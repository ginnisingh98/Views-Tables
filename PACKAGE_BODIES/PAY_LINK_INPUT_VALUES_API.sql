--------------------------------------------------------
--  DDL for Package Body PAY_LINK_INPUT_VALUES_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_LINK_INPUT_VALUES_API" as
/* $Header: pylivapi.pkb 115.4 2003/01/29 11:57:01 scchakra noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  PAY_LIV_API.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< create_liv_internal >---------------------------|
-- ----------------------------------------------------------------------------
--
procedure CREATE_LIV_INTERNAL
  (p_effective_date             in   date
  ,p_element_link_id            in   number
  ,p_input_value_id             in   number
  ,p_costed_flag                in   varchar2
  ,p_default_value              in   varchar2
  ,p_max_value                  in   varchar2
  ,p_min_value                  in   varchar2
  ,p_warning_or_error           in   varchar2
  ,p_link_input_value_id        out  nocopy number
  ,p_effective_start_date       out  nocopy date
  ,p_effective_end_date         out  nocopy date
  ,p_object_version_number      out  nocopy number
  ,p_pay_basis_warning          out  nocopy boolean
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                  varchar2(72) := g_package||'create_liv_internal';
  l_effective_date        date;
  l_effective_start_date  date;
  l_effective_end_date    date;
  l_exists                varchar2(1);
  l_rec                   pay_input_values_f%rowtype;
  l_costable_type         pay_element_links_f.costable_type%type;
  l_default_value         pay_link_input_values_f.default_value%type;
  l_max_value             pay_link_input_values_f.max_value%type;
  l_min_value             pay_link_input_values_f.min_value%type;
  l_warning_or_error      pay_link_input_values_f.warning_or_error%type;
  l_costed_flag           pay_link_input_values_f.costed_flag%type;
  l_link_input_value_id   pay_link_input_values_f.link_input_value_id%type;
  l_object_version_number pay_link_input_values_f.object_version_number%type;


  Cursor C_input_values
  is
    select *
      from pay_input_values_f
     where input_value_id = p_input_value_id
       and p_effective_date between effective_start_date
       and effective_end_date;

  Cursor C_costable_type
  is
    select costable_type
      from pay_element_links_f
     where element_link_id = p_element_link_id
       and p_effective_date between effective_start_date
       and effective_end_date;

  Cursor c_pay_basis
  is
    select null
      from per_pay_bases
     where input_value_id = p_input_value_id;

  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Validation in addition to Row Handlers
  --
  Open C_Input_values;
  Fetch C_Input_values Into l_rec;
  Close C_Input_values;
  --
  -- Set the defaults for the Input Values
  --
  If l_rec.hot_default_flag = 'Y' Then
     l_default_value    := null;
     l_max_value        := null;
     l_min_value        := null;
     l_warning_or_error := null;
  Else
     l_default_value    := l_rec.default_value;
     l_max_value        := l_rec.max_value;
     l_min_value        := l_rec.min_value;
     l_warning_or_error := l_rec.warning_or_error;
  End if;

  Open C_costable_type;
  Fetch C_costable_type into l_costable_type;
  Close C_costable_type;

  l_costed_flag := p_costed_flag;
  --
  -- Set the default for costed flag depending on costable_type of
  -- element link.
  --

  If (upper(l_rec.name) = 'PAY VALUE' and
     (l_costable_type in ('C','F','D'))) Then
       l_costed_flag := 'Y';
  End if;
  --
  -- Raise a warning if the input value is a pay basis for the element.
  --
  Open c_pay_basis;
  Loop
    Fetch c_pay_basis into l_exists;
    If c_pay_basis%found then
      p_pay_basis_warning := True;
    Else
      exit;
    End if;
  End Loop;
  Close c_pay_basis;
  --
  -- Process Logic
  --
  pay_liv_ins.ins
    (p_effective_date           => l_effective_date
    ,p_element_link_id          => p_element_link_id
    ,p_input_value_id           => p_input_value_id
    ,p_costed_flag              => l_costed_flag
    ,p_default_value            => l_default_value
    ,p_max_value                => l_max_value
    ,p_min_value                => l_min_value
    ,p_warning_or_error         => l_warning_or_error
    ,p_link_input_value_id      => l_link_input_value_id
    ,p_object_version_number    => l_object_version_number
    ,p_effective_start_date     => l_effective_start_date
    ,p_effective_end_date       => l_effective_end_date
    );
  --
  -- Set all output arguments
  --
  p_link_input_value_id    := l_link_input_value_id;
  p_object_version_number  := l_object_version_number;
  p_effective_start_date   := l_effective_start_date;
  p_effective_end_date     := l_effective_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);

end CREATE_LIV_INTERNAL;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< update_link_input_values >----------------------|
-- ----------------------------------------------------------------------------
--
procedure UPDATE_LINK_INPUT_VALUES
  (p_validate                   in      boolean
  ,p_effective_date             in      date
  ,p_datetrack_update_mode      in      varchar2
  ,p_link_input_value_id        in      number
  ,p_object_version_number      in out  nocopy number
  ,p_costed_flag                in      varchar2
  ,p_default_value              in      varchar2
  ,p_max_value                  in      varchar2
  ,p_min_value                  in      varchar2
  ,p_warning_or_error           in      varchar2
  ,p_effective_start_date       out     nocopy date
  ,p_effective_end_date         out     nocopy date
  ,p_pay_basis_warning          out     nocopy boolean
  ,p_default_range_warning      out     nocopy boolean
  ,p_default_formula_warning    out     nocopy boolean
  ,p_assignment_id_warning      out     nocopy boolean
  ,p_formula_message            out     nocopy varchar2
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                     varchar2(72) := g_package||'update_liv';
  l_effective_date           date;
  l_effective_end_date       date;
  l_effective_start_date     date;
  l_exists                   varchar2(1);
  l_default_range_warning    boolean;
  l_default_formula_warning  boolean;
  l_assignment_id_warning    boolean;
  l_formula_message          fnd_new_messages.message_text%type;
  l_default_value            pay_link_input_values_f.default_value%type := p_default_value;
  l_element_link_id          pay_link_input_values_f.element_link_id%type;
  l_input_value_id           pay_link_input_values_f.input_value_id%type;
  l_object_version_number    pay_link_input_values_f.object_version_number%type;
  l_lookup_type              hr_lookups.lookup_type%type;

  Cursor c_link_input_value_id
  is
    select element_link_id, input_value_id
      from pay_link_input_values_f
     where link_input_value_id = p_link_input_value_id
       and p_effective_date between effective_start_date
       and effective_end_date;

  Cursor c_pay_basis
  is
    select null
      from per_pay_bases
     where input_value_id = l_input_value_id;

  Cursor c_lookup_type(p_input_value_id   number)
  is
    select lookup_type
      from pay_input_values_f
     where input_value_id = p_input_value_id
       and p_effective_date between effective_start_date
       and effective_end_date;

  Cursor c_lookup_code(p_lookup_type      varchar2)
  is
    select lookup_code
      from hr_lookups
     where lookup_type = p_lookup_type
       and upper(meaning) = p_default_value
       and enabled_flag = 'Y'
       and p_effective_date between nvl(start_date_active, p_effective_date)
       and nvl(end_date_active, p_effective_date);

  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint update_link_input_values;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Initialize all IN/OUT parameters
  --
  l_object_version_number := p_object_version_number;
  --
  -- Check all the mandatory parameters are specified.
  --
  If (nvl(p_link_input_value_id,hr_api.g_number) = hr_api.g_number) then
    hr_api.mandatory_arg_error
          (p_api_name       => l_proc
          ,p_argument       => 'link_input_value_id'
          ,p_argument_value => p_link_input_value_id
          );
  End if;

  --
  -- Get the element_link_id and input_value_id.
  --
  Open C_link_input_value_id;
  Fetch C_link_input_value_id into l_element_link_id, l_input_value_id;
  If C_link_input_value_id%notfound then
     Close C_link_input_value_id;
     --
     -- The primary key is invalid
     --
     fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
     fnd_message.raise_error;
  End if;
  Close C_link_input_value_id;
  --
  -- Get the lookup code for the default value
  --
  Open c_lookup_type(l_input_value_id);
  Fetch c_lookup_type into l_lookup_type;
  Close c_lookup_type;

  If l_lookup_type is not null and p_default_value is not null then
    --
    Open c_lookup_code(l_lookup_type);
    Fetch c_lookup_code into l_default_value;
    Close c_lookup_code;
    --
    -- Raise error is lookup validation fails.
    --
    If l_default_value is null then
     fnd_message.set_name('PAY', 'PAY_6171_INPVAL_NO_LOOKUP');
     fnd_message.raise_error;
    End if;
  End if;
  --
  -- Call Before Process User Hook
  --
  begin
    PAY_LINK_INPUT_VALUES_BK1.update_link_input_values_b
      (p_effective_date         => l_effective_date
      ,p_datetrack_update_mode  => p_datetrack_update_mode
      ,p_link_input_value_id    => p_link_input_value_id
      ,p_element_link_id        => l_element_link_id
      ,p_input_value_id         => l_input_value_id
      ,p_costed_flag            => p_costed_flag
      ,p_default_value          => l_default_value
      ,p_max_value              => p_max_value
      ,p_min_value              => p_min_value
      ,p_warning_or_error       => p_warning_or_error
      ,p_object_version_number  => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_LINK_INPUT_VALUES'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  --
  -- Raise a warning if the input value is a pay basis for the element.
  --
  Open c_pay_basis;
  Fetch c_pay_basis into l_exists;
  If c_pay_basis%found then
    p_pay_basis_warning := true;
  Else
    p_pay_basis_warning := false;
  End if;
  Close c_pay_basis;
  --
  -- Process Logic
  --
  pay_liv_upd.upd
    (p_effective_date           => l_effective_date
    ,p_datetrack_mode           => p_datetrack_update_mode
    ,p_element_link_id          => l_element_link_id
    ,p_input_value_id           => l_input_value_id
    ,p_costed_flag              => p_costed_flag
    ,p_default_value            => l_default_value
    ,p_max_value                => p_max_value
    ,p_min_value                => p_min_value
    ,p_warning_or_error         => p_warning_or_error
    ,p_link_input_value_id      => p_link_input_value_id
    ,p_object_version_number    => l_object_version_number
    ,p_effective_start_date     => l_effective_start_date
    ,p_effective_end_date       => l_effective_end_date
    ,p_default_range_warning    => l_default_range_warning
    ,p_default_formula_warning  => l_default_formula_warning
    ,p_assignment_id_warning    => l_assignment_id_warning
    ,p_formula_message          => l_formula_message
    );
  --
  -- Call After Process User Hook
  --
  begin
    PAY_LINK_INPUT_VALUES_BK1.update_link_input_values_a
      (p_effective_date          => l_effective_date
      ,p_datetrack_update_mode   => p_datetrack_update_mode
      ,p_link_input_value_id     => p_link_input_value_id
      ,p_element_link_id         => l_element_link_id
      ,p_input_value_id          => l_input_value_id
      ,p_costed_flag             => p_costed_flag
      ,p_default_value           => l_default_value
      ,p_max_value               => p_max_value
      ,p_min_value               => p_min_value
      ,p_warning_or_error        => p_warning_or_error
      ,p_effective_start_date    => l_effective_start_date
      ,p_effective_end_date      => l_effective_end_date
      ,p_object_version_number   => l_object_version_number
      ,p_pay_basis_warning       => p_pay_basis_warning
      ,p_default_range_warning   => l_default_range_warning
      ,p_default_formula_warning => l_default_formula_warning
      ,p_assignment_id_warning   => l_assignment_id_warning
      ,p_formula_message         => l_formula_message
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_LINK_INPUT_VALUES'
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
  p_object_version_number   := l_object_version_number;
  p_effective_start_date    := l_effective_start_date;
  p_effective_end_date      := l_effective_end_date;
  p_default_range_warning   := l_default_range_warning;
  p_default_formula_warning := l_default_formula_warning;
  p_assignment_id_warning   := l_assignment_id_warning;
  p_formula_message         := l_formula_message;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to update_link_input_values;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := p_object_version_number;
    p_effective_start_date   := null;
    p_effective_end_date     := null;

    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to update_link_input_values;
    p_object_version_number      := p_object_version_number;
    p_effective_start_date       := null;
    p_effective_end_date         := null;
    p_pay_basis_warning          := null;
    p_default_range_warning      := null;
    p_default_formula_warning    := null;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;

end UPDATE_LINK_INPUT_VALUES;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------< delete_link_input_values >----------------------|
-- ----------------------------------------------------------------------------
--
procedure DELETE_LINK_INPUT_VALUES
  (p_validate                   in      boolean
  ,p_effective_date             in      date
  ,p_datetrack_delete_mode      in      varchar2
  ,p_link_input_value_id        in      number
  ,p_effective_start_date       out     nocopy date
  ,p_effective_end_date         out     nocopy date
  ,p_object_version_number      in out  nocopy number
  ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                  varchar2(72) := g_package||'delete_liv';
  l_effective_date        date;
  l_effective_end_date    date;
  l_effective_start_date  date;
  l_object_version_number pay_link_input_values_f.object_version_number%type;

begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint
  --
  savepoint delete_link_input_values;
  --
  -- Truncate the time portion from all IN date parameters
  --
  l_effective_date := trunc(p_effective_date);
  --
  -- Initialize all IN/OUT parameters
  --
  l_object_version_number := p_object_version_number;
  --
  -- Call Before Process User Hook
  --
  begin
    PAY_LINK_INPUT_VALUES_BK2.delete_link_input_values_b
      (p_effective_date          => l_effective_date
      ,p_datetrack_delete_mode   => p_datetrack_delete_mode
      ,p_link_input_value_id     => p_link_input_value_id
      ,p_object_version_number   => l_object_version_number
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_LINK_INPUT_VALUES'
        ,p_hook_type   => 'BP'
        );
  end;
  --
  -- Validation in addition to Row Handlers
  --
  -- An error is raised if the datetrack_delete_mode is either 'ZAP' or
  -- 'DELETE' when this API is executed as a stand alone procedure.
  --
  If p_datetrack_delete_mode in ('ZAP','DELETE') then
    fnd_message.set_name('PAY','HR_7098_INPVAL_NO_CHANGES');
    fnd_message.raise_error;
  End if;
  --
  -- Process Logic
  --
  pay_liv_del.del
    (p_effective_date           => l_effective_date
    ,p_datetrack_mode           => p_datetrack_delete_mode
    ,p_link_input_value_id      => p_link_input_value_id
    ,p_object_version_number    => l_object_version_number
    ,p_effective_start_date     => l_effective_start_date
    ,p_effective_end_date       => l_effective_end_date
    );
  --
  -- Call After Process User Hook
  --
  begin
    PAY_LINK_INPUT_VALUES_BK2.delete_link_input_values_a
      (p_effective_date          => p_effective_date
      ,p_datetrack_delete_mode   => p_datetrack_delete_mode
      ,p_link_input_value_id     => p_link_input_value_id
      ,p_object_version_number   => l_object_version_number
      ,p_effective_start_date    => l_effective_start_date
      ,p_effective_end_date      => l_effective_end_date
      );
  exception
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'DELETE_LINK_INPUT_VALUES'
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
  p_effective_start_date   := l_effective_start_date;
  p_effective_end_date     := l_effective_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    rollback to delete_link_input_values;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    p_object_version_number  := p_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 80);
  when others then
    --
    -- A validation or unexpected error has occured
    --
    rollback to delete_link_input_values;
    p_effective_start_date   := null;
    p_effective_end_date     := null;
    p_object_version_number  := p_object_version_number;
    hr_utility.set_location(' Leaving:'||l_proc, 90);
    raise;
end DELETE_LINK_INPUT_VALUES;

end PAY_LINK_INPUT_VALUES_API;

/
