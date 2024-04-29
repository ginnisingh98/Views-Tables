--------------------------------------------------------
--  DDL for Package Body PQH_TXN_JOB_REQUIREMENTS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_TXN_JOB_REQUIREMENTS_API" as
/* $Header: pqtjrapi.pkb 115.2 2002/12/06 23:49:05 rpasapul noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  PQH_TXN_JOB_REQUIREMENTS_API.';
--
-- ----------------------------------------------------------------------------
-- |------------------< CREATE_TXN_JOB_REQUIREMENT >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_TXN_JOB_REQUIREMENT
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_txn_job_requirement_id         out nocopy   number
  ,p_object_version_number          out nocopy    number
  ,p_business_group_id              in     number
  ,p_analysis_criteria_id           in     number
  ,p_position_transaction_id        in     number   default null
  ,p_job_requirement_id             in     number   default null
  ,p_date_from                      in     date     default null
  ,p_date_to                        in     date     default null
  ,p_essential                      in     varchar2 default null
  ,p_job_id                         in     number   default null
  ,p_request_id                     in     number   default null
  ,p_program_application_id         in     number   default null
  ,p_program_id                     in     number   default null
  ,p_program_update_date            in     date     default null
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
  ,p_comments                       in     varchar2 default null
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'CREATE_TXN_JOB_REQUIREMENT';
  l_txn_job_requirement_id  PQH_TXN_JOB_REQUIREMENTS.TXN_JOB_REQUIREMENT_ID%TYPE;
  l_object_version_number   PQH_TXN_JOB_REQUIREMENTS.object_version_number%TYPE;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_TXN_JOB_REQUIREMENT;
  --
  -- Truncate the time portion from all IN date parameters
  --

  --
  -- Call Before Process User Hook
  --
  begin
    PQH_TXN_JOB_REQUIREMENTS_BK1.CREATE_TXN_JOB_REQUIREMENT_b
      (p_effective_date                 => p_effective_date
      ,p_business_group_id              => p_business_group_id
      ,p_analysis_criteria_id           => p_analysis_criteria_id
      ,p_position_transaction_id        => p_position_transaction_id
      ,p_job_requirement_id             => p_job_requirement_id
      ,p_date_from                      => p_date_from
      ,p_date_to                        => p_date_to
      ,p_essential                      => p_essential
      ,p_job_id                         => p_job_id
      ,p_request_id                     => p_request_id
      ,p_program_application_id         => p_program_application_id
      ,p_program_id                     => p_program_id
      ,p_program_update_date            => p_program_update_date
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
      ,p_comments                       => p_comments
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_TXN_JOB_REQUIREMENT'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --
  pqh_tjr_ins.ins
  (p_business_group_id              => p_business_group_id
      ,p_analysis_criteria_id           => p_analysis_criteria_id
      ,p_position_transaction_id        => p_position_transaction_id
      ,p_job_requirement_id             => p_job_requirement_id
      ,p_date_from                      => p_date_from
      ,p_date_to                        => p_date_to
      ,p_essential                      => p_essential
      ,p_job_id                         => p_job_id
      ,p_request_id                     => p_request_id
      ,p_program_application_id         => p_program_application_id
      ,p_program_id                     => p_program_id
      ,p_program_update_date            => p_program_update_date
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
      ,p_comments                       => p_comments
      ,p_txn_job_requirement_id         => l_txn_job_requirement_id
      ,p_object_version_number          => l_object_version_number
  );


  --
  -- Call After Process User Hook
  --
  begin
    PQH_TXN_JOB_REQUIREMENTS_BK1.CREATE_TXN_JOB_REQUIREMENT_a
      (p_effective_date                 => p_effective_date
      ,p_txn_job_requirement_id         => l_txn_job_requirement_id
      ,p_object_version_number          => l_object_version_number
      ,p_business_group_id              => p_business_group_id
      ,p_analysis_criteria_id           => p_analysis_criteria_id
      ,p_position_transaction_id        => p_position_transaction_id
      ,p_job_requirement_id             => p_job_requirement_id
      ,p_date_from                      => p_date_from
      ,p_date_to                        => p_date_to
      ,p_essential                      => p_essential
      ,p_job_id                         => p_job_id
      ,p_request_id                     => p_request_id
      ,p_program_application_id         => p_program_application_id
      ,p_program_id                     => p_program_id
      ,p_program_update_date            => p_program_update_date
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
      ,p_comments                       => p_comments
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_TXN_JOB_REQUIREMENT'
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
  p_txn_job_requirement_id := l_txn_job_requirement_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_TXN_JOB_REQUIREMENT;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_txn_job_requirement_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
      p_txn_job_requirement_id := null;
    p_object_version_number  := null;
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_TXN_JOB_REQUIREMENT;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end CREATE_TXN_JOB_REQUIREMENT;
--
-- ----------------------------------------------------------------------------
-- |------------------< UPDATE_TXN_JOB_REQUIREMENT >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_TXN_JOB_REQUIREMENT
  (p_validate                     in     boolean  default false
  ,p_effective_date               in     date
  ,p_txn_job_requirement_id       in     number
  ,p_object_version_number        in out nocopy number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_analysis_criteria_id         in     number    default hr_api.g_number
  ,p_position_transaction_id      in     number    default hr_api.g_number
  ,p_job_requirement_id           in     number    default hr_api.g_number
  ,p_date_from                    in     date      default hr_api.g_date
  ,p_date_to                      in     date      default hr_api.g_date
  ,p_essential                    in     varchar2  default hr_api.g_varchar2
  ,p_job_id                       in     number    default hr_api.g_number
  ,p_request_id                   in     number    default hr_api.g_number
  ,p_program_application_id       in     number    default hr_api.g_number
  ,p_program_id                   in     number    default hr_api.g_number
  ,p_program_update_date          in     date      default hr_api.g_date
  ,p_attribute_category           in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute11                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2  default hr_api.g_varchar2
  ,p_comments                     in     varchar2  default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'UPDATE_TXN_JOB_REQUIREMENT';
  l_object_version_number   PQH_TXN_JOB_REQUIREMENTS.object_version_number%TYPE;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_TXN_JOB_REQUIREMENT;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_object_version_number := p_object_version_number;
  --
  -- Call Before Process User Hook
  --
  begin
    PQH_TXN_JOB_REQUIREMENTS_BK2.UPDATE_TXN_JOB_REQUIREMENT_b
      (p_effective_date                 => p_effective_date
      ,p_business_group_id              => p_business_group_id
      ,p_analysis_criteria_id           => p_analysis_criteria_id
      ,p_position_transaction_id        => p_position_transaction_id
      ,p_job_requirement_id             => p_job_requirement_id
      ,p_date_from                      => p_date_from
      ,p_date_to                        => p_date_to
      ,p_essential                      => p_essential
      ,p_job_id                         => p_job_id
      ,p_request_id                     => p_request_id
      ,p_program_application_id         => p_program_application_id
      ,p_program_id                     => p_program_id
      ,p_program_update_date            => p_program_update_date
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
      ,p_comments                       => p_comments
      ,p_txn_job_requirement_id         => p_txn_job_requirement_id
      ,p_object_version_number          => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_TXN_JOB_REQUIREMENT'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --
  pqh_tjr_upd.upd
  (    p_business_group_id              => p_business_group_id
      ,p_analysis_criteria_id           => p_analysis_criteria_id
      ,p_position_transaction_id        => p_position_transaction_id
      ,p_job_requirement_id             => p_job_requirement_id
      ,p_date_from                      => p_date_from
      ,p_date_to                        => p_date_to
      ,p_essential                      => p_essential
      ,p_job_id                         => p_job_id
      ,p_request_id                     => p_request_id
      ,p_program_application_id         => p_program_application_id
      ,p_program_id                     => p_program_id
      ,p_program_update_date            => p_program_update_date
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
      ,p_comments                       => p_comments
      ,p_txn_job_requirement_id         => p_txn_job_requirement_id
      ,p_object_version_number          => l_object_version_number
  );


  --
  -- Call After Process User Hook
  --
  begin
    PQH_TXN_JOB_REQUIREMENTS_BK2.UPDATE_TXN_JOB_REQUIREMENT_a
      (p_effective_date                 => p_effective_date
      ,p_txn_job_requirement_id         => p_txn_job_requirement_id
      ,p_object_version_number          => l_object_version_number
      ,p_business_group_id              => p_business_group_id
      ,p_analysis_criteria_id           => p_analysis_criteria_id
      ,p_position_transaction_id        => p_position_transaction_id
      ,p_job_requirement_id             => p_job_requirement_id
      ,p_date_from                      => p_date_from
      ,p_date_to                        => p_date_to
      ,p_essential                      => p_essential
      ,p_job_id                         => p_job_id
      ,p_request_id                     => p_request_id
      ,p_program_application_id         => p_program_application_id
      ,p_program_id                     => p_program_id
      ,p_program_update_date            => p_program_update_date
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
      ,p_comments                       => p_comments
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_TXN_JOB_REQUIREMENT'
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
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to UPDATE_TXN_JOB_REQUIREMENT;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    p_object_version_number  := l_object_version_number;
    --
    -- A validation or unexpected error has occured
    --
    rollback to UPDATE_TXN_JOB_REQUIREMENT;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end UPDATE_TXN_JOB_REQUIREMENT;
--
-- ----------------------------------------------------------------------------
-- |------------------< DELETE_TXN_JOB_REQUIREMENT >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_TXN_JOB_REQUIREMENT
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_txn_job_requirement_id         in     number
  ,p_object_version_number          in     number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'DELETE_TXN_JOB_REQUIREMENT';
  l_object_version_number   PQH_TXN_JOB_REQUIREMENTS.object_version_number%TYPE;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_TXN_JOB_REQUIREMENT;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_object_version_number := p_object_version_number;
  --
  -- Call Before Process User Hook
  --
  begin
    PQH_TXN_JOB_REQUIREMENTS_BK3.DELETE_TXN_JOB_REQUIREMENT_b
      (p_effective_date                 => p_effective_date
      ,p_txn_job_requirement_id         => p_txn_job_requirement_id
      ,p_object_version_number          => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_TXN_JOB_REQUIREMENT'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --
  pqh_tjr_del.del
  (    p_txn_job_requirement_id         => p_txn_job_requirement_id
      ,p_object_version_number          => l_object_version_number
  );


  --
  -- Call After Process User Hook
  --
  begin
    PQH_TXN_JOB_REQUIREMENTS_BK3.DELETE_TXN_JOB_REQUIREMENT_a
      (p_effective_date                 => p_effective_date
      ,p_txn_job_requirement_id         => p_txn_job_requirement_id
      ,p_object_version_number          => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_TXN_JOB_REQUIREMENT'
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
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to DELETE_TXN_JOB_REQUIREMENT;
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
    rollback to DELETE_TXN_JOB_REQUIREMENT;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end DELETE_TXN_JOB_REQUIREMENT;
--
end PQH_TXN_JOB_REQUIREMENTS_API;

/
