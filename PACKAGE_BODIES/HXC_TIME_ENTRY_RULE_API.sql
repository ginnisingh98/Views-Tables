--------------------------------------------------------
--  DDL for Package Body HXC_TIME_ENTRY_RULE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_TIME_ENTRY_RULE_API" as
/* $Header: hxcterapi.pkb 120.2 2005/09/23 09:07:21 nissharm noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hxc_time_entry_rule_api.';

g_debug boolean := hr_utility.debug_enabled;
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_time_entry_rule>----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_time_entry_rule
  (p_validate                      in     boolean   default false
  ,p_time_entry_rule_id            in out nocopy number
  ,p_object_version_number         in out nocopy number
  ,p_name                          in     varchar2
  ,p_business_group_id             in     number   default null
  ,p_legislation_code              in     varchar2 default null
  ,p_rule_usage                    in     varchar2
  ,p_start_date                    in     date
  ,p_mapping_id                    in     number   default null
  ,p_formula_id                    in     number   default null
  ,p_description                   in     varchar2 default null
  ,p_end_date                      in     date     default null
  ,p_effective_date		   in     date
  ,p_attribute_category            in     varchar2 default null
  ,p_attribute1                    in     varchar2 default null
  ,p_attribute2                    in     varchar2 default null
  ,p_attribute3                    in     varchar2 default null
  ,p_attribute4                    in     varchar2 default null
  ,p_attribute5                    in     varchar2 default null
  ,p_attribute6                    in     varchar2 default null
  ,p_attribute7                    in     varchar2 default null
  ,p_attribute8                    in     varchar2 default null
  ,p_attribute9                    in     varchar2 default null
  ,p_attribute10                   in     varchar2 default null
  ,p_attribute11                   in     varchar2 default null
  ,p_attribute12                   in     varchar2 default null
  ,p_attribute13                   in     varchar2 default null
  ,p_attribute14                   in     varchar2 default null
  ,p_attribute15                   in     varchar2 default null
  ,p_attribute16                   in     varchar2 default null
  ,p_attribute17                   in     varchar2 default null
  ,p_attribute18                   in     varchar2 default null
  ,p_attribute19                   in     varchar2 default null
  ,p_attribute20                   in     varchar2 default null
  ,p_attribute21                   in     varchar2 default null
  ,p_attribute22                   in     varchar2 default null
  ,p_attribute23                   in     varchar2 default null
  ,p_attribute24                   in     varchar2 default null
  ,p_attribute25                   in     varchar2 default null
  ,p_attribute26                   in     varchar2 default null
  ,p_attribute27                   in     varchar2 default null
  ,p_attribute28                   in     varchar2 default null
  ,p_attribute29                   in     varchar2 default null
  ,p_attribute30                   in     varchar2 default null
  ) is
  --
  -- Declare cursors and local variables
  --
	l_proc varchar2(72);
	l_object_version_number hxc_time_entry_rules.object_version_number%TYPE;
	l_time_entry_rule_id hxc_time_entry_rules.time_entry_rule_id%TYPE;
  --
begin

  g_debug := hr_utility.debug_enabled;
  --

  --
  if g_debug then
  	l_proc := g_package||' create_time_entry_rule';
  	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_time_entry_rule;
  --
  if g_debug then
  	hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Call Before Process User Hook
  --
  begin
    hxc_time_entry_rule_BK_1.create_time_entry_rule_b
      (p_time_entry_rule_id       => p_time_entry_rule_id
      ,p_object_version_number    => p_object_version_number
      ,p_name                     => p_name
      ,p_business_group_id        => p_business_group_id
      ,p_legislation_code         => p_legislation_code
      ,p_rule_usage               => p_rule_usage
      ,p_start_date               => p_start_date
      ,p_mapping_id               => p_mapping_id
      ,p_formula_id               => p_formula_id
      ,p_description              => p_description
      ,p_end_date                 => p_end_date
      ,p_effective_date           => p_effective_date
      ,p_attribute_category       => p_attribute_category
      ,p_attribute1               => p_attribute1
      ,p_attribute2               => p_attribute2
      ,p_attribute3               => p_attribute3
      ,p_attribute4               => p_attribute4
      ,p_attribute5               => p_attribute5
      ,p_attribute6               => p_attribute6
      ,p_attribute7               => p_attribute7
      ,p_attribute8               => p_attribute8
      ,p_attribute9               => p_attribute9
      ,p_attribute10              => p_attribute10
      ,p_attribute11              => p_attribute11
      ,p_attribute12              => p_attribute12
      ,p_attribute13              => p_attribute13
      ,p_attribute14              => p_attribute14
      ,p_attribute15              => p_attribute15
      ,p_attribute16              => p_attribute16
      ,p_attribute17              => p_attribute17
      ,p_attribute18              => p_attribute18
      ,p_attribute19              => p_attribute19
      ,p_attribute20              => p_attribute20
      ,p_attribute21              => p_attribute21
      ,p_attribute22              => p_attribute22
      ,p_attribute23              => p_attribute23
      ,p_attribute24              => p_attribute24
      ,p_attribute25              => p_attribute25
      ,p_attribute26              => p_attribute26
      ,p_attribute27              => p_attribute27
      ,p_attribute28              => p_attribute28
      ,p_attribute29              => p_attribute29
      ,p_attribute30              => p_attribute30  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_time_entry_rule'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  if g_debug then
  	hr_utility.set_location(l_proc, 30);
  end if;
  --
  -- Process Logic
  --
--
  if g_debug then
  	hr_utility.set_location(l_proc, 40);
  end if;
--
-- call row handler
--
hxc_ter_ins.ins (
       p_effective_date 	  => p_effective_date
      ,p_name 			  => p_name
      ,p_business_group_id        => p_business_group_id
      ,p_legislation_code         => p_legislation_code
      ,p_rule_usage 		  => p_rule_usage
      ,p_start_date 		  => p_start_date
      ,p_mapping_id        	  => p_mapping_id
      ,p_formula_id 		  => p_formula_id
      ,p_description 		  => p_description
      ,p_end_date  		  => p_end_date
      ,p_attribute_category       => p_attribute_category
      ,p_attribute1               => p_attribute1
      ,p_attribute2               => p_attribute2
      ,p_attribute3               => p_attribute3
      ,p_attribute4               => p_attribute4
      ,p_attribute5               => p_attribute5
      ,p_attribute6               => p_attribute6
      ,p_attribute7               => p_attribute7
      ,p_attribute8               => p_attribute8
      ,p_attribute9               => p_attribute9
      ,p_attribute10              => p_attribute10
      ,p_attribute11              => p_attribute11
      ,p_attribute12              => p_attribute12
      ,p_attribute13              => p_attribute13
      ,p_attribute14              => p_attribute14
      ,p_attribute15              => p_attribute15
      ,p_attribute16              => p_attribute16
      ,p_attribute17              => p_attribute17
      ,p_attribute18              => p_attribute18
      ,p_attribute19              => p_attribute19
      ,p_attribute20              => p_attribute20
      ,p_attribute21              => p_attribute21
      ,p_attribute22              => p_attribute22
      ,p_attribute23              => p_attribute23
      ,p_attribute24              => p_attribute24
      ,p_attribute25              => p_attribute25
      ,p_attribute26              => p_attribute26
      ,p_attribute27              => p_attribute27
      ,p_attribute28              => p_attribute28
      ,p_attribute29              => p_attribute29
      ,p_attribute30              => p_attribute30
      ,p_time_entry_rule_id       => l_time_entry_rule_id
      ,p_object_version_number    => l_object_version_number );
--
  if g_debug then
  	hr_utility.set_location(l_proc, 50);
  end if;
  --
  -- Call After Process User Hook
  --
  begin
    hxc_time_entry_rule_BK_1.create_time_entry_rule_a
      (p_time_entry_rule_id       => l_time_entry_rule_id
      ,p_object_version_number    => l_object_version_number
      ,p_name                     => p_name
      ,p_business_group_id        => p_business_group_id
      ,p_legislation_code         => p_legislation_code
      ,p_rule_usage               => p_rule_usage
      ,p_start_date               => p_start_date
      ,p_mapping_id               => p_mapping_id
      ,p_formula_id               => p_formula_id
      ,p_description              => p_description
      ,p_end_date                 => p_end_date
      ,p_effective_date           => p_effective_date
      ,p_attribute_category       => p_attribute_category
      ,p_attribute1               => p_attribute1
      ,p_attribute2               => p_attribute2
      ,p_attribute3               => p_attribute3
      ,p_attribute4               => p_attribute4
      ,p_attribute5               => p_attribute5
      ,p_attribute6               => p_attribute6
      ,p_attribute7               => p_attribute7
      ,p_attribute8               => p_attribute8
      ,p_attribute9               => p_attribute9
      ,p_attribute10              => p_attribute10
      ,p_attribute11              => p_attribute11
      ,p_attribute12              => p_attribute12
      ,p_attribute13              => p_attribute13
      ,p_attribute14              => p_attribute14
      ,p_attribute15              => p_attribute15
      ,p_attribute16              => p_attribute16
      ,p_attribute17              => p_attribute17
      ,p_attribute18              => p_attribute18
      ,p_attribute19              => p_attribute19
      ,p_attribute20              => p_attribute20
      ,p_attribute21              => p_attribute21
      ,p_attribute22              => p_attribute22
      ,p_attribute23              => p_attribute23
      ,p_attribute24              => p_attribute24
      ,p_attribute25              => p_attribute25
      ,p_attribute26              => p_attribute26
      ,p_attribute27              => p_attribute27
      ,p_attribute28              => p_attribute28
      ,p_attribute29              => p_attribute29
      ,p_attribute30              => p_attribute30
   );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_time_entry_rule'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  if g_debug then
  	hr_utility.set_location(l_proc, 60);
  end if;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 70);
  end if;
  --
  -- Set all output arguments
  --
  p_time_entry_rule_id := l_time_entry_rule_id;
  p_object_version_number := l_object_version_number;
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_time_entry_rule;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_time_entry_rule_id := null;
    p_object_version_number  := null;
    --
    if g_debug then
    	hr_utility.set_location(' Leaving:'||l_proc, 80);
    end if;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
if g_debug then
	hr_utility.trace('In exeception');
end if;
    ROLLBACK TO create_time_entry_rule;
    raise;
    --
END create_time_entry_rule;
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_time_entry_rule>----------------------|
-- ----------------------------------------------------------------------------
--
procedure update_time_entry_rule
  (p_validate                      in  boolean   default false
  ,p_time_entry_rule_id            in  number
  ,p_object_version_number         in  out nocopy number
  ,p_name                          in     varchar2
  ,p_business_group_id             in     number   default hr_api.g_number
  ,p_legislation_code              in     varchar2 default hr_api.g_varchar2
  ,p_rule_usage                    in     varchar2
  ,p_start_date                    in     date
  ,p_mapping_id                    in     number   default hr_api.g_number
  ,p_formula_id                    in     number   default hr_api.g_number
  ,p_description                   in     varchar2 default hr_api.g_varchar2
  ,p_end_date                      in     date     default hr_api.g_date
  ,p_effective_date		   in     date     default hr_api.g_date
  ,p_attribute_category            in     varchar2 default hr_api.g_varchar2
  ,p_attribute1                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute2                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute3                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute4                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute5                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute6                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute7                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute8                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute9                    in     varchar2 default hr_api.g_varchar2
  ,p_attribute10                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute11                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute12                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute13                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute14                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute15                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute16                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute17                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute18                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute19                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute20                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute21                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute22                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute23                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute24                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute25                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute26                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute27                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute28                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute29                   in     varchar2 default hr_api.g_varchar2
  ,p_attribute30                   in     varchar2 default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
	l_proc varchar2(72);
	l_object_version_number hxc_time_entry_rules.object_version_number%TYPE := p_object_version_number;
  --
begin

  g_debug := hr_utility.debug_enabled;
  --
  if g_debug then
  	l_proc := g_package||' update_time_entry_rule';
  	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;

  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_time_entry_rule;
  --
  if g_debug then
  	hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Call Before Process User Hook
  --
  begin
    hxc_time_entry_rule_BK_2.update_time_entry_rule_b
      (p_time_entry_rule_id       => p_time_entry_rule_id
      ,p_object_version_number    => p_object_version_number
      ,p_name                     => p_name
      ,p_business_group_id        => p_business_group_id
      ,p_legislation_code         => p_legislation_code
      ,p_rule_usage               => p_rule_usage
      ,p_start_date               => p_start_date
      ,p_mapping_id               => p_mapping_id
      ,p_formula_id               => p_formula_id
      ,p_description              => p_description
      ,p_end_date                 => p_end_date
      ,p_effective_date           => p_effective_date
      ,p_attribute_category       => p_attribute_category
      ,p_attribute1               => p_attribute1
      ,p_attribute2               => p_attribute2
      ,p_attribute3               => p_attribute3
      ,p_attribute4               => p_attribute4
      ,p_attribute5               => p_attribute5
      ,p_attribute6               => p_attribute6
      ,p_attribute7               => p_attribute7
      ,p_attribute8               => p_attribute8
      ,p_attribute9               => p_attribute9
      ,p_attribute10              => p_attribute10
      ,p_attribute11              => p_attribute11
      ,p_attribute12              => p_attribute12
      ,p_attribute13              => p_attribute13
      ,p_attribute14              => p_attribute14
      ,p_attribute15              => p_attribute15
      ,p_attribute16              => p_attribute16
      ,p_attribute17              => p_attribute17
      ,p_attribute18              => p_attribute18
      ,p_attribute19              => p_attribute19
      ,p_attribute20              => p_attribute20
      ,p_attribute21              => p_attribute21
      ,p_attribute22              => p_attribute22
      ,p_attribute23              => p_attribute23
      ,p_attribute24              => p_attribute24
      ,p_attribute25              => p_attribute25
      ,p_attribute26              => p_attribute26
      ,p_attribute27              => p_attribute27
      ,p_attribute28              => p_attribute28
      ,p_attribute29              => p_attribute29
      ,p_attribute30              => p_attribute30
   );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_time_entry_rule'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  if g_debug then
  	hr_utility.set_location(l_proc, 30);
  end if;
  --
  -- Process Logic
--
-- call row handler
--
hxc_ter_upd.upd (
       p_effective_date 	  => p_effective_date
      ,p_name 			  => p_name
      ,p_business_group_id        => p_business_group_id
      ,p_legislation_code         => p_legislation_code
      ,p_rule_usage 		  => p_rule_usage
      ,p_start_date 		  => p_start_date
      ,p_mapping_id 		  => p_mapping_id
      ,p_formula_id 		  => p_formula_id
      ,p_description 		  => p_description
      ,p_end_date  	          => p_end_date
      ,p_attribute_category       => p_attribute_category
      ,p_attribute1               => p_attribute1
      ,p_attribute2               => p_attribute2
      ,p_attribute3               => p_attribute3
      ,p_attribute4               => p_attribute4
      ,p_attribute5               => p_attribute5
      ,p_attribute6               => p_attribute6
      ,p_attribute7               => p_attribute7
      ,p_attribute8               => p_attribute8
      ,p_attribute9               => p_attribute9
      ,p_attribute10              => p_attribute10
      ,p_attribute11              => p_attribute11
      ,p_attribute12              => p_attribute12
      ,p_attribute13              => p_attribute13
      ,p_attribute14              => p_attribute14
      ,p_attribute15              => p_attribute15
      ,p_attribute16              => p_attribute16
      ,p_attribute17              => p_attribute17
      ,p_attribute18              => p_attribute18
      ,p_attribute19              => p_attribute19
      ,p_attribute20              => p_attribute20
      ,p_attribute21              => p_attribute21
      ,p_attribute22              => p_attribute22
      ,p_attribute23              => p_attribute23
      ,p_attribute24              => p_attribute24
      ,p_attribute25              => p_attribute25
      ,p_attribute26              => p_attribute26
      ,p_attribute27              => p_attribute27
      ,p_attribute28              => p_attribute28
      ,p_attribute29              => p_attribute29
      ,p_attribute30              => p_attribute30
      ,p_time_entry_rule_id => p_time_entry_rule_id
      ,p_object_version_number => l_object_version_number );
--
  --
  if g_debug then
  	hr_utility.set_location(l_proc, 40);
  end if;
  --
  -- Call After Process User Hook
  --
  begin
    hxc_time_entry_rule_BK_2.update_time_entry_rule_a
      (p_time_entry_rule_id       => p_time_entry_rule_id
      ,p_object_version_number    => l_object_version_number
      ,p_name                     => p_name
      ,p_business_group_id        => p_business_group_id
      ,p_legislation_code         => p_legislation_code
      ,p_rule_usage               => p_rule_usage
      ,p_start_date               => p_start_date
      ,p_mapping_id               => p_mapping_id
      ,p_formula_id               => p_formula_id
      ,p_description              => p_description
      ,p_end_date                 => p_end_date
      ,p_effective_date           => p_effective_date
      ,p_attribute_category       => p_attribute_category
      ,p_attribute1               => p_attribute1
      ,p_attribute2               => p_attribute2
      ,p_attribute3               => p_attribute3
      ,p_attribute4               => p_attribute4
      ,p_attribute5               => p_attribute5
      ,p_attribute6               => p_attribute6
      ,p_attribute7               => p_attribute7
      ,p_attribute8               => p_attribute8
      ,p_attribute9               => p_attribute9
      ,p_attribute10              => p_attribute10
      ,p_attribute11              => p_attribute11
      ,p_attribute12              => p_attribute12
      ,p_attribute13              => p_attribute13
      ,p_attribute14              => p_attribute14
      ,p_attribute15              => p_attribute15
      ,p_attribute16              => p_attribute16
      ,p_attribute17              => p_attribute17
      ,p_attribute18              => p_attribute18
      ,p_attribute19              => p_attribute19
      ,p_attribute20              => p_attribute20
      ,p_attribute21              => p_attribute21
      ,p_attribute22              => p_attribute22
      ,p_attribute23              => p_attribute23
      ,p_attribute24              => p_attribute24
      ,p_attribute25              => p_attribute25
      ,p_attribute26              => p_attribute26
      ,p_attribute27              => p_attribute27
      ,p_attribute28              => p_attribute28
      ,p_attribute29              => p_attribute29
      ,p_attribute30              => p_attribute30
   );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'update_time_entry_rule'
        ,p_hook_type   => 'AP'
        );
  end;
  --
  if g_debug then
  	hr_utility.set_location(l_proc, 50);
  end if;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 60);
  end if;
  --
  -- Set all output arguments
  --
  p_object_version_number := l_object_version_number;
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_time_entry_rule;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    --
    if g_debug then
    	hr_utility.set_location(' Leaving:'||l_proc, 60);
    end if;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
if g_debug then
	hr_utility.trace('In exeception');
end if;
    ROLLBACK TO update_time_entry_rule;
    raise;
    --
END update_time_entry_rule;
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_time_entry_rule >---------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_time_entry_rule
  (p_validate                       in  boolean  default false
  ,p_time_entry_rule_id          in  number
  ,p_object_version_number          in  number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72);
  --
begin

  g_debug := hr_utility.debug_enabled;
  --
  if g_debug then
  	l_proc := g_package||'delete_time_entry_rule';
  	hr_utility.set_location('Entering:'|| l_proc, 10);
  end if;
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_time_entry_rule;
  --
  if g_debug then
  	hr_utility.set_location(l_proc, 20);
  end if;
  --
  -- Call Before Process User Hook
  --
  begin
  --
	    hxc_time_entry_rule_BK_3.delete_time_entry_rule_b
	  (p_time_entry_rule_id => p_time_entry_rule_id
	  ,p_object_version_number => p_object_version_number
	  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_time_entry_rule_b'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  if g_debug then
  	hr_utility.set_location(l_proc, 30);
  end if;
  --
  -- Process Logic
  --
  hxc_ter_del.del
    (
     p_time_entry_rule_id => p_time_entry_rule_id
    ,p_object_version_number => p_object_version_number
    );
  --
  if g_debug then
  	hr_utility.set_location(l_proc, 40);
  end if;
  --
  -- Call After Process User Hook
  --
  begin
  --
	hxc_time_entry_rule_BK_3.delete_time_entry_rule_a
	  (p_time_entry_rule_id => p_time_entry_rule_id
	  ,p_object_version_number => p_object_version_number
	  );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'delete_time_entry_rule_a'
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
  if g_debug then
  	hr_utility.set_location(' Leaving:'||l_proc, 50);
  end if;
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_time_entry_rule;
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_time_entry_rule;
    raise;
    --
end delete_time_entry_rule;
--
END hxc_time_entry_rule_api;

/
