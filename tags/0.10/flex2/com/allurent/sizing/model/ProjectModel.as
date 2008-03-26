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
    import flash.filesystem.File;
    
    /**
     * Model representing an ItDepends project, which is a set of one or more link reports, SWFX
     * documents with offsets, source path entries, catalog names and a main class name. 
     * @author joeb
     * 
     */
    [Bindable]
    public class ProjectModel
    {
        public var swfxNames:Array = [];
        public var linkReportNames:Array = [];
        public var catalogNames:Array = []
        public var sourcePath:Array = [];

        public var codeModel:CodeModel;
        
        public var mainClassName:String = null;
        
        /**
         * Parse some XML into this project model.
         */        
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
        
        /**
         * Convert this project model into XML to be saved as a project definition. 
         */
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
        
        /**
         * Get the File for a source filename by searching in the set of source paths
         * for this ProjectModel. 
         */
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
        
        /**
         * Obtain a filename for some source file corresponding to a Class.  Look for both
         * MXML and AS definitions.  Returns null if no file could be found.
         *  
         */
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