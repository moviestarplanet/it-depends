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
     * Model of a Class in the application. 
     */
    public class ClassModel extends FileSegmentModel
    {
        /** Fully qualified name of this class. */
        public var className:String;

        /** Containing package of this class */
        public var packageModel:PackageModel;
        
        /** name -> ClassModel map for all outgoing dependencies. */
        public var referenceMap:Object = {};
        
        /** name -> ClassModel map for all incoming dependencies. */
        public var referrerMap:Object = {};
        
        /** Bookkeeping mark for graph traversal. */
        public var mark:Boolean = false;
        
        /**
         * Create a new ClassModel. 
         * @param codeModel the owning CodeModel object
         * @param className the name of this class
         */
        public function ClassModel(codeModel:CodeModel, className:String)
        {
            super(codeModel);
            
            this.className = className;

            // Ensure a reference to the containing package
            var index:int = className.lastIndexOf(".");
            if (index > 0)
            {
                // Note: this creates the PackageModel if it doesn't exist.
                packageModel = codeModel.getPackageModel(className.substring(0, index));
                unqualifiedName = className.substring(index+1);
            }
            else
            {
                packageModel = codeModel.rootPackage;
                unqualifiedName = className;
            }
        }

        /**
         * Get the number of classes on which this class depends. 
         */
        public function get referenceCount():int
        {
            var n:int = 0;
            for (var className:String in referenceMap)
            {
                n++;
            }
            return n;
        }
        
        /**
         * The number of classes that depend on this Class. 
         */
        public function get referrerCount():int
        {
            var n:int = 0;
            for (var className:String in referrerMap)
            {
                n++;
            }
            return n;
        }
        
        /**
         * Records an outgoing dependency in the linkage model, symmetrically
         * accounted for on both ends of the relationship.
         */
        public function addDependency(classModel:ClassModel):void
        {
            referenceMap[classModel.className] = classModel;
            classModel.referrerMap[className] = this;
        }
        
        /**
         * Records a prerequisite in the linkage model, equivalent to an
         * outgoing dependency. 
         */
        public function addPrerequisite(classModel:ClassModel):void
        {
            referenceMap[classModel.className] = classModel;
            classModel.referrerMap[className] = this;
        }
        
        /**
         * Removes an outgoing dependency, managing both ends of the relationship.
         */
        public function removeDependency(classModel:ClassModel):void
        {
            delete referenceMap[classModel.className]
            delete classModel.referrerMap[className];
        }
        
        /**
         * @return An array of all outgoing dependencies. 
         */
        public function get references():Array
        {
            var result:Array = [];
            for each (var c:ClassModel in referenceMap)
            {
                result.push(c);
            }
            return result;
        }

        /**
         * @return an array of all incoming dependencies. 
         */
        public function get referrers():Array
        {
            var result:Array = [];
            for each (var c:ClassModel in referrerMap)
            {
                result.push(c);
            }
            return result;
        }

        /**
         * Obtain the transitive closure of all outgoing dependencies
         * starting from this Class.
         */
        public function get referenceClosure():Array
        {
            var closureMap:Object = referenceClosureMap;
            var result:Array = [];
            for each (var c:ClassModel in closureMap)
            {
                result.push(c);
            }
            return result;
        }
        
        /**
         * Obtain a map whose class name -> ClassModel entries represent
         * the transitive closure of all outgoing dependencies from this Class. 
         */
        public function get referenceClosureMap():Object
        {
            var resultSet:Object = {};
            addReferenceClosure(resultSet);
            return resultSet;
        }
        
        /**
         * Figure out if this ClassModel has some PackageModel as an ancestor. 
         * @param p a PackageModel
         * @return true if this class belongs to the given package or one of its subpackages.
         * 
         */
        public function inPackage(p:PackageModel):Boolean
        {
            var p2:PackageModel = this.packageModel;
            while (p2 != null)
            {
                if (p2.packageName == p.packageName)
                {
                    return true;
                }
                p2 = p2.containingPackageModel;
            }
            return false;
        }
        
        /**
         * The total code size of the application to which this class belongs.  
         */
        override public function get totalSize():int
        {
            return codeModel.project.codeModel.totalCodeSize;
        }

        /**
         * Build a map from class names -> ClassModels whose entries represent
         * the transitive closure of outgoing references from this class. 
         * 
         * @param resultSet an Object used as a map to which these entries should be added.
         * 
         */        
        private function addReferenceClosure(resultSet:Object):void
        {
            for each (var reference:ClassModel in referenceMap)
            {
                if (!(reference.className in resultSet))
                {
                    resultSet[reference.className] = reference;
                    reference.addReferenceClosure(resultSet);
                }
            }
        }

  }
}