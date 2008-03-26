package com.allurent.sizing.event
{
    import com.allurent.sizing.model.FileSegmentModel;
    
    import flash.events.Event;

    public class ModelEvent extends Event
    {
        public static const REMOVE:String = "remove";
        public static const REFRESH:String = "refresh";
        
        public var model:FileSegmentModel;
        
        public function ModelEvent(type:String, model:FileSegmentModel = null)
        {
            super(type, bubbles, cancelable);
            this.model = model;
        }
        
    }
}