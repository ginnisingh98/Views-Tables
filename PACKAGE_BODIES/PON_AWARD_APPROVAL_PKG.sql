--------------------------------------------------------
--  DDL for Package Body PON_AWARD_APPROVAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_AWARD_APPROVAL_PKG" AS
/* $Header: PONAWAPB.pls 120.18.12010000.4 2014/05/20 08:47:33 vinnaray ship $ */
/*=======================================================================+
 |  Copyright (c) 1995, 2014 Oracle Corporation Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 | FILENAME
 |   PONAWAPB.pls
 |
 | DESCRIPTION
 |   PL/SQL body for package PON_AWARD_APPROVAL_PKG
 |
 | NOTES
 |   PL/SQL  routines for negotiation award approvals
 |
 | HISTORY
 | Date            UserName   Description
 | -------------------------------------------------------------------------------------------
 |    ?               ?       Created
 |
 | 25-Aug-05      sparames    Bug 4295915: Missing owner in Sourcing notifications
 |                            Added call to wf_engine.SetItemOwner
 |
 =========================================================================+*/


-- DEFINITIONS/DECLARATIONS
-- workflow item type
AWARD_APPROVAL_WF_ITEM_TYPE CONSTANT VARCHAR2(10) := 'PONAWAPR';

-- action history object type
AWARD_OBJECT_TYPE VARCHAR2(20) := 'NEGOTIATION_AWARD';

-- constants for identifying notification types
APPROVAL_REQUEST CONSTANT INTEGER := 1;
AWARD_APPROVED CONSTANT INTEGER := 2;
AWARD_REJECTED CONSTANT INTEGER := 3;
ERROR CONSTANT INTEGER := 4;
ERROR_FOR_ADMIN CONSTANT INTEGER := 5;

-- a record that stores information about an employee
TYPE employeeRecord IS RECORD (
  user_id fnd_user.user_id%TYPE,
  user_name fnd_user.user_name%TYPE,
  person_id per_all_people_f.person_id%TYPE
);

-- a null employee
nullEmployeeRecord employeeRecord;


-- Updated Parsing and Formatting routines to be compatible with AME API 11.5.10.
PROCEDURE parse_ame_approver( p_approver_string IN VARCHAR2, p_approver OUT NOCOPY ame_util.approverRecord2 );
FUNCTION  format_ame_approver( p_approver IN ame_util.approverRecord2 ) RETURN VARCHAR2;
FUNCTION  format_ame_approver_list( p_approver_list IN ame_util.approversTable2 ) RETURN VARCHAR2;
FUNCTION  is_old_approver_record( p_approver_string IN VARCHAR2 ) RETURN BOOLEAN;

-- parsing and formatting routines
PROCEDURE parse_approver(p_approver_string IN VARCHAR2,
                         p_approver OUT NOCOPY ame_util.approverRecord);
PROCEDURE format_approver(p_approver IN ame_util.approverRecord,
                          p_approver_string OUT NOCOPY VARCHAR2);
PROCEDURE parse_approver_list(p_approver_list_string IN VARCHAR2,
                              p_approver_list OUT NOCOPY ame_util.approversTable);
PROCEDURE format_approver_list(p_approver_list IN ame_util.approversTable,
                               p_approver_list_string OUT NOCOPY VARCHAR2);
FUNCTION convert_to_ame_api_insertion(p_pon_api_insertion IN NUMBER) RETURN VARCHAR2;
FUNCTION convert_to_pon_api_insertion(p_ame_api_insertion IN VARCHAR2) RETURN NUMBER;
FUNCTION convert_to_ame_authority(p_pon_authority IN NUMBER) RETURN VARCHAR2;
FUNCTION convert_to_pon_authority(p_ame_authority IN VARCHAR2) RETURN NUMBER;
FUNCTION convert_to_ame_approval_status(p_pon_approval_status IN NUMBER) RETURN VARCHAR2;
FUNCTION convert_to_pon_approval_status(p_ame_approval_status IN VARCHAR2) RETURN NUMBER;
FUNCTION parse_number_field(p_string VARCHAR2) RETURN NUMBER;

-- procedures for retreiving information for users and persons
FUNCTION get_display_name_for_user(p_user_id IN NUMBER) RETURN VARCHAR2;
FUNCTION get_display_name_for_user(p_user_name IN VARCHAR2) RETURN VARCHAR2;
FUNCTION get_display_name_for_person(p_person_id IN NUMBER) RETURN VARCHAR2;
PROCEDURE get_employee_info_for_user(p_user_id IN NUMBER, p_employee OUT NOCOPY employeeRecord);
PROCEDURE get_employee_info_for_user(p_user_name  IN VARCHAR2, p_employee OUT NOCOPY employeeRecord);
PROCEDURE get_employee_info_for_person(p_person_id IN NUMBER, p_employee OUT NOCOPY employeeRecord);

-- function that returns true if two approvers match
FUNCTION approvers_match(p_approver1 ame_util.approverRecord,
                         p_approver2 ame_util.approverRecord) RETURN BOOLEAN;

--procedure used for error reporting
PROCEDURE trim_error_code(p_error_code         IN NUMBER,
                          p_error_message_in   IN VARCHAR2,
                          p_error_message_out  OUT NOCOPY VARCHAR2);

-- IMPLEMENTATIONS
/*
  Identifies an award as an OAM transaction.
*/
PROCEDURE setup_oam_transaction(p_auction_header_id  IN NUMBER,
                                p_transaction_id     IN VARCHAR2,
                                p_user_id            IN NUMBER,
                                p_last_update_date   OUT NOCOPY DATE,
                                p_error_message      OUT NOCOPY VARCHAR2) IS
  l_award_approval_status VARCHAR2(30);
  l_last_update_date DATE;

  l_error_code NUMBER;

  l_current_log_level NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_exception_log_level NUMBER := FND_LOG.LEVEL_EXCEPTION;
  l_statement_log_level NUMBER := FND_LOG.LEVEL_STATEMENT;
  l_module_name VARCHAR2(80) := 'pon.plsql.PON_AWARD_APPROVAL_PKG.SETUP_OAM_TRANSACTION';
BEGIN

  log_string(l_statement_log_level, l_current_log_level, l_module_name, 'marking award ' || p_auction_header_id || ' as OAM transaction ' || p_transaction_id);

  SELECT award_approval_status
  INTO l_award_approval_status
  FROM pon_auction_headers_all
  WHERE auction_header_id = p_auction_header_id;

  -- check if a transaction already exists and has been submitted for approval
  IF l_award_approval_status = 'INPROCESS' THEN
    log_string(l_exception_log_level, l_current_log_level, l_module_name, 'award ' || p_auction_header_id || ' is already in the approval process');
    raise_application_error(-20001, PON_AUCTION_PKG.getMessage('PON_CANNOT_SBMT_AWARD_APPROVAL'));
  END IF;

  l_last_update_date := SYSDATE;

  -- update pon_auction_headers_all
  -- award_appr_ame_trans_id column with transaction id
  -- award_appr_ame_txn_date column with SYSDATE
  UPDATE pon_auction_headers_all
  SET
    award_appr_ame_trans_id = p_transaction_id,
    award_appr_ame_txn_date = l_last_update_date,
    last_updated_by = p_user_id,
    last_update_date = l_last_update_date
  WHERE auction_header_id = p_auction_header_id;

  p_last_update_date := l_last_update_date;
  p_error_message := NULL;

EXCEPTION
  WHEN OTHERS THEN
    -- reset output variables
    p_error_message := NULL;

    l_error_code := SQLCODE;
    IF l_error_code <= -20000 AND l_error_code >= -20999 THEN
      trim_error_code(l_error_code, SQLERRM, p_error_message);
      log_string(l_exception_log_level, l_current_log_level, l_module_name, SQLERRM);
    ELSE
      -- raise all Oracle-predefined and user-defined exceptions
      RAISE;
    END IF;
END setup_oam_transaction;

/*
  Unidentifies an award as an OAM transaction.  Does nothing if the award does not require approval.
*/
PROCEDURE clear_oam_transaction(p_auction_header_id  IN NUMBER,
                                p_user_id            IN NUMBER) IS
BEGIN

  -- update pon_auction_headers_all
  -- award_approval_status with 'REQUIRED',
  -- award_appr_ame_trans_id column with NULL
  -- award_appr_ame_trans_prev_id with NULL
  -- award_appr_ame_txn_date column with NULL
  -- wf_award_approval_item_key column with NULL
  UPDATE pon_auction_headers_all
  SET
    award_approval_status = 'REQUIRED',
    award_appr_ame_trans_id = NULL,
    award_appr_ame_trans_prev_id = NULL,
    award_appr_ame_txn_date = NULL,
    wf_award_approval_item_key = NULL,
    last_updated_by = p_user_id,
    last_update_date = SYSDATE
  WHERE
        auction_header_id = p_auction_header_id
    AND NVL(award_approval_flag, 'Y') = 'Y';

END clear_oam_transaction;

/*
  Checks whether or not an approver list can be modified by a session
  given the database state of the transaction associated with the approver list.
*/
PROCEDURE validate_transaction(p_auction_header_id  IN NUMBER,
                               p_last_update_date   IN DATE,
                               p_lock_transaction   IN BOOLEAN) IS
  l_last_update_date DATE;
  l_award_approval_status VARCHAR2(30);

  lock_not_acquired EXCEPTION;
  transaction_modified EXCEPTION;
  already_in_approval EXCEPTION;

  PRAGMA EXCEPTION_INIT(lock_not_acquired, -54);

  l_current_log_level NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_exception_log_level NUMBER := FND_LOG.LEVEL_EXCEPTION;
  l_statement_log_level NUMBER := FND_LOG.LEVEL_STATEMENT;
  l_module_name VARCHAR2(80) := 'pon.plsql.PON_AWARD_APPROVAL_PKG.VALIDATE_TRANSACTION';
BEGIN

  -- lock the transaction based on the p_lock_transaction parameter
  IF p_lock_transaction THEN
    SELECT last_update_date, award_approval_status
    INTO l_last_update_date, l_award_approval_status
    FROM pon_auction_headers_all
    WHERE auction_header_id = p_auction_header_id
    FOR UPDATE NOWAIT;
  ELSE
    SELECT last_update_date, award_approval_status
    INTO l_last_update_date, l_award_approval_status
    FROM pon_auction_headers_all
    WHERE auction_header_id = p_auction_header_id;
  END IF;

    -- check if the transaction has already been modified
  IF NVL(l_last_update_date, SYSDATE) <> NVL(p_last_update_date, SYSDATE) THEN
    RAISE transaction_modified;
  END IF;

  -- check if the transaction has been submitted for approval
  IF l_award_approval_status = 'INPROCESS' THEN
    RAISE already_in_approval;
  END IF;

EXCEPTION
  WHEN lock_not_acquired THEN
    -- a lock could not be acquired on the transaction; another user may be submitting it for approval
    log_string(l_exception_log_level, l_current_log_level, l_module_name, 'a lock could not be acquired on award ' || p_auction_header_id);
    raise_application_error(-20001, PON_AUCTION_PKG.getMessage('PON_CANNOT_SBMT_AWARD_APPROVAL'));
  WHEN transaction_modified THEN
    -- the transaction has been modified by another user session
    log_string(l_exception_log_level, l_current_log_level, l_module_name, 'award ' || p_auction_header_id || ' has been modified by another user session');
    raise_application_error(-20001, PON_AUCTION_PKG.getMessage('PON_CANNOT_SBMT_AWARD_APPROVAL'));
  WHEN already_in_approval THEN
    -- the transaction is in the approval process
    log_string(l_exception_log_level, l_current_log_level, l_module_name, 'award ' || p_auction_header_id || ' is already in the approval process');
    raise_application_error(-20001, PON_AUCTION_PKG.getMessage('PON_CANNOT_SBMT_AWARD_APPROVAL'));
END validate_transaction;

/*
  Adds a row into the PON_AUCTION_HISTORY table.
*/
PROCEDURE add_action_history(p_auction_header_id  IN NUMBER,
                             p_transaction_id     IN VARCHAR2,
                             p_action_type        IN VARCHAR2,
                             p_notes              IN VARCHAR2,
                             p_action_date        IN DATE,
                             p_user_id            IN NUMBER,
                             p_user_name          IN VARCHAR2) IS
  l_action_sequence_number NUMBER;
BEGIN

  -- determine the current action sequence number for the award
  BEGIN
    SELECT MAX(sequence_num)
    INTO l_action_sequence_number
    FROM pon_action_history
    WHERE
          object_id = p_auction_header_id
      AND object_type_code = AWARD_OBJECT_TYPE;
  EXCEPTION
    WHEN no_data_found THEN
      NULL;
  END;

  -- increment the sequence number
  -- if the current action sequence number is null or could not be determined, set it to 0
  IF l_action_sequence_number IS NULL THEN
    l_action_sequence_number := 0;
  END IF;

  -- create the action entry, incrementing the sequence number
  INSERT INTO pon_action_history(
    object_id,
    object_id2,
    object_type_code,
    sequence_num,
    action_type,
    action_date,
    action_user_id,
    action_note)
  VALUES (
    p_auction_header_id,
    TO_NUMBER(p_transaction_id),
    AWARD_OBJECT_TYPE,
    l_action_sequence_number + 1,
    p_action_type,
    p_action_date,
    p_user_id,
    p_notes);

END add_action_history;

/*
  Updates an existing row in the PON_AUCTION_HISTORY table.

  Only AWARD_APPROVAL_PENDING action entries can be updated.
*/
PROCEDURE update_action_history(p_auction_header_id  IN NUMBER,
                                p_transaction_id     IN VARCHAR2,
                                p_action_type        IN VARCHAR2,
                                p_notes              IN VARCHAR2,
                                p_action_date        IN DATE,
                                p_user_id            IN NUMBER) IS
BEGIN

  UPDATE pon_action_history
  SET
    action_type = p_action_type,
    action_date = p_action_date,
    action_note = p_notes
  WHERE
        object_id = p_auction_header_id
    AND object_id2 = TO_NUMBER(p_transaction_id)
    AND action_user_id = p_user_id
    AND action_type = 'AWARD_APPROVAL_PENDING'
    AND object_type_code = AWARD_OBJECT_TYPE;

END update_action_history;

/*
  Sets the main user-independent attributes for a workflow item.
*/
PROCEDURE set_core_attributes(p_item_type                    IN VARCHAR2,
                              p_item_key                     IN VARCHAR2,
                              p_auction_header_id            IN NUMBER,
                              p_note_to_approvers            IN VARCHAR2,
                              p_first_authority_approver_id  IN NUMBER ) IS
  l_trading_partner_contact_name VARCHAR2(255);
  l_trading_partner_name VARCHAR2(255);
  l_transaction_id VARCHAR2(80);
  l_auction_title VARCHAR2(80);
  l_document_number VARCHAR2(240);
  l_open_bidding_date DATE;
  l_close_bidding_date DATE;
  l_award_by_date DATE;
  l_doctype_group_name VARCHAR2(50);
  l_msg_suffix VARCHAR2(10);
  l_preview_date DATE;
BEGIN

  -- retrieve the necessary negotiation information
  SELECT
    auc.trading_partner_contact_name,
    auc.trading_partner_name,
    auc.award_appr_ame_trans_id,
    auc.auction_title,
    auc.document_number,
    auc.open_bidding_date,
    auc.close_bidding_date,
    auc.award_by_date,
    dt.doctype_group_name,
    auc.view_by_date
  INTO
    l_trading_partner_contact_name,
    l_trading_partner_name,
    l_transaction_id,
    l_auction_title,
    l_document_number,
    l_open_bidding_date,
    l_close_bidding_date,
    l_award_by_date,
    l_doctype_group_name,
    l_preview_date
  FROM
    pon_auction_headers_all auc,
    pon_auc_doctypes dt
  WHERE
        dt.doctype_id= auc.doctype_id
    AND auc.auction_header_id = p_auction_header_id;

  l_msg_suffix := PON_AUCTION_PKG.get_message_suffix(l_doctype_group_name);

  -- set standard notification header attributes
  PON_WF_UTL_PKG.set_hdr_attributes(p_item_type,
                                    p_item_key,
                                    l_trading_partner_name,
                                    l_auction_title,
                                    l_document_number,
                                    l_trading_partner_contact_name);

  -- set other core attributes
  wf_engine.SetItemAttrNumber(itemtype => p_item_type,
                              itemkey  => p_item_key,
                              aname    => 'AUCTION_HEADER_ID',
                              avalue   => p_auction_header_id);

  wf_engine.SetItemAttrNumber(itemtype => p_item_type,
                              itemkey  => p_item_key,
                              aname    => 'FIRST_AUTHORITY_APPROVER_ID',
                              avalue   => p_first_authority_approver_id);

  wf_engine.SetItemAttrText(itemtype => p_item_type,
                            itemkey  => p_item_key,
                            aname    => 'AME_TRANSACTION_ID',
                            avalue   => l_transaction_id);

  wf_engine.SetItemAttrText(itemtype => p_item_type,
                            itemkey  => p_item_key,
                            aname    => 'NOTE_TO_APPROVERS',
                            avalue   => PON_AUCTION_PKG.replaceHtmlChars(p_note_to_approvers));

  wf_engine.SetItemAttrText(itemtype => p_item_type,
                            itemkey  => p_item_key,
                            aname    => 'AWARD_SUMMARY_URL',
                            avalue   => PON_WF_UTL_PKG.get_dest_page_url('PON_AWARD_SUMM', 'BUYER'));

  wf_engine.SetItemAttrText(itemtype => p_item_type,
                            itemkey  => p_item_key,
                            aname    => 'MESSAGE_SUFFIX',
                            avalue   => l_msg_suffix);

  wf_engine.SetItemAttrDate(itemtype => p_item_type,
                            itemkey  => p_item_key,
                            aname    => 'OPEN_BIDDING_DATE',
                            avalue   => l_open_bidding_date);

  wf_engine.SetItemAttrDate(itemtype => p_item_type,
                            itemkey  => p_item_key,
                            aname    => 'CLOSE_BIDDING_DATE',
                            avalue   => l_close_bidding_date);

  wf_engine.SetItemAttrDate(itemtype => p_item_type,
                            itemkey  => p_item_key,
                            aname    => 'AWARD_BY_DATE',
                            avalue   => l_award_by_date);

  wf_engine.SetItemAttrDate (itemtype   => p_item_type,
                             itemkey    => p_item_key,
                             aname      => 'PREVIEW_DATE',
	  	                 avalue     => l_preview_date);

  wf_engine.SetItemAttrText(itemtype => p_item_type,
                            itemkey  => p_item_key,
                            aname    => 'ORIGIN_USER_NAME',
                            avalue   => fnd_global.user_name);
  -- added for bug 18068754 fix
  wf_engine.SetItemAttrText(itemtype => p_item_type,
                            itemkey  => p_item_key,
                            aname    => 'NOTIF_FROM_USER',
                            avalue   => fnd_global.user_name);

END set_core_attributes;

/*
  Sets the main user-dependent notification attributes for a workflow item.

  NOTE:
    Among other attributes, this procedure sets:
    1. the particular notification subject attribute, based on p_notification_type.
    2. the APPROVAL_DATE_TZ attribute if p_set_approval_date is true
    3. the REJECTION_DATE_TZ attribute if p_set_rejection_date is true
*/
PROCEDURE set_common_user_attributes(p_item_type IN VARCHAR2,
                                     p_item_key IN VARCHAR2,
                                     p_user_name IN VARCHAR2,
                                     p_notification_type IN INTEGER,
                                     p_set_approval_date BOOLEAN,
                                     p_set_rejection_date BOOLEAN) IS
  l_language_code VARCHAR2(5);
  l_msg_suffix VARCHAR2(10);
  l_auction_title VARCHAR2(80);
  l_document_number VARCHAR2(240);
  l_open_bidding_date DATE;
  l_open_bidding_date_tz DATE;
  l_close_bidding_date DATE;
  l_close_bidding_date_tz DATE;
  l_award_by_date DATE;
  l_award_by_date_tz DATE;
  l_approval_date DATE;
  l_approval_date_tz DATE;
  l_rejection_date DATE;
  l_rejection_date_tz DATE;
  l_preview_date DATE;
  l_preview_date_tz DATE;
  l_user_timezone VARCHAR2(80);
  l_server_timezone VARCHAR2(80);
  l_user_timezone_desc VARCHAR2(240);
BEGIN

  -- set the db session language
  PON_PROFILE_UTIL_PKG.get_wf_language(p_user_name, l_language_code);
  PON_AUCTION_PKG.set_session_language(null, l_language_code);

  l_msg_suffix := wf_engine.getItemAttrText(itemtype => p_item_type,
                                            itemkey  => p_item_key,
                                            aname    => 'MESSAGE_SUFFIX');

  l_auction_title := wf_engine.getItemAttrText(itemtype => p_item_type,
                                               itemkey  => p_item_key,
                                               aname    => 'AUCTION_TITLE');

  l_document_number := wf_engine.getItemAttrText(itemtype => p_item_type,
                                                 itemkey  => p_item_key,
                                                 aname    => 'DOC_NUMBER');

  -- set the notification subject
  IF p_notification_type = APPROVAL_REQUEST THEN
    -- if the notification type is APPROVAL_REQUEST
    -- set the notification subject for the initial approval request notification
    -- as well as the subject for the reminder notification
    wf_engine.SetItemAttrText(itemtype => p_item_type,
                              itemkey  => p_item_key,
                              aname    => 'APPROVAL_REQUEST_SUBJECT',
                              avalue   => PON_AUCTION_PKG.getMessage('PON_AUC_AWARD_APPROVAL_1',
                                                                     l_msg_suffix,
                                                                     'DOC_NUMBER',
                                                                     l_document_number,
                                                                     'DOC_TITLE',
                                                                     l_auction_title));
    wf_engine.SetItemAttrText(itemtype => p_item_type,
                              itemkey  => p_item_key,
                              aname    => 'REQUEST_REMINDER_SUBJECT',
                              avalue   => PON_AUCTION_PKG.getMessage('PON_AUC_AWARD_APPROVAL_2',
                                                                     l_msg_suffix,
                                                                     'DOC_NUMBER',
                                                                     l_document_number,
                                                                     'DOC_TITLE',
                                                                     l_auction_title));
  ELSIF p_notification_type = AWARD_APPROVED THEN
    wf_engine.SetItemAttrText(itemtype => p_item_type,
                              itemkey  => p_item_key,
                              aname    => 'APPROVAL_SUBJECT',
                              avalue   => PON_AUCTION_PKG.getMessage('PON_AUC_AWARD_APPROVED_1',
                                                                     l_msg_suffix,
                                                                     'DOC_NUMBER',
                                                                     l_document_number,
                                                                     'DOC_TITLE',
                                                                     l_auction_title));
  ELSIF p_notification_type = AWARD_REJECTED THEN
    wf_engine.SetItemAttrText(itemtype => p_item_type,
                              itemkey  => p_item_key,
                              aname    => 'REJECTION_SUBJECT',
                              avalue   => PON_AUCTION_PKG.getMessage('PON_AUC_AWARD_REJECTED_1',
                                                                     l_msg_suffix,
                                                                     'DOC_NUMBER',
                                                                     l_document_number,
                                                                     'DOC_TITLE',
                                                                     l_auction_title));
  ELSIF p_notification_type = ERROR THEN
    wf_engine.SetItemAttrText(itemtype => p_item_type,
                              itemkey  => p_item_key,
                              aname    => 'ERROR_SUBJECT',
                              avalue   => PON_AUCTION_PKG.getMessage('PON_AWARD_REJECTED_ERROR_1',
                                                                     l_msg_suffix,
                                                                     'DOC_NUMBER',
                                                                     l_document_number,
                                                                     'DOC_TITLE',
                                                                     l_auction_title));
  ELSIF p_notification_type = ERROR_FOR_ADMIN THEN
    wf_engine.SetItemAttrText(itemtype => p_item_type,
                              itemkey  => p_item_key,
                              aname    => 'ERROR_SUBJECT_FOR_ADMIN',
                              avalue   => PON_AUCTION_PKG.getMessage('PON_AWARD_REJECTED_ERROR_2',
                                                                     l_msg_suffix,
                                                                     'DOC_NUMBER',
                                                                     l_document_number,
                                                                     'DOC_TITLE',
                                                                     l_auction_title));
  END IF;

  -- convert the open bidding date, close bidding date, award by date, approval date, and rejection_date
  -- to dates in the user's timezone
  l_user_timezone := PON_AUCTION_PKG.get_time_zone(p_user_name);
  l_server_timezone := PON_AUCTION_PKG.get_oex_time_zone;

  l_open_bidding_date := wf_engine.getItemAttrDate(itemtype => p_item_type,
                                                   itemkey  => p_item_key,
                                                   aname    => 'OPEN_BIDDING_DATE');

  l_close_bidding_date := wf_engine.getItemAttrDate(itemtype => p_item_type,
                                                    itemkey  => p_item_key,
                                                    aname    => 'CLOSE_BIDDING_DATE');

  l_award_by_date := wf_engine.getItemAttrDate(itemtype => p_item_type,
                                               itemkey  => p_item_key,
                                               aname    => 'AWARD_BY_DATE');

  IF p_set_approval_date THEN
    l_approval_date := wf_engine.getItemAttrDate(itemtype => p_item_type,
                                                 itemkey  => p_item_key,
                                                 aname    => 'APPROVAL_DATE');
  END IF;

  IF p_set_rejection_date THEN
    l_rejection_date := wf_engine.getItemAttrDate(itemtype => p_item_type,
                                                  itemkey  => p_item_key,
                                                  aname    => 'REJECTION_DATE');
  END IF;

  l_preview_date := wf_engine.getItemAttrDate(itemtype => p_item_type,
                                                  itemkey  => p_item_key,
                                                  aname    => 'PREVIEW_DATE');

  IF PON_OEX_TIMEZONE_PKG.valid_zone(l_user_timezone) = 1 THEN
    l_open_bidding_date_tz := PON_OEX_TIMEZONE_PKG.convert_time(l_open_bidding_date, l_server_timezone, l_user_timezone);
    l_close_bidding_date_tz := PON_OEX_TIMEZONE_PKG.convert_time(l_close_bidding_date, l_server_timezone, l_user_timezone);

    -- the award by date may be null
    IF l_award_by_date IS NOT NULL THEN
      l_award_by_date_tz := PON_OEX_TIMEZONE_PKG.convert_time(l_award_by_date, l_server_timezone, l_user_timezone);
    ELSE
      l_award_by_date_tz := NULL;
    END IF;

    IF p_set_approval_date THEN
      l_approval_date_tz := PON_OEX_TIMEZONE_PKG.convert_time(l_approval_date, l_server_timezone, l_user_timezone);
    END IF;

    IF p_set_rejection_date THEN
      l_rejection_date_tz := PON_OEX_TIMEZONE_PKG.convert_time(l_rejection_date, l_server_timezone, l_user_timezone);
    END IF;

    IF l_preview_date IS NOT NULL THEN
      l_preview_date_tz := PON_OEX_TIMEZONE_PKG.convert_time(l_preview_date, l_server_timezone, l_user_timezone);
    END IF;
  ELSE
    l_user_timezone := l_server_timezone;
    l_open_bidding_date_tz := l_open_bidding_date;
    l_close_bidding_date_tz := l_close_bidding_date;
    l_award_by_date_tz := l_award_by_date;
    l_preview_date_tz := l_preview_date;

    IF p_set_approval_date THEN
      l_approval_date_tz := l_approval_date;
    END IF;

    IF p_set_rejection_date THEN
      l_rejection_date_tz := l_rejection_date;
    END IF;
  END IF;

  l_user_timezone_desc := PON_AUCTION_PKG.get_timezone_description(l_user_timezone, l_language_code);

  wf_engine.setItemAttrText(itemtype => p_item_type,
                            itemkey  => p_item_key,
                            aname    => 'USER_TIMEZONE',
                            avalue   => l_user_timezone_desc);

  wf_engine.setItemAttrDate(itemtype => p_item_type,
                            itemkey  => p_item_key,
                            aname    => 'OPEN_BIDDING_DATE_TZ',
                            avalue   => l_open_bidding_date_tz);

  wf_engine.setItemAttrDate(itemtype => p_item_type,
                            itemkey  => p_item_key,
                            aname    => 'CLOSE_BIDDING_DATE_TZ',
                            avalue   => l_close_bidding_date_tz);

  wf_engine.setItemAttrDate(itemtype => p_item_type,
                            itemkey  => p_item_key,
                            aname    => 'AWARD_BY_DATE_TZ',
                            avalue   => l_award_by_date_tz);

  -- if the award by date is not null, the timezone attribute associated with the date
  -- must have the same value as the user's timezone attribute
  -- otherwise, then the timezone attribute associated with the date must be null
  IF l_award_by_date_tz IS NOT NULL THEN
    wf_engine.setItemAttrText(itemtype => p_item_type,
                              itemkey  => p_item_key,
                              aname    => 'USER_TIMEZONE_AWARD_BY_DATE',
                              avalue   => l_user_timezone_desc);
  ELSE
    wf_engine.setItemAttrText(itemtype => p_item_type,
                              itemkey  => p_item_key,
                              aname    => 'USER_TIMEZONE_AWARD_BY_DATE',
                              avalue   => NULL);
  END IF;

  IF p_set_approval_date THEN
    wf_engine.setItemAttrDate(itemtype => p_item_type,
                              itemkey  => p_item_key,
                              aname    => 'APPROVAL_DATE_TZ',
                              avalue   => l_approval_date_tz);
  END IF;

  IF p_set_rejection_date THEN
    wf_engine.setItemAttrDate(itemtype => p_item_type,
                              itemkey  => p_item_key,
                              aname    => 'REJECTION_DATE_TZ',
                              avalue   => l_rejection_date_tz);
  END IF;

  IF l_preview_date_tz IS NOT NULL THEN
    wf_engine.SetItemAttrText (itemtype   => p_item_type,
                               itemkey    => p_item_key,
                               aname      => 'TP_TIME_ZONE1',
		  	                   avalue     => l_user_timezone_desc);

    wf_engine.SetItemAttrText (itemtype   => p_item_type,
                               itemkey    => p_item_key,
                               aname      => 'PREVIEW_DATE_NOTSPECIFIED',
		  	                   avalue     => null);
  ELSE
    wf_engine.SetItemAttrText (itemtype   => p_item_type,
                               itemkey    => p_item_key,
                               aname      => 'TP_TIME_ZONE1',
		  	                   avalue     => null);

    wf_engine.SetItemAttrText (itemtype   => p_item_type,
                               itemkey    => p_item_key,
                               aname      => 'PREVIEW_DATE_NOTSPECIFIED',
		  	             avalue     => PON_AUCTION_PKG.getMessage('PON_AUC_PREVIEW_DATE_NOTSPEC'));
  END IF;

END set_common_user_attributes;

/*
  Sets the main user-dependent notification attributes for a workflow item.

  NOTE:
    Among other attributes, this procedure sets:
    1. the particular notification subject attribute, based on p_notification_type.
*/
PROCEDURE set_common_user_attributes(p_item_type IN VARCHAR2,
                                     p_item_key IN VARCHAR2,
                                     p_user_name IN VARCHAR2,
                                     p_notification_type IN INTEGER) IS
BEGIN

  set_common_user_attributes(p_item_type, p_item_key, p_user_name, p_notification_type, FALSE, FALSE);

END set_common_user_attributes;

/*
  Sets user-dependent attributes for the Award Approved notification.
*/
PROCEDURE set_award_approved_attributes(p_item_type IN VARCHAR2,
                                        p_item_key IN VARCHAR2) IS
  l_tp_contact_user_name VARCHAR2(100);
BEGIN

  l_tp_contact_user_name := wf_engine.getItemAttrText(itemtype => p_item_type,
                                                      itemkey  => p_item_key,
                                                      aname    => 'PREPARER_TP_CONTACT_NAME');

  set_common_user_attributes(p_item_type,
                             p_item_key,
                             l_tp_contact_user_name,
                             AWARD_APPROVED,
                             TRUE,
                             FALSE);

END set_award_approved_attributes;

/*
  Sets user-dependent attributes for the Award Rejected notification.
*/
PROCEDURE set_award_rejected_attributes(p_item_type IN VARCHAR2,
                                        p_item_key IN VARCHAR2) IS
  l_tp_contact_user_name VARCHAR2(100);
BEGIN

  l_tp_contact_user_name := wf_engine.getItemAttrText(itemtype => p_item_type,
                                                      itemkey  => p_item_key,
                                                      aname    => 'PREPARER_TP_CONTACT_NAME');

  set_common_user_attributes(p_item_type,
                             p_item_key,
                             l_tp_contact_user_name,
                             AWARD_REJECTED,
                             FALSE,
                             TRUE);

END set_award_rejected_attributes;

/*
  Sets user-dependent attributes for the Notify Approver notification.
*/
PROCEDURE set_notify_approver_attributes(p_item_type IN VARCHAR2,
                                         p_item_key  IN VARCHAR2) IS
  l_approver_user_name VARCHAR2(100);
BEGIN

  l_approver_user_name := wf_engine.getItemAttrText(itemtype => p_item_type,
                                                    itemkey  => p_item_key,
                                                    aname    => 'APPROVER_USER');

  -- reset notification's Respond attributes
  wf_engine.setItemAttrText(itemtype => p_item_type,
                            itemkey  => p_item_key,
                            aname    => 'APPROVER_FORWARDEE_USER',
                            avalue   => NULL);

  wf_engine.setItemAttrText(itemtype => p_item_type,
                            itemkey  => p_item_key,
                            aname    => 'NOTE_TO_BUYER',
                            avalue   => NULL);

  -- reset approval-related attributes
  wf_engine.SetItemAttrDate(itemtype => p_item_type,
                            itemkey  => p_item_key,
                            aname    => 'APPROVAL_DATE',
                            avalue   => NULL);

  wf_engine.SetItemAttrDate(itemtype => p_item_type,
                            itemkey  => p_item_key,
                            aname    => 'REJECTION_DATE',
                            avalue   => NULL);

  set_common_user_attributes(p_item_type,
                             p_item_key,
                             l_approver_user_name,
                             APPROVAL_REQUEST);

END set_notify_approver_attributes;

/*
  Called by workflow activity to perform any special tasks
  before executing the main part of the workflow process.
*/
PROCEDURE pre_approval(itemtype   IN VARCHAR2,
                       itemkey    IN VARCHAR2,
                       actid      IN NUMBER,
                       funcmode   IN VARCHAR2,
                       resultout  OUT NOCOPY VARCHAR2) IS
  l_auction_header_id NUMBER;
  l_transaction_id VARCHAR2(80);
  l_tp_contact_user_id NUMBER;
  l_tp_contact_user_name VARCHAR2(100);
BEGIN

  l_auction_header_id := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                                     itemkey  => itemkey,
                                                     aname    => 'AUCTION_HEADER_ID');

  l_transaction_id := wf_engine.GetItemAttrText(itemtype => itemtype,
                                                itemkey  => itemkey,
                                                aname    => 'AME_TRANSACTION_ID');

  l_tp_contact_user_name := wf_engine.GetItemAttrText(itemtype => itemtype,
                                                      itemkey  => itemkey,
                                                      aname    => 'PREPARER_TP_CONTACT_NAME');

  SELECT user_id
  INTO l_tp_contact_user_id
  FROM fnd_user
  WHERE user_name = l_tp_contact_user_name;

  -- update previous transaction id column with current transaction id
  UPDATE pon_auction_headers_all
  SET
    award_appr_ame_trans_prev_id = l_transaction_id,
    last_updated_by = l_tp_contact_user_id,
    last_update_date = SYSDATE
  WHERE auction_header_id = l_auction_header_id;

END pre_approval;

/*
  Called by workflow activity to perform any special tasks
  after executing the main part of the workflow process.
*/
PROCEDURE post_approval(itemtype   IN VARCHAR2,
                        itemkey    IN VARCHAR2,
                        actid      IN NUMBER,
                        funcmode   IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2) IS
BEGIN

  NULL;

END post_approval;

/*
  Sets the current approver to the next approver, if a next approver exists.
*/
PROCEDURE get_next_approver(itemtype   IN VARCHAR2,
                            itemkey    IN VARCHAR2,
                            actid      IN NUMBER,
                            funcmode   IN VARCHAR2,
                            resultout  OUT NOCOPY VARCHAR2) IS
  l_auction_header_id NUMBER;
  l_transaction_id VARCHAR2(80);

  l_next_approver_employee employeeRecord;
  l_next_approver_list ame_util.approversTable2;
  l_next_approver ame_util.approverRecord2;
  l_process_out varchar2(2);
  l_person_id NUMBER;

  l_next_approver_name VARCHAR2(240);
  l_next_approver_string VARCHAR2(240);
  l_success_flag BOOLEAN;
  l_source_type_out VARCHAR2(50);
  l_idList ame_util.idList;

  l_current_log_level NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_exception_log_level NUMBER := FND_LOG.LEVEL_EXCEPTION;
  l_statement_log_level NUMBER := FND_LOG.LEVEL_STATEMENT;
  l_module_name VARCHAR2(80) := 'pon.plsql.PON_AWARD_APPROVAL_PKG.GET_NEXT_APPROVER';
BEGIN

  l_transaction_id := wf_engine.GetItemAttrText(itemtype => itemtype,
                                                itemkey  => itemkey,
                                                aname    => 'AME_TRANSACTION_ID');
  l_success_flag := TRUE;

  BEGIN
    -- get the next approver from OAM
    log_string(l_statement_log_level, l_current_log_level, l_module_name, 'calling ame_api2.getNextApprovers4 on workflow item key ' || itemkey);

    ame_api2.getNextApprovers4( applicationIdIn   => APPLICATION_ID,
                                transactionIdIn   => l_transaction_id,
                                transactionTypeIn => AWARD_TRANSACTION_TYPE,
                                approvalProcessCompleteYNOut => l_process_out,
                                nextApproversOut   => l_next_approver_list);

    log_string(l_statement_log_level, l_current_log_level, l_module_name, 'calling ame_api2.getNextApprovers4 returns ' || fnd_global.newline || format_ame_approver_list(l_next_approver_list));

  EXCEPTION
    WHEN OTHERS THEN
      resultout := 'OAM_API_ERROR';
      l_success_flag := FALSE;

      -- if the OAM API call raises an exception,
      -- set the Application Error and OAM Error workflow attributes
      -- this message is internal and can be seen only by the OAM administrator
      wf_engine.SetItemAttrText(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'OAM_ERROR',
                                avalue   => SQLERRM);

      -- this message can be seen by any buyer
      wf_engine.SetItemAttrText(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'APPLICATION_ERROR',
                                avalue   => PON_AUCTION_PKG.getMessage('PON_OAM_ERROR_OCCURRED'));

      log_string(l_exception_log_level, l_current_log_level, l_module_name, SQLERRM);
  END;

  -- Check whether Parallel Approval is enabled in AME. If yes report an error.
  IF l_next_approver_list.COUNT > 1 THEN
      resultout := 'OAM_API_ERROR';
      l_success_flag := FALSE;

      -- this message can be seen only by admin.
      wf_engine.SetItemAttrText(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'OAM_ERROR',
                                avalue   => PON_AUCTION_PKG.getMessage('PON_AME_PARALLEL_NOT_SUPPORTED'));

      -- this message can be seen by any buyer.
      wf_engine.SetItemAttrText(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'APPLICATION_ERROR',
                                avalue   => PON_AUCTION_PKG.getMessage('PON_AME_PARALLEL_NOT_SUPPORTED'));

      log_string(l_exception_log_level, l_current_log_level, l_module_name, PON_AUCTION_PKG.getMessage('PON_AME_PARALLEL_NOT_SUPPORTED'));

  END IF;


  -- if the OAM API call returned successfully
  IF l_success_flag THEN

    IF l_process_out = 'Y' THEN
         resultout := 'NO_NEXT_APPROVER';
    ELSE

        l_next_approver := l_next_approver_list(1); -- get the first approver from the approvers list.

        IF  l_next_approver.orig_system = 'POS' THEN  -- Position Hierarchy setup in AME.

                BEGIN
                    l_person_id := NULL;
                    ame_api3.parseApproverSource( approverSourceIn      => l_next_approver.source,
                                                  sourceDescriptionOut  => l_source_type_out,
                                                  ruleIdListOut         => l_idList);

                    IF( l_next_approver.api_insertion = ame_util.apiAuthorityInsertion AND
                        l_source_type_out <> ame_util.forwardeeSource ) THEN
                        l_person_id := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                                                   itemkey  => itemkey,
                                                                   aname    => 'FIRST_AUTHORITY_APPROVER_ID');
                    END IF;
                    IF( l_person_id IS NULL OR l_person_id = -1 ) THEN
                        SELECT person_id into l_person_id FROM (
                            SELECT person.person_id FROM per_all_people_f person, per_all_assignments_f asg
                            WHERE asg.position_id = l_next_approver.orig_system_id and trunc(sysdate) between person.effective_start_date
                             and nvl(person.effective_end_date, trunc(sysdate)) and person.person_id = asg.person_id
                             and asg.primary_flag = 'Y' and asg.assignment_type in ('E','C')
                             and ( person.current_employee_flag = 'Y' or person.current_npw_flag = 'Y' )
                             and asg.assignment_status_type_id not in (
                               SELECT assignment_status_type_id FROM per_assignment_status_types
                               WHERE per_system_status = 'TERM_ASSIGN'
                             ) and trunc(sysdate) between asg.effective_start_date and asg.effective_end_date order by person.last_name
                        ) where rownum = 1;
                    END IF;
                EXCEPTION
                    WHEN OTHERS THEN
                        l_person_id := NULL;
                END;

                IF l_person_id IS NULL THEN  -- There are no users associated to this position. Raise an error.

                        resultout := 'OAM_API_ERROR';
                        l_success_flag := FALSE;

                        -- this message can be seen only by admin.
                        wf_engine.SetItemAttrText(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'OAM_ERROR',
                                avalue   => PON_AUCTION_PKG.getMessage('PON_NO_PERSON_FOR_POSITION', '', 'POSITION_NAME', l_next_approver.display_name ));

                        -- this message can be seen by any buyer.
                        wf_engine.SetItemAttrText(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'APPLICATION_ERROR',
                                avalue   => PON_AUCTION_PKG.getMessage('PON_NO_PERSON_FOR_POSITION', '', 'POSITION_NAME', l_next_approver.display_name ));

                        log_string(l_exception_log_level, l_current_log_level, l_module_name, PON_AUCTION_PKG.getMessage('PON_NO_PERSON_FOR_POSITION', '', 'POSITION_NAME', l_next_approver.display_name ));
                        RETURN;
                ELSE
                     get_employee_info_for_person(l_person_id, l_next_approver_employee);
                END IF;

        ELSIF l_next_approver.orig_system = 'PER' THEN  -- Emp-Supervisor Hierarchy setup in AME.

                get_employee_info_for_person(l_next_approver.orig_system_id, l_next_approver_employee);

        ELSE  -- FND USER setup in AME.

                get_employee_info_for_user(l_next_approver.orig_system_id, l_next_approver_employee);

        END IF;

        -- if next approver is valid
        IF l_next_approver_employee.user_id IS NOT NULL AND l_next_approver_employee.person_id IS NOT NULL THEN

                -- set the approver username attribute
                wf_engine.SetItemAttrText(itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'APPROVER_USER',
                                  avalue   => l_next_approver_employee.user_name);

                l_next_approver_string := format_ame_approver(l_next_approver);

                -- set the approver record string atttribute
                wf_engine.SetItemAttrText(itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'APPROVER_STRING',
                                  avalue   => l_next_approver_string);

                -- set attributes specific to approval request notification
                set_notify_approver_attributes(itemtype, itemkey);

                -- get the auction header id workflow attribute
                l_auction_header_id := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                                           itemkey  => itemkey,
                                                           aname    => 'AUCTION_HEADER_ID');

                -- record that approval response is pending for this approver
                add_action_history(l_auction_header_id,
                           l_transaction_id,
                           'AWARD_APPROVAL_PENDING',
                           NULL,
                           SYSDATE,
                           l_next_approver_employee.user_id,
                           l_next_approver_employee.user_name);

                resultout := 'VALID_NEXT_APPROVER';

        -- otherwise
        ELSE

                resultout := 'INVALID_NEXT_APPROVER';
                IF  l_next_approver.orig_system = 'POS' THEN
                  l_next_approver_name := get_display_name_for_person(l_person_id);
                ELSIF l_next_approver.orig_system = 'PER' THEN
                  l_next_approver_name := get_display_name_for_person(l_next_approver.orig_system_id);
                ELSE
                  l_next_approver_name := get_display_name_for_user(l_next_approver.orig_system_id);
                END IF;
                wf_engine.SetItemAttrText(itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'APPLICATION_ERROR',
                                  avalue   => PON_AUCTION_PKG.getMessage('PON_INVALID_NEXT_APPROVER',
                                                                         NULL,
                                                                         'NAME',
                                                                         l_next_approver_name));
        END IF;
    END IF;
  END IF;

END get_next_approver;

/*
  Errors out the transaction.
  Sets workflow attributes used in notifying the trading partner contact.
*/
PROCEDURE process_error(itemtype   IN VARCHAR2,
                        itemkey    IN VARCHAR2,
                        actid      IN NUMBER,
                        funcmode   IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2) IS
  l_error_date DATE;
  l_tp_contact_user_id NUMBER;
  l_tp_contact_user_name VARCHAR2(100);
  l_auction_header_id NUMBER;
  l_transaction_id VARCHAR2(80);
  l_error_message VARCHAR2(2000);
BEGIN

  -- set rejection date attribute
  l_error_date := SYSDATE;

  wf_engine.SetItemAttrDate(itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'REJECTION_DATE',
                            avalue   => l_error_date);

  -- set attributes specific to OAM error notification
  l_tp_contact_user_name := wf_engine.getItemAttrText(itemtype => itemtype,
                                                      itemkey  => itemkey,
                                                      aname    => 'PREPARER_TP_CONTACT_NAME');

  set_common_user_attributes(itemtype,
                             itemkey,
                             l_tp_contact_user_name,
                             ERROR,
                             FALSE,
                             TRUE);

  l_auction_header_id := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                                     itemkey  => itemkey,
                                                     aname    => 'AUCTION_HEADER_ID');

  l_transaction_id := wf_engine.GetItemAttrText(itemtype => itemtype,
                                                itemkey  => itemkey,
                                                aname    => 'AME_TRANSACTION_ID');

  l_error_message := wf_engine.GetItemAttrText(itemtype => itemtype,
                                               itemkey  => itemkey,
                                               aname    => 'APPLICATION_ERROR');

  SELECT user_id
  INTO l_tp_contact_user_id
  FROM fnd_user
  WHERE user_name = l_tp_contact_user_name;

  -- record that document as been rejected (as a result of an error)
  add_action_history(l_auction_header_id,
                     l_transaction_id,
                     'AWARD_REJECT',
                     l_error_message,
                     l_error_date,
                     0,
                     NULL);

  -- change the approval status of the transaction to REJECTED
  UPDATE pon_auction_headers_all
  SET
    award_approval_status = 'REJECTED',
    last_updated_by = 0,
    last_update_date = SYSDATE
  WHERE auction_header_id = l_auction_header_id;

END process_error;

/*
  Determines if an OAM error has been raised.
*/
PROCEDURE is_oam_error(itemtype   IN VARCHAR2,
                       itemkey    IN VARCHAR2,
                       actid      IN NUMBER,
                       funcmode   IN VARCHAR2,
                       resultout  OUT NOCOPY VARCHAR2) IS
BEGIN

  IF wf_engine.GetItemAttrText(itemtype => itemtype,
                               itemkey  => itemkey,
                               aname    => 'OAM_ERROR') <> 'NO' THEN
    resultout := 'Y';
  ELSE
    resultout := 'N';
  END IF;

END is_oam_error;

/*
  Determines if an OAM administrator is available.
  Sets workflow attributes used in notifying the OAM administrator of an error.
*/
PROCEDURE is_oam_admin_available(itemtype   IN VARCHAR2,
                                 itemkey    IN VARCHAR2,
                                 actid      IN NUMBER,
                                 funcmode   IN VARCHAR2,
                                 resultout  OUT NOCOPY VARCHAR2) IS
  l_error_date DATE;
  l_oam_admin_user_name VARCHAR2(100);
  l_admin_approver ame_util.approverRecord2;

  l_current_log_level NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_exception_log_level NUMBER := FND_LOG.LEVEL_EXCEPTION;
  l_statement_log_level NUMBER := FND_LOG.LEVEL_STATEMENT;
  l_module_name VARCHAR2(80) := 'pon.plsql.PON_AWARD_APPROVAL_PKG.IS_OAM_ADMIN_AVAILABLE';
BEGIN

  BEGIN
    -- determine the OAM administrator
    log_string(l_statement_log_level, l_current_log_level, l_module_name, 'calling ame_api2.getAdminApprover');
    ame_api2.getAdminApprover(applicationIdIn   => APPLICATION_ID,
                             transactionTypeIn => AWARD_TRANSACTION_TYPE,
                             adminApproverOut  => l_admin_approver);

    log_string(l_statement_log_level, l_current_log_level, l_module_name, 'calling ame_api2.getAdminApprover returns ' || fnd_global.newline || format_ame_approver(l_admin_approver));

  EXCEPTION
    WHEN OTHERS THEN
      l_admin_approver := ame_util.emptyApproverRecord2;

      log_string(l_exception_log_level, l_current_log_level, l_module_name, SQLERRM);
  END;

 IF l_admin_approver.orig_system_id IS NOT NULL THEN
    BEGIN
      SELECT user_name
      INTO l_oam_admin_user_name
      FROM fnd_user
      WHERE employee_id = l_admin_approver.orig_system_id;
    EXCEPTION
      WHEN no_data_found OR too_many_rows THEN
        NULL;
    END;
  END IF;

  -- if the OAM administrator could be determined
  IF l_oam_admin_user_name IS NOT NULL THEN
    -- set OAM Administrator attribute
    wf_engine.setItemAttrText(itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'OAM_ADMIN_USER',
                              avalue   => l_oam_admin_user_name);

    -- set attributes specific to OAM error notification for OAM administrator
    set_common_user_attributes(itemtype,
                               itemkey,
                               l_oam_admin_user_name,
                               ERROR_FOR_ADMIN,
                               FALSE,
                               TRUE);

    resultout := 'Y';
  ELSE
    -- otherwise
    resultout := 'N';
  END IF;

END is_oam_admin_available;

/*
  Marks the transaction as rejected.
*/
PROCEDURE document_rejected(itemtype   IN VARCHAR2,
                            itemkey    IN VARCHAR2,
                            actid      IN NUMBER,
                            funcmode   IN VARCHAR2,
                            resultout  OUT NOCOPY VARCHAR2) IS
  l_auction_header_id NUMBER;
  l_transaction_id VARCHAR2(80);
BEGIN

  -- if the rejection date is null, set it to the current date
  IF wf_engine.GetItemAttrDate(itemtype => itemtype,
                               itemkey  => itemkey,
                               aname    => 'REJECTION_DATE') IS NULL THEN
    wf_engine.SetItemAttrDate(itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'REJECTION_DATE',
                              avalue   => SYSDATE);
  END IF;

  -- set attributes specific to award rejected notification
  set_award_rejected_attributes(itemtype, itemkey);

  l_auction_header_id := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                                     itemkey  => itemkey,
                                                     aname    => 'AUCTION_HEADER_ID');

  l_transaction_id := wf_engine.GetItemAttrText(itemtype => itemtype,
                                                itemkey  => itemkey,
                                                aname    => 'AME_TRANSACTION_ID');

  -- change the approval status of the transaction to REJECTED
  UPDATE pon_auction_headers_all
  SET
    award_approval_status = 'REJECTED',
    last_updated_by = 0,
    last_update_date = SYSDATE
  WHERE auction_header_id = l_auction_header_id;

END document_rejected;

/*
  Marks the transaction as approved.
*/
PROCEDURE document_approved(itemtype   IN VARCHAR2,
                            itemkey    IN VARCHAR2,
                            actid      IN NUMBER,
                            funcmode   IN VARCHAR2,
                            resultout  OUT NOCOPY VARCHAR2) IS
  l_auction_header_id NUMBER;
  l_transaction_id VARCHAR2(80);
  l_approval_date DATE;
BEGIN

  -- if the approval date is null, set it to the current date
  l_approval_date := wf_engine.GetItemAttrDate(itemtype => itemtype,
                                               itemkey  => itemkey,
                                               aname    => 'APPROVAL_DATE');

  IF l_approval_date IS NULL THEN
    l_approval_date := SYSDATE;

    wf_engine.SetItemAttrDate(itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'APPROVAL_DATE',
                              avalue   => l_approval_date);
  END IF;

  -- set attributes specific to award approved notification
  set_award_approved_attributes(itemtype, itemkey);

  l_auction_header_id := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                                     itemkey  => itemkey,
                                                     aname    => 'AUCTION_HEADER_ID');

  l_transaction_id := wf_engine.GetItemAttrText(itemtype => itemtype,
                                                itemkey  => itemkey,
                                                aname    => 'AME_TRANSACTION_ID');

  -- record that document as been approved (by all required approvers, if any)
  add_action_history(l_auction_header_id,
                     l_transaction_id,
                     'AWARD_APPROVE',
                     PON_AUCTION_PKG.getMessage('PON_AWARD_IS_APPROVED'),
                     l_approval_date,
                     0,
                     NULL);

  -- change the approval status of the transaction to APPROVED
  UPDATE pon_auction_headers_all
  SET
    award_approval_status = 'APPROVED',
    last_updated_by = 0,
    last_update_date = SYSDATE
  WHERE auction_header_id = l_auction_header_id;

END document_approved;

/*
  Processes the approver response on the transaction.
*/
PROCEDURE process_approver_response(itemtype   IN VARCHAR2,
                                    itemkey    IN VARCHAR2,
                                    actid      IN NUMBER,
                                    funcmode   IN VARCHAR2,
                                    resultout  OUT NOCOPY VARCHAR2) IS
  l_response_type VARCHAR2(50);
  l_auction_header_id NUMBER;
  l_transaction_id VARCHAR2(80);
  l_response_date DATE;
  l_note_to_buyer VARCHAR2(2000);
  l_approver_user_name VARCHAR2(100);
  l_approver_string VARCHAR2(1500);

  l_approver_employee employeeRecord;
  l_person_id NUMBER;

  l_approver ame_util.approverRecord2;
  l_forwardee ame_util.approverRecord2;
  l_approver_old ame_util.approverRecord;

  l_forwardee_user_name VARCHAR2(100);
  l_forwardee_employee employeeRecord;
  l_action_type VARCHAR2(25);
  l_approval_status VARCHAR2(50);
  l_valid_response BOOLEAN;
  l_success_flag BOOLEAN;
  l_source_type_out VARCHAR2(50);
  l_idList ame_util.idList;

  l_current_log_level NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_exception_log_level NUMBER := FND_LOG.LEVEL_EXCEPTION;
  l_statement_log_level NUMBER := FND_LOG.LEVEL_STATEMENT;
  l_module_name VARCHAR2(80) := 'pon.plsql.PON_AWARD_APPROVAL_PKG.PROCESS_APPROVER_RESPONSE';
BEGIN

  l_response_type := wf_engine.GetItemAttrText(itemtype => itemtype,
                                               itemkey  => itemkey,
                                               aname    => 'RESULT');

  l_auction_header_id := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                                     itemkey  => itemkey,
                                                     aname    => 'AUCTION_HEADER_ID');

  l_transaction_id := wf_engine.GetItemAttrText(itemtype => itemtype,
                                                itemkey  => itemkey,
                                                aname    => 'AME_TRANSACTION_ID');

  l_approver_user_name := wf_engine.GetItemAttrText(itemtype => itemtype,
                                                    itemkey  => itemkey,
                                                    aname    => 'APPROVER_USER');

  -- get the note to buyer attribute
  l_note_to_buyer := wf_engine.GetItemAttrText(itemtype => itemtype,
                                               itemkey  => itemkey,
                                               aname    => 'NOTE_TO_BUYER');

  l_response_date := SYSDATE;

  -- determine action type for response type
  IF l_response_type = 'APPROVE' THEN
    l_action_type := 'AWARD_APPROVE';
  ELSIF l_response_type = 'REJECT' THEN
    l_action_type := 'AWARD_REJECT';
  ELSIF l_response_type = 'FORWARD' THEN
    l_action_type := 'AWARD_APPROVAL_FORWARD';
  ELSIF l_response_type = 'APPROVE_AND_FORWARD' THEN
    l_action_type := 'AWARD_APPROVE_AND_FORWARD';
  END IF;


  l_approver_string := wf_engine.GetItemAttrText( itemtype => itemtype,
                                                  itemkey  => itemkey,
                                                  aname    => 'APPROVER_STRING');

  log_string( l_statement_log_level,
              l_current_log_level,
              l_module_name,
              'l_approver_string :' || l_approver_string );

  -- Find out the approver record type.
  IF is_old_approver_record( l_approver_string ) THEN

      log_string( l_statement_log_level,
                  l_current_log_level,
                  l_module_name,
                  'It is_old_approver_record. So calling ame_util.apprRecordToApprRecord2' );
      parse_approver(l_approver_string, l_approver_old);
      ame_util.apprRecordToApprRecord2( approverRecordIn => l_approver_old,
                                        approverRecord2Out => l_approver );
  ELSE
      parse_ame_approver(l_approver_string, l_approver);
  END IF;

  log_string( l_statement_log_level,
              l_current_log_level,
              l_module_name,
              'Done with Parsing the approver string. Successfully framed the approver record.');

  -- record approver response in PON_ACTION_HISTORY table
  IF  l_approver.orig_system = 'POS' THEN  -- Position Hierarchy setup in AME.

      BEGIN
          l_person_id := NULL;
          ame_api3.parseApproverSource( approverSourceIn      => l_approver.source,
                                        sourceDescriptionOut  => l_source_type_out,
                                        ruleIdListOut         => l_idList);

          IF( l_approver.api_insertion = ame_util.apiAuthorityInsertion AND
              l_source_type_out <> ame_util.forwardeeSource ) THEN
              l_person_id := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                                         itemkey  => itemkey,
                                                        aname    => 'FIRST_AUTHORITY_APPROVER_ID');
          END IF;
          IF( l_person_id IS NULL OR l_person_id = -1 ) THEN
              SELECT person_id into l_person_id FROM (
                  SELECT person.person_id FROM per_all_people_f person, per_all_assignments_f asg
                    WHERE asg.position_id = l_approver.orig_system_id and trunc(sysdate) between person.effective_start_date
                      and nvl(person.effective_end_date, trunc(sysdate)) and person.person_id = asg.person_id
                      and asg.primary_flag = 'Y' and asg.assignment_type in ('E','C')
                      and ( person.current_employee_flag = 'Y' or person.current_npw_flag = 'Y' )
                      and asg.assignment_status_type_id not in (
                       SELECT assignment_status_type_id FROM per_assignment_status_types
                       WHERE per_system_status = 'TERM_ASSIGN'
                      ) and trunc(sysdate) between asg.effective_start_date and asg.effective_end_date order by person.last_name
              ) where rownum = 1;
          END IF;
      EXCEPTION
          WHEN OTHERS THEN
             l_person_id := NULL;
      END;

      IF l_person_id IS NULL THEN  -- There are no users associated to this position. Raise an error.
           resultout := 'OAM_API_ERROR';
           l_success_flag := FALSE;

           -- this message can be seen only by admin.
           wf_engine.SetItemAttrText( itemtype => itemtype,
                                      itemkey  => itemkey,
                                      aname    => 'OAM_ERROR',
                                      avalue   => PON_AUCTION_PKG.getMessage('PON_NO_PERSON_FOR_POSITION', '', 'POSITION_NAME', l_approver.display_name ));

           -- this message can be seen by any buyer.
           wf_engine.SetItemAttrText( itemtype => itemtype,
                                      itemkey  => itemkey,
                                      aname    => 'APPLICATION_ERROR',
                                      avalue   => PON_AUCTION_PKG.getMessage('PON_NO_PERSON_FOR_POSITION', '', 'POSITION_NAME', l_approver.display_name ));

           log_string(l_exception_log_level, l_current_log_level, l_module_name, PON_AUCTION_PKG.getMessage('PON_NO_PERSON_FOR_POSITION', '', 'POSITION_NAME', l_approver.display_name ));
           RETURN;
      END IF;

      get_employee_info_for_person(l_person_id, l_approver_employee);

  ELSIF l_approver.orig_system = 'PER' THEN  -- Emp-Supervisor Hierarchy setup in AME.

      get_employee_info_for_person(l_approver.orig_system_id, l_approver_employee);

  ELSE  -- FND USER setup in AME.

      get_employee_info_for_user(l_approver.orig_system_id, l_approver_employee);

  END IF;

  log_string( l_statement_log_level,
              l_current_log_level,
              l_module_name,
              'Got the user details and going to update the action history record.');

  update_action_history( l_auction_header_id,
                         l_transaction_id,
                         l_action_type,
                         l_note_to_buyer,
                         l_response_date,
                         l_approver_employee.user_id);

  -- set the appropriate attributes depending on response type
  IF l_response_type IN ('APPROVE', 'APPROVE_AND_FORWARD') THEN
    wf_engine.SetItemAttrDate(itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'APPROVAL_DATE',
                              avalue   => l_response_date);
	-- added for bug 18068754 fix
	wf_engine.SetItemAttrText(itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'NOTIF_FROM_USER',
                            avalue   => l_approver_user_name);
  ELSIF l_response_type = 'REJECT' THEN
    wf_engine.SetItemAttrDate(itemtype => itemtype,
                              itemkey  => itemkey,
                              aname    => 'REJECTION_DATE',
                              avalue   => l_response_date);
  END IF;


  -- perform validation on approval response
  l_valid_response := TRUE;

  -- if the approver is approving, simply mark the result as an approval
  IF l_response_type = 'APPROVE' THEN
    resultout := 'APPROVAL';
  -- if the approver is rejecting, simply mark the result as a rejection
  ELSIF l_response_type = 'REJECT' THEN
    resultout := 'REJECTION';
  -- if the approver is forwarding, validate the forwardee
  ELSIF l_response_type IN ('FORWARD', 'APPROVE_AND_FORWARD') THEN
    l_forwardee_user_name := wf_engine.GetItemAttrText(itemtype => itemtype,
                                                       itemkey  => itemkey,
                                                       aname    => 'APPROVER_FORWARDEE_USER');

    -- if no forwardee was specified
    IF l_forwardee_user_name IS NULL THEN
      resultout := 'INVALID_FORWARD';
      l_valid_response := FALSE;

      -- set the Application Error workflow attribute
      wf_engine.SetItemAttrText(itemtype => itemtype,
                                itemkey  => itemkey,
                                aname    => 'APPLICATION_ERROR',
                                avalue   => PON_AUCTION_PKG.getMessage('PON_NO_FORWARDEE_SPECIFIED'));
    -- otherwise
    ELSE
      -- validate that the forwardee is an active employee and has a user account
      get_employee_info_for_user(l_forwardee_user_name, l_forwardee_employee);

      -- response is valid only if forwardee is valid
      IF l_forwardee_employee.user_id IS NOT NULL AND l_forwardee_employee.person_id IS NOT NULL THEN
        resultout := 'VALID_FORWARD';
      ELSE

        resultout := 'INVALID_FORWARD';
        l_valid_response := FALSE;

        -- set the Application Error workflow attribute
        wf_engine.SetItemAttrText(itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'APPLICATION_ERROR',
                                  avalue   => PON_AUCTION_PKG.getMessage('PON_INVALID_FORWARDEE', NULL, 'NAME', get_display_name_for_user(l_forwardee_user_name)));
      END IF;
    END IF;
  END IF;

  -- post-validation: if validation was successful, update OAM approver list
  IF l_valid_response THEN

    -- determine approval status for response type
    -- set approver's approval status
    IF l_response_type = 'APPROVE' THEN
       l_approver.approval_status:= ame_util.approvedStatus;
    ELSIF l_response_type = 'REJECT' THEN
      l_approver.approval_status := ame_util.rejectStatus;
    ELSIF l_response_type = 'FORWARD' THEN
      l_approver.approval_status := ame_util.forwardStatus;
    ELSIF l_response_type = 'APPROVE_AND_FORWARD' THEN
      l_approver.approval_status := ame_util.approveAndForwardStatus;
    END IF;

    -- use forwardee's person id since person id is preferred
    IF l_forwardee_employee.person_id IS NOT NULL THEN

      l_forwardee.orig_system_id := l_forwardee_employee.person_id;
      l_forwardee.orig_system := l_approver.orig_system;

      -- set forwardee's api_insertion and authority fields
      IF l_approver.api_insertion IN (ame_util.oamGenerated, ame_util.apiAuthorityInsertion) AND
         l_approver.authority = ame_util.authorityApprover THEN
        l_forwardee.api_insertion := ame_util.apiAuthorityInsertion;
      ELSE
        l_forwardee.api_insertion := ame_util.apiInsertion;
      END IF;

      IF l_forwardee.orig_system = 'POS' THEN
            select full_name into l_forwardee.display_name from per_all_people_f where person_id = l_forwardee.orig_system_id and TRUNC(sysdate) between effective_start_date and effective_end_date;
            BEGIN
                SELECT position_id into l_forwardee.orig_system_id FROM PER_ALL_ASSIGNMENTS_F pa
                    WHERE pa.person_id = l_forwardee.orig_system_id and pa.primary_flag = 'Y' and pa.assignment_type in ('E','C')
                    and pa.position_id is not null and pa.assignment_status_type_id not in (
                    select assignment_status_type_id from per_assignment_status_types where per_system_status = 'TERM_ASSIGN')
                    and TRUNC ( pa.effective_start_date )
                    <=  TRUNC(SYSDATE) AND NVL(pa.effective_end_date, TRUNC( SYSDATE)) >= TRUNC(SYSDATE);
            EXCEPTION
                 WHEN OTHERS THEN
                    l_forwardee.orig_system_id := NULL;
            END;

            IF l_forwardee.orig_system_id IS NULL THEN
               resultout := 'INVALID_FORWARD';
               l_success_flag := FALSE;

               -- this message can be seen only by admin.
                wf_engine.SetItemAttrText( itemtype => itemtype,
                                           itemkey  => itemkey,
                                           aname    => 'OAM_ERROR',
                                           avalue   => PON_AUCTION_PKG.getMessage('PON_NO_POSITION_FOR_PERSON', '', 'PERSON_NAME', l_forwardee.display_name ));

               -- this message can be seen by any buyer.
               wf_engine.SetItemAttrText( itemtype => itemtype,
                                          itemkey  => itemkey,
                                          aname    => 'APPLICATION_ERROR',
                                          avalue   => PON_AUCTION_PKG.getMessage('PON_INVALID_FORWARDEE', NULL, 'NAME',l_forwardee.display_name ));

               RETURN;
            END IF;
      END IF;

      l_forwardee.approval_status := ame_util.nullStatus;

      l_forwardee.authority := l_approver.authority;
      l_forwardee.approver_category :=  l_approver.approver_category;
      l_forwardee.item_class := l_approver.item_class ;
      l_forwardee.item_id := l_approver.item_id ;

      SELECT name into l_forwardee.name FROM wf_roles
              WHERE orig_system = l_forwardee.orig_system and orig_system_id = l_forwardee.orig_system_id and rownum = 1;

      IF l_forwardee.name IS NULL THEN
               resultout := 'INVALID_FORWARD';
               l_success_flag := FALSE;

               -- this message can be seen only by admin.
                wf_engine.SetItemAttrText( itemtype => itemtype,
                                           itemkey  => itemkey,
                                           aname    => 'OAM_ERROR',
                                           avalue   => PON_AUCTION_PKG.getMessage('PON_INVALID_FORWARDEE', NULL, 'NAME',l_forwardee.display_name ));

               -- this message can be seen by any buyer.
               wf_engine.SetItemAttrText( itemtype => itemtype,
                                          itemkey  => itemkey,
                                          aname    => 'APPLICATION_ERROR',
                                          avalue   => PON_AUCTION_PKG.getMessage('PON_INVALID_FORWARDEE', NULL, 'NAME', l_forwardee.display_name ));

               RETURN;
      END IF;
    ELSE
      l_forwardee := ame_util.emptyApproverRecord2;
    END IF;

    l_success_flag := TRUE;

    BEGIN

      -- update the approval status for the approver
      log_string(l_statement_log_level,
                 l_current_log_level,
                 l_module_name,
                 'calling ame_api2.updateApprovalStatus on workflow item key ' || itemkey || fnd_global.newline ||
                 'with approver' || fnd_global.newline || format_ame_approver(l_approver) || fnd_global.newline ||
                 'and forwardee' || fnd_global.newline || format_ame_approver(l_forwardee));

      ame_api2.updateApprovalStatus(applicationIdIn   => APPLICATION_ID,
                                   transactionIdIn   => l_transaction_id,
                                   approverIn        => l_approver,
                                   transactionTypeIn => AWARD_TRANSACTION_TYPE,
                                   forwardeeIn       => l_forwardee);

    EXCEPTION
      WHEN OTHERS THEN

        resultout := 'OAM_API_ERROR';
        l_success_flag := FALSE;

        -- if the OAM API call raises an exception,
        -- set the Application Error and OAM Error workflow attributes
        -- this message is internal and can be seen only by the OAM administrator
        wf_engine.SetItemAttrText(itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'OAM_ERROR',
                                  avalue   => SQLERRM);

        -- this message can be seen by any buyer
        wf_engine.SetItemAttrText(itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => 'APPLICATION_ERROR',
                                  avalue   => PON_AUCTION_PKG.getMessage('PON_OAM_ERROR_OCCURRED'));

        log_string(l_exception_log_level, l_current_log_level, l_module_name, SQLERRM);
    END;
  END IF;

END process_approver_response;

/*
  Starts a new Sourcing Award Approval workflow process for the specified transaction.
*/
PROCEDURE start_workflow_process(p_auction_header_id            IN NUMBER,
                                 p_transaction_id               IN VARCHAR2,
                                 p_item_key                     IN VARCHAR2,
                                 p_note_to_approvers            IN VARCHAR2,
                                 p_first_authority_approver_id  IN NUMBER ) IS
BEGIN

  wf_engine.createProcess(itemtype => AWARD_APPROVAL_WF_ITEM_TYPE,
                          itemkey  => p_item_key,
                          process  => 'AWARD_APPROVAL');

  -- set main language-independent workflow attributes
  set_core_attributes(AWARD_APPROVAL_WF_ITEM_TYPE, p_item_key, p_auction_header_id, p_note_to_approvers, p_first_authority_approver_id);


  -- Bug 4295915: Set the  workflow owner
  wf_engine.SetItemOwner(itemtype => AWARD_APPROVAL_WF_ITEM_TYPE,
                         itemkey  => p_item_key,
                         owner    => fnd_global.user_name);

  -- start workflow process
  wf_engine.StartProcess(itemtype => AWARD_APPROVAL_WF_ITEM_TYPE,
                         itemkey  => p_item_key);

END start_workflow_process;

/*
  Adds an approver to the approver list at a specified position.
  The resulting approver list is returned as a formatted string.
*/
PROCEDURE add_approver(p_auction_header_id     IN NUMBER,
                       p_transaction_id        IN VARCHAR2,
                       p_approver_string       IN VARCHAR2,
                       p_position              IN NUMBER,
                       p_last_update_date      IN DATE,
                       p_approver_list_string  OUT NOCOPY VARCHAR2,
                       p_error_message         OUT NOCOPY VARCHAR2) IS

  l_approver_list ame_util.approversTable2;
  l_approver ame_util.approverRecord2;
  l_available_insertion_list ame_util.insertionsTable2;
  l_insertion_order ame_util.insertionRecord2;
  l_process_out varchar2(2);

  l_error_code NUMBER;

  l_current_log_level NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_exception_log_level NUMBER := FND_LOG.LEVEL_EXCEPTION;
  l_statement_log_level NUMBER := FND_LOG.LEVEL_STATEMENT;
  l_module_name VARCHAR2(80) := 'pon.plsql.PON_AWARD_APPROVAL_PKG.ADD_APPROVER';
BEGIN

  log_string(l_statement_log_level, l_current_log_level, l_module_name, 'adding to approver list for award transaction ' || p_auction_header_id || '-' || p_transaction_id);

  -- check that caller can modify the approver list
  validate_transaction(p_auction_header_id, p_last_update_date, false);

  parse_ame_approver(p_approver_string, l_approver);

  -- get a list of all available insertions for the position at which the approver will be inserted
  log_string(l_statement_log_level, l_current_log_level, l_module_name, 'calling ame_api3.getAvailableInsertions at position ' || p_position);

  ame_api3.getAvailableInsertions(applicationIdIn        => APPLICATION_ID,
                                 transactionIdIn        => p_transaction_id,
                                 positionIn             => p_position,
                                 transactionTypeIn      => AWARD_TRANSACTION_TYPE,
                                 availableInsertionsOut => l_available_insertion_list);

  log_string(l_statement_log_level, l_current_log_level, l_module_name, 'calling ame_api3.getAvailableInsertions returns ' || fnd_global.newline || get_insertion_list_string(l_available_insertion_list));

  -- select an absolute-order, after-approver, before-approver insertion in the list of available insertions
  -- that corresponds to the api insertion and authority value of the approver to be inserted into the approver list

  FOR i IN 1 .. l_available_insertion_list.COUNT LOOP
    IF l_available_insertion_list(i).order_type IN
        (ame_util.absoluteOrder, ame_util.afterApprover, ame_util.beforeApprover) AND
       l_available_insertion_list(i).api_insertion = l_approver.api_insertion AND
       l_available_insertion_list(i).authority = l_approver.authority THEN

        l_insertion_order := l_available_insertion_list(i);

        l_approver.item_class := l_insertion_order.item_class;
        l_approver.item_id := l_insertion_order.item_id;
        l_approver.action_type_id := l_insertion_order.action_type_id;
        l_approver.group_or_chain_id := l_insertion_order.group_or_chain_id;
        l_approver.api_insertion := l_insertion_order.api_insertion;
        l_approver.authority := l_insertion_order.authority;

        SELECT name into l_approver.name FROM wf_roles
              WHERE orig_system = l_approver.orig_system and orig_system_id = l_approver.orig_system_id and rownum = 1;

        IF l_approver.name IS NULL THEN
              raise_application_error(-20001, 'Record Not Found in WF_ROLES for the orig_system_id :' ||
                                               l_approver.orig_system_id || ' -- orig_system :' || l_approver.orig_system );
        END IF;

      EXIT;

    END IF;
  END LOOP;

  -- insert the approver into the approver list with the selected insertion
  log_string(
    l_statement_log_level,
    l_current_log_level,
    l_module_name,
    'calling ame_api3.insertApprover with approver insertion ' || fnd_global.newline || get_insertion_string(l_approver, l_insertion_order) || ' at position ' || p_position);

  ame_api3.insertApprover( applicationIdIn   => APPLICATION_ID,
                           transactionIdIn   => p_transaction_id,
                           approverIn        => l_approver,
                           positionIn        => p_position,
                           insertionIn       => l_insertion_order,
                           transactionTypeIn => AWARD_TRANSACTION_TYPE);

  -- recalculate approver list
  ame_api2.getAllApprovers7( applicationIdIn   => APPLICATION_ID,
                             transactionIdIn   => p_transaction_id,
                             transactionTypeIn => AWARD_TRANSACTION_TYPE,
                             approvalProcessCompleteYNOut => l_process_out,
                             approversOut      => l_approver_list);

  log_string(l_statement_log_level, l_current_log_level, l_module_name, 'calling ame_api2.getAllApprovers7 returns ' || fnd_global.newline || format_ame_approver_list(l_approver_list));

  p_approver_list_string := format_ame_approver_list(l_approver_list);

  p_error_message := NULL;

  log_string(l_statement_log_level, l_current_log_level, l_module_name, 'added to approver list for award transaction ' || p_auction_header_id || '-' || p_transaction_id);

EXCEPTION
  WHEN OTHERS THEN
    -- reset output variables
    p_approver_list_string := NULL;
    p_error_message := NULL;

    l_error_code := SQLCODE;
    IF l_error_code <= -20000 AND l_error_code >= -20999 THEN
      trim_error_code(l_error_code, SQLERRM, p_error_message);
      log_string(l_exception_log_level, l_current_log_level, l_module_name, SQLERRM);
    ELSE
      -- raise all Oracle-predefined and user-defined exceptions
      RAISE;
    END IF;
END add_approver;

/*
  Deletes an approver from the approver list.
  The resulting approver list is returned as a formatted string.
*/
PROCEDURE delete_approver(p_auction_header_id     IN NUMBER,
                          p_transaction_id        IN VARCHAR2,
                          p_approver_string       IN VARCHAR2,
                          p_last_update_date      IN DATE,
                          p_approver_list_string  OUT NOCOPY VARCHAR2,
                          p_error_message         OUT NOCOPY VARCHAR2) IS

  l_approver_list ame_util.approversTable2;
  l_approver ame_util.approverRecord2;
  l_process_out varchar2(2);

  l_error_code NUMBER;

  l_current_log_level NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_exception_log_level NUMBER := FND_LOG.LEVEL_EXCEPTION;
  l_statement_log_level NUMBER := FND_LOG.LEVEL_STATEMENT;
  l_module_name VARCHAR2(80) := 'pon.plsql.PON_AWARD_APPROVAL_PKG.DELETE_APPROVER';
BEGIN

  log_string(l_statement_log_level, l_current_log_level, l_module_name, 'deleting from approver list for award transaction ' || p_auction_header_id || '-' || p_transaction_id);

  -- check that caller can modify the approver list
  validate_transaction(p_auction_header_id, p_last_update_date, false);

  parse_ame_approver( p_approver_string, l_approver );

  -- delete approver from approver list
  log_string(l_statement_log_level, l_current_log_level, l_module_name, 'calling ame_api3.suppressApprover with ' || fnd_global.newline || format_ame_approver(l_approver));

  ame_api3.suppressApprover(applicationIdIn   => APPLICATION_ID,
                            transactionIdIn   => p_transaction_id,
                            approverIn        => l_approver,
                            transactionTypeIn => AWARD_TRANSACTION_TYPE);

  -- recalculate approver list
  ame_api2.getAllApprovers7( applicationIdIn   => APPLICATION_ID,
                             transactionIdIn   => p_transaction_id,
                             transactionTypeIn => AWARD_TRANSACTION_TYPE,
                             approvalProcessCompleteYNOut => l_process_out,
                             approversOut      => l_approver_list);

  log_string(l_statement_log_level, l_current_log_level, l_module_name, 'calling ame_api2.getAllApprovers7 returns ' || fnd_global.newline || format_ame_approver_list(l_approver_list));

  p_approver_list_string := format_ame_approver_list( l_approver_list);

  p_error_message := NULL;

  log_string(l_statement_log_level, l_current_log_level, l_module_name, 'deleted from approver list for award transaction ' || p_auction_header_id || '-' || p_transaction_id);

EXCEPTION
  WHEN OTHERS THEN
    -- reset output variables
    p_approver_list_string := NULL;
    p_error_message := NULL;

    l_error_code := SQLCODE;
    IF l_error_code <= -20000 AND l_error_code >= -20999 THEN
      trim_error_code(l_error_code, SQLERRM, p_error_message);
      log_string(l_exception_log_level, l_current_log_level, l_module_name, SQLERRM);
    ELSE
      -- raise all Oracle-predefined and user-defined exceptions
      RAISE;
    END IF;
END delete_approver;

/*
  Changes the first authority approver in the approver list.
  The resulting approver list is returned as a formatted string.
*/
PROCEDURE change_first_approver(p_auction_header_id     IN NUMBER,
                                p_transaction_id        IN VARCHAR2,
                                p_approver_string       IN VARCHAR2,
                                p_last_update_date      IN DATE,
                                p_approver_list_string  OUT NOCOPY VARCHAR2,
                                p_error_message         OUT NOCOPY VARCHAR2) IS

  l_approver_list ame_util.approversTable2;
  l_approver ame_util.approverRecord2;
  l_process_out      VARCHAR2(1);

  insertion ame_util.insertionRecord2;
  l_available_insertion_list ame_util.insertionsTable2;
  l_current_first_approver ame_util.approverRecord2;

  l_error_code NUMBER;

  l_current_log_level NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_exception_log_level NUMBER := FND_LOG.LEVEL_EXCEPTION;
  l_statement_log_level NUMBER := FND_LOG.LEVEL_STATEMENT;
  l_module_name VARCHAR2(80) := 'pon.plsql.PON_AWARD_APPROVAL_PKG.CHANGE_FIRST_APPROVER';
BEGIN

  log_string(l_statement_log_level, l_current_log_level, l_module_name, 'changing first authority approver for award transaction ' || p_auction_header_id || '-' || p_transaction_id);

  -- check that caller can modify the approver list
  validate_transaction(p_auction_header_id, p_last_update_date, false);

  -- clear out all approver deletions
  log_string(l_statement_log_level, l_current_log_level, l_module_name, 'calling ame_api3.clearSuppressions');
  ame_api3.clearSuppressions(applicationIdIn   => APPLICATION_ID,
                             transactionIdIn   => p_transaction_id,
                             transactionTypeIn => AWARD_TRANSACTION_TYPE);

  parse_ame_approver(p_approver_string, l_approver);

  -- corner case scenarios. Find out the current first approver and set the fields accordingly.
  ame_api2.getAllApprovers7( applicationIdIn   => APPLICATION_ID,
                             transactionIdIn   => p_transaction_id,
                             transactionTypeIn => AWARD_TRANSACTION_TYPE,
                             approvalProcessCompleteYNOut => l_process_out,
                             approversOut      => l_approver_list);

  for i in 1 .. l_approver_list.count loop
    if( l_approver_list(i).authority = ame_util.authorityApprover
        and l_approver_list(i).group_or_chain_id < 3
        and l_approver_list(i).api_insertion = ame_util.oamGenerated) then
          l_current_first_approver :=  l_approver_list(i) ;
	  log_string(l_statement_log_level, l_current_log_level, l_module_name,'authorityApprover: ' || l_current_first_approver.authority);

          exit;
    end if;
  end loop;
 log_string(l_statement_log_level, l_current_log_level, l_module_name,'l_current_first_approver.orig_system  ' ||l_current_first_approver.orig_system || ', l_approver.orig_system ' ||l_approver.orig_system);


  IF l_current_first_approver.orig_system = 'POS' AND l_approver.orig_system = 'PER' THEN

        log_string(l_statement_log_level, l_current_log_level, l_module_name, ' ---- Position Record. So trying to find out the position details ---- ');

        l_approver.orig_system := 'POS';
        IF l_approver.orig_system_id IS NOT NULL THEN
            select full_name into l_approver.display_name from per_all_people_f where person_id = l_approver.orig_system_id and TRUNC(sysdate) between effective_start_date and effective_end_date ;
            BEGIN
                SELECT position_id into l_approver.orig_system_id FROM PER_ALL_ASSIGNMENTS_F pa
                    WHERE pa.person_id = l_approver.orig_system_id and pa.primary_flag = 'Y' and pa.assignment_type in ('E','C')
                    and pa.position_id is not null and pa.assignment_status_type_id not in (
                    select assignment_status_type_id from per_assignment_status_types where per_system_status = 'TERM_ASSIGN')
                    and TRUNC ( pa.effective_start_date )
                    <=  TRUNC(SYSDATE) AND NVL(pa.effective_end_date, TRUNC( SYSDATE)) >= TRUNC(SYSDATE);
            EXCEPTION
                 WHEN OTHERS THEN
                    l_approver.orig_system_id := NULL;
            END;

            IF l_approver.orig_system_id IS NULL THEN
               raise_application_error(-20001,PON_AUCTION_PKG.getMessage('PON_NO_POSITION_FOR_PERSON', '', 'PERSON_NAME', l_approver.display_name ));
            END IF;
        END IF;
  END IF;

  -- set the mandatory default attributes for the first authority approver.
  -- this will make sure we have populated the correct values.
  l_approver.authority := ame_util.authorityApprover;
  l_approver.api_insertion := ame_util.apiAuthorityInsertion;
  l_approver.approval_status := ame_util.nullStatus;
  l_approver.approver_category := ame_util.approvalApproverCategory ;
  l_approver.item_class := l_current_first_approver.item_class ;
  l_approver.item_id := l_current_first_approver.item_id ;
  l_approver.action_type_id := l_current_first_approver.action_type_id ;
  l_approver.group_or_chain_id := l_current_first_approver.group_or_chain_id ;

  -- set first authority approver
  log_string(l_statement_log_level, l_current_log_level, l_module_name, 'calling ame_api2.setFirstAuthorityApprover with ' || fnd_global.newline || format_ame_approver(l_approver));

  SELECT name into l_approver.name FROM wf_roles
         WHERE orig_system = l_approver.orig_system and orig_system_id = l_approver.orig_system_id and rownum = 1;

  IF l_approver.name IS NULL THEN
         raise_application_error(-20001, 'Record Not Found in WF_ROLES for the orig_system_id :' ||
                                          l_approver.orig_system_id || ' -- orig_system :' || l_approver.orig_system );
  END IF;

  ame_api2.setFirstAuthorityApprover(applicationIdIn      => APPLICATION_ID,
                                     transactionIdIn      => p_transaction_id,
                                     approverIn           => l_approver,
                                     transactionTypeIn    => AWARD_TRANSACTION_TYPE,
                                     clearChainStatusYNIn => ame_util.booleanTrue);

  -- recalculate approver list
  ame_api2.getAllApprovers7( applicationIdIn   => APPLICATION_ID,
                             transactionIdIn   => p_transaction_id,
                             transactionTypeIn => AWARD_TRANSACTION_TYPE,
                             approvalProcessCompleteYNOut => l_process_out,
                             approversOut      => l_approver_list);

  log_string(l_statement_log_level, l_current_log_level, l_module_name, 'calling ame_api2.getAllApprovers7 returns ' || fnd_global.newline || format_ame_approver_list(l_approver_list));

  p_approver_list_string  := format_ame_approver_list( l_approver_list);

  p_error_message := NULL;

  log_string(l_statement_log_level, l_current_log_level, l_module_name, 'changing first authority approver for award transaction ' || p_auction_header_id || '-' || p_transaction_id);

EXCEPTION
  WHEN OTHERS THEN
    -- reset output variables
    p_approver_list_string := NULL;
    p_error_message := NULL;

    l_error_code := SQLCODE;
    IF l_error_code <= -20000 AND l_error_code >= -20999 THEN
      trim_error_code(l_error_code, SQLERRM, p_error_message);
      log_string(l_exception_log_level, l_current_log_level, l_module_name, SQLERRM);
    ELSE
      -- raise all Oracle-predefined and user-defined exceptions
      RAISE;
    END IF;
END change_first_approver;

/*
  Resets the approver list to its initial state.
  The resulting approver list is returned as a formatted string.
*/
PROCEDURE reset_approver_list(p_auction_header_id         IN NUMBER,
                              p_transaction_id            IN VARCHAR2,
                              p_last_update_date          IN DATE,
                              p_approver_list_string      OUT NOCOPY VARCHAR2,
                              p_can_delete_oam_approvers  OUT NOCOPY VARCHAR2,
                              p_error_message             OUT NOCOPY VARCHAR2) IS

  l_approver_list ame_util.approversTable2;
  l_attribute_value1 VARCHAR2(10);
  l_attribute_value2 VARCHAR2(10);
  l_attribute_value3 VARCHAR2(10);
  l_process_out      VARCHAR2(10);

  l_error_code NUMBER;

  l_current_log_level NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_exception_log_level NUMBER := FND_LOG.LEVEL_EXCEPTION;
  l_statement_log_level NUMBER := FND_LOG.LEVEL_STATEMENT;
  l_module_name VARCHAR2(80) := 'pon.plsql.PON_AWARD_APPROVAL_PKG.RESET_APPROVER_LIST';
BEGIN

  log_string(l_statement_log_level, l_current_log_level, l_module_name, 'resetting approver list for award transaction ' || p_auction_header_id || '-' || p_transaction_id);

  -- check that caller can modify the approver list
  validate_transaction(p_auction_header_id, p_last_update_date, false);

  -- clear out all approval state
  log_string(l_statement_log_level, l_current_log_level, l_module_name, 'calling ame_api2.clearAllApprovals');
  ame_api2.clearAllApprovals(applicationIdIn   => APPLICATION_ID,
                            transactionIdIn   => p_transaction_id,
                            transactionTypeIn => AWARD_TRANSACTION_TYPE);

  -- recalculate approver list
 ame_api2.getAllApprovers7(applicationIdIn   => APPLICATION_ID,
                          transactionIdIn   => p_transaction_id,
                          transactionTypeIn => AWARD_TRANSACTION_TYPE,
                          approvalProcessCompleteYNOut => l_process_out,
                          approversOut      => l_approver_list);

  log_string(l_statement_log_level, l_current_log_level, l_module_name, 'calling ame_api2.getAllApprovers7 returns ' || fnd_global.newline || format_ame_approver_list(l_approver_list));

  p_approver_list_string := format_ame_approver_list(l_approver_list);

  -- determine whether OAM-generated approvers can be deleted
  log_string(l_statement_log_level, l_current_log_level, l_module_name, 'calling ame_api3.getAttributeValue with ' || ame_util.allowDeletingOamApprovers);
  ame_api3.getAttributeValue(applicationIdIn    => APPLICATION_ID,
                             transactionTypeIn  => AWARD_TRANSACTION_TYPE,
                             transactionIdIn    => p_transaction_id,
                             attributeNameIn    => ame_util.allowDeletingOamApprovers,
                             itemIdIn           => NULL,
                             attributeValue1Out => l_attribute_value1,
                             attributeValue2Out => l_attribute_value2,
                             attributeValue3Out => l_attribute_value3);
  log_string(l_statement_log_level, l_current_log_level, l_module_name, 'calling ame_api3.getAttributeValue returns ' || l_attribute_value1);

  IF l_attribute_value1 = 'true' THEN
    p_can_delete_oam_approvers := 'Y';
  ELSE
    p_can_delete_oam_approvers := 'N';
  END IF;

  p_error_message := NULL;

  log_string(l_statement_log_level, l_current_log_level, l_module_name, 'reset approver list for award transaction ' || p_auction_header_id || '-' || p_transaction_id);

EXCEPTION
  WHEN OTHERS THEN
    -- reset output variables
    p_approver_list_string := NULL;
    p_can_delete_oam_approvers := NULL;
    p_error_message := NULL;

    l_error_code := SQLCODE;
    IF l_error_code <= -20000 AND l_error_code >= -20999 THEN
      trim_error_code(l_error_code, SQLERRM, p_error_message);
      log_string(l_exception_log_level, l_current_log_level, l_module_name, SQLERRM);
    ELSE
      -- raise all Oracle-predefined and user-defined exceptions
      RAISE;
    END IF;
END reset_approver_list;

/*
  Submits a transaction for approval.
--  p_first_authority_approver_id : This parameter will be used for futher processing only when the following conditions are satisfied
--           1. Position Hierarchy Rule is setup
--           2. User has specifically changed the first authority approver
--  A WF attribute FIRST_AUTHORITY_APPROVER_ID will be set with this value and will be accessed only for Position Hierarchy setup.
*/
PROCEDURE submit_for_approval(p_auction_header_id           IN NUMBER,
                              p_transaction_id              IN VARCHAR2,
                              p_user_id                     IN NUMBER,
                              p_user_name                   IN VARCHAR2,
                              p_last_update_date            IN DATE,
                              p_note_to_approvers           IN VARCHAR2,
                              p_reject_unawarded_responses  IN VARCHAR2,
                              p_note_to_rejected_suppliers  IN VARCHAR2,
                              p_has_items_flag              IN VARCHAR2,
                              p_has_scoring_teams_flag      IN VARCHAR2,
                              p_scoring_lock_tpc_id         IN NUMBER,
                              p_first_authority_approver_id IN NUMBER,
                              p_error_message               OUT NOCOPY VARCHAR2) IS
  l_item_key VARCHAR2(240);

  l_error_code NUMBER;

   x_return_status   VARCHAR2(20);
   x_msg_count       NUMBER;
   x_msg_data         VARCHAR2(2000);

  l_current_log_level NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_exception_log_level NUMBER := FND_LOG.LEVEL_EXCEPTION;
  l_statement_log_level NUMBER := FND_LOG.LEVEL_STATEMENT;
  l_module_name VARCHAR2(80) := 'pon.plsql.PON_AWARD_APPROVAL_PKG.SUBMIT_FOR_APPROVAL';
BEGIN

  -- reject all active responses without an award decision
  IF p_reject_unawarded_responses = 'Y' THEN
    PON_AWARD_PKG.reject_unawarded_active_bids(p_auction_header_id, p_user_id, p_note_to_rejected_suppliers,p_has_items_flag);
  END IF;

  -- check that caller can modify the approver list
  validate_transaction(p_auction_header_id, p_last_update_date, true);

  -- if team scoring is enabled, call routine to lock team scoring
  IF (p_has_scoring_teams_flag = 'Y') THEN
    -- check to see if the auction was already locked for scoring
    -- if this were true, the p_scoring_lock_tpc_id will be -1
    -- as determined in the ApproverListAM from where this API is called.
    IF (p_scoring_lock_tpc_id = -1) THEN
      NULL;
    ELSE
      -- call pvt API to lock scoring
      IF ( fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string(log_level => fnd_log.level_unexpected
                      ,module    => 'pon_award_approval_pkg.submit_for_approval'
                      ,message   => 'before calling private API to lock team scoring');
      END IF;

      PON_TEAM_SCORING_UTIL_PVT.lock_scoring(p_api_version => 1
	                                      ,p_auction_header_id => p_auction_header_id
	  									  ,p_tpc_id => p_scoring_lock_tpc_id
	   									  ,x_return_status => x_return_status
										  ,x_msg_data => x_msg_data
										  ,x_msg_count => x_msg_count);

      IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        IF ( fnd_log.level_unexpected >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string(log_level => fnd_log.level_unexpected
       	   	        ,module    => 'pon_award_approval_pkg.submit_for_approval'
                    ,message   => 'Error while locking team scoring');
        END IF;
      END IF;
    END IF;
  END IF;

  -- record submit action in PON_ACTION_HISTORY table
  add_action_history(p_auction_header_id,
                     p_transaction_id,
                     'AWARD_APPROVAL_SUBMIT',
                     p_note_to_approvers,
                     SYSDATE,
                     p_user_id,
                     p_user_name);

  -- generate the workflow item key
  -- make the workflow item key of the format '<auction_header_id>-<transaction_id>
  l_item_key := TO_CHAR(p_auction_header_id) || '-' || p_transaction_id;

  -- change the award approval status to INPROCESS
  UPDATE pon_auction_headers_all
  SET
    award_approval_status = 'INPROCESS',
    wf_award_approval_item_key = l_item_key,
    last_updated_by = p_user_id,
    last_update_date = SYSDATE
  WHERE auction_header_id = p_auction_header_id;

  -- start a new workflow process for the transaction
  start_workflow_process(p_auction_header_id,
                         p_transaction_id,
                         l_item_key,
                         p_note_to_approvers,
                         p_first_authority_approver_id);


-- Raise Business Event
  PON_BIZ_EVENTS_PVT.RAISE_NEG_AWD_APPR_STRT_EVENT(
         	      p_api_version  => 1.0 ,
 	              p_init_msg_list => FND_API.G_FALSE,
         	      p_commit         => FND_API.G_FALSE,
 	              p_auction_header_id => p_auction_header_id,
         	      x_return_status  => x_return_status,
 	              x_msg_count      => x_msg_count,
         	      x_msg_data        => x_msg_data);

  p_error_message := NULL;

EXCEPTION
  WHEN OTHERS THEN
    -- reset output variables
    p_error_message := NULL;

    l_error_code := SQLCODE;
    IF l_error_code <= -20000 AND l_error_code >= -20999 THEN
      trim_error_code(l_error_code, SQLERRM, p_error_message);
      log_string(l_exception_log_level, l_current_log_level, l_module_name, SQLERRM);
    ELSE
      -- raise all Oracle-predefined and user-defined exceptions
      RAISE;
    END IF;
END submit_for_approval;

/*
  Makes an approval decision on a award on behalf of the specified user.

  p_decision can be either APPROVE or REJECT.
*/
PROCEDURE make_approval_decision(p_auction_header_id  IN NUMBER,
                                 p_user_name          IN VARCHAR2,
                                 p_decision           IN VARCHAR2,
                                 p_note_to_buyer      IN VARCHAR2,
                                 p_error_message      OUT NOCOPY VARCHAR2) IS
BEGIN

  make_approval_decision(p_auction_header_id, p_user_name, p_decision, p_note_to_buyer, NULL, p_error_message);

END make_approval_decision;

/*
  Makes an approval decision on a transaction on behalf of the specified user.
*/
PROCEDURE make_approval_decision(p_auction_header_id    IN NUMBER,
                                 p_user_name            IN VARCHAR2,
                                 p_decision             IN VARCHAR2,
                                 p_note_to_buyer        IN VARCHAR2,
                                 p_forwardee_user_name  IN VARCHAR2,
                                 p_error_message        OUT NOCOPY VARCHAR2) IS
  l_notification_id NUMBER;
  l_item_key VARCHAR2(240);
  l_notification_found BOOLEAN;

  l_error_code NUMBER;

  l_current_log_level NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  l_exception_log_level NUMBER := FND_LOG.LEVEL_EXCEPTION;
  l_statement_log_level NUMBER := FND_LOG.LEVEL_STATEMENT;
  l_module_name VARCHAR2(80) := 'pon.plsql.PON_AWARD_APPROVAL_PKG.MAKE_APPROVAL_DECISION';
BEGIN

  SELECT wf_award_approval_item_key
  INTO l_item_key
  FROM pon_auction_headers_all
  WHERE auction_header_id = p_auction_header_id;

  -- try to obtain the id of the notification to which the user is responding to
  BEGIN
    SELECT notification_id
    INTO l_notification_id
    FROM wf_item_activity_statuses
    WHERE
          assigned_user = p_user_name
      AND item_type = AWARD_APPROVAL_WF_ITEM_TYPE
      AND item_key = l_item_key
      AND activity_status = 'NOTIFIED';

    l_notification_found := TRUE;
  EXCEPTION
    WHEN no_data_found THEN
      l_notification_found := FALSE;
  END;

  -- if the notification was found, then respond to it with user's decision
  IF l_notification_found THEN
    wf_notification.SetAttrText(l_notification_id, 'RESULT', p_decision);
    wf_notification.SetAttrText(l_notification_id, 'NOTE_TO_BUYER', PON_AUCTION_PKG.replaceHtmlChars(p_note_to_buyer));
    wf_notification.SetAttrText(l_notification_id, 'APPROVER_FORWARDEE_USER', p_forwardee_user_name);
    wf_notification.respond(l_notification_id, p_decision, p_user_name);
  -- otherwise, raise an exception that the notification has already been responded to
  ELSE
    raise_application_error(-20001, PON_AUCTION_PKG.getMessage('PON_NOTIF_ALREADY_RESPONDED'));
  END IF;

  p_error_message := NULL;

EXCEPTION
  WHEN OTHERS THEN
    -- reset output variables
    p_error_message := NULL;

    l_error_code := SQLCODE;
    IF l_error_code <= -20000 AND l_error_code >= -20999 THEN
      trim_error_code(l_error_code, SQLERRM, p_error_message);
      log_string(l_exception_log_level, l_current_log_level, l_module_name, SQLERRM);
    ELSE
      -- raise all Oracle-predefined and user-defined exceptions
      RAISE;
    END IF;
END make_approval_decision;

/*
  Returns true if p_approver1 and p_approver2 match; false otherwise.
*/
FUNCTION approvers_match(p_approver1 ame_util.approverRecord,
                         p_approver2 ame_util.approverRecord) RETURN BOOLEAN IS
BEGIN

  RETURN
    NVL(((p_approver1.user_id IS NULL AND p_approver2.user_id IS NULL) OR
          p_approver1.user_id = p_approver2.user_id) AND
        ((p_approver1.person_id IS NULL AND p_approver2.person_id IS NULL) OR
          p_approver1.person_id = p_approver2.person_id) AND
        ((p_approver1.api_insertion IS NULL AND p_approver2.api_insertion IS NULL) OR
          p_approver1.api_insertion = p_approver2.api_insertion) AND
        ((p_approver1.authority IS NULL AND p_approver2.authority IS NULL) OR
          p_approver1.authority = p_approver2.authority), FALSE);

END approvers_match;

/*
  Reconstructs an ame_util.approverRecord record from a string.
*/
PROCEDURE parse_approver(p_approver_string IN VARCHAR2,
                         p_approver OUT NOCOPY ame_util.approverRecord) IS
  l_start_index INTEGER;
  l_end_index INTEGER;
  l_delimiter_length INTEGER;
  l_field_value VARCHAR2(80);
BEGIN

  l_delimiter_length := LENGTHB(APPROVER_FIELD_DELIMITER);

  l_start_index := 1;
  l_end_index := INSTRB(p_approver_string, APPROVER_FIELD_DELIMITER, l_start_index, 1);
  l_field_value := SUBSTRB(p_approver_string, l_start_index, l_end_index - l_start_index);
  p_approver.user_id := parse_number_field(l_field_value);

  l_start_index := l_end_index + l_delimiter_length;
  l_end_index := INSTRB(p_approver_string, APPROVER_FIELD_DELIMITER, l_start_index, 1);
  l_field_value := SUBSTRB(p_approver_string, l_start_index, l_end_index - l_start_index);
  p_approver.person_id := parse_number_field(l_field_value);

  l_start_index := l_end_index + l_delimiter_length;
  l_end_index := INSTRB(p_approver_string, APPROVER_FIELD_DELIMITER, l_start_index, 1);
  l_field_value := SUBSTRB(p_approver_string, l_start_index, l_end_index - l_start_index);
  p_approver.api_insertion := convert_to_ame_api_insertion(parse_number_field(l_field_value));

  l_start_index := l_end_index + l_delimiter_length;
  l_end_index := INSTRB(p_approver_string, APPROVER_FIELD_DELIMITER, l_start_index, 1);
  l_field_value := SUBSTRB(p_approver_string, l_start_index, l_end_index - l_start_index);
  p_approver.authority := convert_to_ame_authority(parse_number_field(l_field_value));

  l_start_index := l_end_index + l_delimiter_length;
  l_field_value := SUBSTRB(p_approver_string, l_start_index);
  p_approver.approval_status := convert_to_ame_approval_status(parse_number_field(l_field_value));

END parse_approver;


FUNCTION is_old_approver_record( p_approver_string IN VARCHAR2 ) RETURN BOOLEAN IS

  l_start_index INTEGER;
  l_end_index INTEGER;
  l_approver_string_length INTEGER;
  l_delimiter_length INTEGER;
  OLD_APPROVER_FIELD_DELIMITER VARCHAR2(4);
  l_delimiter_count INTEGER;

BEGIN

  OLD_APPROVER_FIELD_DELIMITER := ',,';
  l_delimiter_length := LENGTHB(OLD_APPROVER_FIELD_DELIMITER);

  l_approver_string_length := LENGTHB(p_approver_string);
  l_delimiter_length := LENGTHB(OLD_APPROVER_FIELD_DELIMITER);

  l_start_index := 1;
  l_delimiter_count := 0;

  WHILE l_start_index <= l_approver_string_length LOOP

    l_end_index := INSTRB(p_approver_string, OLD_APPROVER_FIELD_DELIMITER, l_start_index, 1);

    IF l_end_index = 0 THEN
      l_end_index := l_approver_string_length;
    END IF;

    l_start_index := l_end_index + l_delimiter_length;
    l_delimiter_count := l_delimiter_count + 1;

  END LOOP;

  IF l_delimiter_count = 4 THEN
        return TRUE;
  ELSE
        return FALSE;
  END IF;

END is_old_approver_record;

/*
  Reconstructs an ame_util.approverRecord2 record from a string.
*/
PROCEDURE parse_ame_approver( p_approver_string IN VARCHAR2, p_approver OUT NOCOPY ame_util.approverRecord2 ) IS
  l_start_index INTEGER;
  l_end_index INTEGER;
  l_delimiter_length INTEGER;
  l_field_value VARCHAR2(500);
BEGIN

  APPROVER_FIELD_DELIMITER := getAMEFieldDelimiter();

  l_delimiter_length := LENGTHB(APPROVER_FIELD_DELIMITER);

  l_start_index := 1;
  l_end_index := INSTRB(p_approver_string, APPROVER_FIELD_DELIMITER, l_start_index, 1);
  l_field_value := SUBSTRB(p_approver_string, l_start_index, l_end_index - l_start_index);
  p_approver.name := l_field_value;

  l_start_index := l_end_index + l_delimiter_length;
  l_end_index := INSTRB(p_approver_string, APPROVER_FIELD_DELIMITER, l_start_index, 1);
  l_field_value := SUBSTRB(p_approver_string, l_start_index, l_end_index - l_start_index);
  p_approver.orig_system := l_field_value;

  l_start_index := l_end_index + l_delimiter_length;
  l_end_index := INSTRB(p_approver_string, APPROVER_FIELD_DELIMITER, l_start_index, 1);
  l_field_value := SUBSTRB(p_approver_string, l_start_index, l_end_index - l_start_index);
  p_approver.orig_system_id := parse_number_field(l_field_value);

  l_start_index := l_end_index + l_delimiter_length;
  l_end_index := INSTRB(p_approver_string, APPROVER_FIELD_DELIMITER, l_start_index, 1);
  l_field_value := SUBSTRB(p_approver_string, l_start_index, l_end_index - l_start_index);
  p_approver.display_name := l_field_value;

  l_start_index := l_end_index + l_delimiter_length;
  l_end_index := INSTRB(p_approver_string, APPROVER_FIELD_DELIMITER, l_start_index, 1);
  l_field_value := SUBSTRB(p_approver_string, l_start_index, l_end_index - l_start_index);
  p_approver.approver_category := l_field_value;

  l_start_index := l_end_index + l_delimiter_length;
  l_end_index := INSTRB(p_approver_string, APPROVER_FIELD_DELIMITER, l_start_index, 1);
  l_field_value := SUBSTRB(p_approver_string, l_start_index, l_end_index - l_start_index);
  p_approver.api_insertion := convert_to_ame_api_insertion(parse_number_field(l_field_value));

  l_start_index := l_end_index + l_delimiter_length;
  l_end_index := INSTRB(p_approver_string, APPROVER_FIELD_DELIMITER, l_start_index, 1);
  l_field_value := SUBSTRB(p_approver_string, l_start_index, l_end_index - l_start_index);
  p_approver.authority := convert_to_ame_authority(parse_number_field(l_field_value));

  l_start_index := l_end_index + l_delimiter_length;
  l_end_index := INSTRB(p_approver_string, APPROVER_FIELD_DELIMITER, l_start_index, 1);
  l_field_value := SUBSTRB(p_approver_string, l_start_index, l_end_index - l_start_index);
  p_approver.approval_status := convert_to_ame_approval_status(parse_number_field(l_field_value));

  l_start_index := l_end_index + l_delimiter_length;
  l_end_index := INSTRB(p_approver_string, APPROVER_FIELD_DELIMITER, l_start_index, 1);
  l_field_value := SUBSTRB(p_approver_string, l_start_index, l_end_index - l_start_index);
  p_approver.action_type_id := parse_number_field(l_field_value);

  l_start_index := l_end_index + l_delimiter_length;
  l_end_index := INSTRB(p_approver_string, APPROVER_FIELD_DELIMITER, l_start_index, 1);
  l_field_value := SUBSTRB(p_approver_string, l_start_index, l_end_index - l_start_index);
  p_approver.group_or_chain_id := parse_number_field(l_field_value);

  l_start_index := l_end_index + l_delimiter_length;
  l_end_index := INSTRB(p_approver_string, APPROVER_FIELD_DELIMITER, l_start_index, 1);
  l_field_value := SUBSTRB(p_approver_string, l_start_index, l_end_index - l_start_index);
  p_approver.occurrence := parse_number_field(l_field_value);

  l_start_index := l_end_index + l_delimiter_length;
  l_end_index := INSTRB(p_approver_string, APPROVER_FIELD_DELIMITER, l_start_index, 1);
  l_field_value := SUBSTRB(p_approver_string, l_start_index, l_end_index - l_start_index);
  p_approver.source := l_field_value;

  l_start_index := l_end_index + l_delimiter_length;
  l_end_index := INSTRB(p_approver_string, APPROVER_FIELD_DELIMITER, l_start_index, 1);
  l_field_value := SUBSTRB(p_approver_string, l_start_index, l_end_index - l_start_index);
  p_approver.item_class := l_field_value;

  l_start_index := l_end_index + l_delimiter_length;
  l_end_index := INSTRB(p_approver_string, APPROVER_FIELD_DELIMITER, l_start_index, 1);
  l_field_value := SUBSTRB(p_approver_string, l_start_index, l_end_index - l_start_index);
  p_approver.item_id := l_field_value;

  l_start_index := l_end_index + l_delimiter_length;
  l_end_index := INSTRB(p_approver_string, APPROVER_FIELD_DELIMITER, l_start_index, 1);
  l_field_value := SUBSTRB(p_approver_string, l_start_index, l_end_index - l_start_index);
  p_approver.item_class_order_number := parse_number_field(l_field_value);

  l_start_index := l_end_index + l_delimiter_length;
  l_end_index := INSTRB(p_approver_string, APPROVER_FIELD_DELIMITER, l_start_index, 1);
  l_field_value := SUBSTRB(p_approver_string, l_start_index, l_end_index - l_start_index);
  p_approver.item_order_number := parse_number_field(l_field_value);

  l_start_index := l_end_index + l_delimiter_length;
  l_end_index := INSTRB(p_approver_string, APPROVER_FIELD_DELIMITER, l_start_index, 1);
  l_field_value := SUBSTRB(p_approver_string, l_start_index, l_end_index - l_start_index);
  p_approver.sub_list_order_number := parse_number_field(l_field_value);

  l_start_index := l_end_index + l_delimiter_length;
  l_end_index := INSTRB(p_approver_string, APPROVER_FIELD_DELIMITER, l_start_index, 1);
  l_field_value := SUBSTRB(p_approver_string, l_start_index, l_end_index - l_start_index);
  p_approver.action_type_order_number := parse_number_field(l_field_value);

  l_start_index := l_end_index + l_delimiter_length;
  l_end_index := INSTRB(p_approver_string, APPROVER_FIELD_DELIMITER, l_start_index, 1);
  l_field_value := SUBSTRB(p_approver_string, l_start_index, l_end_index - l_start_index);
  p_approver.group_or_chain_order_number := parse_number_field(l_field_value);

  l_start_index := l_end_index + l_delimiter_length;
  l_end_index := INSTRB(p_approver_string, APPROVER_FIELD_DELIMITER, l_start_index, 1);
  l_field_value := SUBSTRB(p_approver_string, l_start_index, l_end_index - l_start_index);
  p_approver.member_order_number := parse_number_field(l_field_value);

  l_start_index := l_end_index + l_delimiter_length;
  l_field_value := SUBSTRB(p_approver_string, l_start_index);
  p_approver.approver_order_number := parse_number_field(l_field_value);

END parse_ame_approver;


/*
  Creates a string representation of an ame_util.approverRecord record.
*/
PROCEDURE format_approver(p_approver IN ame_util.approverRecord,
                          p_approver_string OUT NOCOPY VARCHAR2) IS
BEGIN

  p_approver_string :=
    p_approver_string ||
    p_approver.user_id || APPROVER_FIELD_DELIMITER ||
    p_approver.person_id || APPROVER_FIELD_DELIMITER ||
    convert_to_pon_api_insertion(p_approver.api_insertion) || APPROVER_FIELD_DELIMITER ||
    convert_to_pon_authority(p_approver.authority) || APPROVER_FIELD_DELIMITER ||
    convert_to_pon_approval_status(p_approver.approval_status);

END format_approver;

/*
  Creates a string representation of an ame_util.approverRecord record.
*/
FUNCTION format_ame_approver(p_approver IN ame_util.approverRecord2) RETURN VARCHAR2 IS

 l_approver_string VARCHAR2(1500);

BEGIN

   APPROVER_FIELD_DELIMITER := getAMEFieldDelimiter();

   l_approver_string :=
    p_approver.name || APPROVER_FIELD_DELIMITER ||
    p_approver.orig_system || APPROVER_FIELD_DELIMITER ||
    p_approver.orig_system_id || APPROVER_FIELD_DELIMITER ||
    p_approver.display_name || APPROVER_FIELD_DELIMITER ||
    p_approver.approver_category || APPROVER_FIELD_DELIMITER ||
    convert_to_pon_api_insertion(p_approver.api_insertion) || APPROVER_FIELD_DELIMITER ||
    convert_to_pon_authority(p_approver.authority) || APPROVER_FIELD_DELIMITER ||
    convert_to_pon_approval_status(p_approver.approval_status) || APPROVER_FIELD_DELIMITER ||
    p_approver.action_type_id || APPROVER_FIELD_DELIMITER ||
    p_approver.group_or_chain_id || APPROVER_FIELD_DELIMITER ||
    p_approver.occurrence || APPROVER_FIELD_DELIMITER ||
    p_approver.source || APPROVER_FIELD_DELIMITER ||
    p_approver.item_class || APPROVER_FIELD_DELIMITER ||
    p_approver.item_id || APPROVER_FIELD_DELIMITER ||
    p_approver.item_class_order_number || APPROVER_FIELD_DELIMITER ||
    p_approver.item_order_number || APPROVER_FIELD_DELIMITER ||
    p_approver.sub_list_order_number || APPROVER_FIELD_DELIMITER ||
    p_approver.action_type_order_number || APPROVER_FIELD_DELIMITER ||
    p_approver.group_or_chain_order_number || APPROVER_FIELD_DELIMITER ||
    p_approver.member_order_number || APPROVER_FIELD_DELIMITER ||
    p_approver.approver_order_number;

    return l_approver_string;

END format_ame_approver;

/*
  Reconstructs an ame_util.approversTable table from a string.
*/
PROCEDURE parse_approver_list(p_approver_list_string IN VARCHAR2,
                              p_approver_list OUT NOCOPY ame_util.approversTable) IS
  l_start_index INTEGER;
  l_end_index INTEGER;
  l_list_string_length INTEGER;
  l_delimiter_length INTEGER;
  l_list_index INTEGER;
  l_approver_string VARCHAR2(240);
  l_approver ame_util.approverRecord;
BEGIN

  l_list_string_length := LENGTHB(p_approver_list_string);
  l_delimiter_length := LENGTHB(APPROVER_RECORD_DELIMITER);

  l_list_index := 1;
  l_start_index := 1;

  WHILE l_start_index <= l_list_string_length LOOP
    l_end_index := INSTRB(p_approver_list_string, APPROVER_RECORD_DELIMITER, l_start_index, 1);
    IF l_end_index = 0 THEN
      l_end_index := l_list_string_length + 1;
    END IF;

    l_approver_string := SUBSTRB(p_approver_list_string, l_start_index, l_end_index - l_start_index);
    parse_approver(l_approver_string, l_approver);
    p_approver_list(l_list_index) := l_approver;
    l_list_index := l_list_index + 1;

    l_start_index := l_end_index + l_delimiter_length;
  END LOOP;

END parse_approver_list;

/*
  Creates a string representation of an ame_util.approversTable table.
*/
PROCEDURE format_approver_list(p_approver_list IN ame_util.approversTable,
                               p_approver_list_string OUT NOCOPY VARCHAR2) IS
  l_approver_string VARCHAR2(240);
BEGIN

  FOR i IN 1 .. p_approver_list.COUNT LOOP
    l_approver_string := '';
    format_approver(p_approver_list(i), l_approver_string);

    IF i < p_approver_list.COUNT THEN
      p_approver_list_string := p_approver_list_string || l_approver_string || APPROVER_RECORD_DELIMITER;
    ELSE
      p_approver_list_string := p_approver_list_string || l_approver_string;
    END IF;
  END LOOP;

END format_approver_list;

/*
  Creates a string representation of an ame_util.approversTable2 table.
*/
FUNCTION format_ame_approver_list( p_approver_list IN ame_util.approversTable2) RETURN VARCHAR2 IS
  l_approver_list_string VARCHAR2(32000);
  l_approver_string VARCHAR2(1500);
BEGIN

  APPROVER_RECORD_DELIMITER := getAMERecordDelimiter();

  FOR i IN 1 .. p_approver_list.COUNT LOOP
    l_approver_string := '';
    l_approver_string := format_ame_approver( p_approver_list(i));

    IF i < p_approver_list.COUNT THEN
      l_approver_list_string := l_approver_list_string || l_approver_string || APPROVER_RECORD_DELIMITER;
    ELSE
      l_approver_list_string := l_approver_list_string || l_approver_string;
    END IF;
  END LOOP;

  return l_approver_list_string;

END format_ame_approver_list;


/*
  Converts the specified PON_AWARD_APPROVAL_PKG api_insertion code to a corresponding ame_util api_insertion code.
*/
FUNCTION convert_to_ame_api_insertion(p_pon_api_insertion IN NUMBER) RETURN VARCHAR2 IS
BEGIN
  IF p_pon_api_insertion = API_AUTHORITY_INSERTION THEN
    RETURN ame_util.apiAuthorityInsertion;
  ELSIF p_pon_api_insertion = API_INSERTION THEN
    RETURN ame_util.apiInsertion;
  ELSIF p_pon_api_insertion = OAM_GENERATED THEN
    RETURN ame_util.oamGenerated;
  ELSE
    RETURN NULL;
  END IF;
END convert_to_ame_api_insertion;

/*
  Converts the specified ame_util api_insertion code to a corresponding PON_AWARD_APPROVAL_PKG api_insertion code.
*/
FUNCTION convert_to_pon_api_insertion(p_ame_api_insertion IN VARCHAR2) RETURN NUMBER IS
BEGIN
  IF p_ame_api_insertion = ame_util.apiAuthorityInsertion THEN
    RETURN API_AUTHORITY_INSERTION;
  ELSIF p_ame_api_insertion = ame_util.apiInsertion THEN
    RETURN API_INSERTION;
  ELSIF p_ame_api_insertion = ame_util.oamGenerated THEN
    RETURN OAM_GENERATED;
  ELSE
    RETURN NULL;
  END IF;
END convert_to_pon_api_insertion;

/*
  Converts the specified PON_AWARD_APPROVAL_PKG authority code to a corresponding ame_util authority code.
*/
FUNCTION convert_to_ame_authority(p_pon_authority IN NUMBER) RETURN VARCHAR2 IS
BEGIN
  IF p_pon_authority = PRE_APPROVER THEN
    RETURN ame_util.preApprover;
  ELSIF p_pon_authority = AUTHORITY_APPROVER THEN
    RETURN ame_util.authorityApprover;
  ELSIF p_pon_authority = POST_APPROVER THEN
    RETURN ame_util.postApprover;
  ELSE
    RETURN NULL;
  END IF;
END convert_to_ame_authority;

/*
  Converts the specified ame_util authority code to a corresponding PON_AWARD_APPROVAL_PKG authority code.
*/
FUNCTION convert_to_pon_authority(p_ame_authority IN VARCHAR2) RETURN NUMBER IS
BEGIN
  IF p_ame_authority = ame_util.preApprover THEN
    RETURN PRE_APPROVER;
  ELSIF p_ame_authority = ame_util.authorityApprover THEN
    RETURN AUTHORITY_APPROVER;
  ELSIF p_ame_authority = ame_util.postApprover THEN
    RETURN POST_APPROVER;
  ELSE
    RETURN NULL;
  END IF;
END convert_to_pon_authority;

/*
  Converts the specified PON_AWARD_APPROVAL_PKG approval_status code to a corresponding ame_util approval_status code.
*/
FUNCTION convert_to_ame_approval_status(p_pon_approval_status IN NUMBER) RETURN VARCHAR2 IS
BEGIN
  IF p_pon_approval_status = APPROVE_AND_FORWARD_STATUS THEN
    RETURN ame_util.approveAndForwardStatus;
  ELSIF p_pon_approval_status = APPROVED_STATUS THEN
    RETURN ame_util.approvedStatus;
  ELSIF p_pon_approval_status = CLEAR_EXCEPTIONS_STATUS THEN
    RETURN ame_util.clearExceptionsStatus;
  ELSIF p_pon_approval_status = EXCEPTION_STATUS THEN
    RETURN ame_util.exceptionStatus;
  ELSIF p_pon_approval_status = FORWARD_STATUS THEN
    RETURN ame_util.forwardStatus;
  ELSIF p_pon_approval_status = NO_RESPONSE_STATUS THEN
    RETURN ame_util.noResponseStatus;
/*
  ELSIF p_pon_approval_status = NOTIFIED_STATUS THEN
    RETURN ame_util.notifiedStatus;
*/
  ELSIF p_pon_approval_status = REJECT_STATUS THEN
    RETURN ame_util.rejectStatus;
/*
  ELSIF p_pon_approval_status = REPEATED_STATUS THEN
    RETURN ame_util.repeatedStatus;
  ELSIF p_pon_approval_status = SUPPRESSED_STATUS THEN
    RETURN ame_util.suppressedStatus;
*/
  ELSIF p_pon_approval_status = NULL_STATUS THEN
    RETURN ame_util.nullStatus;
  ELSE
    RETURN NULL;
  END IF;
END convert_to_ame_approval_status;

/*
  Converts the specified ame_util approval_status code to a corresponding PON_AWARD_APPROVAL_PKG approval_status code.
*/
FUNCTION convert_to_pon_approval_status(p_ame_approval_status IN VARCHAR2) RETURN NUMBER IS
BEGIN
  IF p_ame_approval_status = ame_util.approveAndForwardStatus THEN
    RETURN APPROVE_AND_FORWARD_STATUS;
  ELSIF p_ame_approval_status = ame_util.approvedStatus THEN
    RETURN APPROVED_STATUS;
  ELSIF p_ame_approval_status = ame_util.clearExceptionsStatus THEN
    RETURN CLEAR_EXCEPTIONS_STATUS;
  ELSIF p_ame_approval_status = ame_util.exceptionStatus THEN
    RETURN EXCEPTION_STATUS;
  ELSIF p_ame_approval_status = ame_util.forwardStatus THEN
    RETURN FORWARD_STATUS;
  ELSIF p_ame_approval_status = ame_util.noResponseStatus THEN
    RETURN NO_RESPONSE_STATUS;
/*
  ELSIF p_ame_approval_status = ame_util.notifiedStatus THEN
    RETURN NOTIFIED_STATUS;
*/
  ELSIF p_ame_approval_status = ame_util.rejectStatus THEN
    RETURN REJECT_STATUS;
/*
  ELSIF p_ame_approval_status = ame_util.repeatedStatus THEN
    RETURN REPEATED_STATUS;
  ELSIF p_ame_approval_status = ame_util.suppressedStatus THEN
    RETURN SUPPRESSED_STATUS;
*/
  ELSIF p_ame_approval_status IS NULL THEN
    RETURN NULL_STATUS;
  ELSE
    RETURN NULL;
  END IF;
END convert_to_pon_approval_status;

/*
  Parses a string specifying a number.  If the string is null, null is returned.
*/
FUNCTION parse_number_field(p_string VARCHAR2) RETURN NUMBER IS
BEGIN
  IF p_string IS NULL THEN
    RETURN NULL;
  ELSE
    RETURN TO_NUMBER(p_string);
  END IF;
END parse_number_field;

/*
  Retrieves the display name for the specified user.
*/
FUNCTION get_display_name_for_user(p_user_id IN NUMBER) RETURN VARCHAR2 IS
  l_display_name VARCHAR2(240);
BEGIN

  BEGIN
    -- if the full name is null, use the user name
    SELECT NVL(persons.full_name, users.user_name)
    INTO l_display_name
    FROM
      per_all_people_f persons,
      fnd_user users
    WHERE
          users.employee_id = persons.person_id(+)
      AND users.user_id = p_user_id
      AND TRUNC(sysdate) between persons.effective_start_date and persons.effective_end_date;
  EXCEPTION
    WHEN no_data_found OR too_many_rows THEN
      NULL;
  END;

  RETURN l_display_name;

END get_display_name_for_user;

/*
  Retrieves the display name for the specified user.
*/
FUNCTION get_display_name_for_user(p_user_name IN VARCHAR2) RETURN VARCHAR2 IS
  l_display_name VARCHAR2(240);
BEGIN

  BEGIN
    -- if the full name is null, use the user name
    SELECT NVL(persons.full_name, users.user_name)
    INTO l_display_name
    FROM
      per_all_people_f persons,
      fnd_user users
    WHERE
          users.employee_id = persons.person_id(+)
      AND users.user_name = p_user_name
      AND TRUNC(sysdate) between persons.effective_start_date and persons.effective_end_date;
  EXCEPTION
    WHEN no_data_found OR too_many_rows THEN
      NULL;
  END;

  RETURN l_display_name;

END get_display_name_for_user;

/*
  Retrieves the display name for the specified person.
*/
FUNCTION get_display_name_for_person(p_person_id IN NUMBER) RETURN VARCHAR2 IS
  l_display_name VARCHAR2(240);
BEGIN

  BEGIN
    SELECT full_name
    INTO l_display_name
    FROM per_all_people_f
    WHERE person_id = p_person_id;
  EXCEPTION
    WHEN no_data_found OR too_many_rows THEN
      NULL;
  END;

  RETURN l_display_name;

END get_display_name_for_person;

/*
  Retrieves employee information for the specified user.
*/
PROCEDURE get_employee_info_for_user(p_user_id IN NUMBER, p_employee OUT NOCOPY employeeRecord) IS
BEGIN

  p_employee := nullEmployeeRecord;

  SELECT
    users.user_id,
    users.user_name,
    --emp.person_id
    users.employee_id
  INTO
    p_employee.user_id,
    p_employee.user_name,
    p_employee.person_id
  FROM
    --pon_employees_current_v emp,
    fnd_user users
  WHERE
        --emp.person_id = users.employee_id
    users.user_id = p_user_id
    AND users.start_date <= SYSDATE
    AND NVL(users.end_date, SYSDATE) >= SYSDATE;

EXCEPTION
  WHEN no_data_found OR too_many_rows THEN
    NULL;
END get_employee_info_for_user;

/*
  Retrieves employee information for the specified user.
*/
PROCEDURE get_employee_info_for_user(p_user_name IN VARCHAR2, p_employee OUT NOCOPY employeeRecord) IS
BEGIN

  p_employee := nullEmployeeRecord;

  SELECT
    users.user_id,
    users.user_name,
    --emp.person_id
    users.employee_id
  INTO
    p_employee.user_id,
    p_employee.user_name,
    p_employee.person_id
  FROM
    --pon_employees_current_v emp,
    fnd_user users
  WHERE
        --emp.person_id = users.employee_id
    users.user_name = p_user_name
    AND users.start_date <= SYSDATE
    AND NVL(users.end_date, SYSDATE) >= SYSDATE;

EXCEPTION
  WHEN no_data_found OR too_many_rows THEN
    NULL;
END get_employee_info_for_user;

/*
  Retrieves employee information for the specified person.
*/
PROCEDURE get_employee_info_for_person(p_person_id IN NUMBER, p_employee OUT NOCOPY employeeRecord) IS
BEGIN

  p_employee := nullEmployeeRecord;

  SELECT
    users.user_id,
    users.user_name,
    --emp.person_id
    users.employee_id
  INTO
    p_employee.user_id,
    p_employee.user_name,
    p_employee.person_id
  FROM
    --pon_employees_current_v emp,
    fnd_user users
  WHERE
        --emp.person_id = users.employee_id
    users.employee_id = p_person_id
    AND users.start_date <= SYSDATE
    AND NVL(users.end_date, SYSDATE) >= SYSDATE
    AND rownum = 1;

EXCEPTION
  WHEN no_data_found OR too_many_rows THEN
    p_employee.user_id := NULL;
    p_employee.user_name := NULL;
    p_employee.person_id := NULL;
END get_employee_info_for_person;

/*
  Removes the 'ORA<p_error_code>:' prefix in p_error_message_in if one exists.  Otherwise, does nothing.

  NOTE: this procedure works as long as p_error_code is negative.
*/
PROCEDURE trim_error_code(p_error_code         IN NUMBER,
                          p_error_message_in   IN VARCHAR2,
                          p_error_message_out  OUT NOCOPY VARCHAR2) IS
BEGIN

  IF INSTR(p_error_message_in, 'ORA' || p_error_code || ':') = 1 THEN
    p_error_message_out := LTRIM(SUBSTR(p_error_message_in, LENGTH('ORA' || p_error_code || ':') + 1));
  ELSE
    p_error_message_out := p_error_message_in;
  END IF;

END trim_error_code;

/***********************************
  DEBUGGING PROCEDURES AND FUNCTIONS
************************************/

/*
  Logs a string for a module using the Logging Framework.

  The logging level used is FND_LOG.LEVEL_STATEMENT.
*/
PROCEDURE log_string(p_module  IN VARCHAR2,
                     p_string  IN VARCHAR2) IS
BEGIN

  log_string(FND_LOG.LEVEL_STATEMENT, FND_LOG.G_CURRENT_RUNTIME_LEVEL, p_module, p_string);

END log_string;

/*
  Logs a string for a module using the Logging Framework.
*/
PROCEDURE log_string(p_level          IN NUMBER,
                     p_current_level  IN NUMBER,
                     p_module         IN VARCHAR2,
                     p_string         IN VARCHAR2) IS
BEGIN

  IF p_level >= p_current_level THEN
    FND_LOG.string(p_level, p_module, p_string);
  END IF;

END log_string;


/*
  Returns a string representation of an ame_util.insertionsTable.
*/
FUNCTION get_insertion_list_string(p_insertion_list IN ame_util.insertionsTable2) RETURN VARCHAR2 IS
  l_insertion_list_string VARCHAR2(4000);
BEGIN

  FOR i IN 1 .. p_insertion_list.COUNT LOOP

    l_insertion_list_string :=
      l_insertion_list_string ||
      i || ' (' ||
      get_api_insertion_string(p_insertion_list(i).api_insertion) || ', ' ||
      get_authority_string(p_insertion_list(i).authority) || ', ' ||
      get_order_type_string(p_insertion_list(i).order_type) || ', ' ||
      get_parameter_string(p_insertion_list(i).parameter) || ')';

    IF i < p_insertion_list.COUNT THEN
      l_insertion_list_string := l_insertion_list_string || fnd_global.newline;
    END IF;

  END LOOP;

  RETURN l_insertion_list_string;

END get_insertion_list_string;


FUNCTION get_insertion_string(p_approver  IN ame_util.approverRecord2, p_order IN ame_util.insertionRecord2) RETURN VARCHAR2 IS
BEGIN

  RETURN format_ame_approver(p_approver) || ' ' || '(' || get_order_type_string(p_order.order_type) || ', ' || get_parameter_string(p_order.parameter) || ')';

END get_insertion_string;

/*
  Returns a string representation of the value of an ame_util.approverRecord's api_insertion field.
*/
FUNCTION get_api_insertion_string(p_api_insertion IN VARCHAR2) RETURN VARCHAR2 IS
BEGIN

  IF p_api_insertion = ame_util.oamGenerated THEN
    RETURN 'oamGenerated';
  ELSIF p_api_insertion = ame_util.apiAuthorityInsertion THEN
    RETURN 'apiAuthorityInsertion';
  ELSIF p_api_insertion = ame_util.apiInsertion THEN
    RETURN 'apiInsertion';
  ELSE
    RETURN NULL;
  END IF;

END get_api_insertion_string;

/*
  Returns a string representation of the value of an ame_util.approverRecord's authority field.
*/
FUNCTION get_authority_string(p_authority IN VARCHAR2) RETURN VARCHAR2 IS
BEGIN

  IF p_authority = ame_util.preApprover THEN
    RETURN 'preApprover';
  ELSIF p_authority = ame_util.authorityApprover THEN
    RETURN 'authorityApprover';
  ELSIF p_authority = ame_util.postApprover THEN
    RETURN 'postApprover';
  ELSE
    RETURN NULL;
  END IF;

END get_authority_string;

/*
  Returns a string representation of the value of an ame_util.approverRecord's approval_status field.
*/
FUNCTION get_approval_status_string(p_approval_status IN VARCHAR2) RETURN VARCHAR2 IS
BEGIN

  IF p_approval_status = ame_util.approveAndForwardStatus THEN
    RETURN 'approveAndForwardStatus';
  ELSIF p_approval_status = ame_util.approvedStatus THEN
    RETURN 'approvedStatus';
  ELSIF p_approval_status = ame_util.clearExceptionsStatus THEN
    RETURN 'clearExceptionsStatus';
  ELSIF p_approval_status = ame_util.exceptionStatus THEN
    RETURN 'exceptionStatus';
  ELSIF p_approval_status = ame_util.forwardStatus THEN
    RETURN 'forwardStatus';
  ELSIF p_approval_status = ame_util.noResponseStatus THEN
    RETURN 'noResponseStatus';
/*
  ELSIF p_approval_status = ame_util.notifiedStatus THEN
    RETURN 'notifiedStatus';
*/
  ELSIF p_approval_status = ame_util.rejectStatus THEN
    RETURN 'rejectStatus';
/*
  ELSIF p_approval_status = ame_util.repeatedStatus THEN
    RETURN 'repeatedStatus';
  ELSIF p_approval_status = ame_util.suppressedStatus THEN
    RETURN 'suppressedStatus';
*/
  ELSIF p_approval_status IS NULL THEN
    RETURN 'nullStatus';
  ELSE
    RETURN p_approval_status;
  END IF;

END get_approval_status_string;

/*
  Returns a string representation of the value of an ame_util.orderRecord's or ame_util.insertionRecord's order_type field.
*/
FUNCTION get_order_type_string(p_order_type IN VARCHAR2) RETURN VARCHAR2 IS
BEGIN

  IF p_order_type = ame_util.absoluteOrder THEN
    RETURN 'absoluteOrder';
  ELSIF p_order_type = ame_util.afterApprover THEN
    RETURN 'afterApprover';
  ELSIF p_order_type = ame_util.beforeApprover THEN
    RETURN 'beforeApprover';
  ELSIF p_order_type = ame_util.firstAuthority THEN
    RETURN 'firstAuthority';
  ELSIF p_order_type = ame_util.firstPostApprover THEN
    RETURN 'firstPostApprover';
  ELSIF p_order_type = ame_util.firstPreApprover THEN
    RETURN 'firstPreApprover';
  ELSIF p_order_type = ame_util.lastPostApprover THEN
    RETURN 'lastPostApprover';
  ELSIF p_order_type = ame_util.lastPreApprover THEN
    RETURN 'lastPreApprover';
  ELSIF p_order_type IS NULL THEN
    RETURN 'nullOrderType';
  ELSE
    RETURN p_order_type;
  END IF;

END get_order_type_string;

/*
  Returns a string representation of the value of an ame_util.orderRecord's or ame_util.insertionRecord's parameter field.
*/
FUNCTION get_parameter_string(p_parameter IN VARCHAR2) RETURN VARCHAR2 IS
BEGIN

  IF p_parameter IS NOT NULL THEN
    RETURN p_parameter;
  ELSE
    RETURN 'nullParameter';
  END IF;

END get_parameter_string;

/*
  Makes an approval decision on a award on behalf of the specified user.
*/
PROCEDURE user_respond(p_auction_header_id    IN NUMBER,
                       p_user_name            IN VARCHAR2,
                       p_decision             IN VARCHAR2,
                       p_forwardee_user_name  IN VARCHAR2) IS
  l_result VARCHAR2(2000);
BEGIN

  make_approval_decision(p_auction_header_id, p_user_name, p_decision, NULL, p_forwardee_user_name, l_result);

  IF l_result IS NOT NULL THEN
    raise_application_error(-20001, l_result);
  END IF;

END user_respond;

/*
  Makes an APPROVE approval decision on a award on behalf of the specified user.
*/
PROCEDURE user_approve(p_auction_header_id  IN NUMBER,
                       p_user_name          IN VARCHAR2) IS
BEGIN

  user_respond(p_auction_header_id, p_user_name, 'APPROVE', NULL);

END user_approve;

/*
  Makes a REJECT approval decision on a award on behalf of the specified user.
*/
PROCEDURE user_reject(p_auction_header_id  IN NUMBER,
                      p_user_name          IN VARCHAR2) IS
BEGIN

  user_respond(p_auction_header_id, p_user_name, 'REJECT', NULL);

END user_reject;

/*
  Makes a FORWARD approval decision on a award on behalf of the specified user.
*/
PROCEDURE user_forward(p_auction_header_id    IN NUMBER,
                       p_user_name            IN VARCHAR2,
                       p_forwardee_user_name  IN VARCHAR2) IS
BEGIN

  user_respond(p_auction_header_id, p_user_name, 'FORWARD', p_forwardee_user_name);

END user_forward;

/*
  Makes an APPROVE_AND_FORWARD approval decision on a award on behalf of the specified user.
*/
PROCEDURE user_approve_and_forward(p_auction_header_id    IN NUMBER,
                                   p_user_name            IN VARCHAR2,
                                   p_forwardee_user_name  IN VARCHAR2) IS
BEGIN

  user_respond(p_auction_header_id, p_user_name, 'APPROVE_AND_FORWARD', p_forwardee_user_name);

END user_approve_and_forward;


FUNCTION getAMEFieldDelimiter return VARCHAR2 as
BEGIN
      --RETURN(fnd_global.local_chr(ascii_chr => 11));
      RETURN(fnd_global.local_chr(ascii_chr => 10));
END getAMEFieldDelimiter;

FUNCTION getAMERecordDelimiter return VARCHAR2 as
BEGIN
      --RETURN(fnd_global.local_chr(ascii_chr => 12));
      RETURN(fnd_global.local_chr(ascii_chr => 13));
END getAMERecordDelimiter;

END PON_AWARD_APPROVAL_PKG;

/
