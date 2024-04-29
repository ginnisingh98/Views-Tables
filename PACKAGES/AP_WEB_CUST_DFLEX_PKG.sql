--------------------------------------------------------
--  DDL for Package AP_WEB_CUST_DFLEX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_CUST_DFLEX_PKG" AUTHID CURRENT_USER AS
/* $Header: apwdfcfs.pls 120.9.12010000.2 2008/09/15 08:50:40 rveliche ship $ */

PROCEDURE CustomPopulatePoplist(
             P_ExpenseTypeName     IN  VARCHAR2,
             P_CustomFieldName     IN  VARCHAR2,
             P_NumOfPoplistElem    OUT NOCOPY NUMBER,
             P_PoplistArray        OUT NOCOPY AP_WEB_DFLEX_PKG.PoplistValues_A);

PROCEDURE CustomPopulateDefault(
             P_ExpenseTypeName     IN  VARCHAR2,
             P_CustomFieldName     IN  VARCHAR2,
             P_DefaultValue        OUT NOCOPY VARCHAR2);

PROCEDURE CustomValidateDFlexValues(
	p_exp_header_info	IN AP_WEB_DFLEX_PKG.ExpReportHeaderRec,
	p_exp_line_info		IN AP_WEB_DFLEX_PKG.ExpReportLineRec,
	p_custom_fields_array	IN AP_WEB_DFLEX_PKG.CustomFields_A,
	p_custom_field_record  	IN AP_WEB_DFLEX_PKG.CustomFieldRec,
	p_validation_level	IN VARCHAR2,
	p_result_message	IN OUT NOCOPY VARCHAR2,
	p_message_type  	IN OUT NOCOPY VARCHAR2,
	p_receipt_index		IN BINARY_INTEGER);

PROCEDURE CustomCalculateAmount(
	p_exp_header_info	IN OUT NOCOPY AP_WEB_DFLEX_PKG.ExpReportHeaderRec, -- epxense report header details
	p_exp_line_info		IN OUT NOCOPY AP_WEB_DFLEX_PKG.ExpReportLineRec, -- expense report line detail
	p_custom_fields_array	IN AP_WEB_DFLEX_PKG.CustomFields_A, -- custom field details
	-- p_addon_rates used for mileage category only
	p_addon_rates           IN OIE_ADDON_RATES_T, -- array of additional rate types
    p_report_line_id        IN NUMBER DEFAULT NULL, -- report line id
    -- below fields are used for per diem category only
    p_daily_breakup_id              IN      OIE_PDM_NUMBER_T DEFAULT NULL, -- array of unique identifer for daily breakups
    p_start_date                    IN      OIE_PDM_DATE_T DEFAULT NULL, -- array of start date
    p_end_date                      IN      OIE_PDM_DATE_T DEFAULT NULL,-- array of end date
    p_amount                        IN      OIE_PDM_NUMBER_T DEFAULT NULL,-- array of amount
    p_number_of_meals               IN      OIE_PDM_NUMBER_T DEFAULT NULL,-- array of number of meals
    p_meals_amount                  IN      OIE_PDM_NUMBER_T DEFAULT NULL,-- array of meals amount
    p_breakfast_flag                IN      OIE_PDM_VARCHAR_1_T DEFAULT NULL,-- array of breakfast flag
    p_lunch_flag                    IN      OIE_PDM_VARCHAR_1_T DEFAULT NULL, -- array of lunch flag
    p_dinner_flag                   IN      OIE_PDM_VARCHAR_1_T DEFAULT NULL, -- array of dinner flag
    p_accommodation_amount          IN      OIE_PDM_NUMBER_T DEFAULT NULL, -- array of accommodation amount
    p_accommodation_flag            IN      OIE_PDM_VARCHAR_1_T DEFAULT NULL, -- array of accommodation flag
    p_hotel_name                    IN      OIE_PDM_VARCHAR_80_T DEFAULT NULL, -- array of hotel name
    p_night_rate_Type               IN      OIE_PDM_VARCHAR_80_T DEFAULT NULL, -- array of night rate type
    p_night_rate_amount             IN      OIE_PDM_NUMBER_T DEFAULT NULL, -- array of night rate amount
    p_pdm_rate                      IN      OIE_PDM_NUMBER_T DEFAULT NULL, -- array of pdm rate
    p_rate_Type_code                IN      OIE_PDM_VARCHAR_80_T DEFAULT NULL, -- array of rate type code
    p_pdm_breakup_dest_id           IN      OIE_PDM_NUMBER_T DEFAULT NULL, -- array of unique identified for multiple destinations
    p_pdm_destination_id            IN      OIE_PDM_NUMBER_T DEFAULT NULL, -- array of locations for each breakup period
    p_dest_start_date               IN      OIE_PDM_DATE_T DEFAULT NULL, -- array of start date for each location
    p_dest_end_date                 IN      OIE_PDM_DATE_T DEFAULT NULL,-- array of end date for each location
    p_location_id                   IN      OIE_PDM_NUMBER_T DEFAULT NULL, -- array of locations
    -- bug 5358186
    p_cust_meals_amount             IN OUT  NOCOPY OIE_PDM_NUMBER_T, -- array of modified meals amount
    p_cust_accommodation_amount     IN OUT  NOCOPY OIE_PDM_NUMBER_T,-- array of modified accommodation amount
    p_cust_night_rate_amount        IN OUT  NOCOPY OIE_PDM_NUMBER_T,-- array of modified night rate amount
    p_cust_pdm_rate                 IN OUT  NOCOPY OIE_PDM_NUMBER_T-- array of modified pdm rate
        );

FUNCTION CustomValidateCostCenter(
        p_cs_error              OUT NOCOPY VARCHAR2,
        p_CostCenterValue       IN  AP_EXPENSE_FEED_DISTS.cost_center%TYPE,
        p_CostCenterValid       IN OUT NOCOPY BOOLEAN,
        p_employee_id           IN NUMBER DEFAULT null) return BOOLEAN;

FUNCTION CustomDefaultCostCenter(
        p_employee_id           IN NUMBER) return VARCHAR2;

PROCEDURE CustomValidateLine(
  p_exp_header_info	IN AP_WEB_DFLEX_PKG.ExpReportHeaderRec,
  p_exp_line_info	IN AP_WEB_DFLEX_PKG.ExpReportLineRec,
  p_custom_fields_array	IN AP_WEB_DFLEX_PKG.CustomFields_A,
  p_message_array       IN OUT NOCOPY AP_WEB_UTILITIES_PKG.expError);

-- Bug: 7365109, Custom Validate the address style
FUNCTION CustomGetCountyProvince(
  p_addressstyle  IN             per_addresses.style%TYPE,
  p_region        IN OUT NOCOPY  per_addresses.region_1%TYPE) return BOOLEAN;


END AP_WEB_CUST_DFLEX_PKG;

/
