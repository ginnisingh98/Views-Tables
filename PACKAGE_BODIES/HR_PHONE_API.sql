--------------------------------------------------------
--  DDL for Package Body HR_PHONE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PHONE_API" as
/* $Header: pephnapi.pkb 120.0.12010000.2 2009/03/12 10:25:20 dparthas ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'hr_phone_api.';
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< create_phone >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_phone
  (p_date_from                   in     date,
  p_date_to                      in     date             default null,
  p_phone_type                   in     varchar2,
  p_phone_number                 in     varchar2,
  p_parent_id                    in     number           default null, -- HR/TCA merge
  p_parent_table                 in     varchar2         default null, --
  p_attribute_category           in     varchar2         default null,
  p_attribute1                   in     varchar2         default null,
  p_attribute2                   in     varchar2         default null,
  p_attribute3                   in     varchar2         default null,
  p_attribute4                   in     varchar2         default null,
  p_attribute5                   in     varchar2         default null,
  p_attribute6                   in     varchar2         default null,
  p_attribute7                   in     varchar2         default null,
  p_attribute8                   in     varchar2         default null,
  p_attribute9                   in     varchar2         default null,
  p_attribute10                  in     varchar2         default null,
  p_attribute11                  in     varchar2         default null,
  p_attribute12                  in     varchar2         default null,
  p_attribute13                  in     varchar2         default null,
  p_attribute14                  in     varchar2         default null,
  p_attribute15                  in     varchar2         default null,
  p_attribute16                  in     varchar2         default null,
  p_attribute17                  in     varchar2         default null,
  p_attribute18                  in     varchar2         default null,
  p_attribute19                  in     varchar2         default null,
  p_attribute20                  in     varchar2         default null,
  p_attribute21                  in     varchar2         default null,
  p_attribute22                  in     varchar2         default null,
  p_attribute23                  in     varchar2         default null,
  p_attribute24                  in     varchar2         default null,
  p_attribute25                  in     varchar2         default null,
  p_attribute26                  in     varchar2         default null,
  p_attribute27                  in     varchar2         default null,
  p_attribute28                  in     varchar2         default null,
  p_attribute29                  in     varchar2         default null,
  p_attribute30                  in     varchar2         default null,
  p_validate                     in     boolean          default false,
  p_effective_date               in     date,
  p_party_id                     in     number           default null, -- HR/TCA merge
  p_validity                     in     varchar2         default null,
  p_object_version_number           out nocopy number,
  p_phone_id                        out nocopy number)
is
  --
  l_proc      varchar2(72) := g_package||'create_phone';
  l_object_version_number  number;
  l_phone_id               number;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint.
  --
  savepoint create_phone;
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- Process Logic
  --
  --
  -- Start of API User Hook for the before hook of create_phone.
  --
  -- Start of Bug Fix for 2396117
   begin
     hr_phone_bk1.create_phone_b
  (p_date_from                   =>     p_date_from,
   p_date_to                      =>     p_date_to              ,
   p_phone_type                   =>     p_phone_type,
   p_phone_number                 =>     p_phone_number  ,
   p_parent_id                    =>     p_parent_id ,
   p_parent_table                 =>     p_parent_table ,
   p_attribute_category           =>     p_attribute_category ,
   p_attribute1                   =>     p_attribute1          ,
   p_attribute2                   =>     p_attribute2          ,
   p_attribute3                   =>     p_attribute3          ,
   p_attribute4                   =>     p_attribute4          ,
   p_attribute5                   =>     p_attribute5         ,
   p_attribute6                   =>     p_attribute6          ,
   p_attribute7                   =>     p_attribute7          ,
   p_attribute8                   =>     p_attribute8          ,
   p_attribute9                   =>     p_attribute9          ,
   p_attribute10                  =>     p_attribute10          ,
   p_attribute11                  =>     p_attribute11          ,
   p_attribute12                  =>     p_attribute12          ,
   p_attribute13                  =>     p_attribute13          ,
   p_attribute14                  =>     p_attribute14          ,
   p_attribute15                  =>     p_attribute15          ,
   p_attribute16                  =>     p_attribute16          ,
   p_attribute17                  =>     p_attribute17          ,
   p_attribute18                  =>     p_attribute18          ,
   p_attribute19                  =>     p_attribute19          ,
   p_attribute20                  =>     p_attribute20          ,
   p_attribute21                  =>     p_attribute21          ,
   p_attribute22                  =>     p_attribute22          ,
   p_attribute23                  =>     p_attribute23          ,
   p_attribute24                  =>     p_attribute24          ,
   p_attribute25                  =>     p_attribute25          ,
   p_attribute26                  =>     p_attribute26          ,
   p_attribute27                  =>     p_attribute27          ,
   p_attribute28                  =>     p_attribute28          ,
   p_attribute29                  =>     p_attribute29          ,
   p_attribute30                  =>     p_attribute30          ,
   p_effective_date               =>     p_effective_date	,
   p_party_id                     => p_party_id			, -- HR/TCA merge
   p_validity                     => p_validity);
   exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
          (p_module_name       => 'CREATE_PHONE',
          p_hook_type         => 'BP'
          );
   end;
-- End of Fix for Bug 2396117
  --
  per_phn_ins.ins
  (p_phone_id                     => l_phone_id
  ,p_date_from                    => trunc(p_date_from)
  ,p_date_to                      => trunc(p_date_to)
  ,p_phone_type                   => p_phone_type
  ,p_phone_number                 => p_phone_number
  ,p_parent_id                    => p_parent_id
  ,p_parent_table                 => p_parent_table
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
  ,p_object_version_number        => l_object_version_number
  ,p_validate                     => p_validate
  ,p_effective_date               => p_effective_date
  ,p_party_id                     => p_party_id -- HR/TCA merge
  ,p_validity                     => p_validity
  );
  --
  hr_utility.set_location(l_proc, 8);
  --
  -- Start of API User Hook for the after hook of create_phone
  --
  -- Start of Fix for Bug 2396117
  --
   begin
      hr_phone_bk1.create_phone_a
   (p_date_from                   =>     p_date_from,
   p_date_to                      =>     p_date_to              ,
   p_phone_type                   =>     p_phone_type,
   p_phone_number                 =>     p_phone_number  ,
   p_parent_id                    =>     p_parent_id ,
   p_parent_table                 =>     p_parent_table ,
   p_attribute_category           =>     p_attribute_category ,
   p_attribute1                   =>     p_attribute1          ,
   p_attribute2                   =>     p_attribute2          ,
   p_attribute3                   =>     p_attribute3          ,
   p_attribute4                   =>     p_attribute4          ,
   p_attribute5                   =>     p_attribute5         ,
   p_attribute6                   =>     p_attribute6          ,
   p_attribute7                   =>     p_attribute7          ,
   p_attribute8                   =>     p_attribute8          ,
   p_attribute9                   =>     p_attribute9          ,
   p_attribute10                  =>     p_attribute10          ,
   p_attribute11                  =>     p_attribute11          ,
   p_attribute12                  =>     p_attribute12          ,
   p_attribute13                  =>     p_attribute13          ,
   p_attribute14                  =>     p_attribute14          ,
   p_attribute15                  =>     p_attribute15          ,
   p_attribute16                  =>     p_attribute16          ,
   p_attribute17                  =>     p_attribute17          ,
   p_attribute18                  =>     p_attribute18          ,
   p_attribute19                  =>     p_attribute19          ,
   p_attribute20                  =>     p_attribute20          ,
   p_attribute21                  =>     p_attribute21          ,
   p_attribute22                  =>     p_attribute22          ,
   p_attribute23                  =>     p_attribute23          ,
   p_attribute24                  =>     p_attribute24          ,
   p_attribute25                  =>     p_attribute25          ,
   p_attribute26                  =>     p_attribute26          ,
   p_attribute27                  =>     p_attribute27          ,
   p_attribute28                  =>     p_attribute28          ,
   p_attribute29                  =>     p_attribute29          ,
   p_attribute30                  =>     p_attribute30          ,
   p_effective_date               =>     p_effective_date,
   p_object_version_number        =>     l_object_version_number,
   p_phone_id                     =>     l_phone_id		,
   p_party_id                     => 	 p_party_id		, -- HR/TCA merge
   p_validity                     =>	 p_validity);

   exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
          (p_module_name       => 'CREATE_PHONE',
           p_hook_type         => 'AP'
          );
   end;
-- End of Fix for Bug 2396117
  --
  -- End of API User Hook for the after hook of create_phone.
  --
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  p_object_version_number := l_object_version_number;
  p_phone_id              := l_phone_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_phone;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_phone_id := null;
    p_object_version_number  := null;
    --
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632479
    --
    p_phone_id := null;
    p_object_version_number  := null;

    ROLLBACK TO create_phone;
    raise;
    --
    -- End of fix.
    --
end create_phone;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< update_phone >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_phone
  (p_phone_id                     in number,
  p_date_from                    in date             default hr_api.g_date,
  p_date_to                      in date             default hr_api.g_date,
  p_phone_type                   in varchar2         default hr_api.g_varchar2,
  p_phone_number                 in varchar2         default hr_api.g_varchar2,
  p_attribute_category           in varchar2         default hr_api.g_varchar2,
  p_attribute1                   in varchar2         default hr_api.g_varchar2,
  p_attribute2                   in varchar2         default hr_api.g_varchar2,
  p_attribute3                   in varchar2         default hr_api.g_varchar2,
  p_attribute4                   in varchar2         default hr_api.g_varchar2,
  p_attribute5                   in varchar2         default hr_api.g_varchar2,
  p_attribute6                   in varchar2         default hr_api.g_varchar2,
  p_attribute7                   in varchar2         default hr_api.g_varchar2,
  p_attribute8                   in varchar2         default hr_api.g_varchar2,
  p_attribute9                   in varchar2         default hr_api.g_varchar2,
  p_attribute10                  in varchar2         default hr_api.g_varchar2,
  p_attribute11                  in varchar2         default hr_api.g_varchar2,
  p_attribute12                  in varchar2         default hr_api.g_varchar2,
  p_attribute13                  in varchar2         default hr_api.g_varchar2,
  p_attribute14                  in varchar2         default hr_api.g_varchar2,
  p_attribute15                  in varchar2         default hr_api.g_varchar2,
  p_attribute16                  in varchar2         default hr_api.g_varchar2,
  p_attribute17                  in varchar2         default hr_api.g_varchar2,
  p_attribute18                  in varchar2         default hr_api.g_varchar2,
  p_attribute19                  in varchar2         default hr_api.g_varchar2,
  p_attribute20                  in varchar2         default hr_api.g_varchar2,
  p_attribute21                  in varchar2         default hr_api.g_varchar2,
  p_attribute22                  in varchar2         default hr_api.g_varchar2,
  p_attribute23                  in varchar2         default hr_api.g_varchar2,
  p_attribute24                  in varchar2         default hr_api.g_varchar2,
  p_attribute25                  in varchar2         default hr_api.g_varchar2,
  p_attribute26                  in varchar2         default hr_api.g_varchar2,
  p_attribute27                  in varchar2         default hr_api.g_varchar2,
  p_attribute28                  in varchar2         default hr_api.g_varchar2,
  p_attribute29                  in varchar2         default hr_api.g_varchar2,
  p_attribute30                  in varchar2         default hr_api.g_varchar2,
  p_object_version_number        in out nocopy number,
  p_validate                     in boolean          default false,
  p_effective_date               in date,
  p_party_id                     in number           default hr_api.g_number,
  p_validity                     in varchar2         default hr_api.g_varchar2
 )

is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number per_phones.object_version_number%TYPE;
  l_object_version_number_temp per_phones.object_version_number%TYPE;
  l_proc                  varchar2(72) := g_package||'update_phone';
  l_temp_ovn              number       := p_object_version_number;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint.
  --
  savepoint update_phone;
  hr_utility.set_location(l_proc, 6);
  --
  l_object_version_number_temp := p_object_version_number;
  l_object_version_number      := p_object_version_number;
  --
  -- Start of API User Hook for the before hook of update_phone.
  --
  -- Start of Fix for Bug 2396117
   begin
      hr_phone_bk2.update_phone_b
   (p_phone_id                    =>     p_phone_id,
   p_date_from                    =>     p_date_from,
   p_date_to                      =>     p_date_to              ,
   p_phone_type                   =>     p_phone_type,
   p_phone_number                 =>     p_phone_number  ,
   p_attribute_category           =>     p_attribute_category ,
   p_attribute1                   =>     p_attribute1          ,
   p_attribute2                   =>     p_attribute2          ,
   p_attribute3                   =>     p_attribute3          ,
   p_attribute4                   =>     p_attribute4          ,
   p_attribute5                   =>     p_attribute5         ,
   p_attribute6                   =>     p_attribute6          ,
   p_attribute7                   =>     p_attribute7          ,
   p_attribute8                   =>     p_attribute8          ,
   p_attribute9                   =>     p_attribute9          ,
   p_attribute10                  =>     p_attribute10          ,
   p_attribute11                  =>     p_attribute11          ,
   p_attribute12                  =>     p_attribute12          ,
   p_attribute13                  =>     p_attribute13          ,
   p_attribute14                  =>     p_attribute14          ,
   p_attribute15                  =>     p_attribute15          ,
   p_attribute16                  =>     p_attribute16          ,
   p_attribute17                  =>     p_attribute17          ,
   p_attribute18                  =>     p_attribute18          ,
   p_attribute19                  =>     p_attribute19          ,
   p_attribute20                  =>     p_attribute20          ,
   p_attribute21                  =>     p_attribute21          ,
   p_attribute22                  =>     p_attribute22          ,
   p_attribute23                  =>     p_attribute23          ,
   p_attribute24                  =>     p_attribute24          ,
   p_attribute25                  =>     p_attribute25          ,
   p_attribute26                  =>     p_attribute26          ,
   p_attribute27                  =>     p_attribute27          ,
   p_attribute28                  =>     p_attribute28          ,
   p_attribute29                  =>     p_attribute29          ,
   p_attribute30                  =>     p_attribute30          ,
   p_object_version_number        =>     p_object_version_number,
   p_effective_date               =>     p_effective_date	,
   p_validity                     =>  	 p_validity);
   exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
          (p_module_name       => 'UPDATE_PHONE',
           p_hook_type         => 'BP'
         );
   end;
  --
-- End of Fix for Bug 2396117
  --
  -- Update Phone details.
  --
  per_phn_upd.upd
  (p_phone_id                     => p_phone_id
  ,p_date_from                    => trunc(p_date_from)
  ,p_date_to                      => trunc(p_date_to)
  ,p_phone_type                   => p_phone_type
  ,p_phone_number                 => p_phone_number
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
  ,p_object_version_number        => l_object_version_number
  ,p_validate                     => p_validate
  ,p_effective_date               => p_effective_date
  ,p_party_id                     => p_party_id
  ,p_validity                     => p_validity
  );
  --
  hr_utility.set_location(l_proc, 8);
  --
  -- Start of API User Hook for the after hook of update_phone
  -- Start of Fix for Bug 2396117
  --
   begin
      hr_phone_bk2.update_phone_a
   (p_phone_id                    =>     p_phone_id,
   p_date_from                    =>     p_date_from,
   p_date_to                      =>     p_date_to              ,
   p_phone_type                   =>     p_phone_type,
   p_phone_number                 =>     p_phone_number  ,
   p_attribute_category           =>     p_attribute_category ,
   p_attribute1                   =>     p_attribute1          ,
   p_attribute2                   =>     p_attribute2          ,
   p_attribute3                   =>     p_attribute3          ,
   p_attribute4                   =>     p_attribute4          ,
   p_attribute5                   =>     p_attribute5         ,
   p_attribute6                   =>     p_attribute6          ,
   p_attribute7                   =>     p_attribute7          ,
   p_attribute8                   =>     p_attribute8          ,
   p_attribute9                   =>     p_attribute9          ,
   p_attribute10                  =>     p_attribute10          ,
   p_attribute11                  =>     p_attribute11          ,
   p_attribute12                  =>     p_attribute12          ,
   p_attribute13                  =>     p_attribute13          ,
   p_attribute14                  =>     p_attribute14          ,
   p_attribute15                  =>     p_attribute15          ,
   p_attribute16                  =>     p_attribute16          ,
   p_attribute17                  =>     p_attribute17          ,
   p_attribute18                  =>     p_attribute18          ,
   p_attribute19                  =>     p_attribute19          ,
   p_attribute20                  =>     p_attribute20          ,
   p_attribute21                  =>     p_attribute21          ,
   p_attribute22                  =>     p_attribute22          ,
   p_attribute23                  =>     p_attribute23          ,
   p_attribute24                  =>     p_attribute24          ,
   p_attribute25                  =>     p_attribute25          ,
   p_attribute26                  =>     p_attribute26          ,
   p_attribute27                  =>     p_attribute27          ,
   p_attribute28                  =>     p_attribute28          ,
   p_attribute29                  =>     p_attribute29          ,
   p_attribute30                  =>     p_attribute30          ,
   p_object_version_number        =>     l_object_version_number,
   p_effective_date               =>     p_effective_date 	,
   p_validity                     =>  	 p_validity);

   exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
          (p_module_name       => 'UPDATE_PHONE',
          p_hook_type         => 'AP'
          );
   end;
  --
-- End of Fix for Bug 2396117
  -- End of API User Hook for the after hook of update_phone.
  --
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  p_object_version_number := l_object_version_number;
  hr_utility.set_location(' Leaving:'||l_proc, 11);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_phone;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number := l_object_version_number_temp;
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632479
    --
    p_object_version_number := l_temp_ovn;
    ROLLBACK TO update_phone;
    raise;
    --
    -- End of fix.
    --
end update_phone;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< delete_phone >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_phone
  (p_validate                       in     boolean  default false
  ,p_phone_id                       in     number
  ,p_object_version_number          in     number
  ) is
  --
  -- dparthas

  CURSOR get_person_info IS
  select pa.person_id
  from per_phones pp, per_all_people_f pa
  where pa.party_id = pp.party_id
  and phone_id = p_phone_id;

  l_person_id number := -1;

  -- dparthas

  l_proc                varchar2(72) := g_package||'delete_phone';

  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);

   --dparthas
   OPEN get_person_info;
   FETCH get_person_info INTO l_person_id;
   CLOSE get_person_info;
   --dparthas
  --
  -- Issue a savepoint.
  --
  savepoint delete_phone;
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- Process Logic
  --
  --
  -- Start of API User Hook for the before hook of delete_phone.
  -- Start of Fix for Bug 2396117
  --
   begin
      hr_phone_bk3.delete_phone_b
   (p_phone_id                       =>     p_phone_id
   ,p_object_version_number          =>     p_object_version_number
   );
   exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
          (p_module_name       => 'DELETE_PHONE',
           p_hook_type         => 'BP'
          );
   end;
  --
-- End of Fix for Bug 2396117

  per_phn_del.del
    (p_phone_id  => p_phone_id
    ,p_object_version_number => p_object_version_number
    ,p_validate => false);
  --
  hr_utility.set_location(l_proc, 8);
  --
  -- Start of API User Hook for the after hook of delete_phone
  -- Start of Fix for Bug 2396117
  --
   begin
      hr_phone_bk3.delete_phone_a
   (p_phone_id                       =>     p_phone_id
   ,p_object_version_number          =>     p_object_version_number
   ,p_person_id                      =>     l_person_id
   );
   exception
      when hr_api.cannot_find_prog_unit then
        hr_api.cannot_find_prog_unit_error
          (p_module_name       => 'DELETE_PHONE',
           p_hook_type         => 'AP'
          );
   end;
-- End of Fix for Bug 2396117
  --
  -- End of API User Hook for the after hook of delete_phone.
  --
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_phone;
    --
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632479
    --
    ROLLBACK TO delete_phone;
    raise;
    --
    -- End of fix.
    --
end delete_phone;
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_or_update_phone >------------------------|
-- ----------------------------------------------------------------------------
procedure create_or_update_phone
 (p_update_mode                  in     varchar2     default hr_api.g_correction,
  p_phone_id                     in out nocopy number,
  p_object_version_number        in out nocopy number,
  p_date_from                    in date             default hr_api.g_date,
  p_date_to                      in date             default hr_api.g_date,
  p_phone_type                   in varchar2         default hr_api.g_varchar2,
  p_phone_number                 in varchar2         default hr_api.g_varchar2,
  p_parent_id                    in number           default hr_api.g_number,
  p_parent_table                 in varchar2         default hr_api.g_varchar2,
  p_attribute_category           in varchar2         default hr_api.g_varchar2,
  p_attribute1                   in varchar2         default hr_api.g_varchar2,
  p_attribute2                   in varchar2         default hr_api.g_varchar2,
  p_attribute3                   in varchar2         default hr_api.g_varchar2,
  p_attribute4                   in varchar2         default hr_api.g_varchar2,
  p_attribute5                   in varchar2         default hr_api.g_varchar2,
  p_attribute6                   in varchar2         default hr_api.g_varchar2,
  p_attribute7                   in varchar2         default hr_api.g_varchar2,
  p_attribute8                   in varchar2         default hr_api.g_varchar2,
  p_attribute9                   in varchar2         default hr_api.g_varchar2,
  p_attribute10                  in varchar2         default hr_api.g_varchar2,
  p_attribute11                  in varchar2         default hr_api.g_varchar2,
  p_attribute12                  in varchar2         default hr_api.g_varchar2,
  p_attribute13                  in varchar2         default hr_api.g_varchar2,
  p_attribute14                  in varchar2         default hr_api.g_varchar2,
  p_attribute15                  in varchar2         default hr_api.g_varchar2,
  p_attribute16                  in varchar2         default hr_api.g_varchar2,
  p_attribute17                  in varchar2         default hr_api.g_varchar2,
  p_attribute18                  in varchar2         default hr_api.g_varchar2,
  p_attribute19                  in varchar2         default hr_api.g_varchar2,
  p_attribute20                  in varchar2         default hr_api.g_varchar2,
  p_attribute21                  in varchar2         default hr_api.g_varchar2,
  p_attribute22                  in varchar2         default hr_api.g_varchar2,
  p_attribute23                  in varchar2         default hr_api.g_varchar2,
  p_attribute24                  in varchar2         default hr_api.g_varchar2,
  p_attribute25                  in varchar2         default hr_api.g_varchar2,
  p_attribute26                  in varchar2         default hr_api.g_varchar2,
  p_attribute27                  in varchar2         default hr_api.g_varchar2,
  p_attribute28                  in varchar2         default hr_api.g_varchar2,
  p_attribute29                  in varchar2         default hr_api.g_varchar2,
  p_attribute30                  in varchar2         default hr_api.g_varchar2,
  p_validate                     in boolean          default false,
  p_effective_date               in date,
  p_party_id                     in number           default hr_api.g_number,
  p_validity                     in varchar2         default hr_api.g_varchar2
 ) is
  --
  l_proc                varchar2(72) := g_package||'create_or_update_phone';
  l_api_updating boolean;
  l_phn_rec per_phn_shd.g_rec_type;
  l_null_phn_rec per_phn_shd.g_rec_type;
  l_update_mode varchar2(30);
  l_effective_date date;
  --
  begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  savepoint create_or_update_phone;
  --
  l_update_mode:=p_update_mode;
  l_effective_date:=trunc(p_effective_date);
  l_api_updating := per_phn_shd.api_updating
       (p_phone_id               => p_phone_id
       ,p_object_version_number  => p_object_version_number);
  hr_utility.set_location(l_proc, 20);
  --
  -- set the record
  --
  l_phn_rec:=
   per_phn_shd.convert_args
   (p_phone_id,
    trunc(p_date_from),
    trunc(p_date_to),
    p_phone_type,
    p_phone_number,
    p_parent_id,
    p_parent_table,
    p_attribute_category,
    p_attribute1,
    p_attribute2,
    p_attribute3,
    p_attribute4,
    p_attribute5,
    p_attribute6,
    p_attribute7,
    p_attribute8,
    p_attribute9,
    p_attribute10,
    p_attribute11,
    p_attribute12,
    p_attribute13,
    p_attribute14,
    p_attribute15,
    p_attribute16,
    p_attribute17,
    p_attribute18,
    p_attribute19,
    p_attribute20,
    p_attribute21,
    p_attribute22,
    p_attribute23,
    p_attribute24,
    p_attribute25,
    p_attribute26,
    p_attribute27,
    p_attribute28,
    p_attribute29,
    p_attribute30,
    p_party_id,               -- HR/TCA merge
    p_validity,
    p_object_version_number
  );
  if not l_api_updating then
    --
    -- set g_old_rec to null
    --
    per_phn_shd.g_old_rec:=l_null_phn_rec;
    hr_utility.set_location(l_proc, 30);
    --
    -- convert the null values
    --
    hr_utility.set_location(l_proc, 40);
    per_phn_upd.convert_defs(l_phn_rec);
    --
    -- insert the data
    --
    hr_utility.set_location(l_proc||l_phn_rec.parent_id, 50);
    hr_phone_api.create_phone
    (p_date_from             => l_phn_rec.date_from
    ,p_date_to               => l_phn_rec.date_to
    ,p_phone_type            => l_phn_rec.phone_type
    ,p_phone_number          => l_phn_rec.phone_number
    ,p_parent_id             => l_phn_rec.parent_id
    ,p_parent_table          => l_phn_rec.parent_table
    ,p_attribute_category    => l_phn_rec.attribute_category
    ,p_attribute1            => l_phn_rec.attribute1
    ,p_attribute2            => l_phn_rec.attribute2
    ,p_attribute3            => l_phn_rec.attribute3
    ,p_attribute4            => l_phn_rec.attribute4
    ,p_attribute5            => l_phn_rec.attribute5
    ,p_attribute6            => l_phn_rec.attribute6
    ,p_attribute7            => l_phn_rec.attribute7
    ,p_attribute8            => l_phn_rec.attribute8
    ,p_attribute9            => l_phn_rec.attribute9
    ,p_attribute10           => l_phn_rec.attribute10
    ,p_attribute11           => l_phn_rec.attribute11
    ,p_attribute12           => l_phn_rec.attribute12
    ,p_attribute13           => l_phn_rec.attribute13
    ,p_attribute14           => l_phn_rec.attribute14
    ,p_attribute15           => l_phn_rec.attribute15
    ,p_attribute16           => l_phn_rec.attribute16
    ,p_attribute17           => l_phn_rec.attribute17
    ,p_attribute18           => l_phn_rec.attribute18
    ,p_attribute19           => l_phn_rec.attribute19
    ,p_attribute20           => l_phn_rec.attribute20
    ,p_attribute21           => l_phn_rec.attribute21
    ,p_attribute22           => l_phn_rec.attribute22
    ,p_attribute23           => l_phn_rec.attribute23
    ,p_attribute24           => l_phn_rec.attribute24
    ,p_attribute25           => l_phn_rec.attribute25
    ,p_attribute26           => l_phn_rec.attribute26
    ,p_attribute27           => l_phn_rec.attribute27
    ,p_attribute28           => l_phn_rec.attribute28
    ,p_attribute29           => l_phn_rec.attribute29
    ,p_attribute30           => l_phn_rec.attribute30
    ,p_validate              => FALSE
    ,p_effective_date        => l_effective_date
    ,p_object_version_number => l_phn_rec.object_version_number
    ,p_phone_id              => l_phn_rec.phone_id
    ,p_party_id              => l_phn_rec.party_id -- HR/TCA merge
    ,p_validity              => l_phn_rec.validity
    );
    hr_utility.set_location(l_proc, 60);
  else
    hr_utility.set_location(l_proc, 70);
    --
    -- updating not inserting
    --
    -- Validating update_mode values
    if (l_update_mode not in (hr_api.g_update,hr_api.g_correction)) then
      hr_utility.set_location(l_proc, 80);
      hr_utility.set_message(800, 'HR_52858_PHN_CHK_MODE');
      hr_utility.raise_error;
    end if;
    hr_utility.set_location(l_proc, 90);
    --
    -- Validating effective_date
    --
    if ((p_date_to <> hr_api.g_date) AND ( l_effective_date > p_date_to ))
    or ((p_date_from <> hr_api.g_date) AND ( l_effective_date < p_date_from ))
    then
      hr_utility.set_location(l_proc, 100);
      hr_utility.set_message(800, 'HR_52859_PHN_INVALID_EFF_DATE');
      hr_utility.raise_error;
    end if;
    hr_utility.set_location(l_proc, 110);
    --
    per_phn_shd.lck
      (p_phone_id                  => p_phone_id
      ,p_object_version_number     => p_object_version_number);
    --
    -- convert the null values
    --
    hr_utility.set_location(l_proc, 130);
    per_phn_upd.convert_defs(l_phn_rec);
    --
    -- check to see if the start date hasn't changed and is equal to the
    -- effective date. This will always be a correction.
    --
    if per_phn_shd.g_old_rec.date_from = l_phn_rec.date_from
       and  l_phn_rec.date_from = l_effective_date then
      l_update_mode:= hr_api.g_correction;
    end if;
    --
    -- check for the modes mode
    --
    if l_update_mode = hr_api.g_correction then
      --
      -- correct the data
      --
      hr_utility.set_location(l_proc, 140);
      --
      hr_phone_api.update_phone
      (p_date_from             => l_phn_rec.date_from
      ,p_date_to               => l_phn_rec.date_to
      ,p_phone_type            => l_phn_rec.phone_type
      ,p_phone_number          => l_phn_rec.phone_number
      ,p_attribute_category    => l_phn_rec.attribute_category
      ,p_attribute1            => l_phn_rec.attribute1
      ,p_attribute2            => l_phn_rec.attribute2
      ,p_attribute3            => l_phn_rec.attribute3
      ,p_attribute4            => l_phn_rec.attribute4
      ,p_attribute5            => l_phn_rec.attribute5
      ,p_attribute6            => l_phn_rec.attribute6
      ,p_attribute7            => l_phn_rec.attribute7
      ,p_attribute8            => l_phn_rec.attribute8
      ,p_attribute9            => l_phn_rec.attribute9
      ,p_attribute10           => l_phn_rec.attribute10
      ,p_attribute11           => l_phn_rec.attribute11
      ,p_attribute12           => l_phn_rec.attribute12
      ,p_attribute13           => l_phn_rec.attribute13
      ,p_attribute14           => l_phn_rec.attribute14
      ,p_attribute15           => l_phn_rec.attribute15
      ,p_attribute16           => l_phn_rec.attribute16
      ,p_attribute17           => l_phn_rec.attribute17
      ,p_attribute18           => l_phn_rec.attribute18
      ,p_attribute19           => l_phn_rec.attribute19
      ,p_attribute20           => l_phn_rec.attribute20
      ,p_attribute21           => l_phn_rec.attribute21
      ,p_attribute22           => l_phn_rec.attribute22
      ,p_attribute23           => l_phn_rec.attribute23
      ,p_attribute24           => l_phn_rec.attribute24
      ,p_attribute25           => l_phn_rec.attribute25
      ,p_attribute26           => l_phn_rec.attribute26
      ,p_attribute27           => l_phn_rec.attribute27
      ,p_attribute28           => l_phn_rec.attribute28
      ,p_attribute29           => l_phn_rec.attribute29
      ,p_attribute30           => l_phn_rec.attribute30
      ,p_validate              => FALSE
      ,p_effective_date        => l_effective_date
      ,p_object_version_number => l_phn_rec.object_version_number
      ,p_phone_id              => l_phn_rec.phone_id
      ,p_validity              => l_phn_rec.validity
      );
      --
      hr_utility.set_location(l_proc, 150);
      --
    else
      --
      -- update mode
      --
      hr_utility.set_location(l_proc, 160);
      --
      -- if the start date has changed and it is not the effective date then
      -- we have an error. A change of start date is the new start date for
      -- the new record, so must be the effective date so that the phone numbers
      -- are continuous.
      --
      if per_phn_shd.g_old_rec.date_from <> l_phn_rec.date_from
         and l_phn_rec.date_from <> l_effective_date then
        hr_utility.set_location(l_proc, 170);
        hr_utility.set_message(800, 'HR_52859_PHN_INVALID_EFF_DATE');
        hr_utility.raise_error;
      end if;
      --
      hr_utility.set_location(l_proc, 180);
      --
      -- end the old phone number
      --
      hr_phone_api.update_phone
      (p_phone_id              => l_phn_rec.phone_id
      ,p_date_to               => l_effective_date-1
      ,p_object_version_number => l_phn_rec.object_version_number
      ,p_validate              => FALSE
      ,p_effective_date        => l_effective_date);
      --
      hr_utility.set_location(l_proc, 190);
      --
      -- insert the new phone number
      --
      hr_phone_api.create_phone
      (p_date_from             => l_effective_date
      ,p_date_to               => l_phn_rec.date_to
      ,p_phone_type            => l_phn_rec.phone_type
      ,p_phone_number          => l_phn_rec.phone_number
      ,p_parent_id             => l_phn_rec.parent_id
      ,p_parent_table          => l_phn_rec.parent_table
      ,p_attribute_category    => l_phn_rec.attribute_category
      ,p_attribute1            => l_phn_rec.attribute1
      ,p_attribute2            => l_phn_rec.attribute2
      ,p_attribute3            => l_phn_rec.attribute3
      ,p_attribute4            => l_phn_rec.attribute4
      ,p_attribute5            => l_phn_rec.attribute5
      ,p_attribute6            => l_phn_rec.attribute6
      ,p_attribute7            => l_phn_rec.attribute7
      ,p_attribute8            => l_phn_rec.attribute8
      ,p_attribute9            => l_phn_rec.attribute9
      ,p_attribute10           => l_phn_rec.attribute10
      ,p_attribute11           => l_phn_rec.attribute11
      ,p_attribute12           => l_phn_rec.attribute12
      ,p_attribute13           => l_phn_rec.attribute13
      ,p_attribute14           => l_phn_rec.attribute14
      ,p_attribute15           => l_phn_rec.attribute15
      ,p_attribute16           => l_phn_rec.attribute16
      ,p_attribute17           => l_phn_rec.attribute17
      ,p_attribute18           => l_phn_rec.attribute18
      ,p_attribute19           => l_phn_rec.attribute19
      ,p_attribute20           => l_phn_rec.attribute20
      ,p_attribute21           => l_phn_rec.attribute21
      ,p_attribute22           => l_phn_rec.attribute22
      ,p_attribute23           => l_phn_rec.attribute23
      ,p_attribute24           => l_phn_rec.attribute24
      ,p_attribute25           => l_phn_rec.attribute25
      ,p_attribute26           => l_phn_rec.attribute26
      ,p_attribute27           => l_phn_rec.attribute27
      ,p_attribute28           => l_phn_rec.attribute28
      ,p_attribute29           => l_phn_rec.attribute29
      ,p_attribute30           => l_phn_rec.attribute30
      ,p_validate              => FALSE
      ,p_effective_date        => l_effective_date
      ,p_object_version_number => l_phn_rec.object_version_number
      ,p_phone_id              => l_phn_rec.phone_id
      ,p_party_id              => l_phn_rec.party_id -- HR/TCA merge
      ,p_validity              => l_phn_rec.validity
      );
      --
      hr_utility.set_location(l_proc, 190);
      --
    end if;
  end if;
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  p_phone_id:=l_phn_rec.phone_id;
  p_object_version_number:=l_phn_rec.object_version_number;
  hr_utility.set_location('Leaving:'||l_proc, 200);
  --
exception
  when hr_api.validate_enabled then
    rollback to create_or_update_phone;
    p_phone_id:=null;
    p_object_version_number:=null;
    hr_utility.set_location('Leaving:'||l_proc, 220);
    --
  when others then
    rollback to create_or_update_phone;
    hr_utility.set_location('Leaving:'||l_proc, 230);
    raise;
  --
end create_or_update_phone;
--
end hr_phone_api;

/
