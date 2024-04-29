--------------------------------------------------------
--  DDL for Package Body HR_KI_TOPICS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_KI_TOPICS_API" as
/* $Header: hrtpcapi.pkb 115.0 2004/01/09 04:37:54 vkarandi noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'HR_KI_TOPICS_API';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< CREATE_TOPIC >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_topic
    (p_validate                      in     boolean  default false
    ,p_language_code                 in     varchar2 default hr_api.userenv_lang
    ,p_topic_key                     in     varchar2
    ,p_handler                       in     varchar2
    ,p_name                          in     varchar2
    ,p_topic_id                      out    nocopy   number
    ,p_object_version_number         out    nocopy   number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'create_topic';
  l_topic_id      number;
  l_language_code       varchar2(30);
  l_object_version_number number;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_topic;
  --
  -- Remember IN OUT parameter IN values
  --
  --l_in_out_parameter := p_in_out_parameter;
  l_language_code:=p_language_code;

  hr_api.validate_language_code(p_language_code => l_language_code);

  --
  -- Call Before Process User Hook
  --
  begin
    hr_ki_topics_bk1.create_topic_b
      ( p_language_code   => l_language_code
       ,p_topic_key       => p_topic_key
       ,p_handler         => p_handler
       ,p_name            => p_name
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_topic'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  hr_tpc_ins.ins
     (p_topic_key                => p_topic_key
      ,p_handler                 => p_handler
      ,p_topic_id                => l_topic_id
      ,p_object_version_number   => l_object_version_number
      );

  hr_ttl_ins.ins_tl(
       p_language_code           => l_language_code
      ,p_topic_id                => l_topic_id
      ,p_name                    => p_name
      );


  --
  -- Call After Process User Hook
  --
  begin
    hr_ki_topics_bk1.create_topic_a
      (
       p_language_code           =>    l_language_code
      ,p_topic_key               =>    p_topic_key
      ,p_handler                 =>    p_handler
      ,p_name                    =>    p_name
      ,p_topic_id                =>    l_topic_id
      ,p_object_version_number   =>    l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_topic'
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
  p_topic_id               := l_topic_id;
  p_object_version_number  := l_object_version_number;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_topic;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --

    p_topic_id               := null;
    p_object_version_number  := null;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_topic;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --

    p_topic_id               := null;
    p_object_version_number  := null;

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_topic;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< UPDATE_TOPIC >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_topic
  (p_validate                      in     boolean  default false
  ,p_language_code                 in     varchar2 default hr_api.userenv_lang
  ,p_handler                       in     varchar2 default hr_api.g_varchar2
  ,p_name                          in     varchar2 default hr_api.g_varchar2
  ,p_topic_id                      in     number
  ,p_object_version_number         in out nocopy   number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'update_topic';
  l_language_code       varchar2(30);
  l_object_version_number number := p_object_version_number;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_topic;
  --
  -- Remember IN OUT parameter IN values
  --
  --l_in_out_parameter := p_in_out_parameter;
  l_language_code:=p_language_code;

  hr_api.validate_language_code(p_language_code => l_language_code);

  --
  -- Call Before Process User Hook
  --
  begin
    hr_ki_topics_bk2.update_topic_b
      ( p_language_code          => l_language_code
       ,p_handler                => p_handler
       ,p_name                   => p_name
       ,p_topic_id               => p_topic_id
       ,p_object_version_number  => p_object_version_number

      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_topic'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  hr_tpc_upd.upd
     (
      p_topic_id                => p_topic_id
     ,p_handler                 => p_handler
     ,p_object_version_number   => p_object_version_number
      );

  hr_ttl_upd.upd_tl(
      p_language_code    => l_language_code
      ,p_topic_id        => p_topic_id
      ,p_name            => p_name
      );


  --
  -- Call After Process User Hook
  --
  begin
    hr_ki_topics_bk2.update_topic_a
      (
       p_language_code           =>    l_language_code
      ,p_handler                 =>    p_handler
      ,p_name                    =>    p_name
      ,p_topic_id                =>    p_topic_id
      ,p_object_version_number   =>    p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_topic'
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
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_topic;
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
    rollback to update_topic;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --

    p_object_version_number  := l_object_version_number;

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_topic;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------------< DELETE_TOPIC >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_topic
  (
   p_validate                 in boolean	 default false
  ,P_topic_id                 in number
  ,p_object_version_number    in number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'delete_topic';

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_topic;
  --
  -- Remember IN OUT parameter IN values
  --

  -- Call Before Process User Hook
  --
  begin
    hr_ki_topics_bk3.delete_topic_b
      (
       p_topic_id          => p_topic_id
      ,p_object_version_number  => p_object_version_number

      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_topic'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  hr_tpc_shd.lck
     (
      p_topic_id                => p_topic_id
     ,p_object_version_number   => p_object_version_number
     );
  hr_ttl_del.del_tl(
      p_topic_id          => p_topic_id
      );
  hr_tpc_del.del
     (
      p_topic_id          => p_topic_id
     ,p_object_version_number   => p_object_version_number
      );


  --
  -- Call After Process User Hook
  --
  begin
    hr_ki_topics_bk3.delete_topic_a
      (
       p_topic_id          =>    p_topic_id
      ,p_object_version_number   =>    p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_topic'
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

  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_topic;
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
    rollback to delete_topic;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_topic;
end HR_KI_TOPICS_API;

/
