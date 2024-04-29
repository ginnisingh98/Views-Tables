--------------------------------------------------------
--  DDL for Package Body HR_CONTACT_EXTRA_INFO_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CONTACT_EXTRA_INFO_API" as
/* $Header: pereiapi.pkb 115.1 2002/12/10 15:37:01 eumenyio noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_contact_extra_info.';
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_contact_extra_info >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_contact_extra_info
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date,
--  ,p_business_group_id             in     number
--  ,p_non_mandatory_arg             in     number   default null
  p_contact_relationship_id     IN      NUMBER,
  p_information_type            IN      VARCHAR2,
  p_cei_information_category    IN      VARCHAR2        DEFAULT NULL,
  p_cei_information1            IN      VARCHAR2        DEFAULT NULL,
  p_cei_information2            IN      VARCHAR2        DEFAULT NULL,
  p_cei_information3            IN      VARCHAR2        DEFAULT NULL,
  p_cei_information4            IN      VARCHAR2        DEFAULT NULL,
  p_cei_information5            IN      VARCHAR2        DEFAULT NULL,
  p_cei_information6            IN      VARCHAR2        DEFAULT NULL,
  p_cei_information7            IN      VARCHAR2        DEFAULT NULL,
  p_cei_information8            IN      VARCHAR2        DEFAULT NULL,
  p_cei_information9            IN      VARCHAR2        DEFAULT NULL,
  p_cei_information10           IN      VARCHAR2        DEFAULT NULL,
  p_cei_information11           IN      VARCHAR2        DEFAULT NULL,
  p_cei_information12           IN      VARCHAR2        DEFAULT NULL,
  p_cei_information13           IN      VARCHAR2        DEFAULT NULL,
  p_cei_information14           IN      VARCHAR2        DEFAULT NULL,
  p_cei_information15           IN      VARCHAR2        DEFAULT NULL,
  p_cei_information16           IN      VARCHAR2        DEFAULT NULL,
  p_cei_information17           IN      VARCHAR2        DEFAULT NULL,
  p_cei_information18           IN      VARCHAR2        DEFAULT NULL,
  p_cei_information19           IN      VARCHAR2        DEFAULT NULL,
  p_cei_information20           IN      VARCHAR2        DEFAULT NULL,
  p_cei_information21           IN      VARCHAR2        DEFAULT NULL,
  p_cei_information22           IN      VARCHAR2        DEFAULT NULL,
  p_cei_information23           IN      VARCHAR2        DEFAULT NULL,
  p_cei_information24           IN      VARCHAR2        DEFAULT NULL,
  p_cei_information25           IN      VARCHAR2        DEFAULT NULL,
  p_cei_information26           IN      VARCHAR2        DEFAULT NULL,
  p_cei_information27           IN      VARCHAR2        DEFAULT NULL,
  p_cei_information28           IN      VARCHAR2        DEFAULT NULL,
  p_cei_information29           IN      VARCHAR2        DEFAULT NULL,
  p_cei_information30           IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute_category      IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute1              IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute2              IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute3              IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute4              IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute5              IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute6              IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute7              IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute8              IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute9              IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute10             IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute11             IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute12             IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute13             IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute14             IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute15             IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute16             IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute17             IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute18             IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute19             IN      VARCHAR2        DEFAULT NULL,
  p_cei_attribute20             IN      VARCHAR2        DEFAULT NULL
  ,p_contact_extra_info_id            out nocopy number
  ,p_object_version_number            out nocopy number,
--  ,p_some_warning                     out boolean
  p_effective_start_date OUT NOCOPY DATE,
  p_effective_end_date	 OUT NOCOPY DATE
  ) is
  --
  -- Declare cursors and local variables
  --
  l_contact_extra_info_id	per_contact_extra_info_f.contact_extra_info_id%TYPE;
  l_object_version_number	per_contact_extra_info_f.object_version_number%TYPE;
  l_effective_start_date	per_contact_extra_info_f.effective_start_date%TYPE;
  l_effective_end_date		per_contact_extra_info_f.effective_end_date%TYPE;
  l_proc                varchar2(72) := g_package||'create_contact_extra_info';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_contact_extra_info;
  --
  -- Truncate the time portion from all IN date parameters
  --

  --
  -- Call Before Process User Hook
  --
  begin
    hr_contact_extra_info_bk1.create_contact_extra_info_b
      (p_effective_date                => p_effective_date,
--      ,p_business_group_id             => p_business_group_id
--      ,p_non_mandatory_arg             => p_non_mandatory_arg
      p_contact_relationship_id  => p_contact_relationship_id,
      p_information_type	 => p_information_type,
      p_cei_information_category => p_cei_information_category,
      p_cei_information1         => p_cei_information1,
      p_cei_information2         => p_cei_information2,
      p_cei_information3         => p_cei_information3,
      p_cei_information4         => p_cei_information4,
      p_cei_information5         => p_cei_information5,
      p_cei_information6         => p_cei_information6,
      p_cei_information7         => p_cei_information7,
      p_cei_information8         => p_cei_information8,
      p_cei_information9         => p_cei_information9,
      p_cei_information10        => p_cei_information10,
      p_cei_information11        => p_cei_information11,
      p_cei_information12        => p_cei_information12,
      p_cei_information13        => p_cei_information13,
      p_cei_information14        => p_cei_information14,
      p_cei_information15        => p_cei_information15,
      p_cei_information16        => p_cei_information16,
      p_cei_information17        => p_cei_information17,
      p_cei_information18        => p_cei_information18,
      p_cei_information19        => p_cei_information19,
      p_cei_information20        => p_cei_information20,
      p_cei_information21        => p_cei_information21,
      p_cei_information22        => p_cei_information22,
      p_cei_information23        => p_cei_information23,
      p_cei_information24        => p_cei_information24,
      p_cei_information25        => p_cei_information25,
      p_cei_information26        => p_cei_information26,
      p_cei_information27        => p_cei_information27,
      p_cei_information28        => p_cei_information28,
      p_cei_information29        => p_cei_information29,
      p_cei_information30        => p_cei_information30,
      p_cei_attribute_category   => p_cei_attribute_category,
      p_cei_attribute1           => p_cei_attribute1,
      p_cei_attribute2           => p_cei_attribute2,
      p_cei_attribute3           => p_cei_attribute3,
      p_cei_attribute4           => p_cei_attribute4,
      p_cei_attribute5           => p_cei_attribute5,
      p_cei_attribute6           => p_cei_attribute6,
      p_cei_attribute7           => p_cei_attribute7,
      p_cei_attribute8           => p_cei_attribute8,
      p_cei_attribute9           => p_cei_attribute9,
      p_cei_attribute10          => p_cei_attribute10,
      p_cei_attribute11          => p_cei_attribute11,
      p_cei_attribute12          => p_cei_attribute12,
      p_cei_attribute13          => p_cei_attribute13,
      p_cei_attribute14          => p_cei_attribute14,
      p_cei_attribute15          => p_cei_attribute15,
      p_cei_attribute16          => p_cei_attribute16,
      p_cei_attribute17          => p_cei_attribute17,
      p_cei_attribute18          => p_cei_attribute18,
      p_cei_attribute19          => p_cei_attribute19,
      p_cei_attribute20          => p_cei_attribute20
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_contact_extra_info'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --
   per_rei_ins.ins(
    p_effective_date	       => p_effective_date,
    p_contact_relationship_id  => p_contact_relationship_id,
    p_information_type         => p_information_type,
    p_cei_information_category => p_cei_information_category,
    p_cei_information1         => p_cei_information1,
    p_cei_information2         => p_cei_information2,
    p_cei_information3         => p_cei_information3,
    p_cei_information4         => p_cei_information4,
    p_cei_information5         => p_cei_information5,
    p_cei_information6         => p_cei_information6,
    p_cei_information7         => p_cei_information7,
    p_cei_information8         => p_cei_information8,
    p_cei_information9         => p_cei_information9,
    p_cei_information10        => p_cei_information10,
    p_cei_information11        => p_cei_information11,
    p_cei_information12        => p_cei_information12,
    p_cei_information13        => p_cei_information13,
    p_cei_information14        => p_cei_information14,
    p_cei_information15        => p_cei_information15,
    p_cei_information16        => p_cei_information16,
    p_cei_information17        => p_cei_information17,
    p_cei_information18        => p_cei_information18,
    p_cei_information19        => p_cei_information19,
    p_cei_information20        => p_cei_information20,
    p_cei_information21        => p_cei_information21,
    p_cei_information22        => p_cei_information22,
    p_cei_information23        => p_cei_information23,
    p_cei_information24        => p_cei_information24,
    p_cei_information25        => p_cei_information25,
    p_cei_information26        => p_cei_information26,
    p_cei_information27        => p_cei_information27,
    p_cei_information28        => p_cei_information28,
    p_cei_information29        => p_cei_information29,
    p_cei_information30        => p_cei_information30,
    p_cei_attribute_category   => p_cei_attribute_category,
    p_cei_attribute1           => p_cei_attribute1,
    p_cei_attribute2           => p_cei_attribute2,
    p_cei_attribute3           => p_cei_attribute3,
    p_cei_attribute4           => p_cei_attribute4,
    p_cei_attribute5           => p_cei_attribute5,
    p_cei_attribute6           => p_cei_attribute6,
    p_cei_attribute7           => p_cei_attribute7,
    p_cei_attribute8           => p_cei_attribute8,
    p_cei_attribute9           => p_cei_attribute9,
    p_cei_attribute10          => p_cei_attribute10,
    p_cei_attribute11          => p_cei_attribute11,
    p_cei_attribute12          => p_cei_attribute12,
    p_cei_attribute13          => p_cei_attribute13,
    p_cei_attribute14          => p_cei_attribute14,
    p_cei_attribute15          => p_cei_attribute15,
    p_cei_attribute16          => p_cei_attribute16,
    p_cei_attribute17          => p_cei_attribute17,
    p_cei_attribute18          => p_cei_attribute18,
    p_cei_attribute19          => p_cei_attribute19,
    p_cei_attribute20          => p_cei_attribute20,
    p_contact_extra_info_id    => l_contact_extra_info_id,
    p_object_version_number    => l_object_version_number,
    p_effective_start_date     => l_effective_start_date,
    p_effective_end_date       => l_effective_end_date);
  --
  -- Call After Process User Hook
  --
  begin
    hr_contact_extra_info_bk1.create_contact_extra_info_a
      (p_effective_date                => p_effective_date,
--      ,p_business_group_id             => p_business_group_id
--      ,p_non_mandatory_arg             => p_non_mandatory_arg
      p_contact_relationship_id  => p_contact_relationship_id,
      p_information_type         => p_information_type,
      p_cei_information_category => p_cei_information_category,
      p_cei_information1         => p_cei_information1,
      p_cei_information2         => p_cei_information2,
      p_cei_information3         => p_cei_information3,
      p_cei_information4         => p_cei_information4,
      p_cei_information5         => p_cei_information5,
      p_cei_information6         => p_cei_information6,
      p_cei_information7         => p_cei_information7,
      p_cei_information8         => p_cei_information8,
      p_cei_information9         => p_cei_information9,
      p_cei_information10        => p_cei_information10,
      p_cei_information11        => p_cei_information11,
      p_cei_information12        => p_cei_information12,
      p_cei_information13        => p_cei_information13,
      p_cei_information14        => p_cei_information14,
      p_cei_information15        => p_cei_information15,
      p_cei_information16        => p_cei_information16,
      p_cei_information17        => p_cei_information17,
      p_cei_information18        => p_cei_information18,
      p_cei_information19        => p_cei_information19,
      p_cei_information20        => p_cei_information20,
      p_cei_information21        => p_cei_information21,
      p_cei_information22        => p_cei_information22,
      p_cei_information23        => p_cei_information23,
      p_cei_information24        => p_cei_information24,
      p_cei_information25        => p_cei_information25,
      p_cei_information26        => p_cei_information26,
      p_cei_information27        => p_cei_information27,
      p_cei_information28        => p_cei_information28,
      p_cei_information29        => p_cei_information29,
      p_cei_information30        => p_cei_information30,
      p_cei_attribute_category   => p_cei_attribute_category,
      p_cei_attribute1           => p_cei_attribute1,
      p_cei_attribute2           => p_cei_attribute2,
      p_cei_attribute3           => p_cei_attribute3,
      p_cei_attribute4           => p_cei_attribute4,
      p_cei_attribute5           => p_cei_attribute5,
      p_cei_attribute6           => p_cei_attribute6,
      p_cei_attribute7           => p_cei_attribute7,
      p_cei_attribute8           => p_cei_attribute8,
      p_cei_attribute9           => p_cei_attribute9,
      p_cei_attribute10          => p_cei_attribute10,
      p_cei_attribute11          => p_cei_attribute11,
      p_cei_attribute12          => p_cei_attribute12,
      p_cei_attribute13          => p_cei_attribute13,
      p_cei_attribute14          => p_cei_attribute14,
      p_cei_attribute15          => p_cei_attribute15,
      p_cei_attribute16          => p_cei_attribute16,
      p_cei_attribute17          => p_cei_attribute17,
      p_cei_attribute18          => p_cei_attribute18,
      p_cei_attribute19          => p_cei_attribute19,
      p_cei_attribute20          => p_cei_attribute20
      ,p_contact_extra_info_id         => l_contact_extra_info_id
      ,p_object_version_number         => l_object_version_number
--      ,p_some_warning                  => <local_var_set_in_process_logic>
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_contact_extra_info'
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
  p_contact_extra_info_id  := l_contact_extra_info_id;
  p_object_version_number  := l_object_version_number;
--  p_some_warning           := <local_var_set_in_process_logic>;
   p_effective_start_date := l_effective_start_date;
   p_effective_end_date := l_effective_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_contact_extra_info;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_contact_extra_info_id  := null;
    p_object_version_number  := null;
--    p_some_warning           := <local_var_set_in_process_logic>;
     p_effective_start_date := NULL;
     p_effective_end_date := NULL;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_contact_extra_info_id  := null;
    p_object_version_number  := null;
    p_effective_start_date := NULL;
    p_effective_end_date := NULL;
    rollback to create_contact_extra_info;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_contact_extra_info;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_contact_extra_info >----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_contact_extra_info
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date,
--  ,p_business_group_id             in     number
--  ,p_non_mandatory_arg             in     number   default null
  p_datetrack_update_mode	IN	VARCHAR2,
  p_contact_extra_info_id       IN      NUMBER,
  p_contact_relationship_id	IN	NUMBER		DEFAULT hr_api.g_number,
  p_information_type		IN	VARCHAR2	DEFAULT hr_api.g_varchar2,
  p_object_version_number       IN OUT NOCOPY  NUMBER,
  p_cei_information_category    IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_information1            IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_information2            IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_information3            IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_information4            IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_information5            IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_information6            IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_information7            IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_information8            IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_information9            IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_information10           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_information11           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_information12           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_information13           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_information14           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_information15           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_information16           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_information17           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_information18           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_information19           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_information20           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_information21           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_information22           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_information23           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_information24           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_information25           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_information26           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_information27           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_information28           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_information29           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_information30           IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute_category      IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute1              IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute2              IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute3              IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute4              IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute5              IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute6              IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute7              IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute8              IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute9              IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute10             IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute11             IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute12             IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute13             IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute14             IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute15             IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute16             IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute17             IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute18             IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute19             IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
  p_cei_attribute20             IN      VARCHAR2        DEFAULT hr_api.g_varchar2,
--  ,p_id                               out number
--  ,p_object_version_number            out number
--  ,p_some_warning                     out boolean
  p_effective_start_date OUT NOCOPY DATE,
  p_effective_end_date	 OUT NOCOPY DATE
  ) is
  --
  --
  -- Declare cursors and local variables
  --
  l_effective_start_date	per_contact_extra_info_f.effective_start_date%TYPE;
  l_effective_end_date		per_contact_extra_info_f.effective_end_date%TYPE;
  l_proc                varchar2(72) := g_package||'update_contact_extra_info';
  l_temp_ovn            number := p_object_version_number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_contact_extra_info;
  --
  -- Truncate the time portion from all IN date parameters
  --

  --
  -- Call Before Process User Hook
  --
  begin
    hr_contact_extra_info_bk2.update_contact_extra_info_b
      (p_effective_date                => p_effective_date,
--      ,p_business_group_id             => p_business_group_id
--      ,p_non_mandatory_arg             => p_non_mandatory_arg
      p_datetrack_update_mode	 => p_datetrack_update_mode,
      p_contact_extra_info_id    => p_contact_extra_info_id,
      p_contact_relationship_id	 => p_contact_relationship_id,
      p_information_type	 => p_information_type,
      p_cei_information_category => p_cei_information_category,
      p_cei_information1         => p_cei_information1,
      p_cei_information2         => p_cei_information2,
      p_cei_information3         => p_cei_information3,
      p_cei_information4         => p_cei_information4,
      p_cei_information5         => p_cei_information5,
      p_cei_information6         => p_cei_information6,
      p_cei_information7         => p_cei_information7,
      p_cei_information8         => p_cei_information8,
      p_cei_information9         => p_cei_information9,
      p_cei_information10        => p_cei_information10,
      p_cei_information11        => p_cei_information11,
      p_cei_information12        => p_cei_information12,
      p_cei_information13        => p_cei_information13,
      p_cei_information14        => p_cei_information14,
      p_cei_information15        => p_cei_information15,
      p_cei_information16        => p_cei_information16,
      p_cei_information17        => p_cei_information17,
      p_cei_information18        => p_cei_information18,
      p_cei_information19        => p_cei_information19,
      p_cei_information20        => p_cei_information20,
      p_cei_information21        => p_cei_information21,
      p_cei_information22        => p_cei_information22,
      p_cei_information23        => p_cei_information23,
      p_cei_information24        => p_cei_information24,
      p_cei_information25        => p_cei_information25,
      p_cei_information26        => p_cei_information26,
      p_cei_information27        => p_cei_information27,
      p_cei_information28        => p_cei_information28,
      p_cei_information29        => p_cei_information29,
      p_cei_information30        => p_cei_information30,
      p_cei_attribute_category   => p_cei_attribute_category,
      p_cei_attribute1           => p_cei_attribute1,
      p_cei_attribute2           => p_cei_attribute2,
      p_cei_attribute3           => p_cei_attribute3,
      p_cei_attribute4           => p_cei_attribute4,
      p_cei_attribute5           => p_cei_attribute5,
      p_cei_attribute6           => p_cei_attribute6,
      p_cei_attribute7           => p_cei_attribute7,
      p_cei_attribute8           => p_cei_attribute8,
      p_cei_attribute9           => p_cei_attribute9,
      p_cei_attribute10          => p_cei_attribute10,
      p_cei_attribute11          => p_cei_attribute11,
      p_cei_attribute12          => p_cei_attribute12,
      p_cei_attribute13          => p_cei_attribute13,
      p_cei_attribute14          => p_cei_attribute14,
      p_cei_attribute15          => p_cei_attribute15,
      p_cei_attribute16          => p_cei_attribute16,
      p_cei_attribute17          => p_cei_attribute17,
      p_cei_attribute18          => p_cei_attribute18,
      p_cei_attribute19          => p_cei_attribute19,
      p_cei_attribute20          => p_cei_attribute20,
      p_object_version_number    => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_contact_extra_info'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --


  --
  -- Process Logic
  --
   per_rei_upd.upd(
    p_effective_date	       => p_effective_date,
    p_datetrack_mode           => p_datetrack_update_mode,
    p_contact_extra_info_id    => p_contact_extra_info_id,
    p_object_version_number    => p_object_version_number,
    p_contact_relationship_id  => p_contact_relationship_id,
    p_information_type         => p_information_type,
    p_cei_information_category => p_cei_information_category,
    p_cei_information1         => p_cei_information1,
    p_cei_information2         => p_cei_information2,
    p_cei_information3         => p_cei_information3,
    p_cei_information4         => p_cei_information4,
    p_cei_information5         => p_cei_information5,
    p_cei_information6         => p_cei_information6,
    p_cei_information7         => p_cei_information7,
    p_cei_information8         => p_cei_information8,
    p_cei_information9         => p_cei_information9,
    p_cei_information10        => p_cei_information10,
    p_cei_information11        => p_cei_information11,
    p_cei_information12        => p_cei_information12,
    p_cei_information13        => p_cei_information13,
    p_cei_information14        => p_cei_information14,
    p_cei_information15        => p_cei_information15,
    p_cei_information16        => p_cei_information16,
    p_cei_information17        => p_cei_information17,
    p_cei_information18        => p_cei_information18,
    p_cei_information19        => p_cei_information19,
    p_cei_information20        => p_cei_information20,
    p_cei_information21        => p_cei_information21,
    p_cei_information22        => p_cei_information22,
    p_cei_information23        => p_cei_information23,
    p_cei_information24        => p_cei_information24,
    p_cei_information25        => p_cei_information25,
    p_cei_information26        => p_cei_information26,
    p_cei_information27        => p_cei_information27,
    p_cei_information28        => p_cei_information28,
    p_cei_information29        => p_cei_information29,
    p_cei_information30        => p_cei_information30,
    p_cei_attribute_category   => p_cei_attribute_category,
    p_cei_attribute1           => p_cei_attribute1,
    p_cei_attribute2           => p_cei_attribute2,
    p_cei_attribute3           => p_cei_attribute3,
    p_cei_attribute4           => p_cei_attribute4,
    p_cei_attribute5           => p_cei_attribute5,
    p_cei_attribute6           => p_cei_attribute6,
    p_cei_attribute7           => p_cei_attribute7,
    p_cei_attribute8           => p_cei_attribute8,
    p_cei_attribute9           => p_cei_attribute9,
    p_cei_attribute10          => p_cei_attribute10,
    p_cei_attribute11          => p_cei_attribute11,
    p_cei_attribute12          => p_cei_attribute12,
    p_cei_attribute13          => p_cei_attribute13,
    p_cei_attribute14          => p_cei_attribute14,
    p_cei_attribute15          => p_cei_attribute15,
    p_cei_attribute16          => p_cei_attribute16,
    p_cei_attribute17          => p_cei_attribute17,
    p_cei_attribute18          => p_cei_attribute18,
    p_cei_attribute19          => p_cei_attribute19,
    p_cei_attribute20          => p_cei_attribute20,
    p_effective_start_date     => l_effective_start_date,
    p_effective_end_date       => l_effective_end_date);
  --
  -- Call After Process User Hook
  --
  begin
    hr_contact_extra_info_bk2.update_contact_extra_info_a
      (p_effective_date                => p_effective_date
--      ,p_business_group_id             => p_business_group_id
--      ,p_non_mandatory_arg             => p_non_mandatory_arg
      ,p_contact_extra_info_id         => p_contact_extra_info_id,
    p_contact_relationship_id	=> p_contact_relationship_id,
    p_information_type		=> p_information_type
      ,p_object_version_number         => p_object_version_number,
--      ,p_some_warning                  => <local_var_set_in_process_logic>
    p_datetrack_update_mode     => p_datetrack_update_mode,
    p_cei_information_category  => p_cei_information_category,
    p_cei_information1          => p_cei_information1,
    p_cei_information2          => p_cei_information2,
    p_cei_information3          => p_cei_information3,
    p_cei_information4          => p_cei_information4,
    p_cei_information5          => p_cei_information5,
    p_cei_information6          => p_cei_information6,
    p_cei_information7          => p_cei_information7,
    p_cei_information8          => p_cei_information8,
    p_cei_information9          => p_cei_information9,
    p_cei_information10         => p_cei_information10,
    p_cei_information11         => p_cei_information11,
    p_cei_information12         => p_cei_information12,
    p_cei_information13         => p_cei_information13,
    p_cei_information14         => p_cei_information14,
    p_cei_information15         => p_cei_information15,
    p_cei_information16         => p_cei_information16,
    p_cei_information17         => p_cei_information17,
    p_cei_information18         => p_cei_information18,
    p_cei_information19         => p_cei_information19,
    p_cei_information20         => p_cei_information20,
    p_cei_information21         => p_cei_information21,
    p_cei_information22         => p_cei_information22,
    p_cei_information23         => p_cei_information23,
    p_cei_information24         => p_cei_information24,
    p_cei_information25         => p_cei_information25,
    p_cei_information26         => p_cei_information26,
    p_cei_information27         => p_cei_information27,
    p_cei_information28         => p_cei_information28,
    p_cei_information29         => p_cei_information29,
    p_cei_information30         => p_cei_information30,
    p_cei_attribute_category    => p_cei_attribute_category,
    p_cei_attribute1            => p_cei_attribute1,
    p_cei_attribute2            => p_cei_attribute2,
    p_cei_attribute3            => p_cei_attribute3,
    p_cei_attribute4            => p_cei_attribute4,
    p_cei_attribute5            => p_cei_attribute5,
    p_cei_attribute6            => p_cei_attribute6,
    p_cei_attribute7            => p_cei_attribute7,
    p_cei_attribute8            => p_cei_attribute8,
    p_cei_attribute9            => p_cei_attribute9,
    p_cei_attribute10           => p_cei_attribute10,
    p_cei_attribute11           => p_cei_attribute11,
    p_cei_attribute12           => p_cei_attribute12,
    p_cei_attribute13           => p_cei_attribute13,
    p_cei_attribute14           => p_cei_attribute14,
    p_cei_attribute15           => p_cei_attribute15,
    p_cei_attribute16           => p_cei_attribute16,
    p_cei_attribute17           => p_cei_attribute17,
    p_cei_attribute18           => p_cei_attribute18,
    p_cei_attribute19           => p_cei_attribute19,
    p_cei_attribute20           => p_cei_attribute20
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_contact_extra_info'
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
--  p_id  	 	     := <local_var_set_in_process_logic>;
--  p_object_version_number  := <local_var_set_in_process_logic>;
--  p_some_warning           := <local_var_set_in_process_logic>;
   p_effective_start_date := l_effective_start_date;
   p_effective_end_date := l_effective_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_contact_extra_info;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
--    p_id                     := null;
    p_object_version_number  := null;
--    p_some_warning           := <local_var_set_in_process_logic>;
     p_effective_start_date := NULL;
     p_effective_end_date := NULL;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_object_version_number  := l_temp_ovn;
    p_effective_start_date := NULL;
    p_effective_end_date := NULL;
    rollback to update_contact_extra_info;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_contact_extra_info;
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_contact_extra_info >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_contact_extra_info
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date,
--  ,p_business_group_id             in     number
--  ,p_non_mandatory_arg             in     number   default null
  p_datetrack_delete_mode       IN      VARCHAR2,
  p_contact_extra_info_id       IN      NUMBER,
  p_object_version_number       IN OUT NOCOPY  NUMBER,
--  ,p_id                               out number
--  ,p_object_version_number            out number
--  ,p_some_warning                     out boolean
  p_effective_start_date        OUT NOCOPY     DATE,
  p_effective_end_date          OUT NOCOPY     DATE
  ) is
  --
  -- Declare cursors and local variables
  --
  l_effective_start_date	per_contact_extra_info_f.effective_start_date%TYPE;
  l_effective_end_date		per_contact_extra_info_f.effective_end_date%TYPE;
  l_proc                varchar2(72) := g_package||'delete_contact_extra_info';
  l_temp_ovn            number := p_object_version_number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_contact_extra_info;
  --
  -- Truncate the time portion from all IN date parameters
  --

  --
  -- Call Before Process User Hook
  --
  begin
    hr_contact_extra_info_bk3.delete_contact_extra_info_b
      (p_effective_date                => p_effective_date,
--      ,p_business_group_id             => p_business_group_id
--      ,p_non_mandatory_arg             => p_non_mandatory_arg
    p_contact_extra_info_id	=> p_contact_extra_info_id,
    p_object_version_number	=> p_object_version_number,
    p_datetrack_delete_mode	=> p_datetrack_delete_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_contact_extra_info'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --
    per_rei_del.del(
     p_effective_date	 	=> p_effective_date,
     p_datetrack_mode		=> p_datetrack_delete_mode,
     p_contact_extra_info_id	=> p_contact_extra_info_id,
     p_object_version_number	=> p_object_version_number,
     p_effective_start_date	=> l_effective_start_date,
     p_effective_end_date	=> l_effective_end_date);
  --
  -- Call After Process User Hook
  --
  begin
    hr_contact_extra_info_bk3.delete_contact_extra_info_a
      (p_effective_date                => p_effective_date
--      ,p_business_group_id             => p_business_group_id
--      ,p_non_mandatory_arg             => p_non_mandatory_arg
      ,p_contact_extra_info_id         => p_contact_extra_info_id
      ,p_object_version_number         => p_object_version_number,
--      ,p_some_warning                  => <local_var_set_in_process_logic>
     p_datetrack_delete_mode	=> p_datetrack_delete_mode
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_contact_extra_info_api'
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
--  p_id                     := <local_var_set_in_process_logic>;
--  p_object_version_number  := <local_var_set_in_process_logic>;
--  p_some_warning           := <local_var_set_in_process_logic>;
   p_effective_start_date := l_effective_start_date;
   p_effective_end_date := l_effective_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_contact_extra_info;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
--    p_id                     := null;
--    p_object_version_number  := null;
--    p_some_warning           := <local_var_set_in_process_logic>;
     p_effective_start_date := NULL;
     p_effective_end_date := NULL;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_effective_start_date := NULL;
    p_effective_end_date := NULL;
    p_object_version_number  := l_temp_ovn;
    rollback to delete_contact_extra_info;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_contact_extra_info;
--
end hr_contact_extra_info_api;

/
