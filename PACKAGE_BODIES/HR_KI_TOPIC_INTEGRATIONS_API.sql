--------------------------------------------------------
--  DDL for Package Body HR_KI_TOPIC_INTEGRATIONS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_KI_TOPIC_INTEGRATIONS_API" as
/* $Header: hrtisapi.pkb 120.1 2008/01/25 13:51:29 avarri ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'HR_KI_TOPIC_INTEGRATIONS_API';

--
-- ----------------------------------------------------------------------------
-- |----------------------< create_topic_integration >------------------------|
-- ----------------------------------------------------------------------------
--
procedure create_topic_integration
  (
   p_validate                      in     boolean  default false
  ,p_topic_id                      in     number
  ,p_integration_id                in     number
  ,p_param_name1                   in     varchar2 default null
  ,p_param_value1                  in     varchar2 default null
  ,p_param_name2                   in     varchar2 default null
  ,p_param_value2                  in     varchar2 default null
  ,p_param_name3                   in     varchar2 default null
  ,p_param_value3                  in     varchar2 default null
  ,p_param_name4                   in     varchar2 default null
  ,p_param_value4                  in     varchar2 default null
  ,p_param_name5                   in     varchar2 default null
  ,p_param_value5                  in     varchar2 default null
  ,p_param_name6                   in     varchar2 default null
  ,p_param_value6                  in     varchar2 default null
  ,p_param_name7                   in     varchar2 default null
  ,p_param_value7                  in     varchar2 default null
  ,p_param_name8                   in     varchar2 default null
  ,p_param_value8                  in     varchar2 default null
  ,p_param_name9                   in     varchar2 default null
  ,p_param_value9                  in     varchar2 default null
  ,p_param_name10                  in     varchar2 default null
  ,p_param_value10                 in     varchar2 default null
  ,p_topic_integrations_id         out    nocopy   number
  ,p_object_version_number         out    nocopy   number
  )  is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'create_topic_integration';
  l_topic_integrations_id number;
  l_object_version_number number;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_topic_integration;
  --
  -- Remember IN OUT parameter IN values
  --
  --l_in_out_parameter := p_in_out_parameter;

  -- Call Before Process User Hook
  --
  begin
    hr_ki_topic_integrations_bk1.create_topic_integration_b
      (
       p_topic_id                      => p_topic_id
      ,p_integration_id                => p_integration_id
      ,p_param_name1                   => p_param_name1
      ,p_param_value1                  => p_param_value1
      ,p_param_name2                   => p_param_name2
      ,p_param_value2                  => p_param_value2
      ,p_param_name3                   => p_param_name3
      ,p_param_value3                  => p_param_value3
      ,p_param_name4                   => p_param_name4
      ,p_param_value4                  => p_param_value4
      ,p_param_name5                   => p_param_name5
      ,p_param_value5                  => p_param_value5
      ,p_param_name6                   => p_param_name6
      ,p_param_value6                  => p_param_value6
      ,p_param_name7                   => p_param_name7
      ,p_param_value7                  => p_param_value7
      ,p_param_name8                   => p_param_name8
      ,p_param_value8                  => p_param_value8
      ,p_param_name9                   => p_param_name9
      ,p_param_value9                  => p_param_value9
      ,p_param_name10                  => p_param_name10
      ,p_param_value10                 => p_param_value10
      );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_topic_integration'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  hr_tis_ins.ins
     (
       p_topic_id                      => p_topic_id
      ,p_integration_id                => p_integration_id
      ,p_param_name1                   => p_param_name1
      ,p_param_value1                  => p_param_value1
      ,p_param_name2                   => p_param_name2
      ,p_param_value2                  => p_param_value2
      ,p_param_name3                   => p_param_name3
      ,p_param_value3                  => p_param_value3
      ,p_param_name4                   => p_param_name4
      ,p_param_value4                  => p_param_value4
      ,p_param_name5                   => p_param_name5
      ,p_param_value5                  => p_param_value5
      ,p_param_name6                   => p_param_name6
      ,p_param_value6                  => p_param_value6
      ,p_param_name7                   => p_param_name7
      ,p_param_value7                  => p_param_value7
      ,p_param_name8                   => p_param_name8
      ,p_param_value8                  => p_param_value8
      ,p_param_name9                   => p_param_name9
      ,p_param_value9                  => p_param_value9
      ,p_param_name10                  => p_param_name10
      ,p_param_value10                 => p_param_value10
      ,p_topic_integrations_id         => l_topic_integrations_id
      ,p_object_version_number         => l_object_version_number
     );

  --
  -- Call After Process User Hook
  --
  begin
    hr_ki_topic_integrations_bk1.create_topic_integration_a
      (
       p_topic_id                      => p_topic_id
      ,p_integration_id                => p_integration_id
      ,p_param_name1                   => p_param_name1
      ,p_param_value1                  => p_param_value1
      ,p_param_name2                   => p_param_name2
      ,p_param_value2                  => p_param_value2
      ,p_param_name3                   => p_param_name3
      ,p_param_value3                  => p_param_value3
      ,p_param_name4                   => p_param_name4
      ,p_param_value4                  => p_param_value4
      ,p_param_name5                   => p_param_name5
      ,p_param_value5                  => p_param_value5
      ,p_param_name6                   => p_param_name6
      ,p_param_value6                  => p_param_value6
      ,p_param_name7                   => p_param_name7
      ,p_param_value7                  => p_param_value7
      ,p_param_name8                   => p_param_name8
      ,p_param_value8                  => p_param_value8
      ,p_param_name9                   => p_param_name9
      ,p_param_value9                  => p_param_value9
      ,p_param_name10                  => p_param_name10
      ,p_param_value10                 => p_param_value10
      ,p_topic_integrations_id         => l_topic_integrations_id
      ,p_object_version_number         => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_topic_integration'
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
  p_topic_integrations_id  := l_topic_integrations_id;
  p_object_version_number  := l_object_version_number;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_topic_integration;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --

    p_topic_integrations_id  := null;
    p_object_version_number  := null;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_topic_integration;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --

    p_topic_integrations_id  := null;
    p_object_version_number  := null;

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_topic_integration;

--
-- ----------------------------------------------------------------------------
-- |----------------------< create_topic_integration_key >--------------------|
-- ----------------------------------------------------------------------------
--
procedure create_topic_integration_key
  (
   p_validate                      in     boolean  default false
  ,p_topic_key                     in     varchar2
  ,p_integration_key               in     varchar2
  ,p_param_name1                   in     varchar2 default null
  ,p_param_value1                  in     varchar2 default null
  ,p_param_name2                   in     varchar2 default null
  ,p_param_value2                  in     varchar2 default null
  ,p_param_name3                   in     varchar2 default null
  ,p_param_value3                  in     varchar2 default null
  ,p_param_name4                   in     varchar2 default null
  ,p_param_value4                  in     varchar2 default null
  ,p_param_name5                   in     varchar2 default null
  ,p_param_value5                  in     varchar2 default null
  ,p_param_name6                   in     varchar2 default null
  ,p_param_value6                  in     varchar2 default null
  ,p_param_name7                   in     varchar2 default null
  ,p_param_value7                  in     varchar2 default null
  ,p_param_name8                   in     varchar2 default null
  ,p_param_value8                  in     varchar2 default null
  ,p_param_name9                   in     varchar2 default null
  ,p_param_value9                  in     varchar2 default null
  ,p_param_name10                  in     varchar2 default null
  ,p_param_value10                 in     varchar2 default null
  ,p_topic_integrations_id         out    nocopy   number
  ,p_object_version_number         out    nocopy   number
  )  is
  --
  -- Declare cursors and local variables
  --
  CURSOR csr_topic_key is
  select topic_id
   from  hr_ki_topics
   where topic_key = p_topic_key;

  CURSOR csr_integration_key is
  select integration_id
    from hr_ki_integrations
   where integration_key = p_integration_key;

  l_proc                  varchar2(72) := g_package||'create_topic_integration_key';
  l_topic_integrations_id number;
  l_object_version_number number;
  l_topic_id number;
  l_integration_id number;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint create_topic_integration_key;

  open csr_topic_key;
  fetch csr_topic_key into l_topic_id;
  close csr_topic_key;

  open csr_integration_key;
  fetch csr_integration_key into l_integration_id;
  close csr_integration_key;

  create_topic_integration
  (
   p_validate                   => p_validate
  ,p_topic_id                   => l_topic_id
  ,p_integration_id             => l_integration_id
  ,p_param_name1                => p_param_name1
  ,p_param_value1               => p_param_value1
  ,p_param_name2                => p_param_name2
  ,p_param_value2               => p_param_value2
  ,p_param_name3                => p_param_name3
  ,p_param_value3               => p_param_value3
  ,p_param_name4                => p_param_name4
  ,p_param_value4               => p_param_value4
  ,p_param_name5                => p_param_name5
  ,p_param_value5               => p_param_value5
  ,p_param_name6                => p_param_name6
  ,p_param_value6               => p_param_value6
  ,p_param_name7                => p_param_name7
  ,p_param_value7               => p_param_value7
  ,p_param_name8                => p_param_name8
  ,p_param_value8               => p_param_value8
  ,p_param_name9                => p_param_name9
  ,p_param_value9               => p_param_value9
  ,p_param_name10               => p_param_name10
  ,p_param_value10              => p_param_value10
  ,p_topic_integrations_id      => p_topic_integrations_id
  ,p_object_version_number      => p_object_version_number
  );

  -- select the id values corresponding to the keys

  --
  -- Remember IN OUT parameter IN values
  --
  --l_in_out_parameter := p_in_out_parameter;


  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_topic_integration_key;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --

    p_topic_integrations_id  := null;
    p_object_version_number  := null;

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end create_topic_integration_key;

--
--
-- ----------------------------------------------------------------------------
-- |--------------------< update_topic_integration >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure update_topic_integration
  (
   p_validate                      in     boolean  default false
  ,p_topic_integrations_id         in     number
  ,p_topic_id                      in     number   default hr_api.g_number
  ,p_integration_id                in     number   default hr_api.g_number
  ,p_param_name1                   in     varchar2 default hr_api.g_varchar2
  ,p_param_value1                  in     varchar2 default hr_api.g_varchar2
  ,p_param_name2                   in     varchar2 default hr_api.g_varchar2
  ,p_param_value2                  in     varchar2 default hr_api.g_varchar2
  ,p_param_name3                   in     varchar2 default hr_api.g_varchar2
  ,p_param_value3                  in     varchar2 default hr_api.g_varchar2
  ,p_param_name4                   in     varchar2 default hr_api.g_varchar2
  ,p_param_value4                  in     varchar2 default hr_api.g_varchar2
  ,p_param_name5                   in     varchar2 default hr_api.g_varchar2
  ,p_param_value5                  in     varchar2 default hr_api.g_varchar2
  ,p_param_name6                   in     varchar2 default hr_api.g_varchar2
  ,p_param_value6                  in     varchar2 default hr_api.g_varchar2
  ,p_param_name7                   in     varchar2 default hr_api.g_varchar2
  ,p_param_value7                  in     varchar2 default hr_api.g_varchar2
  ,p_param_name8                   in     varchar2 default hr_api.g_varchar2
  ,p_param_value8                  in     varchar2 default hr_api.g_varchar2
  ,p_param_name9                   in     varchar2 default hr_api.g_varchar2
  ,p_param_value9                  in     varchar2 default hr_api.g_varchar2
  ,p_param_name10                  in     varchar2 default hr_api.g_varchar2
  ,p_param_value10                 in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy   number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  varchar2(72) := g_package||'update_topic_integration';
  l_object_version_number number := p_object_version_number;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_topic_integration;
  --
  -- Remember IN OUT parameter IN values
  --
  --l_in_out_parameter := p_in_out_parameter;

  --
  -- Call Before Process User Hook
  --
  begin
    hr_ki_topic_integrations_bk2.update_topic_integration_b
      (
       p_topic_id                   => p_topic_id
      ,p_integration_id             => p_integration_id
      ,p_param_name1                => p_param_name1
      ,p_param_value1               => p_param_value1
      ,p_param_name2                => p_param_name2
      ,p_param_value2               => p_param_value2
      ,p_param_name3                => p_param_name3
      ,p_param_value3               => p_param_value3
      ,p_param_name4                => p_param_name4
      ,p_param_value4               => p_param_value4
      ,p_param_name5                => p_param_name5
      ,p_param_value5               => p_param_value5
      ,p_param_name6                => p_param_name6
      ,p_param_value6               => p_param_value6
      ,p_param_name7                => p_param_name7
      ,p_param_value7               => p_param_value7
      ,p_param_name8                => p_param_name8
      ,p_param_value8               => p_param_value8
      ,p_param_name9                => p_param_name9
      ,p_param_value9               => p_param_value9
      ,p_param_name10               => p_param_name10
      ,p_param_value10              => p_param_value10
      ,p_topic_integrations_id      => p_topic_integrations_id
      ,p_object_version_number      => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_topic_integration'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --
  hr_tis_upd.upd
     (
     p_topic_integrations_id      => p_topic_integrations_id
    ,p_topic_id                   => p_topic_id
    ,p_integration_id             => p_integration_id
    ,p_param_name1                => p_param_name1
    ,p_param_value1               => p_param_value1
    ,p_param_name2                => p_param_name2
    ,p_param_value2               => p_param_value2
    ,p_param_name3                => p_param_name3
    ,p_param_value3               => p_param_value3
    ,p_param_name4                => p_param_name4
    ,p_param_value4               => p_param_value4
    ,p_param_name5                => p_param_name5
    ,p_param_value5               => p_param_value5
    ,p_param_name6                => p_param_name6
    ,p_param_value6               => p_param_value6
    ,p_param_name7                => p_param_name7
    ,p_param_value7               => p_param_value7
    ,p_param_name8                => p_param_name8
    ,p_param_value8               => p_param_value8
    ,p_param_name9                => p_param_name9
    ,p_param_value9               => p_param_value9
    ,p_param_name10               => p_param_name10
    ,p_param_value10              => p_param_value10
    ,p_object_version_number      => p_object_version_number
    );

  --
  -- Call After Process User Hook
  --
  begin
    hr_ki_topic_integrations_bk2.update_topic_integration_a
      (
       p_topic_id                   => p_topic_id
      ,p_integration_id             => p_integration_id
      ,p_param_name1                => p_param_name1
      ,p_param_value1               => p_param_value1
      ,p_param_name2                => p_param_name2
      ,p_param_value2               => p_param_value2
      ,p_param_name3                => p_param_name3
      ,p_param_value3               => p_param_value3
      ,p_param_name4                => p_param_name4
      ,p_param_value4               => p_param_value4
      ,p_param_name5                => p_param_name5
      ,p_param_value5               => p_param_value5
      ,p_param_name6                => p_param_name6
      ,p_param_value6               => p_param_value6
      ,p_param_name7                => p_param_name7
      ,p_param_value7               => p_param_value7
      ,p_param_name8                => p_param_name8
      ,p_param_value8               => p_param_value8
      ,p_param_name9                => p_param_name9
      ,p_param_value9               => p_param_value9
      ,p_param_name10               => p_param_name10
      ,p_param_value10              => p_param_value10
      ,p_topic_integrations_id      => p_topic_integrations_id
      ,p_object_version_number      => p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_topic_integration'
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

  -- p_object_version_number  := p_object_version_number;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_topic_integration;
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
    rollback to update_topic_integration;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --

    p_object_version_number  := l_object_version_number;

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_topic_integration;

-- ----------------------------------------------------------------------------
-- |--------------------< update_topic_integration_key >----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_topic_integration_key
  (
   p_validate                      in     boolean  default false
  ,p_topic_integrations_id         in     number
  ,p_topic_key                     in     varchar2 default hr_api.g_varchar2
  ,p_integration_key               in     varchar2 default hr_api.g_varchar2
  ,p_param_name1                   in     varchar2 default hr_api.g_varchar2
  ,p_param_value1                  in     varchar2 default hr_api.g_varchar2
  ,p_param_name2                   in     varchar2 default hr_api.g_varchar2
  ,p_param_value2                  in     varchar2 default hr_api.g_varchar2
  ,p_param_name3                   in     varchar2 default hr_api.g_varchar2
  ,p_param_value3                  in     varchar2 default hr_api.g_varchar2
  ,p_param_name4                   in     varchar2 default hr_api.g_varchar2
  ,p_param_value4                  in     varchar2 default hr_api.g_varchar2
  ,p_param_name5                   in     varchar2 default hr_api.g_varchar2
  ,p_param_value5                  in     varchar2 default hr_api.g_varchar2
  ,p_param_name6                   in     varchar2 default hr_api.g_varchar2
  ,p_param_value6                  in     varchar2 default hr_api.g_varchar2
  ,p_param_name7                   in     varchar2 default hr_api.g_varchar2
  ,p_param_value7                  in     varchar2 default hr_api.g_varchar2
  ,p_param_name8                   in     varchar2 default hr_api.g_varchar2
  ,p_param_value8                  in     varchar2 default hr_api.g_varchar2
  ,p_param_name9                   in     varchar2 default hr_api.g_varchar2
  ,p_param_value9                  in     varchar2 default hr_api.g_varchar2
  ,p_param_name10                  in     varchar2 default hr_api.g_varchar2
  ,p_param_value10                 in     varchar2 default hr_api.g_varchar2
  ,p_object_version_number         in out nocopy   number
  ) is
    --
  -- Declare cursors and local variables
  --
  CURSOR csr_topic_key is
  select
   topic_id
  from
   hr_ki_topics
  where topic_key = p_topic_key;

  CURSOR csr_integration_key is
  select
   integration_id
  from
   hr_ki_integrations
  where integration_key = p_integration_key;

  l_proc                  varchar2(72) := g_package||'update_topic_integration_key';
  l_topic_integrations_id number;
  l_object_version_number number := p_object_version_number;
  l_topic_id number;
  l_integration_id number;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_topic_integration_key;

  open csr_topic_key;
  fetch csr_topic_key into l_topic_id;
  close csr_topic_key;

  open csr_integration_key;
  fetch csr_integration_key into l_integration_id;
  close csr_integration_key;

  update_topic_integration
  (
   p_validate              => p_validate
  ,p_topic_integrations_id => p_topic_integrations_id
  ,p_topic_id              => l_topic_id
  ,p_integration_id        => l_integration_id
  ,p_param_name1           => p_param_name1
  ,p_param_value1          => p_param_value1
  ,p_param_name2           => p_param_name2
  ,p_param_value2          => p_param_value2
  ,p_param_name3           => p_param_name3
  ,p_param_value3          => p_param_value3
  ,p_param_name4           => p_param_name4
  ,p_param_value4          => p_param_value4
  ,p_param_name5           => p_param_name5
  ,p_param_value5          => p_param_value5
  ,p_param_name6           => p_param_name6
  ,p_param_value6          => p_param_value6
  ,p_param_name7           => p_param_name7
  ,p_param_value7          => p_param_value7
  ,p_param_name8           => p_param_name8
  ,p_param_value8          => p_param_value8
  ,p_param_name9           => p_param_name9
  ,p_param_value9          => p_param_value9
  ,p_param_name10          => p_param_name10
  ,p_param_value10         => p_param_value10
  ,p_object_version_number => p_object_version_number
  );

  -- select the id values corresponding to the keys

  --
  -- Remember IN OUT parameter IN values
  --
  --l_in_out_parameter := p_in_out_parameter;


  hr_utility.set_location(' Leaving:'||l_proc, 20);
exception
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_topic_integration_key;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    p_object_version_number  := l_object_version_number;

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end update_topic_integration_key;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------< delete_topic_integration >------------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_topic_integration
  (
   P_VALIDATE                 in boolean         default false
  ,P_TOPIC_INTEGRATIONS_ID    in number
  ,P_OBJECT_VERSION_NUMBER    in number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'delete_topic_integration';

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_topic_integration;
  --
  -- Remember IN OUT parameter IN values
  --

  -- Call Before Process User Hook
  --
  begin
    hr_ki_topic_integrations_bk3.delete_topic_integration_b
      (
       p_topic_integrations_id   => p_topic_integrations_id
       ,p_object_version_number  => p_object_version_number

      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_topic_integration'
        ,p_hook_type   => 'BP'
        );
  end;

  --
  -- Process Logic
  --

  hr_tis_del.del
     (
      p_topic_integrations_id   => p_topic_integrations_id
     ,p_object_version_number   => p_object_version_number
      );


  --
  -- Call After Process User Hook
  --
  begin
    hr_ki_topic_integrations_bk3.delete_topic_integration_a
      (
       p_topic_integrations_id   =>    p_topic_integrations_id
      ,p_object_version_number   =>    p_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_topic_integration'
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
    rollback to delete_topic_integration;
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
    rollback to delete_topic_integration;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end delete_topic_integration;
end HR_KI_TOPIC_INTEGRATIONS_API;

/
