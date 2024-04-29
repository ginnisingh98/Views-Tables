--------------------------------------------------------
--  DDL for Package Body HR_NO_JOB_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_NO_JOB_API" as
/* $Header: pejobnoi.pkb 120.0 2005/05/31 10:46:35 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_no_job_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_no_job >------------------------------------|
-- ----------------------------------------------------------------------------
procedure create_no_job
    (p_validate                      in     boolean
    ,p_job_group_id                  in     number
    ,p_business_group_id             in     number
    ,p_date_from                     in     date
    ,p_comments                      in     varchar2
    ,p_date_to                       in     date
    ,p_approval_authority            in     number
    ,p_benchmark_job_flag            in     varchar2
    ,p_benchmark_job_id              in     number
    ,p_emp_rights_flag               in     varchar2
    ,p_attribute_category            in     varchar2
    ,p_attribute1                    in     varchar2
    ,p_attribute2                    in     varchar2
    ,p_attribute3                    in     varchar2
    ,p_attribute4                    in     varchar2
    ,p_attribute5                    in     varchar2
    ,p_attribute6                    in     varchar2
    ,p_attribute7                    in     varchar2
    ,p_attribute8                    in     varchar2
    ,p_attribute9                    in     varchar2
    ,p_attribute10                   in     varchar2
    ,p_attribute11                   in     varchar2
    ,p_attribute12                   in     varchar2
    ,p_attribute13                   in     varchar2
    ,p_attribute14                   in     varchar2
    ,p_attribute15                   in     varchar2
    ,p_attribute16                   in     varchar2
    ,p_attribute17                   in     varchar2
    ,p_attribute18                   in     varchar2
    ,p_attribute19                   in     varchar2
    ,p_attribute20                   in     varchar2
    ,p_ssb_position_code             in     varchar2
    ,p_working_title                 in     varchar2
    ,p_segment1                      in     varchar2
    ,p_segment2                      in     varchar2
    ,p_segment3                      in     varchar2
    ,p_segment4                      in     varchar2
    ,p_segment5                      in     varchar2
    ,p_segment6                      in     varchar2
    ,p_segment7                      in     varchar2
    ,p_segment8                      in     varchar2
    ,p_segment9                      in     varchar2
    ,p_segment10                     in     varchar2
    ,p_segment11                     in     varchar2
    ,p_segment12                     in     varchar2
    ,p_segment13                     in     varchar2
    ,p_segment14                     in     varchar2
    ,p_segment15                     in     varchar2
    ,p_segment16                     in     varchar2
    ,p_segment17                     in     varchar2
    ,p_segment18                     in     varchar2
    ,p_segment19                     in     varchar2
    ,p_segment20                     in     varchar2
    ,p_segment21                     in     varchar2
    ,p_segment22                     in     varchar2
    ,p_segment23                     in     varchar2
    ,p_segment24                     in     varchar2
    ,p_segment25                     in     varchar2
    ,p_segment26                     in     varchar2
    ,p_segment27                     in     varchar2
    ,p_segment28                     in     varchar2
    ,p_segment29                     in     varchar2
    ,p_segment30                     in     varchar2
    ,p_concat_segments               in     varchar2
    ,p_job_id                           out nocopy number
    ,p_object_version_number            out nocopy number
    ,p_job_definition_id                out nocopy number
    ,p_name                             out nocopy varchar2
    ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                 varchar2(72) := g_package||'create_no_job';
  l_legislation_code     varchar2(2);
  --
  cursor csr_bg is
    select legislation_code
    from per_business_groups pbg
    where pbg.business_group_id = p_business_group_id;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Validation in addition to Row Handlers
  --
  -- Check that the specified business group is valid.
  --
  open csr_bg;
  fetch csr_bg
  into l_legislation_code;
  if csr_bg%notfound then
    close csr_bg;
    hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
    hr_utility.raise_error;
  end if;
  close csr_bg;
  --
  -- Check that the legislation of the specified business group is 'NO'.
  --
  if l_legislation_code <> 'NO' then
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','NO');
    hr_utility.raise_error;
  end if;

  hr_utility.set_location(l_proc, 6);
  --
  -- Call the person business process
  --
hr_job_api.create_job
      (p_validate		       => p_validate
      ,p_job_group_id                  => p_job_group_id
      ,p_business_group_id             => p_business_group_id
      ,p_date_from                     => p_date_from
      ,p_comments                      => p_comments
      ,p_date_to                       => p_date_to
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
      ,p_job_information_category      => 'NO'
      ,p_job_information1 	       => p_ssb_position_code
      ,p_job_information2 	       => p_working_title
      ,p_segment1                      => p_segment1
      ,p_segment2                      => p_segment2
      ,p_segment3                      => p_segment3
      ,p_segment4                      => p_segment4
      ,p_segment5                      => p_segment5
      ,p_segment6                      => p_segment6
      ,p_segment7                      => p_segment7
      ,p_segment8                      => p_segment8
      ,p_segment9                      => p_segment9
      ,p_segment10                     => p_segment10
      ,p_segment11                     => p_segment11
      ,p_segment12                     => p_segment12
      ,p_segment13                     => p_segment13
      ,p_segment14                     => p_segment14
      ,p_segment15                     => p_segment15
      ,p_segment16                     => p_segment16
      ,p_segment17                     => p_segment17
      ,p_segment18                     => p_segment18
      ,p_segment19                     => p_segment19
      ,p_segment20                     => p_segment20
      ,p_segment21                     => p_segment21
      ,p_segment22                     => p_segment22
      ,p_segment23                     => p_segment23
      ,p_segment24                     => p_segment24
      ,p_segment25                     => p_segment25
      ,p_segment26                     => p_segment26
      ,p_segment27                     => p_segment27
      ,p_segment28                     => p_segment28
      ,p_segment29                     => p_segment29
      ,p_segment30                     => p_segment30
      ,p_concat_segments               => p_concat_segments
      ,p_job_id                        => p_job_id
      ,p_object_version_number         => p_object_version_number
      ,p_job_definition_id             => p_job_definition_id
      ,p_name                          => p_name
      );
      --
  hr_utility.set_location(' Leaving:'||l_proc, 7);
end create_no_job;

--
-- ----------------------------------------------------------------------------
-- |------------------------< update_no_job >-------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_no_job
  (p_validate                      in     boolean
  ,p_job_id                        in     number
  ,p_object_version_number         in out nocopy number
  ,p_date_from                     in     date
  ,p_comments                      in     varchar2
  ,p_date_to                       in     date
  ,p_benchmark_job_flag            in     varchar2
  ,p_benchmark_job_id              in     number
  ,p_emp_rights_flag               in     varchar2
  ,p_attribute_category            in     varchar2
  ,p_attribute1                    in     varchar2
  ,p_attribute2                    in     varchar2
  ,p_attribute3                    in     varchar2
  ,p_attribute4                    in     varchar2
  ,p_attribute5                    in     varchar2
  ,p_attribute6                    in     varchar2
  ,p_attribute7                    in     varchar2
  ,p_attribute8                    in     varchar2
  ,p_attribute9                    in     varchar2
  ,p_attribute10                   in     varchar2
  ,p_attribute11                   in     varchar2
  ,p_attribute12                   in     varchar2
  ,p_attribute13                   in     varchar2
  ,p_attribute14                   in     varchar2
  ,p_attribute15                   in     varchar2
  ,p_attribute16                   in     varchar2
  ,p_attribute17                   in     varchar2
  ,p_attribute18                   in     varchar2
  ,p_attribute19                   in     varchar2
  ,p_attribute20                   in     varchar2
  ,p_ssb_position_code             in     varchar2
  ,p_working_title                 in     varchar2
  ,p_segment1                      in     varchar2
  ,p_segment2                      in     varchar2
  ,p_segment3                      in     varchar2
  ,p_segment4                      in     varchar2
  ,p_segment5                      in     varchar2
  ,p_segment6                      in     varchar2
  ,p_segment7                      in     varchar2
  ,p_segment8                      in     varchar2
  ,p_segment9                      in     varchar2
  ,p_segment10                     in     varchar2
  ,p_segment11                     in     varchar2
  ,p_segment12                     in     varchar2
  ,p_segment13                     in     varchar2
  ,p_segment14                     in     varchar2
  ,p_segment15                     in     varchar2
  ,p_segment16                     in     varchar2
  ,p_segment17                     in     varchar2
  ,p_segment18                     in     varchar2
  ,p_segment19                     in     varchar2
  ,p_segment20                     in     varchar2
  ,p_segment21                     in     varchar2
  ,p_segment22                     in     varchar2
  ,p_segment23                     in     varchar2
  ,p_segment24                     in     varchar2
  ,p_segment25                     in     varchar2
  ,p_segment26                     in     varchar2
  ,p_segment27                     in     varchar2
  ,p_segment28                     in     varchar2
  ,p_segment29                     in     varchar2
  ,p_segment30                     in     varchar2
  ,p_job_definition_id               out nocopy  number
  ,p_name                            out nocopy  varchar2
  ,p_valid_grades_changed_warning    out nocopy  boolean
  ,p_effective_date                in      date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                 varchar2(72) := g_package||'update_no_job';
  l_legislation_code     varchar2(2);
  --
  cursor csr_bg is
    select legislation_code
    from per_business_groups pbg
    where pbg.business_group_id in (select pj.business_group_id
    				    from per_jobs_v pj
    				    where pj.job_id = p_job_id);
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Validation in addition to Row Handlers
  --
  -- Check that the specified business group is valid.
  --
  open csr_bg;
  fetch csr_bg
  into l_legislation_code;
  if csr_bg%notfound then
    close csr_bg;
    hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
    hr_utility.raise_error;
  end if;
  close csr_bg;
  --
  -- Check that the legislation of the specified business group is 'NO'.
  --
  if l_legislation_code <> 'NO' then
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','NO');
    hr_utility.raise_error;
  end if;

  hr_utility.set_location(l_proc, 6);
  --
  -- Call the person business process
  --

hr_job_api.update_job
  (
   p_validate			  => p_validate
  ,p_job_id                       => p_job_id
  ,p_object_version_number        => p_object_version_number
  ,p_date_from                    => p_date_from
  ,p_comments                     => p_comments
  ,p_date_to                      => p_date_to
  ,p_benchmark_job_flag           => p_benchmark_job_flag
  ,p_benchmark_job_id             => p_benchmark_job_id
  ,p_emp_rights_flag              => p_emp_rights_flag
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
  ,p_job_information_category     => 'NO'
  ,p_job_information1 	          => p_ssb_position_code
  ,p_job_information2 	          => p_working_title
  ,p_segment1         		  => p_segment1
  ,p_segment2         		  => p_segment2
  ,p_segment3         		  => p_segment3
  ,p_segment4        		  => p_segment4
  ,p_segment5         		  => p_segment5
  ,p_segment6         		  => p_segment6
  ,p_segment7         	 	  => p_segment7
  ,p_segment8         		  => p_segment8
  ,p_segment9        		  => p_segment9
  ,p_segment11       		  => p_segment10
  ,p_segment12       		  => p_segment12
  ,p_segment13       		  => p_segment13
  ,p_segment14       		  => p_segment14
  ,p_segment15       		  => p_segment15
  ,p_segment16       		  => p_segment16
  ,p_segment17       		  => p_segment17
  ,p_segment18       		  => p_segment18
  ,p_segment19       		  => p_segment19
  ,p_segment20       		  => p_segment20
  ,p_segment21       		  => p_segment21
  ,p_segment22       		  => p_segment22
  ,p_segment23       		  => p_segment23
  ,p_segment24       		  => p_segment24
  ,p_segment25       		  => p_segment25
  ,p_segment26       		  => p_segment26
  ,p_segment27       		  => p_segment27
  ,p_segment28        		  => p_segment28
  ,p_segment29        		  => p_segment29
  ,p_segment30        		  => p_segment30
  ,p_job_definition_id            => p_job_definition_id
  ,p_name                         => p_name
  ,p_valid_grades_changed_warning => p_valid_grades_changed_warning
  ,p_effective_date                => p_effective_date
  );
 --
  hr_utility.set_location(' Leaving:'||l_proc, 7);
end update_no_job;

--
end hr_no_job_api;

/
