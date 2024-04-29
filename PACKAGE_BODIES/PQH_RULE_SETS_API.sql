--------------------------------------------------------
--  DDL for Package Body PQH_RULE_SETS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_RULE_SETS_API" as
/* $Header: pqrstapi.pkb 120.0 2005/05/29 02:38:40 appldev noship $ */

--
-- Package Variables
--
g_package  varchar2(33) := '  pqh_RULE_SETS_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_RULE_SET >----------------------|
-- ----------------------------------------------------------------------------
--
procedure create_RULE_SET
  (p_validate                       in  boolean   default false
  ,p_business_group_id              in  number
  ,p_rule_set_id                    out nocopy number
  ,p_rule_set_name                  in  varchar2
  ,p_description		    in  varchar2
  ,p_organization_structure_id      in  number    default null
  ,p_organization_id                in  number    default null
  ,p_referenced_rule_set_id         in  number    default null
  ,p_rule_level_cd                  in  varchar2
  ,p_object_version_number          out nocopy number
  ,p_short_name                     in  varchar2
  ,p_effective_date                 in  date
  ,p_language_code                  in varchar2   default hr_api.userenv_lang
  ,p_rule_applicability		   in varchar2
  ,p_rule_category		   in varchar2
  ,p_starting_organization_id	   in number      default null
  ,p_seeded_rule_flag		   in varchar2    default 'N'
  ,p_status      		   in varchar2    default null
  ) is
  --
  -- Declare cursors and local variables
  --
  l_rule_set_id pqh_rule_sets.rule_set_id%TYPE;
  l_proc varchar2(72) := g_package||'create_RULE_SET';
  l_object_version_number pqh_rule_sets.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint create_RULE_SET;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  begin
    --
    -- Start of API User Hook for the before hook of create_RULE_SET
    --
    pqh_RULE_SETS_bk1.create_RULE_SET_b
      (
       p_business_group_id              =>  p_business_group_id
      ,p_rule_set_name                  =>  p_rule_set_name
      ,p_description			=>  p_description
      ,p_organization_structure_id      =>  p_organization_structure_id
      ,p_organization_id                =>  p_organization_id
      ,p_referenced_rule_set_id         =>  p_referenced_rule_set_id
      ,p_rule_level_cd                  =>  p_rule_level_cd
      ,p_short_name                     =>  p_short_name
      ,p_effective_date               => trunc(p_effective_date)
      ,p_rule_applicability	      =>  p_rule_applicability
      ,p_rule_category		      =>  p_rule_category
      ,p_starting_organization_id     =>  p_starting_organization_id
      ,p_seeded_rule_flag	      =>  p_seeded_rule_flag
      ,p_status         	      =>  p_status
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_RULE_SET'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_RULE_SET
    --
  end;
  --
  pqh_rst_ins.ins
    (
     p_rule_set_id                   => l_rule_set_id
    ,p_business_group_id             => p_business_group_id
    ,p_rule_set_name                 => p_rule_set_name
    ,p_organization_structure_id     => p_organization_structure_id
    ,p_organization_id               => p_organization_id
    ,p_referenced_rule_set_id        => p_referenced_rule_set_id
    ,p_rule_level_cd                 => p_rule_level_cd
    ,p_object_version_number         => l_object_version_number
    ,p_short_name                    => p_short_name
    ,p_effective_date                => trunc(p_effective_date)
    ,p_rule_applicability	      =>  p_rule_applicability
    ,p_rule_category		      =>  p_rule_category
    ,p_starting_organization_id     =>  p_starting_organization_id
    ,p_seeded_rule_flag	    =>  p_seeded_rule_flag
    ,p_status     	    =>  p_status
    );
  --
    p_rule_set_id  := l_rule_set_id ;
    pqh_rtl_ins.ins_tl(
       p_language_code  => p_language_code,
       p_rule_set_id    => l_rule_set_id ,
       p_rule_set_name  => p_rule_set_name,
       p_description    => p_description
       );
  --

  --
  begin
    --
    -- Start of API User Hook for the after hook of create_RULE_SET
    --
    pqh_RULE_SETS_bk1.create_RULE_SET_a
      (
       p_business_group_id              =>  p_business_group_id
      ,p_rule_set_id                    =>  l_rule_set_id
      ,p_rule_set_name                  =>  p_rule_set_name
      ,p_description			=>  p_description
      ,p_organization_structure_id      =>  p_organization_structure_id
      ,p_organization_id                =>  p_organization_id
      ,p_referenced_rule_set_id         =>  p_referenced_rule_set_id
      ,p_rule_level_cd                  =>  p_rule_level_cd
      ,p_object_version_number          =>  l_object_version_number
      ,p_short_name                     =>  p_short_name
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_rule_applicability	      =>  p_rule_applicability
      ,p_rule_category		      =>  p_rule_category
      ,p_starting_organization_id     =>  p_starting_organization_id
      ,p_seeded_rule_flag	      =>  p_seeded_rule_flag
      ,p_status  		      =>  p_status
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_RULE_SET'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_RULE_SET
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_rule_set_id := l_rule_set_id;
  p_object_version_number := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_RULE_SET;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_rule_set_id := null;
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
      p_rule_set_id := null;
    p_object_version_number  := null;
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_RULE_SET;
    raise;
    --
end create_RULE_SET;
-- ----------------------------------------------------------------------------
-- |------------------------< update_RULE_SET >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_RULE_SET
  (p_validate                       in  boolean   default false
  ,p_business_group_id              in  number    default hr_api.g_number
  ,p_rule_set_id                    in  number
  ,p_rule_set_name                  in  varchar2  default hr_api.g_varchar2
  ,p_description		    in  varchar2  default hr_api.g_varchar2
  ,p_organization_structure_id      in  number    default hr_api.g_number
  ,p_organization_id                in  number    default hr_api.g_number
  ,p_referenced_rule_set_id         in  number    default hr_api.g_number
  ,p_rule_level_cd                  in  varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ,p_short_name                     in  varchar2  default hr_api.g_varchar2
  ,p_effective_date                 in  date
  ,p_language_code                  in varchar2   default hr_api.userenv_lang
  ,p_rule_applicability		   in varchar2  default hr_api.g_varchar2
  ,p_rule_category		   in varchar2  default hr_api.g_varchar2
  ,p_starting_organization_id	   in number    default hr_api.g_number
  ,p_seeded_rule_flag		   in varchar2  default hr_api.g_varchar2
  ,p_status                        in varchar2  default hr_api.g_varchar2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_RULE_SET';
  l_object_version_number pqh_rule_sets.object_version_number%TYPE;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_RULE_SET;
  --
  hr_utility.set_location(l_proc, 20);
  hr_utility.set_location('description passed is'||p_description, 20);
  hr_utility.set_location('rule_set_name passed is'||p_rule_set_name, 30);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_RULE_SET
    --
    pqh_RULE_SETS_bk2.update_RULE_SET_b
      (
       p_business_group_id              =>  p_business_group_id
      ,p_rule_set_id                    =>  p_rule_set_id
      ,p_rule_set_name                  =>  p_rule_set_name
      ,p_description		        =>  p_description
      ,p_organization_structure_id      =>  p_organization_structure_id
      ,p_organization_id                =>  p_organization_id
      ,p_referenced_rule_set_id         =>  p_referenced_rule_set_id
      ,p_rule_level_cd                  =>  p_rule_level_cd
      ,p_object_version_number          =>  p_object_version_number
      ,p_short_name                     =>  p_short_name
      ,p_effective_date                 => trunc(p_effective_date)
      ,p_rule_applicability    	        =>  p_rule_applicability
      ,p_rule_category		        =>  p_rule_category
      ,p_starting_organization_id       =>  p_starting_organization_id
      ,p_seeded_rule_flag	        =>  p_seeded_rule_flag
      ,p_status                         =>  p_status
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_RULE_SET'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_RULE_SET
    --
  end;
  --
  pqh_rst_upd.upd
    (
     p_rule_set_id                   => p_rule_set_id
    ,p_business_group_id             => p_business_group_id
    ,p_rule_set_name                 => p_rule_set_name
    ,p_organization_structure_id     => p_organization_structure_id
    ,p_organization_id               => p_organization_id
    ,p_referenced_rule_set_id        => p_referenced_rule_set_id
    ,p_rule_level_cd                 => p_rule_level_cd
    ,p_object_version_number         => l_object_version_number
    ,p_short_name                    => p_short_name
    ,p_effective_date                => trunc(p_effective_date)
    ,p_rule_applicability	     => p_rule_applicability
    ,p_rule_category		     => p_rule_category
    ,p_starting_organization_id      => p_starting_organization_id
    ,p_seeded_rule_flag	             => p_seeded_rule_flag
    ,p_status                        => p_status
    );
  --
  hr_utility.set_location('description passed is'||p_description, 70);
  hr_utility.set_location('rule_set_name passed is'||p_rule_set_name, 80);
 --
    pqh_rtl_upd.upd_tl(
       p_language_code  => p_language_code,
       p_rule_set_id    => p_rule_set_id ,
       p_rule_set_name  => p_rule_set_name,
       p_description	=> p_description
       );

  begin
    --
    -- Start of API User Hook for the after hook of update_RULE_SET
    --
    pqh_RULE_SETS_bk2.update_RULE_SET_a
      (
       p_business_group_id              =>  p_business_group_id
      ,p_rule_set_id                    =>  p_rule_set_id
      ,p_rule_set_name                  =>  p_rule_set_name
      ,p_description		        =>  p_description
      ,p_organization_structure_id      =>  p_organization_structure_id
      ,p_organization_id                =>  p_organization_id
      ,p_referenced_rule_set_id         =>  p_referenced_rule_set_id
      ,p_rule_level_cd                  =>  p_rule_level_cd
      ,p_object_version_number          =>  l_object_version_number
      ,p_short_name                     =>  p_short_name
      ,p_effective_date                 =>  trunc(p_effective_date)
      ,p_rule_applicability	        =>  p_rule_applicability
      ,p_rule_category		        =>  p_rule_category
      ,p_starting_organization_id       =>  p_starting_organization_id
      ,p_seeded_rule_flag	        =>  p_seeded_rule_flag
      ,p_status                         =>  p_status
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_RULE_SET'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_RULE_SET
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_object_version_number := l_object_version_number;
  --
  --
  hr_utility.set_location('description passed is'||p_description, 170);
  hr_utility.set_location('rule_set_name passed is'||p_rule_set_name, 180);
 --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_RULE_SET;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    p_object_version_number := l_object_version_number;
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_RULE_SET;
    raise;
    --
end update_RULE_SET;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_RULE_SET >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_RULE_SET
  (p_validate                       in  boolean  default false
  ,p_rule_set_id                    in  number
  ,p_object_version_number          in  number
  ,p_effective_date                 in  date
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'delete_RULE_SET';
  l_object_version_number pqh_rule_sets.object_version_number%TYPE;
  --
  --Declare cursor for pqh_rule_attributes.
  --
cursor c1 is
  select rule_attribute_id, object_version_number
  from pqh_rule_attributes where rule_set_id = p_rule_set_id;

begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_RULE_SET;
  --
  hr_utility.set_location(l_proc, 20);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  --
  begin
    --
    -- Start of API User Hook for the before hook of delete_RULE_SET
    --
    pqh_RULE_SETS_bk3.delete_RULE_SET_b
      (
       p_rule_set_id                    =>  p_rule_set_id
      ,p_object_version_number          =>  p_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_RULE_SET'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_RULE_SET
    --
  end;
  --
  pqh_rst_shd.lck
    (
     p_rule_set_id                   => p_rule_set_id
    ,p_object_version_number         => l_object_version_number
    );
  --
  --Delete from pqh_rule_attributes
  --
for rule_att in c1 loop
pqh_rla_del.del(p_rule_attribute_id       => rule_att.rule_attribute_id
               ,p_object_version_number   => rule_att.object_version_number);
end loop;

delete from pqh_rules where rule_set_id = p_rule_set_id;


  pqh_rtl_del.del_tl(
       p_rule_set_id   => p_rule_set_id );
  --
  pqh_rst_del.del
    (
     p_rule_set_id                   => p_rule_set_id
    ,p_object_version_number         => l_object_version_number
    ,p_effective_date                => p_effective_date
    );
  --
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_RULE_SET
    --
    pqh_RULE_SETS_bk3.delete_RULE_SET_a
      (
       p_rule_set_id                    =>  p_rule_set_id
      ,p_object_version_number          =>  l_object_version_number
      ,p_effective_date                 => trunc(p_effective_date)
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_RULE_SET'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_RULE_SET
    --
  end;
  --
  hr_utility.set_location(l_proc, 60);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_RULE_SET;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO delete_RULE_SET;
    raise;
    --
end delete_RULE_SET;
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< lck >------------------------------------|
-- ----------------------------------------------------------------------------
--
procedure lck
  (
   p_rule_set_id                   in     number
  ,p_object_version_number          in     number
  ) is
  --
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'lck';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  pqh_rst_shd.lck
    (
      p_rule_set_id                 => p_rule_set_id
     ,p_object_version_number      => p_object_version_number
    );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
  --
end lck;
--
end pqh_RULE_SETS_api;

/
