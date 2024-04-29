--------------------------------------------------------
--  DDL for Package Body IRC_OFFERS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_OFFERS_API" as
/* $Header: iriofapi.pkb 120.24.12010000.12 2010/03/18 07:39:15 amikukum ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'IRC_OFFERS_API.';
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_offer_assignment_copy >---------------------|
-- ----------------------------------------------------------------------------
-- This procedure duplicates an offer assignment from the source assignment id
-- which could either be the applicant assignment or the previous offer
-- assignment.
-- ----------------------------------------------------------------------------
--
    procedure create_offer_assignment_copy
    ( P_VALIDATE                     IN   boolean     default false
     ,P_EFFECTIVE_DATE               IN   date        default null
     ,P_SOURCE_ASSIGNMENT_ID         IN   number
     ,P_OFFER_ASSIGNMENT_ID          OUT  nocopy number
    ) Is
--
    l_proc                           varchar2(72) := g_package||'create_offer_assignment_copy';
--
--  Out and In Out variables
--
    l_effective_start_date           per_all_assignments_f.effective_start_date%TYPE;
    l_effective_end_date             per_all_assignments_f.effective_end_date%TYPE;
    l_assignment_sequence            per_all_assignments_f.assignment_sequence%TYPE;
    l_assignment_number              per_all_assignments_f.assignment_number%TYPE;
    l_offer_assignment_id            per_all_assignments_f.assignment_id%TYPE;
    l_comment_id                     per_all_assignments_f.comment_id%TYPE;
    l_object_version_number          per_all_assignments_f.object_version_number%TYPE;
    l_other_manager_warning          boolean;
    l_hourly_salaried_warning        boolean;

    l_validation_start_date          date;
    l_validation_end_date            date;
--
--  variables to be set
--
    l_assignment_type                per_all_assignments_f.assignment_type%TYPE;
    l_primary_flag                   per_all_assignments_f.primary_flag%TYPE;
--
--  Date Variables
--
    l_date_probation_end             per_all_assignments_f.date_probation_end%TYPE;
    l_effective_date                 date;
    l_program_update_date            per_all_assignments_f.program_update_date%TYPE;
--
-- Define cursor
--
   cursor csr_assignment_record is
   select
     business_group_id
    ,recruiter_id
    ,grade_id
    ,position_id
    ,job_id
    ,assignment_status_type_id
    ,payroll_id
    ,location_id
    ,person_referred_by_id
    ,supervisor_id
    ,special_ceiling_step_id
    ,person_id
    ,recruitment_activity_id
    ,source_organization_id
    ,organization_id
    ,people_group_id
    ,soft_coding_keyflex_id
    ,vacancy_id
    ,pay_basis_id
    ,assignment_sequence
    ,assignment_type
    ,primary_flag
    ,application_id
    ,assignment_number
    ,change_reason
    ,comment_id
    ,date_probation_end
    ,default_code_comb_id
    ,employment_category
    ,frequency
    ,internal_address_line
    ,manager_flag
    ,normal_hours
    ,perf_review_period
    ,perf_review_period_frequency
    ,period_of_service_id
    ,probation_period
    ,probation_unit
    ,sal_review_period
    ,sal_review_period_frequency
    ,set_of_books_id
    ,source_type
    ,time_normal_finish
    ,time_normal_start
    ,bargaining_unit_code
    ,labour_union_member_flag
    ,hourly_salaried_code
    ,request_id
    ,program_application_id
    ,program_id
    ,program_update_date
    ,ass_attribute_category
    ,ass_attribute1
    ,ass_attribute2
    ,ass_attribute3
    ,ass_attribute4
    ,ass_attribute5
    ,ass_attribute6
    ,ass_attribute7
    ,ass_attribute8
    ,ass_attribute9
    ,ass_attribute10
    ,ass_attribute11
    ,ass_attribute12
    ,ass_attribute13
    ,ass_attribute14
    ,ass_attribute15
    ,ass_attribute16
    ,ass_attribute17
    ,ass_attribute18
    ,ass_attribute19
    ,ass_attribute20
    ,ass_attribute21
    ,ass_attribute22
    ,ass_attribute23
    ,ass_attribute24
    ,ass_attribute25
    ,ass_attribute26
    ,ass_attribute27
    ,ass_attribute28
    ,ass_attribute29
    ,ass_attribute30
    ,title
    ,contract_id
    ,establishment_id
    ,collective_agreement_id
    ,cagr_grade_def_id
    ,cagr_id_flex_num
    ,notice_period
    ,notice_period_uom
    ,employee_category
    ,work_at_home
    ,job_post_source_name
    ,posting_content_id
    ,vendor_id
    ,vendor_employee_number
    ,vendor_assignment_number
    ,assignment_category
    ,project_title
    ,applicant_rank
    ,grade_ladder_pgm_id
    ,supervisor_assignment_id
    ,object_version_number
  from per_all_assignments_f
  where assignment_id = p_source_assignment_id
    and p_effective_date
between effective_start_date
    and effective_end_date;

  l_offer_assignment    csr_assignment_record%ROWTYPE;
--
Begin

  hr_utility.set_location('Entering:'||l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_OFFER_ASSIGNMENT_COPY;
  --
  open  csr_assignment_record;
  fetch csr_assignment_record into l_offer_assignment;
  --
  if csr_assignment_record%notfound
  then
    --
    close csr_assignment_record;
    fnd_message.set_name('PER','HR_289541_PJU_INV_ASG_ID');
    fnd_message.raise_error;
    --
  end if;
  close csr_assignment_record;
  --
  hr_utility.set_location(l_proc,20);
  --
  hr_utility.set_location(l_proc,30);
  --
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date      := trunc(p_effective_date);
  l_date_probation_end  := trunc(l_offer_assignment.date_probation_end);
  l_program_update_date := trunc(l_offer_assignment.program_update_date);
  --
  -- The offer record must have an assignment_type = 'O'
  -- and the primary_flag must be set to 'N'
  --
  l_assignment_type    := 'O';
  l_primary_flag       := 'N';
  --
  hr_utility.set_location(l_proc,40);
  --
  -- Create Offer Assignment record
  --
  per_asg_ins.ins
  (  p_assignment_id                => l_offer_assignment_id
    ,p_effective_start_date         => l_effective_start_date
    ,p_effective_end_date           => l_effective_end_date
    ,p_business_group_id            => l_offer_assignment.business_group_id
    ,p_recruiter_id                 => l_offer_assignment.recruiter_id
    ,p_grade_id                     => l_offer_assignment.grade_id
    ,p_position_id                  => l_offer_assignment.position_id
    ,p_job_id                       => l_offer_assignment.job_id
    ,p_assignment_status_type_id    => l_offer_assignment.assignment_status_type_id
    ,p_payroll_id                   => l_offer_assignment.payroll_id
    ,p_location_id                  => l_offer_assignment.location_id
    ,p_person_referred_by_id        => l_offer_assignment.person_referred_by_id
    ,p_supervisor_id                => l_offer_assignment.supervisor_id
    ,p_special_ceiling_step_id      => l_offer_assignment.special_ceiling_step_id
    ,p_person_id                    => l_offer_assignment.person_id
    ,p_recruitment_activity_id      => l_offer_assignment.recruitment_activity_id
    ,p_source_organization_id       => l_offer_assignment.source_organization_id
    ,p_organization_id              => l_offer_assignment.organization_id
    ,p_people_group_id              => l_offer_assignment.people_group_id
    ,p_soft_coding_keyflex_id       => l_offer_assignment.soft_coding_keyflex_id
    ,p_vacancy_id                   => l_offer_assignment.vacancy_id
    ,p_pay_basis_id                 => l_offer_assignment.pay_basis_id
    ,p_assignment_sequence          => l_assignment_sequence
    ,p_assignment_type              => l_assignment_type
    ,p_primary_flag                 => l_primary_flag
    ,p_application_id               => l_offer_assignment.application_id
    ,p_assignment_number            => l_assignment_number
    ,p_change_reason                => l_offer_assignment.change_reason
    ,p_comment_id                   => l_comment_id
    ,p_date_probation_end           => l_date_probation_end
    ,p_default_code_comb_id         => l_offer_assignment.default_code_comb_id
    ,p_employment_category          => l_offer_assignment.employment_category
    ,p_frequency                    => l_offer_assignment.frequency
    ,p_internal_address_line        => l_offer_assignment.internal_address_line
    ,p_manager_flag                 => l_offer_assignment.manager_flag
    ,p_normal_hours                 => l_offer_assignment.normal_hours
    ,p_perf_review_period           => l_offer_assignment.perf_review_period
    ,p_perf_review_period_frequency => l_offer_assignment.perf_review_period_frequency
    ,p_period_of_service_id         => l_offer_assignment.period_of_service_id
    ,p_probation_period             => l_offer_assignment.probation_period
    ,p_probation_unit               => l_offer_assignment.probation_unit
    ,p_sal_review_period            => l_offer_assignment.sal_review_period
    ,p_sal_review_period_frequency  => l_offer_assignment.sal_review_period_frequency
    ,p_set_of_books_id              => l_offer_assignment.set_of_books_id
    ,p_source_type                  => l_offer_assignment.source_type
    ,p_time_normal_finish           => l_offer_assignment.time_normal_finish
    ,p_time_normal_start            => l_offer_assignment.time_normal_start
    ,p_bargaining_unit_code         => l_offer_assignment.bargaining_unit_code
    ,p_labour_union_member_flag     => l_offer_assignment.labour_union_member_flag
    ,p_hourly_salaried_code         => l_offer_assignment.hourly_salaried_code
    ,p_request_id                   => l_offer_assignment.request_id
    ,p_program_application_id       => l_offer_assignment.program_application_id
    ,p_program_id                   => l_offer_assignment.program_id
    ,p_program_update_date          => l_program_update_date
    ,p_ass_attribute_category       => l_offer_assignment.ass_attribute_category
    ,p_ass_attribute1               => l_offer_assignment.ass_attribute1
    ,p_ass_attribute2               => l_offer_assignment.ass_attribute2
    ,p_ass_attribute3               => l_offer_assignment.ass_attribute3
    ,p_ass_attribute4               => l_offer_assignment.ass_attribute4
    ,p_ass_attribute5               => l_offer_assignment.ass_attribute5
    ,p_ass_attribute6               => l_offer_assignment.ass_attribute6
    ,p_ass_attribute7               => l_offer_assignment.ass_attribute7
    ,p_ass_attribute8               => l_offer_assignment.ass_attribute8
    ,p_ass_attribute9               => l_offer_assignment.ass_attribute9
    ,p_ass_attribute10              => l_offer_assignment.ass_attribute10
    ,p_ass_attribute11              => l_offer_assignment.ass_attribute11
    ,p_ass_attribute12              => l_offer_assignment.ass_attribute12
    ,p_ass_attribute13              => l_offer_assignment.ass_attribute13
    ,p_ass_attribute14              => l_offer_assignment.ass_attribute14
    ,p_ass_attribute15              => l_offer_assignment.ass_attribute15
    ,p_ass_attribute16              => l_offer_assignment.ass_attribute16
    ,p_ass_attribute17              => l_offer_assignment.ass_attribute17
    ,p_ass_attribute18              => l_offer_assignment.ass_attribute18
    ,p_ass_attribute19              => l_offer_assignment.ass_attribute19
    ,p_ass_attribute20              => l_offer_assignment.ass_attribute20
    ,p_ass_attribute21              => l_offer_assignment.ass_attribute21
    ,p_ass_attribute22              => l_offer_assignment.ass_attribute22
    ,p_ass_attribute23              => l_offer_assignment.ass_attribute23
    ,p_ass_attribute24              => l_offer_assignment.ass_attribute24
    ,p_ass_attribute25              => l_offer_assignment.ass_attribute25
    ,p_ass_attribute26              => l_offer_assignment.ass_attribute26
    ,p_ass_attribute27              => l_offer_assignment.ass_attribute27
    ,p_ass_attribute28              => l_offer_assignment.ass_attribute28
    ,p_ass_attribute29              => l_offer_assignment.ass_attribute29
    ,p_ass_attribute30              => l_offer_assignment.ass_attribute30
    ,p_title                        => l_offer_assignment.title
    ,p_object_version_number        => l_object_version_number
    ,p_other_manager_warning        => l_other_manager_warning
    ,p_hourly_salaried_warning      => l_hourly_salaried_warning
    ,p_effective_date               => l_effective_date
    ,p_validate                     => p_validate
    ,p_contract_id                  => l_offer_assignment.contract_id
    ,p_establishment_id             => l_offer_assignment.establishment_id
    ,p_collective_agreement_id      => l_offer_assignment.collective_agreement_id
    ,p_cagr_grade_def_id            => l_offer_assignment.cagr_grade_def_id
    ,p_cagr_id_flex_num             => l_offer_assignment.cagr_id_flex_num
    ,p_notice_period                => l_offer_assignment.notice_period
    ,p_notice_period_uom            => l_offer_assignment.notice_period_uom
    ,p_employee_category            => l_offer_assignment.employee_category
    ,p_work_at_home                 => l_offer_assignment.work_at_home
    ,p_job_post_source_name         => l_offer_assignment.job_post_source_name
    ,p_posting_content_id           => l_offer_assignment.posting_content_id
    ,p_vendor_id                    => l_offer_assignment.vendor_id
    ,p_vendor_employee_number       => l_offer_assignment.vendor_employee_number
    ,p_vendor_assignment_number     => l_offer_assignment.vendor_assignment_number
    ,p_assignment_category          => l_offer_assignment.assignment_category
    ,p_project_title                => l_offer_assignment.project_title
    ,p_applicant_rank               => l_offer_assignment.applicant_rank
    ,p_grade_ladder_pgm_id          => l_offer_assignment.grade_ladder_pgm_id
    ,p_supervisor_assignment_id     => l_offer_assignment.supervisor_assignment_id
    );
  --
  hr_utility.set_location(l_proc, 50);
  --
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  p_offer_assignment_id          := l_offer_assignment_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 60);
  --
exception
  when hr_api.validate_enabled then
    --
    p_offer_assignment_id          := null;
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_OFFER_ASSIGNMENT_COPY;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 70);
  when others then
    --
    p_offer_assignment_id          := null;
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_OFFER_ASSIGNMENT_COPY;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    raise;
end create_offer_assignment_copy;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_appl_assg_status >------------------------|
-- ----------------------------------------------------------------------------
--
   procedure update_appl_assg_status
   ( P_VALIDATE                     IN   boolean     default false
    ,P_EFFECTIVE_DATE               IN   date        default null
    ,P_APPLICANT_ASSIGNMENT_ID      IN   NUMBER
    ,P_OFFER_STATUS                 IN   VARCHAR2
    ,P_CHANGE_REASON                IN   VARCHAR2    default null
   ) is
   --
   l_proc                           varchar2(72) := g_package||'update_appl_assg_status';
   l_prev_assg_status_type          per_all_assignments_f.assignment_status_type_id%TYPE;
   l_assignment_status_type_id      per_all_assignments_f.assignment_status_type_id%TYPE  := -1;
   l_curr_assg_status_type_id       per_all_assignments_f.assignment_status_type_id%TYPE;
   l_business_group_id              per_all_assignments_f.business_group_id%TYPE;
   --
   l_datetrack_mode                 varchar2(30);
   l_asg_object_version_number      per_all_assignments_f.object_version_number%TYPE;
   l_expected_system_status         per_assignment_status_types.per_system_status%TYPE;
   l_effective_start_date           per_all_assignments_f.effective_start_date%TYPE;
   l_effective_end_date             per_all_assignments_f.effective_end_date%TYPE;
   --
   cursor csr_assignment_ovn is
   select object_version_number
         ,effective_start_date
         ,assignment_status_type_id
         ,business_group_id
     from per_all_assignments_f
    where assignment_id = p_applicant_assignment_id
      and p_effective_date
  between effective_start_date
      and effective_end_date;
   --
   --
   cursor csr_get_offer_user_status(p_business_group_id number) is
   select ASSIGNMENT_STATUS_TYPE_ID
     from PER_ASSIGNMENT_STATUS_TYPES_V
    where PER_SYSTEM_STATUS='OFFER'
      and DEFAULT_FLAG = 'Y'
      and BUSINESS_GROUP_ID = p_business_group_id;
   --
   cursor csr_get_accepted_user_status(p_business_group_id number) is
   select ASSIGNMENT_STATUS_TYPE_ID
     from PER_ASSIGNMENT_STATUS_TYPES_V
    where PER_SYSTEM_STATUS='ACCEPTED'
      and DEFAULT_FLAG = 'Y'
      and BUSINESS_GROUP_ID = p_business_group_id;
  --
   cursor csr_prev_assg_status_type(p_business_group_id number) is
   select ias1.assignment_status_type_id
         ,past.per_system_status
     from irc_assignment_statuses ias1
         ,per_assignment_status_types past
    where past.assignment_status_type_id = ias1.assignment_status_type_id
      and ias1.assignment_id = p_applicant_assignment_id
      and ias1.creation_date = (select max(ias2.creation_date)
                                  from irc_assignment_statuses ias2
                                 where ias2.assignment_id = p_applicant_assignment_id
                                   and ias2.assignment_status_type_id not in (5,6)
                                   and ias2.assignment_status_type_id not in (select ASSIGNMENT_STATUS_TYPE_ID
                                                                                from PER_ASSIGNMENT_STATUS_TYPES_V
                                                                               where PER_SYSTEM_STATUS in ('OFFER','ACCEPTED')
                                                                                 and BUSINESS_GROUP_ID = p_business_group_id));
   --
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  -- Since this procedure is called only when the status is changed
  -- we do not need to see if the assignment_status_type_id is already
  -- set to the required value.
  --
  open   csr_assignment_ovn;
  fetch  csr_assignment_ovn into l_asg_object_version_number
                                ,l_effective_start_date
                                ,l_curr_assg_status_type_id
                                ,l_business_group_id;
  if csr_assignment_ovn%notfound
  then
    close csr_assignment_ovn;
    --
    hr_utility.set_location(l_proc,70);
    --
    --
    fnd_message.set_name('PER','IRC_412006_ASG_NOT_APPL');
    fnd_message.raise_error;
    --
  end if;
  close csr_assignment_ovn;
  --
  if   p_change_reason = 'UPDATED' or p_change_reason = 'APL_DECLINED_ACCEPTANCE' or p_change_reason = 'MGR_WITHDRAW'
  then
    --
    -- This is the case where the offer is updated when in EXTENDED or CLOSED status.
    -- 1) The EXTENDED offer is closed and a new offer version is
    --    created. We hence need to set back the Applicant's assignment status to
    --    the status which existed before the most recent 'OFFER' Applicant assignment status.
    -- 2) The offer was previously in CLOSED status before the Applicant
    --    WITHDREW his application it could have been CLOSED previously due to 2
    --    reasons:
    --    1. Applicant Accepted the offer - We need to rollback 2 steps here.
    --                                      One, ACCEPTED assignment status (6)
    --                                      Two, OFFER assignment status (5)
    --    2. Applicant Declined the offer - Do nothing in this case
    --       or, Offer Duration Expired.
    --
    open   csr_prev_assg_status_type(l_business_group_id);
    fetch  csr_prev_assg_status_type into l_prev_assg_status_type
                                         ,l_expected_system_status;
    if csr_prev_assg_status_type%notfound
    then
      close csr_prev_assg_status_type;
      --
      hr_utility.set_location(l_proc,40);
      --
      fnd_message.set_name('PER','IRC_412006_ASG_NOT_APPL');
      fnd_message.raise_error;
      --
    end if;
    close csr_prev_assg_status_type;
    --
    if( l_prev_assg_status_type <> l_curr_assg_status_type_id )
    then
      --
      l_assignment_status_type_id := l_prev_assg_status_type;
      --
    end if;
  --
  elsif   p_offer_status = 'EXTENDED'
  then
    --
    hr_utility.set_location(l_proc,20);
    --
    -- Update the applicant assignment record and set the assignment
    -- status type to 'Offer' ( assignment_status_type_id = 5 )
    --
    open csr_get_offer_user_status(l_business_group_id);
    fetch csr_get_offer_user_status into l_assignment_status_type_id;
    if csr_get_offer_user_status%notfound then
      hr_utility.set_location(l_proc,21);
    l_assignment_status_type_id := 5;
    end if;
    close csr_get_offer_user_status;
    --
  elsif p_offer_status = 'CLOSED'
  then
    --
    hr_utility.set_location(l_proc,25);
    --
    if  p_change_reason = 'EXPIRED'
     or p_change_reason = 'APL_DECLINED'
    then
       --
       -- If the offer has either expired or the applicant has declined the offer,
       -- the applicant assignment status should be set to the assignment status
       -- prior to offer.
       --
       hr_utility.set_location(l_proc,30);
       --
       -- In this scenario, we need to pick up the applicant assignment status
       -- of the assignment record prior to the latest assignment record, becasue
       -- the latest assignment record would have applicant assignment status = 'OFFER'
       --
       open   csr_prev_assg_status_type(l_business_group_id);
       fetch  csr_prev_assg_status_type into l_prev_assg_status_type
                                            ,l_expected_system_status;
       if csr_prev_assg_status_type%notfound
       then
         close csr_prev_assg_status_type;
         --
         hr_utility.set_location(l_proc,40);
         --
         fnd_message.set_name('PER','IRC_412006_ASG_NOT_APPL');
         fnd_message.raise_error;
         --
       end if;
       close csr_prev_assg_status_type;
       --Update only if it is an applicant assignment
       if  l_expected_system_status <> 'ACTIVE_APL'
       and l_expected_system_status <> 'OFFER'
       and l_expected_system_status <> 'ACCEPTED'
       and l_expected_system_status <> 'INTERVIEW1'
       and l_expected_system_status <> 'INTERVIEW2'
       then
        l_assignment_status_type_id := -1;
       else
       l_assignment_status_type_id := l_prev_assg_status_type;
       end if;
       --
    elsif p_change_reason = 'APL_ACCEPTED'
    then
       --
       hr_utility.set_location(l_proc,50);
       --
       -- if the offer has been accepted by the applicant, the applicant assignment
       -- status should be set to 'Accepted' ( assignment_status_type_id = 6 )
       --
       open csr_get_accepted_user_status(l_business_group_id);
       fetch csr_get_accepted_user_status into l_assignment_status_type_id;
       if csr_get_accepted_user_status%notfound then
         hr_utility.set_location(l_proc,51);
       l_assignment_status_type_id := 6;
       end if;
       close csr_get_accepted_user_status;
       --
    end if;
    --
  end if;
  --
  -- only if the assignment_status_type has changed, call 'upd' procedure.
  --
  if l_assignment_status_type_id <> -1
  then
    --
    hr_utility.set_location(l_proc,60);
    --
    -- Decide the date track mode.
    --
    if l_effective_start_date = p_effective_date
    then
       --
       hr_utility.set_location(l_proc,80);
       --
       -- Since the current record has started today, we need to
       -- correct the existing record.
       --
       l_datetrack_mode := hr_api.g_correction;
    else
       --
       hr_utility.set_location(l_proc,90);
       --
       -- End the existing record and create a new record.
       --
       l_datetrack_mode := hr_api.g_update;
    end if;
    --
    -- Call update_status_type_apl_asg in the required date track mode.
    --
    hr_assignment_internal.update_status_type_apl_asg
    (  p_effective_date               => p_effective_date
      ,p_datetrack_update_mode        => l_datetrack_mode
      ,p_assignment_id                => p_applicant_assignment_id
      ,p_object_version_number        => l_asg_object_version_number
      ,p_expected_system_status       => l_expected_system_status
      ,p_assignment_status_type_id    => l_assignment_status_type_id
      ,p_effective_start_date         => l_effective_start_date
      ,p_effective_end_date           => l_effective_end_date
    );
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 100);
  --
  exception
  when others then
  hr_utility.set_location(' Leaving:'||l_proc, 110);
  raise;
  --
end update_appl_assg_status;
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_latest_offer_flag >------------------------|
-- ----------------------------------------------------------------------------
--
   procedure update_latest_offer_flag
   ( P_VALIDATE                     IN   boolean     default false
    ,P_EFFECTIVE_DATE               IN   date        default null
    ,P_OFFER_ID                     IN   NUMBER
    ,P_OFFER_STATUS                 IN   VARCHAR2    default hr_api.g_varchar2
    ,P_LATEST_OFFER                 IN   VARCHAR2
    ,P_CHANGE_REASON                IN   VARCHAR2    default null
    ,P_STATUS_CHANGE_DATE           IN   date        default null
   ) is
  --
   l_proc                        varchar2(72) := g_package||'update_latest_offer_flag';
   l_object_version_number       irc_offers.object_version_number%TYPE;
   l_osh_object_version_number   irc_offer_status_history.object_version_number%TYPE;
   l_offer_status_history_id     irc_offer_status_history.offer_status_history_id%TYPE;
   l_offer_assignment_id         irc_offers.offer_assignment_id%TYPE;
   l_offer_version               irc_offers.offer_version%TYPE;
   l_updated_offer_status        irc_offers.offer_status%TYPE;
   --
   l_effective_start_date           per_all_assignments_f.effective_start_date%TYPE;
   l_effective_end_date             per_all_assignments_f.effective_end_date%TYPE;
   l_business_group_id              per_all_assignments_f.business_group_id%TYPE;
   l_asg_object_version_number      per_all_assignments_f.object_version_number%TYPE;
   l_validation_start_date          date;
   l_validation_end_date            date;
   l_org_now_no_manager_warning     boolean;
  --
   cursor csr_offer_details is
   select offer_assignment_id
         ,object_version_number
         ,offer_status
   from irc_offers
   where offer_id = p_offer_id;
  --
   cursor csr_assignment_ovn is
   select object_version_number
     from per_all_assignments_f
    where assignment_id = l_offer_assignment_id;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  open  csr_offer_details;
  fetch csr_offer_details into l_offer_assignment_id
                              ,l_object_version_number
                              ,l_updated_offer_status;
  if csr_offer_details%notfound
  then
    --
    close csr_offer_details;
    fnd_message.set_name('PER','IRC_412322_INVALID_OFFER_ID');
    fnd_message.raise_error;
    --
  end if;
  close csr_offer_details;
  --
  hr_utility.set_location(l_proc,20);
  --
  -- Call upd with new offer_status value, new
  -- latest_offer value.
  --
  irc_iof_upd.upd
  (  p_effective_date               => p_effective_date
    ,p_offer_id                     => p_offer_id
    ,p_object_version_number        => l_object_version_number
    ,p_offer_version                => l_offer_version
    ,p_latest_offer                 => p_latest_offer
    ,p_offer_status                 => p_offer_status
  );
  --
  -- Insert a new Offer History record with the change_reason only if
  -- the Status has changed.
  --
  if    p_offer_status <> hr_api.g_varchar2
    and p_offer_status <> l_updated_offer_status
  then
    --
    hr_utility.set_location(l_proc, 50);
    --
    irc_offer_status_history_api.create_offer_status_history
    (  p_validate                     =>  p_validate
      ,p_effective_date               =>  p_effective_date
      ,p_offer_status_history_id      =>  l_offer_status_history_id
      ,p_offer_id                     =>  p_offer_id
      ,p_status_change_date           =>  p_status_change_date
      ,p_offer_status                 =>  p_offer_status
      ,p_change_reason                =>  p_change_reason
      ,p_object_version_number        =>  l_osh_object_version_number
    );
    --
  end if;
  --
  -- If the offer has been CLOSED, and if the offer was previously not
  -- closed, end date the offer assignment.
  --
  if    p_offer_status = 'CLOSED'
    and p_offer_status <> l_updated_offer_status
  then
    --
    hr_utility.set_location(l_proc, 60);
    --
    open csr_assignment_ovn;
    fetch csr_assignment_ovn into l_asg_object_version_number;
    if csr_assignment_ovn%notfound
    then
      --
      hr_utility.set_location(l_proc, 65);
      --
      close csr_assignment_ovn;
      fnd_message.set_name('PER','HR_289541_PJU_INV_ASG_ID');
      fnd_message.raise_error;
      --
    end if;
    close csr_assignment_ovn;
    --
    per_asg_del.del
    (
      p_assignment_id              => l_offer_assignment_id
     ,p_effective_start_date       => l_effective_start_date
     ,p_effective_end_date         => l_effective_end_date
     ,p_business_group_id          => l_business_group_id
     ,p_object_version_number      => l_asg_object_version_number
     ,p_effective_date             => p_effective_date
     ,p_validation_start_date      => l_validation_start_date
     ,p_validation_end_date        => l_validation_end_date
     ,p_datetrack_mode             => hr_api.g_delete
     ,p_validate                   => p_validate
     ,p_org_now_no_manager_warning => l_org_now_no_manager_warning
   );
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
  exception
  when others then
  hr_utility.set_location(' Leaving:'||l_proc, 80);
  raise;
end update_latest_offer_flag;
--
-- ----------------------------------------------------------------------------
-- |----------------------< copy_offer_asg_to_appl_asg >----------------------|
-- ----------------------------------------------------------------------------
-- This procedure copies the offer assignment details into the applicant
-- assignment record once the applicant accepts the offer
-- ----------------------------------------------------------------------------
--
    procedure copy_offer_asg_to_appl_asg
    (P_OFFER_ID                                     IN NUMBER
    ,P_EFFECTIVE_DATE                               IN DATE
    ,P_VALIDATE                                     IN BOOLEAN              default false
    )
    Is
--
    l_proc                           varchar2(72) := g_package||'copy_offer_asg_to_appl_asg';
    l_applicant_assignment_id        irc_offers.applicant_assignment_id%TYPE;
    l_offer_assignment_id            irc_offers.offer_assignment_id%TYPE;
--
--  Out and In Out variables
--
    l_effective_start_date           per_all_assignments_f.effective_start_date%TYPE;
    l_effective_end_date             per_all_assignments_f.effective_end_date%TYPE;
    l_business_group_id              per_all_assignments_f.business_group_id%TYPE;
    l_comment_id                     per_all_assignments_f.comment_id%TYPE;
    l_object_version_number          per_all_assignments_f.object_version_number%TYPE;
    l_payroll_id_updated             boolean;
    l_other_manager_warning          boolean;
    l_hourly_salaried_warning        boolean;
    l_no_managers_warning            boolean;
    l_org_now_no_manager_warning     boolean;
    l_validation_start_date          date;
    l_validation_end_date            date;
    l_effective_date                 date;
    l_datetrack_mode                 varchar2(30) := hr_api.g_update;
--
--  Define cursors
--
   cursor csr_assignment_ids is
   select applicant_assignment_id
         ,offer_assignment_id
     from irc_offers
    where offer_id = p_offer_id;
--
   cursor csr_appl_asg_effective_date is
   select effective_start_date
         ,object_version_number
     from per_all_assignments_f
    where assignment_id = l_applicant_assignment_id
      and p_effective_date
  between effective_start_date
      and effective_end_date;
--
   cursor csr_assignment_record is
   select
     business_group_id
    ,recruiter_id
    ,grade_id
    ,position_id
    ,job_id
    ,assignment_status_type_id
    ,payroll_id
    ,location_id
    ,person_referred_by_id
    ,supervisor_id
    ,special_ceiling_step_id
    ,person_id
    ,recruitment_activity_id
    ,source_organization_id
    ,organization_id
    ,people_group_id
    ,soft_coding_keyflex_id
    ,vacancy_id
    ,pay_basis_id
    ,assignment_sequence
    ,assignment_type
    ,primary_flag
    ,application_id
    ,assignment_number
    ,change_reason
    ,comment_id
    ,date_probation_end
    ,default_code_comb_id
    ,employment_category
    ,frequency
    ,internal_address_line
    ,manager_flag
    ,normal_hours
    ,perf_review_period
    ,perf_review_period_frequency
    ,period_of_service_id
    ,probation_period
    ,probation_unit
    ,sal_review_period
    ,sal_review_period_frequency
    ,set_of_books_id
    ,source_type
    ,time_normal_finish
    ,time_normal_start
    ,request_id
    ,program_application_id
    ,program_id
    ,program_update_date
    ,ass_attribute_category
    ,ass_attribute1
    ,ass_attribute2
    ,ass_attribute3
    ,ass_attribute4
    ,ass_attribute5
    ,ass_attribute6
    ,ass_attribute7
    ,ass_attribute8
    ,ass_attribute9
    ,ass_attribute10
    ,ass_attribute11
    ,ass_attribute12
    ,ass_attribute13
    ,ass_attribute14
    ,ass_attribute15
    ,ass_attribute16
    ,ass_attribute17
    ,ass_attribute18
    ,ass_attribute19
    ,ass_attribute20
    ,ass_attribute21
    ,ass_attribute22
    ,ass_attribute23
    ,ass_attribute24
    ,ass_attribute25
    ,ass_attribute26
    ,ass_attribute27
    ,ass_attribute28
    ,ass_attribute29
    ,ass_attribute30
    ,title
    ,object_version_number
    ,bargaining_unit_code
    ,labour_union_member_flag
    ,hourly_salaried_code
    ,contract_id
    ,collective_agreement_id
    ,cagr_id_flex_num
    ,cagr_grade_def_id
    ,establishment_id
    ,notice_period
    ,notice_period_uom
    ,employee_category
    ,work_at_home
    ,job_post_source_name
    ,posting_content_id
    ,applicant_rank
    ,period_of_placement_date_start
    ,vendor_id
    ,vendor_employee_number
    ,vendor_assignment_number
    ,assignment_category
    ,project_title
    ,grade_ladder_pgm_id
    ,supervisor_assignment_id
    ,vendor_site_id
    ,po_header_id
    ,po_line_id
    ,projected_assignment_end
  from per_all_assignments_f
  where assignment_id = l_offer_assignment_id
    and p_effective_date
between effective_start_date
    and effective_end_date;

  l_offer_assignment    csr_assignment_record%ROWTYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint COPY_OFFER_ASG_TO_APPL_ASG;
  --
  open  csr_assignment_ids;
  fetch csr_assignment_ids into l_applicant_assignment_id
                               ,l_offer_assignment_id;
  --
  if csr_assignment_ids%notfound
  then
    --
    close csr_assignment_ids;
    fnd_message.set_name('PER','IRC_412322_INVALID_OFFER_ID');
    fnd_message.raise_error;
    --
  end if;
  close csr_assignment_ids;
  --
  open  csr_assignment_record;
  fetch csr_assignment_record into l_offer_assignment;
  --
  if csr_assignment_record%notfound
  then
    --
    close csr_assignment_record;
    fnd_message.set_name('PER','HR_289541_PJU_INV_ASG_ID');
    fnd_message.raise_error;
    --
  end if;
  close csr_assignment_record;
  --
  hr_utility.set_location(l_proc,20);
  --
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date      := trunc(p_effective_date);
  --
  -- Find out the datetrack mode to be employed
  --
  open  csr_appl_asg_effective_date;
  fetch csr_appl_asg_effective_date into l_effective_start_date
                                        ,l_object_version_number;
  --
  if csr_appl_asg_effective_date%notfound
  then
    --
    close csr_appl_asg_effective_date;
    fnd_message.set_name('PER','HR_289541_PJU_INV_ASG_ID');
    fnd_message.raise_error;
    --
  end if;
  close csr_appl_asg_effective_date;
  --
  if ( l_effective_start_date = trunc(sysdate) )
  then
    --
    hr_utility.set_location(l_proc,30);
    --
    -- Since the applicant assignment record is being modified multiple
    -- times on the same day, the datetrack mode should be correction.
    --
    l_datetrack_mode := hr_api.g_correction;
    --
  end if;
  --
  hr_utility.set_location(l_proc,40);
  --
  -- Copy the Offer Assignment details into Applicant Assignment record
  --
  per_asg_upd.upd
  (  p_assignment_id                     =>       l_applicant_assignment_id
    ,p_effective_start_date              =>       l_effective_start_date
    ,p_effective_end_date                =>       l_effective_end_date
    ,p_business_group_id                 =>       l_business_group_id
    ,p_recruiter_id                      =>       l_offer_assignment.recruiter_id
    ,p_grade_id                          =>       l_offer_assignment.grade_id
    ,p_position_id                       =>       l_offer_assignment.position_id
    ,p_job_id                            =>       l_offer_assignment.job_id
    ,p_assignment_status_type_id         =>       l_offer_assignment.assignment_status_type_id
    ,p_payroll_id                        =>       l_offer_assignment.payroll_id
    ,p_location_id                       =>       l_offer_assignment.location_id
    ,p_person_referred_by_id             =>       l_offer_assignment.person_referred_by_id
    ,p_supervisor_id                     =>       l_offer_assignment.supervisor_id
    ,p_special_ceiling_step_id           =>       l_offer_assignment.special_ceiling_step_id
    ,p_recruitment_activity_id           =>       l_offer_assignment.recruitment_activity_id
    ,p_source_organization_id            =>       l_offer_assignment.source_organization_id
    ,p_organization_id                   =>       l_offer_assignment.organization_id
    ,p_people_group_id                   =>       l_offer_assignment.people_group_id
    ,p_soft_coding_keyflex_id            =>       l_offer_assignment.soft_coding_keyflex_id
    ,p_vacancy_id                        =>       l_offer_assignment.vacancy_id
    ,p_pay_basis_id                      =>       l_offer_assignment.pay_basis_id
    -- Do not modify the Assignment Type and Primary Flag
    ,p_application_id                    =>       l_offer_assignment.application_id
    ,p_assignment_number                 =>       l_offer_assignment.assignment_number
    ,p_change_reason                     =>       l_offer_assignment.change_reason
    ,p_comment_id                        =>       l_comment_id
    ,p_date_probation_end                =>       l_offer_assignment.date_probation_end
    ,p_default_code_comb_id              =>       l_offer_assignment.default_code_comb_id
    ,p_employment_category               =>       l_offer_assignment.employment_category
    ,p_frequency                         =>       l_offer_assignment.frequency
    ,p_internal_address_line             =>       l_offer_assignment.internal_address_line
    ,p_manager_flag                      =>       l_offer_assignment.manager_flag
    ,p_normal_hours                      =>       l_offer_assignment.normal_hours
    ,p_perf_review_period                =>       l_offer_assignment.perf_review_period
    ,p_perf_review_period_frequency      =>       l_offer_assignment.perf_review_period_frequency
    ,p_period_of_service_id              =>       l_offer_assignment.period_of_service_id
    ,p_probation_period                  =>       l_offer_assignment.probation_period
    ,p_probation_unit                    =>       l_offer_assignment.probation_unit
    ,p_sal_review_period                 =>       l_offer_assignment.sal_review_period
    ,p_sal_review_period_frequency       =>       l_offer_assignment.sal_review_period_frequency
    ,p_set_of_books_id                   =>       l_offer_assignment.set_of_books_id
    ,p_source_type                       =>       l_offer_assignment.source_type
    ,p_time_normal_finish                =>       l_offer_assignment.time_normal_finish
    ,p_time_normal_start                 =>       l_offer_assignment.time_normal_start
    ,p_request_id                        =>       l_offer_assignment.request_id
    ,p_program_application_id            =>       l_offer_assignment.program_application_id
    ,p_program_id                        =>       l_offer_assignment.program_id
    ,p_program_update_date               =>       l_offer_assignment.program_update_date
    ,p_ass_attribute_category            =>       l_offer_assignment.ass_attribute_category
    ,p_ass_attribute1                    =>       l_offer_assignment.ass_attribute1
    ,p_ass_attribute2                    =>       l_offer_assignment.ass_attribute2
    ,p_ass_attribute3                    =>       l_offer_assignment.ass_attribute3
    ,p_ass_attribute4                    =>       l_offer_assignment.ass_attribute4
    ,p_ass_attribute5                    =>       l_offer_assignment.ass_attribute5
    ,p_ass_attribute6                    =>       l_offer_assignment.ass_attribute6
    ,p_ass_attribute7                    =>       l_offer_assignment.ass_attribute7
    ,p_ass_attribute8                    =>       l_offer_assignment.ass_attribute8
    ,p_ass_attribute9                    =>       l_offer_assignment.ass_attribute9
    ,p_ass_attribute10                   =>       l_offer_assignment.ass_attribute10
    ,p_ass_attribute11                   =>       l_offer_assignment.ass_attribute11
    ,p_ass_attribute12                   =>       l_offer_assignment.ass_attribute12
    ,p_ass_attribute13                   =>       l_offer_assignment.ass_attribute13
    ,p_ass_attribute14                   =>       l_offer_assignment.ass_attribute14
    ,p_ass_attribute15                   =>       l_offer_assignment.ass_attribute15
    ,p_ass_attribute16                   =>       l_offer_assignment.ass_attribute16
    ,p_ass_attribute17                   =>       l_offer_assignment.ass_attribute17
    ,p_ass_attribute18                   =>       l_offer_assignment.ass_attribute18
    ,p_ass_attribute19                   =>       l_offer_assignment.ass_attribute19
    ,p_ass_attribute20                   =>       l_offer_assignment.ass_attribute20
    ,p_ass_attribute21                   =>       l_offer_assignment.ass_attribute21
    ,p_ass_attribute22                   =>       l_offer_assignment.ass_attribute22
    ,p_ass_attribute23                   =>       l_offer_assignment.ass_attribute23
    ,p_ass_attribute24                   =>       l_offer_assignment.ass_attribute24
    ,p_ass_attribute25                   =>       l_offer_assignment.ass_attribute25
    ,p_ass_attribute26                   =>       l_offer_assignment.ass_attribute26
    ,p_ass_attribute27                   =>       l_offer_assignment.ass_attribute27
    ,p_ass_attribute28                   =>       l_offer_assignment.ass_attribute28
    ,p_ass_attribute29                   =>       l_offer_assignment.ass_attribute29
    ,p_ass_attribute30                   =>       l_offer_assignment.ass_attribute30
    ,p_title                             =>       l_offer_assignment.title
    ,p_object_version_number             =>       l_object_version_number
    ,p_bargaining_unit_code              =>       l_offer_assignment.bargaining_unit_code
    ,p_labour_union_member_flag          =>       l_offer_assignment.labour_union_member_flag
    ,p_hourly_salaried_code              =>       l_offer_assignment.hourly_salaried_code
    ,p_contract_id                       =>       l_offer_assignment.contract_id
    ,p_collective_agreement_id           =>       l_offer_assignment.collective_agreement_id
    ,p_cagr_id_flex_num                  =>       l_offer_assignment.cagr_id_flex_num
    ,p_cagr_grade_def_id                 =>       l_offer_assignment.cagr_grade_def_id
    ,p_establishment_id                  =>       l_offer_assignment.establishment_id
    ,p_notice_period                     =>       l_offer_assignment.notice_period
    ,p_notice_period_uom                 =>       l_offer_assignment.notice_period_uom
    ,p_employee_category                 =>       l_offer_assignment.employee_category
    ,p_work_at_home                      =>       l_offer_assignment.work_at_home
    ,p_job_post_source_name              =>       l_offer_assignment.job_post_source_name
    ,p_posting_content_id                =>       l_offer_assignment.posting_content_id
    ,p_applicant_rank                    =>       l_offer_assignment.applicant_rank
    ,p_placement_date_start              =>       l_offer_assignment.period_of_placement_date_start
    ,p_vendor_id                         =>       l_offer_assignment.vendor_id
    ,p_vendor_employee_number            =>       l_offer_assignment.vendor_employee_number
    ,p_vendor_assignment_number          =>       l_offer_assignment.vendor_assignment_number
    ,p_assignment_category               =>       l_offer_assignment.assignment_category
    ,p_project_title                     =>       l_offer_assignment.project_title
    ,p_grade_ladder_pgm_id               =>       l_offer_assignment.grade_ladder_pgm_id
    ,p_supervisor_assignment_id          =>       l_offer_assignment.supervisor_assignment_id
    ,p_vendor_site_id                    =>       l_offer_assignment.vendor_site_id
    ,p_po_header_id                      =>       l_offer_assignment.po_header_id
    ,p_po_line_id                        =>       l_offer_assignment.po_line_id
    ,p_projected_assignment_end          =>       l_offer_assignment.projected_assignment_end
    ,p_payroll_id_updated                =>       l_payroll_id_updated
    ,p_other_manager_warning             =>       l_other_manager_warning
    ,p_hourly_salaried_warning           =>       l_hourly_salaried_warning
    ,p_no_managers_warning               =>       l_no_managers_warning
    ,p_org_now_no_manager_warning        =>       l_org_now_no_manager_warning
    ,p_validation_start_date             =>       l_validation_start_date
    ,p_validation_end_date               =>       l_validation_end_date
    ,p_effective_date                    =>       l_effective_date
    ,p_datetrack_mode                    =>       l_datetrack_mode
    ,p_validate                          =>       p_validate
   );
  --
  hr_utility.set_location(l_proc, 50);
  --
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 60);
  --
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to COPY_OFFER_ASG_TO_APPL_ASG;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 70);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to COPY_OFFER_ASG_TO_APPL_ASG;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    raise;
end copy_offer_asg_to_appl_asg;
--
-- ----------------------------------------------------------------------------
-- |----------------------< copy_offer_pay_to_appl_pay >----------------------|
-- ----------------------------------------------------------------------------
-- This procedure copies the offer pay proposal record details into the applicant
-- pay proposal record once the applicant accepts the offer
-- ----------------------------------------------------------------------------
--
    procedure copy_offer_pay_to_appl_pay
    (P_VALIDATE                                     IN BOOLEAN              default false
    ,P_OFFER_ID                                     IN NUMBER
    ,P_EFFECTIVE_DATE                               IN DATE
    )
    Is
--
    l_proc                           varchar2(72) := g_package||'copy_offer_pay_to_appl_pay';
--
--  Out and In Out variables
--
    l_pay_proposal_id               per_pay_proposals.pay_proposal_id%TYPE;
    l_pay_proposal_ovn              per_pay_proposals.object_version_number%TYPE;
    l_inv_next_sal_date_warning     boolean;
    l_proposed_salary_warning       boolean;
    l_approved_warning              boolean;
    l_payroll_warning               boolean;

    l_applicant_assignment_id       irc_offers.applicant_assignment_id%TYPE;
    l_offer_assignment_id           irc_offers.offer_assignment_id%TYPE;
--
--  Define cursors
--
   cursor csr_assignment_ids is
   select applicant_assignment_id
         ,offer_assignment_id
     from irc_offers
    where offer_id = p_offer_id;
--
   cursor csr_appl_pay_proposal is
   select pay_proposal_id
         ,object_version_number
     from per_pay_proposals
    where assignment_id = l_applicant_assignment_id
      and approved = 'N';
--
   cursor csr_pay_proposal_record is
   select
     pay_proposal_id
    ,assignment_id
    ,event_id
    ,business_group_id
    ,change_date
    ,comments
    ,last_change_date
    ,next_perf_review_date
    ,next_sal_review_date
    ,performance_rating
    ,proposal_reason
    ,proposed_salary
    ,review_date
    ,attribute_category
    ,attribute1
    ,attribute2
    ,attribute3
    ,attribute4
    ,attribute5
    ,attribute6
    ,attribute7
    ,attribute8
    ,attribute9
    ,attribute10
    ,attribute11
    ,attribute12
    ,attribute13
    ,attribute14
    ,attribute15
    ,attribute16
    ,attribute17
    ,attribute18
    ,attribute19
    ,attribute20
    ,last_update_date
    ,last_updated_by
    ,last_update_login
    ,created_by
    ,creation_date
    ,object_version_number
    ,approved
    ,multiple_components
    ,forced_ranking
    ,performance_review_id
    ,proposed_salary_n
   from per_pay_proposals
  where assignment_id = l_offer_assignment_id
    and approved = 'N';

  l_pay_proposal_record    csr_pay_proposal_record%ROWTYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint COPY_OFFER_PAY_TO_APPL_PAY;
  --
  open  csr_assignment_ids;
  fetch csr_assignment_ids into l_applicant_assignment_id
                               ,l_offer_assignment_id;
  if csr_assignment_ids%notfound
  then
    --
    close csr_assignment_ids;
    fnd_message.set_name('PER','IRC_412322_INVALID_OFFER_ID');
    fnd_message.raise_error;
    --
  end if;
  close csr_assignment_ids;

  --
  open  csr_appl_pay_proposal;
  fetch csr_appl_pay_proposal into l_pay_proposal_id
                                  ,l_pay_proposal_ovn;
  --
  if csr_appl_pay_proposal%notfound
  then
    --
    hr_utility.set_location(l_proc,30);
    --
    -- Pay Proposal does not exist for this applicant.
    -- Hence create a new pay proposal record.
    --
    l_pay_proposal_id  := null;
    l_pay_proposal_ovn := null;
    --
  end if;
  close csr_appl_pay_proposal;
  --
  open  csr_pay_proposal_record;
  fetch csr_pay_proposal_record into l_pay_proposal_record;
  --
  if csr_pay_proposal_record%found
  then
    --
    hr_utility.set_location(l_proc,40);
    --
    -- We need to copy the pay proposal details to the record corresponding
    -- to applicant assignment only if the pay proposal record exists for
    -- offer assignment.
    --
    --
    -- Call the cre_or_upd_salary_proposal procedure with the corresponding values
    -- so that it decides whether a new record needs to be created or an existing record
    -- needs to be updated.
    --
    hr_maintain_proposal_api.cre_or_upd_salary_proposal
    (
      p_validate                     => p_validate
     ,p_pay_proposal_id              => l_pay_proposal_id
     ,p_object_version_number        => l_pay_proposal_ovn
     ,p_business_group_id            => l_pay_proposal_record.business_group_id
     ,p_assignment_id                => l_applicant_assignment_id
     ,p_change_date                  => p_effective_date
     ,p_comments                     => l_pay_proposal_record.comments
     ,p_next_sal_review_date         => l_pay_proposal_record.next_sal_review_date
     ,p_proposal_reason              => l_pay_proposal_record.proposal_reason
     ,p_proposed_salary_n            => l_pay_proposal_record.proposed_salary_n
     ,p_forced_ranking               => l_pay_proposal_record.forced_ranking
     ,p_performance_review_id        => l_pay_proposal_record.performance_review_id
     ,p_attribute_category           => l_pay_proposal_record.attribute_category
     ,p_attribute1                   => l_pay_proposal_record.attribute1
     ,p_attribute2                   => l_pay_proposal_record.attribute2
     ,p_attribute3                   => l_pay_proposal_record.attribute3
     ,p_attribute4                   => l_pay_proposal_record.attribute4
     ,p_attribute5                   => l_pay_proposal_record.attribute5
     ,p_attribute6                   => l_pay_proposal_record.attribute6
     ,p_attribute7                   => l_pay_proposal_record.attribute7
     ,p_attribute8                   => l_pay_proposal_record.attribute8
     ,p_attribute9                   => l_pay_proposal_record.attribute9
     ,p_attribute10                  => l_pay_proposal_record.attribute10
     ,p_attribute11                  => l_pay_proposal_record.attribute11
     ,p_attribute12                  => l_pay_proposal_record.attribute12
     ,p_attribute13                  => l_pay_proposal_record.attribute13
     ,p_attribute14                  => l_pay_proposal_record.attribute14
     ,p_attribute15                  => l_pay_proposal_record.attribute15
     ,p_attribute16                  => l_pay_proposal_record.attribute16
     ,p_attribute17                  => l_pay_proposal_record.attribute17
     ,p_attribute18                  => l_pay_proposal_record.attribute18
     ,p_attribute19                  => l_pay_proposal_record.attribute19
     ,p_attribute20                  => l_pay_proposal_record.attribute20
     ,p_multiple_components          => l_pay_proposal_record.multiple_components
     ,p_approved                     => l_pay_proposal_record.approved
     ,p_inv_next_sal_date_warning    => l_inv_next_sal_date_warning
     ,p_proposed_salary_warning      => l_proposed_salary_warning
     ,p_approved_warning             => l_approved_warning
     ,p_payroll_warning              => l_payroll_warning
    );
    --
  end if;
  close csr_pay_proposal_record;
  --
  hr_utility.set_location(l_proc, 50);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 60);
  --
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to COPY_OFFER_PAY_TO_APPL_PAY;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 70);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to COPY_OFFER_PAY_TO_APPL_PAY;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    raise;
end copy_offer_pay_to_appl_pay;
--
-- ----------------------------------------------------------------------------
-- |-------------------< other_extended_offers_count >------------------------|
--  This functions returns the number of offers that have been already Extended
--  or Accepted by the candidate
-- ----------------------------------------------------------------------------
--
  PROCEDURE other_extended_offers_count
  ( p_applicant_assignment_id             IN NUMBER   default null
   ,p_effective_date                      IN DATE
   ,p_person_id                           IN NUMBER   default null
   ,p_other_extended_offer_count          OUT nocopy NUMBER
  ) IS
  --
  l_proc                         VARCHAR2(72) :=  g_package||'other_extended_offers_count';
  l_other_extended_offer_count   number       := 0;
  l_person_id                    per_all_assignments_f.person_id%TYPE := p_person_id;
  --
  CURSOR csr_person_id is
  SELECT person_id
    FROM per_all_assignments_f
   WHERE assignment_id = p_applicant_assignment_id
     AND p_effective_date
 BETWEEN effective_start_date
     AND effective_end_date;
  --
  CURSOR csr_other_extended_offers IS
  SELECT count(otheroffer.offer_id)
    FROM IRC_OFFERS otheroffer
        ,PER_ALL_ASSIGNMENTS_F  otherasg
        ,PER_ALL_PEOPLE_F per
        ,PER_ALL_PEOPLE_F linkper
        ,IRC_OFFER_STATUS_HISTORY otherhistory
   WHERE (
            -- Other Extended Offers
            otheroffer.offer_status = 'EXTENDED'
            OR
            (  -- Other Closed and Accepted Offers
            otheroffer.offer_status = 'CLOSED'
            AND otherhistory.change_reason = 'APL_ACCEPTED'
            )
         )
     AND otherasg.effective_start_date = (select max(effective_start_date)
                                            from per_assignments_f asg2
                                           where otherasg.assignment_id=asg2.assignment_id
                                             and asg2.effective_start_date <= trunc(sysdate)
                                          )
     AND p_effective_date BETWEEN trunc(per.effective_start_date) and trunc(nvl(per.effective_end_date,p_effective_date))
     AND p_effective_date BETWEEN trunc(linkper.effective_start_date) and trunc(nvl(linkper.effective_end_date,p_effective_date))
     AND otheroffer.offer_assignment_id = otherasg.assignment_id
     AND otherasg.person_id = linkper.person_id
     AND per.person_id = l_person_id
     AND linkper.party_id = per.party_id
     AND otheroffer.latest_offer = 'Y'
     AND otheroffer.applicant_assignment_id <> nvl(p_applicant_assignment_id, -1)
     AND decode(hr_general.get_xbg_profile,'Y', otherasg.business_group_id , hr_general.get_business_group_id) = otherasg.business_group_id
     AND otheroffer.offer_id = otherhistory.offer_id
     AND NOT EXISTS
       (SELECT 1
       FROM    irc_offer_status_history iosh1
       WHERE   iosh1.offer_id             = otherhistory.offer_id
           AND iosh1.status_change_date > otherhistory.status_change_date
       )
   AND otherhistory.offer_status_history_id =
       (SELECT MAX(iosh2.offer_status_history_id)
       FROM    irc_offer_status_history iosh2
       WHERE   iosh2.offer_id             = otherhistory.offer_id
           AND iosh2.status_change_date = otherhistory.status_change_date
       );
  --
  BEGIN
    --
    if l_person_id is null
    then
      --
      open csr_person_id;
      fetch csr_person_id into l_person_id;
      if csr_person_id%notfound
      then
        --
        close csr_person_id;
        --
        fnd_message.set_name('PER','IRC_412006_ASG_NOT_APPL');
        fnd_message.raise_error;
        --
      end if;
      close csr_person_id;
      --
    end if;
    --
    open csr_other_extended_offers;
    fetch csr_other_extended_offers into l_other_extended_offer_count;
    if csr_other_extended_offers%NOTFOUND
    then
      --
      close csr_other_extended_offers;
      l_other_extended_offer_count := 0;
      --
    else
      --
      close csr_other_extended_offers;
      --
    end if;
    --
  p_other_extended_offer_count := l_other_extended_offer_count;
  --
  END other_extended_offers_count;
--
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< close_notifications >------------------------|
-- ----------------------------------------------------------------------------
--
  procedure close_notifications
  ( P_APPLICANT_ASSIGNMENT_ID          IN   number
   ,P_OFFER_ID                     IN   number
  ) Is
--
  l_proc                           varchar2(72) := g_package||'close_notifications';
  l_transaction_id                 hr_api_transactions.transaction_id%TYPE;
  l_item_type                      hr_api_transactions.item_type%TYPE;
  l_item_key                       hr_api_transactions.item_key%TYPE;
--
 cursor csr_get_txn_details is
 select transaction_id
       ,item_type
       ,item_key
   from hr_api_transactions
  where transaction_ref_table='IRC_OFFERS'
    and transaction_ref_id = p_offer_id;
--
cursor csr_get_sfl_txn_details is
 select hat.transaction_id
       ,wn.MESSAGE_TYPE
       ,wn.item_key
   from hr_api_transactions hat,
        wf_notifications wn
  where hat.transaction_ref_table='IRC_OFFERS'
    and hat.STATUS='S'
    and wn.MESSAGE_TYPE='HRSFL'
    and to_char(hat.transaction_id)=wn.user_key
    and hat.ASSIGNMENT_ID = p_applicant_assignment_id;
--
  begin
    --
    --
    hr_utility.set_location(' Entering:'||l_proc,10);
    --
    savepoint CLOSE_NOTIFICATIONS;
    --
    -- Close if any SFL notifications exists
    open csr_get_sfl_txn_details;
    fetch csr_get_sfl_txn_details into l_transaction_id,l_item_type,l_item_key;
    if csr_get_sfl_txn_details%found then
      --
      hr_utility.set_location(' SFL Transaction Found '||l_proc,20);
      hr_transaction_api.rollback_transaction(
                         p_transaction_id   =>  l_transaction_id);
      --
      hr_utility.set_location(' Rolled back SFL Transaction '||l_proc,30);
      --
      if l_item_key is not null then
      wf_engine.abortprocess(itemtype => l_item_type
                               ,itemkey  => l_item_key
                               ,process  =>null
                               ,result   => wf_engine.eng_force
                               ,verify_lock=> true
                               ,cascade=> true);
      end if;
      --
      hr_utility.set_location(' Cancelled SFL notification '||l_proc,40);
      --
    end if;
    close csr_get_sfl_txn_details;
    --
    -- Close any open notifications
    open csr_get_txn_details;
    fetch csr_get_txn_details into l_transaction_id,l_item_type,l_item_key;
    if csr_get_txn_details%found then
      --
      hr_utility.set_location(' API Transaction Found '||l_proc,50);
      hr_transaction_api.rollback_transaction(
                         p_transaction_id   =>  l_transaction_id);
      --
      hr_utility.set_location(' Rolled back API Transaction '||l_proc,60);
      --
      if l_item_key is not null then
      wf_engine.abortprocess(itemtype => l_item_type
                               ,itemkey  => l_item_key
                               ,process  =>null
                               ,result   => wf_engine.eng_force
                               ,verify_lock=> true
                               ,cascade=> true);
      end if;
      --
      hr_utility.set_location(' Cancelled Open notification '||l_proc,70);
      --
    end if;
    close csr_get_txn_details;
    --
    --
  --
  exception
   when others then
   rollback to CLOSE_NOTIFICATIONS;
   hr_utility.set_location(' Leaving: '||l_proc, 80);
   raise;
  end close_notifications;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< create_offer >-------------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_offer
   (   P_VALIDATE                     IN   boolean     default false
    ,  P_EFFECTIVE_DATE               IN   date        default null
    ,  P_OFFER_STATUS                 IN   VARCHAR2
    ,  P_DISCRETIONARY_JOB_TITLE      IN   VARCHAR2    default null
    ,  P_OFFER_EXTENDED_METHOD        IN   VARCHAR2    default null
    ,  P_RESPONDENT_ID                IN   NUMBER      default null
    ,  P_EXPIRY_DATE                  IN   DATE        default null
    ,  P_PROPOSED_START_DATE          IN   DATE        default null
    ,  P_OFFER_LETTER_TRACKING_CODE   IN   VARCHAR2    default null
    ,  P_OFFER_POSTAL_SERVICE         IN   VARCHAR2    default null
    ,  P_OFFER_SHIPPING_DATE          IN   DATE        default null
    ,  P_APPLICANT_ASSIGNMENT_ID      IN   NUMBER
    ,  P_OFFER_ASSIGNMENT_ID          IN   NUMBER
    ,  P_ADDRESS_ID                   IN   NUMBER      default null
    ,  P_TEMPLATE_ID                  IN   NUMBER      default null
    ,  P_OFFER_LETTER_FILE_TYPE       IN   VARCHAR2    default null
    ,  P_OFFER_LETTER_FILE_NAME       IN   VARCHAR2    default null
    ,  P_ATTRIBUTE_CATEGORY           IN   VARCHAR2    default null
    ,  P_ATTRIBUTE1                   IN   VARCHAR2    default null
    ,  P_ATTRIBUTE2                   IN   VARCHAR2    default null
    ,  P_ATTRIBUTE3                   IN   VARCHAR2    default null
    ,  P_ATTRIBUTE4                   IN   VARCHAR2    default null
    ,  P_ATTRIBUTE5                   IN   VARCHAR2    default null
    ,  P_ATTRIBUTE6                   IN   VARCHAR2    default null
    ,  P_ATTRIBUTE7                   IN   VARCHAR2    default null
    ,  P_ATTRIBUTE8                   IN   VARCHAR2    default null
    ,  P_ATTRIBUTE9                   IN   VARCHAR2    default null
    ,  P_ATTRIBUTE10                  IN   VARCHAR2    default null
    ,  P_ATTRIBUTE11                  IN   VARCHAR2    default null
    ,  P_ATTRIBUTE12                  IN   VARCHAR2    default null
    ,  P_ATTRIBUTE13                  IN   VARCHAR2    default null
    ,  P_ATTRIBUTE14                  IN   VARCHAR2    default null
    ,  P_ATTRIBUTE15                  IN   VARCHAR2    default null
    ,  P_ATTRIBUTE16                  IN   VARCHAR2    default null
    ,  P_ATTRIBUTE17                  IN   VARCHAR2    default null
    ,  P_ATTRIBUTE18                  IN   VARCHAR2    default null
    ,  P_ATTRIBUTE19                  IN   VARCHAR2    default null
    ,  P_ATTRIBUTE20                  IN   VARCHAR2    default null
    ,  P_ATTRIBUTE21                  IN   VARCHAR2    default null
    ,  P_ATTRIBUTE22                  IN   VARCHAR2    default null
    ,  P_ATTRIBUTE23                  IN   VARCHAR2    default null
    ,  P_ATTRIBUTE24                  IN   VARCHAR2    default null
    ,  P_ATTRIBUTE25                  IN   VARCHAR2    default null
    ,  P_ATTRIBUTE26                  IN   VARCHAR2    default null
    ,  P_ATTRIBUTE27                  IN   VARCHAR2    default null
    ,  P_ATTRIBUTE28                  IN   VARCHAR2    default null
    ,  P_ATTRIBUTE29                  IN   VARCHAR2    default null
    ,  P_ATTRIBUTE30                  IN   VARCHAR2    default null
    ,  P_STATUS_CHANGE_DATE           IN   DATE        default null
    ,  P_OFFER_ID                     OUT  nocopy   NUMBER
    ,  P_OFFER_VERSION                OUT  nocopy   NUMBER
    ,  P_OBJECT_VERSION_NUMBER        OUT  nocopy   NUMBER
   ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                        varchar2(72) := g_package||'create_offer';
  l_offer_id                    irc_offers.offer_id%TYPE;
  l_object_version_number       irc_offers.object_version_number%TYPE  := 1;
  l_effective_date              date;
  l_expiry_date                 irc_offers.expiry_date%TYPE;
  l_proposed_start_date         irc_offers.proposed_start_date%TYPE;
  l_offer_shipping_date         irc_offers.offer_shipping_date%TYPE;
  l_offer_status_history_id     irc_offer_status_history.offer_status_history_id%TYPE;
  l_latest_offer                irc_offers.latest_offer%TYPE;
  l_osh_object_version_number   irc_offer_status_history.object_version_number%TYPE;
  l_status_change_date          irc_offer_status_history.status_change_date%TYPE;
  l_offer_version               irc_offers.offer_version%TYPE;
  l_asg_object_version_number   per_all_assignments_f.object_version_number%TYPE;
--
  l_updated_offer_id            irc_offers.offer_id%TYPE;
  l_updated_offer_status        irc_offers.offer_status%TYPE;
  l_updated_appl_assignment_id  irc_offers.applicant_assignment_id%TYPE;
--
  cursor csr_latest_offer is
         select offer_id
               ,offer_status
               ,applicant_assignment_id
           from irc_offers
          where latest_offer = 'Y'
            and applicant_assignment_id = p_applicant_assignment_id;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_OFFER;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date      := trunc(p_effective_date);
  l_expiry_date         := trunc(p_expiry_date);
  l_proposed_start_date := trunc(p_proposed_start_date);
  l_offer_shipping_date := trunc(p_offer_shipping_date);
  l_status_change_date  := p_status_change_date;
  --
  hr_utility.set_location(l_proc,20);
  --
  -- If a prev offer exists for this applicant assignment, we need
  -- to close it and set this offer as the Latest.
  --
  --
  -- Check if there is some other offer record
  -- for the same applicant which has latest_offer
  -- set to 'Y'
  --
  open csr_latest_offer;
  fetch csr_latest_offer into l_updated_offer_id
                             ,l_updated_offer_status
                             ,l_updated_appl_assignment_id;
  --
  hr_utility.set_location(l_proc,40);
  --
  if (csr_latest_offer%found)
  then
  --
    close csr_latest_offer;
    --
    hr_utility.set_location(l_proc,45);
    --
    -- Set the offer_status of the record to be
    -- updated to 'Closed', the latest_offer
    -- to 'N' and change_reason to 'Offer Updated'
    --
    update_latest_offer_flag
    ( p_offer_id            => l_updated_offer_id
     ,p_effective_date      => l_effective_date
     ,p_validate            => p_validate
     ,p_offer_status        => 'CLOSED'
     ,p_latest_offer        => 'N'
     ,p_change_reason       => 'UPDATED'
     ,p_status_change_date  => l_status_change_date
    );
    --
    -- Change the Applicant's assignment status to what it was previously.
    -- Do this only if the updated offer was in EXTENDED or CLOSED State as
    -- only then would the application status have been changed.
    --
    if l_updated_offer_status in ('EXTENDED', 'CLOSED')
    then
      --
      update_appl_assg_status
      ( p_validate                        =>  p_validate
       ,p_effective_date                  =>  l_effective_date
       ,p_applicant_assignment_id         =>  l_updated_appl_assignment_id
       ,p_offer_status                    =>  l_updated_offer_status
       ,p_change_reason                   =>  'UPDATED'
      );
      --
    end if;
    --
  else
    close csr_latest_offer;
  end if;
  --
  -- This offer should now be the latest offer
  --
  l_latest_offer := 'Y';
  --
  hr_utility.set_location(l_proc,48);
  --
  -- Call Before Process User Hook
  --
  begin
  IRC_OFFERS_BK1.create_offer_b
   (   P_EFFECTIVE_DATE               =>   l_effective_date
    ,  P_LATEST_OFFER                 =>   l_latest_offer
    ,  P_OFFER_STATUS                 =>   P_OFFER_STATUS
    ,  P_DISCRETIONARY_JOB_TITLE      =>   P_DISCRETIONARY_JOB_TITLE
    ,  P_OFFER_EXTENDED_METHOD        =>   P_OFFER_EXTENDED_METHOD
    ,  P_RESPONDENT_ID                =>   P_RESPONDENT_ID
    ,  P_EXPIRY_DATE                  =>   l_expiry_date
    ,  P_PROPOSED_START_DATE          =>   l_proposed_start_date
    ,  P_OFFER_LETTER_TRACKING_CODE   =>   P_OFFER_LETTER_TRACKING_CODE
    ,  P_OFFER_POSTAL_SERVICE         =>   P_OFFER_POSTAL_SERVICE
    ,  P_OFFER_SHIPPING_DATE          =>   l_offer_shipping_date
    ,  P_APPLICANT_ASSIGNMENT_ID      =>   P_APPLICANT_ASSIGNMENT_ID
    ,  P_OFFER_ASSIGNMENT_ID          =>   P_OFFER_ASSIGNMENT_ID
    ,  P_ADDRESS_ID                   =>   P_ADDRESS_ID
    ,  P_TEMPLATE_ID                  =>   P_TEMPLATE_ID
    ,  P_OFFER_LETTER_FILE_TYPE       =>   P_OFFER_LETTER_FILE_TYPE
    ,  P_OFFER_LETTER_FILE_NAME       =>   P_OFFER_LETTER_FILE_NAME
    ,  P_ATTRIBUTE_CATEGORY           =>   P_ATTRIBUTE_CATEGORY
    ,  P_ATTRIBUTE1                   =>   P_ATTRIBUTE1
    ,  P_ATTRIBUTE2                   =>   P_ATTRIBUTE2
    ,  P_ATTRIBUTE3                   =>   P_ATTRIBUTE3
    ,  P_ATTRIBUTE4                   =>   P_ATTRIBUTE4
    ,  P_ATTRIBUTE5                   =>   P_ATTRIBUTE5
    ,  P_ATTRIBUTE6                   =>   P_ATTRIBUTE6
    ,  P_ATTRIBUTE7                   =>   P_ATTRIBUTE7
    ,  P_ATTRIBUTE8                   =>   P_ATTRIBUTE8
    ,  P_ATTRIBUTE9                   =>   P_ATTRIBUTE9
    ,  P_ATTRIBUTE10                  =>   P_ATTRIBUTE10
    ,  P_ATTRIBUTE11                  =>   P_ATTRIBUTE11
    ,  P_ATTRIBUTE12                  =>   P_ATTRIBUTE12
    ,  P_ATTRIBUTE13                  =>   P_ATTRIBUTE13
    ,  P_ATTRIBUTE14                  =>   P_ATTRIBUTE14
    ,  P_ATTRIBUTE15                  =>   P_ATTRIBUTE15
    ,  P_ATTRIBUTE16                  =>   P_ATTRIBUTE16
    ,  P_ATTRIBUTE17                  =>   P_ATTRIBUTE17
    ,  P_ATTRIBUTE18                  =>   P_ATTRIBUTE18
    ,  P_ATTRIBUTE19                  =>   P_ATTRIBUTE19
    ,  P_ATTRIBUTE20                  =>   P_ATTRIBUTE20
    ,  P_ATTRIBUTE21                  =>   P_ATTRIBUTE21
    ,  P_ATTRIBUTE22                  =>   P_ATTRIBUTE22
    ,  P_ATTRIBUTE23                  =>   P_ATTRIBUTE23
    ,  P_ATTRIBUTE24                  =>   P_ATTRIBUTE24
    ,  P_ATTRIBUTE25                  =>   P_ATTRIBUTE25
    ,  P_ATTRIBUTE26                  =>   P_ATTRIBUTE26
    ,  P_ATTRIBUTE27                  =>   P_ATTRIBUTE27
    ,  P_ATTRIBUTE28                  =>   P_ATTRIBUTE28
    ,  P_ATTRIBUTE29                  =>   P_ATTRIBUTE29
    ,  P_ATTRIBUTE30                  =>   P_ATTRIBUTE30
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_offer'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  irc_iof_ins.ins
  (    p_effective_date                 =>  l_effective_date
    ,  p_latest_offer                   =>  l_latest_offer
    ,  p_applicant_assignment_id        =>  p_applicant_assignment_id
    ,  p_offer_assignment_id            =>  p_offer_assignment_id
    ,  p_offer_status                   =>  p_offer_status
    ,  p_discretionary_job_title        =>  p_discretionary_job_title
    ,  p_offer_extended_method          =>  p_offer_extended_method
    ,  p_respondent_id                  =>  p_respondent_id
    ,  p_expiry_date                    =>  l_expiry_date
    ,  p_proposed_start_date            =>  l_proposed_start_date
    ,  p_offer_letter_tracking_code     =>  p_offer_letter_tracking_code
    ,  p_offer_postal_service           =>  p_offer_postal_service
    ,  p_offer_shipping_date            =>  l_offer_shipping_date
    ,  p_address_id                     =>  p_address_id
    ,  p_template_id                    =>  p_template_id
    ,  p_offer_letter_file_type         =>  p_offer_letter_file_type
    ,  p_offer_letter_file_name         =>  p_offer_letter_file_name
    ,  p_attribute_category             =>  p_attribute_category
    ,  p_attribute1                     =>  p_attribute1
    ,  p_attribute2                     =>  p_attribute2
    ,  p_attribute3                     =>  p_attribute3
    ,  p_attribute4                     =>  p_attribute4
    ,  p_attribute5                     =>  p_attribute5
    ,  p_attribute6                     =>  p_attribute6
    ,  p_attribute7                     =>  p_attribute7
    ,  p_attribute8                     =>  p_attribute8
    ,  p_attribute9                     =>  p_attribute9
    ,  p_attribute10                    =>  p_attribute10
    ,  p_attribute11                    =>  p_attribute11
    ,  p_attribute12                    =>  p_attribute12
    ,  p_attribute13                    =>  p_attribute13
    ,  p_attribute14                    =>  p_attribute14
    ,  p_attribute15                    =>  p_attribute15
    ,  p_attribute16                    =>  p_attribute16
    ,  p_attribute17                    =>  p_attribute17
    ,  p_attribute18                    =>  p_attribute18
    ,  p_attribute19                    =>  p_attribute19
    ,  p_attribute20                    =>  p_attribute20
    ,  p_attribute21                    =>  p_attribute21
    ,  p_attribute22                    =>  p_attribute22
    ,  p_attribute23                    =>  p_attribute23
    ,  p_attribute24                    =>  p_attribute24
    ,  p_attribute25                    =>  p_attribute25
    ,  p_attribute26                    =>  p_attribute26
    ,  p_attribute27                    =>  p_attribute27
    ,  p_attribute28                    =>  p_attribute28
    ,  p_attribute29                    =>  p_attribute29
    ,  p_attribute30                    =>  p_attribute30
    ,  p_offer_id                       =>  l_offer_id
    ,  p_offer_version                  =>  l_offer_version
    ,  p_object_version_number          =>  l_object_version_number
  );
  hr_utility.set_location(l_proc,50);
  --
  -- Create offer history record for the newly created
  -- Offer record.
  --
  irc_offer_status_history_api.create_offer_status_history
  (   p_validate                        =>  p_validate
   ,  p_effective_date                  =>  l_effective_date
   ,  p_offer_status_history_id         =>  l_offer_status_history_id
   ,  p_offer_id                        =>  l_offer_id
   ,  p_offer_status                    =>  p_offer_status
   ,  p_change_reason                   =>  null
   ,  p_decline_reason                  =>  null
   ,  p_note_text                       =>  null
   ,  p_object_version_number           =>  l_osh_object_version_number
   ,  p_status_change_date              =>  l_status_change_date
  );
  hr_utility.set_location(l_proc,60);
  --
  -- Call After Process User Hook
  --
  begin
  IRC_OFFERS_BK1.create_offer_a
   (   P_EFFECTIVE_DATE               =>   l_effective_date
    ,  P_LATEST_OFFER                 =>   l_latest_offer
    ,  P_OFFER_STATUS                 =>   P_OFFER_STATUS
    ,  P_DISCRETIONARY_JOB_TITLE      =>   P_DISCRETIONARY_JOB_TITLE
    ,  P_OFFER_EXTENDED_METHOD        =>   P_OFFER_EXTENDED_METHOD
    ,  P_RESPONDENT_ID                =>   P_RESPONDENT_ID
    ,  P_EXPIRY_DATE                  =>   l_expiry_date
    ,  P_PROPOSED_START_DATE          =>   l_proposed_start_date
    ,  P_OFFER_LETTER_TRACKING_CODE   =>   P_OFFER_LETTER_TRACKING_CODE
    ,  P_OFFER_POSTAL_SERVICE         =>   P_OFFER_POSTAL_SERVICE
    ,  P_OFFER_SHIPPING_DATE          =>   l_offer_shipping_date
    ,  P_APPLICANT_ASSIGNMENT_ID      =>   P_APPLICANT_ASSIGNMENT_ID
    ,  P_OFFER_ASSIGNMENT_ID          =>   P_OFFER_ASSIGNMENT_ID
    ,  P_ADDRESS_ID                   =>   P_ADDRESS_ID
    ,  P_TEMPLATE_ID                  =>   P_TEMPLATE_ID
    ,  P_OFFER_LETTER_FILE_TYPE       =>   P_OFFER_LETTER_FILE_TYPE
    ,  P_OFFER_LETTER_FILE_NAME       =>   P_OFFER_LETTER_FILE_NAME
    ,  P_ATTRIBUTE_CATEGORY           =>   P_ATTRIBUTE_CATEGORY
    ,  P_ATTRIBUTE1                   =>   P_ATTRIBUTE1
    ,  P_ATTRIBUTE2                   =>   P_ATTRIBUTE2
    ,  P_ATTRIBUTE3                   =>   P_ATTRIBUTE3
    ,  P_ATTRIBUTE4                   =>   P_ATTRIBUTE4
    ,  P_ATTRIBUTE5                   =>   P_ATTRIBUTE5
    ,  P_ATTRIBUTE6                   =>   P_ATTRIBUTE6
    ,  P_ATTRIBUTE7                   =>   P_ATTRIBUTE7
    ,  P_ATTRIBUTE8                   =>   P_ATTRIBUTE8
    ,  P_ATTRIBUTE9                   =>   P_ATTRIBUTE9
    ,  P_ATTRIBUTE10                  =>   P_ATTRIBUTE10
    ,  P_ATTRIBUTE11                  =>   P_ATTRIBUTE11
    ,  P_ATTRIBUTE12                  =>   P_ATTRIBUTE12
    ,  P_ATTRIBUTE13                  =>   P_ATTRIBUTE13
    ,  P_ATTRIBUTE14                  =>   P_ATTRIBUTE14
    ,  P_ATTRIBUTE15                  =>   P_ATTRIBUTE15
    ,  P_ATTRIBUTE16                  =>   P_ATTRIBUTE16
    ,  P_ATTRIBUTE17                  =>   P_ATTRIBUTE17
    ,  P_ATTRIBUTE18                  =>   P_ATTRIBUTE18
    ,  P_ATTRIBUTE19                  =>   P_ATTRIBUTE19
    ,  P_ATTRIBUTE20                  =>   P_ATTRIBUTE20
    ,  P_ATTRIBUTE21                  =>   P_ATTRIBUTE21
    ,  P_ATTRIBUTE22                  =>   P_ATTRIBUTE22
    ,  P_ATTRIBUTE23                  =>   P_ATTRIBUTE23
    ,  P_ATTRIBUTE24                  =>   P_ATTRIBUTE24
    ,  P_ATTRIBUTE25                  =>   P_ATTRIBUTE25
    ,  P_ATTRIBUTE26                  =>   P_ATTRIBUTE26
    ,  P_ATTRIBUTE27                  =>   P_ATTRIBUTE27
    ,  P_ATTRIBUTE28                  =>   P_ATTRIBUTE28
    ,  P_ATTRIBUTE29                  =>   P_ATTRIBUTE29
    ,  P_ATTRIBUTE30                  =>   P_ATTRIBUTE30
    ,  P_OFFER_ID                     =>   l_offer_id
    ,  P_OFFER_VERSION                =>   l_offer_version
    ,  P_OBJECT_VERSION_NUMBER        =>   l_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_offer'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all IN OUT and OUT parameters with out values
  --
  p_offer_id               := l_offer_id;
  p_object_version_number  := l_object_version_number;
  p_offer_version          := l_offer_version;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_OFFER;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_offer_id               := null;
    p_offer_version          := null;
    p_object_version_number  := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_offer_id               := null;
    p_offer_version          := null;
    p_object_version_number  := null;
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_OFFER;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_offer;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_offer >-------------------------------|
-- ----------------------------------------------------------------------------
--
   procedure update_offer
  ( P_VALIDATE                     IN   boolean     default false
   ,P_EFFECTIVE_DATE               IN   date        default null
   ,P_OFFER_STATUS                 IN   VARCHAR2    default hr_api.g_varchar2
   ,P_DISCRETIONARY_JOB_TITLE      IN   VARCHAR2    default hr_api.g_varchar2
   ,P_OFFER_EXTENDED_METHOD        IN   VARCHAR2    default hr_api.g_varchar2
   ,P_RESPONDENT_ID                IN   NUMBER      default hr_api.g_number
   ,P_EXPIRY_DATE                  IN   DATE        default hr_api.g_date
   ,P_PROPOSED_START_DATE          IN   DATE        default hr_api.g_date
   ,P_OFFER_LETTER_TRACKING_CODE   IN   VARCHAR2    default hr_api.g_varchar2
   ,P_OFFER_POSTAL_SERVICE         IN   VARCHAR2    default hr_api.g_varchar2
   ,P_OFFER_SHIPPING_DATE          IN   DATE        default hr_api.g_date
   ,P_APPLICANT_ASSIGNMENT_ID      IN   NUMBER      default hr_api.g_number
   ,P_OFFER_ASSIGNMENT_ID          IN   NUMBER      default hr_api.g_number
   ,P_ADDRESS_ID                   IN   NUMBER      default hr_api.g_number
   ,P_TEMPLATE_ID                  IN   NUMBER      default hr_api.g_number
   ,P_OFFER_LETTER_FILE_TYPE       IN   VARCHAR2    default hr_api.g_varchar2
   ,P_OFFER_LETTER_FILE_NAME       IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE_CATEGORY           IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE1                   IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE2                   IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE3                   IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE4                   IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE5                   IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE6                   IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE7                   IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE8                   IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE9                   IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE10                  IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE11                  IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE12                  IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE13                  IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE14                  IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE15                  IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE16                  IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE17                  IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE18                  IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE19                  IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE20                  IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE21                  IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE22                  IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE23                  IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE24                  IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE25                  IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE26                  IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE27                  IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE28                  IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE29                  IN   VARCHAR2    default hr_api.g_varchar2
   ,P_ATTRIBUTE30                  IN   VARCHAR2    default hr_api.g_varchar2
   ,P_CHANGE_REASON                IN   VARCHAR2    default null
   ,P_DECLINE_REASON               IN   VARCHAR2    default null
   ,P_NOTE_TEXT                    IN   VARCHAR2    default null
   ,P_STATUS_CHANGE_DATE           IN   DATE        default null
   ,P_OFFER_ID                     IN OUT  nocopy   NUMBER
   ,P_OBJECT_VERSION_NUMBER        IN OUT  nocopy   NUMBER
   ,P_OFFER_VERSION                OUT  nocopy   NUMBER
   ) is
  --
  -- Declare local variables
  --
  l_proc                        varchar2(72) := g_package||'update_offer';
  l_object_version_number       irc_offers.object_version_number%TYPE;
  l_effective_date              date;
  l_offer_id                    irc_offers.offer_id%TYPE            := p_offer_id;
  l_expiry_date                 irc_offers.expiry_date%TYPE;
  l_prev_expiry_date            irc_offers.expiry_date%TYPE;
  l_proposed_start_date         irc_offers.proposed_start_date%TYPE;
  l_offer_shipping_date         irc_offers.offer_shipping_date%TYPE;
  l_offer_status_history_id     irc_offer_status_history.offer_status_history_id%TYPE;
  l_prev_offer_status           irc_offers.offer_status%TYPE;
  l_prev_to_prev_offer_status   irc_offers.offer_status%TYPE;
  l_latest_offer                irc_offers.latest_offer%TYPE  := hr_api.g_varchar2;
  l_osh_object_version_number   irc_offer_status_history.object_version_number%TYPE;
  l_status_change_date          irc_offer_status_history.status_change_date%TYPE;
  l_mutiple_fields_updated      boolean;
  l_offer_version               irc_offers.offer_version%TYPE;
  l_offer_status                irc_offers.offer_status%TYPE := p_offer_status;
  l_offer_assignment_id         irc_offers.offer_assignment_id%TYPE;

  l_create_new_version          boolean := false;
  l_other_extended_offer_count  number := 0;
  --
  l_asg_object_version_number      per_all_assignments_f.object_version_number%TYPE;
  l_validation_start_date          date;
  l_validation_end_date            date;
  l_business_group_id              per_all_assignments_f.business_group_id%TYPE;
  l_org_now_no_manager_warning     boolean;
  l_effective_start_date           per_all_assignments_f.effective_start_date%TYPE;
  l_effective_end_date             per_all_assignments_f.effective_end_date%TYPE;
  --
  l_prev_offer_assignment_id       irc_offers.offer_assignment_id%TYPE;
  l_prev_applicant_assignment_id   irc_offers.applicant_assignment_id%TYPE;
  l_offer_letter_tracking_code     irc_offers.offer_letter_tracking_code%TYPE;
  l_offer_postal_service           irc_offers.offer_postal_service%TYPE;
  l_prev_offer_shipping_date       irc_offers.offer_shipping_date%TYPE;
  l_prev_offer_ovn                 irc_offers.object_version_number%TYPE;
  l_prev_offer_change_reason       irc_offer_status_history.change_reason%TYPE;
  --
  -- Declare cursors
  --
  cursor csr_prev_offer_details is
         select offer_status
               ,expiry_date
               ,applicant_assignment_id
               ,offer_assignment_id
               ,offer_letter_tracking_code
               ,offer_postal_service
               ,offer_shipping_date
               ,object_version_number
           from irc_offers
          where offer_id = p_offer_id;
  --
  cursor csr_assignment_record is
         select object_version_number
               ,effective_end_date
           from per_all_assignments_f
          where assignment_id = l_prev_offer_assignment_id;
  --
  cursor csr_offer_status_history_id is
         select HISTORY.offer_status_history_id
           from irc_offer_status_history HISTORY
          where HISTORY.offer_id = p_offer_id
          and NOT EXISTS
             (SELECT 1
              FROM irc_offer_status_history iosh1
             WHERE iosh1.offer_id = HISTORY.offer_id
               AND iosh1.status_change_date > HISTORY.status_change_date
             )
          AND HISTORY.offer_status_history_id =
               (SELECT MAX(iosh2.offer_status_history_id)
                  FROM irc_offer_status_history iosh2
                 WHERE iosh2.offer_id = HISTORY.offer_id
                   AND iosh2.status_change_date = HISTORY.status_change_date
               );
  --
  cursor csr_offer_status_history_dets(p_status_history_id number) is
         select change_reason
           from irc_offer_status_history
          where offer_status_history_id = p_status_history_id;
  --
  cursor csr_offer_record is
    select
       offer_version
      ,offer_status
      ,discretionary_job_title
      ,offer_extended_method
      ,respondent_id
      ,expiry_date
      ,proposed_start_date
      ,offer_letter_tracking_code
      ,offer_postal_service
      ,offer_shipping_date
      ,vacancy_id
      ,applicant_assignment_id
      ,offer_assignment_id
      ,address_id
      ,template_id
      ,offer_letter_file_type
      ,offer_letter_file_name
      ,attribute_category
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
      ,attribute6
      ,attribute7
      ,attribute8
      ,attribute9
      ,attribute10
      ,attribute11
      ,attribute12
      ,attribute13
      ,attribute14
      ,attribute15
      ,attribute16
      ,attribute17
      ,attribute18
      ,attribute19
      ,attribute20
      ,attribute21
      ,attribute22
      ,attribute23
      ,attribute24
      ,attribute25
      ,attribute26
      ,attribute27
      ,attribute28
      ,attribute29
      ,attribute30
    from irc_offers
    where offer_id = p_offer_id;

    l_offer_record        csr_offer_record%ROWTYPE;
    l_temp_offer_record   csr_offer_record%ROWTYPE;
  --
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_OFFER;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date      := trunc(p_effective_date);
  l_expiry_date         := trunc(p_expiry_date);
  l_proposed_start_date := trunc(p_proposed_start_date);
  l_offer_shipping_date := trunc(p_offer_shipping_date);
  l_status_change_date  := p_status_change_date;
  --
  open  csr_prev_offer_details;
  fetch csr_prev_offer_details into l_prev_offer_status
                                   ,l_prev_expiry_date
                                   ,l_prev_applicant_assignment_id
                                   ,l_prev_offer_assignment_id
                                   ,l_offer_letter_tracking_code
                                   ,l_offer_postal_service
                                   ,l_prev_offer_shipping_date
                                   ,l_prev_offer_ovn;
  --
  if csr_prev_offer_details%notfound
  then
    --
    close csr_prev_offer_details;
    fnd_message.set_name('PER','IRC_412322_INVALID_OFFER_ID');
    fnd_message.raise_error;
    --
  end if;
  close csr_prev_offer_details;
  --
  if l_offer_status = hr_api.g_varchar2
  then
    --
    l_offer_status := l_prev_offer_status;
    --
  end if;
  --
  open csr_assignment_record;
  fetch csr_assignment_record into l_asg_object_version_number
                                  ,l_effective_end_date;
  if csr_assignment_record%notfound
  then
    --
    close csr_assignment_record;
    fnd_message.set_name('PER','HR_289541_PJU_INV_ASG_ID');
    fnd_message.raise_error;
    --
  end if;
  close csr_assignment_record;
  --
  -- The following check is for the creation of a new offer version.
  --
  if l_prev_offer_status = 'CLOSED'
  then
    --
    -- Check if the offer_status has been set to Extended Already.
    -- This will save us some work :)
    --
    if p_offer_status = 'EXTENDED'
    then
      --
      -- Re-Open the Offer Assignment
      --
      l_effective_date := trunc(l_effective_end_date);
      --
      per_asg_del.del
      (
         p_assignment_id              => l_prev_offer_assignment_id
        ,p_effective_start_date       => l_effective_start_date
        ,p_effective_end_date         => l_effective_end_date
        ,p_business_group_id          => l_business_group_id
        ,p_object_version_number      => l_asg_object_version_number
        ,p_effective_date             => l_effective_date
        ,p_validation_start_date      => l_validation_start_date
        ,p_validation_end_date        => l_validation_end_date
        ,p_datetrack_mode             => 'FUTURE_CHANGE'
        ,p_validate                   => p_validate
        ,p_org_now_no_manager_warning => l_org_now_no_manager_warning
      );
      --
      l_effective_date := trunc(p_effective_date);
      --
    else
     --
     -- The Offer has not yet been set to EXTENDED, do the job of
     -- checking for new offer version.
     --
     -- The code to check new offer version creation has been disabled
     -- since this will now be taken care of in the Java Layer itself.
     -- New Offer version creation code is no longer supported.
     --
     --
     -- l_create_new_version := true;
     --
     hr_utility.set_location(l_proc,50);
     --
     -- 'CLOSED' offer can be updated under only 1 circumstance:
     -- 1) The offer duration has been Extended
     --
     -- Under all other circumstances, a new offer version should be created.
     --
     if (( nvl(l_expiry_date,hr_api.g_date) <> nvl(l_prev_expiry_date,hr_api.g_date))
        )
     then
       --
       irc_iof_bus.chk_multiple_fields_updated
        (     p_mutiple_fields_updated       => l_mutiple_fields_updated
             ,p_offer_id                     => p_offer_id
             ,p_offer_status                 => p_offer_status
             ,p_discretionary_job_title      => p_discretionary_job_title
             ,p_offer_extended_method        => p_offer_extended_method
             ,p_expiry_date                  => l_expiry_date
             ,p_proposed_start_date          => p_proposed_start_date
             ,p_offer_letter_tracking_code   => p_offer_letter_tracking_code
             ,p_offer_postal_service         => p_offer_postal_service
             ,p_offer_shipping_date          => p_offer_shipping_date
             ,p_applicant_assignment_id      => p_applicant_assignment_id
             ,p_offer_assignment_id          => p_offer_assignment_id
             ,p_address_id                   => p_address_id
             ,p_template_id                  => p_template_id
             ,p_offer_letter_file_type       => p_offer_letter_file_type
             ,p_offer_letter_file_name       => p_offer_letter_file_name
             ,p_attribute_category           => p_attribute_category
             ,p_attribute1                   => p_attribute1
             ,p_attribute2                   => p_attribute2
             ,p_attribute3                   => p_attribute3
             ,p_attribute4                   => p_attribute4
             ,p_attribute5                   => p_attribute5
             ,p_attribute6                   => p_attribute6
             ,p_attribute7                   => p_attribute7
             ,p_attribute8                   => p_attribute8
             ,p_attribute9                   => p_attribute9
             ,p_attribute10                  => p_attribute10
             ,p_attribute11                  => p_attribute11
             ,p_attribute12                  => p_attribute12
             ,p_attribute13                  => p_attribute13
             ,p_attribute14                  => p_attribute14
             ,p_attribute15                  => p_attribute15
             ,p_attribute16                  => p_attribute16
             ,p_attribute17                  => p_attribute17
             ,p_attribute18                  => p_attribute18
             ,p_attribute19                  => p_attribute19
             ,p_attribute20                  => p_attribute20
             ,p_attribute21                  => p_attribute21
             ,p_attribute22                  => p_attribute22
             ,p_attribute23                  => p_attribute23
             ,p_attribute24                  => p_attribute24
             ,p_attribute25                  => p_attribute25
             ,p_attribute26                  => p_attribute26
             ,p_attribute27                  => p_attribute27
             ,p_attribute28                  => p_attribute28
             ,p_attribute29                  => p_attribute29
             ,p_attribute30                  => p_attribute30
        );
       --
       if ( l_mutiple_fields_updated = false
            AND p_offer_status <> 'HOLD'  -- Work Around! if ofeer is set to HOLD and the expiry date
                                          -- is not passed in, the flow can come this far.
                                          -- Atleast stop it here.
          )

       then
         l_create_new_version := false;
         --
         if P_CHANGE_REASON<>'APL_DECLINED_ACCEPTANCE' AND P_CHANGE_REASON<>'MGR_WITHDRAW' AND P_CHANGE_REASON<>'APL_HIRED' then
         --
         -- If the offer duration has been extended, we need to change
         -- the offer status to 'EXTENDED'
         --
         l_offer_status := 'EXTENDED';
         --
         -- Re-Open the Offer Assignment
         --
         l_effective_date := trunc(l_effective_end_date);
         --
         per_asg_del.del
         (
           p_assignment_id              => l_prev_offer_assignment_id
          ,p_effective_start_date       => l_effective_start_date
          ,p_effective_end_date         => l_effective_end_date
          ,p_business_group_id          => l_business_group_id
          ,p_object_version_number      => l_asg_object_version_number
          ,p_effective_date             => l_effective_date
          ,p_validation_start_date      => l_validation_start_date
          ,p_validation_end_date        => l_validation_end_date
          ,p_datetrack_mode             => 'FUTURE_CHANGE'
          ,p_validate                   => p_validate
          ,p_org_now_no_manager_warning => l_org_now_no_manager_warning
         );
         --
         l_effective_date := trunc(p_effective_date);
         --
       end if;
     end if;
     end if; -- P_CHANGE_REASON<>'APL_DECLINED_ACCEPTANCE'
    end if; -- offer_status = 'EXTENDED'
    --
  end if; -- prev_offer_status = 'CLOSED'
  --
  hr_utility.set_location(l_proc,60);
  --
  -- If l_create_new_version is true, a new offer version should be
  -- created and the current offer version should be closed.
  --
  if  l_create_new_version = true
  then
    --
    hr_utility.set_location(l_proc,70);
    --
    -- Fetch the previous offer version's record.
    --
    open csr_offer_record;
    fetch csr_offer_record into l_offer_record;
    --
    if csr_offer_record%notfound
    then
      --
      hr_utility.set_location(l_proc, 75);
      --
      close csr_offer_record;
      fnd_message.set_name('PER','IRC_412322_INVALID_OFFER_ID');
      fnd_message.raise_error;
      --
    end if;
    close csr_offer_record;
    --
    -- Store current values in a temporary variable
    --
    l_temp_offer_record.discretionary_job_title          := p_discretionary_job_title;
    l_temp_offer_record.offer_extended_method            := p_offer_extended_method;
    l_temp_offer_record.respondent_id                    := p_respondent_id;
    l_temp_offer_record.expiry_date                      := l_expiry_date;
    l_temp_offer_record.proposed_start_date              := p_proposed_start_date;
    l_temp_offer_record.offer_letter_tracking_code       := p_offer_letter_tracking_code;
    l_temp_offer_record.offer_postal_service             := p_offer_postal_service;
    l_temp_offer_record.offer_shipping_date              := p_offer_shipping_date;
    l_temp_offer_record.applicant_assignment_id          := p_applicant_assignment_id;
    l_temp_offer_record.offer_assignment_id              := p_offer_assignment_id;
    l_temp_offer_record.address_id                       := p_address_id;
    l_temp_offer_record.template_id                      := p_template_id;
    l_temp_offer_record.offer_letter_file_type           := p_offer_letter_file_type;
    l_temp_offer_record.offer_letter_file_name           := p_offer_letter_file_name;
    l_temp_offer_record.attribute_category               := p_attribute_category;
    l_temp_offer_record.attribute1                       := p_attribute1;
    l_temp_offer_record.attribute2                       := p_attribute2;
    l_temp_offer_record.attribute3                       := p_attribute3;
    l_temp_offer_record.attribute4                       := p_attribute4;
    l_temp_offer_record.attribute5                       := p_attribute5;
    l_temp_offer_record.attribute6                       := p_attribute6;
    l_temp_offer_record.attribute7                       := p_attribute7;
    l_temp_offer_record.attribute8                       := p_attribute8;
    l_temp_offer_record.attribute9                       := p_attribute9;
    l_temp_offer_record.attribute10                      := p_attribute10;
    l_temp_offer_record.attribute11                      := p_attribute11;
    l_temp_offer_record.attribute12                      := p_attribute12;
    l_temp_offer_record.attribute13                      := p_attribute13;
    l_temp_offer_record.attribute14                      := p_attribute14;
    l_temp_offer_record.attribute15                      := p_attribute15;
    l_temp_offer_record.attribute16                      := p_attribute16;
    l_temp_offer_record.attribute17                      := p_attribute17;
    l_temp_offer_record.attribute18                      := p_attribute18;
    l_temp_offer_record.attribute19                      := p_attribute19;
    l_temp_offer_record.attribute20                      := p_attribute20;
    l_temp_offer_record.attribute21                      := p_attribute21;
    l_temp_offer_record.attribute22                      := p_attribute22;
    l_temp_offer_record.attribute23                      := p_attribute23;
    l_temp_offer_record.attribute24                      := p_attribute24;
    l_temp_offer_record.attribute25                      := p_attribute25;
    l_temp_offer_record.attribute26                      := p_attribute26;
    l_temp_offer_record.attribute27                      := p_attribute27;
    l_temp_offer_record.attribute28                      := p_attribute28;
    l_temp_offer_record.attribute29                      := p_attribute29;
    l_temp_offer_record.attribute30                      := p_attribute30;
    --
    -- Check if any of the variables have system default values,
    -- if so, set them to their previous values.
    --
    if (  l_temp_offer_record.discretionary_job_title = hr_api.g_varchar2) then
      l_temp_offer_record.discretionary_job_title := l_offer_record.discretionary_job_title;
    end if;
    if (  l_temp_offer_record.offer_extended_method = hr_api.g_varchar2) then
      l_temp_offer_record.offer_extended_method := l_offer_record.offer_extended_method;
    end if;
    if (  l_temp_offer_record.respondent_id = hr_api.g_number) then
      l_temp_offer_record.respondent_id := l_offer_record.respondent_id;
    end if;
    if (  l_temp_offer_record.expiry_date = hr_api.g_date) then
      l_temp_offer_record.expiry_date := l_offer_record.expiry_date;
    end if;
    if (  l_temp_offer_record.proposed_start_date = hr_api.g_date) then
      l_temp_offer_record.proposed_start_date := l_offer_record.proposed_start_date;
    end if;
    if (  l_temp_offer_record.offer_letter_tracking_code = hr_api.g_varchar2) then
      l_temp_offer_record.offer_letter_tracking_code := l_offer_record.offer_letter_tracking_code;
    end if;
    if (  l_temp_offer_record.offer_postal_service = hr_api.g_varchar2) then
      l_temp_offer_record.offer_postal_service := l_offer_record.offer_postal_service;
    end if;
    if (  l_temp_offer_record.offer_shipping_date = hr_api.g_date) then
      l_temp_offer_record.offer_shipping_date := l_offer_record.offer_shipping_date;
    end if;
    if (  l_temp_offer_record.applicant_assignment_id = hr_api.g_number) then
      l_temp_offer_record.applicant_assignment_id := l_offer_record.applicant_assignment_id;
    end if;
    if (  l_temp_offer_record.offer_assignment_id = hr_api.g_number) then
      l_temp_offer_record.offer_assignment_id := l_offer_record.offer_assignment_id;
    end if;
    if (  l_temp_offer_record.address_id = hr_api.g_number) then
      l_temp_offer_record.address_id := l_offer_record.address_id;
    end if;
    if (  l_temp_offer_record.template_id = hr_api.g_number) then
      l_temp_offer_record.template_id := l_offer_record.template_id;
    end if;
    if (  l_temp_offer_record.offer_letter_file_type = hr_api.g_varchar2) then
      l_temp_offer_record.offer_letter_file_type := l_offer_record.offer_letter_file_type;
    end if;
    if (  l_temp_offer_record.offer_letter_file_name = hr_api.g_varchar2) then
      l_temp_offer_record.offer_letter_file_name := l_offer_record.offer_letter_file_name;
    end if;
    if (  l_temp_offer_record.attribute_category = hr_api.g_varchar2) then
      l_temp_offer_record.attribute_category := l_offer_record.attribute_category;
    end if;
    if (  l_temp_offer_record.attribute1 = hr_api.g_varchar2) then
      l_temp_offer_record.attribute1 := l_offer_record.attribute1;
    end if;
    if (  l_temp_offer_record.attribute2 = hr_api.g_varchar2) then
      l_temp_offer_record.attribute2 := l_offer_record.attribute2;
    end if;
    if (  l_temp_offer_record.attribute3 = hr_api.g_varchar2) then
      l_temp_offer_record.attribute3 := l_offer_record.attribute3;
    end if;
    if (  l_temp_offer_record.attribute4 = hr_api.g_varchar2) then
      l_temp_offer_record.attribute4 := l_offer_record.attribute4;
    end if;
    if (  l_temp_offer_record.attribute5 = hr_api.g_varchar2) then
      l_temp_offer_record.attribute5 := l_offer_record.attribute5;
    end if;
    if (  l_temp_offer_record.attribute6 = hr_api.g_varchar2) then
      l_temp_offer_record.attribute6 := l_offer_record.attribute6;
    end if;
    if (  l_temp_offer_record.attribute7 = hr_api.g_varchar2) then
      l_temp_offer_record.attribute7 := l_offer_record.attribute7;
    end if;
    if (  l_temp_offer_record.attribute8 = hr_api.g_varchar2) then
      l_temp_offer_record.attribute8 := l_offer_record.attribute8;
    end if;
    if (  l_temp_offer_record.attribute9 = hr_api.g_varchar2) then
      l_temp_offer_record.attribute9 := l_offer_record.attribute9;
    end if;
    if (  l_temp_offer_record.attribute10 = hr_api.g_varchar2) then
      l_temp_offer_record.attribute10 := l_offer_record.attribute10;
    end if;
    if (  l_temp_offer_record.attribute11 = hr_api.g_varchar2) then
      l_temp_offer_record.attribute11 := l_offer_record.attribute11;
    end if;
    if (  l_temp_offer_record.attribute12 = hr_api.g_varchar2) then
      l_temp_offer_record.attribute12 := l_offer_record.attribute12;
    end if;
    if (  l_temp_offer_record.attribute13 = hr_api.g_varchar2) then
      l_temp_offer_record.attribute13 := l_offer_record.attribute13;
    end if;
    if (  l_temp_offer_record.attribute14 = hr_api.g_varchar2) then
      l_temp_offer_record.attribute14 := l_offer_record.attribute14;
    end if;
    if (  l_temp_offer_record.attribute15 = hr_api.g_varchar2) then
      l_temp_offer_record.attribute15 := l_offer_record.attribute15;
    end if;
    if (  l_temp_offer_record.attribute16 = hr_api.g_varchar2) then
      l_temp_offer_record.attribute16 := l_offer_record.attribute16;
    end if;
    if (  l_temp_offer_record.attribute17 = hr_api.g_varchar2) then
      l_temp_offer_record.attribute17 := l_offer_record.attribute17;
    end if;
    if (  l_temp_offer_record.attribute18 = hr_api.g_varchar2) then
      l_temp_offer_record.attribute18 := l_offer_record.attribute18;
    end if;
    if (  l_temp_offer_record.attribute19 = hr_api.g_varchar2) then
      l_temp_offer_record.attribute19 := l_offer_record.attribute19;
    end if;
    if (  l_temp_offer_record.attribute20 = hr_api.g_varchar2) then
      l_temp_offer_record.attribute20 := l_offer_record.attribute20;
    end if;
    if (  l_temp_offer_record.attribute21 = hr_api.g_varchar2) then
      l_temp_offer_record.attribute21 := l_offer_record.attribute21;
    end if;
    if (  l_temp_offer_record.attribute22 = hr_api.g_varchar2) then
      l_temp_offer_record.attribute22 := l_offer_record.attribute22;
    end if;
    if (  l_temp_offer_record.attribute23 = hr_api.g_varchar2) then
      l_temp_offer_record.attribute23 := l_offer_record.attribute23;
    end if;
    if (  l_temp_offer_record.attribute24 = hr_api.g_varchar2) then
      l_temp_offer_record.attribute24 := l_offer_record.attribute24;
    end if;
    if (  l_temp_offer_record.attribute25 = hr_api.g_varchar2) then
      l_temp_offer_record.attribute25 := l_offer_record.attribute25;
    end if;
    if (  l_temp_offer_record.attribute26 = hr_api.g_varchar2) then
      l_temp_offer_record.attribute26 := l_offer_record.attribute26;
    end if;
    if (  l_temp_offer_record.attribute27 = hr_api.g_varchar2) then
      l_temp_offer_record.attribute27 := l_offer_record.attribute27;
    end if;
    if (  l_temp_offer_record.attribute28 = hr_api.g_varchar2) then
      l_temp_offer_record.attribute28 := l_offer_record.attribute28;
    end if;
    if (  l_temp_offer_record.attribute29 = hr_api.g_varchar2) then
      l_temp_offer_record.attribute29 := l_offer_record.attribute29;
    end if;
    if (  l_temp_offer_record.attribute30 = hr_api.g_varchar2) then
      l_temp_offer_record.attribute30 := l_offer_record.attribute30;
    end if;
    --
    -- Create a new offer assignment copied from prev offer assignment.
    --
    hr_utility.set_location(l_proc,77);
    --
    create_offer_assignment_copy
    (  p_validate                         =>  p_validate
     , p_effective_date                   =>  l_effective_date
     , p_source_assignment_id             =>  l_prev_offer_assignment_id
     , p_offer_assignment_id              =>  l_offer_assignment_id
    );
    --
    -- Create a new offer version.
    --
    create_offer
    (p_validate                     => p_validate
    ,p_effective_date               => l_effective_date
    ,p_offer_status                 => 'SAVED'
    ,p_discretionary_job_title      => l_temp_offer_record.discretionary_job_title
    ,p_offer_extended_method        => l_temp_offer_record.offer_extended_method
    ,p_respondent_id                => l_temp_offer_record.respondent_id
    ,p_expiry_date                  => l_temp_offer_record.expiry_date
    ,p_proposed_start_date          => l_temp_offer_record.proposed_start_date
    ,p_offer_letter_tracking_code   => l_temp_offer_record.offer_letter_tracking_code
    ,p_offer_postal_service         => l_temp_offer_record.offer_postal_service
    ,p_offer_shipping_date          => l_temp_offer_record.offer_shipping_date
    ,p_applicant_assignment_id      => l_temp_offer_record.applicant_assignment_id
    ,p_address_id                   => l_temp_offer_record.address_id
    ,p_template_id                  => l_temp_offer_record.template_id
    ,p_offer_letter_file_type       => l_temp_offer_record.offer_letter_file_type
    ,p_offer_letter_file_name       => l_temp_offer_record.offer_letter_file_name
    ,p_attribute_category           => l_temp_offer_record.attribute_category
    ,p_attribute1                   => l_temp_offer_record.attribute1
    ,p_attribute2                   => l_temp_offer_record.attribute2
    ,p_attribute3                   => l_temp_offer_record.attribute3
    ,p_attribute4                   => l_temp_offer_record.attribute4
    ,p_attribute5                   => l_temp_offer_record.attribute5
    ,p_attribute6                   => l_temp_offer_record.attribute6
    ,p_attribute7                   => l_temp_offer_record.attribute7
    ,p_attribute8                   => l_temp_offer_record.attribute8
    ,p_attribute9                   => l_temp_offer_record.attribute9
    ,p_attribute10                  => l_temp_offer_record.attribute10
    ,p_attribute11                  => l_temp_offer_record.attribute11
    ,p_attribute12                  => l_temp_offer_record.attribute12
    ,p_attribute13                  => l_temp_offer_record.attribute13
    ,p_attribute14                  => l_temp_offer_record.attribute14
    ,p_attribute15                  => l_temp_offer_record.attribute15
    ,p_attribute16                  => l_temp_offer_record.attribute16
    ,p_attribute17                  => l_temp_offer_record.attribute17
    ,p_attribute18                  => l_temp_offer_record.attribute18
    ,p_attribute19                  => l_temp_offer_record.attribute19
    ,p_attribute20                  => l_temp_offer_record.attribute20
    ,p_attribute21                  => l_temp_offer_record.attribute21
    ,p_attribute22                  => l_temp_offer_record.attribute22
    ,p_attribute23                  => l_temp_offer_record.attribute23
    ,p_attribute24                  => l_temp_offer_record.attribute24
    ,p_attribute25                  => l_temp_offer_record.attribute25
    ,p_attribute26                  => l_temp_offer_record.attribute26
    ,p_attribute27                  => l_temp_offer_record.attribute27
    ,p_attribute28                  => l_temp_offer_record.attribute28
    ,p_attribute29                  => l_temp_offer_record.attribute29
    ,p_attribute30                  => l_temp_offer_record.attribute30
    ,p_status_change_date           => l_status_change_date
    ,p_offer_assignment_id          => l_offer_assignment_id
    ,p_offer_id                     => l_offer_id
    ,p_offer_version                => l_offer_version
    ,p_object_version_number        => l_object_version_number
    );
    --
    hr_utility.set_location(' Leaving:'||l_proc, 78);
    --
  else -- l_create_new_version = false
  --
  -- Proceed with normal Update.
  --
  begin
  IRC_OFFERS_BK2.update_offer_b
   (   P_EFFECTIVE_DATE               =>   l_effective_date
    ,  P_OFFER_ID                     =>   P_OFFER_ID
    ,  P_LATEST_OFFER                 =>   l_latest_offer
    ,  P_OFFER_STATUS                 =>   l_offer_status
    ,  P_DISCRETIONARY_JOB_TITLE      =>   P_DISCRETIONARY_JOB_TITLE
    ,  P_OFFER_EXTENDED_METHOD        =>   P_OFFER_EXTENDED_METHOD
    ,  P_RESPONDENT_ID                =>   P_RESPONDENT_ID
    ,  P_EXPIRY_DATE                  =>   l_expiry_date
    ,  P_PROPOSED_START_DATE          =>   l_proposed_start_date
    ,  P_OFFER_LETTER_TRACKING_CODE   =>   P_OFFER_LETTER_TRACKING_CODE
    ,  P_OFFER_POSTAL_SERVICE         =>   P_OFFER_POSTAL_SERVICE
    ,  P_OFFER_SHIPPING_DATE          =>   l_offer_shipping_date
    ,  P_APPLICANT_ASSIGNMENT_ID      =>   P_APPLICANT_ASSIGNMENT_ID
    ,  P_OFFER_ASSIGNMENT_ID          =>   P_OFFER_ASSIGNMENT_ID
    ,  P_ADDRESS_ID                   =>   P_ADDRESS_ID
    ,  P_TEMPLATE_ID                  =>   P_TEMPLATE_ID
    ,  P_OFFER_LETTER_FILE_TYPE       =>   P_OFFER_LETTER_FILE_TYPE
    ,  P_OFFER_LETTER_FILE_NAME       =>   P_OFFER_LETTER_FILE_NAME
    ,  P_ATTRIBUTE_CATEGORY           =>   P_ATTRIBUTE_CATEGORY
    ,  P_ATTRIBUTE1                   =>   P_ATTRIBUTE1
    ,  P_ATTRIBUTE2                   =>   P_ATTRIBUTE2
    ,  P_ATTRIBUTE3                   =>   P_ATTRIBUTE3
    ,  P_ATTRIBUTE4                   =>   P_ATTRIBUTE4
    ,  P_ATTRIBUTE5                   =>   P_ATTRIBUTE5
    ,  P_ATTRIBUTE6                   =>   P_ATTRIBUTE6
    ,  P_ATTRIBUTE7                   =>   P_ATTRIBUTE7
    ,  P_ATTRIBUTE8                   =>   P_ATTRIBUTE8
    ,  P_ATTRIBUTE9                   =>   P_ATTRIBUTE9
    ,  P_ATTRIBUTE10                  =>   P_ATTRIBUTE10
    ,  P_ATTRIBUTE11                  =>   P_ATTRIBUTE11
    ,  P_ATTRIBUTE12                  =>   P_ATTRIBUTE12
    ,  P_ATTRIBUTE13                  =>   P_ATTRIBUTE13
    ,  P_ATTRIBUTE14                  =>   P_ATTRIBUTE14
    ,  P_ATTRIBUTE15                  =>   P_ATTRIBUTE15
    ,  P_ATTRIBUTE16                  =>   P_ATTRIBUTE16
    ,  P_ATTRIBUTE17                  =>   P_ATTRIBUTE17
    ,  P_ATTRIBUTE18                  =>   P_ATTRIBUTE18
    ,  P_ATTRIBUTE19                  =>   P_ATTRIBUTE19
    ,  P_ATTRIBUTE20                  =>   P_ATTRIBUTE20
    ,  P_ATTRIBUTE21                  =>   P_ATTRIBUTE21
    ,  P_ATTRIBUTE22                  =>   P_ATTRIBUTE22
    ,  P_ATTRIBUTE23                  =>   P_ATTRIBUTE23
    ,  P_ATTRIBUTE24                  =>   P_ATTRIBUTE24
    ,  P_ATTRIBUTE25                  =>   P_ATTRIBUTE25
    ,  P_ATTRIBUTE26                  =>   P_ATTRIBUTE26
    ,  P_ATTRIBUTE27                  =>   P_ATTRIBUTE27
    ,  P_ATTRIBUTE28                  =>   P_ATTRIBUTE28
    ,  P_ATTRIBUTE29                  =>   P_ATTRIBUTE29
    ,  P_ATTRIBUTE30                  =>   P_ATTRIBUTE30
    ,  P_OBJECT_VERSION_NUMBER        =>   p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_offer'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  l_offer_id              := p_offer_id;
  --
  -- Check if offer_status is 'EXTENDED'
  --
  if l_offer_status = 'EXTENDED'
  then
    --
    if 'N' = fnd_profile.value('IRC_ALLOW_MULTI_OFFERS')
       OR 'E' = fnd_profile.value('IRC_ALLOW_MULTI_OFFERS')
       OR fnd_profile.value('IRC_ALLOW_MULTI_OFFERS') is null
    then
      --
      other_extended_offers_count
      ( p_applicant_assignment_id     => l_prev_applicant_assignment_id
       ,p_effective_date              => p_effective_date
       ,p_other_extended_offer_count  => l_other_extended_offer_count
      );
      --
      if l_other_extended_offer_count > 0
      then
        --
        -- This happens when an offer is being EXTENDED. Throw an error refusing to
        -- EXTEND another offer to the candidate
        --
        fnd_message.set_name('PER','IRC_412377_MULTIPLE_OFFER_SEND'); -- You cannot send another offer to this applicant as
                                                                      -- an active offer exists for this application
        fnd_message.raise_error;
        --
      end if;
    end if;
    --
    -- check if the Previous status is CLOSED
    -- and handle the situation where the PENDING_EXTENDED gets Approved
    -- but the Offer has already EXPIRED
    if l_prev_offer_status = 'CLOSED' then
       -- get the last Offer Status History change record
       open csr_offer_status_history_id;
       fetch csr_offer_status_history_id into l_offer_status_history_id;
       close csr_offer_status_history_id;

       if l_offer_status_history_id is not null then
         -- get the Change Reason for last Offer Status Change
         open csr_offer_status_history_dets(l_offer_status_history_id);
         fetch csr_offer_status_history_dets into l_prev_offer_change_reason;
         close csr_offer_status_history_dets;
         -- check if this Offer has been closed EARLIER due to EXPIRY
         if l_prev_offer_change_reason = 'EXPIRED' then
           -- get the old OVN and set it as NEW
           l_object_version_number := l_prev_offer_ovn;
         end if;
       end if;
    end if;
  end if;
  --
  -- Check if offer_status is 'CLOSED'
  --
  if ( l_offer_status = 'CLOSED'
     ) then
     --
     -- Check that a closure reason is provided before closing the offer
     --
     if p_change_reason is null
     then
        --
        fnd_message.set_name('PER','IRC_412299_CLOSE_REASON_MNDTRY');
        fnd_message.raise_error;
        --
     end if;
     --
     -- Check if the change_reason is 'WITHDRAWAL'. If yes, close
     -- the offer irrespective of the current offer status.
     -- Else, check for the current offer_status.
     --
     hr_utility.set_location(l_proc,100);
     --
     if ((  p_change_reason = 'EXPIRED'
         OR p_change_reason = 'APL_DECLINED'
         OR p_change_reason = 'APL_ACCEPTED'
         )
        AND (l_prev_offer_status <> 'EXTENDED'
             AND l_prev_offer_status <> 'HOLD'
             AND l_prev_offer_status <> 'PENDING_EXTENDED')
        )
     then
        --
        hr_utility.set_location(l_proc,105);
        --
        fnd_message.set_name('PER','IRC_412300_OFFER_NOT_EXTENDED');
        fnd_message.raise_error;
        --
     end if;
     --
     if (   p_change_reason <> 'WITHDRAWAL'
         OR p_change_reason is null  -- Null check
        ) then
        --
        hr_utility.set_location(l_proc,110);
        --
        -- Check to see if the offer status is Closed. If yes,
        -- throw an error saying that the offer cannot be closed.
        --
        if (  l_prev_offer_status = 'CLOSED'
           ) then
           --
           hr_utility.set_location(l_proc,120);
           --
           -- Close offer can be called on a closed offer with change
           -- reason APL_DECLINED_ACCEPTANCE, MGR_WITHDRAW, APL_HIRED
           --
           if p_change_reason<>'APL_DECLINED_ACCEPTANCE' and p_change_reason<>'MGR_WITHDRAW' and p_change_reason<>'APL_HIRED' then
             fnd_message.set_name('PER','IRC_412301_OFR_CANT_BE_CLOSED');
             fnd_message.raise_error;
           end if;
         end if;
     end if;
     --
     -- If the Applicant has Accepted the offer, copy the offer assignment details into
     -- applicant assignment record and copy the details from pay proposal record for the
     -- offer assignment to the pay proposal record for applicant assignment.
     --
     if ( p_change_reason = 'APL_ACCEPTED' )
     then
       --
       copy_offer_asg_to_appl_asg
       ( p_offer_id                     => P_OFFER_ID
        ,p_effective_date               => p_effective_date
        ,p_validate                     => p_validate
       );
       --
       copy_offer_pay_to_appl_pay
       ( p_validate                     => p_validate
        ,p_offer_id                     => P_offer_id
        ,p_effective_date               => p_effective_date
       );
       --
     end if;
  end if;
  --
  -- Check if the offer has been approved from PENDING_EXTENDED status
  -- If no other field has been modified, set the offer_status to EXTENDED.
  --
  if l_prev_offer_status = 'PENDING_EXTENDED'
    and l_offer_status = 'EXTENDED'
  then
    --
    hr_utility.set_location(l_proc,122);
    --
    -- pass in old status PENDING_EXTENDED to this method
    irc_iof_bus.chk_multiple_fields_updated
    (   p_mutiple_fields_updated       => l_mutiple_fields_updated
       ,p_offer_id                     => p_offer_id
       ,p_offer_status                 => l_prev_offer_status
       ,p_discretionary_job_title      => p_discretionary_job_title
       ,p_offer_extended_method        => p_offer_extended_method
       ,p_expiry_date                  => l_expiry_date
       ,p_proposed_start_date          => p_proposed_start_date
       ,p_offer_letter_tracking_code   => p_offer_letter_tracking_code
       ,p_offer_postal_service         => p_offer_postal_service
       ,p_offer_shipping_date          => p_offer_shipping_date
       ,p_applicant_assignment_id      => p_applicant_assignment_id
       ,p_offer_assignment_id          => p_offer_assignment_id
       ,p_address_id                   => p_address_id
       ,p_template_id                  => p_template_id
       ,p_offer_letter_file_type       => p_offer_letter_file_type
       ,p_offer_letter_file_name       => p_offer_letter_file_name
       ,p_attribute_category           => p_attribute_category
       ,p_attribute1                   => p_attribute1
       ,p_attribute2                   => p_attribute2
       ,p_attribute3                   => p_attribute3
       ,p_attribute4                   => p_attribute4
       ,p_attribute5                   => p_attribute5
       ,p_attribute6                   => p_attribute6
       ,p_attribute7                   => p_attribute7
       ,p_attribute8                   => p_attribute8
       ,p_attribute9                   => p_attribute9
       ,p_attribute10                  => p_attribute10
       ,p_attribute11                  => p_attribute11
       ,p_attribute12                  => p_attribute12
       ,p_attribute13                  => p_attribute13
       ,p_attribute14                  => p_attribute14
       ,p_attribute15                  => p_attribute15
       ,p_attribute16                  => p_attribute16
       ,p_attribute17                  => p_attribute17
       ,p_attribute18                  => p_attribute18
       ,p_attribute19                  => p_attribute19
       ,p_attribute20                  => p_attribute20
       ,p_attribute21                  => p_attribute21
       ,p_attribute22                  => p_attribute22
       ,p_attribute23                  => p_attribute23
       ,p_attribute24                  => p_attribute24
       ,p_attribute25                  => p_attribute25
       ,p_attribute26                  => p_attribute26
       ,p_attribute27                  => p_attribute27
       ,p_attribute28                  => p_attribute28
       ,p_attribute29                  => p_attribute29
       ,p_attribute30                  => p_attribute30
    );
    --
    if ( l_mutiple_fields_updated = false )
    then
      --
      hr_utility.set_location(l_proc,125);
      --
      l_offer_status := 'EXTENDED';
      --
    else
      --
      fnd_message.set_name('PER','IRC_412302_PNDNG_EXTNDD_MODFD');
      fnd_message.raise_error;
      --
   end if;
  --
  end if;

  hr_utility.set_location(l_proc,130);
  --
  irc_iof_upd.upd
   (   p_effective_date                 =>  l_effective_date
    ,  p_offer_id                       =>  l_offer_id
    ,  p_object_version_number          =>  l_object_version_number
    ,  p_offer_version                  =>  l_offer_version
    ,  p_latest_offer                   =>  l_latest_offer
    ,  p_applicant_assignment_id        =>  p_applicant_assignment_id
    ,  p_offer_assignment_id            =>  p_offer_assignment_id
    ,  p_offer_status                   =>  l_offer_status
    ,  p_discretionary_job_title        =>  p_discretionary_job_title
    ,  p_offer_extended_method          =>  p_offer_extended_method
    ,  p_respondent_id                  =>  p_respondent_id
    ,  p_expiry_date                    =>  l_expiry_date
    ,  p_proposed_start_date            =>  l_proposed_start_date
    ,  p_offer_letter_tracking_code     =>  p_offer_letter_tracking_code
    ,  p_offer_postal_service           =>  p_offer_postal_service
    ,  p_offer_shipping_date            =>  l_offer_shipping_date
    ,  p_address_id                     =>  p_address_id
    ,  p_template_id                    =>  p_template_id
    ,  p_offer_letter_file_type         =>  p_offer_letter_file_type
    ,  p_offer_letter_file_name         =>  p_offer_letter_file_name
    ,  p_attribute_category             =>  p_attribute_category
    ,  p_attribute1                     =>  p_attribute1
    ,  p_attribute2                     =>  p_attribute2
    ,  p_attribute3                     =>  p_attribute3
    ,  p_attribute4                     =>  p_attribute4
    ,  p_attribute5                     =>  p_attribute5
    ,  p_attribute6                     =>  p_attribute6
    ,  p_attribute7                     =>  p_attribute7
    ,  p_attribute8                     =>  p_attribute8
    ,  p_attribute9                     =>  p_attribute9
    ,  p_attribute10                    =>  p_attribute10
    ,  p_attribute11                    =>  p_attribute11
    ,  p_attribute12                    =>  p_attribute12
    ,  p_attribute13                    =>  p_attribute13
    ,  p_attribute14                    =>  p_attribute14
    ,  p_attribute15                    =>  p_attribute15
    ,  p_attribute16                    =>  p_attribute16
    ,  p_attribute17                    =>  p_attribute17
    ,  p_attribute18                    =>  p_attribute18
    ,  p_attribute19                    =>  p_attribute19
    ,  p_attribute20                    =>  p_attribute20
    ,  p_attribute21                    =>  p_attribute21
    ,  p_attribute22                    =>  p_attribute22
    ,  p_attribute23                    =>  p_attribute23
    ,  p_attribute24                    =>  p_attribute24
    ,  p_attribute25                    =>  p_attribute25
    ,  p_attribute26                    =>  p_attribute26
    ,  p_attribute27                    =>  p_attribute27
    ,  p_attribute28                    =>  p_attribute28
    ,  p_attribute29                    =>  p_attribute29
    ,  p_attribute30                    =>  p_attribute30
 );

  --
  -- Get the previous change reason
  --
  if l_offer_status = 'CLOSED' then
    -- get the last Offer Status History change record
    open csr_offer_status_history_id;
    fetch csr_offer_status_history_id into l_offer_status_history_id;
    close csr_offer_status_history_id;
    --
    if l_offer_status_history_id is not null then
      -- get the Change Reason for last Offer Status Change
      open csr_offer_status_history_dets(l_offer_status_history_id);
      fetch csr_offer_status_history_dets into l_prev_offer_change_reason;
      close csr_offer_status_history_dets;
    end if;
  end if;

  --
  -- Create offer history record. Call this in the following scenarios:
  -- 1) Status has changed
  -- 2) The offer duration has been extended and the offer is in EXTENDED status.
  -- 3) The offer status change reason has changed.
  --
  if (l_offer_status <> l_prev_offer_status) OR
     (l_offer_status = 'EXTENDED' AND
      (nvl(l_expiry_date,hr_api.g_date) <> nvl(l_prev_expiry_date,hr_api.g_date))
     ) OR
     (l_prev_offer_change_reason <> p_change_reason)
  then
     --
     -- IF any one of offer_letter_tracking_code or offer_postal_service or
     -- offer_shipping_date is set, add an entry in status history table only if
     -- expiry_date has been manually set.
     --
     if not
     (
       (
         (
           ((l_offer_status = 'EXTENDED') or (l_offer_status = hr_api.g_varchar2))
           and (nvl(p_offer_letter_tracking_code,hr_api.g_varchar2) <> nvl(l_offer_letter_tracking_code,hr_api.g_varchar2))
           and p_offer_letter_tracking_code <> hr_api.g_varchar2
         )
      or (
           ((l_offer_status = 'EXTENDED') or (l_offer_status = hr_api.g_varchar2))
           and (nvl(p_offer_postal_service,hr_api.g_varchar2) <> nvl(l_offer_postal_service,hr_api.g_varchar2))
           and p_offer_postal_service <> hr_api.g_varchar2
         )
      or (
           ((l_offer_status = 'EXTENDED') or (l_offer_status = hr_api.g_varchar2))
           and (nvl(l_offer_shipping_date,hr_api.g_date) <> nvl(l_prev_offer_shipping_date,hr_api.g_date))
           and l_offer_shipping_date <> hr_api.g_date
         )
       )
       and
       (l_expiry_date = hr_api.g_date)
     )
     then
     --
     hr_utility.set_location(l_proc,140);
     --
     irc_offer_status_history_api.create_offer_status_history
     (   p_validate                        =>  p_validate
      ,  p_effective_date                  =>  l_effective_date
      ,  p_offer_status_history_id         =>  l_offer_status_history_id
      ,  p_offer_id                        =>  p_offer_id
      ,  p_offer_status                    =>  l_offer_status
      ,  p_change_reason                   =>  p_change_reason
      ,  p_decline_reason                  =>  p_decline_reason
      ,  p_note_text                       =>  p_note_text
      ,  p_object_version_number           =>  l_osh_object_version_number
      ,  p_status_change_date              =>  l_status_change_date
     );
     --
     -- Also, if the offer status has changed, call update_appl_assg_status
     -- to set the appropriate Assignment Status for the application.
     --
     hr_utility.set_location(l_proc,141);
     --
     irc_offers_api.update_appl_assg_status
     (   p_validate                        =>  p_validate
      ,  p_effective_date                  =>  l_effective_date
      ,  p_applicant_assignment_id         =>  l_prev_applicant_assignment_id
      ,  p_offer_status                    =>  l_offer_status
      ,  p_change_reason                   =>  p_change_reason
     );
     --
     -- Also, end date the offer assignment if the offer has just been closed.
     -- If the offer has already been closed, no need to end date the offer
     -- assignment again
     if l_offer_status = 'CLOSED' and l_prev_offer_status<>'CLOSED'
     then
       --
       hr_utility.set_location(l_proc,142);
       --
       if trunc(l_effective_end_date) = hr_api.g_eot then
         --
         hr_utility.set_location('Delete the offer assignment ',143);
       per_asg_del.del
       (
         p_assignment_id              => l_prev_offer_assignment_id
        ,p_effective_start_date       => l_effective_start_date
        ,p_effective_end_date         => l_effective_end_date
        ,p_business_group_id          => l_business_group_id
        ,p_object_version_number      => l_asg_object_version_number
        ,p_effective_date             => l_effective_date
        ,p_validation_start_date      => l_validation_start_date
        ,p_validation_end_date        => l_validation_end_date
        ,p_datetrack_mode             => hr_api.g_delete
        ,p_validate                   => p_validate
        ,p_org_now_no_manager_warning => l_org_now_no_manager_warning
      );
        hr_utility.set_location('After deleting the offer assignment ',144);
     --
      else
        --
        hr_utility.set_location(l_proc,145);
        hr_utility.set_location('Offer assignment is not active ',146);
        --
      end if;
     end if;
     --
     --
     --Check if the offer has been Approved or Returned For Correction or
     --Extended when it was on HOLD, if so, place the offer on HOLD again.
     --
     if (    l_prev_offer_status ='HOLD'
         and (   (l_offer_status = 'CORRECTION')
              or (l_offer_status = 'APPROVED')
              or (l_offer_status = 'EXTENDED')
             )
        )
     then
       hold_offer
       (P_VALIDATE                  =>  p_validate
       ,P_EFFECTIVE_DATE            =>  l_effective_date
       ,P_OFFER_ID                  =>  p_offer_id
       ,P_RESPONDENT_ID             =>  p_respondent_id
       ,P_OBJECT_VERSION_NUMBER     =>  l_object_version_number
       );
     end if;
     --
     end if;
     --
  elsif l_offer_status = l_prev_offer_status
  then
     --
     -- If the offer status has not changed, we need to call
     -- update_offer_status_history to update the note text.
     --
     open csr_offer_status_history_id;
     fetch csr_offer_status_history_id into l_offer_status_history_id;
     --
     if csr_offer_status_history_id%notfound
     then
        --
        close csr_offer_status_history_id;
        fnd_message.set_name('PER','IRC_412322_INVALID_OFFER_ID');
        fnd_message.raise_error;
        --
     end if;
     close csr_offer_status_history_id;
     --
     irc_offer_status_history_api.update_offer_status_history
     (   p_validate                        =>  p_validate
      ,  p_effective_date                  =>  l_effective_date
      ,  p_offer_status_history_id         =>  l_offer_status_history_id
      ,  p_offer_id                        =>  p_offer_id
      ,  p_offer_status                    =>  l_offer_status
      ,  p_change_reason                   =>  p_change_reason
      ,  p_decline_reason                  =>  p_decline_reason
      ,  p_note_text                       =>  p_note_text
      ,  p_object_version_number           =>  l_osh_object_version_number
      ,  p_status_change_date              =>  l_status_change_date
     );
     --
  end if;
  --
  -- Call After Process User Hook
  --
  begin
  IRC_OFFERS_BK2.update_offer_a
   (   P_EFFECTIVE_DATE               =>   l_effective_date
    ,  P_OFFER_ID                     =>   P_OFFER_ID
    ,  P_OFFER_VERSION                =>   l_offer_version
    ,  P_LATEST_OFFER                 =>   l_latest_offer
    ,  P_OFFER_STATUS                 =>   l_offer_status
    ,  P_DISCRETIONARY_JOB_TITLE      =>   P_DISCRETIONARY_JOB_TITLE
    ,  P_OFFER_EXTENDED_METHOD        =>   P_OFFER_EXTENDED_METHOD
    ,  P_RESPONDENT_ID                =>   P_RESPONDENT_ID
    ,  P_EXPIRY_DATE                  =>   l_expiry_date
    ,  P_PROPOSED_START_DATE          =>   l_proposed_start_date
    ,  P_OFFER_LETTER_TRACKING_CODE   =>   P_OFFER_LETTER_TRACKING_CODE
    ,  P_OFFER_POSTAL_SERVICE         =>   P_OFFER_POSTAL_SERVICE
    ,  P_OFFER_SHIPPING_DATE          =>   l_offer_shipping_date
    ,  P_APPLICANT_ASSIGNMENT_ID      =>   P_APPLICANT_ASSIGNMENT_ID
    ,  P_OFFER_ASSIGNMENT_ID          =>   P_OFFER_ASSIGNMENT_ID
    ,  P_ADDRESS_ID                   =>   P_ADDRESS_ID
    ,  P_TEMPLATE_ID                  =>   P_TEMPLATE_ID
    ,  P_OFFER_LETTER_FILE_TYPE       =>   P_OFFER_LETTER_FILE_TYPE
    ,  P_OFFER_LETTER_FILE_NAME       =>   P_OFFER_LETTER_FILE_NAME
    ,  P_ATTRIBUTE_CATEGORY           =>   P_ATTRIBUTE_CATEGORY
    ,  P_ATTRIBUTE1                   =>   P_ATTRIBUTE1
    ,  P_ATTRIBUTE2                   =>   P_ATTRIBUTE2
    ,  P_ATTRIBUTE3                   =>   P_ATTRIBUTE3
    ,  P_ATTRIBUTE4                   =>   P_ATTRIBUTE4
    ,  P_ATTRIBUTE5                   =>   P_ATTRIBUTE5
    ,  P_ATTRIBUTE6                   =>   P_ATTRIBUTE6
    ,  P_ATTRIBUTE7                   =>   P_ATTRIBUTE7
    ,  P_ATTRIBUTE8                   =>   P_ATTRIBUTE8
    ,  P_ATTRIBUTE9                   =>   P_ATTRIBUTE9
    ,  P_ATTRIBUTE10                  =>   P_ATTRIBUTE10
    ,  P_ATTRIBUTE11                  =>   P_ATTRIBUTE11
    ,  P_ATTRIBUTE12                  =>   P_ATTRIBUTE12
    ,  P_ATTRIBUTE13                  =>   P_ATTRIBUTE13
    ,  P_ATTRIBUTE14                  =>   P_ATTRIBUTE14
    ,  P_ATTRIBUTE15                  =>   P_ATTRIBUTE15
    ,  P_ATTRIBUTE16                  =>   P_ATTRIBUTE16
    ,  P_ATTRIBUTE17                  =>   P_ATTRIBUTE17
    ,  P_ATTRIBUTE18                  =>   P_ATTRIBUTE18
    ,  P_ATTRIBUTE19                  =>   P_ATTRIBUTE19
    ,  P_ATTRIBUTE20                  =>   P_ATTRIBUTE20
    ,  P_ATTRIBUTE21                  =>   P_ATTRIBUTE21
    ,  P_ATTRIBUTE22                  =>   P_ATTRIBUTE22
    ,  P_ATTRIBUTE23                  =>   P_ATTRIBUTE23
    ,  P_ATTRIBUTE24                  =>   P_ATTRIBUTE24
    ,  P_ATTRIBUTE25                  =>   P_ATTRIBUTE25
    ,  P_ATTRIBUTE26                  =>   P_ATTRIBUTE26
    ,  P_ATTRIBUTE27                  =>   P_ATTRIBUTE27
    ,  P_ATTRIBUTE28                  =>   P_ATTRIBUTE28
    ,  P_ATTRIBUTE29                  =>   P_ATTRIBUTE29
    ,  P_ATTRIBUTE30                  =>   P_ATTRIBUTE30
    ,  P_OBJECT_VERSION_NUMBER        =>   p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_offer'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
--
end if; -- l_create_new_version
  --
  -- Set all IN OUT and OUT parameters with out values
  -- If a new offer version has been created, the new offer_id
  -- will be returned, else the old one will be returned.
  --
  p_offer_id               := l_offer_id;
  p_object_version_number  := l_object_version_number;
  p_offer_version          := l_offer_version;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 145);
  --
exception
  when hr_api.validate_enabled then
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_offer_id               := l_offer_id;
    p_object_version_number  := l_object_version_number;
    p_offer_version          := l_offer_version;
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to UPDATE_OFFER;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 150);
  when others then
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_offer_id               := l_offer_id;
    p_object_version_number  := l_object_version_number;
    p_offer_version          := l_offer_version;
    --
    -- A validation or unexpected error has occured
    --
    rollback to UPDATE_OFFER;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 160);
    raise;
end update_offer;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< delete_offer >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_offer
(
  P_VALIDATE                    in boolean    default false
, P_OBJECT_VERSION_NUMBER       in number
, P_OFFER_ID                    in number
, P_EFFECTIVE_DATE              in date       default null
)
is
  --
  -- Declare cursors and local variables
  --
  l_proc                 varchar2(72) := g_package||'delete_offer';
  l_offer_id             irc_offers.offer_id%TYPE;
  l_prev_offer_status    irc_offers.offer_status%TYPE;
  l_effective_start_date           per_all_assignments_f.effective_start_date%TYPE;
  l_effective_end_date             per_all_assignments_f.effective_end_date%TYPE;
  l_effective_date       date;
  l_validation_start_date          date;
  l_validation_end_date            date;
  l_applicant_assignment_id        irc_offers.applicant_assignment_id%TYPE;
  l_offer_assignment_id            irc_offers.offer_assignment_id%TYPE;
  l_offer_status                   irc_offers.offer_status%TYPE;
  l_business_group_id              per_all_assignments_f.business_group_id%TYPE;
  l_asg_object_version_number      number(9);
  l_org_now_no_manager_warning     boolean;
  --
  cursor csr_prev_offer_rec is
         select offer_status
               ,applicant_assignment_id
               ,offer_assignment_id
           from irc_offers
          where offer_id = p_offer_id;
  --
  l_prev_offer_rec   csr_prev_offer_rec%ROWTYPE;
  --
  cursor csr_latest_offer is
         select offer_id
               ,offer_status
           from irc_offers
          where applicant_assignment_id = l_applicant_assignment_id
            and offer_version = ( select max(offer_version) from irc_offers
                                   where applicant_assignment_id = l_applicant_assignment_id );
  --
   cursor csr_assignment_ovn is
   select object_version_number
     from per_all_assignments_f
    where assignment_id = l_offer_assignment_id;
 --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_OFFER;
  --
  open  csr_prev_offer_rec;
  fetch csr_prev_offer_rec into l_prev_offer_rec;
  if csr_prev_offer_rec%notfound
  then
    --
    close csr_prev_offer_rec;
    fnd_message.set_name('PER','IRC_412322_INVALID_OFFER_ID');
    fnd_message.raise_error;
    --
  end if;
  --
  close csr_prev_offer_rec;
  --
  -- Check to see if the current offer status is 'Saved for Later'
  -- or 'Returned for Correction'. If NOT, throw an error
  -- saying that the offer cannot be deleted.
  --
  if (    l_prev_offer_rec.offer_status <> 'SAVED'
      AND l_prev_offer_rec.offer_status <> 'CORRECTION'
     ) then
     --
     fnd_message.set_name('PER','IRC_412303_OFFER_CANT_BE_DLTD');
     fnd_message.raise_error;
     --
  end if;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date      := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --
  begin
  IRC_OFFERS_BK3.delete_offer_b
  (
    P_OBJECT_VERSION_NUMBER
   ,P_OFFER_ID
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_offer'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  irc_iof_del.del
  (
    p_offer_id              => P_OFFER_ID
   ,p_object_version_number => P_OBJECT_VERSION_NUMBER
  );
  --
  -- Process Logic
  --
  --
  -- Also delete the irc_offer_status_history record.
  --
  irc_offer_status_history_api.delete_offer_status_history
  (
    p_validate       => p_validate
   ,p_offer_id       => p_offer_id
   ,p_effective_date => l_effective_date
  );
  --
  l_offer_assignment_id  := l_prev_offer_rec.offer_assignment_id ;
  --
  -- get offer assignment's object_version_number
  --
  open csr_assignment_ovn;
  fetch csr_assignment_ovn into l_asg_object_version_number;
  if csr_assignment_ovn%notfound
  then
     --
     close csr_assignment_ovn;
     fnd_message.set_name('PER','HR_289541_PJU_INV_ASG_ID');
     fnd_message.raise_error;
     --
  end if;
  close csr_assignment_ovn;
  --
  -- Purge the offer assignment record
  --
  per_asg_del.del
  (
    p_assignment_id              => l_offer_assignment_id
   ,p_effective_start_date       => l_effective_start_date
   ,p_effective_end_date         => l_effective_end_date
   ,p_business_group_id          => l_business_group_id
   ,p_object_version_number      => l_asg_object_version_number
   ,p_effective_date             => l_effective_date
   ,p_validation_start_date      => l_validation_start_date
   ,p_validation_end_date        => l_validation_end_date
   ,p_datetrack_mode             => hr_api.g_zap
   ,p_validate                   => p_validate
   ,p_org_now_no_manager_warning => l_org_now_no_manager_warning
 );
  --
  -- store the applicant_assignment_id
  --
  l_applicant_assignment_id := l_prev_offer_rec.applicant_assignment_id;
  --
  -- Check if there are any old offer records for this
  -- applicant_assignment_id. if yes, set the latest_offer
  -- for that record to 'Y'.
  --
  open csr_latest_offer;
  fetch csr_latest_offer into l_offer_id, l_offer_status;
  --
  hr_utility.set_location(l_proc,20);
  --
  if (csr_latest_offer%found)
  then
    close csr_latest_offer;
    --
    -- Update the offer record and set the latest_offer to 'Y'
    --
    if   l_offer_status <> 'SAVED'
     and l_offer_id < p_offer_id   --> Check that we are only modifying an earlier offer version
    then
       --
       -- If the offer_status of this offer record is SAVED,
       -- do not set the latest_offer flag to 'Y' because any SAVED
       -- offer cannot be the latest offer.
       -- NOTE: This scenario will not occur unless the offer creation is manupulated.
       -- Eg. First creating a SAVED offer as offer_version = 1 and again
       -- calling create_offer to create a PENDING offer as offer_version = 2.
       --
       update_latest_offer_flag
       ( p_offer_id             => l_offer_id
        ,p_effective_date       => l_effective_date
        ,p_validate             => p_validate
        ,p_latest_offer         => 'Y'
       );
       --
     end if;
  else
     close csr_latest_offer;
  end if;
  --
  -- Call After Process User Hook
  --
  begin
    IRC_OFFERS_BK3.delete_offer_a
     (
      P_OBJECT_VERSION_NUMBER
     ,P_OFFER_ID
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_offer'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 50);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to DELETE_OFFER;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 60);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to DELETE_OFFER;
    hr_utility.set_location(' Leaving:'||l_proc, 70);
    raise;
end delete_offer;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< get_offer_close_reason >--------------------|
-- ----------------------------------------------------------------------------
--
--
function get_offer_close_reason
  ( P_EFFECTIVE_DATE               IN   date
   ,P_APPLICANT_ASSIGNMENT_ID      IN   number
  ) RETURN VARCHAR2 Is
  l_proc                           varchar2(72) := g_package||'get_offer_close_reason';
  l_change_reason irc_offer_status_history.change_reason%TYPE;
  l_manager_terminates varchar2(1);
  l_user_id varchar2(250);
  --
  CURSOR csr_applicant_userid
    (p_assignment_id            IN     per_all_assignments_f.assignment_id%TYPE
    ,p_effective_date           IN     DATE
    )
  IS
  select user_id
  from per_all_assignments_f paf, fnd_user usr, per_all_people_f ppf,
  per_all_people_f linkppf
  where p_effective_date between paf.effective_start_date and
  paf.effective_end_date
  and p_effective_date between usr.start_date and
  nvl(usr.end_date,p_effective_date)
  and p_effective_date between ppf.effective_start_date and
  ppf.effective_end_date
  and p_effective_date between linkppf.effective_start_date and
  linkppf.effective_end_date
  and usr.employee_id=linkppf.person_id
  and ppf.party_id = linkppf.party_id
  and ppf.person_id = paf.person_id
  and paf.assignment_id= p_assignment_id
  and usr.user_id = fnd_global.user_id;
  --
begin
  --
  hr_utility.set_location(' Entering: '|| l_proc, 10);
  --
  OPEN csr_applicant_userid
       (p_assignment_id                => p_applicant_assignment_id
       ,p_effective_date               => p_effective_date
       );
  FETCH csr_applicant_userid INTO l_user_id;
  IF csr_applicant_userid%NOTFOUND
  THEN
    l_manager_terminates:='Y';
  END IF;
  CLOSE csr_applicant_userid;
  --
  hr_utility.set_location('l_user_id: '||l_user_id,20);
  hr_utility.set_location('g_user_id: '||fnd_global.user_id,30);
  --
  if l_user_id=fnd_global.user_id then
    l_manager_terminates:='N';
  else
    l_manager_terminates:='Y';
  end if;
  --
  if fnd_profile.value('IRC_AGENCY_NAME') is not null then
  --
    l_change_reason := 'AGENCY_TERMINATE_APPL';
  --
  elsif l_manager_terminates = 'Y' then
    l_change_reason := 'MGR_TERMINATE_APPL';
  else
    l_change_reason := 'WITHDRAWAL';
  end if;
  --
  hr_utility.set_location(' l_change_reason: '||l_change_reason,40);
  hr_utility.set_location(' Leaving: '|| l_proc, 50);
  --
  RETURN l_change_reason;
end get_offer_close_reason;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< close_offer >------------------------------|
-- ----------------------------------------------------------------------------
--
  procedure close_offer
  ( P_VALIDATE                     IN   boolean     default false
   ,P_EFFECTIVE_DATE               IN   date        default null
   ,P_APPLICANT_ASSIGNMENT_ID      IN   number      default null
   ,P_OFFER_ID                     IN   number      default null
   ,P_RESPONDENT_ID                IN   number      default null
   ,P_CHANGE_REASON                IN   VARCHAR2    default null
   ,P_DECLINE_REASON               IN   VARCHAR2    default null
   ,P_NOTE_TEXT                    IN   VARCHAR2    default null
   ,P_STATUS_CHANGE_DATE           IN   date        default null
  ) Is
--
  l_proc                           varchar2(72) := g_package||'close_offer';
  l_offer_assignment_id            irc_offers.offer_assignment_id%TYPE := null;
  l_offer_id                       irc_offers.offer_id%TYPE := null;
  l_prev_offer_status              irc_offers.offer_status%TYPE;
  l_offer_version                  irc_offers.offer_version%TYPE;
  l_offer_assignment_exists        boolean      := true;
  l_iof_object_version_number      irc_offers.object_version_number%TYPE;
  l_change_reason                  irc_offer_status_history.change_reason%TYPE;
--  Date variables
  l_effective_date                 date;
  l_status_change_date             irc_offer_status_history.status_change_date%TYPE;
--  Cursors
  cursor csr_offer_assignment_1 is
  select offer_assignment_id
        ,offer_id
        ,offer_status
    from irc_offers
   where applicant_assignment_id = p_applicant_assignment_id
     and latest_offer = 'Y';
--
  cursor csr_saved_offers is
  select offer_id
        ,object_version_number
    from irc_offers
   where applicant_assignment_id = p_applicant_assignment_id
     and offer_status = 'SAVED';
--
  cursor csr_offer_assignment_2 is
  select offer_assignment_id
        ,offer_status
    from irc_offers
   where offer_id = p_offer_id;
--
  cursor csr_iof_object_version_number is
   select object_version_number
    from irc_offers
   where offer_id = l_offer_id;
--
  Begin
  --
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  -- issue a savepoint
  --
  savepoint CLOSE_OFFER;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date      := trunc(p_effective_date);
  --
  -- If p_offer_id is not null, we can use 'csr_offer_assignment_2'
  -- This scenario would occur when the applicant declines the offer.
  --
  if (p_offer_id is not null)
  then
     --
     hr_utility.set_location(l_proc,20);
     --
     open csr_offer_assignment_2;
     fetch csr_offer_assignment_2 into l_offer_assignment_id
                                      ,l_prev_offer_status;
     if csr_offer_assignment_2%notfound
     then
        --
        close csr_offer_assignment_2;
        fnd_message.set_name('PER','IRC_412322_INVALID_OFFER_ID');
        fnd_message.raise_error;
        --
     end if;
     close csr_offer_assignment_2;
     -- Store the offer_id
     l_offer_id                := p_offer_id;
     l_offer_assignment_exists := true;
  else
  --
  -- If p_offer_id is null we need to use 'csr_offer_assignment_1'.
  -- This scenario would occur when the applicant withdraws from the
  -- Application, in which case we would not know if there is an offer
  -- for this applicant in the first place, and if there is, what the
  -- offer_id for that record is.
  --
     l_offer_assignment_exists := false;
     --
     hr_utility.set_location(l_proc,30);
     --
     open csr_offer_assignment_1;
     fetch csr_offer_assignment_1 into l_offer_assignment_id
                                      ,l_offer_id
                                      ,l_prev_offer_status;
     --
     --
     -- Check if there is an offer record for this applicant.
     -- If yes, set l_offer_assignment_exists so that we can
     -- close the offer.
     --
     if csr_offer_assignment_1%found
     then
        --
        hr_utility.set_location(l_proc,40);
        --
        close csr_offer_assignment_1;
        --
        -- Set the variable l_offer_assignment_exists to true;
        --
        l_offer_assignment_exists := true;
        --
     else
        close csr_offer_assignment_1;
     end if;
     --
     hr_utility.set_location(l_proc,50);
     --
  end if;
  --
  hr_utility.set_location(l_proc,60);
  --
  -- Check if the offer assginment exists. Only if it exists call the
  -- update_offer the close the offer and end date the offer assignment.
  --
  if l_offer_assignment_exists = true
  then
    --
    hr_utility.set_location(l_proc,65);
    --
    -- Fetch Offer OVN
    --
    open  csr_iof_object_version_number;
    fetch csr_iof_object_version_number into l_iof_object_version_number;
    --
    if csr_iof_object_version_number%notfound
    then
      --
      close csr_iof_object_version_number;
      fnd_message.set_name('PER','IRC_412322_INVALID_OFFER_ID');
      fnd_message.raise_error;
      --
    end if;
    --
    close csr_iof_object_version_number;
    --
    if p_change_reason='WITHDRAWAL' or p_change_reason='MGR_TERMINATE_APPL' then
      l_change_reason := get_offer_close_reason(p_effective_date,p_applicant_assignment_id);
    else
      l_change_reason := p_change_reason;
    end if;
    --
    -- Update the offer record in IRC_OFFERS and set the offer_status to
    -- Closed and end date the offer assignment.
    -- Do this only if the offer is previously not in CLOSED status.
    -- Also do this if the change reason is MGR_WITHDRAW, APL_DECLINED_ACCEPTANCE, APL_HIRED
    if l_prev_offer_status <> 'CLOSED' or p_change_reason='MGR_WITHDRAW' or p_change_reason='APL_DECLINED_ACCEPTANCE' or p_change_reason='APL_HIRED'
    then
      update_offer
      (p_validate                     => p_validate
      ,p_effective_date               => l_effective_date
      ,p_offer_id                     => l_offer_id
      ,p_offer_version                => l_offer_version
      ,p_offer_status                 => 'CLOSED'
      ,p_respondent_id                => p_respondent_id
      ,p_change_reason                => l_change_reason
      ,p_decline_reason               => p_decline_reason
      ,p_note_text                    => p_note_text
      ,p_status_change_date           => p_status_change_date
      ,p_object_version_number        => l_iof_object_version_number
      );
      --
      if p_change_reason='MGR_WITHDRAW' or p_change_reason='WITHDRAWAL' or p_change_reason='APL_HIRED' or p_change_reason='EXPIRED' or p_change_reason='MGR_TERMINATE_APPL' then
        close_notifications(P_APPLICANT_ASSIGNMENT_ID,l_OFFER_ID);
      end if;
      --
    end if;
    --
    hr_utility.set_location(l_proc,70);
    --
  end if;
  --
  -- check if there are any SAVED offers for this applicant assignment ID.
  -- If so, close all of them if the change_reason is WITHDRAWAL.
  --
  if  l_offer_assignment_exists = true
  and p_change_reason in ('WITHDRAWAL','MGR_TERMINATE_APPL')
  then
  --
    for c_rec in csr_saved_offers loop
    --
    -- Close all these offers.
    --
    update_offer
    (p_validate                     => p_validate
    ,p_effective_date               => l_effective_date
    ,p_offer_id                     => c_rec.offer_id
    ,p_offer_version                => l_offer_version
    ,p_offer_status                 => 'CLOSED'
    ,p_respondent_id                => p_respondent_id
    ,p_change_reason                => l_change_reason
    ,p_decline_reason               => p_decline_reason
    ,p_note_text                    => p_note_text
    ,p_status_change_date           => p_status_change_date
    ,p_object_version_number        => c_rec.object_version_number
    );
    --
    close_notifications(P_APPLICANT_ASSIGNMENT_ID,c_rec.offer_id);
    --
    end loop;
  --
  end if;

  --
  hr_utility.set_location(l_proc,90);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 100);
  exception
    when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CLOSE_OFFER;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 110);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CLOSE_OFFER;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 120);
    raise;
end close_offer;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------------< hold_offer >------------------------------|
-- ----------------------------------------------------------------------------
--
   procedure hold_offer
   ( P_VALIDATE                     IN   boolean     default false
    ,P_EFFECTIVE_DATE               IN   date        default null
    ,P_OFFER_ID                     IN   NUMBER
    ,P_RESPONDENT_ID                IN   NUMBER      default hr_api.g_number
    ,P_CHANGE_REASON                IN   VARCHAR2    default null
    ,P_STATUS_CHANGE_DATE           IN   date        default null
    ,P_NOTE_TEXT                    IN   VARCHAR2    default null
    ,P_OBJECT_VERSION_NUMBER        IN OUT  nocopy   NUMBER
   ) is
--
   l_proc                        varchar2(72) := g_package||'hold_offer';
   l_offer_id                    irc_offers.offer_id%TYPE := p_offer_id;
   l_offer_version               irc_offers.offer_version%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  -- Call update_offer with offer_status = 'HOLD'
  --
  update_offer
  (  p_validate                     => p_validate
    ,p_effective_date               => p_effective_date
    ,p_offer_id                     => l_offer_id
    ,p_offer_version                => l_offer_version
    ,p_object_version_number        => p_object_version_number
    ,p_offer_status                 => 'HOLD'
    ,p_respondent_id                => p_respondent_id
    ,p_change_reason                => p_change_reason
    ,p_note_text                    => p_note_text
    ,p_status_change_date           => p_status_change_date
  );
  --
  exception
  when others then
  hr_utility.set_location(' Leaving:'||l_proc, 30);
  raise;
end hold_offer;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< release_offer >----------------------------|
-- ----------------------------------------------------------------------------
--
   procedure release_offer
   ( P_VALIDATE                     IN   boolean     default false
    ,P_EFFECTIVE_DATE               IN   date        default null
    ,P_OFFER_ID                     IN   NUMBER
    ,P_RESPONDENT_ID                IN   NUMBER      default hr_api.g_number
    ,P_CHANGE_REASON                IN   VARCHAR2    default null
    ,P_STATUS_CHANGE_DATE           IN   date        default null
    ,P_NOTE_TEXT                    IN   VARCHAR2    default null
    ,P_OBJECT_VERSION_NUMBER        IN OUT  nocopy   NUMBER
   ) is
--
   l_proc                         varchar2(72) := g_package||'release_offer';
   l_prev_offer_status            irc_offers.offer_status%TYPE;
   l_prev_to_prev_offer_status    irc_offers.offer_status%TYPE;
   l_prev_applicant_assignment_id irc_offers.applicant_assignment_id%TYPE;
   l_prev_to_prev_change_reason   irc_offer_status_history.change_reason%TYPE;
   l_prev_to_prev_decline_reason  irc_offer_status_history.decline_reason%TYPE;
   l_offer_id                     irc_offers.offer_id%TYPE := p_offer_id;
   l_offer_version                irc_offers.offer_version%TYPE;
   l_offer_status_history_id      irc_offer_status_history.offer_status_history_id%TYPE;
   l_osh_object_version_number    irc_offer_status_history.object_version_number%TYPE;
   l_other_extended_offer_count   number := 0;
   l_prev_expiry_date             irc_offers.expiry_date%TYPE;
--
  cursor csr_prev_to_prev_offer_status is
  SELECT ios1.offer_status,
    ios1.change_reason,
    ios1.decline_reason
  FROM irc_offer_status_history ios1
     WHERE EXISTS ( SELECT 1
                        FROM irc_offer_status_history iosh1
                        WHERE iosh1.offer_id = p_offer_id
                        AND iosh1.status_change_date > ios1.status_change_date
                      )
      AND ios1.offer_status_history_id = (SELECT MAX(iosh2.offer_status_history_id)
                                            FROM irc_offer_status_history iosh2
                                           WHERE iosh2.offer_id = p_offer_id
                                             AND iosh2.status_change_date = ios1.status_change_date
                                          )
   AND 1 =
    (SELECT COUNT(*)
     FROM irc_offer_status_history ios3
     WHERE ios3.offer_id = p_offer_id
        AND ios3.status_change_date > ios1.status_change_date
       );
  --
  cursor csr_prev_offer_status is
         select offer_status
               ,applicant_assignment_id
               ,expiry_date
           from irc_offers
          where offer_id = p_offer_id;
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  -- Check if the offer is currently in HOLD
  --
  open  csr_prev_offer_status;
  fetch csr_prev_offer_status into l_prev_offer_status
                                  ,l_prev_applicant_assignment_id
                                  ,l_prev_expiry_date;
  --
  if csr_prev_offer_status%notfound
  then
    --
    close csr_prev_offer_status;
    fnd_message.set_name('PER','IRC_412322_INVALID_OFFER_ID');
    fnd_message.raise_error;
    --
  end if;
  close csr_prev_offer_status;
  --
  if l_prev_offer_status <> 'HOLD'
  then
    --
    fnd_message.set_name('PER','IRC_412304_OFFER_NOT_HELD');
    fnd_message.raise_error;
    --
  end if;
  --
  open csr_prev_to_prev_offer_status;
  fetch csr_prev_to_prev_offer_status into l_prev_to_prev_offer_status
                                          ,l_prev_to_prev_change_reason
                                          ,l_prev_to_prev_decline_reason;
  --
  if csr_prev_to_prev_offer_status%notfound
  then
    --
    close csr_prev_to_prev_offer_status;
    fnd_message.set_name('PER','IRC_412305_INV_PREVTOPREV_OFR');
    fnd_message.raise_error;
    --
  end if;
  close csr_prev_to_prev_offer_status;

  if l_prev_to_prev_offer_status = 'EXTENDED' and
     l_prev_expiry_date is not null and
     l_prev_expiry_date < p_effective_date
  then
    --
    close_offer
     ( p_validate                  =>  p_validate
      ,p_effective_date            =>  p_effective_date
      ,p_applicant_assignment_id   =>  l_prev_applicant_assignment_id
      ,p_offer_id                  =>  p_offer_id
      ,p_respondent_id             =>  p_respondent_id
      ,p_change_reason             =>  'EXPIRED'
      ,p_note_text                 =>  p_note_text
      ,p_status_change_date        =>  p_status_change_date
     );
  else
    --
    -- Checks to not Extend the offer if already an offer has been Extended
    --
    if     l_prev_to_prev_offer_status = 'EXTENDED'   -- Extended Offer which was on Hold
       OR ( l_prev_to_prev_offer_status = 'CLOSED'     -- Closed and Accepted offer which was on Hold
            AND l_prev_to_prev_change_reason = 'APL_ACCEPTED'
          )
    then
      --
      if 'N' = fnd_profile.value('IRC_ALLOW_MULTI_OFFERS')
         OR 'E' = fnd_profile.value('IRC_ALLOW_MULTI_OFFERS')
         OR fnd_profile.value('IRC_ALLOW_MULTI_OFFERS') is null
      then
        --
        -- This happens when an offer which was previously EXTENDED or was CLOSED and ACCEPTED
        -- is being taken off Hold.
        -- Refuse to take it off Hold if another EXTENDED Offer or CLOSED and ACCEPTED Offer Exists
        --
        other_extended_offers_count
        ( p_applicant_assignment_id     => l_prev_applicant_assignment_id
         ,p_effective_date              => p_effective_date
         ,p_other_extended_offer_count  => l_other_extended_offer_count
        );
        --
        if l_other_extended_offer_count > 0
        then
          --
          fnd_message.set_name('PER','IRC_412377_MULTIPLE_OFFER_SEND'); -- You cannot send another offer to this applicant as
                                                                        -- an active offer exists for this application
          fnd_message.raise_error;
          --
        end if;
      --
      end if;
    --
    end if;
    --
    -- Update the offer with offer_status as the offer status
    -- before the offer was held.
    --
    irc_iof_upd.upd
     ( p_effective_date               =>  p_effective_date
      ,p_offer_id                     =>  l_offer_id
      ,p_object_version_number        =>  p_object_version_number
      ,p_offer_version                =>  l_offer_version
      ,p_offer_status                 =>  l_prev_to_prev_offer_status
      ,p_respondent_id                =>  p_respondent_id
     );
    --
    -- Create the offer status history record with the details
    --
    irc_offer_status_history_api.create_offer_status_history
    (   p_validate                        =>  p_validate
     ,  p_effective_date                  =>  p_effective_date
     ,  p_offer_id                        =>  l_offer_id
     ,  p_offer_status                    =>  l_prev_to_prev_offer_status
     ,  p_change_reason                   =>  l_prev_to_prev_change_reason
     ,  p_decline_reason                  =>  l_prev_to_prev_decline_reason
     ,  p_note_text                       =>  p_note_text
     ,  p_offer_status_history_id         =>  l_offer_status_history_id
     ,  p_object_version_number           =>  l_osh_object_version_number
    );
  --
  end if;
  --
  exception
  when others then
  hr_utility.set_location(' Leaving:'||l_proc, 30);
  raise;
end release_offer;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_offer_assignment >------------------------|
-- ----------------------------------------------------------------------------
--
  Procedure create_offer_assignment
  (
    p_assignment_id                OUT NOCOPY NUMBER
   ,p_effective_start_date         OUT NOCOPY DATE
   ,p_effective_end_date           OUT NOCOPY DATE
   ,p_business_group_id            IN NUMBER
   ,p_recruiter_id                 IN NUMBER           default null
   ,p_grade_id                     IN NUMBER           default null
   ,p_position_id                  IN NUMBER           default null
   ,p_job_id                       IN NUMBER           default null
   ,p_assignment_status_type_id    IN NUMBER
   ,p_payroll_id                   IN NUMBER           default null
   ,p_location_id                  IN NUMBER           default null
   ,p_person_referred_by_id        IN NUMBER           default null
   ,p_supervisor_id                IN NUMBER           default null
   ,p_special_ceiling_step_id      IN NUMBER           default null
   ,p_person_id                    IN NUMBER
   ,p_recruitment_activity_id      IN NUMBER           default null
   ,p_source_organization_id       IN NUMBER           default null
   ,p_organization_id              IN NUMBER
   ,p_people_group_id              IN NUMBER           default null
   ,p_soft_coding_keyflex_id       IN NUMBER           default null
   ,p_vacancy_id                   IN NUMBER           default null
   ,p_pay_basis_id                 IN NUMBER           default null
   ,p_assignment_sequence          OUT NOCOPY NUMBER
   ,p_assignment_type              IN VARCHAR2
   ,p_primary_flag                 IN VARCHAR2
   ,p_application_id               IN NUMBER           default null
   ,p_assignment_number            IN OUT NOCOPY VARCHAr2
   ,p_change_reason                IN VARCHAR2         default null
   ,p_comment_id                   OUT NOCOPY NUMBER
   ,p_comments                     IN VARCHAR2         default null
   ,p_date_probation_end           IN DATE             default null
   ,p_default_code_comb_id         IN NUMBER           default null
   ,p_employment_category          IN VARCHAR2         default null
   ,p_frequency                    IN VARCHAR2         default null
   ,p_internal_address_line        IN VARCHAR2         default null
   ,p_manager_flag                 IN VARCHAR2         default null
   ,p_normal_hours                 IN NUMBER           default null
   ,p_perf_review_period           IN NUMBER           default null
   ,p_perf_review_period_frequency IN VARCHAR2         default null
   ,p_period_of_service_id         IN NUMBER           default null
   ,p_probation_period             IN NUMBER           default null
   ,p_probation_unit               IN VARCHAR2         default null
   ,p_sal_review_period            IN NUMBER           default null
   ,p_sal_review_period_frequency  IN VARCHAR2         default null
   ,p_set_of_books_id              IN NUMBER           default null
   ,p_source_type                  IN VARCHAR2         default null
   ,p_time_normal_finish           IN VARCHAR2         default null
   ,p_time_normal_start            IN VARCHAR2         default null
   ,p_bargaining_unit_code         IN VARCHAR2         default null
   ,p_labour_union_member_flag     IN VARCHAR2         default 'N'
   ,p_hourly_salaried_code         IN VARCHAR2         default null
   ,p_request_id                   IN NUMBER           default null
   ,p_program_application_id       IN NUMBER           default null
   ,p_program_id                   IN NUMBER           default null
   ,p_program_update_date          IN DATE             default null
   ,p_ass_attribute_category       IN VARCHAR2         default null
   ,p_ass_attribute1               IN VARCHAR2         default null
   ,p_ass_attribute2               IN VARCHAR2         default null
   ,p_ass_attribute3               IN VARCHAR2         default null
   ,p_ass_attribute4               IN VARCHAR2         default null
   ,p_ass_attribute5               IN VARCHAR2         default null
   ,p_ass_attribute6               IN VARCHAR2         default null
   ,p_ass_attribute7               IN VARCHAR2         default null
   ,p_ass_attribute8               IN VARCHAR2         default null
   ,p_ass_attribute9               IN VARCHAR2         default null
   ,p_ass_attribute10              IN VARCHAR2         default null
   ,p_ass_attribute11              IN VARCHAR2         default null
   ,p_ass_attribute12              IN VARCHAR2         default null
   ,p_ass_attribute13              IN VARCHAR2         default null
   ,p_ass_attribute14              IN VARCHAR2         default null
   ,p_ass_attribute15              IN VARCHAR2         default null
   ,p_ass_attribute16              IN VARCHAR2         default null
   ,p_ass_attribute17              IN VARCHAR2         default null
   ,p_ass_attribute18              IN VARCHAR2         default null
   ,p_ass_attribute19              IN VARCHAR2         default null
   ,p_ass_attribute20              IN VARCHAR2         default null
   ,p_ass_attribute21              IN VARCHAR2         default null
   ,p_ass_attribute22              IN VARCHAR2         default null
   ,p_ass_attribute23              IN VARCHAR2         default null
   ,p_ass_attribute24              IN VARCHAR2         default null
   ,p_ass_attribute25              IN VARCHAR2         default null
   ,p_ass_attribute26              IN VARCHAR2         default null
   ,p_ass_attribute27              IN VARCHAR2         default null
   ,p_ass_attribute28              IN VARCHAR2         default null
   ,p_ass_attribute29              IN VARCHAR2         default null
   ,p_ass_attribute30              IN VARCHAR2         default null
   ,p_title                        IN VARCHAR2         default null
   ,p_validate_df_flex             IN BOOLEAN          default true
   ,p_object_version_number        OUT NOCOPY NUMBER
   ,p_other_manager_warning        OUT NOCOPY BOOLEAN
   ,p_hourly_salaried_warning      OUT NOCOPY BOOLEAN
   ,p_effective_date               IN DATE
   ,p_validate                     IN BOOLEAN          default false
   ,p_contract_id                  IN NUMBER           default null
   ,p_establishment_id             IN NUMBER           default null
   ,p_collective_agreement_id      IN NUMBER           default null
   ,p_cagr_grade_def_id            IN NUMBER           default null
   ,p_cagr_id_flex_num             IN NUMBER           default null
   ,p_notice_period                IN NUMBER           default null
   ,p_notice_period_uom            IN VARCHAR2         default null
   ,p_employee_category            IN VARCHAR2         default null
   ,p_work_at_home                 IN VARCHAR2         default null
   ,p_job_post_source_name         IN VARCHAR2         default null
   ,p_posting_content_id           IN NUMBER           default null
   ,p_placement_date_start         IN DATE             default null
   ,p_vendor_id                    IN NUMBER           default null
   ,p_vendor_employee_number       IN VARCHAR2         default null
   ,p_vendor_assignment_number     IN VARCHAR2         default null
   ,p_assignment_category          IN VARCHAR2         default null
   ,p_project_title                IN VARCHAR2         default null
   ,p_applicant_rank               IN NUMBER           default null
   ,p_grade_ladder_pgm_id          IN NUMBER           default null
   ,p_supervisor_assignment_id     IN NUMBER           default null
   ,p_vendor_site_id               IN NUMBER           default null
   ,p_po_header_id                 IN NUMBER           default null
   ,p_po_line_id                   IN NUMBER           default null
   ,p_projected_assignment_end     IN DATE             default null
  )Is
--
  l_proc                           varchar2(72) := g_package||'create_offer_assignment';
--
--  Out and In Out variables
--
  l_offer_assignment_id            per_all_assignments_f.assignment_id%TYPE;
  l_effective_start_date           per_all_assignments_f.effective_start_date%TYPE;
  l_effective_end_date             per_all_assignments_f.effective_end_date%TYPE;
  l_assignment_sequence            per_all_assignments_f.assignment_sequence%TYPE;
  l_assignment_number              per_all_assignments_f.assignment_number%TYPE  := p_assignment_number;
  l_comment_id                     per_all_assignments_f.comment_id%TYPE;
  l_object_version_number          per_all_assignments_f.object_version_number%TYPE;
  l_other_manager_warning          boolean;
  l_hourly_salaried_warning        boolean;
--
--  variables to be set
--
  l_assignment_type                per_all_assignments_f.assignment_type%TYPE;
  l_primary_flag                   per_all_assignments_f.primary_flag%TYPE;
--
--  Date Variables
--
  l_date_probation_end             per_all_assignments_f.date_probation_end%TYPE;
  l_program_update_date            per_all_assignments_f.program_update_date%TYPE;
  l_placement_date_start           date;
  l_projected_assignment_end       date;
  l_effective_date                 date;
Begin

  hr_utility.set_location('Entering:'||l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_OFFER_ASSIGNMENT;
  --
  hr_utility.set_location(l_proc,20);
  --
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_date_probation_end       := trunc(p_date_probation_end);
  l_program_update_date      := trunc(p_program_update_date);
  l_effective_date           := trunc(p_effective_date);
  l_placement_date_start     := trunc(p_placement_date_start);
  l_projected_assignment_end := trunc(p_projected_assignment_end);
  --
  -- The offer record must have an assignment_type = 'O'
  -- and the primary_flag must be set to 'N'
  --
  l_assignment_type    := 'O';
  l_primary_flag       := 'N';
  --
  hr_utility.set_location(l_proc,40);
  --
  -- Create Offer Assignment record
  --
  per_asg_ins.ins
  (  p_assignment_id                => l_offer_assignment_id
    ,p_effective_start_date         => l_effective_start_date
    ,p_effective_end_date           => l_effective_end_date
    ,p_business_group_id            => p_business_group_id
    ,p_recruiter_id                 => p_recruiter_id
    ,p_grade_id                     => p_grade_id
    ,p_position_id                  => p_position_id
    ,p_job_id                       => p_job_id
    ,p_assignment_status_type_id    => p_assignment_status_type_id
    ,p_payroll_id                   => p_payroll_id
    ,p_location_id                  => p_location_id
    ,p_person_referred_by_id        => p_person_referred_by_id
    ,p_supervisor_id                => p_supervisor_id
    ,p_special_ceiling_step_id      => p_special_ceiling_step_id
    ,p_person_id                    => p_person_id
    ,p_recruitment_activity_id      => p_recruitment_activity_id
    ,p_source_organization_id       => p_source_organization_id
    ,p_organization_id              => p_organization_id
    ,p_people_group_id              => p_people_group_id
    ,p_soft_coding_keyflex_id       => p_soft_coding_keyflex_id
    ,p_vacancy_id                   => p_vacancy_id
    ,p_pay_basis_id                 => p_pay_basis_id
    ,p_assignment_sequence          => l_assignment_sequence
    ,p_assignment_type              => l_assignment_type
    ,p_primary_flag                 => l_primary_flag
    ,p_application_id               => p_application_id
    ,p_assignment_number            => l_assignment_number
    ,p_change_reason                => p_change_reason
    ,p_comment_id                   => l_comment_id
    ,p_comments                     => p_comments
    ,p_date_probation_end           => l_date_probation_end
    ,p_default_code_comb_id         => p_default_code_comb_id
    ,p_employment_category          => p_employment_category
    ,p_frequency                    => p_frequency
    ,p_internal_address_line        => p_internal_address_line
    ,p_manager_flag                 => p_manager_flag
    ,p_normal_hours                 => p_normal_hours
    ,p_perf_review_period           => p_perf_review_period
    ,p_perf_review_period_frequency => p_perf_review_period_frequency
    ,p_period_of_service_id         => p_period_of_service_id
    ,p_probation_period             => p_probation_period
    ,p_probation_unit               => p_probation_unit
    ,p_sal_review_period            => p_sal_review_period
    ,p_sal_review_period_frequency  => p_sal_review_period_frequency
    ,p_set_of_books_id              => p_set_of_books_id
    ,p_source_type                  => p_source_type
    ,p_time_normal_finish           => p_time_normal_finish
    ,p_time_normal_start            => p_time_normal_start
    ,p_bargaining_unit_code         => p_bargaining_unit_code
    ,p_labour_union_member_flag     => p_labour_union_member_flag
    ,p_hourly_salaried_code         => p_hourly_salaried_code
    ,p_request_id                   => p_request_id
    ,p_program_application_id       => p_program_application_id
    ,p_program_id                   => p_program_id
    ,p_program_update_date          => l_program_update_date
    ,p_ass_attribute_category       => p_ass_attribute_category
    ,p_ass_attribute1               => p_ass_attribute1
    ,p_ass_attribute2               => p_ass_attribute2
    ,p_ass_attribute3               => p_ass_attribute3
    ,p_ass_attribute4               => p_ass_attribute4
    ,p_ass_attribute5               => p_ass_attribute5
    ,p_ass_attribute6               => p_ass_attribute6
    ,p_ass_attribute7               => p_ass_attribute7
    ,p_ass_attribute8               => p_ass_attribute8
    ,p_ass_attribute9               => p_ass_attribute9
    ,p_ass_attribute10              => p_ass_attribute10
    ,p_ass_attribute11              => p_ass_attribute11
    ,p_ass_attribute12              => p_ass_attribute12
    ,p_ass_attribute13              => p_ass_attribute13
    ,p_ass_attribute14              => p_ass_attribute14
    ,p_ass_attribute15              => p_ass_attribute15
    ,p_ass_attribute16              => p_ass_attribute16
    ,p_ass_attribute17              => p_ass_attribute17
    ,p_ass_attribute18              => p_ass_attribute18
    ,p_ass_attribute19              => p_ass_attribute19
    ,p_ass_attribute20              => p_ass_attribute20
    ,p_ass_attribute21              => p_ass_attribute21
    ,p_ass_attribute22              => p_ass_attribute22
    ,p_ass_attribute23              => p_ass_attribute23
    ,p_ass_attribute24              => p_ass_attribute24
    ,p_ass_attribute25              => p_ass_attribute25
    ,p_ass_attribute26              => p_ass_attribute26
    ,p_ass_attribute27              => p_ass_attribute27
    ,p_ass_attribute28              => p_ass_attribute28
    ,p_ass_attribute29              => p_ass_attribute29
    ,p_ass_attribute30              => p_ass_attribute30
    ,p_title                        => p_title
    ,p_validate_df_flex             => p_validate_df_flex
    ,p_object_version_number        => l_object_version_number
    ,p_other_manager_warning        => l_other_manager_warning
    ,p_hourly_salaried_warning      => l_hourly_salaried_warning
    ,p_effective_date               => l_effective_date
    ,p_validate                     => p_validate
    ,p_contract_id                  => p_contract_id
    ,p_establishment_id             => p_establishment_id
    ,p_collective_agreement_id      => p_collective_agreement_id
    ,p_cagr_grade_def_id            => p_cagr_grade_def_id
    ,p_cagr_id_flex_num             => p_cagr_id_flex_num
    ,p_notice_period                => p_notice_period
    ,p_notice_period_uom            => p_notice_period_uom
    ,p_employee_category            => p_employee_category
    ,p_work_at_home                 => p_work_at_home
    ,p_job_post_source_name         => p_job_post_source_name
    ,p_posting_content_id           => p_posting_content_id
    ,p_placement_date_start         => l_placement_date_start
    ,p_vendor_id                    => p_vendor_id
    ,p_vendor_employee_number       => p_vendor_employee_number
    ,p_vendor_assignment_number     => p_vendor_assignment_number
    ,p_assignment_category          => p_assignment_category
    ,p_project_title                => p_project_title
    ,p_applicant_rank               => p_applicant_rank
    ,p_grade_ladder_pgm_id          => p_grade_ladder_pgm_id
    ,p_supervisor_assignment_id     => p_supervisor_assignment_id
    ,p_vendor_site_id               => p_vendor_site_id
    ,p_po_header_id                 => p_po_header_id
    ,p_po_line_id                   => p_po_line_id
    ,p_projected_assignment_end     => p_projected_assignment_end
    );
  --
  hr_utility.set_location(l_proc, 50);
  --
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Assign all the OUT and IN OUT Variables
  --
  p_assignment_id            := l_offer_assignment_id;
  p_effective_start_date     := l_effective_start_date;
  p_effective_end_date       := l_effective_end_date;
  p_assignment_sequence      := l_assignment_sequence;
  p_assignment_number        := l_assignment_number;
  p_comment_id               := l_comment_id;
  p_object_version_number    := l_object_version_number;
  p_other_manager_warning    := l_other_manager_warning;
  p_hourly_salaried_warning  := l_hourly_salaried_warning;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 60);
  --
exception
  when hr_api.validate_enabled then
    --
    p_assignment_id            := null;
    p_effective_start_date     := null;
    p_effective_end_date       := null;
    p_assignment_sequence      := null;
    p_assignment_number        := l_assignment_number;
    p_comment_id               := null;
    p_object_version_number    := null;
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_OFFER_ASSIGNMENT;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 70);
  when others then
    --
    p_assignment_id            := null;
    p_effective_start_date     := null;
    p_effective_end_date       := null;
    p_assignment_sequence      := null;
    p_assignment_number        := l_assignment_number;
    p_comment_id               := null;
    p_object_version_number    := null;
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_OFFER_ASSIGNMENT;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    raise;
end create_offer_assignment;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_offer_assignment >------------------------|
-- ----------------------------------------------------------------------------
--
  procedure update_offer_assignment
  ( P_ASSIGNMENT_ID                     IN OUT NOCOPY  NUMBER
   ,P_EFFECTIVE_START_DATE              OUT NOCOPY DATE
   ,P_EFFECTIVE_END_DATE                OUT NOCOPY DATE
   ,P_BUSINESS_GROUP_ID                 OUT NOCOPY NUMBER

   ,P_RECRUITER_ID                      IN NUMBER                default hr_api.g_number
   ,P_GRADE_ID                          IN NUMBER                default hr_api.g_number
   ,P_POSITION_ID                       IN NUMBER                default hr_api.g_number
   ,P_JOB_ID                            IN NUMBER                default hr_api.g_number
   ,P_ASSIGNMENT_STATUS_TYPE_ID         IN NUMBER                default hr_api.g_number
   ,P_PAYROLL_ID                        IN NUMBER                default hr_api.g_number
   ,P_LOCATION_ID                       IN NUMBER                default hr_api.g_number
   ,P_PERSON_REFERRED_BY_ID             IN NUMBER                default hr_api.g_number
   ,P_SUPERVISOR_ID                     IN NUMBER                default hr_api.g_number
   ,P_SPECIAL_CEILING_STEP_ID           IN NUMBER                default hr_api.g_number
   ,P_RECRUITMENT_ACTIVITY_ID           IN NUMBER                default hr_api.g_number
   ,P_SOURCE_ORGANIZATION_ID            IN NUMBER                default hr_api.g_number

   ,P_ORGANIZATION_ID                   IN NUMBER                default hr_api.g_number
   ,P_PEOPLE_GROUP_ID                   IN NUMBER                default hr_api.g_number
   ,P_SOFT_CODING_KEYFLEX_ID            IN NUMBER                default hr_api.g_number
   ,P_VACANCY_ID                        IN NUMBER                default hr_api.g_number
   ,P_PAY_BASIS_ID                      IN NUMBER                default hr_api.g_number
   ,P_ASSIGNMENT_TYPE                   IN VARCHAR2              default hr_api.g_varchar2
   ,P_PRIMARY_FLAG                      IN VARCHAR2              default hr_api.g_varchar2
   ,P_APPLICATION_ID                    IN NUMBER                default hr_api.g_number
   ,P_ASSIGNMENT_NUMBER                 IN VARCHAR2              default hr_api.g_varchar2
   ,P_CHANGE_REASON                     IN VARCHAR2              default hr_api.g_varchar2
   ,P_COMMENT_ID                        OUT NOCOPY NUMBER
   ,P_COMMENTS                          IN VARCHAR2              default hr_api.g_varchar2
   ,P_DATE_PROBATION_END                IN DATE                  default hr_api.g_date

   ,P_DEFAULT_CODE_COMB_ID              IN NUMBER                default hr_api.g_number
   ,P_EMPLOYMENT_CATEGORY               IN VARCHAR2              default hr_api.g_varchar2
   ,P_FREQUENCY                         IN VARCHAR2              default hr_api.g_varchar2
   ,P_INTERNAL_ADDRESS_LINE             IN VARCHAR2              default hr_api.g_varchar2
   ,P_MANAGER_FLAG                      IN VARCHAR2              default hr_api.g_varchar2
   ,P_NORMAL_HOURS                      IN NUMBER                default hr_api.g_number
   ,P_PERF_REVIEW_PERIOD                IN NUMBER                default hr_api.g_number
   ,P_PERF_REVIEW_PERIOD_FREQUENCY      IN VARCHAR2              default hr_api.g_varchar2
   ,P_PERIOD_OF_SERVICE_ID              IN NUMBER                default hr_api.g_number
   ,P_PROBATION_PERIOD                  IN NUMBER                default hr_api.g_number
   ,P_PROBATION_UNIT                    IN VARCHAR2              default hr_api.g_varchar2
   ,P_SAL_REVIEW_PERIOD                 IN NUMBER                default hr_api.g_number
   ,P_SAL_REVIEW_PERIOD_FREQUENCY       IN VARCHAR2              default hr_api.g_varchar2
   ,P_SET_OF_BOOKS_ID                   IN NUMBER                default hr_api.g_number

   ,P_SOURCE_TYPE                       IN VARCHAR2              default hr_api.g_varchar2
   ,P_TIME_NORMAL_FINISH                IN VARCHAR2              default hr_api.g_varchar2
   ,P_TIME_NORMAL_START                 IN VARCHAR2              default hr_api.g_varchar2
   ,P_BARGAINING_UNIT_CODE              IN VARCHAR2              default hr_api.g_varchar2
   ,P_LABOUR_UNION_MEMBER_FLAG          IN VARCHAR2              default hr_api.g_varchar2
   ,P_HOURLY_SALARIED_CODE              IN VARCHAR2              default hr_api.g_varchar2
   ,P_REQUEST_ID                        IN NUMBER                default hr_api.g_number
   ,P_PROGRAM_APPLICATION_ID            IN NUMBER                default hr_api.g_number
   ,P_PROGRAM_ID                        IN NUMBER                default hr_api.g_number
   ,P_PROGRAM_UPDATE_DATE               IN DATE                  default hr_api.g_date
   ,P_ASS_ATTRIBUTE_CATEGORY            IN VARCHAR2              default hr_api.g_varchar2
   ,P_ASS_ATTRIBUTE1                    IN VARCHAR2              default hr_api.g_varchar2
   ,P_ASS_ATTRIBUTE2                    IN VARCHAR2              default hr_api.g_varchar2
   ,P_ASS_ATTRIBUTE3                    IN VARCHAR2              default hr_api.g_varchar2
   ,P_ASS_ATTRIBUTE4                    IN VARCHAR2              default hr_api.g_varchar2
   ,P_ASS_ATTRIBUTE5                    IN VARCHAR2              default hr_api.g_varchar2

   ,P_ASS_ATTRIBUTE6                    IN VARCHAR2              default hr_api.g_varchar2
   ,P_ASS_ATTRIBUTE7                    IN VARCHAR2              default hr_api.g_varchar2
   ,P_ASS_ATTRIBUTE8                    IN VARCHAR2              default hr_api.g_varchar2
   ,P_ASS_ATTRIBUTE9                    IN VARCHAR2              default hr_api.g_varchar2
   ,P_ASS_ATTRIBUTE10                   IN VARCHAR2              default hr_api.g_varchar2
   ,P_ASS_ATTRIBUTE11                   IN VARCHAR2              default hr_api.g_varchar2
   ,P_ASS_ATTRIBUTE12                   IN VARCHAR2              default hr_api.g_varchar2
   ,P_ASS_ATTRIBUTE13                   IN VARCHAR2              default hr_api.g_varchar2
   ,P_ASS_ATTRIBUTE14                   IN VARCHAR2              default hr_api.g_varchar2
   ,P_ASS_ATTRIBUTE15                   IN VARCHAR2              default hr_api.g_varchar2
   ,P_ASS_ATTRIBUTE16                   IN VARCHAR2              default hr_api.g_varchar2
   ,P_ASS_ATTRIBUTE17                   IN VARCHAR2              default hr_api.g_varchar2
   ,P_ASS_ATTRIBUTE18                   IN VARCHAR2              default hr_api.g_varchar2

   ,P_ASS_ATTRIBUTE19                   IN VARCHAR2              default hr_api.g_varchar2
   ,P_ASS_ATTRIBUTE20                   IN VARCHAR2              default hr_api.g_varchar2
   ,P_ASS_ATTRIBUTE21                   IN VARCHAR2              default hr_api.g_varchar2
   ,P_ASS_ATTRIBUTE22                   IN VARCHAR2              default hr_api.g_varchar2
   ,P_ASS_ATTRIBUTE23                   IN VARCHAR2              default hr_api.g_varchar2
   ,P_ASS_ATTRIBUTE24                   IN VARCHAR2              default hr_api.g_varchar2
   ,P_ASS_ATTRIBUTE25                   IN VARCHAR2              default hr_api.g_varchar2
   ,P_ASS_ATTRIBUTE26                   IN VARCHAR2              default hr_api.g_varchar2
   ,P_ASS_ATTRIBUTE27                   IN VARCHAR2              default hr_api.g_varchar2
   ,P_ASS_ATTRIBUTE28                   IN VARCHAR2              default hr_api.g_varchar2
   ,P_ASS_ATTRIBUTE29                   IN VARCHAR2              default hr_api.g_varchar2
   ,P_ASS_ATTRIBUTE30                   IN VARCHAR2              default hr_api.g_varchar2
   ,P_TITLE                             IN VARCHAR2              default hr_api.g_varchar2
   ,P_CONTRACT_ID                       IN NUMBER                default hr_api.g_number
   ,P_ESTABLISHMENT_ID                  IN NUMBER                default hr_api.g_number
   ,P_COLLECTIVE_AGREEMENT_ID           IN NUMBER                default hr_api.g_number
   ,P_CAGR_GRADE_DEF_ID                 IN NUMBER                default hr_api.g_number
   ,P_CAGR_ID_FLEX_NUM                  IN NUMBER                default hr_api.g_number
   ,P_ASG_OBJECT_VERSION_NUMBER         IN OUT NOCOPY NUMBER
   ,P_NOTICE_PERIOD                     IN NUMBER                default hr_api.g_number
   ,P_NOTICE_PERIOD_UOM                 IN VARCHAR2              default hr_api.g_varchar2
   ,P_EMPLOYEE_CATEGORY                 IN VARCHAR2              default hr_api.g_varchar2
   ,P_WORK_AT_HOME                      IN VARCHAR2              default hr_api.g_varchar2
   ,P_JOB_POST_SOURCE_NAME              IN VARCHAR2              default hr_api.g_varchar2
   ,P_POSTING_CONTENT_ID                IN NUMBER                default hr_api.g_number
   ,P_PLACEMENT_DATE_START              IN DATE                  default hr_api.g_date
   ,P_VENDOR_ID                         IN NUMBER                default hr_api.g_number
   ,P_VENDOR_EMPLOYEE_NUMBER            IN VARCHAR2              default hr_api.g_varchar2
   ,P_VENDOR_ASSIGNMENT_NUMBER          IN VARCHAR2              default hr_api.g_varchar2
   ,P_ASSIGNMENT_CATEGORY               IN VARCHAR2              default hr_api.g_varchar2
   ,P_PROJECT_TITLE                     IN VARCHAR2              default hr_api.g_varchar2
   ,P_APPLICANT_RANK                    IN NUMBER                default hr_api.g_number
   ,P_GRADE_LADDER_PGM_ID               IN NUMBER                default hr_api.g_number
   ,P_SUPERVISOR_ASSIGNMENT_ID          IN NUMBER                default hr_api.g_number
   ,P_VENDOR_SITE_ID                    IN NUMBER                default hr_api.g_number
   ,P_PO_HEADER_ID                      IN NUMBER                default hr_api.g_number
   ,P_PO_LINE_ID                        IN NUMBER                default hr_api.g_number
   ,P_PROJECTED_ASSIGNMENT_END          IN DATE                  default hr_api.g_date
   ,P_PAYROLL_ID_UPDATED                OUT NOCOPY BOOLEAN
   ,P_OTHER_MANAGER_WARNING             OUT NOCOPY BOOLEAN
   ,P_HOURLY_SALARIED_WARNING           OUT NOCOPY BOOLEAN
   ,P_NO_MANAGERS_WARNING               OUT NOCOPY BOOLEAN
   ,P_ORG_NOW_NO_MANAGER_WARNING        OUT NOCOPY BOOLEAN
   ,P_VALIDATION_START_DATE             OUT NOCOPY DATE
   ,P_VALIDATION_END_DATE               OUT NOCOPY DATE
   ,P_EFFECTIVE_DATE                    IN DATE                 default null
   ,P_DATETRACK_MODE                    IN VARCHAR2             default hr_api.g_update
   ,P_VALIDATE                          IN BOOLEAN              default false
   ,P_OFFER_ID                          IN OUT NOCOPY  NUMBER
   ,P_OFFER_STATUS                      IN VARCHAR2             default null
  ) Is
--
  l_proc                           varchar2(72) := g_package||'update_offer_assignment';
  l_create_new_version             boolean := false;

  l_assignment_id                  per_all_assignments_f.assignment_id%TYPE;
  l_effective_start_date           per_all_assignments_f.effective_start_date%TYPE;
  l_effective_end_date             per_all_assignments_f.effective_end_date%TYPE;
  l_business_group_id              per_all_assignments_f.business_group_id%TYPE;
  l_comment_id                     per_all_assignments_f.comment_id%TYPE;
  l_asg_object_version_number      per_all_assignments_f.object_version_number%TYPE   := p_asg_object_version_number;
  l_payroll_id_updated             boolean;
  l_other_manager_warning          boolean;
  l_hourly_salaried_warning        boolean;
  l_no_managers_warning            boolean;
  l_org_now_no_manager_warning     boolean;
  l_validation_start_date          date;
  l_validation_end_date            date;
  l_effective_date                 date;
  l_offer_id                       irc_offers.offer_id%TYPE                           := p_offer_id;

  l_prev_offer_status              irc_offers.offer_status%TYPE;
  l_iof_object_version_number      irc_offers.object_version_number%TYPE;
  l_offer_version                  irc_offers.offer_version%TYPE;
  l_datetrack_mode                 varchar2(30) := hr_api.g_update;
--
  cursor csr_prev_offer_details is
         select offer_status
               ,offer_assignment_id
           from irc_offers
          where offer_id = p_offer_id;
--
  cursor csr_asg_effective_start_date is
         select effective_start_date
           from per_all_assignments_f
          where assignment_id = P_ASSIGNMENT_ID
            and p_effective_date
        between effective_start_date
            and effective_end_date;
--
  cursor csr_offer_record is
    select
       offer_version
      ,offer_status
      ,discretionary_job_title
      ,offer_extended_method
      ,respondent_id
      ,expiry_date
      ,proposed_start_date
      ,offer_letter_tracking_code
      ,offer_postal_service
      ,offer_shipping_date
      ,vacancy_id
      ,applicant_assignment_id
      ,offer_assignment_id
      ,address_id
      ,template_id
      ,offer_letter_file_type
      ,offer_letter_file_name
      ,attribute_category
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
      ,attribute6
      ,attribute7
      ,attribute8
      ,attribute9
      ,attribute10
      ,attribute11
      ,attribute12
      ,attribute13
      ,attribute14
      ,attribute15
      ,attribute16
      ,attribute17
      ,attribute18
      ,attribute19
      ,attribute20
      ,attribute21
      ,attribute22
      ,attribute23
      ,attribute24
      ,attribute25
      ,attribute26
      ,attribute27
      ,attribute28
      ,attribute29
      ,attribute30
    from irc_offers
    where offer_id = p_offer_id;

    l_offer_record   csr_offer_record%ROWTYPE;
--
  Begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_OFFER_ASSIGNMENT;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  --
  open  csr_prev_offer_details;
  fetch csr_prev_offer_details into l_prev_offer_status
                                   ,l_assignment_id;
  --
  if csr_prev_offer_details%notfound
  then
    --
    hr_utility.set_location(l_proc, 20);
    --
    close csr_prev_offer_details;
    fnd_message.set_name('PER','IRC_412322_INVALID_OFFER_ID');
    fnd_message.raise_error;
    --
  end if;
  close csr_prev_offer_details;
  --
  open csr_asg_effective_start_date;
  fetch csr_asg_effective_start_date into l_effective_start_date;
  --
  if csr_asg_effective_start_date%notfound
  then
    --
    close csr_asg_effective_start_date;
    fnd_message.set_name('PER','IRC_412006_ASG_NOT_APPL');
    fnd_message.raise_error;
    --
  end if;
  close csr_asg_effective_start_date;
  --
  if l_effective_start_date <= p_effective_date
  then
    --
    -- Since the current record has started today, we need to
    -- correct the existing record.
    --
    l_datetrack_mode := hr_api.g_correction;
  else
    --
    -- End the existing record and create a new record.
    --
    l_datetrack_mode := hr_api.g_update;
    --
  end if;
  --
  if l_prev_offer_status = 'HOLD'
     OR p_offer_status = 'HOLD'
  then
    --
    hr_utility.set_location(l_proc, 25);
    --
    fnd_message.set_name('PER','IRC_412306_CANT_UPD_HELD_OFFER');
    fnd_message.raise_error;
    --
  elsif l_prev_offer_status in ('EXTENDED','APPROVED','CLOSED')
     OR p_offer_status in ('EXTENDED','APPROVED','CLOSED')
  then
    --
    hr_utility.set_location(l_proc, 30);
    --
    -- The code to check new offer version creation has been disabled
    -- since this will now be taken care of in the Java Layer itself.
    -- New Offer version creation code is no longer supported.
    --
    --
    -- l_create_new_version := true;
    --
  end if;
--
-- Should there be a check to see if any value in the offer assignment
-- record has indeed been modified ?
--
  if l_create_new_version = true
  then
    --
    hr_utility.set_location(l_proc, 40);
    --
    -- close the current offer and offer assignment.
    --
    close_offer
    ( p_validate           =>   p_validate
     ,p_effective_date     =>   l_effective_date
     ,p_offer_id           =>   p_offer_id
     ,p_change_reason      =>   'UPDATED'
     ,p_status_change_date =>   l_effective_date
    );
    --
    -- create a new offer and offer assignment.
    --
    open csr_offer_record;
    fetch csr_offer_record into l_offer_record;
    --
    if csr_offer_record%notfound
    then
      --
      hr_utility.set_location(l_proc, 50);
      --
      close csr_offer_record;
      fnd_message.set_name('PER','IRC_412322_INVALID_OFFER_ID');
      fnd_message.raise_error;
      --
    end if;
    close csr_offer_record;
    --
    l_assignment_id := l_offer_record.offer_assignment_id;
    --
    create_offer
    (p_validate                     => p_validate
    ,p_effective_date               => l_effective_date
    ,p_offer_status                 => 'SAVED'
    ,p_discretionary_job_title      => l_offer_record.discretionary_job_title
    ,p_offer_extended_method        => l_offer_record.offer_extended_method
    ,p_respondent_id                => l_offer_record.respondent_id
    ,p_expiry_date                  => l_offer_record.expiry_date
    ,p_proposed_start_date          => l_offer_record.proposed_start_date
    ,p_offer_letter_tracking_code   => l_offer_record.offer_letter_tracking_code
    ,p_offer_postal_service         => l_offer_record.offer_postal_service
    ,p_offer_shipping_date          => l_offer_record.offer_shipping_date
    ,p_applicant_assignment_id      => l_offer_record.applicant_assignment_id
     -- Get the newly created offer assignment ID
    ,p_offer_assignment_id          => l_assignment_id
    ,p_address_id                   => l_offer_record.address_id
    ,p_template_id                  => l_offer_record.template_id
    ,p_offer_letter_file_type       => l_offer_record.offer_letter_file_type
    ,p_offer_letter_file_name       => l_offer_record.offer_letter_file_name
    ,p_attribute_category           => l_offer_record.attribute_category
    ,p_attribute1                   => l_offer_record.attribute1
    ,p_attribute2                   => l_offer_record.attribute2
    ,p_attribute3                   => l_offer_record.attribute3
    ,p_attribute4                   => l_offer_record.attribute4
    ,p_attribute5                   => l_offer_record.attribute5
    ,p_attribute6                   => l_offer_record.attribute6
    ,p_attribute7                   => l_offer_record.attribute7
    ,p_attribute8                   => l_offer_record.attribute8
    ,p_attribute9                   => l_offer_record.attribute9
    ,p_attribute10                  => l_offer_record.attribute10
    ,p_attribute11                  => l_offer_record.attribute11
    ,p_attribute12                  => l_offer_record.attribute12
    ,p_attribute13                  => l_offer_record.attribute13
    ,p_attribute14                  => l_offer_record.attribute14
    ,p_attribute15                  => l_offer_record.attribute15
    ,p_attribute16                  => l_offer_record.attribute16
    ,p_attribute17                  => l_offer_record.attribute17
    ,p_attribute18                  => l_offer_record.attribute18
    ,p_attribute19                  => l_offer_record.attribute19
    ,p_attribute20                  => l_offer_record.attribute20
    ,p_attribute21                  => l_offer_record.attribute21
    ,p_attribute22                  => l_offer_record.attribute22
    ,p_attribute23                  => l_offer_record.attribute23
    ,p_attribute24                  => l_offer_record.attribute24
    ,p_attribute25                  => l_offer_record.attribute25
    ,p_attribute26                  => l_offer_record.attribute26
    ,p_attribute27                  => l_offer_record.attribute27
    ,p_attribute28                  => l_offer_record.attribute28
    ,p_attribute29                  => l_offer_record.attribute29
    ,p_attribute30                  => l_offer_record.attribute30
    ,p_status_change_date           => l_effective_date
    ,p_offer_id                     => l_offer_id
    ,p_offer_version                => l_offer_version
    ,p_object_version_number        => l_iof_object_version_number
    );
    --
    -- Since a new offer assignment record has been created, we will
    -- be updating the assignment_record again on the same day of creation.
    -- We hence need to set the date track mode to 'hr_api.g_correction'
    --
    l_datetrack_mode := hr_api.g_correction;
    --
  end if; -- l_create_new_version
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- update the offer assignment record.
  --
  per_asg_upd.upd
  (  p_assignment_id                     =>       l_assignment_id
    ,p_effective_start_date              =>       l_effective_start_date
    ,p_effective_end_date                =>       l_effective_end_date
    ,p_business_group_id                 =>       l_business_group_id

    ,p_recruiter_id                      =>       p_recruiter_id
    ,p_grade_id                          =>       p_grade_id
    ,p_position_id                       =>       p_position_id
    ,p_job_id                            =>       p_job_id
    ,p_assignment_status_type_id         =>       p_assignment_status_type_id
    ,p_payroll_id                        =>       p_payroll_id
    ,p_location_id                       =>       p_location_id
    ,p_person_referred_by_id             =>       p_person_referred_by_id
    ,p_supervisor_id                     =>       p_supervisor_id
    ,p_special_ceiling_step_id           =>       p_special_ceiling_step_id
    ,p_recruitment_activity_id           =>       p_recruitment_activity_id
    ,p_source_organization_id            =>       p_source_organization_id

    ,p_organization_id                   =>       p_organization_id
    ,p_people_group_id                   =>       p_people_group_id
    ,p_soft_coding_keyflex_id            =>       p_soft_coding_keyflex_id
    ,p_vacancy_id                        =>       p_vacancy_id
    ,p_pay_basis_id                      =>       p_pay_basis_id
    ,p_assignment_type                   =>       p_assignment_type
    ,p_primary_flag                      =>       p_primary_flag
    ,p_application_id                    =>       p_application_id
    ,p_assignment_number                 =>       p_assignment_number
    ,p_change_reason                     =>       p_change_reason
    ,p_comment_id                        =>       l_comment_id
    ,p_comments                          =>       p_comments
    ,p_date_probation_end                =>       p_date_probation_end

    ,p_default_code_comb_id              =>       p_default_code_comb_id
    ,p_employment_category               =>       p_employment_category
    ,p_frequency                         =>       p_frequency
    ,p_internal_address_line             =>       p_internal_address_line
    ,p_manager_flag                      =>       p_manager_flag
    ,p_normal_hours                      =>       p_normal_hours
    ,p_perf_review_period                =>       p_perf_review_period
    ,p_perf_review_period_frequency      =>       p_perf_review_period_frequency
    ,p_period_of_service_id              =>       p_period_of_service_id
    ,p_probation_period                  =>       p_probation_period
    ,p_probation_unit                    =>       p_probation_unit
    ,p_sal_review_period                 =>       p_sal_review_period
    ,p_sal_review_period_frequency       =>       p_sal_review_period_frequency
    ,p_set_of_books_id                   =>       p_set_of_books_id

    ,p_source_type                       =>       p_source_type
    ,p_time_normal_finish                =>       p_time_normal_finish
    ,p_time_normal_start                 =>       p_time_normal_start
    ,p_bargaining_unit_code              =>       p_bargaining_unit_code
    ,p_labour_union_member_flag          =>       p_labour_union_member_flag
    ,p_hourly_salaried_code              =>       p_hourly_salaried_code
    ,p_request_id                        =>       p_request_id
    ,p_program_application_id            =>       p_program_application_id
    ,p_program_id                        =>       p_program_id
    ,p_program_update_date               =>       p_program_update_date
    ,p_ass_attribute_category            =>       p_ass_attribute_category
    ,p_ass_attribute1                    =>       p_ass_attribute1
    ,p_ass_attribute2                    =>       p_ass_attribute2
    ,p_ass_attribute3                    =>       p_ass_attribute3
    ,p_ass_attribute4                    =>       p_ass_attribute4
    ,p_ass_attribute5                    =>       p_ass_attribute5

    ,p_ass_attribute6                    =>       p_ass_attribute6
    ,p_ass_attribute7                    =>       p_ass_attribute7
    ,p_ass_attribute8                    =>       p_ass_attribute8
    ,p_ass_attribute9                    =>       p_ass_attribute9
    ,p_ass_attribute10                   =>       p_ass_attribute10
    ,p_ass_attribute11                   =>       p_ass_attribute11
    ,p_ass_attribute12                   =>       p_ass_attribute12
    ,p_ass_attribute13                   =>       p_ass_attribute13
    ,p_ass_attribute14                   =>       p_ass_attribute14
    ,p_ass_attribute15                   =>       p_ass_attribute15
    ,p_ass_attribute16                   =>       p_ass_attribute16
    ,p_ass_attribute17                   =>       p_ass_attribute17
    ,p_ass_attribute18                   =>       p_ass_attribute18

    ,p_ass_attribute19                   =>       p_ass_attribute19
    ,p_ass_attribute20                   =>       p_ass_attribute20
    ,p_ass_attribute21                   =>       p_ass_attribute21
    ,p_ass_attribute22                   =>       p_ass_attribute22
    ,p_ass_attribute23                   =>       p_ass_attribute23
    ,p_ass_attribute24                   =>       p_ass_attribute24
    ,p_ass_attribute25                   =>       p_ass_attribute25
    ,p_ass_attribute26                   =>       p_ass_attribute26
    ,p_ass_attribute27                   =>       p_ass_attribute27
    ,p_ass_attribute28                   =>       p_ass_attribute28
    ,p_ass_attribute29                   =>       p_ass_attribute29
    ,p_ass_attribute30                   =>       p_ass_attribute30
    ,p_title                             =>       p_title
    ,p_contract_id                       =>       p_contract_id
    ,p_establishment_id                  =>       p_establishment_id
    ,p_collective_agreement_id           =>       p_collective_agreement_id
    ,p_cagr_grade_def_id                 =>       p_cagr_grade_def_id
    ,p_cagr_id_flex_num                  =>       p_cagr_id_flex_num
    ,p_object_version_number             =>       l_asg_object_version_number
    ,p_notice_period                     =>       p_notice_period
    ,p_notice_period_uom                 =>       p_notice_period_uom
    ,p_employee_category                 =>       p_employee_category
    ,p_work_at_home                      =>       p_work_at_home
    ,p_job_post_source_name              =>       p_job_post_source_name
    ,p_posting_content_id                =>       p_posting_content_id
    ,p_placement_date_start              =>       p_placement_date_start
    ,p_vendor_id                         =>       p_vendor_id
    ,p_vendor_employee_number            =>       p_vendor_employee_number
    ,p_vendor_assignment_number          =>       p_vendor_assignment_number
    ,p_assignment_category               =>       p_assignment_category
    ,p_project_title                     =>       p_project_title
    ,p_applicant_rank                    =>       p_applicant_rank
    ,p_grade_ladder_pgm_id               =>       p_grade_ladder_pgm_id
    ,p_supervisor_assignment_id          =>       p_supervisor_assignment_id
    ,p_vendor_site_id                    =>       p_vendor_site_id
    ,p_po_header_id                      =>       p_po_header_id
    ,p_po_line_id                        =>       p_po_line_id
    ,p_projected_assignment_end          =>       p_projected_assignment_end
    ,p_payroll_id_updated                =>       l_payroll_id_updated
    ,p_other_manager_warning             =>       l_other_manager_warning
    ,p_hourly_salaried_warning           =>       l_hourly_salaried_warning
    ,p_no_managers_warning               =>       l_no_managers_warning
    ,p_org_now_no_manager_warning        =>       l_org_now_no_manager_warning
    ,p_validation_start_date             =>       l_validation_start_date
    ,p_validation_end_date               =>       l_validation_end_date
    ,p_effective_date                    =>       l_effective_date
    ,p_datetrack_mode                    =>       l_datetrack_mode
    ,p_validate                          =>       p_validate
   );
  --
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all IN OUT and OUT parameters with out values
  --
  p_assignment_id                 :=        l_assignment_id;
  p_effective_start_date          :=        l_effective_start_date;
  p_effective_end_date            :=        l_effective_end_date;
  p_business_group_id             :=        l_business_group_id;
  p_comment_id                    :=        l_comment_id;
  p_payroll_id_updated            :=        l_payroll_id_updated;
  p_other_manager_warning         :=        l_other_manager_warning;
  p_hourly_salaried_warning       :=        l_hourly_salaried_warning;
  p_no_managers_warning           :=        l_no_managers_warning;
  p_org_now_no_manager_warning    :=        l_org_now_no_manager_warning;
  p_validation_start_date         :=        l_validation_start_date;
  p_validation_end_date           :=        l_validation_end_date;
  p_offer_id                      :=        l_offer_id;
  p_asg_object_version_number     :=        l_asg_object_version_number;

  hr_utility.set_location(' Leaving:'||l_proc, 145);
--
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to UPDATE_OFFER_ASSIGNMENT;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_assignment_id                 :=      l_assignment_id;
    p_effective_start_date          :=      l_effective_start_date;
    p_effective_end_date            :=      l_effective_end_date;
    p_business_group_id             :=      l_business_group_id;
    p_comment_id                    :=      l_comment_id;
    p_payroll_id_updated            :=      l_payroll_id_updated;
    p_other_manager_warning         :=      l_other_manager_warning;
    p_hourly_salaried_warning       :=      l_hourly_salaried_warning;
    p_no_managers_warning           :=      l_no_managers_warning;
    p_org_now_no_manager_warning    :=      l_org_now_no_manager_warning;
    p_validation_start_date         :=      l_validation_start_date;
    p_validation_end_date           :=      l_validation_end_date;
    p_offer_id                      :=      l_offer_id;
    p_asg_object_version_number     :=      l_asg_object_version_number;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 150);
  when others then
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_assignment_id                 :=      l_assignment_id;
    p_effective_start_date          :=      l_effective_start_date;
    p_effective_end_date            :=      l_effective_end_date;
    p_business_group_id             :=      l_business_group_id;
    p_comment_id                    :=      l_comment_id;
    p_payroll_id_updated            :=      l_payroll_id_updated;
    p_other_manager_warning         :=      l_other_manager_warning;
    p_hourly_salaried_warning       :=      l_hourly_salaried_warning;
    p_no_managers_warning           :=      l_no_managers_warning;
    p_org_now_no_manager_warning    :=      l_org_now_no_manager_warning;
    p_validation_start_date         :=      l_validation_start_date;
    p_validation_end_date           :=      l_validation_end_date;
    p_offer_id                      :=      l_offer_id;
    p_asg_object_version_number     :=      l_asg_object_version_number;
    --
    -- A validation or unexpected error has occured
    --
    rollback to UPDATE_OFFER_ASSIGNMENT;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 160);
    raise;
end update_offer_assignment;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_offer_assignment >------------------------|
-- ----------------------------------------------------------------------------
--
  procedure delete_offer_assignment
  ( P_VALIDATE                     IN   boolean     default false
   ,P_EFFECTIVE_DATE               IN   date        default null
   ,P_OFFER_ASSIGNMENT_ID          IN   number
  ) Is
--
  l_proc                           varchar2(72) := g_package||'delete_offer_assignment';
  l_offer_id                       irc_offers.offer_id%TYPE;
  l_offer_object_version_number    irc_offers.object_version_number%TYPE;
--
  cursor csr_offer_id is
         select offer_id
               ,object_version_number
           from irc_offers
          where offer_assignment_id = p_offer_assignment_id;
--
  Begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_OFFER_ASSIGNMENT;
  --
  open  csr_offer_id;
  fetch csr_offer_id into l_offer_id,l_offer_object_version_number;
  --
  if csr_offer_id%notfound
  then
    --
    hr_utility.set_location(l_proc, 20);
    --
    close csr_offer_id;
    fnd_message.set_name('PER','IRC_412322_INVALID_OFFER_ID');
    fnd_message.raise_error;
    --
  end if;
  close csr_offer_id;
  --
  -- If the offer is valid, call the delete procedure of offer
  -- so that both the offer record and the offer assignment
  -- record are deleted.
  --
  hr_utility.set_location(l_proc, 30);
  --
  delete_offer
  ( p_validate                => p_validate
   ,p_object_version_number   => l_offer_object_version_number
   ,p_offer_id                => l_offer_id
   ,p_effective_date          => p_effective_date
  );
  --
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
  --
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to DELETE_OFFER_ASSIGNMENT;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 60);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to DELETE_OFFER_ASSIGNMENT;
    hr_utility.set_location(' Leaving:'||l_proc, 70);
    raise;
end delete_offer_assignment;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< upload_offer_letter >---------------------------|
-- ----------------------------------------------------------------------------
--
  procedure upload_offer_letter
  ( P_VALIDATE                     IN   boolean     default false
   ,P_OFFER_LETTER                 IN   BLOB
   ,P_OFFER_ID                     IN   NUMBER
   ,P_OBJECT_VERSION_NUMBER        IN   NUMBER
  ) Is
--
  l_proc                           varchar2(72) := g_package||'upload_offer_letter';
--
  Begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPLOAD_OFFER_LETTER;
  --
  -- Call blob_dml to pass on the blob to be uploaded
  --
  hr_utility.set_location(l_proc, 30);
  --
  irc_iof_shd.blob_dml
  ( p_offer_letter            => p_offer_letter
   ,p_offer_id                => p_offer_id
   ,p_object_version_number   => p_object_version_number
  );
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to UPLOAD_OFFER_LETTER;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 50);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to UPLOAD_OFFER_LETTER;
    hr_utility.set_location(' Leaving:'||l_proc, 60);
    raise;
end upload_offer_letter;
--
end IRC_OFFERS_API;

/
