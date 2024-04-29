--------------------------------------------------------
--  DDL for Package Body PQP_VEH_MULTI_ALLOC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_VEH_MULTI_ALLOC" as
/* $Header: pqvalmul.pkb 120.0.12010000.2 2008/08/08 07:21:35 ubhat ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  PQP_VEH_MULTI_ALLOC.';
--

Procedure convert_defs
  (p_rec in out nocopy pqp_val_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.assignment_id = hr_api.g_number) then
    p_rec.assignment_id :=
    pqp_val_shd.g_old_rec.assignment_id;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    pqp_val_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.across_assignments = hr_api.g_varchar2) then
    p_rec.across_assignments :=
    pqp_val_shd.g_old_rec.across_assignments;
  End If;
  If (p_rec.vehicle_repository_id = hr_api.g_number) then
    p_rec.vehicle_repository_id :=
    pqp_val_shd.g_old_rec.vehicle_repository_id;
  End If;
  If (p_rec.usage_type = hr_api.g_varchar2) then
    p_rec.usage_type :=
    pqp_val_shd.g_old_rec.usage_type;
  End If;
  If (p_rec.capital_contribution = hr_api.g_number) then
    p_rec.capital_contribution :=
    pqp_val_shd.g_old_rec.capital_contribution;
  End If;
  If (p_rec.private_contribution = hr_api.g_number) then
    p_rec.private_contribution :=
    pqp_val_shd.g_old_rec.private_contribution;
 End If;
  If (p_rec.default_vehicle = hr_api.g_varchar2) then
    p_rec.default_vehicle :=
    pqp_val_shd.g_old_rec.default_vehicle;
  End If;
  If (p_rec.fuel_card = hr_api.g_varchar2) then
    p_rec.fuel_card :=
    pqp_val_shd.g_old_rec.fuel_card;
  End If;
  If (p_rec.fuel_card_number = hr_api.g_varchar2) then
    p_rec.fuel_card_number :=
    pqp_val_shd.g_old_rec.fuel_card_number;
  End If;
  If (p_rec.calculation_method = hr_api.g_varchar2) then
    p_rec.calculation_method :=
    pqp_val_shd.g_old_rec.calculation_method;
  End If;
  If (p_rec.rates_table_id = hr_api.g_number) then
    p_rec.rates_table_id :=
    pqp_val_shd.g_old_rec.rates_table_id;
  End If;
  If (p_rec.element_type_id = hr_api.g_number) then
    p_rec.element_type_id :=
    pqp_val_shd.g_old_rec.element_type_id;
  End If;
  If (p_rec.private_use_flag = hr_api.g_varchar2) then
    p_rec.private_use_flag :=
    pqp_val_shd.g_old_rec.private_use_flag;
  End If;
  If (p_rec.insurance_number = hr_api.g_varchar2) then
    p_rec.insurance_number :=
    pqp_val_shd.g_old_rec.insurance_number;
  End If;
  If (p_rec.insurance_expiry_date = hr_api.g_date) then
    p_rec.insurance_expiry_date :=
    pqp_val_shd.g_old_rec.insurance_expiry_date;
  End If;

 If (p_rec.val_attribute_category = hr_api.g_varchar2) then
    p_rec.val_attribute_category :=
    pqp_val_shd.g_old_rec.val_attribute_category;
  End If;
  If (p_rec.val_attribute1 = hr_api.g_varchar2) then
    p_rec.val_attribute1 :=
    pqp_val_shd.g_old_rec.val_attribute1;
  End If;
  If (p_rec.val_attribute2 = hr_api.g_varchar2) then
    p_rec.val_attribute2 :=
    pqp_val_shd.g_old_rec.val_attribute2;
  End If;
  If (p_rec.val_attribute3 = hr_api.g_varchar2) then
    p_rec.val_attribute3 :=
    pqp_val_shd.g_old_rec.val_attribute3;
  End If;
  If (p_rec.val_attribute4 = hr_api.g_varchar2) then
    p_rec.val_attribute4 :=
    pqp_val_shd.g_old_rec.val_attribute4;
  End If;
  If (p_rec.val_attribute5 = hr_api.g_varchar2) then
    p_rec.val_attribute5 :=
    pqp_val_shd.g_old_rec.val_attribute5;
  End If;
  If (p_rec.val_attribute6 = hr_api.g_varchar2) then
    p_rec.val_attribute6 :=
    pqp_val_shd.g_old_rec.val_attribute6;
  End If;
  If (p_rec.val_attribute7 = hr_api.g_varchar2) then
    p_rec.val_attribute7 :=
    pqp_val_shd.g_old_rec.val_attribute7;
  End If;
  If (p_rec.val_attribute8 = hr_api.g_varchar2) then
    p_rec.val_attribute8 :=
    pqp_val_shd.g_old_rec.val_attribute8;
  End If;
  If (p_rec.val_attribute9 = hr_api.g_varchar2) then
    p_rec.val_attribute9 :=
    pqp_val_shd.g_old_rec.val_attribute9;
  End If;
  If (p_rec.val_attribute10 = hr_api.g_varchar2) then
    p_rec.val_attribute10 :=
    pqp_val_shd.g_old_rec.val_attribute10;
  End If;
  If (p_rec.val_attribute11 = hr_api.g_varchar2) then
    p_rec.val_attribute11 :=
    pqp_val_shd.g_old_rec.val_attribute11;
  End If;
  If (p_rec.val_attribute12 = hr_api.g_varchar2) then
    p_rec.val_attribute12 :=
    pqp_val_shd.g_old_rec.val_attribute12;
  End If;
  If (p_rec.val_attribute13 = hr_api.g_varchar2) then
    p_rec.val_attribute13 :=
    pqp_val_shd.g_old_rec.val_attribute13;
  End If;
  If (p_rec.val_attribute14 = hr_api.g_varchar2) then
    p_rec.val_attribute14 :=
    pqp_val_shd.g_old_rec.val_attribute14;
  End If;
  If (p_rec.val_attribute15 = hr_api.g_varchar2) then
    p_rec.val_attribute15 :=
    pqp_val_shd.g_old_rec.val_attribute15;
  End If;
  If (p_rec.val_attribute16 = hr_api.g_varchar2) then
    p_rec.val_attribute16 :=
    pqp_val_shd.g_old_rec.val_attribute16;
  End If;
  If (p_rec.val_attribute17 = hr_api.g_varchar2) then
    p_rec.val_attribute17 :=
    pqp_val_shd.g_old_rec.val_attribute17;
  End If;
  If (p_rec.val_attribute18 = hr_api.g_varchar2) then
    p_rec.val_attribute18 :=
    pqp_val_shd.g_old_rec.val_attribute18;
  End If;
  If (p_rec.val_attribute19 = hr_api.g_varchar2) then
    p_rec.val_attribute19 :=
    pqp_val_shd.g_old_rec.val_attribute19;
  End If;
  If (p_rec.val_attribute20 = hr_api.g_varchar2) then
    p_rec.val_attribute20 :=
    pqp_val_shd.g_old_rec.val_attribute20;
  End If;
  If (p_rec.val_information_category = hr_api.g_varchar2) then
    p_rec.val_information_category :=
    pqp_val_shd.g_old_rec.val_information_category;
  End If;
  If (p_rec.val_information1 = hr_api.g_varchar2) then
    p_rec.val_information1 :=
    pqp_val_shd.g_old_rec.val_information1;
  End If;
  If (p_rec.val_information2 = hr_api.g_varchar2) then
    p_rec.val_information2 :=
    pqp_val_shd.g_old_rec.val_information2;
  End If;
  If (p_rec.val_information3 = hr_api.g_varchar2) then
    p_rec.val_information3 :=
    pqp_val_shd.g_old_rec.val_information3;
  End If;
  If (p_rec.val_information4 = hr_api.g_varchar2) then
    p_rec.val_information4 :=
    pqp_val_shd.g_old_rec.val_information4;
  End If;
  If (p_rec.val_information5 = hr_api.g_varchar2) then
    p_rec.val_information5 :=
    pqp_val_shd.g_old_rec.val_information5;
  End If;
  If (p_rec.val_information6 = hr_api.g_varchar2) then
    p_rec.val_information6 :=
    pqp_val_shd.g_old_rec.val_information6;
  End If;
  If (p_rec.val_information7 = hr_api.g_varchar2) then
    p_rec.val_information7 :=
    pqp_val_shd.g_old_rec.val_information7;
  End If;
  If (p_rec.val_information8 = hr_api.g_varchar2) then
    p_rec.val_information8 :=
    pqp_val_shd.g_old_rec.val_information8;
  End If;
  If (p_rec.val_information9 = hr_api.g_varchar2) then
    p_rec.val_information9 :=
    pqp_val_shd.g_old_rec.val_information9;
  End If;
  If (p_rec.val_information10 = hr_api.g_varchar2) then
    p_rec.val_information10 :=
    pqp_val_shd.g_old_rec.val_information10;
  End If;
  If (p_rec.val_information11 = hr_api.g_varchar2) then
    p_rec.val_information11 :=
    pqp_val_shd.g_old_rec.val_information11;
  End If;
  If (p_rec.val_information12 = hr_api.g_varchar2) then
    p_rec.val_information12 :=
    pqp_val_shd.g_old_rec.val_information12;
  End If;
  If (p_rec.val_information13 = hr_api.g_varchar2) then
    p_rec.val_information13 :=
    pqp_val_shd.g_old_rec.val_information13;
  End If;
  If (p_rec.val_information14 = hr_api.g_varchar2) then
    p_rec.val_information14 :=
    pqp_val_shd.g_old_rec.val_information14;
  End If;
  If (p_rec.val_information15 = hr_api.g_varchar2) then
    p_rec.val_information15 :=
    pqp_val_shd.g_old_rec.val_information15;
  End If;
  If (p_rec.val_information16 = hr_api.g_varchar2) then
    p_rec.val_information16 :=
    pqp_val_shd.g_old_rec.val_information16;
  End If;
 If (p_rec.val_information17 = hr_api.g_varchar2) then
    p_rec.val_information17 :=
    pqp_val_shd.g_old_rec.val_information17;
  End If;
  If (p_rec.val_information18 = hr_api.g_varchar2) then
    p_rec.val_information18 :=
    pqp_val_shd.g_old_rec.val_information18;
  End If;
  If (p_rec.val_information19 = hr_api.g_varchar2) then
    p_rec.val_information19 :=
    pqp_val_shd.g_old_rec.val_information19;
  End If;
  If (p_rec.val_information20 = hr_api.g_varchar2) then
    p_rec.val_information20 :=
    pqp_val_shd.g_old_rec.val_information20;
  End If;
  If (p_rec.fuel_benefit = hr_api.g_varchar2) then
    p_rec.fuel_benefit :=
    pqp_val_shd.g_old_rec.fuel_benefit;
  End If;
  If (p_rec.sliding_rates_info = hr_api.g_varchar2) then
    p_rec.sliding_rates_info :=
    pqp_val_shd.g_old_rec.sliding_rates_info;
  End If;

  --
End convert_defs;

-- ----------------------------------------------------------------------------
-- |------------------< CREATE_VEHICLE_MULTIPLE_ALLOCATION >------------------|
-- ----------------------------------------------------------------------------
--
procedure create_veh_multi_alloc
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
  ,p_sliding_rates_info                  in     varchar2
  )
   is
  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'<BUS_PROCESS_NAME>';

CURSOR c_get_asg
IS
SELECT paa.assignment_id
  FROM  per_all_assignments_f paa
 WHERE paa.person_id =(SELECT paa1.person_id
                         FROM per_all_assignments_f paa1
                        WHERE paa1.assignment_id=p_assignment_id
                          AND paa1.business_group_id=p_business_group_id
                          AND p_effective_date BETWEEN paa1.effective_start_date
                                                   AND paa1.effective_end_date)
   AND NOT EXISTS (SELECT 'X'
                    FROM pqp_vehicle_allocations_f pva
                   WHERE pva.vehicle_repository_id=p_vehicle_repository_id
                     AND p_effective_date BETWEEN pva.effective_start_date
                                                   AND pva.effective_end_date
                     and pva.assignment_id =paa.assignment_id
                     and pva.business_group_id=paa.business_group_id)
   AND p_effective_date BETWEEN paa.effective_start_date
                            AND paa.effective_end_date;
l_get_asg                   c_get_asg%ROWTYPE;
l_vehicle_allocation_id     NUMBER;
l_object_version_number     NUMBER;
l_effective_start_date      DATE;
l_effective_end_date        DATE;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --


 OPEN c_get_asg;
  LOOP
   FETCH c_get_asg INTO l_get_asg;
   EXIT WHEN c_get_asg%NOTFOUND;

   pqp_val_ins.ins
   (p_effective_date                    => p_effective_date
   ,p_assignment_id                    	=> l_get_asg.assignment_id
   ,p_business_group_id                	=> p_business_group_id
   ,p_vehicle_repository_id         	=> p_vehicle_repository_id
   ,p_across_assignments            	=> p_across_assignments
   ,p_usage_type                    	=> p_usage_type
   ,p_capital_contribution           	=> p_capital_contribution
   ,p_private_contribution           	=> p_private_contribution
   ,p_default_vehicle                	=> p_default_vehicle
   ,p_fuel_card                      	=> p_fuel_card
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
   ,p_sliding_rates_info                => p_sliding_rates_info
   ,p_vehicle_allocation_id         	=> l_vehicle_allocation_id
   ,p_object_version_number            	=> l_object_version_number
   ,p_effective_start_date             	=> l_effective_start_date
   ,p_effective_end_date               	=> l_effective_end_date

   );

  END LOOP;
 CLOSE c_get_asg;

  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when others then
    --
    -- A validation or unexpected error has occured
    --
    --rollback to <BUS_PROCESS_NAME>;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_veh_multi_alloc;
--


--
-- ----------------------------------------------------------------------------
-- |------------------< UPDATE_VEHICLE_MULTIPLE_ALLOCATION >------------------|
-- ----------------------------------------------------------------------------

procedure update_veh_multi_alloc
  (p_validate                     in     boolean
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
  ,p_sliding_rates_info           in     varchar2
  )
IS


CURSOR c_get_asg
IS
SELECT  paa.assignment_id
       ,pva.object_version_number ovn
       ,pva.vehicle_allocation_id
  FROM  per_all_assignments_f paa
       ,pqp_vehicle_allocations_f pva
 WHERE paa.person_id =(SELECT paa1.person_id
                         FROM per_all_assignments_f paa1
                        WHERE paa1.assignment_id=p_assignment_id
                          AND paa1.business_group_id=p_business_group_id
                          AND p_effective_date BETWEEN paa1.effective_start_date
                                                   AND paa1.effective_end_date)
  AND paa.assignment_id=pva.assignment_id
  AND paa.business_group_id=pva.business_group_id
  AND paa.business_group_id=p_business_group_id
  AND p_effective_date BETWEEN paa.effective_start_date
                           AND paa.effective_end_date
-- fix for bug 7025352
 AND p_effective_date BETWEEN pva.effective_start_date
                           AND pva.effective_end_date
  AND pva.vehicle_repository_id=p_vehicle_repository_id
  AND paa.assignment_id<>p_assignment_id;



l_get_asg                c_get_asg%ROWTYPE;
l_effective_start_date   DATE;
l_effective_end_date     DATE;

l_vehicle_allocation_id     NUMBER;
l_object_version_number     NUMBER;
l_rec     pqp_val_shd.g_rec_type;
BEGIN


IF pqp_val_shd.g_old_rec.across_assignments='N' AND
   p_across_assignments='Y' THEN

 l_rec.usage_type                :=p_usage_type;
 l_rec.capital_contribution      :=p_capital_contribution;
 l_rec.private_contribution      :=p_private_contribution;
 l_rec.default_vehicle           :=p_default_vehicle;
 l_rec.fuel_card                 :=p_fuel_card;
 l_rec.fuel_card_number          :=p_fuel_card_number;
 l_rec.calculation_method        :=p_calculation_method;
 l_rec.rates_table_id            :=p_rates_table_id;
 l_rec.element_type_id           :=p_element_type_id;
 l_rec.private_use_flag          :=p_private_use_flag;
 l_rec.insurance_number          :=p_insurance_number;
 l_rec.insurance_expiry_date        :=p_insurance_expiry_date;
 l_rec.val_attribute_category    :=p_val_attribute_category;
 l_rec.val_attribute1            :=p_val_attribute1;
 l_rec.val_attribute2            :=p_val_attribute2;
 l_rec.val_attribute3            :=p_val_attribute3;
 l_rec.val_attribute4            :=p_val_attribute4;
 l_rec.val_attribute5            :=p_val_attribute5;
 l_rec.val_attribute6            :=p_val_attribute6;
 l_rec.val_attribute7            :=p_val_attribute7;
 l_rec.val_attribute8            :=p_val_attribute8;
 l_rec.val_attribute9            :=p_val_attribute9;
 l_rec.val_attribute10           :=p_val_attribute10;
 l_rec.val_attribute11           :=p_val_attribute11;
 l_rec.val_attribute12           :=p_val_attribute12;
 l_rec.val_attribute13           :=p_val_attribute13;
 l_rec.val_attribute14           :=p_val_attribute14;
 l_rec.val_attribute15           :=p_val_attribute15;
 l_rec.val_attribute16           :=p_val_attribute16;
 l_rec.val_attribute17           :=p_val_attribute17;
 l_rec.val_attribute18           :=p_val_attribute18;
 l_rec.val_attribute19           :=p_val_attribute19;
 l_rec.val_attribute20           :=p_val_attribute20;
 l_rec.val_information_category  :=p_val_information_category  ;
 l_rec.val_information1          :=p_val_information1;
 l_rec.val_information2          :=p_val_information2;
 l_rec.val_information3          :=p_val_information3;
 l_rec.val_information4          :=p_val_information4;
 l_rec.val_information5          :=p_val_information5;
 l_rec.val_information6          :=p_val_information6;
 l_rec.val_information7          :=p_val_information7;
 l_rec.val_information8          :=p_val_information8;
 l_rec.val_information9          :=p_val_information9;
 l_rec.val_information10         :=p_val_information10;
 l_rec.val_information11         :=p_val_information11;
 l_rec.val_information12         :=p_val_information12;
 l_rec.val_information13         :=p_val_information13;
 l_rec.val_information14         :=p_val_information14;
 l_rec.val_information15         :=p_val_information15;
 l_rec.val_information16         :=p_val_information16;
 l_rec.val_information17         :=p_val_information17;
 l_rec.val_information18         :=p_val_information18;
 l_rec.val_information19         :=p_val_information19;
 l_rec.val_information20         :=p_val_information20;
 l_rec.fuel_benefit              :=p_fuel_benefit ;
 l_rec.sliding_rates_info        :=p_sliding_rates_info  ;


convert_defs
  (p_rec =>l_rec
  ) ;

  pqp_veh_multi_alloc.create_veh_multi_alloc
   (p_validate                         =>p_validate
   ,p_effective_date                    => p_effective_date
   ,p_assignment_id                    	=> p_assignment_id
   ,p_business_group_id                	=> p_business_group_id
   ,p_vehicle_repository_id         	=> p_vehicle_repository_id
   ,p_across_assignments            	=> p_across_assignments
   ,p_usage_type                    	=> l_rec.usage_type
   ,p_capital_contribution           	=> l_rec.capital_contribution
   ,p_private_contribution           	=> l_rec.private_contribution
   ,p_default_vehicle                	=> l_rec.default_vehicle
   ,p_fuel_card                      	=> l_rec.fuel_card
   ,p_fuel_card_number               	=> l_rec.fuel_card_number
   ,p_calculation_method             	=> l_rec.calculation_method
   ,p_rates_table_id                 	=> l_rec.rates_table_id
   ,p_element_type_id                	=> l_rec.element_type_id
   ,p_private_use_flag		    	=> l_rec.private_use_flag
   ,p_insurance_number		    	=> l_rec.insurance_number
   ,p_insurance_expiry_date	 	=> l_rec.insurance_expiry_date
   ,p_val_attribute_category         	=> l_rec.val_attribute_category
   ,p_val_attribute1                 	=> l_rec.val_attribute1
   ,p_val_attribute2                 	=> l_rec.val_attribute2
   ,p_val_attribute3                 	=> l_rec.val_attribute3
   ,p_val_attribute4                	=> l_rec.val_attribute4
   ,p_val_attribute5                 	=> l_rec.val_attribute5
   ,p_val_attribute6                	=> l_rec.val_attribute6
   ,p_val_attribute7                	=> l_rec.val_attribute7
   ,p_val_attribute8                 	=> l_rec.val_attribute8
   ,p_val_attribute9                	=> l_rec.val_attribute9
   ,p_val_attribute10                	=> l_rec.val_attribute10
   ,p_val_attribute11               	=> l_rec.val_attribute11
   ,p_val_attribute12                	=> l_rec.val_attribute12
   ,p_val_attribute13                	=> l_rec.val_attribute13
   ,p_val_attribute14                	=> l_rec.val_attribute14
   ,p_val_attribute15                	=> l_rec.val_attribute15
   ,p_val_attribute16                	=> l_rec.val_attribute16
   ,p_val_attribute17                	=> l_rec.val_attribute17
   ,p_val_attribute18                	=> l_rec.val_attribute18
   ,p_val_attribute19                	=> l_rec.val_attribute19
   ,p_val_attribute20                	=> l_rec.val_attribute20
   ,p_val_information_category       	=> l_rec.val_information_category
   ,p_val_information1               	=> l_rec.val_information1
   ,p_val_information2               	=> l_rec.val_information2
   ,p_val_information3               	=> l_rec.val_information3
   ,p_val_information4               	=> l_rec.val_information4
   ,p_val_information5               	=> l_rec.val_information5
   ,p_val_information6               	=> l_rec.val_information6
   ,p_val_information7               	=> l_rec.val_information7
   ,p_val_information8               	=> l_rec.val_information8
   ,p_val_information9               	=> l_rec.val_information9
   ,p_val_information10              	=> l_rec.val_information10
   ,p_val_information11              	=> l_rec.val_information11
   ,p_val_information12              	=> l_rec.val_information12
   ,p_val_information13              	=> l_rec.val_information13
   ,p_val_information14              	=> l_rec.val_information14
   ,p_val_information15              	=> l_rec.val_information15
   ,p_val_information16              	=> l_rec.val_information16
   ,p_val_information17              	=> l_rec.val_information17
   ,p_val_information18              	=> l_rec.val_information18
   ,p_val_information19              	=> l_rec.val_information19
   ,p_val_information20              	=> l_rec.val_information20
   ,p_fuel_benefit                   	=> l_rec.fuel_benefit
   ,p_sliding_rates_info                => l_rec.sliding_rates_info
   );

ELSE
 OPEN c_get_asg;
  LOOP
   FETCH c_get_asg INTO l_get_asg;
   EXIT WHEN c_get_asg%NOTFOUND;

l_object_version_number:=l_get_asg.ovn;
   pqp_val_upd.upd
    (p_effective_date                  => p_effective_date
    ,p_datetrack_mode                  => p_datetrack_mode
    ,p_vehicle_allocation_id           => l_get_asg.vehicle_allocation_id
    ,p_object_version_number           =>l_object_version_number -- l_get_asg.ovn
    ,p_assignment_id                   => l_get_asg.assignment_id
    ,p_business_group_id               => p_business_group_id
    ,p_vehicle_repository_id           => p_vehicle_repository_id
    ,p_across_assignments              => p_across_assignments
    ,p_usage_type                      => p_usage_type
    ,p_capital_contribution            => p_capital_contribution
    ,p_private_contribution            => p_private_contribution
    ,p_default_vehicle                 => p_default_vehicle
    ,p_fuel_card                       => p_fuel_card
    ,p_fuel_card_number                => p_fuel_card_number
    ,p_calculation_method              => p_calculation_method
    ,p_rates_table_id                  => p_rates_table_id
    ,p_element_type_id                 => p_element_type_id
    ,p_private_use_flag		    	=> p_private_use_flag
    ,p_insurance_number		    	=> p_insurance_number
    ,p_insurance_expiry_date	   	=> p_insurance_expiry_date
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
    ,p_sliding_rates_info              =>p_sliding_rates_info
    ,p_effective_start_date            => l_effective_start_date
    ,p_effective_end_date              => l_effective_end_date
    );
  END LOOP;
 CLOSE c_get_asg;

END IF;

END update_veh_multi_alloc;


--
-- ----------------------------------------------------------------------------
-- |-------------------< DELETE_VEHICLE_MULTIPLE_ALLOCATION >----------------|
-- ----------------------------------------------------------------------------
procedure delete_veh_multi_alloc
  (p_validate                       in     boolean
  ,p_effective_date                 in     date
  ,p_datetrack_mode                 in     varchar2
  ,p_vehicle_allocation_id          in     number
  )
  IS
CURSOR c_get_asg
IS
SELECT  paa.assignment_id
       ,pva.object_version_number ovn
  FROM  per_all_assignments_f paa
       ,pqp_vehicle_allocations_f pva
 WHERE EXISTS (SELECT paa1.person_id
                         FROM per_all_assignments_f paa1
                             ,pqp_vehicle_allocations_f pva1
                        WHERE pva1.vehicle_allocation_id=p_vehicle_allocation_id
                          AND pva1.vehicle_repository_id=pva.vehicle_repository_id
                          AND paa1.assignment_id=pva1.assignment_id
                          AND paa1.business_group_id=pva1.business_group_id
                          AND p_effective_date BETWEEN paa1.effective_start_date
                                                   AND paa1.effective_end_date
                          AND p_effective_date BETWEEN pva1.effective_start_date
                                                   AND pva1.effective_end_date)
  AND paa.assignment_id=pva.assignment_id
  AND paa.business_group_id=pva.business_group_id
  AND p_effective_date BETWEEN paa.effective_start_date
                           AND paa.effective_end_date;

l_get_asg                c_get_asg%ROWTYPE;
BEGIN
 OPEN c_get_asg;
  LOOP
   FETCH c_get_asg INTO l_get_asg;
--   fnd_message.raise_error;
   EXIT;
  END LOOP;
 CLOSE c_get_asg;

  END delete_veh_multi_alloc;

end PQP_VEH_MULTI_ALLOC;

/
