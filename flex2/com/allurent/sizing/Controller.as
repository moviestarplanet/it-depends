package com.allurent.sizing
{
    import com.allurent.sizing.model.CodeModel;
    import com.allurent.sizing.model.ProjectModel;
    import com.allurent.sizing.parse.LinkReportParser;
    import com.allurent.sizing.parse.SwfxParser;
    
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    
    public class Controller
    {
        [Bindable]
        public var project:ProjectModel;
        
        public function loadProject(file:File):void
        {
            var input:FileStream = new FileStream();
            input.open(file, FileMode.READ);
            var fileContents:String = input.readUTFBytes(input.bytesAvailable);
            input.close();
            
            project = new ProjectModel();
            project.fromXML(new XML(fileContents));
            project.codeModel = new CodeModel(project);
            loadProjectContents();
        }
        
        public function loadLinkReport(file:File):void
        {
            project = new ProjectModel();
            project.linkReportNames.push(file.nativePath);
            project.codeModel = new CodeModel(project);
            loadProjectContents();
        }

        public function loadSwfx(file:File):void
        {
            project = new ProjectModel();
            project.swfxNames.push(file.nativePath);
            project.codeModel = new CodeModel(project);
            loadProjectContents();
        }

        private function loadProjectContents():void
        {
            for each (var linkReportName:String in project.linkReportNames)
            {
                new LinkReportParser(project.codeModel).parseFile(new File(linkReportName));
            }
            for each (var swfxName:String in project.swfxNames)
            {
                new SwfxParser(project.codeModel).parseFile(new File(swfxName));
            }
        }
    }
}