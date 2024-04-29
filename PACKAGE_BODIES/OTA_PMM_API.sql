--------------------------------------------------------
--  DDL for Package Body OTA_PMM_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_PMM_API" as
/* $Header: otpmm02t.pkb 120.1 2006/08/18 11:49:26 niarora noship $ */
--
procedure ins
(
  p_program_membership_id        out nocopy number,
  p_event_id                     in out nocopy number,
  p_program_event_id             in number,
  p_object_version_number        out nocopy number,
  p_comments                     in varchar2         default null,
  p_group_name                   in varchar2         default null,
  p_required_flag                in varchar2         default null,
  p_role                         in varchar2         default null,
  p_sequence                     in number           default null,
  p_pmm_information_category     in varchar2         default null,
  p_pmm_information1             in varchar2         default null,
  p_pmm_information2             in varchar2         default null,
  p_pmm_information3             in varchar2         default null,
  p_pmm_information4             in varchar2         default null,
  p_pmm_information5             in varchar2         default null,
  p_pmm_information6             in varchar2         default null,
  p_pmm_information7             in varchar2         default null,
  p_pmm_information8             in varchar2         default null,
  p_pmm_information9             in varchar2         default null,
  p_pmm_information10            in varchar2         default null,
  p_pmm_information11            in varchar2         default null,
  p_pmm_information12            in varchar2         default null,
  p_pmm_information13            in varchar2         default null,
  p_pmm_information14            in varchar2         default null,
  p_pmm_information15            in varchar2         default null,
  p_pmm_information16            in varchar2         default null,
  p_pmm_information17            in varchar2         default null,
  p_pmm_information18            in varchar2         default null,
  p_pmm_information19            in varchar2         default null,
  p_pmm_information20            in varchar2         default null,
  p_activity_version_id          in number           default null,
  p_business_group_id            in number           default null,
  p_organization_id              in number           default null,
  p_title                        in varchar2         default null,
  p_course_end_date              in date             default null,
  p_course_start_date            in date             default null,
  p_duration                     in number           default null,
  p_duration_units               in varchar2         default null,
  p_enrolment_end_date           in date             default null,
  p_enrolment_start_date         in date             default null,
  p_language_id                  in number           default null,
  p_vendor_id                    in number           default null,
  p_event_status                 in varchar2         default null,
  p_maximum_attendees            in number           default null,
  p_maximum_internal_attendees   in number           default null,
  p_minimum_attendees            in number           default null,
  p_parent_offering_id           in number           default null, --upg_classic
  p_validate                     in boolean   default false ,
  p_timezone                             in varchar2           default null
) is

  cursor c_default_values is
  select public_event_flag,
         enrolment_start_date,
         enrolment_end_date,
         organization_id,
	 secure_event_flag
  from   ota_events
  where  event_id = p_program_event_id;

  cursor c_effective_date is
  select effective_date
  from fnd_sessions
  where session_id=userenv('SESSIONID');

  l_default_data c_default_values%rowtype;
  l_object_version_number number;
  l_effective_date date;

/*  bug no 3891115 */
  l_err_code varchar2(72);
  l_err_msg  varchar2(2000);


  l_add_struct_d hr_dflex_utility.l_ignore_dfcode_varray :=
                               hr_dflex_utility.l_ignore_dfcode_varray();

/*  bug no 3891115 */


begin
  --
/*  bug no 3891115 */

     l_add_struct_d.extend(1);
     l_add_struct_d(l_add_struct_d.count) := 'OTA_EVENTS';
     hr_dflex_utility.create_ignore_df_validation(p_rec => l_add_struct_d);
/*  bug no 3891115 */
   if p_event_id is null then
   --
     open c_default_values;
     fetch c_default_values into l_default_data;
     close c_default_values;

     open c_effective_date;
     fetch c_effective_date into l_effective_date;
     close c_effective_date;


     ota_evt_ins.ins
     (p_event_id                     => p_event_id
     ,p_activity_version_id          => p_activity_version_id
     ,p_business_group_id            => p_business_group_id
     ,p_organization_id              => l_default_data.organization_id
     ,p_event_type                   => 'SCHEDULED'
     ,p_object_version_number        => l_object_version_number
     ,p_title                        => p_title
     ,p_course_end_date              => p_course_end_date
     ,p_course_start_date            => p_course_start_date
     ,p_duration                     => p_duration
     ,p_duration_units               => p_duration_units
     ,p_enrolment_end_date           => l_default_data.enrolment_end_date
     ,p_enrolment_start_date         => l_default_data.enrolment_start_date
     ,p_language_id                  => p_language_id
     ,p_vendor_id                    => p_vendor_id
     ,p_event_status                 => p_event_status
     ,p_price_basis                  => 'N'    -- No Charge
     ,p_book_independent_flag        => 'Y'
     ,p_maximum_attendees            => p_maximum_attendees
     ,p_maximum_internal_attendees   => p_maximum_internal_attendees
     ,p_minimum_attendees            => p_minimum_attendees
     ,p_public_event_flag            => l_default_data.public_event_flag
     ,p_secure_event_flag            => l_default_data.secure_event_flag
     ,p_parent_offering_id           =>  p_parent_offering_id --upg_classic
     ,p_validate                     => FALSE
     ,p_timezone                       =>  p_timezone);

     OTA_ENT_INS.INS_TL
       		(P_EFFECTIVE_DATE   => l_effective_date,
		p_language_code	    => USERENV('LANG'),
  		p_event_id          => p_event_id,
  		p_title             => p_title);


   end if;
     hr_dflex_utility.remove_ignore_df_validation;  /*  bug no 3891115 */

   --
   ota_pmm_ins.ins
   (p_program_membership_id        => p_program_membership_id
   ,p_event_id                     => p_event_id
   ,p_program_event_id             => p_program_event_id
   ,p_comments                     => p_comments
   ,p_group_name                   => p_group_name
   ,p_required_flag                => p_required_flag
   ,p_role                         => p_role
   ,p_sequence                     => p_sequence
   ,p_object_version_number        => p_object_version_number
   ,p_pmm_information_category     => p_pmm_information_category
   ,p_pmm_information1             => p_pmm_information1
   ,p_pmm_information2             => p_pmm_information2
   ,p_pmm_information3             => p_pmm_information3
   ,p_pmm_information4             => p_pmm_information4
   ,p_pmm_information5             => p_pmm_information5
   ,p_pmm_information6             => p_pmm_information6
   ,p_pmm_information7             => p_pmm_information7
   ,p_pmm_information8             => p_pmm_information8
   ,p_pmm_information9             => p_pmm_information9
   ,p_pmm_information10            => p_pmm_information10
   ,p_pmm_information11            => p_pmm_information11
   ,p_pmm_information12            => p_pmm_information12
   ,p_pmm_information13            => p_pmm_information13
   ,p_pmm_information14            => p_pmm_information14
   ,p_pmm_information15            => p_pmm_information15
   ,p_pmm_information16            => p_pmm_information16
   ,p_pmm_information17            => p_pmm_information17
   ,p_pmm_information18            => p_pmm_information18
   ,p_pmm_information19            => p_pmm_information19
   ,p_pmm_information20            => p_pmm_information20
   ,p_validate                     => FALSE
  );

end ins;

procedure del
(
  p_program_membership_id              in number,
  p_object_version_number              in number,
  p_event_id                           in number,
  p_validate                           in boolean) is
--
l_event_ovn number;
--
cursor get_event is
select object_version_number
from   ota_events
where  event_id = p_event_id
and    book_independent_flag <> 'Y'
and not exists
 (select null
  from ota_program_memberships
  where event_id = p_event_id
  and  program_membership_id <> p_program_membership_id);
--
begin
  open get_event;
  fetch get_event into l_event_ovn;
  close get_event;
  --
  ota_pmm_del.del(p_program_membership_id => p_program_membership_id
                 ,p_object_version_number => p_object_version_number
                 ,p_validate => false);
  --
  if (not p_validate) and (l_event_ovn is not null) then
hr_utility.trace('Deleting Event with OVN '||
        to_char(l_event_ovn));
     OTA_ENT_DEL.DEL_TL
     		(P_EVENT_ID         => p_event_id);
     ota_evt_del.del(p_event_id => p_event_id
                    ,p_object_version_number => l_event_ovn
                    ,p_validate => FALSE);
  end if;
end del;
--
end;

/
