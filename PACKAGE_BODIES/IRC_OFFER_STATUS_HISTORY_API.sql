--------------------------------------------------------
--  DDL for Package Body IRC_OFFER_STATUS_HISTORY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_OFFER_STATUS_HISTORY_API" as
/* $Header: iriosapi.pkb 120.3.12000000.2 2007/06/22 13:37:33 gaukumar noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'IRC_OFFER_STATUS_HISTORY_API.';
--
-- ----------------------------------------------------------------------------
-- |---------------------< create_offer_status_history >----------------------|
-- ----------------------------------------------------------------------------
--
  procedure create_offer_status_history
  ( P_VALIDATE           IN  boolean  default false
   ,P_EFFECTIVE_DATE     IN  DATE     default null
   ,P_OFFER_ID           IN  NUMBER
   ,P_STATUS_CHANGE_DATE IN  DATE     default null
   ,P_OFFER_STATUS       IN  VARCHAR2
   ,P_CHANGE_REASON      IN  VARCHAR2 default null
   ,P_DECLINE_REASON     IN  VARCHAR2 default null
   ,P_NOTE_TEXT          IN  VARCHAR2 default null
   ,P_OFFER_STATUS_HISTORY_ID    OUT nocopy NUMBER
   ,P_OBJECT_VERSION_NUMBER      OUT nocopy NUMBER
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc              varchar2(72) := g_package||'create_offer_status_history';
  l_offer_status_history_id number;
  l_object_version_number   number       := 1;
  l_effective_date          date;
  l_status_change_date      date;
  l_note_id                 number;
  l_note_ovn                number;
  --
  begin
    hr_utility.set_location('Entering:'|| l_proc, 10);
    --
    -- Issue a savepoint
    --
    savepoint CREATE_OFFER_STATUS_HISTORY;
    --
    -- Truncate the time portion from all IN date parameters
    --
    l_effective_date      := trunc(p_effective_date);
    if (P_STATUS_CHANGE_DATE is null) then
    l_status_change_date := sysdate;
    else
    l_status_change_date  := p_status_change_date;
    end if;
    --adding a sec into the time the hold status is generated
    --so that the previous status is always a sec before it
    --we need this so that we can access d record before the hold
    --status on the basis of time
    if(P_OFFER_STATUS='HOLD') then
    l_status_change_date  := l_status_change_date+(1/(24*60*60));
    end if;

    --
    -- Call Before Process User Hook
    --
    begin
       IRC_OFFER_STATUS_HISTORY_BK1.create_offer_status_history_b
       ( P_EFFECTIVE_DATE               =>   l_effective_date
        ,P_OFFER_ID                     =>   P_OFFER_ID
	,P_STATUS_CHANGE_DATE           =>   l_status_change_date
        ,P_OFFER_STATUS                 =>   P_OFFER_STATUS
        ,P_CHANGE_REASON                =>   P_CHANGE_REASON
        ,P_DECLINE_REASON               =>   P_DECLINE_REASON
        ,P_NOTE_TEXT                    =>   P_NOTE_TEXT
       );
    exception
       when hr_api.cannot_find_prog_unit then
         hr_api.cannot_find_prog_unit_error
	    (p_module_name => 'CREATE_OFFER_STATUS_HISTORY'
	    ,p_hook_type   => 'BP'
	    );
    end;
  --
  -- Process Logic
  --
  irc_ios_ins.ins
  (
      p_effective_date           =>  l_effective_date
     ,p_offer_id                 =>  p_offer_id
     ,p_status_change_date       =>  l_status_change_date
     ,p_offer_status             =>  p_offer_status
     ,p_change_reason            =>  p_change_reason
     ,p_decline_reason           =>  p_decline_reason
     ,p_offer_status_history_id  =>  l_offer_status_history_id
     ,p_object_version_number    =>  l_object_version_number
  );
  --
  -- Create note record for the newly created offer status history record.
  --
  if (P_NOTE_TEXT is not null) then
  irc_notes_api.create_note
  (
      p_validate                  => p_validate
     ,p_offer_status_history_id   => l_offer_status_history_id
     ,p_note_text                 => p_note_text
     ,p_note_id                   => l_note_id
     ,p_object_version_number     => l_note_ovn
  );
  end if;
  --
  -- Call After Process User Hook
  --
  begin
  IRC_OFFER_STATUS_HISTORY_BK1.create_offer_status_history_a
    (  P_EFFECTIVE_DATE          => l_effective_date
      ,P_OFFER_ID                => P_OFFER_ID
      ,P_STATUS_CHANGE_DATE      => l_status_change_date
      ,P_OFFER_STATUS            => P_OFFER_STATUS
      ,P_CHANGE_REASON           => P_CHANGE_REASON
      ,P_DECLINE_REASON          => P_DECLINE_REASON
      ,P_NOTE_TEXT               => P_NOTE_TEXT
      ,P_OFFER_STATUS_HISTORY_ID => l_offer_status_history_id
      ,P_OBJECT_VERSION_NUMBER   => l_object_version_number
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_OFFER_STATUS_HISTORY'
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
  p_offer_status_history_id  := l_offer_status_history_id;
  p_object_version_number    := l_object_version_number;
  --
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_OFFER_STATUS_HISTORY;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_offer_status_history_id  := null;
    p_object_version_number    := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_OFFER_STATUS_HISTORY;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_offer_status_history_id  := null;
    p_object_version_number    := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end CREATE_OFFER_STATUS_HISTORY;
--
-- ----------------------------------------------------------------------------
-- |---------------------< update_offer_status_history >----------------------|
-- ----------------------------------------------------------------------------
--
  procedure update_offer_status_history
  ( P_VALIDATE                 IN   boolean   default false
   ,P_EFFECTIVE_DATE           IN   DATE      default null
   ,P_OFFER_STATUS_HISTORY_ID  IN   NUMBER
   ,P_OFFER_ID                 IN   NUMBER
   ,P_STATUS_CHANGE_DATE       IN   DATE
   ,P_OFFER_STATUS             IN   VARCHAR2
   ,P_CHANGE_REASON            IN   VARCHAR2  default null
   ,P_DECLINE_REASON           IN   VARCHAR2  default null
   ,P_NOTE_TEXT                IN   VARCHAR2  default null
   ,P_OBJECT_VERSION_NUMBER    IN OUT  nocopy    NUMBER
  ) is
  --
  -- Declare cursors and local variables
  --
  l_object_version_number number(9);
  l_proc                varchar2(72) := g_package||'UPDATE_OFFER_STATUS_HISTORY';
  --l_offer_status_history_id number;

  l_note_id irc_notes.note_id%type;
  l_note_ovn irc_notes.object_version_number%type;
  l_effective_date      date;
  l_status_change_date  date;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_OFFER_STATUS_HISTORY;
  --
  -- Truncate the time portion from all IN date parameters
  --
    l_effective_date      := trunc(p_effective_date);
    if (P_STATUS_CHANGE_DATE is null) then
    l_status_change_date := sysdate;
    else
    l_status_change_date  := p_status_change_date;
    end if;

    --adding a sec into the time the hold status is generated
    --so that the previous status is always a sec before it
    --we need this so that we can access d record before the hold
    --status on the basis of time
    if(P_OFFER_STATUS='HOLD') then
    l_status_change_date  := l_status_change_date+(1/(24*60*60));
    end if;

  --
  -- Call Before Process User Hook
  --
  begin
    IRC_OFFER_STATUS_HISTORY_BK2.update_offer_status_history_b
    (P_EFFECTIVE_DATE          =>   l_effective_date
    ,P_OFFER_STATUS_HISTORY_ID =>   P_OFFER_STATUS_HISTORY_ID
    ,P_STATUS_CHANGE_DATE      =>   l_status_change_date
    ,P_CHANGE_REASON           =>   P_CHANGE_REASON
    ,P_DECLINE_REASON          =>   P_DECLINE_REASON
    ,P_NOTE_TEXT               =>   P_NOTE_TEXT
    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name  => 'UPDATE_OFFER_STATUS_HISTORY'
	,p_hook_type    => 'BP'
	);
  end;
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  -- Create note record for the updated offer status history record.
  --
  if (P_NOTE_TEXT is not null) then
  irc_notes_api.create_note
  (
      p_validate                  => p_validate
     ,p_offer_status_history_id   => p_offer_status_history_id
     ,p_note_text                 => p_note_text
     ,p_note_id                   => l_note_id
     ,p_object_version_number     => l_note_ovn
  );
  end if;
  --
  -- Call After Process User Hook
  --
  begin
    IRC_OFFER_STATUS_HISTORY_BK2.update_offer_status_history_a
      (P_EFFECTIVE_DATE           => l_effective_date
      ,P_OFFER_STATUS_HISTORY_ID  => P_OFFER_STATUS_HISTORY_ID
      ,P_STATUS_CHANGE_DATE       => l_status_change_date
      ,P_CHANGE_REASON            => P_CHANGE_REASON
      ,P_DECLINE_REASON           => P_DECLINE_REASON
      ,P_NOTE_TEXT                => P_NOTE_TEXT
      ,P_OBJECT_VERSION_NUMBER    => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_OFFER_STATUS_HISTORY'
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
    rollback to UPDATE_OFFER_STATUS_HISTORY;
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
    rollback to UPDATE_OFFER_STATUS_HISTORY;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end UPDATE_OFFER_STATUS_HISTORY;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< delete_offer_status_history >---------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_offer_status_history
  ( P_VALIDATE                   IN   boolean   default false
   ,P_OFFER_ID                   IN   NUMBER
   ,P_EFFECTIVE_DATE             IN   DATE
  ) is
  --
  --
  -- Declare cursors and local variables
  --
  l_proc           varchar2(72) := g_package||'DELETE_OFFER_STATUS_HISTORY';

  cursor csr_history_records is
     select offer_status_history_id,
            object_version_number
     from   irc_offer_status_history
     where  offer_id = p_offer_id;

begin

  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_OFFER_STATUS_HISTORY;
  --
  --loop thru all the records
  --
  for c_rec in csr_history_records loop
  --
  -- Truncate the time portion from all IN date parameters
  --
  -- Call Before Process User Hook
  --
  begin
    IRC_OFFER_STATUS_HISTORY_BK3.delete_offer_status_history_b
      (  P_OBJECT_VERSION_NUMBER    => c_rec.object_version_number
        ,P_OFFER_STATUS_HISTORY_ID  => c_rec.offer_status_history_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_OFFER_STATUS_HISTORY'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  irc_ios_del.del
    (P_OFFER_STATUS_HISTORY_ID     => c_rec.offer_status_history_id
    ,P_OBJECT_VERSION_NUMBER       => c_rec.object_version_number
    );
  --
  -- Call After Process User Hook
  --
  begin
    IRC_OFFER_STATUS_HISTORY_BK3.delete_offer_status_history_a
      (  P_OBJECT_VERSION_NUMBER    => c_rec.object_version_number
        ,P_OFFER_STATUS_HISTORY_ID  => c_rec.offer_status_history_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_OFFER_STATUS_HISTORY'
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
  end loop;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to DELETE_OFFER_STATUS_HISTORY;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to DELETE_OFFER_STATUS_HISTORY;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end DELETE_OFFER_STATUS_HISTORY;
--
end IRC_OFFER_STATUS_HISTORY_API;

/
