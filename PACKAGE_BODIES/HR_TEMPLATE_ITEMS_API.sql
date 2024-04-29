--------------------------------------------------------
--  DDL for Package Body HR_TEMPLATE_ITEMS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_TEMPLATE_ITEMS_API" as
/* $Header: hrtimapi.pkb 120.1 2007/11/26 05:58:17 ktithy ship $ */
  --
  -- Package Variables
  --
  g_package  varchar2(33) := '  hr_template_items_api.';
--
PROCEDURE update_template_item_contexts
  (p_effective_date               IN     DATE
  ,p_language_code                IN     VARCHAR2 DEFAULT hr_api.userenv_lang
  ,p_template_item_id             IN     NUMBER
  ,p_alignment                    IN     NUMBER   DEFAULT hr_api.g_number
  ,p_bevel                        IN     NUMBER   DEFAULT hr_api.g_number
  ,p_case_restriction             IN     NUMBER   DEFAULT hr_api.g_number
  ,p_default_value                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_enabled                      IN     NUMBER   DEFAULT hr_api.g_number
  ,p_format_mask                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_height                       IN     NUMBER   DEFAULT hr_api.g_number
  ,p_information_formula_id       IN     NUMBER   DEFAULT hr_api.g_number
  ,p_information_param_item_id1   IN     NUMBER   DEFAULT hr_api.g_number
  ,p_information_param_item_id2   IN     NUMBER   DEFAULT hr_api.g_number
  ,p_information_param_item_id3   IN     NUMBER   DEFAULT hr_api.g_number
  ,p_information_param_item_id4   IN     NUMBER   DEFAULT hr_api.g_number
  ,p_information_param_item_id5   IN     NUMBER   DEFAULT hr_api.g_number
  ,p_information_prompt           IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_insert_allowed               IN     NUMBER   DEFAULT hr_api.g_number
  ,p_label                        IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_next_navigation_item_id      IN     NUMBER   DEFAULT hr_api.g_number
  ,p_previous_navigation_item_id  IN     NUMBER   DEFAULT hr_api.g_number
  ,p_prompt_text                  IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_prompt_alignment_offset      IN     NUMBER   DEFAULT hr_api.g_number
  ,p_prompt_display_style         IN     NUMBER   DEFAULT hr_api.g_number
  ,p_prompt_edge                  IN     NUMBER   DEFAULT hr_api.g_number
  ,p_prompt_edge_alignment        IN     NUMBER   DEFAULT hr_api.g_number
  ,p_prompt_edge_offset           IN     NUMBER   DEFAULT hr_api.g_number
  ,p_prompt_text_alignment        IN     NUMBER   DEFAULT hr_api.g_number
  ,p_query_allowed                IN     NUMBER   DEFAULT hr_api.g_number
  ,p_required                     IN     NUMBER   DEFAULT hr_api.g_number
  ,p_tooltip_text                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_update_allowed               IN     NUMBER   DEFAULT hr_api.g_number
  ,p_validation_formula_id        IN     NUMBER   DEFAULT hr_api.g_number
  ,p_validation_param_item_id1    IN     NUMBER   DEFAULT hr_api.g_number
  ,p_validation_param_item_id2    IN     NUMBER   DEFAULT hr_api.g_number
  ,p_validation_param_item_id3    IN     NUMBER   DEFAULT hr_api.g_number
  ,p_validation_param_item_id4    IN     NUMBER   DEFAULT hr_api.g_number
  ,p_validation_param_item_id5    IN     NUMBER   DEFAULT hr_api.g_number
  ,p_visible                      IN     NUMBER   DEFAULT hr_api.g_number
  ,p_width                        IN     NUMBER   DEFAULT hr_api.g_number
  ,p_x_position                   IN     NUMBER   DEFAULT hr_api.g_number
  ,p_y_position                   IN     NUMBER   DEFAULT hr_api.g_number
  ,p_information_category         IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_information1                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_information2                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_information3                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_information4                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_information5                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_information6                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_information7                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_information8                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_information9                 IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_information10                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_information11                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_information12                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_information13                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_information14                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_information15                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_information16                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_information17                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_information18                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_information19                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_information20                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_information21                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_information22                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_information23                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_information24                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_information25                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_information26                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_information27                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_information28                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_information29                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  ,p_information30                IN     VARCHAR2 DEFAULT hr_api.g_varchar2
  )
IS
  --
  CURSOR csr_template_item_contexts
    (p_language_code                IN     VARCHAR2
    ,p_template_item_id             IN     NUMBER
    )
  IS
    SELECT tic.template_item_context_id
          ,tic.object_version_number
          ,itp.alignment
          ,itp.bevel
          ,itp.case_restriction
          ,ipt.default_value
          ,itp.enabled
          ,itp.format_mask
          ,itp.height
          ,itp.information_formula_id
          ,itp.information_parameter_item_id1
          ,itp.information_parameter_item_id2
          ,itp.information_parameter_item_id3
          ,itp.information_parameter_item_id4
          ,itp.information_parameter_item_id5
          ,ipt.information_prompt
          ,itp.insert_allowed
          ,ipt.label
          ,itp.next_navigation_item_id
          ,itp.previous_navigation_item_id
          ,ipt.prompt_text
          ,itp.prompt_alignment_offset
          ,itp.prompt_display_style
          ,itp.prompt_edge
          ,itp.prompt_edge_alignment
          ,itp.prompt_edge_offset
          ,itp.prompt_text_alignment
          ,itp.query_allowed
          ,itp.required
          ,ipt.tooltip_text
          ,itp.update_allowed
          ,itp.validation_formula_id
          ,itp.validation_parameter_item_id1
          ,itp.validation_parameter_item_id2
          ,itp.validation_parameter_item_id3
          ,itp.validation_parameter_item_id4
          ,itp.validation_parameter_item_id5
          ,itp.visible
          ,itp.width
          ,itp.x_position
          ,itp.y_position
          ,itp.information_category
          ,itp.information1
          ,itp.information2
          ,itp.information3
          ,itp.information4
          ,itp.information5
          ,itp.information6
          ,itp.information7
          ,itp.information8
          ,itp.information9
          ,itp.information10
          ,itp.information11
          ,itp.information12
          ,itp.information13
          ,itp.information14
          ,itp.information15
          ,itp.information16
          ,itp.information17
          ,itp.information18
          ,itp.information19
          ,itp.information20
          ,itp.information21
          ,itp.information22
          ,itp.information23
          ,itp.information24
          ,itp.information25
          ,itp.information26
          ,itp.information27
          ,itp.information28
          ,itp.information29
          ,itp.information30
      FROM hr_item_properties_tl ipt
          ,hr_item_properties_b itp
          ,hr_template_item_contexts_b tic
     WHERE ipt.language = p_language_code
       AND ipt.item_property_id = itp.item_property_id
       AND itp.template_item_context_id = tic.template_item_context_id
       AND tic.template_item_id = p_template_item_id;
  l_template_item_context        csr_template_item_contexts%ROWTYPE;
  --
  CURSOR csr_template_items
    (p_language_code                IN     VARCHAR2
    ,p_template_item_id             IN     NUMBER
    )
  IS
    SELECT itp.alignment
          ,itp.bevel
          ,itp.case_restriction
          ,ipt.default_value
          ,itp.enabled
          ,itp.format_mask
          ,itp.height
          ,itp.information_formula_id
          ,itp.information_parameter_item_id1
          ,itp.information_parameter_item_id2
          ,itp.information_parameter_item_id3
          ,itp.information_parameter_item_id4
          ,itp.information_parameter_item_id5
          ,ipt.information_prompt
          ,itp.insert_allowed
          ,ipt.label
          ,itp.next_navigation_item_id
          ,itp.previous_navigation_item_id
          ,ipt.prompt_text
          ,itp.prompt_alignment_offset
          ,itp.prompt_display_style
          ,itp.prompt_edge
          ,itp.prompt_edge_alignment
          ,itp.prompt_edge_offset
          ,itp.prompt_text_alignment
          ,itp.query_allowed
          ,itp.required
          ,ipt.tooltip_text
          ,itp.update_allowed
          ,itp.validation_formula_id
          ,itp.validation_parameter_item_id1
          ,itp.validation_parameter_item_id2
          ,itp.validation_parameter_item_id3
          ,itp.validation_parameter_item_id4
          ,itp.validation_parameter_item_id5
          ,itp.visible
          ,itp.width
          ,itp.x_position
          ,itp.y_position
          ,itp.information_category
          ,itp.information1
          ,itp.information2
          ,itp.information3
          ,itp.information4
          ,itp.information5
          ,itp.information6
          ,itp.information7
          ,itp.information8
          ,itp.information9
          ,itp.information10
          ,itp.information11
          ,itp.information12
          ,itp.information13
          ,itp.information14
          ,itp.information15
          ,itp.information16
          ,itp.information17
          ,itp.information18
          ,itp.information19
          ,itp.information20
          ,itp.information21
          ,itp.information22
          ,itp.information23
          ,itp.information24
          ,itp.information25
          ,itp.information26
          ,itp.information27
          ,itp.information28
          ,itp.information29
          ,itp.information30
      FROM hr_item_properties_tl ipt
          ,hr_item_properties_b itp
     WHERE ipt.language = p_language_code
       AND ipt.item_property_id = itp.item_property_id
       AND itp.template_item_id = p_template_item_id;
  l_template_item                csr_template_items%ROWTYPE;
  --
  l_proc                         VARCHAR2(72) := g_package||'update_template_item_contexts';
  l_warning                      BOOLEAN;
--
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc,10);
  --
  -- Only process if contexts exist for the item
  --
  OPEN csr_template_item_contexts
    (p_language_code                => p_language_code
    ,p_template_item_id             => p_template_item_id
    );
  FETCH csr_template_item_contexts INTO l_template_item_context;
  IF (csr_template_item_contexts%NOTFOUND)
  THEN
    CLOSE csr_template_item_contexts;
    RETURN;
  END IF;
  CLOSE csr_template_item_contexts;
  --
  hr_utility.set_location(l_proc,20);
  --
  -- Get the original item properties
  --
  OPEN csr_template_items
    (p_language_code                => p_language_code
    ,p_template_item_id             => p_template_item_id
    );
  FETCH csr_template_items INTO l_template_item;
  CLOSE csr_template_items;
  --
  hr_utility.set_location(l_proc,30);
  --
  -- For each item context
  --
  FOR l_template_item_context IN csr_template_item_contexts
    (p_language_code                => p_language_code
    ,p_template_item_id             => p_template_item_id
    )
  LOOP
    --
    hr_utility.set_location(l_proc,40);
    --
    -- If context property equals previous item property then context property
    -- becomes new item property.
    --
    IF (NVL(l_template_item_context.alignment,hr_api.g_number) = NVL(l_template_item.alignment,hr_api.g_number)) THEN
      l_template_item_context.alignment := p_alignment;
    END IF;
    IF (NVL(l_template_item_context.bevel,hr_api.g_number) = NVL(l_template_item.bevel,hr_api.g_number)) THEN
      l_template_item_context.bevel := p_bevel;
    END IF;
    IF (NVL(l_template_item_context.case_restriction,hr_api.g_number) = NVL(l_template_item.case_restriction,hr_api.g_number)) THEN
      l_template_item_context.case_restriction := p_case_restriction;
    END IF;
    IF (NVL(l_template_item_context.default_value,hr_api.g_varchar2) = NVL(l_template_item.default_value,hr_api.g_varchar2)) THEN
      l_template_item_context.default_value := p_default_value;
    END IF;
    IF (NVL(l_template_item_context.enabled,hr_api.g_number) = NVL(l_template_item.enabled,hr_api.g_number)) THEN
      l_template_item_context.enabled := p_enabled;
    END IF;
    IF (NVL(l_template_item_context.format_mask,hr_api.g_varchar2) = NVL(l_template_item.format_mask,hr_api.g_varchar2)) THEN
      l_template_item_context.format_mask := p_format_mask;
    END IF;
    IF (NVL(l_template_item_context.height,hr_api.g_number) = NVL(l_template_item.height,hr_api.g_number)) THEN
      l_template_item_context.height := p_height;
    END IF;
    IF (NVL(l_template_item_context.information_formula_id,hr_api.g_number) = NVL(l_template_item.information_formula_id,hr_api.g_number)) THEN
      l_template_item_context.information_formula_id := p_information_formula_id;
    END IF;
    IF (NVL(l_template_item_context.information_parameter_item_id1,hr_api.g_number) = NVL(l_template_item.information_parameter_item_id1,hr_api.g_number)) THEN
      l_template_item_context.information_parameter_item_id1 := p_information_param_item_id1;
    END IF;
    IF (NVL(l_template_item_context.information_parameter_item_id2,hr_api.g_number) = NVL(l_template_item.information_parameter_item_id2,hr_api.g_number)) THEN
      l_template_item_context.information_parameter_item_id2 := p_information_param_item_id2;
    END IF;
    IF (NVL(l_template_item_context.information_parameter_item_id3,hr_api.g_number) = NVL(l_template_item.information_parameter_item_id3,hr_api.g_number)) THEN
      l_template_item_context.information_parameter_item_id3 := p_information_param_item_id3;
    END IF;
    IF (NVL(l_template_item_context.information_parameter_item_id4,hr_api.g_number) = NVL(l_template_item.information_parameter_item_id4,hr_api.g_number)) THEN
      l_template_item_context.information_parameter_item_id4 := p_information_param_item_id4;
    END IF;
    IF (NVL(l_template_item_context.information_parameter_item_id5,hr_api.g_number) = NVL(l_template_item.information_parameter_item_id5,hr_api.g_number)) THEN
      l_template_item_context.information_parameter_item_id5 := p_information_param_item_id5;
    END IF;
    IF (NVL(l_template_item_context.information_prompt,hr_api.g_varchar2) = NVL(l_template_item.information_prompt,hr_api.g_varchar2)) THEN
      l_template_item_context.information_prompt := p_information_prompt;
    END IF;
    IF (NVL(l_template_item_context.insert_allowed,hr_api.g_number) = NVL(l_template_item.insert_allowed,hr_api.g_number)) THEN
      l_template_item_context.insert_allowed := p_insert_allowed;
    END IF;
    IF (NVL(l_template_item_context.label,hr_api.g_varchar2) = NVL(l_template_item.label,hr_api.g_varchar2)) THEN
      l_template_item_context.label := p_label;
    END IF;
    IF (NVL(l_template_item_context.next_navigation_item_id,hr_api.g_number) = NVL(l_template_item.next_navigation_item_id,hr_api.g_number)) THEN
      l_template_item_context.next_navigation_item_id := p_next_navigation_item_id;
    END IF;
    IF (NVL(l_template_item_context.previous_navigation_item_id,hr_api.g_number) = NVL(l_template_item.previous_navigation_item_id,hr_api.g_number)) THEN
      l_template_item_context.previous_navigation_item_id := p_previous_navigation_item_id;
    END IF;
    IF (NVL(l_template_item_context.prompt_text,hr_api.g_varchar2) = NVL(l_template_item.prompt_text,hr_api.g_varchar2)) THEN
      l_template_item_context.prompt_text := p_prompt_text;
    END IF;
    IF (NVL(l_template_item_context.prompt_alignment_offset,hr_api.g_number) = NVL(l_template_item.prompt_alignment_offset,hr_api.g_number)) THEN
      l_template_item_context.prompt_alignment_offset := p_prompt_alignment_offset;
    END IF;
    IF (NVL(l_template_item_context.prompt_display_style,hr_api.g_number) = NVL(l_template_item.prompt_display_style,hr_api.g_number)) THEN
      l_template_item_context.prompt_display_style := p_prompt_display_style;
    END IF;
    IF (NVL(l_template_item_context.prompt_edge,hr_api.g_number) = NVL(l_template_item.prompt_edge,hr_api.g_number)) THEN
      l_template_item_context.prompt_edge := p_prompt_edge;
    END IF;
    IF (NVL(l_template_item_context.prompt_edge_alignment,hr_api.g_number) = NVL(l_template_item.prompt_edge_alignment,hr_api.g_number)) THEN
      l_template_item_context.prompt_edge_alignment := p_prompt_edge_alignment;
    END IF;
    IF (NVL(l_template_item_context.prompt_edge_offset,hr_api.g_number) = NVL(l_template_item.prompt_edge_offset,hr_api.g_number)) THEN
      l_template_item_context.prompt_edge_offset := p_prompt_edge_offset;
    END IF;
    IF (NVL(l_template_item_context.prompt_text_alignment,hr_api.g_number) = NVL(l_template_item.prompt_text_alignment,hr_api.g_number)) THEN
      l_template_item_context.prompt_text_alignment := p_prompt_text_alignment;
    END IF;
    IF (NVL(l_template_item_context.query_allowed,hr_api.g_number) = NVL(l_template_item.query_allowed,hr_api.g_number)) THEN
      l_template_item_context.query_allowed := p_query_allowed;
    END IF;
    IF (NVL(l_template_item_context.required,hr_api.g_number) = NVL(l_template_item.required,hr_api.g_number)) THEN
      l_template_item_context.required := p_required;
    END IF;
    IF (NVL(l_template_item_context.tooltip_text,hr_api.g_varchar2) = NVL(l_template_item.tooltip_text,hr_api.g_varchar2)) THEN
      l_template_item_context.tooltip_text := p_tooltip_text;
    END IF;
    IF (NVL(l_template_item_context.update_allowed,hr_api.g_number) = NVL(l_template_item.update_allowed,hr_api.g_number)) THEN
      l_template_item_context.update_allowed := p_update_allowed;
    END IF;
    IF (NVL(l_template_item_context.validation_formula_id,hr_api.g_number) = NVL(l_template_item.validation_formula_id,hr_api.g_number)) THEN
      l_template_item_context.validation_formula_id := p_validation_formula_id;
    END IF;
    IF (NVL(l_template_item_context.validation_parameter_item_id1,hr_api.g_number) = NVL(l_template_item.validation_parameter_item_id1,hr_api.g_number)) THEN
      l_template_item_context.validation_parameter_item_id1 := p_validation_param_item_id1;
    END IF;
    IF (NVL(l_template_item_context.validation_parameter_item_id2,hr_api.g_number) = NVL(l_template_item.validation_parameter_item_id2,hr_api.g_number)) THEN
      l_template_item_context.validation_parameter_item_id2 := p_validation_param_item_id2;
    END IF;
    IF (NVL(l_template_item_context.validation_parameter_item_id3,hr_api.g_number) = NVL(l_template_item.validation_parameter_item_id3,hr_api.g_number)) THEN
      l_template_item_context.validation_parameter_item_id3 := p_validation_param_item_id3;
    END IF;
    IF (NVL(l_template_item_context.validation_parameter_item_id4,hr_api.g_number) = NVL(l_template_item.validation_parameter_item_id4,hr_api.g_number)) THEN
      l_template_item_context.validation_parameter_item_id4 := p_validation_param_item_id4;
    END IF;
    IF (NVL(l_template_item_context.validation_parameter_item_id5,hr_api.g_number) = NVL(l_template_item.validation_parameter_item_id5,hr_api.g_number)) THEN
      l_template_item_context.validation_parameter_item_id5 := p_validation_param_item_id5;
    END IF;
    IF (NVL(l_template_item_context.visible,hr_api.g_number) = NVL(l_template_item.visible,hr_api.g_number)) THEN
      l_template_item_context.visible := p_visible;
    END IF;
    IF (NVL(l_template_item_context.width,hr_api.g_number) = NVL(l_template_item.width,hr_api.g_number)) THEN
      l_template_item_context.width := p_width;
    END IF;
    IF (NVL(l_template_item_context.x_position,hr_api.g_number) = NVL(l_template_item.x_position,hr_api.g_number)) THEN
      l_template_item_context.x_position := p_x_position;
    END IF;
    IF (NVL(l_template_item_context.y_position,hr_api.g_number) = NVL(l_template_item.y_position,hr_api.g_number)) THEN
      l_template_item_context.y_position := p_y_position;
    END IF;
    IF (NVL(l_template_item_context.information_category,hr_api.g_varchar2) = NVL(l_template_item.information_category,hr_api.g_varchar2)) THEN
      l_template_item_context.information_category := p_information_category;
      IF (NVL(l_template_item_context.information1,hr_api.g_varchar2) = NVL(l_template_item.information1,hr_api.g_varchar2)) THEN
        l_template_item_context.information1 := p_information1;
      END IF;
      IF (NVL(l_template_item_context.information2,hr_api.g_varchar2) = NVL(l_template_item.information2,hr_api.g_varchar2)) THEN
        l_template_item_context.information2 := p_information2;
      END IF;
      IF (NVL(l_template_item_context.information3,hr_api.g_varchar2) = NVL(l_template_item.information3,hr_api.g_varchar2)) THEN
        l_template_item_context.information3 := p_information3;
      END IF;
      IF (NVL(l_template_item_context.information4,hr_api.g_varchar2) = NVL(l_template_item.information4,hr_api.g_varchar2)) THEN
        l_template_item_context.information4 := p_information4;
      END IF;
      IF (NVL(l_template_item_context.information5,hr_api.g_varchar2) = NVL(l_template_item.information5,hr_api.g_varchar2)) THEN
        l_template_item_context.information5 := p_information5;
      END IF;
      IF (NVL(l_template_item_context.information6,hr_api.g_varchar2) = NVL(l_template_item.information6,hr_api.g_varchar2)) THEN
        l_template_item_context.information6 := p_information6;
      END IF;
      IF (NVL(l_template_item_context.information7,hr_api.g_varchar2) = NVL(l_template_item.information7,hr_api.g_varchar2)) THEN
        l_template_item_context.information7 := p_information7;
      END IF;
      IF (NVL(l_template_item_context.information8,hr_api.g_varchar2) = NVL(l_template_item.information8,hr_api.g_varchar2)) THEN
        l_template_item_context.information8 := p_information8;
      END IF;
      IF (NVL(l_template_item_context.information9,hr_api.g_varchar2) = NVL(l_template_item.information9,hr_api.g_varchar2)) THEN
        l_template_item_context.information9 := p_information9;
      END IF;
      IF (NVL(l_template_item_context.information10,hr_api.g_varchar2) = NVL(l_template_item.information10,hr_api.g_varchar2)) THEN
        l_template_item_context.information10 := p_information10;
      END IF;
      IF (NVL(l_template_item_context.information11,hr_api.g_varchar2) = NVL(l_template_item.information11,hr_api.g_varchar2)) THEN
        l_template_item_context.information11 := p_information11;
      END IF;
      IF (NVL(l_template_item_context.information12,hr_api.g_varchar2) = NVL(l_template_item.information12,hr_api.g_varchar2)) THEN
        l_template_item_context.information12 := p_information12;
      END IF;
      IF (NVL(l_template_item_context.information13,hr_api.g_varchar2) = NVL(l_template_item.information13,hr_api.g_varchar2)) THEN
        l_template_item_context.information13 := p_information13;
      END IF;
      IF (NVL(l_template_item_context.information14,hr_api.g_varchar2) = NVL(l_template_item.information14,hr_api.g_varchar2)) THEN
        l_template_item_context.information14 := p_information14;
      END IF;
      IF (NVL(l_template_item_context.information15,hr_api.g_varchar2) = NVL(l_template_item.information15,hr_api.g_varchar2)) THEN
        l_template_item_context.information15 := p_information15;
      END IF;
      IF (NVL(l_template_item_context.information16,hr_api.g_varchar2) = NVL(l_template_item.information16,hr_api.g_varchar2)) THEN
        l_template_item_context.information16 := p_information16;
      END IF;
      IF (NVL(l_template_item_context.information17,hr_api.g_varchar2) = NVL(l_template_item.information17,hr_api.g_varchar2)) THEN
        l_template_item_context.information17 := p_information17;
      END IF;
      IF (NVL(l_template_item_context.information18,hr_api.g_varchar2) = NVL(l_template_item.information18,hr_api.g_varchar2)) THEN
        l_template_item_context.information18 := p_information18;
      END IF;
      IF (NVL(l_template_item_context.information19,hr_api.g_varchar2) = NVL(l_template_item.information19,hr_api.g_varchar2)) THEN
        l_template_item_context.information19 := p_information19;
      END IF;
      IF (NVL(l_template_item_context.information20,hr_api.g_varchar2) = NVL(l_template_item.information20,hr_api.g_varchar2)) THEN
        l_template_item_context.information20 := p_information20;
      END IF;
      IF (NVL(l_template_item_context.information21,hr_api.g_varchar2) = NVL(l_template_item.information21,hr_api.g_varchar2)) THEN
        l_template_item_context.information21 := p_information21;
      END IF;
      IF (NVL(l_template_item_context.information22,hr_api.g_varchar2) = NVL(l_template_item.information22,hr_api.g_varchar2)) THEN
        l_template_item_context.information22 := p_information22;
      END IF;
      IF (NVL(l_template_item_context.information23,hr_api.g_varchar2) = NVL(l_template_item.information23,hr_api.g_varchar2)) THEN
        l_template_item_context.information23 := p_information23;
      END IF;
      IF (NVL(l_template_item_context.information24,hr_api.g_varchar2) = NVL(l_template_item.information24,hr_api.g_varchar2)) THEN
        l_template_item_context.information24 := p_information24;
      END IF;
      IF (NVL(l_template_item_context.information25,hr_api.g_varchar2) = NVL(l_template_item.information25,hr_api.g_varchar2)) THEN
        l_template_item_context.information25 := p_information25;
      END IF;
      IF (NVL(l_template_item_context.information26,hr_api.g_varchar2) = NVL(l_template_item.information26,hr_api.g_varchar2)) THEN
        l_template_item_context.information26 := p_information26;
      END IF;
      IF (NVL(l_template_item_context.information27,hr_api.g_varchar2) = NVL(l_template_item.information27,hr_api.g_varchar2)) THEN
        l_template_item_context.information27 := p_information27;
      END IF;
      IF (NVL(l_template_item_context.information28,hr_api.g_varchar2) = NVL(l_template_item.information28,hr_api.g_varchar2)) THEN
        l_template_item_context.information28 := p_information28;
      END IF;
      IF (NVL(l_template_item_context.information29,hr_api.g_varchar2) = NVL(l_template_item.information29,hr_api.g_varchar2)) THEN
        l_template_item_context.information29 := p_information29;
      END IF;
      IF (NVL(l_template_item_context.information30,hr_api.g_varchar2) = NVL(l_template_item.information30,hr_api.g_varchar2)) THEN
        l_template_item_context.information30 := p_information30;
      END IF;
    END IF;
    --
    -- Update template item context
    --
    hr_template_item_contexts_api.update_template_item_context
      (p_effective_date               => p_effective_date
      ,p_language_code                => p_language_code
      ,p_template_item_context_id     => l_template_item_context.template_item_context_id
      ,p_object_version_number        => l_template_item_context.object_version_number
      ,p_alignment                    => l_template_item_context.alignment
      ,p_bevel                        => l_template_item_context.bevel
      ,p_case_restriction             => l_template_item_context.case_restriction
      ,p_default_value                => l_template_item_context.default_value
      ,p_enabled                      => l_template_item_context.enabled
      ,p_format_mask                  => l_template_item_context.format_mask
      ,p_height                       => l_template_item_context.height
      ,p_information_formula_id       => l_template_item_context.information_formula_id
      ,p_information_param_item_id1   => l_template_item_context.information_parameter_item_id1
      ,p_information_param_item_id2   => l_template_item_context.information_parameter_item_id2
      ,p_information_param_item_id3   => l_template_item_context.information_parameter_item_id3
      ,p_information_param_item_id4   => l_template_item_context.information_parameter_item_id4
      ,p_information_param_item_id5   => l_template_item_context.information_parameter_item_id5
      ,p_information_prompt           => l_template_item_context.information_prompt
      ,p_insert_allowed               => l_template_item_context.insert_allowed
      ,p_label                        => l_template_item_context.label
      ,p_next_navigation_item_id      => l_template_item_context.next_navigation_item_id
      ,p_previous_navigation_item_id  => l_template_item_context.previous_navigation_item_id
      ,p_prompt_text                  => l_template_item_context.prompt_text
      ,p_prompt_alignment_offset      => l_template_item_context.prompt_alignment_offset
      ,p_prompt_display_style         => l_template_item_context.prompt_display_style
      ,p_prompt_edge                  => l_template_item_context.prompt_edge
      ,p_prompt_edge_alignment        => l_template_item_context.prompt_edge_alignment
      ,p_prompt_edge_offset           => l_template_item_context.prompt_edge_offset
      ,p_prompt_text_alignment        => l_template_item_context.prompt_text_alignment
      ,p_query_allowed                => l_template_item_context.query_allowed
      ,p_required                     => l_template_item_context.required
      ,p_tooltip_text                 => l_template_item_context.tooltip_text
      ,p_update_allowed               => l_template_item_context.update_allowed
      ,p_validation_formula_id        => l_template_item_context.validation_formula_id
      ,p_validation_param_item_id1    => l_template_item_context.validation_parameter_item_id1
      ,p_validation_param_item_id2    => l_template_item_context.validation_parameter_item_id2
      ,p_validation_param_item_id3    => l_template_item_context.validation_parameter_item_id3
      ,p_validation_param_item_id4    => l_template_item_context.validation_parameter_item_id4
      ,p_validation_param_item_id5    => l_template_item_context.validation_parameter_item_id5
      ,p_visible                      => l_template_item_context.visible
      ,p_width                        => l_template_item_context.width
      ,p_x_position                   => l_template_item_context.x_position
      ,p_y_position                   => l_template_item_context.y_position
      ,p_information_category         => l_template_item_context.information_category
      ,p_information1                 => l_template_item_context.information1
      ,p_information2                 => l_template_item_context.information2
      ,p_information3                 => l_template_item_context.information3
      ,p_information4                 => l_template_item_context.information4
      ,p_information5                 => l_template_item_context.information5
      ,p_information6                 => l_template_item_context.information6
      ,p_information7                 => l_template_item_context.information7
      ,p_information8                 => l_template_item_context.information8
      ,p_information9                 => l_template_item_context.information9
      ,p_information10                => l_template_item_context.information10
      ,p_information11                => l_template_item_context.information11
      ,p_information12                => l_template_item_context.information12
      ,p_information13                => l_template_item_context.information13
      ,p_information14                => l_template_item_context.information14
      ,p_information15                => l_template_item_context.information15
      ,p_information16                => l_template_item_context.information16
      ,p_information17                => l_template_item_context.information17
      ,p_information18                => l_template_item_context.information18
      ,p_information19                => l_template_item_context.information19
      ,p_information20                => l_template_item_context.information20
      ,p_information21                => l_template_item_context.information21
      ,p_information22                => l_template_item_context.information22
      ,p_information23                => l_template_item_context.information23
      ,p_information24                => l_template_item_context.information24
      ,p_information25                => l_template_item_context.information25
      ,p_information26                => l_template_item_context.information26
      ,p_information27                => l_template_item_context.information27
      ,p_information28                => l_template_item_context.information28
      ,p_information29                => l_template_item_context.information29
      ,p_information30                => l_template_item_context.information30
      ,p_override_value_warning       => l_warning
      );
    --
  END LOOP;
  --
  hr_utility.set_location('Leaving:'||l_proc,1000);
--
END update_template_item_contexts;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< copy_template_item >--------------------------|
-- ----------------------------------------------------------------------------
procedure copy_template_item
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_language_code                in     varchar2 default hr_api.userenv_lang
  ,p_template_item_id_from        in     number
  ,p_form_template_id             in     number
  ,p_template_item_id_to             out nocopy number
  ,p_object_version_number           out nocopy number
  )
is
  --
  -- Declare cursors and local variables
  --
  CURSOR cur_form_item
  IS
  SELECT tit.form_item_id
  FROM hr_template_items tit
  WHERE tit.template_item_id = p_template_item_id_from;
  --
  CURSOR cur_tab_page
  IS
  SELECT ttp2.template_tab_page_id
  FROM hr_template_tab_pages ttp2
  ,hr_template_canvases tcn
  ,hr_template_windows twn
  ,hr_template_tab_pages ttp1
  ,hr_template_item_tab_pages tip
  WHERE ttp2.form_tab_page_id = ttp1.form_tab_page_id
  AND ttp2.template_canvas_id = tcn.template_canvas_id
  AND tcn.template_window_id = twn.template_window_id
  AND twn.form_template_id = p_form_template_id
  AND ttp1.template_tab_page_id = tip.template_tab_page_id
  AND tip.template_item_id = p_template_item_id_from;
  --
  CURSOR cur_item_context
  IS
  SELECT tic.template_item_context_id
  FROM hr_template_item_contexts tic
  WHERE tic.template_item_id = p_template_item_id_from;
  --
  l_temp number;
  --
  CURSOR cur_api_val
  IS
  SELECT source_form_template_id
  FROM hr_source_form_templates hsf
  WHERE hsf.form_template_id_to = p_form_template_id;
  --
  -- dummy local vars
  --
  l_item_property_id             number;
  l_template_item_tab_page_id    number;
  l_ovn_item                     number;
  l_template_item_context_id_to  number;
  l_ovn_item_context             number;
  l_item_context_id              number;
  l_concatenated_segments        varchar2(2000);
  --
  l_form_item_id                 number;
  l_proc                         varchar2(72) := g_package||'copy_template_item';
  l_template_item_id_to          number;
  l_object_version_number        number;
  l_override_value_warning       boolean;
  l_language_code                fnd_languages.language_code%TYPE;
--
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint copy_template_item;
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
  --
  -- Call Before Process User Hook
  --
  begin
    hr_template_items_api_bk1.copy_template_item_b
      (p_effective_date               => TRUNC(p_effective_date)
      ,p_language_code                => l_language_code
      ,p_template_item_id_from        => p_template_item_id_from
      ,p_form_template_id             => p_form_template_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'copy_template_item'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  hr_utility.set_location('Entering:'|| l_proc, 15);

     OPEN cur_api_val;
     FETCH cur_api_val INTO l_temp;
     IF (cur_api_val%NOTFOUND AND
         hr_form_templates_api.g_session_mode <> 'SEED_DATA') THEN
         CLOSE cur_api_val;
       -- error message
       fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
       fnd_message.set_token('PROCEDURE', l_proc);
       fnd_message.set_token('STEP','10');
       fnd_message.raise_error;
     END IF;
     CLOSE cur_api_val;
  --
  --
  -- Process Logic
  --

  hr_utility.set_location('Entering:'|| l_proc, 20);

  OPEN cur_form_item;
  FETCH cur_form_item INTO l_form_item_id;
  CLOSE cur_form_item;

  hr_utility.set_location('Entering:'|| l_proc, 25);

  hr_tim_ins.ins( p_form_template_id             => p_form_template_id
            ,p_form_item_id                 => l_form_item_id
            ,p_template_item_id             => l_template_item_id_to
            ,p_object_version_number        => l_object_version_number);

  hr_utility.set_location('Entering:'|| l_proc, 30);

  hr_item_properties_bsi.copy_item_property(
            p_effective_date                => TRUNC(p_effective_date)
            ,p_language_code                => l_language_code
            ,p_template_item_id_from        => p_template_item_id_from
            ,p_template_item_id_to          => l_template_item_id_to
            ,p_item_property_id             => l_item_property_id
            ,p_object_version_number        => l_object_version_number);
            --,p_override_value_warning       => l_override_value_warning);

  hr_utility.set_location('Entering:'|| l_proc, 35);

  FOR cur_rec in cur_tab_page LOOP

    hr_template_item_tab_pages_api.create_template_item_tab_page(
                p_effective_date                => TRUNC(p_effective_date)
               ,p_template_item_id             => l_template_item_id_to
               ,p_template_tab_page_id         => cur_rec.template_tab_page_id
               ,p_template_item_tab_page_id    => l_template_item_tab_page_id
               ,p_object_version_number        => l_ovn_item);
  END LOOP;

  hr_utility.set_location('Entering:'|| l_proc, 40);

  FOR cur_rec in cur_item_context LOOP
    hr_template_item_contexts_api.copy_template_item_context(
              p_effective_date                => TRUNC(p_effective_date)
             ,p_language_code                => l_language_code
             ,p_template_item_context_id_frm => cur_rec.template_item_context_id
             ,p_template_item_id             => l_template_item_id_to
             ,p_template_item_context_id_to  => l_template_item_context_id_to
             ,p_object_version_number        => l_ovn_item_context
             ,p_item_context_id              => l_item_context_id
             ,p_concatenated_segments        => l_concatenated_segments);
  END LOOP;

  hr_utility.set_location('Entering:'|| l_proc, 45);

  --
  -- Call After Process User Hook
  --
  begin
    hr_template_items_api_bk1.copy_template_item_a
      (p_effective_date                => TRUNC(p_effective_date)
       ,p_language_code                => l_language_code
       ,p_template_item_id_from        => p_template_item_id_from
       ,p_form_template_id             => p_form_template_id
       ,p_template_item_id_to          => l_template_item_id_to
       ,p_object_version_number        => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'copy_template_item'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  hr_utility.set_location('Entering:'|| l_proc, 50);

  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_template_item_id_to          := l_template_item_id_to;
  p_object_version_number        := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to copy_template_item;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_template_item_id_to          := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_template_item_id_to          := null;
    p_object_version_number  := null;

    rollback to copy_template_item;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end copy_template_item;
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_template_item >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_template_item
  (p_validate                        in boolean  default false
  ,p_effective_date                  in date
  ,p_language_code                   in varchar2 default hr_api.userenv_lang
  ,p_form_template_id                in number
  ,p_form_item_id                    in number
  ,p_template_tab_page_id            in number default null
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
  ,p_template_item_id                  out nocopy number
  ,p_object_version_number             out nocopy number
  ,p_override_value_warning            out nocopy boolean
  ) is
  --
  -- Declare cursors and local variables
  --

  l_required_override number := null;
  l_visible_override number := null;

  CURSOR cur_override
  IS
  SELECT required_override
        ,visible_override
  FROM hr_form_items_b
  WHERE form_item_id = p_form_item_id;

  l_temp number;

  CURSOR cur_api_val
  IS
  SELECT source_form_template_id
  FROM hr_source_form_templates hsf
  WHERE hsf.form_template_id_to = p_form_template_id;

  l_proc                varchar2(72) := g_package||'create_template_item';
  l_object_version_number number;
  l_template_item_id number;
  l_override_value_warning boolean := FALSE;
  l_item_property_id number;
  l_template_item_tab_page_id number;
  l_ovn_tab number;
  l_language_code fnd_languages.language_code%TYPE;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_template_item;
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
  --
  -- Call Before Process User Hook
  --
  begin
    hr_template_items_api_bk2.create_template_item_b
      (p_effective_date                 => TRUNC(p_effective_date)
      ,p_language_code                  => l_language_code
      ,p_form_template_id               => p_form_template_id
      ,p_form_item_id                   => p_form_item_id
      ,p_template_tab_page_id           => p_template_tab_page_id
      ,p_alignment                      => p_alignment
      ,p_bevel                          => p_bevel
      ,p_case_restriction               => p_case_restriction
      ,p_default_value                  => p_default_value
      ,p_enabled                        => p_enabled
      ,p_format_mask                    => p_format_mask
      ,p_height                         => p_height
      ,p_information_formula_id         => p_information_formula_id
      ,p_information_param_item_id1     => p_information_param_item_id1
      ,p_information_param_item_id2     => p_information_param_item_id2
      ,p_information_param_item_id3     => p_information_param_item_id3
      ,p_information_param_item_id4     => p_information_param_item_id4
      ,p_information_param_item_id5     => p_information_param_item_id5
      ,p_information_prompt             => p_information_prompt
      ,p_insert_allowed                 => p_insert_allowed
      ,p_label                          => p_label
      ,p_prompt_text                    => p_prompt_text
      ,p_prompt_alignment_offset        => p_prompt_alignment_offset
      ,p_prompt_display_style           => p_prompt_display_style
      ,p_prompt_edge                    => p_prompt_edge
      ,p_prompt_edge_alignment          => p_prompt_edge_alignment
      ,p_prompt_edge_offset             => p_prompt_edge_offset
      ,p_prompt_text_alignment          => p_prompt_text_alignment
      ,p_query_allowed                  => p_query_allowed
      ,p_required                       => p_required
      ,p_tooltip_text                   => p_tooltip_text
      ,p_update_allowed                 => p_update_allowed
      ,p_validation_formula_id          => p_validation_formula_id
      ,p_validation_param_item_id1      => p_validation_param_item_id1
      ,p_validation_param_item_id2      => p_validation_param_item_id2
      ,p_validation_param_item_id3      => p_validation_param_item_id3
      ,p_validation_param_item_id4      => p_validation_param_item_id4
      ,p_validation_param_item_id5      => p_validation_param_item_id5
      ,p_visible                        => p_visible
      ,p_width                          => p_width
      ,p_x_position                     => p_x_position
      ,p_y_position                     => p_y_position
      ,p_information_category           => p_information_category
      ,p_information1                   => p_information1
      ,p_information2                   => p_information2
      ,p_information3                   => p_information3
      ,p_information4                   => p_information4
      ,p_information5                   => p_information5
      ,p_information6                   => p_information6
      ,p_information7                   => p_information7
      ,p_information8                   => p_information8
      ,p_information9                   => p_information9
      ,p_information10                  => p_information10
      ,p_information11                  => p_information11
      ,p_information12                  => p_information12
      ,p_information13                  => p_information13
      ,p_information14                  => p_information14
      ,p_information15                  => p_information15
      ,p_information16                  => p_information16
      ,p_information17                  => p_information17
      ,p_information18                  => p_information18
      ,p_information19                  => p_information19
      ,p_information20                  => p_information20
      ,p_information21                  => p_information21
      ,p_information22                  => p_information22
      ,p_information23                  => p_information23
      ,p_information24                  => p_information24
      ,p_information25                  => p_information25
      ,p_information26                  => p_information26
      ,p_information27                  => p_information27
      ,p_information28                  => p_information28
      ,p_information29                  => p_information29
      ,p_information30                  => p_information30
      ,p_next_navigation_item_id        => p_next_navigation_item_id
      ,p_previous_navigation_item_id    => p_previous_navigation_item_id);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_template_item'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --

  hr_utility.set_location('Entering:'|| l_proc, 15);

     OPEN cur_override;
     FETCH cur_override INTO l_required_override,l_visible_override;
     CLOSE cur_override;

  hr_utility.set_location('Entering:'|| l_proc, 20);

     IF ( p_required <> hr_api.g_number ) AND
        ( l_required_override is not null AND p_required is not null ) THEN
       l_override_value_warning  := TRUE;
     END IF;

  hr_utility.set_location('Entering:'|| l_proc, 25);

     IF ( p_visible <> hr_api.g_number ) AND
       ( l_visible_override is not null AND p_visible is not null ) THEN
       l_override_value_warning  := TRUE;
     END IF;

  hr_utility.set_location('Entering:'|| l_proc, 30);

     OPEN cur_api_val;
     FETCH cur_api_val INTO l_temp;
     IF (cur_api_val%NOTFOUND AND
         hr_form_templates_api.g_session_mode <> 'SEED_DATA') THEN
         CLOSE cur_api_val;
       -- error message
       fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
       fnd_message.set_token('PROCEDURE', l_proc);
       fnd_message.set_token('STEP','10');
       fnd_message.raise_error;
     END IF;
     CLOSE cur_api_val;

  hr_utility.set_location('Entering:'|| l_proc, 35);

  --
  --
  -- Process Logic
  --
  hr_tim_ins.ins( p_form_template_id             => p_form_template_id
            ,p_form_item_id                 => p_form_item_id
            ,p_template_item_id             => l_template_item_id
            ,p_object_version_number        => l_object_version_number);

  hr_utility.set_location('Entering:'|| l_proc, 40);

  hr_item_properties_bsi.copy_item_property(
             p_effective_date               => TRUNC(p_effective_date)
            ,p_language_code                => l_language_code
            ,p_form_item_id                 => p_form_item_id
            ,p_template_item_id             => l_template_item_id
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

  hr_utility.set_location('Entering:'|| l_proc, 45);

  IF p_template_tab_page_id is not null THEN
    hr_template_item_tab_pages_api.create_template_item_tab_page(
               p_effective_date                => TRUNC(p_effective_date)
               ,p_template_item_id             => l_template_item_id
               ,p_template_tab_page_id         => p_template_tab_page_id
               ,p_template_item_tab_page_id    => l_template_item_tab_page_id
               ,p_object_version_number        => l_ovn_tab);
  END IF;

  hr_utility.set_location('Entering:'|| l_proc, 50);

  --
  -- Call After Process User Hook
  --
  begin
    hr_template_items_api_bk2.create_template_item_a
      (p_effective_date                 => TRUNC(p_effective_date)
      ,p_language_code                  => l_language_code
      ,p_form_template_id               => p_form_template_id
      ,p_form_item_id                   => p_form_item_id
      ,p_template_tab_page_id           => p_template_tab_page_id
      ,p_alignment                      => p_alignment
      ,p_bevel                          => p_bevel
      ,p_case_restriction               => p_case_restriction
      ,p_default_value                  => p_default_value
      ,p_enabled                        => p_enabled
      ,p_format_mask                    => p_format_mask
      ,p_height                         => p_height
      ,p_information_formula_id         => p_information_formula_id
      ,p_information_param_item_id1     => p_information_param_item_id1
      ,p_information_param_item_id2     => p_information_param_item_id2
      ,p_information_param_item_id3     => p_information_param_item_id3
      ,p_information_param_item_id4     => p_information_param_item_id4
      ,p_information_param_item_id5     => p_information_param_item_id5
      ,p_information_prompt             => p_information_prompt
      ,p_insert_allowed                 => p_insert_allowed
      ,p_label                          => p_label
      ,p_prompt_text                    => p_prompt_text
      ,p_prompt_alignment_offset        => p_prompt_alignment_offset
      ,p_prompt_display_style           => p_prompt_display_style
      ,p_prompt_edge                    => p_prompt_edge
      ,p_prompt_edge_alignment          => p_prompt_edge_alignment
      ,p_prompt_edge_offset             => p_prompt_edge_offset
      ,p_prompt_text_alignment          => p_prompt_text_alignment
      ,p_query_allowed                  => p_query_allowed
      ,p_required                       => p_required
      ,p_tooltip_text                   => p_tooltip_text
      ,p_update_allowed                 => p_update_allowed
      ,p_validation_formula_id          => p_validation_formula_id
      ,p_validation_param_item_id1      => p_validation_param_item_id1
      ,p_validation_param_item_id2      => p_validation_param_item_id2
      ,p_validation_param_item_id3      => p_validation_param_item_id3
      ,p_validation_param_item_id4      => p_validation_param_item_id4
      ,p_validation_param_item_id5      => p_validation_param_item_id5
      ,p_visible                        => p_visible
      ,p_width                          => p_width
      ,p_x_position                     => p_x_position
      ,p_y_position                     => p_y_position
      ,p_information_category           => p_information_category
      ,p_information1                   => p_information1
      ,p_information2                   => p_information2
      ,p_information3                   => p_information3
      ,p_information4                   => p_information4
      ,p_information5                   => p_information5
      ,p_information6                   => p_information6
      ,p_information7                   => p_information7
      ,p_information8                   => p_information8
      ,p_information9                   => p_information9
      ,p_information10                  => p_information10
      ,p_information11                  => p_information11
      ,p_information12                  => p_information12
      ,p_information13                  => p_information13
      ,p_information14                  => p_information14
      ,p_information15                  => p_information15
      ,p_information16                  => p_information16
      ,p_information17                  => p_information17
      ,p_information18                  => p_information18
      ,p_information19                  => p_information19
      ,p_information20                  => p_information20
      ,p_information21                  => p_information21
      ,p_information22                  => p_information22
      ,p_information23                  => p_information23
      ,p_information24                  => p_information24
      ,p_information25                  => p_information25
      ,p_information26                  => p_information26
      ,p_information27                  => p_information27
      ,p_information28                  => p_information28
      ,p_information29                  => p_information29
      ,p_information30                  => p_information30
      ,p_next_navigation_item_id        => p_next_navigation_item_id
      ,p_previous_navigation_item_id    => p_previous_navigation_item_id
      ,p_template_item_id             => l_template_item_id
      ,p_object_version_number        => l_object_version_number
      ,p_override_value_warning       => l_override_value_warning);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_template_item'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  hr_utility.set_location('Entering:'|| l_proc, 55);

  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_template_item_id             := l_template_item_id;
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
    rollback to create_template_item;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_template_item_id             := null;
    p_override_value_warning       := FALSE;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_template_item_id             := null;
    p_override_value_warning       := null;
    p_object_version_number        := null;

    rollback to create_template_item;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_template_item;
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_template_item >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_template_item
  (p_validate                      in     boolean  default false
   ,p_template_item_id             in    number
   ,p_object_version_number        in    number
   ,p_delete_children_flag         in    varchar2 default 'N'
  ) is
  --
  -- Declare cursors and local variables
  --
  CURSOR cur_item_context
  IS
  SELECT template_item_context_id
  ,object_version_number
  FROM hr_template_item_contexts
  WHERE template_item_id = p_template_item_id;

  CURSOR cur_tab_page
  IS
  SELECT template_item_tab_page_id
  ,object_version_number
  FROM hr_template_item_tab_pages
  WHERE template_item_id = p_template_item_id;

  l_temp number;

  CURSOR cur_api_val
  IS
  SELECT source_form_template_id
  FROM hr_source_form_templates hsf
       ,hr_template_items_b hti
  WHERE hsf.form_template_id_to = hti.form_template_id
  AND hti.template_item_id = p_template_item_id;

---- Fix For Bug 6631115 Starts ------

  CURSOR cur_template_item
  IS
  SELECT template_item_id
  ,object_version_number
  FROM hr_template_items_b
  WHERE template_item_id = p_template_item_id;

l_template_item_id number;
l_object_version_number number;

---- Fix For Bug 6631115 Ends ---------

  l_proc                varchar2(72) := g_package||'delete_template_item';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_template_item;

  --
  -- Call Before Process User Hook
  --
  begin
    hr_template_items_api_bk3.delete_template_item_b
      (p_template_item_id   => p_template_item_id
       ,p_object_version_number => p_object_version_number
       ,p_delete_children_flag  => p_delete_children_flag
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_template_item'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  hr_utility.set_location('Entering:'|| l_proc, 15);

     OPEN cur_api_val;
     FETCH cur_api_val INTO l_temp;
     IF (cur_api_val%NOTFOUND AND
         hr_form_templates_api.g_session_mode <> 'SEED_DATA') THEN
         CLOSE cur_api_val;
       -- error message
       fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
       fnd_message.set_token('PROCEDURE', l_proc);
       fnd_message.set_token('STEP','10');
       fnd_message.raise_error;
     END IF;
     CLOSE cur_api_val;
  --
  --
  -- Process Logic
  --
  hr_utility.set_location('Entering:'|| l_proc, 15);

  IF p_delete_children_flag = 'Y' THEN
    FOR cur_rec IN cur_item_context LOOP
      hr_template_item_contexts_api.delete_template_item_context(
              p_template_item_context_id     => cur_rec.template_item_context_id
              ,p_object_version_number        => cur_rec.object_version_number);
              --,p_delete_children_flag         => p_delete_children_flag);
    END LOOP;
  END IF;

  hr_utility.set_location('Entering:'|| l_proc, 30);

  FOR cur_rec IN cur_tab_page LOOP
    hr_template_item_tab_pages_api.delete_template_item_tab_page(
             p_template_item_tab_page_id    => cur_rec.template_item_tab_page_id
             ,p_object_version_number        => cur_rec.object_version_number);
  END LOOP;

  hr_utility.set_location('Entering:'|| l_proc, 35);

  hr_item_properties_bsi.delete_item_property
            (p_template_item_id             => p_template_item_id
            ,p_object_version_number        => p_object_version_number);

  hr_utility.set_location('Entering:'|| l_proc, 40);

---- Fix For Bug 6631115 Starts -----

  open cur_template_item;
  fetch cur_template_item into  l_template_item_id,l_object_version_number;
  if cur_template_item%found then
  hr_tim_del.del( p_template_item_id             => p_template_item_id
                 ,p_object_version_number        => l_object_version_number); -- Changed from p_object_version_number
  end if;
  close cur_template_item;

---- Fix For Bug 6631115 Ends -------

  hr_utility.set_location('Entering:'|| l_proc, 45);

  --
  -- Call After Process User Hook
  --
  begin
    hr_template_items_api_bk3.delete_template_item_a
      (p_template_item_id   => p_template_item_id
       ,p_object_version_number => p_object_version_number
       ,p_delete_children_flag  => p_delete_children_flag
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_template_item'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  hr_utility.set_location('Entering:'|| l_proc, 50);

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
    rollback to delete_template_item;
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
    rollback to delete_template_item;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_template_item;
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_template_item >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_template_item
  (p_validate                        in boolean  default false
  ,p_effective_date                  in date
  ,p_language_code                   in varchar2 default hr_api.userenv_lang
  ,p_template_item_id                in number
  ,p_object_version_number           in out nocopy number
  ,p_upd_template_item_contexts      in boolean default false
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
  ,p_override_value_warning            out nocopy boolean
  ) is
  --
  -- Declare cursors and local variables
  --

  l_required_override number := null;
  l_form_tab_page_id_override number := null;
  l_visible_override number := null;

  CURSOR cur_override
  IS
  SELECT required_override
        ,visible_override
  FROM hr_form_items_b hfi
       ,hr_template_items_b hti
  WHERE hfi.form_item_id = hti.form_item_id
  AND hti.template_item_id = p_template_item_id;

  l_temp number;

  CURSOR cur_api_val
  IS
  SELECT source_form_template_id
  FROM hr_source_form_templates hsf
       ,hr_template_items_b hti
  WHERE hsf.form_template_id_to = hti.form_template_id
  AND hti.template_item_id = p_template_item_id;

  l_proc                varchar2(72) := g_package||'update_template_item';
  l_object_version_number number;
  l_override_value_warning boolean := FALSE;
  l_language_code fnd_languages.language_code%TYPE;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_template_item;
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
  --
  -- Call Before Process User Hook
  --
  begin
    hr_template_items_api_bk4.update_template_item_b
      (p_effective_date                 => TRUNC(p_effective_date)
      ,p_language_code                  => l_language_code
      ,p_template_item_id               => p_template_item_id
      ,p_object_version_number          => l_object_version_number
      ,p_upd_template_item_contexts     => p_upd_template_item_contexts
      ,p_alignment                      => p_alignment
      ,p_bevel                          => p_bevel
      ,p_case_restriction               => p_case_restriction
      ,p_default_value                  => p_default_value
      ,p_enabled                        => p_enabled
      ,p_format_mask                    => p_format_mask
      ,p_height                         => p_height
      ,p_information_formula_id         => p_information_formula_id
      ,p_information_param_item_id1     => p_information_param_item_id1
      ,p_information_param_item_id2     => p_information_param_item_id2
      ,p_information_param_item_id3     => p_information_param_item_id3
      ,p_information_param_item_id4     => p_information_param_item_id4
      ,p_information_param_item_id5     => p_information_param_item_id5
      ,p_information_prompt             => p_information_prompt
      ,p_insert_allowed                 => p_insert_allowed
      ,p_label                          => p_label
      ,p_prompt_text                    => p_prompt_text
      ,p_prompt_alignment_offset        => p_prompt_alignment_offset
      ,p_prompt_display_style           => p_prompt_display_style
      ,p_prompt_edge                    => p_prompt_edge
      ,p_prompt_edge_alignment          => p_prompt_edge_alignment
      ,p_prompt_edge_offset             => p_prompt_edge_offset
      ,p_prompt_text_alignment          => p_prompt_text_alignment
      ,p_query_allowed                  => p_query_allowed
      ,p_required                       => p_required
      ,p_tooltip_text                   => p_tooltip_text
      ,p_update_allowed                 => p_update_allowed
      ,p_validation_formula_id          => p_validation_formula_id
      ,p_validation_param_item_id1      => p_validation_param_item_id1
      ,p_validation_param_item_id2      => p_validation_param_item_id2
      ,p_validation_param_item_id3      => p_validation_param_item_id3
      ,p_validation_param_item_id4      => p_validation_param_item_id4
      ,p_validation_param_item_id5      => p_validation_param_item_id5
      ,p_visible                        => p_visible
      ,p_width                          => p_width
      ,p_x_position                     => p_x_position
      ,p_y_position                     => p_y_position
      ,p_information_category           => p_information_category
      ,p_information1                   => p_information1
      ,p_information2                   => p_information2
      ,p_information3                   => p_information3
      ,p_information4                   => p_information4
      ,p_information5                   => p_information5
      ,p_information6                   => p_information6
      ,p_information7                   => p_information7
      ,p_information8                   => p_information8
      ,p_information9                   => p_information9
      ,p_information10                  => p_information10
      ,p_information11                  => p_information11
      ,p_information12                  => p_information12
      ,p_information13                  => p_information13
      ,p_information14                  => p_information14
      ,p_information15                  => p_information15
      ,p_information16                  => p_information16
      ,p_information17                  => p_information17
      ,p_information18                  => p_information18
      ,p_information19                  => p_information19
      ,p_information20                  => p_information20
      ,p_information21                  => p_information21
      ,p_information22                  => p_information22
      ,p_information23                  => p_information23
      ,p_information24                  => p_information24
      ,p_information25                  => p_information25
      ,p_information26                  => p_information26
      ,p_information27                  => p_information27
      ,p_information28                  => p_information28
      ,p_information29                  => p_information29
      ,p_information30                  => p_information30
      ,p_next_navigation_item_id        => p_next_navigation_item_id
      ,p_previous_navigation_item_id    => p_previous_navigation_item_id);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_template_item'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  hr_utility.set_location('Entering:'|| l_proc, 15);

     OPEN cur_override;
     FETCH cur_override INTO l_required_override,l_visible_override;
     CLOSE cur_override;

  hr_utility.set_location('Entering:'|| l_proc, 20);

     IF ( p_required <> hr_api.g_number ) AND
        ( l_required_override is not null AND p_required is not null ) THEN
       l_override_value_warning  := TRUE;
     END IF;

  hr_utility.set_location('Entering:'|| l_proc, 25);

     IF ( p_visible <> hr_api.g_number ) AND
       ( l_visible_override is not null AND p_visible is not null ) THEN
       l_override_value_warning  := TRUE;
     END IF;

  hr_utility.set_location('Entering:'|| l_proc, 30);

     OPEN cur_api_val;
     FETCH cur_api_val INTO l_temp;
     IF (cur_api_val%NOTFOUND AND
         hr_form_templates_api.g_session_mode <> 'SEED_DATA') THEN
         CLOSE cur_api_val;
       -- error message
       fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
       fnd_message.set_token('PROCEDURE', l_proc);
       fnd_message.set_token('STEP','10');
       fnd_message.raise_error;
     END IF;
     CLOSE cur_api_val;

  hr_utility.set_location('Entering:'|| l_proc, 35);

  --
  --
  -- Process Logic
  --
  hr_utility.set_location('Entering:'|| l_proc, 40);
  --
  if (p_upd_template_item_contexts) then
    update_template_item_contexts
      (p_effective_date               => p_effective_date
      ,p_language_code                => p_language_code
      ,p_template_item_id             => p_template_item_id
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
      ,p_next_navigation_item_id      => p_next_navigation_item_id
      ,p_previous_navigation_item_id  => p_previous_navigation_item_id
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
      );
  end if;
  --
  hr_utility.set_location('Entering:'|| l_proc, 42);
  --
  hr_item_properties_bsi.update_item_property(
              p_effective_date               => TRUNC(p_effective_date)
             ,p_language_code                => l_language_code
             ,p_object_version_number        => l_object_version_number
             ,p_template_item_id             => p_template_item_id
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
             --,p_override_value_warning       => l_override_value_warning);

  hr_utility.set_location('Entering:'|| l_proc, 45);

  --
  -- Call After Process User Hook
  --
  begin
    hr_template_items_api_bk4.update_template_item_a
      (p_effective_date                 => TRUNC(p_effective_date)
      ,p_language_code                  => l_language_code
      ,p_template_item_id               => p_template_item_id
      ,p_object_version_number          => l_object_version_number
      ,p_upd_template_item_contexts     => p_upd_template_item_contexts
      ,p_alignment                      => p_alignment
      ,p_bevel                          => p_bevel
      ,p_case_restriction               => p_case_restriction
      ,p_default_value                  => p_default_value
      ,p_enabled                        => p_enabled
      ,p_format_mask                    => p_format_mask
      ,p_height                         => p_height
      ,p_information_formula_id         => p_information_formula_id
      ,p_information_param_item_id1     => p_information_param_item_id1
      ,p_information_param_item_id2     => p_information_param_item_id2
      ,p_information_param_item_id3     => p_information_param_item_id3
      ,p_information_param_item_id4     => p_information_param_item_id4
      ,p_information_param_item_id5     => p_information_param_item_id5
      ,p_information_prompt             => p_information_prompt
      ,p_insert_allowed                 => p_insert_allowed
      ,p_label                          => p_label
      ,p_prompt_text                    => p_prompt_text
      ,p_prompt_alignment_offset        => p_prompt_alignment_offset
      ,p_prompt_display_style           => p_prompt_display_style
      ,p_prompt_edge                    => p_prompt_edge
      ,p_prompt_edge_alignment          => p_prompt_edge_alignment
      ,p_prompt_edge_offset             => p_prompt_edge_offset
      ,p_prompt_text_alignment          => p_prompt_text_alignment
      ,p_query_allowed                  => p_query_allowed
      ,p_required                       => p_required
      ,p_tooltip_text                   => p_tooltip_text
      ,p_update_allowed                 => p_update_allowed
      ,p_validation_formula_id          => p_validation_formula_id
      ,p_validation_param_item_id1      => p_validation_param_item_id1
      ,p_validation_param_item_id2      => p_validation_param_item_id2
      ,p_validation_param_item_id3      => p_validation_param_item_id3
      ,p_validation_param_item_id4      => p_validation_param_item_id4
      ,p_validation_param_item_id5      => p_validation_param_item_id5
      ,p_visible                        => p_visible
      ,p_width                          => p_width
      ,p_x_position                     => p_x_position
      ,p_y_position                     => p_y_position
      ,p_information_category           => p_information_category
      ,p_information1                   => p_information1
      ,p_information2                   => p_information2
      ,p_information3                   => p_information3
      ,p_information4                   => p_information4
      ,p_information5                   => p_information5
      ,p_information6                   => p_information6
      ,p_information7                   => p_information7
      ,p_information8                   => p_information8
      ,p_information9                   => p_information9
      ,p_information10                  => p_information10
      ,p_information11                  => p_information11
      ,p_information12                  => p_information12
      ,p_information13                  => p_information13
      ,p_information14                  => p_information14
      ,p_information15                  => p_information15
      ,p_information16                  => p_information16
      ,p_information17                  => p_information17
      ,p_information18                  => p_information18
      ,p_information19                  => p_information19
      ,p_information20                  => p_information20
      ,p_information21                  => p_information21
      ,p_information22                  => p_information22
      ,p_information23                  => p_information23
      ,p_information24                  => p_information24
      ,p_information25                  => p_information25
      ,p_information26                  => p_information26
      ,p_information27                  => p_information27
      ,p_information28                  => p_information28
      ,p_information29                  => p_information29
      ,p_information30                  => p_information30
      ,p_next_navigation_item_id        => p_next_navigation_item_id
      ,p_previous_navigation_item_id    => p_previous_navigation_item_id
      ,p_override_value_warning         => l_override_value_warning);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_template_item'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  hr_utility.set_location('Entering:'|| l_proc, 50);

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
    rollback to update_template_item;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_override_value_warning := l_override_value_warning;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_template_item;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_template_item;
--
end hr_template_items_api;

/
