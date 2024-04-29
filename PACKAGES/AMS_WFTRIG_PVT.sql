--------------------------------------------------------
--  DDL for Package AMS_WFTRIG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_WFTRIG_PVT" AUTHID CURRENT_USER as
/* $Header: amsvwfts.pls 120.2 2005/08/29 11:34:24 soagrawa ship $*/

--  Start of Comments
--
-- NAME
--   AMS_WfTrig_PVT
--
-- PURPOSE
--   This package performs the workflow procedures for
--   triggers in Oracle Marketing
--
-- HISTORY
--    28-apr-2003   soagrawa   Added APIs for trigger redesign
--    20-aug-2005   soagrawa   Added code for Conc Program that will purge monitor history
--
/***************************  PRIVATE ROUTINES  *******************************/

-- Start of Comments
--
-- NAME
--   StartProcess
--
-- PURPOSE
--   This Procedure will Start the flow
--
-- IN
--   p_trigger_id      Trigger id
--   p_trigger_name    Trigger Name
--   processowner      Owner Of the Process
--   workflowprocess   Work Flaow Process Name (AMS_TRIGGERS)
--   item_type         Item type 	DEFAULT NULL(AMS_CAMP)

--
-- OUT
--
-- Used By Activities
--
-- NOTES
--
--
-- HISTORY
--    22-MAR-2001    julou    created
-- End of Comments
PROCEDURE StartProcess(p_trigger_id      IN      NUMBER  -- Trigger id
--                   ,p_user_id         IN      NUMBER  -- User id

                   ,processowner      IN      VARCHAR2 	DEFAULT NULL
                   ,workflowprocess   IN      VARCHAR2 	DEFAULT NULL
                   ,item_type         IN      VARCHAR2 	DEFAULT NULL

		   ) ;

-- Start of Comments
--
-- NAME
--   Selector
--
-- PURPOSE
--   This Procedure will determine which process to run
--
-- IN
-- itemtype     - A Valid item type from (WF_ITEM_TYPES Table).
-- itemkey      - A string generated from application object's primary key.
-- actid        - The function Activity
-- funcmode     - Run / Cancel
--
-- OUT
-- resultout    - Name of workflow process to run
--
-- Used By Activities
--
-- NOTES
--
--
-- HISTORY
--   22-MAR-2001    julou     created
-- End of Comments
PROCEDURE selector (
                    itemtype    IN      VARCHAR2,
                    itemkey     IN      VARCHAR2,
                    actid       IN      NUMBER,
                    funcmode    IN      VARCHAR2,
                    resultout   OUT NOCOPY     VARCHAR2
                    ) ;

-- Start of Comments
--
-- NAME
--   Check_Trigger_Status
--
-- PURPOSE
--   This Procedure will check whether the Trigger is Active or Expired
--   It will Return - Yes  if the trigger is Active
--   No If the trigger is Expired
--
-- IN
--    Itemtype - AMS_CAMP
--	  Itemkey  - Trigger ID
--	  Accid    - Activity ID
-- 	  Funmode  - Run/Cancel/Timeout
--
-- OUT
-- 	  Result - 'COMPLETE:Y' If the trigger is Active
--	  		 - 'COMPLETE:N' If the trigger is Expired
--
-- Used By Activities
-- 	  Item Type - AMS_CAMP
--	  Activity  - AMS_CHECK_TRIGGER_STATUS
--
-- NOTES
--
--
-- HISTORY
--    22-MAR-2001    julou    created
-- End of Comments
PROCEDURE Check_Trigger_Status(itemtype    IN	VARCHAR2,
                               itemkey     IN	VARCHAR2,
                               actid       IN	NUMBER,
                               funcmode	   IN	VARCHAR2,
                               result      OUT NOCOPY  VARCHAR2) ;

-- Start of Comments
--
-- NAME
--   Perform_Check
--
-- PURPOSE
--   This Procedure will perform the check on standard item and Comparison Item
--   with the operator provided
--   It will Return - Success if the check is successful
--	 		 		- Failure If the check is not successful
--				 	- Error   If there is an error in the Check Process
--
-- IN
--    Itemtype - AMS_TRIG
--	  Itemkey  - Trigger ID
--	  Accid    - Activity ID
-- 	  Funmode  - Run/Cancel/Timeout
--
-- OUT
-- 	  Result - 'COMPLETE:SUCCESS' If the check is successful
--	  		 - 'COMPLETE:FAILURE' If the check is Failure
--			 - 'COMPLETE:ERROR' If there is an Error in the check Process
--
-- Used By Activities
-- 	  Item Type - AMS_TRIG
--	  Activity  - AMS_PERFORM_CHECK
--
-- NOTES
--
--
-- HISTORY
--    22-MAR-2001    julou    created
-- End of Comments
PROCEDURE Perform_check(itemtype     IN	  VARCHAR2,
                        itemkey      IN	  VARCHAR2,
                        actid	     IN	  NUMBER,
                        funcmode     IN	  VARCHAR2,
                        result       OUT NOCOPY  VARCHAR2) ;

-- Start of Comments
--
-- NAME
--   Record_Result
--
-- PURPOSE
--   This Procedure will record the the result
-- 	 after the attached schedules are executed
--
-- IN
--    Itemtype - AMS_TRIG
--	  Itemkey  - Trigger ID
--	  Accid    - Activity ID
-- 	  Funmode  - Run/Cancel/Timeout
--
-- OUT
-- 	  Result - 'COMPLETE:'
--
-- Used By Activities
-- 	  Item Type - AMS_TRIG
--	  Activity  - AMS_RECORD_RESULT
--
-- NOTES
--
--
-- HISTORY
--    22-MAR-2001    julou    created
-- End of Comments
PROCEDURE Record_Result(itemtype     IN	  VARCHAR2,
                        itemkey	     IN	  VARCHAR2,
                        actid        IN	  NUMBER,
                        funcmode     IN	  VARCHAR2,
                        result       OUT NOCOPY  VARCHAR2) ;

-- Start of Comments
--
-- NAME
--   Check_Repeat
--
-- PURPOSE
--   This Procedure will return Yes if there the Trigger is repeating
-- 	 or it will return No
--
-- IN
--    Itemtype - AMS_TRIG
--	  Itemkey  - Trigger ID
--	  Accid    - Activity ID
-- 	  Funmode  - Run/Cancel/Timeout
--
-- OUT
-- 	  Result - 'COMPLETE:Y' If the trigger is repeating
-- 			 - 'COMPLETE:N' If the trigger is not repeating
--
-- Used By Activities
-- 	  Item Type - AMS_TRIG
--	  Activity  - AMS_CHECK_REPEAT
--
-- NOTES
--
--
-- HISTORY
--    22-MAR-2001    julou    created
-- End of Comments
PROCEDURE Check_Repeat(itemtype  IN       VARCHAR2,
                       itemkey   IN       VARCHAR2,
                       actid     IN       NUMBER,
                       funcmode	 IN       VARCHAR2,
                       result    OUT NOCOPY      VARCHAR2) ;

-- Start of Comments
--
-- NAME
--   Schedule_Trig_Run
--
-- PURPOSE
--   This Procedure will Calculate the next schedule time for Trigger to fire
--
--   It will Return - Success if the check is successful
--				 	- Error   If there is an error in the Check Process
--
-- IN
--    Itemtype - AMS_TRIG
--	  Itemkey  - Trigger ID
--	  Accid    - Activity ID
-- 	  Funmode  - Run/Cancel/Timeout
--
-- OUT
-- 	  Result - 'COMPLETE:SUCCESS' If the Scheduling is successful
--	  		 - 'COMPLETE:ERROR' If the scheduling is errored out
--
-- Used By Activities
-- 	  Item Type - AMS_TRIG
--	  Activity  - AMS_SCHEDULE_TRIG_RUN
--
-- NOTES
--
--
-- HISTORY
--    22-MAR-2001    julou    created
-- End of Comments
PROCEDURE Schedule_Trig_Run(itemtype     IN   VARCHAR2,
                            itemkey      IN   VARCHAR2,
                            actid        IN   NUMBER,
                            funcmode	 IN   VARCHAR2,
                            result       OUT NOCOPY  VARCHAR2) ;

-- Start of Comments
--
-- NAME
--   Require_Approval
--
-- PURPOSE
--   This Procedure will return Yes if there is an Approval is required for the List
-- 	 or it will return No if there is no Approval is required
--
-- IN
--    Itemtype - AMS_TRIG
--	  Itemkey  - Trigger ID
--	  Accid    - Activity ID
-- 	  Funmode  - Run/Cancel/Timeout
--
-- OUT
-- 	  Result - 'COMPLETE:Y' If the notification is required
--	  			- 'COMPLETE:N' If the notification is not required
--
-- Used By Activities
-- 	  Item Type - AMS_TRIG
--	  Activity  - AMS_REQUIRE_APPROVAL
--
-- NOTES
--
--
-- HISTORY
--    22-MAR-2001    julou    created
-- End of Comments
PROCEDURE Require_Approval(itemtype    IN   VARCHAR2,
                           itemkey     IN   VARCHAR2,
                           actid       IN   NUMBER,
                           funcmode    IN   VARCHAR2,
                           result      OUT NOCOPY  VARCHAR2) ;

-- Start of Comments
--
-- NAME
--   Notify_Chk_Met
--
-- PURPOSE
--   This Procedure will return Yes if Notification is required for the schedule
--	 or No if no Notification required
--
-- IN
--    Itemtype - AMS_TRIG
--	  Itemkey  - Trigger ID
--	  Accid    - Activity ID
-- 	  Funmode  - Run/Cancel/Timeout
--
-- OUT
-- 	  Result - 'COMPLETE:Y' If the notification is required
--	  			- 'COMPLETE:N' If the notification is not required
--
-- Used By Activities
-- 	  Item Type - AMS_TRIG
--	  Activity  - AMS_Notify_Chk_Met
--
-- NOTES
--
--
-- HISTORY
--    22-MAR-2001    julou    created
-- End of Comments
PROCEDURE Notify_Chk_Met (itemtype    IN	  VARCHAR2,
                               itemkey	   IN	  VARCHAR2,
                               actid	   IN	  NUMBER,
                               funcmode	   IN	  VARCHAR2,
                               result      OUT NOCOPY   VARCHAR2) ;

-- Start of Comments
--
-- NAME
--   Execute_Schedule
--
-- PURPOSE
--   This Procedure will execute the schedule. It will return SUCCESS if schedule completes successfully
-- 	 or it will return ERROR if there is any error.
--
-- IN
--    Itemtype - AMS_TRIG
--	  Itemkey  - Trigger ID
--	  Accid    - Activity ID
-- 	  Funmode  - Run/Cancel/Timeout
--
-- OUT
-- 	  Result - 'COMPLETE:SUCCESS' If the schedule is executed successfully
--	  			- 'COMPLETE:ERROR' If the schedule is  executed successfully
--
-- Used By Activities
-- 	  Item Type - AMS_TRIG
--	  Activity  - EXECUTE_SCHEDULE
--
-- NOTES
--
--
-- HISTORY
-- End of Comments
PROCEDURE Execute_Schedule(itemtype    IN   VARCHAR2,
                           itemkey     IN   VARCHAR2,
                           actid       IN   NUMBER,
                           funcmode    IN   VARCHAR2,
                           result      OUT NOCOPY  VARCHAR2) ;
/*
-- Start of Comments
--
-- NAME
--   Check_Active_Sch
--
-- PURPOSE
--   This Procedure will check if there are more active schedules. It will return Yes
--   if more active schedules are found; otherwise it returns No
-- IN
--    Itemtype - AMS_TRIG
--	  Itemkey  - Trigger ID
--	  Accid    - Activity ID
-- 	  Funmode  - Run/Cancel/Timeout
--
-- OUT
-- 	  Result - 'COMPLETE:Y' If the there are more schedules are active
--	  			- 'COMPLETE:N' If the no more active schedule
--
-- Used By Activities
-- 	  Item Type - AMS_TRIG
--	  Activity  - EXECUTE_SCHEDULE
--
-- NOTES
--
--
-- HISTORY
--    22-MAR-2001    julou    created
-- End of Comments
PROCEDURE Check_Active_Sch(itemtype    IN   VARCHAR2,
                           itemkey     IN   VARCHAR2,
                           actid       IN   NUMBER,
                           funcmode    IN   VARCHAR2,
                           result      OUT NOCOPY  VARCHAR2) ;
*/

-- Start of Comments
--
-- NAME
--   Get_User_Role
--
-- PURPOSE
--   This procedure returns the User role for the userid sent.
--
-- IN
--    p_user_id - user's resource id
--
-- OUT
-- 	  x_role_name -- role name for the userid sent
-- 	  x_role_display_name -- displayed name of the role
-- 	  x_return_status -- status for searching the role
--
-- NOTES
-- HISTORY
--    24-APR-2001    julou    created
-- End of Comments
PROCEDURE Get_User_Role(p_user_id            IN     NUMBER,
                        x_role_name          OUT NOCOPY    VARCHAR2,
                        x_role_display_name  OUT NOCOPY    VARCHAR2 ,
                        x_return_status      OUT NOCOPY    VARCHAR2);

-- Start of Comments
--
-- NAME
--   Check_Active_Sch
--
-- PURPOSE
--   This Procedure will get available schedule that attaches to the trigger.
--
-- IN
--    Itemtype - AMS_TRIG
--	  Itemkey  - Trigger ID
--	  Accid    - Activity ID
-- 	  Funmode  - Run/Cancel/Timeout
--
-- OUT
-- 	  Result -- 'COMPLETE:'
--
-- Used By Activities
-- 	  Item Type - AMS_TRIG
--	  Activity  - EXECUTE_SCHEDULE
--
-- NOTES
--
--
-- HISTORY
--    22-MAR-2001    julou    created
-- End of Comments
PROCEDURE Get_Aval_Sch(itemtype    IN   VARCHAR2,
                           itemkey     IN   VARCHAR2,
                           actid       IN   NUMBER,
                           funcmode    IN   VARCHAR2,
                           result      OUT NOCOPY  VARCHAR2) ;

PROCEDURE AbortProcess(p_trigger_id				IN   NUMBER,
            p_itemtype                  IN   VARCHAR2 DEFAULT NULL,
            p_workflow_process          IN   VARCHAR2 DEFAULT NULL  );

-- soagrawa 28-apr-2003 added the following APIs for redesign
PROCEDURE Trig_Type_Date(itemtype    IN   VARCHAR2,
                         itemkey     IN   VARCHAR2,
                         actid       IN   NUMBER,
                         funcmode    IN   VARCHAR2,
                         result      OUT NOCOPY  VARCHAR2) ;

PROCEDURE Action_Notification(itemtype    IN   VARCHAR2,
                         itemkey     IN   VARCHAR2,
                         actid       IN   NUMBER,
                         funcmode    IN   VARCHAR2,
                         result      OUT NOCOPY  VARCHAR2) ;

PROCEDURE Action_Execute(itemtype    IN   VARCHAR2,
                         itemkey     IN   VARCHAR2,
                         actid       IN   NUMBER,
                         funcmode    IN   VARCHAR2,
                         result      OUT NOCOPY  VARCHAR2) ;

PROCEDURE Get_Aval_Repeat_Sch(itemtype    IN   VARCHAR2,
                         itemkey     IN   VARCHAR2,
                         actid       IN   NUMBER,
                         funcmode    IN   VARCHAR2,
                         result      OUT NOCOPY  VARCHAR2) ;

PROCEDURE Event_Custom_action(itemtype    IN   VARCHAR2,
                         itemkey     IN   VARCHAR2,
                         actid       IN   NUMBER,
                         funcmode    IN   VARCHAR2,
                         result      OUT NOCOPY  VARCHAR2) ;

PROCEDURE Event_Trig_Next(itemtype    IN   VARCHAR2,
                         itemkey     IN   VARCHAR2,
                         actid       IN   NUMBER,
                         funcmode    IN   VARCHAR2,
                         result      OUT NOCOPY  VARCHAR2) ;

PROCEDURE Wf_Init_var(itemtype    IN   VARCHAR2,
                         itemkey     IN   VARCHAR2,
                         actid       IN   NUMBER,
                         funcmode    IN   VARCHAR2,
                         result      OUT NOCOPY  VARCHAR2) ;

-- end soagrawa

PROCEDURE Check_Trig_Exist(itemtype    IN   VARCHAR2,
                           itemkey     IN   VARCHAR2,
                           actid       IN   NUMBER,
                           funcmode    IN   VARCHAR2,
                           result      OUT NOCOPY  VARCHAR2) ;


--========================================================================
-- PROCEDURE
--    purge_history
-- Purpose
--    Purges monitor history. Called by Concurrent Program.
-- HISTORY
--    20-Aug-2005   soagrawa    Created.
--
--========================================================================

PROCEDURE purge_history(
                errbuf             OUT NOCOPY    VARCHAR2,
                retcode            OUT NOCOPY    NUMBER,
                trig_end_date_days IN     NUMBER := 60
);

END	AMS_WFTrig_PVT ;

 

/
