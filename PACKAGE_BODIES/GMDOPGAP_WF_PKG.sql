--------------------------------------------------------
--  DDL for Package Body GMDOPGAP_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMDOPGAP_WF_PKG" AS
/* $Header: GMDOPGAB.pls 120.0 2005/05/25 19:53:45 appldev noship $ */
   PROCEDURE wf_init (
      p_operation_id         IN   GMD_OPERATIONS_B.oprn_id%TYPE,
      p_operation_no         IN   GMD_OPERATIONS_B.oprn_no%TYPE,
      p_operation_vers       IN   GMD_OPERATIONS_B.oprn_vers%TYPE,
      p_start_status      IN   GMD_OPERATIONS_B.operation_status%TYPE,
      p_target_status     IN   GMD_OPERATIONS_B.operation_status%TYPE,
      p_requester         IN   GMD_OPERATIONS_B.LAST_UPDATED_BY%TYPE,
      p_last_update_date  IN   GMD_OPERATIONS_B.LAST_UPDATE_DATE%TYPE
                )
   IS
      /* procedure to initialize and run Workflow */

      l_itemtype                WF_ITEMS.ITEM_TYPE%TYPE :=  'GMDOPGAP';
      l_itemkey                 WF_ITEMS.ITEM_KEY%TYPE  :=  to_char(p_operation_id)||'-'||to_char(p_last_update_date,'dd-MON-yyyy   HH24:mi:ss');
      l_runform                 VARCHAR2(100);
      l_performer_name          FND_USER.USER_NAME%TYPE ;
      l_performer_display_name  FND_USER.DESCRIPTION%TYPE ;

      /* Mercy Thomas Bug 3173515 Added the following variables for the NPD workflow changes */
      l_oprn_desc               GMD_OPERATIONS.OPRN_DESC%TYPE;
      l_oprn_class              GMD_OPERATIONS.OPRN_CLASS%TYPE;
      l_item_um                 GMD_OPERATIONS.PROCESS_QTY_UOM%TYPE;
      l_effective_start_date    GMD_OPERATIONS.EFFECTIVE_START_DATE%TYPE;
      l_effective_end_date      GMD_OPERATIONS.EFFECTIVE_END_DATE%TYPE;
      /* Mercy Thomas Bug 3173515 End of the changes */

      /* make sure that process runs with background engine
       to prevent SAVEPOINT/ROLLBACK error (see Workflow FAQ)
       the value to use for this is -1 */

      l_run_wf_in_background CONSTANT WF_ENGINE.THRESHOLD%TYPE := -1;
      l_wf_timeout     NUMBER := TO_NUMBER(FND_PROFILE.VALUE ('GMD_WF_TIMEOUT'));


      l_WorkflowProcess   VARCHAR2(30) := 'GMDOPGAP_PROCESS';
      l_count             NUMBER;
      BEGIN

      	/* create the process */
      	WF_ENGINE.CREATEPROCESS (itemtype => l_itemtype, itemkey => l_itemkey, process => l_WorkflowProcess) ;

      	/* make sure that process runs with background engine */
      	WF_ENGINE.THRESHOLD := l_run_wf_in_background ;

      	/* set the item attributes */
      	WF_ENGINE.SETITEMATTRNUMBER(itemtype => l_itemtype,itemkey => l_itemkey,
         				  	       aname => 'GMDOPGAP_OPERATION_ID',
         	                               avalue => p_operation_id);

      	WF_ENGINE.SETITEMATTRNUMBER(itemtype => l_itemtype,itemkey => l_itemkey,
         				  	       aname => 'GMDOPGAP_START_STATUS',
         	                               avalue => p_start_status);

      	WF_ENGINE.SETITEMATTRNUMBER(itemtype => l_itemtype,itemkey => l_itemkey,
         				  	       aname => 'GMDOPGAP_TARGET_STATUS',
         	                               avalue => p_target_status);

      	WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         					  aname => 'GMDOPGAP_OPERATION_NO',
         					  avalue => p_operation_no);

      	WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         					  aname => 'GMDOPGAP_OPERATION_VERS',
         					  avalue => p_operation_vers);

            l_wf_timeout := (l_wf_timeout * 24 * 60) / 4 ;  -- Converting days into minutes

      	WF_ENGINE.SETITEMATTRNUMBER(itemtype => l_itemtype,itemkey => l_itemkey,
         				  	       aname => 'GMDOPGAP_TIMEOUT',
         	                               avalue => l_wf_timeout);
      	WF_ENGINE.SETITEMATTRNUMBER(itemtype => l_itemtype,itemkey => l_itemkey,
         				  	       aname => 'GMDOPGAP_MESG_CNT',
         	                               avalue => 1);

            l_runform := 'GMDOPRED_F:OPRN_ID='||to_char(p_operation_id);

      	WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         					  aname => 'GMDOPGAP_FORM',
         					  avalue => l_runform);

      -- get values to be stored into the workflow item
      SELECT USER_NAME , DESCRIPTION
      INTO   l_performer_name ,l_performer_display_name
      FROM   FND_USER
      WHERE  USER_ID = p_Requester;

      	WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         					  aname => 'GMDOPGAP_REQUSTER',
         					  avalue => l_performer_name );

      /* Mercy Thomas Bug 3173515 Added the following variables for the NPD workflow changes */
      SELECT OPRN_DESC, OPRN_CLASS, PROCESS_QTY_UOM, EFFECTIVE_START_DATE, EFFECTIVE_END_DATE
      INTO l_oprn_desc, l_oprn_class, l_item_um, l_effective_start_date, l_effective_end_date
      FROM GMD_OPERATIONS
      WHERE OPRN_ID = P_OPERATION_ID;

      WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         					  aname => 'GMDOPGAP_OPRN_DESC',
         					  avalue => l_oprn_desc);

      WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         					  aname => 'GMDOPGAP_OPRN_CLASS',
         					  avalue => l_oprn_class);

      WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         					  aname => 'GMDOPGAP_OPRN_UOM',
         					  avalue => l_item_um);

      WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         					  aname => 'GMDOPGAP_EFF_START_DATE',
         					  avalue => l_effective_start_date);

      WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         					  aname => 'GMDOPGAP_EFF_END_DATE',
         					  avalue => l_effective_end_date);

      /* Mercy Thomas Bug 3173515 End of the changes */


     	  /* start the Workflow process */

      	WF_ENGINE.STARTPROCESS (itemtype => l_itemtype,itemkey => l_itemkey);



  EXCEPTION
      WHEN OTHERS THEN
      WF_CORE.CONTEXT ('GMDOPGAP_wf_pkg','wf_init',l_itemtype,l_itemkey,'Initial' );
      raise;

  END wf_init;





/* ######################################################################## */

   PROCEDURE is_approval_req
      (p_itemtype      IN VARCHAR2,
      p_itemkey       IN VARCHAR2,
      p_actid         IN NUMBER,
      p_funcmode      IN VARCHAR2,
      p_resultout     OUT NOCOPY VARCHAR2
   )
   IS
      /* procedure to Check Approval is required or not if required find the approver and send the notification to
         approver */

      l_operation_id      GMD_OPERATIONS_B.oprn_id%TYPE:=to_number(wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDOPGAP_OPERATION_ID'));
      p_data_string       VARCHAR2(2000);
      p_wf_data_string    VARCHAR2(2000);
      p_lab_wf_item_type  VARCHAR2(8)  := 'GMDOPGAP';  -- Recipe Lab use Approval Workflow Inernal Name
      P_lab_Process_name  VARCHAR2(32) := 'GMDOPGAP_PROCESS'; -- Recipe Lab use Approval Workflow Process Inernal Name
      P_lab_activity_name VARCHAR2(80) := 'GMDOPGAP_NOTI_REQUEST';
      P_table_name        VARCHAR2(32) := 'GMD_OPERATIONS_B'; -- Key Table
      P_where_clause      VARCHAR2(100):= ' GMD_OPERATIONS_B.OPRN_ID='||l_OPERATION_ID; -- Where clause to be appended
      p_role              GMA_ACTDATA_WF.ROLE%TYPE;
      l_data_string       VARCHAR2(2000);
      l_delimiter         VARCHAR2(15) := FND_PROFILE.VALUE ('SY$WF_DELIMITER');
      l_target_status     GMD_STATUS_NEXT.TARGET_STATUS%TYPE;
    BEGIN

     IF (p_funcmode = 'RUN') THEN
          gma_wfstd_p.WF_GET_CONTORL_PARAMS(P_LAB_WF_ITEM_TYPE,
                                         P_LAB_PROCESS_NAME,
                                         P_LAB_ACTIVITY_NAME,
                                         P_TABLE_NAME,
                                         P_WHERE_CLAUSE,
                                         P_DATA_STRING,
                                         p_wf_data_string);
         IF gma_wfstd_p.check_activity_approval_req(p_lab_wf_item_type,
                                            p_lab_process_name,
                                            p_lab_activity_name,
                                            p_data_string)  = 'Y'
         THEN
            gma_wfstd_p.get_role (p_lab_wf_item_type,
                                  p_lab_process_name,
                                  p_lab_activity_name,
                                  p_data_string,
                                  P_role);
            l_data_string := replace(p_wf_data_string,l_delimiter,wf_core.newline);
	      WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
      			              itemkey => p_itemkey,
         					  aname => 'GMDOPGAP_ADDL_TEXT',
                                      avalue => l_data_string);

	      WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
      			              itemkey => p_itemkey,
         					  aname => 'GMDOPGAP_APPROVER',
                                      avalue => p_role);

            p_resultout:='COMPLETE:Y';
        ELSE
          l_target_status := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDOPGAP_TARGET_STATUS');
          UPDATE GMD_OPERATIONS_B
          SET OPERATION_STATUS  = l_target_status
          WHERE OPRN_ID    = l_operation_id;
          p_resultout:='COMPLETE:N';
        END IF;
     END IF;
EXCEPTION
      WHEN OTHERS THEN
      WF_CORE.CONTEXT ('GMDOPGAP_wf_pkg','is_approval_req',p_itemtype,p_itemkey,p_role);
      raise;
END is_approval_req;

PROCEDURE REMINDAR_CHECK (
      p_itemtype      IN VARCHAR2,
      p_itemkey       IN VARCHAR2,
      p_actid         IN NUMBER,
      p_funcmode      IN VARCHAR2,
      p_resultout     OUT NOCOPY VARCHAR2) IS
      l_mesg_cnt      number:=wf_engine.getitemattrnumber(p_itemtype, p_itemkey,'GMDOPGAP_MESG_CNT');
      l_approver      VARCHAR2(80) := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDOPGAP_APPROVER');
BEGIN
       IF (p_funcmode = 'TIMEOUT') THEN
         l_mesg_cnt  := l_mesg_cnt + 1;
         IF l_mesg_cnt <= 4 THEN
            WF_ENGINE.SETITEMATTRNUMBER(itemtype => p_itemtype,itemkey => p_itemkey,
         	  	       aname => 'GMDOPGAP_MESG_CNT',
                         avalue => l_mesg_cnt);
         ELSE
            p_resultout := 'COMPLETE:DEFAULT';
         END IF;
       ELSIF (p_funcmode = 'RESPOND') THEN
          WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
                                   itemkey => p_itemkey,
         			           aname => 'GMDOPGAP_CURR_PERFORMER',
                                   avalue => l_approver);
       END IF;
END;

PROCEDURE REQ_APPROVED (
      p_itemtype      IN VARCHAR2,
      p_itemkey       IN VARCHAR2,
      p_actid         IN NUMBER,
      p_funcmode      IN VARCHAR2,
      p_resultout     OUT NOCOPY VARCHAR2) IS
  l_target_status     GMD_STATUS_NEXT.TARGET_STATUS%TYPE;
  l_operation_id      GMD_OPERATIONS_B.oprn_id%TYPE:=to_number(wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDOPGAP_OPERATION_ID'));
BEGIN
     IF (p_funcmode = 'RUN') THEN
          l_target_status := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDOPGAP_TARGET_STATUS');
          UPDATE GMD_OPERATIONS_B
          SET OPERATION_STATUS  = l_target_status
          WHERE OPRN_ID    = l_operation_id;
     END IF;

END REQ_APPROVED;

PROCEDURE REQ_REJECTED (
      p_itemtype      IN VARCHAR2,
      p_itemkey       IN VARCHAR2,
      p_actid         IN NUMBER,
      p_funcmode      IN VARCHAR2,
      p_resultout     OUT NOCOPY VARCHAR2) IS
  l_rework_status     GMD_STATUS_NEXT.TARGET_STATUS%TYPE;
  l_target_status     GMD_STATUS_NEXT.TARGET_STATUS%TYPE;
  l_start_status      GMD_STATUS_NEXT.TARGET_STATUS%TYPE;
  l_operation_id      GMD_OPERATIONS_B.oprn_id%TYPE:=to_number(wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDOPGAP_OPERATION_ID'));
BEGIN
     IF (p_funcmode = 'RUN') THEN
          l_start_status := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDOPGAP_START_STATUS');
          l_target_status := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDOPGAP_TARGET_STATUS');
          SELECT rework_status into l_rework_status
          FROM GMD_STATUS_NEXT
          WHERE current_status = l_start_status
            AND target_status  = l_target_status
            AND pending_status IS NOT NULL;
          UPDATE GMD_OPERATIONS_B
          SET OPERATION_STATUS  = l_rework_status
          WHERE OPRN_ID    = l_operation_id;
     END IF;
END REQ_REJECTED;

PROCEDURE NO_RESPONSE (
      p_itemtype      IN VARCHAR2,
      p_itemkey       IN VARCHAR2,
      p_actid         IN NUMBER,
      p_funcmode      IN VARCHAR2,
      p_resultout     OUT NOCOPY VARCHAR2) IS
  l_operation_id      GMD_OPERATIONS_B.oprn_id%TYPE:=to_number(wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDOPGAP_OPERATION_ID'));
  l_start_status      GMD_STATUS_NEXT.TARGET_STATUS%TYPE;
BEGIN
     IF (p_funcmode = 'RUN') THEN
          l_start_status := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDOPGAP_START_STATUS');
          UPDATE GMD_OPERATIONS_B
          SET OPERATION_STATUS  = l_start_status
          WHERE OPRN_ID    = l_operation_id;
     END IF;
END NO_RESPONSE;

PROCEDURE MOREINFO_RESPONSE  (
      p_itemtype      IN VARCHAR2,
      p_itemkey       IN VARCHAR2,
      p_actid         IN NUMBER,
      p_funcmode      IN VARCHAR2,
      p_resultout     OUT NOCOPY VARCHAR2) IS
      l_requester     VARCHAR2(80) := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDOPGAP_REQUSTER');
BEGIN
       IF (p_funcmode = 'RESPOND') THEN
          WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
                                   itemkey => p_itemkey,
         			           aname => 'GMDOPGAP_CURR_PERFORMER',
                                   avalue => l_requester);
       END IF;
END;

PROCEDURE APPEND_COMMENTS (
      p_itemtype      IN VARCHAR2,
      p_itemkey       IN VARCHAR2,
      p_actid         IN NUMBER,
      p_funcmode      IN VARCHAR2,
      p_resultout     OUT NOCOPY VARCHAR2) IS
      l_html_mesg     VARCHAR2(4000);
      l_comment       VARCHAR2(4000):=wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDOPGAP_COMMENT');
      l_mesg_comment  VARCHAR2(4000):=wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDOPGAP_DISP_COMMENT');
      l_performer      VARCHAR2(80) := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDOPGAP_CURR_PERFORMER');
BEGIN
     IF (p_funcmode = 'RUN' AND l_comment IS NOT NULL) THEN
         BEGIN
           l_mesg_comment := l_mesg_comment||wf_core.newline||l_performer||' : '||FND_DATE.DATE_TO_CHARDT(SYSDATE)||
                             wf_core.newline||l_comment;
--           l_html_mesg := replace(l_mesg_comment,wf_core.newline,'<BR>'||wf_core.newline);
           l_comment := null;
         EXCEPTION WHEN OTHERS THEN
           NULL;
         END;
	   WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
                                   itemkey => p_itemkey,
         			           aname => 'GMDOPGAP_DISP_COMMENT',
                                   avalue => l_mesg_comment);
--	   WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
--                                   itemkey => p_itemkey,
--         			           aname => 'GMDOPGAP_HTML_DISP_COMMENT',
--                                   avalue => l_html_mesg);
	   WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
                                   itemkey => p_itemkey,
         			           aname => 'GMDOPGAP_COMMENT',
                                   avalue => l_comment);
       END IF;
END;


END GMDOPGAP_wf_pkg;

/
