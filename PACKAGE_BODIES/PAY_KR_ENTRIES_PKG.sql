--------------------------------------------------------
--  DDL for Package Body PAY_KR_ENTRIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_KR_ENTRIES_PKG" as
/* $Header: pykretr.pkb 120.7.12010000.2 2008/11/26 16:22:34 vaisriva ship $ */

--
-- Constant values to store element name
--
c_tax_en      constant pay_element_types_f.element_name%TYPE := 'TAX';
c_hi_prem_en  constant pay_element_types_f.element_name%TYPE := 'HI_PREM';
c_np_prem_en  constant pay_element_types_f.element_name%TYPE := 'NP_PREM';

-- Global record definition
g_old_rec pay_element_entries_f%ROWTYPE;

-- Global package name
g_package varchar2(33) := ' pay_kr_entries_pkg.';
g_debug   boolean      := hr_utility.debug_enabled;


-- ---------------------------------------------------------------------
-- |------------------------< calc_age >-------------------------------|
-- ---------------------------------------------------------------------
--
function calc_age
(
  p_national_identifier in varchar2,
  p_date_of_birth       in date,
  p_effective_date      in date
)
return number
is
l_age   number;
l_date  varchar2(10);
begin

  if p_national_identifier is null then
    l_age := trunc(
               months_between( p_effective_date, p_date_of_birth )/12 );
    return l_age;
  end if;

-- Modified for Bug2734338
-- The usage of the number 5,6,7,8 are changed to identify Foreigner
--
  select decode( substr( p_national_identifier, 8, 1 ),
                 '1', '19', '2', '19',
                 '3', '20', '4', '20',
                 '5', '19', '6', '19',
                 '7', '20', '8', '20',
                 '9', '18', '0', '18', '19' )
         || substr( p_national_identifier, 1, 6 )
  into l_date
  from sys.dual;

  l_age := trunc( months_between( p_effective_date,
                                  to_date( l_date, 'YYYYMMDD' ))/12 );
  return l_age;

end;
-- ---------------------------------------------------------------------
-- |------------------------< element_name >---------------------------|
-- ---------------------------------------------------------------------
--
-- This function returns element_name corresponding to element_code.
-- This is temporary solution in R11i.
--
function element_name
(
  p_element_code in varchar2
)
return varchar2
is
l_element_name pay_element_types_f.element_name%TYPE;
begin
  if p_element_code = 'TAX' then
    l_element_name := c_tax_en;
  elsif p_element_code = 'HI_PREM' then
    l_element_name := c_hi_prem_en;
  elsif p_element_code = 'NP_PREM' then
    l_element_name := c_np_prem_en;
  end if;

  return  l_element_name;

end element_name;

-- ---------------------------------------------------------------------
-- |------------------------< element_type_rec >-----------------------|
-- ---------------------------------------------------------------------
--
function element_type_rec
(
  p_element_name         in varchar2,
  p_business_group_id    in number   default null,
  p_effective_date       in date     default hr_api.g_sys
) return PAY_ELEMENT_TYPES_F%ROWTYPE
is

l_legislation_code varchar2(30);
l_element_type_rec pay_element_types_f%rowtype;

cursor csr( p_element_name      varchar2,
            p_business_group_id number,
            p_legislation_code  varchar2,
            p_effective_date    date ) is
select *
from   pay_element_types_f pet
where  pet.element_name = p_element_name
and    p_effective_date between pet.effective_start_date
                            and pet.effective_end_date
and    ( pet.legislation_code = p_legislation_code
      or pet.business_group_id = p_business_group_id);

begin
  l_legislation_code
    := hr_api.return_legislation_code(p_business_group_id);

  open csr( p_element_name,
            p_business_group_id,
            l_legislation_code,
            p_effective_date );
  fetch csr into l_element_type_rec;

  if csr%notfound then
    l_element_type_rec.element_type_id := null;
  end if;

  close csr;

  return l_element_type_rec;
end;

-- ---------------------------------------------------------------------
-- |------------------------< derive_attributes >----------------------|
-- ---------------------------------------------------------------------
--
-- This procedure returns element and input value attributes for
-- p_elm_code_tbl input parameters like INPUT_CURRENCY_CODE, UOM etc.
-- p_business_group_id must be not null.
--
procedure derive_attributes
(
  p_elm_code_tbl      in  elm_code_tbl,
  p_effective_date    in  date,
  p_business_group_id in  number,
  p_elm_rec_tbl       out NOCOPY elm_rec_tbl,
  p_iv_rec_tbl        out NOCOPY iv_rec_tbl
)
is

l_index    number;
l_elm_rec  pay_element_types_f%ROWTYPE;

cursor csr_iv( p_element_type_id number ) is
select piv.input_value_id,
       piv.display_sequence,
       piv.uom,
       piv.mandatory_flag
from   pay_input_values_f piv
where  piv.element_type_id = p_element_type_id
and    p_effective_date between piv.effective_start_date
                            and piv.effective_end_date;

begin
  l_index := p_elm_code_tbl.first;
  --
  -- Fetch element attributes.
  --
  while l_index is not NULL loop
/*
    l_elm_rec := hr_jp_id_pkg.element_type_rec(
                   element_name(p_elm_code_tbl(l_index)),
                   p_business_group_id,
                   NULL,
                   p_effective_date,
                   'FALSE');
*/
    l_elm_rec := element_type_rec(
                   element_name(p_elm_code_tbl(l_index)),
                   p_business_group_id,
                   p_effective_date);
    --
    -- When not found, raise error.
    --
    if l_elm_rec.element_type_id is NULL then
      hr_utility.set_message(801,'HR_7478_PLK_INCONSISTENT_ELE');
      hr_utility.set_message_token('ELEMENT_TYPE_ID',NULL);
      hr_utility.set_message_token('ELEMENT_NAME',
                                            p_elm_code_tbl(l_index));
      hr_utility.raise_error;
    else
      p_elm_rec_tbl(l_elm_rec.element_type_id).element_code
        := p_elm_code_tbl(l_index);
      p_elm_rec_tbl(l_elm_rec.element_type_id).input_currency_code
        := l_elm_rec.input_currency_code;
      p_elm_rec_tbl(l_elm_rec.element_type_id).multiple_entries_allowed_flag  := l_elm_rec.multiple_entries_allowed_flag;
    end if;
    --
    -- Fetch input value attributes.
    --
    for l_rec in csr_iv(l_elm_rec.element_type_id) loop
      p_iv_rec_tbl(l_rec.input_value_id).element_type_id
        := l_elm_rec.element_type_id;
      p_iv_rec_tbl(l_rec.input_value_id).display_sequence
        := l_rec.display_sequence;
      p_iv_rec_tbl(l_rec.input_value_id).uom := l_rec.uom;
      p_iv_rec_tbl(l_rec.input_value_id).mandatory_flag
        := l_rec.mandatory_flag;
    end loop;
    --
    -- Increment counter.
    --
    l_index := p_elm_code_tbl.next(l_index);
  end loop;

end derive_attributes;

-- ---------------------------------------------------------------------
-- |------------------------< derive_format_mask >---------------------|
-- ---------------------------------------------------------------------
--
-- Derive format mask for p_iv_rec_tbl input parameter.
-- This procedure is designed to reduce network traffic because
-- fnd_currency.get_format_mask function accesses to DB.
--
procedure derive_format_mask
(
  p_elm_rec_tbl in     elm_rec_tbl,
  p_iv_rec_tbl  in out NOCOPY iv_rec_tbl
)
is
l_index number;
begin

  l_index := p_iv_rec_tbl.first;

  while l_index is not NULL loop
    --
    -- Only supported with uom = 'M'(Money) currently.
    --
    if p_iv_rec_tbl(l_index).uom = 'M' then
      if p_iv_rec_tbl(l_index).max_length is not NULL then
        p_iv_rec_tbl(l_index).format_mask
          := fnd_currency.get_format_mask(
                  p_elm_rec_tbl(p_iv_rec_tbl(l_index).element_type_id).input_currency_code,
                  p_iv_rec_tbl(l_index).max_length);
      end if;
    end if;
    --
    -- Increment counter.
    --
    l_index := p_iv_rec_tbl.next(l_index);
  end loop;

end derive_format_mask;

-- ---------------------------------------------------------------------
-- |-----------------------------< chk_entry >-------------------------|
-- ---------------------------------------------------------------------
--
-- This procedure checks entry can be created or not.
-- This is interface for hr_entry.check_element_entry procedure.
--
procedure chk_entry
(
  p_element_entry_id      in     number,
  p_assignment_id         in     number,
  p_element_link_id       in     number,
  p_entry_type            in     varchar2,
  p_original_entry_id     in     number   default null,
  p_target_entry_id       in     number   default null,
  p_effective_date        in     date,
  p_validation_start_date in     date,
  p_validation_end_date   in     date,
  p_effective_start_date  in out NOCOPY date,
  p_effective_end_date    in out NOCOPY date,
  p_usage                 in     varchar2,
  p_dt_update_mode        in     varchar2,
  p_dt_delete_mode        in     varchar2
)
is
begin
  hr_entry.chk_element_entry(
    p_element_entry_id      => p_element_entry_id,
    p_original_entry_id     => p_original_entry_id,
    p_session_date          => p_effective_date,
    p_element_link_id       => p_element_link_id,
    p_assignment_id         => p_assignment_id,
    p_entry_type            => p_entry_type,
    p_effective_start_date  => p_effective_start_date,
    p_effective_end_date    => p_effective_end_date,
    p_validation_start_date => p_validation_start_date,
    p_validation_end_date   => p_validation_end_date,
    p_dt_update_mode        => p_dt_update_mode,
    p_dt_delete_mode        => p_dt_delete_mode,
    p_usage                 => p_usage,
    p_target_entry_id       => p_target_entry_id
  );

end chk_entry;

-- ---------------------------------------------------------------------
-- |---------------------< derive_default_values >---------------------|
-- ---------------------------------------------------------------------
--
-- This procedure derive default values
-- for p_element_code input parameter.
--
procedure derive_default_values
(
  p_assignment_id        in            number,
  p_element_code         in            varchar2,
  p_business_group_id    in            varchar2,
  p_entry_type           in            varchar2,
  p_element_link_id      out NOCOPY    number,
  p_ev_rec_tbl           out NOCOPY    ev_rec_tbl,
  p_effective_date       in            date,
  p_effective_start_date in out NOCOPY date,
  p_effective_end_date   in out NOCOPY date
)
is

l_element_type_id  number;
l_element_type_rec pay_element_types_f%rowtype;
l_counter          number;

cursor csr_default_value is
select piv.input_value_id,
       piv.display_sequence,
       decode(piv.hot_default_flag,
         'Y',nvl(pliv.default_value,piv.default_value),
         pliv.default_value)  DEFAULT_VALUE,
       decode(piv.lookup_type,NULL,NULL,
         hr_general.decode_lookup(
           piv.lookup_type,
           decode(piv.hot_default_flag,
           'Y',nvl(pliv.default_value,piv.default_value),
           pliv.default_value)))  D_DEFAULT_VALUE
from  pay_input_values_f      piv,
      pay_link_input_values_f pliv
where pliv.element_link_id = p_element_link_id
and   p_effective_date between pliv.effective_start_date
                           and pliv.effective_end_date
and   piv.input_value_id = pliv.input_value_id
and   p_effective_date between piv.effective_start_date
                           and piv.effective_end_date
order by piv.display_sequence;

begin
  --
  -- Fetch eligible element_link_id for the assignment.
  --
  l_element_type_rec := element_type_rec(
                          element_name(p_element_code),
                          p_business_group_id,
                          p_effective_date);
  l_element_type_id := l_element_type_rec.element_type_id;
/*
  l_element_type_id := hr_jp_id_pkg.element_type_id(
                      element_name(p_element_code),p_business_group_id);
*/
  p_element_link_id := hr_entry_api.get_link(
                         p_assignment_id   => p_assignment_id,
                         p_element_type_id => l_element_type_id,
                         p_session_date    => p_effective_date);
  if p_element_link_id is NULL then
    hr_utility.set_message(801,'HR_7027_ELE_ENTRY_EL_NOT_EXST');
    hr_utility.set_message_token('DATE',
                        fnd_date.date_to_displaydate(p_effective_date));
    hr_utility.raise_error;
  end if;
  --
  -- At first, checks whether the entry is available.
  --
  chk_entry(
    p_element_entry_id      => NULL,
    p_assignment_id         => p_assignment_id,
    p_element_link_id       => p_element_link_id,
    p_entry_type            => p_entry_type,
    p_effective_date        => p_effective_date,
    p_validation_start_date => NULL,
    p_validation_end_date   => NULL,
    p_effective_start_date  => p_effective_start_date,
    p_effective_end_date    => p_effective_end_date,
    p_usage                 => 'INSERT',
    p_dt_update_mode        => NULL,
    p_dt_delete_mode        => NULL);
  --
  -- If entry is available, fetch default values.
  -- Must initialize varray variables.
  --
  l_counter := 0;
  for l_rec in csr_default_value loop
    l_counter := l_counter + 1;
    p_ev_rec_tbl(l_counter).input_value_id := l_rec.input_value_id;
    p_ev_rec_tbl(l_counter).entry_value    := l_rec.default_value;
    p_ev_rec_tbl(l_counter).d_entry_value  := l_rec.d_default_value;
  end loop;

end derive_default_values;

-- ---------------------------------------------------------------------
-- |-----------------------------< chk_formula >-----------------------|
-- ---------------------------------------------------------------------
--
-- This procedure execute formula validation for input value.
--
procedure chk_formula
(
  p_formula_id        in  number,
  p_entry_value       in  varchar2,
  p_business_group_id in  number,
  p_assignment_id     in  number,
  p_date_earned       in  date,
  p_formula_status    out NOCOPY varchar2,
  p_formula_message   out NOCOPY varchar2
)
is

l_counter number := 0;
l_inputs  ff_exec.inputs_t;
l_outputs ff_exec.outputs_t;

cursor csr_fdi is
select item_name                                            NAME,
       decode(data_type,'T','TEXT','N','NUMBER','D','DATE') DATATYPE,
       decode(usage,'U','CONTEXT','INPUT')                  CLASS
from   ff_fdi_usages_f
where  formula_id = p_formula_id
and    p_date_earned between effective_start_date
                         and effective_end_date;
begin
  --
  -- Initialize formula informations.
  --
  ff_exec.init_formula(
      p_formula_id     => p_formula_id,
      p_effective_date => p_date_earned,
      p_inputs         => l_inputs,
      p_outputs        => l_outputs
  );
  --
  -- Setup input variables.
  --
  l_counter := l_inputs.first;
  while l_counter is not NULL loop
    if l_inputs(l_counter).name = 'BUSINESS_GROUP_ID' then
      l_inputs(l_counter).value := fnd_number.number_to_canonical(p_business_group_id);
    elsif l_inputs(l_counter).name = 'ASSIGNMENT_ID' then
      l_inputs(l_counter).value := fnd_number.number_to_canonical(p_assignment_id);
    elsif l_inputs(l_counter).name = 'DATE_EARNED' then
      l_inputs(l_counter).value := fnd_date.date_to_canonical(p_date_earned);
    elsif l_inputs(l_counter).name = 'ENTRY_VALUE' then
      l_inputs(l_counter).value := p_entry_value;
    end if;
    l_counter := l_inputs.next(l_counter);
  end loop;
  --
  -- Execute formula. Formula unexpected error is raised by ffexec,
  -- so not necessary to handle error.
  --
  ff_exec.run_formula(
      p_inputs        => l_inputs,
      p_outputs       => l_outputs,
      p_use_dbi_cache => FALSE
  );
  --
  -- Setup output variables.
  --
  l_counter := l_outputs.first;
  while l_counter is not NULL loop
    if l_outputs(l_counter).name = 'FORMULA_STATUS' then
      p_formula_status := l_outputs(l_counter).value;
    elsif l_outputs(l_counter).name = 'FORMULA_MESSAGE' then
      p_formula_message := l_outputs(l_counter).value;
    end if;
    l_counter := l_outputs.next(l_counter);
  end loop;

end chk_formula;

-- ---------------------------------------------------------------------
-- |---------------------------< chk_entry_value >---------------------|
-- ---------------------------------------------------------------------
--
-- This function can not validate "user enterable flag".
-- Never call this procedure when p_display_value is NULL on Forms
-- WHEN-VALIDATE-ITEM trigger which will raise unexpected error.
-- Remeber hot defaulted value is not validated.
--
procedure chk_entry_value
(
  p_element_link_id   in            number,
  p_input_value_id    in            number,
  p_effective_date    in            date,
  p_business_group_id in            number,
  p_assignment_id     in            number,
  p_user_value        in out NOCOPY varchar2,
  p_canonical_value   out    NOCOPY varchar2,
  p_hot_defaulted     out    NOCOPY boolean,
  p_min_max_warning   out    NOCOPY boolean,
  p_user_min_value    out    NOCOPY varchar2,
  p_user_max_value    out    NOCOPY varchar2,
  p_formula_warning   out    NOCOPY boolean,
  p_formula_message   out    NOCOPY varchar2
)
is

l_min_max_status varchar2(1);
l_formula_status varchar2(1);

cursor csr_iv is
select pivtl.name,
       piv.uom,
       piv.mandatory_flag,
       piv.hot_default_flag,
       piv.lookup_type,
       decode(piv.hot_default_flag,
          'Y',nvl(pliv.default_value,piv.default_value),
          pliv.default_value)  DEFAULT_VALUE,
       decode(piv.hot_default_flag,
          'Y',nvl(pliv.min_value,piv.min_value),
          pliv.min_value)    MIN_VALUE,
       decode(piv.hot_default_flag,
          'Y',nvl(pliv.max_value,piv.max_value),
          pliv.max_value)    MAX_VALUE,
       piv.formula_id,
       decode(piv.hot_default_flag,
          'Y',nvl(pliv.warning_or_error,piv.warning_or_error),
          pliv.warning_or_error)  WARNING_OR_ERROR,
       pet.input_currency_code
from   pay_element_types_f     pet,
       pay_input_values_f_tl   pivtl,
       pay_input_values_f      piv,
       pay_link_input_values_f pliv
where  pliv.element_link_id = p_element_link_id
and    pliv.input_value_id = p_input_value_id
and    p_effective_date between pliv.effective_start_date
                            and pliv.effective_end_date
and    piv.input_value_id = pliv.input_value_id
and    p_effective_date between piv.effective_start_date
                            and piv.effective_end_date
and    pivtl.input_value_id = piv.input_value_id
and    pivtl.language = userenv('LANG')
and    pet.element_type_id = piv.element_type_id
and    p_effective_date between pet.effective_start_date
                            and pet.effective_end_date;

l_rec   csr_iv%ROWTYPE;
l_d_uom hr_lookups.meaning%TYPE;

begin
  --
  -- Initialize output variables.
  --
  p_canonical_value := NULL;
  p_hot_defaulted   := FALSE;
  p_min_max_warning := FALSE;
  p_user_min_value  := NULL;
  p_user_max_value  := NULL;
  p_formula_warning := FALSE;
  p_formula_message := NULL;

  if p_input_value_id is NULL then
    p_user_value := NULL;
    return;
  end if;
  --
  -- Fetch input value attributes.
  --
  open csr_iv;
  fetch csr_iv into l_rec;
  if csr_iv%NOTFOUND then
    close csr_iv;
    hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE','hr_entry.check_format');
    hr_utility.set_message_token('STEP','1');
    hr_utility.raise_error;
  end If;
  close csr_iv;
  --
  -- When user entered value is NULL.
  --
  if p_user_value is NULL then
    --
    -- Mandatory Validation.
    --
    if l_rec.mandatory_flag = 'Y' then
      --
      -- When not hot defaulted.
      --
      if l_rec.hot_default_flag = 'N' then
        hr_utility.set_message(801,'HR_6127_ELE_ENTRY_VALUE_MAND');
        hr_utility.set_message_token('INPUT_VALUE_NAME',l_rec.name);
        hr_utility.raise_error;
      end if;
      --
      -- When hot defaulted.
      --
      if l_rec.default_value is NULL then
        hr_utility.set_message(801,'HR_6128_ELE_ENTRY_MAND_HOT');
        hr_utility.set_message_token('INPUT_VALUE_NAME',l_rec.name);
        hr_utility.raise_error;
      end if;

      p_canonical_value := l_rec.default_value;
      hr_chkfmt.changeformat(
        input   => p_canonical_value,
        output  => p_user_value,
        format  => l_rec.uom,
        curcode => l_rec.input_currency_code
      );
    end if;
  end if;
  --
  -- When p_user_value is not NULL.
  -- Hot defaulted value is validated again in the following routine.
  --
  if p_user_value is not NULL then
    --
    -- Check format validation(format, min and max validations).
    -- Hot defaulted value is validated again for range validation.
    --
    begin
      hr_chkfmt.checkformat(
        value   => p_user_value,
        format  => l_rec.uom,
        output  => p_canonical_value,
        minimum => l_rec.min_value,
        maximum => l_rec.max_value,
        nullok  => 'Y',
        rgeflg  => l_min_max_status,
        curcode => l_rec.input_currency_code
      );
    exception
      --
      -- In case the value input is incorrect format.
      --
      when others then
        l_d_uom := hr_general.decode_lookup('UNITS',l_rec.uom);
        hr_utility.set_message(801,'PAY_6306_INPUT_VALUE_FORMAT');
        hr_utility.set_message_token('UNIT_OF_MEASURE',l_d_uom);
        hr_utility.raise_error;
    end;
    --
    -- Format min_value and max_value for output parameters.
    -- These parameters should be used for message only.
    --
    if l_rec.min_value is not NULL then
      hr_chkfmt.changeformat(
        input   => l_rec.min_value,
        output  => p_user_min_value,
        format  => l_rec.uom,
        curcode => l_rec.input_currency_code
      );
    end if;

    if l_rec.max_value is not NULL then
      hr_chkfmt.changeformat(
        input   => l_rec.max_value,
        output  => p_user_max_value,
        format  => l_rec.uom,
        curcode => l_rec.input_currency_code
      );
    end if;
    --
    -- If warning_or_error= E'(Error) and l_min_max_status='F'(Fatal),
    -- then raise error. In case of 'W'(Warning), Forms should warn
    --  to user with fnd_message.warn procedure.
    --
    if l_min_max_status = 'F' and l_rec.warning_or_error = 'E' then
      if l_rec.max_value is NULL then
        hr_utility.set_message(801,'PAY_KR_INPUTV_MIN_WARN');
        hr_utility.set_message_token('MIN_VALUE',p_user_min_value);
        hr_utility.raise_error;
      end if;
      if l_rec.min_value is NULL then
        hr_utility.set_message(801,'PAY_KR_INPUTV_MAX_WARN');
        hr_utility.set_message_token('MAX_VALUE',p_user_max_value);
        hr_utility.raise_error;
      end if;
      hr_utility.set_message(801,'HR_ELE_ENTRY_MIN_MAX_WARN');
      hr_utility.set_message_token('MIN_VALUE',p_user_min_value);
      hr_utility.set_message_token('MAX_VALUE',p_user_max_value);
      hr_utility.raise_error;
    end if;
    --
    -- Execute formula validation.
    --
    if l_rec.formula_id is not NULL then
      chk_formula(
        p_formula_id        => l_rec.formula_id,
        p_entry_value       => p_canonical_value,
        p_business_group_id => p_business_group_id,
        p_assignment_id     => p_assignment_id,
        p_date_earned       => p_effective_date,
        p_formula_status    => l_formula_status,
        p_formula_message   => p_formula_message
      );
    end if;
    --
    -- If warning_or_error='E'(Error) and l_formula_status='E'(Error),
    -- then raise error. In case of 'W'(Warning), Forms should warn
    --  to user with fnd_message.warn procedure.
    --
    if l_formula_status = 'E' and l_rec.warning_or_error = 'E' then
      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT',p_formula_message);
      hr_utility.raise_error;
    end if;
    --
    -- In case lookup_type validation is applied.
    --
    if l_rec.lookup_type is not NULL then
      --
      -- Lookup_type validation with effective_date.
      --
      if hr_api.not_exists_in_hr_lookups(
           p_effective_date => p_effective_date,
           p_lookup_type    => l_rec.lookup_type,
           p_lookup_code    => p_canonical_value) then
        hr_utility.set_message(801,'HR_7033_ELE_ENTRY_LKUP_INVLD');
        hr_utility.set_message_token('LOOKUP_TYPE',l_rec.lookup_type);
        hr_utility.raise_error;
      end if;
    end if;
  end if;
  --
  -- Set output variables.
  --
  if l_min_max_status = 'F' then
    p_min_max_warning := TRUE;
  end if;
  if l_formula_status = 'E' then
    p_formula_warning := TRUE;
  end If;
  if l_rec.hot_default_flag = 'Y'
       and p_canonical_value = l_rec.default_value then
    p_hot_defaulted := TRUE;
  end if;

end chk_entry_value;

-- ---------------------------------------------------------------------
-- |--------------------------< find_dt_upd_modes >--------------------|
-- ---------------------------------------------------------------------
--
-- Mandatory procedure to use DTCSAPI.pll forms library.
-- This procedure returns which datetrack modes are available
-- when updating.
--
procedure find_dt_upd_modes
(
  p_effective_date       in         date,
  p_base_key_value       in         number,
  p_correction           out NOCOPY boolean,
  p_update               out NOCOPY boolean,
  p_update_override      out NOCOPY boolean,
  p_update_change_insert out NOCOPY boolean
)
is

l_proc   varchar2(72) := g_package||'find_dt_upd_modes';
l_entry_type      pay_element_entries_f.entry_type%TYPE;
l_processing_type pay_element_types_f.processing_type%TYPE;

cursor c_sel1 is
select pee.entry_type,
       pet.processing_type
from   pay_element_types_f    pet,
       pay_element_links_f    pel,
       pay_element_entries_f  pee
where  pee.element_entry_id = p_base_key_value
and    p_effective_date between pee.effective_start_date
                            and pee.effective_end_date
and    pel.element_link_id = pee.element_link_id
and    p_effective_date between pel.effective_start_date
                            and pel.effective_end_date
and    pet.element_type_id = pel.element_type_id
and    p_effective_date between pet.effective_start_date
                            and pet.effective_end_date;
--
begin
  if g_debug then
    hr_utility.set_location('Entering:'||l_proc, 5);
  end if;

  open  c_sel1;
  fetch c_sel1 into l_entry_type, l_processing_type;

  if c_sel1%notfound then
    close c_sel1;
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  end if;

  close c_sel1;
--
  if l_processing_type = 'N' or l_entry_type <> 'E' then
    p_correction           := true;
    p_update               := false;
    p_update_override      := false;
    p_update_change_insert := false;
  else
    --
    -- Call the corresponding datetrack api
    --
    dt_api.find_dt_upd_modes(
      p_effective_date       => p_effective_date,
      p_base_table_name      => 'pay_element_entries_f',
      p_base_key_column      => 'element_entry_id',
      p_base_key_value       => p_base_key_value,
      p_correction           => p_correction,
      p_update               => p_update,
      p_update_override      => p_update_override,
      p_update_change_insert => p_update_change_insert
    );
  end if;
  --
  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;

end find_dt_upd_modes;

-- ---------------------------------------------------------------------
-- |--------------------------< find_dt_del_modes >--------------------|
-- ---------------------------------------------------------------------
--
-- Mandatory procedure to use DTCSAPI.pll forms library.
-- This procedure returns which datetrack modes are available
-- when deleting.
--
procedure find_dt_del_modes
(
  p_effective_date     in         date,
  p_base_key_value     in         number,
  p_zap                out NOCOPY boolean,
  p_delete             out NOCOPY boolean,
  p_future_change      out NOCOPY boolean,
  p_delete_next_change out NOCOPY boolean
)
is

l_proc              varchar2(72) := g_package || 'find_dt_del_modes';
l_parent_key_value1 number;
l_parent_key_value2 number;
l_entry_type        pay_element_entries_f.entry_type%TYPE;
l_processing_type   pay_element_types_f.processing_type%TYPE;

cursor c_sel1 is
select pee.assignment_id,
       pee.element_link_id,
       pee.entry_type,
       pet.processing_type
from   pay_element_types_f    pet,
       pay_element_links_f    pel,
       pay_element_entries_f  pee
where  pee.element_entry_id = p_base_key_value
and    p_effective_date between pee.effective_start_date
                            and pee.effective_end_date
and    pel.element_link_id = pee.element_link_id
and    p_effective_date between pel.effective_start_date
                            and pel.effective_end_date
and    pet.element_type_id = pel.element_type_id
and    p_effective_date between pet.effective_start_date
                            and pet.effective_end_date;
--
begin
  if g_debug then
    hr_utility.set_location('Entering:'||l_proc, 5);
  end if;

  open  c_sel1;
  fetch c_sel1 into l_parent_key_value1,
                    l_parent_key_value2,
                    l_entry_type,
                    l_processing_type;

  if c_sel1%notfound then
    close c_sel1;
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  end if;
  close c_sel1;
--

  if l_processing_type = 'N' or l_entry_type <> 'E' then
    p_zap                := true;
    p_delete             := false;
    p_future_change      := false;
    p_delete_next_change := false;
  else
    --
    -- Call the corresponding datetrack api
    --
    dt_api.find_dt_del_modes(
      p_effective_date     => p_effective_date,
      p_base_table_name    => 'pay_element_entries_f',
      p_base_key_column    => 'element_entry_id',
      p_base_key_value     => p_base_key_value,
      p_parent_table_name1 => 'per_all_assignments_f',
      p_parent_key_column1 => 'assignment_id',
      p_parent_key_value1  => l_parent_key_value1,
      p_parent_table_name2 => 'pay_element_links_f',
      p_parent_key_column2 => 'element_link_id',
      p_parent_key_value2  => l_parent_key_value2,
      p_zap                => p_zap,
      p_delete             => p_delete,
      p_future_change      => p_future_change,
      p_delete_next_change => p_delete_next_change
    );
  end if;

  if g_debug then
    hr_utility.set_location(' Leaving:' || l_proc, 10 );
  end if;

end find_dt_del_modes;

-- ---------------------------------------------------------------------
-- |-------------------------------< ins_lck >-------------------------|
-- ---------------------------------------------------------------------
--
-- Optional procedure to use DTCSAPI.pll forms library.
-- This procedure is used to lock parent tables
-- when inserting not to violate locking ladder.
--
procedure ins_lck
(
  p_effective_date        in  date,
  p_datetrack_mode        in  varchar2,
  p_rec                   in  pay_element_entries_f%ROWTYPE,
  p_validation_start_date out NOCOPY date,
  p_validation_end_date   out NOCOPY date
)
is

l_proc                  varchar2(72) := g_package || 'ins_lck' ;
l_validation_start_date date;
l_validation_end_date   date;

begin
  if g_debug then
    hr_utility.set_location( 'Entering:' || l_proc, 5 );
  end if;
  --
  -- Validate the datetrack mode getting the validation start
  -- and end dates for the specified datetrack operation.
  --
  dt_api.validate_dt_mode(
    p_effective_date          => p_effective_date,
    p_datetrack_mode          => p_datetrack_mode,
    p_base_table_name         => 'pay_element_entries_f',
    p_base_key_column         => 'element_entry_id',
    p_base_key_value          => p_rec.element_entry_id,
    p_parent_table_name1      => 'per_all_assignments_f',
    p_parent_key_column1      => 'assignment_id',
    p_parent_key_value1       => p_rec.assignment_id,
    p_parent_table_name2      => 'pay_element_links_f',
    p_parent_key_column2      => 'element_link_id',
    p_parent_key_value2       => p_rec.element_link_id,
    p_enforce_foreign_locking => true,
    p_validation_start_date   => l_validation_start_date,
    p_validation_end_date     => l_validation_end_date
  );
  --
  -- Set the validation start and end date OUT arguments
  --
  p_validation_start_date := l_validation_start_date;
  p_validation_end_date   := l_validation_end_date;
  --
  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 15);
  end if;
end ins_lck;

-- ---------------------------------------------------------------------
-- |---------------------------------< lck >---------------------------|
-- ---------------------------------------------------------------------
--
-- Mandatory procedure to use DTCSAPI.pll forms library.
-- This procedure is used to lock parent and child tables
-- when updating or deleting not to violate locking ladder.
--
procedure lck
(
  p_effective_date        in  date,
  p_datetrack_mode        in  varchar2,
  p_element_entry_id      in  number,
  p_object_version_number in  number,
  p_validation_start_date out NOCOPY date,
  p_validation_end_date   out NOCOPY date
)
is

l_proc varchar2(72) := g_package || 'lck';

l_validation_start_date date;
l_validation_end_date   date;
l_object_invalid        exception;
l_argument              varchar2(30);

--
-- Cursor C_Sel1 fetches the current locked row as of session date
-- ensuring that the object version numbers match.
--
cursor c_sel1 is
select *
from   pay_element_entries_f
where  element_entry_id = p_element_entry_id
and    p_effective_date between effective_start_date
                            and effective_end_date
for update nowait;

begin
  if g_debug then
    hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- Ensure that all the mandatory arguments are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'effective_date',
                             p_argument_value => p_effective_date);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'datetrack_mode',
                             p_argument_value => p_datetrack_mode);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'element_entry_id',
                             p_argument_value => p_element_entry_id);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                           p_argument      => 'object_version_number',
                           p_argument_value => p_object_version_number);
  --
  -- Check to ensure the datetrack mode is not INSERT.
  --
  If (p_datetrack_mode <> 'INSERT') then
    --
    -- We must select and lock the current row.
    --
    open  c_sel1;
    fetch c_sel1 into g_old_rec;

    if c_sel1%notfound then
      close c_sel1;
      --
      -- The primary key is invalid therefore we must error
      --
      hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
      hr_utility.raise_error;
    end if;

    close c_sel1;
    --
    -- Check if the set object version number is the same
    -- as the existing object version number
    --
    if (p_object_version_number <> g_old_rec.object_version_number) then
        hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
        hr_utility.raise_error;
    end if;

    if g_debug then
      hr_utility.set_location('Entering validation_dt_mode', 15);
    end if;

    dt_api.validate_dt_mode(
      p_effective_date          => p_effective_date,
      p_datetrack_mode          => p_datetrack_mode,
      p_base_table_name         => 'pay_element_entries_f',
      p_base_key_column         => 'element_entry_id',
      p_base_key_value          => p_element_entry_id,
      p_parent_table_name1      => 'per_all_assignments_f',
      p_parent_key_column1      => 'assignment_id',
      p_parent_key_value1       => g_old_rec.assignment_id,
      p_parent_table_name2      => 'pay_element_links_f',
      p_parent_key_column2      => 'element_link_id',
      p_parent_key_value2       => g_old_rec.element_link_id,
      p_enforce_foreign_locking => true,
      p_validation_start_date   => l_validation_start_date,
      p_validation_end_date     => l_validation_end_date
    );
  else
    --
    -- We are doing a datetrack 'INSERT' which is illegal within this
    -- procedure therefore we must error (note: to lck on insert the
    -- private procedure ins_lck should be called).
    --
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','20');
    hr_utility.raise_error;

  end if;
  --
  -- Set the validation start and end date OUT arguments
  --
  p_validation_start_date := l_validation_start_date;
  p_validation_end_date   := l_validation_end_date;

  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 30);
  end if;
--
-- We need to trap the ORA LOCK exception
--
exception
  when hr_api.object_locked then
    --
    -- The object is locked therefore we need to supply a meaningful
    -- error message.
    --
    hr_utility.set_message(801, 'HR_7165_OBJECT_LOCKED');
    hr_utility.set_message_token('TABLE_NAME', 'pay_element_entries_f');
    hr_utility.raise_error;
  when l_object_invalid then
    --
    -- The object doesn't exist or is invalid
    --
    hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
    hr_utility.set_message_token('TABLE_NAME', 'pay_element_entries_f');
    hr_utility.raise_error;

end lck;

-- ---------------------------------------------------------------------
-- |---------------------------< init_varray >-------------------------|
-- ---------------------------------------------------------------------
--
-- Currently not used because forms6 can not handle varray correctly.
--
procedure init_varray
(
  p_ev_rec_tbl in out NOCOPY ev_rec_tbl
)
is
l_counter number;
begin
  --
  -- Extend varray variable up to g_iv_max global variable.
  --
  l_counter := p_ev_rec_tbl.count;
  for i in l_counter + 1..g_iv_max loop
    p_ev_rec_tbl(i).input_value_id := NULL;
  end loop;

end init_varray;

-- ---------------------------------------------------------------------
-- |-------------------------------< ins >-----------------------------|
-- ---------------------------------------------------------------------
--
-- Procedure which issues insert dml.
--
procedure ins
(
  p_validate              in         boolean,
  p_effective_date        in         date,
  p_assignment_id         in         number,
  p_element_link_id       in         number,
  p_ev_rec_tbl            in         ev_rec_tbl,
  p_business_group_id     in         number,
  p_element_entry_id      out NOCOPY number,
  p_effective_start_date  out NOCOPY date,
  p_effective_end_date    out NOCOPY date,
  p_object_version_number out NOCOPY number
)
is
l_warning    boolean;
l_ev_rec_tbl ev_rec_tbl := p_ev_rec_tbl;
begin
  init_varray(l_ev_rec_tbl);
  py_element_entry_api.create_element_entry(
    P_VALIDATE              => p_validate,
    P_EFFECTIVE_DATE        => p_effective_date,
    P_BUSINESS_GROUP_ID     => p_business_group_id,
    P_ASSIGNMENT_ID         => p_assignment_id,
    P_ELEMENT_LINK_ID       => p_element_link_id,
    P_ENTRY_TYPE            => 'E',
    P_INPUT_VALUE_ID1       => l_ev_rec_tbl(1).input_value_id,
    P_INPUT_VALUE_ID2       => l_ev_rec_tbl(2).input_value_id,
    P_INPUT_VALUE_ID3       => l_ev_rec_tbl(3).input_value_id,
    P_INPUT_VALUE_ID4       => l_ev_rec_tbl(4).input_value_id,
    P_INPUT_VALUE_ID5       => l_ev_rec_tbl(5).input_value_id,
    P_INPUT_VALUE_ID6       => l_ev_rec_tbl(6).input_value_id,
    P_INPUT_VALUE_ID7       => l_ev_rec_tbl(7).input_value_id,
    P_INPUT_VALUE_ID8       => l_ev_rec_tbl(8).input_value_id,
    P_INPUT_VALUE_ID9       => l_ev_rec_tbl(9).input_value_id,
    P_INPUT_VALUE_ID10      => l_ev_rec_tbl(10).input_value_id,
    P_INPUT_VALUE_ID11      => l_ev_rec_tbl(11).input_value_id,
    P_INPUT_VALUE_ID12      => l_ev_rec_tbl(12).input_value_id,
    P_INPUT_VALUE_ID13      => l_ev_rec_tbl(13).input_value_id,
    P_INPUT_VALUE_ID14      => l_ev_rec_tbl(14).input_value_id,
    P_INPUT_VALUE_ID15      => l_ev_rec_tbl(15).input_value_id,
    P_ENTRY_VALUE1          => l_ev_rec_tbl(1).entry_value,
    P_ENTRY_VALUE2          => l_ev_rec_tbl(2).entry_value,
    P_ENTRY_VALUE3          => l_ev_rec_tbl(3).entry_value,
    P_ENTRY_VALUE4          => l_ev_rec_tbl(4).entry_value,
    P_ENTRY_VALUE5          => l_ev_rec_tbl(5).entry_value,
    P_ENTRY_VALUE6          => l_ev_rec_tbl(6).entry_value,
    P_ENTRY_VALUE7          => l_ev_rec_tbl(7).entry_value,
    P_ENTRY_VALUE8          => l_ev_rec_tbl(8).entry_value,
    P_ENTRY_VALUE9          => l_ev_rec_tbl(9).entry_value,
    P_ENTRY_VALUE10         => l_ev_rec_tbl(10).entry_value,
    P_ENTRY_VALUE11         => l_ev_rec_tbl(11).entry_value,
    P_ENTRY_VALUE12         => l_ev_rec_tbl(12).entry_value,
    P_ENTRY_VALUE13         => l_ev_rec_tbl(13).entry_value,
    P_ENTRY_VALUE14         => l_ev_rec_tbl(14).entry_value,
    P_ENTRY_VALUE15         => l_ev_rec_tbl(15).entry_value,
    P_EFFECTIVE_START_DATE  => p_effective_start_date,
    P_EFFECTIVE_END_DATE    => p_effective_end_date,
    P_ELEMENT_ENTRY_ID      => p_element_entry_id,
    P_OBJECT_VERSION_NUMBER => p_object_version_number,
    P_CREATE_WARNING        => l_warning
  );
end ins;

-- ---------------------------------------------------------------------
-- |-------------------------------< upd >-----------------------------|
-- ---------------------------------------------------------------------
--
-- Procedure which issues update dml.
--
procedure upd
(
  p_validate              in            boolean,
  p_effective_date        in            date,
  p_datetrack_update_mode in            varchar2,
  p_element_entry_id      in            number,
  p_object_version_number in out NOCOPY number,
  p_ev_rec_tbl            in            ev_rec_tbl,
  p_business_group_id     in            number,
  p_effective_start_date  out NOCOPY    date,
  p_effective_end_date    out NOCOPY    date
)
is
l_warning    boolean;
l_ev_rec_tbl ev_rec_tbl := p_ev_rec_tbl;
begin
  init_varray(l_ev_rec_tbl);
  py_element_entry_api.update_element_entry(
    P_VALIDATE              => p_validate,
    P_DATETRACK_UPDATE_MODE => p_datetrack_update_mode,
    P_EFFECTIVE_DATE        => p_effective_date,
    P_BUSINESS_GROUP_ID     => p_business_group_id,
    P_ELEMENT_ENTRY_ID      => p_element_entry_id,
    P_OBJECT_VERSION_NUMBER => p_object_version_number,
    P_INPUT_VALUE_ID1       => l_ev_rec_tbl(1).input_value_id,
    P_INPUT_VALUE_ID2       => l_ev_rec_tbl(2).input_value_id,
    P_INPUT_VALUE_ID3       => l_ev_rec_tbl(3).input_value_id,
    P_INPUT_VALUE_ID4       => l_ev_rec_tbl(4).input_value_id,
    P_INPUT_VALUE_ID5       => l_ev_rec_tbl(5).input_value_id,
    P_INPUT_VALUE_ID6       => l_ev_rec_tbl(6).input_value_id,
    P_INPUT_VALUE_ID7       => l_ev_rec_tbl(7).input_value_id,
    P_INPUT_VALUE_ID8       => l_ev_rec_tbl(8).input_value_id,
    P_INPUT_VALUE_ID9       => l_ev_rec_tbl(9).input_value_id,
    P_INPUT_VALUE_ID10      => l_ev_rec_tbl(10).input_value_id,
    P_INPUT_VALUE_ID11      => l_ev_rec_tbl(11).input_value_id,
    P_INPUT_VALUE_ID12      => l_ev_rec_tbl(12).input_value_id,
    P_INPUT_VALUE_ID13      => l_ev_rec_tbl(13).input_value_id,
    P_INPUT_VALUE_ID14      => l_ev_rec_tbl(14).input_value_id,
    P_INPUT_VALUE_ID15      => l_ev_rec_tbl(15).input_value_id,
    P_ENTRY_VALUE1          => l_ev_rec_tbl(1).entry_value,
    P_ENTRY_VALUE2          => l_ev_rec_tbl(2).entry_value,
    P_ENTRY_VALUE3          => l_ev_rec_tbl(3).entry_value,
    P_ENTRY_VALUE4          => l_ev_rec_tbl(4).entry_value,
    P_ENTRY_VALUE5          => l_ev_rec_tbl(5).entry_value,
    P_ENTRY_VALUE6          => l_ev_rec_tbl(6).entry_value,
    P_ENTRY_VALUE7          => l_ev_rec_tbl(7).entry_value,
    P_ENTRY_VALUE8          => l_ev_rec_tbl(8).entry_value,
    P_ENTRY_VALUE9          => l_ev_rec_tbl(9).entry_value,
    P_ENTRY_VALUE10         => l_ev_rec_tbl(10).entry_value,
    P_ENTRY_VALUE11         => l_ev_rec_tbl(11).entry_value,
    P_ENTRY_VALUE12         => l_ev_rec_tbl(12).entry_value,
    P_ENTRY_VALUE13         => l_ev_rec_tbl(13).entry_value,
    P_ENTRY_VALUE14         => l_ev_rec_tbl(14).entry_value,
    P_ENTRY_VALUE15         => l_ev_rec_tbl(15).entry_value,
    P_EFFECTIVE_START_DATE  => p_effective_start_date,
    P_EFFECTIVE_END_DATE    => p_effective_end_date,
    P_UPDATE_WARNING        => l_warning
  );
end upd;

-- ---------------------------------------------------------------------
-- |-------------------------------< del >-----------------------------|
-- ---------------------------------------------------------------------
--
-- Procedure which issues delete dml.
--
procedure del
(
  p_validate              in            boolean,
  p_effective_date        in            date,
  p_datetrack_delete_mode in            varchar2,
  p_element_entry_id      in            number,
  p_object_version_number in out NOCOPY number,
  p_effective_start_date  out    NOCOPY date,
  p_effective_end_date    out    NOCOPY date
)
is
  l_warning BOOLEAN;
begin
  py_element_entry_api.delete_element_entry(
    P_VALIDATE              => p_validate,
    P_DATETRACK_DELETE_MODE => p_datetrack_delete_mode,
    P_EFFECTIVE_DATE        => p_effective_date,
    P_ELEMENT_ENTRY_ID      => p_element_entry_id,
    P_OBJECT_VERSION_NUMBER => p_object_version_number,
    P_EFFECTIVE_START_DATE  => p_effective_start_date,
    P_EFFECTIVE_END_DATE    => p_effective_end_date,
    P_DELETE_WARNING        => l_warning
  );

end del;
--
-- ---------------------------------------------------------------------
-- Function to handle contact relationship data
-- ---------------------------------------------------------------------
-- upd_contact_info
-- ---------------------------------------------------------------------
procedure upd_contact_info
( p_validate                 in     boolean  default null
 ,p_effective_date           in     date
 ,p_contact_relationship_id  in     number
 ,p_object_version_number    in out NOCOPY number
 ,p_cont_information2        in     varchar2 default null
 ,p_cont_information3        in     varchar2 default null
 ,p_cont_information4        in     varchar2 default null
 ,p_cont_information5        in     varchar2 default null
 ,p_cont_information7        in     varchar2 default null
 ,p_cont_information8        in     varchar2 default null
 ,p_cont_information10	     in     varchar2 default null
 ,p_cont_information12	     in     varchar2 default null
 ,p_cont_information13	     in     varchar2 default null
 ,p_cont_information14	     in     varchar2 default null
) is
  l_proc varchar2(72) := g_package||'upd_contact_info';
begin
  if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 10);
    hr_utility.set_location(l_proc, 6);
  end if;
  --
  -- Call the contact relationships API
  --
  hr_contact_rel_api.update_contact_relationship
  (p_validate                   => p_validate
  ,p_effective_date             => p_effective_date
  ,p_contact_relationship_id    => p_contact_relationship_id
  ,p_object_version_number      => p_object_version_number
  ,p_cont_information2          => p_cont_information2
  ,p_cont_information3          => p_cont_information3
  ,p_cont_information4          => p_cont_information4
  ,p_cont_information5          => p_cont_information5
  ,p_cont_information7          => p_cont_information7
  ,p_cont_information8          => p_cont_information8
  ,p_cont_information10         => p_cont_information10
  ,p_cont_information12         => p_cont_information12
  ,p_cont_information13         => p_cont_information13
  ,p_cont_information14         => p_cont_information14
  );

  if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 40);
  end if;

end upd_contact_info;

-- ---------------------------------------------------------------------
-- Procedure to handle Contact Extra Information Data
-- ---------------------------------------------------------------------
-- upd_contact_extra_info
-- ---------------------------------------------------------------------
procedure upd_contact_extra_info
( p_effective_date		IN		DATE,
  p_contact_extra_info_id	IN		NUMBER,
  p_contact_relationship_id	IN		NUMBER,
  p_contact_ovn			IN OUT NOCOPY	NUMBER,
  p_cei_information1            IN		VARCHAR2,
  p_cei_information2            IN		VARCHAR2,
  p_cei_information3            IN		VARCHAR2,
  p_cei_information4            IN		VARCHAR2,
  p_cei_information5            IN		VARCHAR2,
  p_cei_information6            IN		VARCHAR2,
  p_cei_information7            IN		VARCHAR2,
  p_cei_information8            IN		VARCHAR2,
  p_cei_information9            IN		VARCHAR2,
  p_cei_information10           IN		VARCHAR2, -- Bug 5667762
  p_cei_information11           IN		VARCHAR2,
  p_cei_information12           IN		VARCHAR2, -- Bug 6630135
  p_cei_information13           IN		VARCHAR2, -- Bug 6705170
  p_cei_information14           IN		VARCHAR2, -- Bug 7142612
  p_cei_information15           IN		VARCHAR2, -- Bug 7142612
  p_cei_effective_start_date    OUT NOCOPY	DATE,
  p_cei_effective_end_date      OUT NOCOPY	DATE
)
is
  l_proc varchar2(72) := g_package||'upd_contact_extra_info';
begin

  if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 25);
    hr_utility.set_location(l_proc, 6);
  end if;

  hr_contact_extra_info_api.update_contact_extra_info
      ( p_effective_date          => p_effective_date,
        p_datetrack_update_mode   => 'CORRECTION',
        p_contact_extra_info_id   => p_contact_extra_info_id,
        p_contact_relationship_id => p_contact_relationship_id,
        p_object_version_number   => p_contact_ovn,
        p_information_type        => 'KR_DPNT_EXPENSE_INFO',
        p_cei_information1        => p_cei_information1,
        p_cei_information2        => p_cei_information2,
        p_cei_information3        => p_cei_information3,
        p_cei_information4        => p_cei_information4,
        p_cei_information5        => p_cei_information5,
        p_cei_information6        => p_cei_information6,
        p_cei_information7        => p_cei_information7,
        p_cei_information8        => p_cei_information8,
        p_cei_information9        => p_cei_information9,
        p_cei_information10       => p_cei_information10, -- Bug 5667762
        p_cei_information11       => p_cei_information11,
        p_cei_information12       => p_cei_information12, -- Bug 6630135
        p_cei_information13       => p_cei_information13, -- Bug 6705170
        p_cei_information14       => p_cei_information14, -- Bug 7142612
        p_cei_information15       => p_cei_information15, -- Bug 7142612
        p_effective_start_date    => p_cei_effective_start_date,
        p_effective_end_date      => p_cei_effective_end_date
      );
   --
   if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 40);
   end if;
   --
end upd_contact_extra_info;

-- ---------------------------------------------------------------------
-- Procedure to handle Contact Extra Information Data
-- ---------------------------------------------------------------------
-- create_contact_extra_info
-- ---------------------------------------------------------------------

procedure create_contact_extra_info
( p_effective_date            IN		DATE,
  p_contact_extra_info_id     OUT NOCOPY	NUMBER,
  p_contact_relationship_id   IN		NUMBER,
  p_contact_ovn               OUT NOCOPY	NUMBER,
  p_cei_information1          IN		VARCHAR2,
  p_cei_information2          IN		VARCHAR2,
  p_cei_information3          IN		VARCHAR2,
  p_cei_information4          IN		VARCHAR2,
  p_cei_information5          IN		VARCHAR2,
  p_cei_information6          IN		VARCHAR2,
  p_cei_information7          IN		VARCHAR2,
  p_cei_information8          IN		VARCHAR2,
  p_cei_information9          IN		VARCHAR2,
  p_cei_information10         IN		VARCHAR2, -- Bug 5667762
  p_cei_information11         IN		VARCHAR2,
  p_cei_information12         IN		VARCHAR2, -- Bug 6630135
  p_cei_information13         IN		VARCHAR2, -- Bug 6705170
  p_cei_information14         IN		VARCHAR2, -- Bug 7142612
  p_cei_information15         IN		VARCHAR2, -- Bug 7142612
  p_cei_effective_start_date  OUT NOCOPY	DATE,
  p_cei_effective_end_date    OUT NOCOPY	DATE
)
is
  l_proc varchar2(72) := g_package||'create_contact_extra_info';
begin
--
  if g_debug then
    hr_utility.set_location('Entering:'|| l_proc, 25);
    hr_utility.set_location(l_proc, 6);
  end if;

  hr_contact_extra_info_api.create_contact_extra_info
      ( p_effective_date               => p_effective_date,
        p_contact_extra_info_id        => p_contact_extra_info_id,
        p_contact_relationship_id      => p_contact_relationship_id,
        p_object_version_number        => p_contact_ovn,
        p_information_type             => 'KR_DPNT_EXPENSE_INFO',
	p_cei_information_category     => 'KR_DPNT_EXPENSE_INFO',
        p_cei_information1             => p_cei_information1,
        p_cei_information2             => p_cei_information2,
        p_cei_information3             => p_cei_information3,
        p_cei_information4             => p_cei_information4,
        p_cei_information5             => p_cei_information5,
        p_cei_information6             => p_cei_information6,
        p_cei_information7             => p_cei_information7,
        p_cei_information8             => p_cei_information8,
        p_cei_information9             => p_cei_information9,
        p_cei_information10            => p_cei_information10, -- Bug 5667762
        p_cei_information11            => p_cei_information11,
        p_cei_information12            => p_cei_information12, -- Bug 6630135
	p_cei_information13            => p_cei_information13, -- Bug 6705170
	p_cei_information14            => p_cei_information14, -- Bug 7142612
	p_cei_information15            => p_cei_information15, -- Bug 7142612
        p_effective_start_date         => p_cei_effective_start_date,
        p_effective_end_date           => p_cei_effective_end_date
      );
   --
   if g_debug then
    hr_utility.set_location(' Leaving:'||l_proc, 40);
   end if;
   --
end create_contact_extra_info;
--
end pay_kr_entries_pkg;

/
