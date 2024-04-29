--------------------------------------------------------
--  DDL for Package Body GMDRPLAP_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMDRPLAP_WF_PKG" AS
/* $Header: GMDRPLAB.pls 120.0 2005/05/26 00:59:17 appldev noship $ */
   PROCEDURE wf_init (
      p_recipe_id         IN   GMD_RECIPES_B.recipe_id%TYPE,
      p_recipe_no         IN   GMD_RECIPES_B.recipe_no%TYPE,
      p_recipe_vers       IN   GMD_RECIPES_B.recipe_version%TYPE,
      p_start_status      IN   GMD_RECIPES_B.recipe_status%TYPE,
      p_target_status     IN   GMD_RECIPES_B.recipe_status%TYPE,
      p_requester         IN   GMD_RECIPES_B.LAST_UPDATED_BY%TYPE,
      p_last_update_date  IN   GMD_RECIPES_B.LAST_UPDATE_DATE%TYPE
                )
   IS
      /* procedure to initialize and run Workflow */

      l_itemtype                WF_ITEMS.ITEM_TYPE%TYPE :=  'GMDRPLAP';
      l_itemkey                 WF_ITEMS.ITEM_KEY%TYPE  :=  to_char(p_recipe_id)||'-'||to_char(p_last_update_date,'dd-MON-yyyy   HH24:mi:ss');
      l_runform                 VARCHAR2(100);
      l_performer_name          FND_USER.USER_NAME%TYPE ;
      l_performer_display_name  FND_USER.DESCRIPTION%TYPE ;

      l_wf_timeout     NUMBER := TO_NUMBER(FND_PROFILE.VALUE ('GMD_WF_TIMEOUT'));

      /* Mercy Thomas Bug 3173515 Added the following variables for the NPD workflow changes */
      l_recipe_description      GMD_RECIPES.RECIPE_DESCRIPTION%TYPE;
      l_owner_id                GMD_RECIPES.OWNER_ID%TYPE;
      l_creation_orgn_code      ORG_ORGANIZATION_DEFINITIONS.ORGANIZATION_CODE%TYPE;
      l_creation_orgn_id        GMD_RECIPES.creation_organization_id%TYPE;
      l_formula_no              FM_FORM_MST.FORMULA_NO%TYPE;
      l_formula_vers            FM_FORM_MST.FORMULA_VERS%TYPE;
      l_routing_no              GMD_ROUTINGS.ROUTING_NO%TYPE;
      l_routing_vers            GMD_ROUTINGS.ROUTING_VERS%TYPE;
      /* Mercy Thomas Bug 3173515 End of the changes */

      /* make sure that process runs with background engine
       to prevent SAVEPOINT/ROLLBACK error (see Workflow FAQ)
       the value to use for this is -1 */

      l_run_wf_in_background CONSTANT WF_ENGINE.THRESHOLD%TYPE := 1000;


      l_WorkflowProcess   VARCHAR2(30) := 'GMDRPLAP_PROCESS';
      l_count             NUMBER;
      BEGIN

      	/* create the process */
      	WF_ENGINE.CREATEPROCESS (itemtype => l_itemtype, itemkey => l_itemkey, process => l_WorkflowProcess) ;

      	/* make sure that process runs with background engine */
      	WF_ENGINE.THRESHOLD := l_run_wf_in_background ;

      	/* set the item attributes */
      	WF_ENGINE.SETITEMATTRNUMBER(itemtype => l_itemtype,itemkey => l_itemkey,
         				  	       aname => 'GMDRPLAP_RECIPE_ID',
         	                               avalue => p_recipe_id);

      	WF_ENGINE.SETITEMATTRNUMBER(itemtype => l_itemtype,itemkey => l_itemkey,
         				  	       aname => 'GMDRPLAP_START_STATUS',
         	                               avalue => p_start_status);
            l_wf_timeout := (l_wf_timeout * 24 * 60) / 4 ;  -- Converting days into minutes

      	WF_ENGINE.SETITEMATTRNUMBER(itemtype => l_itemtype,itemkey => l_itemkey,
         				  	       aname => 'GMDRPLAP_TIMEOUT',
         	                               avalue => l_wf_timeout);
      	WF_ENGINE.SETITEMATTRNUMBER(itemtype => l_itemtype,itemkey => l_itemkey,
         				  	       aname => 'GMDRPLAP_MESG_CNT',
         	                               avalue => 1);


      	WF_ENGINE.SETITEMATTRNUMBER(itemtype => l_itemtype,itemkey => l_itemkey,
         				  	       aname => 'GMDRPLAP_TARGET_STATUS',
         	                               avalue => p_target_status);

      	WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         					  aname => 'GMDRPLAP_RECIPE_NO',
         					  avalue => p_recipe_no);

      	WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         					  aname => 'GMDRPLAP_RECIPE_VERS',
         					  avalue => p_recipe_vers);

            l_runform := 'GMDRCPED_F:RECIPE_ID='||to_char(p_recipe_id);

      	WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         					  aname => 'GMDRPLAP_FORM',
         					  avalue => l_runform);

      -- get values to be stored into the workflow item
      SELECT USER_NAME , DESCRIPTION
      INTO   l_performer_name ,l_performer_display_name
      FROM   FND_USER
      WHERE  USER_ID = p_Requester;

      	WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         					  aname => 'GMDRPLAP_REQUSTER',
         					  avalue => l_performer_name );

      /* Mercy Thomas Bug 3173515 Added the following variables for the NPD workflow changes */
      SELECT A.RECIPE_DESCRIPTION, A.OWNER_ID, A.CREATION_ORGANIZATION_ID, C.FORMULA_NO, C.FORMULA_VERS, B.ROUTING_NO, B.ROUTING_VERS
      INTO l_recipe_description, l_owner_id, l_creation_orgn_id, l_formula_no, l_formula_vers, l_routing_no, l_routing_vers
      FROM GMD_RECIPES A, GMD_ROUTINGS B, FM_FORM_MST C
      WHERE A.RECIPE_ID  = P_RECIPE_ID
      AND   A.ROUTING_ID = B.ROUTING_ID  (+)
      AND   A.FORMULA_ID = C.FORMULA_ID;

      /* Krishna, fetch Organization Code */
      IF l_creation_orgn_id is NOT NULL then
         GMD_ERES_UTILS.GET_ORGANIZATION_CODE(l_creation_orgn_id, l_creation_orgn_code);
      END IF;

      SELECT USER_NAME , DESCRIPTION
      INTO   l_performer_name ,l_performer_display_name
      FROM   FND_USER
      WHERE  USER_ID = l_owner_id;

      WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
        					  aname => 'GMDRPLAP_OWNER_ID',
         					  avalue => l_performer_name);

      WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         					  aname => 'GMDRPLAP_RECIPE_DESC',
         					  avalue => l_recipe_description);

      WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         					  aname => 'GMDRPLAP_CREATION_ORGN_CODE',
         					  avalue => l_creation_orgn_code);

      WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         					  aname => 'GMDRPLAP_ROUTING_NO',
         					  avalue => l_routing_no);

      WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         					  aname => 'GMDRPLAP_ROUTING_VERS',
         					  avalue => l_routing_vers);

      WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         					  aname => 'GMDRPLAP_FORMULA_NO',
         					  avalue => l_formula_no);

      WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         					  aname => 'GMDRPLAP_FORMULA_VERS',
         					  avalue => l_formula_vers);

      /* Mercy Thomas Bug 3173515 End of the changes */


     	  /* start the Workflow process */

      	WF_ENGINE.STARTPROCESS (itemtype => l_itemtype,itemkey => l_itemkey);



  EXCEPTION
      WHEN OTHERS THEN
      WF_CORE.CONTEXT ('GMDRPLAP_wf_pkg','wf_init',l_itemtype,l_itemkey,'Initial' );
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

      l_recipe_id         GMD_RECIPES_B.recipe_id%TYPE:=to_number(wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDRPLAP_RECIPE_ID'));
      p_data_string       VARCHAR2(2000);
      p_wf_data_string    VARCHAR2(2000);
      p_lab_wf_item_type  VARCHAR2(8)  := 'GMDRPLAP';  -- Recipe Lab use Approval Workflow Inernal Name
      P_lab_Process_name  VARCHAR2(32) := 'GMDRPLAP_PROCESS'; -- Recipe Lab use Approval Workflow Process Inernal Name
      P_lab_activity_name VARCHAR2(80) := 'GMDRPLAP_NOTI_REQUEST';
      P_table_name        VARCHAR2(32) := 'GMD_RECIPES_B'; -- Key Table
      P_where_clause      VARCHAR2(100):= ' GMD_RECIPES_B.RECIPE_ID='||l_RECIPE_ID; -- Where clause to be appended
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
         					  aname => 'GMDRPLAP_ADDL_TEXT',
                                      avalue => l_data_string);

	          WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
      			              itemkey => p_itemkey,
         					  aname => 'GMDRPLAP_APPROVER',
                                      avalue => p_role);

                 p_resultout:='COMPLETE:Y';
               ELSE
                 l_target_status := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDRPLAP_TARGET_STATUS');
                 UPDATE GMD_RECIPES_B
                 SET RECIPE_STATUS  = l_target_status
                 WHERE RECIPE_ID    = l_recipe_id;
                 p_resultout:='COMPLETE:N';
               END IF;
     END IF;
EXCEPTION
      WHEN OTHERS THEN
      WF_CORE.CONTEXT ('GMDRPLAP_wf_pkg','is_approval_req',p_itemtype,p_itemkey,p_role);
      raise;
END is_approval_req;


PROCEDURE REMINDAR_CHECK (
      p_itemtype      IN VARCHAR2,
      p_itemkey       IN VARCHAR2,
      p_actid         IN NUMBER,
      p_funcmode      IN VARCHAR2,
      p_resultout     OUT NOCOPY VARCHAR2) IS
      l_mesg_cnt      number:=wf_engine.getitemattrnumber(p_itemtype, p_itemkey,'GMDRPLAP_MESG_CNT');
      l_approver      VARCHAR2(80) := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDRPLAP_APPROVER');
BEGIN
       IF (p_funcmode = 'TIMEOUT') THEN
         l_mesg_cnt  := l_mesg_cnt + 1;
         IF l_mesg_cnt <= 4 THEN
            WF_ENGINE.SETITEMATTRNUMBER(itemtype => p_itemtype,itemkey => p_itemkey,
         	  	       aname => 'GMDRPLAP_MESG_CNT',
                         avalue => l_mesg_cnt);
         ELSE
            p_resultout := 'COMPLETE:DEFAULT';
         END IF;
       ELSIF (p_funcmode = 'RESPOND') THEN
          WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
                                   itemkey => p_itemkey,
         			           aname => 'GMDRPLAP_CURR_PERFORMER',
                                   avalue => l_approver);
       END IF;
END;


/* ########################################################################
** Name    : REQ_APPROVED
**
** HISTORY
** kkillams 01-dec-2004 orgn_code  is replaced with organization_id/owner_organization_id w.r.t. 4004501
**+========================================================================+*/
PROCEDURE REQ_APPROVED (
      p_itemtype      IN VARCHAR2,
      p_itemkey       IN VARCHAR2,
      p_actid         IN NUMBER,
      p_funcmode      IN VARCHAR2,
      p_resultout     OUT NOCOPY VARCHAR2) IS
  l_target_status     GMD_STATUS_NEXT.TARGET_STATUS%TYPE;
  l_recipe_id         GMD_RECIPES_B.recipe_id%TYPE:=to_number(wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDRPLAP_RECIPE_ID'));
/* added variables for recipe generation for B3604554 */
      l_return_status	  VARCHAR2(1);
	l_formula_id	NUMBER(10);
     x_end_status	  VARCHAR2(32);
     l_orgn_id            NUMBER;
     l_recipe_use	  VARCHAR2(1);

     CURSOR c_get_details IS
     	SELECT r.owner_organization_id, r.formula_id, r.recipe_no, r.recipe_version, f.formula_status
     	FROM   gmd_recipes_b r, fm_form_mst_b f
     	WHERE  r.recipe_id = l_recipe_id
	AND    r.formula_id = f.formula_id;
	LocalDetailsRecord		c_get_details%ROWTYPE;

      CURSOR cur_recipe_enable IS
	SELECT 	recipe_use_prod, recipe_use_plan, recipe_use_cost, recipe_use_reg, recipe_use_tech, managing_validity_rules
	FROM	gmd_recipe_generation
	WHERE	(organization_id = l_orgn_id OR
	         organization_id IS NULL)
	ORDER BY orgn_code;
      LocalEnableRecord		cur_recipe_enable%ROWTYPE;
BEGIN

     IF (p_funcmode = 'RUN') THEN
          l_target_status := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDRPLAP_TARGET_STATUS');
          UPDATE GMD_RECIPES_B
          SET RECIPE_STATUS  = l_target_status
          WHERE RECIPE_ID    = l_recipe_id;

	OPEN c_get_details;
 	FETCH c_get_details INTO LocalDetailsRecord;
	   l_orgn_id := LocalDetailsRecord.owner_organization_id;
	   l_formula_id := LocalDetailsRecord.formula_id;
 	CLOSE c_get_details;

 	OPEN 	cur_recipe_enable;
	FETCH	cur_recipe_enable INTO LocalEnableRecord;
	IF cur_recipe_enable%FOUND THEN
	  GMD_RECIPE_GENERATE.create_validity_rule_set(p_recipe_id => l_recipe_id,
				                       p_recipe_no => LocalDetailsRecord.recipe_no,
				                       p_recipe_version => LocalDetailsRecord.recipe_version,
				                       p_formula_id => l_formula_id,
				                       p_orgn_id => l_orgn_id,
				                       p_recipe_use_prod => LocalEnableRecord.recipe_use_prod,
				                       p_recipe_use_plan => LocalEnableRecord.recipe_use_plan,
				                       p_recipe_use_cost => LocalEnableRecord.recipe_use_cost,
				                       p_recipe_use_reg => LocalEnableRecord.recipe_use_reg,
				                       p_recipe_use_tech => LocalEnableRecord.recipe_use_tech,
				                       p_manage_validity_rules => LocalEnableRecord.managing_validity_rules,
			                               p_event_signed  => FALSE,
				                       x_return_status	=> l_return_status);
	END IF;
	CLOSE 	cur_recipe_enable;
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
  l_recipe_id         GMD_RECIPES_B.recipe_id%TYPE:=to_number(wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDRPLAP_RECIPE_ID'));
BEGIN
     IF (p_funcmode = 'RUN') THEN
          l_start_status := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDRPLAP_START_STATUS');
          l_target_status := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDRPLAP_TARGET_STATUS');
          SELECT rework_status into l_rework_status
          FROM GMD_STATUS_NEXT
          WHERE current_status = l_start_status
            AND target_status  = l_target_status
            AND pending_status IS NOT NULL;
          UPDATE GMD_RECIPES_B
          SET RECIPE_STATUS  = l_rework_status
          WHERE RECIPE_ID    = l_recipe_id;
     END IF;
END REQ_REJECTED;

PROCEDURE NO_RESPONSE (
      p_itemtype      IN VARCHAR2,
      p_itemkey       IN VARCHAR2,
      p_actid         IN NUMBER,
      p_funcmode      IN VARCHAR2,
      p_resultout     OUT NOCOPY VARCHAR2) IS
  l_recipe_id         GMD_RECIPES_B.recipe_id%TYPE:=to_number(wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDRPLAP_RECIPE_ID'));
  l_start_status     GMD_STATUS_NEXT.TARGET_STATUS%TYPE;
BEGIN
     IF (p_funcmode = 'RUN') THEN
          l_start_status := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDRPLAP_START_STATUS');
          UPDATE GMD_RECIPES_B
          SET RECIPE_STATUS  = l_start_status
          WHERE RECIPE_ID    = l_recipe_id;
     END IF;
END NO_RESPONSE;

PROCEDURE MOREINFO_RESPONSE  (
      p_itemtype      IN VARCHAR2,
      p_itemkey       IN VARCHAR2,
      p_actid         IN NUMBER,
      p_funcmode      IN VARCHAR2,
      p_resultout     OUT NOCOPY VARCHAR2) IS
      l_requester     VARCHAR2(80) := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDRPLAP_REQUSTER');
BEGIN
       IF (p_funcmode = 'RESPOND') THEN
          WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
                                   itemkey => p_itemkey,
         			           aname => 'GMDRPLAP_CURR_PERFORMER',
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
      l_comment       VARCHAR2(4000):=wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDRPLAP_COMMENT');
      l_mesg_comment  VARCHAR2(4000):=wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDRPLAP_DISP_COMMENT');
      l_performer      VARCHAR2(80) := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDRPLAP_CURR_PERFORMER');
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
         			           aname => 'GMDRPLAP_DISP_COMMENT',
                                   avalue => l_mesg_comment);
--	   WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
--                                   itemkey => p_itemkey,
--         			           aname => 'GMDRPLAP_HTML_DISP_COMMENT',
--                                   avalue => l_html_mesg);
	   WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
                                   itemkey => p_itemkey,
         			           aname => 'GMDRPLAP_COMMENT',
                                   avalue => l_comment);
       END IF;
END;

END GMDRPLAP_wf_pkg;

/
