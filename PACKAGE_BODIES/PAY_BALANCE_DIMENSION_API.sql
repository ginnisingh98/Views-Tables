--------------------------------------------------------
--  DDL for Package Body PAY_BALANCE_DIMENSION_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_BALANCE_DIMENSION_API" AS
/* $Header: pybldapi.pkb 120.0 2005/05/29 03:19:13 appldev noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  pay_balance_dimension_api.';
--
-- ----------------------------------------------------------------------------
-- |--------------------------< create_balance_dimension >---------------------|
-- ----------------------------------------------------------------------------
--
procedure create_balance_dimension
  (p_validate                   in         boolean  default false,
   p_balance_dimension_id	out nocopy	   NUMBER,
   p_business_group_id          in         NUMBER,
   p_legislation_code           in         VARCHAR2,
   p_route_id  			in	   NUMBER,
   p_database_item_suffix       in         VARCHAR2,
   p_dimension_name             in         VARCHAR2,
   p_dimension_type             in         VARCHAR2,
   p_description                in         VARCHAR2,
   p_feed_checking_code         in         VARCHAR2,
   p_legislation_subgroup       in         VARCHAR2,
   p_payments_flag              in         VARCHAR2,
   p_expiry_checking_code       in         VARCHAR2,
   p_expiry_checking_level      in         VARCHAR2,
   p_feed_checking_type         in         VARCHAR2,
   p_dimension_level            in         VARCHAR2,
   p_period_type                in         VARCHAR2,
   p_asg_action_balance_dim_id  in         NUMBER,
   p_database_item_function     in         VARCHAR2,
   p_save_run_balance_enabled   in         VARCHAR2,
   p_start_date_code            in         VARCHAR2
  ) is
  --
  -- Declare cursors and local variables
  --
  l_balance_dimension_id number;
  l_in_out_parameter    number;
  l_proc                varchar2(72) :=g_package||'create_balance_dimension';
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
l_in_out_parameter := p_description;
  savepoint create_balance_dimension;
  --

  begin
  g_dml_status := TRUE;
  pay_bld_ins.ins
  (p_route_id			=>  p_route_id
  ,p_database_item_suffix       =>  p_database_item_suffix
  ,p_dimension_name             =>  p_dimension_name
  ,p_dimension_type             =>  p_dimension_type
  ,p_business_group_id          =>  p_business_group_id
  ,p_legislation_code           =>  p_legislation_code
  ,p_description                =>  p_description
  ,p_feed_checking_code         =>  p_feed_checking_code
  ,p_legislation_subgroup       =>  p_legislation_subgroup
  ,p_payments_flag              =>  p_payments_flag
  ,p_expiry_checking_code       =>  p_expiry_checking_code
  ,p_expiry_checking_level      =>  p_expiry_checking_level
  ,p_feed_checking_type         =>  p_feed_checking_type
  ,p_dimension_level            =>  p_dimension_level
  ,p_period_type                =>  p_period_type
  ,p_asg_action_balance_dim_id  =>  p_asg_action_balance_dim_id
  ,p_database_item_function     =>  p_database_item_function
  ,p_save_run_balance_enabled   =>  p_save_run_balance_enabled
  ,p_start_date_code            =>  p_start_date_code
  ,p_balance_dimension_id       =>  l_balance_dimension_id
  ) ;
  --
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'create_balance_dimension'
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
p_balance_dimension_id := l_balance_dimension_id;
--For MLS-----------------------------------------------------------------------
pay_bdt_ins.ins_tl(userenv('lang'),p_balance_dimension_id,p_dimension_name,
		   p_database_item_suffix,p_description);
--------------------------------------------------------------------------------
g_dml_status := FALSE;
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to create_balance_dimension;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to create_balance_dimension;
    --
    -- Reset IN OUT parameters and set all
    -- OUT parameters, including warnings, to null
    --
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    g_dml_status := FALSE;
    raise;

end create_balance_dimension;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< update_balance_dimension >---------------------|
-- ----------------------------------------------------------------------------
--
procedure update_balance_dimension
  (p_validate                   in         boolean  default false,
   p_balance_dimension_id	in	   NUMBER,
   p_business_group_id          in         NUMBER,
   p_legislation_code           in         VARCHAR2,
   p_route_id  			in	   NUMBER,
   p_database_item_suffix       in         VARCHAR2,
   p_dimension_name             in         VARCHAR2,
   p_dimension_type             in         VARCHAR2,
   p_description                in         VARCHAR2,
   p_feed_checking_code         in         VARCHAR2,
   p_legislation_subgroup       in         VARCHAR2,
   p_payments_flag              in         VARCHAR2,
   p_expiry_checking_code       in         VARCHAR2,
   p_expiry_checking_level      in         VARCHAR2,
   p_feed_checking_type         in         VARCHAR2,
   p_dimension_level            in         VARCHAR2,
   p_period_type                in         VARCHAR2,
   p_asg_action_balance_dim_id  in         NUMBER,
   p_database_item_function     in         VARCHAR2,
   p_save_run_balance_enabled   in         VARCHAR2,
   p_start_date_code            in         VARCHAR2
  ) is
  --
  l_proc    varchar2(72) :=g_package||'create_balance_dimension';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_balance_dimension;
  --
  -- Process Logic
  --
  g_dml_status := TRUE;
  pay_bld_upd.upd
  (p_balance_dimension_id       =>  p_balance_dimension_id
  ,p_route_id			=>  p_route_id
  ,p_database_item_suffix       =>  p_database_item_suffix
  ,p_dimension_name             =>  p_dimension_name
  ,p_dimension_type             =>  p_dimension_type
  ,p_business_group_id          =>  p_business_group_id
  ,p_legislation_code           =>  p_legislation_code
  ,p_description                =>  p_description
  ,p_feed_checking_code         =>  p_feed_checking_code
  ,p_legislation_subgroup       =>  p_legislation_subgroup
  ,p_payments_flag              =>  p_payments_flag
  ,p_expiry_checking_code       =>  p_expiry_checking_code
  ,p_expiry_checking_level      =>  p_expiry_checking_level
  ,p_feed_checking_type         =>  p_feed_checking_type
  ,p_dimension_level            =>  p_dimension_level
  ,p_period_type                =>  p_period_type
  ,p_asg_action_balance_dim_id  =>  p_asg_action_balance_dim_id
  ,p_database_item_function     =>  p_database_item_function
  ,p_save_run_balance_enabled   =>  p_save_run_balance_enabled
  ,p_start_date_code            =>  p_start_date_code
  ) ;
  --

  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
   --
--For MLS-----------------------------------------------------------------------
pay_bdt_upd.upd_tl(userenv('lang'),p_balance_dimension_id,p_dimension_name,
		   p_database_item_suffix,p_description);
--------------------------------------------------------------------------------
g_dml_status := FALSE;
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_balance_dimension;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_balance_dimension;

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    g_dml_status := FALSE;
    raise;
end update_balance_dimension;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< delete_balance_dimension >---------------------|
-- ----------------------------------------------------------------------------
--
procedure delete_balance_dimension
  (p_validate                      in     boolean  default false,
   p_balance_dimension_id   in NUMBER
  ) is
  --
  -- Declare cursors and local variables
  --
  l_in_out_parameter    number;
  l_effective_date       date;
  l_proc                 varchar2(72) := g_package||'delete_balance_dimension';
  l_object_version_number number;
  l_effective_start_date  date;
  l_effective_end_date    date;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_balance_dimension;
  --
  -- Process Logic
  --
    g_dml_status := TRUE;
--For MLS-----------------------------------------------------------------------
pay_bdt_del.del_tl(p_balance_dimension_id);
-----------------------------------------------------------------------------------
  pay_bld_del.del
     (p_balance_dimension_id  =>  p_balance_dimension_id);
  --
  -- Call After Process User Hook
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
g_dml_status := FALSE;
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_balance_dimension;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
    g_dml_status := FALSE;
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_balance_dimension;

    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;

end delete_balance_dimension;
--
function return_dml_status
return boolean
IS
begin
return g_dml_status;
end return_dml_status;
--
END PAY_BALANCE_DIMENSION_API;

/
