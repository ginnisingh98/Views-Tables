--------------------------------------------------------
--  DDL for Package Body PQP_PL_VEHICLE_ALLOCATIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_PL_VEHICLE_ALLOCATIONS_API" as
/* $Header: pqvalpli.pkb 120.0 2005/10/16 22:54:39 ssekhar noship $ */
--
-- Package Variables
--
g_package  varchar2(33);
--
-- -------------------------------------------------------------------------------------
-- |-------------------------< create_pl_vehicle_allocation >---------------------------|
-- -------------------------------------------------------------------------------------
--
procedure create_pl_vehicle_allocation
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_assignment_id                  in     number
  ,p_business_group_id              in     number
  ,p_vehicle_repository_id          in     number   default null
  ,p_across_assignments             in     varchar2 default null
  ,p_usage_type                     in     varchar2 default null
  ,p_capital_contribution           in     number   default null
  ,p_private_contribution           in     number   default null
  ,p_default_vehicle                in     varchar2 default null
  ,p_fuel_card                      in     varchar2 default null
  ,p_fuel_card_number               in     varchar2 default null
  ,p_calculation_method             in     varchar2 default null
  ,p_rates_table_id                 in     number   default null
  ,p_element_type_id                in     number   default null
  ,p_private_use_flag		        in     varchar2 default null
  ,p_insurance_number		        in     varchar2 default null
  ,p_insurance_expiry_date	        in     date	    default null
  ,p_val_attribute_category         in     varchar2 default null
  ,p_val_attribute1                 in     varchar2 default null
  ,p_val_attribute2                 in     varchar2 default null
  ,p_val_attribute3                 in     varchar2 default null
  ,p_val_attribute4                 in     varchar2 default null
  ,p_val_attribute5                 in     varchar2 default null
  ,p_val_attribute6                 in     varchar2 default null
  ,p_val_attribute7                 in     varchar2 default null
  ,p_val_attribute8                 in     varchar2 default null
  ,p_val_attribute9                 in     varchar2 default null
  ,p_val_attribute10                in     varchar2 default null
  ,p_val_attribute11                in     varchar2 default null
  ,p_val_attribute12                in     varchar2 default null
  ,p_val_attribute13                in     varchar2 default null
  ,p_val_attribute14                in     varchar2 default null
  ,p_val_attribute15                in     varchar2 default null
  ,p_val_attribute16                in     varchar2 default null
  ,p_val_attribute17                in     varchar2 default null
  ,p_val_attribute18                in     varchar2 default null
  ,p_val_attribute19                in     varchar2 default null
  ,p_val_attribute20                in     varchar2 default null
  ,p_val_information_category       in     varchar2 default null
  ,p_agreement_description          in     varchar2 default null
  ,p_month_mileage_limit_by_law     in     varchar2 default null
  ,p_month_mileage_limit_by_emp     in     varchar2 default null
  ,p_other_conditions               in     varchar2 default null
  ,p_fuel_benefit                   in     varchar2 default null
  ,p_sliding_rates_info		    in     varchar2 default null
  ,p_vehicle_allocation_id          out    nocopy number
  ,p_object_version_number          out    nocopy number
  ,p_effective_start_date           out    nocopy date
  ,p_effective_end_date             out    nocopy date
  ) is
   --
  -- Declare cursors and local variables
  --
  l_proc                 varchar2(72);
  l_legislation_code     varchar2(2);
  --
  cursor csr_bg is
    select legislation_code
    from per_business_groups pbg
    where pbg.business_group_id = p_business_group_id;
  --
begin
     g_package :='pqp_pl_vehicle_allocations_api.';
     l_proc    := g_package||'create_pl_vehicle_allocation';

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
  -- Check that the legislation of the specified business group is 'PL'.
  --
  if l_legislation_code <> 'PL' then
    hr_utility.set_message(801, 'HR_7961_PER_BUS_GRP_INVALID');
    hr_utility.set_message_token('LEG_CODE','PL');
    hr_utility.raise_error;
  end if;


  hr_utility.set_location(l_proc, 6);


  --
  -- Call the Vehicle Allocation business process
  --
 PQP_VEHICLE_ALLOCATIONS_API.create_vehicle_allocation
  (p_validate                       => p_validate
  ,p_effective_date                 => p_effective_date
  ,p_assignment_id                  => p_assignment_id
  ,p_business_group_id              => p_business_group_id
  ,p_vehicle_repository_id          => p_vehicle_repository_id
  ,p_across_assignments             => p_across_assignments
  ,p_usage_type                     => p_usage_type
  ,p_capital_contribution           => p_capital_contribution
  ,p_private_contribution           => p_private_contribution
  ,p_default_vehicle                => p_default_vehicle
  ,p_fuel_card                      => p_fuel_card
  ,p_fuel_card_number               => p_fuel_card_number
  ,p_calculation_method             => p_calculation_method
  ,p_rates_table_id                 => p_rates_table_id
  ,p_element_type_id                => p_element_type_id
  ,p_private_use_flag		        => p_private_use_flag
  ,p_insurance_number		        => p_insurance_number
  ,p_insurance_expiry_date	        => p_insurance_expiry_date
  ,p_val_attribute_category         => p_val_attribute_category
  ,p_val_attribute1                 => p_val_attribute1
  ,p_val_attribute2                 => p_val_attribute2
  ,p_val_attribute3                 => p_val_attribute3
  ,p_val_attribute4                 => p_val_attribute4
  ,p_val_attribute5                 => p_val_attribute5
  ,p_val_attribute6                 => p_val_attribute6
  ,p_val_attribute7                 => p_val_attribute7
  ,p_val_attribute8                 => p_val_attribute8
  ,p_val_attribute9                 => p_val_attribute9
  ,p_val_attribute10                => p_val_attribute10
  ,p_val_attribute11                => p_val_attribute11
  ,p_val_attribute12                => p_val_attribute12
  ,p_val_attribute13                => p_val_attribute13
  ,p_val_attribute14                => p_val_attribute14
  ,p_val_attribute15                => p_val_attribute15
  ,p_val_attribute16                => p_val_attribute16
  ,p_val_attribute17                => p_val_attribute17
  ,p_val_attribute18                => p_val_attribute18
  ,p_val_attribute19                => p_val_attribute19
  ,p_val_attribute20                => p_val_attribute20
  ,p_val_information_category       => p_val_information_category
  ,p_val_information1               => p_agreement_description
  ,p_val_information2               => p_month_mileage_limit_by_law
  ,p_val_information3               => p_month_mileage_limit_by_emp
  ,p_val_information4               => p_other_conditions
  ,p_val_information5               => null
  ,p_val_information6               => null
  ,p_val_information7               => null
  ,p_val_information8               => null
  ,p_val_information9               => null
  ,p_val_information10              => null
  ,p_val_information11              => null
  ,p_val_information12              => null
  ,p_val_information13              => null
  ,p_val_information14              => null
  ,p_val_information15              => null
  ,p_val_information16              => null
  ,p_val_information17              => null
  ,p_val_information18              => null
  ,p_val_information19              => null
  ,p_val_information20              => null
  ,p_fuel_benefit                   => p_fuel_benefit
  ,p_sliding_rates_info		        => p_sliding_rates_info
  ,p_vehicle_allocation_id          => p_vehicle_allocation_id
  ,p_object_version_number          => p_object_version_number
  ,p_effective_start_date           => p_effective_start_date
  ,p_effective_end_date             => p_effective_end_date
  );
  --
--
end create_pl_vehicle_allocation;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_pl_vehicle_allocation >--------------------|
-- ----------------------------------------------------------------------------
--
Procedure update_pl_vehicle_allocation
 (p_validate                      in     boolean  default false
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_vehicle_allocation_id        in     number
  ,p_object_version_number        in     out nocopy number
  ,p_assignment_id                in     number    default hr_api.g_number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_vehicle_repository_id        in     number    default hr_api.g_number
  ,p_across_assignments           in     varchar2  default hr_api.g_varchar2
  ,p_usage_type                   in     varchar2  default hr_api.g_varchar2
  ,p_capital_contribution         in     number    default hr_api.g_number
  ,p_private_contribution         in     number    default hr_api.g_number
  ,p_default_vehicle              in     varchar2  default hr_api.g_varchar2
  ,p_fuel_card                    in     varchar2  default hr_api.g_varchar2
  ,p_fuel_card_number             in     varchar2  default hr_api.g_varchar2
  ,p_calculation_method           in     varchar2  default hr_api.g_varchar2
  ,p_rates_table_id               in     number    default hr_api.g_number
  ,p_element_type_id              in     number    default hr_api.g_number
  ,p_private_use_flag		 	  in     varchar2  default hr_api.g_varchar2
  ,p_insurance_number		  	  in     varchar2  default hr_api.g_varchar2
  ,p_insurance_expiry_date	  	  in     date	   default hr_api.g_date
  ,p_val_attribute_category       in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute1               in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute2               in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute3               in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute4               in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute5               in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute6               in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute7               in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute8               in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute9               in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute10              in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute11              in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute12              in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute13              in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute14              in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute15              in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute16              in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute17              in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute18              in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute19              in     varchar2  default hr_api.g_varchar2
  ,p_val_attribute20              in     varchar2  default hr_api.g_varchar2
  ,p_val_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_agreement_description        in     varchar2  default hr_api.g_varchar2
  ,p_month_mileage_limit_by_law   in     varchar2  default hr_api.g_varchar2
  ,p_month_mileage_limit_by_emp   in     varchar2  default hr_api.g_varchar2
  ,p_other_conditions             in     varchar2  default hr_api.g_varchar2
  ,p_fuel_benefit                 in     varchar2  default hr_api.g_varchar2
  ,p_sliding_rates_info		      in     varchar2  default hr_api.g_varchar2
  ,p_effective_start_date         out    nocopy date
  ,p_effective_end_date           out    nocopy date
  ) is

   l_proc                 varchar2(72);
   l_legislation_code     varchar2(2);
  --
  cursor csr_bg is
    select legislation_code
    from per_business_groups pbg
    where pbg.business_group_id = p_business_group_id;
  --
begin
     g_package :='pqp_pl_vehicle_allocations_api.';
     l_proc    := g_package||'update_pl_vehicle_allocation';

  hr_utility.set_location('Entering:'|| l_proc, 5);
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


  hr_utility.set_location(l_proc, 6);
  -- Call  for  Update Vehicle allocation business process
   PQP_VEHICLE_ALLOCATIONS_API.update_vehicle_allocation
  (p_validate                     => p_validate
  ,p_effective_date               => p_effective_date
  ,p_datetrack_mode               => p_datetrack_mode
  ,p_vehicle_allocation_id        => p_vehicle_allocation_id
  ,p_object_version_number        => p_object_version_number
  ,p_assignment_id                => p_assignment_id
  ,p_business_group_id            => p_business_group_id
  ,p_vehicle_repository_id        => p_vehicle_repository_id
  ,p_across_assignments           => p_across_assignments
  ,p_usage_type                   => p_usage_type
  ,p_capital_contribution         => p_capital_contribution
  ,p_private_contribution         => p_private_contribution
  ,p_default_vehicle              => p_default_vehicle
  ,p_fuel_card                    => p_fuel_card
  ,p_fuel_card_number             => p_fuel_card_number
  ,p_calculation_method           => p_calculation_method
  ,p_rates_table_id 			  => p_rates_table_id
  ,p_element_type_id              => p_element_type_id
  ,p_private_use_flag		      => p_private_use_flag
  ,p_insurance_number		      => p_insurance_number
  ,p_insurance_expiry_date	      => p_insurance_expiry_date
  ,p_val_attribute_category       => p_val_attribute_category
  ,p_val_attribute1               => p_val_attribute1
  ,p_val_attribute2               => p_val_attribute2
  ,p_val_attribute3               => p_val_attribute3
  ,p_val_attribute4               => p_val_attribute4
  ,p_val_attribute5               => p_val_attribute5
  ,p_val_attribute6               => p_val_attribute6
  ,p_val_attribute7               => p_val_attribute7
  ,p_val_attribute8               => p_val_attribute8
  ,p_val_attribute9               => p_val_attribute9
  ,p_val_attribute10              => p_val_attribute10
  ,p_val_attribute11              => p_val_attribute11
  ,p_val_attribute12              => p_val_attribute12
  ,p_val_attribute13              => p_val_attribute13
  ,p_val_attribute14              => p_val_attribute14
  ,p_val_attribute15              => p_val_attribute15
  ,p_val_attribute16              => p_val_attribute16
  ,p_val_attribute17              => p_val_attribute17
  ,p_val_attribute18              => p_val_attribute18
  ,p_val_attribute19              => p_val_attribute19
  ,p_val_attribute20              => p_val_attribute20
  ,p_val_information_category     => p_val_information_category
  ,p_val_information1             => p_agreement_description
  ,p_val_information2             => p_month_mileage_limit_by_law
  ,p_val_information3             => p_month_mileage_limit_by_emp
  ,p_val_information4             => p_other_conditions
  ,p_val_information5             => null
  ,p_val_information6             => null
  ,p_val_information7             => null
  ,p_val_information8             => null
  ,p_val_information9             => null
  ,p_val_information10            => null
  ,p_val_information11            => null
  ,p_val_information12            => null
  ,p_val_information13            => null
  ,p_val_information14            => null
  ,p_val_information15            => null
  ,p_val_information16            => null
  ,p_val_information17            => null
  ,p_val_information18            => null
  ,p_val_information19            => null
  ,p_val_information20            => null
  ,p_fuel_benefit                 => p_fuel_benefit
  ,p_sliding_rates_info		      => p_sliding_rates_info
  ,p_effective_start_date         => p_effective_start_date
  ,p_effective_end_date           => p_effective_end_date
  );

End Update_pl_vehicle_allocation;
end pqp_pl_vehicle_allocations_api;

/
