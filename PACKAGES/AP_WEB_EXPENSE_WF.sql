--------------------------------------------------------
--  DDL for Package AP_WEB_EXPENSE_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_EXPENSE_WF" AUTHID CURRENT_USER AS
/* $Header: apwxwkfs.pls 120.37.12010000.3 2010/05/30 10:38:47 rveliche ship $ */

-- Constant names for projects workflow
C_CreditLineVersion           CONSTANT NUMBER := 1;
C_NoMultiLineVersion          CONSTANT NUMBER := 2;
C_ProjectIntegrationVersion   CONSTANT NUMBER := 1;
C_11_0_3Version               CONSTANT NUMBER := 2;
C_OIEH_Version                CONSTANT NUMBER := 3;
C_OIEJ_Version                CONSTANT NUMBER := 4;
C_R120_Version                CONSTANT NUMBER := 5;
-- Constants used to indicate where ER submit from
C_SUBMIT_FROM_OIE             CONSTANT VARCHAR2(1) := 'Y';
C_SUBMIT_FROM_BG              CONSTANT VARCHAR2(1) := 'N';
--C_Unchanged		      CONSTANT VARCHAR2(1) := 'U';

FUNCTION GetFlowVersion(p_item_type	IN VARCHAR2,
			p_item_key	IN VARCHAR2) RETURN NUMBER;

PROCEDURE StartExpenseReportProcess(p_report_header_id	IN NUMBER,
				    p_preparer_id	IN NUMBER,
				    p_employee_id	IN NUMBER,
				    p_document_number	IN VARCHAR2,
				    p_total		IN NUMBER,
				    p_new_total		IN NUMBER,
				    p_reimb_curr	IN VARCHAR2,
				    p_cost_center	IN VARCHAR2,
				    p_purpose		IN VARCHAR2,
				    p_approver_id	IN NUMBER,
                                    p_week_end_date     IN DATE,
                                    p_workflow_flag     IN VARCHAR2,
                                    p_submit_from_oie   IN VARCHAR2,
                                    p_event_raised      IN VARCHAR2 DEFAULT 'N');

PROCEDURE APValidateExpenseReport(p_item_type		IN VARCHAR2,
			     	  p_item_key		IN VARCHAR2,
			     	  p_actid		IN NUMBER,
			     	  p_funmode		IN VARCHAR2,
			     	  p_result	 OUT NOCOPY VARCHAR2);

PROCEDURE DoAPValidation(p_item_type            IN  VARCHAR2,
                         p_item_key             IN  VARCHAR2,
                         p_report_header_id 	IN  AP_EXPENSE_REPORT_HEADERS.report_header_id%TYPE);


-------------------------------------------------------------------------------
PROCEDURE CashLineErrorsAP(document_id in varchar2,
                 display_type in varchar2,
                 document in out nocopy clob,
                 document_type in out nocopy varchar2);
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
PROCEDURE CashLineErrorsPreparer(document_id in varchar2,
                 display_type in varchar2,
                 document in out nocopy clob,
                 document_type in out nocopy varchar2);
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
PROCEDURE CCardLineErrorsAP(document_id in varchar2,
                 display_type in varchar2,
                 document in out nocopy clob,
                 document_type in out nocopy varchar2);
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
PROCEDURE CCardLineErrorsPreparer(document_id in varchar2,
                 display_type in varchar2,
                 document in out nocopy clob,
                 document_type in out nocopy varchar2);
-------------------------------------------------------------------------------

PROCEDURE BuildBothpayExpReport(p_item_type	IN VARCHAR2,
				p_item_key	IN VARCHAR2,
				p_actid		IN NUMBER,
		       		p_funmode	IN VARCHAR2,
		       		p_result OUT NOCOPY VARCHAR2);

PROCEDURE FindVendor(p_item_type	IN VARCHAR2,
		     p_item_key		IN VARCHAR2,
		     p_actid		IN NUMBER,
		     p_funmode		IN VARCHAR2,
		     p_result	 OUT NOCOPY VARCHAR2);

PROCEDURE CheckIfBothpay(p_item_type	IN VARCHAR2,
				p_item_key	IN VARCHAR2,
				p_actid		IN NUMBER,
		       		p_funmode	IN VARCHAR2,
		       		p_result OUT NOCOPY VARCHAR2);

PROCEDURE CheckIfSplit(p_item_type	IN VARCHAR2,
				p_item_key	IN VARCHAR2,
				p_actid		IN NUMBER,
		       		p_funmode	IN VARCHAR2,
		       		p_result OUT NOCOPY VARCHAR2);

PROCEDURE BuildManagerApprvlMessage(p_item_type	IN VARCHAR2,
				      p_item_key	IN VARCHAR2,
				      p_actid		IN NUMBER,
		       		      p_funmode		IN VARCHAR2,
		       		      p_result	 OUT NOCOPY VARCHAR2);

PROCEDURE ManagerApproved(p_item_type		IN VARCHAR2,
		   	  p_item_key		IN VARCHAR2,
		   	  p_actid		IN NUMBER,
		   	  p_funmode		IN VARCHAR2,
		   	  p_result	 OUT NOCOPY VARCHAR2);

PROCEDURE CheckSumMissingReceipts(p_item_type    IN VARCHAR2,
					      p_item_key     IN VARCHAR2,
					      p_actid	     IN NUMBER,
					      p_funmode	     IN VARCHAR2,
					      p_result	     OUT NOCOPY VARCHAR2);

PROCEDURE AnyReceiptRequired(p_item_type	IN VARCHAR2,
		       	     p_item_key		IN VARCHAR2,
		       	     p_actid		IN NUMBER,
		       	     p_funmode		IN VARCHAR2,
		       	     p_result	 OUT NOCOPY VARCHAR2);

PROCEDURE AnyJustificationRequired(p_item_type		IN VARCHAR2,
		       	     	  p_item_key		IN VARCHAR2,
		       	     	  p_actid		IN NUMBER,
		       	     	  p_funmode		IN VARCHAR2,
		       	     	  p_result	 OUT NOCOPY VARCHAR2);

PROCEDURE CreditLinesOnly(p_item_type		IN VARCHAR2,
		       	  p_item_key		IN VARCHAR2,
		       	  p_actid		IN NUMBER,
		       	  p_funmode		IN VARCHAR2,
		       	  p_result	 OUT NOCOPY VARCHAR2);

PROCEDURE APReviewComplete(p_item_type		IN VARCHAR2,
		       	   p_item_key		IN VARCHAR2,
		       	   p_actid		IN NUMBER,
		       	   p_funmode		IN VARCHAR2,
		       	   p_result	 OUT NOCOPY VARCHAR2);

PROCEDURE AnyAPAdjustments(p_item_type		IN VARCHAR2,
		       	   p_item_key		IN VARCHAR2,
		       	   p_actid		IN NUMBER,
		       	   p_funmode		IN VARCHAR2,
		       	   p_result	 OUT NOCOPY VARCHAR2);

PROCEDURE AllPassAPApproval(p_item_type		IN VARCHAR2,
		       	   	 p_item_key		IN VARCHAR2,
		       	   	 p_actid		IN NUMBER,
		       	   	 p_funmode		IN VARCHAR2,
		       	   	 p_result	 OUT NOCOPY VARCHAR2);

PROCEDURE Approved(p_item_type		IN VARCHAR2,
		   p_item_key		IN VARCHAR2,
		   p_actid		IN NUMBER,
		   p_funmode		IN VARCHAR2,
		   p_result	 OUT NOCOPY VARCHAR2);

PROCEDURE SplitExpenseReport(p_item_type	IN VARCHAR2,
		   	     p_item_key		IN VARCHAR2,
		   	     p_actid		IN NUMBER,
		   	     p_funmode		IN VARCHAR2,
		   	     p_result	 OUT NOCOPY VARCHAR2);

PROCEDURE DeleteExpenseReport(p_item_type	IN VARCHAR2,
		   	      p_item_key	IN VARCHAR2,
		   	      p_actid		IN NUMBER,
		   	      p_funmode		IN VARCHAR2,
		   	      p_result	 OUT NOCOPY VARCHAR2);

/*PROCEDURE StartAPApprvlSubProcess(p_item_type	IN VARCHAR2,
		   	      	  p_item_key	IN VARCHAR2,
		   	      	  p_actid	IN NUMBER,
		   	      	  p_funmode	IN VARCHAR2,
		   	      	  p_result OUT NOCOPY VARCHAR2);

PROCEDURE StartManagerApprvlSubProcess(p_item_type	IN VARCHAR2,
		   	      	  p_item_key	IN VARCHAR2,
		   	      	  p_actid	IN NUMBER,
		   	      	  p_funmode	IN VARCHAR2,
		   	      	  p_result OUT NOCOPY VARCHAR2);
*/

PROCEDURE GetPreparerManager(p_item_type	IN VARCHAR2,
		     	     p_item_key		IN VARCHAR2,
		     	     p_actid		IN NUMBER,
		     	     p_funmode		IN VARCHAR2,
		     	     p_result	 OUT NOCOPY VARCHAR2);

PROCEDURE GetApproverManager(p_item_type	IN VARCHAR2,
		     	     p_item_key		IN VARCHAR2,
		     	     p_actid		IN NUMBER,
		     	     p_funmode		IN VARCHAR2,
		     	     p_result	 OUT NOCOPY VARCHAR2);

PROCEDURE ApproverProvided(p_item_type	IN VARCHAR2,
		     	   p_item_key	IN VARCHAR2,
		     	   p_actid	IN NUMBER,
		     	   p_funmode	IN VARCHAR2,
		     	   p_result OUT NOCOPY VARCHAR2);

PROCEDURE SameCostCenters(p_item_type	IN VARCHAR2,
		     	  p_item_key	IN VARCHAR2,
		     	  p_actid	IN NUMBER,
		     	  p_funmode	IN VARCHAR2,
		     	  p_result OUT NOCOPY VARCHAR2);

PROCEDURE SetApproverEqualManager(p_item_type	IN VARCHAR2,
		     	  	     p_item_key		IN VARCHAR2,
		     	  	     p_actid		IN NUMBER,
		     	  	     p_funmode		IN VARCHAR2,
		     	  	     p_result	 OUT NOCOPY VARCHAR2);

PROCEDURE RecordForwardFromInfo(p_item_type	IN VARCHAR2,
		     	  	     p_item_key		IN VARCHAR2,
		     	  	     p_actid		IN NUMBER,
		     	  	     p_funmode		IN VARCHAR2,
		     	  	     p_result	 OUT NOCOPY VARCHAR2);

PROCEDURE ManagerNotEqualToApprover(p_item_type		IN VARCHAR2,
		     	  	    p_item_key		IN VARCHAR2,
		     	  	    p_actid		IN NUMBER,
		     	  	    p_funmode		IN VARCHAR2,
		     	  	    p_result	 OUT NOCOPY VARCHAR2);

PROCEDURE NotifyPreparer(p_item_type		IN VARCHAR2,
		     	  p_item_key		IN VARCHAR2,
		     	  p_actid		IN NUMBER,
		     	  p_funmode		IN VARCHAR2,
		     	  p_result	 OUT NOCOPY VARCHAR2);

PROCEDURE OpenExp(p1    varchar2,
		  p2	varchar2,
		  p11   varchar2 Default NULL);


PROCEDURE SetPersonAs(p_manager_id 	IN NUMBER,
                      p_item_type	IN VARCHAR2,
		      p_item_key	IN VARCHAR2,
		      p_manager_target	IN VARCHAR2);

PROCEDURE GetManager(p_employee_id 	IN  HR_EMPLOYEES_CURRENT_V.employee_id%TYPE,
                     p_manager_id OUT NOCOPY HR_EMPLOYEES_CURRENT_V.employee_id%TYPE);

-- 3257576 added new parameters p_error_message, p_instructions,
-- p_special_instr
PROCEDURE GetFinalApprover(p_employee_id		IN NUMBER,
                           p_override_approver_id	IN NUMBER,
		      	   p_emp_cost_center		IN VARCHAR2,
		      	   p_doc_cost_center		IN VARCHAR2,
		      	   p_approval_amount		IN NUMBER,
			   p_item_key			IN VARCHAR2,
			   p_item_type			IN VARCHAR2,
		      	   p_final_approver_id	 OUT NOCOPY NUMBER,
		      	   p_error_message	 OUT NOCOPY VARCHAR2,
                           p_instructions        OUT NOCOPY VARCHAR2,
                           p_special_instr       OUT NOCOPY VARCHAR2);

PROCEDURE AMEEnabled(p_item_type	IN VARCHAR2,
		     	p_item_key	IN VARCHAR2,
		     	p_actid		IN NUMBER,
		     	p_funmode	IN VARCHAR2,
		     	p_result OUT NOCOPY VARCHAR2);

PROCEDURE FirstApprover(p_item_type	IN VARCHAR2,
		     	p_item_key	IN VARCHAR2,
		     	p_actid		IN NUMBER,
		     	p_funmode	IN VARCHAR2,
		     	p_result OUT NOCOPY VARCHAR2);

PROCEDURE ResetEmpCostCenter(p_item_type IN VARCHAR2,
		     	     p_item_key	 IN VARCHAR2,
		     	     p_actid	 IN NUMBER,
		     	     p_funmode	 IN VARCHAR2,
		     	     p_result	 OUT NOCOPY VARCHAR2);

PROCEDURE ApprovalForwarded(p_item_type	IN VARCHAR2,
		     	    p_item_key	IN VARCHAR2,
		     	    p_actid	IN NUMBER,
		     	    p_funmode	IN VARCHAR2,
		     	    p_result OUT NOCOPY VARCHAR2);

PROCEDURE PayablesReviewed(p_item_type	IN VARCHAR2,
		     	   p_item_key	IN VARCHAR2,
		     	   p_actid	IN NUMBER,
		     	   p_funmode	IN VARCHAR2,
		     	   p_result OUT NOCOPY VARCHAR2);

PROCEDURE EmployeeEqualsToPreparer(p_item_type   IN VARCHAR2,
                           	   p_item_key    IN VARCHAR2,
                                   p_actid       IN NUMBER,
                          	   p_funmode     IN VARCHAR2,
                          	   p_result      OUT NOCOPY VARCHAR2);

PROCEDURE EmployeeApprovalRequired(p_item_type      IN VARCHAR2,
                       		   p_item_key       IN VARCHAR2,
                       		   p_actid          IN NUMBER,
                       		   p_funmode        IN VARCHAR2,
                       		   p_result         OUT NOCOPY VARCHAR2);

PROCEDURE DetermineStartFromProcess(p_item_type	IN VARCHAR2,
		     	   p_item_key	IN VARCHAR2,
		     	   p_actid	IN NUMBER,
		     	   p_funmode	IN VARCHAR2,
		     	   p_result OUT NOCOPY VARCHAR2);

PROCEDURE SetRejectStatusAndResetAttr(p_item_type      IN VARCHAR2,
                          p_item_key       IN VARCHAR2,
                          p_actid          IN NUMBER,
                          p_funmode        IN VARCHAR2,
                          p_result         OUT NOCOPY VARCHAR2);

PROCEDURE SetEmployeeAsApprover(p_item_type	IN VARCHAR2,
		       	  p_item_key	IN VARCHAR2,
		     	  p_actid	IN NUMBER,
		     	  p_funmode	IN VARCHAR2,
		     	  p_result OUT NOCOPY VARCHAR2);

PROCEDURE MissingReceiptShortPay(p_item_type		IN VARCHAR2,
		   		 p_item_key		IN VARCHAR2,
		   		 p_actid		IN NUMBER,
		   		 p_funmode		IN VARCHAR2,
		   		 p_result	 OUT NOCOPY VARCHAR2);

PROCEDURE PolicyViolationShortPay(p_item_type		IN VARCHAR2,
		   		  p_item_key		IN VARCHAR2,
		   		  p_actid		IN NUMBER,
		   		  p_funmode		IN VARCHAR2,
		   		  p_result	 OUT NOCOPY VARCHAR2);

PROCEDURE StartFromAPApproval(p_item_type	IN VARCHAR2,
		   	      p_item_key	IN VARCHAR2,
		   	      p_actid		IN NUMBER,
		   	      p_funmode		IN VARCHAR2,
		   	      p_result	 OUT NOCOPY VARCHAR2);

PROCEDURE StartFromManagerApproval(p_item_type	IN VARCHAR2,
		   	      p_item_key	IN VARCHAR2,
		   	      p_actid		IN NUMBER,
		   	      p_funmode		IN VARCHAR2,
		   	      p_result	 OUT NOCOPY VARCHAR2);

PROCEDURE StartPolicyShortPayProcess(p_item_type 	 IN VARCHAR2,
		   	      	        p_item_key	 IN VARCHAR2,
		   	      	        p_actid	 	 IN NUMBER,
		   	      	        p_funmode	 IN VARCHAR2,
		   	      	        p_result	 OUT NOCOPY VARCHAR2);

PROCEDURE StartNoReceiptsShortPayProcess(p_item_type 	 IN VARCHAR2,
		   	      	        p_item_key	 IN VARCHAR2,
		   	      	        p_actid	 	 IN NUMBER,
		   	      	        p_funmode	 IN VARCHAR2,
		   	      	        p_result	 OUT NOCOPY VARCHAR2);


PROCEDURE CheckIfShortPaid(p_item_type	IN VARCHAR2,
		   	         p_item_key	IN VARCHAR2,
		   	         p_actid		IN NUMBER,
		   	         p_funmode	IN VARCHAR2,
		   	         p_result OUT NOCOPY VARCHAR2);


PROCEDURE RequireProofOfPayment(p_item_type	IN VARCHAR2,
		       	  	p_item_key	IN VARCHAR2,
		     	  	p_actid		IN NUMBER,
		     	  	p_funmode	IN VARCHAR2,
		     	  	p_result OUT NOCOPY VARCHAR2);

PROCEDURE GenerateExpLines(document_id		IN VARCHAR2,
				display_type	IN VARCHAR2,
				document	IN OUT NOCOPY VARCHAR2,
				document_type	IN OUT NOCOPY VARCHAR2);

PROCEDURE GenerateDocumentAttributeValue(document_id		IN VARCHAR2,
				display_type	IN VARCHAR2,
				document	IN OUT NOCOPY VARCHAR2,
				document_type	IN OUT NOCOPY VARCHAR2);

PROCEDURE GenerateAdjustmentInfo(document_id    IN VARCHAR2,
			   display_type		IN VARCHAR2,
			   document	        IN OUT NOCOPY VARCHAR2,
			   document_type	IN OUT NOCOPY VARCHAR2);

PROCEDURE GenerateAdjustmentInfoClob(document_id    IN VARCHAR2,
 	                     display_type                IN VARCHAR2,
 	                     document                IN OUT NOCOPY CLOB,
 	                     document_type        IN OUT NOCOPY VARCHAR2);

PROCEDURE ResetLineInfo(document_id	IN VARCHAR2,
			display_type	IN VARCHAR2,
			document	IN OUT NOCOPY VARCHAR2,
			document_type	IN OUT NOCOPY VARCHAR2);

PROCEDURE CallbackFunction(	p_s_item_type      IN VARCHAR2,
                          	p_s_item_key       IN VARCHAR2,
                          	p_n_actid          IN NUMBER,
                          	p_s_command        IN VARCHAR2,
                          	p_s_result         OUT NOCOPY VARCHAR2);

PROCEDURE IsPreparerToAuditorTransferred(
                                p_item_type      IN VARCHAR2,
                                p_item_key       IN VARCHAR2,
                                p_actid          IN NUMBER,
                                p_funmode        IN VARCHAR2,
                                p_result         OUT NOCOPY VARCHAR2);

PROCEDURE IsApprovalRequestTransferred(
                                p_item_type      IN VARCHAR2,
                                p_item_key       IN VARCHAR2,
                                p_actid          IN NUMBER,
                                p_funmode        IN VARCHAR2,
                                p_result         OUT NOCOPY VARCHAR2);

PROCEDURE CheckWFAdminNote(
                                p_item_type      IN VARCHAR2,
                                p_item_key       IN VARCHAR2,
                                p_actid          IN NUMBER,
                                p_funmode        IN VARCHAR2,
                                p_result         OUT NOCOPY VARCHAR2);

PROCEDURE SetReturnStatusAndResetAttr(p_item_type      IN VARCHAR2,
                          p_item_key       IN VARCHAR2,
                          p_actid          IN NUMBER,
                          p_funmode        IN VARCHAR2,
                          p_result         OUT NOCOPY VARCHAR2);

PROCEDURE SetFromRoleBeforeApproval(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2);

PROCEDURE SetFromRolePreparer(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2);

PROCEDURE SetFromRoleEmployee(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2);

PROCEDURE SetFromRoleForwardFrom(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2);

PROCEDURE SetFromRoleApprover(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2);

PROCEDURE SetStatusApproverAndDate(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2);

PROCEDURE ZeroFindApproverCount(p_item_type	IN VARCHAR2,
		  p_item_key	IN VARCHAR2,
		  p_actid	IN NUMBER,
		  p_funmode	IN VARCHAR2,
		  p_result OUT NOCOPY VARCHAR2);

--ER 1552747 - withdraw expense report
PROCEDURE WithdrawExpenseRep(
   p_rep_header_id IN AP_EXPENSE_REPORT_LINES.report_header_id%TYPE);

PROCEDURE GenerateExpClobLines(document_id	IN VARCHAR2,
				display_type	IN VARCHAR2,
				document	IN OUT NOCOPY CLOB,
				document_type	IN OUT NOCOPY VARCHAR2);

---------------------------------------------------------
PROCEDURE determineMileageAdjusted(p_item_type  IN VARCHAR2,
			          p_item_key   IN VARCHAR2,
				  p_actid      IN NUMBER,
				  p_funmode    IN VARCHAR2,
				  p_result     OUT NOCOPY VARCHAR2);

---------------------------------------------------------
PROCEDURE getScheduleLineArray(
		p_report_header_id		IN NUMBER,
		p_distribution_line_number	IN NUMBER,
		p_employee_id			IN NUMBER,
		p_cumulative_mileage		IN NUMBER,
		p_schedule_line_array	 OUT NOCOPY AP_WEB_DB_SCHLINE_PKG.Schedule_Line_Array);
---------------------------------------------------------

PROCEDURE updateCumulativeMileage(
	p_cumulative_mileage	IN AP_WEB_EMPLOYEE_INFO.NUMERIC_VALUE%TYPE,
	p_period_id		IN AP_WEB_EMPLOYEE_INFO.PERIOD_ID%TYPE,
	p_employee_id		IN AP_WEB_EMPLOYEE_INFO.EMPLOYEE_ID%TYPE);

---------------------------------------------------------
FUNCTION getRate(
	p_sh_distance_uom	   IN AP_POL_HEADERS.distance_uom%TYPE,
	p_sh_currency_code	   IN AP_POL_HEADERS.currency_code%TYPE,
	p_mileage_line		   IN AP_WEB_DB_EXPLINE_PKG.Mileage_Line_Rec,
	p_schedule_line		   IN AP_WEB_DB_SCHLINE_PKG.Schedule_Line_Rec)
RETURN NUMBER;

---------------------------------------------------------
PROCEDURE copyMileageArray(
	p_from_array		IN AP_WEB_DB_EXPLINE_PKG.Mileage_Line_Array,
	p_to_array	 OUT NOCOPY AP_WEB_DB_EXPLINE_PKG.Mileage_Line_Array);

---------------------------------------------------------
PROCEDURE addToMileageArray(
	p_index			IN NUMBER,
	p_new_dist_number	IN AP_EXPENSE_REPORT_LINES.distribution_line_number%TYPE,
	p_trip_dist		IN AP_EXPENSE_REPORT_LINES.TRIP_DISTANCE%TYPE,
	p_daily_distance	IN AP_EXPENSE_REPORT_LINES.DAILY_DISTANCE%TYPE,
	p_rate			IN AP_EXPENSE_REPORT_LINES.avg_mileage_rate%TYPE,
	p_report_header_id	IN AP_EXPENSE_REPORT_LINES.report_header_id%TYPE,
	p_from_index		IN AP_EXPENSE_REPORT_LINES.distribution_line_number%TYPE,
	p_mileage_line_array	IN OUT NOCOPY AP_WEB_DB_EXPLINE_PKG.Mileage_Line_Array);

---------------------------------------------------------
PROCEDURE updateNewDistNumber(
	p_index			IN NUMBER,
	p_last_index		IN NUMBER,
	p_added_total		IN NUMBER,
	p_mileage_line_array	IN OUT NOCOPY AP_WEB_DB_EXPLINE_PKG.Mileage_Line_Array);

---------------------------------------------------------
PROCEDURE processCrossThreshold(
	p_ml_index		   IN NUMBER,
	p_sh_distance_uom	   IN AP_POL_HEADERS.DISTANCE_UOM%TYPE,
	p_sh_currency_code	   IN AP_POL_HEADERS.CURRENCY_CODE%TYPE,
	p_schedule_line_array	   IN AP_WEB_DB_SCHLINE_PKG.Schedule_Line_Array,
	p_mileage_line_array_count IN OUT NOCOPY NUMBER,
	p_cumulative_mileage	   IN OUT NOCOPY AP_WEB_EMPLOYEE_INFO.NUMERIC_VALUE%TYPE,
	p_mileage_line_array	   IN OUT NOCOPY AP_WEB_DB_EXPLINE_PKG.Mileage_Line_Array);

---------------------------------------------------------
PROCEDURE ProcessMileageLines(p_item_type 	IN VARCHAR2,
			     p_item_key		IN VARCHAR2,
			     p_actid		IN NUMBER,
			     p_funmode		IN VARCHAR2,
			     p_result	 OUT NOCOPY VARCHAR2);

---------------------------------------------------------
PROCEDURE hasCompanyViolations( p_item_type  IN VARCHAR2,
			       p_item_key   IN VARCHAR2,
			       p_actid      IN NUMBER,
			       p_funmode    IN VARCHAR2,
			       p_result     OUT NOCOPY VARCHAR2);
---------------------------------------------------------

-------------------------------------------------------------------------------
PROCEDURE AddToHeaderErrors(p_item_type            IN  VARCHAR2,
                            p_item_key             IN  VARCHAR2,
                            p_header_error         IN  VARCHAR2);
-------------------------------------------------------------------------------
PROCEDURE GenerateHeaderErrors(document_id		IN VARCHAR2,
				display_type	IN VARCHAR2,
				document	IN OUT NOCOPY VARCHAR2,
				document_type	IN OUT NOCOPY VARCHAR2);
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
PROCEDURE GenerateAmountMsg(document_id		IN VARCHAR2,
				display_type	IN VARCHAR2,
				document	IN OUT NOCOPY VARCHAR2,
				document_type	IN OUT NOCOPY VARCHAR2);

-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
PROCEDURE GetRespAppInfo(p_item_key         IN VARCHAR2,
                         p_resp_id          OUT NOCOPY NUMBER,
                         P_appl_id          OUT NOCOPY NUMBER);
-------------------------------------------------------------------------------

---------------------------------------------------------
PROCEDURE GetAuditType( p_item_type  IN VARCHAR2,
			p_item_key   IN VARCHAR2,
			p_actid      IN NUMBER,
			p_funmode    IN VARCHAR2,
			p_result     OUT NOCOPY VARCHAR2);
---------------------------------------------------------

---------------------------------------------------------
PROCEDURE ResetWFNote(p_item_type      IN VARCHAR2,
                      p_item_key       IN VARCHAR2,
                      p_actid          IN NUMBER,
                      p_funmode        IN VARCHAR2,
                      p_result         OUT NOCOPY VARCHAR2);
---------------------------------------------------------

PROCEDURE AddToOtherErrors(p_item_type            IN  VARCHAR2,
                            p_item_key             IN  VARCHAR2,
                            p_other_error         IN  VARCHAR2);
-------------------------------------------------------------------------------

/**
 * jrautiai ADJ Fix start
 */

/**
 * Setting the from field to AP. Used for adjustment and shortpay notifications.
 */
PROCEDURE SetFromRoleAP(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2);

/**
 * Build the policy violation message, this is used to detect whether
 * we are building a policy or missing receipt notification.
 */
PROCEDURE SetPolicyInfo(p_item_type		IN VARCHAR2,
		   	p_item_key		IN VARCHAR2,
		   	p_actid			IN NUMBER,
		   	p_funmode		IN VARCHAR2,
		   	p_result	 OUT NOCOPY VARCHAR2);

/**
 * Build the missing receipts message, this is used to detect whether
 * we are building a policy or missing receipt notification.
 */
PROCEDURE SetMissingReceiptInfo(p_item_type		IN VARCHAR2,
                                p_item_key		IN VARCHAR2,
                                p_actid			IN NUMBER,
                                p_funmode		IN VARCHAR2,
                                p_result	 OUT NOCOPY VARCHAR2);

/**
 * This procedure was modified with adding a parameter indicating the notification type.
 * This is called by the wrappers above.
 */
PROCEDURE SetShortPaidLinesInfo(p_item_type		IN VARCHAR2,
	                        p_item_key		IN VARCHAR2,
		   		p_actid			IN NUMBER,
		   		p_funmode		IN VARCHAR2,
		   		p_notification_type     IN VARCHAR2,
		   		p_result	 OUT NOCOPY VARCHAR2);

/**
 * Build the provide missing info to AP message.
 */
PROCEDURE SetProvideMissingInfo(p_item_type		IN VARCHAR2,
                                p_item_key		IN VARCHAR2,
                                p_actid	                IN NUMBER,
                                p_funmode		IN VARCHAR2,
                                p_result	 OUT NOCOPY VARCHAR2);
------------------------------------------------------------------------

/**
 * Moved the constants to the package specification, so they are visible for other packages too.
 */
C_BothPay			CONSTANT VARCHAR2(10) := 'BOTH';
C_CompanyPay			CONSTANT VARCHAR2(10) := 'COMPANY';
C_IndividualPay			CONSTANT VARCHAR2(10) := 'INDIVIDUAL';

PROCEDURE ResetShortpayAdjustmentInfo(p_item_type  IN VARCHAR2,
                                      p_item_key   IN VARCHAR2,
                                      p_actid      IN NUMBER,
                                      p_funmode    IN VARCHAR2,
                                      p_result     OUT NOCOPY VARCHAR2);

/**
 * jrautiai ADJ Fix end
 */

------------------------------------------------------------------------
PROCEDURE CheckAPReviewResult(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2);
------------------------------------------------------------------------

------------------------------------------------------------------------
PROCEDURE AddToAuditQueue(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2);
------------------------------------------------------------------------

------------------------------------------------------------------------
PROCEDURE RemoveFromAuditQueue(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       OUT NOCOPY VARCHAR2);
------------------------------------------------------------------------

------------------------------------------------------------------------
PROCEDURE StoreNote(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       IN OUT NOCOPY VARCHAR2);
------------------------------------------------------------------------


--Notification Esc :
-----------------------------------------------------------------------
procedure GetJobLevelAndSupervisor(
                                 p_personId IN NUMBER,
                                 p_jobLevel OUT NOCOPY NUMBER);
------------------------------------------------------------------------

------------------------------------------------------------------------
PROCEDURE IsEmployeeTerminated(p_item_type        IN VARCHAR2,
                       p_item_key       IN VARCHAR2,
                       p_actid          IN NUMBER,
                       p_funmode        IN VARCHAR2,
                       p_result  OUT NOCOPY VARCHAR2);
------------------------------------------------------------------------
------------------------------------------------------------------------
PROCEDURE IsEmployeeActive(p_item_type        IN VARCHAR2,
                       p_item_key       IN VARCHAR2,
                       p_actid          IN NUMBER,
                       p_funmode        IN VARCHAR2,
                       p_result  OUT NOCOPY VARCHAR2);
------------------------------------------------------------------------

------------------------------------------------------------------------
PROCEDURE IsManagerActive(p_item_type        IN VARCHAR2,
                       p_item_key       IN VARCHAR2,
                       p_actid          IN NUMBER,
                       p_funmode        IN VARCHAR2,
                       p_result  OUT NOCOPY VARCHAR2);
------------------------------------------------------------------------


-- 3257576 - Gets the manager info and sets p_error_message, p_instructions
-- p_special_instr if manager is terminated or does not exist or is suspended
------------------------------------------------------------------------
PROCEDURE GetManagerInfoAndCheckStatus(
    p_employee_id		    IN 	NUMBER,
    p_employee_name		    IN 	VARCHAR2,
    p_manager_id            OUT NOCOPY NUMBER,
    p_manager_name          OUT NOCOPY VARCHAR2,
    p_manager_status        OUT NOCOPY VARCHAR2,
    p_error_message         OUT NOCOPY VARCHAR2,
    p_instructions          OUT NOCOPY VARCHAR2,
    p_special_instr         OUT NOCOPY VARCHAR2
);
------------------------------------------------------------------------

--Bug 3389386
------------------------------------------------------------------------
Procedure  SetExpenseStatusCode(p_report_header_id IN Number);
------------------------------------------------------------------------

--Bug 2777245
------------------------------------------------------------------------
Procedure UpdateHeaderLines(
                            p_report_header_id IN Number);
------------------------------------------------------------------------

------------------------------------------------------------------------
Procedure RaiseSubmitEvent(
                            p_report_header_id IN Number,
                            p_workflow_appr_flag IN VARCHAR2);
------------------------------------------------------------------------
------------------------------------------------------------------------
PROCEDURE InitSubmit(
                                 p_item_type    IN VARCHAR2,
                                 p_item_key     IN VARCHAR2,
                                 p_actid        IN NUMBER,
                                 p_funmode      IN VARCHAR2,
                                 p_result       IN OUT NOCOPY VARCHAR2);
------------------------------------------------------------------------

------------------------------------------------------------------------
FUNCTION CheckAccess(
                     p_ntf_id    IN NUMBER,
                     p_item_key  IN NUMBER,
                     p_user_name IN VARCHAR2) RETURN VARCHAR2;
------------------------------------------------------------------------

PROCEDURE AMERequestApproval(p_item_type        IN VARCHAR2,
                       p_item_key       IN VARCHAR2,
                       p_actid          IN NUMBER,
                       p_funmode        IN VARCHAR2,
                       p_result  OUT NOCOPY VARCHAR2);

PROCEDURE AMEGetApprovalType(p_item_type	IN VARCHAR2,
		       p_item_key	IN VARCHAR2,
		       p_actid		IN NUMBER,
		       p_funmode	IN VARCHAR2,
		       p_result	 OUT NOCOPY VARCHAR2);

PROCEDURE AMEPropagateApprovalResult(p_item_type	IN VARCHAR2,
		       p_item_key	IN VARCHAR2,
		       p_actid		IN NUMBER,
		       p_funmode	IN VARCHAR2,
		       p_result	 OUT NOCOPY VARCHAR2);

PROCEDURE AMEGetApprovalResult(p_item_type	IN VARCHAR2,
		       p_item_key	IN VARCHAR2,
		       p_actid		IN NUMBER,
		       p_funmode	IN VARCHAR2,
		       p_result	 OUT NOCOPY VARCHAR2);

PROCEDURE AMECompleteApproval(p_item_type	IN VARCHAR2,
		       p_item_key	IN VARCHAR2,
		       p_actid		IN NUMBER,
		       p_funmode	IN VARCHAR2,
		       p_result	 OUT NOCOPY VARCHAR2);

PROCEDURE AMESetCurrentApprover(p_item_type	IN VARCHAR2,
		       p_item_key	IN VARCHAR2,
		       p_actid		IN NUMBER,
		       p_funmode	IN VARCHAR2,
		       p_result	 OUT NOCOPY VARCHAR2);

FUNCTION IsExpAccountsUpdated(p_report_line_id	IN NUMBER) RETURN VARCHAR2;

FUNCTION getItemKey(p_notification_id	IN NUMBER) RETURN VARCHAR2;

------------------------------------------------------------------------
PROCEDURE IsPreparerActive(p_item_type        IN VARCHAR2,
                       p_item_key       IN VARCHAR2,
                       p_actid          IN NUMBER,
                       p_funmode        IN VARCHAR2,
                       p_result  OUT NOCOPY VARCHAR2);
------------------------------------------------------------------------

------------------------------------------------------------------------
PROCEDURE WaitForImagedReceipts(p_item_type      IN VARCHAR2,
                       p_item_key       IN VARCHAR2,
                       p_actid          IN NUMBER,
                       p_funmode        IN VARCHAR2,
                       p_result  OUT NOCOPY VARCHAR2);
------------------------------------------------------------------------

------------------------------------------------------------------------
PROCEDURE CompleteReceiptsBlock(p_report_header_id IN VARCHAR2);
------------------------------------------------------------------------

----------------------------------------------------------------------
PROCEDURE CheckForManagerReApproval(p_item_type      IN VARCHAR2,
                       p_item_key       IN VARCHAR2,
                       p_actid          IN NUMBER,
                       p_funmode        IN VARCHAR2,
                       p_result  OUT NOCOPY VARCHAR2);
----------------------------------------------------------------------

----------------------------------------------------------------------
PROCEDURE SetImageReceiptsStatus(p_item_type      IN VARCHAR2,
                       p_item_key       IN VARCHAR2,
                       p_actid          IN NUMBER,
                       p_funmode        IN VARCHAR2,
                       p_result  OUT NOCOPY VARCHAR2);
----------------------------------------------------------------------

----------------------------------------------------------------------
PROCEDURE SetOriginalReceiptsStatus(p_item_type      IN VARCHAR2,
                       p_item_key       IN VARCHAR2,
                       p_actid          IN NUMBER,
                       p_funmode        IN VARCHAR2,
                       p_result  OUT NOCOPY VARCHAR2);
----------------------------------------------------------------------

----------------------------------------------------------------------
PROCEDURE UpdateExpenseStatusCode(p_item_type      IN VARCHAR2,
                       p_item_key       IN VARCHAR2,
                       p_actid          IN NUMBER,
                       p_funmode        IN VARCHAR2,
                       p_result  OUT NOCOPY VARCHAR2);
----------------------------------------------------------------------

----------------------------------------------------------------------
PROCEDURE CheckShortPayRecptType(p_item_type      IN VARCHAR2,
                       p_item_key       IN VARCHAR2,
                       p_actid          IN NUMBER,
                       p_funmode        IN VARCHAR2,
                       p_result  OUT NOCOPY VARCHAR2);
----------------------------------------------------------------------

-------------------------------------------------------------------------------------
FUNCTION GetImageMissingJustification(p_report_header_id IN NUMBER) RETURN VARCHAR2;
--------------------------------------------------------------------------------------

END AP_WEB_EXPENSE_WF;

/
