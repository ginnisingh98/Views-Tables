--------------------------------------------------------
--  DDL for Package Body HR_TAB_PAGE_PROPERTIES_BSI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_TAB_PAGE_PROPERTIES_BSI" as
/* $Header: hrtppbsi.pkb 120.0 2005/05/31 03:24:32 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_tab_page_properties_bsi.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_tab_page_property >--------------------|
-- ----------------------------------------------------------------------------
--
procedure create_tab_page_property
  (p_validate                        in     boolean  default false
  ,p_effective_date                  in     date
  ,p_language_code                   in varchar2 default hr_api.userenv_lang
  ,p_form_tab_page_id                in number default null
  ,p_template_tab_page_id            in number default null
  ,p_label                           in varchar2 default null
  ,p_navigation_direction            in varchar2 default null
  ,p_visible                         in number default null
  ,p_information_category            in varchar2 default null
  ,p_information1                    in varchar2 default null
  ,p_information2                    in varchar2 default null
  ,p_information3                    in varchar2 default null
  ,p_information4                    in varchar2 default null
  ,p_information5                    in varchar2 default null
  ,p_information6                    in varchar2 default null
  ,p_information7                    in varchar2 default null
  ,p_information8                    in varchar2 default null
  ,p_information9                    in varchar2 default null
  ,p_information10                   in varchar2 default null
  ,p_information11                   in varchar2 default null
  ,p_information12                   in varchar2 default null
  ,p_information13                   in varchar2 default null
  ,p_information14                   in varchar2 default null
  ,p_information15                   in varchar2 default null
  ,p_information16                   in varchar2 default null
  ,p_information17                   in varchar2 default null
  ,p_information18                   in varchar2 default null
  ,p_information19                   in varchar2 default null
  ,p_information20                   in varchar2 default null
  ,p_information21                   in varchar2 default null
  ,p_information22                   in varchar2 default null
  ,p_information23                   in varchar2 default null
  ,p_information24                   in varchar2 default null
  ,p_information25                   in varchar2 default null
  ,p_information26                   in varchar2 default null
  ,p_information27                   in varchar2 default null
  ,p_information28                   in varchar2 default null
  ,p_information29                   in varchar2 default null
  ,p_information30                   in varchar2 default null
  ,p_tab_page_property_id              out nocopy number
  ,p_object_version_number             out nocopy number
  --,p_override_value_warning            out boolean
  ) is
  --
  -- Declare cursors and local variables
  --

  l_language_code fnd_languages.language_code%TYPE;

  l_tab_page_property_id               number;
  l_object_version_number              number;
  l_override_value_warning            boolean;
  l_proc                varchar2(72) := g_package||'create_tab_page_property';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_tab_page_property;

  --
  -- Validate the language parameter. l_language_code should be passed
  -- instead of p_language_code from now on, to allow an IN OUT parameter to
  -- be passed through.
  --
  l_language_code := p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);
  --
  hr_utility.set_location(l_proc, 20);
  --
  --
  -- Process Logic
  --
  hr_tpp_ins.ins(p_effective_date           => TRUNC(p_effective_date)
            ,p_form_tab_page_id             => p_form_tab_page_id
            ,p_template_tab_page_id         => p_template_tab_page_id
            ,p_navigation_direction         => p_navigation_direction
            ,p_visible                      => p_visible
            ,p_information_category         => p_information_category
            ,p_information1                 => p_information1
            ,p_information2                 => p_information2
            ,p_information3                 => p_information3
            ,p_information4                 => p_information4
            ,p_information5                 => p_information5
            ,p_information6                 => p_information6
            ,p_information7                 => p_information7
            ,p_information8                 => p_information8
            ,p_information9                 => p_information9
            ,p_information10                => p_information10
            ,p_information11                => p_information11
            ,p_information12                => p_information12
            ,p_information13                => p_information13
            ,p_information14                => p_information14
            ,p_information15                => p_information15
            ,p_information16                => p_information16
            ,p_information17                => p_information17
            ,p_information18                => p_information18
            ,p_information19                => p_information19
            ,p_information20                => p_information20
            ,p_information21                => p_information21
            ,p_information22                => p_information22
            ,p_information23                => p_information23
            ,p_information24                => p_information24
            ,p_information25                => p_information25
            ,p_information26                => p_information26
            ,p_information27                => p_information27
            ,p_information28                => p_information28
            ,p_information29                => p_information29
            ,p_information30                => p_information30
            ,p_tab_page_property_id         => l_tab_page_property_id
            ,p_object_version_number        => l_object_version_number);
            --,p_override_value_warning       => l_override_value_warning);

  hr_tpt_ins.ins_tl(p_language_code                => l_language_code
            ,p_tab_page_property_id         => l_tab_page_property_id
            ,p_label                        => p_label);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_tab_page_property_id         := l_tab_page_property_id;
  p_object_version_number        := l_object_version_number;
  --p_override_value_warning       := l_override_value_warning;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_tab_page_property;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_tab_page_property_id         := null;
    --p_override_value_warning       := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_tab_page_property;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_tab_page_property;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_tab_page_property >--------------------|
-- ----------------------------------------------------------------------------
--
procedure update_tab_page_property
  (p_validate                        in     boolean  default false
  ,p_effective_date                  in     date
  ,p_object_version_number           in out nocopy number
  ,p_language_code                   in varchar2 default hr_api.userenv_lang
  ,p_tab_page_property_id            in number default null
  ,p_form_tab_page_id                in number default null
  ,p_template_tab_page_id            in number default null
  ,p_label                           in varchar2 default hr_api.g_varchar2
  ,p_navigation_direction            in varchar2 default hr_api.g_varchar2
  ,p_visible                         in number default hr_api.g_number
  ,p_information_category            in varchar2 default hr_api.g_varchar2
  ,p_information1                    in varchar2 default hr_api.g_varchar2
  ,p_information2                    in varchar2 default hr_api.g_varchar2
  ,p_information3                    in varchar2 default hr_api.g_varchar2
  ,p_information4                    in varchar2 default hr_api.g_varchar2
  ,p_information5                    in varchar2 default hr_api.g_varchar2
  ,p_information6                    in varchar2 default hr_api.g_varchar2
  ,p_information7                    in varchar2 default hr_api.g_varchar2
  ,p_information8                    in varchar2 default hr_api.g_varchar2
  ,p_information9                    in varchar2 default hr_api.g_varchar2
  ,p_information10                   in varchar2 default hr_api.g_varchar2
  ,p_information11                   in varchar2 default hr_api.g_varchar2
  ,p_information12                   in varchar2 default hr_api.g_varchar2
  ,p_information13                   in varchar2 default hr_api.g_varchar2
  ,p_information14                   in varchar2 default hr_api.g_varchar2
  ,p_information15                   in varchar2 default hr_api.g_varchar2
  ,p_information16                   in varchar2 default hr_api.g_varchar2
  ,p_information17                   in varchar2 default hr_api.g_varchar2
  ,p_information18                   in varchar2 default hr_api.g_varchar2
  ,p_information19                   in varchar2 default hr_api.g_varchar2
  ,p_information20                   in varchar2 default hr_api.g_varchar2
  ,p_information21                   in varchar2 default hr_api.g_varchar2
  ,p_information22                   in varchar2 default hr_api.g_varchar2
  ,p_information23                   in varchar2 default hr_api.g_varchar2
  ,p_information24                   in varchar2 default hr_api.g_varchar2
  ,p_information25                   in varchar2 default hr_api.g_varchar2
  ,p_information26                   in varchar2 default hr_api.g_varchar2
  ,p_information27                   in varchar2 default hr_api.g_varchar2
  ,p_information28                   in varchar2 default hr_api.g_varchar2
  ,p_information29                   in varchar2 default hr_api.g_varchar2
  ,p_information30                   in varchar2 default hr_api.g_varchar2
  --,p_override_value_warning            out boolean
  ) is
  --
  -- Declare cursors and local variables
  --
  CURSOR cur_tab_prop_1
  IS
  SELECT tab_page_property_id
  FROM hr_tab_page_properties_b
  WHERE form_tab_page_id = p_form_tab_page_id;

  CURSOR cur_tab_prop_2
  IS
  SELECT tab_page_property_id
  FROM hr_tab_page_properties_b
  WHERE template_tab_page_id = p_template_tab_page_id;

  l_tab_page_property number;
  l_language_code fnd_languages.language_code%TYPE;


  l_tab_page_property_id number;
  l_override_value_warning             boolean;
  l_proc                varchar2(72) := g_package||'update_tab_page_property';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_tab_page_property;
  --
  -- Validate the language parameter. l_language_code should be passed
  -- instead of p_language_code from now on, to allow an IN OUT parameter to
  -- be passed through.
  --
  l_language_code := p_language_code;

  hr_api.validate_language_code(p_language_code => l_language_code);
  --
  hr_utility.set_location(l_proc, 20);
  --
  --
  -- Validation in addition to Row Handlers
  --
  IF ( p_tab_page_property_id is not null) AND
     (p_form_tab_page_id is not null OR p_template_tab_page_id is not null) THEN
    -- error message
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ELSIF ( p_form_tab_page_id is not null) AND
    (p_tab_page_property_id is not null OR
     p_template_tab_page_id is not null) THEN
    -- error message
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ELSIF ( p_template_tab_page_id is not null) AND
   (p_tab_page_property_id is not null OR p_form_tab_page_id is not null) THEN
    -- error message
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  END IF;

  --
  -- Process Logic
  --

  l_tab_page_property_id := p_tab_page_property_id;

  IF p_form_tab_page_id is not null THEN
     OPEN cur_tab_prop_1;
     FETCH cur_tab_prop_1 INTO l_tab_page_property_id;
     CLOSE cur_tab_prop_1;
  END IF;

  IF p_template_tab_page_id is not null THEN
     OPEN cur_tab_prop_2;
     FETCH cur_tab_prop_2 INTO l_tab_page_property_id;
     CLOSE cur_tab_prop_2;
  END IF;

  hr_tpp_upd.upd(p_effective_date           => TRUNC(p_effective_date)
            ,p_tab_page_property_id         => l_tab_page_property_id
            ,p_navigation_direction         => p_navigation_direction
            ,p_visible                      => p_visible
            ,p_information_category         => p_information_category
            ,p_information1                 => p_information1
            ,p_information2                 => p_information2
            ,p_information3                 => p_information3
            ,p_information4                 => p_information4
            ,p_information5                 => p_information5
            ,p_information6                 => p_information6
            ,p_information7                 => p_information7
            ,p_information8                 => p_information8
            ,p_information9                 => p_information9
            ,p_information10                => p_information10
            ,p_information11                => p_information11
            ,p_information12                => p_information12
            ,p_information13                => p_information13
            ,p_information14                => p_information14
            ,p_information15                => p_information15
            ,p_information16                => p_information16
            ,p_information17                => p_information17
            ,p_information18                => p_information18
            ,p_information19                => p_information19
            ,p_information20                => p_information20
            ,p_information21                => p_information21
            ,p_information22                => p_information22
            ,p_information23                => p_information23
            ,p_information24                => p_information24
            ,p_information25                => p_information25
            ,p_information26                => p_information26
            ,p_information27                => p_information27
            ,p_information28                => p_information28
            ,p_information29                => p_information29
            ,p_information30                => p_information30
            ,p_object_version_number        => p_object_version_number);
            --,p_override_value_warning       => l_override_value_warning);

  hr_tpt_upd.upd_tl(p_language_code                => l_language_code
            ,p_tab_page_property_id         => l_tab_page_property_id
            ,p_label                        => p_label);
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
  --p_override_value_warning       := l_override_value_warning;
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_tab_page_property;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    --p_override_value_warning       := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_tab_page_property;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_tab_page_property;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_tab_page_property >--------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_tab_page_property
  (p_validate                      in     boolean  default false
  ,p_tab_page_property_id            in number default null
  ,p_form_tab_page_id                in number default null
  ,p_template_tab_page_id            in number default null
  ,p_object_version_number           in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  CURSOR cur_tab_prop_1
  IS
  SELECT tab_page_property_id
  FROM hr_tab_page_properties_b
  WHERE form_tab_page_id = p_form_tab_page_id;

  CURSOR cur_tab_prop_2
  IS
  SELECT tab_page_property_id
  FROM hr_tab_page_properties_b
  WHERE template_tab_page_id = p_template_tab_page_id;

  l_tab_page_property number;
  l_tab_page_property_id number;

  l_proc                varchar2(72) := g_package||'delete_tab_page_property';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_tab_page_property;
  --
  -- Validation in addition to Row Handlers
  --
  IF ( p_tab_page_property_id is not null) AND
     (p_form_tab_page_id is not null OR p_template_tab_page_id is not null) THEN
    -- error message
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ELSIF ( p_form_tab_page_id is not null) AND
    (p_tab_page_property_id is not null OR
     p_template_tab_page_id is not null) THEN
    -- error message
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ELSIF ( p_template_tab_page_id is not null) AND
   (p_tab_page_property_id is not null OR p_form_tab_page_id is not null) THEN
    -- error message
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  END IF;

  --
  -- Process Logic
  --

  l_tab_page_property_id := p_tab_page_property_id;

  IF p_form_tab_page_id is not null THEN
     OPEN cur_tab_prop_1;
     FETCH cur_tab_prop_1 INTO l_tab_page_property_id;
     CLOSE cur_tab_prop_1;
  END IF;

  IF p_template_tab_page_id is not null THEN
     OPEN cur_tab_prop_2;
     FETCH cur_tab_prop_2 INTO l_tab_page_property_id;
     CLOSE cur_tab_prop_2;
  END IF;

  if l_tab_page_property_id is not null then     --Added if condition for Bug 4072087
  hr_tpp_shd.lck( p_tab_page_property_id         => l_tab_page_property_id
                  ,p_object_version_number       => p_object_version_number );

  hr_tpt_del.del_tl(p_tab_page_property_id         => l_tab_page_property_id);

  hr_tpp_del.del( p_tab_page_property_id         => l_tab_page_property_id
                  ,p_object_version_number       => p_object_version_number );

  end if;

  --
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
    rollback to delete_tab_page_property;
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
    rollback to delete_tab_page_property;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_tab_page_property;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< copy_tab_page_property >----------------------|
-- ----------------------------------------------------------------------------
--
procedure copy_tab_page_property
  (p_validate                        in     boolean  default false
  ,p_effective_date                  in     date
  ,p_language_code                   in varchar2 default hr_api.userenv_lang
  ,p_form_tab_page_id                in number
  ,p_template_tab_page_id            in number
  ,p_label                           in varchar2 default hr_api.g_varchar2
  ,p_navigation_direction            in varchar2 default hr_api.g_varchar2
  ,p_visible                         in number default hr_api.g_number
  ,p_information_category            in varchar2 default hr_api.g_varchar2
  ,p_information1                    in varchar2 default hr_api.g_varchar2
  ,p_information2                    in varchar2 default hr_api.g_varchar2
  ,p_information3                    in varchar2 default hr_api.g_varchar2
  ,p_information4                    in varchar2 default hr_api.g_varchar2
  ,p_information5                    in varchar2 default hr_api.g_varchar2
  ,p_information6                    in varchar2 default hr_api.g_varchar2
  ,p_information7                    in varchar2 default hr_api.g_varchar2
  ,p_information8                    in varchar2 default hr_api.g_varchar2
  ,p_information9                    in varchar2 default hr_api.g_varchar2
  ,p_information10                   in varchar2 default hr_api.g_varchar2
  ,p_information11                   in varchar2 default hr_api.g_varchar2
  ,p_information12                   in varchar2 default hr_api.g_varchar2
  ,p_information13                   in varchar2 default hr_api.g_varchar2
  ,p_information14                   in varchar2 default hr_api.g_varchar2
  ,p_information15                   in varchar2 default hr_api.g_varchar2
  ,p_information16                   in varchar2 default hr_api.g_varchar2
  ,p_information17                   in varchar2 default hr_api.g_varchar2
  ,p_information18                   in varchar2 default hr_api.g_varchar2
  ,p_information19                   in varchar2 default hr_api.g_varchar2
  ,p_information20                   in varchar2 default hr_api.g_varchar2
  ,p_information21                   in varchar2 default hr_api.g_varchar2
  ,p_information22                   in varchar2 default hr_api.g_varchar2
  ,p_information23                   in varchar2 default hr_api.g_varchar2
  ,p_information24                   in varchar2 default hr_api.g_varchar2
  ,p_information25                   in varchar2 default hr_api.g_varchar2
  ,p_information26                   in varchar2 default hr_api.g_varchar2
  ,p_information27                   in varchar2 default hr_api.g_varchar2
  ,p_information28                   in varchar2 default hr_api.g_varchar2
  ,p_information29                   in varchar2 default hr_api.g_varchar2
  ,p_information30                   in varchar2 default hr_api.g_varchar2
  ,p_tab_page_property_id              out nocopy number
  ,p_object_version_number             out nocopy number
  --,p_override_value_warning            out boolean
  ) is
  --
  -- Declare cursors and local variables
  --
  Type l_rec_type Is Record
  (navigation_direction hr_tab_page_properties_b.navigation_direction%TYPE
  ,visible hr_tab_page_properties_b.visible%TYPE
  ,information_category hr_tab_page_properties_b.information_category%TYPE
  ,information1 hr_tab_page_properties_b.information1%TYPE
  ,information2 hr_tab_page_properties_b.information2%TYPE
  ,information3 hr_tab_page_properties_b.information3%TYPE
  ,information4 hr_tab_page_properties_b.information4%TYPE
  ,information5 hr_tab_page_properties_b.information5%TYPE
  ,information6 hr_tab_page_properties_b.information6%TYPE
  ,information7 hr_tab_page_properties_b.information7%TYPE
  ,information8 hr_tab_page_properties_b.information8%TYPE
  ,information9 hr_tab_page_properties_b.information9%TYPE
  ,information10 hr_tab_page_properties_b.information10%TYPE
  ,information11 hr_tab_page_properties_b.information11%TYPE
  ,information12 hr_tab_page_properties_b.information12%TYPE
  ,information13 hr_tab_page_properties_b.information13%TYPE
  ,information14 hr_tab_page_properties_b.information14%TYPE
  ,information15 hr_tab_page_properties_b.information15%TYPE
  ,information16 hr_tab_page_properties_b.information16%TYPE
  ,information17 hr_tab_page_properties_b.information17%TYPE
  ,information18 hr_tab_page_properties_b.information18%TYPE
  ,information19 hr_tab_page_properties_b.information19%TYPE
  ,information20 hr_tab_page_properties_b.information20%TYPE
  ,information21 hr_tab_page_properties_b.information21%TYPE
  ,information22 hr_tab_page_properties_b.information22%TYPE
  ,information23 hr_tab_page_properties_b.information23%TYPE
  ,information24 hr_tab_page_properties_b.information24%TYPE
  ,information25 hr_tab_page_properties_b.information25%TYPE
  ,information26 hr_tab_page_properties_b.information26%TYPE
  ,information27 hr_tab_page_properties_b.information27%TYPE
  ,information28 hr_tab_page_properties_b.information28%TYPE
  ,information29 hr_tab_page_properties_b.information29%TYPE
  ,information30 hr_tab_page_properties_b.information30%TYPE);

  l_rec l_rec_type;

  CURSOR cur_check
  IS
  SELECT 1
  FROM hr_template_tab_pages ttp
  WHERE ttp.template_tab_page_id = p_template_tab_page_id
  AND ttp.form_tab_page_id = p_form_tab_page_id;

  CURSOR cur_tab_prop
  IS
  SELECT DECODE(p_navigation_direction,hr_api.g_varchar2,tpp.navigation_direction,p_navigation_direction)
  ,DECODE(p_visible,hr_api.g_number,tpp.visible,p_visible)
  ,DECODE(p_information_category,hr_api.g_varchar2,tpp.information_category,p_information_category)
  ,DECODE(p_information1,hr_api.g_varchar2,tpp.information1,p_information1)
  ,DECODE(p_information2,hr_api.g_varchar2,tpp.information2,p_information2)
  ,DECODE(p_information3,hr_api.g_varchar2,tpp.information3,p_information3)
  ,DECODE(p_information4,hr_api.g_varchar2,tpp.information4,p_information4)
  ,DECODE(p_information5,hr_api.g_varchar2,tpp.information5,p_information5)
  ,DECODE(p_information6,hr_api.g_varchar2,tpp.information6,p_information6)
  ,DECODE(p_information7,hr_api.g_varchar2,tpp.information7,p_information7)
  ,DECODE(p_information8,hr_api.g_varchar2,tpp.information8,p_information8)
  ,DECODE(p_information9,hr_api.g_varchar2,tpp.information9,p_information9)
  ,DECODE(p_information10,hr_api.g_varchar2,tpp.information10,p_information10)
  ,DECODE(p_information11,hr_api.g_varchar2,tpp.information11,p_information11)
  ,DECODE(p_information12,hr_api.g_varchar2,tpp.information12,p_information12)
  ,DECODE(p_information13,hr_api.g_varchar2,tpp.information13,p_information13)
  ,DECODE(p_information14,hr_api.g_varchar2,tpp.information14,p_information14)
  ,DECODE(p_information15,hr_api.g_varchar2,tpp.information15,p_information15)
  ,DECODE(p_information16,hr_api.g_varchar2,tpp.information16,p_information16)
  ,DECODE(p_information17,hr_api.g_varchar2,tpp.information17,p_information17)
  ,DECODE(p_information18,hr_api.g_varchar2,tpp.information18,p_information18)
  ,DECODE(p_information19,hr_api.g_varchar2,tpp.information19,p_information19)
  ,DECODE(p_information20,hr_api.g_varchar2,tpp.information20,p_information20)
  ,DECODE(p_information21,hr_api.g_varchar2,tpp.information21,p_information21)
  ,DECODE(p_information22,hr_api.g_varchar2,tpp.information22,p_information22)
  ,DECODE(p_information23,hr_api.g_varchar2,tpp.information23,p_information23)
  ,DECODE(p_information24,hr_api.g_varchar2,tpp.information24,p_information24)
  ,DECODE(p_information25,hr_api.g_varchar2,tpp.information25,p_information25)
  ,DECODE(p_information26,hr_api.g_varchar2,tpp.information26,p_information26)
  ,DECODE(p_information27,hr_api.g_varchar2,tpp.information27,p_information27)
  ,DECODE(p_information28,hr_api.g_varchar2,tpp.information28,p_information28)
  ,DECODE(p_information29,hr_api.g_varchar2,tpp.information29,p_information29)
  ,DECODE(p_information30,hr_api.g_varchar2,tpp.information30,p_information30)
  FROM hr_tab_page_properties_b tpp
  WHERE tpp.form_tab_page_id = p_form_tab_page_id;

  CURSOR cur_tab_tl
  IS
  SELECT COUNT(0)
  ,tpptl.source_lang
  ,DECODE(p_label,hr_api.g_varchar2,tpptl.label,p_label) label
  FROM hr_tab_page_properties_tl tpptl
  ,hr_tab_page_properties_b tpp
  WHERE tpptl.tab_page_property_id = tpp.tab_page_property_id
  AND tpp.form_tab_page_id = p_form_tab_page_id
  GROUP BY tpptl.source_lang
  ,DECODE(p_label,hr_api.g_varchar2,tpptl.label,p_label)
  ORDER BY 1;

  l_check number;
  l_tab_page_property_id               number;
  l_object_version_number              number;
  l_override_value_warning             boolean;
  l_proc                varchar2(72) := g_package||'copy_tab_page_property';
  l_language_code fnd_languages.language_code%TYPE;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint copy_tab_page_property;

  --
  -- Validate the language parameter. l_language_code should be passed
  -- instead of p_language_code from now on, to allow an IN OUT parameter to
  -- be passed through.
  --
  l_language_code := p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);
  --
  hr_utility.set_location(l_proc, 20);
  --
  --
  -- Validation in addition to Row Handlers
  --
  OPEN cur_check;
  FETCH cur_check INTO l_check;
  IF cur_check%NOTFOUND THEN
    CLOSE cur_check;
    -- error message
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  END IF;
  CLOSE cur_check;
  --
  -- Process Logic
  --
  OPEN cur_tab_prop;
  FETCH cur_tab_prop INTO l_rec;
  CLOSE cur_tab_prop;

  hr_tpp_ins.ins(p_effective_date           => TRUNC(p_effective_date)
            ,p_template_tab_page_id         => p_template_tab_page_id
            ,p_navigation_direction         => l_rec.navigation_direction
            ,p_visible                      => l_rec.visible
            ,p_information_category         => l_rec.information_category
            ,p_information1                 => l_rec.information1
            ,p_information2                 => l_rec.information2
            ,p_information3                 => l_rec.information3
            ,p_information4                 => l_rec.information4
            ,p_information5                 => l_rec.information5
            ,p_information6                 => l_rec.information6
            ,p_information7                 => l_rec.information7
            ,p_information8                 => l_rec.information8
            ,p_information9                 => l_rec.information9
            ,p_information10                => l_rec.information10
            ,p_information11                => l_rec.information11
            ,p_information12                => l_rec.information12
            ,p_information13                => l_rec.information13
            ,p_information14                => l_rec.information14
            ,p_information15                => l_rec.information15
            ,p_information16                => l_rec.information16
            ,p_information17                => l_rec.information17
            ,p_information18                => l_rec.information18
            ,p_information19                => l_rec.information19
            ,p_information20                => l_rec.information20
            ,p_information21                => l_rec.information21
            ,p_information22                => l_rec.information22
            ,p_information23                => l_rec.information23
            ,p_information24                => l_rec.information24
            ,p_information25                => l_rec.information25
            ,p_information26                => l_rec.information26
            ,p_information27                => l_rec.information27
            ,p_information28                => l_rec.information28
            ,p_information29                => l_rec.information29
            ,p_information30                => l_rec.information30
            ,p_tab_page_property_id         => l_tab_page_property_id
            ,p_object_version_number        => l_object_version_number);
            --,p_override_value_warning       => l_override_value_warning);

  IF p_label <> hr_api.g_varchar2 THEN

    hr_tpt_ins.ins_tl(p_language_code                => l_language_code
               ,p_tab_page_property_id         => l_tab_page_property_id
               ,p_label                        => p_label);

  ELSE
    FOR cur_rec IN cur_tab_tl LOOP
      IF cur_tab_tl%ROWCOUNT = 1 THEN
        hr_tpt_ins.ins_tl(p_language_code                => cur_rec.source_lang
                  ,p_tab_page_property_id         => l_tab_page_property_id
                  ,p_label                        => cur_rec.label);
      ELSE
        hr_tpt_upd.upd_tl(p_language_code                => cur_rec.source_lang
                  ,p_tab_page_property_id         => l_tab_page_property_id
                  ,p_label                        => cur_rec.label);
      END IF;
    END LOOP;
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
  p_tab_page_property_id         := l_tab_page_property_id;
  p_object_version_number        := l_object_version_number;
  --p_override_value_warning       := l_override_value_warning;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to copy_tab_page_property;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_tab_page_property_id         := null;
    --p_override_value_warning       := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to copy_tab_page_property;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end copy_tab_page_property;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< copy_tab_page_property - overload >-----------|
-- ----------------------------------------------------------------------------
--
procedure copy_tab_page_property
  (p_validate                        in     boolean  default false
  ,p_effective_date                  in     date
  ,p_language_code                   in varchar2 default hr_api.userenv_lang
  ,p_template_tab_page_id_from       in number
  ,p_template_tab_page_id_to         in number
  ,p_label                           in varchar2 default hr_api.g_varchar2
  ,p_navigation_direction            in varchar2 default hr_api.g_varchar2
  ,p_visible                         in number default hr_api.g_number
  ,p_information_category            in varchar2 default hr_api.g_varchar2
  ,p_information1                    in varchar2 default hr_api.g_varchar2
  ,p_information2                    in varchar2 default hr_api.g_varchar2
  ,p_information3                    in varchar2 default hr_api.g_varchar2
  ,p_information4                    in varchar2 default hr_api.g_varchar2
  ,p_information5                    in varchar2 default hr_api.g_varchar2
  ,p_information6                    in varchar2 default hr_api.g_varchar2
  ,p_information7                    in varchar2 default hr_api.g_varchar2
  ,p_information8                    in varchar2 default hr_api.g_varchar2
  ,p_information9                    in varchar2 default hr_api.g_varchar2
  ,p_information10                   in varchar2 default hr_api.g_varchar2
  ,p_information11                   in varchar2 default hr_api.g_varchar2
  ,p_information12                   in varchar2 default hr_api.g_varchar2
  ,p_information13                   in varchar2 default hr_api.g_varchar2
  ,p_information14                   in varchar2 default hr_api.g_varchar2
  ,p_information15                   in varchar2 default hr_api.g_varchar2
  ,p_information16                   in varchar2 default hr_api.g_varchar2
  ,p_information17                   in varchar2 default hr_api.g_varchar2
  ,p_information18                   in varchar2 default hr_api.g_varchar2
  ,p_information19                   in varchar2 default hr_api.g_varchar2
  ,p_information20                   in varchar2 default hr_api.g_varchar2
  ,p_information21                   in varchar2 default hr_api.g_varchar2
  ,p_information22                   in varchar2 default hr_api.g_varchar2
  ,p_information23                   in varchar2 default hr_api.g_varchar2
  ,p_information24                   in varchar2 default hr_api.g_varchar2
  ,p_information25                   in varchar2 default hr_api.g_varchar2
  ,p_information26                   in varchar2 default hr_api.g_varchar2
  ,p_information27                   in varchar2 default hr_api.g_varchar2
  ,p_information28                   in varchar2 default hr_api.g_varchar2
  ,p_information29                   in varchar2 default hr_api.g_varchar2
  ,p_information30                   in varchar2 default hr_api.g_varchar2
  ,p_tab_page_property_id              out nocopy number
  ,p_object_version_number             out nocopy number
  --,p_override_value_warning            out boolean
  ) is
  --
  -- Declare cursors and local variables
  --
  Type l_rec_type Is Record
  (navigation_direction hr_tab_page_properties_b.navigation_direction%TYPE
  ,visible hr_tab_page_properties_b.visible%TYPE
  ,information_category hr_tab_page_properties_b.information_category%TYPE
  ,information1 hr_tab_page_properties_b.information1%TYPE
  ,information2 hr_tab_page_properties_b.information2%TYPE
  ,information3 hr_tab_page_properties_b.information3%TYPE
  ,information4 hr_tab_page_properties_b.information4%TYPE
  ,information5 hr_tab_page_properties_b.information5%TYPE
  ,information6 hr_tab_page_properties_b.information6%TYPE
  ,information7 hr_tab_page_properties_b.information7%TYPE
  ,information8 hr_tab_page_properties_b.information8%TYPE
  ,information9 hr_tab_page_properties_b.information9%TYPE
  ,information10 hr_tab_page_properties_b.information10%TYPE
  ,information11 hr_tab_page_properties_b.information11%TYPE
  ,information12 hr_tab_page_properties_b.information12%TYPE
  ,information13 hr_tab_page_properties_b.information13%TYPE
  ,information14 hr_tab_page_properties_b.information14%TYPE
  ,information15 hr_tab_page_properties_b.information15%TYPE
  ,information16 hr_tab_page_properties_b.information16%TYPE
  ,information17 hr_tab_page_properties_b.information17%TYPE
  ,information18 hr_tab_page_properties_b.information18%TYPE
  ,information19 hr_tab_page_properties_b.information19%TYPE
  ,information20 hr_tab_page_properties_b.information20%TYPE
  ,information21 hr_tab_page_properties_b.information21%TYPE
  ,information22 hr_tab_page_properties_b.information22%TYPE
  ,information23 hr_tab_page_properties_b.information23%TYPE
  ,information24 hr_tab_page_properties_b.information24%TYPE
  ,information25 hr_tab_page_properties_b.information25%TYPE
  ,information26 hr_tab_page_properties_b.information26%TYPE
  ,information27 hr_tab_page_properties_b.information27%TYPE
  ,information28 hr_tab_page_properties_b.information28%TYPE
  ,information29 hr_tab_page_properties_b.information29%TYPE
  ,information30 hr_tab_page_properties_b.information30%TYPE);

  l_rec l_rec_type;

  CURSOR cur_check
  IS
  SELECT ttp.form_tab_page_id
  FROM hr_template_tab_pages ttp
  WHERE ttp.template_tab_page_id = p_template_tab_page_id_from
  INTERSECT
  SELECT ttp.form_tab_page_id
  FROM hr_template_tab_pages ttp
  WHERE ttp.template_tab_page_id = p_template_tab_page_id_to;

  CURSOR cur_tab_prop
  IS
  SELECT DECODE(p_navigation_direction,hr_api.g_varchar2,tpp.navigation_direction,p_navigation_direction)
  ,DECODE(p_visible,hr_api.g_number,tpp.visible,p_visible)
  ,DECODE(p_information_category,hr_api.g_varchar2,tpp.information_category,p_information_category)
  ,DECODE(p_information1,hr_api.g_varchar2,tpp.information1,p_information1)
  ,DECODE(p_information2,hr_api.g_varchar2,tpp.information2,p_information2)
  ,DECODE(p_information3,hr_api.g_varchar2,tpp.information3,p_information3)
  ,DECODE(p_information4,hr_api.g_varchar2,tpp.information4,p_information4)
  ,DECODE(p_information5,hr_api.g_varchar2,tpp.information5,p_information5)
  ,DECODE(p_information6,hr_api.g_varchar2,tpp.information6,p_information6)
  ,DECODE(p_information7,hr_api.g_varchar2,tpp.information7,p_information7)
  ,DECODE(p_information8,hr_api.g_varchar2,tpp.information8,p_information8)
  ,DECODE(p_information9,hr_api.g_varchar2,tpp.information9,p_information9)
  ,DECODE(p_information10,hr_api.g_varchar2,tpp.information10,p_information10)
  ,DECODE(p_information11,hr_api.g_varchar2,tpp.information11,p_information11)
  ,DECODE(p_information12,hr_api.g_varchar2,tpp.information12,p_information12)
  ,DECODE(p_information13,hr_api.g_varchar2,tpp.information13,p_information13)
  ,DECODE(p_information14,hr_api.g_varchar2,tpp.information14,p_information14)
  ,DECODE(p_information15,hr_api.g_varchar2,tpp.information15,p_information15)
  ,DECODE(p_information16,hr_api.g_varchar2,tpp.information16,p_information16)
  ,DECODE(p_information17,hr_api.g_varchar2,tpp.information17,p_information17)
  ,DECODE(p_information18,hr_api.g_varchar2,tpp.information18,p_information18)
  ,DECODE(p_information19,hr_api.g_varchar2,tpp.information19,p_information19)
  ,DECODE(p_information20,hr_api.g_varchar2,tpp.information20,p_information20)
  ,DECODE(p_information21,hr_api.g_varchar2,tpp.information21,p_information21)
  ,DECODE(p_information22,hr_api.g_varchar2,tpp.information22,p_information22)
  ,DECODE(p_information23,hr_api.g_varchar2,tpp.information23,p_information23)
  ,DECODE(p_information24,hr_api.g_varchar2,tpp.information24,p_information24)
  ,DECODE(p_information25,hr_api.g_varchar2,tpp.information25,p_information25)
  ,DECODE(p_information26,hr_api.g_varchar2,tpp.information26,p_information26)
  ,DECODE(p_information27,hr_api.g_varchar2,tpp.information27,p_information27)
  ,DECODE(p_information28,hr_api.g_varchar2,tpp.information28,p_information28)
  ,DECODE(p_information29,hr_api.g_varchar2,tpp.information29,p_information29)
  ,DECODE(p_information30,hr_api.g_varchar2,tpp.information30,p_information30)
  FROM hr_tab_page_properties_b tpp
  WHERE tpp.template_tab_page_id = p_template_tab_page_id_from;

  CURSOR cur_tab_tl
  IS
  SELECT COUNT(0)
  ,tpptl.source_lang
  ,DECODE(p_label,hr_api.g_varchar2,tpptl.label,p_label) label
  FROM hr_tab_page_properties_tl tpptl
  ,hr_tab_page_properties_b tpp
  WHERE tpptl.tab_page_property_id = tpp.tab_page_property_id
  AND tpp.template_tab_page_id = p_template_tab_page_id_from
  GROUP BY tpptl.source_lang
  ,DECODE(p_label,hr_api.g_varchar2,tpptl.label,p_label)
  ORDER BY 1;

  l_check number;
  l_tab_page_property_id               number;
  l_object_version_number              number;
  l_override_value_warning             boolean;
  l_proc                varchar2(72) := g_package||'copy_tab_page_property';
  l_language_code fnd_languages.language_code%TYPE;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint copy_tab_page_property;

  --
  -- Validate the language parameter. l_language_code should be passed
  -- instead of p_language_code from now on, to allow an IN OUT parameter to
  -- be passed through.
  --
  l_language_code := p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);
  --
  hr_utility.set_location(l_proc, 20);
  --
  --
  -- Validation in addition to Row Handlers
  --
  OPEN cur_check;
  FETCH cur_check INTO l_check;
  IF cur_check%NOTFOUND THEN
    CLOSE cur_check;
    -- error message
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  END IF;
  CLOSE cur_check;
  --
  -- Process Logic
  --
  OPEN cur_tab_prop;
  FETCH cur_tab_prop INTO l_rec;
  CLOSE cur_tab_prop;

  hr_tpp_ins.ins(p_effective_date           => TRUNC(p_effective_date)
            ,p_template_tab_page_id         => p_template_tab_page_id_to
            ,p_navigation_direction         => l_rec.navigation_direction
            ,p_visible                      => l_rec.visible
            ,p_information_category         => l_rec.information_category
            ,p_information1                 => l_rec.information1
            ,p_information2                 => l_rec.information2
            ,p_information3                 => l_rec.information3
            ,p_information4                 => l_rec.information4
            ,p_information5                 => l_rec.information5
            ,p_information6                 => l_rec.information6
            ,p_information7                 => l_rec.information7
            ,p_information8                 => l_rec.information8
            ,p_information9                 => l_rec.information9
            ,p_information10                => l_rec.information10
            ,p_information11                => l_rec.information11
            ,p_information12                => l_rec.information12
            ,p_information13                => l_rec.information13
            ,p_information14                => l_rec.information14
            ,p_information15                => l_rec.information15
            ,p_information16                => l_rec.information16
            ,p_information17                => l_rec.information17
            ,p_information18                => l_rec.information18
            ,p_information19                => l_rec.information19
            ,p_information20                => l_rec.information20
            ,p_information21                => l_rec.information21
            ,p_information22                => l_rec.information22
            ,p_information23                => l_rec.information23
            ,p_information24                => l_rec.information24
            ,p_information25                => l_rec.information25
            ,p_information26                => l_rec.information26
            ,p_information27                => l_rec.information27
            ,p_information28                => l_rec.information28
            ,p_information29                => l_rec.information29
            ,p_information30                => l_rec.information30
            ,p_tab_page_property_id         => l_tab_page_property_id
            ,p_object_version_number         => l_object_version_number);
            --,p_override_value_warning       => l_override_value_warning);

  IF p_label <> hr_api.g_varchar2 THEN

    hr_tpt_ins.ins_tl(p_language_code                => l_language_code
               ,p_tab_page_property_id         => l_tab_page_property_id
               ,p_label                        => p_label);

  ELSE
    FOR cur_rec IN cur_tab_tl LOOP
      IF cur_tab_tl%ROWCOUNT = 1 THEN
        hr_tpt_ins.ins_tl(p_language_code                => cur_rec.source_lang
                  ,p_tab_page_property_id         => l_tab_page_property_id
                  ,p_label                        => cur_rec.label);
      ELSE
        hr_tpt_upd.upd_tl(p_language_code                => cur_rec.source_lang
                  ,p_tab_page_property_id         => l_tab_page_property_id
                  ,p_label                        => cur_rec.label);
      END IF;
    END LOOP;
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
  p_tab_page_property_id         := l_tab_page_property_id;
  p_object_version_number        := l_object_version_number;
  --p_override_value_warning       := l_override_value_warning;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to copy_tab_page_property;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_tab_page_property_id         := null;
    --p_override_value_warning       := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to copy_tab_page_property;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end copy_tab_page_property;
--
end hr_tab_page_properties_bsi;

/
