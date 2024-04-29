--------------------------------------------------------
--  DDL for Package Body AP_WEB_WRAPPER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_WRAPPER_PKG" AS
/* $Header: apwxwrpb.pls 120.6.12000000.2 2007/04/26 18:28:18 skoukunt ship $ */


--------------------------------------------------------------------------
PROCEDURE ICXAdminSig_helpWinScript(v_defHlp IN VARCHAR2) IS
  l_debugInfo varchar2(200);
begin
 null;
EXCEPTION
    WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE','ICXAdminSig_helpWinScript');
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debugInfo);
	APP_EXCEPTION.RAISE_EXCEPTION;

END ICXAdminSig_helpWinScript;

-----------------------------------------------------
PROCEDURE SetUpClientInfo
-----------------------------------------------------
IS

BEGIN
 null;
EXCEPTION
    WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE','AP_WEB_WRAPPER_PKG.SetUpClientInfo');
	APP_EXCEPTION.RAISE_EXCEPTION;

END SetUpClientInfo;

/**********************************************************************
*  Copied FND_DATE.string_to_canonical revision 115.3 for R11 backport
*  because the old R11.0 did not have this functionality, which
*  is called by AP_SSE_NOTIFY_EMPLOYEE.
**********************************************************************/
FUNCTION date_to_canonical(p_string IN date)
RETURN VARCHAR2 IS
BEGIN
   RETURN(fnd_date.date_to_canonical(p_string));
EXCEPTION
   WHEN OTHERS THEN
	RETURN(NULL);
END date_to_canonical;


/**********************************************************************
*  The old R11.0 does not have this functionality, which
*  is called by AP_CREDIT_CARD_INVOICE_PKG.createCreditCardInvoice.
*  This function is copied from version 115.3 of FND_DATE.string_to_date
*  in the 11.0 backport version
**********************************************************************/
FUNCTION string_to_date(p_string IN VARCHAR2,
			p_mask   IN VARCHAR2)
    RETURN DATE
    IS
BEGIN
    return FND_DATE.string_to_date(p_string, p_mask);

EXCEPTION
    WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE','AP_WEB_WRAPPER_PKG.string_to_date');
	APP_EXCEPTION.RAISE_EXCEPTION;
END string_to_date;


-----------------------------------------------------
PROCEDURE GenTaxFunctions
-----------------------------------------------------
IS
l_debugInfo varchar2(200);

l_total_tax_itmes       varchar2(10);
l_tax_id        varchar2(15);
l_tax_code      varchar2(15);
l_tax_startDate         DATE;
l_tax_inactiveDate      DATE;
l_tax_item_count       BINARY_INTEGER := 0;
V_Date_Format               VARCHAR2(30);

BEGIN

  null;

EXCEPTION
    WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE','AP_WEB_WRAPPER_PKG.GenTaxFunctions');
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debugInfo);
	APP_EXCEPTION.RAISE_EXCEPTION;

END GenTaxFunctions;

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
                       p_cc_reversal_flag    		IN varchar2 DEFAULT NULL)
IS

BEGIN

NULL;

/* This will not be used in Rel 12.0
        AP_INVOICE_DISTRIBUTIONS_PKG.insert_dist(
                         X_invoice_id              => p_invoice_Id,
			 X_invoice_distribution_id => null,
			 X_Line_Type               => p_Line_Type,
                         X_GL_Date                 => p_gl_Date,
                         X_Period_Name             => p_period_Name,
                         X_Type_1099               => null,
                         X_Income_Tax_Region       => null,
                         X_Amount                  => -(p_Amount),
			 X_Tax_Code_Id             => null,
			 X_Code_Combination_Id     => p_code_combination_id,
			 X_PA_Quantity             => null,
			 X_Description             => null,
			 X_tax_recoverable_flag    => null,
			 X_tax_recovery_rate	   => null,
			 X_tax_code_override_flag  => null,
			 X_tax_recovery_override_flag => null,
			 X_po_distribution_id	   => null,
                         X_Attribute_Category      => null,
                         X_Attribute1              => null,
                         X_Attribute2              => null,
                         X_Attribute3              => null,
                         X_Attribute4              => null,
                         X_Attribute5              => null,
                         X_Attribute6              => null,
                         X_Attribute7              => null,
                         X_Attribute8              => null,
                         X_Attribute9              => null,
                         X_Attribute10             => null,
                         X_Attribute11             => null,
                         X_Attribute12             => null,
                         X_Attribute13             => null,
                         X_Attribute14             => null,
                         X_Attribute15             => null,
                         X_Calling_Sequence        => p_calling_sequence,
                         X_company_prepaid_invoice_id => p_company_prepaid_invoice_id,
                         X_cc_reversal_flag        => 'Y');
*/

EXCEPTION
    WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE','AP_WEB_WRAPPER_PKG.insert_dist');
	APP_EXCEPTION.RAISE_EXCEPTION;

END insert_dist;


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
            P_billable_flag          OUT NOCOPY VARCHAR2)
IS
  l_debugInfo 		VARCHAR2(200);

BEGIN
  --------------------------------------------------------------
  l_debugInfo := 'ValidatePATransaction for 11.5';
  --------------------------------------------------------------
  PA_TRANSACTIONS_PUB.VALIDATE_TRANSACTION(
  X_PROJECT_ID         => P_project_id,
  X_TASK_ID            => P_task_id,
  X_EI_DATE            => P_ei_date,
  X_EXPENDITURE_TYPE   => P_expenditure_type,
  X_NON_LABOR_RESOURCE => P_non_labor_resource,
  X_PERSON_ID          => P_person_id,
  X_QUANTITY           => P_quantity,
  X_DENOM_CURRENCY_CODE =>P_denom_currency_code,
  X_ACCT_CURRENCY_CODE => P_acct_currency_code,
  X_DENOM_RAW_COST     => P_denom_raw_cost,
  X_ACCT_RAW_COST      => P_acct_raw_cost,
  X_ACCT_RATE_TYPE     => P_acct_rate_type,
  X_ACCT_RATE_DATE     => P_acct_rate_date,
  X_ACCT_EXCHANGE_RATE => P_acct_exchange_rate,
  X_TRANSFER_EI        => P_transfer_ei,
  X_INCURRED_BY_ORG_ID => P_incurred_by_org_id,
  X_NL_RESOURCE_ORG_ID => P_nl_resource_org_id,
  X_TRANSACTION_SOURCE => P_transaction_source,
  X_CALLING_MODULE     => P_calling_module,
  X_VENDOR_ID          => P_vendor_id,
  X_ENTERED_BY_USER_ID => P_entered_by_user_id,
  X_ATTRIBUTE_CATEGORY => P_attribute_category,
  X_ATTRIBUTE1         => P_attribute1,
  X_ATTRIBUTE2         => P_attribute2,
  X_ATTRIBUTE3         => P_attribute3,
  X_ATTRIBUTE4         => P_attribute4,
  X_ATTRIBUTE5         => P_attribute5,
  X_ATTRIBUTE6         => P_attribute6,
  X_ATTRIBUTE7         => P_attribute7,
  X_ATTRIBUTE8         => P_attribute8,
  X_ATTRIBUTE9         => P_attribute9,
  X_ATTRIBUTE10        => P_attribute10,
  X_ATTRIBUTE11        => P_attribute11,
  X_ATTRIBUTE12        => P_attribute12,
  X_ATTRIBUTE13        => P_attribute13,
  X_ATTRIBUTE14        => P_attribute14,
  X_ATTRIBUTE15        => P_attribute15,
  X_MSG_APPLICATION    => P_MsgApplication,
  X_MSG_TYPE           => P_MsgType,
  X_MSG_TOKEN1         => P_MsgToken1,
  X_MSG_TOKEN2         => P_MsgToken2,
  X_MSG_TOKEN3         => P_MsgToken3,
  X_MSG_COUNT          => P_MsgCount,
  X_MSG_DATA           => P_MsgName, -- P_msg_data will contain the error msg
  X_BILLABLE_FLAG      => P_billable_flag);

EXCEPTION
  WHEN OTHERS THEN
      BEGIN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'ValidatePATransaction');
        AP_WEB_UTILITIES_PKG.DisplayException(fnd_message.get);
      END;
END ValidatePATransaction;

---------------------------------------------------------------------
PROCEDURE HaveAMEReCreateApprovalChain(p_approver_id IN NUMBER,
				      p_item_key	IN VARCHAR2,
				      p_item_type	IN VARCHAR2) IS
---------------------------------------------------------------------
/*  Have AME recreate approval chain based off of overriding approver,
  by doing the following :
  Create an ame_util.approverInsertionsTable containing 1 approver
  insertion record with the employee_id set to l_curr_approver_id,
  api_insertion set to 'Y', and authority set to 'Y' and passing the
  table to ame_api.insertApprovers.
*/

l_debug_info                     VARCHAR2(200);
l_recApprover		AME_UTIL.approverRecord;

BEGIN

  ame_api.clearAllApprovals(applicationIdIn => AP_WEB_DB_UTIL_PKG.GetApplicationID,
                            transactionIdIn => p_item_key,
			    transactionTypeIn => p_item_type);

  ----------------------------------------------------
  l_debug_info := 'Set the fields in the approver table';
  ----------------------------------------------------
  l_recApprover.person_id     := p_approver_id;
  l_recApprover.api_insertion := ame_util.apiAuthorityInsertion;  -- 'A'
  l_recApprover.authority     := ame_util.authorityApprover;  -- 'Y'

  ----------------------------------------------------
  l_debug_info := 'Calling AME_API.setFirstAuthorityApprover';
  ----------------------------------------------------
  AME_API.setFirstAuthorityApprover(applicationIdIn   => AP_WEB_DB_UTIL_PKG.GetApplicationID,
                                    transactionIdIn   => p_item_key,
                                    approverIn        => l_recApprover,
                                    transactionTypeIn => p_item_type);

  ----------------------------------------------------
  l_debug_info := 'Done Calling AME_API.insertApprovers';
  ----------------------------------------------------

EXCEPTION
  WHEN OTHERS THEN
      BEGIN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'HaveAMEReCreateApprovalChain');
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
        AP_WEB_UTILITIES_PKG.DisplayException(fnd_message.get);
      END;
END HaveAMEReCreateApprovalChain;

---------------------------------------------------------------------
PROCEDURE SetRejectStatusInAME(	p_item_key	IN VARCHAR2,
			       	p_item_type	IN VARCHAR2) IS
---------------------------------------------------------------------
  l_debug_info                     VARCHAR2(200);
  l_AMEEnabled			   VARCHAR2(1);
  l_approver_id			   number;

BEGIN

    ----------------------------------------------------
    l_debug_info := 'Retrieve profile option AME Enabled?';
    ----------------------------------------------------
    l_AMEEnabled := WF_ENGINE.GetItemAttrText(p_item_type,
					       p_item_key,
					       'AME_ENABLED');

    IF (l_AMEEnabled = 'Y') THEN

      ------------------------------------------------------
      l_debug_info := 'Retrieve Approver_ID Item Attribute';
      -------------------------------------------------------
      l_approver_id := WF_ENGINE.GetItemAttrNumber(p_item_type,
						 p_item_key,
						 'APPROVER_ID');

      /*Call AME UpdateApprovalStatus2 api to let AME know the
	expense report is rejected */
      ------------------------------------------------------
      l_debug_info := 'Call AMEs updateApprovalAtatus api';
      ------------------------------------------------------
      AME_API.updateApprovalStatus2(applicationIdIn => AP_WEB_DB_UTIL_PKG.GetApplicationID,
                                transactionIdIn     => p_item_key,
                                approvalStatusIn    => AME_UTIL.rejectStatus,
                                approverPersonIdIn  => l_approver_id,
                                approverUserIdIn    => NULL,
                                transactionTypeIn   => p_item_type);

    END IF; -- if l_AMEEnabled;

EXCEPTION
  WHEN OTHERS THEN
      BEGIN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'SetRejectStatusInAME');
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
        AP_WEB_UTILITIES_PKG.DisplayException(fnd_message.get);
      END;
END SetRejectStatusInAME;

---------------------------------------------------------------------
PROCEDURE SetForwardInfoInAME( p_item_key      IN VARCHAR2,
                               p_item_type     IN VARCHAR2) IS
---------------------------------------------------------------------
  l_debug_info                     VARCHAR2(200);
  l_AMEEnabled                     VARCHAR2(1);
  l_approver_id                    number;
  l_forward_from_id                number;
  l_recApprover                    AME_UTIL.approverRecord2;
  l_approver_name                  varchar2(240);
  l_forward_from_name              varchar2(240);

  C_WF_Version		           NUMBER := 0;
  l_itemkey                        wf_items.item_key%TYPE;

BEGIN

    ----------------------------------------------------
    l_debug_info := 'Retrieve profile option AME Enabled?';
    ----------------------------------------------------
    l_AMEEnabled := WF_ENGINE.GetItemAttrText(p_item_type,
					       p_item_key,
					       'AME_ENABLED');

    IF (l_AMEEnabled = 'Y') THEN

      C_WF_VERSION  :=  AP_WEB_EXPENSE_WF.GetFlowVersion(p_item_type, p_item_key);
      -- l_itemkey is the itemkey of the parent, need parent item key
      -- to update the approval status
      IF (C_WF_Version >= AP_WEB_EXPENSE_WF.C_R120_Version) THEN
         l_itemkey := WF_ENGINE.GetItemAttrText(p_item_type,
 					       p_item_key,
					       'AME_MASTER_ITEM_KEY');
      ELSE
         l_itemkey := p_item_key;
      END IF;

      ------------------------------------------------------
      l_debug_info := 'Retrieve Approver_ID Item Attribute';
      -------------------------------------------------------
      l_approver_id := WF_ENGINE.GetItemAttrNumber(p_item_type,
                                                 p_item_key,
                                                 'APPROVER_ID');

      ------------------------------------------------------
      l_debug_info := 'Retrieve Approver_Name Item Attribute';
      -------------------------------------------------------
      l_approver_name := WF_ENGINE.GetItemAttrText(p_item_type,
  						    p_item_key,
						    'APPROVER_NAME');

      ------------------------------------------------------
      l_debug_info := 'Retrieve Forward_from_ID Item Attribute';
      -------------------------------------------------------
      l_forward_from_id := WF_ENGINE.GetItemAttrNumber(p_item_type,
                                                 p_item_key,
                                                 'FORWARD_FROM_ID');

      ------------------------------------------------------
      l_debug_info := 'Retrieve Forward_from_Name Item Attribute';
      -------------------------------------------------------
      l_forward_from_name := WF_ENGINE.GetItemAttrText(p_item_type,
  						    p_item_key,
						    'FORWARD_FROM_NAME');

      /*Call AME UpdateApprovalStatus api to let AME know the
        expense report is forwarded */
      ------------------------------------------------------
      l_debug_info := 'Call AMEs updateApprovalStatus api';
      ------------------------------------------------------
      /*
      l_recApprover.person_id := l_approver_id;

      AME_API.updateApprovalStatus2(applicationIdIn    => AP_WEB_DB_UTIL_PKG.GetApplicationID,
                                    transactionIdIn    => p_item_key,
                                    approvalStatusIn   => ame_util.noResponseStatus,
                                    approverPersonIdIn => l_forward_from_id,
                                    approverUserIdIn   => NULL,
                                    transactionTypeIn  => p_item_type,
                                    forwardeeIn        => l_recApprover);
      */
      l_recApprover.name := l_approver_name;

      AME_API2.updateApprovalStatus2(applicationIdIn    => AP_WEB_DB_UTIL_PKG.GetApplicationID,
                              	    transactionTypeIn  => p_item_type,
                               	    transactionIdIn    => l_itemkey,
                                    approvalStatusIn   => ame_util.noResponseStatus,
                                    approverNameIn     => l_forward_from_name,
                                    forwardeeIn        => l_recApprover);

    END IF; -- if l_AMEEnabled;

EXCEPTION
  WHEN OTHERS THEN
      BEGIN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'SetRejectStatusInAME');
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
        AP_WEB_UTILITIES_PKG.DisplayException(fnd_message.get);
      END;
END SetForwardInfoInAME;


FUNCTION isPopList(p_ValueSetFormat FND_VSET.VALUESET_DR) RETURN BOOLEAN IS
BEGIN

    if (p_ValueSetFormat.longlist_flag is null OR
        p_ValueSetFormat.longlist_flag = 'X') then
        return true;
    else
        return false;
    end if;


EXCEPTION
    WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE','AP_WEB_WRAPPER_PKG.isPopList');
	APP_EXCEPTION.RAISE_EXCEPTION;

END isPopList;

END AP_WEB_WRAPPER_PKG;

/
