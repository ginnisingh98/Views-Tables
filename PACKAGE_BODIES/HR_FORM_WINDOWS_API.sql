--------------------------------------------------------
--  DDL for Package Body HR_FORM_WINDOWS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_FORM_WINDOWS_API" as
/* $Header: hrfwnapi.pkb 115.3 2002/12/16 10:18:35 hjonnala noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_form_windows_api.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_form_window >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_form_window
  (p_validate                    in     boolean  default false
  ,p_effective_date              in     date
  ,p_language_code               in varchar2 default hr_api.userenv_lang
  ,p_application_id              in number
  ,p_form_id                     in number
  ,p_window_name                 in varchar2
  ,p_user_window_name            in varchar2
  ,p_description                 in varchar2 default null
  ,p_height                      in number default null
  ,p_title                       in varchar2 default null
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
  ,p_form_window_id                out nocopy number
  ,p_object_version_number         out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'create_form_window';
  l_window_property_id number;
  l_form_window_id   number;
  l_object_version_number number;
  l_language_code fnd_languages.language_code%TYPE;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_form_window;
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
    hr_form_windows_api_bk1.create_form_window_b
      (p_effective_date             => TRUNC(p_effective_date)
      ,p_language_code              => l_language_code
      ,p_application_id             => p_application_id
      ,p_form_id                    => p_form_id
      ,p_window_name                => p_window_name
      ,p_user_window_name           => p_user_window_name
      ,p_description                => p_description
      ,p_height                     => p_height
      ,p_title                      => p_title
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
      ,p_information30              => p_information30);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_form_window'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  hr_utility.set_location('At:'|| l_proc, 15);

  hr_fwn_ins.ins( p_application_id               => p_application_id
                 ,p_form_id                      => p_form_id
                 ,p_window_name                  => p_window_name
                 ,p_form_window_id               => l_form_window_id
                 ,p_object_version_number        => l_object_version_number);

  hr_utility.set_location('At:'|| l_proc, 20);

  hr_fwt_ins.ins_tl(p_language_code                => l_language_code
                      ,p_form_window_id               => l_form_window_id
                      ,p_user_window_name             => p_user_window_name
                      ,p_description                  => p_description);

  hr_utility.set_location('At:'|| l_proc, 25);

  hr_window_properties_bsi.create_window_property(
            p_effective_date                => TRUNC(p_effective_date)
            ,p_language_code                 => l_language_code
            ,p_form_window_id               => l_form_window_id
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
  -- Call After Process User Hook
  --
  hr_utility.set_location('At:'|| l_proc, 30);

  begin
    hr_form_windows_api_bk1.create_form_window_a
      (p_effective_date             => TRUNC(p_effective_date)
      ,p_language_code              => l_language_code
      ,p_application_id             => p_application_id
      ,p_form_id                    => p_form_id
      ,p_window_name                => p_window_name
      ,p_user_window_name           => p_user_window_name
      ,p_description                => p_description
      ,p_height                     => p_height
      ,p_title                      => p_title
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
      ,p_form_window_id             => l_form_window_id
      ,p_object_version_number      => l_object_version_number);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_form_window'
        ,p_hook_type   => 'AP'
        );
  end;
  hr_utility.set_location('At:'|| l_proc, 35);

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_form_window_id := l_form_window_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_form_window;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_form_window_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_form_window;
    -- Set OUT parameters.
    p_form_window_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_form_window;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_form_window >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_form_window
  (p_validate                      in boolean  default false
  ,p_form_window_id                in number
  ,p_object_version_number         in number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'delete_form_window';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_form_window;

  --
  -- Call Before Process User Hook
  --
  begin
    hr_form_windows_api_bk2.delete_form_window_b(
         p_form_window_id => p_form_window_id
         ,p_object_version_number => p_object_version_number );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_form_window'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --

  hr_utility.set_location('At:'|| l_proc, 20);

  hr_fwn_shd.lck( p_form_window_id               => p_form_window_id
                 ,p_object_version_number        => p_object_version_number);

  hr_utility.set_location('At:'|| l_proc, 25);

  hr_window_properties_bsi.delete_window_property
            (p_form_window_id => p_form_window_id);

  hr_utility.set_location('At:'|| l_proc, 30);

  hr_fwt_del.del_tl( p_form_window_id => p_form_window_id);

  hr_utility.set_location('At:'|| l_proc, 40);

  hr_fwn_del.del( p_form_window_id  => p_form_window_id
                 ,p_object_version_number => p_object_version_number);

  hr_utility.set_location('At:'|| l_proc, 45);

  --
  -- Call After Process User Hook
  --
  begin
    hr_form_windows_api_bk2.delete_form_window_a(
         p_form_window_id => p_form_window_id
         ,p_object_version_number => p_object_version_number );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_form_window'
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
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_form_window;
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
    rollback to delete_form_window;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_form_window;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_form_window >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_form_window
  (p_validate                    in     boolean  default false
  ,p_effective_date              in     date
  ,p_language_code               in varchar2 default hr_api.userenv_lang
  --,p_application_id              in number default hr_api.g_number
  --,p_form_id                     in number default hr_api.g_number
  ,p_form_window_id              in number
  ,p_object_version_number       in out nocopy number
  ,p_window_name                 in varchar2  default hr_api.g_varchar2
  ,p_user_window_name            in varchar2 default hr_api.g_varchar2
  ,p_description                 in varchar2 default hr_api.g_varchar2
  ,p_height                      in number default hr_api.g_number
  ,p_title                       in varchar2 default hr_api.g_varchar2
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
  ) is
  --
  -- Declare cursors and local variables
  --

  CURSOR cur_form_canvas
  IS
  SELECT fcn.form_canvas_id
    ,fcn.object_version_number
    ,fwn.height
    ,fwn.width
  FROM hr_form_canvases fcn
    ,hr_form_windows fwn
  WHERE fcn.canvas_type = 'CONTENT'
  AND fcn.form_window_id = fwn.form_window_id
  AND fwn.form_window_id = p_form_window_id;

  l_proc                varchar2(72) := g_package||'update_form_window';
  l_object_version_number number;
  l_language_code fnd_languages.language_code%TYPE;
  l_temp_ovn   number := p_object_version_number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_form_window;
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
    hr_form_windows_api_bk3.update_form_window_b
     (p_effective_date             => TRUNC(p_effective_date)
     ,p_language_code              => l_language_code
     --,p_application_id             => p_application_id
     --,p_form_id                    => p_form_id
     ,p_form_window_id             => p_form_window_id
     ,p_object_version_number      => l_object_version_number
     ,p_window_name                => p_window_name
     ,p_user_window_name           => p_user_window_name
     ,p_description                => p_description
     ,p_height                     => p_height
     ,p_title                      => p_title
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
     ,p_information30              => p_information30);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_form_window'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  hr_utility.set_location('At:'|| l_proc, 20);

  hr_fwn_upd.upd(p_form_window_id                => p_form_window_id
                 --,p_application_id               => p_application_id
                 --,p_form_id                      => p_form_id
                 ,p_window_name                  => p_window_name
                 ,p_object_version_number        => l_object_version_number);

  hr_utility.set_location('At:'|| l_proc, 25);

  hr_fwt_upd.upd_tl(p_language_code                => l_language_code
                      ,p_form_window_id               => p_form_window_id
                      ,p_user_window_name             => p_user_window_name
                      ,p_description                  => p_description);

  hr_utility.set_location('At:'|| l_proc, 30);

  hr_window_properties_bsi.update_window_property(
            p_effective_date                => TRUNC(p_effective_date)
            ,p_language_code                => l_language_code
            ,p_form_window_id               => p_form_window_id
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

  hr_utility.set_location('At:'|| l_proc, 35);

   FOR cur_rec in cur_form_canvas LOOP
     hr_form_canvases_api.update_form_canvas(
               p_effective_date                => TRUNC(p_effective_date)
               ,p_form_canvas_id               => cur_rec.form_canvas_id
               ,p_height                       => cur_rec.height
               ,p_width                        => cur_rec.width
               ,p_object_version_number        => cur_rec.object_version_number
               );
   END LOOP;

  hr_utility.set_location('At:'|| l_proc, 40);

  --
  -- Call After Process User Hook
  --
  begin
    hr_form_windows_api_bk3.update_form_window_a
     (p_effective_date             => TRUNC(p_effective_date)
     ,p_language_code              => l_language_code
     --,p_application_id             => p_application_id
     --,p_form_id                    => p_form_id
     ,p_form_window_id             => p_form_window_id
     ,p_object_version_number      => l_object_version_number
     ,p_window_name                => p_window_name
     ,p_user_window_name           => p_user_window_name
     ,p_description                => p_description
     ,p_height                     => p_height
     ,p_title                      => p_title
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
     ,p_information30              => p_information30);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_form_window'
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
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_form_window;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    -- Reset all out arguments
    --
    p_object_version_number  := l_temp_ovn;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_form_window;
    -- Reset all in out arguments
    --
    p_object_version_number  := l_temp_ovn;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_form_window;
--
end hr_form_windows_api;

/
