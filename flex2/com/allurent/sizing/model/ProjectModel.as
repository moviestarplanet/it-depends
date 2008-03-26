package com.allurent.sizing.model
{
    import flash.filesystem.File;
    
    [Bindable]
    public class ProjectModel
    {
        public var swfxNames:Array = [];
        public var linkReportNames:Array = [];
        public var catalogNames:Array = []
        public var sourcePath:Array = [];

        public var codeModel:CodeModel;
        
        public var mainClassName:String = null;
        
        
        public function fromXML(xml:XML):void
        {
            for each (var swfx:XML in xml.swfContents.swfx)
            {
                swfxNames.push(swfx.text().toString());
            }
            for each (var linkReport:XML in xml.swfContents.linkReport)
            {
                linkReportNames.push(linkReport.text().toString());
            }
            for each (var catalog:XML in xml.swfContents.catalog)
            {
                catalogNames.push(catalog.text().toString());
            }
            for each (var dir:XML in xml.sourcePath.directory)
            {
                sourcePath.push(new File(dir.text().toString()));
            }
            for each (var mainClass:XML in xml.mainClass)
            {
                mainClassName = mainClass.text().toString();
            }
        }
        
        public function toXML():XML
        {
            var project:XML = <project/>;

            var swfContents:XML = <swfContents/>;
            for each (var swfx:String in swfxNames)
            {
                swfContents.appendChild(<swfx>{swfx}</swfx>);
            }
            for each (var linkReport:String in linkReportNames)
            {
                swfContents.appendChild(<linkReport>{linkReport}</linkReport>);
            }
            for each (var catalog:String in catalogNames)
            {
                swfContents.appendChild(<catalog>{catalog}</catalog>);
            }
            project.appendChild(swfContents);
            
            var sourcePathNode:XML = <sourcePath/>;
            for each (var dir:File in sourcePath)
            {
                sourcePathNode.appendChild(<directory>{dir.nativePath}</directory>);
            }
            project.appendChild(sourcePathNode);

            if (mainClassName != null)
            {
                project.appendChild(<mainClass>{mainClassName}</mainClass>);
            }
            
            return project;
        }
        
        public function findSourceFile(filename:String):File
        {
            for each (var path:File in sourcePath)
            {
                var f:File = path.resolvePath(filename);
                if (f.exists)
                {
                    return f;
                }
            }
            return null;
        }
        
        public function findClass(c:ClassModel):File
        {
            var name:String = c.className.replace(/\./g, File.separator);
            var f:File = findSourceFile(name + ".as");
            if (f != null)
            {
                return f;
            }
            return findSourceFile(name + ".mxml");
        }
    }
}