--------------------------------------------------------
--  DDL for Package Body GMDFMLAP_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMDFMLAP_WF_PKG" AS
/* $Header: GMDFMLAB.pls 120.1 2006/08/08 11:25:42 kmotupal noship $ */
   PROCEDURE wf_init (
      p_formula_id         IN   FM_FORM_MST_B.formula_id%TYPE,
      p_formula_no         IN   FM_FORM_MST_B.formula_no%TYPE,
      p_formula_vers       IN   FM_FORM_MST_B.formula_vers%TYPE,
      p_start_status      IN   FM_FORM_MST_B.formula_status%TYPE,
      p_target_status     IN   FM_FORM_MST_B.formula_status%TYPE,
      p_requester         IN   FM_FORM_MST_B.LAST_UPDATED_BY%TYPE,
      p_last_update_date  IN   FM_FORM_MST_B.LAST_UPDATE_DATE%TYPE
                )
   IS
      /* procedure to initialize and run Workflow */

      l_itemtype                WF_ITEMS.ITEM_TYPE%TYPE :=  'GMDFMLAP';
      l_itemkey                 WF_ITEMS.ITEM_KEY%TYPE  :=  to_char(p_formula_id)||'-'||to_char(p_last_update_date,'dd-MON-yyyy   HH24:mi:ss');
      l_runform                 VARCHAR2(100);
      l_performer_name          FND_USER.USER_NAME%TYPE ;
      l_performer_display_name  FND_USER.DESCRIPTION%TYPE ;
      /* Mercy Thomas Bug 3173515 Added the following variables for the NPD workflow changes */
      l_formula_desc            FM_FORM_MST.FORMULA_DESC1%TYPE;
      l_owner_id                FM_FORM_MST.OWNER_ID%TYPE;
      l_formula_class           FM_FORM_MST.FORMULA_CLASS%TYPE;
      l_scale_type              VARCHAR2(10);
      /* Mercy Thomas Bug 3173515 End of the changes */


      /* make sure that process runs with background engine
       to prevent SAVEPOINT/ROLLBACK error (see Workflow FAQ)
       the value to use for this is -1 */

      l_run_wf_in_background CONSTANT WF_ENGINE.THRESHOLD%TYPE := -1;
      l_wf_timeout     NUMBER := TO_NUMBER(FND_PROFILE.VALUE ('GMD_WF_TIMEOUT'));


      l_WorkflowProcess   VARCHAR2(30) := 'GMDFMLAP_PROCESS';
      l_count             NUMBER;
      BEGIN

      	/* create the process */
      	WF_ENGINE.CREATEPROCESS (itemtype => l_itemtype, itemkey => l_itemkey, process => l_WorkflowProcess) ;

      	/* make sure that process runs with background engine */
      	WF_ENGINE.THRESHOLD := l_run_wf_in_background ;

      	/* set the item attributes */
      	WF_ENGINE.SETITEMATTRNUMBER(itemtype => l_itemtype,itemkey => l_itemkey,
         				  	       aname => 'GMDFMLAP_FORMULA_ID',
         	                               avalue => p_formula_id);

      	WF_ENGINE.SETITEMATTRNUMBER(itemtype => l_itemtype,itemkey => l_itemkey,
         				  	       aname => 'GMDFMLAP_START_STATUS',
         	                               avalue => p_start_status);

      	WF_ENGINE.SETITEMATTRNUMBER(itemtype => l_itemtype,itemkey => l_itemkey,
         				  	       aname => 'GMDFMLAP_TARGET_STATUS',
         	                               avalue => p_target_status);

      	WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         					  aname => 'GMDFMLAP_FORMULA_NO',
         					  avalue => p_formula_no);

      	WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         					  aname => 'GMDFMLAP_FORMULA_VERS',
         					  avalue => p_formula_vers);

            l_wf_timeout := (l_wf_timeout * 24 * 60) / 4 ;  -- Converting days into minutes

      	WF_ENGINE.SETITEMATTRNUMBER(itemtype => l_itemtype,itemkey => l_itemkey,
         				  	       aname => 'GMDFMLAP_TIMEOUT',
         	                               avalue => l_wf_timeout);
      	WF_ENGINE.SETITEMATTRNUMBER(itemtype => l_itemtype,itemkey => l_itemkey,
         				  	       aname => 'GMDFMLAP_MESG_CNT',
         	                               avalue => 1);

            l_runform := 'GMDFRMED_F:FORMULA_ID='||to_char(p_formula_id);

      	WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         					  aname => 'GMDFMLAP_FORM',
         					  avalue => l_runform);

      -- get values to be stored into the workflow item
      SELECT USER_NAME , DESCRIPTION
      INTO   l_performer_name ,l_performer_display_name
      FROM   FND_USER
      WHERE  USER_ID = p_Requester;

      	WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         					  aname => 'GMDFMLAP_REQUSTER',
         					  avalue => l_performer_name );

      /* Mercy Thomas Bug 3173515 Added the following variables for the NPD workflow changes */
      SELECT FORMULA_DESC1, OWNER_ID, FORMULA_CLASS, DECODE(SCALE_TYPE, 1, 'Yes', 0, 'No')
      INTO   l_formula_desc, l_owner_id, l_formula_class, l_scale_type
      FROM FM_FORM_MST
      WHERE FORMULA_ID  = p_formula_id;

      SELECT USER_NAME , DESCRIPTION
      INTO   l_performer_name ,l_performer_display_name
      FROM   FND_USER
      WHERE  USER_ID = l_owner_id;

      WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
        					  aname => 'GMDFMLAP_OWNER_ID',
         					  avalue => l_performer_name);

      WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         					  aname => 'GMDFMLAP_FORMULA_DESC',
         					  avalue => l_formula_desc);

      WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         					  aname => 'GMDFMLAP_FORMULA_CLASS',
         					  avalue => l_formula_class);

      WF_ENGINE.SETITEMATTRTEXT(itemtype => l_itemtype,itemkey => l_itemkey,
         					  aname => 'GMDFMLAP_SCALE_TYPE',
         					  avalue => l_scale_type);


      /* Mercy Thomas Bug 3173515 End of the changes */

     	  /* start the Workflow process */

      	WF_ENGINE.STARTPROCESS (itemtype => l_itemtype,itemkey => l_itemkey);



  EXCEPTION
      WHEN OTHERS THEN
      WF_CORE.CONTEXT ('GMDFMLAP_wf_pkg','wf_init',l_itemtype,l_itemkey,'Initial' );
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

      l_formula_id         FM_FORM_MST_B.formula_id%TYPE:=to_number(wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDFMLAP_FORMULA_ID'));
      p_data_string       VARCHAR2(2000);
      p_lab_wf_item_type  VARCHAR2(8)  := 'GMDFMLAP';  -- Recipe Lab use Approval Workflow Inernal Name
      P_lab_Process_name  VARCHAR2(32) := 'GMDFMLAP_PROCESS'; -- Recipe Lab use Approval Workflow Process Inernal Name
      P_lab_activity_name VARCHAR2(80) := 'GMDFMLAP_NOTI_REQUEST';
      P_table_name        VARCHAR2(32) := 'FM_FORM_MST_B'; -- Key Table
      P_where_clause      VARCHAR2(100):= ' FM_FORM_MST_B.FORMULA_ID='||l_FORMULA_ID; -- Where clause to be appended
      p_role              GMA_ACTDATA_WF.ROLE%TYPE;
      l_data_string       VARCHAR2(2000);
      p_wf_data_string    VARCHAR2(2000);
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
         					  aname => 'GMDFMLAP_ADDL_TEXT',
                                      avalue => l_data_string);

	      WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
      			              itemkey => p_itemkey,
         					  aname => 'GMDFMLAP_APPROVER',
                                      avalue => p_role);

            p_resultout:='COMPLETE:Y';
      ELSE
        l_target_status := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDFMLAP_TARGET_STATUS');
        UPDATE FM_FORM_MST_B
        SET FORMULA_STATUS  = l_target_status
        WHERE FORMULA_ID    = l_formula_id;
        p_resultout:='COMPLETE:N';
      END IF;
     END IF;
EXCEPTION
      WHEN OTHERS THEN
      WF_CORE.CONTEXT ('GMDFMLAP_wf_pkg','is_approval_req',p_itemtype,p_itemkey,p_role);
      raise;
END is_approval_req;


PROCEDURE REMINDAR_CHECK (
      p_itemtype      IN VARCHAR2,
      p_itemkey       IN VARCHAR2,
      p_actid         IN NUMBER,
      p_funcmode      IN VARCHAR2,
      p_resultout     OUT NOCOPY VARCHAR2) IS
      l_mesg_cnt      number:=wf_engine.getitemattrnumber(p_itemtype, p_itemkey,'GMDFMLAP_MESG_CNT');
      l_approver      VARCHAR2(80) := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDFMLAP_APPROVER');
BEGIN
       IF (p_funcmode = 'TIMEOUT') THEN
         l_mesg_cnt  := l_mesg_cnt + 1;
         IF l_mesg_cnt <= 4 THEN
            WF_ENGINE.SETITEMATTRNUMBER(itemtype => p_itemtype,itemkey => p_itemkey,
         	  	       aname => 'GMDFMLAP_MESG_CNT',
                         avalue => l_mesg_cnt);
         ELSE
            p_resultout := 'COMPLETE:DEFAULT';
         END IF;
       ELSIF (p_funcmode = 'RESPOND') THEN
          WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
                                   itemkey => p_itemkey,
         			           aname => 'GMDFMLAP_CURR_PERFORMER',
                                   avalue => l_approver);
       END IF;
END;


/*+========================================================================+
** Name    : req_approved
**
** HISTORY
** Ger Kelly  10 May 	  B3604554 - added functionality for recipe generation.
** G.Kelly    25-May-2004 B3648200 Modified the call to GMD_RECIPE_GENERATE as this was changed.
** kkillams   01-DEC-2004 orgn_code  is replaced with organization_id/owner_organization_id w.r.t. 4004501
**+========================================================================+*/

PROCEDURE REQ_APPROVED (
      p_itemtype      IN VARCHAR2,
      p_itemkey       IN VARCHAR2,
      p_actid         IN NUMBER,
      p_funcmode      IN VARCHAR2,
      p_resultout     OUT NOCOPY VARCHAR2) IS
  l_target_status     GMD_STATUS_NEXT.TARGET_STATUS%TYPE;
  l_formula_id         FM_FORM_MST_B.formula_id%TYPE:=to_number(wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDFMLAP_FORMULA_ID'));
/* GK added variables for recipe generation B3604554  */
      l_return_status	  VARCHAR2(1);
      x_recipe_no	  VARCHAR2(32);
      x_recipe_version	  NUMBER;
     l_orgn_id            NUMBER;

    CURSOR Cur_check_recipe (V_formula_id NUMBER) IS
      SELECT 1
      FROM   sys.dual
      WHERE  EXISTS (SELECT 1
                     FROM   gmd_recipes_b
                     WHERE  formula_id = V_formula_id);

     CURSOR c_get_orgn (V_formula_id NUMBER) IS
     	SELECT owner_organization_id
     	FROM   fm_form_mst_b
     	WHERE  formula_id = V_formula_id;

      /* Bug 3748697 - Recipe should only be created for automatic */
      /* or optional setup */
      CURSOR cur_recipe_enable (V_orgn_id VARCHAR2) IS
        SELECT creation_type
        FROM   gmd_recipe_generation
        WHERE  organization_id = V_orgn_id
        AND    creation_type IN (1,2)
        UNION
        SELECT creation_type
        FROM   gmd_recipe_generation
        WHERE  organization_id IS NULL
        AND    creation_type IN (1,2)
        AND    NOT EXISTS (SELECT 1
                           FROM   gmd_recipe_generation
                           WHERE  organization_id = V_orgn_id);
      l_creation_type	NUMBER(5);

BEGIN

     IF (p_funcmode = 'RUN') THEN
          l_target_status := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDFMLAP_TARGET_STATUS');
          UPDATE FM_FORM_MST_B
          SET FORMULA_STATUS  = l_target_status
          WHERE FORMULA_ID    = l_formula_id;

          /* Bug 3748697 - Thomas Daniel */
          /* Added the following check to ensure that recipe */
          /* is not created when the user is changing the status of the formula */
          /*First lets check if a recipe exists for this formula */
          OPEN Cur_check_recipe (l_formula_id);
          FETCH Cur_check_recipe INTO l_creation_type;
          IF Cur_check_recipe%NOTFOUND THEN
            CLOSE Cur_check_recipe;
            /* It implies that there is no recipe, so lets check if the rules have been set to create */
            /* one automatically */
  	    OPEN c_get_orgn (l_formula_id);
 	    FETCH c_get_orgn INTO l_orgn_id;
 	    CLOSE c_get_orgn;

 	    OPEN cur_recipe_enable (l_orgn_id);
	    FETCH cur_recipe_enable INTO l_creation_type;
	    IF cur_recipe_enable%FOUND THEN
	      GMD_RECIPE_GENERATE.recipe_generate(l_orgn_id, l_formula_id, l_return_status, x_recipe_no, x_recipe_version, FALSE);
	    END IF;
	    CLOSE cur_recipe_enable;
	  ELSE
	    CLOSE Cur_check_recipe;
	  END IF; /* IF Cur_check_recipe%FOUND */
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
  l_formula_id         FM_FORM_MST_B.formula_id%TYPE:=to_number(wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDFMLAP_FORMULA_ID'));
BEGIN
     IF (p_funcmode = 'RUN') THEN
          l_start_status := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDFMLAP_START_STATUS');
          l_target_status := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDFMLAP_TARGET_STATUS');
          SELECT rework_status into l_rework_status
          FROM GMD_STATUS_NEXT
          WHERE current_status = l_start_status
            AND target_status  = l_target_status
            AND pending_status IS NOT NULL;
          UPDATE FM_FORM_MST_B
          SET FORMULA_STATUS  = l_rework_status
          WHERE FORMULA_ID    = l_formula_id;
     END IF;
END REQ_REJECTED;

PROCEDURE NO_RESPONSE (
      p_itemtype      IN VARCHAR2,
      p_itemkey       IN VARCHAR2,
      p_actid         IN NUMBER,
      p_funcmode      IN VARCHAR2,
      p_resultout     OUT NOCOPY VARCHAR2) IS
  l_formula_id         FM_FORM_MST_B.formula_id%TYPE:=to_number(wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDFMLAP_FORMULA_ID'));
  l_start_status      GMD_STATUS_NEXT.TARGET_STATUS%TYPE;
BEGIN
     IF (p_funcmode = 'RUN') THEN
          l_start_status := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDFMLAP_START_STATUS');
          UPDATE FM_FORM_MST_B
          SET FORMULA_STATUS  = l_start_status
          WHERE FORMULA_ID    = l_formula_id;
     END IF;
END NO_RESPONSE;

PROCEDURE MOREINFO_RESPONSE  (
      p_itemtype      IN VARCHAR2,
      p_itemkey       IN VARCHAR2,
      p_actid         IN NUMBER,
      p_funcmode      IN VARCHAR2,
      p_resultout     OUT NOCOPY VARCHAR2) IS
      l_requester     VARCHAR2(80) := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDFMLAP_REQUSTER');
BEGIN
       IF (p_funcmode = 'RESPOND') THEN
          WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
                                   itemkey => p_itemkey,
         			           aname => 'GMDFMLAP_CURR_PERFORMER',
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
      l_comment       VARCHAR2(4000):=wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDFMLAP_COMMENT');
      l_mesg_comment  VARCHAR2(4000):=wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDFMLAP_DISP_COMMENT');
      l_performer     VARCHAR2(80) := wf_engine.getitemattrtext(p_itemtype, p_itemkey,'GMDFMLAP_CURR_PERFORMER');
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
         			           aname => 'GMDFMLAP_DISP_COMMENT',
                                   avalue => l_mesg_comment);
--	   WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
--                                   itemkey => p_itemkey,
--         			           aname => 'GMDFMLAP_HTML_DISP_COMMENT',
--                                   avalue => l_html_mesg);
	   WF_ENGINE.SETITEMATTRTEXT(itemtype => p_itemtype,
                                   itemkey => p_itemkey,
         			           aname => 'GMDFMLAP_COMMENT',
                                   avalue => l_comment);
       END IF;
END;

END GMDFMLAP_wf_pkg;

/
