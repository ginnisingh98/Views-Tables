--------------------------------------------------------
--  DDL for Package Body HR_AE_PREVIOUS_EMPLOYMENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_AE_PREVIOUS_EMPLOYMENT_API" as
/* $Header: pepemaei.pkb 120.0 2005/06/03 05:07:23 appldev noship $ */

   -- Package Variables
   g_package   VARCHAR2(33) := 'hr_ae_previous_employment_api.';
   g_debug boolean := hr_utility.debug_enabled;

procedure create_ae_previous_employer
(  p_effective_date               IN      date
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
  ,p_termination_reason           IN      varchar2  default null
  ,p_previous_employer_id         OUT NOCOPY     number
  ,p_object_version_number        OUT NOCOPY     number
  ) is

  --
  -- Declare cursors and local variables
  --

  l_proc                 varchar2(72) ;
  l_effective_date       date;
  l_legislation_code     per_business_groups.legislation_code%type;
  l_discard_varchar2     varchar2(30);
  --

    cursor check_legislation
    (c_person_id      per_people_f.person_id%TYPE,
     c_effective_date date
    )
  is
    select bgp.legislation_code
    from per_people_f per,
         per_business_groups bgp
    where per.business_group_id = bgp.business_group_id
    and   per.person_id     = c_person_id
    and   c_effective_date
      between per.effective_start_date and per.effective_end_date;
  --
begin

 l_proc :=  g_package||'create_ae_previous_employer';
 if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 5);
 end if;
  --
  -- Initialise local variables
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Validation in addition to Row Handlers
  --
  -- Check that the person exists.
  --
  open check_legislation(p_person_id, l_effective_date);
  fetch check_legislation into l_legislation_code;
  if check_legislation%notfound then
    close check_legislation;
    hr_utility.set_message(801,'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  end if;
  close check_legislation;
 if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  -- Check that the legislation of the specified business group is 'AE'.
  --
  if l_legislation_code <> 'AE' then
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','AE');
    hr_utility.raise_error;
  end if;
 if g_debug then
  hr_utility.set_location(l_proc, 30);
 end if;
  --
  -- Create the previous employer record using the create_previous_employer
  --
  hr_previous_employment_api.create_previous_employer
(  p_effective_date               =>      l_effective_date
  ,p_validate                     =>      p_validate
  ,p_business_group_id            =>      p_business_group_id
  ,p_person_id                    =>      p_person_id
  ,p_party_id                     =>      p_party_id
  ,p_start_date                   =>      p_start_date
  ,p_end_date                     =>      p_end_date
  ,p_period_years                 =>      p_period_years
  ,p_period_months                =>      p_period_months
  ,p_period_days                  =>      p_period_days
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
  ,p_pem_information_category     =>      'AE'
  ,p_pem_information1             =>      p_termination_reason
  ,p_previous_employer_id         =>      p_previous_employer_id
  ,p_object_version_number        =>      p_object_version_number
  );

  --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 40);
 end if;
  --
end create_ae_previous_employer;
--------------------------------------------------------------------------------- -

procedure update_ae_previous_employer
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
  ,p_termination_reason         IN      varchar2  default hr_api.g_varchar2
  ,p_object_version_number      IN OUT NOCOPY  number
  ) is

  --
  -- Declare cursors and local variables
  --

  l_proc                 varchar2(72) ;
  l_effective_date       date;
  l_legislation_code     per_business_groups.legislation_code%type;
  l_discard_varchar2     varchar2(30);
  --

    cursor check_legislation
    (c_previous_employer_id      per_previous_employers.previous_employer_id%TYPE,
     c_effective_date date
    )
  is
    select bgp.legislation_code
    from per_people_f per,
         per_business_groups bgp,
         per_previous_employers   pem
    where per.business_group_id = bgp.business_group_id
    and   per.person_id     =  pem.person_id
    and   pem.previous_employer_id = c_previous_employer_id
    and   c_effective_date
      between per.effective_start_date and per.effective_end_date;
  --
begin

 l_proc :=  g_package||'update_ae_previous_employer';
 if g_debug then
  hr_utility.set_location('Entering:'|| l_proc, 5);
 end if;
  --
  -- Initialise local variables
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Validation in addition to Row Handlers
  --
  -- Check that the person exists.
  --
  open check_legislation(p_previous_employer_id, l_effective_date);
  fetch check_legislation into l_legislation_code;
  if check_legislation%notfound then
    close check_legislation;
    hr_utility.set_message(801,'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  end if;
  close check_legislation;
 if g_debug then
  hr_utility.set_location(l_proc, 20);
 end if;
  --
  -- Check that the legislation of the specified business group is 'AE'.
  --
  if l_legislation_code <> 'AE' then
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','AE');
    hr_utility.raise_error;
  end if;
 if g_debug then
  hr_utility.set_location(l_proc, 30);
 end if;
  --
  -- Create the previous employer record using the create_previous_employer
  --
  hr_previous_employment_api.update_previous_employer
(  p_effective_date             =>      l_effective_date
  ,p_validate                   =>      p_validate
  ,p_previous_employer_id       =>      p_previous_employer_id
  ,p_start_date                 =>      p_start_date
  ,p_end_date                   =>      p_end_date
  ,p_period_years               =>      p_period_years
  ,p_period_months              =>      p_period_months
  ,p_period_days                =>      p_period_days
  ,p_employer_name              =>      p_employer_name
  ,p_employer_country           =>      p_employer_country
  ,p_employer_address           =>      p_employer_address
  ,p_employer_type              =>      p_employer_type
  ,p_employer_subtype           =>      p_employer_subtype
  ,p_description                =>      p_description
  ,p_all_assignments            =>      p_all_assignments
  ,p_pem_attribute_category     =>      p_pem_attribute_category
  ,p_pem_attribute1             =>      p_pem_attribute1
  ,p_pem_attribute2             =>      p_pem_attribute2
  ,p_pem_attribute3             =>      p_pem_attribute3
  ,p_pem_attribute4             =>      p_pem_attribute4
  ,p_pem_attribute5             =>      p_pem_attribute5
  ,p_pem_attribute6             =>      p_pem_attribute6
  ,p_pem_attribute7             =>      p_pem_attribute7
  ,p_pem_attribute8             =>      p_pem_attribute8
  ,p_pem_attribute9             =>      p_pem_attribute9
  ,p_pem_attribute10            =>      p_pem_attribute10
  ,p_pem_attribute11            =>      p_pem_attribute11
  ,p_pem_attribute12            =>      p_pem_attribute12
  ,p_pem_attribute13            =>      p_pem_attribute13
  ,p_pem_attribute14            =>      p_pem_attribute14
  ,p_pem_attribute15            =>      p_pem_attribute15
  ,p_pem_attribute16            =>      p_pem_attribute16
  ,p_pem_attribute17            =>      p_pem_attribute17
  ,p_pem_attribute18            =>      p_pem_attribute18
  ,p_pem_attribute19            =>      p_pem_attribute19
  ,p_pem_attribute20            =>      p_pem_attribute20
  ,p_pem_attribute21            =>      p_pem_attribute21
  ,p_pem_attribute22            =>      p_pem_attribute22
  ,p_pem_attribute23            =>      p_pem_attribute23
  ,p_pem_attribute24            =>      p_pem_attribute24
  ,p_pem_attribute25            =>      p_pem_attribute25
  ,p_pem_attribute26            =>      p_pem_attribute26
  ,p_pem_attribute27            =>      p_pem_attribute27
  ,p_pem_attribute28            =>      p_pem_attribute28
  ,p_pem_attribute29            =>      p_pem_attribute29
  ,p_pem_attribute30            =>      p_pem_attribute30
  ,p_pem_information_category   =>      'AE'
  ,p_pem_information1           =>      p_termination_reason
  ,p_object_version_number      =>      p_object_version_number
  );
    --
 if g_debug then
  hr_utility.set_location(' Leaving:'||l_proc, 40);
 end if;
  --
end update_ae_previous_employer;

end hr_ae_previous_employment_api;

/
