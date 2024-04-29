--------------------------------------------------------
--  DDL for Package Body HR_PL_PREVIOUS_EMPLOYMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PL_PREVIOUS_EMPLOYMENT_API" as
/* $Header: pepempli.pkb 120.0 2005/05/31 13:27:48 appldev noship $ */

 -- Package Variables
   g_package   VARCHAR2(33);

-- ----------------------------------------------------------------------------
-- |-------------------------< create_pl_previous_employer>---------------------------|
-- ----------------------------------------------------------------------------

procedure create_pl_previous_employer
(
   p_effective_date               IN      date
  ,p_validate                     IN      boolean   default false
  ,p_business_group_id            IN      number
  ,p_person_id                    IN      number
  ,p_party_id                     IN      number    default null
  ,p_start_date                   IN      date      default null
  ,p_end_date                     IN      date      default null
  ,p_period_years                 IN      number    default null
  ,p_period_months                IN      number    default null
  ,p_period_days                  IN      number    default null
  ,p_employer_name                IN      varchar2
  ,p_employer_country             IN      varchar2  default null
  ,p_employer_address             IN      varchar2  default null
  ,p_employer_type                IN      varchar2  default null
  ,p_employer_subtype             IN      varchar2  default null
  ,p_description                  IN      varchar2  default null
  ,p_all_assignments              IN      varchar2  default 'N'
  ,p_pem_attribute_category       IN      varchar2  default null
  ,p_pem_attribute1               IN      varchar2  default null
  ,p_pem_attribute2               IN      varchar2  default null
  ,p_pem_attribute3               IN      varchar2  default null
  ,p_pem_attribute4               IN      varchar2  default null
  ,p_pem_attribute5               IN      varchar2  default null
  ,p_pem_attribute6               IN      varchar2  default null
  ,p_pem_attribute7               IN      varchar2  default null
  ,p_pem_attribute8               IN      varchar2  default null
  ,p_pem_attribute9               IN      varchar2  default null
  ,p_pem_attribute10              IN      varchar2  default null
  ,p_pem_attribute11              IN      varchar2  default null
  ,p_pem_attribute12              IN      varchar2  default null
  ,p_pem_attribute13              IN      varchar2  default null
  ,p_pem_attribute14              IN      varchar2  default null
  ,p_pem_attribute15              IN      varchar2  default null
  ,p_pem_attribute16              IN      varchar2  default null
  ,p_pem_attribute17              IN      varchar2  default null
  ,p_pem_attribute18              IN      varchar2  default null
  ,p_pem_attribute19              IN      varchar2  default null
  ,p_pem_attribute20              IN      varchar2  default null
  ,p_pem_attribute21              IN      varchar2  default null
  ,p_pem_attribute22              IN      varchar2  default null
  ,p_pem_attribute23              IN      varchar2  default null
  ,p_pem_attribute24              IN      varchar2  default null
  ,p_pem_attribute25              IN      varchar2  default null
  ,p_pem_attribute26              IN      varchar2  default null
  ,p_pem_attribute27              IN      varchar2  default null
  ,p_pem_attribute28              IN      varchar2  default null
  ,p_pem_attribute29              IN      varchar2  default null
  ,p_pem_attribute30              IN      varchar2  default null
  ,p_pem_information_category     IN      varchar2  default null
  ,Direction_Number               IN      varchar2  default null
  ,Telephone           		      IN      varchar2  default null
  ,Mobile           		      IN      varchar2  default null
  ,Fax         			          IN      varchar2  default null
  ,E_mail         		          IN      varchar2  default null
  ,Contact_Information            IN      varchar2  default null
  ,p_pem_information7             IN      varchar2  default null
  ,p_pem_information8             IN      varchar2  default null
  ,p_pem_information9             IN      varchar2  default null
  ,p_pem_information10            IN      varchar2  default null
  ,p_pem_information11            IN      varchar2  default null
  ,p_pem_information12            IN      varchar2  default null
  ,p_pem_information13            IN      varchar2  default null
  ,p_pem_information14            IN      varchar2  default null
  ,p_pem_information15            IN      varchar2  default null
  ,p_pem_information16            IN      varchar2  default null
  ,p_pem_information17            IN      varchar2  default null
  ,p_pem_information18            IN      varchar2  default null
  ,p_pem_information19            IN      varchar2  default null
  ,p_pem_information20            IN      varchar2  default null
  ,p_pem_information21            IN      varchar2  default null
  ,p_pem_information22            IN      varchar2  default null
  ,p_pem_information23            IN      varchar2  default null
  ,p_pem_information24            IN      varchar2  default null
  ,p_pem_information25            IN      varchar2  default null
  ,p_pem_information26            IN      varchar2  default null
  ,p_pem_information27            IN      varchar2  default null
  ,p_pem_information28            IN      varchar2  default null
  ,p_pem_information29            IN      varchar2  default null
  ,p_pem_information30            IN      varchar2  default null
  ,p_previous_employer_id         OUT NOCOPY     number
  ,p_object_version_number        OUT NOCOPY     number
) is

  -- Declare cursors and local variables
  --
   l_proc                 varchar2(72);
   l_legislation_code     varchar2(2);
  --
   cursor csr_bg is
    select legislation_code
    from per_business_groups pbg
    where pbg.business_group_id in (select pe.business_group_id
    from per_all_people_f pe
    where pe.PERSON_ID = p_person_id);

  l_period_years number;
  l_period_months number;
  l_period_days number;
  --
begin

   g_package := 'hr_pl_previous_employment_api.';
   l_proc    := g_package||'create_pl_previous_employer';
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
  -- Check that the legislation of the specified business group is 'PL'.
  --
  if l_legislation_code <> 'PL' then
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','PL');
    hr_utility.raise_error;
  end if;

    if p_period_years is null and p_period_months is null and p_period_days is null then
       hr_pl_utility.per_pl_calc_periods(p_start_date
                                        ,p_end_date
                                        ,l_period_years
                                        ,l_period_months
                                        ,l_period_days);
  Else
     l_period_years:=p_period_years;
     l_period_months:=p_period_months;
     l_period_days:=p_period_days;
  End if;

   hr_utility.set_location('Entering:'|| l_proc, 5);

  --
hr_previous_employment_api.create_previous_employer
(
   p_effective_date               =>	  p_effective_date
  ,p_validate                     =>      p_validate
  ,p_business_group_id            =>      p_business_group_id
  ,p_person_id                    =>      p_person_id
  ,p_party_id                     =>      p_party_id
  ,p_start_date                   =>      p_start_date
  ,p_end_date                     =>      p_end_date
  ,p_period_years                 =>      l_period_years
  ,p_period_months                =>      l_period_months
  ,p_period_days                  =>      l_period_days
  ,p_employer_name                =>      p_employer_name
  ,p_employer_country             =>      p_employer_country
  ,p_employer_address             =>      p_employer_address
  ,p_employer_type                =>      p_employer_type
  ,p_employer_subtype             =>      p_employer_subtype
  ,p_description                  =>      p_description
  ,p_all_assignments              =>      p_all_assignments
  ,p_pem_attribute_category       =>      p_pem_attribute_category
  ,p_pem_attribute1               =>      p_pem_attribute1
  ,p_pem_attribute2               =>      p_pem_attribute2
  ,p_pem_attribute3               =>      p_pem_attribute3
  ,p_pem_attribute4               =>      p_pem_attribute4
  ,p_pem_attribute5               =>      p_pem_attribute5
  ,p_pem_attribute6               =>      p_pem_attribute6
  ,p_pem_attribute7               =>      p_pem_attribute7
  ,p_pem_attribute8               =>      p_pem_attribute8
  ,p_pem_attribute9               =>      p_pem_attribute9
  ,p_pem_attribute10              =>      p_pem_attribute10
  ,p_pem_attribute11              =>      p_pem_attribute11
  ,p_pem_attribute12              =>      p_pem_attribute12
  ,p_pem_attribute13              =>      p_pem_attribute13
  ,p_pem_attribute14              =>      p_pem_attribute14
  ,p_pem_attribute15              =>      p_pem_attribute15
  ,p_pem_attribute16              =>      p_pem_attribute16
  ,p_pem_attribute17              =>      p_pem_attribute17
  ,p_pem_attribute18              =>      p_pem_attribute18
  ,p_pem_attribute19              =>      p_pem_attribute19
  ,p_pem_attribute20              =>      p_pem_attribute20
  ,p_pem_attribute21              =>      p_pem_attribute21
  ,p_pem_attribute22              =>      p_pem_attribute22
  ,p_pem_attribute23              =>      p_pem_attribute23
  ,p_pem_attribute24              =>      p_pem_attribute24
  ,p_pem_attribute25              =>      p_pem_attribute25
  ,p_pem_attribute26              =>      p_pem_attribute26
  ,p_pem_attribute27              =>      p_pem_attribute27
  ,p_pem_attribute28              =>      p_pem_attribute28
  ,p_pem_attribute29              =>      p_pem_attribute29
  ,p_pem_attribute30              =>      p_pem_attribute30
  ,p_pem_information_category     =>      'PL'
  ,p_pem_information1             =>      Direction_Number
  ,p_pem_information2             =>      Telephone
  ,p_pem_information3             =>      Mobile
  ,p_pem_information4             =>      Fax
  ,p_pem_information5             =>      E_mail
  ,p_pem_information6             =>      Contact_Information
  ,p_pem_information7             =>      p_pem_information7
  ,p_pem_information8             =>      p_pem_information8
  ,p_pem_information9             =>      p_pem_information9
  ,p_pem_information10            =>      p_pem_information10
  ,p_pem_information11            =>      p_pem_information11
  ,p_pem_information12            =>      p_pem_information12
  ,p_pem_information13            =>      p_pem_information13
  ,p_pem_information14            =>      p_pem_information14
  ,p_pem_information15            =>      p_pem_information15
  ,p_pem_information16            =>      p_pem_information16
  ,p_pem_information17            =>      p_pem_information17
  ,p_pem_information18            =>      p_pem_information18
  ,p_pem_information19            =>      p_pem_information19
  ,p_pem_information20            =>      p_pem_information20
  ,p_pem_information21            =>      p_pem_information21
  ,p_pem_information22            =>      p_pem_information22
  ,p_pem_information23            =>      p_pem_information23
  ,p_pem_information24            =>      p_pem_information24
  ,p_pem_information25            =>      p_pem_information25
  ,p_pem_information26            =>      p_pem_information26
  ,p_pem_information27            =>      p_pem_information27
  ,p_pem_information28            =>      p_pem_information28
  ,p_pem_information29            =>      p_pem_information29
  ,p_pem_information30            =>      p_pem_information30
  ,p_previous_employer_id         =>      p_previous_employer_id
  ,p_object_version_number        =>      p_object_version_number
);
end create_pl_previous_employer;


-- ----------------------------------------------------------------------------
-- |-------------------------< update_pl_previous_employer >---------------------------|
-- ----------------------------------------------------------------------------


procedure update_pl_previous_employer
(  p_effective_date             IN      date
  ,p_validate                   IN      boolean   default false
  ,p_previous_employer_id       IN      number
  ,p_start_date                 IN      date      default hr_api.g_date
  ,p_end_date                   IN      date      default hr_api.g_date
  ,p_period_years               IN      number    default hr_api.g_number
  ,p_period_months              IN      number    default hr_api.g_number
  ,p_period_days                IN      number    default hr_api.g_number
  ,p_employer_name              IN      varchar2  default hr_api.g_varchar2
  ,p_employer_country           IN      varchar2  default hr_api.g_varchar2
  ,p_employer_address           IN      varchar2  default hr_api.g_varchar2
  ,p_employer_type              IN      varchar2  default hr_api.g_varchar2
  ,p_employer_subtype           IN      varchar2  default hr_api.g_varchar2
  ,p_description                IN      varchar2  default hr_api.g_varchar2
  ,p_all_assignments            IN      varchar2  default 'N'
  ,p_pem_attribute_category     IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute1             IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute2             IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute3             IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute4             IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute5             IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute6             IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute7             IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute8             IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute9             IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute10            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute11            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute12            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute13            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute14            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute15            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute16            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute17            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute18            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute19            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute20            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute21            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute22            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute23            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute24            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute25            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute26            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute27            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute28            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute29            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_attribute30            IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information_category   IN      varchar2  default hr_api.g_varchar2
  ,Direction_Number             IN      varchar2  default hr_api.g_varchar2
  ,Telephone           		    IN      varchar2  default hr_api.g_varchar2
  ,Mobile           		    IN      varchar2  default hr_api.g_varchar2
  ,Fax          		        IN      varchar2  default hr_api.g_varchar2
  ,E_mail         		        IN      varchar2  default hr_api.g_varchar2
  ,Contact_Information          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information7           IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information8           IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information9           IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information10          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information11          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information12          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information13          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information14          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information15          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information16          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information17          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information18          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information19          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information20          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information21          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information22          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information23          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information24          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information25          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information26          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information27          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information28          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information29          IN      varchar2  default hr_api.g_varchar2
  ,p_pem_information30          IN      varchar2  default hr_api.g_varchar2
  ,p_object_version_number      IN 	OUT NOCOPY  number
  ) is

  -- Declare cursors and local variables
  --
  l_proc                 varchar2(72);
  l_legislation_code     varchar2(2);
  --
  cursor csr_bg is
    select legislation_code
    from per_business_groups pbg
    where pbg.business_group_id in (select pe.business_group_id
    from  per_previous_employers pe
    where pe.PREVIOUS_EMPLOYER_ID = p_previous_employer_id
   );

  l_period_years number;
  l_period_months number;
  l_period_days number;
  --
begin

   g_package := 'hr_pl_previous_employment_api.';
   l_proc    := g_package||'update_pl_previous_employer';

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
  -- Check that the legislation of the specified business group is 'PL'.
  --
  if l_legislation_code <> 'PL' then
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','PL');
    hr_utility.raise_error;
  end if;


    if p_period_years is null and p_period_months is null and p_period_days is null then
       hr_pl_utility.per_pl_calc_periods(p_start_date
                                        ,p_end_date
                                        ,l_period_years
                                        ,l_period_months
                                        ,l_period_days);
  Else
     l_period_years:=p_period_years;
     l_period_months:=p_period_months;
     l_period_days:=p_period_days;
  End if;

  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
hr_previous_employment_api.update_previous_employer
(
   p_effective_date             =>	p_effective_date
  ,p_validate                   =>	p_validate
  ,p_previous_employer_id       =>	p_previous_employer_id
  ,p_start_date                 =>	p_start_date
  ,p_end_date                   =>	p_end_date
  ,p_period_years               =>	l_period_years
  ,p_period_months              =>	l_period_months
  ,p_period_days                =>	l_period_days
  ,p_employer_name              =>	p_employer_name
  ,p_employer_country           =>	p_employer_country
  ,p_employer_address           =>	p_employer_address
  ,p_employer_type              =>	p_employer_type
  ,p_employer_subtype           =>	p_employer_subtype
  ,p_description                =>	p_description
  ,p_all_assignments            =>	p_all_assignments
  ,p_pem_attribute_category     =>	p_pem_attribute_category
  ,p_pem_attribute1             =>	p_pem_attribute1
  ,p_pem_attribute2             =>	p_pem_attribute2
  ,p_pem_attribute3             =>	p_pem_attribute3
  ,p_pem_attribute4             =>	p_pem_attribute4
  ,p_pem_attribute5             =>	p_pem_attribute5
  ,p_pem_attribute6             =>	p_pem_attribute6
  ,p_pem_attribute7             =>	p_pem_attribute7
  ,p_pem_attribute8             =>	p_pem_attribute8
  ,p_pem_attribute9             =>	p_pem_attribute9
  ,p_pem_attribute10            =>	p_pem_attribute10
  ,p_pem_attribute11            =>	p_pem_attribute11
  ,p_pem_attribute12            =>	p_pem_attribute12
  ,p_pem_attribute13            =>	p_pem_attribute13
  ,p_pem_attribute14            =>	p_pem_attribute14
  ,p_pem_attribute15            =>	p_pem_attribute15
  ,p_pem_attribute16            =>	p_pem_attribute16
  ,p_pem_attribute17            =>	p_pem_attribute17
  ,p_pem_attribute18            =>	p_pem_attribute18
  ,p_pem_attribute19            =>	p_pem_attribute19
  ,p_pem_attribute20            =>	p_pem_attribute20
  ,p_pem_attribute21            =>	p_pem_attribute21
  ,p_pem_attribute22            =>	p_pem_attribute22
  ,p_pem_attribute23            =>	p_pem_attribute23
  ,p_pem_attribute24            =>	p_pem_attribute24
  ,p_pem_attribute25            =>	p_pem_attribute25
  ,p_pem_attribute26            =>	p_pem_attribute26
  ,p_pem_attribute27            =>	p_pem_attribute27
  ,p_pem_attribute28            =>	p_pem_attribute28
  ,p_pem_attribute29            =>	p_pem_attribute29
  ,p_pem_attribute30            =>	p_pem_attribute30
  ,p_pem_information_category   =>	'PL'
  ,p_pem_information1           =>	Direction_Number
  ,p_pem_information2           =>	Telephone
  ,p_pem_information3           =>	Mobile
  ,p_pem_information4           =>	Fax
  ,p_pem_information5           =>	E_mail
  ,p_pem_information6           =>	Contact_Information
  ,p_pem_information7           =>	p_pem_information7
  ,p_pem_information8           =>	p_pem_information8
  ,p_pem_information9           =>	p_pem_information9
  ,p_pem_information10          =>	p_pem_information10
  ,p_pem_information11          =>	p_pem_information11
  ,p_pem_information12          =>	p_pem_information12
  ,p_pem_information13          =>	p_pem_information13
  ,p_pem_information14          =>	p_pem_information14
  ,p_pem_information15          =>	p_pem_information15
  ,p_pem_information16          =>	p_pem_information16
  ,p_pem_information17          =>	p_pem_information17
  ,p_pem_information18          =>	p_pem_information18
  ,p_pem_information19          =>	p_pem_information19
  ,p_pem_information20          =>	p_pem_information20
  ,p_pem_information21          =>	p_pem_information21
  ,p_pem_information22          =>	p_pem_information22
  ,p_pem_information23          =>	p_pem_information23
  ,p_pem_information24          =>	p_pem_information24
  ,p_pem_information25          =>	p_pem_information25
  ,p_pem_information26          =>	p_pem_information26
  ,p_pem_information27          =>	p_pem_information27
  ,p_pem_information28          =>	p_pem_information28
  ,p_pem_information29          =>	p_pem_information29
  ,p_pem_information30          =>	p_pem_information30
  ,p_object_version_number      =>	p_object_version_number
);

end update_pl_previous_employer;
-- ----------------------------------------------------------------------------
-- |-------------------------< create_pl_previous_employer>---------------------------|
-- ----------------------------------------------------------------------------

procedure create_pl_previous_job
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
  ,p_pjo_information_category       in     varchar2 default null
  ,Type_Of_Service                  in     varchar2
  ,p_pjo_information2               in     varchar2 default null
  ,p_pjo_information3               in     varchar2 default null
  ,p_pjo_information4               in     varchar2 default null
  ,p_pjo_information5               in     varchar2 default null
  ,p_pjo_information6               in     varchar2 default null
  ,p_pjo_information7               in     varchar2 default null
  ,p_pjo_information8               in     varchar2 default null
  ,p_pjo_information9               in     varchar2 default null
  ,p_pjo_information10              in     varchar2 default null
  ,p_pjo_information11              in     varchar2 default null
  ,p_pjo_information12              in     varchar2 default null
  ,p_pjo_information13              in     varchar2 default null
  ,p_pjo_information14              in     varchar2 default null
  ,p_pjo_information15              in     varchar2 default null
  ,p_pjo_information16              in     varchar2 default null
  ,p_pjo_information17              in     varchar2 default null
  ,p_pjo_information18              in     varchar2 default null
  ,p_pjo_information19              in     varchar2 default null
  ,p_pjo_information20              in     varchar2 default null
  ,p_pjo_information21              in     varchar2 default null
  ,p_pjo_information22              in     varchar2 default null
  ,p_pjo_information23              in     varchar2 default null
  ,p_pjo_information24              in     varchar2 default null
  ,p_pjo_information25              in     varchar2 default null
  ,p_pjo_information26              in     varchar2 default null
  ,p_pjo_information27              in     varchar2 default null
  ,p_pjo_information28              in     varchar2 default null
  ,p_pjo_information29              in     varchar2 default null
  ,p_pjo_information30              in     varchar2 default null
  ,p_previous_job_id                out nocopy    number
  ,p_object_version_number          out nocopy    number
) is

  -- Declare cursors and local variables
  --
   l_proc                 varchar2(72);
   l_legislation_code     per_business_groups.legislation_code%type;
  --
   cursor csr_bg is
    select legislation_code
    from per_business_groups pbg
    where pbg.business_group_id
    in (select BUSINESS_GROUP_ID from PER_PREVIOUS_EMPLOYERS where PREVIOUS_EMPLOYER_ID =
 p_previous_employer_id);
  l_period_years number;
  l_period_months number;
  l_period_days number;
  --
begin

   g_package :='hr_pl_previous_employment_api.';
   l_proc    := g_package||'create_pl_previous_job';
  --
  -- Validation in addition to Row Handlers
  --
  -- Check that the specified business group is valid.
  --
  open csr_bg;
  fetch csr_bg into l_legislation_code;
  if csr_bg%notfound then
    close csr_bg;
    hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
    hr_utility.raise_error;
  end if;
  close csr_bg;
  --
  -- Check that the legislation of the specified business group is 'PL'.
  --
  if l_legislation_code <> 'PL' then
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','PL');
    hr_utility.raise_error;
  end if;

  if p_period_years is null and p_period_months is null and p_period_days is null then
       hr_pl_utility.per_pl_calc_periods(p_start_date
                                        ,p_end_date
                                        ,l_period_years
                                        ,l_period_months
                                        ,l_period_days);
  Else
     l_period_years:=p_period_years;
     l_period_months:=p_period_months;
     l_period_days:=p_period_days;
  End if;

     hr_utility.set_location('Entering:'|| l_proc, 5);
  --
hr_previous_employment_api.create_previous_job
	(p_effective_date => p_effective_date
	,p_validate => p_validate
  ,p_previous_employer_id        =>p_previous_employer_id
  ,p_start_date                  =>p_start_date
  ,p_end_date                    =>p_end_date
  ,p_period_years                =>l_period_years
  ,p_period_months               =>l_period_months
  ,p_period_days                 =>l_period_days
  ,p_job_name                    =>p_job_name
  ,p_employment_category         =>p_employment_category
  ,p_description                 =>p_description
  ,p_all_assignments             =>p_all_assignments
  ,p_pjo_attribute_category      =>p_pjo_attribute_category
  ,p_pjo_attribute1              =>p_pjo_attribute1
  ,p_pjo_attribute2              =>p_pjo_attribute2
  ,p_pjo_attribute3              =>p_pjo_attribute3
  ,p_pjo_attribute4              =>p_pjo_attribute4
  ,p_pjo_attribute5              =>p_pjo_attribute5
  ,p_pjo_attribute6              =>p_pjo_attribute6
  ,p_pjo_attribute7              =>p_pjo_attribute7
  ,p_pjo_attribute8              =>p_pjo_attribute8
  ,p_pjo_attribute9              =>p_pjo_attribute9
  ,p_pjo_attribute10             =>p_pjo_attribute10
  ,p_pjo_attribute11             =>p_pjo_attribute11
  ,p_pjo_attribute12             =>p_pjo_attribute12
  ,p_pjo_attribute13             =>p_pjo_attribute13
  ,p_pjo_attribute14             =>p_pjo_attribute14
  ,p_pjo_attribute15             =>p_pjo_attribute15
  ,p_pjo_attribute16             =>p_pjo_attribute16
  ,p_pjo_attribute17             =>p_pjo_attribute17
  ,p_pjo_attribute18             =>p_pjo_attribute18
  ,p_pjo_attribute19             =>p_pjo_attribute19
  ,p_pjo_attribute20             =>p_pjo_attribute20
  ,p_pjo_attribute21             =>p_pjo_attribute21
  ,p_pjo_attribute22             =>p_pjo_attribute22
  ,p_pjo_attribute23             =>p_pjo_attribute23
  ,p_pjo_attribute24             =>p_pjo_attribute24
  ,p_pjo_attribute25             =>p_pjo_attribute25
  ,p_pjo_attribute26             =>p_pjo_attribute26
  ,p_pjo_attribute27             =>p_pjo_attribute27
  ,p_pjo_attribute28             =>p_pjo_attribute28
  ,p_pjo_attribute29             =>p_pjo_attribute29
  ,p_pjo_attribute30             =>p_pjo_attribute30
  ,p_pjo_information_category    =>'PL'
  ,p_pjo_information1            =>Type_Of_Service
  ,p_pjo_information2            =>p_pjo_information2
  ,p_pjo_information3            =>p_pjo_information3
  ,p_pjo_information4            =>p_pjo_information4
  ,p_pjo_information5            =>p_pjo_information5
  ,p_pjo_information6            =>p_pjo_information6
  ,p_pjo_information7            =>p_pjo_information7
  ,p_pjo_information8            =>p_pjo_information8
  ,p_pjo_information9            =>p_pjo_information9
  ,p_pjo_information10           =>p_pjo_information10
  ,p_pjo_information11           =>p_pjo_information11
  ,p_pjo_information12           =>p_pjo_information12
  ,p_pjo_information13           =>p_pjo_information13
  ,p_pjo_information14           =>p_pjo_information14
  ,p_pjo_information15           =>p_pjo_information15
  ,p_pjo_information16           =>p_pjo_information16
  ,p_pjo_information17           =>p_pjo_information17
  ,p_pjo_information18           =>p_pjo_information18
  ,p_pjo_information19           =>p_pjo_information19
  ,p_pjo_information20           =>p_pjo_information20
  ,p_pjo_information21           =>p_pjo_information21
  ,p_pjo_information22           =>p_pjo_information22
  ,p_pjo_information23           =>p_pjo_information23
  ,p_pjo_information24           =>p_pjo_information24
  ,p_pjo_information25           =>p_pjo_information25
  ,p_pjo_information26           =>p_pjo_information26
  ,p_pjo_information27           =>p_pjo_information27
  ,p_pjo_information28           =>p_pjo_information28
  ,p_pjo_information29           =>p_pjo_information29
  ,p_pjo_information30           =>p_pjo_information30
  ,p_previous_job_id             =>p_previous_job_id
  ,p_object_version_number       =>p_object_version_number
  );
end create_pl_previous_job;


-- ----------------------------------------------------------------------------
-- |-------------------------< update_pl_previous_job >---------------------------|
-- ----------------------------------------------------------------------------


procedure update_pl_previous_job
(  p_effective_date               in     date
  ,p_validate                     in     boolean   default false
  ,p_previous_job_id              in     number
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_end_date                     in     date      default hr_api.g_date
  ,p_period_years                 in     number    default hr_api.g_number
  ,p_period_months                in     number    default hr_api.g_number
  ,p_period_days                  in     number    default hr_api.g_number
  ,p_job_name                     in     varchar2  default hr_api.g_varchar2
  ,p_employment_category          in     varchar2  default hr_api.g_varchar2
  ,p_description                  in     varchar2  default hr_api.g_varchar2
  ,p_all_assignments              in     varchar2  default 'N'
  ,p_pjo_attribute_category       in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute1               in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute2               in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute3               in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute4               in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute5               in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute6               in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute7               in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute8               in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute9               in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute10              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute11              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute12              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute13              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute14              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute15              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute16              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute17              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute18              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute19              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute20              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute21              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute22              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute23              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute24              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute25              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute26              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute27              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute28              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute29              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_attribute30              in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information_category     in     varchar2  default hr_api.g_varchar2
  ,Type_Of_Service                in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information2             in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information3             in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information4             in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information5             in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information6             in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information7             in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information8             in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information9             in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information10            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information11            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information12            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information13            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information14            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information15            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information16            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information17            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information18            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information19            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information20            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information21            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information22            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information23            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information24            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information25            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information26            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information27            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information28            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information29            in     varchar2  default hr_api.g_varchar2
  ,p_pjo_information30            in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
) is

  -- Declare cursors and local variables
  --
  l_proc                 varchar2(72);
  l_legislation_code     varchar2(2);
  --
  cursor csr_bg is
    select legislation_code
    from per_business_groups pbg
    where pbg.business_group_id in (select BUSINESS_GROUP_ID from PER_PREVIOUS_JOBS_V
pjb,PER_PREVIOUS_EMPLOYERS_V pem
      where  pjb.PREVIOUS_EMPLOYER_ID=pem.PREVIOUS_EMPLOYER_ID
       and pjb.PREVIOUS_JOB_ID = p_previous_job_id);

  l_period_years number;
  l_period_months number;
  l_period_days number;
--
begin

   g_package := 'hr_pl_previous_employment_api.';
   l_proc    := g_package||'update_pl_previous_job';

  --
  -- Validation in addition to Row Handlers
  --
  -- Check that the specified business group is valid.
  --
  open csr_bg;

  fetch csr_bg into l_legislation_code;

  if csr_bg%notfound then
    close csr_bg;
    hr_utility.set_message(801, 'HR_7208_API_BUS_GRP_INVALID');
    hr_utility.raise_error;
  end if;
  close csr_bg;
  --
  -- Check that the legislation of the specified business group is 'PL'.
  --
  if l_legislation_code <> 'PL' then
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','PL');
    hr_utility.raise_error;
  end if;

  if p_period_years is null and p_period_months is null and p_period_days is null then
       hr_pl_utility.per_pl_calc_periods(p_start_date
                                        ,p_end_date
                                        ,l_period_years
                                        ,l_period_months
                                        ,l_period_days);
  Else
     l_period_years:=p_period_years;
     l_period_months:=p_period_months;
     l_period_days:=p_period_days;
  End if;

  hr_utility.set_location('Entering:'|| l_proc, 5);
 --
hr_previous_employment_api.update_previous_job
  (p_effective_date        =>p_effective_date
  ,p_validate              =>p_validate
  ,p_previous_job_id       =>p_previous_job_id
  ,p_start_date            =>p_start_date
  ,p_end_date              =>p_end_date
  ,p_period_years          =>l_period_years
  ,p_period_months         =>l_period_months
  ,p_period_days           =>l_period_days
  ,p_job_name              =>p_job_name
  ,p_employment_category   =>p_employment_category
  ,p_description           =>p_description
  ,p_all_assignments       =>p_all_assignments
  ,p_pjo_attribute_category=>p_pjo_attribute_category
  ,p_pjo_attribute1        =>p_pjo_attribute1
  ,p_pjo_attribute2        =>p_pjo_attribute2
  ,p_pjo_attribute3        =>p_pjo_attribute3
  ,p_pjo_attribute4        =>p_pjo_attribute4
  ,p_pjo_attribute5        =>p_pjo_attribute5
  ,p_pjo_attribute6        =>p_pjo_attribute6
  ,p_pjo_attribute7        =>p_pjo_attribute7
  ,p_pjo_attribute8        =>p_pjo_attribute8
  ,p_pjo_attribute9        =>p_pjo_attribute9
  ,p_pjo_attribute10       =>p_pjo_attribute10
  ,p_pjo_attribute11       =>p_pjo_attribute11
  ,p_pjo_attribute12       =>p_pjo_attribute12
  ,p_pjo_attribute13       =>p_pjo_attribute13
  ,p_pjo_attribute14       =>p_pjo_attribute14
  ,p_pjo_attribute15       =>p_pjo_attribute15
  ,p_pjo_attribute16       =>p_pjo_attribute16
  ,p_pjo_attribute17       =>p_pjo_attribute17
  ,p_pjo_attribute18       =>p_pjo_attribute18
  ,p_pjo_attribute19       =>p_pjo_attribute19
  ,p_pjo_attribute20       =>p_pjo_attribute20
  ,p_pjo_attribute21       =>p_pjo_attribute21
  ,p_pjo_attribute22       =>p_pjo_attribute22
  ,p_pjo_attribute23       =>p_pjo_attribute23
  ,p_pjo_attribute24       =>p_pjo_attribute24
  ,p_pjo_attribute25       =>p_pjo_attribute25
  ,p_pjo_attribute26       =>p_pjo_attribute26
  ,p_pjo_attribute27       =>p_pjo_attribute27
  ,p_pjo_attribute28       =>p_pjo_attribute28
  ,p_pjo_attribute29       =>p_pjo_attribute29
  ,p_pjo_attribute30       =>p_pjo_attribute30
  ,p_pjo_information_category =>'PL'
  ,p_pjo_information1      =>Type_Of_Service
  ,p_pjo_information2      =>p_pjo_information2
  ,p_pjo_information3      =>p_pjo_information3
  ,p_pjo_information4      =>p_pjo_information4
  ,p_pjo_information5      =>p_pjo_information5
  ,p_pjo_information6      =>p_pjo_information6
  ,p_pjo_information7      =>p_pjo_information7
  ,p_pjo_information8      =>p_pjo_information8
  ,p_pjo_information9      =>p_pjo_information9
  ,p_pjo_information10     =>p_pjo_information10
  ,p_pjo_information11     =>p_pjo_information11
  ,p_pjo_information12     =>p_pjo_information12
  ,p_pjo_information13     =>p_pjo_information13
  ,p_pjo_information14     =>p_pjo_information14
  ,p_pjo_information15     =>p_pjo_information15
  ,p_pjo_information16     =>p_pjo_information16
  ,p_pjo_information17     =>p_pjo_information17
  ,p_pjo_information18     =>p_pjo_information18
  ,p_pjo_information19     =>p_pjo_information19
  ,p_pjo_information20     =>p_pjo_information20
  ,p_pjo_information21     =>p_pjo_information21
  ,p_pjo_information22     =>p_pjo_information22
  ,p_pjo_information23     =>p_pjo_information23
  ,p_pjo_information24     =>p_pjo_information24
  ,p_pjo_information25     =>p_pjo_information25
  ,p_pjo_information26     =>p_pjo_information26
  ,p_pjo_information27     =>p_pjo_information27
  ,p_pjo_information28     =>p_pjo_information28
  ,p_pjo_information29     =>p_pjo_information29
  ,p_pjo_information30     =>p_pjo_information30
  ,p_object_version_number =>p_object_version_number
);

end update_pl_previous_job;

End hr_pl_previous_employment_api;

/
