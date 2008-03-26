package com.allurent.sizing.model
{
    import mx.collections.ArrayCollection;
    
    public class PackageModel extends FileSegmentModel
    {
        public var packageName:String;
        public var containingPackageModel:PackageModel;
        public var classMap:Object = {};   
        public var packageMap:Object = {};
        public var classCodeSize:int = 0;
        
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
        
        public function get childCount():uint
        {
            var n:uint = 0;
            for (var name:String in classMap)
                n++;
            for (name in packageMap)
                n++;
            return n;
        }
        
        public function addClassModel(model:ClassModel):void
        {
            classMap[model.className] = model;
        }
        
        public function removeClassModel(model:ClassModel):void
        {
            delete classMap[model.className];
        }
        
        public function addPackageModel(model:PackageModel):void
        {
            packageMap[model.packageName] = model;
        }
 
        public function removePackageModel(model:PackageModel):void
        {
            delete packageMap[model.packageName];
        }
        
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