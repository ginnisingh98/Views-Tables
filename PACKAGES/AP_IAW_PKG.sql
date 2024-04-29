--------------------------------------------------------
--  DDL for Package AP_IAW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_IAW_PKG" AUTHID CURRENT_USER AS
/* $Header: apiawles.pls 120.9 2006/01/26 00:05:53 mrjiang noship $ */

--Global Variables

TYPE r_inv_aprvl_hist IS RECORD(
	APPROVAL_HISTORY_ID ap_inv_aprvl_hist_all.approval_history_id%TYPE,
 	INVOICE_ID ap_inv_aprvl_hist_all.invoice_id%TYPE,
 	ITERATION ap_inv_aprvl_hist_all.iteration%TYPE,
 	RESPONSE ap_inv_aprvl_hist_all.response%TYPE,
 	APPROVER_ID ap_inv_aprvl_hist_all.approver_id%TYPE,
 	AMOUNT_APPROVED ap_inv_aprvl_hist_all.amount_approved%TYPE,
 	APPROVER_COMMENTS ap_inv_aprvl_hist_all.approver_comments%TYPE,
 	CREATED_BY  ap_inv_aprvl_hist_all.created_by%TYPE,
 	CREATION_DATE ap_inv_aprvl_hist_all.creation_date%TYPE,
 	LAST_UPDATE_DATE ap_inv_aprvl_hist_all.last_update_date%TYPE,
 	LAST_UPDATED_BY ap_inv_aprvl_hist_all.last_updated_by%TYPE,
 	LAST_UPDATE_LOGIN ap_inv_aprvl_hist_all.last_update_login%TYPE,
 	ORG_ID ap_inv_aprvl_hist_all.org_id%TYPE);

TYPE r_line_aprvl_hist IS RECORD(
	LINE_APRVL_HISTORY_ID ap_line_aprvl_hist_all.line_aprvl_history_id%TYPE,
 	LINE_NUMBER ap_line_aprvl_hist_all.line_number%TYPE,
 	INVOICE_ID ap_line_aprvl_hist_all.invoice_id%TYPE,
 	ITERATION ap_line_aprvl_hist_all.iteration%TYPE,
 	RESPONSE ap_line_aprvl_hist_all.response%TYPE,
 	APPROVER_ID ap_line_aprvl_hist_all.approver_id%TYPE,
 	LINE_AMOUNT_APPROVED  ap_line_aprvl_hist_all.line_amount_approved%TYPE,
 	TAX_AMOUNT_APPROVED ap_line_aprvl_hist_all.tax_amount_approved%TYPE,
 	FREIGHT_AMOUNT_APPROVED ap_line_aprvl_hist_all.freight_amount_approved%TYPE,
 	MISC_AMOUNT_APPROVED ap_line_aprvl_hist_all.misc_amount_approved%TYPE,
 	APPROVER_COMMENTS ap_line_aprvl_hist_all.approver_comments%TYPE,
 	ORG_ID ap_line_aprvl_hist_all.org_id%TYPE,
 	CREATED_BY ap_line_aprvl_hist_all.created_by%TYPE,
 	CREATION_DATE ap_line_aprvl_hist_all.creation_date%TYPE,
 	LAST_UPDATED_BY ap_line_aprvl_hist_all.last_updated_by%TYPE,
 	LAST_UPDATE_DATE ap_line_aprvl_hist_all.last_update_date%TYPE,
 	LAST_UPDATE_LOGIN ap_line_aprvl_hist_all.last_update_login%TYPE,
	ITEM_CLASS ap_line_aprvl_hist_all.item_class%TYPE,
	ITEM_ID ap_line_aprvl_hist_all.item_id%TYPE);


-- Public Procedures Specifications called from WF process

PROCEDURE Check_Header_Requirements(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout OUT NOCOPY VARCHAR2);

PROCEDURE Check_Line_Requirements(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout OUT NOCOPY VARCHAR2);

PROCEDURE Identify_Approver(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout OUT NOCOPY VARCHAR2);

PROCEDURE Get_Approvers(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout OUT NOCOPY VARCHAR2);

PROCEDURE Set_Approver(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout OUT NOCOPY VARCHAR2);

PROCEDURE Escalate_Header_Request(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 );

PROCEDURE Escalate_Line_Request(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 );

PROCEDURE Response_Handler(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 );

PROCEDURE Response_Handler(p_invoice_id IN NUMBER,
                        p_line_num IN NUMBER,
                        p_not_key   IN VARCHAR2,
                        p_response IN VARCHAR2,
                        p_comments IN VARCHAR2 );

PROCEDURE Notification_Handler(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 );

--Public Procedures called from other procedures

PROCEDURE IAW_Raise_Event(p_eventname IN VARCHAR2,
                          p_invoice_id IN VARCHAR2,
                          p_org_id IN NUMBER,
			  p_calling_sequence IN VARCHAR2);

PROCEDURE Set_Attribute_Values(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2 );

PROCEDURE Insert_Header_History(
			p_inv_aprvl_hist IN ap_iaw_pkg.r_inv_aprvl_hist);

PROCEDURE Insert_Line_History(
                        p_line_aprvl_hist IN ap_iaw_pkg.r_line_aprvl_hist);


PROCEDURE Insert_Header_History(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
			p_type IN VARCHAR2 );

PROCEDURE Insert_Line_History(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
			P_type IN VARCHAR2) ;

/*PROCEDURE Update_Header_History(
			p_invoice_id IN NUMBER,
			p_inv_iteration IN NUMBER,
			p_who_id 	IN NUMBER);
*/

PROCEDURE Update_Header_History(itemtype IN VARCHAR2,
			actid IN NUMBER,
                        itemkey IN VARCHAR2);

PROCEDURE  Update_Line_History(
                        p_invoice_id IN NUMBER,
                        p_line_num IN NUMBER,
                        p_response IN VARCHAR2,
                        p_comments IN VARCHAR2);

PROCEDURE Update_Line_History(itemtype IN VARCHAR2,
			actid IN NUMBER,
                        itemkey IN VARCHAR2);

PROCEDURE Get_All_Approvers(p_invoice_id IN NUMBER,
                        p_calling_sequence IN VARCHAR2);

PROCEDURE Terminate_Approval(
                        errbuf OUT NOCOPY VARCHAR2,
                        retcode           OUT NOCOPY NUMBER);

--Public Functions called from other procedures

FUNCTION Clear_AME_History_Header(
			p_invoice_id IN NUMBER,
			p_calling_sequence IN VARCHAR2) RETURN BOOLEAN;

FUNCTION Clear_AME_History_Line(
                        p_invoice_id IN NUMBER,
			p_line_num IN NUMBER,
			p_calling_sequence IN VARCHAR2) RETURN BOOLEAN;

FUNCTION Stop_Approval(p_invoice_id IN NUMBER,
		       p_line_number IN NUMBER,
		       p_calling_sequence IN VARCHAR2) RETURN BOOLEAN;

FUNCTION AP_Dist_Accounting_Flex(p_seg_name IN VARCHAR2,
				 p_dist_id IN NUMBER) RETURN VARCHAR2;

FUNCTION Get_Attribute_Value(   p_invoice_id IN NUMBER,
                                p_sub_class_id IN NUMBER DEFAULT NULL,
                                p_attribute_name IN VARCHAR2,
                                p_context IN VARCHAR2 DEFAULT NULL)
				RETURN VARCHAR2;


/*********************************************************************
 *********************************************************************
 *********************************************************************
 **                                                                 **
 ** Methods for Dispute Main Flow and Dispute Notification Flow     **
 **                                                                 **
 *********************************************************************
 *********************************************************************
 *********************************************************************/

PROCEDURE apply_matching_hold(	p_invoice_id in number);


PROCEDURE is_disputable(	itemtype IN VARCHAR2,
                     		itemkey IN VARCHAR2,
                        	actid   IN NUMBER,
                        	funcmode IN VARCHAR2,
                        	resultout OUT NOCOPY VARCHAR2);

PROCEDURE assign_internal_rep(	itemtype IN VARCHAR2,
                     		itemkey IN VARCHAR2,
                        	actid   IN NUMBER,
                        	funcmode IN VARCHAR2,
                        	resultout OUT NOCOPY VARCHAR2);

PROCEDURE create_approver_rec(	itemtype IN VARCHAR2,
                     		itemkey IN VARCHAR2,
                        	actid   IN NUMBER,
                        	funcmode IN VARCHAR2,
                        	resultout OUT NOCOPY VARCHAR2);

PROCEDURE exist_internal_rep(	itemtype IN VARCHAR2,
                     		itemkey IN VARCHAR2,
                        	actid   IN NUMBER,
                        	funcmode IN VARCHAR2,
                        	resultout OUT NOCOPY VARCHAR2);

PROCEDURE set_access_control(	itemtype IN VARCHAR2,
                     		itemkey IN VARCHAR2,
                        	actid   IN NUMBER,
                        	funcmode IN VARCHAR2,
                        	resultout OUT NOCOPY VARCHAR2);

PROCEDURE clear_approver_rec(	itemtype IN VARCHAR2,
                     		itemkey IN VARCHAR2,
                        	actid   IN NUMBER,
                        	funcmode IN VARCHAR2,
                        	resultout OUT NOCOPY VARCHAR2);

PROCEDURE set_dispute_notif_reciever(
				itemtype IN VARCHAR2,
                     		itemkey IN VARCHAR2,
                        	actid   IN NUMBER,
                        	funcmode IN VARCHAR2,
                        	resultout OUT NOCOPY VARCHAR2);

PROCEDURE cancel_invoice(	itemtype IN VARCHAR2,
                     		itemkey IN VARCHAR2,
                        	actid   IN NUMBER,
                        	funcmode IN VARCHAR2,
                        	resultout OUT NOCOPY VARCHAR2);

PROCEDURE accept_invoice(	itemtype IN VARCHAR2,
                     		itemkey IN VARCHAR2,
                        	actid   IN NUMBER,
                        	funcmode IN VARCHAR2,
                        	resultout OUT NOCOPY VARCHAR2);

PROCEDURE unwait_main_flow(	itemtype IN VARCHAR2,
                     		itemkey IN VARCHAR2,
                        	actid   IN NUMBER,
                        	funcmode IN VARCHAR2,
                        	resultout OUT NOCOPY VARCHAR2);

PROCEDURE is_all_accepted(	itemtype IN VARCHAR2,
                     		itemkey IN VARCHAR2,
                        	actid   IN NUMBER,
                        	funcmode IN VARCHAR2,
                        	resultout OUT NOCOPY VARCHAR2);

PROCEDURE is_invoice_updated(	itemtype IN VARCHAR2,
                     		itemkey IN VARCHAR2,
                        	actid   IN NUMBER,
                        	funcmode IN VARCHAR2,
                        	resultout OUT NOCOPY VARCHAR2);

PROCEDURE is_internal(		itemtype IN VARCHAR2,
                     		itemkey IN VARCHAR2,
                        	actid   IN NUMBER,
                        	funcmode IN VARCHAR2,
                        	resultout OUT NOCOPY VARCHAR2);

PROCEDURE exist_null_int_rep(	itemtype IN VARCHAR2,
                     		itemkey IN VARCHAR2,
                        	actid   IN NUMBER,
                        	funcmode IN VARCHAR2,
                        	resultout OUT NOCOPY VARCHAR2);

PROCEDURE asgn_fallback_int_rep(itemtype IN VARCHAR2,
                     		itemkey IN VARCHAR2,
                        	actid   IN NUMBER,
                        	funcmode IN VARCHAR2,
                        	resultout OUT NOCOPY VARCHAR2);

PROCEDURE launch_disp_notif_flow(itemtype IN VARCHAR2,
                     		itemkey IN VARCHAR2,
                        	actid   IN NUMBER,
                        	funcmode IN VARCHAR2,
                        	resultout OUT NOCOPY VARCHAR2);


PROCEDURE is_rejected(		itemtype IN VARCHAR2,
                     		itemkey IN VARCHAR2,
                        	actid   IN NUMBER,
                        	funcmode IN VARCHAR2,
                        	resultout OUT NOCOPY VARCHAR2);

PROCEDURE is_invoice_request(	itemtype IN VARCHAR2,
                     		itemkey IN VARCHAR2,
                        	actid   IN NUMBER,
                        	funcmode IN VARCHAR2,
                        	resultout OUT NOCOPY VARCHAR2);

PROCEDURE update_to_invoice(	itemtype IN VARCHAR2,
                     		itemkey IN VARCHAR2,
                        	actid   IN NUMBER,
                        	funcmode IN VARCHAR2,
                        	resultout OUT NOCOPY VARCHAR2);

PROCEDURE is_isp_enabled(	itemtype IN VARCHAR2,
                     		itemkey IN VARCHAR2,
                        	actid   IN NUMBER,
                        	funcmode IN VARCHAR2,
                        	resultout OUT NOCOPY VARCHAR2);

FUNCTION getRoleEmailAddress(	p_role	in varchar2) return varchar2;

PROCEDURE launch_approval_notif_flow(itemtype IN VARCHAR2,
                                itemkey IN VARCHAR2,
                                actid   IN NUMBER,
                                funcmode IN VARCHAR2,
                                resultout OUT NOCOPY VARCHAR2);

PROCEDURE exists_receiving_hold(itemtype IN VARCHAR2,
                                itemkey IN VARCHAR2,
                                actid   IN NUMBER,
                                funcmode IN VARCHAR2,
                                resultout OUT NOCOPY VARCHAR2);

PROCEDURE delay_dispute(        itemtype IN VARCHAR2,
                                itemkey IN VARCHAR2,
                                actid   IN NUMBER,
                                funcmode IN VARCHAR2,
                                resultout OUT NOCOPY VARCHAR2);

PROCEDURE revalidate_invoice(   itemtype IN VARCHAR2,
                                itemkey IN VARCHAR2,
                                actid   IN NUMBER,
                                funcmode IN VARCHAR2,
                                resultout OUT NOCOPY VARCHAR2);

PROCEDURE release_holds(        itemtype IN VARCHAR2,
                                itemkey IN VARCHAR2,
                                actid   IN NUMBER,
                                funcmode IN VARCHAR2,
                                resultout OUT NOCOPY VARCHAR2);

END AP_IAW_PKG;


 

/
