--------------------------------------------------------
--  DDL for Package Body XXAH_VA_AME_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXAH_VA_AME_WF_PKG" AS
/**************************************************************************
 * VERSION      : $Id: XXAH_VA_AME_WF_PKG.plb 69 2015-05-04 08:27:47Z marc.smeenge@oracle.com $
 * DESCRIPTION  : Contains functionality for the approval workflow.
 *
 * CHANGE HISTORY
 * ==============
 *
 * Date        Authors           Change reference/Description
 * ----------- ----------------- ----------------------------------
 * 09-AUG-2010 Kevin Bouwmeester Genesis.
 * 17-NOV-2010 Joost Voordouw	 fix line breaks
 * 17-NOV-2010 Richard Velden    Fixed parallel flow Rejection bug
 *                               Fixed parallel flow after approval restart
 *                               Added Approval History to notification details
 * 24-MAR-2011 Richard Velden    Attachment file name not passed correctly.
 *                               Now opens attachments in new window
 * 13-DEC-2011 Fabian Aulkemeier Changed column header from 'Related Contract'
 *                               to 'Previous Contract in approval report
 * 13-DEC-2011 Fabian Aulkemeier Added header table to display activation
 *                               and expiration date in approval report
 * 05-APR-2012 Richard Velden    Mandatory Rejection Reason
 *************************************************************************/
-- ----------------------------------------------------------------------
-- Private types
-- ----------------------------------------------------------------------

-- ----------------------------------------------------------------------
-- Private constants
-- ----------------------------------------------------------------------
  lc_application_id    NUMBER         := 660;
  lc_transaction_type  VARCHAR2(100)  := 'VA-AGREEMENT';
  lc_transaction_comb  VARCHAR2(100)  := 'VA_BPA_COMBI';
  --
  -- JPE, 12-Jan-2010 All lines below are obsolete,
  -- we will select all attachments for which the document type has the View Notification function assigned
  --l_max_attachments    NUMBER  := 5;

  --TYPE l_varchar2_t IS TABLE OF VARCHAR2(128);
  --l_sales_contract     VARCHAR2(128) := 'Sales Contract';
  --l_printed_documents   VARCHAR2(128) := 'Printed Documents';
  --l_contract_types_t l_varchar2_t := l_varchar2_t(l_printed_documents, l_sales_contract);
-- ----------------------------------------------------------------------
-- Private variables
-- ----------------------------------------------------------------------
    g_header_id oe_blanket_headers_all.header_id%TYPE;
    g_combined oe_blanket_headers_all_dfv.combined_bpa_va_approval%TYPE;
    g_po_header_id oe_blanket_headers_all_dfv.reference_contractnumber%TYPE;
    g_flag po_headers_all.approved_flag%TYPE;
    g_status po_headers_all.authorization_status%TYPE;
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
    AND  fdct_l.category_id = fd_l.category_id
    AND  fd_l.media_id = fl_l.file_id
    AND  fdu.category_id = fdct_l.category_id
      AND (
        (function_name = 'inbox'
          AND  p_header_id = fad_l.pk1_value
        )
        OR
        ( fad_l.entity_name = 'OKC_CONTRACT_DOCS'
          AND fad_l.pk1_value = 'B'
          AND fad_l.pk2_value = p_header_id
        )
      )
  ;
  -- todo: een record per file name...
CURSOR c_comb_attachments(b_header_id    IN VARCHAR2
                         ,b_po_header_id IN VARCHAR2
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
    AND  fdct_l.category_id = fd_l.category_id
    AND  fd_l.media_id = fl_l.file_id
    AND  fdu.category_id = fdct_l.category_id
      AND (
        (function_name = 'inbox'
          AND  b_header_id = fad_l.pk1_value
        )
        OR
        (function_name = 'inbox'
          AND fad_l.entity_name = 'PO_HEADERS'
          AND  b_po_header_id = fad_l.pk1_value
        )
        OR
        ( fad_l.entity_name = 'OKC_CONTRACT_DOCS'
          AND fad_l.pk1_value = 'B'
          AND fad_l.pk2_value = b_header_id
        )
        OR
        ( fad_l.entity_name = 'OKC_CONTRACT_DOCS'
          AND fad_l.pk1_value = 'PA_BLANKET'
          AND fad_l.pk2_value = b_po_header_id
        )
      )
    ;

CURSOR c_attachments (b_media_id  IN VARCHAR2
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
    AND b_media_id = fd_l.media_id
    ORDER BY ROWNUM;
--
  CURSOR c_va(b_header_id po_headers_all.po_header_id%TYPE) IS
  SELECT count(1)
  FROM  oe_blanket_headers_all h
  ,     oe_blanket_headers_all_dfv hd
  WHERE h.rowid = hd.row_id
  AND   hd.combined_bpa_va_approval = 'Y'
  AND   hd.reference_contractnumber = to_char(b_header_id)
  AND   h.flow_status_code NOT IN ('DRAFT','DRAFT_INTERNAL_REJECTED')
  ;
  CURSOR c_va3(b_header_id po_headers_all.po_header_id%TYPE
              ,b_oe_header_id oe_blanket_headers_all.header_id%TYPE) IS
  SELECT count(1)
  FROM  oe_blanket_headers_all h
  ,     oe_blanket_headers_all_dfv hd
  WHERE h.rowid = hd.row_id
  AND   hd.combined_bpa_va_approval = 'Y'
  AND   hd.reference_contractnumber = to_char(b_header_id)
  AND   h.header_id != b_oe_header_id
  AND   h.flow_status_code IN ('DRAFT_SUBMITTED','PENDING_CUSTOMER_ACCEPTANCE','CUSTOMER_ACCEPTED')
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
    ) IS
  BEGIN
    fnd_log.STRING
    ( LOG_LEVEL => fnd_log.LEVEL_STATEMENT
    , MODULE    => 'XXAH_VA_AME_WF_PKG'
    , MESSAGE   => to_char(systimestamp, 'HH24:MI:SS.FF2 ') || p_message
    );
  END write_log;

-- ----------------------------------------------------------------------
-- Public subprograms combined, revision = 000, nog niet goedgekeurd.
-- ----------------------------------------------------------------------
  PROCEDURE get_bpa
  (p_header_id IN oe_blanket_headers_all.header_id%TYPE)
  IS
    CURSOR c_oe(b_header_id oe_blanket_headers_all.header_id%TYPE) IS
    SELECT nvl(combined_bpa_va_approval,'N') combined
    ,      reference_contractnumber po_header_id
    FROM   oe_blanket_headers_all_dfv hdv
    ,      oe_blanket_headers_all head
    WHERE  head.header_id = b_header_id
    AND    head.rowid = hdv.row_id
    ;
    CURSOR c_po(b_header_id po_headers_all.po_header_id%TYPE) IS
    SELECT user_hold_flag, authorization_status
    FROM   po_headers_all
    WHERE  po_header_id = b_header_id
    AND    revision_num = 0
    ;
    v_found BOOLEAN;
  BEGIN
    OPEN c_oe(p_header_id);
    FETCH c_oe INTO g_combined
    ,               g_po_header_id;
    v_found := c_oe%FOUND;
    CLOSE c_oe;
    IF NOT v_found THEN
      g_combined := 'N';
    END IF;
    IF g_combined = 'Y' THEN
      OPEN c_po(to_number(g_po_header_id));
      FETCH c_po INTO g_flag, g_status;
      v_found := c_po%FOUND;
      CLOSE c_po;
    END IF;
  END get_bpa;
  --
 /**************************************************************************
   *
   * PROCEDURE
   *   is_approval_complete
   *
   * DESCRIPTION
   *   Fetches the next set of approvers (if any) by calling
   *   ame_api2.getNextApprovers4. Also checks whether the
   *   transaction?s approval process is complete. If the process is
   *   incomplete, the node creates and starts a child process for each
   *   approver requiring notification.
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
  PROCEDURE is_approval_complete ( p_itemtype   IN   VARCHAR2
                                 , p_itemkey    IN   VARCHAR2
                                 , p_actid      IN   NUMBER
                                 , p_funcmode   IN   VARCHAR2
                                 , p_resultout  OUT  VARCHAR2
                                 ) IS
    CURSOR c_header_info(b_header_id oe_blanket_headers_all.header_id%TYPE) IS
      SELECT order_number
      FROM   oe_blanket_headers_all
      WHERE  header_id = b_header_id;

    lc_child_itemtype   VARCHAR2(100)  := 'XXAHSAA';
    lc_child_process    VARCHAR2(10)   := 'XXAH_CHILD';
    l_child_itemkey     VARCHAR2(100);
    l_transaction_id    NUMBER;
    l_approval_complete VARCHAR2(1);
    l_approvers_tab     ame_util.approversTable2;
    l_user_id           NUMBER;
    l_user_name         fnd_user.user_name%TYPE;
    l_item_key_count    NUMBER :=0;
    v_transaction_type  VARCHAR2(100);

    l_order_number      oe_blanket_headers_all.order_number%TYPE;

  BEGIN
    write_log('begin is_approval_complete');
   -- 1. Call the AME API procedure to get the next set of approvers to notify.

   l_transaction_id := wf_engine.GetItemAttrNumber
                       ( itemType => p_itemtype
                       , itemKey  => p_itemkey
                       , aName    => 'HEADER_ID'
                        );
   get_bpa(l_transaction_id);
   l_user_id := wf_engine.GetItemAttrNumber
                       ( itemType => p_itemtype
                       , itemKey  => p_itemkey
                       , aName    => 'USER_ID'
                       );
   IF g_combined = 'Y' THEN
     v_transaction_type := lc_transaction_comb;
   ELSE
     v_transaction_type := lc_transaction_type;
   END IF;
   ame_api2.getNextApprovers4
   ( applicationIdIn              => lc_application_id
   , transactionTypeIn            => v_transaction_type
   , transactionIdIn              => l_transaction_id
   , flagApproversAsNotifiedIn    => ame_util.booleanTrue
   , approvalProcessCompleteYNOut => l_approval_complete
   , nextApproversOut             => l_approvers_tab
   );

   -- 2. If approval process is complete, end the process.

   IF l_approval_complete = ame_util.booleanTrue
   THEN
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

   write_log('p_resultout: '||p_resultout);
   write_log('number of approvers in next level: '||l_approvers_tab.count);

    /*
    *  CHILD item key consists of:
    *       <parent_item_key>_<approver_sys_id>_<appr_list_number>
    *  e.g.: 1000_250_22
    */

    -- SELECT MAX(appr_list_number) + 1 FROM previous CHILD approval flows
    -- e.g.: 10000_250_22. conversion to number because of in ascii 11 is lower
    -- than 2.
    SELECT NVL (
            MAX (
             TO_NUMBER(substr(i.item_key, instr(i.item_key, '_', 1,2) -- location of second underscore (e.g. 10)
                                        + 1                           -- location of character after 2nd underscore (e.g. 11)
                                     )                                -- substring starting just after 2nd underscore (e.g. 22)
                                    )                                 -- convert to a numeriek thing
                                   ) + 1                              -- maximum number add +1 to that number (e.g. 23)
                        , 0 )                                         -- If MAX IS NULL (no previous child approval flows), start with value 0
    INTO   l_item_key_count
    FROM   wf_items i
    WHERE  i.item_key LIKE p_itemkey || '%'     -- Belonging to this parent
    AND i.item_type = 'XXAHSAA';                -- Child approval flow Item Type


   -- 3. Loop through the approvers returned at step one.
   FOR i IN l_approvers_tab.first .. l_approvers_tab.last
   LOOP
     write_log('approver #: '||i);
     l_child_itemkey := p_itemkey || '_' || l_approvers_tab(i).orig_system_id;

     -- append <appr_list_number> to itemkey
     l_child_itemkey := l_child_itemkey || '_' || l_item_key_count;

     -- A - Create a child processes
     wf_engine.createProcess
     ( itemType => lc_child_itemtype
     , itemKey  => l_child_itemkey
     , process  => lc_child_process
     );

     -- B - Set the item Approver attribute to the approver?s wf_roles.name value
     wf_engine.SetItemAttrText
     ( itemType => lc_child_itemtype
     , itemKey  => l_child_itemkey
     , aName    => 'XXAH_APPROVER'
     , aValue   => l_approvers_tab(i).NAME
     );
     write_log('approver name: '||l_approvers_tab(i).NAME);

     wf_engine.SetItemAttrText
     ( itemType => lc_child_itemtype
     , itemKey  => l_child_itemkey
     , aName    => 'XXAH_SENDER'
     , aValue   => l_user_id
     );

     SELECT user_name
     INTO   l_user_name
     FROM   fnd_user
     WHERE user_id = l_user_id;

     wf_engine.SetItemAttrText
     ( itemType => lc_child_itemtype
     , itemKey  => l_child_itemkey
     , aName    => 'XXAH_SENDER_NAME'
     , aValue   => l_user_name
     );

     -- C - Set the item Master Item Key attribute to the master item?s item key
     wf_engine.SetItemAttrText
     ( itemType => lc_child_itemtype
     , itemKey  => l_child_itemkey
     , aName    => 'XXAH_MASTER_ITEM_KEY'
     , aValue   => p_itemKey
     );

     wf_engine.SetItemAttrText
     ( itemType => lc_child_itemtype
     , itemKey  => l_child_itemkey
     , aName    => 'XXAH_HEADER_ID'
     , aValue   => l_transaction_id
     );

     OPEN c_header_info(b_header_id => l_transaction_id);
     FETCH c_header_info INTO l_order_number;
     CLOSE c_header_info;

     wf_engine.SetItemAttrText
     ( itemType => lc_child_itemtype
     , itemKey  => l_child_itemkey
     , aName    => 'XXAH_SA_NUM'
     , aValue   => l_order_number
     );

     -- D - Start the child processes
     wf_engine.StartProcess
     ( itemType => lc_child_itemtype
     , itemKey  => l_child_itemkey
     );

   END LOOP;

   p_resultout := 'COMPLETE:N';
   write_log('end is_approval_complete');
  EXCEPTION
    WHEN OTHERS THEN
        -- Set AME_ERROR_MESSAGE to SQLERRM
        BEGIN
          wf_engine.SetItemAttrText
          ( itemType => p_itemtype
          , itemKey  => p_itemkey
          , aName    => 'XXAH_AME_ERROR'
          , aValue   => SQLERRM
          );
        EXCEPTION
          WHEN OTHERS THEN
            Raise;
        END;
        p_resultout := 'COMPLETE:ERROR';

  END;

  /**************************************************************************
   *
   * PROCEDURE
   *   get_approver_response
   *
   * DESCRIPTION
   *   This procedure gets the approver?s response, passes it to AME, and then
   *   completes the master process? waiting activity (its Wait for Approver
   *   Response node).
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
  PROCEDURE get_approver_response( p_itemtype   IN   VARCHAR2
                                 , p_itemkey    IN   VARCHAR2
                                 , p_actid      IN   NUMBER
                                 , p_funcmode   IN   VARCHAR2
                                 , p_resultout  OUT  VARCHAR2
                                 ) IS
    l_approver              VARCHAR2(100);
    l_master_itemkey        VARCHAR2(100);
    l_approval_response     VARCHAR2(100);
    l_transaction_id        NUMBER;
    l_parallel_count        NUMBER;
    l_reject_count          NUMBER;
    v_transaction_type      VARCHAR2(100);
    --
  BEGIN
    write_log('begin get_approver_response');

    -- 1. Get approver attribute value
    write_log('step 1');

    l_approver := wf_engine.GetItemAttrText
                  ( itemType => p_itemtype
                  , itemKey  => p_itemkey
                  , aName    => 'XXAH_APPROVER'
                  );

    -- 2. Get the approver?s notification response for the above approver
    write_log('step 2');
    l_approval_response := wf_engine.GetItemAttrText
                          ( itemType => p_itemtype
                          , itemKey  => p_itemkey
                          , aName    => 'XXAH_RESPONSE'
                          );

    /*
    OPEN  c_notification_reponse(p_itemkey);
    FETCH c_notification_reponse INTO l_approval_response;
    CLOSE c_notification_reponse;
    */

    -- 3. Update the approver?s status
    write_log('step 3');

    l_transaction_id := wf_engine.GetItemAttrNumber
                       ( itemType => p_itemtype
                       , itemKey  => p_itemkey
                       , aName    => 'XXAH_HEADER_ID'
                       );
    get_bpa(l_transaction_id);
    IF g_combined = 'Y' THEN
      v_transaction_type := lc_transaction_comb;
    ELSE
      v_transaction_type := lc_transaction_type;
    END IF;
    ame_api2.updateApprovalStatus2
    ( applicationIdIn   => lc_application_id
    , transactionTypeIn => v_transaction_type
    , transactionIdIn   => l_transaction_id
    , approvalStatusIn  => l_approval_response
    , approverNameIn    => l_approver
    );

    -- 4. Communicate the response to the master process? waiting node
    write_log('step 4');

    l_master_itemkey := wf_engine.GetItemAttrText
                        ( itemType => p_itemtype
                        , itemKey  => p_itemkey
                        , aName    => 'XXAH_MASTER_ITEM_KEY'
                        );


    -- Check if there are still other parallel approval workflow running
    -- Only last process should kick the parent
    SELECT count(*)
    INTO   l_parallel_count
    FROM   wf_item_activity_statuses s
    ,      wf_process_activities A
    WHERE  s.item_type = p_itemtype
    AND    s.item_key LIKE l_transaction_id || '%'
    AND    s.item_key != p_itemkey
    AND    A.process_item_type = s.item_type
    AND    A.process_name = 'XXAH_CHILD'
    AND    A.activity_name = 'XXAH_APPROVAL'
    AND    A.instance_id = s.process_activity
    AND    s.activity_status = 'NOTIFIED'
    ;

    IF  l_parallel_count = 0
    THEN
      -- set last approver on the parent workflow
      wf_engine.SetItemAttrText
      ( itemtype => 'OENH'
      , itemkey => l_master_itemkey
      , aname => 'NOTIFICATION_APPROVER'
      , avalue => l_approver
      );

      -- if there was any reject in the parallel flow then return reject
      SELECT count(*)
      INTO   l_reject_count
      FROM   wf_item_activity_statuses s
      ,      wf_process_activities A
      WHERE  s.item_type = 'XXAHSAA'
      AND    s.item_key LIKE l_transaction_id || '%' || substr(p_itemkey, instr(p_itemkey, '_', 1,2)+1)   -- appr_list_number (after 2nd underscore)
      AND    A.process_item_type = s.item_type
      AND    A.process_name = 'XXAH_CHILD'
      AND    A.activity_name = 'XXAH_APPROVAL'
      AND    A.instance_id = s.process_activity
      AND    s.activity_status = 'COMPLETE'
      AND    s.activity_result_code = 'REJECT';

      IF l_reject_count > 0
      THEN
        l_approval_response := 'REJECT';
      END IF;

      -- this is the last workflow, so kick parent
      wf_engine.CompleteActivity
      ( itemType => 'OENH'
      , itemKey  => l_master_itemkey
      , activity => 'WAITFORAPPROVERS'
      , result   => l_approval_response
      );

    END IF;

    p_resultout := 'COMPLETE';

  END get_approver_response;


  PROCEDURE set_null
  ( document_id    IN      varchar2
  , display_type   IN      varchar2
  , DOCUMENT       IN OUT  NOCOPY varchar2
  , document_type  IN OUT  NOCOPY varchar2
  ) IS
  BEGIN
    DOCUMENT := NULL;
  END;

  /**************************************************************************
   *
   * PROCEDURE
   *   set_transaction_details
   *
   * DESCRIPTION
   *   Get the detais for the approval notification body.
   *
   * PARAMETERS
   * ==========
   * NAME              TYPE           DESCRIPTION
   * ----------------- -------------  --------------------------------------
   * document_id       IN
   * display_type      IN
   * document          IN
   * document_type     IN
   *
   * PREREQUISITES
   *   List prerequisites to be satisfied
   *
   * CALLED BY
   *   List caller of this procedure
   *
   *************************************************************************/
  PROCEDURE set_transaction_details ( document_id    IN      varchar2
                                    , display_type   IN      varchar2
                                    , DOCUMENT       IN OUT  NOCOPY CLOB
                                    , document_type  IN OUT  NOCOPY varchar2
                                    ) IS

    --query on blanket header level
    CURSOR c_header(b_header_id IN NUMBER) IS
      SELECT hex.start_date_active
      ,      hex.end_date_active
      ,      hex.blanket_min_amount
      ,      fnd_date.canonical_to_date(s.attribute5) vendor_check_date
      ,      h.attribute5 project_description
      ,      (SELECT concatenated_segments
              FROM   mtl_categories_b_kfv
              WHERE  structure_id = 201
              AND    category_id = to_number(h.attribute2)) category
      ,      (SELECT flex_value_meaning
              FROM   fnd_flex_values_vl fv
              ,      fnd_flex_value_sets fs
              WHERE  fs.flex_value_set_id = fv.flex_value_set_id
              AND    fs.flex_value_set_name = 'XXAH_CENTRAL_LOCAL'
              AND    flex_value = h.attribute7) central_opco
      ,      pep.full_name buyer
      ,      o.NAME unit
      ,      P.party_name customer
      ,      s.attribute8 vendor_check_advice
      ,      h.transactional_curr_code currency
      ,      t.name payment_terms
      ,      (SELECT segment1
              FROM po_headers_all
              WHERE po_header_id = to_number(h.attribute4)) previous_contract
      FROM   oe_blanket_headers_all h
      ,      oe_blanket_headers_ext hex
      ,      jtf_rs_salesreps r
      ,      per_all_people_f pep
      ,      per_all_assignments_f asg
      ,      hr_all_organization_units o
      ,      hz_cust_accounts c
      ,      hz_parties P
      ,      ap_suppliers s
      ,      ra_terms_vl T
      WHERE  h.header_id = b_header_id
      AND    h.order_number = hex.order_number
      AND    h.salesrep_id = r.salesrep_id
      AND    r.person_id = pep.person_id
      AND    pep.person_id = asg.person_id
      AND    asg.organization_id = o.organization_id
      AND    h.sold_to_org_id = c.cust_account_id
      AND    c.party_id = P.party_id
      AND    s.party_id (+) = P.party_id
      AND    h.payment_term_id = T.term_id (+)
      AND    hex.start_date_active BETWEEN asg.effective_start_date AND asg.effective_end_date
      AND    hex.start_date_active BETWEEN pep.effective_start_date AND pep.effective_end_date
      ;
    l_header c_header%rowtype;

    CURSOR c_header_details(b_header_id IN NUMBER) IS
      SELECT h.header_id
      ,      i.inventory_item_id
      ,      i.description item_description
      ,      ld.line_description line_description
      ,      ld.cost_center cost_center
      ,      i.organization_id
      ,      h.org_id org_id
      ,      SUM(E.blanket_line_min_amount) va_value
      ,      SUM(ld.purchase_value) purchase_value
      ,      attach.management_sum
      ,      e.start_date_active
      ,      e.end_date_active
      FROM   oe_blanket_headers_all h
      ,      oe_blanket_lines_ext E
      ,      oe_blanket_lines_all l
      ,      mtl_system_items_vl i
      ,      oe_blanket_lines_all_dfv ld
      ,      (SELECT A.pk1_value  header_id
              ,      s.short_text management_sum
              FROM   fnd_attached_documents A
              ,      fnd_documents d
              ,      fnd_documents_short_text s
              WHERE  A.entity_name = 'OE_ORDER_HEADERS'
              AND    d.document_id = A.document_id
              AND    d.media_id = s.media_id
             ) attach
      WHERE  h.header_id = b_header_id
      AND    h.header_id = l.header_id
      AND    E.line_id = l.line_id
      AND    ld.row_id = l.rowid
      AND    l.inventory_item_id = i.inventory_item_id
     -- MS: hard coded the org, since only the master is used,
     -- and there are two ou's...
      AND    84 = i.organization_id
      AND    attach.header_id (+) = to_char(h.header_id) --JPE performance tuning, attach.header_id is a varchar2
      GROUP BY h.header_id
      ,        i.inventory_item_id
      ,        i.description
      ,        i.organization_id
      ,        h.org_id
      ,        ld.line_description
      ,        ld.cost_center
      ,        attach.management_sum
      ,        e.start_date_active
      ,        e.end_date_active
      ;
    CURSOR c_totals(b_header_id IN NUMBER) IS
      SELECT SUM(E.blanket_line_min_amount) va_value
      ,      SUM(ld.purchase_value) purchase_value
      ,      to_char(e.start_date_active,'YYYY') year
      FROM   oe_blanket_lines_ext E
      ,      oe_blanket_lines_all l
      ,      oe_blanket_lines_all_dfv ld
      WHERE  l.header_id = b_header_id
      AND    E.line_id = l.line_id
      AND    ld.row_id = l.rowid
      GROUP BY to_char(e.start_date_active,'YYYY')
      ORDER BY 2
      ;
      CURSOR c_opco(b_item_id mtl_cross_references_b.inventory_item_id%TYPE
                   ,b_org_id mtl_cross_references_b.organization_id%TYPE) IS
      SELECT mcr.cross_reference
      FROM   mtl_cross_references_b mcr
      ,      hr_organization_information  hoi
      WHERE  mcr.inventory_item_id = b_item_id
      AND    hoi.organization_id = b_org_id
      AND    hoi.org_information_context = 'Operating Unit Information'
      AND    hoi.org_information19   = mcr.cross_reference_type
      AND    nvl(mcr.organization_id,b_org_id) = b_org_id
      AND    sysdate BETWEEN nvl(mcr.start_date_active-1/86400,sysdate)
                     AND nvl(mcr.end_date_active,sysdate+1/86400)
      ;
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
        AND sysdate BETWEEN aca.start_date AND nvl(aca.end_date,sysdate)
      ORDER BY row_timestamp DESC
      ;
    -- Added by JPE, 09/12/2010
    CURSOR c_ott(p_header_id NUMBER) IS
      SELECT ott.layout_template_id
      FROM   oe_blanket_headers_all obh
            ,oe_transaction_types_all ott
      WHERE  ott.transaction_type_id = obh.order_type_id
        AND  obh.header_id = p_header_id;
    --
    CURSOR c_approval_list(b_transaction_id VARCHAR2 ) IS
      SELECT atoal.order_number
            ,NVL(atoal.approval_status,'Future Approver') approval_status
            ,P.full_name approver_name
            ,aag.NAME approval_group_name
            ,atoal.NAME name
      FROM ame_temp_old_approver_lists atoal
          ,ame_approval_groups        aag
          ,fnd_user fu
          ,per_people_x     P
          ,ame_calling_apps aca
      WHERE atoal.transaction_id = b_transaction_id
        AND atoal.application_id = aca.application_id
        AND nvl(atoal.approval_status,'@') NOT LIKE '%REPEATED'
        AND sysdate BETWEEN aca.start_date AND nvl(aca.end_date,sysdate)
        AND aag.approval_group_id(+) = atoal.group_or_chain_id
        AND sysdate BETWEEN aag.start_date(+) AND aag.end_date(+)
        AND fu.user_name = atoal.NAME
        AND fu.employee_id = P.person_id
      ORDER BY atoal.order_number, P.last_name;
    --
    /*
     * need to find the reject/approve reason for a specific approver.
     * but the reason can only be found in the child process,
     * so the assumption here is that an approver cannot be
     * an approver for the same parent process more than once...
     * This can however be the case, so pick the workflow
     * started the closest on the row_timestamp of the approval
     */
    CURSOR c_child(b_itemkey wf_item_attribute_values.item_key%TYPE
                  ,b_approver wf_item_attribute_values.text_value%TYPE
                  ,b_timestamp DATE) IS
    SELECT wias.item_type
    ,      wias.item_key
    FROM wf_item_attribute_values wias
    ,    wf_items wis
    WHERE wias.item_type = 'XXAHSAA'
    AND   wias.item_key like b_itemkey||'%'
    AND   wis.item_type = wias.item_type
    AND   wis.item_key = wias.item_key
    AND   wias.name = 'XXAH_APPROVER'
    AND   wias.text_value = b_approver
    AND   wis.begin_date < b_timestamp
    ORDER BY (b_timestamp - wis.begin_date) ASC
    ;
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
    ORDER BY (b_timestamp - begin_date) ASC
    ;
    l_document          VARCHAR2(32000) := '';
    l_master_itemkey    VARCHAR2(100);
    l_item_key          VARCHAR2(240);
    l_item_type         VARCHAR2(8);
    l_header_id         NUMBER;
    l_header_details    c_header_details%ROWTYPE;
    l_msg_BSA           VARCHAR2(240);
    l_management_sum    VARCHAR2(32000);
    l_open_contract     VARCHAR2(1000);
    l_open_contract_pdf VARCHAR2(1000);
    l_url               varchar2(32767);
    l_url_pdf           varchar2(32767);
    l_layout_template_id NUMBER;
    --
    l_url_attach varchar2(4000);
    l_open_attach varchar2(4000);

    l_url_attach2 varchar2(4000);
    l_open_attach2 varchar2(4000);
    --
    l_resp_id NUMBER;
    l_resp_appl_id NUMBER;
    v_reject_reason VARCHAR2(32767);
    v_child c_child%ROWTYPE;
    v_child_found BOOLEAN;
    v_opco mtl_cross_references.cross_reference%TYPE;
    v_value varchar2(20);
    v_value2 varchar2(20);
    v_min_amount varchar2(20);
    v_delegate per_all_people_f.full_name%TYPE;
    v_total NUMBER;
    v_total2 NUMBER;
    v_total_char VARCHAR2(20);
    v_total2_char VARCHAR2(20);
    --
    v_po_header xxah_bpa_approval_wf_pkg.c_header%ROWTYPE;
    v_savings           VARCHAR2(20);
    v_commited_value_fix  VARCHAR2(20);
    v_commited_value_lin  VARCHAR2(20);
    v_amount_in_foreign_currency  VARCHAR(20);
  BEGIN
    SELECT message_type, item_key
    INTO   l_item_type
    ,      l_item_key
    FROM   wf_notifications
    WHERE notification_id = to_number(document_id);

    IF l_item_type = 'OENH'
    THEN
      l_master_itemkey := wf_engine.GetItemAttrText
                          ( itemType => l_item_type
                          , itemKey  => l_item_key
                          , aName    => 'HEADER_ID'
                          );
    ELSIF l_item_type = 'XXAHSAA'
    THEN
      l_master_itemkey := wf_engine.GetItemAttrText
                          ( itemType => l_item_type
                          , itemKey  => l_item_key
                          , aName    => 'XXAH_MASTER_ITEM_KEY'
                          );
    END IF;

    l_header_id := to_number(l_master_itemkey);
    get_bpa(l_header_id);

    IF g_combined = 'Y' THEN
      l_msg_BSA := 'Combined BPA-VA Approval';
      l_document := '<br><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=4>' || l_msg_BSA ||'</font><br>';
      dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);

      l_msg_BSA := 'Blanket Purchase Agreement';
      l_document := '<br><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=4>' || l_msg_BSA ||'</font><br>';
      dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
      OPEN xxah_bpa_approval_wf_pkg.c_header(g_po_header_id);
      FETCH xxah_bpa_approval_wf_pkg.c_header INTO v_po_header;
      CLOSE xxah_bpa_approval_wf_pkg.c_header;
      v_min_amount := to_char(v_po_header.BLANKET_TOTAL_AMOUNT,'99G999G999G999');

      --display blanket header information
      l_document := '<table border=0 cellpadding=0 cellspacing=0 ><tr><td>';
      dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
      l_document := '<table sumarry="" width=100% border=0 cellpadding=3 cellspacing=1 bgcolor=white> <tr>';
      dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
      --AGREEMENT NUMBER
      l_document := '<tr>';
      dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
      l_document := '<th align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>Blanket Purchase Agreement Number</font></td>';
      dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
      l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || v_po_header.segment1 || '</font></th>';
      dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
      l_document := '</tr>';
      dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
      --ACTIVATION DATE
      l_document := '<tr>';
      dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
      l_document := '<th align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>Effective From</font></td>';
      dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
      l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || v_po_header.start_date || '</font></th>';
      dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
      l_document := '</tr>';
      dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
      --EXPIRATION DATE
      l_document := '<tr>';
      dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
      l_document := '<th align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>Effective To</font></td>';
      dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
      l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || v_po_header.end_date || '</font></th>';
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
      l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || v_po_header.project_description || '</font></th>';
      dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
      l_document := '</tr>';
      dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
      -- Vendor name
      l_document := '<tr>';
      dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
      l_document := '<th align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>Vendor Name</font></td>';
      dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
      l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || v_po_header.customer || '</font></th>';
      dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
      l_document := '</tr>';
      dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
      -- Buyer
      l_document := '<tr>';
      dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
      l_document := '<th align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>Buyer</font></td>';
      dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
      l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || v_po_header.buyer || '</font></th>';
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

      FOR r_header_details IN xxah_bpa_approval_wf_pkg.c_header_details(g_po_header_id)
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
      FOR r_savings IN xxah_bpa_approval_wf_pkg.c_savings(g_po_header_id)
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

      l_document := '<P>' || REPLACE(l_management_sum, CHR(10), '<BR>') || '</P>';
      dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);

    END IF;
    l_msg_BSA := FND_MESSAGE.Get_String('ONT', 'OE_NTF_BSA');

    l_document := '<br><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=4>' || l_msg_BSA ||'</font><br>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    --added cursor to query blanket header information
    open c_header(l_header_id);
    fetch c_header into l_header;
    close c_header;
    v_min_amount := to_char(l_header.blanket_min_amount,'999G999G999');

    --display blanket header information
    l_document := '<table border=0 cellpadding=0 cellspacing=0><tr><td>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);

    l_document :=  '<table sumarry="" width=100% border=0 cellpadding=3 cellspacing=1 bgcolor=white> <tr>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    --ACTIVATION DATE
    l_document :=  '<tr>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);

    l_document :=  '<th align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>Activation Date</font></td>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);

    l_document :=  '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_header.start_date_active || '</font></th>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '</tr>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    --EXPIRATION DATE
    l_document := '<tr><th align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>Expiration Date</font></td>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_header.end_date_active || '</font></th></tr>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);

    --MIN AMOUNT
    l_document := '<tr><th align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>Min Amount Agreed</font></td>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || v_min_amount || '</font></th></tr>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);

    --Project Description
    l_document := '<tr><th align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>Comment</font></td>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_header.project_description || '</font></th></tr>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);

    --Vendor Name
    l_document := '<tr><th align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>Vendor Name</font></td>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_header.customer || '</font></th></tr>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);

    --Buyer
    l_document := '<tr><th align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>Buyer</font></td>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_header.buyer || '</font></th></tr>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);

    --Unit
    l_document := '<tr><th align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>Unit</font></td>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_header.unit || '</font></th></tr>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);

    --Category
    l_document := '<tr><th align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>Category</font></td>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_header.category || '</font></th></tr>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);

    --Vendor check
    l_document := '<tr><th align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>Vendor check</font></td>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_header.vendor_check_advice || '</font></th></tr>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);

    --Vendor Check date
    l_document := '<tr><th align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>Vendor Check Date</font></td>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || to_char(l_header.vendor_check_date,'DD-MON-YYYY') || '</font></th></tr>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);

    --Previous Contract
    l_document := '<tr><th align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>Related Blanket Purchase Agreement</font></td>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_header.previous_contract || '</font></th></tr>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);

    --Payment terms
    l_document := '<tr><th align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>Payment Terms</font></td>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_header.payment_terms || '</font></th></tr>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);

    --Currency
    l_document := '<tr><th align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>Currency</font></td>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_header.currency || '</font></th></tr>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    --Central/opco
    l_document := '<tr><th align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>Central/Opco</font></td>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || l_header.central_opco || '</font></th></tr></table></table>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);

    l_document := '<br></br>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '<table width=100% border=0 cellpadding=0 cellspacing=0 ><tr><td>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);

    l_document := '<table sumarry="" width=100% border=0 cellpadding=3 cellspacing=1 bgcolor=white> <tr>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);

    l_document := '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || 'Item Description' || '</font></th>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);

    l_document := '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || 'Line Description' || '</font></th>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);

    l_document := '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || 'Activation Date' || '</font></th>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);

    l_document := '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || 'Expiration Date' || '</font></th>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);

    l_document := '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || 'Year' || '</font></th>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);

    l_document := '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || 'Cost Center' || '</font></th>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document :=  '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || 'OPCO' || '</font></th>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document :=  '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || 'VA Value' || '</font></th>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document :=  '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || 'Purchase Value' || '</font></th></tr>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);

    FOR r_header_details IN c_header_details(l_header_id)
    LOOP
      OPEN c_opco(r_header_details.inventory_item_id
                 ,r_header_details.org_id);
      FETCH c_opco INTO v_opco;
      CLOSE c_opco;
      --
      IF r_header_details.va_value = trunc(r_header_details.va_value) THEN
        v_value := to_char(r_header_details.va_value,'999G999G999');
      ELSE
        v_value := to_char(r_header_details.va_value,'999G999G990D00');
      END IF;
      IF r_header_details.purchase_value = trunc(r_header_details.purchase_value) THEN
        v_value2 := to_char(r_header_details.purchase_value,'999G999G999');
      ELSE
        v_value2 := to_char(r_header_details.purchase_value,'999G999G990D00');
      END IF;

      l_management_sum := r_header_details.management_sum;

      l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || r_header_details.item_description || '</font></td>';
      dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
      l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || r_header_details.line_description || '</font></td>';
      dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
      l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || to_char(r_header_details.start_date_active,'DD-MON-YYYY') || '</font></td>';
      dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
      l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || to_char(r_header_details.end_date_active,'DD-MON-YYYY') || '</font></td>';
      dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
      l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || to_char(r_header_details.start_date_active,'YYYY') || '</font></td>';
      dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
      l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || r_header_details.cost_center || '</font></td>';
      dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
      l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || v_opco || '</font></td>';
      dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
      l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || v_value || '</font></td>';
      dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
      l_document := '<td align=RIGHT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || v_value2 || '</font></td></tr>';
      dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);

    END LOOP;

    l_document := '</TABLE></TD></TR></TABLE></P>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);

    -- totals block
    l_document := '<br><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=4>' || 'Total' ||'</font><br>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);

    l_document := '<table width=50% border=0 cellpadding=0 cellspacing=0 ><tr><td>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);

    l_document := '<table sumarry="" width=100% border=0 cellpadding=3 cellspacing=1 bgcolor=white> <tr>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);

    l_document := '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || 'Year' || '</font></th>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);

    l_document := '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || 'VA Value' || '</font></th>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);

    l_document := '<th scope=col align=LEFT valign=baseline bgcolor=#cccc99><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=2>' || 'Purchase Value' || '</font></th></tr>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    v_total := 0;
    v_total2 := 0;
    FOR v_totals IN c_totals(l_header_id) LOOP
      v_total := v_total + v_totals.va_value;
      v_total2 := v_total2 + v_totals.purchase_value;
      IF v_totals.va_value = trunc(v_totals.va_value) THEN
        v_total_char := to_char(v_totals.va_value,'999G999G999');
      ELSE
        v_total_char := to_char(v_totals.va_value,'999G999G990D00');
      END IF;
      IF v_totals.purchase_value = trunc(v_totals.purchase_value) THEN
        v_total2_char := to_char(v_totals.purchase_value,'999G999G999');
      ELSE
        v_total2_char := to_char(v_totals.purchase_value,'999G999G990D00');
      END IF;

      l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || v_totals.year || '</font></td>';
      dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
      l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || v_total_char || '</font></td>';
      dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
      l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || v_total2_char || '</font></td></tr>';
      dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    END LOOP;
    IF v_total = trunc(v_total) THEN
      v_total_char := to_char(v_total,'999G999G999');
    ELSE
      v_total_char := to_char(v_total,'999G999G990D00');
    END IF;
    IF v_total2 = trunc(v_total2) THEN
      v_total2_char := to_char(v_total2,'999G999G999');
    ELSE
      v_total2_char := to_char(v_total2,'999G999G990D00');
    END IF;
    l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || 'Total' || '</font></td>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2><span style="font-weight:bold;">' || v_total_char || '</span></font></td>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2><span style="font-weight:bold;">' || v_total2_char || '</span></font></td>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);

    l_document := '</TABLE></TD></TR></TABLE></P>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);

    -- management summary
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

    FOR r_approval_history IN c_approval_history(l_header_id)
    LOOP
      l_document := '<tr><td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || to_char(r_approval_history.row_timestamp, 'DD-MON-YYYY hh24:mi:ss') || '</font></td>';
      dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
      l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || r_approval_history.approval_status || '</font></td>';
      dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);

      v_delegate := NULL;
      l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || r_approval_history.full_name || '</font></td>';
      dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
      /*
       * So now i need to get the reason from the XXAHSAA workflow, where the approver equals the name from this cursor...
       */
      v_reject_reason := NULL;
      OPEN c_child(l_master_itemkey
                  ,r_approval_history.name
                  ,r_approval_history.row_timestamp);
      FETCH c_child INTO v_child;
      v_child_found := c_child%FOUND;
      CLOSE c_child;
      BEGIN
        IF v_child_found THEN
          v_reject_reason := wf_engine.GetItemAttrText
                            ( itemType => v_child.item_type
                            , itemKey  => v_child.item_key
                            , aName    => 'REJ_REASON'
                            );
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          v_reject_reason := NULL;
      END;
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
    FOR r_approval_list IN c_approval_list(l_header_id)
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
    IF g_combined = 'Y' THEN
      FOR r_comb_attachments IN c_comb_attachments(b_header_id   => l_header_id
                                                  ,b_po_header_id => g_po_header_id) LOOP
        l_document := '<tr><td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || r_comb_attachments.ROWNUM || '</font></td>';
        dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
        l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || r_comb_attachments.file_name || '</font></td>';
        dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
      END LOOP;
    ELSE
      FOR r_ntf_attachments IN c_ntf_attachments(p_header_id   => l_header_id) LOOP
        l_document := '<tr><td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || r_ntf_attachments.ROWNUM || '</font></td>';
        dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
        l_document := '<td align=LEFT valign=baseline bgcolor=#f7f7e7><font color=black face="Arial, Helvetica, Geneva, sans-serif" size=2>' || r_ntf_attachments.file_name || '</font></td>';
        dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
      END LOOP;
    END IF;
    --
    l_document := '</TABLE></TD></TR></TABLE></P>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    -- JPE, added 09/12/2010 - Add link to open PDF
    OPEN c_ott(l_header_id);
    FETCH c_ott INTO l_layout_template_id;
    IF c_ott%NOTFOUND THEN
      l_layout_template_id := NULL;
    END IF;
    CLOSE c_ott;
    --
    IF l_layout_template_id IS NOT NULL THEN
      l_url_pdf := 'OA.jsp?OAFunc=ONT_PRINT&docId='||l_header_id||'&docType=B&layoutTemplateId='||l_layout_template_id;
      --
      --l_url_pdf := 'http://ngstst.corp.ah.nl:8044/OA_HTML/OA.jsp?OAFunc=ONT_PRINT&docId=5286&docType=B&layoutTemplateId=1164';
      --l_url_pdf := 'OA.jsp?OAFunc=ONT_PRINT&docId='||l_header_id||'&docType=B&layoutTemplateId=1164';
      --
      l_open_contract_pdf := '<a href="'||l_url_pdf||'">Open contract</a>';
      l_document := '<br><font color=#336699 face="Arial, Helvetica, Geneva, sans-serif" size=4>' || l_open_contract_pdf ||'</font><br>';
      dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);
    END IF;

    l_document := '<br><font color=#FF0000 face="Arial, Helvetica, Geneva, sans-serif" size=4>' || 'Please contact buyer before rejecting (to prevent double work)' ||'</font><br>';
    dbms_lob.writeappend(DOCUMENT, length(l_document), l_document);

  END set_transaction_details;

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
  )
  IS
    l_transaction_id    NUMBER;
    v_transaction_type VARCHAR2(100);
  BEGIN
    write_log('begin reset_approval');
    l_transaction_id := wf_engine.GetItemAttrNumber
                       ( itemType => p_itemtype
                       , itemKey  => p_itemkey
                       , aName    => 'HEADER_ID'
                       );
    write_log('l_transaction_id:' || l_transaction_id);
   get_bpa(l_transaction_id);
   IF g_combined = 'Y' THEN
     v_transaction_type := lc_transaction_comb;
   ELSE
     v_transaction_type := lc_transaction_type;
   END IF;

    ame_api2.clearAllApprovals
    ( applicationIdIn   => lc_application_id
    , transactionTypeIn => v_transaction_type
    , transactionIdIn   => l_transaction_id
    );
    write_log('end reset_approval');
  END reset_approval;


PROCEDURE set_attachments
  ( p_itemtype   IN   VARCHAR2
  , p_itemkey    IN   VARCHAR2
  , p_actid      IN   NUMBER
  , p_funcmode   IN   VARCHAR2
  , p_resultout  OUT  VARCHAR2
  )
  IS
    l_transaction_id        NUMBER;
    --l_attachments           attach_rec%TYPE;
--    l_approver              VARCHAR2(100);
--    l_master_itemkey        VARCHAR2(100);
--    l_approval_response     VARCHAR2(100);
--
--    l_parallel_count        NUMBER;
--    l_reject_count          NUMBER;
    i NUMBER;

  BEGIN
    write_log('begin set_attachments');
    IF p_funcmode != 'RUN' THEN
      p_resultout := null;
    ELSE
      -- find header id
      l_transaction_id := wf_engine.GetItemAttrNumber
                         ( itemType => p_itemtype
                         , itemKey  => p_itemkey
                         , aName    => 'XXAH_HEADER_ID'
                         );
      get_bpa(l_transaction_id);

      i := 0;
      IF g_combined = 'Y' THEN
        FOR r_comb_attachments IN c_comb_attachments(b_header_id => to_char(l_transaction_id)
                                                    ,b_po_header_id => to_char(g_po_header_id)) LOOP
          i := i + 1;
          IF i <= 5 THEN
            wf_engine.setitemattrdocument
              ( itemtype=> p_itemtype
              , itemkey=> p_itemkey
              , aname=>  'XX_SC_ATT_' || i
              , documentid =>'PLSQLBLOB:xxah_va_ame_wf_pkg.get_attachment/' ||r_comb_attachments.media_id
              );--  to_char(l_file_id));
          ELSIF i <= 10 THEN
            wf_engine.setitemattrdocument
              ( itemtype=> p_itemtype
              , itemkey=> p_itemkey
              , aname=>  'XX_PD_ATT_' || (i-5)
              , documentid =>'PLSQLBLOB:xxah_va_ame_wf_pkg.get_attachment/' ||r_comb_attachments.media_id
              );--  to_char(l_file_id));
          END IF;
        END LOOP;
      ELSE
      -- Just take first 10 attachments and fill attributes for them, regardless of doc type
      -- only attachments for a document category having notification function assigned will be selected
      --
        FOR r_ntf_attachments IN c_ntf_attachments(p_header_id => l_transaction_id) LOOP
          i := i + 1;
          IF i <= 5 THEN
            wf_engine.setitemattrdocument
              ( itemtype=> p_itemtype
              , itemkey=> p_itemkey
              , aname=>  'XX_SC_ATT_' || i
              , documentid =>'PLSQLBLOB:xxah_va_ame_wf_pkg.get_attachment/' ||r_ntf_attachments.media_id
              );--  to_char(l_file_id));
          ELSIF i <= 10 THEN
            wf_engine.setitemattrdocument
              ( itemtype=> p_itemtype
              , itemkey=> p_itemkey
              , aname=>  'XX_PD_ATT_' || (i-5)
              , documentid =>'PLSQLBLOB:xxah_va_ame_wf_pkg.get_attachment/' ||r_ntf_attachments.media_id
              );--  to_char(l_file_id));
          END IF;
        END LOOP;
      END IF;
    END IF;
  END set_attachments;


PROCEDURE get_attachment
  (
    document_id   IN VARCHAR2
   ,display_type  IN VARCHAR2
   ,DOCUMENT      IN OUT BLOB
   ,document_type IN OUT VARCHAR2
  ) IS
    lob_id       NUMBER;
    bdoc         BLOB;
    content_type VARCHAR2(100);
    filename     VARCHAR2(300);
  BEGIN
    --set_debug_context('xx_notif_attach_procedure');
    lob_id := to_number(document_id);

  FOR  l_attachments IN c_attachments(b_media_id  => lob_id) LOOP
    document_type := l_attachments.file_content_type || ';name=' || l_attachments.file_name;
    dbms_lob.copy(DOCUMENT, l_attachments.file_data, dbms_lob.getlength(l_attachments.file_data));
  END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      --debug('ERROR ^^^^0018 ' || SQLERRM);
      wf_core.CONTEXT('xx_g4g_package'
                     ,'xx_notif_attach_procedure'
                     ,document_id
                     ,display_type);
      RAISE;
  END get_attachment;
  --
  /*
   * procedure checks the lines total with the header amount.
   * if this is not the same the agreement is rejected.
   */
  PROCEDURE check_lines_total
  ( p_itemtype   IN  VARCHAR2
  , p_itemkey    IN  VARCHAR2
  , p_actid      IN  NUMBER
  , p_funcmode   IN  VARCHAR2
  , p_resultout  OUT VARCHAR2
  ) IS
    CURSOR c_lines(b_header_id IN oe_blanket_headers_all.header_id%TYPE) IS
    SELECT bhe.blanket_min_amount
    ,      bha.order_number
    ,      sum(ble.blanket_line_min_amount) line_amount
    ,      bha.org_id org_id
    FROM   oe_blanket_headers_ext bhe
    ,      oe_blanket_headers_all bha
    ,      oe_blanket_lines_ext ble
    WHERE  bha.order_number = bhe.order_number
    AND    bha.order_number = ble.order_number
    AND    bha.header_id = b_header_id
    GROUP BY bha.order_number, bhe.blanket_min_amount, bha.org_id
    ;
    CURSOR c_lines2(b_header_id IN oe_blanket_headers_all.header_id%TYPE
                   ,b_set_name gl_periods.period_set_name%TYPE
                   ,b_type gl_periods.period_type%TYPE) IS
    SELECT count(distinct(ble.period_year))
    FROM   (SELECT gp.period_year
            ,      ble.order_number
            ,      ble.line_number
            FROM   oe_blanket_headers_all bha
            ,      oe_blanket_lines_ext ble
            ,      gl_periods gp
            WHERE  bha.order_number = ble.order_number
            AND    bha.header_id = b_header_id
            AND    gp.period_set_name = b_set_name
            AND    gp.period_type = b_type
            AND    ble.start_date_active BETWEEN gp.start_date AND gp.end_date
            UNION ALL
            SELECT gp.period_year
            ,      ble.order_number
            ,      ble.line_number
            FROM   oe_blanket_headers_all bha
            ,      oe_blanket_lines_ext ble
            ,      gl_periods gp
            WHERE  bha.order_number = ble.order_number
            AND    bha.header_id = b_header_id
            AND    gp.period_set_name = b_set_name
            AND    gp.period_type = b_type
            AND    ble.end_date_active BETWEEN gp.start_date AND gp.end_date
            ) ble
    group by ble.order_number, ble.line_number
    having count(distinct(ble.period_year)) > 1
    ;
    CURSOR c_period(b_org_id hr_organization_information.organization_id%TYPE) IS
    SELECT org_information16 period_set
    ,      org_information17 period_type
    FROM   hr_organization_information hoi
    WHERE  hoi.organization_id = b_org_id
    AND    hoi.org_information_context = 'Operating Unit Information'
    ;
    CURSOR c_period_check(b_set_name gl_periods.period_set_name%TYPE
                         ,b_type gl_periods.period_type%TYPE
                         ,b_header_id oe_blanket_headers_all.header_id%TYPE) IS
    SELECT 1
    FROM   oe_blanket_lines_ext ble
    ,      oe_blanket_headers_all bha
    WHERE  bha.header_id = b_header_id
    AND    bha.order_number = ble.order_number
    AND NOT EXISTS
    (SELECT 1
     FROM   gl_periods gp
     WHERE gp.period_set_name = b_set_name
     AND    gp.period_type = b_type
     AND    ble.end_date_active BETWEEN gp.start_date AND gp.end_date)
    ;
    CURSOR c_co(b_header_id po_headers_all.po_header_id%TYPE) IS
    SELECT papf.person_id
    ,      ph.revision_num
    FROM  po_headers_all ph
    ,     per_all_people_f papf
    WHERE ph.po_header_id = b_header_id
    AND   fnd_number.canonical_to_number(ph.attribute11) = papf.person_id(+)
    AND   SYSDATE BETWEEN NVL(papf.effective_start_date(+), SYSDATE)
                      AND NVL(papf.effective_end_date(+), SYSDATE)
    ;
    CURSOR c_le(b_header_id po_headers_all.po_header_id%TYPE
               ,b_doc_type okc_template_usages.document_type%TYPE) IS
    SELECT legalppl.person_id
    FROM okc_template_usages     usg
    ,    okc_terms_templates_all tmpl
    ,    okc_resp_parties_vl     party
    ,    fnd_lookups             ksrc
    ,    okc_bus_doc_types_b     busdoc
    ,    fnd_user                lglcont
    ,    per_all_people_f        legalppl
    WHERE usg.template_id = tmpl.template_id(+)
      AND busdoc.document_type_class = party.document_type_class
      AND busdoc.document_type = usg.document_type
      AND busdoc.intent = party.intent
      AND usg.authoring_party_code = party.resp_party_code
      AND ksrc.lookup_type = 'OKC_CONTRACT_TERMS_SOURCES'
      AND ksrc.lookup_code = usg.contract_source_code
      AND usg.legal_contact_id = lglcont.user_id
      AND lglcont.employee_id = legalppl.person_id
      AND usg.document_id = b_header_id
      AND usg.document_type = b_doc_type
    ;
    v_lines c_lines%ROWTYPE;
    v_transaction_id    NUMBER;
    v_approver VARCHAR2(255);
    v_dummy NUMBER;
    v_found BOOLEAN;
    v_period_found BOOLEAN;
    v_text VARCHAR2(2000);
    v_period c_period%ROWTYPE;
    v_person_id per_all_people_f.person_id%TYPE;
    v_revision_num po_headers_all.revision_num%TYPE;
    v_count PLS_INTEGER;
  BEGIN
    write_log('Start check lines total');
    p_resultout := 'COMPLETE:Y';
    IF p_funcmode != 'RUN' THEN
      p_resultout := null;
    ELSE
      v_transaction_id := wf_engine.GetItemAttrNumber
                         ( itemType => p_itemtype
                         , itemKey  => p_itemkey
                         , aName    => 'HEADER_ID'
                          );
      OPEN c_lines(v_transaction_id);
      FETCH c_lines INTO v_lines;
      CLOSE c_lines;
      v_approver := wf_engine.GetItemAttrText
                       ( itemType => p_itemtype
                       , itemKey  => p_itemkey
                       , aName    => 'NOTIFICATION_FROM_ROLE'
                        );
      IF v_lines.blanket_min_amount != nvl(v_lines.line_amount,-1) THEN
         v_text := 'The header amount ('||v_lines.blanket_min_amount||
                   ') does not equal the sum of the lines amount ('||v_lines.line_amount||').';
      END IF;
      write_log('Start check duration lines');
      /*
       * Check 2: Lines must not span across more than one year.
       * Note: this is the book year, not neccisarily the calendar year...
       * the calendar %PS is assumed, strange one, has no statuses,
       * and there are four different period types in the same set?
       */
      OPEN c_period(v_lines.org_id);
      FETCH c_period INTO v_period;
      CLOSE c_period;
      --
      OPEN c_period_check(v_period.period_set
                         ,v_period.period_type
                         ,v_transaction_id);
      FETCH c_period_check INTO v_dummy;
      v_period_found := c_period_check%FOUND;
      CLOSE c_period_check;
      IF v_period_found THEN
         IF v_text IS NULL THEN
           v_text := 'There is no period defined for the last date of the contract.';
         ELSE
           v_text := v_text||' and there is no period defined for the last date of the contract.';
         END IF;
      END IF;
      --
      IF fnd_profile.VALUE( 'XXAH_VA_DISABLE_MULTI_YEAR_LINES' ) = 'Y'
      THEN
        OPEN c_lines2(v_transaction_id
                     ,v_period.period_set
                     ,v_period.period_type);
        FETCH c_lines2 INTO v_dummy;
        v_found := c_lines2%FOUND;
        CLOSE c_lines2;
        IF v_found THEN
           IF v_text IS NULL THEN
             v_text := 'Lines must not span multiple years.';
           ELSE
             v_text := v_text||' And lines must not span multiple years.';
           END IF;
        END IF;
      END IF; -- Dependant on profile value
      --
      /*
       * Check 4: mandatory field checks for related BPA.
       */
      g_header_id := NULL; --check needs to fetch always...
      get_bpa(v_transaction_id);
      IF g_combined = 'Y' THEN
        IF nvl(g_flag,'@') != 'Y' OR g_status != 'IN PROCESS' THEN
          IF v_text IS NULL THEN
            IF g_status != 'IN PROCESS' THEN
              v_text := 'Related BPA is on status '||g_status;
            ELSE
              v_text := 'Related BPA is not on hold, submit BPA first.';
            END IF;
          ELSE
            IF g_status != 'IN PROCESS' THEN
              v_text := 'And related BPA is on status '||g_status;
            ELSE
              v_text := v_text||' And related BPA is not on hold, submit BPA first.';
            END IF;
          END IF;
        ELSE
          IF g_status = 'IN PROCESS' THEN
            /*
             * Check if bpa is linked to another combined VA...
             */
            OPEN c_va(g_po_header_id);
            FETCH c_va INTO v_count;
            CLOSE c_va;
            IF v_count > 1 THEN
              IF v_text IS NULL THEN
                v_text := 'Related BPA is linked to another Combined VA.';
              ELSE
                v_text := v_text||' And related BPA is linked to another Combined VA.';
              END IF;
            END IF;
          END IF;
        END IF;
        v_person_id := NULL;
        OPEN c_co(g_po_header_id);
        FETCH c_co INTO v_person_id, v_revision_num;
        CLOSE c_co;
        IF v_revision_num > 0 THEN
          IF v_text IS NULL THEN
            v_text := 'Revision of related BPA is '||v_revision_num;
          ELSE
            v_text := v_text||' And Revision of related BPA is '||v_revision_num;
          END IF;
        END IF;
        --
        IF v_person_id IS NULL THEN
          IF v_text IS NULL THEN
            v_text := 'Controller of related BPA is empty.';
          ELSE
            v_text := v_text||' And Controller of related BPA is empty.';
          END IF;
        END IF;
        --
        v_person_id := NULL;
        OPEN c_le(g_po_header_id
                 ,'PA_BLANKET');
        FETCH c_le INTO v_person_id;
        CLOSE c_le;
        IF v_person_id IS NULL THEN
          IF v_text IS NULL THEN
            v_text := 'Legal and/or Contract administrator of related BPA is empty.';
          ELSE
            v_text := v_text||' And Legal and/or Contract administrator of related BPA is empty.';
          END IF;
        END IF;
      END IF;
      /*
       * Check 5: legal and contract admin need to be filled.
       */
      v_person_id := NULL;
      OPEN c_le(v_transaction_id
                ,'B');
      FETCH c_le INTO v_person_id;
      CLOSE c_le;
      IF v_person_id IS NULL THEN
        IF v_text IS NULL THEN
          v_text := 'Legal and/or Contract administrator is empty.';
        ELSE
          v_text := v_text||' And Legal and/or Contract administrator is empty.';
        END IF;
      END IF;
      --
      IF v_text IS NOT NULL THEN
         wf_engine.SetItemAttrText
          ( itemType => p_itemtype
          , itemKey  => p_itemkey
          , aName    => 'NOTIFICATION_APPROVER'
          , aValue   => v_approver
          );
         wf_engine.SetItemAttrText
          ( itemType => p_itemtype
          , itemKey  => p_itemkey
          , aName    => 'XXAH_MESSAGE'
          , aValue   => v_text
          );
          p_resultout := 'COMPLETE:N';
      END IF;
    END IF;
    write_log('End check lines total');
  EXCEPTION
    WHEN OTHERS THEN
      write_log('Error in set_header_total: '||v_transaction_id);
      write_log('Error in set_header_total: '||SQLERRM);
      p_resultout := 'COMPLETE:N';
  END check_lines_total;




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

  v_response_reason   VARCHAR2(4000);
  l_result            VARCHAR2(100);
  l_master_itemkey    VARCHAR2(100);

BEGIN
  IF (p_funcmode IN ('RESPOND'))
  THEN

    OPEN c_ntf_result(WF_ENGINE.context_nid);
    FETCH c_ntf_result INTO l_result;
    IF c_ntf_result %NOTFOUND THEN
      l_result := '#NORESULT';
    END IF;
    CLOSE c_ntf_result;


     -- Mandatory reject_reason when response is REJECT
    v_response_reason := wf_notification.getattrtext(wf_engine.context_nid
                                                    ,'REJ_REASON');
    IF l_result = 'REJECT' AND
       v_response_reason IS NULL
    THEN
      p_resultout := 'ERROR: You must enter rejection reason if rejecting.';
      RETURN;
    END IF;
    IF l_result = 'REJECT' AND v_response_reason IS NOT NULL THEN
      BEGIN
        IF p_itemtype = 'OENH' THEN
          l_master_itemkey := wf_engine.GetItemAttrText
                              ( itemType => p_itemtype
                              , itemKey  => p_itemkey
                              , aName    => 'HEADER_ID'
                              );
        ELSIF p_itemtype = 'XXAHSAA' THEN
          l_master_itemkey := wf_engine.GetItemAttrText
                              ( itemType => p_itemtype
                              , itemKey  => p_itemkey
                              , aName    => 'XXAH_MASTER_ITEM_KEY'
                              );
        END IF;
        wf_engine.SetItemAttrText(itemtype => 'OENH'
                                 ,itemkey => l_master_itemkey
                                 ,aname => 'XXAH_REJ_REASON'
                                 ,avalue => v_response_reason);
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END IF;
    -- End madatory reject reason check
    p_resultout := wf_engine.eng_null;
  ELSE
    p_resultout := wf_engine.eng_null;
  END IF;
EXCEPTION
  WHEN others THEN
    Wf_Core.CONTEXT('Wf_Standard', 'VoteForResultType',p_itemtype,
                    p_itemkey, to_char(p_actid), p_funcmode);
    RAISE;
END PostNtfFunction;
  --
  PROCEDURE process_related_bpa
  ( p_itemtype   IN  VARCHAR2
  , p_itemkey    IN  VARCHAR2
  , p_actid      IN  NUMBER
  , p_funcmode   IN  VARCHAR2
  , p_resultout  OUT VARCHAR2
  ) IS
    CURSOR c_po(b_header_id po_headers_all.po_header_id%TYPE) IS
    SELECT wf_item_type
    ,      wf_item_key
    ,      authorization_status
    FROM   po_headers_all po
    WHERE  po_header_id = b_header_id
    ;
    l_transaction_id NUMBER;
    v_result VARCHAR(100);
    v_resultout VARCHAR(1000);
    v_item_type po_headers_all.wf_item_type%TYPE;
    v_item_key po_headers_all.wf_item_key%TYPE;
    v_status po_headers_all.authorization_status%TYPE;
    v_count PLS_INTEGER;
  BEGIN
    IF p_funcmode != 'RUN' THEN
      p_resultout := wf_engine.eng_null;
    ELSE
      --  schop los als combined
      l_transaction_id := wf_engine.GetItemAttrNumber
                         ( itemType => p_itemtype
                         , itemKey  => p_itemkey
                         , aName    => 'HEADER_ID'
                          );
      get_bpa(l_transaction_id);
      IF g_combined = 'Y' THEN
        v_result := wf_engine.getactivityattrtext(p_itemtype, p_itemkey, p_actid, 'XXAH_RESULT',TRUE);
        OPEN c_po(g_po_header_id);
        FETCH c_po INTO v_item_type, v_item_key, v_status;
        CLOSE c_po;
        IF v_item_key IS NOT NULL AND v_status = 'IN PROCESS' THEN
          BEGIN
            -- but only if it is not linked to another va which is in process...
            OPEN c_va3(g_po_header_id
                      ,l_transaction_id);
            FETCH c_va3 INTO v_count;
            CLOSE c_va3;
            IF v_count = 0 THEN -- if higher it will be completed by the next.
              wf_engine.CompleteActivity(v_item_type, v_item_key, 'XXAH_BLANKET_APPROVAL:XXAH_BLOCK', v_result);
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              /*
               * for some reason sometimes the wrong bpa gets selected, then this activity crashes,
               * and the va cannot be resubmitted. This happens when the va gets rejected.
               * In that case the bpa can also stay as on hold.
               */
              NULL;
          END;
        END IF;
      END  IF;
    END IF;
    p_resultout := wf_engine.eng_null;
  END process_related_bpa;
END XXAH_VA_AME_WF_PKG;

/
