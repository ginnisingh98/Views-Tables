--------------------------------------------------------
--  DDL for Package Body HR_TEMPLATE_ITEM_CONTEXTS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_TEMPLATE_ITEM_CONTEXTS_API" as
/* $Header: hrticapi.pkb 115.7 2003/10/31 06:55:09 bsubrama noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_template_item_contexts_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------< copy_template_item_context >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure copy_template_item_context
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_language_code                 in varchar2 default hr_api.userenv_lang
  ,p_template_item_context_id_frm  in number
  ,p_template_item_id              in number
  ,p_template_item_context_id_to   out nocopy number
  ,p_object_version_number         out nocopy number
  ,p_item_context_id               out nocopy number
  ,p_concatenated_segments         out nocopy varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  Type l_rec_type Is Record (
  context_type hr_template_item_contexts.context_type%TYPE
  ,segment1 hr_item_contexts.segment1%TYPE
  ,segment2 hr_item_contexts.segment2%TYPE
  ,segment3 hr_item_contexts.segment3%TYPE
  ,segment4 hr_item_contexts.segment4%TYPE
  ,segment5 hr_item_contexts.segment5%TYPE
  ,segment6 hr_item_contexts.segment6%TYPE
  ,segment7 hr_item_contexts.segment7%TYPE
  ,segment8 hr_item_contexts.segment8%TYPE
  ,segment9 hr_item_contexts.segment9%TYPE
  ,segment10 hr_item_contexts.segment10%TYPE
  ,segment11 hr_item_contexts.segment11%TYPE
  ,segment12 hr_item_contexts.segment12%TYPE
  ,segment13 hr_item_contexts.segment13%TYPE
  ,segment14 hr_item_contexts.segment14%TYPE
  ,segment15 hr_item_contexts.segment15%TYPE
  ,segment16 hr_item_contexts.segment16%TYPE
  ,segment17 hr_item_contexts.segment17%TYPE
  ,segment18 hr_item_contexts.segment18%TYPE
  ,segment19 hr_item_contexts.segment19%TYPE
  ,segment20 hr_item_contexts.segment20%TYPE
  ,segment21 hr_item_contexts.segment21%TYPE
  ,segment22 hr_item_contexts.segment22%TYPE
  ,segment23 hr_item_contexts.segment23%TYPE
  ,segment24 hr_item_contexts.segment24%TYPE
  ,segment25 hr_item_contexts.segment25%TYPE
  ,segment26 hr_item_contexts.segment26%TYPE
  ,segment27 hr_item_contexts.segment27%TYPE
  ,segment28 hr_item_contexts.segment28%TYPE
  ,segment29 hr_item_contexts.segment29%TYPE
  ,segment30 hr_item_contexts.segment30%TYPE);

  l_rec l_rec_type;

  CURSOR cur_item_contexts
  IS
  SELECT tic.context_type
  ,icx.segment1
  ,icx.segment2
  ,icx.segment3
  ,icx.segment4
  ,icx.segment5
  ,icx.segment6
  ,icx.segment7
  ,icx.segment8
  ,icx.segment9
  ,icx.segment10
  ,icx.segment11
  ,icx.segment12
  ,icx.segment13
  ,icx.segment14
  ,icx.segment15
  ,icx.segment16
  ,icx.segment17
  ,icx.segment18
  ,icx.segment19
  ,icx.segment20
  ,icx.segment21
  ,icx.segment22
  ,icx.segment23
  ,icx.segment24
  ,icx.segment25
  ,icx.segment26
  ,icx.segment27
  ,icx.segment28
  ,icx.segment29
  ,icx.segment30
  FROM hr_item_contexts icx
  ,hr_template_item_contexts tic
  WHERE icx.item_context_id = tic.item_context_id
  AND tic.template_item_context_id = p_template_item_context_id_frm;

  CURSOR cur_tmplt_tab
  IS
  SELECT ttp2.template_tab_page_id
  FROM hr_template_tab_pages ttp2
  ,hr_template_canvases tcn
  ,hr_template_windows twn
  ,hr_template_items tit
  ,hr_template_tab_pages ttp1
  ,hr_template_item_context_pages tcp
  WHERE ttp2.form_tab_page_id = ttp1.form_tab_page_id
  AND ttp2.template_canvas_id = tcn.template_canvas_id
  AND tcn.template_window_id = twn.template_window_id
  AND twn.form_template_id = tit.form_template_id
  AND tit.template_item_id = p_template_item_id
  AND ttp1.template_tab_page_id = tcp.template_tab_page_id
  AND tcp.template_item_context_id = p_template_item_context_id_frm;

  l_temp number;

  CURSOR cur_api_val
  IS
  SELECT source_form_template_id
  FROM hr_source_form_templates hsf
       ,hr_template_items_b hti
  WHERE hsf.form_template_id_to = hti.form_template_id
  AND hti.template_item_id = p_template_item_id;

  l_override_value_warning boolean;
  l_tic_id number;
  l_ovn_item number;
  l_item_property_id number;
  l_template_item_context_id_to   number;
  l_object_version_number         number;
  l_item_context_id               number;
  l_concatenated_segments         varchar2(2000);
  l_language_code fnd_languages.language_code%TYPE;

  l_proc                varchar2(72) := g_package||'copy_template_item_context';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint copy_template_item_context;
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
    hr_template_item_contexts_bk1.copy_template_item_context_b
      (p_effective_date                => TRUNC(p_effective_date)
       ,p_language_code                => l_language_code
       ,p_template_item_context_id_frm => p_template_item_context_id_frm
       ,p_template_item_id             => p_template_item_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'copy_template_item_context'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
     hr_utility.set_location('At:'|| l_proc, 15);

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
  hr_utility.set_location('At:'|| l_proc, 20);

  OPEN cur_item_contexts;
  FETCH cur_item_contexts INTO l_rec;
  CLOSE cur_item_contexts;

  hr_utility.set_location('At:'|| l_proc, 25);

  hr_icx_ins.ins_or_sel(
             p_context_type                 => l_rec.context_type
             ,p_segment1                     => l_rec.segment1
             ,p_segment2                     => l_rec.segment2
             ,p_segment3                     => l_rec.segment3
             ,p_segment4                     => l_rec.segment4
             ,p_segment5                     => l_rec.segment5
             ,p_segment6                     => l_rec.segment6
             ,p_segment7                     => l_rec.segment7
             ,p_segment8                     => l_rec.segment8
             ,p_segment9                     => l_rec.segment9
             ,p_segment10                    => l_rec.segment10
             ,p_segment11                    => l_rec.segment11
             ,p_segment12                    => l_rec.segment12
             ,p_segment13                    => l_rec.segment13
             ,p_segment14                    => l_rec.segment14
             ,p_segment15                    => l_rec.segment15
             ,p_segment16                    => l_rec.segment16
             ,p_segment17                    => l_rec.segment17
             ,p_segment18                    => l_rec.segment18
             ,p_segment19                    => l_rec.segment19
             ,p_segment20                    => l_rec.segment20
             ,p_segment21                    => l_rec.segment21
             ,p_segment22                    => l_rec.segment22
             ,p_segment23                    => l_rec.segment23
             ,p_segment24                    => l_rec.segment24
             ,p_segment25                    => l_rec.segment25
             ,p_segment26                    => l_rec.segment26
             ,p_segment27                    => l_rec.segment27
             ,p_segment28                    => l_rec.segment28
             ,p_segment29                    => l_rec.segment29
             ,p_segment30                    => l_rec.segment30
             ,p_item_context_id              => l_item_context_id
             ,p_concatenated_segments        => l_concatenated_segments);

  hr_utility.set_location('At:'|| l_proc, 30);

  hr_tic_ins.ins( p_template_item_id             => p_template_item_id
             ,p_context_type                 => l_rec.context_type
             ,p_item_context_id              => l_item_context_id
             ,p_template_item_context_id     => l_template_item_context_id_to
             ,p_object_version_number        => l_object_version_number);

  hr_utility.set_location('At:'|| l_proc, 35);

  hr_item_properties_bsi.copy_item_property(
             p_effective_date               => TRUNC(p_effective_date)
             ,p_language_code                => l_language_code
             ,p_template_item_context_id_frm => p_template_item_context_id_frm
             ,p_template_item_context_id_to  => l_template_item_context_id_to
             ,p_item_property_id             => l_item_property_id
             ,p_object_version_number        => l_object_version_number);
             --,p_override_value_warning       => l_override_value_warning);

  hr_utility.set_location('At:'|| l_proc, 40);

  FOR cur_rec IN cur_tmplt_tab LOOP
    hr_tcp_api.create_tcp
            (p_effective_date                => TRUNC(p_effective_date)
             ,p_template_item_context_id      => l_template_item_context_id_to
             ,p_template_tab_page_id         => cur_rec.template_tab_page_id
             ,p_template_item_context_page_i => l_tic_id
             ,p_object_version_number        => l_ovn_item);
  END LOOP;

  hr_utility.set_location('At:'|| l_proc, 45);

  --
  -- Call After Process User Hook
  --
  begin
    hr_template_item_contexts_bk1.copy_template_item_context_a
      (p_effective_date                => TRUNC(p_effective_date)
       ,p_language_code                => l_language_code
       ,p_template_item_context_id_frm => p_template_item_context_id_frm
       ,p_template_item_id             => p_template_item_id
       ,p_template_item_context_id_to  => l_template_item_context_id_to
       ,p_object_version_number        => l_object_version_number
       ,p_item_context_id              => l_item_context_id
       ,p_concatenated_segments        => l_concatenated_segments
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'copy_template_item_context'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  hr_utility.set_location('At:'|| l_proc, 50);

  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_template_item_context_id_to  := l_template_item_context_id_to;
  p_object_version_number        := l_object_version_number;
  p_item_context_id              := l_item_context_id;
  p_concatenated_segments        := l_concatenated_segments;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to copy_template_item_context;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_template_item_context_id_to  := null;
    p_object_version_number        := null;
    p_item_context_id              := null;
    p_concatenated_segments        := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_template_item_context_id_to  := null;
    p_object_version_number        := null;
    p_item_context_id              := null;
    p_concatenated_segments        := null;

    rollback to copy_template_item_context;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end copy_template_item_context;
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_template_item_context >--------------------|
-- ----------------------------------------------------------------------------
--
procedure create_template_item_context
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_language_code                in varchar2 default hr_api.userenv_lang
  ,p_template_item_id             in number
  ,p_context_type                 in varchar2
  ,p_segment1                     in varchar2 default null
  ,p_segment2                     in varchar2 default null
  ,p_segment3                     in varchar2 default null
  ,p_segment4                     in varchar2 default null
  ,p_segment5                     in varchar2 default null
  ,p_segment6                     in varchar2 default null
  ,p_segment7                     in varchar2 default null
  ,p_segment8                     in varchar2 default null
  ,p_segment9                     in varchar2 default null
  ,p_segment10                    in varchar2 default null
  ,p_segment11                    in varchar2 default null
  ,p_segment12                    in varchar2 default null
  ,p_segment13                    in varchar2 default null
  ,p_segment14                    in varchar2 default null
  ,p_segment15                    in varchar2 default null
  ,p_segment16                    in varchar2 default null
  ,p_segment17                    in varchar2 default null
  ,p_segment18                    in varchar2 default null
  ,p_segment19                    in varchar2 default null
  ,p_segment20                    in varchar2 default null
  ,p_segment21                    in varchar2 default null
  ,p_segment22                    in varchar2 default null
  ,p_segment23                    in varchar2 default null
  ,p_segment24                    in varchar2 default null
  ,p_segment25                    in varchar2 default null
  ,p_segment26                    in varchar2 default null
  ,p_segment27                    in varchar2 default null
  ,p_segment28                    in varchar2 default null
  ,p_segment29                    in varchar2 default null
  ,p_segment30                    in varchar2 default null
  ,p_template_tab_page_id         in number default null
  ,p_alignment                    in number default hr_api.g_number
  ,p_bevel                        in number default hr_api.g_number
  ,p_case_restriction             in number default hr_api.g_number
  ,p_default_value                in varchar2 default hr_api.g_varchar2
  ,p_enabled                      in number default hr_api.g_number
  ,p_format_mask                  in varchar2 default hr_api.g_varchar2
  ,p_height                       in number default hr_api.g_number
  ,p_information_formula_id       in number default hr_api.g_number
  ,p_information_param_item_id1   in number default hr_api.g_number
  ,p_information_param_item_id2   in number default hr_api.g_number
  ,p_information_param_item_id3   in number default hr_api.g_number
  ,p_information_param_item_id4   in number default hr_api.g_number
  ,p_information_param_item_id5   in number default hr_api.g_number
  ,p_information_prompt           in varchar2 default hr_api.g_varchar2
  ,p_insert_allowed               in number default hr_api.g_number
  ,p_label                        in varchar2 default hr_api.g_varchar2
  ,p_prompt_text                  in varchar2 default hr_api.g_varchar2
  ,p_prompt_alignment_offset      in number default hr_api.g_number
  ,p_prompt_display_style         in number default hr_api.g_number
  ,p_prompt_edge                  in number default hr_api.g_number
  ,p_prompt_edge_alignment        in number default hr_api.g_number
  ,p_prompt_edge_offset           in number default hr_api.g_number
  ,p_prompt_text_alignment        in number default hr_api.g_number
  ,p_query_allowed                in number default hr_api.g_number
  ,p_required                     in number default hr_api.g_number
  ,p_tooltip_text                 in varchar2 default hr_api.g_varchar2
  ,p_update_allowed               in number default hr_api.g_number
  ,p_validation_formula_id        in number default hr_api.g_number
  ,p_validation_param_item_id1    in number default hr_api.g_number
  ,p_validation_param_item_id2    in number default hr_api.g_number
  ,p_validation_param_item_id3    in number default hr_api.g_number
  ,p_validation_param_item_id4    in number default hr_api.g_number
  ,p_validation_param_item_id5    in number default hr_api.g_number
  ,p_visible                      in number default hr_api.g_number
  ,p_width                        in number default hr_api.g_number
  ,p_x_position                   in number default hr_api.g_number
  ,p_y_position                   in number default hr_api.g_number
  ,p_information_category         in varchar2 default hr_api.g_varchar2
  ,p_information1                 in varchar2 default hr_api.g_varchar2
  ,p_information2                 in varchar2 default hr_api.g_varchar2
  ,p_information3                 in varchar2 default hr_api.g_varchar2
  ,p_information4                 in varchar2 default hr_api.g_varchar2
  ,p_information5                 in varchar2 default hr_api.g_varchar2
  ,p_information6                 in varchar2 default hr_api.g_varchar2
  ,p_information7                 in varchar2 default hr_api.g_varchar2
  ,p_information8                 in varchar2 default hr_api.g_varchar2
  ,p_information9                 in varchar2 default hr_api.g_varchar2
  ,p_information10                in varchar2 default hr_api.g_varchar2
  ,p_information11                in varchar2 default hr_api.g_varchar2
  ,p_information12                in varchar2 default hr_api.g_varchar2
  ,p_information13                in varchar2 default hr_api.g_varchar2
  ,p_information14                in varchar2 default hr_api.g_varchar2
  ,p_information15                in varchar2 default hr_api.g_varchar2
  ,p_information16                in varchar2 default hr_api.g_varchar2
  ,p_information17                in varchar2 default hr_api.g_varchar2
  ,p_information18                in varchar2 default hr_api.g_varchar2
  ,p_information19                in varchar2 default hr_api.g_varchar2
  ,p_information20                in varchar2 default hr_api.g_varchar2
  ,p_information21                in varchar2 default hr_api.g_varchar2
  ,p_information22                in varchar2 default hr_api.g_varchar2
  ,p_information23                in varchar2 default hr_api.g_varchar2
  ,p_information24                in varchar2 default hr_api.g_varchar2
  ,p_information25                in varchar2 default hr_api.g_varchar2
  ,p_information26                in varchar2 default hr_api.g_varchar2
  ,p_information27                in varchar2 default hr_api.g_varchar2
  ,p_information28                in varchar2 default hr_api.g_varchar2
  ,p_information29                in varchar2 default hr_api.g_varchar2
  ,p_information30                in varchar2 default hr_api.g_varchar2
  ,p_next_navigation_item_id      in number default hr_api.g_number
  ,p_previous_navigation_item_id      in number default hr_api.g_number
  ,p_template_item_context_id     out nocopy number
  ,p_object_version_number        out nocopy number
  ,p_item_context_id              out nocopy number
  ,p_concatenated_segments        out nocopy varchar2
  ,p_override_value_warning       out nocopy boolean
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

  l_tic_id number;
  l_ovn_item number;
  l_item_property_id number;
  l_override_value_warning        boolean := FALSE;
  l_template_item_context_id     number;
  l_object_version_number         number;
  l_item_context_id               number;
  l_concatenated_segments         varchar2(2000);
  l_language_code fnd_languages.language_code%TYPE;

  l_proc                varchar2(72) := g_package||'create_template_item_context';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_template_item_context;
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
    hr_template_item_contexts_bk2.create_template_item_context_b
      (p_effective_date              => TRUNC(p_effective_date)
      ,p_language_code               => l_language_code
      ,p_template_item_id            => p_template_item_id
      ,p_context_type                => p_context_type
      ,p_segment1                    => p_segment1
      ,p_segment2                    => p_segment2
      ,p_segment3                    => p_segment3
      ,p_segment4                    => p_segment4
      ,p_segment5                    => p_segment5
      ,p_segment6                    => p_segment6
      ,p_segment7                    => p_segment7
      ,p_segment8                    => p_segment8
      ,p_segment9                    => p_segment9
      ,p_segment10                   => p_segment10
      ,p_segment11                   => p_segment11
      ,p_segment12                   => p_segment12
      ,p_segment13                   => p_segment13
      ,p_segment14                   => p_segment14
      ,p_segment15                   => p_segment15
      ,p_segment16                   => p_segment16
      ,p_segment17                   => p_segment17
      ,p_segment18                   => p_segment18
      ,p_segment19                   => p_segment19
      ,p_segment20                   => p_segment20
      ,p_segment21                   => p_segment21
      ,p_segment22                   => p_segment22
      ,p_segment23                   => p_segment23
      ,p_segment24                   => p_segment24
      ,p_segment25                   => p_segment25
      ,p_segment26                   => p_segment26
      ,p_segment27                   => p_segment27
      ,p_segment28                   => p_segment28
      ,p_segment29                   => p_segment29
      ,p_segment30                   => p_segment30
      ,p_template_tab_page_id        => p_template_tab_page_id
      ,p_alignment                   => p_alignment
      ,p_bevel                       => p_bevel
      ,p_case_restriction            => p_case_restriction
      ,p_default_value               => p_default_value
      ,p_enabled                     => p_enabled
      ,p_format_mask                 => p_format_mask
      ,p_height                      => p_height
      ,p_information_formula_id      => p_information_formula_id
      ,p_information_param_item_id1  => p_information_param_item_id1
      ,p_information_param_item_id2  => p_information_param_item_id2
      ,p_information_param_item_id3  => p_information_param_item_id3
      ,p_information_param_item_id4  => p_information_param_item_id4
      ,p_information_param_item_id5  => p_information_param_item_id5
      ,p_information_prompt          => p_information_prompt
      ,p_insert_allowed              => p_insert_allowed
      ,p_label                       => p_label
      ,p_prompt_text                 => p_prompt_text
      ,p_prompt_alignment_offset     => p_prompt_alignment_offset
      ,p_prompt_display_style        => p_prompt_display_style
      ,p_prompt_edge                 => p_prompt_edge
      ,p_prompt_edge_alignment       => p_prompt_edge_alignment
      ,p_prompt_edge_offset          => p_prompt_edge_offset
      ,p_prompt_text_alignment       => p_prompt_text_alignment
      ,p_query_allowed               => p_query_allowed
      ,p_required                    => p_required
      ,p_tooltip_text                => p_tooltip_text
      ,p_update_allowed              => p_update_allowed
      ,p_validation_formula_id       => p_validation_formula_id
      ,p_validation_param_item_id1   => p_validation_param_item_id1
      ,p_validation_param_item_id2   => p_validation_param_item_id2
      ,p_validation_param_item_id3   => p_validation_param_item_id3
      ,p_validation_param_item_id4   => p_validation_param_item_id4
      ,p_validation_param_item_id5   => p_validation_param_item_id5
      ,p_visible                     => p_visible
      ,p_width                       => p_width
      ,p_x_position                  => p_x_position
      ,p_y_position                  => p_y_position
      ,p_information_category        => p_information_category
      ,p_information1                => p_information1
      ,p_information2                => p_information2
      ,p_information3                => p_information3
      ,p_information4                => p_information4
      ,p_information5                => p_information5
      ,p_information6                => p_information6
      ,p_information7                => p_information7
      ,p_information8                => p_information8
      ,p_information9                => p_information9
      ,p_information10               => p_information10
      ,p_information11               => p_information11
      ,p_information12               => p_information12
      ,p_information13               => p_information13
      ,p_information14               => p_information14
      ,p_information15               => p_information15
      ,p_information16               => p_information16
      ,p_information17               => p_information17
      ,p_information18               => p_information18
      ,p_information19               => p_information19
      ,p_information20               => p_information20
      ,p_information21               => p_information21
      ,p_information22               => p_information22
      ,p_information23               => p_information23
      ,p_information24               => p_information24
      ,p_information25               => p_information25
      ,p_information26               => p_information26
      ,p_information27               => p_information27
      ,p_information28               => p_information28
      ,p_information29               => p_information29
      ,p_information30               => p_information30
      ,p_next_navigation_item_id     => p_next_navigation_item_id
      ,p_previous_navigation_item_id     => p_previous_navigation_item_id);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_template_item_context'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  hr_utility.set_location('At:'|| l_proc, 15);

     OPEN cur_override;
     FETCH cur_override INTO l_required_override,l_visible_override;
     CLOSE cur_override;

  hr_utility.set_location('At:'|| l_proc, 20);

     IF p_required <> hr_api.g_number AND
       ( l_required_override is not null AND p_required is not null ) THEN
        l_override_value_warning  := TRUE;
     END IF;

  hr_utility.set_location('At:'|| l_proc, 25);

     IF p_visible <> hr_api.g_number AND
       ( l_visible_override is not null AND p_visible is not null ) THEN
        l_override_value_warning  := TRUE;
     END IF;

  hr_utility.set_location('At:'|| l_proc, 30);

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

  hr_utility.set_location('At:'|| l_proc, 35);

  --
  --
  -- Process Logic
  --

  hr_icx_ins.ins_or_sel(
             p_context_type                  => p_context_type
             ,p_segment1                     => p_segment1
             ,p_segment2                     => p_segment2
             ,p_segment3                     => p_segment3
             ,p_segment4                     => p_segment4
             ,p_segment5                     => p_segment5
             ,p_segment6                     => p_segment6
             ,p_segment7                     => p_segment7
             ,p_segment8                     => p_segment8
             ,p_segment9                     => p_segment9
             ,p_segment10                    => p_segment10
             ,p_segment11                    => p_segment11
             ,p_segment12                    => p_segment12
             ,p_segment13                    => p_segment13
             ,p_segment14                    => p_segment14
             ,p_segment15                    => p_segment15
             ,p_segment16                    => p_segment16
             ,p_segment17                    => p_segment17
             ,p_segment18                    => p_segment18
             ,p_segment19                    => p_segment19
             ,p_segment20                    => p_segment20
             ,p_segment21                    => p_segment21
             ,p_segment22                    => p_segment22
             ,p_segment23                    => p_segment23
             ,p_segment24                    => p_segment24
             ,p_segment25                    => p_segment25
             ,p_segment26                    => p_segment26
             ,p_segment27                    => p_segment27
             ,p_segment28                    => p_segment28
             ,p_segment29                    => p_segment29
             ,p_segment30                    => p_segment30
             ,p_item_context_id              => l_item_context_id
             ,p_concatenated_segments        => l_concatenated_segments);

  hr_utility.set_location('At:'|| l_proc, 40);

  hr_tic_ins.ins( p_template_item_id             => p_template_item_id
             ,p_context_type                 => p_context_type
             ,p_item_context_id              => l_item_context_id
             ,p_template_item_context_id     => l_template_item_context_id
             ,p_object_version_number        => l_object_version_number);

  hr_utility.set_location('At:'|| l_proc, 45);

  hr_item_properties_bsi.copy_item_property(
             p_effective_date                => TRUNC(p_effective_date)
             ,p_language_code                => l_language_code
             ,p_template_item_id             => p_template_item_id
             ,p_template_item_context_id     => l_template_item_context_id
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
             ,p_next_navigation_item_id     => p_next_navigation_item_id
             ,p_previous_navigation_item_id  => p_previous_navigation_item_id
             ,p_item_property_id             => l_item_property_id
             ,p_object_version_number        => l_object_version_number);
             --,p_override_value_warning       => l_override_value_warning);

  hr_utility.set_location('At:'|| l_proc, 50);

  IF p_template_tab_page_id is not null THEN

    hr_tcp_api.create_tcp(
       p_effective_date                 => TRUNC(p_effective_date)
       ,p_template_item_context_id      => l_template_item_context_id
       ,p_template_tab_page_id          => p_template_tab_page_id
       ,p_template_item_context_page_i => l_tic_id
       ,p_object_version_number         => l_ovn_item);
  END IF;
  hr_utility.set_location('At:'|| l_proc, 55);

  --
  -- Call After Process User Hook
  --
  begin
    hr_template_item_contexts_bk2.create_template_item_context_a
      (p_effective_date              => TRUNC(p_effective_date)
      ,p_language_code               => l_language_code
      ,p_template_item_id            => p_template_item_id
      ,p_context_type                => p_context_type
      ,p_segment1                    => p_segment1
      ,p_segment2                    => p_segment2
      ,p_segment3                    => p_segment3
      ,p_segment4                    => p_segment4
      ,p_segment5                    => p_segment5
      ,p_segment6                    => p_segment6
      ,p_segment7                    => p_segment7
      ,p_segment8                    => p_segment8
      ,p_segment9                    => p_segment9
      ,p_segment10                   => p_segment10
      ,p_segment11                   => p_segment11
      ,p_segment12                   => p_segment12
      ,p_segment13                   => p_segment13
      ,p_segment14                   => p_segment14
      ,p_segment15                   => p_segment15
      ,p_segment16                   => p_segment16
      ,p_segment17                   => p_segment17
      ,p_segment18                   => p_segment18
      ,p_segment19                   => p_segment19
      ,p_segment20                   => p_segment20
      ,p_segment21                   => p_segment21
      ,p_segment22                   => p_segment22
      ,p_segment23                   => p_segment23
      ,p_segment24                   => p_segment24
      ,p_segment25                   => p_segment25
      ,p_segment26                   => p_segment26
      ,p_segment27                   => p_segment27
      ,p_segment28                   => p_segment28
      ,p_segment29                   => p_segment29
      ,p_segment30                   => p_segment30
      ,p_template_tab_page_id        => p_template_tab_page_id
      ,p_alignment                   => p_alignment
      ,p_bevel                       => p_bevel
      ,p_case_restriction            => p_case_restriction
      ,p_default_value               => p_default_value
      ,p_enabled                     => p_enabled
      ,p_format_mask                 => p_format_mask
      ,p_height                      => p_height
      ,p_information_formula_id      => p_information_formula_id
      ,p_information_param_item_id1  => p_information_param_item_id1
      ,p_information_param_item_id2  => p_information_param_item_id2
      ,p_information_param_item_id3  => p_information_param_item_id3
      ,p_information_param_item_id4  => p_information_param_item_id4
      ,p_information_param_item_id5  => p_information_param_item_id5
      ,p_information_prompt          => p_information_prompt
      ,p_insert_allowed              => p_insert_allowed
      ,p_label                       => p_label
      ,p_prompt_text                 => p_prompt_text
      ,p_prompt_alignment_offset     => p_prompt_alignment_offset
      ,p_prompt_display_style        => p_prompt_display_style
      ,p_prompt_edge                 => p_prompt_edge
      ,p_prompt_edge_alignment       => p_prompt_edge_alignment
      ,p_prompt_edge_offset          => p_prompt_edge_offset
      ,p_prompt_text_alignment       => p_prompt_text_alignment
      ,p_query_allowed               => p_query_allowed
      ,p_required                    => p_required
      ,p_tooltip_text                => p_tooltip_text
      ,p_update_allowed              => p_update_allowed
      ,p_validation_formula_id       => p_validation_formula_id
      ,p_validation_param_item_id1   => p_validation_param_item_id1
      ,p_validation_param_item_id2   => p_validation_param_item_id2
      ,p_validation_param_item_id3   => p_validation_param_item_id3
      ,p_validation_param_item_id4   => p_validation_param_item_id4
      ,p_validation_param_item_id5   => p_validation_param_item_id5
      ,p_visible                     => p_visible
      ,p_width                       => p_width
      ,p_x_position                  => p_x_position
      ,p_y_position                  => p_y_position
      ,p_information_category        => p_information_category
      ,p_information1                => p_information1
      ,p_information2                => p_information2
      ,p_information3                => p_information3
      ,p_information4                => p_information4
      ,p_information5                => p_information5
      ,p_information6                => p_information6
      ,p_information7                => p_information7
      ,p_information8                => p_information8
      ,p_information9                => p_information9
      ,p_information10               => p_information10
      ,p_information11               => p_information11
      ,p_information12               => p_information12
      ,p_information13               => p_information13
      ,p_information14               => p_information14
      ,p_information15               => p_information15
      ,p_information16               => p_information16
      ,p_information17               => p_information17
      ,p_information18               => p_information18
      ,p_information19               => p_information19
      ,p_information20               => p_information20
      ,p_information21               => p_information21
      ,p_information22               => p_information22
      ,p_information23               => p_information23
      ,p_information24               => p_information24
      ,p_information25               => p_information25
      ,p_information26               => p_information26
      ,p_information27               => p_information27
      ,p_information28               => p_information28
      ,p_information29               => p_information29
      ,p_information30               => p_information30
      ,p_next_navigation_item_id     => p_next_navigation_item_id
      ,p_previous_navigation_item_id => p_previous_navigation_item_id
      ,p_template_item_context_id    => l_template_item_context_id
      ,p_object_version_number       => l_object_version_number
      ,p_item_context_id             => l_item_context_id
      ,p_concatenated_segments       => l_concatenated_segments
      ,p_override_value_warning      => l_override_value_warning
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_template_item_context'
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
  p_template_item_context_id    := l_template_item_context_id;
  p_object_version_number       := l_object_version_number;
  p_item_context_id             := l_item_context_id;
  p_concatenated_segments       := l_concatenated_segments;
  p_override_value_warning      := l_override_value_warning;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_template_item_context;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_template_item_context_id    := null;
    p_object_version_number       := null;
    p_item_context_id             := null;
    p_concatenated_segments       := null;
    p_override_value_warning      := l_override_value_warning;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_template_item_context_id    := null;
    p_object_version_number       := null;
    p_item_context_id             := null;
    p_concatenated_segments       := null;
    p_override_value_warning      := null;

    rollback to create_template_item_context;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_template_item_context;
--
-- ----------------------------------------------------------------------------
-- |----------------< delete_template_item_context >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_template_item_context
  (p_validate                      in     boolean  default false
   ,p_template_item_context_id     in    number
   ,p_object_version_number        in    number
   --,p_delete_children_flag         in    varchar2 default 'N'
  ) is
  --
  -- Declare cursors and local variables
  --

  CURSOR cur_tmplt_item
  IS
  SELECT template_item_context_page_id
  ,object_version_number
  FROM hr_template_item_context_pages
  WHERE template_item_context_id = p_template_item_context_id;

  l_temp number;

  CURSOR cur_api_val
  IS
  SELECT source_form_template_id
  FROM hr_source_form_templates hsf
       ,hr_template_items_b hti
       ,hr_template_item_contexts_b tic
  WHERE hsf.form_template_id_to = hti.form_template_id
  AND hti.template_item_id = tic.template_item_id
  AND tic.template_item_context_id = p_template_item_context_id;

  l_proc                varchar2(72) := g_package||'delete_template_item_context';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_template_item_context;
  --
  -- Call Before Process User Hook
  --
  begin
    hr_template_item_contexts_bk3.delete_template_item_context_b
      (p_template_item_context_id     => p_template_item_context_id
       ,p_object_version_number       => p_object_version_number
       --,p_delete_children_flag        => p_delete_children_flag
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_template_item_context'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  hr_utility.set_location('At:'|| l_proc, 15);

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
  hr_utility.set_location('At:'|| l_proc, 20);

  hr_utility.set_location('At:'|| l_proc, 25);

  FOR cur_rec IN cur_tmplt_item LOOP
    hr_tcp_api.delete_tcp(
            p_template_item_context_page_i => cur_rec.template_item_context_page_id
            ,p_object_version_number        => cur_rec.object_version_number);
            --,p_delete_all_flag              => 'Y');
  END LOOP;

  hr_utility.set_location('At:'|| l_proc, 30);

  hr_item_properties_bsi.delete_item_property(
             p_template_item_context_id     => p_template_item_context_id
             ,p_object_version_number        => p_object_version_number);

  hr_utility.set_location('At:'|| l_proc, 35);

  hr_tic_del.del( p_template_item_context_id     => p_template_item_context_id
                 ,p_object_version_number        => p_object_version_number);

  --
  -- Call After Process User Hook
  --
  hr_utility.set_location('At:'|| l_proc, 40);

  begin
    hr_template_item_contexts_bk3.delete_template_item_context_a
      (p_template_item_context_id     => p_template_item_context_id
       ,p_object_version_number       => p_object_version_number
       --,p_delete_children_flag        => p_delete_children_flag
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_template_item_context'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  hr_utility.set_location('At:'|| l_proc, 45);

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
    rollback to delete_template_item_context;
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
    rollback to delete_template_item_context;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_template_item_context;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_template_item_context >----------------|
-- ----------------------------------------------------------------------------
--
procedure update_template_item_context
  (p_validate                     in boolean  default false
  ,p_effective_date               in date
  ,p_language_code                in varchar2 default hr_api.userenv_lang
  --,p_context_type                 in varchar2 default hr_api.g_varchar2
  ,p_template_item_context_id     in number
  ,p_object_version_number        in out nocopy number
  --,p_segment1                     in varchar2 default hr_api.g_varchar2
  --,p_segment2                     in varchar2 default hr_api.g_varchar2
  --,p_segment3                     in varchar2 default hr_api.g_varchar2
  --,p_segment4                     in varchar2 default hr_api.g_varchar2
  --,p_segment5                     in varchar2 default hr_api.g_varchar2
  --,p_segment6                     in varchar2 default hr_api.g_varchar2
  --,p_segment7                     in varchar2 default hr_api.g_varchar2
  --,p_segment8                     in varchar2 default hr_api.g_varchar2
  --,p_segment9                     in varchar2 default hr_api.g_varchar2
  --,p_segment10                    in varchar2 default hr_api.g_varchar2
  --,p_segment11                    in varchar2 default hr_api.g_varchar2
  --,p_segment12                    in varchar2 default hr_api.g_varchar2
  --,p_segment13                    in varchar2 default hr_api.g_varchar2
  --,p_segment14                    in varchar2 default hr_api.g_varchar2
  --,p_segment15                    in varchar2 default hr_api.g_varchar2
  --,p_segment16                    in varchar2 default hr_api.g_varchar2
  --,p_segment17                    in varchar2 default hr_api.g_varchar2
  --,p_segment18                    in varchar2 default hr_api.g_varchar2
  --,p_segment19                    in varchar2 default hr_api.g_varchar2
  --,p_segment20                    in varchar2 default hr_api.g_varchar2
  --,p_segment21                    in varchar2 default hr_api.g_varchar2
  --,p_segment22                    in varchar2 default hr_api.g_varchar2
  --,p_segment23                    in varchar2 default hr_api.g_varchar2
  --,p_segment24                    in varchar2 default hr_api.g_varchar2
  --,p_segment25                    in varchar2 default hr_api.g_varchar2
  --,p_segment26                    in varchar2 default hr_api.g_varchar2
  --,p_segment27                    in varchar2 default hr_api.g_varchar2
  --,p_segment28                    in varchar2 default hr_api.g_varchar2
  --,p_segment29                    in varchar2 default hr_api.g_varchar2
  --,p_segment30                    in varchar2 default hr_api.g_varchar2
  ,p_template_tab_page_id         in number default hr_api.g_number
  ,p_alignment                    in number default hr_api.g_number
  ,p_bevel                        in number default hr_api.g_number
  ,p_case_restriction             in number default hr_api.g_number
  ,p_default_value                in varchar2 default hr_api.g_varchar2
  ,p_enabled                      in number default hr_api.g_number
  ,p_format_mask                  in varchar2 default hr_api.g_varchar2
  ,p_height                       in number default hr_api.g_number
  ,p_information_formula_id       in number default hr_api.g_number
  ,p_information_param_item_id1   in number default hr_api.g_number
  ,p_information_param_item_id2   in number default hr_api.g_number
  ,p_information_param_item_id3   in number default hr_api.g_number
  ,p_information_param_item_id4   in number default hr_api.g_number
  ,p_information_param_item_id5   in number default hr_api.g_number
  ,p_information_prompt           in varchar2 default hr_api.g_varchar2
  ,p_insert_allowed               in number default hr_api.g_number
  ,p_label                        in varchar2 default hr_api.g_varchar2
  ,p_prompt_text                  in varchar2 default hr_api.g_varchar2
  ,p_prompt_alignment_offset      in number default hr_api.g_number
  ,p_prompt_display_style         in number default hr_api.g_number
  ,p_prompt_edge                  in number default hr_api.g_number
  ,p_prompt_edge_alignment        in number default hr_api.g_number
  ,p_prompt_edge_offset           in number default hr_api.g_number
  ,p_prompt_text_alignment        in number default hr_api.g_number
  ,p_query_allowed                in number default hr_api.g_number
  ,p_required                     in number default hr_api.g_number
  ,p_tooltip_text                 in varchar2 default hr_api.g_varchar2
  ,p_update_allowed               in number default hr_api.g_number
  ,p_validation_formula_id        in number default hr_api.g_number
  ,p_validation_param_item_id1    in number default hr_api.g_number
  ,p_validation_param_item_id2    in number default hr_api.g_number
  ,p_validation_param_item_id3    in number default hr_api.g_number
  ,p_validation_param_item_id4    in number default hr_api.g_number
  ,p_validation_param_item_id5    in number default hr_api.g_number
  ,p_visible                      in number default hr_api.g_number
  ,p_width                        in number default hr_api.g_number
  ,p_x_position                   in number default hr_api.g_number
  ,p_y_position                   in number default hr_api.g_number
  ,p_information_category         in varchar2 default hr_api.g_varchar2
  ,p_information1                 in varchar2 default hr_api.g_varchar2
  ,p_information2                 in varchar2 default hr_api.g_varchar2
  ,p_information3                 in varchar2 default hr_api.g_varchar2
  ,p_information4                 in varchar2 default hr_api.g_varchar2
  ,p_information5                 in varchar2 default hr_api.g_varchar2
  ,p_information6                 in varchar2 default hr_api.g_varchar2
  ,p_information7                 in varchar2 default hr_api.g_varchar2
  ,p_information8                 in varchar2 default hr_api.g_varchar2
  ,p_information9                 in varchar2 default hr_api.g_varchar2
  ,p_information10                in varchar2 default hr_api.g_varchar2
  ,p_information11                in varchar2 default hr_api.g_varchar2
  ,p_information12                in varchar2 default hr_api.g_varchar2
  ,p_information13                in varchar2 default hr_api.g_varchar2
  ,p_information14                in varchar2 default hr_api.g_varchar2
  ,p_information15                in varchar2 default hr_api.g_varchar2
  ,p_information16                in varchar2 default hr_api.g_varchar2
  ,p_information17                in varchar2 default hr_api.g_varchar2
  ,p_information18                in varchar2 default hr_api.g_varchar2
  ,p_information19                in varchar2 default hr_api.g_varchar2
  ,p_information20                in varchar2 default hr_api.g_varchar2
  ,p_information21                in varchar2 default hr_api.g_varchar2
  ,p_information22                in varchar2 default hr_api.g_varchar2
  ,p_information23                in varchar2 default hr_api.g_varchar2
  ,p_information24                in varchar2 default hr_api.g_varchar2
  ,p_information25                in varchar2 default hr_api.g_varchar2
  ,p_information26                in varchar2 default hr_api.g_varchar2
  ,p_information27                in varchar2 default hr_api.g_varchar2
  ,p_information28                in varchar2 default hr_api.g_varchar2
  ,p_information29                in varchar2 default hr_api.g_varchar2
  ,p_information30                in varchar2 default hr_api.g_varchar2
  ,p_next_navigation_item_id      in number default hr_api.g_number
  ,p_previous_navigation_item_id  in number default hr_api.g_number
  --,p_item_context_id              out number
  --,p_concatenated_segments        out varchar2
  ,p_override_value_warning       out nocopy boolean
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
       ,hr_template_item_contexts_b tic
  WHERE hfi.form_item_id = hti.form_item_id
  AND hti.template_item_id = tic.template_item_id
  AND tic.template_item_context_id = p_template_item_context_id;

  l_temp number;

  CURSOR cur_api_val
  IS
  SELECT source_form_template_id
  FROM hr_source_form_templates hsf
       ,hr_template_items_b hti
       ,hr_template_item_contexts_b tic
  WHERE hsf.form_template_id_to = hti.form_template_id
  AND hti.template_item_id = tic.template_item_id
  AND tic.template_item_context_id = p_template_item_context_id;

  --CURSOR cur_context
  --IS
  --SELECT DECODE(context_type,hr_api.g_varchar2,context_type,p_context_type)
  --FROM hr_template_item_contexts_b
  --WHERE template_item_context_id = p_template_item_context_id;

  --l_context_type varchar2(30);
  l_object_version_number number;
  -- l_item_context_id              number;
  --l_concatenated_segments        varchar2(2000);
  l_override_value_warning       boolean := FALSE;

  l_language_code fnd_languages.language_code%TYPE;

  l_proc                varchar2(72) := g_package||'update_template_item_context';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_template_item_context;
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
    hr_template_item_contexts_bk4.update_template_item_context_b
      (p_effective_date              => TRUNC(p_effective_date)
      ,p_language_code               => l_language_code
      --,p_context_type                => p_context_type
      ,p_template_item_context_id    => p_template_item_context_id
      ,p_object_version_number       => l_object_version_number
--      ,p_segment1                    => p_segment1
--      ,p_segment2                    => p_segment2
--      ,p_segment3                    => p_segment3
--      ,p_segment4                    => p_segment4
--      ,p_segment5                    => p_segment5
--      ,p_segment6                    => p_segment6
--      ,p_segment7                    => p_segment7
--      ,p_segment8                    => p_segment8
--      ,p_segment9                    => p_segment9
--      ,p_segment10                   => p_segment10
--      ,p_segment11                   => p_segment11
--      ,p_segment12                   => p_segment12
--      ,p_segment13                   => p_segment13
--      ,p_segment14                   => p_segment14
--      ,p_segment15                   => p_segment15
--      ,p_segment16                   => p_segment16
--      ,p_segment17                   => p_segment17
--      ,p_segment18                   => p_segment18
--      ,p_segment19                   => p_segment19
--      ,p_segment20                   => p_segment20
--      ,p_segment21                   => p_segment21
--      ,p_segment22                   => p_segment22
--      ,p_segment23                   => p_segment23
--      ,p_segment24                   => p_segment24
--      ,p_segment25                   => p_segment25
--      ,p_segment26                   => p_segment26
--      ,p_segment27                   => p_segment27
--      ,p_segment28                   => p_segment28
--      ,p_segment29                   => p_segment29
--      ,p_segment30                   => p_segment30
      ,p_template_tab_page_id        => p_template_tab_page_id
      ,p_alignment                   => p_alignment
      ,p_bevel                       => p_bevel
      ,p_case_restriction            => p_case_restriction
      ,p_default_value               => p_default_value
      ,p_enabled                     => p_enabled
      ,p_format_mask                 => p_format_mask
      ,p_height                      => p_height
      ,p_information_formula_id      => p_information_formula_id
      ,p_information_param_item_id1  => p_information_param_item_id1
      ,p_information_param_item_id2  => p_information_param_item_id2
      ,p_information_param_item_id3  => p_information_param_item_id3
      ,p_information_param_item_id4  => p_information_param_item_id4
      ,p_information_param_item_id5  => p_information_param_item_id5
      ,p_information_prompt          => p_information_prompt
      ,p_insert_allowed              => p_insert_allowed
      ,p_label                       => p_label
      ,p_prompt_text                 => p_prompt_text
      ,p_prompt_alignment_offset     => p_prompt_alignment_offset
      ,p_prompt_display_style        => p_prompt_display_style
      ,p_prompt_edge                 => p_prompt_edge
      ,p_prompt_edge_alignment       => p_prompt_edge_alignment
      ,p_prompt_edge_offset          => p_prompt_edge_offset
      ,p_prompt_text_alignment       => p_prompt_text_alignment
      ,p_query_allowed               => p_query_allowed
      ,p_required                    => p_required
      ,p_tooltip_text                => p_tooltip_text
      ,p_update_allowed              => p_update_allowed
      ,p_validation_formula_id       => p_validation_formula_id
      ,p_validation_param_item_id1   => p_validation_param_item_id1
      ,p_validation_param_item_id2   => p_validation_param_item_id2
      ,p_validation_param_item_id3   => p_validation_param_item_id3
      ,p_validation_param_item_id4   => p_validation_param_item_id4
      ,p_validation_param_item_id5   => p_validation_param_item_id5
      ,p_visible                     => p_visible
      ,p_width                       => p_width
      ,p_x_position                  => p_x_position
      ,p_y_position                  => p_y_position
      ,p_information_category        => p_information_category
      ,p_information1                => p_information1
      ,p_information2                => p_information2
      ,p_information3                => p_information3
      ,p_information4                => p_information4
      ,p_information5                => p_information5
      ,p_information6                => p_information6
      ,p_information7                => p_information7
      ,p_information8                => p_information8
      ,p_information9                => p_information9
      ,p_information10               => p_information10
      ,p_information11               => p_information11
      ,p_information12               => p_information12
      ,p_information13               => p_information13
      ,p_information14               => p_information14
      ,p_information15               => p_information15
      ,p_information16               => p_information16
      ,p_information17               => p_information17
      ,p_information18               => p_information18
      ,p_information19               => p_information19
      ,p_information20               => p_information20
      ,p_information21               => p_information21
      ,p_information22               => p_information22
      ,p_information23               => p_information23
      ,p_information24               => p_information24
      ,p_information25               => p_information25
      ,p_information26               => p_information26
      ,p_information27               => p_information27
      ,p_information28               => p_information28
      ,p_information29               => p_information29
      ,p_information30               => p_information30
      ,p_next_navigation_item_id     => p_next_navigation_item_id
      ,p_previous_navigation_item_id     => p_previous_navigation_item_id);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_template_item_context'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  hr_utility.set_location('At:'|| l_proc, 15);

     OPEN cur_override;
     FETCH cur_override INTO l_required_override,l_visible_override;
     CLOSE cur_override;

  hr_utility.set_location('At:'|| l_proc, 20);

     IF p_required <> hr_api.g_number AND
       ( l_required_override is not null AND p_required is not null ) THEN
        l_override_value_warning  := TRUE;
     END IF;

  hr_utility.set_location('At:'|| l_proc, 25);

     IF p_visible <> hr_api.g_number AND
       ( l_visible_override is not null AND p_visible is not null ) THEN
        l_override_value_warning  := TRUE;
     END IF;

  hr_utility.set_location('At:'|| l_proc, 30);

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
  hr_utility.set_location('At:'|| l_proc, 35);

  --
  --
  -- Process Logic
  --

  --
  --
     --OPEN cur_context;
     --FETCH cur_context into l_context_type;
     --CLOSE cur_context;
  --
  --
--  hr_icx_upd.upd_or_sel(
--             p_context_type                 => l_context_type
--             ,p_segment1                     => p_segment1
--             ,p_segment2                     => p_segment2
--             ,p_segment3                     => p_segment3
--             ,p_segment4                     => p_segment4
--             ,p_segment5                     => p_segment5
--             ,p_segment6                     => p_segment6
--             ,p_segment7                     => p_segment7
--             ,p_segment8                     => p_segment8
--             ,p_segment9                     => p_segment9
--             ,p_segment10                    => p_segment10
--             ,p_segment11                    => p_segment11
--             ,p_segment12                    => p_segment12
--             ,p_segment13                    => p_segment13
--             ,p_segment14                    => p_segment14
--             ,p_segment15                    => p_segment15
--             ,p_segment16                    => p_segment16
--             ,p_segment17                    => p_segment17
--             ,p_segment18                    => p_segment18
--             ,p_segment19                    => p_segment19
--             ,p_segment20                    => p_segment20
--             ,p_segment21                    => p_segment21
--             ,p_segment22                    => p_segment22
--             ,p_segment23                    => p_segment23
--             ,p_segment24                    => p_segment24
--             ,p_segment25                    => p_segment25
--             ,p_segment26                    => p_segment26
--             ,p_segment27                    => p_segment27
--             ,p_segment28                    => p_segment28
--             ,p_segment29                    => p_segment29
             --,p_segment30                    => p_segment30
             --,p_item_context_id              => l_item_context_id
             --,p_concatenated_segments        => l_concatenated_segments);

  --hr_tic_upd.upd(p_template_item_context_id     => p_template_item_context_id
             --,p_object_version_number        => l_object_version_number
             --,p_context_type                 => l_context_type
             --,p_item_context_id              => l_item_context_id);

  hr_utility.set_location('At:'|| l_proc, 40);

  hr_utility.set_location('At:'|| l_proc, 45);

  hr_item_properties_bsi.update_item_property(
              p_effective_date               => TRUNC(p_effective_date)
             ,p_language_code                => l_language_code
             ,p_object_version_number        => l_object_version_number
             ,p_template_item_context_id     => p_template_item_context_id
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
             ,p_next_navigation_item_id     => p_next_navigation_item_id
             ,p_previous_navigation_item_id     => p_previous_navigation_item_id);
             --,p_override_value_warning       => l_override_value_warning);

  hr_utility.set_location('At:'|| l_proc, 50);

  --
  -- Call After Process User Hook
  --
  begin
    hr_template_item_contexts_bk4.update_template_item_context_a
      (p_effective_date              => TRUNC(p_effective_date)
      ,p_language_code               => l_language_code
      --,p_context_type                => p_context_type
      ,p_template_item_context_id    => p_template_item_context_id
      ,p_object_version_number       => l_object_version_number
--      ,p_segment1                    => p_segment1
--      ,p_segment2                    => p_segment2
--      ,p_segment3                    => p_segment3
--      ,p_segment4                    => p_segment4
--      ,p_segment5                    => p_segment5
--      ,p_segment6                    => p_segment6
--      ,p_segment7                    => p_segment7
--      ,p_segment8                    => p_segment8
--      ,p_segment9                    => p_segment9
--      ,p_segment10                   => p_segment10
--      ,p_segment11                   => p_segment11
--      ,p_segment12                   => p_segment12
--      ,p_segment13                   => p_segment13
--      ,p_segment14                   => p_segment14
--      ,p_segment15                   => p_segment15
--      ,p_segment16                   => p_segment16
--      ,p_segment17                   => p_segment17
--      ,p_segment18                   => p_segment18
--      ,p_segment19                   => p_segment19
--      ,p_segment20                   => p_segment20
--      ,p_segment21                   => p_segment21
--      ,p_segment22                   => p_segment22
--      ,p_segment23                   => p_segment23
--      ,p_segment24                   => p_segment24
--      ,p_segment25                   => p_segment25
--      ,p_segment26                   => p_segment26
--      ,p_segment27                   => p_segment27
--      ,p_segment28                   => p_segment28
--      ,p_segment29                   => p_segment29
--      ,p_segment30                   => p_segment30
      ,p_template_tab_page_id        => p_template_tab_page_id
      ,p_alignment                   => p_alignment
      ,p_bevel                       => p_bevel
      ,p_case_restriction            => p_case_restriction
      ,p_default_value               => p_default_value
      ,p_enabled                     => p_enabled
      ,p_format_mask                 => p_format_mask
      ,p_height                      => p_height
      ,p_information_formula_id      => p_information_formula_id
      ,p_information_param_item_id1  => p_information_param_item_id1
      ,p_information_param_item_id2  => p_information_param_item_id2
      ,p_information_param_item_id3  => p_information_param_item_id3
      ,p_information_param_item_id4  => p_information_param_item_id4
      ,p_information_param_item_id5  => p_information_param_item_id5
      ,p_information_prompt          => p_information_prompt
      ,p_insert_allowed              => p_insert_allowed
      ,p_label                       => p_label
      ,p_prompt_text                 => p_prompt_text
      ,p_prompt_alignment_offset     => p_prompt_alignment_offset
      ,p_prompt_display_style        => p_prompt_display_style
      ,p_prompt_edge                 => p_prompt_edge
      ,p_prompt_edge_alignment       => p_prompt_edge_alignment
      ,p_prompt_edge_offset          => p_prompt_edge_offset
      ,p_prompt_text_alignment       => p_prompt_text_alignment
      ,p_query_allowed               => p_query_allowed
      ,p_required                    => p_required
      ,p_tooltip_text                => p_tooltip_text
      ,p_update_allowed              => p_update_allowed
      ,p_validation_formula_id       => p_validation_formula_id
      ,p_validation_param_item_id1   => p_validation_param_item_id1
      ,p_validation_param_item_id2   => p_validation_param_item_id2
      ,p_validation_param_item_id3   => p_validation_param_item_id3
      ,p_validation_param_item_id4   => p_validation_param_item_id4
      ,p_validation_param_item_id5   => p_validation_param_item_id5
      ,p_visible                     => p_visible
      ,p_width                       => p_width
      ,p_x_position                  => p_x_position
      ,p_y_position                  => p_y_position
      ,p_information_category        => p_information_category
      ,p_information1                => p_information1
      ,p_information2                => p_information2
      ,p_information3                => p_information3
      ,p_information4                => p_information4
      ,p_information5                => p_information5
      ,p_information6                => p_information6
      ,p_information7                => p_information7
      ,p_information8                => p_information8
      ,p_information9                => p_information9
      ,p_information10               => p_information10
      ,p_information11               => p_information11
      ,p_information12               => p_information12
      ,p_information13               => p_information13
      ,p_information14               => p_information14
      ,p_information15               => p_information15
      ,p_information16               => p_information16
      ,p_information17               => p_information17
      ,p_information18               => p_information18
      ,p_information19               => p_information19
      ,p_information20               => p_information20
      ,p_information21               => p_information21
      ,p_information22               => p_information22
      ,p_information23               => p_information23
      ,p_information24               => p_information24
      ,p_information25               => p_information25
      ,p_information26               => p_information26
      ,p_information27               => p_information27
      ,p_information28               => p_information28
      ,p_information29               => p_information29
      ,p_information30               => p_information30
      ,p_next_navigation_item_id     => p_next_navigation_item_id
      ,p_previous_navigation_item_id     => p_previous_navigation_item_id
      --,p_item_context_id             => l_item_context_id
      --,p_concatenated_segments       => l_concatenated_segments
      ,p_override_value_warning      => l_override_value_warning);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_template_item_context'
        ,p_hook_type   => 'AP'
        );
  end;
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
  --p_item_context_id             := l_item_context_id;
  --p_concatenated_segments       := l_concatenated_segments;
  p_override_value_warning      := l_override_value_warning;
  p_object_version_number       := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_template_item_context;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    --p_item_context_id             := null;
    --p_concatenated_segments       := null;
    p_override_value_warning      := l_override_value_warning;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_override_value_warning := null ;

    rollback to update_template_item_context;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_template_item_context;
--
end hr_template_item_contexts_api;

/
