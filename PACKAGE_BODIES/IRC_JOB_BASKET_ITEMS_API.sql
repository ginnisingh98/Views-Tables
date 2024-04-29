--------------------------------------------------------
--  DDL for Package Body IRC_JOB_BASKET_ITEMS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_JOB_BASKET_ITEMS_API" as
/* $Header: irjbiapi.pkb 120.0 2005/07/26 15:12:54 mbocutt noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'irc_job_basket_items_api.';
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_job_basket_item >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_job_basket_item
  (p_validate                      in     boolean  default false
  ,p_effective_date                in     date
  ,p_recruitment_activity_id       in     number
  ,p_person_id                     in     number
  ,p_job_basket_item_id            out nocopy number
  ,p_object_version_number         out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                  varchar2(72) := g_package||'create_job_basket_item';
  l_effective_date        date;
  l_object_version_number irc_job_basket_items.object_version_number%type;
  l_job_basket_item_id    number(15) default null;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_job_basket_item;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin
    irc_job_basket_items_bk1.create_job_basket_item_b
      (p_effective_date                => l_effective_date
      ,p_recruitment_activity_id       => p_recruitment_activity_id
      ,p_person_id                     => p_person_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_job_basket_item'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  irc_jbi_ins.ins
    (p_effective_date               => l_effective_date
    ,p_job_basket_item_id           => l_job_basket_item_id
    ,p_person_id                    => p_person_id
    ,p_recruitment_activity_id      => p_recruitment_activity_id
    ,p_object_version_number        => l_object_version_number );

  --
  -- Call After Process User Hook
  --
  begin
    irc_job_basket_items_bk1.create_job_basket_item_a
      (p_effective_date                => l_effective_date
      ,p_object_version_number         => l_object_version_number
      ,p_job_basket_item_id            => l_job_basket_item_id
      ,p_recruitment_activity_id       => p_recruitment_activity_id
      ,p_person_id                     => p_person_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_job_basket_item'
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
  p_job_basket_item_id     := l_job_basket_item_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_job_basket_item;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    p_job_basket_item_id     := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_job_basket_item;
    --
    -- Reset IN OUT parameters and set OUT parameters
    --
    p_object_version_number  := null;
    p_job_basket_item_id     := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_job_basket_item;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_job_basket_item >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_job_basket_item
  (p_validate                      in     boolean  default false
  ,p_object_version_number         in     number
  ,p_job_basket_item_id            in     number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                  varchar2(72) := g_package||'delete_job_basket_item';
  l_object_version_number irc_job_basket_items.object_version_number%type;
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_job_basket_item;
  l_object_version_number := p_object_version_number;
  --
  -- Call Before Process User Hook
  --
  begin
    irc_job_basket_items_bk2.delete_job_basket_item_b
      (p_object_version_number         => l_object_version_number
      ,p_job_basket_item_id            => p_job_basket_item_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_job_basket_item'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Process Logic
  --
  irc_jbi_del.del
    (p_job_basket_item_id           => p_job_basket_item_id
    ,p_object_version_number        => l_object_version_number);

  --
  -- Call After Process User Hook
  --
  begin
    irc_job_basket_items_bk2.delete_job_basket_item_a
      (p_object_version_number         => l_object_version_number
      ,p_job_basket_item_id            => p_job_basket_item_id
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_job_basket_item'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_job_basket_item;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_job_basket_item;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_job_basket_item;
--
end irc_job_basket_items_api;

/
