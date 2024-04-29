--------------------------------------------------------
--  DDL for Package AP_WFAPPROVAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WFAPPROVAL_PKG" AUTHID CURRENT_USER AS
/* $Header: apiawges.pls 120.0.12000000.3 2007/07/20 07:07:12 schamaku ship $ */
-- Public Procedure Specification

FUNCTION ap_accounting_flex(p_ccid IN NUMBER,
                            p_seg_name IN VARCHAR2,
			    p_set_of_books_id IN NUMBER ) RETURN VARCHAR2;

FUNCTION ap_dist_accounting_flex(p_seg_name IN VARCHAR2,
				 p_dist_id IN NUMBER) RETURN VARCHAR2;

PROCEDURE iaw_po_check(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout OUT NOCOPY VARCHAR2);

PROCEDURE get_approver(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 );

PROCEDURE update_history(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 );

PROCEDURE insert_history(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2 );

PROCEDURE insert_history(p_invoice_id  IN NUMBER,
                        p_iteration IN NUMBER,
			p_org_id IN NUMBER,
			p_status IN VARCHAR2);

PROCEDURE escalate_request(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 );

PROCEDURE set_attribute_values(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2 );

PROCEDURE notification_handler(itemtype IN VARCHAR2,
                        itemkey IN VARCHAR2,
                        actid   IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout  OUT NOCOPY VARCHAR2 );

PROCEDURE iaw_raise_event(eventname IN VARCHAR2,
                        itemkey IN VARCHAR2,
			p_org_id IN NUMBER );

FUNCTION get_attribute_value(   p_invoice_id IN NUMBER,
                                p_dist_id IN NUMBER DEFAULT NULL,
                                p_attribute_name IN VARCHAR2,
                                p_context IN VARCHAR2 DEFAULT NULL)
				RETURN VARCHAR2;
--Bug 5968183
--Added procedure to change Invoice Approval status when a workflow is cancelled for the same.
PROCEDURE Update_Invoice_Status(
          p_invoice_id IN ap_invoices_all.invoice_id%TYPE);
--End of 5968183
END AP_WFAPPROVAL_PKG;



 

/
