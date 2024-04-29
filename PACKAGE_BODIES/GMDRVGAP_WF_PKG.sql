--------------------------------------------------------
--  DDL for Package Body GMDRVGAP_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMDRVGAP_WF_PKG" AS
/* $Header: GMDRVGAB.pls 120.1 2006/06/06 06:23:55 kmotupal noship $ */
   PROCEDURE wf_init (
      p_recipe_validity_rule_id         IN   GMD_RECIPE_VALIDITY_RULES.recipe_validity_rule_id%TYPE,
      p_recipe_id                       IN   GMD_RECIPE_VALIDITY_RULES.recipe_id%TYPE,
      p_start_status                    IN   GMD_RECIPE_VALIDITY_RULES.validity_rule_status%TYPE,
      p_target_status                   IN   GMD_RECIPE_VALIDITY_RULES.validity_rule_status%TYPE,
      p_requester                       IN   GMD_RECIPE_VALIDITY_RULES.LAST_UPDATED_BY%TYPE,
      p_last_update_date                IN   GMD_RECIPE_VALIDITY_RULES.LAST_UPDATE_DATE%TYPE
                )
   IS
      /* procedure to initialize and run Workflow */

      l_itemtype                WF_ITEMS.ITEM_TYPE%TYPE :=  'GMDRVGAP';
      l_itemkey                 WF_ITEMS.ITEM_KEY%TYPE  :=  to_char(p_recipe_validity_rule_id)||'-'||
                                                            to_char(p_last_update_date,'dd-MON-yyyy   HH24:mi:ss');
      l_runform                 VARCHAR2(100);
      l_performer_name          FND_USER.USER_NAME%TYPE ;
      l_performer_display_name  FND_USER.DESCRIPTION%TYPE ;
      l_recipe_no               GMD_RECIPES.RECIPE_NO%TYPE;
      l_recipe_vers             GMD_RECIPES.RECIPE_VERSION%TYPE;
      /* Mercy Thomas Bug 3173515 Added the following variables for the NPD workflow changes */
      l_recipe_use              VARCHAR2(80);
      --Krishna  NPD-Conv, Created l_orgn_id, l_item_id. Modified l_orgn_code, l_item_no.
      l_orgn_id    GMD_RECIPE_VALIDITY_RULES.organization_id%TYPE;
      l_orgn_code  ORG_ORGANIZATION_DEFINITIONS.organization_code%TYPE;
      l_item_id    GMD_RECIPE_VALIDITY_RULES.INVENTORY_ITEM_ID%TYPE;
      l_item_no    MTL_SYSTEM_ITEMS_KFV.concatenated_segments%TYPE;
      l_preference              GMD_RECIPE_VALIDITY_RULES.PREFERENCE%TYPE;
      l_std_qty                 VARCHAR2(80);
      l_min_qty                 VARCHAR2(80);
      l_max_qty                 VARCHAR2(80);
      l_effective_start_date    GMD_RECIPE_VALIDITY_RULES.START_DATE%TYPE;
      l_effective_end_date    GMD_RECIPE_VALIDITY_RULES.END_DATE%TYPE;
      /* Mercy Thomas Bug 3173515 End of the changes */

      /* make sure that process runs with background engine
       to prevent SAVEPOINT/ROLLBACK error (see Workflow FAQ)
       the value to use for this is -1 */

      l_run_wf_in_background CONSTANT WF_ENGINE.THRESHOLD%TYPE := -1;
      l_wf_timeout     NUMBER := TO_NUMBER(FND_PROFILE.VALUE ('GMD_WF_TIMEOUT'));

      l_WorkflowProcess   VARCHAR2(30) := 'GMDRVGAP_PROCESS';
      l_count             NUMBER;
      BEGIN

      	/* create the process */
      	WF_ENGINE.CREATEPROCESS (itemtype => l_itemtype, itemkey => l_itemkey, process => l_WorkflowProcess) ;

      	/* make sure that process runs with background engine */
      	WF_ENGINE.THRESHOLD := l_run_wf_in_background ;

      	/* set the item attributes */
      	WF_ENGINE.SETITEMATTRNUMBER(itemtype => l_itemtype,itemkey => l_itemkey,
         				  	       aname => 'GMDRVGAP_RECIPE_ID',
         	                               avalue => p_recipe_id);
      	WF_ENGINE.SETITEMATTRNUMBER(itemtype => l_itemtype,itemkey => l_itemkey,
         				  	       aname => 'GMDRVGAP_RECIPE_VALIDITYRULEID',
         	                               avalue => p_recipe_validity_rule_id);

      	WF_ENGINE.SETITEMATTRNUMBER(itemtype => l_itemtype,itemkey => l_itemkey,
         				  	       aname => 'GMDRVGAP_START_STATUS',
         	                               avalue => p_start_status);

      	WF_ENGINE.SETITEMATTRNUMBER(itemtype => l_itemtype,itemkey => l_itemkey,
         				  	       aname => 'GMDRVGAP_TARGET_STATUS',
         	                               avalue => p_target_status);

            SELECT RECIPE_NO,RECIPE_VERSION INTO l_recipe_no,l_recipe_vers
            FROM GMD_RECIPES_B
            WHERE RECIPE_ID = P_RECIPE_ID;
      	WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         					  aname => 'GMDRVGAP_RECIPE_NO',
         					  avalue => l_recipe_no);

      	WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         					  aname => 'GMDRVGAP_RECIPE_VERS',
         					  avalue => l_recipe_vers);
            l_wf_timeout := (l_wf_timeout * 24 * 60) / 4 ;  -- Converting days into minutes

      	WF_ENGINE.SETITEMATTRNUMBER(itemtype => l_itemtype,itemkey => l_itemkey,
         				  	       aname => 'GMDRVGAP_TIMEOUT',
         	                               avalue => l_wf_timeout);
      	WF_ENGINE.SETITEMATTRNUMBER(itemtype => l_itemtype,itemkey => l_itemkey,
         				  	       aname => 'GMDRVGAP_MESG_CNT',
         	                               avalue => 1);

            l_runform := 'GMDRVRED_F:RECIPE_VALIDITY_RULE_ID='||to_char(p_recipe_validity_rule_id);

      	WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         					  aname => 'GMDRVGAP_FORM',
         					  avalue => l_runform);

      -- get values to be stored into the workflow item
      SELECT USER_NAME , DESCRIPTION
      INTO   l_performer_name ,l_performer_display_name
      FROM   FND_USER
      WHERE  USER_ID = p_Requester;

      	WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         					  aname => 'GMDRVGAP_REQUSTER',
         					  avalue => l_performer_name );

         /* Mercy Thomas Bug 3173515 Added the following variables for the NPD workflow changes */
         /* Krishna, Modified Query as per NPD-Convergence plan                                 */
         SELECT A.ORGANIZATION_ID,
                DECODE(A.RECIPE_USE, 0, 'Production', 1, 'Planning', 2, 'Costing', 3, 'Regulatory', 4, 'Technical'),
                B.CONCATENATED_SEGMENTS,  A.PREFERENCE, A.STD_QTY || ' ' || A.DETAIL_UOM, A.MIN_QTY || ' ' || A.DETAIL_UOM, A.MAX_QTY || ' ' || A.DETAIL_UOM, A.START_DATE, A.END_DATE
         INTO   l_orgn_id, l_recipe_use, l_item_no, l_preference, l_std_qty, l_min_qty, l_max_qty, l_effective_start_date, l_effective_end_date
         FROM GMD_RECIPE_VALIDITY_RULES A,  MTL_SYSTEM_ITEMS_KFV B
         WHERE A.RECIPE_VALIDITY_RULE_ID = P_RECIPE_VALIDITY_RULE_ID
         AND   A.INVENTORY_ITEM_ID       = B.INVENTORY_ITEM_ID
	 AND   A.organization_id         = B.organization_id;

	 /* fetch Organization Code */
	 IF l_orgn_id is NOT NULL then
	         GMD_ERES_UTILS.GET_ORGANIZATION_CODE(l_orgn_id, l_orgn_code);
	 END IF;

       	 WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         					  aname => 'GMDRVGAP_ORGN_CODE',
         					  avalue => l_orgn_code);

      	 WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         					  aname => 'GMDRVGAP_RECIPE_USE',
         					  avalue => l_recipe_use);

      	 WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         					  aname => 'GMDRVGAP_ITEM_NO',
         					  avalue => l_item_no);

      	 WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         					  aname => 'GMDRVGAP_PREFERENCE',
         					  avalue => l_preference);

      	 WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         					  aname => 'GMDRVGAP_STD_QTY',
         					  avalue => l_std_qty);

      	 WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         					  aname => 'GMDRVGAP_MIN_QTY',
         					  avalue => l_min_qty);

      	 WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         					  aname => 'GMDRVGAP_MAX_QTY',
         					  avalue => l_max_qty);

      	 WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         					  aname => 'GMDRVGAP_EFF_START_DATE',
         					  avalue => l_effective_start_date);

      	 WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         					  aname => 'GMDRVGAP_EFF_END_DATE',
         					  avalue => l_effective_end_date);

         /* Mercy Thomas Bug 3173515 End of the changes */

     	  /* start the Workflow process */

      	WF_ENGINE.STARTPROCESS (itemtype => l_itemtype,itemkey => l_itemkey);



  EXCEPTION
      WHEN OTHERS THEN
      WF_CORE.CONTEXT ('GMDRVGAP_wf_pkg','wf_init',l_itemtype,l_itemkey,'Initial' );
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

      l_recipe_validity_rule_id  GMD_RECIPE_VALIDITY_RULES.recipe_validity_rule_id%TYPE;
      p_data_string       VARCHAR2(2000);
      p_wf_data_string    VARCHAR2(2000);
      p_lab_wf_item_type  VARCHAR2(8)  := 'GMDRVGAP';  -- Recipe Lab use Approval Workflow Inernal Name
      P_lab_Process_name  VARCHAR2(32) := 'GMDRVGAP_PROCESS'; -- Recipe Lab use Approval Workflow Process Inernal Name
      P_lab_activity_name VARCHAR2(80) := 'GMDRVGAP_NOTI_REQUEST';
      P_table_name        VARCHAR2(32) := 'GMD_RECIPE_VALIDITY_RULES'; -- Key Table
      P_where_clause      VARCHAR2(100) ;
      p_role              GMA_ACTDATA_WF.ROLE%TYPE;
      l_data_string       VARCHAR2(2000);
      l_delimiter         VARCHAR2(15) := FND_PROFILE.VALUE ('SY$WF_DELIMITER');
      l_target_status     GMD_STATUS_NEXT.TARGET_STATUS%TYPE;
    BEGIN
      l_recipe_validity_rule_id:=wf_engine.getitemattrnumber(p_itemtype, p_itemkey,'GMDRVGAP_RECIPE_VALIDITYRULEID');
      -- Bug# 5030408 Kapil M : Removed the table name
     P_where_clause := ' RECIPE_VALIDITY_RULE_ID=' ||l_recipe_validity_rule_id; -- Where clause to be appended
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
         					  aname => 'GMDRVGAP_ADDL_TEXT',
                                      avalue => l_data_string);

	      WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
      			              itemkey => p_itemkey,
         					  aname => 'GMDRVGAP_APPROVER',
                                      avalue => p_role);

            p_resultout:='COMPLETE:Y';
        ELSE
          l_target_status := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDRVGAP_TARGET_STATUS');
          UPDATE GMD_RECIPE_VALIDITY_RULES
          SET VALIDITY_RULE_STATUS  = l_target_status
          WHERE RECIPE_VALIDITY_RULE_ID    = l_recipe_validity_rule_id;
          p_resultout:='COMPLETE:N';
        END IF;
     END IF;
EXCEPTION
      WHEN OTHERS THEN
      WF_CORE.CONTEXT ('GMDRVGAP_wf_pkg','is_approval_req',p_itemtype,p_itemkey,p_role);
      raise;
END is_approval_req;

PROCEDURE REMINDAR_CHECK (
      p_itemtype      IN VARCHAR2,
      p_itemkey       IN VARCHAR2,
      p_actid         IN NUMBER,
      p_funcmode      IN VARCHAR2,
      p_resultout     OUT NOCOPY VARCHAR2) IS
      l_mesg_cnt      number:=wf_engine.getitemattrnumber(p_itemtype, p_itemkey,'GMDRVGAP_MESG_CNT');
      l_approver      VARCHAR2(80) := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDRVGAP_APPROVER');
BEGIN
       IF (p_funcmode = 'TIMEOUT') THEN
         l_mesg_cnt  := l_mesg_cnt + 1;
         IF l_mesg_cnt <= 4 THEN
            WF_ENGINE.SETITEMATTRNUMBER(itemtype => p_itemtype,itemkey => p_itemkey,
         	  	       aname => 'GMDRVGAP_MESG_CNT',
                         avalue => l_mesg_cnt);
         ELSE
            p_resultout := 'COMPLETE:DEFAULT';
         END IF;
       ELSIF (p_funcmode = 'RESPOND') THEN
          WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
                                   itemkey => p_itemkey,
         			           aname => 'GMDRVGAP_CURR_PERFORMER',
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
  l_recipe_validity_rule_id  GMD_RECIPE_VALIDITY_RULES.recipe_validity_rule_id%TYPE;
BEGIN
     l_recipe_validity_rule_id:=wf_engine.getitemattrnumber(p_itemtype, p_itemkey,'GMDRVGAP_RECIPE_VALIDITYRULEID');
     IF (p_funcmode = 'RUN') THEN
          l_target_status := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDRVGAP_TARGET_STATUS');
          UPDATE GMD_RECIPE_VALIDITY_RULES
          SET VALIDITY_RULE_STATUS  = l_target_status
          WHERE RECIPE_VALIDITY_RULE_ID    = l_recipe_validity_rule_id;
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
  l_start_status     GMD_STATUS_NEXT.TARGET_STATUS%TYPE;
  l_recipe_validity_rule_id  GMD_RECIPE_VALIDITY_RULES.recipe_validity_rule_id%TYPE;
BEGIN
     l_recipe_validity_rule_id:=wf_engine.getitemattrnumber(p_itemtype, p_itemkey,'GMDRVGAP_RECIPE_VALIDITYRULEID');
     IF (p_funcmode = 'RUN') THEN
          l_start_status := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDRVGAP_START_STATUS');
          l_target_status := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDRVGAP_TARGET_STATUS');
          SELECT rework_status into l_rework_status
          FROM GMD_STATUS_NEXT
          WHERE current_status = l_start_status
            AND target_status  = l_target_status
            AND pending_status IS NOT NULL;
          UPDATE GMD_RECIPE_VALIDITY_RULES
          SET VALIDITY_RULE_STATUS = l_rework_status
          WHERE RECIPE_VALIDITY_RULE_ID    = l_recipe_validity_rule_id;
     END IF;
END REQ_REJECTED;

PROCEDURE NO_RESPONSE (
      p_itemtype      IN VARCHAR2,
      p_itemkey       IN VARCHAR2,
      p_actid         IN NUMBER,
      p_funcmode      IN VARCHAR2,
      p_resultout     OUT NOCOPY VARCHAR2) IS
  l_recipe_validity_rule_id  GMD_RECIPE_VALIDITY_RULES.recipe_validity_rule_id%TYPE;
  l_start_status     GMD_STATUS_NEXT.TARGET_STATUS%TYPE;
BEGIN
     l_recipe_validity_rule_id:=wf_engine.getitemattrnumber(p_itemtype, p_itemkey,'GMDRVGAP_RECIPE_VALIDITYRULEID');
     IF (p_funcmode = 'RUN') THEN
          l_start_status := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDRVGAP_START_STATUS');
          UPDATE GMD_RECIPE_VALIDITY_RULES
          SET VALIDITY_RULE_STATUS  = l_start_status
          WHERE RECIPE_VALIDITY_RULE_ID    = l_recipe_validity_rule_id;
     END IF;
END NO_RESPONSE;
PROCEDURE MOREINFO_RESPONSE  (
      p_itemtype      IN VARCHAR2,
      p_itemkey       IN VARCHAR2,
      p_actid         IN NUMBER,
      p_funcmode      IN VARCHAR2,
      p_resultout     OUT NOCOPY VARCHAR2) IS
      l_requester     VARCHAR2(80) := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDRVGAP_REQUSTER');
BEGIN
       IF (p_funcmode = 'RESPOND') THEN
          WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
                                   itemkey => p_itemkey,
         			           aname => 'GMDRVGAP_CURR_PERFORMER',
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
      l_comment       VARCHAR2(4000):=wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDRVGAP_COMMENT');
      l_mesg_comment  VARCHAR2(4000):=wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDRVGAP_DISP_COMMENT');
      l_performer      VARCHAR2(80) := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDRVGAP_CURR_PERFORMER');
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
         			           aname => 'GMDRVGAP_DISP_COMMENT',
                                   avalue => l_mesg_comment);
--	   WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
--                                   itemkey => p_itemkey,
--         			           aname => 'GMDRVGAP_HTML_DISP_COMMENT',
--                                   avalue => l_html_mesg);
	   WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
                                   itemkey => p_itemkey,
         			           aname => 'GMDRVGAP_COMMENT',
                                   avalue => l_comment);
     END IF;
END;

END GMDRVGAP_wf_pkg;

/
