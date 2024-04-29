--------------------------------------------------------
--  DDL for Package Body PQH_RANK_PROCESS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_RANK_PROCESS_API" as
/* $Header: pqrnkapi.pkb 120.1 2005/06/03 11:58:40 nsanghal noship $ */
--
-- Package Variables
--
g_package  constant varchar2(33) := '  PQH_RANK_PROCESS_API.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_rank_process >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_rank_process
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_rank_process_id                  out nocopy number
  ,p_pgm_id                        in     number default null
  ,p_pl_id                         in     number default null
  ,p_oipl_id                       in     number default null
  ,p_process_cd                    in     varchar2
  ,p_process_date                  in     date
  ,p_benefit_action_id             in     number default null
  ,p_person_id                     in     number
  ,p_assignment_id                 in     number
  ,p_total_score                   in     number default null
  ,p_request_id                    in     number default null
  ,p_business_group_id             in     number default null
  ,p_object_version_number            out nocopy number
  ,p_per_in_ler_id                 in     number default null
  ) is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number    number;
  l_effective_date      date;
  l_rank_process_id     pqh_rank_processes.rank_process_id%Type;
  l_proc constant varchar2(72):= g_package||'create_rank_process';
begin

  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_RANK_PROCESS;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date        := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin
    pqh_rank_process_bk1.create_rank_process_b
      (p_effective_date                => l_effective_date
      ,p_rank_process_id               => l_rank_process_id
      ,p_pgm_id                        => p_pgm_id
      ,p_pl_id                         => p_pl_id
      ,p_oipl_id                       => p_oipl_id
      ,p_process_cd                    => p_process_cd
      ,p_process_date                  => p_process_date
      ,p_benefit_action_id             => p_benefit_action_id
      ,p_person_id                     => p_person_id
      ,p_assignment_id                 => p_assignment_id
      ,p_total_score                   => p_total_score
      ,p_request_id                    => p_request_id
      ,p_business_group_id             => p_business_group_id
      ,p_per_in_ler_id                 => p_per_in_ler_id
      );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQH_RANK_PROCESS_API'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  pqh_rnk_ins.ins
      (p_effective_date                => l_effective_date
      ,p_pgm_id                        => p_pgm_id
      ,p_pl_id                         => p_pl_id
      ,p_oipl_id                       => p_oipl_id
      ,p_process_cd                    => p_process_cd
      ,p_process_date                  => p_process_date
      ,p_benefit_action_id             => p_benefit_action_id
      ,p_person_id                     => p_person_id
      ,p_assignment_id                 => p_assignment_id
      ,p_total_score                   => p_total_score
      ,p_request_id                    => p_request_id
      ,p_rank_process_id               => l_rank_process_id
      ,p_business_group_id             => p_business_group_id
      ,p_object_version_number         => l_object_version_number
      ,p_per_in_ler_id                 => p_per_in_ler_id
      );

  --
  -- Call After Process User Hook
  --
  begin
    pqh_rank_process_bk1.create_rank_process_a
      (p_effective_date                => l_effective_date
      ,p_rank_process_id               => l_rank_process_id
      ,p_pgm_id                        => p_pgm_id
      ,p_pl_id                         => p_pl_id
      ,p_oipl_id                       => p_oipl_id
      ,p_process_cd                    => p_process_cd
      ,p_process_date                  => p_process_date
      ,p_benefit_action_id             => p_benefit_action_id
      ,p_person_id                     => p_person_id
      ,p_assignment_id                 => p_assignment_id
      ,p_total_score                   => p_total_score
      ,p_request_id                    => p_request_id
      ,p_business_group_id             => p_business_group_id
      ,p_object_version_number         => l_object_version_number
      ,p_per_in_ler_id                 => p_per_in_ler_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQH_RANK_PROCESS_API'
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
  p_rank_process_id        := l_rank_process_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_RANK_PROCESS;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_rank_process_id        := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_RANK_PROCESS;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_rank_process_id        := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_rank_process;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_rank_process >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_rank_process
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_rank_process_id               in     number
  ,p_pgm_id                        in     number default hr_api.g_number
  ,p_pl_id                         in     number default hr_api.g_number
  ,p_oipl_id                       in     number default hr_api.g_number
  ,p_process_cd                    in     varchar2
  ,p_process_date                  in     date
  ,p_benefit_action_id             in     number default hr_api.g_number
  ,p_person_id                     in     number
  ,p_assignment_id                 in     number
  ,p_total_score                   in     number default hr_api.g_number
  ,p_request_id                    in     number default hr_api.g_number
  ,p_business_group_id             in     number default hr_api.g_number
  ,p_object_version_number         in out nocopy number
  ,p_per_in_ler_id                 in     number default hr_api.g_number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number    number;
  l_effective_date      date;
  --l_rank_process_id     pqh_rank_processes.rank_process_id%Type;
  l_proc constant varchar2(72):= g_package||'update_rank_process';
begin

  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  savepoint UPDATE_RANK_PROCESS;
  --
  --Remember IN OUT parameter IN values
  --
  l_object_version_number := p_object_version_number;

  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin
    pqh_rank_process_bk2.update_rank_process_b
      (p_effective_date                => l_effective_date
      ,p_rank_process_id               => p_rank_process_id
      ,p_pgm_id                        => p_pgm_id
      ,p_pl_id                         => p_pl_id
      ,p_oipl_id                       => p_oipl_id
      ,p_process_cd                    => p_process_cd
      ,p_process_date                  => p_process_date
      ,p_benefit_action_id             => p_benefit_action_id
      ,p_person_id                     => p_person_id
      ,p_assignment_id                 => p_assignment_id
      ,p_total_score                   => p_total_score
      ,p_request_id                    => p_request_id
      ,p_business_group_id             => p_business_group_id
      ,p_object_version_number         => l_object_version_number
      ,p_per_in_ler_id                 => p_per_in_ler_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQH_RANK_PROCESS_API'
        ,p_hook_type   => 'BP'
        );
  end;

 --
  -- Process Logic
  --
  pqh_rnk_upd.upd
      (p_effective_date                => l_effective_date
      ,p_rank_process_id               => p_rank_process_id
      ,p_pgm_id                        => p_pgm_id
      ,p_pl_id                         => p_pl_id
      ,p_oipl_id                       => p_oipl_id
      ,p_process_cd                    => p_process_cd
      ,p_process_date                  => p_process_date
      ,p_benefit_action_id             => p_benefit_action_id
      ,p_person_id                     => p_person_id
      ,p_assignment_id                 => p_assignment_id
      ,p_total_score                   => p_total_score
      ,p_request_id                    => p_request_id
      ,p_business_group_id             => p_business_group_id
      ,p_object_version_number         => l_object_version_number
      ,p_per_in_ler_id                 => p_per_in_ler_id
      );

  --
  -- Call After Process User Hook
  --
  begin
    pqh_rank_process_bk2.update_rank_process_a
      (p_effective_date                => l_effective_date
      ,p_rank_process_id               => p_rank_process_id
      ,p_pgm_id                        => p_pgm_id
      ,p_pl_id                         => p_pl_id
      ,p_oipl_id                       => p_oipl_id
      ,p_process_cd                    => p_process_cd
      ,p_process_date                  => p_process_date
      ,p_benefit_action_id             => p_benefit_action_id
      ,p_person_id                     => p_person_id
      ,p_assignment_id                 => p_assignment_id
      ,p_total_score                   => p_total_score
      ,p_request_id                    => p_request_id
      ,p_business_group_id             => p_business_group_id
      ,p_object_version_number         => l_object_version_number
      ,p_per_in_ler_id                 => p_per_in_ler_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQH_RANK_PROCESS_API'
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
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);

exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to UPDATE_RANK_PROCESS;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to UPDATE_RANK_PROCESS;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number  := l_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_rank_process;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_rank_process >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_rank_process
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_rank_process_id               in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number    number;
  l_effective_date      date;
  l_proc constant varchar2(72):= g_package||'delete_rank_process';
begin

  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  savepoint DELETE_RANK_PROCESS;
  --
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin
    pqh_rank_process_bk3.delete_rank_process_b
      (p_effective_date                => l_effective_date
      ,p_rank_process_id               => p_rank_process_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQH_RANK_PROCESS_API'
        ,p_hook_type   => 'BP'
        );
  end;

 --
  -- Process Logic
  --
  pqh_rnk_del.del
      (p_rank_process_id               => p_rank_process_id
      ,p_object_version_number         => p_object_version_number
      );

  --
  -- Call After Process User Hook
  --
  begin
    pqh_rank_process_bk3.delete_rank_process_a
      (p_effective_date                => l_effective_date
      ,p_rank_process_id               => p_rank_process_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQH_RANK_PROCESS_API'
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
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);

exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to DELETE_RANK_PROCESS;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to DELETE_RANK_PROCESS;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_rank_process;
--
end pqh_rank_process_api;

/
