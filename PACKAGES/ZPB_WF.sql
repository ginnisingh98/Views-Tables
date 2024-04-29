--------------------------------------------------------
--  DDL for Package ZPB_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZPB_WF" AUTHID CURRENT_USER AS
/* $Header: zpbwrkfl.pls 120.0.12010.4 2006/08/03 18:51:03 appldev noship $ */

procedure ACStart(ACID in number, PublishedBefore in varchar2, isEvent in varchar2 default 'N');
--
--
procedure RunNextTask (itemtype in varchar2,
                  itemkey  in varchar2,
                  actid    in number,
                  funcmode in varchar2,
                  resultout   out nocopy varchar2);
--
--
procedure RunLoad (itemtype in varchar2,
                  itemkey  in varchar2,
                  actid    in number,
                  funcmode in varchar2,
              resultout   out nocopy varchar2);
--
--
procedure Selector(itemtype in varchar2,
                         itemkey  in varchar2,
                         actid    in number,
                         command  in varchar2,
                   resultout   out nocopy varchar2);

--
--
procedure WFbkgMgr (errbuf out nocopy varchar2,
                 retcode out nocopy number,
                 itemtype in varchar2,
                 itemkey  in varchar2);

--
--
procedure STARTPRCMGR (errbuf out nocopy varchar2,
                       retcode out nocopy number,
                       TGT_ITEMTYPE in varchar2,
                       TGT_ITEMKEY in varchar2);
--
--
procedure DeleteWorkflow (errbuf out nocopy varchar2,
                                retcode out nocopy varchar2,
                        inACID in Number,
                        ACIDType in varchar2 default 'I');
--
--
Procedure CallDelWF(inACID in number,
        ACIDType in varchar2 default 'I');

--
--
procedure MakeInstance (errbuf out nocopy varchar2,
                        retcode out nocopy varchar2,
                        ItemKey in varchar2,
                        ACID in Number,
                        P_BUSINESS_AREA_ID in Number);
--
--
procedure MarkforDelete (ACID in Number,
      ownerID in number,
      respID in number,
      RespAppID in number);

--
--
procedure FrequencyInit (itemtype in varchar2,
                  itemkey  in varchar2,
                  actid    in number,
                  funcmode in varchar2,
                  resultout   out nocopy varchar2);
--
--
procedure FrequencyMgr (itemtype in varchar2,
                  itemkey  in varchar2,
                  actid    in number,
                  funcmode in varchar2,
                  resultout   out nocopy varchar2);
--
--
procedure  SetCompDate (itemtype in varchar2,
                  itemkey  in varchar2,
                  actid    in number,
                  funcmode in varchar2,
              resultout   out nocopy varchar2);

procedure PAUSE_INSTANCE (InstanceID in number);
--
-- A. BUDNIK 07/17/2003 Added PResumeType
procedure RESUME_INSTANCE (InstanceID in number,
                   PResumeType varchar2 default 'NORMAL');
--
--
-- abudnik 17NOV2005 BUSINESS AREA ID.
procedure Concurrent_Wrapper (errbuf out nocopy varchar2,
                        retcode out nocopy varchar2,
                        ACID in Number,
                        TaskID in Number,
                        DataAW in Varchar2,
                        CodeAW in Varchar2,
                        AnnoAW in Varchar2,
                        P_BUSINESS_AREA_ID in Number);
--
--
procedure  SET_CURRINST (itemtype in varchar2,
                  itemkey  in varchar2,
                  actid    in number,
                  funcmode in varchar2,
                  resultout   out nocopy varchar2);
--
--
function GetEventACID(taskID in number) return varchar2;
--
--
procedure PREP_EVENT_ACID (itemtype in varchar2,
                  itemkey  in varchar2,
                  actid    in number,
                  funcmode in varchar2,
                  resultout   out nocopy varchar2);
--
--
procedure ENABLE_CYCLE(Pacid in number, PStatus in varchar2);
--
--
procedure INIT_BUSINESS_PROCESS (ACID in Number,
          InstanceID in Number,
          TaskID in Number,
          UserID in Number);
--
--
-- abudnik 17NOV2005 BUSINESS AREA ID
procedure RUN_SOLVE (errbuf out nocopy varchar2,
                     retcode out nocopy varchar2,
                     InstanceID in Number,
                     TaskID in Number,
                     UserID in Number,
                     P_BUSINESS_AREA_ID in number);
--
--
procedure UPDATE_STATUS (p_type in varchar2,
                        p_InstanceID in Number default NULL,
                        p_TaskID in Number default NULL,
                        p_UserID in Number default NULL);

--
-- Kicks off a CM to submit data up to the shared
--
procedure SUBMIT_TO_SHARED (p_user       in number,
                            p_templateID in number,
                            p_retVal     out nocopy number);


procedure INIT_PROC_RUN_DATA  (ACID in Number,
                        InstanceID in Number,
                        TaskID in Number,
                        UserID in Number);
--
-- runs cm.delshints to remove AW instances.
--
-- abudnik 17NOV2005 BUSINESS AREA ID
procedure WF_DELAWINST (errbuf out nocopy varchar2,
                        retcode out nocopy varchar2,
                        InstanceID in Number,
                        UserID in Number,
                        P_BUSINESS_AREA_ID in Number);
--
-- calls abprtWorkflow
--
Procedure CallWFAbort(inACID in number);

--
-- aborts WF scheduler for ACID Can be updated to abort others
--

procedure AbortWorkflow (errbuf out nocopy varchar2,
                         retcode out nocopy varchar2,
                        inACID in Number,
                        ACIDType in varchar2 default 'A');

--
-- If BP has no active instances and no completed instances, deletes CurrentInstance measure from AW
-- If BP has no active instances and some completed instances, resets CurrentInstance measure to last started instance
-- If BP has active instances does nothing
--
procedure DeleteCurrInstMeas (ACId  in number,
                  ownerId in number);

-- This procedure is called by a CM program.  For instance P_InstanceId of BP P_ACId
-- it first deletes the AW measure associted with the instance, it then recreates and
-- initializes the AW measure.  Used when enabling BPs ENABLE_FIRST

-- abudnik 17NOV2005 BUSINESS AREA ID
procedure CleanAndRestartInst (errbuf out nocopy varchar2,
                               retcode out nocopy varchar2,
                               P_ACId  in number,
                               P_InstanceId in number,
                               P_BUSINESS_AREA_ID in number);

procedure RUN_MIGRATE_INST (p_InstanceID        in  NUMBER,
                            p_api_version       IN  NUMBER,
                            p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
                            p_commit            IN  VARCHAR2 := FND_API.G_TRUE,
                            p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                            x_return_status     OUT nocopy varchar2,
                            x_msg_count         OUT nocopy number,
                            x_msg_data          OUT nocopy varchar2);

procedure REVIEW_NOTIF_RESPONSE(itemtype in varchar2,
                  itemkey  in varchar2,
                  actid    in number,
                  funcmode in varchar2,
                  resultout   out NOCOPY varchar2);


-- A. Budnik 04/26/2006 b 3126256
procedure SUBMIT_CONC_REQUEST (itemtype in varchar2,
                  itemkey  in varchar2,
                  actid    in number,
                  funcmode in varchar2,
                  resultout   out nocopy varchar2);

end ZPB_WF;

 

/
