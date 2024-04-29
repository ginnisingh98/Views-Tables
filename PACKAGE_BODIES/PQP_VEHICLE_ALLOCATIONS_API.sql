--------------------------------------------------------
--  DDL for Package Body PQP_VEHICLE_ALLOCATIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_VEHICLE_ALLOCATIONS_API" as
/* $Header: pqvalapi.pkb 120.0.12010000.2 2008/08/08 07:21:04 ubhat ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  PQP_VEHICLE_ALLOCATIONS_API.';
--
-- ----------------------------------------------------------------------------
-- |-----------------------< CREATE_VEHICLE_ALLOCATION >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_vehicle_allocation
  (p_validate                       in     boolean
  ,p_effective_date                 in     date
  ,p_assignment_id                  in     number
  ,p_business_group_id              in     number
  ,p_vehicle_repository_id          in     number
  ,p_across_assignments             in     varchar2
  ,p_usage_type                     in     varchar2
  ,p_capital_contribution           in     number
  ,p_private_contribution           in     number
  ,p_default_vehicle                in     varchar2
  ,p_fuel_card                      in     varchar2
  ,p_fuel_card_number               in     varchar2
  ,p_calculation_method             in     varchar2
  ,p_rates_table_id                 in     number
  ,p_element_type_id                in     number
  ,p_private_use_flag		    in     varchar2
  ,p_insurance_number		    in     varchar2
  ,p_insurance_expiry_date		    in     date
  ,p_val_attribute_category         in     varchar2
  ,p_val_attribute1                 in     varchar2
  ,p_val_attribute2                 in     varchar2
  ,p_val_attribute3                 in     varchar2
  ,p_val_attribute4                 in     varchar2
  ,p_val_attribute5                 in     varchar2
  ,p_val_attribute6                 in     varchar2
  ,p_val_attribute7                 in     varchar2
  ,p_val_attribute8                 in     varchar2
  ,p_val_attribute9                 in     varchar2
  ,p_val_attribute10                in     varchar2
  ,p_val_attribute11                in     varchar2
  ,p_val_attribute12                in     varchar2
  ,p_val_attribute13                in     varchar2
  ,p_val_attribute14                in     varchar2
  ,p_val_attribute15                in     varchar2
  ,p_val_attribute16                in     varchar2
  ,p_val_attribute17                in     varchar2
  ,p_val_attribute18                in     varchar2
  ,p_val_attribute19                in     varchar2
  ,p_val_attribute20                in     varchar2
  ,p_val_information_category       in     varchar2
  ,p_val_information1               in     varchar2
  ,p_val_information2               in     varchar2
  ,p_val_information3               in     varchar2
  ,p_val_information4               in     varchar2
  ,p_val_information5               in     varchar2
  ,p_val_information6               in     varchar2
  ,p_val_information7               in     varchar2
  ,p_val_information8               in     varchar2
  ,p_val_information9               in     varchar2
  ,p_val_information10              in     varchar2
  ,p_val_information11              in     varchar2
  ,p_val_information12              in     varchar2
  ,p_val_information13              in     varchar2
  ,p_val_information14              in     varchar2
  ,p_val_information15              in     varchar2
  ,p_val_information16              in     varchar2
  ,p_val_information17              in     varchar2
  ,p_val_information18              in     varchar2
  ,p_val_information19              in     varchar2
  ,p_val_information20              in     varchar2
  ,p_fuel_benefit                   in     varchar2
  ,p_sliding_rates_info             in     varchar2
  ,p_vehicle_allocation_id          out    nocopy number
  ,p_object_version_number          out    nocopy number
  ,p_effective_start_date           out    nocopy date
  ,p_effective_end_date             out    nocopy date
  )
   is
  --
  -- Declare cursors and local variables
  --

  l_proc       varchar2(72) := g_package||'CREATE_VEHICLE_ALLOCATION';
  l_effective_date date;
  l_fuel_card  pqp_vehicle_allocations_f.fuel_card%TYPE;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_VEHICLE_ALLOCATION;
  hr_utility.set_location(l_proc, 20);
  --
  --Truncate date parameter
  l_effective_date :=TRUNC(p_effective_date);

 --If fuel card is NULL then make it 'N';
   IF p_fuel_card IS NULL THEN

    l_fuel_card :='N';
   ELSE
    l_fuel_card:=p_fuel_card;
   END IF;
  -- Call Before Process User Hook
  --
  begin
  PQP_VEHICLE_ALLOCATIONS_BK1.create_vehicle_allocation_b
  (p_effective_date                     =>l_effective_date
  ,p_assignment_id                  	=> p_assignment_id
  ,p_business_group_id                	=> p_business_group_id
  ,p_vehicle_repository_id         	=> p_vehicle_repository_id
  ,p_across_assignments            	=> p_across_assignments
  ,p_usage_type                    	=> p_usage_type
  ,p_capital_contribution           	=> p_capital_contribution
  ,p_private_contribution           	=> p_private_contribution
  ,p_default_vehicle                	=> p_default_vehicle
  ,p_fuel_card                      	=> l_fuel_card
  ,p_fuel_card_number               	=> p_fuel_card_number
  ,p_calculation_method             	=> p_calculation_method
  ,p_rates_table_id                 	=> p_rates_table_id
  ,p_element_type_id                	=> p_element_type_id
  ,p_private_use_flag		    	=> p_private_use_flag
  ,p_insurance_number		    	=> p_insurance_number
  ,p_insurance_expiry_date		=> p_insurance_expiry_date
  ,p_val_attribute_category         	=> p_val_attribute_category
  ,p_val_attribute1                 	=> p_val_attribute1
  ,p_val_attribute2                 	=> p_val_attribute2
  ,p_val_attribute3                 	=> p_val_attribute3
  ,p_val_attribute4                	=> p_val_attribute4
  ,p_val_attribute5                 	=> p_val_attribute5
  ,p_val_attribute6                	=> p_val_attribute6
  ,p_val_attribute7                	=> p_val_attribute7
  ,p_val_attribute8                 	=> p_val_attribute8
  ,p_val_attribute9                	=> p_val_attribute9
  ,p_val_attribute10                	=> p_val_attribute10
  ,p_val_attribute11               	=> p_val_attribute11
  ,p_val_attribute12                	=> p_val_attribute12
  ,p_val_attribute13                	=> p_val_attribute13
  ,p_val_attribute14                	=> p_val_attribute14
  ,p_val_attribute15                	=> p_val_attribute15
  ,p_val_attribute16                	=> p_val_attribute16
  ,p_val_attribute17                	=> p_val_attribute17
  ,p_val_attribute18                	=> p_val_attribute18
  ,p_val_attribute19                	=> p_val_attribute19
  ,p_val_attribute20                	=> p_val_attribute20
  ,p_val_information_category       	=> p_val_information_category
  ,p_val_information1               	=> p_val_information1
  ,p_val_information2               	=> p_val_information2
  ,p_val_information3               	=> p_val_information3
  ,p_val_information4               	=> p_val_information4
  ,p_val_information5               	=> p_val_information5
  ,p_val_information6               	=> p_val_information6
  ,p_val_information7               	=> p_val_information7
  ,p_val_information8               	=> p_val_information8
  ,p_val_information9               	=> p_val_information9
  ,p_val_information10              	=> p_val_information10
  ,p_val_information11              	=> p_val_information11
  ,p_val_information12              	=> p_val_information12
  ,p_val_information13              	=> p_val_information13
  ,p_val_information14              	=> p_val_information14
  ,p_val_information15              	=> p_val_information15
  ,p_val_information16              	=> p_val_information16
  ,p_val_information17              	=> p_val_information17
  ,p_val_information18              	=> p_val_information18
  ,p_val_information19              	=> p_val_information19
  ,p_val_information20              	=> p_val_information20
  ,p_fuel_benefit                   	=> p_fuel_benefit
  ,p_sliding_rates_info			=>p_sliding_rates_info
  ) ;

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQP_VEHICLE_ALLOCATIONS_API'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
pqp_val_ins.ins
  (p_effective_date                     => l_effective_date
  ,p_assignment_id                    	=> p_assignment_id
  ,p_business_group_id                	=> p_business_group_id
  ,p_vehicle_repository_id         	=> p_vehicle_repository_id
  ,p_across_assignments            	=> p_across_assignments
  ,p_usage_type                    	=> p_usage_type
  ,p_capital_contribution           	=> p_capital_contribution
  ,p_private_contribution           	=> p_private_contribution
  ,p_default_vehicle                	=> p_default_vehicle
  ,p_fuel_card                      	=> l_fuel_card
  ,p_fuel_card_number               	=> p_fuel_card_number
  ,p_calculation_method             	=> p_calculation_method
  ,p_rates_table_id                 	=> p_rates_table_id
  ,p_element_type_id                	=> p_element_type_id
  ,p_private_use_flag		    	=> p_private_use_flag
  ,p_insurance_number		    	=> p_insurance_number
  ,p_insurance_expiry_date	    	=> p_insurance_expiry_date
  ,p_val_attribute_category         	=> p_val_attribute_category
  ,p_val_attribute1                 	=> p_val_attribute1
  ,p_val_attribute2                 	=> p_val_attribute2
  ,p_val_attribute3                 	=> p_val_attribute3
  ,p_val_attribute4                	=> p_val_attribute4
  ,p_val_attribute5                 	=> p_val_attribute5
  ,p_val_attribute6                	=> p_val_attribute6
  ,p_val_attribute7                	=> p_val_attribute7
  ,p_val_attribute8                 	=> p_val_attribute8
  ,p_val_attribute9                	=> p_val_attribute9
  ,p_val_attribute10                	=> p_val_attribute10
  ,p_val_attribute11               	=> p_val_attribute11
  ,p_val_attribute12                	=> p_val_attribute12
  ,p_val_attribute13                	=> p_val_attribute13
  ,p_val_attribute14                	=> p_val_attribute14
  ,p_val_attribute15                	=> p_val_attribute15
  ,p_val_attribute16                	=> p_val_attribute16
  ,p_val_attribute17                	=> p_val_attribute17
  ,p_val_attribute18                	=> p_val_attribute18
  ,p_val_attribute19                	=> p_val_attribute19
  ,p_val_attribute20                	=> p_val_attribute20
  ,p_val_information_category       	=> p_val_information_category
  ,p_val_information1               	=> p_val_information1
  ,p_val_information2               	=> p_val_information2
  ,p_val_information3               	=> p_val_information3
  ,p_val_information4               	=> p_val_information4
  ,p_val_information5               	=> p_val_information5
  ,p_val_information6               	=> p_val_information6
  ,p_val_information7               	=> p_val_information7
  ,p_val_information8               	=> p_val_information8
  ,p_val_information9               	=> p_val_information9
  ,p_val_information10              	=> p_val_information10
  ,p_val_information11              	=> p_val_information11
  ,p_val_information12              	=> p_val_information12
  ,p_val_information13              	=> p_val_information13
  ,p_val_information14              	=> p_val_information14
  ,p_val_information15              	=> p_val_information15
  ,p_val_information16              	=> p_val_information16
  ,p_val_information17              	=> p_val_information17
  ,p_val_information18              	=> p_val_information18
  ,p_val_information19              	=> p_val_information19
  ,p_val_information20              	=> p_val_information20
  ,p_fuel_benefit                   	=> p_fuel_benefit
  ,p_sliding_rates_info			=> p_sliding_rates_info
  ,p_vehicle_allocation_id             	=> p_vehicle_allocation_id
  ,p_object_version_number             	=> p_object_version_number
  ,p_effective_start_date              	=> p_effective_start_date
  ,p_effective_end_date               	=> p_effective_end_date
  );

 IF p_across_assignments='Y' THEN
  pqp_veh_multi_alloc.create_veh_multi_alloc
  ( p_validate                          =>p_validate
   ,p_effective_date                    => l_effective_date
   ,p_assignment_id                    	=> p_assignment_id
   ,p_business_group_id                	=> p_business_group_id
   ,p_vehicle_repository_id         	=> p_vehicle_repository_id
   ,p_across_assignments            	=> p_across_assignments
   ,p_usage_type                    	=> p_usage_type
   ,p_capital_contribution           	=> p_capital_contribution
   ,p_private_contribution           	=> p_private_contribution
   ,p_default_vehicle                	=> p_default_vehicle
   ,p_fuel_card                      	=> l_fuel_card
   ,p_fuel_card_number               	=> p_fuel_card_number
   ,p_calculation_method             	=> p_calculation_method
   ,p_rates_table_id                 	=> p_rates_table_id
   ,p_element_type_id                	=> p_element_type_id
   ,p_private_use_flag		    	=> p_private_use_flag
   ,p_insurance_number		    	=> p_insurance_number
   ,p_insurance_expiry_date		=> p_insurance_expiry_date
   ,p_val_attribute_category         	=> p_val_attribute_category
   ,p_val_attribute1                 	=> p_val_attribute1
   ,p_val_attribute2                 	=> p_val_attribute2
   ,p_val_attribute3                 	=> p_val_attribute3
   ,p_val_attribute4                	=> p_val_attribute4
   ,p_val_attribute5                 	=> p_val_attribute5
   ,p_val_attribute6                	=> p_val_attribute6
   ,p_val_attribute7                	=> p_val_attribute7
   ,p_val_attribute8                 	=> p_val_attribute8
   ,p_val_attribute9                	=> p_val_attribute9
   ,p_val_attribute10                	=> p_val_attribute10
   ,p_val_attribute11               	=> p_val_attribute11
   ,p_val_attribute12                	=> p_val_attribute12
   ,p_val_attribute13                	=> p_val_attribute13
   ,p_val_attribute14                	=> p_val_attribute14
   ,p_val_attribute15                	=> p_val_attribute15
   ,p_val_attribute16                	=> p_val_attribute16
   ,p_val_attribute17                	=> p_val_attribute17
   ,p_val_attribute18                	=> p_val_attribute18
   ,p_val_attribute19                	=> p_val_attribute19
   ,p_val_attribute20                	=> p_val_attribute20
   ,p_val_information_category       	=> p_val_information_category
   ,p_val_information1               	=> p_val_information1
   ,p_val_information2               	=> p_val_information2
   ,p_val_information3               	=> p_val_information3
   ,p_val_information4               	=> p_val_information4
   ,p_val_information5               	=> p_val_information5
   ,p_val_information6               	=> p_val_information6
   ,p_val_information7               	=> p_val_information7
   ,p_val_information8               	=> p_val_information8
   ,p_val_information9               	=> p_val_information9
   ,p_val_information10              	=> p_val_information10
   ,p_val_information11              	=> p_val_information11
   ,p_val_information12              	=> p_val_information12
   ,p_val_information13              	=> p_val_information13
   ,p_val_information14              	=> p_val_information14
   ,p_val_information15              	=> p_val_information15
   ,p_val_information16              	=> p_val_information16
   ,p_val_information17              	=> p_val_information17
   ,p_val_information18              	=> p_val_information18
   ,p_val_information19              	=> p_val_information19
   ,p_val_information20              	=> p_val_information20
   ,p_fuel_benefit                   	=> p_fuel_benefit
   ,p_sliding_rates_info		=>p_sliding_rates_info

    );
 END IF;
  --
  -- Call After Process User Hook
  --
  begin
  PQP_VEHICLE_ALLOCATIONS_BK1.create_vehicle_allocation_a
  (p_effective_date                     =>l_effective_date
  ,p_assignment_id                    	=> p_assignment_id
  ,p_business_group_id                	=> p_business_group_id
  ,p_vehicle_repository_id         	=> p_vehicle_repository_id
  ,p_across_assignments            	=> p_across_assignments
  ,p_usage_type                    	=> p_usage_type
  ,p_capital_contribution           	=> p_capital_contribution
  ,p_private_contribution           	=> p_private_contribution
  ,p_default_vehicle                	=> p_default_vehicle
  ,p_fuel_card                      	=> l_fuel_card
  ,p_fuel_card_number               	=> p_fuel_card_number
  ,p_calculation_method             	=> p_calculation_method
  ,p_rates_table_id                 	=> p_rates_table_id
  ,p_element_type_id                	=> p_element_type_id
  ,p_private_use_flag		    	=> p_private_use_flag
  ,p_insurance_number		    	=> p_insurance_number
  ,p_insurance_expiry_date		=> p_insurance_expiry_date
  ,p_val_attribute_category         	=> p_val_attribute_category
  ,p_val_attribute1                 	=> p_val_attribute1
  ,p_val_attribute2                 	=> p_val_attribute2
  ,p_val_attribute3                 	=> p_val_attribute3
  ,p_val_attribute4                	=> p_val_attribute4
  ,p_val_attribute5                 	=> p_val_attribute5
  ,p_val_attribute6                	=> p_val_attribute6
  ,p_val_attribute7                	=> p_val_attribute7
  ,p_val_attribute8                 	=> p_val_attribute8
  ,p_val_attribute9                	=> p_val_attribute9
  ,p_val_attribute10                	=> p_val_attribute10
  ,p_val_attribute11               	=> p_val_attribute11
  ,p_val_attribute12                	=> p_val_attribute12
  ,p_val_attribute13                	=> p_val_attribute13
  ,p_val_attribute14                	=> p_val_attribute14
  ,p_val_attribute15                	=> p_val_attribute15
  ,p_val_attribute16                	=> p_val_attribute16
  ,p_val_attribute17                	=> p_val_attribute17
  ,p_val_attribute18                	=> p_val_attribute18
  ,p_val_attribute19                	=> p_val_attribute19
  ,p_val_attribute20                	=> p_val_attribute20
  ,p_val_information_category       	=> p_val_information_category
  ,p_val_information1               	=> p_val_information1
  ,p_val_information2               	=> p_val_information2
  ,p_val_information3               	=> p_val_information3
  ,p_val_information4               	=> p_val_information4
  ,p_val_information5               	=> p_val_information5
  ,p_val_information6               	=> p_val_information6
  ,p_val_information7               	=> p_val_information7
  ,p_val_information8               	=> p_val_information8
  ,p_val_information9               	=> p_val_information9
  ,p_val_information10              	=> p_val_information10
  ,p_val_information11              	=> p_val_information11
  ,p_val_information12              	=> p_val_information12
  ,p_val_information13              	=> p_val_information13
  ,p_val_information14              	=> p_val_information14
  ,p_val_information15              	=> p_val_information15
  ,p_val_information16              	=> p_val_information16
  ,p_val_information17              	=> p_val_information17
  ,p_val_information18              	=> p_val_information18
  ,p_val_information19              	=> p_val_information19
  ,p_val_information20              	=> p_val_information20
  ,p_fuel_benefit                   	=> p_fuel_benefit
  ,p_sliding_rates_info			=>p_sliding_rates_info
  ,p_vehicle_allocation_id             	=> p_vehicle_allocation_id
  ,p_object_version_number             	=> p_object_version_number
  ,p_effective_start_date              	=> p_effective_start_date
  ,p_effective_end_date               	=> p_effective_end_date
  );

   exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQP_VEHICLE_ALLOCATIONS_API'
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
  p_vehicle_allocation_id             	:= p_vehicle_allocation_id ;
  p_object_version_number             	:= p_object_version_number;
  p_effective_start_date              	:= p_effective_start_date;
  p_effective_end_date               	:= p_effective_end_date ;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_VEHICLE_ALLOCATION;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_vehicle_allocation_id         := null;
    p_object_version_number         := null;
    p_effective_start_date          := null;
    p_effective_end_date            := null ;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_VEHICLE_ALLOCATION;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_vehicle_allocation_id         := null;
    p_object_version_number         := null;
    p_effective_start_date          := null;
    p_effective_end_date            := null ;

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_vehicle_allocation;
--


--
-- ----------------------------------------------------------------------------
-- |----------------------< UPDATE_VEHICLE_ALLOCATION >-----------------------|
-- ----------------------------------------------------------------------------

procedure update_vehicle_allocation
  (p_validate                       in     boolean
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_vehicle_allocation_id        in     number
  ,p_object_version_number        in out nocopy number
  ,p_assignment_id                in     number
  ,p_business_group_id            in     number
  ,p_vehicle_repository_id        in     number
  ,p_across_assignments           in     varchar2
  ,p_usage_type                   in     varchar2
  ,p_capital_contribution         in     number
  ,p_private_contribution         in     number
  ,p_default_vehicle              in     varchar2
  ,p_fuel_card                    in     varchar2
  ,p_fuel_card_number             in     varchar2
  ,p_calculation_method           in     varchar2
  ,p_rates_table_id               in     number
  ,p_element_type_id              in     number
  ,p_private_use_flag		  in     varchar2
  ,p_insurance_number		  in     varchar2
  ,p_insurance_expiry_date		  in     date
  ,p_val_attribute_category       in     varchar2
  ,p_val_attribute1               in     varchar2
  ,p_val_attribute2               in     varchar2
  ,p_val_attribute3               in     varchar2
  ,p_val_attribute4               in     varchar2
  ,p_val_attribute5               in     varchar2
  ,p_val_attribute6               in     varchar2
  ,p_val_attribute7               in     varchar2
  ,p_val_attribute8               in     varchar2
  ,p_val_attribute9               in     varchar2
  ,p_val_attribute10              in     varchar2
  ,p_val_attribute11              in     varchar2
  ,p_val_attribute12              in     varchar2
  ,p_val_attribute13              in     varchar2
  ,p_val_attribute14              in     varchar2
  ,p_val_attribute15              in     varchar2
  ,p_val_attribute16              in     varchar2
  ,p_val_attribute17              in     varchar2
  ,p_val_attribute18              in     varchar2
  ,p_val_attribute19              in     varchar2
  ,p_val_attribute20              in     varchar2
  ,p_val_information_category     in     varchar2
  ,p_val_information1             in     varchar2
  ,p_val_information2             in     varchar2
  ,p_val_information3             in     varchar2
  ,p_val_information4             in     varchar2
  ,p_val_information5             in     varchar2
  ,p_val_information6             in     varchar2
  ,p_val_information7             in     varchar2
  ,p_val_information8             in     varchar2
  ,p_val_information9             in     varchar2
  ,p_val_information10            in     varchar2
  ,p_val_information11            in     varchar2
  ,p_val_information12            in     varchar2
  ,p_val_information13            in     varchar2
  ,p_val_information14            in     varchar2
  ,p_val_information15            in     varchar2
  ,p_val_information16            in     varchar2
  ,p_val_information17            in     varchar2
  ,p_val_information18            in     varchar2
  ,p_val_information19            in     varchar2
  ,p_val_information20            in     varchar2
  ,p_fuel_benefit                 in     varchar2
  ,p_sliding_rates_info  	  in     varchar2
  ,p_effective_start_date         out nocopy date
  ,p_effective_end_date           out nocopy date
  )
IS
  l_proc      varchar2(72) := g_package||'update_vehicle_allocation';
  l_effective_date  date;
  l_fuel_card   pqp_vehicle_allocations_f.fuel_card%TYPE;
BEGIN
  --
  -- Issue a savepoint
  --
  savepoint update_vehicle_allocation;

  hr_utility.set_location(l_proc, 20);
  --Truncate effective date parameter
   l_effective_date :=TRUNC(p_effective_date);

 --If fuel card is NULL then make it 'N';
   IF p_fuel_card IS NULL THEN

    l_fuel_card :='N';
   ELSE
    l_fuel_card:=p_fuel_card;
   END IF;
  --
  -- Call Before Process User Hook
  --
  begin
  PQP_VEHICLE_ALLOCATIONS_BK2.update_vehicle_allocation_b
  (p_effective_date                     => l_effective_date
  ,p_datetrack_mode                     => p_datetrack_mode
  ,p_vehicle_allocation_id              => p_vehicle_allocation_id
  ,p_object_version_number              => p_object_version_number
  ,p_assignment_id                  	=> p_assignment_id
  ,p_business_group_id                	=> p_business_group_id
  ,p_vehicle_repository_id         	=> p_vehicle_repository_id
  ,p_across_assignments            	=> p_across_assignments
  ,p_usage_type                    	=> p_usage_type
  ,p_capital_contribution           	=> p_capital_contribution
  ,p_private_contribution           	=> p_private_contribution
  ,p_default_vehicle                	=> p_default_vehicle
  ,p_fuel_card                      	=> l_fuel_card
  ,p_fuel_card_number               	=> p_fuel_card_number
  ,p_calculation_method             	=> p_calculation_method
  ,p_rates_table_id                 	=> p_rates_table_id
  ,p_element_type_id                	=> p_element_type_id
  ,p_private_use_flag		    	=> p_private_use_flag
  ,p_insurance_number		    	=> p_insurance_number
  ,p_insurance_expiry_date		    	=> p_insurance_expiry_date
  ,p_val_attribute_category         	=> p_val_attribute_category
  ,p_val_attribute1                 	=> p_val_attribute1
  ,p_val_attribute2                 	=> p_val_attribute2
  ,p_val_attribute3                 	=> p_val_attribute3
  ,p_val_attribute4                	=> p_val_attribute4
  ,p_val_attribute5                 	=> p_val_attribute5
  ,p_val_attribute6                	=> p_val_attribute6
  ,p_val_attribute7                	=> p_val_attribute7
  ,p_val_attribute8                 	=> p_val_attribute8
  ,p_val_attribute9                	=> p_val_attribute9
  ,p_val_attribute10                	=> p_val_attribute10
  ,p_val_attribute11               	=> p_val_attribute11
  ,p_val_attribute12                	=> p_val_attribute12
  ,p_val_attribute13                	=> p_val_attribute13
  ,p_val_attribute14                	=> p_val_attribute14
  ,p_val_attribute15                	=> p_val_attribute15
  ,p_val_attribute16                	=> p_val_attribute16
  ,p_val_attribute17                	=> p_val_attribute17
  ,p_val_attribute18                	=> p_val_attribute18
  ,p_val_attribute19                	=> p_val_attribute19
  ,p_val_attribute20                	=> p_val_attribute20
  ,p_val_information_category       	=> p_val_information_category
  ,p_val_information1               	=> p_val_information1
  ,p_val_information2               	=> p_val_information2
  ,p_val_information3               	=> p_val_information3
  ,p_val_information4               	=> p_val_information4
  ,p_val_information5               	=> p_val_information5
  ,p_val_information6               	=> p_val_information6
  ,p_val_information7               	=> p_val_information7
  ,p_val_information8               	=> p_val_information8
  ,p_val_information9               	=> p_val_information9
  ,p_val_information10              	=> p_val_information10
  ,p_val_information11              	=> p_val_information11
  ,p_val_information12              	=> p_val_information12
  ,p_val_information13              	=> p_val_information13
  ,p_val_information14              	=> p_val_information14
  ,p_val_information15              	=> p_val_information15
  ,p_val_information16              	=> p_val_information16
  ,p_val_information17              	=> p_val_information17
  ,p_val_information18              	=> p_val_information18
  ,p_val_information19              	=> p_val_information19
  ,p_val_information20              	=> p_val_information20
  ,p_fuel_benefit                   	=> p_fuel_benefit
  ,p_sliding_rates_info			=>p_sliding_rates_info

  ) ;

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQP_VEHICLE_ALLOCATIONS_API'
        ,p_hook_type   => 'BP'
        );
  end;

pqp_val_upd.upd
  (p_effective_date                  => l_effective_date
  ,p_datetrack_mode                  => p_datetrack_mode
  ,p_vehicle_allocation_id           => p_vehicle_allocation_id
  ,p_object_version_number           => p_object_version_number
  ,p_assignment_id                   => p_assignment_id
  ,p_business_group_id               => p_business_group_id
  ,p_vehicle_repository_id           => p_vehicle_repository_id
  ,p_across_assignments              => p_across_assignments
  ,p_usage_type                      => p_usage_type
  ,p_capital_contribution            => p_capital_contribution
  ,p_private_contribution            => p_private_contribution
  ,p_default_vehicle                 => p_default_vehicle
  ,p_fuel_card                       => l_fuel_card
  ,p_fuel_card_number                => p_fuel_card_number
  ,p_calculation_method              => p_calculation_method
  ,p_rates_table_id                  => p_rates_table_id
  ,p_element_type_id                 => p_element_type_id
  ,p_private_use_flag		     => p_private_use_flag
  ,p_insurance_number		     => p_insurance_number
  ,p_insurance_expiry_date		     => p_insurance_expiry_date
  ,p_val_attribute_category          => p_val_attribute_category
  ,p_val_attribute1                  => p_val_attribute1
  ,p_val_attribute2                  => p_val_attribute2
  ,p_val_attribute3                  => p_val_attribute3
  ,p_val_attribute4                  => p_val_attribute4
  ,p_val_attribute5                  => p_val_attribute5
  ,p_val_attribute6                  => p_val_attribute6
  ,p_val_attribute7                  => p_val_attribute7
  ,p_val_attribute8                  => p_val_attribute8
  ,p_val_attribute9                  => p_val_attribute9
  ,p_val_attribute10                 => p_val_attribute10
  ,p_val_attribute11                 => p_val_attribute11
  ,p_val_attribute12                 => p_val_attribute12
  ,p_val_attribute13                 => p_val_attribute13
  ,p_val_attribute14                 => p_val_attribute14
  ,p_val_attribute15                 => p_val_attribute15
  ,p_val_attribute16                 => p_val_attribute16
  ,p_val_attribute17                 => p_val_attribute17
  ,p_val_attribute18                 => p_val_attribute18
  ,p_val_attribute19                 => p_val_attribute19
  ,p_val_attribute20                 => p_val_attribute20
  ,p_val_information_category        => p_val_information_category
  ,p_val_information1                => p_val_information1
  ,p_val_information2                => p_val_information2
  ,p_val_information3                => p_val_information3
  ,p_val_information4                => p_val_information4
  ,p_val_information5                => p_val_information5
  ,p_val_information6                => p_val_information6
  ,p_val_information7                => p_val_information7
  ,p_val_information8                => p_val_information8
  ,p_val_information9                => p_val_information9
  ,p_val_information10               => p_val_information10
  ,p_val_information11               => p_val_information11
  ,p_val_information12               => p_val_information12
  ,p_val_information13               => p_val_information13
  ,p_val_information14               => p_val_information14
  ,p_val_information15               => p_val_information15
  ,p_val_information16               => p_val_information16
  ,p_val_information17               => p_val_information17
  ,p_val_information18               => p_val_information18
  ,p_val_information19               => p_val_information19
  ,p_val_information20               => p_val_information20
  ,p_fuel_benefit                    => p_fuel_benefit
  ,p_sliding_rates_info	 	     =>p_sliding_rates_info
  ,p_effective_start_date            => p_effective_start_date
  ,p_effective_end_date              => p_effective_end_date
  );

 pqp_veh_multi_alloc.update_veh_multi_alloc
  ( p_validate                        => p_validate
   ,p_effective_date                  => l_effective_date
   ,p_datetrack_mode                  => p_datetrack_mode
   ,p_vehicle_allocation_id           => p_vehicle_allocation_id
   ,p_object_version_number           => p_object_version_number
   ,p_assignment_id                   => p_assignment_id
   ,p_business_group_id               => p_business_group_id
   ,p_vehicle_repository_id           => p_vehicle_repository_id
   ,p_across_assignments              => p_across_assignments
   ,p_usage_type                      => p_usage_type
   ,p_capital_contribution            => p_capital_contribution
   ,p_private_contribution            => p_private_contribution
   ,p_default_vehicle                 => p_default_vehicle
   ,p_fuel_card                       => l_fuel_card
   ,p_fuel_card_number                => p_fuel_card_number
   ,p_calculation_method              => p_calculation_method
   ,p_rates_table_id                  => p_rates_table_id
   ,p_element_type_id                 => p_element_type_id
   ,p_private_use_flag		      => p_private_use_flag
   ,p_insurance_number		      => p_insurance_number
   ,p_insurance_expiry_date	      => p_insurance_expiry_date
   ,p_val_attribute_category          => p_val_attribute_category
   ,p_val_attribute1                  => p_val_attribute1
   ,p_val_attribute2                  => p_val_attribute2
   ,p_val_attribute3                  => p_val_attribute3
   ,p_val_attribute4                  => p_val_attribute4
   ,p_val_attribute5                  => p_val_attribute5
   ,p_val_attribute6                  => p_val_attribute6
   ,p_val_attribute7                  => p_val_attribute7
   ,p_val_attribute8                  => p_val_attribute8
   ,p_val_attribute9                  => p_val_attribute9
   ,p_val_attribute10                 => p_val_attribute10
   ,p_val_attribute11                 => p_val_attribute11
   ,p_val_attribute12                 => p_val_attribute12
   ,p_val_attribute13                 => p_val_attribute13
   ,p_val_attribute14                 => p_val_attribute14
   ,p_val_attribute15                 => p_val_attribute15
   ,p_val_attribute16                 => p_val_attribute16
   ,p_val_attribute17                 => p_val_attribute17
   ,p_val_attribute18                 => p_val_attribute18
   ,p_val_attribute19                 => p_val_attribute19
   ,p_val_attribute20                 => p_val_attribute20
   ,p_val_information_category        => p_val_information_category
   ,p_val_information1                => p_val_information1
   ,p_val_information2                => p_val_information2
   ,p_val_information3                => p_val_information3
   ,p_val_information4                => p_val_information4
   ,p_val_information5                => p_val_information5
   ,p_val_information6                => p_val_information6
   ,p_val_information7                => p_val_information7
   ,p_val_information8                => p_val_information8
   ,p_val_information9                => p_val_information9
   ,p_val_information10               => p_val_information10
   ,p_val_information11               => p_val_information11
   ,p_val_information12               => p_val_information12
   ,p_val_information13               => p_val_information13
   ,p_val_information14               => p_val_information14
   ,p_val_information15               => p_val_information15
   ,p_val_information16               => p_val_information16
   ,p_val_information17               => p_val_information17
   ,p_val_information18               => p_val_information18
   ,p_val_information19               => p_val_information19
   ,p_val_information20               => p_val_information20
   ,p_fuel_benefit                    => p_fuel_benefit
   ,p_sliding_rates_info  	      =>p_sliding_rates_info

    );


  --
  -- Call After Process User Hook
  --
  begin
  PQP_VEHICLE_ALLOCATIONS_BK2.update_vehicle_allocation_a
  (p_effective_date                     => l_effective_date
  ,p_datetrack_mode                     => p_datetrack_mode
  ,p_vehicle_allocation_id              => p_vehicle_allocation_id
  ,p_object_version_number              => p_object_version_number
  ,p_assignment_id                  	=> p_assignment_id
  ,p_business_group_id                	=> p_business_group_id
  ,p_vehicle_repository_id         	=> p_vehicle_repository_id
  ,p_across_assignments            	=> p_across_assignments
  ,p_usage_type                    	=> p_usage_type
  ,p_capital_contribution           	=> p_capital_contribution
  ,p_private_contribution           	=> p_private_contribution
  ,p_default_vehicle                	=> p_default_vehicle
  ,p_fuel_card                      	=> l_fuel_card
  ,p_fuel_card_number               	=> p_fuel_card_number
  ,p_calculation_method             	=> p_calculation_method
  ,p_rates_table_id                 	=> p_rates_table_id
  ,p_element_type_id                	=> p_element_type_id
  ,p_private_use_flag		    	=> p_private_use_flag
  ,p_insurance_number		    	=> p_insurance_number
  ,p_insurance_expiry_date	    	=> p_insurance_expiry_date
  ,p_val_attribute_category         	=> p_val_attribute_category
  ,p_val_attribute1                 	=> p_val_attribute1
  ,p_val_attribute2                 	=> p_val_attribute2
  ,p_val_attribute3                 	=> p_val_attribute3
  ,p_val_attribute4                	=> p_val_attribute4
  ,p_val_attribute5                 	=> p_val_attribute5
  ,p_val_attribute6                	=> p_val_attribute6
  ,p_val_attribute7                	=> p_val_attribute7
  ,p_val_attribute8                 	=> p_val_attribute8
  ,p_val_attribute9                	=> p_val_attribute9
  ,p_val_attribute10                	=> p_val_attribute10
  ,p_val_attribute11               	=> p_val_attribute11
  ,p_val_attribute12                	=> p_val_attribute12
  ,p_val_attribute13                	=> p_val_attribute13
  ,p_val_attribute14                	=> p_val_attribute14
  ,p_val_attribute15                	=> p_val_attribute15
  ,p_val_attribute16                	=> p_val_attribute16
  ,p_val_attribute17                	=> p_val_attribute17
  ,p_val_attribute18                	=> p_val_attribute18
  ,p_val_attribute19                	=> p_val_attribute19
  ,p_val_attribute20                	=> p_val_attribute20
  ,p_val_information_category       	=> p_val_information_category
  ,p_val_information1               	=> p_val_information1
  ,p_val_information2               	=> p_val_information2
  ,p_val_information3               	=> p_val_information3
  ,p_val_information4               	=> p_val_information4
  ,p_val_information5               	=> p_val_information5
  ,p_val_information6               	=> p_val_information6
  ,p_val_information7               	=> p_val_information7
  ,p_val_information8               	=> p_val_information8
  ,p_val_information9               	=> p_val_information9
  ,p_val_information10              	=> p_val_information10
  ,p_val_information11              	=> p_val_information11
  ,p_val_information12              	=> p_val_information12
  ,p_val_information13              	=> p_val_information13
  ,p_val_information14              	=> p_val_information14
  ,p_val_information15              	=> p_val_information15
  ,p_val_information16              	=> p_val_information16
  ,p_val_information17              	=> p_val_information17
  ,p_val_information18              	=> p_val_information18
  ,p_val_information19              	=> p_val_information19
  ,p_val_information20              	=> p_val_information20
  ,p_fuel_benefit                   	=> p_fuel_benefit
  ,p_sliding_rates_info			=> p_sliding_rates_info
  ,p_effective_start_date               => p_effective_start_date
  ,p_effective_end_date                 => p_effective_end_date
  ) ;

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQP_VEHICLE_ALLOCATIONS_API'
        ,p_hook_type   => 'AP'
        );
  end;

  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_effective_start_date              	:= p_effective_start_date;
  p_effective_end_date               	:= p_effective_end_date ;
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_vehicle_allocation;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
     p_effective_start_date        	:= null;
     p_effective_end_date              	:= null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
     rollback to update_vehicle_allocation;
     p_effective_start_date        	:= null;
     p_effective_end_date              	:= null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
END update_vehicle_allocation;
--
-- ----------------------------------------------------------------------------
-- |---------------------< DELETE_VEHICLE_ALLOCATION >------------------------|
-- ----------------------------------------------------------------------------
procedure delete_vehicle_allocation
  (p_validate                     in     boolean
  ,p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_vehicle_allocation_id        in     number
  ,p_object_version_number        in out nocopy number
  ,p_effective_start_date         out    nocopy date
  ,p_effective_end_date           out    nocopy date
  ) IS

 l_proc       varchar2(72) := g_package||'delete_vehicle_allocation';
 l_effective_date date;

  BEGIN

  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_vehicle_allocation;
  --
  hr_utility.set_location(l_proc, 20);
  --truncate effective_date parameter
   l_effective_date :=TRUNC(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin

  PQP_VEHICLE_ALLOCATIONS_BK3.DELETE_VEHICLE_ALLOCATION_b
  (p_validate                           =>p_validate
  ,p_effective_date                     =>l_effective_date
  ,p_datetrack_mode                     =>p_datetrack_mode
  ,p_vehicle_allocation_id              =>p_vehicle_allocation_id
  ,p_object_version_number              =>p_object_version_number
  ) ;

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQP_VEHICLE_ALLOCATIONS_API'
        ,p_hook_type   => 'BP'
        );
  end;


  pqp_val_del.del
  (p_effective_date             => l_effective_date
  ,p_datetrack_mode             => p_datetrack_mode
  ,p_vehicle_allocation_id      => p_vehicle_allocation_id
  ,p_object_version_number      => p_object_version_number
  ,p_effective_start_date       => p_effective_start_date
  ,p_effective_end_date         => p_effective_end_date
  );

 -- comented as this procedure does not do anything now ( Bug 5634880)
 /*
   pqp_veh_multi_alloc.delete_veh_multi_alloc
  (p_validate                      =>p_validate
  ,p_effective_date                =>l_effective_date
  ,p_datetrack_mode                =>p_datetrack_mode
  ,p_vehicle_allocation_id         =>p_vehicle_allocation_id
  );
  */
  --
  -- Call after Process User Hook
  --
  begin

  PQP_VEHICLE_ALLOCATIONS_BK3.delete_vehicle_allocation_a
  (p_validate                           =>p_validate
  ,p_effective_date                     =>l_effective_date
  ,p_datetrack_mode                     =>p_datetrack_mode
  ,p_vehicle_allocation_id              =>p_vehicle_allocation_id
  ,p_object_version_number              =>p_object_version_number
  ,p_effective_start_date              => p_effective_start_date
  ,p_effective_end_date                 =>p_effective_end_date

  ) ;

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQP_VEHICLE_ALLOCATIONS_API'
        ,p_hook_type   => 'AP'
        );
  end;
  hr_utility.set_location(l_proc, 60);
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
  p_object_version_number             	:= p_object_version_number;
  p_effective_start_date              	:= p_effective_start_date;
  p_effective_end_date               	:= p_effective_end_date ;
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_vehicle_allocation;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number         := null;
    p_effective_start_date          := null;
    p_effective_end_date            := null ;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_vehicle_allocation;
    p_object_version_number         := null;
    p_effective_start_date          := null;
    p_effective_end_date            := null ;

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;

  END delete_vehicle_allocation;

end PQP_VEHICLE_ALLOCATIONS_API;

/
