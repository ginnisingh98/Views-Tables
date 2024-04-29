--------------------------------------------------------
--  DDL for Package PAY_US_TAX_BALS_ADJ_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_TAX_BALS_ADJ_API" AUTHID CURRENT_USER AS
/* $Header: pytbaapi.pkh 120.1.12010000.2 2009/03/24 14:30:43 tclewis ship $ */
/*#
 * This package contains US Tax Balance Adjustments API.
 * @rep:scope public
 * @rep:product per
 * @rep:displayname Tax Balance Adjustment for United States
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_tax_balance_adjustment >-------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
/*#
 * Validations specific to US Payroll is done throug this API subsequent to
 * which adjustment records are created.
 *
 * Tax adjustments are made for an assignment within a jurisdiction if taxes
 * exist for that jurisdiction.
 *
 * <p><b>Licensing</b><br>
 * This API is licensed for use with Human Resources.
 *
 * <p><b>Prerequisites</b><br>
 * An assignment record must exist in that Business Group.
 *
 * <p><b>Post Success</b><br>
 * Balance adjustment records are created for that assignment.
 *
 * <p><b>Post Failure</b><br>
 * If the validations fail the process errors out.
 * @param p_validate If true, then validation alone will be performed and the
 * database will remain unchanged. If false and all validation checks pass,
 * then the database will be modified.
 * @param p_adjustment_date {@rep:casecolumn
 * PAY_PAYROLL_ACTIONS.EFFECTIVE_DATE}
 * @param p_business_group_name Business Group Name.
 * @param p_assignment_number Assignment Number for the assignment.
 * @param p_tax_unit_id {@rep:casecolumn PAY_ASSIGNMENT_ACTIONS.TAX_UNIT_ID}
 * @param p_consolidation_set {@rep:casecolumn
 * PAY_CONSOLIDATION_SETS.CONSOLIDATION_SET_ID}
 * @param p_earning_element_type {@rep:casecolumn PAY_BALANCE_TYPES.TAX_TYPE}
 * @param p_gross_amount Gross Amount entered for adjustments.
 * @param p_net_amount Net Amount entered for adjustment.
 * @param p_fit FIT Adjustment Amount
 * @param p_fit_third Flag to indicate if FIT was withheld by third party.
 * @param p_ss SS Adjustment Amount
 * @param p_medicare Medicare Adjustment Amount
 * @param p_sit SIT Adjustment Amonut
 * @param p_sui SUI Adjustment Amount
 * @param p_sdi SDI Adjustment Amount
 * @param p_county County Adjustment Amount
 * @param p_city City Adjustment Amount
 * @param p_city_name {@rep:casecolumn PAY_US_CITY_NAMES.CITY_NAME}
 * @param p_state_abbrev {@rep:casecolumn PAY_US_STATES.STATE_ABBREV}
 * @param p_county_name {@rep:casecolumn PAY_US_COUNTIES.COUNTY_NAME}
 * @param p_zip_code {@rep:casecolumn PER_ADDRESSES.POSTAL_CODE}
 * @param p_balance_adj_costing_flag Flag to indicate if adjustment action gets
 * costed.
 * @param p_balance_adj_prepay_flag Flag to indicate if adjustment action gets
 * prepaid.
 * @param p_futa_er FUTA Employer Adjustment Amount
 * @param p_sui_er SUI Employer Adjustment Amount
 * @param p_sdi_er SDI Employer Adjustment Amount
 * @param p_sch_dist_wh_ee School district withheld adjustment amount.
 * @param p_sch_dist_jur Jurisdiction Code for school district.
 * @param p_payroll_action_id Payroll action id of the record created in
 * pay_payroll_actions.
 * @param p_create_warning Indicates warning if hr_utility.check_warning is set
 * to true.
 * @rep:displayname Create Tax Balance Adjustment
 * @rep:category BUSINESS_ENTITY PAY_BALANCE_ADJUSTMENT
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:ihelp PER/@scalapi APIs in Oracle HRMS
*/
--
-- {End Of Comments}
--
PROCEDURE create_tax_balance_adjustment(
	--
	-- Common parameters
	--
        p_validate              IN BOOLEAN     	DEFAULT FALSE,
	p_adjustment_date	IN DATE,
	p_business_group_name	IN VARCHAR2,
	p_assignment_number	IN VARCHAR2,
	p_tax_unit_id     	IN VARCHAR2,
	p_consolidation_set	IN VARCHAR2,
	--
	-- Earnings
	--
	p_earning_element_type	IN VARCHAR2 	DEFAULT null,
	p_gross_amount		IN NUMBER	DEFAULT 0,
	p_net_amount		IN NUMBER	DEFAULT 0,
	--
	-- Taxes withheld
	--
	p_FIT			IN NUMBER	DEFAULT 0,
	p_FIT_THIRD		IN VARCHAR2	DEFAULT null,
	p_SS			IN NUMBER	DEFAULT 0,
	p_Medicare		IN NUMBER	DEFAULT 0,
	p_SIT			IN NUMBER	DEFAULT 0,
	p_SUI			IN NUMBER	DEFAULT 0,
	p_SDI			IN NUMBER	DEFAULT 0,
	p_SDI1		IN NUMBER	DEFAULT 0,
	p_County		IN NUMBER	DEFAULT 0,
	p_City			IN NUMBER	DEFAULT 0,
	--
	-- Location parameters
	--
	p_city_name		IN VARCHAR2	DEFAULT null,
	p_state_abbrev		IN VARCHAR2	DEFAULT null,
	p_county_name		IN VARCHAR2	DEFAULT null,
	p_zip_code		IN VARCHAR2	DEFAULT null,
	p_balance_adj_costing_flag IN VARCHAR2	DEFAULT null,
        p_balance_adj_prepay_flag IN VARCHAR2   DEFAULT 'N',
        p_futa_er               IN NUMBER       DEFAULT 0,
        p_sui_er                IN NUMBER       DEFAULT 0,
        p_sdi_er                IN NUMBER       DEFAULT 0,
        p_sch_dist_wh_ee        IN NUMBER       DEFAULT 0,
        p_sch_dist_jur          IN VARCHAR2     DEFAULT null,
        --
        p_payroll_action_id     OUT NOCOPY NUMBER,
        p_create_warning        OUT NOCOPY BOOLEAN
	)
;

END pay_us_tax_bals_adj_api;

/
