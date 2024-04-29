--------------------------------------------------------
--  DDL for Package Body IGI_EXP_APPROVAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_EXP_APPROVAL_PKG" AS
   -- $Header: igiexab.pls 120.13.12010000.3 2009/02/06 06:57:31 sharoy ship $




 /* ============== WORKFLOW VARAIBLES =================
 ## Variables for framing and coloring the Table.
 ## copied FROM WF_NOTIFICATION package
 ## /fnddev/fnd/11.5/patch/115/sql/wfntfb.pls
 ##
 */

    table_width        VARCHAR2(6)  := '"100%"';
    table_border       VARCHAR2(3)  := '"0"';
    table_cellpadding  VARCHAR2(3)  := '"3"';
    table_cellspacing  VARCHAR2(3)  := '"1"';
    total_cellspacing  VARCHAR2(3)  := '"0"';
    table_bgcolor      VARCHAR2(7)  := '"white"';
    th_bgcolor         VARCHAR2(9)  := '"#cccc99"';
    th_fontcolor       VARCHAR2(9)  := '"#336699"';
    th_fontface        VARCHAR2(80) := '"Arial, Helvetica, Geneva, sans-serif"';
    th_fontsize        VARCHAR2(2)  := '2';
    td_bgcolor         VARCHAR2(9)  := '"#f7f7e7"';
    td_fontcolor       VARCHAR2(7)  := '"black"';
    td_fontface        VARCHAR2(80) := '"Arial, Helvetica, Geneva, sans-serif"';
    td_fontsize        varchar2(2)  := '2';

 /* ============== FND LOG VARIABLES ================== */
    l_debug_level   number := FND_LOG.G_CURRENT_RUNTIME_LEVEL ;
    l_state_level   number := FND_LOG.LEVEL_STATEMENT ;
    l_proc_level    number := FND_LOG.LEVEL_PROCEDURE ;
    l_event_level   number := FND_LOG.LEVEL_EVENT ;
    l_excep_level   number := FND_LOG.LEVEL_EXCEPTION ;
    l_error_level   number := FND_LOG.LEVEL_ERROR ;
    l_unexp_level   number := FND_LOG.LEVEL_UNEXPECTED ;

    -- global variables for framing the table header.
    l_table_head           VARCHAR2(100);
    l_line_head            VARCHAR2(100);
    l_desc_head            VARCHAR2(100);

   --
   --
   -- PRIVATE ROUTINES
   --
   --

   /* =================== DEBUG_LOG_UNEXP_ERROR =================== */

   Procedure Debug_log_unexp_error (P_module     IN VARCHAR2,
                                    P_error_type IN VARCHAR2)
   IS

   BEGIN

    IF (l_unexp_level >= l_debug_level) THEN

       IF   (P_error_type = 'DEFAULT') THEN
             FND_MESSAGE.SET_NAME('IGI','IGI_LOGGING_UNEXP_ERROR');
             FND_MESSAGE.SET_TOKEN('CODE',sqlcode);
             FND_MESSAGE.SET_TOKEN('MSG',sqlerrm);
             FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igiexab.igi_exp_approval_pkg.' || P_module ,TRUE);
       ELSIF (P_error_type = 'USER') THEN
             FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igiexab.igi_exp_approval_pkg.' || P_module ,TRUE);
       END IF;

    END IF;

    wf_core.context ('IGI_EXP_APPROVAL_PKG','igi.plsql.igiexab.igi_exp_approval_pkg.'|| P_module,
                                            'Unexpected error occured. Please refer FND LOG for detailed ERROR message');

   EXCEPTION
   WHEN OTHERS THEN
        wf_core.context ('IGI_EXP_APPROVAL_PKG','Debug_log_unexp_error', 'ERROR IN FND LOGGING');
        RAISE;

   END Debug_log_unexp_error;

   /* =================== DEBUG_LOG_STRING =================== */

   Procedure Debug_log_string (P_level   IN NUMBER,
                               P_module  IN VARCHAR2,
                               P_Message IN VARCHAR2)
   IS

   BEGIN

     IF (P_level >= l_debug_level) THEN
         FND_LOG.STRING(P_level, 'igi.plsql.igiexab.igi_exp_approval_pkg.' || P_module, P_message) ;
     END IF;

   EXCEPTION
   WHEN OTHERS THEN
        wf_core.context ('IGI_EXP_APPROVAL_PKG','Debug_log_string', 'ERROR IN FND LOGGING');
        RAISE;

   END Debug_log_string;

   /* =================== FRAME_TABLE_HEADER =================== */

   PROCEDURE Frame_table_header (p_html_tag  OUT NOCOPY VARCHAR2)
   IS

    l_table_details VARCHAR2(4000);

   BEGIN

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Frame_table_header.Msg1',
                           ' ** START FRAME_TABLE_HEADER ** ');
      -- =============== END DEBUG LOG ==================

      -- Getting the table heads from messages
      fnd_message.set_name ('IGI', 'IGI_EXP_TABLE_HEAD');
      l_table_head := fnd_message.get;
      fnd_message.set_name ('IGI', 'IGI_EXP_LINE');
      l_line_head := fnd_message.get;
      fnd_message.set_name ('IGI', 'IGI_EXP_DIA_LIST');
      l_desc_head := fnd_message.get;

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Frame_table_header.Msg2',
                           ' Getting table heading ' ||
                           ' l_table_head --> ' || l_table_head ||
                           ' l_line_head  --> ' || l_line_head  ||
                           ' l_desc_head  --> ' || l_desc_head  );
      -- =============== END DEBUG LOG ==================

      -- Framing the table headings..
      l_table_details := '<br><font color='||th_fontcolor||'face='||
                         th_fontface||'><b>'|| l_table_head || '</b>';

      l_table_details := l_table_details ||'<table bgcolor=' ||table_bgcolor
                                         ||' width='         ||table_width
                                         ||' border='        ||table_border
                                         ||' cellpadding='   ||table_cellpadding
                                         ||' cellspacing='   ||table_cellspacing||'>';

      l_table_details := l_table_details || '<tr bgcolor='||th_bgcolor||'>';
      l_table_details := l_table_details || '<td align="left"><font color='||th_fontcolor||' face='||
                         th_fontface||' size='||th_fontsize||'><b>' || l_line_head || '</b></td>';
      l_table_details := l_table_details || '<td align="left"><font color='||th_fontcolor||' face='||
                         th_fontface||' size='||th_fontsize||'><b>' || l_desc_head || '</b></td>';
      l_table_details := l_table_details || '</tr>';

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Frame_table_header.Msg3',
                          ' Table heading -- l_table_details --> ' || l_table_details);
     -- =============== END DEBUG LOG ==================

     p_html_tag := l_table_details;

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Frame_table_header.Msg4',
                           ' ** END FRAME_TABLE_HEADER ** ');
      -- =============== END DEBUG LOG ==================

  EXCEPTION
      WHEN OTHERS THEN
         p_html_tag := NULL;
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_UNEXP_ERROR ('Frame_table_header.Unexp1','DEFAULT');
         -- =============== END DEBUG LOG ==================
         raise;

   END Frame_table_header;

   -- *************************************************************************
   --    CREATE_DU_LIST
   -- *************************************************************************

  PROCEDURE Create_du_list (document_id   IN            VARCHAR2,
            display_type  IN            VARCHAR2,
            document      IN OUT NOCOPY CLOB,
            document_type IN OUT NOCOPY VARCHAR2)
  IS

      itemtype               VARCHAR2(30);
      itemkey                VARCHAR2(60);
      l_tu_id                igi_exp_dus.tu_id%TYPE;
      l_du_prep_id           igi_exp_dus.du_by_user_id%TYPE;

      l_du_list              VARCHAR2(28000);
      l_du                   VARCHAR2(4000);

      l_table_details        VARCHAR2(4000);
      l_substr               NUMBER := 1;
      l_instr                NUMBER := 0;
      l_line_num             NUMBER := 0;

   BEGIN


      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Create_du_list.Msg1',
                           ' ** START  CREATE_DU_LIST ** ');
      -- =============== END DEBUG LOG ==================

      itemtype := substr(document_id,1,instr(document_id,':')-1);
      itemkey  := substr(document_id,instr(document_id,':')+1);

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Create_du_list.Msg2',
                           ' itemtype --> ' || itemtype ||
                           ' itemkey  --> ' || itemkey);
         DEBUG_LOG_STRING (l_proc_level, 'Create_du_list.Msg3',
                           ' Getting values from ADD_ATTRS' );
      -- =============== END DEBUG LOG ==================

      FOR J IN 1..7 LOOP
        -- Get all the du attribute
        l_du := wf_engine.GetItemAttrText  ( itemtype => itemtype,
                                             itemkey  => itemkey,
                                             aname    => 'ADD_ATTR'||J);

        -- =============== START DEBUG LOG ================
           DEBUG_LOG_STRING (l_proc_level, 'Create_du_list.Msg4',
                             ' Getting from ADD_ATTR'||J);
        -- =============== END DEBUG LOG ==================

        IF (l_du IS NULL) THEN
            exit;
        END IF;

        l_du_list := l_du_list || l_du;

      END LOOP;

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Create_du_list.Msg5',
                           ' Calling frame table header ');
      -- =============== END DEBUG LOG ==================

      Frame_table_header (l_table_details);

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Create_du_list.Msg6',
                           ' l_table_details --> ' || l_table_details);
      -- =============== END DEBUG LOG ==================

      -- adding to the clob
      WF_NOTIFICATION.WriteToClob(Document,l_table_details);

      -- Framing the DU list and adding it to the table.
      LOOP

         l_instr                := instr(l_du_list, fnd_global.local_chr(10));

        -- =============== START DEBUG LOG ================
           DEBUG_LOG_STRING (l_proc_level, 'Create_du_list.Msg7',
                             ' l_instr --> ' || l_instr);
        -- =============== END DEBUG LOG ==================

         l_du := substr ( l_du_list, l_substr, l_instr );

        -- =============== START DEBUG LOG ================
           DEBUG_LOG_STRING (l_proc_level, 'Create_du_list.Msg8',
                             ' l_du --> ' || l_du);
        -- =============== END DEBUG LOG ==================

        -- putting details to HTML table.
        l_line_num      := l_line_num + 1;
        l_table_details := '<tr>';
        l_table_details := l_table_details || '<td bgcolor='||td_bgcolor||' align="left"><font color='||
                           td_fontcolor||' face='||td_fontface||' size='||td_fontsize||'>' || to_char(l_line_num) || '</td>';
        l_table_details := l_table_details || '<td bgcolor='||td_bgcolor||' align="left"><font color='||
                           td_fontcolor||' face='||td_fontface||' size='||td_fontsize||'>' || l_du || '</td>';
        l_table_details := l_table_details || '</tr>';

        -- =============== START DEBUG LOG ================
           DEBUG_LOG_STRING (l_proc_level, 'Create_du_list.Msg9',
                             ' Table details -- l_table_details --> ' || l_table_details);
        -- =============== END DEBUG LOG ==================

        WF_NOTIFICATION.WriteToClob(Document, l_table_details);

        l_du_list          := substr (l_du_list, l_instr+1);

        -- =============== START DEBUG LOG ================
           DEBUG_LOG_STRING (l_proc_level, 'Create_du_list.Msg10',
                             ' l_du_list --> '|| substr(l_du_list,1,3900));
        -- =============== END DEBUG LOG ==================

        IF (l_du_list IS NULL) THEN
           -- =============== START DEBUG LOG ================
              DEBUG_LOG_STRING (l_proc_level, 'Create_du_list.Msg11',
                                ' l_du_list IS NULL -- exiting' );
           -- =============== END DEBUG LOG ==================
           exit;
        END IF;

     END LOOP;


     -- closing the HTML table.
     l_table_details := '</table><br>';
     -- =============== START DEBUG LOG ================
        DEBUG_LOG_STRING (l_proc_level, 'Create_du_list.Msg12',
                          ' End of table -- l_table_details --> ' || l_table_details);
     -- =============== END DEBUG LOG ==================

     WF_NOTIFICATION.WriteToClob(Document,l_table_details);

    -- =============== START DEBUG LOG ================
       DEBUG_LOG_STRING (l_proc_level, 'Create_du_list.Msg13',
                         ' ** END  CREATE_DU_LIST ** ');
    -- =============== END DEBUG LOG ==================

   EXCEPTION
      WHEN OTHERS THEN
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_UNEXP_ERROR ('Create_du_list.Unexp1','DEFAULT');
         -- =============== END DEBUG LOG ==================
         raise;

   END Create_du_list;

  /* =================== SET_TU_FORM_TO_QUERY =================== */

   PROCEDURE set_tu_form_to_query (p_nid NUMBER) IS

      l_value      VARCHAR2(4000);
      l_new_value  VARCHAR2(4000);

   BEGIN

      -- This procedure is called from procedure set_curr_auth_to_responder
      -- (a post notification function).   This procedure will reset the value
      -- of the TU_FORM attribute after a notification has been responded to or
      -- timed out NOCOPY so that the TU form is called in query_only mode.

     -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'set_tu_form_to_query.Msg1',
                           ' ** BEGIN SET_TU_FORM_TO_QUERY ** ');
     -- =============== END DEBUG LOG ==================

      SELECT text_value
      INTO   l_value
      FROM   wf_notification_attributes
      WHERE  notification_id = p_nid
      AND    name = 'TU_FORM';

     -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'set_tu_form_to_query.Msg2',
                           ' l_value --> ' || l_value);
     -- =============== END DEBUG LOG ==================

      -- The value of parameter QUERY_ONLY should be set to 'YES'
      -- instead of 'NO'
      l_new_value := REPLACE(l_value,'NO','YES');

     -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'set_tu_form_to_query.Msg3',
                           ' l_new_value --> ' || l_new_value);
     -- =============== END DEBUG LOG ==================


      UPDATE wf_notification_attributes
      SET    text_value = l_new_value
      WHERE  notification_id = p_nid
      AND    name = 'TU_FORM';

     -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'set_tu_form_to_query.Msg4',
                           ' Updating wf_notification_attributes ');
         DEBUG_LOG_STRING (l_proc_level, 'set_tu_form_to_query.Msg5',
                           ' ** END SET_TU_FORM_TO_QUERY ** ');
     -- =============== END DEBUG LOG ==================

   EXCEPTION
      WHEN OTHERS THEN
        -- =============== START DEBUG LOG ================
           DEBUG_LOG_UNEXP_ERROR ('set_tu_form_to_query.Unexp1','DEFAULT');
        -- =============== END DEBUG LOG ==================
         RAISE;

   END set_tu_form_to_query;

   --
   --
   -- PUBLIC ROUTINES
   --
   --

   -- *************************************************************************
   --     SELECTOR
   -- *************************************************************************


   PROCEDURE Selector(itemtype   IN VARCHAR2,
                      itemkey    IN VARCHAR2,
                      actid      IN NUMBER,
                      funcmode   IN VARCHAR2,
                      resultout OUT NOCOPY VARCHAR2) IS

   l_session_org_id   NUMBER;
   l_work_item_org_id NUMBER;
   l_user_id          NUMBER;
   l_resp_id          NUMBER;
   l_appl_id          NUMBER;

   BEGIN

     -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Selector.Msg1',
                           ' ** BEGIN SELECTOR ** ');
     -- =============== END DEBUG LOG ==================
     -- Bug 4063076 Start

      IF funcmode = 'RUN'
      THEN
          -- Return process to run when workflow is invoked
          resultout := 'EXP_APPROVAL_TOP';
      ELSIF funcmode = 'TEST_CTX'
      THEN
          -- Code that compares current session context
          -- with the work item context required to execute
          -- the workflow
          --fnd_profile.get (name=>'ORG_ID', val=> l_session_org_id);
          l_session_org_id := mo_global.get_current_org_id(); -- Bug# 5905190 MOAC changes
          l_work_item_org_id := wf_engine.GetItemAttrNumber
                                    (itemtype,
                                     itemkey,
                                     'ORG_ID');
          IF nvl(l_session_org_id,-99) = l_work_item_org_id
          THEN
               resultout := 'TRUE';
          ELSE
               -- This will cause workflow to call this funciton
               -- in SET_CTX mode
               resultout := 'FALSE';
          END IF;

      ELSIF funcmode = 'SET_CTX'
      THEN
          l_user_id := wf_engine.GetItemAttrNumber
                                    (itemtype,
                                     itemkey,
                                     'USER_ID');
          l_resp_id := wf_engine.GetItemAttrNumber
                                    (itemtype,
                                     itemkey,
                                     'RESPONSIBILITY_ID');
          l_appl_id := wf_engine.GetItemAttrNumber
                                    (itemtype,
                                     itemkey,
                                     'RESP_APPL_ID');

         /*  Bug# 5905190 MOAC changes starts.
         Get org_id from Item Attribute and set policy context with same value
         */
         l_work_item_org_id := wf_engine.GetItemAttrNumber
                                             (itemtype,
                                              itemkey,
                                     'ORG_ID');

         mo_global.set_policy_context('S',l_work_item_org_id);
         /*  Bug# 5905190 MOAC changes ends */

         DEBUG_LOG_STRING (l_proc_level, 'Selector.Msg',
                           ' Setting apps context with userid, respid, applid as '
                           ||l_user_id ||' '|| l_resp_id ||' '|| l_appl_id );


          FND_GLOBAL.apps_initialize(l_user_id,l_resp_id,l_appl_id);

          resultout := 'COMPLETE';
      ELSE
          resultout := 'COMPLETE';
      END IF;

     -- Bug 4063076 End
     -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Selector.Msg3',
                           ' result --> ' || resultout);
         DEBUG_LOG_STRING (l_proc_level, 'Selector.Msg4',
                           ' ** END SELECTOR ** ');
     -- =============== END DEBUG LOG ==================


   EXCEPTION
      WHEN OTHERS THEN
        -- =============== START DEBUG LOG ================
           DEBUG_LOG_UNEXP_ERROR ('Selector.Unexp1','DEFAULT');
        -- =============== END DEBUG LOG ==================

         Wf_Core.Context ('IGI_EXP_APPROVAL_PKG','Selector', itemtype, itemkey,
                         TO_CHAR(actid),funcmode);
         RAISE;

   END Selector;


   -- *************************************************************************
   --     START_APPROVAL_WORKFLOW
   -- *************************************************************************


   PROCEDURE start_approval_workflow (p_tu_id               IN NUMBER
                                     ,p_tu_order_number     IN VARCHAR2
                                     ,p_tu_transmitter_name IN VARCHAR2
                                     ,p_tu_transmitter_id   IN NUMBER) IS

      l_itemtype          VARCHAR2(10) := 'EXPAPPRV';
      l_itemkey           VARCHAR2(50) ;
      l_approval_run_id   NUMBER;
      l_msg               VARCHAR2(2000);
      l_tu_legal_number   VARCHAR2(250);                              ---- Changes for  Bug 6640095  -    FP Bug  6847238


   BEGIN

     -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Start_approval_workflow.Msg1.3',
                                         ' **       BEGIN START_APPROVAL_WORKFLOW     ** ');
     -- =============== END DEBUG LOG ==================

      -- Update the status of the TU to 'Transmitted'
      UPDATE igi_exp_tus tus
      SET    tus.tu_status = 'TRA'
      WHERE  tus.tu_id = p_tu_id;

     -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Start_approval_workflow.Msg2',
                           ' updating igi_exp_tus setting tu_status = TRA for tu_id ' || p_tu_id);
     -- =============== END DEBUG LOG ==================

      -- Update the status of all DUs in the TU to 'Transmitted'
      UPDATE igi_exp_dus dus
      SET    dus.du_status = 'TRA'
      WHERE  dus.tu_id = p_tu_id;

     -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Start_approval_workflow.Msg3',
                           ' updating igi_exp_dus setting du_status = TRA for tu_id ' || p_tu_id);
     -- =============== END DEBUG LOG ==================

      -- Get approval run id
      SELECT igi_exp_tu_run_s1.nextval
      INTO   l_approval_run_id
      FROM   sys.dual;

     -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Start_approval_workflow.Msg4',
                           ' l_apporval_run_id --> ' || l_approval_run_id);
     -- =============== END DEBUG LOG ==================

      -- Generate the item key
      l_itemkey := to_char(p_tu_id)||'/'||to_char(l_approval_run_id);

     -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Start_approval_workflow.Msg5',
                           ' l_itemkey --> ' || l_itemkey);
     -- =============== END DEBUG LOG ==================

      -- Kick Off Workflow Process
      wf_engine.CreateProcess (itemtype => l_itemtype,
                               itemkey  => l_itemkey,
                               process  => 'EXP_APPROVAL_TOP');

     -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Start_approval_workflow.Msg6',
                           ' Create process ');
     -- =============== END DEBUG LOG ==================

      -- Set Item User Key
      wf_engine.SetItemUserKey( itemtype => l_itemtype,
                                itemkey  => l_itemkey,
                                userkey  => p_tu_order_number);

     -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Start_approval_workflow.Msg7',
                           ' SetItemUserKey  p_tu_order_number');
     -- =============== END DEBUG LOG ==================

      -- Set Process Owner
      wf_engine.SetItemOwner( itemtype => l_itemtype,
                              itemkey  => l_itemkey,
                              owner    => p_tu_transmitter_name);

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Start_approval_workflow.Msg8',
                           ' SetItemOwner  p_tu_transmitter_name');
      -- =============== END DEBUG LOG ==================

     -- Set TU id
      wf_engine.SetItemAttrNumber( itemtype => l_itemtype,
                                   itemkey  => l_itemkey,
                                   aname    => 'TU_ID',
                                   avalue   => p_tu_id);

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Start_approval_workflow.Msg9',
                           ' SetItemAttrNumber TU_ID --> ' || p_tu_id);
      -- =============== END DEBUG LOG ==================

      -- Set TU Order Number
      wf_engine.SetItemAttrText  ( itemtype => l_itemtype,
                                   itemkey  => l_itemkey,
                                   aname    => 'TU_ORDER_NUM',
                                   avalue   => p_tu_order_number);

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Start_approval_workflow.Msg10',
                           ' SetItemAttrText TU_ORDER_NUM --> ' || p_tu_order_number);
      -- =============== END DEBUG LOG ==================


 /*   wf_engine.SetItemAttrText  ( itemtype => l_itemtype,            ---- Changes for  Bug 6640095  -    FP Bug  6847238
                                   itemkey  => l_itemkey,
                                   aname    => 'TU_FULL_NUMBER',
                                   avalue   => p_tu_order_number);
   */
      -- Set TU Full Number

      -- Bug 6640095 modifications starts here.
      -- Introduced the following calculation for TU Full Number for bug 6640095.
      -- If the tu_legal_number is not got generated, then it will take tu_order_number.

     select tu_legal_number into l_tu_legal_number
     from igi_exp_tus WHERE tu_id = p_tu_id;

      IF (l_tu_legal_number is NULL) then

      -- Set TU Full Number
      wf_engine.SetItemAttrText  ( itemtype => l_itemtype,
                                   itemkey  => l_itemkey,
                                   aname    => 'TU_FULL_NUMBER',
                                   avalue   => p_tu_order_number);

      ELSE

      -- Set TU Full Number
      wf_engine.SetItemAttrText  ( itemtype => l_itemtype,
                                   itemkey  => l_itemkey,
                                   aname    => 'TU_FULL_NUMBER',
                                   avalue   => l_tu_legal_number);

      END IF;

   -- Bug 6640095 modifications ends here.                               ---- Changes for  Bug 6640095  -    FP Bug  6847238


      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Start_approval_workflow.Msg11',
                           ' SetItemAttrText TU_FULL_NUMBER --> ' || p_tu_order_number);
      -- =============== END DEBUG LOG ==================

      -- Set TU Transmitter User Name
      wf_engine.SetItemAttrText  ( itemtype => l_itemtype,
                                   itemkey  => l_itemkey,
                                   aname    => 'TRANSMITTER_FND_NAME',
                                   avalue   => p_tu_transmitter_name);

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Start_approval_workflow.Msg12',
                           ' SetItemAttrText TRANSMITTER_FND_NAME --> ' || p_tu_transmitter_name);
      -- =============== END DEBUG LOG ==================

      -- Set TU Transmitter User Id
      wf_engine.SetItemAttrNumber( itemtype => l_itemtype,
                                   itemkey  => l_itemkey,
                                   aname    => 'TRANSMITTER_FND_ID',
                                   avalue   => p_tu_transmitter_id);

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Start_approval_workflow.Msg13',
                           ' SetItemAttrText TRANSMITTER_FND_ID --> ' || p_tu_transmitter_id);
      -- =============== END DEBUG LOG ==================

      -- Set current authorizer role
      wf_engine.SetItemAttrText  ( itemtype => l_itemtype,
                                   itemkey  => l_itemkey,
                                   aname    => 'CURRENT_AUTHORIZER_ROLE',
                                   avalue   => p_tu_transmitter_name);

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Start_approval_workflow.Msg14',
                           ' SetItemAttrText CURRENT_AUTHORIZER_ROLE --> ' || p_tu_transmitter_name);
      -- =============== END DEBUG LOG ==================


      -- Add Transmitter to Authorizer History List
      wf_engine.SetItemAttrText  ( itemtype => l_itemtype,
                                   itemkey  => l_itemkey,
                                   aname    => 'AUTHORIZER_HISTORY_LIST',
                                   avalue   => p_tu_transmitter_name);

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Start_approval_workflow.Msg15',
                           ' SetItemAttrText AUTHORIZER_HISTORY_LIST --> ' || p_tu_transmitter_name);
      -- =============== END DEBUG LOG ==================

      -- Set user id, responsibility id , org id and application id context values
      -- Bug 4063076 , Start
      wf_engine.SetItemAttrText  ( itemtype => l_itemtype,
                                   itemkey  => l_itemkey,
                                   aname    => 'ORG_ID',
                                   avalue   => mo_global.get_current_org_id());

      -- =============== START DEBUG LOG ================

         DEBUG_LOG_STRING (l_proc_level, 'Start_approval_workflow.Msg16',

                           ' SetItemAttrText ORG_ID --> ' || FND_PROFILE.VALUE('ORG_ID'));

      -- =============== END DEBUG LOG ==================



      wf_engine.SetItemAttrText  ( itemtype => l_itemtype,
                                   itemkey  => l_itemkey,
                                   aname    => 'USER_ID',
                                   avalue   => FND_PROFILE.VALUE('USER_ID'));

      -- =============== START DEBUG LOG ================

         DEBUG_LOG_STRING (l_proc_level, 'Start_approval_workflow.Msg17',

                           ' SetItemAttrText USER_ID --> ' || FND_PROFILE.VALUE('USER_ID'));

      -- =============== END DEBUG LOG ==================


      wf_engine.SetItemAttrText  ( itemtype => l_itemtype,
                                   itemkey  => l_itemkey,
                                   aname    => 'RESPONSIBILITY_ID',
                                   avalue   => FND_PROFILE.VALUE('RESP_ID'));


      -- =============== START DEBUG LOG ================

         DEBUG_LOG_STRING (l_proc_level, 'Start_approval_workflow.Msg18',

                           ' SetItemAttrText RESPONSIBILITY_ID --> ' || FND_PROFILE.VALUE('RESPONSIBILITY_ID'));

      -- =============== END DEBUG LOG ==================

      wf_engine.SetItemAttrText  ( itemtype => l_itemtype,
                                   itemkey  => l_itemkey,
                                   aname    => 'RESP_APPL_ID',
                                   avalue   => FND_PROFILE.VALUE('RESP_APPL_ID'));

       -- =============== START DEBUG LOG ================

         DEBUG_LOG_STRING (l_proc_level, 'Start_approval_workflow.Msg19',

                           ' SetItemAttrText RESP_APPL_ID --> ' || FND_PROFILE.VALUE('RESP_APPL_ID'));

      -- =============== END DEBUG LOG ==================

      -- Bug 4063076 , End

      --Bug 5872277 Start
      fnd_message.set_name ('IGI', 'IGI_EXP_APP_PROC_ERROR');

      l_msg := fnd_message.get;

      -- =============== START DEBUG LOG ================

         DEBUG_LOG_STRING (l_proc_level, 'Start_approval_workflow.Msg20',

                           ' SetItemAttrText IGI_EXP_APP_PROC_ERROR --> ' || nvl(l_msg,' NULL '));

      -- =============== END DEBUG LOG ==================

      wf_engine.SetItemAttrText  ( itemtype => l_itemtype,
                                   itemkey  => l_itemkey,
                                   aname    => 'APP_PROC_ERROR',
                                   avalue   => l_msg);

      -- =============== START DEBUG LOG ================

         DEBUG_LOG_STRING (l_proc_level, 'Start_approval_workflow.Msg21',

                           ' SetItemAttrText APP_PROC_ERROR');

      -- =============== END DEBUG LOG ==================

      fnd_message.set_name ('IGI', 'IGI_EXP_DU_AUTH_REQ');
      l_msg := fnd_message.get;
      wf_engine.SetItemAttrText  ( itemtype => l_itemtype,
                                   itemkey  => l_itemkey,
                                   aname    => 'DU_AUTH_REQ',
                                   avalue   => l_msg);

      fnd_message.set_name ('IGI', 'IGI_EXP_DU_HOLD');
      l_msg := fnd_message.get;
      wf_engine.SetItemAttrText  ( itemtype => l_itemtype,
                                   itemkey  => l_itemkey,
                                   aname    => 'DU_HOLD',
                                   avalue   => l_msg);

      fnd_message.set_name ('IGI', 'IGI_EXP_DU_NO_APP_ACTION');
      l_msg := fnd_message.get;
      wf_engine.SetItemAttrText  ( itemtype => l_itemtype,
                                   itemkey  => l_itemkey,
                                   aname    => 'DU_NO_APP_ACTION',
                                   avalue   => l_msg);

      fnd_message.set_name ('IGI', 'IGI_EXP_DU_PER_AUTH_ACTION');
      l_msg := fnd_message.get;
      wf_engine.SetItemAttrText  ( itemtype => l_itemtype,
                                   itemkey  => l_itemkey,
                                   aname    => 'DU_PER_AUTH_ACTION',
                                   avalue   => l_msg);

      fnd_message.set_name ('IGI', 'IGI_EXP_LEGAL_NUM_ERROR');
      l_msg := fnd_message.get;
      wf_engine.SetItemAttrText  ( itemtype => l_itemtype,
                                   itemkey  => l_itemkey,
                                   aname    => 'LEGAL_NUM_ERROR',
                                   avalue   => l_msg);

      fnd_message.set_name ('IGI', 'IGI_EXP_NTFY_DU_FAILED');
      l_msg := fnd_message.get;
      wf_engine.SetItemAttrText  ( itemtype => l_itemtype,
                                   itemkey  => l_itemkey,
                                   aname    => 'NTFY_DU_FAILED',
                                   avalue   => l_msg);

      fnd_message.set_name ('IGI', 'IGI_EXP_NTFY_DU_REJECT');
      l_msg := fnd_message.get;
      wf_engine.SetItemAttrText  ( itemtype => l_itemtype,
                                   itemkey  => l_itemkey,
                                   aname    => 'NTFY_DU_REJECT',
                                   avalue   => l_msg);

      fnd_message.set_name ('IGI', 'IGI_EXP_NTFY_LEGAL_DU_REJECT');
      l_msg := fnd_message.get;
      wf_engine.SetItemAttrText  ( itemtype => l_itemtype,
                                   itemkey  => l_itemkey,
                                   aname    => 'NTFY_LEGAL_DU_REJECT',
                                   avalue   => l_msg);

      fnd_message.set_name ('IGI', 'IGI_EXP_NTFY_TU_SUCCESS');
      l_msg := fnd_message.get;
      wf_engine.SetItemAttrText  ( itemtype => l_itemtype,
                                   itemkey  => l_itemkey,
                                   aname    => 'NTFY_TU_SUCCESS',
                                   avalue   => l_msg);

      fnd_message.set_name ('IGI', 'IGI_EXP_TU_ACTION_ASSIGNMENTS');
      l_msg := fnd_message.get;
      wf_engine.SetItemAttrText  ( itemtype => l_itemtype,
                                   itemkey  => l_itemkey,
                                   aname    => 'TU_ACTION_ASSIGNMENTS',
                                   avalue   => l_msg);

      fnd_message.set_name ('IGI', 'IGI_EXP_TU_ACTION_ERROR');
      l_msg := fnd_message.get;
      wf_engine.SetItemAttrText  ( itemtype => l_itemtype,
                                   itemkey  => l_itemkey,
                                   aname    => 'TU_ACTION_ERROR',
                                   avalue   => l_msg);

      fnd_message.set_name ('IGI', 'IGI_EXP_TU_AUTH_ACTION');
      l_msg := fnd_message.get;
      wf_engine.SetItemAttrText  ( itemtype => l_itemtype,
                                   itemkey  => l_itemkey,
                                   aname    => 'TU_AUTH_ACTION',
                                   avalue   => l_msg);

      fnd_message.set_name ('IGI', 'IGI_EXP_TU_DU_AUTH_ACTION');
      l_msg := fnd_message.get;
      wf_engine.SetItemAttrText  ( itemtype => l_itemtype,
                                   itemkey  => l_itemkey,
                                   aname    => 'TU_DU_AUTH_ACTION',
                                   avalue   => l_msg);

      fnd_message.set_name ('IGI', 'IGI_EXP_TU_DU_COMPLETE');
      l_msg := fnd_message.get;
      wf_engine.SetItemAttrText  ( itemtype => l_itemtype,
                                   itemkey  => l_itemkey,
                                   aname    => 'TU_DU_COMPLETE',
                                   avalue   => l_msg);

      fnd_message.set_name ('IGI', 'IGI_EXP_TU_DU_HOLD');
      l_msg := fnd_message.get;
      wf_engine.SetItemAttrText  ( itemtype => l_itemtype,
                                   itemkey  => l_itemkey,
                                   aname    => 'TU_DU_HOLD',
                                   avalue   => l_msg);

      fnd_message.set_name ('IGI', 'IGI_EXP_TU_DU_HOLD_REMOVE');
      l_msg := fnd_message.get;
      wf_engine.SetItemAttrText  ( itemtype => l_itemtype,
                                   itemkey  => l_itemkey,
                                   aname    => 'TU_DU_HOLD_REMOVE',
                                   avalue   => l_msg);

      fnd_message.set_name ('IGI', 'IGI_EXP_TU_DU_NO_APP_ACTION');
      l_msg := fnd_message.get;
      wf_engine.SetItemAttrText  ( itemtype => l_itemtype,
                                   itemkey  => l_itemkey,
                                   aname    => 'TU_DU_NO_APP_ACTION',
                                   avalue   => l_msg);

      fnd_message.set_name ('IGI', 'IGI_EXP_TU_DU_PER_AUTH_ACTION');
      l_msg := fnd_message.get;
      wf_engine.SetItemAttrText  ( itemtype => l_itemtype,
                                   itemkey  => l_itemkey,
                                   aname    => 'TU_DU_PER_AUTH_ACTION',
                                   avalue   => l_msg);

      fnd_message.set_name ('IGI', 'IGI_EXP_TU_DU_REMAIN');
      l_msg := fnd_message.get;
      wf_engine.SetItemAttrText  ( itemtype => l_itemtype,
                                   itemkey  => l_itemkey,
                                   aname    => 'TU_DU_REMAIN',
                                   avalue   => l_msg);

      fnd_message.set_name ('IGI', 'IGI_EXP_TU_DU_REMOVE');
      l_msg := fnd_message.get;
      wf_engine.SetItemAttrText  ( itemtype => l_itemtype,
                                   itemkey  => l_itemkey,
                                   aname    => 'TU_DU_REMOVE',
                                   avalue   => l_msg);

      fnd_message.set_name ('IGI', 'IGI_EXP_TU_EMP_SETUP_ERROR');
      l_msg := fnd_message.get;
      wf_engine.SetItemAttrText  ( itemtype => l_itemtype,
                                   itemkey  => l_itemkey,
                                   aname    => 'TU_EMP_SETUP_ERROR',
                                   avalue   => l_msg);

      fnd_message.set_name ('IGI', 'IGI_EXP_TU_LEGAL_NUM_ERROR');
      l_msg := fnd_message.get;
      wf_engine.SetItemAttrText  ( itemtype => l_itemtype,
                                   itemkey  => l_itemkey,
                                   aname    => 'TU_LEGAL_NUM_ERROR',
                                   avalue   => l_msg);

      fnd_message.set_name ('IGI', 'IGI_EXP_TU_NO_PARENT');
      l_msg := fnd_message.get;
      wf_engine.SetItemAttrText  ( itemtype => l_itemtype,
                                   itemkey  => l_itemkey,
                                   aname    => 'TU_NO_PARENT',
                                   avalue   => l_msg);

      fnd_message.set_name ('IGI', 'IGI_EXP_TU_NO_USER_ERROR');
      l_msg := fnd_message.get;
      wf_engine.SetItemAttrText  ( itemtype => l_itemtype,
                                   itemkey  => l_itemkey,
                                   aname    => 'TU_NO_USER_ERROR',
                                   avalue   => l_msg);

      fnd_message.set_name ('IGI', 'IGI_EXP_TU_NOT_ASSG_POS_ERROR');
      l_msg := fnd_message.get;
      wf_engine.SetItemAttrText  ( itemtype => l_itemtype,
                                   itemkey  => l_itemkey,
                                   aname    => 'TU_NOT_ASSG_POS_ERROR',
                                   avalue   => l_msg);

      fnd_message.set_name ('IGI', 'IGI_EXP_TU_NOT_SETUP_EMP_ERR');
      l_msg := fnd_message.get;
      wf_engine.SetItemAttrText  ( itemtype => l_itemtype,
                                   itemkey  => l_itemkey,
                                   aname    => 'TU_NOT_SETUP_EMP_ERROR',
                                   avalue   => l_msg);

      fnd_message.set_name ('IGI', 'IGI_EXP_TU_PICK_AUTH');
      l_msg := fnd_message.get;
      wf_engine.SetItemAttrText  ( itemtype => l_itemtype,
                                   itemkey  => l_itemkey,
                                   aname    => 'TU_PICK_AUTH',
                                   avalue   => l_msg);

      fnd_message.set_name ('IGI', 'IGI_EXP_TU_PICK_NEW_AUTH');
      l_msg := fnd_message.get;
      wf_engine.SetItemAttrText  ( itemtype => l_itemtype,
                                   itemkey  => l_itemkey,
                                   aname    => 'TU_PICK_NEW_AUTH',
                                   avalue   => l_msg);

      fnd_message.set_name ('IGI', 'IGI_EXP_TU_PICK_NEW_AUTH_LIST');
      l_msg := fnd_message.get;
      wf_engine.SetItemAttrText  ( itemtype => l_itemtype,
                                   itemkey  => l_itemkey,
                                   aname    => 'TU_PICK_NEW_AUTH_LIST',
                                   avalue   => l_msg);

      fnd_message.set_name ('IGI', 'IGI_EXP_TU_POS_ASSG_ERROR');
      l_msg := fnd_message.get;
      wf_engine.SetItemAttrText  ( itemtype => l_itemtype,
                                   itemkey  => l_itemkey,
                                   aname    => 'TU_POS_ASSG_ERROR',
                                   avalue   => l_msg);

      fnd_message.set_name ('IGI', 'IGI_EXP_TU_REQ_AUTHORIZATION');
      l_msg := fnd_message.get;
      wf_engine.SetItemAttrText  ( itemtype => l_itemtype,
                                   itemkey  => l_itemkey,
                                   aname    => 'TU_REQ_AUTHORIZATION',
                                   avalue   => l_msg);

      fnd_message.set_name ('IGI', 'IGI_EXP_TU_RET_ATTN');
      l_msg := fnd_message.get;
      wf_engine.SetItemAttrText  ( itemtype => l_itemtype,
                                   itemkey  => l_itemkey,
                                   aname    => 'TU_RET_ATTN',
                                   avalue   => l_msg);

      fnd_message.set_name ('IGI', 'IGI_EXP_TU_VAL_HIER_POS_ERROR');
      l_msg := fnd_message.get;
      wf_engine.SetItemAttrText  ( itemtype => l_itemtype,
                                   itemkey  => l_itemkey,
                                   aname    => 'TU_VAL_HIER_POS_ERROR',
                                   avalue   => l_msg);

      fnd_message.set_name ('IGI', 'IGI_EXP_TU_VAL_HR_POS_PRF_ERR');
      l_msg := fnd_message.get;
      wf_engine.SetItemAttrText  ( itemtype => l_itemtype,
                                   itemkey  => l_itemkey,
                                   aname    => 'TU_VAL_HIER_POS_PROF_ERROR',
                                   avalue   => l_msg);

      fnd_message.set_name ('IGI', 'IGI_EXP_TU_VALIDATION_ERROR');
      l_msg := fnd_message.get;
      wf_engine.SetItemAttrText  ( itemtype => l_itemtype,
                                   itemkey  => l_itemkey,
                                   aname    => 'TU_VALIDATION_ERROR',
                                   avalue   => l_msg);

      fnd_message.set_name ('IGI', 'IGI_EXP_TU_VALIDATION_HR_ERR');
      l_msg := fnd_message.get;
      wf_engine.SetItemAttrText  ( itemtype => l_itemtype,
                                   itemkey  => l_itemkey,
                                   aname    => 'TU_VALIDATION_HIER_ERROR',
                                   avalue   => l_msg);

      --Bug 5872277 End

      -- Start the workflow process
      wf_engine.StartProcess( itemtype => l_itemtype,
                              itemkey  => l_itemkey);

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Start_approval_workflow.Msg16',
                           ' Start process ');
         DEBUG_LOG_STRING (l_proc_level, 'Start_approval_workflow.Msg17',
                           ' **        END  START_APPROVAL_WORKFLOW     ** ');
      -- =============== END DEBUG LOG ==================

      COMMIT;

   EXCEPTION
      WHEN OTHERS THEN
           -- =============== START DEBUG LOG ================
              DEBUG_LOG_UNEXP_ERROR ('Start_approval_workflow.Unexp1','DEFAULT');
           -- =============== END DEBUG LOG ==================

           wf_core.context('IGI_EXP_APPROVAL_PKG','start_approval_workflow'
                           ,l_itemtype, l_itemkey);
           RAISE;

   END start_approval_workflow;



   -- *************************************************************************
   --    IS_TU_TRANS_EMPLOYEE
   -- *************************************************************************

   PROCEDURE is_tu_trans_employee ( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2) IS

      l_transmitter_fnd_id       NUMBER(15);
      l_transmitter_emp_id       NUMBER(15);
      l_trans_fnd_name           VARCHAR2(240);
      l_transmitter_emp_name     VARCHAR2(240);
      l_display_name             VARCHAR2(240);
      l_validation_error         VARCHAR2(240);

   BEGIN

     -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Is_tu_trans_employee.Msg1',
                           ' ** BEGIN IS_TU_TRANS_EMPLOYEE ** ');
     -- =============== END DEBUG LOG ==================

      IF (funcmode = 'RUN') THEN

         -- Get the fnd user id of the TU transmitter
         l_transmitter_fnd_id
            := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'TRANSMITTER_FND_ID');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Is_tu_trans_employee.Msg2',
                              ' GetItemAttrNumber TRANSMITTER_FND_ID --> ' || l_transmitter_fnd_id);
         -- =============== END DEBUG LOG ==================

         -- Get the employee id of the transmitter
         SELECT employee_id
         INTO   l_transmitter_emp_id
         FROM   fnd_user
         WHERE  user_id = l_transmitter_fnd_id;

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Is_tu_trans_employee.Msg3',
                              ' Get the employee id of the transmitter - '
                              || ' l_transmitter_emp_id --> ' || l_transmitter_emp_id);
         -- =============== END DEBUG LOG ==================

         IF (l_transmitter_emp_id is null) THEN

            -- TU Transmitter is not an employee, so set result to 'No'
            result := 'COMPLETE:N';

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Is_tu_trans_employee.Msg4',
                                 ' l_transmitter_emp_id is null - result --> ' || result);
            -- =============== END DEBUG LOG ==================


         ELSE  -- TU Transmitter is an employee

            -- Set the transmitter_emp_id attribute
            wf_engine.SetItemAttrNumber( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'TRANSMITTER_EMP_ID',
                                         avalue   => l_transmitter_emp_id);

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Is_tu_trans_employee.Msg5',
                                 ' SetItemAttrNumber TRANSMITTER_EMP_ID --> '|| l_transmitter_emp_id);
            -- =============== END DEBUG LOG ==================

            -- Get the employee name of the transmitter
            wf_directory.GetUserName(p_orig_system    => 'PER',
                                     p_orig_system_id => l_transmitter_emp_id,
                                     p_name           => l_transmitter_emp_name,
                                     p_display_name   => l_display_name );

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Is_tu_trans_employee.Msg6',
                                 ' GetUserName --> l_transmitter_emp_name -> ' || l_transmitter_emp_name
                                 ||' l_display_name -> ' || l_display_name );
            -- =============== END DEBUG LOG ==================

            -- Set the transmitter_emp_name attribute
            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'TRANSMITTER_EMP_NAME',
                                         avalue   => l_transmitter_emp_name);

            -- Note: No need to set a display name attribute since workflow 2.6 automatically
            -- retrieves the display name for messages

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Is_tu_trans_employee.Msg7',
                                 ' SetItemAttrText TRANSMITTER_EMP_NAME --> ' || l_transmitter_emp_name);
            -- =============== END DEBUG LOG ==================

            -- TU Transmitter is an employee, so set result to 'Yes'
            result := 'COMPLETE:Y';

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Is_tu_trans_employee.Msg8',
                                 ' result --> ' || result);
            -- =============== END DEBUG LOG ==================

         END IF;

      END IF;

      IF (funcmode <> 'RUN') THEN
         result := 'COMPLETE';
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Is_tu_trans_employee.Msg9',
                              ' funcmode <> RUN - result --> ' || result);
         -- =============== END DEBUG LOG ==================

         RETURN;
      END IF;

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Is_tu_trans_employee.Msg10',
                           ' ** END IS_TU_TRANS_EMPLOYEE ** ');
      -- =============== END DEBUG LOG ==================

   EXCEPTION
      WHEN OTHERS THEN
           -- =============== START DEBUG LOG ================
              DEBUG_LOG_UNEXP_ERROR ('Start_approval_workflow.Unexp1','DEFAULT');
           -- =============== END DEBUG LOG ==================

           wf_core.context('IGI_EXP_APPROVAL_PKG','is_tu_trans_employee',itemtype,itemkey,
                           to_char(actid),funcmode);
           RAISE;
   END is_tu_trans_employee;



   -- *************************************************************************
   --    EMP_HAS_POSITION
   -- *************************************************************************

   PROCEDURE emp_has_position     ( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2) IS

      CURSOR c_get_position(p_emp_id per_employees_current_x.employee_id%TYPE)
      IS
         SELECT hap.position_id,
                hap.name,
                hap.business_group_id,
                hap.organization_id
         FROM   hr_all_positions_f      hap,
                per_all_assignments_f   paa,
                per_employees_current_x pec
         WHERE  pec.employee_id = p_emp_id
         AND    NVL(pec.inactive_date,SYSDATE) >= SYSDATE
         AND    pec.business_group_id = paa.business_group_id
         AND    pec.assignment_id = paa.assignment_id
         AND    pec.organization_id = paa.organization_id
         AND    paa.assignment_type = 'E'
         AND    paa.effective_start_date <= SYSDATE
         AND    paa.effective_end_date >= SYSDATE
         AND    paa.business_group_id = hap.business_group_id
         AND    paa.position_id IS NOT NULL
         AND    paa.position_id = hap.position_id
         AND    paa.organization_id = hap.organization_id
         AND    hap.date_effective <= SYSDATE
         AND    NVL(hap.date_end, SYSDATE) >= SYSDATE
         AND    NVL(UPPER(hap.status), 'VALID') NOT IN ('INVALID');

      l_position_id        hr_all_positions_f.position_id%TYPE;
      l_position_name      hr_all_positions_f.name%TYPE;
      l_business_group_id  hr_all_positions_f.business_group_id%TYPE;
      l_organization_id    hr_all_positions_f.organization_id%TYPE;
      l_transmitter_emp_id per_employees_current_x.employee_id%TYPE;

   BEGIN

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Emp_has_position.Msg1',
                           ' ** BEGIN EMP_HAS_POSITION ** ');
      -- =============== END DEBUG LOG ==================

      IF (funcmode = 'RUN') THEN

         -- Get the employee id for the TU Transmitter
         l_transmitter_emp_id
            := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'TRANSMITTER_EMP_ID');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Emp_has_position.Msg2',
                              ' GetItemAttrNumber TRANSMITTER_EMP_ID --> '|| l_transmitter_emp_id);
         -- =============== END DEBUG LOG ==================

         OPEN c_get_position(l_transmitter_emp_id);
         FETCH c_get_position INTO l_position_id
                                  ,l_position_name
                                  ,l_business_group_id
                                  ,l_organization_id;

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Emp_has_position.Msg3',
                              ' Getting position : l_position_id --> ' || l_position_id ||
                              ' l_position_name --> ' || l_position_name ||
                              ' l_business_group_id --> ' || l_business_group_id ||
                              ' l_organization_id --> ' || l_organization_id);
         -- =============== END DEBUG LOG ==================

         IF (c_get_position%NOTFOUND) THEN
            -- No rows returned so the employee is not assigned to a position
            -- TU Transmitter is an employee, but is not assigned to a position
            -- so set result to 'No'
            result := 'COMPLETE:N';

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Emp_has_position.Msg4',
                                 ' result --> ' || result);
            -- =============== END DEBUG LOG ==================

         ELSE  -- TU Transmitter is an employee, and has been assigned a position

            -- Set the transmitter_position_id attribute
            wf_engine.SetItemAttrNumber( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'TRANSMITTER_POSITION_ID',
                                         avalue   => l_position_id);

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Emp_has_position.Msg5',
                                 ' SetItemAttrNumber TRANSMITTER_POSITION_ID --> '|| l_position_id);
            -- =============== END DEBUG LOG ==================

            -- Set the business_group_id attribute
            wf_engine.SetItemAttrNumber( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'BUSINESS_GROUP_ID',
                                         avalue   => l_business_group_id);

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Emp_has_position.Msg6',
                                 ' SetItemAttrNumber BUSINESS_GROUP_ID --> ' ||l_business_group_id );
            -- =============== END DEBUG LOG ==================

            -- Set the organization_id attribute
            wf_engine.SetItemAttrNumber( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ORGANIZATION_ID',
                                         avalue   => l_organization_id);

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Emp_has_position.Msg7',
                                 ' SetItemAttrNumber ORGANIZATION_ID --> ' || l_organization_id);
            -- =============== END DEBUG LOG ==================

            -- Set the current_position_id attribute to the position id of the transmitter
            wf_engine.SetItemAttrNumber( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'CURRENT_POSITION_ID',
                                         avalue   => l_position_id);

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Emp_has_position.Msg8',
                                 ' SetItemAttrNumber CURRENT_POSITION_ID --> '|| l_position_id);
            -- =============== END DEBUG LOG ==================

            -- Set the current_position_name attribute to the position name of the transmitter
            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'CURRENT_POSITION_NAME',
                                         avalue   => l_position_name);

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Emp_has_position.Msg9',
                                 ' SetItemAttrText CURRENT_POSITION_NAME --> '||l_position_name );
            -- =============== END DEBUG LOG ==================

            -- TU Transmitter is an employee, and is assigned to a position
            -- so set result to 'Yes'
            result := 'COMPLETE:Y';

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Emp_has_position.Msg10',
                                 ' result --> ' || result);
            -- =============== END DEBUG LOG ==================

         END IF;

         IF (c_get_position%ISOPEN) THEN
            close c_get_position;
         END IF;

      END IF;

      IF (funcmode <> 'RUN') THEN
         result := 'COMPLETE';
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Emp_has_position.Msg11',
                              ' funcmode <> RUN - result --> ' || result);
         -- =============== END DEBUG LOG ==================

         return;
      END IF;

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Emp_has_position.Msg12',
                           ' ** END EMP_HAS_POSITION ** ');
      -- =============== END DEBUG LOG ==================

   EXCEPTION
      WHEN OTHERS THEN
           -- =============== START DEBUG LOG ================
              DEBUG_LOG_UNEXP_ERROR ('Emp_has_position.Unexp1','DEFAULT');
           -- =============== END DEBUG LOG ==================

           wf_core.context('IGI_EXP_APPROVAL_PKG','emp_has_position',itemtype,itemkey,
                           to_char(actid),funcmode);
           RAISE;

   END emp_has_position;



   -- *************************************************************************
   --    POSITION_IN_HIERARCHY
   -- *************************************************************************

   PROCEDURE position_in_hierarchy( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2) IS

      l_tu_id                    igi_exp_tus.tu_id%TYPE;
      l_position_id              per_all_positions.position_id%TYPE;
      l_apprv_profile_id         igi_exp_tus.apprv_profile_id%TYPE;
      l_pos_hierarchy_id         igi_exp_apprv_profiles.pos_hierarchy_id%TYPE;
      l_legal_num_pos_id         igi_exp_apprv_profiles.legal_num_pos_id%TYPE;
      l_final_apprv_pos_id       igi_exp_apprv_profiles.final_apprv_pos_id%TYPE;
      l_business_group_id        hr_all_positions_f.business_group_id%TYPE;
      l_pos_structure_version_id per_pos_structure_versions.pos_structure_version_id%TYPE;
      l_pos_structure_element_id per_pos_structure_elements.pos_structure_element_id%TYPE;

      --
      -- Find the current version of the position hierarchy
      --
      CURSOR c_get_pos_hier_ver(p_hierarchy_id per_pos_structure_versions.position_structure_id%TYPE,
                                p_business_group_id hr_all_positions_f.business_group_id%TYPE)
      IS
         SELECT pos_structure_version_id
         FROM   per_pos_structure_versions
         WHERE  position_structure_id = p_hierarchy_id
         AND    sysdate BETWEEN date_from AND NVL(date_to, sysdate)
         AND    business_group_id = p_business_group_id
         AND    version_number =
           (SELECT MAX(version_number)
            FROM   per_pos_structure_versions
            WHERE  position_structure_id = p_hierarchy_id
            AND    sysdate BETWEEN date_from AND NVL(date_to,sysdate)
            AND    business_group_id = p_business_group_id);

      --
      -- Find out NOCOPY if the position exists as a subordinate position in the current
      -- version of the position hierarchy
      --
      CURSOR c_is_pos_subord(p_pos_structure_ver_id per_pos_structure_elements.pos_structure_version_id%TYPE
                            ,p_business_group_id hr_all_positions_f.business_group_id%TYPE
                            ,p_position_id per_all_positions.position_id%TYPE)
      IS
         SELECT pos_structure_element_id
         FROM   per_pos_structure_elements
         WHERE  pos_structure_version_id = p_pos_structure_ver_id
         AND    business_group_id = p_business_group_id
         AND    subordinate_position_id = p_position_id;

      --
      -- Find out NOCOPY if the position exists as a parent position in the current
      -- version of the position hierarchy
      --
      CURSOR c_is_pos_parent(p_pos_structure_ver_id per_pos_structure_elements.pos_structure_version_id%TYPE
                            ,p_business_group_id hr_all_positions_f.business_group_id%TYPE
                            ,p_position_id per_all_positions.position_id%TYPE)
      IS
         SELECT pos_structure_element_id
         FROM   per_pos_structure_elements
         WHERE  pos_structure_version_id = p_pos_structure_ver_id
         AND    business_group_id = p_business_group_id
         AND    parent_position_id = p_position_id;

      e_pos_hier_ver_not_found EXCEPTION;

   BEGIN

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Position_in_hierarchy.Msg1',
                           ' ** BEGIN POSITION_IN_HIERARCHY ** ');
      -- =============== END DEBUG LOG ==================

      IF (funcmode = 'RUN') THEN

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Position_in_hierarchy.Msg2',
                              ' funcmode = RUN ');
         -- =============== END DEBUG LOG ==================

         -- Need to check that the transmitter's position exists in the position
         -- hierarchy attached to the approval profile chosen for the TU.

         -- First get the TU id
         l_tu_id
            := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'TU_ID');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Position_in_hierarchy.Msg3',
                              ' GetItemAttrNumber TU_ID --> '|| l_tu_id);
         -- =============== END DEBUG LOG ==================

         -- Fetch the position id of the transmitter
         l_position_id
            := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'TRANSMITTER_POSITION_ID');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Position_in_hierarchy.Msg4',
                              ' GetItemAttrNumber TRANSMITTER_POSITION_ID --> '|| l_position_id);
         -- =============== END DEBUG LOG ==================

         -- Now get the approval profile id chosen for the TU.
         SELECT apprv_profile_id
         INTO   l_apprv_profile_id
         FROM   igi_exp_tus
         WHERE  tu_id = l_tu_id;

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Position_in_hierarchy.Msg5',
                              ' l_apprv_profile_id --> ' || l_apprv_profile_id);
         -- =============== END DEBUG LOG ==================

         -- Fetch the approval profile information
         -- i.e. the HR position hierarchy, the legal numbering position
         -- and the final approver position
         SELECT pos_hierarchy_id
               ,legal_num_pos_id
               ,final_apprv_pos_id
         INTO   l_pos_hierarchy_id
               ,l_legal_num_pos_id
               ,l_final_apprv_pos_id
         FROM   igi_exp_apprv_profiles
         WHERE  apprv_profile_id = l_apprv_profile_id;

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Position_in_hierarchy.Msg6',
                              ' l_pos_hierarchy_id --> ' || l_pos_hierarchy_id
                            ||' l_legal_num_pos_id --> ' || l_legal_num_pos_id
                            ||' l_final_apprv_pos_id --> ' || l_final_apprv_pos_id);
         -- =============== END DEBUG LOG ==================

         -- Set the corresponding workflow attributes with this information

         -- Set the pos_structure_id attribute
         wf_engine.SetItemAttrNumber( itemtype => itemtype,
                                      itemkey  => itemkey,
                                      aname    => 'POS_STRUCTURE_ID',
                                      avalue   => l_pos_hierarchy_id);

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Position_in_hierarchy.Msg7',
                              ' SetItemAttrNumber POS_STRUCTURE_ID --> '|| l_pos_hierarchy_id);
         -- =============== END DEBUG LOG ==================

         -- Set the legal_num_pos_id attribute
         wf_engine.SetItemAttrNumber( itemtype => itemtype,
                                      itemkey  => itemkey,
                                      aname    => 'LEGAL_NUM_POS_ID',
                                      avalue   => l_legal_num_pos_id);

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Position_in_hierarchy.Msg8',
                              ' SetItemAttrNumber LEGAL_NUM_POS_ID --> '|| l_legal_num_pos_id);
         -- =============== END DEBUG LOG ==================

         -- Set the final_apprv_pos_id attribute
         wf_engine.SetItemAttrNumber( itemtype => itemtype,
                                      itemkey  => itemkey,
                                      aname    => 'FINAL_APPRV_POS_ID',
                                      avalue   => l_final_apprv_pos_id);

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Position_in_hierarchy.Msg9',
                              'SetItemAttrNumber FINAL_APPRV_POS_ID --> ' || l_final_apprv_pos_id );
         -- =============== END DEBUG LOG ==================

         -- Now need to find the current version of the position hierarchy.

         -- Get the business group id
         l_business_group_id
            := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'BUSINESS_GROUP_ID');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Position_in_hierarchy.Msg10',
                              ' GetItemAttrNumber BUSINESS_GROUP_ID --> ' ||l_business_group_id );
            DEBUG_LOG_STRING (l_proc_level, 'Position_in_hierarchy.Msg11',
                              ' calling c_get_pos_hier_ver with '
                              ||' l_pos_hierarchy_id --> ' || l_pos_hierarchy_id
                              ||' l_business_group_id --> ' || l_business_group_id);
         -- =============== END DEBUG LOG ==================

         OPEN c_get_pos_hier_ver(l_pos_hierarchy_id
                                ,l_business_group_id);
         FETCH c_get_pos_hier_ver INTO l_pos_structure_version_id;

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Position_in_hierarchy.Msg12',
                              ' l_pos_structure_version_id --> '|| l_pos_structure_version_id);
         -- =============== END DEBUG LOG ==================

         IF (c_get_pos_hier_ver%NOTFOUND) THEN

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Position_in_hierarchy.Msg13',
                                 ' c_get_pos_hier_ver%NOTFOUND raise e_pos_hier_ver_not_found ');
            -- =============== END DEBUG LOG ==================
            RAISE e_pos_hier_ver_not_found;

         END IF;

         CLOSE c_get_pos_hier_ver;

         -- Set the pos_structure_version_id attribute
         wf_engine.SetItemAttrNumber( itemtype => itemtype,
                                      itemkey  => itemkey,
                                      aname    => 'POS_STRUCTURE_VERSION_ID',
                                      avalue   => l_pos_structure_version_id);


         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Position_in_hierarchy.Msg14',
                              ' SetItemAttrNumber POS_STRUCTURE_VERSION_ID --> ' ||l_pos_structure_version_id);
         -- =============== END DEBUG LOG ==================

         -- Now need to find if the transmitter's position exists in the
         -- current version of the hierarchy

          -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Position_in_hierarchy.Msg15',
                              ' calling c_is_pos_subord cursor with '
                            ||' l_pos_structure_version_id --> ' || l_pos_structure_version_id
                            ||' l_business_group_id --> ' || l_business_group_id
                            ||' l_position_id --> ' || l_position_id);
         -- =============== END DEBUG LOG ==================

        -- Find out NOCOPY if the position is a subordinate position in the current version
         OPEN c_is_pos_subord(l_pos_structure_version_id
                             ,l_business_group_id
                             ,l_position_id);
         FETCH c_is_pos_subord INTO l_pos_structure_element_id;

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Position_in_hierarchy.Msg16',
                              ' l_pos_structure_element_id --> ' || l_pos_structure_element_id);
         -- =============== END DEBUG LOG ==================

         IF (c_is_pos_subord%NOTFOUND) THEN

            CLOSE c_is_pos_subord;

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Position_in_hierarchy.Msg17',
                                 ' c_is_pos_subord%NOTFOUND - TRUE ');
            -- =============== END DEBUG LOG ==================

            -- It is possible that the transmitter's position is the top position
            -- in the HR hierarchy, in which case it would not appear in the
            -- subordinate_position_id column.
            -- So check if the position appears in the parent_position_id column
            -- for the hierarchy

            -- =============== START DEBUG LOG ================
              DEBUG_LOG_STRING (l_proc_level, 'Position_in_hierarchy.Msg18',
                                ' calling c_is_pos_parent cursor with ' ||
                                ' l_pos_structure_version_id --> ' || l_pos_structure_version_id ||
                                ' l_business_group_id --> ' || l_business_group_id ||
                                ' l_position_id --> ' || l_position_id);
            -- =============== END DEBUG LOG ==================

            OPEN c_is_pos_parent(l_pos_structure_version_id
                                ,l_business_group_id
                                ,l_position_id);
            FETCH c_is_pos_parent INTO l_pos_structure_element_id;

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Position_in_hierarchy.Msg19',
                                 ' l_pos_structure_element_id --> ' || l_pos_structure_element_id);
            -- =============== END DEBUG LOG ==================

            IF (c_is_pos_parent%NOTFOUND) THEN
               CLOSE c_is_pos_parent;

               -- The position does not exist in the hierarchy.
               -- So set result to 'No' and exit
               --
               result := 'COMPLETE:N';

               -- =============== START DEBUG LOG ================
                  DEBUG_LOG_STRING (l_proc_level, 'Position_in_hierarchy.Msg20',
                                    ' c_is_pos_parent%NOTFOUND - result --> ' || result);
               -- =============== END DEBUG LOG ==================

               return;
            END IF;
            CLOSE c_is_pos_parent;

            -- The position is the top position in the hierarchy
            -- so continue

         ELSE

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Position_in_hierarchy.Msg21',
                                 ' In the else part, CLOSE c_is_pos_subord ');
            -- =============== END DEBUG LOG ==================

            CLOSE c_is_pos_subord;

      END IF;

         -- The position exists in the hierarchy.
         -- Set the pos_structure_element_id for reference purposes.

         -- Set the pos_structure_element_id attribute
         wf_engine.SetItemAttrNumber( itemtype => itemtype,
                                      itemkey  => itemkey,
                                      aname    => 'POS_STRUCTURE_ELEMENT_ID',
                                      avalue   => l_pos_structure_element_id);

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Position_in_hierarchy.Msg22',
                              ' SetItemAttrNumber  POS_STRUCTURE_ELEMENT_ID --> ' || l_pos_structure_element_id);
         -- =============== END DEBUG LOG ==================

         -- Set result to 'Yes'
         result := 'COMPLETE:Y';

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Position_in_hierarchy.Msg23',
                              ' result --> '|| result);
         -- =============== END DEBUG LOG ==================

      END IF;

      IF (funcmode <> 'RUN') THEN
         result := 'COMPLETE';
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Position_in_hierarchy.Msg24',
                              ' funcmode <> RUN - result --> '|| result);
         -- =============== END DEBUG LOG ==================
         return;
      END IF;

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Position_in_hierarchy.Msg25',
                           ' ** END POSITION_IN_HIERARCHY ** ');
      -- =============== END DEBUG LOG ==================

   EXCEPTION
      WHEN e_pos_hier_ver_not_found THEN
           -- =============== START DEBUG LOG ================
              DEBUG_LOG_STRING (l_proc_level, 'Position_in_hierarchy.Msg26',
                                ' Inside Exception e_pos_hier_ver_not_found ');
           -- =============== END DEBUG LOG ==================
           wf_core.context('IGI_EXP_APPROVAL_PKG','position_in_hierarchy',itemtype,itemkey,
                           to_char(actid),funcmode,'Position hierarchy version not found');
           IF (c_get_pos_hier_ver%ISOPEN) THEN
              CLOSE c_get_pos_hier_ver;
           END IF;
           raise;

      WHEN OTHERS THEN
           -- =============== START DEBUG LOG ================
              DEBUG_LOG_UNEXP_ERROR ('Position_in_hierarchy.Unexp1','DEFAULT');
           -- =============== END DEBUG LOG ==================
           wf_core.context('IGI_EXP_APPROVAL_PKG','position_in_hierarchy',itemtype,itemkey,
                           to_char(actid),funcmode);
           raise;

   END position_in_hierarchy;


   -- *************************************************************************
   --    IS_POSITION_GT_FINAL_POS
   -- *************************************************************************

   PROCEDURE is_position_gt_final_pos ( itemtype IN  VARCHAR2,
                                        itemkey  IN  VARCHAR2,
                                        actid    IN  NUMBER,
                                        funcmode IN  VARCHAR2,
                                        result   OUT NOCOPY VARCHAR2) IS

     CURSOR c_get_parent_position(p_position_id per_all_positions.position_id%TYPE
                                 ,p_pos_structure_version_id per_pos_structure_versions.pos_structure_version_id%TYPE
                                 ,p_business_group_id hr_all_positions_f.business_group_id%TYPE)
     IS
        SELECT parent_position_id
        FROM   per_pos_structure_elements
        WHERE  pos_structure_version_id = p_pos_structure_version_id
        AND    business_group_id = p_business_group_id
        AND    subordinate_position_id = p_position_id;

      l_position_id              per_all_positions.position_id%TYPE;
      l_transmitter_position_id  per_all_positions.position_id%TYPE;
      l_parent_pos_id            per_all_positions.position_id%TYPE;
      l_final_apprv_pos_id       igi_exp_apprv_profiles.final_apprv_pos_id%TYPE;
      l_business_group_id        hr_all_positions_f.business_group_id%TYPE;
      l_pos_structure_version_id per_pos_structure_versions.pos_structure_version_id%TYPE;
      l_final_apprv_found        VARCHAR2(1) := 'N';

   BEGIN

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Is_position_gt_final_pos.Msg1',
                           ' ** BEGIN IS_POSITION_GT_FINAL_POS ** ');
      -- =============== END DEBUG LOG ==================

      IF (funcmode = 'RUN') THEN


         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Is_position_gt_final_pos.Msg2',
                              ' funcmode = RUN ');
         -- =============== END DEBUG LOG ==================

         -- Want to find out NOCOPY if the TU transmitter's position is higher in the
         -- hierarchy than the final approver position set up for the approval
         -- profile. If this is the case, we should exit out NOCOPY of the approval workflow
         -- If the TU transmitter's position IS the final position
         -- it is ok to continue with the workflow approval.

         -- Get the values of the attributes needed:
         -- Position structure version, transmitter's position, final approver position
         -- and business group.

         l_pos_structure_version_id
            := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'POS_STRUCTURE_VERSION_ID');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Is_position_gt_final_pos.Msg3',
                              ' ** BEGIN IS_POSITION_GT_FINAL_POS ** ');
         -- =============== END DEBUG LOG ==================

         l_business_group_id
            := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'BUSINESS_GROUP_ID');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Is_position_gt_final_pos.Msg4',
                              ' GetItemAttrNumber BUSINESS_GROUP_ID --> '|| l_business_group_id);
         -- =============== END DEBUG LOG ==================

         l_transmitter_position_id
            := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'TRANSMITTER_POSITION_ID');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Is_position_gt_final_pos.Msg5',
                              ' GetItemAttrNumber TRANSMITTER_POSITION_ID --> ' || l_transmitter_position_id);
         -- =============== END DEBUG LOG ==================

         l_final_apprv_pos_id
            := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'FINAL_APPRV_POS_ID');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Is_position_gt_final_pos.Msg6',
                              ' GetItemAttrNumber FINAL_APPRV_POS_ID --> ' || l_final_apprv_pos_id);
         -- =============== END DEBUG LOG ==================

         -- Starting from the transmitter's position, loop through the hierarchy
         -- until either the final approver position (as defined in the EXP approval
         -- profile) is found or the top position in the hierarchy is reached.

         -- Check if the transmitter's position IS the final approver position first
         IF (l_transmitter_position_id = l_final_apprv_pos_id) THEN

            l_final_apprv_found := 'Y';

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Is_position_gt_final_pos.Msg7',
                                 ' l_transmitter_position_id = l_final_apprv_pos_id ');
               DEBUG_LOG_STRING (l_proc_level, 'Is_position_gt_final_pos.Msg8',
                                 ' l_final_apprv_found --> ' || l_final_apprv_found);
            -- =============== END DEBUG LOG ==================

         ELSE

            -- Set the initial value of position_id to the transmitter's position
            l_position_id := l_transmitter_position_id;

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Is_position_gt_final_pos.Msg9',
                                 ' l_position_id --> ' || l_position_id);
            -- =============== END DEBUG LOG ==================

            LOOP

               -- =============== START DEBUG LOG ================
                  DEBUG_LOG_STRING (l_proc_level, 'Is_position_gt_final_pos.Msg10',
                                    ' Cursor c_get_parent_position with ' ||
                                    ' l_position_id --> ' || l_position_id ||
                                    ' l_pos_structure_version_id -> ' || l_pos_structure_version_id ||
                                    ' l_business_group_id --> ' || l_business_group_id);
               -- =============== END DEBUG LOG ==================

               OPEN c_get_parent_position(l_position_id
                                         ,l_pos_structure_version_id
                                         ,l_business_group_id);

               FETCH c_get_parent_position INTO l_parent_pos_id;

               -- =============== START DEBUG LOG ================
                  DEBUG_LOG_STRING (l_proc_level, 'Is_position_gt_final_pos.Msg11',
                                    ' l_parent_pos_id --> ' || l_parent_pos_id);
               -- =============== END DEBUG LOG ==================

               EXIT WHEN c_get_parent_position%NOTFOUND;
               CLOSE c_get_parent_position;

               IF (l_parent_pos_id = l_final_apprv_pos_id) THEN

                  -- =============== START DEBUG LOG ================
                     DEBUG_LOG_STRING (l_proc_level, 'Is_position_gt_final_pos.Msg12',
                                       ' l_parent_pos_id = l_final_apprv_pos_id ');
                  -- =============== END DEBUG LOG ==================

                  l_final_apprv_found := 'Y';
                  -- =============== START DEBUG LOG ================
                     DEBUG_LOG_STRING (l_proc_level, 'Is_position_gt_final_pos.Msg13',
                                       ' l_final_apprv_found --> ' || l_final_apprv_found);
                  -- =============== END DEBUG LOG ==================

                  EXIT;

               ELSE -- parent position is not final approver position

                  -- set the new position to the parent position for next iteration in loop
                  l_position_id := l_parent_pos_id;

                  -- =============== START DEBUG LOG ================
                     DEBUG_LOG_STRING (l_proc_level, 'Is_position_gt_final_pos.Msg14',
                                       ' l_position_id --> ' || l_position_id);
                  -- =============== END DEBUG LOG ==================

               END IF;

            END LOOP;

            IF (c_get_parent_position%ISOPEN) THEN
               CLOSE c_get_parent_position;
            END IF;

         END IF;  -- End check for transmitter's position = final approver position

         IF (l_final_apprv_found = 'Y') THEN

            -- The transmitter's position is NOT higher than the final approver position
            -- So set result to 'No'
            result := 'COMPLETE:N';

             -- =============== START DEBUG LOG ================
                DEBUG_LOG_STRING (l_proc_level, 'Is_position_gt_final_pos.Msg15',
                                  ' l_final_apprv_found = Y -- result --> ' || result);
             -- =============== END DEBUG LOG ==================

         ELSE  -- (l_final_apprv_found = ='N')

            -- The transmitter's position IS higher than the final approver position
            -- So set result to 'Yes'
            result := 'COMPLETE:Y';

             -- =============== START DEBUG LOG ================
                DEBUG_LOG_STRING (l_proc_level, 'Is_position_gt_final_pos.Msg16',
                                  ' l_final_apprv_found != Y -- result --> ' || result);
             -- =============== END DEBUG LOG ==================

         END IF;

      END IF;

      IF (funcmode <> 'RUN') THEN
         result := 'COMPLETE';
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Is_position_gt_final_pos.Msg17',
                              ' funcmode <> RUN -- result --> ' || result);
         -- =============== END DEBUG LOG ==================
         return;
      END IF;

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Is_position_gt_final_pos.Msg18',
                           ' ** END IS_POSITION_GT_FINAL_POS ** ');
      -- =============== END DEBUG LOG ==================

   EXCEPTION
      WHEN OTHERS THEN
           -- =============== START DEBUG LOG ================
              DEBUG_LOG_UNEXP_ERROR ('Is_position_gt_final_pos.Unexp1','DEFAULT');
           -- =============== END DEBUG LOG ==================
           wf_core.context('IGI_EXP_APPROVAL_PKG','is_position_gt_final_pos',itemtype,itemkey,
                           to_char(actid),funcmode);
           raise;
   END is_position_gt_final_pos;

   -- *************************************************************************
   --    UPDATE_TU_STATUS_TO_AVL
   -- *************************************************************************

   PROCEDURE update_tu_status_to_avl ( itemtype IN  VARCHAR2,
                                       itemkey  IN  VARCHAR2,
                                       actid    IN  NUMBER,
                                       funcmode IN  VARCHAR2,
                                       result   OUT NOCOPY VARCHAR2) IS

      l_tu_id  NUMBER;

   BEGIN

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Update_tu_status_to_avl.Msg1',
                           ' ** BEGIN UPDATE_TU_STATUS_TO_AVL ** ');
      -- =============== END DEBUG LOG ==================

      IF (funcmode = 'RUN') THEN

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Update_tu_status_to_avl.Msg2',
                              ' funcmode = RUN ');
         -- =============== END DEBUG LOG ==================

         -- The initial validation failed for the TU transmitter
         -- so set the status of the TU back to 'Available' before
         -- exiting from workflow so the TU can be modified
         -- (e.g. by changing the TU approval profile used) and
         -- transmitted again.

         -- Get the tu id
         l_tu_id
            := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'TU_ID');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Update_tu_status_to_avl.Msg3',
                              ' GetItemAttrNumber TU_ID --> '|| l_tu_id);
         -- =============== END DEBUG LOG ==================

         -- Update the status of the TU to 'AVL' for 'Available'
         UPDATE igi_exp_tus tus
         SET    tus.tu_status = 'AVL'
         WHERE  tus.tu_id = l_tu_id;

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Update_tu_status_to_avl.Msg4',
                              ' UPDATE igi_exp_tus tu_status = AVL ');
         -- =============== END DEBUG LOG ==================

      END IF;

      IF (funcmode <> 'RUN') THEN
         result := 'COMPLETE';
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Update_tu_status_to_avl.Msg5',
                              ' funcmode = RUN -- result --> ' || result);
         -- =============== END DEBUG LOG ==================
         return;
      END IF;

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Update_tu_status_to_avl.Msg6',
                           ' ** END UPDATE_TU_STATUS_TO_AVL ** ');
      -- =============== END DEBUG LOG ==================

   EXCEPTION
      WHEN OTHERS THEN
           -- =============== START DEBUG LOG ================
              DEBUG_LOG_UNEXP_ERROR ('Update_tu_status_to_avl.Unexp1','DEFAULT');
           -- =============== END DEBUG LOG ==================
           wf_core.context('IGI_EXP_APPROVAL_PKG','update_tu_status_to_avl',itemtype,itemkey,
                           to_char(actid),funcmode);
           raise;
   END update_tu_status_to_avl;



   -- *************************************************************************
   --    UPDATE_DUS_TO_IN_A_TU
   -- *************************************************************************

   PROCEDURE update_dus_to_in_a_tu   ( itemtype IN  VARCHAR2,
                                       itemkey  IN  VARCHAR2,
                                       actid    IN  NUMBER,
                                       funcmode IN  VARCHAR2,
                                       result   OUT NOCOPY VARCHAR2) IS

      l_tu_id  igi_exp_dus.tu_id%TYPE;

   BEGIN

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Update_dus_to_in_a_tu.Msg1',
                           ' ** BEGIN UPDATE_DUS_TO_IN_A_TU ** ');
      -- =============== END DEBUG LOG ==================

      IF (funcmode = 'RUN') THEN

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Update_dus_to_in_a_tu.Msg2',
                              ' funcmode = RUN ');
         -- =============== END DEBUG LOG ==================

         -- The initial validation failed for the TU transmitter
         -- So the status of the TU was set back to 'Available'
         -- and the status of the DUs must be set back
         -- to 'In a Transmission Unit' before
         -- exiting from workflow so the TU can be modified
         -- (e.g. by changing the TU approval profile used) and
         -- transmitted again.

         -- Get the tu id
         l_tu_id
            := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'TU_ID');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Update_dus_to_in_a_tu.Msg3',
                              ' GetItemAttrNumber TU_ID --> ' || l_tu_id);
         -- =============== END DEBUG LOG ==================

         -- Update the status of the DUs in the TU
         -- to 'ITU' for 'In a Transmission Unit'

         UPDATE igi_exp_dus dus
         SET    dus.du_status = 'ITU'
         WHERE  dus.tu_id = l_tu_id;

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Update_dus_to_in_a_tu.Msg4',
                              ' UPDATE igi_exp_dus du_status = ITU ');
         -- =============== END DEBUG LOG ==================

      END IF;

      IF (funcmode <> 'RUN') THEN
         result := 'COMPLETE';
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Update_dus_to_in_a_tu.Msg5',
                              ' funcmode = RUN -- result -->  ' || result);
         -- =============== END DEBUG LOG ==================
         return;
      END IF;

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Update_dus_to_in_a_tu.Msg6',
                           ' ** END UPDATE_DUS_TO_IN_A_TU ** ');
      -- =============== END DEBUG LOG ==================

   EXCEPTION
      WHEN OTHERS THEN
           -- =============== START DEBUG LOG ================
              DEBUG_LOG_UNEXP_ERROR ('Update_tu_status_to_avl.Unexp1','DEFAULT');
           -- =============== END DEBUG LOG ==================
           wf_core.context('IGI_EXP_APPROVAL_PKG','update_dus_to_in_a_tu',itemtype,itemkey,
                           to_char(actid),funcmode);
           raise;
   END update_dus_to_in_a_tu;


   -- *************************************************************************
   --    BUILD_USER_LIST
   -- *************************************************************************

   PROCEDURE build_user_list         ( itemtype IN  VARCHAR2,
                                       itemkey  IN  VARCHAR2,
                                       actid    IN  NUMBER,
                                       funcmode IN  VARCHAR2,
                                       result   OUT NOCOPY VARCHAR2) IS

      l_user_count             NUMBER:= 0;
      l_user_list              VARCHAR2(1000);
      l_user_name              fnd_user.user_name%TYPE;
      l_user_id                fnd_user.user_id%TYPE;
      l_tu_id                  igi_exp_tus.tu_id%TYPE;
      l_current_position_id    per_all_positions.position_id%TYPE;
      l_business_group_id      hr_all_positions_f.business_group_id%TYPE;
      l_organization_id        hr_all_positions_f.organization_id%TYPE;

      CURSOR c_user_list(p_position_id hr_all_positions_f.position_id%TYPE
                        ,p_business_group_id hr_all_positions_f.business_group_id%TYPE
                        ,p_organization_id hr_all_positions_f.organization_id%TYPE)
      IS
         SELECT fu.user_name
         FROM   hr_all_positions_f      hap,
                per_all_assignments_f   paa,
                per_employees_current_x pec,
                fnd_user                fu
         WHERE  fu.start_date <= SYSDATE
         AND    NVL(fu.end_date,SYSDATE) >= SYSDATE
         AND    fu.employee_id IS NOT NULL
         AND    fu.employee_id = pec.employee_id
         AND    NVL(pec.inactive_date,SYSDATE) >= SYSDATE
         AND    pec.business_group_id = paa.business_group_id
         AND    pec.assignment_id = paa.assignment_id
         AND    pec.organization_id = paa.organization_id
         AND    pec.business_group_id =  p_business_group_id
         AND    pec.organization_id = p_organization_id
         AND    paa.assignment_type = 'E'
         AND    paa.effective_start_date <= SYSDATE
         AND    paa.effective_end_date >= SYSDATE
         AND    paa.business_group_id = hap.business_group_id
         AND    paa.position_id IS NOT NULL
         AND    paa.position_id = hap.position_id
         AND    paa.organization_id = hap.organization_id
         AND    hap.date_effective <= SYSDATE
         AND    NVL(hap.date_end, SYSDATE) >= SYSDATE
         AND    NVL(UPPER(hap.status), 'VALID') NOT IN ('INVALID')
         AND    hap.position_id = p_position_id;



   BEGIN

     -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Build_user_list.Msg1',
                           ' ** BEGIN BUILD_USER_LIST ** ');
     -- =============== END DEBUG LOG ==================

      IF (funcmode = 'RUN') THEN

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Build_user_list.Msg2',
                              ' funcmode = RUN ');
         -- =============== END DEBUG LOG ==================

         -- Get the current position id
         l_current_position_id
            := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'CURRENT_POSITION_ID');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Build_user_list.Msg3',
                              ' GetItemAttrNumber CURRENT_POSITION_ID --> ' || l_current_position_id);
         -- =============== END DEBUG LOG ==================

         -- Get the business group id
         l_business_group_id
            := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'BUSINESS_GROUP_ID');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Build_user_list.Msg4',
                              ' GetItemAttrNumber BUSINESS_GROUP_ID --> ' || l_business_group_id);
         -- =============== END DEBUG LOG ==================

         -- Get the organization id
         l_organization_id
            := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'ORGANIZATION_ID');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Build_user_list.Msg5',
                              ' GetItemAttrNumber ORGANIZATION_ID --> ' || l_organization_id );
         -- =============== END DEBUG LOG ==================

         OPEN c_user_list(l_current_position_id
                         ,l_business_group_id
                         ,l_organization_id);

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Build_user_list.Msg6',
                              ' opening cursor c_user_list with '
                           || ' l_current_position_id --> ' || l_current_position_id
                           || ' l_business_group_id --> ' || l_business_group_id
                           || ' l_organization_id --> ' || l_organization_id);
         -- =============== END DEBUG LOG ==================

         -- For each user assigned to the current position, fetch the user name
         -- and add to user list
         LOOP
            FETCH c_user_list INTO l_user_name;

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Build_user_list.Msg7',
                                 ' l_user_name --> ' || l_user_name);
            -- =============== END DEBUG LOG ==================

            EXIT WHEN c_user_list%NOTFOUND;
            l_user_count := l_user_count + 1;
            l_user_list  := l_user_list||fnd_global.local_chr(10)||l_user_name;

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Build_user_list.Msg8',
                                 ' l_user_count --> ' || l_user_count);
               DEBUG_LOG_STRING (l_proc_level, 'Build_user_list.Msg9',
                                 ' l_user_list --> ' || l_user_list);
            -- =============== END DEBUG LOG ==================

         END LOOP;
         CLOSE c_user_list;

         IF (l_user_count = 0) THEN
            result := 'COMPLETE:NO_USERS';
            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Build_user_list.Msg10',
                                 ' l_user_count = 0 -- result --> ' || result);
            -- =============== END DEBUG LOG ==================
            return;
         ELSIF (l_user_count = 1) THEN

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Build_user_list.Msg11',
                                 ' l_user_count = 1 ');
            -- =============== END DEBUG LOG ==================

            -- Set the current_authoriser_role attribute to the user
            -- at the current position
            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'CURRENT_AUTHORIZER_ROLE',
                                         avalue   => l_user_name);


            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Build_user_list.Msg12',
                                 ' SetItemAttrText CURRENT_AUTHORIZER_ROLE --> ' || l_user_name);
            -- =============== END DEBUG LOG ==================

            -- Need to update the TU table with the next authorizer of the TU
            -- So firstly get the user_id of the current authorizer
            SELECT user_id
            INTO   l_user_id
            FROM   fnd_user
            WHERE  user_name = l_user_name;


            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Build_user_list.Msg13',
                                 ' l_user_id --> ' || l_user_id);
            -- =============== END DEBUG LOG ==================

            -- Now get the TU id
            l_tu_id
               := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                               itemkey  => itemkey,
                                               aname    => 'TU_ID');


            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Build_user_list.Msg14',
                                 ' GetItemAttrNumber TU_ID --> ' || l_tu_id);
            -- =============== END DEBUG LOG ==================

            -- Update the TU table with the next authorizer
            UPDATE igi_exp_tus
            SET    next_approver_user_id = l_user_id
            WHERE  tu_id = l_tu_id;


            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Build_user_list.Msg15',
                                 ' UPDATE igi_exp_tus set next_approver_user_id --> '|| l_user_id);
            -- =============== END DEBUG LOG ==================

            result := 'COMPLETE:ONE_USER';


            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Build_user_list.Msg16',
                                 ' result --> ' || result);
            -- =============== END DEBUG LOG ==================

            return;

         ELSE  -- multiple users were found for the current position

            -- Set the user_list attribute to the list of users found
            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'USER_LIST',
                                         avalue   => l_user_list);


            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Build_user_list.Msg17',
                                 ' SetItemAttrText USER_LIST --> ' || l_user_list);
            -- =============== END DEBUG LOG ==================

            -- Clear the picked authorizer attribute for the notification
            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'PICKED_AUTHORIZER',
                                         avalue   => null);


            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Build_user_list.Msg18',
                                 ' SetItemAttrText PICKED_AUTHORIZER --> null ');
            -- =============== END DEBUG LOG ==================

            result := 'COMPLETE:MULTIPLE_USERS';

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Build_user_list.Msg19',
                                 ' result --> ' || result);
            -- =============== END DEBUG LOG ==================

            return;
         END IF;

      END IF;

      IF (funcmode <> 'RUN') THEN
         result := 'COMPLETE';
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Build_user_list.Msg20',
                              ' funcmode <> RUN -- result --> ' || result);
         -- =============== END DEBUG LOG ==================
         return;
      END IF;

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Build_user_list.Msg21',
                           ' ** END BUILD_USER_LIST ** ');
      -- =============== END DEBUG LOG ==================

   EXCEPTION
      WHEN OTHERS THEN
           -- =============== START DEBUG LOG ================
              DEBUG_LOG_UNEXP_ERROR ('Build_user_list.Unexp1','DEFAULT');
           -- =============== END DEBUG LOG ==================
           wf_core.context('IGI_EXP_APPROVAL_PKG','build_user_list',itemtype,itemkey,
                           to_char(actid),funcmode);
           raise;
   END build_user_list;



   -- *************************************************************************
   --    CHECK_USER_POSITION
   -- *************************************************************************

   PROCEDURE check_user_position  ( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2) IS

      l_nid                  NUMBER;    -- notification id
      l_user_or_pos          VARCHAR2(30);
      l_picked_authorizer    VARCHAR2(240);
      l_current_position_id  per_all_positions.position_id%TYPE;
      l_role_name            VARCHAR2(240);

      e_wrong_user           EXCEPTION;


   BEGIN

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Check_user_position.Msg1',
                           ' ** BEGIN CHECK_USER_POSITION ** ');
      -- =============== END DEBUG LOG ==================

      IF (funcmode = 'RUN') THEN
         -- Do not do anything when called in 'RUN' mode
         null;
      END IF;

      IF (funcmode = 'RESPOND') THEN

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Check_user_position.Msg2',
                              ' funcmode = RESPOND ');
         -- =============== END DEBUG LOG ==================

         l_nid := wf_engine.context_nid;

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Check_user_position.Msg3',
                              ' l_nid --> ' || l_nid);
         -- =============== END DEBUG LOG ==================

         l_user_or_pos := wf_notification.GetAttrText(l_nid,'RESULT');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Check_user_position.Msg4',
                              ' l_user_or_pos --> ' || l_user_or_pos);
         -- =============== END DEBUG LOG ==================

         IF (l_user_or_pos = 'USER') THEN

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Check_user_position.Msg5',
                                 ' l_user_or_pos = USER ');
            -- =============== END DEBUG LOG ==================

            -- The notification responder chose to send approval request to chosen user
            l_picked_authorizer := wf_notification.GetAttrText(l_nid,'PICKED_AUTHORIZER');

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Check_user_position.Msg6',
                                 ' GetAttrText PICKED_AUTHORIZER --> ' || l_picked_authorizer);
            -- =============== END DEBUG LOG ==================

            -- Get the current position id
            l_current_position_id
               := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                               itemkey  => itemkey,
                                               aname    => 'CURRENT_POSITION_ID');

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Check_user_position.Msg7',
                                 ' GetItemAttrNumber CURRENT_POSITION_ID --> ' ||l_current_position_id );
            -- =============== END DEBUG LOG ==================

            -- Set the role name
            l_role_name := 'POS:'||to_char(l_current_position_id);

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Check_user_position.Msg8',
                                 ' l_role_name --> ' || l_role_name);
               DEBUG_LOG_STRING (l_proc_level, 'Check_user_position.Msg9',
                                 ' Calling wf_directory.IsPerformer with '
                               ||' l_picked_authorizer --> ' || l_picked_authorizer
                               ||' l_role_name --> ' ||  l_role_name);
            -- =============== END DEBUG LOG ==================

            -- Check that the chosen authorizer is assigned to the current position
            IF (wf_directory.IsPerformer(l_picked_authorizer,l_role_name)) THEN
               result := 'COMPLETE:USER';
               -- =============== START DEBUG LOG ================
                  DEBUG_LOG_STRING (l_proc_level, 'Check_user_position.Msg10',
                                    ' wf_directory.IsPerformer --> TRUE - result -> ' || result);
               -- =============== END DEBUG LOG ==================
               return;
            ELSE
               -- =============== START DEBUG LOG ================
                  DEBUG_LOG_STRING (l_proc_level, 'Check_user_position.Msg11',
                                    ' wf_directory.IsPerformer --> FALSE - Raise e_wrong_user');
               -- =============== END DEBUG LOG ==================
               -- Chosen authorizer is not assigned to current position so raise error
               RAISE e_wrong_user;
            END IF;

         ELSE
            result := 'COMPLETE:POS';
            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Check_user_position.Msg12',
                                 ' result --> ' || result);
            -- =============== END DEBUG LOG ==================
            return;
         END IF;

      END IF;

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Check_user_position.Msg13',
                           ' ** END CHECK_USER_POSITION ** ');
      -- =============== END DEBUG LOG ==================

   EXCEPTION
      WHEN e_wrong_user THEN
           fnd_message.set_name('IGI','IGI_EXP_INVALID_AUTHORIZER');
           -- =============== START DEBUG LOG ================
              DEBUG_LOG_UNEXP_ERROR ('Check_user_position.Unexp1','USER');
           -- =============== END DEBUG LOG ==================
           app_exception.raise_exception;
      WHEN OTHERS THEN
           -- =============== START DEBUG LOG ================
              DEBUG_LOG_UNEXP_ERROR ('Check_user_position.Unexp2','DEFAULT');
           -- =============== END DEBUG LOG ==================
           wf_core.context('IGI_EXP_APPROVAL_PKG','check_user_position',itemtype,itemkey,
                           to_char(actid),funcmode);
           raise;
   END check_user_position;


   -- *************************************************************************
   --    SET_POS_AS_AUTH
   -- *************************************************************************

   PROCEDURE set_pos_as_auth      ( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2) IS

      l_current_position_id    per_all_positions.position_id%TYPE;
      l_current_auth_role      VARCHAR2(240);
      l_tu_id                  igi_exp_tus.tu_id%TYPE;

   BEGIN

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Set_pos_as_auth.Msg1',
                           ' ** START SET_POS_AS_AUTH ** ');
      -- =============== END DEBUG LOG ==================

      IF (funcmode = 'RUN') THEN

         -- Get the current position id
         l_current_position_id
            := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'CURRENT_POSITION_ID');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Set_pos_as_auth.Msg1',
                              ' GetItemAttrNumber CURRENT_POSITION_ID -->' || l_current_position_id);
         -- =============== END DEBUG LOG ==================

         l_current_auth_role := 'POS:'||to_char(l_current_position_id);

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Set_pos_as_auth.Msg1',
                              ' l_current_auth_role -->' || l_current_auth_role);
         -- =============== END DEBUG LOG ==================

         -- Set the current_authorizer_role attribute to the position
            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'CURRENT_AUTHORIZER_ROLE',
                                         avalue   => l_current_auth_role);

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Set_pos_as_auth.Msg1',
                              ' SetItemAttrText CURRENT_AUTHORIZER_ROLE -->' || l_current_auth_role);
         -- =============== END DEBUG LOG ==================

         -- Since the next authorizer user is unknown (it is anyone at the
         -- next position) then the value of the column next_approver_user_id
         -- on the TU table should be set to null since nothing can be displayed
         -- there.
         -- First get the TU id

         l_tu_id
            := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'TU_ID');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Set_pos_as_auth.Msg1',
                              ' GetItemAttrNumber TU_ID -->' || l_tu_id);
         -- =============== END DEBUG LOG ==================

         -- Update the next approver column to null
         UPDATE igi_exp_tus
         SET    next_approver_user_id = null
         WHERE  tu_id = l_tu_id;

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Set_pos_as_auth.Msg1',
                              ' Update igi_exp_tus for tu_id ' ||l_tu_id );
         -- =============== END DEBUG LOG ==================

      END IF;

      IF (funcmode <> 'RUN') THEN
         result := 'COMPLETE';
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Set_pos_as_auth.Msg1',
                              ' funcmode <> RUN -- result --> ' || result );
         -- =============== END DEBUG LOG ==================
         return;
      END IF;

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Set_pos_as_auth.Msg1',
                           ' ** END SET_POS_AS_AUTH ** ');
      -- =============== END DEBUG LOG ==================

   EXCEPTION
      WHEN OTHERS THEN
           wf_core.context('IGI_EXP_APPROVAL_PKG','set_pos_as_auth',itemtype,itemkey,
                         to_char(actid),funcmode);
           -- =============== START DEBUG LOG ================
              DEBUG_LOG_UNEXP_ERROR ('Set_pos_as_auth.Unexp1','DEFAULT');
           -- =============== END DEBUG LOG ==================
           raise;
   END set_pos_as_auth;


   -- *************************************************************************
   --    SET_CHOSEN_USER_AS_AUTH
   -- *************************************************************************

   PROCEDURE set_chosen_user_as_auth( itemtype IN  VARCHAR2,
                                      itemkey  IN  VARCHAR2,
                                      actid    IN  NUMBER,
                                      funcmode IN  VARCHAR2,
                                      result   OUT NOCOPY VARCHAR2) IS

      l_current_auth_role  VARCHAR2(240);
      l_auth_id            fnd_user.user_id%TYPE;
      l_tu_id              igi_exp_tus.tu_id%TYPE;

   BEGIN

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Set_chosen_user_as_auth.Msg1',
                           ' ** START SET_CHOSEN_USER_AS_AUTH ** ');
      -- =============== END DEBUG LOG ==================

      IF (funcmode = 'RUN') THEN

         -- Get the picked authorizer role
         l_current_auth_role
            := wf_engine.GetItemAttrText  ( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'PICKED_AUTHORIZER');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Set_chosen_user_as_auth.Msg2',
                              ' GetItemAttrText PICKED_AUTHORIZER --> ' || l_current_auth_role);
         -- =============== END DEBUG LOG ==================

         -- Need to update the TU table to show the next authorizer of the TU
         -- First get the TU id
         l_tu_id
            := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'TU_ID');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Set_chosen_user_as_auth.Msg3',
                              ' GetItemAttrNumbe TU_ID --> '|| l_tu_id);
         -- =============== END DEBUG LOG ==================

         -- Get the user_id of the authorizer
         SELECT user_id
         INTO   l_auth_id
         FROM   fnd_user
         WHERE  user_name = l_current_auth_role;

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Set_chosen_user_as_auth.Msg4',
                              ' Get the user_id of the authorizer --> ' || l_auth_id);
         -- =============== END DEBUG LOG ==================

         -- Update the TU table with the next authorizer id
         UPDATE igi_exp_tus
         SET    next_approver_user_id = l_auth_id
         WHERE  tu_id = l_tu_id;

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Set_chosen_user_as_auth.Msg5',
                              ' UPDATE igi_exp_tus with ' || l_auth_id || ' for ' || l_tu_id);
         -- =============== END DEBUG LOG ==================

         -- Set the current_authorizer_role attribute
         wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                      itemkey  => itemkey,
                                      aname    => 'CURRENT_AUTHORIZER_ROLE',
                                      avalue   => l_current_auth_role);

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Set_chosen_user_as_auth.Msg6',
                              ' SetItemAttrText CURRENT_AUTHORIZER_ROLE --> ' || l_current_auth_role);
         -- =============== END DEBUG LOG ==================

      END IF;

      IF (funcmode <> 'RUN') THEN
         result := 'COMPLETE';
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Set_chosen_user_as_auth.Msg7',
                              ' funcmode <> RUN - result --> ' || result);
         -- =============== END DEBUG LOG ==================
         return;
      END IF;

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Set_chosen_user_as_auth.Msg8',
                           ' ** END SET_CHOSEN_USER_AS_AUTH ** ');
      -- =============== END DEBUG LOG ==================

   EXCEPTION
      WHEN OTHERS THEN
           wf_core.context('IGI_EXP_APPROVAL_PKG','set_chosen_user_as_auth',itemtype,itemkey,
                           to_char(actid),funcmode);
           -- =============== START DEBUG LOG ================
              DEBUG_LOG_UNEXP_ERROR ('Set_chosen_user_as_auth.Unexp1','DEFAULT');
           -- =============== END DEBUG LOG ==================
           raise;
   END set_chosen_user_as_auth;



   -- *************************************************************************
   --    IS_AUTH_ALLOWED_RETURN
   -- *************************************************************************

   PROCEDURE is_auth_allowed_return ( itemtype IN  VARCHAR2,
                                      itemkey  IN  VARCHAR2,
                                      actid    IN  NUMBER,
                                      funcmode IN  VARCHAR2,
                                      result   OUT NOCOPY VARCHAR2) IS

      CURSOR c_return_assign(p_position_id  igi_exp_pos_actions.position_id%TYPE)
      IS
         SELECT return
         FROM   igi_exp_pos_actions
         WHERE  position_id = p_position_id;

      l_authorizer_history_list  VARCHAR2(1000);
      l_num                      NUMBER;
      l_current_position_id      hr_all_positions_f.position_id%TYPE;
      l_return_allowed           VARCHAR2(1);

   BEGIN

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Is_auth_allowed_return.Msg1',
                           ' ** START IS_AUTH_ALLOWED_RETURN ** ');
      -- =============== END DEBUG LOG ==================

      IF (funcmode = 'RUN') THEN

         -- First need to check if there is more than one authorizer on the
         -- authorizer history list.  If there is only one authorizer in the
         -- list, it should not be possible to return the TU (as there is
         -- no authorizer to return it to).

         -- Get the authorizer history list
         l_authorizer_history_list
            := wf_engine.GetItemAttrText  ( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'AUTHORIZER_HISTORY_LIST');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Is_auth_allowed_return.Msg2',
                              ' GetItemAttrText AUTHORIZER_HISTORY_LIST --> ' || l_authorizer_history_list);
         -- =============== END DEBUG LOG ==================

         -- Check if there is more than one authorizer in list
         -- (i.e. check for any commas in list as commas are used as delimiters
         -- between authorizers)
         l_num := INSTR(l_authorizer_history_list,',');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Is_auth_allowed_return.Msg3',
                              ' l_num --> ' || l_num);
         -- =============== END DEBUG LOG ==================

         IF (l_num = 0) THEN

            -- There is only one authorizer in list (i.e. the current authorizer)
            -- so the current authorizer should not be allowed to return the TU
            -- Set the result to 'No' and exit

            result := 'COMPLETE:N';
            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Is_auth_allowed_return.Msg4',
                                 ' l_num = 0 -- result --> ' || result);
            -- =============== END DEBUG LOG ==================
            return;

         ELSE
            -- (l_num > 0) so there is more than one authorizer in list
            -- Now need to check if the current authorizer's position
            -- has the ability to return TUs.  This is defined during EXP
            -- action assignment setup.
            -- Get the position id of the current authorizer

            l_current_position_id
               := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                               itemkey  => itemkey,
                                               aname    => 'CURRENT_POSITION_ID');

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Is_auth_allowed_return.Msg5',
                                 ' GetItemAttrNumber CURRENT_POSITION_ID --> ' || l_current_position_id);
            -- =============== END DEBUG LOG ==================

            -- Check if this position has the ability to return TUs.
            OPEN c_return_assign(l_current_position_id);
            FETCH c_return_assign INTO l_return_allowed;

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Is_auth_allowed_return.Msg6',
                                 ' l_return_allowed --> ' || l_return_allowed);
            -- =============== END DEBUG LOG ==================

            IF (c_return_assign%NOTFOUND) THEN
               CLOSE c_return_assign;
               -- Set the result to 'No Assignments' and exit
               result := 'COMPLETE:NO_ASSIGN';
               -- =============== START DEBUG LOG ================
                  DEBUG_LOG_STRING (l_proc_level, 'Is_auth_allowed_return.Msg7',
                                    ' c_return_assign%NOTFOUND - TRUE - result --> ' || result);
               -- =============== END DEBUG LOG ==================
               return;
            END IF;
            CLOSE c_return_assign;

            IF (l_return_allowed = 'Y') THEN
               -- Set the result to 'Yes' and exit
               result := 'COMPLETE:Y';
               -- =============== START DEBUG LOG ================
                  DEBUG_LOG_STRING (l_proc_level, 'Is_auth_allowed_return.Msg8',
                                    ' l_return_allowed = Y  -- result --> ' || result);
               -- =============== END DEBUG LOG ==================
               return;
            ELSE
               -- return not allowed for this position
               -- Set the result to 'No' and exit
               result := 'COMPLETE:N';
               -- =============== START DEBUG LOG ================
                  DEBUG_LOG_STRING (l_proc_level, 'Is_auth_allowed_return.Msg9',
                                    ' l_return_allowed = N -- result --> ' || result);
               -- =============== END DEBUG LOG ==================
               return;
            END IF;

         END IF;

      END IF;

      IF (funcmode <> 'RUN') THEN
         result := 'COMPLETE';
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Is_auth_allowed_return.Msg10',
                              ' funcmode <> RUN -- result --> ' || result);
         -- =============== END DEBUG LOG ==================
         return;
      END IF;

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Is_auth_allowed_return.Msg11',
                           ' ** END IS_AUTH_ALLOWED_RETURN ** ');
      -- =============== END DEBUG LOG ==================

   EXCEPTION
      WHEN OTHERS THEN
           wf_core.context('IGI_EXP_APPROVAL_PKG','is_auth_allowed_return',itemtype,itemkey,
                           to_char(actid),funcmode);
           -- =============== START DEBUG LOG ================
              DEBUG_LOG_UNEXP_ERROR ('Is_auth_allowed_return.Unexp1','DEFAULT');
           -- =============== END DEBUG LOG ==================
           raise;
   END is_auth_allowed_return;

   -- *************************************************************************
   --    SET_CURR_AUTH_TO_RESPONDER
   -- *************************************************************************

   PROCEDURE set_curr_auth_to_responder  ( itemtype IN  VARCHAR2,
                                           itemkey  IN  VARCHAR2,
                                           actid    IN  NUMBER,
                                           funcmode IN  VARCHAR2,
                                           result   OUT NOCOPY VARCHAR2) IS

      l_nid                  NUMBER;    -- notification id
      l_num                  NUMBER;
      l_current_auth_role    VARCHAR2(240);

   BEGIN

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Set_curr_auth_to_responder.Msg1',
                           ' ** START SET_CURR_AUTH_TO_RESPONDER ** ');
      -- =============== END DEBUG LOG ==================

      IF (funcmode = 'RUN') THEN
         -- do nothing in run mode
         null;
      END IF;

      IF (funcmode = 'RESPOND') THEN

         -- This is run in respond mode for all notifications in the process
         -- 'TU Authorization Request Process' (TU_AUTH_REQUEST_PROCESS)
         -- If the current authorizer role is currently set as a position role
         -- we want to set it to the actual user who responded to the notification
         -- to ensure subsequent notifications are sent to the responder and not
         -- to all users at the position

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Set_curr_auth_to_responder.Msg2',
                              ' funcmode = RESPOND ');
         -- =============== END DEBUG LOG ==================

         l_nid := wf_engine.context_nid;

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Set_curr_auth_to_responder.Msg3',
                              ' l_nid --> ' || l_nid);
         -- =============== END DEBUG LOG ==================

         -- Get the current authoriser role item attribute
         l_current_auth_role
            := wf_engine.GetItemAttrText  ( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'CURRENT_AUTHORIZER_ROLE');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Set_curr_auth_to_responder.Msg4',
                              ' GetItemAttrText CURRENT_AUTHORIZER_ROLE --> ' || l_current_auth_role);
         -- =============== END DEBUG LOG ==================

         -- Find out NOCOPY if the current authorizer role is set to a position
         l_num := INSTR(l_current_auth_role,'POS:');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Set_curr_auth_to_responder.Msg5',
                              ' l_num --> ' || l_num);
         -- =============== END DEBUG LOG ==================

         IF (l_num = 0) THEN

            -- The current authorizer role is not set as a position, so do nothing
            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Set_curr_auth_to_responder.Msg6',
                                 ' l_num = 0 ');
            -- =============== END DEBUG LOG ==================
            null;

         ELSE

            -- (l_num > 0)
            -- The current authorizer role is set as a position, so want to set it to
            -- the responder user instead.

            -- Get the responder
            l_current_auth_role := wf_engine.context_text;

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Set_curr_auth_to_responder.Msg7',
                                 ' l_num > 0 -- l_current_auth_role --> ' || l_current_auth_role);
            -- =============== END DEBUG LOG ==================

            -- Set the current authorizer role attribute to the responder
            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'CURRENT_AUTHORIZER_ROLE',
                                         avalue   => l_current_auth_role);

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Set_curr_auth_to_responder.Msg8',
                                 ' SetItemAttrText CURRENT_AUTHORIZER_ROLE --> ' || l_current_auth_role);
            -- =============== END DEBUG LOG ==================

         END IF;

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Set_curr_auth_to_responder.Msg9',
                              ' calling set_tu_form_to_query with l_nid --> ' || l_nid);
         -- =============== END DEBUG LOG ==================

         -- OPSF(I) EXP Bug 2388078  S Brewer 17-JUN-2002 Start(2)
         -- Also need to call the procedure to set the TU form to query only mode
         -- for this notification
         set_tu_form_to_query(l_nid);

      END IF;

      IF (funcmode = 'TIMEOUT') THEN

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Set_curr_auth_to_responder.Msg10',
                              ' funcmode = TIMEOUT -- calling set_tu_form_to_query with l_nid --> ' || l_nid);
         -- =============== END DEBUG LOG ==================

         -- Need to call the procedure to set the TU form to query only mode
         -- for this notification
         set_tu_form_to_query(l_nid);

      END IF;
      -- OPSF(I) EXP Bug 2388078  S Brewer 17-JUN-2002 End(2)

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Set_curr_auth_to_responder.Msg11',
                           ' ** END SET_CURR_AUTH_TO_RESPONDER ** ');
      -- =============== END DEBUG LOG ==================

   EXCEPTION
      WHEN OTHERS THEN
           wf_core.context('IGI_EXP_APPROVAL_PKG','set_curr_auth_to_responder',itemtype,itemkey,
                            to_char(actid),funcmode);
           -- =============== START DEBUG LOG ================
              DEBUG_LOG_UNEXP_ERROR ('Is_auth_allowed_return.Unexp1','DEFAULT');
           -- =============== END DEBUG LOG ==================
           raise;
   END set_curr_auth_to_responder;



   -- *************************************************************************
   --    ADD_AUTH_TO_HISTORY
   -- *************************************************************************

   PROCEDURE add_auth_to_history  ( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2) IS

      l_authorizer_history_list  VARCHAR2(1000);
      l_current_auth_role        VARCHAR2(240);

   BEGIN

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Add_auth_to_history.Msg1',
                           ' ** START ADD_AUTH_TO_HISTORY ** ');
      -- =============== END DEBUG LOG ==================

      IF (funcmode = 'RUN') THEN

         -- Want to add the current authorizer to the authorizer history
         -- list.

         -- Get the current authorizer
         l_current_auth_role
            := wf_engine.GetItemAttrText  ( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'CURRENT_AUTHORIZER_ROLE');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Add_auth_to_history.Msg2',
                              ' GetItemAttrText CURRENT_AUTHORIZER_ROLE --> ' || l_current_auth_role);
         -- =============== END DEBUG LOG ==================

         -- Get the authorizer history list
         l_authorizer_history_list
            := wf_engine.GetItemAttrText  ( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'AUTHORIZER_HISTORY_LIST');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Add_auth_to_history.Msg3',
                              ' GetItemAttrText AUTHORIZER_HISTORY_LIST --> ' || l_authorizer_history_list);
         -- =============== END DEBUG LOG ==================

         -- Add the current authorizer to the authorizer history list
         l_authorizer_history_list :=
            l_authorizer_history_list||','||l_current_auth_role;

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Add_auth_to_history.Msg4',
                              ' l_authorizer_history_list --> ' || l_authorizer_history_list);
         -- =============== END DEBUG LOG ==================

         -- Set the authorizer_history_list attribute
         wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                      itemkey  => itemkey,
                                      aname    => 'AUTHORIZER_HISTORY_LIST',
                                      avalue   => l_authorizer_history_list);

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Add_auth_to_history.Msg5',
                              ' SetItemAttrText AUTHORIZER_HISTORY_LIST --> ' || l_authorizer_history_list);
         -- =============== END DEBUG LOG ==================

      END IF;

      IF (funcmode <> 'RUN') THEN
         result := 'COMPLETE';
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Add_auth_to_history.Msg6',
                              ' funcmode <> RUN -- result --> ' || result);
         -- =============== END DEBUG LOG ==================
         return;
      END IF;

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Add_auth_to_history.Msg7',
                           ' ** END ADD_AUTH_TO_HISTORY ** ');
      -- =============== END DEBUG LOG ==================

   EXCEPTION
      WHEN OTHERS THEN
         wf_core.context('IGI_EXP_APPROVAL_PKG','add_auth_to_history',itemtype,itemkey,
                         to_char(actid),funcmode);
           -- =============== START DEBUG LOG ================
              DEBUG_LOG_UNEXP_ERROR ('Add_auth_to_history.Unexp1','DEFAULT');
           -- =============== END DEBUG LOG ==================
         raise;

   END add_auth_to_history;



   -- *************************************************************************
   --    SET_CURRENT_POSITION_TO_SUBORD
   -- *************************************************************************

   PROCEDURE set_current_position_to_subord( itemtype IN  VARCHAR2,
                                             itemkey  IN  VARCHAR2,
                                             actid    IN  NUMBER,
                                             funcmode IN  VARCHAR2,
                                             result   OUT NOCOPY VARCHAR2) IS

     CURSOR c_get_subord_pos(p_position_id per_all_positions.position_id%TYPE
                            ,p_pos_structure_version_id per_pos_structure_versions.pos_structure_version_id%TYPE
                            ,p_business_group_id hr_all_positions_f.business_group_id%TYPE)
     IS
        SELECT subordinate_position_id
        FROM   per_pos_structure_elements
        WHERE  pos_structure_version_id = p_pos_structure_version_id
        AND    business_group_id = p_business_group_id
        AND    parent_position_id = p_position_id;

      l_current_position_id      hr_all_positions_f.position_id%TYPE;
      l_subord_position_id       hr_all_positions_f.position_id%TYPE;
      l_subord_position_name     hr_all_positions_f.name%TYPE;
      l_transmitter_position_id  hr_all_positions_f.position_id%TYPE;
      l_business_group_id        hr_all_positions_f.business_group_id%TYPE;
      l_pos_structure_version_id per_pos_structure_versions.pos_structure_version_id%TYPE;
      l_organization_id          hr_all_positions_f.organization_id%TYPE;

      e_no_subord_pos EXCEPTION;

   BEGIN

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Set_current_position_to_subord.Msg1',
                           ' ** START SET_CURRENT_POSITION_TO_SUBORD ** ');
      -- =============== END DEBUG LOG ==================

      IF (funcmode = 'RUN') THEN

         -- This procedure will set the current position id attribute
         -- to be the subordinate position of the current position.
         -- It is called when a TU is returned to the previous
         -- authorizer (in the subordinate position).

         -- First check if the current position id is the same as the
         -- transmitter's position id.  In which case, we should not
         -- set it to the subordinate position - it should never go
         -- below the TU transmitter's level

         -- Get the position id of the TU transmitter
         l_transmitter_position_id
            := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'TRANSMITTER_POSITION_ID');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Set_current_position_to_subord.Msg2',
                              ' GetItemAttrNumber TRANSMITTER_POSITION_ID --> ' || l_transmitter_position_id);
         -- =============== END DEBUG LOG ==================

         -- Get the current position id
         l_current_position_id
            := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'CURRENT_POSITION_ID');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Set_current_position_to_subord.Msg3',
                              ' GetItemAttrNumber CURRENT_POSITION_ID --> ' || l_current_position_id);
         -- =============== END DEBUG LOG ==================

         IF (l_current_position_id = l_transmitter_position_id) THEN
            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Set_current_position_to_subord.Msg4',
                                 ' l_current_position_id = l_transmitter_position_id - return ');
            -- =============== END DEBUG LOG ==================
            -- Since this is the transmitter's position, do nothing
            return;
         END IF;

         -- Get the values of the attributes needed:
         -- Position structure version and business group.

         -- Get the position structure version id
         l_pos_structure_version_id
            := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'POS_STRUCTURE_VERSION_ID');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Set_current_position_to_subord.Msg5',
                              ' GetItemAttrNumber POS_STRUCTURE_VERSION_ID --> ' || l_pos_structure_version_id);
         -- =============== END DEBUG LOG ==================

         -- Get the business group
         l_business_group_id
            := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'BUSINESS_GROUP_ID');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Set_current_position_to_subord.Msg6',
                              ' GetItemAttrNumber BUSINESS_GROUP_ID --> ' || l_business_group_id);
         -- =============== END DEBUG LOG ==================

         -- Get the organization_id
         l_organization_id
            := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'ORGANIZATION_ID');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Set_current_position_to_subord.Msg7',
                              ' GetItemAttrNumber ORGANIZATION_ID --> ' || l_organization_id);
         -- =============== END DEBUG LOG ==================

         -- Get the subordinate position of the current position
         OPEN c_get_subord_pos(l_current_position_id
                              ,l_pos_structure_version_id
                              ,l_business_group_id);
         FETCH c_get_subord_pos INTO l_subord_position_id;

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Set_current_position_to_subord.Msg8',
                              ' l_subord_position_id --> ' || l_subord_position_id);
         -- =============== END DEBUG LOG ==================

         IF (c_get_subord_pos%NOTFOUND) THEN
            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Set_current_position_to_subord.Msg9',
                                 ' c_get_subord_pos%NOTFOUND = TRUE resie e_no_subord_pos ');
            -- =============== END DEBUG LOG ==================
            RAISE e_no_subord_pos;
         END IF;
         CLOSE c_get_subord_pos;

         -- Get the name of the subordinate position
         SELECT name
         INTO   l_subord_position_name
         FROM   hr_all_positions_f
         WHERE  position_id = l_subord_position_id
         AND    business_group_id = l_business_group_id
         AND    organization_id   = l_organization_id;

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Set_current_position_to_subord.Msg10',
                              ' l_subord_position_name --> ' || l_subord_position_name);
         -- =============== END DEBUG LOG ==================

         -- Set the current position id attribute to the subordinate position
         wf_engine.SetItemAttrNumber( itemtype => itemtype,
                                      itemkey  => itemkey,
                                      aname    => 'CURRENT_POSITION_ID',
                                      avalue   => l_subord_position_id);

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Set_current_position_to_subord.Msg11',
                              ' SetItemAttrNumber CURRENT_POSITION_ID --> ' || l_subord_position_id);
         -- =============== END DEBUG LOG ==================

         -- Set the current position name attribute to the subordinate position
         wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                      itemkey  => itemkey,
                                      aname    => 'CURRENT_POSITION_NAME',
                                      avalue   => l_subord_position_name);

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Set_current_position_to_subord.Msg12',
                              ' SetItemAttrText CURRENT_POSITION_NAME --> ' || l_subord_position_name);
         -- =============== END DEBUG LOG ==================

      END IF;

      IF (funcmode <> 'RUN') THEN
         result := 'COMPLETE';
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Set_current_position_to_subord.Msg13',
                              ' funcmode <> RUN -- result --> ' || result);
         -- =============== END DEBUG LOG ==================
         return;
      END IF;

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Set_current_position_to_subord.Msg14',
                           ' ** END SET_CURRENT_POSITION_TO_SUBORD ** ');
      -- =============== END DEBUG LOG ==================

   EXCEPTION
      WHEN e_no_subord_pos THEN
         wf_core.context('IGI_EXP_APPROVAL_PKG','set_current_position_to_subord',itemtype,itemkey,
                         to_char(actid),funcmode,'Subordinate of current position not found in hierarchy');
         IF (c_get_subord_pos%ISOPEN) THEN
            CLOSE c_get_subord_pos;
         END IF;
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Set_current_position_to_subord.Msg15',
                              ' EXCEPTION e_no_subord_pos - No subordinate found. ');
         -- =============== END DEBUG LOG ==================
         raise;

      WHEN OTHERS THEN
         wf_core.context('IGI_EXP_APPROVAL_PKG','set_current_position_to_subord',itemtype,itemkey,
                         to_char(actid),funcmode);
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_UNEXP_ERROR ('Set_current_position_to_subord.Unexp1','DEFAULT');
         -- =============== END DEBUG LOG ==================
        raise;

   END set_current_position_to_subord;



   -- *************************************************************************
   --    SET_CURRENT_AUTH_TO_PREV_AUTH
   -- *************************************************************************

   PROCEDURE set_current_auth_to_prev_auth ( itemtype IN  VARCHAR2,
                                             itemkey  IN  VARCHAR2,
                                             actid    IN  NUMBER,
                                             funcmode IN  VARCHAR2,
                                             result   OUT NOCOPY VARCHAR2) IS

      l_returner_name              VARCHAR2(240);
      l_authorizer_history_list    VARCHAR2(1000);
      l_new_auth_history_list      VARCHAR2(1000);
      l_num1                       NUMBER;
      l_num2                       NUMBER;
      l_prev_authorizer            fnd_user.user_name%TYPE;

      e_no_prev_auth               EXCEPTION;

   BEGIN

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Set_current_auth_to_prev_auth.Msg1',
                           ' ** START SET_CURRENT_AUTH_TO_PREV_AUTH ** ');
      -- =============== END DEBUG LOG ==================

      IF (funcmode = 'RUN') THEN

         -- Firstly, we need to find the returner of the TU
         -- Get the current authoriser
         l_returner_name
            := wf_engine.GetItemAttrText  ( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'CURRENT_AUTHORIZER_ROLE');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Set_current_auth_to_prev_auth.Msg2',
                              ' GetItemAttrText CURRENT_AUTHORIZER_ROLE --> ' || l_returner_name);
         -- =============== END DEBUG LOG ==================

         -- Set the returner_name attribute
         wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                      itemkey  => itemkey,
                                      aname    => 'RETURNER_NAME',
                                      avalue   => l_returner_name);


         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Set_current_auth_to_prev_auth.Msg3',
                              ' SetItemAttrText RETURNER_NAME --> ' || l_returner_name);
         -- =============== END DEBUG LOG ==================

         -- Now we need to remove the current authorizer from the
         -- authorizer history list

         -- Get the authorizer history list
         l_authorizer_history_list
            := wf_engine.GetItemAttrText  ( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'AUTHORIZER_HISTORY_LIST');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Set_current_auth_to_prev_auth.Msg4',
                              ' GetItemAttrText AUTHORIZER_HISTORY_LIST --> ' || l_authorizer_history_list);
         -- =============== END DEBUG LOG ==================

         -- This will return the position of the last comma in the history list
         l_num1 := INSTR(l_authorizer_history_list,',',-1);

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Set_current_auth_to_prev_auth.Msg5',
                              ' l_num1 -> ' || l_num1);
         -- =============== END DEBUG LOG ==================

         IF (l_num1 = 0) THEN
            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Set_current_auth_to_prev_auth.Msg6',
                                 ' l_num1 = 0 -- RAISE e_no_prev_auth ');
            -- =============== END DEBUG LOG ==================
            -- There is only one user in the history list, so cannot continue
            RAISE e_no_prev_auth;
         END IF;

         -- There is more than one authorizer in the history list, so delete
         -- the last authorizer by taking a substring of the original list
         -- up to the last comma (delimiter)
         l_new_auth_history_list := SUBSTR(l_authorizer_history_list,1,l_num1-1);

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Set_current_auth_to_prev_auth.Msg7',
                              ' l_new_auth_history_list --> ' || l_new_auth_history_list);
         -- =============== END DEBUG LOG ==================

         -- Set the authorizer_history_list attribute
         wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                      itemkey  => itemkey,
                                      aname    => 'AUTHORIZER_HISTORY_LIST',
                                      avalue   => l_new_auth_history_list);

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Set_current_auth_to_prev_auth.Msg8',
                              ' SetItemAttrText AUTHORIZER_HISTORY_LIST --> ' || l_new_auth_history_list);
         -- =============== END DEBUG LOG ==================

         -- Now we need to find the previous authorizer (using the authorizer history
         -- list).

         -- This will return the position of the last comma in the new history list
         l_num2 := INSTR(l_new_auth_history_list,',',-1);

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Set_current_auth_to_prev_auth.Msg9',
                              ' l_num2 --> ' || l_num2);
         -- =============== END DEBUG LOG ==================

         IF (l_num2 = 0) THEN
            -- There is only one authorizer left in new history list
            -- so set the previous authorizer attribute to that authorizer
            l_prev_authorizer := l_new_auth_history_list;
            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Set_current_auth_to_prev_auth.Msg10',
                                 ' l_num2 = 0 -- l_prev_authorizer --> ' || l_prev_authorizer);
            -- =============== END DEBUG LOG ==================
         ELSE
            -- There is more than one authorizer in the new history list, so
            -- get the previous authorizer by taking a substring of the new list
            -- up to the last comma (delimiter)
            l_prev_authorizer := SUBSTR(l_new_auth_history_list,l_num2+1);
            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Set_current_auth_to_prev_auth.Msg11',
                                 ' l_num2 != 0 -- l_prev_authorizer --> ' || l_prev_authorizer);
            -- =============== END DEBUG LOG ==================
         END IF;

         -- Set the current_authorizer_role attribute to the previous authorizer
         wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                      itemkey  => itemkey,
                                      aname    => 'CURRENT_AUTHORIZER_ROLE',
                                      avalue   => l_prev_authorizer);

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Set_current_auth_to_prev_auth.Msg12',
                              ' SetItemAttrText CURRENT_AUTHORIZER_ROLE --> ' || l_prev_authorizer);
         -- =============== END DEBUG LOG ==================

      END IF;

      IF (funcmode <> 'RUN') THEN
         result := 'COMPLETE';
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Set_current_auth_to_prev_auth.Msg13',
                              ' funcmode <> RUN -- result --> ' || result);
         -- =============== END DEBUG LOG ==================
         return;
      END IF;

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Set_current_auth_to_prev_auth.Msg14',
                           ' ** END SET_CURRENT_AUTH_TO_PREV_AUTH ** ');
      -- =============== END DEBUG LOG ==================

   EXCEPTION
      WHEN e_no_prev_auth THEN
         wf_core.context('IGI_EXP_APPROVAL_PKG','set_current_auth_to_prev_auth',itemtype,itemkey,
                         to_char(actid),funcmode,'No previous authorizer found in history list');
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Set_current_auth_to_prev_auth.Msg15',
                              ' EXCEPTION - e_no_prev_auth - No previous authorizer ');
         -- =============== END DEBUG LOG ==================
         raise;

      WHEN OTHERS THEN
         wf_core.context('IGI_EXP_APPROVAL_PKG','set_current_auth_to_prev_auth',itemtype,itemkey,
                         to_char(actid),funcmode);
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_UNEXP_ERROR ('Set_current_auth_to_prev_auth.Unexp1','DEFAULT');
         -- =============== END DEBUG LOG ==================
         raise;

   END set_current_auth_to_prev_auth;


   -- *************************************************************************
   --    RESET_DU_STATUSES
   -- *************************************************************************

   PROCEDURE reset_du_statuses    ( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2) IS

      l_tu_id   igi_exp_tus.tu_id%TYPE;

   BEGIN

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Reset_du_statuses.Msg1',
                           ' ** START RESET_DU_STATUSES ** ');
      -- =============== END DEBUG LOG ==================

     IF (funcmode = 'RUN') THEN

         -- If the returner made any changes to the dialog unit statuses
         -- through the transmission unit form and then decided to return
         -- the TU, we need to reset the dialog unit statuses to their
         -- original state.  If the dialog unit has been put on hold 'HLD'
         -- then the original state would be Approved.
         -- If the dialog unit has been rejected and there still exist
         -- transactions within it then the original state would be
         -- Approved.
         -- Also, if the returner made no changes to the dialog unit statuses:
         -- If the dialog unit has a status of 'Approved and Transmitted'
         -- then the original state would be Approved.  (We need to change
         -- the dialog unit statuses back to approved for returned dialog
         -- units so that the authorizer who receives the returned TU
         -- does not have to update all the dialog units to approved again
         -- (They already approved the dialog units when they first received
         -- the approval request).

         -- Get the TU id
         l_tu_id
            := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'TU_ID');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Reset_du_statuses.Msg2',
                              ' GetItemAttrNumber TU_ID --> ' || l_tu_id);
         -- =============== END DEBUG LOG ==================

         -- Change the status of the dialog units on hold
         UPDATE igi_exp_dus dus
         SET    dus.du_status = 'APP'
         WHERE  dus.du_status = 'HLD'
         AND    dus.tu_id = l_tu_id;

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Reset_du_statuses.Msg3',
                              ' UPDATE igi_exp_dus dus HLD to APP ' || SQL%ROWCOUNT);
         -- =============== END DEBUG LOG ==================

         -- Change the status of dialog units which have been rejected
         -- but still contain transactions.
         UPDATE igi_exp_dus dus
         SET    dus.du_status = 'APP'
         WHERE  dus.du_status = 'REJ'
         AND    dus.tu_id = l_tu_id
         AND EXISTS (SELECT 'AR'
                     FROM   igi_exp_ar_trans ar
                     WHERE  ar.du_id = dus.du_id
                     UNION
                     SELECT 'AP'
                     FROM   igi_exp_ap_trans ap
                     WHERE  ap.du_id = dus.du_id);

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Reset_du_statuses.Msg4',
                              ' UPDATE igi_exp_dus status - REJ to APP' || SQL%ROWCOUNT);
         -- =============== END DEBUG LOG ==================

         -- Change the status of the dialog units which are in status
         -- approved and transmitted
         UPDATE igi_exp_dus dus
         SET    dus.du_status = 'APP'
         WHERE  dus.du_status = 'ATR'
         AND    dus.tu_id = l_tu_id;

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Reset_du_statuses.Msg5',
                              ' UPDATE igi_exp_dus status -- ATR to APP ' || SQL%ROWCOUNT);
         -- =============== END DEBUG LOG ==================

      END IF;

      IF (funcmode <> 'RUN') THEN
         result := 'COMPLETE';
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Reset_du_statuses.Msg6',
                              ' funcmode <> RUN -- result --> ' || result);
         -- =============== END DEBUG LOG ==================
         return;
      END IF;

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Reset_du_statuses.Msg7',
                           ' ** END RESET_DU_STATUSES ** ');
      -- =============== END DEBUG LOG ==================

   EXCEPTION
      WHEN OTHERS THEN
         wf_core.context('IGI_EXP_APPROVAL_PKG','reset_du_statuses',itemtype,itemkey,
                         to_char(actid),funcmode);
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_UNEXP_ERROR ('Reset_du_statuses.Unexp1','DEFAULT');
         -- =============== END DEBUG LOG ==================
         raise;

   END reset_du_statuses;



   -- *************************************************************************
   --    CHECK_DUS_ACTIONED
   -- *************************************************************************

   PROCEDURE check_dus_actioned   ( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2) IS

      l_tu_id       igi_exp_tus.tu_id%TYPE;
      l_no_of_dus   NUMBER;

   BEGIN

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Check_dus_actioned.Msg1',
                           ' ** START CHECK_DUS_ACTIONED ** ');
      -- =============== END DEBUG LOG ==================

      IF (funcmode = 'RUN') THEN

         -- Get the TU id
         l_tu_id
            := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'TU_ID');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Check_dus_actioned.Msg2',
                              ' GetItemAttrNumber TU_ID --> ' || l_tu_id);
         -- =============== END DEBUG LOG ==================

         -- Check that all the DUs in the TU have been actioned
         -- i.e. that they have been set to a status of Approved(APP)
         -- Rejected (REJ) or On Hold (HLD)
         SELECT count(*)
         INTO   l_no_of_dus
         FROM   igi_exp_dus
         WHERE  tu_id = l_tu_id
         AND    du_status NOT IN ('APP','REJ','HLD');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Check_dus_actioned.Msg3',
                              ' l_no_of_dus --> '|| l_no_of_dus);
         -- =============== END DEBUG LOG ==================

         IF (l_no_of_dus <> 0) THEN
            -- At least one du has not been actioned
            -- Set the result to 'Yes'
            result := 'COMPLETE:Y';
         ELSE
            -- All the dus have been actioned
            -- Set the result to 'No'
            result := 'COMPLETE:N';
         END IF;

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Check_dus_actioned.Msg4',
                              ' result --> ' || result);
         -- =============== END DEBUG LOG ==================

      END IF;

      IF (funcmode <> 'RUN') THEN
         result := 'COMPLETE';
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Check_dus_actioned.Msg5',
                              ' funcmode <> RUN -- result --> ' || result);
         -- =============== END DEBUG LOG ==================
         return;
      END IF;

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Check_dus_actioned.Msg6',
                           ' ** END CHECK_DUS_ACTIONED ** ');
      -- =============== END DEBUG LOG ==================

   EXCEPTION
      WHEN OTHERS THEN
         wf_core.context('IGI_EXP_APPROVAL_PKG','check_dus_actioned',itemtype,itemkey,
                         to_char(actid),funcmode);
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_UNEXP_ERROR ('Check_dus_actioned.Unexp1','DEFAULT');
         -- =============== END DEBUG LOG ==================
         raise;

   END check_dus_actioned;


   -- *************************************************************************
   --    SET_DUS_TO_ATR
   -- *************************************************************************

   PROCEDURE set_dus_to_atr       ( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2) IS

      l_tu_id   igi_exp_tus.tu_id%TYPE;

   BEGIN

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Set_dus_to_atr.Msg1',
                           ' ** START SET_DUS_TO_ATR ** ');
      -- =============== END DEBUG LOG ==================

      IF (funcmode = 'RUN') THEN

         -- Need to set approved DUs to status 'Approved and Transmitted'
         -- Get the TU id
         l_tu_id
            := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'TU_ID');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Set_dus_to_atr.Msg2',
                              ' GetItemAttrNumber TU_ID --> ' || l_tu_id);
         -- =============== END DEBUG LOG ==================

         UPDATE igi_exp_dus
         SET    du_status = 'ATR'
         WHERE  du_status = 'APP'
         AND    tu_id = l_tu_id;

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Set_dus_to_atr.Msg3',
                              ' UPDATE igi_exp_dus APP - ATR');
         -- =============== END DEBUG LOG ==================

      END IF;

      IF (funcmode <> 'RUN') THEN
         result := 'COMPLETE';
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Set_dus_to_atr.Msg4',
                              ' funcmode <> RUN  -- result --> ' || result);
         -- =============== END DEBUG LOG ==================
         return;
      END IF;

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Set_dus_to_atr.Msg5',
                           ' ** END SET_DUS_TO_ATR ** ');
      -- =============== END DEBUG LOG ==================

   EXCEPTION
      WHEN OTHERS THEN
         wf_core.context('IGI_EXP_APPROVAL_PKG','set_dus_to_atr',itemtype,itemkey,
                         to_char(actid),funcmode);
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_UNEXP_ERROR ('Set_dus_to_atr.Unexp1','DEFAULT');
         -- =============== END DEBUG LOG ==================
         raise;
   END set_dus_to_atr;

   -- *************************************************************************
   --    LIST_ANY_DUS_ON_HOLD
   -- *************************************************************************

   PROCEDURE list_any_dus_on_hold ( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2)
   IS


      CURSOR c_du_hold_info(p_tu_id igi_exp_dus.tu_id%TYPE)
      IS
         SELECT du_order_number
               ,du_legal_number
         FROM   igi_exp_dus
         WHERE  tu_id = p_tu_id
         AND    du_status = 'HLD';

      l_tu_id         igi_exp_dus.tu_id%TYPE;
      l_hold_count    NUMBER;
      l_du_hold_list  VARCHAR2(28000);

   BEGIN

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'List_any_dus_on_hold.Msg1',
                           ' ** START LIST_ANY_DUS_ON_HOLD ** ');
      -- =============== END DEBUG LOG ==================

      IF (funcmode = 'RUN') THEN

         -- Get the TU id
         l_tu_id
            := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'TU_ID');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'List_any_dus_on_hold.Msg2',
                              ' GetItemAttrNumber TU_ID --> ' || l_tu_id);
         -- =============== END DEBUG LOG ==================

         SELECT count(*)
         INTO   l_hold_count
         FROM   igi_exp_dus
         WHERE  du_status = 'HLD'
         AND    tu_id = l_tu_id;

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'List_any_dus_on_hold.Msg3',
                              ' l_hold_count --> ' || l_hold_count);
         -- =============== END DEBUG LOG ==================

         IF (l_hold_count = 0) THEN
            -- No DUs have been put on hold
            -- Set result to 'No'
            result := 'COMPLETE:N';
            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'List_any_dus_on_hold.Msg4',
                                 ' l_hold_count = 0 -- result --> ' || result);
            -- =============== END DEBUG LOG ==================

         ELSE
            -- At least one DU has been put on hold
            -- Need to create a list of numbers of all DUs put on hold
            -- for including in the notification


            FOR I IN c_du_hold_info(l_tu_id)
            LOOP

               IF (l_du_hold_list is NULL) THEN
                  l_du_hold_list := I.du_order_number;
               ELSE
                  l_du_hold_list := l_du_hold_list ||I.du_order_number;
               END IF;

               -- =============== START DEBUG LOG ================
                  DEBUG_LOG_STRING (l_proc_level, 'List_any_dus_on_hold.Msg5',
                                    ' du_order_number --> ' || I.du_order_number);
               -- =============== END DEBUG LOG ==================

               IF (I.du_legal_number is not null) THEN
                  l_du_hold_list := l_du_hold_list||' ('||I.du_legal_number||')';
               END IF;

               -- =============== START DEBUG LOG ================
                  DEBUG_LOG_STRING (l_proc_level, 'List_any_dus_on_hold.Msg6',
                                    ' I.du_legal_number --> ' || I.du_legal_number);
               -- =============== END DEBUG LOG ==================

               l_du_hold_list := l_du_hold_list||fnd_global.local_chr(10);

               IF LENGTH(l_du_hold_list) > 28000 THEN
                  exit;
               END IF;

            END LOOP;

           -- Set the all_dus_list attribute
            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ADD_ATTR1',
                                         avalue   => substr(l_du_hold_list, 1, 4000));

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'List_any_dus_on_hold.Msg7',
                                 ' SetItemAttrText ADD_ATTR1 --> ' || substr(l_du_hold_list, 1, 4000));
            -- =============== END DEBUG LOG ==================

            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ADD_ATTR2',
                                         avalue   => substr(l_du_hold_list, 4001, 4000));

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'List_any_dus_on_hold.Msg8',
                                 ' SetItemAttrText ADD_ATTR2 --> ' || substr(l_du_hold_list, 4001, 4000));
            -- =============== END DEBUG LOG ==================

            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ADD_ATTR3',
                                         avalue   => substr(l_du_hold_list, 8001, 4000));

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'List_any_dus_on_hold.Msg9',
                                 ' SetItemAttrText ADD_ATTR3 --> ' || substr(l_du_hold_list, 8001, 4000));
            -- =============== END DEBUG LOG ==================

            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ADD_ATTR4',
                                         avalue   => substr(l_du_hold_list, 12001, 4000));

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'List_any_dus_on_hold.Msg10',
                                 ' SetItemAttrText ADD_ATTR4 --> ' || substr(l_du_hold_list, 12001, 4000));
            -- =============== END DEBUG LOG ==================

            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ADD_ATTR5',
                                         avalue   => substr(l_du_hold_list, 16001, 4000));

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'List_any_dus_on_hold.Msg11',
                                 ' SetItemAttrText ADD_ATTR5 --> ' || substr(l_du_hold_list, 16001, 4000));
            -- =============== END DEBUG LOG ==================

            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ADD_ATTR6',
                                         avalue   => substr(l_du_hold_list, 20001, 4000));

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'List_any_dus_on_hold.Msg12',
                                 ' SetItemAttrText ADD_ATTR6 --> ' || substr(l_du_hold_list, 20001, 4000));
            -- =============== END DEBUG LOG ==================

            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ADD_ATTR7',
                                         avalue   => substr(l_du_hold_list, 24001, 4000));


            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'List_any_dus_on_hold.Msg13',
                                 ' SetItemAttrText ADD_ATTR7 --> ' || substr(l_du_hold_list, 24001, 4000));
            -- =============== END DEBUG LOG ==================

            -- Set the all_dus_list attribute
            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ALL_DUS_LIST',
                                         avalue   => 'plsqlclob:igi_exp_approval_pkg.Create_du_list/'||itemtype||':'||itemkey);

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'List_any_dus_on_hold.Msg14',
                                 ' SetItemAttrText ALL_DUS_LIST --> ' ||
                                 ' plsqlclob:igi_exp_approval_pkg.Create_du_list/'||itemtype||':'||itemkey);
            -- =============== END DEBUG LOG ==================


            -- Set the result to 'Yes'
            result := 'COMPLETE:Y';

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'List_any_dus_on_hold.Msg15',
                                 ' result --> ' || result);
            -- =============== END DEBUG LOG ==================

         END IF;

      END IF;

      IF (funcmode <> 'RUN') THEN
         result := 'COMPLETE';
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'List_any_dus_on_hold.Msg16',
                              ' funcmode <> RUN -- result --> ' || result);
         -- =============== END DEBUG LOG ==================
         return;
      END IF;

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'List_any_dus_on_hold.Msg17',
                           ' ** END LIST_ANY_DUS_ON_HOLD ** ');
      -- =============== END DEBUG LOG ==================

   EXCEPTION
      WHEN OTHERS THEN
         wf_core.context('IGI_EXP_APPROVAL_PKG','list_any_dus_on_hold',itemtype,itemkey,
                         to_char(actid),funcmode);
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_UNEXP_ERROR ('List_any_dus_on_hold.Unexp1','DEFAULT');
         -- =============== END DEBUG LOG ==================
         raise;

   END list_any_dus_on_hold;


   -- *************************************************************************
   --    GET_NEXT_DU_ON_HOLD
   -- *************************************************************************

   PROCEDURE get_next_du_on_hold  ( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2) IS

      CURSOR c_next_du_hld(p_tu_id igi_exp_dus.tu_id%TYPE)
      IS
         SELECT du_id
               ,du_by_user_id
         FROM   igi_exp_dus
         WHERE  tu_id = p_tu_id
         AND    du_status = 'HLD'
         AND    rownum = 1;

      CURSOR c_du_info(p_tu_id igi_exp_dus.tu_id%TYPE
                      ,p_du_preparer_id igi_exp_dus.du_by_user_id%TYPE)
      IS
         SELECT du_order_number
               ,du_legal_number
         FROM   igi_exp_dus
         WHERE  tu_id = p_tu_id
         AND    du_status = 'HLD'
         AND    du_by_user_id = p_du_preparer_id;

      l_tu_id            igi_exp_dus.tu_id%TYPE;
      l_du_id            igi_exp_dus.du_id%TYPE;
      l_du_prep_id       igi_exp_dus.du_by_user_id%TYPE;
      l_du_prep_name     fnd_user.user_name%TYPE;
      l_du_by_prep_list  VARCHAR2(28000);

   BEGIN

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Get_next_du_on_hold.Msg1',
                           ' ** START GET_NEXT_DU_ON_HOLD  ** ');
      -- =============== END DEBUG LOG ==================

      IF (funcmode = 'RUN') THEN

         -- Get the TU id
         l_tu_id
            := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'TU_ID');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Get_next_du_on_hold.Msg2',
                              ' GetItemAttrNumber TU_ID --> ' || l_tu_id);
         -- =============== END DEBUG LOG ==================

         OPEN  c_next_du_hld(l_tu_id);
         FETCH c_next_du_hld INTO l_du_id,l_du_prep_id;

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Get_next_du_on_hold.Msg3',
                              ' l_du_id --> ' || l_du_id ||
                              ' l_du_prep_id --> ' || l_du_prep_id );
         -- =============== END DEBUG LOG ==================

         IF c_next_du_hld%NOTFOUND THEN
            result := 'COMPLETE:NO_DUS_IN_LIST';
            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Get_next_du_on_hold.Msg4',
                                 ' c_next_du_hld%NOTFOUND -- result --> ' || result );
            -- =============== END DEBUG LOG ==================

         ELSE

            -- The next DU has been fetched
            -- Set the temp_du_preparer_id attribute
            wf_engine.SetItemAttrNumber( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'TEMP_DU_PREPARER_ID',
                                         avalue   => l_du_prep_id);

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Get_next_du_on_hold.Msg5',
                                 ' SetItemAttrNumber TEMP_DU_PREPARER_ID --> ' || l_du_prep_id);
            -- =============== END DEBUG LOG ==================

            -- Get the name of the preparer to send the notification to
            SELECT user_name
            INTO   l_du_prep_name
            FROM   fnd_user
            WHERE  user_id = l_du_prep_id;

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Get_next_du_on_hold.Msg6',
                                 ' l_du_prep_name --> ' || l_du_prep_name);
            -- =============== END DEBUG LOG ==================

            -- Set the temp_du_preparer_name attribute
            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'TEMP_DU_PREPARER_NAME',
                                         avalue   => l_du_prep_name);

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Get_next_du_on_hold.Msg7',
                                 ' SetItemAttrText TEMP_DU_PREPARER_NAME --> ' || l_du_prep_name );
            -- =============== END DEBUG LOG ==================

            -- Find all 'On Hold' DUs prepared by this user and create list
            -- to use in notification

            FOR I IN c_du_info(l_tu_id,l_du_prep_id)
            LOOP

               IF (l_du_by_prep_list is NULL) THEN
                  l_du_by_prep_list := I.du_order_number;
               ELSE
                  l_du_by_prep_list := l_du_by_prep_list ||I.du_order_number;
               END IF;

               -- =============== START DEBUG LOG ================
                  DEBUG_LOG_STRING (l_proc_level, 'Get_next_du_on_hold.Msg8',
                                    ' I.du_order_number --> ' || I.du_order_number);
               -- =============== END DEBUG LOG ==================

               IF (I.du_legal_number is not null) THEN
                  l_du_by_prep_list := l_du_by_prep_list||' ('||I.du_legal_number||')';
               END IF;

               -- =============== START DEBUG LOG ================
                  DEBUG_LOG_STRING (l_proc_level, 'Get_next_du_on_hold.Msg9',
                                    ' I.du_legal_number --> ' || I.du_legal_number);
               -- =============== END DEBUG LOG ==================

               l_du_by_prep_list := l_du_by_prep_list||fnd_global.local_chr(10);

               IF LENGTH(l_du_by_prep_list) > 28000 THEN
                  exit;
               END IF;

            END LOOP;

           -- Set the all_dus_list attribute
            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ADD_ATTR1',
                                         avalue   => substr(l_du_by_prep_list, 1, 4000));

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Get_next_du_on_hold.Msg10',
                                 ' SetItemAttrText ADD_ATTR1 --> ' || substr(l_du_by_prep_list, 1, 4000));
            -- =============== END DEBUG LOG ==================

            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ADD_ATTR2',
                                         avalue   => substr(l_du_by_prep_list, 4001, 4000));

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Get_next_du_on_hold.Msg11',
                                 ' SetItemAttrText ADD_ATTR2 --> ' || substr(l_du_by_prep_list, 4001, 4000));
            -- =============== END DEBUG LOG ==================

            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ADD_ATTR3',
                                         avalue   => substr(l_du_by_prep_list, 8001, 4000));

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Get_next_du_on_hold.Msg12',
                                 ' SetItemAttrText ADD_ATTR3 --> ' || substr(l_du_by_prep_list, 8001, 4000));
            -- =============== END DEBUG LOG ==================

            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ADD_ATTR4',
                                         avalue   => substr(l_du_by_prep_list, 12001, 4000));

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Get_next_du_on_hold.Msg13',
                                 ' SetItemAttrText ADD_ATTR4 --> ' || substr(l_du_by_prep_list, 12001, 4000));
            -- =============== END DEBUG LOG ==================

            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ADD_ATTR5',
                                         avalue   => substr(l_du_by_prep_list, 16001, 4000));

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Get_next_du_on_hold.Msg14',
                                 ' SetItemAttrText ADD_ATTR5 --> ' || substr(l_du_by_prep_list, 16001, 4000));
            -- =============== END DEBUG LOG ==================

            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ADD_ATTR6',
                                         avalue   => substr(l_du_by_prep_list, 20001, 4000));

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Get_next_du_on_hold.Msg15',
                                 ' SetItemAttrText ADD_ATTR6 --> ' || substr(l_du_by_prep_list, 20001, 4000));
            -- =============== END DEBUG LOG ==================

            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ADD_ATTR7',
                                         avalue   => substr(l_du_by_prep_list, 24001, 4000));


            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Get_next_du_on_hold.Msg16',
                                 ' SetItemAttrText ADD_ATTR7 --> ' || substr(l_du_by_prep_list, 24001, 4000));
            -- =============== END DEBUG LOG ==================

            -- Set the temp_du_by_prep_list attribute
            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'TEMP_DU_BY_PREP_LIST',
                                         avalue   => 'plsqlclob:igi_exp_approval_pkg.Create_du_list/'||itemtype||':'||itemkey);

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Get_next_du_on_hold.Msg17',
                                 ' SetItemAttrText TEMP_DU_BY_PREP_LIST --> ' ||
                                 'plsqlclob:igi_exp_approval_pkg.Create_du_list/'||itemtype||':'||itemkey);
            -- =============== END DEBUG LOG ==================

            -- Set the result to 'Next DU Fetched'
            result := 'COMPLETE:NEXT_DU_FETCHED';

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Get_next_du_on_hold.Msg18',
                                 ' result --> ' || result);
            -- =============== END DEBUG LOG ==================

         END IF;

         IF (c_next_du_hld%ISOPEN) THEN
            CLOSE c_next_du_hld;
         END IF;

      END IF;

      IF (funcmode <> 'RUN') THEN
         result := 'COMPLETE';
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Get_next_du_on_hold.Msg19',
                              'funcmode <> RUN -- result --> ' || result);
         -- =============== END DEBUG LOG ==================
         return;
      END IF;

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Get_next_du_on_hold.Msg20',
                           ' ** END GET_NEXT_DU_ON_HOLD  ** ');
      -- =============== END DEBUG LOG ==================

   EXCEPTION
      WHEN OTHERS THEN
         wf_core.context('IGI_EXP_APPROVAL_PKG','get_next_du_on_hold',itemtype,itemkey,
                         to_char(actid),funcmode);
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_UNEXP_ERROR ('Get_next_du_on_hold.Unexp1','DEFAULT');
         -- =============== END DEBUG LOG ==================
         raise;

   END get_next_du_on_hold;


   -- *************************************************************************
   --    REMOVE_DUS_ON_HOLD
   -- *************************************************************************

   PROCEDURE remove_dus_on_hold   ( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2) IS

      l_tu_id      igi_exp_dus.tu_id%TYPE;
      l_du_prep_id igi_exp_dus.du_by_user_id%TYPE;
      l_du_amount  igi_exp_dus.du_amount%TYPE;

   BEGIN

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Remove_dus_on_hold.Msg1',
                           ' ** START REMOVE_DUS_ON_HOLD  ** ');
      -- =============== END DEBUG LOG ==================

      IF (funcmode = 'RUN') THEN

         -- Get the TU id
         l_tu_id
            := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'TU_ID');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Remove_dus_on_hold.Msg2',
                              ' GetItemAttrNumber TU_ID --> '|| l_tu_id);
         -- =============== END DEBUG LOG ==================

         -- Get the DU Preparer id
         l_du_prep_id
            := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'TEMP_DU_PREPARER_ID');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Remove_dus_on_hold.Msg3',
                              ' GetItemAttrNumber TEMP_DU_PREPARER_ID --> ' || l_du_prep_id);
         -- =============== END DEBUG LOG ==================

         -- Before releasing DUs from this TU, want to update the TU amount
         -- i.e. New TU amount = TU amount - released DU amount
         -- Find the total amount of all DUs about to be released
         SELECT sum(du_amount)
         INTO   l_du_amount
         FROM   igi_exp_dus
         WHERE  tu_id = l_tu_id
         AND    du_by_user_id = l_du_prep_id
         AND    du_status = 'HLD';

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Remove_dus_on_hold.Msg4',
                              ' l_du_amount --> ' || l_du_amount);
         -- =============== END DEBUG LOG ==================

         -- Now update the TU amount
         UPDATE igi_exp_tus
         SET    tu_amount = tu_amount - l_du_amount
         WHERE  tu_id = l_tu_id;

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Remove_dus_on_hold.Msg5',
                              '  UPDATE igi_exp_tus tu-amount ' || SQL%ROWCOUNT);
         -- =============== END DEBUG LOG ==================

         -- Want to release all DUs in this TU with status 'On Hold' which
         -- have been prepared by this user.

         UPDATE igi_exp_dus
         SET    tu_id = null
         WHERE  tu_id = l_tu_id
         AND    du_by_user_id = l_du_prep_id
         AND    du_status = 'HLD';

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Remove_dus_on_hold.Msg6',
                              ' UPDATE igi_exp_dus tu_id to NULL --> ' || SQL%ROWCOUNT);
         -- =============== END DEBUG LOG ==================

      END IF;

      IF (funcmode <> 'RUN') THEN
         result := 'COMPLETE';
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Remove_dus_on_hold.Msg7',
                              ' funcmode <> RUN -- result --> ' || result);
         -- =============== END DEBUG LOG ==================
         return;
      END IF;

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Remove_dus_on_hold.Msg8',
                           ' ** START REMOVE_DUS_ON_HOLD  ** ');
      -- =============== END DEBUG LOG ==================

   EXCEPTION
      WHEN OTHERS THEN
         wf_core.context('IGI_EXP_APPROVAL_PKG','remove_dus_on_hold',itemtype,itemkey,
                         to_char(actid),funcmode);
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_UNEXP_ERROR ('Remove_dus_on_hold.Unexp1','DEFAULT');
         -- =============== END DEBUG LOG ==================
         raise;

   END remove_dus_on_hold;


-- OPSF(I) EXP Bug 2415293  S Brewer 11-JUL-2002 Start(1)
-- Modified the select statements in the following procedure to make them simpler
-- Only check for rejected DUs - do not need to check if the DUs contain transactions
-- This procedure can then be used in the 'Process Rejected Legal DUs' workflow
-- process too.
-- To see previous version of this procedure, look at previous file versions

   -- *************************************************************************
   --    LIST_ANY_REJECTED_DUS
   -- *************************************************************************

   PROCEDURE list_any_rejected_dus( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2) IS

      CURSOR c_du_rej_info(p_tu_id igi_exp_dus.tu_id%TYPE)
      IS
         SELECT du_order_number
               ,du_legal_number
         FROM   igi_exp_dus du
         WHERE  tu_id = p_tu_id
         AND    du_status = 'REJ';

      l_tu_id        igi_exp_dus.tu_id%TYPE;
      l_rej_count    NUMBER;
      l_du_rej_list  VARCHAR2(28000);


   BEGIN

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'List_any_rejected_dus.Msg1',
                           ' ** START LIST_ANY_REJECTED_DUS ** ');
      -- =============== END DEBUG LOG ==================

      IF (funcmode = 'RUN') THEN

         -- Get the TU id
         l_tu_id
            := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'TU_ID');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'List_any_rejected_dus.Msg2',
                              ' l_tu_id --> ' || l_tu_id);
         -- =============== END DEBUG LOG ==================

         -- Find out NOCOPY if there are any DUs which have been rejected
         -- (i.e. if the status of the DU is 'Rejected' )
         SELECT count(*)
         INTO   l_rej_count
         FROM   igi_exp_dus du
         WHERE  tu_id = l_tu_id
         AND    du_status = 'REJ';

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'List_any_rejected_dus.Msg3',
                              ' l_rej_count --> ' || l_rej_count);
         -- =============== END DEBUG LOG ==================

         IF (l_rej_count = 0) THEN
            --  There are no DUs in the TU which have been rejected
            -- Set the result to 'No'
            result := 'COMPLETE:N';

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'List_any_rejected_dus.Msg4',
                                 ' l_rej_count --> ' || l_rej_count);
            -- =============== END DEBUG LOG ==================

         ELSE

            -- There is at least one DU in the TU which has been rejected
            -- Need to create a list of numbers of all rejected DUs
            -- for including in the notification
            FOR I IN c_du_rej_info(l_tu_id)
            LOOP

               IF (l_du_rej_list is NULL) THEN
                  l_du_rej_list := I.du_order_number;
               ELSE
                  l_du_rej_list := l_du_rej_list||I.du_order_number;
               END IF;

               -- =============== START DEBUG LOG ================
                  DEBUG_LOG_STRING (l_proc_level, 'List_any_rejected_dus.Msg5',
                                    ' I.du_order_number --> ' || I.du_order_number);
               -- =============== END DEBUG LOG ==================

               IF (I.du_legal_number is not null) THEN
                  l_du_rej_list := l_du_rej_list||' ('||I.du_legal_number||')';
               END IF;

               -- =============== START DEBUG LOG ================
                  DEBUG_LOG_STRING (l_proc_level, 'List_any_rejected_dus.Msg6',
                                    ' I.du_legal_number --> ' || I.du_legal_number);
               -- =============== END DEBUG LOG ==================

               l_du_rej_list := l_du_rej_list||fnd_global.local_chr(10);

               IF LENGTH(l_du_rej_list) > 28000 THEN
                  exit;
               END IF;

            END LOOP;

            -- Set the all_dus_list attribute
            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ADD_ATTR1',
                                         avalue   => substr(l_du_rej_list, 1, 4000));

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'List_any_rejected_dus.Msg7',
                                 ' SetItemAttrText ADD_ATTR1 --> ' || substr(l_du_rej_list, 1, 4000));
            -- =============== END DEBUG LOG ==================

            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ADD_ATTR2',
                                         avalue   => substr(l_du_rej_list, 4001, 4000));

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'List_any_rejected_dus.Msg8',
                                 ' SetItemAttrText ADD_ATTR2 --> ' || substr(l_du_rej_list, 4001, 4000));
            -- =============== END DEBUG LOG ==================

            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ADD_ATTR3',
                                         avalue   => substr(l_du_rej_list, 8001, 4000));

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'List_any_rejected_dus.Msg9',
                                 ' SetItemAttrText ADD_ATTR3 --> ' || substr(l_du_rej_list, 8001, 4000));
            -- =============== END DEBUG LOG ==================

            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ADD_ATTR4',
                                         avalue   => substr(l_du_rej_list, 12001, 4000));

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'List_any_rejected_dus.Msg10',
                                 ' SetItemAttrText ADD_ATTR4 --> ' || substr(l_du_rej_list, 12001, 4000));
            -- =============== END DEBUG LOG ==================

            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ADD_ATTR5',
                                         avalue   => substr(l_du_rej_list, 16001, 4000));

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'List_any_rejected_dus.Msg11',
                                 ' SetItemAttrText ADD_ATTR5 --> ' || substr(l_du_rej_list, 16001, 4000));
            -- =============== END DEBUG LOG ==================

            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ADD_ATTR6',
                                         avalue   => substr(l_du_rej_list, 20001, 4000));

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'List_any_rejected_dus.Msg12',
                                 ' SetItemAttrText ADD_ATTR6 --> ' || substr(l_du_rej_list, 20001, 4000));
            -- =============== END DEBUG LOG ==================

            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ADD_ATTR7',
                                         avalue   => substr(l_du_rej_list, 24001, 4000));

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'List_any_rejected_dus.Msg13',
                                 ' SetItemAttrText ADD_ATTR7 --> ' || substr(l_du_rej_list, 24001, 4000));
            -- =============== END DEBUG LOG ==================

            -- Set the temp_du_by_prep_list attribute
            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ALL_DUS_LIST',
                                         avalue   => 'plsqlclob:igi_exp_approval_pkg.Create_du_list/'||itemtype||':'||itemkey);

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'List_any_rejected_dus.Msg14',
                                 ' SetItemAttrText ALL_DUS_LIST --> ' ||
                                 ' plsqlclob:igi_exp_approval_pkg.Create_du_list/'||itemtype||':'||itemkey);
            -- =============== END DEBUG LOG ==================

            -- Set the result to 'Yes'
            result := 'COMPLETE:Y';

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'List_any_rejected_dus.Msg15',
                                 ' result --> ' || result);
            -- =============== END DEBUG LOG ==================

        END IF;

      END IF;

      IF (funcmode <> 'RUN') THEN
         result := 'COMPLETE';
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'List_any_rejected_dus.Msg16',
                              ' funcmode <> RUN -- result --> ' || result );
         -- =============== END DEBUG LOG ==================
         return;
      END IF;

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'List_any_rejected_dus.Msg17',
                           ' ** END LIST_ANY_REJECTED_DUS ** ');
      -- =============== END DEBUG LOG ==================

   EXCEPTION
      WHEN OTHERS THEN
         wf_core.context('IGI_EXP_APPROVAL_PKG','list_any_rejected_dus',itemtype,itemkey,
                         to_char(actid),funcmode);
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_UNEXP_ERROR ('List_any_rejected_dus.Unexp1','DEFAULT');
         -- =============== END DEBUG LOG ==================
         raise;

   END list_any_rejected_dus;


-- OPSF(I) EXP Bug 2415293  S Brewer 11-JUL-2002 Start(2)
-- Modified the select statements in the following procedure to make them simpler
-- Only check for rejected DUs - do not need to check if the DUs contain transactions
-- To see previous version of this procedure, look at previous file versions

   -- *************************************************************************
   --    GET_NEXT_REJECTED_DU
   -- *************************************************************************

   PROCEDURE get_next_rejected_du ( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2) IS

      CURSOR c_next_du_rej(p_tu_id igi_exp_dus.tu_id%TYPE)
      IS
         SELECT du_id
               ,du_by_user_id
         FROM   igi_exp_dus du
         WHERE  tu_id = p_tu_id
         AND    du_status = 'REJ'
	 AND    EXISTS (SELECT 'AR'
                        FROM   igi_exp_ar_trans ar
                        WHERE  ar.du_id = du.du_id
                        UNION
                        SELECT 'AP'
                        FROM   igi_exp_ap_trans ap
                        WHERE  ap.du_id = du.du_id)
         AND    rownum = 1;

      CURSOR c_rej_du_info(p_tu_id igi_exp_dus.tu_id%TYPE
                          ,p_du_preparer_id igi_exp_dus.du_by_user_id%TYPE)
      IS
         SELECT du_order_number
               ,du_legal_number
         FROM   igi_exp_dus du
         WHERE  tu_id = p_tu_id
         AND    du_status = 'REJ'
         AND    du_by_user_id = p_du_preparer_id;

      l_tu_id           igi_exp_dus.tu_id%TYPE;
      l_du_id           igi_exp_dus.du_id%TYPE;
      l_du_prep_id      igi_exp_dus.du_by_user_id%TYPE;
      l_du_prep_name    fnd_user.user_name%TYPE;
      l_no              NUMBER := 0 ;
      l_du_rej_list     VARCHAR2(28000);

   BEGIN

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Get_next_rejected_du.Msg1',
                           ' ** START GET_NEXT_REJECTED_DU ** ');
      -- =============== END DEBUG LOG ==================

      IF (funcmode = 'RUN') THEN

         -- Get the TU id
         l_tu_id
            := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'TU_ID');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Get_next_rejected_du.Msg2',
                              'GetItemAttrNumber TU_ID --> ' || l_tu_id );
         -- =============== END DEBUG LOG ==================

         -- Get the next rejected DU in this TU
         OPEN c_next_du_rej(l_tu_id);
         FETCH c_next_du_rej INTO l_du_id, l_du_prep_id;

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Get_next_rejected_du.Msg3',
                              ' l_du_id --> ' || l_du_id || ' l_du_prep_id --> ' || l_du_prep_id);
         -- =============== END DEBUG LOG ==================

         IF (c_next_du_rej%NOTFOUND) THEN
            -- There are no more rejected DUs to deal with
            -- Set result to 'No More DUs'
            result := 'COMPLETE:NO_DUS_IN_LIST';

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Get_next_rejected_du.Msg4',
                                 ' result --> ' || result);
            -- =============== END DEBUG LOG ==================

         ELSE

            -- The next rejected DU has been fetched
            -- Set the temp_du_preparer_id attribute
            wf_engine.SetItemAttrNumber( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'TEMP_DU_PREPARER_ID',
                                         avalue   => l_du_prep_id);

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Get_next_rejected_du.Msg5',
                                 ' SetItemAttrNumber TEMP_DU_PREPARER_ID --> ' || l_du_prep_id);
            -- =============== END DEBUG LOG ==================

            -- Get the name of the preparer to send the notification to
            SELECT user_name
            INTO   l_du_prep_name
            FROM   fnd_user
            WHERE  user_id = l_du_prep_id;

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Get_next_rejected_du.Msg6',
                                 ' l_du_prep_name --> ' || l_du_prep_name);
            -- =============== END DEBUG LOG ==================

            -- Set the temp_du_preparer_name attribute
            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'TEMP_DU_PREPARER_NAME',
                                         avalue   => l_du_prep_name);

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Get_next_rejected_du.Msg7',
                                 ' SetItemAttrText TEMP_DU_PREPARER_NAME --> ' || l_du_prep_name);
            -- =============== END DEBUG LOG ==================

            FOR I IN c_rej_du_info(l_tu_id,l_du_prep_id)
            LOOP

               IF (l_du_rej_list is NULL) THEN
                  l_du_rej_list := I.du_order_number;
               ELSE
                  l_du_rej_list := l_du_rej_list ||I.du_order_number;
               END IF;

               -- =============== START DEBUG LOG ================
                  DEBUG_LOG_STRING (l_proc_level, 'Get_next_rejected_du.Msg8',
                                    ' I.du_order_number --> ' || I.du_order_number);
               -- =============== END DEBUG LOG ==================

               IF (I.du_legal_number is not null) THEN
                  l_du_rej_list := l_du_rej_list||' ('||I.du_legal_number||')';
               END IF;

               -- =============== START DEBUG LOG ================
                  DEBUG_LOG_STRING (l_proc_level, 'Get_next_rejected_du.Msg9',
                                    ' I.du_legal_number --> ' || I.du_legal_number);
               -- =============== END DEBUG LOG ==================

               l_du_rej_list := l_du_rej_list||fnd_global.local_chr(10);

               IF LENGTH(l_du_rej_list) > 28000 THEN
                  exit;
               END IF;

            END LOOP;

           -- Set the all_dus_list attribute
            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ADD_ATTR1',
                                         avalue   => substr(l_du_rej_list, 1, 4000));

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Get_next_rejected_du.Msg10',
                                 ' SetItemAttrText ADD_ATTR1 --> ' || substr(l_du_rej_list, 1, 4000));
            -- =============== END DEBUG LOG ==================

            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ADD_ATTR2',
                                         avalue   => substr(l_du_rej_list, 4001, 4000));

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Get_next_rejected_du.Msg11',
                                 ' SetItemAttrText ADD_ATTR2 --> ' || substr(l_du_rej_list, 4001, 4000));
            -- =============== END DEBUG LOG ==================

            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ADD_ATTR3',
                                         avalue   => substr(l_du_rej_list, 8001, 4000));

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Get_next_rejected_du.Msg12',
                                 ' SetItemAttrText ADD_ATTR3 --> ' || substr(l_du_rej_list, 8001, 4000));
            -- =============== END DEBUG LOG ==================

            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ADD_ATTR4',
                                         avalue   => substr(l_du_rej_list, 12001, 4000));

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Get_next_rejected_du.Msg13',
                                 ' SetItemAttrText ADD_ATTR4 --> ' || substr(l_du_rej_list, 12001, 4000));
            -- =============== END DEBUG LOG ==================

            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ADD_ATTR5',
                                         avalue   => substr(l_du_rej_list, 16001, 4000));

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Get_next_rejected_du.Msg14',
                                 ' SetItemAttrText ADD_ATTR5 --> ' || substr(l_du_rej_list, 16001, 4000));
            -- =============== END DEBUG LOG ==================

            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ADD_ATTR6',
                                         avalue   => substr(l_du_rej_list, 20001, 4000));

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Get_next_rejected_du.Msg15',
                                 ' SetItemAttrText ADD_ATTR6 --> ' || substr(l_du_rej_list, 20001, 4000));
            -- =============== END DEBUG LOG ==================

            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ADD_ATTR7',
                                         avalue   => substr(l_du_rej_list, 24001, 4000));


            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Get_next_rejected_du.Msg16',
                                 ' SetItemAttrText ADD_ATTR7 --> ' || substr(l_du_rej_list, 24001, 4000));
            -- =============== END DEBUG LOG ==================

            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'TEMP_DU_BY_PREP_LIST',
                                         avalue   => 'plsqlclob:igi_exp_approval_pkg.Create_du_list/'||itemtype||':'||itemkey);

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Get_next_rejected_du.Msg17',
                                 ' SetItemAttrText ALL_DUS_LIST --> ' ||
                                 ' plsqlclob:igi_exp_approval_pkg.Cerate_du_list/'||itemtype||':'||itemkey);
            -- =============== END DEBUG LOG ==================

            -- Set the result to 'Next DU Fetched'
            result := 'COMPLETE:NEXT_DU_FETCHED';

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Get_next_rejected_du.Msg18',
                                 ' result --> ' || result);
            -- =============== END DEBUG LOG ==================

         END IF;

         IF (c_next_du_rej%ISOPEN) THEN
            CLOSE c_next_du_rej;
         END IF;

      END IF;

      IF (funcmode <> 'RUN') THEN
         result := 'COMPLETE';
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Get_next_rejected_du.Msg19',
                              ' funcmode <> RUN -- result --> ' || result);
         -- =============== END DEBUG LOG ==================
         return;
      END IF;

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Get_next_rejected_du.Msg20',
                           ' ** END GET_NEXT_REJECTED_DU ** ');
      -- =============== END DEBUG LOG ==================

   EXCEPTION
      WHEN OTHERS THEN
         wf_core.context('IGI_EXP_APPROVAL_PKG','get_next_rejected_du',itemtype,itemkey,
                         to_char(actid),funcmode);
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_UNEXP_ERROR ('Get_next_rejected_du.Unexp1','DEFAULT');
         -- =============== END DEBUG LOG ==================
         raise;

   END get_next_rejected_du;
   -- OPSF(I) EXP Bug 2415293  S Brewer 11-JUL-2002 End(2)



   -- *************************************************************************
   --    REM_TRX_FROM_REJ_DUS
   -- *************************************************************************

   PROCEDURE rem_trx_from_rej_dus ( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2) IS

      CURSOR c_rej_dus(p_tu_id igi_exp_dus.tu_id%TYPE
                      ,p_du_preparer_id igi_exp_dus.du_by_user_id%TYPE)
      IS
         SELECT du_id
         FROM   igi_exp_dus du
         WHERE  tu_id = p_tu_id
         AND    du_status = 'REJ'
         AND    du_by_user_id = p_du_preparer_id
         AND    EXISTS (SELECT 'AR'
                        FROM   igi_exp_ar_trans ar
                        WHERE  ar.du_id = du.du_id
                        UNION
                        SELECT 'AP'
                        FROM   igi_exp_ap_trans ap
                        WHERE  ap.du_id = du.du_id);

      l_tu_id          igi_exp_dus.tu_id%TYPE;
      l_du_prep_id     igi_exp_dus.du_by_user_id%TYPE;
      l_du_id          igi_exp_dus.du_id%TYPE;
      l_du_amount      igi_exp_dus.du_amount%TYPE;

   BEGIN

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Rem_trx_from_rej_dus.Msg1',
                           ' ** START REM_TRX_FROM_REJ_DUS ** ');
      -- =============== END DEBUG LOG ==================

     IF (funcmode = 'RUN') THEN

         -- Want to remove all transactions contained within rejected
         -- dialog units

         -- Get the TU id
         l_tu_id
            := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'TU_ID');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Rem_trx_from_rej_dus.Msg2',
                              ' GetItemAttrNumber TU_ID --> ' || l_tu_id);
         -- =============== END DEBUG LOG ==================

         -- Get the DU preparer id
         l_du_prep_id
            := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'TEMP_DU_PREPARER_ID');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Rem_trx_from_rej_dus.Msg3',
                              ' GetItemAttrNumber TEMP_DU_PREPARER_ID --> '|| l_du_prep_id);
         -- =============== END DEBUG LOG ==================

         FOR I IN c_rej_dus(l_tu_id,l_du_prep_id)
         LOOP

            DELETE FROM igi_exp_ar_trans
            WHERE  du_id = I.du_id;

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Rem_trx_from_rej_dus.Msg4',
                                 'DELETE FROM igi_exp_ar_trans --> ' || SQL%ROWCOUNT);
            -- =============== END DEBUG LOG ==================

            DELETE FROM igi_exp_ap_trans
            WHERE du_id = I.du_id;

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Rem_trx_from_rej_dus.Msg5',
                                 ' DELETE FROM igi_exp_ap_trans --> ' || SQL%ROWCOUNT);
            -- =============== END DEBUG LOG ==================

         END LOOP;

         -- OPSF(I) EXP Bug 2415293  S Brewer 18-JUL-2002 Start(2)
         -- Now that the transactions have been removed from the DUs
         -- need to update the DU amounts to 0.  But before doing
         -- this, update the TU amount
         -- i.e. New TU amount = TU amount - DU amount

         -- First find the total DU amount
         SELECT sum(du_amount)
         INTO   l_du_amount
         FROM   igi_exp_dus
         WHERE  tu_id = l_tu_id
         AND    du_by_user_id = l_du_prep_id
         AND    du_status = 'REJ';

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Rem_trx_from_rej_dus.Msg6',
                              ' l_du_amount --> ' || l_du_amount);
         -- =============== END DEBUG LOG ==================

         -- Update the TU amount
         UPDATE igi_exp_tus
         SET    tu_amount = tu_amount - l_du_amount
         WHERE  tu_id = l_tu_id;

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Rem_trx_from_rej_dus.Msg7',
                              ' UPDATE igi_exp_tus --> ' || SQL%ROWCOUNT);
         -- =============== END DEBUG LOG ==================

         -- Now update the DU amount to 0
         UPDATE igi_exp_dus
         SET    du_amount = 0
         WHERE  tu_id = l_tu_id
         AND    du_by_user_id = l_du_prep_id
         AND    du_status = 'REJ';

         -- OPSF(I) EXP Bug 2415293  S Brewer 18-JUL-2002 End(2)

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Rem_trx_from_rej_dus.Msg8',
                              ' UPDATE igi_exp_dus du_amount = 0 --> ' || SQL%ROWCOUNT);
         -- =============== END DEBUG LOG ==================

      END IF;

      IF (funcmode <> 'RUN') THEN
         result := 'COMPLETE';
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Rem_trx_from_rej_dus.Msg9',
                              ' funcmode <> RUN -- result --> ' || result);
         -- =============== END DEBUG LOG ==================
         return;
      END IF;

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Rem_trx_from_rej_dus.Msg10',
                           ' ** END REM_TRX_FROM_REJ_DUS ** ');
      -- =============== END DEBUG LOG ==================

   EXCEPTION
      WHEN OTHERS THEN
         wf_core.context('IGI_EXP_APPROVAL_PKG','rem_trx_from_rej_dus',itemtype,itemkey,
                         to_char(actid),funcmode);
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_UNEXP_ERROR ('Rem_trx_from_rej_dus.Unexp1','DEFAULT');
         -- =============== END DEBUG LOG ==================
         raise;

   END rem_trx_from_rej_dus;


   -- *************************************************************************
   --    IS_LEGAL_NUM_REQ
   -- *************************************************************************

   PROCEDURE is_legal_num_req     ( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2) IS

      l_legal_num_pos_id   igi_exp_apprv_profiles.legal_num_pos_id%TYPE;
      l_current_pos_id     per_all_positions.position_id%TYPE;

   BEGIN

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Is_legal_num_req.Msg1',
                           ' ** START IS_LEGAL_NUM_REQ ** ');
      -- =============== END DEBUG LOG ==================

      IF (funcmode = 'RUN') THEN

         -- Get the legal numbering position id
         l_legal_num_pos_id
            := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'LEGAL_NUM_POS_ID');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Is_legal_num_req.Msg2',
                              'GetItemAttrNumber LEGAL_NUM_POS_ID --> ' || l_legal_num_pos_id);
         -- =============== END DEBUG LOG ==================

         -- If the current position is the legal numbering position
         -- the we need to generate legal numbers for the TU and DUs
         -- Get the current position id
         l_current_pos_id
            := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'CURRENT_POSITION_ID');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Is_legal_num_req.Msg3',
                              ' GetItemAttrNumber CURRENT_POSITION_ID --> ' || l_current_pos_id);
         -- =============== END DEBUG LOG ==================

         IF (l_current_pos_id = l_legal_num_pos_id) THEN
            -- Set the result to 'Yes'
            result := 'COMPLETE:Y';
            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Is_legal_num_req.Msg4',
                                 ' l_current_pos_id = l_legal_num_pos_id -- result --> ' || result);
            -- =============== END DEBUG LOG ==================

         ELSE
            -- Set the result to 'No'
            result := 'COMPLETE:N';
            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Is_legal_num_req.Msg5',
                                 ' result --> ' || result);
            -- =============== END DEBUG LOG ==================
         END IF;

      END IF;

      IF (funcmode <> 'RUN') THEN
         result := 'COMPLETE';
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Is_legal_num_req.Msg6',
                              ' funcmode <> RUN -- result --> '|| result );
         -- =============== END DEBUG LOG ==================
         return;
      END IF;

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Is_legal_num_req.Msg7',
                           ' ** END IS_LEGAL_NUM_REQ ** ');
      -- =============== END DEBUG LOG ==================

   EXCEPTION
      WHEN OTHERS THEN
         wf_core.context('IGI_EXP_APPROVAL_PKG','is_legal_num_req',itemtype,itemkey,
                         to_char(actid),funcmode);
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_UNEXP_ERROR ('Is_legal_num_req.Unexp1','DEFAULT');
         -- =============== END DEBUG LOG ==================
          raise;

   END is_legal_num_req;


   -- *************************************************************************
   --    APPLY_TU_LEGAL_NUM
   -- *************************************************************************

   PROCEDURE apply_tu_legal_num   ( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2) IS

      l_tu_id               igi_exp_dus.tu_id%TYPE;
      l_tu_type_header_id   igi_exp_tus.tu_type_header_id%TYPE;
      l_tu_fiscal_year      igi_exp_tus.tu_fiscal_year%TYPE;
      l_tu_legal_number     igi_exp_tus.tu_legal_number%TYPE;
      l_tu_full_number      VARCHAR2(240);
      l_error_message       VARCHAR2(250);

   BEGIN

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Apply_tu_legal_num.Msg1',
                           ' ** START APPLY_TU_LEGAL_NUM ** ');
      -- =============== END DEBUG LOG ==================

     IF (funcmode = 'RUN') THEN

         -- Get the TU id
         l_tu_id
            := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'TU_ID');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Apply_tu_legal_num.Msg2',
                              ' GetItemAttrNumber TU_ID --> ' || l_tu_id );
         -- =============== END DEBUG LOG ==================

         -- Get the TU type and the fiscal year of the TU
         SELECT tu_type_header_id
               ,tu_fiscal_year
         INTO   l_tu_type_header_id
               ,l_tu_fiscal_year
         FROM   igi_exp_tus
         WHERE  tu_id = l_tu_id;

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Apply_tu_legal_num.Msg3',
                              ' l_tu_type_header_id --> ' || l_tu_type_header_id ||
                              ' l_tu_fiscal_year --> ' || l_tu_fiscal_year);
            DEBUG_LOG_STRING (l_proc_level, 'Apply_tu_legal_num.Msg4',
                              ' Calling igi_exp_utils.generate_number ');
         -- =============== END DEBUG LOG ==================

         -- Get the legal number for the TU
         igi_exp_utils.generate_number('TU'                 -- pi_number_type
                                      ,'L'                  -- pi_number_class
                                      ,l_tu_type_header_id  -- pi_du_tu_type_id
                                      ,l_tu_fiscal_year     -- pi_fiscal_year
                                      ,l_tu_legal_number    -- po_du_tu_number
                                      ,l_error_message);    -- po_error_message

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Apply_tu_legal_num.Msg5',
                              ' l_tu_legal_number --> ' || l_tu_legal_number);
         -- =============== END DEBUG LOG ==================

         IF (l_tu_legal_number is null) THEN
            -- An error occurred generating the TU legal number
            -- Set the error message attribute to be used in the
            -- notification sent to the system administrator

            -- Set the error_message attribute
            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ERROR_MESSAGE',
                                         avalue   => l_error_message);

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Apply_tu_legal_num.Msg6',
                                 ' SetItemAttrText ERROR_MESSAGE --> ' || l_error_message);
            -- =============== END DEBUG LOG ==================

            -- Exit with result 'Failure
            result := 'COMPLETE:FAILURE';

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Apply_tu_legal_num.Msg7',
                                 ' result --> ' || result);
            -- =============== END DEBUG LOG ==================

            return;

         ELSE

            -- TU Legal number was generated successfully
            -- Apply the legal number to the TU
            UPDATE igi_exp_tus
            SET    tu_legal_number = l_tu_legal_number
            WHERE  tu_id = l_tu_id;


            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Apply_tu_legal_num.Msg8',
                                 'UPDATE igi_exp_tus -  ' || SQL%ROWCOUNT);
            -- =============== END DEBUG LOG ==================

            -- OPSF(I) EXP Bug 2567802 26-Sep-2002  S Brewer  Start(2)
            -- Set the TU Full Number attribute to include the legal number
            l_tu_full_number
            := wf_engine.GetItemAttrText  ( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'TU_FULL_NUMBER');

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Apply_tu_legal_num.Msg9',
                                 ' GetItemAttrText TU_FULL_NUMBER --> ' || l_tu_full_number);
            -- =============== END DEBUG LOG ==================

            l_tu_full_number := l_tu_full_number||' ('||l_tu_legal_number||')';

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Apply_tu_legal_num.Msg10',
                                 ' l_tu_full_number --> ' || l_tu_full_number);
            -- =============== END DEBUG LOG ==================

            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'TU_FULL_NUMBER',
                                         avalue   => l_tu_legal_number);

            -- OPSF(I) EXP Bug 2567802 26-Sep-2002  S Brewer  End(2)

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Apply_tu_legal_num.Msg11',
                                 ' SetItemAttrText TU_FULL_NUMBER --> ' || l_tu_legal_number);
            -- =============== END DEBUG LOG ==================

            -- Set the result to Success
            result := 'COMPLETE:SUCCESS';

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Apply_tu_legal_num.Msg12',
                                 ' result --> ' || result);
            -- =============== END DEBUG LOG ==================

         END IF;

      END IF;

      IF (funcmode <> 'RUN') THEN
         result := 'COMPLETE';
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Apply_tu_legal_num.Msg13',
                              ' funcmode <> RUN -- result --> ' || result);
         -- =============== END DEBUG LOG ==================
         return;
      END IF;

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Apply_tu_legal_num.Msg14',
                           ' ** END APPLY_TU_LEGAL_NUM ** ');
      -- =============== END DEBUG LOG ==================

   EXCEPTION
      WHEN OTHERS THEN
         wf_core.context('IGI_EXP_APPROVAL_PKG','apply_tu_legal_num',itemtype,itemkey,
                         to_char(actid),funcmode);
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_UNEXP_ERROR ('Apply_tu_legal_num.Unexp1','DEFAULT');
         -- =============== END DEBUG LOG ==================
         raise;

   END apply_tu_legal_num;



   -- *************************************************************************
   --    APPLY_DU_LEGAL_NUM
   -- *************************************************************************

   PROCEDURE apply_du_legal_num   ( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2) IS

      CURSOR c_get_du(p_tu_id  igi_exp_dus.tu_id%TYPE)
      IS
         SELECT du_id
               ,du_type_header_id
               ,du_fiscal_year
               ,du_order_number
         FROM   igi_exp_dus
         WHERE  tu_id = p_tu_id
         AND du_status = 'ATR';

      l_tu_id              igi_exp_dus.tu_id%TYPE;
      l_du_id              igi_exp_dus.du_id%TYPE;
      l_du_type_header_id  igi_exp_dus.du_type_header_id%TYPE;
      l_du_fiscal_year     igi_exp_dus.du_fiscal_year%TYPE;
      l_du_order_number    igi_exp_dus.du_order_number%TYPE;
      l_du_legal_number    igi_exp_dus.du_legal_number%TYPE;
      l_error_message      VARCHAR2(250);
      l_du_failed          VARCHAR2(1):='N';

   BEGIN

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Apply_du_legal_num.Msg1',
                           ' ** START APPLY_DU_LEGAL_NUM ** ');
      -- =============== END DEBUG LOG ==================

      IF (funcmode = 'RUN') THEN

         -- Get the tu id
         l_tu_id
            := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'TU_ID');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Apply_du_legal_num.Msg2',
                              ' GetItemAttrNumber TU_ID --> ' || l_tu_id);
         -- =============== END DEBUG LOG ==================

         savepoint legal_num_save;

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Apply_du_legal_num.Msg3',
                              ' set savepoint legal_num_save ');
         -- =============== END DEBUG LOG ==================

         OPEN c_get_du(l_tu_id);
         LOOP

            FETCH c_get_du INTO l_du_id
                              , l_du_type_header_id
                              , l_du_fiscal_year
                              , l_du_order_number;

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Apply_du_legal_num.Msg4',
                                 ' l_du_id --> ' || l_du_id ||
                                 ' l_du_type_header_id --> ' || l_du_type_header_id ||
                                 ' l_du_fiscal_year --> ' || l_du_fiscal_year ||
                                 ' l_du_order_number --> ' || l_du_order_number);
            -- =============== END DEBUG LOG ==================

            EXIT WHEN c_get_du%NOTFOUND;

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Apply_du_legal_num.Msg5',
                                 ' calling  igi_exp_utils.generate_number ');
            -- =============== END DEBUG LOG ==================

            -- Get the legal number for the DU
            igi_exp_utils.generate_number('DU'                 -- pi_number_type
                                         ,'L'                  -- pi_number_class
                                         ,l_du_type_header_id  -- pi_du_tu_type_id
                                         ,l_du_fiscal_year     -- pi_fiscal_year
                                         ,l_du_legal_number    -- po_du_tu_number
                                         ,l_error_message);    -- po_error_message

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Apply_du_legal_num.Msg6',
                                 ' l_du_legal_number --> ' || l_du_legal_number);
            -- =============== END DEBUG LOG ==================

            IF (l_du_legal_number is null) THEN
               -- An error occurred generating the DU legal number
               -- Set the error message attribute to be used in the
               -- notification sent to the system administrator

               -- Set the error_message attribute
               wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'ERROR_MESSAGE',
                                            avalue   => l_error_message);

               -- =============== START DEBUG LOG ================
                  DEBUG_LOG_STRING (l_proc_level, 'Apply_du_legal_num.Msg7',
                                    ' SetItemAttrText ERROR_MESSAGE --> ' || l_error_message);
               -- =============== END DEBUG LOG ==================

               -- Set the legal_num_failed_du attribute
               wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'LEGAL_NUM_FAILED_DU',
                                            avalue   => l_du_order_number);

               -- =============== START DEBUG LOG ================
                  DEBUG_LOG_STRING (l_proc_level, 'Apply_du_legal_num.Msg8',
                                    ' SetItemAttrText LEGAL_NUM_FAILED_DU --> ' || l_du_order_number);
               -- =============== END DEBUG LOG ==================

               -- rollback any legal numbering which did work
               rollback to legal_num_save;

               -- =============== START DEBUG LOG ================
                  DEBUG_LOG_STRING (l_proc_level, 'Apply_du_legal_num.Msg9',
                                    ' rollback to legal_num_save ');
               -- =============== END DEBUG LOG ==================

               -- set result to 'Failure'
               result := 'COMPLETE:FAILURE';

               -- =============== START DEBUG LOG ================
                  DEBUG_LOG_STRING (l_proc_level, 'Apply_du_legal_num.Msg10',
                                    ' result --> ' || result );
               -- =============== END DEBUG LOG ==================

               -- set l_du_failed to 'Y'
               l_du_failed := 'Y';

               -- =============== START DEBUG LOG ================
                  DEBUG_LOG_STRING (l_proc_level, 'Apply_du_legal_num.Msg11',
                                    ' l_du_failed --> ' || l_du_failed);
               -- =============== END DEBUG LOG ==================

               -- exit loop
               EXIT;

            ELSE

               -- DU Legal number was generated successfully
               -- Apply the legal number to the DU
               UPDATE igi_exp_dus
               SET    du_legal_number = l_du_legal_number
               WHERE  du_id = l_du_id;

               -- =============== START DEBUG LOG ================
                  DEBUG_LOG_STRING (l_proc_level, 'Apply_du_legal_num.Msg12',
                                    ' UPDATE igi_exp_dus --> ' || SQL%ROWCOUNT);
               -- =============== END DEBUG LOG ==================

            END IF;
         END LOOP;

         IF (c_get_du%ISOPEN) THEN
            CLOSE c_get_du;
         END IF;

         IF (l_du_failed = 'Y') THEN
            -- set result to 'Failure'
            result := 'COMPLETE:FAILURE';
         ELSE
            -- set result to 'Success'
            result := 'COMPLETE:SUCCESS';
         END IF;

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Apply_du_legal_num.Msg13',
                              ' result --> ' || result);
         -- =============== END DEBUG LOG ==================

      END IF;

      IF (funcmode <> 'RUN') THEN
         result := 'COMPLETE';
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Apply_du_legal_num.Msg14',
                              ' ** START APPLY_DU_LEGAL_NUM ** ');
         -- =============== END DEBUG LOG ==================
         return;
      END IF;

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Apply_du_legal_num.Msg15',
                           ' ** END APPLY_DU_LEGAL_NUM ** ');
      -- =============== END DEBUG LOG ==================

   EXCEPTION
      WHEN OTHERS THEN
         wf_core.context('IGI_EXP_APPROVAL_PKG','apply_du_legal_num',itemtype,itemkey,
                         to_char(actid),funcmode);
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_UNEXP_ERROR ('Apply_du_legal_num.Unexp1','DEFAULT');
         -- =============== END DEBUG LOG ==================
         raise;

   END apply_du_legal_num;



   -- *************************************************************************
   --    SET_TU_STATUS
   -- *************************************************************************

   PROCEDURE set_tu_status        ( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2) IS

      l_tu_id        igi_exp_dus.tu_id%TYPE;
      l_tu_status    igi_exp_tus.tu_status%TYPE;
      l_atr_du_count NUMBER;

      -- Bug 4051910
      -- Check if the TU has a status
      CURSOR C_stat(p_tu_id number)
      IS
         SELECT tu_status
         FROM   igi_exp_tus
         WHERE  tu_id = p_tu_id;



   BEGIN

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Set_tu_status.Msg1',
                           ' ** START SET_TU_STATUS ** ');
      -- =============== END DEBUG LOG ==================

      IF (funcmode = 'RUN') THEN

         -- Get the TU id
         l_tu_id
            := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'TU_ID');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Set_tu_status.Msg2',
                              ' GetItemAttrNumber TU_ID --> ' || l_tu_id);
         -- =============== END DEBUG LOG ==================

         -- Bug 4051910
         OPEN  c_stat(l_tu_id);
         FETCH c_stat INTO l_tu_status;
         CLOSE c_stat;

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Set_tu_status.Msg3',
                              ' l_tu_status --> ' || l_tu_status);
         -- =============== END DEBUG LOG ==================

         IF (l_tu_status = 'TRA') THEN

            UPDATE igi_exp_tus
            SET    tu_status = 'ATR'
            WHERE  tu_id = l_tu_id;
            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Set_tu_status.Msg4',
                                 ' UPDATE igi_exp_tus --> ' || SQL%ROWCOUNT);
            -- =============== END DEBUG LOG ==================

         END IF;

         -- Find how many DUs in the TU are approved
         SELECT count(*)
         INTO   l_atr_du_count
         FROM   igi_exp_dus
         WHERE  tu_id = l_tu_id
         AND    du_status = 'ATR';

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Set_tu_status.Msg5',
                              ' l_atr_du_count --> ' || l_atr_du_count);
         -- =============== END DEBUG LOG ==================

         IF (l_atr_du_count = 0) THEN
            -- This TU contains no approved DUs
            -- Set the result to 'TU Empty'
            result := 'COMPLETE:TU_EMPTY';
            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Set_tu_status.Msg6',
                                 ' l_atr_du_count = 0 -- result --> ' || result);
            -- =============== END DEBUG LOG ==================
         ELSE
            -- This TU contains at least one approved DU
            -- Set the result to 'TU Not Empty'
            result := 'COMPLETE:TU_NOT_EMPTY';
            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Set_tu_status.Msg7',
                                 ' result --> ' || result);
            -- =============== END DEBUG LOG ==================
         END IF;
      END IF;

      IF (funcmode <> 'RUN') THEN
         result := 'COMPLETE';
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Set_tu_status.Msg8',
                              ' funcmode <> RUN -- result --> ' || result);
         -- =============== END DEBUG LOG ==================
         return;
      END IF;

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Set_tu_status.Msg9',
                           ' ** END SET_TU_STATUS ** ');
      -- =============== END DEBUG LOG ==================

   EXCEPTION
      WHEN OTHERS THEN
         wf_core.context('IGI_EXP_APPROVAL_PKG','set_tu_status',itemtype,itemkey,
                         to_char(actid),funcmode);
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_UNEXP_ERROR ('Set_tu_status.Unexp1','DEFAULT');
         -- =============== END DEBUG LOG ==================
         raise;

   END set_tu_status;


   -- *************************************************************************
   --    GET_PARENT_POSITION
   -- *************************************************************************

   PROCEDURE get_parent_position  ( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2) IS

     CURSOR c_get_parent_position(p_position_id per_all_positions.position_id%TYPE
                                 ,p_pos_structure_version_id per_pos_structure_versions.pos_structure_version_id%TYPE
                                 ,p_business_group_id hr_all_positions_f.business_group_id%TYPE)
     IS
        SELECT parent_position_id
        FROM   per_pos_structure_elements
        WHERE  pos_structure_version_id = p_pos_structure_version_id
        AND    business_group_id = p_business_group_id
        AND    subordinate_position_id = p_position_id;

      l_position_id              per_all_positions.position_id%TYPE;
      l_parent_pos_id            per_all_positions.position_id%TYPE;
      l_parent_pos_name          per_all_positions.name%TYPE;
      l_final_apprv_pos_id       igi_exp_apprv_profiles.final_apprv_pos_id%TYPE;
      l_business_group_id        hr_all_positions_f.business_group_id%TYPE;
      l_pos_structure_version_id per_pos_structure_versions.pos_structure_version_id%TYPE;

   BEGIN

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Get_parent_position.Msg1',
                           ' ** START GET_PARENT_POSITION ** ');
      -- =============== END DEBUG LOG ==================

      IF (funcmode = 'RUN') THEN

         -- Get the current position id
         l_position_id
            := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'CURRENT_POSITION_ID');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Get_parent_position.Msg2',
                              ' GetItemAttrNumber CURRENT_POSITION_ID --> ' || l_position_id);
         -- =============== END DEBUG LOG ==================

         -- Get the final approver position id
         l_final_apprv_pos_id
            := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'FINAL_APPRV_POS_ID');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Get_parent_position.Msg3',
                              ' GetItemAttrNumber FINAL_APPRV_POS_ID --> ' || l_final_apprv_pos_id);
         -- =============== END DEBUG LOG ==================

         -- If the current position is the final approver position then
         -- this position has no parent position
         IF (l_position_id = l_final_apprv_pos_id) THEN
            -- set the result to 'No Parent' and exit
            result := 'COMPLETE:NO_PARENT';
            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Get_parent_position.Msg4',
                                 ' l_position_id = l_final_apprv_pos_id -- result --> ' || result);
            -- =============== END DEBUG LOG ==================
            return;
         END IF;

         -- Now need to check if there is a parent position in the HR hierarchy
         -- Get the position structure version id
         l_pos_structure_version_id
            := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'POS_STRUCTURE_VERSION_ID');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Get_parent_position.Msg5',
                              ' GetItemAttrNumber POS_STRUCTURE_VERSION_ID --> ' ||l_pos_structure_version_id);
         -- =============== END DEBUG LOG ==================

         -- Get the business group id
         l_business_group_id
            := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'BUSINESS_GROUP_ID');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Get_parent_position.Msg6',
                              ' GetItemAttrNumber BUSINESS_GROUP_ID --> ' || l_business_group_id);
         -- =============== END DEBUG LOG ==================

         OPEN c_get_parent_position(l_position_id
                                   ,l_pos_structure_version_id
                                   ,l_business_group_id);
         FETCH c_get_parent_position INTO l_parent_pos_id;

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Get_parent_position.Msg7',
                              ' l_position_id --> ' || l_position_id ||
                              ' l_pos_structure_version_id --> ' || l_pos_structure_version_id ||
                              ' l_business_group_id --> ' || l_business_group_id);
         -- =============== END DEBUG LOG ==================

         IF c_get_parent_position%NOTFOUND THEN
            -- The current position does not have a parent in the HR hierarchy
            -- Set result to No Parent and exit
            result := 'COMPLETE:NO_PARENT';
            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Get_parent_position.Msg8',
                                 ' c_get_parent_position%NOTFOUND --> TRUE -- result --> ' || result);
            -- =============== END DEBUG LOG ==================
            return;
         ELSE
            -- The current position has a parent
            -- Set the workflow attribute current_position_id to the parent position
            wf_engine.SetItemAttrNumber( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'CURRENT_POSITION_ID',
                                         avalue   => l_parent_pos_id);

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Get_parent_position.Msg9',
                                 ' SetItemAttrNumber CURRENT_POSITION_ID --> ' || l_parent_pos_id);
            -- =============== END DEBUG LOG ==================

            -- Get the position name
            SELECT name
            INTO   l_parent_pos_name
            FROM   hr_all_positions_f
            WHERE  position_id = l_parent_pos_id;

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Get_parent_position.Msg10',
                                 ' l_parent_pos_name --> ' || l_parent_pos_name);
            -- =============== END DEBUG LOG ==================

            -- Set the workflow attribute current_position_name to the parent position
            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'CURRENT_POSITION_NAME',
                                         avalue   => l_parent_pos_name);

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Get_parent_position.Msg11',
                                 ' SetItemAttrText CURRENT_POSITION_NAME --> ' || l_parent_pos_name);
            -- =============== END DEBUG LOG ==================

            -- Set the result to Has a parent
            result := 'COMPLETE:HAS_PARENT';

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Get_parent_position.Msg12',
                                 ' result --> ' || result);
            -- =============== END DEBUG LOG ==================

            return;

         END IF;

      END IF;

      IF (funcmode <> 'RUN') THEN
         result := 'COMPLETE';
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Get_parent_position.Msg13',
                              ' funcmode <> RUN -- result --> ' || result);
         -- =============== END DEBUG LOG ==================
         return;
      END IF;

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Get_parent_position.Msg14',
                           ' ** END GET_PARENT_POSITION ** ');
      -- =============== END DEBUG LOG ==================

   EXCEPTION
      WHEN OTHERS THEN
         wf_core.context('IGI_EXP_APPROVAL_PKG','get_parent_position',itemtype,itemkey,
                         to_char(actid),funcmode);
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_UNEXP_ERROR ('Get_parent_position.Unexp1','DEFAULT');
         -- =============== END DEBUG LOG ==================
         raise;

   END get_parent_position;



   -- *************************************************************************
   --    GET_NEXT_INCOMPLETE_DU
   -- *************************************************************************

   PROCEDURE get_next_incomplete_du( itemtype IN  VARCHAR2,
                                     itemkey  IN  VARCHAR2,
                                     actid    IN  NUMBER,
                                     funcmode IN  VARCHAR2,
                                     result   OUT NOCOPY VARCHAR2) IS

      l_tu_id        igi_exp_dus.tu_id%TYPE;
      l_du_prep_name fnd_user.user_name%TYPE;
      l_du_id        igi_exp_dus.du_id%TYPE;

   BEGIN

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Get_next_incomplete_du.Msg1',
                           ' ** START GET_NEXT_INCOMPLETE_DU ** ');
      -- =============== END DEBUG LOG ==================

      IF (funcmode = 'RUN') THEN

         -- Get the TU id
         l_tu_id
            := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'TU_ID');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Get_next_incomplete_du.Msg1',
                              ' ** START GET_NEXT_INCOMPLETE_DU ** ');
         -- =============== END DEBUG LOG ==================

         -- Get the next DU which has been approved and needs completing
         SELECT du.du_id
               ,fnd.user_name
         INTO   l_du_id
               ,l_du_prep_name
         FROM   igi_exp_dus du
               ,fnd_user fnd
         WHERE  du.tu_id = l_tu_id
         AND    du.du_status = 'ATR'
         AND    du.du_by_user_id = fnd.user_id
         AND    rownum = 1;

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Get_next_incomplete_du.Msg1',
                              ' ** START GET_NEXT_INCOMPLETE_DU ** ');
         -- =============== END DEBUG LOG ==================

         -- Set the du_id_for_completion attribute
         wf_engine.SetItemAttrNumber( itemtype => itemtype,
                                      itemkey  => itemkey,
                                      aname    => 'DU_ID_FOR_COMPLETION',
                                      avalue   => l_du_id);

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Get_next_incomplete_du.Msg1',
                              ' ** START GET_NEXT_INCOMPLETE_DU ** ');
         -- =============== END DEBUG LOG ==================

         -- Set the du_prep_name_for_com attribute
         wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                      itemkey  => itemkey,
                                      aname    => 'DU_PREP_NAME_FOR_COM',
                                      avalue   => l_du_prep_name);

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Get_next_incomplete_du.Msg1',
                              ' ** START GET_NEXT_INCOMPLETE_DU ** ');
         -- =============== END DEBUG LOG ==================

      END IF;

      IF (funcmode <> 'RUN') THEN
         result := 'COMPLETE';
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Get_next_incomplete_du.Msg1',
                              ' ** START GET_NEXT_INCOMPLETE_DU ** ');
         -- =============== END DEBUG LOG ==================
         return;
      END IF;

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Get_next_incomplete_du.Msg1',
                           ' ** START GET_NEXT_INCOMPLETE_DU ** ');
      -- =============== END DEBUG LOG ==================

   EXCEPTION
      WHEN OTHERS THEN
         wf_core.context('IGI_EXP_APPROVAL_PKG','get_next_incomplete_du',itemtype,itemkey,
                         to_char(actid),funcmode);
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_UNEXP_ERROR ('Get_next_incomplete_du.Unexp1','DEFAULT');
         -- =============== END DEBUG LOG ==================
         raise;
   END get_next_incomplete_du;

   -- *************************************************************************
   --    PROCESS_TRANSACTIONS
   -- *************************************************************************

   PROCEDURE process_transactions ( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2) IS

      l_du_id                igi_exp_dus.du_id%TYPE;
      l_app_id               igi_exp_du_type_headers.application_id%TYPE;
      l_order_number         igi_exp_dus.du_order_number%TYPE;
      l_legal_number         igi_exp_dus.du_legal_number%TYPE;
      l_failed_du            VARCHAR2(510);
      l_failed_trx           VARCHAR2(50);
      l_gl_date              DATE := sysdate;
      l_error_message        VARCHAR2(4000);
      l_trx_failed_err_mess  VARCHAR2(4000);
      l_trx_id               NUMBER;

   BEGIN

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Process_transactions.Msg1',
                           ' ** START PROCESS_TRANSACTIONS ** ');
      -- =============== END DEBUG LOG ==================

      IF (funcmode = 'RUN') THEN

         -- Get the DU id
         l_du_id
            := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'DU_ID_FOR_COMPLETION');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Process_transactions.Msg2',
                              ' GetItemAttrNumber DU_ID_FOR_COMPLETION --> ' || l_du_id);
         -- =============== END DEBUG LOG ==================

         -- Get the application id for the du
         SELECT du_type.application_id
         INTO   l_app_id
         FROM   igi_exp_du_type_headers_all du_type
               ,igi_exp_dus du
         WHERE  du.du_id = l_du_id
         AND    du.du_type_header_id = du_type.du_type_header_id;

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Process_transactions.Msg3',
                              ' l_app_id --> ' || l_app_id);
            DEBUG_LOG_STRING (l_proc_level, 'Process_transactions.Msg4',
                              ' Calling igi_exp_utils.complete_du ');
         -- =============== END DEBUG LOG ==================

         -- Call the utility to complete (or approve) transactions
         igi_exp_utils.complete_du(l_du_id          -- p_du_id
                                  ,l_app_id         -- p_app_id
                                  ,l_gl_date        -- p_gl_date
                                  ,l_error_message  -- p_error_message
                                  ,l_trx_id);       -- p_trx_id

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Process_transactions.Msg5',
                              ' l_error_message --> ' || l_error_message);
         -- =============== END DEBUG LOG ==================

         IF (l_error_message <> 'Success') THEN

            SELECT du_order_number, du_legal_number
            INTO   l_order_number, l_legal_number
            FROM   igi_exp_dus
            WHERE  du_id = l_du_id;

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Process_transactions.Msg6',
                                 ' l_order_number --> ' || l_order_number ||
                                 ' l_legal_number --> ' || l_legal_number);
            -- =============== END DEBUG LOG ==================

            l_failed_du := l_order_number;

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Process_transactions.Msg7',
                                 ' l_failed_du --> ' || l_failed_du);
            -- =============== END DEBUG LOG ==================

            IF (l_legal_number is not null) THEN
               l_failed_du := l_failed_du||' ('||l_legal_number||')';
            END IF;

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Process_transactions.Msg8',
                                 ' After if -- l_failed_du --> ' || l_failed_du);
            -- =============== END DEBUG LOG ==================

            IF (l_trx_id is not null) THEN
               -- If the process failed for a particular transaction then
               -- Find the transaction name of the failed transaction
               IF (l_app_id = 200) THEN

                  -- =============== START DEBUG LOG ================
                     DEBUG_LOG_STRING (l_proc_level, 'Process_transactions.Msg9',
                                       ' l_trx_id is not null AND l_app_id = 200 ');
                  -- =============== END DEBUG LOG ==================

                  SELECT invoice_num
                  INTO   l_failed_trx
                  FROM   ap_invoices
                  WHERE  invoice_id = l_trx_id;

                  -- =============== START DEBUG LOG ================
                     DEBUG_LOG_STRING (l_proc_level, 'Process_transactions.Msg10',
                                       ' l_failed_trx --> ' || l_failed_trx);
                  -- =============== END DEBUG LOG ==================

               ELSIF (l_app_id = 222) THEN

                  -- =============== START DEBUG LOG ================
                     DEBUG_LOG_STRING (l_proc_level, 'Process_transactions.Msg11',
                                       ' l_trx_id is not null AND l_app_id = 222 ');
                  -- =============== END DEBUG LOG ==================

                  SELECT trx_number
                  INTO   l_failed_trx
                  FROM   ra_customer_trx
                  WHERE  customer_trx_id = l_trx_id;

                  -- =============== START DEBUG LOG ================
                     DEBUG_LOG_STRING (l_proc_level, 'Process_transactions.Msg12',
                                       ' l_failed_trx --> ' || l_failed_trx);
                  -- =============== END DEBUG LOG ==================

               END IF;
            END IF;


            -- Set the failed_du attribute
            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'FAILED_DU',
                                         avalue   => l_failed_du);

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Process_transactions.Msg13',
                                 ' SetItemAttrText FAILED_DU --> ' || l_failed_du);
            -- =============== END DEBUG LOG ==================

            -- Set the failed_trx attribute
            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'FAILED_TRX',
                                         avalue   => l_failed_trx);

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Process_transactions.Msg14',
                                 ' SetItemAttrText FAILED_TRX --> ' || l_failed_trx);
            -- =============== END DEBUG LOG ==================

            -- Want the trx_failed_error_message to be a list of du_ids which
            -- failed along with the error message for each du
            -- Therefore, get the current item attribute trx_failed_error_message
            -- and append this DU_ID and error message to it.

            -- Get the current error message
            l_trx_failed_err_mess
               := wf_engine.GetItemAttrText  ( itemtype => itemtype,
                                               itemkey  => itemkey,
                                               aname    => 'TRX_FAILED_ERROR_MESSAGE');

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Process_transactions.Msg15',
                                 ' GetItemAttrText TRX_FAILED_ERROR_MESSAGE --> ' || l_trx_failed_err_mess);
            -- =============== END DEBUG LOG ==================


            -- Append this DU and error message to it
            l_trx_failed_err_mess := l_trx_failed_err_mess||', '||to_char(l_du_id)||l_error_message;

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Process_transactions.Msg16',
                                 ' l_trx_failed_err_mess --> ' || l_trx_failed_err_mess);
            -- =============== END DEBUG LOG ==================

            -- Set the trx_failed_error_message attribute
            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'TRX_FAILED_ERROR_MESSAGE',
                                         avalue   => l_trx_failed_err_mess);

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Process_transactions.Msg17',
                                 ' SetItemAttrText TRX_FAILED_ERROR_MESSAGE --> ' || l_trx_failed_err_mess);
            -- =============== END DEBUG LOG ==================

            -- Set the result to 'Failure'
            result := 'COMPLETE:FAILURE';

         ELSE
            result := 'COMPLETE:SUCCESS';

         END IF;

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Process_transactions.Msg18',
                              ' result --> ' || result);
         -- =============== END DEBUG LOG ==================

      END IF;

      IF (funcmode <> 'RUN') THEN
         result := 'COMPLETE';
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Process_transactions.Msg19',
                              ' funcmode <> RUN -- result --> ' || result);
         -- =============== END DEBUG LOG ==================
         return;
      END IF;

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Process_transactions.Msg20',
                           ' ** END PROCESS_TRANSACTIONS ** ');
      -- =============== END DEBUG LOG ==================

   EXCEPTION
      WHEN OTHERS THEN
         wf_core.context('IGI_EXP_APPROVAL_PKG','process_transactions',itemtype,itemkey,
                         to_char(actid),funcmode);
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_UNEXP_ERROR ('Process_transactions.Unexp1','DEFAULT');
         -- =============== END DEBUG LOG ==================
         raise;

   END process_transactions;


   -- *************************************************************************
   --    SET_DU_TO_COMPLETE
   -- *************************************************************************

   PROCEDURE set_du_to_complete   ( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2) IS

      l_du_id    igi_exp_dus.du_id%TYPE;

   BEGIN

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Set_du_to_complete.Msg1',
                           ' ** START SET_DU_TO_COMPLETE ** ');
      -- =============== END DEBUG LOG ==================

      IF (funcmode = 'RUN') THEN

         -- Get the DU id
         l_du_id
            := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'DU_ID_FOR_COMPLETION');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Set_du_to_complete.Msg1',
                              ' GetItemAttrNumber DU_ID_FOR_COMPLETION --> '|| l_du_id);
         -- =============== END DEBUG LOG ==================

         UPDATE igi_exp_dus
         SET    du_status = 'COM'
         WHERE  du_id = l_du_id;

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Set_du_to_complete.Msg1',
                              ' UPDATE igi_exp_dus status - COM --> ' || SQL%ROWCOUNT);
         -- =============== END DEBUG LOG ==================

      END IF;

      IF (funcmode <> 'RUN') THEN
         result := 'COMPLETE';
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Set_du_to_complete.Msg1',
                              ' funcmode <> RUN -- result --> ' || result);
         -- =============== END DEBUG LOG ==================
         return;
      END IF;

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Set_du_to_complete.Msg1',
                           ' ** END SET_DU_TO_COMPLETE ** ');
      -- =============== END DEBUG LOG ==================

   EXCEPTION
      WHEN OTHERS THEN
         wf_core.context('IGI_EXP_APPROVAL_PKG','set_du_to_complete',itemtype,itemkey,
                         to_char(actid),funcmode);
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_UNEXP_ERROR ('Set_du_to_complete.Unexp1','DEFAULT');
         -- =============== END DEBUG LOG ==================
         raise;

   END set_du_to_complete;



   -- *************************************************************************
   --    PUT_FAILED_DU_ON_HOLD
   -- *************************************************************************

   PROCEDURE put_failed_du_on_hold( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2) IS

      l_du_id    igi_exp_dus.du_id%TYPE;

   BEGIN

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Put_failed_du_on_hold.Msg1',
                           ' ** START PUT_FAILED_DU_ON_HOLD ** ');
      -- =============== END DEBUG LOG ==================

      IF (funcmode = 'RUN') THEN

         -- Get the DU id
         l_du_id
            := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'DU_ID_FOR_COMPLETION');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Put_failed_du_on_hold.Msg2',
                              ' GetItemAttrNumber DU_ID_FOR_COMPLETION --> ' || l_du_id);
         -- =============== END DEBUG LOG ==================

         UPDATE igi_exp_dus
         SET    du_status = 'HLD'
         WHERE  du_id = l_du_id;

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Put_failed_du_on_hold.Msg3',
                              ' UPDATE igi_exp_dus du_status = HLD --> ' || SQL%ROWCOUNT);
         -- =============== END DEBUG LOG ==================

      END IF;

      IF (funcmode <> 'RUN') THEN
         result := 'COMPLETE';
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Put_failed_du_on_hold.Msg4',
                              ' funcmode <> RUN -- result --> ' || result);
         -- =============== END DEBUG LOG ==================
         return;
      END IF;

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Put_failed_du_on_hold.Msg5',
                           ' ** END PUT_FAILED_DU_ON_HOLD ** ');
      -- =============== END DEBUG LOG ==================

   EXCEPTION
      WHEN OTHERS THEN
         wf_core.context('IGI_EXP_APPROVAL_PKG','put_failed_du_on_hold',itemtype,itemkey,
                         to_char(actid),funcmode);
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_UNEXP_ERROR ('Put_failed_du_on_hold.Unexp1','DEFAULT');
         -- =============== END DEBUG LOG ==================
         raise;

   END put_failed_du_on_hold;


   -- *************************************************************************
   --    CHECK_DUS_COMPLETED
   -- *************************************************************************

   PROCEDURE check_dus_completed  ( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2) IS

      l_tu_id        igi_exp_dus.tu_id%TYPE;
      l_incom_count  NUMBER;

   BEGIN

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Check_dus_completed.Msg1',
                           ' ** START CHECK_DUS_COMPLETED ** ');
      -- =============== END DEBUG LOG ==================

      IF (funcmode = 'RUN') THEN

         -- Get the TU id
         l_tu_id
            := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'TU_ID');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Check_dus_completed.Msg2',
                              ' GetItemAttrNumber TU_ID --> ' || l_tu_id);
         -- =============== END DEBUG LOG ==================

         SELECT count(*)
         INTO   l_incom_count
         FROM   igi_exp_dus
         WHERE  tu_id = l_tu_id
         AND    du_status = 'ATR';

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Check_dus_completed.Msg3',
                              ' l_incom_count --> ' || l_incom_count);
         -- =============== END DEBUG LOG ==================


         IF (l_incom_count = 0) THEN
            -- There are no more DUs left waiting completion
            -- Set the result to 'No'
            result := 'COMPLETE:N';
         ELSE
            -- There is at least one DU waiting completion
            -- Set the result to 'Yes'
            result := 'COMPLETE:Y';
         END IF;

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Check_dus_completed.Msg4',
                              ' result --> ' || result);
         -- =============== END DEBUG LOG ==================

      END IF;

      IF (funcmode <> 'RUN') THEN
         result := 'COMPLETE';
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Check_dus_completed.Msg5',
                              ' funcmode <> RUN -- result --> ' || result);
         -- =============== END DEBUG LOG ==================
         return;
      END IF;

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Check_dus_completed.Msg6',
                           ' ** END CHECK_DUS_COMPLETED ** ');
      -- =============== END DEBUG LOG ==================

   EXCEPTION
      WHEN OTHERS THEN
         wf_core.context('IGI_EXP_APPROVAL_PKG','check_dus_completed',itemtype,itemkey,
                         to_char(actid),funcmode);
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_UNEXP_ERROR ('Check_dus_completed.Unexp1','DEFAULT');
         -- =============== END DEBUG LOG ==================
         raise;
   END check_dus_completed;



   -- *************************************************************************
   --    ANY_DUS_WITH_TRX_FAIL
   -- *************************************************************************

   PROCEDURE any_dus_with_trx_fail( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2) IS


      l_tu_id           igi_exp_dus.tu_id%TYPE;
      l_failed_du_count NUMBER;
      l_du_hold_list    VARCHAR2(28000);

      CURSOR c_du_hold_info(p_tu_id igi_exp_dus.tu_id%TYPE)
      IS
         SELECT du_order_number
               ,du_legal_number
         FROM   igi_exp_dus
         WHERE  tu_id = p_tu_id
         AND    du_status = 'HLD';

   BEGIN

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Any_dus_with_trx_fail.Msg1',
                           ' ** START ANY_DUS_WITH_TRX_FAIL ** ');
      -- =============== END DEBUG LOG ==================

      IF (funcmode = 'RUN') THEN

         -- Get the TU id
         l_tu_id
            := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'TU_ID');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Any_dus_with_trx_fail.Msg2',
                              ' GetItemAttrNumber TU_ID --> ' || l_tu_id);
         -- =============== END DEBUG LOG ==================

         SELECT count(*)
         INTO   l_failed_du_count
         FROM   igi_exp_dus
         WHERE  tu_id = l_tu_id
         AND    du_status = 'HLD';

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Any_dus_with_trx_fail.Msg3',
                              ' l_failed_du_count --> ' || l_failed_du_count);
         -- =============== END DEBUG LOG ==================

         IF (l_failed_du_count = 0) THEN
            -- No DUs were put on hold due to transaction failure
            -- Set the result to 'No'
            result := 'COMPLETE:N';

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Any_dus_with_trx_fail.Msg4',
                                 ' result --> ' || result);
            -- =============== END DEBUG LOG ==================

         ELSE

            FOR I IN c_du_hold_info(l_tu_id)
            LOOP

               IF (l_du_hold_list is NULL) THEN
                  l_du_hold_list := I.du_order_number;
               ELSE
                  l_du_hold_list := l_du_hold_list ||I.du_order_number;
               END IF;

               -- =============== START DEBUG LOG ================
                  DEBUG_LOG_STRING (l_proc_level, 'Any_dus_with_trx_fail.Msg5',
                                    ' du_order_number --> ' || I.du_order_number);
               -- =============== END DEBUG LOG ==================

               IF (I.du_legal_number is not null) THEN
                  l_du_hold_list := l_du_hold_list||' ('||I.du_legal_number||')';
               END IF;

               -- =============== START DEBUG LOG ================
                  DEBUG_LOG_STRING (l_proc_level, 'Any_dus_with_trx_fail.Msg6',
                                    ' I.du_legal_number --> ' || I.du_legal_number);
               -- =============== END DEBUG LOG ==================

               l_du_hold_list := l_du_hold_list||fnd_global.local_chr(10);

               IF LENGTH(l_du_hold_list) > 28000 THEN
                  exit;
               END IF;

            END LOOP;

           -- Set the all_dus_list attribute
            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ADD_ATTR1',
                                         avalue   => substr(l_du_hold_list, 1, 4000));

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Any_dus_with_trx_fail.Msg7',
                                 ' SetItemAttrText ADD_ATTR1 --> ' || substr(l_du_hold_list, 1, 4000));
            -- =============== END DEBUG LOG ==================

            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ADD_ATTR2',
                                         avalue   => substr(l_du_hold_list, 4001, 4000));

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Any_dus_with_trx_fail.Msg8',
                                 ' SetItemAttrText ADD_ATTR2 --> ' || substr(l_du_hold_list, 4001, 4000));
            -- =============== END DEBUG LOG ==================

            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ADD_ATTR3',
                                         avalue   => substr(l_du_hold_list, 8001, 4000));

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Any_dus_with_trx_fail.Msg9',
                                 ' SetItemAttrText ADD_ATTR3 --> ' || substr(l_du_hold_list, 8001, 4000));
            -- =============== END DEBUG LOG ==================

            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ADD_ATTR4',
                                         avalue   => substr(l_du_hold_list, 12001, 4000));

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Any_dus_with_trx_fail.Msg10',
                                 ' SetItemAttrText ADD_ATTR4 --> ' || substr(l_du_hold_list, 12001, 4000));
            -- =============== END DEBUG LOG ==================

            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ADD_ATTR5',
                                         avalue   => substr(l_du_hold_list, 16001, 4000));

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Any_dus_with_trx_fail.Msg11',
                                 ' SetItemAttrText ADD_ATTR5 --> ' || substr(l_du_hold_list, 16001, 4000));
            -- =============== END DEBUG LOG ==================

            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ADD_ATTR6',
                                         avalue   => substr(l_du_hold_list, 20001, 4000));

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Any_dus_with_trx_fail.Msg12',
                                 ' SetItemAttrText ADD_ATTR6 --> ' || substr(l_du_hold_list, 20001, 4000));
            -- =============== END DEBUG LOG ==================

            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ADD_ATTR7',
                                         avalue   => substr(l_du_hold_list, 24001, 4000));

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Any_dus_with_trx_fail.Msg13',
                                 ' SetItemAttrText ADD_ATTR7 --> ' || substr(l_du_hold_list, 24001, 4000));
            -- =============== END DEBUG LOG ==================

            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ALL_DUS_LIST',
                                         avalue   => 'plsqlclob:igi_exp_approval_pkg.Create_du_list/'||itemtype||':'||itemkey);


            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Any_dus_with_trx_fail.Msg14',
                                 ' SetItemAttrText ALL_DUS_LIST --> ' ||
                                 ' plsqlclob:igi_exp_approval_pkg.Create_du_list/'||itemtype||':'||itemkey);
            -- =============== END DEBUG LOG ==================

            -- Set the result to 'Yes'
            result := 'COMPLETE:Y';

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Any_dus_with_trx_fail.Msg15',
                                 ' result --> ' || result);
            -- =============== END DEBUG LOG ==================

         END IF;

      END IF;

      IF (funcmode <> 'RUN') THEN
         result := 'COMPLETE';
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Any_dus_with_trx_fail.Msg16',
                              ' funcmode <> RUN -- result --> ' || result);
         -- =============== END DEBUG LOG ==================
         return;
      END IF;

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Any_dus_with_trx_fail.Msg17',
                           ' ** END ANY_DUS_WITH_TRX_FAIL ** ');
      -- =============== END DEBUG LOG ==================

   EXCEPTION
      WHEN OTHERS THEN
         wf_core.context('IGI_EXP_APPROVAL_PKG','any_dus_with_trx_fail',itemtype,itemkey,
                         to_char(actid),funcmode);
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_UNEXP_ERROR ('Any_dus_with_trx_fail.Unexp1','DEFAULT');
         -- =============== END DEBUG LOG ==================
         raise;

   END any_dus_with_trx_fail;



   -- *************************************************************************
   --    REMOVE_ALL_ON_HOLD_DUS
   -- *************************************************************************

   PROCEDURE remove_all_on_hold_dus( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2) IS

      l_tu_id      igi_exp_dus.tu_id%TYPE;
      l_du_amount  igi_exp_dus.du_amount%TYPE;

   BEGIN

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Remove_all_on_hold_dus.Msg1',
                           ' ** START REMOVE_ALL_ON_HOLD_DUS ** ');
      -- =============== END DEBUG LOG ==================

      IF (funcmode = 'RUN') THEN

         -- Get the TU id
         l_tu_id
            := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'TU_ID');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Remove_all_on_hold_dus.Msg2',
                              ' GetItemAttrNumber TU_ID --> ' || l_tu_id);
         -- =============== END DEBUG LOG ==================

         -- OPSF(I) EXP Bug 2415293  S Brewer 18-JUL-2002 Start(3)
         -- Before removing the DUs which were put on hold, we need
         -- to update the TU amount to reflect the DUs were removed
         -- So, find the total DU amount for the DUs to be removed
         -- and update the TU amount
         -- i.e. New TU amount = TU amount - DU amount

         -- Find the total DU amount
         SELECT sum(du_amount)
         INTO   l_du_amount
         FROM   igi_exp_dus
         WHERE  tu_id = l_tu_id
         AND    du_status = 'HLD';

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Remove_all_on_hold_dus.Msg3',
                              ' l_du_amount --> ' || l_du_amount);
         -- =============== END DEBUG LOG ==================

         -- Now update the TU amount
         UPDATE igi_exp_tus
         SET    tu_amount = tu_amount - l_du_amount
         WHERE  tu_id = l_tu_id;

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Remove_all_on_hold_dus.Msg4',
                              ' UPDATE igi_exp_tus -> ' || SQL%ROWCOUNT);
         -- =============== END DEBUG LOG ==================


         -- OPSF(I) EXP Bug 2415293  S Brewer 18-JUL-2002 End(3)

         -- Remove the DUs which were put on hold (due to transaction
         -- completion failure)  from the TU
         UPDATE igi_exp_dus
         SET    tu_id = null
         WHERE  tu_id = l_tu_id
         AND    du_status = 'HLD';

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Remove_all_on_hold_dus.Msg5',
                              ' UPDATE igi_exp_dus status = HLD --> ' || SQL%ROWCOUNT);
         -- =============== END DEBUG LOG ==================

      END IF;

      IF (funcmode <> 'RUN') THEN
         result := 'COMPLETE';
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Remove_all_on_hold_dus.Msg6',
                              ' funcmode <> RUN -- result --> ' || result);
         -- =============== END DEBUG LOG ==================
         return;
      END IF;

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Remove_all_on_hold_dus.Msg7',
                           ' ** END REMOVE_ALL_ON_HOLD_DUS ** ');
      -- =============== END DEBUG LOG ==================

   EXCEPTION
      WHEN OTHERS THEN
         wf_core.context('IGI_EXP_APPROVAL_PKG','remove_all_on_hold_dus',itemtype,itemkey,
                         to_char(actid),funcmode);
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_UNEXP_ERROR ('Remove_all_on_hold_dus.Unexp1','DEFAULT');
         -- =============== END DEBUG LOG ==================
         raise;

   END remove_all_on_hold_dus;



   -- *************************************************************************
   --    CHECK_FOR_COMPLETE_DUS
   -- *************************************************************************

   PROCEDURE check_for_complete_dus( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2) IS

      l_tu_id          igi_exp_dus.tu_id%TYPE;
      l_com_du_count   NUMBER;

   BEGIN

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Check_for_complete_dus.Msg1',
                           ' ** START CHECK_FOR_COMPLETE_DUS ** ');
      -- =============== END DEBUG LOG ==================

      IF (funcmode = 'RUN') THEN

         -- Get the TU id
         l_tu_id
            := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'TU_ID');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Check_for_complete_dus.Msg2',
                              ' GetItemAttrNumber TU_ID --> ' || l_tu_id);
         -- =============== END DEBUG LOG ==================

         SELECT count(*)
         INTO   l_com_du_count
         FROM   igi_exp_dus
         WHERE  tu_id = l_tu_id
         AND    du_status = 'COM';

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Check_for_complete_dus.Msg3',
                              ' l_com_du_count --> ' || l_com_du_count);
         -- =============== END DEBUG LOG ==================

         IF (l_com_du_count = 0) THEN
            -- There are no completed DUs in this TU
            -- Set result to 'No'
            result := 'COMPLETE:N';
         ELSE
            -- There is at least one completed DU in this TU
            -- Set result to 'Yes'
            result := 'COMPLETE:Y';
         END IF;

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Check_for_complete_dus.Msg4',
                              ' result --> ' || result);
         -- =============== END DEBUG LOG ==================
      END IF;

      IF (funcmode <> 'RUN') THEN
         result := 'COMPLETE';
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Check_for_complete_dus.Msg5',
                              'funcmode <> RUN -- result --> ' || result);
         -- =============== END DEBUG LOG ==================
         return;
      END IF;

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Check_for_complete_dus.Msg6',
                           ' ** END CHECK_FOR_COMPLETE_DUS ** ');
      -- =============== END DEBUG LOG ==================

   EXCEPTION
      WHEN OTHERS THEN
         wf_core.context('IGI_EXP_APPROVAL_PKG','check_for_complete_dus',itemtype,itemkey,
                         to_char(actid),funcmode);
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_UNEXP_ERROR ('Check_for_complete_dus.Unexp1','DEFAULT');
         -- =============== END DEBUG LOG ==================
         raise;
   END check_for_complete_dus;



   -- *************************************************************************
   --    BUILD_PREP_LIST_OF_COM_DUS
   -- *************************************************************************

   PROCEDURE build_prep_list_of_com_dus( itemtype IN  VARCHAR2,
                                         itemkey  IN  VARCHAR2,
                                         actid    IN  NUMBER,
                                         funcmode IN  VARCHAR2,
                                         result   OUT NOCOPY VARCHAR2) IS

      CURSOR c_prep_list(p_tu_id igi_exp_dus.tu_id%TYPE)
      IS
         SELECT distinct du_by_user_id
         FROM   igi_exp_dus
         WHERE  tu_id = p_tu_id
         AND    du_status = 'COM';

      l_tu_id     igi_exp_dus.tu_id%TYPE;
      l_user_id   igi_exp_dus.du_by_user_id%TYPE;
      l_user_list VARCHAR2(1000);


   BEGIN

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Build_prep_list_of_com_dus.Msg1',
                           ' ** START BUILD_PREP_LIST_OF_COM_DUS ** ');
      -- =============== END DEBUG LOG ==================

      IF (funcmode = 'RUN') THEN

         -- Get the TU id
         l_tu_id
            := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'TU_ID');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Build_prep_list_of_com_dus.Msg2',
                              ' GetItemAttrNumber TU_ID --> ' || l_tu_id);
         -- =============== END DEBUG LOG ==================

         OPEN c_prep_list(l_tu_id);
         LOOP
            FETCH c_prep_list INTO l_user_id;
            EXIT WHEN c_prep_list%NOTFOUND;
            l_user_list := l_user_list||','||l_user_id;
            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Build_prep_list_of_com_dus.Msg3',
                                 ' l_user_list --> ' || l_user_list);
            -- =============== END DEBUG LOG ==================
         END LOOP;
         CLOSE c_prep_list;

            -- Set the all_dus_list attribute
            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'COM_DU_PREP_LIST',
                                         avalue   => l_user_list);

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Build_prep_list_of_com_dus.Msg4',
                           ' SetItemAttrText COM_DU_PREP_LIST --> ' || l_user_list);
      -- =============== END DEBUG LOG ==================

      END IF;

      IF (funcmode <> 'RUN') THEN
         result := 'COMPLETE';
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Build_prep_list_of_com_dus.Msg5',
                              ' funcmode <> RUN -- result --> ' || result);
         -- =============== END DEBUG LOG ==================
         return;
      END IF;

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Build_prep_list_of_com_dus.Msg6',
                           ' ** END BUILD_PREP_LIST_OF_COM_DUS ** ');
      -- =============== END DEBUG LOG ==================

   EXCEPTION
      WHEN OTHERS THEN
         wf_core.context('IGI_EXP_APPROVAL_PKG','build_prep_list_of_com_dus',itemtype,itemkey,
                         to_char(actid),funcmode);
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_UNEXP_ERROR ('Build_prep_list_of_com_dus.Unexp1','DEFAULT');
         -- =============== END DEBUG LOG ==================
         raise;

   END build_prep_list_of_com_dus;

   -- *************************************************************************
   --    GET_NEXT_PREP
   -- *************************************************************************

   PROCEDURE get_next_prep        ( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2) IS

      l_num             NUMBER;
      l_prep_list       VARCHAR2(1000);
      l_next_prep       NUMBER;
      l_next_prep_name  fnd_user.user_name%TYPE;
      l_tu_id           igi_exp_dus.tu_id%TYPE;

      l_com_du_list     VARCHAR2(28000);

      CURSOR c_com_dus(p_tu_id igi_exp_dus.tu_id%TYPE
                      ,p_du_by_user_id igi_exp_dus.du_by_user_id%TYPE)
      IS
         SELECT du_order_number
               ,du_legal_number
         FROM   igi_exp_dus
         WHERE  tu_id = p_tu_id
         AND    du_status = 'COM'
         AND    du_by_user_id = p_du_by_user_id;


   BEGIN

     -- =============== START DEBUG LOG ================
        DEBUG_LOG_STRING (l_proc_level, 'Get_next_prep.Msg1',
                          ' ** START GET_NEXT_PREP ** ');
     -- =============== END DEBUG LOG ==================

     IF (funcmode = 'RUN') THEN

         -- Get the list of preparers of completed DUS
         l_prep_list
            := wf_engine.GetItemAttrText  ( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'COM_DU_PREP_LIST');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Get_next_prep.Msg2',
                              ' GetItemAttrText COM_DU_PREP_LIST --> ' || l_prep_list);
         -- =============== END DEBUG LOG ==================

         IF (l_prep_list is null) THEN
            -- There are no more preparers in the list
            -- Set result to 'No More Preparers In List'
            result := 'COMPLETE:NO_PREPS_IN_LIST';
            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Get_next_prep.Msg3',
                                 ' l_prep_list is null -- result --> ' || result);
            -- =============== END DEBUG LOG ==================
            return;
         END IF;

         l_num := INSTR(l_prep_list,',',-1);

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Get_next_prep.Msg4',
                              ' l_num --> ' || l_num);
         -- =============== END DEBUG LOG ==================

         IF (l_num = 0) THEN
            -- There is only one preparer left in list
            l_next_prep := l_prep_list;
         ELSE
            -- There is more than one preparer in list
            l_next_prep := SUBSTR(l_prep_list,l_num + 1);
         END IF;

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Get_next_prep.Msg5',
                              ' l_next_prep --> ' || l_next_prep);
         -- =============== END DEBUG LOG ==================

         -- Set the temp_du_preparer_id attribute
         wf_engine.SetItemAttrNumber( itemtype => itemtype,
                                      itemkey  => itemkey,
                                      aname    => 'TEMP_DU_PREPARER_ID',
                                      avalue   => l_next_prep);

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Get_next_prep.Msg6',
                              ' SetItemAttrNumber TEMP_DU_PREPARER_ID --> '||l_next_prep);
         -- =============== END DEBUG LOG ==================

         SELECT user_name
         INTO   l_next_prep_name
         FROM   fnd_user
         WHERE  user_id = l_next_prep;

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Get_next_prep.Msg7',
                              ' l_next_prep_name --> ' || l_next_prep_name);
         -- =============== END DEBUG LOG ==================

         -- Set the temp_du_preparer attribute
         wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                      itemkey  => itemkey,
                                      aname    => 'TEMP_DU_PREPARER_NAME',
                                      avalue   => l_next_prep_name);

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Get_next_prep.Msg8',
                              ' SetItemAttrText TEMP_DU_PREPARER_NAME --> ' || l_next_prep_name);
         -- =============== END DEBUG LOG ==================

         -- Get the TU id
         l_tu_id
            := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'TU_ID');


            FOR I IN c_com_dus(l_tu_id, l_next_prep)
            LOOP

               IF (l_com_du_list is NULL) THEN
                  l_com_du_list := I.du_order_number;
               ELSE
                  l_com_du_list := l_com_du_list ||I.du_order_number;
               END IF;

               -- =============== START DEBUG LOG ================
                  DEBUG_LOG_STRING (l_proc_level, 'Get_next_prep.Msg9',
                                    ' du_order_number --> ' || I.du_order_number);
               -- =============== END DEBUG LOG ==================

               IF (I.du_legal_number is not null) THEN
                  l_com_du_list := l_com_du_list||' ('||I.du_legal_number||')';
               END IF;

               -- =============== START DEBUG LOG ================
                  DEBUG_LOG_STRING (l_proc_level, 'Get_next_prep.Msg10',
                                    ' I.du_legal_number --> ' || I.du_legal_number);
               -- =============== END DEBUG LOG ==================

               l_com_du_list := l_com_du_list||fnd_global.local_chr(10);

               IF LENGTH(l_com_du_list) > 28000 THEN
                  exit;
               END IF;

            END LOOP;


           -- Set the all_dus_list attribute
            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ADD_ATTR1',
                                         avalue   => substr(l_com_du_list, 1, 4000));

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Get_next_prep.Msg11',
                                 ' SetItemAttrText ADD_ATTR1 --> ' || substr(l_com_du_list, 1, 4000));
            -- =============== END DEBUG LOG ==================

            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ADD_ATTR2',
                                         avalue   => substr(l_com_du_list, 4001, 4000));

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Get_next_prep.Msg12',
                                 ' SetItemAttrText ADD_ATTR2 --> ' || substr(l_com_du_list, 4001, 4000));
            -- =============== END DEBUG LOG ==================

            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ADD_ATTR3',
                                         avalue   => substr(l_com_du_list, 8001, 4000));

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Get_next_prep.Msg13',
                                 ' SetItemAttrText ADD_ATTR3 --> ' || substr(l_com_du_list, 8001, 4000));
            -- =============== END DEBUG LOG ==================

            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ADD_ATTR4',
                                         avalue   => substr(l_com_du_list, 12001, 4000));

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Get_next_prep.Msg14',
                                 ' SetItemAttrText ADD_ATTR4 --> ' || substr(l_com_du_list, 12001, 4000));
            -- =============== END DEBUG LOG ==================

            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ADD_ATTR5',
                                         avalue   => substr(l_com_du_list, 16001, 4000));

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Get_next_prep.Msg15',
                                 ' SetItemAttrText ADD_ATTR5 --> ' || substr(l_com_du_list, 16001, 4000));
            -- =============== END DEBUG LOG ==================

            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ADD_ATTR6',
                                         avalue   => substr(l_com_du_list, 20001, 4000));

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Get_next_prep.Msg16',
                                 ' SetItemAttrText ADD_ATTR6 --> ' || substr(l_com_du_list, 20001, 4000));
            -- =============== END DEBUG LOG ==================

            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ADD_ATTR7',
                                         avalue   => substr(l_com_du_list, 24001, 4000));


            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Get_next_prep.Msg17',
                                 ' SetItemAttrText ADD_ATTR7 --> ' || substr(l_com_du_list, 24001, 4000));
            -- =============== END DEBUG LOG ==================

            wf_engine.SetItemAttrText(itemtype => itemtype,
                                      itemkey  => itemkey,
                                      aname    => 'TEMP_DU_BY_PREP_LIST',
                                      avalue   => 'plsqlclob:igi_exp_approval_pkg.Create_du_list/'||itemtype||':'||itemkey);

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Get_next_prep.Msg18',
                                 ' SetItemAttrText TEMP_DU_BY_PREP_LIST --> ' ||
                                 ' plsqlclob:igi_exp_approval_pkg.Create_du_list/'||itemtype||':'||itemkey);
            -- =============== END DEBUG LOG ==================

         -- Set the result to 'Next Preparer Fetched'
         result := 'COMPLETE:NEXT_PREP_FETCHED';

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Get_next_prep.Msg19',
                              ' result --> ' || result);
         -- =============== END DEBUG LOG ==================

      END IF;

      IF (funcmode <> 'RUN') THEN
         result := 'COMPLETE';
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Get_next_prep.Msg20',
                              ' funcmode <> RUN -- result --> ' || result);
         -- =============== END DEBUG LOG ==================
         return;
      END IF;

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Get_next_prep.Msg21',
                           ' ** END GET_NEXT_PREP ** ');
      -- =============== END DEBUG LOG ==================

   EXCEPTION
      WHEN OTHERS THEN
         wf_core.context('IGI_EXP_APPROVAL_PKG','get_next_prep',itemtype,itemkey,
                         to_char(actid),funcmode);
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_UNEXP_ERROR ('Get_next_prep.Unexp1','DEFAULT');
         -- =============== END DEBUG LOG ==================
         raise;

   END get_next_prep;



   -- *************************************************************************
   --    REMOVE_PREP_FROM_LIST
   -- *************************************************************************

   PROCEDURE remove_prep_from_list( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2) IS

      l_num           NUMBER;
      l_prep_list     VARCHAR2(1000);
      l_new_prep_list VARCHAR2(1000);

   BEGIN

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Remove_prep_from_list.Msg1',
                           ' ** START REMOVE_PREP_FROM_LIST ** ');
      -- =============== END DEBUG LOG ==================

      IF (funcmode = 'RUN') THEN

         -- Get the list of preparers of completed dus
         l_prep_list
            := wf_engine.GetItemAttrText  ( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'COM_DU_PREP_LIST');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Remove_prep_from_list.Msg2',
                              ' GetItemAttrText COM_DU_PREP_LIST --> ' || l_prep_list);
         -- =============== END DEBUG LOG ==================

         -- This will remove the last preparer id from the list
         l_num := INSTR(l_prep_list,',',-1);
         l_new_prep_list := SUBSTR(l_prep_list,1,l_num-1);

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Remove_prep_from_list.Msg3',
                              ' l_num --> ' || l_num || ' l_new_prep_list --> ' || l_new_prep_list);
         -- =============== END DEBUG LOG ==================

         -- Set the com_du_prep_list attribute to the new list
         wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                      itemkey  => itemkey,
                                      aname    => 'COM_DU_PREP_LIST',
                                      avalue   => l_new_prep_list);

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Remove_prep_from_list.Msg4',
                              ' SetItemAttrText COM_DU_PREP_LIST --> ' || l_new_prep_list);
         -- =============== END DEBUG LOG ==================

      END IF;

      IF (funcmode <> 'RUN') THEN
         result := 'COMPLETE';
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Remove_prep_from_list.Msg5',
                              ' funcmode <> RUN -- result --> ' || result);
         -- =============== END DEBUG LOG ==================
         return;
      END IF;

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Remove_prep_from_list.Msg6',
                          ' ** END REMOVE_PREP_FROM_LIST ** ');
      -- =============== END DEBUG LOG ==================

   EXCEPTION
      WHEN OTHERS THEN
         wf_core.context('IGI_EXP_APPROVAL_PKG','remove_prep_from_list',itemtype,itemkey,
                         to_char(actid),funcmode);
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_UNEXP_ERROR ('Remove_prep_from_list.Unexp1','DEFAULT');
         -- =============== END DEBUG LOG ==================
         raise;
   END remove_prep_from_list;



   -- *************************************************************************
   --    SET_TU_TO_COMPLETE
   -- *************************************************************************

   PROCEDURE set_tu_to_complete   ( itemtype IN  VARCHAR2,
                                    itemkey  IN  VARCHAR2,
                                    actid    IN  NUMBER,
                                    funcmode IN  VARCHAR2,
                                    result   OUT NOCOPY VARCHAR2) IS

      l_tu_id    igi_exp_dus.tu_id%TYPE;

   BEGIN

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Set_tu_to_complete.Msg1',
                          ' ** START SET_TU_TO_COMPLETE ** ');
      -- =============== END DEBUG LOG ==================

      IF (funcmode = 'RUN') THEN

         -- Get the TU id
         l_tu_id
            := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'TU_ID');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Set_tu_to_complete.Msg2',
                              ' GetItemAttrNumber TU_ID --> ' || l_tu_id);
         -- =============== END DEBUG LOG ==================

         UPDATE igi_exp_tus
         SET    tu_status = 'COM'
         WHERE  tu_id = l_tu_id;

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Set_tu_to_complete.Msg3',
                              ' UPDATE igi_exp_tus --> ' || SQL%ROWCOUNT);
         -- =============== END DEBUG LOG ==================

      END IF;

      IF (funcmode <> 'RUN') THEN
         result := 'COMPLETE';
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Set_tu_to_complete.Msg4',
                              ' funcmode <> RUN -- result --> ' || result);
         -- =============== END DEBUG LOG ==================
         return;
      END IF;

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Set_tu_to_complete.Msg5',
                          ' ** END SET_TU_TO_COMPLETE ** ');
      -- =============== END DEBUG LOG ==================

   EXCEPTION
      WHEN OTHERS THEN
         wf_core.context('IGI_EXP_APPROVAL_PKG','set_tu_to_complete',itemtype,itemkey,
                         to_char(actid),funcmode);
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_UNEXP_ERROR ('set_tu_to_complete.Unexp1','DEFAULT');
         -- =============== END DEBUG LOG ==================
         raise;

   END set_tu_to_complete;



   -- OPSF(I) EXP Bug 2415293  S Brewer 11-JUL-2002 Start(3)
   -- Added new procedures does_tu_have_legal_num and
   -- remove_rej_dus_from_tu  and get_next_rejected_legal_du

   -- *************************************************************************
   --    DOES_TU_HAVE_LEGAL_NUM
   -- *************************************************************************

   PROCEDURE does_tu_have_legal_num( itemtype IN  VARCHAR2,
                                     itemkey  IN  VARCHAR2,
                                     actid    IN  NUMBER,
                                     funcmode IN  VARCHAR2,
                                     result   OUT NOCOPY VARCHAR2) IS

    l_tu_id            igi_exp_dus.tu_id%TYPE;
      l_tu_legal_number  igi_exp_tus.tu_legal_number%TYPE;
 -- Check if the TU has a legal number
 -- Bug 4051910
      CURSOR c_leg_num(c_tu_id number) is
         SELECT tu_legal_number
         FROM   igi_exp_tus
         WHERE  tu_id = c_tu_id;




   BEGIN

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Does_tu_have_legal_num.Msg1',
                          ' ** START DOES_TU_HAVE_LEGAL_NUM ** ');
      -- =============== END DEBUG LOG ==================

      IF (funcmode = 'RUN') THEN

         -- Get the TU id
         l_tu_id
            := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'TU_ID');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Does_tu_have_legal_num.Msg2',
                              ' GetItemAttrNumber TU_ID --> ' || l_tu_id);
         -- =============== END DEBUG LOG ==================

       -- Bug 4051910
      OPEN c_leg_num(l_tu_id);
      FETCH c_leg_num INTO l_tu_legal_number;
      CLOSE c_leg_num;


         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Does_tu_have_legal_num.Msg3',
                              ' l_tu_legal_number --> ' || l_tu_legal_number);
         -- =============== END DEBUG LOG ==================

         IF (l_tu_legal_number is null) THEN
            -- The TU has not been assigned a legal number
            -- Set the result to 'No'
            result := 'COMPLETE:N';
         ELSE
            -- The TU has been assigned a legal number
            -- Set the result to 'Yes'
            result := 'COMPLETE:Y';
         END IF;

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Does_tu_have_legal_num.Msg4',
                              ' result --> ' || result);
         -- =============== END DEBUG LOG ==================

      END IF;

      IF (funcmode <> 'RUN') THEN
         result := 'COMPLETE';
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Does_tu_have_legal_num.Msg5',
                              ' funcmode <> RUN -- result --> ' || result);
         -- =============== END DEBUG LOG ==================
         return;
      END IF;

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Does_tu_have_legal_num.Msg6',
                           ' ** END DOES_TU_HAVE_LEGAL_NUM ** ');
      -- =============== END DEBUG LOG ==================

   EXCEPTION
      WHEN OTHERS THEN
         wf_core.context('IGI_EXP_APPROVAL_PKG','does_tu_have_legal_num',itemtype,itemkey,
                         to_char(actid),funcmode);
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_UNEXP_ERROR ('Does_tu_have_legal_num.Unexp1','DEFAULT');
         -- =============== END DEBUG LOG ==================
         raise;
   END does_tu_have_legal_num;



   -- *************************************************************************
   --    REMOVE_REJ_DUS_FROM_TU
   -- *************************************************************************

   PROCEDURE remove_rej_dus_from_tu( itemtype IN  VARCHAR2,
                                     itemkey  IN  VARCHAR2,
                                     actid    IN  NUMBER,
                                     funcmode IN  VARCHAR2,
                                     result   OUT NOCOPY VARCHAR2) IS

      l_tu_id       igi_exp_dus.tu_id%TYPE;
      l_du_prep_id  igi_exp_dus.du_by_user_id%TYPE;

   BEGIN

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Remove_rej_dus_from_tu.Msg1',
                           ' ** START  REMOVE_REJ_DUS_FROM_TU ** ');
      -- =============== END DEBUG LOG ==================

      IF (funcmode = 'RUN') THEN

         -- Get the TU id
         l_tu_id
            := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'TU_ID');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Remove_rej_dus_from_tu.Msg2',
                              ' GetItemAttrNumber TU_ID --> ' || l_tu_id);
         -- =============== END DEBUG LOG ==================

         -- Get the DU preparer id
         l_du_prep_id
            := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'TEMP_DU_PREPARER_ID');


         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Remove_rej_dus_from_tu.Msg3',
                              ' GetItemAttrNumber TEMP_DU_PREPARER_ID --> ' || l_du_prep_id );
         -- =============== END DEBUG LOG ==================

         -- Remove the rejected DUs (prepared by user l_du_prep_id) from the
         -- TU

	 -- FP Bug 7711356 (not updating the tu_id as null for rejected DU's)
         /*UPDATE igi_exp_dus
         SET    tu_id = null
         WHERE  tu_id = l_tu_id
         AND    du_by_user_id = l_du_prep_id
         AND    du_status = 'REJ';*/

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Remove_rej_dus_from_tu.Msg4',
                              ' UPDATE igi_exp_dus du_status = REJ --> ' || SQL%ROWCOUNT);
         -- =============== END DEBUG LOG ==================

      END IF;

      IF (funcmode <> 'RUN') THEN
         result := 'COMPLETE';
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Remove_rej_dus_from_tu.Msg5',
                              ' funcmode <> RUN -- result --> ' || result);
         -- =============== END DEBUG LOG ==================
         return;
      END IF;

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Remove_rej_dus_from_tu.Msg6',
                           ' ** START  REMOVE_REJ_DUS_FROM_TU ** ');
      -- =============== END DEBUG LOG ==================

   EXCEPTION
      WHEN OTHERS THEN
         wf_core.context('IGI_EXP_APPROVAL_PKG','remove_rej_dus_from_tu',itemtype,itemkey,
                         to_char(actid),funcmode);
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_UNEXP_ERROR ('Remove_rej_dus_from_tu.Unexp1','DEFAULT');
         -- =============== END DEBUG LOG ==================
        raise;
   END remove_rej_dus_from_tu;


   -- *************************************************************************
   --    GET_NEXT_REJECTED_LEGAL_DU
   -- *************************************************************************

   PROCEDURE get_next_rejected_legal_du( itemtype IN  VARCHAR2,
                                         itemkey  IN  VARCHAR2,
                                         actid    IN  NUMBER,
                                         funcmode IN  VARCHAR2,
                                         result   OUT NOCOPY VARCHAR2) IS

      CURSOR c_next_du_rej(p_tu_id igi_exp_dus.tu_id%TYPE)
      IS
         SELECT du_id
               ,du_by_user_id
         FROM   igi_exp_dus du
         WHERE  tu_id = p_tu_id
         AND    du_status = 'REJ'
         AND    EXISTS (SELECT 'AR'
                        FROM   igi_exp_ar_trans ar
                        WHERE  ar.du_id = du.du_id
                        UNION
                        SELECT 'AP'
                        FROM   igi_exp_ap_trans ap
                        WHERE  ap.du_id = du.du_id)
         AND    rownum = 1;


      CURSOR c_rej_du_info(p_tu_id igi_exp_dus.tu_id%TYPE
                          ,p_du_preparer_id igi_exp_dus.du_by_user_id%TYPE)
      IS
         SELECT du_order_number
               ,du_legal_number
         FROM   igi_exp_dus du
         WHERE  tu_id = p_tu_id
         AND    du_status = 'REJ'
         AND    du_by_user_id = p_du_preparer_id;


      l_tu_id           igi_exp_dus.tu_id%TYPE;
      l_du_id           igi_exp_dus.du_id%TYPE;
      l_du_prep_id      igi_exp_dus.du_by_user_id%TYPE;
      l_du_prep_name    fnd_user.user_name%TYPE;

      l_du_rej_list     VARCHAR2(28000);


   BEGIN

    -- =============== START DEBUG LOG ================
       DEBUG_LOG_STRING (l_proc_level, 'Get_next_rejected_legal_du.Msg1',
                         ' ** START  GET_NEXT_REJECTED_LEGAL_DU ** ');
    -- =============== END DEBUG LOG ==================

      IF (funcmode = 'RUN') THEN

         -- Get the TU id
         l_tu_id
            := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'TU_ID');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Get_next_rejected_legal_du.Msg2',
                              ' GetItemAttrNumber TU_ID --> ' || l_tu_id);
         -- =============== END DEBUG LOG ==================

         -- Get the next rejected legal DU in this TU
         OPEN c_next_du_rej(l_tu_id);
         FETCH c_next_du_rej INTO l_du_id, l_du_prep_id;

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Get_next_rejected_legal_du.Msg3',
                              ' l_du_id --> ' || l_du_id || ' l_du_prep_id --> ' || l_du_prep_id);
         -- =============== END DEBUG LOG ==================

         IF (c_next_du_rej%NOTFOUND) THEN
            -- There are no more rejected DUs to deal with
            -- Set result to 'No More DUs'
            result := 'COMPLETE:NO_DUS_IN_LIST';

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Get_next_rejected_legal_du.Msg4',
                                 ' c_next_du_rej%NOTFOUND -- result --> ' || result);
            -- =============== END DEBUG LOG ==================

         ELSE
            -- The next rejected DU has been fetched
            -- Set the temp_du_preparer_id attribute
            wf_engine.SetItemAttrNumber( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'TEMP_DU_PREPARER_ID',
                                         avalue   => l_du_prep_id);

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Get_next_rejected_legal_du.Msg5',
                                 ' SetItemAttrNumber TEMP_DU_PREPARER_ID --> ' || l_du_prep_id);
            -- =============== END DEBUG LOG ==================

            -- Get the name of the preparer to send the notification to
            SELECT user_name
            INTO   l_du_prep_name
            FROM   fnd_user
            WHERE  user_id = l_du_prep_id;

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Get_next_rejected_legal_du.Msg6',
                                 ' l_du_prep_name --> ' || l_du_prep_name);
            -- =============== END DEBUG LOG ==================

            -- Set the temp_du_preparer_name attribute
            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'TEMP_DU_PREPARER_NAME',
                                         avalue   => l_du_prep_name);

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Get_next_rejected_legal_du.Msg7',
                                 ' SetItemAttrText TEMP_DU_PREPARER_NAME --> ' || l_du_prep_name);
            -- =============== END DEBUG LOG ==================

            FOR I IN c_rej_du_info(l_tu_id,l_du_prep_id)
            LOOP

               IF (l_du_rej_list is NULL) THEN
                  l_du_rej_list := I.du_order_number;
               ELSE
                  l_du_rej_list := l_du_rej_list ||I.du_order_number;
               END IF;

               -- =============== START DEBUG LOG ================
                  DEBUG_LOG_STRING (l_proc_level, 'Get_next_rejected_legal_du.Msg8',
                                    ' du_order_number --> ' || I.du_order_number);
               -- =============== END DEBUG LOG ==================

               IF (I.du_legal_number is not null) THEN
                  l_du_rej_list := l_du_rej_list||' ('||I.du_legal_number||')';
               END IF;

               -- =============== START DEBUG LOG ================
                  DEBUG_LOG_STRING (l_proc_level, 'Get_next_rejected_legal_du.Msg9',
                                    ' I.du_legal_number --> ' || I.du_legal_number);
               -- =============== END DEBUG LOG ==================

               l_du_rej_list := l_du_rej_list||fnd_global.local_chr(10);

               IF LENGTH(l_du_rej_list) > 28000 THEN
                  exit;
               END IF;

            END LOOP;

           -- Set the all_dus_list attribute
            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ADD_ATTR1',
                                         avalue   => substr(l_du_rej_list, 1, 4000));

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Get_next_rejected_legal_du.Msg10',
                                 ' SetItemAttrText ADD_ATTR1 --> ' || substr(l_du_rej_list, 1, 4000));
            -- =============== END DEBUG LOG ==================

            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ADD_ATTR2',
                                         avalue   => substr(l_du_rej_list, 4001, 4000));

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Get_next_rejected_legal_du.Msg11',
                                 ' SetItemAttrText ADD_ATTR2 --> ' || substr(l_du_rej_list, 4001, 4000));
            -- =============== END DEBUG LOG ==================

            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ADD_ATTR3',
                                         avalue   => substr(l_du_rej_list, 8001, 4000));

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Get_next_rejected_legal_du.Msg12',
                                 ' SetItemAttrText ADD_ATTR3 --> ' || substr(l_du_rej_list, 8001, 4000));
            -- =============== END DEBUG LOG ==================

            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ADD_ATTR4',
                                         avalue   => substr(l_du_rej_list, 12001, 4000));

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Get_next_rejected_legal_du.Msg13',
                                 ' SetItemAttrText ADD_ATTR4 --> ' || substr(l_du_rej_list, 12001, 4000));
            -- =============== END DEBUG LOG ==================

            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ADD_ATTR5',
                                         avalue   => substr(l_du_rej_list, 16001, 4000));

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Get_next_rejected_legal_du.Msg14',
                                 ' SetItemAttrText ADD_ATTR5 --> ' || substr(l_du_rej_list, 16001, 4000));
            -- =============== END DEBUG LOG ==================

            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ADD_ATTR6',
                                         avalue   => substr(l_du_rej_list, 20001, 4000));

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Get_next_rejected_legal_du.Msg15',
                                 ' SetItemAttrText ADD_ATTR6 --> ' || substr(l_du_rej_list, 20001, 4000));
            -- =============== END DEBUG LOG ==================

            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'ADD_ATTR7',
                                         avalue   => substr(l_du_rej_list, 24001, 4000));


            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Get_next_rejected_legal_du.Msg16',
                                 ' SetItemAttrText ADD_ATTR7 --> ' || substr(l_du_rej_list, 24001, 4000));
            -- =============== END DEBUG LOG ==================

            -- Set the temp_du_by_prep_list attribute
            wf_engine.SetItemAttrText  ( itemtype => itemtype,
                                         itemkey  => itemkey,
                                         aname    => 'TEMP_DU_BY_PREP_LIST',
                                         avalue   => 'plsqlclob:igi_exp_approval_pkg.Create_du_list/'||itemtype||':'||itemkey);


            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Get_next_rejected_legal_du.Msg17',
                                 ' SetItemAttrText TEMP_DU_BY_PREP_LIST --> ' ||
                                 ' plsqlclob:igi_exp_approval_pkg.Create_du_list/'||itemtype||':'||itemkey);
            -- =============== END DEBUG LOG ==================

            -- Set the result to 'Next DU Fetched'
            result := 'COMPLETE:NEXT_DU_FETCHED';

            -- =============== START DEBUG LOG ================
               DEBUG_LOG_STRING (l_proc_level, 'Get_next_rejected_legal_du.Msg18',
                                 ' result --> '||result);
            -- =============== END DEBUG LOG ==================

         END IF;

         IF (c_next_du_rej%ISOPEN) THEN
            CLOSE c_next_du_rej;
         END IF;

      END IF;

      IF (funcmode <> 'RUN') THEN
         result := 'COMPLETE';
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Get_next_rejected_legal_du.Msg19',
                              ' funcmode <> RUN -- result --> '|| result);
         -- =============== END DEBUG LOG ==================
         return;
      END IF;

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Get_next_rejected_legal_du.Msg20',
                           ' ** END  GET_NEXT_REJECTED_LEGAL_DU ** ');
      -- =============== END DEBUG LOG ==================

   EXCEPTION
      WHEN OTHERS THEN
         wf_core.context('IGI_EXP_APPROVAL_PKG','get_next_rejected_legal_du',itemtype,itemkey,
                         to_char(actid),funcmode);
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_UNEXP_ERROR ('Get_next_rejected_legal_du.Unexp1','DEFAULT');
         -- =============== END DEBUG LOG ==================
         raise;

   END get_next_rejected_legal_du;
   -- OPSF(I) EXP Bug 2415293  S Brewer 11-JUL-2002 End(3)


   -- OPSF(I) EXP Bug 2379693  S Brewer 16-JUL-2002 Start(1)
   -- Added new procedure is_transmitter_final_apprv

   -- *************************************************************************
   --    IS_TRANSMITTER_FINAL_APPRV
   -- *************************************************************************

   PROCEDURE is_transmitter_final_apprv( itemtype IN  VARCHAR2,
                                         itemkey  IN  VARCHAR2,
                                         actid    IN  NUMBER,
                                         funcmode IN  VARCHAR2,
                                         result   OUT NOCOPY VARCHAR2) IS

      l_transmitter_position_id  per_all_positions.position_id%TYPE;
      l_final_apprv_pos_id       igi_exp_apprv_profiles.final_apprv_pos_id%TYPE;

   BEGIN

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Is_transmitter_final_apprv.Msg1',
                           ' ** START  IS_TRANSMITTER_FINAL_APPRV ** ');
      -- =============== END DEBUG LOG ==================

      IF (funcmode = 'RUN') THEN

         -- Get the transmitter position id
         l_transmitter_position_id
            := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'TRANSMITTER_POSITION_ID');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Is_transmitter_final_apprv.Msg2',
                              ' GetItemAttrNumber TRANSMITTER_POSITION_ID --> '||l_transmitter_position_id);
         -- =============== END DEBUG LOG ==================

         -- Get the final approver position id
         l_final_apprv_pos_id
            := wf_engine.GetItemAttrNumber( itemtype => itemtype,
                                            itemkey  => itemkey,
                                            aname    => 'FINAL_APPRV_POS_ID');

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Is_transmitter_final_apprv.Msg3',
                              ' GetItemAttrNumber FINAL_APPRV_POS_ID --> '||l_final_apprv_pos_id );
         -- =============== END DEBUG LOG ==================

         -- Check if the transmitter position is the same as the final position
         IF (l_transmitter_position_id = l_final_apprv_pos_id) THEN
            -- The transmitter has the final approval position
            -- Set the result to 'Yes'
            result := 'COMPLETE:Y';
         ELSE
            -- The transmitter is not at the final approval position
            -- Set the result to 'No'
            result := 'COMPLETE:N';
         END IF;

         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Is_transmitter_final_apprv.Msg4',
                              ' result --> '|| result);
         -- =============== END DEBUG LOG ==================

      END IF;

      IF (funcmode <> 'RUN') THEN
         result := 'COMPLETE';
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_STRING (l_proc_level, 'Is_transmitter_final_apprv.Msg5',
                              ' funcmode <> RUN -- result --> ' || result);
         -- =============== END DEBUG LOG ==================
         return;
      END IF;

      -- =============== START DEBUG LOG ================
         DEBUG_LOG_STRING (l_proc_level, 'Is_transmitter_final_apprv.Msg6',
                           ' ** END  IS_TRANSMITTER_FINAL_APPRV ** ');
      -- =============== END DEBUG LOG ==================

   EXCEPTION
      WHEN OTHERS THEN
         wf_core.context('IGI_EXP_APPROVAL_PKG','is_transmitter_final_apprv',itemtype,itemkey,
                         to_char(actid),funcmode);
         -- =============== START DEBUG LOG ================
            DEBUG_LOG_UNEXP_ERROR ('Is_transmitter_final_apprv.Unexp1','DEFAULT');
         -- =============== END DEBUG LOG ==================
          raise;

   END is_transmitter_final_apprv;
   -- OPSF(I) EXP Bug 2379693  S Brewer 16-JUL-2002 End(1)

END igi_exp_approval_pkg;

/
