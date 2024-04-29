--------------------------------------------------------
--  DDL for Package AP_WORKFLOW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WORKFLOW_PKG" AUTHID CURRENT_USER AS
/* $Header: aphanwfs.pls 120.26.12010000.6 2009/08/03 12:52:10 ansethur ship $ */
--  Public Procedure Specifications

PROCEDURE get_approver(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 );

PROCEDURE is_negotiable_flow(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 );
PROCEDURE process_ack_pomatched(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 );

PROCEDURE process_rel_pomatched(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 );

PROCEDURE process_ack_pounmatched(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 );

PROCEDURE process_rel_pounmatched(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 );

PROCEDURE is_it_internal(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 );

PROCEDURE get_supplier_contact(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 );

PROCEDURE process_accept_ext(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 );

PROCEDURE get_first_approver(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 );

PROCEDURE process_cancel_inv_by_sup(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 );

PROCEDURE process_accept_int(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 );
/*
APINVAPR - Main Approval Process
*/
PROCEDURE check_header_requirements(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 );

PROCEDURE check_line_requirements(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 );

PROCEDURE get_approvers(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 );

PROCEDURE identify_approvers(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 );

PROCEDURE launch_approval_notifications(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 );

PROCEDURE launch_neg_notifications(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 );

PROCEDURE process_doc_rejection(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 );

PROCEDURE process_doc_approval(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 );

PROCEDURE process_lines_approval(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 );

PROCEDURE process_lines_rejection(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 );

PROCEDURE set_document_approver(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 );

PROCEDURE set_lines_approver(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 );
/*
APINVNEG - AP Invoice Approval Negotiation
*/

PROCEDURE get_last_approver(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 );

PROCEDURE aprvl_process_accept_ext(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 );

PROCEDURE aprvl_process_accept_int(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 );

PROCEDURE aprvl_process_cancel_inv_sup(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 );
/************* NEW Procedures *************/
PROCEDURE create_hold_neg_process(p_hold_id IN NUMBER,
                                  p_ext_contact_id IN NUMBER,
                                          parentkey IN VARCHAR2,
                                          childkey  IN VARCHAR2,
					  int_ext_indicator IN VARCHAR2,
					  newchildprocess OUT NOCOPY VARCHAR2) ;

PROCEDURE create_hold_wf_process(p_hold_id IN NUMBER);
PROCEDURE get_header_approver(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 );
PROCEDURE escalate_doc_approval(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 );
PROCEDURE escalate_lines_approval(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 );
PROCEDURE awake_approval_main(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 );
PROCEDURE create_lineapp_neg_process(p_invoice_id IN NUMBER,
					  p_ext_user_id IN NUMBER,
					  p_invoice_amount IN NUMBER,
                                          parentkey IN VARCHAR2,
                                          childkey  IN VARCHAR2,
                                          int_ext_indicator IN VARCHAR2,
                                          p_wfitemkey OUT NOCOPY VARCHAR2);
PROCEDURE create_invapp_process(p_invoice_id IN NUMBER
                       ,p_approval_iteration IN NUMBER DEFAULT NULL
                       ,p_wfitemkey OUT NOCOPY VARCHAR2);
FUNCTION Stop_Approval(
                        p_invoice_id IN NUMBER,
                        p_line_number IN NUMBER,
                        p_calling_sequence IN VARCHAR2) RETURN BOOLEAN;
PROCEDURE process_single_line_response(p_invoice_id IN NUMBER,
                                       p_line_number IN NUMBER,
				       p_response IN VARCHAR2,
				       p_itemkey  IN VARCHAR2,
                                       p_comments IN VARCHAR2);
FUNCTION Get_Attribute_Value(p_invoice_id IN NUMBER,
                   p_sub_class_id IN NUMBER DEFAULT NULL,
                   p_attribute_name IN VARCHAR2,
                   p_context IN VARCHAR2 DEFAULT NULL)
                                 RETURN VARCHAR2;
FUNCTION AP_Dist_Accounting_Flex(p_seg_name IN VARCHAR2,
                                 p_dist_id IN NUMBER) RETURN VARCHAR2;
PROCEDURE exists_initial_wait(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 );
PROCEDURE is_hold_released(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 );
PROCEDURE continue_hold_workflow(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 );
PROCEDURE is_invoice_matched(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 );
PROCEDURE abort_holds_workflow(p_hold_id IN NUMBER);
FUNCTION IS_INV_NEGOTIATED(
                 p_invoice_id IN ap_invoice_lines_all.invoice_id%TYPE
		,p_org_id IN ap_invoice_lines_all.org_id%TYPE)
		RETURN BOOLEAN;
/* Bug 5590138, Bring it from old apiawles.pls */
PROCEDURE Get_All_Approvers(p_invoice_id IN NUMBER,
                        p_calling_sequence IN VARCHAR2);

/* Bug 5595121, Following Procedure becomes public */

PROCEDURE insert_history_table(p_hist_rec IN AP_INV_APRVL_HIST%ROWTYPE);
PROCEDURE Terminate_Approval( errbuf   OUT NOCOPY VARCHAR2,
                              retcode  OUT NOCOPY NUMBER);

PROCEDURE wakeup_lineapproval_process(p_invoice_id IN NUMBER,
                                      p_itemkey  IN VARCHAR2);

PROCEDURE aprvl_get_supplier_contact(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 );

PROCEDURE aprvl_process_reject_int(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 );

-- Bug 8462325. Added parameter p_process_instance_label.
PROCEDURE approve_button( p_itemkey  IN VARCHAR2,
                          p_process_instance_label IN VARCHAR2);
--Bug 8689391. Added parameter processInstanceLabel  to procedure rejectButton.
PROCEDURE reject_button( p_itemkey  IN VARCHAR2,
                          p_process_instance_label IN VARCHAR2);
PROCEDURE accept_invoice_button( p_itemkey  IN VARCHAR2);
PROCEDURE accept_invoice_int_button( p_itemkey  IN VARCHAR2);
PROCEDURE cancel_invoice_aprvl_button( p_itemkey  IN VARCHAR2);

PROCEDURE set_comments( p_itemkey  IN VARCHAR2,
                        p_notif_id IN VARCHAR2,
                        p_notes in VARCHAR2);

PROCEDURE is_payment_request(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 );
-- added for IAW delegation enhancement
PROCEDURE forward_check(itemtype   IN VARCHAR2,
                        itemkey    IN VARCHAR2,
                        actid      IN NUMBER,
                        funcmode   IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 );

PROCEDURE notification_handler( itemtype  IN VARCHAR2,
                                itemkey   IN VARCHAR2,
                                actid     IN NUMBER,
                                funcmode  IN VARCHAR2,
                                resultout OUT NOCOPY VARCHAR2 );
PROCEDURE notification_handler_lines( itemtype  IN VARCHAR2,
                                itemkey   IN VARCHAR2,
                                actid     IN NUMBER,
                                funcmode  IN VARCHAR2,
                                resultout OUT NOCOPY VARCHAR2 );
PROCEDURE forward_check_lines(itemtype   IN VARCHAR2,
                        itemkey    IN VARCHAR2,
                        actid      IN NUMBER,
                        funcmode   IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 );
-- added for IAW delegation enhancement
END AP_WORKFLOW_PKG;

/
