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
package com.allurent.sizing.tree
{
    import com.allurent.sizing.event.ModelEvent;
    import com.allurent.sizing.model.CodeModel;
    
    import mx.collections.ArrayCollection;

    [RemoteClass(alias="com.allurent.sizing.tree.ModelCollection")]
    
    /**
     * Collection of model objects shown in a tree or list view; monitors REMOVE events
     * to keep itself updated (in a very expensive, hacked way).
     */
    public class ModelCollection extends ArrayCollection
    {
        public function ModelCollection(codeModel:CodeModel)
        {
            codeModel.addEventListener(ModelEvent.REMOVE, removeHandler, false, 0, true);
        }

        private function removeHandler(e:ModelEvent):void
        {
            for (var i:int = 0; i < length; i++)
            {
                // TODO: use lookup table
                if (getItemAt(i).data == e.model)
                {
                    removeItemAt(i);
                    refresh();   // seems to be necessary to avoid errors down the line
                    return;
                }
            }
        }
    }
}