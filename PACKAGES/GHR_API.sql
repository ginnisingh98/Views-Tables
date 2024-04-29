--------------------------------------------------------
--  DDL for Package GHR_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_API" AUTHID CURRENT_USER AS
/* $Header: ghapiapi.pkh 120.13 2007/12/03 09:32:51 managarw noship $ */
--
--  Internal ghr_api globals
--
g_package       constant varchar2(33) := '  ghr_api.';
g_api_dml  boolean := false;                               -- Global api dml status

--  Record Types
--  Provided by Levin Mootoosamy
--
type extra_info_rec_type is record
	(l_extra_info_id                per_assignment_extra_info.assignment_extra_info_id%type
	,l_object_version_number        per_assignment_extra_info.object_version_number%type
	,l_information1                 per_assignment_extra_info.aei_information1%type
	,l_information2                 per_assignment_extra_info.aei_information2%type
	,l_information3                 per_assignment_extra_info.aei_information3%type
	,l_information4                 per_assignment_extra_info.aei_information4%type
	,l_information5                 per_assignment_extra_info.aei_information5%type
	,l_information6                 per_assignment_extra_info.aei_information6%type
	,l_information7                 per_assignment_extra_info.aei_information7%type
	,l_information8                 per_assignment_extra_info.aei_information8%type
	,l_information9                 per_assignment_extra_info.aei_information9%type
	,l_information10                per_assignment_extra_info.aei_information10%type
	,l_information11                per_assignment_extra_info.aei_information11%type
	,l_information12                per_assignment_extra_info.aei_information12%type
	,l_information13                per_assignment_extra_info.aei_information13%type
	,l_information14                per_assignment_extra_info.aei_information14%type
	,l_information15                per_assignment_extra_info.aei_information15%type
	,l_information16                per_assignment_extra_info.aei_information16%type
	,l_information17                per_assignment_extra_info.aei_information17%type
	,l_information18                per_assignment_extra_info.aei_information18%type
	,l_information19                per_assignment_extra_info.aei_information19%type
	,l_information20                per_assignment_extra_info.aei_information20%type
	,l_information21                per_assignment_extra_info.aei_information21%type
	,l_information22                per_assignment_extra_info.aei_information22%type
	,l_information23                per_assignment_extra_info.aei_information23%type
	,l_information24                per_assignment_extra_info.aei_information24%type
	,l_information25                per_assignment_extra_info.aei_information25%type
	,l_information26                per_assignment_extra_info.aei_information26%type
	,l_information27                per_assignment_extra_info.aei_information27%type
	,l_information28                per_assignment_extra_info.aei_information28%type
	,l_information29                per_assignment_extra_info.aei_information29%type
	,l_information30                per_assignment_extra_info.aei_information30%type);
--
type generic_extra_info_rec_type is record
	(l_extra_info_id                per_assignment_extra_info.assignment_extra_info_id%type
	,l_object_version_number        per_assignment_extra_info.object_version_number%type
	,l_information1                 per_assignment_extra_info.aei_information1%type
	,l_information2                 per_assignment_extra_info.aei_information2%type
	,l_information3                 per_assignment_extra_info.aei_information3%type
	,l_information4                 per_assignment_extra_info.aei_information4%type
	,l_information5                 per_assignment_extra_info.aei_information5%type
	,l_information6                 per_assignment_extra_info.aei_information6%type
	,l_information7                 per_assignment_extra_info.aei_information7%type
	,l_information8                 per_assignment_extra_info.aei_information8%type
	,l_information9                 per_assignment_extra_info.aei_information9%type
	,l_information10                per_assignment_extra_info.aei_information10%type
	,l_information11                per_assignment_extra_info.aei_information11%type
	,l_information12                per_assignment_extra_info.aei_information12%type
	,l_information13                per_assignment_extra_info.aei_information13%type
	,l_information14                per_assignment_extra_info.aei_information14%type
	,l_information15                per_assignment_extra_info.aei_information15%type
	,l_information16                per_assignment_extra_info.aei_information16%type
	,l_information17                per_assignment_extra_info.aei_information17%type
	,l_information18                per_assignment_extra_info.aei_information18%type
	,l_information19                per_assignment_extra_info.aei_information19%type
	,l_information20                per_assignment_extra_info.aei_information20%type
	,l_information21                per_assignment_extra_info.aei_information21%type
	,l_information22                per_assignment_extra_info.aei_information22%type
	,l_information23                per_assignment_extra_info.aei_information23%type
	,l_information24                per_assignment_extra_info.aei_information24%type
	,l_information25                per_assignment_extra_info.aei_information25%type
	,l_information26                per_assignment_extra_info.aei_information26%type
	,l_information27                per_assignment_extra_info.aei_information27%type
	,l_information28                per_assignment_extra_info.aei_information28%type
	,l_information29                per_assignment_extra_info.aei_information29%type
	,l_information30                per_assignment_extra_info.aei_information30%type);
--
type asg_sf52_type is record
	(asg_sf52_flag                  varchar2(1)
	,assignment_extra_info_id       per_assignment_extra_info.assignment_extra_info_id%type
	,object_version_number          per_assignment_extra_info.object_version_number%type
	,step_or_rate                   per_assignment_extra_info.aei_information3%type
	,tenure                         per_assignment_extra_info.aei_information4%type
	,annuitant_indicator            per_assignment_extra_info.aei_information5%type
    ,pay_rate_determinant           per_assignment_extra_info.aei_information6%type
    ,work_schedule                  per_assignment_extra_info.aei_information7%type
    ,part_time_hours                per_assignment_extra_info.aei_information8%type
    -- FWFA Changes Bug#4444609
    ,calc_pay_table                 per_assignment_extra_info.aei_information9%type
    -- FWFA Changes
        );
--
-- Bug 2431934
type      ghr_gbx_tab_type is table of ghr_groupboxes%rowtype
                   index by binary_integer;
   ghr_gbx_tab   ghr_gbx_tab_type;
   ghr_gbx_index binary_integer;
type      ghr_gbx_user_tab_type is table of ghr_groupbox_users%rowtype
                   index by binary_integer;
   ghr_gbx_user_new_tab   ghr_gbx_user_tab_type;
   ghr_gbx_user_old_tab   ghr_gbx_user_tab_type;
   ghr_gbx_user_index binary_integer;
-- Bug 2431934

type asg_non_sf52_type is record
	(asg_non_sf52_flag              varchar2(1)
	,assignment_extra_info_id       per_assignment_extra_info.assignment_extra_info_id%type
	,object_version_number          per_assignment_extra_info.object_version_number%type
	,date_arr_personnel_office      per_assignment_extra_info.aei_information3%type
	,duty_status                    per_assignment_extra_info.aei_information4%type
	,key_emer_essential_empl        per_assignment_extra_info.aei_information5%type
	,non_disc_agmt_status           per_assignment_extra_info.aei_information6%type
	,date_wtop_exemp_expires        per_assignment_extra_info.aei_information7%type
	,parttime_indicator             per_assignment_extra_info.aei_information8%type
	,qualification_standard_waiver  per_assignment_extra_info.aei_information9%type
	,trainee_promotion_id           per_assignment_extra_info.aei_information10%type
	,date_trainee_promotion_expt    per_assignment_extra_info.aei_information11%type);
--
type asg_nte_dates_type is record
	(asg_nte_dates_flag             varchar2(1)
	,assignment_extra_info_id       per_assignment_extra_info.assignment_extra_info_id%type
	,object_version_number          per_assignment_extra_info.object_version_number%type
      ,asg_nte_start_date             per_assignment_extra_info.aei_information3%type
	,assignment_nte                 per_assignment_extra_info.aei_information4%type
      ,lwop_nte_start_date            per_assignment_extra_info.aei_information5%type
	,lwop_nte                       per_assignment_extra_info.aei_information6%type
      ,suspension_nte_start_date      per_assignment_extra_info.aei_information7%type
     	,suspension_nte                 per_assignment_extra_info.aei_information8%type
     	,furlough_nte_Start_date        per_assignment_extra_info.aei_information9%type
    	,furlough_nte                   per_assignment_extra_info.aei_information10%type
	,lwp_nte_start_date             per_assignment_extra_info.aei_information11%type
      ,lwp_nte                        per_assignment_extra_info.aei_information12%type
      ,sabatical_nte                  per_assignment_extra_info.aei_information13%type
      ,sabatical_nte_start_date      per_assignment_extra_info.aei_information14%type
    	,assignment_number              per_assignment_extra_info.aei_information15%type
      ,position_change_nte            per_assignment_extra_info.aei_information16%type);

--
type loc_info_type is record
	(loc_info_flag                  varchar2(1)
	,location_extra_info_id         hr_location_extra_info.location_extra_info_id%type
	,object_version_number          hr_location_extra_info.object_version_number%type
	,duty_station_id                hr_location_extra_info.lei_information3%type
);
--
type per_sf52_type is record
	(per_sf52_flag                  varchar2(1)
	,person_extra_info_id           per_people_extra_info.person_extra_info_id%type
	,object_version_number          per_people_extra_info.object_version_number%type
	,citizenship                    per_people_extra_info.pei_information3%type
	,veterans_preference            per_people_extra_info.pei_information4%type
	,veterans_preference_for_rif    per_people_extra_info.pei_information5%type
	,veterans_status                per_people_extra_info.pei_information6%type);
--
-- Bug#4486823 added retention_incentive_review_date
-- --Bug# 4941984(AFHR2) added columns org_appointment_desc1,org_appointment_desc2
type per_group1_type is record
	( per_group1_flag               varchar2(1)
	,person_extra_info_id           per_people_extra_info.person_extra_info_id%type
	,object_version_number          per_people_extra_info.object_version_number%type
	,appointment_type               per_people_extra_info.pei_information3%type
	,type_of_employment             per_people_extra_info.pei_information4%type
	,race_national_origin           per_people_extra_info.pei_information5%type
	,date_last_promotion            per_people_extra_info.pei_information6%type
	,agency_code_transfer_from      per_people_extra_info.pei_information7%type
	,org_appointment_auth_code1     per_people_extra_info.pei_information8%type
    ,org_appointment_desc1          per_people_extra_info.pei_information22%type
	,org_appointment_auth_code2     per_people_extra_info.pei_information9%type
    ,org_appointment_desc2          per_people_extra_info.pei_information23%type
	,country_world_citizenship      per_people_extra_info.pei_information10%type
	,handicap_code                  per_people_extra_info.pei_information11%type
	,consent_id                     per_people_extra_info.pei_information12%type
	,date_fehb_eligibility_expires  per_people_extra_info.pei_information13%type
	,date_temp_eligibility_fehb     per_people_extra_info.pei_information14%type
	,date_febh_dependent_cert_exp   per_people_extra_info.pei_information15%type
	,family_member_emp_pref         per_people_extra_info.pei_information16%type
	,family_member_status           per_people_extra_info.pei_information17%type
    ,retention_inc_review_date      per_people_extra_info.pei_information21%type);
--
type per_group2_type is record
	(per_group2_flag                varchar2(1)
	,person_extra_info_id           per_people_extra_info.person_extra_info_id%type
	,object_version_number          per_people_extra_info.object_version_number%type
	,obligated_position_number      per_people_extra_info.pei_information3%type
	,obligated_position_type        per_people_extra_info.pei_information4%type
	,date_overseas_tour_expires     per_people_extra_info.pei_information5%type
	,date_return_rights_expires     per_people_extra_info.pei_information6%type
	,date_stat_return_rights_expir  per_people_extra_info.pei_information7%type
	,civilian_duty_stat_contigency  per_people_extra_info.pei_information8%type
	,date_travel_agmt_pcs_expires   per_people_extra_info.pei_information9%type
	,draw_down_action_id            per_people_extra_info.pei_information10%type);
--
-- 4352589 BEN_EIT Created new benefits EIT Type
type per_benefit_info_type is record
	( per_benefit_info_flag         varchar2(1)
	,person_extra_info_id           per_people_extra_info.person_extra_info_id%type
	,object_version_number          per_people_extra_info.object_version_number%type
	,FEGLI_Date_Eligibility_Expires per_people_extra_info.pei_information3%type
	,FEHB_Date_Eligibility_expires  per_people_extra_info.pei_information4%type
	,FEHB_Date_temp_eligibility     per_people_extra_info.pei_information5%type
	,FEHB_Date_dependent_cert_expir per_people_extra_info.pei_information6%type
	,FEHB_LWOP_contingency_st_date  per_people_extra_info.pei_information7%type
	,FEHB_LWOP_contingency_end_date  per_people_extra_info.pei_information8%type
	,FEHB_Child_equiry_court_date   per_people_extra_info.pei_information10%type
	,FERS_Date_eligibility_expires  per_people_extra_info.pei_information11%type
	,FERS_Election_Date             per_people_extra_info.pei_information12%type
	,FERS_Election_Indicator        per_people_extra_info.pei_information13%type
	,TSP_Agncy_Contrib_Elig_date    per_people_extra_info.pei_information14%type
	,TSP_Emp_Contrib_Elig_date      per_people_extra_info.pei_information15%type
	-- 6312144  addition of new segments related to per_benefit_info
	,FEGLI_Assignment_Ind           per_people_extra_info.pei_information16%type
	,FEGLI_Post_Elec_Basic_Ins_Amt  per_people_extra_info.pei_information17%type
        ,FEGLI_Court_Order_Ind          per_people_extra_info.pei_information18%type
	,Desg_FEGLI_Benf_Ind            per_people_extra_info.pei_information19%type
	,FEHB_Event_Code                per_people_extra_info.pei_information20%type);
--
type per_scd_info_type is record
	(per_scd_info_flag              varchar2(1)
	,person_extra_info_id           per_people_extra_info.person_extra_info_id%type
	,object_version_number          per_people_extra_info.object_version_number%type
	,scd_leave                      per_people_extra_info.pei_information3%type
	,scd_civilian                   per_people_extra_info.pei_information4%type
	,scd_rif                        per_people_extra_info.pei_information5%type
	,scd_tsp                        per_people_extra_info.pei_information6%type
	,scd_retirement                 per_people_extra_info.pei_information7%type
	-- Bug 4164083 eHRI New Attributions
	,scd_ses                        per_people_extra_info.pei_information10%type
	,scd_spl_retirement             per_people_extra_info.pei_information11%type
	-- End Bug 4164083
	--Bug 4443968
	,scd_creditable_svc_annl_leave  per_people_extra_info.pei_information12%type
	);
--
type per_probations_type is record
	(per_probation_flag             varchar2(1)
	,person_extra_info_id           per_people_extra_info.person_extra_info_id%type
	,object_version_number          per_people_extra_info.object_version_number%type
	,date_prob_trial_period_begin   per_people_extra_info.pei_information3%type
	,date_prob_trial_period_ends    per_people_extra_info.pei_information4%type
    ,date_spvr_mgr_prob_begins      per_people_extra_info.pei_information8%type--Bug# 4588575
	,date_spvr_mgr_prob_ends        per_people_extra_info.pei_information5%type
	,spvr_mgr_prob_completion       per_people_extra_info.pei_information6%type
	,date_ses_prob_expires          per_people_extra_info.pei_information7%type);
--
type per_retained_grade_type is record
	(per_retained_grade_flag        varchar2(1)
	,person_extra_info_id           per_people_extra_info.person_extra_info_id%type
	,object_version_number          per_people_extra_info.object_version_number%type
      ,date_from		              per_people_extra_info.pei_information1%type
	,date_to	                    per_people_extra_info.pei_information2%type
      ,retain_grade                   per_people_extra_info.pei_information3%type
	,retain_step_or_rate            per_people_extra_info.pei_information4%type
	,retain_pay_plan                per_people_extra_info.pei_information5%type
	,retain_pay_table_id            per_people_extra_info.pei_information6%type
	,retain_locality_percent        per_people_extra_info.pei_information7%type
      ,retain_pay_basis               per_people_extra_info.pei_information8%type
      ,temp_step                     per_people_extra_info.pei_information9%type
      );
--
type per_sep_retire_type is record
	(per_sep_retire_flag            varchar2(1)
	,person_extra_info_id           per_people_extra_info.person_extra_info_id%type
	,object_version_number          per_people_extra_info.object_version_number%type
	,fers_coverage                  per_people_extra_info.pei_information3%type
	,prev_retirement_coverage       per_people_extra_info.pei_information4%type
	,frozen_service                 per_people_extra_info.pei_information5%type
	,naf_retirement_indicator       per_people_extra_info.pei_information6%type
	,reason_for_separation          per_people_extra_info.pei_information7%type
	,agency_code_transfer_to        per_people_extra_info.pei_information8%type
	,date_projected_retirement      per_people_extra_info.pei_information9%type
	,mandatory_retirement_date      per_people_extra_info.pei_information10%type
	,separate_pkg_status_indicator  per_people_extra_info.pei_information11%type
	,separate_pkg_register_number   per_people_extra_info.pei_information12%type
	,separate_pkg_pay_office_id     per_people_extra_info.pei_information13%type
	,date_ret_appl_received         per_people_extra_info.pei_information14%type
	,date_ret_pkg_sent_to_payroll   per_people_extra_info.pei_information15%type
	,date_ret_pkg_recv_payroll      per_people_extra_info.pei_information16%type
	,date_ret_pkg_to_opm            per_people_extra_info.pei_information17%type);
--
type per_security_type is record
	(per_security_flag              varchar2(1)
	,person_extra_info_id           per_people_extra_info.person_extra_info_id%type
	,object_version_number          per_people_extra_info.object_version_number%type
	,sec_investigation_basis        per_people_extra_info.pei_information3%type
	,type_of_sec_investigation      per_people_extra_info.pei_information4%type
	,date_sec_invest_required       per_people_extra_info.pei_information5%type
	,date_sec_invest_completed      per_people_extra_info.pei_information6%type
	,personnel_sec_clearance        per_people_extra_info.pei_information7%type
	,sec_clearance_eligilb_date     per_people_extra_info.pei_information8%type
	,prp_sci_status_employment      per_people_extra_info.pei_information9%type);
--
--  Bug#4486823 RRR Changes -- Added per_service_oblig_type record
type per_service_oblig_type is record
	(per_service_oblig_flag         varchar2(1)
	,person_extra_info_id           per_people_extra_info.person_extra_info_id%type
	,object_version_number          per_people_extra_info.object_version_number%type
	,service_oblig_type_code        per_people_extra_info.pei_information3%type
	,service_oblig_start_date       per_people_extra_info.pei_information4%type
	,service_oblig_end_date         per_people_extra_info.pei_information5%type);
--
-- modified 10/24/97
type per_conversions_type is record
	(per_conversions_flag           varchar2(1)
	,person_extra_info_id           per_people_extra_info.person_extra_info_id%type
	,object_version_number          per_people_extra_info.object_version_number%type
	,date_conv_career_begins        per_people_extra_info.pei_information3%type
	,date_conv_career_due           per_people_extra_info.pei_information4%type
	,date_recmd_conv_begins         per_people_extra_info.pei_information5%type
   	,date_recmd_conv_due            per_people_extra_info.pei_information7%type
	,date_vra_conv_due              per_people_extra_info.pei_information6%type);
    --Bug# 4588575 Segments are wrongly defined. modified the same

--
type per_uniformed_services_type is record
	(per_uniformed_services_flag    varchar2(1)
	,person_extra_info_id           per_people_extra_info.person_extra_info_id%type
	,object_version_number          per_people_extra_info.object_version_number%type
	,reserve_category               per_people_extra_info.pei_information3%type
	,military_recall_status         per_people_extra_info.pei_information4%type
	,creditable_military_service    per_people_extra_info.pei_information5%type
	,date_retired_uniform_service   per_people_extra_info.pei_information6%type
	,uniform_service_component      per_people_extra_info.pei_information7%type
	,uniform_service_designation    per_people_extra_info.pei_information8%type
	,retirement_grade               per_people_extra_info.pei_information9%type
	,military_retire_waiver_ind     per_people_extra_info.pei_information10%type
	,exception_retire_pay_ind       per_people_extra_info.pei_information11%type);
--
type pos_valid_grade_type is record
	(pos_valid_grade_flag           varchar2(1)
	,position_extra_info_id         per_position_extra_info.position_extra_info_id%type
	,object_version_number          per_position_extra_info.object_version_number%type
	,valid_grade                    per_position_extra_info.poei_information3%type
	,target_grade                   per_position_extra_info.poei_information4%type
	,pay_table_id                   per_position_extra_info.poei_information5%type
	,pay_basis                      per_position_extra_info.poei_information6%type
	,employment_category_group      per_position_extra_info.poei_information7%type);
--
type pos_grp1_type is record
	(pos_grp1_flag                  varchar2(1)
	,position_extra_info_id         per_position_extra_info.position_extra_info_id%type
	,object_version_number          per_position_extra_info.object_version_number%type
	,personnel_office_id            per_position_extra_info.poei_information3%type
	,office_symbol                  per_position_extra_info.poei_information4%type
	,organization_structure_id      per_position_extra_info.poei_information5%type
	,occupation_category_code       per_position_extra_info.poei_information6%type
	,flsa_category                  per_position_extra_info.poei_information7%type
	,bargaining_unit_status         per_position_extra_info.poei_information8%type
	,competitive_level              per_position_extra_info.poei_information9%type
	,work_schedule                  per_position_extra_info.poei_information10%type
	,functional_class               per_position_extra_info.poei_information11%type
	,position_working_title         per_position_extra_info.poei_information12%type
	,position_sensitivity           per_position_extra_info.poei_information13%type
	,security_access                per_position_extra_info.poei_information14%type
	,prp_sci                        per_position_extra_info.poei_information15%type
	,supervisory_status             per_position_extra_info.poei_information16%type
	,type_employee_supervised       per_position_extra_info.poei_information17%type
	,payroll_office_id              per_position_extra_info.poei_information18%type
	,timekeeper                     per_position_extra_info.poei_information19%type
	,competitive_area               per_position_extra_info.poei_information20%type
      ,positions_organization         per_position_extra_info.poei_information21%type
      ,oct_report_flag                per_position_extra_info.poei_information22%type
      ,part_time_hours                per_position_extra_info.poei_information23%type);
--
type pos_grp2_type is record
	(pos_grp2_flag                  varchar2(1)
	,position_extra_info_id         per_position_extra_info.position_extra_info_id%type
	,object_version_number          per_position_extra_info.object_version_number%type
	,position_occupied              per_position_extra_info.poei_information3%type
	,organization_function_code     per_position_extra_info.poei_information4%type
	,date_position_classified       per_position_extra_info.poei_information5%type
	,date_last_position_audit       per_position_extra_info.poei_information6%type
	,classification_official        per_position_extra_info.poei_information7%type
	,language_required              per_position_extra_info.poei_information8%type
	,drug_test                      per_position_extra_info.poei_information9%type
	,financial_statement            per_position_extra_info.poei_information10%type
	,training_program_id            per_position_extra_info.poei_information11%type
	,key_emergency_essential        per_position_extra_info.poei_information12%type
	,appropriation_code1            per_position_extra_info.poei_information13%type
	,appropriation_code2            per_position_extra_info.poei_information14%type
	,intelligence_position_ind      per_position_extra_info.poei_information15%type
	,leo_position_indicator         per_position_extra_info.poei_information16%type);
--
-- type pos_of8_type is record
--         (pos_of8_flag                   varchar2(1)
--         ,position_extra_info_id         per_position_extra_info.position_extra_info_id%type
--         ,object_version_number          per_position_extra_info.object_version_number%type
--         ,reason_for_submission          per_position_extra_info.poei_information3%type
--         ,service_location               per_position_extra_info.poei_information4%type
--         ,cs_certification_number        per_position_extra_info.poei_information5%type
--         ,classified_grade_by            per_position_extra_info.poei_information6%type
--         ,classification_standard_used   per_position_extra_info.poei_information7%type
--         ,classification_standard_date   per_position_extra_info.poei_information8%type
--         ,subject_to_ia_action           per_position_extra_info.poei_information9%type);
--
type pos_oblig_type is record
	(pos_oblig_flag                 varchar2(1)
	,position_extra_info_id         per_position_extra_info.position_extra_info_id%type
	,object_version_number          per_position_extra_info.object_version_number%type
	,expiration_date                per_position_extra_info.poei_information3%type
	,obligation_type                per_position_extra_info.poei_information4%type
	,employee_ssn                   per_position_extra_info.poei_information5%type);
--
type pos_car_prog_type is record
	(pos_car_prog_flag              varchar2(1)
	,position_extra_info_id         per_position_extra_info.position_extra_info_id%type
	,object_version_number          per_position_extra_info.object_version_number%type
	,career_program_id              per_position_extra_info.poei_information3%type
	,career_program_type            per_position_extra_info.poei_information4%type
	,change_reasons                 per_position_extra_info.poei_information5%type
	,career_field_id                per_position_extra_info.poei_information6%type
	,career_program_code            per_position_extra_info.poei_information7%type
	,acteds_key_position            per_position_extra_info.poei_information8%type);
--
type personal_info_type is record
	(p_national_identifier          per_people_f.national_identifier%type
	,p_date_of_birth                per_people_f.date_of_birth%type
	,p_sex                          per_people_f.sex%type);
--
type prior_sf52_data_type is record
	(position_title               per_position_definitions.segment1%type
	,position_number              per_position_definitions.segment2%type
      ,position_seq_no              per_position_definitions.segment3%type
	,pay_plan                     per_grade_definitions.segment1%type
	,occ_code                     per_job_definitions.segment1%type
	,grade_or_level               per_grade_definitions.segment2%type
	,step_or_rate                 per_assignment_extra_info.aei_information3%type
	,total_salary                 number
	,pay_basis                    per_position_extra_info.poei_information6%type
	,basic_pay                    number
	,locality_adj                 number
	,adj_basic_pay                number
	,other_pay                    number
	,position_org_line1           ghr_pa_requests.from_position_org_line1%type
	,position_org_line2           ghr_pa_requests.from_position_org_line2%type
	,position_org_line3           ghr_pa_requests.from_position_org_line3%type
	,position_org_line4           ghr_pa_requests.from_position_org_line4%type
	,position_org_line5           ghr_pa_requests.from_position_org_line5%type
	,position_org_line6           ghr_pa_requests.from_position_org_line6%type
	,position_id                  per_all_positions.position_id%type
	,duty_station_location_id     hr_locations.location_id%type
       , work_schedule                ghr_pa_requests.work_schedule%type
	,pay_rate_determinant         per_assignment_extra_info.aei_information6%type);
--
type recruitment_bonus_type is record
	(p_recruitment_bonus_flag       varchar2(1)
	,p_recruitment_bonus            ghr_pa_request_extra_info.rei_information1%type
	,p_date_recruit_exp             ghr_pa_request_extra_info.rei_information2%type
	,p_percentage                     ghr_pa_request_extra_info.rei_information3%type);
--
type relocation_bonus_type is record
	(p_relocation_bonus_flag        varchar2(1)
	,p_relocation_bonus             ghr_pa_request_extra_info.rei_information1%type
	,p_date_reloc_exp               ghr_pa_request_extra_info.rei_information2%type
	,p_percentage                     ghr_pa_request_extra_info.rei_information3%type);
--
type agency_sf52_type is record
(agency_flag		 VARCHAR2(1)
,agency_extra_info_id  	 ghr_pa_request_extra_info.pa_request_extra_info_id%type
,object_version_number 	 ghr_pa_request_extra_info.object_version_number%type
,agency_use_block_25     ghr_pa_request_extra_info.rei_information3%type
,agency_data_block_40    ghr_pa_request_extra_info.rei_information4%type
,agency_data_block_41    ghr_pa_request_extra_info.rei_information5%type
,agency_data_block_42    ghr_pa_request_extra_info.rei_information6%type
,agency_data_block_43    ghr_pa_request_extra_info.rei_information7%type
,agency_data_block_44    ghr_pa_request_extra_info.rei_information8%type);
----

type within_grade_increase_type is record
	(p_wgi_flag                     varchar2(1)
	,p_wgi_status                   ghr_pa_request_extra_info.rei_information1%type
	,p_date_wgi_due                 ghr_pa_request_extra_info.rei_information2%type
      ,p_wgi_pay_date                 ghr_pa_request_extra_info.rei_information3%type
      ,p_date_wgi_postpone_effective  ghr_pa_request_extra_info.rei_information3%type
	,p_date_wgi_postpone_detail_due ghr_pa_request_extra_info.rei_information4%type
	,p_date_wgi_due_temp_prom       ghr_pa_request_extra_info.rei_information5%type
        ,p_last_equi_incr    ghr_pa_request_extra_info.rei_information5%type);

--   Added 14-AUG-97
type government_awards_type is record
     (award_flag                     varchar2(1)
     ,award_agency                   ghr_pa_request_extra_info.rei_information3%type
     ,award_type                     ghr_pa_request_extra_info.rei_information4%type
     ,percentage                     ghr_pa_request_extra_info.rei_information5%type
     ,group_award                    ghr_pa_request_extra_info.rei_information6%type
     ,tangible_benefit_dollars       ghr_pa_request_extra_info.rei_information7%type
     ,award_payment                  ghr_pa_request_extra_info.rei_information8%type
     ,date_award_earned              ghr_pa_request_extra_info.rei_information9%type
     ,award_appropriation_code       ghr_pa_request_extra_info.rei_information10%type
     ,date_exemp_award               ghr_pa_request_extra_info.rei_information11%type );
-- award_payment - 10/24/97
-- date_award_earned - 02/16/98
-- award_appropriation_code - 02/29/00
type government_payroll_type is record
     (payroll_type                   ghr_pa_request_extra_info.rei_information3%type);

type retention_allow_review_type is record
     ( retention_allow_review_flag   varchar2(1)
      ,review_date                   ghr_pa_request_extra_info.rei_information3%type);
-- added date_init_appr_due on 5-oct-98 by skutteti
type performance_appraisal_type is record
     (perf_appr_flag                 varchar2(1)
     ,rating_rec                     ghr_pa_request_extra_info.rei_information3%type
     ,rating_rec_pattern             ghr_pa_request_extra_info.rei_information4%type
     ,rating_rec_level               ghr_pa_request_extra_info.rei_information5%type
     ,date_appr_starts               ghr_pa_request_extra_info.rei_information19%type --Bug#4753117
     ,date_appr_ends                 ghr_pa_request_extra_info.rei_information6%type
     ,unit                           ghr_pa_request_extra_info.rei_information7%type
     ,org_structure_id               ghr_pa_request_extra_info.rei_information8%type
     ,office_symbol                  ghr_pa_request_extra_info.rei_information9%type
     ,pay_plan                       ghr_pa_request_extra_info.rei_information10%type
     ,grade                          ghr_pa_request_extra_info.rei_information11%type
     ,date_due                       ghr_pa_request_extra_info.rei_information12%type
     ,appraisal_system_identifier    ghr_pa_request_extra_info.rei_information13%type
     ,appraisal_type                 ghr_pa_request_extra_info.rei_information14%type
     ,date_effective                 ghr_pa_request_extra_info.rei_information15%type
     ,date_init_appr_due             ghr_pa_request_extra_info.rei_information16%type
     ,optional_information           ghr_pa_request_extra_info.rei_information17%type
     ,person_analysis_id             per_person_analyses.person_analysis_id%type
     ,object_version_number          per_person_analyses.object_version_number%type
--Added for Bug 3636398
     ,performance_rating_points      ghr_pa_request_extra_info.rei_information18%type);

-- Added 10/24/97
type conduct_performance_type  is record
     ( cond_perf_flag            varchar2(1)
      ,type_of_employment        ghr_pa_request_extra_info.rei_information3%type
      ,adverse_action_noac       ghr_pa_request_extra_info.rei_information4%type
      ,cause_of_disc_action      ghr_pa_request_extra_info.rei_information5%type
      ,date_of_adverse_action    ghr_pa_request_extra_info.rei_information6%type
      ,days_suspended            ghr_pa_request_extra_info.rei_information7%type
      ,date_suspension_over_30   ghr_pa_request_extra_info.rei_information8%type
      ,date_suspension_under_30  ghr_pa_request_extra_info.rei_information9%type
      ,pip_action_taken          ghr_pa_request_extra_info.rei_information10%type
      ,pip_begin_date            ghr_pa_request_extra_info.rei_information11%type
      ,pip_end_date              ghr_pa_request_extra_info.rei_information12%type
      ,pip_extensions            ghr_pa_request_extra_info.rei_information13%type
      ,pip_length                ghr_pa_request_extra_info.rei_information14%type
      ,date_reprimand_expires    ghr_pa_request_extra_info.rei_information15%type
      ,person_analysis_id        per_person_analyses.person_analysis_id%type
      ,object_version_number     per_person_analyses.object_version_number%type);


-- Rohini 07-AUG-1972

type special_information_type is record
     (segment1                per_analysis_criteria.segment1%type
     ,segment2                per_analysis_criteria.segment2%type
     ,segment3                per_analysis_criteria.segment3%type
     ,segment4                per_analysis_criteria.segment4%type
     ,segment5                per_analysis_criteria.segment5%type
     ,segment6                per_analysis_criteria.segment6%type
     ,segment7                per_analysis_criteria.segment7%type
     ,segment8                per_analysis_criteria.segment8%type
     ,segment9                per_analysis_criteria.segment9%type
     ,segment10               per_analysis_criteria.segment10%type
     ,segment11               per_analysis_criteria.segment11%type
     ,segment12               per_analysis_criteria.segment12%type
     ,segment13               per_analysis_criteria.segment13%type
     ,segment14               per_analysis_criteria.segment14%type
     ,segment15               per_analysis_criteria.segment15%type
     ,segment16               per_analysis_criteria.segment16%type
     ,segment17               per_analysis_criteria.segment17%type
     ,segment18               per_analysis_criteria.segment18%type
     ,segment19               per_analysis_criteria.segment19%type
     ,segment20               per_analysis_criteria.segment20%type
     ,segment21               per_analysis_criteria.segment21%type
     ,segment22               per_analysis_criteria.segment22%type
     ,segment23               per_analysis_criteria.segment23%type
     ,segment24               per_analysis_criteria.segment24%type
     ,segment25               per_analysis_criteria.segment25%type
     ,segment26               per_analysis_criteria.segment26%type
     ,segment27               per_analysis_criteria.segment27%type
     ,segment28               per_analysis_criteria.segment28%type
     ,segment29               per_analysis_criteria.segment29%type
     ,segment30               per_analysis_criteria.segment30%type
     ,person_analysis_id      per_person_analyses.person_analysis_id%type
     ,object_version_number   per_person_analyses.object_version_number%type );


type civ_position_acquisition is record
( career_category       	per_position_extra_info.poei_information8%type
 ,critical_position    	per_position_extra_info.poei_information5%type
 ,civ_func_acct_shred 	per_position_extra_info.poei_information7%type
 ,psn_status_ind      	per_position_extra_info.poei_information4%type
);

type civ_position_army_appr_ln is record
(
  amscd                 per_position_extra_info.poei_information11%type
 ,ar_tda_line_num       per_position_extra_info.poei_information3%type
 ,competitive_area      per_position_extra_info.poei_information4%type
 ,duty_stn_st           per_position_extra_info.poei_information16%type
 ,func_desc             per_position_extra_info.poei_information2%type
 ,tda_para_num          per_position_extra_info.poei_information5%type
 );

type civ_position_naf is record
(
 med_ind                per_position_extra_info.poei_information12%type
 ,nafi_psn_num           per_position_extra_info.poei_information10%type
 ,svc_offc_symbol        per_position_extra_info.poei_information4%type
 );

-- added by skutteti on 3-mar-98
type par_term_retained_grade_type is record
	(par_term_retained_grade_flag   varchar2(1)
	,person_extra_info_id           per_people_extra_info.person_extra_info_id%type
	,object_version_number          per_people_extra_info.object_version_number%type
      );
--
type entitlement_type is record
     (entitlement_flag               varchar2(1)
     ,entitlement_code               ghr_pa_request_extra_info.rei_information3%type
     ,entitlement_amt_percent        ghr_pa_request_extra_info.rei_information4%type
     );
-- Bug#2759379 Created FEGLI Record type
type fegli_type is record
     (fegli_flag                     varchar2(1)
     ,eligibility_expiration         ghr_pa_request_extra_info.rei_information1%type
     );
--
type foreign_lang_prof_pay_type is record
     (for_lang_flag                  varchar2(1)
     ,certification_date             ghr_pa_request_extra_info.rei_information3%type
     ,pay_level_or_rate              ghr_pa_request_extra_info.rei_information4%type
     );
--
-- Bug#3385386 Added record type FTA
type fta_type is record
     (fta_flag                   varchar2(1)
     ,last_action_code           ghr_pa_request_extra_info.rei_information3%type
     ,Number_family_members      ghr_pa_request_extra_info.rei_information4%type
     ,Miscellaneous_Expense      ghr_pa_request_extra_info.rei_information5%type
     ,Wardrobe_Expense           ghr_pa_request_extra_info.rei_information6%type
     ,Pre_Departure_Subs_Expense ghr_pa_request_extra_info.rei_information7%type
     ,Lease_Penalty_Expense      ghr_pa_request_extra_info.rei_information8%type
     ,Amount                     ghr_pa_request_extra_info.rei_information9%type
     );
--
type edp_pay_type is record
     (edp_flag                       varchar2(1)
     ,premium_pay_indicator          ghr_pa_request_extra_info.rei_information3%type
     ,edp_type                       ghr_pa_request_extra_info.rei_information4%type
     );
--
type hazard_pay_type is record
     (hazard_flag                    varchar2(1)
     ,premium_pay_indicator          ghr_pa_request_extra_info.rei_information3%type
     ,hazard_type                    ghr_pa_request_extra_info.rei_information4%type
     );
--
type health_benefits_type is record
     (health_benefits_flag           varchar2(1)
     ,enrollment                     ghr_pa_request_extra_info.rei_information3%type
     ,health_plan                    ghr_pa_request_extra_info.rei_information4%type
     ,temps_total_cost               ghr_pa_request_extra_info.rei_information5%type
     ,pre_tax_waiver                 ghr_pa_request_extra_info.rei_information6%type
     );
--
--
type health_ben_pre_tax_type is record
     (health_ben_pre_tax_flag           varchar2(1)
     ,enrollment                     ghr_pa_request_extra_info.rei_information3%type
     ,health_plan                    ghr_pa_request_extra_info.rei_information4%type
     ,temps_total_cost               ghr_pa_request_extra_info.rei_information5%type
     );
--
type danger_pay_type is record
     (danger_flag                    varchar2(1)
     ,last_action_code               ghr_pa_request_extra_info.rei_information3%type
     ,location                       ghr_pa_request_extra_info.rei_information4%type
     );
--
type imminent_danger_pay_type is record
     (imminent_danger_flag           varchar2(1)
     ,amount                         ghr_pa_request_extra_info.rei_information3%type
     ,location                       ghr_pa_request_extra_info.rei_information4%type
     ,last_action_code               ghr_pa_request_extra_info.rei_information5%type
     );
--
type living_quarters_allow_type is record
     (living_quarters_allow_flag     varchar2(1)
     ,purchase_amount                ghr_pa_request_extra_info.rei_information3%type
     ,purchase_date                  ghr_pa_request_extra_info.rei_information4%type
     ,rent_amount                    ghr_pa_request_extra_info.rei_information5%type
     ,utility_amount                 ghr_pa_request_extra_info.rei_information6%type
     ,last_action_code               ghr_pa_request_extra_info.rei_information7%type
     ,location                       ghr_pa_request_extra_info.rei_information8%type
     ,quarters_type                  ghr_pa_request_extra_info.rei_information9%type
     ,shared_percent                 ghr_pa_request_extra_info.rei_information10%type
     ,no_of_family_members           ghr_pa_request_extra_info.rei_information11%type
     ,summer_record_ind              ghr_pa_request_extra_info.rei_information12%type
     ,quarters_group                 ghr_pa_request_extra_info.rei_information13%type
     ,currency                       ghr_pa_request_extra_info.rei_information14%type
     );
--
type post_diff_amt_type is record
     (post_diff_amt_flag             varchar2(1)
     ,amount                         ghr_pa_request_extra_info.rei_information3%type
     ,last_action_code               ghr_pa_request_extra_info.rei_information4%type
     ,location                       ghr_pa_request_extra_info.rei_information5%type
     ,no_of_family_members           ghr_pa_request_extra_info.rei_information6%type
     );
--
type post_diff_percent_type is record
     (post_diff_percent_flag         varchar2(1)
     ,percent                        ghr_pa_request_extra_info.rei_information3%type
     ,last_action_code               ghr_pa_request_extra_info.rei_information4%type
     ,location                       ghr_pa_request_extra_info.rei_information5%type
     );
--
type sep_maintenance_allow_type is record
     (sep_maint_allow_flag           varchar2(1)
     ,amount                         ghr_pa_request_extra_info.rei_information3%type
     ,last_action_code               ghr_pa_request_extra_info.rei_information4%type
     ,category                       ghr_pa_request_extra_info.rei_information5%type
     );
--
type supplemental_post_allow_type is record
     (sup_post_allow_flag            varchar2(1)
     ,amount                         ghr_pa_request_extra_info.rei_information3%type
     );
--
type temp_lodge_allow_type is record
     (temp_lodge_allow_flag          varchar2(1)
     ,allowance_type                 ghr_pa_request_extra_info.rei_information3%type
     ,daily_rate                     ghr_pa_request_extra_info.rei_information4%type
     );
--
type premium_pay_type is record
     (premium_pay_flag               varchar2(1)
     ,premium_pay_ind                ghr_pa_request_extra_info.rei_information3%type
     ,amount                         ghr_pa_request_extra_info.rei_information4%type
     );
--
type retirement_annuity_type is record
     (retirement_annuity_flag        varchar2(1)
     ,annuity_sum                    ghr_pa_request_extra_info.rei_information3%type
     ,eligibility_expires           ghr_pa_request_extra_info.rei_information4%type
     );
--
type severance_pay_type is record
     (severance_pay_flag             varchar2(1)
     ,amount                         ghr_pa_request_extra_info.rei_information3%type
     ,total_entitlement_weeks        ghr_pa_request_extra_info.rei_information4%type
     ,number_weeks_paid              ghr_pa_request_extra_info.rei_information5%type
     ,weekly_amount                  ghr_pa_request_extra_info.rei_information6%type
     );
--
type thrift_saving_plan is record
     (tsp_flag                       varchar2(1)
     ,amount                         ghr_pa_request_extra_info.rei_information3%type
     ,rate                           ghr_pa_request_extra_info.rei_information4%type
     ,g_fund                         ghr_pa_request_extra_info.rei_information5%type
     ,f_fund                         ghr_pa_request_extra_info.rei_information6%type
     ,c_fund                         ghr_pa_request_extra_info.rei_information7%type
     ,status                         ghr_pa_request_extra_info.rei_information8%type
     ,status_date                    ghr_pa_request_extra_info.rei_information9%type
     ,agncy_contrib_elig_date        ghr_pa_request_extra_info.rei_information10%type
     ,emp_contrib_elig_date          ghr_pa_request_extra_info.rei_information11%type
     );
--
--Pradeep.
  type mddds_special_pay_type is record
      (	 mddds_special_pay_flag			varchar2(1)
 	,Full_Time_Status 			ghr_pa_request_extra_info.rei_information9%type
 	,Length_of_Service 			ghr_pa_request_extra_info.rei_information10%type
 	,Scarce_Specialty 			ghr_pa_request_extra_info.rei_information3%type
 	,Specialty_or_Board_Cert 	        ghr_pa_request_extra_info.rei_information4%type
 	,Geographic_Location 			ghr_pa_request_extra_info.rei_information5%type
 	,Exceptional_Qualifications 		ghr_pa_request_extra_info.rei_information6%type
 	,Executive_Position 			ghr_pa_request_extra_info.rei_information7%type
 	,Dentist_Post_Graduate_Training		ghr_pa_request_extra_info.rei_information8%type
 	,Amount					ghr_pa_request_extra_info.rei_information11%type
 	,mddds_special_pay_date			ghr_pa_request_extra_info.rei_information12%type
	,premium_pay_ind                        ghr_pa_request_extra_info.rei_information13%type
      );
--
--Bug#3585473
  type premium_pay_ind_type is record
      (
        premium_pay_ind_flag                   varchar2(1)
        ,premium_pay_ind                        ghr_pa_request_extra_info.rei_information3%type
      );

-- Student Loan Repayment changes bug 3494728
type student_loan_repay_type is record
	(p_student_loan_flag        varchar2(1)
	,p_repay_schedule           varchar2(2)
	,p_amount                   ghr_pa_request_extra_info.rei_information1%type
	,p_review_date              ghr_pa_request_extra_info.rei_information2%type);

-- Student Loan Repayment changes

-- Bug 4724337 Race or National Origin changes
type per_race_ethnic_type is record
(	p_race_ethnic_info_flag varchar2(1),
	person_extra_info_id           per_people_extra_info.person_extra_info_id%type,
	object_version_number          per_people_extra_info.object_version_number%type,
	p_hispanic	varchar2(1),
	p_american_indian varchar2(1),
	p_asian varchar2(1),
	p_black_afr_american varchar2(1),
	p_hawaiian_pacific varchar2(1),
	p_white varchar2(1)
);
-- End Race or National Origin changes

-- 6312144 IPA Benefits Continuation EIT changes
type per_ipa_ben_cont_info_type is record
	( per_ben_cont_info_flag    varchar2(1)
	 ,person_extra_info_id           per_people_extra_info.person_extra_info_id%type
	 ,object_version_number          per_people_extra_info.object_version_number%type
	 ,FEGLI_Indicator                per_people_extra_info.pei_information1%type
	 ,FEGLI_Election_Date            per_people_extra_info.pei_information2%type
	 ,FEGLI_Elec_Not_Date            per_people_extra_info.pei_information3%type
	 ,FEHB_Indicator                 per_people_extra_info.pei_information4%type
	 ,FEHB_Election_Date             per_people_extra_info.pei_information5%type
	 ,FEHB_Elec_Notf_Date            per_people_extra_info.pei_information6%type
	 ,Retirement_Indicator           per_people_extra_info.pei_information7%type
	 ,Retirement_Elec_Date           per_people_extra_info.pei_information12%type
	 ,Retirement_Elec_Notf_Date      per_people_extra_info.pei_information8%type
	 ,Cont_Term_Insuff_Pay_Elec_Date per_people_extra_info.pei_information9%type
	 ,Cont_Term_Insuff_Pay_Notf_Date per_people_extra_info.pei_information10%type
	 ,Cont_Term_Insuff_Pmt_Type_Code per_people_extra_info.pei_information11%type);

-- 6312144 Retirement System information
type per_retirement_info_type is record
	(per_retirement_info_flag       varchar2(1)
	,person_extra_info_id           per_people_extra_info.person_extra_info_id%type
	,object_version_number          per_people_extra_info.object_version_number%type
        ,special_population_code        per_people_extra_info.pei_information1%type
	,App_Exc_CSRS_Ind               per_people_extra_info.pei_information2%type
	,App_Exc_FERS_Ind               per_people_extra_info.pei_information3%type
	,FICA_Coverage_Ind1             per_people_extra_info.pei_information4%type
	,FICA_Coverage_Ind2             per_people_extra_info.pei_information5%type);





-- ---------------------------------------------------------------------------
-- |-------------------< retrieve_element_entry_value >----------------------|
-- ---------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   Retrieve element entry value
--
-- Prerequisites:
--
-- In Parameters:
--   p_element_name
--   p_input_value_name
--   p_assignment_id
--   p_effective_date
--
-- Out Parameters:
--   p_value
--   p_multiple_error_flag
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error will be raised and processing is terminated.
--   If an employee has more than one of the same element, this procedure
--     will set p_multiple_error flag to TRUE and return NULL to p_value.
--     Otherwise, p_multiple_error flag will be set to FALSE and return
--     the entry value.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Use Only.
--
-- {End of Comments}
-- ---------------------------------------------------------------------------
procedure retrieve_element_entry_value
	(p_element_name      in     pay_element_types_f.element_name%type
	,p_input_value_name  in     pay_input_values_f.name%type
	,p_assignment_id     in     pay_element_entries_f.assignment_id%type
	,p_effective_date    in     date
	,p_value                OUT NOCOPY varchar2
	,p_multiple_error_flag  OUT NOCOPY boolean);

--
-- ---------------------------------------------------------------------------
-- |--------------------------< get_position_title >--------------------------|
-- ---------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   Retrieve position title.
--
-- Prerequisites:
--   Either p_persion_id or p_assignment_id must be provided.
--
-- In Parameters:
--   p_person_id
--     The default is NULL.
--   p_assignment_id
--     The default is NULL.
--   p_effective_date
--     The default is sysdate.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error will be raised and processing is terminated.
--
-- Developer Implementation Notes:
--   Calling hr_utility procedures are commented out due to these procedures
--   update the database which violates the function requirement.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End of Comments}
-- ---------------------------------------------------------------------------
function get_position_title
	(p_person_id            in per_people_f.person_id%type          default NULL
	,p_assignment_id        in per_assignments_f.assignment_id%type default NULL
	,p_effective_date       in date                                 default sysdate                             ) return varchar2;
pragma restrict_references (get_position_title, WNDS, WNPS);
--
-- ---------------------------------------------------------------------------
-- |--------------------------< get_position_title_pos >----------------------|
-- ---------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   Retrieve position title. Very similar to get_position_title except it takes position_id and
--   its associated business group as in parameters
--
-- Prerequisites:
--   p_position_id and p_business_group_id must be provided.
--
-- In Parameters:
--   p_position_id
--   p_business_group_id
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error will be raised and processing is terminated.
--
-- Developer Implementation Notes:
--   Calling hr_utility procedures are commented out due to these procedures
--   update the database which violates the function requirement.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End of Comments}
-- ---------------------------------------------------------------------------
function get_position_title_pos
	(p_position_id            in per_all_positions.position_id%type
	,p_business_group_id      in per_all_positions.business_group_id%type
        ,p_effective_date         in date default sysdate
  ) return varchar2;
pragma restrict_references (get_position_title_pos, WNDS, WNPS);
--
-- ---------------------------------------------------------------------------
-- |---------------------< get_position_description_no >---------------------|
-- ---------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   Retrieve position description no (PD#).
--
-- Prerequisites:
--   Either p_persion_id or p_assignment_id must be provided.
--
-- In Parameters:
--   p_person_id
--     The default is NULL.
--   p_assignment_id
--     The default is NULL.
--   p_effective_date
--     The default is sysdate.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error will be raised and processing is terminated.
--
-- Developer Implementation Notes:
--   Calling hr_utility procedures are commented out due to these procedures
--   update the database which violates the function requirement.
--
-- Access Status:
--   All.
--
-- {End of Comments}
-- ---------------------------------------------------------------------------
function get_position_description_no
	(p_person_id            in per_people_f.person_id%type          default NULL
	,p_assignment_id        in per_assignments_f.assignment_id%type default NULL
	,p_effective_date       in date                                 default sysdate
	) return varchar2;
pragma restrict_references (get_position_description_no, WNDS, WNPS);
--
-- ---------------------------------------------------------------------------
-- |--------------------------< get_position_desc_no_pos >--------------------|
-- ---------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   Retrieve position description no (PD#). Very similar to get_position_description_no
-- except it takes position_id and its associated business group as in parameters
--
-- Prerequisites:
--   p_position_id and p_business_group_id must be provided.
--
-- In Parameters:
--   p_position_id
--   p_business_group_id
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error will be raised and processing is terminated.
--
-- Developer Implementation Notes:
--   Calling hr_utility procedures are commented out due to these procedures
--   update the database which violates the function requirement.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End of Comments}
-- ---------------------------------------------------------------------------
function get_position_desc_no_pos
	(p_position_id            in per_all_positions.position_id%type
	,p_business_group_id      in per_all_positions.business_group_id%type
        ,p_effective_date         in date default sysdate
  ) return varchar2;
pragma restrict_references (get_position_desc_no_pos, WNDS, WNPS);
--
-- ---------------------------------------------------------------------------
-- |----------------------< get_position_sequence_no >-----------------------|
-- ---------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   Retrieve position sequence no.
--
-- Prerequisites:
--   Either p_persion_id or p_assignment_id must be provided.
--
-- In Parameters:
--   p_person_id
--     The default is NULL.
--   p_assignment_id
--     The default is NULL.
--   p_effective_date
--     The default is sysdate.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error will be raised and processing is terminated.
--
-- Developer Implementation Notes:
--   Calling hr_utility procedures are commented out due to these procedures
--   update the database which violates the function requirement.
--
-- Access Status:
--   All.
--
-- {End of Comments}
-- ---------------------------------------------------------------------------
function get_position_sequence_no
	(p_person_id            in per_people_f.person_id%type          default NULL
	,p_assignment_id        in per_assignments_f.assignment_id%type default NULL
	,p_effective_date       in date                                 default sysdate
	) return varchar2;
pragma restrict_references (get_position_sequence_no, WNDS, WNPS);
--
-- ---------------------------------------------------------------------------
-- |--------------------------< get_position_sequence_no_pos >----------------|
-- ---------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   Retrieve position sequence no. Very similar to get_position_sequence_no
-- except it takes position_id and its associated business group as in parameters
--
-- Prerequisites:
--   p_position_id and p_business_group_id must be provided.
--
-- In Parameters:
--   p_position_id
--   p_business_group_id
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error will be raised and processing is terminated.
--
-- Developer Implementation Notes:
--   Calling hr_utility procedures are commented out due to these procedures
--   update the database which violates the function requirement.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End of Comments}
-- ---------------------------------------------------------------------------
function get_position_sequence_no_pos
	(p_position_id            in per_all_positions.position_id%type
	,p_business_group_id      in per_all_positions.business_group_id%type
       ,p_effective_date          in date default sysdate
  ) return varchar2;
pragma restrict_references (get_position_sequence_no_pos, WNDS, WNPS);
--

-- ---------------------------------------------------------------------------
-- |----------------------< get_position_agency_code>-------------------------|
-- ---------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   Retrieve position agency code. Similar to get_position_title,
--   get_position_description_no and get_position_sequence_no
--
-- Prerequisites:
--   Either p_persion_id or p_assignment_id must be provided.
--
-- In Parameters:
--   p_person_id
--     The default is NULL.
--   p_assignment_id
--     The default is NULL.
--   p_effective_date
--     The default is sysdate.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error will be raised and processing is terminated.
--
-- Developer Implementation Notes:
--   Calling hr_utility procedures are commented out due to these procedures
--   update the database which violates the function requirement.
--
-- Access Status:
--   All.
--
-- {End of Comments}
-- ---------------------------------------------------------------------------
function get_position_agency_code
	(p_person_id            in per_people_f.person_id%type          default NULL
	,p_assignment_id        in per_assignments_f.assignment_id%type default NULL
	,p_effective_date       in date                                 default sysdate
	) return varchar2;
pragma restrict_references (get_position_agency_code, WNDS, WNPS);
--
-- ---------------------------------------------------------------------------
-- |--------------------------< get_position_agency_code_pos >----------------|
-- ---------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   Retrieve position agency_ code. Very similar to get_position_agency_code
-- except it takes position_id and its associated business group as in parameters
--
-- Prerequisites:
--   p_position_id and p_business_group_id must be provided.
--
-- In Parameters:
--   p_position_id
--   p_business_group_id
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error will be raised and processing is terminated.
--
-- Developer Implementation Notes:
--   Calling hr_utility procedures are commented out due to these procedures
--   update the database which violates the function requirement.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End of Comments}
-- ---------------------------------------------------------------------------
function get_position_agency_code_pos
	(p_position_id            in per_all_positions.position_id%type
	,p_business_group_id      in per_all_positions.business_group_id%type
	,p_effective_date         in date   default sysdate
  ) return varchar2;
pragma restrict_references (get_position_agency_code_pos, WNDS, WNPS);
--
-- ---------------------------------------------------------------------------
-- |--------------------< get_job_occupational_series >----------------------|
-- ---------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   Retrieve job occupational series.
--
-- Prerequisites:
--   Either p_persion_id or p_assignment_id must be provided.
--
-- In Parameters:
--   p_person_id
--     The default is NULL.
--   p_assignment_id
--     The default is NULL.
--   p_effective_date
--     The default is sysdate.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error will be raised and processing is terminated.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   All.
--
-- {End of Comments}
-- ---------------------------------------------------------------------------
--
function get_job_occupational_series
	(p_person_id            in per_people_f.person_id%type          default NULL
	,p_assignment_id        in per_assignments_f.assignment_id%type default NULL
	,p_effective_date       in date                                 default sysdate
	) return varchar2;
pragma restrict_references (get_job_occupational_series, WNDS, WNPS);
--
-- ---------------------------------------------------------------------------
-- |--------------------< get_job_occ_series_job >----------------------------|
-- ---------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   Retrieve job occupational series. Very similar to get_job_occupational_series
-- except it takes job_id and its associated business group as in parameters
--
-- Prerequisites:
--   p_job_id and p_business_group_id must be provided.
--
-- In Parameters:
--   p_job_id
--   p_business_group_id
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error will be raised and processing is terminated.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   All.
--
-- {End of Comments}
-- ---------------------------------------------------------------------------
--
function get_job_occ_series_job
	(p_job_id              in per_jobs.job_id%type
	,p_business_group_id   in per_all_positions.business_group_id%type
  ) return varchar2;
pragma restrict_references (get_job_occ_series_job, WNDS, WNPS);
--
-- ---------------------------------------------------------------------------
-- |----------------------< sf52_from_by_assignment >------------------------|
-- ---------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   SF52 From (from block 7 throught 14) by assignment ID.
--
-- Prerequisites:
--
-- In Parameters:
--   p_assignment_id
--   p_effective_date
--     The default is sysdate.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error will be raised and processing is terminated.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   All.
--
-- {End of Comments}
-- ---------------------------------------------------------------------------
--
procedure sf52_from_data_elements
      (p_person_id                 in     per_people_f.person_id%type      default NULL
	,p_assignment_id             IN OUT NOCOPY per_assignments_f.assignment_id%type
      ,p_effective_date            in     date                             default sysdate
      ,p_altered_pa_request_id     in     number
      ,p_noa_id_corrected          in     number
	,p_pa_history_id             in  number
      ,p_position_title            OUT NOCOPY varchar2
      ,p_position_number           OUT NOCOPY varchar2
      ,p_position_seq_no           OUT NOCOPY number
      ,p_pay_plan                  OUT NOCOPY varchar2
      ,p_job_id                    OUT NOCOPY number
      ,p_occ_code                  OUT NOCOPY varchar2
      ,p_grade_id                  OUT NOCOPY number
      ,p_grade_or_level            OUT NOCOPY varchar2
      ,p_step_or_rate              OUT NOCOPY varchar2
      ,p_total_salary              OUT NOCOPY number
      ,p_pay_basis                 OUT NOCOPY varchar2
       -- FWFA Changes Bug#4444609
      ,p_pay_table_identifier      OUT NOCOPY number
      -- FWFA Changes
      ,p_basic_pay                 OUT NOCOPY number
      ,p_locality_adj              OUT NOCOPY number
      ,p_adj_basic_pay             OUT NOCOPY number
      ,p_other_pay                 OUT NOCOPY number
      ,p_au_overtime               OUT NOCOPY NUMBER
      ,p_auo_premium_pay_indicator OUT NOCOPY VARCHAR2
      ,p_availability_pay          OUT NOCOPY NUMBER
      ,p_ap_premium_pay_indicator  OUT NOCOPY VARCHAR2
      ,p_retention_allowance       OUT NOCOPY NUMBER
      ,p_retention_allow_percentage OUT NOCOPY NUMBER
      ,p_supervisory_differential  OUT NOCOPY NUMBER
      ,p_supervisory_diff_percentage OUT NOCOPY NUMBER
      ,p_staffing_differential     OUT NOCOPY NUMBER
      ,p_staffing_diff_percentage  OUT NOCOPY NUMBER
      ,p_organization_id           OUT NOCOPY number
      ,p_position_org_line1        OUT NOCOPY varchar2   -- Position_org_line1 .. 6
      ,p_position_org_line2        OUT NOCOPY varchar2
      ,p_position_org_line3        OUT NOCOPY varchar2
      ,p_position_org_line4        OUT NOCOPY varchar2
      ,p_position_org_line5        OUT NOCOPY varchar2
      ,p_position_org_line6        OUT NOCOPY varchar2
      ,p_position_id               OUT NOCOPY per_all_positions.position_id%type
      ,p_duty_station_location_id  OUT NOCOPY hr_locations.location_id%type  -- duty_station_location_id
      ,p_pay_rate_determinant      OUT NOCOPY varchar2
     ,p_work_schedule              OUT NOCOPY varchar2
      );
--
--
-- ---------------------------------------------------------------------------
-- |--------------------------< return_upd_hr_dml_status >----------------|
-- ---------------------------------------------------------------------------
-- Description:
--   This function will return the current g_api_dml private global
--   boolean status.
--   The g_api_dml status determines if at the time of the function
--   being executed if a dml statement (i.e. INSERT, UPDATE or DELETE)
--   is being issued from within an api.
--   If the status is TRUE then a dml statement is being issued from
--   within this entity api.
--   This function is primarily to support database triggers which
--   need to maintain the object_version_number for non-supported
--   dml statements (i.e. dml statement issued outside of the api layer).
--
-- Pre Conditions:

--   None.
--
-- In Arguments:
--   None.
--
-- Post Success:
--   Processing continues.
--   If the function returns a TRUE value then, dml is being executed from
--   within this api.
--
-- Post Failure:
--   None.
--
-- Access Status:
--   Internal Table Handler Use Only.
--
-- {End Of Comments}

function return_upd_hr_dml_status return boolean;

-- pragma restrict_references (return_upd_hr_dml_status, WNDS, WNPS);


-- ---------------------------------------------------------------------------
-- |----------------------< return_special_information >------------------------|
-- ---------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   Special Information for the Person

-- Prerequisites:
--
-- In Parameters:
--
--   p_structure_name
--   p_person_id
--   p_effective_date
--     The default is sysdate.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error will be raised and processing is terminated.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   All.
--
-- {End of Comments}

Procedure return_special_information
(p_person_id       in  number
,p_structure_name  in  varchar2
,p_effective_date  in  date
,p_special_info    OUT NOCOPY ghr_api.special_information_type
);

-- ---------------------------------------------------------------------------
-- |--------------------------< return_education_Details >----------------|
-- --------------------------------------------------------------------------

  Procedure return_education_Details
  (p_person_id                  in  per_people_f.person_id%type,
   p_effective_date             in  date,
   p_education_level            OUT NOCOPY per_analysis_criteria.segment1%type,
   p_academic_discipline        OUT NOCOPY per_analysis_criteria.segment2%type,
   p_year_degree_attained       OUT NOCOPY per_analysis_criteria.segment3%type
  );

------------------------------------------------------------------------------

Procedure call_workflow
(p_pa_request_id        in    ghr_pa_requests.pa_request_id%type,
 p_action_taken         in    ghr_pa_routing_history.action_taken%type,
 p_old_action_taken     in    ghr_pa_routing_history.action_taken%type default null,
 p_error                in    varchar2   default null
 );

  FUNCTION restricted_attribute (
      p_user_name       in VARCHAR2
    , p_attribute       in VARCHAR2
  )
  RETURN BOOLEAN;

end ghr_api;

----------------------------------------------------------------------------


/
