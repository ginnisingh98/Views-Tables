--------------------------------------------------------
--  DDL for Package Body AMS_TCOP_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_TCOP_WF_PKG" AS
/* $Header: amsvtcwb.pls 120.1 2005/11/17 04:16:47 mayjain noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_TCOP_WF_PKG
-- Purpose
--
-- This package has all the methods required to integrate with
-- OMO Schedule Execution Workflow
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================

Procedure Is_Fatigue_Enabled (
          itemtype in varchar2,
	  itemkey  in varchar2,
	  actid in number,
	  funcmode in varchar2,
          result out nocopy varchar2
) is

   l_fatigue_enabled_flag    varchar2(1);
   l_schedule_id             number;
   l_activity_id             number;

begin

   if ( funcmode = 'RUN') then

      -- Get the Schedule Id set in the Schedule Execution Workflow instance
      l_schedule_id := WF_ENGINE.getItemAttrText
                    (itemtype  =>  itemtype,
                     itemkey   => itemkey,
                     aname     => 'SCHEDULE_ID');


      l_fatigue_enabled_flag := AMS_TCOP_UTIL_PKG.Is_Fatigue_Rule_Applicable(
			        l_schedule_id
			        );

      if (l_fatigue_enabled_flag = 'Y') then
         result := 'COMPLETE:Y';
      else
         result := 'COMPLETE:N';
      end if;

      return;

   end if;

   if ( funcmode = 'CANCEL') then
       result := 'COMPLETE';
       return;
   end if;

   if ( funcmode = 'RESPOND') then
       result := 'COMPLETE';
       return;
   end if;

EXCEPTION

   WHEN OTHERS THEN
       wf_core.context(G_PKG_NAME,'Check_Schedule_Status',itemtype,itemkey,
		       actid,funcmode);
       raise ;

end Is_Fatigue_Enabled;

Procedure Add_Request_To_Queue (
          itemtype in varchar2,
	  itemkey in varchar2,
	  actid in varchar2,
	  funcmode in varchar2,
	  result out nocopy varchar2
)
is
    l_schedule_id	NUMBER;
begin

   if ( funcmode = 'RUN') then

      -- Get the Schedule Id set in the Schedule Execution Workflow instance
      l_schedule_id := WF_ENGINE.getItemAttrText
                    (itemtype  =>  itemtype,
                     itemkey   => itemkey,
                     aname     => 'SCHEDULE_ID');


      -- Enqueue the traffic cop request
      AMS_TCOP_SCHEDULER_PKG.ENQUEUE
      (
         l_schedule_id,
	 itemtype,
	 itemkey
      );

      result := 'COMPLETE';

      return;

   end if;

   if ( funcmode = 'CANCEL') then
       result := 'COMPLETE';
       return;
   end if;

   if ( funcmode = 'RESPOND') then
       result := 'COMPLETE';
       return;
   end if;

EXCEPTION

   WHEN OTHERS THEN
       wf_core.context(G_PKG_NAME,'Add_Request_To_Queue',itemtype,itemkey,
		       actid,funcmode);
       raise ;

end Add_Request_To_Queue;

Procedure Is_This_Request_Scheduled (
          itemtype in varchar2,
	  itemkey  in varchar2,
	  actid in number,
	  funcmode in varchar2,
          result out nocopy varchar2
)
is
   l_response	 VARCHAR2(1);
   l_schedule_id NUMBER;
begin

   if ( funcmode = 'RUN') then

      -- Get the Schedule Id set in the Schedule Execution Workflow instance
      l_schedule_id := WF_ENGINE.getItemAttrText
                    (itemtype  =>  itemtype,
                     itemkey   => itemkey,
                     aname     => 'SCHEDULE_ID');

      -- Enqueue the traffic cop request
      l_response := AMS_TCOP_SCHEDULER_PKG.Is_This_Schedule_Ready_To_Run (
         	    l_schedule_id
                    );

      if (l_response = 'Y') THEN
         result := 'COMPLETE:Y';
      ELSE
         result := 'COMPLETE:N';
      END IF;

      return;

   end if;

   if ( funcmode = 'CANCEL') then
       result := 'COMPLETE';
       return;
   end if;

   if ( funcmode = 'RESPOND') then
       result := 'COMPLETE';
       return;
   end if;

end Is_This_Request_Scheduled;

Procedure Invoke_TCOP_Engine (
          itemtype in varchar2,
	  itemkey  in varchar2,
	  actid in number,
	  funcmode in varchar2,
          result out nocopy varchar2
)
is
   l_schedule_id  NUMBER;
begin

   AMS_Utility_PVT.Write_Conc_Log('AMS_TCOP_WF_PKG.Invoke_TCOP_Engine ==> Entered Invoke_TCOP_Engine');
   if ( funcmode = 'RUN') then

         -- Get the Schedule Id set in the Schedule Execution Workflow instance
         l_schedule_id := WF_ENGINE.getItemAttrText
                       (itemtype  =>  itemtype,
                        itemkey   => itemkey,
                        aname     => 'SCHEDULE_ID');

	 AMS_Utility_PVT.Write_Conc_Log('AMS_TCOP_WF_PKG.Invoke_TCOP_Engine ==> l_schedule_id = ' || l_schedule_id);


         AMS_TCOP_ENGINE_PKG.Apply_Fatigue_Rules(l_schedule_id);

         result := 'COMPLETE:SUCCESS';

         return;

   end if;

   if ( funcmode = 'CANCEL') then
       result := 'COMPLETE';
       return;
   end if;

   if ( funcmode = 'RESPOND') then
       result := 'COMPLETE';
       return;
   end if;
  AMS_Utility_PVT.Write_Conc_Log('AMS_TCOP_WF_PKG.Invoke_TCOP_Engine ==> Exiting Invoke_TCOP_Engine');


/**
   WF_ENGINE.SetItemAttrText(itemtype     =>    p_itemtype,
			     itemkey      =>    p_itemkey ,
			     aname        =>    'AMS_TCOP_ERROR_MSG',
                             avalue       =>    l_final_data   );
**/

end Invoke_TCOP_Engine;


Procedure Run_FR_Conc_Request (
          itemtype in varchar2,
	  itemkey  in varchar2,
	  actid in number,
	  funcmode in varchar2,
          result out NOCOPY varchar2
)
IS
   l_request_id NUMBER;
BEGIN
   l_request_id := 0;

   if ( funcmode = 'RUN') then
      -- Call the concurrent program for "AMS : Apply Fatigue Rules".
      l_request_id := FND_REQUEST.SUBMIT_REQUEST (
                      application       => 'AMS',
                      program           => 'AMSTCSCP'
                     );

      WF_ENGINE.SetItemAttrText(itemtype    =>     itemtype,
                            itemkey     =>   itemkey,
                           aname        =>   'AMS_TCOP_PROGRAM_MSG',
                           avalue       =>   'Concurrent Request Id = ' || to_char(l_request_id));

      result := 'COMPLETE';

      return;
   end if;

   if ( funcmode = 'CANCEL') then
       result := 'COMPLETE';
       return;
   end if;

   if ( funcmode = 'RESPOND') then
       result := 'COMPLETE';
       return;
   end if;

END Run_FR_Conc_Request;

END AMS_TCOP_WF_PKG;

/
