--------------------------------------------------------
--  DDL for Package AP_WEB_EXPENSE_CUST_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_EXPENSE_CUST_WF" AUTHID CURRENT_USER AS
/* $Header: apwxwfcs.pls 115.4 2002/11/14 23:04:24 kwidjaja ship $ */

PROCEDURE CustomValidateExpenseReport(p_item_type		IN VARCHAR2,
			     	  p_item_key		IN VARCHAR2,
			     	  p_actid		IN NUMBER,
			     	  p_funmode		IN VARCHAR2,
			     	  p_result	 OUT NOCOPY VARCHAR2);

PROCEDURE DoCustomValidation(p_report_header_id 	IN  NUMBER,
		       p_return_error_message   IN  OUT NOCOPY VARCHAR2);


PROCEDURE FindApprover(p_item_type	IN VARCHAR2,
		       p_item_key	IN VARCHAR2,
		       p_actid		IN NUMBER,
		       p_funmode	IN VARCHAR2,
		       p_result	 OUT NOCOPY VARCHAR2);

PROCEDURE VerifyAuthority(p_item_type	IN VARCHAR2,
		     	  	     p_item_key		IN VARCHAR2,
		     	  	     p_actid		IN NUMBER,
		     	  	     p_funmode		IN VARCHAR2,
		     	  	     p_result	 OUT NOCOPY VARCHAR2);


FUNCTION HasAuthority(p_approver_id	IN NUMBER,
		      p_doc_cost_center	IN VARCHAR2,
		      p_approval_amount	IN NUMBER,
                      p_item_key        IN VARCHAR2,
		      p_item_type	IN VARCHAR2) RETURN BOOLEAN;

PROCEDURE CustomDataTransfer(p_item_type	IN VARCHAR2,
			     p_item_key		IN VARCHAR2);


PROCEDURE DetermineMgrInvolvement(p_item_type	IN VARCHAR2,
		     	     	  p_item_key	IN VARCHAR2,
		     	     	  p_actid	IN NUMBER,
		     	     	  p_funmode	IN VARCHAR2,
		     	     	  p_result OUT NOCOPY VARCHAR2);

END AP_WEB_EXPENSE_CUST_WF;

 

/
