--------------------------------------------------------
--  DDL for Package Body PON_MASS_UPDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_MASS_UPDATE_PVT" AS
  /* $Header: PON_MASS_UPDATE_PVT.plb 120.0.12010000.13 2013/09/06 06:28:26 nrayi noship $ */
PROCEDURE validate_buyer(
    p_new_buyer_user_id IN NUMBER,
    is_valid_buyer OUT NOCOPY  VARCHAR2,
    p_msg_data OUT NOCOPY      VARCHAR2,
    p_msg_count OUT NOCOPY     NUMBER,
    p_return_status OUT NOCOPY VARCHAR2);
PROCEDURE validate_resp_org_access(
    p_auction_header_id NUMBER,
    p_user_id IN NUMBER,
    x_has_access OUT NOCOPY    VARCHAR2,
    p_msg_data OUT NOCOPY      VARCHAR2,
    p_msg_count OUT NOCOPY     NUMBER,
    p_return_status OUT NOCOPY VARCHAR2);
  --------------------------------------------------------------------------------------------------
  -- Start of Comments
  -- API Name   : pon_update_buyer
  -- Type       : Private
  -- Pre-reqs   : None
  -- Function   : Calls the procedure to update the Buyer person
  --              accordingly to the input received.
  -- Parameters :
  -- IN         : p_old_buyer_id         Id of the old person.
  --  p_new_buyer_id         Id of the new person.
  --  p_doc_no_from          Document number from.
  --  p_doc_no_to            Document number to.
  --   p_date_from            Date from.
  --  p_date_to              Date to.
  --  p_commit_intrl         Commit interval.
  --  p_simulate             Simulate.
  -- OUT        : EFFBUF             Actual message in encoded format.
  --  RETCODE        Return status of the API .
  -- End of Comments
  --------------------------------------------------------------------------------------------------
PROCEDURE pon_update_buyer(
    EFFBUF OUT NOCOPY  VARCHAR2,
    RETCODE OUT NOCOPY VARCHAR2,
    p_old_buyer_id IN NUMBER,
    p_new_buyer_id IN NUMBER,
    p_doc_no_from  IN NUMBER,
    p_doc_no_to    IN NUMBER,
    p_date_from    IN VARCHAR2,
    p_date_to      IN VARCHAR2,
    p_commit_intrl IN NUMBER,
    p_simulate     IN VARCHAR2 )
AS
  CURSOR c_approval_rec(p_auction_header_id NUMBER)
  IS
    SELECT user_id
    FROM pon_neg_team_members
    WHERE auction_header_id    = p_auction_header_id
    AND APPROVER_FLAG          = 'Y';
  l_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_msg_count     NUMBER;
  l_msg_data      VARCHAR2(2000);
  l_old_user_id fnd_user.user_id%TYPE;
  l_old_person_party_id fnd_user.person_party_id%TYPE;
  l_new_user_id fnd_user.user_id%TYPE;
  l_new_user_name fnd_user.user_name%TYPE;
  l_old_user_name fnd_user.user_name%TYPE;
  l_new_person_party_id fnd_user.person_party_id%TYPE;
  stmt_neg VARCHAR2(4000);
  c_auc g_auc;
  l_auction_header_id pon_auction_headers_all.auction_header_id%TYPE;
  l_auction_status pon_auction_headers_all.auction_status%TYPE;
  l_award_approval_status pon_auction_headers_all.award_approval_status%TYPE;
  l_approval_status pon_auction_headers_all.approval_status%TYPE;
  l_amendment_number pon_auction_headers_all.amendment_number%TYPE;
  l_neg_team_enabled_flag pon_auction_headers_all.neg_team_enabled_flag%TYPE;
  l_first_name HZ_PARTIES.PERSON_FIRST_NAME%TYPE;
  l_last_name HZ_PARTIES.PERSON_LAST_NAME%TYPE;
  l_count         NUMBER;
  l_itemtype      VARCHAR2(8);
  l_itemkey       VARCHAR2(50);
  l_award_itemkey VARCHAR2(50);
  l_item_key      VARCHAR2(50);
  l_notification_id wf_notifications.notification_id%TYPE;
  l_preparer_id VARCHAR2(4000);
  l_approval_rec c_approval_rec%ROWTYPE;
  l_has_access     VARCHAR(1);
  l_is_valid_buyer VARCHAR(1);
  l_old_buyer_name VARCHAR2(4000);
  l_new_buyer_name VARCHAR2(4000);
  l_doc_number_from pon_auction_headers_all.document_number%TYPE;
  l_doc_number_to pon_auction_headers_all.document_number%TYPE;
  l_documnet_number pon_auction_headers_all.document_number%TYPE;
  l_doctype_id pon_auction_headers_all.doctype_id%TYPE;
  l_award_app_user_name fnd_user.user_name%TYPE;
  l_log_head     CONSTANT VARCHAR2(1000) := g_pkg_name||'.'||'pon_update_buyer';
  l_progress     VARCHAR2(3)             := '000';
  l_commit_count NUMBER                  := 0;
  -- Variables used in OKC API.
  l_document_id pon_auction_headers_all.auction_header_id%TYPE;
  l_conterms_exist_flag pon_auction_headers_all.conterms_exist_flag%TYPE;
  l_contracts_document_type VARCHAR2(150);
  SUBTYPE busdocs_tbl_type
IS
  okc_manage_deliverables_grp.busdocs_tbl_type;
  l_busdocs_tbl busdocs_tbl_type;
  l_empty_busdocs_tbl busdocs_tbl_type;
  l_row_index PLS_INTEGER := 0;
  l_msg16 VARCHAR2(240);
  l_old_emp_id fnd_user.employee_id%TYPE;
  l_new_emp_id fnd_user.employee_id%TYPE;
  l_simulate VARCHAR2(1):='N';
  l_auction_title pon_auction_headers_all.auction_title%TYPE;
  l_doc_type_name fnd_lookups.meaning%TYPE;
  p_msg_data      VARCHAR2(1000);
  p_msg_count     NUMBER;
  p_return_status VARCHAR2(100);
  l_msg           VARCHAR2 (2000);
BEGIN
  l_progress := '000';
  print_log(l_log_head,l_progress, 'Begin: start of pon_update_buyer procedure');
  l_simulate:= NVL(p_simulate,'N');
  print_log(l_log_head,l_progress, 'p_old_buyer_id => '||p_old_buyer_id);
  print_log(l_log_head,l_progress, 'p_new_buyer_id => '||p_new_buyer_id);
  print_log(l_log_head,l_progress, 'p_doc_no_from => '||p_doc_no_from);
  print_log(l_log_head,l_progress, 'p_doc_no_to => '||p_doc_no_to);
  print_log(l_log_head,l_progress, 'p_date_from => '||p_date_from);
  print_log(l_log_head,l_progress, 'p_date_to => '||p_date_to);
  print_log(l_log_head,l_progress, 'p_commit_intrl => '||p_commit_intrl);
  print_log(l_log_head,l_progress, 'l_simulate => '||l_simulate);
  BEGIN
    -- getting the buyer information
    SELECT employee_id,
      person_party_id,
      user_name
    INTO l_old_emp_id,
      l_old_person_party_id,
      l_old_user_name
    FROM fnd_user
    WHERE user_id= p_old_buyer_id;
    SELECT employee_id,
      person_party_id,
      user_name
    INTO l_new_emp_id,
      l_new_person_party_id,
      l_new_user_name
    FROM fnd_user
    WHERE user_id               = p_new_buyer_id
    AND start_date             <= SYSDATE
    AND NVL(end_date, SYSDATE) >= SYSDATE;
    l_old_user_id              := p_old_buyer_id;
    l_new_user_id              := p_new_buyer_id;
    l_old_buyer_name           := pon_locale_pkg.get_party_display_name(l_old_person_party_id);
    l_new_buyer_name           :=pon_locale_pkg.get_party_display_name(l_new_person_party_id);
    validate_buyer(l_new_user_id,l_is_valid_buyer,p_msg_data,p_msg_count,p_return_status );
    IF p_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RETURN;
    END IF;
    IF(l_is_valid_buyer= 'N' ) THEN
      print_log(l_log_head,l_progress, 'Not a valid buyer');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      RETURN;
    END IF;
    -- updating the global variables
    g_old_personid     := l_old_person_party_id;
    g_document_no_from := p_doc_no_from;
    g_document_no_to   := p_doc_no_to;
    g_date_from        := to_date(p_date_from,'YYYY/MM/DD HH24:MI:SS');
    g_date_to          := to_date(p_date_to,'YYYY/MM/DD HH24:MI:SS');
    l_progress         := '002';
    fnd_message.set_name('PON','PON_MUB_MSG_NEW_APPROVER');
    l_msg16 := fnd_message.get;
    print_log(l_log_head,l_progress, 'Generating the select statement');
    stmt_neg:= 'select auction_header_id,
                   document_number,
                   auction_status,
                   award_approval_status,
                   approval_status,
                   neg_team_enabled_flag,
                   amendment_number,
                   WF_APPROVAL_ITEM_KEY,
                   WF_AWARD_APPROVAL_ITEM_KEY,
                   conterms_exist_flag,
                   doctype_id,
                   auction_title
              from pon_auction_headers_all
              where trading_partner_contact_id = pon_mass_update_pvt.get_old_person_id
              and auction_status not in (''DELETED'', ''CANCELLED'')
              and nvl(is_paused,''N'') = ''N''
			  and nvl(is_template_flag,''N'') = ''N'' ';
    IF p_doc_no_from IS NOT NULL THEN
      stmt_neg       := stmt_neg || ' AND auction_header_id >=  pon_mass_update_pvt.get_document_no_from ';
      SELECT document_number
      INTO l_doc_number_from
      FROM pon_auction_headers_all
      WHERE auction_header_id = p_doc_no_from;
    END IF;
    IF p_doc_no_to IS NOT NULL THEN
      stmt_neg     := stmt_neg || ' AND auction_header_id <=  pon_mass_update_pvt.get_document_no_to ';
      SELECT document_number
      INTO l_doc_number_to
      FROM pon_auction_headers_all
      WHERE auction_header_id = p_doc_no_to;
    END IF;
    IF p_date_from IS NOT NULL THEN
      stmt_neg     := stmt_neg || ' AND creation_date >=  pon_mass_update_pvt.get_date_from ';
    END IF;
    IF p_date_to IS NOT NULL THEN
      stmt_neg   := stmt_neg || ' AND creation_date <=  pon_mass_update_pvt.get_date_to ';
    END IF;
    l_progress := '003';
    print_log(l_log_head,l_progress, 'Printing the header output log');
    -- printing the header information
   Print_Output( l_old_buyer_name,
              l_new_buyer_name,
              l_doc_number_from,
              l_doc_number_to,
              g_date_from,
              g_date_to,
              p_commit_intrl,
              l_simulate,
              p_msg_data,
              p_msg_count,
              p_return_status);
    IF p_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RETURN;
    END IF;
    print_log(l_log_head,l_progress, 'stmt_neg => '||stmt_neg);
    -- opening the cursor
    OPEN c_auc FOR stmt_neg;
    LOOP
      FETCH c_auc
      INTO l_auction_header_id,
        l_documnet_number,
        l_auction_status,
        l_award_approval_status,
        l_approval_status,
        l_neg_team_enabled_flag,
        l_amendment_number,
        l_itemkey,
        l_award_itemkey,
        l_conterms_exist_flag,
        l_doctype_id,
        l_auction_title;
      EXIT
    WHEN c_auc%NOTFOUND;
      BEGIN
        l_progress := '004';
        print_log(l_log_head,l_progress, 'l_auction_header_id => '||l_auction_header_id);
        print_log(l_log_head,l_progress, 'l_documnet_number => '||l_documnet_number);
        print_log(l_log_head,l_progress, 'l_auction_status => '||l_auction_status);
        print_log(l_log_head,l_progress, 'l_award_approval_status => '||l_award_approval_status);
        print_log(l_log_head,l_progress, 'l_approval_status => '||l_approval_status);
        print_log(l_log_head,l_progress, 'l_neg_team_enabled_flag => '||l_neg_team_enabled_flag);
        print_log(l_log_head,l_progress, 'l_amendment_number => '||l_amendment_number);
        print_log(l_log_head,l_progress, 'l_itemkey => '||l_itemkey);
        print_log(l_log_head,l_progress, 'l_award_itemkey => '||l_award_itemkey);
        print_log(l_log_head,l_progress, 'l_conterms_exist_flag => '||l_conterms_exist_flag);
        print_log(l_log_head,l_progress, 'l_doctype_id => '||l_doctype_id);
        -- validating the org access
        validate_resp_org_access(l_auction_header_id,l_new_user_id,l_has_access,p_msg_data,p_msg_count,p_return_status);
        IF(l_has_access = 'N') THEN
          print_log(l_log_head,l_progress, 'user donot have the org access for the auction_header_id => '||l_auction_header_id);
          CONTINUE;
        END IF;
        l_progress := '005';
        print_log(l_log_head,l_progress, 'Updating pon_auction_headers_all table');
        SELECT fl1.meaning
        INTO l_doc_type_name
        FROM fnd_lookups fl1,
          pon_auc_doctypes doc
        WHERE fl1.lookup_type = 'PON_AUCTION_DOC_TYPES'
        AND fl1.lookup_code   = doc.internal_name
        AND doc.DOCTYPE_ID    = l_doctype_id;
        -- Updating the auction headers all table
        -- update trading partner contact
        IF(l_simulate='N') THEN
          UPDATE PON_AUCTION_HEADERS_ALL
          SET TRADING_PARTNER_CONTACT_ID   = l_new_person_party_id,
            LAST_UPDATE_DATE               = SYSDATE,
            LAST_UPDATED_BY                = fnd_global.user_id,
            TRADING_PARTNER_CONTACT_NAME   = l_new_user_name
          WHERE TRADING_PARTNER_CONTACT_ID = l_old_person_party_id
          AND auction_header_id            = l_auction_header_id;
          -- update draft locked by column
          UPDATE PON_AUCTION_HEADERS_ALL
          SET LAST_UPDATE_DATE             = SYSDATE,
            LAST_UPDATED_BY                = fnd_global.user_id,
            DRAFT_LOCKED_BY_CONTACT_ID     = l_new_person_party_id
          WHERE DRAFT_LOCKED_BY_CONTACT_ID = l_old_person_party_id
          AND auction_header_id            = l_auction_header_id;
          UPDATE PON_AUCTION_HEADERS_ALL
          SET LAST_UPDATE_DATE  = SYSDATE,
            LAST_UPDATED_BY     = fnd_global.user_id,
            BUYER_ID            = l_new_user_id
          WHERE BUYER_ID        = l_old_user_id
          AND auction_header_id = l_auction_header_id;
          -- updating the collaboration team
          IF(NVL(l_neg_team_enabled_flag,'N')='Y') THEN
            l_progress                      := '006';
            print_log(l_log_head,l_progress, 'Updating pon_neg_team_members table');
            SELECT COUNT(*)
            INTO l_count
            FROM PON_NEG_TEAM_MEMBERS pnt
            WHERE pnt.auction_header_id = l_auction_header_id
            AND pnt.list_id             = -1
            AND pnt.user_id             = l_new_user_id;
            IF (l_count                 > 0 ) THEN
              -- if user already exists then update the user as creator and give the user full access
              UPDATE PON_NEG_TEAM_MEMBERS pntm
              SET pntm.member_type       = 'C' ,
                menu_name                = 'PON_SOURCING_EDITNEG'
              WHERE pntm.USER_ID         = l_new_user_id
              AND pntm.auction_header_id = l_auction_header_id;
            ELSE
              -- Insert the new buyer as creator and give the user full access
              INSERT
              INTO PON_NEG_TEAM_MEMBERS
                (
                  auction_header_id,
                  list_id ,
                  user_name ,
                  menu_name ,
                  member_type ,
                  approver_flag ,
                  task_name ,
                  target_date ,
                  last_amendment_update,
                  creation_date ,
                  created_by ,
                  last_update_date ,
                  last_updated_by ,
                  user_id
                )
                VALUES
                (
                  l_auction_header_id,
                  -1 ,
                  NULL ,
                  'PON_SOURCING_EDITNEG' ,
                  'C' ,
                  'N' ,
                  NULL ,
                  NULL ,
                  l_amendment_number ,
                  sysdate ,
                  fnd_global.user_id ,
                  sysdate ,
                  fnd_global.user_id ,
                  l_new_user_id
                );
            END IF;
            -- update the old buyer as member
            UPDATE PON_NEG_TEAM_MEMBERS pntm
            SET pntm.member_type       = 'N'
            WHERE pntm.USER_ID         = l_old_user_id
            AND pntm.auction_header_id = l_auction_header_id;
          END IF;
          l_progress := '007';
          -- update online discussions
          print_log(l_log_head,l_progress, 'Updating PON_DISCUSSIONS table');
          UPDATE PON_DISCUSSIONS
          SET OWNER_PARTY_ID   = l_new_person_party_id,
            LAST_UPDATE_DATE   = SYSDATE
          WHERE OWNER_PARTY_ID = l_old_person_party_id
          AND PK1_VALUE        = l_auction_header_id;
          print_log(l_log_head,l_progress, 'Updating pon_bid_headers table');
          -- update surrogate bid contact id, trading partner name
          UPDATE PON_BID_HEADERS
          SET LAST_UPDATE_DATE                = SYSDATE,
            LAST_UPDATED_BY                   = fnd_global.user_id,
            SURROG_BID_CREATED_CONTACT_ID     = l_new_person_party_id
          WHERE SURROG_BID_CREATED_CONTACT_ID = l_old_person_party_id
          AND auction_header_id               = l_auction_header_id;
          UPDATE PON_BID_HEADERS
          SET LAST_UPDATE_DATE             = SYSDATE,
            LAST_UPDATED_BY                = fnd_global.user_id,
            DRAFT_LOCKED_BY_CONTACT_ID     = l_new_person_party_id
          WHERE DRAFT_LOCKED_BY_CONTACT_ID = l_old_person_party_id
          AND auction_header_id            = l_auction_header_id;
          UPDATE PON_BID_HEADERS
          SET LAST_UPDATE_DATE               = SYSDATE,
            LAST_UPDATED_BY                  = fnd_global.user_id,
            TRADING_PARTNER_CONTACT_NAME     = l_new_user_name
          WHERE TRADING_PARTNER_CONTACT_NAME = l_old_user_name
          AND auction_header_id              = l_auction_header_id;
          -- updating the workflow attributes
          IF(l_approval_status = 'INPROCESS') THEN
            l_itemtype        := 'PONAPPRV';
            wf_engine.SetItemAttrText ( itemtype => l_itemtype, itemkey => l_itemkey, aname => 'CREATOR_USER_NAME' , avalue => l_new_user_name);
            l_progress := '008';
            print_log(l_log_head,l_progress, 'auction approval status itemtype => '||l_itemtype|| 'itemkey => '||l_itemkey);
            OPEN c_approval_rec(l_auction_header_id);
            LOOP
              FETCH c_approval_rec INTO l_approval_rec;
              EXIT
            WHEN c_approval_rec%NOTFOUND;
              BEGIN
                l_progress := '009';
                l_item_key := l_itemkey||'_'||TO_CHAR(l_approval_rec.user_id);
                print_log(l_log_head,l_progress, 'auction approval status itemtype => '||l_itemtype|| 'itemkey => '||l_item_key);
                wf_engine.SetItemAttrText ( itemtype => l_itemtype, itemkey => l_item_key, aname => 'CREATOR_USER_NAME' , avalue => l_new_user_name);
                -- if the old buyer is the approval forward the notification to new buyer
                IF(l_approval_rec.user_id = l_old_user_id) THEN
                  BEGIN
                    SELECT wfn.notification_id
                    INTO l_notification_id
                    FROM wf_notifications wfn,
                      wf_item_activity_statuses wfa
                    WHERE wfn.notification_id = wfa.notification_id
                    AND wfa.item_type         = l_itemtype
                    AND wfa.item_key          = l_item_key
                    AND wfn.status NOT       IN ('CLOSED','CANCELED')
                    AND wfn.recipient_role    = l_old_user_name;
                  EXCEPTION
                  WHEN OTHERS THEN
                    l_notification_id := -1;
                  END;
                END IF;
                IF(NVL(l_notification_id,-1)>0) THEN
                  l_progress               := '010';
                  print_log(l_log_head,l_progress, 'Forwarding the notification l_notification_id  => '||l_notification_id);
                  Wf_Notification.Forward(l_notification_id, l_new_user_name,l_msg16);
                END IF;
              END;
            END LOOP;
            CLOSE c_approval_rec;
          END IF;
          IF(l_award_approval_status = 'INPROCESS') THEN
            l_itemtype              := 'PONAWAPR';
            l_progress              := '011';
            print_log(l_log_head,l_progress, 'award approval status itemtype => '||l_itemtype|| 'itemkey => '||l_award_itemkey);
            wf_engine.SetItemAttrText ( itemtype => l_itemtype, itemkey => l_award_itemkey, aname => 'ORIGIN_USER_NAME' , avalue => l_new_user_name);
            wf_engine.SetItemAttrText ( itemtype => l_itemtype, itemkey => l_award_itemkey, aname => 'PREPARER_TP_CONTACT_NAME' , avalue => l_new_user_name);
            l_award_app_user_name   := wf_engine.GetItemAttrText ( itemtype => l_itemtype, itemkey => l_award_itemkey, aname => 'APPROVER_USER');
            IF(l_award_app_user_name = l_old_user_name ) THEN
              BEGIN
                SELECT wfn.notification_id
                INTO l_notification_id
                FROM wf_notifications wfn,
                  wf_item_activity_statuses wfa
                WHERE wfn.notification_id = wfa.notification_id
                AND wfa.item_type         = l_itemtype
                AND wfa.item_key          = l_award_itemkey
                AND wfn.status NOT       IN ('CLOSED','CANCELED')
                AND wfn.recipient_role    = l_old_user_name;
              EXCEPTION
              WHEN OTHERS THEN
                l_notification_id := -1;
              END;
              IF(NVL(l_notification_id,-1)>0) THEN
                l_progress               := '012';
                print_log(l_log_head,l_progress, 'Forwarding the notification l_notification_id  => '||l_notification_id);
                Wf_Notification.Forward(l_notification_id, l_new_user_name,l_msg16);
              END IF;
            END IF;
          END IF;
          l_progress := '013';
          print_log(l_log_head,l_progress, 'updated the document auction_header_id  => '||l_auction_header_id);
          l_commit_count                               := l_commit_count + 1;
          IF(NVL(l_conterms_exist_flag,'N')             = 'Y') THEN
            l_row_index                                := l_row_index + 1;
            l_busdocs_tbl(l_row_index).bus_doc_id      := l_auction_header_id;
            l_busdocs_tbl(l_row_index).bus_doc_version := -99;
            l_contracts_document_type                  := PON_CONTERMS_UTL_PVT.get_negotiation_doc_type(l_doctype_id);
            l_busdocs_tbl(l_row_index).bus_doc_type    := l_contracts_document_type;
          END IF;
          IF l_commit_count          = p_commit_intrl THEN
            IF (l_busdocs_tbl.COUNT >= 1) THEN
              okc_manage_deliverables_grp.updateIntContactOnDeliverables (
			p_api_version                  => 1.0,
			p_init_msg_list                => FND_API.G_FALSE,
	                p_commit                       => FND_API.G_FALSE,
		        p_bus_docs_tbl                 => l_busdocs_tbl,
	                p_original_internal_contact_id => l_old_emp_id,
		        p_new_internal_contact_id      => l_new_emp_id,
	                x_msg_data                     => p_msg_data,
		        x_msg_count                    => p_msg_count,
	                x_return_status                => p_return_status);
              IF (p_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                FND_MSG_PUB.Count_and_Get(p_count => p_msg_count,p_data => p_msg_data);
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
            END IF;
            COMMIT;
            l_commit_count := 0;
            l_busdocs_tbl  := l_empty_busdocs_tbl;
            l_row_index    := 0;
          END IF;
        END IF;
        fnd_file.put_line(fnd_file.output, rpad(l_documnet_number,26) || rpad(l_doc_type_name,32) || l_auction_title);
      END;
    END LOOP;
    CLOSE c_auc;
    IF(l_simulate              = 'N') THEN
      IF (l_busdocs_tbl.COUNT >= 1) THEN
        okc_manage_deliverables_grp.updateIntContactOnDeliverables (
			p_api_version                  => 1.0,
			p_init_msg_list                => FND_API.G_FALSE,
	                p_commit                       => FND_API.G_FALSE,
		        p_bus_docs_tbl                 => l_busdocs_tbl,
	                p_original_internal_contact_id => l_old_emp_id,
		        p_new_internal_contact_id      => l_new_emp_id,
	                x_msg_data                     => p_msg_data,
		        x_msg_count                    => p_msg_count,
	                x_return_status                => p_return_status);
        IF (p_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          FND_MSG_PUB.Count_and_Get(p_count => p_msg_count ,p_data => p_msg_data);
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;
      COMMIT;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    print_log(l_log_head,l_progress, SQLCODE || SUBSTR(SQLERRM,1,200));
    ROLLBACK TO Update_Buyer_SP;
    IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,l_log_head,l_progress|| SQLCODE || SUBSTR(SQLERRM,1,200));
    END IF;
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => p_msg_count, p_data => p_msg_data);
  END;
  l_progress          := '013';
  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
    ROLLBACK TO Update_Buyer_SP;
    RETCODE := '2';
    EFFBUF  := SQLCODE || SUBSTR(SQLERRM,1,200);
    FOR i IN 1..FND_MSG_PUB.COUNT_MSG
    LOOP
      l_msg := FND_MSG_PUB.get ( p_msg_index => i, p_encoded => FND_API.G_FALSE );
      EFFBUF:= l_msg;
      FND_FILE.put_line(FND_FILE.LOG, l_msg);
    END LOOP;
    --RAISE;
  END IF;
  print_log(l_log_head,l_progress, 'End: end of pon_update_buyer procedure');
END pon_update_buyer;
FUNCTION get_old_person_id
  RETURN NUMBER
IS
BEGIN
  RETURN g_old_personid;
END;
FUNCTION get_document_no_from
  RETURN NUMBER
IS
BEGIN
  RETURN g_document_no_from;
END;
FUNCTION get_document_no_to
  RETURN NUMBER
IS
BEGIN
  RETURN g_document_no_to;
END;
FUNCTION get_date_from
  RETURN DATE
IS
BEGIN
  RETURN g_date_from;
END;
FUNCTION get_date_to
  RETURN DATE
IS
BEGIN
  RETURN g_date_to;
END;
PROCEDURE validate_buyer(
    p_new_buyer_user_id IN NUMBER,
    is_valid_buyer OUT NOCOPY  VARCHAR2,
    p_msg_data OUT NOCOPY      VARCHAR2,
    p_msg_count OUT NOCOPY     NUMBER,
    p_return_status OUT NOCOPY VARCHAR2)
IS
  l_log_head CONSTANT VARCHAR2(1000) := g_pkg_name||'.'||'validate_buyer';
  l_progress VARCHAR2(3)             :='000';
  l_count    NUMBER;
BEGIN
  is_valid_buyer:= 'N';
  print_log(l_log_head,l_progress, 'Begin: start of validate_buyer procedure');
  print_log(l_log_head,l_progress, 'p_new_buyer_user_id => '||p_new_buyer_user_id);
  SELECT COUNT(*)
  INTO l_count
  FROM pon_employees_current_v emp,
    fnd_user users
  WHERE emp.person_id               = users.employee_id
  AND users.start_date             <= SYSDATE
  AND NVL(users.end_date, SYSDATE) >= SYSDATE
  AND user_id                       = p_new_buyer_user_id;
  IF(l_count                        > 0) THEN
    is_valid_buyer                 := 'Y';
  END IF;
  print_log(l_log_head,l_progress, 'p_new_buyer_user_id=>  ' || p_new_buyer_user_id || 'is_valid_buyer => '||is_valid_buyer);
  print_log(l_log_head,l_progress, 'End: end of validate_buyer procedure');
END validate_buyer;
PROCEDURE validate_resp_org_access(
    p_auction_header_id NUMBER,
    p_user_id IN NUMBER,
    x_has_access OUT NOCOPY    VARCHAR2,
    p_msg_data OUT NOCOPY      VARCHAR2,
    p_msg_count OUT NOCOPY     NUMBER,
    p_return_status OUT NOCOPY VARCHAR2)
IS
  CURSOR c_resp_rec
  IS
    SELECT DISTINCT r.RESPONSIBILITY_id ,
      urg.RESPONSIBILITY_APPLICATION_ID
    FROM fnd_compiled_menu_functions cmf ,
      fnd_form_functions ff ,
      fnd_responsibility r ,
      fnd_user_resp_groups urg ,
      fnd_user u
    WHERE cmf.function_id     = ff.function_id
    AND r.menu_id             = cmf.menu_id
    AND urg.responsibility_id = r.responsibility_id
    AND cmf.GRANT_FLAG        ='Y'
    AND r.APPLICATION_ID      =urg.RESPONSIBILITY_APPLICATION_ID
    AND u.user_id             = urg.user_id
    AND ff.function_name      ='PON_CREATE_NEW_NEG'
    AND u.user_id             = p_user_id
	AND urg.RESPONSIBILITY_APPLICATION_ID IN (201,396,177);
  l_user_id fnd_user.user_id%type;
  l_resp_id fnd_responsibility.responsibility_id%type;
  l_appl_id fnd_application.application_id%type;
  l_appl_short_name fnd_application_vl.application_short_name%type;
  l_ou_value fnd_profile_option_values.profile_option_value%type;
  l_sp_value fnd_profile_option_values.profile_option_value%type;
  l_resp_rec c_resp_rec%ROWTYPE;
  l_api_name   CONSTANT VARCHAR2(30) := 'check_org_access';
  l_has_access VARCHAR2(1);
  x_org_id     NUMBER;
  l_log_head   CONSTANT VARCHAR2(1000) := g_pkg_name||'.'||'validate_resp_org_access';
  l_progress   VARCHAR2(3)             :='000';
BEGIN
  print_log(l_log_head,l_progress, 'Begin: start of validate_resp_org_access procedure');
  print_log(l_log_head,l_progress, 'p_auction_header_id =>' ||p_auction_header_id);
  print_log(l_log_head,l_progress, 'p_user_id =>' || p_user_id);
  l_user_id   := p_user_id;
  x_has_access:='N';
  SELECT org_id
  INTO x_org_id
  FROM pon_auction_headers_all
  WHERE auction_header_id = p_auction_header_id;
  print_log(l_log_head,l_progress, 'p_auction_header_id=>  ' || p_auction_header_id || 'x_org_id => '||x_org_id);
  OPEN c_resp_rec;
  LOOP
    FETCH c_resp_rec INTO l_resp_rec;
    EXIT
  WHEN c_resp_rec%NOTFOUND;
    BEGIN
      l_resp_id:= l_resp_rec.RESPONSIBILITY_id;
      l_appl_id:= l_resp_rec.RESPONSIBILITY_APPLICATION_ID;
      SELECT application_short_name
      INTO l_appl_short_name
      FROM fnd_application_vl
      WHERE application_id = l_appl_id;
      l_ou_value          := fnd_profile.value_specific( 'ORG_ID',l_user_id, l_resp_id, l_appl_id);
      l_sp_value          := fnd_profile.value_specific( 'XLA_MO_SECURITY_PROFILE_LEVEL', l_user_id, l_resp_id, l_appl_id);
      print_log(l_log_head,l_progress,'Responsibility Id '||l_resp_rec.RESPONSIBILITY_ID || ','||'MO: Operating Unit: '||l_ou_value ||','|| 'MO: Security Profile: '||l_sp_value);
      IF l_sp_value IS NULL AND l_ou_value IS NULL THEN
        x_has_access:='N';
      ELSE
        BEGIN
          fnd_global.APPS_INITIALIZE (p_user_id, l_resp_id,l_appl_id);
            mo_global.init('PON');
            SELECT mo_global.check_access(x_org_id) INTO l_has_access FROM dual;
            print_log(l_log_head,l_progress, 'l_has_access =>' || l_has_access);
        EXCEPTION
        WHEN OTHERS THEN
          l_has_access := 'N';
        END;
      END IF;
      IF(l_has_access = 'Y') THEN
        x_has_access :='Y';
        print_log(l_log_head,l_progress, 'x_has_access =>' || x_has_access);
        CLOSE c_resp_rec;
        RETURN;
      END IF;
    EXCEPTION
    WHEN OTHERS THEN
      x_has_access:='N';
    END;
  END LOOP;
  CLOSE c_resp_rec;
  print_log(l_log_head,l_progress, 'x_has_access =>' || x_has_access);
  print_log(l_log_head,l_progress, 'END: end of validate_resp_org_access procedure');
EXCEPTION
WHEN OTHERS THEN
  print_log(l_log_head,l_progress, SQLCODE || SUBSTR(SQLERRM,1,200));
  IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,l_log_head,l_progress|| SQLCODE || SUBSTR(SQLERRM,1,200));
  END IF;
  p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_log_head );
  END IF;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => p_msg_count, p_data => p_msg_data );
END validate_resp_org_access;
--------------------------------------------------------------------------------------------------
-- Start of Comments
-- API Name   : Print_Output
-- Type       : Private
-- Pre-reqs   : None
-- Function   : Prints the header and body of the output file showing the documents
--            updated along with the person who have been updated in the
--            document.
-- Parameters :
-- IN         : p_old_buyer_name       Buyer name of the old person.
--  p_new_buyer_name       Buyer name of the new person.
--              p_document_no_from     Document number from.
--  p_document_no_to       Document number to.
--  p_date_from            Date from.
--  p_date_to              Date to.
--  p_commit_intrl         Commit interval.
--  p_simulate             Simulate.
--
-- OUT        : p_msg_data             Actual message in encoded format.
--  p_msg_count            Holds the number of messages in the API list.
--  p_return_status        Return status of the API (Includes 'S','E','U').
-- End of Comments
--------------------------------------------------------------------------------------------------
PROCEDURE Print_Output(
    p_old_buyer_name   IN VARCHAR2,
    p_new_buyer_name   IN VARCHAR2,
    p_document_no_from IN VARCHAR2,
    p_document_no_to   IN VARCHAR2,
    p_date_from        IN DATE,
    p_date_to          IN DATE,
    p_commit_intrl     IN NUMBER,
    p_simulate         IN VARCHAR2,
    p_msg_data OUT NOCOPY      VARCHAR2,
    p_msg_count OUT NOCOPY     NUMBER,
    p_return_status OUT NOCOPY VARCHAR2)
IS
  l_msg1     VARCHAR2(240);
  l_msg2     VARCHAR2(240);
  l_msg3     VARCHAR2(240);
  l_msg4     VARCHAR2(240);
  l_msg5     VARCHAR2(240);
  l_msg6     VARCHAR2(240);
  l_msg7     VARCHAR2(240);
  l_msg8     VARCHAR2(240);
  l_msg9     VARCHAR2(240);
  l_msg10    VARCHAR2(240);
  l_msg11    VARCHAR2(240);
  l_msg12    VARCHAR2(240);
  l_msg13    VARCHAR2(240);
  l_msg14    VARCHAR2(240);
  l_msg15    VARCHAR2(240);
  l_msg16    VARCHAR2(240);
  l_msg17    VARCHAR2(240);
  l_msg18    VARCHAR2(240);
  l_msg19    VARCHAR2(240);
  l_msg20    VARCHAR2(240);
  l_progress VARCHAR2(3);
  l_log_head CONSTANT VARCHAR2(1000) := g_pkg_name||'.'||'Print_Output';
BEGIN
  l_progress := '000';
  print_log(l_log_head,l_progress, 'START: start of Print_Output procedure');
  print_log(l_log_head,l_progress,'p_old_buyer_name => '||p_old_buyer_name );
  print_log(l_log_head,l_progress,'p_new_buyer_name => '||p_new_buyer_name );
  print_log(l_log_head,l_progress,'p_document_no_from => '||p_document_no_from );
  print_log(l_log_head,l_progress,'p_document_no_to => '||p_document_no_to );
  print_log(l_log_head,l_progress,'p_date_from => '||p_date_from);
  print_log(l_log_head,l_progress,'p_date_to => '||p_date_to);
  print_log(l_log_head,l_progress,'p_commit_intrl => '||p_commit_intrl);
  print_log(l_log_head,l_progress,'p_simulate => '||p_simulate);
  fnd_message.set_name('PON','PON_MUB_MSG_BUYER_HEADER1');
  l_msg1 := fnd_message.get;
  fnd_message.set_name('PON','PON_MUB_MSG_DATE');
  l_msg2 := fnd_message.get;
  fnd_message.set_name('PON','PON_MUB_MSG_OLD_PERSON');
  l_msg4 := fnd_message.get;
  fnd_message.set_name('PON','PON_MUB_MSG_NEW_PERSON');
  l_msg5 := fnd_message.get;
  fnd_message.set_name('PON','PON_MUB_MSG_DOC_NUM_FROM');
  l_msg7 := fnd_message.get;
  fnd_message.set_name('PON','PON_MUB_MSG_DOC_NUM_TO');
  l_msg8 := fnd_message.get;
  fnd_message.set_name('PON','PON_MUB_MSG_DATE_FROM');
  l_msg9 := fnd_message.get;
  fnd_message.set_name('PON','PON_MUB_MSG_DATE_TO');
  l_msg10 := fnd_message.get;
  SAVEPOINT Print_SP;
  fnd_message.set_name('PON','PON_MUB_MSG_BUYER_HEADER2');
  fnd_message.set_token('OLD_BUYER',p_old_buyer_name);
  fnd_message.set_token('NEW_BUYER',p_new_buyer_name);
  l_progress := '001';
  l_msg12    := fnd_message.get;
  fnd_message.set_name('PON','PON_MUB_MSG_DOC_NUM');
  l_msg13 := fnd_message.get;
  fnd_message.set_name('PON','PO_MUB_MSG_DOC_TYPE');
  l_msg14 := fnd_message.get;
  fnd_message.set_name('PON','PON_MUB_MSG_TITLE');
  l_msg15 := fnd_message.get;
  fnd_message.set_name('PON','PON_MUB_COMMIT_NT');
  l_msg16 := fnd_message.get;
  fnd_message.set_name('PON','PON_MUB_SIMULATE');
  l_msg17 := fnd_message.get;
  fnd_message.set_name('PON','PON_MUB_YES_FLAG');
  l_msg18 := fnd_message.get;
  fnd_message.set_name('PON','PON_MUB_NO_FLAG');
  l_msg19 := fnd_message.get;
  SELECT DECODE(NVL(p_simulate,'N'),'Y',l_msg18,l_msg19) INTO l_msg20 FROM dual;
  l_progress := '002';
  fnd_file.put_line(fnd_file.output, l_msg1);
  fnd_file.put_line(fnd_file.output, '                         ');
  fnd_file.put_line(fnd_file.output, rpad(l_msg2,21) || ' : ' || sysdate);
  fnd_file.put_line(fnd_file.output, rpad(l_msg4,21) || ' : ' || p_old_buyer_name);
  fnd_file.put_line(fnd_file.output, rpad(l_msg5,21) || ' : ' || p_new_buyer_name);
  l_progress := '003';
  fnd_file.put_line(fnd_file.output, rpad(l_msg7,21) || ' : ' || p_document_no_from);
  fnd_file.put_line(fnd_file.output, rpad(l_msg8,21) || ' : ' || p_document_no_to);
  fnd_file.put_line(fnd_file.output, rpad(l_msg9,21) || ' : ' || p_date_from);
  fnd_file.put_line(fnd_file.output, rpad(l_msg10,21) || ' : ' || p_date_to);
  fnd_file.put_line(fnd_file.output, rpad(l_msg16,21) || ' : ' || p_commit_intrl);
  fnd_file.put_line(fnd_file.output, rpad(l_msg17,21) || ' : ' || l_msg20);
  l_progress := '004';
  fnd_file.put_line(fnd_file.output, '                                         ');
  fnd_file.put_line(fnd_file.output, l_msg12);
  fnd_file.put_line(fnd_file.output, '                                                      ');
  fnd_file.put_line(fnd_file.output, rpad(l_msg13,26) || rpad(l_msg14,32) || l_msg15);
  fnd_file.put_line(fnd_file.output, rpad('-',75,'-'));
  print_log(l_log_head,l_progress, 'END: end of Print_Output procedure');
EXCEPTION
WHEN OTHERS THEN
  print_log(l_log_head,l_progress, SQLCODE || SUBSTR(SQLERRM,1,200));
  IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,l_log_head,l_progress|| SQLCODE || SUBSTR(SQLERRM,1,200));
  END IF;
  ROLLBACK TO Print_SP;
  p_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_log_head );
  END IF;
  FND_MSG_PUB.Count_And_Get(p_encoded=>'F', p_count => p_msg_count, p_data => p_msg_data );
END Print_Output;
-----------------------------------------------------------------------
--Start of Comments
--Name:  print_log
--Description  : Helper procedure for logging
--Pre-reqs:
--Parameters:
--IN:  p_message
--     p_header
--     p_process
--OUT:
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE print_log(
    p_log_head IN VARCHAR2,
    p_process  IN VARCHAR2,
    p_message  IN VARCHAR2 )
IS
BEGIN
  fnd_file.put_line(fnd_file.log, 'p_log_head => '||p_log_head ||' '||'p_process => ' ||p_process||' '|| p_message);
END print_log;
END PON_MASS_UPDATE_PVT;

/
