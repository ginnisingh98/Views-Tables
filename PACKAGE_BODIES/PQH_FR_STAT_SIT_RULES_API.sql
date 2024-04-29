--------------------------------------------------------
--  DDL for Package Body PQH_FR_STAT_SIT_RULES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_FR_STAT_SIT_RULES_API" as
/* $Header: pqstrapi.pkb 115.2 2003/10/16 11:47:43 svorugan noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pqh_fr_stat_sit_rules_api.';

g_debug boolean := hr_utility.debug_enabled;

--
-- ----------------------------------------------------------------------------
-- |--------------------------<CREATE_STAT_SITUATION_RULE >--------------------|
-- ----------------------------------------------------------------------------
--
procedure create_stat_situation_rule
  (p_validate                      in     boolean  default false
  ,p_effective_date                 in     date    default sysdate
  ,p_statutory_situation_id         in     number
  ,p_processing_sequence            in     number
  ,p_txn_category_attribute_id      in     number
  ,p_from_value                     in     varchar2
  ,p_to_value                       in     varchar2 default null
  ,p_enabled_flag                   in     varchar2 default null
  ,p_required_flag                  in     varchar2 default null
  ,p_exclude_flag                   in     varchar2 default null
  ,p_stat_situation_rule_id            out nocopy number
  ,p_object_version_number             out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_in_out_parameter    number;
  l_effective_date      date;
  l_proc                varchar2(72) := g_package||'create_stat_situation_rule';
  l_object_version_number number(9);
  l_stat_situation_rule_id pqh_fr_stat_situation_rules.stat_situation_rule_id%type;

begin

  if g_debug then
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  End if;

  --
  -- Issue a savepoint
  --
  savepoint CREATE_STAT_SITUATION_RULE;
  --
  -- Remember IN OUT parameter IN values
  --
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin
       pqh_fr_stat_sit_rules_bk1.create_stat_situation_rule_b
        (
          p_effective_date              =>     l_effective_date
         ,p_statutory_situation_id      =>     p_statutory_situation_id
         ,p_processing_sequence         =>     p_processing_sequence
         ,p_txn_category_attribute_id   =>     p_txn_category_attribute_id
         ,p_from_value                  =>     p_from_value
         ,p_to_value                    =>     p_to_value
         ,p_enabled_flag                =>     p_enabled_flag
         ,p_required_flag               =>     p_required_flag
         ,p_exclude_flag                =>     p_exclude_flag
       );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_STAT_SITUATION_RULE'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --



  --
  -- Process Logic
  --
          pqh_str_ins.ins
          		(p_effective_date            => p_effective_date
  			,p_statutory_situation_id    =>	p_statutory_situation_id
  			,p_processing_sequence       => p_processing_sequence
  			,p_txn_category_attribute_id => p_txn_category_attribute_id
  			,p_from_value                => p_from_value
  			,p_to_value                  => p_to_value
  			,p_enabled_flag              => p_enabled_flag
  			,p_required_flag             => p_required_flag
  			,p_exclude_flag              => p_exclude_flag
  			,p_stat_situation_rule_id    => l_stat_situation_rule_id
          		,p_object_version_number     => l_object_version_number
          		);



  --
  -- Call After Process User Hook
  --
  begin
     pqh_fr_stat_sit_rules_bk1.create_stat_situation_rule_a
       (   p_effective_date                =>    l_effective_date
 	  ,p_statutory_situation_id        =>    p_statutory_situation_id
	  ,p_processing_sequence           =>    p_processing_sequence
	  ,p_txn_category_attribute_id     =>    p_txn_category_attribute_id
	  ,p_from_value                    =>    p_from_value
	  ,p_to_value                      =>    p_to_value
	  ,p_enabled_flag                  =>    p_enabled_flag
	  ,p_required_flag                 =>    p_required_flag
	  ,p_exclude_flag                  =>    p_exclude_flag
	  ,p_stat_situation_rule_id        =>    l_stat_situation_rule_id
	  ,p_object_version_number         =>    l_object_version_number

         );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_STAT_SITUATION_RULE'
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
  p_stat_situation_rule_id := l_stat_situation_rule_id;
  p_object_version_number  := l_object_version_number;
    --
  if g_debug then
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
  End if;

exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_STAT_SITUATION_RULE;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
  p_stat_situation_rule_id := null;
  p_object_version_number  := null;

  if g_debug then
  --
  hr_utility.set_location(' Leaving:'||l_proc, 80);
  --
  End if;

  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_STAT_SITUATION_RULE;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
  p_stat_situation_rule_id := null;
  p_object_version_number  := null;

    raise;

end CREATE_STAT_SITUATION_RULE;
--

-- ----------------------------------------------------------------------------
-- |--------------------------<UPDATE_STAT_SITUATION_RULE >--------------------|
-- ----------------------------------------------------------------------------
--
procedure update_stat_situation_rule
  (p_validate                      in     boolean  default false
  ,p_effective_date               in     date      default sysdate
  ,p_stat_situation_rule_id       in     number
  ,p_object_version_number        in out nocopy number
  ,p_statutory_situation_id       in     number    default hr_api.g_number
  ,p_processing_sequence          in     number    default hr_api.g_number
  ,p_txn_category_attribute_id    in     number    default hr_api.g_number
  ,p_from_value                   in     varchar2  default hr_api.g_varchar2
  ,p_to_value                     in     varchar2  default hr_api.g_varchar2
  ,p_enabled_flag                 in     varchar2  default hr_api.g_varchar2
  ,p_required_flag                in     varchar2  default hr_api.g_varchar2
  ,p_exclude_flag                 in     varchar2  default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_in_out_parameter    number;
  l_effective_date      date;
  l_proc                varchar2(72) := g_package||'update_stat_situation_rule';
  l_object_version_number number(9);
  l_stat_situation_rule_id pqh_fr_stat_situation_rules.stat_situation_rule_id%type;

begin

 if g_debug then
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  End if;

  --
  -- Issue a savepoint
  --
  savepoint UPDATE_STAT_SITUATION_RULE;
  --
  -- Remember IN OUT parameter IN values
  --
  --l_in_out_parameter := p_in_out_parameter;

  l_object_version_number := p_object_version_number;
  l_stat_situation_rule_id := p_stat_situation_rule_id;

  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);

  --
  -- Call Before Process User Hook
  --
  begin
       pqh_fr_stat_sit_rules_bk2.update_stat_situation_rule_b
      (    p_effective_date              =>      l_effective_date
	  ,p_statutory_situation_id      =>      p_statutory_situation_id
	  ,p_processing_sequence         =>      p_processing_sequence
	  ,p_txn_category_attribute_id   =>      p_txn_category_attribute_id
	  ,p_from_value                  =>      p_from_value
	  ,p_to_value                    =>      p_to_value
	  ,p_enabled_flag                =>      p_enabled_flag
	  ,p_required_flag               =>      p_required_flag
	  ,p_exclude_flag                =>      p_exclude_flag
	  ,p_stat_situation_rule_id      =>      p_stat_situation_rule_id
	  ,p_object_version_number       =>      p_object_version_number

      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_STAT_SITUATION_RULE'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --

	   pqh_str_upd.upd
	      (p_effective_date            	 =>     l_effective_date
	      ,p_stat_situation_rule_id    	 =>     p_stat_situation_rule_id
	      ,p_object_version_number     	 =>     p_object_version_number
	      ,p_statutory_situation_id    	 =>     p_statutory_situation_id
	      ,p_processing_sequence       	 =>     p_processing_sequence
	      ,p_txn_category_attribute_id 	 =>     p_txn_category_attribute_id
	      ,p_from_value                	 =>     p_from_value
	      ,p_to_value                  	 =>     p_to_value
	      ,p_enabled_flag              	 =>     p_enabled_flag
	      ,p_required_flag             	 =>     p_required_flag
	      ,p_exclude_flag              	 =>     p_exclude_flag
	      );

  --
  -- Call After Process User Hook
  --
  begin
     pqh_fr_stat_sit_rules_bk2.update_stat_situation_rule_a
         (    p_effective_date           =>      l_effective_date
   	  ,p_statutory_situation_id      =>      p_statutory_situation_id
   	  ,p_processing_sequence         =>      p_processing_sequence
   	  ,p_txn_category_attribute_id   =>      p_txn_category_attribute_id
   	  ,p_from_value                  =>      p_from_value
   	  ,p_to_value                    =>      p_to_value
   	  ,p_enabled_flag                =>      p_enabled_flag
   	  ,p_required_flag               =>      p_required_flag
   	  ,p_exclude_flag                =>      p_exclude_flag
   	  ,p_stat_situation_rule_id      =>      p_stat_situation_rule_id
   	  ,p_object_version_number       =>      p_object_version_number

      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_STAT_SITUATION_RULE'
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
  -- p_object_version_number  := l_object_version_number;

    --
  if g_debug then
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
  End if;

exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to UPDATE_STAT_SITUATION_RULE;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
  p_object_version_number  := l_object_version_number;

   if g_debug then
  --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
    End if;

  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to UPDATE_STAT_SITUATION_RULE;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
   p_object_version_number  := l_object_version_number;

    raise;

end UPDATE_STAT_SITUATION_RULE;
--

-- ----------------------------------------------------------------------------
-- |--------------------------<DELETE_STAT_SITUATION_RULE >--------------------|
-- ----------------------------------------------------------------------------
--
  procedure delete_stat_situation_rule
  (p_validate                      in     boolean  default false
  ,p_stat_situation_rule_id               in     number
  ,p_object_version_number                in     number
  ) is

  --
  -- Declare cursors and local variables
  --
  l_proc                varchar2(72) := g_package||'delete_statutory_situation';
  l_stat_situation_rule_id pqh_fr_stat_situation_rules.stat_situation_rule_id%type;

begin
   if g_debug then
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  End if;

  --
  -- Issue a savepoint
  --
  savepoint DELETE_STAT_SITUATION_RULE;
  --
  -- Remember IN OUT parameter IN values
  --
  --
  -- Call Before Process User Hook
  --
  begin
       pqh_fr_stat_sit_rules_bk3.delete_stat_situation_rule_b
      (  p_stat_situation_rule_id       =>   p_stat_situation_rule_id
	,p_object_version_number	=>   p_object_version_number
      );

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_STAT_SITUATION_RULE'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --

	     pqh_str_del.del
	   	   (
	     		p_stat_situation_rule_id           =>    p_stat_situation_rule_id
	     	       ,p_object_version_number           =>    p_object_version_number
	            );




  --
  -- Call After Process User Hook
  --
  begin
       pqh_fr_stat_sit_rules_bk3.delete_stat_situation_rule_a
           (  p_stat_situation_rule_id       =>   p_stat_situation_rule_id
     	     ,p_object_version_number	     =>   p_object_version_number
     	    );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_STAT_SITUATION_RULE'
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
  -- p_object_version_number  := l_object_version_number;
    --
  if g_debug then
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
  End if;
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to DELETE_STAT_SITUATION_RULE;
    --
    -- Reset IN OUT parameters and set OUT parameters
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
--  p_statutory_situation_id := l_statutory_situation_id;
--  p_object_version_number  := l_object_version_number;
   if g_debug then
   --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
   --
   end if;

  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to DELETE_STAT_SITUATION_RULE;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
  -- p_statutory_situation_id := l_statutory_situation_id;
  -- p_object_version_number  := l_object_version_number;

    raise;

end DELETE_STAT_SITUATION_RULE;
--



end PQH_FR_STAT_SIT_RULES_API;

/
