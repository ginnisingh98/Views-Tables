--------------------------------------------------------
--  DDL for Package Body IRC_LINKED_CANDIDATES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_LINKED_CANDIDATES_API" as
/* $Header: irilcapi.pkb 120.0.12010000.1 2010/03/17 14:06:00 vmummidi noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  IRC_LINKED_CANDIDATES_API.';
--
-- ----------------------------------------------------------------------------
-- |-------------------------< create_linked_candidate >--------------------|
-- ----------------------------------------------------------------------------
--
procedure create_linked_candidate
  (p_validate                       in           boolean  default false
  ,p_duplicate_set_id               in           number
  ,p_party_id                       in           number
  ,p_status                         in           varchar2
  ,p_target_party_id                in           number   default null
  ,p_link_id                        out nocopy   number
  ,p_object_version_number          out nocopy   number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                     varchar2(72) := g_package||'CREATE_LINKED_CANDIDATE';
  l_link_id                  number;
  l_object_version_number    number;
  l_effective_date           date;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_linked_candidate;
  --
  -- Call Before Process User Hook
  --
  begin
    irc_linked_candidates_bk1.create_linked_candidate_b
                 (p_duplicate_set_id			=>		p_duplicate_set_id
                 ,p_party_id				=>		p_party_id
                 ,p_status				=>		p_status
                 ,p_target_party_id			=>		p_target_party_id
                 );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_LINKED_CANDIDATE'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  -- Set the effective date to the sysdate
  l_effective_date := sysdate;

  irc_ilc_ins.ins(p_effective_date              =>      l_effective_date
                 ,p_duplicate_set_id		=>	p_duplicate_set_id
                 ,p_party_id			=>	p_party_id
                 ,p_status			=>	p_status
                 ,p_target_party_id		=>	p_target_party_id
		 ,p_link_id                     =>      l_link_id
                 ,p_object_version_number       =>      l_object_version_number
                 );
  -- Call After Process User Hook
  --
  begin
    irc_linked_candidates_bk1.create_linked_candidate_a
                 (p_link_id            =>      l_link_id
                 ,p_duplicate_set_id   =>      p_duplicate_set_id
                 ,p_party_id	       =>      p_party_id
                 ,p_status	       =>      p_status
                 ,p_target_party_id    =>      p_target_party_id
                 ,p_object_version_number       =>      l_object_version_number
                 );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_LINKED_CANDIDATE'
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
  p_link_id                   := l_link_id;
  p_object_version_number     := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_linked_candidate;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_link_id          := null;
    p_object_version_number     := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_linked_candidate;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_link_id          := null;
    p_object_version_number     := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_linked_candidate;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< update_linked_candidate >----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_linked_candidate
  (p_validate                       in       boolean  default false
  ,p_link_id                        in       number
  ,p_duplicate_set_id               in       number   default hr_api.g_number
  ,p_party_id                       in       number   default hr_api.g_number
  ,p_status                         in       varchar2 default hr_api.g_varchar2
  ,p_target_party_id                in       number   default hr_api.g_number
  ,p_object_version_number          in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number    number;
  l_effective_date           date;
  l_proc                     varchar2(72) := g_package||'UPDATE_LINKED_CANDIDATE';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_linked_candidate;
  --
  -- Call Before Process User Hook
  --
  begin
    irc_linked_candidates_bk2.update_linked_candidate_b
                 (p_link_id                =>      p_link_id
                 ,p_duplicate_set_id       =>      p_duplicate_set_id
                 ,p_party_id	           =>      p_party_id
                 ,p_status	           =>      p_status
                 ,p_target_party_id        =>      p_target_party_id
                 ,p_object_version_number  =>      p_object_version_number
                 );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_linked_candidate'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  -- Set the effective date to the sysdate
  l_effective_date := sysdate;
  l_object_version_number := p_object_version_number;
  if p_link_id is null then
    -- RAISE ERROR SAYING INVALID link_ID
    fnd_message.set_name('PER', 'IRC_XXXX_INV_LINK_ID');
    fnd_message.raise_error;
  end if;
  irc_ilc_upd.upd(p_effective_date              =>     l_effective_date
                 ,p_link_id                     =>      p_link_id
                 ,p_object_version_number       =>      l_object_version_number
                 ,p_duplicate_set_id            =>      p_duplicate_set_id
                 ,p_party_id	                =>      p_party_id
                 ,p_status	                =>      p_status
                 ,p_target_party_id             =>      p_target_party_id
                 );
  --
  -- Call After Process User Hook
  --
  begin
    irc_linked_candidates_bk2.update_linked_candidate_a
                 (p_link_id                =>      p_link_id
                 ,p_duplicate_set_id       =>      p_duplicate_set_id
                 ,p_party_id	           =>      p_party_id
                 ,p_status	           =>      p_status
                 ,p_target_party_id        =>      p_target_party_id
                 ,p_object_version_number  =>      p_object_version_number
                 );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_linked_candidate'
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
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_linked_candidate;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_linked_candidate;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_linked_candidate;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_linked_candidate >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_linked_candidate
  (p_validate                       in boolean  default false
  ,p_link_id                        in number
  ,p_object_version_number          in number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                     varchar2(72) := g_package||'DELETE_LINKED_CANDIDATE';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_linked_candidate;
  --
  -- Process Logic
  --
  if p_link_id is null then
    -- RAISE ERROR SAYING INVALID link_ID
    hr_utility.set_location('Invalid Link Id '|| l_proc, 20);
    fnd_message.set_name('PER', 'IRC_XXXX_INV_LINK_ID');
    fnd_message.raise_error;
  end if;
  --
  hr_utility.set_location('Calling Delete Link Id '|| l_proc, 30);
  --
  irc_ilc_del.del(p_link_id                     =>      p_link_id
                 ,p_object_version_number       =>      p_object_version_number
                 );
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_linked_candidate;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 50);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_linked_candidate;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 60);
    --
    raise;
end delete_linked_candidate;
--
end IRC_LINKED_CANDIDATES_API;

/
