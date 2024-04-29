--------------------------------------------------------
--  DDL for Package Body OTA_EVENT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_EVENT_API" as
/* $Header: otevtapi.pkb 120.3.12010000.3 2009/05/27 13:26:29 pekasi ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  OTA_EVENT_API.';
--
--
--
   FUNCTION istimezonechanged (p_event_id NUMBER, p_timezone VARCHAR2)
      RETURN BOOLEAN
   IS
      l_timezone   VARCHAR2 (30);

      CURSOR csr_evt_tz (p_event_id NUMBER)
      IS
         SELECT TIMEZONE
           FROM ota_events
          WHERE event_id = p_event_id
           AND event_type IN ('SCHEDULED', 'SELFPACED');
   BEGIN

      OPEN csr_evt_tz (p_event_id);

      FETCH csr_evt_tz
       INTO l_timezone;
      CLOSE csr_evt_tz;

      IF l_timezone IS NOT NULL AND p_timezone <> l_timezone
      THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   END;

--
--
--
   PROCEDURE proc_upd_evt_chat_sess (
      p_event_id                IN              NUMBER,
      p_timezone                IN              VARCHAR2,
      p_effective_date          IN              DATE
   )
   IS

      CURSOR csr_chats (
         p_event_id                IN   NUMBER
      )
      IS
         SELECT cht.chat_id, cht.NAME, cht.description,chb.business_group_id,chb.object_version_number
           FROM ota_chats_tl cht, ota_chat_obj_inclusions coi, ota_chats_b chb
          WHERE coi.chat_id = cht.chat_id
            AND coi.object_id = p_event_id
            and cht.language = userenv('LANG')
            AND chb.chat_id = coi.chat_id;


      CURSOR csr_sess (
         p_event_id                IN   NUMBER
      )
      IS
         SELECT event_id,business_group_id,object_version_number
           FROM ota_events
          WHERE parent_event_id = p_event_id;
   BEGIN

        for csr_chats_row in csr_chats(p_event_id)
        loop

        ota_chat_api.update_chat
                           (p_effective_date             => p_effective_date,
                            p_name                       => csr_chats_row.name,
                            p_description                => csr_chats_row.description,
                            p_business_group_id          => csr_chats_row.business_group_id,
                            p_timezone_code              => p_timezone,
                            p_chat_id                    => csr_chats_row.chat_id,
                            p_object_version_number      => csr_chats_row.object_version_number
                           );

        end loop;

      for csr_sess_row in csr_sess(p_event_id)
      loop


      ota_event_api.update_class
                           (p_event_id                  => csr_sess_row.event_id,
                            p_effective_date            => p_effective_date,
                            p_business_group_id         => csr_sess_row.business_group_id,
                            p_object_version_number     => csr_sess_row.object_version_number,
                            p_timezone                  => p_timezone
                           );
      end loop;



   END;


-- ----------------------------------------------------------------------------
-- |-----------------------------< CREATE_CLASS >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_class(
  p_effective_date                in     date,
  p_event_id                     out nocopy number,
  p_vendor_id                    in number           default null,
  p_activity_version_id          in number           default null,
  p_business_group_id            in number,
  p_organization_id              in number           default null,
  p_event_type                   in varchar2,
  p_object_version_number        out nocopy number,
  p_title                        in varchar2,
  p_budget_cost                  in number           default null,
  p_actual_cost                  in number           default null,
  p_budget_currency_code         in varchar2         default null,
  p_centre                       in varchar2         default null,
  p_comments                     in varchar2         default null,
  p_course_end_date              in date             default null,
  p_course_end_time              in varchar2         default null,
  p_course_start_date            in date             default null,
  p_course_start_time            in varchar2         default null,
  p_duration                     in number           default null,
  p_duration_units               in varchar2         default null,
  p_enrolment_end_date           in date             default null,
  p_enrolment_start_date         in date             default null,
  p_language_id                  in number           default null,
  p_user_status                  in varchar2         default null,
  p_development_event_type       in varchar2         default null,
  p_event_status                 in varchar2         default null,
  p_price_basis                  in varchar2         default null,
  p_currency_code                in varchar2         default null,
  p_maximum_attendees            in number           default null,
  p_maximum_internal_attendees   in number           default null,
  p_minimum_attendees            in number           default null,
  p_standard_price               in number           default null,
  p_category_code                in varchar2         default null,
  p_parent_event_id              in number           default null,
  p_book_independent_flag        in varchar2         default null,
  p_public_event_flag            in varchar2         default null,
  p_secure_event_flag            in varchar2         default null,
  p_evt_information_category     in varchar2         default null,
  p_evt_information1             in varchar2         default null,
  p_evt_information2             in varchar2         default null,
  p_evt_information3             in varchar2         default null,
  p_evt_information4             in varchar2         default null,
  p_evt_information5             in varchar2         default null,
  p_evt_information6             in varchar2         default null,
  p_evt_information7             in varchar2         default null,
  p_evt_information8             in varchar2         default null,
  p_evt_information9             in varchar2         default null,
  p_evt_information10            in varchar2         default null,
  p_evt_information11            in varchar2         default null,
  p_evt_information12            in varchar2         default null,
  p_evt_information13            in varchar2         default null,
  p_evt_information14            in varchar2         default null,
  p_evt_information15            in varchar2         default null,
  p_evt_information16            in varchar2         default null,
  p_evt_information17            in varchar2         default null,
  p_evt_information18            in varchar2         default null,
  p_evt_information19            in varchar2         default null,
  p_evt_information20            in varchar2         default null,
  p_project_id                   in number           default null,
  p_owner_id			         in number	         default null,
  p_line_id				         in number	         default null,
  p_org_id				         in number	         default null,
  p_training_center_id           in number           default null,
  p_location_id                  in number           default null,
  p_offering_id         	     in number           default null,
  p_timezone	                 in varchar2         default null,
  p_parent_offering_id			 in number	         default null,
  p_data_source	                 in varchar2         default null,
  p_validate                     in boolean          default false,
  p_event_availability           in varchar2         default null
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Create Class';
  l_event_id number;
  l_object_version_number   number;
  l_effective_date          date;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_CLASS;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --

  begin
    ota_event_bk1.create_class_b
  (p_effective_date              => l_effective_date,
  p_vendor_id                    => p_vendor_id,
  p_activity_version_id          => p_activity_version_id,
  p_business_group_id            => p_business_group_id,
  p_organization_id              => p_organization_id,
  p_event_type                   => p_event_type,
  p_object_version_number        => l_object_version_number,
  p_title                        => p_title,
  p_budget_cost                  => p_budget_cost,
  p_actual_cost                  => p_actual_cost,
  p_budget_currency_code         => p_budget_currency_code,
  p_centre                       => p_centre,
  p_comments                     => p_comments,
  p_course_end_date              => p_course_end_date,
  p_course_end_time              => p_course_end_time,
  p_course_start_date            => p_course_start_date,
  p_course_start_time            => p_course_start_time,
  p_duration                     => p_duration,
  p_duration_units               => p_duration_units,
  p_enrolment_end_date           => p_enrolment_end_date,
  p_enrolment_start_date         => p_enrolment_start_date,
  p_language_id                  => p_language_id,
  p_user_status                  => p_user_status,
  p_development_event_type       => p_development_event_type,
  p_event_status                 => p_event_status,
  p_price_basis                  => p_price_basis,
  p_currency_code                => p_currency_code,
  p_maximum_attendees            => p_maximum_attendees,
  p_maximum_internal_attendees   => p_maximum_internal_attendees,
  p_minimum_attendees            => p_minimum_attendees,
  p_standard_price               => p_standard_price,
  p_category_code                => p_category_code,
  p_parent_event_id              => p_parent_event_id,
  p_book_independent_flag        => p_book_independent_flag,
  p_public_event_flag            => p_public_event_flag,
  p_secure_event_flag            => p_secure_event_flag,
  p_evt_information_category     => p_evt_information_category,
  p_evt_information1             => p_evt_information1,
  p_evt_information2             => p_evt_information2,
  p_evt_information3             => p_evt_information3,
  p_evt_information4             => p_evt_information4,
  p_evt_information5             => p_evt_information5,
  p_evt_information6             => p_evt_information6,
  p_evt_information7             => p_evt_information7,
  p_evt_information8             => p_evt_information8,
  p_evt_information9             => p_evt_information9,
  p_evt_information10            => p_evt_information10,
  p_evt_information11            => p_evt_information11,
  p_evt_information12            => p_evt_information12,
  p_evt_information13            => p_evt_information13,
  p_evt_information14            => p_evt_information14,
  p_evt_information15            => p_evt_information15,
  p_evt_information16            => p_evt_information16,
  p_evt_information17            => p_evt_information17,
  p_evt_information18            => p_evt_information18,
  p_evt_information19            => p_evt_information19,
  p_evt_information20            => p_evt_information20,
  p_project_id                   => p_project_id,
  p_owner_id			         => p_owner_id,
  p_line_id				         => p_line_id,
  p_org_id				         => p_org_id,
  p_training_center_id           => p_training_center_id,
  p_location_id 			     => p_location_id,
  p_offering_id			         => p_offering_id,
  p_timezone			         => p_timezone,
  p_parent_offering_id			 => p_parent_offering_id,
  p_data_source			         => p_data_source,
  p_event_availability           => p_event_availability);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_CLASS'
        ,p_hook_type   => 'BP'
        );
  end;
  --

  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
  ota_evt_ins.ins(
  p_vendor_id                    => p_vendor_id,
  p_activity_version_id          => p_activity_version_id,
  p_business_group_id            => p_business_group_id,
  p_organization_id              => p_organization_id,
  p_event_type                   => p_event_type,
  p_title                        => p_title,
  p_budget_cost                  => p_budget_cost,
  p_actual_cost                  => p_actual_cost,
  p_budget_currency_code         => p_budget_currency_code,
  p_centre                       => p_centre,
  p_comments                     => p_comments,
  p_course_end_date              => p_course_end_date,
  p_course_end_time              => p_course_end_time,
  p_course_start_date            => p_course_start_date,
  p_course_start_time            => p_course_start_time,
  p_duration                     => p_duration,
  p_duration_units               => p_duration_units,
  p_enrolment_end_date           => p_enrolment_end_date,
  p_enrolment_start_date         => p_enrolment_start_date,
  p_language_id                  => p_language_id,
  p_user_status                  => p_user_status,
  p_development_event_type       => p_development_event_type,
  p_event_status                 => p_event_status,
  p_price_basis                  => p_price_basis,
  p_currency_code                => p_currency_code,
  p_maximum_attendees            => p_maximum_attendees,
  p_maximum_internal_attendees   => p_maximum_internal_attendees,
  p_minimum_attendees            => p_minimum_attendees,
  p_standard_price               => p_standard_price,
  p_category_code                => p_category_code,
  p_parent_event_id              => p_parent_event_id,
  p_book_independent_flag        => p_book_independent_flag,
  p_public_event_flag            => p_public_event_flag,
  p_secure_event_flag            => p_secure_event_flag,
  p_evt_information_category     => p_evt_information_category,
  p_evt_information1             => p_evt_information1,
  p_evt_information2             => p_evt_information2,
  p_evt_information3             => p_evt_information3,
  p_evt_information4             => p_evt_information4,
  p_evt_information5             => p_evt_information5,
  p_evt_information6             => p_evt_information6,
  p_evt_information7             => p_evt_information7,
  p_evt_information8             => p_evt_information8,
  p_evt_information9             => p_evt_information9,
  p_evt_information10            => p_evt_information10,
  p_evt_information11            => p_evt_information11,
  p_evt_information12            => p_evt_information12,
  p_evt_information13            => p_evt_information13,
  p_evt_information14            => p_evt_information14,
  p_evt_information15            => p_evt_information15,
  p_evt_information16            => p_evt_information16,
  p_evt_information17            => p_evt_information17,
  p_evt_information18            => p_evt_information18,
  p_evt_information19            => p_evt_information19,
  p_evt_information20            => p_evt_information20,
  p_project_id                   => p_project_id,
  p_owner_id			         => p_owner_id,
  p_line_id	                     => p_line_id,
  p_org_id				         => p_org_id,
  p_training_center_id           => p_training_center_id,
  p_location_id                  => p_location_id,
  p_offering_id         	     => p_offering_id,
  p_timezone	                 => p_timezone,
  p_parent_offering_id           => p_parent_offering_id,
  p_data_source                  => p_data_source,
  p_validate                     => p_validate,
  p_event_id                     => l_event_id,
  p_object_version_number        => l_object_version_number,
  p_event_availability           => p_event_availability
  );
    -- Set all output arguments
  --
  p_event_id                     := l_event_id;
  p_object_version_number        := l_object_version_number;

  ota_ent_ins.ins_tl(
  p_effective_date	             => p_effective_date,
  p_language_code	             => USERENV('LANG'),
  p_event_id                     => p_event_id,
  p_title                        => p_title
  );
--
    --Adding evaluation at class level from the default
    --class evaluation at the course level.
    add_evaluation(p_event_id,p_activity_version_id);

  --
  -- Call After Process User Hook
  --
  begin
  ota_event_bk1.create_class_a
 (p_effective_date               => l_effective_date,
  p_event_id                     => l_event_id,
  p_vendor_id                    => p_vendor_id,
  p_activity_version_id          => p_activity_version_id,
  p_business_group_id            => p_business_group_id,
  p_organization_id              => p_organization_id,
  p_event_type                   => p_event_type,
  p_object_version_number        => l_object_version_number,
  p_title                        => p_title,
  p_budget_cost                  => p_budget_cost,
  p_actual_cost                  => p_actual_cost,
  p_budget_currency_code         => p_budget_currency_code,
  p_centre                       => p_centre,
  p_comments                     => p_comments,
  p_course_end_date              => p_course_end_date,
  p_course_end_time              => p_course_end_time,
  p_course_start_date            => p_course_start_date,
  p_course_start_time            => p_course_start_time,
  p_duration                     => p_duration,
  p_duration_units               => p_duration_units,
  p_enrolment_end_date           => p_enrolment_end_date,
  p_enrolment_start_date         => p_enrolment_start_date,
  p_language_id                  => p_language_id,
  p_user_status                  => p_user_status,
  p_development_event_type       => p_development_event_type,
  p_event_status                 => p_event_status,
  p_price_basis                  => p_price_basis,
  p_currency_code                => p_currency_code,
  p_maximum_attendees            => p_maximum_attendees,
  p_maximum_internal_attendees   => p_maximum_internal_attendees,
  p_minimum_attendees            => p_minimum_attendees,
  p_standard_price               => p_standard_price,
  p_category_code                => p_category_code,
  p_parent_event_id              => p_parent_event_id,
  p_book_independent_flag        => p_book_independent_flag,
  p_public_event_flag            => p_public_event_flag,
  p_secure_event_flag            => p_secure_event_flag,
  p_evt_information_category     => p_evt_information_category,
  p_evt_information1             => p_evt_information1,
  p_evt_information2             => p_evt_information2,
  p_evt_information3             => p_evt_information3,
  p_evt_information4             => p_evt_information4,
  p_evt_information5             => p_evt_information5,
  p_evt_information6             => p_evt_information6,
  p_evt_information7             => p_evt_information7,
  p_evt_information8             => p_evt_information8,
  p_evt_information9             => p_evt_information9,
  p_evt_information10            => p_evt_information10,
  p_evt_information11            => p_evt_information11,
  p_evt_information12            => p_evt_information12,
  p_evt_information13            => p_evt_information13,
  p_evt_information14            => p_evt_information14,
  p_evt_information15            => p_evt_information15,
  p_evt_information16            => p_evt_information16,
  p_evt_information17            => p_evt_information17,
  p_evt_information18            => p_evt_information18,
  p_evt_information19            => p_evt_information19,
  p_evt_information20            => p_evt_information20,
  p_project_id                   => p_project_id,
  p_owner_id			         => p_owner_id,
  p_line_id				         => p_line_id,
  p_org_id				         => p_org_id,
  p_training_center_id           => p_training_center_id,
  p_location_id 			     => p_location_id,
  p_offering_id			         => p_offering_id,
  p_timezone			         => p_timezone,
  p_parent_offering_id			 => p_parent_offering_id,
  p_data_source			         => p_data_source,
  p_event_availability           => p_event_availability);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_CLASS'
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
  p_event_id        := l_event_id;
  p_object_version_number   := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_CLASS;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_event_id := null;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_CLASS;
    p_event_id        := null;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_class;
-- ----------------------------------------------------------------------------
-- |-------------------------< UPDATE_CLASS >---------------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_class
  (p_event_id                     in number,
  p_effective_date               in date,
  p_vendor_id                    in number           default hr_api.g_number,
  p_activity_version_id          in number           default hr_api.g_number,
  p_business_group_id            in number           default hr_api.g_number,
  p_organization_id              in number           default hr_api.g_number,
  p_event_type                   in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out nocopy number,
  p_title                        in varchar2         default hr_api.g_varchar2,
  p_budget_cost                  in number           default hr_api.g_number,
  p_actual_cost                  in number           default hr_api.g_number,
  p_budget_currency_code         in varchar2         default hr_api.g_varchar2,
  p_centre                       in varchar2         default hr_api.g_varchar2,
  p_comments                     in varchar2         default hr_api.g_varchar2,
  p_course_end_date              in date             default hr_api.g_date,
  p_course_end_time              in varchar2         default hr_api.g_varchar2,
  p_course_start_date            in date             default hr_api.g_date,
  p_course_start_time            in varchar2         default hr_api.g_varchar2,
  p_duration                     in number           default hr_api.g_number,
  p_duration_units               in varchar2         default hr_api.g_varchar2,
  p_enrolment_end_date           in date             default hr_api.g_date,
  p_enrolment_start_date         in date             default hr_api.g_date,
  p_language_id                  in number           default hr_api.g_number,
  p_user_status                  in varchar2         default hr_api.g_varchar2,
  p_development_event_type       in varchar2         default hr_api.g_varchar2,
  p_event_status                 in varchar2         default hr_api.g_varchar2,
  p_price_basis                  in varchar2         default hr_api.g_varchar2,
  p_currency_code                in varchar2         default hr_api.g_varchar2,
  p_maximum_attendees            in number           default hr_api.g_number,
  p_maximum_internal_attendees   in number           default hr_api.g_number,
  p_minimum_attendees            in number           default hr_api.g_number,
  p_standard_price               in number           default hr_api.g_number,
  p_category_code                in varchar2         default hr_api.g_varchar2,
  p_parent_event_id              in number           default hr_api.g_number,
  p_book_independent_flag        in varchar2         default hr_api.g_varchar2,
  p_public_event_flag            in varchar2         default hr_api.g_varchar2,
  p_secure_event_flag            in varchar2         default hr_api.g_varchar2,
  p_evt_information_category     in varchar2         default hr_api.g_varchar2,
  p_evt_information1             in varchar2         default hr_api.g_varchar2,
  p_evt_information2             in varchar2         default hr_api.g_varchar2,
  p_evt_information3             in varchar2         default hr_api.g_varchar2,
  p_evt_information4             in varchar2         default hr_api.g_varchar2,
  p_evt_information5             in varchar2         default hr_api.g_varchar2,
  p_evt_information6             in varchar2         default hr_api.g_varchar2,
  p_evt_information7             in varchar2         default hr_api.g_varchar2,
  p_evt_information8             in varchar2         default hr_api.g_varchar2,
  p_evt_information9             in varchar2         default hr_api.g_varchar2,
  p_evt_information10            in varchar2         default hr_api.g_varchar2,
  p_evt_information11            in varchar2         default hr_api.g_varchar2,
  p_evt_information12            in varchar2         default hr_api.g_varchar2,
  p_evt_information13            in varchar2         default hr_api.g_varchar2,
  p_evt_information14            in varchar2         default hr_api.g_varchar2,
  p_evt_information15            in varchar2         default hr_api.g_varchar2,
  p_evt_information16            in varchar2         default hr_api.g_varchar2,
  p_evt_information17            in varchar2         default hr_api.g_varchar2,
  p_evt_information18            in varchar2         default hr_api.g_varchar2,
  p_evt_information19            in varchar2         default hr_api.g_varchar2,
  p_evt_information20            in varchar2         default hr_api.g_varchar2,
  p_project_id                   in number           default hr_api.g_number,
  p_owner_id                     in number           default hr_api.g_number,
  p_line_id	                     in number           default hr_api.g_number,
  p_org_id	                     in number           default hr_api.g_number,
  p_training_center_id           in number           default hr_api.g_number,
  p_location_id	               in number             default hr_api.g_number,
  p_offering_id		         in number               default hr_api.g_number,
  p_timezone	               in varchar2           default hr_api.g_varchar2,
-- Bug#2200078 Corrected default value for offering_id and timezone
--  p_offering_id		         in number           default null,
--  p_timezone	               in varchar2         default null,
  p_parent_offering_id 	         in number	         default hr_api.g_number,
  p_data_source                  in varchar2         default hr_api.g_varchar2,
  p_validate                     in boolean          default false,
  p_event_availability           in varchar2         default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Update Class';
  l_effective_date          date;
  l_object_version_number   number := p_object_version_number;
   l_timezonechanged BOOLEAN := false;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_CLASS;
  --
  -- Truncate the time portion from all IN date parameters
  --
  IF p_timezone <> hr_api.g_varchar2 THEN
        l_timezonechanged := istimezonechanged(p_event_id, p_timezone);
      END IF;
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Call Before Process User Hook
  --

  begin
  ota_event_bk2.update_class_b
 (p_effective_date               => l_effective_date,
  p_event_id                     => p_event_id,
  p_vendor_id                    => p_vendor_id,
  p_activity_version_id          => p_activity_version_id,
  p_business_group_id            => p_business_group_id,
  p_organization_id              => p_organization_id,
  p_event_type                   => p_event_type,
  p_object_version_number        => l_object_version_number,
  p_title                        => p_title,
  p_budget_cost                  => p_budget_cost,
  p_actual_cost                  => p_actual_cost,
  p_budget_currency_code         => p_budget_currency_code,
  p_centre                       => p_centre,
  p_comments                     => p_comments,
  p_course_end_date              => p_course_end_date,
  p_course_end_time              => p_course_end_time,
  p_course_start_date            => p_course_start_date,
  p_course_start_time            => p_course_start_time,
  p_duration                     => p_duration,
  p_duration_units               => p_duration_units,
  p_enrolment_end_date           => p_enrolment_end_date,
  p_enrolment_start_date         => p_enrolment_start_date,
  p_language_id                  => p_language_id,
  p_user_status                  => p_user_status,
  p_development_event_type       => p_development_event_type,
  p_event_status                 => p_event_status,
  p_price_basis                  => p_price_basis,
  p_currency_code                => p_currency_code,
  p_maximum_attendees            => p_maximum_attendees,
  p_maximum_internal_attendees   => p_maximum_internal_attendees,
  p_minimum_attendees            => p_minimum_attendees,
  p_standard_price               => p_standard_price,
  p_category_code                => p_category_code,
  p_parent_event_id              => p_parent_event_id,
  p_book_independent_flag        => p_book_independent_flag,
  p_public_event_flag            => p_public_event_flag,
  p_secure_event_flag            => p_secure_event_flag,
  p_evt_information_category     => p_evt_information_category,
  p_evt_information1             => p_evt_information1,
  p_evt_information2             => p_evt_information2,
  p_evt_information3             => p_evt_information3,
  p_evt_information4             => p_evt_information4,
  p_evt_information5             => p_evt_information5,
  p_evt_information6             => p_evt_information6,
  p_evt_information7             => p_evt_information7,
  p_evt_information8             => p_evt_information8,
  p_evt_information9             => p_evt_information9,
  p_evt_information10            => p_evt_information10,
  p_evt_information11            => p_evt_information11,
  p_evt_information12            => p_evt_information12,
  p_evt_information13            => p_evt_information13,
  p_evt_information14            => p_evt_information14,
  p_evt_information15            => p_evt_information15,
  p_evt_information16            => p_evt_information16,
  p_evt_information17            => p_evt_information17,
  p_evt_information18            => p_evt_information18,
  p_evt_information19            => p_evt_information19,
  p_evt_information20            => p_evt_information20,
  p_project_id                   => p_project_id,
  p_owner_id			         => p_owner_id,
  p_line_id				         => p_line_id,
  p_org_id				         => p_org_id,
  p_training_center_id           => p_training_center_id,
  p_location_id 			     => p_location_id,
  p_offering_id			         => p_offering_id,
  p_timezone			         => p_timezone,
  p_parent_offering_id			 => p_parent_offering_id,
  p_data_source			         => p_data_source,
  p_event_availability           => p_event_availability);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_CLASS'
        ,p_hook_type   => 'BP'
        );
  end;
  --

  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
    ota_evt_upd.upd(
  p_vendor_id                    => p_vendor_id,
  p_activity_version_id          => p_activity_version_id,
  p_business_group_id            => p_business_group_id,
  p_organization_id              => p_organization_id,
  p_event_type                   => p_event_type,
  p_title                        => p_title,
  p_budget_cost                  => p_budget_cost,
  p_actual_cost                  => p_actual_cost,
  p_budget_currency_code         => p_budget_currency_code,
  p_centre                       => p_centre,
  p_comments                     => p_comments,
  p_course_end_date              => p_course_end_date,
  p_course_end_time              => p_course_end_time,
  p_course_start_date            => p_course_start_date,
  p_course_start_time            => p_course_start_time,
  p_duration                     => p_duration,
  p_duration_units               => p_duration_units,
  p_enrolment_end_date           => p_enrolment_end_date,
  p_enrolment_start_date         => p_enrolment_start_date,
  p_language_id                  => p_language_id,
  p_user_status                  => p_user_status,
  p_development_event_type       => p_development_event_type,
  p_event_status                 => p_event_status,
  p_price_basis                  => p_price_basis,
  p_currency_code                => p_currency_code,
  p_maximum_attendees            => p_maximum_attendees,
  p_maximum_internal_attendees   => p_maximum_internal_attendees,
  p_minimum_attendees            => p_minimum_attendees,
  p_standard_price               => p_standard_price,
  p_category_code                => p_category_code,
  p_parent_event_id              => p_parent_event_id,
  p_book_independent_flag        => p_book_independent_flag,
  p_public_event_flag            => p_public_event_flag,
  p_secure_event_flag            => p_secure_event_flag,
  p_evt_information_category     => p_evt_information_category,
  p_evt_information1             => p_evt_information1,
  p_evt_information2             => p_evt_information2,
  p_evt_information3             => p_evt_information3,
  p_evt_information4             => p_evt_information4,
  p_evt_information5             => p_evt_information5,
  p_evt_information6             => p_evt_information6,
  p_evt_information7             => p_evt_information7,
  p_evt_information8             => p_evt_information8,
  p_evt_information9             => p_evt_information9,
  p_evt_information10            => p_evt_information10,
  p_evt_information11            => p_evt_information11,
  p_evt_information12            => p_evt_information12,
  p_evt_information13            => p_evt_information13,
  p_evt_information14            => p_evt_information14,
  p_evt_information15            => p_evt_information15,
  p_evt_information16            => p_evt_information16,
  p_evt_information17            => p_evt_information17,
  p_evt_information18            => p_evt_information18,
  p_evt_information19            => p_evt_information19,
  p_evt_information20            => p_evt_information20,
  p_project_id                   => p_project_id,
  p_owner_id			         => p_owner_id,
  p_line_id	                     => p_line_id,
  p_org_id				         => p_org_id,
  p_training_center_id           => p_training_center_id,
  p_location_id                  => p_location_id,
  p_offering_id         	     => p_offering_id,
  p_timezone	                 => p_timezone,
  p_parent_offering_id           => p_parent_offering_id,
  p_data_source                  => p_data_source,
  p_validate                     => p_validate,
  p_event_id                     => p_event_id,
  p_object_version_number        => l_object_version_number,
  p_event_availability           => p_event_availability
  );

  ota_ent_upd.upd_tl(
  p_effective_date	             => p_effective_date,
  p_language_code	             => USERENV('LANG'),
  p_event_id                     => p_event_id,
  p_title                        => p_title
  );



  --
  -- Call After Process User Hook
  --
  begin
  ota_event_bk2.update_class_a
 (p_effective_date               => l_effective_date,
  p_event_id                     => p_event_id,
  p_vendor_id                    => p_vendor_id,
  p_activity_version_id          => p_activity_version_id,
  p_business_group_id            => p_business_group_id,
  p_organization_id              => p_organization_id,
  p_event_type                   => p_event_type,
  p_object_version_number        => l_object_version_number,
  p_title                        => p_title,
  p_budget_cost                  => p_budget_cost,
  p_actual_cost                  => p_actual_cost,
  p_budget_currency_code         => p_budget_currency_code,
  p_centre                       => p_centre,
  p_comments                     => p_comments,
  p_course_end_date              => p_course_end_date,
  p_course_end_time              => p_course_end_time,
  p_course_start_date            => p_course_start_date,
  p_course_start_time            => p_course_start_time,
  p_duration                     => p_duration,
  p_duration_units               => p_duration_units,
  p_enrolment_end_date           => p_enrolment_end_date,
  p_enrolment_start_date         => p_enrolment_start_date,
  p_language_id                  => p_language_id,
  p_user_status                  => p_user_status,
  p_development_event_type       => p_development_event_type,
  p_event_status                 => p_event_status,
  p_price_basis                  => p_price_basis,
  p_currency_code                => p_currency_code,
  p_maximum_attendees            => p_maximum_attendees,
  p_maximum_internal_attendees   => p_maximum_internal_attendees,
  p_minimum_attendees            => p_minimum_attendees,
  p_standard_price               => p_standard_price,
  p_category_code                => p_category_code,
  p_parent_event_id              => p_parent_event_id,
  p_book_independent_flag        => p_book_independent_flag,
  p_public_event_flag            => p_public_event_flag,
  p_secure_event_flag            => p_secure_event_flag,
  p_evt_information_category     => p_evt_information_category,
  p_evt_information1             => p_evt_information1,
  p_evt_information2             => p_evt_information2,
  p_evt_information3             => p_evt_information3,
  p_evt_information4             => p_evt_information4,
  p_evt_information5             => p_evt_information5,
  p_evt_information6             => p_evt_information6,
  p_evt_information7             => p_evt_information7,
  p_evt_information8             => p_evt_information8,
  p_evt_information9             => p_evt_information9,
  p_evt_information10            => p_evt_information10,
  p_evt_information11            => p_evt_information11,
  p_evt_information12            => p_evt_information12,
  p_evt_information13            => p_evt_information13,
  p_evt_information14            => p_evt_information14,
  p_evt_information15            => p_evt_information15,
  p_evt_information16            => p_evt_information16,
  p_evt_information17            => p_evt_information17,
  p_evt_information18            => p_evt_information18,
  p_evt_information19            => p_evt_information19,
  p_evt_information20            => p_evt_information20,
  p_project_id                   => p_project_id,
  p_owner_id			         => p_owner_id,
  p_line_id				         => p_line_id,
  p_org_id				         => p_org_id,
  p_training_center_id           => p_training_center_id,
  p_location_id 			     => p_location_id,
  p_offering_id			         => p_offering_id,
  p_timezone			         => p_timezone,
  p_parent_offering_id			 => p_parent_offering_id,
  p_data_source			         => p_data_source,
  p_event_availability           => p_event_availability);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_CLASS'
        ,p_hook_type   => 'AP'
        );
  end;

  --

  IF l_timezonechanged
      THEN
         proc_upd_evt_chat_sess (p_event_id,
                                 p_timezone,
                                 p_effective_date
                                );
      END IF;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to UPDATE_CLASS;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to UPDATE_CLASS;
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_class;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_CLASS >---------------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_class
  (p_validate                      in     boolean  default false
  ,p_event_id                   in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Delete Class';
  l_object_version_id       number;
  --
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_CLASS;
  --
  -- Truncate the time portion from all IN date parameters
  --
  --

  -- Call Before Process User Hook
  --
  begin
    ota_event_bk3.delete_class_b
  (p_event_id                    => p_event_id,
   p_object_version_number       => p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_CLASS'
        ,p_hook_type   => 'BP'
        );
  end;
  --

  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --
 --
  ota_ent_del.del_tl
  (p_event_id                => p_event_id
  );
  --

  ota_evt_del.del
  (p_event_id                => p_event_id
  ,p_object_version_number   => p_object_version_number
  );
  --

  -- Call After Process User Hook
  --
  begin
  ota_event_bk3.delete_class_a
  (p_event_id                    => p_event_id,
   p_object_version_number       => p_object_version_number
  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_CLASS'
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
  --
  hr_utility.set_location(' Leaving:'||l_proc, 170);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to DELETE_CLASS;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 180);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to DELETE_CLASS;
    hr_utility.set_location(' Leaving:'||l_proc, 190);
    raise;
end delete_class;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< add_evaluation >----------------------------|
-- ----------------------------------------------------------------------------
procedure add_evaluation(p_event_id in number,
                         p_activity_version_id in number
                         ) is

l_eval_id ota_tests.test_id%type :=null;
l_mand_flag ota_evaluations.eval_mandatory_flag%type;

Cursor c_dflt_eval is
select dflt_class_eval_id,eval_mandatory_flag
into l_eval_id,l_mand_flag
from ota_evaluations
where object_id = p_activity_version_id
and object_type = 'A';

l_proc    varchar2(72) := g_package ||'add_evaluation';
Begin
    hr_utility.set_location(' Entering:' || l_proc,10);
    open c_dflt_eval;
    fetch c_dflt_eval into l_eval_id, l_mand_flag;
    close c_dflt_eval;
    if l_eval_id is not null then
        insert into ota_evaluations (evaluation_id,
                                    eval_mandatory_flag,
                                    object_id,
                                    object_type,
                                    object_version_number) values
                                    (l_eval_id,
                                     l_mand_flag,
                                     p_event_id,
                                     'E',
                                     1);
    end if;
    hr_utility.set_location(' Exiting:' || l_proc,15);
end add_evaluation;

end OTA_EVENT_API;

/
