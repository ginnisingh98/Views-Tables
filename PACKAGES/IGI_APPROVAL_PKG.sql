--------------------------------------------------------
--  DDL for Package IGI_APPROVAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_APPROVAL_PKG" AUTHID CURRENT_USER AS
/* $Header: igiexpns.pls 115.5 2002/11/18 12:29:54 sowsubra ship $ */

---------------------------------------------------------------------------
---------------------------------------------------------------------------
-- Public Procedure Specification
---------------------------------------------------------------------------
---------------------------------------------------------------------------

PROCEDURE Process_Inv_Hold_Status(p_invoice_id 		IN NUMBER,
				  p_line_location_id	IN NUMBER,
				  p_rcv_transaction_id  IN NUMBER,
				  p_hold_lookup_code	IN VARCHAR2,
				  p_should_have_hold	IN VARCHAR2,
				  p_hold_reason		IN VARCHAR2,
				  p_system_user		IN NUMBER,
				  p_holds		IN OUT NOCOPY AP_APPROVAL_PKG.HOLDSARRAY,
				  p_holds_count		IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
				  p_release_count	IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
				  p_calling_sequence	IN VARCHAR2);

PROCEDURE Get_Hold_Status(p_invoice_id		IN NUMBER,
			  p_line_location_id	IN NUMBER,
			  p_rcv_transaction_id	IN NUMBER,
			  p_hold_lookup_code	IN VARCHAR2,
			  p_system_user		IN NUMBER,
			  p_status		IN OUT NOCOPY VARCHAR2,
			  p_return_hold_reason  IN OUT NOCOPY VARCHAR2,
			  p_user_id     	IN OUT NOCOPY VARCHAR2,
			  p_resp_id		IN OUT NOCOPY VARCHAR2,
			  p_calling_sequence  	IN VARCHAR2);

PROCEDURE Approve(p_run_option			IN VARCHAR2,
             	  p_invoice_batch_id		IN NUMBER,
                  p_begin_invoice_date		IN DATE,
                  p_end_invoice_date		IN DATE,
                  p_vendor_id			IN NUMBER,
                  p_pay_group			IN VARCHAR2,
                  p_invoice_id			IN NUMBER,
                  p_entered_by			IN NUMBER,
                  p_set_of_books_id		IN NUMBER,
                  p_trace_option		IN VARCHAR2,
		  p_conc_flag			IN VARCHAR2,
		  p_holds_count			IN OUT NOCOPY NUMBER,
		  p_approval_status		IN OUT NOCOPY VARCHAR2,
		  p_calling_sequence		IN VARCHAR2);

PROCEDURE Release_Hold(p_invoice_id		IN NUMBER,
		       p_line_location_id	IN NUMBER,
		       p_rcv_transaction_id	IN NUMBER,
		       p_hold_lookup_code	IN VARCHAR2,
		       p_holds			IN OUT NOCOPY AP_APPROVAL_PKG.HOLDSARRAY,
		       p_release_count		IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
		       p_calling_sequence	IN VARCHAR2);

END IGI_APPROVAL_PKG;

 

/
