--------------------------------------------------------
--  DDL for Package PO_DOCUMENT_ACTION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_DOCUMENT_ACTION_PVT" AUTHID CURRENT_USER AS
-- $Header: POXVDACS.pls 120.1.12010000.4 2012/11/13 01:19:58 rajarang ship $

/*
 * Document Actions
 * One note: it is best not to call a PO_DOCUMENT_ACTION_PVT method
 * from within the code flow of another PO_DOCUMENT_ACTION_PVT method.
 * These actions use a common switchboard, do_action(), as well as some
 * common error handling (via pl/sql package varaible) which could
 * conflict.
 * Exception: find_forward_to_id, which calls verify_authority
 * The find_forward_to_id does not use the switchboard; it is a
 * complicated wrapper around many calls to verify_authority.
 */

-- Global Constants


-- Previously doc manager actions
g_doc_action_APPROVE CONSTANT VARCHAR2(30)
   := 'APPROVE';
g_doc_action_REJECT CONSTANT VARCHAR2(30)
   := 'REJECT';
g_doc_action_FORWARD CONSTANT VARCHAR2(30)
   := 'FORWARD';
g_doc_action_CHECK_APPROVE CONSTANT VARCHAR2(30)
   := 'DOCUMENT_STATUS_CHECK_APPROVE';
g_doc_action_CHECK_REJECT CONSTANT VARCHAR2(30)
   := 'DOCUMENT_STATUS_CHECK_APPROVE';
g_doc_action_CHECK_AUTHORITY CONSTANT VARCHAR2(30)
   := 'VERIFY_AUTHORITY_CHECK';
g_doc_action_UPDATE_CLOSE_AUTO VARCHAR2(30)
   := 'UPDATE_CLOSE_STATE';


-- Previously User exit actions
g_doc_action_RETURN CONSTANT VARCHAR2(30)
   := 'RETURN';
g_doc_action_FREEZE CONSTANT VARCHAR2(30)
   := 'FREEZE';
g_doc_action_UNFREEZE CONSTANT VARCHAR2(30)
   := 'UNFREEZE';
g_doc_action_HOLD CONSTANT VARCHAR2(30)
   := 'HOLD';
g_doc_action_RELEASE_HOLD CONSTANT VARCHAR2(30)
   := 'RELEASE HOLD';
g_doc_action_OPEN CONSTANT VARCHAR2(30)
   := 'OPEN';
g_doc_action_CLOSE CONSTANT VARCHAR2(30)
   := 'CLOSE';
g_doc_action_CLOSE_RCV CONSTANT VARCHAR2(30)
   := 'RECEIVE CLOSE';
g_doc_action_OPEN_RCV CONSTANT VARCHAR2(30)
   := 'RECEIVE OPEN';
g_doc_action_CLOSE_INV CONSTANT VARCHAR2(30)
   := 'INVOICE CLOSE';
g_doc_action_OPEN_INV CONSTANT VARCHAR2(30)
   := 'INVOICE OPEN';
g_doc_action_FINALLY_CLOSE CONSTANT VARCHAR2(30)
   := 'FINALLY CLOSE';


-- Not yet converted
g_doc_action_CANCEL CONSTANT VARCHAR2(30)
   := 'CANCEL';


-- Possibly Deprecated actions - use PO_DOCUMENT_FUNDS_PVT instead?
g_doc_action_RESERVE CONSTANT VARCHAR2(30)
   := 'RESERVE';
g_doc_action_UNRESERVE CONSTANT VARCHAR2(30)
   := 'UNRESERVE';
g_doc_action_APPRV_RESERVE CONSTANT VARCHAR2(30)
   := 'APPROVE AND RESERVE';
g_doc_action_CHECK_FUNDS CONSTANT VARCHAR2(30)
   := 'CHECK FUNDS';

-- Intentionally Deprecated actions
g_doc_action_APPROVE_DOC CONSTANT VARCHAR2(30)
   := 'APPROVE_DOCUMENT';
g_doc_action_FORWARD_DOC CONSTANT VARCHAR2(30)
   := 'FORWARD_DOCUMENT';
g_doc_action_REJECT_DOC CONSTANT VARCHAR2(30)
   := 'REJECT_DOCUMENT';



-- document authorization statuses
g_doc_status_APPROVED CONSTANT VARCHAR2(30)
   := 'APPROVED';
g_doc_status_REJECTED CONSTANT VARCHAR2(30)
   := 'REJECTED';
g_doc_status_PREAPPROVED CONSTANT VARCHAR2(30)
   := 'PRE-APPROVED';
g_doc_status_INPROCESS CONSTANT VARCHAR2(30)
   := 'IN PROCESS';
g_doc_status_INCOMPLETE CONSTANT VARCHAR2(30)
   := 'INCOMPLETE';
g_doc_status_REAPPROVAL CONSTANT VARCHAR2(30)
   := 'REQUIRES REAPPROVAL';
g_doc_status_RETURNED CONSTANT VARCHAR2(30)
   := 'RETURNED';
g_doc_status_SENT CONSTANT VARCHAR2(30)
   := 'SENT';

-- document closed statuses
g_doc_closed_sts_OPEN CONSTANT VARCHAR2(30)
   := 'OPEN';
g_doc_closed_sts_CLOSED CONSTANT VARCHAR2(30)
   := 'CLOSED';
g_doc_closed_sts_CLOSED_INV CONSTANT VARCHAR2(30)
   := 'CLOSED FOR INVOICE';
g_doc_closed_sts_CLOSED_RCV CONSTANT VARCHAR2(30)
   := 'CLOSED FOR RECEIVING';
g_doc_closed_sts_FIN_CLOSED CONSTANT VARCHAR2(30)
   := 'FINALLY CLOSED';



-- Global Types

/* TYPE: DOC_ACTION_CALL_REC_TYPE
 *
 * Note: for a given action, only a few of the following
 * container variables are actually used.
 *
 * Descriptions and examples:
 *
 * Used primarily as IN values:
 *
 * The following are used by most actions:
 * action: one of g_doc_action_XXXX, e.g. g_doc_action_APPROVE
 * lock_document: pass as true if you the document should be locked
 *                before handling the logic for the action
 * document_type: 'PO', 'PA', 'REQUISITION', or 'RELEASE'
 * document_subtype: 'STANDARD', 'BLANKET', 'CONTRACT', 'SCHEDULED', etc.
 * document_id: po_header_id, requisition_header_id, or po_release_id
 * note: usually used for action history purposes
 *
 * The following are primarily used by workflow actions (approve, reject, etc.)
 * employee_id: ID of the employee taking the action
 * new_document_status: one of g_doc_status_XXXX, e.g. g_doc_status_APPROVED
 *                      needed by some actions so that they know what
 *                      status to set the document to on completion
 * approval_path_id: usually used for discovering next approver
 * forward_to_id: ID of an employee to forward the document to
 *
 * The following are primarily used by closed status related actions:
 * line_id/shipment_id: needed for some actions
 * calling_mode: either 'PO', 'RCV', or 'AP'; needed for close actions.  'AP'
 *               code flow is slightly different for certain actions.
 * called_from_conc: TRUE means we are being called from within a
 *                   concurrent program.  Used only in the close
 *                   actions, to get the right login_id.  Should be false
 *                   for all other actions.
 * action_date: Used in invoice open and finally close actions to
 *              determine gl_override_date for encumbrance calls.
 * origin_doc_id : Needed for JFMIP for final close and invoice open actions.
 *                 For those cases, this is the invoice id.  Should be NULL
 *                 if not coming from AP.
 * use_gl_date : Needed only for encumbrance purposes, for final close
 *               and invoice open.  'Y' or 'N'
 * offline_code: does not seem to be used; often passed in as NULL
 *
 *
 * Used primarily as OUT values:
 *
 * return_code: used by certain actions to indicate functional success or
 *              error.  Often, a null value means unconditional success.
 * return_status: 'S' or 'U'.  A 'U' indicates an unexpected technical
 *                error/exception occurred.  Can also be 'E', but rarely used
 *                in that capacity, as the return_code variable is often used
 *                instead to denote functional errors.
 * error_msg: concatenated string representing a stack of error messages
 *            often only relevant if return_status is 'U'
 * functional_error: string representing a functional error.  Ofen
 *                   contains a translated error string from fnd.  Should
 *                   usually be used only when return_status is 'S'
 * online_report_id: stores ID of online report with more error info.
 *                   Used by certain actions only.
 *
 */
TYPE DOC_ACTION_CALL_REC_TYPE IS RECORD
 (
    action                         VARCHAR2(30),
    lock_document                  BOOLEAN,
    document_type                  VARCHAR2(25),
    document_subtype               VARCHAR2(25),
    document_id                    NUMBER,
    employee_id                    NUMBER,
    new_document_status            VARCHAR2(25),
    approval_path_id               NUMBER,
    forward_to_id                  NUMBER,
    note                           PO_ACTION_HISTORY.NOTE%TYPE,
    return_code                    VARCHAR2(25),
    return_status                  VARCHAR2(1),  -- replaces return_value
    error_msg                      VARCHAR2(2000),
    functional_error               VARCHAR2(2000),
    line_id                        NUMBER,
    shipment_id                    NUMBER,
    calling_mode                   VARCHAR2(4),
    called_from_conc               BOOLEAN,
    origin_doc_id                  NUMBER,
    action_date                    DATE,
    online_report_id               NUMBER,
    use_gl_date                    VARCHAR2(1),
    offline_code                   VARCHAR2(1)
 );


/* <Bug 14207546 :Cancel Refactoring Project >
 * TYPE: entity_dtl_rec_type
 *
 * Description:
 *
 * Used primarily as IN value For Cancel Action:
 *   doc_id            : Document Header Id of the entity being canceled
 *                       For document Type PO/PA, it will PO Header Id
 *                       For Docuemnt Type Release, it will be release id
 *   document_type      :Document Type PO/PA/Release
 *   document_subtype   :Document SubType:STANDARD/PLANNED/BLANKET/..
 *   entity_id          :Id of the entity being canceled, ex:
 *                        Po_hedaer_id if PO Header is canceled,
 *                        Line_Loctaion_id if PO shipment is canceled,
 *   entity_level       :Level at which cancel action is performed ex:
 *                       HEADER/LINE/LINE_LOCATION
 *  entity_action_date  :cancel action date
 *  process_entity_flag : This is used during the cancel action processing
 *  recreate_demand_flag :This is used during the cancel action processing
 *
 */


 TYPE entity_dtl_rec_type  IS RECORD(
      doc_id             number,
      document_type      VARCHAR2(25),
      document_subtype   VARCHAR2(25),
      entity_id          NUMBER,
      entity_level       VARCHAR2(25),
      entity_action_date  DATE ,
      process_entity_flag varchar2(1) :='Y',
      recreate_demand_flag varchar2(1) :='N'
 ) ;

 -- <Bug 14207546 :Cancel Refactoring Project >
TYPE  entity_dtl_rec_type_tbl IS TABLE OF  entity_dtl_rec_type;



/* <Bug 14207546 :Cancel Refactoring Project >
 * TYPE: DOC_ACTION_CALL_TBL_REC_TYPE
 *
 *
 * Descriptions and examples:
 *
 * Used primarily as IN value For Cancel Action:
 *
 *  entity_dtl_record_tbl
 *  reason
 *  action       :'CANCEL'
 *  action_date  : Used to get gl_override_date for encumbrance calls and
 *                 also to update the cancel_date/closed date on the document
 *  use_gl_date  : Needed only for encumbrance purposes 'Y' or 'N'
 *  cancel_reqs_flag
 *  revert_pending_chg_flag
 *  note_to_vendor  :usually used for action history purposes
 *  launch_approval_flag
 *  communication_method_option
 *  communication_method_value
 *  caller
 *  commit_flag
 * Used primarily as OUT values:
 *
 *  return_code: used by certain actions to indicate functional success or
 *              error.  Often, a null value means unconditional success.
 *  return_status: 'S' or 'U'.  A 'U' indicates an unexpected technical
 *                error/exception occurred.  Can also be 'E', but rarely used
 *                in that capacity, as the return_code variable is often used
 *                instead to denote functional errors.
 *  online_report_id: stores ID of online report with more error info.
 *                   Used by certain actions only.

 */


TYPE DOC_ACTION_CALL_TBL_REC_TYPE IS RECORD
 (
         entity_dtl_record_tbl        entity_dtl_rec_type_tbl
      ,  reason                       VARCHAR2(240) --Bug 15836292
      ,  action                       VARCHAR2(30)
      ,  action_date                  DATE
      ,  use_gl_date                  VARCHAR2(30)
      ,  cancel_reqs_flag             VARCHAR2(1)
      ,  revert_pending_chg_flag      VARCHAR2(1)
      ,  note_to_vendor               VARCHAR2(1000)
      ,  launch_approval_flag         VARCHAR2(1)
      ,  communication_method_option  VARCHAR2(30)
      ,  communication_method_value   VARCHAR2(30)
      ,  caller                       VARCHAR2(30)
      ,  commit_flag                  VARCHAR2(1)
      ,  online_report_id             NUMBER
      ,  return_status                VARCHAR2(30)
      ,  return_code                    VARCHAR2(30)
 );


-- Methods

PROCEDURE do_action(
   p_action_ctl_rec  IN OUT NOCOPY  PO_DOCUMENT_ACTION_PVT.doc_action_call_rec_type
);

PROCEDURE do_approve(
   p_document_id        IN           VARCHAR2
,  p_document_type      IN           VARCHAR2
,  p_document_subtype   IN           VARCHAR2
,  p_note               IN           VARCHAR2
,  p_approval_path_id   IN           NUMBER
,  x_return_status      OUT  NOCOPY  VARCHAR2
,  x_exception_msg      OUT  NOCOPY  VARCHAR2
);

PROCEDURE do_reject(
   p_document_id        IN           VARCHAR2
,  p_document_type      IN           VARCHAR2
,  p_document_subtype   IN           VARCHAR2
,  p_note               IN           VARCHAR2
,  p_approval_path_id   IN           NUMBER
,  x_return_status      OUT  NOCOPY  VARCHAR2
,  x_return_code        OUT  NOCOPY  VARCHAR2
,  x_exception_msg      OUT  NOCOPY  VARCHAR2
,  x_online_report_id   OUT  NOCOPY  NUMBER
);


PROCEDURE do_forward(
   p_document_id        IN           VARCHAR2
,  p_document_type      IN           VARCHAR2
,  p_document_subtype   IN           VARCHAR2
,  p_new_doc_status     IN           VARCHAR2
,  p_note               IN           VARCHAR2
,  p_approval_path_id   IN           NUMBER
,  p_forward_to_id      IN           NUMBER
,  x_return_status      OUT  NOCOPY  VARCHAR2
,  x_exception_msg      OUT  NOCOPY  VARCHAR2
);

PROCEDURE do_return(
   p_document_id        IN           VARCHAR2
,  p_document_type      IN           VARCHAR2
,  p_document_subtype   IN           VARCHAR2
,  p_note               IN           VARCHAR2
,  p_approval_path_id   IN           NUMBER
,  x_return_status      OUT  NOCOPY  VARCHAR2
,  x_return_code        OUT  NOCOPY  VARCHAR2
,  x_exception_msg      OUT  NOCOPY  VARCHAR2
,  x_online_report_id   OUT  NOCOPY  NUMBER
);

PROCEDURE do_freeze(
   p_document_id        IN           VARCHAR2
,  p_document_type      IN           VARCHAR2
,  p_document_subtype   IN           VARCHAR2
,  p_reason             IN           VARCHAR2
,  x_return_status      OUT  NOCOPY  VARCHAR2
,  x_return_code        OUT  NOCOPY  VARCHAR2
,  x_exception_msg      OUT  NOCOPY  VARCHAR2
);

PROCEDURE do_unfreeze(
   p_document_id        IN           VARCHAR2
,  p_document_type      IN           VARCHAR2
,  p_document_subtype   IN           VARCHAR2
,  p_reason             IN           VARCHAR2
,  x_return_status      OUT  NOCOPY  VARCHAR2
,  x_return_code        OUT  NOCOPY  VARCHAR2
,  x_exception_msg      OUT  NOCOPY  VARCHAR2
);

PROCEDURE do_hold(
   p_document_id        IN           VARCHAR2
,  p_document_type      IN           VARCHAR2
,  p_document_subtype   IN           VARCHAR2
,  p_reason             IN           VARCHAR2
,  x_return_status      OUT  NOCOPY  VARCHAR2
,  x_return_code        OUT  NOCOPY  VARCHAR2
,  x_exception_msg      OUT  NOCOPY  VARCHAR2
);

PROCEDURE do_release_hold(
   p_document_id        IN           VARCHAR2
,  p_document_type      IN           VARCHAR2
,  p_document_subtype   IN           VARCHAR2
,  p_reason             IN           VARCHAR2
,  x_return_status      OUT  NOCOPY  VARCHAR2
,  x_return_code        OUT  NOCOPY  VARCHAR2
,  x_exception_msg      OUT  NOCOPY  VARCHAR2
);

PROCEDURE verify_authority(
   p_document_id        IN           VARCHAR2
,  p_document_type      IN           VARCHAR2
,  p_document_subtype   IN           VARCHAR2
,  p_employee_id        IN           VARCHAR2
,  x_return_status      OUT  NOCOPY  VARCHAR2
,  x_return_code        OUT  NOCOPY  VARCHAR2
,  x_exception_msg      OUT  NOCOPY  VARCHAR2
,  x_auth_failed_msg    OUT  NOCOPY  VARCHAR2
);

PROCEDURE check_doc_status_approve(
   p_document_id        IN           VARCHAR2
,  p_document_type      IN           VARCHAR2
,  p_document_subtype   IN           VARCHAR2
,  x_return_status      OUT  NOCOPY  VARCHAR2
,  x_return_code        OUT  NOCOPY  VARCHAR2
,  x_exception_msg      OUT  NOCOPY  VARCHAR2
);

PROCEDURE check_doc_status_reject(
   p_document_id        IN           VARCHAR2
,  p_document_type      IN           VARCHAR2
,  p_document_subtype   IN           VARCHAR2
,  x_return_status      OUT  NOCOPY  VARCHAR2
,  x_return_code        OUT  NOCOPY  VARCHAR2
,  x_exception_msg      OUT  NOCOPY  VARCHAR2
);

PROCEDURE find_forward_to_id(
   p_document_id        IN     NUMBER
,  p_document_type      IN     VARCHAR2
,  p_document_subtype   IN     VARCHAR2
,  p_employee_id        IN     NUMBER
,  p_approval_path_id   IN     NUMBER
,  x_return_status      OUT NOCOPY  VARCHAR2
,  x_forward_to_id      OUT NOCOPY  NUMBER
);

PROCEDURE auto_update_close_state(
   p_document_id       IN      NUMBER
,  p_document_type     IN      VARCHAR2
,  p_document_subtype  IN      VARCHAR2
,  p_line_id           IN      NUMBER    DEFAULT  NULL
,  p_shipment_id       IN      NUMBER    DEFAULT  NULL
,  p_calling_mode      IN      VARCHAR2  DEFAULT  'PO'
,  p_called_from_conc  IN      BOOLEAN   DEFAULT  FALSE
,  x_return_status     OUT NOCOPY  VARCHAR2
,  x_exception_msg     OUT NOCOPY  VARCHAR2
,  x_return_code       OUT NOCOPY  VARCHAR2
);

PROCEDURE do_manual_close(
   p_action            IN      VARCHAR2
,  p_document_id       IN      NUMBER
,  p_document_type     IN      VARCHAR2
,  p_document_subtype  IN      VARCHAR2
,  p_line_id           IN      NUMBER
,  p_shipment_id       IN      NUMBER
,  p_reason            IN      VARCHAR2
,  p_action_date       IN      DATE      DEFAULT  SYSDATE
,  p_calling_mode      IN      VARCHAR2  DEFAULT  'PO'
,  p_origin_doc_id     IN      NUMBER    DEFAULT  NULL
,  p_called_from_conc  IN      BOOLEAN   DEFAULT  FALSE
,  p_use_gl_date       IN      VARCHAR2  DEFAULT  'N'
,  x_return_status     OUT NOCOPY  VARCHAR2
,  x_exception_msg     OUT NOCOPY  VARCHAR2
,  x_return_code       OUT NOCOPY  VARCHAR2
,  x_online_report_id  OUT NOCOPY  NUMBER
);

--<Bug 14207546 :Cancel Refactoring Project >
PROCEDURE do_cancel(
  p_entity_dtl_rec                IN entity_dtl_rec_type_tbl
,  p_reason                       IN   VARCHAR2
,  p_action                       IN   VARCHAR2
,  p_action_date                  IN   DATE      DEFAULT  SYSDATE
,  p_use_gl_date                  IN   VARCHAR2  DEFAULT  'N'
,  p_cancel_reqs_flag             IN   VARCHAR2
,  p_note_to_vendor               IN   VARCHAR2  DEFAULT NULL
,  p_launch_approvals_flag        IN   VARCHAR2  DEFAULT  'N'
,  p_communication_method_option  IN   VARCHAR2  DEFAULT NULL
,  p_communication_method_value   IN   VARCHAR2  DEFAULT NULL
,  p_caller                       IN   VARCHAR2
,  p_commit                       IN   VARCHAR2  DEFAULT  'N'
,  p_revert_pending_chg_flag      IN   VARCHAR2  DEFAULT  'Y'
,  x_online_report_id             OUT  NOCOPY NUMBER
,  x_return_status                OUT  NOCOPY  VARCHAR2
,  x_exception_msg                OUT  NOCOPY  VARCHAR2
,  x_return_code                  OUT  NOCOPY  VARCHAR2
);







-- PO_DOCUMENT_ACTION_XXXX Shared Error Message Trace Handlers
-- These should not be called outside of DOCUMENT_ACTION code.
PROCEDURE get_error_message(
  x_error_message        OUT NOCOPY   VARCHAR2
);

PROCEDURE error_msg_append(
   p_subprogram_name     IN           VARCHAR2
,  p_position            IN           NUMBER
,  p_message_text        IN           VARCHAR2
);

PROCEDURE error_msg_append(
   p_subprogram_name     IN           VARCHAR2
,  p_position            IN           NUMBER
,  p_sqlcode             IN           NUMBER
,  p_sqlerrm             IN           VARCHAR2
);

-- <R12 BEGIN INVCONV>
PROCEDURE update_secondary_qty_cancelled (
   p_join_column         IN           VARCHAR2
,  p_entity_id           IN           NUMBER
);
-- <R12 END INVCONV>

END PO_DOCUMENT_ACTION_PVT;

/
