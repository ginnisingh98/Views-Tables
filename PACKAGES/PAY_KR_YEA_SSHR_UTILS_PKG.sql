--------------------------------------------------------
--  DDL for Package PAY_KR_YEA_SSHR_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_KR_YEA_SSHR_UTILS_PKG" 
/* $Header: pykryutl.pkh 120.7.12010000.9 2010/01/27 14:30:52 vaisriva ship $ */
AUTHID CURRENT_USER as

    function yea_entry_status(p_assignment_id number,
                              p_target_year varchar2)
    return varchar2;
    -------------------------------------------------------
    function get_URL(p_file_type varchar2,
                             p_request_id number,
                             p_gwy_uid varchar2,
                             p_two_task varchar2) return varchar2;
    -------------------------------------------------------
    function get_total_taxable(p_assignment_id number,
                               p_effective_date date)
    return number;
    -------------------------------------------------------
    function get_total_itax( p_assignment_id number,
                             p_effective_date date)
    return number;
    -------------------------------------------------------
    function get_total_rtax( p_assignment_id number,
                             p_effective_date date)
    return number;
    -------------------------------------------------------
    function get_total_stax( p_assignment_id number,
                             p_effective_date date)
    return number;

    -------------------------------------------------------
    function get_ovs_processed( p_assignment_id number,
                             p_effective_date date)
    return number;
    -------------------------------------------------------
    procedure insert_fnd_sessions ( p_effective_date   in varchar2
			      );
    -------------------------------------------------------
    procedure submit_yea_info(p_assignment_id    in varchar2,
                              p_target_year      in varchar2,
                              p_effective_date   in varchar2,
                              p_return_status    out nocopy varchar2,
                              p_return_message   out nocopy varchar2,
                              p_failed_record    out nocopy varchar2
                              );
    -------------------------------------------------------
    function update_allowed(p_business_group_id number,
                            p_assignment_id     number,
                            p_target_year       number,
                            p_effective_date    date)
    return varchar2;
    -------------------------------------------------------
    procedure run_validation_formula
                          ( P_BUSINESS_GROUP_ID                 in varchar2,
                            P_ASSIGNMENT_ID                     in varchar2,
                            P_TARGET_YEAR                       in varchar2,
                            P_EFFECTIVE_DATE                    in varchar2,
                            P_RETURN_MESSAGE                    out nocopy varchar2,
                            P_RETURN_STATUS                     out nocopy varchar2,
                            P_FF_MESSAGE0                       out nocopy varchar2,
                            P_FF_MESSAGE1                       out nocopy varchar2,
                            P_FF_MESSAGE2                       out nocopy varchar2,
                            P_FF_MESSAGE3                       out nocopy varchar2,
                            P_FF_MESSAGE4                       out nocopy varchar2,
                            P_FF_MESSAGE5                       out nocopy varchar2,
                            P_FF_MESSAGE6                       out nocopy varchar2,
                            P_FF_MESSAGE7                       out nocopy varchar2,
                            P_FF_MESSAGE8                       out nocopy varchar2,
                            P_FF_MESSAGE9                       out nocopy varchar2,
                            P_FF_RETURN_STATUS                  out nocopy varchar2,
                            ---------------- Special tax ---------------------
                            P_EE_EDUC_EXP                       in varchar2,
                            P_HOUSING_SAVING_TYPE               in varchar2,
                            P_HOUSING_SAVING                    in varchar2,
                            P_HOUSING_PURCHASE_DATE             in varchar2,
                            P_HOUSING_LOAN_DATE                 in varchar2,
                            P_HOUSING_LOAN_REPAY                in varchar2,
                            P_LT_HOUSING_LOAN_DATE              in varchar2,
                            P_LT_HOUSING_LOAN_INTEREST_REP      in varchar2,
                            P_DONATION1                         in varchar2,
                            P_POLITICAL_DONATION1               in varchar2,
                            P_HI_PREM                           in varchar2,
                            P_POLITICAL_DONATION2               in varchar2,
                            P_POLITICAL_DONATION3               in varchar2,
                            P_DONATION2                         in varchar2,
                            P_DONATION3                         in varchar2,
                            P_MED_EXP_EMP                       in varchar2,
                            P_LT_HOUSING_LOAN_DATE_1            in varchar2,
                            P_LT_HOUSING_LOAN_INT_REPAY_1       in varchar2,
                            P_MFR_MARRIAGE_OCCASIONS            in varchar2,
                            P_MFR_FUNERAL_OCCASIONS             in varchar2,
                            P_MFR_RELOCATION_OCCASIONS          in varchar2,
                            P_EI_PREM                           in varchar2,
                            P_ESOA_DONATION                     in varchar2,
                            P_PERS_INS_NAME                     in varchar2,
                            P_PERS_INS_PREM                     in varchar2,
                            P_DISABLED_INS_PREM                 in varchar2,
                            P_MED_EXP                           in varchar2,
                            P_MED_EXP_DISABLED                  in varchar2,
                            P_MED_EXP_AGED                      in varchar2,
                            P_EE_OCCUPATION_EDUC_EXP            in varchar2,
                            ----------------- FW Tax Break --------------------
                            P_IMMIGRATION_PURPOSE               in varchar2,
                            P_CONTRACT_DATE                     in varchar2,
                            P_EXPIRY_DATE                       in varchar2,
                            P_STAX_APPLICABLE_FLAG              in varchar2,
                            P_FW_APPLICATION_DATE               in varchar2,
                            P_FW_SUBMISSION_DATE                in varchar2,
                            ----------------- OVS Tax Break -------------------
                            P_TAX_PAID_DATE                     in varchar2,
                            P_OVS_SUBMISSION_DATE               in varchar2,
                            P_KR_OVS_LOCATION                   in varchar2,
                            P_KR_OVS_WORK_PERIOD                in varchar2,
                            P_KR_OVS_RESPONSIBILITY             in varchar2,
                            P_TERRITORY_CODE                    in varchar2,
                            P_CURRENCY_CODE                     in varchar2,
                            P_TAXABLE                           in varchar2,
                            P_TAXABLE_SUBJ_TAX_BREAK            in varchar2,
                            P_TAX_BREAK_RATE                    in varchar2,
                            P_TAX_FOREIGN_CURRENCY              in varchar2,
                            P_TAX                               in varchar2,
                            P_OVS_APPLICATION_DATE              in varchar2,
                            ----------------- Tax Break Info ------------------
                            P_HOUSING_LOAN_INTEREST_REPAY       in varchar2,
                            P_STOCK_SAVING                      in varchar2,
                            P_LT_STOCK_SAVING1                  in varchar2,
                            P_LT_STOCK_SAVING2                  in varchar2,
                            ----------------- Tax Exems  ----------------------
                            P_DIRECT_CARD_EXP                   in varchar2,
                            P_DPNT_DIRECT_EXP                   in varchar2,
                            P_GIRO_TUITION_PAID_EXP             in varchar2,
                            P_CASH_RECEIPT_EXP                  in varchar2,
                            P_NP_PREM                           in varchar2,
                            P_PERS_PENSION_PREM                 in varchar2,
                            P_PERS_PENSION_SAVING               in varchar2,
                            P_INVEST_PARTNERSHIP_FIN1           in varchar2,
                            P_INVEST_PARTNERSHIP_FIN2           in varchar2,
                            P_CREDIT_CARD_EXP                   in varchar2,
                            P_EMP_STOCK_OWN_PLAN_CONTRI         in varchar2,
                            P_CREDIT_CARD_EXP_DPNT              in varchar2,
			    P_PEN_PREM				in varchar2,	-- Bug 6024342
                            P_LTCI_PREM                         in varchar2     -- Bug 7260606
                          );

    -------------------------------------------------------
    procedure change_access(P_ASSIGNMENT_ID                     in varchar2,
                            P_TARGET_YEAR                       in varchar2,
                            P_RESULT                            out nocopy varchar2);


    -------------------------------------------------------
    procedure get_balances(P_ASSIGNMENT_ID                     in varchar2,
                           P_TARGET_YEAR                       in varchar2,
                           P_EFFECTIVE_DATE                    in varchar2,
                           P_ITAX                              out nocopy varchar2,
                           P_STAX                              out nocopy varchar2,
                           P_RTAX                              out nocopy varchar2,
                           P_TAXABLE                           out nocopy varchar2,
                           P_OVS_PROCESSED                     out nocopy varchar2,
                           P_TOTAL_TAXABLE_KRW                 out nocopy varchar2,
                           P_HI_PREM_EE                        out nocopy varchar2,  -- Bug 5372366
                           P_EI_PREM                           out nocopy varchar2,  -- Bug 5372366
                           P_NP_PREM_EE                        out nocopy varchar2,  -- Bug 5185309
			   P_PEN_PREM_BAL		       out nocopy varchar2,  -- Bug 6024342
                           P_LTCI_PREM_EE                      out nocopy varchar2); -- Bug 7260606
    -------------------------------------------------------
    procedure delete_all_records(
                           P_ASSIGNMENT_ID                     in varchar2,
                           P_TARGET_YEAR                       in varchar2);
    -------------------------------------------------------
    procedure get_dependent_information(
                           P_ASSIGNMENT_ID                     in varchar2,
                           P_EFFECTIVE_DATE                    in varchar2,
                           P_SPOUSE_EXEM                       out nocopy varchar2,
                           P_AGED_DEPENDENTS                   out nocopy varchar2,
                           P_ADULT_DEPENDENTS                  out nocopy varchar2,
                           P_UNDERAGED_DEPENDENTS              out nocopy varchar2,
                           P_TOTAL_DEPENDENTS                  out nocopy varchar2,
                           P_TOTAL_AGEDS                       out nocopy varchar2,
                           P_TOTAL_DISABLED                    out nocopy varchar2,
                           P_FEMALE_EXEM                       out nocopy varchar2,
                           P_TOTAL_CHILDREN                    out nocopy varchar2,
                           P_TOTAL_SUPER_AGEDS                 out nocopy varchar2,
			   P_NEW_BORN_ADOPTED                  out nocopy varchar2, -- Bug  6705170
                           P_HOUSE_HOLDER                      out nocopy varchar2,
                           P_HOUSE_HOLDER_CODE                 out nocopy varchar2);
    -------------------------------------------------------
    procedure update_house_holder(
                           p_person_id          in varchar2,
                           p_house_holder_code  in varchar2);
    -------------------------------------------------------
    -- Bug 6849941: Credit Card Validation Checks
    --
    procedure enable_credit_card(
	p_person_id                     in         number,
	p_contact_person_id             in         number,
	p_contact_relationship_id	in         number,
	p_date_earned			in         varchar2,
	p_result			out nocopy varchar2);
    -------------------------------------------------------
    -- Bug 7142612
    --
    procedure enable_donation_fields(
	p_person_id                     in         number,
	p_contact_person_id             in         number,
	p_contact_relationship_id	in         number,
	p_date_earned			in         varchar2,
	p_result			out nocopy varchar2);
    -------------------------------------------------------
    -- Bug 7142612
    --
    procedure validate_bus_reg_num(
	p_national_identifier in varchar2,
	p_result	      out nocopy varchar2);
    -------------------------------------------------------
    -- Bug 7633302
    ---------------------------------------------------------
    procedure detail_exists(
    	p_ayi_information6		in	 number,
    	p_assignment_id			in	 number,
    	p_target_year			in	 number,
    	p_result			out nocopy varchar2);
   ---------------------------------------------------------
   -- Bug 7633302
   ---------------------------------------------------------
   procedure chk_taxation_period_unique(
    	p_assignment_yea_info_id	in	 number,
    	p_assignment_id			in	 number,
	p_ayi_information2		in	 varchar2,
	p_ayi_information6		in	 varchar2,	-- Bug 9213683
    	p_target_year			in	 number,
    	p_result			out nocopy varchar2);
   ---------------------------------------------------------
   -- Bug 9079450
   ---------------------------------------------------------
   procedure aged_flag(
	p_national_identifier 	in varchar2,
        p_effective_date	in varchar2,
	p_result		out nocopy varchar2);
   ---------------------------------------------------------
end pay_kr_yea_sshr_utils_pkg;

/
