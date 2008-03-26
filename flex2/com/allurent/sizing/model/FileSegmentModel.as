package com.allurent.sizing.model
{
    import mx.collections.ArrayCollection;
    
    public class FileSegmentModel
    {
        public var size:int = 0;
        public var deleted:Boolean = false;
        public var codeModel:CodeModel;
        public var unqualifiedName:String;
        
        public function FileSegmentModel(codeModel:CodeModel)
        {
            this.codeModel = codeModel;
        }

        public function get totalSize():int
        {
            return 0;
        }
    }
}