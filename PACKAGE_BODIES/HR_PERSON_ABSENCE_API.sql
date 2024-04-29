--------------------------------------------------------
--  DDL for Package Body HR_PERSON_ABSENCE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PERSON_ABSENCE_API" as
/* $Header: peabsapi.pkb 120.4.12010000.29 2010/04/08 10:24:36 ghshanka ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_person_absence_api.';
--
procedure populate_ben_absence_rec
  (p_absence_attendance_id   in number,
   p_rec_type                in varchar2,
   p_ben_rec                 out nocopy ben_abs_ler.g_abs_ler_rec) is

  cursor c_current_absence is
    select
       absence_attendance_id
      ,business_group_id
      ,absence_attendance_type_id
      ,abs_attendance_reason_id
      ,person_id
      ,authorising_person_id
      ,replacement_person_id
      ,period_of_incapacity_id
      ,absence_days
      ,absence_hours
      ,comments
      ,date_end
      ,date_notification
      ,date_projected_end
      ,date_projected_start
      ,date_start
      ,occurrence
      ,ssp1_issued
      ,time_end
      ,time_projected_end
      ,time_projected_start
      ,time_start
      ,request_id
      ,program_application_id
      ,program_id
      ,program_update_date
      ,attribute_category
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
      ,attribute6
      ,attribute7
      ,attribute8
      ,attribute9
      ,attribute10
      ,attribute11
      ,attribute12
      ,attribute13
      ,attribute14
      ,attribute15
      ,attribute16
      ,attribute17
      ,attribute18
      ,attribute19
      ,attribute20
      ,maternity_id
      ,sickness_start_date
      ,sickness_end_date
      ,pregnancy_related_illness
      ,reason_for_notification_delay
      ,accept_late_notification_flag
      ,linked_absence_id
      ,abs_information_category
      ,abs_information1
      ,abs_information2
      ,abs_information3
      ,abs_information4
      ,abs_information5
      ,abs_information6
      ,abs_information7
      ,abs_information8
      ,abs_information9
      ,abs_information10
      ,abs_information11
      ,abs_information12
      ,abs_information13
      ,abs_information14
      ,abs_information15
      ,abs_information16
      ,abs_information17
      ,abs_information18
      ,abs_information19
      ,abs_information20
      ,abs_information21
      ,abs_information22
      ,abs_information23
      ,abs_information24
      ,abs_information25
      ,abs_information26
      ,abs_information27
      ,abs_information28
      ,abs_information29
      ,abs_information30
      ,absence_case_id
      ,batch_id
      ,object_version_number
    from   per_absence_attendances
    where  absence_attendance_id = p_absence_attendance_id;
  --
  l_absence_rec         per_abs_shd.g_rec_type;
  l_proc                varchar2(72) := g_package||'populate_ben_absence_rec';

begin

  hr_utility.set_location('Entering: '|| l_proc, 10);

  if (p_rec_type = 'O') then
     l_absence_rec := per_abs_shd.g_old_rec;
  else
      open c_current_absence;
     fetch c_current_absence into l_absence_rec;
     close c_current_absence;
  end if;

  p_ben_rec.person_id := l_absence_rec.person_id;
  p_ben_rec.business_group_id := l_absence_rec.business_group_id;
  p_ben_rec.date_start := l_absence_rec.date_start;
  p_ben_rec.date_end := l_absence_rec.date_end;
  p_ben_rec.absence_attendance_type_id := l_absence_rec.absence_attendance_type_id;
  p_ben_rec.abs_attendance_reason_id := l_absence_rec.abs_attendance_reason_id;
  p_ben_rec.absence_attendance_id := l_absence_rec.absence_attendance_id;
  p_ben_rec.authorising_person_id := l_absence_rec.authorising_person_id;
  p_ben_rec.replacement_person_id := l_absence_rec.replacement_person_id;
  p_ben_rec.period_of_incapacity_id := l_absence_rec.period_of_incapacity_id;
  p_ben_rec.absence_days := l_absence_rec.absence_days;
  p_ben_rec.absence_hours := l_absence_rec.absence_hours;
  p_ben_rec.date_notification := l_absence_rec.date_notification;
  p_ben_rec.date_projected_end := l_absence_rec.date_projected_end;
  p_ben_rec.date_projected_start := l_absence_rec.date_projected_start;
  p_ben_rec.occurrence := l_absence_rec.occurrence;
  p_ben_rec.ssp1_issued := l_absence_rec.ssp1_issued;
  p_ben_rec.time_end := l_absence_rec.time_end;
  p_ben_rec.time_projected_end := l_absence_rec.time_projected_end;
  p_ben_rec.time_projected_start := l_absence_rec.time_projected_start;
  p_ben_rec.time_start := l_absence_rec.time_start;
  p_ben_rec.attribute_category := l_absence_rec.attribute_category;
  p_ben_rec.attribute1 := l_absence_rec.attribute1;
  p_ben_rec.attribute2 := l_absence_rec.attribute2;
  p_ben_rec.attribute3 := l_absence_rec.attribute3;
  p_ben_rec.attribute4 := l_absence_rec.attribute4;
  p_ben_rec.attribute5 := l_absence_rec.attribute5;
  p_ben_rec.attribute6 := l_absence_rec.attribute6;
  p_ben_rec.attribute7 := l_absence_rec.attribute7;
  p_ben_rec.attribute8 := l_absence_rec.attribute8;
  p_ben_rec.attribute9 := l_absence_rec.attribute9;
  p_ben_rec.attribute10 := l_absence_rec.attribute10;
  p_ben_rec.attribute11 := l_absence_rec.attribute11;
  p_ben_rec.attribute12 := l_absence_rec.attribute12;
  p_ben_rec.attribute13 := l_absence_rec.attribute13;
  p_ben_rec.attribute14 := l_absence_rec.attribute14;
  p_ben_rec.attribute15 := l_absence_rec.attribute15;
  p_ben_rec.attribute16 := l_absence_rec.attribute16;
  p_ben_rec.attribute17 := l_absence_rec.attribute17;
  p_ben_rec.attribute18 := l_absence_rec.attribute18;
  p_ben_rec.attribute19 := l_absence_rec.attribute19;
  p_ben_rec.attribute20 := l_absence_rec.attribute20;
  p_ben_rec.maternity_id := l_absence_rec.maternity_id;
  p_ben_rec.sickness_start_date := l_absence_rec.sickness_start_date;
  p_ben_rec.sickness_end_date := l_absence_rec.sickness_end_date;
  p_ben_rec.pregnancy_related_illness := l_absence_rec.pregnancy_related_illness;
  p_ben_rec.reason_for_notification_delay := l_absence_rec.reason_for_notification_delay;
  p_ben_rec.accept_late_notification_flag := l_absence_rec.accept_late_notification_flag;
  p_ben_rec.linked_absence_id := l_absence_rec.linked_absence_id;
  p_ben_rec.batch_id := l_absence_rec.batch_id;
  p_ben_rec.abs_information_category := l_absence_rec.abs_information_category;
  p_ben_rec.abs_information1 := l_absence_rec.abs_information1;
  p_ben_rec.abs_information2 := l_absence_rec.abs_information2;
  p_ben_rec.abs_information3 := l_absence_rec.abs_information3;
  p_ben_rec.abs_information4 := l_absence_rec.abs_information4;
  p_ben_rec.abs_information5 := l_absence_rec.abs_information5;
  p_ben_rec.abs_information6 := l_absence_rec.abs_information6;
  p_ben_rec.abs_information7 := l_absence_rec.abs_information7;
  p_ben_rec.abs_information8 := l_absence_rec.abs_information8;
  p_ben_rec.abs_information9 := l_absence_rec.abs_information9;
  p_ben_rec.abs_information10 := l_absence_rec.abs_information10;
  p_ben_rec.abs_information11 := l_absence_rec.abs_information11;
  p_ben_rec.abs_information12 := l_absence_rec.abs_information12;
  p_ben_rec.abs_information13 := l_absence_rec.abs_information13;
  p_ben_rec.abs_information14 := l_absence_rec.abs_information14;
  p_ben_rec.abs_information15 := l_absence_rec.abs_information15;
  p_ben_rec.abs_information16 := l_absence_rec.abs_information16;
  p_ben_rec.abs_information17 := l_absence_rec.abs_information17;
  p_ben_rec.abs_information18 := l_absence_rec.abs_information18;
  p_ben_rec.abs_information19 := l_absence_rec.abs_information19;
  p_ben_rec.abs_information20 := l_absence_rec.abs_information20;
  p_ben_rec.abs_information21 := l_absence_rec.abs_information21;
  p_ben_rec.abs_information22 := l_absence_rec.abs_information22;
  p_ben_rec.abs_information23 := l_absence_rec.abs_information23;
  p_ben_rec.abs_information24 := l_absence_rec.abs_information24;
  p_ben_rec.abs_information25 := l_absence_rec.abs_information25;
  p_ben_rec.abs_information26 := l_absence_rec.abs_information26;
  p_ben_rec.abs_information27 := l_absence_rec.abs_information27;
  p_ben_rec.abs_information28 := l_absence_rec.abs_information28;
  p_ben_rec.abs_information29 := l_absence_rec.abs_information29;
  p_ben_rec.abs_information30 := l_absence_rec.abs_information30;

  hr_utility.set_location('Leaving: '|| l_proc, 15);
end;
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_person_absence >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_person_absence
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_person_id                     in     number
  ,p_business_group_id             in     number
  ,p_absence_attendance_type_id    in     number
  ,p_abs_attendance_reason_id      in     number   default null
  ,p_comments                      in     long     default null
  ,p_date_notification             in     date     default null
  ,p_date_projected_start          in     date     default null
  ,p_time_projected_start          in     varchar2 default null
  ,p_date_projected_end            in     date     default null
  ,p_time_projected_end            in     varchar2 default null
  ,p_date_start                    in     date     default null
  ,p_time_start                    in     varchar2 default null
  ,p_date_end                      in     date     default null
  ,p_time_end                      in     varchar2 default null
  ,p_absence_days                  in out nocopy number
  ,p_absence_hours                 in out nocopy number
  ,p_authorising_person_id         in     number   default null
  ,p_replacement_person_id         in     number   default null
  ,p_attribute_category            in     varchar2 default null
  ,p_attribute1                    in     varchar2 default null
  ,p_attribute2                    in     varchar2 default null
  ,p_attribute3                    in     varchar2 default null
  ,p_attribute4                    in     varchar2 default null
  ,p_attribute5                    in     varchar2 default null
  ,p_attribute6                    in     varchar2 default null
  ,p_attribute7                    in     varchar2 default null
  ,p_attribute8                    in     varchar2 default null
  ,p_attribute9                    in     varchar2 default null
  ,p_attribute10                   in     varchar2 default null
  ,p_attribute11                   in     varchar2 default null
  ,p_attribute12                   in     varchar2 default null
  ,p_attribute13                   in     varchar2 default null
  ,p_attribute14                   in     varchar2 default null
  ,p_attribute15                   in     varchar2 default null
  ,p_attribute16                   in     varchar2 default null
  ,p_attribute17                   in     varchar2 default null
  ,p_attribute18                   in     varchar2 default null
  ,p_attribute19                   in     varchar2 default null
  ,p_attribute20                   in     varchar2 default null
  ,p_period_of_incapacity_id       in     number   default null
  ,p_ssp1_issued                   in     varchar2 default 'N'
  ,p_maternity_id                  in     number   default null
  ,p_sickness_start_date           in     date     default null
  ,p_sickness_end_date             in     date     default null
  ,p_pregnancy_related_illness     in     varchar2 default 'N'
  ,p_reason_for_notification_dela  in     varchar2 default null
  ,p_accept_late_notification_fla  in     varchar2 default 'N'
  ,p_linked_absence_id             in     number   default null
  ,p_batch_id                      in     number   default null
  ,p_create_element_entry          in     boolean  default true
  ,p_abs_information_category      in     varchar2 default null
  ,p_abs_information1              in     varchar2 default null
  ,p_abs_information2              in     varchar2 default null
  ,p_abs_information3              in     varchar2 default null
  ,p_abs_information4              in     varchar2 default null
  ,p_abs_information5              in     varchar2 default null
  ,p_abs_information6              in     varchar2 default null
  ,p_abs_information7              in     varchar2 default null
  ,p_abs_information8              in     varchar2 default null
  ,p_abs_information9              in     varchar2 default null
  ,p_abs_information10             in     varchar2 default null
  ,p_abs_information11             in     varchar2 default null
  ,p_abs_information12             in     varchar2 default null
  ,p_abs_information13             in     varchar2 default null
  ,p_abs_information14             in     varchar2 default null
  ,p_abs_information15             in     varchar2 default null
  ,p_abs_information16             in     varchar2 default null
  ,p_abs_information17             in     varchar2 default null
  ,p_abs_information18             in     varchar2 default null
  ,p_abs_information19             in     varchar2 default null
  ,p_abs_information20             in     varchar2 default null
  ,p_abs_information21             in     varchar2 default null
  ,p_abs_information22             in     varchar2 default null
  ,p_abs_information23             in     varchar2 default null
  ,p_abs_information24             in     varchar2 default null
  ,p_abs_information25             in     varchar2 default null
  ,p_abs_information26             in     varchar2 default null
  ,p_abs_information27             in     varchar2 default null
  ,p_abs_information28             in     varchar2 default null
  ,p_abs_information29             in     varchar2 default null
  ,p_abs_information30             in     varchar2 default null
  ,p_absence_case_id               in     number   default null
  ,p_program_application_id        in     number   default 800
  ,p_called_from                   in     number   default 800
  ,p_absence_attendance_id         out nocopy    number
  ,p_object_version_number         out nocopy    number
  ,p_occurrence                    out nocopy    number
  ,p_dur_dys_less_warning          out nocopy    boolean
  ,p_dur_hrs_less_warning          out nocopy    boolean
  ,p_exceeds_pto_entit_warning     out nocopy    boolean
  ,p_exceeds_run_total_warning     out nocopy    boolean
  ,p_abs_overlap_warning           out nocopy    boolean
  ,p_abs_day_after_warning         out nocopy    boolean
  ,p_dur_overwritten_warning       out nocopy    boolean
  ) is

  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'create_person_absence';
  l_exists                   number;
  l_occurrence               number;
  l_input_value_id           number;
  l_date_projected_start     date;
  l_date_projected_end       date;
  l_date_start               date;
  l_date_end                 date;
  l_date_notification        date;
  l_effective_date           date;
  l_old                      ben_abs_ler.g_abs_ler_rec;
  l_new                      ben_abs_ler.g_abs_ler_rec;
  --
  -- Declare out parameters
  --
  l_absence_days               number;
  l_absence_hours              number;
  l_absence_attendance_id      number;
  l_assignment_id              number;
  l_element_entry_id           number;
  l_object_version_number      number;
  l_processing_type            pay_element_types_f.processing_type%TYPE;
  l_dur_dys_less_warning       boolean;
  l_dur_hrs_less_warning       boolean;
  l_exceeds_pto_entit_warning  boolean;
  l_exceeds_run_total_warning  boolean;
  l_abs_overlap_warning        boolean;
  l_abs_day_after_warning      boolean;
  l_dur_overwritten_warning    boolean;
  l_retvalue varchar2(10);
  --

l_hours_or_days varchar2(2);
cursor csr_get_abstype is
select HOURS_OR_DAYS, INPUT_VALUE_ID
from per_absence_attendance_types
where absence_attendance_type_id= p_absence_attendance_type_id;
l_chk_datestart date;
l_chk_dateend date;
l_elm_entry_id number;
l_enty_efsd date;
l_entry_efed date;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);

  --
  -- Pipe the main IN / IN OUT parameters for ease of debugging.
  --
  hr_utility.trace(' ');
  hr_utility.trace(' --------------------------------'||
                   '---------------------------------');
  hr_utility.trace(' IN / IN OUT NOCOPY PARAMETER           '||
                   ' VALUE');
  hr_utility.trace(' --------------------------------'||
                   '+--------------------------------');
  hr_utility.trace('  p_effective_date                 '||
                      to_char(p_effective_date));
  hr_utility.trace('  p_person_id                      '||
                      to_char(p_person_id));
  hr_utility.trace('  p_business_group_id              '||
                      to_char(p_business_group_id));
  hr_utility.trace('  p_absence_attendance_type_id     '||
                      to_char(p_absence_attendance_type_id));
  hr_utility.trace('  p_abs_attendance_reason_id       '||
                      to_char(p_abs_attendance_reason_id));
  hr_utility.trace('  p_date_notification              '||
                      to_char(p_date_notification));
  hr_utility.trace('  p_date_projected_start           '||
                      to_char(p_date_projected_start));
  hr_utility.trace('  p_time_projected_start           '||
                      p_time_projected_start);
  hr_utility.trace('  p_date_projected_end             '||
                      to_char(p_date_projected_end));
  hr_utility.trace('  p_time_projected_end             '||
                      p_time_projected_end);
  hr_utility.trace('  p_date_start                     '||
                      to_char(p_date_start));
  hr_utility.trace('  p_time_start                     '||
                      p_time_start);
  hr_utility.trace('  p_date_end                       '||
                      to_char(p_date_end));
  hr_utility.trace('  p_time_end                       '||
                      p_time_end);
  hr_utility.trace('  p_absence_days                   '||
                      to_char(p_absence_days));
  hr_utility.trace('  p_absence_hours                  '||
                      to_char(p_absence_hours));
  hr_utility.trace('  p_authorising_person_id          '||
                      to_char(p_authorising_person_id));
  hr_utility.trace('  p_batch_id                       '||
                      to_char(p_batch_id));
  if p_create_element_entry then
    hr_utility.trace('  p_create_element_entry           '||
                        'TRUE');
  else
    hr_utility.trace('  p_create_element_entry           '||
                        'FALSE');
  end if;
  hr_utility.trace(' --------------------------------'||
                   '---------------------------------');
  hr_utility.trace(' ');

  --
  -- Create a savepoint.
  --
  savepoint create_person_absence;
  --
  -- Truncate the time portion from all IN date parameters
  --

if nvl(FND_PROFILE.Value('HR_ABS_OTL_INTEGRATION'),'N') = 'Y' then
hr_utility.set_location(' OTL ABS integration on ',10);

open csr_get_abstype;
fetch csr_get_abstype into l_hours_or_days,l_elm_entry_id;
close csr_get_abstype;

hr_utility.set_location(' l_inputvalue_id : '|| l_elm_entry_id,10);

if l_elm_entry_id is not null then


hr_utility.set_location(' l_hours_or_days  ' ||l_hours_or_days,10);
if l_hours_or_days ='H' then
-- when the UOM attached to the element is Hours

	if p_date_start is null then

    if p_date_projected_start is null then
     hr_utility.set_message (800,'HR_449868_START_END_DATES5');
     hr_utility.raise_error;
    end if;

   if p_time_projected_start is null  or p_date_projected_end is null  or p_time_projected_end is null then
     hr_utility.set_location(' l_hours_or_days 30  ' ||l_hours_or_days,30);
     hr_utility.set_message(800, 'HR_449866_START_END_DATES3');
     hr_utility.raise_error;
     end if;

    hr_utility.set_location(' l_hours_or_days  ' ||l_hours_or_days,20);

  else
	hr_utility.set_location(' l_hours_or_days  ' ||l_hours_or_days,40);

    if p_date_projected_start is not null and
       (p_time_projected_start is null  or p_date_projected_end is null  or p_time_projected_end is null ) then

   hr_utility.set_message (800,'HR_449866_START_END_DATES3');
   hr_utility.raise_error;
   end if;

   if p_date_end is null or p_time_end is null or p_time_start is null then

   hr_utility.set_message (800,'HR_449867_START_END_DATES4');
   hr_utility.raise_error;
   end if;
end if;

else
-- when the UOM is Days
if p_date_start is null then

    if p_date_projected_start is null then
     hr_utility.set_message (800,'HR_449868_START_END_DATES5');
     hr_utility.raise_error;

     elsif  p_date_projected_end is null then

     hr_utility.set_message (800,'HR_449864_START_END_DATES1');
     hr_utility.raise_error;
     end if;

  else

    if p_date_projected_start is not null and  p_date_projected_end is null then

   hr_utility.set_message (800,'HR_449864_START_END_DATES1');
   hr_utility.raise_error;
   end if;

   if p_date_end is null then

   hr_utility.set_message (800,'HR_449865_START_END_DATES2');
   hr_utility.raise_error;
   end if;

end if;

end if;

l_chk_datestart := nvl(p_date_start,p_date_projected_start);
l_chk_dateend :=  nvl(p_date_end,p_date_projected_end);

if p_called_from <> 809 and  l_chk_datestart is not null and l_chk_dateend is not null
then
  hr_utility.set_location('inside otl hr check ', 10);

otl_hr_check
(
p_person_id  => p_person_id,
p_date_start => l_chk_datestart,
p_date_end   => l_chk_dateend,
p_scope      => 'CREATE',
p_ret_value  => l_retvalue );

  hr_utility.set_location('after otl hr check ', 10);
end if;

end if;
end if;



  l_effective_date        := trunc(p_effective_date);
  l_date_projected_start  := trunc(p_date_projected_start);
  l_date_projected_end    := trunc(p_date_projected_end);
  l_date_start            := trunc(p_date_start);
  l_date_end              := trunc(p_date_end);
  l_date_notification     := trunc(p_date_notification);
  l_absence_days          := p_absence_days;
  l_absence_hours         := p_absence_hours;

  --
  -- Call Before Process User Hook
  --
  begin
    hr_person_absence_bk1.create_person_absence_b
      (p_effective_date                => p_effective_date
      ,p_person_id                     => p_person_id
      ,p_business_group_id             => p_business_group_id
      ,p_absence_attendance_type_id    => p_absence_attendance_type_id
      ,p_abs_attendance_reason_id      => p_abs_attendance_reason_id
      ,p_comments                      => p_comments
      ,p_date_notification             => p_date_notification
      ,p_date_projected_start          => p_date_projected_start
      ,p_time_projected_start          => p_time_projected_start
      ,p_date_projected_end            => p_date_projected_end
      ,p_time_projected_end            => p_time_projected_end
      ,p_date_start                    => p_date_start
      ,p_time_start                    => p_time_start
      ,p_date_end                      => p_date_end
      ,p_time_end                      => p_time_end
      ,p_absence_days                  => l_absence_days
      ,p_absence_hours                 => l_absence_hours
      ,p_authorising_person_id         => p_authorising_person_id
      ,p_replacement_person_id         => p_replacement_person_id
      ,p_attribute_category            => p_attribute_category
      ,p_attribute1                    => p_attribute1
      ,p_attribute2                    => p_attribute2
      ,p_attribute3                    => p_attribute3
      ,p_attribute4                    => p_attribute4
      ,p_attribute5                    => p_attribute5
      ,p_attribute6                    => p_attribute6
      ,p_attribute7                    => p_attribute7
      ,p_attribute8                    => p_attribute8
      ,p_attribute9                    => p_attribute9
      ,p_attribute10                   => p_attribute10
      ,p_attribute11                   => p_attribute11
      ,p_attribute12                   => p_attribute12
      ,p_attribute13                   => p_attribute13
      ,p_attribute14                   => p_attribute14
      ,p_attribute15                   => p_attribute15
      ,p_attribute16                   => p_attribute16
      ,p_attribute17                   => p_attribute17
      ,p_attribute18                   => p_attribute18
      ,p_attribute19                   => p_attribute19
      ,p_attribute20                   => p_attribute20
      ,p_period_of_incapacity_id       => p_period_of_incapacity_id
      ,p_ssp1_issued                   => p_ssp1_issued
      ,p_maternity_id                  => p_maternity_id
      ,p_sickness_start_date           => p_sickness_start_date
      ,p_sickness_end_date             => p_sickness_end_date
      ,p_pregnancy_related_illness     => p_pregnancy_related_illness
      ,p_reason_for_notification_dela  => p_reason_for_notification_dela
      ,p_accept_late_notification_fla  => p_accept_late_notification_fla
      ,p_linked_absence_id             => p_linked_absence_id
      ,p_absence_case_id               => p_absence_case_id
      ,p_batch_id                      => p_batch_id
      ,p_create_element_entry          => p_create_element_entry
      ,p_abs_information_category      => p_abs_information_category
      ,p_abs_information1              => p_abs_information1
      ,p_abs_information2              => p_abs_information2
      ,p_abs_information3              => p_abs_information3
      ,p_abs_information4              => p_abs_information4
      ,p_abs_information5              => p_abs_information5
      ,p_abs_information6              => p_abs_information6
      ,p_abs_information7              => p_abs_information7
      ,p_abs_information8              => p_abs_information8
      ,p_abs_information9              => p_abs_information9
      ,p_abs_information10             => p_abs_information10
      ,p_abs_information11             => p_abs_information11
      ,p_abs_information12             => p_abs_information12
      ,p_abs_information13             => p_abs_information13
      ,p_abs_information14             => p_abs_information14
      ,p_abs_information15             => p_abs_information15
      ,p_abs_information16             => p_abs_information16
      ,p_abs_information17             => p_abs_information17
      ,p_abs_information18             => p_abs_information18
      ,p_abs_information19             => p_abs_information19
      ,p_abs_information20             => p_abs_information20
      ,p_abs_information21             => p_abs_information21
      ,p_abs_information22             => p_abs_information22
      ,p_abs_information23             => p_abs_information23
      ,p_abs_information24             => p_abs_information24
      ,p_abs_information25             => p_abs_information25
      ,p_abs_information26             => p_abs_information26
      ,p_abs_information27             => p_abs_information27
      ,p_abs_information28             => p_abs_information28
      ,p_abs_information29             => p_abs_information29
      ,p_abs_information30             => p_abs_information30


      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PERSON_ABSENCE'
        ,p_hook_type   => 'BP'
        );
  end;

  hr_utility.set_location(l_proc, 30);
  --
  -- Insert Person Absence
  per_abs_ins.ins
  (p_effective_date                 =>   l_effective_date
  ,p_business_group_id              =>   p_business_group_id
  ,p_absence_attendance_type_id     =>   p_absence_attendance_type_id
  ,p_person_id                      =>   p_person_id
  ,p_abs_attendance_reason_id       =>   p_abs_attendance_reason_id
  ,p_authorising_person_id          =>   p_authorising_person_id
  ,p_replacement_person_id          =>   p_replacement_person_id
  ,p_absence_days                   =>   l_absence_days
  ,p_absence_hours                  =>   l_absence_hours
  ,p_comments                       =>   p_comments
  ,p_date_end                       =>   l_date_end
  ,p_date_notification              =>   l_date_notification
  ,p_date_projected_end             =>   l_date_projected_end
  ,p_date_projected_start           =>   l_date_projected_start
  ,p_date_start                     =>   l_date_start
  ,p_occurrence                     =>   l_occurrence
  ,p_time_end                       =>   p_time_end
  ,p_time_projected_end             =>   p_time_projected_end
  ,p_time_projected_start           =>   p_time_projected_start
  ,p_time_start                     =>   p_time_start
  ,p_attribute_category             =>   p_attribute_category
  ,p_attribute1                     =>   p_attribute1
  ,p_attribute2                     =>   p_attribute2
  ,p_attribute3                     =>   p_attribute3
  ,p_attribute4                     =>   p_attribute4
  ,p_attribute5                     =>   p_attribute5
  ,p_attribute6                     =>   p_attribute6
  ,p_attribute7                     =>   p_attribute7
  ,p_attribute8                     =>   p_attribute8
  ,p_attribute9                     =>   p_attribute9
  ,p_attribute10                    =>   p_attribute10
  ,p_attribute11                    =>   p_attribute11
  ,p_attribute12                    =>   p_attribute12
  ,p_attribute13                    =>   p_attribute13
  ,p_attribute14                    =>   p_attribute14
  ,p_attribute15                    =>   p_attribute15
  ,p_attribute16                    =>   p_attribute16
  ,p_attribute17                    =>   p_attribute17
  ,p_attribute18                    =>   p_attribute18
  ,p_attribute19                    =>   p_attribute19
  ,p_attribute20                    =>   p_attribute20
  ,p_period_of_incapacity_id        =>   p_period_of_incapacity_id
  ,p_ssp1_issued                    =>   p_ssp1_issued
  ,p_maternity_id                   =>   p_maternity_id
  ,p_sickness_start_date            =>   p_sickness_start_date
  ,p_sickness_end_date              =>   p_sickness_end_date
  ,p_pregnancy_related_illness      =>   p_pregnancy_related_illness
  ,p_reason_for_notification_dela   =>   p_reason_for_notification_dela
  ,p_accept_late_notification_fla   =>   p_accept_late_notification_fla
  ,p_linked_absence_id              =>   p_linked_absence_id
  ,p_absence_case_id                =>   p_absence_case_id
  ,p_batch_id                       =>   p_batch_id
  ,p_abs_information_category       =>   p_abs_information_category
  ,p_abs_information1               =>   p_abs_information1
  ,p_abs_information2               =>   p_abs_information2
  ,p_abs_information3               =>   p_abs_information3
  ,p_abs_information4               =>   p_abs_information4
  ,p_abs_information5               =>   p_abs_information5
  ,p_abs_information6               =>   p_abs_information6
  ,p_abs_information7               =>   p_abs_information7
  ,p_abs_information8               =>   p_abs_information8
  ,p_abs_information9               =>   p_abs_information9
  ,p_abs_information10              =>   p_abs_information10
  ,p_abs_information11              =>   p_abs_information11
  ,p_abs_information12              =>   p_abs_information12
  ,p_abs_information13              =>   p_abs_information13
  ,p_abs_information14              =>   p_abs_information14
  ,p_abs_information15              =>   p_abs_information15
  ,p_abs_information16              =>   p_abs_information16
  ,p_abs_information17              =>   p_abs_information17
  ,p_abs_information18              =>   p_abs_information18
  ,p_abs_information19              =>   p_abs_information19
  ,p_abs_information20              =>   p_abs_information20
  ,p_abs_information21              =>   p_abs_information21
  ,p_abs_information22              =>   p_abs_information22
  ,p_abs_information23              =>   p_abs_information23
  ,p_abs_information24              =>   p_abs_information24
  ,p_abs_information25              =>   p_abs_information25
  ,p_abs_information26              =>   p_abs_information26
  ,p_abs_information27              =>   p_abs_information27
  ,p_abs_information28              =>   p_abs_information28
  ,p_abs_information29              =>   p_abs_information29
  ,p_abs_information30              =>   p_abs_information30
   ,p_program_application_id        => p_program_application_id
  ,p_absence_attendance_id          =>   l_absence_attendance_id
  ,p_object_version_number          =>   l_object_version_number
  ,p_dur_dys_less_warning           =>   l_dur_dys_less_warning
  ,p_dur_hrs_less_warning           =>   l_dur_hrs_less_warning
  ,p_exceeds_pto_entit_warning      =>   l_exceeds_pto_entit_warning
  ,p_exceeds_run_total_warning      =>   l_exceeds_run_total_warning
  ,p_abs_overlap_warning            =>   l_abs_overlap_warning
  ,p_abs_day_after_warning          =>   l_abs_day_after_warning
  ,p_dur_overwritten_warning        =>   l_dur_overwritten_warning
  );

  p_dur_dys_less_warning      := l_dur_dys_less_warning;
  p_dur_hrs_less_warning      := l_dur_hrs_less_warning;
  p_exceeds_pto_entit_warning := l_exceeds_pto_entit_warning;
  p_exceeds_run_total_warning := l_exceeds_run_total_warning;
  p_abs_overlap_warning       := l_abs_overlap_warning;
  p_abs_day_after_warning     := l_abs_day_after_warning;
  p_dur_overwritten_warning   := l_dur_overwritten_warning;

  hr_utility.set_location('Start of absence element entry section', 40);

/* Start of Absence Element Entry Section */

  if p_create_element_entry then
    --
    -- Insert the absence element element. First we check if the
    -- absence type is linked to an element type.
    --

    if linked_to_element
       (p_absence_attendance_id => l_absence_attendance_id)
    then

      --
      -- Get the assignment_id and processing type for use later
      --
      l_assignment_id := get_primary_assignment
                         (p_person_id      => p_person_id
                         ,p_effective_date => p_date_start);

      l_processing_type := get_processing_type
        (p_absence_attendance_type_id => p_absence_attendance_type_id);


      if (l_processing_type = 'N'
          and p_date_start is not null
          and p_date_end is not null)
      or (l_processing_type = 'R'
          and p_date_start is not null)
      then

         insert_absence_element
           (p_date_start            => p_date_start
           ,p_assignment_id         => l_assignment_id
           ,p_absence_attendance_id => l_absence_attendance_id
           ,p_element_entry_id      => l_element_entry_id);

         if l_processing_type = 'R' and p_date_end is not null then
            --
            -- If this is a recurring element entry and we have the
            -- absence end date, we date effectively delete the
            -- element immediately, otherwise it remains open until
            -- the end of time.
            --

             delete_absence_element
              (p_dt_delete_mode        => 'DELETE'
              ,p_session_date          => p_date_end
              ,p_element_entry_id      => l_element_entry_id);

         end if;

      end if;

    end if;

  end if;
/* End of Absence Element Entry Section */

  hr_utility.set_location('End of absence element entry section', 50);

  populate_ben_absence_rec
  (p_absence_attendance_id => l_absence_attendance_id,
   p_rec_type => 'N',
   p_ben_rec => l_new);

  --
  -- Start of BEN call.
  --
  hr_utility.set_location('Start of BEN call', 52);

  ben_abs_ler.ler_chk
    (p_old            => l_old
    ,p_new            => l_new
    ,p_effective_date => l_effective_date);

  hr_utility.set_location('End of BEN call', 54);

  --
  -- Call After Process User Hook
  --

  begin
    hr_person_absence_bk1.create_person_absence_a
      (p_effective_date                => p_effective_date
      ,p_person_id                     => p_person_id
      ,p_business_group_id             => p_business_group_id
      ,p_absence_attendance_type_id    => p_absence_attendance_type_id
      ,p_abs_attendance_reason_id      => p_abs_attendance_reason_id
      ,p_comments                      => p_comments
      ,p_date_notification             => p_date_notification
      ,p_date_projected_start          => p_date_projected_start
      ,p_time_projected_start          => p_time_projected_start
      ,p_date_projected_end            => p_date_projected_end
      ,p_time_projected_end            => p_time_projected_end
      ,p_date_start                    => p_date_start
      ,p_time_start                    => p_time_start
      ,p_date_end                      => p_date_end
      ,p_time_end                      => p_time_end
      ,p_absence_days                  => l_absence_days
      ,p_absence_hours                 => l_absence_hours
      ,p_authorising_person_id         => p_authorising_person_id
      ,p_replacement_person_id         => p_replacement_person_id
      ,p_attribute_category            => p_attribute_category
      ,p_attribute1                    => p_attribute1
      ,p_attribute2                    => p_attribute2
      ,p_attribute3                    => p_attribute3
      ,p_attribute4                    => p_attribute4
      ,p_attribute5                    => p_attribute5
      ,p_attribute6                    => p_attribute6
      ,p_attribute7                    => p_attribute7
      ,p_attribute8                    => p_attribute8
      ,p_attribute9                    => p_attribute9
      ,p_attribute10                   => p_attribute10
      ,p_attribute11                   => p_attribute11
      ,p_attribute12                   => p_attribute12
      ,p_attribute13                   => p_attribute13
      ,p_attribute14                   => p_attribute14
      ,p_attribute15                   => p_attribute15
      ,p_attribute16                   => p_attribute16
      ,p_attribute17                   => p_attribute17
      ,p_attribute18                   => p_attribute18
      ,p_attribute19                   => p_attribute19
      ,p_attribute20                   => p_attribute20
      ,p_occurrence                    => l_occurrence
      ,p_period_of_incapacity_id       => p_period_of_incapacity_id
      ,p_ssp1_issued                   => p_ssp1_issued
      ,p_maternity_id                  => p_maternity_id
      ,p_sickness_start_date           => p_sickness_start_date
      ,p_sickness_end_date             => p_sickness_end_date
      ,p_pregnancy_related_illness     => p_pregnancy_related_illness
      ,p_reason_for_notification_dela  => p_reason_for_notification_dela
      ,p_accept_late_notification_fla  => p_accept_late_notification_fla
      ,p_linked_absence_id             => p_linked_absence_id
      ,p_absence_case_id               => p_absence_case_id
      ,p_batch_id                      => p_batch_id
      ,p_create_element_entry          => p_create_element_entry
      ,p_abs_information_category      => p_abs_information_category
      ,p_abs_information1              => p_abs_information1
      ,p_abs_information2              => p_abs_information2
      ,p_abs_information3              => p_abs_information3
      ,p_abs_information4              => p_abs_information4
      ,p_abs_information5              => p_abs_information5
      ,p_abs_information6              => p_abs_information6
      ,p_abs_information7              => p_abs_information7
      ,p_abs_information8              => p_abs_information8
      ,p_abs_information9              => p_abs_information9
      ,p_abs_information10             => p_abs_information10
      ,p_abs_information11             => p_abs_information11
      ,p_abs_information12             => p_abs_information12
      ,p_abs_information13             => p_abs_information13
      ,p_abs_information14             => p_abs_information14
      ,p_abs_information15             => p_abs_information15
      ,p_abs_information16             => p_abs_information16
      ,p_abs_information17             => p_abs_information17
      ,p_abs_information18             => p_abs_information18
      ,p_abs_information19             => p_abs_information19
      ,p_abs_information20             => p_abs_information20
      ,p_abs_information21             => p_abs_information21
      ,p_abs_information22             => p_abs_information22
      ,p_abs_information23             => p_abs_information23
      ,p_abs_information24             => p_abs_information24
      ,p_abs_information25             => p_abs_information25
      ,p_abs_information26             => p_abs_information26
      ,p_abs_information27             => p_abs_information27
      ,p_abs_information28             => p_abs_information28
      ,p_abs_information29             => p_abs_information29
      ,p_abs_information30             => p_abs_information30
      ,p_absence_attendance_id         => l_absence_attendance_id
      ,p_object_version_number         => l_object_version_number
      ,p_dur_dys_less_warning          => l_dur_dys_less_warning
      ,p_dur_hrs_less_warning          => l_dur_hrs_less_warning
      ,p_exceeds_pto_entit_warning     => l_exceeds_pto_entit_warning
      ,p_exceeds_run_total_warning     => l_exceeds_run_total_warning
      ,p_abs_overlap_warning           => l_abs_overlap_warning
      ,p_abs_day_after_warning         => l_abs_day_after_warning
      ,p_dur_overwritten_warning       => l_dur_overwritten_warning
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_PERSON_ABSENCE'
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
  p_absence_attendance_id  := l_absence_attendance_id;
  p_object_version_number  := l_object_version_number;
  p_absence_days           := l_absence_days;
  p_absence_hours          := l_absence_hours;
  p_occurrence             := l_occurrence;
  --

  --
  -- Pipe the main IN OUT / OUT parameters for ease of debugging.
  --
  hr_utility.trace(' ');
  hr_utility.trace(' --------------------------------'||
                   '---------------------------------');
  hr_utility.trace(' IN OUT NOCOPY / OUT NOCOPY PARAMETER          '||
                   ' VALUE');
  hr_utility.trace(' --------------------------------'||
                   '+--------------------------------');
  hr_utility.trace('  p_absence_days                   '||
                      to_char(p_absence_days));
  hr_utility.trace('  p_absence_hours                  '||
                      to_char(p_absence_hours));
  hr_utility.trace('  p_absence_attendance_id          '||
                      to_char(p_absence_attendance_id));
  hr_utility.trace('  p_object_version_number          '||
                      to_char(p_object_version_number));
  hr_utility.trace('  p_occurrence                     '||
                      to_char(p_occurrence));
  hr_utility.trace(' --------------------------------'||
                   '---------------------------------');
  hr_utility.trace(' ');

  hr_utility.set_location(' Leaving:'||l_proc, 70);

exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_person_absence;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_absence_attendance_id  := null;
    p_object_version_number  := null;
    hr_utility.set_location(l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_absence_attendance_id         := null;
    p_object_version_number         := null;
    p_occurrence                    := null;
    p_dur_dys_less_warning          := null;
    p_dur_hrs_less_warning          := null;
    p_exceeds_pto_entit_warning     := null;
    p_exceeds_run_total_warning     := null;
    p_abs_overlap_warning           := null;
    p_abs_day_after_warning         := null;
    p_dur_overwritten_warning       := null;

    rollback to create_person_absence;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_person_absence;
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_person_absence >---------------------------|
-- ----------------------------------------------------------------------------
--
 procedure update_person_absence
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_absence_attendance_id         in     number
  ,p_abs_attendance_reason_id      in     number   default hr_api.g_number
  ,p_comments                      in     long     default hr_api.g_varchar2
  ,p_date_notification             in     date     default hr_api.g_date
  ,p_date_projected_start          in     date     default hr_api.g_date
  ,p_time_projected_start          in     varchar2 default hr_api.g_varchar2
  ,p_date_projected_end            in     date     default hr_api.g_date
  ,p_time_projected_end            in     varchar2 default hr_api.g_varchar2
  ,p_date_start                    in     date     default hr_api.g_date
  ,p_time_start                    in     varchar2 default hr_api.g_varchar2
  ,p_date_end                      in     date     default hr_api.g_date
  ,p_time_end                      in     varchar2 default hr_api.g_varchar2
  ,p_absence_days                  in out nocopy number
  ,p_absence_hours                 in out nocopy number
  ,p_authorising_person_id         in     number   default hr_api.g_number
  ,p_replacement_person_id         in     number   default hr_api.g_number
  ,p_attribute_category            in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                   in     varchar2 default hr_api.g_varchar2
  ,p_period_of_incapacity_id       in     number   default hr_api.g_number
  ,p_ssp1_issued                   in     varchar2 default hr_api.g_varchar2
  ,p_maternity_id                  in     number   default hr_api.g_number
  ,p_sickness_start_date           in     date     default hr_api.g_date
  ,p_sickness_end_date             in     date     default hr_api.g_date
  ,p_pregnancy_related_illness     in     varchar2 default hr_api.g_varchar2
  ,p_reason_for_notification_dela  in     varchar2 default hr_api.g_varchar2
  ,p_accept_late_notification_fla  in     varchar2 default hr_api.g_varchar2
  ,p_linked_absence_id             in     number   default hr_api.g_number
  ,p_batch_id                      in     number   default hr_api.g_number
  ,p_abs_information_category      in     varchar2 default hr_api.g_varchar2
  ,p_abs_information1              in     varchar2 default hr_api.g_varchar2
  ,p_abs_information2              in     varchar2 default hr_api.g_varchar2
  ,p_abs_information3              in     varchar2 default hr_api.g_varchar2
  ,p_abs_information4              in     varchar2 default hr_api.g_varchar2
  ,p_abs_information5              in     varchar2 default hr_api.g_varchar2
  ,p_abs_information6              in     varchar2 default hr_api.g_varchar2
  ,p_abs_information7              in     varchar2 default hr_api.g_varchar2
  ,p_abs_information8              in     varchar2 default hr_api.g_varchar2
  ,p_abs_information9              in     varchar2 default hr_api.g_varchar2
  ,p_abs_information10             in     varchar2 default hr_api.g_varchar2
  ,p_abs_information11             in     varchar2 default hr_api.g_varchar2
  ,p_abs_information12             in     varchar2 default hr_api.g_varchar2
  ,p_abs_information13             in     varchar2 default hr_api.g_varchar2
  ,p_abs_information14             in     varchar2 default hr_api.g_varchar2
  ,p_abs_information15             in     varchar2 default hr_api.g_varchar2
  ,p_abs_information16             in     varchar2 default hr_api.g_varchar2
  ,p_abs_information17             in     varchar2 default hr_api.g_varchar2
  ,p_abs_information18             in     varchar2 default hr_api.g_varchar2
  ,p_abs_information19             in     varchar2 default hr_api.g_varchar2
  ,p_abs_information20             in     varchar2 default hr_api.g_varchar2
  ,p_abs_information21             in     varchar2 default hr_api.g_varchar2
  ,p_abs_information22             in     varchar2 default hr_api.g_varchar2
  ,p_abs_information23             in     varchar2 default hr_api.g_varchar2
  ,p_abs_information24             in     varchar2 default hr_api.g_varchar2
  ,p_abs_information25             in     varchar2 default hr_api.g_varchar2
  ,p_abs_information26             in     varchar2 default hr_api.g_varchar2
  ,p_abs_information27             in     varchar2 default hr_api.g_varchar2
  ,p_abs_information28             in     varchar2 default hr_api.g_varchar2
  ,p_abs_information29             in     varchar2 default hr_api.g_varchar2
  ,p_abs_information30             in     varchar2 default hr_api.g_varchar2
  ,p_absence_case_id               in     number   default hr_api.g_number
    ,p_program_application_id        in     number   default 800
  ,p_called_from                   in     number   default 800
  ,p_object_version_number         in out nocopy number
  ,p_dur_dys_less_warning          out nocopy    boolean
  ,p_dur_hrs_less_warning          out nocopy    boolean
  ,p_exceeds_pto_entit_warning     out nocopy    boolean
  ,p_exceeds_run_total_warning     out nocopy    boolean
  ,p_abs_overlap_warning           out nocopy    boolean
  ,p_abs_day_after_warning         out nocopy    boolean
  ,p_dur_overwritten_warning       out nocopy    boolean
  ,p_del_element_entry_warning     out nocopy    boolean
  ) is
  --
  -- Declare cursors and local variables
  --

 cursor c_get_absence_dates is
        select  abs.date_start, abs.date_end,
	abs.DATE_PROJECTED_START,abs.DATE_PROJECTED_END,
	abs.TIME_START , abs.TIME_END,
	abs.TIME_PROJECTED_START ,abs.TIME_PROJECTED_END
        from   per_absence_attendances abs
        where  abs.absence_attendance_id = p_absence_attendance_id;

  cursor c_get_absence_details is
         select abs.person_id,
         abs.absence_attendance_type_id,
	 abs.date_start,
	 abs.date_end
         from   per_absence_attendances abs
         where  abs.absence_attendance_id = p_absence_attendance_id;


  cursor c_get_person_id is
         select abs.person_id
         from   per_absence_attendances abs
         where  abs.absence_attendance_id = p_absence_attendance_id;

l_csrperson_id number;
l_retvalue  varchar2(10);
l_datestart date;
l_dateend date;
l_prjdatestart date;
l_prjdateend date;
l_timestart varchar2(10);
l_timeend varchar2(10);
l_prjtimestart varchar2(10);
l_prjtimeend varchar2(10);

ls_datestart date;
ls_dateend date;
ls_prjdatestart date;
ls_prjdateend date;
ls_timestart varchar2(10);
ls_timeend varchar2(10);
ls_prjtimestart varchar2(10);
ls_prjtimeend varchar2(10);
l_glb_date date :=to_date('01-01--4712', 'DD-MM-SYYYY');
l_glb_var  varchar2(10) :='$Sys_Def$';




  l_proc                varchar2(72) := g_package||'update_person_absence';
  l_date_projected_start       date;
  l_date_projected_end         date;
  l_date_start                 date;
  l_date_end                   date;
  l_date_notification          date;
  l_effective_date             date;
  l_old                        ben_abs_ler.g_abs_ler_rec;
  l_new                        ben_abs_ler.g_abs_ler_rec;
  --
  lv_object_version_number      number;
  lv_absence_days               number;
  lv_absence_hours              number;

  -- For bug 5454141

  l_date_start1 date;
  l_date_end1 date;
  l_date_start_for_absence date;
  l_date_end_for_absence date;

  -- End of added parameters for bug 5454141

  -- Declare out parameters
  --
  l_object_version_number      number;
  l_absence_days               number;
  l_absence_hours              number;
  l_person_id                  number;
  l_absence_attendance_type_id number;
  l_assignment_id              number;
  l_element_entry_id           number;
  l_effective_start_date       date;
  l_effective_end_date         date;
  l_processing_type            pay_element_types_f.processing_type%TYPE;
  l_dur_dys_less_warning       boolean;
  l_dur_hrs_less_warning       boolean;
  l_exceeds_pto_entit_warning  boolean;
  l_exceeds_run_total_warning  boolean;
  l_abs_overlap_warning        boolean;
  l_abs_day_after_warning      boolean;
  l_dur_overwritten_warning    boolean;
  l_del_element_entry_warning  boolean := FALSE;

  --

l_hours_or_days varchar2(2);

cursor csr_get_abstype is
select HOURS_OR_DAYS,INPUT_VALUE_ID
from per_absence_attendance_types
where absence_attendance_type_id= (select absence_attendance_type_id
from per_absence_attendances where ABSENCE_ATTENDANCE_ID  = p_absence_attendance_id);



l_chk_datestart date;
l_chk_dateend date;
l_enty_efsd date;
l_entry_efed date;
l_elm_entry_id number;
l_chk_abs_type_id number;

--

begin

  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  lv_object_version_number      := p_object_version_number ;
  lv_absence_days               := p_absence_days ;
  lv_absence_hours              := p_absence_hours ;

  -- Issue a savepoint
  --
  savepoint update_person_absence;

  --
  -- Pipe the main IN / IN OUT parameters for ease of debugging.
  --
  hr_utility.trace(' ');
  hr_utility.trace(' --------------------------------'||
                   '---------------------------------');
  hr_utility.trace(' IN / IN OUT NOCOPY PARAMETER           '||
                   ' VALUE');
  hr_utility.trace(' --------------------------------'||
                   '+--------------------------------');
  hr_utility.trace('  p_effective_date                 '||
                      to_char(p_effective_date));
  hr_utility.trace('  p_absence_attendance_id          '||
                      to_char(p_absence_attendance_id));
  hr_utility.trace('  p_abs_attendance_reason_id       '||
                      to_char(p_abs_attendance_reason_id));
  hr_utility.trace('  p_date_notification              '||
                      to_char(p_date_notification));
  hr_utility.trace('  p_date_projected_start           '||
                      to_char(p_date_projected_start));
  hr_utility.trace('  p_time_projected_start           '||
                      p_time_projected_start);
  hr_utility.trace('  p_date_projected_end             '||
                      to_char(p_date_projected_end));
  hr_utility.trace('  p_time_projected_end             '||
                      p_time_projected_end);
  hr_utility.trace('  p_date_start                     '||
                      to_char(p_date_start));
  hr_utility.trace('  p_time_start                     '||
                      p_time_start);
  hr_utility.trace('  p_date_end                       '||
                      to_char(p_date_end));
  hr_utility.trace('  p_time_end                       '||
                      p_time_end);
  hr_utility.trace('  p_absence_days                   '||
                      to_char(p_absence_days));
  hr_utility.trace('  p_absence_hours                  '||
                      to_char(p_absence_hours));
  hr_utility.trace('  p_authorising_person_id          '||
                      to_char(p_authorising_person_id));
  hr_utility.trace('  p_batch_id                       '||
                      to_char(p_batch_id));
  hr_utility.trace('  p_object_version_number          '||
                      to_char(p_object_version_number));
  hr_utility.trace(' --------------------------------'||
                   '---------------------------------');
  hr_utility.trace(' ');

  --
if nvl(FND_PROFILE.Value('HR_ABS_OTL_INTEGRATION'),'N') = 'Y' then


open csr_get_abstype;
fetch csr_get_abstype into l_hours_or_days,l_elm_entry_id;
close csr_get_abstype;

if l_elm_entry_id is not null then

open c_get_person_id;
fetch c_get_person_id into l_csrperson_id;
close c_get_person_id;

l_datestart:= p_date_start;
l_dateend  := p_date_end;
l_prjdatestart:=p_date_projected_start;
l_prjdateend:=p_date_projected_end;
l_timestart:=p_time_start;
l_timeend:=p_time_end;
l_prjtimestart:=p_time_projected_start;
l_prjtimeend :=p_time_projected_end;


hr_utility.set_location(' l_date_start  ' ||l_datestart,20);
hr_utility.set_location(' p_date_start  ' ||p_date_start,22);
hr_utility.set_location(' l_dateend  '|| l_dateend,22);
hr_utility.set_location(' l_prjdatestart  ' || l_prjdatestart,22);
hr_utility.set_location(' l_prjdateend  ' || l_prjdateend,22);
hr_utility.set_location(' l_timestart  ' || l_timestart,22);
hr_utility.set_location(' l_timeend  ' || l_timeend,22);
hr_utility.set_location(' l_prjtimestart  ' || l_prjtimestart,22);
hr_utility.set_location(' l_prjtimeend  ' || l_prjtimeend,22);

if p_date_start =hr_api.g_date or p_date_end = hr_api.g_date
	 or p_date_projected_start =hr_api.g_date or p_date_projected_end = hr_api.g_date
   or p_time_start =hr_api.g_varchar2 or p_time_end = hr_api.g_varchar2
   or p_time_projected_start =hr_api.g_varchar2 or p_time_projected_end = hr_api.g_varchar2  then

  open c_get_absence_dates;
  fetch c_get_absence_dates into l_datestart,l_dateend,l_prjdatestart,
				l_prjdateend,l_timestart,l_timeend,l_prjtimestart,l_prjtimeend;
  close c_get_absence_dates;
hr_utility.set_location(' l_date_start  ' ||l_date_start,20);
 if p_date_start <> hr_api.g_date and l_datestart is not null then
    l_datestart :=p_date_start;
 end if;

  if p_date_end <> hr_api.g_date and l_dateend is not null then
    l_dateend :=p_date_end;
 end if;


 if p_date_projected_start <> hr_api.g_date and l_prjdatestart is not null then
    l_prjdatestart :=p_date_projected_start;
 end if;

  if p_date_projected_end <> hr_api.g_date and l_prjdateend is not null then
    l_prjdateend :=p_date_projected_end;
 end if;

 if p_time_projected_start <> hr_api.g_varchar2 and l_timestart is not null then
    l_prjtimestart :=p_time_projected_start;
 end if;

  if p_time_projected_end <> hr_api.g_varchar2 and l_prjtimeend is not null then
    l_prjtimeend :=p_time_projected_end;
 end if;


 if p_time_start <> hr_api.g_varchar2 and l_timestart is not null then
    l_timestart :=p_time_start;
 end if;

  if p_time_end <> hr_api.g_varchar2 and l_timeend is not null then
    l_timeend :=p_time_end;
 end if;


end if;

hr_utility.set_location(' l_hours_or_days  ' ||l_hours_or_days,250);
hr_utility.set_location(' l_datestart  ' ||l_datestart,30);

hr_utility.set_location(' p_date_start  ' ||p_date_start,30);
hr_utility.set_location(' l_dateend  '|| l_dateend,30);
hr_utility.set_location(' l_prjdatestart  ' || l_prjdatestart,30);
hr_utility.set_location(' l_prjdateend  ' || l_prjdateend,30);
hr_utility.set_location(' l_timestart  ' || l_timestart,30);
hr_utility.set_location(' l_timeend  ' || l_timeend,30);
hr_utility.set_location(' l_prjtimestart  ' || l_prjtimestart,30);
hr_utility.set_location(' l_prjtimeend  ' || l_prjtimeend,30);

if l_hours_or_days ='H' then
-- when the UOM attached to the element is Hours

if  ( l_datestart is null ) then

 if ( l_prjdatestart is null  ) then
     hr_utility.set_message (800,'HR_449868_START_END_DATES5');
     hr_utility.raise_error;
    end if;

     --if p_time_projected_start is null  or p_date_projected_end = hr_api.g_date or p_time_projected_end is null then

     if (l_prjtimestart is null)  or (l_prjdateend is null  ) or (l_prjtimeend is null ) then

     hr_utility.set_location(' l_hours_or_days 30  ' ||l_hours_or_days,30);
     hr_utility.set_message(800, 'HR_449866_START_END_DATES3');
     hr_utility.raise_error;
     end if;

    hr_utility.set_location(' l_hours_or_days  ' ||l_hours_or_days,20);
    hr_utility.set_location(' l_hours_or_days  ' ||l_hours_or_days,40);

else

   if (l_dateend is null  ) or ( l_timeend is null) or(l_timestart is null ) then
   hr_utility.set_message (800,'HR_449867_START_END_DATES4');
   hr_utility.raise_error;
   end if;

end if;

else

-- when the UOM is Days

hr_utility.set_location(' l_hours_or_days  ' ||l_hours_or_days,25);


if l_datestart is null then


    if l_prjdatestart is null then
     hr_utility.set_message (800,'HR_449868_START_END_DATES5');
     hr_utility.raise_error;

		elsif  l_prjdateend is null then

     hr_utility.set_message (800,'HR_449864_START_END_DATES1');
     hr_utility.raise_error;
     end if;

  else

/*    if (p_date_projected_start is null or p_date_projected_start= hr_api.g_date)
			 and ( p_date_projected_end is null or p_date_projected_end = hr_api.g_date) then

   hr_utility.set_message (800,'HR_449864_START_END_DATES1');
   hr_utility.raise_error;
   end if;
*/

   if l_dateend is null  then

   hr_utility.set_message (800,'HR_449865_START_END_DATES2');
   hr_utility.raise_error;
   end if;

end if;

end if;

l_chk_datestart := nvl(l_datestart,l_prjdatestart);
l_chk_dateend :=  nvl(l_dateend,l_prjdateend);

if p_called_from <> 809 and  l_chk_datestart is not null and l_chk_dateend is not null
then
  hr_utility.set_location('inside otl hr check ', 10);

otl_hr_check
(
p_person_id  => l_csrperson_id,
p_date_start => l_chk_datestart,
p_date_end   => l_chk_dateend,
p_scope 	   => 'UPDATE',
p_ret_value  => l_retvalue );


  hr_utility.set_location('after otl hr check ', 10);

end if;

 -- to allow the projected leaves to get confirmed
-- when elementry id is null

 hr_utility.set_location('l_retvalue'||l_retvalue, 10);

 if l_retvalue ='RESTRICT' THEN


hr_utility.set_location(' p_date_projected_start'||p_date_projected_start, 10);
hr_utility.set_location('p_time_projected_start'||p_time_projected_start, 10);
hr_utility.set_location('p_date_projected_end'||p_date_projected_end, 10);
hr_utility.set_location('p_time_projected_end'||p_time_projected_end, 10);
hr_utility.set_location('p_date_start'||p_date_start, 10);
hr_utility.set_location('p_date_end'||p_date_end, 10);
hr_utility.set_location('p_time_start'||p_time_start, 10);
hr_utility.set_location('p_time_end'||p_time_end, 10);

 open c_get_absence_dates;
  fetch c_get_absence_dates into l_datestart,l_dateend,l_prjdatestart,
				l_prjdateend,l_timestart,l_timeend,l_prjtimestart,l_prjtimeend;
  close c_get_absence_dates;


if p_date_projected_start is null or p_date_projected_start =hr_api.g_date then
   ls_prjdatestart := l_prjdatestart;
  else
  ls_prjdatestart :=p_date_projected_start;
end if;

if p_date_projected_end is null or p_date_projected_end =hr_api.g_date then
   ls_prjdateend := l_prjdateend;
  else
  ls_prjdateend :=p_date_projected_end;
end if;

if p_time_projected_start is null or p_time_projected_start = hr_api.g_varchar2 then
   ls_prjtimestart := l_prjtimestart;
  else
  ls_prjtimestart := p_time_projected_start;
end if;

if p_time_projected_end is null or p_time_projected_end =hr_api.g_varchar2 then
   ls_prjtimeend := l_prjtimeend;
  else
  ls_prjtimeend :=p_time_projected_end;
end if;

if p_date_start is null or p_date_start =hr_api.g_date then
   ls_datestart := l_datestart;
  else
  ls_datestart :=p_date_start;
end if;

if p_date_end is null or p_date_end =hr_api.g_date then
   ls_dateend := l_dateend;
  else
  ls_dateend :=p_date_end;
end if;

if p_time_start is null or p_time_start =hr_api.g_varchar2 then
   ls_timestart := l_timestart;
  else
  ls_timestart :=p_time_start;
end if;

if p_time_end is null or p_time_end =hr_api.g_varchar2 then
   ls_timeend := l_timeend;
  else
  ls_timeend :=p_time_end;
end if;



hr_utility.set_location(' l_datestart'|| l_datestart, 10);
hr_utility.set_location(' l_dateend'|| l_dateend , 10);
hr_utility.set_location(' l_prjdatestart'|| l_prjdatestart , 10);
hr_utility.set_location(' l_prjdateend'|| l_prjdateend , 10);
hr_utility.set_location(' l_timestart'|| l_timestart , 10);
hr_utility.set_location(' l_timeend'|| l_timeend , 10);
hr_utility.set_location(' l_prjtimestart'|| l_prjtimestart , 10);
hr_utility.set_location(' l_prjtimeend'|| l_prjtimeend , 10);


hr_utility.set_location(' ls_prjdatestart'|| ls_prjdatestart,20);
hr_utility.set_location(' ls_prjdateend'|| ls_prjdateend , 20);
hr_utility.set_location(' ls_prjtimestart'|| ls_prjtimestart , 20);
hr_utility.set_location(' ls_prjtimeend'|| ls_prjtimeend ,20);
hr_utility.set_location(' ls_datestart'|| ls_datestart , 20);
hr_utility.set_location(' ls_dateend'|| ls_dateend , 20);
hr_utility.set_location(' ls_timestart'|| ls_timestart , 20);
hr_utility.set_location(' ls_timeend'|| ls_timeend ,20);

if l_datestart is null and p_date_start is not null then
 hr_utility.set_location('before comparing  dates', 5);

    IF nvl(ls_prjdatestart,l_glb_date) <> nvl(l_prjdatestart,l_glb_date)
       or nvl(ls_prjdateend,l_glb_date) <>  nvl(l_prjdateend,l_glb_date)
       or nvl(ls_prjtimestart,l_glb_var)<> nvl(l_prjtimestart,l_glb_var)
       or nvl(ls_prjtimeend,l_glb_var)<> nvl(l_prjtimeend,l_glb_var)
       or nvl(ls_datestart,l_glb_date) <>  nvl(p_date_start,l_glb_date)
       or nvl(ls_dateend,l_glb_date) <> nvl(p_date_end,l_glb_date)
       or nvl(ls_timestart,l_glb_var) <> nvl(p_time_start,l_glb_var)
       or nvl(ls_timeend,l_glb_var) <> nvl(p_time_end,l_glb_var)
       or nvl(p_date_start,l_prjdatestart) <> nvl (l_prjdatestart,p_date_start)
       or nvl(p_date_end,l_prjdateend) <> nvl(l_prjdateend,p_date_end)
       or nvl(p_time_start,l_prjtimestart) <> nvl (l_prjtimestart,p_time_start)
       or nvl(p_time_end,l_prjtimeend) <> nvl (l_prjtimeend,p_time_end)


  then

 hr_utility.set_location('While confirming dates should not be changed', 10);

      hr_utility.set_location('otl hr UPDATE check ', 60);
		     hr_utility.set_message(800,'HR_50433_OTL_CARD_EXISTS');
		      hr_utility.raise_error;
END IF;
end if;
END IF;

end if;

end if;
--
--


  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date        := trunc(p_effective_date);
  l_date_notification     := trunc(p_date_notification);
  l_date_projected_start  := trunc(p_date_projected_start);
  l_date_projected_end    := trunc(p_date_projected_end);
  l_date_start            := trunc(p_date_start);
  l_date_end              := trunc(p_date_end);

  l_absence_days          := p_absence_days;
  l_absence_hours         := p_absence_hours;

  hr_utility.trace('Old Dur Dys: '||to_char(l_absence_days));
  hr_utility.trace('Old Dur Hrs: '||to_char(l_absence_hours));

  --
  -- Call Before Process User Hook
  --
  begin
    hr_person_absence_bk2.update_person_absence_b
      (p_effective_date                => l_effective_date
      ,p_absence_attendance_id         => p_absence_attendance_id
      ,p_object_version_number         => p_object_version_number
      ,p_abs_attendance_reason_id      => p_abs_attendance_reason_id
      ,p_comments                      => p_comments
      ,p_date_notification             => l_date_notification
      ,p_date_projected_start          => l_date_projected_start
      ,p_time_projected_start          => p_time_projected_start
      ,p_date_projected_end            => l_date_projected_end
      ,p_time_projected_end            => p_time_projected_end
      ,p_date_start                    => l_date_start
      ,p_time_start                    => p_time_start
      ,p_date_end                      => l_date_end
      ,p_time_end                      => p_time_end
      ,p_absence_days                  => l_absence_days
      ,p_absence_hours                 => l_absence_hours
      ,p_authorising_person_id         => p_authorising_person_id
      ,p_replacement_person_id         => p_replacement_person_id
      ,p_attribute_category            => p_attribute_category
      ,p_attribute1                    => p_attribute1
      ,p_attribute2                    => p_attribute2
      ,p_attribute3                    => p_attribute3
      ,p_attribute4                    => p_attribute4
      ,p_attribute5                    => p_attribute5
      ,p_attribute6                    => p_attribute6
      ,p_attribute7                    => p_attribute7
      ,p_attribute8                    => p_attribute8
      ,p_attribute9                    => p_attribute9
      ,p_attribute10                   => p_attribute10
      ,p_attribute11                   => p_attribute11
      ,p_attribute12                   => p_attribute12
      ,p_attribute13                   => p_attribute13
      ,p_attribute14                   => p_attribute14
      ,p_attribute15                   => p_attribute15
      ,p_attribute16                   => p_attribute16
      ,p_attribute17                   => p_attribute17
      ,p_attribute18                   => p_attribute18
      ,p_attribute19                   => p_attribute19
      ,p_attribute20                   => p_attribute20
      ,p_period_of_incapacity_id       => p_period_of_incapacity_id
      ,p_ssp1_issued                   => p_ssp1_issued
      ,p_maternity_id                  => p_maternity_id
      ,p_sickness_start_date           => p_sickness_start_date
      ,p_sickness_end_date             => p_sickness_end_date
      ,p_pregnancy_related_illness     => p_pregnancy_related_illness
      ,p_reason_for_notification_dela  => p_reason_for_notification_dela
      ,p_accept_late_notification_fla  => p_accept_late_notification_fla
      ,p_linked_absence_id             => p_linked_absence_id
      ,p_absence_case_id               => p_absence_case_id
      ,p_batch_id                      => p_batch_id
      ,p_abs_information_category      => p_abs_information_category
      ,p_abs_information1              => p_abs_information1
      ,p_abs_information2              => p_abs_information2
      ,p_abs_information3              => p_abs_information3
      ,p_abs_information4              => p_abs_information4
      ,p_abs_information5              => p_abs_information5
      ,p_abs_information6              => p_abs_information6
      ,p_abs_information7              => p_abs_information7
      ,p_abs_information8              => p_abs_information8
      ,p_abs_information9              => p_abs_information9
      ,p_abs_information10             => p_abs_information10
      ,p_abs_information11             => p_abs_information11
      ,p_abs_information12             => p_abs_information12
      ,p_abs_information13             => p_abs_information13
      ,p_abs_information14             => p_abs_information14
      ,p_abs_information15             => p_abs_information15
      ,p_abs_information16             => p_abs_information16
      ,p_abs_information17             => p_abs_information17
      ,p_abs_information18             => p_abs_information18
      ,p_abs_information19             => p_abs_information19
      ,p_abs_information20             => p_abs_information20
      ,p_abs_information21             => p_abs_information21
      ,p_abs_information22             => p_abs_information22
      ,p_abs_information23             => p_abs_information23
      ,p_abs_information24             => p_abs_information24
      ,p_abs_information25             => p_abs_information25
      ,p_abs_information26             => p_abs_information26
      ,p_abs_information27             => p_abs_information27
      ,p_abs_information28             => p_abs_information28
      ,p_abs_information29             => p_abs_information29
      ,p_abs_information30             => p_abs_information30
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PERSON_ABSENCE'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  hr_utility.set_location(l_proc, 30);
  --
  l_object_version_number := p_object_version_number;
  --
  -- Update Person Absence
  per_abs_upd.upd
  (p_effective_date                 =>   l_effective_date
  ,p_absence_attendance_id          =>   p_absence_attendance_id
  ,p_abs_attendance_reason_id       =>   p_abs_attendance_reason_id
  ,p_authorising_person_id          =>   p_authorising_person_id
  ,p_replacement_person_id          =>   p_replacement_person_id
  ,p_absence_days                   =>   l_absence_days
  ,p_absence_hours                  =>   l_absence_hours
  ,p_comments                       =>   p_comments
  ,p_date_notification              =>   l_date_notification
  ,p_date_projected_start           =>   l_date_projected_start
  ,p_date_projected_end             =>   l_date_projected_end
  ,p_date_start                     =>   l_date_start
  ,p_date_end                       =>   l_date_end
  ,p_time_start                     =>   p_time_start
  ,p_time_end                       =>   p_time_end
  ,p_time_projected_start           =>   p_time_projected_start
  ,p_time_projected_end             =>   p_time_projected_end
  ,p_attribute_category             =>   p_attribute_category
  ,p_attribute1                     =>   p_attribute1
  ,p_attribute2                     =>   p_attribute2
  ,p_attribute3                     =>   p_attribute3
  ,p_attribute4                     =>   p_attribute4
  ,p_attribute5                     =>   p_attribute5
  ,p_attribute6                     =>   p_attribute6
  ,p_attribute7                     =>   p_attribute7
  ,p_attribute8                     =>   p_attribute8
  ,p_attribute9                     =>   p_attribute9
  ,p_attribute10                    =>   p_attribute10
  ,p_attribute11                    =>   p_attribute11
  ,p_attribute12                    =>   p_attribute12
  ,p_attribute13                    =>   p_attribute13
  ,p_attribute14                    =>   p_attribute14
  ,p_attribute15                    =>   p_attribute15
  ,p_attribute16                    =>   p_attribute16
  ,p_attribute17                    =>   p_attribute17
  ,p_attribute18                    =>   p_attribute18
  ,p_attribute19                    =>   p_attribute19
  ,p_attribute20                    =>   p_attribute20
  ,p_period_of_incapacity_id        =>   p_period_of_incapacity_id
  ,p_ssp1_issued                    =>   p_ssp1_issued
  ,p_maternity_id                   =>   p_maternity_id
  ,p_sickness_start_date            =>   p_sickness_start_date
  ,p_sickness_end_date              =>   p_sickness_end_date
  ,p_pregnancy_related_illness      =>   p_pregnancy_related_illness
  ,p_reason_for_notification_dela   =>   p_reason_for_notification_dela
  ,p_accept_late_notification_fla   =>   p_accept_late_notification_fla
  ,p_linked_absence_id              =>   p_linked_absence_id
  ,p_batch_id                       =>   p_batch_id
  ,p_abs_information_category       =>   p_abs_information_category
  ,p_abs_information1               =>   p_abs_information1
  ,p_abs_information2               =>   p_abs_information2
  ,p_abs_information3               =>   p_abs_information3
  ,p_abs_information4               =>   p_abs_information4
  ,p_abs_information5               =>   p_abs_information5
  ,p_abs_information6               =>   p_abs_information6
  ,p_abs_information7               =>   p_abs_information7
  ,p_abs_information8               =>   p_abs_information8
  ,p_abs_information9               =>   p_abs_information9
  ,p_abs_information10              =>   p_abs_information10
  ,p_abs_information11              =>   p_abs_information11
  ,p_abs_information12              =>   p_abs_information12
  ,p_abs_information13              =>   p_abs_information13
  ,p_abs_information14              =>   p_abs_information14
  ,p_abs_information15              =>   p_abs_information15
  ,p_abs_information16              =>   p_abs_information16
  ,p_abs_information17              =>   p_abs_information17
  ,p_abs_information18              =>   p_abs_information18
  ,p_abs_information19              =>   p_abs_information19
  ,p_abs_information20              =>   p_abs_information20
  ,p_abs_information21              =>   p_abs_information21
  ,p_abs_information22              =>   p_abs_information22
  ,p_abs_information23              =>   p_abs_information23
  ,p_abs_information24              =>   p_abs_information24
  ,p_abs_information25              =>   p_abs_information25
  ,p_abs_information26              =>   p_abs_information26
  ,p_abs_information27              =>   p_abs_information27
  ,p_abs_information28              =>   p_abs_information28
  ,p_abs_information29              =>   p_abs_information29
  ,p_abs_information30              =>   p_abs_information30
  ,p_absence_case_id                =>   p_absence_case_id
   ,p_program_application_id        => p_program_application_id
  ,p_object_version_number          =>   l_object_version_number
  ,p_dur_dys_less_warning           =>   l_dur_dys_less_warning
  ,p_dur_hrs_less_warning           =>   l_dur_hrs_less_warning
  ,p_exceeds_pto_entit_warning      =>   l_exceeds_pto_entit_warning
  ,p_exceeds_run_total_warning      =>   l_exceeds_run_total_warning
  ,p_abs_overlap_warning            =>   l_abs_overlap_warning
  ,p_abs_day_after_warning          =>   l_abs_day_after_warning
  ,p_dur_overwritten_warning        =>   l_dur_overwritten_warning
  );

  --
  -- Assign the out parameters.
  --
  p_object_version_number     := l_object_version_number;
  p_dur_dys_less_warning      := l_dur_dys_less_warning;
  p_dur_hrs_less_warning      := l_dur_hrs_less_warning;
  p_exceeds_pto_entit_warning := l_exceeds_pto_entit_warning;
  p_exceeds_run_total_warning := l_exceeds_run_total_warning;
  p_abs_overlap_warning       := l_abs_overlap_warning;
  p_abs_day_after_warning     := l_abs_day_after_warning;
  p_dur_overwritten_warning   := l_dur_overwritten_warning;
  p_del_element_entry_warning := l_del_element_entry_warning;
  p_absence_days              := l_absence_days;
  p_absence_hours             := l_absence_hours;

  hr_utility.trace('New Dur Dys: '||to_char(l_absence_days));
  hr_utility.trace('New Dur Hrs: '||to_char(l_absence_hours));


  hr_utility.set_location('Start of absence element entry section', 40);

/* Start of Absence Element Entry Section */
  --
  -- Update or insert the absence element element. First we
  -- check if the absence type is linked to an element type.
  --

  /* Level 1 */
  if linked_to_element
     (p_absence_attendance_id => p_absence_attendance_id)
  then

    --
    -- Get the person_id, assignment_id, assignment_type_id
    -- and processing type for use later
    --

    open  c_get_absence_details;
    fetch c_get_absence_details into l_person_id,
                                     l_absence_attendance_type_id,
				     l_date_start1,
				     l_date_end1;
    close c_get_absence_details;

    --
    -- Replace start date and end date by their db row
    -- values if they are defaulted to hr_api.g_date
    -- for correct element entry validations.
    -- This is done for bug 5454141
    --

    if (p_date_start = hr_api.g_date)
    then
    l_date_start_for_absence := l_date_start1;
    else
    l_date_start_for_absence := p_date_start;
    end if;

    if (p_date_end = hr_api.g_date)
    then
    l_date_end_for_absence := l_date_end1;
    else
    l_date_end_for_absence := p_date_end;
    end if;

    -- End of additions for bug 5454141

    l_assignment_id := get_primary_assignment
                       (p_person_id      => l_person_id
                       ,p_effective_date => l_date_start_for_absence); --fix for bug 7191231

    l_processing_type := get_processing_type
      (p_absence_attendance_type_id => l_absence_attendance_type_id);

    --
    -- We determine if an entry already exists.
    --
    get_absence_element
      (p_absence_attendance_id => p_absence_attendance_id
      ,p_element_entry_id      => l_element_entry_id
      ,p_effective_start_date  => l_effective_start_date
      ,p_effective_end_date    => l_effective_end_date);


  /* Level 2 */
    if l_element_entry_id is null then
      --
      -- Scenario 1.
      -- An entry does not already exist. Insert if we have
      -- the appropriate dates.
      --
      hr_utility.set_location('Scenario 1', 45);

      if (l_processing_type = 'N'
          and l_date_start_for_absence is not null
          and l_date_end_for_absence is not null)
      or (l_processing_type = 'R'
          and l_date_start_for_absence is not null)
      then

         insert_absence_element
           (p_date_start            => l_date_start_for_absence
           ,p_assignment_id         => l_assignment_id
           ,p_absence_attendance_id => p_absence_attendance_id
           ,p_element_entry_id      => l_element_entry_id);

         if l_processing_type = 'R' and l_date_end_for_absence is not null then
            --
            -- Scenario 2.
            -- If this is a recurring element entry and we have the
            -- absence end date, we date effectively delete the
            -- element immediately, otherwise it remains open until
            -- the end of time.
            --
            hr_utility.set_location('Scenario 2', 50);

            delete_absence_element
              (p_dt_delete_mode        => 'DELETE'
              ,p_session_date          => l_date_end_for_absence
              ,p_element_entry_id      => l_element_entry_id);
         end if;

      end if;

    else
      --
      -- An entry already exists. Update it as appropriate.
      --
      /* Level 3 */
      if (l_processing_type = 'R' and l_date_start_for_absence is null)
      or (l_processing_type = 'N' and (l_date_start_for_absence is null
                                   or   l_date_end_for_absence is null)) then
         --
         -- Scenario 3.
         -- The element entry should be purged because the
         -- actual dates have been removed.
         --
         hr_utility.set_location('Scenario 3', 55);

         --
         -- Warn the user before deleting.
         --
         l_del_element_entry_warning := TRUE;

         delete_absence_element
           (p_dt_delete_mode        => 'ZAP'
           ,p_session_date          => l_effective_start_date
           ,p_element_entry_id      => l_element_entry_id);

      elsif l_processing_type = 'N' and l_date_start_for_absence not between
            l_effective_start_date and l_effective_end_date then
         --
         -- Scenario 4.
         -- The start date cannot be moved outside the entry's
         -- current period for non-recurring entries.
         --
         hr_utility.set_location('Scenario 4', 60);

         fnd_message.set_name ('PAY', 'HR_6744_ABS_DET_ENTRY_PERIOD');
         fnd_message.set_token ('PERIOD_FROM',
               fnd_date.date_to_chardate(l_effective_start_date));
         fnd_message.set_token ('PERIOD_TO',
               fnd_date.date_to_chardate(l_effective_end_date));
         fnd_message.raise_error;

      elsif l_processing_type = 'N' then
         --
         -- Scenario 5.
         -- Update the existing entry with the new input values.
         -- For simplicity, we make the update even if the value
         -- has not changed.
         --
         hr_utility.set_location('Scenario 5', 65);

         update_absence_element
           (p_dt_update_mode        => 'CORRECTION'
           ,p_session_date          => l_effective_start_date
           ,p_element_entry_id      => l_element_entry_id
           ,p_absence_attendance_id => p_absence_attendance_id);

      elsif l_processing_type = 'R'
            and l_date_start_for_absence <> l_effective_start_date then

         --
         -- Scenario 6.
         -- The start date has been moved. As this is part of the
         -- primary key we must delete the entry and re-insert it.
         --
         hr_utility.set_location('Scenario 6', 70);

         delete_absence_element
           (p_dt_delete_mode        => 'ZAP'
           ,p_session_date          => l_effective_start_date
           ,p_element_entry_id      => l_element_entry_id);

         insert_absence_element
           (p_date_start            => l_date_start_for_absence
           ,p_assignment_id         => l_assignment_id
           ,p_absence_attendance_id => p_absence_attendance_id
           ,p_element_entry_id      => l_element_entry_id);

         if l_date_end_for_absence is not null then
            --
            -- We have the absence end date, we date effectively
            -- delete the element immediately, otherwise it
            -- remains open until the end of time.
            --

            delete_absence_element
              (p_dt_delete_mode        => 'DELETE'
              ,p_session_date          => l_date_end_for_absence
              ,p_element_entry_id      => l_element_entry_id);
         end if;

      elsif l_processing_type = 'R' and
            (l_date_end_for_absence is null or
             l_date_end_for_absence <> l_effective_end_date) then
         --
         -- Scenario 7.
         -- The end date has:
         --  . changed
         --  . been removed
         --  . entered for the first time
         --  . still not been entered.
         --
         hr_utility.set_location('Scenario 7', 75);

         if l_effective_end_date <> hr_api.g_eot then
            --
            -- End date has been changed or removed so we
            -- remove the end date so it continues through
            -- until the end of time.
            --
            hr_utility.set_location(l_proc, 76);

            delete_absence_element
              (p_dt_delete_mode        => 'DELETE_NEXT_CHANGE'
              ,p_session_date          => l_effective_end_date
              ,p_element_entry_id      => l_element_entry_id);
         end if;

         if l_date_end_for_absence is not null then
            --
            -- End date has been changed or entered for
            -- the first time. We end the element entry
            -- at the end date.
            --
            hr_utility.set_location(l_proc, 78);

            delete_absence_element
              (p_dt_delete_mode        => 'DELETE'
              ,p_session_date          => l_date_end_for_absence
              ,p_element_entry_id      => l_element_entry_id);
         end if;

      /* Level 3 */
      end if;

    /* Level 2 */
    end if;

  /* Level 1 */
  end if;


/* End of Absence Element Entry Section */

  hr_utility.set_location('End of absence element entry section', 80);

  populate_ben_absence_rec
  (p_absence_attendance_id => p_absence_attendance_id,
   p_rec_type => 'O',
   p_ben_rec => l_old);

  populate_ben_absence_rec
  (p_absence_attendance_id => p_absence_attendance_id,
   p_rec_type => 'N',
   p_ben_rec => l_new);

  --
  -- Start of BEN call.
  --
  hr_utility.set_location('Start of BEN call', 82);

  ben_abs_ler.ler_chk
    (p_old            => l_old
    ,p_new            => l_new
    ,p_effective_date => l_effective_date);

  hr_utility.set_location('End of BEN call', 84);

  --
  -- Call After Process User Hook
  --
  begin
    hr_person_absence_bk2.update_person_absence_a
      (p_effective_date                => l_effective_date
      ,p_absence_attendance_id         => p_absence_attendance_id
      ,p_object_version_number         => l_object_version_number
      ,p_abs_attendance_reason_id      => p_abs_attendance_reason_id
      ,p_comments                      => p_comments
      ,p_date_notification             => l_date_notification
      ,p_date_projected_start          => l_date_projected_start
      ,p_time_projected_start          => p_time_projected_start
      ,p_date_projected_end            => l_date_projected_end
      ,p_time_projected_end            => p_time_projected_end
      ,p_date_start                    => l_date_start
      ,p_time_start                    => p_time_start
      ,p_date_end                      => l_date_end
      ,p_time_end                      => p_time_end
      ,p_absence_days                  => l_absence_days
      ,p_absence_hours                 => l_absence_hours
      ,p_authorising_person_id         => p_authorising_person_id
      ,p_replacement_person_id         => p_replacement_person_id
      ,p_attribute_category            => p_attribute_category
      ,p_attribute1                    => p_attribute1
      ,p_attribute2                    => p_attribute2
      ,p_attribute3                    => p_attribute3
      ,p_attribute4                    => p_attribute4
      ,p_attribute5                    => p_attribute5
      ,p_attribute6                    => p_attribute6
      ,p_attribute7                    => p_attribute7
      ,p_attribute8                    => p_attribute8
      ,p_attribute9                    => p_attribute9
      ,p_attribute10                   => p_attribute10
      ,p_attribute11                   => p_attribute11
      ,p_attribute12                   => p_attribute12
      ,p_attribute13                   => p_attribute13
      ,p_attribute14                   => p_attribute14
      ,p_attribute15                   => p_attribute15
      ,p_attribute16                   => p_attribute16
      ,p_attribute17                   => p_attribute17
      ,p_attribute18                   => p_attribute18
      ,p_attribute19                   => p_attribute19
      ,p_attribute20                   => p_attribute20
      ,p_period_of_incapacity_id       => p_period_of_incapacity_id
      ,p_ssp1_issued                   => p_ssp1_issued
      ,p_maternity_id                  => p_maternity_id
      ,p_sickness_start_date           => p_sickness_start_date
      ,p_sickness_end_date             => p_sickness_end_date
      ,p_pregnancy_related_illness     => p_pregnancy_related_illness
      ,p_reason_for_notification_dela  => p_reason_for_notification_dela
      ,p_accept_late_notification_fla  => p_accept_late_notification_fla
      ,p_linked_absence_id             => p_linked_absence_id
      ,p_absence_case_id               => p_absence_case_id
      ,p_batch_id                      => p_batch_id
      ,p_abs_information_category      => p_abs_information_category
      ,p_abs_information1              => p_abs_information1
      ,p_abs_information2              => p_abs_information2
      ,p_abs_information3              => p_abs_information3
      ,p_abs_information4              => p_abs_information4
      ,p_abs_information5              => p_abs_information5
      ,p_abs_information6              => p_abs_information6
      ,p_abs_information7              => p_abs_information7
      ,p_abs_information8              => p_abs_information8
      ,p_abs_information9              => p_abs_information9
      ,p_abs_information10             => p_abs_information10
      ,p_abs_information11             => p_abs_information11
      ,p_abs_information12             => p_abs_information12
      ,p_abs_information13             => p_abs_information13
      ,p_abs_information14             => p_abs_information14
      ,p_abs_information15             => p_abs_information15
      ,p_abs_information16             => p_abs_information16
      ,p_abs_information17             => p_abs_information17
      ,p_abs_information18             => p_abs_information18
      ,p_abs_information19             => p_abs_information19
      ,p_abs_information20             => p_abs_information20
      ,p_abs_information21             => p_abs_information21
      ,p_abs_information22             => p_abs_information22
      ,p_abs_information23             => p_abs_information23
      ,p_abs_information24             => p_abs_information24
      ,p_abs_information25             => p_abs_information25
      ,p_abs_information26             => p_abs_information26
      ,p_abs_information27             => p_abs_information27
      ,p_abs_information28             => p_abs_information28
      ,p_abs_information29             => p_abs_information29
      ,p_abs_information30             => p_abs_information30
      ,p_dur_dys_less_warning          => l_dur_dys_less_warning
      ,p_dur_hrs_less_warning          => l_dur_hrs_less_warning
      ,p_exceeds_pto_entit_warning     => l_exceeds_pto_entit_warning
      ,p_exceeds_run_total_warning     => l_exceeds_run_total_warning
      ,p_abs_overlap_warning           => l_abs_overlap_warning
      ,p_abs_day_after_warning         => l_abs_day_after_warning
      ,p_dur_overwritten_warning       => l_dur_overwritten_warning
      ,p_del_element_entry_warning     => l_del_element_entry_warning
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_PERSON_ABSENCE'
        ,p_hook_type   => 'AP'
        );
  end;

  --
  -- Pipe the main IN OUT / OUT parameters for ease of debugging.
  --
  hr_utility.trace(' ');
  hr_utility.trace(' --------------------------------'||
                   '---------------------------------');
  hr_utility.trace(' IN OUT NOCOPY / OUT NOCOPY PARAMETER          '||
                   ' VALUE');
  hr_utility.trace(' --------------------------------'||
                   '+--------------------------------');
  hr_utility.trace('  p_absence_days                   '||
                      to_char(p_absence_days));
  hr_utility.trace('  p_absence_hours                  '||
                      to_char(p_absence_hours));
  hr_utility.trace('  p_object_version_number          '||
                      to_char(p_object_version_number));
  hr_utility.trace(' --------------------------------'||
                   '---------------------------------');
  hr_utility.trace(' ');

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 90);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_person_absence;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 100);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_object_version_number      := lv_object_version_number ;
    p_absence_days               := lv_absence_days ;
    p_absence_hours              := lv_absence_hours ;

    p_dur_dys_less_warning       := null;
    p_dur_hrs_less_warning        := null;
    p_exceeds_pto_entit_warning   := null;
    p_exceeds_run_total_warning   := null;
    p_abs_overlap_warning         := null;
    p_abs_day_after_warning       := null;
    p_dur_overwritten_warning     := null;
    p_del_element_entry_warning   := null;

    rollback to update_person_absence;
    hr_utility.set_location(' Leaving:'||l_proc, 110);
    raise;
end update_person_absence;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_person_absence >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_person_absence
  (p_validate                      in     boolean default false
  ,p_absence_attendance_id         in     number
  ,p_object_version_number         in     number
  ,p_called_from                   in     number   default 800
  ) is

 CURSOR get_person_info IS
 select person_id
 from per_absence_attendances
 where ABSENCE_ATTENDANCE_ID = p_absence_attendance_id ;
  --
  -- Declare cursors and local variables
  --
  --
  l_old                      ben_abs_ler.g_abs_ler_rec;
  l_new                      ben_abs_ler.g_abs_ler_rec;

  l_proc                varchar2(72) := g_package||'delete_person_absence';
  l_exists                   number;
  l_element_entry_id         number;
  l_effective_start_date     date;
  l_effective_end_date       date;

    l_person_id number := -1;
    l_csrperson_id number;


--

cursor csr_get_absdates is
select nvl(date_start,DATE_PROJECTED_START) , nvl(date_end,DATE_PROJECTED_END)

from per_absence_attendances
 where ABSENCE_ATTENDANCE_ID = p_absence_attendance_id ;
  --
l_chk_datestart date;
l_chk_dateend date;
l_PROGRAM_APPLICATION_ID number;
l_retvalue varchar2(10);
--

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);

  -- Issue a savepoint
  savepoint delete_person_absence;

  OPEN get_person_info;
   FETCH get_person_info INTO l_person_id;
   CLOSE get_person_info;

if nvl(FND_PROFILE.Value('HR_ABS_OTL_INTEGRATION'),'N') = 'Y' then
hr_utility.set_location(' OTL ABS integration on ',10);

open csr_get_absdates;
fetch csr_get_absdates into l_chk_datestart,l_chk_dateend ;
close csr_get_absdates;

if p_called_from <> 809 and  l_chk_datestart is not null and l_chk_dateend is not null

 then

  hr_utility.set_location('inside otl hr check ', 10);

otl_hr_check
(
p_person_id  => l_person_id,
p_date_start => l_chk_datestart,
p_date_end   => l_chk_dateend,
p_scope 	   => 'DELETE',
p_ret_value  => l_retvalue );


  hr_utility.set_location('after otl hr check ', 10);

end if;
END IF;

   --
   --
  -- Call Before Process User Hook
  --
  begin
    hr_person_absence_bk3.delete_person_absence_b
      (p_absence_attendance_id         => p_absence_attendance_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PERSON_ABSENCE'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  hr_utility.set_location('Start of absence element deletion section', 30);
  --
/* Start of Absence Element Deletion Section */

  --
  -- Delete the absence element entry. First we check if an
  -- element has been created for this absence.
  -- Added Loop for bug fix 5392984
  Loop
  get_absence_element
    (p_absence_attendance_id => p_absence_attendance_id
    ,p_element_entry_id      => l_element_entry_id
    ,p_effective_start_date  => l_effective_start_date
    ,p_effective_end_date    => l_effective_end_date);

    if l_element_entry_id is not null then
    --
    -- An element entry exists so we delete it.
    --

    delete_absence_element
      (p_dt_delete_mode        => 'ZAP'
      ,p_session_date          => l_effective_start_date
      ,p_element_entry_id      => l_element_entry_id);
     else
     exit;
    end if;
End loop;
/* End of Absence Element Deletion Section */

  hr_utility.set_location('End of absence element deletion section', 40);
  --
  -- Delete Person Absence

  per_abs_del.del
  (p_absence_attendance_id          =>   p_absence_attendance_id
  ,p_object_version_number          =>   p_object_version_number
  );

  hr_utility.set_location(l_proc, 50);

  populate_ben_absence_rec
  (p_absence_attendance_id => p_absence_attendance_id,
   p_rec_type => 'O',
   p_ben_rec => l_old);
  -- fix for bug 4395727.
  ben_abs_ler.ler_chk(p_old            => l_old,
                      p_new            => l_new,
                      p_effective_date => l_effective_start_date);

  --
  -- Call After Process User Hook
  --

  begin
    hr_person_absence_bk3.delete_person_absence_a
      (p_absence_attendance_id         => p_absence_attendance_id
      ,p_object_version_number         => p_object_version_number
      ,p_person_id                     => l_person_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_PERSON_ABSENCE'
        ,p_hook_type   => 'AP'
        );
  end;
  --
-- to delete all the pending for approval transactions data requested for OTL-HRAbsence.
if nvl(FND_PROFILE.Value('HR_ABS_OTL_INTEGRATION'),'N') = 'Y' then

 hr_utility.set_location('OTL HR ABS integration is ON ', 10);
hr_absutil_ss.remove_absence_transaction(p_absence_attendance_id);

end if;

  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_person_absence;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_person_absence;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
--
end delete_person_absence;

--
-- ----------------------------------------------------------------------------
-- |----------------------< get_primary_assignment >--------------------------|
-- ----------------------------------------------------------------------------
--
function get_primary_assignment
  (p_person_id       in number,
   p_effective_date  in date) return number is


  -- It is acceptable for one person to have several simultaneous assignments
  -- with the benefits functionality so we exclude assignment types of 'B'
  -- to prevent the wrong assignment being picked up.

  cursor c_get_primary_assignment is
    select asg.assignment_id
    from   per_all_assignments_f asg
    where  asg.person_id = p_person_id
    and    p_effective_date between
           asg.effective_start_date and asg.effective_end_date
    and    asg.primary_flag = 'Y'
    and    asg.assignment_type <> 'B';


  l_proc           varchar2(72) := g_package||'get_primary_assignment';
  l_assignment_id  number;


begin

  hr_utility.set_location('Entering:'|| l_proc, 10);

  open  c_get_primary_assignment;
  fetch c_get_primary_assignment into l_assignment_id;
  close c_get_primary_assignment;


  hr_utility.set_location('Leaving:'|| l_proc, 20);

  return l_assignment_id;

end get_primary_assignment;

--
-- ----------------------------------------------------------------------------
-- |----------------------< linked_to_element >-------------------------------|
-- ----------------------------------------------------------------------------
--
function linked_to_element
  (p_absence_attendance_id in number) return boolean is

  cursor c_linked_to_element is
    select abt.input_value_id
    from   per_absence_attendances aba,
           per_absence_attendance_types abt
    where  aba.absence_attendance_id = p_absence_attendance_id
    and    aba.absence_attendance_type_id = abt.absence_attendance_type_id;


  l_proc              varchar2(72) := g_package||'linked_to_element';
  l_input_value_id    number;
  l_linked_to_element boolean;


begin

  hr_utility.set_location('Entering:'|| l_proc, 10);

  open  c_linked_to_element;
  fetch c_linked_to_element into l_input_value_id;
  close c_linked_to_element;


  if l_input_value_id is not null then
    l_linked_to_element := TRUE;
  else
    l_linked_to_element := FALSE;
  end if;


 hr_utility.set_location('Leaving:'|| l_proc, 20);

  return l_linked_to_element;

end linked_to_element;

--
-- ----------------------------------------------------------------------------
-- |----------------------< get_absence_element >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure get_absence_element
  (p_absence_attendance_id in  number
  ,p_element_entry_id      out nocopy number
  ,p_effective_start_date  out nocopy date
  ,p_effective_end_date    out nocopy date) is

  --
  -- Bug 2782577.  Performance tuned for the CBO.
  --
  cursor c_get_absence_element is
    select distinct pee.element_entry_id
          ,pee.effective_start_date
          ,pee.effective_end_date
    from   per_absence_attendances abs
          ,per_all_assignments_f asg
          ,per_absence_attendance_types abt
          ,pay_input_values_f piv
          ,pay_element_types_f pet
          ,pay_element_links_f pel
          ,pay_element_entries_f pee
    where  abs.absence_attendance_id = p_absence_attendance_id
    and    abs.person_id = asg.person_id
    and    abs.absence_attendance_type_id = abt.absence_attendance_type_id
    and    abt.input_value_id is not null
    and    abt.input_value_id = piv.input_value_id
    and    piv.element_type_id = pet.element_type_id
    and    pet.element_type_id = pel.element_type_id
    and    pel.element_link_id = pee.element_link_id
    and    pee.assignment_id = asg.assignment_id
    and    pee.creator_id = abs.absence_attendance_id
    and    pee.creator_type = 'A';

  l_proc                 varchar2(72) := g_package||'get_absence_element';

begin

  hr_utility.set_location('Entering:'|| l_proc, 10);

  open  c_get_absence_element;
  fetch c_get_absence_element into p_element_entry_id,
                                   p_effective_start_date,
                                   p_effective_end_date;
  close c_get_absence_element;


  hr_utility.set_location('Leaving:'|| l_proc, 20);
exception
  when others then
     p_element_entry_id      := null;
     p_effective_start_date  := null;
     p_effective_end_date    := null;

end get_absence_element;

-- ----------------------------------------------------------------------------
-- |----------------------< get_processing_type >-----------------------------|
-- ----------------------------------------------------------------------------
--
function get_processing_type
  (p_absence_attendance_type_id in number) return varchar2 is

  cursor c_get_processing_type is
    select upper(pet.processing_type)
    from   per_absence_attendance_types abt,
           pay_input_values_f piv,
           pay_element_types_f pet
    where  abt.absence_attendance_type_id = p_absence_attendance_type_id
    and    abt.input_value_id = piv.input_value_id
    and    piv.element_type_id = pet.element_type_id;


  l_proc              varchar2(72) := g_package||'get_processing_type';
  l_processing_type   pay_element_types_f.processing_type%TYPE;


begin

  hr_utility.set_location('Entering:'|| l_proc, 10);

  --
  -- Fetch the processing type.  If no records are found, the absence type
  -- does not have an associated element so null is returned.
  --
  open  c_get_processing_type;
  fetch c_get_processing_type into l_processing_type;
  close c_get_processing_type;

  hr_utility.set_location('Leaving:'|| l_proc, 20);

  return l_processing_type;

end get_processing_type;

--
-- ----------------------------------------------------------------------------
-- |----------------------< get_element_details >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure get_element_details
  (p_absence_attendance_id    in  number
  ,p_element_type_id          out nocopy number
  ,p_input_value_id           out nocopy number
  ,p_entry_value              out nocopy number
  ) is


  cursor c_get_element_details is
    select aba.absence_hours,
           aba.absence_days,
           abt.hours_or_days,
           abt.increasing_or_decreasing_flag,
           abt.input_value_id,
           pet.element_type_id,
           pet.processing_type
    from   per_absence_attendances aba,
           per_absence_attendance_types abt,
           pay_input_values_f piv,
           pay_element_types_f pet
    where  aba.absence_attendance_id = p_absence_attendance_id
    and    aba.absence_attendance_type_id = abt.absence_attendance_type_id
    and    abt.input_value_id = piv.input_value_id
    and    piv.element_type_id = pet.element_type_id;


  l_proc            varchar2(72) := g_package||'get_element_details';
  l_absence_hours   per_absence_attendances.absence_hours%TYPE;
  l_absence_days    per_absence_attendances.absence_days%TYPE;
  l_hours_or_days   per_absence_attendance_types.hours_or_days%TYPE;
  l_processing_type pay_element_types_f.processing_type%TYPE;
  l_inc_or_dec_flag per_absence_attendance_types.increasing_or_decreasing_flag%TYPE;


begin

  hr_utility.set_location('Entering:'|| l_proc, 10);


  -- This should always return a row because this procedure is only
  -- called when the absence type has an associated element type.

  open  c_get_element_details;
  fetch c_get_element_details into l_absence_hours,
                                   l_absence_days,
                                   l_hours_or_days,
                                   l_inc_or_dec_flag,
                                   p_input_value_id,
                                   p_element_type_id,
                                   l_processing_type;
  close c_get_element_details;


  hr_utility.set_location('Setting entry value', 20);

  if upper(l_processing_type) = 'N' then
     --
     -- p_entry_value is only set when the element type is
     -- non-recurring, otherwise it remains null.
     --
     if upper(l_hours_or_days) = 'H' then

       if l_inc_or_dec_flag = 'D' then
         --
         -- Invert the absence duration for decreasing balances.
         --
         hr_utility.set_location(l_proc, 30);
         p_entry_value := l_absence_hours * -1;

       else

         hr_utility.set_location(l_proc, 40);
         p_entry_value := l_absence_hours;

       end if;

     else

       if l_inc_or_dec_flag = 'D' then
         --
         -- Invert the absence duration for decreasing balances.
         --
         hr_utility.set_location(l_proc, 50);
         p_entry_value := l_absence_days * -1;

       else

         hr_utility.set_location(l_proc, 60);
         p_entry_value := l_absence_days;

       end if;

     end if;

  end if;

  hr_utility.set_location('Leaving:'|| l_proc, 70);

exception
  when others then
   p_element_type_id          := null ;
   p_input_value_id           := null ;
   p_entry_value              := null ;

   raise;

--
end get_element_details;
--
-- ----------------------------------------------------------------------------
-- |----------------------< insert_absence_element >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure insert_absence_element
  (p_date_start                in  date
  ,p_assignment_id             in  number
  ,p_absence_attendance_id     in  number
  ,p_element_entry_id          out nocopy number
  ) is


  l_proc            varchar2(72) := g_package||'insert_absence_element';
  l_date_start      date := p_date_start;
  l_date_end        date;
  l_element_type_id number;
  l_element_link_id number;
  l_input_value_id  number;
  l_entry_value     number;

begin


  hr_utility.set_location('Entering:'|| l_proc, 10);

  get_element_details
    (p_absence_attendance_id  => p_absence_attendance_id
    ,p_element_type_id        => l_element_type_id
    ,p_input_value_id         => l_input_value_id
    ,p_entry_value            => l_entry_value);


 hr_utility.set_location('Checking element link', 20);

  l_element_link_id := hr_entry_api.get_link
    (p_assignment_id          => p_assignment_id
    ,p_element_type_id        => l_element_type_id
    ,p_session_date           => p_date_start);

  If l_element_link_id is null then
    -- Assignment is not eligible for the element type
    -- associated with this absence.
    fnd_message.set_name ('PAY','HR_7448_ELE_PER_NOT_ELIGIBLE');
    hr_utility.raise_error;
  end if;


 hr_utility.set_location('Inserting element', 30);

  -- We know the assignment is eligible for this element because
  -- we have the element_link_id. The entries API will handle
  -- all other validation (e.g., non-recurring entries must
  -- have a valid payroll).

  hr_entry_api.insert_element_entry
    (p_effective_start_date => l_date_start
    ,p_effective_end_date   => l_date_end
    ,p_element_entry_id     => p_element_entry_id
    ,p_assignment_id        => p_assignment_id
    ,p_element_link_id      => l_element_link_id
    ,p_creator_type         => 'A'
    ,p_entry_type           => 'E'
    ,p_creator_id           => p_absence_attendance_id
    ,p_input_value_id1      => l_input_value_id
    ,p_entry_value1         => l_entry_value);


  hr_utility.set_location('EE ID: '|| to_char(p_element_entry_id), 40);
  hr_utility.set_location('Leaving:'|| l_proc, 50);

exception
 when others then
  p_element_entry_id    := null ;
  raise;

end insert_absence_element;
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_absence_element >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_absence_element
  (p_dt_update_mode            in  varchar2
  ,p_session_date              in  date
  ,p_element_entry_id          in  number
  ,p_absence_attendance_id     in  number
  ) is


  l_proc            varchar2(72) := g_package||'update_absence_element';
  l_element_type_id number;
  l_input_value_id  number;
  l_entry_value     number;

begin


  hr_utility.set_location('Entering:'|| l_proc, 10);

  get_element_details
    (p_absence_attendance_id  => p_absence_attendance_id
    ,p_element_type_id        => l_element_type_id
    ,p_input_value_id         => l_input_value_id
    ,p_entry_value            => l_entry_value);


 hr_utility.set_location('Updating element', 20);

  -- We know the assignment is eligible for this element because
  -- we have the element_link_id. The entries API will handle
  -- all other validation (e.g., non-recurring entries must
  -- have a valid payroll).

  hr_entry_api.update_element_entry
    (p_dt_update_mode       => p_dt_update_mode
    ,p_session_date         => p_session_date
    ,p_element_entry_id     => p_element_entry_id
    ,p_creator_type         => 'A'
    ,p_creator_id           => p_absence_attendance_id
    ,p_input_value_id1      => l_input_value_id
    ,p_entry_value1         => l_entry_value);


  hr_utility.set_location('Leaving:'|| l_proc, 30);

end update_absence_element;
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_absence_element >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_absence_element
  (p_dt_delete_mode            in  varchar2
  ,p_session_date              in  date
  ,p_element_entry_id          in  number
  ) is


  l_proc            varchar2(72) := g_package||'delete_absence_element';
  l_input_value_id  number;
  l_entry_value     number;

begin


  hr_utility.set_location('Entering:'|| l_proc, 10);

  hr_entry_api.delete_element_entry
    (p_dt_delete_mode       => p_dt_delete_mode
    ,p_session_date         => p_session_date
    ,p_element_entry_id     => p_element_entry_id);


  hr_utility.set_location('Leaving:'|| l_proc, 20);

end delete_absence_element;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< otl_hr_check >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure otl_hr_check
(
p_person_id number default null,
p_date_start date default null,
p_date_end date default null,
p_scope varchar2 default null,
p_ret_value out nocopy varchar2
)
is
 l_error_level NUMBER;
 l_error_code VARCHAR2(50);
 l_profile varchar2(1);
 g_debug boolean := hr_utility.debug_enabled;

begin
p_ret_value :='NO';
l_profile :='N';


  hr_utility.set_location('p_person_id : '||  p_person_id, 20);
  hr_utility.set_location('p_date_start :'|| p_date_start, 20);
  hr_utility.set_location('p_date_end :'|| p_date_end, 20);
  hr_utility.set_location('p_scope :'|| p_scope, 20);

if (NVL(FND_PROFILE.Value('HR_SCH_BASED_ABS_CALC'),'N')='Y' AND
			NVL(FND_PROFILE.Value('PER_ABSENCE_DURATION_AUTO_OVERWRITE'),'N')='Y')

then

l_profile :='Y';

if g_debug then
 hr_utility.set_location('CAC	installed', 10);
end if;

end if;



if p_person_id is not null and p_date_start is not null and p_date_end is not null  then
 hr_utility.set_location('passed parameter are not null :', 10);

--if l_profile = 'Y' and nvl(FND_PROFILE.Value('HR_ABS_OTL_INTEGRATION'),'N') = 'Y' then
if nvl(FND_PROFILE.Value('HR_ABS_OTL_INTEGRATION'),'N') = 'Y' then

if g_debug then
 hr_utility.set_location('OTL HR ABS integration is ON ', 10);
end if;
-- bug 8916489
 if not per_abs_bus.per_valid_for_absence
      (p_person_id            => p_person_id
      ,p_business_group_id    => hr_general.get_business_group_id
      ,p_date_projected_start => null
      ,p_date_projected_end   => null
      ,p_date_start           => p_date_start
      ,p_date_end             => p_date_end)
  then

      fnd_message.set_name('PER', 'PER_7715_ABS_TERM_PROJ_DATE');
      fnd_message.raise_error;

  end if;

HXC_ABS_INTG_PKG.otl_timecard_chk(p_person_id => p_person_id,
                                     p_start_time => p_date_start,
                                        p_stop_time   => p_date_end,
                                        p_error_code => l_error_code,
                                        p_error_level => l_error_level);

if g_debug then
 hr_utility.set_location('out of OTL call ', 10);
 hr_utility.set_location(' l_error_level ' ||l_error_level, 10);
end if;

	if p_scope IN ('CREATE','DELETE') THEN
  	IF l_error_level = 0 THEN
		p_ret_value :='ALL';

		if g_debug then
		hr_utility.set_location('otl hr Insert check - CREATE', 10);
		end if;

		elsif l_error_level in (1,2) then
		 -- raise
		 hr_utility.set_location('OTL Check failed. Raise Error', 20);
		 hr_utility.set_message(800,'HR_50433_OTL_CARD_EXISTS');
		 hr_utility.raise_error;

 		else
		-- raise
		 hr_utility.set_location('Unknown Exception raised from OTL. Raise Error', 30);
		 hr_utility.set_message(800,'HR_50433_OTL_CARD_EXISTS');
		 hr_utility.raise_error;
		end if;

	end if;

	if  p_scope ='UPDATE' THEN

		if g_debug then
		hr_utility.set_location('otl hr Insert check - UPDATE', 10);
		end if;

		IF l_error_level =0 THEN
		p_ret_value :='ALL';
		hr_utility.set_location('otl hr UPDATE check', 40);
		elsif l_error_level =1 then
		     p_ret_value:='RESTRICT';
		     hr_utility.set_location('otl hr UPDATE check', 50);
        	elsif  l_error_level =2 then
			-- raise
		     hr_utility.set_location('otl hr UPDATE check ', 60);
		     hr_utility.set_message(800,'HR_50433_OTL_CARD_EXISTS');
		     hr_utility.raise_error;
		else
			--raise;
		     hr_utility.set_location('otl hr UPDATE check', 70);
		     hr_utility.set_message(800,'HR_50433_OTL_CARD_EXISTS');
		     hr_utility.raise_error;

		end if;
	end if;

	/* Code added for Query and then Disable of some fields in PUI screen */
	IF p_scope = 'QUERY' THEN
	   IF l_error_level = 0 THEN
		p_ret_value :='ALL';
		hr_utility.set_location('Query for the period done. No disable', 40);
	   elsif l_error_level =1 then
		p_ret_value:='RESTRICT';
		hr_utility.set_location('Query for the period done. Disable the fields', 50);
	   end if;
	END IF ;

	else
		p_ret_value :='ALL';
	end if;

 else
	hr_utility.set_location('CAC check call ', 100);
 	p_ret_value :='YES'; -- Profile for cac is set
end if;


end;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< get_absence_data >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure get_absence_data(p_person_id in number,
                           p_start_date in date,
                           p_end_date in date,
                           absence_records out nocopy abs_data,
		           absence_records_inv out nocopy abs_data_inv ) is

type absence_entries is record (  startdate date ,
                                  enddate date,
			          TRANSACTION_ID number,
				  TRANSACTION_DOCUMENT clob,
				  absence_attendance_type_id number,
				  ELEMENT_TYPE_ID number(10),
				  hours_or_days varchar2(1));

type create_data is table of absence_entries INDEX BY binary_integer;

ss_create_data create_data;

l_confirmed_flag varchar2(2);
ssmodes number:=1; -- 8941541
p_ssmode varchar2(20); -- 8941541
l_start_date date;
l_end_date date;
l_start_date_new date;
l_end_date_new date;
l_time_start varchar2(10);
l_time_end varchar2(10);
l_time_start_new varchar2(10);
l_time_end_new varchar2(10);
l_days number;
l_hours number(6,2);
l_abs_type number(10);
l_ele_type number(10);
l_assignment_id number;
l_sch_based_dur VARCHAR2(1);
l_hours_or_days varchar2(1);
l_absence_attendance_id number(10);

-- for core data-

 l_core_dstart date;
 l_core_dend date;
 l_core_tstart varchar2(10);
 l_core_tend varchar2(10);
 l_core_abs_attendance_id number(10);
 l_core_ovn number;
--
  l_idx             NUMBER;
  i number :=0;
  j number :=0;
  l_ref_date        DATE;
  l_first_band      BOOLEAN;
  l_day_start_time  VARCHAR2(30);
  l_day_end_time    VARCHAR2(30);

  l_schedule        cac_avlblty_time_varray;
  l_schedule_source VARCHAR2(10);
  l_return_status   VARCHAR2(1);
  l_return_message  VARCHAR2(2000);
  l_PROGRAM_APPLICATION_ID number(15);


  e_bad_time_format EXCEPTION;


v_start_date date;
v_end_date date;


cursor  csr_sshr_abs_records(p_mode varchar2) is

select
	 hr_person_absence_swi.getStartDate(hat.transaction_id) ActualDateStart,
	hr_person_absence_swi.getEndDate(hat.transaction_id) ActualDateEnd,
	nvl(hr_xml_util.get_node_value(hat.transaction_id,'TimeStart','Transaction/TransCache/AM/TXN/EO/PerAbsenceAttendancesEORow',
    					    NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
	 hr_xml_util.get_node_value(hat.transaction_id,'TimeProjectedStart','Transaction/TransCache/AM/TXN/EO/PerAbsenceAttendancesEORow',
  					    NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)),
	nvl(hr_xml_util.get_node_value(hat.transaction_id,'TimeEnd','Transaction/TransCache/AM/TXN/EO/PerAbsenceAttendancesEORow',
				NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
	 hr_xml_util.get_node_value(hat.transaction_id,'TimeProjectedEnd','Transaction/TransCache/AM/TXN/EO/PerAbsenceAttendancesEORow',
					    NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)),
	hat.TRANSACTION_ID,
	hat.TRANSACTION_DOCUMENT,
	-- hrtsteps.object_state, -- stores ovn
	hr_xml_util.get_node_value(hat.transaction_id,'ObjectVersionNumber','Transaction/TransCache/AM/TXN/EO/PerAbsenceAttendancesEORow',
    					    NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),
        abt.absence_attendance_type_id,
	hat.transaction_ref_id,
        pet.ELEMENT_TYPE_ID,
        abt.hours_or_days,
	decode (hrtsteps.INFORMATION9,'CONFIRMED','Y','N') CONFIRMED_FLAG
   from hr_api_transactions hat,
        HR_API_TRANSACTION_STEPS hrtsteps,
        per_absence_attendance_types abt,
        pay_input_values_f piv,
        pay_element_types_f pet
where
hat.SELECTED_PERSON_ID = p_person_id
--hat.creator_person_id = 125
and hat.TRANSACTION_REF_TABLE = 'PER_ABSENCE_ATTENDANCES'
and hrtsteps.TRANSACTION_ID= hat.TRANSACTION_ID
and hat.STATUS not in ('W','S','N','D','AC') -- bug9554066
AND hr_person_absence_swi.getstartdate(hat.transaction_id) is NOT NULL
AND hr_person_absence_swi.getenddate(hat.transaction_id) is NOT NULL
and (p_start_date <= hr_person_absence_swi.getEndDate(hat.transaction_id) and
		p_end_date >= hr_person_absence_swi.getStartDate(hat.transaction_id)  )

and hr_xml_util.get_node_value(hat.transaction_id,'AbsenceAction','Transaction/TransCtx/CNode',
           NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)=p_mode
and p_start_date between piv.EFFECTIVE_START_DATE and piv.EFFECTIVE_END_DATE
and p_start_date between pet.EFFECTIVE_START_DATE and pet.EFFECTIVE_END_DATE
AND abt.absence_attendance_type_id= hrtsteps.Information5
and abt.input_value_id = piv.input_value_id (+)
and piv.element_type_id = pet.element_type_id(+)  ;


 cursor csr_core_absences is
 select  nvl(aba.date_start,aba.DATE_PROJECTED_START) datestart,
 nvl(aba.date_end,aba.DATE_PROJECTED_end) dateend,
 nvl(aba.TIME_START,aba.TIME_PROJECTED_START) timestart,
  nvl(aba.TIME_END,aba.TIME_PROJECTED_END) timeend,
  aba.ABSENCE_ATTENDANCE_TYPE_ID,
  pet.ELEMENT_TYPE_ID,
  aba.absence_attendance_id,
  abt.hours_or_days,
  aba.program_application_id,
  nvl(aba.ABSENCE_DAYS,aba.ABSENCE_HOURS) DURATION,
  decode (aba.date_start,'','N','Y') CONFIRMED_FLAG

 from per_absence_attendances aba,
       per_absence_attendance_types abt,
       pay_input_values_f piv,
       pay_element_types_f pet
where aba.person_id = p_person_id
AND abt.absence_attendance_type_id= aba.absence_attendance_type_id
and abt.input_value_id = piv.input_value_id (+)
and piv.element_type_id = pet.element_type_id(+)
and (p_start_date <= nvl(aba.date_end,aba.DATE_PROJECTED_end)
	 and p_end_date >= nvl(aba.date_start,aba.DATE_PROJECTED_START))

and aba.absence_attendance_id not in
                                ( select hat.transaction_ref_id
                                   from hr_api_transactions hat,
                                        HR_API_TRANSACTION_STEPS hrtsteps
                                    where
hat.SELECTED_PERSON_ID = p_person_id
--hat.creator_person_id = 125
and hat.TRANSACTION_REF_TABLE = 'PER_ABSENCE_ATTENDANCES'
and hrtsteps.TRANSACTION_ID= hat.TRANSACTION_ID
and hat.STATUS not in ('W','S','N','D','AC') -- BUG 9554066
AND hr_person_absence_swi.getstartdate(hat.transaction_id) is NOT NULL
AND hr_person_absence_swi.getenddate(hat.transaction_id) is NOT NULL
and (p_start_date <= hr_person_absence_swi.getEndDate(hat.transaction_id) and
		p_end_date >= hr_person_absence_swi.getStartDate(hat.transaction_id) ));


   l_commitElement xmldom.DOMElement;
   l_parser xmlparser.Parser;
   l_CommitNode xmldom.DOMNode;
   l_transactionid number(15,0);
   l_transactiondocument clob;
   rootNode xmldom.DOMNode;
   l_Attach_Node xmldom.DOMNode;
   l_Attach_NodeList1 xmldom.DOMNodeList;
   l_TransCtx_Node xmldom.DOMNode;
   l_TransCtx_NodeList xmldom.DOMNodeList;
   l_Attach_NodeList xmldom.DOMNodeList;
   l_ss_ovn number;
   l_rec_start_date date;
   l_rec_end_date date;
   l_duration number(9,4);

   g_debug boolean := hr_utility.debug_enabled;


begin

 if g_debug then
 hr_utility.set_location('Entering .get_absence_data ',10);
 end if;

 l_assignment_id := hr_person_absence_api.get_primary_assignment
      (p_person_id         => p_person_id
      ,p_effective_date    => p_start_date);

l_sch_based_dur := NVL(FND_PROFILE.Value('HR_SCH_BASED_ABS_CALC'),'N');

if  nvl(FND_PROFILE.Value('HR_ABS_OTL_INTEGRATION'),'N') = 'Y' THEN
 if g_debug then
 hr_utility.set_location(' Profile HR OTL Integ in ON ',10);
 end if;

--- BLOCK 1  will provide the data from SSHR Transaction tables
-- which are in Create Mode and in Pending for approval status
---------------------------
------ Block 1-------------
---------------------------

open csr_sshr_abs_records('CancelMode');
fetch csr_sshr_abs_records into  l_start_date,l_end_date,l_time_start ,l_time_end,l_transactionid,l_transactiondocument,
			l_ss_ovn,l_abs_type,l_absence_attendance_id,l_ele_type,l_hours_or_days,l_confirmed_flag;
-- if any record exists in Delete mode and pending for approval then only pass this data
-- so that OTL can take action accordingly
if  csr_sshr_abs_records%found then
close csr_sshr_abs_records;

absence_records(i).transactionid := l_transactionid;
absence_records(i).absence_type_id:=l_abs_type;
absence_records(i).element_type_id:=l_ele_type;
absence_records(i).absence_attendance_id:= l_absence_attendance_id;
absence_records(i).abs_startdate:=l_day_start_time;
absence_records(i).abs_enddate:=l_day_end_time;
absence_records(i).modetype:='DeleteMode';
absence_records(i).PROGRAM_APPLICATION_ID :='800';
absence_records(i).rec_start_date :=l_start_date;
absence_records(i).rec_end_date :=l_end_date;
absence_records(i).days_or_hours :=l_hours_or_days;

else
close csr_sshr_abs_records;

IF l_sch_based_dur = 'Y' THEN

open csr_sshr_abs_records('CreateMode');
if g_debug then
hr_utility.set_location('Block 1 -Create Mode',110);
end if;
loop
 -- fetch csr_sshr_abs_records bulk collect into l_start_date,l_end_date,l_transactionid,l_transactiondocument,l_abs_type,l_ele_type,l_hours_or_days;

fetch csr_sshr_abs_records into  l_start_date,l_end_date,l_time_start ,l_time_end,l_transactionid,l_transactiondocument,
			l_ss_ovn,l_abs_type,l_absence_attendance_id,l_ele_type,l_hours_or_days,l_confirmed_flag;

if g_debug then
hr_utility.set_location('Entering .get_absence_data ',120);
hr_utility.set_location(' l_start_date '||l_start_date,120);
hr_utility.set_location(' l_end_date '|| l_end_date,120);
hr_utility.set_location(' l_transactionid '||l_transactionid,120);
hr_utility.set_location(' l_hours_or_days '||l_hours_or_days,120);
hr_utility.set_location(' l_ele_type '||l_ele_type,120);
hr_utility.set_location(' l_abs_type '||l_abs_type,120);
end if;


exit when csr_sshr_abs_records%notfound;

--l_time_start := hr_xml_util.get_node_value(l_transactionid,'TimeStart','Transaction/TransCache/AM/TXN/EO/PerAbsenceAttendancesEORow',
    					   -- NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
--l_time_end := hr_xml_util.get_node_value(l_transactionid,'TimeEnd','Transaction/TransCache/AM/TXN/EO/PerAbsenceAttendancesEORow',
					--	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

-- as this is just in create mode so hours should be present if abs element is hours based
/*

if l_hours_or_days ='H' and (l_time_start is null or l_time_end is null ) then
  select time_start , time_end into l_time_start , l_time_end
  from per_absence_attendances
  where person_id=p_person_id
  and date_start = l_start_date
  and date_end = l_end_date;
end if;
*/

  IF l_time_start IS NULL THEN
    l_time_start := '00:00';
  ELSE
    null;
  END IF;

 IF l_time_end IS NULL THEN

   IF l_hours_or_days = 'D' THEN
      l_time_end := '00:00';
  else
    l_time_end := '23:59';
   END IF;

  ELSE
    null;
  END IF;



 v_start_date := TO_DATE(TO_CHAR(l_start_date,'DD-MM-YYYY')||' '||l_time_start,'DD-MM-YYYY HH24:MI');
 v_end_date := TO_DATE(TO_CHAR(l_end_date,'DD-MM-YYYY')||' '||l_time_end,'DD-MM-YYYY HH24:MI');
 if g_debug then
 hr_utility.set_location('v_start_date:  '||v_start_date,130);
 hr_utility.set_location('v_end_date:  '||v_end_date,130);
end if;

  IF l_hours_or_days = 'D' THEN
    v_end_date := l_end_date + 1;
  END IF;

if g_debug then
   hr_utility.set_location('before cac .get_absence_data ',140);
end if;

 hr_wrk_sch_pkg.get_per_asg_schedule
  ( p_person_assignment_id => l_assignment_id
  , p_period_start_date    => v_start_date
  , p_period_end_date      => v_end_date
  , p_schedule_category    => NULL
  , p_include_exceptions   => 'Y'
  , p_busy_tentative_as    => 'FREE'
  , x_schedule_source      => l_schedule_source
  , x_schedule             => l_schedule
  , x_return_status        => l_return_status
  , x_return_message       => l_return_message
  );

if g_debug then
 hr_utility.set_location('after cac .get_absence_data ',150);
end if;

  IF l_return_status = '0' THEN

if g_debug then
 hr_utility.set_location('Entering sch found ',151);
end if;

    l_idx := l_schedule.first;
    IF l_hours_or_days = 'D' THEN

if g_debug then
hr_utility.set_location('get_absence_data SS',152);
end if;

      l_first_band := TRUE;
      l_ref_date := NULL;

      WHILE l_idx IS NOT NULL
      LOOP

 if g_debug then
 hr_utility.set_location('get_absence_data SS',153);
 end if;

        IF l_schedule(l_idx).FREE_BUSY_TYPE IS NOT NULL THEN
          IF l_schedule(l_idx).FREE_BUSY_TYPE = 'FREE' THEN
          i:=i+1;

--l_day_start_time := TO_CHAR(l_schedule(l_idx).START_DATE_TIME,'DD-MM-YYYY HH24:MI');
--l_day_end_time := TO_CHAR(l_schedule(l_idx).END_DATE_TIME,'DD-MM-YYYY HH24:MI');

	l_day_start_time :=  fnd_date.date_to_canonical(l_schedule(l_idx).START_DATE_TIME);
	l_day_end_time :=  fnd_date.date_to_canonical(l_schedule(l_idx).END_DATE_TIME);

	   absence_records(i).transactionid := l_transactionid;
           absence_records(i).absence_type_id:=l_abs_type;
           absence_records(i).element_type_id:=l_ele_type;
	   absence_records(i).absence_attendance_id:= l_absence_attendance_id;
	   absence_records(i).abs_startdate:=l_day_start_time;
	   absence_records(i).abs_enddate:=l_day_end_time;
           absence_records(i).modetype:='CreateMode';
	   absence_records(i).PROGRAM_APPLICATION_ID :='800';
	   absence_records(i).rec_start_date :=v_start_date;
	   absence_records(i).rec_end_date :=v_end_date -1;
           absence_records(i).days_or_hours :=l_hours_or_days;
           absence_records(i).confirmed_flag :=l_confirmed_flag;-- added

          END IF;
        END IF;
    l_idx := l_schedule(l_idx).NEXT_OBJECT_INDEX;
    end loop;

  -- for hours
else
 if g_debug then
   hr_utility.set_location(' indexloop FOR Hours get_absence_data ',160);
 end if;


  l_day_start_time := '00:00';
      l_day_end_time := '23:59';
      WHILE l_idx IS NOT NULL
      LOOP
        IF l_schedule(l_idx).FREE_BUSY_TYPE IS NOT NULL THEN
          IF l_schedule(l_idx).FREE_BUSY_TYPE = 'FREE' THEN

     i:=i+1;

--l_day_start_time := TO_CHAR(l_schedule(l_idx).START_DATE_TIME,'DD-MM-YYYY HH24:MI');
--l_day_end_time := TO_CHAR(l_schedule(l_idx).END_DATE_TIME,'DD-MM-YYYY HH24:MI');

	l_day_start_time :=  fnd_date.date_to_canonical(l_schedule(l_idx).START_DATE_TIME);
	l_day_end_time :=  fnd_date.date_to_canonical(l_schedule(l_idx).END_DATE_TIME);

	absence_records(i).transactionid := l_transactionid;
        absence_records(i).absence_type_id:=l_abs_type;
        absence_records(i).element_type_id:=l_ele_type;
        absence_records(i).absence_attendance_id:= l_absence_attendance_id;
	absence_records(i).abs_startdate:=l_day_start_time;
	absence_records(i).abs_enddate:=l_day_end_time;
        absence_records(i).modetype:='CreateMode';
	absence_records(i).PROGRAM_APPLICATION_ID :='800';
        absence_records(i).rec_start_date :=v_start_date;
	absence_records(i).rec_end_date :=v_end_date ;
        absence_records(i).days_or_hours :=l_hours_or_days;
	absence_records(i).confirmed_flag :=l_confirmed_flag;-- added

          END IF;
        END IF;

        l_idx := l_schedule(l_idx).NEXT_OBJECT_INDEX;
     END LOOP;

  end if;
end if;

end loop;

close csr_sshr_abs_records;

if g_debug then
hr_utility.set_location('Block 1 -Create Mode',170);
end if;

else
--  when cac is not in use then we will provide absences on day basis as we do not know the schedule of the person

if g_debug then
hr_utility.set_location('Block 1 -CAC is not used',180);
end if;

open csr_sshr_abs_records('CreateMode');
if g_debug then
hr_utility.set_location('Entering .get_absence_data',190);
end if;
loop


fetch csr_sshr_abs_records into  l_start_date,l_end_date,l_time_start ,l_time_end,l_transactionid,l_transactiondocument,
			l_ss_ovn,l_abs_type,l_absence_attendance_id,l_ele_type,l_hours_or_days,l_confirmed_flag;

if g_debug then
hr_utility.set_location('Entering .get_absence_data ',190);
hr_utility.set_location(' l_start_date '||l_start_date,190);
hr_utility.set_location(' l_end_date '|| l_end_date,190);
hr_utility.set_location(' l_transactionid '||l_transactionid,190);
hr_utility.set_location(' l_hours_or_days '||l_hours_or_days,190);
hr_utility.set_location(' l_ele_type '||l_ele_type,190);
hr_utility.set_location(' l_abs_type '||l_abs_type,190);
end if;

exit when csr_sshr_abs_records%notfound;

l_rec_start_date :=l_start_date;
l_rec_end_date :=l_end_date;
if g_debug then
hr_utility.set_location('Entering .get_absence_data ',200);
end if;

 IF l_time_start IS NULL THEN
    l_time_start := '00:00';
    l_time_start_new := '00:00';
  else
 l_time_start_new :=l_time_start;
 end if;

  IF l_time_end IS NULL THEN
     l_time_end_new := '23:59';
			l_time_end := '23:59';
	else
  l_time_end_new :=l_time_end;

  END IF;

-- when startdate is equal to enddate-------
if l_start_date = l_end_date then
	  i:=i+1;

 l_start_date_new := TO_DATE(TO_CHAR(l_start_date,'DD-MM-YYYY')||' '||l_time_start_new,'DD-MM-YYYY HH24:MI');
 l_end_date_new := TO_DATE(TO_CHAR(l_end_date,'DD-MM-YYYY')||' '||l_time_end_new,'DD-MM-YYYY HH24:MI');

	absence_records(i).transactionid := l_transactionid;
	absence_records(i).absence_type_id:=l_abs_type;
        absence_records(i).element_type_id:=l_ele_type;
        absence_records(i).absence_attendance_id:= l_absence_attendance_id;
	absence_records(i).abs_startdate:= FND_DATE.DATE_TO_CANONICAL(l_start_date_new);		-- changed for 8844454
	absence_records(i).abs_enddate:=FND_DATE.DATE_TO_CANONICAL(l_end_date_new);			-- changed for 8844454
        absence_records(i).modetype:='CreateMode';
	absence_records(i).PROGRAM_APPLICATION_ID :='800';
        absence_records(i).rec_start_date :=l_rec_start_date;
	absence_records(i).rec_end_date :=l_rec_end_date;
        absence_records(i).days_or_hours :=l_hours_or_days;
	absence_records(i).confirmed_flag :=l_confirmed_flag;-- added

else

--- CASE 1 for to first input the startdate data ---
	  i:=i+1;

l_time_end_new := '23:59';

 l_start_date_new := TO_DATE(TO_CHAR(l_start_date,'DD-MM-YYYY')||' '||l_time_start_new,'DD-MM-YYYY HH24:MI');
 l_end_date_new := TO_DATE(TO_CHAR(l_start_date,'DD-MM-YYYY')||' '||l_time_end_new,'DD-MM-YYYY HH24:MI');

	    absence_records(i).transactionid := l_transactionid;
            absence_records(i).absence_type_id:=l_abs_type;
            absence_records(i).element_type_id:=l_ele_type;
            absence_records(i).absence_attendance_id:= l_absence_attendance_id;
	    absence_records(i).abs_startdate:= FND_DATE.DATE_TO_CANONICAL(l_start_date_new);		-- changed for 8844454
	    absence_records(i).abs_enddate:=FND_DATE.DATE_TO_CANONICAL(l_end_date_new);			-- changed for 8844454
            absence_records(i).modetype:='CreateMode';
	    absence_records(i).PROGRAM_APPLICATION_ID :='800';
            absence_records(i).rec_start_date :=l_rec_start_date;
	    absence_records(i).rec_end_date :=l_rec_end_date;
            absence_records(i).days_or_hours :=l_hours_or_days;
	    absence_records(i).confirmed_flag :=l_confirmed_flag;-- added

-- end of case 1----
-- case 2 is to insert from startdate + 1 to    enddate-1   ------

l_start_date:=l_start_date + 1;

 while l_start_date < l_end_date
         loop
	  i:=i+1;

l_time_start_new := '00:00';
l_time_end_new := '23:59';

 l_start_date_new := TO_DATE(TO_CHAR(l_start_date,'DD-MM-YYYY')||' '||l_time_start_new,'DD-MM-YYYY HH24:MI');
 l_end_date_new := TO_DATE(TO_CHAR(l_start_date,'DD-MM-YYYY')||' '||l_time_end_new,'DD-MM-YYYY HH24:MI');

            absence_records(i).transactionid := l_transactionid;
            absence_records(i).absence_type_id:=l_abs_type;
            absence_records(i).element_type_id:=l_ele_type;
            absence_records(i).absence_attendance_id:= l_absence_attendance_id;
	    absence_records(i).abs_startdate:= FND_DATE.DATE_TO_CANONICAL(l_start_date_new);		-- changed for 8844454
	    absence_records(i).abs_enddate:=FND_DATE.DATE_TO_CANONICAL(l_end_date_new);			-- changed for 8844454
            absence_records(i).modetype:='CreateMode';
	    absence_records(i).PROGRAM_APPLICATION_ID :='800';
            absence_records(i).rec_start_date :=l_rec_start_date;
	    absence_records(i).rec_end_date :=l_rec_end_date;
            absence_records(i).days_or_hours :=l_hours_or_days;
	    absence_records(i).confirmed_flag :=l_confirmed_flag;-- added

	l_start_date :=l_start_date+1;

	end loop;

-- end of case2 -----
-- case 3 to insert only enddate data---

i:=i+1;

l_time_start_new := '00:00';

 l_start_date_new := TO_DATE(TO_CHAR(l_start_date,'DD-MM-YYYY')||' '||l_time_start_new,'DD-MM-YYYY HH24:MI');
 l_end_date_new := TO_DATE(TO_CHAR(l_start_date,'DD-MM-YYYY')||' '||l_time_end,'DD-MM-YYYY HH24:MI');

	    absence_records(i).transactionid := l_transactionid;
            absence_records(i).absence_type_id:=l_abs_type;
            absence_records(i).element_type_id:=l_ele_type;
            absence_records(i).absence_attendance_id:= l_absence_attendance_id;
	    absence_records(i).abs_startdate:= FND_DATE.DATE_TO_CANONICAL(l_start_date_new);		-- changed for 8844454
	    absence_records(i).abs_enddate:=FND_DATE.DATE_TO_CANONICAL(l_end_date_new);			-- changed for 8844454
            absence_records(i).modetype:='CreateMode';
	    absence_records(i).PROGRAM_APPLICATION_ID :='800';
            absence_records(i).rec_start_date :=l_rec_start_date;
	    absence_records(i).rec_end_date :=l_rec_end_date;
            absence_records(i).days_or_hours :=l_hours_or_days;
	    absence_records(i).confirmed_flag :=l_confirmed_flag;-- added

-- END of case3 to insert only enddate ---


 end if;
end loop;
close csr_sshr_abs_records;
end if; -- CAC Check

if g_debug then
hr_utility.set_location('End of Create Mode Blk1 ',200);
end if;

-----END  OF  BLOCK 1-----

-- Block 2 will provide data from SSHR transaction tables which are in update mode
-- will retrieve the data and a check is made with Core data to see which is having higher OVN number
-- high ovn data will be sent and if core is having high ovn then the sshr transaction data is invalid

------------------------
----BLOCK 2-----
------------------------
while (ssmodes < 3) loop

if ssmodes =1 then
p_ssmode :='UpdateMode';

elsif ssmodes =2 then
p_ssmode  :='ConfirmMode';

end if;

open csr_sshr_abs_records(p_ssmode);

if g_debug then
hr_utility.set_location('Start of BLock 2',210);
hr_utility.set_location('Entering .get_absence_data',210);

end if;
loop
 fetch csr_sshr_abs_records into  l_start_date,l_end_date,l_time_start ,l_time_end,l_transactionid,l_transactiondocument,
			l_ss_ovn,l_abs_type,l_absence_attendance_id,l_ele_type,l_hours_or_days,l_confirmed_flag;

 exit when csr_sshr_abs_records%notfound;
 hr_utility.set_location('Before sql stmt',220);

 BEGIN
 l_core_ovn :=null;
			select nvl(date_start,DATE_PROJECTED_START) datestart,
				 nvl(date_end,DATE_PROJECTED_end) dateend,
				 nvl(TIME_START,TIME_PROJECTED_START) timestart,
				 nvl(TIME_END,TIME_PROJECTED_END) timeend,
				 ABSENCE_ATTENDANCE_TYPE_ID,
				 OBJECT_VERSION_NUMBER
			     INTO l_core_dstart  ,l_core_dend, l_core_tstart, l_core_tend, l_core_abs_attendance_id , l_core_ovn
 			from per_absence_attendances
 			where ABSENCE_ATTENDANCE_ID = l_absence_attendance_id;
if g_debug then
   hr_utility.set_location('after sql stmt',220);
end if;

 exception
  when no_data_found then

  if g_debug then
  hr_utility.set_location('in the exception',220);
  end if;

   j:=j+1;
   absence_records_inv(j).transactionid := l_transactionid;
   absence_records_inv(j).abs_startdate :=  FND_DATE.DATE_TO_CANONICAL(l_start_date);		-- changed for 8844454
   absence_records_inv(j).abs_enddate :=  FND_DATE.DATE_TO_CANONICAL(l_end_date);		-- changed for 8844454


   END; -- end of core sql

 if l_core_ovn > l_ss_ovn then
 -- ss data is invalid hence insert core data in to pl sql table
 if g_debug then
  hr_utility.set_location('Core Data modified when SS is pending',220);
  end if;

  j:=j+1;
   absence_records_inv(j).transactionid := l_transactionid;
   absence_records_inv(j).abs_startdate := FND_DATE.DATE_TO_CANONICAL(l_start_date);		-- changed for 8844454
   absence_records_inv(j).abs_enddate := FND_DATE.DATE_TO_CANONICAL(l_end_date);		-- changed for 8844454

-- assigning to old local vars so that rest of process remains same and we do not need to replace the
-- variables with core ones.
--
  l_time_start:=l_core_tstart;
  l_time_end :=l_core_tend;
  l_start_date:=l_core_dstart;
  l_end_date:=l_core_dend;
 --

   IF l_sch_based_dur = 'Y' THEN

  hr_utility.set_location('CAC profile set to Yes Block2',230);
    IF l_time_start IS NULL THEN
    l_time_start := '00:00';
  ELSE
    null;
  END IF;

 IF l_time_end IS NULL THEN

   IF l_hours_or_days = 'D' THEN
      l_time_end := '00:00';
  else
    l_time_end := '23:59';
   END IF;

  ELSE
    null;
  END IF;



 v_start_date := TO_DATE(TO_CHAR(l_start_date,'DD-MM-YYYY')||' '||l_time_start,'DD-MM-YYYY HH24:MI');
 v_end_date := TO_DATE(TO_CHAR(l_end_date,'DD-MM-YYYY')||' '||l_time_end,'DD-MM-YYYY HH24:MI');

 if g_debug then
 hr_utility.set_location('v_start_date:  '||v_start_date,10);
 hr_utility.set_location('v_end_date:  '||v_end_date,10);
 end if;

  IF l_hours_or_days = 'D' THEN
    v_end_date := l_end_date + 1;
  END IF;

hr_wrk_sch_pkg.get_per_asg_schedule
  ( p_person_assignment_id => l_assignment_id
  , p_period_start_date    => v_start_date
  , p_period_end_date      => v_end_date
  , p_schedule_category    => NULL
  , p_include_exceptions   => 'Y'
  , p_busy_tentative_as    => 'FREE'
  , x_schedule_source      => l_schedule_source
  , x_schedule             => l_schedule
  , x_return_status        => l_return_status
  , x_return_message       => l_return_message
  );
 hr_utility.set_location('after cac .get_absence_data ',230);


  IF l_return_status = '0' THEN

if g_debug then
 hr_utility.set_location('Entering sch found ',240);
end if;

    l_idx := l_schedule.first;

  IF l_hours_or_days = 'D' THEN

if g_debug then
hr_utility.set_location('.get_absence_data ',250);
end if;

      l_first_band := TRUE;
      l_ref_date := NULL;

      WHILE l_idx IS NOT NULL
      LOOP

 if g_debug then
 hr_utility.set_location('.get_absence_data',270);
 end if;

        IF l_schedule(l_idx).FREE_BUSY_TYPE IS NOT NULL THEN
          IF l_schedule(l_idx).FREE_BUSY_TYPE = 'FREE' THEN
          i:=i+1;

--l_day_start_time := TO_CHAR(l_schedule(l_idx).START_DATE_TIME,'DD-MM-YYYY HH24:MI');
--l_day_end_time := TO_CHAR(l_schedule(l_idx).END_DATE_TIME,'DD-MM-YYYY HH24:MI');


	    l_day_start_time :=  fnd_date.date_to_canonical(l_schedule(l_idx).START_DATE_TIME);
     	    l_day_end_time :=  fnd_date.date_to_canonical(l_schedule(l_idx).END_DATE_TIME);
            absence_records(i).absence_type_id:=l_abs_type;
            absence_records(i).element_type_id:=l_ele_type;
 	    absence_records(i).abs_startdate:=l_day_start_time;
	    absence_records(i).abs_enddate:=l_day_end_time;
            absence_records(i).absence_attendance_id:= l_absence_attendance_id ;
	    absence_records(i).PROGRAM_APPLICATION_ID :='800';
            absence_records(i).rec_start_date :=v_start_date;
	    absence_records(i).rec_end_date :=v_end_date -1;
            absence_records(i).days_or_hours :=l_hours_or_days;
	   absence_records(i).confirmed_flag :=l_confirmed_flag;-- added

          END IF;
        END IF;
    l_idx := l_schedule(l_idx).NEXT_OBJECT_INDEX;
    end loop;

  -- for hours
else

 if g_debug then
   hr_utility.set_location(' indexloop hours .get_absence_data block2 ',280);
 end if;


  l_day_start_time := '00:00';
      l_day_end_time := '23:59';
      WHILE l_idx IS NOT NULL
      LOOP
        IF l_schedule(l_idx).FREE_BUSY_TYPE IS NOT NULL THEN
          IF l_schedule(l_idx).FREE_BUSY_TYPE = 'FREE' THEN

     i:=i+1;

--l_day_start_time := TO_CHAR(l_schedule(l_idx).START_DATE_TIME,'DD-MM-YYYY HH24:MI');
--l_day_end_time := TO_CHAR(l_schedule(l_idx).END_DATE_TIME,'DD-MM-YYYY HH24:MI');

	  l_day_start_time :=  fnd_date.date_to_canonical(l_schedule(l_idx).START_DATE_TIME);
	  l_day_end_time :=  fnd_date.date_to_canonical(l_schedule(l_idx).END_DATE_TIME);
          absence_records(i).absence_attendance_id:= l_absence_attendance_id;
          absence_records(i).absence_type_id:=l_abs_type;
          absence_records(i).element_type_id:=l_ele_type;
     	  absence_records(i).abs_startdate:=l_day_start_time;
	  absence_records(i).abs_enddate:=l_day_end_time;
          absence_records(i).PROGRAM_APPLICATION_ID :='800';
          absence_records(i).rec_start_date :=v_start_date;
	  absence_records(i).rec_end_date :=v_end_date;
          absence_records(i).days_or_hours :=l_hours_or_days;
	  absence_records(i).confirmed_flag :=l_confirmed_flag;-- added

          END IF;
        END IF;

        l_idx := l_schedule(l_idx).NEXT_OBJECT_INDEX;
     END LOOP;

  end if; -- hours or days
end if; -- l_return_status


else
--  when cac is not in use then we will provide absences on day basis as we do not know the schedule of the person

if g_debug then
   hr_utility.set_location('CAC is not used -block2 ',290);
end if;
l_rec_start_date :=l_start_date;
l_rec_end_date :=l_end_date;

/* -- old code

 while l_start_date <= l_end_date
         loop
	i:=i+1;


            absence_records(i).absence_type_id:=l_abs_type;
            absence_records(i).element_type_id:=l_ele_type;
            absence_records(i).abs_startdate:=FND_DATE.DATE_TO_CANONICAL(l_start_date);	 	-- changed for 8844454
	    absence_records(i).abs_enddate:=FND_DATE.DATE_TO_CANONICAL(l_start_date); 	-- changed for 8844454
            absence_records(i).absence_attendance_id:= l_absence_attendance_id;
	    absence_records(i).PROGRAM_APPLICATION_ID :='800';
	    absence_records(i).rec_start_date :=l_rec_start_date;
	    absence_records(i).rec_end_date :=l_rec_end_date;
            absence_records(i).days_or_hours :=l_hours_or_days;

	l_start_date :=l_start_date+1;

*/-- end of old code


 IF l_time_start IS NULL THEN
    l_time_start := '00:00';
    l_time_start_new := '00:00';
  else
 l_time_start_new :=l_time_start;
 end if;

  IF l_time_end IS NULL THEN
     l_time_end_new := '23:59';
			l_time_end := '23:59';
	else
  l_time_end_new :=l_time_end;

  END IF;

-- when startdate is equal to enddate-------

if l_start_date = l_end_date then  -- start of blk2 ins if
	  i:=i+1;

 l_start_date_new := TO_DATE(TO_CHAR(l_start_date,'DD-MM-YYYY')||' '||l_time_start_new,'DD-MM-YYYY HH24:MI');
 l_end_date_new := TO_DATE(TO_CHAR(l_end_date,'DD-MM-YYYY')||' '||l_time_end_new,'DD-MM-YYYY HH24:MI');

  absence_records(i).absence_type_id:=l_abs_type;
  absence_records(i).element_type_id:=l_ele_type;
  absence_records(i).abs_startdate:=FND_DATE.DATE_TO_CANONICAL(l_start_date_new); -- changed for 8844454
  absence_records(i).abs_enddate:=FND_DATE.DATE_TO_CANONICAL(l_end_date_new); -- changed for 8844454
  absence_records(i).absence_attendance_id:= l_absence_attendance_id;
  absence_records(i).PROGRAM_APPLICATION_ID :='800';
  absence_records(i).rec_start_date :=l_rec_start_date;
  absence_records(i).rec_end_date :=l_rec_end_date;
  absence_records(i).days_or_hours :=l_hours_or_days;
  absence_records(i).confirmed_flag :=l_confirmed_flag;-- added

else

--- CASE 1 for to first input the startdate ---
	  i:=i+1;

l_time_end_new := '23:59';

 l_start_date_new := TO_DATE(TO_CHAR(l_start_date,'DD-MM-YYYY')||' '||l_time_start_new,'DD-MM-YYYY HH24:MI');
 l_end_date_new := TO_DATE(TO_CHAR(l_start_date,'DD-MM-YYYY')||' '||l_time_end_new,'DD-MM-YYYY HH24:MI');

 absence_records(i).absence_type_id:=l_abs_type;
 absence_records(i).element_type_id:=l_ele_type;
 absence_records(i).abs_startdate:=FND_DATE.DATE_TO_CANONICAL(l_start_date_new);  -- changed for 8844454
 absence_records(i).abs_enddate:=FND_DATE.DATE_TO_CANONICAL(l_end_date_new); -- changed for 8844454
 absence_records(i).absence_attendance_id:= l_absence_attendance_id;
 absence_records(i).PROGRAM_APPLICATION_ID :='800';
 absence_records(i).rec_start_date :=l_rec_start_date;
 absence_records(i).rec_end_date :=l_rec_end_date;
 absence_records(i).days_or_hours :=l_hours_or_days;
  absence_records(i).confirmed_flag :=l_confirmed_flag;-- added

-- end of case 1----
-- case 2 is to insert from startdate + 1 to    enddate-1   ------

l_start_date:=l_start_date + 1;

 while l_start_date < l_end_date
         loop
	  i:=i+1;

l_time_start_new := '00:00';
l_time_end_new := '23:59';

 l_start_date_new := TO_DATE(TO_CHAR(l_start_date,'DD-MM-YYYY')||' '||l_time_start_new,'DD-MM-YYYY HH24:MI');
 l_end_date_new := TO_DATE(TO_CHAR(l_start_date,'DD-MM-YYYY')||' '||l_time_end_new,'DD-MM-YYYY HH24:MI');

  absence_records(i).absence_type_id:=l_abs_type;
  absence_records(i).element_type_id:=l_ele_type;
  absence_records(i).abs_startdate:=FND_DATE.DATE_TO_CANONICAL(l_start_date_new); 	-- changed for 8844454
  absence_records(i).abs_enddate:=FND_DATE.DATE_TO_CANONICAL(l_end_date_new); -- changed for 8844454
  absence_records(i).absence_attendance_id:= l_absence_attendance_id;
  absence_records(i).PROGRAM_APPLICATION_ID :='800';
  absence_records(i).rec_start_date :=l_rec_start_date;
  absence_records(i).rec_end_date :=l_rec_end_date;
  absence_records(i).days_or_hours :=l_hours_or_days;
  absence_records(i).confirmed_flag :=l_confirmed_flag;-- added

  l_start_date :=l_start_date+1;

  end loop;
-- end of case2 -----
-- case 3 to insert only enddate data---
i:=i+1;

l_time_start_new := '00:00';

 l_start_date_new := TO_DATE(TO_CHAR(l_start_date,'DD-MM-YYYY')||' '||l_time_start_new,'DD-MM-YYYY HH24:MI');
 l_end_date_new := TO_DATE(TO_CHAR(l_start_date,'DD-MM-YYYY')||' '||l_time_end,'DD-MM-YYYY HH24:MI');


  absence_records(i).absence_type_id:=l_abs_type;
  absence_records(i).element_type_id:=l_ele_type;
  absence_records(i).abs_startdate:=FND_DATE.DATE_TO_CANONICAL(l_start_date_new); -- changed for 8844454
  absence_records(i).abs_enddate:=FND_DATE.DATE_TO_CANONICAL(l_end_date_new);	 -- changed for 8844454
  absence_records(i).absence_attendance_id:= l_absence_attendance_id;
  absence_records(i).PROGRAM_APPLICATION_ID :='800';
  absence_records(i).rec_start_date :=l_rec_start_date;
  absence_records(i).rec_end_date :=l_rec_end_date;
  absence_records(i).days_or_hours :=l_hours_or_days;
  absence_records(i).confirmed_flag :=l_confirmed_flag;-- added

-- END of case3 to insert only enddate ---


   end if; --end of  blk2 ins if

 end if; -- CAC Cheeck if condition

 elsif  l_core_ovn <= l_ss_ovn then -- " SSHR DATA is valid and insert into pl sql table. " --( bug fix 8881266 )
---------------
-- " SSHR DATA is valid and insert into pl sql table. "
---------------
if g_debug then
   hr_utility.set_location('SS Tran data is valid- block2 ',280);
end if;


if l_hours_or_days ='H' then

 if (l_time_start is null ) then
  select nvl(TIME_START,TIME_PROJECTED_START)into l_time_start
  from per_absence_attendances
  where  ABSENCE_ATTENDANCE_ID = l_absence_attendance_id;
 end if;

 if ( l_time_end is null ) then
  select nvl(TIME_END,TIME_PROJECTED_END) into  l_time_end
  from per_absence_attendances
  where  ABSENCE_ATTENDANCE_ID = l_absence_attendance_id;

end if;

end if;

IF l_sch_based_dur = 'Y' THEN

	if g_debug then
	hr_utility.set_location(' CAC profile set to Yes block2 ',280);
	end if;

-- as this is in update mode so hours may not be present in ss tran tables hence getting from core tables


 IF l_time_start IS NULL THEN
    l_time_start := '00:00';
  ELSE
    null;
  END IF;

 IF l_time_end IS NULL THEN

   IF l_hours_or_days = 'D' THEN
      l_time_end := '00:00';
  else
    l_time_end := '23:59';
   END IF;

  ELSE
    null;
  END IF;



 v_start_date := TO_DATE(TO_CHAR(l_start_date,'DD-MM-YYYY')||' '||l_time_start,'DD-MM-YYYY HH24:MI');
 v_end_date := TO_DATE(TO_CHAR(l_end_date,'DD-MM-YYYY')||' '||l_time_end,'DD-MM-YYYY HH24:MI');
if g_debug then
 hr_utility.set_location('v_start_date:  '||v_start_date,290);
 hr_utility.set_location('v_end_date:  '||v_end_date,290);
end if;

  IF l_hours_or_days = 'D' THEN
    v_end_date := l_end_date + 1;
  END IF;

if g_debug then
   hr_utility.set_location('before cac .get_absence_data ',300);
end if;
 hr_wrk_sch_pkg.get_per_asg_schedule
  ( p_person_assignment_id => l_assignment_id
  , p_period_start_date    => v_start_date
  , p_period_end_date      => v_end_date
  , p_schedule_category    => NULL
  , p_include_exceptions   => 'Y'
  , p_busy_tentative_as    => 'FREE'
  , x_schedule_source      => l_schedule_source
  , x_schedule             => l_schedule
  , x_return_status        => l_return_status
  , x_return_message       => l_return_message
  );
if g_debug then
 hr_utility.set_location('after cac .get_absence_data ',310);
end if;

  IF l_return_status = '0' THEN

if g_debug then
 hr_utility.set_location('Entering sch found ',310);
end if;

    l_idx := l_schedule.first;
    IF l_hours_or_days = 'D' THEN

if g_debug then
hr_utility.set_location('.get_absence_data ',320);
end if;

      l_first_band := TRUE;
      l_ref_date := NULL;

      WHILE l_idx IS NOT NULL
      LOOP

 if g_debug then
 hr_utility.set_location('.get_absence_data ',330);
 end if;

        IF l_schedule(l_idx).FREE_BUSY_TYPE IS NOT NULL THEN
          IF l_schedule(l_idx).FREE_BUSY_TYPE = 'FREE' THEN
          i:=i+1;

--l_day_start_time := TO_CHAR(l_schedule(l_idx).START_DATE_TIME,'DD-MM-YYYY HH24:MI');
--l_day_end_time := TO_CHAR(l_schedule(l_idx).END_DATE_TIME,'DD-MM-YYYY HH24:MI');

	l_day_start_time :=  fnd_date.date_to_canonical(l_schedule(l_idx).START_DATE_TIME);
	l_day_end_time :=  fnd_date.date_to_canonical(l_schedule(l_idx).END_DATE_TIME);

	    absence_records(i).transactionid := l_transactionid;
            absence_records(i).absence_type_id:=l_abs_type;
            absence_records(i).element_type_id:=l_ele_type;
 	    absence_records(i).abs_startdate:=l_day_start_time;
	    absence_records(i).abs_enddate:=l_day_end_time;
            absence_records(i).modetype:='UPdateMode';
	    absence_records(i).PROGRAM_APPLICATION_ID :='800';
            absence_records(i).absence_attendance_id:= l_absence_attendance_id;
	    absence_records(i).rec_start_date :=v_start_date;
	    absence_records(i).rec_end_date :=v_end_date -1;
            absence_records(i).days_or_hours :=l_hours_or_days;
	    absence_records(i).confirmed_flag :=l_confirmed_flag;-- added

          END IF;
        END IF;
    l_idx := l_schedule(l_idx).NEXT_OBJECT_INDEX;
    end loop;

  -- for hours
else
 if g_debug then
   hr_utility.set_location(' indexloop hours .get_absence_data blk2',340);
 end if;


  l_day_start_time := '00:00';
      l_day_end_time := '23:59';
      WHILE l_idx IS NOT NULL
      LOOP
        IF l_schedule(l_idx).FREE_BUSY_TYPE IS NOT NULL THEN
          IF l_schedule(l_idx).FREE_BUSY_TYPE = 'FREE' THEN

     i:=i+1;

--l_day_start_time := TO_CHAR(l_schedule(l_idx).START_DATE_TIME,'DD-MM-YYYY HH24:MI');
--l_day_end_time := TO_CHAR(l_schedule(l_idx).END_DATE_TIME,'DD-MM-YYYY HH24:MI');

	l_day_start_time :=  fnd_date.date_to_canonical(l_schedule(l_idx).START_DATE_TIME);
	l_day_end_time :=  fnd_date.date_to_canonical(l_schedule(l_idx).END_DATE_TIME);

	    absence_records(i).transactionid := l_transactionid;
            absence_records(i).absence_type_id:=l_abs_type;
            absence_records(i).element_type_id:=l_ele_type;
     	    absence_records(i).abs_startdate:=l_day_start_time;
	    absence_records(i).abs_enddate:=l_day_end_time;
            absence_records(i).modetype:='UpdateMode';
	    absence_records(i).PROGRAM_APPLICATION_ID :='800';
	    absence_records(i).absence_attendance_id:= l_absence_attendance_id;
	    absence_records(i).rec_start_date :=v_start_date;
	    absence_records(i).rec_end_date :=v_end_date;
	    absence_records(i).days_or_hours :=l_hours_or_days;
	    absence_records(i).confirmed_flag :=l_confirmed_flag;-- added

          END IF;
        END IF;

        l_idx := l_schedule(l_idx).NEXT_OBJECT_INDEX;
     END LOOP;

  end if;  -- l_hours_days if
end if; -- l_return_status if


else

--  when cac is not in use then we will provide absences on day basis as we do not know the schedule of the person

if g_debug then
   hr_utility.set_location('CAC is not used -block2 ',290);
end if;
l_rec_start_date :=l_start_date;
l_rec_end_date :=l_end_date;

/*

 while l_start_date <= l_end_date
         loop
	i:=i+1;

	absence_records(i).transactionid := l_transactionid;
	absence_records(i).absence_type_id:=l_abs_type;
	absence_records(i).element_type_id:=l_ele_type;
	absence_records(i).abs_startdate:=FND_DATE.DATE_TO_CANONICAL(l_start_date);		-- changed for 8844454
	absence_records(i).abs_enddate:=FND_DATE.DATE_TO_CANONICAL(l_start_date);		-- changed for 8844454
	absence_records(i).modetype:='UpdateMode';
	absence_records(i).absence_attendance_id:= l_absence_attendance_id;
	absence_records(i).PROGRAM_APPLICATION_ID :='800';
	absence_records(i).rec_start_date :=l_rec_start_date;
	absence_records(i).rec_end_date :=l_rec_end_date;
	absence_records(i).days_or_hours :=l_hours_or_days;

	l_start_date :=l_start_date+1;
	end loop;
*/


 IF l_time_start IS NULL THEN
    l_time_start := '00:00';
    l_time_start_new := '00:00';
  else
 l_time_start_new :=l_time_start;
 end if;

  IF l_time_end IS NULL THEN
     l_time_end_new := '23:59';
     l_time_end := '23:59';
  else
  l_time_end_new :=l_time_end;

  END IF;

-- when startdate is equal to enddate-------

if l_start_date = l_end_date then
	  i:=i+1;

 l_start_date_new := TO_DATE(TO_CHAR(l_start_date,'DD-MM-YYYY')||' '||l_time_start_new,'DD-MM-YYYY HH24:MI');
 l_end_date_new := TO_DATE(TO_CHAR(l_end_date,'DD-MM-YYYY')||' '||l_time_end_new,'DD-MM-YYYY HH24:MI');


	absence_records(i).transactionid := l_transactionid;
	absence_records(i).absence_type_id:=l_abs_type;
	absence_records(i).element_type_id:=l_ele_type;
	absence_records(i).abs_startdate:=FND_DATE.DATE_TO_CANONICAL(l_start_date_new);		-- changed for 8844454
	absence_records(i).abs_enddate:=FND_DATE.DATE_TO_CANONICAL(l_end_date_new);		-- changed for 8844454
	absence_records(i).modetype:='UpdateMode';
	absence_records(i).absence_attendance_id:= l_absence_attendance_id;
	absence_records(i).PROGRAM_APPLICATION_ID :='800';
	absence_records(i).rec_start_date :=l_rec_start_date;
	absence_records(i).rec_end_date :=l_rec_end_date;
	absence_records(i).days_or_hours :=l_hours_or_days;
	absence_records(i).confirmed_flag :=l_confirmed_flag;-- added

else

--- CASE 1 for to first input the start date ---
	  i:=i+1;

l_time_end_new := '23:59';

 l_start_date_new := TO_DATE(TO_CHAR(l_start_date,'DD-MM-YYYY')||' '||l_time_start_new,'DD-MM-YYYY HH24:MI');
 l_end_date_new := TO_DATE(TO_CHAR(l_end_date,'DD-MM-YYYY')||' '||l_time_end_new,'DD-MM-YYYY HH24:MI');


	absence_records(i).transactionid := l_transactionid;
	absence_records(i).absence_type_id:=l_abs_type;
	absence_records(i).element_type_id:=l_ele_type;
	absence_records(i).abs_startdate:=FND_DATE.DATE_TO_CANONICAL(l_start_date_new);		-- changed for 8844454
	absence_records(i).abs_enddate:=FND_DATE.DATE_TO_CANONICAL(l_end_date_new);		-- changed for 8844454
	absence_records(i).modetype:='UpdateMode';
	absence_records(i).absence_attendance_id:= l_absence_attendance_id;
	absence_records(i).PROGRAM_APPLICATION_ID :='800';
	absence_records(i).rec_start_date :=l_rec_start_date;
	absence_records(i).rec_end_date :=l_rec_end_date;
	absence_records(i).days_or_hours :=l_hours_or_days;
	absence_records(i).confirmed_flag :=l_confirmed_flag;-- added

-- end of case 1----
-- case 2 is to insert from startdate + 1 to    enddate-1   ------

l_start_date:=l_start_date + 1;

 while l_start_date < l_end_date
         loop
	  i:=i+1;

l_time_start_new := '00:00';
l_time_end_new := '23:59';

 l_start_date_new := TO_DATE(TO_CHAR(l_start_date,'DD-MM-YYYY')||' '||l_time_start_new,'DD-MM-YYYY HH24:MI');
 l_end_date_new := TO_DATE(TO_CHAR(l_end_date,'DD-MM-YYYY')||' '||l_time_end_new,'DD-MM-YYYY HH24:MI');


	absence_records(i).transactionid := l_transactionid;
	absence_records(i).absence_type_id:=l_abs_type;
	absence_records(i).element_type_id:=l_ele_type;
	absence_records(i).abs_startdate:=FND_DATE.DATE_TO_CANONICAL(l_start_date_new);		-- changed for 8844454
	absence_records(i).abs_enddate:=FND_DATE.DATE_TO_CANONICAL(l_end_date_new);		-- changed for 8844454
	absence_records(i).modetype:='UpdateMode';
	absence_records(i).absence_attendance_id:= l_absence_attendance_id;
	absence_records(i).PROGRAM_APPLICATION_ID :='800';
	absence_records(i).rec_start_date :=l_rec_start_date;
	absence_records(i).rec_end_date :=l_rec_end_date;
	absence_records(i).days_or_hours :=l_hours_or_days;
	absence_records(i).confirmed_flag :=l_confirmed_flag;-- added

l_start_date :=l_start_date+1;
	end loop;
-- end of case2 -----
-- case 3 to insert only enddate data---
i:=i+1;

l_time_start_new := '00:00';

 l_start_date_new := TO_DATE(TO_CHAR(l_start_date,'DD-MM-YYYY')||' '||l_time_start_new,'DD-MM-YYYY HH24:MI');
 l_end_date_new := TO_DATE(TO_CHAR(l_end_date,'DD-MM-YYYY')||' '||l_time_end,'DD-MM-YYYY HH24:MI');


	absence_records(i).transactionid := l_transactionid;
	absence_records(i).absence_type_id:=l_abs_type;
	absence_records(i).element_type_id:=l_ele_type;
	absence_records(i).abs_startdate:=FND_DATE.DATE_TO_CANONICAL(l_start_date_new);		-- changed for 8844454
	absence_records(i).abs_enddate:=FND_DATE.DATE_TO_CANONICAL(l_end_date_new);		-- changed for 8844454
	absence_records(i).modetype:='UpdateMode';
	absence_records(i).absence_attendance_id:= l_absence_attendance_id;
	absence_records(i).PROGRAM_APPLICATION_ID :='800';
	absence_records(i).rec_start_date :=l_rec_start_date;
	absence_records(i).rec_end_date :=l_rec_end_date;
	absence_records(i).days_or_hours :=l_hours_or_days;
	absence_records(i).confirmed_flag :=l_confirmed_flag;-- added

-- END of case3 to insert only enddate ---

    end if;
  end if; -- CAC check block 2

end if; -- core_ovn > ss_ovn  if condition
end loop;
close csr_sshr_abs_records;
if g_debug then
 hr_utility.set_location(' End of Blk2',340);
end if;
ssmodes :=ssmodes+1;
end loop; -- new while loop to cover for "COnfirm mode" as well
-----------------------
----End of Block 2-----
-----------------------

---Start of Block 3------
----------------
-- This will provide only the data in CORE Tables for which no transaction is in update mode and
-- pending for approval.

open csr_core_absences;
loop
fetch csr_core_absences into  l_start_date,l_end_date,l_time_start ,l_time_end,
	l_abs_type,l_ele_type,l_absence_attendance_id,l_hours_or_days,l_program_application_id,l_duration,l_confirmed_flag;


if g_debug then
 hr_utility.set_location(' Ony Core Data Blk3',400);
end if;

if g_debug then
hr_utility.set_location('Entering .get_absence_data',400);
hr_utility.set_location(' l_start_date '||l_start_date,400);
hr_utility.set_location(' l_end_date '|| l_end_date,400);

hr_utility.set_location(' l_hours_or_days '||l_hours_or_days,400);
hr_utility.set_location(' l_ele_type '||l_ele_type,400);
hr_utility.set_location(' l_abs_type '||l_abs_type,400);
end if;

exit when csr_core_absences%notfound;

IF l_sch_based_dur = 'Y' THEN

if g_debug then
 hr_utility.set_location(' CAC Profile set yes Blk3',410);
end if;


 IF l_time_start IS NULL THEN
    l_time_start := '00:00';
  ELSE
    null;
  END IF;

 IF l_time_end IS NULL THEN

   IF l_hours_or_days = 'D' THEN
      l_time_end := '00:00';
  else
    l_time_end := '23:59';
   END IF;

  ELSE
    null;
  END IF;



 v_start_date := TO_DATE(TO_CHAR(l_start_date,'DD-MM-YYYY')||' '||l_time_start,'DD-MM-YYYY HH24:MI');
 v_end_date := TO_DATE(TO_CHAR(l_end_date,'DD-MM-YYYY')||' '||l_time_end,'DD-MM-YYYY HH24:MI');
if g_debug then
 hr_utility.set_location('v_start_date:  '||v_start_date,410);
 hr_utility.set_location('v_end_date:  '||v_end_date,410);
end if;

  IF l_hours_or_days = 'D' THEN
    v_end_date := l_end_date + 1;
  END IF;

if g_debug then
   hr_utility.set_location('before cac .get_absence_data SS',420);
end if;
 hr_wrk_sch_pkg.get_per_asg_schedule
  ( p_person_assignment_id => l_assignment_id
  , p_period_start_date    => v_start_date
  , p_period_end_date      => v_end_date
  , p_schedule_category    => NULL
  , p_include_exceptions   => 'Y'
  , p_busy_tentative_as    => 'FREE'
  , x_schedule_source      => l_schedule_source
  , x_schedule             => l_schedule
  , x_return_status        => l_return_status
  , x_return_message       => l_return_message
  );
if g_debug then
 hr_utility.set_location('after cac .get_absence_data ',430);
end if;

  IF l_return_status = '0' THEN

if g_debug then
 hr_utility.set_location('Entering sch found ',430);
end if;

    l_idx := l_schedule.first;
    IF l_hours_or_days = 'D' THEN

if g_debug then
hr_utility.set_location('.get_absence_data',440);
end if;

      l_first_band := TRUE;
      l_ref_date := NULL;

      WHILE l_idx IS NOT NULL
      LOOP

 if g_debug then
 hr_utility.set_location('.get_absence_data',450);
 end if;

        IF l_schedule(l_idx).FREE_BUSY_TYPE IS NOT NULL THEN
          IF l_schedule(l_idx).FREE_BUSY_TYPE = 'FREE' THEN
          i:=i+1;

--l_day_start_time := TO_CHAR(l_schedule(l_idx).START_DATE_TIME,'DD-MM-YYYY HH24:MI');
--l_day_end_time := TO_CHAR(l_schedule(l_idx).END_DATE_TIME,'DD-MM-YYYY HH24:MI');

	l_day_start_time :=  fnd_date.date_to_canonical(l_schedule(l_idx).START_DATE_TIME);
	l_day_end_time :=  fnd_date.date_to_canonical(l_schedule(l_idx).END_DATE_TIME);

            absence_records(i).absence_type_id:=l_abs_type;
            absence_records(i).element_type_id:=l_ele_type;
 	    absence_records(i).abs_startdate:=l_day_start_time;
	    absence_records(i).abs_enddate:=l_day_end_time;
            absence_records(i).absence_attendance_id:= l_absence_attendance_id;
	    absence_records(i).PROGRAM_APPLICATION_ID :=l_program_application_id;
            absence_records(i).rec_start_date :=v_start_date;
	    absence_records(i).rec_end_date :=v_end_date -1;
            absence_records(i).days_or_hours :=l_hours_or_days;
	    absence_records(i).rec_duration := l_duration;
	    absence_records(i).confirmed_flag :=l_confirmed_flag;-- added

          END IF;
        END IF;
    l_idx := l_schedule(l_idx).NEXT_OBJECT_INDEX;
    end loop;

  -- for hours
else
 if g_debug then
   hr_utility.set_location(' indexloop hours .get_absence_data blk3',460);
 end if;


  l_day_start_time := '00:00';
      l_day_end_time := '23:59';
      WHILE l_idx IS NOT NULL
      LOOP
        IF l_schedule(l_idx).FREE_BUSY_TYPE IS NOT NULL THEN
          IF l_schedule(l_idx).FREE_BUSY_TYPE = 'FREE' THEN

     i:=i+1;

-- l_day_start_time := TO_CHAR(l_schedule(l_idx).START_DATE_TIME,'DD-MM-YYYY HH24:MI');
-- l_day_end_time := TO_CHAR(l_schedule(l_idx).END_DATE_TIME,'DD-MM-YYYY HH24:MI');

	l_day_start_time :=  fnd_date.date_to_canonical(l_schedule(l_idx).START_DATE_TIME);
	l_day_end_time :=  fnd_date.date_to_canonical(l_schedule(l_idx).END_DATE_TIME);



		absence_records(i).absence_type_id:=l_abs_type;
		absence_records(i).element_type_id:=l_ele_type;
		absence_records(i).abs_startdate:=l_day_start_time;
		absence_records(i).abs_enddate:=l_day_end_time;
		absence_records(i).absence_attendance_id:= l_absence_attendance_id;
		absence_records(i).PROGRAM_APPLICATION_ID := l_program_application_id ;
		absence_records(i).rec_start_date :=v_start_date;
		absence_records(i).rec_end_date :=v_end_date;
		absence_records(i).days_or_hours :=l_hours_or_days;
		absence_records(i).rec_duration := l_duration;
		absence_records(i).confirmed_flag :=l_confirmed_flag;-- added

          END IF;
        END IF;

        l_idx := l_schedule(l_idx).NEXT_OBJECT_INDEX;
     END LOOP;

  end if;
end if;



else
--  when cac is not in use then we will provide absences on day basis as we do not know the schedule of the person


if g_debug then
hr_utility.set_location('CAC not is use Blk3',490);
end if;

 l_rec_start_date :=l_start_date;
l_rec_end_date :=l_end_date;

/*
 while l_start_date <= l_end_date
         loop
	i:=i+1;


            absence_records(i).absence_type_id:=l_abs_type;
            absence_records(i).element_type_id:=l_ele_type;
            absence_records(i).abs_startdate:=FND_DATE.DATE_TO_CANONICAL(l_start_date); -- changed for 8844454
	    absence_records(i).abs_enddate:=FND_DATE.DATE_TO_CANONICAL(l_start_date); 	-- changed for 8844454
	    absence_records(i).absence_attendance_id:= l_absence_attendance_id;
            absence_records(i).PROGRAM_APPLICATION_ID :=l_program_application_id;
	    absence_records(i).rec_start_date :=l_rec_start_date;
	    absence_records(i).rec_end_date :=l_rec_end_date;
	    absence_records(i).days_or_hours :=l_hours_or_days;
	    absence_records(i).rec_duration := l_duration;

	l_start_date :=l_start_date+1;
	end loop;
*/


 IF l_time_start IS NULL THEN
    l_time_start := '00:00';
    l_time_start_new := '00:00';
  else
 l_time_start_new :=l_time_start;
 end if;

  IF l_time_end IS NULL THEN
     l_time_end_new := '23:59';
			l_time_end := '23:59';
	else
  l_time_end_new :=l_time_end;

  END IF;

-- when startdate is equal to enddate-------

if l_start_date = l_end_date then
	  i:=i+1;

 l_start_date_new := TO_DATE(TO_CHAR(l_start_date,'DD-MM-YYYY')||' '||l_time_start_new,'DD-MM-YYYY HH24:MI');
 l_end_date_new := TO_DATE(TO_CHAR(l_end_date,'DD-MM-YYYY')||' '||l_time_end_new,'DD-MM-YYYY HH24:MI');



            absence_records(i).absence_type_id:=l_abs_type;
            absence_records(i).element_type_id:=l_ele_type;
            absence_records(i).abs_startdate:=FND_DATE.DATE_TO_CANONICAL(l_start_date_new); -- changed for 8844454
	    absence_records(i).abs_enddate:=FND_DATE.DATE_TO_CANONICAL(l_end_date_new);	 -- changed for 8844454
	    absence_records(i).absence_attendance_id:= l_absence_attendance_id;
            absence_records(i).PROGRAM_APPLICATION_ID :=l_program_application_id;
	    absence_records(i).rec_start_date :=l_rec_start_date;
	    absence_records(i).rec_end_date :=l_rec_end_date;
	    absence_records(i).days_or_hours :=l_hours_or_days;
	    absence_records(i).rec_duration := l_duration;
	    absence_records(i).confirmed_flag :=l_confirmed_flag;-- added

else

--- CASE 1 for to first input the start date ---
	  i:=i+1;

l_time_end_new := '23:59';

 l_start_date_new := TO_DATE(TO_CHAR(l_start_date,'DD-MM-YYYY')||' '||l_time_start_new,'DD-MM-YYYY HH24:MI');
 l_end_date_new := TO_DATE(TO_CHAR(l_start_date,'DD-MM-YYYY')||' '||l_time_end_new,'DD-MM-YYYY HH24:MI');


            absence_records(i).absence_type_id:=l_abs_type;
            absence_records(i).element_type_id:=l_ele_type;
            absence_records(i).abs_startdate:=FND_DATE.DATE_TO_CANONICAL(l_start_date_new); -- changed for 8844454
	    absence_records(i).abs_enddate:=FND_DATE.DATE_TO_CANONICAL(l_end_date_new);  -- changed for 8844454
	    absence_records(i).absence_attendance_id:= l_absence_attendance_id;
            absence_records(i).PROGRAM_APPLICATION_ID :=l_program_application_id;
	    absence_records(i).rec_start_date :=l_rec_start_date;
	    absence_records(i).rec_end_date :=l_rec_end_date;
	    absence_records(i).days_or_hours :=l_hours_or_days;
	    absence_records(i).rec_duration := l_duration;
	    absence_records(i).confirmed_flag :=l_confirmed_flag;-- added

-- end of case 1----
-- case 2 is to insert from startdate + 1 to    enddate-1   ------

l_start_date:=l_start_date + 1;

 while l_start_date < l_end_date
         loop
	  i:=i+1;

l_time_start_new := '00:00';
l_time_end_new := '23:59';

 l_start_date_new := TO_DATE(TO_CHAR(l_start_date,'DD-MM-YYYY')||' '||l_time_start_new,'DD-MM-YYYY HH24:MI');
 l_end_date_new := TO_DATE(TO_CHAR(l_start_date,'DD-MM-YYYY')||' '||l_time_end_new,'DD-MM-YYYY HH24:MI');


            absence_records(i).absence_type_id:=l_abs_type;
            absence_records(i).element_type_id:=l_ele_type;
            absence_records(i).abs_startdate:=FND_DATE.DATE_TO_CANONICAL(l_start_date_new);    -- changed for 8844454
	    absence_records(i).abs_enddate:=FND_DATE.DATE_TO_CANONICAL(l_end_date_new);	 -- changed for 8844454
	    absence_records(i).absence_attendance_id:= l_absence_attendance_id;
            absence_records(i).PROGRAM_APPLICATION_ID :=l_program_application_id;
	    absence_records(i).rec_start_date :=l_rec_start_date;
	    absence_records(i).rec_end_date :=l_rec_end_date;
	    absence_records(i).days_or_hours :=l_hours_or_days;
	    absence_records(i).rec_duration := l_duration;
	    absence_records(i).confirmed_flag :=l_confirmed_flag;-- added

	l_start_date :=l_start_date+1;
	end loop;
-- end of case2 -----
-- case 3 to insert only enddate data---
i:=i+1;

l_time_start_new := '00:00';

 l_start_date_new := TO_DATE(TO_CHAR(l_start_date,'DD-MM-YYYY')||' '||l_time_start_new,'DD-MM-YYYY HH24:MI');
 l_end_date_new := TO_DATE(TO_CHAR(l_start_date,'DD-MM-YYYY')||' '||l_time_end,'DD-MM-YYYY HH24:MI');


            absence_records(i).absence_type_id:=l_abs_type;
            absence_records(i).element_type_id:=l_ele_type;
            absence_records(i).abs_startdate:=FND_DATE.DATE_TO_CANONICAL(l_start_date_new); 	-- changed for 8844454
	    absence_records(i).abs_enddate:=FND_DATE.DATE_TO_CANONICAL(l_end_date_new);	 -- changed for 8844454
	    absence_records(i).absence_attendance_id:= l_absence_attendance_id;
            absence_records(i).PROGRAM_APPLICATION_ID :=l_program_application_id;
	    absence_records(i).rec_start_date :=l_rec_start_date;
	    absence_records(i).rec_end_date :=l_rec_end_date;
	    absence_records(i).days_or_hours :=l_hours_or_days;
	    absence_records(i).rec_duration := l_duration;
	    absence_records(i).confirmed_flag :=l_confirmed_flag;-- added

-- END of case3 to insert only enddate ---


 end if;




end if; -- CAC Check block 3 closed

end loop;  -- csr_core_absences loop
close csr_core_absences;
if g_debug then
 hr_utility.set_location('End of Blk3 ',500);
end if;

end if; -- for Delete mode check

else

 if g_debug then
 hr_utility.set_location(' Profile HR OTL Integ setto OFF ',10);
 end if;

end if; -- OTL Integration Check

EXCEPTION
  WHEN e_bad_time_format THEN
    hr_utility.set_location('Leaving coz exception '||'.get_absence_data',30);
    hr_utility.set_location(SQLERRM,35);
    RAISE;
/*
  WHEN OTHERS THEN
    hr_utility.set_location('Leaving coz exception '||'.get_absence_data',40);
    hr_utility.set_location(SQLERRM,45);
    RAISE;
*/


end get_absence_data;
--
--
end hr_person_absence_api;

/
