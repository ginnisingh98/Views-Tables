--------------------------------------------------------
--  DDL for Package Body HR_TEMPLATE_WINDOWS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_TEMPLATE_WINDOWS_API" as
/* $Header: hrtwuapi.pkb 115.5 2003/03/06 17:15:52 adhunter noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_template_windows_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< copy_template_window >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure copy_template_window
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_language_code                 in     varchar2 default hr_api.userenv_lang
  ,p_template_window_id_from       in     number
  ,p_form_template_id              in     number
  ,p_template_window_id_to           out nocopy  number
  ,p_object_version_number           out nocopy  number
  ) is
  --
  -- Declare cursors and local variables
  --

  CURSOR cur_form_window
  IS
  SELECT twn.form_window_id
  FROM hr_template_windows twn
  WHERE twn.template_window_id = p_template_window_id_from;

  CURSOR cur_tmplt_canvas
  IS
  SELECT tcn.template_canvas_id
  FROM hr_template_canvases tcn
  WHERE tcn.template_window_id = p_template_window_id_from;

  l_temp number;

  CURSOR cur_api_val
  IS
  SELECT 1 from dual where exists(   --added line for 2832106
   SELECT source_form_template_id
   FROM hr_source_form_templates hsf
   WHERE hsf.form_template_id_to = p_form_template_id);

  l_template_canvas_id_to number;
  l_ovn_canvas number;
  l_form_window_id number;
  l_window_property_id number;
  l_template_window_id_to number;
  l_object_version_number number;
  l_language_code fnd_languages.language_code%TYPE;

  l_proc                varchar2(72) := g_package||'copy_template_window';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint copy_template_window;
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
    hr_template_windows_api_bk1.copy_template_window_b
      (p_effective_date               => TRUNC(p_effective_date)
      ,p_language_code                => l_language_code
      ,p_template_window_id_from      => p_template_window_id_from
      ,p_form_template_id             => p_form_template_id);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'copy_template_window'
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

  hr_utility.set_location('At:'|| l_proc, 20);

  OPEN cur_form_window;
  FETCH cur_form_window INTO l_form_window_id;
  CLOSE cur_form_window;

  hr_utility.set_location('At:'|| l_proc, 25);

  hr_twn_ins.ins( p_form_template_id             => p_form_template_id
            ,p_form_window_id               => l_form_window_id
            ,p_template_window_id           => l_template_window_id_to
            ,p_object_version_number        => l_object_version_number);

  hr_utility.set_location('At:'|| l_proc, 30);

  hr_window_properties_bsi.copy_window_property(
            p_effective_date                => TRUNC(p_effective_date)
            ,p_language_code                => l_language_code
            ,p_template_window_id_from      => p_template_window_id_from
            ,p_template_window_id_to        => l_template_window_id_to
            ,p_window_property_id           => l_window_property_id);

  hr_utility.set_location('At:'|| l_proc, 35);

  FOR cur_rec in cur_tmplt_canvas LOOP

    hr_template_canvases_api.copy_template_canvas(
               p_effective_date                => TRUNC(p_effective_date)
               ,p_language_code                 => l_language_code
               ,p_template_canvas_id_from      => cur_rec.template_canvas_id
               ,p_template_window_id           => l_template_window_id_to
               ,p_template_canvas_id_to        => l_template_canvas_id_to
               ,p_object_version_number        => l_ovn_canvas);
  END LOOP;
  --
  -- Call After Process User Hook
  --
  hr_utility.set_location('At:'|| l_proc, 40);

  begin
    hr_template_windows_api_bk1.copy_template_window_a
      (p_effective_date               => TRUNC(p_effective_date)
      ,p_language_code                => l_language_code
      ,p_template_window_id_from      => p_template_window_id_from
      ,p_form_template_id             => p_form_template_id
      ,p_template_window_id_to        => l_template_window_id_to
      ,p_object_version_number        => l_object_version_number);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'copy_template_window'
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
  p_template_window_id_to        := l_template_window_id_to;
  p_object_version_number        := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to copy_template_window;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_template_window_id_to        := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_template_window_id_to        := null;
    p_object_version_number  := null;

    rollback to copy_template_window;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end copy_template_window;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_template_window >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_template_window
  (p_validate                        in boolean  default false
  ,p_effective_date                  in date
  ,p_language_code                   in varchar2 default hr_api.userenv_lang
  ,p_form_template_id                in number
  ,p_form_window_id                  in number
  ,p_height                          in number default hr_api.g_number
  ,p_title                           in varchar2 default hr_api.g_varchar2
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
  ,p_template_window_id                out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_temp number;

  CURSOR cur_api_val
  IS
  SELECT 1 from dual where exists(   --added line for 2832106, removed unnecessary joins
   SELECT source_form_template_id
   FROM hr_source_form_templates hsf
   --     ,hr_template_windows_b htw
   --     ,hr_template_canvases_b htc
   --     ,hr_template_tab_pages_b http
   WHERE hsf.form_template_id_to = p_form_template_id);

  CURSOR csr_form_canvases
    (p_form_window_id IN NUMBER
    )
  IS
    SELECT fcn.form_canvas_id
      FROM hr_form_canvases_b fcn
     WHERE fcn.canvas_type = 'CONTENT'
       AND fcn.form_window_id = p_form_window_id;

  l_window_property_id number;
  l_template_window_id number;
  l_object_version_number number;
  l_proc                varchar2(72) := g_package||'create_template_window';
  l_language_code fnd_languages.language_code%TYPE;
  l_template_canvas_id number;
  l_tcn_object_version_number number;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_template_window;
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
    hr_template_windows_api_bk2.create_template_window_b
      (p_effective_date                  => TRUNC(p_effective_date)
      ,p_language_code                   => l_language_code
      ,p_form_template_id                => p_form_template_id
      ,p_form_window_id                  => p_form_window_id
      ,p_height                          => p_height
      ,p_title                           => p_title
      ,p_width                           => p_width
      ,p_x_position                      => p_x_position
      ,p_y_position                      => p_y_position
      ,p_information_category            => p_information_category
      ,p_information1                    => p_information1
      ,p_information2                    => p_information2
      ,p_information3                    => p_information3
      ,p_information4                    => p_information4
      ,p_information5                    => p_information5
      ,p_information6                    => p_information6
      ,p_information7                    => p_information7
      ,p_information8                    => p_information8
      ,p_information9                    => p_information9
      ,p_information10                   => p_information10
      ,p_information11                   => p_information11
      ,p_information12                   => p_information12
      ,p_information13                   => p_information13
      ,p_information14                   => p_information14
      ,p_information15                   => p_information15
      ,p_information16                   => p_information16
      ,p_information17                   => p_information17
      ,p_information18                   => p_information18
      ,p_information19                   => p_information19
      ,p_information20                   => p_information20
      ,p_information21                   => p_information21
      ,p_information22                   => p_information22
      ,p_information23                   => p_information23
      ,p_information24                   => p_information24
      ,p_information25                   => p_information25
      ,p_information26                   => p_information26
      ,p_information27                   => p_information27
      ,p_information28                   => p_information28
      ,p_information29                   => p_information29
      ,p_information30                   => p_information30);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_template_window'
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

  hr_twn_ins.ins( p_form_template_id             => p_form_template_id
                  ,p_form_window_id               => p_form_window_id
                  ,p_template_window_id           => l_template_window_id
                  ,p_object_version_number        => l_object_version_number);

  hr_utility.set_location('At:'|| l_proc, 25);

  hr_window_properties_bsi.copy_window_property(
            p_effective_date                => TRUNC(p_effective_date)
            ,p_language_code                => l_language_code
            ,p_form_window_id               => p_form_window_id
            ,p_template_window_id           => l_template_window_id
            ,p_height                       => p_height
            ,p_title                        => p_title
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
            ,p_window_property_id           => l_window_property_id);

  --
  -- Create content canvases
  --
  FOR l_form_canvas IN csr_form_canvases(p_form_window_id)
  LOOP
    hr_template_canvases_api.create_template_canvas
      (p_effective_date                   => TRUNC(p_effective_date)
      ,p_template_window_id               => l_template_window_id
      ,p_form_canvas_id                   => l_form_canvas.form_canvas_id
      ,p_height                           => p_height
      ,p_width                            => p_width
      ,p_template_canvas_id               => l_template_canvas_id
      ,p_object_version_number            => l_tcn_object_version_number
      );
  END LOOP;
  --
  -- Call After Process User Hook
  --
  hr_utility.set_location('At:'|| l_proc, 30);

  begin
    hr_template_windows_api_bk2.create_template_window_a
      (p_effective_date                  => TRUNC(p_effective_date)
      ,p_language_code                   => l_language_code
      ,p_form_template_id                => p_form_template_id
      ,p_form_window_id                  => p_form_window_id
      ,p_height                          => p_height
      ,p_title                           => p_title
      ,p_width                           => p_width
      ,p_x_position                      => p_x_position
      ,p_y_position                      => p_y_position
      ,p_information_category            => p_information_category
      ,p_information1                    => p_information1
      ,p_information2                    => p_information2
      ,p_information3                    => p_information3
      ,p_information4                    => p_information4
      ,p_information5                    => p_information5
      ,p_information6                    => p_information6
      ,p_information7                    => p_information7
      ,p_information8                    => p_information8
      ,p_information9                    => p_information9
      ,p_information10                   => p_information10
      ,p_information11                   => p_information11
      ,p_information12                   => p_information12
      ,p_information13                   => p_information13
      ,p_information14                   => p_information14
      ,p_information15                   => p_information15
      ,p_information16                   => p_information16
      ,p_information17                   => p_information17
      ,p_information18                   => p_information18
      ,p_information19                   => p_information19
      ,p_information20                   => p_information20
      ,p_information21                   => p_information21
      ,p_information22                   => p_information22
      ,p_information23                   => p_information23
      ,p_information24                   => p_information24
      ,p_information25                   => p_information25
      ,p_information26                   => p_information26
      ,p_information27                   => p_information27
      ,p_information28                   => p_information28
      ,p_information29                   => p_information29
      ,p_information30                   => p_information30
      ,p_template_window_id              => l_template_window_id
      ,p_object_version_number           => l_object_version_number);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_template_window'
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
    p_template_window_id              := l_template_window_id;
    p_object_version_number           := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_template_window;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_template_window_id     := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_template_window_id     := null;
    p_object_version_number  := null;

    rollback to create_template_window;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_template_window;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_template_window >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_template_window
  (p_validate                      in     boolean  default false
  ,p_template_window_id            in     number
  ,p_object_version_number         in     number
  ,p_delete_children_flag          in     varchar2 default 'N'
  ) is
  --
  -- Declare cursors and local variables
  --

  CURSOR csr_template_canvases
  IS
    SELECT tcn.template_canvas_id
          ,tcn.object_version_number
      FROM hr_template_canvases_b tcn
          ,hr_form_canvases_b fcn
     WHERE tcn.template_window_id = p_template_window_id
       AND tcn.form_canvas_id = fcn.form_canvas_id
       AND fcn.canvas_type = 'CONTENT';

  CURSOR cur_tmplt_canvas
  IS
  SELECT template_canvas_id
  ,object_version_number
  FROM hr_template_canvases
  WHERE template_window_id = p_template_window_id;

  l_temp number;

  CURSOR cur_api_val
  IS
  SELECT 1 from dual where exists(   --added line for 2832106
   SELECT source_form_template_id
   FROM hr_source_form_templates hsf
        ,hr_template_windows_b htw
   WHERE hsf.form_template_id_to = htw.form_template_id
   AND htw.template_window_id = p_template_window_id);

l_proc                varchar2(72) := g_package||'delete_template_window';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_template_window;
  --
  -- Call Before Process User Hook
  --
  begin
    hr_template_windows_api_bk3.delete_template_window_b
      (p_template_window_id              => p_template_window_id
      ,p_object_version_number           => p_object_version_number
      ,p_delete_children_flag            => p_delete_children_flag);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_template_window'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  hr_utility.set_location('At:'|| l_proc, 35);

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
  hr_utility.set_location('At:'|| l_proc, 40);

  hr_twn_shd.lck( p_template_window_id           => p_template_window_id
             ,p_object_version_number        => p_object_version_number);

  hr_utility.set_location('At:'|| l_proc, 45);

  --
  -- Delete content canvases
  --
  FOR l_template_canvas IN csr_template_canvases
  LOOP
    hr_template_canvases_api.delete_template_canvas
      (p_template_canvas_id      => l_template_canvas.template_canvas_id
      ,p_object_version_number   => l_template_canvas.object_version_number
      ,p_delete_children_flag    => p_delete_children_flag
      );
  END LOOP;
  --
  IF p_delete_children_flag = 'Y'  THEN
    FOR cur_rec IN cur_tmplt_canvas LOOP
      hr_template_canvases_api.delete_template_canvas(
                p_template_canvas_id           => cur_rec.template_canvas_id
                ,p_object_version_number        => cur_rec.object_version_number
                ,p_delete_children_flag         => p_delete_children_flag);
    END LOOP;
  END IF;
  hr_utility.set_location('At:'|| l_proc, 50);

  hr_window_properties_bsi.delete_window_property(
             p_template_window_id           => p_template_window_id);

  hr_utility.set_location('At:'|| l_proc, 55);

  hr_twn_del.del( p_template_window_id           => p_template_window_id
                 ,p_object_version_number        => p_object_version_number);

  hr_utility.set_location('At:'|| l_proc, 60);

  --
  -- Call After Process User Hook
  --
  begin
    hr_template_windows_api_bk3.delete_template_window_a
      (p_template_window_id              => p_template_window_id
      ,p_object_version_number           => p_object_version_number
      ,p_delete_children_flag            => p_delete_children_flag);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_template_window'
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
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_template_window;
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
    rollback to delete_template_window;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_template_window;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_template_window >----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_template_window
  (p_validate                        in boolean  default false
  ,p_effective_date                  in date
  ,p_language_code                   in varchar2 default hr_api.userenv_lang
  ,p_template_window_id              in number
  ,p_object_version_number           in out nocopy number
  ,p_height                          in number default hr_api.g_number
  ,p_title                           in varchar2 default hr_api.g_varchar2
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

  CURSOR cur_tmplt_canvas
  IS
  SELECT tcn.template_canvas_id
  ,tcn.object_version_number
  ,twn.height
  ,twn.width
  FROM hr_template_windows twn
  ,hr_form_canvases fcn
  ,hr_template_canvases tcn
  WHERE twn.template_window_id = p_template_window_id
  AND fcn.canvas_type = 'CONTENT'
  AND fcn.form_canvas_id = tcn.form_canvas_id
  AND tcn.template_window_id = p_template_window_id;

  l_temp number;

  CURSOR cur_api_val
  IS
  SELECT 1 from dual where exists(   --added line for 2832106, removed unnecessary joins
   SELECT source_form_template_id
   FROM hr_source_form_templates hsf
        ,hr_template_windows_b htw
   --     ,hr_template_canvases_b htc
   --     ,hr_template_tab_pages_b http
   WHERE hsf.form_template_id_to = htw.form_template_id
   AND htw.template_window_id = p_template_window_id);

  l_proc                varchar2(72) := g_package||'update_template_window';
  l_object_version_number number;
  l_language_code fnd_languages.language_code%TYPE;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_template_window;
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
    hr_template_windows_api_bk4.update_template_window_b
      (p_effective_date                 => TRUNC(p_effective_date)
      ,p_language_code                  => l_language_code
      ,p_template_window_id             => p_template_window_id
      ,p_object_version_number          => l_object_version_number
      ,p_height                         => p_height
      ,p_title                          => p_title
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
        (p_module_name => 'update_template_window'
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

  hr_twn_shd.lck( p_template_window_id           => p_template_window_id
             ,p_object_version_number        => p_object_version_number);

  hr_utility.set_location('At:'|| l_proc, 25);

  hr_window_properties_bsi.update_window_property(
             p_effective_date                => TRUNC(p_effective_date)
             ,p_language_code                => l_language_code
             ,p_template_window_id           => p_template_window_id
             ,p_height                       => p_height
             ,p_title                        => p_title
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

  FOR cur_rec IN cur_tmplt_canvas LOOP

    hr_template_canvases_api.update_template_canvas(
              p_effective_date                => TRUNC(p_effective_date)
              ,p_template_canvas_id            => cur_rec.template_canvas_id
              ,p_height                       => cur_rec.height
              ,p_width                        => cur_rec.width
              ,p_object_version_number        => cur_rec.object_version_number);

  END LOOP;

  hr_utility.set_location('At:'|| l_proc, 35);

  --
  -- Call After Process User Hook
  --
  begin
    hr_template_windows_api_bk4.update_template_window_a
      (p_effective_date                 => TRUNC(p_effective_date)
      ,p_language_code                  => l_language_code
      ,p_template_window_id             => p_template_window_id
      ,p_object_version_number          => l_object_version_number
      ,p_height                         => p_height
      ,p_title                          => p_title
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
        (p_module_name => 'update_template_window'
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
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_template_window;
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
    rollback to update_template_window;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_template_window;
--
end hr_template_windows_api;

/
