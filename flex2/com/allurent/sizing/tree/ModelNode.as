package com.allurent.sizing.tree
{
    import com.allurent.sizing.event.ModelEvent;
    import com.allurent.sizing.model.ClassModel;
    import com.allurent.sizing.model.FileSegmentModel;
    import com.allurent.sizing.model.PackageModel;
    
    import mx.collections.ArrayCollection;
    import mx.formatters.NumberFormatter;

    [RemoteClass(alias="com.allurent.sizing.tree.ModelNode")]
    
    [Bindable]
    public class ModelNode
    {
        private static var _formattersInitialized:Boolean = false;
        private static var percentFormatter:NumberFormatter;
        private static var sizeFormatter:NumberFormatter;
        
        public var label:String;
        public var type:int;
        public var data:FileSegmentModel;
        public var children:ArrayCollection;
        
        public static const PACKAGE_TYPE:int = 1;
        public static const PACKAGE_CLASSES_TYPE:int = 2;
        public static const CLASS_TYPE:int = 3;
        
        public function ModelNode(model:FileSegmentModel, type:int, children:ArrayCollection = null)
        {
            if (!_formattersInitialized)
            {
                percentFormatter = new NumberFormatter();
                percentFormatter.precision = 2;
                sizeFormatter = new NumberFormatter();
                sizeFormatter.useThousandsSeparator = true;
                _formattersInitialized = true;
            }

            this.data = model;
            this.type = type;
            this.children = children;

            updateLabel();
            
            if (type != CLASS_TYPE)
            {
                model.codeModel.addEventListener(ModelEvent.REFRESH, handleModelRefresh);
            }
        }

        public function get size():int
        {
            switch (type)
            {
                case PACKAGE_TYPE:
                case CLASS_TYPE:
                    return data.size;
                    
                case PACKAGE_CLASSES_TYPE:
                    return PackageModel(data).classCodeSize;
                    
                default:
                    return 0;
            }
        }        

        private function handleModelRefresh(e:ModelEvent):void
        {
            updateLabel();
        }
        
        public function updateLabel():void
        {
            this.label = (type == PACKAGE_CLASSES_TYPE ? "<classes>" : data.unqualifiedName)
                         + segmentSuffix();
        }

        private function segmentSuffix():String
        {
            var ss:String = ": " + percentFormatter.format(size * 100 / data.totalSize)
                   + "% (" + sizeFormatter.format(size) + ")";
                   
           if (data is ClassModel)
           {
               ss += " [" + ClassModel(data).referrerCount + "]";
           }
           
           return ss;
        }
    }
}