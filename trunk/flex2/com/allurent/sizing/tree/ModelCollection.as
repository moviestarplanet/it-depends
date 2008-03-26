package com.allurent.sizing.tree
{
    import com.allurent.sizing.event.ModelEvent;
    import com.allurent.sizing.model.CodeModel;
    
    import mx.collections.ArrayCollection;

    [RemoteClass(alias="com.allurent.sizing.tree.ModelCollection")]
    
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