--------------------------------------------------------
--  DDL for Package Body PQP_PL_VEHICLE_ALLOCATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_PL_VEHICLE_ALLOCATIONS" AS
/* $Header: pqplvalp.pkb 120.1 2006/09/13 13:13:29 mseshadr noship $ */

PROCEDURE PL_VALIDATE_ALLOCATION(p_vehicle_repository_id          in     NUMBER
		                 ,p_effective_date                in     DATE
                                 ,p_val_information2              in     varchar2
  						 ,p_val_information3              in     NUMBER
	                         ) is
      cursor csr_veh_type is
       select pvr.vehicle_type,pvr.vehicle_ownership
       from
         pqp_vehicle_repository_f pvr
       where
        pvr.vehicle_repository_id = p_vehicle_repository_id
	and p_effective_date between pvr.effective_start_date and pvr.effective_end_date;

     cursor csr_capacity is select ci.value from pay_user_column_instances_f ci
      where ci.legislation_code = 'PL'
        and ci.user_column_instance_id = p_val_information2
	and p_effective_date between ci.effective_start_date and ci.effective_end_date;

   l_vehicle_type pqp_vehicle_repository_f.vehicle_type%type;
   l_vehicle_ownership pqp_vehicle_repository_f.vehicle_ownership%type;
   l_mileage_value number;
   l_proc varchar2(72);  -- Variable used when data is uploaded directly by api

BEGIN


    open csr_capacity;
    fetch csr_capacity into l_mileage_value;
    close csr_capacity;
    open csr_veh_type;
    fetch csr_veh_type into l_vehicle_type,l_vehicle_ownership;
    close csr_veh_type;

   If l_vehicle_ownership = 'PL_PC' and l_vehicle_type <> 'PL_T' then

      If p_val_information2 is null then
	hr_utility.set_message(800,'HR_375879_PL_MILEAGE_LMT_LAW');
	hr_utility.raise_error;
      End if;

      If p_val_information3 is null then
	hr_utility.set_message(800,'HR_375880_PL_MILEAGE_LMT_EMP');
	hr_utility.raise_error;
      End if;
      If p_val_information3 < l_mileage_value then
        hr_utility.set_message(800,'HR_375881_PL_EMP_LIMIT');
	hr_utility.raise_error;
      End if;
  End if;
  If l_vehicle_type = 'PL_T' then
   -- Check for Vehicle type Truck
    If p_val_information2 is not null or p_val_information3 is not null then
   -- Check the value is null for Truck
        hr_utility.set_message(800,'HR_375838_VAL_PL_TRUCK');
       --Monthly mileage limit is not applicable to trucks. Ensure that you do not specify a monthly mileage limit for a truck.
        hr_utility.raise_error;
     End if;
  End if;
END PL_VALIDATE_ALLOCATION;

PROCEDURE CREATE_PL_VEHICLE_ALLOCATION(p_assignment_id                  in     NUMBER
                                  ,p_effective_date                 in     DATE
						  ,p_business_group_id              in     NUMBER
                                  ,p_vehicle_repository_id          in     NUMBER
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
						  ,p_val_information20              in     varchar2) IS

Begin

  /* Added for GSI Bug 5472781 */
IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'PL') THEN
   hr_utility.trace('PL not installed.Leaving CREATE_PL_VEHICLE_ALLOCATION');
   return;
END IF;

 If p_val_information_category = 'PL' then

   PL_VALIDATE_ALLOCATION(p_vehicle_repository_id,p_effective_date,p_val_information2,p_val_information3);

 End If;


END CREATE_PL_VEHICLE_ALLOCATION;

PROCEDURE UPDATE_PL_VEHICLE_ALLOCATION(p_effective_date                 in     DATE
                                  ,p_vehicle_allocation_id          in     NUMBER
                                  ,p_assignment_id                  in     NUMBER
                                  ,p_business_group_id              in     NUMBER
                                  ,p_vehicle_repository_id          in     NUMBER
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
						  ,p_val_information20              in     varchar2) IS

BEGIN
  /* Added for GSI Bug 5472781 */
IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'PL') THEN
   hr_utility.trace('PL not installed.Leaving UPDATE_PL_VEHICLE_ALLOCATION');
   return;
END IF;

 If p_val_information_category = 'PL' then
  PL_VALIDATE_ALLOCATION(p_vehicle_repository_id,p_effective_date,p_val_information2,p_val_information3);
 End if;

END UPDATE_PL_VEHICLE_ALLOCATION;


PROCEDURE DELETE_PL_VEHICLE_ALLOCATION(P_VALIDATE in BOOLEAN
                          		  ,P_EFFECTIVE_DATE in DATE
                                  ,P_DATETRACK_MODE in VARCHAR2
                                  ,P_VEHICLE_ALLOCATION_ID in NUMBER
                                  ,P_OBJECT_VERSION_NUMBER in NUMBER) IS

cursor csr_element_entry is select peef.element_entry_id, peef.assignment_id, peef.object_version_number from
	pay_element_types_f petf,
	pay_element_entry_values_f peevf,
	pay_input_values_f pivf,
	pay_element_entries_f peef,
	pqp_vehicle_allocations_f pvaf,
	per_all_assignments_f paaf
   where
	peevf.element_entry_id = peef.element_entry_id and
	peef.element_type_id = petf.element_type_id and
	petf.element_type_id = peef.element_type_id and
	peef.assignment_id = pvaf.assignment_id and
	paaf.assignment_id = pvaf.assignment_id and
	pivf.element_type_id = petf.element_type_id and
	pivf.input_value_id = peevf.input_value_id and
	petf.element_name = 'Vehicle Mileage Expense Information' and
	pivf.name = 'Vehicle Allocation' and
	pvaf.vehicle_allocation_id = P_VEHICLE_ALLOCATION_ID and
	P_EFFECTIVE_DATE between peevf.EFFECTIVE_START_DATE and peevf.EFFECTIVE_END_DATE and
	P_EFFECTIVE_DATE between peef.EFFECTIVE_START_DATE and peef.EFFECTIVE_END_DATE and
	P_EFFECTIVE_DATE between petf.effective_start_date and petf.effective_end_date and
	P_EFFECTIVE_DATE between pivf.effective_start_date and pivf.effective_end_date and
	P_EFFECTIVE_DATE between pvaf.effective_start_date and pvaf.effective_end_date and
	P_EFFECTIVE_DATE between paaf.effective_start_date and paaf.effective_end_date;


  cursor csr_pay_period(p_assignment_id  number) is
        SELECT max(ptp.end_date)
	FROM   per_time_periods ptp,
	       per_all_assignments_f paa
        where  ptp.payroll_id = paa.payroll_id and
               paa.assignment_id = p_assignment_id;

  l_element_entry_id pay_element_entries_f.element_entry_id%type;
  l_assignment_id   per_all_assignments_f.assignment_id%type;
  l_period_end_date per_time_periods.end_date%type;
  l_object_version_number pay_element_entries_f.object_version_number%TYPE;

  l_effective_start_date date;
  l_effective_end_date   date;
  l_delete_warning       boolean;

BEGIN

  /* Added for GSI Bug 5472781 */
IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'PL') THEN
   hr_utility.trace('PL not installed.Leaving DELETE_PL_VEHICLE_ALLOCATION');
   return;
END IF;

  open csr_element_entry;
    fetch csr_element_entry into l_element_entry_id, l_assignment_id, l_object_version_number;
  close csr_element_entry;

  open csr_pay_period(l_assignment_id);
    fetch csr_pay_period into l_period_end_date;
  close csr_pay_period;

 If l_element_entry_id is not null then
   if p_effective_date > l_period_end_date then

     pay_element_entry_api.delete_element_entry (
	      p_validate              => FALSE,
	      p_datetrack_delete_mode => P_DATETRACK_MODE,
	      p_effective_date        => l_period_end_date,
	      p_element_entry_id      => l_element_entry_id,
	      p_object_version_number => l_object_version_number,
	      p_effective_start_date  => l_effective_start_date,
	      p_effective_end_date    => l_effective_end_date,
	      p_delete_warning        => l_delete_warning
	    );

   else

      pay_element_entry_api.delete_element_entry (
	      p_validate              => FALSE,
	      p_datetrack_delete_mode => P_DATETRACK_MODE,
	      p_effective_date        => p_effective_date,
	      p_element_entry_id      => l_element_entry_id,
	      p_object_version_number => l_object_version_number,
	      p_effective_start_date  => l_effective_start_date,
	      p_effective_end_date    => l_effective_end_date,
	      p_delete_warning        => l_delete_warning
	    );
   end if;
 End if;
END DELETE_PL_VEHICLE_ALLOCATION;

END PQP_PL_VEHICLE_ALLOCATIONS;

/
