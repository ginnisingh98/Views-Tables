--------------------------------------------------------
--  DDL for Package Body PER_REC_ACTIVITY_FOR_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_REC_ACTIVITY_FOR_API" as
/* $Header: percfapi.pkb 115.5 2002/12/10 16:15:30 eumenyio ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  PER_REC_ACTIVITY_FOR_API.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< CREATE_REC_ACTIVITY_FOR >---------------------|
-- ----------------------------------------------------------------------------
--
procedure create_rec_activity_for
  (
   p_validate                        in     boolean  default false
  ,p_rec_activity_for_id             out nocopy    number
  ,p_business_group_id               in     number
  ,p_vacancy_id                      in     number
  ,p_rec_activity_id                 in     number
  ,p_object_version_number           out nocopy    number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'create_rec_activity_for';
  l_rec_activity_for_id      number;
  l_object_version_number    number;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_rec_activity_for;

  --
  -- Call Before Process User Hook
  --
  begin
    PER_REC_ACTIVITY_FOR_BK1.CREATE_REC_ACTIVITY_FOR_B
      (
       p_rec_activity_for_id            => l_rec_activity_for_id
      ,p_business_group_id              => p_business_group_id
      ,p_vacancy_id 			=> p_vacancy_id
      ,p_rec_activity_id                => p_rec_activity_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_REC_ACTIVITY_FOR'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  per_rcf_ins.ins
  (
   p_rec_activity_for_id	=> l_rec_activity_for_id
  ,p_object_version_number      => l_object_version_number
  ,p_business_group_id          => p_business_group_id
  ,p_vacancy_id                 => p_vacancy_id
  ,p_rec_activity_id            => p_rec_activity_id
  );

  --
  -- Call After Process User Hook
  --
  begin
    PER_REC_ACTIVITY_FOR_BK1.CREATE_REC_ACTIVITY_FOR_A
      (
       p_rec_activity_for_id            => l_rec_activity_for_id
      ,p_business_group_id              => p_business_group_id
      ,p_vacancy_id 			=> p_vacancy_id
      ,p_rec_activity_id                => p_rec_activity_id
      ,p_object_version_number          => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_REC_ACTIVITY_FOR'
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
  p_rec_activity_for_id    := l_rec_activity_for_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_REC_ACTIVITY_FOR;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_rec_activity_for_id    := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    p_rec_activity_for_id    := null;
    p_object_version_number  := null;
    rollback to CREATE_REC_ACTIVITY_FOR;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end CREATE_REC_ACTIVITY_FOR;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< UPDATE_REC_ACTIVITY_FOR >---------------------|
-- ----------------------------------------------------------------------------
--
procedure update_REC_ACTIVITY_FOR
  (p_validate                        in     boolean  default false
  ,p_rec_activity_for_id             in     number
  ,p_vacancy_id                      in     number   default hr_api.g_number
  ,p_rec_activity_id                 in     number   default hr_api.g_number
  ,p_object_version_number           in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'update_REC_ACTIVITY_FOR';
  l_object_version_number   number   := p_object_version_number;
  l_temp_ovn                number   := p_object_version_number;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_REC_ACTIVITY_FOR;

  --
  -- Call Before Process User Hook
  --
  begin
    PER_REC_ACTIVITY_FOR_BK2.UPDATE_REC_ACTIVITY_FOR_B
      (
       p_rec_activity_for_id       => p_rec_activity_for_id
      ,p_vacancy_id                => p_vacancy_id
      ,p_rec_activity_id           => p_rec_activity_id
      ,p_object_version_number     => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_REC_ACTIVITY_FOR'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
per_rcf_upd.upd
(
 p_rec_activity_for_id   => p_rec_activity_for_id
,p_vacancy_id            => p_vacancy_id
,p_rec_activity_id       => p_rec_activity_id
,p_object_version_number => l_object_version_number
);
--
  --
  -- Call After Process User Hook
  --
  begin
    PER_REC_ACTIVITY_FOR_BK2.UPDATE_REC_ACTIVITY_FOR_A
      (
       p_rec_activity_for_id       => p_rec_activity_for_id
      ,p_vacancy_id                => p_vacancy_id
      ,p_rec_activity_id           => p_rec_activity_id
      ,p_object_version_number     => l_object_version_number
      );

    exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_REC_ACTIVITY_FOR'
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
    rollback to UPDATE_REC_ACTIVITY_FOR;
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
    p_object_version_number  := l_temp_ovn;
    rollback to UPDATE_REC_ACTIVITY_FOR;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end UPDATE_REC_ACTIVITY_FOR;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< DELETE_REC_ACTIVITY_FOR >---------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_rec_activity_for
  (p_validate                      in     boolean  default false
  ,p_rec_activity_for_id           in     number
  ,p_object_version_number         in     number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'delete_REC_ACTIVITY_FOR';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_REC_ACTIVITY_FOR;

  --
  -- Call Before Process User Hook
  --
  begin
    PER_REC_ACTIVITY_FOR_BK3.DELETE_REC_ACTIVITY_FOR_B
      (
       p_rec_activity_for_id        => p_rec_activity_for_id
      ,p_object_version_number      => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_REC_ACTIVITY_FOR'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --

per_rcf_del.del
(
 p_rec_activity_for_id	 =>	p_rec_activity_for_id
,p_object_version_number =>     p_object_version_number
);


  --
  -- Call After Process User Hook
  --
  begin
    PER_REC_ACTIVITY_FOR_BK3.DELETE_REC_ACTIVITY_FOR_A
      (
       p_rec_activity_for_id	 =>	p_rec_activity_for_id
      ,p_object_version_number   =>     p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_REC_ACTIVITY_FOR'
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
    rollback to DELETE_REC_ACTIVITY_FOR;
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
    rollback to DELETE_REC_ACTIVITY_FOR;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end DELETE_REC_ACTIVITY_FOR;
--
end PER_REC_ACTIVITY_FOR_API;

/
