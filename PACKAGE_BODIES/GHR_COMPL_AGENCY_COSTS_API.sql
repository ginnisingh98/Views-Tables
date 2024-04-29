--------------------------------------------------------
--  DDL for Package Body GHR_COMPL_AGENCY_COSTS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_COMPL_AGENCY_COSTS_API" as
/* $Header: ghcstapi.pkb 120.0 2005/05/29 03:05:00 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  ghr_compl_agency_costs_api.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------<create_agency_costs> >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_agency_costs
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_complaint_id                   in     number
  ,p_phase                          in     varchar2 default null
  ,p_stage                          in     varchar2 default null
  ,p_category                       in     varchar2 default null
  ,p_amount                         in     number   default null
  ,p_cost_date                      in     date     default null
  ,p_description                    in     varchar2 default null
  ,p_compl_agency_cost_id           out nocopy number
  ,p_object_version_number          out nocopy number

   ) is

  --
  -- Declare cursors and local variables
  --

  l_proc                  varchar2(72) := g_package||'create_agency_costs';
  l_compl_agency_cost_id  number;
  l_object_version_number number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_agency_costs;
  hr_utility.set_location(l_proc, 20);
  --
  -- Truncate the time portion from all IN date parameters
  --
  --
  -- Call Before Process User Hook
  --
  begin
    ghr_compl_agency_costs_bk1.create_agency_costs_b
      (p_effective_date                 => trunc(p_effective_date)
      ,p_complaint_id                   =>     p_complaint_id
      ,p_phase                          =>     p_phase
      ,p_stage                          =>     p_stage
      ,p_category                       =>     p_category
      ,p_amount                         =>     p_amount
      ,p_cost_date                      =>     p_cost_date
      ,p_description                    =>     p_description
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_AGENCY_COSTS'
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
  ghr_cst_ins.ins
 (p_effective_date                 => p_effective_date
 ,p_complaint_id                   => p_complaint_id
 ,p_phase                          => p_phase
 ,p_stage                          => p_stage
 ,p_category                       => p_category
 ,p_amount                         => p_amount
 ,p_cost_date                      => p_cost_date
 ,p_description                    => p_description
 ,p_compl_agency_cost_id           => l_compl_agency_cost_id
 ,p_object_version_number          => l_object_version_number
  );
  hr_utility.set_location(l_proc, 50);
  --
  --
  -- Call After Process User Hook
  --
  begin
    ghr_compl_agency_costs_bk1.create_agency_costs_a
      (p_effective_date                 => trunc(p_effective_date)
      ,p_complaint_id                   => p_complaint_id
      ,p_phase                          => p_phase
      ,p_stage                          => p_stage
      ,p_category                       => p_category
      ,p_amount                         => p_amount
      ,p_cost_date                      => p_cost_date
      ,p_description                    => p_description
      ,p_compl_agency_cost_id           => l_compl_agency_cost_id
      ,p_object_version_number          => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_AGENCY_COSTS'
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
  p_compl_agency_cost_id    := l_compl_agency_cost_id;
  p_object_version_number   := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_agency_costs;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_compl_agency_cost_id   := null;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_agency_costs;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_compl_agency_cost_id         := null;
    p_object_version_number   := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_agency_costs;
--


procedure update_agency_costs
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_compl_agency_cost_id           in     number
  ,p_complaint_id                   in     number   default hr_api.g_number
  ,p_phase                          in     varchar2 default hr_api.g_varchar2
  ,p_stage                          in     varchar2 default hr_api.g_varchar2
  ,p_category                       in     varchar2 default hr_api.g_varchar2
  ,p_amount                         in     number   default hr_api.g_number
  ,p_cost_date                      in     date     default hr_api.g_date
  ,p_description                    in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  )

is
  l_proc                varchar2(72) := g_package||'update_agency_costs';
  l_object_version_number number;
-- Initial OVN.
  l_i_object_version_number number;
begin
hr_utility.set_location('Entering:'|| l_proc, 5);
  --
   savepoint update_agency_costs;
  --
  -- Remember IN OUT parameter IN values
  l_i_object_version_number := p_object_version_number;
  --
  -- Truncate the time portion from all IN date parameters
  --

  --
  -- Call Before Process User Hook
  --
  begin
    ghr_compl_agency_costs_bk2.update_agency_costs_b
      (p_effective_date                 => trunc(p_effective_date)
      ,p_complaint_id                   => p_complaint_id
      ,p_phase                          => p_phase
      ,p_stage                          => p_stage
      ,p_category                       => p_category
      ,p_amount                         => p_amount
      ,p_cost_date                      => p_cost_date
      ,p_description                    => p_description
      ,p_compl_agency_cost_id           => p_compl_agency_cost_id
      ,p_object_version_number          => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_AGENCY_COSTS'
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

    ghr_cst_upd.upd
  (p_effective_date                 => p_effective_date
  ,p_complaint_id                   => p_complaint_id
  ,p_phase                          => p_phase
  ,p_stage                          => p_stage
  ,p_category                       => p_category
  ,p_amount                         => p_amount
  ,p_cost_date                      => p_cost_date
  ,p_description                    => p_description
  ,p_compl_agency_cost_id           => p_compl_agency_cost_id
  ,p_object_version_number          => l_object_version_number
  );
  --
  -- Call After Process User Hook
  --
  begin
    ghr_compl_agency_costs_bk2.update_agency_costs_a
      (p_effective_date                 => trunc(p_effective_date)
      ,p_complaint_id                   => p_complaint_id
      ,p_phase                          => p_phase
      ,p_stage                          => p_stage
      ,p_category                       => p_category
      ,p_amount                         => p_amount
      ,p_cost_date                      => p_cost_date
      ,p_description                    => p_description
      ,p_compl_agency_cost_id           => p_compl_agency_cost_id
      ,p_object_version_number          => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_AGENCY_COSTS'
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
    rollback to update_agency_costs;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := l_i_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_agency_costs;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number  := l_i_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;

end update_agency_costs;

-- ----------------------------------------------------------------------------
-- |-----------------------< delete_agency_costs >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_agency_costs
  (p_validate                       in     boolean  default false
  ,p_compl_agency_cost_id           in     number
  ,p_object_version_number          in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'delete_agency_costs';
  l_exists                boolean      := false;

begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  --
  savepoint delete_agency_costs;
  --
  -- Truncate the time portion from all IN date parameters
  --

  --
  -- Call Before Process User Hook
  --
  begin
    ghr_compl_agency_costs_bk3.delete_agency_costs_b
      (p_compl_agency_cost_id           => p_compl_agency_cost_id
      ,p_object_version_number          => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_AGENCY_COSTS'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
 -- Process Logic
   ghr_cst_del.del
    (p_compl_agency_cost_id           => p_compl_agency_cost_id
    ,p_object_version_number          => p_object_version_number
     );
 --
  hr_utility.set_location(l_proc, 8);
  --
  -- Call After Process User Hook
  --
  begin
    ghr_compl_agency_costs_bk3.delete_agency_costs_a
      (p_compl_agency_cost_id           => p_compl_agency_cost_id
      ,p_object_version_number          => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_AGENCY_COSTS'
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
    ROLLBACK TO delete_agency_costs;
    --
  When Others then
    ROLLBACK TO delete_agency_costs;
    raise;

  hr_utility.set_location(' Leaving:'||l_proc, 12);
end delete_agency_costs;
end ghr_compl_agency_costs_api;


/
