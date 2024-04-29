--------------------------------------------------------
--  DDL for Package Body HR_FORM_TAB_PAGES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_FORM_TAB_PAGES_API" as
/* $Header: hrftpapi.pkb 115.5 2003/09/24 02:23:35 bsubrama noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_form_tab_pages_api.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_form_tab_page >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_form_tab_page
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_language_code                  in varchar2 default hr_api.userenv_lang
  ,p_form_canvas_id                 in number
  ,p_tab_page_name                  in varchar2
  ,p_display_order                  in number
  ,p_user_tab_page_name             in varchar2
  ,p_description                    in varchar2 default null
  ,p_label                          in varchar2 default null
  ,p_navigation_direction           in varchar2 default null
  ,p_visible                        in number default null
  ,p_visible_override               in number default null
  ,p_information_category           in varchar2 default null
  ,p_information1                   in varchar2 default null
  ,p_information2                   in varchar2 default null
  ,p_information3                   in varchar2 default null
  ,p_information4                   in varchar2 default null
  ,p_information5                   in varchar2 default null
  ,p_information6                   in varchar2 default null
  ,p_information7                   in varchar2 default null
  ,p_information8                   in varchar2 default null
  ,p_information9                   in varchar2 default null
  ,p_information10                  in varchar2 default null
  ,p_information11                  in varchar2 default null
  ,p_information12                  in varchar2 default null
  ,p_information13                  in varchar2 default null
  ,p_information14                  in varchar2 default null
  ,p_information15                  in varchar2 default null
  ,p_information16                  in varchar2 default null
  ,p_information17                  in varchar2 default null
  ,p_information18                  in varchar2 default null
  ,p_information19                  in varchar2 default null
  ,p_information20                  in varchar2 default null
  ,p_information21                  in varchar2 default null
  ,p_information22                  in varchar2 default null
  ,p_information23                  in varchar2 default null
  ,p_information24                  in varchar2 default null
  ,p_information25                  in varchar2 default null
  ,p_information26                  in varchar2 default null
  ,p_information27                  in varchar2 default null
  ,p_information28                  in varchar2 default null
  ,p_information29                  in varchar2 default null
  ,p_information30                  in varchar2 default null
  ,p_form_tab_page_id                 out nocopy number
  ,p_object_version_number            out nocopy number
  ,p_override_value_warning           out nocopy boolean
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'create_form_tab_page';
  l_language_code fnd_languages.language_code%TYPE;

  l_object_version_number number;
  l_form_tab_page_id number;
  l_tab_page_property_id number;
  l_override_value_warning boolean := FALSE;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_form_tab_page;
  --
  -- Truncate the time portion from all IN date parameters
  --
     -- p_effective_date := TRUNC(p_effective_date);
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
  -- Call Before Process User Hook
  --
  begin
    hr_form_tab_pages_api_bk1.create_form_tab_page_b(
      p_effective_date                => TRUNC(p_effective_date)
      ,p_language_code                 => l_language_code
      ,p_form_canvas_id                => p_form_canvas_id
      ,p_tab_page_name                 => p_tab_page_name
      ,p_display_order                 => p_display_order
      ,p_user_tab_page_name            => p_user_tab_page_name
      ,p_description                   => p_description
      ,p_label                         => p_label
      ,p_navigation_direction          => p_navigation_direction
      ,p_visible                       => p_visible
      ,p_visible_override              => p_visible_override
      ,p_information_category          => p_information_category
      ,p_information1                  => p_information1
      ,p_information2                  => p_information2
      ,p_information3                  => p_information3
      ,p_information4                  => p_information4
      ,p_information5                  => p_information5
      ,p_information6                  => p_information6
      ,p_information7                  => p_information7
      ,p_information8                  => p_information8
      ,p_information9                  => p_information9
      ,p_information10                 => p_information10
      ,p_information11                 => p_information11
      ,p_information12                 => p_information12
      ,p_information13                 => p_information13
      ,p_information14                 => p_information14
      ,p_information15                 => p_information15
      ,p_information16                 => p_information16
      ,p_information17                 => p_information17
      ,p_information18                 => p_information18
      ,p_information19                 => p_information19
      ,p_information20                 => p_information20
      ,p_information21                 => p_information21
      ,p_information22                 => p_information22
      ,p_information23                 => p_information23
      ,p_information24                 => p_information24
      ,p_information25                 => p_information25
      ,p_information26                 => p_information26
      ,p_information27                 => p_information27
      ,p_information28                 => p_information28
      ,p_information29                 => p_information29
      ,p_information30                 => p_information30
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_form_tab_page'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  IF (p_visible is not null AND p_visible_override is not null) THEN
    l_override_value_warning := TRUE;
  END IF;
  hr_utility.set_location('At:'|| l_proc, 15);

  hr_ftp_ins.ins( p_effective_date                => TRUNC(p_effective_date)
                  ,p_form_canvas_id               => p_form_canvas_id
                  ,p_tab_page_name                => p_tab_page_name
                  ,p_display_order                => p_display_order
                  ,p_visible_override             => p_visible_override
                  ,p_form_tab_page_id             => l_form_tab_page_id
                  ,p_object_version_number        => l_object_version_number);

  hr_utility.set_location('At:'|| l_proc, 20);

  hr_ftt_ins.ins_tl( p_language_code                => l_language_code
                      ,p_form_tab_page_id             => l_form_tab_page_id
                      ,p_user_tab_page_name           => p_user_tab_page_name
                      ,p_description                  => p_description);

  hr_utility.set_location('At:'|| l_proc, 30);

  hr_tab_page_properties_bsi.create_tab_page_property(
            p_effective_date                => TRUNC(p_effective_date)
            ,p_language_code                => l_language_code
            ,p_form_tab_page_id             => l_form_tab_page_id
            ,p_label                        => p_label
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

  --
  -- Call After Process User Hook
  --
  hr_utility.set_location('At:'|| l_proc, 35);

  begin
    hr_form_tab_pages_api_bk1.create_form_tab_page_a(
      p_effective_date                => TRUNC(p_effective_date)
      ,p_language_code                 => l_language_code
      ,p_form_canvas_id                => p_form_canvas_id
      ,p_tab_page_name                 => p_tab_page_name
      ,p_display_order                 => p_display_order
      ,p_user_tab_page_name            => p_user_tab_page_name
      ,p_description                   => p_description
      ,p_label                         => p_label
      ,p_navigation_direction          => p_navigation_direction
      ,p_visible                       => p_visible
      ,p_visible_override              => p_visible_override
      ,p_information_category          => p_information_category
      ,p_information1                  => p_information1
      ,p_information2                  => p_information2
      ,p_information3                  => p_information3
      ,p_information4                  => p_information4
      ,p_information5                  => p_information5
      ,p_information6                  => p_information6
      ,p_information7                  => p_information7
      ,p_information8                  => p_information8
      ,p_information9                  => p_information9
      ,p_information10                 => p_information10
      ,p_information11                 => p_information11
      ,p_information12                 => p_information12
      ,p_information13                 => p_information13
      ,p_information14                 => p_information14
      ,p_information15                 => p_information15
      ,p_information16                 => p_information16
      ,p_information17                 => p_information17
      ,p_information18                 => p_information18
      ,p_information19                 => p_information19
      ,p_information20                 => p_information20
      ,p_information21                 => p_information21
      ,p_information22                 => p_information22
      ,p_information23                 => p_information23
      ,p_information24                 => p_information24
      ,p_information25                 => p_information25
      ,p_information26                 => p_information26
      ,p_information27                 => p_information27
      ,p_information28                 => p_information28
      ,p_information29                 => p_information29
      ,p_information30                 => p_information30
      ,p_form_tab_page_id             => l_form_tab_page_id
--      ,p_tab_page_property_id         => l_tab_page_property_id
      ,p_object_version_number        => l_object_version_number
      ,p_override_value_warning       => l_override_value_warning
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_form_tab_page'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  hr_utility.set_location('At:'|| l_proc, 40);

  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_form_tab_page_id             := l_form_tab_page_id;
  p_object_version_number        := l_object_version_number;
  p_override_value_warning       := l_override_value_warning;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_form_tab_page;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_form_tab_page_id             := null;
    p_object_version_number        := null;
    p_override_value_warning       := l_override_value_warning;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_form_tab_page;
    -- Set out parameters.
    p_form_tab_page_id             := null;
    p_object_version_number        := null;
    p_override_value_warning       := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_form_tab_page;
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_form_tab_page >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_form_tab_page
  (p_validate                      in     boolean  default false
   ,p_form_tab_page_id             in   number
   ,p_object_version_number        in   number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'delete_form_tab_page';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_form_tab_page;

  --
  -- Call Before Process User Hook
  --
  begin
    hr_form_tab_pages_api_bk2.delete_form_tab_page_b
      (p_form_tab_page_id             => p_form_tab_page_id
      ,p_object_version_number        => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_form_tab_page'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  hr_utility.set_location('At:'|| l_proc, 15);

  hr_ftp_shd.lck( p_form_tab_page_id             => p_form_tab_page_id
                 ,p_object_version_number        => p_object_version_number);

  hr_utility.set_location('At:'|| l_proc, 20);

  hr_tab_page_properties_bsi.delete_tab_page_property
            (p_form_tab_page_id  => p_form_tab_page_id
            ,p_object_version_number        => p_object_version_number);

  hr_utility.set_location('At:'|| l_proc, 25);

  hr_ftt_del.del_tl( p_form_tab_page_id => p_form_tab_page_id);

  hr_utility.set_location('At:'|| l_proc, 30);

  hr_ftp_del.del( p_form_tab_page_id             => p_form_tab_page_id
                 ,p_object_version_number        => p_object_version_number);

  hr_utility.set_location('At:'|| l_proc, 35);

  --
  -- Call After Process User Hook
  --
  begin
    hr_form_tab_pages_api_bk2.delete_form_tab_page_a
      (p_form_tab_page_id             => p_form_tab_page_id
      ,p_object_version_number        => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_form_tab_page'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  hr_utility.set_location('At:'|| l_proc, 40);

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
    rollback to delete_form_tab_page;
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
    rollback to delete_form_tab_page;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_form_tab_page;
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_form_tab_page >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_form_tab_page
  (p_validate                       in boolean  default false
  ,p_effective_date                 in date
  ,p_language_code                  in varchar2 default hr_api.userenv_lang
  ,p_form_tab_page_id               in number
  ,p_object_version_number          in out nocopy number
  ,p_tab_page_name                  in varchar2 default hr_api.g_varchar2
  ,p_display_order                  in number default hr_api.g_number
  ,p_user_tab_page_name             in varchar2 default hr_api.g_varchar2
  ,p_description                    in varchar2 default hr_api.g_varchar2
  ,p_label                          in varchar2 default hr_api.g_varchar2
  ,p_navigation_direction           in varchar2 default hr_api.g_varchar2
  ,p_visible                        in number default hr_api.g_number
  ,p_visible_override               in number default hr_api.g_number
  ,p_information_category           in varchar2 default hr_api.g_varchar2
  ,p_information1                   in varchar2 default hr_api.g_varchar2
  ,p_information2                   in varchar2 default hr_api.g_varchar2
  ,p_information3                   in varchar2 default hr_api.g_varchar2
  ,p_information4                   in varchar2 default hr_api.g_varchar2
  ,p_information5                   in varchar2 default hr_api.g_varchar2
  ,p_information6                   in varchar2 default hr_api.g_varchar2
  ,p_information7                   in varchar2 default hr_api.g_varchar2
  ,p_information8                   in varchar2 default hr_api.g_varchar2
  ,p_information9                   in varchar2 default hr_api.g_varchar2
  ,p_information10                  in varchar2 default hr_api.g_varchar2
  ,p_information11                  in varchar2 default hr_api.g_varchar2
  ,p_information12                  in varchar2 default hr_api.g_varchar2
  ,p_information13                  in varchar2 default hr_api.g_varchar2
  ,p_information14                  in varchar2 default hr_api.g_varchar2
  ,p_information15                  in varchar2 default hr_api.g_varchar2
  ,p_information16                  in varchar2 default hr_api.g_varchar2
  ,p_information17                  in varchar2 default hr_api.g_varchar2
  ,p_information18                  in varchar2 default hr_api.g_varchar2
  ,p_information19                  in varchar2 default hr_api.g_varchar2
  ,p_information20                  in varchar2 default hr_api.g_varchar2
  ,p_information21                  in varchar2 default hr_api.g_varchar2
  ,p_information22                  in varchar2 default hr_api.g_varchar2
  ,p_information23                  in varchar2 default hr_api.g_varchar2
  ,p_information24                  in varchar2 default hr_api.g_varchar2
  ,p_information25                  in varchar2 default hr_api.g_varchar2
  ,p_information26                  in varchar2 default hr_api.g_varchar2
  ,p_information27                  in varchar2 default hr_api.g_varchar2
  ,p_information28                  in varchar2 default hr_api.g_varchar2
  ,p_information29                  in varchar2 default hr_api.g_varchar2
  ,p_information30                  in varchar2 default hr_api.g_varchar2
  ,p_override_value_warning           out nocopy boolean
  ) is
  --
  -- Declare cursors and local variables
  --

  l_language_code fnd_languages.language_code%TYPE;

  CURSOR cur_override
  IS
  SELECT DECODE(p_visible,hr_api.g_number,visible,p_visible),
 DECODE(p_visible_override,hr_api.g_number,visible_override,p_visible_override)
  FROM hr_form_tab_pages
  WHERE form_tab_page_id = p_form_tab_page_id;

  l_visible number;
  l_visible_override number;
  l_proc                varchar2(72) := g_package||'update_form_tab_page';
  l_object_version_number number;
  l_override_value_warning boolean := FALSE;

  l_temp_ovn   number := p_object_version_number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_form_tab_page;
  --
  -- Truncate the time portion from all IN date parameters
  --
     -- p_effective_date := TRUNC(p_effective_date);
     l_object_version_number := p_object_version_number;
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
  -- Call Before Process User Hook
  --
  begin
    hr_form_tab_pages_api_bk3.update_form_tab_page_b
      ( p_effective_date                => TRUNC(p_effective_date)
      ,p_language_code                 => l_language_code
      ,p_form_tab_page_id              => p_form_tab_page_id
      ,p_object_version_number         => l_object_version_number
      ,p_tab_page_name                 => p_tab_page_name
      ,p_display_order                 => p_display_order
      ,p_user_tab_page_name            => p_user_tab_page_name
      ,p_description                   => p_description
      ,p_label                         => p_label
      ,p_navigation_direction          => p_navigation_direction
      ,p_visible                       => p_visible
      ,p_visible_override              => p_visible_override
      ,p_information_category          => p_information_category
      ,p_information1                  => p_information1
      ,p_information2                  => p_information2
      ,p_information3                  => p_information3
      ,p_information4                  => p_information4
      ,p_information5                  => p_information5
      ,p_information6                  => p_information6
      ,p_information7                  => p_information7
      ,p_information8                  => p_information8
      ,p_information9                  => p_information9
      ,p_information10                 => p_information10
      ,p_information11                 => p_information11
      ,p_information12                 => p_information12
      ,p_information13                 => p_information13
      ,p_information14                 => p_information14
      ,p_information15                 => p_information15
      ,p_information16                 => p_information16
      ,p_information17                 => p_information17
      ,p_information18                 => p_information18
      ,p_information19                 => p_information19
      ,p_information20                 => p_information20
      ,p_information21                 => p_information21
      ,p_information22                 => p_information22
      ,p_information23                 => p_information23
      ,p_information24                 => p_information24
      ,p_information25                 => p_information25
      ,p_information26                 => p_information26
      ,p_information27                 => p_information27
      ,p_information28                 => p_information28
      ,p_information29                 => p_information29
      ,p_information30                 => p_information30 );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_form_tab_page'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  OPEN cur_override;
  FETCH cur_override INTO l_visible , l_visible_override;
  CLOSE cur_override;

  IF (l_visible is not null AND l_visible_override is not null) THEN
    l_override_value_warning := TRUE;
  END IF;

  hr_utility.set_location('At:'|| l_proc, 20);

  hr_ftp_upd.upd(p_effective_date                => TRUNC(p_effective_date)
                 ,p_form_tab_page_id             => p_form_tab_page_id
                 ,p_tab_page_name                => p_tab_page_name
                 ,p_display_order                => p_display_order
                 ,p_visible_override             => p_visible_override
                 ,p_object_version_number        => l_object_version_number);

  hr_utility.set_location('At:'|| l_proc, 25);

  hr_ftt_upd.upd_tl(p_language_code                => l_language_code
                      ,p_form_tab_page_id             => p_form_tab_page_id
                      ,p_user_tab_page_name           => p_user_tab_page_name
                      ,p_description                  => p_description);

  hr_utility.set_location('At:'|| l_proc, 30);

  hr_tab_page_properties_bsi.update_tab_page_property
            (p_effective_date               => TRUNC(p_effective_date)
            ,p_object_version_number        => l_object_version_number
            ,p_language_code                => l_language_code
            ,p_form_tab_page_id             => p_form_tab_page_id
            ,p_label                        => p_label
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
            ,p_information30                => p_information30);
            --,p_override_value_warning       => l_override_value_warning);

  hr_utility.set_location('At:'|| l_proc, 35);

  --
  -- Call After Process User Hook
  --
  begin

    hr_form_tab_pages_api_bk3.update_form_tab_page_a
      ( p_effective_date                => TRUNC(p_effective_date)
      ,p_language_code                 => l_language_code
      ,p_form_tab_page_id              => p_form_tab_page_id
      ,p_object_version_number         => l_object_version_number
      ,p_tab_page_name                 => p_tab_page_name
      ,p_display_order                 => p_display_order
      ,p_user_tab_page_name            => p_user_tab_page_name
      ,p_description                   => p_description
      ,p_label                         => p_label
      ,p_navigation_direction          => p_navigation_direction
      ,p_visible                       => p_visible
      ,p_visible_override              => p_visible_override
      ,p_information_category          => p_information_category
      ,p_information1                  => p_information1
      ,p_information2                  => p_information2
      ,p_information3                  => p_information3
      ,p_information4                  => p_information4
      ,p_information5                  => p_information5
      ,p_information6                  => p_information6
      ,p_information7                  => p_information7
      ,p_information8                  => p_information8
      ,p_information9                  => p_information9
      ,p_information10                 => p_information10
      ,p_information11                 => p_information11
      ,p_information12                 => p_information12
      ,p_information13                 => p_information13
      ,p_information14                 => p_information14
      ,p_information15                 => p_information15
      ,p_information16                 => p_information16
      ,p_information17                 => p_information17
      ,p_information18                 => p_information18
      ,p_information19                 => p_information19
      ,p_information20                 => p_information20
      ,p_information21                 => p_information21
      ,p_information22                 => p_information22
      ,p_information23                 => p_information23
      ,p_information24                 => p_information24
      ,p_information25                 => p_information25
      ,p_information26                 => p_information26
      ,p_information27                 => p_information27
      ,p_information28                 => p_information28
      ,p_information29                 => p_information29
      ,p_information30                 => p_information30
      ,p_override_value_warning       => l_override_value_warning);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_form_tab_page'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  hr_utility.set_location('At:'|| l_proc, 40);

  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_object_version_number  := l_object_version_number;
  p_override_value_warning := l_override_value_warning;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_form_tab_page;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := l_temp_ovn;
    p_override_value_warning := l_override_value_warning;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_form_tab_page;
    -- Reset IN OUT and set OUT parameters.
    p_object_version_number  := l_temp_ovn;
    p_override_value_warning := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_form_tab_page;
--
end hr_form_tab_pages_api;

/
