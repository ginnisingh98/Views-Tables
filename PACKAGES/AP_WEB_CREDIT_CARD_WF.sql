--------------------------------------------------------
--  DDL for Package AP_WEB_CREDIT_CARD_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_CREDIT_CARD_WF" AUTHID CURRENT_USER AS
/* $Header: apwccwfs.pls 120.17.12010000.3 2008/08/19 06:54:34 sodash ship $ */
-- Constant definitions
c_voidPayment varchar2(20) := 'VOID_PAYMENT_PROCESS';  -- Bug 7187680(sodash)
c_paymentToCardIssuer varchar2(20) := 'PAY_TO_CARD_ISSUER';
c_paymentToEmployee varchar2(20) := 'PAY_TO_EMPLOYEE';
c_check         varchar2(20):= 'CHECK';
c_directDeposit varchar2(20):= 'DIRECT_DEPOSIT';

TYPE EmployeeCursor                IS REF CURSOR; --Amulya Mishra : Notification Esc Project
/*
Purpose:
  To send Workflow notifications to employee when AP makes Expense Report payments to:
  - employee
  - credit card issuer
Input:
  p_checkNumber: Check number
  p_employeeId: Employee id
  p_paymentCurrency: Currency of the payment
  p_invoiceNumber: Expense report invoice number
  p_paidAmount: Paid amount
  p_paymentTo: Flag indicate to whom payment is made. Use the predefined constants
               c_paymentToCardIssuer or c_paymentToCardEmployee
  p_paymentMethod: Flag to indicate if the payment is direct deposit or by check. This
                   applies when the payment is to employee only. Use the predefined constants
                   c_check or c_directDeposit.
  p_account: Employee's bank account
  p_bankName: Employee's bank name
  p_cardIssuer: Card issuer name
  p_paymentDate: Formatted date of payment
  p_deferred: Boolean flag to indicate if the WF process(notification) is deferred. This
              parameter should be set to TRUE when the procedure is called by a database
              trigger.
Output:
  None
Input Output:
  None
Assumption:
  None.
Usage
  Since this procedure is used for both cases where payment is made to employee or credit card
company, the NULL value could be passed for some of the parameters as described in the following:
- When payment to employee:
  p_paymentTo flag = c_paymentToCardEmployee
  p_paymentMethod = c_check or c_directDeposit
  p_cardIssuer = null
- When payment to credit card company:
  p_paymentTo = c_paymentToIssuer
  p_paymentMethod = null
  p_account = null
  p_bankName = null

  All the other parmaters are required.

Date:
  10/14/99
*/
PROCEDURE sendPaymentNotification(p_checkNumber       IN NUMBER,
			   	  p_employeeId        IN NUMBER,
                                  p_paymentCurrency   IN VARCHAR2,
                                  p_invoiceNumber     IN VARCHAR2,
			   	  p_paidAmount	      IN NUMBER,
                                  p_paymentTo         IN VARCHAR2,
                                  p_paymentMethod     IN VARCHAR2,
                           	  p_account           IN VARCHAR2,
                           	  p_bankName          IN VARCHAR2,
                                  p_cardIssuer        IN VARCHAR2,
                                  p_paymentDate       IN VARCHAR2,
                                  p_deferred          IN BOOLEAN default TRUE);

/*
Purpose:
  To send Workflow notifications to an employee to remind him/her to submit expense report
  for unsubmitted expenses incurred during a period( of p_date1 and p_date2).
Input:
  p_employeeId: Employee Id
  p_Amount: Total Amount of unsumitted expenses
  p_currency: Currency
  p_cardIssuer: Card issuer name
  p_Date1: Start date of the period(formatted)
  p_Date2: End date of the period(formatted)
Output:
  None
Input Output:
  None
Assumption:
  None.
Usage
  To be called by the Unsubmitted Report process. See the 11i Credit Card
  functional specs for details.
Date:
  10/14/99
*/
PROCEDURE sendUnsubmittedChargesNote(p_employeeId     IN NUMBER,
			   	  p_Amount	      IN NUMBER,
                           	  p_currency          IN VARCHAR2,
                                  p_cardIssuer        IN VARCHAR2,
                                  p_date1             IN VARCHAR2,
                           	  p_date2             IN VARCHAR2,
				  p_charge_type	      IN VARCHAR2,
 				  p_send_notifications  IN VARCHAR2 DEFAULT 'EM',       -- default Emp and Mgr Bug 6026927
				  p_min_amount    IN NUMBER DEFAULT null);   -- Bug 6886855 (sodash) setting the wf attribute MIN_AMOUNT


PROCEDURE SendDunningNotifications
	(p_employeeId       	IN NUMBER,
         p_cardProgramId    	IN AP_CARD_PROGRAMS.card_program_id%TYPE,
	 p_amount		IN NUMBER,
         p_currency          	IN VARCHAR2,
	 p_min_bucket    	IN NUMBER,
	 p_max_bucket    	IN NUMBER,
	 p_dunning_number 	IN NUMBER,
         p_send_notifications IN VARCHAR2,
         p_esc_level          IN NUMBER,
         p_grace_days         IN NUMBER,
         p_manager_notified   IN VARCHAR2);



/*
Purpose:
  To send Workflow notifications to a manager to remind him/her to process a
  submitted expense report.
Input:
  p_managerId: Manager Id
  p_expenseReportId: Expense Report (Header) id
  p_Amount: Total Amount of unsumitted expenses
Output:
  None
Input Output:
  None
Assumption:
  None.
Usage
  To be called by the Unapproved Report process. See the 11i Credit Card
  functional specs for details.
Date:
  10/14/99
*/
PROCEDURE sendUnapprovedExpReportNote(
	p_expenseReportId   IN AP_EXPENSE_REPORT_HEADERS.report_header_id%TYPE,
        p_current_approver  IN AP_EXPENSE_REPORT_HEADERS.expense_current_approver_id%TYPE);  --2628468


/*
Purpose:
  To send Workflow notifications to an employee to remind him/her to
  resolve outstanding disputed charges.
Input:
  p_employeeId: Employee Id
  p_cardProgramId: Card Program ID
  p_billedStartDate: Start date for billed date
  p_billedEndDate: End date for billed date
  p_minimumAmount: Minimum billed amount to be processed
Output:
  None
Input Output:
  None
Assumption:
  None.
Usage
  To be called by the Disputed Report process. See the 11i Credit Card
  functional specs for details.
Date:
  10/14/99
*/
PROCEDURE sendDisputedChargesNote(p_employeeId       IN NUMBER,
				  p_cardProgramId    IN AP_CARD_PROGRAMS.card_program_id%TYPE,
                                  p_billedStartDate  in date,
                                  p_billedEndDate    in date,
			   	  p_minimumAmount    IN NUMBER);


PROCEDURE GenerateList(document_id		IN VARCHAR2,
				display_type	IN VARCHAR2,
				document	IN OUT NOCOPY VARCHAR2,
				document_type	IN OUT NOCOPY VARCHAR2);

PROCEDURE GenerateUnsubmittedList(document_id		IN VARCHAR2,
				display_type	IN VARCHAR2,
				document	IN OUT NOCOPY VARCHAR2,
				document_type	IN OUT NOCOPY VARCHAR2);

PROCEDURE GenerateDunningList(document_id               IN VARCHAR2,
                                display_type    IN VARCHAR2,
                                document        IN OUT NOCOPY VARCHAR2,
                                document_type   IN OUT NOCOPY VARCHAR2);

PROCEDURE getNumofDunningrecords(document_id	IN VARCHAR2,
				display_type	IN VARCHAR2,
				document	IN OUT NOCOPY VARCHAR2,
				document_type	IN OUT NOCOPY VARCHAR2);

PROCEDURE getNumofUnsubmittedrecords(document_id	IN VARCHAR2,
				display_type	IN VARCHAR2,
				document	IN OUT NOCOPY VARCHAR2,
				document_type	IN OUT NOCOPY VARCHAR2);

--Amulya Mishra :Notifications Esc Project

PROCEDURE SendNotifications(p_item_type      IN VARCHAR2,
                            p_item_key       IN VARCHAR2,
                            p_actid          IN NUMBER,
                            p_funmode        IN VARCHAR2,
                            p_result         OUT NOCOPY VARCHAR2);

PROCEDURE GenerateDunningClobList(  document_id     IN VARCHAR2,
                                display_type    IN VARCHAR2,
                                document        IN OUT NOCOPY CLOB,
                                document_type   IN OUT NOCOPY VARCHAR2);

PROCEDURE GenerateManagerDunningList(	document_id	IN VARCHAR2,
				display_type	IN VARCHAR2,
				document	IN OUT NOCOPY CLOB,
				document_type	IN OUT NOCOPY VARCHAR2);

PROCEDURE GenerateNextManagerDunningList(	document_id	IN VARCHAR2,
				display_type	IN VARCHAR2,
				document	IN OUT NOCOPY CLOB,
				document_type	IN OUT NOCOPY VARCHAR2);


--Amulya Mishra: Notification Esc project

FUNCTION GetEmployeeCursor(
	        p_supervisor_id		IN  NUMBER,
      		p_employee_cursor OUT NOCOPY EmployeeCursor)
RETURN BOOLEAN;

--Amulya Mishra: Notification Esc project

--5049215 -- Added the dunning number to the function level as only records of this dunning level are processed later.
FUNCTION GetHierarchialEmployeeCursor(
	        p_supervisor_id		IN  NUMBER,
      		p_employee_cursor OUT NOCOPY EmployeeCursor,
		p_level_id			IN NUMBER DEFAULT NULL)
RETURN BOOLEAN;


--AMulya Mishra: Notification Esc project

PROCEDURE GetTotalOutstandingAttribute(
                 p_employee_id  IN NUMBER,
		 p_cardProgramId         IN  NUMBER,
                 p_min_bucket            IN  NUMBER,
                 p_max_bucket            IN  NUMBER,
                 p_grace_days            IN  NUMBER,
                 p_total_amount   OUT NOCOPY NUMBER);

--Amulya Mishra: Notification Esc project

PROCEDURE GetHierTotalOutstandingAttr(
                 p_supervisor_id  IN NUMBER,
		 p_cardProgramId         IN  NUMBER,
                 p_min_bucket            IN  NUMBER,
                 p_max_bucket            IN  NUMBER,
                 p_grace_days            IN  NUMBER,
                 p_dunning_number        IN  NUMBER,
                 p_total_amount   OUT NOCOPY NUMBER);

--Amulya Mishra: Notification Esc project

PROCEDURE IsNotificationRepeated(p_item_type      IN VARCHAR2,
                            p_item_key       IN VARCHAR2,
                            p_actid          IN NUMBER,
                            p_funmode        IN VARCHAR2,
                            p_result         OUT NOCOPY VARCHAR2);

--Amulya Mishra: Notification Esc project Direct project


PROCEDURE IsFirstDunning(p_item_type      IN VARCHAR2,
                            p_item_key       IN VARCHAR2,
                            p_actid          IN NUMBER,
                            p_funmode        IN VARCHAR2,
                            p_result         OUT NOCOPY VARCHAR2);


--Bug 3337443
FUNCTION GetDirectReport(
                p_employee_id         IN  NUMBER,
                p_final_manager_id    IN  NUMBER)
RETURN VARCHAR2;

PROCEDURE GenUnsubmittedClobList(document_id	IN VARCHAR2,
				display_type	IN VARCHAR2,
				document	IN OUT NOCOPY CLOB,
				document_type	IN OUT NOCOPY VARCHAR2);


PROCEDURE GetWebNextEscManager(p_itemType 	IN VARCHAR2,
	                       p_itemKey 	IN VARCHAR2);

PROCEDURE GetWebEscManager(p_itemType       IN VARCHAR2,
                           p_itemKey        IN VARCHAR2);

PROCEDURE SendDeactivatedNotif(p_employeeId     IN NUMBER,
                               p_cardProgramId  IN NUMBER,
                               p_endDate        IN VARCHAR2);

------------------------------------------------------------------------
PROCEDURE CallbackFunction(     p_item_type      IN VARCHAR2,
                                p_item_key       IN VARCHAR2,
                                p_actid          IN NUMBER,
                                p_funmode        IN VARCHAR2,
                                p_result         OUT NOCOPY VARCHAR2);
------------------------------------------------------------------------

END AP_WEB_CREDIT_CARD_WF;

/
