--------------------------------------------------------
--  DDL for Package PO_AME_WF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_AME_WF_PVT" AUTHID CURRENT_USER AS
-- $Header: PO_AME_WF_PVT.pls 120.0.12010000.5 2012/06/14 07:23:03 smvinod noship $

applicationId     NUMBER :=201; /* ame is using PO id  */


PROCEDURE get_next_approvers(
            itemtype        IN VARCHAR2,
            itemkey         IN VARCHAR2,
            actid           IN NUMBER,
            funcmode        IN VARCHAR2,
            resultout       OUT NOCOPY VARCHAR2);

PROCEDURE launch_parallel_approval(
            itemtype        IN VARCHAR2,
            itemkey         IN VARCHAR2,
            actid           IN NUMBER,
            funcmode        IN VARCHAR2,
            resultout       OUT NOCOPY VARCHAR2);

PROCEDURE determine_approver_category(
            itemtype        IN VARCHAR2,
            itemkey         IN VARCHAR2,
            actid           IN NUMBER,
            funcmode        IN VARCHAR2,
            resultout       OUT NOCOPY VARCHAR2);

PROCEDURE update_action_history_forward(
            itemtype        IN VARCHAR2,
            itemkey         IN VARCHAR2,
            actid           IN NUMBER,
            funcmode        IN VARCHAR2,
            resultout       OUT NOCOPY VARCHAR2);

PROCEDURE update_action_history_approve(
            itemtype        IN VARCHAR2,
            itemkey         IN VARCHAR2,
            actid           IN NUMBER,
            funcmode        IN VARCHAR2,
            resultout       OUT NOCOPY VARCHAR2);

PROCEDURE update_action_history_reject(
            itemtype        IN VARCHAR2,
            itemkey         IN VARCHAR2,
            actid           IN NUMBER,
            funcmode        IN VARCHAR2,
            resultout       OUT NOCOPY VARCHAR2);

PROCEDURE update_action_history_timeout(
            itemtype        IN VARCHAR2,
            itemkey         IN VARCHAR2,
            actid           IN NUMBER,
            funcmode        IN VARCHAR2,
            resultout       OUT NOCOPY VARCHAR2);

PROCEDURE insert_action_history(
            itemtype        IN VARCHAR2,
            itemkey         IN VARCHAR2,
            actid           IN NUMBER,
            funcmode        IN VARCHAR2,
            resultout       OUT NOCOPY VARCHAR2);

PROCEDURE process_response_exception(
            itemtype        IN VARCHAR2,
            itemkey         IN VARCHAR2,
            actid           IN NUMBER,
            funcmode        IN VARCHAR2,
            resultout       OUT NOCOPY VARCHAR2);

PROCEDURE process_response_app_forward(
            itemtype        IN VARCHAR2,
            itemkey         IN VARCHAR2,
            actid           IN NUMBER,
            funcmode        IN VARCHAR2,
            resultout       OUT NOCOPY VARCHAR2);

PROCEDURE process_response_approve(
            itemtype        IN VARCHAR2,
            itemkey         IN VARCHAR2,
            actid           IN NUMBER,
            funcmode        IN VARCHAR2,
            resultout       OUT NOCOPY VARCHAR2);

PROCEDURE process_response_timeout(
            itemtype        IN VARCHAR2,
            itemkey         IN VARCHAR2,
            actid           IN NUMBER,
            funcmode        IN VARCHAR2,
            resultout       OUT NOCOPY VARCHAR2);

PROCEDURE process_response_forward(
            itemtype        IN VARCHAR2,
            itemkey         IN VARCHAR2,
            actid           IN NUMBER,
            funcmode        IN VARCHAR2,
            resultout       OUT NOCOPY VARCHAR2);

PROCEDURE process_response_reject(
            itemtype        IN VARCHAR2,
            itemkey         IN VARCHAR2,
            actid           IN NUMBER,
            funcmode        IN VARCHAR2,
            resultout       OUT NOCOPY VARCHAR2);

PROCEDURE increment_no_reminder_attr(
            itemtype        IN VARCHAR2,
            itemkey         IN VARCHAR2,
            actid           IN NUMBER,
            funcmode        IN VARCHAR2,
            resultout       OUT NOCOPY VARCHAR2);

PROCEDURE post_approval_notif(
            itemtype        IN VARCHAR2,
            itemkey         IN VARCHAR2,
            actid           IN NUMBER,
            funcmode        IN VARCHAR2,
            resultout       OUT NOCOPY VARCHAR2);

PROCEDURE generate_pdf_ame_supp(
            itemtype        IN VARCHAR2,
            itemkey         IN VARCHAR2,
            actid           IN NUMBER,
            funcmode        IN VARCHAR2,
            resultout       OUT NOCOPY VARCHAR2);

PROCEDURE generate_pdf_ame_buyer(
            itemtype        IN VARCHAR2,
            itemkey         IN VARCHAR2,
            actid           IN NUMBER,
            funcmode        IN VARCHAR2,
            resultout       OUT NOCOPY VARCHAR2);

PROCEDURE forward_unable_to_reserve(
            itemtype        IN VARCHAR2,
            itemkey         IN VARCHAR2,
            actid           IN NUMBER,
            funcmode        IN VARCHAR2,
            resultout       OUT NOCOPY VARCHAR2);

PROCEDURE process_beat_by_first(
            itemtype        IN VARCHAR2,
            itemkey         IN VARCHAR2,
            actid           IN NUMBER,
            funcmode        IN VARCHAR2,
            resultout       OUT NOCOPY VARCHAR2);

PROCEDURE is_ame_exception(
            itemtype        IN VARCHAR2,
            itemkey         IN VARCHAR2,
            actid           IN NUMBER,
            funcmode        IN VARCHAR2,
            resultout       OUT NOCOPY VARCHAR2);

PROCEDURE update_resp_verf_failed(
            itemtype        IN VARCHAR2,
            itemkey         IN VARCHAR2,
            actid           IN NUMBER,
            funcmode        IN VARCHAR2,
            resultout       OUT NOCOPY VARCHAR2);

PROCEDURE update_resp_verf_failed_reject(
            itemtype        IN VARCHAR2,
            itemkey         IN VARCHAR2,
            actid           IN NUMBER,
            funcmode        IN VARCHAR2,
            resultout       OUT NOCOPY VARCHAR2);

PROCEDURE get_ame_sub_approval_response(
            itemtype        IN VARCHAR2,
            itemkey         IN VARCHAR2,
            actid           IN NUMBER,
            funcmode        IN VARCHAR2,
            resultout       OUT NOCOPY VARCHAR2);

PROCEDURE update_action_history_reminder(
            itemtype        IN VARCHAR2,
            itemkey         IN VARCHAR2,
            actid           IN NUMBER,
            funcmode        IN VARCHAR2,
            resultout       OUT NOCOPY VARCHAR2);

PROCEDURE withdraw_document(
		    p_document_id         IN NUMBER,
            p_draft_id            IN NUMBER,
            p_document_type       IN VARCHAR2,
            p_document_sub_type   IN VARCHAR2,
            p_revision_num        IN NUMBER,
            p_current_employee_id IN NUMBER,
            p_note                IN VARCHAR2,
            x_return_status       OUT NOCOPY VARCHAR2,
            x_return_message      OUT NOCOPY VARCHAR2);

PROCEDURE is_fyi_approver(
            itemtype   IN        VARCHAR2,
            itemkey    IN        VARCHAR2,
            actid      IN        NUMBER,
            funcmode   IN        VARCHAR2,
            resultout  OUT NOCOPY VARCHAR2 );

FUNCTION get_current_future_approvers(
            transactionType IN   VARCHAR2,
            transactionId   IN   NUMBER)
RETURN po_ame_approver_tab;

PROCEDURE set_esigner_response_rejected(
            itemtype   IN        VARCHAR2,
            itemkey    IN        VARCHAR2,
            actid      IN        NUMBER,
            funcmode   IN        VARCHAR2,
            resultout  OUT NOCOPY VARCHAR2 ) ;

PROCEDURE set_esigner_response_accepted(
            itemtype   IN        VARCHAR2,
            itemkey    IN        VARCHAR2,
            actid      IN        NUMBER,
            funcmode   IN        VARCHAR2,
            resultout  OUT NOCOPY VARCHAR2 ) ;

PROCEDURE create_erecord(
            itemtype   IN        VARCHAR2,
            itemkey    IN        VARCHAR2,
            actid      IN        NUMBER,
            funcmode   IN        VARCHAR2,
            resultout  OUT NOCOPY VARCHAR2);

PROCEDURE check_for_esigner_exists(
            itemtype   IN        VARCHAR2,
            itemkey    IN        VARCHAR2,
            actid      IN        NUMBER,
            funcmode   IN        VARCHAR2,
            resultout  OUT NOCOPY VARCHAR2 );

PROCEDURE update_auth_status_esign(
            itemtype   IN        VARCHAR2,
            itemkey    IN        VARCHAR2,
            actid      IN        NUMBER,
            funcmode   IN        VARCHAR2,
            resultout  OUT NOCOPY VARCHAR2);


PROCEDURE trigger_approval_workflow(
            itemtype   IN        VARCHAR2,
            itemkey    IN        VARCHAR2,
            actid      IN        NUMBER,
            funcmode   IN        VARCHAR2,
            resultout  OUT NOCOPY VARCHAR2);

PROCEDURE suppress_existing_esigners(
            itemtype   IN        VARCHAR2,
            itemkey    IN        VARCHAR2,
            actid      IN        NUMBER,
            funcmode   IN        VARCHAR2,
            resultout  OUT NOCOPY VARCHAR2);

PROCEDURE complete_ame_transaction(
            itemtype   IN        VARCHAR2,
            itemkey    IN        VARCHAR2,
            actid      IN        NUMBER,
            funcmode   IN        VARCHAR2,
            resultout  OUT NOCOPY VARCHAR2);

PROCEDURE update_action_history_app_fwd(
            itemtype        IN VARCHAR2,
            itemkey         IN VARCHAR2,
            actid           IN NUMBER,
            funcmode        IN VARCHAR2,
            resultout       OUT NOCOPY VARCHAR2);

PROCEDURE ame_is_forward_to_valid(
            itemtype   IN        VARCHAR2,
            itemkey    IN        VARCHAR2,
            actid      IN        NUMBER,
            funcmode   IN        VARCHAR2,
            resultout  OUT NOCOPY VARCHAR2);

END PO_AME_WF_PVT;

/
