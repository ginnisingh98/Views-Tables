--------------------------------------------------------
--  DDL for Package Body HR_JOB_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_JOB_API" as
/* $Header: pejobapi.pkb 120.0.12010000.1 2008/07/28 04:55:26 appldev ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_job_api.';
--
c_date_from  constant varchar2(4) := 'FROM';
c_date_to    constant varchar2(4) := 'TO';
--
-- ------------------------- Private Procedures -------------------------------
-- ----------------------------------------------------------------------------
-- |------------------------< maintain_valid_grades >-------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This internal procedure maintains valid grades for a job when the
--   date from or date to of a job is updated.

--   If the job Date Effective is being updated, then valid grades with
--   a date to which is earlier than that Date Effective are deleted.
--   Valid Grades with a date from which is earlier than the Job Date
--   Effective and a date to which is later than the Job Date Effective
--   or null are update with their Date From set to the job Date
--   Effective.
--
--   If the Job Date End is being updated, valid grades with a date from
--   which is later than the end date of the job are deleted.  Valid
--   Grades with a date from which is earlier then the job end date and a
--   date to which is later than the job end date or null are updated with
--   their date to set to the job end date.
--
-- Prerequisites:
--   A valid job (p_job_id) must exist.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--  p_validate                       Y   boolean  Default False
--  p_job_id                        Y   number
--  p_maintenance_mode          Y   varchar2 Indicates whether the
--                                                job date effective or
--                                                the job date end has
--                                                been updated. Valid values
--                                                are 'DATE_EFFECTIVE' and
--                                                'DATE_END'.
--  p_date_from                      N   date     job date effective
--  p_date_to                        N   date     job date end
--  p_approval_authority             N   number   approval authority for OAM
--
--
-- Post Success:
--
--   Name                                Type     Description
--   p_valid_grades_changed              boolean  Only set to true if any valid
--                                                grade rows have been updated
--                                                or deleted.
--
-- Post Failure:
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ---------------------------------------------------------------------------
 procedure maintain_valid_grades
  (
   p_validate                 in boolean default false
  ,p_job_id                   in number
  ,p_maintenance_mode         in varchar2
  ,p_date_from                in date
  ,p_date_to                  in date
  ,p_valid_grades_changed     out nocopy boolean
  ,p_effective_date        in date   -- Added for Bug# 1760707
  )
  is
  --
  l_proc                  varchar2(72) := g_package||'maintain_valid_grades';
  l_valid_grade_changed   boolean default FALSE;
  --
  cursor csr_valid_grades is
  select
       vgr.valid_grade_id valid_grade_id
      ,vgr.object_version_number object_version_number
      ,vgr.date_from  date_from
      ,vgr.date_to  date_to
  from per_valid_grades vgr
  where vgr.job_id = p_job_id;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
--
    IF p_maintenance_mode = c_date_from THEN
--
-- When maintain_valid_grades has been called to maintain the valid grades
-- for a job in accordance with that Jobs's new Date from,
-- (ie. p_maintenance_mode = 'DATE_EFFECTIVE') then the p_date_from
-- parameter should have been set.
--
  hr_api.mandatory_arg_error
    (p_api_name      => l_proc
    ,p_argument      => 'date_effective'
    ,p_argument_value   => p_date_from);
--
  hr_utility.set_location(l_proc, 10);
--
    FOR c_vgr_rec IN csr_valid_grades LOOP
--
-- If a valid grade for the job has a Date From that is earlier
-- than the new Date from of the job and a Date To that is
-- later than that new Date from or is null, then update that
-- valid grade's Date From to that new Date from.
--
   hr_utility.set_location(l_proc, 15);
   if (c_vgr_rec.date_from < p_date_from and
       nvl(c_vgr_rec.date_to, hr_api.g_eot) > p_date_from ) then
--
   hr_utility.set_location(l_proc, 20);
--
   per_vgr_upd.upd
       (p_valid_grade_id => c_vgr_rec.valid_grade_id
       ,p_object_version_number => c_vgr_rec.object_version_number
       ,p_date_from => p_date_from
       ,p_validate  => p_validate
       ,p_effective_date => p_effective_date);  --Added for bug# 1760707
--
   l_valid_grade_changed := TRUE;
--
-- Else if valid grades exist for the job which have a date to that
-- is earlier than the new Date from for the job then delete
-- those valid grades.
--
--
   elsif (c_vgr_rec.date_to < p_date_from) then
--
   hr_utility.set_location(l_proc, 25);
--
   per_vgr_del.del
     (p_valid_grade_id => c_vgr_rec.valid_grade_id
     ,p_object_version_number => c_vgr_rec.object_version_number
     ,p_validate  => p_validate);
--
   l_valid_grade_changed := TRUE;
--
--
   end if;
--
   END LOOP;
--
   ELSE
--
-- When maintain_valid_grades has been called to maintain the valid grades
-- for a job in accordance with that job's new Date to,
-- (ie. p_maintenance_mode = 'DATE_TO') then the p_date_to parameter
-- should have been set.
--
   hr_api.mandatory_arg_error
     (p_api_name     => l_proc
     ,p_argument     => 'date_to'
     ,p_argument_value          => p_date_to);
--
   hr_utility.set_location(l_proc, 30);
--
   for c_vgr_rec in csr_valid_grades loop
--
-- If a valid grade for the job has a Date From that is earlier
-- than the new To Date of the job and a Date To that is later than
-- that new To Date or is null, then update that valid grade's Date To
-- to that new To Date.
--
   hr_utility.set_location(l_proc, 35);
--
   if (c_vgr_rec.date_from < p_date_to and
     nvl(c_vgr_rec.date_to, hr_api.g_eot) > p_date_to ) then
--
   hr_utility.set_location(l_proc, 40);
--
   per_vgr_upd.upd
     (p_valid_grade_id => c_vgr_rec.valid_grade_id
     ,p_object_version_number => c_vgr_rec.object_version_number
     ,p_date_to   => p_date_to
     ,p_validate  => p_validate
     ,p_effective_date => p_effective_date);  -- Added for Bug# 1760707
--
   l_valid_grade_changed := TRUE;
--
-- Else if valid grades exist for the job which have a date from that
-- is later than the new End Date for the job then delete those
-- valid grades.
--
   elsif (c_vgr_rec.date_from > p_date_to) then
--
   hr_utility.set_location(l_proc, 45);
--
   per_vgr_del.del
     (p_valid_grade_id => c_vgr_rec.valid_grade_id
     ,p_object_version_number => c_vgr_rec.object_version_number
     ,p_validate  => p_validate);
--
   l_valid_grade_changed := TRUE;
--
   end if;
--
   END LOOP;
--
   END IF;
--
   hr_utility.set_location(l_proc, 50);
--
   p_valid_grades_changed := l_valid_grade_changed;
   hr_utility.set_location('Leaving: '||l_proc, 55);
--
   end maintain_valid_grades;
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_job >------------------------------------|
-- ----------------------------------------------------------------------------
procedure create_job
    (p_validate                      in     boolean  default false
    ,p_business_group_id             in     number
    ,p_date_from                     in     date
    ,p_comments                      in     varchar2 default null
    ,p_date_to                       in     date     default null
    ,p_approval_authority            in     number   default null
    ,p_benchmark_job_flag            in     varchar2 default 'N'
    ,p_benchmark_job_id              in     number   default null
    ,p_emp_rights_flag               in     varchar2 default 'N'
    ,p_job_group_id                  in     number
    ,p_attribute_category            in     varchar2 default null
    ,p_attribute1                    in     varchar2 default null
    ,p_attribute2                    in     varchar2 default null
    ,p_attribute3                    in     varchar2 default null
    ,p_attribute4                    in     varchar2 default null
    ,p_attribute5                    in     varchar2 default null
    ,p_attribute6                    in     varchar2 default null
    ,p_attribute7                    in     varchar2 default null
    ,p_attribute8                    in     varchar2 default null
    ,p_attribute9                    in     varchar2 default null
    ,p_attribute10                   in     varchar2 default null
    ,p_attribute11                   in     varchar2 default null
    ,p_attribute12                   in     varchar2 default null
    ,p_attribute13                   in     varchar2 default null
    ,p_attribute14                   in     varchar2 default null
    ,p_attribute15                   in     varchar2 default null
    ,p_attribute16                   in     varchar2 default null
    ,p_attribute17                   in     varchar2 default null
    ,p_attribute18                   in     varchar2 default null
    ,p_attribute19                   in     varchar2 default null
    ,p_attribute20                   in     varchar2 default null
    ,p_job_information_category      in     varchar2 default null
    ,p_job_information1              in     varchar2 default null
    ,p_job_information2              in     varchar2 default null
    ,p_job_information3              in     varchar2 default null
    ,p_job_information4              in     varchar2 default null
    ,p_job_information5              in     varchar2 default null
    ,p_job_information6              in     varchar2 default null
    ,p_job_information7              in     varchar2 default null
    ,p_job_information8              in     varchar2 default null
    ,p_job_information9              in     varchar2 default null
    ,p_job_information10             in     varchar2 default null
    ,p_job_information11             in     varchar2 default null
    ,p_job_information12             in     varchar2 default null
    ,p_job_information13             in     varchar2 default null
    ,p_job_information14             in     varchar2 default null
    ,p_job_information15             in     varchar2 default null
    ,p_job_information16             in     varchar2 default null
    ,p_job_information17             in     varchar2 default null
    ,p_job_information18             in     varchar2 default null
    ,p_job_information19             in     varchar2 default null
    ,p_job_information20             in     varchar2 default null
    ,p_segment1                      in     varchar2 default null
    ,p_segment2                      in     varchar2 default null
    ,p_segment3                      in     varchar2 default null
    ,p_segment4                      in     varchar2 default null
    ,p_segment5                      in     varchar2 default null
    ,p_segment6                      in     varchar2 default null
    ,p_segment7                      in     varchar2 default null
    ,p_segment8                      in     varchar2 default null
    ,p_segment9                      in     varchar2 default null
    ,p_segment10                     in     varchar2 default null
    ,p_segment11                     in     varchar2 default null
    ,p_segment12                     in     varchar2 default null
    ,p_segment13                     in     varchar2 default null
    ,p_segment14                     in     varchar2 default null
    ,p_segment15                     in     varchar2 default null
    ,p_segment16                     in     varchar2 default null
    ,p_segment17                     in     varchar2 default null
    ,p_segment18                     in     varchar2 default null
    ,p_segment19                     in     varchar2 default null
    ,p_segment20                     in     varchar2 default null
    ,p_segment21                     in     varchar2 default null
    ,p_segment22                     in     varchar2 default null
    ,p_segment23                     in     varchar2 default null
    ,p_segment24                     in     varchar2 default null
    ,p_segment25                     in     varchar2 default null
    ,p_segment26                     in     varchar2 default null
    ,p_segment27                     in     varchar2 default null
    ,p_segment28                     in     varchar2 default null
    ,p_segment29                     in     varchar2 default null
    ,p_segment30                     in     varchar2 default null
    ,p_concat_segments               in     varchar2 default null
    ,p_language_code                 in     varchar2 default hr_api.userenv_lang
    ,p_job_id                           out nocopy number
    ,p_object_version_number            out nocopy number
    --
    -- bug 2242339 change p_job_definition_id from an out to an in/out parameter    -- to enable value to be passed into program when known and required.
    --
    ,p_job_definition_id             in out nocopy number
    ,p_name                             out nocopy varchar2
    ) is
--
-- Declare cursors and local variables
--
   l_job_id                   per_jobs.job_id%TYPE;
   l_job_definition_id        per_jobs.job_definition_id%TYPE                      := p_job_definition_id;
   l_business_group_id        per_jobs.business_group_id%TYPE;
   l_name                     per_jobs.name%TYPE;
   l_proc                     varchar2(72) := g_package||'create_job';
   l_flex_num                 fnd_id_flex_segments.id_flex_num%TYPE;
   l_object_version_number    per_jobs.object_version_number%TYPE;
   l_date_from                per_jobs.date_from%TYPE;
   l_date_to                  per_jobs.date_to%TYPE;
   l_segment1                 varchar2(150) := p_segment1;
   l_segment2                 varchar2(150) := p_segment2;
   l_segment3                 varchar2(150) := p_segment3;
   l_segment4                 varchar2(150) := p_segment4;
   l_segment5                 varchar2(150) := p_segment5;
   l_segment6                 varchar2(150) := p_segment6;
   l_segment7                 varchar2(150) := p_segment7;
   l_segment8                 varchar2(150) := p_segment8;
   l_segment9                 varchar2(150) := p_segment9;
   l_segment10                varchar2(150) := p_segment10;
   l_segment11                varchar2(150) := p_segment11;
   l_segment12                varchar2(150) := p_segment12;
   l_segment13                varchar2(150) := p_segment13;
   l_segment14                varchar2(150) := p_segment14;
   l_segment15                varchar2(150) := p_segment15;
   l_segment16                varchar2(150) := p_segment16;
   l_segment17                varchar2(150) := p_segment17;
   l_segment18                varchar2(150) := p_segment18;
   l_segment19                varchar2(150) := p_segment19;
   l_segment20                varchar2(150) := p_segment20;
   l_segment21                varchar2(150) := p_segment21;
   l_segment22                varchar2(150) := p_segment22;
   l_segment23                varchar2(150) := p_segment23;
   l_segment24                varchar2(150) := p_segment24;
   l_segment25                varchar2(150) := p_segment25;
   l_segment26                varchar2(150) := p_segment26;
   l_segment27                varchar2(150) := p_segment27;
   l_segment28                varchar2(150) := p_segment28;
   l_segment29                varchar2(150) := p_segment29;
   l_segment30                varchar2(150) := p_segment30;
   l_language_code            varchar2(30) := p_language_code;
   --
   -- bug 2242339 new variable to indicate whether key flex id parameter
   -- enters the program with a value.
   --
   l_null_ind                 number(1)    := 0;
   --
   --
   -- bug 2436606 Use job_group job KFF structure
   cursor idsel is
       select pjg.ID_FLEX_NUM
       from per_job_groups pjg
       where pjg.job_group_id = p_job_group_id;

   --
   --
   -- bug 2242339 get per_job_definition segment values where
   -- job_definition_id is known
   --
   cursor c_segments is
     select segment1,
            segment2,
            segment3,
            segment4,
            segment5,
            segment6,
            segment7,
            segment8,
            segment9,
            segment10,
            segment11,
            segment12,
            segment13,
            segment14,
            segment15,
            segment16,
            segment17,
            segment18,
            segment19,
            segment20,
            segment21,
            segment22,
            segment23,
            segment24,
            segment25,
            segment26,
            segment27,
            segment28,
            segment29,
            segment30
       from per_job_definitions
      where job_definition_id = l_job_definition_id;
--
begin
--
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_job;
  --
  -- Validate the language parameter. l_language_code should be passed
  -- instead of p_language_code from now on, to allow an IN OUT parameter to
  -- be passed through.
  --
  hr_api.validate_language_code(p_language_code => l_language_code);
  --
  -- Truncate date_from and date_to
  --
  l_date_from      := trunc(p_date_from);
  l_date_to        := trunc(p_date_to);
  --
  -- check that job group id is valid
  --
   per_job_bus.chk_job_group_id
     (p_job_group_id       => p_job_group_id
     ,p_business_group_id  => p_business_group_id);
  --
  -- check that flex structure is valid
  --
  open idsel;
  fetch idsel into l_flex_num;
  if idsel%notfound
  then
     close idsel;
     --
     -- the flex structure has not been found
     --
     hr_utility.set_message(801, 'HR_6039_ALL_CANT_GET_FFIELD');
     hr_utility.raise_error;
  end if;
  close idsel;
  --
  -- 2242339 get segment values if p_job_definition_id entered with a value
  --
  if l_job_definition_id is not null
  --
  then
  --
     hr_utility.set_location(l_proc, 15);
     --
     -- set indicator to show p_job_definition_id did not enter program null
     --
     l_null_ind := 1;
     --
     open c_segments;
        fetch c_segments into
                      l_segment1,
                      l_segment2,
                      l_segment3,
                      l_segment4,
                      l_segment5,
                      l_segment6,
                      l_segment7,
                      l_segment8,
                      l_segment9,
                      l_segment10,
                      l_segment11,
                      l_segment12,
                      l_segment13,
                      l_segment14,
                      l_segment15,
                      l_segment16,
                      l_segment17,
                      l_segment18,
                      l_segment19,
                      l_segment20,
                      l_segment21,
                      l_segment22,
                      l_segment23,
                      l_segment24,
                      l_segment25,
                      l_segment26,
                      l_segment27,
                      l_segment28,
                      l_segment29,
                      l_segment30;
     close c_segments;
  end if;
  --
  begin
  --
  -- Call Before Process User hook for create_job
  --
  hr_job_bk1.create_job_b
    (p_business_group_id             => p_business_group_id
    ,p_date_from                     => l_date_from
    ,p_comments                      => p_comments
    ,p_date_to                       => l_date_to
    ,p_approval_authority            => p_approval_authority
    ,p_benchmark_job_flag            => p_benchmark_job_flag
    ,p_benchmark_job_id              => p_benchmark_job_id
    ,p_emp_rights_flag               => p_emp_rights_flag
    ,p_job_group_id                  => p_job_group_id
    ,p_attribute_category            => p_attribute_category
    ,p_attribute1                    => p_attribute1
    ,p_attribute2                    => p_attribute2
    ,p_attribute3                    => p_attribute3
    ,p_attribute4                    => p_attribute4
    ,p_attribute5                    => p_attribute5
    ,p_attribute6                    => p_attribute6
    ,p_attribute7                    => p_attribute7
    ,p_attribute8                    => p_attribute8
    ,p_attribute9                    => p_attribute9
    ,p_attribute10                   => p_attribute10
    ,p_attribute11                   => p_attribute11
    ,p_attribute12                   => p_attribute12
    ,p_attribute13                   => p_attribute13
    ,p_attribute14                   => p_attribute14
    ,p_attribute15                   => p_attribute15
    ,p_attribute16                   => p_attribute16
    ,p_attribute17                   => p_attribute17
    ,p_attribute18                   => p_attribute18
    ,p_attribute19                   => p_attribute19
    ,p_attribute20                   => p_attribute20
    ,p_job_information_category      => p_job_information_category
    ,p_job_information1              => p_job_information1
    ,p_job_information2              => p_job_information2
    ,p_job_information3              => p_job_information3
    ,p_job_information4              => p_job_information4
    ,p_job_information5              => p_job_information5
    ,p_job_information6              => p_job_information6
    ,p_job_information7              => p_job_information7
    ,p_job_information8              => p_job_information8
    ,p_job_information9              => p_job_information9
    ,p_job_information10             => p_job_information10
    ,p_job_information11             => p_job_information11
    ,p_job_information12             => p_job_information12
    ,p_job_information13             => p_job_information13
    ,p_job_information14             => p_job_information14
    ,p_job_information15             => p_job_information15
    ,p_job_information16             => p_job_information16
    ,p_job_information17             => p_job_information17
    ,p_job_information18             => p_job_information18
    ,p_job_information19             => p_job_information19
    ,p_job_information20        => p_job_information20
    ,p_segment1                      => l_segment1
    ,p_segment2                      => l_segment2
    ,p_segment3                      => l_segment3
    ,p_segment4                      => l_segment4
    ,p_segment5                      => l_segment5
    ,p_segment6                      => l_segment6
    ,p_segment7                      => l_segment7
    ,p_segment8                      => l_segment8
    ,p_segment9                      => l_segment9
    ,p_segment10                     => l_segment10
    ,p_segment11                     => l_segment11
    ,p_segment12                     => l_segment12
    ,p_segment13                     => l_segment13
    ,p_segment14                     => l_segment14
    ,p_segment15                     => l_segment15
    ,p_segment16                     => l_segment16
    ,p_segment17                     => l_segment17
    ,p_segment18                     => l_segment18
    ,p_segment19                     => l_segment19
    ,p_segment20                     => l_segment20
    ,p_segment21                     => l_segment21
    ,p_segment22                     => l_segment22
    ,p_segment23                     => l_segment23
    ,p_segment24                     => l_segment24
    ,p_segment25                     => l_segment25
    ,p_segment26                     => l_segment26
    ,p_segment27                     => l_segment27
    ,p_segment28                     => l_segment28
    ,p_segment29                     => l_segment29
    ,p_segment30                     => l_segment30
    ,p_concat_segments               => p_concat_segments
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_JOB'
        ,p_hook_type   => 'BP'
        );
  --
  -- End of before hook process (create_job)
  --
  end;
  --
  -- Process Logic
  --
     --
     -- Determine the Grade defintion by calling ins_or_sel
     --
     hr_utility.set_location(l_proc, 20);
     --
     hr_kflex_utility.ins_or_sel_keyflex_comb
       (p_appl_short_name       => 'PER'
       ,p_flex_code             => 'JOB'
       ,p_flex_num              => l_flex_num
       ,p_segment1              => l_segment1
       ,p_segment2              => l_segment2
       ,p_segment3              => l_segment3
       ,p_segment4              => l_segment4
       ,p_segment5              => l_segment5
       ,p_segment6              => l_segment6
       ,p_segment7              => l_segment7
       ,p_segment8              => l_segment8
       ,p_segment9              => l_segment9
       ,p_segment10             => l_segment10
       ,p_segment11             => l_segment11
       ,p_segment12             => l_segment12
       ,p_segment13             => l_segment13
       ,p_segment14             => l_segment14
       ,p_segment15             => l_segment15
       ,p_segment16             => l_segment16
       ,p_segment17             => l_segment17
       ,p_segment18             => l_segment18
       ,p_segment19             => l_segment19
       ,p_segment20             => l_segment20
       ,p_segment21             => l_segment21
       ,p_segment22             => l_segment22
       ,p_segment23             => l_segment23
       ,p_segment24             => l_segment24
       ,p_segment25             => l_segment25
       ,p_segment26             => l_segment26
       ,p_segment27             => l_segment27
       ,p_segment28             => l_segment28
       ,p_segment29             => l_segment29
       ,p_segment30             => l_segment30
       ,p_concat_segments_in    => p_concat_segments
       ,p_ccid                  => l_job_definition_id
       ,p_concat_segments_out   => l_name
       );
  --
  if l_job_definition_id is not null
  then
  --
  -- Insert Job.
  --
     hr_utility.set_location(l_proc, 30);
     --
     per_job_ins.ins
       (p_job_id                       => l_job_id
       ,p_business_group_id            => p_business_group_id
       ,p_job_definition_id            => l_job_definition_id
       ,p_date_from                    => l_date_from
       ,p_comments                     => p_comments
       ,p_date_to                      => l_date_to
       ,p_approval_authority           => p_approval_authority
       ,p_name                         => l_name
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
       ,p_job_information_category     => p_job_information_category
       ,p_job_information1             => p_job_information1
       ,p_job_information2             => p_job_information2
       ,p_job_information3             => p_job_information3
       ,p_job_information4             => p_job_information4
       ,p_job_information5             => p_job_information5
       ,p_job_information6             => p_job_information6
       ,p_job_information7             => p_job_information7
       ,p_job_information8             => p_job_information8
       ,p_job_information9             => p_job_information9
       ,p_job_information10            => p_job_information10
       ,p_job_information11            => p_job_information11
       ,p_job_information12            => p_job_information12
       ,p_job_information13            => p_job_information13
       ,p_job_information14            => p_job_information14
       ,p_job_information15            => p_job_information15
       ,p_job_information16            => p_job_information16
       ,p_job_information17            => p_job_information17
       ,p_job_information18            => p_job_information18
       ,p_job_information19            => p_job_information19
       ,p_job_information20            => p_job_information20
       ,p_benchmark_job_flag           => p_benchmark_job_flag
       ,p_benchmark_job_id             => p_benchmark_job_id
       ,p_emp_rights_flag              => p_emp_rights_flag
       ,p_job_group_id                 => p_job_group_id
       ,p_object_version_number        => l_object_version_number
       ,p_validate                     => FALSE
       );
     --
     --
     -- MLS Processing
     --
     per_jbt_ins.ins_tl( p_language_code  => l_language_code
                        ,p_job_id         => l_job_id
                        ,p_name           => p_name);
  --
     hr_utility.set_location(l_proc, 40);
  --
  end if;
  --
  --
  -- Call After Process hook for create_job
  --
  begin
    hr_job_bk1.create_job_a
      (p_business_group_id             => p_business_group_id
      ,p_date_from                     => l_date_from
      ,p_comments                      => p_comments
      ,p_date_to                       => l_date_to
      ,p_approval_authority            => p_approval_authority
      ,p_benchmark_job_flag            => p_benchmark_job_flag
      ,p_benchmark_job_id              => p_benchmark_job_id
      ,p_emp_rights_flag               => p_emp_rights_flag
      ,p_job_group_id                  => p_job_group_id
      ,p_attribute_category            => p_attribute_category
      ,p_attribute1                    => p_attribute1
      ,p_attribute2                    => p_attribute2
      ,p_attribute3                    => p_attribute3
      ,p_attribute4                    => p_attribute4
      ,p_attribute5                    => p_attribute5
      ,p_attribute6                    => p_attribute6
      ,p_attribute7                    => p_attribute7
      ,p_attribute8                    => p_attribute8
      ,p_attribute9                    => p_attribute9
      ,p_attribute10                   => p_attribute10
      ,p_attribute11                   => p_attribute11
      ,p_attribute12                   => p_attribute12
      ,p_attribute13                   => p_attribute13
      ,p_attribute14                   => p_attribute14
      ,p_attribute15                   => p_attribute15
      ,p_attribute16                   => p_attribute16
      ,p_attribute17                   => p_attribute17
      ,p_attribute18                   => p_attribute18
      ,p_attribute19                   => p_attribute19
      ,p_attribute20                   => p_attribute20
      ,p_job_information_category      => p_job_information_category
      ,p_job_information1              => p_job_information1
      ,p_job_information2              => p_job_information2
      ,p_job_information3              => p_job_information3
      ,p_job_information4              => p_job_information4
      ,p_job_information5              => p_job_information5
      ,p_job_information6              => p_job_information6
      ,p_job_information7              => p_job_information7
      ,p_job_information8              => p_job_information8
      ,p_job_information9              => p_job_information9
      ,p_job_information10             => p_job_information10
      ,p_job_information11             => p_job_information11
      ,p_job_information12             => p_job_information12
      ,p_job_information13             => p_job_information13
      ,p_job_information14             => p_job_information14
      ,p_job_information15             => p_job_information15
      ,p_job_information16             => p_job_information16
      ,p_job_information17             => p_job_information17
      ,p_job_information18             => p_job_information18
      ,p_job_information19             => p_job_information19
      ,p_job_information20             => p_job_information20
      ,p_segment1                      => l_segment1
      ,p_segment2                      => l_segment2
      ,p_segment3                      => l_segment3
      ,p_segment4                      => l_segment4
      ,p_segment5                      => l_segment5
      ,p_segment6                      => l_segment6
      ,p_segment7                      => l_segment7
      ,p_segment8                      => l_segment8
      ,p_segment9                      => l_segment9
      ,p_segment10                     => l_segment10
      ,p_segment11                     => l_segment11
      ,p_segment12                     => l_segment12
      ,p_segment13                     => l_segment13
      ,p_segment14                     => l_segment14
      ,p_segment15                     => l_segment15
      ,p_segment16                     => l_segment16
      ,p_segment17                     => l_segment17
      ,p_segment18                     => l_segment18
      ,p_segment19                     => l_segment19
      ,p_segment20                     => l_segment20
      ,p_segment21                     => l_segment21
      ,p_segment22                     => l_segment22
      ,p_segment23                     => l_segment23
      ,p_segment24                     => l_segment24
      ,p_segment25                     => l_segment25
      ,p_segment26                     => l_segment26
      ,p_segment27                     => l_segment27
      ,p_segment28                     => l_segment28
      ,p_segment29                     => l_segment29
      ,p_segment30                     => l_segment30
      ,p_concat_segments               => p_concat_segments
      ,p_job_id                        => l_job_id
      ,p_object_version_number         => l_object_version_number
      ,p_job_definition_id             => l_job_definition_id
      ,p_name                          => l_name
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_JOB'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of after hook process (create_job)
    --
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate
  then
     raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 50);
  --
  -- Set OUT parameters
  --
   p_job_id                := l_job_id;
   p_object_version_number := l_object_version_number;
   p_job_definition_id     := l_job_definition_id;
   p_name                  := l_name;
   --
   hr_utility.set_location(' Leaving:'||l_proc, 60);
   --
   exception
   --
   when hr_api.validate_enabled then
     --
     -- As the Validate_Enabled exception has been raised
     -- we must rollback to the savepoint
     --
     ROLLBACK TO create_job;
     --
     -- Set OUT parameters to null
     -- Only set output warning arguments
     -- (Any key or derived arguments must be set to null
     -- when validation only mode is being used.)
     --
     if l_null_ind = 0
     then
        p_job_definition_id      := null;
     end if;
     p_job_id                    := null;
     p_object_version_number     := null;
     p_job_definition_id         := null;
     p_name                      := null;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
  when others then
     --
     -- A validation or unexpected error has occurred
     --
     -- Added as part of the fix to bug 632479
     --
     ROLLBACK TO create_job;
     --
    -- set in out parameters and set out parameters
    --
     p_job_id                    := null;
     p_object_version_number     := null;
     p_name                      := null;
     p_job_definition_id         := l_job_definition_id;
     --
     hr_utility.set_location(' Leaving:'||l_proc, 80);
     --
     raise;
     --
end create_job;
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_job >-------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_job
  (p_validate                      in     boolean  default false
  ,p_job_id                        in     number
  ,p_object_version_number         in out nocopy number
  ,p_date_from                     in     date     default hr_api.g_date
  ,p_comments                      in     varchar2 default hr_api.g_varchar2
  ,p_date_to                       in     date     default hr_api.g_date
  ,p_benchmark_job_flag            in     varchar2 default hr_api.g_varchar2
  ,p_benchmark_job_id              in     number   default hr_api.g_number
  ,p_emp_rights_flag               in     varchar2 default hr_api.g_varchar2
  ,p_attribute_category            in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                   in     varchar2 default hr_api.g_varchar2
  ,p_job_information_category      in     varchar2 default hr_api.g_varchar2
  ,p_job_information1              in     varchar2 default hr_api.g_varchar2
  ,p_job_information2              in     varchar2 default hr_api.g_varchar2
  ,p_job_information3              in     varchar2 default hr_api.g_varchar2
  ,p_job_information4              in     varchar2 default hr_api.g_varchar2
  ,p_job_information5              in     varchar2 default hr_api.g_varchar2
  ,p_job_information6              in     varchar2 default hr_api.g_varchar2
  ,p_job_information7              in     varchar2 default hr_api.g_varchar2
  ,p_job_information8              in     varchar2 default hr_api.g_varchar2
  ,p_job_information9              in     varchar2 default hr_api.g_varchar2
  ,p_job_information10             in     varchar2 default hr_api.g_varchar2
  ,p_job_information11             in     varchar2 default hr_api.g_varchar2
  ,p_job_information12             in     varchar2 default hr_api.g_varchar2
  ,p_job_information13             in     varchar2 default hr_api.g_varchar2
  ,p_job_information14             in     varchar2 default hr_api.g_varchar2
  ,p_job_information15             in     varchar2 default hr_api.g_varchar2
  ,p_job_information16             in     varchar2 default hr_api.g_varchar2
  ,p_job_information17             in     varchar2 default hr_api.g_varchar2
  ,p_job_information18             in     varchar2 default hr_api.g_varchar2
  ,p_job_information19             in     varchar2 default hr_api.g_varchar2
  ,p_job_information20             in     varchar2 default hr_api.g_varchar2
  ,p_segment1                      in     varchar2 default hr_api.g_varchar2
  ,p_segment2                      in     varchar2 default hr_api.g_varchar2
  ,p_segment3                      in     varchar2 default hr_api.g_varchar2
  ,p_segment4                      in     varchar2 default hr_api.g_varchar2
  ,p_segment5                      in     varchar2 default hr_api.g_varchar2
  ,p_segment6                      in     varchar2 default hr_api.g_varchar2
  ,p_segment7                      in     varchar2 default hr_api.g_varchar2
  ,p_segment8                      in     varchar2 default hr_api.g_varchar2
  ,p_segment9                      in     varchar2 default hr_api.g_varchar2
  ,p_segment10                     in     varchar2 default hr_api.g_varchar2
  ,p_segment11                     in     varchar2 default hr_api.g_varchar2
  ,p_segment12                     in     varchar2 default hr_api.g_varchar2
  ,p_segment13                     in     varchar2 default hr_api.g_varchar2
  ,p_segment14                     in     varchar2 default hr_api.g_varchar2
  ,p_segment15                     in     varchar2 default hr_api.g_varchar2
  ,p_segment16                     in     varchar2 default hr_api.g_varchar2
  ,p_segment17                     in     varchar2 default hr_api.g_varchar2
  ,p_segment18                     in     varchar2 default hr_api.g_varchar2
  ,p_segment19                     in     varchar2 default hr_api.g_varchar2
  ,p_segment20                     in     varchar2 default hr_api.g_varchar2
  ,p_segment21                     in     varchar2 default hr_api.g_varchar2
  ,p_segment22                     in     varchar2 default hr_api.g_varchar2
  ,p_segment23                     in     varchar2 default hr_api.g_varchar2
  ,p_segment24                     in     varchar2 default hr_api.g_varchar2
  ,p_segment25                     in     varchar2 default hr_api.g_varchar2
  ,p_segment26                     in     varchar2 default hr_api.g_varchar2
  ,p_segment27                     in     varchar2 default hr_api.g_varchar2
  ,p_segment28                     in     varchar2 default hr_api.g_varchar2
  ,p_segment29                     in     varchar2 default hr_api.g_varchar2
  ,p_segment30                     in     varchar2 default hr_api.g_varchar2
  ,p_concat_segments               in     varchar2 default hr_api.g_varchar2
  ,p_approval_authority            in     number   default hr_api.g_number
  ,p_language_code                 in     varchar2 default hr_api.userenv_lang
  --
  -- bug 2242339 change p_job_definition_id from an out to an in/out parameter
  -- to enable value to be passed into program when known and required.
  --
  ,p_job_definition_id             in out nocopy number
  ,p_name                             out nocopy varchar2
  ,p_valid_grades_changed_warning     out nocopy boolean
  -- Defaulting it for fix 3138252
  ,p_effective_date        in date   default hr_api.g_date --Added for Bug# 1760707
  ) is
--
-- Declare cursors and local variables
--
  -- bug 2242339 initialize l_job_definition_id and segment variables with
  -- values where these are passed into program.
  --
  l_job_id                   per_jobs.job_id%TYPE;
  l_job_definition_id        per_jobs.job_definition_id%TYPE                      := p_job_definition_id;
  l_business_group_id        per_jobs.business_group_id%TYPE;
  l_name                     varchar2(700);
  l_proc                     varchar2(72) := g_package||'update_job';
  l_flex_num                 fnd_id_flex_segments.id_flex_num%TYPE;
  l_object_version_number    per_jobs.object_version_number%TYPE;
  l_valid_grades_changed1    boolean default FALSE;
  l_valid_grades_changed2    boolean default FALSE;
  l_api_updating             boolean;
  l_date_from          per_jobs.date_from%TYPE;
  l_date_to         per_jobs.date_to%TYPE;
  l_segment1                   varchar2(150) := p_segment1;
  l_segment2                   varchar2(150) := p_segment2;
  l_segment3                   varchar2(150) := p_segment3;
  l_segment4                   varchar2(150) := p_segment4;
  l_segment5                   varchar2(150) := p_segment5;
  l_segment6                   varchar2(150) := p_segment6;
  l_segment7                   varchar2(150) := p_segment7;
  l_segment8                   varchar2(150) := p_segment8;
  l_segment9                   varchar2(150) := p_segment9;
  l_segment10                  varchar2(150) := p_segment10;
  l_segment11                  varchar2(150) := p_segment11;
  l_segment12                  varchar2(150) := p_segment12;
  l_segment13                  varchar2(150) := p_segment13;
  l_segment14                  varchar2(150) := p_segment14;
  l_segment15                  varchar2(150) := p_segment15;
  l_segment16                  varchar2(150) := p_segment16;
  l_segment17                  varchar2(150) := p_segment17;
  l_segment18                  varchar2(150) := p_segment18;
  l_segment19                  varchar2(150) := p_segment19;
  l_segment20                  varchar2(150) := p_segment20;
  l_segment21                  varchar2(150) := p_segment21;
  l_segment22                  varchar2(150) := p_segment22;
  l_segment23                  varchar2(150) := p_segment23;
  l_segment24                  varchar2(150) := p_segment24;
  l_segment25                  varchar2(150) := p_segment25;
  l_segment26                  varchar2(150) := p_segment26;
  l_segment27                  varchar2(150) := p_segment27;
  l_segment28                  varchar2(150) := p_segment28;
  l_segment29                  varchar2(150) := p_segment29;
  l_segment30                  varchar2(150) := p_segment30;
  l_null_ind                   number(1)    := 0;
  l_language_code              varchar2(30) := p_language_code;
  --
  -- Declare cursors
  --
  -- bug 2436606 Use job_group job KFF structure
  --
  cursor idsel is
     select pjg.ID_FLEX_NUM
     from per_job_groups pjg
     where pjg.JOB_GROUP_ID = (select job_group_id
                              from per_jobs
                              where JOB_ID = p_job_id);

  --
  -- bug 2242339 get per_job_definition segment values where
  -- job_definition_id is known
  --
  cursor c_segments is
    select segment1,
           segment2,
           segment3,
           segment4,
           segment5,
           segment6,
           segment7,
           segment8,
           segment9,
           segment10,
           segment11,
           segment12,
           segment13,
           segment14,
           segment15,
           segment16,
           segment17,
           segment18,
           segment19,
           segment20,
           segment21,
           segment22,
           segment23,
           segment24,
           segment25,
           segment26,
           segment27,
           segment28,
           segment29,
           segment30
      from per_job_definitions
     where job_definition_id = l_job_definition_id;
--
begin
--
   hr_utility.set_location('Entering:'|| l_proc, 5);
   --
   -- Issue a savepoint
   --
   savepoint update_job;
   --
   -- Validate the language parameter. l_language_code should be passed
   -- instead of p_language_code from now on, to allow an IN OUT parameter to
   -- be passed through.
   --
   hr_api.validate_language_code(p_language_code => l_language_code);
   --
   hr_utility.set_location(l_proc, 10);
   --
   l_object_version_number := p_object_version_number;
   --
   -- Validation in addition to Table Handlers
   --
   -- Retrieve current position details from position
   --
   l_api_updating := per_job_shd.api_updating
     (p_job_id            => p_job_id
     ,p_object_version_number => p_object_version_number);
   --
   hr_utility.set_location(l_proc, 15);
   --
   if not l_api_updating
   then
      hr_utility.set_location(l_proc, 20);
      --
      -- As this an updating API, the position should already exist.
      --
      hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
      hr_utility.raise_error;
   else
      if l_job_definition_id is null
      then
         l_null_ind := 0;
         l_job_definition_id := per_job_shd.g_old_rec.job_definition_id;
         hr_utility.set_location(l_proc, 24);
      else
         -- 2242339
         -- get segment values if p_job_definition_id entered with a value
         -- set indicator to show p_job_definition_id did not enter program null
         --
         l_null_ind := 1;
         --
         open c_segments;
            fetch c_segments into
                      l_segment1,
                      l_segment2,
                      l_segment3,
                      l_segment4,
                      l_segment5,
                      l_segment6,
                      l_segment7,
                      l_segment8,
                      l_segment9,
                      l_segment10,
                      l_segment11,
                      l_segment12,
                      l_segment13,
                      l_segment14,
                      l_segment15,
                      l_segment16,
                      l_segment17,
                      l_segment18,
                      l_segment19,
                      l_segment20,
                      l_segment21,
                      l_segment22,
                      l_segment23,
                      l_segment24,
                      l_segment25,
                      l_segment26,
                      l_segment27,
                      l_segment28,
                      l_segment29,
                      l_segment30;
         close c_segments;
         hr_utility.set_location(l_proc, 27);
         --
      end if;
      --
   end if;
   --
   hr_utility.set_location('Entering: call - update_job_b',35);
   --
   --
   -- Call Before Process User Hook
   --
   begin
   --
     hr_job_api_bk2.update_job_b
      (p_job_id                => p_job_id
      ,p_date_from                     => l_date_from
      ,p_comments                      => p_comments
      ,p_date_to                       => l_date_to
      ,p_approval_authority            => p_approval_authority
      ,p_benchmark_job_flag            => p_benchmark_job_flag
      ,p_benchmark_job_id              => p_benchmark_job_id
      ,p_emp_rights_flag               => p_emp_rights_flag
      ,p_attribute_category            => p_attribute_category
      ,p_attribute1                    => p_attribute1
      ,p_attribute2                    => p_attribute2
      ,p_attribute3                    => p_attribute3
      ,p_attribute4                    => p_attribute4
      ,p_attribute5                    => p_attribute5
      ,p_attribute6                    => p_attribute6
      ,p_attribute7                    => p_attribute7
      ,p_attribute8                    => p_attribute8
      ,p_attribute9                    => p_attribute9
      ,p_attribute10                   => p_attribute10
      ,p_attribute11                   => p_attribute11
      ,p_attribute12                   => p_attribute12
      ,p_attribute13                   => p_attribute13
      ,p_attribute14                   => p_attribute14
      ,p_attribute15                   => p_attribute15
      ,p_attribute16                   => p_attribute16
      ,p_attribute17                   => p_attribute17
      ,p_attribute18                   => p_attribute18
      ,p_attribute19                   => p_attribute19
      ,p_attribute20                   => p_attribute20
      ,p_job_information_category      => p_job_information_category
      ,p_job_information1              => p_job_information1
      ,p_job_information2              => p_job_information2
      ,p_job_information3              => p_job_information3
      ,p_job_information4              => p_job_information4
      ,p_job_information5              => p_job_information5
      ,p_job_information6              => p_job_information6
      ,p_job_information7              => p_job_information7
      ,p_job_information8              => p_job_information8
      ,p_job_information9              => p_job_information9
      ,p_job_information10             => p_job_information10
      ,p_job_information11             => p_job_information11
      ,p_job_information12             => p_job_information12
      ,p_job_information13             => p_job_information13
      ,p_job_information14             => p_job_information14
      ,p_job_information15             => p_job_information15
      ,p_job_information16             => p_job_information16
      ,p_job_information17             => p_job_information17
      ,p_job_information18             => p_job_information18
      ,p_job_information19             => p_job_information19
      ,p_job_information20             => p_job_information20
      ,p_segment1                      => l_segment1
      ,p_segment2                      => l_segment2
      ,p_segment3                      => l_segment3
      ,p_segment4                      => l_segment4
      ,p_segment5                      => l_segment5
      ,p_segment6                      => l_segment6
      ,p_segment7                      => l_segment7
      ,p_segment8                      => l_segment8
      ,p_segment9                      => l_segment9
      ,p_segment10                     => l_segment10
      ,p_segment11                     => l_segment11
      ,p_segment12                     => l_segment12
      ,p_segment13                     => l_segment13
      ,p_segment14                     => l_segment14
      ,p_segment15                     => l_segment15
      ,p_segment16                     => l_segment16
      ,p_segment17                     => l_segment17
      ,p_segment18                     => l_segment18
      ,p_segment19                     => l_segment19
      ,p_segment20                     => l_segment20
      ,p_segment21                     => l_segment21
      ,p_segment22                     => l_segment22
      ,p_segment23                     => l_segment23
      ,p_segment24                     => l_segment24
      ,p_segment25                     => l_segment25
      ,p_segment26                     => l_segment26
      ,p_segment27                     => l_segment27
      ,p_segment28                     => l_segment28
      ,p_segment29                     => l_segment29
      ,p_segment30                     => l_segment30
      ,p_concat_segments               => p_concat_segments
      ,p_name                    => p_name
      ,p_object_version_number          => p_object_version_number
      ,p_job_definition_id        => p_job_definition_id
      ,p_effective_date           => p_effective_date   --Added for bug# 1760707
      );
   exception
     when hr_api.cannot_find_prog_unit
     then
        hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_JOB'
        ,p_hook_type   => 'BP'
        );
   end; -- End of API User Hook for the before hook of update_job
   --
   hr_utility.set_location('Entering:'|| l_proc, 30);
   --
   -- Because we may need to maintain the valid grade dates, need to
   -- explicitly lock the per_jobs row.
   --
   -- per_job_shd.lck(p_job_id => p_job_id
   --       ,p_object_version_number => l_object_version_number);
   --
   hr_utility.set_location('Entering:'|| l_proc, 36);
   --
   open idsel;
   fetch idsel into l_flex_num;
   if idsel%notfound
   then
      hr_utility.set_location('Entering:'|| l_proc, 38);
      close idsel;
      --
      -- the flex structure has not been found
      --
      hr_utility.set_message(801, 'HR_6039_ALL_CANT_GET_FFIELD');
      hr_utility.raise_error;
   end if;
   close idsel;
   hr_utility.set_location(l_proc, 40);
   l_date_from      := trunc(p_date_from);
   l_date_to        := trunc(p_date_to);
   --
   --
   -- update job definitions in per_job_definitions if p_job_definition_id had
   -- no value when passed into program

   hr_utility.set_location(l_proc, 50);
   hr_utility.trace('JBD before upd_or_sel '||l_job_definition_id);
   --
   hr_kflex_utility.upd_or_sel_keyflex_comb
       (p_appl_short_name     => 'PER'
       ,p_flex_code           => 'JOB'
       ,p_flex_num            => l_flex_num
       ,p_segment1            => l_segment1
       ,p_segment2            => l_segment2
       ,p_segment3            => l_segment3
       ,p_segment4            => l_segment4
       ,p_segment5            => l_segment5
       ,p_segment6            => l_segment6
       ,p_segment7            => l_segment7
       ,p_segment8            => l_segment8
       ,p_segment9            => l_segment9
       ,p_segment10           => l_segment10 -- #4163409 added
       ,p_segment11           => l_segment11 -- #4163409 changed from l_segment10 to l_segment11
       ,p_segment12           => l_segment12
       ,p_segment13           => l_segment13
       ,p_segment14           => l_segment14
       ,p_segment15           => l_segment15
       ,p_segment16           => l_segment16
       ,p_segment17           => l_segment17
       ,p_segment18           => l_segment18
       ,p_segment19           => l_segment19
       ,p_segment20           => l_segment20
       ,p_segment21           => l_segment21
       ,p_segment22           => l_segment22
       ,p_segment23           => l_segment23
       ,p_segment24           => l_segment24
       ,p_segment25           => l_segment25
       ,p_segment26           => l_segment26
       ,p_segment27           => l_segment27
       ,p_segment28           => l_segment28
       ,p_segment29           => l_segment29
       ,p_segment30           => l_segment30
       ,p_concat_segments_in  => p_concat_segments
       ,p_ccid                => l_job_definition_id
       ,p_concat_segments_out => l_name
    );
    --
   hr_utility.set_location(l_proc, 60);
   --
   -- Because we may need to maintain the valid grade dates, need to
   -- explicitly lock the per_jobs row.
   --
   -- per_job_shd.lck(p_job_id => p_job_id
   --  ,p_object_version_number => l_object_version_number);
   --
   hr_utility.set_location(l_proc, 65);
   --
   -- If date_from is being updated , then need to maintain valid grades
   -- accordingly for that job.
   --
   if ((nvl(p_date_from, hr_api.g_date) <> hr_api.g_date) and
       per_job_shd.g_old_rec.date_from <>
       nvl(p_date_from, hr_api.g_date))
   then
      --
      maintain_valid_grades
        (p_validate             => p_validate
        ,p_job_id               => p_job_id
        ,p_maintenance_mode     => c_date_from
        ,p_date_to              => p_date_to
        ,p_date_from            => p_date_from
        ,p_valid_grades_changed => l_valid_grades_changed1
        ,p_effective_date  => p_effective_date);  --Added for Bug# 1760707
   end if;
   --
   hr_utility.set_location(l_proc, 70);
   --
   -- If date_end is being updated , then need to maintain valid grades
   -- accordingly for that job.
   --
   if ((nvl(p_date_to, hr_api.g_date) <> hr_api.g_date) and
         nvl(per_job_shd.g_old_rec.date_to, hr_api.g_date) <>
         nvl(p_date_to, hr_api.g_date))
   then
      maintain_valid_grades
      (p_validate       => p_validate
      ,p_job_id               => p_job_id
      ,p_maintenance_mode     => c_date_to
      ,p_date_to              => p_date_to
      ,p_date_from            => p_date_from
      ,p_valid_grades_changed => l_valid_grades_changed2
      ,p_effective_date       => p_effective_date);  --Added for Bug# 1760707
      --
   end if;
   --
   --
   -- Update Job details.
   --
   hr_utility.set_location('Entering per_job_upd.upd'||l_proc,80);
   --
   --
   per_job_upd.upd
   (p_job_id                       => p_job_id
   ,p_job_definition_id            => l_job_definition_id
   ,p_date_from                    => p_date_from
   ,p_comments                     => p_comments
   ,p_date_to                      => p_date_to
   ,p_approval_authority           => p_approval_authority
   ,p_name                         => l_name
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
   ,p_job_information_category     => p_job_information_category
   ,p_job_information1             => p_job_information1
   ,p_job_information2             => p_job_information2
   ,p_job_information3             => p_job_information3
   ,p_job_information4             => p_job_information4
   ,p_job_information5             => p_job_information5
   ,p_job_information6             => p_job_information6
   ,p_job_information7             => p_job_information7
   ,p_job_information8             => p_job_information8
   ,p_job_information9             => p_job_information9
   ,p_job_information10            => p_job_information10
   ,p_job_information11            => p_job_information11
   ,p_job_information12            => p_job_information12
   ,p_job_information13            => p_job_information13
   ,p_job_information14            => p_job_information14
   ,p_job_information15            => p_job_information15
   ,p_job_information16            => p_job_information16
   ,p_job_information17            => p_job_information17
   ,p_job_information18            => p_job_information18
   ,p_job_information19            => p_job_information19
   ,p_job_information20            => p_job_information20
   ,p_benchmark_job_flag           => p_benchmark_job_flag
   ,p_benchmark_job_id             => p_benchmark_job_id
   ,p_emp_rights_flag              => p_emp_rights_flag
   ,p_object_version_number        => l_object_version_number
   ,p_validate                     => p_validate
   );
  --
  -- MLS Processing
  --
  per_jbt_upd.upd_tl( p_language_code  => l_language_code
                     ,p_job_id         => p_job_id
                     ,p_name           => p_name);
  --

  hr_utility.set_location('Entering: call - update_job_a',55);
  --
  begin
  --
  hr_job_api_bk2.update_job_a
     (p_job_id                        => p_job_id
     ,p_date_from                     => l_date_from
     ,p_comments                      => p_comments
     ,p_date_to                       => l_date_to
     ,p_approval_authority            => p_approval_authority
     ,p_benchmark_job_flag            => p_benchmark_job_flag
     ,p_benchmark_job_id              => p_benchmark_job_id
     ,p_emp_rights_flag               => p_emp_rights_flag
     ,p_attribute_category            => p_attribute_category
     ,p_attribute1                    => p_attribute1
     ,p_attribute2                    => p_attribute2
     ,p_attribute3                    => p_attribute3
     ,p_attribute4                    => p_attribute4
     ,p_attribute5                    => p_attribute5
     ,p_attribute6                    => p_attribute6
     ,p_attribute7                    => p_attribute7
     ,p_attribute8                    => p_attribute8
     ,p_attribute9                    => p_attribute9
     ,p_attribute10                   => p_attribute10
     ,p_attribute11                   => p_attribute11
     ,p_attribute12                   => p_attribute12
     ,p_attribute13                   => p_attribute13
     ,p_attribute14                   => p_attribute14
     ,p_attribute15                   => p_attribute15
     ,p_attribute16                   => p_attribute16
     ,p_attribute17                   => p_attribute17
     ,p_attribute18                   => p_attribute18
     ,p_attribute19                   => p_attribute19
     ,p_attribute20                   => p_attribute20
     ,p_job_information_category      => p_job_information_category
     ,p_job_information1              => p_job_information1
     ,p_job_information2              => p_job_information2
     ,p_job_information3              => p_job_information3
     ,p_job_information4              => p_job_information4
     ,p_job_information5              => p_job_information5
     ,p_job_information6              => p_job_information6
     ,p_job_information7              => p_job_information7
     ,p_job_information8              => p_job_information8
     ,p_job_information9              => p_job_information9
     ,p_job_information10             => p_job_information10
     ,p_job_information11             => p_job_information11
     ,p_job_information12             => p_job_information12
     ,p_job_information13             => p_job_information13
     ,p_job_information14             => p_job_information14
     ,p_job_information15             => p_job_information15
     ,p_job_information16             => p_job_information16
     ,p_job_information17             => p_job_information17
     ,p_job_information18             => p_job_information18
     ,p_job_information19             => p_job_information19
     ,p_job_information20             => p_job_information20
     ,p_segment1                      => l_segment1
     ,p_segment2                      => l_segment2
     ,p_segment3                      => l_segment3
     ,p_segment4                      => l_segment4
     ,p_segment5                      => l_segment5
     ,p_segment6                      => l_segment6
     ,p_segment7                      => l_segment7
     ,p_segment8                      => l_segment8
     ,p_segment9                      => l_segment9
     ,p_segment10                     => l_segment10
     ,p_segment11                     => l_segment11
     ,p_segment12                     => l_segment12
     ,p_segment13                     => l_segment13
     ,p_segment14                     => l_segment14
     ,p_segment15                     => l_segment15
     ,p_segment16                     => l_segment16
     ,p_segment17                     => l_segment17
     ,p_segment18                     => l_segment18
     ,p_segment19                     => l_segment19
     ,p_segment20                     => l_segment20
     ,p_segment21                     => l_segment21
     ,p_segment22                     => l_segment22
     ,p_segment23                     => l_segment23
     ,p_segment24                     => l_segment24
     ,p_segment25                     => l_segment25
     ,p_segment26                     => l_segment26
     ,p_segment27                     => l_segment27
     ,p_segment28                     => l_segment28
     ,p_segment29                     => l_segment29
     ,p_segment30                     => l_segment30
     ,p_concat_segments               => p_concat_segments
     ,p_name              => p_name
     ,p_object_version_number      => p_object_version_number
     ,p_job_definition_id       => p_job_definition_id
     ,p_effective_date          => p_effective_date   --Added for Bug# 1760707
     );
   --
   exception
     when hr_api.cannot_find_prog_unit then
       hr_api.cannot_find_prog_unit_error
         (p_module_name => 'UPDATE_JOB'
         ,p_hook_type   => 'AP'
         );
   end; -- End of API User Hook for the after hook of update_job
   --
   hr_utility.set_location(l_proc, 90);
   --
   -- When in validation only mode raise the Validate_Enabled exception
   --
   if p_validate
   then
      raise hr_api.validate_enabled;
   end if;
   --
   p_object_version_number := l_object_version_number;
   if l_valid_grades_changed1 or l_valid_grades_changed2
   then
      p_valid_grades_changed_warning := TRUE;
   else
      p_valid_grades_changed_warning := FALSE;
   end if;
   p_job_definition_id := l_job_definition_id;
   p_name := l_name;
   --
   hr_utility.set_location(' Leaving:'||l_proc, 100);
   exception
   when hr_api.validate_enabled then
   --
   -- As the Validate_Enabled exception has been raised
   -- we must rollback to the savepoint
   --
   ROLLBACK TO update_job;
   --
   -- Only set output warning arguments
   -- (Any key or derived arguments must be set to null
   -- when validation only mode is being used.)
   --
   p_object_version_number := p_object_version_number;
   if l_valid_grades_changed1 or l_valid_grades_changed2
   then
      p_valid_grades_changed_warning := TRUE;
   else
      p_valid_grades_changed_warning := FALSE;
   end if;
   if l_null_ind = 0
   then
      p_job_definition_id := null;
   end if;
   p_name := null;
   when others then
   --
   --
   -- A validation or unexpected error has occured
   --
   rollback to update_job;
    --
    -- set in out parameters and set out parameters
    --
    p_name := null;
    p_valid_grades_changed_warning := FALSE;
    p_object_version_number := l_object_version_number;
    p_job_definition_id := l_job_definition_id;
   hr_utility.set_location(' Leaving:'||l_proc, 120);
   raise;
end update_job;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_job >--------------------------------|
-- ----------------------------------------------------------------------------
--

procedure delete_job
  (p_validate                      in     boolean
  ,p_job_id                        in     number
  ,p_object_version_number         in out nocopy number) IS

  l_object_version_number       number(9);
  l_proc                varchar2(72) := g_package||'DELETE_JOB';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);

  --
  -- Issue a savepoint
  --
  savepoint DELETE_JOB;

  --
  -- Call Before Process User Hook
  --
  begin
  hr_job_api_bk3.delete_job_b
    (p_validate                   =>  p_validate
    ,p_job_id                     =>  p_job_id
    ,p_object_version_number      =>  p_object_version_number);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_JOB'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- MLS Processing
  --
  per_jbt_del.del_tl(p_job_id  => p_job_id);

  -- Process Logic
  --
l_object_version_number := p_object_version_number;
--
per_job_del.del
  (p_job_id    => p_job_id
  ,p_object_version_number         => l_object_version_number);
  --
  -- Call After Process User Hook
  --
 begin
  hr_job_api_bk3.delete_job_a
    (p_validate                   =>  p_validate
    ,p_job_id                     =>  p_job_id
    ,p_object_version_number      =>  l_object_version_number);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_JOB'
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
  p_object_version_number := l_object_version_number;

  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to DELETE_JOB;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to DELETE_JOB;
        --
    -- set in out parameters and set out parameters
    --
    p_object_version_number := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_job;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< get_next_sequence >-------------------------|
-- ----------------------------------------------------------------------------
procedure get_next_sequence(p_job_id in out nocopy number) is
--
cursor c1 is select per_jobs_s.nextval
        from sys.dual;
l_proc   varchar2(72) := g_package||'get_next_sequence';
--
begin
  --
  -- Retrieve the next sequence number for job_id
  --
  if (p_job_id is null) then
    open c1;
    fetch c1 into p_job_id;
    if (C1%NOTFOUND) then
       CLOSE C1;
       hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
       hr_utility.set_message_token('PROCEDURE','get_next_sequence');
       hr_utility.set_message_token('STEP','1');
    end if;
      close c1;
  end if;
  --
  hr_utility.set_location(l_proc, 10);
  --
end get_next_sequence;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< get_job_flex_structure >--------------------|
-- ----------------------------------------------------------------------------
procedure get_job_flex_structure(
                p_structure_defining_column in out nocopy varchar2,
           p_job_group_id              in number) is
--
-- Get the job_flex_structure_id
--
l_struct varchar2(30);
l_proc   varchar2(72) := g_package||'get_job_flex_structure';
--
cursor csr_job is select to_char(id_flex_num)
        from per_job_groups_v
        where p_job_group_id = job_group_id;
--
v_not_found boolean := FALSE;
--
-- Get job flex structure id
--
begin
  --
  open csr_job;
  fetch csr_job into p_structure_defining_column;
  v_not_found := csr_job%NOTFOUND;
  close csr_job;
  --
 l_struct := p_structure_defining_column;
 hr_utility.set_location('p_struct '||l_struct, 99);
 --
  if v_not_found then
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','get_job_flex_structure');
      hr_utility.set_message_token('STEP','1');
      hr_utility.raise_error;
  end if;
  --
  hr_utility.set_location(l_proc, 10);
  --
end get_job_flex_structure;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_valid_grades >-----------------------|
-- ----------------------------------------------------------------------------
procedure update_valid_grades(p_business_group_id    number,
                         p_job_id               number,
               p_date_to              date,
               p_end_of_time          date) is
--
begin
   --
   -- Update valid grade end dates to match the end date of the
   -- job where the end date of the job is earlier than the end
   -- date of the valid grade.or the previous end dates matched.
   --
   --
   update per_valid_grades vg
   set vg.date_to =
   (select least(nvl(p_date_to, p_end_of_time),
            nvl(g.date_to, p_end_of_time))
         from   per_grades g
    where  g.grade_id          = vg.grade_id
    and    g.business_group_id + 0 = p_business_group_id)
   where vg.business_group_id + 0 = p_business_group_id
   and   vg.job_id            = p_job_id
   and   nvl(vg.date_to, p_end_of_time) > p_date_to;
   --
   if (SQL%NOTFOUND) then
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','update_valid_grades');
      hr_utility.set_message_token('STEP','1');
      hr_utility.raise_error;
   end if;
   --
   --
end update_valid_grades;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_valid_grades >-----------------------|
-- ----------------------------------------------------------------------------
procedure delete_valid_grades(p_business_group_id    number,
               p_job_id               number,
               p_date_to              date) is
--
begin
   --
   -- Valid grades are deleted if the end date of the job
   -- has been made earlier than the start date of the
   -- valid grade.
   --
   --
   delete from per_valid_grades vg
   where  vg.business_group_id + 0 = p_business_group_id
   and    vg.job_id            = p_job_id
   and    vg.date_from         > p_date_to;
   --
   --
   if (SQL%NOTFOUND) then
      hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
      hr_utility.set_message_token('PROCEDURE','delete_valid_grades');
      hr_utility.set_message_token('STEP','1');
      hr_utility.raise_error;
   end if;
   --
end delete_valid_grades;
--
end hr_job_api;

/
