--------------------------------------------------------
--  DDL for Package PER_KR_EXTRA_AEI_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_KR_EXTRA_AEI_RULES" AUTHID CURRENT_USER as
/* $Header: pekrexae.pkh 120.0.12010000.7 2010/01/27 14:01:10 vaisriva ship $ */
--
procedure chk_information_type_unique(
            p_assignment_extra_info_id  in number,
            p_assignment_id             in number,
            p_information_type          in varchar2,
            p_aei_information1          in varchar2);
--
procedure chk_insert_update(
            p_assignment_id             in number,
            p_information_type          in varchar2,
            p_aei_information1          in varchar2,
            p_aei_information3          in varchar2,
            p_aei_information12         in varchar2,
            p_aei_information13         in varchar2);  -- Bug 7142612
--
procedure chk_delete(
            p_assignment_id_o             in number,
            p_information_type_o          in varchar2,
            p_aei_information1_o          in varchar2,
            p_aei_information3_o          in varchar2,
            p_aei_information12_o         in varchar2,
            p_aei_information13_o         in varchar2);  -- Bug 7142612
--
procedure chk_taxation_period_unique(
            p_assignment_extra_info_id  in number,
            p_assignment_id             in number,
            p_information_type          in varchar2,
            p_aei_information1          in varchar2,
            p_aei_information2          in varchar2,
            p_aei_information3          in varchar2,
            p_aei_information4          in varchar2,
            p_aei_information5          in varchar2,   -- Bug 7633302
            p_aei_information7          in varchar2);	-- Bug 9213683
--
procedure chk_med_insert_update(
            p_assignment_id             in number,
            p_information_type          in varchar2,
            p_aei_information1          in varchar2);   -- Bug 8200240
--
procedure chk_med_delete(
            p_assignment_id_o             in number,
            p_information_type_o          in varchar2,
            p_aei_information1_o          in varchar2); -- Bug 8200240
--
procedure chk_ntax_earn_unique(
            p_assignment_extra_info_id  in number,
            p_assignment_id             in number,
            p_information_type          in varchar2,
            p_aei_information1          in varchar2,
            p_aei_information2          in varchar2,
            p_aei_information4          in varchar2);   -- Bug 8644512
--
procedure chk_dpnt_educ_insert_update(
            p_assignment_id             in number,
            p_information_type          in varchar2,
            p_aei_information1          in varchar2,
            p_aei_information6          in varchar2,
            p_aei_information7          in varchar2); -- Bug 9079450
--
procedure chk_dpnt_educ_delete(
            p_assignment_id_o             in number,
            p_information_type_o          in varchar2,
            p_aei_information1_o          in varchar2); -- Bug 9079450
--
procedure eligible_for_med_exem_aged(
            p_aei_information7 		in varchar2,
            p_aei_information8 		in varchar2,
            p_aei_information9 		in varchar2,
            p_information_type          in varchar2,
            p_aei_information1          in varchar2); -- Bug 9079450
--
end per_kr_extra_aei_rules;

/
