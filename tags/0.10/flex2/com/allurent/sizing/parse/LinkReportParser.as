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
    
    /**
     * Parse a link report from MXMLC, filling up a CodeModel with the information. 
     */
    public class LinkReportParser extends Parser
    {
        private const MX_INTERNAL:String = "mx.core.mx_internal";
        
        public function LinkReportParser(codeModel:CodeModel)
        {
            super(codeModel);
        }
        
        /**
         * Parse the XML for a link report. 
         */
        override public function parseXML(xml:XML):void
        {
            for each (var script:XML in xml..script)
            {
                // Add the basic information for a class.  Note that the call to
                // addClassSize() will implicitly add ClassModels and PackageModels
                // as needed to maintain the completeness and consistency of the linkage model.
                //
                var className:String = fixClassName(script.def.@id);
                codeModel.addClassSize(className, script.@size);

                // parse prerequisites and dependencies as needed.  Ignore
                // MX internal stuff in both cases.
                for each (var prerequisite:XML in script.pre)
                {
                    var prereqName:String = fixClassName(prerequisite.@id);
                    if (prereqName != MX_INTERNAL)
                    {
                        codeModel.addClassPrerequisite(className, prereqName);
                    }
                }
                for each (var dependency:XML in script.dep)
                {
                    var depName:String = fixClassName(dependency.@id);
                    if (depName != MX_INTERNAL)
                    {
                        codeModel.addClassDependency(className, depName);
                    }
                }
            }
        }
    }
}