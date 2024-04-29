--------------------------------------------------------
--  DDL for Package BEN_EXT_CHLG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EXT_CHLG" AUTHID CURRENT_USER as
/* $Header: benxchlg.pkh 120.3.12010000.3 2009/11/24 06:54:44 vkodedal ship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA		       |
|			        All rights reserved.			       |
+==============================================================================+
--
Name
        Benefit Extract Change Log
Purpose
        This package is used to log changes for benefit extract
History
        Date             Who        Version    What?
        10/28/98         Pdas       115.0      Created.
        12/14/98         Pdas       115.1      Modified g_per_rec_type.
        12/21/98         Pdas       115.2      Modified g_per_rec_type.
        12/29/98         Pdas       115.3      Modified g_per_rec_type.
        09 Mar 99        G Perry    115.4      IS to AS.
        23 Mar 99        thayden    115.5      Added procedure log_benefit_chg.
        12 May 99        isen       115.6      Added new change events
        16 Jun 99        isen       115.7      Added new change events
        24 Jun 99        isen       115.8      Added new change events
        20 Jul 99        isen       115.9      Added log_abs_chg for absence change events
        09 Aug 99        isen       115.10     Added new and old values
        29 Sep 99        isen       115.11     Added new change events
        10 Oct 99        thayden    115.12     Fixed application bug. Changed pos.
        26 Jan 99        thayden    115.13     Added log_dependent_chg.
        27 Jan 99        thayden    115.14     Added globals, pcp
        30 Jan 99        thayden    115.15     Added element entries.
        02 May 00        shas       115.16     Added g_cont_type and log_con_chg
        12 Dec 01        Tmathers   115.17     dos2unix for 2128462.
        23 May 02        tjesumic   115.18     per_infomration1 to 30 ,grade_id
                                               correspondence_language,uses_tobacco_flag
                                               added fro ansi
        24 may 02        tjesumic   115.19     set veryfy off added
        30 may 02        tjesumic   115.20     log_per_pay procedured added for base salary change
                                               log_school_chg procedure added
                                               log_prem_mo_chg proecude added
        13 aug 02        glingapp   115.21     Added column normal_hours to g_asg_rec_type
                                               and date_to to g_phn_rec_type
        10-Jan-04        tjesumic   115.22     employee nuber added
        26-Jan-04        vjhanak    115.24     Added primary flag to the asg record
        25-Mar-05        tjesumic   115.25     Added position id in asg
        30-Aug-05        tjesumic   115.26      log_per_chg overload procedure created, that will be called from SSHR
                                              api
        14-Oct-05        vjhanak    115.27     Added soft_coding_keyflex_id to the asg record
        14-Nov-06        tjesumic   115.28    per_pay_proposal trigger moved to api (pepyprhi.pkb 115.60)
                                              the global record changed to have all the column of the table
                                              for future requirements.
                                              Rqd: pepyprhi.pkb,115.60 benxchglg.pkb 115.61,benxbstg.sql 115.3
        08-Jul-08        pvelugul   115.29    Modified for 6517369
        24-Nov-09        vkodedal   115.30    Overloaded log_asg_chg, called from core HR bug#9092938

*/
--
  g_package          varchar2(80) := 'ben_ext_chlg';
  g_prev_upd_adr_person_id           per_addresses.person_id%type;
  g_prev_upd_adr_primary_flag        per_addresses.primary_flag%type;
  g_prev_upd_adr_to_date             per_addresses.date_to%type;
  g_prev_upd_adr_address_line1       per_addresses.address_line1%type;
  g_prev_upd_adr_address_line2       per_addresses.address_line2%type;
  g_prev_upd_adr_address_line3       per_addresses.address_line3%type;
  g_prev_upd_adr_country             per_addresses.country%type;
  g_prev_upd_adr_postal_code         per_addresses.postal_code%type;
  g_prev_upd_adr_region_1            per_addresses.region_1%type;
  g_prev_upd_adr_region_2            per_addresses.region_2%type;
  g_prev_upd_adr_region_3            per_addresses.region_3%type;
  g_prev_upd_adr_town_or_city        per_addresses.town_or_city%type;
  g_prev_upd_adr_address_id          per_addresses.address_id%type;
 -- g_prev_upd_adr_last_update_login
--
  Type g_per_rec_type is RECORD
  (national_identifier      per_all_people_f.national_identifier%type
  ,full_name                per_all_people_f.full_name%type
  ,last_name                per_all_people_f.last_name%type
  ,first_name               per_all_people_f.first_name%type
  ,middle_names             per_all_people_f.middle_names%type
  ,title                    per_all_people_f.title%type
  ,pre_name_adjunct         per_all_people_f.pre_name_adjunct%type
  ,suffix                   per_all_people_f.suffix%type
  ,known_as                 per_all_people_f.known_as%type
  ,previous_last_name       per_all_people_f.previous_last_name%type
  ,date_of_birth            per_all_people_f.date_of_birth%type
  ,sex                      per_all_people_f.sex%type
  ,marital_status           per_all_people_f.marital_status%type
  ,business_group_id        per_all_people_f.business_group_id%type
  ,person_id                per_all_people_f.person_id%type
  ,person_type_id           per_all_people_f.person_type_id%type
  ,registered_disabled_flag per_all_people_f.registered_disabled_flag%type
  ,benefit_group_id         per_all_people_f.benefit_group_id%type
  ,student_status           per_all_people_f.student_status%type
  ,date_of_death            per_all_people_f.date_of_death%type
  ,date_employee_data_verified per_all_people_f.date_employee_data_verified%type
  ,effective_start_date     per_all_people_f.effective_start_date%type
  ,effective_end_date       per_all_people_f.effective_end_date%type
  ,attribute1               per_all_people_f.attribute1%type
  ,attribute2               per_all_people_f.attribute2%type
  ,attribute3               per_all_people_f.attribute3%type
  ,attribute4               per_all_people_f.attribute4%type
  ,attribute5               per_all_people_f.attribute5%type
  ,attribute6               per_all_people_f.attribute6%type
  ,attribute7               per_all_people_f.attribute7%type
  ,attribute8               per_all_people_f.attribute8%type
  ,attribute9               per_all_people_f.attribute9%type
  ,attribute10              per_all_people_f.attribute10%type
  ,email_address            per_all_people_f.email_address%type
  ,employee_number          per_all_people_f.employee_number%type
  ,per_information1         per_all_people_f.per_information1%type
  ,per_information2         per_all_people_f.per_information2%type
  ,per_information3         per_all_people_f.per_information3%type
  ,per_information4         per_all_people_f.per_information4%type
  ,per_information5         per_all_people_f.per_information5%type
  ,per_information6         per_all_people_f.per_information6%type
  ,per_information7         per_all_people_f.per_information7%type
  ,per_information8         per_all_people_f.per_information8%type
  ,per_information9         per_all_people_f.per_information9%type
  ,per_information10        per_all_people_f.per_information10%type
  ,per_information11        per_all_people_f.per_information11%type
  ,per_information12        per_all_people_f.per_information12%type
  ,per_information13        per_all_people_f.per_information13%type
  ,per_information14        per_all_people_f.per_information14%type
  ,per_information15        per_all_people_f.per_information15%type
  ,per_information16        per_all_people_f.per_information16%type
  ,per_information17        per_all_people_f.per_information17%type
  ,per_information18        per_all_people_f.per_information18%type
  ,per_information19        per_all_people_f.per_information19%type
  ,per_information20        per_all_people_f.per_information20%type
  ,per_information21        per_all_people_f.per_information21%type
  ,per_information22        per_all_people_f.per_information22%type
  ,per_information23        per_all_people_f.per_information23%type
  ,per_information24        per_all_people_f.per_information24%type
  ,per_information25        per_all_people_f.per_information25%type
  ,per_information26        per_all_people_f.per_information26%type
  ,per_information27        per_all_people_f.per_information27%type
  ,per_information28        per_all_people_f.per_information28%type
  ,per_information29        per_all_people_f.per_information29%type
  ,per_information30        per_all_people_f.per_information30%type
  ,correspondence_language  per_all_people_f.correspondence_language%type
  ,uses_tobacco_flag        per_all_people_f.uses_tobacco_flag%type
  ,update_mode              varchar2(20)
  );
--
  Type g_cont_rec_type is RECORD
  (contact_relationship_id  per_contact_relationships.contact_relationship_id%type
  ,contact_type             per_contact_relationships.contact_type%type
  ,person_id                per_contact_relationships.person_id%type
  ,contact_person_id        per_contact_relationships.contact_person_id%type
  ,business_group_id        per_contact_relationships.business_group_id%type
  ,date_start               per_contact_relationships.date_start%TYPE
  );
--
  Type g_add_rec_type is RECORD
  (address_id          per_addresses.address_id%type
  ,primary_flag        per_addresses.primary_flag%type
  ,person_id           per_addresses.person_id%type
  ,business_group_id   per_addresses.business_group_id%type
  ,address_line1       per_addresses.address_line1%type
  ,address_line2       per_addresses.address_line2%type
  ,address_line3       per_addresses.address_line3%type
  ,country             per_addresses.country%type
  ,postal_code         per_addresses.postal_code%type
  ,region_1            per_addresses.region_1%type
  ,region_2            per_addresses.region_2%type
  ,region_3            per_addresses.region_3%type
  ,town_or_city        per_addresses.town_or_city%type
  ,address_type        per_addresses.address_type%type
  ,date_from           per_addresses.date_from%type
  ,date_to             per_addresses.date_to%type
  );
--
  Type g_asg_rec_type is RECORD
  (assignment_id             per_all_assignments_f.assignment_id%type
  ,person_id                 per_all_assignments_f.person_id%type
  ,business_group_id         per_all_assignments_f.business_group_id%type
  ,assignment_status_type_id per_all_assignments_f.assignment_status_type_id%type
  ,hourly_salaried_code      per_all_assignments_f.hourly_salaried_code%type
  ,normal_hours	             per_all_assignments_f.normal_hours%type     --Bug 1554477
  ,location_id               per_all_assignments_f.location_id%type
  ,position_id               per_all_assignments_f.position_id%type
  ,employment_category       per_all_assignments_f.employment_category%type
  ,assignment_type           per_all_assignments_f.assignment_type%type
  ,effective_start_date      per_all_assignments_f.effective_start_date%type
  ,ass_attribute1            per_all_assignments_f.ass_attribute1%type
  ,ass_attribute2            per_all_assignments_f.ass_attribute2%type
  ,ass_attribute3            per_all_assignments_f.ass_attribute3%type
  ,ass_attribute4            per_all_assignments_f.ass_attribute4%type
  ,ass_attribute5            per_all_assignments_f.ass_attribute5%type
  ,ass_attribute6            per_all_assignments_f.ass_attribute6%type
  ,ass_attribute7            per_all_assignments_f.ass_attribute7%type
  ,ass_attribute8            per_all_assignments_f.ass_attribute8%type
  ,ass_attribute9            per_all_assignments_f.ass_attribute9%type
  ,ass_attribute10           per_all_assignments_f.ass_attribute10%type
  ,payroll_id                per_all_assignments_f.payroll_id%type
  ,grade_id                  per_all_assignments_f.grade_id%type
  --rpinjala
  ,primary_flag              per_all_assignments_f.primary_flag%TYPE
  --rpinjala
  -- vjhanak
  ,soft_coding_keyflex_id    per_all_assignments_f.soft_coding_keyflex_id%TYPE
  -- vjhanak
  ,effective_end_date        per_all_assignments_f.effective_end_date%type
  ,update_mode               varchar2(20)
  );
--
  Type g_pos_rec_type is RECORD
  (period_of_service_id      per_periods_of_service.period_of_service_id%type
  ,person_id                 per_periods_of_service.person_id%type
  ,business_group_id         per_periods_of_service.business_group_id%type
  ,date_start                per_periods_of_service.date_start%type
  ,actual_termination_date   per_periods_of_service.actual_termination_date%type
  ,leaving_reason            per_periods_of_service.leaving_reason%type
  ,last_update_date          per_periods_of_service.last_update_date%type
  ,update_mode               varchar2(20)
  );
--
  Type g_abs_rec_type is RECORD
  (absence_attendance_id      per_absence_attendances.absence_attendance_id%type
  ,business_group_id          per_absence_attendances.business_group_id%type
  ,absence_attendance_type_id per_absence_attendances.absence_attendance_type_id%type
  ,person_id                  per_absence_attendances.person_id%type
  ,abs_attendance_reason_id   per_absence_attendances.abs_attendance_reason_id%type
  ,date_start                 per_absence_attendances.date_start%type
  ,date_end                   per_absence_attendances.date_end%type
  ,date_projected_start       per_absence_attendances.date_projected_start%type
  ,update_mode                varchar2(20)
  );
--
  Type g_apl_rec_type is RECORD
  (application_id            per_applications.application_id%type
  ,person_id                 per_applications.person_id%type
  ,date_received             per_applications.date_received%type
  ,date_end                  per_applications.date_end%type
  ,termination_reason        per_applications.termination_reason%type
  ,business_group_id         per_applications.business_group_id%type
  ,update_mode               varchar2(20)
  );
--
  Type g_phn_rec_type is RECORD
  (phone_id                  per_phones.phone_id%type
  ,date_from                 per_phones.date_from%type
  ,date_to  		     per_phones.date_to%type  --Bug 1554477
  ,phone_type                per_phones.phone_type%type
  ,phone_number              per_phones.phone_number%type
  ,parent_table              per_phones.parent_table%type
  ,parent_id                 per_phones.parent_id%type
  ,update_mode               varchar2(20)
  );
--
  Type g_ptu_rec_type is RECORD
  (person_type_usage_id      per_person_type_usages_f.person_type_usage_id%type
  ,person_id                 per_person_type_usages_f.person_id%type
  ,effective_start_date      per_person_type_usages_f.effective_start_date%type
  ,person_type_id            per_person_type_usages_f.person_type_id%type
  ,update_mode               varchar2(20)
  );
---
  Type g_per_pay_rec_type is RECORD
   (PERSON_ID                       per_all_people_f.person_id%type
   ,BUSINESS_GROUP_ID               per_pay_proposals.BUSINESS_GROUP_ID%type
   ,PAY_PROPOSAL_ID                 per_pay_proposals.assignment_id%type
   ,OBJECT_VERSION_NUMBER           per_pay_proposals.OBJECT_VERSION_NUMBER%type
   ,ASSIGNMENT_ID                   per_pay_proposals.ASSIGNMENT_ID%type
   ,EVENT_ID                        per_pay_proposals.EVENT_ID%type
   ,CHANGE_DATE                     per_pay_proposals.CHANGE_DATE%type
   ,LAST_CHANGE_DATE                per_pay_proposals.LAST_CHANGE_DATE%type
   ,NEXT_PERF_REVIEW_DATE           per_pay_proposals.NEXT_PERF_REVIEW_DATE%type
   ,NEXT_SAL_REVIEW_DATE            per_pay_proposals.NEXT_SAL_REVIEW_DATE%type
   ,PERFORMANCE_RATING              per_pay_proposals.PERFORMANCE_RATING%type
   ,PROPOSAL_REASON                 per_pay_proposals.PROPOSAL_REASON%type
   ,PROPOSED_SALARY_N               per_pay_proposals.PROPOSED_SALARY_N%type
   ,REVIEW_DATE                     per_pay_proposals.REVIEW_DATE%type
   ,APPROVED                        per_pay_proposals.APPROVED%type
   ,MULTIPLE_COMPONENTS             per_pay_proposals.MULTIPLE_COMPONENTS%type
   ,FORCED_RANKING                  per_pay_proposals.FORCED_RANKING%type
   ,PERFORMANCE_REVIEW_ID           per_pay_proposals.PERFORMANCE_REVIEW_ID%type
   ,ATTRIBUTE1                      per_pay_proposals.ATTRIBUTE1%type
   ,ATTRIBUTE2                      per_pay_proposals.ATTRIBUTE1%type
   ,ATTRIBUTE3                      per_pay_proposals.ATTRIBUTE1%type
   ,ATTRIBUTE4                      per_pay_proposals.ATTRIBUTE1%type
   ,ATTRIBUTE5                      per_pay_proposals.ATTRIBUTE1%type
   ,ATTRIBUTE6                      per_pay_proposals.ATTRIBUTE1%type
   ,ATTRIBUTE7                      per_pay_proposals.ATTRIBUTE1%type
   ,ATTRIBUTE8                      per_pay_proposals.ATTRIBUTE1%type
   ,ATTRIBUTE9                      per_pay_proposals.ATTRIBUTE1%type
   ,ATTRIBUTE10                     per_pay_proposals.ATTRIBUTE1%type
   ,ATTRIBUTE11                     per_pay_proposals.ATTRIBUTE1%type
   ,ATTRIBUTE12                     per_pay_proposals.ATTRIBUTE1%type
   ,ATTRIBUTE13                     per_pay_proposals.ATTRIBUTE1%type
   ,ATTRIBUTE14                     per_pay_proposals.ATTRIBUTE1%type
   ,ATTRIBUTE15                     per_pay_proposals.ATTRIBUTE1%type
   ,ATTRIBUTE16                     per_pay_proposals.ATTRIBUTE1%type
   ,ATTRIBUTE17                     per_pay_proposals.ATTRIBUTE1%type
   ,ATTRIBUTE18                     per_pay_proposals.ATTRIBUTE1%type
   ,ATTRIBUTE19                     per_pay_proposals.ATTRIBUTE1%type
   ,ATTRIBUTE20                     per_pay_proposals.ATTRIBUTE1%type
   ,PROPOSED_SALARY                 per_pay_proposals.PROPOSED_SALARY%type
   ,date_to                         per_pay_proposals.date_to%type
   ,update_mode                     varchar2(20)
   );
--

 Type g_per_school_rec_type is RECORD
   (person_id                  per_establishment_attendances.person_id%type
   ,full_time                  per_establishment_attendances.full_time%type
   ,attended_end_date          per_establishment_attendances.attended_end_date%type
   ,establishment_id           per_establishment_attendances.establishment_id%type
   ,attended_start_date        per_establishment_attendances.attended_start_date%type
   ,business_group_id          per_establishment_attendances.business_group_id%type
   ,update_mode               varchar2(20)
  );

 Type g_prem_mo_rec_type is  RECORD
  (prtt_prem_id               ben_prtt_prem_by_mo_f.prtt_prem_id%type
   ,val                       ben_prtt_prem_by_mo_f.val%type
   ,effective_start_date      ben_prtt_prem_by_mo_f.effective_start_date%type
   ,effective_end_date        ben_prtt_prem_by_mo_f.effective_end_date%type
   ,business_group_id         ben_prtt_prem_by_mo_f.business_group_id%type
   ,mo_num                    ben_prtt_prem_by_mo_f.mo_num%type
   ,yr_num                    ben_prtt_prem_by_mo_f.yr_num%type
   ,cr_val                    ben_prtt_prem_by_mo_f.cr_val%type
   ,uom                       ben_prtt_prem_by_mo_f.uom%type
   ,update_mode               varchar2(20)
   );
--
-- added for bug 6517369 to audit changes to per_disabilities_f
Type per_dis_rec_type is RECORD
  (person_id		      	per_disabilities_f.person_id%type
  ,effective_start_date		per_disabilities_f.effective_start_date%type
  ,effective_end_date		per_disabilities_f.effective_end_date%type
  ,business_group_id		per_all_people_f.business_group_id%type
  ,incident_id			per_disabilities_f.incident_id%type
  ,organization_id		per_disabilities_f.organization_id%type
  ,registration_id	     	per_disabilities_f.registration_id%type
  ,registration_date		per_disabilities_f.registration_date%type
  ,registration_exp_date	per_disabilities_f.registration_exp_date%type
  ,categoryname		       	per_disabilities_f.category%type
  ,description		    	per_disabilities_f.description%type
  ,degree	          	per_disabilities_f.degree%type
  ,quota_fte			per_disabilities_f.quota_fte%type
  ,reason		        per_disabilities_f.reason%type
  ,pre_registration_job		per_disabilities_f.pre_registration_job%type
  ,work_restriction		per_disabilities_f.work_restriction%type
  ,object_version_number	per_disabilities_f.object_version_number%type
  ,status       		per_disabilities_f.status%type
  ,attribute1			per_disabilities_f.attribute1%type
  ,attribute2			per_disabilities_f.attribute2%type
  ,attribute3			per_disabilities_f.attribute3%type
  ,attribute4			per_disabilities_f.attribute4%type
  ,attribute5			per_disabilities_f.attribute5%type
  ,attribute6			per_disabilities_f.attribute6%type
  ,attribute7			per_disabilities_f.attribute7%type
  ,attribute8			per_disabilities_f.attribute8%type
  ,attribute9			per_disabilities_f.attribute9%type
  ,attribute10			per_disabilities_f.attribute10%type
  ,dis_information1		per_disabilities_f.dis_information1%type
  ,dis_information2		per_disabilities_f.dis_information2%type
  ,dis_information3		per_disabilities_f.dis_information3%type
  ,dis_information4		per_disabilities_f.dis_information4%type
  ,dis_information5		per_disabilities_f.dis_information5%type
  ,dis_information6		per_disabilities_f.dis_information6%type
  ,dis_information7		per_disabilities_f.dis_information7%type
  ,dis_information8		per_disabilities_f.dis_information8%type
  ,dis_information9		per_disabilities_f.dis_information9%type
  ,dis_information10		per_disabilities_f.dis_information10%type
  ,update_mode			varchar2(20)
  );

--
  Type g_char_tab_type is table of varchar2(200)
  index by binary_integer;
--
  Type g_date_tab_type is table of date
  index by binary_integer;
--
  Type g_num_tab_type is table of number
  index by binary_integer;
--
  Type g_old_val is table of ben_ext_chg_evt_log.old_val1%type
  index by binary_integer;
--
  Type g_new_val is table of ben_ext_chg_evt_log.new_val1%type
  index by binary_integer;

--
  procedure log_prem_mo_chg
          (p_event     in  varchar2
          ,p_old_rec   in  g_prem_mo_rec_type
          ,p_new_rec   in  g_prem_mo_rec_type
          ) ;
--
  procedure log_per_pay_chg
          (p_event     in  varchar2
          ,p_old_rec   in  g_per_pay_rec_type
          ,p_new_rec   in  g_per_pay_rec_type
          ) ;
--
  procedure log_school_chg
          (p_event     in  varchar2
          ,p_old_rec   in  g_per_school_rec_type
          ,p_new_rec   in  g_per_school_rec_type
          );

--
  procedure log_per_chg
  (p_event        in   varchar2
  ,p_old_rec      in   g_per_rec_type
  ,p_new_rec      in   g_per_rec_type
  );

--- this is a overlaod procedure to call from SSHR
 procedure log_per_chg
  (p_event        in   varchar2
  ,p_old_rec      in   per_per_shd.g_rec_type
  ,p_new_rec      in   per_per_shd.g_rec_type
----  ,p_mode         in   varchar2
  );

--
  procedure log_cont_chg
  (
   p_old_rec      in   g_cont_rec_type
  ,p_new_rec      in   g_cont_rec_type
  );
--
  procedure log_add_chg
  (p_event        in   varchar2
  ,p_old_rec      in   g_add_rec_type
  ,p_new_rec      in   g_add_rec_type
  );
--
  procedure log_asg_chg
  (p_event        in   varchar2
  ,p_old_rec      in   g_asg_rec_type
  ,p_new_rec      in   g_asg_rec_type
  );
-- this is a overload procedure to call from core HR api
  procedure log_asg_chg
  (p_event        in   varchar2
  ,p_old_rec      in   per_asg_shd.g_rec_type
  ,p_new_rec      in   per_asg_shd.g_rec_type
  );
--
  procedure log_abs_chg
  (p_event        in   varchar2
  ,p_old_rec      in   g_abs_rec_type
  ,p_new_rec      in   g_abs_rec_type
  );
--
  procedure log_pos_chg
  (p_event        in   varchar2
  ,p_old_rec      in   g_pos_rec_type
  ,p_new_rec      in   g_pos_rec_type
  );
--
  procedure log_apl_chg
  (p_event        in   varchar2
  ,p_old_rec      in   g_apl_rec_type
  ,p_new_rec      in   g_apl_rec_type
  );
--
  procedure log_phn_chg
  (p_event        in   varchar2
  ,p_old_rec      in   g_phn_rec_type
  ,p_new_rec      in   g_phn_rec_type
  );
--
  procedure log_ptu_chg
  (p_event        in   varchar2
  ,p_old_rec      in   g_ptu_rec_type
  ,p_new_rec      in   g_ptu_rec_type
  );
--
procedure log_benefit_chg(
        p_action               in varchar2, -- CREATE,UPDATE, or DELETE
        p_pl_id                in number default null,
        p_old_pl_id            in number default null,
        p_oipl_id              in number default null,
        p_old_oipl_id          in number default null,
        p_enrt_cvg_strt_dt     in date default null,
        p_enrt_cvg_end_dt      in date default null,
        p_old_enrt_cvg_strt_dt in date default null,
        p_old_enrt_cvg_end_dt  in date default null,
        p_bnft_amt             in number default null,
        p_old_bnft_amt         in number default null,
        p_pen_attribute1       in varchar2 default null,
        p_pen_attribute2       in varchar2 default null,
        p_pen_attribute3       in varchar2 default null,
        p_pen_attribute4       in varchar2 default null,
        p_pen_attribute5       in varchar2 default null,
        p_pen_attribute6       in varchar2 default null,
        p_pen_attribute7       in varchar2 default null,
        p_pen_attribute8       in varchar2 default null,
        p_pen_attribute9       in varchar2 default null,
        p_pen_attribute10      in varchar2 default null,
        p_old_pen_attribute1   in varchar2 default null,
        p_old_pen_attribute2   in varchar2 default null,
        p_old_pen_attribute3   in varchar2 default null,
        p_old_pen_attribute4   in varchar2 default null,
        p_old_pen_attribute5   in varchar2 default null,
        p_old_pen_attribute6   in varchar2 default null,
        p_old_pen_attribute7   in varchar2 default null,
        p_old_pen_attribute8   in varchar2 default null,
        p_old_pen_attribute9   in varchar2 default null,
        p_old_pen_attribute10  in varchar2 default null,
        p_effective_start_date in date default null,
        p_effective_end_date   in date default null,
        p_prtt_enrt_rslt_id    in number default null,
        p_old_prtt_enrt_rslt_id in number default null,
        p_per_in_ler_id        in number default null,
        p_old_per_in_ler_id    in number default null,
        p_person_id            in number,
        p_business_group_id    in number,
        p_effective_date       in date);

--
procedure log_dependent_chg(
        p_action               in varchar2, -- CREATE,UPDATE, or DELETE
        p_pl_id                in number default null,
        p_oipl_id              in number default null,
        p_cvg_strt_dt          in date default null,
        p_cvg_end_dt           in date default null,
        p_old_cvg_strt_dt      in date default null,
        p_old_cvg_end_dt       in date default null,
        p_effective_start_date in date default null,
        p_effective_end_date   in date default null,
        p_prtt_enrt_rslt_id    in number default null,
        p_per_in_ler_id        in number default null,
        p_elig_cvrd_dpnt_id    in number default null,
        p_person_id            in number,
        p_dpnt_person_id       in number,
        p_business_group_id    in number,
        p_effective_date       in date);

procedure log_pcp_chg(
        p_action               in varchar2,
        p_ext_ident            in varchar2 default null,
        p_old_ext_ident        in varchar2 default null,
        p_name                 in varchar2 default null,
        p_old_name             in varchar2 default null,
        p_prmry_care_prvdr_typ_cd in varchar2 default null,
        p_old_prmry_care_prvdr_typ_cd in varchar2 default null,
        p_prmry_care_prvdr_id  in number default null,
        p_elig_cvrd_dpnt_id    in number default null,
        p_prtt_enrt_rslt_id    in number default null,
        p_effective_start_date in date default null,
        p_effective_end_date   in date default null,
        p_business_group_id    in number,
        p_effective_date       in date);

procedure log_element_chg(
        p_action               in varchar2,
        p_amt                  in number default null,
        p_old_amt              in number default null,
        p_input_value_id       in number default null,
        p_element_entry_id     in number default null,
        p_person_id            in number default null,
        p_effective_start_date in date default null,
        p_effective_end_date   in date default null,
        p_business_group_id    in number,
        p_effective_date       in date);

--procedure for logging changes to per_disabilities_f
procedure log_per_dis_chg(
	p_event		in varchar2,
	p_old_rec	in per_dis_rec_type,
	p_new_rec	in per_dis_rec_type);


end ben_ext_chlg;


/
