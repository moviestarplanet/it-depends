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
    import mx.collections.ArrayCollection;
    
    /**
     * Model object representing some segment or cross section of a SWF-based application. 
     * @author joeb
     * 
     */
    public class FileSegmentModel
    {
        /** Size in bytes. */
        public var size:int = 0;
        
        /** True if this model has been deleted from the owning code model; provides book-keeping during
         *  dependency graph traversal.
         */
        public var deleted:Boolean = false;
        
        /** The owning CodeModel for this object. */
        public var codeModel:CodeModel;
        
        /** An unqualified name that can be used for general display purposes. */
        public var unqualifiedName:String;
        
        public function FileSegmentModel(codeModel:CodeModel)
        {
            this.codeModel = codeModel;
        }

        /**
         * The total size of all occurences of this type of segment within the SWF.
         * e.g. for fonts, the total size of all fonts.  For classes/packages, the total
         * code size.  
         */
        public function get totalSize():int
        {
            return 0;
        }
    }
}