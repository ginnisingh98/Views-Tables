--------------------------------------------------------
--  DDL for Package Body HR_FI_PREVIOUS_EMPLOYMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_FI_PREVIOUS_EMPLOYMENT_API" as
/* $Header: pepemfii.pkb 120.0 2005/05/31 13:25:51 appldev noship $ */

 -- Package Variables
   g_package   VARCHAR2(33) := 'hr_fi_previous_employment_api.';
   g_debug boolean := hr_utility.debug_enabled;

procedure create_fi_previous_job
(  p_effective_date                 in     date
  ,p_validate                       in     boolean  default false
  ,p_previous_employer_id           in     number
  ,p_start_date                     in     date     default null
  ,p_end_date                       in     date     default null
  ,p_period_years                   in     number   default null
  ,p_period_months                  in     number   default null
  ,p_period_days                    in     number   default null
  ,p_job_name                       in     varchar2 default null
  ,p_employment_category            in     varchar2 default null
  ,p_description                    in     varchar2 default null
  ,p_all_assignments                in     varchar2 default 'N'
  ,p_pjo_attribute_category         in     varchar2 default null
  ,p_pjo_attribute1                 in     varchar2 default null
  ,p_pjo_attribute2                 in     varchar2 default null
  ,p_pjo_attribute3                 in     varchar2 default null
  ,p_pjo_attribute4                 in     varchar2 default null
  ,p_pjo_attribute5                 in     varchar2 default null
  ,p_pjo_attribute6                 in     varchar2 default null
  ,p_pjo_attribute7                 in     varchar2 default null
  ,p_pjo_attribute8                 in     varchar2 default null
  ,p_pjo_attribute9                 in     varchar2 default null
  ,p_pjo_attribute10                in     varchar2 default null
  ,p_pjo_attribute11                in     varchar2 default null
  ,p_pjo_attribute12                in     varchar2 default null
  ,p_pjo_attribute13                in     varchar2 default null
  ,p_pjo_attribute14                in     varchar2 default null
  ,p_pjo_attribute15                in     varchar2 default null
  ,p_pjo_attribute16                in     varchar2 default null
  ,p_pjo_attribute17                in     varchar2 default null
  ,p_pjo_attribute18                in     varchar2 default null
  ,p_pjo_attribute19                in     varchar2 default null
  ,p_pjo_attribute20                in     varchar2 default null
  ,p_pjo_attribute21                in     varchar2 default null
  ,p_pjo_attribute22                in     varchar2 default null
  ,p_pjo_attribute23                in     varchar2 default null
  ,p_pjo_attribute24                in     varchar2 default null
  ,p_pjo_attribute25                in     varchar2 default null
  ,p_pjo_attribute26                in     varchar2 default null
  ,p_pjo_attribute27                in     varchar2 default null
  ,p_pjo_attribute28                in     varchar2 default null
  ,p_pjo_attribute29                in     varchar2 default null
  ,p_pjo_attribute30                in     varchar2 default null
  ,p_job_exp_classification  	    in     varchar2 default null
  ,p_previous_job_id                out nocopy    number
  ,p_object_version_number          out nocopy    number
  ) is


  -- Declare cursors and local variables
  --
  l_proc                 varchar2(72) := g_package||'create_fi_previous_job';
  l_legislation_code     varchar2(2);
  --
  cursor csr_bg is
		select legislation_code
		from per_business_groups
		where business_group_id in
					(
					select business_group_id
					from per_previous_employers
					where previous_employer_id = p_previous_employer_id
					);
  --
begin
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
  -- Check that the legislation of the specified business group is 'FI'.
  --
  if l_legislation_code <> 'FI' then
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','FI');
    hr_utility.raise_error;
  end if;


  --
  -- Call the business process

  -- Create the previous Job record using the create_previous_job
  --
hr_previous_employment_api.create_previous_job
(      p_effective_date                 =>     p_effective_date
      ,p_previous_job_id                =>     p_previous_job_id
      ,p_previous_employer_id           =>     p_previous_employer_id
      ,p_start_date                     =>     p_start_date
      ,p_end_date                       =>     p_end_date
      ,p_period_years                   =>     p_period_years
      ,p_period_months                  =>     p_period_months
      ,p_period_days                    =>     p_period_days
      ,p_job_name                       =>     p_job_name
      ,p_employment_category            =>     p_employment_category
      ,p_description                    =>     p_description
      ,p_all_assignments                =>     p_all_assignments
      ,p_pjo_attribute_category         =>     p_pjo_attribute_category
      ,p_pjo_attribute1                 =>     p_pjo_attribute1
      ,p_pjo_attribute2                 =>     p_pjo_attribute2
      ,p_pjo_attribute3                 =>     p_pjo_attribute3
      ,p_pjo_attribute4                 =>     p_pjo_attribute4
      ,p_pjo_attribute5                 =>     p_pjo_attribute5
      ,p_pjo_attribute6                 =>     p_pjo_attribute6
      ,p_pjo_attribute7                 =>     p_pjo_attribute7
      ,p_pjo_attribute8                 =>     p_pjo_attribute8
      ,p_pjo_attribute9                 =>     p_pjo_attribute9
      ,p_pjo_attribute10                =>     p_pjo_attribute10
      ,p_pjo_attribute11                =>     p_pjo_attribute11
      ,p_pjo_attribute12                =>     p_pjo_attribute12
      ,p_pjo_attribute13                =>     p_pjo_attribute13
      ,p_pjo_attribute14                =>     p_pjo_attribute14
      ,p_pjo_attribute15                =>     p_pjo_attribute15
      ,p_pjo_attribute16                =>     p_pjo_attribute16
      ,p_pjo_attribute17                =>     p_pjo_attribute17
      ,p_pjo_attribute18                =>     p_pjo_attribute18
      ,p_pjo_attribute19                =>     p_pjo_attribute19
      ,p_pjo_attribute20                =>     p_pjo_attribute20
      ,p_pjo_attribute21                =>     p_pjo_attribute21
      ,p_pjo_attribute22                =>     p_pjo_attribute22
      ,p_pjo_attribute23                =>     p_pjo_attribute23
      ,p_pjo_attribute24                =>     p_pjo_attribute24
      ,p_pjo_attribute25                =>     p_pjo_attribute25
      ,p_pjo_attribute26                =>     p_pjo_attribute26
      ,p_pjo_attribute27                =>     p_pjo_attribute27
      ,p_pjo_attribute28                =>     p_pjo_attribute28
      ,p_pjo_attribute29                =>     p_pjo_attribute29
      ,p_pjo_attribute30                =>     p_pjo_attribute30
      ,p_pjo_information_category       =>     'FI'
      ,p_pjo_information1               =>     p_job_exp_classification
      ,p_object_version_number          =>     p_object_version_number
      );
      --
      if g_debug then
	 hr_utility.set_location(' Leaving:'||l_proc, 40);
	end if;

END ;
--
-- -----------------------------------------------------------------------
-- |-------------------------< update_fi_previous_job >---------------------|
-- -----------------------------------------------------------------------
--
procedure update_fi_previous_job
  (p_effective_date               in     date
  ,p_validate                     in     boolean   default false
  ,p_previous_job_id              in     number
  ,p_start_date                   in     date      default null
  ,p_end_date                     in     date      default null
  ,p_period_years                 in     number    default null
  ,p_period_months                in     number    default null
  ,p_period_days                  in     number    default null
  ,p_job_name                     in     varchar2  default null
  ,p_employment_category          in     varchar2  default null
  ,p_description                  in     varchar2  default null
  ,p_all_assignments              in     varchar2  default 'N'
  ,p_pjo_attribute_category       in     varchar2  default null
  ,p_pjo_attribute1               in     varchar2  default null
  ,p_pjo_attribute2               in     varchar2  default null
  ,p_pjo_attribute3               in     varchar2  default null
  ,p_pjo_attribute4               in     varchar2  default null
  ,p_pjo_attribute5               in     varchar2  default null
  ,p_pjo_attribute6               in     varchar2  default null
  ,p_pjo_attribute7               in     varchar2  default null
  ,p_pjo_attribute8               in     varchar2  default null
  ,p_pjo_attribute9               in     varchar2  default null
  ,p_pjo_attribute10              in     varchar2  default null
  ,p_pjo_attribute11              in     varchar2  default null
  ,p_pjo_attribute12              in     varchar2  default null
  ,p_pjo_attribute13              in     varchar2  default null
  ,p_pjo_attribute14              in     varchar2  default null
  ,p_pjo_attribute15              in     varchar2  default null
  ,p_pjo_attribute16              in     varchar2  default null
  ,p_pjo_attribute17              in     varchar2  default null
  ,p_pjo_attribute18              in     varchar2  default null
  ,p_pjo_attribute19              in     varchar2  default null
  ,p_pjo_attribute20              in     varchar2  default null
  ,p_pjo_attribute21              in     varchar2  default null
  ,p_pjo_attribute22              in     varchar2  default null
  ,p_pjo_attribute23              in     varchar2  default null
  ,p_pjo_attribute24              in     varchar2  default null
  ,p_pjo_attribute25              in     varchar2  default null
  ,p_pjo_attribute26              in     varchar2  default null
  ,p_pjo_attribute27              in     varchar2  default null
  ,p_pjo_attribute28              in     varchar2  default null
  ,p_pjo_attribute29              in     varchar2  default null
  ,p_pjo_attribute30              in     varchar2  default null
  ,p_job_exp_classification 	  in     varchar2  default null
  ,p_object_version_number        in out nocopy number
  ) is

  --
  -- Declare cursors and local variables
  --
  l_proc                 varchar2(72) := g_package||'update_fi_previous_job';
  l_legislation_code     varchar2(2);
  --
  cursor csr_bg is
    select legislation_code
    from per_business_groups pbg
    where pbg.business_group_id in (select pe.business_group_id
from per_previous_jobs pj , per_previous_employers pe
where pj.PREVIOUS_EMPLOYER_ID = pe.PREVIOUS_EMPLOYER_ID
and pj.PREVIOUS_JOB_ID = p_previous_job_id
);
  --
begin
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
  -- Check that the legislation of the specified business group is 'FI'.
  --
  if l_legislation_code <> 'FI' then
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','FI');
    hr_utility.raise_error;
  end if;


  --
  -- Call the business process
  --
  hr_previous_employment_api.update_previous_job
  (p_effective_date                 =>     p_effective_date
      ,p_previous_job_id                =>     p_previous_job_id
      ,p_start_date                     =>     p_start_date
      ,p_end_date                       =>     p_end_date
      ,p_period_years                   =>     p_period_years
      ,p_period_months                  =>     p_period_months
      ,p_period_days                    =>     p_period_days
      ,p_job_name                       =>     p_job_name
      ,p_employment_category            =>     p_employment_category
      ,p_description                    =>     p_description
      ,p_all_assignments                =>     p_all_assignments
      ,p_pjo_attribute_category         =>     p_pjo_attribute_category
      ,p_pjo_attribute1                 =>     p_pjo_attribute1
      ,p_pjo_attribute2                 =>     p_pjo_attribute2
      ,p_pjo_attribute3                 =>     p_pjo_attribute3
      ,p_pjo_attribute4                 =>     p_pjo_attribute4
      ,p_pjo_attribute5                 =>     p_pjo_attribute5
      ,p_pjo_attribute6                 =>     p_pjo_attribute6
      ,p_pjo_attribute7                 =>     p_pjo_attribute7
      ,p_pjo_attribute8                 =>     p_pjo_attribute8
      ,p_pjo_attribute9                 =>     p_pjo_attribute9
      ,p_pjo_attribute10                =>     p_pjo_attribute10
      ,p_pjo_attribute11                =>     p_pjo_attribute11
      ,p_pjo_attribute12                =>     p_pjo_attribute12
      ,p_pjo_attribute13                =>     p_pjo_attribute13
      ,p_pjo_attribute14                =>     p_pjo_attribute14
      ,p_pjo_attribute15                =>     p_pjo_attribute15
      ,p_pjo_attribute16                =>     p_pjo_attribute16
      ,p_pjo_attribute17                =>     p_pjo_attribute17
      ,p_pjo_attribute18                =>     p_pjo_attribute18
      ,p_pjo_attribute19                =>     p_pjo_attribute19
      ,p_pjo_attribute20                =>     p_pjo_attribute20
      ,p_pjo_attribute21                =>     p_pjo_attribute21
      ,p_pjo_attribute22                =>     p_pjo_attribute22
      ,p_pjo_attribute23                =>     p_pjo_attribute23
      ,p_pjo_attribute24                =>     p_pjo_attribute24
      ,p_pjo_attribute25                =>     p_pjo_attribute25
      ,p_pjo_attribute26                =>     p_pjo_attribute26
      ,p_pjo_attribute27                =>     p_pjo_attribute27
      ,p_pjo_attribute28                =>     p_pjo_attribute28
      ,p_pjo_attribute29                =>     p_pjo_attribute29
      ,p_pjo_attribute30                =>     p_pjo_attribute30
      ,p_pjo_information_category       =>     'FI'
      ,p_pjo_information1               =>     p_job_exp_classification
      ,p_object_version_number          =>     p_object_version_number
      );

      if g_debug then
	  hr_utility.set_location(' Leaving:'||l_proc, 40);
	end if;
end update_fi_previous_job;

--
end hr_fi_previous_employment_api;

/
