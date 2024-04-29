--------------------------------------------------------
--  DDL for Package Body PER_ABSENCE_ATTENDANCES_PKG3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ABSENCE_ATTENDANCES_PKG3" as
/* $Header: peaba03t.pkb 120.0 2005/05/31 04:40:30 appldev noship $ */
--
/*
   NAME
     peaba03t.pkb -- procedure   Absence API
--
   DESCRIPTION
   This package is used as an interface between the PayMIX form and the
   Absence api.
--
  MODIFIED       (DD-MON-YYYY)  COMMENT
  btailor	  28-Jun-95	Created
  rfine	   70.3	  12-Jul-95	Populated the notification date with the
				session date - it's used to select a single
				row from datetracked join tables in the
				base view for PERWSEAD, so should not be left
				NULL.
  rfine	   70.5	  23-Nov-95	Added new SSP-related args to call to
				per_absence_attendances_pkg.insert_row. They
				are defined as DEFAULTs, which means they
				shouldn't really be necessary, but they appear
				to be.
  ctredwin 110.2  16-Aug-99     Bug 953648. Handle null value from cursor
                                when fetching occurrence number during
                                insert.
  ctredwin 110.3  01-Oct-99     Added insert_abs_for_bee,
                                insert_validate_for_bee, and validation
                                procedures.
  ctredwin 115.5  07-Feb-00     Bug 1184545. Use derived start and end times
                                in validation.
  ctredwin 115.6  24-Jul-99     Bug 1337672. Altered message name in check
                                duration procedure.
  dcasemor 115.7  28-Aug-01     Bug 1668275. Replaced the table handler call
                                'insert_row' with the create absence API.
                                This was only changed for insert_abs_for_bee
                                because paymix is no longer used in 11i.
  dcasemor 115.8  21-Dec-01     Passed out nocopy an additional warning to indicate
                                that the absence API has already created the
                                element entry.
  dcasemor 115.9  28-Dec-01     Added check_dates_entered procedure.
  dcasemor 115.10 21-May-02     Bug 2377104. Passed p_create_element_entry
                                to the absence API as false so that BEE
                                creates the element entries. Warnings of
                                EE_CREATED_BY_ABSENCE are no longer passed
                                back to BEE (so it always creates the EE).
  dcasemor 115.11 14-Aug-02     GSCC compliance - added WHENEVER OSERROR...
  adudekul 115.13 18-FEB-04     Bug 3307340. Modified procedure INSER_VALIDATE_FOR_BEE
                                to treat the errors as warnings which are raised
                                for sickness overlap.
  kjagadee 115.14 23-FEB-04     Added overloaded proc for insert_abs_for_bee
  kjagadee 115.15 05-APR-04     Bug 3506133, Modified procedure insert_abs_for_bee
                                (one which is called from BEE)
                                Added new private proc insert_absence_element.
                                Added package variable g_package.
  kjagadee 115.16 19-MAY-04     Bug 3626565, Modified CHK_ABSENCE_INPUT to relax
                                the input validation, so that user can enter
                                negative absence duration through BEE.
  SuSivasu 115.17 20-Aug-04     Bug 3812684. Assed support for sickness start and
                                end date for UK's sickness attendance types.
  smparame 115.18 05-Oct-04     Bug 3900409. Replaced call to hr_cal_abs_dur_pkg.
                                calculate_absence_duration in check_duration with
                                per_abs_bus.calculate_absence_duration.

*/
--
-- Package Variables
--
g_package  varchar2(33) := ' per_absence_attendances_pkg3.';
--
procedure check_dates_entered(p_date_end      In  DATE,
                              p_absence_days  In  NUMBER,
                              p_absence_hours In  NUMBER,
                              p_message       out nocopy VARCHAR2) is

l_message varchar2(30) := null;

begin
--
  IF p_date_end is null and
    (p_absence_days is not null or p_absence_hours is not null) THEN

    l_message := 'PER_7714_ABS_CALC_DURATION';

  END IF;

  p_message := l_message;

--
end check_dates_entered;


procedure check_absence_dates(p_date_start   In DATE,
                              p_date_end     In DATE,
                              p_message      out nocopy VARCHAR2) is

l_message varchar2(30) := null;

begin
--
  IF p_date_start > p_date_end THEN
  --
    l_message := 'PAY_7616_EMP_ABS_DATE_AFTER';
  --
  END IF;

  p_message := l_message;
--
end check_absence_dates;

procedure check_absence_type(p_abs_type_id In NUMBER,
                             p_date_start  IN DATE,
                             p_eot         IN DATE,
                             p_date_end    IN DATE,
                             p_message     OUT NOCOPY VARCHAR2) is

l_exists VARCHAR2(1);
l_message VARCHAR2(30) := null;

cursor c5 is
select 'x'
from   per_absence_attendance_types
where  absence_attendance_type_id = p_abs_type_id
and    date_effective <= p_date_start
and    (nvl(date_end,p_eot) >= p_date_end or
        p_date_end is null);
--
begin
--
  open c5;
  --
  fetch c5 into l_exists;

  IF c5%notfound THEN
  --
    l_message := 'HR_6847_ABS_DET_RANGE_CHECK';
  --
  END IF;
  --
  close c5;
  p_message := l_message;
--
end check_absence_type;

procedure check_duration(p_date_start        in date,
                         p_date_end          in date,
                         p_time_start        in varchar2,
                         p_time_end          in varchar2,
                         p_business_group_id in number,
                         p_session_date      in date,
                         p_assignment_id     in number,
                         p_person_id         in number, -- Bug 3900409
                         p_absence_days      in number,
                         p_absence_hours     in number,
                         p_abs_type_id       in number,
                         p_error             out nocopy varchar2,
                         p_warning           out nocopy varchar2) is

l_use_formula      boolean;
l_duration         number;
l_invalid_message  varchar2(240);
l_element_type_id  number;
l_legislation_code varchar2(30);
l_days_or_hours    varchar2(30);
l_hours_default    number;
l_days_in_hours    number;
l_days_default     number;
l_warning          varchar2(30) := null;
l_error            varchar2(30) := null;
l_absence_days         number;
l_absence_hours        number;

cursor c1 is
select piv.element_type_id,
       abt.hours_or_days
from   per_absence_attendance_types abt,
       pay_input_values_f piv
where  abt.absence_attendance_type_id = p_abs_type_id
and    abt.input_value_id = piv.input_value_id
and    p_date_start between piv.effective_start_date
                    and     piv.effective_end_date;

cursor c2 is
select legislation_code
from per_business_groups
where business_group_id = p_business_group_id;


begin

  open c1;
  fetch c1 into l_element_type_id, l_days_or_hours;
  close c1;

  open c2;
  fetch c2 into l_legislation_code;
  close c2;

  -- bug fix 3900409.
  -- Replace the call with per_abs_bus.calculate_absence_duration.

  /*hr_cal_abs_dur_pkg.calculate_absence_duration (
  p_days_or_hours     => l_days_or_hours,
  p_date_start        => p_date_start,
  p_date_end          => p_date_end,
  p_time_start        => null,
  p_time_end          => null,
  p_business_group_id => p_business_group_id,
  p_legislation_code  => l_legislation_code,
  p_session_date      => p_session_date,
  p_assignment_id     => p_assignment_id,
  p_element_type_id   => l_element_type_id,
  p_invalid_message   => l_invalid_message,
  p_duration          => l_duration,
  p_use_formula       => l_use_formula
  );*/

  per_abs_bus.calculate_absence_duration
       (p_absence_attendance_id      => NULL
       ,p_absence_attendance_type_id => p_abs_type_id
       ,p_business_group_id          => p_business_group_id
       ,p_object_version_number      => NULL
       ,p_effective_date             => p_session_date
       ,p_person_id                  => p_person_id
       ,p_date_start                 => p_date_start
       ,p_date_end                   => p_date_end
       ,p_time_start                 => p_time_start
       ,p_time_end                   => p_time_end
       ,p_absence_days               => l_absence_days
       ,p_absence_hours              => l_absence_hours
       ,p_use_formula                => l_use_formula);

  if l_use_formula then
  --
    /*if nvl(p_absence_days, p_absence_hours) <> l_duration then
    --
      l_warning := 'HR_EMP_ABS_DURATION_FORMULA';
    --
    end if;*/
    if ( l_days_or_hours = 'H' and p_absence_hours <> l_absence_hours )
       OR ( l_days_or_hours = 'D' and p_absence_days  <> l_absence_days )then

        l_warning := 'HR_EMP_ABS_DURATION_FORMULA';
    end if;
  --
  else
  --

    per_absence_attendances_pkg.get_defaults(p_time_end,
                                             p_time_start,
                                             p_date_end,
                                             p_date_start,
                                             l_hours_default,
                                             l_days_in_hours,
                                             l_days_default);

    if l_days_or_hours = 'D' then
    --
      if l_days_default > p_absence_days then
      --
        l_warning := 'HR_EMP_ABS_SHORT_DURATION';
      --
      elsif l_days_default < p_absence_days then
      --
        l_error := 'PER_7622_EMP_ABS_LONG_DURATION';
      --
      end if;
    --
    elsif l_days_or_hours = 'H' then
    --
      if nvl(l_hours_default, l_days_in_hours) > p_absence_hours then
      --
        l_warning := 'HR_EMP_ABS_SHORT_DURATION';
      --
      elsif nvl(l_hours_default, l_days_in_hours) < p_absence_hours then
      --
        l_error := 'PER_7623_EMP_ABS_LONG_DURATION';
      --
      end if;
    --
    end if;
  --
  end if;

  p_warning := l_warning;
  p_error := l_error;

end check_duration;

procedure check_sickness_overlap(p_person_id   IN NUMBER,
                                 p_abs_type_id IN NUMBER,
                                 p_date_start  IN DATE,
                                 p_date_end    IN DATE,
                                 p_eot         IN DATE,
                                 p_message1    OUT NOCOPY VARCHAR2,
                                 p_message2    OUT NOCOPY VARCHAR2) is

l_exists VARCHAR2(1);
l_exists2 VARCHAR2(1);

cursor c1 is
select 'x'
from per_absence_attendances t,
     per_absence_attendance_types a,
     per_absence_attendance_types b
where t.person_id = p_person_id
and   p_abs_type_id = a.absence_attendance_type_id
and   t.absence_attendance_type_id = b.absence_attendance_type_id
and   a.absence_category = 'S'
and   b.absence_category = 'S'
and   p_date_end is null
and   t.date_end is null;
--
cursor c2 is
select 'x'
from per_absence_attendances t,
     per_absence_attendance_types a,
     per_absence_attendance_types b
where t.person_id = p_person_id
and   p_abs_type_id = b.absence_attendance_type_id
and   t.absence_attendance_type_id = a.absence_attendance_type_id
and   a.absence_category = 'S'
and   b.absence_category = 'S'
and   ((p_date_start between t.date_start and nvl(t.date_end,p_eot))
or    (t.date_start between p_date_start and nvl(p_date_end,p_eot)));
--
begin
--
  open c1;
  fetch c1 into l_exists;

  IF c1%found THEN
  --
    p_message1 := 'SSP_35217_DEF_ONLY_ONE_ABS';
  --
  END IF;
  --
  close c1;

  open c2;
  fetch c2 into l_exists2;

  IF c2%found THEN
  --
    p_message2 := 'SSP_35216_DEF_OVERLAP_ABS';
  --
  END IF;

  close c2;
--
end check_sickness_overlap;
--
-- ----------------------------------------------------------------------------
-- |----------------------< insert_absence_element >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure insert_absence_element(
   p_line_record           in     pay_batch_lines%Rowtype,
   p_asg_act_id            in     number,
   p_absence_attendance_id in     number,
   p_absence_att_type_id   in     number,
   p_entry_values_count    in     number,
   p_date_start            in     date,
   p_date_end              in     date,
   p_passed_inp_tbl        in     hr_entry.number_table,
   p_passed_val_tbl        in     hr_entry.varchar2_table
   ) is
   --
   l_proc                  varchar2(72) := g_package||'insert_absence_element';
   -- Local variables
   l_effective_end_date    date;
   l_effective_start_date  date := p_line_record.effective_date;
   l_count                 number := 1;
   l_entry_value           number;
   l_element_type_id       number;
   l_input_value_id        number;
   l_reason                hr_lookups.lookup_code%Type;
   l_processing_type       pay_element_types_f.processing_type%Type;
   l_element_link_id       pay_element_links_f.element_link_id%Type;
   l_element_entry_id      pay_element_entries_f.element_entry_id%Type;
   l_passed_inp_tbl        hr_entry.number_table;
   l_passed_val_tbl        hr_entry.varchar2_table;
   -- Cursor to pickup the lookup code
   cursor csr_lookup_code(p_meaning hr_lookups.meaning%Type) is
          select hl.lookup_code
            from hr_lookups hl
           where hl.lookup_type = 'ELE_ENTRY_REASON'
             and hl.meaning = p_meaning;
   --
begin
   --
   hr_utility.set_location('Entering:'|| l_proc, 10);
   --
   -- Insert the absence element element. First we check if the
   -- absence type is linked to an element type.
   if hr_person_absence_api.linked_to_element(
                p_absence_attendance_id => p_absence_attendance_id) then
      --
      hr_utility.set_location(l_proc, 20);
      -- Getting the processing type of the absence element
      l_processing_type := hr_person_absence_api.get_processing_type(
                p_absence_attendance_type_id => p_absence_att_type_id);
      --
      if (l_processing_type = 'N' and p_date_start is not null
         and p_date_end is not null) or
         (l_processing_type = 'R' and p_date_start is not null) then
         --
         hr_utility.set_location(l_proc, 30);
         -- Getting the element details
         hr_person_absence_api.get_element_details(
                p_absence_attendance_id => p_absence_attendance_id,
                p_element_type_id       => l_element_type_id,
                p_input_value_id        => l_input_value_id,
                p_entry_value           => l_entry_value);
         -- Checking element link
         hr_utility.set_location(l_proc, 40);
         --
         l_element_link_id := hr_entry_api.get_link(
                p_assignment_id         => p_line_record.assignment_id,
                p_element_type_id       => l_element_type_id,
                p_session_date          => p_date_start);
         --
         if l_element_link_id is null then
            -- Assignment is not eligible for the element type
            -- associated with this absence.
            hr_utility.set_message(801,'HR_7448_ELE_PER_NOT_ELIGIBLE');
            hr_utility.raise_error;
            --
         end if;
         -- We know the assignment is eligible for this element because
         -- we have the element_link_id. The entries API will handle
         -- all other validation (e.g., non-recurring entries must
         -- have a valid payroll).
         if p_line_record.reason is not null then
            --
            open csr_lookup_code(p_line_record.reason);
            fetch csr_lookup_code into l_reason;
            close csr_lookup_code;
            --
         end if;
         --
         for i in 1..p_entry_values_count loop
            --
            if p_passed_val_tbl.exists(i)
               and p_passed_val_tbl(i) is not null then
               --
               l_passed_inp_tbl(l_count) := p_passed_inp_tbl(i);
               l_passed_val_tbl(l_count) := p_passed_val_tbl(i);
               l_count := l_count + 1;
               --
            end if;
            --
         end loop;
         --
         hr_utility.set_location(l_proc, 50);
         --
         l_count := l_passed_val_tbl.count;
         --
         -- Calling the API to create EE
         hr_entry_api.insert_element_entry(
         p_effective_start_date       => l_effective_start_date,
         p_effective_end_date         => l_effective_end_date,
         p_element_entry_id           => l_element_entry_id,
         p_assignment_id              => p_line_record.assignment_id,
         p_element_link_id            => l_element_link_id,
         p_creator_type               => 'A',
         p_creator_id                 => p_absence_attendance_id,
         p_entry_type                 => 'E',
         p_cost_allocation_keyflex_id => p_line_record.cost_allocation_keyflex_id,
         p_reason                     => l_reason,
         p_subpriority                => p_line_record.subpriority,
         p_date_earned                => p_line_record.date_earned,
         p_personal_payment_method_id => p_line_record.personal_payment_method_id,
         p_attribute_category         => p_line_record.attribute_category,
         p_attribute1                 => p_line_record.attribute1,
         p_attribute2                 => p_line_record.attribute2,
         p_attribute3                 => p_line_record.attribute3,
         p_attribute4                 => p_line_record.attribute4,
         p_attribute5                 => p_line_record.attribute5,
         p_attribute6                 => p_line_record.attribute6,
         p_attribute7                 => p_line_record.attribute7,
         p_attribute8                 => p_line_record.attribute8,
         p_attribute9                 => p_line_record.attribute9,
         p_attribute10                => p_line_record.attribute10,
         p_attribute11                => p_line_record.attribute11,
         p_attribute12                => p_line_record.attribute12,
         p_attribute13                => p_line_record.attribute13,
         p_attribute14                => p_line_record.attribute14,
         p_attribute15                => p_line_record.attribute15,
         p_attribute16                => p_line_record.attribute16,
         p_attribute17                => p_line_record.attribute17,
         p_attribute18                => p_line_record.attribute18,
         p_attribute19                => p_line_record.attribute19,
         p_attribute20                => p_line_record.attribute20,
         p_entry_information_category => p_line_record.entry_information_category,
         p_entry_information1         => p_line_record.entry_information1,
         p_entry_information2         => p_line_record.entry_information2,
         p_entry_information3         => p_line_record.entry_information3,
         p_entry_information4         => p_line_record.entry_information4,
         p_entry_information5         => p_line_record.entry_information5,
         p_entry_information6         => p_line_record.entry_information6,
         p_entry_information7         => p_line_record.entry_information7,
         p_entry_information8         => p_line_record.entry_information8,
         p_entry_information9         => p_line_record.entry_information9,
         p_entry_information10        => p_line_record.entry_information10,
         p_entry_information11        => p_line_record.entry_information11,
         p_entry_information12        => p_line_record.entry_information12,
         p_entry_information13        => p_line_record.entry_information13,
         p_entry_information14        => p_line_record.entry_information14,
         p_entry_information15        => p_line_record.entry_information15,
         p_entry_information16        => p_line_record.entry_information16,
         p_entry_information17        => p_line_record.entry_information17,
         p_entry_information18        => p_line_record.entry_information18,
         p_entry_information19        => p_line_record.entry_information19,
         p_entry_information20        => p_line_record.entry_information20,
         p_entry_information21        => p_line_record.entry_information21,
         p_entry_information22        => p_line_record.entry_information22,
         p_entry_information23        => p_line_record.entry_information23,
         p_entry_information24        => p_line_record.entry_information24,
         p_entry_information25        => p_line_record.entry_information25,
         p_entry_information26        => p_line_record.entry_information26,
         p_entry_information27        => p_line_record.entry_information27,
         p_entry_information28        => p_line_record.entry_information28,
         p_entry_information29        => p_line_record.entry_information29,
         p_entry_information30        => p_line_record.entry_information30,
         p_num_entry_values           => l_count,
         p_input_value_id_tbl         => l_passed_inp_tbl,
         p_entry_value_tbl            => l_passed_val_tbl);
         --
         hr_utility.set_location(l_proc, 60);
         -- Set the origin of the entry as the batch and its assignment action.
         update pay_element_entries_f
            set source_id = p_asg_act_id
          where element_entry_id = l_element_entry_id;
         -- Needs to end date the recurring Absence EE, if user has supplied an
         -- absence end date through batch line.
         if l_processing_type = 'R' and p_date_end is not null
            and l_element_entry_id is not null then
            --
            hr_utility.set_location(l_proc, 70);
            --
            hr_entry_api.delete_element_entry(
                   p_dt_delete_mode   => 'DELETE',
                   p_session_date     => p_date_end,
                   p_element_entry_id => l_element_entry_id);
            --
         end if;
      end if; -- End of procesing type and date check
   end if; -- End of absence type and element type link check
   --
   hr_utility.set_location(' Leaving:'||l_proc, 99);
   --
end insert_absence_element;
--
procedure check_absence_overlap(p_date_start   In DATE,
                                p_date_end     In DATE,
                                p_person_id    In NUMBER,
                                p_abs_type_id  In NUMBER,
                                p_message      out nocopy VARCHAR2) is

l_message varchar2(30) := null;

begin
--
  IF per_absence_attendances_pkg.chkab3(null,
                                        p_person_id,
                                        p_abs_type_id,
                                        p_date_start,
                                        p_date_end,
                                        hr_general.end_of_time) THEN
  --
    l_message := 'HR_ABS_DET_OVERLAP';
  --
  END IF;

  p_message := l_message;
--
end check_absence_overlap;

procedure check_pto_entitlement(p_date_start    In DATE,
                                p_assignment_id In NUMBER,
                                p_abs_type_id   In NUMBER,
                                p_absence_days  In NUMBER,
                                p_absence_hours In NUMBER,
                                p_message out nocopy VARCHAR2) is

l_message varchar2(30) := null;

begin
--
  IF not (per_absence_attendances_pkg.is_emp_entitled (
                        p_abs_type_id,
                        p_assignment_id,
                        p_date_start,
                        p_absence_days,
                        p_absence_hours)) THEN
  --
    l_message := 'HR_EMP_NOT_ENTITLED';
  --
  END IF;

  p_message := l_message;
--
end check_pto_entitlement;

procedure check_absence_balance(p_session_date  In DATE,
                                p_date_start    In DATE,
                                p_abs_type_id   In NUMBER,
                                p_assignment_id In NUMBER,
                                p_absence_days  In NUMBER,
                                p_absence_hours In NUMBER,
                                p_message out nocopy VARCHAR2) is

l_message varchar2(30) := null;
l_balance number;
l_flag    varchar2(30);

cursor c1 is
select increasing_or_decreasing_flag
from per_absence_attendance_types
where absence_attendance_type_id = p_abs_type_id;

begin
--
  open c1;
  fetch c1 into l_flag;
  close c1;

  if l_flag = 'D' then
  --
    l_balance := per_absence_attendances_pkg.get_annual_balance(
                       p_session_date => p_date_start,
                       p_abs_type_id  => p_abs_type_id,
                       p_ass_id       => p_assignment_id
                       );

    if l_balance < nvl(p_absence_days, l_balance) or
       l_balance < nvl(p_absence_hours, l_balance) then
    --
      l_message := 'HR_ABS_DET_RUNNING_ZERO';
    --
    end if;
  --
  end if;

  p_message := l_message;
--
end check_absence_balance;

procedure check_previous_absence(p_date_start   In DATE,
                                 p_person_id    In NUMBER,
                                 p_abs_type_id  In NUMBER,
                                 p_message out nocopy VARCHAR2) is

l_message varchar2(30) := null;

begin
--
  IF per_absence_attendances_pkg.chkab1(null,
                                        p_person_id,
                                        p_abs_type_id,
                                        p_date_start) THEN
  --
    l_message := 'HR_ABS_DET_ABS_DAY_AFTER';
  --
  END IF;

  p_message := l_message;
--
end check_previous_absence;



PROCEDURE insert_validate_for_bee(p_session_date    in date,
                                  p_date_start      in date,
                                  p_date_end        in date,
                                  p_time_start      in varchar2,
                                  p_time_end        in varchar2,
                                  p_absence_days    in number,
                                  p_absence_hours   in number,
                                  p_abs_type_id     in number,
                                  p_person_id       in number,
                                  p_assignment_id   in number,
                                  p_business_group_id in number,
                                  p_warning_table     out nocopy t_message_table,
                                  p_error_table       out nocopy t_message_table
                                  ) IS

l_warning       varchar2(30) := null;
l_error         varchar2(30) := null;
l_error_count   number := 1;
l_warning_count number := 1;
l_error_table   t_message_table;
l_warning_table t_message_table;

begin

  check_dates_entered(p_date_end      => p_date_end,
                      p_absence_days  => p_absence_days,
                      p_absence_hours => p_absence_hours,
                      p_message       => l_error);

  if l_error is not null then
  --
    l_error_table(l_error_count) := l_error;
    l_error_count := l_error_count + 1;
  --
  end if;

  check_previous_absence(p_date_start => p_date_start,
                         p_person_id => p_person_id,
                         p_abs_type_id => p_abs_type_id,
                         p_message => l_warning);

  if l_warning is not null then
  --
    l_warning_table(l_warning_count) := l_warning;
    l_warning_count := l_warning_count + 1;
  --
  end if;

  check_absence_balance(p_session_date => p_session_date,
                        p_date_start => p_date_start,
                        p_abs_type_id => p_abs_type_id,
                        p_assignment_id => p_assignment_id,
                        p_absence_days => p_absence_days,
                        p_absence_hours => p_absence_hours,
                        p_message => l_warning);

  if l_warning is not null then
  --
    l_warning_table(l_warning_count) := l_warning;
    l_warning_count := l_warning_count + 1;
  --
  end if;

  check_pto_entitlement(p_date_start => p_date_start,
                        p_assignment_id => p_assignment_id,
                        p_abs_type_id => p_abs_type_id,
                        p_absence_days => p_absence_days,
                        p_absence_hours => p_absence_hours,
                        p_message => l_warning);

  if l_warning is not null then
  --
    l_warning_table(l_warning_count) := l_warning;
    l_warning_count := l_warning_count + 1;
  --
  end if;

  check_absence_overlap(p_date_start => p_date_start,
                        p_date_end => p_date_end,
                        p_person_id => p_person_id,
                        p_abs_type_id => p_abs_type_id,
                        p_message => l_warning);

  if l_warning is not null then
  --
    l_warning_table(l_warning_count) := l_warning;
    l_warning_count := l_warning_count + 1;
  --
  end if;

  check_duration(p_date_start => p_date_start,
                 p_date_end => p_date_end,
                 p_time_start => p_time_start,
                 p_time_end => p_time_end,
                 p_business_group_id => p_business_group_id,
                 p_session_date => p_session_date,
                 p_assignment_id => p_assignment_id,
                 p_person_id => p_person_id, -- bug fix 3900409
                 p_absence_days  => p_absence_days,
                 p_absence_hours => p_absence_hours,
                 p_abs_type_id => p_abs_type_id,
                 p_error => l_error,
                 p_warning => l_warning);

  if l_warning is not null then
  --
    l_warning_table(l_warning_count) := l_warning;
    l_warning_count := l_warning_count + 1;
  --
  end if;

  if l_error is not null then
  --
    l_error_table(l_error_count) := l_error;
    l_error_count := l_error_count + 1;
  --
  end if;

  check_absence_type(p_abs_type_id => p_abs_type_id,
                     p_date_start => p_date_start,
                     p_eot => hr_general.end_of_time,
                     p_date_end => p_date_end,
                     p_message => l_error);

  if l_error is not null then
  --
    l_error_table(l_error_count) := l_error;
    l_error_count := l_error_count + 1;
  --
  end if;

  check_absence_dates(p_date_start => p_date_start,
                      p_date_end => p_date_end,
                      p_message => l_error);

  if l_error is not null then
  --
    l_error_table(l_error_count) := l_error;
    l_error_count := l_error_count + 1;
  --
  end if;

  check_sickness_overlap(p_person_id   => p_person_id,
                         p_abs_type_id => p_abs_type_id,
                         p_date_start  => p_date_start,
                         p_date_end    => p_date_end,
                         p_eot         => hr_general.end_of_time,
                         p_message1    => l_error,
                         p_message2    => l_warning);

  --
  -- If either of the above two messages are returned, they will
  -- be errors. We use l_warning to save the definition of
  -- another variable
  --
  -- Fix for bug 3307340 starts here.
  -- For BEE, treat the errors as warnings. This is needed for retro BEE proccess.
  --

  if l_error is not null then
  --
    -- l_error_table(l_error_count) := l_error;
    -- l_error_count := l_error_count + 1;
    l_warning_table(l_warning_count) := l_error;
    l_warning_count := l_warning_count + 1;
  --
  end if;

  if l_warning is not null then
  --
   -- l_error_table(l_error_count) := l_warning;
   -- l_error_count := l_error_count + 1;
    l_warning_table(l_warning_count) := l_warning;
    l_warning_count := l_warning_count + 1;
  --
  end if;
  --
  -- Fix for bug 3307340 ends here.
  --
  p_error_table := l_error_table;
  p_warning_table := l_warning_table;

--
end insert_validate_for_bee;

PROCEDURE insert_abs_for_paymix(p_session_date	       in     date,
		    		p_absence_att_type_id  in     number,
		    		p_assignment_id        in     number,
                    		p_absence_days	       in     number,
		    		p_absence_hours        in     number,
		    		p_date_start	       in     date,
		    		p_date_end	       in     date) IS
--
-- Retrieves additional data from per_assignments_f table.
--
CURSOR C1 IS
  SELECT a.business_group_id,
	 a.person_id,
	 a.payroll_id
  FROM   per_assignments_f a
  WHERE  a.assignment_id = p_assignment_id
  AND    p_session_date between a.effective_start_date
	 AND a.effective_end_date;
--
/*
-- Derives Element_type, input_value_id, the hours_or_days_flag which
-- determines whether the entry value is in days or hours and the
-- increment_or_decrement_flag which determines the sign of the entry value.
--
-- All element entry maintenance is now done directly by the PayMIX
-- form.  Therefore it is commented out from the API, but preserved in
-- case the decision is reversed later.
--
CURSOR C2 IS
  select iv.element_type_id,
	 a.hours_or_days,
	 a.increasing_or_decreasing_flag,
	 a.input_value_id
  FROM   pay_input_values_f iv,
         per_absence_attendance_types a
  WHERE  a.absence_attendance_type_id = p_absence_att_type_id
  AND    a.input_value_id = iv.input_value_id (+);
*/
--
l_max_occurrence      number;
l_absence_att_id     number;
l_row_id	     VARCHAR2(30);
l_person_id	     number;
l_business_group_id  number;
l_assignment_id	     number;
l_date_start	     date;
l_date_end	     date;
l_payroll_id	     number;
--l_element_entry_id   number;
--l_entry_value        varchar2(30);
--l_element_link_id    number;
--l_pay_id             number;
--l_test               varchar2(1);
--l_element_type_id    number;
--l_hours_or_days      varchar2(1);
--l_inc_or_dec_flag    varchar2(1);
--l_ele_exists_flag    varchar2(1);
--l_input_value_id     number;
--
-- Finds the maximum absence occurrence for the required person.
-- has to be declared after l_person_id.
--
CURSOR C3 IS
  SELECT max(occurrence)
  FROM   per_absence_attendances
  WHERE  person_id = l_person_id
  AND    absence_attendance_type_id = p_absence_att_type_id;
--
--
BEGIN
  OPEN C1;
  FETCH C1 INTO
	l_business_group_id,
	l_person_id,
	l_payroll_id;
  --
  IF (C1%NOTFOUND) THEN
    CLOSE C1;
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','insert_abs_for_paymix');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
  END IF;
  CLOSE C1;
  --
  l_assignment_id     := p_assignment_id;
  l_date_start        := p_date_start;
  l_date_end          := p_date_end;
  --
  -- If either the payroll_id or the p_date_start is null then dont want
  -- to continue.
  --
  IF l_payroll_id IS NULL OR p_date_start IS NULL THEN
     hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.raise_error;
  END IF;
  --
/*
  -- Get Element type and input value id.
  --
  OPEN C2;
  FETCH C2 INTO
	l_element_type_id,
	l_hours_or_days,
	l_inc_or_dec_flag,
	l_input_value_id;
  --
  IF (C2%NOTFOUND) THEN
     l_ele_exists_flag := 'N';
  ELSE
     l_ele_exists_flag := 'Y';
  END IF;
  CLOSE C2;
  --
  -- If absence has no associated element then dont get element link.
  --
  IF l_ele_exists_flag = 'Y' THEN
     --
     -- Derive p_element_link
     --
     per_absence_attendances_pkg.get_ele_det1
				(p_bgroup_id   => l_business_group_id,
				 p_eltype      => l_element_type_id,
				 p_per_id      => l_person_id,
				 p_dstart      => p_date_start,
				 p_sess	       => p_session_date,
				 p_ass_id      => l_assignment_id,
				 p_ele_link    => l_element_link_id,
				 p_pay_id      => l_pay_id,
				 p_test	       => l_test);
     --
     -- If element link does not exist then discontinue.
     --
     IF l_element_link_id IS NULL THEN
        hr_utility.set_message('PAY','HR_7448_ELE_PER_NOT_ELIGIBLE');
        hr_utility.raise_error;
     END IF;
     --
  END IF;
  --
*/
  -- Get the maximum absence occurrence for that person.
  --
  OPEN C3;
  FETCH C3 INTO l_max_occurrence;

  IF l_max_occurrence is null THEN
     l_max_occurrence := 0;
  END IF;

  CLOSE C3;
  --
  -- Increment the maximum occurrence by 1
  --
    l_max_occurrence := l_max_occurrence + 1;
  --
  --
  -- Insert the new absence from PayMIX into per_absence_attendances
  -- table.  All values are set to null except for the mandatory ones
  -- and those set up by PayMIX.
  --
  per_absence_attendances_pkg.insert_row
	(X_Rowid                        => l_row_id,
         X_Absence_Attendance_Id        => l_absence_att_id,
         X_Business_Group_Id            => l_business_group_id,
         X_Absence_Attendance_Type_Id   => p_absence_att_type_id,
         X_Abs_Attendance_Reason_Id     => null,
         X_Person_Id                    => l_person_id,
         X_Authorising_Person_Id        => null,
         X_Replacement_Person_Id        => null,
         X_Period_Of_Incapacity_Id      => null,
         X_Absence_Days                 => p_absence_days,
         X_Absence_Hours                => p_absence_hours,
         X_Comments                     => null,
         X_Date_End                     => p_date_end,
         X_Date_Notification            => p_session_date,
         X_Date_Projected_End           => null,
         X_Date_Projected_Start         => null,
         X_Date_Start                   => p_date_start,
         X_Occurrence                   => l_max_occurrence,
         X_Ssp1_Issued                  => null,
         X_Time_End                     => null,
         X_Time_Projected_End           => null,
         X_Time_Projected_Start         => null,
         X_Time_Start                   => null,
         X_Attribute_Category           => null,
         X_Attribute1                   => null,
         X_Attribute2                   => null,
         X_Attribute3                   => null,
         X_Attribute4                   => null,
         X_Attribute5                   => null,
         X_Attribute6                   => null,
         X_Attribute7                   => null,
         X_Attribute8                   => null,
         X_Attribute9                   => null,
         X_Attribute10                  => null,
         X_Attribute11                  => null,
         X_Attribute12                  => null,
         X_Attribute13                  => null,
         X_Attribute14                  => null,
         X_Attribute15                  => null,
         X_Attribute16                  => null,
         X_Attribute17                  => null,
         X_Attribute18                  => null,
         X_Attribute19                  => null,
         X_Attribute20                  => null,
         X_Linked_Absence_id            => null,
         X_Sickness_Start_Date          => null,
         X_Sickness_End_Date            => null,
         X_Accept_Late_Notif_Flag       => null,
         X_reason_for_late_notification => null,
         X_Pregnancy_Related_Illness    => null,
         X_Maternity_Id                 => null,
         X_Abs_Information_Category     => null,
         X_Abs_Information1             => null,
         X_Abs_Information2             => null,
         X_Abs_Information3             => null,
         X_Abs_Information4             => null,
         X_Abs_Information5             => null,
         X_Abs_Information6             => null,
         X_Abs_Information7             => null,
         X_Abs_Information8             => null,
         X_Abs_Information9             => null,
         X_Abs_Information10            => null,
         X_Abs_Information11             => null,
         X_Abs_Information12             => null,
         X_Abs_Information13             => null,
         X_Abs_Information14             => null,
         X_Abs_Information15             => null,
         X_Abs_Information16             => null,
         X_Abs_Information17             => null,
         X_Abs_Information18             => null,
         X_Abs_Information19             => null,
         X_Abs_Information20             => null,
         X_Abs_Information21             => null,
         X_Abs_Information22             => null,
         X_Abs_Information23             => null,
         X_Abs_Information24             => null,
         X_Abs_Information25             => null,
         X_Abs_Information26             => null,
         X_Abs_Information27             => null,
         X_Abs_Information28             => null,
         X_Abs_Information29             => null,
         X_Abs_Information30             => null);
  --
/*
  -- Determine the entry value and its sign.  It is +ve if
  -- increasing_or_decreasing_flag set to 'I' else -ve.
  --
  IF l_inc_or_dec_flag = 'I' THEN
     IF l_hours_or_days = 'H' THEN
        l_entry_value := p_absence_hours;
     ELSE
	l_entry_value := p_absence_days;
     END IF;
  ELSE
     IF l_hours_or_days = 'H' THEN
	l_entry_value := p_absence_hours * -1;
     ELSE
	l_entry_value := p_absence_days * -1;
     END IF;
  END IF;
  --
  -- Insert element only if absence has an element associated to it.
  --
  IF l_ele_exists_flag = 'Y' THEN
     --
     -- Insert the element entry.
     --
     per_absence_attendances_pkg2.insert_element
			(p_effective_start_date => l_date_start,
			 p_effective_end_date   => l_date_end,
			 p_element_entry_id	=> l_element_entry_id,
			 p_assignment_id	=> p_assignment_id,
			 p_element_link_id	=> l_element_link_id,
			 p_creator_id		=> l_absence_att_id,
			 p_creator_type		=> 'A',
			 p_entry_type		=> 'E',
			 p_input_value_id1	=> l_input_value_id,
			 p_entry_value1		=> l_entry_value);
    --
  END IF;
*/
--
END insert_abs_for_paymix;
--
--
PROCEDURE insert_abs_for_bee(p_session_date          in     date,
                             p_absence_att_type_id   in     number,
                             p_assignment_id         in     number,
                             p_batch_id              in     number,
                             p_absence_days          in     number,
                             p_absence_hours         in     number,
                             p_date_start            in     date,
                             p_date_end              in     date,
                             p_absence_attendance_id out nocopy    number,
                             p_warning_table         out nocopy    t_message_table,
                             p_error_table           out nocopy    t_message_table
                             ) is
--
l_absence_att_id            number;
l_row_id                    varchar2(30);
l_person_id                 number;
l_business_group_id         number;
l_payroll_id                number;
l_time_start                varchar2(5);
l_time_end                  varchar2(5);
l_error_table               t_message_table;
l_warning_table             t_message_table;
l_absence_days              number;
l_absence_hours             number;
l_object_version_number     number;
l_occurrence                number;
l_dur_dys_less_warning      boolean;
l_dur_hrs_less_warning      boolean;
l_exceeds_pto_entit_warning boolean;
l_exceeds_run_total_warning boolean;
l_abs_overlap_warning       boolean;
l_abs_day_after_warning     boolean;
l_dur_overwritten_warning   boolean;

--
-- Retrieves additional data from per_assignments_f table.
--
CURSOR C1 IS
  SELECT a.business_group_id,
	 a.person_id,
	 a.payroll_id
  FROM   per_assignments_f a
  WHERE  a.assignment_id = p_assignment_id
  AND    p_session_date between a.effective_start_date
	 AND a.effective_end_date;

--
-- Find normal working hours of employee
--
CURSOR C2 IS
  SELECT nvl(nvl(asg.time_normal_start, pbg.default_start_time), '00:00'),
         nvl(nvl(asg.time_normal_finish, pbg.default_end_time), '23:59')
  FROM   per_assignments_f asg,
         per_business_groups pbg
  WHERE  asg.assignment_id = p_assignment_id
  AND    asg.business_group_id = pbg.business_group_id
  AND    p_session_date between asg.effective_start_date
                        and     asg.effective_end_date;

--

-- ### Bug fix for 3812684.
--
l_sickness_start_date       date := p_date_start;
l_sickness_end_date         date := p_date_end;
l_dummy                     varchar2(1);
--
cursor C3 IS
  SELECT null
  FROM   per_absence_attendance_types paat,
         per_business_groups_perf pbg
  WHERE  pbg.business_group_id = l_business_group_id
    AND  pbg.legislation_code = 'GB'
    AND  paat.absence_attendance_type_id = p_absence_att_type_id
    AND  paat.absence_category='S';
--
-- ###

begin

  OPEN C1;
  FETCH C1 INTO
	l_business_group_id,
	l_person_id,
	l_payroll_id;
  --
  IF (C1%NOTFOUND) THEN
    CLOSE C1;
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','insert_abs_for_bee');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
  END IF;
  CLOSE C1;

  --
  -- If either the payroll_id or the p_date_start is null then dont want
  -- to continue.
  --
  IF l_payroll_id IS NULL OR p_date_start IS NULL THEN
     hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.raise_error;
  END IF;

  --
  -- Fetch the default start and end times for an
  -- hours absence
  --
  if p_absence_hours is not null
  and p_date_start is not null
  and p_date_end is not null then
  --
    open C2;
    fetch C2 into l_time_start, l_time_end;
    close C2;
  --
  end if;

  --
  -- Carry out validation on new data before creating new
  -- absence record
  --

  insert_validate_for_bee(p_session_date => p_session_date,
                          p_date_start => p_date_start,
                          p_date_end => p_date_end,
                          p_time_start => l_time_start,
                          p_time_end => l_time_end,
                          p_absence_days => p_absence_days,
                          p_absence_hours => p_absence_hours,
                          p_abs_type_id => p_absence_att_type_id,
                          p_person_id => l_person_id,
                          p_assignment_id => p_assignment_id,
                          p_business_group_id => l_business_group_id,
                          p_warning_table => l_warning_table,
                          p_error_table => l_error_table
                          );

  if l_error_table.count = 0 then

  --
  -- The absence duration in days and or hours is an IN OUT parameter
  -- in the API so a local variable must be used.
  --
  l_absence_hours := p_absence_hours;
  l_absence_days  := p_absence_days;

  -- ### Bug fix for 3812684.
  --
  OPEN C3;
  FETCH C3 INTO l_dummy;
  if C3%notfound then
     l_sickness_start_date := null;
     l_sickness_end_date    := null;
  end if;
  CLOSE C3;
  --
  -- ###

  --
  -- Call the absence API to insert the new absence from BEE into
  -- per_absence_attendances table.
  -- All values are set to null except for the mandatory ones
  -- and those set up by BEE.
  --
  hr_person_absence_api.create_person_absence
    (p_validate                       =>   FALSE
    ,p_effective_date                 =>   p_session_date
    ,p_person_id                      =>   l_person_id
    ,p_business_group_id              =>   l_business_group_id
    ,p_absence_attendance_type_id     =>   p_absence_att_type_id
    ,p_date_notification              =>   p_session_date
    ,p_date_start                     =>   p_date_start
    ,p_time_start                     =>   l_time_start
    ,p_date_end                       =>   p_date_end
    ,p_time_end                       =>   l_time_end
    ,p_absence_days                   =>   l_absence_days
    ,p_absence_hours                  =>   l_absence_hours
    ,p_batch_id                       =>   p_batch_id
    ,p_create_element_entry           =>   FALSE
    ,p_absence_attendance_id          =>   l_absence_att_id
    ,p_object_version_number          =>   l_object_version_number
    ,p_occurrence                     =>   l_occurrence
    ,p_dur_dys_less_warning           =>   l_dur_dys_less_warning
    ,p_dur_hrs_less_warning           =>   l_dur_hrs_less_warning
    ,p_exceeds_pto_entit_warning      =>   l_exceeds_pto_entit_warning
    ,p_exceeds_run_total_warning      =>   l_exceeds_run_total_warning
    ,p_abs_overlap_warning            =>   l_abs_overlap_warning
    ,p_abs_day_after_warning          =>   l_abs_day_after_warning
    ,p_dur_overwritten_warning        =>   l_dur_overwritten_warning
    -- ### Bug fix for 3812684.
    --
    ,p_sickness_start_date            =>   l_sickness_start_date
    ,p_sickness_end_date              =>   l_sickness_end_date
    --
    -- ###
    );
  --
/*
    Create a warning message stating that the EE has already been created.

    Bug 2377104.  The below is now commented out.  Setting this warning means
    thats BEE will not create the element entry (it assumes the absence API
    has already created it).  However, any non-absence entry values specified
    for the BEE line are not passed to the absence API and so never
    get saved to the database.  Commenting out nocopy this line ensures that BEE
    creates the element entry.  The absence API is prevented from creating
    the EE by passing FALSE to p_create_element_entry.

    l_warning_table(l_warning_table.count+1) := 'EE_CREATED_BY_ABSENCE_API';
*/

  end if;

  --
  -- Set the out parameters
  --

  p_absence_attendance_id := l_absence_att_id;
  p_warning_table         := l_warning_table;
  p_error_table           := l_error_table;
--
END insert_abs_for_bee;
--
-- ----------------------------------------------------------------------------
-- |------------------------< insert_abs_for_bee >----------------------------|
-- ----------------------------------------------------------------------------
-- Overloaded procedure
procedure insert_abs_for_bee(
   p_absence_att_type_id   in         number,
   p_batch_id              in         number,
   p_asg_act_id            in         number,
   p_entry_values_count    in         number,
   p_hours_or_days         in         varchar2,
   p_format                in         varchar2,
   p_value                 in         varchar2,
   p_date_start            in         date,
   p_date_end              in         date,
   p_line_record           in         pay_batch_lines%Rowtype,
   p_passed_inp_tbl        in         hr_entry.number_table,
   p_passed_val_tbl        in         hr_entry.varchar2_table,
   p_absence_attendance_id out nocopy number,
   p_warning_table         out nocopy t_message_table,
   p_error_table           out nocopy t_message_table
   ) is
   --
   l_proc                  varchar2(72) := g_package||'insert_abs_for_bee';
   --
   l_value                 number;
   l_absence_days          number;
   l_absence_hours         number;
   l_error_count           number := 1;
   l_error                 varchar2(30) := null;
   l_result                boolean;
   l_error_table           t_message_table;
   --
   procedure chk_absence_input(
      p_value   in         varchar2, -- the input value to be checked/formatted.
      p_format  in         varchar2, -- the specific format.
      p_output  out nocopy number,   -- the formatted value on output.
      p_result  out nocopy boolean   -- success or failure flag.
      ) is
      --
      l_decplace           pls_integer;         -- number of decimal places.
      --
   begin
      --
      p_result := true; -- start by assuming success.
      --
      if(p_format = 'H_HH') then
         -- check is number and integer.
         if(trunc(p_value) <> p_value) then
            p_result := false;
            return;
         else
            p_output := to_number(trunc(p_value));
         end if;
      elsif(p_format = 'H_DECIMAL1' or p_format = 'H_DECIMAL2'
         or p_format = 'H_DECIMAL3' or p_format = 'HOURS') then
         p_output := to_number(p_value); --uses session NLS settings.
         -- can get dec places from the last character of the format:
         if p_format = 'HOURS' then
            l_decplace := 3; -- for backwards compatability.
         else
            l_decplace := to_number(substrb(p_format, -1, 1 ));
         end if;
         -- round the number.
         p_output := round(p_output, l_decplace);
      else -- Including the format type ND
         p_output := to_number(p_value); --uses session NLS settings.
      end if;
      --
   exception
      --
      when others then --when varchar2 conversion to number fails.
         --
         p_result := false;
      --
   end chk_absence_input;
   --
begin
   --
   hr_utility.set_location('Entering:'||l_proc, 10);
   --
   chk_absence_input(p_value    => p_value,
                     p_format   => p_format,
                     p_output   => l_value,
                     p_result   => l_result);
   --
   hr_utility.set_location(l_proc, 10);
   --
   if l_result = true then
      if p_hours_or_days = 'D' then
         l_absence_days := l_value;
         l_absence_hours := null;
      else
         l_absence_days := null;
         l_absence_hours := l_value;
      end if;
      --
      hr_utility.set_location(l_proc, 20);
      -- Calling the absence API after validation
      per_absence_attendances_pkg3.insert_abs_for_bee(
                     p_session_date          => p_line_record.effective_date,
                     p_absence_att_type_id   => p_absence_att_type_id,
                     p_absence_attendance_id => p_absence_attendance_id,
                     p_batch_id              => p_batch_id,
                     p_assignment_id         => p_line_record.assignment_id,
                     p_absence_days          => l_absence_days,
                     p_absence_hours         => l_absence_hours,
                     p_date_start            => p_date_start,
                     p_date_end              => p_date_end,
                     p_warning_table         => p_warning_table,
                     p_error_table           => p_error_table);
      --
      hr_utility.set_location(l_proc, 30);
      -- Creating absence element entry.
      insert_absence_element(
                     p_line_record           => p_line_record,
                     p_asg_act_id            => p_asg_act_id,
                     p_absence_attendance_id => p_absence_attendance_id,
                     p_absence_att_type_id   => p_absence_att_type_id,
                     p_entry_values_count    => p_entry_values_count,
                     p_date_start            => p_date_start,
                     p_date_end              => p_date_end,
                     p_passed_inp_tbl        => p_passed_inp_tbl,
                     p_passed_val_tbl        => p_passed_val_tbl);
      -- Create a warning message stating that the EE has already been created.
      p_warning_table(p_warning_table.count + 1) := 'EE_CREATED_BY_ABSENCE_API';
      --
   else
      l_error := 'HR_51153_INVAL_NUM_FORMAT';
      l_error_table(l_error_count) := l_error;
      p_error_table := l_error_table;
      --
      hr_utility.set_location(l_proc, 40);
      --
   end if;
   --
   hr_utility.set_location(' Leaving:'||l_proc, 99);
   --
end insert_abs_for_bee;
--
END PER_ABSENCE_ATTENDANCES_PKG3;

/
