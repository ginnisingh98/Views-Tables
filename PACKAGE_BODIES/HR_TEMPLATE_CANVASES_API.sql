--------------------------------------------------------
--  DDL for Package Body HR_TEMPLATE_CANVASES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_TEMPLATE_CANVASES_API" as
/* $Header: hrtcuapi.pkb 115.5 2003/10/31 06:54:37 bsubrama noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_template_canvases_api.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< copy_template_canvas >------------------------|
-- ----------------------------------------------------------------------------
--
procedure copy_template_canvas
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_language_code                 in     varchar2 default hr_api.userenv_lang
  ,p_template_canvas_id_from       in     number
  ,p_template_window_id            in     number
  ,p_template_canvas_id_to            out nocopy number
  ,p_object_version_number            out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  CURSOR cur_form_canvas
  IS
  SELECT tcn.form_canvas_id
  FROM hr_template_canvases tcn
  WHERE tcn.template_canvas_id = p_template_canvas_id_from;

  CURSOR cur_tmplt_tab
  IS
  SELECT ttp.template_tab_page_id
  FROM hr_template_tab_pages ttp
  WHERE ttp.template_canvas_id = p_template_canvas_id_from;

  l_temp number;

  CURSOR cur_api_val
  IS
  SELECT source_form_template_id
  FROM hr_source_form_templates hsf
       ,hr_template_windows_b htw
  WHERE hsf.form_template_id_to = htw.form_template_id
  AND htw.template_window_id = p_template_window_id;

  l_template_tab_page_id_to number;
  l_ovn_tab number;
  l_override_value_warning boolean;
  l_form_canvas_id number;
  l_canvas_property_id number;
  l_object_version_number number;
  l_template_canvas_id_to number;
  l_language_code fnd_languages.language_code%TYPE;

  l_proc                varchar2(72) := g_package||'copy_template_canvas';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint copy_template_canvas;
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
    hr_template_canvases_api_bk1.copy_template_canvas_b
      (p_effective_date           => TRUNC(p_effective_date)
      ,p_language_code            => l_language_code
      ,p_template_canvas_id_from  => p_template_canvas_id_from
      ,p_template_window_id       => p_template_window_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'copy_template_canvas'
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
  -- Process Logic
  --

  hr_utility.set_location('At:'|| l_proc, 20);

  OPEN cur_form_canvas;
  FETCH cur_form_canvas INTO l_form_canvas_id;
  CLOSE cur_form_canvas;

  hr_utility.set_location('At:'|| l_proc, 25);

  hr_tcn_ins.ins(p_template_window_id           => p_template_window_id
             ,p_form_canvas_id               => l_form_canvas_id
             ,p_template_canvas_id           => l_template_canvas_id_to
             ,p_object_version_number        => l_object_version_number);

  hr_utility.set_location('At:'|| l_proc, 30);

  hr_canvas_properties_bsi.copy_canvas_property(
             p_effective_date                => TRUNC(p_effective_date)
             ,p_template_canvas_id_from      => p_template_canvas_id_from
             ,p_template_canvas_id_to        => l_template_canvas_id_to
             ,p_canvas_property_id           => l_canvas_property_id
             ,p_object_version_number        => l_object_version_number);

  hr_utility.set_location('At:'|| l_proc, 35);

  FOR cur_rec IN cur_tmplt_tab LOOP
    hr_template_tab_pages_api.copy_template_tab_page(
                p_effective_date                => TRUNC(p_effective_date)
                ,p_template_tab_page_id_from    => cur_rec.template_tab_page_id
                ,p_template_canvas_id           => l_template_canvas_id_to
                ,p_template_tab_page_id_to      => l_template_tab_page_id_to
                ,p_object_version_number        => l_ovn_tab);
                --,p_override_value_warning       => l_override_value_warning);
  END LOOP;

  hr_utility.set_location('At:'|| l_proc, 40);

  --
  -- Call After Process User Hook
  --
  begin
    hr_template_canvases_api_bk1.copy_template_canvas_b
      (p_effective_date           => TRUNC(p_effective_date)
      ,p_language_code            => l_language_code
      ,p_template_canvas_id_from  => p_template_canvas_id_from
      ,p_template_window_id       => p_template_window_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'copy_template_canvas'
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
  -- Set all output arguments
  --
     p_template_canvas_id_to    := l_template_canvas_id_to;
     p_object_version_number    := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to copy_template_canvas;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_template_canvas_id_to    := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_template_canvas_id_to    := null;
    p_object_version_number  := null;

    rollback to copy_template_canvas;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end copy_template_canvas;
--
-- ----------------------------------------------------------------------------
-- |----------------------< create_template_canvas >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_template_canvas
  (p_validate                        in boolean  default false
  ,p_effective_date                  in date
-- ask john
--,p_language_code                   in varchar2 default hr_api.userenv_lang
  ,p_template_window_id              in number
  ,p_form_canvas_id                  in number
  ,p_height                          in number default hr_api.g_number
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
  ,p_template_canvas_id                out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --

  CURSOR cur_canvas_type
  IS
  SELECT fcn.canvas_type
  FROM hr_form_canvases fcn
  WHERE fcn.form_canvas_id = p_form_canvas_id;

  CURSOR cur_tmplt_window
  IS
  SELECT DECODE(p_height,hr_api.g_number,twn.height,p_height)
  ,DECODE(p_width,hr_api.g_number,twn.width,p_width)
  FROM hr_template_windows twn
  WHERE twn.template_window_id = p_template_window_id;

  l_temp number;

  CURSOR cur_api_val
  IS
  SELECT source_form_template_id
  FROM hr_source_form_templates hsf
       ,hr_template_windows_b htw
  WHERE hsf.form_template_id_to = htw.form_template_id
  AND htw.template_window_id = p_template_window_id;

  l_canvas_property_id number;
  l_height hr_template_windows.height%TYPE;
  l_width hr_template_windows.width%TYPE;
  l_canvas_type hr_form_canvases.canvas_type%TYPE;
  l_proc                varchar2(72) := g_package||'create_template_canvas';
  l_template_canvas_id  number;
  l_object_version_number number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_template_canvas;
  --
  -- Truncate the time portion from all IN date parameters
  --
     -- p_effective_date := TRUNC(p_effective_date);
  --
  -- Call Before Process User Hook
  --
  begin
    hr_template_canvases_api_bk2.create_template_canvas_b
      (p_effective_date                 => TRUNC(p_effective_date)
      ,p_template_window_id             => p_template_window_id
      ,p_form_canvas_id                 => p_form_canvas_id
      ,p_height                         => p_height
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
      ,p_information30                  => p_information30);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_template_canvas'
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

  hr_tcn_ins.ins(p_template_window_id           => p_template_window_id
             ,p_form_canvas_id               => p_form_canvas_id
             ,p_template_canvas_id           => l_template_canvas_id
             ,p_object_version_number        => l_object_version_number);

  hr_utility.set_location('At:'|| l_proc, 25);

  OPEN cur_canvas_type;
  FETCH cur_canvas_type INTO l_canvas_type;
  CLOSE cur_canvas_type;

  hr_utility.set_location('At:'|| l_proc, 30);

  IF l_canvas_type = 'CONTENT' THEN
          OPEN cur_tmplt_window;
          FETCH cur_tmplt_window INTO l_height , l_width;
          CLOSE cur_tmplt_window;
  ELSE
     l_height := p_height;
     l_width := p_width;
  END IF;

  hr_utility.set_location('At:'|| l_proc, 35);

  hr_canvas_properties_bsi.copy_canvas_property(
              p_effective_date               => TRUNC(p_effective_date)
             ,p_form_canvas_id               => p_form_canvas_id
             ,p_template_canvas_id           => l_template_canvas_id
             ,p_height                       => l_height
             ,p_visible                      => p_visible
             ,p_width                        => l_width
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
             ,p_canvas_property_id           => l_canvas_property_id
             ,p_object_version_number        => l_object_version_number);

  hr_utility.set_location('At:'|| l_proc, 40);

  --
  -- Call After Process User Hook
  --
  begin
    hr_template_canvases_api_bk2.create_template_canvas_a
      (p_effective_date                 => TRUNC(p_effective_date)
      ,p_template_window_id             => p_template_window_id
      ,p_form_canvas_id                 => p_form_canvas_id
      ,p_height                         => p_height
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
      ,p_template_canvas_id             => p_template_canvas_id
      ,p_object_version_number          => p_object_version_number);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_template_canvas'
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
  -- Set all output arguments
  --
     p_template_canvas_id             := l_template_canvas_id;
     p_object_version_number          := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_template_canvas;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_template_canvas_id             := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_template_canvas_id             := null;
    p_object_version_number  := null;

    rollback to create_template_canvas;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_template_canvas;
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_template_canvas >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_template_canvas
  (p_validate                      in     boolean  default false
  ,p_template_canvas_id            in number
  ,p_delete_children_flag          in varchar2 default 'N'
  ,p_object_version_number         in number
  ) is
  --
  -- Declare cursors and local variables
  --
  CURSOR cur_tmplt_tab
  IS
  SELECT template_tab_page_id
  ,object_version_number
  FROM hr_template_tab_pages
  WHERE template_canvas_id = p_template_canvas_id;

  l_temp number;

  CURSOR cur_api_val
  IS
  SELECT source_form_template_id
  FROM hr_source_form_templates hsf
       ,hr_template_canvases_b htc
       ,hr_template_windows_b htw
  WHERE hsf.form_template_id_to = htw.form_template_id
  AND htw.template_window_id = htc.template_window_id
  AND htc.template_canvas_id = p_template_canvas_id;

  l_proc                varchar2(72) := g_package||'delete_template_canvas';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_template_canvas;
  --
  -- Call Before Process User Hook
  --
  begin
    hr_template_canvases_api_bk3.delete_template_canvas_b
          (p_template_canvas_id           => p_template_canvas_id
           ,p_delete_children_flag        => p_delete_children_flag
           ,p_object_version_number       => p_object_version_number
          );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_template_canvas'
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

  IF p_delete_children_flag = 'Y' THEN

    FOR cur_rec IN cur_tmplt_tab  LOOP

      hr_template_tab_pages_api.delete_template_tab_page(
                p_template_tab_page_id         => cur_rec.template_tab_page_id
                ,p_object_version_number        => cur_rec.object_version_number
                ,p_delete_children_flag         => p_delete_children_flag);
    END LOOP;
  END IF;

  hr_utility.set_location('At:'|| l_proc, 30);

  hr_canvas_properties_bsi.delete_canvas_property(
             p_template_canvas_id           => p_template_canvas_id
             ,p_object_version_number        => p_object_version_number);

  hr_utility.set_location('At:'|| l_proc, 35);

  hr_tcn_del.del(
             p_template_canvas_id           => p_template_canvas_id
             ,p_object_version_number        => p_object_version_number);

  hr_utility.set_location('At:'|| l_proc, 40);

  --
  -- Call After Process User Hook
  --
  begin
    hr_template_canvases_api_bk3.delete_template_canvas_a
          (p_template_canvas_id           => p_template_canvas_id
           ,p_delete_children_flag        => p_delete_children_flag
           ,p_object_version_number       => p_object_version_number
          );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_template_canvas'
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
    rollback to delete_template_canvas;
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
    rollback to delete_template_canvas;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_template_canvas;
--
-- ----------------------------------------------------------------------------
-- |----------------------< update_template_canvas >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_template_canvas
  (p_validate                        in boolean  default false
  ,p_effective_date                  in date
-- ask john
--,p_language_code                   in varchar2 default hr_api.userenv_lang
  ,p_template_canvas_id              in number
  ,p_object_version_number           in out nocopy number
  ,p_height                          in number default hr_api.g_number
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
  ) is
  --
  -- Declare cursors and local variables
  --

  l_temp number;

  CURSOR cur_api_val
  IS
  SELECT source_form_template_id
  FROM hr_source_form_templates hsf
       ,hr_template_canvases_b htc
       ,hr_template_windows_b htw
  WHERE hsf.form_template_id_to = htw.form_template_id
  AND htw.template_window_id = htc.template_window_id
  AND htc.template_canvas_id = p_template_canvas_id;

  l_proc                varchar2(72) := g_package||'update_template_canvas';
  l_object_version_number number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_template_canvas;
  --
  -- Truncate the time portion from all IN date parameters
  --
     -- p_effective_date := TRUNC(p_effective_date);
     l_object_version_number := p_object_version_number;
  --
  -- Call Before Process User Hook
  --
  begin
    hr_template_canvases_api_bk4.update_template_canvas_b
      (p_effective_date                 => TRUNC(p_effective_date)
      ,p_template_canvas_id             => p_template_canvas_id
      ,p_object_version_number          => l_object_version_number
      ,p_height                         => p_height
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
      ,p_information30                  => p_information30);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_template_canvas'
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

  hr_canvas_properties_bsi.update_canvas_property(
             p_effective_date                => TRUNC(p_effective_date)
             ,p_object_version_number        => l_object_version_number
             ,p_template_canvas_id           => p_template_canvas_id
             ,p_height                       => p_height
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
             ,p_information30                => p_information30);

  hr_utility.set_location('At:'|| l_proc, 30);

  --
  -- Call After Process User Hook
  --
  begin
    hr_template_canvases_api_bk4.update_template_canvas_a
      (p_effective_date                 => TRUNC(p_effective_date)
      ,p_template_canvas_id             => p_template_canvas_id
      ,p_object_version_number          => l_object_version_number
      ,p_height                         => p_height
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
      ,p_information30                  => p_information30);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_template_canvas'
        ,p_hook_type   => 'AP'
        );
  end;
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
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_template_canvas;
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
    rollback to update_template_canvas;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_template_canvas;
--
end hr_template_canvases_api;

/
