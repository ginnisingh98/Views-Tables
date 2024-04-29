--------------------------------------------------------
--  DDL for Package Body PAY_INPUT_VALUE_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_INPUT_VALUE_API" as
/* $Header: pyivlapi.pkb 120.0.12010000.3 2008/08/06 07:33:31 ubhat ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  PAY_INPUT_VALUE_API.';

--
-- ----------------------------------------------------------------------------
-- |------------------------< CREATE_INPUT_VALUE_INT >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_INPUT_VALUE_INT
   ( p_element_type_id       IN number
  ,p_generate_db_items_flag  IN	varchar2
  ,p_hot_default_flag        IN	varchar2
  ,p_name                    IN	varchar2
  ,p_uom                     IN	varchar2
  ,p_default_value           IN	varchar2
  ,p_max_value               IN	varchar2
  ,p_min_value               IN	varchar2
  ,p_warning_or_error        IN	varchar2
  ,p_input_value_id          IN	number
  ,p_effective_start_date    IN	date
  ,p_effective_end_date      IN	date
   ) is

 --
 l_proc varchar2(72) := g_package||'PAY_INPUT_VALUE_INT';
 --
 begin

   hr_utility.set_location('Entering: '|| l_proc, 10);

  -- Cascade creation of link input values, Balance feeds and db items

  pay_link_input_values_pkg.create_link_input_value (

          p_input_value_id,
          p_element_type_id,
          p_effective_start_date ,
          p_effective_end_date ,
     -- change 115.12
          p_name,
          p_hot_default_flag,
          p_default_value,
          p_min_value,
          p_max_value,
          p_warning_or_error);

  hr_utility.set_location(l_proc, 20);

  -- Create balance feeds for pay values
  --
  -- change 115.12
    if (p_name = 'Pay Value'      -- the default
          or upper (p_name) = upper (hr_general.pay_value)) then
      hr_balance_feeds.ins_bf_pay_value (p_input_value_id);
    end if;
  --

  hr_utility.set_location(l_proc, 30);

  -- Bug 6432304
  -- Moved the DB Item creation call from RHI to API to handle translation Errors.

  -- bug 6609296

  if( p_generate_db_items_flag = 'Y' or upper(p_name) = 'PAY VALUE' ) then
     pay_input_values_pkg.recreate_db_items
     (p_element_type_id);
  end if;
  --
  hr_utility.set_location('Leaving: '|| l_proc, 40);

 end CREATE_INPUT_VALUE_INT;
--

--
-- ----------------------------------------------------------------------------
-- |--------------------------< CREATE_INPUT_VALUE >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_INPUT_VALUE
  (P_VALIDATE                in boolean  Default false
   ,P_EFFECTIVE_DATE          in date
   ,P_ELEMENT_TYPE_ID         in number
   ,P_NAME                    in varchar2
   ,P_UOM                     in varchar2
   ,P_LOOKUP_TYPE             in varchar2 Default Null
   ,P_FORMULA_ID              in number   Default Null
   ,P_VALUE_SET_ID            in number   Default Null
   ,P_DISPLAY_SEQUENCE        in number   Default Null
   ,P_GENERATE_DB_ITEMS_FLAG  in varchar2 Default 'N'
   ,P_HOT_DEFAULT_FLAG        in varchar2 Default 'N'
   ,P_MANDATORY_FLAG          in varchar2 Default 'N'
   ,P_DEFAULT_VALUE           in varchar2 Default Null
   ,P_MAX_VALUE               in varchar2 Default Null
   ,P_MIN_VALUE               in varchar2 Default Null
   ,P_WARNING_OR_ERROR        in varchar2 Default Null
   ,P_INPUT_VALUE_ID	      OUT NOCOPY number
   ,P_OBJECT_VERSION_NUMBER   OUT NOCOPY number
   ,P_EFFECTIVE_START_DATE    OUT NOCOPY date
   ,P_EFFECTIVE_END_DATE      OUT NOCOPY date
   ,P_DEFAULT_VAL_WARNING     OUT NOCOPY boolean
   ,P_MIN_MAX_WARNING         OUT NOCOPY boolean
   ,P_PAY_BASIS_WARNING       OUT NOCOPY boolean
   ,P_FORMULA_WARNING         OUT NOCOPY boolean
   ,P_ASSIGNMENT_ID_WARNING   OUT NOCOPY boolean
   ,P_FORMULA_MESSAGE         OUT NOCOPY varchar2
  ) is
  --
  -- Declare cursors and local variables
  --

  cursor csr_derived_values
  is
  select business_group_id,legislation_code,legislation_subgroup
  from pay_element_types_f
  where element_type_id = p_element_type_id;

  --

  l_business_group_id     pay_input_values_f.business_group_id%type;
  l_legislation_code      pay_input_values_f.legislation_code%type;
  l_legislation_subgroup  pay_input_values_f.legislation_subgroup%type;


  l_proc                varchar2(72) := g_package||'CREATE_INPUT_VALUE';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint CREATE_INPUT_VALUE;
  --
  -- Call Before Process User Hook
  --

  open csr_derived_values;
  fetch csr_derived_values into l_business_group_id,l_legislation_code,l_legislation_subgroup;
  close csr_derived_values;

  begin
    PAY_INPUT_VALUE_bk1.CREATE_INPUT_VALUE_b
   (P_VALIDATE
   ,trunc(P_EFFECTIVE_DATE)
   ,P_ELEMENT_TYPE_ID
   ,L_BUSINESS_GROUP_ID
   ,P_NAME
   ,P_UOM
   ,P_LOOKUP_TYPE
   ,L_LEGISLATION_CODE
   ,P_FORMULA_ID
   ,P_VALUE_SET_ID
   ,P_DISPLAY_SEQUENCE
   ,P_GENERATE_DB_ITEMS_FLAG
   ,P_HOT_DEFAULT_FLAG
   ,P_MANDATORY_FLAG
   ,P_DEFAULT_VALUE
   ,L_LEGISLATION_SUBGROUP
   ,P_MAX_VALUE
   ,P_MIN_VALUE
   ,P_WARNING_OR_ERROR
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_INPUT_VALUE'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Process Logic
  --

  pay_ivl_ins.ins(
   p_effective_date          => trunc(p_effective_date)
  ,p_element_type_id         => p_element_type_id
  ,p_display_sequence        =>	p_display_sequence
  ,p_generate_db_items_flag  =>	p_generate_db_items_flag
  ,p_hot_default_flag        =>	p_hot_default_flag
  ,p_mandatory_flag          =>	p_mandatory_flag
  ,p_name                    =>	p_name
  ,p_uom                     =>	p_uom
  ,p_lookup_type             =>	p_lookup_type
  ,p_business_group_id       =>	l_business_group_id
  ,p_legislation_code        =>	l_legislation_code
  ,p_formula_id              =>	p_formula_id
  ,p_value_set_id            =>  p_value_set_id
  ,p_default_value           =>	p_default_value
  ,p_legislation_subgroup    =>	l_legislation_subgroup
  ,p_max_value               =>	p_max_value
  ,p_min_value               =>	p_min_value
  ,p_warning_or_error        =>	p_warning_or_error
  ,p_input_value_id          =>	p_input_value_id
  ,p_object_version_number   =>	p_object_version_number
  ,p_effective_start_date    =>	p_effective_start_date
  ,p_effective_end_date      =>	p_effective_end_date
  ,p_default_val_warning     => p_default_val_warning
  ,p_min_max_warning         => p_min_max_warning
  ,p_pay_basis_warning       => p_pay_basis_warning
  ,p_formula_warning         => p_formula_warning
  ,p_assignment_id_warning   => p_assignment_id_warning
  ,p_formula_message         => p_formula_message
  );

  -- Bug 6432304
  -- Cascade creation of link input values, Balance feeds and db items is moved to
  -- the internal procedure create_input_value_int

  CREATE_INPUT_VALUE_INT
   ( p_element_type_id         => p_element_type_id
  ,p_generate_db_items_flag  =>	p_generate_db_items_flag
  ,p_hot_default_flag        =>	p_hot_default_flag
  ,p_name                    =>	p_name
  ,p_uom                     =>	p_uom
  ,p_default_value           =>	p_default_value
  ,p_max_value               =>	p_max_value
  ,p_min_value               =>	p_min_value
  ,p_warning_or_error        =>	p_warning_or_error
  ,p_input_value_id          =>	p_input_value_id
  ,p_effective_start_date    =>	p_effective_start_date
  ,p_effective_end_date      =>	p_effective_end_date
   );

  --
  -- Call After Process User Hook
  --
  begin
    PAY_INPUT_VALUE_bk1.CREATE_INPUT_VALUE_a
      (  P_VALIDATE
	,trunc(P_EFFECTIVE_DATE)
	,P_ELEMENT_TYPE_ID
	,L_BUSINESS_GROUP_ID
	,P_NAME
	,P_UOM
	,P_LOOKUP_TYPE
	,L_LEGISLATION_CODE
	,P_FORMULA_ID
   ,P_VALUE_SET_ID
	,P_DISPLAY_SEQUENCE
	,P_GENERATE_DB_ITEMS_FLAG
	,P_HOT_DEFAULT_FLAG
	,P_MANDATORY_FLAG
	,P_DEFAULT_VALUE
	,L_LEGISLATION_SUBGROUP
	,P_MAX_VALUE
	,P_MIN_VALUE
	,P_WARNING_OR_ERROR
	,P_INPUT_VALUE_ID
	,P_OBJECT_VERSION_NUMBER
	,P_EFFECTIVE_START_DATE
	,P_EFFECTIVE_END_DATE
	,P_DEFAULT_VAL_WARNING
	,P_MIN_MAX_WARNING
	,P_PAY_BASIS_WARNING
	,P_FORMULA_WARNING
	,P_ASSIGNMENT_ID_WARNING
	,P_FORMULA_MESSAGE
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_INPUT_VALUE'
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
  p_input_value_id         := p_input_value_id;
  p_object_version_number  := p_object_version_number;

  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to CREATE_INPUT_VALUE;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_input_value_id         := null;
    p_object_version_number  := null;
    p_default_val_warning    := null;
    p_min_max_warning        := null;
    p_pay_basis_warning      := null;
    p_formula_warning        := null;
    p_assignment_id_warning  := null;
    p_formula_message        := null;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to CREATE_INPUT_VALUE;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end CREATE_INPUT_VALUE;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< UPDATE_INPUT_VALUE >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_INPUT_VALUE
  ( P_VALIDATE                     IN     boolean  Default false
   ,P_EFFECTIVE_DATE               IN     date
   ,P_DATETRACK_MODE	           IN     varchar2
   ,P_INPUT_VALUE_ID		   IN     number
   ,P_OBJECT_VERSION_NUMBER	   IN OUT NOCOPY number
   ,P_NAME                         IN     varchar2 Default hr_api.g_varchar2
   ,P_UOM                          IN     varchar2 Default hr_api.g_varchar2
   ,P_LOOKUP_TYPE                  IN     varchar2 Default hr_api.g_varchar2
   ,P_FORMULA_ID                   IN     number   Default hr_api.g_number
   ,P_VALUE_SET_ID                 IN     number   Default hr_api.g_number
   ,P_DISPLAY_SEQUENCE             IN     number   Default hr_api.g_number
   ,P_GENERATE_DB_ITEMS_FLAG       IN     varchar2 Default hr_api.g_varchar2
   ,P_HOT_DEFAULT_FLAG             IN     varchar2 Default hr_api.g_varchar2
   ,P_MANDATORY_FLAG               IN     varchar2 Default hr_api.g_varchar2
   ,P_DEFAULT_VALUE                IN     varchar2 Default hr_api.g_varchar2
   ,P_MAX_VALUE                    IN     varchar2 Default hr_api.g_varchar2
   ,P_MIN_VALUE                    IN     varchar2 Default hr_api.g_varchar2
   ,P_WARNING_OR_ERROR             IN     varchar2 Default hr_api.g_varchar2
   ,P_EFFECTIVE_START_DATE	   OUT NOCOPY    date
   ,P_EFFECTIVE_END_DATE	   OUT NOCOPY    date
   ,P_DEFAULT_VAL_WARNING          OUT NOCOPY   boolean
   ,P_MIN_MAX_WARNING              OUT NOCOPY   boolean
   ,P_LINK_INP_VAL_WARNING         OUT NOCOPY   boolean
   ,P_PAY_BASIS_WARNING            OUT NOCOPY 	  boolean
   ,P_FORMULA_WARNING              OUT NOCOPY    boolean
   ,P_ASSIGNMENT_ID_WARNING        OUT NOCOPY    boolean
   ,P_FORMULA_MESSAGE              OUT NOCOPY    varchar2
   ) is
  --
  -- Declare cursors and local variables
  --
  cursor csr_derived_values
  is
  select business_group_id,legislation_code,element_type_id,legislation_subgroup
  from pay_input_values_f
  where input_value_id = p_input_value_id;


  l_element_type_id       pay_input_values_f.element_type_id%type;
  l_business_group_id     pay_input_values_f.business_group_id%type;
  l_legislation_code      pay_input_values_f.legislation_code%type;
  l_legislation_subgroup  pay_input_values_f.legislation_subgroup%type;

  l_proc                varchar2(72) := g_package||'UPDATE_INPUT_VALUE';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint UPDATE_INPUT_VALUE;
  --
  -- Call Before Process User Hook
  --
  begin
    PAY_INPUT_VALUE_bk2.UPDATE_INPUT_VALUE_b
      (P_VALIDATE
   ,trunc(P_EFFECTIVE_DATE)
   ,P_DATETRACK_MODE
   ,P_INPUT_VALUE_ID
   ,P_OBJECT_VERSION_NUMBER
   ,P_NAME
   ,P_UOM
   ,P_LOOKUP_TYPE
   ,P_FORMULA_ID
   ,P_VALUE_SET_ID
   ,P_DISPLAY_SEQUENCE
   ,P_GENERATE_DB_ITEMS_FLAG
   ,P_HOT_DEFAULT_FLAG
   ,P_MANDATORY_FLAG
   ,P_DEFAULT_VALUE
   ,P_MAX_VALUE
   ,P_MIN_VALUE
   ,P_WARNING_OR_ERROR
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_INPUT_VALUE'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  open csr_derived_values;
  fetch csr_derived_values into l_business_group_id,l_legislation_code,l_element_type_id,l_legislation_subgroup;
  close csr_derived_values;
  --
  -- Process Logic
  --

pay_ivl_upd.upd
  (p_effective_date           => trunc(p_effective_date)
  ,p_datetrack_mode           => p_datetrack_mode
  ,p_input_value_id           => p_input_value_id
  ,p_object_version_number    => p_object_version_number
  ,p_element_type_id          => l_element_type_id
  ,p_display_sequence         => p_display_sequence
  ,p_generate_db_items_flag   => p_generate_db_items_flag
  ,p_hot_default_flag         => p_hot_default_flag
  ,p_mandatory_flag           => p_mandatory_flag
  ,p_name                     => p_name
  ,p_uom                      => p_uom
  ,p_lookup_type              => p_lookup_type
  ,p_business_group_id        => l_business_group_id
  ,p_legislation_code         => l_legislation_code
  ,p_formula_id               => p_formula_id
  ,p_value_set_id             => p_value_set_id
  ,p_default_value            => p_default_value
  ,p_legislation_subgroup     => l_legislation_subgroup
  ,p_max_value                => p_max_value
  ,p_min_value                => p_min_value
  ,p_warning_or_error         => p_warning_or_error
  ,p_effective_start_date     => p_effective_start_date
  ,p_effective_end_date       => p_effective_end_date
  ,p_default_val_warning      => p_default_val_warning
  ,p_min_max_warning          => p_min_max_warning
  ,p_link_inp_val_warning     => p_link_inp_val_warning
  ,p_pay_basis_warning        => p_pay_basis_warning
  ,p_formula_warning          => p_formula_warning
  ,p_assignment_id_warning    => p_assignment_id_warning
  ,p_formula_message          => p_formula_message
  );

  -- Bug 6432304
  -- Moved the DB Item update code from RHI to API to handle Translation issues.

  if pay_ivl_shd.g_old_rec.name <> p_name or pay_ivl_shd.g_old_rec.uom <> p_uom
     or pay_ivl_shd.g_old_rec.generate_db_items_flag <> p_generate_db_items_flag then
     pay_input_values_pkg.recreate_db_items(l_element_type_id);
  end if;

  --
  -- Call After Process User Hook
  --
  begin
    PAY_INPUT_VALUE_bk2.UPDATE_INPUT_VALUE_a
      (P_VALIDATE
   ,trunc(P_EFFECTIVE_DATE)
   ,P_DATETRACK_MODE
   ,P_INPUT_VALUE_ID
   ,P_OBJECT_VERSION_NUMBER
   ,P_NAME
   ,P_UOM
   ,P_LOOKUP_TYPE
   ,P_FORMULA_ID
   ,P_VALUE_SET_ID
   ,P_DISPLAY_SEQUENCE
   ,P_GENERATE_DB_ITEMS_FLAG
   ,P_HOT_DEFAULT_FLAG
   ,P_MANDATORY_FLAG
   ,P_DEFAULT_VALUE
   ,P_MAX_VALUE
   ,P_MIN_VALUE
   ,P_WARNING_OR_ERROR
   ,P_EFFECTIVE_START_DATE
   ,P_EFFECTIVE_END_DATE
   ,P_DEFAULT_VAL_WARNING
   ,P_MIN_MAX_WARNING
   ,P_LINK_INP_VAL_WARNING
   ,P_PAY_BASIS_WARNING
   ,P_FORMULA_WARNING
   ,P_ASSIGNMENT_ID_WARNING
   ,P_FORMULA_MESSAGE
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_INPUT_VALUE'
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
  p_object_version_number  := null;
  p_default_val_warning    := null;
  p_min_max_warning        := null;
  p_link_inp_val_warning   := null;
  p_pay_basis_warning      := null;
  p_formula_warning        := null;
  p_assignment_id_warning  := null;
  p_formula_message        := null;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to UPDATE_INPUT_VALUE;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := p_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to UPDATE_INPUT_VALUE;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end UPDATE_INPUT_VALUE;
--
--
--
-- ----------------------------------------------------------------------------
-- |--------------------------< DELETE_INPUT_VALUE >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_INPUT_VALUE
  (  P_VALIDATE                        IN     boolean   default false
    ,P_EFFECTIVE_DATE                  IN     date
    ,P_DATETRACK_DELETE_MODE           IN     varchar2
    ,P_INPUT_VALUE_ID                  IN     number
    ,P_OBJECT_VERSION_NUMBER           IN OUT NOCOPY number
    ,P_EFFECTIVE_START_DATE            OUT NOCOPY    date
    ,P_EFFECTIVE_END_DATE              OUT NOCOPY    date
    ,P_BALANCE_FEEDS_WARNING           OUT NOCOPY    boolean
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                varchar2(72) := g_package||'DELETE_INPUT_VALUE';
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint DELETE_INPUT_VALUE;
  --
  -- Call Before Process User Hook
  --
  begin
    PAY_INPUT_VALUE_bk3.DELETE_INPUT_VALUE_b
      (P_VALIDATE
    ,trunc(P_EFFECTIVE_DATE)
    ,P_DATETRACK_DELETE_MODE
    ,P_INPUT_VALUE_ID
    ,P_OBJECT_VERSION_NUMBER
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_INPUT_VALUE'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  if P_DATETRACK_DELETE_MODE = 'DELETE' then
    hr_utility.set_message(801,'HR_7098_INPVAL_NO_CHANGES');
    hr_utility.raise_error;
  end if;



  --
  -- Process Logic
  --

  pay_ivl_del.del
  (p_effective_date => trunc(p_effective_date)
  ,p_datetrack_mode => p_datetrack_delete_mode
  ,p_input_value_id => p_input_value_id
  ,p_object_version_number => p_object_version_number
  ,p_effective_start_date => p_effective_start_date
  ,p_effective_end_date => p_effective_end_date
  ,p_balance_feeds_warning => p_balance_feeds_warning);

  --
  -- Call After Process User Hook
  --
  begin
    PAY_INPUT_VALUE_bk3.DELETE_INPUT_VALUE_a
      ( P_VALIDATE
	,trunc(P_EFFECTIVE_DATE)
	,P_DATETRACK_DELETE_MODE
	,P_INPUT_VALUE_ID
	,P_OBJECT_VERSION_NUMBER
	,P_EFFECTIVE_START_DATE
	,P_EFFECTIVE_END_DATE
	,p_balance_feeds_warning
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_INPUT_VALUE'
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
  p_object_version_number  := p_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to DELETE_INPUT_VALUE;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := null;
    p_balance_feeds_warning  := null;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to DELETE_INPUT_VALUE;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end DELETE_INPUT_VALUE;
--
end PAY_INPUT_VALUE_API;

/
