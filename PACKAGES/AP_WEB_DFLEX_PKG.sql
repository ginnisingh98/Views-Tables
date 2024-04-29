--------------------------------------------------------
--  DDL for Package AP_WEB_DFLEX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_DFLEX_PKG" AUTHID CURRENT_USER AS
/* $Header: apwdflxs.pls 120.18.12010000.3 2009/01/23 07:18:47 stalasil ship $ */

SUBTYPE expLines_currCode		IS AP_EXPENSE_REPORT_LINES.currency_code%TYPE;
SUBTYPE expLines_expOrgID		IS AP_EXPENSE_REPORT_LINES.expenditure_organization_id%TYPE;
SUBTYPE expHdr_headerID 		IS AP_EXPENSE_REPORT_HEADERS.report_header_id%TYPE;

  -- Constants
  C_CustValidResMsgTypeNone    CONSTANT VARCHAR(20) := NULL;
  C_CustValidResMsgTypeError   CONSTANT VARCHAR(20) := 'ERROR';
  C_CustValidResMsgTypeWarning CONSTANT VARCHAR(20) := 'WARNING';
  C_AbsoluteMaxFlexField  CONSTANT NUMBER := 15;

  -- Descriptive flexfield data types
  TYPE ExpReportHeaderRec IS RECORD (
    report_header_id			expHdr_headerID,
    employee_id		      		VARCHAR2(25),
    cost_center		      		VARCHAR2(30),
    template_id	      		        VARCHAR2(25),
    template_name			VARCHAR2(100),
    purpose		      		VARCHAR2(240),
    summary_start_date			VARCHAR2(25),
    summary_end_date			VARCHAR2(25),
    summary_xtype			VARCHAR2(25),
    receipt_index			NUMBER,
    last_receipt_date			VARCHAR2(25),
    last_update_date			VARCHAR2(25),
    receipt_count			VARCHAR2(25),
    transaction_currency_type		VARCHAR2(25),
    reimbursement_currency_code		expLines_currCode,
    reimbursement_currency_name		VARCHAR2(80),
    multi_currency_flag			VARCHAR2(1),
    inverse_rate_flag			VARCHAR2(1),
    override_approver_id		VARCHAR2(25),
    override_approver_name		VARCHAR2(240),
    expenditure_organization_id         expLines_expOrgID,
    number_max_flexfield		NUMBER,
    amt_due_employee			NUMBER,
    amt_due_ccCompany			NUMBER,  -- project accounting
    default_currency_code		VARCHAR2(15),
    default_exchange_rate_type		VARCHAR2(30),
    attribute_category                  ap_expense_report_headers_all.attribute_category%type,
    attribute1                          ap_expense_report_headers_all.attribute1%type,
    attribute2                          ap_expense_report_headers_all.attribute2%type,
    attribute3                          ap_expense_report_headers_all.attribute3%type,
    attribute4                          ap_expense_report_headers_all.attribute4%type,
    attribute5                          ap_expense_report_headers_all.attribute5%type,
    attribute6                          ap_expense_report_headers_all.attribute6%type,
    attribute7                          ap_expense_report_headers_all.attribute7%type,
    attribute8                          ap_expense_report_headers_all.attribute8%type,
    attribute9                          ap_expense_report_headers_all.attribute9%type,
    attribute10                         ap_expense_report_headers_all.attribute10%type,
    attribute11                         ap_expense_report_headers_all.attribute11%type,
    attribute12                         ap_expense_report_headers_all.attribute12%type,
    attribute13                         ap_expense_report_headers_all.attribute13%type,
    attribute14                         ap_expense_report_headers_all.attribute14%type,
    attribute15                         ap_expense_report_headers_all.attribute15%type
	);

  TYPE ExpReportLineRec IS RECORD (
    receipt_index                       NUMBER, -- index of receipt starting from 1
    start_date				DATE,
    end_date				DATE,
    days				VARCHAR2(25),
    daily_amount			VARCHAR2(50),--Bug 2646884.
    receipt_amount			VARCHAR2(50),
    rate				VARCHAR2(50),--Bug 4956830
    amount				VARCHAR2(50),
    parameter_id			AP_EXPENSE_REPORT_PARAMS.parameter_id%TYPE,
    expense_type			VARCHAR2(80),
    currency_code			VARCHAR2(25),

    merchant                            varchar2(80),
    merchantDoc                         varchar2(80),
    taxReference                        varchar2(240),
    taxRegNumber                        varchar2(80),
    taxPayerId                          varchar2(80),
    supplyCountry                       varchar2(5),
    itemizeId                           number,
    cCardTrxnId                         number,
    category                            AP_CREDIT_CARD_TRXNS.category%type,

    group_value				VARCHAR2(80),
    justification			VARCHAR2(240),
    receipt_missing_flag		VARCHAR2(1),
    validation_required			VARCHAR2(1),
    calculate_flag			VARCHAR2(1),
    calculated_amount			VARCHAR2(50),
    copy_calc_amt_into_receipt_amt	VARCHAR2(1),
    amount_includes_tax                 VARCHAR2(1),
    tax_code                            AP_EXPENSE_REPORT_PARAMS.vat_code%TYPE,
    taxOverrideFlag			VARCHAR2(1),
    taxId				VARCHAR2(15),
    project_id                          VARCHAR2(15),
    project_number                      PA_PROJECTS_EXPEND_V.project_number%TYPE,
    task_id                             VARCHAR2(15),
    task_number                         PA_TASKS_EXPEND_V.task_number%TYPE,
    expenditure_type                    VARCHAR2(30),
    award_number			gms_awards_all.award_number%TYPE,
    award_id				gms_awards_all.award_id%TYPE,
    cost_center				VARCHAR2(240),
    category_code                       VARCHAR2(20), --Bug 2292854
                    -- Per Diem data
    nFreeBreakfasts1                    ap_expense_report_lines.NUM_FREE_BREAKFASTS1%type,
    nFreeBreakfasts2                    ap_expense_report_lines.NUM_FREE_BREAKFASTS1%type,
    nFreeBreakfasts3                    ap_expense_report_lines.NUM_FREE_BREAKFASTS1%type,
    nFreeLunches1                       ap_expense_report_lines.NUM_FREE_LUNCHES1%type,
    nFreeLunches2                       ap_expense_report_lines.NUM_FREE_LUNCHES1%type,
    nFreeLunches3                       ap_expense_report_lines.NUM_FREE_LUNCHES1%type,
    nFreeDinners1                       ap_expense_report_lines.NUM_FREE_DINNERS1%type,
    nFreeDinners2                       ap_expense_report_lines.NUM_FREE_DINNERS1%type,
    nFreeDinners3                       ap_expense_report_lines.NUM_FREE_DINNERS1%type,
    nFreeAccommodations1                ap_expense_report_lines.NUM_FREE_ACCOMMODATIONS1%type,
    nFreeAccommodations2                ap_expense_report_lines.NUM_FREE_ACCOMMODATIONS1%type,
    nFreeAccommodations3                ap_expense_report_lines.NUM_FREE_ACCOMMODATIONS1%type,
    location 	                	ap_expense_report_lines.LOCATION%type,
    -- Bug 3600198
    startTime                           VARCHAR(5),   -- in HH24:MM format
    endTime                             VARCHAR(5),   -- in HH24:MM format
        -- Mileage data
    dailyDistance                       ap_expense_report_lines.DAILY_DISTANCE%type,
    tripDistance                        ap_expense_report_lines.TRIP_DISTANCE%type,
    mileageRate                         ap_expense_report_lines.AVG_MILEAGE_RATE%type,
    vehicleCategory 	        	ap_expense_report_lines.VEHICLE_CATEGORY_CODE%type,
    vehicleType 	               	ap_expense_report_lines.VEHICLE_TYPE%type,
    fuelType 	                	ap_expense_report_lines.FUEL_TYPE%type,
    numberPassengers                    ap_expense_report_lines.NUMBER_PEOPLE%type,
    licensePlateNumber                  ap_expense_report_lines_all.license_plate_number%type,
    passengerRateUsed                   ap_expense_report_lines_all.rate_per_passenger%type,
    destinationFrom                     ap_expense_report_lines_all.destination_from%type,
    destinationTo                       ap_expense_report_lines_all.destination_to%type,
    distanceUnitCode                    ap_expense_report_lines_all.distance_unit_code%type,
    report_line_id                      ap_expense_report_lines_all.report_line_id%type,
    itemization_parent_id               ap_expense_report_lines_all.itemization_parent_id%type,
    emp_attendee_count                 NUMBER, -- Bug 6919132
    nonemp_attendee_count              NUMBER  -- Bug 6919132
  );

  TYPE ExpReportLines_A IS TABLE OF ExpReportLineRec
    INDEX BY BINARY_INTEGER;

  TYPE CustomFieldRec IS RECORD (
-- chiho: 1170729: modify the data type:
    prompt				fnd_descr_flex_col_usage_vl.form_left_prompt%TYPE,
    user_prompt                        fnd_descr_flex_col_usage_vl.form_left_prompt%TYPE,
    value				fnd_descr_flex_col_usage_vl.default_value%TYPE,

    column_mapping			VARCHAR2(30),
    displayed_flag			VARCHAR2(1),
    required_flag			VARCHAR2(1),
    display_size			NUMBER,
    value_set				VARCHAR2(30));

  TYPE CustomFields_A IS TABLE OF CustomFieldRec
    INDEX BY BINARY_INTEGER;

  TYPE PoplistValue IS RECORD (InternalValue  VARCHAR2(240),
                               DisplayText    VARCHAR2(240));
  TYPE PoplistValues_A IS TABLE OF PoplistValue INDEX BY BINARY_INTEGER;

TYPE Binary_Integer_A IS TABLE OF BINARY_INTEGER
  INDEX BY BINARY_INTEGER;

PROCEDURE GetExpenseLineDflexInfo(p_user_id     IN NUMBER, -- 2242176
                                  p_flexfield	IN OUT NOCOPY FND_DFLEX.DFLEX_R,
				  p_flexinfo	IN OUT NOCOPY FND_DFLEX.DFLEX_DR,
				  p_contexts	IN OUT NOCOPY FND_DFLEX.CONTEXTS_DR,
                                  p_is_custom_fields_feat_used IN OUT NOCOPY BOOLEAN);


PROCEDURE GetDFlexContextSegments(p_flexfield	IN FND_DFLEX.DFLEX_R,
			     	  p_contexts    IN FND_DFLEX.CONTEXTS_DR,
			     	  p_context_index  IN BINARY_INTEGER,
			     	  p_segments	IN OUT NOCOPY FND_DFLEX.SEGMENTS_DR);


PROCEDURE GetDFlexContextIndex(p_context_value	    IN VARCHAR2,
		               p_dflex_contexts	    IN FND_DFLEX.CONTEXTS_DR,
		               p_index		    IN OUT NOCOPY BINARY_INTEGER);


PROCEDURE GetIndexRefOrderedArray(p_sequence_array  IN  FND_DFLEX.SEQUENCE_A,
				  p_nelements	    IN	NUMBER,
			p_index_ref_ordered_array   OUT NOCOPY BINARY_INTEGER_A);

FUNCTION GetNumOfEnabledSegments(P_Segments IN FND_DFLEX.SEGMENTS_DR) RETURN NUMBER;

FUNCTION GetCustomFieldValue(p_prompt			IN VARCHAR2,
	      p_custom_fields_array	IN CustomFields_A) RETURN VARCHAR2;

PROCEDURE GetReceiptCustomFields(
		p_receipt_custom_fields_array	IN OUT NOCOPY CustomFields_A,
		p_receipt_index			IN BINARY_INTEGER,
		p_custom1_array			IN CustomFields_A,
		p_custom2_array			IN CustomFields_A,
		p_custom3_array			IN CustomFields_A,
		p_custom4_array			IN CustomFields_A,
		p_custom5_array			IN CustomFields_A,
		p_custom6_array			IN CustomFields_A,
		p_custom7_array			IN CustomFields_A,
		p_custom8_array			IN CustomFields_A,
		p_custom9_array			IN CustomFields_A,
		p_custom10_array		IN CustomFields_A,
		p_custom11_array		IN CustomFields_A,
		p_custom12_array		IN CustomFields_A,
		p_custom13_array		IN CustomFields_A,
		p_custom14_array		IN CustomFields_A,
		p_custom15_array		IN CustomFields_A);

PROCEDURE PropogateReceiptCustFldsInfo(
		p_receipt_custom_fields_array	IN CustomFields_A,
		p_receipt_index			IN BINARY_INTEGER,
		p_custom1_array			IN OUT NOCOPY CustomFields_A,
		p_custom2_array			IN OUT NOCOPY CustomFields_A,
		p_custom3_array			IN OUT NOCOPY CustomFields_A,
		p_custom4_array			IN OUT NOCOPY CustomFields_A,
		p_custom5_array			IN OUT NOCOPY CustomFields_A,
		p_custom6_array			IN OUT NOCOPY CustomFields_A,
		p_custom7_array			IN OUT NOCOPY CustomFields_A,
		p_custom8_array			IN OUT NOCOPY CustomFields_A,
		p_custom9_array			IN OUT NOCOPY CustomFields_A,
		p_custom10_array		IN OUT NOCOPY CustomFields_A,
		p_custom11_array		IN OUT NOCOPY CustomFields_A,
		p_custom12_array		IN OUT NOCOPY CustomFields_A,
		p_custom13_array		IN OUT NOCOPY CustomFields_A,
		p_custom14_array		IN OUT NOCOPY CustomFields_A,
		p_custom15_array		IN OUT NOCOPY CustomFields_A);

PROCEDURE AssocCustFieldPromptsToValues(
	p_dflex_segs		IN FND_DFLEX.SEGMENTS_DR,
        p_starting_index	IN BINARY_INTEGER,
        p_ending_index		IN BINARY_INTEGER,
	p_custom_fields_array   IN OUT NOCOPY CustomFields_A);


PROCEDURE ProcessDFlexError(
	p_custom_fields_array	IN CustomFields_A,
	p_num_of_global_fields	IN BINARY_INTEGER,
	p_num_of_context_fields	IN BINARY_INTEGER,
        p_error                 IN OUT NOCOPY AP_WEB_UTILITIES_PKG.expError,
	p_receipt_index		IN BINARY_INTEGER DEFAULT NULL );


PROCEDURE CoreValidateDFlexValues(
	p_dflex_name	      	IN VARCHAR2,
	p_dflex_contexts	IN FND_DFLEX.CONTEXTS_DR,
	p_context_index	      	IN BINARY_INTEGER,
	p_custom_fields_array   IN CustomFields_A,
	p_num_of_global_fields	IN BINARY_INTEGER,
	p_num_of_context_fields	IN BINARY_INTEGER,
	p_receipt_errors	IN OUT NOCOPY AP_WEB_UTILITIES_PKG.receipt_error_stack,
	p_receipt_index		IN BINARY_INTEGER,
        p_error                 IN OUT NOCOPY AP_WEB_UTILITIES_PKG.expError);

PROCEDURE ValidateDFlexValues(
	p_exp_header_info	IN ExpReportHeaderRec,
	p_exp_line_info		IN ExpReportLineRec,
	p_custom_fields_array	IN CustomFields_A,
	p_num_of_global_fields	IN BINARY_INTEGER,
	p_num_of_context_fields	IN BINARY_INTEGER,
        p_dflex_name		IN VARCHAR2,
	p_dflex_contexts	IN FND_DFLEX.CONTEXTS_DR,
	p_context_index		IN BINARY_INTEGER,
	p_receipt_errors	IN OUT NOCOPY AP_WEB_UTILITIES_PKG.receipt_error_stack,
	p_receipt_index		IN BINARY_INTEGER,
        p_error                 IN OUT NOCOPY AP_WEB_UTILITIES_PKG.expError);

PROCEDURE PopulateExpTypeInLineRec(
        p_exp_line_info  IN OUT NOCOPY ExpReportLineRec);

PROCEDURE ValidateReceiptCustomFields(
    	p_userId		IN 	NUMBER,
	p_exp_header_info	IN ExpReportHeaderRec,
	p_exp_line_info	 	IN OUT NOCOPY ExpReportLineRec,
	p_custom_fields_array 	IN OUT NOCOPY CustomFields_A,
	p_receipt_errors	IN OUT NOCOPY AP_WEB_UTILITIES_PKG.receipt_error_stack,
	p_receipt_index		IN BINARY_INTEGER,
        p_error                 IN OUT NOCOPY AP_WEB_UTILITIES_PKG.expError );



FUNCTION IsFlexFieldUsed(
        P_CustomField IN CustomFieldRec)
RETURN BOOLEAN;
PROCEDURE IsSessionTaxEnabled(P_Result OUT NOCOPY VARCHAR2,
                              p_user_id IN NUMBER DEFAULT NULL); -- 2242176
FUNCTION GetMaxNumSegmentsUsed (p_user_id IN NUMBER DEFAULT NULL)
  RETURN NUMBER;
FUNCTION GetMaxNumPseudoSegmentsUsed(
  P_IsSessionProjectEnabled IN VARCHAR2) -- 2242176
RETURN NUMBER;
PROCEDURE ClearCustomFieldRec(
  P_CustomField OUT NOCOPY CustomFieldRec);
FUNCTION IsCustomFieldPopulated(P_ReceiptIndex IN NUMBER,
                                Custom1_Array  IN CustomFields_A,
                                Custom2_Array  IN CustomFields_A,
                                Custom3_Array  IN CustomFields_A,
                                Custom4_Array  IN CustomFields_A,
                                Custom5_Array  IN CustomFields_A,
                                Custom6_Array  IN CustomFields_A,
                                Custom7_Array  IN CustomFields_A,
                                Custom8_Array  IN CustomFields_A,
                                Custom9_Array  IN CustomFields_A,
                                Custom10_Array IN CustomFields_A,
                                Custom11_Array IN CustomFields_A,
                                Custom12_Array IN CustomFields_A,
                                Custom13_Array IN CustomFields_A,
                                Custom14_Array IN CustomFields_A,
                                Custom15_Array IN CustomFields_A)
RETURN BOOLEAN;

PROCEDURE PopulateCustomDefaultValues(
                               p_user_id      IN NUMBER, -- 2242176
                               P_ExpReportHeaderInfo IN ExpReportHeaderRec,
                               ExpReportLinesInfo IN OUT NOCOPY ExpReportLines_A,
                               P_ReceiptCount IN NUMBER,
                               Custom1_Array  IN OUT NOCOPY CustomFields_A,
                               Custom2_Array  IN OUT NOCOPY CustomFields_A,
                               Custom3_Array  IN OUT NOCOPY CustomFields_A,
                               Custom4_Array  IN OUT NOCOPY CustomFields_A,
                               Custom5_Array  IN OUT NOCOPY CustomFields_A,
                               Custom6_Array  IN OUT NOCOPY CustomFields_A,
                               Custom7_Array  IN OUT NOCOPY CustomFields_A,
                               Custom8_Array  IN OUT NOCOPY CustomFields_A,
                               Custom9_Array  IN OUT NOCOPY CustomFields_A,
                               Custom10_Array IN OUT NOCOPY CustomFields_A,
                               Custom11_Array IN OUT NOCOPY CustomFields_A,
                               Custom12_Array IN OUT NOCOPY CustomFields_A,
                               Custom13_Array IN OUT NOCOPY CustomFields_A,
                               Custom14_Array IN OUT NOCOPY CustomFields_A,
                               Custom15_Array IN OUT NOCOPY CustomFields_A,
                               P_NumMaxFlexField  IN NUMBER,
                               P_DataDefaultedUpdateable IN OUT NOCOPY BOOLEAN);

PROCEDURE PopulatePseudoDefaultValues(
                               P_ExpReportHeaderInfo IN ExpReportHeaderRec,
                               ExpReportLinesInfo IN OUT NOCOPY ExpReportLines_A,
                               P_ReceiptCount IN NUMBER,
                               P_DataDefaultedUpdateable IN OUT NOCOPY BOOLEAN);

PROCEDURE SetExpReportLineInfo(P_ExpReportLineInfo          OUT NOCOPY ExpReportLineRec,
                               P_receipt_index                  IN      NUMBER,
                               P_start_date			IN	DATE,
                               P_end_date			IN	DATE,
                               P_days				IN	VARCHAR2,
                               P_daily_amount			IN	VARCHAR2,
                               P_receipt_amount			IN	VARCHAR2,
                               P_rate				IN	VARCHAR2,
                               P_amount				IN	VARCHAR2,
                               P_parameter_id			IN	VARCHAR2,
                               P_expense_type			IN	VARCHAR2,
                               P_currency_code			IN	VARCHAR2,
                               P_group_value			IN	VARCHAR2,
                               P_justification			IN	VARCHAR2,
                               P_receipt_missing_flag		IN	VARCHAR2,
                               P_validation_required		IN	VARCHAR2,
                               P_calculate_flag			IN	VARCHAR2,
                               P_calculated_amount		IN	VARCHAR2,
                               P_copy_calc_amt_into_receipt	IN	VARCHAR2,
                               P_AmtInclTax                     IN      VARCHAR2,
                               P_TaxCode                        IN      VARCHAR2,
			       P_TaxOverrideFlag		IN	VARCHAR2,
			       P_TaxId                          IN      VARCHAR2,
                               P_ProjectID                      IN      VARCHAR2,
                               P_ProjectNumber                  IN      VARCHAR2,
                               P_TaskID                         IN      VARCHAR2,
                               P_TaskNumber                     IN      VARCHAR2,
                               P_ExpenditureType                IN      VARCHAR2
);

PROCEDURE SetExpReportHeaderInfo(P_ExpReportHeaderInfo    OUT NOCOPY ExpReportHeaderRec,
                                 P_employee_id		      	IN	VARCHAR2,
                                 P_cost_center		      	IN	VARCHAR2,
                                 P_expense_report_id	      	IN	VARCHAR2,
                                 P_template_name		IN	VARCHAR2,
                                 P_purpose		      	IN	VARCHAR2,
                                 P_last_receipt_date		IN	VARCHAR2,
                                 P_receipt_count		IN	VARCHAR2,
                                 P_transaction_currency_type	IN	VARCHAR2,
                                 P_reimbursement_currency_code	IN	VARCHAR2,
                                 P_reimbursement_currency_name	IN	VARCHAR2,
                                 P_multi_currency_flag		IN	VARCHAR2,
                                 P_inverse_rate_flag		IN	VARCHAR2,
                                 P_approver_id			IN	VARCHAR2,
                                 P_approver_name		IN	VARCHAR2,
                                 P_expenditure_organization_id  IN      VARCHAR2 DEFAULT NULL);

PROCEDURE PopulateCustomFieldsInfo(
        p_userId                   IN NUMBER,
	p_exp_line_info	 	   IN OUT NOCOPY ExpReportLineRec,
	p_custom_fields_array 	   IN OUT NOCOPY CustomFields_A,
        p_num_global_enabled_segs  IN OUT NOCOPY NUMBER,
        p_num_context_enabled_segs IN OUT NOCOPY NUMBER,
        p_dflexfield               IN OUT NOCOPY FND_DFLEX.DFLEX_R,
        p_dflexinfo                IN OUT NOCOPY FND_DFLEX.DFLEX_DR,
        p_dflexfield_contexts      IN OUT NOCOPY FND_DFLEX.CONTEXTS_DR,
        p_context_index            IN OUT NOCOPY NUMBER);
PROCEDURE PopulateCustomFieldsInfoAll(
        p_report_lines_info   IN OUT NOCOPY ExpReportLines_A,
        p_custom1_array       IN OUT NOCOPY CustomFields_A,
        p_custom2_array       IN OUT NOCOPY CustomFields_A,
        p_custom3_array       IN OUT NOCOPY CustomFields_A,
        p_custom4_array       IN OUT NOCOPY CustomFields_A,
        p_custom5_array       IN OUT NOCOPY CustomFields_A,
        p_custom6_array       IN OUT NOCOPY CustomFields_A,
        p_custom7_array       IN OUT NOCOPY CustomFields_A,
        p_custom8_array       IN OUT NOCOPY CustomFields_A,
        p_custom9_array       IN OUT NOCOPY CustomFields_A,
        p_custom10_array      IN OUT NOCOPY CustomFields_A,
        p_custom11_array      IN OUT NOCOPY CustomFields_A,
        p_custom12_array      IN OUT NOCOPY CustomFields_A,
        p_custom13_array      IN OUT NOCOPY CustomFields_A,
        p_custom14_array      IN OUT NOCOPY CustomFields_A,
        p_custom15_array      IN OUT NOCOPY CustomFields_A,
	p_receipts_count      IN     BINARY_INTEGER);

FUNCTION GetSegmentDefault(P_ContextValue          IN VARCHAR2,
                           P_Segments              IN FND_DFLEX.SEGMENTS_DR,
                           P_SegIndex              IN NUMBER) RETURN VARCHAR2;


FUNCTION IsSegmentWebEnabled(P_Segments IN FND_DFLEX.SEGMENTS_DR,
                            P_Index IN NUMBER) RETURN BOOLEAN;


function LOVButton (c_attribute_app_id in number,
                    c_attribute_code in varchar2,
                    c_region_app_id in number,
                    c_region_code in varchar2,
                    c_form_name in varchar2,
                    c_frame_name in varchar2 default null,
                    c_where_clause in varchar2 default null,
                    c_js_where_clause in varchar2 default null,
		    c_image_align in varchar2 default 'CENTER')
                    return varchar2;

PROCEDURE GetTaxPseudoSegmentDefaults(
             P_ExpTypeID                IN  AP_EXPENSE_REPORT_PARAMS.parameter_id%TYPE,
             P_ExpTypeTaxCodeUpdateable IN OUT NOCOPY VARCHAR2,
             P_ExpTypeDefaultTaxCode    IN OUT NOCOPY AP_TAX_CODES.name%TYPE,
             P_OrgId                    IN  NUMBER);


END AP_WEB_DFLEX_PKG;

/
