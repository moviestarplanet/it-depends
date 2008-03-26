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
    import com.allurent.sizing.model.*;
    
    import mx.collections.ArrayCollection;
    import mx.collections.Sort;
    import mx.collections.SortField;

    /**
     * This class acts as a helper to create data providers from the model that can be handed
     * to a Tree or List. 
     */
    public class PackageTreeData
    {
        private var nonEmptyFilter:Function;
        
        private var typeSizeSort:Sort;
        private var nameSort:Sort;
        
        public function PackageTreeData()
        {
            typeSizeSort = new Sort();
            typeSizeSort.fields = [new SortField("type"), new SortField("size", false, true, true)];
            
            nameSort = new Sort();
            nameSort.fields = [new SortField("label")];
            
            nonEmptyFilter = function(f:FileSegmentModel):Boolean { return f.size > 0; };
        }

        /**
         * Given a PackageModel, return a data provider for that model and all of its
         * subpackages and descendant classes. 
         */
        public function getPackageMapTree(packageModel:PackageModel):ArrayCollection
        {
            var children:ArrayCollection = new ModelCollection(packageModel.codeModel);
            for each (var model:PackageModel in packageModel.packageMap)
            {
                if (nonEmptyFilter(model))
                {
                    children.addItem(new ModelNode(model, ModelNode.PACKAGE_TYPE, getPackageMapTree(model)));
                }
            }
            children.sort = typeSizeSort;
            children.refresh();

            var classChildren:ArrayCollection = children;
            var classChildrenNode:ModelNode = null;
            if (classChildren.length > 0)
            {
                // If there are multiple subpackages, create a special child collection
                // for the classes that are actually hanging right off this package.
                classChildren = new ModelCollection(packageModel.codeModel);
                classChildrenNode = new ModelNode(packageModel, ModelNode.PACKAGE_CLASSES_TYPE ,classChildren);
            }
            
            // add all the classes in this package
            for each (var clsModel:ClassModel in packageModel.classMap)
            {
                if (nonEmptyFilter(clsModel))
                {
                    classChildren.addItem(new ModelNode(clsModel, ModelNode.CLASS_TYPE));
                }
            }

            // add a special <classes> node if necessary
            if (classChildrenNode != null)
            {
                children.addItem(classChildrenNode);
                classChildren.sort = typeSizeSort;
                classChildren.refresh();
            }
            
            return children;
        }

       /**
        * Get a list-structured data provider for some set of packages. 
        */
       public function getPackageMapList(packages:Array):ArrayCollection
       {
            if (packages.length == 0)
            {
                return new ArrayCollection();
            }
                
            var children:ArrayCollection = new ModelCollection(packages[0].codeModel);
            for each (var model:PackageModel in packages)
            {
                if (nonEmptyFilter(model))
                {
                    children.addItem(new ModelNode(model, ModelNode.PACKAGE_TYPE));
                }
            }
            
            children.sort = nameSort;
            children.refresh();
            return children;
        }
        
       /**
        * Get a list-structured data provider for some set of classes. 
        */
       public function getClassList(classes:Array, filter:Function = null):ArrayCollection
       {
            if (classes.length == 0)
            {
                return new ArrayCollection();
            }
            
            var children:ArrayCollection = new ModelCollection(classes[0].codeModel);
            for each (var model:ClassModel in classes)
            {
                if (nonEmptyFilter(model)
                    && (filter == null || filter(model)))
                {
                    children.addItem(new ModelNode(model, ModelNode.CLASS_TYPE));
                }
            }
            
            children.sort = nameSort;
            children.refresh();
            return children;
        }
        
    }
}