--------------------------------------------------------
--  DDL for Package Body HR_FORM_CANVASES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_FORM_CANVASES_API" as
/* $Header: hrfcnapi.pkb 115.4 2003/09/24 02:02:48 bsubrama noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_form_canvases_api.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_form_canvas >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_form_canvas
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_language_code                in     varchar2 default hr_api.userenv_lang
  ,p_form_window_id               in     number
  ,p_canvas_name                  in     varchar2
  ,p_canvas_type                  in     varchar2
  ,p_user_canvas_name             in     varchar2
  ,p_description                  in     varchar2 default null
  ,p_height                       in     number default null
  ,p_visible                      in     number default null
  ,p_width                        in     number default null
  ,p_x_position                   in     number default null
  ,p_y_position                   in     number default null
  ,p_information_category         in     varchar2 default null
  ,p_information1                 in     varchar2 default null
  ,p_information2                 in     varchar2 default null
  ,p_information3                 in     varchar2 default null
  ,p_information4                 in     varchar2 default null
  ,p_information5                 in     varchar2 default null
  ,p_information6                 in     varchar2 default null
  ,p_information7                 in     varchar2 default null
  ,p_information8                 in     varchar2 default null
  ,p_information9                 in     varchar2 default null
  ,p_information10                in     varchar2 default null
  ,p_information11                in     varchar2 default null
  ,p_information12                in     varchar2 default null
  ,p_information13                in     varchar2 default null
  ,p_information14                in     varchar2 default null
  ,p_information15                in     varchar2 default null
  ,p_information16                in     varchar2 default null
  ,p_information17                in     varchar2 default null
  ,p_information18                in     varchar2 default null
  ,p_information19                in     varchar2 default null
  ,p_information20                in     varchar2 default null
  ,p_information21                in     varchar2 default null
  ,p_information22                in     varchar2 default null
  ,p_information23                in     varchar2 default null
  ,p_information24                in     varchar2 default null
  ,p_information25                in     varchar2 default null
  ,p_information26                in     varchar2 default null
  ,p_information27                in     varchar2 default null
  ,p_information28                in     varchar2 default null
  ,p_information29                in     varchar2 default null
  ,p_information30                in     varchar2 default null
  ,p_form_canvas_id               out nocopy    number
  ,p_object_version_number        out nocopy    number)
is
  --
  -- Declare cursors and local variables
  --

  CURSOR cur_form_window
  IS
  SELECT NVL(p_height,fwn.height)
        ,NVL(p_width,fwn.width)
  FROM hr_form_windows fwn
  WHERE fwn.form_window_id = p_form_window_id;

  l_proc                varchar2(72) := g_package||'create_form_canvas';
  l_form_canvas_id      number;
  l_canvas_property_id  number;
  l_object_version_number number;

  l_language_code fnd_languages.language_code%TYPE;
  l_height number;
  l_width number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_form_canvas;
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
  -- Call Before Process User Hook
  --
  begin

    hr_form_canvases_api_bk1.create_form_canvas_b
      (p_effective_date              => TRUNC(p_effective_date)
       ,p_language_code              => l_language_code
       ,p_form_window_id             => p_form_window_id
       ,p_canvas_name                => p_canvas_name
       ,p_canvas_type                => p_canvas_type
       ,p_user_canvas_name           => p_user_canvas_name
       ,p_description                => p_description
       ,p_height                     => p_height
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
       ,p_information30              => p_information30);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_form_canvas'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --

  hr_utility.set_location('At:'|| l_proc, 20);

   hr_fcn_ins.ins(
     p_effective_date               => TRUNC(p_effective_date)
     ,p_form_window_id               => p_form_window_id
     ,p_canvas_name                  => p_canvas_name
     ,p_canvas_type                  => p_canvas_type
     ,p_form_canvas_id               => l_form_canvas_id
     ,p_object_version_number        => l_object_version_number);

  hr_utility.set_location('At:'|| l_proc, 25);

   hr_fct_ins.ins_tl(
     --p_effective_date                => TRUNC(p_effective_date)
     p_language_code                => l_language_code
     ,p_form_canvas_id               => l_form_canvas_id
     ,p_user_canvas_name             => p_user_canvas_name
     ,p_description                  => p_description);

  hr_utility.set_location('At:'|| l_proc, 30);

   IF p_canvas_type = 'CONTENT' then
     OPEN cur_form_window;
     FETCH cur_form_window into l_height , l_width;
     CLOSE cur_form_window;
   END IF;

  hr_utility.set_location('At:'|| l_proc, 40);

  hr_canvas_properties_bsi.create_canvas_property(
      p_effective_date                => TRUNC(p_effective_date)
      ,p_form_canvas_id               => l_form_canvas_id
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

  --
  -- Call After Process User Hook
  --
  hr_utility.set_location('At:'|| l_proc, 45);


  begin

    hr_form_canvases_api_bk1.create_form_canvas_a
       (p_effective_date           => TRUNC(p_effective_date)
       ,p_language_code            => l_language_code
       ,p_form_window_id           => p_form_window_id
       ,p_canvas_name              => p_canvas_name
       ,p_canvas_type              => p_canvas_type
       ,p_user_canvas_name         => p_user_canvas_name
       ,p_description              => p_description
       ,p_height                   => p_height
       ,p_visible                  => p_visible
       ,p_width                    => p_width
       ,p_x_position               => p_x_position
       ,p_y_position               => p_y_position
       ,p_information_category     => p_information_category
       ,p_information1             => p_information1
       ,p_information2             => p_information2
       ,p_information3             => p_information3
       ,p_information4             => p_information4
       ,p_information5             => p_information5
       ,p_information6             => p_information6
       ,p_information7             => p_information7
       ,p_information8             => p_information8
       ,p_information9             => p_information9
       ,p_information10            => p_information10
       ,p_information11            => p_information11
       ,p_information12            => p_information12
       ,p_information13            => p_information13
       ,p_information14            => p_information14
       ,p_information15            => p_information15
       ,p_information16            => p_information16
       ,p_information17            => p_information17
       ,p_information18            => p_information18
       ,p_information19            => p_information19
       ,p_information20            => p_information20
       ,p_information21            => p_information21
       ,p_information22            => p_information22
       ,p_information23            => p_information23
       ,p_information24            => p_information24
       ,p_information25            => p_information25
       ,p_information26            => p_information26
       ,p_information27            => p_information27
       ,p_information28            => p_information28
       ,p_information29            => p_information29
       ,p_information30            => p_information30
       ,p_form_canvas_id           => l_form_canvas_id
       ,p_object_version_number    => l_object_version_number);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_form_canvas'
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
  p_form_canvas_id         := l_form_canvas_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_form_canvas;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_form_canvas_id         := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --

    rollback to create_form_canvas;
    -- Reset out parameters
    p_form_canvas_id         := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_form_canvas;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_form_canvas >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_form_canvas
  (p_validate                      in     boolean  default false
   ,p_form_canvas_id               in     number
   ,p_object_version_number        in     number)
 is
  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'delete_form_canvas';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_form_canvas;
  --
  -- Call Before Process User Hook
  --
  begin

    hr_form_canvases_api_bk2.delete_form_canvas_b
      (p_form_canvas_id               => p_form_canvas_id
       ,p_object_version_number        => p_object_version_number);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_form_canvas'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  hr_utility.set_location('At:'|| l_proc, 20);

  hr_fcn_shd.lck(
     p_form_canvas_id               => p_form_canvas_id
     ,p_object_version_number        => p_object_version_number);

  hr_utility.set_location('At:'|| l_proc, 25);

  hr_canvas_properties_bsi.delete_canvas_property(
     p_form_canvas_id               => p_form_canvas_id
     ,p_object_version_number        => p_object_version_number);

  hr_utility.set_location('At:'|| l_proc, 30);

  hr_fct_del.del_tl(p_form_canvas_id => p_form_canvas_id );

  hr_utility.set_location('At:'|| l_proc, 35);

  hr_fcn_del.del(p_form_canvas_id               => p_form_canvas_id
                 ,p_object_version_number        => p_object_version_number);

  hr_utility.set_location('At:'|| l_proc, 40);

  --
  -- Call After Process User Hook
  --
  begin

    hr_form_canvases_api_bk2.delete_form_canvas_a
      (p_form_canvas_id               => p_form_canvas_id
       ,p_object_version_number        => p_object_version_number);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_form_canvas'
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
    rollback to delete_form_canvas;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_form_canvas;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_form_canvas;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_form_canvas >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_form_canvas
   (p_validate                     in      boolean  default false
    ,p_effective_date              in      date
    ,p_language_code                in     varchar2 default hr_api.userenv_lang
    ,p_form_canvas_id               in     number
    ,p_object_version_number        in out nocopy number
    ,p_canvas_name                  in     varchar2 default hr_api.g_varchar2
    --,p_canvas_type                  in     varchar2 default hr_api.g_varchar2
    ,p_user_canvas_name             in     varchar2 default hr_api.g_varchar2
    ,p_description                  in     varchar2 default hr_api.g_varchar2
    ,p_height                       in     number   default hr_api.g_number
    ,p_visible                      in     number   default hr_api.g_number
    ,p_width                        in     number   default hr_api.g_number
    ,p_x_position                   in     number   default hr_api.g_number
    ,p_y_position                   in     number   default hr_api.g_number
    ,p_information_category         in     varchar2 default hr_api.g_varchar2
    ,p_information1                 in     varchar2 default hr_api.g_varchar2
    ,p_information2                 in     varchar2 default hr_api.g_varchar2
    ,p_information3                 in     varchar2 default hr_api.g_varchar2
    ,p_information4                 in     varchar2 default hr_api.g_varchar2
    ,p_information5                 in     varchar2 default hr_api.g_varchar2
    ,p_information6                 in     varchar2 default hr_api.g_varchar2
    ,p_information7                 in     varchar2 default hr_api.g_varchar2
    ,p_information8                 in     varchar2 default hr_api.g_varchar2
    ,p_information9                 in     varchar2 default hr_api.g_varchar2
    ,p_information10                in     varchar2 default hr_api.g_varchar2
    ,p_information11                in     varchar2 default hr_api.g_varchar2
    ,p_information12                in     varchar2 default hr_api.g_varchar2
    ,p_information13                in     varchar2 default hr_api.g_varchar2
    ,p_information14                in     varchar2 default hr_api.g_varchar2
    ,p_information15                in     varchar2 default hr_api.g_varchar2
    ,p_information16                in     varchar2 default hr_api.g_varchar2
    ,p_information17                in     varchar2 default hr_api.g_varchar2
    ,p_information18                in     varchar2 default hr_api.g_varchar2
    ,p_information19                in     varchar2 default hr_api.g_varchar2
    ,p_information20                in     varchar2 default hr_api.g_varchar2
    ,p_information21                in     varchar2 default hr_api.g_varchar2
    ,p_information22                in     varchar2 default hr_api.g_varchar2
    ,p_information23                in     varchar2 default hr_api.g_varchar2
    ,p_information24                in     varchar2 default hr_api.g_varchar2
    ,p_information25                in     varchar2 default hr_api.g_varchar2
    ,p_information26                in     varchar2 default hr_api.g_varchar2
    ,p_information27                in     varchar2 default hr_api.g_varchar2
    ,p_information28                in     varchar2 default hr_api.g_varchar2
    ,p_information29                in     varchar2 default hr_api.g_varchar2
    ,p_information30                in     varchar2 default hr_api.g_varchar2)
is
  --
  -- Declare cursors and local variables
  --

  l_language_code fnd_languages.language_code%TYPE;
  l_proc                varchar2(72) := g_package||'update_form_canvas';
  l_object_version_number number;

  l_temp_ovn   number := p_object_version_number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_form_canvas;
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

    hr_form_canvases_api_bk3.update_form_canvas_b
      (p_effective_date      => TRUNC(p_effective_date)
      ,p_language_code              => l_language_code
      ,p_canvas_name                => p_canvas_name
      --,p_canvas_type                => p_canvas_type
      ,p_user_canvas_name           => p_user_canvas_name
      ,p_description                => p_description
      ,p_height                     => p_height
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
      ,p_form_canvas_id             => p_form_canvas_id
      ,p_object_version_number      => l_object_version_number);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_form_canvas'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --

  hr_utility.set_location('At:'|| l_proc, 20);

   hr_fcn_upd.upd(
      p_effective_date               => TRUNC(p_effective_date)
     ,p_form_canvas_id               => p_form_canvas_id
     ,p_canvas_name                  => p_canvas_name
     --,p_canvas_type                  => p_canvas_type
     ,p_object_version_number        => l_object_version_number);

  hr_utility.set_location('At:'|| l_proc, 25);

   hr_fct_upd.upd_tl(
      --p_effective_date               => TRUNC(p_effective_date)
     p_language_code                => l_language_code
     ,p_form_canvas_id               => p_form_canvas_id
     ,p_user_canvas_name             => p_user_canvas_name
     ,p_description                  => p_description);

  hr_utility.set_location('At:'|| l_proc, 30);

   hr_canvas_properties_bsi.update_canvas_property(
      p_effective_date               => TRUNC(p_effective_date)
     ,p_object_version_number        => l_object_version_number
     ,p_form_canvas_id               => p_form_canvas_id
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

  hr_utility.set_location('At:'|| l_proc, 35);

  --
  -- Call After Process User Hook
  --
  begin

    hr_form_canvases_api_bk3.update_form_canvas_a
     (p_effective_date            => TRUNC(p_effective_date)
     ,p_language_code             => l_language_code
     ,p_canvas_name               => p_canvas_name
     --,p_canvas_type               => p_canvas_type
     ,p_user_canvas_name          => p_user_canvas_name
     ,p_description               => p_description
     ,p_height                    => p_height
     ,p_visible                   => p_visible
     ,p_width                     => p_width
     ,p_x_position                => p_x_position
     ,p_y_position                => p_y_position
     ,p_information_category      => p_information_category
     ,p_information1              => p_information1
     ,p_information2              => p_information2
     ,p_information3              => p_information3
     ,p_information4              => p_information4
     ,p_information5              => p_information5
     ,p_information6              => p_information6
     ,p_information7              => p_information7
     ,p_information8              => p_information8
     ,p_information9              => p_information9
     ,p_information10             => p_information10
     ,p_information11             => p_information11
     ,p_information12             => p_information12
     ,p_information13             => p_information13
     ,p_information14             => p_information14
     ,p_information15             => p_information15
     ,p_information16             => p_information16
     ,p_information17             => p_information17
     ,p_information18             => p_information18
     ,p_information19             => p_information19
     ,p_information20             => p_information20
     ,p_information21             => p_information21
     ,p_information22             => p_information22
     ,p_information23             => p_information23
     ,p_information24             => p_information24
     ,p_information25             => p_information25
     ,p_information26             => p_information26
     ,p_information27             => p_information27
     ,p_information28             => p_information28
     ,p_information29             => p_information29
     ,p_information30             => p_information30
     ,p_form_canvas_id            => p_form_canvas_id
     ,p_object_version_number     => l_object_version_number);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_form_canvas'
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
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_form_canvas;
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
    rollback to update_form_canvas;
    -- Reset all output arguments
    --
    p_object_version_number  := l_temp_ovn;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_form_canvas;
--
end hr_form_canvases_api;

/
