--------------------------------------------------------
--  DDL for Package Body GHR_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_API" AS
/* $Header: ghapiapi.pkb 120.10.12010000.3 2009/02/01 12:00:59 vmididho ship $ */
--
--  Private Record Type
--
  type org_info_rec_type is record
	(information1   hr_organization_information.org_information1%type
	,information2   hr_organization_information.org_information2%type
	,information3   hr_organization_information.org_information3%type
	,information4   hr_organization_information.org_information4%type
	,information5   hr_organization_information.org_information5%type
	);
--
--  Private Cursors
--
  cursor c_asg_pos_by_per_id (per_id number, eff_date date) is
	select asg.position_id
	  from per_all_assignments_f asg
	 where asg.person_id = per_id
           and asg.assignment_type <> 'B'
	   and trunc(eff_date) between asg.effective_start_date
				   and asg.effective_end_date
	   and asg.primary_flag = 'Y';
  --
  cursor c_asg_pos_by_asg_id (asg_id number, eff_date date) is
	select asg.position_id
	  from per_all_assignments_f asg
	 where asg.assignment_id = asg_id
           and asg.assignment_type <> 'B'
	   and trunc(eff_date) between asg.effective_start_date
				   and asg.effective_end_date;
  --
  cursor c_asg_job_by_per_id (per_id number, eff_date date) is
	select asg.job_id
	  from per_all_assignments_f asg
	 where asg.person_id = per_id
           and asg.assignment_type <> 'B'
	   and trunc(eff_date) between asg.effective_start_date
				   and asg.effective_end_date
	   and asg.primary_flag = 'Y';
  --
  cursor c_asg_job_by_asg_id (asg_id number, eff_date date) is
	select asg.job_id
	  from per_all_assignments_f asg
	 where asg.assignment_id = asg_id
           and asg.assignment_type <> 'B'
	   and trunc(eff_date) between asg.effective_start_date
				   and asg.effective_end_date;

 --
  Cursor c_per_type(per_id number,eff_date date) is
        Select ppt.system_person_type
        from   per_all_people_f per,per_person_types ppt
        where  per.person_id      =  per_id
        and    trunc(eff_date) between per.effective_start_date
                               and     per.effective_end_date
        and    per.person_type_id = ppt.person_type_id;
--
-- ---------------------------------------------------------------------------
-- |--------------------< retrieve_business_group_id >-----------------------|
-- ---------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   Retrieve business group id
--
-- Prerequisites:
--   Either p_person_id or p_assignment_id must be provided.
--
-- In Parameters:
--   p_person_id
--     The default is NULL.
--   p_assignment_id
--     The default is NULL.
--   p_effective_date
--     The default is sysdate.
--
-- out Parameters:
--   p_business_group_id
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error will be raised and processing is terminated.
--
-- Developer Implementation Notes:
--   Calling hr_utility procedures are commented out to these procedures
--   update the database which violates the function requirement.
--
-- Access Status:
--   Internal Use Only.
--
-- {End of Comments}
-- ---------------------------------------------------------------------------
--
procedure retrieve_business_group_id
	(p_person_id         in     per_people_f.person_id%type          default null
	,p_assignment_id     in     per_assignments_f.assignment_id%type default null
	,p_effective_date    in     date                                 default sysdate
	,p_business_group_id    OUT NOCOPY per_business_groups.business_group_id%type
	) is
  --
  l_proc                varchar2(72) := g_package||'retrieve_business_group_id';
  l_person_found        boolean := FALSE;
  l_assignment_found    boolean := FALSE;
  l_person_type         per_person_types.system_person_type%type;
  --
  cursor c_person (per_id number, eff_date date) is
	select per.business_group_id
	  from per_all_people_f per
	 where per.person_id = per_id
	   and trunc(eff_date) between per.effective_start_date
				   and per.effective_end_date;
  --
  cursor c_assignment (asg_id number, eff_date date) is
	select asg.business_group_id
	  from per_all_assignments_f asg
	 where asg.assignment_id = asg_id
           and asg.assignment_type <> 'B'
	   and trunc(eff_date) between asg.effective_start_date
				   and asg.effective_end_date;
--
begin
  -- hr_utility.set_location('Entering:'||l_proc, 1);
  p_business_group_id := NULL;
  --
  if p_person_id is NULL and p_assignment_id is NULL then
    -- hr_utility.set_message(8301, 'GHR_38037_API_ARG_ERR');
    -- hr_utility.raise_error;
    null;
  elsif p_assignment_id is NULL then
    for per_type in c_per_type(p_person_id,p_effective_date) loop
      l_person_type  :=  per_type.system_person_type;
    end loop;
    If l_person_type = 'EX_EMP' then -- Roh
      null;
    Else
      for c_person_rec in c_person (p_person_id, p_effective_date) loop
        l_person_found := TRUE;
        p_business_group_id := c_person_rec.business_group_id;
        exit;
      end loop;
      if not l_person_found then
        -- hr_utility.set_message(8301, 'GHR_38024_API_INV_PER');
        -- hr_utility.raise_error;
        null;
      end if;
    End if;-- Roh
  else    -- p_assignment_id is not NULL
    for c_assignment_rec in c_assignment (p_assignment_id, p_effective_date) loop
      l_assignment_found := TRUE;
      p_business_group_id := c_assignment_rec.business_group_id;
      exit;
    end loop;
    if not l_assignment_found then
      -- hr_utility.set_message(8301, 'GHR_38023_API_INV_ASG');
      -- hr_utility.raise_error;
      null;
    end if;
  end if;
  --
  -- hr_utility.set_location(' Leaving:'||l_proc, 2);
 EXCEPTION when others then
     -- NOCOPY changes
     -- Reset IN OUT params and set OUT params
        p_business_group_id           := NULL;
        raise;
end retrieve_business_group_id;

-- retrieve_business_group_id overloaded to cater to refresh for the correction of SF52.
-- vsm
procedure retrieve_business_group_id
	(p_person_id         in     per_people_f.person_id%type          default null
	,p_assignment_id     in     per_assignments_f.assignment_id%type default null
	,p_effective_date    in     date                                 default sysdate
      ,p_altered_pa_request_id in number
	,p_pa_history_id     in     number
      ,p_noa_id_corrected      in number
	,p_business_group_id    OUT NOCOPY per_business_groups.business_group_id%type
	) is
  --
   l_result_code        varchar2(30);
   l_people_data        per_all_people_f%rowtype;
   l_assignment_data    per_all_assignments_f%rowtype;
   l_proc               varchar2(72) := g_package||'retrieve_business_group_id';
Begin
	if p_person_id is not null then
		ghr_history_fetch.fetch_people
			( p_person_id             => p_person_id
			 ,p_date_effective        => p_effective_date
 			 ,p_altered_pa_request_id => p_altered_pa_request_id
			 ,p_noa_id_corrected      => p_noa_id_corrected
			 ,p_pa_history_id	        => p_pa_history_id
			 ,p_people_data           => l_people_data
			 ,p_result_code           => l_result_code);
		p_business_group_id := l_people_data.business_group_id;
	elsif p_assignment_id is not null then
		ghr_history_fetch.fetch_assignment
			( p_assignment_id         => p_assignment_id
			 ,p_date_effective        => p_effective_date
 			 ,p_altered_pa_request_id => p_altered_pa_request_id
			 ,p_noa_id_corrected      => p_noa_id_corrected
			 ,p_assignment_data       => l_assignment_data
			 ,p_result_code           => l_result_code);
		p_business_group_id := l_assignment_data.business_group_id;
	end if;
 EXCEPTION when others then
     -- NOCOPY changes
     -- Reset IN OUT params and set OUT params
     p_business_group_id           := NULL;
     raise;

end retrieve_business_group_id;
--

--
-- ---------------------------------------------------------------------------
-- |--------------------< retrieve_gov_kff_setup_info >----------------------|
-- ---------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   Retrieve government key flexfields setup information.
--
-- Prerequisites:
--   Data must be existed in organization information with
--      ORG_INFORMATION = 'GHR_US_ORG_INFORMATION'.
--
-- In Parameters:
--   p_business_group_id
--
-- OUT NOCOPY Parameters:
--   p_org_info_rec
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error will be raised and processing is terminated.
--
-- Developer Implementation Notes:
--   Calling hr_utility procedures are commented OUT NOCOPY due to these procedures
--   update the database which violates the function requirement.
--
-- Access Status:
--   Internal Use Only.
--
-- {End of Comments}
-- ---------------------------------------------------------------------------
procedure retrieve_gov_kff_setup_info
	(p_business_group_id in     per_business_groups.business_group_id%type
	,p_org_info_rec         OUT NOCOPY org_info_rec_type
	) is
  --
  l_proc                varchar2(72) := g_package||'retrieve_gov_kff_setup_info';
  l_org_info_id         hr_organization_information.org_information_id%type;
  l_org_info_found      boolean := FALSE;
  --
  cursor c_organization_information (org_id number) is
	select oi.org_information1,
	       oi.org_information2,
	       oi.org_information3,
	       oi.org_information4,
	       oi.org_information5
	  from hr_organization_information oi
	 where oi.organization_id = org_id
	   and oi.org_information_context = 'GHR_US_ORG_INFORMATION';
--
begin
  -- hr_utility.set_location('Entering:'||l_proc, 1);
  p_org_info_rec.information1 := NULL;
  p_org_info_rec.information2 := NULL;
  p_org_info_rec.information3 := NULL;
  p_org_info_rec.information4 := NULL;
  p_org_info_rec.information5 := NULL;
  --
  for c_organization_information_rec in
		c_organization_information (p_business_group_id) loop
    l_org_info_found := TRUE;
    p_org_info_rec.information1 := c_organization_information_rec.org_information1;
    p_org_info_rec.information2 := c_organization_information_rec.org_information2;
    p_org_info_rec.information3 := c_organization_information_rec.org_information3;
    p_org_info_rec.information4 := c_organization_information_rec.org_information4;
    p_org_info_rec.information5 := c_organization_information_rec.org_information5;
    exit;
  end loop;
  if not l_org_info_found then
    -- hr_utility.set_message(8301, 'GHR_38025_API_INV_ORG');
    -- hr_utility.raise_error;
    null;
  end if;
  -- hr_utility.set_location(l_proc, 2);
  --
  if (p_org_info_rec.information1 is NULL
      and p_org_info_rec.information2 is NULL
      and p_org_info_rec.information3 is NULL
      and p_org_info_rec.information4 is NULL
      and p_org_info_rec.information5 is NULL) then
    -- hr_utility.set_message(8301, 'GHR_38033_API_ORG_DDF_NOT_EXST');
    -- hr_utility.raise_error;
    null;
  end if;
  --
  -- hr_utility.set_location(' Leaving:'||l_proc, 3);
--
exception
  when no_data_found then
    -- hr_utility.set_message(8301, 'GHR_38033_API_ORG_DDF_NOT_EXST');
    -- hr_utility.raise_error;
    null;
 when others then
     -- NOCOPY changes
     -- Reset IN OUT params and set OUT params
     p_org_info_rec           := NULL;
     raise;
end retrieve_gov_kff_setup_info;
--
-- ---------------------------------------------------------------------------
-- |-------------------< retrieve_segment_information >----------------------|
-- ---------------------------------------------------------------------------
-- {Start of Comments}
--
-- Description:
--   Retrieve position/job segment information
--
-- Prerequisites:
--
-- In Parameters:
--   p_information
--   p_code
--     'POS' - Position
--     'JOB' - Job
--
-- OUT NOCOPY Parameters:
--   p_segment
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   An application error will be raised and processing is terminated.
--
-- Developer Implementation Notes:
--   Calling hr_utility procedures are commented OUT NOCOPY due to these procedures
--   update the database which violates the function requirement.
--
-- Access Status:
--   Internal Use Only.
--
-- {End of Comments}
-- ---------------------------------------------------------------------------
procedure retrieve_segment_information
	(p_information          in     varchar2
	,p_id                   in     number
	,p_code                 in     varchar2
        ,p_effective_date       in     date default sysdate
	,p_segment                 OUT NOCOPY varchar2
	) is
  --
  l_proc                varchar2(72) := g_package||'retrieve_segment_information';
  l_segment             varchar2(150);
  l_pos_seg1_found      boolean := FALSE;
  l_pos_seg2_found      boolean := FALSE;
  l_pos_seg3_found      boolean := FALSE;
  l_pos_seg4_found      boolean := FALSE;
  l_pos_seg5_found      boolean := FALSE;
  l_pos_seg6_found      boolean := FALSE;
  l_pos_seg7_found      boolean := FALSE;
  l_pos_seg8_found      boolean := FALSE;
  l_pos_seg9_found      boolean := FALSE;
  l_pos_seg10_found     boolean := FALSE;
  l_pos_seg11_found     boolean := FALSE;
  l_pos_seg12_found     boolean := FALSE;
  l_pos_seg13_found     boolean := FALSE;
  l_pos_seg14_found     boolean := FALSE;
  l_pos_seg15_found     boolean := FALSE;
  l_pos_seg16_found     boolean := FALSE;
  l_pos_seg17_found     boolean := FALSE;
  l_pos_seg18_found     boolean := FALSE;
  l_pos_seg19_found     boolean := FALSE;
  l_pos_seg20_found     boolean := FALSE;
  l_pos_seg21_found     boolean := FALSE;
  l_pos_seg22_found     boolean := FALSE;
  l_pos_seg23_found     boolean := FALSE;
  l_pos_seg24_found     boolean := FALSE;
  l_pos_seg25_found     boolean := FALSE;
  l_pos_seg26_found     boolean := FALSE;
  l_pos_seg27_found     boolean := FALSE;
  l_pos_seg28_found     boolean := FALSE;
  l_pos_seg29_found     boolean := FALSE;
  l_pos_seg30_found     boolean := FALSE;
  l_job_seg1_found      boolean := FALSE;
  l_job_seg2_found      boolean := FALSE;
  l_job_seg3_found      boolean := FALSE;
  l_job_seg4_found      boolean := FALSE;
  l_job_seg5_found      boolean := FALSE;
  l_job_seg6_found      boolean := FALSE;
  l_job_seg7_found      boolean := FALSE;
  l_job_seg8_found      boolean := FALSE;
  l_job_seg9_found      boolean := FALSE;
  l_job_seg10_found     boolean := FALSE;
  l_job_seg11_found     boolean := FALSE;
  l_job_seg12_found     boolean := FALSE;
  l_job_seg13_found     boolean := FALSE;
  l_job_seg14_found     boolean := FALSE;
  l_job_seg15_found     boolean := FALSE;
  l_job_seg16_found     boolean := FALSE;
  l_job_seg17_found     boolean := FALSE;
  l_job_seg18_found     boolean := FALSE;
  l_job_seg19_found     boolean := FALSE;
  l_job_seg20_found     boolean := FALSE;
  l_job_seg21_found     boolean := FALSE;
  l_job_seg22_found     boolean := FALSE;
  l_job_seg23_found     boolean := FALSE;
  l_job_seg24_found     boolean := FALSE;
  l_job_seg25_found     boolean := FALSE;
  l_job_seg26_found     boolean := FALSE;
  l_job_seg27_found     boolean := FALSE;
  l_job_seg28_found     boolean := FALSE;
  l_job_seg29_found     boolean := FALSE;
  l_job_seg30_found     boolean := FALSE;
  --
  --  Private Variables for Dynamic SQL
  --
  -- l_cursor_id           number          := NULL;
  -- l_select_string       varchar2(2000)  := NULL;
  -- l_numrows             integer         := NULL;
  --
  cursor c_pos_seg1 (pos_id number) is
	select pdf.segment1
	  from hr_all_positions_f pos, per_position_definitions pdf
	 where pos.position_definition_id = pdf.position_definition_id
	   and pos.position_id = pos_id
           and p_effective_date between pos.effective_start_date and pos.effective_end_date;
  --
  cursor c_pos_seg2 (pos_id number) is
	select pdf.segment2
	  from hr_all_positions_f pos, per_position_definitions pdf
	 where pos.position_definition_id = pdf.position_definition_id
	   and pos.position_id = pos_id
           and p_effective_date between pos.effective_start_date and pos.effective_end_date;
  --
  cursor c_pos_seg3 (pos_id number) is
	select pdf.segment3
	  from hr_all_positions_f pos, per_position_definitions pdf
	 where pos.position_definition_id = pdf.position_definition_id
	   and pos.position_id = pos_id
           and p_effective_date between pos.effective_start_date and pos.effective_end_date;
  --
  cursor c_pos_seg4 (pos_id number) is
	select pdf.segment4
	  from hr_all_positions_f pos, per_position_definitions pdf
	 where pos.position_definition_id = pdf.position_definition_id
	   and pos.position_id = pos_id
           and p_effective_date between pos.effective_start_date and pos.effective_end_date;
  --
  cursor c_pos_seg5 (pos_id number) is
	select pdf.segment5
	  from hr_all_positions_f pos, per_position_definitions pdf
	 where pos.position_definition_id = pdf.position_definition_id
	   and pos.position_id = pos_id
           and p_effective_date between pos.effective_start_date and pos.effective_end_date;
  --
  cursor c_pos_seg6 (pos_id number) is
	select pdf.segment6
	  from hr_all_positions_f pos, per_position_definitions pdf
	 where pos.position_definition_id = pdf.position_definition_id
	   and pos.position_id = pos_id
           and p_effective_date between pos.effective_start_date and pos.effective_end_date;
  --
  cursor c_pos_seg7 (pos_id number) is
	select pdf.segment7
	  from hr_all_positions_f pos, per_position_definitions pdf
	 where pos.position_definition_id = pdf.position_definition_id
	   and pos.position_id = pos_id
           and p_effective_date between pos.effective_start_date and pos.effective_end_date;
  --
  cursor c_pos_seg8 (pos_id number) is
	select pdf.segment8
	  from hr_all_positions_f pos, per_position_definitions pdf
	 where pos.position_definition_id = pdf.position_definition_id
	   and pos.position_id = pos_id
           and p_effective_date between pos.effective_start_date and pos.effective_end_date;
  --
  cursor c_pos_seg9 (pos_id number) is
	select pdf.segment9
	  from hr_all_positions_f pos, per_position_definitions pdf
	 where pos.position_definition_id = pdf.position_definition_id
	   and pos.position_id = pos_id
           and p_effective_date between pos.effective_start_date and pos.effective_end_date;
  --
  cursor c_pos_seg10 (pos_id number) is
	select pdf.segment10
	  from hr_all_positions_f pos, per_position_definitions pdf
	 where pos.position_definition_id = pdf.position_definition_id
	   and pos.position_id = pos_id
           and p_effective_date between pos.effective_start_date and pos.effective_end_date;
  --
  cursor c_pos_seg11 (pos_id number) is
	select pdf.segment11
	  from hr_all_positions_f pos, per_position_definitions pdf
	 where pos.position_definition_id = pdf.position_definition_id
	   and pos.position_id = pos_id
           and p_effective_date between pos.effective_start_date and pos.effective_end_date;
  --
  cursor c_pos_seg12 (pos_id number) is
	select pdf.segment12
	  from hr_all_positions_f pos, per_position_definitions pdf
	 where pos.position_definition_id = pdf.position_definition_id
	   and pos.position_id = pos_id
           and p_effective_date between pos.effective_start_date and pos.effective_end_date;
  --
  cursor c_pos_seg13 (pos_id number) is
	select pdf.segment13
	  from hr_all_positions_f pos, per_position_definitions pdf
	 where pos.position_definition_id = pdf.position_definition_id
	   and pos.position_id = pos_id
           and p_effective_date between pos.effective_start_date and pos.effective_end_date;
  --
  cursor c_pos_seg14 (pos_id number) is
	select pdf.segment14
	  from hr_all_positions_f pos, per_position_definitions pdf
	 where pos.position_definition_id = pdf.position_definition_id
	   and pos.position_id = pos_id
           and p_effective_date between pos.effective_start_date and pos.effective_end_date;
  --
  cursor c_pos_seg15 (pos_id number) is
	select pdf.segment15
	  from hr_all_positions_f pos, per_position_definitions pdf
	 where pos.position_definition_id = pdf.position_definition_id
	   and pos.position_id = pos_id
           and p_effective_date between pos.effective_start_date and pos.effective_end_date;
  --
  cursor c_pos_seg16 (pos_id number) is
	select pdf.segment16
	  from hr_all_positions_f pos, per_position_definitions pdf
	 where pos.position_definition_id = pdf.position_definition_id
	   and pos.position_id = pos_id
           and p_effective_date between pos.effective_start_date and pos.effective_end_date;
  --
  cursor c_pos_seg17 (pos_id number) is
	select pdf.segment17
	  from hr_all_positions_f pos, per_position_definitions pdf
	 where pos.position_definition_id = pdf.position_definition_id
	   and pos.position_id = pos_id
           and p_effective_date between pos.effective_start_date and pos.effective_end_date;
  --
  cursor c_pos_seg18 (pos_id number) is
	select pdf.segment18
	  from hr_all_positions_f pos, per_position_definitions pdf
	 where pos.position_definition_id = pdf.position_definition_id
	   and pos.position_id = pos_id
           and p_effective_date between pos.effective_start_date and pos.effective_end_date;
  --
  cursor c_pos_seg19 (pos_id number) is
	select pdf.segment19
	  from hr_all_positions_f pos, per_position_definitions pdf
	 where pos.position_definition_id = pdf.position_definition_id
	   and pos.position_id = pos_id
           and p_effective_date between pos.effective_start_date and pos.effective_end_date;
  --
  cursor c_pos_seg20 (pos_id number) is
	select pdf.segment20
	  from hr_all_positions_f pos, per_position_definitions pdf
	 where pos.position_definition_id = pdf.position_definition_id
	   and pos.position_id = pos_id
           and p_effective_date between pos.effective_start_date and pos.effective_end_date;
  --
  cursor c_pos_seg21 (pos_id number) is
	select pdf.segment21
	  from hr_all_positions_f pos, per_position_definitions pdf
	 where pos.position_definition_id = pdf.position_definition_id
	   and pos.position_id = pos_id
           and p_effective_date between pos.effective_start_date and pos.effective_end_date;
  --
  cursor c_pos_seg22 (pos_id number) is
	select pdf.segment22
	  from hr_all_positions_f pos, per_position_definitions pdf
	 where pos.position_definition_id = pdf.position_definition_id
	   and pos.position_id = pos_id
           and p_effective_date between pos.effective_start_date and pos.effective_end_date;
  --
  cursor c_pos_seg23 (pos_id number) is
	select pdf.segment23
	  from hr_all_positions_f pos, per_position_definitions pdf
	 where pos.position_definition_id = pdf.position_definition_id
	   and pos.position_id = pos_id
           and p_effective_date between pos.effective_start_date and pos.effective_end_date;
  --
  cursor c_pos_seg24 (pos_id number) is
	select pdf.segment24
	  from hr_all_positions_f pos, per_position_definitions pdf
	 where pos.position_definition_id = pdf.position_definition_id
	   and pos.position_id = pos_id
           and p_effective_date between pos.effective_start_date and pos.effective_end_date;
  --
  cursor c_pos_seg25 (pos_id number) is
	select pdf.segment25
	  from hr_all_positions_f pos, per_position_definitions pdf
	 where pos.position_definition_id = pdf.position_definition_id
	   and pos.position_id = pos_id
           and p_effective_date between pos.effective_start_date and pos.effective_end_date;
  --
  cursor c_pos_seg26 (pos_id number) is
	select pdf.segment26
	  from hr_all_positions_f pos, per_position_definitions pdf
	 where pos.position_definition_id = pdf.position_definition_id
	   and pos.position_id = pos_id
           and p_effective_date between pos.effective_start_date and pos.effective_end_date;
  --
  cursor c_pos_seg27 (pos_id number) is
	select pdf.segment27
	  from hr_all_positions_f pos, per_position_definitions pdf
	 where pos.position_definition_id = pdf.position_definition_id
	   and pos.position_id = pos_id
           and p_effective_date between pos.effective_start_date and pos.effective_end_date;
  --
  cursor c_pos_seg28 (pos_id number) is
	select pdf.segment28
	  from hr_all_positions_f pos, per_position_definitions pdf
	 where pos.position_definition_id = pdf.position_definition_id
	   and pos.position_id = pos_id
           and p_effective_date between pos.effective_start_date and pos.effective_end_date;
  --
  cursor c_pos_seg29 (pos_id number) is
	select pdf.segment29
	  from hr_all_positions_f pos, per_position_definitions pdf
	 where pos.position_definition_id = pdf.position_definition_id
	   and pos.position_id = pos_id
           and p_effective_date between pos.effective_start_date and pos.effective_end_date;
  --
  cursor c_pos_seg30 (pos_id number) is
	select pdf.segment30
	  from hr_all_positions_f pos, per_position_definitions pdf
	 where pos.position_definition_id = pdf.position_definition_id
	   and pos.position_id = pos_id
           and p_effective_date between pos.effective_start_date and pos.effective_end_date;
  --


  --
  cursor c_job_seg1 (p_job_id number) is
	select jdf.segment1
	  from per_jobs job, per_job_definitions jdf
	 where job.job_definition_id = jdf.job_definition_id
	   and job.job_id = p_job_id;
  --
  cursor c_job_seg2 (p_job_id number) is
	select jdf.segment2
	  from per_jobs job, per_job_definitions jdf
	 where job.job_definition_id = jdf.job_definition_id
	   and job.job_id = p_job_id;
  --
  cursor c_job_seg3 (p_job_id number) is
	select jdf.segment3
	  from per_jobs job, per_job_definitions jdf
	 where job.job_definition_id = jdf.job_definition_id
	   and job.job_id = p_job_id;
  --
  cursor c_job_seg4 (p_job_id number) is
	select jdf.segment4
	  from per_jobs job, per_job_definitions jdf
	 where job.job_definition_id = jdf.job_definition_id
	   and job.job_id = p_job_id;
  --
  cursor c_job_seg5 (p_job_id number) is
	select jdf.segment5
	  from per_jobs job, per_job_definitions jdf
	 where job.job_definition_id = jdf.job_definition_id
	   and job.job_id = p_job_id;
  --
  cursor c_job_seg6 (p_job_id number) is
	select jdf.segment6
	  from per_jobs job, per_job_definitions jdf
	 where job.job_definition_id = jdf.job_definition_id
	   and job.job_id = p_job_id;
  --
  cursor c_job_seg7 (p_job_id number) is
	select jdf.segment7
	  from per_jobs job, per_job_definitions jdf
	 where job.job_definition_id = jdf.job_definition_id
	   and job.job_id = p_job_id;
  --
  cursor c_job_seg8 (p_job_id number) is
	select jdf.segment8
	  from per_jobs job, per_job_definitions jdf
	 where job.job_definition_id = jdf.job_definition_id
	   and job.job_id = p_job_id;
  --
  cursor c_job_seg9 (p_job_id number) is
	select jdf.segment9
	  from per_jobs job, per_job_definitions jdf
	 where job.job_definition_id = jdf.job_definition_id
	   and job.job_id = p_job_id;
  --
  cursor c_job_seg10 (p_job_id number) is
	select jdf.segment10
	  from per_jobs job, per_job_definitions jdf
	 where job.job_definition_id = jdf.job_definition_id
	   and job.job_id = p_job_id;
  --
  cursor c_job_seg11 (p_job_id number) is
	select jdf.segment11
	  from per_jobs job, per_job_definitions jdf
	 where job.job_definition_id = jdf.job_definition_id
	   and job.job_id = p_job_id;
  --
  cursor c_job_seg12 (p_job_id number) is
	select jdf.segment12
	  from per_jobs job, per_job_definitions jdf
	 where job.job_definition_id = jdf.job_definition_id
	   and job.job_id = p_job_id;
  --
  cursor c_job_seg13 (p_job_id number) is
	select jdf.segment13
	  from per_jobs job, per_job_definitions jdf
	 where job.job_definition_id = jdf.job_definition_id
	   and job.job_id = p_job_id;
  --
  cursor c_job_seg14 (p_job_id number) is
	select jdf.segment14
	  from per_jobs job, per_job_definitions jdf
	 where job.job_definition_id = jdf.job_definition_id
	   and job.job_id = p_job_id;
  --
  cursor c_job_seg15 (p_job_id number) is
	select jdf.segment15
	  from per_jobs job, per_job_definitions jdf
	 where job.job_definition_id = jdf.job_definition_id
	   and job.job_id = p_job_id;
  --
  cursor c_job_seg16 (p_job_id number) is
	select jdf.segment16
	  from per_jobs job, per_job_definitions jdf
	 where job.job_definition_id = jdf.job_definition_id
	   and job.job_id = p_job_id;
  --
  cursor c_job_seg17 (p_job_id number) is
	select jdf.segment17
	  from per_jobs job, per_job_definitions jdf
	 where job.job_definition_id = jdf.job_definition_id
	   and job.job_id = p_job_id;
  --
  cursor c_job_seg18 (p_job_id number) is
	select jdf.segment18
	  from per_jobs job, per_job_definitions jdf
	 where job.job_definition_id = jdf.job_definition_id
	   and job.job_id = p_job_id;
  --
  cursor c_job_seg19 (p_job_id number) is
	select jdf.segment19
	  from per_jobs job, per_job_definitions jdf
	 where job.job_definition_id = jdf.job_definition_id
	   and job.job_id = p_job_id;
  --
  cursor c_job_seg20 (p_job_id number) is
	select jdf.segment20
	  from per_jobs job, per_job_definitions jdf
	 where job.job_definition_id = jdf.job_definition_id
	   and job.job_id = p_job_id;
  --
  cursor c_job_seg21 (p_job_id number) is
	select jdf.segment21
	  from per_jobs job, per_job_definitions jdf
	 where job.job_definition_id = jdf.job_definition_id
	   and job.job_id = p_job_id;
  --
  cursor c_job_seg22 (p_job_id number) is
	select jdf.segment22
	  from per_jobs job, per_job_definitions jdf
	 where job.job_definition_id = jdf.job_definition_id
	   and job.job_id = p_job_id;
  --
  cursor c_job_seg23 (p_job_id number) is
	select jdf.segment23
	  from per_jobs job, per_job_definitions jdf
	 where job.job_definition_id = jdf.job_definition_id
	   and job.job_id = p_job_id;
  --
  cursor c_job_seg24 (p_job_id number) is
	select jdf.segment24
	  from per_jobs job, per_job_definitions jdf
	 where job.job_definition_id = jdf.job_definition_id
	   and job.job_id = p_job_id;
  --
  cursor c_job_seg25 (p_job_id number) is
	select jdf.segment25
	  from per_jobs job, per_job_definitions jdf
	 where job.job_definition_id = jdf.job_definition_id
	   and job.job_id = p_job_id;
  --
  cursor c_job_seg26 (p_job_id number) is
	select jdf.segment26
	  from per_jobs job, per_job_definitions jdf
	 where job.job_definition_id = jdf.job_definition_id
	   and job.job_id = p_job_id;
  --
  cursor c_job_seg27 (p_job_id number) is
	select jdf.segment27
	  from per_jobs job, per_job_definitions jdf
	 where job.job_definition_id = jdf.job_definition_id
	   and job.job_id = p_job_id;
  --
  cursor c_job_seg28 (p_job_id number) is
	select jdf.segment28
	  from per_jobs job, per_job_definitions jdf
	 where job.job_definition_id = jdf.job_definition_id
	   and job.job_id = p_job_id;
  --
  cursor c_job_seg29 (p_job_id number) is
	select jdf.segment29
	  from per_jobs job, per_job_definitions jdf
	 where job.job_definition_id = jdf.job_definition_id
	   and job.job_id = p_job_id;
  --
  cursor c_job_seg30 (p_job_id number) is
	select jdf.segment30
	  from per_jobs job, per_job_definitions jdf
	 where job.job_definition_id = jdf.job_definition_id
	   and job.job_id = p_job_id;

--
begin
  -- hr_utility.set_location('Entering:'||l_proc, 1);
/*
  --
  -- Open the cursor
  --
  l_cursor_id := DBMS_SQL.OPEN_CURSOR;
  --
  -- Create the query string
  --
  if p_code = 'POS' then
    l_select_string
	:= 'select pdf.' || p_information
	   || ' from per_positions pos, per_position_definitions pdf'
	   || ' where pos.position_definition_id = pdf.position_definition_id'
	   || ' and pos.position_id = ' || p_id;
  elsif p_code = 'JOB' then
    l_select_string
	:= 'select jdf.' || p_information
	   || ' from per_jobs job, per_job_definitions jdf'
	   || ' where job.job_definition_id = jdf.job_definition_id'
	   || ' and job.job_id = ' || p_id;
  else  -- Invalid p_code
    null;
  end if;
  --
  -- Parse the query
  --
  DBMS_SQL.PARSE(l_cursor_id, l_select_string, DBMS_SQL.V7);
  --
  -- Define the output variable
  --
  DBMS_SQL.DEFINE_COLUMN(l_cursor_id, 1, l_segment, 150);
  --
  -- Execute the query
  --
  l_numrows := DBMS_SQL.EXECUTE(l_cursor_id);
  if DBMS_SQL.FETCH_ROWS(l_cursor_id) != 0 then
    --
    -- Retrieve row from the buffer into PL/SQL variable
    --
    DBMS_SQL.COLUMN_VALUE(l_cursor_id, 1, l_segment);
    --
    -- Close the cursor
    --
    DBMS_SQL.CLOSE_CURSOR(l_cursor_id);
  end if;
  --
  p_segment     := l_segment;
  -- hr_utility.set_location(' Leaving:'||l_proc, 5);
  --
--
exception
  when others then
    --
    -- Close cursor, then raise error
    --
    DBMS_SQL.CLOSE_CURSOR(l_cursor_id);
    -- hr_utility.set_message(8301,'GHR_9999_API_DYNAMIC_SQL_ERR');
    -- hr_utility.raise_error;
*/
  --
  p_segment := NULL;
  --
  if p_code = 'POS' then
    if p_information = 'SEGMENT1' then
      for c_pos_seg1_rec in c_pos_seg1 (p_id) loop
	l_pos_seg1_found := TRUE;
	p_segment := c_pos_seg1_rec.segment1;
	exit;
      end loop;
      if not l_pos_seg1_found then
	-- hr_utility.set_message(8301, 'GHR_38028_API_INV_POS');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT2' then
      for c_pos_seg2_rec in c_pos_seg2 (p_id) loop
	l_pos_seg2_found := TRUE;
	p_segment := c_pos_seg2_rec.segment2;
	exit;
      end loop;
      if not l_pos_seg2_found then
	-- hr_utility.set_message(8301, 'GHR_38028_API_INV_POS');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT3' then
      for c_pos_seg3_rec in c_pos_seg3 (p_id) loop
	l_pos_seg3_found := TRUE;
	p_segment := c_pos_seg3_rec.segment3;
	exit;
      end loop;
      if not l_pos_seg3_found then
	-- hr_utility.set_message(8301, 'GHR_38028_API_INV_POS');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT4' then
      for c_pos_seg4_rec in c_pos_seg4 (p_id) loop
	l_pos_seg4_found := TRUE;
	p_segment := c_pos_seg4_rec.segment4;
	exit;
      end loop;
      if not l_pos_seg4_found then
	-- hr_utility.set_message(8301, 'GHR_38028_API_INV_POS');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT5' then
      for c_pos_seg5_rec in c_pos_seg5 (p_id) loop
	l_pos_seg5_found := TRUE;
	p_segment := c_pos_seg5_rec.segment5;
	exit;
      end loop;
      if not l_pos_seg5_found then
	-- hr_utility.set_message(8301, 'GHR_38028_API_INV_POS');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT6' then
      for c_pos_seg6_rec in c_pos_seg6 (p_id) loop
	l_pos_seg6_found := TRUE;
	p_segment := c_pos_seg6_rec.segment6;
	exit;
      end loop;
      if not l_pos_seg6_found then
	-- hr_utility.set_message(8301, 'GHR_38028_API_INV_POS');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT7' then
      for c_pos_seg7_rec in c_pos_seg7 (p_id) loop
	l_pos_seg7_found := TRUE;
	p_segment := c_pos_seg7_rec.segment7;
	exit;
      end loop;
      if not l_pos_seg7_found then
	-- hr_utility.set_message(8301, 'GHR_38028_API_INV_POS');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT8' then
      for c_pos_seg8_rec in c_pos_seg8 (p_id) loop
	l_pos_seg8_found := TRUE;
	p_segment := c_pos_seg8_rec.segment8;
	exit;
      end loop;
      if not l_pos_seg8_found then
	-- hr_utility.set_message(8301, 'GHR_38028_API_INV_POS');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT9' then
      for c_pos_seg9_rec in c_pos_seg9 (p_id) loop
	l_pos_seg9_found := TRUE;
	p_segment := c_pos_seg9_rec.segment9;
	exit;
      end loop;
      if not l_pos_seg9_found then
	-- hr_utility.set_message(8301, 'GHR_38028_API_INV_POS');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT10' then
      for c_pos_seg10_rec in c_pos_seg10 (p_id) loop
	l_pos_seg10_found := TRUE;
	p_segment := c_pos_seg10_rec.segment10;
	exit;
      end loop;
      if not l_pos_seg10_found then
	-- hr_utility.set_message(8301, 'GHR_38028_API_INV_POS');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT11' then
      for c_pos_seg11_rec in c_pos_seg11 (p_id) loop
	l_pos_seg11_found := TRUE;
	p_segment := c_pos_seg11_rec.segment11;
	exit;
      end loop;
      if not l_pos_seg11_found then
	-- hr_utility.set_message(8301, 'GHR_38028_API_INV_POS');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT12' then
      for c_pos_seg12_rec in c_pos_seg12 (p_id) loop
	l_pos_seg12_found := TRUE;
	p_segment := c_pos_seg12_rec.segment12;
	exit;
      end loop;
      if not l_pos_seg12_found then
	-- hr_utility.set_message(8301, 'GHR_38028_API_INV_POS');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT13' then
      for c_pos_seg13_rec in c_pos_seg13 (p_id) loop
	l_pos_seg13_found := TRUE;
	p_segment := c_pos_seg13_rec.segment13;
	exit;
      end loop;
      if not l_pos_seg13_found then
	-- hr_utility.set_message(8301, 'GHR_38028_API_INV_POS');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT14' then
      for c_pos_seg14_rec in c_pos_seg14 (p_id) loop
	l_pos_seg14_found := TRUE;
	p_segment := c_pos_seg14_rec.segment14;
	exit;
      end loop;
      if not l_pos_seg14_found then
	-- hr_utility.set_message(8301, 'GHR_38028_API_INV_POS');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT15' then
      for c_pos_seg15_rec in c_pos_seg15 (p_id) loop
	l_pos_seg15_found := TRUE;
	p_segment := c_pos_seg15_rec.segment15;
	exit;
      end loop;
      if not l_pos_seg15_found then
	-- hr_utility.set_message(8301, 'GHR_38028_API_INV_POS');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT15' then
      for c_pos_seg15_rec in c_pos_seg15 (p_id) loop
	l_pos_seg15_found := TRUE;
	p_segment := c_pos_seg15_rec.segment15;
	exit;
      end loop;
      if not l_pos_seg15_found then
	-- hr_utility.set_message(8301, 'GHR_38028_API_INV_POS');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT16' then
      for c_pos_seg16_rec in c_pos_seg16 (p_id) loop
	l_pos_seg16_found := TRUE;
	p_segment := c_pos_seg16_rec.segment16;
	exit;
      end loop;
      if not l_pos_seg16_found then
	-- hr_utility.set_message(8301, 'GHR_38028_API_INV_POS');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT17' then
      for c_pos_seg17_rec in c_pos_seg17 (p_id) loop
	l_pos_seg17_found := TRUE;
	p_segment := c_pos_seg17_rec.segment17;
	exit;
      end loop;
      if not l_pos_seg17_found then
	-- hr_utility.set_message(8301, 'GHR_38028_API_INV_POS');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT18' then
      for c_pos_seg18_rec in c_pos_seg18 (p_id) loop
	l_pos_seg18_found := TRUE;
	p_segment := c_pos_seg18_rec.segment18;
	exit;
      end loop;
      if not l_pos_seg18_found then
	-- hr_utility.set_message(8301, 'GHR_38028_API_INV_POS');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT19' then
      for c_pos_seg19_rec in c_pos_seg19 (p_id) loop
	l_pos_seg19_found := TRUE;
	p_segment := c_pos_seg19_rec.segment19;
	exit;
      end loop;
      if not l_pos_seg19_found then
	-- hr_utility.set_message(8301, 'GHR_38028_API_INV_POS');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT20' then
      for c_pos_seg20_rec in c_pos_seg20 (p_id) loop
	l_pos_seg20_found := TRUE;
	p_segment := c_pos_seg20_rec.segment20;
	exit;
      end loop;
      if not l_pos_seg20_found then
	-- hr_utility.set_message(8301, 'GHR_38028_API_INV_POS');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT21' then
      for c_pos_seg21_rec in c_pos_seg21 (p_id) loop
	l_pos_seg21_found := TRUE;
	p_segment := c_pos_seg21_rec.segment21;
	exit;
      end loop;
      if not l_pos_seg21_found then
	-- hr_utility.set_message(8301, 'GHR_38028_API_INV_POS');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT22' then
      for c_pos_seg22_rec in c_pos_seg22 (p_id) loop
	l_pos_seg22_found := TRUE;
	p_segment := c_pos_seg22_rec.segment22;
	exit;
      end loop;
      if not l_pos_seg22_found then
	-- hr_utility.set_message(8301, 'GHR_38028_API_INV_POS');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT23' then
      for c_pos_seg23_rec in c_pos_seg23 (p_id) loop
	l_pos_seg23_found := TRUE;
	p_segment := c_pos_seg23_rec.segment23;
	exit;
      end loop;
      if not l_pos_seg23_found then
	-- hr_utility.set_message(8301, 'GHR_38028_API_INV_POS');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT24' then
      for c_pos_seg24_rec in c_pos_seg24 (p_id) loop
	l_pos_seg24_found := TRUE;
	p_segment := c_pos_seg24_rec.segment24;
	exit;
      end loop;
      if not l_pos_seg24_found then
	-- hr_utility.set_message(8301, 'GHR_38028_API_INV_POS');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT25' then
      for c_pos_seg25_rec in c_pos_seg25 (p_id) loop
	l_pos_seg25_found := TRUE;
	p_segment := c_pos_seg25_rec.segment25;
	exit;
      end loop;
      if not l_pos_seg25_found then
	-- hr_utility.set_message(8301, 'GHR_38028_API_INV_POS');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT26' then
      for c_pos_seg26_rec in c_pos_seg26 (p_id) loop
	l_pos_seg26_found := TRUE;
	p_segment := c_pos_seg26_rec.segment26;
	exit;
      end loop;
      if not l_pos_seg26_found then
	-- hr_utility.set_message(8301, 'GHR_38028_API_INV_POS');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT27' then
      for c_pos_seg27_rec in c_pos_seg27 (p_id) loop
	l_pos_seg27_found := TRUE;
	p_segment := c_pos_seg27_rec.segment27;
	exit;
      end loop;
      if not l_pos_seg27_found then
	-- hr_utility.set_message(8301, 'GHR_38028_API_INV_POS');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT28' then
      for c_pos_seg28_rec in c_pos_seg28 (p_id) loop
	l_pos_seg28_found := TRUE;
	p_segment := c_pos_seg28_rec.segment28;
	exit;
      end loop;
      if not l_pos_seg28_found then
	-- hr_utility.set_message(8301, 'GHR_38028_API_INV_POS');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT29' then
      for c_pos_seg29_rec in c_pos_seg29 (p_id) loop
	l_pos_seg29_found := TRUE;
	p_segment := c_pos_seg29_rec.segment29;
	exit;
      end loop;
      if not l_pos_seg29_found then
	-- hr_utility.set_message(8301, 'GHR_38028_API_INV_POS');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT30' then
      for c_pos_seg30_rec in c_pos_seg30 (p_id) loop
	l_pos_seg30_found := TRUE;
	p_segment := c_pos_seg30_rec.segment30;
	exit;
      end loop;
      if not l_pos_seg30_found then
	-- hr_utility.set_message(8301, 'GHR_38028_API_INV_POS');
	-- hr_utility.raise_error;
	null;
      end if;
    end if;  /* p_information */
  --
  elsif p_code = 'JOB' then
    if p_information = 'SEGMENT1' then
      for c_job_seg1_rec in c_job_seg1 (p_id) loop
	l_job_seg1_found := TRUE;
	p_segment := c_job_seg1_rec.segment1;
	exit;
      end loop;
      if not l_job_seg1_found then
	-- hr_utility.set_message(8301, 'GHR_38029_API_INV_JOB');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT2' then
      for c_job_seg2_rec in c_job_seg2 (p_id) loop
	l_job_seg2_found := TRUE;
	p_segment := c_job_seg2_rec.segment2;
	exit;
      end loop;
      if not l_job_seg2_found then
	-- hr_utility.set_message(8301, 'GHR_38029_API_INV_JOB');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT3' then
      for c_job_seg3_rec in c_job_seg3 (p_id) loop
	l_job_seg3_found := TRUE;
	p_segment := c_job_seg3_rec.segment3;
	exit;
      end loop;
      if not l_job_seg3_found then
	-- hr_utility.set_message(8301, 'GHR_38029_API_INV_JOB');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT4' then
      for c_job_seg4_rec in c_job_seg4 (p_id) loop
	l_job_seg4_found := TRUE;
	p_segment := c_job_seg4_rec.segment4;
	exit;
      end loop;
      if not l_job_seg4_found then
	-- hr_utility.set_message(8301, 'GHR_38029_API_INV_JOB');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT5' then
      for c_job_seg5_rec in c_job_seg5 (p_id) loop
	l_job_seg5_found := TRUE;
	p_segment := c_job_seg5_rec.segment5;
	exit;
      end loop;
      if not l_job_seg5_found then
	-- hr_utility.set_message(8301, 'GHR_38029_API_INV_JOB');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT6' then
      for c_job_seg6_rec in c_job_seg6 (p_id) loop
	l_job_seg6_found := TRUE;
	p_segment := c_job_seg6_rec.segment6;
	exit;
      end loop;
      if not l_job_seg6_found then
	-- hr_utility.set_message(8301, 'GHR_38029_API_INV_JOB');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT7' then
      for c_job_seg7_rec in c_job_seg7 (p_id) loop
	l_job_seg7_found := TRUE;
	p_segment := c_job_seg7_rec.segment7;
	exit;
      end loop;
      if not l_job_seg7_found then
	-- hr_utility.set_message(8301, 'GHR_38029_API_INV_JOB');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT8' then
      for c_job_seg8_rec in c_job_seg8 (p_id) loop
	l_job_seg8_found := TRUE;
	p_segment := c_job_seg8_rec.segment8;
	exit;
      end loop;
      if not l_job_seg8_found then
	-- hr_utility.set_message(8301, 'GHR_38029_API_INV_JOB');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT9' then
      for c_job_seg9_rec in c_job_seg9 (p_id) loop
	l_job_seg9_found := TRUE;
	p_segment := c_job_seg9_rec.segment9;
	exit;
      end loop;
      if not l_job_seg9_found then
	-- hr_utility.set_message(8301, 'GHR_38029_API_INV_JOB');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT10' then
      for c_job_seg10_rec in c_job_seg10 (p_id) loop
	l_job_seg10_found := TRUE;
	p_segment := c_job_seg10_rec.segment10;
	exit;
      end loop;
      if not l_job_seg10_found then
	-- hr_utility.set_message(8301, 'GHR_38029_API_INV_JOB');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT11' then
      for c_job_seg11_rec in c_job_seg11 (p_id) loop
	l_job_seg11_found := TRUE;
	p_segment := c_job_seg11_rec.segment11;
	exit;
      end loop;
      if not l_job_seg11_found then
	-- hr_utility.set_message(8301, 'GHR_38029_API_INV_JOB');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT12' then
      for c_job_seg12_rec in c_job_seg12 (p_id) loop
	l_job_seg12_found := TRUE;
	p_segment := c_job_seg12_rec.segment12;
	exit;
      end loop;
      if not l_job_seg12_found then
	-- hr_utility.set_message(8301, 'GHR_38029_API_INV_JOB');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT13' then
      for c_job_seg13_rec in c_job_seg13 (p_id) loop
	l_job_seg13_found := TRUE;
	p_segment := c_job_seg13_rec.segment13;
	exit;
      end loop;
      if not l_job_seg13_found then
	-- hr_utility.set_message(8301, 'GHR_38029_API_INV_JOB');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT14' then
      for c_job_seg14_rec in c_job_seg14 (p_id) loop
	l_job_seg14_found := TRUE;
	p_segment := c_job_seg14_rec.segment14;
	exit;
      end loop;
      if not l_job_seg14_found then
	-- hr_utility.set_message(8301, 'GHR_38029_API_INV_JOB');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT15' then
      for c_job_seg15_rec in c_job_seg15 (p_id) loop
	l_job_seg15_found := TRUE;
	p_segment := c_job_seg15_rec.segment15;
	exit;
      end loop;
      if not l_job_seg15_found then
	-- hr_utility.set_message(8301, 'GHR_38029_API_INV_JOB');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT15' then
      for c_job_seg15_rec in c_job_seg15 (p_id) loop
	l_job_seg15_found := TRUE;
	p_segment := c_job_seg15_rec.segment15;
	exit;
      end loop;
      if not l_job_seg15_found then
	-- hr_utility.set_message(8301, 'GHR_38029_API_INV_JOB');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT16' then
      for c_job_seg16_rec in c_job_seg16 (p_id) loop
	l_job_seg16_found := TRUE;
	p_segment := c_job_seg16_rec.segment16;
	exit;
      end loop;
      if not l_job_seg16_found then
	-- hr_utility.set_message(8301, 'GHR_38029_API_INV_JOB');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT17' then
      for c_job_seg17_rec in c_job_seg17 (p_id) loop
	l_job_seg17_found := TRUE;
	p_segment := c_job_seg17_rec.segment17;
	exit;
      end loop;
      if not l_job_seg17_found then
	-- hr_utility.set_message(8301, 'GHR_38029_API_INV_JOB');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT18' then
      for c_job_seg18_rec in c_job_seg18 (p_id) loop
	l_job_seg18_found := TRUE;
	p_segment := c_job_seg18_rec.segment18;
	exit;
      end loop;
      if not l_job_seg18_found then
	-- hr_utility.set_message(8301, 'GHR_38029_API_INV_JOB');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT19' then
      for c_job_seg19_rec in c_job_seg19 (p_id) loop
	l_job_seg19_found := TRUE;
	p_segment := c_job_seg19_rec.segment19;
	exit;
      end loop;
      if not l_job_seg19_found then
	-- hr_utility.set_message(8301, 'GHR_38029_API_INV_JOB');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT20' then
      for c_job_seg20_rec in c_job_seg20 (p_id) loop
	l_job_seg20_found := TRUE;
	p_segment := c_job_seg20_rec.segment20;
	exit;
      end loop;
      if not l_job_seg20_found then
	-- hr_utility.set_message(8301, 'GHR_38029_API_INV_JOB');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT21' then
      for c_job_seg21_rec in c_job_seg21 (p_id) loop
	l_job_seg21_found := TRUE;
	p_segment := c_job_seg21_rec.segment21;
	exit;
      end loop;
      if not l_job_seg21_found then
	-- hr_utility.set_message(8301, 'GHR_38029_API_INV_JOB');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT22' then
      for c_job_seg22_rec in c_job_seg22 (p_id) loop
	l_job_seg22_found := TRUE;
	p_segment := c_job_seg22_rec.segment22;
	exit;
      end loop;
      if not l_job_seg22_found then
	-- hr_utility.set_message(8301, 'GHR_38029_API_INV_JOB');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT23' then
      for c_job_seg23_rec in c_job_seg23 (p_id) loop
	l_job_seg23_found := TRUE;
	p_segment := c_job_seg23_rec.segment23;
	exit;
      end loop;
      if not l_job_seg23_found then
	-- hr_utility.set_message(8301, 'GHR_38029_API_INV_JOB');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT24' then
      for c_job_seg24_rec in c_job_seg24 (p_id) loop
	l_job_seg24_found := TRUE;
	p_segment := c_job_seg24_rec.segment24;
	exit;
      end loop;
      if not l_job_seg24_found then
	-- hr_utility.set_message(8301, 'GHR_38029_API_INV_JOB');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT25' then
      for c_job_seg25_rec in c_job_seg25 (p_id) loop
	l_job_seg25_found := TRUE;
	p_segment := c_job_seg25_rec.segment25;
	exit;
      end loop;
      if not l_job_seg25_found then
	-- hr_utility.set_message(8301, 'GHR_38029_API_INV_JOB');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT26' then
      for c_job_seg26_rec in c_job_seg26 (p_id) loop
	l_job_seg26_found := TRUE;
	p_segment := c_job_seg26_rec.segment26;
	exit;
      end loop;
      if not l_job_seg26_found then
	-- hr_utility.set_message(8301, 'GHR_38029_API_INV_JOB');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT27' then
      for c_job_seg27_rec in c_job_seg27 (p_id) loop
	l_job_seg27_found := TRUE;
	p_segment := c_job_seg27_rec.segment27;
	exit;
      end loop;
      if not l_job_seg27_found then
	-- hr_utility.set_message(8301, 'GHR_38029_API_INV_JOB');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT28' then
      for c_job_seg28_rec in c_job_seg28 (p_id) loop
	l_job_seg28_found := TRUE;
	p_segment := c_job_seg28_rec.segment28;
	exit;
      end loop;
      if not l_job_seg28_found then
	-- hr_utility.set_message(8301, 'GHR_38029_API_INV_JOB');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT29' then
      for c_job_seg29_rec in c_job_seg29 (p_id) loop
	l_job_seg29_found := TRUE;
	p_segment := c_job_seg29_rec.segment29;
	exit;
      end loop;
      if not l_job_seg29_found then
	-- hr_utility.set_message(8301, 'GHR_38029_API_INV_JOB');
	-- hr_utility.raise_error;
	null;
      end if;
    --
    elsif p_information = 'SEGMENT30' then
      for c_job_seg30_rec in c_job_seg30 (p_id) loop
	l_job_seg30_found := TRUE;
	p_segment := c_job_seg30_rec.segment30;
	exit;
      end loop;
      if not l_job_seg30_found then
	-- hr_utility.set_message(8301, 'GHR_38029_API_INV_JOB');
	-- hr_utility.raise_error;
	null;
      end if;
    end if;  /* p_information */
  --
  else  --  Invalid p_code
    -- hr_utility.set_message(8301, 'GHR_38037_API_ARG_ERR');
    -- hr_utility.raise_error;
    null;
  end if;
--
 exception when others then
     -- NOCOPY changes
     -- Reset IN OUT params and set OUT params
     p_segment           := NULL;
     raise;
end retrieve_segment_information;
--
-- ---------------------------------------------------------------------------
-- |-------------------< retrieve_element_entry_value >----------------------|
-- ---------------------------------------------------------------------------
--
procedure retrieve_element_entry_value
	(p_element_name      in     pay_element_types_f.element_name%type
	,p_input_value_name  in     pay_input_values_f.name%type
	,p_assignment_id     in     pay_element_entries_f.assignment_id%type
	,p_effective_date    in     date
	,p_value                OUT NOCOPY varchar2
	,p_multiple_error_flag  OUT NOCOPY boolean
	) is
  --
  l_proc                        varchar2(72) := g_package||'retrieve_element_entry_value';
  l_processing_type             pay_element_types_f.processing_type%type;
  l_ele_proc_type_found boolean := FALSE;
  l_rec_ele_ent_val_found       boolean := FALSE;
  l_nonrec_ele_ent_val_found    boolean := FALSE;
  l_session                     ghr_history_api.g_session_var_type;
  --
  cursor c_ele_processing_type (ele_name            in varchar2
		      	       ,eff_date            in date
			       ,bg_id               in number
			       ) is
	select elt.processing_type
	  from pay_element_types_f elt
	 where trunc(eff_date) between elt.effective_start_date
				   and elt.effective_end_date
	   and upper(elt.element_name) = upper(ele_name)
	  --Ashley
	   and (elt.business_group_id is null or elt.business_group_id = bg_id);
  --
  cursor c_rec_ele_entry_value (ele_name        in varchar2
			       ,input_name      in varchar2
       			       ,asg_id          in number
	      		       ,eff_date        in date
			       ,bg_id           in number) is
	select eev.screen_entry_value screen_entry_value
	  from pay_element_types_f elt,
	       pay_input_values_f ipv,
	       pay_element_entries_f ele,
	       pay_element_entry_values_f eev
	 where trunc(eff_date) between elt.effective_start_date
				   and elt.effective_end_date
	   and trunc(eff_date) between ipv.effective_start_date
				   and ipv.effective_end_date
	   and trunc(eff_date) between ele.effective_start_date
				   and ele.effective_end_date
	   and trunc(eff_date) between eev.effective_start_date
				   and eev.effective_end_date
	   and elt.element_type_id = ipv.element_type_id
	   and upper(elt.element_name) = upper(ele_name)
	   and ipv.input_value_id = eev.input_value_id
	   and ele.assignment_id = asg_id
	   and ele.element_entry_id + 0 = eev.element_entry_id
	   and upper(ipv.name) = upper(input_name)
--	   and NVL(elt.business_group_id,0) = NVL(ipv.business_group_id,0)   --Ashley
	   and (elt.business_group_id is null or elt.business_group_id = bg_id);
  --
  cursor c_nonrec_ele_entry_value (ele_name     in varchar2
				  ,input_name   in varchar2
				  ,asg_id       in number
				  ,eff_date     in date
				  ,bg_id        in number) is
	select eev.screen_entry_value screen_entry_value
	  from pay_element_types_f elt,
	       pay_input_values_f ipv,
	       pay_element_entries_f ele,
	       pay_element_entry_values_f eev
	 where trunc(eff_date) between elt.effective_start_date
				   and elt.effective_end_date
	   and trunc(eff_date) between ipv.effective_start_date
				   and ipv.effective_end_date
	   and ele.effective_end_date =
			(select max(ele2.effective_end_date)
			   from pay_element_entries_f ele2
			  where ele2.element_entry_id = ele.element_entry_id)
	   and eev.effective_end_date =
			(select max(eev2.effective_end_date)
			   from pay_element_entries_f eev2
			  where eev2.element_entry_id = eev.element_entry_id)
	   and elt.element_type_id = ipv.element_type_id
	   and upper(elt.element_name) = upper(ele_name)
	   and ipv.input_value_id = eev.input_value_id
	   and ele.assignment_id = asg_id
	   and ele.element_entry_id + 0 = eev.element_entry_id
	   and upper(ipv.name) = upper(input_name)
--	   and NVL(elt.business_group_id,0) = NVL(ipv.business_group_id,0)   --Ashley
	   and (elt.business_group_id is null or elt.business_group_id = bg_id);
--
--
Cursor Cur_bg(p_assignment_id NUMBER,p_eff_date DATE) is
       Select distinct business_group_id bg
       from  per_assignments_f
       where assignment_id = p_assignment_id
       and   p_eff_date between effective_start_date
             and effective_end_date;

--
--
 ll_bg_id                    NUMBER;
 ll_pay_basis                VARCHAR2(80);
 l_new_element_name          VARCHAR2(80);
 ll_effective_Date           DATE;
 l_ele_type_id               NUMBER;
 l_ele_name                  VARCHAR2(80);
 l_sal_basis_id              NUMBER;

--
begin
--
  hr_utility.set_location('Entering:'||l_proc, 1);
  ghr_history_api.get_g_session_var(l_session);
  ll_effective_date := p_effective_date;
  --
  -- Initialization
  -- Pick the business group id and also pay basis for later use
  hr_utility.set_location('Asg Id'||to_char(p_assignment_id), 20);

 For BG_rec in Cur_BG(p_assignment_id,p_effective_date)
  Loop
   ll_bg_id:=BG_rec.bg;
  End Loop;

----
---- The New Changes after 08/22 patch
---- For all elements in HR User old function will fetch the same name.
----     because of is_script will be FALSE
----
---- For all elements (except BSR) in Payroll user old function.
----     for BSR a new function which will fetch from assignmnet id.
----

IF (p_element_name = 'Basic Salary Rate'
    and (fnd_profile.value('HR_USER_TYPE') = 'INT')) THEN
  hr_utility.set_location('PAYROLL User -- BSR -- from asgid-- '||l_proc, 1);
           l_new_element_name :=
                   pqp_fedhr_uspay_int_utils.return_new_element_name(
                                           p_assignment_id      => p_assignment_id,
                                           p_business_group_id  => ll_bg_id,
                                           p_effective_date     => ll_effective_date);
 ELSIF (fnd_profile.value('HR_USER_TYPE') <> 'INT'
   or (p_element_name <> 'Basic Salary Rate' and (fnd_profile.value('HR_USER_TYPE') = 'INT'))) THEN
  hr_utility.set_location('HR USER or PAYROLL User without BSR element -- from elt name -- '||l_proc, 1);
           l_new_element_name :=
                            pqp_fedhr_uspay_int_utils.return_new_element_name(
                                          p_fedhr_element_name => p_element_name,
                                           p_business_group_id  => ll_bg_id,
                                           p_effective_date     => ll_effective_date,
                                           p_pay_basis          => NULL);

 END IF;

hr_utility.set_location('Element Name ' ||p_element_name,1000);
hr_utility.set_location('BG ID '|| nvl(to_char(ll_bg_id),'NULL'),2000);
hr_utility.set_location('Eff date'|| p_effective_date ,3000);
hr_utility.set_location('pay basis ' || ll_pay_basis,3500);
--
-- the p_element_name is replaced with l_new_element_name
-- in further calls.
--
  hr_utility.set_location('New element Name ' ||l_new_element_name,100000);

  hr_utility.set_location(l_proc,2);

  If l_session.noa_id_correct is not null then
     hr_utility.set_location(l_proc,3);

-- History package call fetch_element_entry_value picks new element name
-- again in its call so sending old element name.
     ghr_history_fetch.fetch_element_entry_value
     (p_element_name          =>  p_element_name,
      p_input_value_name      =>  p_input_value_name,
      p_assignment_id         =>  p_assignment_id,
      p_date_effective        =>  p_effective_date,
      p_screen_entry_value    =>  p_value
      );
  Else
  hr_utility.set_location(l_proc,4);
-- sending new element name for cursors to get proper element_type_id's,
-- Processing_types, element_entry_id's
  for c_ele_processing_type_rec in
		c_ele_processing_type (l_new_element_name
				      ,p_effective_date
				      ,ll_bg_id) loop
    l_ele_proc_type_found := TRUE;
    l_processing_type := c_ele_processing_type_rec.processing_type;
    exit;
  end loop;
  if not l_ele_proc_type_found then
    hr_utility.set_message(8301, 'GHR_38034_API_EL_TYPE_NOT_EXST');
    hr_utility.raise_error;
  end if;
  hr_utility.set_location(l_proc, 5);
  --
  if l_processing_type = 'R' then  -- Recurring element
    for c_rec_ele_entry_value_rec in
		c_rec_ele_entry_value (l_new_element_name
				      ,p_input_value_name
				      ,p_assignment_id
				      ,p_effective_date
				      ,ll_bg_id) loop
      l_rec_ele_ent_val_found := TRUE;
      if c_rec_ele_entry_value%rowcount > 1 then
	p_multiple_error_flag := TRUE;
	p_value := NULL;
	exit;
      else
	p_multiple_error_flag := FALSE;
	p_value := c_rec_ele_entry_value_rec.screen_entry_value;
      end if;
    end loop;
    if not l_rec_ele_ent_val_found then
      -- hr_utility.set_message(8301, 'GHR_38036_API_EL_ENT_NOT_EXIST');
      -- hr_utility.raise_error;
      p_value := NULL;
    end if;
  elsif l_processing_type = 'N' then  -- Nonrecurring element
    for c_nonrec_ele_entry_value_rec in
		c_nonrec_ele_entry_value (l_new_element_name
					 ,p_input_value_name
					 ,p_assignment_id
					 ,p_effective_date
					 ,ll_bg_id) loop
      l_nonrec_ele_ent_val_found := TRUE;
      if c_nonrec_ele_entry_value%rowcount > 1 then
	p_multiple_error_flag := TRUE;
	p_value := NULL;
	exit;
      else
	p_multiple_error_flag := FALSE;
	p_value := c_nonrec_ele_entry_value_rec.screen_entry_value;
      end if;
    end loop;
  if not l_nonrec_ele_ent_val_found then
    -- hr_utility.set_message(8301, 'GHR_38036_API_EL_ENT_NOT_EXIST');
    -- hr_utility.raise_error;
    p_value := NULL;
  end if;
  hr_utility.set_location(l_proc, 6);
  else  -- Neither recurring nor nonrecurring element
    hr_utility.set_message(8301, 'GHR_38035_API_INV_PROC_TYPE');
    hr_utility.raise_error;
  end if;
  hr_utility.set_location(l_proc, 7);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 8);
--
End If;
   exception
  when others then
     -- NOCOPY changes
     -- Reset IN OUT params and set OUT params

       if p_element_name in ('AUO','Availability Pay','Staffing Differential',
                             'Health Benefits') then
          p_value               := null;
          p_multiple_error_flag := null;
       else
            hr_utility.set_message(800, 'HR_7465_PLK_NOT_ELGBLE_ELE_NME');
            hr_utility.set_message_token('ELEMENT_NAME', p_element_name);
            hr_utility.raise_error;

       end if;
  hr_utility.set_location(' Leaving:'||l_proc, 8);

end retrieve_element_entry_value;
--
-- ---------------------------------------------------------------------------
-- |--------------------------< get_position_title >-------------------------|
-- ---------------------------------------------------------------------------
--
function get_position_title
	(p_person_id            in per_people_f.person_id%type          default NULL
	,p_assignment_id        in per_assignments_f.assignment_id%type default NULL
	,p_effective_date       in date                                 default sysdate
	) return varchar2 is
  --
  l_proc                varchar2(72) := g_package||'get_position_title';
  l_effective_date      date;
  l_business_group_id   per_all_positions.business_group_id%type;
  l_position_id         per_all_positions.position_id%type;
  l_segment_rec         org_info_rec_type;
  l_segment             per_position_definitions.segment1%type;
  l_asg_pos_by_per_id_found     boolean := FALSE;
  l_asg_pos_by_asg_id_found     boolean := FALSE;
--
begin
  -- hr_utility.set_location('Entering:'||l_proc, 1);
  --
  if p_effective_date is NULL then
    l_effective_date := sysdate;
  else
    l_effective_date := p_effective_date;
  end if;
  --
  retrieve_business_group_id (p_person_id               => p_person_id
			     ,p_assignment_id           => p_assignment_id
			     ,p_effective_date          => l_effective_date
			     ,p_business_group_id       => l_business_group_id);
  if l_business_group_id is NULL then
    -- hr_utility.set_message(8301, 'GHR_38038_API_INV_BG');
    -- hr_utility.raise_error;
    null;
  end if;
  -- hr_utility.set_location(l_proc, 2);
  --
  retrieve_gov_kff_setup_info (p_business_group_id      => l_business_group_id
			       ,p_org_info_rec          => l_segment_rec);
  if l_segment_rec.information2 is NULL then
    -- hr_utility.set_message(8301, 'GHR_38022_API_GHR_ORG_INFO_ERR');
    -- hr_utility.raise_error;
    null;
  end if;
  -- hr_utility.set_location(l_proc, 3);
  --
  IF p_person_id is NULL and p_assignment_id is NULL THEN
      -- hr_utility.set_message(8301, 'GHR_38037_API_ARG_ERR');
      -- hr_utility.raise_error;
      null;
  ELSIF p_assignment_id IS NULL THEN
    FOR c_asg_pos_by_per_id_rec IN c_asg_pos_by_per_id (p_person_id, l_effective_date) loop
      l_asg_pos_by_per_id_found := TRUE;
      l_position_id := c_asg_pos_by_per_id_rec.position_id;
      EXIT;
    END LOOP;
    IF NOT l_asg_pos_by_per_id_found THEN
      -- hr_utility.set_message(8301, 'GHR_38023_API_INV_ASG');
      -- hr_utility.raise_error;
      null;
    END IF;
  else    -- p_assignment_id is not NULL
    for c_asg_pos_by_asg_id_rec
		in c_asg_pos_by_asg_id (p_assignment_id, l_effective_date) loop
      l_asg_pos_by_asg_id_found := TRUE;
      l_position_id := c_asg_pos_by_asg_id_rec.position_id;
      exit;
    end loop;
    if not l_asg_pos_by_asg_id_found then
      -- hr_utility.set_message(8301, 'GHR_38023_API_INV_ASG');
      -- hr_utility.raise_error;
      null;
    end if;
  end if;
  -- hr_utility.set_location(l_proc, 4);
  --
  retrieve_segment_information (p_information   => l_segment_rec.information2
			       ,p_id            => l_position_id
			       ,p_code          => 'POS'
			       ,p_segment       => l_segment
                               ,p_effective_date => p_effective_date);
  --
  -- hr_utility.set_location(' Leaving:'||l_proc, 5);
  return l_segment;
--
end get_position_title;
--
-- ---------------------------------------------------------------------------
-- |--------------------------< get_position_title_pos >----------------------|
-- ---------------------------------------------------------------------------
--
function get_position_title_pos
	(p_position_id            in per_all_positions.position_id%type
	,p_business_group_id      in per_all_positions.business_group_id%type
        ,p_effective_date         in date default sysdate
  ) return varchar2 IS
  --
  l_proc                varchar2(72) := g_package||'get_position_title_pos';
  l_segment_rec         org_info_rec_type;
  l_segment             per_position_definitions.segment1%type;
--
begin
  -- hr_utility.set_location('Entering:'||l_proc, 1);
  --
  if p_position_id IS NULL OR p_business_group_id IS NULL then
    -- hr_utility.set_message(8301, 'GHR_38037_API_ARG_ERR');
    -- hr_utility.raise_error;
    null;
  end if;
  --
  -- hr_utility.set_location(l_proc, 2);
  --
  retrieve_gov_kff_setup_info (p_business_group_id => p_business_group_id
			      ,p_org_info_rec      => l_segment_rec);
  --
  if l_segment_rec.information2 is NULL then
   -- hr_utility.set_message(8301, 'GHR_38022_API_GHR_ORG_INFO_ERR');
   -- hr_utility.raise_error;
    null;
  end if;
  -- hr_utility.set_location(l_proc, 3);
  --
  retrieve_segment_information (p_information  => l_segment_rec.information2
			       ,p_id           => p_position_id
			       ,p_code         => 'POS'
                               ,p_effective_date => p_effective_date
			       ,p_segment      => l_segment);
  --
  -- hr_utility.set_location(' Leaving:'||l_proc, 5);
  return l_segment;
--
end get_position_title_pos;
--
-- ---------------------------------------------------------------------------
-- |---------------------< get_position_description_no >---------------------|
-- ---------------------------------------------------------------------------
--
function get_position_description_no
	(p_person_id            in per_people_f.person_id%type          default NULL
	,p_assignment_id        in per_assignments_f.assignment_id%type default NULL
	,p_effective_date       in date                                 default sysdate
	) return varchar2 is
  --
  l_proc                varchar2(72) := g_package||'get_position_description_no';
  l_effective_date      date;
  l_business_group_id   per_all_positions.business_group_id%type;
  l_position_id         per_all_positions.position_id%type;
  l_segment_rec         org_info_rec_type;
  l_segment             per_position_definitions.segment1%type;
  l_asg_pos_by_per_id_found     boolean := FALSE;
  l_asg_pos_by_asg_id_found     boolean := FALSE;
--
begin
  -- hr_utility.set_location('Entering:'||l_proc, 1);
  --
  if p_effective_date is NULL then
    l_effective_date := sysdate;
  else
    l_effective_date := p_effective_date;
  end if;
  --
  retrieve_business_group_id (p_person_id             => p_person_id
			     ,p_assignment_id         => p_assignment_id
			     ,p_effective_date        => l_effective_date
			     ,p_business_group_id     => l_business_group_id);
  if l_business_group_id is NULL then
    -- hr_utility.set_message(8301, 'GHR_38038_API_INV_BG');
    -- hr_utility.raise_error;
    null;
  end if;
  -- hr_utility.set_location(l_proc, 2);
  --
  if p_person_id is NULL and p_assignment_id is NULL then
      -- hr_utility.set_message(8301, 'GHR_38037_API_ARG_ERR');
      -- hr_utility.raise_error;
      null;
  elsif p_assignment_id is NULL then
    for c_asg_pos_by_per_id_rec
		in c_asg_pos_by_per_id (p_person_id, l_effective_date) loop
      l_asg_pos_by_per_id_found := TRUE;
      l_position_id := c_asg_pos_by_per_id_rec.position_id;
      exit;
    end loop;
    if not l_asg_pos_by_per_id_found then
      -- hr_utility.set_message(8301, 'GHR_38023_API_INV_ASG');
      -- hr_utility.raise_error;
      null;
    end if;
  else    -- p_assignment_id is not NULL
    for c_asg_pos_by_asg_id_rec
		in c_asg_pos_by_asg_id (p_assignment_id, l_effective_date) loop
      l_asg_pos_by_asg_id_found := TRUE;
      l_position_id := c_asg_pos_by_asg_id_rec.position_id;
      exit;
    end loop;
    if not l_asg_pos_by_asg_id_found then
      -- hr_utility.set_message(8301, 'GHR_38023_API_INV_ASG');
      -- hr_utility.raise_error;
      null;
    end if;
  end if;
  -- hr_utility.set_location(l_proc, 3);
  --
  retrieve_gov_kff_setup_info (p_business_group_id      => l_business_group_id
			      ,p_org_info_rec           => l_segment_rec);
  if l_segment_rec.information3 is NULL then
    -- hr_utility.set_message(8301, 'GHR_38022_API_GHR_ORG_INFO_ERR');
    -- hr_utility.raise_error;
     null;
  end if;
  -- hr_utility.set_location(l_proc, 4);
  --
  retrieve_segment_information (p_information   => l_segment_rec.information3
			       ,p_id            => l_position_id
			       ,p_code          => 'POS'
			       ,p_segment       => l_segment
                               ,p_effective_date => p_effective_date);
  --
  -- hr_utility.set_location(' Leaving:'||l_proc, 5);
  --
  return l_segment;
--
end get_position_description_no;
--
-- ---------------------------------------------------------------------------
-- |--------------------------< get_position_desc_no_pos >----------------------|
-- ---------------------------------------------------------------------------
--
function get_position_desc_no_pos
	(p_position_id            in per_all_positions.position_id%type
	,p_business_group_id      in per_all_positions.business_group_id%type
        ,p_effective_date          in date default sysdate
  ) return varchar2 IS
  --
  l_proc                varchar2(72) := g_package||'get_position_desc_no_pos';
  l_segment_rec         org_info_rec_type;
  l_segment             per_position_definitions.segment1%type;
--
begin
  -- hr_utility.set_location('Entering:'||l_proc, 1);
  --
  if p_position_id IS NULL OR p_business_group_id IS NULL then
    -- hr_utility.set_message(8301, 'GHR_38037_API_ARG_ERR');
    -- hr_utility.raise_error;
    null;
  end if;
  --
  -- hr_utility.set_location(l_proc, 2);
  --
  retrieve_gov_kff_setup_info (p_business_group_id => p_business_group_id
			      ,p_org_info_rec      => l_segment_rec);
  --
  if l_segment_rec.information3 is NULL then
   --  hr_utility.set_message(8301, 'GHR_38022_API_GHR_ORG_INFO_ERR');
   --  hr_utility.raise_error;
    null;
  end if;
  -- hr_utility.set_location(l_proc, 3);
  --
  retrieve_segment_information (p_information  => l_segment_rec.information3
			       ,p_id           => p_position_id
			       ,p_code         => 'POS'
			       ,p_segment      => l_segment
                               ,p_effective_date => p_effective_date);
  --
  -- hr_utility.set_location(' Leaving:'||l_proc, 5);
  return l_segment;
--
end get_position_desc_no_pos;
--
-- ---------------------------------------------------------------------------
-- |----------------------< get_position_sequence_no >-----------------------|
-- ---------------------------------------------------------------------------
--
function get_position_sequence_no
	(p_person_id            in per_people_f.person_id%type          default NULL
	,p_assignment_id        in per_assignments_f.assignment_id%type default NULL
	,p_effective_date       in date                                 default sysdate
	) return varchar2 is
  --
  l_proc                varchar2(72) := g_package||'get_position_sequence_no';
  l_effective_date      date;
  l_business_group_id   per_all_positions.business_group_id%type;
  l_position_id         per_all_positions.position_id%type;
  l_segment_rec         org_info_rec_type;
  l_segment             per_position_definitions.segment1%type;
  l_asg_pos_by_per_id_found     boolean := FALSE;
  l_asg_pos_by_asg_id_found     boolean := FALSE;
--
begin
  -- hr_utility.set_location('Entering:'||l_proc, 1);
  --
  if p_effective_date is NULL then
    l_effective_date := sysdate;
  else
    l_effective_date := p_effective_date;
  end if;
  --
  retrieve_business_group_id (p_person_id             => p_person_id
			     ,p_assignment_id         => p_assignment_id
			     ,p_effective_date        => l_effective_date
			     ,p_business_group_id     => l_business_group_id);
  if l_business_group_id is NULL then
    -- hr_utility.set_message(8301, 'GHR_38038_API_INV_BG');
    -- hr_utility.raise_error;
    null;
  end if;
  -- hr_utility.set_location(l_proc, 2);
  --
  if p_person_id is NULL and p_assignment_id is NULL then
      -- hr_utility.set_message(8301, 'GHR_38037_API_ARG_ERR');
      -- hr_utility.raise_error;
      null;
  elsif p_assignment_id is NULL then
    for c_asg_pos_by_per_id_rec
		in c_asg_pos_by_per_id (p_person_id, l_effective_date) loop
      l_asg_pos_by_per_id_found := TRUE;
      l_position_id := c_asg_pos_by_per_id_rec.position_id;
      exit;
    end loop;
    if not l_asg_pos_by_per_id_found then
      -- hr_utility.set_message(8301, 'GHR_38023_API_INV_ASG');
      -- hr_utility.raise_error;
      null;
    end if;
  else    -- p_assignment_id is not NULL
    for c_asg_pos_by_asg_id_rec
		in c_asg_pos_by_asg_id (p_assignment_id, l_effective_date) loop
      l_asg_pos_by_asg_id_found := TRUE;
      l_position_id := c_asg_pos_by_asg_id_rec.position_id;
      exit;
    end loop;
    if not l_asg_pos_by_asg_id_found then
      -- hr_utility.set_message(8301, 'GHR_38023_API_INV_ASG');
      -- hr_utility.raise_error;
      null;
    end if;
  end if;
  -- hr_utility.set_location(l_proc, 3);
  --
  retrieve_gov_kff_setup_info (p_business_group_id      => l_business_group_id
			      ,p_org_info_rec           => l_segment_rec);
  if l_segment_rec.information4 is NULL then
    -- hr_utility.set_message(8301, 'GHR_38022_API_GHR_ORG_INFO_ERR');
    -- hr_utility.raise_error;
     null;
  end if;
  -- hr_utility.set_location(l_proc, 4);
  --
  retrieve_segment_information (p_information   => l_segment_rec.information4
			       ,p_id            => l_position_id
			       ,p_code          => 'POS'
                               ,p_effective_date => p_effective_date
			       ,p_segment       => l_segment);
  --
  -- hr_utility.set_location(' Leaving:'||l_proc, 5);
  --
  return l_segment;
--
end get_position_sequence_no;
--
-- ---------------------------------------------------------------------------
-- |--------------------------< get_position_sequence_no_pos >----------------|
-- ---------------------------------------------------------------------------
--
function get_position_sequence_no_pos
	(p_position_id            in per_all_positions.position_id%type
	,p_business_group_id      in per_all_positions.business_group_id%type
	,p_effective_date         in date  default sysdate
  ) return varchar2 IS
  --
  l_proc                varchar2(72) := g_package||'get_position_desc_no_pos';
  l_segment_rec         org_info_rec_type;
  l_segment             per_position_definitions.segment1%type;
--
begin
  -- hr_utility.set_location('Entering:'||l_proc, 1);
  --
  if p_position_id IS NULL OR p_business_group_id IS NULL then
    -- hr_utility.set_message(8301, 'GHR_38037_API_ARG_ERR');
    -- hr_utility.raise_error;
    null;
  end if;
  --
  -- hr_utility.set_location(l_proc, 2);
  --
  retrieve_gov_kff_setup_info (p_business_group_id => p_business_group_id
			      ,p_org_info_rec      => l_segment_rec);
  --
  if l_segment_rec.information4 is NULL then
   --  hr_utility.set_message(8301, 'GHR_38022_API_GHR_ORG_INFO_ERR');
   --  hr_utility.raise_error;
    null;
  end if;
  -- hr_utility.set_location(l_proc, 3);
  --
  retrieve_segment_information (p_information  => l_segment_rec.information4
			       ,p_id           => p_position_id
			       ,p_code         => 'POS'
                               ,p_effective_date => p_effective_date
			       ,p_segment      => l_segment);
  --
  -- hr_utility.set_location(' Leaving:'||l_proc, 5);
  return l_segment;
--
end get_position_sequence_no_pos;
--
-- ---------------------------------------------------------------------------
-- |----------------------< get_position_agency_code >-----------------------|
-- ---------------------------------------------------------------------------
--
function get_position_agency_code
	(p_person_id            in per_people_f.person_id%type          default NULL
	,p_assignment_id        in per_assignments_f.assignment_id%type default NULL
	,p_effective_date       in date                                 default sysdate
	) return varchar2 is
  --
  l_proc                varchar2(72) := g_package||'get_position_agency_code';
  l_effective_date      date;
  l_business_group_id   per_all_positions.business_group_id%type;
  l_position_id         per_all_positions.position_id%type;
  l_segment_rec         org_info_rec_type;
  l_segment             per_position_definitions.segment1%type;
  l_asg_pos_by_per_id_found     boolean := FALSE;
  l_asg_pos_by_asg_id_found     boolean := FALSE;
--
begin
  -- hr_utility.set_location('Entering:'||l_proc, 1);
  --
  if p_effective_date is NULL then
    l_effective_date := sysdate;
  else
    l_effective_date := p_effective_date;
  end if;
  --
  retrieve_business_group_id (p_person_id       => p_person_id
			     ,p_assignment_id         => p_assignment_id
			     ,p_effective_date        => l_effective_date
			     ,p_business_group_id     => l_business_group_id);
  if l_business_group_id is NULL then
    -- hr_utility.set_message(8301, 'GHR_38038_API_INV_BG');
    -- hr_utility.raise_error;
    null;
  end if;
  -- hr_utility.set_location(l_proc, 2);
  --
  if p_person_id is NULL and p_assignment_id is NULL then
      -- hr_utility.set_message(8301, 'GHR_38037_API_ARG_ERR');
      -- hr_utility.raise_error;
      null;
  elsif p_assignment_id is NULL then
    for c_asg_pos_by_per_id_rec
		in c_asg_pos_by_per_id (p_person_id, l_effective_date) loop
      l_asg_pos_by_per_id_found := TRUE;
      l_position_id := c_asg_pos_by_per_id_rec.position_id;
      exit;
    end loop;
    if not l_asg_pos_by_per_id_found then
      -- hr_utility.set_message(8301, 'GHR_38023_API_INV_ASG');
      -- hr_utility.raise_error;
      null;
    end if;
  else    -- p_assignment_id is not NULL
    for c_asg_pos_by_asg_id_rec
		in c_asg_pos_by_asg_id (p_assignment_id, l_effective_date) loop
      l_asg_pos_by_asg_id_found := TRUE;
      l_position_id := c_asg_pos_by_asg_id_rec.position_id;
      exit;
    end loop;
    if not l_asg_pos_by_asg_id_found then
      -- hr_utility.set_message(8301, 'GHR_38023_API_INV_ASG');
      -- hr_utility.raise_error;
      null;
    end if;
  end if;
  -- hr_utility.set_location(l_proc, 3);
  --
  retrieve_gov_kff_setup_info (p_business_group_id      => l_business_group_id
			      ,p_org_info_rec           => l_segment_rec);
  if l_segment_rec.information5 is NULL then
   --  hr_utility.set_message(8301, 'GHR_38022_API_GHR_ORG_INFO_ERR');
   --  hr_utility.raise_error;
     null;
  end if;
  -- hr_utility.set_location(l_proc, 4);
  --
  retrieve_segment_information (p_information   => l_segment_rec.information5
			       ,p_id            => l_position_id
			       ,p_code          => 'POS'
                               ,p_effective_date => p_effective_date
			       ,p_segment       => l_segment);
  --
  -- hr_utility.set_location(' Leaving:'||l_proc, 5);
  --
  return l_segment;
--
end get_position_agency_code;
--
-- ---------------------------------------------------------------------------
-- |--------------------------< get_position_agency_code_pos >----------------|
-- ---------------------------------------------------------------------------
--
function get_position_agency_code_pos
	(p_position_id            in per_all_positions.position_id%type
	,p_business_group_id      in per_all_positions.business_group_id%type
	,p_effective_date         in date  default sysdate
  ) return varchar2 IS
  --
  l_proc                varchar2(72) := g_package||'get_position_agency_code_pos';
  l_segment_rec         org_info_rec_type;
  l_segment             per_position_definitions.segment1%type;
--
begin
  -- hr_utility.set_location('Entering:'||l_proc, 1);
  --
  if p_position_id IS NULL OR p_business_group_id IS NULL then
    -- hr_utility.set_message(8301, 'GHR_38037_API_ARG_ERR');
    -- hr_utility.raise_error;
    null;
  end if;
  --
  -- hr_utility.set_location(l_proc, 2);
  --
  retrieve_gov_kff_setup_info (p_business_group_id => p_business_group_id
			      ,p_org_info_rec      => l_segment_rec);
  --
  if l_segment_rec.information5 is NULL then
   --  hr_utility.set_message(8301, 'GHR_38022_API_GHR_ORG_INFO_ERR');
   --  hr_utility.raise_error;
     null;
  end if;
  -- hr_utility.set_location(l_proc, 3);
  --
  retrieve_segment_information (p_information  => l_segment_rec.information5
			       ,p_id           => p_position_id
			       ,p_code         => 'POS'
			       ,p_segment      => l_segment
                               ,p_effective_date => p_effective_date);
  --
  -- hr_utility.set_location(' Leaving:'||l_proc, 5);
  return l_segment;
--
end get_position_agency_code_pos;
--
-- ---------------------------------------------------------------------------
-- |---------------------< get_job_occupational_series >---------------------|
-- ---------------------------------------------------------------------------
--
function get_job_occupational_series
	(p_person_id            in per_people_f.person_id%type          default NULL
	,p_assignment_id        in per_assignments_f.assignment_id%type default NULL
	,p_effective_date       in date                                 default sysdate
	) return varchar2 is
  --
  l_proc                varchar2(72) := g_package||'get_job_occupational_series';
  l_effective_date      date;
  l_business_group_id   per_all_positions.business_group_id%type;
  l_job_id              per_jobs.job_id%type;
  l_segment_rec         org_info_rec_type;
  l_segment             per_position_definitions.segment1%type;
  l_asg_job_by_per_id_found     boolean := FALSE;
  l_asg_job_by_asg_id_found     boolean := FALSE;
--
begin
  -- hr_utility.set_location('Entering:'||l_proc, 1);
  --
  if p_effective_date is NULL then
    l_effective_date := sysdate;
  else
    l_effective_date := p_effective_date;
  end if;
  --
  retrieve_business_group_id (p_person_id             => p_person_id
			     ,p_assignment_id         => p_assignment_id
			     ,p_effective_date        => l_effective_date
			     ,p_business_group_id     => l_business_group_id);
  if l_business_group_id is NULL then
    -- hr_utility.set_message(8301, 'GHR_38038_API_INV_BG');
    -- hr_utility.raise_error;
    null;
  end if;
  -- hr_utility.set_location(l_proc, 2);
  --
  if p_person_id is NULL and p_assignment_id is NULL then
      -- hr_utility.set_message(8301, 'GHR_38037_API_ARG_ERR');
      -- hr_utility.raise_error;
      null;
  elsif p_assignment_id is NULL then

    for c_asg_job_by_per_id_rec
		in c_asg_job_by_per_id (p_person_id, l_effective_date) loop
      l_asg_job_by_per_id_found := TRUE;
      l_job_id := c_asg_job_by_per_id_rec.job_id;
      exit;
    end loop;
    if not l_asg_job_by_per_id_found then
      -- hr_utility.set_message(8301, 'GHR_38023_API_INV_ASG');
      -- hr_utility.raise_error;
      null;
    end if;
  else    -- p_assignment_id is not NULL
    for c_asg_job_by_asg_id_rec
		in c_asg_job_by_asg_id (p_assignment_id, l_effective_date) loop
      l_asg_job_by_asg_id_found := TRUE;
      l_job_id := c_asg_job_by_asg_id_rec.job_id;
      exit;
    end loop;
    if not l_asg_job_by_asg_id_found then
      -- hr_utility.set_message(8301, 'GHR_38023_API_INV_ASG');
      -- hr_utility.raise_error;
      null;
    end if;
  end if;
  -- hr_utility.set_location(l_proc, 3);
  --
  retrieve_gov_kff_setup_info (p_business_group_id      => l_business_group_id
			      ,p_org_info_rec           => l_segment_rec);
  if l_segment_rec.information1 is NULL then
   --  hr_utility.set_message(8301, 'GHR_38022_API_GHR_ORG_INFO_ERR');
   --  hr_utility.raise_error;
     null;
  end if;
  -- hr_utility.set_location(l_proc, 4);
  --
  retrieve_segment_information (p_information   => l_segment_rec.information1
			       ,p_id            => l_job_id
			       ,p_code          => 'JOB'
			       ,p_segment       => l_segment);
  --
  -- hr_utility.set_location(' Leaving:'||l_proc, 5);
  --
  return l_segment;
--
end get_job_occupational_series;
--
-- ---------------------------------------------------------------------------
-- |---------------------< get_job_occ_series_job >---------------------------|
-- ---------------------------------------------------------------------------
--
function get_job_occ_series_job
	(p_job_id              in per_jobs.job_id%type
	,p_business_group_id   in per_all_positions.business_group_id%type
  ) return varchar2 IS
  --
  l_proc                varchar2(72) := g_package||'get_job_occ_series_job';
  l_segment_rec         org_info_rec_type;
  l_segment             per_position_definitions.segment1%type;
--
begin
  -- hr_utility.set_location('Entering:'||l_proc, 1);
  --
  if p_job_id IS NULL OR p_business_group_id IS NULL then
    -- hr_utility.set_message(8301, 'GHR_38037_API_ARG_ERR');
    -- hr_utility.raise_error;
    null;
  end if;
  --
  -- hr_utility.set_location(l_proc, 2);
  --
  retrieve_gov_kff_setup_info (p_business_group_id      => p_business_group_id
			      ,p_org_info_rec           => l_segment_rec);
  if l_segment_rec.information1 is NULL then
   --  hr_utility.set_message(8301, 'GHR_38022_API_GHR_ORG_INFO_ERR');
   --  hr_utility.raise_error;
     null;
  end if;
  -- hr_utility.set_location(l_proc, 3);
  --
  retrieve_segment_information (p_information   => l_segment_rec.information1
			       ,p_id            => p_job_id
			       ,p_code          => 'JOB'
			       ,p_segment       => l_segment
                               );
  --
  -- hr_utility.set_location(' Leaving:'||l_proc, 4);
  --
  return l_segment;
--
end get_job_occ_series_job;
--
-- ---------------------------------------------------------------------------
-- |-----------------------< sf52_from_data_elements >-----------------------|
-- ---------------------------------------------------------------------------
--
procedure sf52_from_data_elements
      (p_person_id                 in  per_people_f.person_id%type      default NULL
	,p_assignment_id         IN OUT NOCOPY  per_assignments_f.assignment_id%type
      ,p_effective_date            in  date                             default sysdate
-- vsm added following 2 parameters
      ,p_altered_pa_request_id     in  number
      ,p_noa_id_corrected          in  number
-- vsm added pa_history_id
	,p_pa_history_id              in number
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
      ,p_work_schedule             OUT NOCOPY varchar2
      ) is
  --
  l_proc                varchar2(72) := g_package||'sf52_from_by_assignment';
  l_organization_id     hr_organization_units.organization_id%type;
  l_position_id         per_all_positions.position_id%type;
  l_job_id              per_jobs.job_id%type;
  l_grade_id            per_grades.grade_id%type;
  l_location_id         hr_locations.location_id%type;
  l_total_salary        number;
  l_basic_pay           number;
  l_locality_adj        number;
  l_adj_basic_pay       number;
  l_other_pay           number;
  l_au_overtime                 NUMBER;
  l_auo_premium_pay_indicator   VARCHAR2(30);
  l_availability_pay            NUMBER;
  l_ap_premium_pay_indicator    VARCHAR2(30);
  l_retention_allowance         NUMBER;
  l_retention_allow_percentage  NUMBER;
  l_supervisory_differential    NUMBER;
  l_supervisory_diff_percentage NUMBER;
  l_staffing_differential       NUMBER;
  l_staffing_diff_percentage    NUMBER;
  l_org_info_rec        org_info_rec_type;
  l_multi_error_flag    boolean;
  l_asg_by_per_id_found boolean := FALSE;
  l_asg_by_asg_id_found boolean := FALSE;
  l_organization_found  boolean := FALSE;
  l_location_found      boolean := FALSE;
  l_grade_kff_found     boolean := FALSE;
  l_assignment_ddf_found boolean := FALSE;
  l_position_ddf_found  boolean := FALSE;
  l_asg_ei_data         per_assignment_extra_info%rowtype;
  l_pos_ei_data         per_position_extra_info%rowtype;
  l_element_entry_data  pay_element_entry_values_f%rowtype;
  l_org_id              hr_organization_units.organization_id%type;
--vsm
  l_business_group_id   per_business_groups.business_group_id%type;
  l_result_code         varchar2(30);
  l_assignment_data     per_all_assignments_f%rowtype;
  l_person_type         per_person_types.system_person_type%type;
  l_effective_date      date;
  l_assignment_id       per_assignments_f.assignment_id%type;
  v_assignment_id       per_assignments_f.assignment_id%type;
  l_session             ghr_history_api.g_session_var_type;
  l_pa_request_id       ghr_pa_requests.pa_request_id%type;
  l_retained_grade      ghr_pay_calc.retained_grade_rec_type;
  l_update34_date       date;
  -- FWFA Changes Bug#4444609
  l_pay_basis           varchar2(30);
  l_pay_table_identifier NUMBER(10);
  -- FWFA Changes

  --
  -- Cursor to get person type
  cursor c_person_type is
    select system_person_type
    from   per_all_people_f ppf,
           per_person_types ppt
    where  ppf.person_id      = p_person_id
    and    ppt.person_type_id = ppf.person_type_id;
 --
  cursor c_assignment_by_per_id (per_id number, eff_date date) is
	select asg.assignment_id,
	       asg.organization_id,
	       asg.job_id,
	       asg.position_id,
	       asg.grade_id,
             asg.location_id
	  from per_all_assignments_f asg
	 where asg.person_id = per_id
           and asg.assignment_type <> 'B'
	   and trunc(eff_date) between asg.effective_start_date
				   and asg.effective_end_date
	   and asg.primary_flag = 'Y';
  --
   Cursor c_assignment_ex_emp is
   select asg.effective_end_date,asg.assignment_id,asg.organization_id,
               asg.job_id,
               asg.position_id,
               asg.grade_id,
             asg.location_id
          from per_all_assignments_f asg
         where asg.person_id = p_person_id
           and asg.assignment_type <> 'B'
           and asg.effective_start_date < p_effective_date
           and asg.primary_flag = 'Y'
          order by asg.effective_start_date desc;
 --
  CURSOR c_asg_by_per_id_not_prim (p_per_id number, p_eff_date date) IS
    SELECT asg.assignment_id,
           asg.organization_id,
           asg.job_id,
           asg.position_id,
           asg.grade_id,
           asg.location_id
    FROM   per_all_assignments_f asg
    WHERE  asg.person_id = p_per_id
    AND    asg.assignment_type <> 'B'
    AND    trunc(p_eff_date) BETWEEN asg.effective_start_date AND asg.effective_end_date
    ORDER BY asg.assignment_id;
  --
  cursor c_assignment_by_asg_id (asg_id number, eff_date date) is
	select asg.organization_id,
	       asg.job_id,
	       asg.position_id,
	       asg.grade_id,
             asg.location_id
	  from per_all_assignments_f asg
	 where asg.assignment_id = asg_id
           and asg.assignment_type <> 'B'
	   and trunc(eff_date) between asg.effective_start_date
				   and asg.effective_end_date;
  --

  cursor c_grade_kff (grd_id number) is
	select gdf.segment1,
	       gdf.segment2
	  from per_grades grd,
	       per_grade_definitions gdf
	 where grd.grade_id = grd_id
	   and grd.grade_definition_id = gdf.grade_definition_id;
  --
  cursor c_assignment_ddf (asg_id number) is
	select aei.aei_information3,
	       aei.aei_information6
	  from per_assignment_extra_info aei
	 where aei.assignment_id = asg_id
	   and aei.information_type = 'GHR_US_ASG_SF52';
  --
  cursor c_position_ddf (pos_id number) is
	select poi.poei_information6
	  from per_position_extra_info poi
	 where poi.position_id = pos_id
	   and poi.information_type = 'GHR_US_POS_VALID_GRADE';


  cursor c_org_address (org_id number) is
	select oi.org_information5,
	       oi.org_information6,
	       oi.org_information7,
	       oi.org_information8,
	       oi.org_information9,
             oi.org_information10
	  from hr_organization_information oi
	 where oi.organization_id = org_id
	   and oi.org_information_context = 'GHR_US_ORG_REPORTING_INFO';

----
----For Better Performance it was suggested that the last line in the below
----Query to be eliminated. Customer suggested to put the paranthesis one line up.
----Bug 2770551. AVR Suggested 20-JAN-03.
----
/**** Commented the original...
  Cursor c_job_id is
     select job_id, business_group_id
     from   ghr_assignments_h_v
     where  pa_request_id =
           (select min(pa_request_id)
            from   ghr_pa_requests
            connect by pa_request_id  = prior altered_pa_request_id
            start with  pa_request_id = p_altered_pa_request_id
            and nature_of_action_id   = p_noa_id_corrected
             );
     --order by pa_history_id desc;

*/

  Cursor c_job_id is
     select job_id, business_group_id
     from   ghr_assignments_h_v
     where  pa_request_id =
           (select min(pa_request_id)
            from   ghr_pa_requests
            connect by pa_request_id  = prior altered_pa_request_id
            start with  pa_request_id = p_altered_pa_request_id
             );
     --order by pa_history_id desc;

  Cursor  c_orig_par_id is
    select      min(pa_request_id) pa_request_id
                from            ghr_pa_requests
                connect by      pa_request_id = prior altered_pa_request_id
                start with      pa_request_id = p_altered_pa_request_id;

  Cursor c_orig_par_rec is
    Select par.employee_assignment_id,
          par.from_adj_basic_pay,
          par.from_basic_pay,
          par.from_grade_or_level,
          par.from_locality_adj,
          par.from_occ_code,
          par.from_office_symbol,
          par.from_other_pay_amount,
          par.from_pay_basis,
          par.from_pay_plan,
          par.from_position_id,
          par.from_position_org_line1,
          par.from_position_org_line2,
          par.from_position_org_line3,
          par.from_position_org_line4,
          par.from_position_org_line5,
          par.from_position_org_line6,
          par.from_position_seq_no,
          par.from_position_title,
          par.from_position_number,
	  -- FWFA Changes Bug#4444609
	  par.from_pay_table_identifier,
	  -- FWFA Changes
          par.from_step_or_rate,
          par.from_total_salary
   from   ghr_pa_requests par
   where  pa_request_id = l_pa_request_id;
 --
 --
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  l_effective_date := p_effective_date;
  l_assignment_id  := p_assignment_id;

  --Initilization for NOCOPY Changes
  --
  v_assignment_id  := p_assignment_id;
  --
    If p_noa_id_corrected is not null or p_altered_pa_request_id is not null then
    -- get original RPA , the very first;
      for orig_par_id in c_orig_par_id loop
          l_pa_request_id := orig_par_id.pa_request_id;
      end loop;
      for orig_par_rec in c_orig_par_rec loop
      p_assignment_id        := orig_par_rec.employee_assignment_id;
      p_position_title       := orig_par_rec.from_position_title;
      p_position_number      := orig_par_rec.from_position_number;
      p_position_seq_no      := orig_par_rec.from_position_seq_no;
      p_pay_plan             := orig_par_rec.from_pay_plan;
      -- FWFA Changes Bug#4444609
      p_pay_table_identifier         := orig_par_rec.from_pay_table_identifier;
      -- FWFA Changes
      p_occ_code             := orig_par_rec.from_occ_code;
      --p_grade_id
      p_grade_or_level       := orig_par_rec.from_grade_or_level;
      p_step_or_rate         := orig_par_rec.from_step_or_rate;
      p_total_salary         := orig_par_rec.from_total_salary;
      p_pay_basis            := orig_par_rec.from_pay_basis;
      p_basic_pay            := orig_par_rec.from_basic_pay;
      p_locality_adj         := orig_par_rec.from_locality_adj;
      p_adj_basic_pay        := orig_par_rec.from_adj_basic_pay;
      p_other_pay            := orig_par_rec.from_other_pay_amount;
      p_position_id          := orig_par_rec.from_position_id;
      p_position_org_line1   := orig_par_rec.from_position_org_line1;
      p_position_org_line2   := orig_par_rec.from_position_org_line2;
      p_position_org_line3   := orig_par_rec.from_position_org_line3;
      p_position_org_line4   := orig_par_rec.from_position_org_line4;
      p_position_org_line5   := orig_par_rec.from_position_org_line5;
      p_position_org_line6   := orig_par_rec.from_position_org_line6;

 end loop;
    ghr_history_fetch.fetch_assignment
                ( p_assignment_id         => p_assignment_id
                 ,p_date_effective        => l_effective_date
                 ,p_altered_pa_request_id => p_altered_pa_request_id
                 ,p_noa_id_corrected      => p_noa_id_corrected
                 ,p_assignment_data       => l_assignment_data
                 ,p_pa_history_id         => p_pa_history_id
                 ,p_result_code           => l_result_code);
    if l_result_code = 'not_found' then
        null;
        -- raise error.
    end if;
    p_duty_station_location_id   := l_assignment_data.location_id;

    --6850492
    p_job_id          := l_assignment_data.job_id;
    p_organization_id := l_assignment_data.organization_id;
    p_grade_id        := l_assignment_data.grade_id;
    --6850492

    Ghr_History_Fetch.Fetch_ASGEI_prior_root_sf50(
        p_assignment_id         => p_assignment_id,
        p_information_type      => 'GHR_US_ASG_SF52',
        p_date_effective                => l_effective_date,
        p_altered_pa_request_id => p_altered_pa_request_id,
        p_noa_id_corrected      => p_noa_id_corrected,
        p_get_ovn_flag          => 'Y',
        p_asgei_data            => l_asg_ei_data
       );
    p_work_schedule          :=   l_asg_ei_data.aei_information7;
    p_pay_rate_determinant   :=  l_asg_ei_data.aei_information6;

Else

  for per_type in c_per_type(p_person_id,l_effective_date) loop
    l_person_type := per_type.system_person_type;
  end loop;

  -- VSM added following if stmt. and the TRUE result code to take care of refresh of correction SF52.
  if p_altered_pa_request_id is not NULL and
     p_noa_id_corrected is not NULL then
    if p_assignment_id is NULL then
        hr_utility.set_message(8301, 'GHR_38037_API_ARG_ERR');
        hr_utility.raise_error;
    else
        ghr_history_fetch.fetch_assignment
		( p_assignment_id         => p_assignment_id
		 ,p_date_effective        => p_effective_date
 		 ,p_altered_pa_request_id => p_altered_pa_request_id
		 ,p_noa_id_corrected      => p_noa_id_corrected
		 ,p_assignment_data       => l_assignment_data
		 ,p_pa_history_id         => p_pa_history_id
		 ,p_result_code           => l_result_code);
        if l_result_code = 'not_found' then
            null;
            -- raise error.
        end if;
        p_duty_station_location_id   := l_assignment_data.location_id;
        l_position_id     := l_assignment_data.position_id;
        l_organization_id := l_assignment_data.organization_id;
        l_job_id          := l_assignment_data.job_id;
        l_grade_id        := l_assignment_data.grade_id;
    end if;

  else
    if p_person_id is NULL and p_assignment_id is NULL then
        hr_utility.set_message(8301, 'GHR_38037_API_ARG_ERR');
        hr_utility.raise_error;
    elsif p_assignment_id is NULL then
      -- If we were not given an assignment id then we need to get the 'default'
      -- assignment. The definition of 'default' assignment is not yet clearly
      -- defined!
      -- Every person must have at least one assignment, now if they are an
      -- 'employee' then the 'default' will be the primary assignment (i.e. primary_flag = 'Y')
      -- since a person can have only one primary assignment.
      -- However if you are an 'applicant' we do not know which assignment to choose as
      -- they apparently do not have a primary assignment hence for the moment just chose the first
      -- one!!
      -- It is also not clear at the moment the exact definition of an 'employee' as opposed
      -- to an 'applicant'.
      -- In conclusion to all this we will first try and get the 'primary' assignment and
      -- if there isn't one we will just get the first one we can!
       for per_type in c_per_type(p_person_id,l_effective_date) loop
         l_person_type := per_type.system_person_type;
       end loop;
       If l_person_type = 'EX_EMP' then
         hr_utility.set_location('Ex Employee in conversion action',1);
         for c_assignment_ex_emp_rec in c_assignment_ex_emp loop
           l_asg_by_per_id_found := TRUE;
           l_effective_date  := c_assignment_ex_emp_rec.effective_end_date;
           p_assignment_id   := c_assignment_ex_emp_rec.assignment_id;
           l_organization_id := c_assignment_ex_emp_rec.organization_id;
           l_job_id          := c_assignment_ex_emp_rec.job_id;
           l_position_id     := c_assignment_ex_emp_rec.position_id;
           l_grade_id        := c_assignment_ex_emp_rec.grade_id;
           p_duty_station_location_id   := c_assignment_ex_emp_rec.location_id;

           EXIT;
         END LOOP;

 Else
      --RP
      if l_person_type = 'EX_EMP' then
         hr_utility.set_location('Ex Employee in conversion action with asg id',1);
         for c_assignment_ex_emp_rec in c_assignment_ex_emp loop
           l_asg_by_per_id_found := TRUE;
           l_effective_date  := c_assignment_ex_emp_rec.effective_end_date;
           p_assignment_id   := c_assignment_ex_emp_rec.assignment_id;
           l_organization_id := c_assignment_ex_emp_rec.organization_id;
           l_job_id          := c_assignment_ex_emp_rec.job_id;
           l_position_id     := c_assignment_ex_emp_rec.position_id;
           l_grade_id        := c_assignment_ex_emp_rec.grade_id;
           p_duty_station_location_id   := c_assignment_ex_emp_rec.location_id;
           EXIT;
         END LOOP;
     Else

      FOR c_assignment_by_per_id_rec in c_assignment_by_per_id (p_person_id, l_effective_date) LOOP
        l_asg_by_per_id_found := TRUE;
        --
        p_assignment_id   := c_assignment_by_per_id_rec.assignment_id;
        l_organization_id := c_assignment_by_per_id_rec.organization_id;
        l_job_id          := c_assignment_by_per_id_rec.job_id;
        l_position_id     := c_assignment_by_per_id_rec.position_id;
        l_grade_id        := c_assignment_by_per_id_rec.grade_id;
        p_duty_station_location_id   := c_assignment_by_per_id_rec.location_id;
        EXIT;
      END LOOP;
  IF NOT l_asg_by_per_id_found THEN
        -- Couldn't get a primary assignment so try for any other
        --
        FOR c_asg_by_per_id_not_prim_rec in c_asg_by_per_id_not_prim (p_person_id, l_effective_date)
LOOP
          l_asg_by_per_id_found := TRUE;
          --
          p_assignment_id   := c_asg_by_per_id_not_prim_rec.assignment_id;
          l_organization_id := c_asg_by_per_id_not_prim_rec.organization_id;
          l_job_id          := c_asg_by_per_id_not_prim_rec.job_id;
          l_position_id     := c_asg_by_per_id_not_prim_rec.position_id;
          l_grade_id        := c_asg_by_per_id_not_prim_rec.grade_id;
          p_duty_station_location_id     := c_asg_by_per_id_not_prim_rec.location_id;

          EXIT;
        END LOOP;
        --
      END IF;
     End if;
      --
      IF NOT l_asg_by_per_id_found THEN
        hr_utility.set_message(8301, 'GHR_38023_API_INV_ASG');
        hr_utility.raise_error;
      END IF;
    End if;
 ELSE    -- p_assignment_id is not NULL
       hr_utility.set_location('asg id is not  null  : Asg Id : ' || p_assignment_id,1);
      If l_person_type = 'EX_EMP' then
        hr_utility.set_location('Ex Employee in conversion action',1);
        for c_assignment_ex_emp_rec in c_assignment_ex_emp loop
          l_asg_by_asg_id_found   := TRUE;
           hr_utility.set_location('Ex Employee - with Asg , value found ',1);
          l_effective_date  := c_assignment_ex_emp_rec.effective_end_date;
          p_assignment_id   := c_assignment_ex_emp_rec.assignment_id;
          l_organization_id := c_assignment_ex_emp_rec.organization_id;
          l_job_id          := c_assignment_ex_emp_rec.job_id;
          l_position_id     := c_assignment_ex_emp_rec.position_id;
          l_grade_id        := c_assignment_ex_emp_rec.grade_id;
          p_duty_station_location_id   := c_assignment_ex_emp_rec.location_id;
          EXIT;
        END LOOP;
      Else
        for c_assignment_by_asg_id_rec
          in c_assignment_by_asg_id (p_assignment_id, l_effective_date) loop
          l_asg_by_asg_id_found   := TRUE;
          l_organization_id       := c_assignment_by_asg_id_rec.organization_id;
          l_job_id                := c_assignment_by_asg_id_rec.job_id;
          l_position_id           := c_assignment_by_asg_id_rec.position_id;
          l_grade_id              := c_assignment_by_asg_id_rec.grade_id;
          p_duty_station_location_id     := c_assignment_by_asg_id_rec.location_id;
          exit;
        end loop;
 End if;
      if not l_asg_by_asg_id_found then
        hr_utility.set_message(8301, 'GHR_38023_API_INV_ASG');
        hr_utility.raise_error;
      end if;
    END IF;
  END IF;

  p_position_id     := l_position_id;
  p_organization_id := l_organization_id;
  p_job_id          := l_job_id;
  p_grade_id        := l_grade_id;

  hr_utility.set_location(l_proc, 2);

  if p_altered_pa_request_id is not NULL and
     p_noa_id_corrected is not NULL then
    hr_utility.set_location(l_proc, 104);

   /* retrieve_business_group_id
	( p_person_id             => p_person_id,
        p_effective_date        => l_effective_date,
        p_altered_pa_request_id => p_altered_pa_request_id,
        p_noa_id_corrected      => p_noa_id_corrected,
        p_pa_history_id         => p_pa_history_id,
        p_business_group_id     => l_business_group_id
	);

    p_position_title := get_position_title_pos
	(p_position_id            => l_position_id
	,p_business_group_id      => l_business_group_id ) ;

    p_position_number := get_position_desc_no_pos
	(p_position_id         => l_position_id
	,p_business_group_id   => l_business_group_id);

    p_position_seq_no := get_position_sequence_no_pos
	(p_position_id       => l_position_id
	,p_business_group_id => l_business_group_id);

    */
  else
    --
    --  Retrieve Position Title
    --
    p_position_title := get_position_title (p_person_id           => p_person_id
					 ,p_assignment_id       => p_assignment_id
					 ,p_effective_date      => l_effective_date);
    hr_utility.set_location(l_proc, 3);
    --
    --  Retrieve Position Number
    --
    p_position_number := get_position_description_no
				(p_person_id            => p_person_id
				,p_assignment_id        => p_assignment_id
				,p_effective_date       => l_effective_date);

    p_position_seq_no := get_position_sequence_no
				(p_person_id            => p_person_id
				,p_assignment_id        => p_assignment_id
				,p_effective_date       => l_effective_date);
  END IF;

  hr_utility.set_location(l_proc, 4);
  --
  --  Retrieve Grade Key Flexfield Information
  --
  for c_grade_kff_rec in c_grade_kff (l_grade_id) loop
    l_grade_kff_found   := TRUE;
    p_pay_plan          := c_grade_kff_rec.segment1;
    p_grade_or_level    := c_grade_kff_rec.segment2;
    exit;
  end loop;
  if not l_grade_kff_found then
   -- hr_utility.set_message(8301, 'GHR_38026_API_INV_GRD');
   -- hr_utility.raise_error;
   null;
  end if;
  hr_utility.set_location(l_proc, 5);
  --
  --  Retrieve Job Occupational Series
  --
  ghr_history_api.get_g_session_var(l_session);
   hr_utility.set_location('p_assignment id before getting job is ' || p_assignment_id,1);
if l_session.noa_id_correct is null then --RP
     p_occ_code := get_job_occupational_series (p_person_id        => p_person_id
                                            ,p_assignment_id    => p_assignment_id
                                            ,p_effective_date   => l_effective_date);
  else
    for job_id_rec in c_job_id loop
      l_job_id :=  job_id_rec.job_id;
      l_business_group_id := job_id_rec.business_group_id;
      exit;
    end loop;
     p_occ_code := get_job_occ_series_job (p_job_id        => l_job_id
                                          ,p_business_group_id => l_business_group_id);
  end if; --RP
 hr_utility.set_location(l_proc, 6);


-- VSM added following 2 parameters to all the calls to GHR_History_Fetch procedures
--                         ,p_altered_pa_request_id => p_altered_pa_request_id
--                         ,p_noa_id_corrected      => p_noa_id_corrected


  --
  --  Retrieve Assignment Developer Descriptive Flexfield Information
  --

   -- This procedures uses session variables for p_altered)pa_request_id and p_noa_id_corrected
   ghr_history_fetch.fetch_asgei (p_assignment_id         => p_assignment_id
                                 ,p_information_type      => 'GHR_US_ASG_SF52'
                                 ,p_date_effective        => l_effective_date
                                 ,p_asg_ei_data           => l_asg_ei_data
                                 );

   p_step_or_rate           :=  l_asg_ei_data.aei_information3;

  hr_utility.set_location(l_proc, 7);
  --
  --  Retrieve Position Developer Descriptive Flexfield Information
  --
  -- This procedures uses session variables for p_altered)pa_request_id and p_noa_id_corrected
   ghr_history_fetch.fetch_positionei (p_position_id           => l_position_id
                                      ,p_information_type      => 'GHR_US_POS_VALID_GRADE'
                                      ,p_date_effective        => l_effective_date
                                      ,p_pos_ei_data           => l_pos_ei_data
                                      );
      -- FWFA Changes Bug# 4444609
      l_pay_basis            :=  l_pos_ei_data.poei_information6;
      l_pay_table_identifier := l_pos_ei_data.poei_information5;
      -- FWFA Changes

  hr_utility.set_location(l_proc, 8);
  --
    -- Retrieve work_Schedule  -- (Added for OGSD)

  If p_assignment_id is null then
     ghr_history_fetch.fetch_positionei (p_position_id           => l_position_id
                                        ,p_information_type      => 'GHR_US_POS_GRP1'
                                        ,p_date_effective        => l_effective_date
                                        ,p_pos_ei_data           => l_pos_ei_data
                                        );

   p_work_Schedule              :=  l_pos_ei_data.poei_information10;
   hr_utility.set_location(l_proc,9);
  Else

    -- VSM Prior PRD and Work Schedule
    Ghr_History_Fetch.Fetch_ASGEI_prior_root_sf50(
	p_assignment_id		=> p_assignment_id,
	p_information_type	=> 'GHR_US_ASG_SF52',
	p_date_effective		=> l_effective_date,
	p_altered_pa_request_id	=> p_altered_pa_request_id,
	p_noa_id_corrected	=> p_noa_id_corrected,
      p_get_ovn_flag          => 'Y',
  	p_asgei_data		=> l_asg_ei_data);

    p_work_schedule          :=   l_asg_ei_data.aei_information7;
    p_pay_rate_determinant   :=  l_asg_ei_data.aei_information6;

  End if;

 --Start New Retained Grade Processing
   hr_utility.set_location('PRD is ' ||p_pay_rate_determinant,9);
  IF p_pay_rate_determinant IN ('A','B','E','F','U','V') THEN
    -- use retained details...
    BEGIN
      l_retained_grade :=
        ghr_pc_basic_pay.get_retained_grade_details
               (p_person_id
               ,l_effective_date);
      EXCEPTION
      WHEN OTHERS THEN
           BEGIN
             l_retained_grade :=
               ghr_pc_basic_pay.get_retained_grade_details
                      (p_person_id
                      ,(l_effective_date - 1));
             EXCEPTION
             WHEN OTHERS THEN
             hr_utility.set_message(8301,'GHR_38699_MISSING_RETAINED_DET');
             hr_utility.raise_error;
           END;
    END;
   if l_retained_grade.temp_step is NULL THEN -- Temp. Promo RG Changes
    l_update34_date := ghr_pay_caps.update34_implemented_date(p_person_id);
   hr_utility.set_location('Update 34 date is ' ||l_update34_date,10);
   hr_utility.set_location('Effective date is ' ||l_effective_date,11);
    if l_update34_date is not null AND l_effective_date >= l_update34_date then
       p_pay_basis := l_retained_grade.pay_basis;
       -- FWFA Changes Bug#4444609
       p_pay_table_identifier := l_retained_grade.user_table_id;
       -- FWFA Changes
   hr_utility.set_location('RET 1 pay basis is ' ||p_pay_basis,11);
    else
       -- FWFA Changes Bug#4444609
       -- Modified the p_pay_basis assignment to l_pay_basis as there may be a chance of
       -- l_pos_ei_data.poei_information6 could be of GHR_US_POS_GRP1
       p_pay_table_identifier := l_pay_table_identifier;
       p_pay_basis := l_pay_basis;
       -- FWFA Changes
   hr_utility.set_location('POS 1 pay basis is ' ||p_pay_basis,11);
    end if;
  ELSE
     -- FWFA Changes Bug#4444609
     -- Modified the p_pay_basis assignment to l_pay_basis as there may be a chance of
     -- l_pos_ei_data.poei_information6 could be of GHR_US_POS_GRP1
     p_pay_table_identifier := l_pay_table_identifier;
     p_pay_basis := l_pay_basis;
     -- FWFA Changes
  END IF;
  ELSE
     -- FWFA Changes Bug#4444609
       -- Modified the p_pay_basis assignment to l_pay_basis as there may be a chance of
       -- l_pos_ei_data.poei_information6 could be of GHR_US_POS_GRP1
       p_pay_table_identifier := l_pay_table_identifier;
       p_pay_basis := l_pay_basis;
       -- FWFA Changes
   hr_utility.set_location('POS 2 pay basis is ' ||p_pay_basis,11);
  END IF;
   hr_utility.set_location('Final from pay basis is ' ||p_pay_basis,11);
 --End New Retained Grade Processing

-- Changed for Basic Salary Rate
--
  retrieve_element_entry_value (p_element_name          => 'Basic Salary Rate'
			       ,p_input_value_name      => 'Rate'
			       ,p_assignment_id         => p_assignment_id
			       ,p_effective_date        => l_effective_date
			       ,p_value                 => l_basic_pay
			       ,p_multiple_error_flag   => l_multi_error_flag);
/*  if l_basic_pay is NULL then
    l_basic_pay := 0;
  end if;
*/
  if l_multi_error_flag then
    hr_utility.set_message(8301, 'GHR_38014_API_MULTI_ELE_ENTR');
    hr_utility.raise_error;
  end if;
  --

 -- FWFA Changes Bug#4444609 Modified 'Locality Pay' to 'Locality Pay or SR Supplement'
 retrieve_element_entry_value (p_element_name           => 'Locality Pay or SR Supplement'
 -- FWFA Changes
                               ,p_input_value_name      => 'Rate'
-- Changed from 'Amount' to 'Rate' by Ashu Gupta
			       ,p_assignment_id         => p_assignment_id
			       ,p_effective_date        => l_effective_date
			       ,p_value                 => l_locality_adj
			       ,p_multiple_error_flag   => l_multi_error_flag);
  /*if l_locality_adj is NULL then
    l_locality_adj := 0;
  end if;
  */
  if l_multi_error_flag then
    hr_utility.set_message(8301, 'GHR_38014_API_MULTI_ELE_ENTR');
    hr_utility.raise_error;
  end if;
  --

-- Processing Total Pay and Adjusted Basic Pay
-- NAME    DATE       BUG           COMMENTS
-- Ashley  17-JUL-03  Payroll Intg  Modified the Input Value name
--                                  Changes from Total Salary -> Amount
--                                               Adjusted Pay -> Amount
--

  retrieve_element_entry_value (p_element_name    => 'Adjusted Basic Pay'
			       ,p_input_value_name      => 'Amount'
			       ,p_assignment_id         => p_assignment_id
			       ,p_effective_date        => l_effective_date
			       ,p_value                 => l_adj_basic_pay
			       ,p_multiple_error_flag   => l_multi_error_flag);
  /*if l_adj_basic_pay is NULL then
    l_adj_basic_pay := 0;
  end if;
  */
  if l_multi_error_flag then
    hr_utility.set_message(8301, 'GHR_38014_API_MULTI_ELE_ENTR');
    hr_utility.raise_error;
  end if;
--
--
  --  7/28/97 Added retrieval of Other pay and the 7 items that make it up!
  retrieve_element_entry_value (p_element_name    =>'Other Pay'
			       ,p_input_value_name      => 'Amount'
			       ,p_assignment_id         => p_assignment_id
			       ,p_effective_date        => l_effective_date
			       ,p_value                 => l_other_pay
			       ,p_multiple_error_flag   => l_multi_error_flag);
  /*if l_other_pay is NULL then
    l_other_pay := 0;
  end if;
  */
  if l_multi_error_flag then
    hr_utility.set_message(8301, 'GHR_38014_API_MULTI_ELE_ENTR');
    hr_utility.raise_error;
  end if;
  --


  retrieve_element_entry_value (p_element_name    => 'Total Pay'
			       ,p_input_value_name      => 'Amount'
			       ,p_assignment_id         => p_assignment_id
			       ,p_effective_date        => l_effective_date
			       ,p_value                 => l_total_salary
			       ,p_multiple_error_flag   => l_multi_error_flag);
 /* if l_total_salary is NULL then
    l_total_salary := 0;
  end if;
 */
  if l_multi_error_flag then
    hr_utility.set_message(8301, 'GHR_38014_API_MULTI_ELE_ENTR');
    hr_utility.raise_error;
  end if;
  --
  --
  p_total_salary                := round(l_total_salary,2);
  p_basic_pay                   := round(l_basic_pay,2);
  p_locality_adj                := round(l_locality_adj,0);
  p_adj_basic_pay               := round(l_adj_basic_pay,2);
  p_other_pay                   := l_other_pay;
  --
  --  Retrieve Organzation Information
  --
  hr_utility.set_location(l_proc, 9);
  --
  -- Retrieve Position's Organization's address lines


   ghr_history_fetch.fetch_positionei (p_position_id           => l_position_id
                                      ,p_information_type      => 'GHR_US_POS_GRP1'
                                      ,p_date_effective        => p_effective_date
                                      ,p_pos_ei_data           => l_pos_ei_data
                                      );
  l_org_id      := l_pos_ei_data.poei_information21;

  If l_org_id is not null then
  for org_address in c_org_address(l_org_id) loop
     p_position_org_line1  := org_address.org_information5;
     p_position_org_line2  := org_address.org_information6;
     p_position_org_line3  := org_address.org_information7;
     p_position_org_line4  := org_address.org_information8;
     p_position_org_line5  := org_address.org_information9;
     p_position_org_line6  := org_address.org_information10;
  End loop;
 End if;
End if;
--
  retrieve_element_entry_value (p_element_name    => 'AUO'
			       ,p_input_value_name      => 'Amount'
			       ,p_assignment_id         => p_assignment_id
			       ,p_effective_date        => l_effective_date
			       ,p_value                 => l_au_overtime
			       ,p_multiple_error_flag   => l_multi_error_flag);
  /*if l_au_overtime is NULL then
    l_au_overtime := 0;
  end if;
  */
  if l_multi_error_flag then
    hr_utility.set_message(8301, 'GHR_38014_API_MULTI_ELE_ENTR');
    hr_utility.raise_error;
  end if;
  --
  retrieve_element_entry_value (p_element_name    => 'AUO'
			       ,p_input_value_name      => 'Premium Pay Ind'
			       ,p_assignment_id         => p_assignment_id
			       ,p_effective_date        => l_effective_date
			       ,p_value                 => l_auo_premium_pay_indicator
			       ,p_multiple_error_flag   => l_multi_error_flag);
  /*if l_auo_premium_pay_indicator is NULL then
    l_auo_premium_pay_indicator := 0;
  end if;
  */
  if l_multi_error_flag then
    hr_utility.set_message(8301, 'GHR_38014_API_MULTI_ELE_ENTR');
    hr_utility.raise_error;
  end if;
  --
  retrieve_element_entry_value (p_element_name    => 'Availability Pay'
			       ,p_input_value_name      => 'Amount'
			       ,p_assignment_id         => p_assignment_id
			       ,p_effective_date        => l_effective_date
			       ,p_value                 => l_availability_pay
			       ,p_multiple_error_flag   => l_multi_error_flag);
/*  if l_availability_pay is NULL then
    l_availability_pay := 0;
  end if;
*/
  if l_multi_error_flag then
    hr_utility.set_message(8301, 'GHR_38014_API_MULTI_ELE_ENTR');
    hr_utility.raise_error;
  end if;
  --

  retrieve_element_entry_value (p_element_name    => 'Availability Pay'
    		               ,p_input_value_name      => 'Premium Pay Ind'
			       ,p_assignment_id         => p_assignment_id
			       ,p_effective_date        => l_effective_date
			       ,p_value                 => l_ap_premium_pay_indicator
			       ,p_multiple_error_flag   => l_multi_error_flag);
 /* if l_ap_premium_pay_indicator is NULL then
    l_ap_premium_pay_indicator := 0;
  end if;
*/
  if l_multi_error_flag then
    hr_utility.set_message(8301, 'GHR_38014_API_MULTI_ELE_ENTR');
    hr_utility.raise_error;
  end if;
  --
  retrieve_element_entry_value (p_element_name    =>  'Retention Allowance'
			       ,p_input_value_name      => 'Amount'
			       ,p_assignment_id         => p_assignment_id
			       ,p_effective_date        => l_effective_date
			       ,p_value                 => l_retention_allowance
			       ,p_multiple_error_flag   => l_multi_error_flag);
  -- added 06-Oct by Sue
  retrieve_element_entry_value (p_element_name    => 'Retention Allowance'
			       ,p_input_value_name      => 'Percentage'
			       ,p_assignment_id         => p_assignment_id
			       ,p_effective_date        => l_effective_date
			       ,p_value                 => l_retention_allow_percentage
			       ,p_multiple_error_flag   => l_multi_error_flag);
  /*if l_retention_allowance is NULL then
    l_retention_allowance := 0;
  end if;
  */
  if l_multi_error_flag then
    hr_utility.set_message(8301, 'GHR_38014_API_MULTI_ELE_ENTR');
    hr_utility.raise_error;
  end if;
  --
  retrieve_element_entry_value (p_element_name    =>  'Supervisory Differential'
			       ,p_input_value_name      => 'Amount'
			       ,p_assignment_id         => p_assignment_id
			       ,p_effective_date        => l_effective_date
			       ,p_value                 => l_supervisory_differential
			       ,p_multiple_error_flag   => l_multi_error_flag);
  -- added 06-Oct by Sue
  retrieve_element_entry_value (p_element_name    => 'Supervisory Differential'
                               ,p_input_value_name      => 'Percentage'
			       ,p_assignment_id         => p_assignment_id
			       ,p_effective_date        => p_effective_date
			       ,p_value                 => l_supervisory_diff_percentage
			       ,p_multiple_error_flag   => l_multi_error_flag);
/*  if l_supervisory_differential is NULL then
    l_supervisory_differential := 0;
  end if;
*/
  if l_multi_error_flag then
    hr_utility.set_message(8301, 'GHR_38014_API_MULTI_ELE_ENTR');
    hr_utility.raise_error;
  end if;
  --
  retrieve_element_entry_value (p_element_name    => 'Staffing Differential'
			       ,p_input_value_name      => 'Amount'
			       ,p_assignment_id         => p_assignment_id
			       ,p_effective_date        => l_effective_date
			       ,p_value                 => l_staffing_differential
			       ,p_multiple_error_flag   => l_multi_error_flag);
  -- added 06-Oct by Sue
  retrieve_element_entry_value (p_element_name    =>  'Staffing Differential'
			       ,p_input_value_name      => 'Percent'
			       ,p_assignment_id         => p_assignment_id
			       ,p_effective_date        => l_effective_date
			       ,p_value                 => l_staffing_diff_percentage
			       ,p_multiple_error_flag   => l_multi_error_flag);
  /*if l_staffing_differential is NULL then
    l_staffing_differential := 0;
  end if;
  */
  if l_multi_error_flag then
    hr_utility.set_message(8301, 'GHR_38014_API_MULTI_ELE_ENTR');
    hr_utility.raise_error;
  end if;
--
  p_au_overtime                 := l_au_overtime;
  p_auo_premium_pay_indicator   := l_auo_premium_pay_indicator;
  p_availability_pay            := l_availability_pay;
  p_ap_premium_pay_indicator    := l_ap_premium_pay_indicator;
  p_retention_allowance         := l_retention_allowance;
  p_retention_allow_percentage  := l_retention_allow_percentage;
  p_supervisory_differential    := l_supervisory_differential;
  p_supervisory_diff_percentage := l_supervisory_diff_percentage;
  p_staffing_differential       := l_staffing_differential;
  p_staffing_diff_percentage    := l_staffing_diff_percentage;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
EXCEPTION
  when others then
     -- NOCOPY Changes
     -- Reset IN OUT params and Set OUT params to null
     p_assignment_id                        := v_assignment_id;
     p_position_title                       := null;
     p_position_number                      := null;
     p_position_seq_no                      := null;
     p_pay_plan                             := null;
     p_job_id                               := null;
     p_occ_code                             := null;
     p_grade_id                             := null;
     p_grade_or_level                       := null;
     p_step_or_rate                         := null;
     p_total_salary                         := null;
     p_pay_basis                            := null;
     -- FWFA Changes Bug#4444609
     p_pay_table_identifier                         := null;
     -- FWFA Changes
     p_basic_pay                            := null;
     p_locality_adj                         := null;
     p_adj_basic_pay                        := null;
     p_other_pay                            := null;
     p_au_overtime                          := null;
     p_auo_premium_pay_indicator            := null;
     p_availability_pay                     := null;
     p_ap_premium_pay_indicator             := null;
     p_retention_allowance                  := null;
     p_retention_allow_percentage           := null;
     p_supervisory_differential             := null;
     p_supervisory_diff_percentage          := null;
     p_staffing_differential                := null;
     p_staffing_diff_percentage             := null;
     p_organization_id                      := null;
     p_position_org_line1                   := null;
     p_position_org_line2                   := null;
     p_position_org_line3                   := null;
     p_position_org_line4                   := null;
     p_position_org_line5                   := null;
     p_position_org_line6                   := null;
     p_position_id                          := null;
     p_duty_station_location_id             := null;
     p_pay_rate_determinant                 := null;
     p_work_schedule                        := null;
     raise;
end sf52_from_data_elements;
--
--
-- ---------------------------------------------------------------------------
-- |--------------------------< return_upd_hr_dml_status >----------------|
-- --------------------------------------------------------------------------
FUNCTION return_upd_hr_dml_status RETURN BOOLEAN IS
	l_proc varchar2(72) := g_package||'return_upd_hr_dml_status';
begin
 	hr_utility.set_location('Entering:'||l_proc,5);
 	return (nvl(g_api_dml, false));
 	hr_utility.set_location(' Leaving:'||l_proc,10);
end return_upd_hr_dml_status;

-- ---------------------------------------------------------------------------
-- |--------------------------< return_special_information >----------------|
-- --------------------------------------------------------------------------

Procedure return_special_information
(p_person_id       in  number
,p_structure_name  in  varchar2
,p_effective_date  in  date
,p_special_info    OUT NOCOPY ghr_api.special_information_type
)
is
l_proc           varchar2(72)  := 'return_special_information ';
l_id_flex_num    fnd_id_flex_structures.id_flex_num%type;
l_max_segment    per_analysis_criteria.segment1%type;

Cursor c_flex_num is
  select    flx.id_flex_num
  from      fnd_id_flex_structures_tl flx
  where     flx.id_flex_code           = 'PEA'  --
  and       flx.application_id         =  800   --
  and       flx.id_flex_structure_name =  p_structure_name
  and	    flx.language	       = 'US';

 Cursor    c_sit      is
   select  pea.analysis_criteria_id,
           pan.date_from, -- added for bug fix : 609285
           pan.person_analysis_id,
           pan.object_version_number,
           pea.start_date_active,
           pea.segment1,
           pea.segment2,
           pea.segment3,
           pea.segment4,
           pea.segment5,
           pea.segment6,
           pea.segment7,
           pea.segment8,
           pea.segment9,
           pea.segment10,
           pea.segment11,
           pea.segment12,
           pea.segment13,
           pea.segment14,
           pea.segment15,
           pea.segment16,
           pea.segment17,
           pea.segment18,
           pea.segment19,
           pea.segment20,
           pea.segment21,
           pea.segment22,
           pea.segment23,
           pea.segment24,
           pea.segment25,
           pea.segment26,
           pea.segment27,
           pea.segment28,
           pea.segment29,
           pea.segment30
   from    per_analysis_Criteria pea,
           per_person_analyses   pan
   where   pan.person_id            =  p_person_id
   and     pan.id_flex_num          =  l_id_flex_num
   and     pea.analysis_Criteria_id =  pan.analysis_criteria_id
   and     p_effective_date
   between nvl(pan.date_from,p_effective_date)
   and     nvl(pan.date_to,p_effective_date)
   and     p_effective_date
   between nvl(pea.start_date_active,p_effective_date)
   and     nvl(pea.end_date_active,p_effective_date)
   order   by  2 desc, 3 desc;

begin

  for flex_num in c_flex_num loop
    l_id_flex_num  :=  flex_num.id_flex_num;
  End loop;

  If l_id_flex_num is null then
    hr_utility.set_message(8301,'GHR_38275_INV_SP_INFO_TYPE');
    hr_utility.raise_error;
  End if;

  for special_info in c_sit loop
    p_special_info.segment1              := special_info.segment1;
    p_special_info.segment2              := special_info.segment2;
    p_special_info.segment3              := special_info.segment3;
    p_special_info.segment4              := special_info.segment4;
    p_special_info.segment5              := special_info.segment5;
    p_special_info.segment6              := special_info.segment6;
    p_special_info.segment7              := special_info.segment7;
    p_special_info.segment8              := special_info.segment8;
    p_special_info.segment9              := special_info.segment9;
    p_special_info.segment10             := special_info.segment10;
    p_special_info.segment11             := special_info.segment11;
    p_special_info.segment12             := special_info.segment12;
    p_special_info.segment13             := special_info.segment13;
    p_special_info.segment14             := special_info.segment14;
    p_special_info.segment15             := special_info.segment15;
    p_special_info.segment16             := special_info.segment16;
    p_special_info.segment17             := special_info.segment17;
    p_special_info.segment18             := special_info.segment18;
    p_special_info.segment19             := special_info.segment19;
    p_special_info.segment20             := special_info.segment20;
    p_special_info.segment21             := special_info.segment21;
    p_special_info.segment22             := special_info.segment22;
    p_special_info.segment23             := special_info.segment23;
    p_special_info.segment24             := special_info.segment24;
    p_special_info.segment25             := special_info.segment25;
    p_special_info.segment26             := special_info.segment26;
    p_special_info.segment27             := special_info.segment27;
    p_special_info.segment28             := special_info.segment28;
    p_special_info.segment29             := special_info.segment29;
    p_special_info.segment30             := special_info.segment30;
    p_special_info.person_analysis_id    := special_info.person_analysis_id;
    p_special_info.object_version_number := special_info.object_version_number;

    exit;
  End loop;
EXCEPTION
  when others then
     -- NOCOPY changes
     -- Reset IN OUT params and set OUT params
     p_special_info := null;
     raise;
 End return_special_information;


-- ---------------------------------------------------------------------------
-- |--------------------------< return_education_Details >----------------|
-- --------------------------------------------------------------------------

  Procedure return_education_Details
  (p_person_id                  in  per_people_f.person_id%type,
   p_effective_date             in  date,
   p_education_level            OUT NOCOPY per_analysis_criteria.segment1%type,
   p_academic_discipline        OUT NOCOPY per_analysis_criteria.segment2%type,
   p_year_degree_attained       OUT NOCOPY per_analysis_criteria.segment3%type
  )
  is

  l_proc             varchar2(72) :=  'return_education_Details';
  l_special_info     ghr_api.special_information_type;
  l_id_flex_num      fnd_id_flex_structures.id_flex_num%type;

  Cursor c_flex_num is
  select    flx.id_flex_num
  from      fnd_id_flex_structures_tl flx
  where     flx.id_flex_code           = 'PEA'  --
  and       flx.application_id         =  800   --
  and       flx.id_flex_structure_name =  'US Fed Education'
  and       flx.language	       =  'US';

/*Cursor to get the highest education level for the person , as of the effective date */


  Cursor c_sit is
   select  pea.segment1,
           pea.segment2,
           pea.segment3,
           pea.segment4,
           pea.segment5,
           pea.segment6,
           pea.segment7,
           pea.segment8,
           pea.segment9,
           pea.segment10,
           pea.segment11,
           pea.segment12,
           pea.segment13,
           pea.segment14,
           pea.segment15,
           pea.segment16,
           pea.segment17,
           pea.segment18,
           pea.segment19,
           pea.segment20
  from     per_analysis_criteria pea,
           per_person_analyses pan
   where   pan.person_id             = p_person_id
   and     pan.id_flex_num           =  l_id_flex_num
   and     pea.id_flex_num           =  pan.id_flex_num
   and     p_effective_date
   between nvl(pan.date_from,p_effective_date)
   and     nvl(pan.date_to,p_effective_date)
   and     p_effective_date
   between nvl(pea.start_date_active,p_effective_date)
   and     nvl(pea.end_date_active,p_effective_date)
   and     pan.analysis_criteria_id     =  pea.analysis_criteria_id
   order by 1 desc;

  begin

   hr_utility.set_location('Entering ' || l_proc,5);

   for flex_num in c_flex_num loop
      hr_utility.set_location(l_proc,10);
      l_id_flex_num := flex_num.id_flex_num;
   end loop;
      hr_utility.set_location(l_proc,15);
   for sit in c_sit loop
     hr_utility.set_location(l_proc,20);
     p_education_level            := sit.segment1;
     p_academic_discipline        := sit.segment2;
     p_year_degree_attained       := sit.segment3;
     exit;
   end loop;
   hr_utility.set_location(l_proc,25);

  hr_utility.set_location('Leaving  ' ||l_proc,30);
EXCEPTION
  when others then
     -- NOCOPY changes
     -- Reset IN OUT params and set OUT params
   p_education_level            := null;
   p_academic_discipline        := null;
   p_year_degree_attained       := null;
   raise;
End return_education_details;

-- ---------------------------------------------------------------------------
-- |--------------------------< call_work_flow>----------------|
-- --------------------------------------------------------------------------

Procedure call_workflow
(p_pa_request_id        in    ghr_pa_requests.pa_request_id%type,
 p_action_taken         in    ghr_pa_routing_history.action_taken%type,
 p_old_action_taken     in    ghr_pa_routing_history.action_taken%type default null,
 p_error                in    varchar2 default null
)
is
--
l_proc              		varchar2(72)  := 'Call_workflow';
l_pa_routing_history_rec 	ghr_pa_routing_history%rowtype;
l_forward_to_name   		ghr_pa_routing_history.user_name%type;
l_cnt               		number;
l_act_cnt             		number;
l_groupbox_id       		number;
l_user_name             	ghr_pa_routing_history.user_name%type;
l_object_version_number 	ghr_pa_requests.object_version_number%type;

Cursor c_par is
  select   par.object_version_number
  from     ghr_pa_requests par
  where    par.pa_request_id = p_pa_request_id;

Cursor c_routing_count is
  select  count(*) cnt
  from    ghr_pa_routing_history
  where   pa_request_id  = p_pa_request_id;

  Cursor c_routing_action is
  select  count(1) act_cnt
  from    ghr_pa_routing_history
  where   pa_request_id  = p_pa_request_id
  and     action_taken = 'INITIATED';
  /* Bug# 5634964. The existing code is like l_cnt =2 and l_cnt>2 are wrote without considering the action_taken
   of 'INITIATED'. When user routed to inbox there will be one record in the ghr_pa_routing_history table with
   action_taken as 'INTIATED'. To work existing code for INITIATED actoons, added the above cursor*/

Cursor c_forwarding_name is
  select pa_routing_history_id,
         pa_request_id,
         initiator_flag,
         requester_flag,
         authorizer_flag,
         personnelist_flag,
         approver_flag,
         reviewer_flag,
         approved_flag,
         user_name,
         user_name_employee_id,
         user_name_emp_first_name,
         user_name_emp_last_name,
         user_name_emp_middle_names,
         groupbox_id,
         notepad ,
         routing_list_id,
         routing_seq_number,
         nature_of_action_id,
         noa_family_code,
         second_nature_of_action_id,
         object_version_number
  from   ghr_pa_routing_history
  where  pa_request_id  = p_pa_request_id
  order  by pa_routing_history_id desc;

Cursor  c_groupbox_name is
  select name
  from   ghr_groupboxes
  where  groupbox_id = l_pa_routing_history_rec.groupbox_id;

begin

    hr_utility.set_location('Entering    ' || l_proc,5);

    If p_action_taken not in ('NOT_ROUTED','UPDATE_HR','CONTINUE') then
        hr_utility.set_location(l_proc || p_action_taken,10);
        for routing_rec in c_routing_count loop
            hr_utility.set_location(l_proc,15);
            l_cnt := routing_rec.cnt;
            -- Begin Bug# 5634964
            IF p_action_taken not in('INITIATED') and p_old_action_taken = 'FUTURE_ACTION' THEN
                for routing_action in c_routing_action loop
                    l_act_cnt := routing_action.act_cnt;
                end loop;
                l_cnt := l_cnt - nvl(l_act_cnt,0);
            END IF;
            -- End Bug# 5634964
        end loop;
        -- The very fact that it is a 2nd routing history and action taken is not 'UPDATE_HR_COMPLETE' means
        -- work flow needs to be initiated. In all other cases , the blockingofparequest needs to be called
        If l_cnt = 2 then
            hr_utility.set_location(l_proc ||p_action_taken,20);
            If p_action_taken not in ('FUTURE_ACTION','CANCELED') then
                hr_utility.set_location('not FA or CAncel',1);
                If (p_action_taken = 'UPDATE_HR_COMPLETE'or p_action_taken = 'ENDED') and
                    p_old_action_taken = 'FUTURE_ACTION' then
                    hr_utility.set_location('nothing',1);
                    Null;
                Else --(p_action_taken = 'UPDATE_HR_COMPLETE'or p_action_taken = 'ENDED')
                    hr_utility.set_location('else not Update Coplete',1);
                    for forwarding_name in c_forwarding_name loop
                        hr_utility.set_location(l_proc,25);
                        l_pa_routing_history_rec.groupbox_id := forwarding_name.groupbox_id;
                        l_pa_routing_history_rec.user_name   := forwarding_name.user_name;
                        hr_utility.set_location('groupbox ' || l_pa_routing_history_rec.groupbox_id,1);
                        hr_utility.set_location('username ' || l_pa_routing_history_rec.user_name,1);
                        exit;
                    end loop;
                    If l_pa_routing_history_rec.user_name  is null then
                        hr_utility.set_location(l_proc || 'user not null',30);
                        for  groupbox_name in c_groupbox_name loop
                            hr_utility.set_location(l_proc,35);
                            l_forward_to_name  :=   groupbox_name.name;
                        end loop;
                    Else
                      l_forward_to_name  :=   l_pa_routing_history_rec.user_name;
                    End if;
                    If l_forward_to_name is null then
                        hr_utility.set_message(8301,'GHR_38276_FORWARD_NAME_REQD');
                        hr_utility.raise_error;
                    End if;
                    hr_utility.set_location(l_proc,40);
                    ghr_wf_pkg.startsf52process
                    (p_pa_request_id         =>  p_pa_request_id,
                    p_forward_to_name       =>  l_forward_to_name,
                    p_error_msg             => p_error
                    );
                End if; --(p_action_taken = 'UPDATE_HR_COMPLETE'or p_action_taken = 'ENDED')
                hr_utility.set_location('after call to start sf52' || p_old_action_taken,11);
            Elsif p_action_taken in ('FUTURE_ACTION','CANCELED')then
                hr_utility.set_location(l_proc,43);
                ghr_wf_pkg.CompleteBlockingOfparequest
                (p_pa_request_id       => p_pa_request_id,
                p_error_msg           => p_error
                );
            End if;--p_action_taken not in ('FUTURE_ACTION','CANCELED')

            -- If  there are more than 2 routing history records, then workflow has already started and
            -- now we need to know whether to transfer OUT to blockingoffutureactions of blockingofparequest
        Elsif l_cnt > 2 then
            hr_utility.set_location('Old Action Taken ' || p_old_action_taken,1);
            hr_utility.set_location(l_proc,45);
            If  nvl(p_old_action_taken,hr_api.g_varchar2) = 'FUTURE_ACTION' and
                p_action_taken ='UPDATE_HR_COMPLETE' then
                ghr_wf_pkg.completeblockingoffutureaction
                (p_pa_request_id       => p_pa_request_id,
                p_action_taken        => p_action_taken,
                p_error_msg           => p_error);
            Else
                ghr_wf_pkg.CompleteBlockingOfparequest
                (p_pa_request_id      => p_pa_request_id,
                p_error_msg           => p_error);
            End if;
        End if; --l_cnt = 2
    End if; -- p_action_taken not in ('NOT_ROUTED','UPDATE_HR','CONTINUE')

    If p_action_taken = 'CONTINUE' then
        hr_utility.set_location('continue',1);
        -- Update the current status of the PA Request with the next in hierarchy (after update_hr,future_action), which is APPROVED.
        for par in c_par loop
            l_object_version_number  :=  par.object_version_number;
        end loop;
        ghr_par_upd.upd
        (p_pa_request_id     	=> p_pa_request_id,
        p_status            	=> 'APPROVED',
        p_object_version_number   => l_object_version_number);

        for routing_rec in c_routing_count loop
            l_cnt := routing_rec.cnt;
        end loop;

        for forwarding_name in c_forwarding_name loop
            hr_utility.set_location(l_proc,25);
            hr_utility.set_location('inside rh loop',2);
            l_pa_routing_history_rec.pa_routing_history_id 		:= forwarding_name.pa_routing_history_id;
            l_pa_routing_history_rec.pa_request_id         		:= forwarding_name.pa_request_id;
            l_pa_routing_history_rec.initiator_flag        		:= forwarding_name.initiator_flag;
            l_pa_routing_history_rec.requester_flag        		:= forwarding_name.requester_flag;
            l_pa_routing_history_rec.authorizer_flag        		:= forwarding_name.authorizer_flag;
            l_pa_routing_history_rec.personnelist_flag     		:= forwarding_name.personnelist_flag;
            l_pa_routing_history_rec.approver_flag         		:= forwarding_name.approver_flag;
            l_pa_routing_history_rec.reviewer_flag         		:= forwarding_name.reviewer_flag;
            l_pa_routing_history_rec.approved_flag         		:= forwarding_name.approved_flag;
            l_pa_routing_history_rec.user_name             		:= forwarding_name.user_name;
            l_pa_routing_history_rec.user_name_employee_id 		:= forwarding_name.user_name_employee_id;
            l_pa_routing_history_rec.user_name_emp_first_name 		:= forwarding_name.user_name_emp_first_name;
            l_pa_routing_history_rec.user_name_emp_last_name  		:= forwarding_name.user_name_emp_last_name;
            l_pa_routing_history_rec.user_name_emp_middle_names		:= forwarding_name.user_name_emp_middle_names;
            l_pa_routing_history_rec.groupbox_id           		:= forwarding_name.groupbox_id;
            l_pa_routing_history_rec.routing_list_id       		:= forwarding_name.routing_list_id;
            l_pa_routing_history_rec.routing_seq_number     		:= forwarding_name.routing_seq_number;
            l_pa_routing_history_rec.notepad                		:= forwarding_name.notepad;
            l_pa_routing_history_rec.nature_of_action_id    		:= forwarding_name.nature_of_action_id;
            l_pa_routing_history_rec.second_nature_of_action_id   	:= forwarding_name.second_nature_of_action_id;
            l_pa_routing_history_rec.noa_family_code                  := forwarding_name.noa_family_code;
            l_pa_routing_history_rec.object_version_number  		:= forwarding_name.object_version_number;
            exit;
        end loop;

        If l_pa_routing_history_rec.user_name is null then
            hr_utility.set_location('user name is null',1);
            hr_utility.set_location(l_proc,30);
            for  groupbox_name in c_groupbox_name loop
                hr_utility.set_location('inside groupbox cursor',2);
                hr_utility.set_location(l_proc,35);
                l_forward_to_name  :=   groupbox_name.name;
            end loop;
        Else
            l_forward_to_name  :=   l_pa_routing_history_rec.user_name;
        End if;
            hr_utility.set_location('Forward to name  : ' || l_forward_to_name,3);
        If l_forward_to_name is null then
            hr_utility.set_message(8301,'GHR_38276_FORWARD_NAME_REQD');
            hr_utility.raise_error;
        End if;
        hr_utility.set_location('Before call to prh' || l_proc,40);

        ghr_prh_ins.ins
        (
        p_pa_routing_history_id     	=> l_pa_routing_history_rec.pa_routing_history_id,
        p_pa_request_id             	=> l_pa_routing_history_rec.pa_request_id,
        p_attachment_modified_flag  	=> nvl(l_pa_routing_history_rec.attachment_modified_flag,'N') ,
        p_initiator_flag            	=> nvl(l_pa_routing_history_rec.initiator_flag,'N'),
        p_approver_flag             	=> nvl(l_pa_routing_history_rec.approver_flag,'N'),
        p_reviewer_flag             	=> nvl(l_pa_routing_history_rec.reviewer_flag,'N') ,
        p_requester_flag            	=> nvl(l_pa_routing_history_rec.requester_flag,'N') ,
        p_authorizer_flag           	=> nvl(l_pa_routing_history_rec.authorizer_flag,'N'),
        p_personnelist_flag         	=> nvl(l_pa_routing_history_rec.personnelist_flag,'N'),
        p_approved_flag             	=> nvl(l_pa_routing_history_rec.approved_flag,'N'),
        p_user_name                 	=> l_pa_routing_history_rec.user_name,
        p_user_name_employee_id     	=> l_pa_routing_history_rec.user_name_employee_id,
        p_user_name_emp_first_name  	=> l_pa_routing_history_rec.user_name_emp_first_name,
        p_user_name_emp_last_name   	=> l_pa_routing_history_rec.user_name_emp_last_name ,
        p_user_name_emp_middle_names 	=> l_pa_routing_history_rec.user_name_emp_middle_names,
        p_groupbox_id               	=> l_pa_routing_history_rec.groupbox_id,
        p_routing_seq_number        	=> l_pa_routing_history_rec.routing_seq_number,
        p_routing_list_id           	=> l_pa_routing_history_rec.routing_list_id,
        p_notepad                   	=> l_pa_routing_history_rec.notepad,
        p_nature_of_action_id       	=> l_pa_routing_history_rec.nature_of_action_id,
        p_second_nature_of_action_id	=> l_pa_routing_history_rec.second_nature_of_action_id,
        p_noa_family_code           	=> l_pa_routing_history_rec.noa_family_code,
        p_object_version_number     	=> l_pa_routing_history_rec.object_version_number
        );

        If l_cnt = 1 then
            ghr_wf_pkg.startsf52process
            (p_pa_request_id         =>  p_pa_request_id,
            p_forward_to_name       =>  l_forward_to_name,
            p_error_msg             => p_error);
        Else
            ghr_wf_pkg.CompleteBlockingOfFutureAction
            (p_pa_request_id       => p_pa_request_id
            ,p_action_taken        => p_action_taken
            ,p_error_msg               => p_error );
        End if;
    End if; --p_action_taken = 'CONTINUE'

End call_workflow;

  FUNCTION restricted_attribute (
      p_user_name in VARCHAR2
    , p_attribute in VARCHAR2
  )
  RETURN BOOLEAN
  IS

    CURSOR c_restricted IS
      SELECT rpm.restricted_proc_method
      FROM   FND_USER USR
           , PER_PEOPLE_EXTRA_INFO PEI
           , GHR_RESTRICTED_PROC_METHODS RPM
           , GHR_PA_DATA_FIELDS PDF
      WHERE  usr.user_name = p_user_name
      AND    pdf.name      = p_attribute
      AND    pei.person_id = usr.employee_id
      AND    pei.information_type = 'GHR_US_PER_USER_INFO'
      AND    rpm.restricted_form = pei.pei_information3
      AND    rpm.pa_data_field_id = pdf.pa_data_field_id;

    l_restricted_proc_method VARCHAR2(30);

  BEGIN

    OPEN c_restricted;
    FETCH c_restricted INTO l_restricted_proc_method;
    CLOSE c_restricted;

    RETURN NVL(l_restricted_proc_method, 'DO') = 'ND';

  END  restricted_attribute;


end ghr_api;

/
