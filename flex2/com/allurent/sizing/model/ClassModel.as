package com.allurent.sizing.model
{
    import mx.collections.ArrayCollection;
    
    public class ClassModel extends FileSegmentModel
    {
        public var className:String;

        public var packageModel:PackageModel;
        public var referenceMap:Object = {};
        public var referrerMap:Object = {};
        
        public var mark:Boolean = false;
        
        public function ClassModel(codeModel:CodeModel, className:String)
        {
            super(codeModel);
            
            this.className = className;

            var index:int = className.lastIndexOf(".");
            if (index > 0)
            {
                packageModel = codeModel.getPackageModel(className.substring(0, index));
                unqualifiedName = className.substring(index+1);
            }
            else
            {
                packageModel = codeModel.rootPackage;
                unqualifiedName = className;
            }
        }

        public function get referenceCount():int
        {
            var n:int = 0;
            for (var className:String in referenceMap)
            {
                n++;
            }
            return n;
        }
        
        public function get referrerCount():int
        {
            var n:int = 0;
            for (var className:String in referrerMap)
            {
                n++;
            }
            return n;
        }
        
        public function addPrerequisite(classModel:ClassModel):void
        {
            // prerequisites and dependencies treated both as ext. references
            referenceMap[classModel.className] = classModel;
            classModel.referrerMap[className] = this;
        }
        
        public function addDependency(classModel:ClassModel):void
        {
            referenceMap[classModel.className] = classModel;
            classModel.referrerMap[className] = this;
        }
        
        public function removeDependency(classModel:ClassModel):void
        {
            delete referenceMap[classModel.className]
            delete classModel.referrerMap[className];
        }
        
        public function get references():Array
        {
            var result:Array = [];
            for each (var c:ClassModel in referenceMap)
            {
                result.push(c);
            }
            return result;
        }

        public function get referrers():Array
        {
            var result:Array = [];
            for each (var c:ClassModel in referrerMap)
            {
                result.push(c);
            }
            return result;
        }

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
        
        public function get referenceClosureMap():Object
        {
            var resultSet:Object = {};
            addReferenceClosure(resultSet);
            return resultSet;
        }
        
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
        
        override public function get totalSize():int
        {
            return codeModel.project.codeModel.totalCodeSize;
        }
   }
}