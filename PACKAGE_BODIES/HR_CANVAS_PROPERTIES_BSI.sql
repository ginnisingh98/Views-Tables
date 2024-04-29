--------------------------------------------------------
--  DDL for Package Body HR_CANVAS_PROPERTIES_BSI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CANVAS_PROPERTIES_BSI" as
/* $Header: hrcnpbsi.pkb 120.0 2005/05/30 23:16:05 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_canvas_properties_bsi.';
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_canvas_property >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_canvas_property
  (p_validate                        in     boolean  default false
  ,p_effective_date                  in     date
  ,p_form_canvas_id                  in number default null
  ,p_template_canvas_id              in number default null
  ,p_height                          in number default null
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
  ,p_canvas_property_id                out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_canvas_property_id                number;
  l_object_version_number             number;
  l_proc                varchar2(72) := g_package||'create_canvas_property';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_canvas_property;

  --
  -- Process Logic
  --

  hr_cnp_ins.ins(p_effective_date           => TRUNC(p_effective_date)
            ,p_form_canvas_id               => p_form_canvas_id
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
            ,p_information30                => p_information30
            ,p_canvas_property_id           => l_canvas_property_id
            ,p_object_version_number        => l_object_version_number);

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_canvas_property_id           := l_canvas_property_id;
  p_object_version_number        := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_canvas_property;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_canvas_property_id           := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_canvas_property;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_canvas_property;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_canvas_property >------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_canvas_property
  (p_validate                        in     boolean  default false
  ,p_effective_date                  in     date
  ,p_canvas_property_id              in number default null
  ,p_object_version_number           in out nocopy number
  ,p_form_canvas_id                  in number default null
  ,p_template_canvas_id              in number default null
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

  CURSOR cur_can_prop_1
  IS
  SELECT canvas_property_id
  FROM hr_canvas_properties
  WHERE form_canvas_id = p_form_canvas_id;

  CURSOR cur_can_prop_2
  IS
  SELECT canvas_property_id
  FROM hr_canvas_properties
  WHERE template_canvas_id = p_template_canvas_id;

  l_canvas_property_id number;
  l_proc                varchar2(72) := g_package||'update_canvas_property';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_canvas_property;
  --
  -- Validation in addition to Row Handlers
  --
  hr_utility.set_location('At:'|| l_proc, 15);

  IF ( p_canvas_property_id is not null) THEN
    IF ( p_form_canvas_id is not null OR p_template_canvas_id is not null) THEN
      -- error message
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','10');
      fnd_message.raise_error;
    END IF;
  ELSIF ( p_form_canvas_id is not null) THEN
    IF (p_canvas_property_id is not null) OR
        (p_template_canvas_id is not null) THEN
      -- error message
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','10');
      fnd_message.raise_error;
    END IF;
  ELSIF ( p_template_canvas_id is not null) THEN
    IF  (p_canvas_property_id is not null OR p_form_canvas_id is not null) THEN
      -- error message
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','10');
      fnd_message.raise_error;
    END IF;
  END IF;
  --
  -- Process Logic
  --

  hr_utility.set_location('At:'|| l_proc, 20);

  l_canvas_property_id := p_canvas_property_id;

  IF p_form_canvas_id is not null THEN
     OPEN cur_can_prop_1;
     FETCH cur_can_prop_1 INTO l_canvas_property_id;
     CLOSE cur_can_prop_1;
  END IF;

  hr_utility.set_location('At:'|| l_proc, 30);

  IF p_template_canvas_id is not null THEN
     OPEN cur_can_prop_2;
     FETCH cur_can_prop_2 INTO l_canvas_property_id;
     CLOSE cur_can_prop_2;
  END IF;

  hr_utility.set_location('At:'|| l_proc, 40);

  hr_cnp_upd.upd(p_effective_date           => TRUNC(p_effective_date)
            ,p_canvas_property_id           => l_canvas_property_id
            ,p_object_version_number        => p_object_version_number
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
  --
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  hr_utility.set_location('At:'|| l_proc, 50);

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
    rollback to update_canvas_property;
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
    rollback to update_canvas_property;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_canvas_property;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_canvas_property >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_canvas_property
  (p_validate                        in     boolean  default false
  ,p_canvas_property_id              in number default null
  ,p_object_version_number           in number
  ,p_form_canvas_id                  in number default null
  ,p_template_canvas_id              in number default null
  ) is
  --
  -- Declare cursors and local variables
  --
  CURSOR cur_can_prop_1
  IS
  SELECT canvas_property_id
  FROM hr_canvas_properties
  WHERE form_canvas_id = p_form_canvas_id;

  CURSOR cur_can_prop_2
  IS
  SELECT canvas_property_id
  FROM hr_canvas_properties
  WHERE template_canvas_id = p_template_canvas_id;

  l_proc                varchar2(72) := g_package||'delete_canvas_property';
  l_canvas_property_id number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_canvas_property;

  --
  -- Validation in addition to Row Handlers
  --
  hr_utility.set_location('At:'|| l_proc, 15);

  IF ( p_canvas_property_id is not null) THEN
    IF (p_form_canvas_id is not null OR p_template_canvas_id is not null) THEN
      -- error message
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','10');
      fnd_message.raise_error;
    END IF;
  ELSIF ( p_form_canvas_id is not null) THEN
    IF (p_canvas_property_id is not null OR
       p_template_canvas_id is not null) THEN
      -- error message
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','10');
      fnd_message.raise_error;
    END IF;
  ELSIF ( p_template_canvas_id is not null) THEN
    IF  (p_canvas_property_id is not null OR p_form_canvas_id is not null) THEN
      -- error message
      fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
      fnd_message.set_token('PROCEDURE', l_proc);
      fnd_message.set_token('STEP','10');
      fnd_message.raise_error;
    END IF;
  END IF;
  --
  -- Process Logic
  --

  hr_utility.set_location('At:'|| l_proc, 20);

  l_canvas_property_id := p_canvas_property_id;

  IF p_form_canvas_id is not null THEN
     OPEN cur_can_prop_1;
     FETCH cur_can_prop_1 INTO l_canvas_property_id;
     CLOSE cur_can_prop_1;
  END IF;

  hr_utility.set_location('At:'|| l_proc, 30);

  IF p_template_canvas_id is not null THEN
     OPEN cur_can_prop_2;
     FETCH cur_can_prop_2 INTO l_canvas_property_id;
     CLOSE cur_can_prop_2;
  END IF;

  hr_utility.set_location('At:'|| l_proc, 40);

  if l_canvas_property_id is not null then                   --Added if condition for Bug 4072087
      hr_cnp_del.del( p_canvas_property_id           => l_canvas_property_id
                 ,p_object_version_number        => p_object_version_number  );
  end if;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  hr_utility.set_location('At:'|| l_proc, 50);

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
    rollback to delete_canvas_property;
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
    rollback to delete_canvas_property;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_canvas_property;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< copy_canvas_property >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure copy_canvas_property
  (p_validate                        in     boolean  default false
  ,p_effective_date                  in     date
  ,p_form_canvas_id                  in number
  ,p_template_canvas_id              in number
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
  ,p_canvas_property_id                out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  Type l_rec_type Is Record
  (height hr_canvas_properties.height%TYPE
  ,visible hr_canvas_properties.visible%TYPE
  ,width hr_canvas_properties.width%TYPE
  ,x_position hr_canvas_properties.x_position%TYPE
  ,y_position hr_canvas_properties.y_position%TYPE
  ,information_category hr_canvas_properties.information_category%TYPE
  ,information1 hr_canvas_properties.information1%TYPE
  ,information2 hr_canvas_properties.information2%TYPE
  ,information3 hr_canvas_properties.information3%TYPE
  ,information4 hr_canvas_properties.information4%TYPE
  ,information5 hr_canvas_properties.information5%TYPE
  ,information6 hr_canvas_properties.information6%TYPE
  ,information7 hr_canvas_properties.information7%TYPE
  ,information8 hr_canvas_properties.information8%TYPE
  ,information9 hr_canvas_properties.information9%TYPE
  ,information10 hr_canvas_properties.information10%TYPE
  ,information11 hr_canvas_properties.information11%TYPE
  ,information12 hr_canvas_properties.information12%TYPE
  ,information13 hr_canvas_properties.information13%TYPE
  ,information14 hr_canvas_properties.information14%TYPE
  ,information15 hr_canvas_properties.information15%TYPE
  ,information16 hr_canvas_properties.information16%TYPE
  ,information17 hr_canvas_properties.information17%TYPE
  ,information18 hr_canvas_properties.information18%TYPE
  ,information19 hr_canvas_properties.information19%TYPE
  ,information20 hr_canvas_properties.information20%TYPE
  ,information21 hr_canvas_properties.information21%TYPE
  ,information22 hr_canvas_properties.information22%TYPE
  ,information23 hr_canvas_properties.information23%TYPE
  ,information24 hr_canvas_properties.information24%TYPE
  ,information25 hr_canvas_properties.information25%TYPE
  ,information26 hr_canvas_properties.information26%TYPE
  ,information27 hr_canvas_properties.information27%TYPE
  ,information28 hr_canvas_properties.information28%TYPE
  ,information29 hr_canvas_properties.information29%TYPE
  ,information30 hr_canvas_properties.information30%TYPE);

  l_rec l_rec_type;

  CURSOR cur_check
  IS
  SELECT 1
  FROM hr_template_canvases tcn
  WHERE tcn.template_canvas_id = p_template_canvas_id
  AND tcn.form_canvas_id = p_form_canvas_id;

-- added a outer join so that the correct values are returned
-- if there are no entries in the properties table
  CURSOR cur_can_prop
  IS
  SELECT DECODE(p_height,hr_api.g_number,cnp.height,p_height)
  ,DECODE(p_visible,hr_api.g_number,cnp.visible,p_visible)
  ,DECODE(p_width,hr_api.g_number,cnp.width,p_width)
  ,DECODE(p_x_position,hr_api.g_number,cnp.x_position,p_x_position)
  ,DECODE(p_y_position,hr_api.g_number,cnp.y_position,p_y_position)
  ,DECODE(p_information_category,hr_api.g_varchar2,cnp.information_category,p_information_category)
  ,DECODE(p_information1,hr_api.g_varchar2,cnp.information1,p_information1)
  ,DECODE(p_information2,hr_api.g_varchar2,cnp.information2,p_information2)
  ,DECODE(p_information3,hr_api.g_varchar2,cnp.information3,p_information3)
  ,DECODE(p_information4,hr_api.g_varchar2,cnp.information4,p_information4)
  ,DECODE(p_information5,hr_api.g_varchar2,cnp.information5,p_information5)
  ,DECODE(p_information6,hr_api.g_varchar2,cnp.information6,p_information6)
  ,DECODE(p_information7,hr_api.g_varchar2,cnp.information7,p_information7)
  ,DECODE(p_information8,hr_api.g_varchar2,cnp.information8,p_information8)
  ,DECODE(p_information9,hr_api.g_varchar2,cnp.information9,p_information9)
  ,DECODE(p_information10,hr_api.g_varchar2,cnp.information10,p_information10)
  ,DECODE(p_information11,hr_api.g_varchar2,cnp.information11,p_information11)
  ,DECODE(p_information12,hr_api.g_varchar2,cnp.information12,p_information12)
  ,DECODE(p_information13,hr_api.g_varchar2,cnp.information13,p_information13)
  ,DECODE(p_information14,hr_api.g_varchar2,cnp.information14,p_information14)
  ,DECODE(p_information15,hr_api.g_varchar2,cnp.information15,p_information15)
  ,DECODE(p_information16,hr_api.g_varchar2,cnp.information16,p_information16)
  ,DECODE(p_information17,hr_api.g_varchar2,cnp.information17,p_information17)
  ,DECODE(p_information18,hr_api.g_varchar2,cnp.information18,p_information18)
  ,DECODE(p_information19,hr_api.g_varchar2,cnp.information19,p_information19)
  ,DECODE(p_information20,hr_api.g_varchar2,cnp.information20,p_information20)
  ,DECODE(p_information21,hr_api.g_varchar2,cnp.information21,p_information21)
  ,DECODE(p_information22,hr_api.g_varchar2,cnp.information22,p_information22)
  ,DECODE(p_information23,hr_api.g_varchar2,cnp.information23,p_information23)
  ,DECODE(p_information24,hr_api.g_varchar2,cnp.information24,p_information24)
  ,DECODE(p_information25,hr_api.g_varchar2,cnp.information25,p_information25)
  ,DECODE(p_information26,hr_api.g_varchar2,cnp.information26,p_information26)
  ,DECODE(p_information27,hr_api.g_varchar2,cnp.information27,p_information27)
  ,DECODE(p_information28,hr_api.g_varchar2,cnp.information28,p_information28)
  ,DECODE(p_information29,hr_api.g_varchar2,cnp.information29,p_information29)
  ,DECODE(p_information30,hr_api.g_varchar2,cnp.information30,p_information30)
  FROM hr_canvas_properties cnp
       , hr_form_canvases_b hfc
  WHERE cnp.form_canvas_id (+) = hfc.form_canvas_id
  AND hfc.form_canvas_id = p_form_canvas_id;

  l_check                 number;
  l_canvas_property_id    number;
  l_object_version_number number;
  l_proc                  varchar2(72) := g_package||'copy_canvas_property';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint copy_canvas_property;
  --
  -- Validation in addition to Row Handlers
  --
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

  OPEN cur_can_prop;
  FETCH cur_can_prop INTO l_rec;
  CLOSE cur_can_prop;

  hr_utility.set_location('At:'|| l_proc, 30);

  hr_cnp_ins.ins(p_effective_date           => p_effective_date
            ,p_template_canvas_id           => p_template_canvas_id
            ,p_height                       => l_rec.height
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
            ,p_canvas_property_id           => l_canvas_property_id
            ,p_object_version_number        => l_object_version_number);
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
  p_canvas_property_id           := l_canvas_property_id;
  p_object_version_number        := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to copy_canvas_property;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_canvas_property_id           := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to copy_canvas_property;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end copy_canvas_property;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< copy_canvas_property - overload>-----------------|
-- ----------------------------------------------------------------------------
--
procedure copy_canvas_property
  (p_validate                        in     boolean  default false
  ,p_effective_date                  in     date
  ,p_template_canvas_id_from         in number
  ,p_template_canvas_id_to           in number
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
  ,p_canvas_property_id                out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
-- added a outer join so that the correct values are returned
-- if there are no entries in the properties table
  Type l_rec_type Is Record
  (height hr_canvas_properties.height%TYPE
  ,visible hr_canvas_properties.visible%TYPE
  ,width hr_canvas_properties.width%TYPE
  ,x_position hr_canvas_properties.x_position%TYPE
  ,y_position hr_canvas_properties.y_position%TYPE
  ,information_category hr_canvas_properties.information_category%TYPE
  ,information1 hr_canvas_properties.information1%TYPE
  ,information2 hr_canvas_properties.information2%TYPE
  ,information3 hr_canvas_properties.information3%TYPE
  ,information4 hr_canvas_properties.information4%TYPE
  ,information5 hr_canvas_properties.information5%TYPE
  ,information6 hr_canvas_properties.information6%TYPE
  ,information7 hr_canvas_properties.information7%TYPE
  ,information8 hr_canvas_properties.information8%TYPE
  ,information9 hr_canvas_properties.information9%TYPE
  ,information10 hr_canvas_properties.information10%TYPE
  ,information11 hr_canvas_properties.information11%TYPE
  ,information12 hr_canvas_properties.information12%TYPE
  ,information13 hr_canvas_properties.information13%TYPE
  ,information14 hr_canvas_properties.information14%TYPE
  ,information15 hr_canvas_properties.information15%TYPE
  ,information16 hr_canvas_properties.information16%TYPE
  ,information17 hr_canvas_properties.information17%TYPE
  ,information18 hr_canvas_properties.information18%TYPE
  ,information19 hr_canvas_properties.information19%TYPE
  ,information20 hr_canvas_properties.information20%TYPE
  ,information21 hr_canvas_properties.information21%TYPE
  ,information22 hr_canvas_properties.information22%TYPE
  ,information23 hr_canvas_properties.information23%TYPE
  ,information24 hr_canvas_properties.information24%TYPE
  ,information25 hr_canvas_properties.information25%TYPE
  ,information26 hr_canvas_properties.information26%TYPE
  ,information27 hr_canvas_properties.information27%TYPE
  ,information28 hr_canvas_properties.information28%TYPE
  ,information29 hr_canvas_properties.information29%TYPE
  ,information30 hr_canvas_properties.information30%TYPE);

  l_rec l_rec_type;

  CURSOR cur_check
  IS
  SELECT tcn.form_canvas_id
  FROM hr_template_canvases tcn
  WHERE tcn.template_canvas_id = p_template_canvas_id_from
  INTERSECT
  SELECT tcn.form_canvas_id
  FROM hr_template_canvases tcn
  WHERE tcn.template_canvas_id = p_template_canvas_id_to;

  CURSOR cur_can_prop
  IS
  SELECT DECODE(p_height,hr_api.g_number,cnp.height,p_height)
  ,DECODE(p_visible,hr_api.g_number,cnp.visible,p_visible)
  ,DECODE(p_width,hr_api.g_number,cnp.width,p_width)
  ,DECODE(p_x_position,hr_api.g_number,cnp.x_position,p_x_position)
  ,DECODE(p_y_position,hr_api.g_number,cnp.y_position,p_y_position)
  ,DECODE(p_information_category,hr_api.g_varchar2,cnp.information_category,p_information_category)
  ,DECODE(p_information1,hr_api.g_varchar2,cnp.information1,p_information1)
  ,DECODE(p_information2,hr_api.g_varchar2,cnp.information2,p_information2)
  ,DECODE(p_information3,hr_api.g_varchar2,cnp.information3,p_information3)
  ,DECODE(p_information4,hr_api.g_varchar2,cnp.information4,p_information4)
  ,DECODE(p_information5,hr_api.g_varchar2,cnp.information5,p_information5)
  ,DECODE(p_information6,hr_api.g_varchar2,cnp.information6,p_information6)
  ,DECODE(p_information7,hr_api.g_varchar2,cnp.information7,p_information7)
  ,DECODE(p_information8,hr_api.g_varchar2,cnp.information8,p_information8)
  ,DECODE(p_information9,hr_api.g_varchar2,cnp.information9,p_information9)
  ,DECODE(p_information10,hr_api.g_varchar2,cnp.information10,p_information10)
  ,DECODE(p_information11,hr_api.g_varchar2,cnp.information11,p_information11)
  ,DECODE(p_information12,hr_api.g_varchar2,cnp.information12,p_information12)
  ,DECODE(p_information13,hr_api.g_varchar2,cnp.information13,p_information13)
  ,DECODE(p_information14,hr_api.g_varchar2,cnp.information14,p_information14)
  ,DECODE(p_information15,hr_api.g_varchar2,cnp.information15,p_information15)
  ,DECODE(p_information16,hr_api.g_varchar2,cnp.information16,p_information16)
  ,DECODE(p_information17,hr_api.g_varchar2,cnp.information17,p_information17)
  ,DECODE(p_information18,hr_api.g_varchar2,cnp.information18,p_information18)
  ,DECODE(p_information19,hr_api.g_varchar2,cnp.information19,p_information19)
  ,DECODE(p_information20,hr_api.g_varchar2,cnp.information20,p_information20)
  ,DECODE(p_information21,hr_api.g_varchar2,cnp.information21,p_information21)
  ,DECODE(p_information22,hr_api.g_varchar2,cnp.information22,p_information22)
  ,DECODE(p_information23,hr_api.g_varchar2,cnp.information23,p_information23)
  ,DECODE(p_information24,hr_api.g_varchar2,cnp.information24,p_information24)
  ,DECODE(p_information25,hr_api.g_varchar2,cnp.information25,p_information25)
  ,DECODE(p_information26,hr_api.g_varchar2,cnp.information26,p_information26)
  ,DECODE(p_information27,hr_api.g_varchar2,cnp.information27,p_information27)
  ,DECODE(p_information28,hr_api.g_varchar2,cnp.information28,p_information28)
  ,DECODE(p_information29,hr_api.g_varchar2,cnp.information29,p_information29)
  ,DECODE(p_information30,hr_api.g_varchar2,cnp.information30,p_information30)
  FROM hr_canvas_properties cnp
       , hr_template_canvases_b htc
  WHERE cnp.template_canvas_id (+) = htc.template_canvas_id
  and htc.template_canvas_id = p_template_canvas_id_from;

  l_check number;
  l_canvas_property_id                number;
  l_object_version_number             number;
  l_proc                varchar2(72) := g_package||'copy_canvas_property';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint copy_canvas_property;
  --
  -- Validation in addition to Row Handlers
  --

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

  OPEN cur_can_prop;
  FETCH cur_can_prop INTO l_rec;
  CLOSE cur_can_prop;

  hr_utility.set_location('At:'|| l_proc, 30);

  hr_cnp_ins.ins(p_effective_date           => p_effective_date
            ,p_template_canvas_id           => p_template_canvas_id_to
            ,p_height                       => l_rec.height
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
            ,p_canvas_property_id           => l_canvas_property_id
            ,p_object_version_number        => l_object_version_number );
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
  p_canvas_property_id           := l_canvas_property_id;
  p_object_version_number        := l_object_Version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to copy_canvas_property;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_canvas_property_id           := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to copy_canvas_property;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end copy_canvas_property;
--
end hr_canvas_properties_bsi;

/
