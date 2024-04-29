--------------------------------------------------------
--  DDL for Package Body HR_ITEM_PROPERTIES_BSI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ITEM_PROPERTIES_BSI" as
/* $Header: hritpbsi.pkb 120.0 2005/05/31 00:59:30 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_item_properties_bsi.';
--
-- ----------------------------------------------------------------------------
PROCEDURE update_radio_button_property
  (p_effective_date                  IN     DATE
  ,p_language_code                   IN     VARCHAR2
  ,p_form_item_id                    IN     NUMBER
  ,p_template_item_id                IN     NUMBER
  ,p_template_item_context_id        IN     NUMBER
  ,p_default_value                   IN     VARCHAR2
  ,p_information_formula_id          IN     NUMBER
  ,p_information_param_item_id1      IN     NUMBER
  ,p_information_param_item_id2      IN     NUMBER
  ,p_information_param_item_id3      IN     NUMBER
  ,p_information_param_item_id4      IN     NUMBER
  ,p_information_param_item_id5      IN     NUMBER
  ,p_information_prompt              IN     VARCHAR2
  ,p_insert_allowed                  IN     NUMBER
  ,p_next_navigation_item_id         IN     NUMBER
  ,p_previous_navigation_item_id     IN     NUMBER
  ,p_query_allowed                   IN     NUMBER
  ,p_tooltip_text                    IN     VARCHAR2
  ,p_update_allowed                  IN     NUMBER
  ,p_validation_formula_id           IN     NUMBER
  ,p_validation_param_item_id1       IN     NUMBER
  ,p_validation_param_item_id2       IN     NUMBER
  ,p_validation_param_item_id3       IN     NUMBER
  ,p_validation_param_item_id4       IN     NUMBER
  ,p_validation_param_item_id5       IN     NUMBER
  ,p_object_version_number           in out nocopy number
  )
IS
  CURSOR csr_form_items
    (p_form_item_id                     IN     NUMBER
    )
  IS
    SELECT itp.item_property_id
      FROM hr_item_properties_b itp
          ,hr_form_items_b fi2
          ,hr_form_items_b fi1
     WHERE itp.form_item_id = fi2.form_item_id
       AND fi2.application_id = fi1.application_id
       AND fi2.form_id = fi1.form_id
       AND fi2.full_item_name = fi1.full_item_name
       AND fi2.form_item_id <> fi1.form_item_id
       AND fi1.item_type = 'RADIO_BUTTON'
       AND fi1.form_item_id = p_form_item_id;
  CURSOR csr_template_items
    (p_template_item_id                 IN     NUMBER
    )
  IS
    SELECT itp.item_property_id
      FROM hr_item_properties_b itp
          ,hr_template_items_b ti2
          ,hr_form_items_b fi2
          ,hr_form_items_b fi1
          ,hr_template_items_b ti1
     WHERE itp.template_item_id = ti2.template_item_id
       AND ti2.form_template_id = ti1.form_template_id
       AND ti2.form_item_id = fi2.form_item_id
       AND fi2.application_id = fi1.application_id
       AND fi2.form_id = fi1.form_id
       AND fi2.full_item_name = fi1.full_item_name
       AND fi2.form_item_id <> fi1.form_item_id
       AND fi1.item_type = 'RADIO_BUTTON'
       AND fi1.form_item_id = ti1.form_item_id
       AND ti1.template_item_id = p_template_item_id;
  CURSOR csr_template_item_contexts
    (p_template_item_context_id         IN     NUMBER
    )
  IS
    SELECT itp.item_property_id
      FROM hr_item_properties_b itp
          ,hr_template_item_contexts_b tc2
          ,hr_template_items_b ti2
          ,hr_form_items_b fi2
          ,hr_form_items_b fi1
          ,hr_template_items_b ti1
          ,hr_template_item_contexts_b tc1
     WHERE itp.template_item_context_id = tc2.template_item_context_id
       AND tc2.item_context_id = tc1.item_context_id
       AND tc2.template_item_id = ti2.template_item_id
       AND ti2.form_template_id = ti1.form_template_id
       AND ti2.form_item_id = fi2.form_item_id
       AND fi2.application_id = fi1.application_id
       AND fi2.form_id = fi1.form_id
       AND fi2.full_item_name = fi1.full_item_name
       AND fi2.form_item_id <> fi1.form_item_id
       AND fi1.item_type = 'RADIO_BUTTON'
       AND fi1.form_item_id = ti1.form_item_id
       AND ti1.template_item_id = tc1.template_item_id
       AND tc1.template_item_context_id = p_template_item_context_id;
  PROCEDURE update_radio_button_property_i
    (p_item_property_id            IN     NUMBER
    )
  IS
  BEGIN
    hr_itp_upd.upd
      (p_effective_date              => p_effective_date
      ,p_item_property_id            => p_item_property_id
      ,p_object_version_number       => p_object_version_number
      ,p_information_formula_id      => p_information_formula_id
      ,p_information_param_item_id1  => p_information_param_item_id1
      ,p_information_param_item_id2  => p_information_param_item_id2
      ,p_information_param_item_id3  => p_information_param_item_id3
      ,p_information_param_item_id4  => p_information_param_item_id4
      ,p_information_param_item_id5  => p_information_param_item_id5
      ,p_insert_allowed              => p_insert_allowed
      ,p_next_navigation_item_id     => p_next_navigation_item_id
      ,p_previous_navigation_item_id => p_previous_navigation_item_id
      ,p_query_allowed               => p_query_allowed
      ,p_update_allowed              => p_update_allowed
      ,p_validation_formula_id       => p_validation_formula_id
      ,p_validation_param_item_id1   => p_validation_param_item_id1
      ,p_validation_param_item_id2   => p_validation_param_item_id2
      ,p_validation_param_item_id3   => p_validation_param_item_id3
      ,p_validation_param_item_id4   => p_validation_param_item_id4
      ,p_validation_param_item_id5   => p_validation_param_item_id5
      );
    hr_ipt_upd.upd_tl
      (p_language_code               => p_language_code
      ,p_default_value               => p_default_value
      ,p_item_property_id            => p_item_property_id
      ,p_information_prompt          => p_information_prompt
      ,p_tooltip_text                => p_tooltip_text
      );
  END update_radio_button_property_i;
BEGIN
  IF (p_form_item_id IS NOT NULL)
  THEN
    FOR l_item_property IN csr_form_items(p_form_item_id)
    LOOP
      update_radio_button_property_i(l_item_property.item_property_id);
    END LOOP;
  ELSIF (p_template_item_id IS NOT NULL)
  THEN
    FOR l_item_property IN csr_template_items(p_template_item_id)
    LOOP
      update_radio_button_property_i(l_item_property.item_property_id);
    END LOOP;
  ELSIF (p_template_item_context_id IS NOT NULL)
  THEN
    FOR l_item_property IN csr_template_item_contexts(p_template_item_context_id)
    LOOP
      update_radio_button_property_i(l_item_property.item_property_id);
    END LOOP;
  END IF;
END update_radio_button_property;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_item_property >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_item_property
  (p_validate                        in     boolean  default false
  ,p_effective_date                  in     date
  ,p_language_code                   in varchar2 default hr_api.userenv_lang
  ,p_form_item_id                    in number default null
  ,p_template_item_id                in number default null
  ,p_template_item_context_id        in number default null
  ,p_alignment                       in number default null
  ,p_bevel                           in number default null
  ,p_case_restriction                in number default null
  ,p_default_value                   in varchar2 default null
  ,p_enabled                         in number default null
  ,p_format_mask                     in varchar2 default null
  ,p_height                          in number default null
  ,p_information_formula_id          in number default null
  ,p_information_param_item_id1      in number default null
  ,p_information_param_item_id2      in number default null
  ,p_information_param_item_id3      in number default null
  ,p_information_param_item_id4      in number default null
  ,p_information_param_item_id5      in number default null
  ,p_information_prompt              in varchar2 default null
  ,p_insert_allowed                  in number default null
  ,p_label                           in varchar2 default null
  ,p_prompt_text                     in varchar2 default null
  ,p_prompt_alignment_offset         in number default null
  ,p_prompt_display_style            in number default null
  ,p_prompt_edge                     in number default null
  ,p_prompt_edge_alignment           in number default null
  ,p_prompt_edge_offset              in number default null
  ,p_prompt_text_alignment           in number default null
  ,p_query_allowed                   in number default null
  ,p_required                        in number default null
  ,p_tooltip_text                    in varchar2 default null
  ,p_update_allowed                  in number default null
  ,p_validation_formula_id           in number default null
  ,p_validation_param_item_id1       in number default null
  ,p_validation_param_item_id2       in number default null
  ,p_validation_param_item_id3       in number default null
  ,p_validation_param_item_id4       in number default null
  ,p_validation_param_item_id5       in number default null
  ,p_visible                         in number default null
  ,p_width                           in number default null
  ,p_x_position                      in number default null
  ,p_y_position                      in number default null
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
  ,p_next_navigation_item_id         in number default null
  ,p_previous_navigation_item_id     in number default null
  ,p_item_property_id                  out nocopy number
  ,p_object_version_number             out nocopy number
  --,p_override_value_warning            out boolean
  ) is
  --
  -- Declare cursors and local variables
  --

  l_language_code fnd_languages.language_code%TYPE;

  l_item_property_id                  number;
  l_object_version_number             number;
  l_override_value_warning            boolean;
  l_proc                varchar2(72) := g_package||'create_item_property';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_item_property;
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
  -- Process Logic
  --
  hr_itp_ins.ins(p_effective_date            => TRUNC(p_effective_date)
             ,p_form_item_id                 => p_form_item_id
             ,p_template_item_id             => p_template_item_id
             ,p_template_item_context_id     => p_template_item_context_id
             ,p_alignment                    => p_alignment
             ,p_bevel                        => p_bevel
             ,p_case_restriction             => p_case_restriction
             ,p_enabled                      => p_enabled
             ,p_format_mask                  => p_format_mask
             ,p_height                       => p_height
             ,p_information_formula_id       => p_information_formula_id
             ,p_information_param_item_id1   => p_information_param_item_id1
             ,p_information_param_item_id2   => p_information_param_item_id2
             ,p_information_param_item_id3   => p_information_param_item_id3
             ,p_information_param_item_id4   => p_information_param_item_id4
             ,p_information_param_item_id5   => p_information_param_item_id5
             ,p_insert_allowed               => p_insert_allowed
             ,p_prompt_alignment_offset      => p_prompt_alignment_offset
             ,p_prompt_display_style         => p_prompt_display_style
             ,p_prompt_edge                  => p_prompt_edge
             ,p_prompt_edge_alignment        => p_prompt_edge_alignment
             ,p_prompt_edge_offset           => p_prompt_edge_offset
             ,p_prompt_text_alignment        => p_prompt_text_alignment
             ,p_query_allowed                => p_query_allowed
             ,p_required                     => p_required
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
--             ,p_override_value_warning       => l_override_value_warning);

  hr_ipt_ins.ins_tl(p_language_code                => l_language_code
                       ,p_item_property_id             => l_item_property_id
                       ,p_default_value                => p_default_value
                       ,p_information_prompt           => p_information_prompt
                       ,p_label                        => p_label
                       ,p_prompt_text                  => p_prompt_text
                       ,p_tooltip_text                 => p_tooltip_text);
  --
  -- Update properties common across all buttons of a radio group
  --
  update_radio_button_property
    (p_effective_date                  => TRUNC(p_effective_date)
    ,p_language_code                   => l_language_code
    ,p_form_item_id                    => p_form_item_id
    ,p_template_item_id                => p_template_item_id
    ,p_template_item_context_id        => p_template_item_context_id
    ,p_default_value                   => p_default_value
    ,p_information_formula_id          => p_information_formula_id
    ,p_information_param_item_id1      => p_information_param_item_id1
    ,p_information_param_item_id2      => p_information_param_item_id2
    ,p_information_param_item_id3      => p_information_param_item_id3
    ,p_information_param_item_id4      => p_information_param_item_id4
    ,p_information_param_item_id5      => p_information_param_item_id5
    ,p_information_prompt              => p_information_prompt
    ,p_insert_allowed                  => p_insert_allowed
    ,p_next_navigation_item_id         => p_next_navigation_item_id
    ,p_previous_navigation_item_id     => p_previous_navigation_item_id
    ,p_query_allowed                   => p_query_allowed
    ,p_tooltip_text                    => p_tooltip_text
    ,p_update_allowed                  => p_update_allowed
    ,p_validation_formula_id           => p_validation_formula_id
    ,p_validation_param_item_id1       => p_validation_param_item_id1
    ,p_validation_param_item_id2       => p_validation_param_item_id2
    ,p_validation_param_item_id3       => p_validation_param_item_id3
    ,p_validation_param_item_id4       => p_validation_param_item_id4
    ,p_validation_param_item_id5       => p_validation_param_item_id5
    ,p_object_version_number           => l_object_version_number
    );
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_item_property_id             := l_item_property_id;
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
    rollback to create_item_property;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_item_property_id             := null;
    --p_override_value_warning       := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_item_property;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_item_property;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_item_property >------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_item_property
  (p_validate                        in     boolean  default false
  ,p_effective_date                  in     date
  ,p_language_code                   in varchar2 default hr_api.userenv_lang
  ,p_item_property_id                in number default null
  ,p_object_version_number           in out nocopy number
  ,p_form_item_id                    in number default null
  ,p_template_item_id                in number default null
  ,p_template_item_context_id        in number default null
  ,p_alignment                       in number default hr_api.g_number
  ,p_bevel                           in number default hr_api.g_number
  ,p_case_restriction                in number default hr_api.g_number
  ,p_default_value                   in varchar2 default hr_api.g_varchar2
  ,p_enabled                         in number default hr_api.g_number
  ,p_format_mask                     in varchar2 default hr_api.g_varchar2
  ,p_height                          in number default hr_api.g_number
  ,p_information_formula_id          in number default hr_api.g_number
  ,p_information_param_item_id1      in number default hr_api.g_number
  ,p_information_param_item_id2      in number default hr_api.g_number
  ,p_information_param_item_id3      in number default hr_api.g_number
  ,p_information_param_item_id4      in number default hr_api.g_number
  ,p_information_param_item_id5      in number default hr_api.g_number
  ,p_information_prompt              in varchar2 default hr_api.g_varchar2
  ,p_insert_allowed                  in number default hr_api.g_number
  ,p_label                           in varchar2 default hr_api.g_varchar2
  ,p_prompt_text                     in varchar2 default hr_api.g_varchar2
  ,p_prompt_alignment_offset         in number default hr_api.g_number
  ,p_prompt_display_style            in number default hr_api.g_number
  ,p_prompt_edge                     in number default hr_api.g_number
  ,p_prompt_edge_alignment           in number default hr_api.g_number
  ,p_prompt_edge_offset              in number default hr_api.g_number
  ,p_prompt_text_alignment           in number default hr_api.g_number
  ,p_query_allowed                   in number default hr_api.g_number
  ,p_required                        in number default hr_api.g_number
  ,p_tooltip_text                    in varchar2 default hr_api.g_varchar2
  ,p_update_allowed                  in number default hr_api.g_number
  ,p_validation_formula_id           in number default hr_api.g_number
  ,p_validation_param_item_id1       in number default hr_api.g_number
  ,p_validation_param_item_id2       in number default hr_api.g_number
  ,p_validation_param_item_id3       in number default hr_api.g_number
  ,p_validation_param_item_id4       in number default hr_api.g_number
  ,p_validation_param_item_id5       in number default hr_api.g_number
  ,p_visible                         in number default hr_api.g_number
  ,p_width                           in number default hr_api.g_number
  ,p_x_position                      in number default hr_api.g_number
  ,p_y_position                      in number default hr_api.g_number
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
  ,p_next_navigation_item_id         in number   default hr_api.g_number
  ,p_previous_navigation_item_id     in number   default hr_api.g_number
  --,p_override_value_warning            out boolean
  ) is
  --
  -- Declare cursors and local variables
  --

  l_language_code fnd_languages.language_code%TYPE;

  CURSOR cur_item_prop_1
  IS
  SELECT item_property_id
  FROM hr_item_properties_b
  WHERE form_item_id = p_form_item_id;

  CURSOR cur_item_prop_2
  IS
  SELECT item_property_id
  FROM hr_item_properties_b
  WHERE template_item_id = p_template_item_id;

  CURSOR cur_item_prop_3
  IS
  SELECT item_property_id
  FROM hr_item_properties_b
  WHERE template_item_context_id = p_template_item_context_id;

  l_item_property_id number;
  l_proc                varchar2(72) := g_package||'update_item_property';
  l_override_value_warning            boolean;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_item_property;
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
  -- Validation in addition to Row Handlers
  --
  hr_utility.set_location('At:'|| l_proc, 15);

  IF ( p_item_property_id is not null ) AND
     (p_template_item_context_id is not null OR p_form_item_id is not null OR
      p_template_item_id is not null) THEN
    -- error message
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ELSIF (p_template_item_context_id is not null ) AND
        ( p_form_item_id is not null OR p_item_property_id is not null
          OR p_template_item_id is not null) THEN
    -- error message
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ELSIF( p_template_item_id is not null) AND
       ( p_item_property_id is not null
         OR p_template_item_context_id is not null
         OR p_form_item_id is not null) THEN
    -- error message
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ELSIF( p_form_item_id is not null) AND
       ( p_item_property_id is not null
         OR p_template_item_context_id is not null
         OR p_template_item_id is not null) THEN
    -- error message
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  END IF;

  --
  -- Process Logic
  --
  hr_utility.set_location('At:'|| l_proc, 20);

  l_item_property_id := p_item_property_id;

  IF p_form_item_id is not null THEN
    OPEN cur_item_prop_1;
    FETCH cur_item_prop_1 INTO l_item_property_id;
    CLOSE cur_item_prop_1;
  END IF;
  IF p_template_item_id is not null THEN
    OPEN cur_item_prop_2;
    FETCH cur_item_prop_2 INTO l_item_property_id;
    CLOSE cur_item_prop_2;
  END IF;
  IF p_template_item_context_id is not null THEN
    OPEN cur_item_prop_3;
    FETCH cur_item_prop_3 INTO l_item_property_id;
    CLOSE cur_item_prop_3;
  END IF;

  hr_utility.set_location('At:'|| l_proc, 25);

  hr_itp_upd.upd(p_effective_date            => TRUNC(p_effective_date)
             ,p_item_property_id             => l_item_property_id
             ,p_object_version_number        => p_object_version_number
             ,p_alignment                    => p_alignment
             ,p_bevel                        => p_bevel
             ,p_case_restriction             => p_case_restriction
             ,p_enabled                      => p_enabled
             ,p_format_mask                  => p_format_mask
             ,p_height                       => p_height
             ,p_information_formula_id       => p_information_formula_id
             ,p_information_param_item_id1   => p_information_param_item_id1
             ,p_information_param_item_id2   => p_information_param_item_id2
             ,p_information_param_item_id3   => p_information_param_item_id3
             ,p_information_param_item_id4   => p_information_param_item_id4
             ,p_information_param_item_id5   => p_information_param_item_id5
             ,p_insert_allowed               => p_insert_allowed
             ,p_prompt_alignment_offset      => p_prompt_alignment_offset
             ,p_prompt_display_style         => p_prompt_display_style
             ,p_prompt_edge                  => p_prompt_edge
             ,p_prompt_edge_alignment        => p_prompt_edge_alignment
             ,p_prompt_edge_offset           => p_prompt_edge_offset
             ,p_prompt_text_alignment        => p_prompt_text_alignment
             ,p_query_allowed                => p_query_allowed
             ,p_required                     => p_required
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

  hr_utility.set_location('At:'|| l_proc, 30);

  hr_ipt_upd.upd_tl(p_language_code                => l_language_code
             ,p_item_property_id             => l_item_property_id
             ,p_default_value                => p_default_value
             ,p_information_prompt           => p_information_prompt
             ,p_label                        => p_label
             ,p_prompt_text                  => p_prompt_text
             ,p_tooltip_text                 => p_tooltip_text);

  --
  -- Update properties common across all buttons of a radio group
  --
  update_radio_button_property
    (p_effective_date                  => TRUNC(p_effective_date)
    ,p_language_code                   => l_language_code
    ,p_form_item_id                    => p_form_item_id
    ,p_template_item_id                => p_template_item_id
    ,p_template_item_context_id        => p_template_item_context_id
    ,p_default_value                   => p_default_value
    ,p_information_formula_id          => p_information_formula_id
    ,p_information_param_item_id1      => p_information_param_item_id1
    ,p_information_param_item_id2      => p_information_param_item_id2
    ,p_information_param_item_id3      => p_information_param_item_id3
    ,p_information_param_item_id4      => p_information_param_item_id4
    ,p_information_param_item_id5      => p_information_param_item_id5
    ,p_information_prompt              => p_information_prompt
    ,p_insert_allowed                  => p_insert_allowed
    ,p_next_navigation_item_id         => p_next_navigation_item_id
    ,p_previous_navigation_item_id     => p_previous_navigation_item_id
    ,p_query_allowed                   => p_query_allowed
    ,p_tooltip_text                    => p_tooltip_text
    ,p_update_allowed                  => p_update_allowed
    ,p_validation_formula_id           => p_validation_formula_id
    ,p_validation_param_item_id1       => p_validation_param_item_id1
    ,p_validation_param_item_id2       => p_validation_param_item_id2
    ,p_validation_param_item_id3       => p_validation_param_item_id3
    ,p_validation_param_item_id4       => p_validation_param_item_id4
    ,p_validation_param_item_id5       => p_validation_param_item_id5
    ,p_object_version_number           => p_object_version_number
    );
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  hr_utility.set_location('At:'|| l_proc, 35);

  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  --p_override_value_warning       := l_override_value_warning;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_item_property;
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
    rollback to update_item_property;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_item_property;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_item_property >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_item_property
  (p_validate                        in     boolean  default false
  ,p_item_property_id                in number default null
  ,p_form_item_id                    in number default null
  ,p_template_item_id                in number default null
  ,p_template_item_context_id        in number default null
  ,p_object_version_number           in     number
  ) is
  --
  -- Declare cursors and local variables
  --

  CURSOR cur_item_prop_1
  IS
  SELECT item_property_id
  FROM hr_item_properties_b
  WHERE form_item_id = p_form_item_id;

  CURSOR cur_item_prop_2
  IS
  SELECT item_property_id
  FROM hr_item_properties_b
  WHERE template_item_id = p_template_item_id;

  CURSOR cur_item_prop_3
  IS
  SELECT item_property_id
  FROM hr_item_properties_b
  WHERE template_item_context_id = p_template_item_context_id;

  l_item_property_id number;
  l_proc                varchar2(72) := g_package||'delete_item_property';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_item_property;
  --
  -- Validation in addition to Row Handlers
  --

  hr_utility.set_location('At:'|| l_proc, 15);

  IF ( p_item_property_id is not null ) AND
     (p_template_item_context_id is not null OR p_form_item_id is not null OR
      p_template_item_id is not null) THEN
    -- error message
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ELSIF (p_template_item_context_id is not null ) AND
        ( p_form_item_id is not null OR p_item_property_id is not null
          OR p_template_item_id is not null) THEN
    -- error message
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ELSIF( p_template_item_id is not null) AND
       ( p_item_property_id is not null
         OR p_template_item_context_id is not null
         OR p_form_item_id is not null) THEN
    -- error message
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ELSIF( p_form_item_id is not null) AND
       ( p_item_property_id is not null
         OR p_template_item_context_id is not null
         OR p_template_item_id is not null) THEN
    -- error message
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  END IF;

  --
  -- Process Logic
  --
  hr_utility.set_location('At:'|| l_proc, 20);

  l_item_property_id := p_item_property_id;

  IF p_form_item_id is not null THEN
    OPEN cur_item_prop_1;
    FETCH cur_item_prop_1 INTO l_item_property_id;
    CLOSE cur_item_prop_1;
  END IF;

  hr_utility.set_location('At:'|| l_proc, 25);

  IF p_template_item_id is not null THEN
    OPEN cur_item_prop_2;
    FETCH cur_item_prop_2 INTO l_item_property_id;
    CLOSE cur_item_prop_2;
  END IF;

  hr_utility.set_location('At:'|| l_proc, 30);

  IF p_template_item_context_id is not null THEN
    OPEN cur_item_prop_3;
    FETCH cur_item_prop_3 INTO l_item_property_id;
    CLOSE cur_item_prop_3;
  END IF;

  hr_utility.set_location('At:'|| l_proc, 35);
-- Bug 4018745 Starts Here
-- Desc: Added if condition to avoid the below calls if item_property_id is null.
if l_item_property_id is not null then
  hr_itp_shd.lck( p_item_property_id             => l_item_property_id
                , p_object_version_number        => p_object_version_number);

  hr_utility.set_location('At:'|| l_proc, 40);

  hr_ipt_del.del_tl( p_item_property_id             => l_item_property_id);

  hr_utility.set_location('At:'|| l_proc, 45);

  hr_itp_del.del( p_item_property_id             => l_item_property_id
                , p_object_version_number        => p_object_version_number);

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  hr_utility.set_location('At:'|| l_proc, 50);
end if;
-- Bug 4018745 Ends Here
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
    rollback to delete_item_property;
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
    rollback to delete_item_property;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_item_property;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< copy_item_property >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure copy_item_property
  (p_validate                        in     boolean  default false
  ,p_effective_date                  in     date
  ,p_language_code                   in varchar2 default hr_api.userenv_lang
  ,p_form_item_id                    in number
  ,p_template_item_id                in number
  ,p_alignment                       in number default hr_api.g_number
  ,p_bevel                           in number default hr_api.g_number
  ,p_case_restriction                in number default hr_api.g_number
  ,p_default_value                   in varchar2 default hr_api.g_varchar2
  ,p_enabled                         in number default hr_api.g_number
  ,p_format_mask                     in varchar2 default hr_api.g_varchar2
  ,p_height                          in number default hr_api.g_number
  ,p_information_formula_id          in number default hr_api.g_number
  ,p_information_param_item_id1      in number default hr_api.g_number
  ,p_information_param_item_id2      in number default hr_api.g_number
  ,p_information_param_item_id3      in number default hr_api.g_number
  ,p_information_param_item_id4      in number default hr_api.g_number
  ,p_information_param_item_id5      in number default hr_api.g_number
  ,p_information_prompt              in varchar2 default hr_api.g_varchar2
  ,p_insert_allowed                  in number default hr_api.g_number
  ,p_label                           in varchar2 default hr_api.g_varchar2
  ,p_prompt_text                     in varchar2 default hr_api.g_varchar2
  ,p_prompt_alignment_offset         in number default hr_api.g_number
  ,p_prompt_display_style            in number default hr_api.g_number
  ,p_prompt_edge                     in number default hr_api.g_number
  ,p_prompt_edge_alignment           in number default hr_api.g_number
  ,p_prompt_edge_offset              in number default hr_api.g_number
  ,p_prompt_text_alignment           in number default hr_api.g_number
  ,p_query_allowed                   in number default hr_api.g_number
  ,p_required                        in number default hr_api.g_number
  ,p_tooltip_text                    in varchar2 default hr_api.g_varchar2
  ,p_update_allowed                  in number default hr_api.g_number
  ,p_validation_formula_id           in number default hr_api.g_number
  ,p_validation_param_item_id1       in number default hr_api.g_number
  ,p_validation_param_item_id2       in number default hr_api.g_number
  ,p_validation_param_item_id3       in number default hr_api.g_number
  ,p_validation_param_item_id4       in number default hr_api.g_number
  ,p_validation_param_item_id5       in number default hr_api.g_number
  ,p_visible                         in number default hr_api.g_number
  ,p_width                           in number default hr_api.g_number
  ,p_x_position                      in number default hr_api.g_number
  ,p_y_position                      in number default hr_api.g_number
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
  ,p_next_navigation_item_id         in number default hr_api.g_number
  ,p_previous_navigation_item_id     in number default hr_api.g_number
  ,p_item_property_id                  out nocopy number
  ,p_object_version_number             out nocopy number
  --,p_override_value_warning            out boolean
  ) is
  --
  -- Declare cursors and local variables
  --

  Type l_rec_type Is Record
  (alignment hr_item_properties_b.alignment%TYPE
  ,bevel hr_item_properties_b.bevel%TYPE
  ,case_restriction hr_item_properties_b.case_restriction%TYPE
  ,enabled hr_item_properties_b.enabled%TYPE
  ,format_mask hr_item_properties_b.format_mask%TYPE
  ,height hr_item_properties_b.height%TYPE
  ,information_formula_id hr_item_properties_b.information_formula_id%TYPE
  ,information_param_item_id1 hr_item_properties_b.information_parameter_item_id1%TYPE
  ,information_param_item_id2 hr_item_properties_b.information_parameter_item_id2%TYPE
  ,information_param_item_id3 hr_item_properties_b.information_parameter_item_id3%TYPE
  ,information_param_item_id4 hr_item_properties_b.information_parameter_item_id4%TYPE
  ,information_param_item_id5 hr_item_properties_b.information_parameter_item_id5%TYPE
  ,insert_allowed hr_item_properties_b.insert_allowed%TYPE
  ,prompt_alignment_offset hr_item_properties_b.prompt_alignment_offset%TYPE
  ,prompt_display_style hr_item_properties_b.prompt_display_style%TYPE
  ,prompt_edge hr_item_properties_b.prompt_edge%TYPE
  ,prompt_edge_alignment hr_item_properties_b.prompt_edge_alignment%TYPE
  ,prompt_edge_offset hr_item_properties_b.prompt_edge_offset%TYPE
  ,prompt_text_alignment hr_item_properties_b.prompt_text_alignment%TYPE
  ,query_allowed hr_item_properties_b.query_allowed%TYPE
  ,required hr_item_properties_b.required%TYPE
  ,update_allowed hr_item_properties_b.update_allowed%TYPE
  ,validation_formula_id hr_item_properties_b.validation_formula_id%TYPE
  ,validation_param_item_id1 hr_item_properties_b.validation_parameter_item_id1%TYPE
  ,validation_param_item_id2 hr_item_properties_b.validation_parameter_item_id2%TYPE
  ,validation_param_item_id3 hr_item_properties_b.validation_parameter_item_id3%TYPE
  ,validation_param_item_id4 hr_item_properties_b.validation_parameter_item_id4%TYPE
  ,validation_param_item_id5 hr_item_properties_b.validation_parameter_item_id5%TYPE
  ,visible hr_item_properties_b.visible%TYPE
  ,width hr_item_properties_b.width%TYPE
  ,x_position hr_item_properties_b.x_position%TYPE
  ,y_position hr_item_properties_b.y_position%TYPE
  ,information_category hr_item_properties_b.information_category%TYPE
  ,information1 hr_item_properties_b.information1%TYPE
  ,information2 hr_item_properties_b.information2%TYPE
  ,information3 hr_item_properties_b.information3%TYPE
  ,information4 hr_item_properties_b.information4%TYPE
  ,information5 hr_item_properties_b.information5%TYPE
  ,information6 hr_item_properties_b.information6%TYPE
  ,information7 hr_item_properties_b.information7%TYPE
  ,information8 hr_item_properties_b.information8%TYPE
  ,information9 hr_item_properties_b.information9%TYPE
  ,information10 hr_item_properties_b.information10%TYPE
  ,information11 hr_item_properties_b.information11%TYPE
  ,information12 hr_item_properties_b.information12%TYPE
  ,information13 hr_item_properties_b.information13%TYPE
  ,information14 hr_item_properties_b.information14%TYPE
  ,information15 hr_item_properties_b.information15%TYPE
  ,information16 hr_item_properties_b.information16%TYPE
  ,information17 hr_item_properties_b.information17%TYPE
  ,information18 hr_item_properties_b.information18%TYPE
  ,information19 hr_item_properties_b.information19%TYPE
  ,information20 hr_item_properties_b.information20%TYPE
  ,information21 hr_item_properties_b.information21%TYPE
  ,information22 hr_item_properties_b.information22%TYPE
  ,information23 hr_item_properties_b.information23%TYPE
  ,information24 hr_item_properties_b.information24%TYPE
  ,information25 hr_item_properties_b.information25%TYPE
  ,information26 hr_item_properties_b.information26%TYPE
  ,information27 hr_item_properties_b.information27%TYPE
  ,information28 hr_item_properties_b.information28%TYPE
  ,information29 hr_item_properties_b.information29%TYPE
  ,information30 hr_item_properties_b.information30%TYPE
  ,next_navigation_item_id hr_item_properties_b.next_navigation_item_id%TYPE
  ,previous_navigation_item_id hr_item_properties_b.previous_navigation_item_id%TYPE
);

  l_rec l_rec_type;

  CURSOR cur_check
  IS
  SELECT 1
  FROM hr_template_items tit
  WHERE tit.template_item_id = p_template_item_id
  AND tit.form_item_id  = p_form_item_id;

-- added a outer join so that the correct values are returned
-- if there are no entries in the properties table
  CURSOR cur_item_prop
  IS
  SELECT DECODE(p_alignment,hr_api.g_number,itp.alignment,p_alignment)
  ,DECODE(p_bevel,hr_api.g_number,itp.bevel,p_bevel)
  ,DECODE(p_case_restriction,hr_api.g_number,itp.case_restriction,p_case_restriction)
  ,DECODE(p_enabled,hr_api.g_number,itp.enabled,p_enabled)
  ,DECODE(p_format_mask,hr_api.g_varchar2,itp.format_mask,p_format_mask)
  ,DECODE(p_height,hr_api.g_number,itp.height,p_height)
  ,DECODE(p_information_formula_id,hr_api.g_number,itp.information_formula_id,p_information_formula_id)
  ,DECODE(p_information_param_item_id1,hr_api.g_number,itp.information_parameter_item_id1,p_information_param_item_id1)
  ,DECODE(p_information_param_item_id2,hr_api.g_number,itp.information_parameter_item_id2,p_information_param_item_id2)
  ,DECODE(p_information_param_item_id3,hr_api.g_number,itp.information_parameter_item_id3,p_information_param_item_id3)
  ,DECODE(p_information_param_item_id4,hr_api.g_number,itp.information_parameter_item_id4,p_information_param_item_id4)
  ,DECODE(p_information_param_item_id5,hr_api.g_number,itp.information_parameter_item_id5,p_information_param_item_id5)
  ,DECODE(p_insert_allowed,hr_api.g_number,itp.insert_allowed,p_insert_allowed)
  ,DECODE(p_prompt_alignment_offset,hr_api.g_number,itp.prompt_alignment_offset,p_prompt_alignment_offset)
  ,DECODE(p_prompt_display_style,hr_api.g_number,itp.prompt_display_style,p_prompt_display_style)
  ,DECODE(p_prompt_edge,hr_api.g_number,itp.prompt_edge,p_prompt_edge)
  ,DECODE(p_prompt_edge_alignment,hr_api.g_number,itp.prompt_edge_alignment,p_prompt_edge_alignment)
  ,DECODE(p_prompt_edge_offset,hr_api.g_number,itp.prompt_edge_offset,p_prompt_edge_offset)
  ,DECODE(p_prompt_text_alignment,hr_api.g_number,itp.prompt_text_alignment,p_prompt_text_alignment)
  ,DECODE(p_query_allowed,hr_api.g_number,itp.query_allowed,p_query_allowed)
  ,DECODE(p_required,hr_api.g_number,itp.required,p_required)
  ,DECODE(p_update_allowed,hr_api.g_number,itp.update_allowed,p_update_allowed)
  ,DECODE(p_validation_formula_id,hr_api.g_number,itp.validation_formula_id,p_validation_formula_id)
  ,DECODE(p_validation_param_item_id1,hr_api.g_number,itp.validation_parameter_item_id1,p_validation_param_item_id1)
  ,DECODE(p_validation_param_item_id2,hr_api.g_number,itp.validation_parameter_item_id2,p_validation_param_item_id2)
  ,DECODE(p_validation_param_item_id3,hr_api.g_number,itp.validation_parameter_item_id3,p_validation_param_item_id3)
  ,DECODE(p_validation_param_item_id4,hr_api.g_number,itp.validation_parameter_item_id4,p_validation_param_item_id4)
  ,DECODE(p_validation_param_item_id5,hr_api.g_number,itp.validation_parameter_item_id5,p_validation_param_item_id5)
  ,DECODE(p_visible,hr_api.g_number,itp.visible,p_visible)
  ,DECODE(p_width,hr_api.g_number,itp.width,p_width)
  ,DECODE(p_x_position,hr_api.g_number,itp.x_position,p_x_position)
  ,DECODE(p_y_position,hr_api.g_number,itp.y_position,p_y_position)
  ,DECODE(p_information_category,hr_api.g_varchar2,itp.information_category,p_information_category)
  ,DECODE(p_information1,hr_api.g_varchar2,itp.information1,p_information1)
  ,DECODE(p_information2,hr_api.g_varchar2,itp.information2,p_information2)
  ,DECODE(p_information3,hr_api.g_varchar2,itp.information3,p_information3)
  ,DECODE(p_information4,hr_api.g_varchar2,itp.information4,p_information4)
  ,DECODE(p_information5,hr_api.g_varchar2,itp.information5,p_information5)
  ,DECODE(p_information6,hr_api.g_varchar2,itp.information6,p_information6)
  ,DECODE(p_information7,hr_api.g_varchar2,itp.information7,p_information7)
  ,DECODE(p_information8,hr_api.g_varchar2,itp.information8,p_information8)
  ,DECODE(p_information9,hr_api.g_varchar2,itp.information9,p_information9)
  ,DECODE(p_information10,hr_api.g_varchar2,itp.information10,p_information10)
  ,DECODE(p_information11,hr_api.g_varchar2,itp.information11,p_information11)
  ,DECODE(p_information12,hr_api.g_varchar2,itp.information12,p_information12)
  ,DECODE(p_information13,hr_api.g_varchar2,itp.information13,p_information13)
  ,DECODE(p_information14,hr_api.g_varchar2,itp.information14,p_information14)
  ,DECODE(p_information15,hr_api.g_varchar2,itp.information15,p_information15)
  ,DECODE(p_information16,hr_api.g_varchar2,itp.information16,p_information16)
  ,DECODE(p_information17,hr_api.g_varchar2,itp.information17,p_information17)
  ,DECODE(p_information18,hr_api.g_varchar2,itp.information18,p_information18)
  ,DECODE(p_information19,hr_api.g_varchar2,itp.information19,p_information19)
  ,DECODE(p_information20,hr_api.g_varchar2,itp.information20,p_information20)
  ,DECODE(p_information21,hr_api.g_varchar2,itp.information21,p_information21)
  ,DECODE(p_information22,hr_api.g_varchar2,itp.information22,p_information22)
  ,DECODE(p_information23,hr_api.g_varchar2,itp.information23,p_information23)
  ,DECODE(p_information24,hr_api.g_varchar2,itp.information24,p_information24)
  ,DECODE(p_information25,hr_api.g_varchar2,itp.information25,p_information25)
  ,DECODE(p_information26,hr_api.g_varchar2,itp.information26,p_information26)
  ,DECODE(p_information27,hr_api.g_varchar2,itp.information27,p_information27)
  ,DECODE(p_information28,hr_api.g_varchar2,itp.information28,p_information28)
  ,DECODE(p_information29,hr_api.g_varchar2,itp.information29,p_information29)
  ,DECODE(p_information30,hr_api.g_varchar2,itp.information30,p_information30)
  ,DECODE(p_next_navigation_item_id,hr_api.g_number,itp.next_navigation_item_id,p_next_navigation_item_id)
  ,DECODE(p_previous_navigation_item_id,hr_api.g_number,itp.previous_navigation_item_id,p_previous_navigation_item_id)
  FROM hr_item_properties_b itp
      , hr_form_items_b hfi
  WHERE itp.form_item_id (+) = hfi.form_item_id
  AND   hfi.form_item_id = p_form_item_id;

  CURSOR cur_item_tl
  IS
  SELECT COUNT(0) t_count
  ,itptl.source_lang
  ,DECODE(p_default_value,hr_api.g_varchar2,itptl.default_value,p_default_value) default_value
  ,DECODE(p_information_prompt,hr_api.g_varchar2,itptl.information_prompt,p_information_prompt) information_prompt
  ,DECODE(p_label,hr_api.g_varchar2,itptl.label,p_label) label
  ,DECODE(p_prompt_text,hr_api.g_varchar2,itptl.prompt_text,p_prompt_text) prompt_text
  ,DECODE(p_tooltip_text,hr_api.g_varchar2,itptl.tooltip_text,p_tooltip_text) tooltip_text
  FROM hr_item_properties_tl itptl
  ,hr_item_properties_b itp
  WHERE itptl.item_property_id = itp.item_property_id
  AND itp.form_item_id = p_form_item_id
  GROUP BY itptl.source_lang
  ,DECODE(p_default_value,hr_api.g_varchar2,itptl.default_value,p_default_value)
  ,DECODE(p_information_prompt,hr_api.g_varchar2,itptl.information_prompt,p_information_prompt)
  ,DECODE(p_label,hr_api.g_varchar2,itptl.label,p_label)
  ,DECODE(p_prompt_text,hr_api.g_varchar2,itptl.prompt_text,p_prompt_text)
  ,DECODE(p_tooltip_text,hr_api.g_varchar2,itptl.tooltip_text,p_tooltip_text)
  ORDER BY 1;

  l_language_code fnd_languages.language_code%TYPE;

  l_check number;
  l_item_property_id                  number ;
  l_object_version_number             number;
  l_override_value_warning            boolean;
  l_proc                varchar2(72) := g_package||'copy_item_property';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint copy_item_property;
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
  -- Validation in addition to Row Handlers
  --
  hr_utility.set_location('At:'|| l_proc, 15);

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
  hr_utility.set_location('At:'|| l_proc, 20);

  OPEN cur_item_prop;
  FETCH cur_item_prop INTO l_rec;
  CLOSE cur_item_prop;

  hr_utility.set_location('At:'|| l_proc, 25);

  hr_itp_ins.ins(p_effective_date           => TRUNC(p_effective_date)
            ,p_template_item_id             => p_template_item_id
            ,p_alignment                    => l_rec.alignment
            ,p_bevel                        => l_rec.bevel
            ,p_case_restriction             => l_rec.case_restriction
            ,p_enabled                      => l_rec.enabled
            ,p_format_mask                  => l_rec.format_mask
            ,p_height                       => l_rec.height
            ,p_information_formula_id       => l_rec.information_formula_id
            ,p_information_param_item_id1   => l_rec.information_param_item_id1
            ,p_information_param_item_id2   => l_rec.information_param_item_id2
            ,p_information_param_item_id3   => l_rec.information_param_item_id3
            ,p_information_param_item_id4   => l_rec.information_param_item_id4
            ,p_information_param_item_id5   => l_rec.information_param_item_id5
            ,p_insert_allowed               => l_rec.insert_allowed
            ,p_prompt_alignment_offset      => l_rec.prompt_alignment_offset
            ,p_prompt_display_style         => l_rec.prompt_display_style
            ,p_prompt_edge                  => l_rec.prompt_edge
            ,p_prompt_edge_alignment        => l_rec.prompt_edge_alignment
            ,p_prompt_edge_offset           => l_rec.prompt_edge_offset
            ,p_prompt_text_alignment        => l_rec.prompt_text_alignment
            ,p_query_allowed                => l_rec.query_allowed
            ,p_required                     => l_rec.required
            ,p_update_allowed               => l_rec.update_allowed
            ,p_validation_formula_id        => l_rec.validation_formula_id
            ,p_validation_param_item_id1    => l_rec.validation_param_item_id1
            ,p_validation_param_item_id2    => l_rec.validation_param_item_id2
            ,p_validation_param_item_id3    => l_rec.validation_param_item_id3
            ,p_validation_param_item_id4    => l_rec.validation_param_item_id4
            ,p_validation_param_item_id5    => l_rec.validation_param_item_id5
            ,p_visible                      => l_rec.visible
            ,p_width                        => l_rec.width
            ,p_x_position                   => l_rec.x_position
            ,p_y_position                   => l_rec.y_position
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
            ,p_next_navigation_item_id      => l_rec.next_navigation_item_id
            ,p_previous_navigation_item_id  => l_rec.previous_navigation_item_id
            ,p_item_property_id             => l_item_property_id
            ,p_object_version_number        => l_object_version_number);
            --,p_override_value_warning       => l_override_value_warning);

  hr_utility.set_location('At:'|| l_proc, 30);

  IF  ( p_default_value <> hr_api.g_varchar2)
  AND ( p_information_prompt <> hr_api.g_varchar2)
  AND ( p_label <> hr_api.g_varchar2 )
  AND ( p_prompt_text <> hr_api.g_varchar2 )
  AND ( p_tooltip_text <> hr_api.g_varchar2 ) THEN

    hr_utility.set_location('At:'|| l_proc, 35);

    hr_ipt_ins.ins_tl(p_language_code                => l_language_code
               ,p_item_property_id             => l_item_property_id
               ,p_default_value                => p_default_value
               ,p_information_prompt           => p_information_prompt
               ,p_label                        => p_label
               ,p_prompt_text                  => p_prompt_text
               ,p_tooltip_text                 => p_tooltip_text);

  ELSE
    hr_utility.set_location('At:'|| l_proc, 40);

    FOR cur_rec in cur_item_tl LOOP
       IF cur_item_tl%ROWCOUNT = 1 THEN
         hr_utility.set_location('At:'|| l_proc, 45);

         hr_ipt_ins.ins_tl(p_language_code                => cur_rec.source_lang
                  ,p_item_property_id             => l_item_property_id
                  ,p_default_value                => cur_rec.default_value
                  ,p_information_prompt           => cur_rec.information_prompt
                  ,p_label                        => cur_rec.label
                  ,p_prompt_text                  => cur_rec.prompt_text
                  ,p_tooltip_text                 => cur_rec.tooltip_text);
      ELSE
         hr_utility.set_location('At:'|| l_proc, 50);

        hr_ipt_upd.upd_tl(p_language_code                => cur_rec.source_lang
                  ,p_item_property_id             => l_item_property_id
                  ,p_default_value                => cur_rec.default_value
                  ,p_information_prompt           => cur_rec.information_prompt
                  ,p_label                        => cur_rec.label
                  ,p_prompt_text                  => cur_rec.prompt_text
                  ,p_tooltip_text                 => cur_rec.tooltip_text);
      END IF;
    END LOOP;
  END IF;
  --
  -- Update properties common across all buttons of a radio group
  --
  update_radio_button_property
    (p_effective_date                  => TRUNC(p_effective_date)
    ,p_language_code                   => l_language_code
    ,p_form_item_id                    => NULL
    ,p_template_item_id                => p_template_item_id
    ,p_template_item_context_id        => NULL
    ,p_default_value                   => p_default_value
    ,p_information_formula_id          => l_rec.information_formula_id
    ,p_information_param_item_id1      => l_rec.information_param_item_id1
    ,p_information_param_item_id2      => l_rec.information_param_item_id2
    ,p_information_param_item_id3      => l_rec.information_param_item_id3
    ,p_information_param_item_id4      => l_rec.information_param_item_id4
    ,p_information_param_item_id5      => l_rec.information_param_item_id5
    ,p_information_prompt              => p_information_prompt
    ,p_insert_allowed                  => l_rec.insert_allowed
    ,p_next_navigation_item_id         => l_rec.next_navigation_item_id
    ,p_previous_navigation_item_id     => l_rec.previous_navigation_item_id
    ,p_query_allowed                   => l_rec.query_allowed
    ,p_tooltip_text                    => p_tooltip_text
    ,p_update_allowed                  => l_rec.update_allowed
    ,p_validation_formula_id           => l_rec.validation_formula_id
    ,p_validation_param_item_id1       => l_rec.validation_param_item_id1
    ,p_validation_param_item_id2       => l_rec.validation_param_item_id2
    ,p_validation_param_item_id3       => l_rec.validation_param_item_id3
    ,p_validation_param_item_id4       => l_rec.validation_param_item_id4
    ,p_validation_param_item_id5       => l_rec.validation_param_item_id5
    ,p_object_version_number           => l_object_version_number
    );
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  hr_utility.set_location('At:'|| l_proc, 60);

  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_item_property_id             := l_item_property_id;
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
    rollback to copy_item_property;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_item_property_id             := null;
    --p_override_value_warning       := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to copy_item_property;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end copy_item_property;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------< copy_item_property - overload 1>--------------------|
-- ----------------------------------------------------------------------------
--
procedure copy_item_property
  (p_validate                        in     boolean  default false
  ,p_effective_date                  in     date
  ,p_language_code                   in varchar2 default hr_api.userenv_lang
  ,p_template_item_id                in number
  ,p_template_item_context_id        in number
  ,p_alignment                       in number default hr_api.g_number
  ,p_bevel                           in number default hr_api.g_number
  ,p_case_restriction                in number default hr_api.g_number
  ,p_default_value                   in varchar2 default hr_api.g_varchar2
  ,p_enabled                         in number default hr_api.g_number
  ,p_format_mask                     in varchar2 default hr_api.g_varchar2
  ,p_height                          in number default hr_api.g_number
  ,p_information_formula_id          in number default hr_api.g_number
  ,p_information_param_item_id1      in number default hr_api.g_number
  ,p_information_param_item_id2      in number default hr_api.g_number
  ,p_information_param_item_id3      in number default hr_api.g_number
  ,p_information_param_item_id4      in number default hr_api.g_number
  ,p_information_param_item_id5      in number default hr_api.g_number
  ,p_information_prompt              in varchar2 default hr_api.g_varchar2
  ,p_insert_allowed                  in number default hr_api.g_number
  ,p_label                           in varchar2 default hr_api.g_varchar2
  ,p_prompt_text                     in varchar2 default hr_api.g_varchar2
  ,p_prompt_alignment_offset         in number default hr_api.g_number
  ,p_prompt_display_style            in number default hr_api.g_number
  ,p_prompt_edge                     in number default hr_api.g_number
  ,p_prompt_edge_alignment           in number default hr_api.g_number
  ,p_prompt_edge_offset              in number default hr_api.g_number
  ,p_prompt_text_alignment           in number default hr_api.g_number
  ,p_query_allowed                   in number default hr_api.g_number
  ,p_required                        in number default hr_api.g_number
  ,p_tooltip_text                    in varchar2 default hr_api.g_varchar2
  ,p_update_allowed                  in number default hr_api.g_number
  ,p_validation_formula_id           in number default hr_api.g_number
  ,p_validation_param_item_id1       in number default hr_api.g_number
  ,p_validation_param_item_id2       in number default hr_api.g_number
  ,p_validation_param_item_id3       in number default hr_api.g_number
  ,p_validation_param_item_id4       in number default hr_api.g_number
  ,p_validation_param_item_id5       in number default hr_api.g_number
  ,p_visible                         in number default hr_api.g_number
  ,p_width                           in number default hr_api.g_number
  ,p_x_position                      in number default hr_api.g_number
  ,p_y_position                      in number default hr_api.g_number
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
  ,p_next_navigation_item_id         in number default hr_api.g_number
  ,p_previous_navigation_item_id     in number default hr_api.g_number
  ,p_item_property_id                  out nocopy number
  ,p_object_version_number             out nocopy number
  --,p_override_value_warning            out boolean
  ) is
  --
  -- Declare cursors and local variables
  --

  Type l_rec_type Is Record
  (alignment hr_item_properties_b.alignment%TYPE
  ,bevel hr_item_properties_b.bevel%TYPE
  ,case_restriction hr_item_properties_b.case_restriction%TYPE
  ,enabled hr_item_properties_b.enabled%TYPE
  ,format_mask hr_item_properties_b.format_mask%TYPE
  ,height hr_item_properties_b.height%TYPE
  ,information_formula_id hr_item_properties_b.information_formula_id%TYPE
  ,information_param_item_id1 hr_item_properties_b.information_parameter_item_id1%TYPE
  ,information_param_item_id2 hr_item_properties_b.information_parameter_item_id2%TYPE
  ,information_param_item_id3 hr_item_properties_b.information_parameter_item_id3%TYPE
  ,information_param_item_id4 hr_item_properties_b.information_parameter_item_id4%TYPE
  ,information_param_item_id5 hr_item_properties_b.information_parameter_item_id5%TYPE
  ,insert_allowed hr_item_properties_b.insert_allowed%TYPE
  ,prompt_alignment_offset hr_item_properties_b.prompt_alignment_offset%TYPE
  ,prompt_display_style hr_item_properties_b.prompt_display_style%TYPE
  ,prompt_edge hr_item_properties_b.prompt_edge%TYPE
  ,prompt_edge_alignment hr_item_properties_b.prompt_edge_alignment%TYPE
  ,prompt_edge_offset hr_item_properties_b.prompt_edge_offset%TYPE
  ,prompt_text_alignment hr_item_properties_b.prompt_text_alignment%TYPE
  ,query_allowed hr_item_properties_b.query_allowed%TYPE
  ,required hr_item_properties_b.required%TYPE
  ,update_allowed hr_item_properties_b.update_allowed%TYPE
  ,validation_formula_id hr_item_properties_b.validation_formula_id%TYPE
  ,validation_param_item_id1 hr_item_properties_b.validation_parameter_item_id1%TYPE
  ,validation_param_item_id2 hr_item_properties_b.validation_parameter_item_id2%TYPE
  ,validation_param_item_id3 hr_item_properties_b.validation_parameter_item_id3%TYPE
  ,validation_param_item_id4 hr_item_properties_b.validation_parameter_item_id4%TYPE
  ,validation_param_item_id5 hr_item_properties_b.validation_parameter_item_id5%TYPE
  ,visible hr_item_properties_b.visible%TYPE
  ,width hr_item_properties_b.width%TYPE
  ,x_position hr_item_properties_b.x_position%TYPE
  ,y_position hr_item_properties_b.y_position%TYPE
  ,information_category hr_item_properties_b.information_category%TYPE
  ,information1 hr_item_properties_b.information1%TYPE
  ,information2 hr_item_properties_b.information2%TYPE
  ,information3 hr_item_properties_b.information3%TYPE
  ,information4 hr_item_properties_b.information4%TYPE
  ,information5 hr_item_properties_b.information5%TYPE
  ,information6 hr_item_properties_b.information6%TYPE
  ,information7 hr_item_properties_b.information7%TYPE
  ,information8 hr_item_properties_b.information8%TYPE
  ,information9 hr_item_properties_b.information9%TYPE
  ,information10 hr_item_properties_b.information10%TYPE
  ,information11 hr_item_properties_b.information11%TYPE
  ,information12 hr_item_properties_b.information12%TYPE
  ,information13 hr_item_properties_b.information13%TYPE
  ,information14 hr_item_properties_b.information14%TYPE
  ,information15 hr_item_properties_b.information15%TYPE
  ,information16 hr_item_properties_b.information16%TYPE
  ,information17 hr_item_properties_b.information17%TYPE
  ,information18 hr_item_properties_b.information18%TYPE
  ,information19 hr_item_properties_b.information19%TYPE
  ,information20 hr_item_properties_b.information20%TYPE
  ,information21 hr_item_properties_b.information21%TYPE
  ,information22 hr_item_properties_b.information22%TYPE
  ,information23 hr_item_properties_b.information23%TYPE
  ,information24 hr_item_properties_b.information24%TYPE
  ,information25 hr_item_properties_b.information25%TYPE
  ,information26 hr_item_properties_b.information26%TYPE
  ,information27 hr_item_properties_b.information27%TYPE
  ,information28 hr_item_properties_b.information28%TYPE
  ,information29 hr_item_properties_b.information29%TYPE
  ,information30 hr_item_properties_b.information30%TYPE
  ,next_navigation_item_id hr_item_properties_b.next_navigation_item_id%TYPE
  ,previous_navigation_item_id hr_item_properties_b.previous_navigation_item_id%TYPE
  );

  l_rec l_rec_type;

  CURSOR cur_check
  IS
  SELECT 1
  FROM hr_template_item_contexts tic
  WHERE tic.template_item_context_id = p_template_item_context_id
  AND tic.template_item_id  = p_template_item_id;

-- added a outer join so that the correct values are returned
-- if there are no entries in the properties table
  CURSOR cur_item_prop
  IS
  SELECT DECODE(p_alignment,hr_api.g_number,itp.alignment,p_alignment)
  ,DECODE(p_bevel,hr_api.g_number,itp.bevel,p_bevel)
  ,DECODE(p_case_restriction,hr_api.g_number,itp.case_restriction,p_case_restriction)
  ,DECODE(p_enabled,hr_api.g_number,itp.enabled,p_enabled)
  ,DECODE(p_format_mask,hr_api.g_varchar2,itp.format_mask,p_format_mask)
  ,DECODE(p_height,hr_api.g_number,itp.height,p_height)
  ,DECODE(p_information_formula_id,hr_api.g_number,itp.information_formula_id,p_information_formula_id)
  ,DECODE(p_information_param_item_id1,hr_api.g_number,itp.information_parameter_item_id1,p_information_param_item_id1)
  ,DECODE(p_information_param_item_id2,hr_api.g_number,itp.information_parameter_item_id2,p_information_param_item_id2)
  ,DECODE(p_information_param_item_id3,hr_api.g_number,itp.information_parameter_item_id3,p_information_param_item_id3)
  ,DECODE(p_information_param_item_id4,hr_api.g_number,itp.information_parameter_item_id4,p_information_param_item_id4)
  ,DECODE(p_information_param_item_id5,hr_api.g_number,itp.information_parameter_item_id5,p_information_param_item_id5)
  ,DECODE(p_insert_allowed,hr_api.g_number,itp.insert_allowed,p_insert_allowed)
  ,DECODE(p_prompt_alignment_offset,hr_api.g_number,itp.prompt_alignment_offset,p_prompt_alignment_offset)
  ,DECODE(p_prompt_display_style,hr_api.g_number,itp.prompt_display_style,p_prompt_display_style)
  ,DECODE(p_prompt_edge,hr_api.g_number,itp.prompt_edge,p_prompt_edge)
  ,DECODE(p_prompt_edge_alignment,hr_api.g_number,itp.prompt_edge_alignment,p_prompt_edge_alignment)
  ,DECODE(p_prompt_edge_offset,hr_api.g_number,itp.prompt_edge_offset,p_prompt_edge_offset)
  ,DECODE(p_prompt_text_alignment,hr_api.g_number,itp.prompt_text_alignment,p_prompt_text_alignment)
  ,DECODE(p_query_allowed,hr_api.g_number,itp.query_allowed,p_query_allowed)
  ,DECODE(p_required,hr_api.g_number,itp.required,p_required)
  ,DECODE(p_update_allowed,hr_api.g_number,itp.update_allowed,p_update_allowed)
  ,DECODE(p_validation_formula_id,hr_api.g_number,itp.validation_formula_id,p_validation_formula_id)
  ,DECODE(p_validation_param_item_id1,hr_api.g_number,itp.validation_parameter_item_id1,p_validation_param_item_id1)
  ,DECODE(p_validation_param_item_id2,hr_api.g_number,itp.validation_parameter_item_id2,p_validation_param_item_id2)
  ,DECODE(p_validation_param_item_id3,hr_api.g_number,itp.validation_parameter_item_id3,p_validation_param_item_id3)
  ,DECODE(p_validation_param_item_id4,hr_api.g_number,itp.validation_parameter_item_id4,p_validation_param_item_id4)
  ,DECODE(p_validation_param_item_id5,hr_api.g_number,itp.validation_parameter_item_id5,p_validation_param_item_id5)
  ,DECODE(p_visible,hr_api.g_number,itp.visible,p_visible)
  ,DECODE(p_width,hr_api.g_number,itp.width,p_width)
  ,DECODE(p_x_position,hr_api.g_number,itp.x_position,p_x_position)
  ,DECODE(p_y_position,hr_api.g_number,itp.y_position,p_y_position)
  ,DECODE(p_information_category,hr_api.g_varchar2,itp.information_category,p_information_category)
  ,DECODE(p_information1,hr_api.g_varchar2,itp.information1,p_information1)
  ,DECODE(p_information2,hr_api.g_varchar2,itp.information2,p_information2)
  ,DECODE(p_information3,hr_api.g_varchar2,itp.information3,p_information3)
  ,DECODE(p_information4,hr_api.g_varchar2,itp.information4,p_information4)
  ,DECODE(p_information5,hr_api.g_varchar2,itp.information5,p_information5)
  ,DECODE(p_information6,hr_api.g_varchar2,itp.information6,p_information6)
  ,DECODE(p_information7,hr_api.g_varchar2,itp.information7,p_information7)
  ,DECODE(p_information8,hr_api.g_varchar2,itp.information8,p_information8)
  ,DECODE(p_information9,hr_api.g_varchar2,itp.information9,p_information9)
  ,DECODE(p_information10,hr_api.g_varchar2,itp.information10,p_information10)
  ,DECODE(p_information11,hr_api.g_varchar2,itp.information11,p_information11)
  ,DECODE(p_information12,hr_api.g_varchar2,itp.information12,p_information12)
  ,DECODE(p_information13,hr_api.g_varchar2,itp.information13,p_information13)
  ,DECODE(p_information14,hr_api.g_varchar2,itp.information14,p_information14)
  ,DECODE(p_information15,hr_api.g_varchar2,itp.information15,p_information15)
  ,DECODE(p_information16,hr_api.g_varchar2,itp.information16,p_information16)
  ,DECODE(p_information17,hr_api.g_varchar2,itp.information17,p_information17)
  ,DECODE(p_information18,hr_api.g_varchar2,itp.information18,p_information18)
  ,DECODE(p_information19,hr_api.g_varchar2,itp.information19,p_information19)
  ,DECODE(p_information20,hr_api.g_varchar2,itp.information20,p_information20)
  ,DECODE(p_information21,hr_api.g_varchar2,itp.information21,p_information21)
  ,DECODE(p_information22,hr_api.g_varchar2,itp.information22,p_information22)
  ,DECODE(p_information23,hr_api.g_varchar2,itp.information23,p_information23)
  ,DECODE(p_information24,hr_api.g_varchar2,itp.information24,p_information24)
  ,DECODE(p_information25,hr_api.g_varchar2,itp.information25,p_information25)
  ,DECODE(p_information26,hr_api.g_varchar2,itp.information26,p_information26)
  ,DECODE(p_information27,hr_api.g_varchar2,itp.information27,p_information27)
  ,DECODE(p_information28,hr_api.g_varchar2,itp.information28,p_information28)
  ,DECODE(p_information29,hr_api.g_varchar2,itp.information29,p_information29)
  ,DECODE(p_information30,hr_api.g_varchar2,itp.information30,p_information30)
  ,DECODE(p_next_navigation_item_id,hr_api.g_number,itp.next_navigation_item_id,p_next_navigation_item_id)
  ,DECODE(p_previous_navigation_item_id,hr_api.g_number,itp.previous_navigation_item_id,p_previous_navigation_item_id)
  FROM hr_item_properties_b itp
      , hr_template_items_b hti
  WHERE itp.template_item_id (+) = hti.template_item_id
  AND hti.template_item_id = p_template_item_id;

  CURSOR cur_item_tl
  IS
  SELECT COUNT(0) t_count
  ,itptl.source_lang
  ,DECODE(p_default_value,hr_api.g_varchar2,itptl.default_value,p_default_value) default_value
  ,DECODE(p_information_prompt,hr_api.g_varchar2,itptl.information_prompt,p_information_prompt) information_prompt
  ,DECODE(p_label,hr_api.g_varchar2,itptl.label,p_label) label
  ,DECODE(p_prompt_text,hr_api.g_varchar2,itptl.prompt_text,p_prompt_text) prompt_text
  ,DECODE(p_tooltip_text,hr_api.g_varchar2,itptl.tooltip_text,p_tooltip_text) tooltip_text
  FROM hr_item_properties_tl itptl
  ,hr_item_properties_b itp
  WHERE itptl.item_property_id = itp.item_property_id
  AND itp.template_item_id = p_template_item_id
  GROUP BY itptl.source_lang
  ,DECODE(p_default_value,hr_api.g_varchar2,itptl.default_value,p_default_value)
  ,DECODE(p_information_prompt,hr_api.g_varchar2,itptl.information_prompt,p_information_prompt)
  ,DECODE(p_label,hr_api.g_varchar2,itptl.label,p_label)
  ,DECODE(p_prompt_text,hr_api.g_varchar2,itptl.prompt_text,p_prompt_text)
  ,DECODE(p_tooltip_text,hr_api.g_varchar2,itptl.tooltip_text,p_tooltip_text)
  ORDER BY 1;

  l_language_code fnd_languages.language_code%TYPE;

  l_check number;
  l_item_property_id                  number ;
  l_object_version_number             number;
  l_override_value_warning            boolean;
  l_proc                varchar2(72) := g_package||'copy_item_property';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint copy_item_property;
  --
  -- Truncate the time portion from all IN date parameters
  --

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
  hr_utility.set_location('At:'|| l_proc, 15);

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
  hr_utility.set_location('At:'|| l_proc, 20);

  OPEN cur_item_prop;
  FETCH cur_item_prop INTO l_rec;
  CLOSE cur_item_prop;

  hr_utility.set_location('At:'|| l_proc, 25);

  hr_itp_ins.ins(p_effective_date           => TRUNC(p_effective_date)
            ,p_template_item_context_id     => p_template_item_context_id
            ,p_alignment                    => l_rec.alignment
            ,p_bevel                        => l_rec.bevel
            ,p_case_restriction             => l_rec.case_restriction
            ,p_enabled                      => l_rec.enabled
            ,p_format_mask                  => l_rec.format_mask
            ,p_height                       => l_rec.height
            ,p_information_formula_id       => l_rec.information_formula_id
            ,p_information_param_item_id1   => l_rec.information_param_item_id1
            ,p_information_param_item_id2   => l_rec.information_param_item_id2
            ,p_information_param_item_id3   => l_rec.information_param_item_id3
            ,p_information_param_item_id4   => l_rec.information_param_item_id4
            ,p_information_param_item_id5   => l_rec.information_param_item_id5
            ,p_insert_allowed               => l_rec.insert_allowed
            ,p_prompt_alignment_offset      => l_rec.prompt_alignment_offset
            ,p_prompt_display_style         => l_rec.prompt_display_style
            ,p_prompt_edge                  => l_rec.prompt_edge
            ,p_prompt_edge_alignment        => l_rec.prompt_edge_alignment
            ,p_prompt_edge_offset           => l_rec.prompt_edge_offset
            ,p_prompt_text_alignment        => l_rec.prompt_text_alignment
            ,p_query_allowed                => l_rec.query_allowed
            ,p_required                     => l_rec.required
            ,p_update_allowed               => l_rec.update_allowed
            ,p_validation_formula_id        => l_rec.validation_formula_id
            ,p_validation_param_item_id1    => l_rec.validation_param_item_id1
            ,p_validation_param_item_id2    => l_rec.validation_param_item_id2
            ,p_validation_param_item_id3    => l_rec.validation_param_item_id3
            ,p_validation_param_item_id4    => l_rec.validation_param_item_id4
            ,p_validation_param_item_id5    => l_rec.validation_param_item_id5
            ,p_visible                      => l_rec.visible
            ,p_width                        => l_rec.width
            ,p_x_position                   => l_rec.x_position
            ,p_y_position                   => l_rec.y_position
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
            ,p_next_navigation_item_id      => l_rec.next_navigation_item_id
            ,p_previous_navigation_item_id  => l_rec.previous_navigation_item_id
            ,p_item_property_id             => l_item_property_id
            ,p_object_version_number        => l_object_version_number);
            --,p_override_value_warning       => l_override_value_warning);

  hr_utility.set_location('At:'|| l_proc, 30);

  IF  (p_default_value <> hr_api.g_varchar2)
  AND ( p_information_prompt <> hr_api.g_varchar2)
  AND ( p_label <> hr_api.g_varchar2 )
  AND ( p_prompt_text <> hr_api.g_varchar2 )
  AND ( p_tooltip_text <> hr_api.g_varchar2 ) THEN

    hr_utility.set_location('At:'|| l_proc, 35);

    hr_ipt_ins.ins_tl(p_language_code                => l_language_code
               ,p_item_property_id             => l_item_property_id
               ,p_default_value                => p_default_value
               ,p_information_prompt           => p_information_prompt
               ,p_label                        => p_label
               ,p_prompt_text                  => p_prompt_text
               ,p_tooltip_text                 => p_tooltip_text);

  ELSE
    hr_utility.set_location('At:'|| l_proc, 40);

    FOR cur_rec in cur_item_tl LOOP
       IF cur_item_tl%ROWCOUNT = 1 THEN
         hr_utility.set_location('At:'|| l_proc, 45);

         hr_ipt_ins.ins_tl(p_language_code                => cur_rec.source_lang
                  ,p_item_property_id             => l_item_property_id
                  ,p_default_value                => cur_rec.default_value
                  ,p_information_prompt           => cur_rec.information_prompt
                  ,p_label                        => cur_rec.label
                  ,p_prompt_text                  => cur_rec.prompt_text
                  ,p_tooltip_text                 => cur_rec.tooltip_text);
      ELSE
         hr_utility.set_location('At:'|| l_proc, 50);

        hr_ipt_upd.upd_tl(p_language_code                => cur_rec.source_lang
                  ,p_item_property_id             => l_item_property_id
                  ,p_default_value                => cur_rec.default_value
                  ,p_information_prompt           => cur_rec.information_prompt
                  ,p_label                        => cur_rec.label
                  ,p_prompt_text                  => cur_rec.prompt_text
                  ,p_tooltip_text                 => cur_rec.tooltip_text);
      END IF;
    END LOOP;
  END IF;
  --
  -- Update properties common across all buttons of a radio group
  --
  update_radio_button_property
    (p_effective_date                  => TRUNC(p_effective_date)
    ,p_language_code                   => l_language_code
    ,p_form_item_id                    => NULL
    ,p_template_item_id                => NULL
    ,p_template_item_context_id        => p_template_item_context_id
    ,p_default_value                   => p_default_value
    ,p_information_formula_id          => l_rec.information_formula_id
    ,p_information_param_item_id1      => l_rec.information_param_item_id1
    ,p_information_param_item_id2      => l_rec.information_param_item_id2
    ,p_information_param_item_id3      => l_rec.information_param_item_id3
    ,p_information_param_item_id4      => l_rec.information_param_item_id4
    ,p_information_param_item_id5      => l_rec.information_param_item_id5
    ,p_information_prompt              => p_information_prompt
    ,p_insert_allowed                  => l_rec.insert_allowed
    ,p_next_navigation_item_id         => l_rec.next_navigation_item_id
    ,p_previous_navigation_item_id     => l_rec.previous_navigation_item_id
    ,p_query_allowed                   => l_rec.query_allowed
    ,p_tooltip_text                    => p_tooltip_text
    ,p_update_allowed                  => l_rec.update_allowed
    ,p_validation_formula_id           => l_rec.validation_formula_id
    ,p_validation_param_item_id1       => l_rec.validation_param_item_id1
    ,p_validation_param_item_id2       => l_rec.validation_param_item_id2
    ,p_validation_param_item_id3       => l_rec.validation_param_item_id3
    ,p_validation_param_item_id4       => l_rec.validation_param_item_id4
    ,p_validation_param_item_id5       => l_rec.validation_param_item_id5
    ,p_object_version_number           => l_object_version_number
    );
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  hr_utility.set_location('At:'|| l_proc, 55);

  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_item_property_id             := l_item_property_id;
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
    rollback to copy_item_property;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_item_property_id             := null;
    --p_override_value_warning       := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to copy_item_property;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end copy_item_property;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------< copy_item_property - overload 2>--------------------|
-- ----------------------------------------------------------------------------
--
procedure copy_item_property
  (p_validate                        in     boolean  default false
  ,p_effective_date                  in     date
  ,p_language_code                   in varchar2 default hr_api.userenv_lang
  ,p_template_item_id_from           in number
  ,p_template_item_id_to             in number
  ,p_alignment                       in number default hr_api.g_number
  ,p_bevel                           in number default hr_api.g_number
  ,p_case_restriction                in number default hr_api.g_number
  ,p_default_value                   in varchar2 default hr_api.g_varchar2
  ,p_enabled                         in number default hr_api.g_number
  ,p_format_mask                     in varchar2 default hr_api.g_varchar2
  ,p_height                          in number default hr_api.g_number
  ,p_information_formula_id          in number default hr_api.g_number
  ,p_information_param_item_id1      in number default hr_api.g_number
  ,p_information_param_item_id2      in number default hr_api.g_number
  ,p_information_param_item_id3      in number default hr_api.g_number
  ,p_information_param_item_id4      in number default hr_api.g_number
  ,p_information_param_item_id5      in number default hr_api.g_number
  ,p_information_prompt              in varchar2 default hr_api.g_varchar2
  ,p_insert_allowed                  in number default hr_api.g_number
  ,p_label                           in varchar2 default hr_api.g_varchar2
  ,p_prompt_text                     in varchar2 default hr_api.g_varchar2
  ,p_prompt_alignment_offset         in number default hr_api.g_number
  ,p_prompt_display_style            in number default hr_api.g_number
  ,p_prompt_edge                     in number default hr_api.g_number
  ,p_prompt_edge_alignment           in number default hr_api.g_number
  ,p_prompt_edge_offset              in number default hr_api.g_number
  ,p_prompt_text_alignment           in number default hr_api.g_number
  ,p_query_allowed                   in number default hr_api.g_number
  ,p_required                        in number default hr_api.g_number
  ,p_tooltip_text                    in varchar2 default hr_api.g_varchar2
  ,p_update_allowed                  in number default hr_api.g_number
  ,p_validation_formula_id           in number default hr_api.g_number
  ,p_validation_param_item_id1       in number default hr_api.g_number
  ,p_validation_param_item_id2       in number default hr_api.g_number
  ,p_validation_param_item_id3       in number default hr_api.g_number
  ,p_validation_param_item_id4       in number default hr_api.g_number
  ,p_validation_param_item_id5       in number default hr_api.g_number
  ,p_visible                         in number default hr_api.g_number
  ,p_width                           in number default hr_api.g_number
  ,p_x_position                      in number default hr_api.g_number
  ,p_y_position                      in number default hr_api.g_number
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
  ,p_next_navigation_item_id         in number default hr_api.g_number
  ,p_previous_navigation_item_id     in number default hr_api.g_number
  ,p_item_property_id                  out nocopy number
  ,p_object_version_number             out nocopy number
  --,p_override_value_warning            out boolean
  ) is
  --
  -- Declare cursors and local variables
  --

  Type l_rec_type Is Record
  (alignment hr_item_properties_b.alignment%TYPE
  ,bevel hr_item_properties_b.bevel%TYPE
  ,case_restriction hr_item_properties_b.case_restriction%TYPE
  ,enabled hr_item_properties_b.enabled%TYPE
  ,format_mask hr_item_properties_b.format_mask%TYPE
  ,height hr_item_properties_b.height%TYPE
  ,information_formula_id hr_item_properties_b.information_formula_id%TYPE
  ,information_param_item_id1 hr_item_properties_b.information_parameter_item_id1%TYPE
  ,information_param_item_id2 hr_item_properties_b.information_parameter_item_id2%TYPE
  ,information_param_item_id3 hr_item_properties_b.information_parameter_item_id3%TYPE
  ,information_param_item_id4 hr_item_properties_b.information_parameter_item_id4%TYPE
  ,information_param_item_id5 hr_item_properties_b.information_parameter_item_id5%TYPE
  ,insert_allowed hr_item_properties_b.insert_allowed%TYPE
  ,prompt_alignment_offset hr_item_properties_b.prompt_alignment_offset%TYPE
  ,prompt_display_style hr_item_properties_b.prompt_display_style%TYPE
  ,prompt_edge hr_item_properties_b.prompt_edge%TYPE
  ,prompt_edge_alignment hr_item_properties_b.prompt_edge_alignment%TYPE
  ,prompt_edge_offset hr_item_properties_b.prompt_edge_offset%TYPE
  ,prompt_text_alignment hr_item_properties_b.prompt_text_alignment%TYPE
  ,query_allowed hr_item_properties_b.query_allowed%TYPE
  ,required hr_item_properties_b.required%TYPE
  ,update_allowed hr_item_properties_b.update_allowed%TYPE
  ,validation_formula_id hr_item_properties_b.validation_formula_id%TYPE
  ,validation_param_item_id1 hr_item_properties_b.validation_parameter_item_id1%TYPE
  ,validation_param_item_id2 hr_item_properties_b.validation_parameter_item_id2%TYPE
  ,validation_param_item_id3 hr_item_properties_b.validation_parameter_item_id3%TYPE
  ,validation_param_item_id4 hr_item_properties_b.validation_parameter_item_id4%TYPE
  ,validation_param_item_id5 hr_item_properties_b.validation_parameter_item_id5%TYPE
  ,visible hr_item_properties_b.visible%TYPE
  ,width hr_item_properties_b.width%TYPE
  ,x_position hr_item_properties_b.x_position%TYPE
  ,y_position hr_item_properties_b.y_position%TYPE
  ,information_category hr_item_properties_b.information_category%TYPE
  ,information1 hr_item_properties_b.information1%TYPE
  ,information2 hr_item_properties_b.information2%TYPE
  ,information3 hr_item_properties_b.information3%TYPE
  ,information4 hr_item_properties_b.information4%TYPE
  ,information5 hr_item_properties_b.information5%TYPE
  ,information6 hr_item_properties_b.information6%TYPE
  ,information7 hr_item_properties_b.information7%TYPE
  ,information8 hr_item_properties_b.information8%TYPE
  ,information9 hr_item_properties_b.information9%TYPE
  ,information10 hr_item_properties_b.information10%TYPE
  ,information11 hr_item_properties_b.information11%TYPE
  ,information12 hr_item_properties_b.information12%TYPE
  ,information13 hr_item_properties_b.information13%TYPE
  ,information14 hr_item_properties_b.information14%TYPE
  ,information15 hr_item_properties_b.information15%TYPE
  ,information16 hr_item_properties_b.information16%TYPE
  ,information17 hr_item_properties_b.information17%TYPE
  ,information18 hr_item_properties_b.information18%TYPE
  ,information19 hr_item_properties_b.information19%TYPE
  ,information20 hr_item_properties_b.information20%TYPE
  ,information21 hr_item_properties_b.information21%TYPE
  ,information22 hr_item_properties_b.information22%TYPE
  ,information23 hr_item_properties_b.information23%TYPE
  ,information24 hr_item_properties_b.information24%TYPE
  ,information25 hr_item_properties_b.information25%TYPE
  ,information26 hr_item_properties_b.information26%TYPE
  ,information27 hr_item_properties_b.information27%TYPE
  ,information28 hr_item_properties_b.information28%TYPE
  ,information29 hr_item_properties_b.information29%TYPE
  ,information30 hr_item_properties_b.information30%TYPE
  ,next_navigation_item_id hr_item_properties_b.next_navigation_item_id%TYPE
  ,previous_navigation_item_id hr_item_properties_b.previous_navigation_item_id%TYPE
  );

  l_rec l_rec_type;

  CURSOR cur_check
  IS
  SELECT tit.form_item_id
  FROM hr_template_items tit
  WHERE tit.template_item_id  = p_template_item_id_from
  INTERSECT
  SELECT tit.form_item_id
  FROM hr_template_items tit
  WHERE tit.template_item_id  = p_template_item_id_to;

  CURSOR cur_item_prop
  IS
  SELECT DECODE(p_alignment,hr_api.g_number,itp.alignment,p_alignment)
  ,DECODE(p_bevel,hr_api.g_number,itp.bevel,p_bevel)
  ,DECODE(p_case_restriction,hr_api.g_number,itp.case_restriction,p_case_restriction)
  ,DECODE(p_enabled,hr_api.g_number,itp.enabled,p_enabled)
  ,DECODE(p_format_mask,hr_api.g_varchar2,itp.format_mask,p_format_mask)
  ,DECODE(p_height,hr_api.g_number,itp.height,p_height)
  ,DECODE(p_information_formula_id,hr_api.g_number,itp.information_formula_id,p_information_formula_id)
  ,DECODE(p_information_param_item_id1,hr_api.g_number,itp.information_parameter_item_id1,p_information_param_item_id1)
  ,DECODE(p_information_param_item_id2,hr_api.g_number,itp.information_parameter_item_id2,p_information_param_item_id2)
  ,DECODE(p_information_param_item_id3,hr_api.g_number,itp.information_parameter_item_id3,p_information_param_item_id3)
  ,DECODE(p_information_param_item_id4,hr_api.g_number,itp.information_parameter_item_id4,p_information_param_item_id4)
  ,DECODE(p_information_param_item_id5,hr_api.g_number,itp.information_parameter_item_id5,p_information_param_item_id5)
  ,DECODE(p_insert_allowed,hr_api.g_number,itp.insert_allowed,p_insert_allowed)
  ,DECODE(p_prompt_alignment_offset,hr_api.g_number,itp.prompt_alignment_offset,p_prompt_alignment_offset)
  ,DECODE(p_prompt_display_style,hr_api.g_number,itp.prompt_display_style,p_prompt_display_style)
  ,DECODE(p_prompt_edge,hr_api.g_number,itp.prompt_edge,p_prompt_edge)
  ,DECODE(p_prompt_edge_alignment,hr_api.g_number,itp.prompt_edge_alignment,p_prompt_edge_alignment)
  ,DECODE(p_prompt_edge_offset,hr_api.g_number,itp.prompt_edge_offset,p_prompt_edge_offset)
  ,DECODE(p_prompt_text_alignment,hr_api.g_number,itp.prompt_text_alignment,p_prompt_text_alignment)
  ,DECODE(p_query_allowed,hr_api.g_number,itp.query_allowed,p_query_allowed)
  ,DECODE(p_required,hr_api.g_number,itp.required,p_required)
  ,DECODE(p_update_allowed,hr_api.g_number,itp.update_allowed,p_update_allowed)
  ,DECODE(p_validation_formula_id,hr_api.g_number,itp.validation_formula_id,p_validation_formula_id)
  ,DECODE(p_validation_param_item_id1,hr_api.g_number,itp.validation_parameter_item_id1,p_validation_param_item_id1)
  ,DECODE(p_validation_param_item_id2,hr_api.g_number,itp.validation_parameter_item_id2,p_validation_param_item_id2)
  ,DECODE(p_validation_param_item_id3,hr_api.g_number,itp.validation_parameter_item_id3,p_validation_param_item_id3)
  ,DECODE(p_validation_param_item_id4,hr_api.g_number,itp.validation_parameter_item_id4,p_validation_param_item_id4)
  ,DECODE(p_validation_param_item_id5,hr_api.g_number,itp.validation_parameter_item_id5,p_validation_param_item_id5)
  ,DECODE(p_visible,hr_api.g_number,itp.visible,p_visible)
  ,DECODE(p_width,hr_api.g_number,itp.width,p_width)
  ,DECODE(p_x_position,hr_api.g_number,itp.x_position,p_x_position)
  ,DECODE(p_y_position,hr_api.g_number,itp.y_position,p_y_position)
  ,DECODE(p_information_category,hr_api.g_varchar2,itp.information_category,p_information_category)
  ,DECODE(p_information1,hr_api.g_varchar2,itp.information1,p_information1)
  ,DECODE(p_information2,hr_api.g_varchar2,itp.information2,p_information2)
  ,DECODE(p_information3,hr_api.g_varchar2,itp.information3,p_information3)
  ,DECODE(p_information4,hr_api.g_varchar2,itp.information4,p_information4)
  ,DECODE(p_information5,hr_api.g_varchar2,itp.information5,p_information5)
  ,DECODE(p_information6,hr_api.g_varchar2,itp.information6,p_information6)
  ,DECODE(p_information7,hr_api.g_varchar2,itp.information7,p_information7)
  ,DECODE(p_information8,hr_api.g_varchar2,itp.information8,p_information8)
  ,DECODE(p_information9,hr_api.g_varchar2,itp.information9,p_information9)
  ,DECODE(p_information10,hr_api.g_varchar2,itp.information10,p_information10)
  ,DECODE(p_information11,hr_api.g_varchar2,itp.information11,p_information11)
  ,DECODE(p_information12,hr_api.g_varchar2,itp.information12,p_information12)
  ,DECODE(p_information13,hr_api.g_varchar2,itp.information13,p_information13)
  ,DECODE(p_information14,hr_api.g_varchar2,itp.information14,p_information14)
  ,DECODE(p_information15,hr_api.g_varchar2,itp.information15,p_information15)
  ,DECODE(p_information16,hr_api.g_varchar2,itp.information16,p_information16)
  ,DECODE(p_information17,hr_api.g_varchar2,itp.information17,p_information17)
  ,DECODE(p_information18,hr_api.g_varchar2,itp.information18,p_information18)
  ,DECODE(p_information19,hr_api.g_varchar2,itp.information19,p_information19)
  ,DECODE(p_information20,hr_api.g_varchar2,itp.information20,p_information20)
  ,DECODE(p_information21,hr_api.g_varchar2,itp.information21,p_information21)
  ,DECODE(p_information22,hr_api.g_varchar2,itp.information22,p_information22)
  ,DECODE(p_information23,hr_api.g_varchar2,itp.information23,p_information23)
  ,DECODE(p_information24,hr_api.g_varchar2,itp.information24,p_information24)
  ,DECODE(p_information25,hr_api.g_varchar2,itp.information25,p_information25)
  ,DECODE(p_information26,hr_api.g_varchar2,itp.information26,p_information26)
  ,DECODE(p_information27,hr_api.g_varchar2,itp.information27,p_information27)
  ,DECODE(p_information28,hr_api.g_varchar2,itp.information28,p_information28)
  ,DECODE(p_information29,hr_api.g_varchar2,itp.information29,p_information29)
  ,DECODE(p_information30,hr_api.g_varchar2,itp.information30,p_information30)
  ,DECODE(p_next_navigation_item_id,hr_api.g_number,itp.next_navigation_item_id,p_next_navigation_item_id)
  ,DECODE(p_previous_navigation_item_id,hr_api.g_number,itp.previous_navigation_item_id,p_previous_navigation_item_id)
  FROM hr_item_properties_b itp
       ,hr_template_items_b hti
  WHERE itp.template_item_id (+) = hti.template_item_id
  AND hti.template_item_id = p_template_item_id_from;

  CURSOR cur_item_tl
  IS
  SELECT COUNT(0) t_count
  ,itptl.source_lang
  ,DECODE(p_default_value,hr_api.g_varchar2,itptl.default_value,p_default_value) default_value
  ,DECODE(p_information_prompt,hr_api.g_varchar2,itptl.information_prompt,p_information_prompt) information_prompt
  ,DECODE(p_label,hr_api.g_varchar2,itptl.label,p_label) label
  ,DECODE(p_prompt_text,hr_api.g_varchar2,itptl.prompt_text,p_prompt_text) prompt_text
  ,DECODE(p_tooltip_text,hr_api.g_varchar2,itptl.tooltip_text,p_tooltip_text) tooltip_text
  FROM hr_item_properties_tl itptl
  ,hr_item_properties_b itp
  WHERE itptl.item_property_id = itp.item_property_id
  AND itp.template_item_id = p_template_item_id_from
  GROUP BY itptl.source_lang
  ,DECODE(p_default_value,hr_api.g_varchar2,itptl.default_value,p_default_value)
  ,DECODE(p_information_prompt,hr_api.g_varchar2,itptl.information_prompt,p_information_prompt)
  ,DECODE(p_label,hr_api.g_varchar2,itptl.label,p_label)
  ,DECODE(p_prompt_text,hr_api.g_varchar2,itptl.prompt_text,p_prompt_text)
  ,DECODE(p_tooltip_text,hr_api.g_varchar2,itptl.tooltip_text,p_tooltip_text)
  ORDER BY 1;

  l_check number;
  l_item_property_id                  number ;
  l_object_version_number             number;
  l_override_value_warning            boolean;
  l_proc                varchar2(72) := g_package||'copy_item_property';
  l_language_code fnd_languages.language_code%TYPE;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint copy_item_property;
  --
  -- Truncate the time portion from all IN date parameters
  --

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
  hr_utility.set_location('At:'|| l_proc, 15);

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
  hr_utility.set_location('At:'|| l_proc, 20);

  OPEN cur_item_prop;
  FETCH cur_item_prop INTO l_rec;
  CLOSE cur_item_prop;

  hr_utility.set_location('At:'|| l_proc, 25);

  hr_itp_ins.ins(p_effective_date           => TRUNC(p_effective_date)
            ,p_template_item_id             => p_template_item_id_to
            ,p_alignment                    => l_rec.alignment
            ,p_bevel                        => l_rec.bevel
            ,p_case_restriction             => l_rec.case_restriction
            ,p_enabled                      => l_rec.enabled
            ,p_format_mask                  => l_rec.format_mask
            ,p_height                       => l_rec.height
            ,p_information_formula_id       => l_rec.information_formula_id
            ,p_information_param_item_id1   => l_rec.information_param_item_id1
            ,p_information_param_item_id2   => l_rec.information_param_item_id2
            ,p_information_param_item_id3   => l_rec.information_param_item_id3
            ,p_information_param_item_id4   => l_rec.information_param_item_id4
            ,p_information_param_item_id5   => l_rec.information_param_item_id5
            ,p_insert_allowed               => l_rec.insert_allowed
            ,p_prompt_alignment_offset      => l_rec.prompt_alignment_offset
            ,p_prompt_display_style         => l_rec.prompt_display_style
            ,p_prompt_edge                  => l_rec.prompt_edge
            ,p_prompt_edge_alignment        => l_rec.prompt_edge_alignment
            ,p_prompt_edge_offset           => l_rec.prompt_edge_offset
            ,p_prompt_text_alignment        => l_rec.prompt_text_alignment
            ,p_query_allowed                => l_rec.query_allowed
            ,p_required                     => l_rec.required
            ,p_update_allowed               => l_rec.update_allowed
            ,p_validation_formula_id        => l_rec.validation_formula_id
            ,p_validation_param_item_id1    => l_rec.validation_param_item_id1
            ,p_validation_param_item_id2    => l_rec.validation_param_item_id2
            ,p_validation_param_item_id3    => l_rec.validation_param_item_id3
            ,p_validation_param_item_id4    => l_rec.validation_param_item_id4
            ,p_validation_param_item_id5    => l_rec.validation_param_item_id5
            ,p_visible                      => l_rec.visible
            ,p_width                        => l_rec.width
            ,p_x_position                   => l_rec.x_position
            ,p_y_position                   => l_rec.y_position
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
            ,p_next_navigation_item_id      => l_rec.next_navigation_item_id
            ,p_previous_navigation_item_id  => l_rec.previous_navigation_item_id
            ,p_item_property_id             => l_item_property_id
            ,p_object_version_number        => l_object_version_number);
            --,p_override_value_warning       => l_override_value_warning);

  hr_utility.set_location('At:'|| l_proc, 30);

  IF  ( p_default_value <> hr_api.g_varchar2)
  AND ( p_information_prompt <> hr_api.g_varchar2)
  AND ( p_label <> hr_api.g_varchar2 )
  AND ( p_prompt_text <> hr_api.g_varchar2 )
  AND ( p_tooltip_text <> hr_api.g_varchar2 ) THEN

    hr_utility.set_location('At:'|| l_proc, 35);

    hr_ipt_ins.ins_tl(p_language_code                => l_language_code
               ,p_item_property_id             => l_item_property_id
               ,p_default_value                => p_default_value
               ,p_information_prompt           => p_information_prompt
               ,p_label                        => p_label
               ,p_prompt_text                  => p_prompt_text
               ,p_tooltip_text                 => p_tooltip_text);

  ELSE
    hr_utility.set_location('At:'|| l_proc, 40);

    FOR cur_rec in cur_item_tl LOOP
       IF cur_item_tl%ROWCOUNT = 1 THEN
         hr_utility.set_location('At:'|| l_proc, 45);

         hr_ipt_ins.ins_tl(p_language_code                => cur_rec.source_lang
                  ,p_item_property_id             => l_item_property_id
                  ,p_default_value                => cur_rec.default_value
                  ,p_information_prompt           => cur_rec.information_prompt
                  ,p_label                        => cur_rec.label
                  ,p_prompt_text                  => cur_rec.prompt_text
                  ,p_tooltip_text                 => cur_rec.tooltip_text);
      ELSE
         hr_utility.set_location('At:'|| l_proc, 50);

        hr_ipt_upd.upd_tl(p_language_code                => cur_rec.source_lang
                  ,p_item_property_id             => l_item_property_id
                  ,p_default_value                => cur_rec.default_value
                  ,p_information_prompt           => cur_rec.information_prompt
                  ,p_label                        => cur_rec.label
                  ,p_prompt_text                  => cur_rec.prompt_text
                  ,p_tooltip_text                 => cur_rec.tooltip_text);
      END IF;
    END LOOP;
  END IF;
  --
  -- Update properties common across all buttons of a radio group
  --
  update_radio_button_property
    (p_effective_date                  => TRUNC(p_effective_date)
    ,p_language_code                   => l_language_code
    ,p_form_item_id                    => NULL
    ,p_template_item_id                => p_template_item_id_to
    ,p_template_item_context_id        => NULL
    ,p_default_value                   => p_default_value
    ,p_information_formula_id          => l_rec.information_formula_id
    ,p_information_param_item_id1      => l_rec.information_param_item_id1
    ,p_information_param_item_id2      => l_rec.information_param_item_id2
    ,p_information_param_item_id3      => l_rec.information_param_item_id3
    ,p_information_param_item_id4      => l_rec.information_param_item_id4
    ,p_information_param_item_id5      => l_rec.information_param_item_id5
    ,p_information_prompt              => p_information_prompt
    ,p_insert_allowed                  => l_rec.insert_allowed
    ,p_next_navigation_item_id         => l_rec.next_navigation_item_id
    ,p_previous_navigation_item_id     => l_rec.previous_navigation_item_id
    ,p_query_allowed                   => l_rec.query_allowed
    ,p_tooltip_text                    => p_tooltip_text
    ,p_update_allowed                  => l_rec.update_allowed
    ,p_validation_formula_id           => l_rec.validation_formula_id
    ,p_validation_param_item_id1       => l_rec.validation_param_item_id1
    ,p_validation_param_item_id2       => l_rec.validation_param_item_id2
    ,p_validation_param_item_id3       => l_rec.validation_param_item_id3
    ,p_validation_param_item_id4       => l_rec.validation_param_item_id4
    ,p_validation_param_item_id5       => l_rec.validation_param_item_id5
    ,p_object_version_number           => l_object_version_number
    );
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  hr_utility.set_location('At:'|| l_proc, 55);

  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_item_property_id             := l_item_property_id;
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
    rollback to copy_item_property;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_item_property_id             := null;
    --p_override_value_warning       := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to copy_item_property;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end copy_item_property;
--
--
--
-- ----------------------------------------------------------------------------
-- |--------------------< copy_item_property - overload 3>--------------------|
-- ----------------------------------------------------------------------------
--
procedure copy_item_property
  (p_validate                        in     boolean  default false
  ,p_effective_date                  in     date
  ,p_language_code                   in varchar2 default hr_api.userenv_lang
  ,p_template_item_context_id_frm    in number
  ,p_template_item_context_id_to     in number
  ,p_alignment                       in number default hr_api.g_number
  ,p_bevel                           in number default hr_api.g_number
  ,p_case_restriction                in number default hr_api.g_number
  ,p_default_value                   in varchar2 default hr_api.g_varchar2
  ,p_enabled                         in number default hr_api.g_number
  ,p_format_mask                     in varchar2 default hr_api.g_varchar2
  ,p_height                          in number default hr_api.g_number
  ,p_information_formula_id          in number default hr_api.g_number
  ,p_information_param_item_id1      in number default hr_api.g_number
  ,p_information_param_item_id2      in number default hr_api.g_number
  ,p_information_param_item_id3      in number default hr_api.g_number
  ,p_information_param_item_id4      in number default hr_api.g_number
  ,p_information_param_item_id5      in number default hr_api.g_number
  ,p_information_prompt              in varchar2 default hr_api.g_varchar2
  ,p_insert_allowed                  in number default hr_api.g_number
  ,p_label                           in varchar2 default hr_api.g_varchar2
  ,p_prompt_text                     in varchar2 default hr_api.g_varchar2
  ,p_prompt_alignment_offset         in number default hr_api.g_number
  ,p_prompt_display_style            in number default hr_api.g_number
  ,p_prompt_edge                     in number default hr_api.g_number
  ,p_prompt_edge_alignment           in number default hr_api.g_number
  ,p_prompt_edge_offset              in number default hr_api.g_number
  ,p_prompt_text_alignment           in number default hr_api.g_number
  ,p_query_allowed                   in number default hr_api.g_number
  ,p_required                        in number default hr_api.g_number
  ,p_tooltip_text                    in varchar2 default hr_api.g_varchar2
  ,p_update_allowed                  in number default hr_api.g_number
  ,p_validation_formula_id           in number default hr_api.g_number
  ,p_validation_param_item_id1       in number default hr_api.g_number
  ,p_validation_param_item_id2       in number default hr_api.g_number
  ,p_validation_param_item_id3       in number default hr_api.g_number
  ,p_validation_param_item_id4       in number default hr_api.g_number
  ,p_validation_param_item_id5       in number default hr_api.g_number
  ,p_visible                         in number default hr_api.g_number
  ,p_width                           in number default hr_api.g_number
  ,p_x_position                      in number default hr_api.g_number
  ,p_y_position                      in number default hr_api.g_number
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
  ,p_next_navigation_item_id         in number default hr_api.g_number
  ,p_previous_navigation_item_id     in number default hr_api.g_number
  ,p_item_property_id                  out nocopy number
  ,p_object_version_number             out nocopy number
  --,p_override_value_warning            out boolean
  ) is
  --
  -- Declare cursors and local variables
  --

  Type l_rec_type Is Record
  (alignment hr_item_properties_b.alignment%TYPE
  ,bevel hr_item_properties_b.bevel%TYPE
  ,case_restriction hr_item_properties_b.case_restriction%TYPE
  ,enabled hr_item_properties_b.enabled%TYPE
  ,format_mask hr_item_properties_b.format_mask%TYPE
  ,height hr_item_properties_b.height%TYPE
  ,information_formula_id hr_item_properties_b.information_formula_id%TYPE
  ,information_param_item_id1 hr_item_properties_b.information_parameter_item_id1%TYPE
  ,information_param_item_id2 hr_item_properties_b.information_parameter_item_id2%TYPE
  ,information_param_item_id3 hr_item_properties_b.information_parameter_item_id3%TYPE
  ,information_param_item_id4 hr_item_properties_b.information_parameter_item_id4%TYPE
  ,information_param_item_id5 hr_item_properties_b.information_parameter_item_id5%TYPE
  ,insert_allowed hr_item_properties_b.insert_allowed%TYPE
  ,prompt_alignment_offset hr_item_properties_b.prompt_alignment_offset%TYPE
  ,prompt_display_style hr_item_properties_b.prompt_display_style%TYPE
  ,prompt_edge hr_item_properties_b.prompt_edge%TYPE
  ,prompt_edge_alignment hr_item_properties_b.prompt_edge_alignment%TYPE
  ,prompt_edge_offset hr_item_properties_b.prompt_edge_offset%TYPE
  ,prompt_text_alignment hr_item_properties_b.prompt_text_alignment%TYPE
  ,query_allowed hr_item_properties_b.query_allowed%TYPE
  ,required hr_item_properties_b.required%TYPE
  ,update_allowed hr_item_properties_b.update_allowed%TYPE
  ,validation_formula_id hr_item_properties_b.validation_formula_id%TYPE
  ,validation_param_item_id1 hr_item_properties_b.validation_parameter_item_id1%TYPE
  ,validation_param_item_id2 hr_item_properties_b.validation_parameter_item_id2%TYPE
  ,validation_param_item_id3 hr_item_properties_b.validation_parameter_item_id3%TYPE
  ,validation_param_item_id4 hr_item_properties_b.validation_parameter_item_id4%TYPE
  ,validation_param_item_id5 hr_item_properties_b.validation_parameter_item_id5%TYPE
  ,visible hr_item_properties_b.visible%TYPE
  ,width hr_item_properties_b.width%TYPE
  ,x_position hr_item_properties_b.x_position%TYPE
  ,y_position hr_item_properties_b.y_position%TYPE
  ,information_category hr_item_properties_b.information_category%TYPE
  ,information1 hr_item_properties_b.information1%TYPE
  ,information2 hr_item_properties_b.information2%TYPE
  ,information3 hr_item_properties_b.information3%TYPE
  ,information4 hr_item_properties_b.information4%TYPE
  ,information5 hr_item_properties_b.information5%TYPE
  ,information6 hr_item_properties_b.information6%TYPE
  ,information7 hr_item_properties_b.information7%TYPE
  ,information8 hr_item_properties_b.information8%TYPE
  ,information9 hr_item_properties_b.information9%TYPE
  ,information10 hr_item_properties_b.information10%TYPE
  ,information11 hr_item_properties_b.information11%TYPE
  ,information12 hr_item_properties_b.information12%TYPE
  ,information13 hr_item_properties_b.information13%TYPE
  ,information14 hr_item_properties_b.information14%TYPE
  ,information15 hr_item_properties_b.information15%TYPE
  ,information16 hr_item_properties_b.information16%TYPE
  ,information17 hr_item_properties_b.information17%TYPE
  ,information18 hr_item_properties_b.information18%TYPE
  ,information19 hr_item_properties_b.information19%TYPE
  ,information20 hr_item_properties_b.information20%TYPE
  ,information21 hr_item_properties_b.information21%TYPE
  ,information22 hr_item_properties_b.information22%TYPE
  ,information23 hr_item_properties_b.information23%TYPE
  ,information24 hr_item_properties_b.information24%TYPE
  ,information25 hr_item_properties_b.information25%TYPE
  ,information26 hr_item_properties_b.information26%TYPE
  ,information27 hr_item_properties_b.information27%TYPE
  ,information28 hr_item_properties_b.information28%TYPE
  ,information29 hr_item_properties_b.information29%TYPE
  ,information30 hr_item_properties_b.information30%TYPE
  ,next_navigation_item_id hr_item_properties_b.next_navigation_item_id%TYPE
  ,previous_navigation_item_id hr_item_properties_b.previous_navigation_item_id%TYPE
  );

  l_rec l_rec_type;

  CURSOR cur_check
  IS
  SELECT tiw.form_item_id
  FROM hr_template_item_contexts tic
       , hr_template_items_b tiw
  WHERE tic.template_item_id = tiw.template_item_id
  AND tic.template_item_context_id = p_template_item_context_id_frm
  INTERSECT
  SELECT tiw.form_item_id
  FROM hr_template_item_contexts tic
       , hr_template_items_b tiw
  WHERE tic.template_item_id = tiw.template_item_id
  AND tic.template_item_context_id = p_template_item_context_id_to;

  CURSOR cur_item_prop
  IS
  SELECT DECODE(p_alignment,hr_api.g_number,itp.alignment,p_alignment)
  ,DECODE(p_bevel,hr_api.g_number,itp.bevel,p_bevel)
  ,DECODE(p_case_restriction,hr_api.g_number,itp.case_restriction,p_case_restriction)
  ,DECODE(p_enabled,hr_api.g_number,itp.enabled,p_enabled)
  ,DECODE(p_format_mask,hr_api.g_varchar2,itp.format_mask,p_format_mask)
  ,DECODE(p_height,hr_api.g_number,itp.height,p_height)
  ,DECODE(p_information_formula_id,hr_api.g_number,itp.information_formula_id,p_information_formula_id)
  ,DECODE(p_information_param_item_id1,hr_api.g_number,itp.information_parameter_item_id1,p_information_param_item_id1)
  ,DECODE(p_information_param_item_id2,hr_api.g_number,itp.information_parameter_item_id2,p_information_param_item_id2)
  ,DECODE(p_information_param_item_id3,hr_api.g_number,itp.information_parameter_item_id3,p_information_param_item_id3)
  ,DECODE(p_information_param_item_id4,hr_api.g_number,itp.information_parameter_item_id4,p_information_param_item_id4)
  ,DECODE(p_information_param_item_id5,hr_api.g_number,itp.information_parameter_item_id5,p_information_param_item_id5)
  ,DECODE(p_insert_allowed,hr_api.g_number,itp.insert_allowed,p_insert_allowed)
  ,DECODE(p_prompt_alignment_offset,hr_api.g_number,itp.prompt_alignment_offset,p_prompt_alignment_offset)
  ,DECODE(p_prompt_display_style,hr_api.g_number,itp.prompt_display_style,p_prompt_display_style)
  ,DECODE(p_prompt_edge,hr_api.g_number,itp.prompt_edge,p_prompt_edge)
  ,DECODE(p_prompt_edge_alignment,hr_api.g_number,itp.prompt_edge_alignment,p_prompt_edge_alignment)
  ,DECODE(p_prompt_edge_offset,hr_api.g_number,itp.prompt_edge_offset,p_prompt_edge_offset)
  ,DECODE(p_prompt_text_alignment,hr_api.g_number,itp.prompt_text_alignment,p_prompt_text_alignment)
  ,DECODE(p_query_allowed,hr_api.g_number,itp.query_allowed,p_query_allowed)
  ,DECODE(p_required,hr_api.g_number,itp.required,p_required)
  ,DECODE(p_update_allowed,hr_api.g_number,itp.update_allowed,p_update_allowed)
  ,DECODE(p_validation_formula_id,hr_api.g_number,itp.validation_formula_id,p_validation_formula_id)
  ,DECODE(p_validation_param_item_id1,hr_api.g_number,itp.validation_parameter_item_id1,p_validation_param_item_id1)
  ,DECODE(p_validation_param_item_id2,hr_api.g_number,itp.validation_parameter_item_id2,p_validation_param_item_id2)
  ,DECODE(p_validation_param_item_id3,hr_api.g_number,itp.validation_parameter_item_id3,p_validation_param_item_id3)
  ,DECODE(p_validation_param_item_id4,hr_api.g_number,itp.validation_parameter_item_id4,p_validation_param_item_id4)
  ,DECODE(p_validation_param_item_id5,hr_api.g_number,itp.validation_parameter_item_id5,p_validation_param_item_id5)
  ,DECODE(p_visible,hr_api.g_number,itp.visible,p_visible)
  ,DECODE(p_width,hr_api.g_number,itp.width,p_width)
  ,DECODE(p_x_position,hr_api.g_number,itp.x_position,p_x_position)
  ,DECODE(p_y_position,hr_api.g_number,itp.y_position,p_y_position)
  ,DECODE(p_information_category,hr_api.g_varchar2,itp.information_category,p_information_category)
  ,DECODE(p_information1,hr_api.g_varchar2,itp.information1,p_information1)
  ,DECODE(p_information2,hr_api.g_varchar2,itp.information2,p_information2)
  ,DECODE(p_information3,hr_api.g_varchar2,itp.information3,p_information3)
  ,DECODE(p_information4,hr_api.g_varchar2,itp.information4,p_information4)
  ,DECODE(p_information5,hr_api.g_varchar2,itp.information5,p_information5)
  ,DECODE(p_information6,hr_api.g_varchar2,itp.information6,p_information6)
  ,DECODE(p_information7,hr_api.g_varchar2,itp.information7,p_information7)
  ,DECODE(p_information8,hr_api.g_varchar2,itp.information8,p_information8)
  ,DECODE(p_information9,hr_api.g_varchar2,itp.information9,p_information9)
  ,DECODE(p_information10,hr_api.g_varchar2,itp.information10,p_information10)
  ,DECODE(p_information11,hr_api.g_varchar2,itp.information11,p_information11)
  ,DECODE(p_information12,hr_api.g_varchar2,itp.information12,p_information12)
  ,DECODE(p_information13,hr_api.g_varchar2,itp.information13,p_information13)
  ,DECODE(p_information14,hr_api.g_varchar2,itp.information14,p_information14)
  ,DECODE(p_information15,hr_api.g_varchar2,itp.information15,p_information15)
  ,DECODE(p_information16,hr_api.g_varchar2,itp.information16,p_information16)
  ,DECODE(p_information17,hr_api.g_varchar2,itp.information17,p_information17)
  ,DECODE(p_information18,hr_api.g_varchar2,itp.information18,p_information18)
  ,DECODE(p_information19,hr_api.g_varchar2,itp.information19,p_information19)
  ,DECODE(p_information20,hr_api.g_varchar2,itp.information20,p_information20)
  ,DECODE(p_information21,hr_api.g_varchar2,itp.information21,p_information21)
  ,DECODE(p_information22,hr_api.g_varchar2,itp.information22,p_information22)
  ,DECODE(p_information23,hr_api.g_varchar2,itp.information23,p_information23)
  ,DECODE(p_information24,hr_api.g_varchar2,itp.information24,p_information24)
  ,DECODE(p_information25,hr_api.g_varchar2,itp.information25,p_information25)
  ,DECODE(p_information26,hr_api.g_varchar2,itp.information26,p_information26)
  ,DECODE(p_information27,hr_api.g_varchar2,itp.information27,p_information27)
  ,DECODE(p_information28,hr_api.g_varchar2,itp.information28,p_information28)
  ,DECODE(p_information29,hr_api.g_varchar2,itp.information29,p_information29)
  ,DECODE(p_information30,hr_api.g_varchar2,itp.information30,p_information30)
  ,DECODE(p_next_navigation_item_id,hr_api.g_number,itp.next_navigation_item_id,p_next_navigation_item_id)
  ,DECODE(p_previous_navigation_item_id,hr_api.g_number,itp.previous_navigation_item_id,p_previous_navigation_item_id)
  FROM hr_item_properties_b itp
      , hr_template_item_contexts_b tic
  WHERE itp.template_item_context_id = tic.template_item_context_id
  AND tic.template_item_context_id = p_template_item_context_id_frm;

  CURSOR cur_item_tl
  IS
  SELECT COUNT(0) t_count
  ,itptl.source_lang
  ,DECODE(p_default_value,hr_api.g_varchar2,itptl.default_value,p_default_value) default_value
  ,DECODE(p_information_prompt,hr_api.g_varchar2,itptl.information_prompt,p_information_prompt) information_prompt
  ,DECODE(p_label,hr_api.g_varchar2,itptl.label,p_label) label
  ,DECODE(p_prompt_text,hr_api.g_varchar2,itptl.prompt_text,p_prompt_text) prompt_text
  ,DECODE(p_tooltip_text,hr_api.g_varchar2,itptl.tooltip_text,p_tooltip_text) tooltip_text
  FROM hr_item_properties_tl itptl
  ,hr_item_properties_b itp
  WHERE itptl.item_property_id = itp.item_property_id
  AND itp.template_item_context_id = p_template_item_context_id_frm
  GROUP BY itptl.source_lang
  ,DECODE(p_default_value,hr_api.g_varchar2,itptl.default_value,p_default_value)
  ,DECODE(p_information_prompt,hr_api.g_varchar2,itptl.information_prompt,p_information_prompt)
  ,DECODE(p_label,hr_api.g_varchar2,itptl.label,p_label)
  ,DECODE(p_prompt_text,hr_api.g_varchar2,itptl.prompt_text,p_prompt_text)
  ,DECODE(p_tooltip_text,hr_api.g_varchar2,itptl.tooltip_text,p_tooltip_text)
  ORDER BY 1;

  l_language_code fnd_languages.language_code%TYPE;

  l_check number;
  l_item_property_id                  number ;
  l_object_version_number             number;
  l_override_value_warning            boolean;
  l_proc                varchar2(72) := g_package||'copy_item_property';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint copy_item_property;
  --
  -- Truncate the time portion from all IN date parameters
  --

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
  hr_utility.set_location('At:'|| l_proc, 15);

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
  hr_utility.set_location('At:'|| l_proc, 20);

  OPEN cur_item_prop;
  FETCH cur_item_prop INTO l_rec;
  CLOSE cur_item_prop;

  hr_utility.set_location('At:'|| l_proc, 30);

  hr_itp_ins.ins(p_effective_date           => TRUNC(p_effective_date)
            ,p_template_item_context_id     => p_template_item_context_id_to
            ,p_alignment                    => l_rec.alignment
            ,p_bevel                        => l_rec.bevel
            ,p_case_restriction             => l_rec.case_restriction
            ,p_enabled                      => l_rec.enabled
            ,p_format_mask                  => l_rec.format_mask
            ,p_height                       => l_rec.height
            ,p_information_formula_id       => l_rec.information_formula_id
            ,p_information_param_item_id1   => l_rec.information_param_item_id1
            ,p_information_param_item_id2   => l_rec.information_param_item_id2
            ,p_information_param_item_id3   => l_rec.information_param_item_id3
            ,p_information_param_item_id4   => l_rec.information_param_item_id4
            ,p_information_param_item_id5   => l_rec.information_param_item_id5
            ,p_insert_allowed               => l_rec.insert_allowed
            ,p_prompt_alignment_offset      => l_rec.prompt_alignment_offset
            ,p_prompt_display_style         => l_rec.prompt_display_style
            ,p_prompt_edge                  => l_rec.prompt_edge
            ,p_prompt_edge_alignment        => l_rec.prompt_edge_alignment
            ,p_prompt_edge_offset           => l_rec.prompt_edge_offset
            ,p_prompt_text_alignment        => l_rec.prompt_text_alignment
            ,p_query_allowed                => l_rec.query_allowed
            ,p_required                     => l_rec.required
            ,p_update_allowed               => l_rec.update_allowed
            ,p_validation_formula_id        => l_rec.validation_formula_id
            ,p_validation_param_item_id1    => l_rec.validation_param_item_id1
            ,p_validation_param_item_id2    => l_rec.validation_param_item_id2
            ,p_validation_param_item_id3    => l_rec.validation_param_item_id3
            ,p_validation_param_item_id4    => l_rec.validation_param_item_id4
            ,p_validation_param_item_id5    => l_rec.validation_param_item_id5
            ,p_visible                      => l_rec.visible
            ,p_width                        => l_rec.width
            ,p_x_position                   => l_rec.x_position
            ,p_y_position                   => l_rec.y_position
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
            ,p_next_navigation_item_id      => l_rec.next_navigation_item_id
            ,p_previous_navigation_item_id  => l_rec.previous_navigation_item_id
            ,p_item_property_id             => l_item_property_id
            ,p_object_version_number        => l_object_version_number);
            --,p_override_value_warning       => l_override_value_warning);

  hr_utility.set_location('At:'|| l_proc, 35);

  IF  ( p_default_value <> hr_api.g_varchar2)
  AND ( p_information_prompt <> hr_api.g_varchar2)
  AND ( p_label <> hr_api.g_varchar2 )
  AND ( p_prompt_text <> hr_api.g_varchar2 )
  AND ( p_tooltip_text <> hr_api.g_varchar2 ) THEN

    hr_utility.set_location('At:'|| l_proc, 40);

    hr_ipt_ins.ins_tl(p_language_code                => l_language_code
               ,p_item_property_id             => l_item_property_id
               ,p_default_value                => p_default_value
               ,p_information_prompt           => p_information_prompt
               ,p_label                        => p_label
               ,p_prompt_text                  => p_prompt_text
               ,p_tooltip_text                 => p_tooltip_text);

  ELSE
    hr_utility.set_location('At:'|| l_proc, 45);

    FOR cur_rec in cur_item_tl LOOP
       IF cur_item_tl%ROWCOUNT = 1 THEN
         hr_utility.set_location('At:'|| l_proc, 50);

         hr_ipt_ins.ins_tl(p_language_code                => cur_rec.source_lang
                  ,p_item_property_id             => l_item_property_id
                  ,p_default_value                => cur_rec.default_value
                  ,p_information_prompt           => cur_rec.information_prompt
                  ,p_label                        => cur_rec.label
                  ,p_prompt_text                  => cur_rec.prompt_text
                  ,p_tooltip_text                 => cur_rec.tooltip_text);
      ELSE
         hr_utility.set_location('At:'|| l_proc, 55);

        hr_ipt_upd.upd_tl(p_language_code                => cur_rec.source_lang
                  ,p_item_property_id             => l_item_property_id
                  ,p_default_value                => cur_rec.default_value
                  ,p_information_prompt           => cur_rec.information_prompt
                  ,p_label                        => cur_rec.label
                  ,p_prompt_text                  => cur_rec.prompt_text
                  ,p_tooltip_text                 => cur_rec.tooltip_text);
      END IF;
    END LOOP;
  END IF;
  --
  -- Update properties common across all buttons of a radio group
  --
  update_radio_button_property
    (p_effective_date                  => TRUNC(p_effective_date)
    ,p_language_code                   => l_language_code
    ,p_form_item_id                    => NULL
    ,p_template_item_id                => NULL
    ,p_template_item_context_id        => p_template_item_context_id_to
    ,p_default_value                   => p_default_value
    ,p_information_formula_id          => l_rec.information_formula_id
    ,p_information_param_item_id1      => l_rec.information_param_item_id1
    ,p_information_param_item_id2      => l_rec.information_param_item_id2
    ,p_information_param_item_id3      => l_rec.information_param_item_id3
    ,p_information_param_item_id4      => l_rec.information_param_item_id4
    ,p_information_param_item_id5      => l_rec.information_param_item_id5
    ,p_information_prompt              => p_information_prompt
    ,p_insert_allowed                  => l_rec.insert_allowed
    ,p_next_navigation_item_id         => l_rec.next_navigation_item_id
    ,p_previous_navigation_item_id     => l_rec.previous_navigation_item_id
    ,p_query_allowed                   => l_rec.query_allowed
    ,p_tooltip_text                    => p_tooltip_text
    ,p_update_allowed                  => l_rec.update_allowed
    ,p_validation_formula_id           => l_rec.validation_formula_id
    ,p_validation_param_item_id1       => l_rec.validation_param_item_id1
    ,p_validation_param_item_id2       => l_rec.validation_param_item_id2
    ,p_validation_param_item_id3       => l_rec.validation_param_item_id3
    ,p_validation_param_item_id4       => l_rec.validation_param_item_id4
    ,p_validation_param_item_id5       => l_rec.validation_param_item_id5
    ,p_object_version_number           => p_object_version_number
    );
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  hr_utility.set_location('At:'|| l_proc, 60);

  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_item_property_id             := l_item_property_id;
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
    rollback to copy_item_property;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_item_property_id             := null;
    --p_override_value_warning       := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to copy_item_property;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end copy_item_property;
--
end hr_item_properties_bsi;

/
