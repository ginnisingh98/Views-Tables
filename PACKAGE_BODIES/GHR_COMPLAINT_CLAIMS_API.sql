--------------------------------------------------------
--  DDL for Package Body GHR_COMPLAINT_CLAIMS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_COMPLAINT_CLAIMS_API" as
/* $Header: ghcclapi.pkb 115.1 2003/01/30 16:31:42 asubrahm noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ghr_complaint_claims_api.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< Create_compl_claim> >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_compl_claim
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_complaint_id                   in     number
  ,p_claim                          in     varchar2 default null
  ,p_incident_date                  in     date     default null
  ,p_phase                          in     varchar2 default null
  ,p_mixed_flag                     in     varchar2 default null
  ,p_claim_source                   in     varchar2 default null
  ,p_agency_acceptance              in     varchar2 default null
  ,p_aj_acceptance                  in     varchar2 default null
  ,p_agency_appeal                  in     varchar2 default null
  ,p_compl_claim_id                   out nocopy number
  ,p_object_version_number            out nocopy number
  ) is

  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'create_compl_claim';
  l_compl_claim_id      number;
  l_object_version_number number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_compl_claim;
  hr_utility.set_location(l_proc, 20);
  --
  -- Truncate the time portion from all IN date parameters
  --
  -- Call Before Process User Hook
  --
  begin
    ghr_complaint_claims_bk_1.create_compl_claim_b
      (p_effective_date                 => trunc(p_effective_date)
      ,p_complaint_id                   => p_complaint_id
      ,p_claim                          => p_claim
      ,p_incident_date                  => p_incident_date
      ,p_phase                          => p_phase
      ,p_mixed_flag                     => p_mixed_flag
      ,p_claim_source                   => p_claim_source
      ,p_agency_acceptance              => p_agency_acceptance
      ,p_aj_acceptance                  => p_aj_acceptance
      ,p_agency_appeal                  => p_agency_appeal
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_compl_claim'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  --
  --
  -- Validation in addition to Row Handlers
  --

  hr_utility.set_location(l_proc, 40);
  --
  -- Process Logic
  --
  ghr_ccl_ins.ins
 (
   p_effective_date                 => p_effective_date
  ,p_complaint_id                   => p_complaint_id
  ,p_claim                          => p_claim
  ,p_incident_date                  => p_incident_date
  ,p_phase                          => p_phase
  ,p_mixed_flag                     => p_mixed_flag
  ,p_claim_source                   => p_claim_source
  ,p_agency_acceptance              => p_agency_acceptance
  ,p_aj_acceptance                  => p_aj_acceptance
  ,p_agency_appeal                  => p_agency_appeal
  ,p_compl_claim_id                 => l_compl_claim_id
  ,p_object_version_number          => l_object_version_number
  );
  hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    ghr_complaint_claims_bk_1.create_compl_claim_a
      (p_effective_date                 => trunc(p_effective_date)
      ,p_complaint_id                   => p_complaint_id
      ,p_claim                          => p_claim
      ,p_incident_date                  => p_incident_date
      ,p_phase                          => p_phase
      ,p_mixed_flag                     => p_mixed_flag
      ,p_claim_source                   => p_claim_source
      ,p_agency_acceptance              => p_agency_acceptance
      ,p_aj_acceptance                  => p_aj_acceptance
      ,p_agency_appeal                  => p_agency_appeal
      ,p_compl_claim_id                 => l_compl_claim_id
      ,p_object_version_number          => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_compl_claim'
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
  p_compl_claim_id         := l_compl_claim_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_compl_claim;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_compl_claim_id         := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_compl_claim;
    --RESET In/Out Params and SET Out Params
    p_compl_claim_id         := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_compl_claim;
--

procedure update_compl_claim
  (p_validate                     in     boolean default false
  ,p_effective_date               in     date
  ,p_compl_claim_id               in     number
  ,p_object_version_number        in out nocopy number
  ,p_complaint_id                 in     number    default hr_api.g_number
  ,p_claim                        in     varchar2  default hr_api.g_varchar2
  ,p_incident_date                in     date      default hr_api.g_date
  ,p_phase                        in     varchar2  default hr_api.g_varchar2
  ,p_mixed_flag                   in     varchar2  default hr_api.g_varchar2
  ,p_claim_source                 in     varchar2  default hr_api.g_varchar2
  ,p_agency_acceptance            in     varchar2  default hr_api.g_varchar2
  ,p_aj_acceptance                in     varchar2  default hr_api.g_varchar2
  ,p_agency_appeal                in     varchar2  default hr_api.g_varchar2
  )

is
  l_proc                varchar2(72) := g_package||'update_compl_claim';
  l_object_version_number number;
begin
hr_utility.set_location('Entering:'|| l_proc, 5);
  --
   savepoint update_compl_claim;

    --
    -- Remember IN OUT parameter IN values
    l_object_version_number := p_object_version_number;
  --
  -- Truncate the time portion from all IN date parameters
  --

  --
  -- Call Before Process User Hook
  --
  begin
    ghr_complaint_claims_bk_2.update_compl_claim_b
      (p_effective_date                 => trunc(p_effective_date)
      ,p_complaint_id                   => p_complaint_id
      ,p_claim                          => p_claim
      ,p_incident_date                  => p_incident_date
      ,p_phase                          => p_phase
      ,p_mixed_flag                     => p_mixed_flag
      ,p_claim_source                   => p_claim_source
      ,p_agency_acceptance              => p_agency_acceptance
      ,p_aj_acceptance                  => p_aj_acceptance
      ,p_agency_appeal                  => p_agency_appeal
      ,p_compl_claim_id                 => p_compl_claim_id
      ,p_object_version_number          => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_compl_claim'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
 -- Store the original ovn in case we rollback when p_validate is true
 --
  l_object_version_number  := p_object_version_number;

  hr_utility.set_location(l_proc, 6);

    ghr_ccl_upd.upd
  (p_effective_date                 => p_effective_date
  ,p_compl_claim_id                 => p_compl_claim_id
  ,p_complaint_id                   => p_complaint_id
  ,p_claim                          => p_claim
  ,p_incident_date                  => p_incident_date
  ,p_phase                          => p_phase
  ,p_mixed_flag                     => p_mixed_flag
  ,p_claim_source                   => p_claim_source
  ,p_agency_acceptance              => p_agency_acceptance
  ,p_aj_acceptance                  => p_aj_acceptance
  ,p_agency_appeal                  => p_agency_appeal
  ,p_object_version_number          => l_object_version_number
  );
  --
  -- Call After Process User Hook
  --
  begin
    ghr_complaint_claims_bk_2.update_compl_claim_a
      (p_effective_date                 => trunc(p_effective_date)
      ,p_complaint_id                   => p_complaint_id
      ,p_claim                          => p_claim
      ,p_incident_date                  => p_incident_date
      ,p_phase                          => p_phase
      ,p_mixed_flag                     => p_mixed_flag
      ,p_claim_source                   => p_claim_source
      ,p_agency_acceptance              => p_agency_acceptance
      ,p_aj_acceptance                  => p_aj_acceptance
      ,p_agency_appeal                  => p_agency_appeal
      ,p_compl_claim_id                 => p_compl_claim_id
      ,p_object_version_number          => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_compl_claim'
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
    rollback to update_compl_claim;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_compl_claim;
    --RESET In/Out Params and SET Out Params
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;

end update_compl_claim;

-- ----------------------------------------------------------------------------
-- |-----------------------< delete_compl_claim >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_compl_claim
  (p_validate                      in     boolean  default false
  ,p_compl_claim_id                in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'delete_compl_claim';
  l_exists                boolean      := false;

begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  --
  savepoint delete_compl_claim;
  --
  -- Truncate the time portion from all IN date parameters
  --

  --
  -- Call Before Process User Hook
  --
  begin
    ghr_complaint_claims_bk_3.delete_compl_claim_b
      (p_compl_claim_id                => p_compl_claim_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_compl_claim'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
 -- Process Logic
   ghr_ccl_del.del
    (p_compl_claim_id                => p_compl_claim_id
    ,p_object_version_number         => p_object_version_number
     );
 --
  hr_utility.set_location(l_proc, 8);
  --
  -- Call After Process User Hook
  --
  begin
    ghr_complaint_claims_bk_3.delete_compl_claim_a
      (p_compl_claim_id                => p_compl_claim_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_compl_claim'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
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
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_compl_claim;
    --
  When Others then
    ROLLBACK TO delete_compl_claim;
    raise;

  hr_utility.set_location(' Leaving:'||l_proc, 12);
end delete_compl_claim;
end ghr_complaint_claims_api;


/
