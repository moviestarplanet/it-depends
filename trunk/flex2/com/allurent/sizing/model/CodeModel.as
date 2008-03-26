/* 
 * Copyright (c) 2008 Allurent, Inc.
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without restriction,
 * including without limitation the rights to use, copy, modify,
 * merge, publish, distribute, sublicense, and/or sell copies of the
 * Software, and to permit persons to whom the Software is furnished
 * to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
 * OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package com.allurent.sizing.model
{
    import com.allurent.sizing.event.ModelEvent;
    
    import flash.events.EventDispatcher;
    
    /**
     * A CodeModel represents a set of ClassModels and PackageModels that belong to an application,
     * or to a specific module within that application. 
     */
    [Bindable]
    public class CodeModel extends EventDispatcher
    {
        /** Total size of all fonts in the SWF */
        public var totalFontSize:int = 0;
        
        /** Total code size in the SWF (the numbers are inflated by MXMLC for some reason) */ 
        public var totalCodeSize:int = 0;
        
        /** Total number of classes in the model including externals/intrinsics. */
        public var totalClasses:int = 0;
        
        /** Total number of classes with nonzero code size in the model. */
        public var linkedClasses:int = 0;

        /** Map from font names to FontModels */        
        public var fontMap:Object = {};
        
        /** Map from class names to ClassModels */
        public var classMap:Object = {};
        
        /** Map from package names to package models */
        public var packageMap:Object = {};

        /** The anonymous top-level package. */         
        public var rootPackage:PackageModel;

        /**
         * If non-null, gives the parent module's CodeModel.  Typically the parent module of 
         * a module is in fact the base application.  The base application itself has no parent
         * (and the nullity of parentModule tells us that a given module is the base app).
         */
        public var parentModule:CodeModel;
        
        /**
         * The owning ProjectModel, whose CodeModel represents the "unretouched" linkage model of the app.
         */
        public var project:ProjectModel;
        
        /**
         * Construct a new CodeModel. 
         */
        public function CodeModel(project:ProjectModel)
        {
            this.project = project;
            
            rootPackage = new PackageModel(this, "");
        }
        
        /**
         * Construct a clone of this CodeModel. 
         */
        public function copyCodeModel():CodeModel
        {
            var codeModel:CodeModel = new CodeModel(project);
            for each (var c:ClassModel in classMap)
            {
                if (c.size > 0)
                    codeModel.addClass(c);
            }
            return codeModel;
        }
        
        /**
         * True if this CodeModel is a module, rather than the base application. 
         */
        public function get isModule():Boolean
        {
            return this != project.codeModel;
        }

        /**
         * Add one or more classes to this model. 
         * @param classes an array of ClassModel objects.
         */
        public function addClasses(classes:Array):void
        {
            for each (var c:ClassModel in classes)
            {
                addClass(c);
            }
        }
        
        /**
         * Add a single ClassModel to this code model.
         */
        public function addClass(c:ClassModel):void
        {
            // Add 'c' to the model if 1) its class name is not already
            // known, OR 2) if it has a nonzero code size and we only know
            // that class as a zero-size external.
            // 
            if (!(c.className in classMap)
                || (getClassModel(c.className).size == 0 && c.size > 0))
            {
                // record the class size of this new ClassModel, which also
                // constructs PackageModels as needed for it. 
                addClassSize(c.className, c.size);
                
                // record both ends of all outgoing dependencies from this class.
                for each (var ext:ClassModel in c.referenceMap)
                {
                    addClassDependency(c.className, ext.className);
                }
            }
        }
        
        /**
         * Remove a single ClassModel from this code model. 
         */
        public function removeClass(c:ClassModel):void
        {
            if (c.className in classMap && !c.deleted)
            {
                c.deleted = true;
                removeClassSize(c.className, c.size);
                
                // remove both incoming and outgoing dependencies.
                for each (var ext:ClassModel in c.referenceMap)
                {
                    removeClassDependency(c.className, ext.className);
                }
                for each (ext in c.referrerMap)
                {
                    removeClassDependency(ext.className, c.className);
                }

                // remove from containing package model and from our class map, decrement
                // class count, and signal listeners to remove this class.
                //
                var packageModel:PackageModel = c.packageModel;
                packageModel.removeClassModel(c);
                delete classMap[c.className];
                totalClasses--;
                dispatchEvent(new ModelEvent(ModelEvent.REMOVE, c));

                // clean up ancestor packages that may now have zero classes in them
                while (packageModel != null && packageModel.childCount == 0)
                {
                    
                    delete packageMap[packageModel.packageName];
                    dispatchEvent(new ModelEvent(ModelEvent.REMOVE, packageModel));
                    
                    var containingPackageModel:PackageModel = packageModel.containingPackageModel;
                    if (containingPackageModel != null)
                    {
                        containingPackageModel.removePackageModel(packageModel);
                    }
                    packageModel = containingPackageModel;
                }
            }
        }
        
        /**
         * Look up all dangling references and bring those classes in from the "master code model"
         * in the project. 
         */
        public function closeUnderReferences():void
        {
            for each (var c:ClassModel in classMap)
            {
                if (c.size > 0)
                {
                    var closure:Array = project.codeModel.getClassModel(c.className).referenceClosure;
                    for each (var reference:ClassModel in closure)
                    {
                        if (resolveClassName(reference.className) == null)
                        {
                            addClass(reference);
                        }
                    }
                }
            }
        }
        
        /**
         * Remove all classes from this model that are not in the transitive closure
         * of dependencies starting from some root class.
         *  
         * @param rootClassName the name of a root class
         * 
         */
        public function gcFromRootClass(rootClassName:String):void
        {
            var root:ClassModel = getClassModel(rootClassName);
            var rootRefClosureMap:Object = root.referenceClosureMap;
            for (var className:String in classMap)
            {
                if (!(className in rootRefClosureMap))
                {
                    removeClass(getClassModel(className));
                }
            }
        }
        
        /**
         * Add a PackageModel to this code model.  This also adds all
         * classes and subpackages recursively contained within the package. 
         */
        public function addPackage(p:PackageModel):void
        {
            for each (var c:ClassModel in p.classMap)
            {
                addClass(c);
            }
            for each (var pp:PackageModel in p.packageMap)
            {
                addPackage(pp);
            }
            
            // NOTE: we don't need to actually add the package to packageMap,
            // because if it has any descendant classes in it, it will be noted as a side effect
            // of adding those classes.
        }

        /**
         * Remove a PackageModel from this code model. 
         */
        public function removePackage(p:PackageModel):void
        {
            for each (var c:ClassModel in p.classMap)
            {
                removeClass(c);
            }
            for each (var pp:PackageModel in p.packageMap)
            {
                removePackage(pp);
            }
            
            delete packageMap[p.packageName];
            dispatchEvent(new ModelEvent(ModelEvent.REMOVE, p));
        }

        public function getFontModel(fontName:String):FontModel
        {
            var model:FontModel = fontMap[fontName];
            if (model == null)
            {
                model = new FontModel(this, fontName);
                fontMap[fontName] = model;
            }
            return model;
        }
        
        /**
         * Obtain a PackageModel from this code model for some package name,
         * creating the model if it does not already exist. 
         */
        public function getPackageModel(packageName:String):PackageModel
        {
            var model:PackageModel = packageMap[packageName];
            if (model == null)
            {
                model = new PackageModel(this, packageName);
                packageMap[packageName] = model;
                if (packageName.indexOf(".") < 0)
                {
                    rootPackage.addPackageModel(model);
                }
                model.containingPackageModel.addPackageModel(model);
            }
            return model;
        }
        
        /**
         * Obtain a ClassModel from this code model for some class name,
         * creating a zero-size class model (i.e. an external) if it does not
         * already exist.  
         */
        public function getClassModel(className:String):ClassModel
        {
            var model:ClassModel = classMap[className];
            if (model == null)
            {
                model = new ClassModel(this, className);
                classMap[className] = model;
                totalClasses++;
                model.packageModel.addClassModel(model);
            }
            return model;
        }
        
        /**
         * Resolve a ClassModel from a class name.  Return null if there is none
         * in this code model, or if its size is zero (i.e. it's an external reference.) 
         */
        public function resolveClassName(className:String):ClassModel
        {
            var model:ClassModel = getClassModel(className);
            if (model.size == 0)
            {
                model = null;
            }
            if (model != null || parentModule == null)
            {
                return model;
            }
            return parentModule.resolveClassName(className);
        }

        public function addFontSize(fontName:String, size:int):void
        {
            getFontModel(fontName).size += size;
            totalFontSize += size;
        }

        /**
         * Add a class's size to this code model, which also takes care of
         * updating the code sizes of all ancestor packages of that class. 
         */
        public function addClassSize(className:String, size:int):void
        {
            var model:ClassModel = getClassModel(className);
            if (model.size == 0)
            {
                linkedClasses++;
            }
            model.size += size;
            var packageModel:PackageModel = model.packageModel;
            packageModel.classCodeSize += size;
            do {
                packageModel.size += size;
                packageModel = packageModel.containingPackageModel;
            }
            while (packageModel != null);
            totalCodeSize += size;
        }
        
        /**
         * Remove a class's size from this code model, adjusting ancestor packages
         * as in addClassSize(). 
         * 
         */
        public function removeClassSize(className:String, size:int):void
        {
            var model:ClassModel = getClassModel(className);
            var packageModel:PackageModel = model.packageModel;
            packageModel.classCodeSize -= size;
            do {
                packageModel.size -= size;
                packageModel = packageModel.containingPackageModel;
            }
            while (packageModel != null);
            totalCodeSize -= size;
            
            if (model.size > 0)
            {
                linkedClasses--;
            }
        }
        
        /**
         * Add a bidirectional prerequisite relationship to this model between a source
         * and target class. 
         */
        public function addClassPrerequisite(className:String, prereqName:String):void
        {
            getClassModel(className).addPrerequisite(getClassModel(prereqName));
        }
        
        /**
         * Add a bidirectional dependency relationship to this model between a source
         * and target class, working from the class names.
         */
        public function addClassDependency(className:String, depName:String):void
        {
            getClassModel(className).addDependency(getClassModel(depName));
        }

        /**
         * Remove a class dependency from this model, working from the names. 
         */
        public function removeClassDependency(className:String, depName:String):void
        {
            var c:ClassModel = getClassModel(className);
            var d:ClassModel = getClassModel(depName);
            c.removeDependency(d);
            if (d.referrerCount == 0)
            {
                removeClass(d);
            }
        }
        
        /**
         * Signal this model to refresh all of its views.  Used after a set of operations
         * that may have globally changed code sizes, among other things. 
         */
        public function refresh():void
        {
            dispatchEvent(new ModelEvent(ModelEvent.REFRESH));
        }
    }
}