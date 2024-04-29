--------------------------------------------------------
--  DDL for Package Body HR_FORM_PROPERTIES_BSI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_FORM_PROPERTIES_BSI" as
/* $Header: hrfmpbsi.pkb 115.3 2003/09/24 02:01:09 bsubrama noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_form_properties_bsi.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_form_property >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_form_property
  (p_validate                        in     boolean  default false
  ,p_effective_date                  in     date
  ,p_application_id                  in number default null
  ,p_form_id                         in number default null
  ,p_form_template_id                in number default null
  ,p_help_target                     in varchar2 default null
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
  ,p_form_property_id                  out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'create_form_property';
  l_form_property_id number;
  l_object_version_number number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_form_property;
  --
  -- Truncate the time portion from all IN date parameters
  --
    -- p_effective_date := TRUNC(p_effective_date);

  --
  -- Process Logic
  --
  hr_fmp_ins.ins(p_application_id               => p_application_id
             ,p_form_id                      => p_form_id
             ,p_form_template_id             => p_form_template_id
             ,p_help_target                  => p_help_target
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
             ,p_form_property_id             => l_form_property_id
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
  p_form_property_id       := l_form_property_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_form_property;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_form_property_id := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_form_property;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_form_property;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_form_property >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_form_property
  (p_validate                        in     boolean  default false
  ,p_effective_date                  in     date
  ,p_form_property_id                in number default null
  ,p_object_version_number           in out nocopy number
  ,p_application_id                  in number default null
  ,p_form_id                         in number default null
  ,p_form_template_id                in number default null
  ,p_help_target                     in varchar2 default hr_api.g_varchar2
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

  CURSOR cur_frm_prop_1
  IS
  SELECT form_property_id
  FROM hr_form_properties
  WHERE application_id = p_application_id
  AND form_id = p_form_id;

  CURSOR cur_frm_prop_2
  IS
  SELECT form_property_id
  FROM hr_form_properties
  WHERE form_template_id = p_form_template_id;

  l_form_property_id number;
  l_proc                varchar2(72) := g_package||'update_form_property';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_form_property;
  --
  -- Truncate the time portion from all IN date parameters
  --
    -- p_effective_date := TRUNC(p_effective_date);
  --
  -- Validation in addition to Row Handlers
  --

  hr_utility.set_location('At:'|| l_proc, 15);

  IF ( p_form_property_id is not null ) AND
     (p_application_id is not null OR p_form_id is not null OR
      p_form_template_id is not null) THEN
    -- error message
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ELSIF (p_application_id is not null OR p_form_id is not null) AND
        ( p_form_property_id is not null OR p_form_template_id is not null) THEN
    -- error message
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ELSIF( p_form_template_id is not null) AND
       ( p_form_property_id is not null OR
         p_application_id is not null OR p_form_id is not null) THEN
    -- error message
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  END IF;

  hr_utility.set_location('At:'|| l_proc, 20);

  --
  -- Process Logic
  --

  l_form_property_id := p_form_property_id;

  IF ( p_application_id is not null AND p_form_id is not null) THEN
    OPEN cur_frm_prop_1;
    FETCH cur_frm_prop_1 INTO l_form_property_id;
    CLOSE cur_frm_prop_1;
  END IF;

  hr_utility.set_location('At:'|| l_proc, 25);

  IF p_form_template_id is not null THEN
    OPEN cur_frm_prop_2;
    FETCH cur_frm_prop_2 INTO l_form_property_id;
    CLOSE cur_frm_prop_2;
  END IF;

  hr_utility.set_location('At:'|| l_proc, 30);

  hr_fmp_upd.upd(p_form_property_id             => l_form_property_id
             ,p_object_version_number        => p_object_version_number
             ,p_help_target                  => p_help_target
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
  -- When in validation only mode raise the Validate_Enabled exception
  --
  hr_utility.set_location('At:'|| l_proc, 35);

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
    rollback to update_form_property;
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
    rollback to update_form_property;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_form_property;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_form_property >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_form_property
  (p_validate                      in     boolean  default false
  ,p_form_property_id                in number default null
  ,p_object_version_number           in     number
  ,p_application_id                  in number default null
  ,p_form_id                         in number default null
  ,p_form_template_id                in number default null
  ) is
  --
  -- Declare cursors and local variables
  --

  CURSOR cur_frm_prop_1
  IS
  SELECT form_property_id
  FROM hr_form_properties
  WHERE application_id = p_application_id
  AND form_id = p_form_id;

  CURSOR cur_frm_prop_2
  IS
  SELECT form_property_id
  FROM hr_form_properties
  WHERE form_template_id = p_form_template_id;

  l_form_property_id number;
  l_proc                varchar2(72) := g_package||'delete_form_property';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_form_property;
  --
  -- Validation in addition to Row Handlers
  --

  hr_utility.set_location('At:'|| l_proc, 15);

  IF ( p_form_property_id is not null ) AND
     (p_application_id is not null OR p_form_id is not null OR
      p_form_template_id is not null) THEN
    -- error message
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ELSIF (p_application_id is not null OR p_form_id is not null) AND
        ( p_form_property_id is not null OR p_form_template_id is not null) THEN
    -- error message
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ELSIF( p_form_template_id is not null) AND
       ( p_form_property_id is not null OR
         p_application_id is not null OR p_form_id is not null) THEN
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

  l_form_property_id := p_form_property_id;

  IF ( p_application_id is not null AND p_form_id is not null) THEN
    OPEN cur_frm_prop_1;
    FETCH cur_frm_prop_1 INTO l_form_property_id;
    CLOSE cur_frm_prop_1;
  END IF;

  hr_utility.set_location('At:'|| l_proc, 25);

  IF p_form_template_id is not null THEN
    OPEN cur_frm_prop_2;
    FETCH cur_frm_prop_2 INTO l_form_property_id;
    CLOSE cur_frm_prop_2;
  END IF;

  hr_utility.set_location('At:'|| l_proc, 30);

  hr_fmp_del.del(p_form_property_id             => l_form_property_id
                ,p_object_version_number        => p_object_version_number);

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  hr_utility.set_location('At:'|| l_proc, 35);

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
    rollback to delete_form_property;
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
    rollback to delete_form_property;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_form_property;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< copy_form_property >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure copy_form_property
  (p_validate                        in     boolean  default false
  ,p_effective_date                  in     date
  ,p_application_id                  in number
  ,p_form_id                         in number
  ,p_form_template_id                in number
  ,p_help_target                     in varchar2 default hr_api.g_varchar2
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
  ,p_form_property_id                  out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --

-- added a outer join so that the correct values are returned
-- if there are no entries in the properties table
  Type l_rec_type Is Record
  (help_target hr_form_properties.help_target%TYPE
  ,information_category hr_form_properties.information_category%TYPE
  ,information1 hr_form_properties.information1%TYPE
  ,information2 hr_form_properties.information2%TYPE
  ,information3 hr_form_properties.information3%TYPE
  ,information4 hr_form_properties.information4%TYPE
  ,information5 hr_form_properties.information5%TYPE
  ,information6 hr_form_properties.information6%TYPE
  ,information7 hr_form_properties.information7%TYPE
  ,information8 hr_form_properties.information8%TYPE
  ,information9 hr_form_properties.information9%TYPE
  ,information10 hr_form_properties.information10%TYPE
  ,information11 hr_form_properties.information11%TYPE
  ,information12 hr_form_properties.information12%TYPE
  ,information13 hr_form_properties.information13%TYPE
  ,information14 hr_form_properties.information14%TYPE
  ,information15 hr_form_properties.information15%TYPE
  ,information16 hr_form_properties.information16%TYPE
  ,information17 hr_form_properties.information17%TYPE
  ,information18 hr_form_properties.information18%TYPE
  ,information19 hr_form_properties.information19%TYPE
  ,information20 hr_form_properties.information20%TYPE
  ,information21 hr_form_properties.information21%TYPE
  ,information22 hr_form_properties.information22%TYPE
  ,information23 hr_form_properties.information23%TYPE
  ,information24 hr_form_properties.information24%TYPE
  ,information25 hr_form_properties.information25%TYPE
  ,information26 hr_form_properties.information26%TYPE
  ,information27 hr_form_properties.information27%TYPE
  ,information28 hr_form_properties.information28%TYPE
  ,information29 hr_form_properties.information29%TYPE
  ,information30 hr_form_properties.information30%TYPE);

  l_rec l_rec_type;

-- ask john , bpd says default for all is information1
  CURSOR cur_form_properties
  IS
  SELECT DECODE(p_help_target,hr_api.g_varchar2,fmp.help_target,p_help_target)
  ,DECODE(p_information_category,hr_api.g_varchar2,fmp.information_category,p_information_category)
  ,DECODE(p_information1,hr_api.g_varchar2,fmp.information1,p_information1)
  ,DECODE(p_information2,hr_api.g_varchar2,fmp.information2,p_information2)
  ,DECODE(p_information3,hr_api.g_varchar2,fmp.information3,p_information3)
  ,DECODE(p_information4,hr_api.g_varchar2,fmp.information4,p_information4)
  ,DECODE(p_information5,hr_api.g_varchar2,fmp.information5,p_information5)
  ,DECODE(p_information6,hr_api.g_varchar2,fmp.information6,p_information6)
  ,DECODE(p_information7,hr_api.g_varchar2,fmp.information7,p_information7)
  ,DECODE(p_information8,hr_api.g_varchar2,fmp.information8,p_information8)
  ,DECODE(p_information9,hr_api.g_varchar2,fmp.information9,p_information9)
  ,DECODE(p_information10,hr_api.g_varchar2,fmp.information10,p_information10)
  ,DECODE(p_information11,hr_api.g_varchar2,fmp.information11,p_information11)
  ,DECODE(p_information12,hr_api.g_varchar2,fmp.information12,p_information12)
  ,DECODE(p_information13,hr_api.g_varchar2,fmp.information13,p_information13)
  ,DECODE(p_information14,hr_api.g_varchar2,fmp.information14,p_information14)
  ,DECODE(p_information15,hr_api.g_varchar2,fmp.information15,p_information15)
  ,DECODE(p_information16,hr_api.g_varchar2,fmp.information16,p_information16)
  ,DECODE(p_information17,hr_api.g_varchar2,fmp.information17,p_information17)
  ,DECODE(p_information18,hr_api.g_varchar2,fmp.information18,p_information18)
  ,DECODE(p_information19,hr_api.g_varchar2,fmp.information19,p_information19)
  ,DECODE(p_information20,hr_api.g_varchar2,fmp.information20,p_information20)
  ,DECODE(p_information21,hr_api.g_varchar2,fmp.information21,p_information21)
  ,DECODE(p_information22,hr_api.g_varchar2,fmp.information22,p_information22)
  ,DECODE(p_information23,hr_api.g_varchar2,fmp.information23,p_information23)
  ,DECODE(p_information24,hr_api.g_varchar2,fmp.information24,p_information24)
  ,DECODE(p_information25,hr_api.g_varchar2,fmp.information25,p_information25)
  ,DECODE(p_information26,hr_api.g_varchar2,fmp.information26,p_information26)
  ,DECODE(p_information27,hr_api.g_varchar2,fmp.information27,p_information27)
  ,DECODE(p_information28,hr_api.g_varchar2,fmp.information28,p_information28)
  ,DECODE(p_information29,hr_api.g_varchar2,fmp.information29,p_information29)
  ,DECODE(p_information30,hr_api.g_varchar2,fmp.information30,p_information30)
  FROM hr_form_properties fmp
       , fnd_application fnd
  WHERE fmp.application_id (+) = fnd.application_id
  AND fnd.application_id = p_application_id
  AND fmp.form_id (+) = p_form_id;

  CURSOR cur_check
  IS
  SELECT 1
  FROM hr_form_templates tmp
  WHERE tmp.form_template_id = p_form_template_id
  AND tmp.application_id = p_application_id
  AND tmp.form_id = p_form_id;

  l_check number;
  l_form_property_id number;
  l_object_version_number number;
  l_proc                varchar2(72) := g_package||'copy_form_property';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint copy_form_property;
  --
  -- Truncate the time portion from all IN date parameters
  --
     -- p_effective_date := TRUNC(p_effective_date);
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

  OPEN cur_form_properties;
  FETCH cur_form_properties INTO l_rec;
  CLOSE cur_form_properties;

  hr_utility.set_location('At:'|| l_proc, 25);

  hr_fmp_ins.ins(p_form_template_id             => p_form_template_id
             ,p_help_target                  => l_rec.help_target
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
             ,p_form_property_id             => l_form_property_id
             ,p_object_version_number        => l_object_version_number);

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  hr_utility.set_location('At:'|| l_proc, 30);

  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_form_property_id             := l_form_property_id;
  p_object_version_number        := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to copy_form_property;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_form_property_id             := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to copy_form_property;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end copy_form_property;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------< copy_form_property - overload>----------------------|
-- ----------------------------------------------------------------------------
--
procedure copy_form_property
  (p_validate                        in     boolean  default false
  ,p_effective_date                  in     date
  ,p_form_template_id_to             in number
  ,p_form_template_id_from           in number
  ,p_help_target                     in varchar2 default hr_api.g_varchar2
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
  ,p_form_property_id                  out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
  --
  -- Declare cursors and local variables

-- added a outer join so that the correct values are returned
-- if there are no entries in the properties table
  Type l_rec_type Is Record
  (help_target hr_form_properties.help_target%TYPE
  ,information_category hr_form_properties.information_category%TYPE
  ,information1 hr_form_properties.information1%TYPE
  ,information2 hr_form_properties.information2%TYPE
  ,information3 hr_form_properties.information3%TYPE
  ,information4 hr_form_properties.information4%TYPE
  ,information5 hr_form_properties.information5%TYPE
  ,information6 hr_form_properties.information6%TYPE
  ,information7 hr_form_properties.information7%TYPE
  ,information8 hr_form_properties.information8%TYPE
  ,information9 hr_form_properties.information9%TYPE
  ,information10 hr_form_properties.information10%TYPE
  ,information11 hr_form_properties.information11%TYPE
  ,information12 hr_form_properties.information12%TYPE
  ,information13 hr_form_properties.information13%TYPE
  ,information14 hr_form_properties.information14%TYPE
  ,information15 hr_form_properties.information15%TYPE
  ,information16 hr_form_properties.information16%TYPE
  ,information17 hr_form_properties.information17%TYPE
  ,information18 hr_form_properties.information18%TYPE
  ,information19 hr_form_properties.information19%TYPE
  ,information20 hr_form_properties.information20%TYPE
  ,information21 hr_form_properties.information21%TYPE
  ,information22 hr_form_properties.information22%TYPE
  ,information23 hr_form_properties.information23%TYPE
  ,information24 hr_form_properties.information24%TYPE
  ,information25 hr_form_properties.information25%TYPE
  ,information26 hr_form_properties.information26%TYPE
  ,information27 hr_form_properties.information27%TYPE
  ,information28 hr_form_properties.information28%TYPE
  ,information29 hr_form_properties.information29%TYPE
  ,information30 hr_form_properties.information30%TYPE);

  l_rec l_rec_type;

-- ask john , bpd says default for all is information1
  CURSOR cur_form_properties
  IS
  SELECT DECODE(p_help_target,hr_api.g_varchar2,fmp.help_target,p_help_target)
  ,DECODE(p_information_category,hr_api.g_varchar2,fmp.information_category,p_information_category)
  ,DECODE(p_information1,hr_api.g_varchar2,fmp.information1,p_information1)
  ,DECODE(p_information2,hr_api.g_varchar2,fmp.information2,p_information2)
  ,DECODE(p_information3,hr_api.g_varchar2,fmp.information3,p_information3)
  ,DECODE(p_information4,hr_api.g_varchar2,fmp.information4,p_information4)
  ,DECODE(p_information5,hr_api.g_varchar2,fmp.information5,p_information5)
  ,DECODE(p_information6,hr_api.g_varchar2,fmp.information6,p_information6)
  ,DECODE(p_information7,hr_api.g_varchar2,fmp.information7,p_information7)
  ,DECODE(p_information8,hr_api.g_varchar2,fmp.information8,p_information8)
  ,DECODE(p_information9,hr_api.g_varchar2,fmp.information9,p_information9)
  ,DECODE(p_information10,hr_api.g_varchar2,fmp.information10,p_information10)
  ,DECODE(p_information11,hr_api.g_varchar2,fmp.information11,p_information11)
  ,DECODE(p_information12,hr_api.g_varchar2,fmp.information12,p_information12)
  ,DECODE(p_information13,hr_api.g_varchar2,fmp.information13,p_information13)
  ,DECODE(p_information14,hr_api.g_varchar2,fmp.information14,p_information14)
  ,DECODE(p_information15,hr_api.g_varchar2,fmp.information15,p_information15)
  ,DECODE(p_information16,hr_api.g_varchar2,fmp.information16,p_information16)
  ,DECODE(p_information17,hr_api.g_varchar2,fmp.information17,p_information17)
  ,DECODE(p_information18,hr_api.g_varchar2,fmp.information18,p_information18)
  ,DECODE(p_information19,hr_api.g_varchar2,fmp.information19,p_information19)
  ,DECODE(p_information20,hr_api.g_varchar2,fmp.information20,p_information20)
  ,DECODE(p_information21,hr_api.g_varchar2,fmp.information21,p_information21)
  ,DECODE(p_information22,hr_api.g_varchar2,fmp.information22,p_information22)
  ,DECODE(p_information23,hr_api.g_varchar2,fmp.information23,p_information23)
  ,DECODE(p_information24,hr_api.g_varchar2,fmp.information24,p_information24)
  ,DECODE(p_information25,hr_api.g_varchar2,fmp.information25,p_information25)
  ,DECODE(p_information26,hr_api.g_varchar2,fmp.information26,p_information26)
  ,DECODE(p_information27,hr_api.g_varchar2,fmp.information27,p_information27)
  ,DECODE(p_information28,hr_api.g_varchar2,fmp.information28,p_information28)
  ,DECODE(p_information29,hr_api.g_varchar2,fmp.information29,p_information29)
  ,DECODE(p_information30,hr_api.g_varchar2,fmp.information30,p_information30)
  FROM hr_form_properties fmp
       ,hr_form_templates_b hft
  WHERE fmp.form_template_id (+) = hft.form_template_id
  AND hft.form_template_id = p_form_template_id_from;

  --
  CURSOR cur_check
  IS
  SELECT tmp.application_id
  ,tmp.form_id
  FROM hr_form_templates tmp
  WHERE tmp.form_template_id = p_form_template_id_from
  INTERSECT
  SELECT tmp.application_id
  ,tmp.form_id
  FROM hr_form_templates tmp
  WHERE tmp.form_template_id = p_form_template_id_to;

  l_application_id number;
  l_form_id number;
  l_object_version_number number;
  l_proc                varchar2(72) := g_package||'copy_form_property';
  l_form_property_id number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint copy_form_property;
  --
  -- Truncate the time portion from all IN date parameters
  --
  -- p_effective_date := TRUNC(p_effective_date);
  --
  -- Validation in addition to Row Handlers
  --
  hr_utility.set_location('At:'|| l_proc, 15);

  OPEN cur_check;
  FETCH cur_check INTO l_application_id , l_form_id;
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

  OPEN cur_form_properties;
  FETCH cur_form_properties INTO l_rec;
  CLOSE cur_form_properties;

  hr_utility.set_location('At:'|| l_proc, 25);

  hr_fmp_ins.ins(p_form_template_id             => p_form_template_id_to
             ,p_help_target                  => l_rec.help_target
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
             ,p_form_property_id             => l_form_property_id
             ,p_object_version_number        => l_object_version_number);

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  hr_utility.set_location('At:'|| l_proc, 30);

  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_form_property_id             := l_form_property_id;
  p_object_version_number        := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to copy_form_property;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_form_property_id             := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to copy_form_property;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end copy_form_property;
--
end hr_form_properties_bsi;

/
