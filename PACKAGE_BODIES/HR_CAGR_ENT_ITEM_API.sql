--------------------------------------------------------
--  DDL for Package Body HR_CAGR_ENT_ITEM_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CAGR_ENT_ITEM_API" as
/* $Header: peceiapi.pkb 120.1 2006/10/18 08:44:46 grreddy noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_cagr_ent_item_api.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_cagr_entitlement_item >------------------|
-- ----------------------------------------------------------------------------
--
procedure create_cagr_entitlement_item
  (p_validate                       in     boolean    default false
  ,p_effective_date                 in     date
  ,p_language_code                  in     varchar2  default hr_api.userenv_lang
  ,p_business_group_id              in     number    default null
  ,p_item_name                      in     varchar2
  ,p_element_type_id                in     number    default null
  ,p_input_value_id                 in     varchar2  default null
  ,p_column_type                    in     varchar2
  ,p_column_size                    in     number    default 2000
  ,p_legislation_code               in     varchar2  default null
  ,p_beneficial_rule                in     varchar2  default null
  ,p_cagr_api_param_id              in     number    default null
  ,p_category_name                  in     varchar2
  ,p_beneficial_formula_id          in     number    default null
  ,p_uom                            in     varchar2
  ,p_flex_value_set_id              in     number    default null
  ,p_ben_rule_value_set_id	        in     number    default null
  ,p_mult_entries_allowed_flag      in     varchar2  default null
  ,p_auto_create_entries_flag       in     varchar2  default null -- CEI Enh
  ,p_object_version_number             out nocopy number
  ,p_cagr_entitlement_item_id          out nocopy number
  ,p_opt_id                            out nocopy number ) IS
  --
  -- Declare cursors and local variables
  --
  l_proc VARCHAR2(72) := g_package||'create_cagr_entitlement_item';
  l_object_version_number    per_cagr_entitlement_items.object_version_number%TYPE;
  l_cagr_entitlement_item_id per_cagr_entitlement_items.cagr_entitlement_item_id%TYPE;
  l_effective_date           DATE;
  l_cagr_api_id              per_cagr_entitlement_items.cagr_api_id%TYPE;
  l_language_code            hr_locations_all_tl.language%TYPE;
  --
  -- Declare variables for Option API Call
  --
  l_opt_id                   ben_opt_f.opt_id%TYPE;
  l_opt_ovn                  ben_opt_f.object_version_number%TYPE;
  l_effective_start_date     DATE;
  l_effective_end_date       DATE;
  --
  CURSOR csr_get_api_id IS
    SELECT cagr_api_id
	  FROM per_cagr_api_parameters p
	 WHERE p.cagr_api_param_id = p_cagr_api_param_id;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  SAVEPOINT create_cagr_entitlement_item;
  --
  hr_utility.set_location(l_proc, 20);
  --
  l_effective_date := TRUNC(p_effective_date);
  --
  -- Validate the language parameter.  l_language_code should be passed to functions
  -- instead of p_language_code from now on, to allow an IN OUT parameter to
  -- be passed through.
  --
  l_language_code := p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);
  --
  -- Create the option that will be used for this item
  --
  BEGIN
    --
    hr_utility.set_location(l_proc, 30);
    --
    ben_option_definition_api.create_option_definition
      (p_validate                       => p_validate
      ,p_opt_id                         => l_opt_id
      ,p_effective_start_date           => l_effective_start_date
      ,p_effective_end_date             => l_effective_end_date
      ,p_name                           => per_cagr_utility_pkg.option_name
      ,p_business_group_id              => p_business_group_id
      ,p_object_version_number          => l_opt_ovn
      ,p_effective_date                 => TO_DATE('01-01-1953','DD-MM-YYYY'));
    --
	hr_utility.set_location(l_proc||'/'||l_opt_id, 40);
	--
  END;
  --
  hr_utility.set_location(l_proc, 50);
  --
  -- Fetch the API ID for the CAGR Parameter
  -- ID passed into this procedure.
  --
  IF p_cagr_api_param_id IS NOT NULL THEN
    --
    OPEN csr_get_api_id;
    FETCH csr_get_api_id INTO l_cagr_api_id;
    --
    IF csr_get_api_id%NOTFOUND THEN
      --
      CLOSE csr_get_api_id;
      --
      hr_utility.set_message(800, 'HR_289232_CAGR_API_PARAM_ID_IN');
      hr_utility.raise_error;
      --
    ELSE
      --
	  CLOSE csr_get_api_id;
	  --
    END IF;
  --
  END IF;
  --
  hr_utility.set_location(l_proc||'/'||l_cagr_api_id, 60);
  --
  -- Process Logic
  --
  BEGIN
    --
    -- Start of API User Hook for the before hook of create_cagr_entitlement_item
    --
    hr_cagr_ent_item_bk1.create_cagr_entitlement_item_b
      (p_cagr_entitlement_item_id       =>  p_cagr_entitlement_item_id
      ,p_language_code		            =>  p_language_code
      ,p_business_group_id              =>  p_business_group_id
      ,p_opt_id                         =>  l_opt_id
      ,p_item_name                      =>  p_item_name
      ,p_element_type_id                =>  p_element_type_id
      ,p_input_value_id                 =>  p_input_value_id
      ,p_column_type                    =>  p_column_type
      ,p_column_size                    =>  p_column_size
      ,p_legislation_code               =>  p_legislation_code
      ,p_beneficial_rule                =>  p_beneficial_rule
      ,p_cagr_api_id                    =>  l_cagr_api_id
      ,p_cagr_api_param_id              =>  p_cagr_api_param_id
      ,p_category_name                  =>  p_category_name
      ,p_beneficial_formula_id          =>  p_beneficial_formula_id
      ,p_uom                            =>  p_uom
      ,p_flex_value_set_id              =>  p_flex_value_set_id
      ,p_ben_rule_value_set_id	        =>  p_ben_rule_value_set_id
      ,p_mult_entries_allowed_flag      =>  p_mult_entries_allowed_flag
      ,p_auto_create_entries_flag       =>  p_auto_create_entries_flag -- CEI Enh

      );
  EXCEPTION
    WHEN hr_api.cannot_find_prog_unit THEN
      hr_api.cannot_find_prog_unit_error
        (
         p_module_name => 'CREATE_CAGR_ENTITLEMENT_ITEM'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_cagr_entitlement_item
    --
  END;
  --
  hr_utility.set_location(l_proc, 70);
  --
  per_cei_ins.ins
    (p_cagr_entitlement_item_id      => l_cagr_entitlement_item_id
    ,p_effective_date                => l_effective_date
    ,p_business_group_id             => p_business_group_id
    ,p_opt_id                        => l_opt_id
    ,p_item_name                     => p_item_name
    ,p_element_type_id               => p_element_type_id
    ,p_input_value_id                => p_input_value_id
    ,p_column_type                   => p_column_type
    ,p_column_size                   => p_column_size
    ,p_legislation_code              => p_legislation_code
    ,p_beneficial_rule               => p_beneficial_rule
    ,p_cagr_api_id                   => l_cagr_api_id
    ,p_cagr_api_param_id             => p_cagr_api_param_id
    ,p_category_name                 => p_category_name
    ,p_beneficial_formula_id         => p_beneficial_formula_id
    ,p_uom                           => p_uom
    ,p_flex_value_set_id             => p_flex_value_set_id
    ,p_ben_rule_value_set_id	     => p_ben_rule_value_set_id
    ,p_mult_entries_allowed_flag     => p_mult_entries_allowed_flag
    ,p_auto_create_entries_flag      => p_auto_create_entries_flag -- CEI Enh
    ,p_object_version_number         => l_object_version_number);
  --
  --  Now insert translatable rows in HR_LOCATIONS_ALL_TL table
  --
  per_cit_ins.ins_tl
    (p_language_code            => l_language_code
    ,p_cagr_entitlement_item_id  => l_cagr_entitlement_item_id
    ,p_item_name                 => p_item_name
    ) ;
  --
  begin
    --
    -- Start of API User Hook for the after hook of create_cagr_entitlement_item
    --
    hr_cagr_ent_item_bk1.create_cagr_entitlement_item_a
      (p_cagr_entitlement_item_id       =>  p_cagr_entitlement_item_id
      ,p_language_code		            =>  p_language_code
      ,p_business_group_id              =>  p_business_group_id
      ,p_opt_id                         =>  l_opt_id
      ,p_item_name                      =>  p_item_name
      ,p_element_type_id                =>  p_element_type_id
      ,p_input_value_id                 =>  p_input_value_id
	  ,p_column_type                    =>  p_column_type
	  ,p_column_size                    =>  p_column_size
      ,p_legislation_code               =>  p_legislation_code
      ,p_beneficial_rule                =>  p_beneficial_rule
      ,p_cagr_api_id                    =>  l_cagr_api_id
      ,p_cagr_api_param_id              =>  p_cagr_api_param_id
      ,p_category_name                  =>  p_category_name
      ,p_beneficial_formula_id          =>  p_beneficial_formula_id
      ,p_uom                            =>  p_uom
      ,p_flex_value_set_id              =>  p_flex_value_set_id
       ,p_ben_rule_value_set_id	        =>  p_ben_rule_value_set_id
      ,p_mult_entries_allowed_flag      =>  p_mult_entries_allowed_flag
      ,p_auto_create_entries_flag       =>  p_auto_create_entries_flag -- CEI Enh
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_cagr_entitlement_item'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_cagr_entitlement_item
    --
  end;
  --
  hr_utility.set_location(l_proc, 80);
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_object_version_number     := l_object_version_number;
  p_cagr_entitlement_item_id  := l_cagr_entitlement_item_id;
  p_opt_id                    := l_opt_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 999);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_cagr_entitlement_item;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO create_cagr_entitlement_item;
    raise;
    --
end create_cagr_entitlement_item;
-- ----------------------------------------------------------------------------
-- |------------------------< update_cagr_entitlement_item >--- ------------------|
-- ----------------------------------------------------------------------------
--
procedure update_cagr_entitlement_item
  (p_validate                       in     boolean   default false
  ,p_effective_date                 in     date
  ,p_language_code                  in     varchar2  DEFAULT hr_api.userenv_lang
  ,p_cagr_entitlement_item_id       in     number    default hr_api.g_number
  ,p_business_group_id              in     number    default hr_api.g_number
  ,p_item_name                      in     varchar2  default hr_api.g_varchar2
  ,p_element_type_id                in     number    default hr_api.g_number
  ,p_input_value_id                 in     varchar2  default hr_api.g_varchar2
  ,p_column_type                    in     varchar2  default hr_api.g_varchar2
  ,p_column_size                    in     number    default hr_api.g_number
  ,p_legislation_code               in     varchar2  default hr_api.g_varchar2
  ,p_beneficial_rule                in     varchar2  default hr_api.g_varchar2
  ,p_cagr_api_param_id              in     number    default hr_api.g_number
  ,p_category_name                  in     varchar2  default hr_api.g_varchar2
  ,p_beneficial_formula_id          in     number    default hr_api.g_number
  ,p_uom                            in     varchar2  default hr_api.g_varchar2
  ,p_flex_value_set_id              in     number    default hr_api.g_number
  ,p_ben_rule_value_set_id	        in     number    default hr_api.g_number
  ,p_mult_entries_allowed_flag      in     varchar2  default hr_api.g_varchar2
  ,p_object_version_number          in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc varchar2(72) := g_package||'update_cagr_entitlement_item';
  l_object_version_number per_cagr_entitlement_items.object_version_number%TYPE;
  l_effective_date        DATE;
  l_language_code         hr_locations_all_tl.language%TYPE;
  l_cagr_api_id           per_cagr_entitlement_items.cagr_api_id%TYPE;
  --
  CURSOR csr_get_api_id IS
    SELECT cagr_api_id
	  FROM per_cagr_api_parameters p
	 WHERE p.cagr_api_param_id = p_cagr_api_param_id;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint update_cagr_entitlement_item;
  --
  hr_utility.set_location(l_proc, 20);
  --
  l_effective_date := TRUNC(p_effective_date);
  --
  -- Validate the language parameter.  l_language_code should be passed to functions
  -- instead of p_language_code from now on, to allow an IN OUT parameter to be
  -- passed through.
  --
  l_language_code := p_language_code;
  hr_api.validate_language_code(p_language_code => l_language_code);
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- Fetch the API ID for the CAGR Parameter
  -- ID passed into this procedure.
  --
  IF p_cagr_api_param_id IS NOT NULL THEN
    --
    OPEN csr_get_api_id;
    FETCH csr_get_api_id INTO l_cagr_api_id;
    --
    IF csr_get_api_id%NOTFOUND THEN
      --
      CLOSE csr_get_api_id;
      --
      hr_utility.set_message(800, 'HR_289232_CAGR_API_PARAM_ID_IN');
      hr_utility.raise_error;
      --
    ELSE
      --
	  CLOSE csr_get_api_id;
	  --
    END IF;
    --
  END IF;
  --
  hr_utility.set_location(l_proc||'/'||l_cagr_api_id, 40);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  begin
    --
    -- Start of API User Hook for the before hook of update_cagr_entitlement_item
    --
    hr_cagr_ent_item_bk2.update_cagr_entitlement_item_b
      (p_cagr_entitlement_item_id       =>  p_cagr_entitlement_item_id
       ,p_language_code		            =>  p_language_code
      ,p_business_group_id              =>  p_business_group_id
      ,p_item_name                      =>  p_item_name
      ,p_element_type_id                =>  p_element_type_id
      ,p_input_value_id                 =>  p_input_value_id
	  ,p_column_type                    =>  p_column_type
	  ,p_column_size                    =>  p_column_size
      ,p_legislation_code               =>  p_legislation_code
      ,p_beneficial_rule                =>  p_beneficial_rule
      ,p_cagr_api_id                    =>  l_cagr_api_id
      ,p_cagr_api_param_id              =>  p_cagr_api_param_id
      ,p_category_name                  =>  p_category_name
      ,p_beneficial_formula_id          =>  p_beneficial_formula_id
      ,p_uom                            =>  p_uom
      ,p_flex_value_set_id              =>  p_flex_value_set_id
      ,p_ben_rule_value_set_id	        =>  p_ben_rule_value_set_id
      ,p_mult_entries_allowed_flag      =>  p_mult_entries_allowed_flag
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_cagr_entitlement_item'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of update_cagr_entitlement_item
    --
  end;
  --
  per_cei_upd.upd
    (p_cagr_entitlement_item_id      => p_cagr_entitlement_item_id
    ,p_effective_date                => l_effective_date
    ,p_business_group_id             => p_business_group_id
    ,p_item_name                     => p_item_name
    ,p_element_type_id               => p_element_type_id
    ,p_input_value_id                => p_input_value_id
	,p_column_type                   => p_column_type
	,p_column_size                   => p_column_size
    ,p_legislation_code              => p_legislation_code
    ,p_beneficial_rule               => p_beneficial_rule
    ,p_cagr_api_id                   => l_cagr_api_id
    ,p_cagr_api_param_id             => p_cagr_api_param_id
    ,p_category_name                 => p_category_name
    ,p_beneficial_formula_id         => p_beneficial_formula_id
    ,p_uom                           => p_uom
    ,p_flex_value_set_id             => p_flex_value_set_id
    ,p_ben_rule_value_set_id	     => p_ben_rule_value_set_id
    ,p_mult_entries_allowed_flag     => p_mult_entries_allowed_flag
    ,p_object_version_number         => l_object_version_number
    );
  --
  per_cit_upd.upd_tl
    (p_language_code                => l_language_code
    ,p_cagr_entitlement_item_id     => p_cagr_entitlement_item_id
    ,p_item_name                    => p_item_name) ;
  --
  begin
    --
    -- Start of API User Hook for the after hook of update_cagr_entitlement_item
    --
    hr_cagr_ent_item_bk2.update_cagr_entitlement_item_a
      (p_cagr_entitlement_item_id       =>  p_cagr_entitlement_item_id
      ,p_language_code		            =>  p_language_code
      ,p_business_group_id              =>  p_business_group_id
      ,p_item_name                      =>  p_item_name
      ,p_element_type_id                =>  p_element_type_id
      ,p_input_value_id                 =>  p_input_value_id
	  ,p_column_type                    =>  p_column_type
	  ,p_column_size                    =>  p_column_size
      ,p_legislation_code               =>  p_legislation_code
      ,p_beneficial_rule                =>  p_beneficial_rule
      ,p_cagr_api_id                    =>  l_cagr_api_id
      ,p_cagr_api_param_id              =>  p_cagr_api_param_id
      ,p_category_name                  =>  p_category_name
      ,p_beneficial_formula_id          =>  p_beneficial_formula_id
      ,p_uom                            =>  p_uom
      ,p_flex_value_set_id              =>  p_flex_value_set_id
      ,p_ben_rule_value_set_id	        =>  p_ben_rule_value_set_id
      ,p_mult_entries_allowed_flag      =>  p_mult_entries_allowed_flag
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_cagr_entitlement_item'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of update_cagr_entitlement_item
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
  hr_utility.set_location(' Leaving:'||l_proc, 999);
  --
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_cagr_entitlement_item;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
    --
  when others then
    --
    -- A validation or unexpected error has occured
    --
    ROLLBACK TO update_cagr_entitlement_item;
    raise;
    --
end update_cagr_entitlement_item;
-- ----------------------------------------------------------------------------
-- |------------------------< delete_cagr_entitlement_item >----------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_cagr_entitlement_item
  (p_validate                       in     boolean  default false
  ,p_effective_date                 in     date
  ,p_cagr_entitlement_item_id       in     number
  ,p_object_version_number          in out nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --
  l_proc                  VARCHAR2(72) := g_package||'update_cagr_entitlement_item';
  l_object_version_number per_cagr_entitlement_items.object_version_number%TYPE;
  l_effective_date        DATE;
  l_opt_id		NUMBER;
  l_opt_ovn		NUMBER;
  l_effective_start_date	DATE;
  l_effective_end_date		DATE;
  --
  CURSOR csr_option IS
      SELECT b.opt_id,
  	       b.object_version_number
  	  FROM ben_opt_f b,
  	       PER_CAGR_ENTITLEMENT_ITEMS cagitems
  	 WHERE b.opt_id = cagitems.opt_Id
	   AND cagitems.CAGR_ENTITLEMENT_ITEM_ID = p_cagr_entitlement_item_id;
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint if operating in validation only mode
  --
  savepoint delete_cagr_entitlement_item;
  --
  hr_utility.set_location(l_proc, 20);
  --
  l_effective_date := TRUNC(p_effective_date);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  --
  --
  begin
    --
    -- Start of API User Hook for the before hook of delete_cagr_entitlement_item
    --
    hr_cagr_ent_item_bk3.delete_cagr_entitlement_item_b
      (p_cagr_entitlement_item_id       =>  p_cagr_entitlement_item_id
      ,p_effective_date                 =>  l_effective_date
      ,p_object_version_number          =>  l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_cagr_entitlement_item'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of delete_cagr_entitlement_item
    --
  end;
  --
  --
  -- Process Logic
  -- =============
  --
  --  Need to lock main table to maintain the locking ladder order
  --
  hr_utility.set_location( l_proc, 30);
  per_cei_shd.lck (   p_cagr_entitlement_item_id     =>  p_cagr_entitlement_item_id
  			,p_object_version_number      => p_object_version_number);
  --
  --
  open csr_option;
  fetch csr_option into l_opt_id, l_opt_ovn;
  --
  if csr_option%found then
  	ben_option_definition_api.delete_option_definition
	  (p_validate                       => p_validate
	  ,p_opt_id                         => l_opt_id
	  ,p_effective_start_date           => l_effective_start_date
	  ,p_effective_end_date             => l_effective_end_date
	  ,p_object_version_number          => l_opt_ovn
	  ,p_effective_date                 => p_effective_date
	  ,p_datetrack_mode                 => 'ZAP'
  	);
  end if;
  --
  --  Remove all matching translation rows
  --
  hr_utility.set_location( l_proc, 35);
  per_cit_del.del_tl ( p_cagr_entitlement_item_id => p_cagr_entitlement_item_id );
  --
  hr_utility.set_location( l_proc, 45);
  --
  per_cei_del.del
    (p_cagr_entitlement_item_id => p_cagr_entitlement_item_id
    ,p_effective_date           => l_effective_date
    ,p_object_version_number    => l_object_version_number
    );
  --
  begin
    --
    -- Start of API User Hook for the after hook of delete_cagr_entitlement_item
    --
    hr_cagr_ent_item_bk3.delete_cagr_entitlement_item_a
      (p_cagr_entitlement_item_id       =>  p_cagr_entitlement_item_id
      ,p_effective_date                 =>  l_effective_date
      ,p_object_version_number          =>  l_object_version_number);

  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_cagr_entitlement_item'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of delete_cagr_entitlement_item
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
    ROLLBACK TO delete_cagr_entitlement_item;
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
    ROLLBACK TO delete_cagr_entitlement_item;
    raise;
    --
end delete_cagr_entitlement_item;
--
end hr_cagr_ent_item_api;

/
