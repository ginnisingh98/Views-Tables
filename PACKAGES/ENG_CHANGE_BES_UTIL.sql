--------------------------------------------------------
--  DDL for Package ENG_CHANGE_BES_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_CHANGE_BES_UTIL" AUTHID CURRENT_USER AS
/* $Header: ENGUBESS.pls 120.4 2006/01/31 19:06:50 mkimizuk noship $ */

  -- Internal constants for business event and event group names
  -- (used only for update_bug event group)
  G_CMBE_HEADER_CREATE            CONSTANT VARCHAR2(240)  := 'oracle.apps.eng.cm.changeObject.create';
  G_CMBE_HEADER_SUBMIT            CONSTANT VARCHAR2(240)  := 'oracle.apps.eng.cm.changeObject.submit';
  G_CMBE_HEADER_UPDATE            CONSTANT VARCHAR2(240)  := 'oracle.apps.eng.cm.changeObject.update';
  G_CMBE_HEADER_CHG_STATUS        CONSTANT VARCHAR2(240)  := 'oracle.apps.eng.cm.changeObject.changeStatus';
  G_CMBE_HEADER_CHG_PRIORITY      CONSTANT VARCHAR2(240)  := 'oracle.apps.eng.cm.changeObject.changePriority';
  G_CMBE_HEADER_REASSIGN          CONSTANT VARCHAR2(240)  := 'oracle.apps.eng.cm.changeObject.reassign';
  G_CMBE_HEADER_POST_COMMENT      CONSTANT VARCHAR2(240)  := 'oracle.apps.eng.cm.changeObject.postComment';
  G_CMBE_HEADER_REQ_COMMENT       CONSTANT VARCHAR2(240)  := 'oracle.apps.eng.cm.changeObject.requestComment';
  G_CMBE_HEADER_CHG_WF_STATUS     CONSTANT VARCHAR2(240)  := 'oracle.apps.eng.cm.changeObject.changeWorkflowStatus';
  G_CMBE_HEADER_CHG_APPR_STATUS   CONSTANT VARCHAR2(240)  := 'oracle.apps.eng.cm.changeObject.changeApprovalStatus';

  -- (not used, for debugging only)
  G_CMBE_CO_CHG_SCHED_DATE        CONSTANT VARCHAR2(240)  := 'oracle.apps.eng.cm.changeOrder.changeScheduleDate';
  G_CMBE_REVITEM_CHG_SCHED_DATE   CONSTANT VARCHAR2(240)  := 'oracle.apps.eng.cm.revisedItem.changeScheduleDate';
  G_CMBE_REVITEM_CHG_STATUS       CONSTANT VARCHAR2(240)  := 'oracle.apps.eng.cm.revisedItem.changeStatus';

  G_CMBE_IMPORT_COMPLETE          CONSTANT VARCHAR2(240)  := 'oracle.apps.eng.cm.import.complete';

  -- Business Event related - constants for parameter names
  G_BES_PARAM_CHANGE_ID           CONSTANT VARCHAR2(30)   := 'ChangeId';
  G_BES_PARAM_BASE_CM_TYPE_CODE   CONSTANT VARCHAR2(30)   := 'BaseCMTypeCode';
  G_BES_PARAM_ACT_TYPE_CODE       CONSTANT VARCHAR2(30)   := 'ActionTypeCode';
  G_BES_PARAM_ACTION_ID           CONSTANT VARCHAR2(30)   := 'ActionId';
  G_BES_PARAM_STATUS_CODE         CONSTANT VARCHAR2(30)   := 'StatusCode';
  G_BES_PARAM_PRIORITY_CODE       CONSTANT VARCHAR2(30)   := 'PriorityCode';
  G_BES_PARAM_ASSIGNEE_ID         CONSTANT VARCHAR2(30)   := 'AssigneeId';
  G_BES_PARAM_NEW_APPR_STS_CODE   CONSTANT VARCHAR2(30)   := 'NewApprovalStatusCode';
  G_BES_PARAM_WF_STATUS_CODE      CONSTANT VARCHAR2(30)   := 'WorkflowRouteStatus';
  G_BES_PARAM_SCHEDULE_DATE       CONSTANT VARCHAR2(30)   := 'ScheduleDate';
  G_BES_PARAM_REV_ITEM_SEQ_ID     CONSTANT VARCHAR2(30)   := 'RevisedItemSequenceId';
  G_BES_PARAM_BATCH_ID            CONSTANT VARCHAR2(30)   := 'BatchId';
  G_BES_PARAM_COMP_STATUS         CONSTANT VARCHAR2(30)   := 'CompletionStatus';


  PROCEDURE Raise_Status_Change_Event
  ( p_change_id                 IN   NUMBER
   ,p_status_code               IN   NUMBER
   ,p_action_type               IN   VARCHAR2
   ,p_action_id                 IN   NUMBER
  ) ;


  PROCEDURE Raise_Appr_Status_Change_Event
  ( p_change_id                 IN   NUMBER
   ,p_appr_status               IN   NUMBER
   ,p_wf_route_status              IN   VARCHAR2
  ) ;

  PROCEDURE Raise_Post_Comment_Event
  ( p_change_id                 IN   NUMBER
   ,p_action_type               IN   VARCHAR2
   ,p_action_id                 IN   NUMBER
  ) ;

  PROCEDURE Raise_Create_Change_Event
  ( p_change_id                 IN   NUMBER
  ) ;

  PROCEDURE Raise_Update_Change_Event
  ( p_change_id                 IN   NUMBER
  ) ;




END ENG_CHANGE_BES_UTIL;


 

/
