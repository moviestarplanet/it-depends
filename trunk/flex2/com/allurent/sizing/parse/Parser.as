package com.allurent.sizing.parse
{
    import com.allurent.sizing.model.CodeModel;
    import flash.filesystem.File;
    import flash.filesystem.FileStream;
    import flash.filesystem.FileMode;
    
    public class Parser
    {
        protected var codeModel:CodeModel;

        public function Parser(model:CodeModel)
        {
            this.codeModel = model;
        }
        
        public function parseXML(xml:XML):void
        {
        }

        public function parseFile(file:File):void
        {
            var input:FileStream = new FileStream();
            input.open(file, FileMode.READ);
            var fileContents:String = input.readUTFBytes(input.bytesAvailable);
            XML.ignoreComments = false;
            parseXML(new XML(fileContents));
            XML.ignoreComments = true;
            input.close();
        }
    }
}