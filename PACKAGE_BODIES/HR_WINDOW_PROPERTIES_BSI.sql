--------------------------------------------------------
--  DDL for Package Body HR_WINDOW_PROPERTIES_BSI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_WINDOW_PROPERTIES_BSI" as
/* $Header: hrwnpbsi.pkb 115.2 2002/12/03 14:14:10 raranjan noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_window_properties_bsi.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_window_property >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_window_property
  (p_validate                        in     boolean  default false
  ,p_effective_date                  in     date
  ,p_language_code                   in varchar2 default hr_api.userenv_lang
  ,p_form_window_id                  in number default null
  ,p_template_window_id              in number default null
  ,p_height                          in number default null
  ,p_title                           in varchar2 default null
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
  ,p_window_property_id                out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_window_property_id                number;
  l_proc                varchar2(72) := g_package||'create_window_property';
  l_language_code fnd_languages.language_code%TYPE;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_window_property;
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
  -- Process Logic
  --
  hr_wnp_ins.ins(p_form_window_id               => p_form_window_id
            ,p_template_window_id           => p_template_window_id
            ,p_height                       => p_height
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

  hr_utility.set_location('At:'|| l_proc, 15);

  hr_wpt_ins.ins_tl(
            p_language_code                => l_language_code
            ,p_window_property_id           => l_window_property_id
            ,p_title                        => p_title);

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_window_property_id           := l_window_property_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_window_property;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_window_property_id           := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_window_property;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_window_property;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_window_property >----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_window_property
  (p_validate                        in     boolean  default false
  ,p_effective_date                  in     date
  ,p_language_code                   in varchar2 default hr_api.userenv_lang
  ,p_window_property_id              in number default null
  ,p_form_window_id                  in number default null
  ,p_template_window_id              in number default null
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
  CURSOR cur_win_prop_1
  IS
  SELECT window_property_id
  FROM hr_window_properties_b
  WHERE form_window_id = p_form_window_id;

  CURSOR cur_win_prop_2
  IS
  SELECT window_property_id
  FROM hr_window_properties_b
  WHERE template_window_id = p_template_window_id;

  l_window_property_id number;
  l_proc                varchar2(72) := g_package||'update_window_property';
  l_language_code fnd_languages.language_code%TYPE;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_window_property;
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

  IF ( p_window_property_id is not null) AND
     (p_form_window_id is not null OR p_template_window_id is not null) THEN
    -- error message
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ELSIF ( p_form_window_id is not null) AND
     (p_window_property_id is not null OR p_template_window_id is not null) THEN
    -- error message
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ELSIF ( p_template_window_id is not null) AND
     (p_window_property_id is not null OR p_form_window_id is not null) THEN
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

  l_window_property_id := p_window_property_id;

  IF p_form_window_id is not null THEN
     OPEN cur_win_prop_1;
     FETCH cur_win_prop_1 INTO l_window_property_id;
     CLOSE cur_win_prop_1;
  END IF;

  hr_utility.set_location('At:'|| l_proc, 25);

  IF p_template_window_id is not null THEN
     OPEN cur_win_prop_2;
     FETCH cur_win_prop_2 INTO l_window_property_id;
     CLOSE cur_win_prop_2;
  END IF;

  hr_utility.set_location('At:'|| l_proc, 30);

  hr_wnp_upd.upd(p_window_property_id           => l_window_property_id
            ,p_height                       => p_height
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

  hr_wpt_upd.upd_tl(
            p_language_code                => l_language_code
            ,p_window_property_id           => l_window_property_id
            ,p_title                        => p_title);

  hr_utility.set_location('At:'|| l_proc, 40);

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
    rollback to update_window_property;
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
    rollback to update_window_property;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_window_property;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_window_property >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_window_property
  (p_validate                      in     boolean  default false
  ,p_window_property_id              in number default null
  ,p_form_window_id                  in number default null
  ,p_template_window_id              in number default null
  ) is
  --
  -- Declare cursors and local variables
  --
  CURSOR cur_win_prop_1
  IS
  SELECT window_property_id
  FROM hr_window_properties_b
  WHERE form_window_id = p_form_window_id;

  CURSOR cur_win_prop_2
  IS
  SELECT window_property_id
  FROM hr_window_properties_b
  WHERE template_window_id = p_template_window_id;

  l_window_property_id number;
  l_proc                varchar2(72) := g_package||'delete_window_property';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_window_property;
  --
  -- Validation in addition to Row Handlers
  --
  hr_utility.set_location('At:'|| l_proc, 15);

  IF ( p_window_property_id is not null) AND
     (p_form_window_id is not null OR p_template_window_id is not null) THEN
    -- error message
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ELSIF ( p_form_window_id is not null) AND
     (p_window_property_id is not null OR p_template_window_id is not null) THEN
    -- error message
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ELSIF ( p_template_window_id is not null) AND
     (p_window_property_id is not null OR p_form_window_id is not null) THEN
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

  l_window_property_id := p_window_property_id;

  IF p_form_window_id is not null THEN
     OPEN cur_win_prop_1;
     FETCH cur_win_prop_1 INTO l_window_property_id;
     CLOSE cur_win_prop_1;
  END IF;

  hr_utility.set_location('At:'|| l_proc, 25);

  IF p_template_window_id is not null THEN
     OPEN cur_win_prop_2;
     FETCH cur_win_prop_2 INTO l_window_property_id;
     CLOSE cur_win_prop_2;
  END IF;

  hr_utility.set_location('At:'|| l_proc, 30);

  hr_wnp_shd.lck( p_window_property_id => l_window_property_id );

  hr_utility.set_location('At:'|| l_proc, 35);

  hr_wpt_del.del_tl( p_window_property_id => l_window_property_id);

  hr_utility.set_location('At:'|| l_proc, 40);

  hr_wnp_del.del(p_window_property_id => l_window_property_id);

  hr_utility.set_location('At:'|| l_proc, 45);

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
    rollback to delete_window_property;
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
    rollback to delete_window_property;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_window_property;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< copy_window_property >------------------------|
-- ----------------------------------------------------------------------------
--
procedure copy_window_property
  (p_validate                        in     boolean  default false
  ,p_effective_date                  in     date
  ,p_language_code                   in varchar2 default hr_api.userenv_lang
  ,p_form_window_id                  in number
  ,p_template_window_id              in number
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
  ,p_window_property_id                out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  Type l_rec_type Is Record
  (height hr_window_properties_b.height%TYPE
  -- ,title hr_window_properties_b.title%TYPE
  ,width hr_window_properties_b.width%TYPE
  ,x_position hr_window_properties_b.x_position%TYPE
  ,y_position hr_window_properties_b.y_position%TYPE
  ,information_category hr_window_properties_b.information_category%TYPE
  ,information1 hr_window_properties_b.information1%TYPE
  ,information2 hr_window_properties_b.information2%TYPE
  ,information3 hr_window_properties_b.information3%TYPE
  ,information4 hr_window_properties_b.information4%TYPE
  ,information5 hr_window_properties_b.information5%TYPE
  ,information6 hr_window_properties_b.information6%TYPE
  ,information7 hr_window_properties_b.information7%TYPE
  ,information8 hr_window_properties_b.information8%TYPE
  ,information9 hr_window_properties_b.information9%TYPE
  ,information10 hr_window_properties_b.information10%TYPE
  ,information11 hr_window_properties_b.information11%TYPE
  ,information12 hr_window_properties_b.information12%TYPE
  ,information13 hr_window_properties_b.information13%TYPE
  ,information14 hr_window_properties_b.information14%TYPE
  ,information15 hr_window_properties_b.information15%TYPE
  ,information16 hr_window_properties_b.information16%TYPE
  ,information17 hr_window_properties_b.information17%TYPE
  ,information18 hr_window_properties_b.information18%TYPE
  ,information19 hr_window_properties_b.information19%TYPE
  ,information20 hr_window_properties_b.information20%TYPE
  ,information21 hr_window_properties_b.information21%TYPE
  ,information22 hr_window_properties_b.information22%TYPE
  ,information23 hr_window_properties_b.information23%TYPE
  ,information24 hr_window_properties_b.information24%TYPE
  ,information25 hr_window_properties_b.information25%TYPE
  ,information26 hr_window_properties_b.information26%TYPE
  ,information27 hr_window_properties_b.information27%TYPE
  ,information28 hr_window_properties_b.information28%TYPE
  ,information29 hr_window_properties_b.information29%TYPE
  ,information30 hr_window_properties_b.information30%TYPE);

  l_rec l_rec_type;

  CURSOR cur_win_prop
  IS
  SELECT DECODE(p_height,hr_api.g_number,wnp.height,p_height)
  -- ,DECODE(p_title,hr_api.g_varchar2,wnp.title,p_title)
  ,DECODE(p_width,hr_api.g_number,wnp.width,p_width)
  ,DECODE(p_x_position,hr_api.g_number,wnp.x_position,p_x_position)
  ,DECODE(p_y_position,hr_api.g_number,wnp.y_position,p_y_position)
  ,DECODE(p_information_category,hr_api.g_varchar2,wnp.information_category,p_information_category)
  ,DECODE(p_information1,hr_api.g_varchar2,wnp.information1,p_information1)
  ,DECODE(p_information2,hr_api.g_varchar2,wnp.information2,p_information2)
  ,DECODE(p_information3,hr_api.g_varchar2,wnp.information3,p_information3)
  ,DECODE(p_information4,hr_api.g_varchar2,wnp.information4,p_information4)
  ,DECODE(p_information5,hr_api.g_varchar2,wnp.information5,p_information5)
  ,DECODE(p_information6,hr_api.g_varchar2,wnp.information6,p_information6)
  ,DECODE(p_information7,hr_api.g_varchar2,wnp.information7,p_information7)
  ,DECODE(p_information8,hr_api.g_varchar2,wnp.information8,p_information8)
  ,DECODE(p_information9,hr_api.g_varchar2,wnp.information9,p_information9)
  ,DECODE(p_information10,hr_api.g_varchar2,wnp.information10,p_information10)
  ,DECODE(p_information11,hr_api.g_varchar2,wnp.information11,p_information11)
  ,DECODE(p_information12,hr_api.g_varchar2,wnp.information12,p_information12)
  ,DECODE(p_information13,hr_api.g_varchar2,wnp.information13,p_information13)
  ,DECODE(p_information14,hr_api.g_varchar2,wnp.information14,p_information14)
  ,DECODE(p_information15,hr_api.g_varchar2,wnp.information15,p_information15)
  ,DECODE(p_information16,hr_api.g_varchar2,wnp.information16,p_information16)
  ,DECODE(p_information17,hr_api.g_varchar2,wnp.information17,p_information17)
  ,DECODE(p_information18,hr_api.g_varchar2,wnp.information18,p_information18)
  ,DECODE(p_information19,hr_api.g_varchar2,wnp.information19,p_information19)
  ,DECODE(p_information20,hr_api.g_varchar2,wnp.information20,p_information20)
  ,DECODE(p_information21,hr_api.g_varchar2,wnp.information21,p_information21)
  ,DECODE(p_information22,hr_api.g_varchar2,wnp.information22,p_information22)
  ,DECODE(p_information23,hr_api.g_varchar2,wnp.information23,p_information23)
  ,DECODE(p_information24,hr_api.g_varchar2,wnp.information24,p_information24)
  ,DECODE(p_information25,hr_api.g_varchar2,wnp.information25,p_information25)
  ,DECODE(p_information26,hr_api.g_varchar2,wnp.information26,p_information26)
  ,DECODE(p_information27,hr_api.g_varchar2,wnp.information27,p_information27)
  ,DECODE(p_information28,hr_api.g_varchar2,wnp.information28,p_information28)
  ,DECODE(p_information29,hr_api.g_varchar2,wnp.information29,p_information29)
  ,DECODE(p_information30,hr_api.g_varchar2,wnp.information30,p_information30)
  FROM hr_window_properties_b wnp
  WHERE wnp.form_window_id = p_form_window_id;

  CURSOR cur_check
  IS
  SELECT 1
  FROM hr_template_windows twn
  WHERE twn.template_window_id = p_template_window_id
  AND twn.form_window_id   = p_form_window_id;

  CURSOR cur_win_tl
  IS
  SELECT COUNT(0)
  ,wnptl.source_lang
  ,DECODE(p_title,hr_api.g_varchar2,wnptl.title,p_title) title
  FROM hr_window_properties_tl wnptl
  ,hr_window_properties_b wnp
  WHERE wnptl.window_property_id = wnp.window_property_id
  AND wnp.form_window_id = p_form_window_id
  GROUP BY wnptl.source_lang
  ,DECODE(p_title,hr_api.g_varchar2,wnptl.title,p_title)
  ORDER BY 1;

  l_check number;
  l_window_property_id                number ;
  l_proc                varchar2(72) := g_package||'copy_window_property';
  l_language_code fnd_languages.language_code%TYPE;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint copy_window_property;

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

  hr_utility.set_location('At:'|| l_proc, 20);

  --
  -- Process Logic
  --
  OPEN cur_win_prop;
  FETCH cur_win_prop INTO l_rec;
  CLOSE cur_win_prop;

  hr_utility.set_location('At:'|| l_proc, 25);

  hr_wnp_ins.ins(p_template_window_id           => p_template_window_id
            ,p_height                       => l_rec.height
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
            ,p_window_property_id           => l_window_property_id);

  hr_utility.set_location('At:'|| l_proc, 30);

  IF p_title <> hr_api.g_varchar2 THEN
    hr_utility.set_location('At:'|| l_proc, 35);

    hr_wpt_ins.ins_tl(
               p_language_code                => l_language_code
               ,p_window_property_id           => l_window_property_id
               ,p_title                        => p_title);
  ELSE
    hr_utility.set_location('At:'|| l_proc, 40);

    FOR cur_rec IN cur_win_tl LOOP
      IF cur_win_tl%ROWCOUNT = 1 THEN
        hr_utility.set_location('At:'|| l_proc, 45);

        hr_wpt_ins.ins_tl(
                  p_language_code                => cur_rec.source_lang
                  ,p_window_property_id           => l_window_property_id
                  ,p_title                        => cur_rec.title);
       ELSE
        hr_utility.set_location('At:'|| l_proc, 50);

         hr_wpt_upd.upd_tl(
                  p_language_code                => cur_rec.source_lang
                  ,p_window_property_id           => l_window_property_id
                  ,p_title                        => cur_rec.title);
       END IF;
     END LOOP;
  END IF;

  hr_utility.set_location('At:'|| l_proc, 55);

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_window_property_id           := l_window_property_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to copy_window_property;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_window_property_id           := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to copy_window_property;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end copy_window_property;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< copy_window_property  - overload>-------------|
-- ----------------------------------------------------------------------------
--
procedure copy_window_property
  (p_validate                        in     boolean  default false
  ,p_effective_date                  in     date
  ,p_language_code                   in varchar2 default hr_api.userenv_lang
  ,p_template_window_id_from         in number
  ,p_template_window_id_to           in number
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
  ,p_window_property_id                out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  Type l_rec_type Is Record
  (height hr_window_properties_b.height%TYPE
  --,title hr_window_properties_b.title%TYPE
  ,width hr_window_properties_b.width%TYPE
  ,x_position hr_window_properties_b.x_position%TYPE
  ,y_position hr_window_properties_b.y_position%TYPE
  ,information_category hr_window_properties_b.information_category%TYPE
  ,information1 hr_window_properties_b.information1%TYPE
  ,information2 hr_window_properties_b.information2%TYPE
  ,information3 hr_window_properties_b.information3%TYPE
  ,information4 hr_window_properties_b.information4%TYPE
  ,information5 hr_window_properties_b.information5%TYPE
  ,information6 hr_window_properties_b.information6%TYPE
  ,information7 hr_window_properties_b.information7%TYPE
  ,information8 hr_window_properties_b.information8%TYPE
  ,information9 hr_window_properties_b.information9%TYPE
  ,information10 hr_window_properties_b.information10%TYPE
  ,information11 hr_window_properties_b.information11%TYPE
  ,information12 hr_window_properties_b.information12%TYPE
  ,information13 hr_window_properties_b.information13%TYPE
  ,information14 hr_window_properties_b.information14%TYPE
  ,information15 hr_window_properties_b.information15%TYPE
  ,information16 hr_window_properties_b.information16%TYPE
  ,information17 hr_window_properties_b.information17%TYPE
  ,information18 hr_window_properties_b.information18%TYPE
  ,information19 hr_window_properties_b.information19%TYPE
  ,information20 hr_window_properties_b.information20%TYPE
  ,information21 hr_window_properties_b.information21%TYPE
  ,information22 hr_window_properties_b.information22%TYPE
  ,information23 hr_window_properties_b.information23%TYPE
  ,information24 hr_window_properties_b.information24%TYPE
  ,information25 hr_window_properties_b.information25%TYPE
  ,information26 hr_window_properties_b.information26%TYPE
  ,information27 hr_window_properties_b.information27%TYPE
  ,information28 hr_window_properties_b.information28%TYPE
  ,information29 hr_window_properties_b.information29%TYPE
  ,information30 hr_window_properties_b.information30%TYPE);

  l_rec l_rec_type;

  CURSOR cur_win_prop
  IS
  SELECT DECODE(p_height,hr_api.g_number,wnp.height,p_height)
  --,DECODE(p_title,hr_api.g_varchar2,wnp.title,p_title)
  ,DECODE(p_width,hr_api.g_number,wnp.width,p_width)
  ,DECODE(p_x_position,hr_api.g_number,wnp.x_position,p_x_position)
  ,DECODE(p_y_position,hr_api.g_number,wnp.y_position,p_y_position)
  ,DECODE(p_information_category,hr_api.g_varchar2,wnp.information_category,p_information_category)
  ,DECODE(p_information1,hr_api.g_varchar2,wnp.information1,p_information1)
  ,DECODE(p_information2,hr_api.g_varchar2,wnp.information2,p_information2)
  ,DECODE(p_information3,hr_api.g_varchar2,wnp.information3,p_information3)
  ,DECODE(p_information4,hr_api.g_varchar2,wnp.information4,p_information4)
  ,DECODE(p_information5,hr_api.g_varchar2,wnp.information5,p_information5)
  ,DECODE(p_information6,hr_api.g_varchar2,wnp.information6,p_information6)
  ,DECODE(p_information7,hr_api.g_varchar2,wnp.information7,p_information7)
  ,DECODE(p_information8,hr_api.g_varchar2,wnp.information8,p_information8)
  ,DECODE(p_information9,hr_api.g_varchar2,wnp.information9,p_information9)
  ,DECODE(p_information10,hr_api.g_varchar2,wnp.information10,p_information10)
  ,DECODE(p_information11,hr_api.g_varchar2,wnp.information11,p_information11)
  ,DECODE(p_information12,hr_api.g_varchar2,wnp.information12,p_information12)
  ,DECODE(p_information13,hr_api.g_varchar2,wnp.information13,p_information13)
  ,DECODE(p_information14,hr_api.g_varchar2,wnp.information14,p_information14)
  ,DECODE(p_information15,hr_api.g_varchar2,wnp.information15,p_information15)
  ,DECODE(p_information16,hr_api.g_varchar2,wnp.information16,p_information16)
  ,DECODE(p_information17,hr_api.g_varchar2,wnp.information17,p_information17)
  ,DECODE(p_information18,hr_api.g_varchar2,wnp.information18,p_information18)
  ,DECODE(p_information19,hr_api.g_varchar2,wnp.information19,p_information19)
  ,DECODE(p_information20,hr_api.g_varchar2,wnp.information20,p_information20)
  ,DECODE(p_information21,hr_api.g_varchar2,wnp.information21,p_information21)
  ,DECODE(p_information22,hr_api.g_varchar2,wnp.information22,p_information22)
  ,DECODE(p_information23,hr_api.g_varchar2,wnp.information23,p_information23)
  ,DECODE(p_information24,hr_api.g_varchar2,wnp.information24,p_information24)
  ,DECODE(p_information25,hr_api.g_varchar2,wnp.information25,p_information25)
  ,DECODE(p_information26,hr_api.g_varchar2,wnp.information26,p_information26)
  ,DECODE(p_information27,hr_api.g_varchar2,wnp.information27,p_information27)
  ,DECODE(p_information28,hr_api.g_varchar2,wnp.information28,p_information28)
  ,DECODE(p_information29,hr_api.g_varchar2,wnp.information29,p_information29)
  ,DECODE(p_information30,hr_api.g_varchar2,wnp.information30,p_information30)
  FROM hr_window_properties_b wnp
  WHERE wnp.template_window_id = p_template_window_id_from;

  l_form_window_id number;

  CURSOR cur_check
  IS
  SELECT twn.form_window_id
  FROM hr_template_windows twn
  WHERE twn.template_window_id = p_template_window_id_from
  INTERSECT
  SELECT twn.form_window_id
  FROM hr_template_windows twn
  WHERE twn.template_window_id = p_template_window_id_to;

  CURSOR cur_win_tl
  IS
  SELECT COUNT(0)
  ,wnptl.source_lang
  ,DECODE(p_title,hr_api.g_varchar2,wnptl.title,p_title) title
  FROM hr_window_properties_tl wnptl
  ,hr_window_properties_b wnp
  WHERE wnptl.window_property_id = wnp.window_property_id
  AND wnp.form_window_id = l_form_window_id
  GROUP BY wnptl.source_lang
  ,DECODE(p_title,hr_api.g_varchar2,wnptl.title,p_title)
  ORDER BY 1;

  l_window_property_id                number ;
  l_proc                varchar2(72) := g_package||'copy_window_property';
  l_language_code fnd_languages.language_code%TYPE;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint copy_window_property;

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
  FETCH cur_check INTO l_form_window_id;
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

  OPEN cur_win_prop;
  FETCH cur_win_prop INTO l_rec;
  CLOSE cur_win_prop;

  hr_utility.set_location('At:'|| l_proc, 25);

  hr_wnp_ins.ins(p_template_window_id           => p_template_window_id_to
            ,p_height                       => l_rec.height
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
            ,p_window_property_id           => l_window_property_id);

  hr_utility.set_location('At:'|| l_proc, 30);

  IF p_title <> hr_api.g_varchar2 THEN
    hr_utility.set_location('At:'|| l_proc, 35);

    hr_wpt_ins.ins_tl(
               p_language_code                => l_language_code
               ,p_window_property_id           => l_window_property_id
               ,p_title                        => p_title);
  ELSE
    hr_utility.set_location('At:'|| l_proc, 40);

    FOR cur_rec IN cur_win_tl LOOP
      IF cur_win_tl%ROWCOUNT = 1 THEN
        hr_utility.set_location('At:'|| l_proc, 45);

        hr_wpt_ins.ins_tl(
                  p_language_code                => cur_rec.source_lang
                  ,p_window_property_id           => l_window_property_id
                  ,p_title                        => cur_rec.title);
       ELSE
         hr_utility.set_location('At:'|| l_proc, 50);

         hr_wpt_upd.upd_tl(
                  p_language_code                => cur_rec.source_lang
                  ,p_window_property_id           => l_window_property_id
                  ,p_title                        => cur_rec.title);
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
  p_window_property_id           := l_window_property_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to copy_window_property;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_window_property_id           := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to copy_window_property;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end copy_window_property;
--
end hr_window_properties_bsi;

/
