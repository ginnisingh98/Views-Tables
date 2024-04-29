--------------------------------------------------------
--  DDL for Package Body PQH_PTX_UTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_PTX_UTL" as
/* $Header: pqptxutl.pkb 120.2.12010000.2 2008/08/05 13:41:27 ubhat ship $ */
--
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqh_ptx_utl.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_attributes >------------------------|
-- ----------------------------------------------------------------------------

procedure delete_attributes
(
 p_query_str        in    varchar2,
 p_attrib_prv_tab   out nocopy   pqh_prvcalc.t_attname_priv
)
is

-- declare local variables

 TYPE cur_typ is REF CURSOR;
 attrib_cur    cur_typ;
 i      binary_integer := 1;
 l_form_column_name        pqh_txn_category_attributes.form_column_name%TYPE;


begin

  OPEN attrib_cur FOR p_query_str;
  LOOP
    FETCH attrib_cur into l_form_column_name;
    EXIT WHEN attrib_cur%NOTFOUND;
    p_attrib_prv_tab(i).form_column_name    := l_form_column_name;
    p_attrib_prv_tab(i).mode_flag         := 'D';
    p_attrib_prv_tab(i).reqd_flag         := 'D';
    i := i + 1;
  END LOOP;

  CLOSE attrib_cur;

end delete_attributes;

-- ----------------------------------------------------------------------------
-- |---------------------------< update_pos_tran >-----------------------------|
-- ----------------------------------------------------------------------------

procedure update_pos_tran(p_position_transaction_id in number,
                          p_position_id             in number,
                          p_job_id                  in number,
                          p_organization_id         in number,
                          p_effective_date	    in date) is
   cursor c1 is select worksheet_detail_id,object_version_number
                from pqh_worksheet_details
                where position_id is null
                and position_transaction_id = p_position_transaction_id
                for update of position_id;
begin
   for i in c1 loop
   	--
      	pqh_wdt_shd.lck(
      			p_worksheet_detail_id   => i.worksheet_detail_id,
                       	p_object_version_number => i.object_version_number);
	--
	pqh_worksheet_details_api.update_worksheet_detail(
			p_worksheet_detail_id 	=> i.worksheet_detail_id,
			p_position_id           => p_position_id,
                        p_job_id                => p_job_id,
                        p_organization_id       => p_organization_id,
			p_effective_date        => p_effective_date,
			p_object_version_number => i.object_version_number);
	--
   end loop;
end update_pos_tran;

-- ----------------------------------------------------------------------------
-- |--------------------------< log_warnings >------------------------------|
-- ----------------------------------------------------------------------------
procedure log_warnings(p_transaction_id number) is
    l_warn_tab  pqh_utility.warnings_tab;
    l_warn_no   number;
begin
      --
      pqh_utility.get_all_warnings(l_warn_tab, l_warn_no);
      --
      if l_warn_no > 0 then
        --
        for l_rec_no in l_warn_tab.first .. l_warn_tab.last
        loop
	  --
          pqh_process_batch_log.set_context_level (
             				    p_txn_id             => l_rec_no,
                                            p_txn_table_route_id => null,
                                            p_level              => 1,
                                            p_log_context        => 'WARNING');
   	  --
   	  pqh_process_batch_log.insert_log ( p_message_type_cd => 'WARNING',
                                      p_message_text    => l_warn_tab(l_rec_no).message_text);
	end loop;
	--
      end if;
      --
end;
--
procedure append_if_not_present(p_string in out nocopy varchar2, p_substring varchar2) is
l_index integer;
begin
    if p_substring is not null then
      if p_string is null then
        p_string := p_substring;
      else
        l_index := instr(nvl(p_string,''), p_substring);
        hr_utility.set_location('l_index:'||nvl(l_index,-111), 1000);
        if l_index = 0 then
          p_string := p_string || fnd_global.local_chr(10) || '  ' || p_substring;
        end if;
      end if;
    end if;
end;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< fetch_position >------------------------------|
-- ----------------------------------------------------------------------------

procedure fetch_position
(
 p_position_transaction_id    out nocopy pqh_position_transactions.position_transaction_id%TYPE,
 p_position_id                in pqh_position_transactions.position_id%TYPE,
 p_action_date                in date,
 p_review_flag                in pqh_position_transactions.review_flag%type
) is
l_object_version_number  number := 1;
v_posn_rec     HR_POSITIONS%ROWTYPE;
l_pei_populated varchar2(5000);
l_jtr_populated varchar2(5000);
l_ptx_deployment_factor_id number;
--
cursor c_pqh_ptx_dpf_df_s is
select pqh_ptx_dpf_df_s.nextval
from dual;
--
CURSOR c1 IS
 SELECT *
  FROM hr_positions
 WHERE position_id = p_position_id;
v_wc_rec     PER_DEPLOYMENT_FACTORS%ROWTYPE;
--
CURSOR c2 IS
 SELECT *
 FROM per_deployment_factors
 WHERE position_id = p_position_id;
begin
    --
    OPEN c1;
    FETCH c1 INTO v_posn_rec;
    if c1%notfound then
      return;
    else
      OPEN c2;
      FETCH c2 INTO v_wc_rec;
      CLOSE c2;
    end if;
    CLOSE c1;
    --
    if (pqh_psf_bus.position_control_enabled(
      v_posn_rec.organization_id, p_action_date) = 'N') then
      fnd_message.set_name('PQH','PQH_ORG_NOT_POS_CONTROLLED');
      fnd_message.raise_error;
    end if;
    --
    if (v_posn_rec.review_flag = 'Y') then
      fnd_message.set_name('PQH','PQH_POSITION_UNDER_REVIEW');
      fnd_message.raise_error;
    end if;
    --
    pqh_position_transactions_api.create_position_transaction
(
   p_validate                          =>  false
  ,p_position_transaction_id           =>  p_position_transaction_id
  ,p_action_date                       =>  p_action_date
  ,p_position_id                       =>  p_position_id
  ,p_availability_status_id            =>  v_posn_rec.availability_status_id
  ,p_business_group_id                 =>  v_posn_rec.business_group_id
  ,p_entry_step_id                     =>  v_posn_rec.entry_step_id
  ,p_entry_grade_rule_id               =>  v_posn_rec.entry_grade_rule_id
  ,p_job_id                            =>  v_posn_rec.job_id
  ,p_location_id                       =>  v_posn_rec.location_id
  ,p_organization_id                   =>  v_posn_rec.organization_id
  ,p_pay_freq_payroll_id               =>  v_posn_rec.pay_freq_payroll_id
  ,p_position_definition_id            =>  v_posn_rec.position_definition_id
  ,p_prior_position_id                 =>  v_posn_rec.prior_position_id
  ,p_relief_position_id                =>  v_posn_rec.relief_position_id
  ,p_entry_grade_id                    =>  v_posn_rec.entry_grade_id
  ,p_successor_position_id             =>  v_posn_rec.successor_position_id
  ,p_supervisor_position_id            =>  v_posn_rec.supervisor_position_id
  ,p_amendment_date                    =>  v_posn_rec.amendment_date
  ,p_amendment_recommendation          =>  v_posn_rec.amendment_recommendation
  ,p_amendment_ref_number              =>  v_posn_rec.amendment_ref_number
  ,p_avail_status_prop_end_date        =>  v_posn_rec.avail_status_prop_end_date
  ,p_bargaining_unit_cd                =>  v_posn_rec.bargaining_unit_cd
  ,p_comments                          =>  v_posn_rec.comments
  ,p_country1                          =>  v_wc_rec.country1
  ,p_country2                          =>  v_wc_rec.country2
  ,p_country3                          =>  v_wc_rec.country3
  ,p_current_job_prop_end_date         =>  v_posn_rec.current_job_prop_end_date
  ,p_current_org_prop_end_date         =>  v_posn_rec.current_org_prop_end_date
  ,p_date_effective                    =>  v_posn_rec.date_effective
  ,p_date_end                          =>  null --v_posn_rec.date_end
  ,p_earliest_hire_date                =>  v_posn_rec.earliest_hire_date
  ,p_fill_by_date                      =>  v_posn_rec.fill_by_date
  ,p_frequency                         =>  v_posn_rec.frequency
  ,p_fte                               =>  v_posn_rec.fte
  ,p_fte_capacity                      =>  v_wc_rec.fte_capacity
  ,p_location1                         =>  v_wc_rec.location1
  ,p_location2                         =>  v_wc_rec.location2
  ,p_location3                         =>  v_wc_rec.location3
  ,p_max_persons                       =>  v_posn_rec.max_persons
  ,p_name                              =>  v_posn_rec.name
  ,p_other_requirements                =>  v_wc_rec.other_requirements
  ,p_overlap_period                    =>  v_posn_rec.overlap_period
  ,p_overlap_unit_cd                   =>  v_posn_rec.overlap_unit_cd
  ,p_passport_required                 =>  v_wc_rec.passport_required
  ,p_pay_term_end_day_cd               =>  v_posn_rec.pay_term_end_day_cd
  ,p_pay_term_end_month_cd             =>  v_posn_rec.pay_term_end_month_cd
  ,p_permanent_temporary_flag          =>  nvl(v_posn_rec.permanent_temporary_flag, 'Y')
  ,p_permit_recruitment_flag           =>  nvl(v_posn_rec.permit_recruitment_flag, 'N')
  ,p_position_type                     =>  v_posn_rec.position_type
  ,p_posting_description               =>  v_posn_rec.posting_description
  ,p_probation_period                  =>  v_posn_rec.probation_period
  ,p_probation_period_unit_cd          =>  v_posn_rec.probation_period_unit_cd
  ,p_relocate_domestically             =>  v_wc_rec.relocate_domestically
  ,p_relocate_internationally          =>  v_wc_rec.relocate_internationally
  ,p_replacement_required_flag         =>  nvl(v_posn_rec.replacement_required_flag, 'N')
  ,p_review_flag                       =>  nvl(p_review_flag, 'N')
  ,p_seasonal_flag                     =>  nvl(v_posn_rec.seasonal_flag, 'N')
  ,p_security_requirements             =>  v_posn_rec.security_requirements
  ,p_service_minimum                   =>  v_wc_rec.service_minimum
  ,p_term_start_day_cd                 =>  v_posn_rec.term_start_day_cd
  ,p_term_start_month_cd               =>  v_posn_rec.term_start_month_cd
  ,p_time_normal_finish                =>  v_posn_rec.time_normal_finish
  ,p_time_normal_start                 =>  v_posn_rec.time_normal_start
  ,p_transaction_status                =>  'PENDING' --:ptx.transaction_status
  ,p_travel_required                   =>  v_wc_rec.travel_required
  ,p_working_hours                     =>  v_posn_rec.working_hours
  ,p_works_council_approval_flag       =>  v_posn_rec.works_council_approval_flag
  ,p_work_any_country                  =>  v_wc_rec.work_any_country
  ,p_work_any_location                 =>  v_wc_rec.work_any_location
  ,p_work_period_type_cd               =>  v_posn_rec.work_period_type_cd
  ,p_work_schedule                     =>  v_wc_rec.work_schedule
  ,p_work_duration                     =>  v_wc_rec.work_duration
  ,p_work_term_end_day_cd              =>  v_posn_rec.work_term_end_day_cd
  ,p_work_term_end_month_cd            =>  v_posn_rec.work_term_end_month_cd
  ,p_proposed_fte_for_layoff           =>  v_posn_rec.proposed_fte_for_layoff
  ,p_proposed_date_for_layoff          =>  v_posn_rec.proposed_date_for_layoff
  ,p_information1                      =>  v_posn_rec.information1
  ,p_information2                      =>  v_posn_rec.information2
  ,p_information3                      =>  v_posn_rec.information3
  ,p_information4                      =>  v_posn_rec.information4
  ,p_information5                      =>  v_posn_rec.information5
  ,p_information6                      =>  v_posn_rec.information6
  ,p_information7                      =>  v_posn_rec.information7
  ,p_information8                      =>  v_posn_rec.information8
  ,p_information9                      =>  v_posn_rec.information9
  ,p_information10                     =>  v_posn_rec.information10
  ,p_information11                     =>  v_posn_rec.information11
  ,p_information12                     =>  v_posn_rec.information12
  ,p_information13                     =>  v_posn_rec.information13
  ,p_information14                     =>  v_posn_rec.information14
  ,p_information15                     =>  v_posn_rec.information15
  ,p_information16                     =>  v_posn_rec.information16
  ,p_information17                     =>  v_posn_rec.information17
  ,p_information18                     =>  v_posn_rec.information18
  ,p_information19                     =>  v_posn_rec.information19
  ,p_information20                     =>  v_posn_rec.information20
  ,p_information21                     =>  v_posn_rec.information21
  ,p_information22                     =>  v_posn_rec.information22
  ,p_information23                     =>  v_posn_rec.information23
  ,p_information24                     =>  v_posn_rec.information24
  ,p_information25                     =>  v_posn_rec.information25
  ,p_information26                     =>  v_posn_rec.information26
  ,p_information27                     =>  v_posn_rec.information27
  ,p_information28                     =>  v_posn_rec.information28
  ,p_information29                     =>  v_posn_rec.information29
  ,p_information30                     =>  v_posn_rec.information30
  ,p_information_category              =>  v_posn_rec.information_category
  ,p_attribute1                        =>  v_posn_rec.attribute1
  ,p_attribute2                        =>  v_posn_rec.attribute2
  ,p_attribute3                        =>  v_posn_rec.attribute3
  ,p_attribute4                        =>  v_posn_rec.attribute4
  ,p_attribute5                        =>  v_posn_rec.attribute5
  ,p_attribute6                        =>  v_posn_rec.attribute6
  ,p_attribute7                        =>  v_posn_rec.attribute7
  ,p_attribute8                        =>  v_posn_rec.attribute8
  ,p_attribute9                        =>  v_posn_rec.attribute9
  ,p_attribute10                       =>  v_posn_rec.attribute10
  ,p_attribute11                       =>  v_posn_rec.attribute11
  ,p_attribute12                       =>  v_posn_rec.attribute12
  ,p_attribute13                       =>  v_posn_rec.attribute13
  ,p_attribute14                       =>  v_posn_rec.attribute14
  ,p_attribute15                       =>  v_posn_rec.attribute15
  ,p_attribute16                       =>  v_posn_rec.attribute16
  ,p_attribute17                       =>  v_posn_rec.attribute17
  ,p_attribute18                       =>  v_posn_rec.attribute18
  ,p_attribute19                       =>  v_posn_rec.attribute19
  ,p_attribute20                       =>  v_posn_rec.attribute20
  ,p_attribute21                       =>  v_posn_rec.attribute21
  ,p_attribute22                       =>  v_posn_rec.attribute22
  ,p_attribute23                       =>  v_posn_rec.attribute23
  ,p_attribute24                       =>  v_posn_rec.attribute24
  ,p_attribute25                       =>  v_posn_rec.attribute25
  ,p_attribute26                       =>  v_posn_rec.attribute26
  ,p_attribute27                       =>  v_posn_rec.attribute27
  ,p_attribute28                       =>  v_posn_rec.attribute28
  ,p_attribute29                       =>  v_posn_rec.attribute29
  ,p_attribute30                       =>  v_posn_rec.attribute30
  ,p_attribute_category                =>  v_posn_rec.attribute_category
  ,p_object_version_number             =>  l_object_version_number --:ptx.object_version_number
  ,p_effective_date                    =>  p_action_date
  ,p_pay_basis_id                      =>  v_posn_rec.pay_basis_id
  ,p_supervisor_id                     =>  v_posn_rec.supervisor_id
  ,p_wf_transaction_category_id        =>
     pqh_workflow.get_txn_cat('POSITION_TRANSACTION',v_posn_rec.business_group_id)
 );
if (v_posn_rec.position_id is not null) and (p_position_transaction_id is not null) then
   --
   open c_pqh_ptx_dpf_df_s;
   fetch c_pqh_ptx_dpf_df_s into l_ptx_deployment_factor_id;
   close c_pqh_ptx_dpf_df_s;
   --
   insert into pqh_ptx_dpf_df
   (
   ptx_deployment_factor_id, deployment_factor_id, position_transaction_id,
   attribute_category,
   attribute1, attribute2, attribute3, attribute4, attribute5,
   attribute6, attribute7, attribute8, attribute9, attribute10,
   attribute11, attribute12, attribute13, attribute14, attribute15,
   attribute16, attribute17, attribute18, attribute19, attribute20,
   object_version_number
   )
   values
   (
   l_ptx_deployment_factor_id, v_wc_rec.deployment_factor_id, p_position_transaction_id,
   v_wc_rec.attribute_category,
   v_wc_rec.attribute1, v_wc_rec.attribute2, v_wc_rec.attribute3, v_wc_rec.attribute4, v_wc_rec.attribute5,
   v_wc_rec.attribute6, v_wc_rec.attribute7, v_wc_rec.attribute8, v_wc_rec.attribute9, v_wc_rec.attribute10,
   v_wc_rec.attribute11, v_wc_rec.attribute12, v_wc_rec.attribute13, v_wc_rec.attribute14, v_wc_rec.attribute15,
   v_wc_rec.attribute16, v_wc_rec.attribute17, v_wc_rec.attribute18, v_wc_rec.attribute19, v_wc_rec.attribute20,
   1
   );
   --
   --
   insert into pqh_ptx_dpf_df_shadow
   (
   ptx_deployment_factor_id, deployment_factor_id, position_transaction_id,
   attribute_category,
   attribute1, attribute2, attribute3, attribute4, attribute5,
   attribute6, attribute7, attribute8, attribute9, attribute10,
   attribute11, attribute12, attribute13, attribute14, attribute15,
   attribute16, attribute17, attribute18, attribute19, attribute20,
   object_version_number
   )
   values
   (
   l_ptx_deployment_factor_id, v_wc_rec.deployment_factor_id, p_position_transaction_id,
   v_wc_rec.attribute_category,
   v_wc_rec.attribute1, v_wc_rec.attribute2, v_wc_rec.attribute3, v_wc_rec.attribute4, v_wc_rec.attribute5,
   v_wc_rec.attribute6, v_wc_rec.attribute7, v_wc_rec.attribute8, v_wc_rec.attribute9, v_wc_rec.attribute10,
   v_wc_rec.attribute11, v_wc_rec.attribute12, v_wc_rec.attribute13, v_wc_rec.attribute14, v_wc_rec.attribute15,
   v_wc_rec.attribute16, v_wc_rec.attribute17, v_wc_rec.attribute18, v_wc_rec.attribute19, v_wc_rec.attribute20,
   1
   );
   -- populate extra_info into postion transaction
   pqh_ptx_utl.populate_pei
   ( p_position_transaction_id  =>  p_position_transaction_id,
     p_position_id              =>  p_position_id,
     p_populated                =>  l_pei_populated
   );
   pqh_ptx_utl.populate_job_requirements
   ( p_position_transaction_id  =>  p_position_transaction_id,
     p_position_id              =>  p_position_id,
     p_populated                =>  l_jtr_populated
   );
  create_ptx_shadow(p_position_transaction_id);
  create_pte_shadow(p_position_transaction_id);
  create_tjr_shadow(p_position_transaction_id);
end if;
exception when others then
p_position_transaction_id := null;
raise;
end;
--
/*
PROCEDURE create_shadow_record(p_position_transaction_id number,p_position_id number) IS

cursor c1 is
select * from hr_positions
where position_id=p_position_id;

cursor c2 is
select *
from per_deployment_factors
where position_id=p_position_id;

cursor c3 is
select *
from pqh_ptx_extra_info
where position_transaction_id=p_position_transaction_id;

rec1 c1%rowtype;
rec2 c2%rowtype;

BEGIN

open c1;
fetch c1 into rec1;
close c1;

open c2;
fetch c2 into rec2;
close c2;

insert into pqh_ptx_shadow
(
AMENDMENT_DATE,
AMENDMENT_RECOMMENDATION,
AMENDMENT_REF_NUMBER,
ATTRIBUTE1,
ATTRIBUTE10,
ATTRIBUTE11,
ATTRIBUTE12,
ATTRIBUTE13,
ATTRIBUTE14,
ATTRIBUTE15,
ATTRIBUTE16,
ATTRIBUTE17,
ATTRIBUTE18,
ATTRIBUTE19,
ATTRIBUTE2,
ATTRIBUTE20,
ATTRIBUTE21,
ATTRIBUTE22,
ATTRIBUTE23,
ATTRIBUTE24,
ATTRIBUTE25,
ATTRIBUTE26,
ATTRIBUTE27,
ATTRIBUTE28,
ATTRIBUTE29,
ATTRIBUTE3,
ATTRIBUTE30,
ATTRIBUTE4,
ATTRIBUTE5,
ATTRIBUTE6,
ATTRIBUTE7,
ATTRIBUTE8,
ATTRIBUTE9,
ATTRIBUTE_CATEGORY,
AVAILABILITY_STATUS_ID,
AVAIL_STATUS_PROP_END_DATE,
BARGAINING_UNIT_CD,
BUSINESS_GROUP_ID,
COMMENTS,
CURRENT_JOB_PROP_END_DATE,
CURRENT_ORG_PROP_END_DATE,
DATE_EFFECTIVE,
DATE_END,
EARLIEST_HIRE_DATE,
ENTRY_GRADE_ID,
ENTRY_GRADE_RULE_ID,
ENTRY_STEP_ID,
FILL_BY_DATE,
FREQUENCY,
FTE,
FTE_CAPACITY,
INFORMATION1,
INFORMATION10,
INFORMATION11,
INFORMATION12,
INFORMATION13,
INFORMATION14,
INFORMATION15,
INFORMATION16,
INFORMATION17,
INFORMATION18,
INFORMATION19,
INFORMATION2,
INFORMATION20,
INFORMATION21,
INFORMATION22,
INFORMATION23,
INFORMATION24,
INFORMATION25,
INFORMATION26,
INFORMATION27,
INFORMATION28,
INFORMATION29,
INFORMATION3,
INFORMATION30,
INFORMATION4,
INFORMATION5,
INFORMATION6,
INFORMATION7,
INFORMATION8,
INFORMATION9,
INFORMATION_CATEGORY,
JOB_ID,
LOCATION_ID,
MAX_PERSONS,
NAME,
ORGANIZATION_ID,
OVERLAP_PERIOD,
OVERLAP_UNIT_CD,
PASSPORT_REQUIRED,
PAY_BASIS_ID,
PAY_FREQ_PAYROLL_ID,
PAY_TERM_END_DAY_CD,
PAY_TERM_END_MONTH_CD,
PERMANENT_TEMPORARY_FLAG,
PERMIT_RECRUITMENT_FLAG,
POSITION_DEFINITION_ID,
POSITION_ID,
POSITION_TRANSACTION_ID,
POSITION_TYPE,
POSTING_DESCRIPTION,
PRIOR_POSITION_ID,
PROBATION_PERIOD,
PROBATION_PERIOD_UNIT_CD,
PROPOSED_DATE_FOR_LAYOFF,
PROPOSED_FTE_FOR_LAYOFF,
RELIEF_POSITION_ID,
RELOCATE_DOMESTICALLY,
RELOCATE_INTERNATIONALLY,
RELOCATION_REQUIRED,
REPLACEMENT_REQUIRED_FLAG,
REVIEW_FLAG,
SEASONAL_FLAG,
SECURITY_REQUIREMENTS,
SUCCESSOR_POSITION_ID,
SUPERVISOR_ID,
SUPERVISOR_POSITION_ID,
SERVICE_MINIMUM,
TERM_START_DAY_CD,
TERM_START_MONTH_CD,
TIME_NORMAL_FINISH,
TIME_NORMAL_START,
TRAVEL_REQUIRED,
VISIT_INTERNATIONALLY,
WORKING_HOURS,
WORKS_COUNCIL_APPROVAL_FLAG,
WORK_ANY_COUNTRY,
WORK_ANY_LOCATION,
WORK_DURATION,
WORK_PERIOD_TYPE_CD,
WORK_TERM_END_DAY_CD,
WORK_TERM_END_MONTH_CD,
object_version_number)
values
(
rec1.AMENDMENT_DATE,
rec1.AMENDMENT_RECOMMENDATION,
rec1.AMENDMENT_REF_NUMBER,
rec1.ATTRIBUTE1,
rec1.ATTRIBUTE10,
rec1.ATTRIBUTE11,
rec1.ATTRIBUTE12,
rec1.ATTRIBUTE13,
rec1.ATTRIBUTE14,
rec1.ATTRIBUTE15,
rec1.ATTRIBUTE16,
rec1.ATTRIBUTE17,
rec1.ATTRIBUTE18,
rec1.ATTRIBUTE19,
rec1.ATTRIBUTE2,
rec1.ATTRIBUTE20,
rec1.ATTRIBUTE21,
rec1.ATTRIBUTE22,
rec1.ATTRIBUTE23,
rec1.ATTRIBUTE24,
rec1.ATTRIBUTE25,
rec1.ATTRIBUTE26,
rec1.ATTRIBUTE27,
rec1.ATTRIBUTE28,
rec1.ATTRIBUTE29,
rec1.ATTRIBUTE3,
rec1.ATTRIBUTE30,
rec1.ATTRIBUTE4,
rec1.ATTRIBUTE5,
rec1.ATTRIBUTE6,
rec1.ATTRIBUTE7,
rec1.ATTRIBUTE8,
rec1.ATTRIBUTE9,
rec1.ATTRIBUTE_CATEGORY,
rec1.AVAILABILITY_STATUS_ID,
rec1.AVAIL_STATUS_PROP_END_DATE,
rec1.BARGAINING_UNIT_CD,
rec1.BUSINESS_GROUP_ID,
rec1.COMMENTS,
rec1.CURRENT_JOB_PROP_END_DATE,
rec1.CURRENT_ORG_PROP_END_DATE,
rec1.DATE_EFFECTIVE,
rec1.DATE_END,
rec1.EARLIEST_HIRE_DATE,
rec1.ENTRY_GRADE_ID,
rec1.ENTRY_GRADE_RULE_ID,
rec1.ENTRY_STEP_ID,
rec1.FILL_BY_DATE,
rec1.FREQUENCY,
rec1.FTE,
rec2.FTE_CAPACITY,
rec1.INFORMATION1,
rec1.INFORMATION10,
rec1.INFORMATION11,
rec1.INFORMATION12,
rec1.INFORMATION13,
rec1.INFORMATION14,
rec1.INFORMATION15,
rec1.INFORMATION16,
rec1.INFORMATION17,
rec1.INFORMATION18,
rec1.INFORMATION19,
rec1.INFORMATION2,
rec1.INFORMATION20,
rec1.INFORMATION21,
rec1.INFORMATION22,
rec1.INFORMATION23,
rec1.INFORMATION24,
rec1.INFORMATION25,
rec1.INFORMATION26,
rec1.INFORMATION27,
rec1.INFORMATION28,
rec1.INFORMATION29,
rec1.INFORMATION3,
rec1.INFORMATION30,
rec1.INFORMATION4,
rec1.INFORMATION5,
rec1.INFORMATION6,
rec1.INFORMATION7,
rec1.INFORMATION8,
rec1.INFORMATION9,
rec1.INFORMATION_CATEGORY,
rec1.JOB_ID,
rec1.LOCATION_ID,
rec1.MAX_PERSONS,
rec1.NAME,
rec1.ORGANIZATION_ID,
rec1.OVERLAP_PERIOD,
rec1.OVERLAP_UNIT_CD,
rec2.PASSPORT_REQUIRED,
rec1.PAY_BASIS_ID,
rec1.PAY_FREQ_PAYROLL_ID,
rec1.PAY_TERM_END_DAY_CD,
rec1.PAY_TERM_END_MONTH_CD,
rec1.PERMANENT_TEMPORARY_FLAG,
rec1.PERMIT_RECRUITMENT_FLAG,
rec1.POSITION_DEFINITION_ID,
p_POSITION_ID,
p_position_transaction_id,
rec1.POSITION_TYPE,
rec1.POSTING_DESCRIPTION,
rec1.PRIOR_POSITION_ID,
rec1.PROBATION_PERIOD,
rec1.PROBATION_PERIOD_UNIT_CD,
rec1.PROPOSED_DATE_FOR_LAYOFF,
rec1.PROPOSED_FTE_FOR_LAYOFF,
rec1.RELIEF_POSITION_ID,
rec2.RELOCATE_DOMESTICALLY,
rec2.RELOCATE_INTERNATIONALLY,
rec2.RELOCATION_REQUIRED,
rec1.REPLACEMENT_REQUIRED_FLAG,
rec1.REVIEW_FLAG,
rec1.SEASONAL_FLAG,
rec1.SECURITY_REQUIREMENTS,
rec1.SUCCESSOR_POSITION_ID,
rec1.SUPERVISOR_ID,
rec1.SUPERVISOR_POSITION_ID,
rec2.SERVICE_MINIMUM,
rec1.TERM_START_DAY_CD,
rec1.TERM_START_MONTH_CD,
rec1.TIME_NORMAL_FINISH,
rec1.TIME_NORMAL_START,
rec2.TRAVEL_REQUIRED,
rec2.VISIT_INTERNATIONALLY,
rec1.WORKING_HOURS,
rec1.WORKS_COUNCIL_APPROVAL_FLAG,
rec2.WORK_ANY_COUNTRY,
rec2.WORK_ANY_LOCATION,
rec2.WORK_DURATION,
rec1.WORK_PERIOD_TYPE_CD,
rec1.WORK_TERM_END_DAY_CD,
rec1.WORK_TERM_END_MONTH_CD,
1);
--
for rec3 in c3 loop
insert into pqh_pte_shadow
(ptx_extra_info_id, information_type, position_transaction_id, position_extra_info_id,
information_category, information1, information2, information3, information4, information5,
information6, information7, information8, information9, information10,
information11, information12, information13, information14, information15,
information16, information17, information18, information19, information20,
information21, information22, information23, information24, information25,
information26, information27, information28, information29, information30,
attribute_category, attribute1, attribute2, attribute3, attribute4, attribute5,
attribute6, attribute7, attribute8, attribute9, attribute10,
attribute11, attribute12, attribute13, attribute14, attribute15,
attribute16, attribute17, attribute18, attribute19, attribute20,
object_version_number)
values
(rec3.ptx_extra_info_id, rec3.information_type, rec3.position_transaction_id, rec3.position_extra_info_id,
rec3.information_category,
rec3.information1, rec3.information2, rec3.information3, rec3.information4, rec3.information5,
rec3.information6, rec3.information7, rec3.information8, rec3.information9, rec3.information10,
rec3.information11, rec3.information12, rec3.information13, rec3.information14, rec3.information15,
rec3.information16, rec3.information17, rec3.information18, rec3.information19, rec3.information20,
rec3.information21, rec3.information22, rec3.information23, rec3.information24, rec3.information25,
rec3.information26, rec3.information27, rec3.information28, rec3.information29, rec3.information30,
rec3.attribute_category, rec3.attribute1, rec3.attribute2, rec3.attribute3, rec3.attribute4, rec3.attribute5,
rec3.attribute6, rec3.attribute7, rec3.attribute8, rec3.attribute9, rec3.attribute10,
rec3.attribute11, rec3.attribute12, rec3.attribute13, rec3.attribute14, rec3.attribute15,
rec3.attribute16, rec3.attribute17, rec3.attribute18, rec3.attribute19, rec3.attribute20,
1);
end loop;
--
END;
*/
--
-- ----------------------------------------------------------------------------
-- |----------------------------< populate_pei >------------------------------|
-- ----------------------------------------------------------------------------

procedure populate_pei
(
 p_position_transaction_id    in pqh_position_transactions.position_transaction_id%TYPE,
 p_position_id                in pqh_position_transactions.position_id%TYPE,
 p_populated                  in out nocopy varchar2
) is

/*

  This procedure will be called from the Position Transaction Form.
  In the case of update template, the user selects an existing position.
  we will fetch corresponding records from per_position_extra_info table.
  With the position_transaction_id id and the position_id of current position,
  we will insert records in the pqh_ptx_extra_info table.

*/

-- declare variables
  l_ptx_extra_info_id       pqh_ptx_extra_info.ptx_extra_info_id%TYPE;
  l_object_version_number   pqh_ptx_extra_info.object_version_number%TYPE  := 1;

  CURSOR c1 IS
  select *
  from  per_position_extra_info pei
  where information_type <> 'PQH_POS_ROLE_ID'
    and position_id = p_position_id
    and not exists
    (select null from  pqh_pte_shadow pps where position_transaction_id = p_position_transaction_id
     and pps.position_extra_info_id = pei.position_extra_info_id);
--
l_pte_context_desc  varchar2(1000);

begin

--

        FOR v_poei_rec in c1 loop
           -- select the sequence number for pqh_ptx_extra_info
           select pqh_ptx_extra_info_s.nextval
           into l_ptx_extra_info_id
           from dual;

          -- insert record into pqh_ptx_extra_info

          insert into pqh_ptx_extra_info
          (
           PTX_EXTRA_INFO_ID,
           INFORMATION_TYPE,
           POSITION_TRANSACTION_ID,
           POSITION_EXTRA_INFO_ID,
           INFORMATION_CATEGORY,
           INFORMATION1,
           INFORMATION2,
           INFORMATION3,
           INFORMATION4,
           INFORMATION5,
           INFORMATION6,
           INFORMATION7,
           INFORMATION8,
           INFORMATION9,
           INFORMATION10,
           INFORMATION11,
           INFORMATION12,
           INFORMATION13,
           INFORMATION14,
           INFORMATION15,
           INFORMATION16,
           INFORMATION17,
           INFORMATION18,
           INFORMATION19,
           INFORMATION20,
           INFORMATION21,
           INFORMATION22,
           INFORMATION23,
           INFORMATION24,
           INFORMATION25,
           INFORMATION26,
           INFORMATION27,
           INFORMATION28,
           INFORMATION29,
           INFORMATION30,
           ATTRIBUTE_CATEGORY,
           ATTRIBUTE1,
           ATTRIBUTE2,
           ATTRIBUTE3,
           ATTRIBUTE4,
           ATTRIBUTE5,
           ATTRIBUTE6,
           ATTRIBUTE7,
           ATTRIBUTE8,
           ATTRIBUTE9,
           ATTRIBUTE10,
           ATTRIBUTE11,
           ATTRIBUTE12,
           ATTRIBUTE13,
           ATTRIBUTE14,
           ATTRIBUTE15,
           ATTRIBUTE16,
           ATTRIBUTE17,
           ATTRIBUTE18,
           ATTRIBUTE19,
           ATTRIBUTE20,
           OBJECT_VERSION_NUMBER
          )
          values
          (
           l_ptx_extra_info_id,
           v_poei_rec.information_type,
           p_position_transaction_id,
           v_poei_rec.POSITION_EXTRA_INFO_ID,
           v_poei_rec.POEI_INFORMATION_CATEGORY,
           v_poei_rec.POEI_INFORMATION1,
           v_poei_rec.POEI_INFORMATION2,
           v_poei_rec.POEI_INFORMATION3,
           v_poei_rec.POEI_INFORMATION4,
           v_poei_rec.POEI_INFORMATION5,
           v_poei_rec.POEI_INFORMATION6,
           v_poei_rec.POEI_INFORMATION7,
           v_poei_rec.POEI_INFORMATION8,
           v_poei_rec.POEI_INFORMATION9,
           v_poei_rec.POEI_INFORMATION10,
           v_poei_rec.POEI_INFORMATION11,
           v_poei_rec.POEI_INFORMATION12,
           v_poei_rec.POEI_INFORMATION13,
           v_poei_rec.POEI_INFORMATION14,
           v_poei_rec.POEI_INFORMATION15,
           v_poei_rec.POEI_INFORMATION16,
           v_poei_rec.POEI_INFORMATION17,
           v_poei_rec.POEI_INFORMATION18,
           v_poei_rec.POEI_INFORMATION19,
           v_poei_rec.POEI_INFORMATION20,
           v_poei_rec.POEI_INFORMATION21,
           v_poei_rec.POEI_INFORMATION22,
           v_poei_rec.POEI_INFORMATION23,
           v_poei_rec.POEI_INFORMATION24,
           v_poei_rec.POEI_INFORMATION25,
           v_poei_rec.POEI_INFORMATION26,
           v_poei_rec.POEI_INFORMATION27,
           v_poei_rec.POEI_INFORMATION28,
           v_poei_rec.POEI_INFORMATION29,
           v_poei_rec.POEI_INFORMATION30,
           v_poei_rec.POEI_ATTRIBUTE_CATEGORY,
           v_poei_rec.POEI_ATTRIBUTE1,
           v_poei_rec.POEI_ATTRIBUTE2,
           v_poei_rec.POEI_ATTRIBUTE3,
           v_poei_rec.POEI_ATTRIBUTE4,
           v_poei_rec.POEI_ATTRIBUTE5,
           v_poei_rec.POEI_ATTRIBUTE6,
           v_poei_rec.POEI_ATTRIBUTE7,
           v_poei_rec.POEI_ATTRIBUTE8,
           v_poei_rec.POEI_ATTRIBUTE9,
           v_poei_rec.POEI_ATTRIBUTE10,
           v_poei_rec.POEI_ATTRIBUTE11,
           v_poei_rec.POEI_ATTRIBUTE12,
           v_poei_rec.POEI_ATTRIBUTE13,
           v_poei_rec.POEI_ATTRIBUTE14,
           v_poei_rec.POEI_ATTRIBUTE15,
           v_poei_rec.POEI_ATTRIBUTE16,
           v_poei_rec.POEI_ATTRIBUTE17,
           v_poei_rec.POEI_ATTRIBUTE18,
           v_poei_rec.POEI_ATTRIBUTE19,
           v_poei_rec.POEI_ATTRIBUTE20,
           l_object_version_number
          );

          l_pte_context_desc := pqh_utility.get_pte_context_desc(l_ptx_extra_info_id);
          append_if_not_present(p_populated, l_pte_context_desc);
       END LOOP;

end populate_pei;
--
-- ----------------------------------------------------------------------------
-- |------------------< populate_job_requirements >---------------------------|
-- ----------------------------------------------------------------------------

procedure populate_job_requirements
(
 p_position_transaction_id    in pqh_position_transactions.position_transaction_id%TYPE,
 p_position_id                in pqh_position_transactions.position_id%TYPE,
 p_populated                  in out nocopy varchar2
) is

/*

  This procedure will be called from the Position Transaction Form.
  In the case of update template, the user selects an existing position.
  we will fetch corresponding records from per_job_requirements table.
  With the position_transaction_id and the position_id of current position,
  we will insert records in the pqh_txn_job_requirements table.

*/

-- declare variables
  l_txn_job_requirement_id       pqh_txn_job_requirements.txn_job_requirement_id%TYPE;
  l_object_version_number        pqh_txn_job_requirements.object_version_number%TYPE  := 1;

  CURSOR c1 IS
   select *
   from  per_job_requirements pjr
   where pjr.position_id = p_position_id
   and not exists
   (select null from pqh_tjr_shadow pts
     where pts.position_transaction_id = p_position_transaction_id
     and pts.job_requirement_id = pjr.job_requirement_id);

--
l_tjr_classification varchar2(1000);

begin

--

        FOR r_jre in c1 loop
           -- select the sequence number for pqh_txn_job_requirements
           select pqh_txn_job_requirements_s.nextval
           into l_txn_job_requirement_id
           from dual;

          -- insert record into pqh_txn_job_requirements

          insert into pqh_txn_job_requirements
          (
 txn_job_requirement_id,
 position_transaction_id,
 job_requirement_id,
 business_group_id,
 analysis_criteria_id,
 date_from,
 date_to,
 essential,
 job_id,
 object_version_number,
 attribute_category,
 attribute1,
 attribute2,
 attribute3,
 attribute4,
 attribute5,
 attribute6,
 attribute7,
 attribute8,
 attribute9,
 attribute10,
 attribute11,
 attribute12,
 attribute13,
 attribute14,
 attribute15,
 attribute16,
 attribute17,
 attribute18,
 attribute19,
 attribute20,
 comments
          )
          values
          (
  l_txn_job_requirement_id,
  p_position_transaction_id,
  r_jre.job_requirement_id,
  r_jre.business_group_id,
  r_jre.analysis_criteria_id,
  r_jre.date_from,
  r_jre.date_to,
  r_jre.essential,
  r_jre.job_id,
  l_object_version_number,
  r_jre.attribute_category,
  r_jre.attribute1,
  r_jre.attribute2,
  r_jre.attribute3,
  r_jre.attribute4,
  r_jre.attribute5,
  r_jre.attribute6,
  r_jre.attribute7,
  r_jre.attribute8,
  r_jre.attribute9,
  r_jre.attribute10,
  r_jre.attribute11,
  r_jre.attribute12,
  r_jre.attribute13,
  r_jre.attribute14,
  r_jre.attribute15,
  r_jre.attribute16,
  r_jre.attribute17,
  r_jre.attribute18,
  r_jre.attribute19,
  r_jre.attribute20,
  r_jre.comments
          );

         l_tjr_classification := pqh_utility.get_tjr_classification(l_txn_job_requirement_id);
         append_if_not_present(p_populated, l_tjr_classification);
       END LOOP;

end populate_job_requirements;

-- ----------------------------------------------------------------------------
-- |------------------------< alter_session_push >------------------------|
-- ----------------------------------------------------------------------------

procedure alter_session_push is

/*
 This is called thru the Position Txn Form as a work around for bug 934616.
 When we query the pqh_position_transactions_v the session hangs. So as a
 work around we have to alter session set "_push_join_predicate"=FALSE
*/
--
-- local variables
--
 l_proc          varchar2(72) := g_package||'alter_session_push';


BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);

 EXECUTE IMMEDIATE
 'alter session set "_push_join_predicate"=FALSE';

  hr_utility.set_location('Leaving:'||l_proc, 1000);

EXCEPTION
      WHEN OTHERS THEN
          Raise ;
END alter_session_push;




-- ----------------------------------------------------------------------------
-- |------------------------< apply_transaction >------------------------|
-- ----------------------------------------------------------------------------

function apply_transaction
(  p_transaction_id    in pqh_position_transactions.position_transaction_id%TYPE,
   p_validate_only              in varchar2 default 'NO'
) return varchar2 is
/*

 This procedure will be called from the PQHPCTXN Position Transaction form
 when the user selects Apply Transaction option in the routing window.
 This procedure will determine whether it is an update transaction or
 a new position transaction and will call the apis to populate the
 underlying master tables.
 It will poppulate the following tables
 hr_all_positions_f
 per_positions
 per_position_extra_info
 per_deployment_factors

*/

--
-- local variables
--
 l_proc                      varchar2(72) := g_package||'apply_transaction';
 l_txn_type                  varchar2(1);
 l_dpf_type                  varchar2(1);
 l_pei_type                  varchar2(1);
 l_update_mode               varchar2(20);
 l_dummy                     varchar2(10);
 l_ptx_rec                   pqh_position_transactions%ROWTYPE;
 l_pte_rec                   pqh_ptx_extra_info%ROWTYPE;
 l_position_id               hr_all_positions_f.position_id%TYPE;
 l_effective_start_date      hr_all_positions_f.effective_start_date%TYPE;
 l_effective_end_date        hr_all_positions_f.effective_end_date%TYPE;
 l_position_definition_id    hr_all_positions_f.position_definition_id%TYPE;
 l_name                      hr_all_positions_f.name%TYPE;
 l_object_version_number     hr_all_positions_f.object_version_number%TYPE;
 l_dpf_deployment_factor_id  per_deployment_factors.deployment_factor_id%type;
 l_dpf_object_version_number per_deployment_factors.object_version_number%type;
 l_warning                   boolean;
 l_deployment_factor_id      per_deployment_factors.deployment_factor_id%TYPE;
 l_position_extra_info_id    per_position_extra_info.position_extra_info_id%TYPE;
 p_position_id               hr_all_positions_f.position_id%TYPE;
 p_effective_start_date      hr_all_positions_f.effective_start_date%TYPE;
 l_pei_position_extra_info_id per_position_extra_info.position_extra_info_id%type;
 l_pei_object_version_number  per_position_extra_info.object_version_number%type;
l_transaction_category_id    pqh_transaction_categories.transaction_category_id%type;
l_return			varchar2(30) := 'SUCCESS';
l_seasonal_dates_present    boolean := false;
l_overlap_dates_present     boolean := false;
l_position_family_flag      boolean := false;
l_permit_extended_pay       boolean := false;
l_start_date                date;
l_availability_status_id    number;
l_res_position_id    number;
l_res_fte       number;
l_res_position_type varchar2(30);
l_res_effective_date date;
l_res_validation_start_date date;
l_res_validation_end_date  date;

CURSOR c1 IS
 select *
 from pqh_position_transactions
 where position_transaction_id = p_transaction_id;

CURSOR c2(p_position_id          IN hr_all_positions_f.position_id%TYPE,
          p_effective_date IN hr_all_positions_f.effective_start_date%TYPE) IS
  select effective_start_date, effective_end_date, object_version_number, date_effective, availability_status_id  --'X'
  from hr_all_positions_f
  where position_id = p_position_id
    and  p_effective_date
    between effective_start_date and effective_end_date ;

CURSOR c3 IS
  select *
  from pqh_ptx_extra_info
  where position_transaction_id = p_transaction_id;

CURSOR c_del_pte(p_transaction_id number, p_position_id number) IS
  select pei.position_extra_info_id, pei.object_version_number
  from per_position_extra_info pei, pqh_pte_shadow pps
  where position_id = p_position_id
    and position_transaction_id = p_transaction_id
    and pps.position_extra_info_id = pei.position_extra_info_id
    and not exists
      (select null
       from pqh_ptx_extra_info ppei
       where position_transaction_id = p_transaction_id
       and ppei.position_extra_info_id = pps.position_extra_info_id);

cursor c4 (p_position_id in hr_all_positions_f.position_id%TYPE)is
  select deployment_factor_id,object_version_number
  from per_deployment_factors
  where position_id = p_position_id;

CURSOR c5 (p_position_id in hr_all_positions_f.position_id%TYPE,
            p_information_type in per_position_extra_info.information_type%type,
            p_position_extra_info_id in
               per_position_extra_info.position_extra_info_id%type) IS
  select position_extra_info_id,object_version_number
  from per_position_extra_info
  where position_id = p_position_id
  and information_type = p_information_type
  and position_extra_info_id = p_position_extra_info_id;

/*
  CURSOR c_transaction_category is
    select transaction_category_id
    from pqh_transaction_categories
    where short_name = 'POSITION_TRANSACTION';
*/
--
cursor c_pes(p_ptx_extra_info_id number) is
select *
from pqh_pte_shadow
where ptx_extra_info_id = p_ptx_extra_info_id;
--
cursor c_dpf_df(p_position_transaction_id number) is
select *
from pqh_ptx_dpf_df
where position_transaction_id = p_position_transaction_id;
--
l_pes_rec c_pes%rowtype;
l_items_changed varchar2(10000);
l_dpf_df c_dpf_df%rowtype;
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  savepoint apply_transaction;
  /*
    Determine the transaction type i.e whether it is update transaction or
    a new transaction .
    If it is an update transactio the position_id will not be
    NULL. Alternatively if the position_id is NULL , then it is a new position
    transaction.
  */

  OPEN c1;
    FETCH c1 INTO l_ptx_rec;
  CLOSE c1;

  l_position_id := l_ptx_rec.position_id;
  l_position_definition_id := l_ptx_rec.position_definition_id;
  l_name := l_ptx_rec.name;
  --
  -- Start Position Transaction Log
  --
  pqh_process_batch_log.start_log (
             			   p_batch_id  => p_transaction_id,
                                   p_module_cd => 'POSITION_TRANSACTION' ,
                                   p_log_context => l_ptx_rec.name || ' - ' || l_ptx_rec.position_type ) ;

  --
  -- Select transaction_category_id
  --
  l_transaction_category_id := l_ptx_rec.wf_transaction_category_id;
  --
  IF l_ptx_rec.position_id IS NULL THEN
   -- create transaction
     l_txn_type := 'C';
     l_dpf_type := 'C';
     hr_utility.set_location('Txn Type is Create '||l_proc, 6);
     --
     open c_dpf_df(p_transaction_id);
     fetch c_dpf_df into l_dpf_df;
     close c_dpf_df;
    --
  ELSE
    -- update transaction
     l_txn_type := 'U';
     hr_utility.set_location('Txn Type is Update '||l_proc, 7);
    --  call_refresh before applying Update Transaction;
    pqh_ptx_utl.refresh_ptx(
     p_transaction_category_id  => l_transaction_category_id,
     p_position_transaction_id  => p_transaction_id,
     p_items_changed            => l_items_changed);
     open c4(l_ptx_rec.position_id);
     fetch c4 into l_dpf_deployment_factor_id, l_dpf_object_version_number;
     close c4;
     --
     open c_dpf_df(p_transaction_id);
     fetch c_dpf_df into l_dpf_df;
     close c_dpf_df;
     --
     if l_dpf_deployment_factor_id is null then
          l_dpf_type := 'C';
     else
          l_dpf_type := 'U';
     end if;
     l_dummy := null;
  END IF;

  /*
     Determine if UPDATE mode or CORRECTION mode in case of Update txn type
     This is done as follows :
     If for the action_date in the PTX table there exists a row in
     hr_all_positions_f
     table for the same position_id and effective_start_date = action_date
     of PTX , it will
     be correction , else it will be update
  */

   IF l_txn_type = 'U' THEN

  --
  --  TABLE : per_position_extra_info
  --
  -- For update transaction delete the position extra info if deleted from ptx extra info
  if l_position_id is not null then
    for r_del_pte in c_del_pte(p_transaction_id , l_position_id) loop
          hr_position_extra_info_api.delete_position_extra_info
          (p_validate                      =>  false
          ,p_position_extra_info_id        =>  r_del_pte.position_extra_info_id
          ,p_object_version_number         =>  r_del_pte.object_version_number
          );
    end loop;
  end if;

     OPEN c2(p_position_id          => l_ptx_rec.position_id,
             p_effective_date => l_ptx_rec.action_date);

       FETCH c2 INTO l_effective_start_date, l_effective_end_date,
                     l_object_version_number, l_start_date, l_availability_status_id;

     CLOSE c2;

     IF (l_effective_start_date = l_ptx_rec.action_date)  or (nvl(l_start_date,l_ptx_rec.date_effective) <> l_ptx_rec.date_effective) THEN
       -- record exists so its correction
        l_update_mode := 'CORRECTION';
        hr_utility.set_location(' Correction Mode '||l_proc, 10);
     ELSIF (l_effective_end_date = to_date('4712/12/31','RRRR/MM/DD')) THEN
        -- no record exists so its update
        l_update_mode := 'UPDATE';
        hr_utility.set_location(' Update Mode '||l_proc, 11);
     ELSE
        l_update_mode := 'UPDATE_CHANGE_INSERT';
        hr_utility.set_location(' Update Change Insert Mode '||l_proc, 11);
     END IF; -- for updt mode

  END IF; -- for txn_type as update

  /*
   Depending on the txn type call the respective APIs
  */

  --
  --  TABLE : hr_all_positions_f AND per_positions ( Common API )
  --

   IF l_txn_type = 'C' THEN
     hr_utility.set_location('Calling create_dt_position '||l_proc, 15);
     --
     -- call create API
     --
  hr_position_api.create_position
    (p_position_id                   =>  l_position_id
    ,p_effective_start_date          =>  l_effective_start_date
    ,p_effective_end_date            =>  l_effective_end_date
    ,p_position_definition_id        =>  l_position_definition_id
    ,p_name                          =>  l_name
    ,p_object_version_number         =>  l_object_version_number
    ,p_job_id                        =>  l_ptx_rec.job_id
    ,p_organization_id               =>  l_ptx_rec.organization_id
    ,p_effective_date                =>  l_ptx_rec.action_date
    ,p_date_effective                =>  l_ptx_rec.date_effective
    ,p_availability_status_id        =>  l_ptx_rec.availability_status_id
    ,p_business_group_id             =>  l_ptx_rec.business_group_id
    ,p_entry_step_id                 =>  l_ptx_rec.entry_step_id
    ,p_entry_grade_rule_id           =>  l_ptx_rec.entry_grade_rule_id
    ,p_location_id                   =>  l_ptx_rec.location_id
    ,p_pay_freq_payroll_id           =>  l_ptx_rec.pay_freq_payroll_id
    ,p_position_transaction_id       =>  l_ptx_rec.position_transaction_id
    ,p_prior_position_id             =>  l_ptx_rec.prior_position_id
    ,p_relief_position_id            =>  l_ptx_rec.relief_position_id
    ,p_entry_grade_id                =>  l_ptx_rec.entry_grade_id
    ,p_successor_position_id         =>  l_ptx_rec.successor_position_id
    ,p_supervisor_position_id        =>  l_ptx_rec.supervisor_position_id
    ,p_amendment_date                =>  l_ptx_rec.amendment_date
    ,p_amendment_recommendation      =>  l_ptx_rec.amendment_recommendation
    ,p_amendment_ref_number          =>  l_ptx_rec.amendment_ref_number
    ,p_bargaining_unit_cd            =>  l_ptx_rec.bargaining_unit_cd
    ,p_comments                      =>  l_ptx_rec.comments
    ,p_current_job_prop_end_date     =>  l_ptx_rec.current_job_prop_end_date
    ,p_current_org_prop_end_date     =>  l_ptx_rec.current_org_prop_end_date
    ,p_avail_status_prop_end_date    =>  l_ptx_rec.avail_status_prop_end_date
    ,p_date_end                      =>  l_ptx_rec.date_end
    ,p_earliest_hire_date            =>  l_ptx_rec.earliest_hire_date
    ,p_fill_by_date                  =>  l_ptx_rec.fill_by_date
    ,p_frequency                     =>  l_ptx_rec.frequency
    ,p_fte                           =>  l_ptx_rec.fte
    ,p_max_persons                   =>  l_ptx_rec.max_persons
    ,p_overlap_period                =>  l_ptx_rec.overlap_period
    ,p_overlap_unit_cd               =>  l_ptx_rec.overlap_unit_cd
    ,p_pay_term_end_day_cd           =>  l_ptx_rec.pay_term_end_day_cd
    ,p_pay_term_end_month_cd         =>  l_ptx_rec.pay_term_end_month_cd
    ,p_permanent_temporary_flag      =>  l_ptx_rec.permanent_temporary_flag
    ,p_permit_recruitment_flag       =>  l_ptx_rec.permit_recruitment_flag
    ,p_position_type                 =>  l_ptx_rec.position_type
    ,p_posting_description           =>  l_ptx_rec.posting_description
    ,p_probation_period              =>  l_ptx_rec.probation_period
    ,p_probation_period_unit_cd      =>  l_ptx_rec.probation_period_unit_cd
    ,p_replacement_required_flag     =>  l_ptx_rec.replacement_required_flag
    ,p_review_flag                   =>  'N'  --l_ptx_rec.review_flag
    ,p_seasonal_flag                 =>  l_ptx_rec.seasonal_flag
    ,p_security_requirements         =>  l_ptx_rec.security_requirements
    ,p_status                        =>  NULL
    ,p_term_start_day_cd             =>  l_ptx_rec.term_start_day_cd
    ,p_term_start_month_cd           =>  l_ptx_rec.term_start_month_cd
    ,p_time_normal_finish            =>  l_ptx_rec.time_normal_finish
    ,p_time_normal_start             =>  l_ptx_rec.time_normal_start
    ,p_update_source_cd              =>  NULL
    ,p_working_hours                 =>  l_ptx_rec.working_hours
    ,p_works_council_approval_flag   =>  l_ptx_rec.works_council_approval_flag
    ,p_work_period_type_cd           =>  l_ptx_rec.work_period_type_cd
    ,p_work_term_end_day_cd          =>  l_ptx_rec.work_term_end_day_cd
    ,p_work_term_end_month_cd        =>  l_ptx_rec.work_term_end_month_cd
    ,p_concat_segments               =>  l_ptx_rec.name
    ,p_proposed_fte_for_layoff       =>  l_ptx_rec.proposed_fte_for_layoff
    ,p_proposed_date_for_layoff      =>  l_ptx_rec.proposed_date_for_layoff
    ,p_pay_basis_id                  =>  l_ptx_rec.pay_basis_id
    ,p_supervisor_id                 =>  l_ptx_rec.supervisor_id
         ,p_information1                      =>  l_ptx_rec.information1
         ,p_information2                      =>  l_ptx_rec.information2
         ,p_information3                      =>  l_ptx_rec.information3
         ,p_information4                      =>  l_ptx_rec.information4
         ,p_information5                      =>  l_ptx_rec.information5
         ,p_information6                      =>  l_ptx_rec.information6
         ,p_information7                      =>  l_ptx_rec.information7
         ,p_information8                      =>  l_ptx_rec.information8
         ,p_information9                      =>  l_ptx_rec.information9
         ,p_information10                     =>  l_ptx_rec.information10
         ,p_information11                     =>  l_ptx_rec.information11
         ,p_information12                     =>  l_ptx_rec.information12
         ,p_information13                     =>  l_ptx_rec.information13
         ,p_information14                     =>  l_ptx_rec.information14
         ,p_information15                     =>  l_ptx_rec.information15
         ,p_information16                     =>  l_ptx_rec.information16
         ,p_information17                     =>  l_ptx_rec.information17
         ,p_information18                     =>  l_ptx_rec.information18
         ,p_information19                     =>  l_ptx_rec.information19
         ,p_information20                     =>  l_ptx_rec.information20
         ,p_information21                     =>  l_ptx_rec.information21
         ,p_information22                     =>  l_ptx_rec.information22
         ,p_information23                     =>  l_ptx_rec.information24
         ,p_information24                     =>  l_ptx_rec.information23
         ,p_information25                     =>  l_ptx_rec.information25
         ,p_information26                     =>  l_ptx_rec.information26
         ,p_information27                     =>  l_ptx_rec.information27
         ,p_information28                     =>  l_ptx_rec.information28
         ,p_information29                     =>  l_ptx_rec.information29
         ,p_information30                     =>  l_ptx_rec.information30
         ,p_information_category              =>  l_ptx_rec.information_category
         ,p_attribute1                        =>  l_ptx_rec.attribute1
         ,p_attribute2                        =>  l_ptx_rec.attribute2
         ,p_attribute3                        =>  l_ptx_rec.attribute3
         ,p_attribute4                        =>  l_ptx_rec.attribute4
         ,p_attribute5                        =>  l_ptx_rec.attribute5
         ,p_attribute6                        =>  l_ptx_rec.attribute6
         ,p_attribute7                        =>  l_ptx_rec.attribute7
         ,p_attribute8                        =>  l_ptx_rec.attribute8
         ,p_attribute9                        =>  l_ptx_rec.attribute9
         ,p_attribute10                       =>  l_ptx_rec.attribute10
         ,p_attribute11                       =>  l_ptx_rec.attribute11
         ,p_attribute12                       =>  l_ptx_rec.attribute12
         ,p_attribute13                       =>  l_ptx_rec.attribute13
         ,p_attribute14                       =>  l_ptx_rec.attribute14
         ,p_attribute15                       =>  l_ptx_rec.attribute15
         ,p_attribute16                       =>  l_ptx_rec.attribute16
         ,p_attribute17                       =>  l_ptx_rec.attribute17
         ,p_attribute18                       =>  l_ptx_rec.attribute18
         ,p_attribute19                       =>  l_ptx_rec.attribute19
         ,p_attribute20                       =>  l_ptx_rec.attribute20
         ,p_attribute21                       =>  l_ptx_rec.attribute21
         ,p_attribute22                       =>  l_ptx_rec.attribute22
         ,p_attribute23                       =>  l_ptx_rec.attribute23
         ,p_attribute24                       =>  l_ptx_rec.attribute24
         ,p_attribute25                       =>  l_ptx_rec.attribute25
         ,p_attribute26                       =>  l_ptx_rec.attribute26
         ,p_attribute27                       =>  l_ptx_rec.attribute27
         ,p_attribute28                       =>  l_ptx_rec.attribute28
         ,p_attribute29                       =>  l_ptx_rec.attribute29
         ,p_attribute30                       =>  l_ptx_rec.attribute30
         ,p_attribute_category                =>  l_ptx_rec.attribute_category
    ) ;
    --
    hr_utility.set_location('POSITION ID is : '||l_position_id, 19);
    --
    update_pos_tran(p_position_transaction_id 	=> l_ptx_rec.position_transaction_id,
                    p_position_id             	=> l_position_id,
                    p_job_id                    => l_ptx_rec.job_id,
                    p_organization_id           => l_ptx_rec.organization_id,
                    p_effective_date	    	=> l_ptx_rec.action_date);
    --
    --
       --rpullare  Bug#2349744

          UPDATE FND_ATTACHED_DOCUMENTS
            SET PK1_VALUE = l_position_id,
                ENTITY_NAME = 'PER_POSITIONS'
                WHERE  PK1_VALUE = p_transaction_id
                 AND ENTITY_NAME = 'PQH_POSITION_TRANSACTIONS_V';



    --rpullare
    --
    hr_utility.set_location('Update Budget Positions', 20);
     --
   ELSE
     hr_utility.set_location('Calling update_dt_position '||l_proc, 20);
     --
     -- call update API
     --

     hr_position_api.update_position
       (p_validate                       =>  false
       ,p_position_id                    =>  l_ptx_rec.position_id
       ,p_effective_start_date           =>  l_effective_start_date
       ,p_effective_end_date             =>  l_effective_end_date
       ,p_position_definition_id         =>  l_position_definition_id
       ,p_valid_grades_changed_warning   =>  l_warning
       ,p_name                           =>  l_name
--       ,p_availability_status_id         =>  l_availability_status_id
       ,p_entry_step_id                  =>  l_ptx_rec.entry_step_id
       ,p_entry_grade_rule_id            =>  l_ptx_rec.entry_grade_rule_id
       ,p_location_id                    =>  l_ptx_rec.location_id
       ,p_pay_freq_payroll_id            =>  l_ptx_rec.pay_freq_payroll_id
       ,p_position_transaction_id        =>  l_ptx_rec.position_transaction_id
       ,p_prior_position_id              =>  l_ptx_rec.prior_position_id
       ,p_relief_position_id             =>  l_ptx_rec.relief_position_id
       ,p_entry_grade_id                 =>  l_ptx_rec.entry_grade_id
       ,p_successor_position_id          =>  l_ptx_rec.successor_position_id
       ,p_supervisor_position_id         =>  l_ptx_rec.supervisor_position_id
       ,p_amendment_date                 =>  l_ptx_rec.amendment_date
       ,p_amendment_recommendation       =>  l_ptx_rec.amendment_recommendation
       ,p_amendment_ref_number           =>  l_ptx_rec.amendment_ref_number
       ,p_bargaining_unit_cd             =>  l_ptx_rec.bargaining_unit_cd
       ,p_comments                       =>  l_ptx_rec.comments
       ,p_current_job_prop_end_date      =>  l_ptx_rec.current_job_prop_end_date
       ,p_current_org_prop_end_date      =>  l_ptx_rec.current_org_prop_end_date
       ,p_avail_status_prop_end_date     =>  l_ptx_rec.avail_status_prop_end_date
       ,p_date_effective                 =>  l_ptx_rec.date_effective
       ,p_date_end                       =>  l_ptx_rec.date_end
       ,p_earliest_hire_date             =>  l_ptx_rec.earliest_hire_date
       ,p_fill_by_date                   =>  l_ptx_rec.fill_by_date
       ,p_frequency                      =>  l_ptx_rec.frequency
       ,p_fte                            =>  l_ptx_rec.fte
       ,p_max_persons                    =>  l_ptx_rec.max_persons
       ,p_overlap_period                 =>  l_ptx_rec.overlap_period
       ,p_overlap_unit_cd                =>  l_ptx_rec.overlap_unit_cd
       ,p_pay_term_end_day_cd            =>  l_ptx_rec.pay_term_end_day_cd
       ,p_pay_term_end_month_cd          =>  l_ptx_rec.pay_term_end_month_cd
       ,p_permanent_temporary_flag       =>  l_ptx_rec.permanent_temporary_flag
       ,p_permit_recruitment_flag        =>  l_ptx_rec.permit_recruitment_flag
       ,p_position_type                  =>  l_ptx_rec.position_type
       ,p_posting_description            =>  l_ptx_rec.posting_description
       ,p_probation_period               =>  l_ptx_rec.probation_period
       ,p_probation_period_unit_cd       =>  l_ptx_rec.probation_period_unit_cd
       ,p_replacement_required_flag      =>  l_ptx_rec.replacement_required_flag
       ,p_review_flag                    =>  'N'   --l_ptx_rec.review_flag
       ,p_seasonal_flag                  =>  l_ptx_rec.seasonal_flag
       ,p_security_requirements          =>  l_ptx_rec.security_requirements
       ,p_status                         =>  NULL
       ,p_term_start_day_cd              =>  l_ptx_rec.term_start_day_cd
       ,p_term_start_month_cd            =>  l_ptx_rec.term_start_month_cd
       ,p_time_normal_finish             =>  l_ptx_rec.time_normal_finish
       ,p_time_normal_start              =>  l_ptx_rec.time_normal_start
       ,p_update_source_cd               =>  NULL
       ,p_working_hours                  =>  l_ptx_rec.working_hours
       ,p_works_council_approval_flag    =>  l_ptx_rec.works_council_approval_flag
       ,p_work_period_type_cd            =>  l_ptx_rec.work_period_type_cd
       ,p_work_term_end_day_cd           =>  l_ptx_rec.work_term_end_day_cd
       ,p_work_term_end_month_cd         =>  l_ptx_rec.work_term_end_month_cd
       ,p_concat_segments                =>  l_ptx_rec.name
       ,p_object_version_number          =>  l_object_version_number
       ,p_effective_date                 =>  l_ptx_rec.action_date
       ,p_datetrack_mode                 =>  l_update_mode
       ,p_proposed_fte_for_layoff        =>  l_ptx_rec.proposed_fte_for_layoff
       ,p_proposed_date_for_layoff       =>  l_ptx_rec.proposed_date_for_layoff
       ,p_pay_basis_id                   =>  l_ptx_rec.pay_basis_id
       ,p_supervisor_id                  =>  l_ptx_rec.supervisor_id
       ,p_information1                      =>  l_ptx_rec.information1
       ,p_information2                      =>  l_ptx_rec.information2
       ,p_information3                      =>  l_ptx_rec.information3
       ,p_information4                      =>  l_ptx_rec.information4
       ,p_information5                      =>  l_ptx_rec.information5
       ,p_information6                      =>  l_ptx_rec.information6
       ,p_information7                      =>  l_ptx_rec.information7
       ,p_information8                      =>  l_ptx_rec.information8
       ,p_information9                      =>  l_ptx_rec.information9
       ,p_information10                     =>  l_ptx_rec.information10
       ,p_information11                     =>  l_ptx_rec.information11
       ,p_information12                     =>  l_ptx_rec.information12
       ,p_information13                     =>  l_ptx_rec.information13
       ,p_information14                     =>  l_ptx_rec.information14
       ,p_information15                     =>  l_ptx_rec.information15
       ,p_information16                     =>  l_ptx_rec.information16
       ,p_information17                     =>  l_ptx_rec.information17
       ,p_information18                     =>  l_ptx_rec.information18
       ,p_information19                     =>  l_ptx_rec.information19
       ,p_information20                     =>  l_ptx_rec.information20
       ,p_information21                     =>  l_ptx_rec.information21
       ,p_information22                     =>  l_ptx_rec.information22
       ,p_information23                     =>  l_ptx_rec.information24
       ,p_information24                     =>  l_ptx_rec.information23
       ,p_information25                     =>  l_ptx_rec.information25
       ,p_information26                     =>  l_ptx_rec.information26
       ,p_information27                     =>  l_ptx_rec.information27
       ,p_information28                     =>  l_ptx_rec.information28
       ,p_information29                     =>  l_ptx_rec.information29
       ,p_information30                     =>  l_ptx_rec.information30
       ,p_information_category              =>  l_ptx_rec.information_category
       ,p_attribute1                        =>  l_ptx_rec.attribute1
       ,p_attribute2                        =>  l_ptx_rec.attribute2
       ,p_attribute3                        =>  l_ptx_rec.attribute3
       ,p_attribute4                        =>  l_ptx_rec.attribute4
       ,p_attribute5                        =>  l_ptx_rec.attribute5
       ,p_attribute6                        =>  l_ptx_rec.attribute6
       ,p_attribute7                        =>  l_ptx_rec.attribute7
       ,p_attribute8                        =>  l_ptx_rec.attribute8
       ,p_attribute9                        =>  l_ptx_rec.attribute9
       ,p_attribute10                       =>  l_ptx_rec.attribute10
       ,p_attribute11                       =>  l_ptx_rec.attribute11
       ,p_attribute12                       =>  l_ptx_rec.attribute12
       ,p_attribute13                       =>  l_ptx_rec.attribute13
       ,p_attribute14                       =>  l_ptx_rec.attribute14
       ,p_attribute15                       =>  l_ptx_rec.attribute15
       ,p_attribute16                       =>  l_ptx_rec.attribute16
       ,p_attribute17                       =>  l_ptx_rec.attribute17
       ,p_attribute18                       =>  l_ptx_rec.attribute18
       ,p_attribute19                       =>  l_ptx_rec.attribute19
       ,p_attribute20                       =>  l_ptx_rec.attribute20
       ,p_attribute21                       =>  l_ptx_rec.attribute21
       ,p_attribute22                       =>  l_ptx_rec.attribute22
       ,p_attribute23                       =>  l_ptx_rec.attribute23
       ,p_attribute24                       =>  l_ptx_rec.attribute24
       ,p_attribute25                       =>  l_ptx_rec.attribute25
       ,p_attribute26                       =>  l_ptx_rec.attribute26
       ,p_attribute27                       =>  l_ptx_rec.attribute27
       ,p_attribute28                       =>  l_ptx_rec.attribute28
       ,p_attribute29                       =>  l_ptx_rec.attribute29
       ,p_attribute30                       =>  l_ptx_rec.attribute30
       ,p_attribute_category                =>  l_ptx_rec.attribute_category
       );
     --
     l_res_position_id := l_ptx_rec.position_id;
     l_res_fte := l_ptx_rec.fte;
     l_res_position_type := l_ptx_rec.position_type;
     l_res_effective_date := l_ptx_rec.action_date;
     l_res_validation_start_date := l_effective_start_date;
     l_res_validation_end_date := l_effective_end_date;
     --
     if l_availability_status_id <> l_ptx_rec.availability_status_id then
     IF (l_effective_start_date = l_ptx_rec.action_date)  THEN
       -- record exists so its correction
        l_update_mode := 'CORRECTION';
        hr_utility.set_location(' Correction Mode '||l_proc, 10);
     ELSIF (l_effective_end_date = to_date('4712/12/31','RRRR/MM/DD')) THEN
        -- no record exists so its update
        l_update_mode := 'UPDATE';
        hr_utility.set_location(' Update Mode '||l_proc, 11);
     ELSE
        l_update_mode := 'UPDATE_CHANGE_INSERT';
        hr_utility.set_location(' Update Change Insert Mode '||l_proc, 11);
     END IF; -- for updt mode

     hr_position_api.update_position
       (p_validate                       =>  false
       ,p_position_id                    =>  l_ptx_rec.position_id
       ,p_effective_start_date           =>  l_effective_start_date
       ,p_effective_end_date             =>  l_effective_end_date
       ,p_position_definition_id         =>  l_position_definition_id
       ,p_valid_grades_changed_warning   =>  l_warning
       ,p_name                           =>  l_name
       ,p_availability_status_id         =>  l_ptx_rec.availability_status_id
       ,p_entry_step_id                  =>  l_ptx_rec.entry_step_id
       ,p_entry_grade_rule_id            =>  l_ptx_rec.entry_grade_rule_id
       ,p_location_id                    =>  l_ptx_rec.location_id
       ,p_pay_freq_payroll_id            =>  l_ptx_rec.pay_freq_payroll_id
       ,p_position_transaction_id        =>  l_ptx_rec.position_transaction_id
       ,p_prior_position_id              =>  l_ptx_rec.prior_position_id
       ,p_relief_position_id             =>  l_ptx_rec.relief_position_id
       ,p_entry_grade_id                 =>  l_ptx_rec.entry_grade_id
       ,p_successor_position_id          =>  l_ptx_rec.successor_position_id
       ,p_supervisor_position_id         =>  l_ptx_rec.supervisor_position_id
       ,p_amendment_date                 =>  l_ptx_rec.amendment_date
       ,p_amendment_recommendation       =>  l_ptx_rec.amendment_recommendation
       ,p_amendment_ref_number           =>  l_ptx_rec.amendment_ref_number
       ,p_bargaining_unit_cd             =>  l_ptx_rec.bargaining_unit_cd
       ,p_comments                       =>  l_ptx_rec.comments
       ,p_current_job_prop_end_date      =>  l_ptx_rec.current_job_prop_end_date
       ,p_current_org_prop_end_date      =>  l_ptx_rec.current_org_prop_end_date
       ,p_avail_status_prop_end_date     =>  l_ptx_rec.avail_status_prop_end_date
       ,p_date_effective                 =>  l_ptx_rec.date_effective
       ,p_date_end                       =>  l_ptx_rec.date_end
       ,p_earliest_hire_date             =>  l_ptx_rec.earliest_hire_date
       ,p_fill_by_date                   =>  l_ptx_rec.fill_by_date
       ,p_frequency                      =>  l_ptx_rec.frequency
       ,p_fte                            =>  l_ptx_rec.fte
       ,p_max_persons                    =>  l_ptx_rec.max_persons
       ,p_overlap_period                 =>  l_ptx_rec.overlap_period
       ,p_overlap_unit_cd                =>  l_ptx_rec.overlap_unit_cd
       ,p_pay_term_end_day_cd            =>  l_ptx_rec.pay_term_end_day_cd
       ,p_pay_term_end_month_cd          =>  l_ptx_rec.pay_term_end_month_cd
       ,p_permanent_temporary_flag       =>  l_ptx_rec.permanent_temporary_flag
       ,p_permit_recruitment_flag        =>  l_ptx_rec.permit_recruitment_flag
       ,p_position_type                  =>  l_ptx_rec.position_type
       ,p_posting_description            =>  l_ptx_rec.posting_description
       ,p_probation_period               =>  l_ptx_rec.probation_period
       ,p_probation_period_unit_cd       =>  l_ptx_rec.probation_period_unit_cd
       ,p_replacement_required_flag      =>  l_ptx_rec.replacement_required_flag
       ,p_review_flag                    =>  'N'   --l_ptx_rec.review_flag
       ,p_seasonal_flag                  =>  l_ptx_rec.seasonal_flag
       ,p_security_requirements          =>  l_ptx_rec.security_requirements
       ,p_status                         =>  NULL
       ,p_term_start_day_cd              =>  l_ptx_rec.term_start_day_cd
       ,p_term_start_month_cd            =>  l_ptx_rec.term_start_month_cd
       ,p_time_normal_finish             =>  l_ptx_rec.time_normal_finish
       ,p_time_normal_start              =>  l_ptx_rec.time_normal_start
       ,p_update_source_cd               =>  NULL
       ,p_working_hours                  =>  l_ptx_rec.working_hours
       ,p_works_council_approval_flag    =>  l_ptx_rec.works_council_approval_flag
       ,p_work_period_type_cd            =>  l_ptx_rec.work_period_type_cd
       ,p_work_term_end_day_cd           =>  l_ptx_rec.work_term_end_day_cd
       ,p_work_term_end_month_cd         =>  l_ptx_rec.work_term_end_month_cd
       ,p_concat_segments                =>  l_ptx_rec.name
       ,p_object_version_number          =>  l_object_version_number
       ,p_effective_date                 =>  l_ptx_rec.action_date
       ,p_datetrack_mode                 =>  l_update_mode
       ,p_proposed_fte_for_layoff        =>  l_ptx_rec.proposed_fte_for_layoff
       ,p_proposed_date_for_layoff       =>  l_ptx_rec.proposed_date_for_layoff
       ,p_pay_basis_id                   =>  l_ptx_rec.pay_basis_id
       ,p_supervisor_id                  =>  l_ptx_rec.supervisor_id
       ,p_information1                      =>  l_ptx_rec.information1
       ,p_information2                      =>  l_ptx_rec.information2
       ,p_information3                      =>  l_ptx_rec.information3
       ,p_information4                      =>  l_ptx_rec.information4
       ,p_information5                      =>  l_ptx_rec.information5
       ,p_information6                      =>  l_ptx_rec.information6
       ,p_information7                      =>  l_ptx_rec.information7
       ,p_information8                      =>  l_ptx_rec.information8
       ,p_information9                      =>  l_ptx_rec.information9
       ,p_information10                     =>  l_ptx_rec.information10
       ,p_information11                     =>  l_ptx_rec.information11
       ,p_information12                     =>  l_ptx_rec.information12
       ,p_information13                     =>  l_ptx_rec.information13
       ,p_information14                     =>  l_ptx_rec.information14
       ,p_information15                     =>  l_ptx_rec.information15
       ,p_information16                     =>  l_ptx_rec.information16
       ,p_information17                     =>  l_ptx_rec.information17
       ,p_information18                     =>  l_ptx_rec.information18
       ,p_information19                     =>  l_ptx_rec.information19
       ,p_information20                     =>  l_ptx_rec.information20
       ,p_information21                     =>  l_ptx_rec.information21
       ,p_information22                     =>  l_ptx_rec.information22
       ,p_information23                     =>  l_ptx_rec.information24
       ,p_information24                     =>  l_ptx_rec.information23
       ,p_information25                     =>  l_ptx_rec.information25
       ,p_information26                     =>  l_ptx_rec.information26
       ,p_information27                     =>  l_ptx_rec.information27
       ,p_information28                     =>  l_ptx_rec.information28
       ,p_information29                     =>  l_ptx_rec.information29
       ,p_information30                     =>  l_ptx_rec.information30
       ,p_information_category              =>  l_ptx_rec.information_category
       ,p_attribute1                        =>  l_ptx_rec.attribute1
       ,p_attribute2                        =>  l_ptx_rec.attribute2
       ,p_attribute3                        =>  l_ptx_rec.attribute3
       ,p_attribute4                        =>  l_ptx_rec.attribute4
       ,p_attribute5                        =>  l_ptx_rec.attribute5
       ,p_attribute6                        =>  l_ptx_rec.attribute6
       ,p_attribute7                        =>  l_ptx_rec.attribute7
       ,p_attribute8                        =>  l_ptx_rec.attribute8
       ,p_attribute9                        =>  l_ptx_rec.attribute9
       ,p_attribute10                       =>  l_ptx_rec.attribute10
       ,p_attribute11                       =>  l_ptx_rec.attribute11
       ,p_attribute12                       =>  l_ptx_rec.attribute12
       ,p_attribute13                       =>  l_ptx_rec.attribute13
       ,p_attribute14                       =>  l_ptx_rec.attribute14
       ,p_attribute15                       =>  l_ptx_rec.attribute15
       ,p_attribute16                       =>  l_ptx_rec.attribute16
       ,p_attribute17                       =>  l_ptx_rec.attribute17
       ,p_attribute18                       =>  l_ptx_rec.attribute18
       ,p_attribute19                       =>  l_ptx_rec.attribute19
       ,p_attribute20                       =>  l_ptx_rec.attribute20
       ,p_attribute21                       =>  l_ptx_rec.attribute21
       ,p_attribute22                       =>  l_ptx_rec.attribute22
       ,p_attribute23                       =>  l_ptx_rec.attribute23
       ,p_attribute24                       =>  l_ptx_rec.attribute24
       ,p_attribute25                       =>  l_ptx_rec.attribute25
       ,p_attribute26                       =>  l_ptx_rec.attribute26
       ,p_attribute27                       =>  l_ptx_rec.attribute27
       ,p_attribute28                       =>  l_ptx_rec.attribute28
       ,p_attribute29                       =>  l_ptx_rec.attribute29
       ,p_attribute30                       =>  l_ptx_rec.attribute30
       ,p_attribute_category                =>  l_ptx_rec.attribute_category
       );
     end if;
     --
     -- assign position_id to local variable as it will be used in the next apis
     --
            l_position_id  := l_ptx_rec.position_id;
            hr_utility.set_location('POSITION ID is : '||l_position_id, 21);
    --
    --rpullare Bug#2349744

         UPDATE FND_ATTACHED_DOCUMENTS
         SET PK1_VALUE = l_ptx_rec.position_id,
             ENTITY_NAME = 'PER_POSITIONS'
            WHERE    PK1_VALUE = p_transaction_id
              AND ENTITY_NAME = 'PQH_POSITION_TRANSACTIONS_V';


   --rpullare
   --
   END IF; -- api call positions table


  --
  --  TABLE : per_deployment_factors
  --  In deployment factors , we will pass only the position_id as deployment
  --  is for a position_id OR person_id OR job_id
  --  Business Rule in per_deployment_factors :
  --  For position_id following fileds are NULL
  --  VISIT_INTERNATIONALLY, COMMENTS , EARLIEST_AVAILABLE_DATE
  --


   IF l_dpf_type = 'C' THEN
    hr_utility.set_location('Calling per_dpf_ins.ins '||l_proc, 20);

    if (hr_psf_shd.get_availability_status(l_ptx_rec.availability_status_id,
            l_ptx_rec.business_group_id) <> 'ELIMINATED') then
     --
     -- call create API
     --

     if (l_ptx_rec.work_any_country is not null
     or l_ptx_rec.work_any_location  is not null
     or l_ptx_rec.relocate_domestically is not null
     or l_ptx_rec.relocate_internationally  is not null
     or l_ptx_rec.travel_required  is not null
     or l_ptx_rec.country1  is not null
     or l_ptx_rec.country2  is not null
     or l_ptx_rec.country3  is not null
     or l_ptx_rec.work_duration  is not null
     or l_ptx_rec.work_schedule  is not null
     or l_ptx_rec.working_hours  is not null
     or l_ptx_rec.fte_capacity  is not null
     or l_ptx_rec.relocation_required  is not null
     or l_ptx_rec.passport_required  is not null
     or l_ptx_rec.location1  is not null
     or l_ptx_rec.location2  is not null
     or l_ptx_rec.other_requirements  is not null
     or l_ptx_rec.service_minimum  is not null
     ) then

     per_dpf_ins.ins
       (
       p_deployment_factor_id         =>  l_deployment_factor_id,
       p_position_id                  =>  l_position_id,
       p_business_group_id            =>  l_ptx_rec.business_group_id,
       p_work_any_country             =>  nvl(l_ptx_rec.work_any_country,'N'),
       p_work_any_location            =>  nvl(l_ptx_rec.work_any_location,'N'),
       p_relocate_domestically        =>  nvl(l_ptx_rec.relocate_domestically,'N'),
       p_relocate_internationally     =>  nvl(l_ptx_rec.relocate_internationally,'N'),
       p_travel_required              =>  nvl(l_ptx_rec.travel_required,'N'),
       p_country1                     =>  l_ptx_rec.country1,
       p_country2                     =>  l_ptx_rec.country2,
       p_country3                     =>  l_ptx_rec.country3,
       p_work_duration                =>  l_ptx_rec.work_duration,
       p_work_schedule                =>  l_ptx_rec.work_schedule,
--     p_work_hours                   =>  l_ptx_rec.working_hours,
       p_fte_capacity                 =>  l_ptx_rec.fte_capacity,
       p_relocation_required          =>  nvl(l_ptx_rec.relocation_required,'N'),
       p_passport_required            =>  nvl(l_ptx_rec.passport_required,'N'),
       p_location1                    =>  l_ptx_rec.location1,
       p_location2                    =>  l_ptx_rec.location2,
       p_location3                    =>  l_ptx_rec.location3,
       p_other_requirements           =>  l_ptx_rec.other_requirements,
       p_service_minimum              =>  l_ptx_rec.service_minimum,
       p_object_version_number        =>  l_object_version_number,
       p_effective_date               =>  l_ptx_rec.action_date
       ,p_attribute1                        =>  l_dpf_df.attribute1
       ,p_attribute2                        =>  l_dpf_df.attribute2
       ,p_attribute3                        =>  l_dpf_df.attribute3
       ,p_attribute4                        =>  l_dpf_df.attribute4
       ,p_attribute5                        =>  l_dpf_df.attribute5
       ,p_attribute6                        =>  l_dpf_df.attribute6
       ,p_attribute7                        =>  l_dpf_df.attribute7
       ,p_attribute8                        =>  l_dpf_df.attribute8
       ,p_attribute9                        =>  l_dpf_df.attribute9
       ,p_attribute10                       =>  l_dpf_df.attribute10
       ,p_attribute11                       =>  l_dpf_df.attribute11
       ,p_attribute12                       =>  l_dpf_df.attribute12
       ,p_attribute13                       =>  l_dpf_df.attribute13
       ,p_attribute14                       =>  l_dpf_df.attribute14
       ,p_attribute15                       =>  l_dpf_df.attribute15
       ,p_attribute16                       =>  l_dpf_df.attribute16
       ,p_attribute17                       =>  l_dpf_df.attribute17
       ,p_attribute18                       =>  l_dpf_df.attribute18
       ,p_attribute19                       =>  l_dpf_df.attribute19
       ,p_attribute20                       =>  l_dpf_df.attribute20
       ,p_attribute_category                =>  l_dpf_df.attribute_category
       );
     --
     end if;
    end if;
   ELSE
     hr_utility.set_location('Calling per_dpf_upd.upd '||l_proc, 25);
     --
     -- call update API
     --

     per_dpf_upd.upd
       (
       p_deployment_factor_id         =>  l_dpf_deployment_factor_id,
       p_position_id                  =>  l_position_id,
       p_business_group_id            =>  l_ptx_rec.business_group_id,
       p_work_any_country             =>  nvl(l_ptx_rec.work_any_country,'N'),
       p_work_any_location            =>  nvl(l_ptx_rec.work_any_location,'N'),
       p_relocate_domestically        =>  nvl(l_ptx_rec.relocate_domestically,'N'),
       p_relocate_internationally     =>  nvl(l_ptx_rec.relocate_internationally,'N'),
       p_travel_required              =>  nvl(l_ptx_rec.travel_required,'N'),
       p_country1                     =>  l_ptx_rec.country1,
       p_country2                     =>  l_ptx_rec.country2,
       p_country3                     =>  l_ptx_rec.country3,
       p_work_duration                =>  l_ptx_rec.work_duration,
       p_work_schedule                =>  l_ptx_rec.work_schedule,
--     p_work_hours                   =>  l_ptx_rec.working_hours,
       p_fte_capacity                 =>  l_ptx_rec.fte_capacity,
       p_relocation_required          =>  nvl(l_ptx_rec.relocation_required,'N'),
       p_passport_required            =>  nvl(l_ptx_rec.passport_required,'N'),
       p_location1                    =>  l_ptx_rec.location1,
       p_location2                    =>  l_ptx_rec.location2,
       p_location3                    =>  l_ptx_rec.location3,
       p_other_requirements           =>  l_ptx_rec.other_requirements,
       p_service_minimum              =>  l_ptx_rec.service_minimum,
       p_object_version_number        =>  l_dpf_object_version_number,
       p_effective_date               =>  l_ptx_rec.action_date
       ,p_attribute1                        =>  l_dpf_df.attribute1
       ,p_attribute2                        =>  l_dpf_df.attribute2
       ,p_attribute3                        =>  l_dpf_df.attribute3
       ,p_attribute4                        =>  l_dpf_df.attribute4
       ,p_attribute5                        =>  l_dpf_df.attribute5
       ,p_attribute6                        =>  l_dpf_df.attribute6
       ,p_attribute7                        =>  l_dpf_df.attribute7
       ,p_attribute8                        =>  l_dpf_df.attribute8
       ,p_attribute9                        =>  l_dpf_df.attribute9
       ,p_attribute10                       =>  l_dpf_df.attribute10
       ,p_attribute11                       =>  l_dpf_df.attribute11
       ,p_attribute12                       =>  l_dpf_df.attribute12
       ,p_attribute13                       =>  l_dpf_df.attribute13
       ,p_attribute14                       =>  l_dpf_df.attribute14
       ,p_attribute15                       =>  l_dpf_df.attribute15
       ,p_attribute16                       =>  l_dpf_df.attribute16
       ,p_attribute17                       =>  l_dpf_df.attribute17
       ,p_attribute18                       =>  l_dpf_df.attribute18
       ,p_attribute19                       =>  l_dpf_df.attribute19
       ,p_attribute20                       =>  l_dpf_df.attribute20
       ,p_attribute_category                =>  l_dpf_df.attribute_category
       );

       --
   END IF; -- api call per_deployment_factors


  --
  -- create/update the per_position_extra_info
  --
    OPEN c3;
    LOOP
      FETCH c3 INTO l_pte_rec;
      EXIT WHEN c3%NOTFOUND;
      l_pei_type := null;

      if l_pte_rec.position_extra_info_id is null then
          l_pei_type := 'C';
      elsif l_txn_type = 'U' then
          --
          open c_pes(l_pte_rec.ptx_extra_info_id);
          fetch c_pes into l_pes_rec;
          close c_pes;
          --
          if l_pte_rec.object_version_number > l_pes_rec.object_version_number then
            l_pei_position_extra_info_id := null;
            open c5(l_ptx_rec.position_id,l_pte_rec.information_type,l_pte_rec.position_extra_info_id);
            fetch c5 into l_pei_position_extra_info_id,l_pei_object_version_number;
            close c5;
            --
            if l_pei_position_extra_info_id is null then
              l_pei_type := 'I';
            else
              l_pei_type := 'U';
            end if;
          end if;
      end if;

       IF l_pei_type = 'I' THEN
         --
         hr_utility.set_location('Insert for pei_id '|| l_pei_position_extra_info_id
                     ||l_proc, 20);
         insert into per_position_extra_info
         (
         position_extra_info_id, position_id, information_type,
         poei_attribute_category,
         poei_attribute1, poei_attribute2, poei_attribute3, poei_attribute4, poei_attribute5,
         poei_attribute6, poei_attribute7, poei_attribute8, poei_attribute9, poei_attribute10,
         poei_attribute11, poei_attribute12, poei_attribute13, poei_attribute14, poei_attribute15,
         poei_attribute16, poei_attribute17, poei_attribute18, poei_attribute19, poei_attribute20,
         poei_information_category,
         poei_information1, poei_information2, poei_information3,
         poei_information4, poei_information5,
         poei_information6, poei_information7, poei_information8,
         poei_information9, poei_information10,
         poei_information11, poei_information12, poei_information13,
         poei_information14, poei_information15,
         poei_information16, poei_information17, poei_information18,
         poei_information19, poei_information20,
         poei_information21, poei_information22, poei_information23,
         poei_information24, poei_information25,
         poei_information26, poei_information27, poei_information28,
         poei_information29, poei_information30,
         object_version_number
         )
         values
         (
         l_pte_rec.position_extra_info_id, l_position_id, l_pte_rec.information_type,
         l_pte_rec.attribute_category,
         l_pte_rec.attribute1, l_pte_rec.attribute2, l_pte_rec.attribute3, l_pte_rec.attribute4, l_pte_rec.attribute5,
         l_pte_rec.attribute6, l_pte_rec.attribute7, l_pte_rec.attribute8, l_pte_rec.attribute9, l_pte_rec.attribute10,
         l_pte_rec.attribute11, l_pte_rec.attribute12, l_pte_rec.attribute13, l_pte_rec.attribute14, l_pte_rec.attribute15,
         l_pte_rec.attribute16, l_pte_rec.attribute17, l_pte_rec.attribute18, l_pte_rec.attribute19, l_pte_rec.attribute20,
         l_pte_rec.information_category,
         l_pte_rec.information1, l_pte_rec.information2, l_pte_rec.information3,
         l_pte_rec.information4, l_pte_rec.information5,
         l_pte_rec.information6, l_pte_rec.information7, l_pte_rec.information8,
         l_pte_rec.information9, l_pte_rec.information10,
         l_pte_rec.information11, l_pte_rec.information12, l_pte_rec.information13,
         l_pte_rec.information14, l_pte_rec.information15,
         l_pte_rec.information16, l_pte_rec.information17, l_pte_rec.information18,
         l_pte_rec.information19, l_pte_rec.information20,
         l_pte_rec.information21, l_pte_rec.information22, l_pte_rec.information23,
         l_pte_rec.information24, l_pte_rec.information25,
         l_pte_rec.information26, l_pte_rec.information27, l_pte_rec.information28,
         l_pte_rec.information29, l_pte_rec.information30,
         1
         );
         --
         hr_utility.set_location('After Insert for pei_id '|| l_pei_position_extra_info_id
                     ||l_proc, 25);
       ELSIF l_pei_type = 'C' THEN
         hr_utility.set_location('Calling create_position_extra_info.ins '
                     ||l_proc, 30);
         --
         -- call create API
         --
         hr_position_extra_info_api.create_position_extra_info
          (p_validate                      =>  false
          ,p_position_id                   =>  l_position_id
          ,p_information_type              =>  l_pte_rec.information_type
          ,p_poei_attribute_category       =>  l_pte_rec.attribute_category
          ,p_poei_attribute1               =>  l_pte_rec.attribute1
          ,p_poei_attribute2               =>  l_pte_rec.attribute2
          ,p_poei_attribute3               =>  l_pte_rec.attribute3
          ,p_poei_attribute4               =>  l_pte_rec.attribute4
          ,p_poei_attribute5               =>  l_pte_rec.attribute5
          ,p_poei_attribute6               =>  l_pte_rec.attribute6
          ,p_poei_attribute7               =>  l_pte_rec.attribute7
          ,p_poei_attribute8               =>  l_pte_rec.attribute8
          ,p_poei_attribute9               =>  l_pte_rec.attribute9
          ,p_poei_attribute10              =>  l_pte_rec.attribute10
          ,p_poei_attribute11              =>  l_pte_rec.attribute11
          ,p_poei_attribute12              =>  l_pte_rec.attribute12
          ,p_poei_attribute13              =>  l_pte_rec.attribute13
          ,p_poei_attribute14              =>  l_pte_rec.attribute14
          ,p_poei_attribute15              =>  l_pte_rec.attribute15
          ,p_poei_attribute16              =>  l_pte_rec.attribute16
          ,p_poei_attribute17              =>  l_pte_rec.attribute17
          ,p_poei_attribute18              =>  l_pte_rec.attribute18
          ,p_poei_attribute19              =>  l_pte_rec.attribute19
          ,p_poei_attribute20              =>  l_pte_rec.attribute20
          ,p_poei_information_category     =>  l_pte_rec.information_category
          ,p_poei_information1             =>  l_pte_rec.information1
          ,p_poei_information2             =>  l_pte_rec.information2
          ,p_poei_information3             =>  l_pte_rec.information3
          ,p_poei_information4             =>  l_pte_rec.information4
          ,p_poei_information5             =>  l_pte_rec.information5
          ,p_poei_information6             =>  l_pte_rec.information6
          ,p_poei_information7             =>  l_pte_rec.information7
          ,p_poei_information8             =>  l_pte_rec.information8
          ,p_poei_information9             =>  l_pte_rec.information9
          ,p_poei_information10            =>  l_pte_rec.information10
          ,p_poei_information11            =>  l_pte_rec.information11
          ,p_poei_information12            =>  l_pte_rec.information12
          ,p_poei_information13            =>  l_pte_rec.information13
          ,p_poei_information14            =>  l_pte_rec.information14
          ,p_poei_information15            =>  l_pte_rec.information15
          ,p_poei_information16            =>  l_pte_rec.information16
          ,p_poei_information17            =>  l_pte_rec.information17
          ,p_poei_information18            =>  l_pte_rec.information18
          ,p_poei_information19            =>  l_pte_rec.information19
          ,p_poei_information20            =>  l_pte_rec.information20
          ,p_poei_information21            =>  l_pte_rec.information21
          ,p_poei_information22            =>  l_pte_rec.information22
          ,p_poei_information23            =>  l_pte_rec.information23
          ,p_poei_information24            =>  l_pte_rec.information24
          ,p_poei_information25            =>  l_pte_rec.information25
          ,p_poei_information26            =>  l_pte_rec.information26
          ,p_poei_information27            =>  l_pte_rec.information27
          ,p_poei_information28            =>  l_pte_rec.information28
          ,p_poei_information29            =>  l_pte_rec.information29
          ,p_poei_information30            =>  l_pte_rec.information30
          ,p_position_extra_info_id        =>  l_position_extra_info_id
          ,p_object_version_number         =>  l_object_version_number
          );
       ELSIF l_pei_type = 'U' then
         hr_utility.set_location('Calling update_position_extra_info.upd '
                                   ||l_proc, 35);
         --
         -- call update API
         --
         hr_position_extra_info_api.update_position_extra_info
          (p_validate                      =>  false
          ,p_position_extra_info_id        =>  l_pei_position_extra_info_id
          ,p_object_version_number         =>  l_pei_object_version_number
          ,p_poei_attribute_category       =>  l_pte_rec.attribute_category
          ,p_poei_attribute1               =>  l_pte_rec.attribute1
          ,p_poei_attribute2               =>  l_pte_rec.attribute2
          ,p_poei_attribute3               =>  l_pte_rec.attribute3
          ,p_poei_attribute4               =>  l_pte_rec.attribute4
          ,p_poei_attribute5               =>  l_pte_rec.attribute5
          ,p_poei_attribute6               =>  l_pte_rec.attribute6
          ,p_poei_attribute7               =>  l_pte_rec.attribute7
          ,p_poei_attribute8               =>  l_pte_rec.attribute8
          ,p_poei_attribute9               =>  l_pte_rec.attribute9
          ,p_poei_attribute10              =>  l_pte_rec.attribute10
          ,p_poei_attribute11              =>  l_pte_rec.attribute11
          ,p_poei_attribute12              =>  l_pte_rec.attribute12
          ,p_poei_attribute13              =>  l_pte_rec.attribute13
          ,p_poei_attribute14              =>  l_pte_rec.attribute14
          ,p_poei_attribute15              =>  l_pte_rec.attribute15
          ,p_poei_attribute16              =>  l_pte_rec.attribute16
          ,p_poei_attribute17              =>  l_pte_rec.attribute17
          ,p_poei_attribute18              =>  l_pte_rec.attribute18
          ,p_poei_attribute19              =>  l_pte_rec.attribute19
          ,p_poei_attribute20              =>  l_pte_rec.attribute20
          ,p_poei_information_category     =>  l_pte_rec.information_category
          ,p_poei_information1             =>  l_pte_rec.information1
          ,p_poei_information2             =>  l_pte_rec.information2
          ,p_poei_information3             =>  l_pte_rec.information3
          ,p_poei_information4             =>  l_pte_rec.information4
          ,p_poei_information5             =>  l_pte_rec.information5
          ,p_poei_information6             =>  l_pte_rec.information6
          ,p_poei_information7             =>  l_pte_rec.information7
          ,p_poei_information8             =>  l_pte_rec.information8
          ,p_poei_information9             =>  l_pte_rec.information9
          ,p_poei_information10            =>  l_pte_rec.information10
          ,p_poei_information11            =>  l_pte_rec.information11
          ,p_poei_information12            =>  l_pte_rec.information12
          ,p_poei_information13            =>  l_pte_rec.information13
          ,p_poei_information14            =>  l_pte_rec.information14
          ,p_poei_information15            =>  l_pte_rec.information15
          ,p_poei_information16            =>  l_pte_rec.information16
          ,p_poei_information17            =>  l_pte_rec.information17
          ,p_poei_information18            =>  l_pte_rec.information18
          ,p_poei_information19            =>  l_pte_rec.information19
          ,p_poei_information20            =>  l_pte_rec.information20
          ,p_poei_information21            =>  l_pte_rec.information21
          ,p_poei_information22            =>  l_pte_rec.information22
          ,p_poei_information23            =>  l_pte_rec.information23
          ,p_poei_information24            =>  l_pte_rec.information24
          ,p_poei_information25            =>  l_pte_rec.information25
          ,p_poei_information26            =>  l_pte_rec.information26
          ,p_poei_information27            =>  l_pte_rec.information27
          ,p_poei_information28            =>  l_pte_rec.information28
          ,p_poei_information29            =>  l_pte_rec.information29
          ,p_poei_information30            =>  l_pte_rec.information30
          );
         --
       END IF; -- api call per_position_extra_info
       --
--       if l_ptx_rec.seasonal_flag = 'Y' then
       --
         if l_pte_rec.information_type = 'PER_SEASONAL' then
           l_seasonal_dates_present := true;
         end if;
       --
--       end if;
       --
       --
       --
--       if l_ptx_rec.overlap_period is not null then
       --
         if l_pte_rec.information_type = 'PER_OVERLAP' then
           l_overlap_dates_present := true;
         end if;
       --
--       end if;
       --
       --
       if l_ptx_rec.work_period_type_cd is not null then
       --
         if l_pte_rec.information_type = 'PER_FAMILY'
            and l_pte_rec.information3 in ('ACADEMIC','FACULTY') then
           l_permit_extended_pay := true;
         end if;
       --
       end if;
       --
    END LOOP;  -- for c3
    CLOSE c3;
    --
    -- Check if seasonal_flag = 'Y' then seasonal dates are entered.
    --
    if l_ptx_rec.seasonal_flag = 'Y' then
      if not l_seasonal_dates_present then
        hr_utility.set_message(8302,'PQH_ENTER_SEASONAL_DATES');
        hr_utility.raise_error;
      end if;
    else
      if l_seasonal_dates_present then
        hr_utility.set_message(800,'HR_INV_SEASONAL_FLAG');
        hr_utility.raise_error;
      end if;
    end if;
    --
    -- Check if overlap_period is not null then overlap dates are entered.
    --
    if l_ptx_rec.overlap_period is not null then
      if not l_overlap_dates_present then
        hr_utility.set_message(8302,'PQH_ENTER_OVERLAP_DATES');
        hr_utility.raise_error;
      end if;
    else
      if l_overlap_dates_present then
        hr_utility.set_message(800,'HR_INV_OVERLAP_PERIOD');
        hr_utility.raise_error;
      end if;
    end if;
/*
    --
    -- Check whether to permit extended pay
    --
    if nvl(l_ptx_rec.work_period_type_cd,'N')='Y' then
      if not l_permit_extended_pay then
        hr_utility.set_message(8302,'PQH_ENTER_VALID_POS_FAMILY');
        hr_utility.raise_error;
      end if;
    end if;
    --
*/
if ((l_res_position_id is not null or l_res_fte is not null)
     or (l_res_effective_date is not null
     or (l_res_validation_start_date is not null or l_res_validation_end_date is not null)))
then
  if (l_res_position_type = 'SHARED' or l_res_position_type = 'SINGLE') then
    pqh_ptx_utl.chk_reserved_fte
    (p_position_id               =>l_res_position_id
    ,p_fte                       =>l_res_fte
    ,p_position_type             =>l_res_position_type
    ,p_effective_date            =>l_res_effective_date
    ,p_validation_start_date     =>l_res_validation_start_date
    ,p_validation_end_date       =>l_res_validation_end_date
    );
  end if;
end if;
    --
    pqh_ptx_utl.apply_sit(p_transaction_id, l_position_id, l_txn_type);
    --
    pqh_ptx_utl.apply_ptx_budgets(l_ptx_rec.position_transaction_id);
    --
    pqh_position_transactions_api.update_position_transaction
    (
      p_validate                          =>  false
     ,p_position_transaction_id           =>  l_ptx_rec.position_transaction_id
     ,p_action_date                       =>  l_ptx_rec.action_date
     ,p_position_id                       =>  l_position_id
     ,p_availability_status_id            =>  l_ptx_rec.availability_status_id
     ,p_business_group_id                 =>  l_ptx_rec.business_group_id
     ,p_entry_step_id                     =>  l_ptx_rec.entry_step_id
     ,p_entry_grade_rule_id               =>  l_ptx_rec.entry_grade_rule_id
     ,p_job_id                            =>  l_ptx_rec.job_id
     ,p_location_id                       =>  l_ptx_rec.location_id
     ,p_organization_id                   =>  l_ptx_rec.organization_id
     ,p_pay_freq_payroll_id               =>  l_ptx_rec.pay_freq_payroll_id
     ,p_position_definition_id            =>  l_ptx_rec.position_definition_id
     ,p_prior_position_id                 =>  l_ptx_rec.prior_position_id
     ,p_relief_position_id                =>  l_ptx_rec.relief_position_id
     ,p_entry_grade_id                    =>  l_ptx_rec.entry_grade_id
     ,p_successor_position_id             =>  l_ptx_rec.successor_position_id
     ,p_supervisor_position_id            =>  l_ptx_rec.supervisor_position_id
     ,p_amendment_date                    =>  l_ptx_rec.amendment_date
     ,p_amendment_recommendation          =>  l_ptx_rec.amendment_recommendation
     ,p_amendment_ref_number              =>  l_ptx_rec.amendment_ref_number
     ,p_avail_status_prop_end_date        =>  l_ptx_rec.avail_status_prop_end_date
     ,p_bargaining_unit_cd                =>  l_ptx_rec.bargaining_unit_cd
     ,p_comments                          =>  l_ptx_rec.comments
     ,p_country1                          =>  l_ptx_rec.country1
     ,p_country2                          =>  l_ptx_rec.country2
     ,p_country3                          =>  l_ptx_rec.country3
     ,p_current_job_prop_end_date         =>  l_ptx_rec.current_job_prop_end_date
     ,p_current_org_prop_end_date         =>  l_ptx_rec.current_org_prop_end_date
     ,p_date_effective                    =>  l_ptx_rec.date_effective
     --,p_date_end                          =>  l_ptx_rec.date_end
     ,p_earliest_hire_date                =>  l_ptx_rec.earliest_hire_date
     ,p_fill_by_date                      =>  l_ptx_rec.fill_by_date
     ,p_frequency                         =>  l_ptx_rec.frequency
     ,p_fte                               =>  l_ptx_rec.fte
     ,p_location1                         =>  l_ptx_rec.location1
     ,p_location2                         =>  l_ptx_rec.location2
     ,p_location3                         =>  l_ptx_rec.location3
     ,p_max_persons                       =>  l_ptx_rec.max_persons
     ,p_name                              =>  l_ptx_rec.name
     ,p_other_requirements                =>  l_ptx_rec.other_requirements
     ,p_overlap_period                    =>  l_ptx_rec.overlap_period
     ,p_overlap_unit_cd                   =>  l_ptx_rec.overlap_unit_cd
     ,p_passport_required                 =>  l_ptx_rec.passport_required
     ,p_pay_term_end_day_cd               =>  l_ptx_rec.pay_term_end_day_cd
     ,p_pay_term_end_month_cd             =>  l_ptx_rec.pay_term_end_month_cd
     ,p_permanent_temporary_flag          =>  l_ptx_rec.permanent_temporary_flag
     ,p_permit_recruitment_flag           =>  l_ptx_rec.permit_recruitment_flag
     ,p_position_type                     =>  l_ptx_rec.position_type
     ,p_posting_description               =>  l_ptx_rec.posting_description
     ,p_probation_period                  =>  l_ptx_rec.probation_period
     ,p_probation_period_unit_cd          =>  l_ptx_rec.probation_period_unit_cd
     ,p_relocate_domestically             =>  l_ptx_rec.relocate_domestically
     ,p_relocate_internationally          =>  l_ptx_rec.relocate_internationally
     ,p_replacement_required_flag         =>  l_ptx_rec.replacement_required_flag
     ,p_review_flag                       =>  'N'  --l_ptx_rec.review_flag
     ,p_seasonal_flag                     =>  l_ptx_rec.seasonal_flag
     ,p_security_requirements             =>  l_ptx_rec.security_requirements
     ,p_service_minimum                   =>  l_ptx_rec.service_minimum
     ,p_term_start_day_cd                 =>  l_ptx_rec.term_start_day_cd
     ,p_term_start_month_cd               =>  l_ptx_rec.term_start_month_cd
     ,p_time_normal_finish                =>  l_ptx_rec.time_normal_finish
     ,p_time_normal_start                 =>  l_ptx_rec.time_normal_start
     ,p_transaction_status                =>  'APPLIED'
     ,p_travel_required                   =>  l_ptx_rec.travel_required
     ,p_working_hours                     =>  l_ptx_rec.working_hours
     ,p_works_council_approval_flag       =>  l_ptx_rec.works_council_approval_flag
     ,p_work_any_country                  =>  l_ptx_rec.work_any_country
     ,p_work_any_location                 =>  l_ptx_rec.work_any_location
     ,p_work_period_type_cd               =>  l_ptx_rec.work_period_type_cd
     ,p_work_schedule                     =>  l_ptx_rec.work_schedule
     ,p_work_duration                     =>  l_ptx_rec.work_duration
     ,p_work_term_end_day_cd              =>  l_ptx_rec.work_term_end_day_cd
     ,p_work_term_end_month_cd            =>  l_ptx_rec.work_term_end_month_cd
     ,p_proposed_fte_for_layoff           =>  l_ptx_rec.proposed_fte_for_layoff
     ,p_proposed_date_for_layoff          =>  l_ptx_rec.proposed_date_for_layoff
     ,p_information1                      =>  l_ptx_rec.information1
     ,p_information2                      =>  l_ptx_rec.information2
     ,p_information3                      =>  l_ptx_rec.information3
     ,p_information4                      =>  l_ptx_rec.information4
     ,p_information5                      =>  l_ptx_rec.information5
     ,p_information6                      =>  l_ptx_rec.information6
     ,p_information7                      =>  l_ptx_rec.information7
     ,p_information8                      =>  l_ptx_rec.information8
     ,p_information9                      =>  l_ptx_rec.information9
     ,p_information10                     =>  l_ptx_rec.information10
     ,p_information11                     =>  l_ptx_rec.information11
     ,p_information12                     =>  l_ptx_rec.information12
     ,p_information13                     =>  l_ptx_rec.information13
     ,p_information14                     =>  l_ptx_rec.information14
     ,p_information15                     =>  l_ptx_rec.information15
     ,p_information16                     =>  l_ptx_rec.information16
     ,p_information17                     =>  l_ptx_rec.information17
     ,p_information18                     =>  l_ptx_rec.information18
     ,p_information19                     =>  l_ptx_rec.information19
     ,p_information20                     =>  l_ptx_rec.information20
     ,p_information21                     =>  l_ptx_rec.information21
     ,p_information22                     =>  l_ptx_rec.information22
     ,p_information23                     =>  l_ptx_rec.information24
     ,p_information24                     =>  l_ptx_rec.information23
     ,p_information25                     =>  l_ptx_rec.information25
     ,p_information26                     =>  l_ptx_rec.information26
     ,p_information27                     =>  l_ptx_rec.information27
     ,p_information28                     =>  l_ptx_rec.information28
     ,p_information29                     =>  l_ptx_rec.information29
     ,p_information30                     =>  l_ptx_rec.information30
     ,p_information_category              =>  l_ptx_rec.information_category
     ,p_attribute1                        =>  l_ptx_rec.attribute1
     ,p_attribute2                        =>  l_ptx_rec.attribute2
     ,p_attribute3                        =>  l_ptx_rec.attribute3
     ,p_attribute4                        =>  l_ptx_rec.attribute4
     ,p_attribute5                        =>  l_ptx_rec.attribute5
     ,p_attribute6                        =>  l_ptx_rec.attribute6
     ,p_attribute7                        =>  l_ptx_rec.attribute7
     ,p_attribute8                        =>  l_ptx_rec.attribute8
     ,p_attribute9                        =>  l_ptx_rec.attribute9
     ,p_attribute10                       =>  l_ptx_rec.attribute10
     ,p_attribute11                       =>  l_ptx_rec.attribute11
     ,p_attribute12                       =>  l_ptx_rec.attribute12
     ,p_attribute13                       =>  l_ptx_rec.attribute13
     ,p_attribute14                       =>  l_ptx_rec.attribute14
     ,p_attribute15                       =>  l_ptx_rec.attribute15
     ,p_attribute16                       =>  l_ptx_rec.attribute16
     ,p_attribute17                       =>  l_ptx_rec.attribute17
     ,p_attribute18                       =>  l_ptx_rec.attribute18
     ,p_attribute19                       =>  l_ptx_rec.attribute19
     ,p_attribute20                       =>  l_ptx_rec.attribute20
     ,p_attribute21                       =>  l_ptx_rec.attribute21
     ,p_attribute22                       =>  l_ptx_rec.attribute22
     ,p_attribute23                       =>  l_ptx_rec.attribute23
     ,p_attribute24                       =>  l_ptx_rec.attribute24
     ,p_attribute25                       =>  l_ptx_rec.attribute25
     ,p_attribute26                       =>  l_ptx_rec.attribute26
     ,p_attribute27                       =>  l_ptx_rec.attribute27
     ,p_attribute28                       =>  l_ptx_rec.attribute28
     ,p_attribute29                       =>  l_ptx_rec.attribute29
     ,p_attribute30                       =>  l_ptx_rec.attribute30
     ,p_attribute_category                =>  l_ptx_rec.attribute_category
     ,p_object_version_number             =>  l_ptx_rec.object_version_number
     ,p_effective_date                    =>  l_ptx_rec.action_date
     ,p_pay_basis_id                      =>  l_ptx_rec.pay_basis_id
     ,p_supervisor_id                     =>  l_ptx_rec.supervisor_id
     ,p_wf_transaction_category_id	  =>  l_ptx_rec.wf_transaction_category_id
    );
    --
    log_warnings(p_transaction_id);
    --
    pqh_process_batch_log.end_log ;
    --
    hr_utility.set_location('Leaving:'||l_proc, 1000);
    return(l_return);
    --
EXCEPTION
      WHEN OTHERS THEN
        begin
	  --
          pqh_process_batch_log.set_context_level (
             				    p_txn_id             => p_transaction_id,
                                            p_txn_table_route_id => null,
                                            p_level              => 1,
                                            p_log_context        => 'ERROR');
   	  --
   	  pqh_process_batch_log.insert_log ( p_message_type_cd => 'ERROR',
                                      p_message_text    => SQLERRM );
          --
          log_warnings(p_transaction_id);
          --
   	  pqh_process_batch_log.end_log ;
        end;
        --
	rollback to apply_transaction;
	--
        --
	if PQH_APPLY_BUDGET.get_txn_state (
  		p_transaction_category_id => l_transaction_category_id,
  		p_action_date 		  => l_ptx_rec.action_date
		) = 'D'
	then
        pqh_position_transactions_api.update_position_transaction
        (
          p_validate                          =>  false
         ,p_position_transaction_id           =>  l_ptx_rec.position_transaction_id
         ,p_action_date                       =>  l_ptx_rec.action_date
         ,p_position_id                       =>  l_ptx_rec.position_id
         ,p_availability_status_id            =>  l_ptx_rec.availability_status_id
         ,p_business_group_id                 =>  l_ptx_rec.business_group_id
         ,p_entry_step_id                     =>  l_ptx_rec.entry_step_id
         ,p_entry_grade_rule_id               =>  l_ptx_rec.entry_grade_rule_id
         ,p_job_id                            =>  l_ptx_rec.job_id
         ,p_location_id                       =>  l_ptx_rec.location_id
         ,p_organization_id                   =>  l_ptx_rec.organization_id
         ,p_pay_freq_payroll_id               =>  l_ptx_rec.pay_freq_payroll_id
         ,p_position_definition_id            =>  l_ptx_rec.position_definition_id
         ,p_prior_position_id                 =>  l_ptx_rec.prior_position_id
         ,p_relief_position_id                =>  l_ptx_rec.relief_position_id
         ,p_entry_grade_id                    =>  l_ptx_rec.entry_grade_id
         ,p_successor_position_id             =>  l_ptx_rec.successor_position_id
         ,p_supervisor_position_id            =>  l_ptx_rec.supervisor_position_id
         ,p_amendment_date                    =>  l_ptx_rec.amendment_date
         ,p_amendment_recommendation          =>  l_ptx_rec.amendment_recommendation
         ,p_amendment_ref_number              =>  l_ptx_rec.amendment_ref_number
         ,p_avail_status_prop_end_date        =>  l_ptx_rec.avail_status_prop_end_date
         ,p_bargaining_unit_cd                =>  l_ptx_rec.bargaining_unit_cd
         ,p_comments                          =>  l_ptx_rec.comments
         ,p_country1                          =>  l_ptx_rec.country1
         ,p_country2                          =>  l_ptx_rec.country2
         ,p_country3                          =>  l_ptx_rec.country3
         ,p_current_job_prop_end_date         =>  l_ptx_rec.current_job_prop_end_date
         ,p_current_org_prop_end_date         =>  l_ptx_rec.current_org_prop_end_date
         ,p_date_effective                    =>  l_ptx_rec.date_effective
         ,p_date_end                          =>  l_ptx_rec.date_end
         ,p_earliest_hire_date                =>  l_ptx_rec.earliest_hire_date
         ,p_fill_by_date                      =>  l_ptx_rec.fill_by_date
         ,p_frequency                         =>  l_ptx_rec.frequency
         ,p_fte                               =>  l_ptx_rec.fte
         ,p_location1                         =>  l_ptx_rec.location1
         ,p_location2                         =>  l_ptx_rec.location2
         ,p_location3                         =>  l_ptx_rec.location3
         ,p_max_persons                       =>  l_ptx_rec.max_persons
         ,p_name                              =>  l_ptx_rec.name
         ,p_other_requirements                =>  l_ptx_rec.other_requirements
         ,p_overlap_period                    =>  l_ptx_rec.overlap_period
         ,p_overlap_unit_cd                   =>  l_ptx_rec.overlap_unit_cd
         ,p_passport_required                 =>  l_ptx_rec.passport_required
         ,p_pay_term_end_day_cd               =>  l_ptx_rec.pay_term_end_day_cd
         ,p_pay_term_end_month_cd             =>  l_ptx_rec.pay_term_end_month_cd
         ,p_permanent_temporary_flag          =>  l_ptx_rec.permanent_temporary_flag
         ,p_permit_recruitment_flag           =>  l_ptx_rec.permit_recruitment_flag
         ,p_position_type                     =>  l_ptx_rec.position_type
         ,p_posting_description               =>  l_ptx_rec.posting_description
         ,p_probation_period                  =>  l_ptx_rec.probation_period
         ,p_probation_period_unit_cd          =>  l_ptx_rec.probation_period_unit_cd
         ,p_relocate_domestically             =>  l_ptx_rec.relocate_domestically
         ,p_relocate_internationally          =>  l_ptx_rec.relocate_internationally
         ,p_replacement_required_flag         =>  l_ptx_rec.replacement_required_flag
         ,p_review_flag                       =>  'N'  --l_ptx_rec.review_flag
         ,p_seasonal_flag                     =>  l_ptx_rec.seasonal_flag
         ,p_security_requirements             =>  l_ptx_rec.security_requirements
         ,p_service_minimum                   =>  l_ptx_rec.service_minimum
         ,p_term_start_day_cd                 =>  l_ptx_rec.term_start_day_cd
         ,p_term_start_month_cd               =>  l_ptx_rec.term_start_month_cd
         ,p_time_normal_finish                =>  l_ptx_rec.time_normal_finish
         ,p_time_normal_start                 =>  l_ptx_rec.time_normal_start
         ,p_transaction_status                =>  'APPROVED'
         ,p_travel_required                   =>  l_ptx_rec.travel_required
         ,p_working_hours                     =>  l_ptx_rec.working_hours
         ,p_works_council_approval_flag       =>  l_ptx_rec.works_council_approval_flag
         ,p_work_any_country                  =>  l_ptx_rec.work_any_country
         ,p_work_any_location                 =>  l_ptx_rec.work_any_location
         ,p_work_period_type_cd               =>  l_ptx_rec.work_period_type_cd
         ,p_work_schedule                     =>  l_ptx_rec.work_schedule
         ,p_work_duration                     =>  l_ptx_rec.work_duration
         ,p_work_term_end_day_cd              =>  l_ptx_rec.work_term_end_day_cd
         ,p_work_term_end_month_cd            =>  l_ptx_rec.work_term_end_month_cd
         ,p_proposed_fte_for_layoff           =>  l_ptx_rec.proposed_fte_for_layoff
         ,p_proposed_date_for_layoff          =>  l_ptx_rec.proposed_date_for_layoff
         ,p_information1                      =>  l_ptx_rec.information1
         ,p_information2                      =>  l_ptx_rec.information2
         ,p_information3                      =>  l_ptx_rec.information3
         ,p_information4                      =>  l_ptx_rec.information4
         ,p_information5                      =>  l_ptx_rec.information5
         ,p_information6                      =>  l_ptx_rec.information6
         ,p_information7                      =>  l_ptx_rec.information7
         ,p_information8                      =>  l_ptx_rec.information8
         ,p_information9                      =>  l_ptx_rec.information9
         ,p_information10                     =>  l_ptx_rec.information10
         ,p_information11                     =>  l_ptx_rec.information11
         ,p_information12                     =>  l_ptx_rec.information12
         ,p_information13                     =>  l_ptx_rec.information13
         ,p_information14                     =>  l_ptx_rec.information14
         ,p_information15                     =>  l_ptx_rec.information15
         ,p_information16                     =>  l_ptx_rec.information16
         ,p_information17                     =>  l_ptx_rec.information17
         ,p_information18                     =>  l_ptx_rec.information18
         ,p_information19                     =>  l_ptx_rec.information19
         ,p_information20                     =>  l_ptx_rec.information20
         ,p_information21                     =>  l_ptx_rec.information21
         ,p_information22                     =>  l_ptx_rec.information22
         ,p_information23                     =>  l_ptx_rec.information24
         ,p_information24                     =>  l_ptx_rec.information23
         ,p_information25                     =>  l_ptx_rec.information25
         ,p_information26                     =>  l_ptx_rec.information26
         ,p_information27                     =>  l_ptx_rec.information27
         ,p_information28                     =>  l_ptx_rec.information28
         ,p_information29                     =>  l_ptx_rec.information29
         ,p_information30                     =>  l_ptx_rec.information30
         ,p_information_category              =>  l_ptx_rec.information_category
         ,p_attribute1                        =>  l_ptx_rec.attribute1
         ,p_attribute2                        =>  l_ptx_rec.attribute2
         ,p_attribute3                        =>  l_ptx_rec.attribute3
         ,p_attribute4                        =>  l_ptx_rec.attribute4
         ,p_attribute5                        =>  l_ptx_rec.attribute5
         ,p_attribute6                        =>  l_ptx_rec.attribute6
         ,p_attribute7                        =>  l_ptx_rec.attribute7
         ,p_attribute8                        =>  l_ptx_rec.attribute8
         ,p_attribute9                        =>  l_ptx_rec.attribute9
         ,p_attribute10                       =>  l_ptx_rec.attribute10
         ,p_attribute11                       =>  l_ptx_rec.attribute11
         ,p_attribute12                       =>  l_ptx_rec.attribute12
         ,p_attribute13                       =>  l_ptx_rec.attribute13
         ,p_attribute14                       =>  l_ptx_rec.attribute14
         ,p_attribute15                       =>  l_ptx_rec.attribute15
         ,p_attribute16                       =>  l_ptx_rec.attribute16
         ,p_attribute17                       =>  l_ptx_rec.attribute17
         ,p_attribute18                       =>  l_ptx_rec.attribute18
         ,p_attribute19                       =>  l_ptx_rec.attribute19
         ,p_attribute20                       =>  l_ptx_rec.attribute20
         ,p_attribute21                       =>  l_ptx_rec.attribute21
         ,p_attribute22                       =>  l_ptx_rec.attribute22
         ,p_attribute23                       =>  l_ptx_rec.attribute23
         ,p_attribute24                       =>  l_ptx_rec.attribute24
         ,p_attribute25                       =>  l_ptx_rec.attribute25
         ,p_attribute26                       =>  l_ptx_rec.attribute26
         ,p_attribute27                       =>  l_ptx_rec.attribute27
         ,p_attribute28                       =>  l_ptx_rec.attribute28
         ,p_attribute29                       =>  l_ptx_rec.attribute29
         ,p_attribute30                       =>  l_ptx_rec.attribute30
         ,p_attribute_category                =>  l_ptx_rec.attribute_category
         ,p_object_version_number             =>  l_ptx_rec.object_version_number
         ,p_effective_date                    =>  l_ptx_rec.action_date
         ,p_pay_basis_id                      =>  l_ptx_rec.pay_basis_id
         ,p_supervisor_id                     =>  l_ptx_rec.supervisor_id
         ,p_wf_transaction_category_id	      =>  l_ptx_rec.wf_transaction_category_id
        );
	end if;
        --
        if SQLERRM is not null then
	   pqh_wf.set_apply_error(p_transaction_category_id
						 => l_transaction_category_id,
                            p_transaction_id     => p_transaction_id,
                            p_apply_error_mesg   => SQLERRM,
                            p_apply_error_num    => SQLCODE);
           l_return := 'FAILURE';
        else
           l_return := 'SUCESS';
        end if;
        --
        return l_return;
        --
END apply_transaction;

--------------------------------------------------------------------------

FUNCTION fyi_notification (p_transaction_id in number) RETURN varchar2
is
  l_document varchar2(4000);
  l_proc     varchar2(61) := g_package||'fyi_notification' ;
  l_position_name     varchar2(2000);
  l_action_date       date;
  l_organization_desc varchar2(2000);
  l_job_desc          varchar2(2000);
  l_transaction_status  varchar2(100);
  cursor c0 is select name, action_date,
                      hr_general.decode_organization(organization_id),
                      hr_general.decode_job(job_id),
                      hr_general.decode_lookup('PQH_TRANSACTION_STATUS', transaction_status)
               from pqh_position_transactions
               where position_transaction_id = p_transaction_id;
BEGIN
  hr_utility.set_location('inside fyi notification'||l_proc,10);
  open c0;
  fetch c0 into l_position_name, l_action_date, l_organization_desc,
                l_job_desc, l_transaction_status;
  close c0;
  hr_utility.set_location('position name, action date fetched   '||l_proc,20);
  --
  hr_utility.set_message(8302,'PQH_PTX_WF_FYI_NOTICE');
  hr_utility.set_message_token('POSITION_NAME',l_position_name);
  hr_utility.set_message_token('ACTION_DATE',l_action_date);
  hr_utility.set_message_token('ORGANIZATION',l_organization_desc);
  hr_utility.set_message_token('JOB',l_job_desc);
  hr_utility.set_message_token('TRANSACTION_STATUS',l_transaction_status);
  l_document := hr_utility.get_message;
  return l_document;
  exception
  when others then
     hr_utility.set_message(8302,'PQH_PTX_WF_FYI_FAIL');
     hr_utility.set_message_token('TRANSACTION_ID',p_transaction_id);
     l_document := hr_utility.get_message;
     return l_document;
END fyi_notification;

--------------------------------------------------------------------------

FUNCTION back_notification (p_transaction_id in number) RETURN varchar2
is
  l_document varchar2(4000);
  l_proc     varchar2(61) := g_package||'back_notification' ;
  l_position_name     varchar2(2000);
  l_action_date       date;
  l_organization_desc varchar2(2000);
  l_job_desc          varchar2(2000);
  l_transaction_status  varchar2(100);
  cursor c0 is select name, action_date,
                      hr_general.decode_organization(organization_id),
                      hr_general.decode_job(job_id),
                      hr_general.decode_lookup('PQH_TRANSACTION_STATUS', transaction_status)
               from pqh_position_transactions
               where position_transaction_id = p_transaction_id;
BEGIN
  hr_utility.set_location('inside back notification'||l_proc,10);
  open c0;
  fetch c0 into l_position_name, l_action_date, l_organization_desc,
                l_job_desc, l_transaction_status;
  close c0;
  hr_utility.set_location('position name, action date fetched   '||l_proc,20);
  --
  hr_utility.set_message(8302,'PQH_PTX_WF_BACK_NOTICE');
  hr_utility.set_message_token('POSITION_NAME',l_position_name);
  hr_utility.set_message_token('ACTION_DATE',l_action_date);
  hr_utility.set_message_token('ORGANIZATION',l_organization_desc);
  hr_utility.set_message_token('JOB',l_job_desc);
  hr_utility.set_message_token('TRANSACTION_STATUS',l_transaction_status);
  l_document := hr_utility.get_message;
  return l_document;
  exception
  when others then
     hr_utility.set_message(8302,'PQH_PTX_WF_BACK_FAIL');
     hr_utility.set_message_token('TRANSACTION_ID',p_transaction_id);
     l_document := hr_utility.get_message;
     return l_document;
END back_notification;

--------------------------------------------------------------------------

FUNCTION override_notification (p_transaction_id in number) RETURN varchar2
is
  l_document varchar2(4000);
  l_proc     varchar2(61) := g_package||'override_notification' ;
  l_position_name     varchar2(2000);
  l_action_date       date;
  l_organization_desc varchar2(2000);
  l_job_desc          varchar2(2000);
  l_transaction_status  varchar2(100);
  cursor c0 is select name, action_date,
                      hr_general.decode_organization(organization_id),
                      hr_general.decode_job(job_id),
                      hr_general.decode_lookup('PQH_TRANSACTION_STATUS', transaction_status)
               from pqh_position_transactions
               where position_transaction_id = p_transaction_id;
BEGIN
  hr_utility.set_location('inside override notification'||l_proc,10);
  open c0;
  fetch c0 into l_position_name, l_action_date, l_organization_desc,
                l_job_desc, l_transaction_status;
  close c0;
  hr_utility.set_location('position name, action date fetched   '||l_proc,20);
  --
  hr_utility.set_message(8302,'PQH_PTX_WF_OVERRIDE_NOTICE');
  hr_utility.set_message_token('POSITION_NAME',l_position_name);
  hr_utility.set_message_token('ACTION_DATE',l_action_date);
  hr_utility.set_message_token('ORGANIZATION',l_organization_desc);
  hr_utility.set_message_token('JOB',l_job_desc);
  hr_utility.set_message_token('TRANSACTION_STATUS',l_transaction_status);
  l_document := hr_utility.get_message;
  return l_document;
  exception
  when others then
     hr_utility.set_message(8302,'PQH_PTX_WF_OVERRIDE_FAIL');
     hr_utility.set_message_token('TRANSACTION_ID',p_transaction_id);
     l_document := hr_utility.get_message;
     return l_document;
END override_notification;

--------------------------------------------------------------------------

FUNCTION apply_notification (p_transaction_id in number) RETURN varchar2
is
  l_document varchar2(4000);
  l_proc     varchar2(61) := g_package||'apply_notification' ;
  l_position_name     varchar2(2000);
  l_action_date       date;
  l_organization_desc varchar2(2000);
  l_job_desc          varchar2(2000);
  l_transaction_status  varchar2(100);
  cursor c0 is select name, action_date,
                      hr_general.decode_organization(organization_id),
                      hr_general.decode_job(job_id),
                      hr_general.decode_lookup('PQH_TRANSACTION_STATUS', transaction_status)
               from pqh_position_transactions
               where position_transaction_id = p_transaction_id;
BEGIN
  hr_utility.set_location('inside apply notification'||l_proc,10);
  open c0;
  fetch c0 into l_position_name, l_action_date, l_organization_desc,
                l_job_desc, l_transaction_status;
  close c0;
  hr_utility.set_location('position name, action date fetched   '||l_proc,20);
  --
  hr_utility.set_message(8302,'PQH_PTX_WF_APPLY_NOTICE');
  hr_utility.set_message_token('POSITION_NAME',l_position_name);
  hr_utility.set_message_token('ACTION_DATE',l_action_date);
  hr_utility.set_message_token('ORGANIZATION',l_organization_desc);
  hr_utility.set_message_token('JOB',l_job_desc);
  hr_utility.set_message_token('TRANSACTION_STATUS',l_transaction_status);
  l_document := hr_utility.get_message;
  return l_document;
  exception
  when others then
     hr_utility.set_message(8302,'PQH_PTX_WF_APPLY_FAIL');
     hr_utility.set_message_token('TRANSACTION_ID',p_transaction_id);
     l_document := hr_utility.get_message;
     return l_document;
END apply_notification;

--------------------------------------------------------------------------

FUNCTION reject_notification (p_transaction_id in number) RETURN varchar2
is
  l_document varchar2(4000);
  l_proc     varchar2(61) := g_package||'reject_notification' ;
  l_position_name     varchar2(2000);
  l_action_date       date;
  l_organization_desc varchar2(2000);
  l_job_desc          varchar2(2000);
  l_transaction_status  varchar2(100);
  cursor c0 is select name, action_date,
                      hr_general.decode_organization(organization_id),
                      hr_general.decode_job(job_id),
                      hr_general.decode_lookup('PQH_TRANSACTION_STATUS', transaction_status)
               from pqh_position_transactions
               where position_transaction_id = p_transaction_id;
BEGIN
  hr_utility.set_location('inside reject notification'||l_proc,10);
  open c0;
  fetch c0 into l_position_name, l_action_date, l_organization_desc,
                l_job_desc, l_transaction_status;
  close c0;
  hr_utility.set_location('position name, action date fetched   '||l_proc,20);
  --
  hr_utility.set_message(8302,'PQH_PTX_WF_REJECT_NOTICE');
  hr_utility.set_message_token('POSITION_NAME',l_position_name);
  hr_utility.set_message_token('ACTION_DATE',l_action_date);
  hr_utility.set_message_token('ORGANIZATION',l_organization_desc);
  hr_utility.set_message_token('JOB',l_job_desc);
  hr_utility.set_message_token('TRANSACTION_STATUS',l_transaction_status);
  l_document := hr_utility.get_message;
  return l_document;
  exception
  when others then
     hr_utility.set_message(8302,'PQH_PTX_WF_REJECT_FAIL');
     hr_utility.set_message_token('TRANSACTION_ID',p_transaction_id);
     l_document := hr_utility.get_message;
     return l_document;
END reject_notification;

--------------------------------------------------------------------------

FUNCTION warning_notification (p_transaction_id in number) RETURN varchar2
is
  l_document varchar2(4000);
  l_proc     varchar2(61) := g_package||'warning_notification' ;
  l_position_name     varchar2(2000);
  l_action_date       date;
  l_organization_desc varchar2(2000);
  l_job_desc          varchar2(2000);
  l_transaction_status  varchar2(100);
  cursor c0 is select name, action_date,
                      hr_general.decode_organization(organization_id),
                      hr_general.decode_job(job_id),
                      hr_general.decode_lookup('PQH_TRANSACTION_STATUS', transaction_status)
               from pqh_position_transactions
               where position_transaction_id = p_transaction_id;
BEGIN
  hr_utility.set_location('inside warning notification'||l_proc,10);
  open c0;
  fetch c0 into l_position_name, l_action_date, l_organization_desc,
                l_job_desc, l_transaction_status;
  close c0;
  hr_utility.set_location('position name, action date fetched   '||l_proc,20);
  --
  hr_utility.set_message(8302,'PQH_PTX_WF_WARNING_NOTICE');
  hr_utility.set_message_token('POSITION_NAME',l_position_name);
  hr_utility.set_message_token('ACTION_DATE',l_action_date);
  hr_utility.set_message_token('ORGANIZATION',l_organization_desc);
  hr_utility.set_message_token('JOB',l_job_desc);
  hr_utility.set_message_token('TRANSACTION_STATUS',l_transaction_status);
  l_document := hr_utility.get_message;
  return l_document;
  exception
  when others then
     hr_utility.set_message(8302,'PQH_PTX_WF_WARNING_FAIL');
     hr_utility.set_message_token('TRANSACTION_ID',p_transaction_id);
     l_document := hr_utility.get_message;
     return l_document;
END warning_notification;

--------------------------------------------------------------------------

FUNCTION respond_notification (p_transaction_id in number) RETURN varchar2
is
  l_document          varchar2(4000);
  l_proc              varchar2(61) := g_package||'respond_notification' ;
  l_position_name     varchar2(2000);
  l_action_date       date;
  l_organization_desc varchar2(2000);
  l_job_desc          varchar2(2000);
  l_transaction_status  varchar2(100);
  cursor c0 is select name, action_date,
                      hr_general.decode_organization(organization_id),
                      hr_general.decode_job(job_id),
                      hr_general.decode_lookup('PQH_TRANSACTION_STATUS', transaction_status)
               from pqh_position_transactions
               where position_transaction_id = p_transaction_id;
BEGIN
  hr_utility.set_location('inside respond notification'||l_proc,10);
  open c0;
  fetch c0 into l_position_name, l_action_date, l_organization_desc,
                l_job_desc, l_transaction_status;
  close c0;
  hr_utility.set_location('position name, action date fetched   '||l_proc,20);
  --
  hr_utility.set_message(8302,'PQH_PTX_WF_RESPOND_NOTICE');
  hr_utility.set_message_token('POSITION_NAME',l_position_name);
  hr_utility.set_message_token('ACTION_DATE',l_action_date);
  hr_utility.set_message_token('ORGANIZATION',l_organization_desc);
  hr_utility.set_message_token('JOB',l_job_desc);
  hr_utility.set_message_token('TRANSACTION_STATUS',l_transaction_status);
  l_document := hr_utility.get_message;
  return l_document;
exception
  when others then
     hr_utility.set_message(8302,'PQH_PTX_WF_RESPOND_FAIL');
     hr_utility.set_message_token('TRANSACTION_ID',p_transaction_id);
     l_document := hr_utility.get_message;
     return l_document;
END respond_notification;

--------------------------------------------------------------------------------------------------------------

FUNCTION set_status
(
 p_transaction_category_id       IN    pqh_transaction_categories.transaction_category_id%TYPE,
 p_transaction_id                IN    pqh_worksheets.worksheet_id%TYPE,
 p_status                        IN    pqh_worksheets.transaction_status%TYPE
) RETURN varchar2 IS
/*
   This procedure will update the txn status
*/

 l_proc                            varchar2(72) := g_package||'set_status';


CURSOR csr_ptx IS
SELECT ptx.*
FROM pqh_position_transactions ptx
WHERE ptx.position_transaction_id = p_transaction_id;

l_ptx_rec                           pqh_position_transactions%ROWTYPE;
l_object_version_number             pqh_position_transactions.object_version_number%TYPE;
l_review_flag                       pqh_position_transactions.review_flag%TYPE;

BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);

    OPEN csr_ptx;
      FETCH csr_ptx INTO l_ptx_rec;
    CLOSE csr_ptx;

     -- call the Abort process
     BEGIN
       -- call the Abort Process, if error then skip and go to next record after updating wdt status
       wf_engine.AbortProcess
       (itemtype  => 'PQHGEN',
       itemkey    => p_transaction_category_id || '-' || p_transaction_id,
       process    => 'PQH_ROUTING',
       result     => null
       );

     EXCEPTION
       WHEN OTHERS THEN
        null;
     END; -- for Abort process

          l_object_version_number   :=  l_ptx_rec.object_version_number;

          -- call the update API
	  -- If condition added for bug 6112905/ Modified for bug 6524175
	  hr_utility.set_location('Entering:'||l_proc||' with status: '||p_status||
					'and review_flag: '||l_review_flag, 15);

	  if p_status in ('REJECT','TERMINATE','SUBMITTED') then
	   l_review_flag := 'N';
	  end if;


            pqh_position_transactions_api.update_position_transaction
            (
             p_validate                       =>  false
            ,p_position_transaction_id        =>  p_transaction_id
            ,p_object_version_number          =>  l_object_version_number
            ,p_transaction_status             =>  p_status
            ,p_effective_date                 =>  SYSDATE
            ,p_review_flag                    =>  l_review_flag   -- bug 6112905
            );


  hr_utility.set_location('Leaving:'||l_proc, 1000);

  RETURN 'SUCCESS';



EXCEPTION
      WHEN OTHERS THEN
        hr_utility.set_message(8302, 'PQH_CATASTROPHIC_ERROR');
        hr_utility.set_message_token('ROUTINE', l_proc);
        hr_utility.set_message_token('REASON', SQLERRM);
        hr_utility.raise_error;
        hr_utility.set_location('Leaving: EXCEPTION '||l_proc, 1000);
        RETURN 'FAILURE';
END set_status;

--------------------------------------------------------------------------------
procedure create_ptx_shadow(p_position_transaction_id number) is
cursor c1 is
select *
from pqh_position_transactions
where position_transaction_id = p_position_transaction_id
  and position_transaction_id not in
  (select position_transaction_id
   from pqh_ptx_shadow
   where position_transaction_id = p_position_transaction_id);
rec1 c1%rowtype;
begin
open c1;
fetch c1 into rec1;
if c1%notfound then
  return;
end if;
insert into pqh_ptx_shadow
(position_transaction_id, action_date, position_id, availability_status_id, business_group_id, entry_grade_id,
entry_step_id, entry_grade_rule_id, job_id, location_id, organization_id, pay_basis_id, pay_freq_payroll_id,
position_definition_id, prior_position_id, relief_position_id, successor_position_id, supervisor_id,
supervisor_position_id, amendment_date, amendment_recommendation, amendment_ref_number, avail_status_prop_end_date,
bargaining_unit_cd, comments, country1, country2, country3, current_job_prop_end_date, current_org_prop_end_date,
date_effective, date_end, earliest_hire_date, fill_by_date, frequency, fte, fte_capacity, location1, location2,
location3, max_persons, name, other_requirements, overlap_period, overlap_unit_cd, passport_required,
pay_term_end_day_cd, pay_term_end_month_cd, permanent_temporary_flag, permit_recruitment_flag, position_type,
posting_description, probation_period, probation_period_unit_cd, proposed_fte_for_layoff,
proposed_date_for_layoff, relocate_domestically, relocate_internationally, relocation_required,
replacement_required_flag, review_flag, seasonal_flag, security_requirements, service_minimum,
term_start_day_cd, term_start_month_cd, time_normal_finish, time_normal_start,
travel_required, visit_internationally, working_hours, works_council_approval_flag, work_any_country,
work_any_location, work_duration, work_period_type_cd, work_schedule, work_term_end_day_cd, work_term_end_month_cd,
information1, information2, information3, information4, information5,
information6, information7, information8, information9, information10,
information11, information12, information13, information14, information15,
information16, information17, information18, information19, information20,
information21, information22, information23, information24, information25,
information26, information27, information28, information29, information30,
information_category,
attribute1, attribute2, attribute3, attribute4, attribute5,
attribute6, attribute7, attribute8, attribute9, attribute10,
attribute11, attribute12, attribute13, attribute14, attribute15,
attribute16, attribute17, attribute18, attribute19, attribute20,
attribute21, attribute22, attribute23, attribute24, attribute25,
attribute26, attribute27, attribute28, attribute29, attribute30,
attribute_category,
created_by, creation_date, last_updated_by, last_update_date, last_update_login, object_version_number
)
values
(rec1.position_transaction_id, rec1.action_date, rec1.position_id, rec1.availability_status_id,
rec1.business_group_id, rec1.entry_grade_id,
rec1.entry_step_id, rec1.entry_grade_rule_id, rec1.job_id, rec1.location_id,
rec1.organization_id, rec1.pay_basis_id, rec1.pay_freq_payroll_id,
rec1.position_definition_id, rec1.prior_position_id, rec1.relief_position_id,
rec1.successor_position_id, rec1.supervisor_id,
rec1.supervisor_position_id, rec1.amendment_date, rec1.amendment_recommendation,
rec1.amendment_ref_number, rec1.avail_status_prop_end_date,
rec1.bargaining_unit_cd, rec1.comments, rec1.country1, rec1.country2, rec1.country3,
rec1.current_job_prop_end_date, rec1.current_org_prop_end_date,
rec1.date_effective, rec1.date_end, rec1.earliest_hire_date, rec1.fill_by_date, rec1.frequency,
rec1.fte, rec1.fte_capacity, rec1.location1, rec1.location2,
rec1.location3, rec1.max_persons, rec1.name, rec1.other_requirements, rec1.overlap_period,
rec1.overlap_unit_cd, rec1.passport_required,
rec1.pay_term_end_day_cd, rec1.pay_term_end_month_cd, rec1.permanent_temporary_flag,
rec1.permit_recruitment_flag, rec1.position_type,
rec1.posting_description, rec1.probation_period, rec1.probation_period_unit_cd,
rec1.proposed_fte_for_layoff,
rec1.proposed_date_for_layoff, rec1.relocate_domestically, rec1.relocate_internationally,
rec1.relocation_required,
rec1.replacement_required_flag, rec1.review_flag, rec1.seasonal_flag, rec1.security_requirements,
rec1.service_minimum,
rec1.term_start_day_cd, rec1.term_start_month_cd, rec1.time_normal_finish, rec1.time_normal_start,
rec1.travel_required, rec1.visit_internationally, rec1.working_hours, rec1.works_council_approval_flag,
rec1.work_any_country,
rec1.work_any_location, rec1.work_duration, rec1.work_period_type_cd, rec1.work_schedule,
rec1.work_term_end_day_cd, rec1.work_term_end_month_cd,
rec1.information1, rec1.information2, rec1.information3, rec1.information4, rec1.information5,
rec1.information6, rec1.information7, rec1.information8, rec1.information9, rec1.information10,
rec1.information11, rec1.information12, rec1.information13, rec1.information14, rec1.information15,
rec1.information16, rec1.information17, rec1.information18, rec1.information19, rec1.information20,
rec1.information21, rec1.information22, rec1.information23, rec1.information24, rec1.information25,
rec1.information26, rec1.information27, rec1.information28, rec1.information29, rec1.information30,
rec1.information_category,
rec1.attribute1, rec1.attribute2, rec1.attribute3, rec1.attribute4, rec1.attribute5,
rec1.attribute6, rec1.attribute7, rec1.attribute8, rec1.attribute9, rec1.attribute10,
rec1.attribute11, rec1.attribute12, rec1.attribute13, rec1.attribute14, rec1.attribute15,
rec1.attribute16, rec1.attribute17, rec1.attribute18, rec1.attribute19, rec1.attribute20,
rec1.attribute21, rec1.attribute22, rec1.attribute23, rec1.attribute24, rec1.attribute25,
rec1.attribute26, rec1.attribute27, rec1.attribute28, rec1.attribute29, rec1.attribute30,
rec1.attribute_category,
rec1.created_by, rec1.creation_date, rec1.last_updated_by, rec1.last_update_date, rec1.last_update_login, rec1.object_version_number
);

end;
--------------------------------------------------------------------------------
procedure create_pte_shadow(p_position_transaction_id number) is
  cursor c3 is
  select *
  from pqh_ptx_extra_info
  where position_transaction_id = p_position_transaction_id
  and position_extra_info_id is not null
  and ptx_extra_info_id not in
  (select ptx_extra_info_id
   from pqh_pte_shadow
   where position_transaction_id = p_position_transaction_id);
begin
for rec3 in c3 loop
insert into pqh_pte_shadow
(ptx_extra_info_id, information_type, position_transaction_id, position_extra_info_id,
information_category, information1, information2, information3, information4, information5,
information6, information7, information8, information9, information10,
information11, information12, information13, information14, information15,
information16, information17, information18, information19, information20,
information21, information22, information23, information24, information25,
information26, information27, information28, information29, information30,
attribute_category, attribute1, attribute2, attribute3, attribute4, attribute5,
attribute6, attribute7, attribute8, attribute9, attribute10,
attribute11, attribute12, attribute13, attribute14, attribute15,
attribute16, attribute17, attribute18, attribute19, attribute20,
object_version_number)
values
(rec3.ptx_extra_info_id, rec3.information_type, rec3.position_transaction_id, rec3.position_extra_info_id,
 rec3.information_category,
rec3.information1, rec3.information2, rec3.information3, rec3.information4, rec3.information5,
rec3.information6, rec3.information7, rec3.information8, rec3.information9, rec3.information10,
rec3.information11, rec3.information12, rec3.information13, rec3.information14, rec3.information15,
rec3.information16, rec3.information17, rec3.information18, rec3.information19, rec3.information20,
rec3.information21, rec3.information22, rec3.information23, rec3.information24, rec3.information25,
rec3.information26, rec3.information27, rec3.information28, rec3.information29, rec3.information30,
rec3.attribute_category, rec3.attribute1, rec3.attribute2, rec3.attribute3, rec3.attribute4, rec3.attribute5,
rec3.attribute6, rec3.attribute7, rec3.attribute8, rec3.attribute9, rec3.attribute10,
rec3.attribute11, rec3.attribute12, rec3.attribute13, rec3.attribute14, rec3.attribute15,
rec3.attribute16, rec3.attribute17, rec3.attribute18, rec3.attribute19, rec3.attribute20,
1);
end loop;
--
end;
--------------------------------------------------------------------------------
procedure create_tjr_shadow(p_position_transaction_id number) is
  cursor c3 is
  select *
  from pqh_txn_job_requirements
  where position_transaction_id = p_position_transaction_id
  and job_requirement_id is not null
  and txn_job_requirement_id not in
  (select txn_job_requirement_id
   from pqh_tjr_shadow
   where position_transaction_id = p_position_transaction_id);
begin
for rec3 in c3 loop
insert into pqh_tjr_shadow (
txn_job_requirement_id, position_transaction_id, job_requirement_id,
business_group_id, analysis_criteria_id, date_from, date_to,
essential, job_id, object_version_number,
attribute_category, attribute1, attribute2, attribute3,
attribute4, attribute5, attribute6, attribute7, attribute8,
attribute9, attribute10, attribute11, attribute12,
attribute13, attribute14, attribute15, attribute16,
attribute17, attribute18, attribute19, attribute20,
comments
)
values (
rec3.txn_job_requirement_id, rec3.position_transaction_id, rec3.job_requirement_id,
rec3.business_group_id, rec3.analysis_criteria_id, rec3.date_from, rec3.date_to,
rec3.essential, rec3.job_id, 1,
rec3.attribute_category, rec3.attribute1, rec3.attribute2, rec3.attribute3,
rec3.attribute4, rec3.attribute5, rec3.attribute6, rec3.attribute7, rec3.attribute8,
rec3.attribute9, rec3.attribute10, rec3.attribute11, rec3.attribute12,
rec3.attribute13, rec3.attribute14, rec3.attribute15, rec3.attribute16,
rec3.attribute17, rec3.attribute18, rec3.attribute19, rec3.attribute20,
rec3.comments
);
end loop;
--
end;
--------------------------------------------------------------------------------
procedure refresh_ptx(p_transaction_category_id number, p_position_transaction_id number, p_items_changed out nocopy varchar2) is
l_position_id   number;
l_pf1_items_changed varchar2(10000);
l_ptx_items_changed varchar2(8000);
p_ptx_deployment_factor_id number;

cursor c_ptx(p_position_transaction_id number) is
select position_id
from pqh_position_transactions
where position_transaction_id = p_position_transaction_id;
--
cursor c_dpf_df(p_position_transaction_id number) is
select ptx_deployment_factor_id
from pqh_ptx_dpf_df
where position_transaction_id = p_position_transaction_id;
--
l_pf1_changed       varchar2(10000);
l_pei_changed       varchar2(10000);
l_tjr_changed       varchar2(10000);
--
begin
 open c_ptx(p_position_transaction_id);
 fetch c_ptx into l_position_id;
 close c_ptx;
 -- call the refresh_data pkg for txn table alias PTX
  pqh_refresh_data.refresh_data
  (p_txn_category_id  => p_transaction_category_id,
   p_txn_id           => p_position_transaction_ID,
   p_refresh_criteria => 'PTX',
   p_items_changed    => l_ptx_items_changed
  );
  --
  open c_dpf_df(p_position_transaction_id);
  fetch c_dpf_df into p_ptx_deployment_factor_id;
  close c_dpf_df;
  if p_ptx_deployment_factor_id is not null then
    -- call the refresh_data pkg for txn table alias PF1
    pqh_refresh_data.refresh_data
    (p_txn_category_id  => p_transaction_category_id,
     p_txn_id           => p_ptx_deployment_factor_ID,
     p_refresh_criteria => 'PF1',
     p_items_changed    => l_pf1_items_changed
    );
  end if;
  --
  pqh_ptx_utl.refresh_pte
  (p_transaction_category_id    => p_transaction_category_id,
   p_position_transaction_id    => p_position_transaction_ID,
   p_position_id                => l_position_id,
   p_pte_changed                => l_pei_changed
  );
  --
  pqh_ptx_utl.refresh_tjr
  (p_transaction_category_id    => p_transaction_category_id,
   p_position_transaction_id    => p_position_transaction_ID,
   p_position_id                => l_position_id,
   p_tjr_changed                => l_tjr_changed
  );
  --
  if l_pf1_items_changed is not null then
    l_pf1_changed := pqh_utility.get_attribute_name('DF1','DEPLOYMENT_DF');
  end if;
  --
  if l_pf1_changed is not null then
   if l_ptx_items_changed is null then
    l_ptx_items_changed := l_pf1_changed;
   else
    l_ptx_items_changed := l_ptx_items_changed || fnd_global.local_chr(10) || l_pf1_changed;
   end if;
  end if;
  --
  if l_ptx_items_changed is null then
    p_items_changed := l_pei_changed;
  elsif l_pei_changed is null then
    p_items_changed := l_ptx_items_changed;
  else
    p_items_changed := l_ptx_items_changed || fnd_global.local_chr(10) || l_pei_changed;
  end if;
  --
  if p_items_changed is null then
    p_items_changed := l_tjr_changed;
  elsif l_tjr_changed is not null then
    p_items_changed := p_items_changed || fnd_global.local_chr(10) || l_tjr_changed;
  end if;
  --
  --
end;
--
procedure apply_sit(p_position_transaction_id number, p_position_id number, p_txn_type varchar2) is
 l_proc                      varchar2(72) := g_package||'apply_sit';
 l_tjr_rec                   pqh_txn_job_requirements%ROWTYPE;
 l_sit_type                  varchar2(1);
 l_sit_job_requirement_id     per_job_requirements.job_requirement_id%type;
 l_sit_object_version_number  per_job_requirements.object_version_number%type;
 l_position_id              number;
 l_position_extra_info_id  number;
 l_object_version_number number;

 CURSOR c_del_tjr(p_transaction_id number, p_position_id number) IS
  select jreq.job_requirement_id, jreq.object_version_number
  from per_job_requirements jreq,pqh_tjr_shadow pts
  where position_id = p_position_id
  and jreq.job_requirement_id = pts.job_requirement_id
  and pts.position_transaction_id = p_transaction_id
  and not exists (
   select null
   from pqh_txn_job_requirements ptjr
   where position_transaction_id = p_transaction_id
     and ptjr.job_requirement_id = pts.job_requirement_id);

CURSOR c3 IS
  select *
  from pqh_txn_job_requirements
  where position_transaction_id = p_position_transaction_id;
cursor c_pes(p_txn_job_requirement_id number) is
select *
from pqh_tjr_shadow
where txn_job_requirement_id = p_txn_job_requirement_id;
CURSOR c5 (p_position_id in hr_all_positions_f.position_id%TYPE,
--            p_information_type in per_position_extra_info.information_type%type,
            p_job_requirement_id in
               per_job_requirements.job_requirement_id%type) IS
  select job_requirement_id,object_version_number
  from per_job_requirements
  where position_id = p_position_id
--  and information_type = p_information_type
  and job_requirement_id = p_job_requirement_id;
--
l_pes_rec c_pes%rowtype;
begin

  --
  --  TABLE : per_job_requirements
  --
  -- For update transaction delete the per_job_requirements if deleted from per_job_requirements
  if p_position_id is not null and p_txn_type = 'U' then
    for r_del_tjr in c_del_tjr(p_position_transaction_id , p_position_id) loop
      delete per_job_requirements
      where job_requirement_id = r_del_tjr.job_requirement_id;
    end loop;
  end if;

  --
  -- create/update the per_job_requirements
  --
    OPEN c3;
    LOOP
      FETCH c3 INTO l_tjr_rec;
      EXIT WHEN c3%NOTFOUND;
      l_sit_type := null;

      if l_tjr_rec.job_requirement_id is null then
          l_sit_type := 'C';
      elsif p_txn_type = 'U' then
          --
          open c_pes(l_tjr_rec.txn_job_requirement_id);
          fetch c_pes into l_pes_rec;
          close c_pes;
          --
          if l_tjr_rec.object_version_number > l_pes_rec.object_version_number then
            l_sit_job_requirement_id := null;
            open c5(p_position_id,l_tjr_rec.job_requirement_id);
            fetch c5 into l_sit_job_requirement_id,l_sit_object_version_number;
            close c5;
            --
            if l_sit_job_requirement_id is null then
              l_sit_type := 'I';
            else
              l_sit_type := 'U';
            end if;
          end if;
      end if;

       IF l_sit_type = 'I' THEN
         --
         hr_utility.set_location('Insert for sit_id '|| l_sit_job_requirement_id
                     ||l_proc, 20);
         insert into per_job_requirements
         (
         job_requirement_id, business_group_id, analysis_criteria_id,
         comments, date_from, date_to, essential, job_id,
         position_id,
         attribute_category, attribute1, attribute2,
         attribute3, attribute4,
         attribute5, attribute6, attribute7,
         attribute8, attribute9, attribute10,
         attribute11, attribute12, attribute13,
         attribute14, attribute15,
         attribute16, attribute17, attribute18,
         attribute19, attribute20,
         object_version_number
         )
         values
         (
         l_tjr_rec.job_requirement_id, l_tjr_rec.business_group_id, l_tjr_rec.analysis_criteria_id,
         l_tjr_rec.comments, l_tjr_rec.date_from, l_tjr_rec.date_to, l_tjr_rec.essential, l_tjr_rec.job_id,
         p_position_id,
         l_tjr_rec.attribute_category, l_tjr_rec.attribute1, l_tjr_rec.attribute2,
         l_tjr_rec.attribute3, l_tjr_rec.attribute4,
         l_tjr_rec.attribute5, l_tjr_rec.attribute6, l_tjr_rec.attribute7,
         l_tjr_rec.attribute8, l_tjr_rec.attribute9, l_tjr_rec.attribute10,
         l_tjr_rec.attribute11, l_tjr_rec.attribute12, l_tjr_rec.attribute13,
         l_tjr_rec.attribute14, l_tjr_rec.attribute15,
         l_tjr_rec.attribute16, l_tjr_rec.attribute17, l_tjr_rec.attribute18,
         l_tjr_rec.attribute19, l_tjr_rec.attribute20,
         1
         );
         --
         hr_utility.set_location('After Insert for sit_id '|| l_sit_job_requirement_id
                     ||l_proc, 25);
       ELSIF l_sit_type = 'C' THEN
         hr_utility.set_location('Calling create PER_JOB_REQUIREMENTS '
                     ||l_proc, 30);
         --
         -- call create API
         --
         declare
         l_job_requirement_id number;
         begin
         select per_job_requirements_s.nextval into l_job_requirement_id
         from dual;
         --
         insert into per_job_requirements
         (
         job_requirement_id, business_group_id, analysis_criteria_id,
         comments, date_from, date_to, essential, job_id,
         position_id,
         attribute_category, attribute1, attribute2,
         attribute3, attribute4,
         attribute5, attribute6, attribute7,
         attribute8, attribute9, attribute10,
         attribute11, attribute12, attribute13,
         attribute14, attribute15,
         attribute16, attribute17, attribute18,
         attribute19, attribute20,
         object_version_number
         )
         values
         (
         l_job_requirement_id, l_tjr_rec.business_group_id, l_tjr_rec.analysis_criteria_id,
         l_tjr_rec.comments, l_tjr_rec.date_from, l_tjr_rec.date_to, l_tjr_rec.essential, l_tjr_rec.job_id,
         p_position_id,
         l_tjr_rec.attribute_category, l_tjr_rec.attribute1, l_tjr_rec.attribute2,
         l_tjr_rec.attribute3, l_tjr_rec.attribute4,
         l_tjr_rec.attribute5, l_tjr_rec.attribute6, l_tjr_rec.attribute7,
         l_tjr_rec.attribute8, l_tjr_rec.attribute9, l_tjr_rec.attribute10,
         l_tjr_rec.attribute11, l_tjr_rec.attribute12, l_tjr_rec.attribute13,
         l_tjr_rec.attribute14, l_tjr_rec.attribute15,
         l_tjr_rec.attribute16, l_tjr_rec.attribute17, l_tjr_rec.attribute18,
         l_tjr_rec.attribute19, l_tjr_rec.attribute20,
         1
         );
         end;
       ELSIF l_sit_type = 'U' then
         hr_utility.set_location('Calling update PER_JOB_REQUIREMENTS '
                                   ||l_proc, 35);
         --
         -- call update API
         --
        declare
         l_job_requirement_id number;
         begin
         update per_job_requirements
         set
         business_group_id = l_tjr_rec.business_group_id,
         analysis_criteria_id = l_tjr_rec.analysis_criteria_id,
         comments = l_tjr_rec.comments,
         date_from = l_tjr_rec.date_from,
         date_to = l_tjr_rec.date_to,
         essential = l_tjr_rec.essential,
         job_id = l_tjr_rec.job_id,
         position_id = p_position_id,
         attribute_category = l_tjr_rec.attribute_category,
         attribute1 = l_tjr_rec.attribute1,
         attribute2 = l_tjr_rec.attribute2,
         attribute3 = l_tjr_rec.attribute3,
         attribute4 = l_tjr_rec.attribute4,
         attribute5 = l_tjr_rec.attribute5,
         attribute6 = l_tjr_rec.attribute6,
         attribute7 = l_tjr_rec.attribute7,
         attribute8 = l_tjr_rec.attribute8,
         attribute9 = l_tjr_rec.attribute9,
         attribute10 = l_tjr_rec.attribute10,
         attribute11 = l_tjr_rec.attribute11,
         attribute12 = l_tjr_rec.attribute12,
         attribute13 = l_tjr_rec.attribute13,
         attribute14 = l_tjr_rec.attribute14,
         attribute15 = l_tjr_rec.attribute15,
         attribute16 = l_tjr_rec.attribute16,
         attribute17 = l_tjr_rec.attribute17,
         attribute18 = l_tjr_rec.attribute18,
         attribute19 = l_tjr_rec.attribute19,
         attribute20 = l_tjr_rec.attribute20,
         object_version_number = object_version_number+1
         where job_requirement_id = l_tjr_rec.job_requirement_id;
         end;         --
       END IF; -- api call per_job_requirements
       --
    END LOOP;  -- for c3
    CLOSE c3;
    --
end;
--

procedure refresh_tjr(p_transaction_category_id number, p_position_transaction_id number, p_position_id number, p_tjr_changed out nocopy varchar2) is
l_position_id  number;
l_tjr_items_changed varchar2(8000);
--
cursor c_tjr(p_position_transaction_id number, p_position_id number) is
select txn_job_requirement_id
from pqh_txn_job_requirements
where position_transaction_id = p_position_transaction_id
and job_requirement_id in
(select job_requirement_id
 from per_job_requirements
 where position_id = p_position_id
 );
--
cursor c_prs_tjr(p_position_transaction_id number, p_position_id number) is
select tjr.txn_job_requirement_id, tjr.object_version_number
from pqh_txn_job_requirements tjr, pqh_tjr_shadow pts
where tjr.txn_job_requirement_id = pts.txn_job_requirement_id
  and tjr.position_transaction_id = pts.position_transaction_id
  and tjr.position_transaction_id = p_position_transaction_id
  and not exists
   (select null
    from per_job_requirements pjr
    where position_id = p_position_id
      and pjr.job_requirement_id = pts.job_requirement_id);
--
l_tjr_classification varchar2(100);
l_index     number;
l_tjr_changed varchar2(10000);
--
begin
  l_position_id := p_position_id;
  --
  for r_tjr in c_tjr(p_position_transaction_id, l_position_id)
  loop
    pqh_refresh_data.refresh_data
    (p_txn_category_id  => p_transaction_category_id,
     p_txn_id           => r_tjr.txn_job_requirement_id,
     p_refresh_criteria => 'TJR',
     p_items_changed      => l_tjr_items_changed
    );
    hr_utility.set_location('l_tjr_items_changed:'||nvl(l_tjr_items_changed,'NULL'), 1000);
    if l_tjr_items_changed is not null then
      l_tjr_classification := pqh_utility.get_tjr_classification(r_tjr.txn_job_requirement_id);
      hr_utility.set_location('l_tjr_classification:'||nvl(l_tjr_classification,'NULL'), 1000);
      append_if_not_present(l_tjr_changed, l_tjr_classification);
    end if;
  end loop;
  --
  for r_prs_tjr in c_prs_tjr(p_position_transaction_id, l_position_id)
  loop
    --
    if r_prs_tjr.object_version_number = 1 then
      l_tjr_classification := pqh_utility.get_tjr_classification(r_prs_tjr.txn_job_requirement_id);
      hr_utility.set_location('l_tjr_classification:'||nvl(l_tjr_classification,'NULL'), 1000);
      append_if_not_present(l_tjr_changed, l_tjr_classification);
      --
      delete pqh_txn_job_requirements
      where txn_job_requirement_id = r_prs_tjr.txn_job_requirement_id;
      --
      delete pqh_tjr_shadow
      where txn_job_requirement_id = r_prs_tjr.txn_job_requirement_id;
    end if;
  end loop;
  --
  populate_job_requirements(p_position_transaction_id, l_position_id, l_tjr_changed);
  create_tjr_shadow(p_position_transaction_id);
  --
  if l_tjr_changed is not null then
    fnd_message.set_name('PQH', 'PQH_REQUIREMENTS_LIST');
    fnd_message.set_token('CLASSIFICATIONS', l_tjr_changed);
    l_tjr_changed := fnd_message.get;
  end if;
  --
  p_tjr_changed := l_tjr_changed;
end;
--
--------------------------------------------------------------------------------
procedure refresh_pte(p_transaction_category_id number, p_position_transaction_id number,
  p_position_id number, p_pte_changed out nocopy varchar2) is
l_pte_items_changed varchar2(8000);
l_pte_context_desc varchar2(100);
l_index     number;
l_pei_changed       varchar2(10000);
--
cursor c_pte(p_position_transaction_id number, p_position_id number) is
select ptx_extra_info_id
from pqh_ptx_extra_info
where position_transaction_id = p_position_transaction_id
and position_extra_info_id in
(select position_extra_info_id
 from per_position_extra_info
 where position_id = p_position_id
 and information_type <> 'PQH_POS_ROLE_ID');
--
cursor c_pes_poe(p_position_transaction_id number, p_position_id number) is
select tei.ptx_extra_info_id, tei.object_version_number
from pqh_ptx_extra_info tei, pqh_pte_shadow pps
where
tei.information_type <> 'PQH_POS_ROLE_ID'
and tei.ptx_extra_info_id = pps.ptx_extra_info_id
and tei.position_transaction_id = pps.position_transaction_id
and tei.position_transaction_id = p_position_transaction_id
and not exists (
 select null
 from per_position_extra_info ppei
 where position_id = p_position_id
 and ppei.position_extra_info_id  = pps.position_extra_info_id);
--
begin
  --
  for r_pte in c_pte(p_position_transaction_id, p_position_id)
  loop
    pqh_refresh_data.refresh_data
    (p_txn_category_id  => p_transaction_category_id,
     p_txn_id           => r_pte.ptx_extra_info_ID,
     p_refresh_criteria => 'PTE',
     p_items_changed      => l_pte_items_changed
    );
    hr_utility.set_location('l_pte_items_changed:'||nvl(l_pte_items_changed,'NULL'), 1000);
    if l_pte_items_changed is not null then
      l_pte_context_desc := pqh_utility.get_pte_context_desc(r_pte.ptx_extra_info_ID);
      hr_utility.set_location('l_pte_context_desc:'||nvl(l_pte_context_desc,'NULL'), 1000);
      append_if_not_present(l_pei_changed, l_pte_context_desc);
    end if;
  end loop;
  --
  for r_pes_poe in c_pes_poe(p_position_transaction_id, p_position_id)
  loop
    --
    if r_pes_poe.object_version_number = 1 then
      l_pte_context_desc := pqh_utility.get_pte_context_desc(r_pes_poe.ptx_extra_info_ID);
      hr_utility.set_location('l_pte_context_desc:'||nvl(l_pte_context_desc,'NULL'), 1000);
      append_if_not_present(l_pei_changed, l_pte_context_desc);
      --
      delete pqh_ptx_extra_info
      where ptx_extra_info_id = r_pes_poe.ptx_extra_info_id;
      --
      delete pqh_pte_shadow
      where ptx_extra_info_id = r_pes_poe.ptx_extra_info_id;
    end if;
  end loop;
  --
  populate_pei(p_position_transaction_id, p_position_id, l_pei_changed);
  create_pte_shadow(p_position_transaction_id);
  --
  if l_pei_changed is not null then
    fnd_message.set_name('PQH', 'PQH_EXTRA_INFO_LIST');
    fnd_message.set_token('INFORMATION_TYPES', l_pei_changed);
    p_pte_changed := fnd_message.get;
  end if;
  --
  --
end;
--
-- ---------------------------------------------------------------------------
-- --------------------------< chk_resesrved_fte >----------------------------
-- ---------------------------------------------------------------------------

Procedure chk_reserved_fte
  (p_position_id               in number
  ,p_fte                       in number
  ,p_position_type             in varchar2
  ,p_effective_date            in date
  ,p_validation_start_date     in date
  ,p_validation_end_date       in date
  ) is

  l_proc         varchar2(72) := 'chk_reserved_fte';
  l_api_updating boolean;
  l_rsv_fte   number;

cursor csr_valid_fte(p_position_id number, p_effective_date date) is
select sum(poei_information6) fte
from per_position_extra_info
where position_id = p_position_id
and information_type= 'PER_RESERVED'
and p_effective_date
  between fnd_date.canonical_to_date(poei_information3)
  and nvl(fnd_date.canonical_to_date(poei_information4),hr_general.end_of_time);
  --
cursor csr_valid_eff_date(p_position_id number, p_validation_start_date date, p_validation_end_date date) is
select p_validation_start_date start_date
from dual
union
select start_date
from (select fnd_date.canonical_to_date(poei_information3) start_date
      from per_position_extra_info
      where position_id = p_position_id
      and information_type = 'PER_RESERVED') a
where a.start_date between p_validation_start_date and p_validation_end_date;
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
    --
    for r2 in csr_valid_eff_date(p_position_id, p_validation_start_date, p_validation_end_date) loop
    if p_position_type ='SHARED' or p_position_type ='SINGLE' then
        open csr_valid_fte(p_position_id, r2.start_date);
         fetch csr_valid_fte into l_rsv_fte;
         if (p_fte < l_rsv_fte) then
            hr_utility.set_message(800,'PER_FTE_LT_RSVD_FTE');
            hr_utility.set_message_token('POSITION_FTE',p_fte);
            hr_utility.set_message_token('RESERVED_FTE',l_rsv_fte);
            hr_utility.set_message_token('EFFECTIVE_DATE',r2.start_date);
            hr_utility.raise_error;
         else
            hr_utility.set_location(l_proc, 3);
         end if;
      --
       close csr_valid_fte;
    end if;
    end loop;
  --
end chk_reserved_fte;
--
--
--
--
procedure recalculate_bvr_avail(p_budget_version_id number) is
--
cursor c_bvr(p_budget_version_id number) is
select bgt.budget_style_cd,
       budget_version_id, bvr.object_version_number,
       budget_unit1_value, budget_unit2_value, budget_unit3_value
from pqh_budget_versions bvr, pqh_budgets bgt
where budget_version_id = p_budget_version_id
and bvr.budget_id = bgt.budget_id;
--
cursor c_total_bdt(p_budget_version_id number) is
SELECT sum(nvl(BUDGET_UNIT1_VALUE,0)) ,
       sum(nvl(BUDGET_UNIT2_VALUE,0)) ,
       sum(nvl(BUDGET_UNIT3_VALUE,0))
FROM pqh_budget_details
WHERE budget_version_id = p_budget_version_id;
--
l_budget_unit1_available number;
l_budget_unit2_available number;
l_budget_unit3_available number;
--
l_bdt_unit1 number;
l_bdt_unit2 number;
l_bdt_unit3 number;
--
begin
   for r_bvr in c_bvr(p_budget_version_id)
   loop
     --
     open c_total_bdt(p_budget_version_id);
     fetch c_total_bdt into l_bdt_unit1, l_bdt_unit2, l_bdt_unit3;
     close c_total_bdt;
     --
     if r_bvr.budget_style_cd = 'BOTTOM' then
        --
        pqh_budget_versions_api.update_budget_version
         (
          p_validate                        => false
         ,p_budget_version_id               => r_bvr.budget_version_id
         ,p_object_version_number           => r_bvr.object_version_number
         ,p_budget_unit1_value              => l_bdt_unit1
         ,p_budget_unit2_value              => l_bdt_unit2
         ,p_budget_unit3_value              => l_bdt_unit3
         ,p_budget_unit1_available          => null
         ,p_budget_unit2_available          => null
         ,p_budget_unit3_available          => null
         ,p_effective_date                  => sysdate
         );
     else
        --
        if nvl(r_bvr.budget_unit1_value,0) >0 then
          l_budget_unit1_available := r_bvr.budget_unit1_value - l_bdt_unit1;
        else
          l_budget_unit1_available := null;
        end if;
        if nvl(r_bvr.budget_unit2_value,0) >0 then
          l_budget_unit2_available := r_bvr.budget_unit2_value - l_bdt_unit2;
        else
          l_budget_unit2_available := null;
        end if;
        if nvl(r_bvr.budget_unit3_value,0) >0 then
          l_budget_unit3_available := r_bvr.budget_unit3_value - l_bdt_unit3;
        else
          l_budget_unit3_available := null;
        end if;
        --
        pqh_budget_versions_api.update_budget_version
         (
          p_validate                        => false
         ,p_budget_version_id               => r_bvr.budget_version_id
         ,p_object_version_number           => r_bvr.object_version_number
         ,p_budget_unit1_available          => l_budget_unit1_available
         ,p_budget_unit2_available          => l_budget_unit2_available
         ,p_budget_unit3_available          => l_budget_unit3_available
         ,p_effective_date                  => sysdate
         );
     end if;
   end loop;
end;
--
--
--
--
FUNCTION get_unit_precision(p_currency_code in varchar2) RETURN number IS
   l_ext_precision number;
   l_precision number;
   l_min_acct number;
BEGIN
   fnd_currency.get_info(currency_code => p_currency_code,
                         precision     => l_precision,
                         ext_precision => l_ext_precision,
                         min_acct_unit => l_min_acct);
   return l_precision;
END;
--
--
procedure get_unit_precision(p_budget_id number,
                             p_unit1_precision OUT NOCOPY varchar2,
                             p_unit2_precision OUT NOCOPY varchar2,
                             p_unit3_precision OUT NOCOPY varchar2) as
   --
   cursor c1 is select currency_code
                from per_business_groups
                where business_group_id = hr_general.get_business_group_id;
   --
   cursor b1(p_budget_id number) is
   select currency_code, budget_unit1_id, budget_unit2_id, budget_unit3_id,
          pqh_wks_budget.get_unit_type(budget_unit1_id),
          pqh_wks_budget.get_unit_type(budget_unit2_id),
          pqh_wks_budget.get_unit_type(budget_unit3_id)
   from pqh_budgets
   where budget_id = p_budget_id;
   --
   l_budget_currency_code varchar2(15);
   l_budget_unit1_id number;
   l_budget_unit2_id number;
   l_budget_unit3_id number;
   l_budget_unit1_type_cd varchar2(15);
   l_budget_unit2_type_cd varchar2(15);
   l_budget_unit3_type_cd varchar2(15);
   l_currency_code varchar2(15);
begin
      open b1(p_budget_id);
      fetch b1 into l_budget_currency_code, l_budget_unit1_id,
                    l_budget_unit2_id, l_budget_unit3_id,
                    l_budget_unit1_type_cd, l_budget_unit2_type_cd,
                    l_budget_unit3_type_cd;
      if l_budget_currency_code is null then
         open c1;
         fetch c1 into l_currency_code;
         close c1;
      else
         l_currency_code := l_budget_currency_code;
      end if;
      --
      if l_budget_unit1_id is not null then
         --
         if l_budget_unit1_type_cd ='MONEY' then
            --
            if l_currency_code is not null then
              p_unit1_precision := get_unit_precision(l_currency_code);
            else
              p_unit1_precision := 2;
            end if;
            --
         else
            p_unit1_precision := 2;
         end if;
      end if;
      if l_budget_unit2_id is not null then
         --
         if l_budget_unit2_type_cd ='MONEY' then
            --
            if l_budget_currency_code is not null then
              p_unit2_precision := get_unit_precision(l_currency_code);
            else
              p_unit2_precision := 2;
            end if;
            --
         else
            p_unit2_precision := 2;
         end if;
      end if;
      if l_budget_unit3_id is not null then
         --
         if l_budget_unit3_type_cd ='MONEY' then
            --
            if l_currency_code is not null then
              p_unit3_precision := get_unit_precision(l_currency_code);
            else
              p_unit3_precision := 2;
            end if;
            --
         else
            p_unit3_precision := 2;
         end if;
      end if;
end;
--
--
procedure default_budget_set_info(p_budget_period_id number, p_dflt_budget_set_id number,
                                  p_period_unit1_value number,
                                  p_period_unit2_value number,
                                  p_period_unit3_value number) is
  l_budget_set_id number(15);
  l_object_version_number number(15);
begin
if p_dflt_budget_set_id is not null then
  --
  -- new period is added for a posted budget
  --   budget_detail_chg_to_gl;

   pqh_budget_sets_api.create_budget_set(
      p_validate                    => FALSE
      ,p_budget_set_id              => l_budget_set_id
      ,p_dflt_budget_set_id         => p_dflt_budget_set_id
      ,p_budget_period_id           => p_budget_period_id
      ,p_budget_unit1_value         => p_period_unit1_value
      ,p_budget_unit1_percent       => 100
      ,p_budget_unit1_available     => p_period_unit1_value
      ,p_budget_unit1_value_type_cd => 'V'
      ,p_budget_unit2_value         => p_period_unit2_value
      ,p_budget_unit2_percent       => 100
      ,p_budget_unit2_available     => p_period_unit2_value
      ,p_budget_unit2_value_type_cd => 'V'
      ,p_budget_unit3_value         => p_period_unit3_value
      ,p_budget_unit3_percent       => 100
      ,p_budget_unit3_value_type_cd => 'V'
      ,p_budget_unit3_available     => p_period_unit3_value
      ,p_object_version_number      => l_object_version_number
      ,p_effective_date             => trunc(sysdate)
    );

  --
  -- The following call will pull the default element and fund sources from
  -- pqh_dflt_budget_elements and pqh_dflt_fund_srcs and insert in
  -- pqh_budget_elements and pqh_budget_fund_srcs.
  --

  pqh_wks_budget.insert_budgetset
  (p_dflt_budget_set_id => p_dflt_budget_set_id,
   p_budget_set_id      => l_budget_set_id
  );
end if;
end;
--
--
--
procedure apply_ptx_budgets(p_position_transaction_id number) is
--
cursor c_worksheets(p_position_transaction_id number) is
select distinct wks.worksheet_id, wks.budget_version_id,
                wdt.worksheet_detail_id, wdt.budget_detail_id
from pqh_worksheets wks, pqh_worksheet_details wdt
where wks.worksheet_id = wdt.worksheet_id
and wks.worksheet_mode_cd = 'O'
and wdt.position_transaction_id = p_position_transaction_id;
--
cursor c_worksheet_details(p_worksheet_detail_id number) is
select *
from pqh_worksheet_details
where worksheet_detail_id = p_worksheet_detail_id;
--
cursor c_worksheet_periods(p_worksheet_detail_id number) is
select *
from pqh_worksheet_periods
where worksheet_detail_id = p_worksheet_detail_id;
--
CURSOR units_csr(p_budget_version_id number) IS
SELECT nvl(BUDGET_UNIT1_VALUE,0) ,
       nvl(BUDGET_UNIT2_VALUE,0) ,
       nvl(BUDGET_UNIT3_VALUE,0),
       bgt.budget_style_cd,
       bgt.dflt_budget_set_id
FROM pqh_budget_versions bvr, pqh_budgets bgt
WHERE budget_version_id = p_budget_version_id
and bvr.budget_id = bgt.budget_id;
--
CURSOR l_object_version_number_cur(p_budget_detail_id number) IS
SELECT object_version_number
FROM pqh_budget_details
WHERE budget_detail_id = p_budget_detail_id;
--
CURSOR l_bpr_ovn_cur(p_budget_period_id number) IS
SELECT object_version_number
FROM pqh_budget_periods
WHERE budget_period_id = p_budget_period_id;
--
l_proc                        varchar2(72) := g_package||'apply_ptx_budgets';
l_budget_style_cd             pqh_budgets.budget_style_cd%type;
l_budget_detail_id            number;
l_budget_period_id            number;
l_version_unit1_value         number;
l_version_unit2_value         number;
l_version_unit3_value         number;
l_budget_unit1_percent        number;
l_budget_unit2_percent        number;
l_budget_unit3_percent        number;
l_object_version_number       pqh_budget_details.object_version_number%TYPE;
l_bpr_object_version_number   pqh_budget_periods.object_version_number%TYPE;
l_propagate varchar2(15);
l_bpr_budget_unit1_available number;
l_bpr_budget_unit2_available number;
l_bpr_budget_unit3_available number;
l_unit1_precision number;
l_unit2_precision number;
l_unit3_precision number;
l_dflt_budget_set_id number;
--
begin
  for r_wst in c_worksheets(p_position_transaction_id)
  loop
    -- compute the unit values
    OPEN units_csr(r_wst.budget_version_id);
    FETCH units_csr INTO l_version_unit1_value, l_version_unit2_value,
                         l_version_unit3_value,
                         l_budget_style_cd, l_dflt_budget_set_id;
    CLOSE units_csr;
    --
    for p_worksheet_details_rec in c_worksheet_details(r_wst.worksheet_detail_id)
    loop

      if l_budget_style_cd = 'BOTTOM' then
        l_budget_unit1_percent := null;
        l_budget_unit2_percent := null;
        l_budget_unit3_percent := null;
      else
        if nvl(l_version_unit1_value,0) >0 then
         l_budget_unit1_percent := (p_worksheet_details_rec.budget_unit1_value*100)/l_version_unit1_value ;
        else
         l_budget_unit1_percent := null;
        end if;
        if nvl(l_version_unit2_value,0) >0 then
         l_budget_unit2_percent := (p_worksheet_details_rec.budget_unit2_value*100)/l_version_unit2_value ;
        else
         l_budget_unit2_percent := null;
        end if;
        if nvl(l_version_unit3_value,0) >0 then
         l_budget_unit3_percent := (p_worksheet_details_rec.budget_unit3_value*100)/l_version_unit3_value ;
        else
         l_budget_unit3_percent := null;
        end if;
      end if;
      --
      if p_worksheet_details_rec.budget_detail_id is not null then
        l_budget_detail_id := p_worksheet_details_rec.budget_detail_id;
        -- update rows where p_worksheet_details_rec.budget_detail_id IS NOT NULL
        hr_utility.set_location('Budget Detail Id : '||p_worksheet_details_rec.budget_detail_id, 7);

        -- get the object_version_number for this budget_detail_id and pass to update API
        OPEN l_object_version_number_cur(p_worksheet_details_rec.budget_detail_id);
        FETCH l_object_version_number_cur INTO l_object_version_number;
        CLOSE l_object_version_number_cur;

        hr_utility.set_location('Update API OVN  : '||l_object_version_number, 8);

        pqh_budget_details_api.update_budget_detail
        (
         p_validate                       =>  false
        ,p_budget_detail_id               =>  p_worksheet_details_rec.budget_detail_id
        ,p_organization_id                =>  p_worksheet_details_rec.organization_id
        ,p_job_id                         =>  p_worksheet_details_rec.job_id
        ,p_position_id                    =>  p_worksheet_details_rec.position_id
        ,p_grade_id                       =>  p_worksheet_details_rec.grade_id
        ,p_budget_version_id              =>  r_wst.budget_version_id
        ,p_budget_unit1_percent           =>  l_budget_unit1_percent
        ,p_budget_unit1_value_type_cd     =>  p_worksheet_details_rec.budget_unit1_value_type_cd
        ,p_budget_unit1_value             =>  p_worksheet_details_rec.budget_unit1_value
        ,p_budget_unit1_available         =>  p_worksheet_details_rec.budget_unit1_available
        ,p_budget_unit2_percent           =>  l_budget_unit2_percent
        ,p_budget_unit2_value_type_cd     =>  p_worksheet_details_rec.budget_unit2_value_type_cd
        ,p_budget_unit2_value             =>  p_worksheet_details_rec.budget_unit2_value
        ,p_budget_unit2_available         =>  p_worksheet_details_rec.budget_unit2_available
        ,p_budget_unit3_percent           =>  l_budget_unit3_percent
        ,p_budget_unit3_value_type_cd     =>  p_worksheet_details_rec.budget_unit3_value_type_cd
        ,p_budget_unit3_value             =>  p_worksheet_details_rec.budget_unit3_value
        ,p_budget_unit3_available         =>  p_worksheet_details_rec.budget_unit3_available
        ,p_object_version_number          =>  l_object_version_number
        );
        l_budget_detail_id  := p_worksheet_details_rec.budget_detail_id;
      else
        -- for others i.e new rows call the insert API

        hr_utility.set_location('Create API in update mode : ', 9);

        pqh_budget_details_api.create_budget_detail
        (
         p_validate                       =>  false
        ,p_budget_detail_id               =>  l_budget_detail_id
        ,p_organization_id                =>  p_worksheet_details_rec.organization_id
        ,p_job_id                         =>  p_worksheet_details_rec.job_id
        ,p_position_id                    =>  p_worksheet_details_rec.position_id
        ,p_grade_id                       =>  p_worksheet_details_rec.grade_id
        ,p_budget_version_id              =>  r_wst.budget_version_id
        ,p_budget_unit1_percent           =>  l_budget_unit1_percent
        ,p_budget_unit1_value_type_cd     =>  p_worksheet_details_rec.budget_unit1_value_type_cd
        ,p_budget_unit1_value             =>  p_worksheet_details_rec.budget_unit1_value
        ,p_budget_unit1_available         =>  p_worksheet_details_rec.budget_unit1_available
        ,p_budget_unit2_percent           =>  l_budget_unit2_percent
        ,p_budget_unit2_value_type_cd     =>  p_worksheet_details_rec.budget_unit2_value_type_cd
        ,p_budget_unit2_value             =>  p_worksheet_details_rec.budget_unit2_value
        ,p_budget_unit2_available         =>  p_worksheet_details_rec.budget_unit2_available
        ,p_budget_unit3_percent           =>  l_budget_unit3_percent
        ,p_budget_unit3_value_type_cd     =>  p_worksheet_details_rec.budget_unit3_value_type_cd
        ,p_budget_unit3_value             =>  p_worksheet_details_rec.budget_unit3_value
        ,p_budget_unit3_available         =>  p_worksheet_details_rec.budget_unit3_available
        ,p_object_version_number          =>  l_object_version_number
        );
      end if;

      -- Apply Budget Periods
      for p_worksheet_periods_rec in c_worksheet_periods(r_wst.worksheet_detail_id)
      loop
        --
        if p_worksheet_periods_rec.budget_period_id is not null then
          l_budget_period_id := p_worksheet_periods_rec.budget_period_id;
          -- update rows where p_worksheet_periods_rec.budget_period_id IS NOT NULL
          hr_utility.set_location('Budget Period Id : '||p_worksheet_periods_rec.budget_period_id, 7);

        -- Populate all other levels
--      pqh_apply_budget.ptx_budget_periods(r_wst.worksheet_detail_id);
        if l_budget_period_id is not null then
        begin
         --l_propagate := check_budget_details.chk_period_propagate(p_budget_period_id => l_budget_period_id);
         l_propagate := 'TRUE';
         if l_propagate = 'TRUE' then
         BEGIN
           get_unit_precision(1 ,
                             l_unit1_precision,
                             l_unit2_precision,
                             l_unit3_precision);

           pqh_bdgt.propagate_period_changes(
            p_change_mode         => 'UE',
            p_budget_period_id    => l_budget_period_id,
            p_new_prd_unit1_value => p_worksheet_periods_rec.budget_unit1_value,
            p_new_prd_unit2_value => p_worksheet_periods_rec.budget_unit2_value,
            p_new_prd_unit3_value => p_worksheet_periods_rec.budget_unit3_value,
            p_unit1_precision     => l_unit1_precision, --:budgets.unit1_precision,
            p_unit2_precision     => l_unit2_precision, --:budgets.unit2_precision,
            p_unit3_precision     => l_unit3_precision, --:budgets.unit3_precision,
            p_prd_unit1_available => l_bpr_budget_unit1_available,
            p_prd_unit2_available => l_bpr_budget_unit2_available,
            p_prd_unit3_available => l_bpr_budget_unit3_available);
         EXCEPTION
           when others then
             fnd_message.set_name('PQH','PQH_WKS_PERIOD_PROP_ERROR');
             fnd_message.raise_error;
         END;
         end if;
        end;
        end if;

          -- get the object_version_number for this budget_detail_id and pass to update API
          OPEN l_bpr_ovn_cur(p_worksheet_periods_rec.budget_period_id);
          FETCH l_bpr_ovn_cur INTO l_bpr_object_version_number;
          CLOSE l_bpr_ovn_cur;

          hr_utility.set_location('Update API OVN  : '||l_bpr_object_version_number, 8);

          pqh_budget_periods_api.update_budget_period
          (
           p_validate                       =>  false
          ,p_budget_period_id               =>  l_budget_period_id
          ,p_budget_detail_id               =>  l_budget_detail_id
          ,p_start_time_period_id           =>  p_worksheet_periods_rec.start_time_period_id
          ,p_end_time_period_id             =>  p_worksheet_periods_rec.end_time_period_id
          ,p_budget_unit1_percent           =>  p_worksheet_periods_rec.budget_unit1_percent
          ,p_budget_unit2_percent           =>  p_worksheet_periods_rec.budget_unit2_percent
          ,p_budget_unit3_percent           =>  p_worksheet_periods_rec.budget_unit3_percent
          ,p_budget_unit1_value             =>  p_worksheet_periods_rec.budget_unit1_value
          ,p_budget_unit2_value             =>  p_worksheet_periods_rec.budget_unit2_value
          ,p_budget_unit3_value             =>  p_worksheet_periods_rec.budget_unit3_value
          ,p_budget_unit1_value_type_cd     =>  p_worksheet_periods_rec.budget_unit1_value_type_cd
          ,p_budget_unit2_value_type_cd     =>  p_worksheet_periods_rec.budget_unit2_value_type_cd
          ,p_budget_unit3_value_type_cd     =>  p_worksheet_periods_rec.budget_unit3_value_type_cd
          ,p_budget_unit1_available         =>  l_bpr_budget_unit1_available --p_worksheet_periods_rec.budget_unit1_available
          ,p_budget_unit2_available         =>  l_bpr_budget_unit2_available --p_worksheet_periods_rec.budget_unit2_available
          ,p_budget_unit3_available         =>  l_bpr_budget_unit3_available --p_worksheet_periods_rec.budget_unit3_available
          ,p_object_version_number          =>  l_bpr_object_version_number
          );
        else
          -- for others i.e new rows call the insert API

          hr_utility.set_location('Create API in update mode : ', 9);

          pqh_budget_periods_api.create_budget_period
          (
           p_validate                       =>  false
          ,p_budget_period_id               =>  l_budget_period_id
          ,p_budget_detail_id               =>  l_budget_detail_id
          ,p_start_time_period_id           =>  p_worksheet_periods_rec.start_time_period_id
          ,p_end_time_period_id             =>  p_worksheet_periods_rec.end_time_period_id
          ,p_budget_unit1_percent           =>  p_worksheet_periods_rec.budget_unit1_percent
          ,p_budget_unit2_percent           =>  p_worksheet_periods_rec.budget_unit2_percent
          ,p_budget_unit3_percent           =>  p_worksheet_periods_rec.budget_unit3_percent
          ,p_budget_unit1_value             =>  p_worksheet_periods_rec.budget_unit1_value
          ,p_budget_unit2_value             =>  p_worksheet_periods_rec.budget_unit2_value
          ,p_budget_unit3_value             =>  p_worksheet_periods_rec.budget_unit3_value
          ,p_budget_unit1_value_type_cd     =>  p_worksheet_periods_rec.budget_unit1_value_type_cd
          ,p_budget_unit2_value_type_cd     =>  p_worksheet_periods_rec.budget_unit2_value_type_cd
          ,p_budget_unit3_value_type_cd     =>  p_worksheet_periods_rec.budget_unit3_value_type_cd
          ,p_budget_unit1_available         =>  p_worksheet_periods_rec.budget_unit1_available
          ,p_budget_unit2_available         =>  p_worksheet_periods_rec.budget_unit2_available
          ,p_budget_unit3_available         =>  p_worksheet_periods_rec.budget_unit3_available
          ,p_object_version_number          =>  l_bpr_object_version_number
          );
          --
          --
          --
          default_budget_set_info(
            p_budget_period_id   => l_budget_period_id,
            p_dflt_budget_set_id => l_dflt_budget_set_id,
            p_period_unit1_value => p_worksheet_periods_rec.budget_unit1_value,
            p_period_unit2_value => p_worksheet_periods_rec.budget_unit2_value,
            p_period_unit3_value => p_worksheet_periods_rec.budget_unit3_value);
          --
          --
          --
        end if;
        --
        --
      end loop;
      --
    end loop;
    -- Re-calculate budget version available
    recalculate_bvr_avail(r_wst.budget_version_id);
  end loop;
  --
end;
--
end pqh_ptx_utl;

/
