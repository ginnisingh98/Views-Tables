--------------------------------------------------------
--  DDL for Package AP_WEB_WRAPPER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_WRAPPER_PKG" AUTHID CURRENT_USER AS
/* $Header: apwxwrps.pls 120.2 2005/09/07 21:56:44 rlangi ship $ */


/**********************************************************************
*  Copied FND_DATE.canonical_mask revision 115.5 in the spec for R11 backport
*  because the old R11.0 did not have this, which
*  is used by AP_CREDIT_CARD_INVOICE_PKG.createCreditCardInvoice.
**********************************************************************/
canonical_mask    varchar2(15) := 'YYYY/MM/DD';
canonical_DT_mask varchar2(26) := 'YYYY/MM/DD HH24:MI:SS';

--------------------------------------------------------------------------
PROCEDURE ICXAdminSig_helpWinScript(v_defHlp IN VARCHAR2);

PROCEDURE GenTaxFunctions;

PROCEDURE SetUpClientInfo;

FUNCTION date_to_canonical(p_string IN DATE)
RETURN VARCHAR2;

FUNCTION string_to_date(p_string IN VARCHAR2,
			p_mask   IN VARCHAR2)
RETURN DATE;

PROCEDURE insert_dist (p_invoice_id          		IN number,
		       p_Line_Type           		IN varchar2,
                       p_GL_Date             		IN date,
                       p_Period_Name         		IN varchar2,
                       p_Type_1099           		IN varchar2,
                       p_Income_Tax_Region   		IN varchar2,
                       p_Amount              		IN number,
		       p_Vat_Code            		IN varchar2,
		       p_Code_Combination_Id 		IN number,
		       p_PA_Quantity         		IN number,
		       p_Description         		IN varchar2,
-- Bug 1105325. Passing the project info.
                       p_Project_Acct_Cont   		IN varchar2,
                       p_Project_Id          		IN number,
                       p_Task_Id             		IN number,
                       p_Expenditure_Type    		IN varchar2,
                       p_Expenditure_Org_Id  		IN number,
                       p_Exp_item_date       		IN date,
--Bug# 763539 . Passin the attribute category		 and the attributes
                       p_Attribute_Category  		IN varchar2,
                       p_Attribute1          		IN varchar2,
                       p_Attribute2          		IN varchar2,
                       p_Attribute3          		IN varchar2,
                       p_Attribute4          		IN varchar2,
                       p_Attribute5          		IN varchar2,
                       p_Attribute6          		IN varchar2,
                       p_Attribute7          		IN varchar2,
                       p_Attribute8          		IN varchar2,
                       p_Attribute9          		IN varchar2,
                       p_Attribute10         		IN varchar2,
                       p_Attribute11         		IN varchar2,
                       p_Attribute12         		IN varchar2,
                       p_Attribute13         		IN varchar2,
                       p_Attribute14         		IN varchar2,
                       p_Attribute15         		IN varchar2,
--backport.  Exists in 11i but not in 11.0
		       p_invoice_distribution_id    	IN number,
		       p_Tax_Code_Id         	    	IN NUMBER,
		       p_tax_recoverable_flag 	    	IN varchar2,
		       p_tax_recovery_rate   	    	IN number,
		       p_tax_code_override_flag     	IN varchar2,
		       p_tax_recovery_override_flag 	IN varchar2,
		       p_po_distribution_id  	    	IN number,
--end backport.
                       p_Calling_Sequence    		IN varchar2,
                       p_company_prepaid_invoice_id 	IN number DEFAULT NULL,
                       p_cc_reversal_flag    		IN varchar2 DEFAULT NULL);

PROCEDURE ValidatePATransaction(
            P_project_id             IN NUMBER,
            P_task_id                IN NUMBER,
            P_ei_date                IN DATE,
            P_expenditure_type       IN VARCHAR2,
            P_non_labor_resource     IN VARCHAR2,
            P_person_id              IN NUMBER,
            P_quantity               IN NUMBER DEFAULT NULL,
            P_denom_currency_code    IN VARCHAR2 DEFAULT NULL,
            P_acct_currency_code     IN VARCHAR2 DEFAULT NULL,
            P_denom_raw_cost         IN NUMBER DEFAULT NULL,
            P_acct_raw_cost          IN NUMBER DEFAULT NULL,
            P_acct_rate_type         IN VARCHAR2 DEFAULT NULL,
            P_acct_rate_date         IN DATE DEFAULT NULL,
            P_acct_exchange_rate     IN NUMBER DEFAULT NULL ,
            P_transfer_ei            IN NUMBER DEFAULT NULL,
            P_incurred_by_org_id     IN NUMBER DEFAULT NULL,
            P_nl_resource_org_id     IN NUMBER DEFAULT NULL,
            P_transaction_source     IN VARCHAR2 DEFAULT NULL ,
            P_calling_module         IN VARCHAR2 DEFAULT NULL,
            P_vendor_id              IN NUMBER DEFAULT NULL,
            P_entered_by_user_id     IN NUMBER DEFAULT NULL,
            P_attribute_category     IN VARCHAR2 DEFAULT NULL,
            P_attribute1             IN VARCHAR2 DEFAULT NULL,
            P_attribute2             IN VARCHAR2 DEFAULT NULL,
            P_attribute3             IN VARCHAR2 DEFAULT NULL,
            P_attribute4             IN VARCHAR2 DEFAULT NULL,
            P_attribute5             IN VARCHAR2 DEFAULT NULL,
            P_attribute6             IN VARCHAR2 DEFAULT NULL,
            P_attribute7             IN VARCHAR2 DEFAULT NULL,
            P_attribute8             IN VARCHAR2 DEFAULT NULL,
            P_attribute9             IN VARCHAR2 DEFAULT NULL,
            P_attribute10            IN VARCHAR2 DEFAULT NULL,
            P_attribute11            IN VARCHAR2 DEFAULT NULL,
            P_attribute12            IN VARCHAR2 DEFAULT NULL,
            P_attribute13            IN VARCHAR2 DEFAULT NULL,
            P_attribute14            IN VARCHAR2 DEFAULT NULL,
            P_attribute15            IN VARCHAR2 DEFAULT NULL,
  	    P_MsgApplication	     IN OUT NOCOPY VARCHAR2,
  	    P_MsgType 		     OUT NOCOPY VARCHAR2,
  	    P_MsgToken1 	     OUT NOCOPY VARCHAR2,
  	    P_MsgToken2 	     OUT NOCOPY VARCHAR2,
  	    P_MsgToken3 	     OUT NOCOPY VARCHAR2,
  	    P_MsgCount 		     OUT NOCOPY NUMBER,
  	    P_MsgName 		     OUT NOCOPY VARCHAR2, -- P_msg_data will contain the error msg
	    P_Msg_Data		     OUT NOCOPY VARCHAR2,
            P_billable_flag          OUT NOCOPY VARCHAR2);

PROCEDURE HaveAMEReCreateApprovalChain(p_approver_id IN NUMBER,
				      p_item_key	IN VARCHAR2,
				      p_item_type	IN VARCHAR2);

PROCEDURE SetRejectStatusInAME(	p_item_key	IN VARCHAR2,
			       	p_item_type	IN VARCHAR2);

PROCEDURE SetForwardInfoInAME( p_item_key      IN VARCHAR2,
                               p_item_type     IN VARCHAR2);

FUNCTION isPopList(p_ValueSetFormat FND_VSET.VALUESET_DR) RETURN BOOLEAN;

END AP_WEB_WRAPPER_PKG;

 

/
