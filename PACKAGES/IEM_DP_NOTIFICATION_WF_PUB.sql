--------------------------------------------------------
--  DDL for Package IEM_DP_NOTIFICATION_WF_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_DP_NOTIFICATION_WF_PUB" AUTHID CURRENT_USER as
/* $Header: iempdpns.pls 120.0 2005/07/11 17:00:55 liangxia noship $*/
   G_STAT		varchar2(1):='S';

-- PROCEDURE IEM_STARTPROCESS
--
-- Starts The Workflow Application
--
-- IN
--	Workflowprocess	- Name Of The Process
--   Item_Type  - type of the current item
--   ItemKey Itemkey for the workflow process
-- OUT
--	None
--   result
PROCEDURE 	IEM_START_PROCESS(
     		WorkflowProcess IN VARCHAR2,
     		ItemType in VARCHAR2 ,
			ItemKey in number);

-- PROCEDURE IEM_LAUNCH_WF_DPNTF
--
-- This API will lauch WF to send notification for Download Processor
--
PROCEDURE IEM_LAUNCH_WF_DPNTF
             (p_api_version_number      IN  NUMBER,
              P_init_msg_list           IN  VARCHAR2 := null,
              p_commit                  IN  VARCHAR2 := null,
              x_return_status           OUT NOCOPY VARCHAR2,
              x_msg_count               OUT NOCOPY NUMBER,
              x_msg_data                OUT NOCOPY VARCHAR2);

END IEM_DP_NOTIFICATION_WF_PUB;

 

/
