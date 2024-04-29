--------------------------------------------------------
--  DDL for Package BEN_EXT_PERSON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_PERSON" AUTHID CURRENT_USER as
/* $Header: benxpers.pkh 120.17.12010000.2 2008/08/05 14:58:54 ubhat ship $ */
--
g_effective_date                date;
g_person_ext_dt            	date;
g_benefits_ext_dt               date;
g_business_group_id       	number(15);
g_per_num                 	number(9);
g_trans_num               	number(9);
g_rcd_seq                 	number(9);
detail_error              	exception;
detail_restart_error           	exception;
required_error                  exception;
g_err_num                 	number(9);
g_err_name                	varchar2(30);
g_elmt_name                     ben_ext_data_elmt.name%type ;
g_pay_last_start_date           date ;
g_pay_last_end_date             date ;
g_ext_global_flag               varchar2(30);

hr_application_error            EXCEPTION;
PRAGMA EXCEPTION_INIT(hr_application_error, -20001);

--
-- detail - personal (25)
-- ======================
g_person_id                	per_all_people_f.person_id%TYPE;
--
g_chg_evt_cd               	varchar2(30);
g_chg_evt_source               	varchar2(30);
g_chg_eff_dt                    ben_ext_chg_evt_log.chg_eff_dt%TYPE;
g_chg_actl_dt                   ben_ext_chg_evt_log.chg_actl_dt%TYPE;
g_chg_last_update_login         ben_ext_chg_evt_log.last_update_login%TYPE;
g_chg_pl_id                     number(15);
g_chg_enrt_rslt_id         	number(15);
g_chg_input_value_id       	number(15);
g_ext_chg_evt_log_id       	number(15);
g_chg_prmtr_01                  ben_ext_chg_evt_log.prmtr_01%TYPE;
g_chg_prmtr_02                  ben_ext_chg_evt_log.prmtr_02%TYPE;
g_chg_prmtr_03                  ben_ext_chg_evt_log.prmtr_03%TYPE;
g_chg_prmtr_04                  ben_ext_chg_evt_log.prmtr_04%TYPE;
g_chg_prmtr_05                  ben_ext_chg_evt_log.prmtr_05%TYPE;
g_chg_prmtr_06                  ben_ext_chg_evt_log.prmtr_06%TYPE;
g_chg_old_val1       	        ben_ext_chg_evt_log.old_val1%TYPE;
g_chg_old_val2       	        ben_ext_chg_evt_log.old_val2%TYPE;
g_chg_old_val3       	        ben_ext_chg_evt_log.old_val3%TYPE;
g_chg_old_val4       	        ben_ext_chg_evt_log.old_val4%TYPE;
g_chg_old_val5       	        ben_ext_chg_evt_log.old_val5%TYPE;
g_chg_old_val6       	        ben_ext_chg_evt_log.old_val6%TYPE;
g_chg_new_val1       	        ben_ext_chg_evt_log.new_val1%TYPE;
g_chg_new_val2       	        ben_ext_chg_evt_log.new_val2%TYPE;
g_chg_new_val3       	        ben_ext_chg_evt_log.new_val3%TYPE;
g_chg_new_val4       	        ben_ext_chg_evt_log.new_val4%TYPE;
g_chg_new_val5       	        ben_ext_chg_evt_log.new_val5%TYPE;
g_chg_new_val6       	        ben_ext_chg_evt_log.new_val6%TYPE;
g_chg_pay_table                 varchar2(50);
g_chg_pay_column                varchar2(50);
g_chg_pay_mode                  varchar2(50);
g_chg_update_type               pay_datetracked_events.update_type%type ;
g_chg_surrogate_key             pay_process_events.SURROGATE_KEY%type ;
g_chg_next_event_date           date  ;
g_chg_pay_evt_index             number  ;
--
g_part_type                	varchar2(30);
g_per_rlshp_type           	varchar2(30);
g_part_ssn                 	per_all_people_f.national_identifier%TYPE;
g_part_first_name               per_all_people_f.first_name%TYPE;
g_part_last_name                per_all_people_f.last_name%TYPE;
--
g_national_identifier      	per_all_people_f.national_identifier%TYPE;
g_last_name                	per_all_people_f.last_name%TYPE;
g_first_name               	per_all_people_f.first_name%TYPE;
g_middle_names             	per_all_people_f.middle_names%TYPE;
g_full_name                	per_all_people_f.full_name%TYPE;
g_suffix                   	per_all_people_f.suffix%TYPE;
g_prefix                   	per_all_people_f.pre_name_adjunct%TYPE;
g_title                    	per_all_people_f.title%TYPE;
g_sup_full_name                 per_all_people_f.full_name%TYPE;
--
g_sex                      	per_all_people_f.sex%TYPE;
g_date_of_birth            	per_all_people_f.date_of_birth%TYPE;
g_marital_status           	per_all_people_f.marital_status%TYPE;
g_registered_disabled_flag 	per_all_people_f.registered_disabled_flag%TYPE;
g_student_status           	per_all_people_f.student_status%TYPE;
g_date_of_death            	per_all_people_f.date_of_death%TYPE;
g_employee_number          	per_all_people_f.employee_number%TYPE;
g_per_information1              per_all_people_f.per_information1%TYPE;
g_per_information2              per_all_people_f.per_information2%TYPE;
g_per_information3              per_all_people_f.per_information3%TYPE;
g_per_information4              per_all_people_f.per_information4%TYPE;
g_per_information5              per_all_people_f.per_information5%TYPE;
g_per_information6              per_all_people_f.per_information6%TYPE;
g_per_information7              per_all_people_f.per_information7%TYPE;
g_per_information8              per_all_people_f.per_information8%TYPE;
g_per_information9              per_all_people_f.per_information9%TYPE;
g_per_information10             per_all_people_f.per_information10%TYPE;
g_per_information11             per_all_people_f.per_information11%TYPE;
g_per_information12             per_all_people_f.per_information12%TYPE;
g_per_information13             per_all_people_f.per_information13%TYPE;
g_per_information14             per_all_people_f.per_information14%TYPE;
g_per_information15             per_all_people_f.per_information14%TYPE;
g_per_information16             per_all_people_f.per_information16%TYPE;
g_per_information17             per_all_people_f.per_information17%TYPE;
g_per_information18             per_all_people_f.per_information18%TYPE;
g_per_information19             per_all_people_f.per_information19%TYPE;
g_per_information20             per_all_people_f.per_information20%TYPE;
g_per_information21             per_all_people_f.per_information20%TYPE;
g_per_information22             per_all_people_f.per_information21%TYPE;
g_per_information23             per_all_people_f.per_information22%TYPE;
g_per_information24             per_all_people_f.per_information23%TYPE;
g_per_information25             per_all_people_f.per_information24%TYPE;
g_per_information26             per_all_people_f.per_information25%TYPE;
g_per_information27             per_all_people_f.per_information27%TYPE;
g_per_information28             per_all_people_f.per_information28%TYPE;
g_per_information29             per_all_people_f.per_information29%TYPE;
g_per_information30             per_all_people_f.per_information30%TYPE;
g_benefit_group_id         	ben_benfts_grp.benfts_grp_id%TYPE;
g_benefit_group            	ben_benfts_grp.name%TYPE;
g_benefit_bal_vacation     	ben_per_bnfts_bal_f.val%TYPE;
g_benefit_bal_sickleave    	ben_per_bnfts_bal_f.val%TYPE;
g_benefit_bal_pension      	ben_per_bnfts_bal_f.val%TYPE;
g_benefit_bal_dfncntrbn    	ben_per_bnfts_bal_f.val%TYPE;
g_benefit_bal_wellness     	ben_per_bnfts_bal_f.val%TYPE;
g_sup_employee_number           per_all_people_f.employee_number%TYPE;
--
g_applicant_number         	per_all_people_f.applicant_number%TYPE;
g_correspondence_language  	per_all_people_f.correspondence_language%TYPE;
g_email_address            	per_all_people_f.email_address%TYPE;
g_known_as                 	per_all_people_f.known_as%TYPE;
g_mailstop                 	per_all_people_f.mailstop%TYPE;
g_nationality              	per_all_people_f.nationality%TYPE;
g_pre_name_adjunct         	per_all_people_f.pre_name_adjunct%TYPE;
g_original_date_of_hire    	per_all_people_f.original_date_of_hire%TYPE;
g_uses_tobacco_flag        	per_all_people_f.uses_tobacco_flag%TYPE;
g_office_number            	per_all_people_f.office_number%TYPE;
--
g_previous_last_name       	per_all_people_f.last_name%TYPE;
g_previous_first_name      	per_all_people_f.first_name%TYPE;
g_previous_middle_name     	per_all_people_f.middle_names%TYPE;
g_previous_suffix          	per_all_people_f.suffix%TYPE;
g_previous_prefix          	per_all_people_f.pre_name_adjunct%TYPE;
g_previous_ssn             	per_all_people_f.national_identifier%TYPE;
g_previous_dob             	per_all_people_f.date_of_birth%TYPE;
g_previous_sex             	per_all_people_f.Sex%TYPE;
g_data_verification_dt     	per_all_people_f.date_employee_data_verified%TYPE;
--
g_last_update_date              per_all_people_f.last_update_date%TYPE;
g_last_updated_by               per_all_people_f.last_updated_by%TYPE;
g_last_update_login             per_all_people_f.last_update_login%TYPE;
g_created_by             	per_all_people_f.created_by%TYPE;
g_creation_date             	per_all_people_f.creation_date%TYPE;
--
g_per_attr_1               	per_all_people_f.attribute1%TYPE;
g_per_attr_2               	per_all_people_f.attribute2%TYPE;
g_per_attr_3               	per_all_people_f.attribute3%TYPE;
g_per_attr_4               	per_all_people_f.attribute4%TYPE;
g_per_attr_5               	per_all_people_f.attribute5%TYPE;
g_per_attr_6               	per_all_people_f.attribute6%TYPE;
g_per_attr_7               	per_all_people_f.attribute7%TYPE;
g_per_attr_8               	per_all_people_f.attribute8%TYPE;
g_per_attr_9               	per_all_people_f.attribute9%TYPE;
g_per_attr_10              	per_all_people_f.attribute10%TYPE;
--
-- g_work_telephone        	per_all_people_f.work_telephone%TYPE;
--
g_prim_address_line_1      	per_addresses.address_line1%TYPE;
g_prim_address_line_2      	per_addresses.address_line2%TYPE;
g_prim_address_line_3      	per_addresses.address_line3%TYPE;
g_prim_city                	per_addresses.town_or_city%TYPE;
g_prim_state               	per_addresses.REGION_2%TYPE;
g_prim_state_ansi             	per_addresses.REGION_2%TYPE;
g_prim_postal_code         	per_addresses.POSTAL_CODE%TYPE;
g_prim_country             	per_addresses.COUNTRY%TYPE;
g_prim_county              	per_addresses.region_1%TYPE;
g_prim_region_3            	per_addresses.region_3%TYPE;
g_prim_address_date        	per_addresses.date_from%TYPE;
g_addr_last_update_date        	per_addresses.last_update_date%TYPE;
g_addr_last_updated_by        	per_addresses.last_updated_by%TYPE;
g_addr_last_update_login       	per_addresses.last_update_login%TYPE;
g_addr_created_by        	per_addresses.created_by%TYPE;
g_addr_creation_date        	per_addresses.creation_date%TYPE;
g_prim_addr_service_area      	ben_svc_area_f.name%TYPE;
g_prim_addr_sva_id      	ben_svc_area_f.svc_area_id%TYPE;
--
g_mail_address_line_1      	per_addresses.address_line1%TYPE;
g_mail_address_line_2      	per_addresses.address_line2%TYPE;
g_mail_address_line_3      	per_addresses.address_line3%TYPE;
g_mail_city                	per_addresses.town_or_city%TYPE;
g_mail_state               	per_addresses.REGION_2%TYPE;
g_mail_postal_code         	per_addresses.POSTAL_CODE%TYPE;
g_mail_country             	per_addresses.COUNTRY%TYPE;
g_mail_county              	per_addresses.region_1%TYPE;
g_mail_region_3            	per_addresses.region_3%TYPE;
g_mail_address_date        	per_addresses.date_from%TYPE;
--
g_phone_home               	per_phones.phone_number%TYPE;
g_phone_work               	per_phones.phone_number%TYPE;
g_phone_fax                	per_phones.phone_number%TYPE;
g_phone_mobile             	per_phones.phone_number%TYPE;
--
g_last_hire_date           	per_periods_of_service.date_start%TYPE;
g_actual_term_date         	per_periods_of_service.actual_termination_date%TYPE;
g_adjusted_svc_date        	per_periods_of_service.adjusted_svc_date%TYPE;
g_term_reason              	per_periods_of_service.leaving_reason%TYPE;
g_pos_last_update_date        	per_periods_of_service.last_update_date%TYPE;
g_pos_last_updated_by        	per_periods_of_service.last_updated_by%TYPE;
g_pos_last_update_login        	per_periods_of_service.last_update_login%TYPE;
g_pos_created_by        	per_periods_of_service.created_by%TYPE;
g_pos_creation_date        	per_periods_of_service.creation_date%TYPE;
g_prs_flex_01        	        per_periods_of_service.attribute1%TYPE;
g_prs_flex_02        	        per_periods_of_service.attribute2%TYPE;
g_prs_flex_03        	        per_periods_of_service.attribute3%TYPE;
g_prs_flex_04        	        per_periods_of_service.attribute4%TYPE;
g_prs_flex_05        	        per_periods_of_service.attribute5%TYPE;
g_prs_flex_06        	        per_periods_of_service.attribute6%TYPE;
g_prs_flex_07        	        per_periods_of_service.attribute7%TYPE;
g_prs_flex_08        	        per_periods_of_service.attribute8%TYPE;
g_prs_flex_09        	        per_periods_of_service.attribute9%TYPE;
g_prs_flex_10        	        per_periods_of_service.attribute10%TYPE;
--
g_person_types                  per_person_types.user_person_type%type ;
g_person_type_id                per_person_types.person_type_id%type ;
--
g_employee_status          	per_assignment_status_types.user_status%TYPE;
g_employee_grade           	per_grades.name%TYPE;
g_employee_organization    	per_all_organization_units.name%TYPE;
--
g_location_code            	hr_locations.location_code%TYPE;
g_location_addr1            	hr_locations.ADDRESS_LINE_1%TYPE;
g_location_addr2            	hr_locations.ADDRESS_LINE_2%TYPE;
g_location_addr3            	hr_locations.ADDRESS_LINE_3%TYPE;
g_location_city            	hr_locations.TOWN_OR_CITY%TYPE;
g_location_country            	hr_locations.COUNTRY%TYPE;
g_location_zip            	hr_locations.POSTAL_CODE%TYPE;
g_location_region1            	hr_locations.REGION_1%TYPE;
g_location_region2            	hr_locations.REGION_2%TYPE;
g_location_region3            	hr_locations.REGION_3%TYPE;
--
g_org_location_addr1            hr_locations.ADDRESS_LINE_1%TYPE;
g_org_location_addr2            Hr_locations.ADDRESS_LINE_2%TYPE;
g_org_location_addr3            hr_locations.ADDRESS_LINE_3%TYPE;
g_org_location_city             Hr_locations.TOWN_OR_CITY%TYPE;
g_org_location_country          hr_locations.COUNTRY%TYPE;
g_org_location_zip              hr_locations.POSTAL_CODE%TYPE;
g_org_location_region1          hr_locations.REGION_1%TYPE;
g_org_location_region2          hr_locations.REGION_2%TYPE;
g_org_location_region3          hr_locations.REGION_3%TYPE;
g_org_location_phone            hr_locations.Telephone_number_1%TYPE;
--

g_job                      	per_jobs.name%TYPE;
g_position                 	per_positions.name%TYPE;
g_payroll                  	pay_all_payrolls_f.payroll_name%TYPE;
g_people_group             	pay_people_groups.group_name%TYPE;
g_pay_basis                	per_pay_bases.name%TYPE;
g_pay_basis_type              	per_pay_bases.pay_basis%TYPE;
--
g_employee_status_id       	per_assignment_status_types.assignment_status_type_id%TYPE;
g_employee_grade_id        	per_grades.grade_id%TYPE;
g_employee_organization_id 	per_all_organization_units.organization_id%TYPE;
g_location_id              	hr_locations.location_id%TYPE;
g_job_id                   	per_jobs.job_id%TYPE;
g_position_id              	per_positions.position_id%TYPE;
g_payroll_id               	pay_all_payrolls_f.payroll_id%TYPE;
g_people_group_id          	pay_people_groups.people_group_id%TYPE;
g_pay_basis_id             	per_pay_bases.pay_basis_id%TYPE;
g_payroll_period_type      	pay_all_payrolls_f.period_type%TYPE;
g_payroll_period_number    	per_time_periods.period_num%TYPE;
g_payroll_period_strtdt    	per_time_periods.start_date%TYPE;
g_payroll_period_enddt     	per_time_periods.end_date%TYPE;
g_payroll_costing          	pay_cost_allocation_keyflex.concatenated_segments%TYPE;
g_payroll_costing_id       	pay_cost_allocation_keyflex.cost_allocation_keyflex_id%TYPE;
g_payroll_consolidation_set     pay_consolidation_sets.consolidation_set_name%TYPE;
g_payroll_consolidation_set_id  pay_consolidation_sets.consolidation_set_id%TYPE;
--
g_per_in_ler_id            	ben_per_in_ler.per_in_ler_id%TYPE;
g_ler_name                 	ben_ler_f.name%TYPE;
g_ler_id                   	ben_ler_f.ler_id%TYPE;
g_lf_evt_ocrd_dt           	ben_per_in_ler.lf_evt_ocrd_dt%TYPE;
g_lf_evt_note_dt           	ben_per_in_ler.ntfn_dt%TYPE;
--
g_assignment_id                 per_all_assignments_f.assignment_id%TYPE;
g_employee_category        	per_all_assignments_f.employment_category%TYPE;
g_employee_barg_unit       	per_all_assignments_f.bargaining_unit_code%TYPE;
g_hourly_salaried_code     	per_all_assignments_f.hourly_salaried_code%TYPE;
g_labour_union_member_flag 	per_all_assignments_f.labour_union_member_flag%TYPE;
g_manager_flag             	per_all_assignments_f.manager_flag%TYPE;
g_asg_title                	per_all_assignments_f.title%TYPE;
g_asg_attr_1               	per_all_assignments_f.ass_attribute1%TYPE;
g_asg_attr_2               	per_all_assignments_f.ass_attribute2%TYPE;
g_asg_attr_3               	per_all_assignments_f.ass_attribute3%TYPE;
g_asg_attr_4               	per_all_assignments_f.ass_attribute4%TYPE;
g_asg_attr_5               	per_all_assignments_f.ass_attribute5%TYPE;
g_asg_attr_6               	per_all_assignments_f.ass_attribute6%TYPE;
g_asg_attr_7               	per_all_assignments_f.ass_attribute7%TYPE;
g_asg_attr_8               	per_all_assignments_f.ass_attribute8%TYPE;
g_asg_attr_9               	per_all_assignments_f.ass_attribute9%TYPE;
g_asg_attr_10              	per_all_assignments_f.ass_attribute10%TYPE;
g_asg_last_update_date        	per_all_assignments_f.last_update_date%TYPE;
g_asg_last_updated_by        	per_all_assignments_f.last_updated_by%TYPE;
g_asg_last_update_login       	per_all_assignments_f.last_update_login%TYPE;
g_asg_created_by        	per_all_assignments_f.created_by%TYPE;
g_asg_creation_date        	per_all_assignments_f.creation_date%TYPE;
g_asg_normal_hours              per_all_assignments_f.normal_hours%TYPE;
g_asg_frequency                 per_all_assignments_f.frequency%TYPE ;
g_asg_time_normal_start         per_all_assignments_f.time_normal_start%TYPE;
g_asg_time_normal_finish        per_all_assignments_f.time_normal_finish%TYPE;
g_asg_supervisor_id             per_all_assignments_f.supervisor_id%TYPE;
g_asg_type                      per_all_assignments_f.ASSIGNMENT_TYPE%TYPE;
g_base_salary                   number ;
--
g_abs_reason       	   	per_absence_attendances.abs_attendance_reason_id%TYPE;
g_abs_category     	   	per_absence_attendance_types.absence_category%TYPE;
g_abs_type         	   	per_absence_attendances.absence_attendance_type_id%TYPE;

-- 2841958
g_abs_reason_cd      	   	hr_lookups.lookup_code%TYPE;

g_abs_reason_name      	   	hr_lookups.meaning%TYPE;
g_abs_category_name    	   	hr_lookups.meaning%TYPE;
g_abs_type_name       	   	per_absence_attendance_types.name%TYPE;
g_abs_start_dt     	   	per_absence_attendances.date_start%TYPE;
g_abs_end_dt       	   	per_absence_attendances.date_end%TYPE;
g_abs_duration       	   	per_absence_attendances.absence_days%TYPE;
g_abs_flex_01              	per_absence_attendances.attribute1%TYPE;
g_abs_flex_02              	per_absence_attendances.attribute2%TYPE;
g_abs_flex_03              	per_absence_attendances.attribute3%TYPE;
g_abs_flex_04              	per_absence_attendances.attribute4%TYPE;
g_abs_flex_05              	per_absence_attendances.attribute5%TYPE;
g_abs_flex_06              	per_absence_attendances.attribute6%TYPE;
g_abs_flex_07              	per_absence_attendances.attribute7%TYPE;
g_abs_flex_08              	per_absence_attendances.attribute8%TYPE;
g_abs_flex_09              	per_absence_attendances.attribute9%TYPE;
g_abs_flex_10              	per_absence_attendances.attribute10%TYPE;
g_abs_last_update_date        	per_absence_attendances.last_update_date%TYPE;
g_abs_last_updated_by        	per_absence_attendances.last_updated_by%TYPE;
g_abs_last_update_login       	per_absence_attendances.last_update_login%TYPE;
g_abs_created_by        	per_absence_attendances.created_by%TYPE;
g_abs_creation_date        	per_absence_attendances.creation_date%TYPE;
--
g_flex_credit_provided     	ben_bnft_prvdd_ldgr_f.prvdd_val%TYPE;
g_flex_credit_forfited     	ben_bnft_prvdd_ldgr_f.frftd_val%TYPE;
g_flex_credit_used         	ben_bnft_prvdd_ldgr_f.used_val%TYPE;
g_flex_credit_excess       	ben_bnft_prvdd_ldgr_f.used_val%TYPE;
g_flex_pgm_id                   ben_pgm_f.pgm_id%TYPE;
g_flex_pgm_name                 ben_pgm_f.name%TYPE;
g_flex_pl_id                    ben_pl_f.pl_id%TYPE;
g_flex_pl_name                  ben_pl_f.name%TYPE;
g_flex_pl_typ_id                ben_pl_typ_f.pl_typ_id%TYPE;
g_flex_pl_typ_name              ben_pl_typ_f.name%TYPE;
g_flex_opt_id                   ben_opt_f.opt_id%TYPE;
g_flex_opt_name                 ben_opt_f.name%TYPE;
g_flex_cmbn_plip_id             ben_cmbn_plip_f.cmbn_plip_id%TYPE;
g_flex_cmbn_plip_name           ben_cmbn_plip_f.name%TYPE;
g_flex_cmbn_ptip_id             ben_cmbn_ptip_f.cmbn_ptip_id%TYPE;
g_flex_cmbn_ptip_name           ben_cmbn_ptip_f.name%TYPE;
g_flex_cmbn_ptip_opt_id         ben_cmbn_ptip_opt_f.cmbn_ptip_opt_id%TYPE;
g_flex_cmbn_ptip_opt_name       ben_cmbn_ptip_opt_f.name%TYPE;
g_flex_amt                      ben_prtt_rt_val.rt_val%TYPE;
g_flex_currency                 ben_prtt_enrt_rslt_f.uom%TYPE;
g_flex_bnft_pool_id             ben_elig_per_elctbl_chc.bnft_PRVDR_pool_id%TYPE;
g_flex_bnft_pool_name           ben_bnft_prvdr_pool_f.name%type;
--
-- detail - enrollment
--
/* Start of Changes for WWBUG: 1828349  added 	*/
g_enrt_prtt_enrt_rslt_id        ben_prtt_enrt_rslt_f.prtt_enrt_rslt_id%TYPE;
/* End of Changes for WWBUG: 1828349  added 	*/
g_enrt_pl_name             	ben_pl_f.name%TYPE;
g_enrt_opt_name            	ben_opt_f.name%TYPE;
g_enrt_pl_id               	ben_pl_f.pl_id%TYPE;
g_enrt_opt_id              	ben_opt_f.opt_id%TYPE;
g_enrt_pgm_id              	ben_pgm_f.pgm_id%TYPE;
g_enrt_pgm_name            	ben_pgm_f.name%TYPE;
g_enrt_pl_typ_id           	ben_pl_typ_f.pl_typ_id%TYPE;
g_enrt_pl_typ_name         	ben_pl_typ_f.name%TYPE;
g_enrt_pl_seq_num         	ben_prtt_enrt_rslt_f.pl_ordr_num%TYPE;
g_enrt_pip_seq_num         	ben_prtt_enrt_rslt_f.plip_ordr_num%TYPE;
g_enrt_ptp_seq_num         	ben_prtt_enrt_rslt_f.ptip_ordr_num%TYPE;
g_enrt_oip_seq_num         	ben_prtt_enrt_rslt_f.oipl_ordr_num%TYPE;
g_enrt_cvg_strt_dt         	ben_prtt_enrt_rslt_f.enrt_cvg_strt_dt%TYPE;
g_enrt_cvg_thru_dt         	ben_prtt_enrt_rslt_f.enrt_cvg_thru_dt%TYPE;
g_enrt_cvg_amt             	ben_prtt_enrt_rslt_f.bnft_amt%TYPE;
g_enrt_benefit_order_num   	ben_prtt_enrt_rslt_f.bnft_ordr_num%TYPE;
g_enrt_method              	ben_prtt_enrt_rslt_f.enrt_mthd_cd%TYPE;
g_enrt_ovrd_flag           	ben_prtt_enrt_rslt_f.enrt_ovridn_flag%TYPE;
g_enrt_ovrd_thru_dt        	ben_prtt_enrt_rslt_f.enrt_ovrid_thru_dt%TYPE;
g_enrt_ovrd_reason         	ben_prtt_enrt_rslt_f.enrt_ovrid_rsn_cd%TYPE;
g_enrt_suspended_flag      	ben_prtt_enrt_rslt_f.sspndd_flag%TYPE;
g_enrt_rslt_effct_strdt    	ben_prtt_enrt_rslt_f.effective_start_date%TYPE;
g_enrt_total_premium_amt   	ben_prtt_prem_f.std_prem_val%TYPE;
g_enrt_total_premium_uom   	ben_prtt_prem_f.std_prem_uom%TYPE;
g_enrt_uom               	ben_prtt_enrt_rslt_f.uom%TYPE;
g_enrt_rpt_group_name           ben_rptg_grp.name%TYPE;
g_enrt_rpt_group_id             ben_rptg_grp.rptg_grp_id%TYPE;
g_enrt_pl_yr_strdt              ben_yr_perd.start_date%TYPE;
g_enrt_pl_yr_enddt              ben_yr_perd.end_date%TYPE;
g_enrt_attr_1              	ben_prtt_enrt_rslt_f.pen_attribute1%TYPE;
g_enrt_attr_2              	ben_prtt_enrt_rslt_f.pen_attribute2%TYPE;
g_enrt_attr_3              	ben_prtt_enrt_rslt_f.pen_attribute3%TYPE;
g_enrt_attr_4              	ben_prtt_enrt_rslt_f.pen_attribute4%TYPE;
g_enrt_attr_5              	ben_prtt_enrt_rslt_f.pen_attribute5%TYPE;
g_enrt_attr_6              	ben_prtt_enrt_rslt_f.pen_attribute6%TYPE;
g_enrt_attr_7              	ben_prtt_enrt_rslt_f.pen_attribute7%TYPE;
g_enrt_attr_8              	ben_prtt_enrt_rslt_f.pen_attribute8%TYPE;
g_enrt_attr_9              	ben_prtt_enrt_rslt_f.pen_attribute9%TYPE;
g_enrt_attr_10             	ben_prtt_enrt_rslt_f.pen_attribute10%TYPE;
g_enrt_plcy_r_grp          	ben_popl_org_f.plcy_r_grp%TYPE;
g_enrt_ler_id            	ben_prtt_enrt_rslt_f.ler_id%TYPE;
g_enrt_assignment_id           	ben_prtt_enrt_rslt_f.assignment_id%TYPE;
g_pl_attr_1                	ben_pl_f.pln_attribute1%TYPE;
g_pl_attr_2                	ben_pl_f.pln_attribute2%TYPE;
g_pl_attr_3                	ben_pl_f.pln_attribute3%TYPE;
g_pl_attr_4                	ben_pl_f.pln_attribute4%TYPE;
g_pl_attr_5                	ben_pl_f.pln_attribute5%TYPE;
g_pl_attr_6                	ben_pl_f.pln_attribute6%TYPE;
g_pl_attr_7                	ben_pl_f.pln_attribute7%TYPE;
g_pl_attr_8                	ben_pl_f.pln_attribute8%TYPE;
g_pl_attr_9                	ben_pl_f.pln_attribute9%TYPE;
g_pl_attr_10               	ben_pl_f.pln_attribute10%TYPE;
g_pgm_attr_1               	ben_pgm_f.pgm_attribute1%TYPE;
g_pgm_attr_2               	ben_pgm_f.pgm_attribute2%TYPE;
g_pgm_attr_3               	ben_pgm_f.pgm_attribute3%TYPE;
g_pgm_attr_4               	ben_pgm_f.pgm_attribute4%TYPE;
g_pgm_attr_5               	ben_pgm_f.pgm_attribute5%TYPE;
g_pgm_attr_6               	ben_pgm_f.pgm_attribute6%TYPE;
g_pgm_attr_7               	ben_pgm_f.pgm_attribute7%TYPE;
g_pgm_attr_8               	ben_pgm_f.pgm_attribute8%TYPE;
g_pgm_attr_9               	ben_pgm_f.pgm_attribute9%TYPE;
g_pgm_attr_10              	ben_pgm_f.pgm_attribute10%TYPE;
g_ptp_attr_1               	ben_pl_typ_f.ptp_attribute1%TYPE;
g_ptp_attr_2               	ben_pl_typ_f.ptp_attribute2%TYPE;
g_ptp_attr_3               	ben_pl_typ_f.ptp_attribute3%TYPE;
g_ptp_attr_4               	ben_pl_typ_f.ptp_attribute4%TYPE;
g_ptp_attr_5               	ben_pl_typ_f.ptp_attribute5%TYPE;
g_ptp_attr_6               	ben_pl_typ_f.ptp_attribute6%TYPE;
g_ptp_attr_7               	ben_pl_typ_f.ptp_attribute7%TYPE;
g_ptp_attr_8               	ben_pl_typ_f.ptp_attribute8%TYPE;
g_ptp_attr_9               	ben_pl_typ_f.ptp_attribute9%TYPE;
g_ptp_attr_10              	ben_pl_typ_f.ptp_attribute10%TYPE;
g_plip_attr_1              	ben_plip_f.cpp_attribute1%TYPE;
g_plip_attr_2              	ben_plip_f.cpp_attribute2%TYPE;
g_plip_attr_3              	ben_plip_f.cpp_attribute3%TYPE;
g_plip_attr_4              	ben_plip_f.cpp_attribute4%TYPE;
g_plip_attr_5              	ben_plip_f.cpp_attribute5%TYPE;
g_plip_attr_6              	ben_plip_f.cpp_attribute6%TYPE;
g_plip_attr_7              	ben_plip_f.cpp_attribute7%TYPE;
g_plip_attr_8              	ben_plip_f.cpp_attribute8%TYPE;
g_plip_attr_9              	ben_plip_f.cpp_attribute9%TYPE;
g_plip_attr_10             	ben_plip_f.cpp_attribute10%TYPE;
g_oipl_attr_1              	ben_oipl_f.cop_attribute1%TYPE;
g_oipl_attr_2              	ben_oipl_f.cop_attribute2%TYPE;
g_oipl_attr_3              	ben_oipl_f.cop_attribute3%TYPE;
g_oipl_attr_4              	ben_oipl_f.cop_attribute4%TYPE;
g_oipl_attr_5              	ben_oipl_f.cop_attribute5%TYPE;
g_oipl_attr_6              	ben_oipl_f.cop_attribute6%TYPE;
g_oipl_attr_7              	ben_oipl_f.cop_attribute7%TYPE;
g_oipl_attr_8              	ben_oipl_f.cop_attribute8%TYPE;
g_oipl_attr_9              	ben_oipl_f.cop_attribute9%TYPE;
g_oipl_attr_10             	ben_oipl_f.cop_attribute10%TYPE;
g_ler_attr_1               	ben_ler_f.ler_attribute1%TYPE;
g_ler_attr_2               	ben_ler_f.ler_attribute2%TYPE;
g_ler_attr_3               	ben_ler_f.ler_attribute3%TYPE;
g_ler_attr_4               	ben_ler_f.ler_attribute4%TYPE;
g_ler_attr_5               	ben_ler_f.ler_attribute5%TYPE;
g_ler_attr_6               	ben_ler_f.ler_attribute6%TYPE;
g_ler_attr_7               	ben_ler_f.ler_attribute7%TYPE;
g_ler_attr_8               	ben_ler_f.ler_attribute8%TYPE;
g_ler_attr_9               	ben_ler_f.ler_attribute9%TYPE;
g_ler_attr_10              	ben_ler_f.ler_attribute10%TYPE;
g_opt_attr_1              	ben_opt_f.opt_attribute1%TYPE;
g_opt_attr_2              	ben_opt_f.opt_attribute2%TYPE;
g_opt_attr_3              	ben_opt_f.opt_attribute3%TYPE;
g_opt_attr_4              	ben_opt_f.opt_attribute4%TYPE;
g_opt_attr_5              	ben_opt_f.opt_attribute5%TYPE;
g_opt_attr_6              	ben_opt_f.opt_attribute6%TYPE;
g_opt_attr_7              	ben_opt_f.opt_attribute7%TYPE;
g_opt_attr_8              	ben_opt_f.opt_attribute8%TYPE;
g_opt_attr_9              	ben_opt_f.opt_attribute9%TYPE;
g_opt_attr_10             	ben_opt_f.opt_attribute10%TYPE;
g_enrt_lfevt_name               ben_ler_f.name%TYPE;
g_enrt_lfevt_status             ben_per_in_ler.per_in_ler_stat_cd%TYPE;
g_enrt_lfevt_note_dt            ben_per_in_ler.ntfn_dt%TYPE;
g_enrt_lfevt_ocrd_dt            ben_per_in_ler.lf_evt_ocrd_dt%TYPE;
g_prem_actl_prem_id             ben_actl_prem_f.actl_prem_id%type;
g_prem_mn_amt                   ben_prtt_prem_by_mo_f.val%TYPE;
g_prem_mn_uom                   ben_prtt_prem_by_mo_f.uom%TYPE;
g_prem_mn_cramt                 ben_prtt_prem_by_mo_f.cr_val%TYPE;
g_prem_mn_mnl_adj               ben_prtt_prem_by_mo_f.mnl_adj_flag%TYPE;
g_prem_mn_cr_mnl_adj            ben_prtt_prem_by_mo_f.cr_mnl_adj_flag%TYPE;
g_prem_month                    ben_prtt_prem_by_mo_f.mo_num%TYPE;
g_prem_last_upd_date            ben_prtt_prem_by_mo_f.last_update_date%type;
g_prem_year                     ben_prtt_prem_by_mo_f.yr_num%TYPE;
g_prem_mn_costalloc_name        pay_cost_allocation_keyflex.concatenated_segments%TYPE;
g_prem_mn_costalloc_id          pay_cost_allocation_keyflex.cost_allocation_keyflex_id%TYPE;
g_prem_mn_costalloc_flex_01     pay_cost_allocation_keyflex.segment1%TYPE;
g_prem_mn_costalloc_flex_02     pay_cost_allocation_keyflex.segment2%TYPE;
g_prem_mn_costalloc_flex_03     pay_cost_allocation_keyflex.segment3%TYPE;
g_prem_type                     ben_actl_prem_f.actl_prem_typ_cd%TYPE;
g_prtt_prem_by_mo_id            ben_prtt_prem_by_mo_f.prtt_prem_by_mo_id%TYPE;
g_enrt_mntot_prem_amt           ben_prtt_prem_by_mo_f.val%TYPE;
g_enrt_mntot_prem_cramt         ben_prtt_prem_by_mo_f.cr_val%TYPE;
g_enrt_orgcovg_strdt            ben_prtt_enrt_rslt_f.orgnl_enrt_dt%TYPE;
g_enrt_prt_orgcovg_strdt        ben_prtt_enrt_rslt_f.orgnl_enrt_dt%TYPE;
g_enrt_status_cd                ben_prtt_enrt_rslt_f.prtt_enrt_rslt_stat_cd%TYPE;
g_enrt_intrcovg_flag            varchar2(30);
g_enrt_int_pl_id                ben_prtt_enrt_rslt_f.pl_id%TYPE;
g_enrt_int_pl_name              ben_pl_f.name%TYPE;
g_enrt_int_opt_id               ben_opt_f.opt_id%TYPE;
g_enrt_int_opt_name             ben_opt_f.name%TYPE;
g_enrt_int_cvg_amt              ben_prtt_enrt_rslt_f.bnft_amt%TYPE;
g_enrt_elec_made_dt             ben_pil_elctbl_chc_popl.elcns_made_dt%TYPE;
g_enrt_pl_fd_name               ben_pl_f.short_name%Type ;
g_enrt_pl_fd_code               ben_pl_f.short_code%Type ;
g_enrt_pgm_fd_name              ben_pgm_f.short_name%Type ;
g_enrt_pgm_fd_code              ben_pgm_f.short_code%Type ;
g_enrt_pl_typ_fd_name           ben_pl_typ_f.short_name%Type ;
g_enrt_pl_typ_fd_code           ben_pl_typ_f.short_code%Type ;
g_enrt_opt_fd_name              ben_opt_f.short_name%Type ;
g_enrt_opt_fd_code              ben_opt_f.short_code%Type ;
g_enrt_opt_pl_fd_name	        ben_oipl_f.short_name%Type ;
g_enrt_opt_pl_fd_code	        ben_oipl_f.short_code%Type ;
g_enrt_pl_pgm_fd_name           ben_plip_f.short_name%Type ;
g_enrt_pl_pgm_fd_code           ben_plip_f.short_code%Type ;
g_enrt_pl_typ_pgm_fd_name       ben_pl_typ_f.short_name%Type ;
g_enrt_pl_typ_pgm_fd_code       ben_pl_typ_f.short_code%Type ;
-- rates
--
g_ee_pre_tax_cost         	ben_prtt_rt_val.rt_val%TYPE;
g_ee_after_tax_cost       	ben_prtt_rt_val.rt_val%TYPE;
g_ee_ttl_cost             	ben_prtt_rt_val.rt_val%TYPE;
g_er_ttl_cost             	ben_prtt_rt_val.rt_val%TYPE;
g_ee_ttl_distribution     	ben_prtt_rt_val.rt_val%TYPE;
g_er_ttl_distribution     	ben_prtt_rt_val.rt_val%TYPE;
g_ttl_other_rate         	ben_prtt_rt_val.rt_val%TYPE;

--cwb 2832419
g_er_cwb_dst_bdgt               ben_prtt_rt_val.rt_val%TYPE;
g_er_cwb_misc_rate_1            ben_prtt_rt_val.rt_val%TYPE;
g_er_cwb_misc_rate_2            ben_prtt_rt_val.rt_val%TYPE;
g_er_cwb_misc_rate_3            ben_prtt_rt_val.rt_val%TYPE;
g_er_cwb_elig_salary            ben_prtt_rt_val.rt_val%TYPE;
g_er_cwb_grant_price            ben_prtt_rt_val.rt_val%TYPE;
g_er_cwb_other_salary           ben_prtt_rt_val.rt_val%TYPE;
g_er_cwb_reserve                ben_prtt_rt_val.rt_val%TYPE;
g_er_cwb_recomond_amt           ben_prtt_rt_val.rt_val%TYPE;
g_er_cwb_stated_salary          ben_prtt_rt_val.rt_val%TYPE;
g_er_cwb_tot_compensation       ben_prtt_rt_val.rt_val%TYPE;
g_er_cwb_worksheet_bdgt         ben_prtt_rt_val.rt_val%TYPE;
g_er_cwb_worksheet_amt         ben_prtt_rt_val.rt_val%TYPE;
-- reimbursement 2832419
g_er_forfeited                  ben_prtt_rt_val.rt_val%TYPE;
g_er_reimbursement              ben_prtt_rt_val.rt_val%TYPE;
g_pev_er_forfeited              ben_prtt_rt_val.rt_val%TYPE;
g_pev_er_reimbursement          ben_prtt_rt_val.rt_val%TYPE;

--
g_pev_ee_pre_tax_contr          number;
g_pev_ee_after_tax_contr        number;
g_pev_ee_ttl_contr              number;
g_pev_er_ttl_contr              number;
g_pev_ee_ttl_distribution       number;
g_pev_er_ttl_distribution       number;
g_pev_ttl_other_rate            number;
--
-- detail - dependent
--
g_dpnt_national_identifier 	per_all_people_f.national_identifier%TYPE;
g_dpnt_last_name           	per_all_people_f.last_name%TYPE;
g_dpnt_first_name          	per_all_people_f.first_name%TYPE;
g_dpnt_middle_names        	per_all_people_f.middle_names%TYPE;
g_dpnt_full_name           	per_all_people_f.full_name%TYPE;
g_dpnt_suffix              	per_all_people_f.suffix%TYPE;
g_Dpnt_prefix                  per_all_people_f.pre_name_adjunct%TYPE;
g_dpnt_title               	per_all_people_f.title%TYPE;
g_dpnt_rlshp_type          	per_contact_relationships.contact_type%TYPE;
g_dpnt_contact_seq_num     	per_contact_relationships.sequence_number%TYPE;
g_dpnt_shared_resd_flag    per_contact_relationships.rltd_per_rsds_w_dsgntr_flag%TYPE;
g_dpnt_sex                 	per_all_people_f.sex%TYPE;
g_dpnt_date_of_birth       	per_all_people_f.date_of_birth%TYPE;
g_dpnt_marital_status      	per_all_people_f.marital_status%TYPE;
g_dpnt_disabled_flag       	per_all_people_f.registered_disabled_flag%TYPE;
g_dpnt_student_status      	per_all_people_f.student_status%TYPE;
g_dpnt_date_of_death       	per_all_people_f.date_of_death%TYPE;
g_dpnt_cvg_strt_dt         	ben_elig_cvrd_dpnt_f.cvg_strt_dt%TYPE;
g_dpnt_cvg_thru_dt         	ben_elig_cvrd_dpnt_f.cvg_thru_dt%TYPE;
g_dpnt_nationality         	per_all_people_f.nationality%TYPE;
g_dpnt_language            	per_all_people_f.correspondence_language%TYPE;
g_dpnt_email_address       	per_all_people_f.email_address%TYPE;
g_dpnt_known_as            	per_all_people_f.known_as%TYPE;
g_dpnt_pre_name_adjunct    	per_all_people_f.pre_name_adjunct%TYPE;
g_dpnt_tobacco_usage       	per_all_people_f.uses_tobacco_flag%TYPE;
g_dpnt_prev_last_name      	per_all_people_f.last_name%TYPE;
g_dpnt_prim_address1       	per_addresses.address_line1%TYPE;
g_dpnt_prim_address2       	per_addresses.address_line2%TYPE;
g_dpnt_prim_address3       	per_addresses.address_line3%TYPE;
g_dpnt_prim_city           	per_addresses.town_or_city%TYPE;
g_dpnt_prim_state          	per_addresses.region_2%TYPE;
g_dpnt_prim_postal_code    	per_addresses.postal_code%TYPE;
g_dpnt_prim_country        	per_addresses.country%TYPE;
g_dpnt_prim_effect_date    	per_addresses.date_from%TYPE;
g_dpnt_prim_region         	per_addresses.region_3%TYPE;
g_dpnt_home_phone          	per_phones.phone_number%TYPE;
g_dpnt_fax                 	per_phones.phone_number%TYPE;
g_dpnt_mobile              	per_phones.phone_number%TYPE;
g_dpnt_work_phone          	per_phones.phone_number%TYPE;
g_dpnt_cvrd_dpnt_id             ben_elig_cvrd_dpnt_f.elig_cvrd_dpnt_id%TYPE;
--
-- detail - eligible dependent
--
g_elig_dpnt_national_ident          per_all_people_f.national_identifier%TYPE;
g_elig_dpnt_last_name           	per_all_people_f.last_name%TYPE;
g_elig_dpnt_first_name          	per_all_people_f.first_name%TYPE;
g_elig_dpnt_middle_names        	per_all_people_f.middle_names%TYPE;
g_elig_dpnt_full_name           	per_all_people_f.full_name%TYPE;
g_elig_dpnt_suffix              	per_all_people_f.suffix%TYPE;
g_elig_dpnt_prefix                     per_all_people_f.pre_name_adjunct%TYPE;
g_elig_dpnt_title               	per_all_people_f.title%TYPE;
g_elig_dpnt_rlshp_type          	per_contact_relationships.contact_type%TYPE;
g_elig_dpnt_contact_seq_num     	per_contact_relationships.sequence_number%TYPE;
g_elig_dpnt_shared_resd_flag  per_contact_relationships.rltd_per_rsds_w_dsgntr_flag%TYPE;
g_elig_dpnt_sex                 	per_all_people_f.sex%TYPE;
g_elig_dpnt_date_of_birth       	per_all_people_f.date_of_birth%TYPE;
g_elig_dpnt_marital_status      	per_all_people_f.marital_status%TYPE;
g_elig_dpnt_disabled_flag       	per_all_people_f.registered_disabled_flag%TYPE;
g_elig_dpnt_student_status      	per_all_people_f.student_status%TYPE;
g_elig_dpnt_date_of_death       	per_all_people_f.date_of_death%TYPE;
g_elig_dpnt_elig_strt_dt         	ben_elig_dpnt.elig_strt_dt%TYPE;
g_elig_dpnt_elig_thru_dt         	ben_elig_dpnt.elig_thru_dt%TYPE;
g_elig_dpnt_create_dt         	ben_elig_dpnt.create_dt%TYPE;
g_elig_dpnt_ovrdn_flag        	ben_elig_dpnt.ovrdn_flag%TYPE;
g_elig_dpnt_ovrdn_thru_dt     	ben_elig_dpnt.ovrdn_thru_dt%TYPE;
g_elig_dpnt_nationality         	per_all_people_f.nationality%TYPE;
g_elig_dpnt_language            	per_all_people_f.correspondence_language%TYPE;
g_elig_dpnt_email_address       	per_all_people_f.email_address%TYPE;
g_elig_dpnt_known_as            	per_all_people_f.known_as%TYPE;
g_elig_dpnt_pre_name_adjunct    	per_all_people_f.pre_name_adjunct%TYPE;
g_elig_dpnt_tobacco_usage       	per_all_people_f.uses_tobacco_flag%TYPE;
g_elig_dpnt_prev_last_name      	per_all_people_f.last_name%TYPE;
g_elig_dpnt_prim_address1       	per_addresses.address_line1%TYPE;
g_elig_dpnt_prim_address2       	per_addresses.address_line2%TYPE;
g_elig_dpnt_prim_address3       	per_addresses.address_line3%TYPE;
g_elig_dpnt_prim_city           	per_addresses.town_or_city%TYPE;
g_elig_dpnt_prim_state          	per_addresses.region_2%TYPE;
g_elig_dpnt_prim_postal_code    	per_addresses.postal_code%TYPE;
g_elig_dpnt_prim_country        	per_addresses.country%TYPE;
g_elig_dpnt_prim_effect_date    	per_addresses.date_from%TYPE;
g_elig_dpnt_prim_region         	per_addresses.region_3%TYPE;
g_elig_dpnt_home_phone          	per_phones.phone_number%TYPE;
g_elig_dpnt_fax                 	per_phones.phone_number%TYPE;
g_elig_dpnt_mobile              	per_phones.phone_number%TYPE;
g_elig_dpnt_work_phone          	per_phones.phone_number%TYPE;
g_elig_dpnt_id                   	ben_elig_dpnt.elig_dpnt_id%TYPE;
--
-- contacts
--
g_contact_national_ident            per_all_people_f.national_identifier%TYPE;
g_contact_last_name           	per_all_people_f.last_name%TYPE;
g_contact_first_name          	per_all_people_f.first_name%TYPE;
g_contact_middle_names        	per_all_people_f.middle_names%TYPE;
g_contact_full_name           	per_all_people_f.full_name%TYPE;
g_contact_suffix              	per_all_people_f.suffix%TYPE;
g_contact_prefix               per_all_people_f.pre_name_adjunct%TYPE;
g_contact_title               	per_all_people_f.title%TYPE;
g_contact_sex                 	per_all_people_f.sex%TYPE;
g_contact_date_of_birth       	per_all_people_f.date_of_birth%TYPE;
g_contact_marital_status      	per_all_people_f.marital_status%TYPE;
g_contact_disabled_flag       	per_all_people_f.registered_disabled_flag%TYPE;
g_contact_student_status      	per_all_people_f.student_status%TYPE;
g_contact_date_of_death       	per_all_people_f.date_of_death%TYPE;
g_contact_nationality         	per_all_people_f.nationality%TYPE;
g_contact_language            	per_all_people_f.correspondence_language%TYPE;
g_contact_email_address       	per_all_people_f.email_address%TYPE;
g_contact_known_as            	per_all_people_f.known_as%TYPE;
g_contact_pre_name_adjunct    	per_all_people_f.pre_name_adjunct%TYPE;
g_contact_tobacco_usage       	per_all_people_f.uses_tobacco_flag%TYPE;
g_contact_prev_last_name      	per_all_people_f.last_name%TYPE;
g_contact_prim_address1       	per_addresses.address_line1%TYPE;
g_contact_prim_address2       	per_addresses.address_line2%TYPE;
g_contact_prim_address3       	per_addresses.address_line3%TYPE;
g_contact_prim_city           	per_addresses.town_or_city%TYPE;
g_contact_prim_state          	per_addresses.region_2%TYPE;
g_contact_prim_postal_code    	per_addresses.postal_code%TYPE;
g_contact_prim_country        	per_addresses.country%TYPE;
g_contact_prim_effect_date    	per_addresses.date_from%TYPE;
g_contact_prim_region         	per_addresses.region_3%TYPE;
g_contact_home_phone          	per_phones.phone_number%TYPE;
g_contact_fax                 	per_phones.phone_number%TYPE;
g_contact_mobile              	per_phones.phone_number%TYPE;
g_contact_work_phone          	per_phones.phone_number%TYPE;
g_contact_rlshp_type          	per_contact_relationships.contact_type%TYPE;
g_contact_rlshp_id          	per_contact_relationships.contact_relationship_id%TYPE;
g_contact_seq_num     	        per_contact_relationships.sequence_number%TYPE;
g_contact_prmy_contact_flag     per_contact_relationships.PRIMARY_CONTACT_FLAG%TYPE;
g_contact_shared_resd_flag      per_contact_relationships.RLTD_PER_RSDS_W_DSGNTR_FLAG%TYPE;
g_contact_personal_flag         per_contact_relationships.PERSONAL_FLAG%TYPE;
g_contact_pymts_rcpnt_flag      per_contact_relationships.THIRD_PARTY_PAY_FLAG%TYPE;
g_contact_start_date            per_contact_relationships.DATE_START%TYPE;
g_contact_end_date              per_contact_relationships.DATE_END%TYPE;
g_contact_start_life_evt        ben_ler_f.name%TYPE;
g_contact_start_ler_id          ben_ler_f.ler_id%TYPE;
g_contact_end_life_evt          ben_ler_f.name%TYPE;
g_contact_end_ler_id            ben_ler_f.ler_id%TYPE;
g_contact_is_elig_dpnt_flag     varchar2(30);
g_contact_is_cvrd_dpnt_flag     varchar2(30);
g_contact_is_bnfcry_flag        varchar2(30);

-- communicaton
--
g_per_cm_id            		ben_per_cm_f.per_cm_id%type;
g_cm_eff_dt            		ben_per_cm_f.effective_start_date%type;
g_cm_type              		ben_cm_typ_f.name%type;
g_cm_type_id           		ben_cm_typ_f.cm_typ_id%type;
g_cm_short_name        		ben_cm_typ_f.shrt_name%type;
g_cm_kit               		ben_cm_typ_f.pc_kit_cd%type;
g_cm_lf_evt_ocrd_dt    		ben_per_in_ler.lf_evt_ocrd_dt%TYPE;
g_cm_lf_evt                     ben_ler_f.name%TYPE;
g_cm_lf_evt_id                  ben_ler_f.ler_id%TYPE;
g_cm_lf_evt_stat                ben_per_in_ler.per_in_ler_stat_cd%TYPE;
g_cm_lf_evt_ntfn_dt             ben_per_in_ler.ntfn_dt%TYPE;
g_cm_per_in_ler_id     		ben_per_cm_f.per_in_ler_id%TYPE;
g_cm_prtt_enrt_actn_id		ben_per_cm_f.prtt_enrt_actn_id%TYPE;
g_cm_trgr_proc_name    		ben_cm_trgr.proc_cd%type;
g_cm_trgr_proc_dt      		ben_per_cm_trgr_f.effective_start_date%type;
g_cm_address_id                 ben_per_cm_prvdd_f.address_id%type;
g_cm_addr_line1        		per_addresses.address_line1%type;
g_cm_addr_line2        		per_addresses.address_line2%type;
g_cm_addr_line3        		per_addresses.address_line3%type;
g_cm_city              		per_addresses.town_or_city%type;
g_cm_state             		per_addresses.region_2%type;
g_cm_postal_code       		per_addresses.postal_code%TYPE;
g_cm_country           		per_addresses.country%type;
g_cm_county            		per_addresses.region_1%type;
g_cm_region_3          		per_addresses.region_3%type;
g_cm_dlvry_instn_txt   		ben_per_cm_prvdd_f.dlvry_instn_txt%type;
g_cm_inspn_rqd_flag    		ben_per_cm_prvdd_f.inspn_rqd_flag%type;
g_cm_to_be_sent_dt     		ben_per_cm_prvdd_f.to_be_sent_dt%type;
g_cm_prvdd_eff_dt               ben_per_cm_prvdd_f.effective_start_date%type;
g_cm_sent_dt                    ben_per_cm_prvdd_f.sent_dt%type;
g_cm_last_update_date           ben_per_cm_f.last_update_date%TYPE;
g_cm_pvdd_last_update_date      ben_per_cm_prvdd_f.last_update_date%type;
g_cm_address_date      		per_addresses.date_from%type;
--
g_ppr_name             		ben_prmry_care_prvdr_f.name%type;
g_ppr_ident            		ben_prmry_care_prvdr_f.ext_ident%type;
g_ppr_typ              		ben_prmry_care_prvdr_f.prmry_care_prvdr_typ_cd%type;
g_ppr_strt_dt          		ben_prmry_care_prvdr_f.effective_start_date%type;
g_ppr_end_dt           		ben_prmry_care_prvdr_f.effective_end_date%type;
--
g_dpnt_ppr_name        		ben_prmry_care_prvdr_f.name%type;
g_dpnt_ppr_ident       		ben_prmry_care_prvdr_f.ext_ident%type;
g_dpnt_ppr_typ         		ben_prmry_care_prvdr_f.prmry_care_prvdr_typ_cd%type;
g_dpnt_ppr_strt_dt     		ben_prmry_care_prvdr_f.effective_start_date%type;
g_dpnt_ppr_end_dt      		ben_prmry_care_prvdr_f.effective_end_date%type;
--
-- payroll
--
g_element_name                   pay_element_types_f.element_name%TYPE;
g_element_id                     pay_element_types_f.element_type_id%TYPE;
g_element_reporting_name         pay_element_types_f.reporting_name%TYPE;
g_element_description            pay_element_types_f.description%TYPE;
g_element_classification_name    pay_element_classifications.classification_name%TYPE;
g_element_classification_id      pay_element_classifications.classification_id%TYPE;
g_element_processing_type        pay_element_types_f.processing_type%TYPE;
g_element_input_currency_code    pay_element_types_f.input_currency_code%TYPE;
g_element_output_currency_code   pay_element_types_f.output_currency_code%TYPE;
g_element_skip_rule              ff_formulas_f.formula_name%TYPE;
g_element_skip_rule_id           ff_formulas_f.formula_id%TYPE;
g_element_input_value_name       pay_input_values_f.name%TYPE;
g_element_input_value_id         pay_input_values_f.input_value_id%TYPE;
g_element_input_value_units      pay_input_values_f.uom%TYPE;
g_element_input_value_sequence   pay_input_values_f.display_sequence%TYPE;
g_element_entry_value            pay_element_entry_values_f.screen_entry_value%TYPE;
g_element_entry_costing          pay_cost_allocation_keyflex.concatenated_segments%TYPE;
g_element_entry_costing_id       pay_cost_allocation_keyflex.cost_allocation_keyflex_id%TYPE;
g_element_entry_reason           pay_element_entries_f.reason%TYPE;
g_element_entry_id               pay_element_entries_f.element_entry_id%TYPE;
g_element_entry_eff_start_date   pay_element_entries_f.effective_start_date%TYPE;
g_element_entry_eff_end_date     pay_element_entries_f.effective_end_date%TYPE;
g_element_entry_value_id         pay_element_entry_values_f.element_entry_value_id%TYPE;
g_element_eev_eff_strt_date      pay_element_entry_values_f.effective_start_date%TYPE;
g_element_eev_eff_end_date       pay_element_entry_values_f.effective_end_date%TYPE;

--
-- eligiblitity
--
g_elig_per_elctbl_chc_id         ben_elig_per_elctbl_chc.elig_per_elctbl_chc_id%TYPE;
g_elig_enrt_strt_dt              ben_pil_elctbl_chc_popl.enrt_perd_strt_dt%TYPE;
g_elig_enrt_end_dt               ben_pil_elctbl_chc_popl.enrt_perd_end_dt%TYPE;
g_elig_dflt_enrt_dt              ben_pil_elctbl_chc_popl.dflt_enrt_dt%TYPE;
g_elig_uom                       ben_pil_elctbl_chc_popl.uom%TYPE;
g_elig_pl_name                   ben_pl_f.name%TYPE;
g_elig_pl_seq_num         	 ben_prtt_enrt_rslt_f.pl_ordr_num%TYPE;
g_elig_pip_seq_num         	 ben_prtt_enrt_rslt_f.plip_ordr_num%TYPE;
g_elig_ptp_seq_num         	 ben_prtt_enrt_rslt_f.ptip_ordr_num%TYPE;
g_elig_oip_seq_num         	 ben_prtt_enrt_rslt_f.oipl_ordr_num%TYPE;
g_elig_opt_name                  ben_opt_f.name%TYPE;
g_elig_cvg_amt                   ben_enrt_bnft.val%TYPE;
g_elig_cvg_min_amt               ben_enrt_bnft.MN_VAL%TYPE;
g_elig_cvg_max_amt               ben_enrt_bnft.MX_VAL%TYPE;
g_elig_cvg_inc_amt               ben_enrt_bnft.INCRMT_VAL%TYPE;
g_elig_cvg_dfl_amt               ben_enrt_bnft.DFLT_VAL%TYPE;
g_elig_cvg_dfl_flg               ben_enrt_bnft.dflt_flag%TYPE;
g_elig_cvg_seq_no                ben_enrt_bnft.ORDR_NUM%TYPE;
g_elig_cvg_onl_flg               ben_enrt_bnft.ENTR_VAL_AT_ENRT_FLAG%TYPE;
g_elig_cvg_calc_mthd             ben_enrt_bnft.CVG_MLT_CD%TYPE;
g_elig_cvg_bnft_typ              ben_enrt_bnft.BNFT_TYP_CD%TYPE;
g_elig_cvg_bnft_uom              ben_enrt_bnft.NNMNTRY_UOM%TYPE;
g_elig_pl_ord_no                 ben_plip_f.ordr_num%TYPE;
g_elig_opt_ord_no                ben_oipl_f.ordr_num%TYPE;
g_elig_pl_id                     ben_pl_f.pl_id%TYPE;
g_elig_pl_typ_name             	 ben_pl_typ_f.name%TYPE;
g_elig_pl_typ_id               	 ben_pl_typ_f.pl_typ_id%TYPE;
g_elig_opt_id                    ben_opt_f.opt_id%TYPE;
g_elig_age_val                   ben_elig_per_f.age_val%TYPE;
g_elig_los_val                   ben_elig_per_f.los_val%TYPE;
g_elig_age_uom                   ben_elig_per_f.age_uom%TYPE;
g_elig_los_uom                   ben_elig_per_f.los_uom%TYPE;
g_elig_comp_amt                  ben_elig_per_f.comp_ref_amt%TYPE;
g_elig_comp_amt_uom              ben_elig_per_f.comp_ref_uom%TYPE;
g_elig_cmbn_age_n_los            ben_elig_per_f.cmbn_age_n_los_val%TYPE;
g_elig_hrs_wkd                   ben_elig_per_f.hrs_wkd_val%TYPE;
g_elig_pct_fl_tm                 ben_elig_per_f.pct_fl_tm_val%TYPE;
g_elig_min_amt                   ben_enrt_rt.mn_elcn_val%TYPE;
g_elig_max_amt                   ben_enrt_rt.mx_elcn_val%TYPE;
g_elig_incr_amt                  ben_enrt_rt.incrmt_elcn_val%TYPE;
g_elig_dflt_amt                  ben_enrt_rt.dflt_val%TYPE;
g_elig_ee_pre_tax_cost           ben_enrt_rt.val%TYPE;
g_elig_ee_after_tax_cost         ben_enrt_rt.val%TYPE;
g_elig_ee_ttl_cost               ben_enrt_rt.val%TYPE;
g_elig_er_ttl_cost               ben_enrt_rt.val%TYPE;
g_elig_ee_ttl_distribution       ben_enrt_rt.val%TYPE;
g_elig_er_ttl_distribution       ben_enrt_rt.val%TYPE;
g_elig_ttl_other_rate            ben_enrt_rt.val%TYPE;
g_elig_elec_made_dt              ben_pil_elctbl_chc_popl.elcns_made_dt%TYPE;
g_elig_program_id                ben_pgm_f.pgm_id%TYPE;
g_elig_program_name              ben_pgm_f.name%TYPE;
g_elig_total_premium_amt         ben_enrt_prem.val%TYPE;
g_elig_total_premium_uom         ben_enrt_prem.uom%TYPE;
g_elig_rpt_group_name            ben_rptg_grp.name%TYPE;
g_elig_rpt_group_id              ben_rptg_grp.rptg_grp_id%TYPE;
g_elig_pl_yr_strdt               ben_yr_perd.start_date%TYPE;
g_elig_pl_yr_enddt               ben_yr_perd.end_date%TYPE;
g_elig_flex_01                   ben_elig_per_elctbl_chc.epe_attribute1%TYPE;
g_elig_flex_02                   ben_elig_per_elctbl_chc.epe_attribute2%TYPE;
g_elig_flex_03                   ben_elig_per_elctbl_chc.epe_attribute3%TYPE;
g_elig_flex_04                   ben_elig_per_elctbl_chc.epe_attribute4%TYPE;
g_elig_flex_05                   ben_elig_per_elctbl_chc.epe_attribute5%TYPE;
g_elig_flex_06                   ben_elig_per_elctbl_chc.epe_attribute6%TYPE;
g_elig_flex_07                   ben_elig_per_elctbl_chc.epe_attribute7%TYPE;
g_elig_flex_08                   ben_elig_per_elctbl_chc.epe_attribute8%TYPE;
g_elig_flex_09                   ben_elig_per_elctbl_chc.epe_attribute9%TYPE;
g_elig_flex_10                   ben_elig_per_elctbl_chc.epe_attribute10%TYPE;
g_elig_plan_flex_01              ben_pl_f.pln_attribute1%TYPE;
g_elig_plan_flex_02              ben_pl_f.pln_attribute2%TYPE;
g_elig_plan_flex_03              ben_pl_f.pln_attribute3%TYPE;
g_elig_plan_flex_04              ben_pl_f.pln_attribute4%TYPE;
g_elig_plan_flex_05              ben_pl_f.pln_attribute5%TYPE;
g_elig_plan_flex_06              ben_pl_f.pln_attribute6%TYPE;
g_elig_plan_flex_07              ben_pl_f.pln_attribute7%TYPE;
g_elig_plan_flex_08              ben_pl_f.pln_attribute8%TYPE;
g_elig_plan_flex_09              ben_pl_f.pln_attribute9%TYPE;
g_elig_plan_flex_10              ben_pl_f.pln_attribute10%TYPE;
g_elig_pgm_flex_01               ben_pgm_f.pgm_attribute1%TYPE;
g_elig_pgm_flex_02               ben_pgm_f.pgm_attribute2%TYPE;
g_elig_pgm_flex_03               ben_pgm_f.pgm_attribute3%TYPE;
g_elig_pgm_flex_04               ben_pgm_f.pgm_attribute4%TYPE;
g_elig_pgm_flex_05               ben_pgm_f.pgm_attribute5%TYPE;
g_elig_pgm_flex_06               ben_pgm_f.pgm_attribute6%TYPE;
g_elig_pgm_flex_07               ben_pgm_f.pgm_attribute7%TYPE;
g_elig_pgm_flex_08               ben_pgm_f.pgm_attribute8%TYPE;
g_elig_pgm_flex_09               ben_pgm_f.pgm_attribute9%TYPE;
g_elig_pgm_flex_10               ben_pgm_f.pgm_attribute10%TYPE;
g_elig_ptp_flex_01               ben_pl_typ_f.ptp_attribute1%TYPE;
g_elig_ptp_flex_02               ben_pl_typ_f.ptp_attribute2%TYPE;
g_elig_ptp_flex_03               ben_pl_typ_f.ptp_attribute3%TYPE;
g_elig_ptp_flex_04               ben_pl_typ_f.ptp_attribute4%TYPE;
g_elig_ptp_flex_05               ben_pl_typ_f.ptp_attribute5%TYPE;
g_elig_ptp_flex_06               ben_pl_typ_f.ptp_attribute6%TYPE;
g_elig_ptp_flex_07               ben_pl_typ_f.ptp_attribute7%TYPE;
g_elig_ptp_flex_08               ben_pl_typ_f.ptp_attribute8%TYPE;
g_elig_ptp_flex_09               ben_pl_typ_f.ptp_attribute9%TYPE;
g_elig_ptp_flex_10               ben_pl_typ_f.ptp_attribute10%TYPE;
g_elig_pl_in_pgm_flex_01         ben_plip_f.cpp_attribute1%TYPE;
g_elig_pl_in_pgm_flex_02         ben_plip_f.cpp_attribute2%TYPE;
g_elig_pl_in_pgm_flex_03         ben_plip_f.cpp_attribute3%TYPE;
g_elig_pl_in_pgm_flex_04         ben_plip_f.cpp_attribute4%TYPE;
g_elig_pl_in_pgm_flex_05         ben_plip_f.cpp_attribute5%TYPE;
g_elig_pl_in_pgm_flex_06         ben_plip_f.cpp_attribute6%TYPE;
g_elig_pl_in_pgm_flex_07         ben_plip_f.cpp_attribute7%TYPE;
g_elig_pl_in_pgm_flex_08         ben_plip_f.cpp_attribute8%TYPE;
g_elig_pl_in_pgm_flex_09         ben_plip_f.cpp_attribute9%TYPE;
g_elig_pl_in_pgm_flex_10         ben_plip_f.cpp_attribute10%TYPE;
g_elig_opt_in_pl_flex_01         ben_oipl_f.cop_attribute1%TYPE;
g_elig_opt_in_pl_flex_02         ben_oipl_f.cop_attribute2%TYPE;
g_elig_opt_in_pl_flex_03         ben_oipl_f.cop_attribute3%TYPE;
g_elig_opt_in_pl_flex_04         ben_oipl_f.cop_attribute4%TYPE;
g_elig_opt_in_pl_flex_05         ben_oipl_f.cop_attribute5%TYPE;
g_elig_opt_in_pl_flex_06         ben_oipl_f.cop_attribute6%TYPE;
g_elig_opt_in_pl_flex_07         ben_oipl_f.cop_attribute7%TYPE;
g_elig_opt_in_pl_flex_08         ben_oipl_f.cop_attribute8%TYPE;
g_elig_opt_in_pl_flex_09         ben_oipl_f.cop_attribute9%TYPE;
g_elig_opt_in_pl_flex_10         ben_oipl_f.cop_attribute10%TYPE;
g_elig_opt_flex_01               ben_opt_f.opt_attribute1%TYPE;
g_elig_opt_flex_02               ben_opt_f.opt_attribute2%TYPE;
g_elig_opt_flex_03               ben_opt_f.opt_attribute3%TYPE;
g_elig_opt_flex_04               ben_opt_f.opt_attribute4%TYPE;
g_elig_opt_flex_05               ben_opt_f.opt_attribute5%TYPE;
g_elig_opt_flex_06               ben_opt_f.opt_attribute6%TYPE;
g_elig_opt_flex_07               ben_opt_f.opt_attribute7%TYPE;
g_elig_opt_flex_08               ben_opt_f.opt_attribute8%TYPE;
g_elig_opt_flex_09               ben_opt_f.opt_attribute9%TYPE;
g_elig_opt_flex_10               ben_opt_f.opt_attribute10%TYPE;
g_elig_lfevt_name                ben_ler_f.name%TYPE;
g_elig_ler_id                    ben_ler_f.ler_id%TYPE;
g_elig_lfevt_status              ben_per_in_ler.per_in_ler_stat_cd%TYPE;
g_elig_lfevt_note_dt             ben_per_in_ler.ntfn_dt%TYPE;
g_elig_lfevt_ocrd_dt             ben_per_in_ler.lf_evt_ocrd_dt%TYPE;
g_elig_pl_fd_name                ben_pl_f.short_name%Type ;
g_elig_pl_fd_code                ben_pl_f.short_code%Type ;
g_elig_pgm_fd_name               ben_pgm_f.short_name%Type ;
g_elig_pgm_fd_code               ben_pgm_f.short_code%Type ;
g_elig_opt_fd_name               ben_opt_f.short_name%Type ;
g_elig_opt_fd_code               ben_opt_f.short_code%Type ;
g_elig_pl_typ_fd_name            ben_pl_typ_f.short_name%Type ;
g_elig_pl_typ_fd_code            ben_pl_typ_f.short_code%Type ;
g_elig_opt_pl_fd_name            ben_oipl_f.short_name%Type ;
g_elig_opt_pl_fd_code            ben_oipl_f.short_code%Type ;
g_elig_pl_pgm_fd_name            ben_plip_f.short_name%Type ;
g_elig_pl_pgm_fd_code            ben_plip_f.short_code%Type ;
g_elig_pl_typ_pgm_fd_name        ben_pl_typ_f.short_name%Type ;
g_elig_pl_typ_pgm_fd_code        ben_pl_typ_f.short_code%Type ;

--cwb 2832419
g_elig_ee_cwb_dst_bdgt               ben_prtt_rt_val.rt_val%TYPE;
g_elig_ee_cwb_misc_rate_1            ben_prtt_rt_val.rt_val%TYPE;
g_elig_ee_cwb_misc_rate_2            ben_prtt_rt_val.rt_val%TYPE;
g_elig_ee_cwb_misc_rate_3            ben_prtt_rt_val.rt_val%TYPE;
g_elig_ee_cwb_elig_salary            ben_prtt_rt_val.rt_val%TYPE;
g_elig_ee_cwb_grant_price            ben_prtt_rt_val.rt_val%TYPE;
g_elig_ee_cwb_other_salary           ben_prtt_rt_val.rt_val%TYPE;
g_elig_ee_cwb_reserve                ben_prtt_rt_val.rt_val%TYPE;
g_elig_ee_cwb_recomond_amt           ben_prtt_rt_val.rt_val%TYPE;
g_elig_ee_cwb_stated_salary          ben_prtt_rt_val.rt_val%TYPE;
g_elig_ee_cwb_tot_compensation       ben_prtt_rt_val.rt_val%TYPE;
g_elig_ee_cwb_worksheet_bdgt         ben_prtt_rt_val.rt_val%TYPE;
g_elig_ee_cwb_worksheet_amt          ben_prtt_rt_val.rt_val%TYPE;

-- Cobra letter requirment
g_elig_cobra_payment_dys        ben_pl_f.COBRA_PYMT_DUE_DY_NUM%type ;
g_elig_cobra_admin_name         ben_popl_org_role_f.name%type ;
g_elig_cobra_admin_org_name     hr_all_organization_units.name%type ;
g_elig_cobra_admin_addr1        hr_locations.address_line_1%type ;
g_elig_cobra_admin_addr2        hr_locations.address_line_2%type ;
g_elig_cobra_admin_addr3        hr_locations.address_line_3%type ;
g_elig_cobra_admin_city         hr_locations.town_or_city%type ;
g_elig_cobra_admin_state        hr_locations.region_2%type ;
g_elig_cobra_admin_country      hr_locations.country%type ;
g_elig_cobra_admin_zip          hr_locations.postal_code%type ;
g_elig_cobra_admin_phone        hr_locations.telephone_number_1%type ;

--
-- beneficiary
--
g_bnf_ssn                        per_all_people_f.national_identifier%TYPE;
g_bnf_lst_nm                     per_all_people_f.last_name%TYPE;
g_bnf_fst_nm                     per_all_people_f.first_name%TYPE;
g_bnf_mid_nm                     per_all_people_f.middle_names%TYPE;
g_bnf_fl_nm                      per_all_people_f.full_name%TYPE;
g_bnf_suffix                     per_all_people_f.suffix%TYPE;
g_bnf_prefix                     per_all_people_f.pre_name_adjunct%TYPE;
g_bnf_title                      per_all_people_f.title%TYPE;
g_bnf_prv_lst_nm                 per_all_people_f.previous_last_name%TYPE;
g_bnf_pre_nm_adjunct             per_all_people_f.pre_name_adjunct%TYPE;
g_bnf_email_address              per_all_people_f.email_address%TYPE;
g_bnf_known_as                   per_all_people_f.known_as%TYPE;
g_bnf_nationality                per_all_people_f.nationality%TYPE;
g_bnf_tobacco_usage              per_all_people_f.uses_tobacco_flag%TYPE;
g_bnf_language                   per_all_people_f.correspondence_language%TYPE;
g_bnf_prim_address1              per_addresses.address_line1%TYPE;
g_bnf_prim_address2              per_addresses.address_line2%TYPE;
g_bnf_prim_address3              per_addresses.address_line3%TYPE;
g_bnf_prim_city                  per_addresses.town_or_city%TYPE;
g_bnf_prim_state                 per_addresses.region_2%TYPE;
g_bnf_prim_postal_code           per_addresses.postal_code%TYPE;
g_bnf_prim_country               per_addresses.country%TYPE;
g_bnf_prim_effect_date           per_addresses.date_from%TYPE;
g_bnf_prim_region                per_addresses.region_3%TYPE;
g_bnf_gender                     per_all_people_f.sex%TYPE;
g_bnf_date_of_birth              per_all_people_f.date_of_birth%TYPE;
g_bnf_marital_status             per_all_people_f.marital_status%TYPE;
g_bnf_disabled_flag              per_all_people_f.registered_disabled_flag%TYPE;
g_bnf_student_status             per_all_people_f.student_status%TYPE;
g_bnf_date_of_death              per_all_people_f.date_of_death%TYPE;
g_bnf_prmy_cont                  ben_pl_bnf_f.prmry_cntngnt_cd%TYPE;
g_bnf_pct_dsgd                   ben_pl_bnf_f.pct_dsgd_num%TYPE;
g_bnf_amt_dsgd                   ben_pl_bnf_f.amt_dsgd_val%TYPE;
g_bnf_amt_uom                    ben_pl_bnf_f.amt_dsgd_uom%TYPE;
g_bnf_rlshp                      per_contact_relationships.contact_type%TYPE;
g_bnf_contact_seq_num            per_contact_relationships.sequence_number%TYPE;
g_bnf_shared_resd_flag           per_contact_relationships.rltd_per_rsds_w_dsgntr_flag%TYPE;
g_bnf_home_phone                 per_phones.phone_number%TYPE;
g_bnf_fax                        per_phones.phone_number%TYPE;
g_bnf_mobile                     per_phones.phone_number%TYPE;
g_bnf_work_phone                 per_phones.phone_number%TYPE;
g_bnf_pl_bnf_id                  ben_pl_bnf_f.pl_bnf_id%TYPE;
--
--
-- Action Items
--
g_actn_type_id			ben_actn_typ.actn_typ_id%TYPE;
g_actn_name			      ben_actn_typ.name%TYPE;
g_actn_description		ben_actn_typ.description%TYPE;
g_actn_type	 		      ben_actn_typ.type_cd%TYPE;
g_actn_due_date	 		ben_prtt_enrt_actn_f.due_dt%TYPE;
g_actn_required_flag 		ben_prtt_enrt_actn_f.rqd_flag%TYPE;
g_actn_cmpltd_date		ben_prtt_enrt_actn_f.cmpltd_dt%TYPE;
g_actn_prtt_enrt_actn_id        ben_prtt_enrt_actn_f.prtt_enrt_actn_id%TYPE;
--
-- Run Result
--
g_runrslt_element_name           pay_element_types_f.element_name%TYPE;
g_runrslt_element_id             pay_element_types_f.element_type_id%TYPE;
g_runrslt_reporting_name         pay_element_types_f.reporting_name%TYPE;
g_runrslt_element_description    pay_element_types_f.description%TYPE;
g_runrslt_classification  	 pay_element_classifications.classification_name%TYPE;
g_runrslt_classification_id  	 pay_element_classifications.classification_id%TYPE;
g_runrslt_processing_type        pay_element_types_f.processing_type%TYPE;
g_runrslt_input_currency         pay_element_types_f.input_currency_code%TYPE;
g_runrslt_output_currency        pay_element_types_f.output_currency_code%TYPE;
g_runrslt_skip_rule              ff_formulas_f.formula_name%TYPE;
g_runrslt_skip_rule_id           ff_formulas_f.formula_id%TYPE;
g_runrslt_input_value_name       pay_input_values_f.name%TYPE;
g_runrslt_input_value_id         pay_input_values_f.input_value_id%TYPE;
g_runrslt_input_value_units      pay_input_values_f.uom%TYPE;
g_runrslt_input_value_sequence   pay_input_values_f.display_sequence%TYPE;
g_runrslt_value		   	 pay_run_result_values.result_value%TYPE;
g_runrslt_identifier	   	 pay_run_results.run_result_id%TYPE;
g_runrslt_jurisdiction_code   	 pay_run_results.jurisdiction_code%TYPE;
g_runrslt_status	   	 pay_run_results.status%TYPE;
g_runrslt_source_type	   	 pay_run_results.source_type%TYPE;
g_runrslt_entry_type	   	 pay_run_results.entry_type%TYPE;
g_runrslt_last_pay_date          pay_payroll_actions.effective_date%type ;
--
--
g_prmy_sort_val                  varchar2(250);
g_scnd_sort_val                  varchar2(250);
--
-- for updating sent_dt in ben_per_cm_prvdd_f
g_per_cm_prvdd_id              number(15);
g_per_cm_object_version_number number(15);
g_cm_flag                      varchar2(30);
g_upd_cm_sent_dt_flag          varchar2(30);
--
-- Flex fields
--
g_alc_flex_01			hr_locations.attribute1%TYPE;
g_alc_flex_02			hr_locations.attribute2%TYPE;
g_alc_flex_03			hr_locations.attribute3%TYPE;
g_alc_flex_04			hr_locations.attribute4%TYPE;
g_alc_flex_05			hr_locations.attribute5%TYPE;
g_alc_flex_06			hr_locations.attribute6%TYPE;
g_alc_flex_07			hr_locations.attribute7%TYPE;
g_alc_flex_08			hr_locations.attribute8%TYPE;
g_alc_flex_09			hr_locations.attribute9%TYPE;
g_alc_flex_10			hr_locations.attribute10%TYPE;
--
g_prl_flex_01			pay_all_payrolls_f.attribute1%TYPE;
g_prl_flex_02			pay_all_payrolls_f.attribute2%TYPE;
g_prl_flex_03			pay_all_payrolls_f.attribute3%TYPE;
g_prl_flex_04			pay_all_payrolls_f.attribute4%TYPE;
g_prl_flex_05			pay_all_payrolls_f.attribute5%TYPE;
g_prl_flex_06			pay_all_payrolls_f.attribute6%TYPE;
g_prl_flex_07			pay_all_payrolls_f.attribute7%TYPE;
g_prl_flex_08			pay_all_payrolls_f.attribute8%TYPE;
g_prl_flex_09			pay_all_payrolls_f.attribute9%TYPE;
g_prl_flex_10			pay_all_payrolls_f.attribute10%TYPE;
--
g_pos_flex_01			per_positions.attribute1%TYPE;
g_pos_flex_02			per_positions.attribute2%TYPE;
g_pos_flex_03			per_positions.attribute3%TYPE;
g_pos_flex_04			per_positions.attribute4%TYPE;
g_pos_flex_05			per_positions.attribute5%TYPE;
g_pos_flex_06			per_positions.attribute6%TYPE;
g_pos_flex_07			per_positions.attribute7%TYPE;
g_pos_flex_08			per_positions.attribute8%TYPE;
g_pos_flex_09			per_positions.attribute9%TYPE;
g_pos_flex_10			per_positions.attribute10%TYPE;
--
g_job_flex_01			per_jobs.attribute1%TYPE;
g_job_flex_02			per_jobs.attribute2%TYPE;
g_job_flex_03			per_jobs.attribute3%TYPE;
g_job_flex_04			per_jobs.attribute4%TYPE;
g_job_flex_05			per_jobs.attribute5%TYPE;
g_job_flex_06			per_jobs.attribute6%TYPE;
g_job_flex_07			per_jobs.attribute7%TYPE;
g_job_flex_08			per_jobs.attribute8%TYPE;
g_job_flex_09			per_jobs.attribute9%TYPE;
g_job_flex_10			per_jobs.attribute10%TYPE;
--
g_grd_flex_01			per_grades.attribute1%TYPE;
g_grd_flex_02			per_grades.attribute2%TYPE;
g_grd_flex_03			per_grades.attribute3%TYPE;
g_grd_flex_04			per_grades.attribute4%TYPE;
g_grd_flex_05			per_grades.attribute5%TYPE;
g_grd_flex_06			per_grades.attribute6%TYPE;
g_grd_flex_07			per_grades.attribute7%TYPE;
g_grd_flex_08			per_grades.attribute8%TYPE;
g_grd_flex_09			per_grades.attribute9%TYPE;
g_grd_flex_10			per_grades.attribute10%TYPE;
--
g_pbs_flex_01			per_pay_bases.attribute1%TYPE;
g_pbs_flex_02			per_pay_bases.attribute2%TYPE;
g_pbs_flex_03			per_pay_bases.attribute3%TYPE;
g_pbs_flex_04			per_pay_bases.attribute4%TYPE;
g_pbs_flex_05			per_pay_bases.attribute5%TYPE;
g_pbs_flex_06			per_pay_bases.attribute6%TYPE;
g_pbs_flex_07			per_pay_bases.attribute7%TYPE;
g_pbs_flex_08			per_pay_bases.attribute8%TYPE;
g_pbs_flex_09			per_pay_bases.attribute9%TYPE;
g_pbs_flex_10			per_pay_bases.attribute10%TYPE;
--
g_bng_flex_01			ben_benfts_grp.bng_attribute1%TYPE;
g_bng_flex_02			ben_benfts_grp.bng_attribute2%TYPE;
g_bng_flex_03			ben_benfts_grp.bng_attribute3%TYPE;
g_bng_flex_04			ben_benfts_grp.bng_attribute4%TYPE;
g_bng_flex_05			ben_benfts_grp.bng_attribute5%TYPE;
g_bng_flex_06			ben_benfts_grp.bng_attribute6%TYPE;
g_bng_flex_07			ben_benfts_grp.bng_attribute7%TYPE;
g_bng_flex_08			ben_benfts_grp.bng_attribute8%TYPE;
g_bng_flex_09			ben_benfts_grp.bng_attribute9%TYPE;
g_bng_flex_10			ben_benfts_grp.bng_attribute10%TYPE;
--
g_cbra_ler_id                   ben_ler_f.ler_id%TYPE;
g_cbra_ler_name                 ben_ler_f.name%TYPE;
g_cbra_strt_dt                  ben_cbr_quald_bnf.cbr_elig_perd_strt_dt%TYPE;
g_cbra_end_dt                   ben_cbr_quald_bnf.cbr_elig_perd_end_dt%TYPE;
g_bnft_stat_cd                  varchar2(1);
-- current School establishemnt
g_ESTABLISHMENT_name            PER_ESTABLISHMENTS.name%TYPE ;
--
g_detail_extracted              boolean:=false;
--cwb variables
 --- intialize cwb globals
 g_cwb_group_plan_name                  ben_pl_f.name%type ;
 g_cwb_per_group_per_in_ler_id          ben_cwb_person_info.group_per_in_ler_id%type  ;
 g_cwb_per_group_pl_id                  ben_per_in_ler.group_pl_id%type  ;
 g_CWB_Person_FULL_NAME	         	ben_cwb_person_info.FULL_NAME%type ;
 g_CWB_Person_Custom_Name		ben_cwb_person_info.Custom_Name%type ;
 g_CWB_Person_Brief_Name		ben_cwb_person_info.Brief_Name%type ;
 g_CWB_Life_Event_Name          	ben_ler_f.name%type  ;
 g_CWB_Life_Event_status          	ben_ler_f.name%type  ;
 g_CWB_Life_Event_Occurred_Date		ben_per_in_ler.LF_EVT_OCRD_DT%type ;
 g_CWB_Person_EMAIL_DDRESS		ben_cwb_person_info.EMAIL_ADDRESS%type ;
 g_CWB_Person_EMPLOYEE_NUMBER		ben_cwb_person_info.EMPLOYEE_NUMBER%Type ;
 g_CWB_Person_BASE_SALARY		ben_cwb_person_info.BASE_SALARY%type ;
 g_CWB_Person_BG_Name	                per_business_groups.name%type ;
 g_CWB_Person_CHANGE_REASON		ben_cwb_person_info.CHANGE_REASON%type ;
 g_CWB_PEOPLE_GROUP_NAME		ben_cwb_person_info.PEOPLE_GROUP_name%type  ;
 g_CWB_PEOPLE_GROUP_SEGMENT1		ben_cwb_person_info.PEOPLE_GROUP_SEGMENT1%type;
 g_CWB_PEOPLE_GROUP_SEGMENT10		ben_cwb_person_info.PEOPLE_GROUP_SEGMENT1%type;
 g_CWB_PEOPLE_GROUP_SEGMENT11		ben_cwb_person_info.PEOPLE_GROUP_SEGMENT1%type;
 g_CWB_PEOPLE_GROUP_SEGMENT2		ben_cwb_person_info.PEOPLE_GROUP_SEGMENT1%type;
 g_CWB_PEOPLE_GROUP_SEGMENT3		ben_cwb_person_info.PEOPLE_GROUP_SEGMENT1%type;
 g_CWB_PEOPLE_GROUP_SEGMENT4		ben_cwb_person_info.PEOPLE_GROUP_SEGMENT1%type;
 g_CWB_PEOPLE_GROUP_SEGMENT5		ben_cwb_person_info.PEOPLE_GROUP_SEGMENT1%type;
 g_CWB_PEOPLE_GROUP_SEGMENT6		ben_cwb_person_info.PEOPLE_GROUP_SEGMENT1%type;
 g_CWB_PEOPLE_GROUP_SEGMENT7		ben_cwb_person_info.PEOPLE_GROUP_SEGMENT1%type;
 g_CWB_PEOPLE_GROUP_SEGMENT8		ben_cwb_person_info.PEOPLE_GROUP_SEGMENT1%type;
 g_CWB_PEOPLE_GROUP_SEGMENT9		ben_cwb_person_info.PEOPLE_GROUP_SEGMENT1%type;
 g_CWB_Persom_PERF_RATING_TYPE       	hr_lookups.meaning%type;
 g_CWB_Person_PERF_RATING       	ben_cwb_person_info.PERFORMANCE_RATING%type ;
 g_CWB_Person_BASE_SALARY_FREQ   	ben_cwb_person_info.BASE_SALARY_FREQUENCY%type;
 g_CWB_Person_EMPloyee_CATEGORY 	hr_lookups.meaning%type;
 g_CWB_Person_POST_PROCESS_Stat 	ben_cwb_person_info.POST_PROCESS_Stat_cd%type ;
 g_CWB_Person_START_DATE		ben_cwb_person_info.START_DATE%type ;
 g_CWB_Person_ADJUSTED_SVC_DATE 	ben_cwb_person_info.ADJUSTED_SVC_DATE%type  ;
 g_CWB_Person_Assg_ATTRIBUTE1 	        ben_cwb_person_info.Ass_ATTRIBUTE1%type ;
 g_CWB_Person_Assg_ATTRIBUTE10  	ben_cwb_person_info.Ass_ATTRIBUTE1%type ;
 g_CWB_Person_Assg_ATTRIBUTE11  	ben_cwb_person_info.Ass_ATTRIBUTE1%type ;
 g_CWB_Person_Assg_ATTRIBUTE12  	ben_cwb_person_info.Ass_ATTRIBUTE1%type ;
 g_CWB_Person_Assg_ATTRIBUTE13  	ben_cwb_person_info.Ass_ATTRIBUTE1%type ;
 g_CWB_Person_Assg_ATTRIBUTE14  	ben_cwb_person_info.Ass_ATTRIBUTE1%type ;
 g_CWB_Person_Assg_ATTRIBUTE15          ben_cwb_person_info.Ass_ATTRIBUTE1%type ;
 g_CWB_Person_Assg_ATTRIBUTE16  	ben_cwb_person_info.Ass_ATTRIBUTE1%type ;
 g_CWB_Person_Assg_ATTRIBUTE17  	ben_cwb_person_info.Ass_ATTRIBUTE1%type ;
 g_CWB_Person_Assg_ATTRIBUTE18  	ben_cwb_person_info.Ass_ATTRIBUTE1%type ;
 g_CWB_Person_Assg_ATTRIBUTE19  	ben_cwb_person_info.Ass_ATTRIBUTE1%type ;
 g_CWB_Person_Assg_ATTRIBUTE2	        ben_cwb_person_info.Ass_ATTRIBUTE1%type ;
 g_CWB_Person_Assg_ATTRIBUTE20	        ben_cwb_person_info.Ass_ATTRIBUTE1%type ;
 g_CWB_Person_Assg_ATTRIBUTE21	        ben_cwb_person_info.Ass_ATTRIBUTE1%type ;
 g_CWB_Person_Assg_ATTRIBUTE22	        ben_cwb_person_info.Ass_ATTRIBUTE1%type ;
 g_CWB_Person_Assg_ATTRIBUTE23	        ben_cwb_person_info.Ass_ATTRIBUTE1%type ;
 g_CWB_Person_Assg_ATTRIBUTE24	        ben_cwb_person_info.Ass_ATTRIBUTE1%type ;
 g_CWB_Person_Assg_ATTRIBUTE25	        ben_cwb_person_info.Ass_ATTRIBUTE1%type ;
 g_CWB_Person_Assg_ATTRIBUTE26	        ben_cwb_person_info.Ass_ATTRIBUTE1%type ;
 g_CWB_Person_Assg_ATTRIBUTE28	        ben_cwb_person_info.Ass_ATTRIBUTE1%type ;
 g_CWB_Person_Assg_ATTRIBUTE29	        ben_cwb_person_info.Ass_ATTRIBUTE1%type ;
 g_CWB_Person_Assg_ATTRIBUTE3	        ben_cwb_person_info.Ass_ATTRIBUTE1%type ;
 g_CWB_Person_Assg_ATTRIBUTE30	        ben_cwb_person_info.Ass_ATTRIBUTE1%type ;
 g_CWB_Person_Assg_ATTRIBUTE4	        ben_cwb_person_info.Ass_ATTRIBUTE1%type ;
 g_CWB_Person_Assg_ATTRIBUTE5	        ben_cwb_person_info.Ass_ATTRIBUTE1%type ;
 g_CWB_Person_Assg_ATTRIBUTE6	        ben_cwb_person_info.Ass_ATTRIBUTE1%type ;
 g_CWB_Person_Assg_ATTRIBUTE7	        ben_cwb_person_info.Ass_ATTRIBUTE1%type ;
 g_CWB_Person_Assg_ATTRIBUTE8	        ben_cwb_person_info.Ass_ATTRIBUTE1%type ;
 g_CWB_Person_Assg_ATTRIBUTE9	        ben_cwb_person_info.Ass_ATTRIBUTE1%type ;
 g_CWB_Person_Assg_ATTRIBUTE27	        ben_cwb_person_info.Ass_ATTRIBUTE1%type ;
 g_CWB_Person_Info_ATTRIBUTE1	        ben_cwb_person_info.CPI_ATTRIBUTE1%type ;
 g_CWB_Person_Info_ATTRIBUTE10	        ben_cwb_person_info.CPI_ATTRIBUTE1%type ;
 g_CWB_Person_Info_ATTRIBUTE2	        ben_cwb_person_info.CPI_ATTRIBUTE1%type ;
 g_CWB_Person_Info_ATTRIBUTE3	        ben_cwb_person_info.CPI_ATTRIBUTE1%type ;
 g_CWB_Person_Info_ATTRIBUTE4	        ben_cwb_person_info.CPI_ATTRIBUTE1%type ;
 g_CWB_Person_Info_ATTRIBUTE5	        ben_cwb_person_info.CPI_ATTRIBUTE1%type ;
 g_CWB_Person_Info_ATTRIBUTE6	        ben_cwb_person_info.CPI_ATTRIBUTE1%type ;
 g_CWB_Person_Info_ATTRIBUTE7	        ben_cwb_person_info.CPI_ATTRIBUTE1%type ;
 g_CWB_Person_Info_ATTRIBUTE11	        ben_cwb_person_info.CPI_ATTRIBUTE1%type ;
 g_CWB_Person_Info_ATTRIBUTE12	        ben_cwb_person_info.CPI_ATTRIBUTE1%type ;
 g_CWB_Person_Info_ATTRIBUTE13	        ben_cwb_person_info.CPI_ATTRIBUTE1%type ;
 g_CWB_Person_Info_ATTRIBUTE14	        ben_cwb_person_info.CPI_ATTRIBUTE1%type ;
 g_CWB_Person_Info_ATTRIBUTE15	        ben_cwb_person_info.CPI_ATTRIBUTE1%type ;
 g_CWB_Person_Info_ATTRIBUTE16	        ben_cwb_person_info.CPI_ATTRIBUTE1%type ;
 g_CWB_Person_Info_ATTRIBUTE17	        ben_cwb_person_info.CPI_ATTRIBUTE1%type ;
 g_CWB_Person_Info_ATTRIBUTE18	        ben_cwb_person_info.CPI_ATTRIBUTE1%type ;
 g_CWB_Person_Info_ATTRIBUTE19	        ben_cwb_person_info.CPI_ATTRIBUTE1%type ;
 g_CWB_Person_Info_ATTRIBUTE20	        ben_cwb_person_info.CPI_ATTRIBUTE1%type ;
 g_CWB_Person_Info_ATTRIBUTE21	        ben_cwb_person_info.CPI_ATTRIBUTE1%type ;
 g_CWB_Person_Info_ATTRIBUTE22	        ben_cwb_person_info.CPI_ATTRIBUTE1%type ;
 g_CWB_Person_Info_ATTRIBUTE23	        ben_cwb_person_info.CPI_ATTRIBUTE1%type ;
 g_CWB_Person_Info_ATTRIBUTE24	        ben_cwb_person_info.CPI_ATTRIBUTE1%type ;
 g_CWB_Person_Info_ATTRIBUTE25	        ben_cwb_person_info.CPI_ATTRIBUTE1%type ;
 g_CWB_Person_Info_ATTRIBUTE26	        ben_cwb_person_info.CPI_ATTRIBUTE1%type ;
 g_CWB_Person_Info_ATTRIBUTE27	        ben_cwb_person_info.CPI_ATTRIBUTE1%type ;
 g_CWB_Person_Info_ATTRIBUTE28	        ben_cwb_person_info.CPI_ATTRIBUTE1%type ;
 g_CWB_Person_Info_ATTRIBUTE29	        ben_cwb_person_info.CPI_ATTRIBUTE1%type ;
 g_CWB_Person_Info_ATTRIBUTE30	        ben_cwb_person_info.CPI_ATTRIBUTE1%type ;
 g_CWB_Person_Info_ATTRIBUTE8	        ben_cwb_person_info.CPI_ATTRIBUTE1%type ;
 g_CWB_Person_Info_ATTRIBUTE9	        ben_cwb_person_info.CPI_ATTRIBUTE1%type ;
 g_CWB_Person_CUSTOM_SEGMENT1		ben_cwb_person_info.CUSTOM_SEGMENT1%type ;
 g_CWB_Person_CUSTOM_SEGMENT10		ben_cwb_person_info.CUSTOM_SEGMENT10%type ;
 g_CWB_Person_CUSTOM_SEGMENT11		ben_cwb_person_info.CUSTOM_SEGMENT11%type ;
 g_CWB_Person_CUSTOM_SEGMENT13		ben_cwb_person_info.CUSTOM_SEGMENT13%type ;
 g_CWB_Person_CUSTOM_SEGMENT14		ben_cwb_person_info.CUSTOM_SEGMENT14%type ;
 g_CWB_Person_CUSTOM_SEGMENT2		ben_cwb_person_info.CUSTOM_SEGMENT1%type ;
 g_CWB_Person_CUSTOM_SEGMENT4		ben_cwb_person_info.CUSTOM_SEGMENT1%type ;
 g_CWB_Person_CUSTOM_SEGMENT5		ben_cwb_person_info.CUSTOM_SEGMENT1%type ;
 g_CWB_Person_CUSTOM_SEGMENT6		ben_cwb_person_info.CUSTOM_SEGMENT1%type ;
 g_CWB_Person_CUSTOM_SEGMENT7		ben_cwb_person_info.CUSTOM_SEGMENT1%type ;
 g_CWB_Person_CUSTOM_SEGMENT9		ben_cwb_person_info.CUSTOM_SEGMENT1%type ;
 g_CWB_Person_CUSTOM_SEGMENT12		ben_cwb_person_info.CUSTOM_SEGMENT12%type ;
 g_CWB_Person_CUSTOM_SEGMENT15		ben_cwb_person_info.CUSTOM_SEGMENT15%type ;
 g_CWB_Person_CUSTOM_SEGMENT8 		ben_cwb_person_info.CUSTOM_SEGMENT1%type ;
 g_CWB_Person_CUSTOM_SEGMENT3		ben_cwb_person_info.CUSTOM_SEGMENT1%type ;
 g_CWB_Person_FEEDBACK_RATING		ben_cwb_person_info.FEEDBACK_RATING%type ;
 g_CWB_Person_FREQUENCY		        ben_cwb_person_info.FREQUENCY%type ;
 g_CWB_Person_Grade_MAX_VAL       	ben_cwb_person_info.GRD_MAX_VAL%type  ;
 g_CWB_Person_Grade_MID_POINT		ben_cwb_person_info.GRD_MID_POINT%type ;
 g_CWB_Person_Grade_MIN_VAL     	ben_cwb_person_info.GRD_MIN_VAL%type ;
 g_CWB_Person_GRADE_name		per_grades.name%type ;
 g_CWB_Person_Grade_QUARTILE		hr_lookups.meaning%type ;
 g_CWB_Person_GRADE_ANN_FACTOR	        ben_cwb_person_info.GRADE_ANNULIZATION_FACTOR%type ;
 g_CWB_Person_Grade_COMPARATIO		ben_cwb_person_info.Grd_COMPARATIO%type ;
 g_CWB_Person_JOB_name			per_jobs.name%type ;
 g_CWB_Person_LEGISLATION 		ben_cwb_person_info.LEGISLATION_CODE%type ;
 g_CWB_Person_LOCATION			hr_locations.location_code%TYPE ;
 g_CWB_Person_NORMAL_HOURS		ben_cwb_person_info.NORMAL_HOURS%type ;
 g_CWB_Person_ORG_name	                per_all_organization_units.name%TYPE;
 g_CWB_Person_ORIG_START_DATE	        ben_cwb_person_info.ORIGINAL_START_DATE%type ;
 g_CWB_Person_PAY_RATE 		        varchar2(100) ;
 g_CWB_Person_PAY_ANNUL_FACTOR	        ben_cwb_person_info.PAY_ANNULIZATION_FACTOR%type ;
 g_CWB_Person_PAYROLL_NAME		pay_all_payrolls_f.payroll_name%TYPE;
 g_CWB_Person_PERF_RATING_DATE	        ben_cwb_person_info.PERFORMANCE_RATING%type ;
 g_CWB_Person_POSITION	        	per_positions.name%type ;
 g_CWB_Person_STATUS_TYPE		varchar2(250) ;
 g_CWB_Person_SUP_BRIEF_NAME	        ben_cwb_person_info.SUPERVISOR_BRIEF_NAME%type ;
 g_CWB_Person_SUP_CUSTOM_NAME	        ben_cwb_person_info.SUPERVISOR_CUSTOM_NAME%type ;
 g_CWB_Person_SUP_FULL_NAME	        ben_cwb_person_info.SUPERVISOR_FULL_NAME%type ;
 g_CWB_Person_YEARS_EMPLOYED		ben_cwb_person_info.YEARS_EMPLOYED%type     ;
 g_CWB_Person_YEARS_IN_GRADE		ben_cwb_person_info.YEARS_IN_GRADE%type ;
 g_CWB_Person_YEARS_IN_POS		ben_cwb_person_info.YEARS_IN_POSITION%type ;
 g_CWB_Person_YEARS_IN_JOB		ben_cwb_person_info.YEARS_IN_JOB%type ;
 g_cwb_nw_chg_reason                    hr_lookups.meaning%type ;
 g_CWB_new_Job_name                     per_jobs.name%type ;
 g_CWB_new_Grade_name                   per_grades.name%type ;
 g_CWB_new_Group_name                   ben_cwb_person_info.PEOPLE_GROUP_name%type  ;
 g_CWB_new_Postion_name                 per_positions.name%Type ;
 g_CWB_new_Perf_rating                  hr_lookups.meaning%type ;
--- CWB person Groups
 g_CWB_Budget_PL_ID                     ben_cwb_person_groups.GROUP_PL_ID%type    ;
 g_CWB_Budget_Access                    ben_cwb_person_groups.ACCESS_CD%type  ;
 g_CWB_Budget_Approval                  ben_cwb_person_groups.APPROVAL_CD%type  ;
 g_CWB_Budget_Approval_Date             ben_cwb_person_groups.APPROVAL_DATE%type  ;
 g_CWB_Budget_Dist_Budget_Value         ben_cwb_person_groups.DIST_BDGT_VAL%type  ;
 g_CWB_Budget_Due_Date                  ben_cwb_person_groups.DUE_DT%type  ;
 g_CWB_Budget_Group_Option_Name         ben_opt_f.name%type  ;
 g_CWB_Budget_Group_Plan_Name           ben_pl_f.name%type  ;
 g_CWB_Budget_Last_Updt_By              ben_cwb_person_groups.LAST_UPDATED_BY%type  ;
 g_CWB_Budget_Last_Updt_dt              ben_cwb_person_groups.LAST_UPDATE_DATE%type  ;
 g_CWB_Budget_Population                ben_cwb_person_groups.BDGT_POP_CD%type  ;
 g_CWB_Budget_Resv_Max_Value            ben_cwb_person_groups.RSRV_MX_VAL%type  ;
 g_CWB_Budget_Resv_Min_Value            ben_cwb_person_groups.RSRV_MN_VAL%type  ;
 g_CWB_Budget_Resv_Value                ben_cwb_person_groups.RSRV_VAL%type  ;
 g_CWB_Budget_Resv_Val_Updt_By          ben_cwb_person_groups.RSRV_VAL_LAST_UPD_BY%type  ;
 g_CWB_Budget_Resv_Val_Updt_dt          ben_cwb_person_groups.RSRV_VAL_LAST_UPD_DATE%type  ;
 g_CWB_Budget_Submit_date               ben_cwb_person_groups.SUBMIT_DATE%type  ;
 g_CWB_Budget_Submit_Name               ben_cwb_person_groups.SUBMIT_CD%type  ;
 g_CWB_Budget_WS_Budget_Value           ben_cwb_person_groups.WS_BDGT_VAL%type  ;
 g_CWB_Dist_Budget_Default_Val          ben_cwb_person_groups.DFLT_DIST_BDGT_VAL%type  ;
 g_CWB_Dist_Budget_Issue_date           ben_cwb_person_groups.DIST_BDGT_ISS_DATE%type  ;
 g_CWB_Dist_Budget_Issue_Value          ben_cwb_person_groups.DIST_BDGT_ISS_VAL%type  ;
 g_CWB_Dist_Budget_Max_Value            ben_cwb_person_groups.DIST_BDGT_MX_VAL%type  ;
 g_CWB_Dist_Budget_Min_Value            ben_cwb_person_groups.DIST_BDGT_MN_VAL%type  ;
 g_CWB_Dist_Budget_Val_Updt_By          ben_cwb_person_groups.DIST_BDGT_VAL_LAST_UPD_BY%type  ;
 g_CWB_Dist_Budget_Val_Updt_dt          ben_cwb_person_groups.DIST_BDGT_VAL_LAST_UPD_DATE%type  ;
 g_CWB_WS_Budget_Issue_Date             ben_cwb_person_groups.WS_BDGT_ISS_DATE%type  ;
 g_CWB_WS_Budget_Issue_Value            ben_cwb_person_groups.WS_BDGT_ISS_VAL%type  ;
 g_CWB_WS_Budget_Max_Value              ben_cwb_person_groups.WS_BDGT_MN_VAL%type  ;
 g_CWB_WS_Budget_Min_Value              ben_cwb_person_groups.WS_BDGT_MX_VAL%type  ;
 g_CWB_WS_Budget_Val_Updt_By            ben_cwb_person_groups.LAST_UPDATED_BY%type  ;
 g_CWB_WS_Budget_Val_Updt_dt            ben_cwb_person_groups.LAST_UPDATE_DATE%type  ;
 g_cwb_LE_Dt                            date  ;
 g_cwb_effective_date                   date  ;
 --- cwb person rates

 g_CWB_Awrd_Elig_Flag                   ben_Cwb_person_rates.ELIG_FLAG%Type  ;
 g_CWB_Awrd_Elig_Salary_Value           ben_Cwb_person_rates.ELIG_SAL_VAL%Type  ;
 g_CWB_Awrd_Group_Option_Name           ben_opt_f.name%Type        ;
 g_CWB_Awrd_Group_Plan_Name             ben_pl_f.name%Type           ;
 g_CWB_Awrd_Plan_Name                   ben_pl_f.name%Type          ;
 g_CWB_Awrd_Option_Name                 ben_opt_f.name%Type        ;
 g_CWB_Awrd_Misc_Value1                 ben_Cwb_person_rates.MISC1_VAL%Type   ;
 g_CWB_Awrd_Misc_Value2                 ben_Cwb_person_rates.MISC2_VAL%Type    ;
 g_CWB_Awrd_Misc_Value3                 ben_Cwb_person_rates.MISC3_VAL%Type    ;
 g_CWB_Awrd_Other_Comp_Value            ben_Cwb_person_rates.OTH_COMP_VAL%Type   ;
 g_CWB_Awrd_Recorded_Value              ben_Cwb_person_rates.REC_VAL%Type     ;
 g_CWB_Awrd_Stated_Salary_Value         ben_Cwb_person_rates.STAT_SAL_VAL%Type   ;
 g_CWB_Awrd_Total_Comp_Value            ben_Cwb_person_rates.TOT_COMP_VAL%Type     ;
 g_CWB_Awrd_WS_Maximum_Value            ben_Cwb_person_rates.WS_MN_VAL%Type   ;
 g_CWB_Awrd_WS_Minimum_Value            ben_Cwb_person_rates.WS_MX_VAL%Type    ;
 g_CWB_Awrd_WS_Value                    ben_Cwb_person_rates.WS_VAL%Type     ;

--- subheader
g_group_elmt_value1       ben_ext_rslt_dtl.group_val_01%type  ;
g_group_elmt_value2       ben_ext_rslt_dtl.group_val_01%type  ;

--- payroll chananges only adv condition exist
g_pay_adv_eff_from_dt   date ;
g_pay_adv_eff_to_dt     date ;
g_pay_adv_act_from_dt   date ;
g_pay_adv_act_to_dt     date ;
g_pay_adv_date_mode     varchar2(1) ;

--- payroll
TYPE pay_evt_group_rec IS RECORD
      (dated_table_id      number,
       column_name         varchar2(150),
       event_group_id      number
      );

TYPE t_pay_evt_group IS TABLE OF pay_evt_group_rec INDEX BY Binary_Integer;
g_pay_evt_group_tab  t_pay_evt_group;

TYPE t_detailed_output_tab_rec IS RECORD
(
    dated_table_id       pay_dated_tables.dated_table_id%TYPE     ,
    datetracked_event    pay_datetracked_events.datetracked_event_id%TYPE  ,
    update_type          pay_datetracked_events.update_type%TYPE  ,
    surrogate_key        pay_process_events.surrogate_key%type    ,
    column_name          pay_event_updates.column_name%TYPE       ,
    effective_date       date,
    old_value            varchar2(2000),
    new_value            varchar2(2000),
    change_values        varchar2(2000),
    proration_type       varchar2(10),
    change_mode          pay_process_events.change_type%type,--'DATE_PROCESSED' etc
    event_group_id       number,
    next_evt_start_date  date ,
    actual_date          date
);


TYPE t_detailed_output_table IS TABLE OF t_detailed_output_tab_rec
                                                    INDEX BY BINARY_INTEGER ;
g_pay_proc_evt_tab      t_detailed_output_table ;
---
Procedure process_ext_person(
                             p_person_id          in number,
                             p_ext_dfn_id         in number,
                             p_ext_rslt_id        in number,
                             p_ext_file_id        in number,
                             p_ext_crit_prfl_id   in number,
                             p_data_typ_cd        in varchar2,
                             p_ext_typ_cd         in varchar2,
                             p_effective_date     in date, -- passed in from conc mgr
                             p_business_group_id  in number,
                             p_penserv_mode       in varchar2 -- vkodedal - changes for penserver - 30-apr-2008
                            );
--
--
Procedure process_ext_levels(
                             p_person_id         in number,
                             p_ext_rslt_id       in number,
                             p_ext_file_id       in number,
                             p_data_typ_cd       in varchar2,
                             p_ext_typ_cd        in varchar2,
                             p_business_group_id in number,
                             p_effective_date    in date
                            );
--
PROCEDURE init_detail_globals;
--
Procedure write_error(p_err_num     in number,
                      p_err_name    in varchar2,
                      p_typ_cd      in varchar2,
                      p_request_id  in number,
                      p_ext_rslt_id in number
                     );


--this is externalized for sub header

procedure get_pos_info (p_position_id  in number,
                        p_effective_date in date ) ;

procedure get_job_info (p_job_id  in number,
                        p_effective_date in date ) ;

procedure get_loc_info (p_location_id  in number,
                        p_effective_date in date ) ;

procedure get_payroll_info (p_payroll_id  in number,
                            p_effective_date in date ) ;
procedure get_grade_info (p_grade_id  in number,
                        p_effective_date in date ) ;


--
END; -- Package spec

/
