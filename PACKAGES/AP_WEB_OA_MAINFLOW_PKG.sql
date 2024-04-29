--------------------------------------------------------
--  DDL for Package AP_WEB_OA_MAINFLOW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_OA_MAINFLOW_PKG" AUTHID CURRENT_USER AS
/* $Header: apwoamfs.pls 120.41.12010000.2 2008/08/06 10:17:47 rveliche ship $ */

SUBTYPE expLines_currCode		IS AP_EXPENSE_REPORT_LINES.currency_code%TYPE;
SUBTYPE expLines_expOrgID		IS AP_EXPENSE_REPORT_LINES.expenditure_organization_id%TYPE;
SUBTYPE expHdr_headerID 		IS AP_EXPENSE_REPORT_HEADERS.report_header_id%TYPE;


TYPE PARAM_TBL_TYPE IS TABLE OF NUMBER
  INDEX BY BINARY_INTEGER;

TYPE CONCATENATED_TBL_TYPE IS TABLE OF VARCHAR2(2000)
  INDEX BY BINARY_INTEGER;


G_RET_STS_SUCCESS       CONSTANT    VARCHAR2(1) :=  'S';
G_RET_STS_ERROR         CONSTANT    VARCHAR2(1) :=  'E';
G_RET_STS_UNEXP_ERROR   CONSTANT    VARCHAR2(1) :=  'U';

G_EXC_ERROR             EXCEPTION;
G_EXC_UNEXPECTED_ERROR  EXCEPTION;

PROCEDURE DeleteExpenseReport(
  ReportID             IN expHdr_headerID);


PROCEDURE GetEmployeeIdFromBothPayParent(
                          p_bothpay_parent_id         IN      NUMBER,
                          p_employee_id               OUT NOCOPY     NUMBER);

PROCEDURE GetEmployeeInfo(
			  p_employee_id			IN	NUMBER,
			  p_employee_name	 OUT NOCOPY VARCHAR2,
			  p_employee_num	 OUT NOCOPY VARCHAR2,
			  p_cost_center		 OUT NOCOPY  	VARCHAR2,
			  p_is_project_enabled	 OUT NOCOPY  	VARCHAR2,
			  p_default_reimb_currency_code OUT NOCOPY VARCHAR2,
			  p_is_cc_enabled	 OUT NOCOPY     VARCHAR2,
                          p_max_num_segments            OUT NOCOPY     NUMBER,
                          p_userId                      OUT NOCOPY     VARCHAR2
			  );

PROCEDURE GetGeneralInfo(
                          p_preparer_id                         IN      NUMBER,
                          p_default_expense_template_id         OUT NOCOPY     NUMBER,
                          p_default_approver_name               OUT NOCOPY     VARCHAR2,
                          p_default_purpose                     OUT NOCOPY     VARCHAR2,
                          p_default_validate_detail_page        OUT NOCOPY     VARCHAR2,
                          p_default_skip_cc_if_no_trxn          OUT NOCOPY     VARCHAR2,
                          p_default_foreign_curr_flag           OUT NOCOPY     VARCHAR2,
                          p_set_of_books_id                     OUT NOCOPY     NUMBER,
			  p_is_grants_enabled		 OUT NOCOPY     VARCHAR2
                          );

FUNCTION IsGrantsEnabled RETURN VARCHAR2;

PROCEDURE ValidateReportHeader(
    		report_header_id		IN 	VARCHAR2,
    		employee_id		      	IN 	VARCHAR2,
    		cost_center		      	IN 	VARCHAR2,
    		template_id	      		IN 	VARCHAR2,
    		template_name			IN 	VARCHAR2,
    		purpose		      		IN 	VARCHAR2,
    		summary_start_date		IN 	VARCHAR2,
    		last_receipt_date		IN 	VARCHAR2,
    		reimbursement_currency_code	IN 	VARCHAR2,
    		reimbursement_currency_name	IN 	VARCHAR2,
    		multi_currency_flag		IN 	VARCHAR2,
    		override_approver_id		IN OUT NOCOPY VARCHAR2,
    		override_approver_name		IN OUT NOCOPY VARCHAR2,
    		number_max_flexfield		IN 	VARCHAR2,
    		amt_due_employee		IN 	VARCHAR2,
    		amt_due_ccCompany		IN 	VARCHAR2,
		p_IsSessionProjectEnabled	IN 	VARCHAR2,
		p_return_status		 OUT NOCOPY VARCHAR2,
		p_msg_count		 OUT NOCOPY 	NUMBER,
		p_msg_data		 OUT NOCOPY 	VARCHAR2);

PROCEDURE ValidateReceiptLine(
    		employee_id		      	IN 	VARCHAR2,
    		template_id	      		IN 	VARCHAR2,
    		summary_start_date		IN 	VARCHAR2,
    		reimbursement_currency_code	IN 	VARCHAR2,
    		reimbursement_currency_name	IN 	VARCHAR2,
    		multi_currency_flag		IN 	VARCHAR2,
   		override_approver_name		IN 	VARCHAR2,
    		number_max_flexfield		IN 	VARCHAR2,
    		start_date			IN	DATE,
    		end_date			IN      DATE,
    		days				IN      VARCHAR2,
    		daily_amount			IN      NUMBER,
    		receipt_amount			IN      NUMBER,
    		rate				IN      VARCHAR2,
    		amount				IN      NUMBER,
    		parameter_id			IN      VARCHAR2,
    		currency_code			IN      VARCHAR2,
    		merchant                        IN      VARCHAR2,
    		merchantDoc                     IN      VARCHAR2,
    		taxReference                    IN      VARCHAR2,
    		taxRegNumber                    IN      VARCHAR2,
    		taxPayerId                      IN      VARCHAR2,
    		supplyCountry                   IN      VARCHAR2,
    		itemizeId                       IN      VARCHAR2,
    		cCardTrxnId                     IN      VARCHAR2,
    		group_value			IN      VARCHAR2,
    		justification			IN OUT  NOCOPY VARCHAR2,
    		receipt_missing_flag		IN      VARCHAR2,
    		validation_required		IN      VARCHAR2,
    		taxOverrideFlag			IN      VARCHAR2,
    		project_number                  IN      VARCHAR2,
    		task_number                     IN      VARCHAR2,
		project_name		 OUT NOCOPY     VARCHAR2,
		task_name		 OUT NOCOPY     VARCHAR2,
		attribute1			IN      VARCHAR2,
		attribute2			IN      VARCHAR2,
		attribute3			IN      VARCHAR2,
		attribute4			IN      VARCHAR2,
		attribute5			IN      VARCHAR2,
		attribute6			IN      VARCHAR2,
		attribute7			IN      VARCHAR2,
		attribute8			IN      VARCHAR2,
		attribute9			IN      VARCHAR2,
		attribute10			IN      VARCHAR2,
		attribute11			IN      VARCHAR2,
		attribute12			IN      VARCHAR2,
		attribute13			IN      VARCHAR2,
		attribute14			IN      VARCHAR2,
		attribute15			IN      VARCHAR2,
		p_IsSessionTaxEnabled		IN	VARCHAR2,
		p_IsSessionProjectEnabled	IN 	VARCHAR2,
		p_calculate_amt_index		IN	INTEGER,
		p_calculated_receipt_amount     OUT NOCOPY     VARCHAR2,
		p_return_status		 OUT NOCOPY VARCHAR2,
		p_msg_count		 OUT NOCOPY NUMBER,
		p_msg_data		 OUT NOCOPY VARCHAR2,
    		p_userId		      	IN 	VARCHAR2,
	        award_number			IN	VARCHAR2,
                p_cost_center                   IN      VARCHAR2,
                p_template_name                 IN      VARCHAR2,--Bug 2510993
                p_purpose                       IN      VARCHAR2,--Bug 2510993
		p_override_approver_id	        IN 	NUMBER,  --Bug 2510993
		p_last_update_date 		IN	DATE,    --Bug 2510993
                -- skaneshi: temporarily put default null so does not cause plsql error
                receipt_cost_center             IN      VARCHAR2 DEFAULT NULL,
		p_transaction_currency_type	IN 	VARCHAR2,--Bug 2510993
		p_inverse_rate_flag		IN	VARCHAR2,--Bug 2510993
                p_report_header_id              IN      NUMBER,
		p_category_code 		IN	VARCHAR2, --Bug 2292854
                    -- Per Diem data
                p_nFreeBreakfasts1              IN      NUMBER,
                p_nFreeBreakfasts2              IN      NUMBER,
                p_nFreeBreakfasts3              IN      NUMBER,
                p_nFreeLunches1                 IN      NUMBER,
                p_nFreeLunches2                 IN      NUMBER,
                p_nFreeLunches3                 IN      NUMBER,
                p_nFreeDinners1                 IN      NUMBER,
                p_nFreeDinners2                 IN      NUMBER,
                p_nFreeDinners3                 IN      NUMBER,
                p_nFreeAccommodations1          IN      NUMBER,
                p_nFreeAccommodations2          IN      NUMBER,
                p_nFreeAccommodations3          IN      NUMBER,
                p_location 	                IN	VARCHAR2,
                     -- Mileage data
                p_dailyDistance                 IN      NUMBER,
                p_tripDistance                  IN      NUMBER,
                p_mileageRate                  IN      NUMBER,
                p_vehicleCategory 	        IN	VARCHAR2,
                p_vehicleType 	                IN	VARCHAR2,
                p_fuelType 	                IN	VARCHAR2,
                p_numberPassengers              IN      NUMBER,
		p_default_currency_code		IN	VARCHAR2,
		p_default_exchange_rate_type	IN	VARCHAR2,
		p_header_attribute_category	IN      VARCHAR2,
		p_header_attribute1		IN      VARCHAR2,
		p_header_attribute2		IN      VARCHAR2,
		p_header_attribute3		IN      VARCHAR2,
		p_header_attribute4		IN      VARCHAR2,
		p_header_attribute5		IN      VARCHAR2,
		p_header_attribute6		IN      VARCHAR2,
		p_header_attribute7		IN      VARCHAR2,
		p_header_attribute8		IN      VARCHAR2,
		p_header_attribute9		IN      VARCHAR2,
		p_header_attribute10		IN      VARCHAR2,
		p_header_attribute11		IN      VARCHAR2,
		p_header_attribute12		IN      VARCHAR2,
		p_header_attribute13		IN      VARCHAR2,
		p_header_attribute14		IN      VARCHAR2,
		p_header_attribute15		IN      VARCHAR2,
		p_receipt_index			IN	NUMBER,
                p_passenger_rate_used           IN      NUMBER,
                p_license_plate_number          IN      VARCHAR2,
                p_destination_from              IN      VARCHAR2,
                p_destination_to                IN      VARCHAR2,
                p_distance_unit_code            IN      VARCHAR2,
                p_addon_rates                   IN      OIE_ADDON_RATES_T DEFAULT NULL,
                p_report_line_id                IN      NUMBER,
                p_itemization_parent_id         IN      NUMBER,
		-- daily breakup array
                p_daily_breakup_id              IN      OIE_PDM_NUMBER_T DEFAULT NULL,
                p_start_date                    IN      OIE_PDM_DATE_T DEFAULT NULL,
                p_end_date                      IN      OIE_PDM_DATE_T DEFAULT NULL,
                p_amount                        IN      OIE_PDM_NUMBER_T DEFAULT NULL,
                p_number_of_meals               IN      OIE_PDM_NUMBER_T DEFAULT NULL,
                p_meals_amount                  IN      OIE_PDM_NUMBER_T DEFAULT NULL,
                p_breakfast_flag                IN      OIE_PDM_VARCHAR_1_T DEFAULT NULL,
                p_lunch_flag                    IN      OIE_PDM_VARCHAR_1_T DEFAULT NULL,
                p_dinner_flag                   IN      OIE_PDM_VARCHAR_1_T DEFAULT NULL,
                p_accommodation_amount          IN      OIE_PDM_NUMBER_T DEFAULT NULL,
                p_accommodation_flag            IN      OIE_PDM_VARCHAR_1_T DEFAULT NULL,
                p_hotel_name                    IN      OIE_PDM_VARCHAR_80_T DEFAULT NULL,
                p_night_rate_Type               IN      OIE_PDM_VARCHAR_80_T DEFAULT NULL,
                p_night_rate_amount             IN      OIE_PDM_NUMBER_T DEFAULT NULL,
                p_pdm_rate                      IN      OIE_PDM_NUMBER_T DEFAULT NULL,
                p_rate_Type_code                IN      OIE_PDM_VARCHAR_80_T DEFAULT NULL,
                p_pdm_breakup_dest_id           IN      OIE_PDM_NUMBER_T DEFAULT NULL,
                -- destination array
                p_pdm_destination_id            IN      OIE_PDM_NUMBER_T DEFAULT NULL,
                p_dest_start_date               IN      OIE_PDM_DATE_T DEFAULT NULL,
                p_dest_end_date                 IN      OIE_PDM_DATE_T DEFAULT NULL,
                p_location_id                   IN      OIE_PDM_NUMBER_T DEFAULT NULL,
                p_cust_meals_amount             IN OUT  NOCOPY OIE_PDM_NUMBER_T,
                p_cust_accommodation_amount     IN OUT  NOCOPY OIE_PDM_NUMBER_T,
                p_cust_night_rate_amount        IN OUT  NOCOPY OIE_PDM_NUMBER_T,
                p_cust_pdm_rate                 IN OUT  NOCOPY OIE_PDM_NUMBER_T,
                p_vat_code                      IN      VARCHAR2 DEFAULT NULL, -- Bug: 6719467
                p_emp_attendee_count            IN      NUMBER DEFAULT NULL, -- Bug 6919132
                p_nonemp_attendee_count         IN      NUMBER DEFAULT NULL -- Bug 6919132
);


PROCEDURE OASubmitWorkflow         (p_report_header_id	IN VARCHAR2,
				    p_preparer_id	IN VARCHAR2,
				    p_employee_id	IN VARCHAR2,
				    p_invoice_number	IN VARCHAR2,
				    p_reimb_curr	IN VARCHAR2,
				    p_cost_center	IN VARCHAR2,
				    p_purpose		IN VARCHAR2,
				    p_approver_id	IN VARCHAR2,
                                    p_week_end_date     IN DATE, -- Bug 3322390
                                    p_workflow_appr_flag IN VARCHAR2,
				    p_msg_count		 OUT NOCOPY NUMBER);


PROCEDURE GetItemDescLookupCode(p_parameter_id		IN VARCHAR2,
				p_item_description OUT NOCOPY VARCHAR2,
				p_line_type_lookup_code OUT NOCOPY VARCHAR2);

PROCEDURE GetUserID(p_employee_id	IN VARCHAR2,
		    p_user_id	 OUT NOCOPY VARCHAR2);

PROCEDURE WithdrawExpenseReport(
             p_report_header_id IN expHdr_headerID);

PROCEDURE GetFunctionalCurrencyInfo(p_currencyCode out nocopy varchar2,
                                    p_currencyType out nocopy varchar2);

-------------------------------------------------------------------
-- Name: DuplicateExpenseReport
-- Desc: duplicates an Expense Report
-- Input:   p_source_report_header_id - source expense report header id
-- Returns: p_target_report_header_id - target expense report header id
-------------------------------------------------------------------
PROCEDURE DuplicateExpenseReport(
  p_user_id     IN NUMBER,
  p_source_report_header_id     IN expHdr_headerID,
  p_target_report_header_id     IN OUT NOCOPY expHdr_headerID);

/*------------------------------------------------------------+
  Created By: Amulya Mishra
  Bug 2751642: Wrapper function to get ORG_ID value from
                AP_WEB_DB_HR_INT_PKG.GetEmpOrgId().
+-------------------------------------------------------------*/

FUNCTION GetOrgIDFromHR(p_employee_id IN NUMBER,
                        p_effective_date  IN   Date) RETURN NUMBER;

----------------------------------------------------------------------
PROCEDURE GetDefaultAcctgSegValues(
             P_REPORT_HEADER_ID    IN  NUMBER,
             P_REPORT_LINE_ID      IN  NUMBER,
             P_OLD_EMPLOYEE_ID         IN  NUMBER,
	     P_OLD_HEADER_COST_CENTER  IN  AP_EXPENSE_REPORT_HEADERS.flex_concatenated%TYPE,
	     P_OLD_PARAMETER_ID        IN  NUMBER,
             P_NEW_EMPLOYEE_ID         IN  NUMBER,
	     P_NEW_HEADER_COST_CENTER  IN  AP_EXPENSE_REPORT_HEADERS.flex_concatenated%TYPE,
	     P_NEW_PARAMETER_ID        IN  NUMBER,
             P_SEGMENTS            IN  AP_OIE_KFF_SEGMENTS_T,
             X_SEGMENTS            OUT NOCOPY AP_OIE_KFF_SEGMENTS_T,
             x_combination_id      OUT NOCOPY HR_EMPLOYEES_CURRENT_V.default_code_combination_id%TYPE,
             X_MSG_COUNT           OUT NOCOPY NUMBER,
             X_MSG_DATA            OUT NOCOPY VARCHAR2,
             X_RETURN_STATUS       OUT NOCOPY VARCHAR2);
----------------------------------------------------------------------
PROCEDURE validateAccountSegments(
             P_REPORT_HEADER_ID    IN  NUMBER,
             P_REPORT_LINE_ID      IN  NUMBER,
             P_EMPLOYEE_ID         IN  NUMBER,
             P_SEGMENTS            IN  AP_OIE_KFF_SEGMENTS_T,
             X_SEGMENTS            OUT NOCOPY AP_OIE_KFF_SEGMENTS_T,
             x_combination_id      OUT NOCOPY HR_EMPLOYEES_CURRENT_V.default_code_combination_id%TYPE,
             X_MSG_COUNT           OUT NOCOPY NUMBER,
             X_MSG_DATA            OUT NOCOPY VARCHAR2,
             X_RETURN_STATUS       OUT NOCOPY VARCHAR2);
----------------------------------------------------------------------
PROCEDURE rebuildAccountSegments(
             P_REPORT_HEADER_ID    IN  NUMBER,
             P_REPORT_LINE_ID      IN  NUMBER,
             P_EMPLOYEE_ID         IN  NUMBER,
             P_SEGMENTS            IN  AP_OIE_KFF_SEGMENTS_T,
             X_SEGMENTS            OUT NOCOPY AP_OIE_KFF_SEGMENTS_T,
             x_combination_id      OUT NOCOPY HR_EMPLOYEES_CURRENT_V.default_code_combination_id%TYPE,
             X_MSG_COUNT           OUT NOCOPY NUMBER,
             X_MSG_DATA            OUT NOCOPY VARCHAR2,
             X_RETURN_STATUS       OUT NOCOPY VARCHAR2);



----------------------------------------------------------------------


PROCEDURE updateExpensedAmount(
	p_trxIds 	IN AP_WEB_PARENT_PKG.Number_Array,
        p_expensedAmt 	IN AP_WEB_PARENT_PKG.Number_Array,
       	p_reportId    	IN AP_CREDIT_CARD_TRXNS.report_header_id%TYPE);

----------------------------------------------------------------------


PROCEDURE DeleteReport(
         ReportID             IN AP_EXPENSE_REPORT_LINES.report_header_id%TYPE);

----------------------------------------------------------------------


PROCEDURE updChargesFromDeletedReport(
  p_idArray  IN AP_WEB_PARENT_PKG.number_Array,
  p_amtArray IN AP_WEB_PARENT_PKG.number_Array);



END AP_WEB_OA_MAINFLOW_PKG;

/
