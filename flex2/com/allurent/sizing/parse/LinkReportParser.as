package com.allurent.sizing.parse
{
    import com.allurent.sizing.model.CodeModel;
    
    public class LinkReportParser extends Parser
    {
        private const MX_INTERNAL:String = "mx.core.mx_internal";
        
        public function LinkReportParser(codeModel:CodeModel)
        {
            super(codeModel);
        }
        
        override public function parseXML(xml:XML):void
        {
            for each (var script:XML in xml..script)
            {
                var className:String = fixClassName(script.def.@id);
                codeModel.addClassSize(className, script.@size);

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
        
        private static function fixClassName(className:String):String
        {
            className = className.replace(/:/g, ".");
            if (className.match(/^_.+WatcherSetupUtil$/))
            {
                className = className.substring(1).replace(/_/g, ".");
            }
            return className;
        }
    }
}