--------------------------------------------------------
--  DDL for Package Body OTA_ACTIVITY_VERSION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_ACTIVITY_VERSION_API" as
/* $Header: ottavapi.pkb 120.0.12010000.2 2009/08/11 13:13:11 smahanka ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  OTA_ACTIVITY_VERSION_API.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< CREATE_ACTIVITY_VERSION >------------------|
-- ----------------------------------------------------------------------------
--
procedure create_activity_version
(
  p_effective_date               in date,
  p_validate                     in boolean   default false ,
  p_activity_id                  in number,
  p_superseded_by_act_version_id in number          ,
  p_developer_organization_id    in number,
  p_controlling_person_id        in number          ,
  p_version_name                 in varchar2,
  p_comments                     in varchar2        ,
  p_description                  in varchar2        ,
  p_duration                     in number          ,
  p_duration_units               in varchar2        ,
  p_end_date                     in date            ,
  p_intended_audience            in varchar2        ,
  p_language_id                  in number          ,
  p_maximum_attendees            in number          ,
  p_minimum_attendees            in number          ,
  p_objectives                   in varchar2        ,
  p_start_date                   in date            ,
  p_success_criteria             in varchar2        ,
  p_user_status                  in varchar2        ,
  p_vendor_id                    in number          ,
  p_actual_cost                  in number          ,
  p_budget_cost                  in number          ,
  p_budget_currency_code         in varchar2        ,
  p_expenses_allowed             in varchar2        ,
  p_professional_credit_type     in varchar2        ,
  p_professional_credits         in number          ,
  p_maximum_internal_attendees   in number          ,
  p_tav_information_category     in varchar2        ,
  p_tav_information1             in varchar2        ,
  p_tav_information2             in varchar2        ,
  p_tav_information3             in varchar2        ,
  p_tav_information4             in varchar2        ,
  p_tav_information5             in varchar2        ,
  p_tav_information6             in varchar2        ,
  p_tav_information7             in varchar2        ,
  p_tav_information8             in varchar2        ,
  p_tav_information9             in varchar2        ,
  p_tav_information10            in varchar2        ,
  p_tav_information11            in varchar2        ,
  p_tav_information12            in varchar2        ,
  p_tav_information13            in varchar2        ,
  p_tav_information14            in varchar2        ,
  p_tav_information15            in varchar2        ,
  p_tav_information16            in varchar2        ,
  p_tav_information17            in varchar2        ,
  p_tav_information18            in varchar2        ,
  p_tav_information19            in varchar2        ,
  p_tav_information20            in varchar2        ,
  p_inventory_item_id            in number          ,
  p_organization_id		   in number	    ,
  p_rco_id		         in number	    ,
  p_version_code                 in varchar2        ,
  p_keywords                     in varchar2        ,
  p_business_group_id            in number          ,
  p_activity_version_id          out nocopy number  ,
  p_object_version_number        out  nocopy  number,
  p_data_source                  in varchar2
  ,p_competency_update_level        in     varchar2 ,
  p_eres_enabled                 in varchar2

  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Create Activity Version';
  l_activity_version_id number;
  l_object_version_number   number;
  l_effective_date date;
  l_version_name ota_activity_versions_tl.version_name%type;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_ACTIVITY_VERSION;
  l_effective_date := trunc(p_effective_date);
  l_version_name := rtrim(p_version_name);
  --
  begin
      ota_activity_version_bk1.create_activity_version_b
    (
  p_effective_date        =>      l_effective_date    ,
  p_activity_id                  => p_activity_id                  ,
  p_superseded_by_act_version_id => p_superseded_by_act_version_id ,
  p_developer_organization_id    => p_developer_organization_id    ,
  p_controlling_person_id        => p_controlling_person_id        ,
  p_version_name                 => l_version_name                 ,
  p_comments                     => p_comments                     ,
  p_description                  => p_description                  ,
  p_duration                     => p_duration                     ,
  p_duration_units               => p_duration_units               ,
  p_end_date                     => p_end_date                     ,
  p_intended_audience            => p_intended_audience            ,
  p_language_id                  => p_language_id                  ,
  p_maximum_attendees            => p_maximum_attendees            ,
  p_minimum_attendees            => p_minimum_attendees            ,
  p_objectives                   => p_objectives                   ,
  p_start_date                   => p_start_date                   ,
  p_success_criteria             => p_success_criteria             ,
  p_user_status                  => p_user_status                  ,
  p_vendor_id                    => p_vendor_id                    ,
  p_actual_cost                  => p_actual_cost                  ,
  p_budget_cost                  => p_budget_cost                  ,
  p_budget_currency_code         => p_budget_currency_code         ,
  p_expenses_allowed             => p_expenses_allowed             ,
  p_professional_credit_type     => p_professional_credit_type     ,
  p_professional_credits         => p_professional_credits         ,
  p_maximum_internal_attendees   => p_maximum_internal_attendees   ,
  p_tav_information_category     => p_tav_information_category     ,
  p_tav_information1             => p_tav_information1             ,
  p_tav_information2             => p_tav_information2             ,
  p_tav_information3             => p_tav_information3             ,
  p_tav_information4             => p_tav_information4             ,
  p_tav_information5             => p_tav_information5             ,
  p_tav_information6             => p_tav_information6             ,
  p_tav_information7             => p_tav_information7             ,
  p_tav_information8             => p_tav_information8             ,
  p_tav_information9             => p_tav_information9             ,
  p_tav_information10            => p_tav_information10            ,
  p_tav_information11            => p_tav_information11            ,
  p_tav_information12            => p_tav_information12            ,
  p_tav_information13            => p_tav_information13            ,
  p_tav_information14            => p_tav_information14            ,
  p_tav_information15            => p_tav_information15            ,
  p_tav_information16            => p_tav_information16            ,
  p_tav_information17            => p_tav_information17            ,
  p_tav_information18            => p_tav_information18            ,
  p_tav_information19            => p_tav_information19            ,
  p_tav_information20            => p_tav_information20            ,
  p_inventory_item_id            => p_inventory_item_id            ,
  p_organization_id		 => p_organization_id		 ,
  p_rco_id		         => p_rco_id		         ,
  p_version_code                 => p_version_code                 ,
  p_business_group_id            => p_business_group_id            ,
  p_object_version_number        => l_object_version_number        ,
  p_data_source                  => p_data_source
  ,p_competency_update_level      => p_competency_update_level

     );
    exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
          (p_module_name => 'CREATE_ACTIVITY_VERSION'
          ,p_hook_type   => 'BP'
          );
  end;

  --
  -- Process Logic
  --
  ota_tav_ins.ins
  (
  p_validate                     => p_validate                      ,
  p_activity_id                  => p_activity_id                  ,
  p_superseded_by_act_version_id => p_superseded_by_act_version_id ,
  p_developer_organization_id    => p_developer_organization_id    ,
  p_controlling_person_id        => p_controlling_person_id        ,
  p_version_name                 => l_version_name                 ,
  p_comments                     => p_comments                     ,
  p_description                  => p_description                  ,
  p_duration                     => p_duration                     ,
  p_duration_units               => p_duration_units               ,
  p_end_date                     => p_end_date                     ,
  p_intended_audience            => p_intended_audience            ,
  p_language_id                  => p_language_id                  ,
  p_maximum_attendees            => p_maximum_attendees            ,
  p_minimum_attendees            => p_minimum_attendees            ,
  p_objectives                   => p_objectives                   ,
  p_start_date                   => p_start_date                   ,
  p_success_criteria             => p_success_criteria             ,
  p_user_status                  => p_user_status                  ,
  p_vendor_id                    => p_vendor_id                    ,
  p_actual_cost                  => p_actual_cost                  ,
  p_budget_cost                  => p_budget_cost                  ,
  p_budget_currency_code         => p_budget_currency_code         ,
  p_expenses_allowed             => p_expenses_allowed             ,
  p_professional_credit_type     => p_professional_credit_type     ,
  p_professional_credits         => p_professional_credits         ,
  p_maximum_internal_attendees   => p_maximum_internal_attendees   ,
  p_tav_information_category     => p_tav_information_category     ,
  p_tav_information1             => p_tav_information1             ,
  p_tav_information2             => p_tav_information2             ,
  p_tav_information3             => p_tav_information3             ,
  p_tav_information4             => p_tav_information4             ,
  p_tav_information5             => p_tav_information5             ,
  p_tav_information6             => p_tav_information6             ,
  p_tav_information7             => p_tav_information7             ,
  p_tav_information8             => p_tav_information8             ,
  p_tav_information9             => p_tav_information9             ,
  p_tav_information10            => p_tav_information10            ,
  p_tav_information11            => p_tav_information11            ,
  p_tav_information12            => p_tav_information12            ,
  p_tav_information13            => p_tav_information13            ,
  p_tav_information14            => p_tav_information14            ,
  p_tav_information15            => p_tav_information15            ,
  p_tav_information16            => p_tav_information16            ,
  p_tav_information17            => p_tav_information17            ,
  p_tav_information18            => p_tav_information18            ,
  p_tav_information19            => p_tav_information19            ,
  p_tav_information20            => p_tav_information20            ,
  p_inventory_item_id            => p_inventory_item_id            ,
  p_organization_id		 => p_organization_id		 ,
  p_rco_id		         => p_rco_id		         ,
  p_version_code                 => p_version_code                 ,
  p_business_group_id            => p_business_group_id            ,
  p_activity_version_id          => l_activity_version_id          ,
  p_object_version_number        => l_object_version_number        ,
  p_data_source                  => p_data_source
,p_competency_update_level      => p_competency_update_level       ,
  p_eres_enabled                 => p_eres_enabled

  );
  --
  -- Set all output arguments
  --
  p_activity_version_id        := l_activity_version_id;
  p_object_version_number   := l_object_version_number;
  ota_avt_ins.ins_tl
    (p_effective_date        => l_effective_date
    ,p_language_code         => USERENV('LANG')
    ,p_activity_version_id   => p_activity_version_id
    ,p_version_name          => l_version_name
    ,p_description           => p_description
    ,p_intended_audience     => p_intended_audience
    ,p_objectives            => p_objectives
    ,p_keywords              => p_keywords
  );



  --
  --
  begin
        ota_activity_version_bk1.create_activity_version_a
      (
    p_effective_date        =>      l_effective_date    ,
    p_activity_id                  => p_activity_id                  ,
    p_superseded_by_act_version_id => p_superseded_by_act_version_id ,
    p_developer_organization_id    => p_developer_organization_id    ,
    p_controlling_person_id        => p_controlling_person_id        ,
    p_version_name                 => l_version_name                 ,
    p_comments                     => p_comments                     ,
    p_description                  => p_description                  ,
    p_duration                     => p_duration                     ,
    p_duration_units               => p_duration_units               ,
    p_end_date                     => p_end_date                     ,
    p_intended_audience            => p_intended_audience            ,
    p_language_id                  => p_language_id                  ,
    p_maximum_attendees            => p_maximum_attendees            ,
    p_minimum_attendees            => p_minimum_attendees            ,
    p_objectives                   => p_objectives                   ,
    p_start_date                   => p_start_date                   ,
    p_success_criteria             => p_success_criteria             ,
    p_user_status                  => p_user_status                  ,
    p_vendor_id                    => p_vendor_id                    ,
    p_actual_cost                  => p_actual_cost                  ,
    p_budget_cost                  => p_budget_cost                  ,
    p_budget_currency_code         => p_budget_currency_code         ,
    p_expenses_allowed             => p_expenses_allowed             ,
    p_professional_credit_type     => p_professional_credit_type     ,
    p_professional_credits         => p_professional_credits         ,
    p_maximum_internal_attendees   => p_maximum_internal_attendees   ,
    p_tav_information_category     => p_tav_information_category     ,
    p_tav_information1             => p_tav_information1             ,
    p_tav_information2             => p_tav_information2             ,
    p_tav_information3             => p_tav_information3             ,
    p_tav_information4             => p_tav_information4             ,
    p_tav_information5             => p_tav_information5             ,
    p_tav_information6             => p_tav_information6             ,
    p_tav_information7             => p_tav_information7             ,
    p_tav_information8             => p_tav_information8             ,
    p_tav_information9             => p_tav_information9             ,
    p_tav_information10            => p_tav_information10            ,
    p_tav_information11            => p_tav_information11            ,
    p_tav_information12            => p_tav_information12            ,
    p_tav_information13            => p_tav_information13            ,
    p_tav_information14            => p_tav_information14            ,
    p_tav_information15            => p_tav_information15            ,
    p_tav_information16            => p_tav_information16            ,
    p_tav_information17            => p_tav_information17            ,
    p_tav_information18            => p_tav_information18            ,
    p_tav_information19            => p_tav_information19            ,
    p_tav_information20            => p_tav_information20            ,
    p_inventory_item_id            => p_inventory_item_id            ,
    p_organization_id		 => p_organization_id		 ,
    p_rco_id		         => p_rco_id		         ,
    p_version_code                 => p_version_code                 ,
    p_business_group_id            => p_business_group_id            ,
    p_object_version_number        => l_object_version_number        ,
    p_activity_version_id          => l_activity_version_id,
    p_data_source                  => p_data_source
,p_competency_update_level      => p_competency_update_level

       );
      exception
        when hr_api.cannot_find_prog_unit then
          hr_api.cannot_find_prog_unit_error
            (p_module_name => 'CREATE_ACTIVITY_VERSION'
            ,p_hook_type   => 'AP'
            );
    end;

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;

  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_ACTIVITY_VERSION;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_activity_version_id := null;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_ACTIVITY_VERSION;
    p_activity_version_id     := null;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_activity_version;
-- ----------------------------------------------------------------------------
-- |-------------------------< UPDATE_ACTIVITY_VERSION >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_activity_version
  (
  p_effective_date               in date  ,
  p_activity_version_id          in number,
  p_activity_id                  in number           ,
  p_superseded_by_act_version_id in number           ,
  p_developer_organization_id    in number           ,
  p_controlling_person_id        in number           ,
  p_object_version_number        in out nocopy number,
  p_version_name                 in varchar2       ,
  p_comments                     in varchar2         ,
  p_description                  in varchar2         ,
  p_duration                     in number           ,
  p_duration_units               in varchar2         ,
  p_end_date                     in date             ,
  p_intended_audience            in varchar2         ,
  p_language_id                  in number           ,
  p_maximum_attendees            in number           ,
  p_minimum_attendees            in number           ,
  p_objectives                   in varchar2         ,
  p_start_date                   in date             ,
  p_success_criteria             in varchar2         ,
  p_user_status                  in varchar2         ,
  p_vendor_id                  in number            ,
  p_actual_cost                in number            ,
  p_budget_cost                in number            ,
  p_budget_currency_code       in varchar2         ,
  p_expenses_allowed           in varchar2         ,
  p_professional_credit_type   in varchar2         ,
  p_professional_credits       in number           ,
  p_maximum_internal_attendees in number           ,
  p_tav_information_category     in varchar2       ,
  p_tav_information1             in varchar2       ,
  p_tav_information2             in varchar2       ,
  p_tav_information3             in varchar2       ,
  p_tav_information4             in varchar2       ,
  p_tav_information5             in varchar2       ,
  p_tav_information6             in varchar2       ,
  p_tav_information7             in varchar2       ,
  p_tav_information8             in varchar2       ,
  p_tav_information9             in varchar2       ,
  p_tav_information10            in varchar2       ,
  p_tav_information11            in varchar2       ,
  p_tav_information12            in varchar2       ,
  p_tav_information13            in varchar2       ,
  p_tav_information14            in varchar2       ,
  p_tav_information15            in varchar2       ,
  p_tav_information16            in varchar2       ,
  p_tav_information17            in varchar2       ,
  p_tav_information18            in varchar2         ,
  p_tav_information19            in varchar2         ,
  p_tav_information20            in varchar2         ,
  p_inventory_item_id		   in number	     ,
  p_organization_id		   in number 	     ,
  p_rco_id		   		   in number 	  ,
  p_version_code                 in varchar2       ,
  p_keywords                     in varchar2       ,
  p_business_group_id            in number         ,
  p_validate                     in boolean        ,
  p_data_source                  in varchar2
,p_competency_update_level        in     varchar2  ,
  p_eres_enabled                 in varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                    varchar2(72) := g_package||' Update Activity Version';
  l_object_version_number   number := p_object_version_number;
  l_effective_date date;
  l_version_name ota_activity_versions_tl.version_name%type;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_ACTIVITY_VERSION;
  l_effective_date := trunc(p_effective_date);
  l_version_name := rtrim(p_version_name);
  --
  --
  begin
          ota_activity_version_bk2.update_activity_version_b
        (
        p_effective_date        =>      l_effective_date    ,
      p_activity_id                  => p_activity_id                  ,
      p_superseded_by_act_version_id => p_superseded_by_act_version_id ,
      p_developer_organization_id    => p_developer_organization_id    ,
      p_controlling_person_id        => p_controlling_person_id        ,
      p_version_name                 => l_version_name                 ,
      p_comments                     => p_comments                     ,
      p_description                  => p_description                  ,
      p_duration                     => p_duration                     ,
      p_duration_units               => p_duration_units               ,
      p_end_date                     => p_end_date                     ,
      p_intended_audience            => p_intended_audience            ,
      p_language_id                  => p_language_id                  ,
      p_maximum_attendees            => p_maximum_attendees            ,
      p_minimum_attendees            => p_minimum_attendees            ,
      p_objectives                   => p_objectives                   ,
      p_start_date                   => p_start_date                   ,
      p_success_criteria             => p_success_criteria             ,
      p_user_status                  => p_user_status                  ,
      p_vendor_id                    => p_vendor_id                    ,
      p_actual_cost                  => p_actual_cost                  ,
      p_budget_cost                  => p_budget_cost                  ,
      p_budget_currency_code         => p_budget_currency_code         ,
      p_expenses_allowed             => p_expenses_allowed             ,
      p_professional_credit_type     => p_professional_credit_type     ,
      p_professional_credits         => p_professional_credits         ,
      p_maximum_internal_attendees   => p_maximum_internal_attendees   ,
      p_tav_information_category     => p_tav_information_category     ,
      p_tav_information1             => p_tav_information1             ,
      p_tav_information2             => p_tav_information2             ,
      p_tav_information3             => p_tav_information3             ,
      p_tav_information4             => p_tav_information4             ,
      p_tav_information5             => p_tav_information5             ,
      p_tav_information6             => p_tav_information6             ,
      p_tav_information7             => p_tav_information7             ,
      p_tav_information8             => p_tav_information8             ,
      p_tav_information9             => p_tav_information9             ,
      p_tav_information10            => p_tav_information10            ,
      p_tav_information11            => p_tav_information11            ,
      p_tav_information12            => p_tav_information12            ,
      p_tav_information13            => p_tav_information13            ,
      p_tav_information14            => p_tav_information14            ,
      p_tav_information15            => p_tav_information15            ,
      p_tav_information16            => p_tav_information16            ,
      p_tav_information17            => p_tav_information17            ,
      p_tav_information18            => p_tav_information18            ,
      p_tav_information19            => p_tav_information19            ,
      p_tav_information20            => p_tav_information20            ,
      p_inventory_item_id            => p_inventory_item_id            ,
      p_organization_id		 => p_organization_id		 ,
      p_rco_id		         => p_rco_id		         ,
      p_version_code                 => p_version_code                 ,
      p_business_group_id            => p_business_group_id            ,
      p_object_version_number        => l_object_version_number        ,
      p_activity_version_id          => p_activity_version_id,
      p_data_source                  => p_data_source
,p_competency_update_level      => p_competency_update_level

         );
        exception
          when hr_api.cannot_find_prog_unit then
            hr_api.cannot_find_prog_unit_error
              (p_module_name => 'UPDATE_ACTIVITY_VERSION'
              ,p_hook_type   => 'BP'
              );
      end;

  --
  -- Process Logic
  --
  ota_tav_upd.upd
  (
  p_activity_version_id         => p_activity_version_id          ,
  p_activity_id                 => p_activity_id                             ,
  p_superseded_by_act_version_id => p_superseded_by_act_version_id            ,
  p_developer_organization_id   => p_developer_organization_id               ,
  p_controlling_person_id       => p_controlling_person_id                   ,
  p_object_version_number       => p_object_version_number        ,
  p_version_name                => l_version_name                 ,
  p_comments                    => p_comments                     ,
  p_description                 => p_description                  ,
  p_duration                    => p_duration                     ,
  p_duration_units              => p_duration_units               ,
  p_end_date                    => p_end_date                     ,
  p_intended_audience           => p_intended_audience            ,
  p_language_id                 => p_language_id                  ,
  p_maximum_attendees           => p_maximum_attendees            ,
  p_minimum_attendees           => p_minimum_attendees            ,
  p_objectives                  => p_objectives                   ,
  p_start_date                  => p_start_date                   ,
  p_success_criteria            => p_success_criteria             ,
  p_user_status                 => p_user_status                  ,
  p_vendor_id                   => p_vendor_id                    ,
  p_actual_cost                 => p_actual_cost                  ,
  p_budget_cost                 => p_budget_cost                  ,
  p_budget_currency_code        => p_budget_currency_code        ,
  p_expenses_allowed            => p_expenses_allowed            ,
  p_professional_credit_type    => p_professional_credit_type    ,
  p_professional_credits        => p_professional_credits        ,
  p_maximum_internal_attendees  => p_maximum_internal_attendees  ,
  p_tav_information_category    => p_tav_information_category    ,
  p_tav_information1            => p_tav_information1            ,
  p_tav_information2            => p_tav_information2            ,
  p_tav_information3            => p_tav_information3            ,
  p_tav_information4            => p_tav_information4            ,
  p_tav_information5            => p_tav_information5            ,
  p_tav_information6            => p_tav_information6            ,
  p_tav_information7            => p_tav_information7            ,
  p_tav_information8            => p_tav_information8            ,
  p_tav_information9            => p_tav_information9            ,
  p_tav_information10           => p_tav_information10           ,
  p_tav_information11           => p_tav_information11           ,
  p_tav_information12           => p_tav_information12           ,
  p_tav_information13           => p_tav_information13           ,
  p_tav_information14           => p_tav_information14           ,
  p_tav_information15           => p_tav_information15           ,
  p_tav_information16           => p_tav_information16           ,
  p_tav_information17           => p_tav_information17           ,
  p_tav_information18           => p_tav_information18           ,
  p_tav_information19           => p_tav_information19           ,
  p_tav_information20           => p_tav_information20           ,
  p_inventory_item_id		=> p_inventory_item_id		,
  p_organization_id		=> p_organization_id		,
  p_rco_id		   	=> p_rco_id		   	,
  p_version_code                => p_version_code                ,
  p_business_group_id           => p_business_group_id           ,
  p_validate                   	=> p_validate                    ,
  p_data_source                 => p_data_source
  ,p_competency_update_level      => p_competency_update_level   ,
  p_eres_enabled                => p_eres_enabled

  );
  ota_avt_upd.upd_tl
    (p_effective_date        => l_effective_date
    ,p_language_code         => USERENV('LANG')
    ,p_activity_version_id   => p_activity_version_id
    ,p_version_name          => l_version_name
    ,p_description           => p_description
    ,p_intended_audience     => p_intended_audience
    ,p_objectives            => p_objectives
    ,p_keywords              => p_keywords
  );

  --
  --
  begin
            ota_activity_version_bk2.update_activity_version_a
          (
          p_effective_date        =>      l_effective_date    ,
        p_activity_id                  => p_activity_id                  ,
        p_superseded_by_act_version_id => p_superseded_by_act_version_id ,
        p_developer_organization_id    => p_developer_organization_id    ,
        p_controlling_person_id        => p_controlling_person_id        ,
        p_version_name                 => l_version_name                 ,
        p_comments                     => p_comments                     ,
        p_description                  => p_description                  ,
        p_duration                     => p_duration                     ,
        p_duration_units               => p_duration_units               ,
        p_end_date                     => p_end_date                     ,
        p_intended_audience            => p_intended_audience            ,
        p_language_id                  => p_language_id                  ,
        p_maximum_attendees            => p_maximum_attendees            ,
        p_minimum_attendees            => p_minimum_attendees            ,
        p_objectives                   => p_objectives                   ,
        p_start_date                   => p_start_date                   ,
        p_success_criteria             => p_success_criteria             ,
        p_user_status                  => p_user_status                  ,
        p_vendor_id                    => p_vendor_id                    ,
        p_actual_cost                  => p_actual_cost                  ,
        p_budget_cost                  => p_budget_cost                  ,
        p_budget_currency_code         => p_budget_currency_code         ,
        p_expenses_allowed             => p_expenses_allowed             ,
        p_professional_credit_type     => p_professional_credit_type     ,
        p_professional_credits         => p_professional_credits         ,
        p_maximum_internal_attendees   => p_maximum_internal_attendees   ,
        p_tav_information_category     => p_tav_information_category     ,
        p_tav_information1             => p_tav_information1             ,
        p_tav_information2             => p_tav_information2             ,
        p_tav_information3             => p_tav_information3             ,
        p_tav_information4             => p_tav_information4             ,
        p_tav_information5             => p_tav_information5             ,
        p_tav_information6             => p_tav_information6             ,
        p_tav_information7             => p_tav_information7             ,
        p_tav_information8             => p_tav_information8             ,
        p_tav_information9             => p_tav_information9             ,
        p_tav_information10            => p_tav_information10            ,
        p_tav_information11            => p_tav_information11            ,
        p_tav_information12            => p_tav_information12            ,
        p_tav_information13            => p_tav_information13            ,
        p_tav_information14            => p_tav_information14            ,
        p_tav_information15            => p_tav_information15            ,
        p_tav_information16            => p_tav_information16            ,
        p_tav_information17            => p_tav_information17            ,
        p_tav_information18            => p_tav_information18            ,
        p_tav_information19            => p_tav_information19            ,
        p_tav_information20            => p_tav_information20            ,
        p_inventory_item_id            => p_inventory_item_id            ,
        p_organization_id		 => p_organization_id		 ,
        p_rco_id		         => p_rco_id		         ,
        p_version_code                 => p_version_code                 ,
        p_business_group_id            => p_business_group_id            ,
        p_object_version_number        => l_object_version_number        ,
        p_activity_version_id          => p_activity_version_id,
        p_data_source                  => p_data_source
	,p_competency_update_level      => p_competency_update_level


           );
          exception
            when hr_api.cannot_find_prog_unit then
              hr_api.cannot_find_prog_unit_error
                (p_module_name => 'UPDATE_ACTIVITY_VERSION'
                ,p_hook_type   => 'AP'
                );
        end;

  --
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
    rollback to UPDATE_ACTIVITY_VERSION;
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
    rollback to UPDATE_ACTIVITY_VERSION;
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_activity_version;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< DELETE_ACTIVITY_VERSION >-------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_activity_version
  (
  p_activity_version_id                in number,
  p_object_version_number              in number,
  p_validate                           in boolean
  ) is
  --
  -- Declare cursors and local variables
  --

  CURSOR cur_act_cat is
    select
      aci.category_usage_id,
      aci.primary_flag,
      aci.activity_category,
      aci.object_version_number
    From
      ota_act_cat_inclusions  aci
    where
      aci.activity_version_id = p_activity_version_id;
  CURSOR c_prereq_courses is
    select
      cpr.activity_version_id,
      cpr.prerequisite_course_id,
      cpr.object_version_number
    From
      ota_course_prerequisites cpr
    where
      cpr.activity_version_id = p_activity_version_id
      or cpr.prerequisite_course_id = p_activity_version_id;
  --

  --
  l_proc  varchar2(72) := g_package||' Delete Activity Version';
  l_tmp_ovn   ota_act_cat_inclusions.object_version_number%type;
  --
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_ACTIVITY_VERSION;
  --
  -- Truncate the time portion from all IN date parameters
  --
  begin
    ota_activity_version_bk3.delete_activity_version_b
     (p_activity_version_id      => p_activity_version_id
     ,p_object_version_number    => p_object_version_number
    );
  exception
              when hr_api.cannot_find_prog_unit then
                hr_api.cannot_find_prog_unit_error
                  (p_module_name => 'DELETE_ACTIVITY_VERSION'
                  ,p_hook_type   => 'BP'
                );
  end   ;
  --
  -- Process Logic
  --
  ota_tav_shd.lck
  (p_activity_version_id      => p_activity_version_id
  ,p_object_version_number    => p_object_version_number
  );

  --OPEN cur_act_cat;
  FOR act_cat in cur_act_cat
   LOOP
     l_tmp_ovn := act_cat.object_version_number;

     IF act_cat.primary_flag = 'Y' THEN
       ota_activity_category_api.update_act_cat_inclusion
       (p_validate => false
       ,p_effective_date => sysdate
       ,p_category_usage_id  => act_cat.category_usage_id
       ,p_activity_version_id => p_activity_version_id
       ,p_primary_flag       => 'N'
       ,p_activity_category  => act_cat.activity_category
       ,p_object_version_number    => l_tmp_ovn
       );
     END IF;
     ota_activity_category_api.delete_act_cat_inclusion
     (p_category_usage_id  => act_cat.category_usage_id
     ,p_activity_version_id => p_activity_version_id
     ,p_object_version_number    => l_tmp_ovn
     );

  END LOOP;

--Delete the prereq courses
FOR prereq_courses in c_prereq_courses
 LOOP
     ota_course_prerequisite_api.delete_course_prerequisite
     (p_activity_version_id        => prereq_courses.activity_version_id
     ,p_prerequisite_course_id     => prereq_courses.prerequisite_course_id
     ,p_object_version_number      => prereq_courses.object_version_number);
 END LOOP;

  ota_avt_del.del_tl
    (p_activity_version_id => p_activity_version_id
    );
  ota_tav_del.del
  (
  p_activity_version_id      => p_activity_version_id             ,
  p_object_version_number    => p_object_version_number           ,
  p_validate                 => p_validate
  );

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --

  begin
      ota_activity_version_bk3.delete_activity_version_a
       (p_activity_version_id      => p_activity_version_id             ,
        p_object_version_number    => p_object_version_number
      );
    exception
                when hr_api.cannot_find_prog_unit then
                  hr_api.cannot_find_prog_unit_error
                    (p_module_name => 'DELETE_ACTIVITY_VERSION'
                    ,p_hook_type   => 'AP'
                );
   end;
  --
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
    rollback to DELETE_ACTIVITY_VERSION;
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
    rollback to DELETE_ACTIVITY_VERSION;
    hr_utility.set_location(' Leaving:'||l_proc, 190);
    raise;
end delete_activity_version;
--
end ota_activity_version_api;


/
