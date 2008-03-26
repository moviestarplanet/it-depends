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
package com.allurent.sizing.parse
{
    import com.allurent.sizing.model.CodeModel;
    
    import flash.filesystem.File;
    import flash.filesystem.FileMode;
    import flash.filesystem.FileStream;
    
    /**
     * Abstract XML parser class to handle both link reports and SWFX output. 
     */
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

        public function parseContents(fileContents:String):void
        {
            parseXML(new XML(fileContents));
        }

        public function parseFile(file:File):void
        {
            var input:FileStream = new FileStream();
            input.open(file, FileMode.READ);
            var fileContents:String = input.readUTFBytes(input.bytesAvailable);
            XML.ignoreComments = false;
            parseContents(fileContents);
            XML.ignoreComments = true;
            input.close();
        }
        
        /**
         * Turn a class name as it occurs in the LinkReport into something
         * that we can work with, with nice dots 'n' everything.  Also strip off
         * the initial _ from watcher setup classes for clarity of analysis.
         */
        public static function fixClassName(className:String):String
        {
            className = className.replace(/:/g, ".");
            if (className.match(/^_.+WatcherSetupUtil$/))
            {
                className = className.substring(1).replace(/_/g, ".");
            }
            if (className.charAt(0) == ".")
            {
                className = className.substring(1);
            }
            return className;
        }
   }
}