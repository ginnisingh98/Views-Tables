--------------------------------------------------------
--  DDL for Package Body PQH_FR_ASSIGNMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_FR_ASSIGNMENT_API" As
/* $Header: pqasgapi.pkb 120.1.12000000.2 2007/08/17 13:17:11 abhaduri noship $ */
--
-- Package variables
--
g_package  varchar2(33) := '  hr_assignment_api.';
g_debug boolean := hr_utility.debug_enabled;
--
--
-- Procedure update_primary_assg_affectation

procedure update_primary_asg_affectation
(
 p_validate       in boolean default false,
 p_assignment_id     in  number,
 p_effective_date in date,
 p_primary_affectation in varchar2,
 p_organization_id in number,
 p_job_id          in number,
 p_position_id   in  number,
 p_datetrack_update_mode in varchar2,
 p_object_version_number in number,
 p_person_id             in number,
 p_supervisor_id         in number default null
)
is

  l_validate                      boolean;
  l_no_managers_warning           boolean;
  l_other_manager_warning         boolean;
  l_other_manager_warning2        boolean;
  l_hourly_salaried_warning       boolean;
  l_soft_coding_keyflex_id        number;
  l_cagr_grade_def_id             number;
  l_cagr_concatenated_segments    varchar2(1000);
  l_concatenated_segments         varchar2(1000);
  l_comment_id                    number;
  l_effective_start_date          date;
  l_effective_end_date            date;
  l_ovn                           number;
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  l_assignment_id                number;
  l_admin_career_id              number;

-- scl - 1146
-- people_group_id 1103
-- common info variables
    l_people_group_id               number ;
    l_establishment_id              number;
    l_fr_emp_category               varchar2(1000);
    l_special_ceiling_step_id       number;
    l_group_name                    varchar2(1000);
    l_org_now_no_manager_warning    boolean;
    l_spp_delete_warning            boolean;
    l_entries_changed_warning       varchar2(1000);
    l_tax_district_changed_warning  boolean;
    l_scl_id number ;
    l_fut_pri_start_date Date;

-- Cursor to get the future assignment dates.

    cursor csr_fut_primary_asg is
    Select effective_start_date from
    per_all_assignments_f
    where primary_flag = 'Y'
    and person_id = p_person_id
    and assignment_id = p_assignment_id
    and effective_start_date > p_effective_date;

begin

if (p_primary_affectation = 'Y' )then
--
  l_ovn := p_object_version_number;

  -- If Employee the following routine will be Called
   If (pqh_fr_utility.is_worker_employee(p_person_id,p_effective_date)) then
   --
   hr_assignment_api.update_emp_asg_criteria
    (
    p_validate                     => p_validate
   ,p_effective_date               => p_effective_date
   ,p_datetrack_update_mode        => p_datetrack_update_mode
   ,p_assignment_id                => p_assignment_id
   ,p_organization_id              => p_organization_id
   ,p_position_id                  => p_position_id
   ,p_job_id                       => p_job_id
    -- Out Variables
  ,p_people_group_id              => l_people_group_id
  ,p_object_version_number        => l_ovn -- In OUT
  ,p_special_ceiling_step_id      => l_special_ceiling_step_id
  ,p_group_name                      => l_group_name
  ,p_effective_start_date            => l_effective_start_date
  ,p_effective_end_date              => l_effective_end_date
  ,p_org_now_no_manager_warning      => l_org_now_no_manager_warning
  ,p_other_manager_warning           => l_other_manager_warning
  ,p_spp_delete_warning              => l_spp_delete_warning
  ,p_entries_changed_warning         => l_entries_changed_warning
  ,p_tax_district_changed_warning    => l_tax_district_changed_warning);
  --
    update per_all_assignments_f
    set supervisor_id = p_supervisor_id
    where
         person_id = p_person_id
    and  p_effective_date between effective_start_date and effective_end_date
    and  assignment_id = p_assignment_id
    and  primary_flag = 'Y';

  ElsIf (pqh_fr_utility.is_worker_cwk(p_person_id,p_effective_date)) Then

   hr_assignment_api.update_cwk_asg_criteria
    (
     p_validate                     => p_validate
    ,p_effective_date               => p_effective_date
    ,p_datetrack_update_mode        => p_datetrack_update_mode
    ,p_assignment_id                => p_assignment_id
    ,p_organization_id              => p_organization_id
    ,p_position_id                  => p_position_id
    ,p_job_id                       => p_job_id
    -- Out Variables
    ,p_people_group_id              => l_people_group_id
    ,p_object_version_number        => l_ovn -- In OUT
    ,p_people_group_name                      => l_group_name
    ,p_effective_start_date            => l_effective_start_date
    ,p_effective_end_date              => l_effective_end_date
    ,p_org_now_no_manager_warning      => l_org_now_no_manager_warning
    ,p_other_manager_warning           => l_other_manager_warning
    ,p_spp_delete_warning              => l_spp_delete_warning
    ,p_entries_changed_warning         => l_entries_changed_warning
    ,p_tax_district_changed_warning    => l_tax_district_changed_warning);

    update per_all_assignments_f
    set supervisor_id = p_supervisor_id
    where
         person_id = p_person_id
    and  p_effective_date between effective_start_date and effective_end_date
    and  assignment_id = p_assignment_id
    and  primary_flag = 'Y';


  End if;

--
open csr_fut_primary_asg;
  loop
    fetch csr_fut_primary_asg into l_fut_pri_start_date;
    exit when csr_fut_primary_asg%notfound;

    update per_all_assignments_f
    set position_id = p_position_id,
         job_id = p_job_id,
         organization_id = p_organization_id,
         supervisor_id = p_supervisor_id
    where
         person_id = p_person_id
    and  effective_start_date = l_fut_pri_start_date
    and  assignment_id = p_assignment_id
    and  primary_flag = 'Y';

  end loop;

  close csr_fut_primary_asg;
end if;

end update_primary_asg_affectation;
--
--
procedure create_affectation
  (p_validate                     in     boolean
  ,p_effective_date               in     date
  ,p_organization_id              in     number
  ,p_position_id                  in     number
  ,p_person_id                    in     number
  ,p_job_id                       in     number
  ,p_supervisor_id                in     number
  ,p_assignment_number            in out nocopy varchar2
  ,p_assignment_status_type_id    in     number

  ,p_identifier                   in     varchar2
  ,p_affectation_type             in     varchar2
  ,p_percent_effected             in     varchar2
  ,p_primary_affectation          in     varchar2 default 'N'
  ,p_group_name                      out nocopy varchar2

  ,p_scl_concat_segments          in     varchar2

  ,p_assignment_id                   out nocopy number
  ,p_soft_coding_keyflex_id        in  out nocopy number

  ,p_object_version_number           out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_assignment_sequence             out nocopy number
  )
   IS

  l_validate                      boolean;
  l_no_managers_warning           boolean;
  l_other_manager_warning         boolean;
  l_hourly_salaried_warning       boolean;
  l_soft_coding_keyflex_id        number;
  l_cagr_grade_def_id             number;
  l_cagr_concatenated_segments    varchar2(1000);
  l_concatenated_segments         varchar2(1000);
  l_comment_id                    number;
  l_position_id                   number;
  l_frequency                     varchar2(30);
  l_p_normal_hours                number;
  l_business_group_id             number;


  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  l_assignment_id                number;

  -- common info variables
    l_people_group_id               number ;
    l_establishment_id              number;
    l_fr_emp_category               varchar2(1000);
    l_admin_career_id               number;
    l_p_asg_ovn                     number;


  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_affectation';
  l_temp                          varchar2(10);

-- Cursors to Fetch all primary assignment's People group Segements, the same will be passed
-- to the secondary assingment.


 cursor common_info_csr is
 Select people_group_id, establishment_id , scl.segment10 FrEmpCategory,
            assignment_id,object_version_number,normal_hours,frequency,business_group_id
          from per_all_assignments_f asg, hr_soft_coding_keyflex scl
          where person_id = p_person_id
          and scl.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
          and p_effective_date between effective_start_date and effective_end_date
          and primary_flag ='Y';



-- Note : CAGR_GRADE_DEF_ID is not used, assuming that will not be used by the customer, as the functionality is not delivered.
--
l_identifier varchar2(30);

Begin

  hr_utility.set_location(' Entering:' || l_proc,10);
  hr_utility.set_location(' Parameters' || l_proc,10);
  hr_utility.set_location(' p_organization_id:' || p_organization_id,10);
  hr_utility.set_location(' p_position_id:' || p_position_id,10);
  hr_utility.set_location(' p_person_id:' || p_person_id,10);
  hr_utility.set_location(' p_job_id:' || p_job_id,10);
  hr_utility.set_location(' p_supervisor_id:' || p_supervisor_id,10);
  hr_utility.set_location(' p_assignment_number:' || p_assignment_number,10);
  hr_utility.set_location(' p_assignment_status_type_id:' || p_assignment_status_type_id,10);
  hr_utility.set_location(' p_identifier:' || p_identifier,10);
  hr_utility.set_location(' p_affectation_type:' || p_affectation_type,10);
  hr_utility.set_location(' p_percent_effected:' || p_percent_effected,10);
  hr_utility.set_location(' p_primary_affectation:' || p_primary_affectation,10);

   --

   -- Issue a savepoint
   --
   savepoint create_secondary_emp_asg_swi;

   --
   -- Remember IN OUT parameter IN values
   --
   l_soft_coding_keyflex_id        := null;
   --
   -- Register Surrogate ID or user key values
   --
   per_asg_ins.set_base_key_value
     (p_assignment_id => p_assignment_id
     );
   --
   -- Call API
   --

   -- Fetch common values from Primary assignment
    Open common_info_csr;
      fetch common_info_csr into l_people_group_id,l_establishment_id,
                            l_fr_emp_category,l_admin_career_id,l_p_asg_ovn,l_p_normal_hours,l_frequency,l_business_group_id;
    Close common_info_csr;

    hr_utility.set_location(' CC Id '|| p_soft_coding_keyflex_id,10);

    -- Create Affectation : If Affectation is a Primary, then donot pass Position
    -- instead position will be updated on the assignment by using l_admin_career_id = assignment_id
    -- on primary assignment
    -- else Position details will be copied to Affecation details
    --
    if (p_primary_affectation = 'Y') then
       hr_utility.set_location(' Admin career id '|| to_char(l_admin_career_id),10);
      PQH_FR_ASSIGNMENT_CHK.chk_primary_affectation(p_person_id, p_effective_date,l_admin_career_id);
      l_position_id := null;
    else
       l_position_id := p_position_id;
    end if;

      l_identifier := p_identifier;
   pqh_fr_assignment_chk.chk_situation(p_person_id,p_effective_date);
   pqh_fr_assignment_chk.chk_percent_affected(p_percent_effected, p_person_id, p_effective_date );
   pqh_fr_assignment_chk.chk_position(p_position_id,p_person_id,p_effective_date);
   pqh_fr_assignment_chk.chk_Identifier(l_identifier);
   pqh_fr_assignment_chk.chk_type(p_affectation_type,p_person_id,p_effective_date,p_position_id);

   If (pqh_fr_utility.is_worker_employee(p_person_id,p_effective_date)) Then
   --
     hr_assignment_api.create_secondary_emp_asg(
       p_validate                     => p_validate
      ,p_effective_date               => p_effective_date
      ,p_person_id                    => p_person_id
      ,p_organization_id              => p_organization_id
      ,p_frequency                    => l_frequency
       ,p_normal_hours                 => l_p_normal_hours * p_percent_effected/100
      ,p_position_id                  => l_position_id
      ,p_job_id                       => p_job_id
      ,p_supervisor_id                => p_supervisor_id
      ,p_assignment_number            => p_assignment_number
      ,p_assignment_status_type_id    => p_assignment_status_type_id
      ,p_establishment_id            => l_establishment_id
      ,p_scl_segment2               => 'CIVIL'
      ,p_scl_segment10              => l_fr_emp_category
      ,p_scl_segment23        	    => p_identifier
      ,p_scl_segment24        	    => p_affectation_type
      ,p_scl_segment25        	    => p_percent_effected
      ,p_scl_segment26        	    => l_admin_career_id
      ,p_scl_segment27        	    => p_primary_affectation

    -- Following are Out Parameters
   ,p_group_name                     => p_group_name
   ,p_concatenated_segments          => l_concatenated_segments
   ,p_cagr_grade_def_id              => l_cagr_grade_def_id
   ,p_cagr_concatenated_segments     => l_cagr_concatenated_segments
   ,p_assignment_id                  => p_assignment_id
   ,p_soft_coding_keyflex_id         => p_soft_coding_keyflex_id
   ,p_people_group_id                => l_people_group_id
   ,p_object_version_number          => p_object_version_number
   ,p_effective_start_date           => p_effective_start_date
   ,p_effective_end_date             => p_effective_end_date
   ,p_assignment_sequence            => p_assignment_sequence
   ,p_comment_id                     => l_comment_id
   ,p_other_manager_warning          => l_other_manager_warning
    );
   --
  ElsIf (pqh_fr_utility.is_worker_cwk(p_person_id,p_effective_date)) Then
  --

    hr_assignment_api.create_secondary_cwk_asg(
       p_validate                     => p_validate
      ,p_effective_date               => p_effective_date
      ,p_business_group_id            => l_business_group_id
      ,p_person_id                    => p_person_id
      ,p_organization_id              => p_organization_id
      ,p_frequency                    => l_frequency
      ,p_normal_hours                 => l_p_normal_hours * p_percent_effected/100
      ,p_position_id                  => l_position_id
      ,p_job_id                       => p_job_id
      ,p_supervisor_id                => p_supervisor_id
      ,p_assignment_number            => p_assignment_number
      ,p_assignment_status_type_id    => p_assignment_status_type_id
      ,p_establishment_id            => l_establishment_id
      ,p_scl_segment2               => 'CIVIL'
      ,p_scl_segment10              => l_fr_emp_category
      ,p_scl_segment23        	    => p_identifier
      ,p_scl_segment24        	    => p_affectation_type
      ,p_scl_segment25        	    => p_percent_effected
      ,p_scl_segment26        	    => l_admin_career_id
      ,p_scl_segment27        	    => p_primary_affectation

    -- Following are Out Parameters
     ,p_assignment_id                   => p_assignment_id
     ,p_object_version_number           => p_object_version_number
     ,p_effective_start_date            => p_effective_start_date
     ,p_effective_end_date              => p_effective_end_date
     ,p_assignment_sequence             => p_assignment_sequence
     ,p_comment_id                      => l_comment_id
     ,p_people_group_id                 => l_people_group_id
     ,p_people_group_name               => p_group_name
     ,p_other_manager_warning           => l_other_manager_warning
     ,p_hourly_salaried_warning         =>  l_hourly_salaried_warning
     ,p_soft_coding_keyflex_id          => p_soft_coding_keyflex_id
    );

  --
  End if;


  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  update_primary_asg_affectation
      (
        p_validate              => p_validate,
        p_assignment_id         => l_admin_career_id,
        p_effective_date        => p_effective_date,
        p_primary_affectation   => p_primary_affectation,
        p_organization_id       => p_organization_id,
        p_job_id                => p_job_id,
        p_position_id           => p_position_id,
        p_datetrack_update_mode => pqh_fr_utility.get_DateTrack_Mode(p_effective_date,'PER_ALL_ASSIGNMENTS_F','ASSIGNMENT_ID',l_admin_career_id),
        p_object_version_number => l_p_asg_ovn,
        p_person_id             => p_person_id,
	p_supervisor_id         => p_supervisor_id
      ) ;

  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
End create_affectation;
---
---
---

procedure  update_affectation
  (p_validate                     in     boolean  default false
  ,p_datetrack_update_mode        in     varchar2
  ,p_effective_date               in     date
  ,p_organization_id              in     number
  ,p_position_id                  in     number
  ,p_person_id                    in     number
  ,p_job_id                       in     number
  ,p_supervisor_id                in     number
  ,p_assignment_number            in     varchar2
  ,p_assignment_status_type_id    in     number

  ,p_identifier                   in     varchar2
  ,p_affectation_type             in     varchar2
  ,p_percent_effected             in     varchar2
  ,p_primary_affectation          in     varchar2
  ,p_group_name                      out nocopy varchar2

  ,p_scl_concat_segments          in     varchar2

  ,p_assignment_id                in  number
  ,p_soft_coding_keyflex_id          out nocopy number
  ,p_object_version_number        in out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  ,p_assignment_sequence             out nocopy number
  ) IS


 l_validate                      boolean;
  l_no_managers_warning           boolean;
  l_other_manager_warning         boolean;
  l_other_manager_warning2        boolean;
  l_hourly_salaried_warning       boolean;
  l_soft_coding_keyflex_id        number;
  l_cagr_grade_def_id             number;
  l_cagr_concatenated_segments    varchar2(1000);
  l_concatenated_segments         varchar2(1000);
  l_comment_id                    number;
  l_old_primary_affectation       varchar2(100);
  l_temp                          varchar2(10);
  --
  -- Variables for IN/OUT parameters
  l_object_version_number         number;
  l_assignment_id                number;
  l_admin_career_id              number;
  l_p_asg_ovn                    number;

  -- common info variables
    l_people_group_id               number ;
    l_establishment_id              number;
    l_fr_emp_category               varchar2(1000);
    l_special_ceiling_step_id       number;
    l_group_name                    varchar2(1000);
    l_org_now_no_manager_warning    boolean;
    l_spp_delete_warning            boolean;
    l_entries_changed_warning       varchar2(1000);
    l_tax_district_changed_warning  boolean;

  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_affecations';

-- Cursors to Fetch all primary assignment's People group Segements, the same will be passed
-- to the secondary assingment.


 cursor common_info_csr is
 Select people_group_id, establishment_id , scl.segment10 FrEmpCategory,assignment_id
        ,object_version_number,normal_hours
          from per_all_assignments_f asg, hr_soft_coding_keyflex scl
          where person_id = p_person_id
          and scl.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
          and p_effective_date between effective_start_date and effective_end_date
          and primary_flag ='Y';
-- Note : CAGR_GRADE_DEF_ID is not used, assuming that will not be used by the customer, as the functionality is not delivered.

 Cursor earlier_affect_det_csr IS
 Select segment27 PrimayAffectation
 from per_all_assignments_f asg, hr_soft_coding_keyflex scl
 where assignment_id = p_assignment_id
 and scl.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
 and p_effective_date between effective_start_date and effective_end_date;



 l_j_id number;
 l_p_id number;
  l_normal_hours per_all_assignments_f.normal_hours%type;
Begin

  hr_utility.set_location(' Entering:' || l_proc,10);
   --

   -- Issue a savepoint
   --
   savepoint create_secondary_emp_asg_swi;

   --
   -- Remember IN OUT parameter IN values
   --
   l_soft_coding_keyflex_id        := p_soft_coding_keyflex_id;
   --
   -- Register Surrogate ID or user key values
   --
   per_asg_ins.set_base_key_value
     (p_assignment_id => p_assignment_id
     );
   --
   -- Call API
   --

   -- Fetch common values from Primary assignment
    Open common_info_csr;
      fetch common_info_csr into l_people_group_id,l_establishment_id,
                                l_fr_emp_category,l_admin_career_id,
                                l_p_asg_ovn,l_normal_hours;

    Close common_info_csr;

    Open earlier_affect_det_csr;
    --
       Fetch earlier_affect_det_csr into l_old_primary_affectation;
    --
    Close earlier_affect_det_csr;



    /*
     Priamary Affecation Value Can be in the following ways
     Earlier         Current           Action
     Y                 Y                1. Update Primary Assignment with Position, Job , org
                                        2. Update Affecation with Remaining Details

     N                 N                1. Update Affecation with complete details

     N                 Y                1. Check are there any Primary affecations in the System, If so Throw an error
                                           Saying effective affectation is already exist, Else Similar to first case

     Y                 N                1. Update the Primary assignment by removing Job and  Position
                                        2. Update Affecation with Other details + Position + Job

    Earlier Value: Retrieve from assignments table for the affection id
    Current Value: Value which is passed from UI

    */

    If (l_old_primary_affectation is null) then
    -- Creating Affectation for the first time, <=> there are no affecations earlier
    --
    l_old_primary_affectation := 'N';
    --
    End if;



    hr_utility.set_location(' Primary Affectation Old :'||l_old_primary_affectation||'New '||p_primary_affectation,10);

    pqh_fr_assignment_chk.chk_percent_affected(p_percent_effected,p_person_id,p_effective_date,p_assignment_id);
    pqh_fr_assignment_chk.chk_position(p_position_id,p_person_id,p_effective_date);
    pqh_fr_assignment_chk.chk_type(p_affectation_type,p_person_id,p_effective_date,p_position_id);

      l_normal_hours := l_normal_hours * p_percent_effected/100;

  If (l_old_primary_affectation='Y' and p_primary_affectation = 'Y') Then
  --
     If (pqh_fr_utility.is_worker_cwk(p_person_id,p_effective_date)) Then
     --

      hr_assignment_api.update_cwk_asg_criteria
      (
      p_validate                     => p_validate
     ,p_effective_date               => p_effective_date
     ,p_datetrack_update_mode        => p_datetrack_update_mode
     ,p_assignment_id                => p_assignment_id
     ,p_organization_id              => p_organization_id
     ,p_position_id                  => null
     ,p_job_id                       => p_job_id
    -- Out Variables
    ,p_people_group_id              => l_people_group_id
    ,p_object_version_number        => p_object_version_number -- In OUT
    ,p_people_group_name                      => l_group_name
    ,p_effective_start_date            => p_effective_start_date
    ,p_effective_end_date              => p_effective_end_date
    ,p_org_now_no_manager_warning      => l_org_now_no_manager_warning
    ,p_other_manager_warning           => l_other_manager_warning
    ,p_spp_delete_warning              => l_spp_delete_warning
    ,p_entries_changed_warning         => l_entries_changed_warning
    ,p_tax_district_changed_warning    => l_tax_district_changed_warning);

    hr_assignment_api.update_cwk_asg(
       p_validate                     => p_validate
      ,p_effective_date               => p_effective_date
      ,p_datetrack_update_mode        => pqh_fr_utility.get_DateTrack_Mode(p_effective_date,'PER_ALL_ASSIGNMENTS_F','ASSIGNMENT_ID',p_assignment_id)
      ,p_assignment_id                => p_assignment_id
      ,p_object_version_number        => p_object_version_number
      ,p_normal_hours                 => l_normal_hours

      ,p_supervisor_id                => p_supervisor_id
      ,p_assignment_number            => p_assignment_number
   --   ,p_assignment_status_type_id    => p_assignment_status_type_id

      ,p_establishment_id            => l_establishment_id
      ,p_scl_segment23        	    => p_identifier
      ,p_scl_segment24        	    => p_affectation_type
      ,p_scl_segment25        	    => p_percent_effected
      ,p_scl_segment26        	    => l_admin_career_id
      ,p_scl_segment27        	    => p_primary_affectation
      ,p_scl_segment2               => 'CIVIL'
      ,p_scl_segment10              => l_fr_emp_category

    -- Following are Out Parameters
      ,p_concatenated_segments        => l_concatenated_segments
      ,p_soft_coding_keyflex_id       => p_soft_coding_keyflex_id
      ,p_comment_id                   => l_comment_id
      ,p_effective_start_date         => p_effective_start_date
      ,p_effective_end_date           => p_effective_end_date
      ,p_no_managers_warning          => l_other_manager_warning
      ,p_other_manager_warning        => l_other_manager_warning2
      ,p_org_now_no_manager_warning   => l_other_manager_warning2
      ,p_hourly_salaried_warning      => l_other_manager_warning2   );

    ElsIf (pqh_fr_utility.is_worker_employee(p_person_id,p_effective_date)) Then

   --
       hr_assignment_api.update_emp_asg_criteria
      (
      p_validate                     => p_validate
     ,p_effective_date               => p_effective_date
     ,p_datetrack_update_mode        => p_datetrack_update_mode
     ,p_assignment_id                => p_assignment_id
     ,p_organization_id              => p_organization_id
     ,p_position_id                  => null
     ,p_job_id                       => p_job_id
    -- Out Variables
    ,p_people_group_id              => l_people_group_id
    ,p_object_version_number        => p_object_version_number -- In OUT
    ,p_special_ceiling_step_id      => l_special_ceiling_step_id
    ,p_group_name                      => l_group_name
    ,p_effective_start_date            => p_effective_start_date
    ,p_effective_end_date              => p_effective_end_date
    ,p_org_now_no_manager_warning      => l_org_now_no_manager_warning
    ,p_other_manager_warning           => l_other_manager_warning
    ,p_spp_delete_warning              => l_spp_delete_warning
    ,p_entries_changed_warning         => l_entries_changed_warning
    ,p_tax_district_changed_warning    => l_tax_district_changed_warning);

    hr_assignment_api.update_emp_asg(
       p_validate                     => p_validate
      ,p_effective_date               => p_effective_date
      ,p_datetrack_update_mode        => pqh_fr_utility.get_DateTrack_Mode(p_effective_date,'PER_ALL_ASSIGNMENTS_F','ASSIGNMENT_ID',p_assignment_id)
      ,p_assignment_id                => p_assignment_id
      ,p_object_version_number        => p_object_version_number
      ,p_normal_hours                => l_normal_hours

      ,p_supervisor_id                => p_supervisor_id
      ,p_assignment_number            => p_assignment_number
      ,p_assignment_status_type_id    => p_assignment_status_type_id

      ,p_establishment_id            => l_establishment_id
      ,p_segment23        	    => p_identifier
      ,p_segment24        	    => p_affectation_type
      ,p_segment25        	    => p_percent_effected
      ,p_segment26        	    => l_admin_career_id
      ,p_segment27        	    => p_primary_affectation
      ,p_segment2               => 'CIVIL'
      ,p_segment10              => l_fr_emp_category

    -- Following are Out Parameters
     ,p_cagr_grade_def_id            => l_cagr_grade_def_id
      ,p_cagr_concatenated_segments   => l_cagr_concatenated_segments
      ,p_concatenated_segments        => l_concatenated_segments
      ,p_soft_coding_keyflex_id       => p_soft_coding_keyflex_id
      ,p_comment_id                   => l_comment_id
      ,p_effective_start_date         => p_effective_start_date
      ,p_effective_end_date           => p_effective_end_date
      ,p_no_managers_warning          => l_other_manager_warning
      ,p_other_manager_warning        => l_other_manager_warning2  );
    --  Employee Completed
    End if;

  -- If above updates are successful then update the primary assignment with affectation
  -- detais

      update_primary_asg_affectation
      (
        p_validate              => p_validate,
        p_assignment_id         => l_admin_career_id,
        p_effective_date        => p_effective_date,
        p_primary_affectation   => p_primary_affectation,
        p_organization_id       => p_organization_id,
        p_job_id                => p_job_id,
        p_position_id           => p_position_id,
        p_datetrack_update_mode => pqh_fr_utility.get_DateTrack_Mode(p_effective_date,'PER_ALL_ASSIGNMENTS_F','ASSIGNMENT_ID',l_admin_career_id),
        p_object_version_number => l_p_asg_ovn,
        p_person_id             => p_person_id,
     	p_supervisor_id         => p_supervisor_id
      ) ;

  ElsIf (l_old_primary_affectation='N' and p_primary_affectation = 'N') Then
  --
    If (pqh_fr_utility.is_worker_employee(p_person_id,p_effective_date)) Then
    --
    hr_utility.set_location('In condition when an no chages in primary affectation value assignment_id N ', 10);

     hr_assignment_api.update_emp_asg_criteria
      (
      p_validate                     => p_validate
     ,p_effective_date               => p_effective_date
     ,p_datetrack_update_mode        => p_datetrack_update_mode
     ,p_assignment_id                => p_assignment_id
     ,p_organization_id              => p_organization_id
     ,p_position_id                  => p_position_id
     ,p_job_id                       => p_job_id
    -- Out Variables
    ,p_people_group_id              => l_people_group_id
    ,p_object_version_number        => p_object_version_number -- In OUT
    ,p_special_ceiling_step_id      => l_special_ceiling_step_id
    ,p_group_name                      => l_group_name
    ,p_effective_start_date            => p_effective_start_date
    ,p_effective_end_date              => p_effective_end_date
    ,p_org_now_no_manager_warning      => l_org_now_no_manager_warning
    ,p_other_manager_warning           => l_other_manager_warning
    ,p_spp_delete_warning              => l_spp_delete_warning
    ,p_entries_changed_warning         => l_entries_changed_warning
    ,p_tax_district_changed_warning    => l_tax_district_changed_warning);

    hr_assignment_api.update_emp_asg(
       p_validate                     => p_validate
      ,p_effective_date               => p_effective_date
      ,p_datetrack_update_mode        => pqh_fr_utility.get_DateTrack_Mode(p_effective_date,'PER_ALL_ASSIGNMENTS_F','ASSIGNMENT_ID',p_assignment_id)
      ,p_assignment_id                => p_assignment_id
      ,p_object_version_number        => p_object_version_number
      ,p_normal_hours                 => l_normal_hours
      ,p_supervisor_id                => p_supervisor_id
      ,p_assignment_number            => p_assignment_number
      ,p_assignment_status_type_id    => p_assignment_status_type_id

      ,p_establishment_id            => l_establishment_id
      ,p_segment23        	    => p_identifier
      ,p_segment24        	    => p_affectation_type
      ,p_segment25        	    => p_percent_effected
      ,p_segment26        	    => l_admin_career_id
      ,p_segment27        	    => p_primary_affectation
      ,p_segment2               => 'CIVIL'
      ,p_segment10              => l_fr_emp_category

    -- Following are Out Parameters
     ,p_cagr_grade_def_id            => l_cagr_grade_def_id
      ,p_cagr_concatenated_segments   => l_cagr_concatenated_segments
      ,p_concatenated_segments        => l_concatenated_segments
      ,p_soft_coding_keyflex_id       => p_soft_coding_keyflex_id
      ,p_comment_id                   => l_comment_id
      ,p_effective_start_date         => p_effective_start_date
      ,p_effective_end_date           => p_effective_end_date
      ,p_no_managers_warning          => l_other_manager_warning
      ,p_other_manager_warning        => l_other_manager_warning2  );
    --
    ElsIf pqh_fr_utility.is_worker_cwk(p_person_id,p_effective_date) then
    ---

      hr_assignment_api.update_cwk_asg_criteria
      (
      p_validate                     => p_validate
     ,p_effective_date               => p_effective_date
     ,p_datetrack_update_mode        => p_datetrack_update_mode
     ,p_assignment_id                => p_assignment_id
     ,p_organization_id              => p_organization_id
     ,p_position_id                  => p_position_id
     ,p_job_id                       => p_job_id
    -- Out Variables
   ,p_people_group_id              => l_people_group_id
    ,p_object_version_number        => p_object_version_number -- In OUT
    ,p_people_group_name                      => l_group_name
    ,p_effective_start_date            => p_effective_start_date
    ,p_effective_end_date              => p_effective_end_date
    ,p_org_now_no_manager_warning      => l_org_now_no_manager_warning
    ,p_other_manager_warning           => l_other_manager_warning
    ,p_spp_delete_warning              => l_spp_delete_warning
    ,p_entries_changed_warning         => l_entries_changed_warning
    ,p_tax_district_changed_warning    => l_tax_district_changed_warning);


    hr_assignment_api.update_cwk_asg(
       p_validate                     => p_validate
      ,p_effective_date               => p_effective_date
      ,p_datetrack_update_mode        => pqh_fr_utility.get_DateTrack_Mode(p_effective_date,'PER_ALL_ASSIGNMENTS_F','ASSIGNMENT_ID',p_assignment_id)
      ,p_assignment_id                => p_assignment_id
      ,p_object_version_number        => p_object_version_number
      ,p_normal_hours                 => l_normal_hours

      ,p_supervisor_id                => p_supervisor_id
      ,p_assignment_number            => p_assignment_number
    --  ,p_assignment_status_type_id    => p_assignment_status_type_id

      ,p_establishment_id            => l_establishment_id
      ,p_scl_segment23        	    => p_identifier
      ,p_scl_segment24        	    => p_affectation_type
      ,p_scl_segment25        	    => p_percent_effected
      ,p_scl_segment26        	    => l_admin_career_id
      ,p_scl_segment27        	    => p_primary_affectation
      ,p_scl_segment2               => 'CIVIL'
      ,p_scl_segment10              => l_fr_emp_category

    -- Following are Out Parameters
       ,p_concatenated_segments        => l_concatenated_segments
      ,p_soft_coding_keyflex_id       => p_soft_coding_keyflex_id
      ,p_comment_id                   => l_comment_id
      ,p_effective_start_date         => p_effective_start_date
      ,p_effective_end_date           => p_effective_end_date
      ,p_no_managers_warning          => l_other_manager_warning
      ,p_other_manager_warning        => l_other_manager_warning2
      ,p_org_now_no_manager_warning   => l_other_manager_warning2
      ,p_hourly_salaried_warning      => l_other_manager_warning2   );


    ---
    End If;

  ElsIf (l_old_primary_affectation='N' and p_primary_affectation = 'Y') Then

  --
     PQH_FR_ASSIGNMENT_CHK.chk_primary_affectation(p_person_id, p_effective_date,l_admin_career_id);

     If  pqh_fr_utility.is_worker_employee(p_person_id,p_effective_date) Then
     --
      hr_assignment_api.update_emp_asg_criteria
      (
      p_validate                     => p_validate
     ,p_effective_date               => p_effective_date
     ,p_datetrack_update_mode        => p_datetrack_update_mode
     ,p_assignment_id                => p_assignment_id
     ,p_organization_id              => p_organization_id
     ,p_position_id                  => null
     ,p_job_id                       => p_job_id
    -- Out Variables
    ,p_people_group_id              => l_people_group_id
    ,p_object_version_number        => p_object_version_number -- In OUT
    ,p_special_ceiling_step_id      => l_special_ceiling_step_id
    ,p_group_name                      => l_group_name
    ,p_effective_start_date            => p_effective_start_date
    ,p_effective_end_date              => p_effective_end_date
    ,p_org_now_no_manager_warning      => l_org_now_no_manager_warning
    ,p_other_manager_warning           => l_other_manager_warning
    ,p_spp_delete_warning              => l_spp_delete_warning
    ,p_entries_changed_warning         => l_entries_changed_warning
    ,p_tax_district_changed_warning    => l_tax_district_changed_warning);

    hr_assignment_api.update_emp_asg(
       p_validate                     => p_validate
      ,p_effective_date               => p_effective_date
      ,p_datetrack_update_mode        => pqh_fr_utility.get_DateTrack_Mode(p_effective_date,'PER_ALL_ASSIGNMENTS_F','ASSIGNMENT_ID',p_assignment_id)
      ,p_assignment_id                => p_assignment_id
      ,p_object_version_number        => p_object_version_number
      ,p_normal_hours                 => l_normal_hours

      ,p_supervisor_id                => p_supervisor_id
      ,p_assignment_number            => p_assignment_number
      ,p_assignment_status_type_id    => p_assignment_status_type_id

      ,p_establishment_id            => l_establishment_id
      ,p_segment23        	    => p_identifier
      ,p_segment24        	    => p_affectation_type
      ,p_segment25        	    => p_percent_effected
      ,p_segment26        	    => l_admin_career_id
      ,p_segment27        	    => p_primary_affectation
      ,p_segment2               => 'CIVIL'
      ,p_segment10              => l_fr_emp_category

    -- Following are Out Parameters
     ,p_cagr_grade_def_id            => l_cagr_grade_def_id
      ,p_cagr_concatenated_segments   => l_cagr_concatenated_segments
      ,p_concatenated_segments        => l_concatenated_segments
      ,p_soft_coding_keyflex_id       => p_soft_coding_keyflex_id
      ,p_comment_id                   => l_comment_id
      ,p_effective_start_date         => p_effective_start_date
      ,p_effective_end_date           => p_effective_end_date
      ,p_no_managers_warning          => l_other_manager_warning
      ,p_other_manager_warning        => l_other_manager_warning2  );

      --
      ElsIf  pqh_fr_utility.is_worker_cwk(p_person_id,p_effective_date) Then
      --

      hr_assignment_api.update_cwk_asg_criteria
      (
      p_validate                     => p_validate
     ,p_effective_date               => p_effective_date
     ,p_datetrack_update_mode        => p_datetrack_update_mode
     ,p_assignment_id                => p_assignment_id
     ,p_organization_id              => p_organization_id
     ,p_position_id                  => null
     ,p_job_id                       => p_job_id
    -- Out Variables
   ,p_people_group_id              => l_people_group_id
    ,p_object_version_number        => p_object_version_number -- In OUT
    ,p_people_group_name                      => l_group_name
    ,p_effective_start_date            => p_effective_start_date
    ,p_effective_end_date              => p_effective_end_date
    ,p_org_now_no_manager_warning      => l_org_now_no_manager_warning
    ,p_other_manager_warning           => l_other_manager_warning
    ,p_spp_delete_warning              => l_spp_delete_warning
    ,p_entries_changed_warning         => l_entries_changed_warning
    ,p_tax_district_changed_warning    => l_tax_district_changed_warning);

    hr_assignment_api.update_cwk_asg(
       p_validate                     => p_validate
      ,p_effective_date               => p_effective_date
      ,p_datetrack_update_mode        => pqh_fr_utility.get_DateTrack_Mode(p_effective_date,'PER_ALL_ASSIGNMENTS_F','ASSIGNMENT_ID',p_assignment_id)
      ,p_assignment_id                => p_assignment_id
      ,p_object_version_number        => p_object_version_number
      ,p_supervisor_id                => p_supervisor_id
      ,p_assignment_number            => p_assignment_number
      ,p_establishment_id            => l_establishment_id
      ,p_normal_hours                 => l_normal_hours

      ,p_scl_segment23        	    => p_identifier
      ,p_scl_segment24        	    => p_affectation_type
      ,p_scl_segment25        	    => p_percent_effected
      ,p_scl_segment26        	    => l_admin_career_id
      ,p_scl_segment27        	    => p_primary_affectation
      ,p_scl_segment2               => 'CIVIL'
      ,p_scl_segment10              => l_fr_emp_category

    -- Following are Out Parameters
      ,p_concatenated_segments        => l_concatenated_segments
      ,p_soft_coding_keyflex_id       => p_soft_coding_keyflex_id
      ,p_comment_id                   => l_comment_id
      ,p_effective_start_date         => p_effective_start_date
      ,p_effective_end_date           => p_effective_end_date
      ,p_no_managers_warning          => l_other_manager_warning
      ,p_other_manager_warning        => l_other_manager_warning2
      ,p_org_now_no_manager_warning   => l_other_manager_warning2
      ,p_hourly_salaried_warning      => l_other_manager_warning2   );



      --
      End If;



  -- If above updates are successful then update the primary assignment with affectation
  -- detais

      update_primary_asg_affectation
      (
        p_validate              => p_validate,
        p_assignment_id         => l_admin_career_id,
        p_effective_date        => p_effective_date,
        p_primary_affectation   => p_primary_affectation,
        p_organization_id       => p_organization_id,
        p_job_id                => p_job_id,
        p_position_id           => p_position_id,
        p_datetrack_update_mode => pqh_fr_utility.get_DateTrack_Mode(p_effective_date,'PER_ALL_ASSIGNMENTS_F','ASSIGNMENT_ID',l_admin_career_id),
        p_object_version_number => l_p_asg_ovn,
        p_person_id             => p_person_id,
	p_supervisor_id         => p_supervisor_id
      ) ;
     --
  ElsIf(l_old_primary_affectation='Y' and p_primary_affectation = 'N') Then
  --

        update_primary_asg_affectation
      (
        p_validate              => p_validate,
        p_assignment_id         => l_admin_career_id,
        p_effective_date        => p_effective_date,
        p_primary_affectation   => l_old_primary_affectation,
        p_organization_id       => p_organization_id,
        p_job_id                => p_job_id,
        p_position_id           => null,
        p_datetrack_update_mode => pqh_fr_utility.get_DateTrack_Mode(p_effective_date,'PER_ALL_ASSIGNMENTS_F','ASSIGNMENT_ID',l_admin_career_id),
        p_object_version_number => l_p_asg_ovn,
        p_person_id             => p_person_id,
	p_supervisor_id         => p_supervisor_id
      ) ;

     If (pqh_fr_utility.is_worker_employee(p_person_id,p_effective_date)) then
     --
     hr_assignment_api.update_emp_asg_criteria
      (
      p_validate                     => p_validate
     ,p_effective_date               => p_effective_date
     ,p_datetrack_update_mode        => p_datetrack_update_mode
     ,p_assignment_id                => p_assignment_id
     ,p_organization_id              => p_organization_id
     ,p_position_id                  => p_position_id
     ,p_job_id                       => p_job_id
    -- Out Variables
    ,p_people_group_id              => l_people_group_id
    ,p_object_version_number        => p_object_version_number -- In OUT
    ,p_special_ceiling_step_id      => l_special_ceiling_step_id
    ,p_group_name                      => l_group_name
    ,p_effective_start_date            => p_effective_start_date
    ,p_effective_end_date              => p_effective_end_date
    ,p_org_now_no_manager_warning      => l_org_now_no_manager_warning
    ,p_other_manager_warning           => l_other_manager_warning
    ,p_spp_delete_warning              => l_spp_delete_warning
    ,p_entries_changed_warning         => l_entries_changed_warning
    ,p_tax_district_changed_warning    => l_tax_district_changed_warning);

    hr_assignment_api.update_emp_asg(
       p_validate                     => p_validate
      ,p_effective_date               => p_effective_date
      ,p_datetrack_update_mode        => pqh_fr_utility.get_DateTrack_Mode(p_effective_date,'PER_ALL_ASSIGNMENTS_F','ASSIGNMENT_ID',p_assignment_id)
      ,p_assignment_id                => p_assignment_id
      ,p_object_version_number        => p_object_version_number
      ,p_normal_hours                 => l_normal_hours

      ,p_supervisor_id                => p_supervisor_id
      ,p_assignment_number            => p_assignment_number
      ,p_assignment_status_type_id    => p_assignment_status_type_id

      ,p_establishment_id            => l_establishment_id
      ,p_segment23        	    => p_identifier
      ,p_segment24        	    => p_affectation_type
      ,p_segment25        	    => p_percent_effected
      ,p_segment26        	    => l_admin_career_id
      ,p_segment27        	    => p_primary_affectation
      ,p_segment2               => 'CIVIL'
      ,p_segment10              => l_fr_emp_category

    -- Following are Out Parameters
     ,p_cagr_grade_def_id            => l_cagr_grade_def_id
      ,p_cagr_concatenated_segments   => l_cagr_concatenated_segments
      ,p_concatenated_segments        => l_concatenated_segments
      ,p_soft_coding_keyflex_id       => p_soft_coding_keyflex_id
      ,p_comment_id                   => l_comment_id
      ,p_effective_start_date         => p_effective_start_date
      ,p_effective_end_date           => p_effective_end_date
      ,p_no_managers_warning          => l_other_manager_warning
      ,p_other_manager_warning        => l_other_manager_warning2  );
    --
    ElsIf pqh_fr_utility.is_worker_cwk(p_person_id,p_effective_date) Then
    --
       hr_assignment_api.update_cwk_asg_criteria
      (
      p_validate                     => p_validate
     ,p_effective_date               => p_effective_date
     ,p_datetrack_update_mode        => p_datetrack_update_mode
     ,p_assignment_id                => p_assignment_id
     ,p_organization_id              => p_organization_id
     ,p_position_id                  => p_position_id
     ,p_job_id                       => p_job_id
    -- Out Variables
    ,p_people_group_id              => l_people_group_id
    ,p_object_version_number        => p_object_version_number -- In OUT
    ,p_people_group_name                      => l_group_name
    ,p_effective_start_date            => p_effective_start_date
    ,p_effective_end_date              => p_effective_end_date
    ,p_org_now_no_manager_warning      => l_org_now_no_manager_warning
    ,p_other_manager_warning           => l_other_manager_warning
    ,p_spp_delete_warning              => l_spp_delete_warning
    ,p_entries_changed_warning         => l_entries_changed_warning
    ,p_tax_district_changed_warning    => l_tax_district_changed_warning);

      hr_assignment_api.update_cwk_asg(
       p_validate                     => p_validate
      ,p_effective_date               => p_effective_date
      ,p_datetrack_update_mode        => pqh_fr_utility.get_DateTrack_Mode(p_effective_date,'PER_ALL_ASSIGNMENTS_F','ASSIGNMENT_ID',p_assignment_id)
      ,p_assignment_id                => p_assignment_id
      ,p_object_version_number        => p_object_version_number
      ,p_normal_hours                 => l_normal_hours

      ,p_supervisor_id                => p_supervisor_id
      ,p_assignment_number            => p_assignment_number
      ,p_establishment_id            => l_establishment_id
      ,p_scl_segment23        	    => p_identifier
      ,p_scl_segment24        	    => p_affectation_type
      ,p_scl_segment25        	    => p_percent_effected
      ,p_scl_segment26        	    => l_admin_career_id
      ,p_scl_segment27        	    => p_primary_affectation
      ,p_scl_segment2               => 'CIVIL'
      ,p_scl_segment10              => l_fr_emp_category

    -- Following are Out Parameters
      ,p_concatenated_segments        => l_concatenated_segments
      ,p_soft_coding_keyflex_id       => p_soft_coding_keyflex_id
      ,p_comment_id                   => l_comment_id
      ,p_effective_start_date         => p_effective_start_date
      ,p_effective_end_date           => p_effective_end_date
      ,p_no_managers_warning          => l_other_manager_warning
      ,p_other_manager_warning        => l_other_manager_warning2
      ,p_org_now_no_manager_warning   => l_other_manager_warning2
      ,p_hourly_salaried_warning      => l_other_manager_warning2   );

    --
    End if;

  -- If above updates are successful then update the primary assignment with affectation
  -- detais


  ---
  End if;

  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  hr_utility.set_location(' Leaving:' || l_proc,20);


end update_affectation;
--
-- Employment Terms Update Routine
--
  PROCEDURE update_employment_terms
  (p_validate               IN            BOOLEAN  DEFAULT FALSE
  ,p_datetrack_update_mode  IN            VARCHAR2
  ,p_effective_date         IN            DATE
  ,p_assignment_id          IN            NUMBER
  ,p_establishment_id       IN            NUMBER
  ,p_comments               IN            VARCHAR2
  ,p_assignment_category    IN            VARCHAR2
  ,p_reason_for_parttime    IN            VARCHAR2
  ,p_working_hours_share    IN            VARCHAR2
  ,p_contract_id            IN            NUMBER
  ,p_change_reason          IN            VARCHAR2
  ,p_normal_hours           IN            NUMBER
  ,p_frequency              IN            VARCHAR2
  ,p_soft_coding_keyflex_id    OUT NOCOPY NUMBER
  ,p_object_version_number  IN OUT NOCOPY NUMBER
  ,p_effective_start_date      OUT NOCOPY DATE
  ,p_effective_end_date        OUT NOCOPY DATE
  ,p_assignment_sequence       OUT NOCOPY NUMBER
  )
  IS
  --
  --Cursor to fetch Current Assignment
    CURSOR csr_asg_information IS
    SELECT asg.assignment_type, ast.per_system_status
      FROM per_all_assignments_f       asg,
           per_assignment_status_types ast
     WHERE asg.assignment_id             = p_assignment_id
       AND p_effective_date        BETWEEN asg.effective_start_date AND asg.effective_end_date
       AND asg.assignment_status_type_id = ast.assignment_status_type_id;
  --
  --Cursor to fetch assignment values to be updated.
    CURSOR csr_update_admin_career(p_effective_end_date  DATE
                                  ,p_employment_category VARCHAR2
                                  ,p_contract_id         NUMBER
                                  ,p_reason_for_parttime VARCHAR2
                                  ,p_comments            VARCHAR2) IS
    SELECT asg.assignment_id,
           asg.object_version_number,
           asg.soft_coding_keyflex_id,
           asg.grade_ladder_pgm_id,
           asg.grade_id,
           scl.segment10 "Employee Category",
           asg.effective_start_date,
           asg.effective_end_date,
           'ET',
           asg.employment_category,
           asg.contract_id,
           asg.establishment_id,
           scl.segment9 "Working Hours Share",
           scl.segment19 "Reason For Part",
           scl.segment20 "Comments"
      FROM per_all_assignments_f  asg,
           hr_soft_coding_keyflex scl
     WHERE asg.assignment_id                                  = p_assignment_id
       AND asg.soft_coding_keyflex_id                         = scl.soft_coding_keyflex_id (+)
       AND asg.effective_start_date                          >= p_effective_end_date
       AND NVL(asg.employment_category,p_employment_category) = p_employment_category
       AND NVL(asg.contract_id,p_contract_id)                 = p_contract_id
       AND NVL(asg.establishment_id,p_establishment_id)       = p_establishment_id
       AND NVL(scl.segment9,p_working_hours_share)            = p_working_hours_share
       AND NVL(scl.segment19,p_reason_for_parttime)           = p_reason_for_parttime
       AND NVL(scl.segment20,p_comments)                      = p_comments;
  --
  --Cursor to fetch Working Hours from Corps for Fonctionaire else from Estab Info for Non Titulaires.
    CURSOR csr_normal_working_hour IS
    SELECT normal_hours hours, normal_hours_frequency frequency
      FROM pqh_corps_definitions
     WHERE ben_pgm_id = (SELECT grade_ladder_pgm_id
                           FROM per_all_assignments_f
                          WHERE assignment_id = p_assignment_id
                            AND p_effective_date BETWEEN effective_start_date AND effective_end_date)
    UNION
    SELECT fnd_number.canonical_to_number (org_information4) hours, 'M' frequency
      FROM hr_organization_information_v
     WHERE org_information_context = 'FR_ESTAB_INFO'
       AND organization_id = p_establishment_id;
  --
  --Variable Declaration
    l_asg_type                      VARCHAR2(10);
    l_asg_status                    VARCHAR2(30);
    l_rec_wrk_type                  csr_normal_working_hour%ROWTYPE;
    l_frequency                     VARCHAR2(30);
    l_wrk_hours                     NUMBER;
    l_validate                      BOOLEAN;
    l_no_managers_warning           BOOLEAN;
    l_other_manager_warning         BOOLEAN;
    l_other_manager_warning2        BOOLEAN;
    l_hourly_salaried_warning       BOOLEAN;
    l_soft_coding_keyflex_id        NUMBER;
    l_cagr_grade_def_id             NUMBER;
    l_cagr_concatenated_segments    VARCHAR2(1000);
    l_concatenated_segments         VARCHAR2(1000);
    l_comment_id                    NUMBER;
    l_effective_start_date          DATE;
    l_effective_end_date            DATE;
    l_ovn                           NUMBER;
    l_datetrack_mode                VARCHAR2(100);
  --Variables for IN/OUT parameters
    l_object_version_number         NUMBER;
    l_assignment_id                 NUMBER;
    l_admin_career_id               NUMBER;
  --Common info variables
    l_people_group_id               NUMBER;
    l_establishment_id              NUMBER;
    l_fr_emp_category               VARCHAR2(1000);
    l_special_ceiling_step_id       NUMBER;
    l_group_name                    VARCHAR2(1000);
    l_org_now_no_manager_warning    BOOLEAN;
    l_spp_delete_warning            BOOLEAN;
    l_entries_changed_warning       VARCHAR2(1000);
    l_tax_district_changed_warning  BOOLEAN;
  --
  BEGIN
  --
    OPEN csr_asg_information;
    FETCH csr_asg_information INTO l_asg_type, l_asg_status;
    CLOSE csr_asg_information;
    IF UPPER(l_asg_status) NOT LIKE '%ACTIVE%' THEN
       FND_MESSAGE.set_name('PQH','FR_PQH_NO_EMPLOYTERM_UPDT');
       FND_MESSAGE.raise_error;
    END IF;

    OPEN csr_normal_working_hour;
    FETCH csr_normal_working_hour INTO l_rec_wrk_type;
    CLOSE csr_normal_working_hour;
  --
  --Logic for calculating the workign hours.
    l_frequency := NULL;
    l_wrk_hours := NULL;
    IF l_rec_wrk_type.hours IS NOT NULL AND p_assignment_category <> 'IT' THEN
       l_wrk_hours := ROUND((l_rec_wrk_type.hours*p_working_hours_share)/100,3);
       l_frequency := l_rec_wrk_type.frequency;
    ELSE
       l_wrk_hours := p_normal_hours;
       l_frequency := p_frequency;
    END IF;
  --
/*
  Mappings
  update_emp_asg_criteria
  -p_employment_category -> p_assignment_category

  update_emp_asg
  -p_establishment_id
  -p_comments - scl.20
  -p_reason_for_parttime - scl.19
  -p_working_hours_share - scl.9
  -p_contract_id
  -p_change_reason
*/
  --
    IF l_asg_type = 'E' THEN
     --Employee Assignment
       hr_assignment_api.update_emp_asg_criteria
         (p_validate                     => p_validate
         ,p_effective_date               => p_effective_date
         ,p_datetrack_update_mode        => p_datetrack_update_mode
         ,p_assignment_id                => p_assignment_id
         ,p_employment_category          => p_assignment_category
        --Out Variables
         ,p_people_group_id              => l_people_group_id
         ,p_object_version_number        => p_object_version_number -- IN OUT
         ,p_special_ceiling_step_id      => l_special_ceiling_step_id
         ,p_group_name                   => l_group_name
         ,p_effective_start_date         => p_effective_start_date
         ,p_effective_end_date           => p_effective_end_date
         ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
         ,p_other_manager_warning        => l_other_manager_warning
         ,p_spp_delete_warning           => l_spp_delete_warning
         ,p_entries_changed_warning      => l_entries_changed_warning
         ,p_tax_district_changed_warning => l_tax_district_changed_warning);
     --
       l_datetrack_mode := pqh_fr_utility.get_DateTrack_Mode(p_effective_date,'PER_ALL_ASSIGNMENTS_F','ASSIGNMENT_ID',p_assignment_id);
     --
       hr_assignment_api.update_emp_asg
         (p_validate                   => p_validate
         ,p_effective_date             => p_effective_date
         ,p_datetrack_update_mode      => l_datetrack_mode
         ,p_assignment_id              => p_assignment_id
         ,p_object_version_number      => p_object_version_number
         ,p_segment17                  => p_change_reason
         ,p_contract_id                => p_contract_id
         ,p_establishment_id           => p_establishment_id
         ,p_segment20                  => p_comments
         ,p_segment19                  => p_reason_for_parttime
         ,p_segment9                   => p_working_hours_share
         ,p_normal_hours               => l_wrk_hours
         ,p_frequency                  => l_frequency
         ,p_segment2                   => 'CIVIL'
        --Following are Out Parameters
         ,p_cagr_grade_def_id          => l_cagr_grade_def_id
         ,p_cagr_concatenated_segments => l_cagr_concatenated_segments
         ,p_concatenated_segments      => l_concatenated_segments
         ,p_soft_coding_keyflex_id     => p_soft_coding_keyflex_id
         ,p_comment_id                 => l_comment_id
         ,p_effective_start_date       => p_effective_start_date
         ,p_effective_end_date         => p_effective_end_date
         ,p_no_managers_warning        => l_other_manager_warning
         ,p_other_manager_warning      => l_other_manager_warning2  );
      /*
        If Employment Terms record is updated will have to keep the Career Information
        record in Sync with Employment Terms record: Steps as follows
        1. Find the all Assignment records whose effective start date > the p_effective_end_date
        2. For all those assignment records compare career details with current rec career detial
           If It matches update Employment Terms Information for those records
      */
       hr_utility.set_location(' Before Loop ' , 10);
     --
       FOR l_asg_rec in csr_update_admin_career(p_effective_end_date,p_assignment_category,-1
                                               ,NVL(p_reason_for_parttime,-1),NVL(p_comments,-1))
       LOOP
         --
           l_ovn := l_asg_rec.object_version_number;
           hr_assignment_api.update_emp_asg_criteria
             (p_validate                     => p_validate
             ,p_effective_date               => l_asg_rec.effective_start_date
             ,p_datetrack_update_mode        => 'CORRECTION'
             ,p_assignment_id                => l_asg_rec.assignment_id
             ,p_employment_category          => p_assignment_category
            --Out Variables
             ,p_people_group_id              => l_people_group_id
             ,p_object_version_number        => l_ovn -- In OUT
             ,p_special_ceiling_step_id      => l_special_ceiling_step_id
             ,p_group_name                   => l_group_name
             ,p_effective_start_date         => p_effective_start_date
             ,p_effective_end_date           => p_effective_end_date
             ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
             ,p_other_manager_warning        => l_other_manager_warning
             ,p_spp_delete_warning           => l_spp_delete_warning
             ,p_entries_changed_warning      => l_entries_changed_warning
             ,p_tax_district_changed_warning => l_tax_district_changed_warning);
         --
           l_datetrack_mode := 'CORRECTION';
         --
           hr_assignment_api.update_emp_asg
             (p_validate                   => p_validate
             ,p_effective_date             => l_asg_rec.effective_start_date
             ,p_datetrack_update_mode      => l_datetrack_mode
             ,p_assignment_id              => l_asg_rec.assignment_id
             ,p_object_version_number      => l_ovn
             ,p_segment17                  => p_change_reason
             ,p_contract_id                => p_contract_id
             ,p_establishment_id           => p_establishment_id
             ,p_segment20                  => p_comments
             ,p_segment19                  => p_reason_for_parttime
             ,p_segment9                   => p_working_hours_share
             ,p_normal_hours               => l_wrk_hours
             ,p_frequency                  => l_frequency
             ,p_segment2                   => 'CIVIL'
            --Out Parameters
             ,p_cagr_grade_def_id          => l_cagr_grade_def_id
             ,p_cagr_concatenated_segments => l_cagr_concatenated_segments
             ,p_concatenated_segments      => l_concatenated_segments
             ,p_soft_coding_keyflex_id     => p_soft_coding_keyflex_id
             ,p_comment_id                 => l_comment_id
             ,p_effective_start_date       => p_effective_start_date
             ,p_effective_end_date         => p_effective_end_date
             ,p_no_managers_warning        => l_other_manager_warning
             ,p_other_manager_warning      => l_other_manager_warning2);
         --
       END LOOP;
  --
    ELSIF l_asg_type = 'C' THEN
     --
       hr_assignment_api.update_cwk_asg_criteria
         (p_validate                     => p_validate
         ,p_effective_date               => p_effective_date
         ,p_datetrack_update_mode        => p_datetrack_update_mode
         ,p_assignment_id                => p_assignment_id
       --,p_employment_category          => p_assignment_category
        --Out Variables
         ,p_people_group_id              => l_people_group_id
         ,p_object_version_number        => p_object_version_number -- In OUT
         ,p_people_group_name            => l_group_name
         ,p_effective_start_date         => p_effective_start_date
         ,p_effective_end_date           => p_effective_end_date
         ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
         ,p_other_manager_warning        => l_other_manager_warning
         ,p_spp_delete_warning           => l_spp_delete_warning
         ,p_entries_changed_warning      => l_entries_changed_warning
         ,p_tax_district_changed_warning => l_tax_district_changed_warning);
     --
       hr_assignment_api.update_cwk_asg
         (p_validate                   => p_validate
         ,p_effective_date             => p_effective_date
         ,p_datetrack_update_mode      => p_datetrack_update_mode
         ,p_assignment_id              => p_assignment_id
         ,p_object_version_number      => p_object_version_number
         ,p_change_reason              => p_change_reason
       --,p_contract_id                => p_contract_id
         ,p_establishment_id           => p_establishment_id
         ,p_scl_segment20              => p_comments
         ,p_scl_segment19              => p_reason_for_parttime
         ,p_scl_segment9               => p_working_hours_share
         ,p_normal_hours               => l_wrk_hours
         ,p_frequency                  => l_frequency
         ,p_scl_segment2               => 'CIVIL'
        --Out Parameters
         ,p_concatenated_segments      => l_concatenated_segments
         ,p_soft_coding_keyflex_id     => p_soft_coding_keyflex_id
         ,p_comment_id                 => l_comment_id
         ,p_effective_start_date       => p_effective_start_date
         ,p_effective_end_date         => p_effective_end_date
         ,p_no_managers_warning        => l_other_manager_warning
         ,p_other_manager_warning      => l_other_manager_warning2
         ,p_org_now_no_manager_warning => l_other_manager_warning2
         ,p_hourly_salaried_warning    => l_other_manager_warning2);
     --
    END IF;
  --
  END update_employment_terms;
--
--
   PROCEDURE update_administrative_career (
      p_validate                 IN              BOOLEAN DEFAULT FALSE,
      p_datetrack_update_mode    IN              VARCHAR2,
      p_effective_date           IN              DATE,
      p_assignment_id            IN              NUMBER,
      p_corps_id                 IN              NUMBER,
      p_grade_id                 IN              NUMBER,
      p_step_id                  IN              NUMBER,
      p_progression_speed        IN              VARCHAR2,
      p_personal_gross_index     IN              VARCHAR2,
      p_employee_category        IN              VARCHAR2,
      p_soft_coding_keyflex_id   OUT NOCOPY      NUMBER,
      p_object_version_number    IN OUT NOCOPY   NUMBER,
      p_effective_start_date     OUT NOCOPY      DATE,
      p_effective_end_date       OUT NOCOPY      DATE,
      p_assignment_sequence      OUT NOCOPY      NUMBER
   )
   IS
      l_validate                       BOOLEAN;
      l_no_managers_warning            BOOLEAN;
      l_other_manager_warning          BOOLEAN;
      l_other_manager_warning2         BOOLEAN;
      l_hourly_salaried_warning        BOOLEAN;
      l_soft_coding_keyflex_id         NUMBER;
      l_cagr_grade_def_id              NUMBER;
      l_cagr_concatenated_segments     VARCHAR2 (1000);
      l_concatenated_segments          VARCHAR2 (1000);
      l_comment_id                     NUMBER;
      l_effective_start_date           DATE;
      l_effective_end_date             DATE;
      l_ovn                            NUMBER;
      l_establishment_id               NUMBER         DEFAULT hr_api.g_number;
      l_datetrack_mode                 VARCHAR2 (100);
      l_normal_hours                   NUMBER;
      l_frequency                      VARCHAR2 (30);
      --
      -- Variables for IN/OUT parameters
      l_object_version_number          NUMBER;
      l_assignment_id                  NUMBER;
      l_admin_career_id                NUMBER;
      -- common info variables
      l_people_group_id                NUMBER;
      l_fr_emp_category                VARCHAR2 (1000);
      l_special_ceiling_step_id        NUMBER;
      l_group_name                     VARCHAR2 (1000);
      l_org_now_no_manager_warning     BOOLEAN;
      l_spp_delete_warning             BOOLEAN;
      l_entries_changed_warning        VARCHAR2 (1000);
      l_tax_district_changed_warning   BOOLEAN;

      CURSOR csr_placement_info
      IS
         SELECT placement_id, object_version_number ovn, information3,
                information4, step_id
           FROM per_spinal_point_placements_f
          WHERE assignment_id = p_assignment_id
            AND p_effective_date BETWEEN effective_start_date
                                     AND effective_end_date;

--
      CURSOR csr_asg_information
      IS
         SELECT assignment_type
           FROM per_all_assignments_f
          WHERE assignment_id = p_assignment_id
            AND p_effective_date BETWEEN effective_start_date
                                     AND effective_end_date;

--
      CURSOR csr_get_corps_info
      IS
         SELECT normal_hours, normal_hours_frequency
           FROM pqh_corps_definitions
          WHERE ben_pgm_id = p_corps_id
            AND p_effective_date BETWEEN date_from
                                     AND NVL (date_to, hr_general.end_of_time);

--
      CURSOR csr_old_assign_record
      IS
         SELECT grade_ladder_pgm_id, grade_id, normal_hours, frequency,
                segment10 employee_category
           FROM per_all_assignments_f, hr_soft_coding_keyflex
          WHERE assignment_id = p_assignment_id
            AND p_effective_date BETWEEN effective_start_date
                                     AND effective_end_date
            AND per_all_assignments_f.soft_coding_keyflex_id = hr_soft_coding_keyflex.soft_coding_keyflex_id(+);

--
      CURSOR csr_work_hrs_share IS
      SELECT nvl(scl.segment9,100) work_hour_share,
             nvl(employment_category,'CF') employment_category,
             normal_hours,
             frequency
      FROM   per_all_assignments_f asg,
             hr_soft_coding_keyflex scl
      WHERE asg.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
      AND   assignment_id = p_assignment_id
      AND p_effective_date between effective_start_date and effective_end_date
      AND primary_flag = 'Y';

      lr_old_assign_record             csr_old_assign_record%ROWTYPE;
      placement_record                 csr_placement_info%ROWTYPE;
      l_asg_type                       VARCHAR2 (10);
      l_work_hour_share                 NUMBER;
      l_agreed_normal_hrs               NUMBER;
      l_emp_cat                        VARCHAR2(10);
      l_it_frequency                   VARCHAR2(10);
      -- added for bug 6334604
      l_business_group_id               NUMBER;

   BEGIN
      -- getting the business group id
      l_business_group_id := hr_general.get_business_group_id;
      --
      OPEN csr_asg_information;

      FETCH csr_asg_information
       INTO l_asg_type;

      CLOSE csr_asg_information;

      --
      OPEN csr_get_corps_info;

      FETCH csr_get_corps_info
       INTO l_normal_hours, l_frequency;

      CLOSE csr_get_corps_info;

      --
      OPEN csr_old_assign_record;

      FETCH csr_old_assign_record
       INTO lr_old_assign_record;

      CLOSE csr_old_assign_record;

       OPEN csr_work_hrs_share;

      FETCH csr_work_hrs_share
       INTO l_work_hour_share,l_emp_cat,l_agreed_normal_hrs,l_it_frequency;

      CLOSE csr_work_hrs_share;

      if l_emp_cat <> 'IT' then
          l_normal_hours := (l_normal_hours * l_work_hour_share)/100;
      else
          l_normal_hours := l_agreed_normal_hrs;
          l_frequency := l_it_frequency;
      end if;


      IF (l_asg_type = 'E')
      THEN
         -- Employee Assignment
         IF (   NVL (lr_old_assign_record.grade_ladder_pgm_id, -1) <>
                                                           NVL (p_corps_id,
                                                                -1)
             OR NVL (lr_old_assign_record.grade_id, -1) <> NVL (p_grade_id,
                                                                -1)
            )
         THEN
            hr_assignment_api.update_emp_asg_criteria
               (p_validate                          => p_validate,
                p_effective_date                    => p_effective_date,
                p_datetrack_update_mode             => p_datetrack_update_mode,
                p_assignment_id                     => p_assignment_id,
                p_grade_ladder_pgm_id               => p_corps_id,
                p_grade_id                          => p_grade_id
                                                                 -- Out Variables
            ,
                p_people_group_id                   => l_people_group_id,
                p_object_version_number             => p_object_version_number
                                                                     -- In OUT
                                                                              ,
                p_special_ceiling_step_id           => l_special_ceiling_step_id,
                p_group_name                        => l_group_name,
                p_effective_start_date              => p_effective_start_date,
                p_effective_end_date                => p_effective_end_date,
                p_org_now_no_manager_warning        => l_org_now_no_manager_warning,
                p_other_manager_warning             => l_other_manager_warning,
                p_spp_delete_warning                => l_spp_delete_warning,
                p_entries_changed_warning           => l_entries_changed_warning,
                p_tax_district_changed_warning      => l_tax_district_changed_warning
               );
         END IF;

         l_datetrack_mode :=
            pqh_fr_utility.get_datetrack_mode (p_effective_date,
                                               'PER_ALL_ASSIGNMENTS_F',
                                               'ASSIGNMENT_ID',
                                               p_assignment_id
                                              );

         IF (   NVL (lr_old_assign_record.normal_hours, -1) <>
                                                       NVL (l_normal_hours,
                                                            -1)
             OR NVL (lr_old_assign_record.frequency, hr_api.g_varchar2) <>
                                          NVL (l_frequency, hr_api.g_varchar2)
             OR NVL (lr_old_assign_record.employee_category,
                     hr_api.g_varchar2) <>
                                  NVL (p_employee_category, hr_api.g_varchar2)
            )
         THEN
            hr_assignment_api.update_emp_asg
               (p_validate                        => p_validate,
                p_effective_date                  => p_effective_date,
                p_datetrack_update_mode           => l_datetrack_mode,
                p_assignment_id                   => p_assignment_id,
                p_object_version_number           => p_object_version_number,
                p_segment10                       => p_employee_category,
                p_segment2                        => 'CIVIL',
                p_normal_hours                    => l_normal_hours,
                p_frequency                       => l_frequency
                                                                -- Following are Out Parameters
            ,
                p_cagr_grade_def_id               => l_cagr_grade_def_id,
                p_cagr_concatenated_segments      => l_cagr_concatenated_segments,
                p_concatenated_segments           => l_concatenated_segments,
                p_soft_coding_keyflex_id          => p_soft_coding_keyflex_id,
                p_comment_id                      => l_comment_id,
                p_effective_start_date            => p_effective_start_date,
                p_effective_end_date              => p_effective_end_date,
                p_no_managers_warning             => l_other_manager_warning,
                p_other_manager_warning           => l_other_manager_warning2
               );
         END IF;
      --
      ELSIF l_asg_type = 'C'
      THEN
         -- CWK Worker
         IF (NVL (lr_old_assign_record.employee_category, hr_api.g_varchar2) <>
                                  NVL (p_employee_category, hr_api.g_varchar2)
            )
         THEN
            hr_assignment_api.update_cwk_asg
                   (p_validate                        => p_validate,
                    p_effective_date                  => p_effective_date,
                    p_datetrack_update_mode           => p_datetrack_update_mode,
                    p_assignment_id                   => p_assignment_id,
                    p_object_version_number           => p_object_version_number,
                    p_scl_segment10                   => p_employee_category,
                    p_scl_segment2                    => 'CIVIL',
                    p_establishment_id                => l_establishment_id
                                                                           -- Following are Out Parameters
            ,
                    p_concatenated_segments           => l_concatenated_segments,
                    p_soft_coding_keyflex_id          => p_soft_coding_keyflex_id,
                    p_comment_id                      => l_comment_id,
                    p_effective_start_date            => p_effective_start_date,
                    p_effective_end_date              => p_effective_end_date,
                    p_no_managers_warning             => l_other_manager_warning,
                    p_other_manager_warning           => l_other_manager_warning2,
                    p_org_now_no_manager_warning      => l_other_manager_warning2,
                    p_hourly_salaried_warning         => l_other_manager_warning2
                   );
            hr_assignment_api.update_cwk_asg_criteria
               (p_validate                          => p_validate,
                p_effective_date                    => p_effective_date,
                p_datetrack_update_mode             => p_datetrack_update_mode,
                p_assignment_id                     => p_assignment_id
                                                                      -- Out Variables
            ,
                p_people_group_id                   => l_people_group_id,
                p_object_version_number             => p_object_version_number
                                                                     -- In OUT
                                                                              ,
                p_people_group_name                 => l_group_name,
                p_effective_start_date              => p_effective_start_date,
                p_effective_end_date                => p_effective_end_date,
                p_org_now_no_manager_warning        => l_org_now_no_manager_warning,
                p_other_manager_warning             => l_other_manager_warning,
                p_spp_delete_warning                => l_spp_delete_warning,
                p_entries_changed_warning           => l_entries_changed_warning,
                p_tax_district_changed_warning      => l_tax_district_changed_warning
               );
         END IF;
      -- Update cwk_asg
      END IF;

/*

    hr_sp_placement_api.update_spp(
       p_validate                     => p_validate
      ,p_effective_date               => p_effective_date
      ,p_datetrack_update_mode        => p_datetrack_update_mode
      ,p_object_version_number        => p_object_version_number
      ,p_placement_id                 => p_object_version_number
      ,p_information2                 => p_personal_gross_index
      ,p_effective_start_date         => p_effective_start_date
      ,p_effective_end_date           => p_effective_end_date);
*/
      OPEN csr_placement_info;

      FETCH csr_placement_info
       INTO placement_record;

      CLOSE csr_placement_info;

      --Modified condition below. Added p_step IS NOT NULL by deenath 12/13/04
      IF p_step_id IS NOT NULL AND placement_record.placement_id IS NOT NULL
--      IF placement_record.placement_id IS NOT NULL
      THEN
         l_datetrack_mode :=
            pqh_fr_utility.get_datetrack_mode
                                            (p_effective_date,
                                             'PER_SPINAL_POINT_PLACEMENTS_F',
                                             'PLACEMENT_ID',
                                             placement_record.placement_id
                                            );

         IF (   NVL (placement_record.information3, hr_api.g_varchar2) <>
                                  NVL (p_progression_speed, hr_api.g_varchar2)
             OR NVL (placement_record.information4, hr_api.g_varchar2) <>
                               NVL (p_personal_gross_index, hr_api.g_varchar2)
             OR NVL (placement_record.step_id, -1) <> NVL (p_step_id, -1)
            )
         THEN
            hr_sp_placement_api.update_spp
                           (p_effective_date             => p_effective_date,
                            p_placement_id               => placement_record.placement_id,
                            p_object_version_number      => placement_record.ovn,
                            p_datetrack_mode             => l_datetrack_mode,
                            p_effective_start_date       => p_effective_start_date,
                            p_effective_end_date         => p_effective_end_date,
                            p_validate                   => p_validate,
                            p_information3               => p_progression_speed,
                            p_information4               => p_personal_gross_index,
                            p_step_id                    => p_step_id
                           );
         END IF;
      END IF;
      --Replaced ELSE clause with below IF Condition - deenath 12/13/04.
      IF p_step_id IS NOT NULL AND placement_record.placement_id IS NULL THEN
        -- replaced function with variable l_business_group_id
        -- for bug 6334604
         hr_sp_placement_api.create_spp
                    (p_effective_date             => p_effective_date,
                     p_validate                   => p_validate,
                     p_information3               => p_progression_speed,
                     p_information4               => p_personal_gross_index,
                     p_step_id                    => p_step_id,
                     p_assignment_id              => p_assignment_id,
                     p_business_group_id          => l_business_group_id,
                     p_placement_id               => placement_record.placement_id,
                     p_object_version_number      => p_object_version_number,
                     p_effective_start_date       => p_effective_start_date,
                     p_effective_end_date         => p_effective_end_date
                    );
      END IF;
   END update_administrative_career;

procedure terminate_affectation
  (p_validate                     in     boolean
  ,p_assignment_id                in     number
  ,p_effective_date               in     date
  ,p_assignment_status_type_id    in     number
  ,p_primary_affectation          in     varchar2 default 'N'
  ,p_group_name                   out nocopy varchar2
  ,p_object_version_number        in out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  )
  IS

  l_validate                      boolean;
  l_no_managers_warning           boolean;
  l_other_manager_warning         boolean;
  l_hourly_salaried_warning       boolean;
  l_soft_coding_keyflex_id        number;
  l_cagr_grade_def_id             number;
  l_cagr_concatenated_segments    varchar2(1000);
  l_concatenated_segments         varchar2(1000);
  l_comment_id                    number;
  l_position_id                   number;
  l_frequency                     varchar2(30);
  l_p_normal_hours                number;
  l_business_group_id             number;
  l_person_id                   number;
   l_asg_future_changes_warning      boolean;
  l_entries_changed_warning         varchar2(2000);
  l_pay_proposal_warning            boolean;


  --
  -- Variables for IN/OUT parameters
  l_obj_ver_no                    number;
  l_object_version_number         number;
  l_assignment_id                number;

  -- common info variables
    l_people_group_id               number ;
    l_establishment_id              number;
    l_fr_emp_category               varchar2(1000);
    l_admin_career_id               number;
    l_p_asg_ovn                     number;
    l_organization_id                 number;
     l_job_id                         number;



  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'terminate_affectation';
  l_temp                          varchar2(10);

-- Cursors to Fetch all primary assignment's People group Segements, the same will be passed
-- to the secondary assingment.


cursor info_admin_career_id is
 Select  person_id,  scl.segment26 admin_career_id, object_version_number
          from per_all_assignments_f asg, hr_soft_coding_keyflex scl
          where assignment_id = p_assignment_id
          and scl.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
          and p_effective_date between effective_start_date and effective_end_date;

cursor common_info_csr (p_person_id in number)is
Select people_group_id, establishment_id , scl.segment10 FrEmpCategory,
          assignment_id,object_version_number,normal_hours,frequency,business_group_id,
          organization_id, job_id, position_id
          from per_all_assignments_f asg, hr_soft_coding_keyflex scl
          where person_id = p_person_id
          and scl.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
          and p_effective_date between effective_start_date and effective_end_date
          and primary_flag ='Y';


-- Note : CAGR_GRADE_DEF_ID is not used, assuming that will not be used by the customer, as the functionality is not delivered.
--
l_identifier varchar2(30);

Begin

  hr_utility.set_location(' Entering:' || l_proc,10);
  hr_utility.set_location(' Parameters' || l_proc,10);
  hr_utility.set_location(' p_assignment_status_type_id:' || p_assignment_status_type_id,10);
  hr_utility.set_location(' p_primary_affectation:' || p_primary_affectation,10);

   --

   -- Issue a savepoint
   --
   savepoint terminate_sec_emp_asg_swi;

   --
   -- Remember IN OUT parameter IN values
   --
   l_soft_coding_keyflex_id        := null;
   --
   -- Register Surrogate ID or user key values
   --
   --
   -- Call API
   --

   -- Fetch common values from Primary assignment
    Open info_admin_career_id;
      fetch info_admin_career_id into l_person_id,l_admin_career_id,l_obj_ver_no;
    Close info_admin_career_id;

    Open common_info_csr(l_person_id);
      fetch common_info_csr into l_people_group_id,l_establishment_id,
                            l_fr_emp_category,l_admin_career_id,l_p_asg_ovn,l_p_normal_hours,l_frequency,l_business_group_id,
                            l_organization_id, l_job_id, l_position_id;
    Close common_info_csr;



    -- Create Affectation : If Affectation is a Primary, then donot pass Position
    -- instead position will be updated on the assignment by using l_admin_career_id = assignment_id
    -- on primary assignment
    -- else Position details will be copied to Affecation details
    --

 If (pqh_fr_utility.is_worker_employee(l_person_id,p_effective_date)) Then
   --
     hr_assignment_api.actual_termination_emp_asg(
       p_validate                     => p_validate
      ,p_assignment_id               => p_assignment_id
      ,p_actual_termination_date      => p_effective_date
      ,p_assignment_status_type_id    => p_assignment_status_type_id

   -- Following are Out Parameters
   ,p_object_version_number          => l_obj_ver_no
   ,p_effective_start_date           => p_effective_start_date
   ,p_effective_end_date             => p_effective_end_date
   ,p_asg_future_changes_warning     => l_asg_future_changes_warning
    ,p_entries_changed_warning       => l_entries_changed_warning
  ,p_pay_proposal_warning            => l_pay_proposal_warning
    );
   --
  ElsIf (pqh_fr_utility.is_worker_cwk(l_person_id,p_effective_date)) Then
  --
    hr_assignment_api.actual_termination_cwk_asg(
       p_validate                     => p_validate
      ,p_assignment_id               => p_assignment_id
      ,p_actual_termination_date      => p_effective_date
      ,p_assignment_status_type_id    => p_assignment_status_type_id

   -- Following are Out Parameters

   ,p_object_version_number          => l_obj_ver_no
   ,p_effective_start_date           => p_effective_start_date
   ,p_effective_end_date             => p_effective_end_date
   ,p_asg_future_changes_warning     => l_asg_future_changes_warning
    ,p_entries_changed_warning       => l_entries_changed_warning
  ,p_pay_proposal_warning            => l_pay_proposal_warning
    );
  --
  End if;


  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  update_primary_asg_affectation
      (
        p_validate              => p_validate,
        p_assignment_id         => l_admin_career_id,
        p_effective_date        => p_effective_date,
        p_primary_affectation   => p_primary_affectation,
        p_organization_id       => l_organization_id,
        p_job_id                => l_job_id,
        p_position_id           => NULL,
        p_datetrack_update_mode => pqh_fr_utility.get_DateTrack_Mode(p_effective_date,'PER_ALL_ASSIGNMENTS_F','ASSIGNMENT_ID',l_admin_career_id),
        p_object_version_number => l_p_asg_ovn,
        p_person_id             => l_person_id
      ) ;

  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
End terminate_affectation;

procedure suspend_affectation
  (p_validate                     in     boolean
  ,p_assignment_id                in     number
  ,p_effective_date               in     date
  ,p_assignment_status_type_id    in     number
  ,p_object_version_number        in out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  )
  IS

  l_validate                      boolean;
  l_soft_coding_keyflex_id        number;
  l_cagr_grade_def_id             number;
  l_cagr_concatenated_segments    varchar2(1000);
  l_concatenated_segments         varchar2(1000);
  l_comment_id                    number;
  l_position_id                   number;
  l_frequency                     varchar2(30);
  l_p_normal_hours                number;
  l_business_group_id             number;
  l_person_id                   number;

  --
  -- Variables for IN/OUT parameters
  l_obj_ver_no                    number;
  l_assignment_id                number;

  -- common info variables
    l_fr_emp_category               varchar2(1000);
    l_admin_career_id               number;
    l_p_asg_ovn                     number;
    l_organization_id                 number;
     l_job_id                         number;



  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'suspend_affectation';
  l_temp                          varchar2(10);

-- Cursors to Fetch all primary assignment's People group Segements, the same will be passed
-- to the secondary assingment.


cursor info_admin_career_id is
 Select  person_id,  scl.segment26 admin_career_id, object_version_number
          from per_all_assignments_f asg, hr_soft_coding_keyflex scl
          where assignment_id = p_assignment_id
          and scl.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
          and p_effective_date between effective_start_date and effective_end_date;


-- Note : CAGR_GRADE_DEF_ID is not used, assuming that will not be used by the customer, as the functionality is not delivered.
--
l_identifier varchar2(30);

Begin

  hr_utility.set_location(' Entering:' || l_proc,10);
  hr_utility.set_location(' Parameters' || l_proc,10);
  hr_utility.set_location(' p_assignment_status_type_id:' || p_assignment_status_type_id,10);


   --

   -- Issue a savepoint
   --
   savepoint suspend_sec_emp_asg_swi;

   --
   -- Remember IN OUT parameter IN values
   --
   l_soft_coding_keyflex_id        := null;
   --
   -- Register Surrogate ID or user key values
   --
   --
   -- Call API
   --

   -- Fetch common values from Primary assignment
    Open info_admin_career_id;
      fetch info_admin_career_id into l_person_id,l_admin_career_id,l_obj_ver_no;
    Close info_admin_career_id;

/*    Open common_info_csr(l_person_id);
      fetch common_info_csr into l_people_group_id,l_establishment_id,
                            l_fr_emp_category,l_admin_career_id,l_p_asg_ovn,l_p_normal_hours,l_frequency,l_business_group_id,
                            l_organization_id, l_job_id, l_position_id;
    Close common_info_csr;*/


 If (pqh_fr_utility.is_worker_employee(l_person_id,p_effective_date)) Then
   --
     hr_assignment_api.suspend_emp_asg(
     p_validate                     => p_validate
    ,p_assignment_id               => p_assignment_id
    ,p_effective_date      => p_effective_date
    ,p_assignment_status_type_id    => p_assignment_status_type_id
    ,p_datetrack_update_mode   => pqh_fr_utility.get_datetrack_mode(p_effective_date  => p_effective_date
                                                     ,p_base_table_name => 'PER_ALL_ASSIGNMENTS_F'
                                                     ,p_base_key_column => 'ASSIGNMENT_ID'
                                                     ,p_base_key_value  => p_assignment_id)
   -- Following are Out Parameters
   ,p_object_version_number          => l_obj_ver_no
   ,p_effective_start_date           => p_effective_start_date
   ,p_effective_end_date             => p_effective_end_date
       );
   --
  ElsIf (pqh_fr_utility.is_worker_cwk(l_person_id,p_effective_date)) Then
  --
    hr_assignment_api.suspend_cwk_asg(
       p_validate                     => p_validate
      ,p_assignment_id               => p_assignment_id
      ,p_effective_date      => p_effective_date
      ,p_assignment_status_type_id    => p_assignment_status_type_id
      ,p_datetrack_update_mode   => pqh_fr_utility.get_datetrack_mode(p_effective_date  => p_effective_date
                                                     ,p_base_table_name => 'PER_ALL_ASSIGNMENTS_F'
                                                     ,p_base_key_column => 'ASSIGNMENT_ID'
                                                     ,p_base_key_value  => p_assignment_id)
   -- Following are Out Parameters
   ,p_object_version_number          => l_obj_ver_no
   ,p_effective_start_date           => p_effective_start_date
   ,p_effective_end_date             => p_effective_end_date
    );
  --
  End if;


  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --

  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
End suspend_affectation;

procedure activate_affectation
  (p_validate                     in     boolean
  ,p_assignment_id                in     number
  ,p_effective_date               in     date
  ,p_assignment_status_type_id    in     number
  ,p_object_version_number        in out nocopy number
  ,p_effective_start_date            out nocopy date
  ,p_effective_end_date              out nocopy date
  )
  IS

  l_validate                      boolean;
  l_soft_coding_keyflex_id        number;
  l_cagr_grade_def_id             number;
  l_cagr_concatenated_segments    varchar2(1000);
  l_concatenated_segments         varchar2(1000);
  l_comment_id                    number;
  l_position_id                   number;
  l_frequency                     varchar2(30);
  l_p_normal_hours                number;
  l_business_group_id             number;
  l_person_id                   number;

  --
  -- Variables for IN/OUT parameters
  l_obj_ver_no                    number;
  l_assignment_id                number;

  -- common info variables
    l_fr_emp_category               varchar2(1000);
    l_admin_career_id               number;
    l_p_asg_ovn                     number;
    l_organization_id                 number;
     l_job_id                         number;



  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'activate_affectation';
  l_temp                          varchar2(10);

-- Cursors to Fetch all primary assignment's People group Segements, the same will be passed
-- to the secondary assingment.

cursor info_admin_career_id is
 Select  person_id,  scl.segment26 admin_career_id, object_version_number
          from per_all_assignments_f asg, hr_soft_coding_keyflex scl
          where assignment_id = p_assignment_id
          and scl.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
          and p_effective_date between effective_start_date and effective_end_date;


Cursor assign_percent_affected is
Select nvl(scl.segment25,0) Percenteffected
       From  per_all_assignments_f assign,
             hr_soft_coding_keyflex scl
       Where person_id = l_person_id
       And assign.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
       And assign.primary_flag = 'N'
       And  p_effective_date Between effective_start_date And effective_end_date
       And assign.assignment_status_type_id = 2
       And assign.assignment_id = p_assignment_id;



l_identifier varchar2(30);
l_percent_affected varchar2(30);

Begin

  hr_utility.set_location(' Entering:' || l_proc,10);
  hr_utility.set_location(' Parameters' || l_proc,10);
  hr_utility.set_location(' p_assignment_status_type_id:' || p_assignment_status_type_id,10);


   --

   -- Issue a savepoint
   --
   savepoint activate_sec_emp_asg_swi;

   --
   -- Remember IN OUT parameter IN values
   --
   l_soft_coding_keyflex_id        := null;
   --
   -- Register Surrogate ID or user key values
   --
   --
   -- Call API
   --

   -- Fetch common values from assignment
    Open info_admin_career_id;
      fetch info_admin_career_id into l_person_id,l_admin_career_id,l_obj_ver_no;
    Close info_admin_career_id;



   Open assign_percent_affected ;
      fetch assign_percent_affected into l_percent_affected;
    Close assign_percent_affected;

   pqh_fr_assignment_chk.chk_situation(l_person_id,p_effective_date);
   pqh_fr_assignment_chk.chk_percent_affected(l_percent_affected, l_person_id, p_effective_date);


 If (pqh_fr_utility.is_worker_employee(l_person_id,p_effective_date)) Then
   --
     hr_assignment_api.activate_emp_asg(
     p_validate                     => p_validate
    ,p_assignment_id               => p_assignment_id
    ,p_effective_date      => p_effective_date
    ,p_assignment_status_type_id    => p_assignment_status_type_id
    ,p_datetrack_update_mode   => pqh_fr_utility.get_datetrack_mode(p_effective_date  => p_effective_date
                                                     ,p_base_table_name => 'PER_ALL_ASSIGNMENTS_F'
                                                     ,p_base_key_column => 'ASSIGNMENT_ID'
                                                     ,p_base_key_value  => p_assignment_id)
   -- Following are Out Parameters
   ,p_object_version_number          => l_obj_ver_no
   ,p_effective_start_date           => p_effective_start_date
   ,p_effective_end_date             => p_effective_end_date
       );
   --
  ElsIf (pqh_fr_utility.is_worker_cwk(l_person_id,p_effective_date)) Then
  --
    hr_assignment_api.activate_cwk_asg(
       p_validate                     => p_validate
      ,p_assignment_id               => p_assignment_id
      ,p_effective_date      => p_effective_date
      ,p_assignment_status_type_id    => p_assignment_status_type_id
      ,p_datetrack_update_mode   => pqh_fr_utility.get_datetrack_mode(p_effective_date  => p_effective_date
                                                     ,p_base_table_name => 'PER_ALL_ASSIGNMENTS_F'
                                                     ,p_base_key_column => 'ASSIGNMENT_ID'
                                                     ,p_base_key_value  => p_assignment_id)
   -- Following are Out Parameters
   ,p_object_version_number          => l_obj_ver_no
   ,p_effective_start_date           => p_effective_start_date
   ,p_effective_end_date             => p_effective_end_date
    );
  --
  End if;


  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --

  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
End activate_affectation;
  --
end pqh_fr_assignment_api;

/
