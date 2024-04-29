--------------------------------------------------------
--  DDL for Package FUN_WF_COMMON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_WF_COMMON" AUTHID CURRENT_USER AS
/* $Header: FUN_WF_COMMON_S.pls 120.4.12010000.2 2010/01/13 08:05:07 ychandra ship $ */


/*-----------------------------------------------------
 * FUNCTION generate_event_key
 * ----------------------------------------------------
 * Get the attributes for the recipient WF.
 * ---------------------------------------------------*/

FUNCTION generate_event_key (
    batch_id IN number,
    trx_id IN number) RETURN varchar2;


/*-----------------------------------------------------
 * FUNCTION concat_msg_stack
 * ----------------------------------------------------
y * Pop <p_depth> messages off the fnd_message stack and
 * concat them, separated by '\n'.
 *
 * If there are not enough messages in the stack, then
 * all the messages are popped.
 *
 * Returns null when there are no messages.
 * Delete the returned messages iff p_flush.
 * ---------------------------------------------------*/

FUNCTION concat_msg_stack (
    p_depth IN number,
    p_flush IN boolean DEFAULT TRUE) RETURN varchar2;


/*-----------------------------------------------------
 * PROCEDURE get_contact_role
 * ----------------------------------------------------
 * Get the contact for this party into an item attr
 * called CONTACT.
 * It assumes there is an item attr called PARTY_ID.
 * ---------------------------------------------------*/

FUNCTION get_contact_role (p_party_id IN number) RETURN varchar2;


/*-----------------------------------------------------
 * PROCEDURE is_arap_batch_mode
 * ----------------------------------------------------
 * Check whether AR/AP transfer is in batch mode.
 * ---------------------------------------------------*/

PROCEDURE is_arap_batch_mode (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2);


/*-----------------------------------------------------
 * PROCEDURE raise_complete
 * ----------------------------------------------------
 * Raise the complete event.
 * ---------------------------------------------------*/

PROCEDURE raise_complete (
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

PROCEDURE update_status_error (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2);


/*-----------------------------------------------------
 * PROCEDURE update_status_received
 * ----------------------------------------------------
 * Update status to received.
 * ---------------------------------------------------*/

PROCEDURE update_status_received (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2);


/*-----------------------------------------------------
 * PROCEDURE update_status_complete
 * ----------------------------------------------------
 * Update status to complete.
 * ---------------------------------------------------*/

PROCEDURE update_status_complete (
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2);


/*-----------------------------------------------------
 * PROCEDURE raise_wf_bus_event
 * ----------------------------------------------------
 * Raise workflow business event
 * ---------------------------------------------------*/

PROCEDURE raise_wf_bus_event (
    batch_id   IN number,
    trx_id     IN number default null,
    event_key  IN varchar2 default null,
    event_name IN varchar2 default null);

/* Start of changes for AME Uptake, 3671923. 07 Jun 2004 */

/* ---------------------------------------------------------------------------
Name      : get_ame_contacts
Pre-reqs  : None.
Modifies  : None.
Function  : This function is called by the various intercompany workflows
            to get the contact list to whom FYI notifications need to be
            sent out.
Parameters:
    IN    : itemtype  - Workflow Item Type
            itemkey   - Workflow Item Key
            actid     - Workflow Activity Id
            funcmode  - Workflow Function Mode
    OUT   : resultout - Result of the workflow function
Notes     : None.
Testing   : This function will be tested via workflows FUNARINT, FUNAPINT,
            FUNGLINT, FUNRTVAL, FUNIMAIN
------------------------------------------------------------------------------*/
PROCEDURE get_ame_contacts (itemtype   IN VARCHAR2,
                            itemkey    IN VARCHAR2,
                            actid      IN NUMBER,
                            funcmode   IN VARCHAR2,
                            resultout  OUT NOCOPY VARCHAR2 );

/* ---------------------------------------------------------------------------
Name      : get_ame_approvers
Pre-reqs  : None.
Modifies  : None.
Function  : This function is called by the Recipient Main workflow
            to get the contact list to whom request for approval notfications
            are sent out.
Parameters:
    IN    : itemtype  - Workflow Item Type
            itemkey   - Workflow Item Key
            actid     - Workflow Activity Id
            funcmode  - Workflow Function Mode
    OUT   : resultout - Result of the workflow function
Notes     : None.
Testing   : This function will be tested via workflow FUNRMAIN
------------------------------------------------------------------------------*/
PROCEDURE get_ame_approvers (itemtype   IN VARCHAR2,
                            itemkey    IN VARCHAR2,
                            actid      IN NUMBER,
                            funcmode   IN VARCHAR2,
                            resultout  OUT NOCOPY VARCHAR2 );

/* ---------------------------------------------------------------------------
Name      : get_ame_role_list
Pre-reqs  : None.
Modifies  : None.
Function  : This function is called by get_ame_contacts() and
            get_ame_approvers functions. It returns the name of the wflow
            role to whom FYI or approval notifications are sent out.
Parameters:
    IN    : p_transaction_id   - fun_trx_headers.trx_id
            p_fyi_notification - 'Y' or 'N' indicating if its FYI notification
            p_contact_type     - 'I'- Initiator or 'R'- Recipient
    OUT   : x_approvers_found  - 'Y'or 'N' indicating approvers found
            x_process_complete - 'Y'or 'N' indicating process complete
            x_role             - workflow role name
            x_ame_admin_user   - Ame Administrator
            x_error_message    - Error Message
Notes     : None.
Testing   : This function will be tested via the various intercompany
            workflows
------------------------------------------------------------------------------*/
PROCEDURE get_ame_role_list(itemkey            IN  VARCHAR2,
                            p_transaction_id   IN  NUMBER,
                            p_fyi_notification IN  VARCHAR2,
                            p_contact_type     IN  VARCHAR2,
                            x_approvers_found  OUT NOCOPY VARCHAR2,
                            x_process_complete OUT NOCOPY VARCHAR2,
                            x_role             OUT NOCOPY VARCHAR2,
                            x_return_status    OUT NOCOPY VARCHAR2,
                            x_ame_admin_user   OUT NOCOPY VARCHAR2,
                            x_error_message    OUT NOCOPY VARCHAR2) ;

/* ---------------------------------------------------------------------------
Name      : is_user_valid_approver
Pre-reqs  : None.
Modifies  : None.
Function  : This function is called from the Inbound Transaction UI
            to check if the user is a valid approver before enabling
            the 'Approve' and 'Reject' button.
            This function is also called from within workflow to decide
            whether or not the user the notification is going to be sent to
            is a valid user or not.
Parameters:
    IN    : p_transaction_id   - fun_trx_headers.trx_id
            p_user_id          - fnd_user.userid of the person navigating
                                 to the Inbound Trx UI.
            p_role_name        - wf_roles.name of the person the notification
                                 is being sent to or forwarded to.
            p_org_type         - 'I'-  Initating, R - Recipient
            p_mode             - UI - called from the UI
                                 WF - called from the workflow.

    OUT   : Varchat2 - 'Y' implies user has access, 'N' means no access
Notes     : None.
Testing   : This function will be tested via the inbound trx UI
------------------------------------------------------------------------------*/
FUNCTION is_user_valid_approver (p_transaction_id      IN VARCHAR2,
				 p_user_id             IN NUMBER,
                                 p_role_name           IN VARCHAR2,
                                 p_org_type            IN VARCHAR2,
                                 p_mode                IN VARCHAR2)
RETURN VARCHAR2 ;

/* End of changes for AME Uptake, 3671923. 07 Jun 2004 */



-- 6995183 START
/* ---------------------------------------------------------------------------
Name      : validate_approver
Pre-reqs  : None.
Modifies  : None.
Function  : This function is called to check if the user is a valid approver before enabling
            the 'Approve' and 'Reject' button.

Parameters:
    IN    : p_transaction_id   - fun_trx_headers.trx_id
    OUT   : Varchar2 - 'Y' implies user has access, 'N' means no access
Notes     : None.
Testing   : This function will be tested via the inbound trx UI
------------------------------------------------------------------------------*/

FUNCTION validate_approver (p_transaction_id      IN VARCHAR2 )
RETURN VARCHAR2;

-- 6995183 END


PROCEDURE set_invoice_reqd_flag(p_batch_id             IN NUMBER,
                                x_return_status        OUT NOCOPY VARCHAR2);


/*-----------------------------------------------------
 * PROCEDURE wf_abort
 * ----------------------------------------------------
 * Abort the workflow events running for the given batch_id and trx_id.
 * ---------------------------------------------------*/
PROCEDURE wf_abort (p_batch_id IN NUMBER,
                    p_trx_id IN NUMBER);

END;


/
