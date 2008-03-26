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