package com.allurent.sizing.model
{
    import mx.collections.ArrayCollection;
    
    public class FontModel extends FileSegmentModel
    {
        public var fontName:String;
        
        public function FontModel(codeModel:CodeModel, fontName:String)
        {
            super(codeModel);
            this.fontName = fontName;
        }
        
        override public function get totalSize():int
        {
            return codeModel.totalFontSize;
        }
    }
}