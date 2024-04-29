--------------------------------------------------------
--  DDL for Package PAY_KR_YEA_FORM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_KR_YEA_FORM_PKG" AUTHID CURRENT_USER as
/* $Header: pykryeaf.pkh 120.5.12010000.2 2008/11/26 16:30:02 vaisriva ship $ */
-------------------------------------------------------------------------------------------------------
procedure chk_detail_medical_record
        (
          p_effective_date           in date,
          p_assignment_id            in per_assignment_extra_info.assignment_id%type,
          p_provider_reg_no          in per_assignment_extra_info.aei_information1%type,
          p_provider_reg_name        in per_assignment_extra_info.aei_information1%type,
          p_res_reg_no               in per_assignment_extra_info.aei_information1%type,
          p_relationship             in per_assignment_extra_info.aei_information1%type,
          p_disabled_aged            in per_assignment_extra_info.aei_information1%type,
          p_total_employee           in out  nocopy  per_assignment_extra_info.aei_information1%type,
          p_total_dependent          in out  nocopy  per_assignment_extra_info.aei_information1%type,
          p_total_aged               in out  nocopy  per_assignment_extra_info.aei_information1%type,
          p_total_disabled           in out  nocopy  per_assignment_extra_info.aei_information1%type,
          p_total_card_exp           in out  nocopy  per_assignment_extra_info.aei_information1%type,
          p_inv_provider_name        out     nocopy  varchar2,
          p_inv_relationship         out     nocopy  varchar2,
          p_inv_aged_disabled        out     nocopy  varchar2
        );
-------------------------------------------------------------------------------------------------------
function chk_dup_recipient_name (
          p_effective_date 	in	date,
          p_assignment_id	in	per_assignment_extra_info.assignment_id%type,
          p_recipient_reg_no	in	per_assignment_extra_info.aei_information1%type,
          p_recipient_name	in	per_assignment_extra_info.aei_information1%type,
	  p_stat_total		in out nocopy per_assignment_extra_info.aei_information1%type,
	  p_pol_total		in out nocopy per_assignment_extra_info.aei_information1%type,
	  p_prom_fund_total	in out nocopy per_assignment_extra_info.aei_information1%type,
	  p_tax_redn_total	in out nocopy per_assignment_extra_info.aei_information1%type,
	  p_specified_total	in out nocopy per_assignment_extra_info.aei_information1%type,
	  p_religious_total	in out nocopy per_assignment_extra_info.aei_information1%type,
	  p_esoa_total		in out nocopy per_assignment_extra_info.aei_information1%type,
	  p_others_total	in out nocopy per_assignment_extra_info.aei_information1%type,
	  p_public_legal_total	in out nocopy per_assignment_extra_info.aei_information1%type
) return varchar2 ;   -- Bug 7142612
-------------------------------------------------------------------------------------------------------
function get_donation_tax_break(p_effective_date IN VARCHAR2,
				p_political_donation IN NUMBER) return number;
-------------------------------------------------------------------------------------------------------
end pay_kr_yea_form_pkg;

/
