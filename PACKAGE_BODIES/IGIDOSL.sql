--------------------------------------------------------
--  DDL for Package Body IGIDOSL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGIDOSL" AS
   -- $Header: igidoslb.pls 120.31.12010000.4 2010/02/09 10:32:50 dramired ship $
   --

 /* ============== FND LOG VARIABLES ================== */
    l_debug_level   number := FND_LOG.G_CURRENT_RUNTIME_LEVEL ;
    l_state_level   number := FND_LOG.LEVEL_STATEMENT ;
    l_proc_level    number := FND_LOG.LEVEL_PROCEDURE ;
    l_event_level   number := FND_LOG.LEVEL_EVENT ;
    l_excep_level   number := FND_LOG.LEVEL_EXCEPTION ;
    l_error_level   number := FND_LOG.LEVEL_ERROR ;
    l_unexp_level   number := FND_LOG.LEVEL_UNEXPECTED ;

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

   -- Global variable to hold user id
   g_userid        NUMBER ;
   g_currency_code VARCHAR2(15);
   g_sob_id        NUMBER(15);
   g_total_text    VARCHAR2(100);

   CURSOR C_curr (p_sob_id NUMBER)
   IS
      SELECT currency_code FROM gl_sets_of_books
      WHERE  set_of_books_id = p_sob_id;

   -- Cursor to FETCH user id FROM user name
   CURSOR c_userid (p_username VARCHAR2) IS
      SELECT user_id, employee_id
      FROM   fnd_user
      WHERE  user_name = p_username;

   --
   --
   -- PUBLIC ROUTINES
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
             FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igidosl.' || P_module ,TRUE);
       ELSIF (P_error_type = 'USER') THEN
             FND_LOG.MESSAGE(l_unexp_level, 'igi.plsql.igidosl.' || P_module ,TRUE);
       END IF;

    END IF;

  END Debug_log_unexp_error;

   /* =================== DEBUG_LOG_STRING =================== */

   Procedure Debug_log_string (P_level   IN NUMBER,
                               P_module  IN VARCHAR2,
                               P_Message IN VARCHAR2)
   IS

   BEGIN

     IF (P_level >= l_debug_level) THEN
         FND_LOG.STRING(P_level, 'igi.plsql.igidosl.' || P_module, P_message) ;
     END IF;

   END Debug_log_string;

   /* =================== SELECTOR =================== */

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

     /* =============== START DEBUG LOG ================ */
         DEBUG_LOG_STRING (l_proc_level, 'selector.Msg1',
                           ' ** BEGIN SELECTOR ** ');
     /* =============== END DEBUG LOG ================== */
      -- Bug 4124934 Start

      IF funcmode = 'RUN'
      THEN
          -- Return process to run when workflow is invoked
          resultout := 'DOSFLOWE';

      ELSIF funcmode = 'TEST_CTX'
      THEN
          -- Code that compares current session context
          -- with the work item context required to execute
          -- the workflow safely

          fnd_profile.get (name=>'ORG_ID', val=> l_session_org_id);

          l_work_item_org_id := wf_engine.GetItemAttrNumber
                                    (itemtype,
                                     itemkey,
                                     'ORG_ID');

          IF l_session_org_id = l_work_item_org_id
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

         DEBUG_LOG_STRING (l_proc_level, 'Selector.Msg',
                           ' Setting apps context with userid, respid, applid as '
                           ||l_user_id ||' '|| l_resp_id ||' '|| l_appl_id );


          FND_GLOBAL.apps_initialize(l_user_id,l_resp_id,l_appl_id);

          resultout := 'COMPLETE';
      ELSE
          resultout := 'COMPLETE';
      END IF;

      -- Bug 4124934 End

      /* =============== START DEBUG LOG ================ */
         DEBUG_LOG_STRING (l_proc_level, 'Selector.Msg2',
                           ' result --> ' || resultout);
         DEBUG_LOG_STRING (l_proc_level, 'selector.Msg3',
                           ' ** END SELECTOR ** ' || resultout);
      /* =============== END DEBUG LOG ================== */

   EXCEPTION
      WHEN OTHERS THEN
        /* =============== START DEBUG LOG ================ */
           DEBUG_LOG_UNEXP_ERROR ('selector.unexp1','DEFAULT');
        /* =============== END DEBUG LOG ================== */
        resultout := NULL;
        Wf_Core.Context ('IGIDOSL','Selector', itemtype, itemkey,
                          TO_CHAR(actid),funcmode);
        RAISE;
   END Selector;

  /* ========================== STARTUP ============================= */

   PROCEDURE Startup (Wkf_Name                   VARCHAR2,
                      Dossier_Id                 NUMBER,
                      Dossier_Num                VARCHAR2,
                      ledger_id                  NUMBER,  -- Added for bug 6126275
                      Packet_Id                  NUMBER,
                      User_Name                  VARCHAR2,
                      Dossier_Transaction_Name   VARCHAR2,
                      Dossier_Description        VARCHAR2,
                      User_Id                    VARCHAR2,
                      Responsibility_Id          VARCHAR2,
                      Dossier_Transaction_Detail VARCHAR2) IS

      ItemType       VARCHAR2(30) := Wkf_name;
      ItemKey        VARCHAR2(60) := (Dossier_Num);
      UserKey        VARCHAR2(50) := 'DOSFLOW'||Dossier_Num;
      l_trx_status   VARCHAR2(80);
      l_trx_number   VARCHAR2(60);
      l_approval_run NUMBER;

      l_total_amount NUMBER;
      l_formatted_total_amount VARCHAR2(100);

      l_employee_id           NUMBER(15);
      l_preparer_name         VARCHAR2(80);
      l_preparer_display_name VARCHAR2(80);


      CURSOR c_source_total
      IS
        SELECT SUM(NVL(s.funds_available,0) - NVL(s.new_balance,0))
        FROM   igi_dos_trx_sources s
        WHERE  trx_id IN (
                          SELECT trx_id FROM igi_dos_trx_headers
                          WHERE  trx_number = Dossier_num
                          AND    dossier_id = Dossier_id);

   BEGIN

     /* =============== START DEBUG LOG ================ */
         DEBUG_LOG_STRING (l_proc_level, 'startup.Msg1',
                           ' ** BEGIN STARTUP ** ');
     /* =============== END DEBUG LOG ================== */

      -- set of books id.
     -- g_sob_id := FND_PROFILE.VALUE ('GL_SET_OF_BKS_ID'); /* Commented for bug 6126275 */
        g_sob_id := ledger_id;  /* Added for bug 6126275 */
      /* =============== START DEBUG LOG ================ */
         DEBUG_LOG_STRING (l_proc_level, 'startup.Msg2',
                           ' g_sob_id       --> ' || g_sob_id);
      /* =============== END DEBUG LOG ================== */

      -- currency code.
      OPEN  c_curr(g_sob_id);
      FETCH c_curr INTO g_currency_code;
      CLOSE c_curr;

      /* =============== START DEBUG LOG ================ */
         DEBUG_LOG_STRING (l_proc_level, 'startup.Msg3',
                           ' g_curency_code --> ' || g_currency_code);
      /* =============== END DEBUG LOG ================== */

      -- Get user id
      OPEN  c_userid (User_Name);
      FETCH c_userid INTO g_userid, l_employee_id;
      CLOSE c_userid;

      /* =============== START DEBUG LOG ================ */
         DEBUG_LOG_STRING (l_proc_level, 'startup.Msg4',
                           ' l_employee_id --> ' || l_employee_id);
      /* =============== END DEBUG LOG ================== */

      SELECT meaning
      INTO   l_trx_status
      FROM   igi_lookups
      WHERE  lookup_type = 'DOSSIER STATUS'
      AND    lookup_code = 'INPROCESS';

      /* =============== START DEBUG LOG ================ */
         DEBUG_LOG_STRING (l_proc_level, 'startup.Msg5',
                           ' l_trx_status  --> ' || l_trx_status);
      /* =============== END DEBUG LOG ================== */

      -- Flag the DOSSIER as in process
      UPDATE igi_dos_trx_headers trx
      SET    trx.trx_status = l_trx_status,
             trx.last_update_date= sysdate
      WHERE  trx.trx_number = dossier_num;

     /* =============== START DEBUG LOG ================ */
         DEBUG_LOG_STRING (l_proc_level, 'startup.Msg6',
                           ' updated igi_dos_trx_headers ');
     /* =============== END DEBUG LOG ================== */

      -- Get the approval run id
      SELECT igi_dos_approval_run_s1.NextVal
      INTO   l_approval_run
      FROM   sys.dual;

      /* =============== START DEBUG LOG ================ */
         DEBUG_LOG_STRING (l_proc_level, 'startup.Msg7',
                           ' l_approval_run --> ' || l_approval_run);
      /* =============== END DEBUG LOG ================== */

      -- Build the unique item key
      ItemKey := ItemKey || '/' || TO_CHAR(l_approval_run);

      /* =============== START DEBUG LOG ================ */
         DEBUG_LOG_STRING (l_proc_level, 'startup.Msg8',
                           ' Itemkey --> ' || itemkey);
      /* =============== END DEBUG LOG ================== */

      -- Workflow Initiation
      --4124934 added  Process parameter
      Wf_Engine.CreateProcess ( itemtype =>  ItemType,
                                itemkey  =>  ItemKey,
                                process => 'DOSFLOWE');

      /* =============== START DEBUG LOG ================ */
         DEBUG_LOG_STRING (l_proc_level, 'startup.Msg9',
                           ' calling create process ');
         DEBUG_LOG_STRING (l_proc_level, 'startup.Msg3',
                           ' Assigning workflow attribute values ');
      /* =============== END DEBUG LOG ================== */

      --
      -- Assign workflow item attribute values
      --

      Wf_Engine.SetItemAttrNumber ( itemtype =>  ItemType,
                                    itemkey  =>  ItemKey,
                                    aname    =>  'DOSSIER_ID',
                                    avalue   =>  Dossier_Id);

      /* =============== START DEBUG LOG ================ */
         DEBUG_LOG_STRING (l_proc_level, 'startup.Msg10',
                           ' Dossier id           --> ' || Dossier_id);
      /* =============== END DEBUG LOG ================== */

      Wf_Engine.SetItemAttrText ( itemtype =>  ItemType,
                                  itemkey  =>  ItemKey,
                                  aname    =>  'DOSSIER_NUM',
                                  avalue   =>  Dossier_Num);

      /* =============== START DEBUG LOG ================ */
         DEBUG_LOG_STRING (l_proc_level, 'startup.Msg11',
                           ' Dossier Num           --> ' || Dossier_num);
      /* =============== END DEBUG LOG ================== */

      Wf_Engine.SetItemAttrText ( itemtype => ItemType,
                                  itemkey  => ItemKey,
                                  aname    => 'INITIAL_ENTRY_FLAG',
                                  avalue   => 'TRUE');

      /* =============== START DEBUG LOG ================ */
         DEBUG_LOG_STRING (l_proc_level, 'startup.Msg12',
                           ' Initial entry flag    --> ' || 'TRUE');
      /* =============== END DEBUG LOG ================== */

      Wf_Engine.SetItemAttrNumber ( itemtype =>  ItemType,
                                    itemkey  =>  ItemKey,
                                    aname    =>  'PACKET_ID',
                                    avalue   =>  Packet_Id);

      /* =============== START DEBUG LOG ================ */
         DEBUG_LOG_STRING (l_proc_level, 'startup.Msg13',
                           ' Packet id            --> ' || Packet_id);
      /* =============== END DEBUG LOG ================== */

      Wf_Engine.SetItemAttrText ( itemtype =>  ItemType,
                                  itemkey  =>  ItemKey,
                                  aname    =>  'CREATOR_NAME',
                                  avalue   =>  User_Name);

      /* =============== START DEBUG LOG ================ */
         DEBUG_LOG_STRING (l_proc_level, 'startup.Msg14',
                           ' CREATOR_NAME        --> ' || User_Name);
      /* =============== END DEBUG LOG ================== */

      Wf_Engine.SetItemAttrText ( itemtype =>  ItemType,
                                  itemkey  =>  ItemKey,
                                  aname    =>  'DOSSIER_TRANSACTION_NAME',
                                  avalue   =>  Dossier_Transaction_Name);

      /* =============== START DEBUG LOG ================ */
         DEBUG_LOG_STRING (l_proc_level, 'startup.Msg15',
                           ' DOSSIER_TRANSACTION_NAME --> ' || Dossier_Transaction_Name);
      /* =============== END DEBUG LOG ================== */

      Wf_Engine.SetItemAttrText ( itemtype =>  ItemType,
                                  itemkey  =>  ItemKey,
                                  aname    =>  'DOSSIER_DESCRIPTION',
                                  avalue   =>  Dossier_Description);

      /* =============== START DEBUG LOG ================ */
          DEBUG_LOG_STRING (l_proc_level, 'startup.Msg15.1',
                            ' DOSSIER_DESCRIPTION  --> ' || Dossier_Description);
      /* =============== END DEBUG LOG ================== */

      OPEN  c_source_total;
      FETCH c_source_total INTO l_total_amount;
      CLOSE c_source_total;
-- Bug 5138221 .. Start
      l_formatted_total_amount := TO_CHAR(l_total_amount,   FND_CURRENCY.Get_Format_Mask(g_currency_code,22));
-- Bug 5138221 .. End
      Wf_Engine.SetItemAttrText ( itemtype =>  ItemType,
                                  itemkey  =>  ItemKey,
                                  aname    =>  'TOTAL',
                                  avalue   =>  l_formatted_total_amount);


      /* =============== START DEBUG LOG ================ */
         DEBUG_LOG_STRING (l_proc_level, 'startup.Msg16',
                           ' TOTAL_AMOUNT --> ' || l_formatted_total_amount);
     /* =============== END DEBUG LOG ================== */

      Wf_Engine.SetItemAttrText ( itemtype =>  ItemType,
                                  itemkey  =>  ItemKey,
                                  aname    =>  'DOCUMENT_ID',
                                  avalue   =>  itemtype||':'||itemkey);

     /* =============== START DEBUG LOG ================ */
         DEBUG_LOG_STRING (l_proc_level, 'startup.Msg17',
                           ' DOCUMENT_ID         --> ' || itemtype||':'||itemkey);
     /* =============== END DEBUG LOG ================== */

      Wf_Engine.SetItemAttrText ( itemtype =>  ItemType,
                                  itemkey  =>  ItemKey,
                                  aname    =>  'DOSSIER_TRANSACTION_DETAIL',
                                  avalue   =>  'plsqlclob:igidosl.dossier_transaction_detail/'||itemtype||':'||itemkey);

     /* =============== START DEBUG LOG ================ */
         DEBUG_LOG_STRING (l_proc_level, 'startup.Msg18',
                           ' DOSSIER_TRANSACTION_DETAIL  --> ' ||
                           'plsqlclob:igidosl.dossier_transaction_detail/'||itemtype||':'||itemkey);
     /* =============== END DEBUG LOG ================== */

      Wf_Engine.SetItemAttrText ( itemtype =>  ItemType,
                                  itemkey  =>  ItemKey,
                                  aname    =>  'USER_ID',
                                  avalue   =>  User_Id);

     /* =============== START DEBUG LOG ================ */
         DEBUG_LOG_STRING (l_proc_level, 'startup.Msg19',
                           ' USER_ID                    --> ' || User_Id );
     /* =============== END DEBUG LOG ================== */

      Wf_Engine.SetItemAttrText ( itemtype =>  ItemType,
                                  itemkey  =>  ItemKey,
                                  aname    =>  'RESPONSIBILITY_ID',
                                  avalue   =>  Responsibility_Id);

     /* =============== START DEBUG LOG ================ */
         DEBUG_LOG_STRING (l_proc_level, 'startup.Msg20',
                           ' RESPONSIBILITY_ID         --> ' || Responsibility_Id );
     /* =============== END DEBUG LOG ================== */

      -- Retrieve preparer's User name (Login name for Apps) and displayed name
      wf_directory.GetUserName(p_orig_system    => 'PER',
                               p_orig_system_id => l_employee_id,
                               p_name           => l_preparer_name,
                               p_display_name   => l_preparer_display_name );


      -- Copy username to Workflow
      wf_engine.SetItemAttrText( itemtype     => itemtype,
                                 itemkey      => itemkey,
                                 aname        => 'PREPARER_NAME',
                                 avalue       => l_preparer_display_name );

     /* =============== START DEBUG LOG ================ */
         DEBUG_LOG_STRING (l_proc_level, 'startup.Msg21',
                           ' PREPARER_NAME            --> ' || l_preparer_display_name );
     /* =============== END DEBUG LOG ================== */

      -- Copy displayed username to Workflow
      wf_engine.SetItemAttrText( itemtype     => itemtype,
                                 itemkey      => itemkey,
                                 aname        => 'PREPARER_LOGIN_NAME',
                                 avalue       => l_preparer_name );

     /* =============== START DEBUG LOG ================ */
         DEBUG_LOG_STRING (l_proc_level, 'startup.Msg22',
                           ' PREPARER_LOGIN_NAME      --> ' || l_preparer_name );
     /* =============== END DEBUG LOG ================== */

      --
      -- Set process attributes
      --

     /* =============== START DEBUG LOG ================ */
         DEBUG_LOG_STRING (l_proc_level, 'startup.Msg23',
                           ' Setting process attributes ');
     /* =============== END DEBUG LOG ================== */

      Wf_Engine.SetItemOwner ( itemtype =>  ItemType,
                               itemkey  =>  ItemKey,
                               owner    =>  User_name);

      Wf_Engine.SetItemUserKey ( itemtype =>  ItemType,
                                 itemkey  =>  ItemKey,
                                 userkey  =>  UserKey);

     /* =============== START DEBUG LOG ================ */
         DEBUG_LOG_STRING (l_proc_level, 'startup.Msg24',
                           ' Starting workflow process ' );
     /* =============== END DEBUG LOG ================== */

      -- Set user id, responsibility id , org id and application id context values
      -- Bug 4124934 , Start
      wf_engine.SetItemAttrText  ( itemtype => ItemType,
                                   itemkey  => ItemKey,
                                   aname    => 'ORG_ID',
                                   avalue   => FND_PROFILE.VALUE('ORG_ID'));

      wf_engine.SetItemAttrText  ( itemtype => ItemType,
                                   itemkey  => ItemKey,
                                   aname    => 'USER_ID',
                                   avalue   => FND_PROFILE.VALUE('USER_ID'));

      wf_engine.SetItemAttrText  ( itemtype => ItemType,
                                   itemkey  => ItemKey,
                                   aname    => 'RESPONSIBILITY_ID',
                                   avalue   => FND_PROFILE.VALUE('RESP_ID'));

      wf_engine.SetItemAttrText  ( itemtype => ItemType,
                                   itemkey  => ItemKey,
                                   aname    => 'RESP_APPL_ID',
                                   avalue   => FND_PROFILE.VALUE('RESP_APPL_ID'));
      -- Bug 4124934 End

      --
      -- Kick-off the workflow process instance
      --
      Wf_Engine.StartProcess ( itemtype =>  ItemType,
                               itemkey  =>  ItemKey);

      COMMIT;

     /* =============== START DEBUG LOG ================ */
         DEBUG_LOG_STRING (l_proc_level, 'startup.Msg25',
                           ' ** END OF STARTUP ** ');
     /* =============== END DEBUG LOG ================== */


   EXCEPTION
      WHEN OTHERS THEN
        /* =============== START DEBUG LOG ================ */
           DEBUG_LOG_UNEXP_ERROR ('startup.unexp1','DEFAULT');
        /* =============== END DEBUG LOG ================== */
        Wf_Core.Context ('IGIDOSL', 'Startup', itemtype, itemkey,
                          ' username='||user_name);
        RAISE;
   END Startup;

   /* ========================== SETROLE ================== */

   PROCEDURE SetRole ( itemtype      VARCHAR2,
                       itemkey       VARCHAR2,
                       actid         NUMBER,
                       funcmode      VARCHAR2,
                       result    OUT NOCOPY VARCHAR2)
   IS

      l_picked_role wf_notifications.responder%TYPE;

   BEGIN

     /* =============== START DEBUG LOG ================ */
         DEBUG_LOG_STRING (l_proc_level, 'setrole.Msg1',
                           ' ** START SETROLE ** ');
     /* =============== END DEBUG LOG ================== */

      IF funcmode <> 'RUN' THEN
         result := 'COMPLETE';
         /* =============== START DEBUG LOG ================ */
            DEBUG_LOG_STRING (l_proc_level, 'setrole.Msg2',
                              ' funcmode <> RUN - result --> '
                              || result || ' -- RETURN ');
         /* =============== END DEBUG LOG ================== */

         RETURN;
      END IF;

      l_picked_role := Wf_Engine.GetItemAttrText ( itemtype =>  itemtype,
                                                   itemkey  =>  itemkey,
                                                   aname    =>  'PICKED_ROLE');

     /* =============== START DEBUG LOG ================ */
         DEBUG_LOG_STRING (l_proc_level, 'setrole.Msg3',
                           ' l_picked_role --> '|| l_picked_role);
     /* =============== END DEBUG LOG ================== */

      Wf_Engine.SetItemAttrText ( itemtype =>  itemtype,
                                  itemkey  =>  itemkey,
                                  aname    =>  'ROLE_NAME',
                                  avalue   =>  l_picked_role);

     /* =============== START DEBUG LOG ================ */
         DEBUG_LOG_STRING (l_proc_level, 'setrole.Msg4',
                           ' setting l_picked_role to ROLE_NAME ');
     /* =============== END DEBUG LOG ================== */

      Wf_Engine.SetItemAttrText ( itemtype =>  itemtype,
                                  itemkey  =>  itemkey,
                                  aname    =>  'SELECTED_USER_NAME',
                                  avalue   =>  l_picked_role);

     /* =============== START DEBUG LOG ================ */
         DEBUG_LOG_STRING (l_proc_level, 'setrole.Msg5',
                           ' setting l_picked_role to SELECTED_USER_NAME ');
     /* =============== END DEBUG LOG ================== */

      result := 'COMPLETE';

     /* =============== START DEBUG LOG ================ */
         DEBUG_LOG_STRING (l_proc_level, 'setrole.Msg6',
                           ' ** END SETROLE ** ');
     /* =============== END DEBUG LOG ================== */


   EXCEPTION
      WHEN OTHERS THEN
        /* =============== START DEBUG LOG ================ */
           DEBUG_LOG_UNEXP_ERROR ('setrole.Unexp1','DEFAULT');
        /* =============== END DEBUG LOG ================== */

         result := NULL;
         Wf_Core.Context ('IGIDOSL', 'SetRole', itemtype, itemkey ,
                          TO_CHAR(actid),funcmode);
         RAISE;
   END SetRole;

  /* ================== GETPARENTPOSITION ================== */

   PROCEDURE GetParentPosition (itemtype     VARCHAR2,
                                itemkey      VARCHAR2,
                                actid        NUMBER,
                                funcmode     VARCHAR2,
                                result   OUT NOCOPY VARCHAR2)
   IS

      l_creator_name wf_notifications.responder%TYPE
         := Wf_Engine.GetItemAttrText (itemtype => itemtype,
                                       itemkey  => itemkey,
                                       aname    => 'CREATOR_NAME');

      l_initial_entry VARCHAR2(5)
         := Wf_Engine.GetItemAttrText (itemtype => itemtype,
                                       itemkey  => itemkey,
                                       aname    => 'INITIAL_ENTRY_FLAG');

      l_pos_struct_element_id per_pos_structure_elements.pos_structure_element_id%TYPE
         := Wf_Engine.GetItemAttrNumber (itemtype =>  itemtype,
                                         itemkey  =>  itemkey,
                                         aname    =>  'POS_STRUCTURE_ELEMENT_ID');

      l_dossier_id igi_dos_doc_types.dossier_id%TYPE
         :=Wf_Engine.GetItemAttrNumber (itemtype =>  ItemType,
                                        itemkey  =>  ItemKey,
                                        aname    =>  'DOSSIER_ID');

      l_picked_role             wf_notifications.responder%TYPE;
      l_error                   VARCHAR2(1000) ;
      l_position_structure_id   per_position_structures.position_structure_id%TYPE ;
      l_structure_version_id    per_pos_structure_versions.pos_structure_version_id%TYPE ;
      l_structure_element_id    per_pos_structure_elements.pos_structure_element_id%TYPE ;
      l_parent_position_id      per_positions.position_id%TYPE ;
      l_position_id             per_all_positions.position_id%TYPE;
      l_top_position_id         per_all_positions.position_id%TYPE ;
      l_hierarchy_version_id    per_pos_structure_versions.pos_structure_version_id%TYPE;
      l_hierarchy_id            per_position_structures.position_structure_id%TYPE;
      l_business_group_id       hr_all_positions_f.business_group_id%TYPE;
      l_organization_id         hr_all_positions_f.organization_id%TYPE;
      l_current_user_name       fnd_user.user_name%TYPE;

      cur_pos_not_found         EXCEPTION ;
      pos_hier_not_found        EXCEPTION ;
      pos_hier_ver_not_found    EXCEPTION ;
      top_pos_not_found         EXCEPTION ;
      par_pos_not_found         EXCEPTION ;

      /*************************************/
      /* FETCH current position of creator */
      /*************************************/

      CURSOR c_cur_pos
      IS
        SELECT  hap.position_id,
                hap.business_group_id,
                hap.organization_id,
                fu.user_name
         FROM   hr_all_positions_f      hap,
                per_all_assignments_f   paa,
                fnd_user                fu ,
                per_people_f p,
                per_periods_of_service b
         WHERE
                fu.user_id = g_userid
         AND    paa.person_id = p.person_id
         AND    paa.primary_flag = 'Y'
         AND    paa.period_of_service_id = b.period_of_service_id
         AND    TRUNC(SYSDATE) BETWEEN p.effective_start_date AND p.effective_end_date
         AND    TRUNC(SYSDATE) BETWEEN paa.effective_start_date AND paa.effective_end_date
         AND    (b.actual_termination_date is null OR b.actual_termination_date>= trunc(sysdate)  )
         AND    p.employee_number IS NOT NULL
         and    fu.start_date <= SYSDATE
         and    NVL(fu.end_date,SYSDATE) >= SYSDATE
         and    fu.employee_id IS NOT NULL
         and    fu.employee_id = P.PERSON_ID
         and    NVL(b.actual_termination_date,SYSDATE) >= SYSDATE
         and    P.business_group_id = paa.business_group_id
         and    paa.assignment_type = 'E'
         and    paa.business_group_id = hap.business_group_id
         and    paa.position_id IS NOT NULL
         and    paa.position_id = hap.position_id
         and    paa.organization_id = hap.organization_id
         and    hap.date_effective <= SYSDATE
         and    NVL(hap.date_end, SYSDATE) >= SYSDATE
         and    NVL(UPPER(hap.status), 'VALID') NOT IN ('INVALID') ;



      /*********************************************/
      /* FETCH position hierarchy for dossier type */
      /*********************************************/

      CURSOR c_pos_hier (p_dossier_id igi_dos_doc_types.dossier_id%TYPE)
      IS
         SELECT hierarchy_id
         FROM igi_dos_doc_types
         WHERE dossier_id = p_dossier_id;

      /***********************************************/
      /* FETCH current version of position hierarchy */
      /***********************************************/

      CURSOR c_pos_hier_ver(p_hierarchy_id igi_dos_doc_types.hierarchy_id%TYPE,
                            p_business_group_id hr_all_positions_f.business_group_id%TYPE)
      IS
         SELECT pos_structure_version_id
         FROM   per_pos_structure_versions
     WHERE  position_structure_id = p_hierarchy_id
     AND    SYSDATE BETWEEN date_FROM AND NVL(date_to, SYSDATE)
         AND    business_group_id = p_business_group_id
     AND    version_number =
           (SELECT MAX(version_number)
            FROM   per_pos_structure_versions
            WHERE  position_structure_id = p_hierarchy_id
            AND    SYSDATE BETWEEN date_FROM AND NVL(date_to,SYSDATE)
            AND    business_group_id = p_business_group_id);

      /***********************************/
      /* FETCH top position in hierarchy */
      /***********************************/

      CURSOR c_get_top_position
         (p_pos_structure_ver_id per_pos_structure_elements.pos_structure_version_id%TYPE,
          p_business_group_id hr_all_positions_f.business_group_id%TYPE)
      IS
         SELECT ppse.parent_position_id
         FROM   per_pos_structure_elements ppse
         WHERE  ppse.pos_structure_version_id = p_pos_structure_ver_id
         AND    business_group_id = p_business_group_id
         AND    ppse.parent_position_id NOT IN
            (SELECT subordinate_position_id
             FROM   per_pos_structure_elements
             WHERE  pos_structure_version_id = p_pos_structure_ver_id
             AND    business_group_id = p_business_group_id);

      /****************************/
      /* FETCH parent position id */
      /****************************/

      CURSOR c_par_pos_id
         (p_hier_ver_id per_pos_structure_versions.pos_structure_version_id%TYPE,
          p_position_id per_all_positions.position_id%TYPE,
          p_business_group_id hr_all_positions_f.business_group_id%TYPE)
      IS
         SELECT parent_position_id
         FROM   per_pos_structure_elements
         WHERE  pos_structure_version_id = p_hier_ver_id
         AND    business_group_id = p_business_group_id
         AND    subordinate_position_id = p_position_id;

    BEGIN

     /* =============== START DEBUG LOG ================ */
         DEBUG_LOG_STRING (l_proc_level, 'getparentposition.Msg1',
                           ' ** START GETPARENTPOSITION ** ');
     /* =============== END DEBUG LOG ================== */

       IF funcmode <> 'RUN' THEN
          /* =============== START DEBUG LOG ================ */
             DEBUG_LOG_STRING (l_proc_level, 'getparentposition.Msg2',
                               ' result --> COMPLETE ');
          /* =============== END DEBUG LOG ================== */

          result := 'COMPLETE';
          RETURN;
       ELSE
          /* =============== START DEBUG LOG ================ */
             DEBUG_LOG_STRING (l_proc_level, 'getparentposition.Msg3',
                               ' result --> ERROR ');
          /* =============== END DEBUG LOG ================== */
          result := 'Error' ;
       END IF;

      /* =============== START DEBUG LOG ================ */
         DEBUG_LOG_STRING (l_proc_level, 'getparentposition.Msg4',
                           ' l_initial_entry --> ' || l_initial_entry);
      /* =============== END DEBUG LOG ================== */

      IF l_initial_entry = 'TRUE' THEN

         -- Get the Current Position
         BEGIN
            OPEN  c_cur_pos;
            FETCH c_cur_pos INTO l_position_id,
                                 l_business_group_id,
                                 l_organization_id,
                                 l_current_user_name;
            CLOSE c_cur_pos ;

            /* =============== START DEBUG LOG ================ */
               DEBUG_LOG_STRING (l_proc_level, 'getparentposition.Msg5',
                                 ' l_position_id --> '       || l_position_id ||
                                 ' l_business_group_id --> ' || l_business_group_id ||
                                 ' l_organization_id --> '   || l_organization_id ||
                                 ' l_current_user_name --> ' || l_current_user_name);
            /* =============== END DEBUG LOG ================== */

         EXCEPTION
            WHEN OTHERS THEN
               FND_MESSAGE.SET_NAME('IGI','IGI_DOS_WKF_NO_CURRENT_POS');
               FND_MESSAGE.SET_TOKEN('USER_ID',g_userid);
               /* =============== START DEBUG LOG ================ */
                  DEBUG_LOG_UNEXP_ERROR ('getparentposition.Unexp2','USER');
               /* =============== END DEBUG LOG ================== */
               RAISE cur_pos_not_found;
         END;

         /* =============== START DEBUG LOG ================ */
            DEBUG_LOG_STRING (l_proc_level, 'getparentposition.Msg6',
                              ' Setting attribute text ');
         /* =============== END DEBUG LOG ================== */

         Wf_Engine.SetItemAttrText (itemtype => ItemType,
                                    itemkey  => ItemKey,
                                    aname    => 'CURRENT_POSITION_ID',
                                    avalue   => l_position_id);

         /* =============== START DEBUG LOG ================ */
            DEBUG_LOG_STRING (l_proc_level, 'getparentposition.Msg7',
                              ' l_position_id - CURRENT_POSITION_ID --> ' || l_position_id );
         /* =============== END DEBUG LOG ================== */


         Wf_Engine.SetItemAttrText (itemtype => ItemType,
                                    itemkey  => ItemKey,
                                    aname    => 'BUSINESS_GROUP_ID',
                                    avalue   => l_business_group_id);

         /* =============== START DEBUG LOG ================ */
            DEBUG_LOG_STRING (l_proc_level, 'getparentposition.Msg8',
                              ' l_business_group_id - BUSINESS_GROUP_ID --> ' || l_business_group_id );
         /* =============== END DEBUG LOG ================== */

         Wf_Engine.SetItemAttrText (itemtype => ItemType,
                                    itemkey  => ItemKey,
                                    aname    => 'ORGANIZATION_ID',
                                    avalue   => l_organization_id);

         /* =============== START DEBUG LOG ================ */
            DEBUG_LOG_STRING (l_proc_level, 'getparentposition.Msg9',
                              ' l_organization_id - ORGANIZATION_ID --> ' || l_organization_id );
         /* =============== END DEBUG LOG ================== */

         Wf_Engine.SetItemAttrText (itemtype => ItemType,
                                    itemkey  => ItemKey,
                                    aname    => 'CURRENT_USER_NAME',
                                    avalue   => l_current_user_name);

         /* =============== START DEBUG LOG ================ */
            DEBUG_LOG_STRING (l_proc_level, 'getparentposition.Msg10',
                              ' l_current_user_name - CURRENT_USER_NAME --> ' || l_current_user_name );
         /* =============== END DEBUG LOG ================== */

         -- Get the Position Hierarchy
         BEGIN

            /* =============== START DEBUG LOG ================ */
               DEBUG_LOG_STRING (l_proc_level, 'getparentposition.Msg11',
                                 ' Getting Position Hierarchy ');
            /* =============== END DEBUG LOG ================== */

            OPEN  c_pos_hier(l_dossier_id);
            FETCH c_pos_hier INTO l_hierarchy_id;
            CLOSE c_pos_hier;

         EXCEPTION

            WHEN OTHERS THEN
              FND_MESSAGE.SET_NAME('IGI','IGI_DOS_WKF_NO_HIERARCHY');
              FND_MESSAGE.SET_TOKEN('DOSSIER_ID',l_dossier_id);
              /* =============== START DEBUG LOG ================ */
                 DEBUG_LOG_UNEXP_ERROR ('getparentposition.Unexp3','USER');
              /* =============== END DEBUG LOG ================== */
              RAISE pos_hier_not_found;
         END;

         Wf_Engine.SetItemAttrText (itemtype => ItemType,
                                    itemkey  => ItemKey,
                                    aname    => 'POS_STRUCTURE_ID',
                                    avalue   => l_hierarchy_id);

         /* =============== START DEBUG LOG ================ */
            DEBUG_LOG_STRING (l_proc_level, 'getparentposition.Msg12',
                              ' l_hierarchy_id -- POS_STRUCTURE_ID --> ' || l_hierarchy_id );
         /* =============== END DEBUG LOG ================== */

         -- Get the Position Hierarchy Version
         BEGIN

            /* =============== START DEBUG LOG ================ */
               DEBUG_LOG_STRING (l_proc_level, 'getparentposition.Msg13',
                                 ' Getting Position Hierarchy Version ');
            /* =============== END DEBUG LOG ================== */

            OPEN  c_pos_hier_ver(l_hierarchy_id,
                                 l_business_group_id);
            FETCH c_pos_hier_ver INTO l_hierarchy_version_id;
            CLOSE c_pos_hier_ver;

         EXCEPTION
            WHEN OTHERS THEN
               FND_MESSAGE.SET_NAME('IGI','IGI_DOS_WKF_NO_HIER_VER');
               FND_MESSAGE.SET_TOKEN('HIERARCHY_ID',l_hierarchy_id);
               FND_MESSAGE.SET_TOKEN('BUS_GRP_ID',l_business_group_id);
               /* =============== START DEBUG LOG ================ */
                  DEBUG_LOG_UNEXP_ERROR ('getparentposition.Unexp4','USER');
               /* =============== END DEBUG LOG ================== */
               RAISE pos_hier_ver_not_found;
         END;

         Wf_Engine.SetItemAttrText (itemtype => ItemType,
                                    itemkey  => ItemKey,
                                    aname    => 'POS_STRUCTURE_VERSION_ID',
                                    avalue   => l_hierarchy_version_id);

         /* =============== START DEBUG LOG ================ */
            DEBUG_LOG_STRING (l_proc_level, 'getparentposition.Msg14',
                              ' l_hierarchy_version_id -- POS_STRUCTURE_VERSION_ID --> '
                              || l_hierarchy_version_id );
         /* =============== END DEBUG LOG ================== */


        -- Get the Top Position in the hierarchy
        BEGIN

            /* =============== START DEBUG LOG ================ */
               DEBUG_LOG_STRING (l_proc_level, 'getparentposition.Msg15',
                                 ' Get the Top Position in the hierarchy ');
            /* =============== END DEBUG LOG ================== */

            OPEN  c_get_top_position(l_hierarchy_version_id,
                                     l_business_group_id);
            FETCH c_get_top_position INTO l_top_position_id;
            CLOSE c_get_top_position;

         EXCEPTION
            WHEN OTHERS THEN
               FND_MESSAGE.SET_NAME('IGI','IGI_DOS_WKF_NO_HIER_TOP');
               FND_MESSAGE.SET_TOKEN('HIER_VER_ID',l_hierarchy_version_id);
               FND_MESSAGE.SET_TOKEN('BUS_GRP_ID',l_business_group_id);
               /* =============== START DEBUG LOG ================ */
                  DEBUG_LOG_UNEXP_ERROR ('getparentposition.Unexp5','USER');
               /* =============== END DEBUG LOG ================== */
               RAISE top_pos_not_found;
         END;

         Wf_Engine.SetItemAttrText (itemtype => ItemType,
                                    itemkey  => ItemKey,
                                    aname    => 'TOP_POSITION_ID',
                                    avalue   => l_top_position_id);

         /* =============== START DEBUG LOG ================ */
            DEBUG_LOG_STRING (l_proc_level, 'getparentposition.Msg16',
                              ' l_top_position_id -- TOP_POSITION_ID --> '
                              || l_top_position_id );
         /* =============== END DEBUG LOG ================== */

         IF l_position_id = l_top_position_id THEN
         -- Save the current position as the parent position so that the
         -- notification for approval gets sent to the top level.

            /* =============== START DEBUG LOG ================ */
               DEBUG_LOG_STRING (l_proc_level, 'getparentposition.Msg17',
                                 ' l_position_id --> ' || l_position_id || ' = ' ||
                                 ' l_top_position_id --> ' || l_top_position_id );
            /* =============== END DEBUG LOG ================== */

            Wf_Engine.SetItemAttrText (itemtype => ItemType,
                                       itemkey  => ItemKey,
                                       aname    => 'PARENT_POSITION_ID',
                                       avalue   => l_position_id);

            /* =============== START DEBUG LOG ================ */
               DEBUG_LOG_STRING (l_proc_level, 'getparentposition.Msg18',
                                 ' l_position_id -- PARENT_POSITION_ID --> ' || l_position_id);
            /* =============== END DEBUG LOG ================== */

         ELSE -- creator is not at the top

            /* =============== START DEBUG LOG ================ */
               DEBUG_LOG_STRING (l_proc_level, 'getparentposition.Msg19',
                                 ' creator is not at the top ' );
            /* =============== END DEBUG LOG ================== */

            -- Get the parent for the current position
            BEGIN

               /* =============== START DEBUG LOG ================ */
                  DEBUG_LOG_STRING (l_proc_level, 'getparentposition.Msg20',
                                   ' Get the parent for the current position ' );
               /* =============== END DEBUG LOG ================== */

               OPEN  c_par_pos_id(l_hierarchy_version_id,
                                  l_position_id,
                                  l_business_group_id);
               FETCH c_par_pos_id INTO l_parent_position_id;
               CLOSE c_par_pos_id;

            EXCEPTION
               WHEN OTHERS THEN
                  FND_MESSAGE.SET_NAME('IGI','IGI_DOS_WKF_NO_PARENT_POS');
                  FND_MESSAGE.SET_TOKEN('HIERARCHY_ID',l_hierarchy_id);
                  FND_MESSAGE.SET_TOKEN('BUS_GRP_ID',l_business_group_id);
                  FND_MESSAGE.SET_TOKEN('POSITION_ID',l_position_id);
                  /* =============== START DEBUG LOG ================ */
                     DEBUG_LOG_UNEXP_ERROR ('getparentposition.Unexp6','USER');
                  /* =============== END DEBUG LOG ================== */
                  RAISE par_pos_not_found;
            END;

            Wf_Engine.SetItemAttrText (itemtype => ItemType,
                                       itemkey  => ItemKey,
                                       aname    => 'PARENT_POSITION_ID',
                                       avalue   => l_parent_position_id);

            /* =============== START DEBUG LOG ================ */
               DEBUG_LOG_STRING (l_proc_level, 'getparentposition.Msg21',
                                 ' l_parent_position_id -- PARENT_POSITION_ID --> '
                                 || TO_CHAR(l_parent_position_id));
            /* =============== END DEBUG LOG ================== */

         END IF;

         result := 'COMPLETE:HAS_PARENT';

         /* =============== START DEBUG LOG ================ */
            DEBUG_LOG_STRING (l_proc_level, 'getparentposition.Msg22',
                              ' result --> ' || result);
         /* =============== END DEBUG LOG ================== */

         -- Flip the initial entry flag as subsequent entries will not be initial
         l_initial_entry := 'FALSE';
         Wf_Engine.SetItemAttrText (itemtype => itemtype,
                                    itemkey  => itemkey,
                                    aname    => 'INITIAL_ENTRY_FLAG',
                                    avalue   => l_initial_entry);

         /* =============== START DEBUG LOG ================ */
            DEBUG_LOG_STRING (l_proc_level, 'getparentposition.Msg23',
                              ' l_initial_entry - INITIAL_ENTRY_FLAG ' || l_initial_entry);
         /* =============== END DEBUG LOG ================== */

      ELSE -- This is not the initial entry

         /* =============== START DEBUG LOG ================ */
            DEBUG_LOG_STRING (l_proc_level, 'getparentposition.Msg24',
                              ' Not initial entry INTO GetParentPosition ');
         /* =============== END DEBUG LOG ================== */

         -- FETCH the parent position id as the current position id
         l_position_id := Wf_Engine.GetItemAttrText (itemtype => ItemType,
                                                     itemkey  => ItemKey,
                                                     aname    => 'PARENT_POSITION_ID');

         /* =============== START DEBUG LOG ================ */
            DEBUG_LOG_STRING (l_proc_level, 'getparentposition.Msg25',
                              ' GetItemAttrText PARENT_POSITION_ID --> ' || l_position_id);
         /* =============== END DEBUG LOG ================== */


         l_top_position_id := Wf_Engine.GetItemAttrText (itemtype => ItemType,
                                                         itemkey  => ItemKey,
                                                         aname    => 'TOP_POSITION_ID');

         /* =============== START DEBUG LOG ================ */
            DEBUG_LOG_STRING (l_proc_level, 'getparentposition.Msg26',
                              ' GetItemAttrText TOP_POSITION_ID --> ' || l_top_position_id );
         /* =============== END DEBUG LOG ================== */

         IF l_top_position_id = l_position_id THEN
            result := 'COMPLETE:NO_HIERS' ;
            /* =============== START DEBUG LOG ================ */
               DEBUG_LOG_STRING (l_proc_level, 'getparentposition.Msg27',
                                 ' l_top_position_id --> ' || l_top_position_id
                                 || ' = ' ||
                                 ' l_position_id --> ' || l_position_id ||
                                 ' result --> ' || result);
            /* =============== END DEBUG LOG ================== */

         ELSE -- top != current

            /* =============== START DEBUG LOG ================ */
               DEBUG_LOG_STRING (l_proc_level, 'getparentposition.Msg28',
                                 ' l_top_position_id --> ' || l_top_position_id
                                  || ' != ' ||
                                 ' l_position_id --> ' || l_position_id);
            /* =============== END DEBUG LOG ================== */

            l_hierarchy_version_id :=
                 Wf_Engine.GetItemAttrNumber ( itemtype =>  ItemType,
                                               itemkey  =>  ItemKey,
                                               aname    =>  'POS_STRUCTURE_VERSION_ID');

            /* =============== START DEBUG LOG ================ */
               DEBUG_LOG_STRING (l_proc_level, 'getparentposition.Msg29',
                                 ' GetItemAttrNumber - POS_STRUCTURE_VERSION_ID --> ' || TO_CHAR(l_hierarchy_version_id));
            /* =============== END DEBUG LOG ================== */

            l_business_group_id :=
                 Wf_Engine.GetItemAttrNumber ( itemtype =>  ItemType,
                                               itemkey  =>  ItemKey,
                                               aname    =>  'BUSINESS_GROUP_ID');

            /* =============== START DEBUG LOG ================ */
               DEBUG_LOG_STRING (l_proc_level, 'getparentposition.Msg29',
                                 ' GetItemAttrNumber - BUSINESS_GROUP_ID --> ' || TO_CHAR(l_business_group_id));
            /* =============== END DEBUG LOG ================== */

            -- Get parent position
            BEGIN

               /* =============== START DEBUG LOG ================ */
                  DEBUG_LOG_STRING (l_proc_level, 'getparentposition.Msg30',
                                    ' Get parent position ');
               /* =============== END DEBUG LOG ================== */

               OPEN  c_par_pos_id(l_hierarchy_version_id,
                                  l_position_id,
                                  l_business_group_id);
               FETCH c_par_pos_id INTO l_parent_position_id;
               CLOSE c_par_pos_id;

            EXCEPTION
               WHEN OTHERS THEN
                 /* =============== START DEBUG LOG ================ */
                    DEBUG_LOG_UNEXP_ERROR ('getparentposition.unexp7','DEFAULT');
                 /* =============== END DEBUG LOG ================== */
                 RAISE par_pos_not_found;
            END;

            Wf_Engine.SetItemAttrText (itemtype => ItemType,
                                       itemkey  => ItemKey,
                                       aname    => 'PARENT_POSITION_ID',
                                       avalue   => l_parent_position_id);

            /* =============== START DEBUG LOG ================ */
               DEBUG_LOG_STRING (l_proc_level, 'getparentposition.Msg31',
                                 ' l_parent_position_id - PARENT_POSITION_ID --> ' || TO_CHAR(l_parent_position_id));
            /* =============== END DEBUG LOG ================== */

            l_current_user_name :=
            Wf_Engine.GetItemAttrText (itemtype => ItemType,
                                         itemkey  => ItemKey,
                                         aname    => 'SELECTED_USER_NAME');

            /* =============== START DEBUG LOG ================ */
               DEBUG_LOG_STRING (l_proc_level, 'getparentposition.Msg32',
                                 ' GetItemAttrText SELECTED_USER_NAME --> ' || l_current_user_name);
            /* =============== END DEBUG LOG ================== */

            Wf_Engine.SetItemAttrText (itemtype => ItemType,
                                       itemkey  => ItemKey,
                                       aname    => 'CURRENT_USER_NAME',
                                       avalue   => l_current_user_name);

            /* =============== START DEBUG LOG ================ */
               DEBUG_LOG_STRING (l_proc_level, 'getparentposition.Msg33',
                                 ' l_current_user_name - CURRENT_USER_NAME ' || l_current_user_name);
            /* =============== END DEBUG LOG ================== */

            result := 'COMPLETE:HAS_PARENT';

            /* =============== START DEBUG LOG ================ */
               DEBUG_LOG_STRING (l_proc_level, 'getparentposition.Msg34',
                                 ' result --> ' || result);
            /* =============== END DEBUG LOG ================== */

         END IF; -- top = current

      END IF; -- initial entry

     /* =============== START DEBUG LOG ================ */
         DEBUG_LOG_STRING (l_proc_level, 'getparentposition.Msg35',
                           ' ** END GETPARENTPOSITION ** ');
     /* =============== END DEBUG LOG ================== */

    EXCEPTION
       WHEN cur_pos_not_found      OR
            pos_hier_not_found     OR
            pos_hier_ver_not_found OR
            top_pos_not_found      OR
            par_pos_not_found      THEN

          /* =============== START DEBUG LOG ================ */
             DEBUG_LOG_STRING (l_proc_level, 'getparentposition.Msg36',
                               ' #### Into User defined EXCEPTION ');
          /* =============== END DEBUG LOG ================== */

          Wf_Core.Context ('IGIDOSL', 'GetParentPosition', itemtype, itemkey,
                           TO_CHAR(actid),funcmode,
                           'Creator='||l_creator_name
                           ||'  Initflag='||l_initial_entry
                           ||'  error= '||l_error);

          IF c_cur_pos%ISOPEN THEN
             CLOSE c_cur_pos;
          END IF ;
          IF c_pos_hier%ISOPEN THEN
             CLOSE c_pos_hier;
          END IF ;
          IF c_pos_hier_ver%ISOPEN THEN
             CLOSE c_pos_hier_ver;
          END IF ;
          IF c_get_top_position%ISOPEN THEN
             CLOSE c_get_top_position;
          END IF ;
          IF c_par_pos_id%ISOPEN THEN
             CLOSE c_par_pos_id;
          END IF ;

          RAISE;

       WHEN OTHERS THEN
        /* =============== START DEBUG LOG ================ */
           DEBUG_LOG_UNEXP_ERROR ('getparentposition.unexp1','DEFAULT');
        /* =============== END DEBUG LOG ================== */

          result := NULL;
          Wf_Core.Context ('IGIDOSL', 'GetParentPosition', itemtype, itemkey,
                           TO_CHAR(actid),funcmode);

          IF c_cur_pos%ISOPEN THEN
             CLOSE c_cur_pos;
          END IF ;
          IF c_pos_hier%ISOPEN THEN
             CLOSE c_pos_hier;
          END IF ;
          IF c_pos_hier_ver%ISOPEN THEN
             CLOSE c_pos_hier_ver;
          END IF ;
          IF c_get_top_position%ISOPEN THEN
            CLOSE c_get_top_position;
          END IF ;
          IF c_par_pos_id%ISOPEN THEN
             CLOSE c_par_pos_id;
          END IF ;

          RAISE;

    END GetParentPosition;

    /* ====================== APPROVE ========================= */

    PROCEDURE Approve ( itemtype     VARCHAR2,
                        itemkey      VARCHAR2,
                        actid        NUMBER,
                        funcmode     VARCHAR2,
                        result   OUT NOCOPY VARCHAR2)
    IS
       l_trx_status VARCHAR2(30);
       l_sob_id     NUMBER;
	   --bug 9128478
	   l_fatal_error VARCHAR2(100);

       l_dossier_num VARCHAR2(255)
          := Wf_Engine.GetItemAttrText   ( itemtype =>  itemtype,
                                           itemkey  =>  itemkey,
                                           aname    =>  'DOSSIER_NUM');

       l_user_id VARCHAR2(30) -- Changed FROM NUM to TEXT by bug 1635667
          := Wf_Engine.GetItemAttrText( itemtype => itemtype,
                                        itemkey  => itemkey,
                                        aname    => 'USER_ID');

       l_responsibility_id VARCHAR2(30) -- Changed FROM NUM to TEXT by bug 1635667
          := Wf_Engine.GetItemAttrText( itemtype => itemtype,
                                        itemkey  => itemkey,
                                        aname    => 'RESPONSIBILITY_ID');
       encumbrance_error EXCEPTION;

       CURSOR get_status
       IS
          SELECT meaning
          FROM igi_lookups
          WHERE lookup_type ='DOSSIER STATUS'
          AND   lookup_code ='COMPLETE';

    BEGIN
        l_fatal_error := null;
       /* =============== START DEBUG LOG ================ */
          DEBUG_LOG_STRING (l_proc_level, 'approve.Msg1',
                            ' ** START APPROVE ** ');
       /* =============== END DEBUG LOG ================== */

       IF funcmode <> 'RUN' THEN

          /* =============== START DEBUG LOG ================ */
             DEBUG_LOG_STRING (l_proc_level, 'approve.Msg2',
                               ' funcmode <> RUN result COMPLETE');
          /* =============== END DEBUG LOG ================== */

          result := 'COMPLETE:T';
          return;
       END IF;

       -- WHEN the dossier has passed through the validation loop and
       -- been successfully authorised set the status to Complete.
       OPEN get_status;
       FETCH get_status INTO l_trx_status;
       CLOSE get_status;

       /* =============== START DEBUG LOG ================ */
          DEBUG_LOG_STRING (l_proc_level, 'approve.Msg3',
                            ' l_trx_status --> ' || l_trx_status);
       /* =============== END DEBUG LOG ================== */

       SELECT dtype.sob_id
       INTO   l_sob_id
       FROM   igi_dos_doc_types   dtype,
              igi_dos_trx_headers thead
       WHERE  thead.dossier_id = dtype.dossier_id
       AND    thead.trx_number = l_dossier_num;

       /* =============== START DEBUG LOG ================ */
          DEBUG_LOG_STRING (l_proc_level, 'approve.Msg3',
                            ' l_sob_id --> ' || l_sob_id);
          DEBUG_LOG_STRING (l_proc_level, 'approve.Msg4',
                            ' Calling igi_dis_funds.approve with ' ||
                            ' l_dossier_num --> ' || l_dossier_num ||
                            ' l_user_id --> ' || l_user_id ||
                            ' l_responsibility_id --> ' || l_responsibility_id ||
                            ' l_sob_id --> ' || l_sob_id);
       /* =============== END DEBUG LOG ================== */

       IF igi_dos_funds.approve(l_dossier_num, l_user_id, l_responsibility_id, l_sob_id)
       THEN

          UPDATE igi_dos_trx_headers trx
          SET    trx.trx_status = l_trx_status,
                 trx.last_update_date= sysdate
          WHERE  trx.trx_number = l_dossier_num;
          result := 'COMPLETE:T';
          Wf_Engine.SetItemAttrText (itemtype =>  Itemtype,
                                itemkey  =>  Itemkey,
                                aname    =>  'FATAL_ERROR',
                                avalue   =>  l_fatal_error);
           /* =============== START DEBUG LOG ================ */
             DEBUG_LOG_STRING (l_proc_level, 'approve.Msg4.1',
                               ' Setting Fatal Error to null ');
          /* =============== END DEBUG LOG ================== */
          /* =============== START DEBUG LOG ================ */
             DEBUG_LOG_STRING (l_proc_level, 'approve.Msg5',
                               ' updating igi_dos_trx_headers ');
          /* =============== END DEBUG LOG ================== */

       ELSE
       --bug 9128478
	    BEGIN
        SELECT message_text
		INTO l_fatal_error
		FROM fnd_new_messages
        WHERE message_name = 'IGI_DOS_ERROR_APPROVED';
		EXCEPTION
		    WHEN OTHERS THEN
			  l_fatal_error := '.This Dossier could not be approved earlier due to encumbrance error.';
		END;
         Wf_Engine.SetItemAttrText (itemtype =>  Itemtype,
                                itemkey  =>  Itemkey,
                                aname    =>  'FATAL_ERROR',
                                avalue   =>  l_fatal_error);
          /* =============== START DEBUG LOG ================ */
             DEBUG_LOG_STRING (l_proc_level, 'approve.Msg5.1',
                               'Setting the Fatal Error Attribute');
          /* =============== END DEBUG LOG ================== */
         result := 'COMPLETE:F';
         --RAISE encumbrance_error;
       END IF;



       /* =============== START DEBUG LOG ================ */
          DEBUG_LOG_STRING (l_proc_level, 'approve.Msg7',
                            ' result --> ' || result);
          DEBUG_LOG_STRING (l_proc_level, 'approve.Msg8',
                            ' ** END APPROVE ** ');
       /* =============== END DEBUG LOG ================== */

    EXCEPTION
    --bug 9128478
      /* WHEN encumbrance_error THEN
             FND_MESSAGE.SET_NAME('IGI','IGI_DOS_WKF_ENCMBRC_ERROR');
             FND_MESSAGE.SET_TOKEN('DOSSIER_NUM',l_dossier_num);
             FND_MESSAGE.SET_TOKEN('USER_ID',l_user_id);
             FND_MESSAGE.SET_TOKEN('RESP_ID',l_responsibility_id);
             FND_MESSAGE.SET_TOKEN('SOB_ID',l_sob_id);
             /* =============== START DEBUG LOG ================ */
              --  DEBUG_LOG_UNEXP_ERROR ('approve.unexp1','USER');
             /* =============== END DEBUG LOG ================== */

         /*    result := NULL;
             Wf_Core.Context ('IGIDOSL', 'Reverse Encumbrances -Unable to create encumbrances for specified packet'
                           , itemtype, itemkey , to_char(actid),funcmode
                           , 'Dossier Trx Num ='||itemkey ) ;
             RAISE ;*/

       WHEN OTHERS THEN
             /* =============== START DEBUG LOG ================ */
                DEBUG_LOG_UNEXP_ERROR ('approve.unexp2','DEFAULT');
             /* =============== END DEBUG LOG ================== */

             result := NULL;
             Wf_Core.Context ('IGIDOSL', 'Approve', itemtype, itemkey , TO_CHAR(actid),funcmode) ;
             RAISE;

    END Approve ;

  /* ======================= REJECT ============================== */

 PROCEDURE Reject ( itemtype   VARCHAR2,
                     itemkey    VARCHAR2,
                     actid      NUMBER,
                     funcmode   VARCHAR2,
                     result OUT NOCOPY VARCHAR2)
 IS
    l_trx_status VARCHAR2(80);

    l_dossier_id VARCHAR2(255)
    := Wf_Engine.GetItemAttrText   ( itemtype =>  itemtype,
                                     itemkey  =>  itemkey,
                                     aname    =>  'DOSSIER_NUM');

    l_creator_name wf_notifications.responder%TYPE
    := Wf_Engine.GetItemAttrText ( itemtype =>  itemtype,
                                   itemkey  =>  itemkey,
                                   aname    =>  'CREATOR_NAME');
 BEGIN


    /* =============== START DEBUG LOG ================ */
       DEBUG_LOG_STRING (l_proc_level, 'reject.Msg1',
                         ' ** START REJECT ** ');
    /* =============== END DEBUG LOG ================== */

    IF funcmode <> 'RUN' THEN

       /* =============== START DEBUG LOG ================ */
          DEBUG_LOG_STRING (l_proc_level, 'reject.Msg2',
                            ' funcmode <> RUN result COMPLETE');
       /* =============== END DEBUG LOG ================== */
       result := 'COMPLETE';
       return;
    END IF;


    SELECT meaning INTO l_trx_status
    FROM  igi_lookups
    WHERE lookup_type ='DOSSIER STATUS'
    and   lookup_code ='REJECTED';

    /* =============== START DEBUG LOG ================ */
       DEBUG_LOG_STRING (l_proc_level, 'reject.Msg3',
                         ' l_trx_status --> ' || l_trx_status);
    /* =============== END DEBUG LOG ================== */

    UPDATE IGI_DOS_TRX_HEADERS trx
    SET    trx.trx_status       = l_trx_status,
           trx.last_update_date= sysdate
    WHERE  trx.trx_number      = l_dossier_id;

    /* =============== START DEBUG LOG ================ */
       DEBUG_LOG_STRING (l_proc_level, 'reject.Msg4',
                         ' updating igi_dos_trx_headers ');
    /* =============== END DEBUG LOG ================== */

    result := 'COMPLETE' ;

    /* =============== START DEBUG LOG ================ */
       DEBUG_LOG_STRING (l_proc_level, 'reject.Msg5',
                         ' result --> ' || result);
       DEBUG_LOG_STRING (l_proc_level, 'reject.Msg6',
                         ' ** END REJECT ** ');
    /* =============== END DEBUG LOG ================== */

 EXCEPTION
     WHEN OTHERS THEN
       /* =============== START DEBUG LOG ================ */
          DEBUG_LOG_UNEXP_ERROR ('reject.unexp1','USER');
       /* =============== END DEBUG LOG ================== */
       result := NULL;
       Wf_Core.Context ('IGIDOSL', 'Reject', itemtype, itemkey
                          , to_char(actid),funcmode) ;
       RAISE;
 END Reject;

  /* ==================== SENDAPPROVED ======================= */

  PROCEDURE SendApproved ( itemtype  IN VARCHAR2,
                           itemkey   IN VARCHAR2,
                           actid     IN NUMBER,
                           funcmode  IN VARCHAR2,
                           result   OUT NOCOPY VARCHAR2)
  IS

    l_creator_name wf_notifications.responder%TYPE
    := Wf_Engine.GetItemAttrText ( itemtype =>  itemtype,
                                   itemkey  =>  itemkey,
                                   aname    =>  'CREATOR_NAME');

    l_nid                 NUMBER ;
    unable_to_send_notify EXCEPTION ;

  BEGIN
      -- This procedure sends a notification to the creator of the dossier
      -- every time a dossier is approved.
      -- This had to be done within a procedure because it was not possible
      -- to send a notification activity WHEN it was within a workflow loop
      -- (as the last activity in the loop). This was due to the way workflow
      -- resets the loop the last activity gets cancelled-see #bug 937429.

    /* =============== START DEBUG LOG ================ */
       DEBUG_LOG_STRING (l_proc_level, 'SendApproved.Msg1',
                         ' ** START SENDAPPROVED ** ');
    /* =============== END DEBUG LOG ================== */


    IF funcmode <> 'RUN' THEN
       /* =============== START DEBUG LOG ================ */
          DEBUG_LOG_STRING (l_proc_level, 'SendApproved.Msg2',
                            ' funcmode <> RUN result COMPLETE');
       /* =============== END DEBUG LOG ================== */
        result := 'COMPLETE' ;
        return;
    END IF ;

    l_nid := Wf_Notification.Send(
                                    l_creator_name
                                   , itemtype
                                   ,'ALL_APPROVED'
                                   , null
                                   , 'WF_ENGINE.CB'
                                   , itemtype||':'||itemkey||':'||to_char(actid)
                                   ,'Send The Dossier Approved Message To The Creator.'
                                   , null
                                   )  ;

    /* =============== START DEBUG LOG ================ */
       DEBUG_LOG_STRING (l_proc_level, 'SendApproved.Msg3',
                         ' Notification sent ');
    /* =============== END DEBUG LOG ================== */

      IF l_nid = 0 OR l_nid < 0 THEN
         /* =============== START DEBUG LOG ================ */
            DEBUG_LOG_STRING (l_proc_level, 'SendApproved.Msg4',
                              ' raising unable_to_send_notify');
         /* =============== END DEBUG LOG ================== */
         RAISE unable_to_send_notify ;
      END IF ;

      result := 'COMPLETE' ;

    /* =============== START DEBUG LOG ================ */
       DEBUG_LOG_STRING (l_proc_level, 'SendApproved.Msg4',
                         ' result --> ' || result);
       DEBUG_LOG_STRING (l_proc_level, 'SendApproved.Msg5',
                         ' ** END SENDAPPROVED ** ');
    /* =============== END DEBUG LOG ================== */


  EXCEPTION
    WHEN unable_to_send_notify THEN
           FND_MESSAGE.SET_NAME('IGI','IGI_DOS_WKF_FAIL_SEND_NOTC');
           FND_MESSAGE.SET_TOKEN('NOTICE_ID',l_nid);
           /* =============== START DEBUG LOG ================ */
              DEBUG_LOG_UNEXP_ERROR ('SendApproved.Unexp1','USER');
           /* =============== END DEBUG LOG ================== */
           result := NULL;
           Wf_Core.Context ( 'IGIDOSL','SendApproved', itemtype, itemkey
                             , to_char(actid),funcmode
                             ,'Failed to Send Dossier Approved Notice- Notice Id:'||to_char(l_nid)) ;
           RAISE ;

    WHEN OTHERS THEN
           /* =============== START DEBUG LOG ================ */
              DEBUG_LOG_UNEXP_ERROR ('SendApproved.Unexp2','DEFAULT');
           /* =============== END DEBUG LOG ================== */
           result := NULL;
           Wf_Core.Context ( 'IGIDOSL','SendApproved', itemtype, itemkey
                             , to_char(actid),funcmode) ;
           RAISE ;

  END SendApproved ;

  /* ===================== SENDREJECTED ======================== */

  PROCEDURE SendRejected ( itemtype  IN VARCHAR2,
                           itemkey   IN VARCHAR2,
                           actid     IN NUMBER,
                           funcmode  IN VARCHAR2,
                           result   OUT NOCOPY VARCHAR2)
  IS

    l_creator_name wf_notifications.responder%TYPE
    := Wf_Engine.GetItemAttrText ( itemtype =>  itemtype,
                                   itemkey  =>  itemkey,
                                   aname    =>  'CREATOR_NAME');

    l_nid                 NUMBER ;
    unable_to_send_notify EXCEPTION ;

  BEGIN

      -- This procedure sends a notification to the creator of the dossier
      -- time a dossier is rejected.
      -- This had to be done within a procedure because it was not possible
      -- to send a notification activity WHEN it was within a workflow loop
      -- (as the last activity in the loop). This was due to the way workflow
      -- resets the loop the last activity gets cancelled-see #bug 937429.

    /* =============== START DEBUG LOG ================ */
       DEBUG_LOG_STRING (l_proc_level, 'SendRejected.Msg1',
                         ' ** START SENDREJECTED ** ');
    /* =============== END DEBUG LOG ================== */


    IF funcmode <> 'RUN' THEN
       /* =============== START DEBUG LOG ================ */
          DEBUG_LOG_STRING (l_proc_level, 'SendRejected.Msg2',
                            ' funcmode <> RUN result COMPLETE');
       /* =============== END DEBUG LOG ================== */
        result := 'COMPLETE' ;
        return;
    END IF ;
-- start Commented for bug 9104180
/*
      l_nid := Wf_Notification.Send(
                                     l_creator_name
                                   , itemtype
                                   ,'AUTHORISER_REJECTION'
                                   , null
                                   , 'WF_ENGINE.CB'
                                   , itemtype||':'||itemkey||':'||to_char(actid)
                                   ,'Send The Dossier Rejection Message To The Creator.'
                                   , null
                                   )  ;
*/

    /* =============== START DEBUG LOG ================ */
     --  DEBUG_LOG_STRING (l_proc_level, 'SendRejected.Msg3',
      --                   ' Notification sent ');
    /* =============== END DEBUG LOG ================== */

  --    IF l_nid = 0 OR l_nid < 0 THEN
         /* =============== START DEBUG LOG ================ */
    --        DEBUG_LOG_STRING (l_proc_level, 'SendRejected.Msg4',
     --                         ' raising unable_to_send_notify');
         /* =============== END DEBUG LOG ================== */
     --    RAISE unable_to_send_notify ;
  --    END IF ;
-- end Commented for bug 9104180

      result := 'COMPLETE' ;

    /* =============== START DEBUG LOG ================ */
       DEBUG_LOG_STRING (l_proc_level, 'SendRejected.Msg4',
                         ' result --> ' || result);
       DEBUG_LOG_STRING (l_proc_level, 'SendRejected.Msg5',
                         ' ** END SENDREJECTED ** ');
    /* =============== END DEBUG LOG ================== */


  EXCEPTION
--start commented for bug 9104180
 --   WHEN unable_to_send_notify THEN
 --         FND_MESSAGE.SET_NAME('IGI','IGI_DOS_WKF_FAIL_SEND_NOTC');
 --         FND_MESSAGE.SET_TOKEN('NOTICE_ID',l_nid);
           /* =============== START DEBUG LOG ================ */
  --            DEBUG_LOG_UNEXP_ERROR ('SendRejected.Unexp1','USER');
           /* =============== END DEBUG LOG ================== */
  --         Wf_Core.Context ('IGIDOSL','SendRejected', itemtype, itemkey
  --                          , to_char(actid),funcmode, 'Failed to Send Dossier Reject Notice- Notice Id:'||to_char(l_nid)) ;
  --         RAISE ;
-- end commented for bug 9104180

    WHEN OTHERS THEN
         /* =============== START DEBUG LOG ================ */
            DEBUG_LOG_UNEXP_ERROR ('SendRejected.Unexp2','DEFAULT');
         /* =============== END DEBUG LOG ================== */
         result := NULL;
         Wf_Core.Context ('IGIDOSL','SendRejected', itemtype, itemkey
                          , to_char(actid),funcmode) ;
         RAISE ;

  END SendRejected ;

  /* ======================= CREATELIST ====================== */

  PROCEDURE CreateList ( itemtype   VARCHAR2,
                         itemkey    VARCHAR2,
                         actid      NUMBER,
                         funcmode   VARCHAR2,
                         result OUT NOCOPY VARCHAR2)
   IS
     l_user_count   NUMBER := 0;
     l_local_table  Wf_Directory.Usertable;
     l_size         NUMBER;
     l_list         VARCHAR2(1000) := 'ALL';

     l_user_name fnd_user.user_name%TYPE;

     l_next_position per_positions.name%TYPE
     := Wf_Engine.GetItemAttrText( itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'NEXT_POSITION');

     l_parent_position_id per_positions.position_id%TYPE
      :=  Wf_Engine.GetItemAttrText (itemtype => ItemType,
                                   itemkey  => ItemKey,
                                   aname    => 'PARENT_POSITION_ID');

     l_business_group_id       hr_all_positions_f.business_group_id%TYPE
     := Wf_Engine.GetItemAttrText( itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'BUSINESS_GROUP_ID');

     l_organization_id         hr_all_positions_f.organization_id%TYPE
     := Wf_Engine.GetItemAttrText( itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'ORGANIZATION_ID');

      CURSOR c_user_list
      IS
         select fu.user_name user_name
         FROM   hr_all_positions_f      hap,
                per_all_assignments_f   paa,
	        fnd_user                fu ,
                per_people_f p,
                per_periods_of_service b
         WHERE
                paa.person_id = p.person_id
         AND    paa.primary_flag = 'Y'
         AND    paa.period_of_service_id = b.period_of_service_id
         AND    TRUNC(SYSDATE) BETWEEN p.effective_start_date AND p.effective_end_date
         AND    TRUNC(SYSDATE) BETWEEN paa.effective_start_date AND paa.effective_end_date
         AND   (b.actual_termination_date >= trunc(sysdate) or b.actual_termination_date is null)
         AND    p.employee_number IS NOT NULL
         and    fu.start_date <= SYSDATE
         and    NVL(fu.end_date,SYSDATE) >= SYSDATE
         and    fu.employee_id IS NOT NULL
         and    fu.employee_id = p.person_id
         and    p.business_group_id = paa.business_group_id
         and    p.business_group_id = l_business_group_id
         and    paa.organization_id = l_organization_id
         and    paa.assignment_type = 'E'
         and    paa.business_group_id = hap.business_group_id
         and    paa.position_id IS NOT NULL
         and    paa.position_id = hap.position_id
         and    paa.organization_id = hap.organization_id
         and    hap.date_effective <= SYSDATE
         and    NVL(hap.date_end, SYSDATE) >= SYSDATE
         and    NVL(UPPER(hap.status), 'VALID') NOT IN ('INVALID')
         and    hap.position_id = l_parent_position_id;



    e_user_list_not_found EXCEPTION;

  BEGIN

    /* =============== START DEBUG LOG ================ */
       DEBUG_LOG_STRING (l_proc_level, 'CreateList.Msg1',
                         ' ** START CREATELIST ** ');
    /* =============== END DEBUG LOG ================== */

     IF funcmode <> 'RUN' THEN
       /* =============== START DEBUG LOG ================ */
          DEBUG_LOG_STRING (l_proc_level, 'CreateList.Msg2',
                            ' funcmode <> RUN result COMPLETE');
       /* =============== END DEBUG LOG ================== */
       result := 'COMPLETE';
       return;
     END IF;

     /* =============== START DEBUG LOG ================ */
        DEBUG_LOG_STRING (l_proc_level, 'CreateList.Msg3',
                          ' FETCH the users for the position ');
     /* =============== END DEBUG LOG ================== */

     -- FETCH the users for the position
     BEGIN

        FOR I IN c_user_list
        LOOP
           l_user_count := l_user_count + 1;
           l_list       := l_list || fnd_global.local_chr(10) || I.user_name;
           l_user_name  := I.user_name;

           /* =============== START DEBUG LOG ================ */
              DEBUG_LOG_STRING (l_proc_level, 'CreateList.Msg4',
                                ' user_name --> ' || I.user_name);
           /* =============== END DEBUG LOG ================== */

        END LOOP;

     /* =============== START DEBUG LOG ================ */
        DEBUG_LOG_STRING (l_proc_level, 'CreateList.Msg4',
                          ' out of loop  ');
     /* =============== END DEBUG LOG ================== */

        IF l_user_count = 1 THEN
           /* =============== START DEBUG LOG ================ */
              DEBUG_LOG_STRING (l_proc_level, 'CreateList.Msg5',
                                ' One user exists --> ' || l_user_name);
           /* =============== END DEBUG LOG ================== */
           l_list := l_user_name;
        END IF;

     EXCEPTION
        WHEN OTHERS THEN
         /* =============== START DEBUG LOG ================ */
            DEBUG_LOG_UNEXP_ERROR ('CreateList.Unexp1','DEFAULT');
         /* =============== END DEBUG LOG ================== */
         RAISE e_user_list_not_found;
     END;

     Wf_Engine.SetItemAttrText (itemtype =>  Itemtype,
                                itemkey  =>  Itemkey,
                                aname    =>  'USER_LIST',
                                avalue   =>  l_list);

     /* =============== START DEBUG LOG ================ */
        DEBUG_LOG_STRING (l_proc_level, 'CreateList.Msg6',
                          ' l_list - USER_LIST --> ' || l_list);
     /* =============== END DEBUG LOG ================== */

     IF l_user_count = 1 THEN
       result := 'COMPLETE:N' ;
     ELSE
        result := 'COMPLETE:Y' ;
     END IF;

     /* =============== START DEBUG LOG ================ */
        DEBUG_LOG_STRING (l_proc_level, 'CreateList.Msg7',
                          ' result --> ' || result);
     /* =============== END DEBUG LOG ================== */

     Wf_Engine.SetItemAttrText ( itemtype =>  Itemtype,
                                 itemkey  =>  Itemkey,
                                 aname    =>  'PICKED_ROLE',
                                 avalue   =>  l_list) ;

     /* =============== START DEBUG LOG ================ */
        DEBUG_LOG_STRING (l_proc_level, 'CreateList.Msg8',
                          ' l_list - PICKED_ROLE --> ' || l_list);
        DEBUG_LOG_STRING (l_proc_level, 'CreateList.Msg9',
                          '  ** END CREATELIST ** ');
     /* =============== END DEBUG LOG ================== */

 EXCEPTION
    WHEN e_user_list_not_found THEN
          FND_MESSAGE.SET_NAME('IGI','IGI_DOS_WKF_NO_USER_LIST');
          /* =============== START DEBUG LOG ================ */
              DEBUG_LOG_UNEXP_ERROR ('CreateList.Unexp2','USER');
          /* =============== END DEBUG LOG ================== */
          Wf_Core.Context ('IGIDOSL', 'CreateList cursor', itemtype, itemkey
                           , to_char(actid),funcmode) ;
          RAISE;
    WHEN OTHERS THEN
          /* =============== START DEBUG LOG ================ */
              DEBUG_LOG_UNEXP_ERROR ('CreateList.Unexp3','DEFAULT');
          /* =============== END DEBUG LOG ================== */
          result := NULL;
          Wf_Core.Context ('IGIDOSL', 'CreateList', itemtype, itemkey
                           , to_char(actid),funcmode) ;
          Raise;

  END CreateList;

  /* ======================= CHECKLIST ========================== */

  PROCEDURE CheckList ( itemtype   VARCHAR2,
                        itemkey    VARCHAR2,
                        actid      NUMBER,
                        funcmode   VARCHAR2,
                        result OUT NOCOPY VARCHAR2)
   IS


   l_user_list VARCHAR2(250)
   := Wf_Engine.GetItemAttrText ( itemtype =>  itemtype,
                                  itemkey  =>  itemkey,
                                  aname    =>  'USER_LIST');

   l_next_position  per_positions.name%TYPE;

   l_parent_position_id hr_all_positions_f.position_id%TYPE
   := Wf_Engine.GetItemAttrText ( itemtype =>  itemtype,
                                  itemkey  =>  itemkey,
                                  aname    =>  'PARENT_POSITION_ID');

   l_next_authoriser wf_notifications.responder%TYPE ;
   l_pos NUMBER := 0;

   no_next_authoriser EXCEPTION ;

  BEGIN

     /* =============== START DEBUG LOG ================ */
        DEBUG_LOG_STRING (l_proc_level, 'CheckList.Msg1',
                          '  ** START CHECKLIST ** ');
     /* =============== END DEBUG LOG ================== */

     IF funcmode <> 'RUN' THEN
       /* =============== START DEBUG LOG ================ */
          DEBUG_LOG_STRING (l_proc_level, 'CheckList.Msg2',
                            ' funcmode <> RUN result COMPLETE');
       /* =============== END DEBUG LOG ================== */
       result := 'COMPLETE';
       return;
     END IF;

     -- The returned value is held in item attribute which is the same name as
     -- the workflow message attribute with source 'Respond'.

     l_next_authoriser := Wf_Engine.GetItemAttrText ( itemtype =>  itemtype,
                                                      itemkey  =>  itemkey,
                                                      aname    =>  'NEXT_AUTHORISER');

     l_next_authoriser := UPPER(l_next_authoriser) ;

     /* =============== START DEBUG LOG ================ */
        DEBUG_LOG_STRING (l_proc_level, 'CheckList.Msg3',
                          '  GetItemAttrText NEXT_AUTHORISER --> ' || l_next_authoriser);
     /* =============== END DEBUG LOG ================== */

      l_pos := INSTR(l_user_list, l_next_authoriser, 1)  ;

     /* =============== START DEBUG LOG ================ */
        DEBUG_LOG_STRING (l_proc_level, 'CheckList.Msg4',
                          '  l_pos --> ' || l_pos);
     /* =============== END DEBUG LOG ================== */

     IF l_pos <> 0 THEN

     /* =============== START DEBUG LOG ================ */
        DEBUG_LOG_STRING (l_proc_level, 'CheckList.Msg5',
                          '  l_pos <> 0 ');
     /* =============== END DEBUG LOG ================== */

        IF l_next_authoriser = 'ALL'
        THEN

           l_next_position := 'POS:'||TO_CHAR(l_parent_position_id);
           l_next_authoriser := l_next_position;
           /* =============== START DEBUG LOG ================ */
              DEBUG_LOG_STRING (l_proc_level, 'CheckList.Msg6',
                                ' l_next_position --> ' || l_next_position ||
                                ' l_next_authoriser --> ' || l_next_authoriser);
           /* =============== END DEBUG LOG ================== */

        END IF ;

        Wf_Engine.SetItemAttrText ( itemtype =>  Itemtype,
                                    itemkey  =>  Itemkey,
                                    aname    =>  'PICKED_ROLE',
                                    avalue   =>  l_next_authoriser) ;

        /* =============== START DEBUG LOG ================ */
           DEBUG_LOG_STRING (l_proc_level, 'CheckList.Msg7',
                             ' l_next_authoriser - PICKED_ROLE --> ' || l_next_authoriser);
        /* =============== END DEBUG LOG ================== */

        Wf_Engine.SetItemAttrText ( itemtype =>  Itemtype,
                                    itemkey  =>  Itemkey,
                                    aname    =>  'SELECTED_USER_NAME',
                                    avalue   =>  l_next_authoriser) ;

        /* =============== START DEBUG LOG ================ */
           DEBUG_LOG_STRING (l_proc_level, 'CheckList.Msg8',
                             ' l_next_authoriser - SELECTED_USER_NAME --> ' || l_next_authoriser);
        /* =============== END DEBUG LOG ================== */

        Result := 'COMPLETE:T';

     ELSE

        Result := 'COMPLETE:F';

     END IF;

     /* =============== START DEBUG LOG ================ */
        DEBUG_LOG_STRING (l_proc_level, 'CheckList.Msg9',
                          ' result --> ' || result);
        DEBUG_LOG_STRING (l_proc_level, 'CheckList.Msg10',
                          ' ** END CHECKLIST ** ');
     /* =============== END DEBUG LOG ================== */

 EXCEPTION
     WHEN no_next_authoriser THEN

         /* =============== START DEBUG LOG ================ */
            DEBUG_LOG_STRING (l_proc_level, 'CheckList.Msg11',
                             ' Exception no_next_authoriser' );
         /* =============== END DEBUG LOG ================== */
         Wf_Core.Context ('IGIDOSL', 'CheckList', itemtype, itemkey
                          , to_char(actid),funcmode, ' Could not find a response value for next authoriser') ;
        RAISE ;

     WHEN OTHERS THEN
        /* =============== START DEBUG LOG ================ */
            DEBUG_LOG_UNEXP_ERROR ('CheckList.Unexp1','DEFAULT');
        /* =============== END DEBUG LOG ================== */
        result := NULL;
        Wf_Core.Context ('IGIDOSL', 'CheckList', itemtype, itemkey
                          , to_char(actid),funcmode) ;
        Raise;

 END CheckList;

  /* ======================== UNRESERVEFUNDS ===================== */

  PROCEDURE UnreserveFunds ( itemtype   VARCHAR2,
                             itemkey    VARCHAR2,
                             actid      NUMBER,
                             funcmode   VARCHAR2,
                             result OUT NOCOPY VARCHAR2)
  IS
     l_trx_status VARCHAR2(30);
     l_fatal_error VARCHAR2(100);
     l_trx_number VARCHAR2(30)
     := Wf_Engine.GetItemAttrText  ( itemtype => itemtype,
                                     itemkey  => itemkey,
                                     aname    => 'DOSSIER_NUM');
     l_user_id    VARCHAR2(30)
     := Wf_Engine.GetItemAttrText  ( itemtype => itemtype,
                                     itemkey  => itemkey,
                                     aname    => 'USER_ID');

     l_responsibility_id    VARCHAR2(30)
     := Wf_Engine.GetItemAttrText  ( itemtype => itemtype,
                                     itemkey  => itemkey,
                                     aname    => 'RESPONSIBILITY_ID');
     l_sob_id number;
     unreserve_error EXCEPTION ;

  BEGIN

     /* =============== START DEBUG LOG ================ */
        DEBUG_LOG_STRING (l_proc_level, 'UnreserveFunds.Msg1',
                          '  ** START UNRESERVEFUNDS ** ');
     /* =============== END DEBUG LOG ================== */

     IF funcmode <> 'RUN' THEN
       /* =============== START DEBUG LOG ================ */
          DEBUG_LOG_STRING (l_proc_level, 'UnreserveFunds.Msg2',
                            ' funcmode <> RUN result COMPLETE');
       /* =============== END DEBUG LOG ================== */
       result := 'COMPLETE:T';
       return;
     END IF;

      SELECT dtype.SOB_ID
      INTO l_sob_id
      FROM IGI_DOS_DOC_TYPES dtype,
           igi_dos_trx_headers thead
      WHERE thead.dossier_id = dtype.dossier_id
      and   thead.trx_number = l_trx_number;

     /* =============== START DEBUG LOG ================ */
        DEBUG_LOG_STRING (l_proc_level, 'UnreserveFunds.Msg3',
                          '  l_sob_id --> ' || l_sob_id);
     /* =============== END DEBUG LOG ================== */

      IF NOT IGI_DOS_FUNDS.REJECT(l_trx_number, l_user_id, l_responsibility_id, l_sob_id)
      THEN
	    BEGIN
        SELECT message_text
		INTO l_fatal_error
		FROM fnd_new_messages
        WHERE message_name = 'IGI_DOS_ERROR_REJECTED';
		EXCEPTION
		    WHEN OTHERS THEN
			  l_fatal_error := '.This Dossier could not be rejected earlier due to encumbrance error.';
		END;
        Wf_Engine.SetItemAttrText (itemtype =>  Itemtype,
                                itemkey  =>  Itemkey,
                                aname    =>  'FATAL_ERROR',
                                avalue   =>  l_fatal_error);
          /* =============== START DEBUG LOG ================ */
             DEBUG_LOG_STRING (l_proc_level, 'UnreserveFunds.Msg3.1',
                               'Setting the Fatal Error Attribute');
          /* =============== END DEBUG LOG ================== */
         result := 'COMPLETE:F';

        /* =============== START DEBUG LOG ================ */
           DEBUG_LOG_STRING (l_proc_level, 'UnreserveFunds.Msg4',
                             '  Raise unreserve error ');
        /* =============== END DEBUG LOG ================== */

        --RAISE unreserve_error ;
      ELSE

         SELECT meaning INTO l_trx_status
         FROM   igi_lookups
         WHERE  lookup_type ='DOSSIER STATUS'
         and    lookup_code ='REJECTED';

         /* =============== START DEBUG LOG ================ */
            DEBUG_LOG_STRING (l_proc_level, 'UnreserveFunds.Msg5',
                              '  l_trx_status --> ' || l_trx_status);
         /* =============== END DEBUG LOG ================== */

         UPDATE IGI_DOS_TRX_HEADERS trx
         SET    trx.trx_status       = l_trx_status,
                trx.last_update_date= sysdate
         WHERE  trx.trx_number       = l_trx_number ;

         /* =============== START DEBUG LOG ================ */
            DEBUG_LOG_STRING (l_proc_level, 'UnreserveFunds.Msg6',
                              '  updated igi_dos_trx_headers ');
         /* =============== END DEBUG LOG ================== */
         --bug 9128478
         Wf_Engine.SetItemAttrText (itemtype =>  Itemtype,
                                itemkey  =>  Itemkey,
                                aname    =>  'FATAL_ERROR',
                                avalue   =>  '');
          /* =============== START DEBUG LOG ================ */
             DEBUG_LOG_STRING (l_proc_level, 'UnreserveFunds.Msg6.1',
                               'Setting the Fatal Error Attribute to null');
          /* =============== END DEBUG LOG ================== */
         result := 'COMPLETE:T';

      END IF ;

     /* =============== START DEBUG LOG ================ */
        DEBUG_LOG_STRING (l_proc_level, 'UnreserveFunds.Msg7',
                          '  ** END UNRESERVEFUNDS ** ');
     /* =============== END DEBUG LOG ================== */

 EXCEPTION
    /* WHEN unreserve_error THEN
           FND_MESSAGE.SET_NAME('IGI','IGI_DOS_WKF_UNRSRV_ERROR');
           FND_MESSAGE.SET_TOKEN('TRANS_NUM',l_trx_number);
           FND_MESSAGE.SET_TOKEN('USER_ID',l_user_id);
           FND_MESSAGE.SET_TOKEN('RESP_ID',l_responsibility_id);
           FND_MESSAGE.SET_TOKEN('SOB_ID',l_sob_id);
           /* =============== START DEBUG LOG ================ */
          --    DEBUG_LOG_UNEXP_ERROR ('UnreserveFunds.Unexp1','USER');
           /* =============== END DEBUG LOG ================== */
          /* Wf_Core.Context ('IGIDOSL', 'UnreserveFunds -Unable to reserve funds for specified packet'
                            , itemtype, itemkey , to_char(actid),funcmode
                            , 'Dossier Trx Num ='||l_trx_number ) ;
           RAISE ;*/

     WHEN OTHERS THEN
           /* =============== START DEBUG LOG ================ */
              DEBUG_LOG_UNEXP_ERROR ('UnreserveFunds.Unexp2','DEFAULT');
           /* =============== END DEBUG LOG ================== */
           result := NULL;
           Wf_Core.Context ('IGIDOSL', 'UnreserveFunds', itemtype, itemkey
                            , to_char(actid),funcmode) ;
           RAISE;

 END UnreserveFunds ;

/* ============================= FRAMEDOSTABLE ================================= */


PROCEDURE FrameDosTable ( Document IN OUT NOCOPY CLOB)
IS

 l_table_header VARCHAR2(32000);

 /* === Message variables === */
 l_trans_dets_head      VARCHAR2(50);
 l_line_head            VARCHAR2(50);
 l_source_budget_head   VARCHAR2(50);
 l_source_account_head  VARCHAR2(50);
 l_source_period_head   VARCHAR2(50);
 l_source_amount_head   VARCHAR2(50);
 l_dest_budget_head     VARCHAR2(50);
 l_dest_account_head    VARCHAR2(50);
 l_dest_period_head     VARCHAR2(50);
 l_dest_amount_head     VARCHAR2(50);

BEGIN

 /* =============== START DEBUG LOG ================ */
    DEBUG_LOG_STRING (l_proc_level, 'FrameDosTable.Msg1',
                      '  ** START FRAMEDOSTABLE ** ');
    DEBUG_LOG_STRING (l_proc_level, 'FrameDosTable.Msg2',
                      ' Getting messages for Table Heading');
 /* =============== END DEBUG LOG ================== */

 -- Getting the Headings FROM fnd message.

 fnd_message.set_name ('IGI', 'IGI_DOS_TRAN_DETS');
 l_trans_dets_head := fnd_message.get;
 fnd_message.set_name ('IGI', 'IGI_DOS_LINE');
 l_line_head := fnd_message.get;
 fnd_message.set_name ('IGI', 'IGI_DOS_SOURCE_BUDGET');
 l_source_budget_head := fnd_message.get;
 fnd_message.set_name ('IGI', 'IGI_DOS_SOURCE_ACCOUNT');
 l_source_account_head := fnd_message.get;
 fnd_message.set_name ('IGI', 'IGI_DOS_SOURCE_PERIOD');
 l_source_period_head := fnd_message.get;
 fnd_message.set_name ('IGI', 'IGI_DOS_SOURCE_AMOUNT');
 l_source_amount_head := fnd_message.get;
 fnd_message.set_name ('IGI', 'IGI_DOS_DEST_BUDGET');
 l_dest_budget_head := fnd_message.get;
 fnd_message.set_name ('IGI', 'IGI_DOS_DEST_ACCOUNT');
 l_dest_account_head := fnd_message.get;
 fnd_message.set_name ('IGI', 'IGI_DOS_DEST_PERIOD');
 l_dest_period_head := fnd_message.get;
 fnd_message.set_name ('IGI', 'IGI_DOS_DEST_AMOUNT');
 l_dest_amount_head := fnd_message.get;

 /* =============== START DEBUG LOG ================ */
    DEBUG_LOG_STRING (l_proc_level, 'FrameDosTable.Msg3',
                      ' Heading Done - Now Framing the table ');
 /* =============== END DEBUG LOG ================== */

 l_table_header := '<br><font color='||th_fontcolor||'face='||
                   th_fontface||'><b>'|| l_trans_dets_head || '</b>'; -- <hr>';

 l_table_header := l_table_header ||'<table bgcolor=' ||table_bgcolor
                                  ||' width='         ||table_width
                                  ||' border='        ||table_border
                                  ||' cellpadding='   ||table_cellpadding
                                  ||' cellspacing='   ||table_cellspacing||'>';

 l_table_header := l_table_header || '<tr bgcolor='||th_bgcolor||'>';
 l_table_header := l_table_header || '<td align="left"><font color='||th_fontcolor||' face='||
                   th_fontface||' size='||th_fontsize||'><b>' || l_line_head || '</b></td>';
 l_table_header := l_table_header || '<td align="left"><font color='||th_fontcolor||' face='||
                   th_fontface||' size='||th_fontsize||'><b>' || l_source_budget_head || '</b></td>';
 l_table_header := l_table_header || '<td align="left"><font color='||th_fontcolor||' face='||
                   th_fontface||' size='||th_fontsize||'><b>' || l_source_account_head || '</b></td>';
 l_table_header := l_table_header || '<td align="left"><font color='||th_fontcolor||' face='||
                   th_fontface||' size='||th_fontsize||'><b>' || l_source_period_head || '</b></td>';
 l_table_header := l_table_header || '<td align="left"><font color='||th_fontcolor||' face='||
                   th_fontface||' size='||th_fontsize||'><b>' || l_source_amount_head
                   || '(' || g_currency_code || ')'|| '</b></td>';
 l_table_header := l_table_header || '<td align="left"><font color='||th_fontcolor||' face='||
                   th_fontface||' size='||th_fontsize||'><b>' || l_dest_budget_head || '</b></td>';
 l_table_header := l_table_header || '<td align="left"><font color='||th_fontcolor||' face='||
                   th_fontface||' size='||th_fontsize||'><b>' || l_dest_account_head || '</b></td>';
 l_table_header := l_table_header || '<td align="left"><font color='||th_fontcolor||' face='||
                   th_fontface||' size='||th_fontsize||'><b>' || l_dest_period_head || '</b></td>';
 l_table_header := l_table_header || '<td align="left"><font color='||th_fontcolor||' face='||
                   th_fontface||' size='||th_fontsize||'><b>' || l_dest_amount_head
                   || '(' || g_currency_code || ')'|| '</b></td>';
 l_table_header := l_table_header || '</tr>';

 /* =============== START DEBUG LOG ================ */
    DEBUG_LOG_STRING (l_proc_level, 'FrameDosTable.Msg4',
                      ' l_table_header --> ' || substr(l_table_header,1,3800));
 /* =============== END DEBUG LOG ================== */

 WF_NOTIFICATION.WriteToClob(Document,l_table_header);

 /* =============== START DEBUG LOG ================ */
    DEBUG_LOG_STRING (l_proc_level, 'FrameDosTable.Msg5',
                      '  ** END FRAMEDOSTABLE ** ');
 /* =============== END DEBUG LOG ================== */

EXCEPTION
  WHEN OTHERS THEN
       /* =============== START DEBUG LOG ================ */
          DEBUG_LOG_UNEXP_ERROR ('FrameDosTable.Unexp1','DEFAULT');
       /* =============== END DEBUG LOG ================== */
       APP_EXCEPTION.RAISE_EXCEPTION;
END FrameDosTable;


/* ============================= ADDTOTALTOTABLE ================================= */


PROCEDURE AddTotalToTable ( Document IN OUT NOCOPY CLOB,
                            p_total  IN            VARCHAR2)
IS

 l_frame_total VARCHAR2(32000);

BEGIN

 /* =============== START DEBUG LOG ================ */
    DEBUG_LOG_STRING (l_proc_level, 'AddTotalToTable.Msg1',
                      ' ** START ADDTOTALTOTABLE ** ');
    DEBUG_LOG_STRING (l_proc_level, 'AddTotalToTable.Msg2',
                      ' Adding text and the total for destination ');
 /* =============== END DEBUG LOG ================== */

 l_frame_total := l_frame_total || '<td bgcolor='||th_bgcolor||' align="right" COLSPAN=8 ><font color='||
                  th_fontcolor||' face='||th_fontface||' size='||th_fontsize ||'><b>'|| g_total_text ||'</b></td>';

 l_frame_total := l_frame_total || '<td bgcolor='||td_bgcolor||' align="right"><font color='||
                  td_fontcolor  ||' face='||td_fontface||' size='||td_fontsize||'>'||p_total||'</td>';

 l_frame_total := l_frame_total || '</tr>';

 /* =============== START DEBUG LOG ================ */
    DEBUG_LOG_STRING (l_proc_level, 'AddTotalToTable.Msg3',
                      ' l_frame_total --> ' || substr(l_frame_total,1,3900));
 /* =============== END DEBUG LOG ================== */

 WF_NOTIFICATION.WriteToClob(Document,l_frame_total);

 /* =============== START DEBUG LOG ================ */
    DEBUG_LOG_STRING (l_proc_level, 'AddTotalToTable.Msg4',
                      ' ** END ADDTOTALTOTABLE ** ');
 /* =============== END DEBUG LOG ================== */

EXCEPTION
  WHEN OTHERS THEN
       /* =============== START DEBUG LOG ================ */
          DEBUG_LOG_UNEXP_ERROR ('AddTotalToTable.Unexp1','DEFAULT');
       /* =============== END DEBUG LOG ================== */
       APP_EXCEPTION.RAISE_EXCEPTION;

END AddTotalToTable;

/* ============================= DOSSIER_TRANSACTION_DETAIL ================================= */

Procedure dossier_transaction_detail(document_id in VARCHAR2,
                                     display_type in VARCHAR2,
				     document in out NOCOPY CLOB,
				     document_type in out NOCOPY VARCHAR2)
IS

  l_table_frame    VARCHAR2(32000) := NULL;
  l_trx_detail     VARCHAR2(32000) := NULL;
  l_dossier_id     VARCHAR2(255);
  l_dossier_num    VARCHAR2(250);
  l_dossier_trx_id NUMBER;

  l_itemtype       VARCHAR2(30);
  l_itemkey        VARCHAR2(60);
  l_document_old   VARCHAR2(32000) := NULL;
  l_line_num       NUMBER := 0;

  l_source_formatted_amount  VARCHAR2(100);
  l_dest_formatted_amount    VARCHAR2(100);

  l_dest_total     NUMBER;
  l_source_total   NUMBER;

  l_source_formatted_total  VARCHAR2(100);
  l_dest_formatted_total    VARCHAR2(100);

  l_new_source     VARCHAR2(1);

  CURSOR c_get_trx_id
  IS
     SELECT trx_id FROM igi_dos_trx_headers
     WHERE  trx_number = l_dossier_num
     AND    dossier_id = l_dossier_id;

  CURSOR c_get_sources
  IS
    SELECT s.budget_name,
           NVL(s.funds_available,0) - NVL(s.new_balance,0) amount,
           s.visible_segments,
           s.period_name,
           s.source_id,
           s.source_trx_id
    FROM   igi_dos_trx_sources s
    WHERE  trx_id = l_dossier_trx_id
    AND EXISTS (SELECT budget_name
                FROM   igi_dos_trx_dest d
                WHERE  d.trx_id = l_dossier_trx_id
                AND    source_id = s.source_id
                AND    source_trx_id = s.source_trx_id);

  CURSOR c_get_destinations(p_source_id NUMBER, p_source_trx_id NUMBER)
  IS
    SELECT budget_name,
           ABS(NVL(funds_available,0) - NVL(new_balance,0)) amount,
           visible_segments,
           period_name,
           source_id,
           source_trx_id,
           destination_id,
           dest_trx_id
    FROM   igi_dos_trx_dest
    WHERE  trx_id = l_dossier_trx_id
    AND    source_id = p_source_id
    AND    source_trx_id = p_source_trx_id
    ORDER BY destination_id,
             dest_trx_id;

BEGIN

  /* =============== START DEBUG LOG ================ */
     DEBUG_LOG_STRING (l_proc_level, 'dossier_transaction_detail.Msg1',
                       ' ** START DOSSIER_TRANSACTION_DETAIL ** ' ) ;
  /* =============== END DEBUG LOG ================== */

  l_itemtype := substr(document_id,1,instr(document_id,':')-1);
  l_itemkey  := substr(document_id,instr(document_id,':')+1);

  /* =============== START DEBUG LOG ================ */
     DEBUG_LOG_STRING (l_proc_level, 'dossier_transaction_detail.Msg2',
                       ' l_itemtype --> ' || l_itemtype ) ;
     DEBUG_LOG_STRING (l_proc_level, 'dossier_transaction_detail.Msg3',
                       ' l_itemkey  --> ' || l_itemkey  ) ;
  /* =============== END DEBUG LOG ================== */

  -- set of books id.
   -- g_sob_id := FND_PROFILE.VALUE ('GL_SET_OF_BKS_ID');


  /* =============== START DEBUG LOG ================ */
   --  DEBUG_LOG_STRING (l_proc_level, 'dossier_transaction_detail.Msg3.1',
   --                    ' g_sob_id       --> ' || g_sob_id);
  /* =============== END DEBUG LOG ================== */

  -- currency code.
 /* OPEN  c_curr(g_sob_id);
  FETCH c_curr INTO g_currency_code;
  CLOSE c_curr;*/

  /* =============== START DEBUG LOG ================ */
    -- DEBUG_LOG_STRING (l_proc_level, 'dossier_transaction_detail.Msg3.2',
    --                   ' g_curency_code --> ' || g_currency_code);
  /* =============== END DEBUG LOG ================== */


  l_dossier_num
      := Wf_Engine.GetItemAttrText ( itemtype => l_itemtype,
                                     itemkey  => l_itemkey,
                                     aname    => 'DOSSIER_NUM');

  /* =============== START DEBUG LOG ================ */
     DEBUG_LOG_STRING (l_proc_level, 'dossier_transaction_detail.Msg4',
                       ' l_dossier_num --> ' || l_dossier_num);
  /* =============== END DEBUG LOG ================== */

  l_dossier_id
    := Wf_Engine.GetItemAttrNumber ( itemtype =>  l_itemtype,
                                     itemkey  =>  l_itemkey,
                                     aname    =>  'DOSSIER_ID');

  /* =============== START DEBUG LOG ================ */
     DEBUG_LOG_STRING (l_proc_level, 'dossier_transaction_detail.Msg5',
                       ' l_dossier_id --> ' || l_dossier_id);
  /* =============== END DEBUG LOG ================== */

     OPEN  c_get_trx_id;
     FETCH c_get_trx_id INTO l_dossier_trx_id;
     CLOSE c_get_trx_id;

  /* =============== START DEBUG LOG ================ */
     DEBUG_LOG_STRING (l_proc_level, 'dossier_transaction_detail.Msg6',
                       ' l_dossier_trx_id --> ' || l_dossier_trx_id);
  /* =============== END DEBUG LOG ================== */
  --bug 9075812
      SELECT dtype.SOB_ID
      INTO g_sob_id
      FROM IGI_DOS_DOC_TYPES dtype,
           igi_dos_trx_headers thead
      WHERE thead.dossier_id = dtype.dossier_id
      and   thead.trx_number = l_dossier_num;
	  /* =============== START DEBUG LOG ================ */
     DEBUG_LOG_STRING (l_proc_level, 'dossier_transaction_detail.Msg3.1',
                       ' g_sob_id       --> ' || g_sob_id);
  /* =============== END DEBUG LOG ================== */

	-- currency code.
	  OPEN  c_curr(g_sob_id);
      FETCH c_curr INTO g_currency_code;
      CLOSE c_curr;
	/* =============== START DEBUG LOG ================ */
     DEBUG_LOG_STRING (l_proc_level, 'dossier_transaction_detail.Msg3.2',
                       ' g_curency_code --> ' || g_currency_code);
  /* =============== END DEBUG LOG ================== */

     FrameDosTable (Document);

  /* =============== START DEBUG LOG ================ */
     DEBUG_LOG_STRING (l_proc_level, 'dossier_transaction_detail.Msg7',
                       ' Copying table headings in to clob ');
     DEBUG_LOG_STRING (l_proc_level, 'dossier_transaction_detail.Msg8',
                       ' starrting for loop ');
  /* =============== END DEBUG LOG ================== */

     l_source_total := 0;

     -- getting grand total test message.
     fnd_message.set_name ('IGI','IGI_DOS_TOTAL');
     g_total_text := fnd_message.get;

     FOR source_rec IN c_get_sources LOOP

         /* =============== START DEBUG LOG ================ */
            DEBUG_LOG_STRING (l_proc_level, 'dossier_transaction_detail.Msg9'
                            , ' Source_id     --> ' || source_rec.source_id);
            DEBUG_LOG_STRING (l_proc_level, 'dossier_transaction_detail.Msg10',
                              ' Source_trx_id --> ' || source_rec.source_trx_id);
         /* =============== END DEBUG LOG ================== */

         l_line_num   := l_line_num + 1;
         l_new_source := 'Y';
         l_dest_total := 0;

	 FOR dest_rec IN c_get_destinations(source_rec.source_id, source_rec.source_trx_id) LOOP


            /* =============== START DEBUG LOG ================ */
               DEBUG_LOG_STRING (l_proc_level, 'dossier_transaction_detail.Msg11',
                                 ' l_line_num                  --> ' || l_line_num);
            /* =============== END DEBUG LOG ================== */

            l_trx_detail := '<tr>';

            IF l_new_source = 'Y' THEN

            /* =============== START DEBUG LOG ================ */
               DEBUG_LOG_STRING (l_proc_level, 'dossier_transaction_detail.Msg12',
                                 ' l_new_source                --> ' || l_new_source);
            /* =============== END DEBUG LOG ================== */

            -- Source details
            l_new_source    := 'N';
            l_source_formatted_amount := TO_CHAR(source_rec.amount, FND_CURRENCY.Get_Format_Mask(g_currency_code,22));
            l_trx_detail := l_trx_detail || '<td bgcolor='||td_bgcolor||' align="left"><font color='||td_fontcolor
                            ||' face='||td_fontface||' size='||td_fontsize||'>' || to_char(l_line_num) || '</td>';
            l_trx_detail := l_trx_detail || '<td bgcolor='||td_bgcolor||' align="left"><font color='||td_fontcolor
                            ||' face='||td_fontface||' size='||td_fontsize||'>' || source_rec.budget_name || '</td>';
            l_trx_detail := l_trx_detail || '<td bgcolor='||td_bgcolor||' align="left"><font color='||td_fontcolor
                            ||' face='||td_fontface||' size='||td_fontsize||'>' || source_rec.visible_segments || '</td>';
            l_trx_detail := l_trx_detail || '<td bgcolor='||td_bgcolor||' align="left"><font color='||td_fontcolor
                            ||' face='||td_fontface||' size='||td_fontsize||'>' || source_rec.period_name || '</td>';
            l_trx_detail := l_trx_detail || '<td bgcolor='||td_bgcolor||' align="right"><font color='||td_fontcolor
                            ||' face='||td_fontface||' size='||td_fontsize||'>' || l_source_formatted_amount  || '</td>';

            ELSE

             /* =============== START DEBUG LOG ================ */
               DEBUG_LOG_STRING (l_proc_level, 'dossier_transaction_detail.Msg13',
                                 ' l_new_source                --> ' || l_new_source);
             /* =============== END DEBUG LOG ================== */

            -- Blank Source details
            l_trx_detail := l_trx_detail || '<td bgcolor='||td_bgcolor||' align="left"><font color='||td_fontcolor
                            ||' face='||td_fontface||' size='||td_fontsize||'>' || ' ' || '</td>';
            l_trx_detail := l_trx_detail || '<td bgcolor='||td_bgcolor||' align="left"><font color='||td_fontcolor
                            ||' face='||td_fontface||' size='||td_fontsize||'>' || ' ' || '</td>';
            l_trx_detail := l_trx_detail || '<td bgcolor='||td_bgcolor||' align="left"><font color='||td_fontcolor
                            ||' face='||td_fontface||' size='||td_fontsize||'>' || ' ' || '</td>';
            l_trx_detail := l_trx_detail || '<td bgcolor='||td_bgcolor||' align="left"><font color='||td_fontcolor
                            ||' face='||td_fontface||' size='||td_fontsize||'>' || ' ' || '</td>';
            l_trx_detail := l_trx_detail || '<td bgcolor='||td_bgcolor||' align="right"><font color='||td_fontcolor
                            ||' face='||td_fontface||' size='||td_fontsize||'>' || ' '  || '</td>';

            END IF;

            /* =============== START DEBUG LOG ================ */
               DEBUG_LOG_STRING (l_proc_level, 'dossier_transaction_detail.Msg14',
                                 ' Framing destination details ');
            /* =============== END DEBUG LOG ================== */

            -- Destination details
            l_dest_formatted_amount   := TO_CHAR(dest_rec.amount,   FND_CURRENCY.Get_Format_Mask(g_currency_code,22));
            l_trx_detail := l_trx_detail || '<td bgcolor='||td_bgcolor||' align="left"><font color='||td_fontcolor
                            ||' face='||td_fontface||' size='||td_fontsize||'>' || dest_rec.budget_name || '</td>';
            l_trx_detail := l_trx_detail || '<td bgcolor='||td_bgcolor||' align="left"><font color='||td_fontcolor
                            ||' face='||td_fontface||' size='||td_fontsize||'>' || dest_rec.visible_segments || '</td>';
            l_trx_detail := l_trx_detail || '<td bgcolor='||td_bgcolor||' align="left"><font color='||td_fontcolor
                            ||' face='||td_fontface||' size='||td_fontsize||'>' || dest_rec.period_name || '</td>';
            l_trx_detail := l_trx_detail || '<td bgcolor='||td_bgcolor||' align="right"><font color='||td_fontcolor
                            ||' face='||td_fontface||' size='||td_fontsize||'>' || l_dest_formatted_amount || '</td>';
            l_trx_detail := l_trx_detail || '</tr>';

            l_dest_total := l_dest_total + dest_rec.amount;

            /* =============== START DEBUG LOG ================ */
               DEBUG_LOG_STRING (l_proc_level, 'dossier_transaction_detail.Msg15',
                                 ' source_rec.budget_name      --> ' || source_rec.budget_name);
               DEBUG_LOG_STRING (l_proc_level, 'dossier_transaction_detail.Msg16',
                                 ' source_rec.visible_segments --> ' || source_rec.visible_segments);
               DEBUG_LOG_STRING (l_proc_level, 'dossier_transaction_detail.Msg17',
                                 ' source_budget_name          --> ' || source_rec.budget_name);
               DEBUG_LOG_STRING (l_proc_level, 'dossier_transaction_detail.Msg18',
                                 ' source_rec.amount           --> ' || l_source_formatted_amount);
               DEBUG_LOG_STRING (l_proc_level, 'dossier_transaction_detail.Msg19',
                                 ' dest_rec.budget_name        --> ' || dest_rec.budget_name);
               DEBUG_LOG_STRING (l_proc_level, 'dossier_transaction_detail.Msg20',
                                 ' dest_rec.visible_segments   --> ' || dest_rec.visible_segments);
               DEBUG_LOG_STRING (l_proc_level, 'dossier_transaction_detail.Msg21',
                                 ' dest_rec.period_name        --> ' || dest_rec.period_name);
               DEBUG_LOG_STRING (l_proc_level, 'dossier_transaction_detail.Msg22',
                                 ' dest_rec.amount             --> ' || l_dest_formatted_amount);
            /* =============== END DEBUG LOG ================== */

            WF_NOTIFICATION.WriteToClob(Document,l_trx_detail);

            /* =============== START DEBUG LOG ================ */
               DEBUG_LOG_STRING (l_proc_level, 'dossier_transaction_detail.Msg23',
                                 ' l_trx_detail updated to clob ');
            /* =============== END DEBUG LOG ================== */

        END LOOP; -- destinations

         /* =============== START DEBUG LOG ================ */
            DEBUG_LOG_STRING (l_proc_level, 'dossier_transaction_detail.Msg24',
                              ' Calling AddTotalToTable to set the destination total ');
         /* =============== END DEBUG LOG ================== */

         -- Adding total for every destination.
         l_dest_formatted_total := TO_CHAR(l_dest_total,   FND_CURRENCY.Get_Format_Mask(g_currency_code,22));
         AddTotalToTable (Document, l_dest_formatted_total);

         l_source_total := l_source_total + source_rec.amount;

    END LOOP; -- sources

    -- getting grand total test message.
    fnd_message.set_name ('IGI','IGI_DOS_GRAND_TOTAL');
    g_total_text := fnd_message.get;

    /* =============== START DEBUG LOG ================ */
        DEBUG_LOG_STRING (l_proc_level, 'dossier_transaction_detail.Msg24.1',
                          ' Calling AddTotalToTable to set the grand total ');
    /* =============== END DEBUG LOG ================== */

    -- Adding the grand total.
    l_source_formatted_total := TO_CHAR(l_source_total,   FND_CURRENCY.Get_Format_Mask(g_currency_code,22));
    AddTotalToTable (Document, l_source_formatted_total);

    /* =============== START DEBUG LOG ================ */
       DEBUG_LOG_STRING (l_proc_level, 'dossier_transaction_detail.Msg25',
                                        ' Out of loop ' ) ;
    /* =============== END DEBUG LOG ================== */

    l_trx_detail := '</table><br>';
    WF_NOTIFICATION.WriteToClob(Document,l_trx_detail);


    /* =============== START DEBUG LOG ================ */
       DEBUG_LOG_STRING (l_proc_level, 'dossier_transaction_detail.Msg26',
                                        ' Copied to CLOB ' ) ;
       DEBUG_LOG_STRING (l_proc_level, 'dossier_transaction_detail.Msg27',
                                        ' ** END DOSSIER_TRANSACTION_DETAIL ** ' ) ;
    /* =============== END DEBUG LOG ================== */

EXCEPTION
 WHEN OTHERS THEN
       /* =============== START DEBUG LOG ================ */
          DEBUG_LOG_UNEXP_ERROR ('dossier_transaction_detail.Unexp1','DEFAULT');
       /* =============== END DEBUG LOG ================== */
       RAISE;

END dossier_transaction_detail;

/* ======================= REWINDINPROCESS ================================= */

   --
   -- Rewinds the 'In Process' status of the Dossier Transaction
   -- to 'Creating'
   --
   PROCEDURE RewindInProcess( itemtype   IN VARCHAR2,
                              itemkey    IN VARCHAR2,
                              actid      IN NUMBER,
                              funcmode   IN VARCHAR2,
                              result    OUT NOCOPY VARCHAR2 ) IS

      l_trx_status  igi_lookups.meaning%TYPE;
      l_dossier_num igi_dos_trx_headers.trx_number%TYPE :=
                         Wf_Engine.GetItemAttrText ( itemtype => itemtype,
                                                     itemkey  => itemkey,
                                                     aname    => 'DOSSIER_NUM');

      CURSOR c_meaning IS
         SELECT meaning
         FROM   igi_lookups
         WHERE  lookup_type = 'DOSSIER STATUS'
         AND    lookup_code = 'CREATING';

   BEGIN

      /* =============== START DEBUG LOG ================ */
         DEBUG_LOG_STRING (l_proc_level, 'RewindInProcess.Msg1',
                           ' ** START REWINDINPROCESS ** ');
      /* =============== END DEBUG LOG ================== */

      -- FETCH the translated value for 'Creating'
      OPEN  c_meaning;
      FETCH c_meaning INTO l_trx_status;
      CLOSE c_meaning;

      /* =============== START DEBUG LOG ================ */
         DEBUG_LOG_STRING (l_proc_level, 'RewindInProcess.Msg2',
                           ' l_trx_status --> ' || l_trx_status);
      /* =============== END DEBUG LOG ================== */

      -- Rewind the 'In Process' status to 'Creating'
      UPDATE igi_dos_trx_headers trx
      SET    trx.trx_status = l_trx_status,
             trx.last_update_date= sysdate
      WHERE  trx.trx_number = l_dossier_num;

      /* =============== START DEBUG LOG ================ */
         DEBUG_LOG_STRING (l_proc_level, 'RewindInProcess.Msg3',
                           ' updating igi_dos_trx_headers ');
      /* =============== END DEBUG LOG ================== */

      COMMIT;

      /* =============== START DEBUG LOG ================ */
         DEBUG_LOG_STRING (l_proc_level, 'RewindInProcess.Msg4',
                           ' result --> COMPLETE ');
      /* =============== END DEBUG LOG ================== */

      result := 'COMPLETE';

      /* =============== START DEBUG LOG ================ */
         DEBUG_LOG_STRING (l_proc_level, 'RewindInProcess.Msg5',
                           ' ** END REWINDINPROCESS ** ');
      /* =============== END DEBUG LOG ================== */

   EXCEPTION
      WHEN OTHERS THEN
           /* =============== START DEBUG LOG ================ */
              DEBUG_LOG_UNEXP_ERROR ('RewindInProcess.Unexp1','DEFAULT');
           /* =============== END DEBUG LOG ================== */
           result := NULL;
           RAISE;
   END RewindInProcess;

 /* ===================== ISEMPLOYEE **********************/

 --
 -- Validates if dossier approval launcher is an employee
 --

 PROCEDURE IsEmployee( itemtype   IN VARCHAR2,
                       itemkey    IN VARCHAR2,
                       actid      IN NUMBER,
                       funcmode   IN VARCHAR2,
                       result    OUT NOCOPY VARCHAR2 ) IS

    l_emp_id  NUMBER(15);

    l_user_id NUMBER(15) := Wf_Engine.GetItemAttrText
                                    ( itemtype => itemtype,
                                      itemkey  => itemkey,
                                      aname    => 'USER_ID');

    CURSOR c_emp_id (p_user_id fnd_user.user_id%TYPE)
    IS
       SELECT employee_id
       FROM   fnd_user
       WHERE  user_id = p_user_id;

 BEGIN

    /* =============== START DEBUG LOG ================ */
       DEBUG_LOG_STRING (l_proc_level, 'IsEmployee.Msg1',
                         ' ** START ISEMPLOYEE ** ');
    /* =============== END DEBUG LOG ================== */

     IF funcmode <> 'RUN' THEN
       /* =============== START DEBUG LOG ================ */
          DEBUG_LOG_STRING (l_proc_level, 'IsEmployee.Msg2',
                            ' funcmode <> RUN result COMPLETE');
       /* =============== END DEBUG LOG ================== */
       result := 'COMPLETE';
       return;
     END IF;

    -- Get the employee id of the dossier approval launcher
    OPEN  c_emp_id(l_user_id);
    FETCH c_emp_id INTO l_emp_id;
    CLOSE c_emp_id;

    /* =============== START DEBUG LOG ================ */
       DEBUG_LOG_STRING (l_proc_level, 'IsEmployee.Msg3',
                         ' l_emp_id --> ' || l_emp_id);
    /* =============== END DEBUG LOG ================== */

    IF l_emp_id IS NULL THEN
       -- The launcher is not an employee
       result := 'COMPLETE:N';

    ELSE
       -- Save the employee id for subsequent validations
       Wf_Engine.SetItemAttrText ( itemtype => itemtype,
                                   itemkey  => itemkey,
                                   aname    => 'EMPLOYEE_ID',
                                   avalue   => l_emp_id);

       /* =============== START DEBUG LOG ================ */
          DEBUG_LOG_STRING (l_proc_level, 'IsEmployee.Msg4',
                            ' SetItemAttrText EMPLOYEE_ID to ' || l_emp_id);
       /* =============== END DEBUG LOG ================== */

       -- The launcher is an employee
       result := 'COMPLETE:Y';
    END IF;

    /* =============== START DEBUG LOG ================ */
       DEBUG_LOG_STRING (l_proc_level, 'IsEmployee.Msg5',
                         ' result --> ' || result);
       DEBUG_LOG_STRING (l_proc_level, 'IsEmployee.Msg6',
                         ' ** END ISEMPLOYEE ** ');
    /* =============== END DEBUG LOG ================== */

 EXCEPTION
      WHEN OTHERS THEN
           /* =============== START DEBUG LOG ================ */
              DEBUG_LOG_UNEXP_ERROR ('RewindInProcess.Unexp1','DEFAULT');
           /* =============== END DEBUG LOG ================== */
           result := NULL;
           RAISE;

 END IsEmployee;

 /* ========================= HASPOSITION ===================== */

   --
   -- Validates if dossier approval launcher has a position
   -- assignment.
   --
   PROCEDURE HasPosition( itemtype   IN VARCHAR2,
                          itemkey    IN VARCHAR2,
                          actid      IN NUMBER,
                          funcmode   IN VARCHAR2,
                          result    OUT NOCOPY VARCHAR2 ) IS


      CURSOR c_get_position(p_emp_id per_employees_current_x.employee_id%TYPE)
      IS
         select    hap.position_id,
               hap.name,
               hap.business_group_id,
               hap.organization_id
         FROM
               hr_all_positions_f      hap,
               per_all_assignments_f   paa,
               per_people_f p,
               per_periods_of_service b
         WHERE
               p.person_id = p_emp_id
         AND   paa.person_id = p.person_id
         AND   paa.primary_flag = 'Y'
         AND   paa.period_of_service_id = b.period_of_service_id
         AND   TRUNC(SYSDATE) BETWEEN p.effective_start_date AND p.effective_end_date
         AND   TRUNC(SYSDATE) BETWEEN paa.effective_start_date AND paa.effective_end_date
         AND   (b.actual_termination_date>= trunc(sysdate) or b.actual_termination_date is null)
         AND   p.employee_number IS NOT NULL
         and   p.business_group_id = paa.business_group_id
         and   paa.assignment_type = 'E'
         and   paa.business_group_id = hap.business_group_id
         and   paa.position_id IS NOT NULL
         and   paa.position_id = hap.position_id
         and   paa.organization_id = hap.organization_id
         and   hap.date_effective <= SYSDATE
         and   NVL(hap.date_end, SYSDATE) >= SYSDATE
         and   NVL(UPPER(hap.status), 'VALID') NOT IN ('INVALID') ;


      l_position_id       hr_all_positions_f.position_id%TYPE;
      l_position_name     hr_all_positions_f.name%TYPE;
      l_business_group_id hr_all_positions_f.business_group_id%TYPE;
      l_organization_id   hr_all_positions_f.organization_id%TYPE;

      l_emp_id NUMBER(15) := Wf_Engine.GetItemAttrText
                                         ( itemtype => itemtype,
                                           itemkey  => itemkey,
                                           aname    => 'EMPLOYEE_ID');

   BEGIN

    /* =============== START DEBUG LOG ================ */
       DEBUG_LOG_STRING (l_proc_level, 'HasPosition.Msg1',
                         ' ** END HASPOSITION ** ');
    /* =============== END DEBUG LOG ================== */

     IF funcmode <> 'RUN' THEN
       /* =============== START DEBUG LOG ================ */
          DEBUG_LOG_STRING (l_proc_level, 'HasPosition.Msg2',
                            ' funcmode <> RUN result COMPLETE');
       /* =============== END DEBUG LOG ================== */
       result := 'COMPLETE';
       return;
     END IF;

      -- FETCH position for employee
      OPEN  c_get_position(l_emp_id);
      FETCH c_get_position INTO l_position_id
                               ,l_position_name
                               ,l_business_group_id
                               ,l_organization_id;


     /* =============== START DEBUG LOG ================ */
        DEBUG_LOG_STRING (l_proc_level, 'HasPosition.Msg3',
                          ' Get position for l_emp_id --> ' || l_emp_id);
     /* =============== END DEBUG LOG ================== */

     IF (c_get_position%NOTFOUND) THEN

         result := 'COMPLETE:N';
      ELSE

         Wf_Engine.SetItemAttrText (itemtype => ItemType,
                                    itemkey  => ItemKey,
                                    aname    => 'CURRENT_POSITION_ID',
                                    avalue   => l_position_id);

         /* =============== START DEBUG LOG ================ */
            DEBUG_LOG_STRING (l_proc_level, 'HasPosition.Msg4',
                              ' SetItemAttrText CURRENT_POSITION_ID -> ' || l_position_id );
         /* =============== END DEBUG LOG ================== */

         Wf_Engine.SetItemAttrText (itemtype => ItemType,
                                    itemkey  => ItemKey,
                                    aname    => 'BUSINESS_GROUP_ID',
                                    avalue   => l_business_group_id);

         /* =============== START DEBUG LOG ================ */
            DEBUG_LOG_STRING (l_proc_level, 'HasPosition.Msg5',
                              ' SetItemAttrText BUSINESS_GROUP_ID -> ' || l_business_group_id);
         /* =============== END DEBUG LOG ================== */

         Wf_Engine.SetItemAttrText (itemtype => ItemType,
                                    itemkey  => ItemKey,
                                    aname    => 'ORGANIZATION_ID',
                                    avalue   => l_organization_id);

         /* =============== START DEBUG LOG ================ */
            DEBUG_LOG_STRING (l_proc_level, 'HasPosition.Msg6',
                              ' SetItemAttrText ORGANIZATION_ID -> ' || l_organization_id);
         /* =============== END DEBUG LOG ================== */

         result := 'COMPLETE:Y';

      END IF;

     /* =============== START DEBUG LOG ================ */
        DEBUG_LOG_STRING (l_proc_level, 'HasPosition.Msg7',
                          ' result --> ' || result );
     /* =============== END DEBUG LOG ================== */

      IF (c_get_position%ISOPEN) THEN
         CLOSE c_get_position;
      END IF;

     /* =============== START DEBUG LOG ================ */
        DEBUG_LOG_STRING (l_proc_level, 'HasPosition.Msg8',
                          ' ** END HASPOSITION ** ');
     /* =============== END DEBUG LOG ================== */

 EXCEPTION
      WHEN OTHERS THEN
           /* =============== START DEBUG LOG ================ */
              DEBUG_LOG_UNEXP_ERROR ('HasPosition.Unexp1','DEFAULT');
           /* =============== END DEBUG LOG ================== */
           result := NULL;
           RAISE;
 END HasPosition;

  /* ======================== POSITIONINHIERARCHY ***********************/

   --
   --  Validates if dossier approval launcher position is in the
   --  hierarchy attached to the dossier type.
   --
   PROCEDURE PositionInHierarchy( itemtype   IN VARCHAR2,
                                  itemkey    IN VARCHAR2,
                                  actid      IN NUMBER,
                                  funcmode   IN VARCHAR2,
                                  result    OUT NOCOPY VARCHAR2 ) IS

      l_position_id hr_all_positions_f.position_id%TYPE :=
             Wf_Engine.GetItemAttrText (itemtype => ItemType,
                                        itemkey  => ItemKey,
                                        aname    => 'CURRENT_POSITION_ID');

      l_business_group_id hr_all_positions_f.business_group_id%TYPE :=
             Wf_Engine.GetItemAttrText (itemtype => ItemType,
                                        itemkey  => ItemKey,
                                        aname    => 'BUSINESS_GROUP_ID');

      l_organization_id   hr_all_positions_f.organization_id%TYPE :=
             Wf_Engine.GetItemAttrText (itemtype => ItemType,
                                        itemkey  => ItemKey,
                                        aname    => 'ORGANIZATION_ID');

      l_dossier_id igi_dos_doc_types.dossier_id%TYPE :=
             Wf_Engine.GetItemAttrNumber (itemtype => ItemType,
                                          itemkey  => ItemKey,
                                          aname    => 'DOSSIER_ID');

      l_valid BOOLEAN := TRUE;

      l_hierarchy_id
           per_position_structures.position_structure_id%TYPE;
      l_hierarchy_version_id
           per_pos_structure_versions.pos_structure_version_id%TYPE;
      l_pos_structure_element_id
           per_pos_structure_elements.pos_structure_element_id%TYPE;

      -- Cursor to FETCH position hierarchy
      CURSOR c_pos_hier (p_dossier_id igi_dos_doc_types.dossier_id%TYPE) IS
         SELECT hierarchy_id
         FROM igi_dos_doc_types
         WHERE dossier_id = p_dossier_id;

      -- Cursor to FETCH current version of position hierarchy
      CURSOR c_pos_hier_ver
           (p_hierarchy_id igi_dos_doc_types.hierarchy_id%TYPE,
            p_business_group_id hr_all_positions_f.business_group_id%TYPE) IS
         SELECT pos_structure_version_id
         FROM   per_pos_structure_versions
         WHERE  position_structure_id = p_hierarchy_id
         AND    SYSDATE BETWEEN date_FROM AND NVL(date_to, SYSDATE)
         AND    business_group_id = p_business_group_id
         AND    version_number =
                (SELECT MAX(version_number)
                 FROM   per_pos_structure_versions
                 WHERE  position_structure_id = p_hierarchy_id
                 AND    SYSDATE BETWEEN date_FROM AND NVL(date_to,SYSDATE)
                 AND    business_group_id = p_business_group_id);

      -- Cursor to FETCH current version of position hierarchy
      CURSOR c_is_pos_in_hier
           (p_business_group_id
                 hr_all_positions_f.business_group_id%TYPE,
            p_pos_structure_ver_id
                 per_pos_structure_elements.pos_structure_version_id%TYPE,
            p_position_id per_all_positions.position_id%TYPE) IS
         SELECT pos_structure_element_id
         FROM   per_pos_structure_elements
         WHERE  pos_structure_version_id = p_pos_structure_ver_id
         AND    business_group_id = p_business_group_id
         AND   (subordinate_position_id = p_position_id OR
                parent_position_id = p_position_id);

   BEGIN

     /* =============== START DEBUG LOG ================ */
        DEBUG_LOG_STRING (l_proc_level, 'PositionInHierarchy.Msg1',
                          ' ** END POSITIONINHIERARCHY ** ');
     /* =============== END DEBUG LOG ================== */

     IF funcmode <> 'RUN' THEN
       /* =============== START DEBUG LOG ================ */
          DEBUG_LOG_STRING (l_proc_level, 'PositionInHierarchy.Msg2',
                            ' funcmode <> RUN result COMPLETE');
       /* =============== END DEBUG LOG ================== */
       result := 'COMPLETE';
       return;
     END IF;

      -- Get the position Hierarchy
      OPEN  c_pos_hier(l_dossier_id);
      FETCH c_pos_hier INTO l_hierarchy_id;

     /* =============== START DEBUG LOG ================ */
        DEBUG_LOG_STRING (l_proc_level, 'PositionInHierarchy.Msg3',
                          ' Getting position Hierarchy for --> ' || l_dossier_id);
     /* =============== END DEBUG LOG ================== */

      IF (c_pos_hier%NOTFOUND) THEN
         l_valid := FALSE;
      ELSE
         Wf_Engine.SetItemAttrText (itemtype => ItemType,
                                    itemkey  => ItemKey,
                                    aname    => 'POS_STRUCTURE_ID',
                                    avalue   => l_hierarchy_id);

         /* =============== START DEBUG LOG ================ */
            DEBUG_LOG_STRING (l_proc_level, 'PositionInHierarchy.Msg4',
                             ' SetItemAttrText POS_STRUCTURE_ID as ' || l_hierarchy_id);
         /* =============== END DEBUG LOG ================== */

         result := 'COMPLETE:Y';
         l_valid := TRUE;
      END IF;

      IF (c_pos_hier%ISOPEN) THEN
         CLOSE c_pos_hier;
      END IF;

      IF l_valid THEN

         /* =============== START DEBUG LOG ================ */
            DEBUG_LOG_STRING (l_proc_level, 'PositionInHierarchy.Msg5',
                              ' l_valid --> TRUE ');
         /* =============== END DEBUG LOG ================== */

         -- Get the current version of position Hierarchy
         OPEN  c_pos_hier_ver(l_hierarchy_id,
                              l_business_group_id);
         FETCH c_pos_hier_ver INTO l_hierarchy_version_id;

         /* =============== START DEBUG LOG ================ */
            DEBUG_LOG_STRING (l_proc_level, 'PositionInHierarchy.Msg6',
                              ' Getting hierarchy for l_hierarchy_id --> '||l_hierarchy_id
                              ||' l_business_group_id --> '||l_business_group_id);
            DEBUG_LOG_STRING (l_proc_level, 'PositionInHierarchy.Msg7',
                              ' l_hierarchy_version_id --> ' || l_hierarchy_version_id );
         /* =============== END DEBUG LOG ================== */

         IF (c_pos_hier_ver%NOTFOUND) THEN

            result := 'COMPLETE:N';
            l_valid := FALSE;

            /* =============== START DEBUG LOG ================ */
               DEBUG_LOG_STRING (l_proc_level, 'PositionInHierarchy.Msg8',
                                 'result --> ' || result || ' and l_valid --> FALSE ');
            /* =============== END DEBUG LOG ================== */

         ELSE

            Wf_Engine.SetItemAttrText (itemtype => ItemType,
                                       itemkey  => ItemKey,
                                       aname    => 'POS_STRUCTURE_VERSION_ID',
                                       avalue   => l_hierarchy_version_id);

            /* =============== START DEBUG LOG ================ */
               DEBUG_LOG_STRING (l_proc_level, 'PositionInHierarchy.Msg9',
                                 ' SetItemAttrText  POS_STRUCTURE_VERSION_ID --> ' ||l_hierarchy_version_id);
            /* =============== END DEBUG LOG ================== */

            l_valid := TRUE;

            /* =============== START DEBUG LOG ================ */
               DEBUG_LOG_STRING (l_proc_level, 'PositionInHierarchy.Msg10',
                                 ' l_valid --> TRUE ');
            /* =============== END DEBUG LOG ================== */

         END IF;

         IF (c_pos_hier_ver%ISOPEN) THEN
            CLOSE c_pos_hier_ver;
         END IF;

      END IF;

      IF l_valid THEN

         -- Check if Postion eixsts in Hierarchy
         OPEN c_is_pos_in_hier(l_business_group_id,
                               l_hierarchy_version_id,
                               l_position_id);
         FETCH c_is_pos_in_hier INTO l_pos_structure_element_id;

         /* =============== START DEBUG LOG ================ */
            DEBUG_LOG_STRING (l_proc_level, 'PositionInHierarchy.Msg11',
                              ' check if Postion eixsts in Hierarchy ' ||
                              ' l_business_group_id --> ' || l_business_group_id ||
                              ' l_hierarchy_version_id --> ' || l_hierarchy_version_id ||
                              ' l_position_id --> ' || l_position_id);
           DEBUG_LOG_STRING (l_proc_level, 'PositionInHierarchy.Msg12',
                              ' l_pos_structure_element_id --> ' || l_pos_structure_element_id);
         /* =============== END DEBUG LOG ================== */

         IF (c_is_pos_in_hier%NOTFOUND) THEN
            l_valid := FALSE;
         ELSE
            l_valid := TRUE;
         END IF;

         IF (c_is_pos_in_hier%ISOPEN) THEN
            CLOSE c_is_pos_in_hier;
         END IF;

      END IF;

      IF l_valid THEN
         result := 'COMPLETE:Y';
      ELSE
         result := 'COMPLETE:N';
      END IF;

     /* =============== START DEBUG LOG ================ */
        DEBUG_LOG_STRING (l_proc_level, 'PositionInHierarchy.Msg13',
                          ' result --> ' || result);
        DEBUG_LOG_STRING (l_proc_level, 'PositionInHierarchy.Msg14',
                          ' ** END POSITIONINHIERARCHY ** ');
     /* =============== END DEBUG LOG ================== */

   EXCEPTION
      WHEN OTHERS THEN
           /* =============== START DEBUG LOG ================ */
              DEBUG_LOG_UNEXP_ERROR ('PositionInHierarchy.Unexp1','DEFAULT');
           /* =============== END DEBUG LOG ================== */
           result := NULL;
           RAISE;

 END PositionInHierarchy;

END igidosl;


/
