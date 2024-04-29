--------------------------------------------------------
--  DDL for Package Body GHR_COMPLAINT_ADRS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_COMPLAINT_ADRS_API" as
/* $Header: ghcadapi.pkb 115.4 2003/01/30 16:31:29 asubrahm noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ghr_complaint_adr_api.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< Create_compl_adr> >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_compl_adr
  (p_validate                       in     boolean
  ,p_effective_date                 in     date
  ,p_complaint_id                   in     number
  ,p_stage                          in     varchar2
  ,p_start_date                     in     date
  ,p_end_date                       in     date
  ,p_adr_resource                   in     varchar2
  ,p_technique                      in     varchar2
  ,p_outcome                        in     varchar2
  ,p_adr_offered                    in     varchar2
  ,p_date_accepted                  in     date
  ,p_compl_adr_id                      out nocopy number
  ,p_object_version_number             out nocopy number
   ) is

  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'create_compl_adr';
  l_compl_adr_id      number;
  l_object_version_number number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_compl_adr;
  hr_utility.set_location(l_proc, 20);
  --
  -- Truncate the time portion from all IN date parameters
  --
  --
  -- Call Before Process User Hook
  --
  begin
    ghr_complaint_adrs_bk_1.create_compl_adr_b
      (p_effective_date                => trunc(p_effective_date)
      ,p_complaint_id                  => p_complaint_id
      ,p_stage                         => p_stage
      ,p_start_date                    => p_start_date
      ,p_end_date                      => p_end_date
      ,p_adr_resource                  => p_adr_resource
      ,p_technique                     => p_technique
      ,p_outcome                       => p_outcome
      ,p_adr_offered                   => p_adr_offered
      ,p_date_accepted                 => p_date_accepted
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_compl_adr'
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
  ghr_cad_ins.ins
 (p_effective_date                  => p_effective_date
  ,p_complaint_id                   => p_complaint_id
  ,p_stage                          => p_stage
  ,p_start_date                     => p_start_date
  ,p_end_date                       => p_end_date
  ,p_adr_resource                   => p_adr_resource
  ,p_technique                      => p_technique
  ,p_outcome                        => p_outcome
  ,p_adr_offered                    => p_adr_offered
  ,p_date_accepted                  => p_date_accepted
  ,p_compl_adr_id                   => l_compl_adr_id
  ,p_object_version_number          => l_object_version_number
  );

  hr_utility.set_location(l_proc, 50);
  --
  -- Call After Process User Hook
  --
  begin
    ghr_complaint_adrs_bk_1.create_compl_adr_a
      (p_effective_date                => trunc(p_effective_date)
      ,p_complaint_id                  => p_complaint_id
      ,p_stage                         => p_stage
      ,p_start_date                    => p_start_date
      ,p_end_date                      => p_end_date
      ,p_adr_resource                  => p_adr_resource
      ,p_technique                     => p_technique
      ,p_outcome                       => p_outcome
      ,p_adr_offered                   => p_adr_offered
      ,p_date_accepted                 => p_date_accepted
      ,p_compl_adr_id                  => l_compl_adr_id
      ,p_object_version_number         => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_compl_adr'
        ,p_hook_type   => 'AP'
        );
  end;
  --

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_compl_adr_id           := l_compl_adr_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_compl_adr;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_compl_adr_id           := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_compl_adr;
    p_compl_adr_id           := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_compl_adr;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< Update_compl_adr> >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_compl_adr
  (p_validate                     in     boolean
  ,p_effective_date               in     date
  ,p_compl_adr_id                 in     number
  ,p_complaint_id                 in     number
  ,p_stage                        in     varchar2
  ,p_start_date                   in     date
  ,p_end_date                     in     date
  ,p_adr_resource                 in     varchar2
  ,p_technique                    in     varchar2
  ,p_outcome                      in     varchar2
  ,p_adr_offered                  in     varchar2
  ,p_date_accepted                in     date
  ,p_object_version_number        in out nocopy number
   )

is
  l_proc                varchar2(72) := g_package||'update_compl_adr';
  l_compl_adr_id      number;
  l_object_version_number number;
begin
hr_utility.set_location('Entering:'|| l_proc, 5);
  --
   savepoint update_compl_adr;
  -- Truncate the time portion from all IN date parameters
  --
  --
  -- Call Before Process User Hook
  --
  begin
    ghr_complaint_adrs_bk_2.update_compl_adr_b
      (p_effective_date                 => trunc(p_effective_date)
      ,p_compl_adr_id                   => p_compl_adr_id
      ,p_complaint_id                   => p_complaint_id
      ,p_stage                          => p_stage
      ,p_start_date                     => p_start_date
      ,p_end_date                       => p_end_date
      ,p_adr_resource                   => p_adr_resource
      ,p_technique                      => p_technique
      ,p_outcome                        => p_outcome
      ,p_adr_offered                    => p_adr_offered
      ,p_date_accepted                  => p_date_accepted
      ,p_object_version_number          => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Update_compl_adr'
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

    ghr_cad_upd.upd
  (p_effective_date                 => p_effective_date
  ,p_complaint_id                   => p_complaint_id
  ,p_stage                          => p_stage
  ,p_start_date                     => p_start_date
  ,p_end_date                       => p_end_date
  ,p_adr_resource                   => p_adr_resource
  ,p_technique                      => p_technique
  ,p_outcome                        => p_outcome
  ,p_adr_offered                    => p_adr_offered
  ,p_date_accepted                  => p_date_accepted
  ,p_compl_adr_id                   => p_compl_adr_id
  ,p_object_version_number          => l_object_version_number
  );
  --
  -- Call After Process User Hook
  --
  begin
    ghr_complaint_adrs_bk_2.update_compl_adr_a
      (p_effective_date                => trunc(p_effective_date)
      ,p_complaint_id                  => p_complaint_id
      ,p_stage                         => p_stage
      ,p_start_date                    => p_start_date
      ,p_end_date                      => p_end_date
      ,p_adr_resource                  => p_adr_resource
      ,p_technique                     => p_technique
      ,p_outcome                       => p_outcome
      ,p_adr_offered                   => p_adr_offered
      ,p_date_accepted                 => p_date_accepted
      ,p_compl_adr_id                  => p_compl_adr_id
      ,p_object_version_number         => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'Update_compl_adr'
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
    rollback to update_compl_adr;
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
    rollback to update_compl_adr;
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;

end update_compl_adr;

-- ----------------------------------------------------------------------------
-- |-----------------------< delete_compl_adr >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_compl_adr
  (p_validate                      in     boolean
  ,p_compl_adr_id                  in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'delete_compl_adr';
  l_exists                boolean      := false;

begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  --
  savepoint delete_compl_adr;
  --
  -- Truncate the time portion from all IN date parameters
  --
  --
  -- Call Before Process User Hook
  --
  begin
    ghr_complaint_adrs_bk_3.delete_compl_adr_b
      (p_compl_adr_id                  => p_compl_adr_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_compl_adr'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
 -- Process Logic
   ghr_cad_del.del
    (p_compl_adr_id                  => p_compl_adr_id
    ,p_object_version_number         => p_object_version_number
     );
 --
  hr_utility.set_location(l_proc, 8);
  --
  -- Call After Process User Hook
  --
  begin
    ghr_complaint_adrs_bk_3.delete_compl_adr_a
      (p_compl_adr_id                  => p_compl_adr_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_compl_adr'
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
    ROLLBACK TO delete_compl_adr;
    --
  When Others then
    ROLLBACK TO delete_compl_adr;
    raise;

  hr_utility.set_location(' Leaving:'||l_proc, 12);
end delete_compl_adr;
end ghr_complaint_adrs_api;

/
