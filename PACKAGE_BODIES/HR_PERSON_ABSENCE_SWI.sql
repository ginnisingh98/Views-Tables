--------------------------------------------------------
--  DDL for Package Body HR_PERSON_ABSENCE_SWI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PERSON_ABSENCE_SWI" As
/* $Header: hrabsswi.pkb 120.6.12010000.12 2009/10/14 09:44:25 ckondapi ship $ */
--
-- Package variables
--
g_package  varchar2(33) := 'hr_person_absence_swi.';

g_date_format  constant varchar2(10):='RRRR-MM-DD';
g_usr_day_time_fmt  varchar(40) := g_date_format|| ' HH24:MI:SS';

function getEndDate(p_transaction_id in number) return date
IS
c_proc  constant varchar2(30) := 'getEndDate';
lv_EndDate hr_api_transaction_steps.Information1%type;
begin

    if(p_transaction_id is not null) then
      begin
      select nvl(Information2,Information4)
      into lv_EndDate
      from hr_api_transaction_steps
      where transaction_id=p_transaction_id;

      exception
      when others then
        null;
        lv_EndDate:=null;
      end;
    end if;
     if(lv_EndDate is not null) then
       return fnd_date.canonical_to_date(lv_EndDate);
     else
       return null;
     end if;



exception
when others then
    hr_utility.set_location(g_package||c_proc|| 'errored : '||SQLERRM ||' '||to_char(SQLCODE), 30);
    Wf_Core.Context(g_package, c_proc, p_transaction_id);
   -- raise;
   return null;
end getEndDate;

function getStartDate(p_transaction_id in number) return date

IS
c_proc  constant varchar2(30) := 'getStartDate';
lv_startDate hr_api_transaction_steps.Information1%type;
begin

    hr_utility.set_location('Entering:'|| g_package||'.'||c_proc, 1);


    if(p_transaction_id is not null) then
      begin
      select nvl(Information1,Information3)
      into lv_startDate
      from hr_api_transaction_steps
      where transaction_id=p_transaction_id;

      exception
      when others then
        null;
        lv_startDate:=null;
      end;
    end if;
    if(lv_startDate is not null) then
      return fnd_date.canonical_to_date(lv_startDate);
    else
      return null;
    end if;

    hr_utility.set_location('Leaving:'|| g_package||'.'||c_proc, 30);


exception
when others then
    hr_utility.set_location(g_package||c_proc|| 'errored : '||SQLERRM ||' '||to_char(SQLCODE), 30);
    Wf_Core.Context(g_package, c_proc, p_transaction_id);
--    raise;
   return null;
end getStartDate;

function chk_overlap(
    p_person_id          IN NUMBER
   ,p_business_group_id  IN NUMBER
   ,p_date_start         IN DATE
   ,p_date_end           IN DATE
   ,p_time_start         IN VARCHAR2
   ,p_time_end           IN VARCHAR2
  ) return boolean
  IS
  --
  --
  l_proc              varchar2(250)  :=  g_package||'chk_overlap';
  l_exists            varchar2(250) ;
  l_abs_overlap_warning boolean;
  --
  --

  -- Fix 2706099
   CURSOR c_abs_overlap(p_person_id          IN NUMBER
                       ,p_business_grroup_id IN NUMBER
                       ,p_date_start         IN DATE
                       ,p_date_end           IN DATE
                       ,p_time_start         IN VARCHAR2
                       ,p_time_end           IN VARCHAR2
   ) IS
SELECT 1
    from hr_api_transactions hat
 where
hat.selected_person_id = p_person_id
and hat.TRANSACTION_IDENTIFIER = 'ABSENCES'
and hat.STATUS in ('Y','C')
and hat.transaction_id <> hr_transaction_swi.g_txn_ctx.transaction_id
and hr_person_absence_swi.getStartDate(hat.transaction_id)  is not null
and hr_person_absence_swi.getEndDate(hat.transaction_id)  is not null
and (
                      (
                      to_date (to_char(hr_person_absence_swi.getStartDate(hat.transaction_id), g_date_format) ||' ' ||
                      nvl((hr_xml_util.get_node_value(hat.transaction_id,'TimeProjectedStart','Transaction/TransCache/AM/TXN/EO/PerAbsenceAttendancesEORow',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)),'00:00'),g_usr_day_time_fmt)
                      BETWEEN to_date (to_char(p_date_start, g_date_format)||' ' || nvl(null,'00:00'),g_usr_day_time_fmt)
                      AND to_date(to_char(nvl(p_date_end,p_date_start), g_date_format) || ' '|| nvl(null,'00:00') , g_usr_day_time_fmt)
                       )
                       or
                      (
                      to_date (to_char(p_date_start, g_date_format) ||' ' || nvl(null,'00:00'),g_usr_day_time_fmt)
                       BETWEEN
                        to_date (to_char(hr_person_absence_swi.getStartDate(hat.transaction_id), g_date_format) ||' ' ||
                        nvl((hr_xml_util.get_node_value(hat.transaction_id,'TimeProjectedStart','Transaction/TransCache/AM/TXN/EO/PerAbsenceAttendancesEORow',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)),'00:00'),g_usr_day_time_fmt)
                      AND
                      to_date (to_char(hr_person_absence_swi.getEndDate(hat.transaction_id), g_date_format)  ||' ' ||
                      nvl((hr_xml_util.get_node_value(hat.transaction_id,'TimeProjectedEnd','Transaction/TransCache/AM/TXN/EO/PerAbsenceAttendancesEORow',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL)),'00:00'),g_usr_day_time_fmt)
                       )

          );
 --

BEGIN
  --

  hr_utility.set_location('Entering:'|| l_proc, 10);

  --
  --       check if this absence overlaps another absence for the same person.
  --


  open  c_abs_overlap(p_person_id,p_business_group_id,p_date_start,p_date_end,p_time_start,p_time_end);
  fetch c_abs_overlap into l_exists;

  if c_abs_overlap%found then

    --
    -- Set the warning message
    --
    l_abs_overlap_warning := TRUE;
    close c_abs_overlap;
    --
  else

    l_abs_overlap_warning := FALSE;

  end if;
  --
    return l_abs_overlap_warning;

  --
  EXCEPTION
  WHEN OTHERS THEN
  hr_utility.trace(' .chk_overlap: ' || SQLERRM );
  hr_utility.set_location('Leaving:'|| l_proc, 555);
    raise ;
 end chk_overlap;

function is_gb_leg_and_category_s(p_absence_attendance_type_id IN NUMBER ,
				    p_business_group_id IN NUMBER)
  return boolean is

   l_proc varchar2(200) := g_package || 'is_gb_leg_and_category_s';

   populate_sickness_dates boolean := false;
   l_absence_category per_absence_attendance_types.absence_category%type ;
   l_legislation_code varchar2(150);

   cursor get_category_code (p_absence_attendance_type_id number) is
   select absence_category
   from per_absence_attendance_types
   where absence_attendance_type_id = p_absence_attendance_type_id;

  begin
    hr_utility.set_location(' Entering:' || l_proc,5);

    open get_category_code(p_absence_attendance_type_id);
    fetch get_category_code into l_absence_category ;
    close get_category_code ;

    IF l_absence_category = 'S' THEN
       l_legislation_code := hr_api.return_legislation_code(p_business_group_id);
       IF l_legislation_code = 'GB' THEN
          hr_utility.set_location(l_proc,10);

    	  populate_sickness_dates := true;
       END IF;
    END IF;
    hr_utility.set_location(' Leaving:' || l_proc,15);

    return populate_sickness_dates;
  END is_gb_leg_and_category_s ;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_person_absence >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE create_person_absence
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_person_id                    in     number
  ,p_business_group_id            in     number
  ,p_absence_attendance_type_id   in     number
  ,p_abs_attendance_reason_id     in     number    default null
  ,p_comments                     in     long      default null
  ,p_date_notification            in     date      default null
  ,p_date_projected_start         in     date      default null
  ,p_time_projected_start         in     varchar2  default null
  ,p_date_projected_end           in     date      default null
  ,p_time_projected_end           in     varchar2  default null
  ,p_date_start                   in     date      default null
  ,p_time_start                   in     varchar2  default null
  ,p_date_end                     in     date      default null
  ,p_time_end                     in     varchar2  default null
  ,p_absence_days                 in out nocopy number
  ,p_absence_hours                in out nocopy number
  ,p_authorising_person_id        in     number    default null
  ,p_replacement_person_id        in     number    default null
  ,p_attribute_category           in     varchar2  default null
  ,p_attribute1                   in     varchar2  default null
  ,p_attribute2                   in     varchar2  default null
  ,p_attribute3                   in     varchar2  default null
  ,p_attribute4                   in     varchar2  default null
  ,p_attribute5                   in     varchar2  default null
  ,p_attribute6                   in     varchar2  default null
  ,p_attribute7                   in     varchar2  default null
  ,p_attribute8                   in     varchar2  default null
  ,p_attribute9                   in     varchar2  default null
  ,p_attribute10                  in     varchar2  default null
  ,p_attribute11                  in     varchar2  default null
  ,p_attribute12                  in     varchar2  default null
  ,p_attribute13                  in     varchar2  default null
  ,p_attribute14                  in     varchar2  default null
  ,p_attribute15                  in     varchar2  default null
  ,p_attribute16                  in     varchar2  default null
  ,p_attribute17                  in     varchar2  default null
  ,p_attribute18                  in     varchar2  default null
  ,p_attribute19                  in     varchar2  default null
  ,p_attribute20                  in     varchar2  default null
  ,p_period_of_incapacity_id      in     number    default null
  ,p_ssp1_issued                  in     varchar2  default null
  ,p_maternity_id                 in     number    default null
  ,p_sickness_start_date          in     date      default null
  ,p_sickness_end_date            in     date      default null
  ,p_pregnancy_related_illness    in     varchar2  default null
  ,p_reason_for_notification_dela in     varchar2  default null
  ,p_accept_late_notification_fla in     varchar2  default null
  ,p_linked_absence_id            in     number    default null
  ,p_batch_id                     in     number    default null
  ,p_create_element_entry         in     number    default null
  ,p_abs_information_category     in     varchar2  default null
  ,p_abs_information1             in     varchar2  default null
  ,p_abs_information2             in     varchar2  default null
  ,p_abs_information3             in     varchar2  default null
  ,p_abs_information4             in     varchar2  default null
  ,p_abs_information5             in     varchar2  default null
  ,p_abs_information6             in     varchar2  default null
  ,p_abs_information7             in     varchar2  default null
  ,p_abs_information8             in     varchar2  default null
  ,p_abs_information9             in     varchar2  default null
  ,p_abs_information10            in     varchar2  default null
  ,p_abs_information11            in     varchar2  default null
  ,p_abs_information12            in     varchar2  default null
  ,p_abs_information13            in     varchar2  default null
  ,p_abs_information14            in     varchar2  default null
  ,p_abs_information15            in     varchar2  default null
  ,p_abs_information16            in     varchar2  default null
  ,p_abs_information17            in     varchar2  default null
  ,p_abs_information18            in     varchar2  default null
  ,p_abs_information19            in     varchar2  default null
  ,p_abs_information20            in     varchar2  default null
  ,p_abs_information21            in     varchar2  default null
  ,p_abs_information22            in     varchar2  default null
  ,p_abs_information23            in     varchar2  default null
  ,p_abs_information24            in     varchar2  default null
  ,p_abs_information25            in     varchar2  default null
  ,p_abs_information26            in     varchar2  default null
  ,p_abs_information27            in     varchar2  default null
  ,p_abs_information28            in     varchar2  default null
  ,p_abs_information29            in     varchar2  default null
  ,p_abs_information30            in     varchar2  default null
  ,p_absence_case_id              in     number    default null
  ,p_absence_attendance_id        in out nocopy number
  ,p_object_version_number           out nocopy number
  ,p_occurrence                      out nocopy number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_create_element_entry          boolean;
  l_dur_dys_less_warning          boolean;
  l_dur_hrs_less_warning          boolean;
  l_exceeds_pto_entit_warning     boolean;
  l_exceeds_run_total_warning     boolean;
  l_abs_overlap_warning           boolean;
  l_abs_day_after_warning         boolean;
  l_dur_overwritten_warning       boolean;
  --
  -- Variables for IN/OUT parameters
  l_absence_days                  number;
  l_absence_hours                 number;

   l_populate_sickness_dates boolean := false;
   l_sickness_start_date date := p_sickness_start_date;
   l_sickness_end_date date := p_sickness_end_date;
   l_date_notification date := p_date_notification;
   l_abs_information_category varchar2(25) := p_abs_information_category;

   l_date_start date := p_date_start;
   l_date_end date := p_date_end;
   l_date_projected_start date := p_date_projected_start;
   l_date_projected_end date := p_date_projected_end;
   l_ssp1_issued varchar2(1) := p_ssp1_issued;
   l_pregnancy_related_illness varchar2(1) := p_pregnancy_related_illness;
   l_accept_late_notification_fla varchar2(1) := p_accept_late_notification_fla;
   l_error_text    varchar2(2000);
   l_sqlerrm       varchar2(2000);

  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'create_person_absence';
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint create_person_absence_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
--  Bug 6347488 fix starts

 if p_date_start is null then
  p_absence_days                  := null;
  p_absence_hours                 := null;
 end if;

-- Bug 6347488 fix ends

  l_absence_days                  := p_absence_days;
  l_absence_hours                 := p_absence_hours;

  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  l_create_element_entry :=
    hr_api.constant_to_boolean
      (p_constant_value => p_create_element_entry);
  --
  -- Register Surrogate ID or user key values
  --
  per_abs_ins.set_base_key_value
    (p_absence_attendance_id => p_absence_attendance_id
    );

    l_populate_sickness_dates := is_gb_leg_and_category_s(p_absence_attendance_type_id , p_business_group_id);

    IF l_populate_sickness_dates THEN
       IF p_date_start IS NULL AND p_date_projected_start IS NOT NULL THEN
	  l_date_start := l_date_projected_start;
	  l_date_projected_start := NULL;
	  l_date_end := l_date_projected_end;
	  l_date_projected_end := NULL;
       END IF;
       IF l_date_start > SYSDATE THEN
	 fnd_message.set_name('SSP', 'SSP_35036_INV_NOTIF_DATE');
         fnd_message.raise_error;
       END IF;
       l_sickness_start_date := l_date_start;
       l_sickness_end_date := l_date_end;
       l_date_notification := sysdate;
       l_abs_information_category := 'GB_PQP_OSP_OMP_PART_DAYS';
       l_ssp1_issued := 'N';
       l_pregnancy_related_illness := 'N';
       l_accept_late_notification_fla := 'N';
    END IF;
  --
  -- Call API
  --
  hr_person_absence_api.create_person_absence
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_person_id                    => p_person_id
    ,p_business_group_id            => p_business_group_id
    ,p_absence_attendance_type_id   => p_absence_attendance_type_id
    ,p_abs_attendance_reason_id     => p_abs_attendance_reason_id
    ,p_comments                     => p_comments
    ,p_date_notification            => l_date_notification
    ,p_date_projected_start         => l_date_projected_start
    ,p_time_projected_start         => p_time_projected_start
    ,p_date_projected_end           => l_date_projected_end
    ,p_time_projected_end           => p_time_projected_end
    ,p_date_start                   => l_date_start
    ,p_time_start                   => p_time_start
    ,p_date_end                     => l_date_end
    ,p_time_end                     => p_time_end
    ,p_absence_days                 => p_absence_days
    ,p_absence_hours                => p_absence_hours
    ,p_authorising_person_id        => p_authorising_person_id
    ,p_replacement_person_id        => p_replacement_person_id
    ,p_attribute_category           => p_attribute_category
    ,p_attribute1                   => p_attribute1
    ,p_attribute2                   => p_attribute2
    ,p_attribute3                   => p_attribute3
    ,p_attribute4                   => p_attribute4
    ,p_attribute5                   => p_attribute5
    ,p_attribute6                   => p_attribute6
    ,p_attribute7                   => p_attribute7
    ,p_attribute8                   => p_attribute8
    ,p_attribute9                   => p_attribute9
    ,p_attribute10                  => p_attribute10
    ,p_attribute11                  => p_attribute11
    ,p_attribute12                  => p_attribute12
    ,p_attribute13                  => p_attribute13
    ,p_attribute14                  => p_attribute14
    ,p_attribute15                  => p_attribute15
    ,p_attribute16                  => p_attribute16
    ,p_attribute17                  => p_attribute17
    ,p_attribute18                  => p_attribute18
    ,p_attribute19                  => p_attribute19
    ,p_attribute20                  => p_attribute20
    ,p_period_of_incapacity_id      => p_period_of_incapacity_id
    ,p_ssp1_issued                  => l_ssp1_issued
    ,p_maternity_id                 => p_maternity_id
    ,p_sickness_start_date          => l_sickness_start_date
    ,p_sickness_end_date            => l_sickness_end_date
    ,p_pregnancy_related_illness    => l_pregnancy_related_illness
    ,p_reason_for_notification_dela => p_reason_for_notification_dela
    ,p_accept_late_notification_fla => l_accept_late_notification_fla
    ,p_linked_absence_id            => p_linked_absence_id
    ,p_batch_id                     => p_batch_id
    ,p_create_element_entry         => l_create_element_entry
    ,p_abs_information_category     => l_abs_information_category
    ,p_abs_information1             => p_abs_information1
    ,p_abs_information2             => p_abs_information2
    ,p_abs_information3             => p_abs_information3
    ,p_abs_information4             => p_abs_information4
    ,p_abs_information5             => p_abs_information5
    ,p_abs_information6             => p_abs_information6
    ,p_abs_information7             => p_abs_information7
    ,p_abs_information8             => p_abs_information8
    ,p_abs_information9             => p_abs_information9
    ,p_abs_information10            => p_abs_information10
    ,p_abs_information11            => p_abs_information11
    ,p_abs_information12            => p_abs_information12
    ,p_abs_information13            => p_abs_information13
    ,p_abs_information14            => p_abs_information14
    ,p_abs_information15            => p_abs_information15
    ,p_abs_information16            => p_abs_information16
    ,p_abs_information17            => p_abs_information17
    ,p_abs_information18            => p_abs_information18
    ,p_abs_information19            => p_abs_information19
    ,p_abs_information20            => p_abs_information20
    ,p_abs_information21            => p_abs_information21
    ,p_abs_information22            => p_abs_information22
    ,p_abs_information23            => p_abs_information23
    ,p_abs_information24            => p_abs_information24
    ,p_abs_information25            => p_abs_information25
    ,p_abs_information26            => p_abs_information26
    ,p_abs_information27            => p_abs_information27
    ,p_abs_information28            => p_abs_information28
    ,p_abs_information29            => p_abs_information29
    ,p_abs_information30            => p_abs_information30
    ,p_absence_attendance_id        => p_absence_attendance_id
    ,p_absence_case_id              => p_absence_case_id
    ,p_object_version_number        => p_object_version_number
    ,p_occurrence                   => p_occurrence
    ,p_dur_dys_less_warning         => l_dur_dys_less_warning
    ,p_dur_hrs_less_warning         => l_dur_hrs_less_warning
    ,p_exceeds_pto_entit_warning    => l_exceeds_pto_entit_warning
    ,p_exceeds_run_total_warning    => l_exceeds_run_total_warning
    ,p_abs_overlap_warning          => l_abs_overlap_warning
    ,p_abs_day_after_warning        => l_abs_day_after_warning
    ,p_dur_overwritten_warning      => l_dur_overwritten_warning
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  if l_validate then
  if l_dur_dys_less_warning then
      hr_utility.set_message(800, 'HR_EMP_ABS_SHORT_DURATION');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;
  if l_dur_hrs_less_warning then
     hr_utility.set_message(800,'HR_ABS_HOUR_LESS_DURATION');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;
  if l_exceeds_pto_entit_warning then
     hr_utility.set_message(800, 'HR_LOA_EMP_NOT_ENTITLED');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;
  if l_exceeds_run_total_warning then
     hr_utility.set_message(800, 'HR_LOA_DET_RUNNING_ZERO');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;
  if l_abs_overlap_warning then
     hr_utility.set_message(800, 'HR_LOA_ABSENCE_OVERLAP');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;
  if l_abs_day_after_warning then
     hr_utility.set_message(800, 'HR_LOA_DET_ABS_DAY_AFTER');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;

 if (l_dur_dys_less_warning OR
       l_dur_hrs_less_warning OR
       l_exceeds_pto_entit_warning   OR
       l_exceeds_run_total_warning OR
       l_dur_dys_less_warning  OR
       l_abs_overlap_warning  OR
       l_abs_day_after_warning) then

     hr_utility.set_location(l_proc, 40);

   else
      l_abs_overlap_warning := chk_overlap(p_person_id,p_business_group_id,nvl(p_date_start,p_date_projected_start),nvl(p_date_end,p_date_projected_end),nvl(p_time_start,p_time_projected_start),nvl(p_time_end,p_time_projected_end));

      if l_abs_overlap_warning then
        hr_utility.set_message(800, 'HR_LOA_ABSENCE_OVERLAP');
        hr_multi_message.add(p_message_type => hr_multi_message.g_warning_msg);
        end if;
   end if;

  end if;
  --
  -- We don't raise overwritten warning from SSHR
  --
  --if l_dur_overwritten_warning then
  --   hr_utility.set_message(800, 'EDIT_HERE: MESSAGE_NAME ');
  --    hr_multi_message.add
  --      (p_message_type => hr_multi_message.g_warning_msg
  --      );
  --end if;  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  p_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to create_person_absence_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_absence_days                 := l_absence_days;
    p_absence_hours                := l_absence_hours;
    p_absence_attendance_id        := null;
    p_object_version_number        := null;
    p_occurrence                   := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to create_person_absence_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    l_sqlerrm := sqlerrm;
    l_error_text := hr_utility.get_message;
    if l_error_text is null then
      l_error_text := fnd_message.get;
    end if;

    if (((l_error_text is not null) OR (l_sqlerrm is not null)) and (p_validate = hr_api.g_false_num)) then
    	hr_utility.set_location(' Leaving:' || l_proc,45);
    	raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_absence_days                 := l_absence_days;
    p_absence_hours                := l_absence_hours;
    p_absence_attendance_id        := null;
    p_object_version_number        := null;
    p_occurrence                   := null;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end create_person_absence;
-- ----------------------------------------------------------------------------
-- |-------------------------< update_person_absence >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE update_person_absence
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_absence_attendance_id        in     number
  ,p_abs_attendance_reason_id     in     number    default hr_api.g_number
  ,p_comments                     in     long      default hr_api.g_varchar2
  ,p_date_notification            in     date      default hr_api.g_date
  ,p_date_projected_start         in     date      default hr_api.g_date
  ,p_time_projected_start         in     varchar2  default hr_api.g_varchar2
  ,p_date_projected_end           in     date      default hr_api.g_date
  ,p_time_projected_end           in     varchar2  default hr_api.g_varchar2
  ,p_date_start                   in     date      default hr_api.g_date
  ,p_time_start                   in     varchar2  default hr_api.g_varchar2
  ,p_date_end                     in     date      default hr_api.g_date
  ,p_time_end                     in     varchar2  default hr_api.g_varchar2
  ,p_absence_days                 in out nocopy number
  ,p_absence_hours                in out nocopy number
  ,p_authorising_person_id        in     number    default hr_api.g_number
  ,p_replacement_person_id        in     number    default hr_api.g_number
  ,p_attribute_category           in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute11                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2  default hr_api.g_varchar2
  ,p_period_of_incapacity_id      in     number    default hr_api.g_number
  ,p_ssp1_issued                  in     varchar2  default hr_api.g_varchar2
  ,p_maternity_id                 in     number    default hr_api.g_number
  ,p_sickness_start_date          in     date      default hr_api.g_date
  ,p_sickness_end_date            in     date      default hr_api.g_date
  ,p_pregnancy_related_illness    in     varchar2  default hr_api.g_varchar2
  ,p_reason_for_notification_dela in     varchar2  default hr_api.g_varchar2
  ,p_accept_late_notification_fla in     varchar2  default hr_api.g_varchar2
  ,p_linked_absence_id            in     number    default hr_api.g_number
  ,p_batch_id                     in     number    default hr_api.g_number
  ,p_abs_information_category     in     varchar2  default hr_api.g_varchar2
  ,p_abs_information1             in     varchar2  default hr_api.g_varchar2
  ,p_abs_information2             in     varchar2  default hr_api.g_varchar2
  ,p_abs_information3             in     varchar2  default hr_api.g_varchar2
  ,p_abs_information4             in     varchar2  default hr_api.g_varchar2
  ,p_abs_information5             in     varchar2  default hr_api.g_varchar2
  ,p_abs_information6             in     varchar2  default hr_api.g_varchar2
  ,p_abs_information7             in     varchar2  default hr_api.g_varchar2
  ,p_abs_information8             in     varchar2  default hr_api.g_varchar2
  ,p_abs_information9             in     varchar2  default hr_api.g_varchar2
  ,p_abs_information10            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information11            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information12            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information13            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information14            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information15            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information16            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information17            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information18            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information19            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information20            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information21            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information22            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information23            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information24            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information25            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information26            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information27            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information28            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information29            in     varchar2  default hr_api.g_varchar2
  ,p_abs_information30            in     varchar2  default hr_api.g_varchar2
  ,p_absence_case_id              in     number    default hr_api.g_number
  ,p_object_version_number        in out nocopy number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  l_dur_dys_less_warning          boolean;
  l_dur_hrs_less_warning          boolean;
  l_exceeds_pto_entit_warning     boolean;
  l_exceeds_run_total_warning     boolean;
  l_abs_overlap_warning           boolean;
  l_abs_day_after_warning         boolean;
  l_dur_overwritten_warning       boolean;
  l_del_element_entry_warning     boolean;
  --
  -- Variables for IN/OUT parameters
  l_absence_days                  number;
  l_absence_hours                 number;
  l_object_version_number         number;

--7382975 begin
   l_populate_sickness_dates boolean := false;
   l_sickness_start_date date := p_sickness_start_date;
   l_sickness_end_date date := p_sickness_end_date;
   l_absence_attendance_type_id per_absence_attendances.absence_attendance_type_id%type;
   l_business_group_id per_absence_attendances.business_group_id%type;

   Cursor c_is_gb_leg is
   select absence_attendance_type_id, business_group_id
   from per_absence_attendances
   where absence_attendance_id = p_absence_attendance_id;
--7382975 End

lv_PERSON_ID number;
lv_BUSINESS_GROUP_ID number;
lv_DATE_START Date;
lv_DATE_END Date;
lv_TIME_START VARCHAR2(200);
lv_TIME_END VARCHAR2(200);
lv_DATE_PROJECTED_START Date;
lv_DATE_PROJECTED_END Date;
lv_TIME_PROJECTED_START VARCHAR2(200);
lv_TIME_PROJECTED_END VARCHAR2(200);


  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'update_person_absence';
  l_error_text    varchar2(2000);
  l_sqlerrm       varchar2(2000);
  l_date_start    Date;

Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint update_person_absence_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --

 --  Bug 6347488,8671547 fix starts

if p_date_start is null or p_date_start = hr_api.g_date then

  select date_start into l_date_start from per_absence_attendances where
  absence_attendance_id = p_absence_attendance_id;

  if(l_date_start) is null then
    p_absence_days                  := null;
    p_absence_hours                 := null;
  end if;
end if;

-- Bug 6347488,8671547 fix ends

  -- Remember IN OUT parameter IN values
  --
  l_absence_days                  := p_absence_days;
  l_absence_hours                 := p_absence_hours;
  l_object_version_number         := p_object_version_number;
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  --
  -- Register Surrogate ID or user key values
  --
    --7382975 begin
    open c_is_gb_leg;
    fetch c_is_gb_leg into l_absence_attendance_type_id, l_business_group_id;

    IF c_is_gb_leg%FOUND THEN
	  l_populate_sickness_dates := is_gb_leg_and_category_s(l_absence_attendance_type_id , l_business_group_id);

     IF l_populate_sickness_dates THEN
	IF (p_date_start <> hr_api.g_date) THEN
	        IF p_date_start > SYSDATE THEN
  		  fnd_message.set_name('SSP', 'SSP_35036_INV_NOTIF_DATE');
	          fnd_message.raise_error;
	        END IF;
        	l_sickness_start_date := p_date_start;
 	END IF;
	IF (p_date_end <> hr_api.g_date) THEN
	        l_sickness_end_date   := p_date_end;
	END IF;
     END IF;
    END IF;

    close c_is_gb_leg;
  --7382975 end



  --
  -- Call API
  --
  hr_person_absence_api.update_person_absence
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_absence_attendance_id        => p_absence_attendance_id
    ,p_abs_attendance_reason_id     => p_abs_attendance_reason_id
    ,p_comments                     => p_comments
    ,p_date_notification            => p_date_notification
    ,p_date_projected_start         => p_date_projected_start
    ,p_time_projected_start         => p_time_projected_start
    ,p_date_projected_end           => p_date_projected_end
    ,p_time_projected_end           => p_time_projected_end
    ,p_date_start                   => p_date_start
    ,p_time_start                   => p_time_start
    ,p_date_end                     => p_date_end
    ,p_time_end                     => p_time_end
    ,p_absence_days                 => p_absence_days
    ,p_absence_hours                => p_absence_hours
    ,p_authorising_person_id        => p_authorising_person_id
    ,p_replacement_person_id        => p_replacement_person_id
    ,p_attribute_category           => p_attribute_category
    ,p_attribute1                   => p_attribute1
    ,p_attribute2                   => p_attribute2
    ,p_attribute3                   => p_attribute3
    ,p_attribute4                   => p_attribute4
    ,p_attribute5                   => p_attribute5
    ,p_attribute6                   => p_attribute6
    ,p_attribute7                   => p_attribute7
    ,p_attribute8                   => p_attribute8
    ,p_attribute9                   => p_attribute9
    ,p_attribute10                  => p_attribute10
    ,p_attribute11                  => p_attribute11
    ,p_attribute12                  => p_attribute12
    ,p_attribute13                  => p_attribute13
    ,p_attribute14                  => p_attribute14
    ,p_attribute15                  => p_attribute15
    ,p_attribute16                  => p_attribute16
    ,p_attribute17                  => p_attribute17
    ,p_attribute18                  => p_attribute18
    ,p_attribute19                  => p_attribute19
    ,p_attribute20                  => p_attribute20
    ,p_period_of_incapacity_id      => p_period_of_incapacity_id
    ,p_ssp1_issued                  => p_ssp1_issued
    ,p_maternity_id                 => p_maternity_id
    ,p_sickness_start_date          => l_sickness_start_date  --7382975
    ,p_sickness_end_date            => l_sickness_end_date    --7382975
    ,p_pregnancy_related_illness    => p_pregnancy_related_illness
    ,p_reason_for_notification_dela => p_reason_for_notification_dela
    ,p_accept_late_notification_fla => p_accept_late_notification_fla
    ,p_linked_absence_id            => p_linked_absence_id
    ,p_batch_id                     => p_batch_id
    ,p_abs_information_category     => p_abs_information_category
    ,p_abs_information1             => p_abs_information1
    ,p_abs_information2             => p_abs_information2
    ,p_abs_information3             => p_abs_information3
    ,p_abs_information4             => p_abs_information4
    ,p_abs_information5             => p_abs_information5
    ,p_abs_information6             => p_abs_information6
    ,p_abs_information7             => p_abs_information7
    ,p_abs_information8             => p_abs_information8
    ,p_abs_information9             => p_abs_information9
    ,p_abs_information10            => p_abs_information10
    ,p_abs_information11            => p_abs_information11
    ,p_abs_information12            => p_abs_information12
    ,p_abs_information13            => p_abs_information13
    ,p_abs_information14            => p_abs_information14
    ,p_abs_information15            => p_abs_information15
    ,p_abs_information16            => p_abs_information16
    ,p_abs_information17            => p_abs_information17
    ,p_abs_information18            => p_abs_information18
    ,p_abs_information19            => p_abs_information19
    ,p_abs_information20            => p_abs_information20
    ,p_abs_information21            => p_abs_information21
    ,p_abs_information22            => p_abs_information22
    ,p_abs_information23            => p_abs_information23
    ,p_abs_information24            => p_abs_information24
    ,p_abs_information25            => p_abs_information25
    ,p_abs_information26            => p_abs_information26
    ,p_abs_information27            => p_abs_information27
    ,p_abs_information28            => p_abs_information28
    ,p_abs_information29            => p_abs_information29
    ,p_abs_information30            => p_abs_information30
    ,p_absence_case_id              => p_absence_case_id
    ,p_object_version_number        => p_object_version_number
    ,p_dur_dys_less_warning         => l_dur_dys_less_warning
    ,p_dur_hrs_less_warning         => l_dur_hrs_less_warning
    ,p_exceeds_pto_entit_warning    => l_exceeds_pto_entit_warning
    ,p_exceeds_run_total_warning    => l_exceeds_run_total_warning
    ,p_abs_overlap_warning          => l_abs_overlap_warning
    ,p_abs_day_after_warning        => l_abs_day_after_warning
    ,p_dur_overwritten_warning      => l_dur_overwritten_warning
    ,p_del_element_entry_warning    => l_del_element_entry_warning
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  if l_validate then
  if l_dur_dys_less_warning then
     hr_utility.set_message(800, 'HR_EMP_ABS_SHORT_DURATION');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;
  if l_dur_hrs_less_warning then
     hr_utility.set_message(800, 'HR_ABS_HOUR_LESS_DURATION');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;
  if l_exceeds_pto_entit_warning then
     hr_utility.set_message(800, 'HR_LOA_EMP_NOT_ENTITLED');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;
  if l_exceeds_run_total_warning then
     hr_utility.set_message(800, 'HR_LOA_DET_RUNNING_ZERO');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;
  if l_abs_overlap_warning then
     hr_utility.set_message(800, 'HR_LOA_ABSENCE_OVERLAP');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;
  if l_abs_day_after_warning then
     hr_utility.set_message(800, 'HR_LOA_DET_ABS_DAY_AFTER');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;
  --
  -- We don't raise overwritten warning from SSHR
  --
  --if l_dur_overwritten_warning then
  --   hr_utility.set_message(800, 'EDIT_HERE: MESSAGE_NAME ');
  --    hr_multi_message.add
  --      (p_message_type => hr_multi_message.g_warning_msg
  --      );
  --end if;  --
  if l_del_element_entry_warning then
     fnd_message.set_name('EDIT HERE: APP_CODE', 'EDIT_HERE: MESSAGE_NAME ');
      hr_multi_message.add
        (p_message_type => hr_multi_message.g_warning_msg
        );
  end if;
     if (l_dur_dys_less_warning OR
       l_dur_hrs_less_warning OR
       l_exceeds_pto_entit_warning   OR
       l_exceeds_run_total_warning OR
       l_abs_overlap_warning  OR
       l_abs_day_after_warning  OR
       l_del_element_entry_warning) then

     hr_utility.set_location(l_proc, 40);

   else

begin

select PERSON_ID,BUSINESS_GROUP_ID,DATE_START,DATE_END,TIME_START,TIME_END,DATE_PROJECTED_START,DATE_PROJECTED_END,TIME_PROJECTED_START,TIME_PROJECTED_END
into
lv_PERSON_ID,lv_BUSINESS_GROUP_ID,lv_DATE_START,lv_DATE_END,lv_TIME_START,lv_TIME_END,lv_DATE_PROJECTED_START,lv_DATE_PROJECTED_END,lv_TIME_PROJECTED_START,lv_TIME_PROJECTED_END
from per_absence_attendances
where ABSENCE_ATTENDANCE_ID = p_absence_attendance_id;
end;

      l_abs_overlap_warning := chk_overlap(lv_PERSON_ID,lv_BUSINESS_GROUP_ID,nvl(nvl(p_date_start,p_date_projected_start),nvl(lv_DATE_START,lv_DATE_PROJECTED_START)),nvl(nvl(p_date_end,p_date_projected_end),
      nvl(lv_DATE_END,lv_DATE_PROJECTED_END)),nvl(nvl(p_time_start,p_time_projected_start),nvl(lv_TIME_START,lv_TIME_PROJECTED_START)),nvl(nvl(p_time_end,p_time_projected_end),nvl(lv_TIME_END,lv_TIME_PROJECTED_END)));



      if l_abs_overlap_warning then
        hr_utility.set_message(800, 'HR_LOA_ABSENCE_OVERLAP');
        hr_multi_message.add(p_message_type => hr_multi_message.g_warning_msg);
        end if;
   end if;

  end if;  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  p_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to update_person_absence_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_absence_days                 := l_absence_days;
    p_absence_hours                := l_absence_hours;
    p_object_version_number        := l_object_version_number;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to update_person_absence_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    l_sqlerrm := sqlerrm;
    l_error_text := hr_utility.get_message;
    if l_error_text is null then
      l_error_text := fnd_message.get;
    end if;

    if (((l_error_text is not null) OR (l_sqlerrm is not null)) and (p_validate = hr_api.g_false_num)) then
    	hr_utility.set_location(' Leaving:' || l_proc,45);
    	raise;
    end if;

    --
    -- Reset IN OUT and set OUT parameters
    --
    p_absence_days                 := l_absence_days;
    p_absence_hours                := l_absence_hours;
    p_object_version_number        := l_object_version_number;
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end update_person_absence;
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_person_absence >------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_person_absence
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_absence_attendance_id        in     number
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  ) is
  --
  -- Variables for API Boolean parameters
  l_validate                      boolean;
  --
  -- Variables for IN/OUT parameters
  --
  -- Other variables
  l_proc    varchar2(72) := g_package ||'delete_person_absence';
Begin


  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint delete_person_absence_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;
  --
  -- Remember IN OUT parameter IN values
  --
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  --
  -- Register Surrogate ID or user key values
  --
  --
  -- Call API
  --
  hr_person_absence_api.delete_person_absence
    (p_validate                     => l_validate
    ,p_absence_attendance_id        => p_absence_attendance_id
    ,p_object_version_number        => p_object_version_number
    );
  --
  -- Convert API warning boolean parameter values to specific
  -- messages and add them to Multiple Message List
  --
  --
  -- Convert API non-warning boolean parameter values
  --
  --
  -- Derive the API return status value based on whether
  -- messages of any type exist in the Multiple Message List.
  -- Also disable Multiple Message Detection.
  --
  p_return_status := hr_multi_message.get_return_status_disable;
  hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
  when hr_multi_message.error_message_exist then
    --
    -- Catch the Multiple Message List exception which
    -- indicates API processing has been aborted because
    -- at least one message exists in the list.
    --
    rollback to delete_person_absence_swi;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc, 30);
  when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to delete_person_absence_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    --
    p_return_status := hr_multi_message.get_return_status_disable;
    hr_utility.set_location(' Leaving:' || l_proc,50);
end delete_person_absence;


-- ----------------------------------------------------------------------------
-- |--------------------------< update_attachment >----------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_attachment
          (p_entity_name        in varchar2 default null
          ,p_pk1_value          in varchar2 default null
          ,p_rowid              in varchar2 ) is



  l_proc    varchar2(72) := g_package ||'update_attachment';
  l_rowid                  varchar2(50);
  l_language               varchar2(30) ;
  data_error               exception;
  --

  cursor csr_get_attached_doc  is
    select *
    from   fnd_attached_documents
    where  rowid = p_rowid;
  --
  cursor csr_get_doc(csr_p_document_id in number)  is
    select *
    from   fnd_documents
    where  document_id = csr_p_document_id;
  --
  cursor csr_get_doc_tl  (csr_p_lang in varchar2
                         ,csr_p_document_id in number) is
    select *
    from   fnd_documents_tl
    where  document_id = csr_p_document_id
    and    language = csr_p_lang;
  --
  l_attached_doc_pre_upd   csr_get_attached_doc%rowtype;
  l_doc_pre_upd            csr_get_doc%rowtype;
  l_doc_tl_pre_upd         csr_get_doc_tl%rowtype;
  --
  --
  Begin
    hr_utility.set_location(' Entering:' || l_proc,10);
    --
    -- Get language
    select userenv('LANG') into l_language from dual;
    --
    -- Get the before update nullable fields which are not used by the
    -- Web page to ensure the values are propagated.
     Open csr_get_attached_doc;
     fetch csr_get_attached_doc into l_attached_doc_pre_upd;
     IF csr_get_attached_doc%NOTFOUND THEN
        close csr_get_attached_doc;
        raise data_error;
     END IF;

     Open csr_get_doc(l_attached_doc_pre_upd.document_id);
     fetch csr_get_doc into l_doc_pre_upd;
     IF csr_get_doc%NOTFOUND then
        close csr_get_doc;
        raise data_error;
     END IF;

     Open csr_get_doc_tl (csr_p_lang => l_language
                      ,csr_p_document_id => l_attached_doc_pre_upd.document_id);
     fetch csr_get_doc_tl into l_doc_tl_pre_upd;
     IF csr_get_doc_tl%NOTFOUND then
        close csr_get_doc_tl;
        raise data_error;
     END IF;

     hr_utility.set_location(' before  fnd_attached_documents_pkg.lock_row :' || l_proc,20);
     -- Now, lock the rows.
     fnd_attached_documents_pkg.lock_row
            (x_rowid                      => p_rowid
            ,x_attached_document_id       =>
                      l_attached_doc_pre_upd.attached_document_id
            ,x_document_id                => l_doc_pre_upd.document_id
            ,x_seq_num                    => l_attached_doc_pre_upd.seq_num
            ,x_entity_name                => l_attached_doc_pre_upd.entity_name
            ,x_column1                    => l_attached_doc_pre_upd.column1
            ,x_pk1_value                  => l_attached_doc_pre_upd.pk1_value
            ,x_pk2_value                  => l_attached_doc_pre_upd.pk2_value
            ,x_pk3_value                  => l_attached_doc_pre_upd.pk3_value
            ,x_pk4_value                  => l_attached_doc_pre_upd.pk4_value
            ,x_pk5_value                  => l_attached_doc_pre_upd.pk5_value
            ,x_automatically_added_flag   =>
                    l_attached_doc_pre_upd.automatically_added_flag
            ,x_attribute_category         =>
                    l_attached_doc_pre_upd.attribute_category
            ,x_attribute1                 => l_attached_doc_pre_upd.attribute1
            ,x_attribute2                 => l_attached_doc_pre_upd.attribute2
            ,x_attribute3                 => l_attached_doc_pre_upd.attribute3
            ,x_attribute4                 => l_attached_doc_pre_upd.attribute4
            ,x_attribute5                 => l_attached_doc_pre_upd.attribute5
            ,x_attribute6                 => l_attached_doc_pre_upd.attribute6
            ,x_attribute7                 => l_attached_doc_pre_upd.attribute7
            ,x_attribute8                 => l_attached_doc_pre_upd.attribute8
            ,x_attribute9                 => l_attached_doc_pre_upd.attribute9
            ,x_attribute10                => l_attached_doc_pre_upd.attribute10
            ,x_attribute11                => l_attached_doc_pre_upd.attribute11
            ,x_attribute12                => l_attached_doc_pre_upd.attribute12
            ,x_attribute13                => l_attached_doc_pre_upd.attribute13
            ,x_attribute14                => l_attached_doc_pre_upd.attribute14
            ,x_attribute15                => l_attached_doc_pre_upd.attribute15
            ,x_datatype_id                => l_doc_pre_upd.datatype_id
            ,x_category_id                => l_doc_pre_upd.category_id
            ,x_security_type              => l_doc_pre_upd.security_type
            ,x_security_id                => l_doc_pre_upd.security_id
            ,x_publish_flag               => l_doc_pre_upd.publish_flag
            ,x_image_type                 => l_doc_pre_upd.image_type
            ,x_storage_type               => l_doc_pre_upd.storage_type
            ,x_usage_type                 => l_doc_pre_upd.usage_type
            ,x_start_date_active          => l_doc_pre_upd.start_date_active
            ,x_end_date_active            => l_doc_pre_upd.end_date_active
            ,x_language                   => l_doc_tl_pre_upd.language
            ,x_description                => l_doc_tl_pre_upd.description
            ,x_file_name                  => l_doc_pre_upd.file_name
            ,x_media_id                   => l_doc_pre_upd.media_id
            ,x_doc_attribute_category     =>
                          l_doc_tl_pre_upd.doc_attribute_category
            ,x_doc_attribute1             => l_doc_tl_pre_upd.doc_attribute1
            ,x_doc_attribute2             => l_doc_tl_pre_upd.doc_attribute2
            ,x_doc_attribute3             => l_doc_tl_pre_upd.doc_attribute3
            ,x_doc_attribute4             => l_doc_tl_pre_upd.doc_attribute4
            ,x_doc_attribute5             => l_doc_tl_pre_upd.doc_attribute5
            ,x_doc_attribute6             => l_doc_tl_pre_upd.doc_attribute6
            ,x_doc_attribute7             => l_doc_tl_pre_upd.doc_attribute7
            ,x_doc_attribute8             => l_doc_tl_pre_upd.doc_attribute8
            ,x_doc_attribute9             => l_doc_tl_pre_upd.doc_attribute9
            ,x_doc_attribute10            => l_doc_tl_pre_upd.doc_attribute10
            ,x_doc_attribute11            => l_doc_tl_pre_upd.doc_attribute11
            ,x_doc_attribute12            => l_doc_tl_pre_upd.doc_attribute12
            ,x_doc_attribute13            => l_doc_tl_pre_upd.doc_attribute13
            ,x_doc_attribute14            => l_doc_tl_pre_upd.doc_attribute14
            ,x_doc_attribute15            => l_doc_tl_pre_upd.doc_attribute15
            ,x_url                        => l_doc_pre_upd.url
            ,x_title                      => l_doc_tl_pre_upd.title
            );


  -- Update document to fnd_attached_documents, fnd_documents,
  -- fnd_documents_tl
  --
        hr_utility.set_location(' before fnd_attached_documents_pkg.update_row :' || l_proc,30);
            fnd_attached_documents_pkg.update_row
            (x_rowid                      => p_rowid
            ,x_attached_document_id       =>
                        l_attached_doc_pre_upd.attached_document_id
            ,x_document_id                => l_doc_pre_upd.document_id
            ,x_last_update_date           => trunc(sysdate)
            ,x_last_updated_by            => l_attached_doc_pre_upd.last_updated_by
            ,x_seq_num                    => l_attached_doc_pre_upd.seq_num
            ,x_entity_name                => p_entity_name
            ,x_column1                    => l_attached_doc_pre_upd.column1
            ,x_pk1_value                  => p_pk1_value
            ,x_pk2_value                  => l_attached_doc_pre_upd.pk2_value
            ,x_pk3_value                  => l_attached_doc_pre_upd.pk3_value
            ,x_pk4_value                  => l_attached_doc_pre_upd.pk4_value
            ,x_pk5_value                  => l_attached_doc_pre_upd.pk5_value
            ,x_automatically_added_flag   =>
                      l_attached_doc_pre_upd.automatically_added_flag
            ,x_attribute_category         =>
                      l_attached_doc_pre_upd.attribute_category
            ,x_attribute1                 => l_attached_doc_pre_upd.attribute1
            ,x_attribute2                 => l_attached_doc_pre_upd.attribute2
            ,x_attribute3                 => l_attached_doc_pre_upd.attribute3
            ,x_attribute4                 => l_attached_doc_pre_upd.attribute4
            ,x_attribute5                 => l_attached_doc_pre_upd.attribute5
            ,x_attribute6                 => l_attached_doc_pre_upd.attribute6
            ,x_attribute7                 => l_attached_doc_pre_upd.attribute7
            ,x_attribute8                 => l_attached_doc_pre_upd.attribute8
            ,x_attribute9                 => l_attached_doc_pre_upd.attribute9
            ,x_attribute10                => l_attached_doc_pre_upd.attribute10
            ,x_attribute11                => l_attached_doc_pre_upd.attribute11
            ,x_attribute12                => l_attached_doc_pre_upd.attribute12
            ,x_attribute13                => l_attached_doc_pre_upd.attribute13
            ,x_attribute14                => l_attached_doc_pre_upd.attribute14
            ,x_attribute15                => l_attached_doc_pre_upd.attribute15
            /*   columns necessary for creating a document on the fly  */
            ,x_datatype_id                => l_doc_pre_upd.datatype_id
            ,x_category_id                => l_doc_pre_upd.category_id
            ,x_security_type              => l_doc_pre_upd.security_type
            ,x_security_id                => l_doc_pre_upd.security_id
            ,x_publish_flag               => l_doc_pre_upd.publish_flag
            ,x_image_type                 => l_doc_pre_upd.image_type
            ,x_storage_type               => l_doc_pre_upd.storage_type
            ,x_usage_type                 => l_doc_pre_upd.usage_type
           ,x_start_date_active          => trunc(sysdate)
            ,x_end_date_active            => l_doc_pre_upd.end_date_active
            ,x_language                   => l_language
            ,x_description                => l_doc_tl_pre_upd.description
            ,x_file_name                  => l_doc_pre_upd.file_name
            ,x_media_id                   => l_doc_pre_upd.media_id
            ,x_doc_attribute_category     =>
                      l_doc_tl_pre_upd.doc_attribute_category
            ,x_doc_attribute1             => l_doc_tl_pre_upd.doc_attribute1
            ,x_doc_attribute2             => l_doc_tl_pre_upd.doc_attribute2
            ,x_doc_attribute3             => l_doc_tl_pre_upd.doc_attribute3
            ,x_doc_attribute4             => l_doc_tl_pre_upd.doc_attribute4
            ,x_doc_attribute5             => l_doc_tl_pre_upd.doc_attribute5
            ,x_doc_attribute6             => l_doc_tl_pre_upd.doc_attribute6
            ,x_doc_attribute7             => l_doc_tl_pre_upd.doc_attribute7
            ,x_doc_attribute8             => l_doc_tl_pre_upd.doc_attribute8
            ,x_doc_attribute9             => l_doc_tl_pre_upd.doc_attribute9
            ,x_doc_attribute10            => l_doc_tl_pre_upd.doc_attribute10
            ,x_doc_attribute11            => l_doc_tl_pre_upd.doc_attribute11
            ,x_doc_attribute12            => l_doc_tl_pre_upd.doc_attribute12
            ,x_doc_attribute13            => l_doc_tl_pre_upd.doc_attribute13
            ,x_doc_attribute14            => l_doc_tl_pre_upd.doc_attribute14
            ,x_doc_attribute15            => l_doc_tl_pre_upd.doc_attribute15
            ,x_url                        => l_doc_pre_upd.url
            ,x_title                      => l_doc_tl_pre_upd.title
            );

  hr_utility.set_location(' after fnd_attached_documents_pkg.update_row :' || l_proc,40);
  hr_utility.set_location(' Leaving:' || l_proc,50);

  EXCEPTION
    when others then
      hr_utility.set_location(' Error in :' || l_proc,60);
         raise;
  --
  End update_attachment;


procedure merge_attachments(p_transaction_id in     number,
                           p_absence_attendance_id in     number,
                           p_return_status in out nocopy varchar2)
 is
-- Other variables
  l_proc    varchar2(72) := g_package ||'merge_attachments';
  l_rowid                  varchar2(50);
  lv_pk1_value varchar2(72) := p_absence_attendance_id||'_'||p_transaction_id ;
  data_error               exception;
  lv_entity_name constant varchar2(30) := 'PER_ABSENCE_ATTENDANCES';

  cursor csr_get_attached_doc is
    select *
    from   fnd_attached_documents
    where  entity_name=lv_entity_name
     and   pk1_value=lv_pk1_value;

  CURSOR C (X_attached_document_id in number) IS
    SELECT rowid
    FROM fnd_attached_documents
    WHERE attached_document_id = X_attached_document_id;
  --
Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint attachments_person_absence_swi;
  --
  -- Initialise Multiple Message Detection
  --
  hr_multi_message.enable_message_list;

  for attached_documents_rec in csr_get_attached_doc loop
     OPEN C (attached_documents_rec.attached_document_id);
      FETCH C INTO l_rowid;
      if (C%NOTFOUND) then
      CLOSE C;
       RAISE NO_DATA_FOUND;
     end if;
    CLOSE C;
    -- call the update_attachement for each attached doc
        update_attachment
          (p_entity_name=>lv_entity_name
          ,p_pk1_value=> p_absence_attendance_id
          ,p_rowid=>l_rowid);

  end loop;

 p_return_status := hr_multi_message.get_return_status_disable;

 hr_utility.set_location(' Leaving:' || l_proc,20);
  --
exception
when others then
    --
    -- When Multiple Message Detection is enabled catch
    -- any Application specific or other unexpected
    -- exceptions.  Adding appropriate details to the
    -- Multiple Message List.  Otherwise re-raise the
    -- error.
    --
    rollback to attachments_person_absence_swi;
    if hr_multi_message.unexpected_error_add(l_proc) then
       hr_utility.set_location(' Leaving:' || l_proc,40);
       raise;
    end if;
    --
    -- Reset IN OUT and set OUT parameters
    p_return_status := hr_multi_message.get_return_status_disable;

    hr_utility.set_location(' Leaving:' || l_proc,50);
end merge_attachments;


-- ----------------------------------------------------------------------------
-- |---------------------------< process_api >--------------------------------|
-- ----------------------------------------------------------------------------

Procedure process_api
( p_document            in         CLOB
 ,p_return_status       out nocopy VARCHAR2
 ,p_validate            in         number    default hr_api.g_false_num
 ,p_effective_date      in         date      default null
)
IS
   l_postState VARCHAR2(2);
   l_return_status VARCHAR2(1);
   l_commitElement xmldom.DOMElement;
   l_object_version_number number;
   l_parser xmlparser.Parser;
   l_CommitNode xmldom.DOMNode;
   l_proc    varchar2(72) := g_package || 'process_api';

    l_absence_days number;
    l_absence_hours number;
	lv_absence_days number;
    lv_absence_hours number;
    l_absence_attendance_id number;
    l_occurrence number;
    lv_action varchar2(30);

   Cursor c_get_dur(p_absence_attendance_id number) is
   select absence_days, absence_hours
   from per_absence_attendances
   where absence_attendance_id = p_absence_attendance_id;


BEGIN

   hr_utility.set_location(' Entering:' || l_proc,10);
   hr_utility.set_location(' CLOB --> xmldom.DOMNode:' || l_proc,15);
   savepoint absence_process_api;
   l_parser      := xmlparser.newParser;
   xmlparser.ParseCLOB(l_parser,p_document);
   l_CommitNode  := xmldom.makeNode(xmldom.getDocumentElement(xmlparser.getDocument(l_parser)));

   hr_utility.set_location('Extracting the PostState:' || l_proc,20);

   l_commitElement := xmldom.makeElement(l_CommitNode);
   l_postState := xmldom.getAttribute(l_commitElement, 'PS');
   l_object_version_number := hr_transaction_swi.getNumberValue(l_CommitNode,'ObjectVersionNumber');

   -- overiding for poststate
   -- CancelMode
   if(l_postState = '2') then
     -- Check if the transaction is for delete
     begin
      lv_action:= hr_xml_util.get_node_value(hr_transaction_swi.g_txn_ctx.TRANSACTION_ID,'AbsenceAction','Transaction/TransCtx/CNode',
      NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
     end;
     if(lv_action='CancelMode') then
        -- reset the poststate
        l_postState:= '3';
     end if;
   end if;


   if l_postState = '0' then

    l_absence_days := hr_transaction_swi.getNumberValue(l_CommitNode,'AbsenceDays',null);
    l_absence_hours := hr_transaction_swi.getNumberValue(l_CommitNode,'AbsenceHours',null);
    l_absence_attendance_id := hr_transaction_swi.getNumberValue(l_CommitNode,'AbsenceAttendanceId',null);
    l_occurrence := hr_transaction_swi.getNumberValue(l_CommitNode,'Occurrence',null);

    create_person_absence
    (p_validate                     => p_validate
    ,p_effective_date               =>  p_effective_date
    ,p_person_id                    =>  hr_transaction_swi.getNumberValue(l_CommitNode,'PersonId',null)
    ,p_business_group_id            => hr_transaction_swi.getNumberValue(l_CommitNode,'BusinessGroupId',null)
    ,p_absence_attendance_type_id   => hr_transaction_swi.getNumberValue(l_CommitNode,'AbsenceAttendanceTypeId',null)
    ,p_abs_attendance_reason_id     =>  hr_transaction_swi.getNumberValue(l_CommitNode,'AbsAttendanceReasonId',null)
    ,p_comments                     => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Comments',null)
    ,p_date_notification            => hr_transaction_swi.getDateValue(l_CommitNode,'DateNotification',null)
    ,p_date_projected_start         => hr_transaction_swi.getDateValue(l_CommitNode,'DateProjectedStart',null)
    ,p_time_projected_start         => hr_transaction_swi.getVarchar2Value(l_CommitNode,'TimeProjectedStart',null)
    ,p_date_projected_end           => hr_transaction_swi.getDateValue(l_CommitNode,'DateProjectedEnd',null)
    ,p_time_projected_end           => hr_transaction_swi.getVarchar2Value(l_CommitNode,'TimeProjectedEnd',null)
    ,p_date_start                   => hr_transaction_swi.getDateValue(l_CommitNode,'DateStart',null)
    ,p_time_start                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'TimeStart',null)
    ,p_date_end                     => hr_transaction_swi.getDateValue(l_CommitNode,'DateEnd',null)
    ,p_time_end                     => hr_transaction_swi.getVarchar2Value(l_CommitNode,'TimeEnd',null)
    ,p_absence_days                 => l_absence_days
    ,p_absence_hours                => l_absence_hours
    ,p_authorising_person_id        => hr_transaction_swi.getNumberValue(l_CommitNode,'AuthorisingPersonId',null)
    ,p_replacement_person_id        => hr_transaction_swi.getNumberValue(l_CommitNode,'ReplacementPersonId',null)
    ,p_attribute_category           => hr_transaction_swi.getVarchar2Value(l_CommitNode,'AttributeCategory',null)
    ,p_attribute1                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute1',null)
    ,p_attribute2                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute2',null)
    ,p_attribute3                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute3',null)
    ,p_attribute4                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute4',null)
    ,p_attribute5                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute5',null)
    ,p_attribute6                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute6',null)
    ,p_attribute7                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute7',null)
    ,p_attribute8                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute8',null)
    ,p_attribute9                   => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute9',null)
    ,p_attribute10                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute10',null)
    ,p_attribute11                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute11',null)
    ,p_attribute12                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute12',null)
    ,p_attribute13                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute13',null)
    ,p_attribute14                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute14',null)
    ,p_attribute15                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute15',null)
    ,p_attribute16                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute16',null)
    ,p_attribute17                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute17',null)
    ,p_attribute18                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute18',null)
    ,p_attribute19                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute19',null)
    ,p_attribute20                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute20',null)
    ,p_period_of_incapacity_id      => hr_transaction_swi.getNumberValue(l_CommitNode,'PeriodOfIncapacityId',null)
    ,p_ssp1_issued                  => hr_transaction_swi.getVarchar2Value(l_CommitNode,'Ssp1Issued',null)
    ,p_maternity_id                 => hr_transaction_swi.getNumberValue(l_CommitNode,'MaternityId',null)
    ,p_sickness_start_date          => hr_transaction_swi.getDateValue(l_CommitNode,'SicknessStartDate',null)
    ,p_sickness_end_date            => hr_transaction_swi.getDateValue(l_CommitNode,'SicknessEndDate',null)
    ,p_pregnancy_related_illness    => hr_transaction_swi.getVarchar2Value(l_CommitNode,'PregnancyRelatedIllness',null)
    ,p_reason_for_notification_dela => hr_transaction_swi.getVarchar2Value(l_CommitNode,'ReasonForNotificationDela',null)
    ,p_accept_late_notification_fla => hr_transaction_swi.getVarchar2Value(l_CommitNode,'AcceptLateNotificationFla',null)
    ,p_linked_absence_id            => hr_transaction_swi.getNumberValue(l_CommitNode,'LinkedAbsenceId',null)
    ,p_batch_id                     => hr_transaction_swi.getNumberValue(l_CommitNode,'BatchId',null)
    ,p_create_element_entry         => hr_transaction_swi.getNumberValue(l_CommitNode,'CreateElementEntry',null)
    ,p_abs_information_category     => hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformationCategory',null)
    ,p_abs_information1             => hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation1',null)
    ,p_abs_information2             => hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation2',null)
    ,p_abs_information3             => hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation3',null)
    ,p_abs_information4             => hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation4',null)
    ,p_abs_information5             => hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation5',null)
    ,p_abs_information6             => hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation6',null)
    ,p_abs_information7             => hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation7',null)
    ,p_abs_information8             => hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation8',null)
    ,p_abs_information9             => hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation9',null)
    ,p_abs_information10            => hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation10',null)
    ,p_abs_information11            => hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation11',null)
    ,p_abs_information12            => hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation12',null)
    ,p_abs_information13            => hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation13',null)
    ,p_abs_information14            => hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation14',null)
    ,p_abs_information15            => hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation15',null)
    ,p_abs_information16            => hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation16',null)
    ,p_abs_information17            => hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation17',null)
    ,p_abs_information18            => hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation18',null)
    ,p_abs_information19            => hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation19',null)
    ,p_abs_information20            => hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation20',null)
    ,p_abs_information21            => hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation21',null)
    ,p_abs_information22            => hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation22',null)
    ,p_abs_information23            => hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation23',null)
    ,p_abs_information24            => hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation24',null)
    ,p_abs_information25            => hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation25',null)
    ,p_abs_information26            => hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation26',null)
    ,p_abs_information27            => hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation27',null)
    ,p_abs_information28            => hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation28',null)
    ,p_abs_information29            => hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation29',null)
    ,p_abs_information30            => hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation30',null)
    ,p_absence_attendance_id        => l_absence_attendance_id
    ,p_object_version_number        => l_object_version_number
    ,p_occurrence                   => l_occurrence
    ,p_return_status                => l_return_status);

  elsif l_postState = '2' then


    l_absence_days := hr_transaction_swi.getNumberValue(l_CommitNode,'AbsenceDays',null);
    l_absence_hours := hr_transaction_swi.getNumberValue(l_CommitNode,'AbsenceHours',null);
    l_absence_attendance_id := hr_transaction_swi.getNumberValue(l_CommitNode,'AbsenceAttendanceId',null);

	if( l_absence_days is null and l_absence_hours is null) then

    open c_get_dur(l_absence_attendance_id);
    fetch c_get_dur into  lv_absence_days, lv_absence_hours;

    if  c_get_dur%found then
	l_absence_days := lv_absence_days;
	l_absence_hours := lv_absence_hours;
	end if;

	close c_get_dur;
	end if;

    update_person_absence
    (p_validate                     => p_validate
    ,p_effective_date               => p_effective_date
    ,p_absence_attendance_id        => hr_transaction_swi.getNumberValue(l_CommitNode,'AbsenceAttendanceId')
    ,p_abs_attendance_reason_id     => hr_transaction_swi.getNumberValue(l_CommitNode,'AbsAttendanceReasonId')
    ,p_comments                     =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'Comments')
    ,p_date_notification            => hr_transaction_swi.getDateValue(l_CommitNode,'DateNotification')
    ,p_date_projected_start         => hr_transaction_swi.getDateValue(l_CommitNode,'DateProjectedStart')
    ,p_time_projected_start         =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'TimeProjectedStart')
    ,p_date_projected_end           => hr_transaction_swi.getDateValue(l_CommitNode,'DateProjectedEnd')
    ,p_time_projected_end           =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'TimeProjectedEnd')
    ,p_date_start                   => hr_transaction_swi.getDateValue(l_CommitNode,'DateStart')
    ,p_time_start                   =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'TimeStart')
    ,p_date_end                     => hr_transaction_swi.getDateValue(l_CommitNode,'DateEnd')
    ,p_time_end                     =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'TimeEnd')
    ,p_absence_days                 => l_absence_days
    ,p_absence_hours                => l_absence_hours
    ,p_authorising_person_id        => hr_transaction_swi.getNumberValue(l_CommitNode,'AuthorisingPerson_id')
    ,p_replacement_person_id        => hr_transaction_swi.getNumberValue(l_CommitNode,'ReplacementPersonId')
    ,p_attribute_category           =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'AttributeCategory')
    ,p_attribute1                   =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute1')
    ,p_attribute2                   =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute2')
    ,p_attribute3                   =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute3')
    ,p_attribute4                   =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute4')
    ,p_attribute5                   =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute5')
    ,p_attribute6                   =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute6')
    ,p_attribute7                   =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute7')
    ,p_attribute8                   =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute8')
    ,p_attribute9                   =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute9')
    ,p_attribute10                  =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute10')
    ,p_attribute11                  =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute11')
    ,p_attribute12                  =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute12')
    ,p_attribute13                  =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute13')
    ,p_attribute14                  =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute14')
    ,p_attribute15                  =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute15')
    ,p_attribute16                  =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute16')
    ,p_attribute17                  =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute17')
    ,p_attribute18                  =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute18')
    ,p_attribute19                  =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute19')
    ,p_attribute20                  =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'Attribute20')
    ,p_period_of_incapacity_id      => hr_transaction_swi.getNumberValue(l_CommitNode,'PeriodOfIncapacityId')
    ,p_ssp1_issued                  =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'Ssp1Issued')
    ,p_maternity_id                 => hr_transaction_swi.getNumberValue(l_CommitNode,'MaternityId')
    ,p_sickness_start_date          => hr_transaction_swi.getDateValue(l_CommitNode,'SicknessStartDate')
    ,p_sickness_end_date            => hr_transaction_swi.getDateValue(l_CommitNode,'SicknessEndDate')
    ,p_pregnancy_related_illness    =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'PregnancyRelatedIllness')
    ,p_reason_for_notification_dela =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'ReasonForNotificationDela')
    ,p_accept_late_notification_fla =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'AcceptLateNotificationFla')
    ,p_linked_absence_id            => hr_transaction_swi.getNumberValue(l_CommitNode,'LinkedAbsenceId')
    ,p_batch_id                     => hr_transaction_swi.getNumberValue(l_CommitNode,'BatchId')
    ,p_abs_information_category     =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformationCategory')
    ,p_abs_information1             =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation1')
    ,p_abs_information2             =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation2')
    ,p_abs_information3             =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation3')
    ,p_abs_information4             =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation4')
    ,p_abs_information5             =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation5')
    ,p_abs_information6             =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation6')
    ,p_abs_information7             =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation7')
    ,p_abs_information8             =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation8')
    ,p_abs_information9             =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation9')
    ,p_abs_information10            =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation10')
    ,p_abs_information11            =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation11')
    ,p_abs_information12            =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation12')
    ,p_abs_information13            =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation13')
    ,p_abs_information14            =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation14')
    ,p_abs_information15            =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation15')
    ,p_abs_information16            =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation16')
    ,p_abs_information17            =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation17')
    ,p_abs_information18            =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation18')
    ,p_abs_information19            =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation19')
    ,p_abs_information20            =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation20')
    ,p_abs_information21            =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation21')
    ,p_abs_information22            =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation22')
    ,p_abs_information23            =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation23')
    ,p_abs_information24            =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation24')
    ,p_abs_information25            =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation25')
    ,p_abs_information26            =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation26')
    ,p_abs_information27            =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation27')
    ,p_abs_information28            =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation28')
    ,p_abs_information29            =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation29')
    ,p_abs_information30            =>  hr_transaction_swi.getVarchar2Value(l_CommitNode,'AbsInformation30')
    ,p_object_version_number        => l_object_version_number
    ,p_return_status        => l_return_status);


   elsif l_postState = '3' then

        delete_person_absence
      ( p_validate                     => p_validate
       ,p_absence_attendance_id        => hr_transaction_swi.getNumberValue(l_CommitNode,'AbsenceAttendanceId')
       ,p_object_version_number        => l_object_version_number
       ,p_return_status                => l_return_status
      );

   end if;

   -- finally call the attachements update
   if( l_return_status <> 'E') then
     merge_attachments(hr_transaction_swi.g_txn_ctx.TRANSACTION_ID,
                    hr_transaction_swi.getNumberValue(l_CommitNode,'AbsenceAttendanceId'),
                    l_return_status);
   end if;

   p_return_status := l_return_status;
   hr_utility.set_location('Exiting:' || l_proc,40);
EXCEPTION
  WHEN OTHERS THEN
    rollback to absence_process_api;
    hr_utility.trace('Exception in .process_api:' || SQLERRM );
    hr_utility.set_location(' Leaving:' || l_proc,50);

    raise;

END process_api;

procedure delete_absences_in_tt
(p_transaction_id in	   number)
is

begin

hr_absutil_ss.delete_transaction(p_transaction_id);

exception
when others then
  raise;
end delete_absences_in_tt;


procedure otl_hr_check
(
p_person_id number default null,
p_date_start date default null,
p_date_end date default null,
p_scope varchar2 default null,
p_ret_value out nocopy varchar2,
p_error_name out nocopy varchar2
) is

begin

hr_multi_message.enable_message_list;
hr_person_absence_api.otl_hr_check (
p_person_id => p_person_id,
p_date_start => p_date_start ,
p_date_end => p_date_end ,
p_scope => p_scope ,
p_ret_value => p_ret_value);

exception

when others then
p_error_name := fnd_message.get();

end otl_hr_check;


end hr_person_absence_swi;

/
