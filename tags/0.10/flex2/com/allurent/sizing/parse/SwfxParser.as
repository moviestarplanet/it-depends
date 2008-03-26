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
     * Prototype parser for SWFX dump produced with the -abc and -showoffset options. 
     * This parser only looks at code sizes, not dependencies, and it probably doesn't get
     * the code size right either since there are generated fragments for constructors and scripts
     * that don't seem to exhibit the proper class name.  More research required.
     */
    public class SwfxParser extends Parser
    {
        private var classSizeMap:Object = {};
        
        private var functionRE:RegExp = /^ +offset (\d+):( [0-9A-F]{2})+ +function (get |set )?([a-zA-Z0-9.$_:]+)/;
        private var endRE:RegExp = /^ +offset (\d+):.*Entries/;
        private var currentOffset:int = -1;
        private var currentName:String = null;
       
        
        public function SwfxParser(codeModel:CodeModel)
        {
            super(codeModel);
        }
        
        override public function parseFile(file:File):void
        {
            var input:FileStream = new FileStream();
            input.open(file, FileMode.READ);
            var buffer:String = "";
            const BLOCK_SIZE:int = 1024;
            while (input.bytesAvailable > 0)
            {
                buffer += input.readUTFBytes(Math.min(input.bytesAvailable, BLOCK_SIZE));
                while (true)
                {
                    var nextEol:int = buffer.indexOf("\n");
                    if (nextEol >= 0)
                    {
                        handleLine(buffer.substring(0, nextEol));
                        buffer = buffer.substring(nextEol+1);
                    }
                    else
                    {
                        break;
                    }
                }
            }

            input.close();

            processClassSizes();
       }
       
       private function handleLine(line:String):void
       {
           while(line.charAt(line.length-1) == "\r")
           {
               line = line.substring(0, line.length-1);
           }
           
           var result:Object = functionRE.exec(line);
           var offset:int = 0;
           if (result)
           {
               var fnName:String = result[4];
               offset = parseInt(result[1]);
               var fnSplit:Array = fnName.split("::");
               if (fnSplit.length > 1)
               {
                   currentName = fixClassName(fnSplit[0]);
                   currentOffset = offset;
               }
               return;
           }
           
           result = endRE.exec(line);
           if (result && currentName != null)
           {
               offset = parseInt(result[1]);
               handleFunction(currentName, offset - currentOffset);
               currentName = null;
               currentOffset = offset;
           }
       }
       
       private function handleFunction(className:String, length:int):void
       {
           if (className.substring(0, 8) == "private:")
           {
               return;
           }
           
           if (className in classSizeMap)
           {
               classSizeMap[className] += length;
           }
           else
           {
               classSizeMap[className] = length;
           }
       }
       
       private function processClassSizes():void
       {
           for (var className:String in classSizeMap)
           {
               codeModel.addClassSize(className, classSizeMap[className]);
           }
       }
    }
}