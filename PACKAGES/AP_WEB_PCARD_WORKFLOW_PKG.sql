--------------------------------------------------------
--  DDL for Package AP_WEB_PCARD_WORKFLOW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_PCARD_WORKFLOW_PKG" AUTHID CURRENT_USER AS
/* $Header: apwpcwfs.pls 120.3 2005/07/26 19:49:49 kgurumur noship $ */

PROCEDURE DistributeEmpVerifications (errbuf		OUT NOCOPY VARCHAR2,
				      retcode		OUT NOCOPY NUMBER,
                                      p_card_program_id	IN NUMBER DEFAULT NULL,
				      p_employee_id	IN NUMBER DEFAULT NULL,
				      p_status_lookup_code IN VARCHAR2 DEFAULT NULL,p_org_id in NUMBER);

PROCEDURE DistributeManagerApprovals (errbuf		OUT NOCOPY VARCHAR2,
				      retcode		OUT NOCOPY NUMBER,
				      p_manager_id IN NUMBER DEFAULT NULL,
				      p_org_id IN NUMBER);
PROCEDURE OpenP(p1  VARCHAR2,
		p2  VARCHAR2,
		p11 VARCHAR2 DEFAULT NULL);

PROCEDURE CheckEmpNotificationMethod(p_item_type	IN VARCHAR2,
			     	     p_item_key		IN VARCHAR2,
			     	     p_actid		IN NUMBER,
			     	     p_funmode		IN VARCHAR2,
			     	     p_result		OUT NOCOPY VARCHAR2);

PROCEDURE MarkRemainingTransVerified(p_item_type	IN VARCHAR2,
			     	     p_item_key		IN VARCHAR2,
			     	     p_actid		IN NUMBER,
			     	     p_funmode		IN VARCHAR2,
			     	     p_result		OUT NOCOPY VARCHAR2);

PROCEDURE AutoApprvVeriTransNotReqAprvl(p_item_type	IN VARCHAR2,
			     	        p_item_key	IN VARCHAR2,
			     	  	p_actid		IN NUMBER,
			     	  	p_funmode	IN VARCHAR2,
			     	  	p_result	OUT NOCOPY VARCHAR2);

PROCEDURE CheckEmpVerificationComplete(p_item_type	IN VARCHAR2,
			     	       p_item_key	IN VARCHAR2,
			     	       p_actid		IN NUMBER,
			     	       p_funmode	IN VARCHAR2,
			     	       p_result	OUT NOCOPY VARCHAR2);

PROCEDURE BuildEmpVerificationMessage(p_item_type	IN VARCHAR2,
				p_item_key	IN VARCHAR2,
				p_actid		IN NUMBER,
		       		p_funmode	IN VARCHAR2,
		       		p_result	OUT NOCOPY VARCHAR2);

PROCEDURE CheckManagerApprovalMethod(p_item_type	IN VARCHAR2,
			     	     p_item_key		IN VARCHAR2,
			     	     p_actid		IN NUMBER,
			     	     p_funmode		IN VARCHAR2,
			     	     p_result		OUT NOCOPY VARCHAR2);

PROCEDURE MarkTransactionsAsRejected(p_item_type	IN VARCHAR2,
			     	     p_item_key		IN VARCHAR2,
			     	     p_actid		IN NUMBER,
			     	     p_funmode		IN VARCHAR2,
			     	     p_result		OUT NOCOPY VARCHAR2);

PROCEDURE MarkTransactionsAsApproved(p_item_type	IN VARCHAR2,
			     	     p_item_key		IN VARCHAR2,
			     	     p_actid		IN NUMBER,
			     	     p_funmode		IN VARCHAR2,
			     	     p_result		OUT NOCOPY VARCHAR2);

PROCEDURE BuildManagerApprovalMessage(p_item_type	IN VARCHAR2,
				      p_item_key	IN VARCHAR2,
				      p_actid		IN NUMBER,
		       		      p_funmode		IN VARCHAR2,
		       		      p_result		OUT NOCOPY VARCHAR2);


END AP_WEB_PCARD_WORkFLOW_PKG;
 

/
