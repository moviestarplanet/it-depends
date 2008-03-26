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
    import mx.collections.ArrayCollection;
    
    /**
     * Model of a package, its parent packages and its child packages/classes within a CodeModel.
     */
    public class PackageModel extends FileSegmentModel
    {
        /** Fully qualified name of this package. */
        public var packageName:String;
        
        /** Containing parent package of this package, if it is not the root package. */
        public var containingPackageModel:PackageModel;
        
        /** Map from class names to ClassModels for classes directly contained in this package. */
        public var classMap:Object = {};
        
        /** Map from package names to PackageModels for classes directly contained in this package. */
        public var packageMap:Object = {};
        
        /** Total size of all classes in this package and its subpackages. */
        public var classCodeSize:int = 0;
        
        /** Create a new PackageModel. */
        public function PackageModel(codeModel:CodeModel, packageName:String)
        {
            super(codeModel);
            
            this.packageName = packageName;

            var index:int = packageName.lastIndexOf(".");
            if (index > 0)
            {
                containingPackageModel = codeModel.getPackageModel(packageName.substring(0, index));
                unqualifiedName = packageName.substring(index+1);
            }
            else
            {
                containingPackageModel = codeModel.rootPackage;
                unqualifiedName = packageName;
            }
        }
        
        /**
         * Get the child count of this package model, including both classes and packages. 
         */
        public function get childCount():uint
        {
            var n:uint = 0;
            for (var name:String in classMap)
                n++;
            for (name in packageMap)
                n++;
            return n;
        }
        
        /**
         * Add a class to this package. 
         */
        public function addClassModel(model:ClassModel):void
        {
            classMap[model.className] = model;
        }
        
        /**
         * Remove a class from this package. 
         */
        public function removeClassModel(model:ClassModel):void
        {
            delete classMap[model.className];
        }
        
        /**
         * Add a subpackage to this package. 
         */
        public function addPackageModel(model:PackageModel):void
        {
            packageMap[model.packageName] = model;
        }
 
        /**
         * Remove a subpackage from this package. 
         */
        public function removePackageModel(model:PackageModel):void
        {
            delete packageMap[model.packageName];
        }
        
        /**
         * Get the transitive closure of all classes  referred to by any classes at in this
         * package or any of its subpackages. 
         */
        public function get referenceClosure():Array
        {
            var resultSet:Object = {};
            for each (var c:ClassModel in classMap)
            {
                var classes:Array = c.referenceClosure;
                for each (var reference:ClassModel in classes)
                {
                    if (!(reference.className in resultSet))
                    {
                        resultSet[reference.className] = reference;
                    }
                }
            }
            for each (var p:PackageModel in packageMap)
            {
                classes = p.referenceClosure;
                for each (reference in classes)
                {
                    if (!(reference.className in resultSet))
                    {
                        resultSet[reference.className] = reference;
                    }
                }
            }
            var result:Array = [];
            for each (c in resultSet)
            {
                result.push(c);
            }
            return result;
        }
 
        /**
         * Get all immediate references coming out of this package or any of its subpackages. 
         */
        public function get references():Array
        {
            var resultSet:Object = {};
            for each (var c:ClassModel in classMap)
            {
                for each (var reference:ClassModel in c.references)
                {
                    if (!(reference.className in resultSet))
                    {
                        resultSet[reference.className] = reference;
                    }
                }
            }
            for each (var p:PackageModel in packageMap)
            {
                for each (reference in p.references)
                {
                    if (!(reference.className in resultSet))
                    {
                        resultSet[reference.className] = reference;
                    }
                }
            }
            var result:Array = [];
            for each (c in resultSet)
            {
                result.push(c);
            }
            return result;
        }
 
        /**
         * Get all incoming dependencies on this package or any of its subpackages. 
         */
        public function get referrers():Array
        {
            var resultSet:Object = {};
            for each (var c:ClassModel in classMap)
            {
                for each (var referrer:ClassModel in c.referrers)
                {
                    if (!(referrer.className in resultSet))
                    {
                        resultSet[referrer.className] = referrer;
                    }
                }
            }
            for each (var p:PackageModel in packageMap)
            {
                for each (referrer in p.referrers)
                {
                    if (!(referrer.className in resultSet))
                    {
                        resultSet[referrer.className] = referrer;
                    }
                }
            }
            var result:Array = [];
            for each (c in resultSet)
            {
                result.push(c);
            }
            return result;
        }
 
        override public function get totalSize():int
        {
            return codeModel.project.codeModel.totalCodeSize;
        }
   }
}