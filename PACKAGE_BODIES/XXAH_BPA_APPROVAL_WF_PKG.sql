--------------------------------------------------------
--  DDL for Package Body XXAH_BPA_APPROVAL_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXAH_BPA_APPROVAL_WF_PKG" AS
/**************************************************************************
 * VERSION      : $Id: XXAH_BPA_APPROVAL_WF_PKG.pkb 48 2014-12-03 10:30:01Z marc.smeenge@oracle.com $
 * DESCRIPTION  : Contains functionality for the approval workflow.
 *
 * CHANGE HISTORY
 * ==============
 *
 * Date        Authors           Change reference/Description
 * ----------- ----------------- ----------------------------------
 * 21-JAN-2011 Richard Velden    Initial
 * 11-MAR-2011 Richard Velden    Parallelization added to PostNtfFunction
 * 25-MAR-2011 Richard Velden    Attachment name not passed correctly: Now opens in new window
 * 13-DEC-2011 Fabian Aulkemeier Changes in the approval report
 * 13-DEC-2011 Fabian Aulkemeier Added header table to display activation
 *                               and expiration date in approval report
 * 04-FEB-2013 A Hadimoeljono    Changes in CURSOR c_header_details
 *                               in PROCEDURE set_transaction_details
 *************************************************************************/

-- ----------------------------------------------------------------------
-- Private types
-- ----------------------------------------------------------------------
  TYPE employeerecord IS RECORD(
     user_id   fnd_user.user_id%TYPE
    ,user_name fnd_user.user_name%TYPE
    ,person_id per_all_people_f.person_id%TYPE
    ,full_name per_all_people_f.full_name%TYPE
    );
  --
  nullemployeerecord employeerecord;
-- -----------------------------------------------Estimated Savings-----------------------
-- Private constants
-- ----------------------------------------------------------------------
    -- Read the profile option that enables/disables the debug log
  g_po_wf_debug VARCHAR2(1) := NVL(fnd_profile.VALUE('PO_SET_DEBUG_WORKFLOW_ON'),'N');
  --
  gc_application_id    NUMBER         := 201;	-- TODO
  gc_transaction_type  VARCHAR2(100)  := 'XXAH Blanket Purchase Agreement';


  /* Child workflow names */
  gc_child_itemtype CONSTANT VARCHAR2(200) := 'XXAHBPAA';
  gc_child_process  CONSTANT VARCHAR2(200) := 'XXAH_BPA_APPRV_MAIN';

-- ----------------------------------------------------------------------
-- Private variables
-- ----------------------------------------------------------------------


-- ----------------------------------------------------------------------
-- Private cursors
-- ----------------------------------------------------------------------
CURSOR c_ntf_attachments (p_header_id    IN VARCHAR2
                         ) IS
    SELECT ROWNUM
          ,fd_l.media_id
          ,fdct_l.user_name
          ,fd_l.file_name file_name
          ,fl_l.file_content_type
          ,fl_l.file_data
    FROM   fnd_attached_documents fad_l
          ,fnd_documents fd_l
          ,fnd_document_categories_tl fdct_l
          ,fnd_lobs fl_l
          ,fnd_doc_category_usages_vl fdu
    WHERE  fad_l.document_id = fd_l.document_id
      AND  fd_l.media_id = fl_l.file_id
	  AND fd_l.category_id = fdct_l.category_id(+)
      AND  fdct_l.category_id = fdu.category_id(+)
      AND (
        (function_name = 'inbox'
          AND fad_l.entity_name = 'PO_HEADERS'
          AND  p_header_id = fad_l.pk1_value
        )
        OR
        ( fad_l.entity_name = 'OKC_CONTRACT_DOCS'
          AND fad_l.pk1_value = 'PA_BLANKET'
          AND fad_l.pk2_value = p_header_id
        )
      )
    ;
    CURSOR c_po(b_header_id po_headers_all.po_header_id%TYPE)
    IS
    SELECT nvl(phf.combined_bpa_va_approval,'N') combined
    FROM   po_headers_all pha
    ,      po_headers_all_dfv phf
    WHERE  phf.row_id = pha.rowid
    AND    pha.po_header_id = b_header_id
    AND    pha.revision_num = '0'
    ;

-- ----------------------------------------------------------------------
-- Private exceptions
-- ----------------------------------------------------------------------

-- ----------------------------------------------------------------------
-- Forward declarations
-- ----------------------------------------------------------------------

-- ----------------------------------------------------------------------
-- Private subprograms
-- ----------------------------------------------------------------------
  PROCEDURE write_log
    (p_message IN VARCHAR2 DEFAULT NULL
    ,p_module IN VARCHAR2
    ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    fnd_log.STRING
    ( LOG_LEVEL => fnd_log.LEVEL_STATEMENT
    , MODULE    => p_module
    , MESSAGE   => to_char(systimestamp, 'HH24:MI:SS.FF2 ') || p_message
    );
  END write_log;


  PROCEDURE write_log
    (p_message IN VARCHAR2 DEFAULT NULL
    ) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    write_log( p_message, 'xxah_bpa_approval_wf_pkg' );
  END write_log;


  --
  /*
    Retrieves employee information for the specified user.
  */
  PROCEDURE get_employee_info_for_user(p_user_id  IN NUMBER
                                      ,p_employee OUT NOCOPY employeerecord) IS
  BEGIN

    p_employee := nullemployeerecord;

    SELECT USERS.user_id
          ,USERS.user_name
          ,emp.person_id
          ,emp.full_name
      INTO p_employee.user_id
          ,p_employee.user_name
          ,p_employee.person_id
          ,p_employee.full_name
      FROM pon_employees_current_v emp
          ,fnd_user                USERS
     WHERE emp.person_id = USERS.employee_id
       AND USERS.user_id = p_user_id
       AND USERS.start_date <= SYSDATE
       AND nvl(USERS.end_date, SYSDATE) >= SYSDATE;

  EXCEPTION
    WHEN no_data_found OR too_many_rows THEN
      NULL;
  END get_employee_info_for_user;

  /*
    Retrieves employee information for the specified user.
  */
  PROCEDURE get_employee_info_for_user(p_user_name IN VARCHAR2
                                      ,p_employee  OUT NOCOPY employeerecord) IS
  BEGIN

      p_employee := nullemployeerecord;

      SELECT USERS.user_id
            ,USERS.user_name
            ,emp.person_id
            ,emp.full_name
        INTO p_employee.user_id
            ,p_employee.user_name
            ,p_employee.person_id
            ,p_employee.full_name
        FROM pon_employees_current_v emp
            ,fnd_user                USERS
       WHERE emp.person_id = USERS.employee_id
         AND USERS.user_name = p_user_name
         AND USERS.start_date <= SYSDATE
         AND nvl(USERS.end_date, SYSDATE) >= SYSDATE;

    EXCEPTION
      WHEN no_data_found OR too_many_rows THEN
        NULL;
    END get_employee_info_for_user;
  --
  --------------------------------------------------------------------------------
  --Start of Comments
  --Name: UpdateActionHistory
  --Pre-reqs:
  --  None.
  --Modifies:
  --  None.
  --Locks:
  --  None.
  --Function:
  --  This procedure updates the po_action_history table based on the approvers response.
  --Parameters:
  --IN:
  --  p_document_id : PO Header Id
  --  p_action : Action
  --  p_note : Notes
  --  p_current_approver: Approver person Id
  --OUT:
  --
  --End of Comments
  -------------------------------------------------------------------------------
  PROCEDURE updateactionhistory(p_document_id      NUMBER
                               ,p_action           VARCHAR2
                               ,p_note             VARCHAR2
                               ,p_current_approver NUMBER) IS
    --PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN

    IF (p_current_approver IS NOT NULL) THEN

      UPDATE po_action_history
         SET action_code = p_action, note = p_note, action_date = SYSDATE
       WHERE object_id = p_document_id
         AND employee_id = p_current_approver
            -- AND action_code IS NULL
         AND object_type_code = 'PO'
         AND ROWNUM = 1;

    ELSE

      UPDATE po_action_history
         SET action_code = p_action, note = p_note, action_date = SYSDATE
       WHERE object_id = p_document_id
         AND action_code IS NULL
         AND object_type_code = 'PO';
    END IF;

    COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END updateactionhistory;
-- ----------------------------------------------------------------------
-- Public subprograms
-- ----------------------------------------------------------------------
 /**************************************************************************
   *
   * PROCEDURE
   *   is_approval_complete
   *
   * DESCRIPTION
   *   Fetches the next set of approvers (if any) by calling
   *   ame_api2.getNextApprovers4.
   *   Returns whether the transaction approval process is complete or not.
   *
   * PARAMETERS
   * ==========
   * NAME              TYPE           DESCRIPTION
   * ----------------- -------------  --------------------------------------
   * p_itemtype        IN             The internal name for the item type.
   * p_itemkey         IN             A string that represents a primary key
   *                                  generated by the workflow-enabled
   *                                  application for the item type. The string
   *                                  uniquely identifies the item within an
   *                                  item type.
   * p_actid           IN             The ID number of the activity from which
   *                                  this procedure is called.
   * p_funcmode        IN             The execution mode of the activity.
   * p_resultout       OUT            If a result type is specified in the
   *                                  Activities properties page for the
   *                                  activity in the Oracle Workflow Builder,
   *                                  this parameter represents the expected
   *                                  result that is returned when the procedure
   *                                  completes.
   *
   *************************************************************************/
  PROCEDURE is_approval_complete ( p_itemtype   IN   VARCHAR2
                                 , p_itemkey    IN   VARCHAR2
                                 , p_actid      IN   NUMBER
                                 , p_funcmode   IN   VARCHAR2
                                 , p_resultout  OUT  VARCHAR2
                                 ) IS

    l_child_itemkey     VARCHAR2(100);
    l_transaction_id    VARCHAR2(100);
    l_revision_num      VARCHAR2(3);
    l_approval_complete VARCHAR2(1);
    l_approvers_tab     ame_util.approversTable2;
    l_user_id           NUMBER;
    l_user_name         fnd_user.user_name%TYPE;
    l_item_key_count    NUMBER :=0;


  BEGIN
    --
    IF  (p_funcmode <> wf_engine.eng_run)
    AND (p_funcmode <> wf_engine.eng_timeout) THEN
      p_resultout := wf_engine.eng_null;
      RETURN;
    END IF;
    --
    --
    write_log('begin is_approval_complete','xxah_va_ame_wf_pkg.is_approval_complete');
   -- 1. Call the AME API procedure to get the next set of approvers to notify.

   -- TODO: other id?
   l_transaction_id := wf_engine.GetItemAttrNumber
                       ( itemType => p_itemtype
                       , itemKey  => p_itemkey
                       , aName    => 'DOCUMENT_ID'
                        );
   --
   l_revision_num := wf_engine.GetItemAttrNumber
                       ( itemType => p_itemtype
                       , itemKey  => p_itemkey
                       , aName    => 'REVISION_NUMBER'
                       );
   --
   l_transaction_id := l_transaction_id ||'#'||l_revision_num;
   --
   ame_api2.getNextApprovers4
   ( applicationIdIn              => gc_application_id
   , transactionTypeIn            => gc_transaction_type
   , transactionIdIn              => l_transaction_id
   , flagApproversAsNotifiedIn    => ame_util.booleanFalse	-- NOT NOTIFIED: Just a list to check l_approvalcomplete
   , approvalProcessCompleteYNOut => l_approval_complete
   , nextApproversOut             => l_approvers_tab
   );
   --
   IF l_approval_complete = ame_util.booleanTrue THEN
       p_resultout := 'COMPLETE:Y';
       RETURN;
   END IF;

   -- No new approvers yet, wait a little bit more
   IF  l_approvers_tab.count = 0
   AND l_approval_complete = ame_util.booleanFalse
   THEN
       p_resultout := 'COMPLETE:N';
       RETURN;
   END IF;
   --
   write_log('p_resultout: '||p_resultout,'xxah_va_ame_wf_pkg.is_approval_complete');
   write_log('number of approvers in next level: '||l_approvers_tab.count,'xxah_va_ame_wf_pkg.is_approval_complete');
   --
   p_resultout := 'COMPLETE:N';
   write_log('end is_approval_complete','xxah_va_ame_wf_pkg.is_approval_complete');
  END is_approval_complete;


/**************************************************************************
   *
   * PROCEDURE
   *   has_next_approvers
   *
   * DESCRIPTION
   *   Fetches the next set of approvers (if any) by calling
   *   ame_api2.getNextApprovers4.
   *
   *   Returns whether there are any next approvers or not.
   *
   * PARAMETERS
   * ==========
   * NAME              TYPE           DESCRIPTION
   * ----------------- -------------  --------------------------------------
   * p_itemtype        IN             The internal name for the item type.
   * p_itemkey         IN             A string that represents a primary key
   *                                  generated by the workflow-enabled
   *                                  application for the item type. The string
   *                                  uniquely identifies the item within an
   *                                  item type.
   * p_actid           IN             The ID number of the activity from which
   *                                  this procedure is called.
   * p_funcmode        IN             The execution mode of the activity.
   * p_resultout       OUT            If a result type is specified in the
   *                                  Activities properties page for the
   *                                  activity in the Oracle Workflow Builder,
   *                                  this parameter represents the expected
   *                                  result that is returned when the procedure
   *                                  completes.
   *
   *************************************************************************/
  PROCEDURE has_next_approvers( p_itemtype   IN   VARCHAR2
                              , p_itemkey    IN   VARCHAR2
                              , p_actid      IN   NUMBER
                              , p_funcmode   IN   VARCHAR2
                              , p_resultout  OUT  VARCHAR2
                              ) IS
    --
    l_progress          VARCHAR2(100) := '000';
    l_child_itemkey     VARCHAR2(100);
    l_transaction_id    VARCHAR2(100);
    l_revision_num      VARCHAR2(3);
    l_approval_complete VARCHAR2(1);
    l_approvers_tab     ame_util.approversTable2;
    l_user_id           NUMBER;
    l_user_name         fnd_user.user_name%TYPE;
    l_item_key_count    NUMBER :=0;
    --
  BEGIN
    --
    IF  (p_funcmode <> wf_engine.eng_run)
    AND (p_funcmode <> wf_engine.eng_timeout) THEN
      p_resultout := wf_engine.eng_null;
      RETURN;
    END IF;
    --
    --
    l_progress := 'begin has_next_approvers';
    write_log(l_progress,'xxah_va_ame_wf_pkg.has_next_approvers');
    -- 1. Call the AME API procedure to get the next set of approvers to notify.
    l_transaction_id := wf_engine.GetItemAttrNumber
                        ( itemType => p_itemtype
                        , itemKey  => p_itemkey
                        , aName    => 'DOCUMENT_ID'
                        );
    --
    l_revision_num := wf_engine.GetItemAttrNumber
                        ( itemType => p_itemtype
                        , itemKey  => p_itemkey
                        , aName    => 'REVISION_NUMBER'
                        );
   --
   l_transaction_id := l_transaction_id ||'#'||l_revision_num;
   --
   l_progress := 'get next approvers for transaction_id = '||l_transaction_id;
   write_log(l_progress,'xxah_va_ame_wf_pkg.has_next_approvers');
   --
   ame_api2.getNextApprovers4
    ( applicationIdIn              => gc_application_id
    , transactionTypeIn            => gc_transaction_type
    , transactionIdIn              => l_transaction_id
    , flagApproversAsNotifiedIn    => ame_util.booleanFalse	-- NOT NOTIFIED: Just a list to check l_approvalcomplete
    , approvalProcessCompleteYNOut => l_approval_complete
    , nextApproversOut             => l_approvers_tab
    );
    --
    write_log('After get next approvers','xxah_va_ame_wf_pkg.has_next_approvers');
    write_log('number of approvers in next level: '||l_approvers_tab.count,'xxah_va_ame_wf_pkg.has_next_approvers');

    IF l_approvers_tab.COUNT > 0 THEN
      p_resultout := 'COMPLETE:YES';
    ELSE
      --RAISE no_approvers;
      p_resultout := 'COMPLETE:NO';
    END IF;
    --
    l_progress := 'p_resultout: '||p_resultout;
    write_log(l_progress,'xxah_va_ame_wf_pkg.has_next_approvers');
    write_log('end is_approval_complete','xxah_va_ame_wf_pkg.has_next_approvers');
    --
    --p_resultout := 'COMPLETE:Y';
  EXCEPTION
    WHEN OTHERS THEN
        -- Set AME_ERROR_MESSAGE to SQLERRM
        wf_engine.SetItemAttrText
        ( itemType => p_itemtype
        , itemKey  => p_itemkey
        , aName    => 'XXAH_AME_ERROR'
        , aValue   => SQLERRM
        );

        p_resultout := 'COMPLETE:ERROR';
  END has_next_approvers;

/**************************************************************************
   *
   * PROCEDURE
   *   create_addhoc_role
   *
   * DESCRIPTION
   *   TODO
   *
   *   Returns TODO
   *
   * PARAMETERS
   * ==========
   * NAME              TYPE           DESCRIPTION
   * ----------------- -------------  --------------------------------------
   * p_itemtype        IN             The internal name for the item type.
   * p_itemkey         IN             A string that represents a primary key
   *                                  generated by the workflow-enabled
   *                                  application for the item type. The string
   *                                  uniquely identifies the item within an
   *                                  item type.
   * p_actid           IN             The ID number of the activity from which
   *                                  this procedure is called.
   * p_funcmode        IN             The execution mode of the activity.
   * p_resultout       OUT            If a result type is specified in the
   *                                  Activities properties page for the
   *                                  activity in the Oracle Workflow Builder,
   *                                  this parameter represents the expected
   *                                  result that is returned when the procedure
   *                                  completes.
   *
   *************************************************************************/
  PROCEDURE create_addhoc_role( p_itemtype   IN   VARCHAR2
                              , p_itemkey    IN   VARCHAR2
                              , p_actid      IN   NUMBER
                              , p_funcmode   IN   VARCHAR2
                              , p_resultout  OUT  VARCHAR2
                              ) IS
    --
    l_child_itemkey     VARCHAR2(100);
    l_transaction_id    VARCHAR2(100);
    l_approval_complete VARCHAR2(1);
    l_approvers_tab     ame_util.approversTable2;
    l_user_id           NUMBER;
    l_user_name         fnd_user.user_name%TYPE;
    l_item_key_count    NUMBER :=0;
    --
    l_role_name           VARCHAR2(50)  := 'XXAHBLANKET';
    l_role_display_name   VARCHAR2(100) := 'XXAH AdHoc role for Blanket ';
    l_wf_user             Wf_Directory.UserTable;
    l_revision_num        VARCHAR2(10);
    l_dummy NUMBER;
    --
  BEGIN
    IF  (p_funcmode <> wf_engine.eng_run)
    AND (p_funcmode <> wf_engine.eng_timeout) THEN
      p_resultout := wf_engine.eng_null;
      RETURN;
    END IF;
    --
    write_log('begin create_addhoc_role','xxah_va_ame_wf_pkg.create_addhoc_role');
    -- 1. Call the AME API procedure to get the next set of approvers to notify.

    -- create_addhoc_role
    l_transaction_id := wf_engine.GetItemAttrNumber
                        ( itemType => p_itemtype
                        , itemKey  => p_itemkey
                        , aName    => 'DOCUMENT_ID'
                        );
    --
    l_revision_num := wf_engine.GetItemAttrNumber
                        ( itemType => p_itemtype
                        , itemKey  => p_itemkey
                        , aName    => 'REVISION_NUMBER'
                        );
    --
    l_role_name := l_role_name||'_'||l_transaction_id;
    l_role_display_name := l_role_display_name||'_'||l_transaction_id;
    --
    --add revision number here after setting the role namen, since the role does not have the revision num included
    l_transaction_id := l_transaction_id ||'#'||l_revision_num;
    /******/
    l_role_display_name := wf_directory.GetRoleDisplayName(p_role_name => l_role_name );
    write_log('role disp name: ' || l_role_display_name ,'xxah_va_ame_wf_pkg.create_addhoc_role');
    --
    IF l_role_display_name IS NULL THEN
      write_log( 'role does not yet exist.. creating' ,'xxah_va_ame_wf_pkg.create_addhoc_role');
      --
      wf_directory.CreateAdHocRole(role_name => l_role_name
                                 , role_display_name => l_role_display_name
                             --  , language => -- optional
                             --  , territory => -- optional
                             --  , role_description => -- optional
                             --  , notification_preference => -- optional
                             --  , role_users => -- optional?
                             --  , email_address => -- optional
                             --  , fax => -- optional
                             --  , status => -- optional
                             --  , expiration_date => -- optional?
                             --  , parent_orig_system => -- optional
                             --  , parent_orig_system_id => -- optional
                             --  , owner_tag => -- optional
                                 );
      --
    ELSE
      write_log( 'role already exists.. remove previous users from role!','xxah_va_ame_wf_pkg.create_addhoc_role' );
      --
      Wf_Directory.GetRoleUsers(ROLE =>  l_role_name
                               ,USERS => l_wf_user
                               );
      --
      FOR indx IN 1 .. l_wf_user.COUNT
        LOOP
          write_log('removing user: ' || l_wf_user(indx),'xxah_va_ame_wf_pkg.create_addhoc_role' );
          --
          Wf_Directory.RemoveUsersFromAdHocRole(role_name  => l_role_name
                                               ,role_users => l_wf_user(indx)
                                               );
        END LOOP;
        --
    END IF;
    --
    -- Role is empty (newly created or removed users - now add users
    ame_api2.getNextApprovers4
      ( applicationIdIn              => gc_application_id
      , transactionTypeIn            => gc_transaction_type
      , transactionIdIn              => l_transaction_id
      , flagApproversAsNotifiedIn    => ame_util.booleanTrue
      , approvalProcessCompleteYNOut => l_approval_complete
      , nextApproversOut             => l_approvers_tab
      );
    --
    FOR indx IN 1 .. l_approvers_tab.COUNT
      LOOP
        write_log( 'adding user: ' || l_approvers_tab(indx).NAME,'xxah_va_ame_wf_pkg.create_addhoc_role' );

        WF_DIRECTORY.AddUsersToAdHocRole(
            role_name  =>    l_role_name
          , role_users => l_approvers_tab(indx).NAME
          );
      END LOOP;
    --
    wf_engine.SetItemAttrText
        ( itemType => p_itemtype
        , itemKey  => p_itemkey
        , aName    => 'XXAH_ADHOC_ROLE_NAME'
        , aValue   => l_role_name
        );
    /******/
    p_resultout := 'COMPLETE:Y';
    write_log('end create_addhoc_role','xxah_va_ame_wf_pkg.create_addhoc_role');
    RETURN;
  END create_addhoc_role;


/**************************************************************************
   *
   * PROCEDURE
   *   add_approvers_to_role
   *
   * DESCRIPTION
   *   TODO
   *
   *   Returns TODO
   *
   * PARAMETERS
   * ==========
   * NAME              TYPE           DESCRIPTION
   * ----------------- -------------  --------------------------------------
   * p_itemtype        IN             The internal name for the item type.
   * p_itemkey         IN             A string that represents a primary key
   *                                  generated by the workflow-enabled
   *                                  application for the item type. The string
   *                                  uniquely identifies the item within an
   *                                  item type.
   * p_actid           IN             The ID number of the activity from which
   *                                  this procedure is called.
   * p_funcmode        IN             The execution mode of the activity.
   * p_resultout       OUT            If a result type is specified in the
   *                                  Activities properties page for the
   *                                  activity in the Oracle Workflow Builder,
   *                                  this parameter represents the expected
   *                                  result that is returned when the procedure
   *                                  completes.
   *
   *************************************************************************/
  PROCEDURE add_approvers_to_role( p_itemtype   IN   VARCHAR2
                                 , p_itemkey    IN   VARCHAR2
                                 , p_actid      IN   NUMBER
                                 , p_funcmode   IN   VARCHAR2
                                 , p_resultout  OUT  VARCHAR2
                                 ) IS

    l_child_itemkey     VARCHAR2(100);
    l_transaction_id    VARCHAR2(100);
    l_revision_num      VARCHAR2(3);
    l_approval_complete VARCHAR2(1);
    l_approvers_tab     ame_util.approversTable2;
    l_user_id           NUMBER;
    l_user_name         fnd_user.user_name%TYPE;
    l_item_key_count    NUMBER :=0;
    l_role_name           VARCHAR2(50); --  := 'XXRVELDENTEST001';
    --  l_role_display_name   VARCHAR2(100) := 'Test Role For Dynamic AME Approval Lists';
    l_wf_user             Wf_Directory.UserTable;
    l_dummy NUMBER;
    --
  BEGIN
    IF  (p_funcmode <> wf_engine.eng_run)
    AND (p_funcmode <> wf_engine.eng_timeout) THEN
      p_resultout := wf_engine.eng_null;
      RETURN;
    END IF;
    --
    write_log('begin add_approvers_to_role','xxah_va_ame_wf_pkg.add_approvers_to_role');
    -- 1. Call the AME API procedure to get the next set of approvers to notify.
    -- TODO: retrieve add hoc role name
    l_role_name := wf_engine.GetItemAttrText
                        ( itemType => p_itemtype
                        , itemKey  => p_itemkey
                        , aName    => 'XXAH_ADHOC_ROLE_NAME'
                         );

    -- TODO: Retrieve transaction_id
    l_transaction_id := wf_engine.GetItemAttrNumber
                        ( itemType => p_itemtype
                        , itemKey  => p_itemkey
                        , aName    => 'DOCUMENT_ID'
                         );
    --
    l_revision_num := wf_engine.GetItemAttrNumber
                        ( itemType => p_itemtype
                        , itemKey  => p_itemkey
                        , aName    => 'REVISION_NUMBER'
                        );
    --
    l_transaction_id := l_transaction_id ||'#'||l_revision_num;
    --
    -- TODO fetch approvers from AME
    ame_api2.getNextApprovers4
       ( applicationIdIn              => gc_application_id
       , transactionTypeIn            => gc_transaction_type
       , transactionIdIn              => l_transaction_id
       , flagApproversAsNotifiedIn    => ame_util.booleanTrue
       , approvalProcessCompleteYNOut => l_approval_complete
       , nextApproversOut             => l_approvers_tab
       );
    /******/
    write_log( 'adding users to role!','xxah_va_ame_wf_pkg.add_approvers_to_role' );

    FOR indx IN 1 .. l_approvers_tab.COUNT
    LOOP
      write_log( 'adding user: ' || l_approvers_tab(indx).NAME ,'xxah_va_ame_wf_pkg.add_approvers_to_role');
      --
      WF_DIRECTORY.AddUsersToAdHocRole(
          role_name =>    l_role_name
        , role_users => l_approvers_tab(indx).NAME
        );
    END LOOP;
   /******/
    p_resultout := 'COMPLETE:Y';
    write_log('end add_approvers_to_role','xxah_va_ame_wf_pkg.add_approvers_to_role');
    RETURN;
  END add_approvers_to_role;


/**************************************************************************
   *
   * PROCEDURE
   *   reset_approval
   *
   * DESCRIPTION
   *   reset the approval of the transaction.
   *
   * PARAMETERS
   * ==========
   * NAME              TYPE           DESCRIPTION
   * ----------------- -------------  --------------------------------------
   * p_itemtype        IN             The internal name for the item type.
   * p_itemkey         IN             A string that represents a primary key
   *                                  generated by the workflow-enabled
   *                                  application for the item type. The string
   *                                  uniquely identifies the item within an
   *                                  item type.
   * p_actid           IN             The ID number of the activity from which
   *                                  this procedure is called.
   * p_funcmode        IN             The execution mode of the activity.
   * p_resultout       OUT            If a result type is specified in the
   *                                  Activities properties page for the
   *                                  activity in the Oracle Workflow Builder,
   *                                  this parameter represents the expected
   *                                  result that is returned when the procedure
   *                                  completes.
   *
   * PREREQUISITES
   *   List prerequisites to be satisfied
   *
   * CALLED BY
   *   List caller of this procedure
   *
   *************************************************************************/
  PROCEDURE reset_approval
  ( p_itemtype   IN   VARCHAR2
  , p_itemkey    IN   VARCHAR2
  , p_actid      IN   NUMBER
  , p_funcmode   IN   VARCHAR2
  , p_resultout  OUT  VARCHAR2
  ) IS
    l_transaction_id    VARCHAR2(100);
    l_revision_num      VARCHAR2(100);
  BEGIN
   IF  (p_funcmode <> wf_engine.eng_run)
   AND (p_funcmode <> wf_engine.eng_timeout) THEN
     p_resultout := wf_engine.eng_null;
     RETURN;
   END IF;
   --
   write_log('begin reset_approval','xxah_va_ame_wf_pkg.reset_approval');

-- other application / transaction type
    l_transaction_id := wf_engine.GetItemAttrNumber
                       ( itemType => p_itemtype
                       , itemKey  => p_itemkey
                       , aName    => 'DOCUMENT_ID'
                       );

--
   l_revision_num := wf_engine.GetItemAttrNumber
                       ( itemType => p_itemtype
                       , itemKey  => p_itemkey
                       , aName    => 'REVISION_NUMBER'
                       );
   --
   l_transaction_id := l_transaction_id ||'#'||l_revision_num;

    write_log('l_transaction_id:' || l_transaction_id,'xxah_va_ame_wf_pkg.reset_approval');
    ame_api2.clearAllApprovals
      ( applicationIdIn   => gc_application_id
      , transactionTypeIn => gc_transaction_type
      , transactionIdIn   => l_transaction_id
      );
     write_log('end reset_approval','xxah_va_ame_wf_pkg.reset_approval');
  END reset_approval;




/**************************************************************************
   *
   * PROCEDURE
   *   launch_child_flow
   *
   * DESCRIPTION
   *   Launch a child approval workflow
   *    Notifies the next approver(s)
   *
   * PARAMETERS
   * ==========
   * NAME              TYPE           DESCRIPTION
   * ----------------- -------------  --------------------------------------
   * p_itemtype        IN             The internal name for the item type.
   * p_itemkey         IN             A string that represents a primary key
   *                                  generated by the workflow-enabled
   *                                  application for the item type. The string
   *                                  uniquely identifies the item within an
   *                                  item type.
   * p_actid           IN             The ID number of the activity from which
   *                                  this procedure is called.
   * p_funcmode        IN             The execution mode of the activity.
   * p_resultout       OUT            If a result type is specified in the
   *                                  Activities properties page for the
   *                                  activity in the Oracle Workflow Builder,
   *                                  this parameter represents the expected
   *                                  result that is returned when the procedure
   *                                  completes.
   *
   * PREREQUISITES
   *   List prerequisites to be satisfied
   *
   * CALLED BY
   *   List caller of this procedure
   *
   *************************************************************************/
  PROCEDURE launch_child_flow
  ( p_itemtype   IN   VARCHAR2
  , p_itemkey    IN   VARCHAR2
  , p_actid      IN   NUMBER
  , p_funcmode   IN   VARCHAR2
  , p_resultout  OUT  VARCHAR2
  )
  IS
    l_child_itemkey   VARCHAR2(200);
    l_child_counter   NUMBER;

    l_document_id    NUMBER;

  BEGIN
    IF  (p_funcmode <> wf_engine.eng_run)
    AND (p_funcmode <> wf_engine.eng_timeout) THEN
      p_resultout := wf_engine.eng_null;
      RETURN;
    END IF;
    --
    write_log('begin launch_child_flow','xxah_va_ame_wf_pkg.launch_child_flow');


    /* Get PO Header id from parent WF */
    l_document_id := wf_engine.GetItemAttrText
     ( itemType => p_itemtype
     , itemKey  => p_itemkey
     , aName    => 'DOCUMENT_ID'
    );

    l_child_itemkey := p_itemtype || ':' || p_itemkey || '_';

    /* Find other child instances, create unique id */
    SELECT count(*) + 1
    INTO l_child_counter
    FROM wf_process_activities wpa
      LEFT JOIN wf_item_activity_statuses wias
      ON ( wpa.instance_id = wias.process_activity )
    WHERE process_item_type = 'XXAHBPAA'
      AND process_name = 'XXAH_BPA_APPRV_MAIN'
      AND wpa.activity_name = 'START'
      AND wias.item_key LIKE l_child_itemkey || '%'
      ;

    /* Append unique id to child item key */
    l_child_itemkey := l_child_itemkey || l_child_counter;


    wf_engine.createProcess
     ( itemType => gc_child_itemtype
     , itemKey  => l_child_itemkey
     , process  => gc_child_process
     );

    /* Set master item key */
    wf_engine.SetItemAttrText
     ( itemType => gc_child_itemtype
     , itemKey  => l_child_itemkey
     , aName    => 'XXAH_MASTER_ITEM_KEY'
     , aValue   => p_itemKey
    );

    /* Sets PO HEADER ID */
    wf_engine.SetItemAttrText
     ( itemType => gc_child_itemtype
     , itemKey  => l_child_itemkey
     , aName    => 'DOCUMENT_ID'
     , aValue   => l_document_id
    );

    /* JPE, Need to set the parent child relationship between processes */
    wf_engine.setitemparent(itemtype        => gc_child_itemtype
                           ,itemkey         => l_child_itemkey
                           ,parent_itemtype => p_itemtype
                           ,parent_itemkey  => p_itemkey
                           ,parent_context  => NULL);
    --
    /* Start Child Process */
    wf_engine.StartProcess
     ( itemType => gc_child_itemtype
     , itemKey  => l_child_itemkey
     );

    write_log('end launch_child_flow','xxah_va_ame_wf_pkg.launch_child_flow');
  END launch_child_flow;

  /**************************************************************************
   *
   * PROCEDURE
   *   complete_activity
   *
   * DESCRIPTION
   *   Completes Block activity of Master Workflow
   *
   * PARAMETERS
   * ==========
   * NAME              TYPE           DESCRIPTION
   * ----------------- -------------  --------------------------------------
   * p_itemtype        IN             The internal name for the item type.
   * p_itemkey         IN             A string that represents a primary key
   *                                  generated by the workflow-enabled
   *                                  application for the item type. The string
   *                                  uniquely identifies the item within an
   *                                  item type.
   * p_actid           IN             The ID number of the activity from which
   *                                  this procedure is called.
   * p_funcmode        IN             The execution mode of the activity.
   * p_resultout       OUT            If a result type is specified in the
   *                                  Activities properties page for the
   *                                  activity in the Oracle Workflow Builder,
   *                                  this parameter represents the expected
   *                                  result that is returned when the procedure
   *                                  completes.
   *
   * PREREQUISITES
   *   List prerequisites to be satisfied
   *
   * CALLED BY
   *   List caller of this procedure
   *
   *************************************************************************/
  PROCEDURE complete_activity
  ( p_itemtype   IN   VARCHAR2
  , p_itemkey    IN   VARCHAR2
  , p_actid      IN   NUMBER
  , p_funcmode   IN   VARCHAR2
  , p_resultout  OUT  VARCHAR2
  )
  IS
    l_master_item_key   VARCHAR2(200);
  BEGIN
    write_log('begin complete_activity','xxah_va_ame_wf_pkg.complete_activity');

    l_master_item_key := wf_engine.GetItemAttrText
                       ( itemType => p_itemtype
                       , itemKey  => p_itemkey
                       , aName    => 'XXAH_MASTER_ITEM_KEY'
                        );

    WF_ENGINE.CompleteActivity (
        itemtype => 'POAPPRV'
     ,  itemkey => l_master_item_key
     ,  activity => 'WAITFORAPPROVERS'
     ,  result => 'COMPLETE'   -- approvers response?
    );

    write_log('end complete_activity','xxah_va_ame_wf_pkg.complete_activity');
  END complete_activity;



-- PostNtfFunction
PROCEDURE PostNtfFunction(p_itemtype   IN varchar2,
                          p_itemkey    IN varchar2,
                          p_actid      IN number,
                          p_funcmode   IN varchar2,
                          p_resultout  IN OUT NOCOPY varchar2
                         ) IS

  -- Notification result check
  CURSOR c_ntf_result(p_nid NUMBER) IS
    SELECT  wfna.text_value
    FROM    wf_notifications wfn,
            wf_notification_attributes wfna
    WHERE   wfn.notification_id = p_nid
    AND     wfn.notification_id     = wfna.notification_id
    AND     wfna.NAME               = 'RESULT'
  ;

  -- Notification group result check
  CURSOR c_group_result( b_group_id   NUMBER
    , b_result VARCHAR2 )
  IS
    SELECT  COUNT(1) --wfna.text_value
    FROM    wf_notifications wfn,
            wf_notification_attributes wfna
    WHERE   1=1
    AND     wfn.group_id = b_group_id
    AND     wfn.notification_id     = wfna.notification_id
    AND     wfna.NAME               = 'RESULT'
    AND     wfna.text_value = b_result
  ;

  --
  l_group_id      PLS_INTEGER;
  l_user          varchar2(320);

  --
  l_transaction_id    VARCHAR2(100);
  l_revision_num      VARCHAR2(3);
  l_responder         VARCHAR2(100);
  v_response_reason   VARCHAR2(4000);

  --
  l_result            VARCHAR2(100);
  l_count_rejected    NUMBER;
  l_count_forwarded   NUMBER;
  --
  v_itemkey wf_items.item_key%TYPE;
  v_doc_num VARCHAR2(2000);
  v_transaction_id    VARCHAR2(100);
  v_user_name VARCHAR2(2000);
  --
BEGIN
  write_log('funcmode='||p_funcmode,'xxah_bpa_approval_wf_pkg.PostNtfFunction');
  write_log( 'context_user: ' || WF_ENGINE.context_user );
  write_log( 'context_recipient_role: ' || WF_ENGINE.context_recipient_role );
  write_log( 'context_original_recipient: ' || WF_ENGINE.context_original_recipient );
  write_log( 'context_from_role: ' || WF_ENGINE.context_from_role );
  write_log( 'context_new_role: ' || WF_ENGINE.context_new_role );
  write_log( 'context_user_key: ' || WF_ENGINE.context_user_key );
  write_log( 'context_proxy: ' || WF_ENGINE.context_proxy );
  write_log( 'g_nid: ' || WF_ENGINE.g_nid );
  write_log( 'context_nid: ' || WF_ENGINE.context_nid );
  write_log( 'p_actid: ' || p_actid );
  write_log( 'p_funcmode: ' || p_funcmode );

  l_transaction_id := wf_engine.GetItemAttrNumber
                        ( itemType => p_itemtype
                        , itemKey  => p_itemkey
                        , aName    => 'DOCUMENT_ID'
                        );
  --
  l_revision_num := wf_engine.GetItemAttrNumber
                      ( itemType => p_itemtype
                      , itemKey  => p_itemkey
                      , aName    => 'REVISION_NUMBER'
                      );

  l_transaction_id := l_transaction_id ||'#'||l_revision_num;

  -- Get Notifications group_id for activity
  Wf_Item_Activity_Status.Notification_Status(p_itemtype,p_itemkey,p_actid,l_group_id,l_user);

  write_log( 'l_group_id: ' || l_group_id );
  write_log( 'l_user: ' || l_user );
  write_log( 'l_transaction_id: ' || l_transaction_id );


  IF( p_funcmode = 'RESPOND' )            -- RESPOND ACTIONS
  THEN
    l_responder := NVL(WF_ENGINE.context_original_recipient, WF_ENGINE.context_user);

    write_log('notification result getNtfResponse = ' );
    --
    OPEN c_ntf_result(WF_ENGINE.context_nid);
    FETCH c_ntf_result INTO l_result;
    IF c_ntf_result %NOTFOUND THEN
      l_result := '#NORESULT';
    END IF;
    CLOSE c_ntf_result;
    --
    write_log('notification result cursor = '||l_result );
    write_log('l_responder = '||l_responder );


    -- Mandatory reject_reason when response is REJECT
    v_response_reason := wf_notification.getattrtext(wf_engine.context_nid
                                                    ,'XXAH_REJECT_REASON');
    IF l_result = 'REJECT' AND
       v_response_reason IS NULL
    THEN
      p_resultout := 'ERROR: You must enter rejection reason if rejecting.';
      RETURN;
    END IF;
    -- End madatory reject reason check


    write_log('call ame update approval status ');
    ame_api2.updateApprovalStatus2
      ( applicationIdIn   => gc_application_id
      , transactionTypeIn => gc_transaction_type
      , transactionIdIn   => l_transaction_id      -- PO HEADER ID
      , approvalStatusIn  => l_result
      , approverNameIn    => l_responder
    );
    write_log('ame done');

    -- Setting FORWARD_FROM_USER_NAME equal to current responder
    wf_engine.SetItemAttrText
                (p_ItemType
                ,p_ItemKey
                ,'FORWARD_FROM_USER_NAME'
                ,l_responder);

    -- only send notification if not rejected...
    IF l_result <> 'REJECT' THEN
      v_itemkey := p_itemkey||'#XX#'||to_char(sysdate,'DDMMYYYYHH24:MI:SS');
      wf_engine.CreateProcess(p_itemtype, v_itemkey, 'XXAH_SEND_NOTIFICATION', WF_ENGINE.context_user_key);

      v_user_name := wf_engine.GetItemAttrText
                          ( itemType => p_itemtype
                          , itemKey  => p_itemkey
                          , aName    => 'PREPARER_USER_NAME'
                          );
      wf_engine.SetItemAttrText
                (p_ItemType
                ,v_ItemKey
                ,'PREPARER_USER_NAME'
                ,v_user_name);
      wf_engine.SetItemAttrText
                (p_ItemType
                ,v_ItemKey
                ,'FORWARD_FROM_USER_NAME'
                ,l_responder);
      wf_engine.SetItemAttrText
                (p_ItemType
                ,p_ItemKey
                ,'FORWARD_FROM_USER_NAME'
                ,l_responder);
      wf_engine.SetItemAttrDocument
                (p_ItemType
                ,v_ItemKey
                ,'PDF_ATTACHMENT_BUYER'
                ,wf_engine.GetItemAttrDocument(p_ItemType,p_ItemKey,'PDF_ATTACHMENT_BUYER',TRUE));
      wf_engine.SetItemAttrDocument
                (p_ItemType
                ,v_ItemKey
                ,'XXAH_ATT_1'
                ,wf_engine.GetItemAttrDocument(p_ItemType,p_ItemKey,'XXAH_ATT_1',TRUE));
      wf_engine.SetItemAttrDocument
                (p_ItemType
                ,v_ItemKey
                ,'XXAH_ATT_2'
                ,wf_engine.GetItemAttrDocument(p_ItemType,p_ItemKey,'XXAH_ATT_2',TRUE));
      wf_engine.SetItemAttrDocument
                (p_ItemType
                ,v_ItemKey
                ,'XXAH_ATT_3'
                ,wf_engine.GetItemAttrDocument(p_ItemType,p_ItemKey,'XXAH_ATT_3',TRUE));
      wf_engine.SetItemAttrDocument
                (p_ItemType
                ,v_ItemKey
                ,'XXAH_ATT_4'
                ,wf_engine.GetItemAttrDocument(p_ItemType,p_ItemKey,'XXAH_ATT_4',TRUE));
      wf_engine.SetItemAttrDocument
                (p_ItemType
                ,v_ItemKey
                ,'XXAH_ATT_5'
                ,wf_engine.GetItemAttrDocument(p_ItemType,p_ItemKey,'XXAH_ATT_5',TRUE));
      wf_engine.SetItemAttrDocument
                (p_ItemType
                ,v_ItemKey
                ,'XXAH_ATT_6'
                ,wf_engine.GetItemAttrDocument(p_ItemType,p_ItemKey,'XXAH_ATT_6',TRUE));
      wf_engine.SetItemAttrDocument
                (p_ItemType
                ,v_ItemKey
                ,'XXAH_ATT_7'
                ,wf_engine.GetItemAttrDocument(p_ItemType,p_ItemKey,'XXAH_ATT_7',TRUE));
      wf_engine.SetItemAttrDocument
                (p_ItemType
                ,v_ItemKey
                ,'XXAH_ATT_8'
                ,wf_engine.GetItemAttrDocument(p_ItemType,p_ItemKey,'XXAH_ATT_8',TRUE));
      wf_engine.SetItemAttrDocument
                (p_ItemType
                ,v_ItemKey
                ,'XXAH_ATT_9'
                ,wf_engine.GetItemAttrDocument(p_ItemType,p_ItemKey,'XXAH_ATT_9',TRUE));
      wf_engine.SetItemAttrDocument
                (p_ItemType
                ,v_ItemKey
                ,'XXAH_ATT_10'
                ,wf_engine.GetItemAttrDocument(p_ItemType,p_ItemKey,'XXAH_ATT_10',TRUE));

      v_doc_num := wf_engine.GetItemAttrText
                          ( itemType => p_itemtype
                          , itemKey  => p_itemkey
                          , aName    => 'DOCUMENT_NUMBER'
                          );
      wf_engine.SetItemAttrText
                (p_ItemType
                ,v_ItemKey
                ,'DOCUMENT_NUMBER'
                ,v_doc_num);
      v_transaction_id := wf_engine.GetItemAttrNumber
                          ( itemType => p_itemtype
                          , itemKey  => p_itemkey
                          , aName    => 'DOCUMENT_ID'
                          );
      wf_engine.SetItemAttrNumber
                (p_ItemType
                ,v_ItemKey
                ,'DOCUMENT_ID'
                ,v_transaction_id);
      wf_engine.SetItemAttrNumber
                (p_ItemType
                ,v_ItemKey
                ,'REVISION_NUMBER'
                ,l_revision_num);
      wf_engine.StartProcess(p_ItemType, v_ItemKey);
    END IF;
    --
    /* For RESPOND resultout is always eng_null */
    p_resultout := wf_engine.eng_null;
    write_log('RESPOND resultout NULL');

  ELSIF ( p_funcmode = wf_engine.eng_run )   -- RUN ACTIONS
  THEN
    write_log( 'RUN' );

    -- check for rejections:
    OPEN c_group_result( l_group_id, 'REJECT' );
    FETCH c_group_result INTO l_count_rejected;
    CLOSE c_group_result;

    IF l_count_rejected > 0
    THEN
      -- rejected entry found in notification group
      -- Other notifications will be cancelled automatically
      p_resultout := wf_engine.eng_completed || ':' || 'REJECT';
      write_log('From WRITE resultout rejected');
    ELSIF (wf_notification.OpenNotificationsExist(l_group_id))
    THEN
      p_resultout := wf_engine.eng_waiting;
      write_log('RUN: resultout waiting');
    ELSE
      -- No open notifications left AND No Rejections => APPROVE!
      write_log( 'RUN no open notifs no reject => APPROVE!' );
      p_resultout := wf_engine.eng_completed || ':' || 'APPROVE';
    END IF;


  ELSE
    write_log('p_funcmode ELSE ' || p_funcmode);
    p_resultout := wf_engine.eng_null;
  END IF;

  --
  -- SYNCHMODE: Not allowed
  IF (p_itemkey = wf_engine.eng_synch) THEN
    Wf_Core .Token('OPERATION', 'Wf_Standard.VotForResultType');
    Wf_Core.RAISE('WFENG_SYNCH_DISABLED');
  END IF;


  RETURN;

EXCEPTION
  WHEN others THEN
    Wf_Core.CONTEXT('Wf_Standard', 'VoteForResultType',p_itemtype,
                    p_itemkey, to_char(p_actid), p_funcmode);
    RAISE;
END PostNtfFunction;




--
PROCEDURE update_action_history_reject(itemtype  IN VARCHAR2
                                        ,itemkey   IN VARCHAR2
                                        ,actid     IN NUMBER
                                        ,funcmode  IN VARCHAR2
                                        ,resultout OUT NOCOPY VARCHAR2) IS

  l_progress         VARCHAR2(100) := '000';
  l_action           VARCHAR2(30) := 'REJECT';
  l_document_id      NUMBER;
  l_document_type    VARCHAR2(25) := '';
  l_document_subtype VARCHAR2(25) := '';
  l_note             VARCHAR2(4000);

  l_doc_string         VARCHAR2(200);
  l_preparer_user_name VARCHAR2(100);
  l_approver_user_name fnd_user.user_name%TYPE;

  l_org_id           NUMBER;
  l_current_approver NUMBER;
  l_employee         employeerecord;

BEGIN
  IF (funcmode = wf_engine.eng_run) THEN
    l_progress := 'Update_Action_History_Reject: 001';
    IF (g_po_wf_debug = 'Y') THEN
       /* DEBUG */
       po_wf_debug_pkg.insert_debug(itemtype, itemkey, l_progress);
    END IF;

    l_current_approver := po_wf_util_pkg.getitemattrnumber(itemtype => itemtype
                                                          ,itemkey  => itemkey
                                                          ,aname    => 'APPROVER_EMPID');

    IF l_current_approver IS NULL THEN

      l_approver_user_name := po_wf_util_pkg.getitemattrnumber(itemtype => itemtype
                                                              ,itemkey  => itemkey
                                                              ,aname    => 'APPROVER_USER_NAME');
      --
      get_employee_info_for_user(l_approver_user_name, l_employee);
      --
      l_current_approver := l_employee.person_id;
      --
    END IF;

    l_document_id := po_wf_util_pkg.getitemattrnumber(itemtype => itemtype
                                                     ,itemkey  => itemkey
                                                     ,aname    => 'DOCUMENT_ID');

    l_document_type := po_wf_util_pkg.getitemattrtext(itemtype => itemtype
                                                     ,itemkey  => itemkey
                                                     ,aname    => 'DOCUMENT_TYPE');

    l_document_subtype := po_wf_util_pkg.getitemattrtext(itemtype => itemtype
                                                        ,itemkey  => itemkey
                                                        ,aname    => 'DOCUMENT_SUBTYPE');

    l_note := po_wf_util_pkg.getitemattrtext(itemtype => itemtype
                                            ,itemkey  => itemkey
                                            ,aname    => 'NOTE');

    -- Set the multi-org context
    l_org_id := po_wf_util_pkg.getitemattrnumber(itemtype => itemtype
                                                ,itemkey  => itemkey
                                                ,aname    => 'ORG_ID');

    IF l_org_id IS NOT NULL THEN
      po_moac_utils_pvt.set_org_context(l_org_id);
    END IF;

    l_progress := 'Update_Action_History_Reject: 002-' ||
                  to_char(l_document_id) || '-' || l_document_type || '-' ||
                  l_document_subtype;
    IF (g_po_wf_debug = 'Y') THEN
      /* DEBUG */
      po_wf_debug_pkg.insert_debug(itemtype, itemkey, l_progress);
    END IF;

    updateactionhistory(l_document_id
                       ,l_action
                       ,l_note
                       ,l_current_approver);

    po_wf_util_pkg.setitemattrtext(itemtype => itemtype
                                  ,itemkey  => itemkey
                                  ,aname    => 'AUTHORIZATION_STATUS'
                                  ,avalue   => 'REJECTED');

    resultout := wf_engine.eng_completed || ':' || 'ACTIVITY_PERFORMED';

    l_progress := 'Update_Action_History_Reject: 003';
    IF (g_po_wf_debug = 'Y') THEN
       /* DEBUG */
       po_wf_debug_pkg.insert_debug(itemtype, itemkey, l_progress);
    END IF;
  ELSE
    resultout := wf_engine.eng_null;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    wf_core.CONTEXT('xxah_bpa_approval_wf_pkg'
                   ,'Update_Action_History_Reject'
                   ,l_progress
                   ,SQLERRM);
    RAISE;
  END update_action_history_reject;



  PROCEDURE set_transaction_details ( document_id    IN      varchar2
    , display_type   IN      varchar2
    , DOCUMENT       IN OUT  NOCOPY CLOB
    , document_type  IN OUT  NOCOPY varchar2
  ) IS
    l_header c_header%rowtype;
    --
    CURSOR c_approval_history( b_transaction_id VARCHAR2 ) IS
      SELECT aah.name
      ,      aah.row_timestamp
      ,      aah.approval_status
      ,      ppf.full_name
      FROM ame_approvals_history aah
          ,ame_calling_apps aca
          ,per_all_people_f ppf
          ,fnd_user fur
      WHERE ppf.person_id = fur.employee_id
        AND sysdate BETWEEN ppf.effective_start_date AND ppf.effective_end_date
        AND fur.user_name = aah.name
        AND aah.transaction_id = b_transaction_id
        AND aah.application_id = aca.application_id
        AND aca.transaction_type_id = 'XXAH Blanket Purchase Agreement'   -- gc_transaction_type
        AND sysdate BETWEEN aca.start_date AND nvl(aca.end_date,sysdate)
      ORDER BY row_timestamp ASC
      ;
    --
    CURSOR c_approval_list(b_transaction_id VARCHAR2 ) IS
      SELECT atoal.order_number
            ,NVL(atoal.approval_status,'Future Approver') approval_status
            ,P.full_name approver_name
            ,aag.NAME approval_group_name
      FROM ame_temp_old_approver_lists atoal
          ,ame_approval_groups        aag
          ,fnd_user fu
          ,per_people_x     P
          ,ame_calling_apps aca
      WHERE atoal.transaction_id = b_transaction_id
        AND atoal.application_id = aca.application_id
        AND aca.transaction_type_id = 'XXAH Blanket Purchase Agreement'
        AND nvl(atoal.approval_status,'@') NOT LIKE '%REPEATED'
        AND sysdate BETWEEN aca.start_date AND nvl(aca.end_date,sysdate)
        AND aag.approval_group_id(+) = atoal.group_or_chain_id
        AND sysdate BETWEEN aag.start_date(+) AND aag.end_date(+)
        AND fu.user_name = atoal.NAME
        AND fu.employee_id = P.person_id
      ORDER BY atoal.order_number, P.last_name;

    CURSOR c_delegate(b_itemkey wf_notifications.item_key%TYPE
                     ,b_approver wf_notifications.original_recipient%TYPE
                     ,b_timestamp DATE) IS
    SELECT ppf.full_name
    FROM   wf_notifications
    ,      per_all_people_f ppf
    ,      fnd_user fur
    WHERE  ppf.person_id = fur.employee_id
    AND    sysdate BETWEEN ppf.effective_start_date AND ppf.effective_end_date
    AND    fur.user_name = nvl(responder,recipient_role)
    AND    item_key like b_itemkey||'%'
    AND    original_recipient = b_approver
    AND    begin_date < b_timestamp
    AND    message_type = 'POAPPRV'
    ORDER BY (b_timestamp - begin_date) DESC
    ;
    CURSOR c_notif(b_user_key wf_notifications.user_key%TYPE
                  ,b_role wf_notifications.recipient_role%TYPE
                  , b_approval_date DATE ) IS
    SELECT wfna.text_value
    FROM    wf_notifications wfn,
            wf_notification_attributes wfna
    WHERE   wfn.message_type = 'POAPPRV'
    AND     wfn.notification_id     = wfna.notification_id
    AND     wfn.user_key            = b_user_key
    AND     wfn.recipient_role      = b_role
    AND     wfna.NAME               = 'XXAH_REJECT_REASON'
    AND     wfn.status              = 'CLOSED'    -- already responded
    AND     ABS(wfn.end_date - b_approval_date) < 5/(24* 60 * 60)   -- 5 second delay
    ;
    --
    l_document          VARCHAR2(32700) := '';
    l_item_key          VARCHAR2(240);
    l_user_key          VARCHAR2(240);
    l_item_type         VARCHAR2(240);
    l_header_id         NUMBER;
    l_msg_BSA           VARCHAR2(240);
    l_management_sum    VARCHAR2(32000);
    --
    l_transaction_id    VARCHAR2(100);
    l_revision_num      VARCHAR2(100);
    v_value             VARCHAR2(20);
    v_savings           VARCHAR2(20);
    v_saving_total      VARCHAR2(20);
    v_saving_year_opco  VARCHAR2(20);
    v_saving_opco  VARCHAR2(20);

    v_commited_value_fix  VARCHAR2(20);
    v_commited_value_lin  VARCHAR2(20);
    v_amount_in_foreign_currency  VARCHAR(20);
    v_min_amount varchar2(20);
    v_delegate per_all_people_f.full_name%TYPE;
    v_reject_reason VARCHAR2(32767);
    v_combined         po_headers_all_dfv.combined_bpa_va_approval%TYPE;
    BEGIN

    SELECT message_type, item_key, user_key
    INTO   l_item_type
    ,      l_item_key
    ,      l_user_key
    FROM   wf_notifications
    WHERE notification_id = to_number(document_id);

    IF l_item_key like '%#XX#%' THEN
      l_item_key := substr(l_item_key,1,instr(l_item_key,'#XX#')-1);
    END IF;

    l_transaction_id := wf_engine.GetItemAttrNumber
                       ( itemType => l_item_type
                       , itemKey  => l_item_key
                       , aName    => 'DOCUMENT_ID'
                        );
    --
    l_revision_num := wf_engine.GetItemAttrNumber
                       ( itemType => l_item_type
                       , itemKey  => l_item_key
                       , aName    => 'REVISION_NUMBER'
                       );

    l_header_id := to_number(l_transaction_id);
    --
    l_transaction_id := l_transaction_id ||'#'||l_revision_num;
    IF l_revision_num = '0' THEN
      OPEN c_po(l_header_id);
      FETCH c_po INTO v_combined;
      CLOSE c_po;
      IF v_combined = 'Y' THEN
        l_msg_BSA := 'Combined Blanket Purchase Agreement and Sales Agreement, check related sales agreement for more information.';
        l_document := '<br><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=4>' || l_msg_BSA ||'</font><br>';
        dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
      ELSE
        l_msg_BSA := 'Blanket Purchase Agreement';
        l_document := '<br><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=4>' || l_msg_BSA ||'</font><br>';
        dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
      END IF;
    ELSE
      l_msg_BSA := 'Blanket Purchase Agreement';
      l_document := '<br><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=4>' || l_msg_BSA ||'</font><br>';
      dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    END IF;

    --added cursor to query blanket header information
    open c_header(l_header_id);
    fetch c_header into l_header;
    close c_header;
    v_min_amount := to_char(l_header.BLANKET_TOTAL_AMOUNT,'99G999G999G999');

    --display blanket header information
    l_document := '<table border=0 cellpadding=0 cellspacing=0 ><tr><td>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '<table sumarry="" width=100% border=0 cellpadding=3 cellspacing=1 bgcolor=white> <tr>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    --ACTIVATION DATE
    l_document := '<tr>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '<th align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>Effective From</font></td>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_header.start_date || '</font></th>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '</tr>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    --EXPIRATION DATE
    l_document := '<tr>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '<th align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>Effective To</font></td>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_header.end_date || '</font></th>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '</tr>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    --MIN AMOUNT
    l_document := '<tr>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '<th align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>Amount Agreed</font></td>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || v_min_amount || '</font></th>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '</tr>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    -- project_description
    l_document := '<tr>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '<th align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>Project Description</font></td>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_header.project_description || '</font></th>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '</tr>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    -- Vendor name
    l_document := '<tr>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '<th align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>Vendor Name</font></td>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_header.customer || '</font></th>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '</tr>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    -- Buyer
    l_document := '<tr>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '<th align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>Buyer</font></td>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_header.buyer || '</font></th>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '</tr>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);

    l_document := '</table>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '</table>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);

    l_document := '<table width=100% border=0 cellpadding=0 cellspacing=0 ><tr><td>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '<table sumarry="" width=100% border=0 cellpadding=3 cellspacing=1 bgcolor=white> <tr>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);

    l_document := '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || 'Vendor Check' || '</font></th>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || 'Vendor Check Date' || '</font></th>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || 'Payment Terms Days' || '</font></th>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || 'Payment Terms Percentage' || '</font></th>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || 'Previous Contract' || '</font></th>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || 'Related Mother Contract' || '</font></th>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || 'Committed Value (Fixed)' || '</font></th>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || 'Committed Value (Linear)' || '</font></th>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || 'Amount in Foreign Currency' || '</font></th>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || 'Foreign Currency' || '</font></th></tr>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);

    FOR r_header_details IN c_header_details(l_header_id)
    LOOP
      v_commited_value_fix := to_char(fnd_number.canonical_to_number(r_header_details.committed_value_fixed),'999G999G999G999');
      v_commited_value_lin := to_char(fnd_number.canonical_to_number(r_header_details.committed_value_linear),'999G999G999G999');
      v_amount_in_foreign_currency := to_char(fnd_number.canonical_to_number(r_header_details.amount_in_foreign_currency),'999G999G999G999');

      l_management_sum := r_header_details.management_sum;

      l_document := '<tr><td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || r_header_details.vendor_check_advice || '</font></td>';

      dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
      l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || to_char(r_header_details.vendor_check_date, 'DD-MON-YYYY') || '</font></td>';

      dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
      l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || r_header_details.payment_terms_days  || '</font></td>';
      dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
      l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || r_header_details.payment_terms_percentage || '</font></td>';

      dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
      l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || r_header_details.previous_contract || '</font></td>';
      dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
      l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || r_header_details.related_mother_contract || '</font></td>';

      dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
      l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || v_commited_value_fix  || '</font></td>';
      dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
      l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || v_commited_value_lin || '</font></td>';
      dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);

      l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || v_amount_in_foreign_currency  || '</font></td>';
      dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
      l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || r_header_details.foreign_currency || '</font></td></tr>';
      dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);

    END LOOP;

    l_document := '</TABLE></TD></TR></TABLE></P>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);

    l_msg_BSA := 'Mandatory Contract Information';

    l_document := '<br><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=4>' || l_msg_BSA ||'</font><br>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '<table width=75% border=0 cellpadding=0 cellspacing=0 ><tr><td>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '<table sumarry="" width=100% border=0 cellpadding=3 cellspacing=1 bgcolor=white> <tr>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);

    l_document := '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || 'Result Type' || '</font></th>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || 'Category' || '</font></th>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || 'Opco' || '</font></th>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || 'Year' || '</font></th>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || 'Amount' || '</font></th></tr>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
--category
    FOR r_savings IN c_savings(l_header_id)
    LOOP
      IF r_savings.estimated_savings = trunc(r_savings.estimated_savings) THEN
        v_savings := to_char(r_savings.estimated_savings,'999G999G999');
      ELSE
        v_savings := to_char(r_savings.estimated_savings,'999G999G990D00');
      END IF;


      l_document := '<tr><td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || r_savings.savings_type || '</font></td>';
      dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
      l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || r_savings.category || '</font></td>';
      dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
      l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || r_savings.opco || '</font></td>';
      dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
      l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || r_savings.year || '</font></td>';
      dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
      l_document := '<td align=RIGHT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || v_savings || '</font></td></tr>';
      dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);

    END LOOP;

    l_document := '</TABLE></TD></TR></TABLE></P>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);

    l_document := '<br><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=4>' || 'Management Summary' ||'</font><br>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);

    /* Joost Voordouw: fix line breaks */
    l_document := '<P>' || REPLACE(l_management_sum, CHR(10), '<BR>') || '</P>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);

    /* Rvelden: Approval History */
    l_document := '<br><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=4>' || 'Approval History' ||'</font><br>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '<table width=50% border=0 cellpadding=0 cellspacing=0 ><tr><td>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '<table summary="" width=100% border=0 cellpadding=3 cellspacing=1 bgcolor=white> <tr>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);

    l_document := '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || 'Date' || '</font></th>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || 'Approval Status' || '</font></th>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || 'Name' || '</font></th>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || 'Reason' || '</font></th></tr>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);

    FOR r_approval_history IN c_approval_history(l_transaction_id)
    LOOP
      l_document := '<tr><td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || to_char(r_approval_history.row_timestamp, 'DD-MON-YYYY hh24:mi:ss') || '</font></td>';

      dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
      l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || r_approval_history.approval_status || '</font></td>';
      dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
      v_delegate := NULL;
--      OPEN c_delegate(l_item_key
--                     ,r_approval_history.name
--                     ,r_approval_history.row_timestamp);
--      FETCH c_delegate INTO v_delegate;
--      CLOSE c_delegate;
--      IF nvl(v_delegate,r_approval_history.full_name) != r_approval_history.full_name THEN
--        l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || v_delegate ||' on behalf of '||r_approval_history.full_name || '</font></td>';
--        dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
--      ELSE
        l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || r_approval_history.full_name || '</font></td>';
        dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
--      END IF;
      --
      v_reject_reason := NULL;
      OPEN c_notif(l_user_key
                  ,r_approval_history.name
                  ,r_approval_history.row_timestamp );
      FETCH c_notif INTO v_reject_reason;
      CLOSE c_notif;
      l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || v_reject_reason || '</font></td></tr>';
      dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    END LOOP;
    l_document := '</TABLE></TD></TR></TABLE></P>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    --
    -- JPE, Approval path, list approvers and future approvers
    l_document := '<br><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=4>' || 'Approval Path' ||'</font><br>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '<table width=50% border=0 cellpadding=0 cellspacing=0 ><tr><td>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '<table summary="" width=100% border=0 cellpadding=3 cellspacing=1 bgcolor=white> <tr>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);

    --
    l_document := '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || 'Order' || '</font></th>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || 'Approval Status' || '</font></th>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || 'Name' || '</font></th>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || 'Approval Group Name' || '</font></th></tr>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    --
    FOR r_approval_list IN c_approval_list(l_transaction_id)
      LOOP
        l_document := '<tr><td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || r_approval_list.order_number || '</font></td>';
        dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
        l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || r_approval_list.approval_status || '</font></td>';
        dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
        l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || r_approval_list.approver_name || '</font></td>';
        dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
        l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || r_approval_list.approval_group_name || '</font></td></tr>';
       dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
      END LOOP;
    l_document := '</TABLE></TD></TR></TABLE></P>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);

    l_document := '<br><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=4>' || 'Attachments' ||'</font><br>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '<table width=50% border=0 cellpadding=0 cellspacing=0 ><tr><td>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '<table summary="" width=100% border=0 cellpadding=3 cellspacing=1 bgcolor=white> <tr>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    --
    l_document := '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || 'Nr' || '</font></th>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || 'Name' || '</font></th></tr>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    --
    FOR r_ntf_attachments IN c_ntf_attachments(p_header_id   => l_header_id)
      LOOP
        l_document := '<tr><td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || r_ntf_attachments.ROWNUM || '</font></td>';
        dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
        l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || r_ntf_attachments.file_name || '</font></td>';
        dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
      END LOOP;
    --
    l_document := '</TABLE></TD></TR></TABLE></P>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);

  END set_transaction_details;

  PROCEDURE set_attachments
  ( p_itemtype   IN   VARCHAR2
  , p_itemkey    IN   VARCHAR2
  , p_actid      IN   NUMBER
  , p_funcmode   IN   VARCHAR2
  , p_resultout  OUT  VARCHAR2
  )
  IS
    l_header_id NUMBER;
  BEGIN
    write_log('begin set_attachments');
    -- find header id
    l_header_id := wf_engine.GetItemAttrNumber
                       ( itemType => p_itemtype
                       , itemKey  => p_itemkey
                       , aName    => 'DOCUMENT_ID'
                        );


    -- Just take first 10 attachments and fill attributes for them, regardless of doc type
    -- only attachments for a document category having notification function assigned will be selected
    --
    FOR r_ntf_attachments IN c_ntf_attachments(p_header_id => l_header_id)
    LOOP
      IF r_ntf_attachments.rownum <= 10 THEN
        wf_engine.setitemattrdocument
          ( itemtype=> p_itemtype
          , itemkey=> p_itemkey
          , aname=>  'XXAH_ATT_' || r_ntf_attachments.rownum
          , documentid =>'PLSQLBLOB:xxah_bpa_approval_wf_pkg.get_attachment/' ||r_ntf_attachments.media_id
          );
      END IF;
    END LOOP;

  END set_attachments;


PROCEDURE get_attachment
  (
    document_id   IN VARCHAR2
   ,display_type  IN VARCHAR2
   ,DOCUMENT      IN OUT BLOB
   ,document_type IN OUT VARCHAR2
  ) IS

    CURSOR c_attachments (p_media_id  IN VARCHAR2
                       ) IS
      SELECT ROWNUM
         ,fd_l.media_id
         ,fdct_l.user_name
         ,fd_l.file_name file_name
         ,fl_l.file_content_type
         ,fl_l.file_data
      FROM  fnd_attached_documents fad_l
        , fnd_documents fd_l
        , fnd_document_categories_tl fdct_l
        , fnd_lobs fl_l
      WHERE fad_l.document_id = fd_l.document_id
      AND fdct_l.category_id = fd_l.category_id
      AND fd_l.media_id = fl_l.file_id
      AND p_media_id = fd_l.media_id
      ORDER BY ROWNUM
    ;

    lob_id       NUMBER;
    bdoc         BLOB;
    content_type VARCHAR2(100);
    filename     VARCHAR2(300);
  BEGIN
    lob_id := to_number(document_id);

  FOR  l_attachments IN c_attachments( p_media_id  => lob_id )
  LOOP
    document_type := l_attachments.file_content_type || ';name=' || l_attachments.file_name;
    dbms_lob.copy(DOCUMENT, l_attachments.file_data, dbms_lob.getlength(l_attachments.file_data));
  END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      wf_core.CONTEXT('xxah_bpa_approval_wf_pkg'
                     ,'get_attachement'
                     ,document_id
                     ,display_type);
      RAISE;
  END get_attachment;
  --
  PROCEDURE set_transaction_details ( document_id    IN      varchar2
    , display_type   IN      varchar2
    , DOCUMENT       IN OUT  NOCOPY varchar2
    , document_type  IN OUT  NOCOPY varchar2
  ) IS
    v_clob CLOB;
    v_amount NUMBER;
  BEGIN
    dbms_lob.createtemporary(v_clob, TRUE, Dbms_Lob.Session);
    set_transaction_details( document_id => document_id
    , display_type  => display_type
    , DOCUMENT      => v_clob
    , document_type  => document_type);
   /*
    * If the message is larger than 32k, no text is shown at all.
    * because its not valid HTML
    */
    v_amount := 32000;
    dbms_lob.read(v_clob,v_amount,1,document);
    IF dbms_lob.getlength(v_clob) >= 32000 THEN
      document := '<br><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=4>' ||
                  'Message is too large to show, please reject the contract. When the contract '||
                  'is resubmitted all data can be shown. '||'</font><br>';
    END IF;

  END set_transaction_details;
  --
  PROCEDURE check_combined
   ( p_itemtype   IN   VARCHAR2
    , p_itemkey    IN   VARCHAR2
    , p_actid      IN   NUMBER
    ,  p_funcmode   IN   VARCHAR2
    , p_resultout  OUT  VARCHAR2
    ) IS
    l_progress         VARCHAR2(100) := '000';
    l_transaction_id   VARCHAR2(100);
    l_header_id        po_headers_all.po_header_id%TYPE;
    v_combined         po_headers_all_dfv.combined_bpa_va_approval%TYPE;
    v_found BOOLEAN;
  BEGIN
    --
    l_progress := 'Check Combined: 001';
    IF (p_funcmode = wf_engine.eng_run) THEN
      l_transaction_id := wf_engine.GetItemAttrNumber
                         ( itemType => p_itemtype
                         , itemKey  => p_itemkey
                         , aName    => 'DOCUMENT_ID'
                         );
      --
      l_header_id := to_number(l_transaction_id);
      OPEN c_po(l_header_id);
      FETCH c_po INTO v_combined;
      v_found := c_po%FOUND;
      CLOSE c_po;
      IF v_found THEN
        IF v_combined = 'Y' THEN
          -- set to on  hold?
          UPDATE po_headers_all
          SET user_hold_flag = 'Y'
          WHERE po_header_id = l_header_id
          ;
          p_resultout := 'COMPLETE:Y';
        ELSE
          p_resultout := 'COMPLETE:N';
        END IF;
      ELSE
        p_resultout := 'COMPLETE:N';
      END IF;
    ELSE
      p_resultout := wf_engine.eng_null;
    END IF;
    l_progress := 'Check Combined: 002';
  EXCEPTION
    WHEN OTHERS THEN
     wf_core.CONTEXT('xxah_bpa_approval_wf_pkg'
                    ,'Check Combined'
                    ,l_progress
                    ,SQLERRM);
     RAISE;
  END check_combined;
  --
  PROCEDURE remove_hold
    ( p_itemtype   IN   VARCHAR2
    , p_itemkey    IN   VARCHAR2
    , p_actid      IN   NUMBER
    , p_funcmode   IN   VARCHAR2
      , p_resultout  OUT  VARCHAR2
    ) IS
    l_progress         VARCHAR2(100) := '000';
    l_transaction_id   VARCHAR2(100);
    l_header_id        po_headers_all.po_header_id%TYPE;
  BEGIN
    l_progress := 'Remove Hold: 001';
    IF (p_funcmode = wf_engine.eng_run) THEN
      l_transaction_id := wf_engine.GetItemAttrNumber
                         ( itemType => p_itemtype
                         , itemKey  => p_itemkey
                         , aName    => 'DOCUMENT_ID'
                         );
      l_header_id := to_number(l_transaction_id);
      UPDATE po_headers_all
      SET user_hold_flag = NULL
      WHERE po_header_id = l_header_id
      ;
      COMMIT; --oddly enough, the update is not quick enough without an explicit commit...
    END IF;
    l_progress := 'Remove Hold: 002';
    p_resultout := wf_engine.eng_null;
  EXCEPTION
    WHEN OTHERS THEN
     wf_core.CONTEXT('xxah_bpa_approval_wf_pkg'
                    ,'Remove Hold'
                    ,l_progress
                    ,SQLERRM);
     RAISE;
  END remove_hold;

END XXAH_BPA_APPROVAL_WF_PKG;

/
