--------------------------------------------------------
--  DDL for Package Body GHR_COMPLAINT_BASES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_COMPLAINT_BASES_API" as
/* $Header: ghcbaapi.pkb 115.1 2003/01/30 16:31:37 asubrahm noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ghr_complaint_bases_api.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_compl_basis> >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_compl_basis
  (p_validate                     in     boolean default false
  ,p_effective_date               in date
  ,p_compl_claim_id               in number
  ,p_basis                        in varchar2 default null
  ,p_value                        in varchar2 default null
  ,p_statute                      in varchar2 default null
  ,p_agency_finding               in varchar2 default null
  ,p_aj_finding                   in varchar2 default null
  ,p_compl_basis_id               out nocopy number
  ,p_object_version_number        out nocopy number
  ) is

  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'create_compl_basis';
  l_compl_basis_id      number;
  l_object_version_number number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_compl_basis;
  hr_utility.set_location(l_proc, 20);
  --
  -- Truncate the time portion from all IN date parameters
  --
  -- Call Before Process User Hook
  --
  begin
    ghr_complaint_bases_bk_1.create_compl_basis_b
      (p_effective_date                => trunc(p_effective_date)
      ,p_compl_claim_id                => p_compl_claim_id
      ,p_basis                         => p_basis
      ,p_value                         => p_value
      ,p_statute                       => p_statute
      ,p_agency_finding                => p_agency_finding
      ,p_aj_finding                    => p_aj_finding
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_compl_basis'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --

  hr_utility.set_location(l_proc, 40);
  --
  -- Process Logic
  --
  ghr_cba_ins.ins
  (p_effective_date               => p_effective_date
  ,p_compl_claim_id               => p_compl_claim_id
  ,p_basis                        => p_basis
  ,p_value                        => p_value
  ,p_statute                      => p_statute
  ,p_agency_finding               => p_agency_finding
  ,p_aj_finding                   => p_aj_finding
  ,p_compl_basis_id               => l_compl_basis_id
  ,p_object_version_number        => l_object_version_number
  );
  hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    ghr_complaint_bases_bk_1.create_compl_basis_a
      (p_effective_date               => trunc(p_effective_date)
      ,p_compl_claim_id               => p_compl_claim_id
      ,p_basis                        => p_basis
      ,p_value                        => p_value
      ,p_statute                      => p_statute
      ,p_agency_finding               => p_agency_finding
      ,p_aj_finding                   => p_aj_finding
      ,p_compl_basis_id               => l_compl_basis_id
      ,p_object_version_number        => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_compl_basis'
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
  p_compl_basis_id         := l_compl_basis_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_compl_basis;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_compl_basis_id         := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_compl_basis;
    -- Reset In/Out Params and SET Out Params.
    p_compl_basis_id         := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_compl_basis;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_compl_basis> >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_compl_basis
  (p_validate                     in     boolean default false
  ,p_effective_date               in     date
  ,p_compl_basis_id               in     number
  ,p_compl_claim_id               in     number    default hr_api.g_number
  ,p_basis                        in     varchar2  default hr_api.g_varchar2
  ,p_value                        in     varchar2  default hr_api.g_varchar2
  ,p_statute                      in     varchar2  default hr_api.g_varchar2
  ,p_agency_finding               in     varchar2  default hr_api.g_varchar2
  ,p_aj_finding                   in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number        in out nocopy number
  )

is
  l_proc                varchar2(72) := g_package||'update_compl_basis';
  l_object_version_number number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
   savepoint update_compl_basis;
  --
  --  Initialise Local Variables
    l_object_version_number:=p_object_version_number;
  --
  -- Truncate the time portion from all IN date parameters
  --
  -- Call Before Process User Hook
  --
  begin
    ghr_complaint_bases_bk_2.update_compl_basis_b
      (p_effective_date                 => trunc(p_effective_date)
      ,p_compl_claim_id                 => p_compl_claim_id
      ,p_basis                          => p_basis
      ,p_value                          => p_value
      ,p_statute                        => p_statute
      ,p_agency_finding                 => p_agency_finding
      ,p_aj_finding                     => p_aj_finding
      ,p_compl_basis_id                 => p_compl_basis_id
      ,p_object_version_number          => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_compl_basis'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  -- Store the original ovn in case we rollback when p_validate is true
  --
      l_object_version_number  := p_object_version_number;

  hr_utility.set_location(l_proc, 6);

    ghr_cba_upd.upd
  (p_effective_date                 => p_effective_date
  ,p_compl_claim_id                 => p_compl_claim_id
  ,p_basis                          => p_basis
  ,p_value                          => p_value
  ,p_statute                        => p_statute
  ,p_agency_finding                 => p_agency_finding
  ,p_aj_finding                     => p_aj_finding
  ,p_compl_basis_id                 => p_compl_basis_id
  ,p_object_version_number          => l_object_version_number
  );
  --
  -- Call After Process User Hook
  --
  begin
    ghr_complaint_bases_bk_2.update_compl_basis_a
      (p_effective_date                 => trunc(p_effective_date)
      ,p_compl_claim_id                 => p_compl_claim_id
      ,p_basis                          => p_basis
      ,p_value                          => p_value
      ,p_statute                        => p_statute
      ,p_agency_finding                 => p_agency_finding
      ,p_aj_finding                     => p_aj_finding
      ,p_compl_basis_id                 => p_compl_basis_id
      ,p_object_version_number          => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_compl_basis'
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
    rollback to update_compl_basis;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    -- Reset In/Out Params and SET Out Params
     p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_compl_basis;
    -- Reset In/Out Params and SET Out Params
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;

end update_compl_basis;

-- ----------------------------------------------------------------------------
-- |-----------------------< delete_compl_basis >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_compl_basis
  (p_validate                      in     boolean  default false
  ,p_compl_basis_id                in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'delete_compl_basis';
  l_exists                boolean      := false;

begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  --
  savepoint delete_compl_basis;
  --
  -- Truncate the time portion from all IN date parameters
  --

  --
  -- Call Before Process User Hook
  --
  begin
    ghr_complaint_bases_bk_3.delete_compl_basis_b
      (p_compl_basis_id                => p_compl_basis_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_compl_basis'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  -- Process Logic
   ghr_cba_del.del
    (p_compl_basis_id                => p_compl_basis_id
    ,p_object_version_number         => p_object_version_number
     );
 --
  hr_utility.set_location(l_proc, 8);
  --
  -- Call After Process User Hook
  --
  begin
    ghr_complaint_bases_bk_3.delete_compl_basis_a
      (p_compl_basis_id                => p_compl_basis_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_compl_basis'
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
  hr_utility.set_location(' Leaving:'||l_proc, 11);
exception
  when hr_api.validate_enabled then
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_compl_basis;
    --
  When Others then
    ROLLBACK TO delete_compl_basis;
    raise;

  hr_utility.set_location(' Leaving:'||l_proc, 12);
end delete_compl_basis;
end ghr_complaint_bases_api;

/
