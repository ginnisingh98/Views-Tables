--------------------------------------------------------
--  DDL for Package Body HR_ABSENCE_TYPE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ABSENCE_TYPE_API" as
/* $Header: peabbapi.pkb 120.2.12010000.2 2008/08/06 08:52:03 ubhat ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := ' hr_absence_type_api.';
g_debug boolean := hr_utility.debug_enabled;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_absence_type >-------------------------|
-- ----------------------------------------------------------------------------
procedure create_absence_type
  (p_validate                      in  boolean     default false
  ,p_language_code                 in  varchar2    default hr_api.userenv_lang
  ,p_business_group_id             in  number      default null
  ,p_input_value_id                in  number      default null
  ,p_date_effective                in  date
  ,p_date_end                      in out nocopy date
  ,p_name                          in  varchar2
  ,p_absence_category              in  varchar2    default null
  ,p_comments                      in  varchar2    default null
  ,p_hours_or_days                 in  varchar2    default null
  ,p_inc_or_dec_flag               in  varchar2    default null
  ,p_attribute_category            in  varchar2    default null
  ,p_attribute1                    in  varchar2    default null
  ,p_attribute2                    in  varchar2    default null
  ,p_attribute3                    in  varchar2    default null
  ,p_attribute4                    in  varchar2    default null
  ,p_attribute5                    in  varchar2    default null
  ,p_attribute6                    in  varchar2    default null
  ,p_attribute7                    in  varchar2    default null
  ,p_attribute8                    in  varchar2    default null
  ,p_attribute9                    in  varchar2    default null
  ,p_attribute10                   in  varchar2    default null
  ,p_attribute11                   in  varchar2    default null
  ,p_attribute12                   in  varchar2    default null
  ,p_attribute13                   in  varchar2    default null
  ,p_attribute14                   in  varchar2    default null
  ,p_attribute15                   in  varchar2    default null
  ,p_attribute16                   in  varchar2    default null
  ,p_attribute17                   in  varchar2    default null
  ,p_attribute18                   in  varchar2    default null
  ,p_attribute19                   in  varchar2    default null
  ,p_attribute20                   in  varchar2    default null
  ,p_information_category          in  varchar2    default null
  ,p_information1                  in  varchar2    default null
  ,p_information2                  in  varchar2    default null
  ,p_information3                  in  varchar2    default null
  ,p_information4                  in  varchar2    default null
  ,p_information5                  in  varchar2    default null
  ,p_information6                  in  varchar2    default null
  ,p_information7                  in  varchar2    default null
  ,p_information8                  in  varchar2    default null
  ,p_information9                  in  varchar2    default null
  ,p_information10                 in  varchar2    default null
  ,p_information11                 in  varchar2    default null
  ,p_information12                 in  varchar2    default null
  ,p_information13                 in  varchar2    default null
  ,p_information14                 in  varchar2    default null
  ,p_information15                 in  varchar2    default null
  ,p_information16                 in  varchar2    default null
  ,p_information17                 in  varchar2    default null
  ,p_information18                 in  varchar2    default null
  ,p_information19                 in  varchar2    default null
  ,p_information20                 in  varchar2    default null
  ,p_user_role                     in  varchar2    default null
  ,p_assignment_status_type_id     in  number      default null
  ,p_advance_pay                   in  varchar2    default null
  ,p_absence_overlap_flag          in  varchar2    default null
  ,p_absence_attendance_type_id       out nocopy number
  ,p_object_version_number            out nocopy number
   ) is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number      number;
  l_absence_attendance_type_id number;
  l_date_effective             date;
  l_date_end                   date;
  l_date_end_orig              date := p_date_end;
  l_proc               varchar2(72) := g_package||'create_absence_type';
  l_language_code      fnd_languages.language_code%TYPE;
  --
begin
  --
  if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint
  --
  savepoint create_absence_type;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_date_effective := trunc(p_date_effective);
  l_date_end       := trunc(p_date_end);
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
    hr_absence_type_bk1.create_absence_type_b
	 (p_language_code           => l_language_code
	 ,p_business_group_id       => p_business_group_id
	 ,p_input_value_id          => p_input_value_id
	 ,p_date_effective          => l_date_effective
	 ,p_date_end                => l_date_end
	 ,p_name                    => p_name
	 ,p_absence_category        => p_absence_category
	 ,p_comments                => p_comments
         ,p_hours_or_days           => p_hours_or_days
	 ,p_inc_or_dec_flag         => p_inc_or_dec_flag
	 ,p_attribute_category      => p_attribute_category
	 ,p_attribute1              => p_attribute1
	 ,p_attribute2              => p_attribute2
	 ,p_attribute3              => p_attribute3
	 ,p_attribute4              => p_attribute4
	 ,p_attribute5              => p_attribute5
	 ,p_attribute6              => p_attribute6
	 ,p_attribute7              => p_attribute7
	 ,p_attribute8              => p_attribute8
	 ,p_attribute9              => p_attribute9
	 ,p_attribute10             => p_attribute10
	 ,p_attribute11             => p_attribute11
	 ,p_attribute12             => p_attribute12
	 ,p_attribute13             => p_attribute13
	 ,p_attribute14             => p_attribute14
	 ,p_attribute15             => p_attribute15
	 ,p_attribute16             => p_attribute16
	 ,p_attribute17             => p_attribute17
	 ,p_attribute18             => p_attribute18
	 ,p_attribute19             => p_attribute19
	 ,p_attribute20             => p_attribute20
	 ,p_information_category    => p_information_category
	 ,p_information1            => p_information1
	 ,p_information2            => p_information2
	 ,p_information3            => p_information3
	 ,p_information4            => p_information4
	 ,p_information5            => p_information5
	 ,p_information6            => p_information6
	 ,p_information7            => p_information7
	 ,p_information8            => p_information8
	 ,p_information9            => p_information9
	 ,p_information10           => p_information10
	 ,p_information11           => p_information11
	 ,p_information12           => p_information12
	 ,p_information13           => p_information13
	 ,p_information14           => p_information14
	 ,p_information15           => p_information15
	 ,p_information16           => p_information16
	 ,p_information17           => p_information17
	 ,p_information18           => p_information18
	 ,p_information19           => p_information19
	 ,p_information20           => p_information20
         ,p_user_role               => p_user_role
         ,p_assignment_status_type_id  => p_assignment_status_type_id
         ,p_advance_pay             => p_advance_pay
         ,p_absence_overlap_flag    => p_absence_overlap_flag
	 );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_absence_type'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  if p_business_group_id is null
  and p_input_value_id is not null then
    fnd_message.set_name('PER','PER_449173_ABB_NO_BG_NO_INPUT');
    fnd_message.raise_error;
  end if;
  --
  if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 20);
  end if;
  --
  --
  -- Process Logic
  --
  per_abb_ins.ins
  (p_business_group_id              => p_business_group_id
  ,p_date_effective                 => l_date_effective
  ,p_name                           => p_name
  ,p_input_value_id                 => p_input_value_id
  ,p_absence_category               => p_absence_category
  ,p_comments                       => p_comments
  ,p_date_end                       => l_date_end
  ,p_hours_or_days                  => p_hours_or_days
  ,p_inc_or_dec_flag                => p_inc_or_dec_flag
  ,p_attribute_category             => p_attribute_category
  ,p_attribute1                     => p_attribute1
  ,p_attribute2                     => p_attribute2
  ,p_attribute3                     => p_attribute3
  ,p_attribute4                     => p_attribute4
  ,p_attribute5                     => p_attribute5
  ,p_attribute6                     => p_attribute6
  ,p_attribute7                     => p_attribute7
  ,p_attribute8                     => p_attribute8
  ,p_attribute9                     => p_attribute9
  ,p_attribute10                    => p_attribute10
  ,p_attribute11                    => p_attribute11
  ,p_attribute12                    => p_attribute12
  ,p_attribute13                    => p_attribute13
  ,p_attribute14                    => p_attribute14
  ,p_attribute15                    => p_attribute15
  ,p_attribute16                    => p_attribute16
  ,p_attribute17                    => p_attribute17
  ,p_attribute18                    => p_attribute18
  ,p_attribute19                    => p_attribute19
  ,p_attribute20                    => p_attribute20
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
  ,p_user_role                      => p_user_role
  ,p_assignment_status_type_id      => p_assignment_status_type_id
  ,p_advance_pay                    => p_advance_pay
  ,p_absence_overlap_flag           => p_absence_overlap_flag
  ,p_absence_attendance_type_id     => l_absence_attendance_type_id
  ,p_object_version_number          => l_object_version_number
  );
  --
  if g_debug then
    hr_utility.set_location(l_proc, 30);
    hr_utility.set_location(to_char(l_absence_attendance_type_id), 30);
  end if;
  --
  per_abt_ins.ins_tl
  (p_language_code               => l_language_code
  ,p_absence_attendance_type_id  => l_absence_attendance_type_id
  ,p_name                        => p_name
   );
  --
  --  Call to create database items
  --
  hrdyndbi.create_absence_dict(l_absence_attendance_type_id);
  --
  -- Call After Process User Hook
  --
  begin
    hr_absence_type_bk1.create_absence_type_a
	 (p_language_code           => l_language_code
	 ,p_business_group_id       => p_business_group_id
	 ,p_input_value_id          => p_input_value_id
	 ,p_date_effective          => l_date_effective
	 ,p_date_end                => l_date_end
	 ,p_name                    => p_name
	 ,p_absence_category        => p_absence_category
	 ,p_comments                => p_comments
         ,p_hours_or_days           => p_hours_or_days
	 ,p_inc_or_dec_flag         => p_inc_or_dec_flag
	 ,p_attribute_category      => p_attribute_category
	 ,p_attribute1              => p_attribute1
	 ,p_attribute2              => p_attribute2
	 ,p_attribute3              => p_attribute3
	 ,p_attribute4              => p_attribute4
	 ,p_attribute5              => p_attribute5
	 ,p_attribute6              => p_attribute6
	 ,p_attribute7              => p_attribute7
	 ,p_attribute8              => p_attribute8
	 ,p_attribute9              => p_attribute9
	 ,p_attribute10             => p_attribute10
	 ,p_attribute11             => p_attribute11
	 ,p_attribute12             => p_attribute12
	 ,p_attribute13             => p_attribute13
	 ,p_attribute14             => p_attribute14
	 ,p_attribute15             => p_attribute15
	 ,p_attribute16             => p_attribute16
	 ,p_attribute17             => p_attribute17
	 ,p_attribute18             => p_attribute18
	 ,p_attribute19             => p_attribute19
	 ,p_attribute20             => p_attribute20
	 ,p_information_category    => p_information_category
	 ,p_information1            => p_information1
	 ,p_information2            => p_information2
	 ,p_information3            => p_information3
	 ,p_information4            => p_information4
	 ,p_information5            => p_information5
	 ,p_information6            => p_information6
	 ,p_information7            => p_information7
	 ,p_information8            => p_information8
	 ,p_information9            => p_information9
	 ,p_information10           => p_information10
	 ,p_information11           => p_information11
	 ,p_information12           => p_information12
	 ,p_information13           => p_information13
	 ,p_information14           => p_information14
	 ,p_information15           => p_information15
	 ,p_information16           => p_information16
	 ,p_information17           => p_information17
	 ,p_information18           => p_information18
	 ,p_information19           => p_information19
	 ,p_information20           => p_information20
	 ,p_user_role               => p_user_role
	 ,p_assignment_status_type_id    => p_assignment_status_type_id
	 ,p_advance_pay             => p_advance_pay
         ,p_absence_overlap_flag    => p_absence_overlap_flag
         ,p_absence_attendance_type_id => l_absence_attendance_type_id
         ,p_object_version_number      => l_object_version_number
	 );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_absence_type'
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
  -- Set all IN OUT and OUT parameters with out values
  --
  p_absence_attendance_type_id := l_absence_attendance_type_id;
  p_object_version_number  := l_object_version_number;
  p_date_end := l_date_end;
  --
  --
  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 70);
  end if;
  --
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_absence_type;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_absence_attendance_type_id := null;
    p_object_version_number  := null;
    p_date_end := l_date_end_orig;
  --
  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  end if;
  --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_absence_type;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_absence_attendance_type_id := null;
    p_object_version_number  := null;
    p_date_end := l_date_end_orig;
    --
    if g_debug then
      hr_utility.set_location(' Leaving:'||l_proc, 90);
    end if;
    --
    raise;
end create_absence_type;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_absence_type >--------------------------|
-- ----------------------------------------------------------------------------
procedure update_absence_type
  (p_validate                      in  boolean     default false
  ,p_absence_attendance_type_id    in  number
  ,p_language_code                 in  varchar2    default hr_api.userenv_lang
  ,p_input_value_id                in  number      default hr_api.g_number
  ,p_date_effective                in  date        default hr_api.g_date
  ,p_date_end                      in out nocopy date
  ,p_name                          in  varchar2    default hr_api.g_varchar2
  ,p_absence_category              in  varchar2    default hr_api.g_varchar2
  ,p_comments                      in  varchar2    default hr_api.g_varchar2
  ,p_hours_or_days                 in  varchar2    default hr_api.g_varchar2
  ,p_inc_or_dec_flag               in  varchar2    default hr_api.g_varchar2
  ,p_attribute_category            in  varchar2    default hr_api.g_varchar2
  ,p_attribute1                    in  varchar2    default hr_api.g_varchar2
  ,p_attribute2                    in  varchar2    default hr_api.g_varchar2
  ,p_attribute3                    in  varchar2    default hr_api.g_varchar2
  ,p_attribute4                    in  varchar2    default hr_api.g_varchar2
  ,p_attribute5                    in  varchar2    default hr_api.g_varchar2
  ,p_attribute6                    in  varchar2    default hr_api.g_varchar2
  ,p_attribute7                    in  varchar2    default hr_api.g_varchar2
  ,p_attribute8                    in  varchar2    default hr_api.g_varchar2
  ,p_attribute9                    in  varchar2    default hr_api.g_varchar2
  ,p_attribute10                   in  varchar2    default hr_api.g_varchar2
  ,p_attribute11                   in  varchar2    default hr_api.g_varchar2
  ,p_attribute12                   in  varchar2    default hr_api.g_varchar2
  ,p_attribute13                   in  varchar2    default hr_api.g_varchar2
  ,p_attribute14                   in  varchar2    default hr_api.g_varchar2
  ,p_attribute15                   in  varchar2    default hr_api.g_varchar2
  ,p_attribute16                   in  varchar2    default hr_api.g_varchar2
  ,p_attribute17                   in  varchar2    default hr_api.g_varchar2
  ,p_attribute18                   in  varchar2    default hr_api.g_varchar2
  ,p_attribute19                   in  varchar2    default hr_api.g_varchar2
  ,p_attribute20                   in  varchar2    default hr_api.g_varchar2
  ,p_information_category          in  varchar2    default hr_api.g_varchar2
  ,p_information1                  in  varchar2    default hr_api.g_varchar2
  ,p_information2                  in  varchar2    default hr_api.g_varchar2
  ,p_information3                  in  varchar2    default hr_api.g_varchar2
  ,p_information4                  in  varchar2    default hr_api.g_varchar2
  ,p_information5                  in  varchar2    default hr_api.g_varchar2
  ,p_information6                  in  varchar2    default hr_api.g_varchar2
  ,p_information7                  in  varchar2    default hr_api.g_varchar2
  ,p_information8                  in  varchar2    default hr_api.g_varchar2
  ,p_information9                  in  varchar2    default hr_api.g_varchar2
  ,p_information10                 in  varchar2    default hr_api.g_varchar2
  ,p_information11                 in  varchar2    default hr_api.g_varchar2
  ,p_information12                 in  varchar2    default hr_api.g_varchar2
  ,p_information13                 in  varchar2    default hr_api.g_varchar2
  ,p_information14                 in  varchar2    default hr_api.g_varchar2
  ,p_information15                 in  varchar2    default hr_api.g_varchar2
  ,p_information16                 in  varchar2    default hr_api.g_varchar2
  ,p_information17                 in  varchar2    default hr_api.g_varchar2
  ,p_information18                 in  varchar2    default hr_api.g_varchar2
  ,p_information19                 in  varchar2    default hr_api.g_varchar2
  ,p_information20                 in  varchar2    default hr_api.g_varchar2
  ,p_user_role                     in  varchar2    default hr_api.g_varchar2
  ,p_assignment_status_type_id     in  number      default hr_api.g_number
  ,p_advance_pay                   in  varchar2    default hr_api.g_varchar2
  ,p_absence_overlap_flag          in  varchar2    default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number      number;
  l_absence_attendance_type_id number;
  l_date_effective             date;
  l_date_end                   date;
  l_date_end_orig              date := p_date_end;
  l_proc               varchar2(72) := g_package||'update_absence_type';
  l_language_code      fnd_languages.language_code%TYPE;
  --
  cursor csr_derived_row is
  select business_group_id,input_value_id,date_effective
  from per_absence_attendance_types
  where absence_attendance_type_id = p_absence_attendance_type_id;
  --
  l_derived_rec csr_derived_row%rowtype;
  --
begin
  --
  if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint
  --
  savepoint update_absence_type;
  --
  l_object_version_number  := p_object_version_number;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_date_effective := trunc(p_date_effective);
  l_date_end       := trunc(p_date_end);
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
    hr_absence_type_bk2.update_absence_type_b
	 (p_language_code           => l_language_code
         ,p_absence_attendance_type_id => p_absence_attendance_type_id
	 ,p_input_value_id          => p_input_value_id
	 ,p_date_effective          => l_date_effective
	 ,p_date_end                => l_date_end
	 ,p_name                    => p_name
	 ,p_absence_category        => p_absence_category
	 ,p_comments                => p_comments
         ,p_hours_or_days           => p_hours_or_days
	 ,p_inc_or_dec_flag         => p_inc_or_dec_flag
	 ,p_attribute_category      => p_attribute_category
	 ,p_attribute1              => p_attribute1
	 ,p_attribute2              => p_attribute2
	 ,p_attribute3              => p_attribute3
	 ,p_attribute4              => p_attribute4
	 ,p_attribute5              => p_attribute5
	 ,p_attribute6              => p_attribute6
	 ,p_attribute7              => p_attribute7
	 ,p_attribute8              => p_attribute8
	 ,p_attribute9              => p_attribute9
	 ,p_attribute10             => p_attribute10
	 ,p_attribute11             => p_attribute11
	 ,p_attribute12             => p_attribute12
	 ,p_attribute13             => p_attribute13
	 ,p_attribute14             => p_attribute14
	 ,p_attribute15             => p_attribute15
	 ,p_attribute16             => p_attribute16
	 ,p_attribute17             => p_attribute17
	 ,p_attribute18             => p_attribute18
	 ,p_attribute19             => p_attribute19
	 ,p_attribute20             => p_attribute20
	 ,p_information_category    => p_information_category
	 ,p_information1            => p_information1
	 ,p_information2            => p_information2
	 ,p_information3            => p_information3
	 ,p_information4            => p_information4
	 ,p_information5            => p_information5
	 ,p_information6            => p_information6
	 ,p_information7            => p_information7
	 ,p_information8            => p_information8
	 ,p_information9            => p_information9
	 ,p_information10           => p_information10
	 ,p_information11           => p_information11
	 ,p_information12           => p_information12
	 ,p_information13           => p_information13
	 ,p_information14           => p_information14
	 ,p_information15           => p_information15
	 ,p_information16           => p_information16
	 ,p_information17           => p_information17
	 ,p_information18           => p_information18
	 ,p_information19           => p_information19
	 ,p_information20           => p_information20
	 ,p_user_role               => p_user_role
	 ,p_assignment_status_type_id    => p_assignment_status_type_id
	 ,p_advance_pay             => p_advance_pay
	 ,p_absence_overlap_flag    => p_absence_overlap_flag
         ,p_object_version_number   => l_object_version_number
	 );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_absence_type'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --  Get the business_group_id and other parameters for use later
  --
  open csr_derived_row;
  fetch csr_derived_row into l_derived_rec;
  close csr_derived_row;
  --
  if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 20);
  end if;
  --
  if l_derived_rec.business_group_id is null
  and nvl(p_input_value_id,hr_api.g_number) <> hr_api.g_number then
    fnd_message.set_name('PER','PER_449173_ABB_NO_BG_NO_INPUT');
    fnd_message.raise_error;
  end if;
  --
  if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 30);
  end if;
  --
  -- Process Logic
  --
  per_abb_upd.upd
  (p_absence_attendance_type_id   => p_absence_attendance_type_id
  ,p_object_version_number        => l_object_version_number
  ,p_business_group_id            => l_derived_rec.business_group_id
  ,p_date_effective               => l_date_effective
  ,p_name                         => p_name
  ,p_input_value_id               => p_input_value_id
  ,p_absence_category             => p_absence_category
  ,p_comments                     => p_comments
  ,p_date_end                     => l_date_end
  ,p_hours_or_days                => p_hours_or_days
  ,p_inc_or_dec_flag              => p_inc_or_dec_flag
  ,p_attribute_category           => p_attribute_category
  ,p_attribute1                   => p_attribute1
  ,p_attribute2                   => p_attribute2
  ,p_attribute3                   => p_attribute3
  ,p_attribute4                   => p_attribute4
  ,p_attribute5                   => p_attribute5
  ,p_attribute6                   => p_attribute6
  ,p_attribute7                   => p_attribute7
  ,p_attribute8                   => p_attribute8
  ,p_attribute9                   => p_attribute9
  ,p_attribute10                  => p_attribute10
  ,p_attribute11                  => p_attribute11
  ,p_attribute12                  => p_attribute12
  ,p_attribute13                  => p_attribute13
  ,p_attribute14                  => p_attribute14
  ,p_attribute15                  => p_attribute15
  ,p_attribute16                  => p_attribute16
  ,p_attribute17                  => p_attribute17
  ,p_attribute18                  => p_attribute18
  ,p_attribute19                  => p_attribute19
  ,p_attribute20                  => p_attribute20
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
  ,p_user_role                    => p_user_role
  ,p_assignment_status_type_id    => p_assignment_status_type_id
  ,p_absence_overlap_flag         => p_absence_overlap_flag
  ,p_advance_pay                  => p_advance_pay
  );
  --
  if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 50);
  end if;
  --
  per_abt_upd.upd_tl
  (p_language_code               => l_language_code
  ,p_absence_attendance_type_id  => p_absence_attendance_type_id
  ,p_name                        => p_name
  );
  --
  --  Call to create database items
  --
  hrdyndbi.create_absence_dict(p_absence_attendance_type_id);
  --
  -- Call After Process User Hook
  --
  begin
    hr_absence_type_bk2.update_absence_type_a
	 (p_language_code           => l_language_code
         ,p_absence_attendance_type_id => p_absence_attendance_type_id
	 ,p_input_value_id          => p_input_value_id
	 ,p_date_effective          => l_date_effective
	 ,p_date_end                => l_date_end
	 ,p_name                    => p_name
	 ,p_absence_category        => p_absence_category
	 ,p_comments                => p_comments
         ,p_hours_or_days           => p_hours_or_days
	 ,p_inc_or_dec_flag         => p_inc_or_dec_flag
	 ,p_attribute_category      => p_attribute_category
	 ,p_attribute1              => p_attribute1
	 ,p_attribute2              => p_attribute2
	 ,p_attribute3              => p_attribute3
	 ,p_attribute4              => p_attribute4
	 ,p_attribute5              => p_attribute5
	 ,p_attribute6              => p_attribute6
	 ,p_attribute7              => p_attribute7
	 ,p_attribute8              => p_attribute8
	 ,p_attribute9              => p_attribute9
	 ,p_attribute10             => p_attribute10
	 ,p_attribute11             => p_attribute11
	 ,p_attribute12             => p_attribute12
	 ,p_attribute13             => p_attribute13
	 ,p_attribute14             => p_attribute14
	 ,p_attribute15             => p_attribute15
	 ,p_attribute16             => p_attribute16
	 ,p_attribute17             => p_attribute17
	 ,p_attribute18             => p_attribute18
	 ,p_attribute19             => p_attribute19
	 ,p_attribute20             => p_attribute20
	 ,p_information_category    => p_information_category
	 ,p_information1            => p_information1
	 ,p_information2            => p_information2
	 ,p_information3            => p_information3
	 ,p_information4            => p_information4
	 ,p_information5            => p_information5
	 ,p_information6            => p_information6
	 ,p_information7            => p_information7
	 ,p_information8            => p_information8
	 ,p_information9            => p_information9
	 ,p_information10           => p_information10
	 ,p_information11           => p_information11
	 ,p_information12           => p_information12
	 ,p_information13           => p_information13
	 ,p_information14           => p_information14
	 ,p_information15           => p_information15
	 ,p_information16           => p_information16
	 ,p_information17           => p_information17
	 ,p_information18           => p_information18
	 ,p_information19           => p_information19
	 ,p_information20           => p_information20
	 ,p_user_role               => p_user_role
	 ,p_assignment_status_type_id  => p_assignment_status_type_id
	 ,p_advance_pay             => p_advance_pay
	 ,p_absence_overlap_flag    => p_absence_overlap_flag
         ,p_object_version_number   => l_object_version_number
	 );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_absence_type'
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
  -- Set all IN OUT and OUT parameters with out values
  --
  p_object_version_number  := l_object_version_number;
  p_date_end := l_date_end;
  --
  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 60);
  end if;
  --
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_absence_type;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := l_object_version_number;
    p_date_end := l_date_end_orig;
    --
    if g_debug then
      hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_absence_type;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number  := l_object_version_number;
    p_date_end := l_date_end_orig;
    --
    if g_debug then
      hr_utility.set_location(' Leaving:'||l_proc, 90);
    end if;
    --
    raise;
end update_absence_type;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_absence_type >--------------------------|
-- ----------------------------------------------------------------------------
procedure delete_absence_type
  (p_validate                      in  boolean     default false
  ,p_absence_attendance_type_id    in  number
  ,p_object_version_number         in  number
  ) is
  --
  l_proc               varchar2(72) := g_package||'delete_absence_type';
  --
begin
  --
  if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint
  --
  savepoint delete_absence_type;
  --
  -- Call Before Process User Hook
  --
  begin
    hr_absence_type_bk3.delete_absence_type_b
	 (p_absence_attendance_type_id => p_absence_attendance_type_id
         ,p_object_version_number   => p_object_version_number
	 );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_absence_type'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --

  --
  -- Process Logic
  --
  per_abt_del.del_tl
     (p_absence_attendance_type_id           => p_absence_attendance_type_id
      );

  per_abb_del.del
     (p_absence_attendance_type_id           => p_absence_attendance_type_id
     ,p_object_version_number                => p_object_version_number
      );
  --

   /*Fix for the bug 6894537 starts here
      Added the call to delete DBI when the absence type is deleted.*/

   hrdyndbi.delete_absence_dict
      (p_absence_attendance_type_id
      );
      /*Fix for the bug 6894537 ends here*/

  -- Call After Process User Hook
  --
  begin
    hr_absence_type_bk3.delete_absence_type_a
         (p_absence_attendance_type_id => p_absence_attendance_type_id
         ,p_object_version_number   => p_object_version_number
	 );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_absence_type'
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
  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 70);
  end if;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_absence_type;
    --
    if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_absence_type;
    --
    if g_debug then
      hr_utility.set_location(' Leaving:'||l_proc, 90);
    end if;
    --
    raise;
end delete_absence_type;
--
end hr_absence_type_api;

/
