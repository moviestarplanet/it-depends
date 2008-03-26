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
    
    public class SwfxParser extends Parser
    {
        public function SwfxParser(codeModel:CodeModel)
        {
            super(codeModel);
        }
        
        override public function parseXML(xml:XML):void
        {
            var offset:int = -1;
            var size:int = -1;
            var offsetRE:RegExp = /offset=([0-9]+)/;
            var sizeRE:RegExp = /size=([0-9]+)/;
            for each (var child:XML in xml.children())
            {
                if (child.nodeKind() == "comment")
                {
                    var result:Array = offsetRE.exec(child.toXMLString());
                    if (result)
                    {
                        offset = result[1];
                    }
                    result = sizeRE.exec(child.toXMLString());
                    if (result)
                    {
                        size = result[1];
                    }
                }
                else if (child.nodeKind() == "element" && size > 0)
                {
                    switch(child.localName())
                    {
                        case "DefineFont3":
                            if (child.@font)
                            {
                                codeModel.addFontSize(child.@font, size);
                            }
                            break;
                        case "DoABC2":
                            if (child.@name)
                            {
                                var className:String = child.@name.toString().replace(/\//g, ".");
                                if (className.match(/^_.+WatcherSetupUtil$/))
                                {
                                    className = className.substring(1).replace(/_/g, ".");
                                }
                                codeModel.addClassSize(className, size);
                            }
                            break;
                    }

                    // reset offset and size once consumed by an element
                    offset = size = -1;
                }
            }
        }
    }
}