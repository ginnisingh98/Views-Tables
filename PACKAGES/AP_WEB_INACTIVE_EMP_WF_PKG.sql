--------------------------------------------------------
--  DDL for Package AP_WEB_INACTIVE_EMP_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_INACTIVE_EMP_WF_PKG" AUTHID CURRENT_USER as
/* $Header: apwinacs.pls 120.5 2005/10/02 20:15:44 albowicz noship $ */

--------------------------------------------------------
c_business                CONSTANT VARCHAR2(8) := 'BUSINESS';
c_api_version_num         CONSTANT NUMBER := 1.0;
c_commit                  CONSTANT VARCHAR2(1) := 'T';
c_attribute_appl_id       CONSTANT NUMBER  := 178;
c_last_update_login       CONSTANT NUMBER  := 0;
c_sec_attribute           CONSTANT VARCHAR2(30) := 'ICX_HR_PERSON_ID';

---------------------------------------------------------------------------------
SUBTYPE ccTrxn_cardProgID			IS AP_CREDIT_CARD_TRXNS.card_program_id%TYPE;
SUBTYPE ccTrxn_billedDate			IS AP_CREDIT_CARD_TRXNS.billed_date%TYPE;
---------------------------------------------------------------------------------

/*PER Employees */
----------------------------------------------------------------------------------
SUBTYPE perEmp_employeeID			IS PER_EMPLOYEES_CURRENT_X.employee_id%TYPE;
SUBTYPE perEmp_supervisorID			IS PER_EMPLOYEES_CURRENT_X.supervisor_id%TYPE;
----------------------------------------------------------------------------------


SUBTYPE wfItems_item_type           IS WF_ITEMS.item_type%type;
SUBTYPE wfItems_item_key            IS WF_ITEMS.item_key%type;

-----------------------------------------------
TYPE InactEmpCCTrxnCursor		IS REF CURSOR;
-----------------------------------------------


PROCEDURE Start_inactive_emp_process(p_card_program_id       IN NUMBER,
                                     p_inact_employee_id     IN NUMBER,
                                     p_billed_currency_code  IN VARCHAR2,
                                     p_total_amt_posted      IN NUMBER,
                                     p_cc_billed_start_date  IN ccTrxn_billedDate,
                                     p_cc_billed_end_date    IN ccTrxn_billedDate,
                                     p_wf_item_type          IN wfItems_item_type,
                                     p_wf_item_key           IN wfItems_item_key);

FUNCTION GetInactEmpCcardTrxnCursor(
	 	p_cardProgramId		IN  ccTrxn_cardProgID,
		p_employeeId		IN  perEmp_employeeID,
		p_billedStartDate	IN  ccTrxn_billedDate,
		p_billedEndDate		IN  ccTrxn_billedDate,
        p_itemkey           IN  wfItems_item_key,
		p_Inact_Emp_trx_cursor	OUT NOCOPY InactEmpCCTrxnCursor
) RETURN BOOLEAN;

PROCEDURE GenerateCCTrxList(document_id		IN VARCHAR2,
				            display_type	IN VARCHAR2,
				            document	IN OUT NOCOPY VARCHAR2,
				            document_type	IN OUT NOCOPY VARCHAR2);

PROCEDURE FindActiveMAnager(p_item_type		IN VARCHAR2,
			     	        p_item_key		IN VARCHAR2,
			     	        p_actid		    IN NUMBER,
			     	        p_funmode		IN VARCHAR2,
			     	        p_result		OUT NOCOPY VARCHAR2);

PROCEDURE CheckMangSecAttr(itemtype    in varchar2,
                           itemkey     in varchar2,
                           actid       in number,
                           funcmode    in varchar2,
                           resultout   in out NOCOPY varchar2);


PROCEDURE SetAPRolePreparer(p_item_type		IN VARCHAR2,
			     	        p_item_key		IN VARCHAR2,
			     	        p_actid		    IN NUMBER,
			     	        p_funmode		IN VARCHAR2,
			     	        p_result		OUT NOCOPY VARCHAR2);

PROCEDURE SetFromRoleForwardFrom(p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2);

PROCEDURE RecordForwardFromInfo(p_item_type	    IN VARCHAR2,
		     	  	            p_item_key		IN VARCHAR2,
		     	  	            p_actid		    IN NUMBER,
		     	  	            p_funmode		IN VARCHAR2,
		     	  	            p_result		OUT NOCOPY VARCHAR2);

PROCEDURE SetMangInfoPrepNoResp(itemtype  in varchar2,
                                itemkey   in varchar2,
                                actid     in number,
                                funcmode  in varchar2,
                                resultout in out NOCOPY varchar2);

PROCEDURE AddSecAttrPreparer(itemtype    in varchar2,
                             itemkey     in varchar2,
                             actid       in number,
                             funcmode    in varchar2,
                             resultout   in out NOCOPY varchar2);


PROCEDURE RemoveSecAttrPreparer(itemtype    in varchar2,
                                itemkey     in varchar2,
                                actid       in number,
                                funcmode    in varchar2,
                                resultout   in out NOCOPY varchar2);

PROCEDURE Format_message(p_status 	    IN  VARCHAR2,
                         p_msg_count 	IN  NUMBER,
                         p_msg_data 	IN  VARCHAR2,
                         p_error 	    OUT NOCOPY VARCHAR2);

PROCEDURE CheckCCTransactionExists(itemtype  in varchar2,
                                     itemkey   in varchar2,
                                     actid     in number,
                                     funcmode  in varchar2,
                                     resultout in out NOCOPY varchar2);

PROCEDURE  CheckWfExistsEmpl(itemtype  in varchar2,
                              itemkey   in varchar2,
                              actid     in number,
                              funcmode  in varchar2,
                              resultout in out NOCOPY varchar2);

PROCEDURE CallbackFunction(p_s_item_type      IN VARCHAR2,
                          	p_s_item_key       IN VARCHAR2,
                          	p_n_actid          IN NUMBER,
                          	p_s_command        IN VARCHAR2,
                          	p_s_result         OUT NOCOPY VARCHAR2);

PROCEDURE IsNotifTransferred( p_item_type      IN VARCHAR2,
                              p_item_key       IN VARCHAR2,
                              p_actid          IN NUMBER,
                              p_funmode        IN VARCHAR2,
                              p_result         OUT NOCOPY VARCHAR2);

PROCEDURE SetPersonAs(p_preparer_id 	      IN NUMBER,
                       p_item_type	          IN VARCHAR2,
		               p_item_key	          IN VARCHAR2,
		               p_preparer_target	  IN VARCHAR2);

PROCEDURE CheckAPApproved(itemtype  in varchar2,
                          itemkey   in varchar2,
                          actid     in number,
                          funcmode  in varchar2,
                          resultout in out NOCOPY varchar2);

FUNCTION GetUserIdForEmp(p_emp_user_name	IN	VARCHAR2,
	                     p_user_id	        OUT NOCOPY	NUMBER
) RETURN BOOLEAN;

PROCEDURE ClearItemkeyCCTrx(itemtype  in varchar2,
                            itemkey   in varchar2,
                            actid     in number,
                            funcmode  in varchar2,
                            resultout in out NOCOPY varchar2);

END AP_WEB_INACTIVE_EMP_WF_PKG;

 

/
