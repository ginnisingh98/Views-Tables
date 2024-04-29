--------------------------------------------------------
--  DDL for Package Body HR_DE_ORGANIZATION_LINKS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DE_ORGANIZATION_LINKS_API" as
/* $Header: hrordapi.pkb 115.4 2002/12/16 10:38:03 hjonnala noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_de_organization_links_api.';
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_link >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_link
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_parent_organization_id         in     number
  ,p_child_organization_id          in     number
  ,p_org_link_type                  in     varchar2
  ,p_org_link_information_categor   in     varchar2 default null
  ,p_org_link_information1          in     varchar2 default null
  ,p_org_link_information2          in     varchar2 default null
  ,p_org_link_information3          in     varchar2 default null
  ,p_org_link_information4          in     varchar2 default null
  ,p_org_link_information5          in     varchar2 default null
  ,p_org_link_information6          in     varchar2 default null
  ,p_org_link_information7          in     varchar2 default null
  ,p_org_link_information8          in     varchar2 default null
  ,p_org_link_information9          in     varchar2 default null
  ,p_org_link_information10         in     varchar2 default null
  ,p_org_link_information11         in     varchar2 default null
  ,p_org_link_information12         in     varchar2 default null
  ,p_org_link_information13         in     varchar2 default null
  ,p_org_link_information14         in     varchar2 default null
  ,p_org_link_information15         in     varchar2 default null
  ,p_org_link_information16         in     varchar2 default null
  ,p_org_link_information17         in     varchar2 default null
  ,p_org_link_information18         in     varchar2 default null
  ,p_org_link_information19         in     varchar2 default null
  ,p_org_link_information20         in     varchar2 default null
  ,p_org_link_information21         in     varchar2 default null
  ,p_org_link_information22         in     varchar2 default null
  ,p_org_link_information23         in     varchar2 default null
  ,p_org_link_information24         in     varchar2 default null
  ,p_org_link_information25         in     varchar2 default null
  ,p_org_link_information26         in     varchar2 default null
  ,p_org_link_information27         in     varchar2 default null
  ,p_org_link_information28         in     varchar2 default null
  ,p_org_link_information29         in     varchar2 default null
  ,p_org_link_information30         in     varchar2 default null
  ,p_attribute_category             in     varchar2 default null
  ,p_attribute1                     in     varchar2 default null
  ,p_attribute2                     in     varchar2 default null
  ,p_attribute3                     in     varchar2 default null
  ,p_attribute4                     in     varchar2 default null
  ,p_attribute5                     in     varchar2 default null
  ,p_attribute6                     in     varchar2 default null
  ,p_attribute7                     in     varchar2 default null
  ,p_attribute8                     in     varchar2 default null
  ,p_attribute9                     in     varchar2 default null
  ,p_attribute10                    in     varchar2 default null
  ,p_attribute11                    in     varchar2 default null
  ,p_attribute12                    in     varchar2 default null
  ,p_attribute13                    in     varchar2 default null
  ,p_attribute14                    in     varchar2 default null
  ,p_attribute15                    in     varchar2 default null
  ,p_attribute16                    in     varchar2 default null
  ,p_attribute17                    in     varchar2 default null
  ,p_attribute18                    in     varchar2 default null
  ,p_attribute19                    in     varchar2 default null
  ,p_attribute20                    in     varchar2 default null
  ,p_attribute21                    in     varchar2 default null
  ,p_attribute22                    in     varchar2 default null
  ,p_attribute23                    in     varchar2 default null
  ,p_attribute24                    in     varchar2 default null
  ,p_attribute25                    in     varchar2 default null
  ,p_attribute26                    in     varchar2 default null
  ,p_attribute27                    in     varchar2 default null
  ,p_attribute28                    in     varchar2 default null
  ,p_attribute29                    in     varchar2 default null
  ,p_attribute30                    in     varchar2 default null
  ,p_organization_link_id              out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
  --
  -- Declare cursors
  --
  cursor csr_get_derived_details(p_parent_organization_id number) is
    select org.business_group_id
    from   hr_organization_units org
    where  org.organization_id = p_parent_organization_id;
  --
  -- Declare local variables
  --
  l_proc                  varchar2(72) := g_package||'create_link';
  l_business_group_id     hr_de_organization_links.business_group_id%TYPE;
  l_organization_link_id  hr_de_organization_links.organization_link_id%TYPE;
  l_object_version_number hr_de_organization_links.object_version_number%TYPE;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_link;
  --
  -- Pre process logic
  --
  -- Derive the business group.
  --
  open  csr_get_derived_details(p_parent_organization_id);
  fetch csr_get_derived_details into l_business_group_id;
  if csr_get_derived_details%NOTFOUND then
    close csr_get_derived_details;
    hr_utility.set_message(801,'XXX');
    hr_utility.raise_error;
  end if;
  close csr_get_derived_details;
  --
  -- Call Before Process User Hook
  --
  begin
    hr_de_organization_links_bk1.create_link_b
      (p_effective_date               => trunc(p_effective_date)
      ,p_parent_organization_id       => p_parent_organization_id
      ,p_child_organization_id        => p_child_organization_id
      ,p_business_group_id            => l_business_group_id
      ,p_org_link_type                => p_org_link_type
      ,p_org_link_information_categor => p_org_link_information_categor
      ,p_org_link_information1        => p_org_link_information1
      ,p_org_link_information2        => p_org_link_information2
      ,p_org_link_information3        => p_org_link_information3
      ,p_org_link_information4        => p_org_link_information4
      ,p_org_link_information5        => p_org_link_information5
      ,p_org_link_information6        => p_org_link_information6
      ,p_org_link_information7        => p_org_link_information7
      ,p_org_link_information8        => p_org_link_information8
      ,p_org_link_information9        => p_org_link_information9
      ,p_org_link_information10       => p_org_link_information10
      ,p_org_link_information11       => p_org_link_information11
      ,p_org_link_information12       => p_org_link_information12
      ,p_org_link_information13       => p_org_link_information13
      ,p_org_link_information14       => p_org_link_information14
      ,p_org_link_information15       => p_org_link_information15
      ,p_org_link_information16       => p_org_link_information16
      ,p_org_link_information17       => p_org_link_information17
      ,p_org_link_information18       => p_org_link_information18
      ,p_org_link_information19       => p_org_link_information19
      ,p_org_link_information20       => p_org_link_information20
      ,p_org_link_information21       => p_org_link_information21
      ,p_org_link_information22       => p_org_link_information22
      ,p_org_link_information23       => p_org_link_information23
      ,p_org_link_information24       => p_org_link_information24
      ,p_org_link_information25       => p_org_link_information25
      ,p_org_link_information26       => p_org_link_information26
      ,p_org_link_information27       => p_org_link_information27
      ,p_org_link_information28       => p_org_link_information28
      ,p_org_link_information29       => p_org_link_information29
      ,p_org_link_information30       => p_org_link_information30
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
      ,p_attribute21                  => p_attribute21
      ,p_attribute22                  => p_attribute22
      ,p_attribute23                  => p_attribute23
      ,p_attribute24                  => p_attribute24
      ,p_attribute25                  => p_attribute25
      ,p_attribute26                  => p_attribute26
      ,p_attribute27                  => p_attribute27
      ,p_attribute28                  => p_attribute28
      ,p_attribute29                  => p_attribute29
      ,p_attribute30                  => p_attribute30);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_link'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  hr_ord_ins.ins
    (p_effective_date               => trunc(p_effective_date)
    ,p_parent_organization_id       => p_parent_organization_id
    ,p_child_organization_id        => p_child_organization_id
    ,p_business_group_id            => l_business_group_id
    ,p_org_link_type                => p_org_link_type
    ,p_org_link_information_categor => p_org_link_information_categor
    ,p_org_link_information1        => p_org_link_information1
    ,p_org_link_information2        => p_org_link_information2
    ,p_org_link_information3        => p_org_link_information3
    ,p_org_link_information4        => p_org_link_information4
    ,p_org_link_information5        => p_org_link_information5
    ,p_org_link_information6        => p_org_link_information6
    ,p_org_link_information7        => p_org_link_information7
    ,p_org_link_information8        => p_org_link_information8
    ,p_org_link_information9        => p_org_link_information9
    ,p_org_link_information10       => p_org_link_information10
    ,p_org_link_information11       => p_org_link_information11
    ,p_org_link_information12       => p_org_link_information12
    ,p_org_link_information13       => p_org_link_information13
    ,p_org_link_information14       => p_org_link_information14
    ,p_org_link_information15       => p_org_link_information15
    ,p_org_link_information16       => p_org_link_information16
    ,p_org_link_information17       => p_org_link_information17
    ,p_org_link_information18       => p_org_link_information18
    ,p_org_link_information19       => p_org_link_information19
    ,p_org_link_information20       => p_org_link_information20
    ,p_org_link_information21       => p_org_link_information21
    ,p_org_link_information22       => p_org_link_information22
    ,p_org_link_information23       => p_org_link_information23
    ,p_org_link_information24       => p_org_link_information24
    ,p_org_link_information25       => p_org_link_information25
    ,p_org_link_information26       => p_org_link_information26
    ,p_org_link_information27       => p_org_link_information27
    ,p_org_link_information28       => p_org_link_information28
    ,p_org_link_information29       => p_org_link_information29
    ,p_org_link_information30       => p_org_link_information30
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
    ,p_attribute21                  => p_attribute21
    ,p_attribute22                  => p_attribute22
    ,p_attribute23                  => p_attribute23
    ,p_attribute24                  => p_attribute24
    ,p_attribute25                  => p_attribute25
    ,p_attribute26                  => p_attribute26
    ,p_attribute27                  => p_attribute27
    ,p_attribute28                  => p_attribute28
    ,p_attribute29                  => p_attribute29
    ,p_attribute30                  => p_attribute30
    ,p_organization_link_id         => l_organization_link_id
    ,p_object_version_number        => l_object_version_number);
  --
  -- Call After Process User Hook
  --
  begin
    hr_de_organization_links_bk1.create_link_a
      (p_effective_date               => trunc(p_effective_date)
      ,p_parent_organization_id       => p_parent_organization_id
      ,p_child_organization_id        => p_child_organization_id
      ,p_business_group_id            => l_business_group_id
      ,p_org_link_type                => p_org_link_type
      ,p_org_link_information_categor => p_org_link_information_categor
      ,p_org_link_information1        => p_org_link_information1
      ,p_org_link_information2        => p_org_link_information2
      ,p_org_link_information3        => p_org_link_information3
      ,p_org_link_information4        => p_org_link_information4
      ,p_org_link_information5        => p_org_link_information5
      ,p_org_link_information6        => p_org_link_information6
      ,p_org_link_information7        => p_org_link_information7
      ,p_org_link_information8        => p_org_link_information8
      ,p_org_link_information9        => p_org_link_information9
      ,p_org_link_information10       => p_org_link_information10
      ,p_org_link_information11       => p_org_link_information11
      ,p_org_link_information12       => p_org_link_information12
      ,p_org_link_information13       => p_org_link_information13
      ,p_org_link_information14       => p_org_link_information14
      ,p_org_link_information15       => p_org_link_information15
      ,p_org_link_information16       => p_org_link_information16
      ,p_org_link_information17       => p_org_link_information17
      ,p_org_link_information18       => p_org_link_information18
      ,p_org_link_information19       => p_org_link_information19
      ,p_org_link_information20       => p_org_link_information20
      ,p_org_link_information21       => p_org_link_information21
      ,p_org_link_information22       => p_org_link_information22
      ,p_org_link_information23       => p_org_link_information23
      ,p_org_link_information24       => p_org_link_information24
      ,p_org_link_information25       => p_org_link_information25
      ,p_org_link_information26       => p_org_link_information26
      ,p_org_link_information27       => p_org_link_information27
      ,p_org_link_information28       => p_org_link_information28
      ,p_org_link_information29       => p_org_link_information29
      ,p_org_link_information30       => p_org_link_information30
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
      ,p_attribute21                  => p_attribute21
      ,p_attribute22                  => p_attribute22
      ,p_attribute23                  => p_attribute23
      ,p_attribute24                  => p_attribute24
      ,p_attribute25                  => p_attribute25
      ,p_attribute26                  => p_attribute26
      ,p_attribute27                  => p_attribute27
      ,p_attribute28                  => p_attribute28
      ,p_attribute29                  => p_attribute29
      ,p_attribute30                  => p_attribute30
      ,p_organization_link_id         => l_organization_link_id
      ,p_object_version_number        => l_object_version_number);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_link'
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
  p_organization_link_id  := l_organization_link_id;
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_link;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_organization_link_id  := null;
    p_object_version_number := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_link;
    -- Set OUT parameters.
    --
    p_organization_link_id  := null;
    p_object_version_number := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_link;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< update_link >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_link
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_organization_link_id           in     number
  ,p_org_link_information_categor   in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information1          in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information2          in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information3          in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information4          in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information5          in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information6          in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information7          in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information8          in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information9          in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information10         in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information11         in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information12         in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information13         in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information14         in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information15         in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information16         in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information17         in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information18         in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information19         in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information20         in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information21         in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information22         in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information23         in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information24         in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information25         in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information26         in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information27         in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information28         in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information29         in     varchar2 default hr_api.g_varchar2
  ,p_org_link_information30         in     varchar2 default hr_api.g_varchar2
  ,p_attribute_category             in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                     in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                     in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                     in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                     in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                     in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                     in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                     in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                     in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                     in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute21                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute22                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute23                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute24                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute25                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute26                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute27                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute28                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute29                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute30                    in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ) is
  --
  -- Declare local variables
  --
  l_proc                  varchar2(72) := g_package||'update_link';
  l_object_version_number hr_de_organization_links.object_version_number%TYPE := p_object_version_number;
  l_temp_ovn   number := p_object_version_number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_link;
  --
  -- Call Before Process User Hook
  --
  begin
    hr_de_organization_links_bk2.update_link_b
      (p_effective_date               => trunc(p_effective_date)
      ,p_organization_link_id         => p_organization_link_id
      ,p_org_link_information_categor => p_org_link_information_categor
      ,p_org_link_information1        => p_org_link_information1
      ,p_org_link_information2        => p_org_link_information2
      ,p_org_link_information3        => p_org_link_information3
      ,p_org_link_information4        => p_org_link_information4
      ,p_org_link_information5        => p_org_link_information5
      ,p_org_link_information6        => p_org_link_information6
      ,p_org_link_information7        => p_org_link_information7
      ,p_org_link_information8        => p_org_link_information8
      ,p_org_link_information9        => p_org_link_information9
      ,p_org_link_information10       => p_org_link_information10
      ,p_org_link_information11       => p_org_link_information11
      ,p_org_link_information12       => p_org_link_information12
      ,p_org_link_information13       => p_org_link_information13
      ,p_org_link_information14       => p_org_link_information14
      ,p_org_link_information15       => p_org_link_information15
      ,p_org_link_information16       => p_org_link_information16
      ,p_org_link_information17       => p_org_link_information17
      ,p_org_link_information18       => p_org_link_information18
      ,p_org_link_information19       => p_org_link_information19
      ,p_org_link_information20       => p_org_link_information20
      ,p_org_link_information21       => p_org_link_information21
      ,p_org_link_information22       => p_org_link_information22
      ,p_org_link_information23       => p_org_link_information23
      ,p_org_link_information24       => p_org_link_information24
      ,p_org_link_information25       => p_org_link_information25
      ,p_org_link_information26       => p_org_link_information26
      ,p_org_link_information27       => p_org_link_information27
      ,p_org_link_information28       => p_org_link_information28
      ,p_org_link_information29       => p_org_link_information29
      ,p_org_link_information30       => p_org_link_information30
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
      ,p_attribute21                  => p_attribute21
      ,p_attribute22                  => p_attribute22
      ,p_attribute23                  => p_attribute23
      ,p_attribute24                  => p_attribute24
      ,p_attribute25                  => p_attribute25
      ,p_attribute26                  => p_attribute26
      ,p_attribute27                  => p_attribute27
      ,p_attribute28                  => p_attribute28
      ,p_attribute29                  => p_attribute29
      ,p_attribute30                  => p_attribute30
      ,p_object_version_number        => l_object_version_number);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_link'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  hr_ord_upd.upd
    (p_effective_date               => trunc(p_effective_date)
    ,p_organization_link_id         => p_organization_link_id
    ,p_org_link_information_categor => p_org_link_information_categor
    ,p_org_link_information1        => p_org_link_information1
    ,p_org_link_information2        => p_org_link_information2
    ,p_org_link_information3        => p_org_link_information3
    ,p_org_link_information4        => p_org_link_information4
    ,p_org_link_information5        => p_org_link_information5
    ,p_org_link_information6        => p_org_link_information6
    ,p_org_link_information7        => p_org_link_information7
    ,p_org_link_information8        => p_org_link_information8
    ,p_org_link_information9        => p_org_link_information9
    ,p_org_link_information10       => p_org_link_information10
    ,p_org_link_information11       => p_org_link_information11
    ,p_org_link_information12       => p_org_link_information12
    ,p_org_link_information13       => p_org_link_information13
    ,p_org_link_information14       => p_org_link_information14
    ,p_org_link_information15       => p_org_link_information15
    ,p_org_link_information16       => p_org_link_information16
    ,p_org_link_information17       => p_org_link_information17
    ,p_org_link_information18       => p_org_link_information18
    ,p_org_link_information19       => p_org_link_information19
    ,p_org_link_information20       => p_org_link_information20
    ,p_org_link_information21       => p_org_link_information21
    ,p_org_link_information22       => p_org_link_information22
    ,p_org_link_information23       => p_org_link_information23
    ,p_org_link_information24       => p_org_link_information24
    ,p_org_link_information25       => p_org_link_information25
    ,p_org_link_information26       => p_org_link_information26
    ,p_org_link_information27       => p_org_link_information27
    ,p_org_link_information28       => p_org_link_information28
    ,p_org_link_information29       => p_org_link_information29
    ,p_org_link_information30       => p_org_link_information30
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
    ,p_attribute21                  => p_attribute21
    ,p_attribute22                  => p_attribute22
    ,p_attribute23                  => p_attribute23
    ,p_attribute24                  => p_attribute24
    ,p_attribute25                  => p_attribute25
    ,p_attribute26                  => p_attribute26
    ,p_attribute27                  => p_attribute27
    ,p_attribute28                  => p_attribute28
    ,p_attribute29                  => p_attribute29
    ,p_attribute30                  => p_attribute30
    ,p_object_version_number        => l_object_version_number);
  --
  -- Call After Process User Hook
  --
  begin
    hr_de_organization_links_bk2.update_link_a
      (p_effective_date               => trunc(p_effective_date)
      ,p_organization_link_id         => p_organization_link_id
      ,p_org_link_information_categor => p_org_link_information_categor
      ,p_org_link_information1        => p_org_link_information1
      ,p_org_link_information2        => p_org_link_information2
      ,p_org_link_information3        => p_org_link_information3
      ,p_org_link_information4        => p_org_link_information4
      ,p_org_link_information5        => p_org_link_information5
      ,p_org_link_information6        => p_org_link_information6
      ,p_org_link_information7        => p_org_link_information7
      ,p_org_link_information8        => p_org_link_information8
      ,p_org_link_information9        => p_org_link_information9
      ,p_org_link_information10       => p_org_link_information10
      ,p_org_link_information11       => p_org_link_information11
      ,p_org_link_information12       => p_org_link_information12
      ,p_org_link_information13       => p_org_link_information13
      ,p_org_link_information14       => p_org_link_information14
      ,p_org_link_information15       => p_org_link_information15
      ,p_org_link_information16       => p_org_link_information16
      ,p_org_link_information17       => p_org_link_information17
      ,p_org_link_information18       => p_org_link_information18
      ,p_org_link_information19       => p_org_link_information19
      ,p_org_link_information20       => p_org_link_information20
      ,p_org_link_information21       => p_org_link_information21
      ,p_org_link_information22       => p_org_link_information22
      ,p_org_link_information23       => p_org_link_information23
      ,p_org_link_information24       => p_org_link_information24
      ,p_org_link_information25       => p_org_link_information25
      ,p_org_link_information26       => p_org_link_information26
      ,p_org_link_information27       => p_org_link_information27
      ,p_org_link_information28       => p_org_link_information28
      ,p_org_link_information29       => p_org_link_information29
      ,p_org_link_information30       => p_org_link_information30
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
      ,p_attribute21                  => p_attribute21
      ,p_attribute22                  => p_attribute22
      ,p_attribute23                  => p_attribute23
      ,p_attribute24                  => p_attribute24
      ,p_attribute25                  => p_attribute25
      ,p_attribute26                  => p_attribute26
      ,p_attribute27                  => p_attribute27
      ,p_attribute28                  => p_attribute28
      ,p_attribute29                  => p_attribute29
      ,p_attribute30                  => p_attribute30
      ,p_object_version_number        => l_object_version_number);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_link'
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
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_link;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number := l_temp_ovn;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_link;
    -- Reset IN OUT parameters.
    p_object_version_number := l_temp_ovn;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_link;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< delete_link >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_link
  (p_validate                       in     boolean  default false
  ,p_organization_link_id           in     number
  ,p_object_version_number          in     number
  ) is
  --
  -- Declare local variables
  --
  l_proc                  varchar2(72) := g_package||'delete_link';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_link;
  --
  -- Call Before Process User Hook
  --
  begin
    hr_de_organization_links_bk3.delete_link_b
      (p_organization_link_id  => p_organization_link_id
      ,p_object_version_number => p_object_version_number);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_link'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  hr_ord_del.del
    (p_organization_link_id  => p_organization_link_id
    ,p_object_version_number => p_object_version_number);
  --
  begin
    hr_de_organization_links_bk3.delete_link_a
      (p_organization_link_id  => p_organization_link_id
      ,p_object_version_number => p_object_version_number);
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_link'
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
    rollback to delete_link;
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
    rollback to delete_link;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_link;
--
-- ----------------------------------------------------------------------------
-- |--------------------------------< lck >-----------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (p_organization_link_id           in     number
  ,p_object_version_number          in     number
  ) is
  --
  -- Declare local variables
  --
  l_proc                  varchar2(72) := g_package||'lck';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Lock the record.
  --
  hr_ord_shd.lck
    (p_organization_link_id  => p_organization_link_id
    ,p_object_version_number => p_object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
end lck;
--
end hr_de_organization_links_api;

/
