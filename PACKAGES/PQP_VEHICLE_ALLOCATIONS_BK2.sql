--------------------------------------------------------
--  DDL for Package PQP_VEHICLE_ALLOCATIONS_BK2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_VEHICLE_ALLOCATIONS_BK2" AUTHID CURRENT_USER as
/* $Header: pqvalapi.pkh 120.1 2005/10/02 02:28:38 aroussel $ */
--
-- ----------------------------------------------------------------------------
-- |-------------------------< UPDATE_VEHICLE_ALLOCATION_b >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_vehicle_allocation_b
  (p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_vehicle_allocation_id        in     number
  ,p_object_version_number        in     number
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
  ,p_insurance_expiry_date	  in     date
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
  ,p_sliding_rates_info	          in     varchar2
    );


-- ----------------------------------------------------------------------------
-- |-------------------------< UPDATE_VEHICLE_ALLOCATION_a >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_vehicle_allocation_a
  (p_effective_date               in     date
  ,p_datetrack_mode               in     varchar2
  ,p_vehicle_allocation_id        in     number
  ,p_object_version_number        in     number
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
  ,p_insurance_expiry_date	  in     date
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
  ,p_sliding_rates_info		    in     varchar2
  ,p_effective_start_date         in     date
  ,p_effective_end_date           in     date
    );



end PQP_VEHICLE_ALLOCATIONS_BK2;

 

/
