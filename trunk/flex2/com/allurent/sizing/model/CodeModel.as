package com.allurent.sizing.model
{
    import com.allurent.sizing.event.ModelEvent;
    
    import flash.events.EventDispatcher;
    
    [Bindable]
    public class CodeModel extends EventDispatcher
    {
        public var totalFontSize:int = 0;
        public var totalCodeSize:int = 0;
        public var totalClasses:int = 0;
        public var linkedClasses:int = 0;
        
        public var fontMap:Object = {};
        public var classMap:Object = {};
        public var packageMap:Object = {};
        public var externalMap:Object = {};
        public var rootPackage:PackageModel;

        public var parentModule:CodeModel;
        public var project:ProjectModel;
        
        public function CodeModel(project:ProjectModel)
        {
            this.project = project;
            
            rootPackage = new PackageModel(this, "");
        }
        
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
        
        public function get isModule():Boolean
        {
            return this != project.codeModel;
        }

        public function addClasses(classes:Array):void
        {
            for each (var c:ClassModel in classes)
            {
                addClass(c);
            }
        }
        
        public function addClass(c:ClassModel):void
        {
            if (!(c.className in classMap)
                || (getClassModel(c.className).size == 0 && c.size > 0))
            {
                addClassSize(c.className, c.size);
                for each (var ext:ClassModel in c.referenceMap)
                {
                    addClassDependency(c.className, ext.className);
                }
            }
        }
        
        public function removeClass(c:ClassModel):void
        {
            if (c.className in classMap && !c.deleted)
            {
                c.deleted = true;
                removeClassSize(c.className, c.size);
                for each (var ext:ClassModel in c.referenceMap)
                {
                    removeClassDependency(c.className, ext.className);
                }
                for each (ext in c.referrerMap)
                {
                    removeClassDependency(ext.className, c.className);
                }

                var packageModel:PackageModel = c.packageModel;
                packageModel.removeClassModel(c);
                delete classMap[c.className];
                totalClasses--;
                dispatchEvent(new ModelEvent(ModelEvent.REMOVE, c));

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
        }

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
        
        public function addClassPrerequisite(className:String, prereqName:String):void
        {
            getClassModel(className).addPrerequisite(getClassModel(prereqName));
        }
        
        public function addClassDependency(className:String, depName:String):void
        {
            getClassModel(className).addDependency(getClassModel(depName));
        }

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
        
        public function refresh():void
        {
            dispatchEvent(new ModelEvent(ModelEvent.REFRESH));
        }
    }
}