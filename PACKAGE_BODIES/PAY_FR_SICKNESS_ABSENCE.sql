--------------------------------------------------------
--  DDL for Package Body PAY_FR_SICKNESS_ABSENCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FR_SICKNESS_ABSENCE" AS
/* $Header: perfrabs.pkb 120.1.12000000.2 2007/02/28 11:04:00 spendhar ship $ */
--
g_package  varchar2(50) := 'pay_fr_sickness_absence.';
l_adoption_spouse_min_leave Number;

PROCEDURE PERSON_ABSENCE_CREATE(
         p_business_group_id            IN Number
        ,p_abs_information_category     IN varchar2
        ,p_person_id                    IN Number
        ,p_date_start                   IN Date
        ,p_date_end                     IN Date
        ,p_abs_information1             IN Varchar2
        ,p_abs_information4             IN Varchar2
        ,p_abs_information5             IN Varchar2
        ,p_abs_information6             IN Varchar2
        ,p_abs_information7             IN Varchar2
        ,p_abs_information8             IN Varchar2
        ,p_abs_information9             IN Varchar2
        ,p_abs_information10            IN Varchar2
        ,p_abs_information11            IN Varchar2
        ,p_abs_information12            IN Varchar2
       ) IS

  l_proc	varchar2(200) := g_package ||'person_absence_create';
  --

begin

  --
  /* Added for GSI Bug 5472781 */
  IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'FR') THEN
     hr_utility.set_location('Leaving : '||l_proc , 10);
     return;
  END IF;
  --
  -- get the values of the person_id profile
     fnd_profile.put('HR_FR_PERSON_ID',p_person_id);
  -- get the value of the absence_start_date
     fnd_profile.put('HR_FR_ABSENCE_START_DATE',to_char(p_date_start,'DD-MON-YYYY'));



  If p_abs_information_category = 'FR_S' then



            --
            IF p_abs_information1 IS NOT NULL THEN
              -- Current absence is Child absence
              IF (p_abs_information9 IS NOT NULL
                 OR p_abs_information10 IS NOT NULL
                 OR p_abs_information11 IS NOT NULL
                 OR p_abs_information12 IS NOT NULL) THEN
                   hr_utility.set_message(801,'PAY_75030_INV_ELIGIBILITY_SEG');
                   hr_utility.raise_error;
              END IF;
              -- #3040003
              IF (p_abs_information7 IS NOT NULL) THEN --IJSS Inelig dt
                hr_utility.set_message(801,'PAY_75079_INV_IJSS_INELIG_DT');
                hr_utility.raise_error;
              END IF;

              --
            END IF;
            --

  ElsIf p_abs_information_category = 'FR_M'  Then
     --
     If p_abs_information1 Is Not Null --Child Absence
        And
         (p_abs_information4 Is Not Null
          Or p_abs_information5 Is Not Null
          Or p_abs_information6 Is Not Null
          Or p_abs_information7 Is Not Null
          Or p_abs_information8 Is Not Null
          Or p_abs_information9 Is Not Null) Then

        hr_utility.set_message(801,'PAY_75044_INV_MATERNITY_SEG');
        hr_utility.raise_error;
     End If;
     --
     If (fnd_date.canonical_to_date(p_abs_information4) < p_date_start or
         fnd_date.canonical_to_date(p_abs_information4) > p_date_end ) Then
        hr_utility.set_message(801,'PAY_75045_INV_MAT_CONFINE_DATE');
        hr_utility.raise_error;
     End If;
     --

  ElsIf p_abs_information_category = 'FR_FR_ADOPTION' Then
     --
     select global_value
     Into l_adoption_spouse_min_leave
     from ff_globals_f
     where global_name ='FR_ADOPTION_SPOUSE_MIN_LEAVE'
       and legislation_code = 'FR'
       and business_group_id is null;
     --
     If p_abs_information7 < l_adoption_spouse_min_leave And p_abs_information7 <> 0  Then
        hr_utility.set_message(801,'PAY_75046_ADPT_MIN_SPOUSE_LVE');
        hr_utility.set_message_token(801,'GLOBAL_VAL',l_adoption_spouse_min_leave);
        hr_utility.raise_error;
     End If;
     --

  End If;


  --
end PERSON_ABSENCE_CREATE;
--
--
procedure PERSON_ABSENCE_UPDATE(
         p_absence_attendance_id    IN Number
        ,p_abs_information_category IN varchar2
        ,p_date_start               IN Date
        ,p_date_end                 IN Date
        ,p_abs_information1         IN Varchar2
        ,p_abs_information4         IN Varchar2
        ,p_abs_information5         IN Varchar2
        ,p_abs_information6         IN Varchar2
        ,p_abs_information7         IN Varchar2
        ,p_abs_information8         IN Varchar2
        ,p_abs_information9         IN Varchar2
        ,p_abs_information10        IN Varchar2
        ,p_abs_information11        IN Varchar2
        ,p_abs_information12        IN Varchar2
        ) IS

        l_person_id             number;
        l_proc			varchar2(200) := g_package||'person_absence_update';
        --
        cursor get_person_id(p_absence_attendance_id in number) is
        select person_id
        from   per_absence_attendances
        where  absence_attendance_id =p_absence_attendance_id;
        --
begin
 --
 /* Added for GSI Bug 5472781 */
 IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'FR') THEN
    hr_utility.set_location('Leaving : '||l_proc , 10);
    return;
 END IF;
 --
 open get_person_id(p_absence_attendance_id);
 fetch get_person_id into l_person_id;
 -- get the values of the person_id profile
 fnd_profile.put('HR_FR_PERSON_ID',l_person_id);
 close get_person_id;
 -- get the value of the absence_start_date
 fnd_profile.put('HR_FR_ABSENCE_START_DATE',to_char(p_date_start,'DD-MON-YYYY'));


 If p_abs_information_category = 'FR_S' then


            --
            IF p_abs_information1 IS NOT NULL THEN
                -- Current absence is Child absence
                IF (p_abs_information9 IS NOT NULL
                    OR p_abs_information10 IS NOT NULL
                    OR p_abs_information11 IS NOT NULL
                    OR p_abs_information12 IS NOT NULL) THEN
                   hr_utility.set_message(801,'PAY_75030_INV_ELIGIBILITY_SEG');
                   hr_utility.raise_error;
                END IF;
                -- #3040003
                IF (p_abs_information7 IS NOT NULL) THEN --IJSS Inelig dt
                  hr_utility.set_message(801,'PAY_75079_INV_IJSS_INELIG_DT');
                  hr_utility.raise_error;
                END IF;

                --
            END IF;
            --

 ElsIf p_abs_information_category = 'FR_M'  Then

      If p_abs_information1 Is Not Null
        And  --Child Absence
          (p_abs_information4 Is Not Null
            Or p_abs_information5 Is Not Null
            Or p_abs_information6 Is Not Null
            Or p_abs_information7 Is Not Null
            Or p_abs_information8 Is Not Null
            Or p_abs_information9 Is Not Null) Then

         hr_utility.set_message(801,'PAY_75044_INV_MATERNITY_SEG');
         hr_utility.raise_error;

      End If;

      --
      If (fnd_date.canonical_to_date(p_abs_information4) < p_date_start or
         fnd_date.canonical_to_date(p_abs_information4)  > p_date_end ) Then

         hr_utility.set_message(801,'PAY_75045_INV_MAT_CONFINE_DATE');
         hr_utility.raise_error;

      End If;
      --

 ElsIf p_abs_information_category = 'FR_FR_ADOPTION' Then
      --
      select global_value
      Into l_adoption_spouse_min_leave
      from ff_globals_f
      where global_name ='FR_ADOPTION_SPOUSE_MIN_LEAVE'
        and legislation_code = 'FR'
        and business_group_id is null;
      --
      If p_abs_information7 < l_adoption_spouse_min_leave  And p_abs_information7 <> 0 Then
         hr_utility.set_message(801,'PAY_75046_ADPT_MIN_SPOUSE_LVE');
         hr_utility.set_message_token(801,'GLOBAL_VAL',l_adoption_spouse_min_leave);
         hr_utility.raise_error;
      End If;
     --

 End If;

 --
end PERSON_ABSENCE_UPDATE;
--
--
procedure PERSON_ENTRY_CREATE(
         p_business_group_id            IN Number
        ,p_absence_attendance_id        IN Number
        ,p_abs_information_category     IN Varchar2
        ,p_date_start                   IN Date
        ) IS

l_proc		       VARCHAR2(200) := g_package ||'person_entry_create';
l_element_entry_id     NUMBER;
l_effective_start_date DATE;
l_effective_end_date   DATE;
l_ovn                  NUMBER;
l_sub                  NUMBER;
l_o_start_dt            DATE;
l_o_end_dt              DATE;
l_o_warning             BOOLEAN;

BEGIN
  --
  /* Added for GSI Bug 5472781 */
  IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'FR') THEN
     hr_utility.set_location('Leaving : '||l_proc , 10);
     return;
  END IF;
  --
  hr_utility.set_location('Entering hook Person_entry_Create',10);
  If p_abs_information_category = 'FR_S' then
    hr_utility.set_location(' IN Create User hook ',20);
    HR_PERSON_ABSENCE_API.get_absence_element
     (p_absence_attendance_id   => p_absence_attendance_id
     ,p_element_entry_id        => l_element_entry_id
     ,p_effective_start_date    => l_effective_start_date
     ,p_effective_end_date      => l_effective_end_date);
    hr_utility.set_location(' IN Create, setting subpriority for entry_id='||l_element_entry_id,30);

    SELECT max(object_version_number) INTO l_ovn
      FROM pay_element_entries_f
      WHERE element_entry_id = l_element_entry_id;

    SELECT to_number(substr(to_char(p_date_start,'J'),4,4)) INTO l_sub
      FROM dual;

    hr_utility.set_location(' IN Create, sub='||l_sub||' ovn='||l_ovn,30);

    PAY_ELEMENT_ENTRY_API.update_element_entry
     (p_validate                => FALSE
     ,p_datetrack_update_mode   => 'CORRECTION'
     ,p_effective_date          => l_effective_start_date
     ,p_business_group_id       => p_business_group_id
     ,p_element_entry_id        => l_element_entry_id
     ,p_object_version_number   => l_ovn
     ,p_subpriority             => l_sub
     ,p_effective_start_date    => l_o_start_dt
     ,p_effective_end_date      => l_o_end_dt
     ,p_update_warning          => l_o_warning);


   END IF;
   hr_utility.set_location('Leaving hook Person_entry_Create',90);
END PERSON_ENTRY_CREATE;
--
procedure PERSON_ENTRY_UPDATE(
         p_absence_attendance_id        IN Number
        ,p_abs_information_category     IN Varchar2
        ,p_date_start                   IN Date
        ) IS
l_proc		        VARCHAR2(200) := g_package ||'person_entry_update';
l_element_entry_id      NUMBER;
l_effective_start_date  DATE;
l_effective_end_date    DATE;
l_ovn                   NUMBER;
l_sub                   NUMBER;
l_o_start_dt            DATE;
l_o_end_dt              DATE;
l_o_warning             BOOLEAN;
l_bus_grp_id            NUMBER;

BEGIN
  --
  /* Added for GSI Bug 5472781 */
  IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'FR') THEN
     hr_utility.set_location('Leaving : '||l_proc , 10);
     return;
  END IF;
  --
  hr_utility.set_location('Entering hook Person_entry_Update',10);
  If p_abs_information_category = 'FR_S' then
    hr_utility.set_location(' IN Update User hook ',20);
    HR_PERSON_ABSENCE_API.get_absence_element
     (p_absence_attendance_id   => p_absence_attendance_id
     ,p_element_entry_id        => l_element_entry_id
     ,p_effective_start_date    => l_effective_start_date
     ,p_effective_end_date      => l_effective_end_date);
    hr_utility.set_location(' IN Update, setting subpriority for entry_id='||l_element_entry_id,30);

    SELECT max(object_version_number) INTO l_ovn
      FROM pay_element_entries_f
      WHERE element_entry_id = l_element_entry_id;

    select business_group_id INTO l_bus_grp_id
      from per_absence_attendances
     where absence_attendance_id = p_absence_attendance_id;

    SELECT to_number(substr(to_char(p_date_start,'J'),4,4)) INTO l_sub
      FROM dual;

    hr_utility.set_location(' IN Update, sub='||l_sub||' ovn='||l_ovn,30);

    PAY_ELEMENT_ENTRY_API.update_element_entry
     (p_validate                => FALSE
     ,p_datetrack_update_mode   => 'CORRECTION'
     ,p_effective_date          => l_effective_start_date
     ,p_business_group_id       => l_bus_grp_id
     ,p_element_entry_id        => l_element_entry_id
     ,p_object_version_number   => l_ovn
     ,p_subpriority             => l_sub
     ,p_effective_start_date    => l_o_start_dt
     ,p_effective_end_date      => l_o_end_dt
     ,p_update_warning          => l_o_warning);



   END IF;
   hr_utility.set_location('Leaving hook Person_entry_Update',90);
END PERSON_ENTRY_UPDATE;
--
-- procedure added for checking additional holiday entitlements
PROCEDURE CHECK_ADD_ABS_ENT_CREATE(p_absence_days               in  number,
                                   p_absence_attendance_type_id in  number,
                                   p_date_start                 in  date,
                                   p_person_id                  in  number)
IS
-- Cursor to find the accrual plan id
-- and absence type
Cursor csr_get_accrual_plan is
Select pap.accrual_plan_id, pabt.absence_category
from pay_accrual_plans pap,
     per_absence_attendance_types pabt
where pabt.absence_attendance_type_id = p_absence_attendance_type_id
  and pap.pto_input_value_id= pabt.input_value_id;
--
-- Defining cursor to get existing entitlements
-- Modified cursor to check for element entry dates
-- instead of value of 'Accrual Date'
cursor csr_get_ent(
               c_type_m_iv_id number
              ,c_start_date date
              ,c_end_date date) is
       select  nvl(sum(pevm.screen_entry_value),0)
       from    pay_element_entry_values_f pevm
              ,pay_element_entries_f      pee
              ,per_all_assignments_f      pasg
       where   pevm.input_value_id = c_type_m_iv_id
       and     pee.element_entry_id = pevm.element_entry_id
       and     pevm.effective_start_date between c_start_date and c_end_date
       and     pee.effective_start_date between c_start_date and c_end_date
       and     pee.assignment_id = pasg.assignment_id
       and     pasg.person_id = p_person_id;
--
-- Defining cursor selecting hiredate
Cursor csr_assg_hiredate(c_person_id number) is
Select max(ppos.date_start)
From per_periods_of_service ppos
Where ppos.person_id   = c_person_id
  And ppos.date_start <= p_date_start;
--
-- Cursor to sum up existing absences against entitled holidays
Cursor csr_exist_abs(p_from_date date) is
Select sum(date_end-date_start+1)
from per_absence_attendances
where person_id = p_person_id
and date_end < p_date_start
and date_start >= p_from_date
and absence_attendance_type_id = p_absence_attendance_type_id;
--
l_fr_plan_info pay_fr_pto_pkg.g_fr_plan_info;
l_accrual_plan_id number;
l_absence_type varchar2(30);
l_ent_m number :=0;
l_hiredate date;
l_exist_absence number;
l_net_entitlement number;
l_proc		  varchar2(200) := g_package ||'check_add_abs_ent_create';
--
--
begin
 --
 /* Added for GSI Bug 5472781 */
 IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'FR') THEN
    hr_utility.set_location('Leaving : '|| l_proc , 22);
    return;
 END IF;
 --

  hr_utility.set_location('Entering entilement check user hook', 22);
  -- Get accrual plan details
  open csr_get_accrual_plan;
  fetch csr_get_accrual_plan into l_accrual_plan_id,l_absence_type;
  close csr_get_accrual_plan;
  hr_utility.set_location('Absence type is : '||l_absence_type,22);
  --
  IF l_absence_type = 'FR_ADDITIONAL_HOLIDAY' THEN
     l_fr_plan_info := pay_fr_pto_pkg.get_fr_accrual_plan_info(
                     p_accrual_plan_id          => l_accrual_plan_id
                    ,p_accrual_date             => p_date_start );
     -- Get the hire date
     -- to get the date range for checking absence
     open csr_assg_hiredate(p_person_id);
     fetch csr_assg_hiredate into l_hiredate;
     close csr_assg_hiredate;
     -- Calculate the sum of total entitlements created for this accrual plan
     -- within the hire date and absence start date
     -- Modified cursor call for parameters passed
     open csr_get_ent(l_fr_plan_info.ent_m_iv_id,
                          l_hiredate,
                          p_date_start);
     fetch csr_get_ent into l_ent_m;
     close csr_get_ent;
     hr_utility.set_location('total entitlements are :'||l_ent_m, 22);
     -- Check for sum of existing absences against additional entitlements
     open csr_exist_abs(l_hiredate);
     fetch csr_exist_abs into l_exist_absence;
     close csr_exist_abs;
     IF l_exist_absence IS NULL THEN
        l_exist_absence := 0;
     END IF;
     hr_utility.set_location('Total absences are : '||l_exist_absence, 22);
     --
     l_net_entitlement := l_ent_m - l_exist_absence - p_absence_days;
     hr_utility.set_location('Net entitlements are : '||l_net_entitlement, 22);
     IF l_net_entitlement <0 THEN
        -- fnd_message.set_name('PER','HR_EMP_NOT_ENTITLED');
        -- replaced by a different function and message
        hr_utility.set_message(801,'PAY_75197_ADD_ENT_EXCEED');
        hr_utility.raise_error;
	--
     END IF;
     --
   END IF;-- check for absence type
   hr_utility.set_location('Leaving entilement check user hook', 22);
 END CHECK_ADD_ABS_ENT_CREATE;
 --
 PROCEDURE CHECK_ADD_ABS_ENT_UPDATE(p_absence_days               in  number,
                                    p_absence_attendance_id      in  number,
                                    p_date_start                 in  date)
 IS
 --
 -- Cursor to find the accrual plan id
 -- and absence type
 Cursor csr_get_accrual_plan is
 Select pap.accrual_plan_id,
        pabt.absence_category,
        pabs.person_id,
        pabt.absence_attendance_type_id
 from pay_accrual_plans pap,
      per_absence_attendance_types pabt,
      per_absence_attendances pabs
 where pabs.absence_attendance_id = p_absence_attendance_id
   and pabt.absence_attendance_type_id = pabs.absence_attendance_type_id
   and pap.pto_input_value_id= pabt.input_value_id;
 --
 -- Defining cursor to get existing entitlements
 -- Modfied cursor to check for element entry date
 -- instead of value of 'Accrual Date'
 cursor csr_get_ent(
                c_type_m_iv_id number
               ,c_start_date date
               ,c_end_date date
               ,c_person_id number) is
        select  nvl(sum(pevm.screen_entry_value),0)
        from    pay_element_entry_values_f pevm
               ,pay_element_entries_f      pee
               ,per_all_assignments_f      pasg
        where   pevm.input_value_id = c_type_m_iv_id
        and     pee.element_entry_id = pevm.element_entry_id
        and     pevm.effective_start_date between c_start_date and c_end_date
        and     pee.effective_start_date between c_start_date and c_end_date
        and     pee.assignment_id = pasg.assignment_id
        and     pasg.person_id = c_person_id;
 --
 -- Defining cursor selecting hiredate
 Cursor csr_assg_hiredate(c_person_id number) is
 Select max(ppos.date_start)
 From per_periods_of_service ppos
 Where ppos.person_id   = c_person_id
   And ppos.date_start <= p_date_start;
 --
 -- Cursor to sum up existing absences against entitled holidays
 Cursor csr_exist_abs(p_person_id                  number,
                      p_absence_attendance_type_id number,
                      p_from_date                  date) is
 Select sum(date_end-date_start+1)
 from per_absence_attendances
 where person_id = p_person_id
 and date_end < p_date_start
 and date_start >= p_from_date
 and absence_attendance_type_id = p_absence_attendance_type_id;
 --
 l_fr_plan_info pay_fr_pto_pkg.g_fr_plan_info;
 l_accrual_plan_id number;
 l_absence_type varchar2(30);
 l_person_id number;
 l_absence_attendance_type_id number;
 l_ent_m number :=0;
 l_hiredate date;
 l_exist_absence number;
 l_net_entitlement number;
 l_proc		   varchar2(200) := g_package ||'check_add_abs_ent_update';
 --
 --
 begin
   --
   /* Added for GSI Bug 5472781 */
   IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'FR') THEN
      hr_utility.set_location('Leaving : '|| l_proc , 22);
      return;
   END IF;
   --
   hr_utility.set_location('Entering entilement update user hook', 22);
   -- Get accrual plan details
   open csr_get_accrual_plan;
   fetch csr_get_accrual_plan into l_accrual_plan_id,l_absence_type, l_person_id, l_absence_attendance_type_id;
   close csr_get_accrual_plan;
   hr_utility.set_location('Absence type is : '||l_absence_type, 22);
   --
   IF l_absence_type = 'FR_ADDITIONAL_HOLIDAY' THEN
      hr_utility.set_location('Absence is additional type', 22);
      hr_utility.set_location('Plan id is : '||to_char(l_accrual_plan_id),22);
      hr_utility.set_location('Accrual Date is : '||to_char(p_date_start),22);
      l_fr_plan_info := pay_fr_pto_pkg.get_fr_accrual_plan_info(
                      p_accrual_plan_id          => l_accrual_plan_id
                     ,p_accrual_date             => p_date_start );
      -- Get the hire date
      -- to get the date range for checking absence
      open csr_assg_hiredate(l_person_id);
      fetch csr_assg_hiredate into l_hiredate;
      close csr_assg_hiredate;
      hr_utility.set_location('Hiredate is : '||to_char(l_hiredate),22);
      -- Calculate the sum of total entitlements created for this accrual plan
      -- within the hire date and absence start date
      hr_utility.set_location('Entilements input id is : '||to_char(l_fr_plan_info.ent_m_iv_id),22);
      hr_utility.set_location('Accrual date input id is  : '||to_char(l_fr_plan_info.ent_accrual_date_iv_id), 22);
      -- modified cursor call
      open csr_get_ent(l_fr_plan_info.ent_m_iv_id,
                           l_hiredate,
                           p_date_start,
                           l_person_id);
      fetch csr_get_ent into l_ent_m;
      close csr_get_ent;
      hr_utility.set_location('total entitlements are :'||l_ent_m, 22);
      -- Check for sum of existing absences against additional entitlements
      open csr_exist_abs(l_person_id,l_absence_attendance_type_id,l_hiredate);
      fetch csr_exist_abs into l_exist_absence;
      close csr_exist_abs;
      IF l_exist_absence IS NULL THEN
         l_exist_absence := 0;
      END IF;
      hr_utility.set_location('Total absences are : '||l_exist_absence, 22);
      --
      l_net_entitlement := l_ent_m - l_exist_absence - p_absence_days;
      hr_utility.set_location('Net entitlements are : '||l_net_entitlement, 22);
      IF l_net_entitlement <0 THEN
         -- fnd_message.set_name('PER','HR_EMP_NOT_ENTITLED');
         -- replaced by a different function and message
         hr_utility.set_message(801,'PAY_75197_ADD_ENT_EXCEED');
         hr_utility.raise_error;
 	--
      END IF;
      --
   END IF;-- check for absence type
   hr_utility.set_location('Leaving entilement update user hook', 22);
 --
 END CHECK_ADD_ABS_ENT_UPDATE;


 PROCEDURE CHK_TRG_CATG_HRS(
         p_abs_information_category     IN varchar2
        ,p_abs_information1             IN Varchar2
        -- added for bug#4104220
        ,p_abs_information5             IN Varchar2
        ,p_abs_information6             IN Varchar2
        ,p_abs_information7             IN Varchar2
        ,p_abs_information8             IN Varchar2
        ,p_abs_information9             IN Varchar2
        ,p_abs_information10            IN Varchar2
        ,p_abs_information11            IN Varchar2
        ,p_abs_information12            IN Varchar2
        ,p_abs_information13            IN Varchar2
        ,p_abs_information14            IN Varchar2
        ,p_abs_information15            IN Varchar2
        ,p_abs_information16            IN Varchar2
        ,p_abs_information18            IN Varchar2
        ,p_abs_information19            IN Varchar2
        --
        ,p_abs_information20            IN Varchar2
        -- Added for bug 5218081
        ,p_abs_information21            IN Varchar2
        ,p_abs_information22            IN Varchar2
        -- added for validating leave category
        ,p_date_start                   IN Date)
IS
--
l_value_end_date date;
l_proc		 varchar2(200) := g_package ||'chk_trg_catg_hrs';
--
Cursor csr_lookup_end is
Select end_date_active
from hr_lookups
where lookup_type = 'FR_TRAINING_LEAVE_CATEGORY'
and lookup_code = 'TRAINING_CREDIT';
--
BEGIN
--
/* Added for GSI Bug 5472781 */
IF NOT hr_utility.chk_product_install('Oracle Human Resources', 'FR') THEN
   hr_utility.set_location('Leaving : '|| l_proc , 10);
   return;
END IF;
--
IF p_abs_information_category = 'FR_TRAINING_ABSENCE' THEN
    IF p_abs_information1 NOT IN ('OTHER', 'PP')
       AND p_abs_information20 IS NOT NULL THEN
           -- raise error
              hr_utility.set_message(800,'PER_75093_TRG_CATG_OUT_HRS');
              hr_utility.raise_error;
     END IF;
     -- added for bug#4104220
     IF p_abs_information18 = 'Y' THEN
        IF p_abs_information19 IS NOT NULL
           OR (p_abs_information20 IS NOT NULL
           AND fnd_number.canonical_to_number(p_abs_information20)<>0)
           OR p_abs_information5 IS NOT NULL
           OR p_abs_information6 IS NOT NULL
           OR p_abs_information7 IS NOT NULL
           OR p_abs_information8 IS NOT NULL
           OR (p_abs_information9 IS NOT NULL
           AND fnd_number.canonical_to_number(p_abs_information9)<>0)
           OR (p_abs_information10 IS NOT NULL
           AND fnd_number.canonical_to_number(p_abs_information10)<>0)
           OR (p_abs_information11 IS NOT NULL
           AND fnd_number.canonical_to_number(p_abs_information11)<>0)
           OR (p_abs_information12 IS NOT NULL
           AND fnd_number.canonical_to_number(p_abs_information12)<>0)
           OR (p_abs_information13 IS NOT NULL
           AND fnd_number.canonical_to_number(p_abs_information13)<>0)
           OR (p_abs_information14 IS NOT NULL
           AND fnd_number.canonical_to_number(p_abs_information14)<>0)
           OR (p_abs_information15 IS NOT NULL
           AND fnd_number.canonical_to_number(p_abs_information15)<>0)
           OR (p_abs_information16 IS NOT NULL
           AND fnd_number.canonical_to_number(p_abs_information16)<>0)
           OR (p_abs_information21 IS NOT NULL
           AND fnd_number.canonical_to_number(p_abs_information21)<>0)
           OR (p_abs_information22 IS NOT NULL
           AND fnd_number.canonical_to_number(p_abs_information22)<>0)
        THEN
           -- raise an error
           hr_utility.set_message(800,'PER_75097_DIF_TRG_PLAN');
           hr_utility.raise_error;
        END IF;
     END IF;
     -- added for validating leave category
     IF p_abs_information1 = 'TRAINING_CREDIT' THEN
        OPEN csr_lookup_end;
        FETCH csr_lookup_end INTO l_value_end_date;
        CLOSE csr_lookup_end;
        --
        IF p_date_start is not null
          AND p_date_start > l_value_end_date THEN
          -- raise error
          hr_utility.set_message(800,'PER_75098_TRG_CATG_END_DATE');
          hr_utility.raise_error;
          --
        END IF;
     END IF;
END IF;
end;

 --
end PAY_FR_SICKNESS_ABSENCE;

/
