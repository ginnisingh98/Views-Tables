--------------------------------------------------------
--  DDL for Package Body HR_FORM_ITEMS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_FORM_ITEMS_API" as
/* $Header: hrfimapi.pkb 115.5 2003/09/24 02:23:16 bsubrama noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_form_items_api.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_form_item >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_form_item
  (p_validate                    in boolean  default false
  ,p_effective_date              in date
  ,p_language_code               in varchar2 default hr_api.userenv_lang
  ,p_application_id              in number
  ,p_form_id                     in number
  ,p_full_item_name              in varchar2
  ,p_item_type                   in varchar2
  ,p_form_canvas_id              in number
  ,p_user_item_name              in varchar2
  ,p_description                 in varchar2 default null
  ,p_form_tab_page_id            in number default null
  ,p_radio_button_name           in varchar2 default null
  ,p_required_override           in number default null
  ,p_form_tab_page_id_override   in number default null
  ,p_visible_override            in number default null
  ,p_alignment                   in number default null
  ,p_bevel                       in number default null
  ,p_case_restriction            in number default null
  ,p_default_value               in varchar2 default null
  ,p_enabled                     in number default null
  ,p_format_mask                 in varchar2 default null
  ,p_height                      in number default null
  ,p_information_formula_id      in number default null
  ,p_information_param_item_id1  in number default null
  ,p_information_param_item_id2  in number default null
  ,p_information_param_item_id3  in number default null
  ,p_information_param_item_id4  in number default null
  ,p_information_param_item_id5  in number default null
  ,p_information_prompt          in varchar2 default null
  ,p_insert_allowed              in number default null
  ,p_label                       in varchar2 default null
  ,p_prompt_text                 in varchar2 default null
  ,p_prompt_alignment_offset     in number default null
  ,p_prompt_display_style        in number default null
  ,p_prompt_edge                 in number default null
  ,p_prompt_edge_alignment       in number default null
  ,p_prompt_edge_offset          in number default null
  ,p_prompt_text_alignment       in number default null
  ,p_query_allowed               in number default null
  ,p_required                    in number default null
  ,p_tooltip_text                in varchar2 default null
  ,p_update_allowed              in number default null
  ,p_validation_formula_id       in number default null
  ,p_validation_param_item_id1   in number default null
  ,p_validation_param_item_id2   in number default null
  ,p_validation_param_item_id3   in number default null
  ,p_validation_param_item_id4   in number default null
  ,p_validation_param_item_id5   in number default null
  ,p_visible                     in number default null
  ,p_width                       in number default null
  ,p_x_position                  in number default null
  ,p_y_position                  in number default null
  ,p_information_category        in varchar2 default null
  ,p_information1                in varchar2 default null
  ,p_information2                in varchar2 default null
  ,p_information3                in varchar2 default null
  ,p_information4                in varchar2 default null
  ,p_information5                in varchar2 default null
  ,p_information6                in varchar2 default null
  ,p_information7                in varchar2 default null
  ,p_information8                in varchar2 default null
  ,p_information9                in varchar2 default null
  ,p_information10               in varchar2 default null
  ,p_information11               in varchar2 default null
  ,p_information12               in varchar2 default null
  ,p_information13               in varchar2 default null
  ,p_information14               in varchar2 default null
  ,p_information15               in varchar2 default null
  ,p_information16               in varchar2 default null
  ,p_information17               in varchar2 default null
  ,p_information18               in varchar2 default null
  ,p_information19               in varchar2 default null
  ,p_information20               in varchar2 default null
  ,p_information21               in varchar2 default null
  ,p_information22               in varchar2 default null
  ,p_information23               in varchar2 default null
  ,p_information24               in varchar2 default null
  ,p_information25               in varchar2 default null
  ,p_information26               in varchar2 default null
  ,p_information27               in varchar2 default null
  ,p_information28               in varchar2 default null
  ,p_information29               in varchar2 default null
  ,p_information30               in varchar2 default null
  ,p_next_navigation_item_id     in number default null
  ,p_previous_navigation_item_id in number default null
  ,p_form_item_id                   out nocopy number
  ,p_object_version_number          out nocopy number
  ,p_override_value_warning         out nocopy boolean
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                  varchar2(72) := g_package||'create_form_item';
  l_language_code fnd_languages.language_code%TYPE;

  l_form_item_id          number;
  l_object_version_number number;
  l_item_property_id       number;
  l_override_value_warning boolean := FALSE;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_form_item;
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
    hr_form_items_api_bk1.create_form_item_b
      (p_effective_date             => TRUNC(p_effective_date)
      ,p_language_code              => l_language_code
      ,p_application_id             => p_application_id
      ,p_form_id                    => p_form_id
      ,p_full_item_name             => p_full_item_name
      ,p_item_type                  => p_item_type
      ,p_form_canvas_id             => p_form_canvas_id
      ,p_user_item_name             => p_user_item_name
      ,p_description                => p_description
      ,p_form_tab_page_id           => p_form_tab_page_id
      ,p_radio_button_name          => p_radio_button_name
      ,p_required_override          => p_required_override
      ,p_form_tab_page_id_override  => p_form_tab_page_id_override
      ,p_visible_override           => p_visible_override
      ,p_alignment                  => p_alignment
      ,p_bevel                      => p_bevel
      ,p_case_restriction           => p_case_restriction
      ,p_default_value              => p_default_value
      ,p_enabled                    => p_enabled
      ,p_format_mask                => p_format_mask
      ,p_height                     => p_height
      ,p_information_formula_id     => p_information_formula_id
      ,p_information_param_item_id1 => p_information_param_item_id1
      ,p_information_param_item_id2 => p_information_param_item_id2
      ,p_information_param_item_id3 => p_information_param_item_id3
      ,p_information_param_item_id4 => p_information_param_item_id4
      ,p_information_param_item_id5 => p_information_param_item_id5
      ,p_information_prompt         => p_information_prompt
      ,p_insert_allowed             => p_insert_allowed
      ,p_label                      => p_label
      ,p_prompt_text                => p_prompt_text
      ,p_prompt_alignment_offset    => p_prompt_alignment_offset
      ,p_prompt_display_style       => p_prompt_display_style
      ,p_prompt_edge                => p_prompt_edge
      ,p_prompt_edge_alignment      => p_prompt_edge_alignment
      ,p_prompt_edge_offset         => p_prompt_edge_offset
      ,p_prompt_text_alignment      => p_prompt_text_alignment
      ,p_query_allowed              => p_query_allowed
      ,p_required                   => p_required
      ,p_tooltip_text               => p_tooltip_text
      ,p_update_allowed             => p_update_allowed
      ,p_validation_formula_id      => p_validation_formula_id
      ,p_validation_param_item_id1  => p_validation_param_item_id1
      ,p_validation_param_item_id2  => p_validation_param_item_id2
      ,p_validation_param_item_id3  => p_validation_param_item_id3
      ,p_validation_param_item_id4  => p_validation_param_item_id4
      ,p_validation_param_item_id5  => p_validation_param_item_id5
      ,p_visible                    => p_visible
      ,p_width                      => p_width
      ,p_x_position                 => p_x_position
      ,p_y_position                 => p_y_position
      ,p_information_category       => p_information_category
      ,p_information1               => p_information1
      ,p_information2               => p_information2
      ,p_information3               => p_information3
      ,p_information4               => p_information4
      ,p_information5               => p_information5
      ,p_information6               => p_information6
      ,p_information7               => p_information7
      ,p_information8               => p_information8
      ,p_information9               => p_information9
      ,p_information10              => p_information10
      ,p_information11              => p_information11
      ,p_information12              => p_information12
      ,p_information13              => p_information13
      ,p_information14              => p_information14
      ,p_information15              => p_information15
      ,p_information16              => p_information16
      ,p_information17              => p_information17
      ,p_information18              => p_information18
      ,p_information19              => p_information19
      ,p_information20              => p_information20
      ,p_information21              => p_information21
      ,p_information22              => p_information22
      ,p_information23              => p_information23
      ,p_information24              => p_information24
      ,p_information25              => p_information25
      ,p_information26              => p_information26
      ,p_information27              => p_information27
      ,p_information28              => p_information28
      ,p_information29              => p_information29
      ,p_information30              => p_information30
      ,p_next_navigation_item_id      => p_next_navigation_item_id
      ,p_previous_navigation_item_id  => p_previous_navigation_item_id);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_form_item'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --

  hr_utility.set_location('At:'|| l_proc, 15);

  IF ( p_required_override is not null AND p_required is not null ) OR
     ( p_form_tab_page_id_override is not null
       AND p_form_tab_page_id is not null ) OR
     ( p_visible_override is not null AND p_visible is not null ) THEN
     l_override_value_warning := TRUE;
  END IF;

  hr_utility.set_location('At:'|| l_proc, 20);

  hr_fim_ins.ins(p_effective_date                => TRUNC(p_effective_date)
                 ,p_application_id               => p_application_id
                 ,p_form_id                      => p_form_id
                 ,p_full_item_name               => p_full_item_name
                 ,p_item_type                    => p_item_type
                 ,p_form_canvas_id               => p_form_canvas_id
                 ,p_form_tab_page_id             => p_form_tab_page_id
                 ,p_radio_button_name            => p_radio_button_name
                 ,p_required_override            => p_required_override
                 ,p_form_tab_page_id_override    => p_form_tab_page_id_override
                 ,p_visible_override             => p_visible_override
                 ,p_form_item_id                 => l_form_item_id
                 ,p_object_version_number        => l_object_version_number);

  hr_utility.set_location('At:'|| l_proc, 25);

   hr_fit_ins.ins_tl(p_language_code                => l_language_code
                       ,p_form_item_id                 => l_form_item_id
                       ,p_user_item_name               => p_user_item_name
                       ,p_description                  => p_description);

  hr_utility.set_location('At:'|| l_proc, 30);

   hr_item_properties_bsi.create_item_property(
            p_effective_date                => TRUNC(p_effective_date)
            ,p_language_code                => l_language_code
            ,p_form_item_id                 => l_form_item_id
            ,p_alignment                    => p_alignment
            ,p_bevel                        => p_bevel
            ,p_case_restriction             => p_case_restriction
            ,p_default_value                => p_default_value
            ,p_enabled                      => p_enabled
            ,p_format_mask                  => p_format_mask
            ,p_height                       => p_height
            ,p_information_formula_id       => p_information_formula_id
            ,p_information_param_item_id1   => p_information_param_item_id1
            ,p_information_param_item_id2   => p_information_param_item_id2
            ,p_information_param_item_id3   => p_information_param_item_id3
            ,p_information_param_item_id4   => p_information_param_item_id4
            ,p_information_param_item_id5   => p_information_param_item_id5
            ,p_information_prompt           => p_information_prompt
            ,p_insert_allowed               => p_insert_allowed
            ,p_label                        => p_label
            ,p_prompt_text                  => p_prompt_text
            ,p_prompt_alignment_offset      => p_prompt_alignment_offset
            ,p_prompt_display_style         => p_prompt_display_style
            ,p_prompt_edge                  => p_prompt_edge
            ,p_prompt_edge_alignment        => p_prompt_edge_alignment
            ,p_prompt_edge_offset           => p_prompt_edge_offset
            ,p_prompt_text_alignment        => p_prompt_text_alignment
            ,p_query_allowed                => p_query_allowed
            ,p_required                     => p_required
            ,p_tooltip_text                 => p_tooltip_text
            ,p_update_allowed               => p_update_allowed
            ,p_validation_formula_id        => p_validation_formula_id
            ,p_validation_param_item_id1    => p_validation_param_item_id1
            ,p_validation_param_item_id2    => p_validation_param_item_id2
            ,p_validation_param_item_id3    => p_validation_param_item_id3
            ,p_validation_param_item_id4    => p_validation_param_item_id4
            ,p_validation_param_item_id5    => p_validation_param_item_id5
            ,p_visible                      => p_visible
            ,p_width                        => p_width
            ,p_x_position                   => p_x_position
            ,p_y_position                   => p_y_position
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
            ,p_next_navigation_item_id      => p_next_navigation_item_id
            ,p_previous_navigation_item_id  => p_previous_navigation_item_id
            ,p_item_property_id             => l_item_property_id
            ,p_object_version_number        => l_object_version_number);
            --,p_override_value_warning       => l_override_value_warning);

  --
  -- Call After Process User Hook
  --
  hr_utility.set_location('At:'|| l_proc, 40);

  begin
    hr_form_items_api_bk1.create_form_item_a
      (p_effective_date             => TRUNC(p_effective_date)
      ,p_language_code              => l_language_code
      ,p_application_id             => p_application_id
      ,p_form_id                    => p_form_id
      ,p_full_item_name             => p_full_item_name
      ,p_item_type                  => p_item_type
      ,p_form_canvas_id             => p_form_canvas_id
      ,p_user_item_name             => p_user_item_name
      ,p_description                => p_description
      ,p_form_tab_page_id           => p_form_tab_page_id
      ,p_radio_button_name          => p_radio_button_name
      ,p_required_override          => p_required_override
      ,p_form_tab_page_id_override  => p_form_tab_page_id_override
      ,p_visible_override           => p_visible_override
      ,p_alignment                  => p_alignment
      ,p_bevel                      => p_bevel
      ,p_case_restriction           => p_case_restriction
      ,p_default_value              => p_default_value
      ,p_enabled                    => p_enabled
      ,p_format_mask                => p_format_mask
      ,p_height                     => p_height
      ,p_information_formula_id     => p_information_formula_id
      ,p_information_param_item_id1 => p_information_param_item_id1
      ,p_information_param_item_id2 => p_information_param_item_id2
      ,p_information_param_item_id3 => p_information_param_item_id3
      ,p_information_param_item_id4 => p_information_param_item_id4
      ,p_information_param_item_id5 => p_information_param_item_id5
      ,p_information_prompt         => p_information_prompt
      ,p_insert_allowed             => p_insert_allowed
      ,p_label                      => p_label
      ,p_prompt_text                => p_prompt_text
      ,p_prompt_alignment_offset    => p_prompt_alignment_offset
      ,p_prompt_display_style       => p_prompt_display_style
      ,p_prompt_edge                => p_prompt_edge
      ,p_prompt_edge_alignment      => p_prompt_edge_alignment
      ,p_prompt_edge_offset         => p_prompt_edge_offset
      ,p_prompt_text_alignment      => p_prompt_text_alignment
      ,p_query_allowed              => p_query_allowed
      ,p_required                   => p_required
      ,p_tooltip_text               => p_tooltip_text
      ,p_update_allowed             => p_update_allowed
      ,p_validation_formula_id      => p_validation_formula_id
      ,p_validation_param_item_id1  => p_validation_param_item_id1
      ,p_validation_param_item_id2  => p_validation_param_item_id2
      ,p_validation_param_item_id3  => p_validation_param_item_id3
      ,p_validation_param_item_id4  => p_validation_param_item_id4
      ,p_validation_param_item_id5  => p_validation_param_item_id5
      ,p_visible                    => p_visible
      ,p_width                      => p_width
      ,p_x_position                 => p_x_position
      ,p_y_position                 => p_y_position
      ,p_information_category       => p_information_category
      ,p_information1               => p_information1
      ,p_information2               => p_information2
      ,p_information3               => p_information3
      ,p_information4               => p_information4
      ,p_information5               => p_information5
      ,p_information6               => p_information6
      ,p_information7               => p_information7
      ,p_information8               => p_information8
      ,p_information9               => p_information9
      ,p_information10              => p_information10
      ,p_information11              => p_information11
      ,p_information12              => p_information12
      ,p_information13              => p_information13
      ,p_information14              => p_information14
      ,p_information15              => p_information15
      ,p_information16              => p_information16
      ,p_information17              => p_information17
      ,p_information18              => p_information18
      ,p_information19              => p_information19
      ,p_information20              => p_information20
      ,p_information21              => p_information21
      ,p_information22              => p_information22
      ,p_information23              => p_information23
      ,p_information24              => p_information24
      ,p_information25              => p_information25
      ,p_information26              => p_information26
      ,p_information27              => p_information27
      ,p_information28              => p_information28
      ,p_information29              => p_information29
      ,p_information30              => p_information30
      ,p_next_navigation_item_id      => p_next_navigation_item_id
      ,p_previous_navigation_item_id  => p_previous_navigation_item_id
      ,p_form_item_id               => l_form_item_id
--    ,p_form_item_property_id      => l_form_item_property_id
      ,p_object_version_number      => l_object_version_number
      ,p_override_value_warning     => l_override_value_warning);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_form_item'
        ,p_hook_type   => 'AP'
        );
  end;

  hr_utility.set_location('At:'|| l_proc, 50);

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_form_item_id           := l_form_item_id;
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
    rollback to create_form_item;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_form_item_id           := null;
    p_object_version_number  := null;
    p_override_value_warning := l_override_value_warning;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_form_item;
    -- Reset out parameters.
    p_form_item_id           := null;
    p_object_version_number  := null;
    p_override_value_warning := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_form_item;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_form_item >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_form_item
  (p_validate                      in     boolean  default false
  ,p_form_item_id                  in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'delete_form_item';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_form_item;

  --
  -- Call Before Process User Hook
  --
  begin
    hr_form_items_api_bk2.delete_form_item_b
      (p_form_item_id                => p_form_item_id
      ,p_object_version_number       => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_form_item'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  hr_utility.set_location('At:'|| l_proc, 15);

  hr_fim_shd.lck( p_form_item_id => p_form_item_id
                 ,p_object_version_number => p_object_version_number);

  hr_utility.set_location('At:'|| l_proc, 20);

  hr_item_properties_bsi.delete_item_property
            (p_form_item_id => p_form_item_id
            ,p_object_version_number => p_object_version_number);

  hr_utility.set_location('At:'|| l_proc, 25);

  hr_fit_del.del_tl( p_form_item_id => p_form_item_id);

  hr_utility.set_location('At:'|| l_proc, 30);

  hr_fim_del.del( p_form_item_id => p_form_item_id
                 ,p_object_version_number => p_object_version_number);

  hr_utility.set_location('At:'|| l_proc, 35);

  --
  -- Call After Process User Hook
  --
  begin
    hr_form_items_api_bk2.delete_form_item_b
      (p_form_item_id                => p_form_item_id
      ,p_object_version_number       => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_form_item'
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
    rollback to delete_form_item;
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
    rollback to delete_form_item;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_form_item;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_form_item >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_form_item
  (p_validate                    in     boolean  default false
  ,p_effective_date              in     date
  ,p_language_code               in varchar2 default hr_api.userenv_lang
  ,p_form_item_id                in  number
  ,p_object_version_number       in out nocopy     number
  ,p_full_item_name              in varchar2  default hr_api.g_varchar2
  --,p_item_type                   in varchar2 default hr_api.g_varchar2
  ,p_user_item_name              in varchar2  default hr_api.g_varchar2
  ,p_description                 in varchar2 default hr_api.g_varchar2
  ,p_radio_button_name           in varchar2 default hr_api.g_varchar2
  ,p_required_override           in number default hr_api.g_number
  ,p_form_tab_page_id_override   in number default hr_api.g_number
  ,p_visible_override            in number default hr_api.g_number
  ,p_alignment                   in number default hr_api.g_number
  ,p_bevel                       in number default hr_api.g_number
  ,p_case_restriction            in number default hr_api.g_number
  ,p_default_value               in varchar2 default hr_api.g_varchar2
  ,p_enabled                     in number default hr_api.g_number
  ,p_format_mask                 in varchar2 default hr_api.g_varchar2
  ,p_height                      in number default hr_api.g_number
  ,p_information_formula_id      in number default hr_api.g_number
  ,p_information_param_item_id1  in number default hr_api.g_number
  ,p_information_param_item_id2  in number default hr_api.g_number
  ,p_information_param_item_id3  in number default hr_api.g_number
  ,p_information_param_item_id4  in number default hr_api.g_number
  ,p_information_param_item_id5  in number default hr_api.g_number
  ,p_information_prompt          in varchar2 default hr_api.g_varchar2
  ,p_insert_allowed              in number default hr_api.g_number
  ,p_label                       in varchar2 default hr_api.g_varchar2
  ,p_prompt_text                 in varchar2 default hr_api.g_varchar2
  ,p_prompt_alignment_offset     in number default hr_api.g_number
  ,p_prompt_display_style        in number default hr_api.g_number
  ,p_prompt_edge                 in number default hr_api.g_number
  ,p_prompt_edge_alignment       in number default hr_api.g_number
  ,p_prompt_edge_offset          in number default hr_api.g_number
  ,p_prompt_text_alignment       in number default hr_api.g_number
  ,p_query_allowed               in number default hr_api.g_number
  ,p_required                    in number default hr_api.g_number
  ,p_tooltip_text                in varchar2 default hr_api.g_varchar2
  ,p_update_allowed              in number default hr_api.g_number
  ,p_validation_formula_id       in number default hr_api.g_number
  ,p_validation_param_item_id1   in number default hr_api.g_number
  ,p_validation_param_item_id2   in number default hr_api.g_number
  ,p_validation_param_item_id3   in number default hr_api.g_number
  ,p_validation_param_item_id4   in number default hr_api.g_number
  ,p_validation_param_item_id5   in number default hr_api.g_number
  ,p_visible                     in number default hr_api.g_number
  ,p_width                       in number default hr_api.g_number
  ,p_x_position                  in number default hr_api.g_number
  ,p_y_position                  in number default hr_api.g_number
  ,p_information_category        in varchar2 default hr_api.g_varchar2
  ,p_information1                in varchar2 default hr_api.g_varchar2
  ,p_information2                in varchar2 default hr_api.g_varchar2
  ,p_information3                in varchar2 default hr_api.g_varchar2
  ,p_information4                in varchar2 default hr_api.g_varchar2
  ,p_information5                in varchar2 default hr_api.g_varchar2
  ,p_information6                in varchar2 default hr_api.g_varchar2
  ,p_information7                in varchar2 default hr_api.g_varchar2
  ,p_information8                in varchar2 default hr_api.g_varchar2
  ,p_information9                in varchar2 default hr_api.g_varchar2
  ,p_information10               in varchar2 default hr_api.g_varchar2
  ,p_information11               in varchar2 default hr_api.g_varchar2
  ,p_information12               in varchar2 default hr_api.g_varchar2
  ,p_information13               in varchar2 default hr_api.g_varchar2
  ,p_information14               in varchar2 default hr_api.g_varchar2
  ,p_information15               in varchar2 default hr_api.g_varchar2
  ,p_information16               in varchar2 default hr_api.g_varchar2
  ,p_information17               in varchar2 default hr_api.g_varchar2
  ,p_information18               in varchar2 default hr_api.g_varchar2
  ,p_information19               in varchar2 default hr_api.g_varchar2
  ,p_information20               in varchar2 default hr_api.g_varchar2
  ,p_information21               in varchar2 default hr_api.g_varchar2
  ,p_information22               in varchar2 default hr_api.g_varchar2
  ,p_information23               in varchar2 default hr_api.g_varchar2
  ,p_information24               in varchar2 default hr_api.g_varchar2
  ,p_information25               in varchar2 default hr_api.g_varchar2
  ,p_information26               in varchar2 default hr_api.g_varchar2
  ,p_information27               in varchar2 default hr_api.g_varchar2
  ,p_information28               in varchar2 default hr_api.g_varchar2
  ,p_information29               in varchar2 default hr_api.g_varchar2
  ,p_information30               in varchar2 default hr_api.g_varchar2
  ,p_next_navigation_item_id     in number default hr_api.g_number
  ,p_previous_navigation_item_id in number default hr_api.g_number
  ,p_override_value_warning      out nocopy boolean
  ) is
  --
  -- Declare cursors and local variables
  --
  l_language_code fnd_languages.language_code%TYPE;

  CURSOR cur_override
  IS
  SELECT DECODE(p_required,hr_api.g_number,required,p_required),
         DECODE(p_required_override,hr_api.g_number,required_override,p_required_override),
         form_tab_page_id,
         DECODE(p_form_tab_page_id_override,hr_api.g_number,form_tab_page_id_override,p_form_tab_page_id_override),
         DECODE(p_visible,hr_api.g_number,visible,p_visible),
         DECODE(p_visible_override,hr_api.g_number,visible_override,p_visible_override)
  FROM hr_form_items
  WHERE form_item_id = p_form_item_id;

  l_required number ;
  l_required_override number ;
  l_form_tab_page_id_override number ;
  l_form_tab_page_id number ;
  l_visible_override number ;
  l_visible number ;
  l_proc                varchar2(72) := g_package||'update_form_item';
  l_object_version_number number;
  l_override_value_warning boolean := FALSE;

  l_temp_ovn   number := p_object_version_number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_form_item;
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
    hr_form_items_api_bk3.update_form_item_b
      (p_effective_date             => TRUNC(p_effective_date)
      ,p_language_code              => l_language_code
      ,p_form_item_id               => p_form_item_id
      ,p_object_version_number      => l_object_version_number
      ,p_full_item_name             => p_full_item_name
      --,p_item_type                  => p_item_type
      ,p_user_item_name             => p_user_item_name
      ,p_description                => p_description
      ,p_radio_button_name          => p_radio_button_name
      ,p_required_override          => p_required_override
      ,p_form_tab_page_id_override  => p_form_tab_page_id_override
      ,p_visible_override           => p_visible_override
      ,p_alignment                  => p_alignment
      ,p_bevel                      => p_bevel
      ,p_case_restriction           => p_case_restriction
      ,p_default_value              => p_default_value
      ,p_enabled                    => p_enabled
      ,p_format_mask                => p_format_mask
      ,p_height                     => p_height
      ,p_information_formula_id     => p_information_formula_id
      ,p_information_param_item_id1 => p_information_param_item_id1
      ,p_information_param_item_id2 => p_information_param_item_id2
      ,p_information_param_item_id3 => p_information_param_item_id3
      ,p_information_param_item_id4 => p_information_param_item_id4
      ,p_information_param_item_id5 => p_information_param_item_id5
      ,p_information_prompt         => p_information_prompt
      ,p_insert_allowed             => p_insert_allowed
      ,p_label                      => p_label
      ,p_prompt_text                => p_prompt_text
      ,p_prompt_alignment_offset    => p_prompt_alignment_offset
      ,p_prompt_display_style       => p_prompt_display_style
      ,p_prompt_edge                => p_prompt_edge
      ,p_prompt_edge_alignment      => p_prompt_edge_alignment
      ,p_prompt_edge_offset         => p_prompt_edge_offset
      ,p_prompt_text_alignment      => p_prompt_text_alignment
      ,p_query_allowed              => p_query_allowed
      ,p_required                   => p_required
      ,p_tooltip_text               => p_tooltip_text
      ,p_update_allowed             => p_update_allowed
      ,p_validation_formula_id      => p_validation_formula_id
      ,p_validation_param_item_id1  => p_validation_param_item_id1
      ,p_validation_param_item_id2  => p_validation_param_item_id2
      ,p_validation_param_item_id3  => p_validation_param_item_id3
      ,p_validation_param_item_id4  => p_validation_param_item_id4
      ,p_validation_param_item_id5  => p_validation_param_item_id5
      ,p_visible                    => p_visible
      ,p_width                      => p_width
      ,p_x_position                 => p_x_position
      ,p_y_position                 => p_y_position
      ,p_information_category       => p_information_category
      ,p_information1               => p_information1
      ,p_information2               => p_information2
      ,p_information3               => p_information3
      ,p_information4               => p_information4
      ,p_information5               => p_information5
      ,p_information6               => p_information6
      ,p_information7               => p_information7
      ,p_information8               => p_information8
      ,p_information9               => p_information9
      ,p_information10              => p_information10
      ,p_information11              => p_information11
      ,p_information12              => p_information12
      ,p_information13              => p_information13
      ,p_information14              => p_information14
      ,p_information15              => p_information15
      ,p_information16              => p_information16
      ,p_information17              => p_information17
      ,p_information18              => p_information18
      ,p_information19              => p_information19
      ,p_information20              => p_information20
      ,p_information21              => p_information21
      ,p_information22              => p_information22
      ,p_information23              => p_information23
      ,p_information24              => p_information24
      ,p_information25              => p_information25
      ,p_information26              => p_information26
      ,p_information27              => p_information27
      ,p_information28              => p_information28
      ,p_information29              => p_information29
      ,p_information30              => p_information30
      ,p_next_navigation_item_id      => p_next_navigation_item_id
      ,p_previous_navigation_item_id  => p_previous_navigation_item_id);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_form_item'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --

  hr_utility.set_location('At:'|| l_proc, 15);

  OPEN cur_override;
  FETCH cur_override INTO l_required,l_required_override,l_form_tab_page_id,
        l_form_tab_page_id_override,l_visible,l_visible_override;
  CLOSE cur_override;

  IF ( l_required_override is not null AND l_required is not null ) OR
     ( l_form_tab_page_id_override is not null AND l_form_tab_page_id is not null ) OR
     ( l_visible_override is not null AND l_visible is not null ) THEN
     l_override_value_warning := TRUE;
  END IF;

  hr_utility.set_location('At:'|| l_proc, 20);

  hr_fim_upd.upd(p_effective_date                => TRUNC(p_effective_date)
                 ,p_form_item_id                 => p_form_item_id
                 ,p_full_item_name               => p_full_item_name
                 --,p_item_type                    => p_item_type
                 ,p_radio_button_name            => p_radio_button_name
                 ,p_required_override            => p_required_override
                 ,p_form_tab_page_id_override    => p_form_tab_page_id_override
                 ,p_visible_override             => p_visible_override
                 ,p_object_version_number        => l_object_version_number);

  hr_utility.set_location('At:'|| l_proc, 25);

  hr_fit_upd.upd_tl( p_language_code                => l_language_code
                      ,p_form_item_id                 => p_form_item_id
                      ,p_user_item_name               => p_user_item_name
                      ,p_description                  => p_description);

  hr_utility.set_location('At:'|| l_proc, 30);

  hr_item_properties_bsi.update_item_property(
            p_effective_date                => TRUNC(p_effective_date)
            ,p_language_code                => l_language_code
            ,p_object_version_number        => l_object_version_number
            ,p_form_item_id                 => p_form_item_id
            ,p_alignment                    => p_alignment
            ,p_bevel                        => p_bevel
            ,p_case_restriction             => p_case_restriction
            ,p_default_value                => p_default_value
            ,p_enabled                      => p_enabled
            ,p_format_mask                  => p_format_mask
            ,p_height                       => p_height
            ,p_information_formula_id       => p_information_formula_id
            ,p_information_param_item_id1   => p_information_param_item_id1
            ,p_information_param_item_id2   => p_information_param_item_id2
            ,p_information_param_item_id3   => p_information_param_item_id3
            ,p_information_param_item_id4   => p_information_param_item_id4
            ,p_information_param_item_id5   => p_information_param_item_id5
            ,p_information_prompt           => p_information_prompt
            ,p_insert_allowed               => p_insert_allowed
            ,p_label                        => p_label
            ,p_prompt_text                  => p_prompt_text
            ,p_prompt_alignment_offset      => p_prompt_alignment_offset
            ,p_prompt_display_style         => p_prompt_display_style
            ,p_prompt_edge                  => p_prompt_edge
            ,p_prompt_edge_alignment        => p_prompt_edge_alignment
            ,p_prompt_edge_offset           => p_prompt_edge_offset
            ,p_prompt_text_alignment        => p_prompt_text_alignment
            ,p_query_allowed                => p_query_allowed
            ,p_required                     => p_required
            ,p_tooltip_text                 => p_tooltip_text
            ,p_update_allowed               => p_update_allowed
            ,p_validation_formula_id        => p_validation_formula_id
            ,p_validation_param_item_id1    => p_validation_param_item_id1
            ,p_validation_param_item_id2    => p_validation_param_item_id2
            ,p_validation_param_item_id3    => p_validation_param_item_id3
            ,p_validation_param_item_id4    => p_validation_param_item_id4
            ,p_validation_param_item_id5    => p_validation_param_item_id5
            ,p_visible                      => p_visible
            ,p_width                        => p_width
            ,p_x_position                   => p_x_position
            ,p_y_position                   => p_y_position
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
            ,p_next_navigation_item_id      => p_next_navigation_item_id
            ,p_previous_navigation_item_id  => p_previous_navigation_item_id);
           -- ,p_override_value_warning       => l_override_value_warning);

  hr_utility.set_location('At:'|| l_proc, 35);

  --
  -- Call After Process User Hook
  --
  begin
    hr_form_items_api_bk3.update_form_item_a
     (p_effective_date             => TRUNC(p_effective_date)
     ,p_language_code              => l_language_code
     ,p_form_item_id               => p_form_item_id
     ,p_object_version_number      => l_object_version_number
     ,p_full_item_name             => p_full_item_name
     --,p_item_type                  => p_item_type
     ,p_user_item_name             => p_user_item_name
     ,p_description                => p_description
     ,p_radio_button_name          => p_radio_button_name
     ,p_required_override          => p_required_override
     ,p_form_tab_page_id_override  => p_form_tab_page_id_override
     ,p_visible_override           => p_visible_override
     ,p_alignment                  => p_alignment
     ,p_bevel                      => p_bevel
     ,p_case_restriction           => p_case_restriction
     ,p_default_value              => p_default_value
     ,p_enabled                    => p_enabled
     ,p_format_mask                => p_format_mask
     ,p_height                     => p_height
     ,p_information_formula_id     => p_information_formula_id
     ,p_information_param_item_id1 => p_information_param_item_id1
     ,p_information_param_item_id2 => p_information_param_item_id2
     ,p_information_param_item_id3 => p_information_param_item_id3
     ,p_information_param_item_id4 => p_information_param_item_id4
     ,p_information_param_item_id5 => p_information_param_item_id5
     ,p_information_prompt         => p_information_prompt
     ,p_insert_allowed             => p_insert_allowed
     ,p_label                      => p_label
     ,p_prompt_text                => p_prompt_text
     ,p_prompt_alignment_offset    => p_prompt_alignment_offset
     ,p_prompt_display_style       => p_prompt_display_style
     ,p_prompt_edge                => p_prompt_edge
     ,p_prompt_edge_alignment      => p_prompt_edge_alignment
     ,p_prompt_edge_offset         => p_prompt_edge_offset
     ,p_prompt_text_alignment      => p_prompt_text_alignment
     ,p_query_allowed              => p_query_allowed
     ,p_required                   => p_required
     ,p_tooltip_text               => p_tooltip_text
     ,p_update_allowed             => p_update_allowed
     ,p_validation_formula_id      => p_validation_formula_id
     ,p_validation_param_item_id1  => p_validation_param_item_id1
     ,p_validation_param_item_id2  => p_validation_param_item_id2
     ,p_validation_param_item_id3  => p_validation_param_item_id3
     ,p_validation_param_item_id4  => p_validation_param_item_id4
     ,p_validation_param_item_id5  => p_validation_param_item_id5
     ,p_visible                    => p_visible
     ,p_width                      => p_width
     ,p_x_position                 => p_x_position
     ,p_y_position                 => p_y_position
     ,p_information_category       => p_information_category
     ,p_information1               => p_information1
     ,p_information2               => p_information2
     ,p_information3               => p_information3
     ,p_information4               => p_information4
     ,p_information5               => p_information5
     ,p_information6               => p_information6
     ,p_information7               => p_information7
     ,p_information8               => p_information8
     ,p_information9               => p_information9
     ,p_information10              => p_information10
     ,p_information11              => p_information11
     ,p_information12              => p_information12
     ,p_information13              => p_information13
     ,p_information14              => p_information14
     ,p_information15              => p_information15
     ,p_information16              => p_information16
     ,p_information17              => p_information17
     ,p_information18              => p_information18
     ,p_information19              => p_information19
     ,p_information20              => p_information20
     ,p_information21              => p_information21
     ,p_information22              => p_information22
     ,p_information23              => p_information23
     ,p_information24              => p_information24
     ,p_information25              => p_information25
     ,p_information26              => p_information26
     ,p_information27              => p_information27
     ,p_information28              => p_information28
     ,p_information29              => p_information29
     ,p_information30              => p_information30
     ,p_next_navigation_item_id      => p_next_navigation_item_id
     ,p_previous_navigation_item_id  => p_previous_navigation_item_id
     ,p_override_value_warning     => l_override_value_warning);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_form_item'
        ,p_hook_type   => 'AP'
        );
  end;

  hr_utility.set_location('At:'|| l_proc, 40);

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
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
    rollback to update_form_item;
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
    rollback to update_form_item;
    -- Reset IN OUT and set OUT parameters.
    p_object_version_number  := l_temp_ovn;
    p_override_value_warning := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_form_item;
--
end hr_form_items_api;

/
