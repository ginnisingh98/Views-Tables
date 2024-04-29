--------------------------------------------------------
--  DDL for Package FUN_RECIPIENT_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_RECIPIENT_WF" AUTHID CURRENT_USER AS
/* $Header: FUN_RECI_WF_S.pls 120.9.12010000.1 2008/07/29 09:49:02 appldev ship $ */

    -- Raise when AP transfer has unknown failure.
    ap_transfer_failure EXCEPTION;



/*-----------------------------------------------------
 * PROCEDURE get_attr
 * ----------------------------------------------------
 * Get the attributes for the recipient WF.
 * ---------------------------------------------------*/

PROCEDURE get_attr (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2);


/*-----------------------------------------------------
 * PROCEDURE validate_trx
 * ----------------------------------------------------
 * Call the Transaction API to validate the trx.
 * ---------------------------------------------------*/

PROCEDURE validate_trx (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2);


/*-----------------------------------------------------
 * PROCEDURE delete_trx
 * ----------------------------------------------------
 * Delete the transaction from the recipient's DB.
 * ---------------------------------------------------*/

PROCEDURE delete_trx (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2);



/*-----------------------------------------------------
 * PROCEDURE is_gl_batch_mode
 * ----------------------------------------------------
 * Check whether GL transfer is in batch mode.
 * ---------------------------------------------------*/

PROCEDURE is_gl_batch_mode (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2);


/*-----------------------------------------------------
 * PROCEDURE check_invoice_reqd
 * ----------------------------------------------------
 * Check whether this transaction requires invoice.
 * ---------------------------------------------------*/

PROCEDURE check_invoice_reqd (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2);


/*-----------------------------------------------------
 * PROCEDURE check_approval_result
 * ----------------------------------------------------
 * Check status: APPROVED or REJECTED.
 * ---------------------------------------------------*/

PROCEDURE check_approval_result (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2);


/*-----------------------------------------------------
 * PROCEDURE is_manual_approval
 * ----------------------------------------------------
 * Check whether this transaction requires manual
 * approval.
 * ---------------------------------------------------*/

PROCEDURE is_manual_approval (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2);


/*-----------------------------------------------------
 * PROCEDURE abort_approval
 * ----------------------------------------------------
 * Abort the accounting and approval process.
 * ---------------------------------------------------*/

PROCEDURE abort_approval (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2);


/*-----------------------------------------------------
 * PROCEDURE generate_approval_doc
 * ----------------------------------------------------
 * Generate the approval document.
 * ---------------------------------------------------*/

PROCEDURE generate_approval_doc (
    document_id     IN number,
    display_type    IN varchar2,
    document        IN OUT NOCOPY varchar2,
    document_type   IN OUT NOCOPY varchar2);


/*-----------------------------------------------------
 * PROCEDURE is_same_instance
 * ----------------------------------------------------
 * Check whether the initiator and recipient are on the
 * same instance.
 * ---------------------------------------------------*/

PROCEDURE is_same_instance (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2);


/*-----------------------------------------------------
 * PROCEDURE get_contact
 * ----------------------------------------------------
 * Get the contact for this party.
 * ---------------------------------------------------*/

PROCEDURE get_contact (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2);


/*-----------------------------------------------------
 * PROCEDURE check_allow_reject
 * ----------------------------------------------------
 * Check whether this transaction requires manual
 * approval.
 * ---------------------------------------------------*/

PROCEDURE check_allow_reject (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2);


/*-----------------------------------------------------
 * PROCEDURE post_approval_ntf
 * ----------------------------------------------------
 * Check whether anyone has already approved or
 * or rejected the transaction.
 * ---------------------------------------------------*/

PROCEDURE post_approval_ntf (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2);


/*-----------------------------------------------------
 * PROCEDURE check_ap_setup
 * ----------------------------------------------------
 * Check that AP is setup correctly with supplier and
 * open period and all that.
 * ---------------------------------------------------*/

PROCEDURE check_ap_setup (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2);


/*-----------------------------------------------------
 * PROCEDURE transfer_to_ap
 * ----------------------------------------------------
 * Transfer to AP. Wrapper for
 * FUN_AP_TRANSFER.TRANSFER_SINGLE
 * ---------------------------------------------------*/

PROCEDURE transfer_to_ap (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2);


/*-----------------------------------------------------
 * PROCEDURE raise_error
 * ----------------------------------------------------
 * Raise the error event.
 * ---------------------------------------------------*/

PROCEDURE raise_error (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2);


/*-----------------------------------------------------
 * PROCEDURE raise_received
 * ----------------------------------------------------
 * Raise the received event.
 * ---------------------------------------------------*/

PROCEDURE raise_received (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2);


/*-----------------------------------------------------
 * PROCEDURE raise_reject
 * ----------------------------------------------------
 * Raise the reject event.
 * ---------------------------------------------------*/

PROCEDURE raise_reject (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2);


/*-----------------------------------------------------
 * PROCEDURE raise_approve
 * ----------------------------------------------------
 * Raise the approve event.
 * ---------------------------------------------------*/

PROCEDURE raise_approve (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2);


/*-----------------------------------------------------
 * PROCEDURE raise_gl_transfer
 * ----------------------------------------------------
 * Raise the transfer to gl event.
 * ---------------------------------------------------*/

PROCEDURE raise_gl_transfer (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2);


/*-----------------------------------------------------
 * PROCEDURE update_status_error
 * ----------------------------------------------------
 * Update status to error.
 * ---------------------------------------------------*/

/*PROCEDURE update_status_error (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2);
*/


/*-----------------------------------------------------
 * PROCEDURE update_status_rejected
 * ----------------------------------------------------
 * Update status to rejected.
 * ---------------------------------------------------*/

procedure update_status_rejected (
    itemtype    in varchar2,
    itemkey     in varchar2,
    actid       in number,
    funcmode    in varchar2,
    resultout   in OUT NOCOPY varchar2);


/*-----------------------------------------------------
 * PROCEDURE update_status_approved
 * ----------------------------------------------------
 * Update status to approved.
 * ---------------------------------------------------*/

procedure update_status_approved (
    itemtype    in varchar2,
    itemkey     in varchar2,
    actid       in number,
    funcmode    in varchar2,
    resultout   in OUT NOCOPY varchar2);

/*-----------------------------------------------------
 * PROCEDURE approve_ntf
 * ----------------------------------------------------
 * Approve notification process from UI.
 * ---------------------------------------------------*/

procedure approve_ntf (
    p_batch_id    in varchar2,
    p_trx_id      in varchar2,
    p_eventkey    in varchar2);


/*-----------------------------------------------------
 * PROCEDURE reject_ntf
 * ----------------------------------------------------
 * Reject notification process from UI.
 * ---------------------------------------------------*/

procedure reject_ntf (
    p_batch_id    in varchar2,
    p_trx_id      in varchar2,
    p_eventkey    in varchar2);

/*-----------------------------------------------------
 * PROCEDURE recipient_interco_acct
 * ----------------------------------------------------
 * Insert a default intercompany account for recipient
 * accounting to fun_dist_lines
 * ---------------------------------------------------*/

procedure recipient_interco_acct (
    itemtype    in varchar2,
    itemkey     in varchar2,
    actid       in number,
    funcmode    in varchar2,
    resultout   in OUT NOCOPY varchar2);


/*-----------------------------------------------------
 * PROCEDURE check_acct_dist
 * ----------------------------------------------------
 * Call transaction API to validate account distributions
 * ---------------------------------------------------*/

procedure check_acct_dist (
    itemtype    in varchar2,
    itemkey     in varchar2,
    actid       in number,
    funcmode    in varchar2,
    resultout   in OUT NOCOPY varchar2);


FUNCTION make_batch_rec (
    p_batch_id    IN number) RETURN fun_trx_pvt.batch_rec_type;

FUNCTION make_trx_rec (
    p_trx_id    IN number) RETURN fun_trx_pvt.trx_rec_type;

FUNCTION make_dist_lines_tbl (
    p_trx_id    IN number) RETURN fun_trx_pvt.dist_line_tbl_type;


/* Start of changes for AME Uptake, 3671923. Bidisha S, 08 Jun 2004 */
/* ---------------------------------------------------------------------------
Name      : check_ui_apprvl_action
Pre-reqs  : None.
Modifies  : None.
Function  : This function is called by the Recipient Main workflow
            to check if an approval action was taken in the wflow
            even before an approval notification was sent.
Parameters:
    IN    : itemtype  - Workflow Item Type
            itemkey   - Workflow Item Key
            actid     - Workflow Activity Id
            funcmode  - Workflow Function Mode
    OUT   : resultout - Result of the workflow function
Notes     : None.
Testing   : This function will be tested via workflow FUNRMAIN
------------------------------------------------------------------------------*/
PROCEDURE check_ui_apprvl_action(
    itemtype   IN  VARCHAR2,
    itemkey    IN  VARCHAR2,
    actid      IN  NUMBER,
    funcmode   IN  VARCHAR2,
    resultout  OUT NOCOPY VARCHAR2 ) ;

/* End of changes for AME Uptake, 3671923. Bidisha S, 07 Jun 2004 */

/* ---------------------------------------------------------------------------
Name      : generate_interco_acct
Pre-reqs  : None.
Modifies  : None.
Function  : This function is called by the update_status_approved
            in recipient workflow to generate the intercompany accouns
            before the status has been set to approved
Parameters:
    IN    : p_trx_id  -- fun_trx_headers.trx_id
    OUT   : x_status  -- FND_API.G_RET_STS_SUCCESS, ..UNEXP,..ERROR
            x_msg_count -- Number of messages
            x_msg_data  -- Message data
Notes     : None.
Testing   : This function will be tested via workflow FUNRMAIN
------------------------------------------------------------------------------*/
PROCEDURE generate_interco_acct (
    p_trx_id    IN NUMBER,
    x_status    IN OUT NOCOPY VARCHAR2,
    x_msg_count IN OUT NOCOPY NUMBER,
    x_msg_data  IN OUT NOCOPY VARCHAR2);


/* ---------------------------------------------------------------------------
Name      : get_default_sla_ccid
Pre-reqs  : None.
Modifies  : None.
Function  : This function is called by recipient_interco_acct
            to get the default ccid from SLA
Parameters:
    IN    : p_trx_id  -- fun_trx_headers.trx_id
    OUT   : x_status  -- FND_API.G_RET_STS_SUCCESS, ..UNEXP,..ERROR
            x_msg_count -- Number of messages
            x_msg_data  -- Message data
            x_ccid      -- CCID
Notes     : None.
Testing   : This function will be tested via workflow FUNRMAIN
------------------------------------------------------------------------------*/
PROCEDURE get_default_sla_ccid (
    p_trx_id    IN NUMBER,
    x_ccid      IN OUT NOCOPY NUMBER,
    x_status    IN OUT NOCOPY VARCHAR2,
    x_msg_count IN OUT NOCOPY NUMBER,
    x_msg_data  IN OUT NOCOPY VARCHAR2);

/*-----------------------------------------------------
 * PROCEDURE generate_acct_lines
 * ----------------------------------------------------
 * Generate Intercompany Accounting Lines
 * ---------------------------------------------------*/

PROCEDURE generate_acct_lines (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2);

/*-----------------------------------------------------
 * PROCEDURE create_wf_roles
 * ----------------------------------------------------
 * Generate wf roles. Bug No: 5897122.
 * ---------------------------------------------------*/
    procedure create_wf_roles (
    trx_id      IN VARCHAR2);
END;

/
