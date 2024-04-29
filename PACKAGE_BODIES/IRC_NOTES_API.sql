--------------------------------------------------------
--  DDL for Package Body IRC_NOTES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_NOTES_API" as
/* $Header: irinoapi.pkb 120.0 2005/09/27 09:08:47 sayyampe noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  IRC_NOTES_API.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< <CREATE_NOTE> >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_NOTE
   (p_validate                      in     boolean  default false
  ,p_offer_status_history_id        in     number
  ,p_note_text                      in     varchar2
  ,p_note_id                          out nocopy   number
  ,p_object_version_number            out nocopy   number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_note_id             number(15);
  l_object_version_number number(9);
  l_proc                varchar2(72) := g_package||'CREATE_NOTE';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_NOTE;
  --
  -- Truncate the time portion from all IN date parameters
  --
  --
  -- Call Before Process User Hook
  --
  begin
    IRC_NOTES_BK1.CREATE_NOTE_b
      (p_offer_status_history_id       => p_offer_status_history_id
      ,p_note_text                     => p_note_text
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_NOTE'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  irc_ino_ins.ins
    (
     p_offer_status_history_id       => p_offer_status_history_id
     ,p_note_text                     => p_note_text
     ,p_note_id                       => l_note_id
     ,p_object_version_number         => l_object_version_number
    );
  --
  -- Call After Process User Hook
  --
  begin
    IRC_NOTES_BK1.CREATE_NOTE_a
      (p_note_id                       => l_note_id
      ,p_offer_status_history_id       => p_offer_status_history_id
      ,p_note_text                     => p_note_text
      ,p_object_version_number         => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_NOTE'
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
  p_note_id                := l_note_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_NOTE;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_note_id                := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_NOTE;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_note_id                := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end CREATE_NOTE;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------------< <UPDATE_NOTE> >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_NOTE
   (p_validate                      in     boolean  default false
  ,p_note_id                        in     number
  ,p_offer_status_history_id        in     number
  ,p_note_text                      in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number          in  out nocopy   number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number number(9);
  l_proc                varchar2(72) := g_package||'UPDATE_NOTE';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_NOTE;
  --
  -- Truncate the time portion from all IN date parameters
  --
  --
  -- Call Before Process User Hook
  --
  begin
    IRC_NOTES_BK2.UPDATE_NOTE_b
      (p_note_id                       => p_note_id
      ,p_offer_status_history_id       => p_offer_status_history_id
      ,p_note_text                     => p_note_text
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_NOTE'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  irc_ino_upd.upd
    (
     p_note_id                       => p_note_id
     ,p_offer_status_history_id       => p_offer_status_history_id
     ,p_object_version_number         => l_object_version_number
     ,p_note_text                     => p_note_text
    );
  --
  -- Call After Process User Hook
  --
  begin
    IRC_NOTES_BK2.UPDATE_NOTE_a
      (p_note_id                       => p_note_id
      ,p_offer_status_history_id       => p_offer_status_history_id
      ,p_note_text                     => p_note_text
      ,p_object_version_number         => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_NOTE'
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
    rollback to UPDATE_NOTE;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to UPDATE_NOTE;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end UPDATE_NOTE;
--
--
-- ----------------------------------------------------------------------------
-- |---------------------------< <DELETE_NOTE> >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_NOTE
   (p_validate                      in     boolean  default false
  ,p_note_id                        in     number
  ,p_object_version_number          in     number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'DELETE_NOTE';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_NOTE;
  --
  -- Truncate the time portion from all IN date parameters
  --
  -- Call Before Process User Hook
  --
  begin
    IRC_NOTES_BK3.DELETE_NOTE_b
      (p_note_id                       => p_note_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_NOTE'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  irc_ino_del.del
    (
     p_note_id                        => p_note_id
     ,p_object_version_number         => p_object_version_number
    );
  --
  -- Call After Process User Hook
  --
  begin
    IRC_NOTES_BK3.DELETE_NOTE_a
      (p_note_id                       => p_note_id
      ,p_object_version_number         => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_NOTE'
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
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to DELETE_NOTE;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to DELETE_NOTE;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end DELETE_NOTE;
--
end IRC_NOTES_API;

/
