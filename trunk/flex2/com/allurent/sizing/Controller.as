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