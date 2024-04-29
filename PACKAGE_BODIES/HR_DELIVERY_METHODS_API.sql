--------------------------------------------------------
--  DDL for Package Body HR_DELIVERY_METHODS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DELIVERY_METHODS_API" as
/* $Header: pepdmapi.pkb 120.0.12010000.2 2009/03/12 11:19:22 dparthas ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_delivery_methods_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_delivery_method >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_delivery_method
  (p_validate                       in  boolean   default false
  ,p_effective_date                 in  date
  ,p_person_id                      in  number
  ,p_comm_dlvry_method              in  varchar2
  ,p_date_start                     in  date
  ,p_date_end                       in  date      default hr_api.g_eot
  ,p_preferred_flag                 in  varchar2  default 'N'
  ,p_request_id                     in  number    default null
  ,p_program_update_date            in  date      default null
  ,p_program_application_id         in  number    default null
  ,p_program_id                     in  number    default null
  ,p_attribute_category             in  varchar2  default null
  ,p_attribute1                     in  varchar2  default null
  ,p_attribute2                     in  varchar2  default null
  ,p_attribute3                     in  varchar2  default null
  ,p_attribute4                     in  varchar2  default null
  ,p_attribute5                     in  varchar2  default null
  ,p_attribute6                     in  varchar2  default null
  ,p_attribute7                     in  varchar2  default null
  ,p_attribute8                     in  varchar2  default null
  ,p_attribute9                     in  varchar2  default null
  ,p_attribute10                    in  varchar2  default null
  ,p_attribute11                    in  varchar2  default null
  ,p_attribute12                    in  varchar2  default null
  ,p_attribute13                    in  varchar2  default null
  ,p_attribute14                    in  varchar2  default null
  ,p_attribute15                    in  varchar2  default null
  ,p_attribute16                    in  varchar2  default null
  ,p_attribute17                    in  varchar2  default null
  ,p_attribute18                    in  varchar2  default null
  ,p_attribute19                    in  varchar2  default null
  ,p_attribute20                    in  varchar2  default null
  ,p_delivery_method_id             out nocopy number
  ,p_object_version_number          out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_delivery_method_id    per_person_dlvry_methods.delivery_method_id%TYPE;
  l_proc varchar2(72)     := g_package||'create_delivery_method';
  l_object_version_number per_person_dlvry_methods.object_version_number%TYPE;
  l_effective_date        date;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_delivery_method;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_effective_date := trunc(p_effective_date);
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_delivery_methods
    --
    hr_delivery_methods_bk1.create_delivery_method_b
      (
       p_effective_date                 =>  l_effective_date
      ,p_date_start                     =>  p_date_start
      ,p_date_end                       =>  p_date_end
      ,p_person_id                      =>  p_person_id
      ,p_comm_dlvry_method              =>  p_comm_dlvry_method
      ,p_preferred_flag                 =>  p_preferred_flag
      ,p_request_id                     =>  p_request_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_attribute_category             =>  p_attribute_category
      ,p_attribute1                     =>  p_attribute1
      ,p_attribute2                     =>  p_attribute2
      ,p_attribute3                     =>  p_attribute3
      ,p_attribute4                     =>  p_attribute4
      ,p_attribute5                     =>  p_attribute5
      ,p_attribute6                     =>  p_attribute6
      ,p_attribute7                     =>  p_attribute7
      ,p_attribute8                     =>  p_attribute8
      ,p_attribute9                     =>  p_attribute9
      ,p_attribute10                    =>  p_attribute10
      ,p_attribute11                    =>  p_attribute11
      ,p_attribute12                    =>  p_attribute12
      ,p_attribute13                    =>  p_attribute13
      ,p_attribute14                    =>  p_attribute14
      ,p_attribute15                    =>  p_attribute15
      ,p_attribute16                    =>  p_attribute16
      ,p_attribute17                    =>  p_attribute17
      ,p_attribute18                    =>  p_attribute18
      ,p_attribute19                    =>  p_attribute19
      ,p_attribute20                    =>  p_attribute20
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_DELIVERY_METHOD'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_delivery_method
    --
  end;
  --
  per_pdm_ins.ins
    (
     p_delivery_method_id            => l_delivery_method_id
    ,p_date_start                    => p_date_start
    ,p_date_end                      => p_date_end
    ,p_person_id                     => p_person_id
    ,p_comm_dlvry_method             => p_comm_dlvry_method
    ,p_preferred_flag                => p_preferred_flag
    ,p_object_version_number         => l_object_version_number
    ,p_request_id                    => p_request_id
    ,p_program_update_date           => p_program_update_date
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_attribute_category            => p_attribute_category
    ,p_attribute1                    => p_attribute1
    ,p_attribute2                    => p_attribute2
    ,p_attribute3                    => p_attribute3
    ,p_attribute4                    => p_attribute4
    ,p_attribute5                    => p_attribute5
    ,p_attribute6                    => p_attribute6
    ,p_attribute7                    => p_attribute7
    ,p_attribute8                    => p_attribute8
    ,p_attribute9                    => p_attribute9
    ,p_attribute10                   => p_attribute10
    ,p_attribute11                   => p_attribute11
    ,p_attribute12                   => p_attribute12
    ,p_attribute13                   => p_attribute13
    ,p_attribute14                   => p_attribute14
    ,p_attribute15                   => p_attribute15
    ,p_attribute16                   => p_attribute16
    ,p_attribute17                   => p_attribute17
    ,p_attribute18                   => p_attribute18
    ,p_attribute19                   => p_attribute19
    ,p_attribute20                   => p_attribute20
    ,p_effective_date                => l_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_delivery_methods
    --
    hr_delivery_methods_bk1.create_delivery_method_a
      (
       p_delivery_method_id             =>  l_delivery_method_id
      ,p_date_start                     =>  p_date_start
      ,p_date_end                       =>  p_date_end
      ,p_person_id                      =>  p_person_id
      ,p_comm_dlvry_method              =>  p_comm_dlvry_method
      ,p_preferred_flag                 =>  p_preferred_flag
      ,p_object_version_number          =>  l_object_version_number
      ,p_request_id                     =>  p_request_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_attribute_category             =>  p_attribute_category
      ,p_attribute1                     =>  p_attribute1
      ,p_attribute2                     =>  p_attribute2
      ,p_attribute3                     =>  p_attribute3
      ,p_attribute4                     =>  p_attribute4
      ,p_attribute5                     =>  p_attribute5
      ,p_attribute6                     =>  p_attribute6
      ,p_attribute7                     =>  p_attribute7
      ,p_attribute8                     =>  p_attribute8
      ,p_attribute9                     =>  p_attribute9
      ,p_attribute10                    =>  p_attribute10
      ,p_attribute11                    =>  p_attribute11
      ,p_attribute12                    =>  p_attribute12
      ,p_attribute13                    =>  p_attribute13
      ,p_attribute14                    =>  p_attribute14
      ,p_attribute15                    =>  p_attribute15
      ,p_attribute16                    =>  p_attribute16
      ,p_attribute17                    =>  p_attribute17
      ,p_attribute18                    =>  p_attribute18
      ,p_attribute19                    =>  p_attribute19
      ,p_attribute20                    =>  p_attribute20
      ,p_effective_date                 => l_effective_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_DELIVERY_METHOD'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_delivery_method
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_delivery_method_id    := l_delivery_method_id;
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_delivery_method;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_delivery_method_id     := null;
    p_object_version_number  := null;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    ROLLBACK TO create_delivery_method;
    --
    -- set in out parameters and set out parameters
    --
    p_delivery_method_id     := null;
    p_object_version_number  := null;
    --
    raise;
    --
end create_delivery_method;
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_delivery_method >----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_delivery_method
  (p_validate                       in     boolean   default false
  ,p_effective_date                 in     date
  ,p_delivery_method_id             in     number
  ,p_object_version_number          in out nocopy number
  ,p_date_start                     in     date      default hr_api.g_date
  ,p_date_end                       in     date      default hr_api.g_date
  ,p_comm_dlvry_method              in     varchar2  default hr_api.g_varchar2
  ,p_preferred_flag                 in     varchar2  default hr_api.g_varchar2
  ,p_request_id                     in     number    default hr_api.g_number
  ,p_program_update_date            in     date      default hr_api.g_date
  ,p_program_application_id         in     number    default hr_api.g_number
  ,p_program_id                     in     number    default hr_api.g_number
  ,p_attribute_category             in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                     in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute11                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                    in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                    in     varchar2  default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72)     := g_package||'update_delivery_method';
  l_object_version_number per_person_dlvry_methods.object_version_number%TYPE;
  l_ovn per_person_dlvry_methods.object_version_number%TYPE := p_object_version_number;
  l_effective_date        date;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_delivery_method;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  l_effective_date := trunc(p_effective_date);
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_delivery_method
    --
    hr_delivery_methods_bk2.update_delivery_method_b
      (
       p_delivery_method_id             =>  p_delivery_method_id
      ,p_effective_date                 =>  l_effective_date
      ,p_date_start                     =>  p_date_start
      ,p_date_end                       =>  p_date_end
      ,p_comm_dlvry_method              =>  p_comm_dlvry_method
      ,p_preferred_flag                 =>  p_preferred_flag
      ,p_object_version_number          =>  p_object_version_number
      ,p_request_id                     =>  p_request_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_attribute_category             =>  p_attribute_category
      ,p_attribute1                     =>  p_attribute1
      ,p_attribute2                     =>  p_attribute2
      ,p_attribute3                     =>  p_attribute3
      ,p_attribute4                     =>  p_attribute4
      ,p_attribute5                     =>  p_attribute5
      ,p_attribute6                     =>  p_attribute6
      ,p_attribute7                     =>  p_attribute7
      ,p_attribute8                     =>  p_attribute8
      ,p_attribute9                     =>  p_attribute9
      ,p_attribute10                    =>  p_attribute10
      ,p_attribute11                    =>  p_attribute11
      ,p_attribute12                    =>  p_attribute12
      ,p_attribute13                    =>  p_attribute13
      ,p_attribute14                    =>  p_attribute14
      ,p_attribute15                    =>  p_attribute15
      ,p_attribute16                    =>  p_attribute16
      ,p_attribute17                    =>  p_attribute17
      ,p_attribute18                    =>  p_attribute18
      ,p_attribute19                    =>  p_attribute19
      ,p_attribute20                    =>  p_attribute20
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_DELIVERY_METHOD'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_delivery_method
    --
  end;
  --
  per_pdm_upd.upd
    (
     p_delivery_method_id            => p_delivery_method_id
    ,p_date_start                    => p_date_start
    ,p_date_end                      => p_date_end
    ,p_comm_dlvry_method             => p_comm_dlvry_method
    ,p_preferred_flag                => p_preferred_flag
    ,p_object_version_number         => l_object_version_number
    ,p_request_id                    => p_request_id
    ,p_program_update_date           => p_program_update_date
    ,p_program_application_id        => p_program_application_id
    ,p_program_id                    => p_program_id
    ,p_attribute_category            => p_attribute_category
    ,p_attribute1                    => p_attribute1
    ,p_attribute2                    => p_attribute2
    ,p_attribute3                    => p_attribute3
    ,p_attribute4                    => p_attribute4
    ,p_attribute5                    => p_attribute5
    ,p_attribute6                    => p_attribute6
    ,p_attribute7                    => p_attribute7
    ,p_attribute8                    => p_attribute8
    ,p_attribute9                    => p_attribute9
    ,p_attribute10                   => p_attribute10
    ,p_attribute11                   => p_attribute11
    ,p_attribute12                   => p_attribute12
    ,p_attribute13                   => p_attribute13
    ,p_attribute14                   => p_attribute14
    ,p_attribute15                   => p_attribute15
    ,p_attribute16                   => p_attribute16
    ,p_attribute17                   => p_attribute17
    ,p_attribute18                   => p_attribute18
    ,p_attribute19                   => p_attribute19
    ,p_attribute20                   => p_attribute20
    ,p_effective_date                => l_effective_date
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_delivery_method
    --
    hr_delivery_methods_bk2.update_delivery_method_a
      (
       p_effective_date                 =>  l_effective_date
      ,p_delivery_method_id             =>  p_delivery_method_id
      ,p_date_start                     =>  p_date_start
      ,p_date_end                       =>  p_date_end
      ,p_comm_dlvry_method              =>  p_comm_dlvry_method
      ,p_preferred_flag                 =>  p_preferred_flag
      ,p_object_version_number          =>  l_object_version_number
      ,p_request_id                     =>  p_request_id
      ,p_program_update_date            =>  p_program_update_date
      ,p_program_application_id         =>  p_program_application_id
      ,p_program_id                     =>  p_program_id
      ,p_attribute_category             =>  p_attribute_category
      ,p_attribute1                     =>  p_attribute1
      ,p_attribute2                     =>  p_attribute2
      ,p_attribute3                     =>  p_attribute3
      ,p_attribute4                     =>  p_attribute4
      ,p_attribute5                     =>  p_attribute5
      ,p_attribute6                     =>  p_attribute6
      ,p_attribute7                     =>  p_attribute7
      ,p_attribute8                     =>  p_attribute8
      ,p_attribute9                     =>  p_attribute9
      ,p_attribute10                    =>  p_attribute10
      ,p_attribute11                    =>  p_attribute11
      ,p_attribute12                    =>  p_attribute12
      ,p_attribute13                    =>  p_attribute13
      ,p_attribute14                    =>  p_attribute14
      ,p_attribute15                    =>  p_attribute15
      ,p_attribute16                    =>  p_attribute16
      ,p_attribute17                    =>  p_attribute17
      ,p_attribute18                    =>  p_attribute18
      ,p_attribute19                    =>  p_attribute19
      ,p_attribute20                    =>  p_attribute20
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_DELIVERY_METHOD'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_delivery_method
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
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
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_delivery_method;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    ROLLBACK TO update_delivery_method;
    --
    -- set in out parameters and set out parameters
    --
    p_object_version_number := l_ovn;
    raise;
    --
end update_delivery_method;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_delivery_method >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_delivery_method
  (p_validate                       in  boolean  default false
  ,p_delivery_method_id             in  number
  ,p_object_version_number          in  number
  ) is

  -- dparthas
  CURSOR get_person_info IS
  select person_id
  from PER_PERSON_DLVRY_METHODS
  where DELIVERY_METHOD_ID = p_delivery_method_id ;
  --dparthas
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72)     := g_package||'delete_delivery_method';
  l_object_version_number per_person_dlvry_methods.object_version_number%TYPE;
  l_person_id number := -1;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);

   -- dparthas
   OPEN get_person_info;
   FETCH get_person_info INTO l_person_id;
   CLOSE get_person_info;
   -- dparthas
  --
  -- Issue a savepoint
  --
  savepoint delete_delivery_method;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of delete_delivery_method
    --
    hr_delivery_methods_bk3.delete_delivery_method_b
      (
       p_delivery_method_id             =>  p_delivery_method_id
      ,p_object_version_number          =>  p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_DELIVERY_METHOD'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_delivery_method
    --
  end;
  --
  per_pdm_del.del
    (
     p_delivery_method_id            => p_delivery_method_id
    ,p_object_version_number         => p_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_delivery_method
    --
    hr_delivery_methods_bk3.delete_delivery_method_a
      (
       p_delivery_method_id             =>  p_delivery_method_id
      ,p_object_version_number          =>  p_object_version_number
      ,p_person_id                      =>  l_person_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_DELIVERY_METHOD'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_delivery_method
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_delivery_method;
    --
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    ROLLBACK TO delete_delivery_method;
    raise;
    --
end delete_delivery_method;
--
end hr_delivery_methods_api;

/
