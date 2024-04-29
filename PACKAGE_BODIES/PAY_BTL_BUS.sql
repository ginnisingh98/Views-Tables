--------------------------------------------------------
--  DDL for Package Body PAY_BTL_BUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_BTL_BUS" as
/* $Header: pybtlrhi.pkb 120.7 2005/11/09 08:16:09 mkataria noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pay_btl_bus.';  -- Global package name
--
-- The following two global variables are only to be
-- used by the return_legislation_code function.
--
g_legislation_code            varchar2(150)  default null;
g_batch_line_id               number         default null;

--  ---------------------------------------------------------------------------
--  |----------------------< Validate_Input_Values >--------------------------|
--  ---------------------------------------------------------------------------
Procedure Validate_Input_Values (p_session_date                 in date,
				 p_rec                          in pay_btl_shd.g_rec_type)
is
  Cursor  csr_Input_value_set (P_Element_type_id		in number,
				    P_Effective_date		in Date)
  is
	Select	input_value_id
		,effective_start_date
		,effective_end_date
		,element_type_id
		,lookup_type
		,business_group_id
		,legislation_code
		,formula_id
		,value_set_id
		,display_sequence
		,generate_db_items_flag
		,hot_default_flag
		,mandatory_flag
		,name
		,uom
		,default_value
		,legislation_subgroup
		,max_value
		,min_value
		,warning_or_error
		,object_version_number
	From	Pay_input_values_f
	Where	Element_type_id	=	P_element_Type_id
	And	P_effective_Date Between Effective_start_date
				 And     Effective_end_date
	Order	By Display_sequence,Input_value_id ;

Type Ivl_rec_type Is Record
  (input_value_id                  number(9)
  ,effective_start_date            date
  ,effective_end_date              date
  ,element_type_id                 number(9)
  ,lookup_type                     varchar2(30)
  ,business_group_id               number(15)
  ,legislation_code                varchar2(30)
  ,formula_id                      number(9)
  ,value_set_id                    number(10)
  ,display_sequence                number(9)         -- Increased length
  ,generate_db_items_flag          varchar2(30)
  ,hot_default_flag                varchar2(30)
  ,mandatory_flag                  varchar2(9)       -- Increased length
  ,name                            varchar2(80)
  ,uom                             varchar2(30)
  ,default_value                   varchar2(60)
  ,legislation_subgroup            varchar2(30)
  ,max_value                       varchar2(60)
  ,min_value                       varchar2(60)
  ,warning_or_error                varchar2(30)
  ,object_version_number           number(9)
  ,input_value			   varchar2(240)
  );

Type Input_val_tbl_type is Table of ivl_rec_type index by binary_integer;

Input_val_tbl Input_val_tbl_type;

i Number:=1;
 l_entry_value1          varchar2(240);
  l_entry_value2          varchar2(240);
  l_entry_value3          varchar2(240);
  l_entry_value4          varchar2(240);
  l_entry_value5          varchar2(240);
  l_entry_value6          varchar2(240);
  l_entry_value7          varchar2(240);
  l_entry_value8          varchar2(240);
  l_entry_value9          varchar2(240);
  l_entry_value10         varchar2(240);
  l_entry_value11         varchar2(240);
  l_entry_value12         varchar2(240);
  l_entry_value13         varchar2(240);
  l_entry_value14         varchar2(240);
  l_entry_value15         varchar2(240);

Begin


for counter in 1..15 loop
Input_val_tbl(counter).input_value_id  := null;
Input_val_tbl(counter).input_value  := null;
end loop;
 For j in csr_Input_value_set(	p_rec.Element_type_id,
				p_session_date)
 loop
	Input_val_tbl(i).input_value_id		:=	j.input_value_id;
	Input_val_tbl(i).effective_start_date   :=      j.effective_start_date;
	Input_val_tbl(i).effective_end_date     :=      j.effective_end_date;
	Input_val_tbl(i).element_type_id        :=      j.element_type_id;
	Input_val_tbl(i).lookup_type            :=      j.lookup_type;
	Input_val_tbl(i).business_group_id      :=      j.business_group_id;
	Input_val_tbl(i).legislation_code       :=      j.legislation_code;
	Input_val_tbl(i).formula_id             :=      j.formula_id;
	Input_val_tbl(i).value_set_id           :=      j.value_set_id;
	Input_val_tbl(i).display_sequence       :=      j.display_sequence;
	Input_val_tbl(i).generate_db_items_flag :=      j.generate_db_items_flag;
	Input_val_tbl(i).hot_default_flag       :=      j.hot_default_flag;
	Input_val_tbl(i).mandatory_flag         :=      j.mandatory_flag;
	Input_val_tbl(i).name                   :=      j.name;
	Input_val_tbl(i).uom                    :=      j.uom;
	Input_val_tbl(i).default_value          :=      j.default_value;
	Input_val_tbl(i).legislation_subgroup   :=      j.legislation_subgroup;
	Input_val_tbl(i).max_value              :=      j.max_value;
	Input_val_tbl(i).min_value              :=      j.min_value;
	Input_val_tbl(i).warning_or_error       :=      j.warning_or_error;
	Input_val_tbl(i).object_version_number  :=      j.object_version_number;
	hr_utility.trace('1-LR');
	i:=i+1;
  End loop;
   IF Input_val_tbl(1).input_value_id IS NOT NULL AND
     p_rec.value_1 IS NOT NULL THEN
     l_entry_value1 := pay_ele_shd.convert_lookups(Input_val_tbl(1).input_value_id, p_rec.value_1);
     Input_val_tbl(1).Input_value := p_rec.value_1;
  END IF;
 IF Input_val_tbl(2).input_value_id IS NOT NULL AND
     p_rec.value_2 IS NOT NULL THEN
     l_entry_value1 := pay_ele_shd.convert_lookups(Input_val_tbl(2).input_value_id, p_rec.value_2);
     Input_val_tbl(2).Input_value := p_rec.value_2;
  END IF;
IF Input_val_tbl(3).input_value_id IS NOT NULL AND
     p_rec.value_3 IS NOT NULL THEN
     l_entry_value1 := pay_ele_shd.convert_lookups(Input_val_tbl(3).input_value_id, p_rec.value_3);
     Input_val_tbl(3).Input_value := p_rec.value_3;
  END IF;
  IF Input_val_tbl(4).input_value_id IS NOT NULL AND
     p_rec.value_4 IS NOT NULL THEN
     l_entry_value1 := pay_ele_shd.convert_lookups(Input_val_tbl(4).input_value_id, p_rec.value_4);
     Input_val_tbl(4).Input_value := p_rec.value_4;
  END IF;
  IF Input_val_tbl(5).input_value_id IS NOT NULL AND
     p_rec.value_5 IS NOT NULL THEN
     l_entry_value1 := pay_ele_shd.convert_lookups(Input_val_tbl(5).input_value_id, p_rec.value_5);
     Input_val_tbl(5).Input_value := p_rec.value_5;
  END IF;
  IF Input_val_tbl(6).input_value_id IS NOT NULL AND
     p_rec.value_6 IS NOT NULL THEN
     l_entry_value1 := pay_ele_shd.convert_lookups(Input_val_tbl(6).input_value_id, p_rec.value_6);
     Input_val_tbl(6).Input_value := p_rec.value_6;
  END IF;
  IF Input_val_tbl(7).input_value_id IS NOT NULL AND
     p_rec.value_7 IS NOT NULL THEN
     l_entry_value1 := pay_ele_shd.convert_lookups(Input_val_tbl(7).input_value_id, p_rec.value_7);
     Input_val_tbl(7).Input_value := p_rec.value_7;
  END IF;
  IF Input_val_tbl(8).input_value_id IS NOT NULL AND
     p_rec.value_8 IS NOT NULL THEN
     l_entry_value1 := pay_ele_shd.convert_lookups(Input_val_tbl(8).input_value_id, p_rec.value_8);
     Input_val_tbl(8).Input_value := p_rec.value_8;
  END IF;
  IF Input_val_tbl(9).input_value_id IS NOT NULL AND
     p_rec.value_9 IS NOT NULL THEN
     l_entry_value1 := pay_ele_shd.convert_lookups(Input_val_tbl(9).input_value_id, p_rec.value_9);
     Input_val_tbl(9).Input_value := p_rec.value_9;
  END IF;
  IF Input_val_tbl(10).input_value_id IS NOT NULL AND
     p_rec.value_10 IS NOT NULL THEN
     l_entry_value1 := pay_ele_shd.convert_lookups(Input_val_tbl(10).input_value_id, p_rec.value_10);
     Input_val_tbl(10).Input_value := p_rec.value_10;
  END IF;
  IF Input_val_tbl(11).input_value_id IS NOT NULL AND
     p_rec.value_11 IS NOT NULL THEN
     l_entry_value1 := pay_ele_shd.convert_lookups(Input_val_tbl(11).input_value_id, p_rec.value_11);
     Input_val_tbl(11).Input_value := p_rec.value_11;
  END IF;
  IF Input_val_tbl(12).input_value_id IS NOT NULL AND
     p_rec.value_12 IS NOT NULL THEN
     l_entry_value1 := pay_ele_shd.convert_lookups(Input_val_tbl(12).input_value_id, p_rec.value_12);
     Input_val_tbl(12).Input_value := p_rec.value_12;
  END IF;
  IF Input_val_tbl(13).input_value_id IS NOT NULL AND
     p_rec.value_13 IS NOT NULL THEN
     l_entry_value1 := pay_ele_shd.convert_lookups(Input_val_tbl(13).input_value_id, p_rec.value_13);
     Input_val_tbl(13).Input_value := p_rec.value_13;
  END IF;
  IF Input_val_tbl(14).input_value_id IS NOT NULL AND
     p_rec.value_14 IS NOT NULL THEN
     l_entry_value1 := pay_ele_shd.convert_lookups(Input_val_tbl(14).input_value_id, p_rec.value_14);
     Input_val_tbl(14).Input_value := p_rec.value_14;
  END IF;
  IF Input_val_tbl(15).input_value_id IS NOT NULL AND
     p_rec.value_15 IS NOT NULL THEN
     l_entry_value1 := pay_ele_shd.convert_lookups(Input_val_tbl(15).input_value_id, p_rec.value_15);
     Input_val_tbl(15).Input_value := p_rec.value_15;
  END IF;
  --
End;

-- ----------------------------------------------------------------------------
-- |-------------------------< chk_mandatory_segments >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure will check any segment which is not required for
--   particular level and have been assigned any value. Procedure will
--   error out in case any extra segment have been assigned value.
--   This procedure will also check the segments which are mandatory and qualified
--   for particular level.
--
-- Prerequisites:
--   None.
--
-- In Parameters:
--   Name                           Reqd Type     Description
--   p_level                        Yes  varchar2 The Qualifier level.
--   p_cost_id_flex_num             Yes  varchar2 The concatenated flex number.
--   p_segment                      No   segment_value.
--
-- Post Success:
--   If none of required segments are not null then row is inserted or updated
--   successfully.
--
-- Post Failure:
--   The procedure will raise an error.
--
-- Access Status:
--   Internal use only.
--
-- {End Of Comments}
--
Procedure chk_mandatory_segments(
          p_level               IN  VARCHAR2,
          p_cost_id_flex_num    IN  NUMBER,
          p_segment             IN  pay_btl_shd.segment_value
  ) is
   l_proc  VARCHAR2(72) := g_package||'check_mandatory_segments';
   --

  type segment_no_array          is table
                     of number(2) INDEX BY Binary_integer;
  type application_column_array  is table
                     of fnd_id_flex_segments.application_column_name%type INDEX BY Binary_integer;
  type application_segment_array is table
                     of fnd_id_flex_segments.segment_name%type INDEX BY Binary_integer;
  type required_flag_array       is table
                     of fnd_id_flex_segments.required_flag%type INDEX BY Binary_integer;

  l_segment_no          segment_no_array;
  l_application_column  application_column_array;
  l_application_segment application_segment_array;
  l_required_flag       required_flag_array;


  cursor csr_segment is
     SELECT substr(fs.application_column_name,8,2) segment_no,
            fs.application_column_name application_column_name,
            fs.segment_name application_segment_name,
            fs.required_flag required_flag
    FROM    FND_ID_FLEX_SEGMENTS         fs,
            FND_SEGMENT_ATTRIBUTE_VALUES sa1
    WHERE   sa1.id_flex_num = p_cost_id_flex_num
    and     sa1.id_flex_code = 'COST'
    and     sa1.attribute_value = 'Y'
    and     sa1.segment_attribute_type <> 'BALANCING'
    and     sa1.segment_attribute_type = p_level
    and     fs.id_flex_num = p_cost_id_flex_num
    and     fs.id_flex_code = 'COST'
    and     fs.enabled_flag  = 'Y'
    and     fs.application_id = 801
    and     fs.application_column_name =
                                       sa1.application_column_name
order by substr(fs.application_column_name,8,2);



    -- local variable to hold segments needed for the particular level
    -- initialy mark all segment as not required
    l_required_segment pay_btl_shd.Segment_value
                 := pay_btl_shd.segment_value('N','N','N','N','N','N','N','N','N','N',
                                  'N','N','N','N','N','N','N','N','N','N',
                                  'N','N','N','N','N','N','N','N','N','N'
                                 );
    --
    v_cal_cost_segs varchar2(3);
    --

Begin
   OPEN csr_segment;
   FETCH csr_segment BULK COLLECT INTO l_Segment_no,l_application_column,
                                    l_application_segment,l_required_flag;
   close csr_segment;

   --
   -- Perform Flexfield Validation: if COST_VAL_SEGS pay_action_parameter = 'Y'
   --
   begin
     select parameter_value
       into v_cal_cost_segs
       from pay_action_parameters
      where parameter_name = 'COST_VAL_SEGS';
   exception
     when others then
       v_cal_cost_segs := 'N';
   end;
   --

   -- Only carry out the mandatory check if the COST_VAL_SEGS is set as 'Y'.
   if ( l_segment_no.COUNT <> 0 and v_cal_cost_segs = 'Y') then

   FOR i IN l_segment_no.FIRST..l_segment_no.LAST
   LOOP
      -- mark those segment which is needed for flexfield
      --
      l_required_segment(l_segment_no(i)) := 'Y';
      --
      -- Check for mandatoy segment
      --
      If (l_required_flag(i) = 'Y' and p_segment(l_segment_no(i)) is null) then
          fnd_message.set_name('PER','PAY_33284_FLEX_VALUE_MISSING');
          fnd_message.set_token('COLUMN',l_application_column(i));
          fnd_message.set_token('PROMPT',l_application_segment(i));
          hr_utility.raise_error;
      end if;
   END LOOP;
   end if;

  -- -- check whether any segment is not required for flexfield and value has been
  -- -- assigned for the same.
  -- for i in 1..30 loop
  --     if l_required_segment(i) = 'N' then
  --       if (p_segment(i) is not null or p_segment(i) = hr_api.g_varchar2) then
  --          --
  --          hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
  --      hr_utility.set_message_token('PROCEDURE', l_proc);
  --         hr_utility.set_message_token('STEP','20');
  --         hr_utility.raise_error;
  --          --
  --      end if;
  --    end if;
  -- end loop;
end chk_mandatory_segments;
--
--  ---------------------------------------------------------------------------
--  |----------------------< set_security_group_id >--------------------------|
--  ---------------------------------------------------------------------------
--
Procedure set_security_group_id
  (p_batch_line_id                        in number
  ) is
  --
  -- Declare cursor
  --
  -- In the following cursor statement add join(s) between
  -- pay_batch_lines and PER_BUSINESS_GROUPS
  -- so that the security_group_id for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_sec_grp is
    select pbg.security_group_id
      from per_business_groups pbg
         , pay_batch_lines btl
         , pay_batch_headers bth
     where btl.batch_line_id = p_batch_line_id
       and bth.batch_id = btl.batch_id
       and pbg.business_group_id = bth.business_group_id;
  --
  -- Declare local variables
  --
  l_security_group_id number;
  l_proc              varchar2(72)  :=  g_package||'set_security_group_id';
  --
begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'batch_line_id'
    ,p_argument_value     => p_batch_line_id
    );
  --
  open csr_sec_grp;
  fetch csr_sec_grp into l_security_group_id;
  --
  if csr_sec_grp%notfound then
     --
     close csr_sec_grp;
     --
     -- The primary key is invalid therefore we must error
     --
     fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
     fnd_message.raise_error;
     --
  end if;
  close csr_sec_grp;
  --
  -- Set the security_group_id in CLIENT_INFO
  --
  hr_api.set_security_group_id
    (p_security_group_id => l_security_group_id
    );
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 20);
  --
end set_security_group_id;
--
--  ---------------------------------------------------------------------------
--  |---------------------< return_legislation_code >-------------------------|
--  ---------------------------------------------------------------------------
--
Function return_legislation_code
  (p_batch_line_id                        in     number
  )
  Return Varchar2 Is
  --
  -- Declare cursor
  --
  -- In the following cursor statement add join(s) between
  -- pay_batch_lines and PER_BUSINESS_GROUPS
  -- so that the legislation_code for
  -- the current business group context can be derived.
  -- Remove this comment when the edit has been completed.
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups     pbg
         , pay_batch_lines btl
         , pay_batch_headers bth
     where btl.batch_line_id = p_batch_line_id
       and bth.batch_id = btl.batch_id
       and pbg.business_group_id = bth.business_group_id;
  --
  -- Declare local variables
  --
  l_legislation_code  varchar2(150);
  l_proc              varchar2(72)  :=  g_package||'return_legislation_code';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Ensure that all the mandatory parameter are not null
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'batch_line_id'
    ,p_argument_value     => p_batch_line_id
    );
  --
  if ( nvl(pay_btl_bus.g_batch_line_id, hr_api.g_number)
       = p_batch_line_id) then
    --
    -- The legislation code has already been found with a previous
    -- call to this function. Just return the value in the global
    -- variable.
    --
    l_legislation_code := pay_btl_bus.g_legislation_code;
    hr_utility.set_location(l_proc, 20);
  else
    --
    -- The ID is different to the last call to this function
    -- or this is the first call to this function.
    --
    open csr_leg_code;
    fetch csr_leg_code into l_legislation_code;
    --
    if csr_leg_code%notfound then
      --
      -- The primary key is invalid therefore we must error
      --
      close csr_leg_code;
      fnd_message.set_name('PAY','HR_7220_INVALID_PRIMARY_KEY');
      fnd_message.raise_error;
    end if;
    hr_utility.set_location(l_proc,30);
    --
    -- Set the global variables so the values are
    -- available for the next call to this function.
    --
    close csr_leg_code;
    pay_btl_bus.g_batch_line_id     := p_batch_line_id;
    pay_btl_bus.g_legislation_code  := l_legislation_code;
  end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 40);
  return l_legislation_code;
end return_legislation_code;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_non_updateable_args >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is used to ensure that non updateable attributes have
--   not been updated. If an attribute has been updated an error is generated.
--
-- Pre Conditions:
--   g_old_rec has been populated with details of the values currently in
--   the database.
--
-- In Arguments:
--   p_rec has been populated with the updated values the user would like the
--   record set to.
--
-- Post Success:
--   Processing continues if all the non updateable attributes have not
--   changed.
--
-- Post Failure:
--   An application error is raised if any of the non updatable attributes
--   have been altered.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure chk_non_updateable_args
  (p_rec in pay_btl_shd.g_rec_type
  ) IS
--
  l_proc     varchar2(72) := g_package || 'chk_non_updateable_args';
  l_error    EXCEPTION;
  l_argument varchar2(30);
--
Begin
  --
  -- Only proceed with the validation if a row exists for the current
  -- record in the HR Schema.
  --
  IF NOT pay_btl_shd.api_updating
      (p_batch_line_id                        => p_rec.batch_line_id
      ,p_object_version_number                => p_rec.object_version_number
      ) THEN
     fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE ', l_proc);
     fnd_message.set_token('STEP ', '5');
     fnd_message.raise_error;
  END IF;
  --
  hr_utility.set_location(l_proc, 10);
  --
  if nvl(p_rec.batch_id, hr_api.g_number) <>
     pay_btl_shd.g_old_rec.batch_id then
     l_argument := 'batch_id';
     raise l_error;
  end if;
  --
  hr_utility.set_location(l_proc, 20);
  --
  EXCEPTION
    WHEN l_error THEN
       hr_api.argument_changed_error
         (p_api_name => l_proc
         ,p_argument => l_argument);
    WHEN OTHERS THEN
       RAISE;
End chk_non_updateable_args;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< chk_transferred_status >-------------------------|
-- ----------------------------------------------------------------------------
--
--  Desciption :
--
--    Check whether the existing batch line is transferred or not. If it
--    is transferred then raise error.
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_batch_line_id
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
Procedure chk_transferred_status (p_batch_line_id number) Is
--
  cursor csr_status is
     select 'Y'
       from pay_batch_lines pbl
      where pbl.batch_line_id = p_batch_line_id
        and pbl.batch_line_status = 'T';
  --
  l_transferred varchar2(1);
  --
Begin
  --
  open csr_status;
  fetch csr_status into l_transferred;
  if csr_status%found then
     close csr_status;
     Fnd_Message.Set_Name('PER', 'HR_289754_BEE_REC_TRANSFERRED');
     fnd_message.raise_error;
  end if;
  --
  close csr_status;
  --
End chk_transferred_status;
--
--  ---------------------------------------------------------------------------
--  |----------------------------< chk_batch_id >----------------------------|
--  ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that on insert BATCH_ID is not null and that
--    it exists in pay_batch_headers.
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_batch_line_id
--    p_batch_id
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_batch_id
  (p_batch_line_id      in    pay_batch_lines.batch_line_id%TYPE,
   p_batch_id           in    pay_batch_lines.batch_id%TYPE
   ) is
--
 l_proc  varchar2(72) := g_package||'chk_batch_id';
 l_dummy number;
--
 cursor csr_batch_id_exists is
    select null
    from pay_batch_headers bth
    where bth.batch_id = p_batch_id;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  --    Check mandatory batch_id is set
  --
  hr_api.mandatory_arg_error
    (p_api_name           => l_proc
    ,p_argument           => 'BATCH_ID'
    ,p_argument_value     => p_batch_id
    );
  --
  hr_utility.set_location(l_proc, 5);
  --
  --
  --
  -- Only proceed with validation if :
  -- a) on insert (non-updateable param)
  --
  if (p_batch_line_id is null) then
     --
     hr_utility.set_location(l_proc, 10);
     --
     -- Check that the batch_id is in the pay_batch_headers.
     --
       open csr_batch_id_exists;
       fetch csr_batch_id_exists into l_dummy;
       if csr_batch_id_exists%notfound then
          close csr_batch_id_exists;
          pay_btl_shd.constraint_error('PAY_BATCH_LINES_FK3');
       end if;
       close csr_batch_id_exists;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 15);
  --
end chk_batch_id;
--
-- ---------------------------------------------------------------------------
-- |-------------------------< chk_batch_line_status >-----------------------|
-- ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate that on insert and update batch_status is not null.
--    Also to validate against HR_LOOKUP.LOOKUP_CODE where LOOKUP_TYPE
--    'BATCH_STATUS'.
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_batch_line_status
--    p_session_date
--    p_batch_line_id
--    p_object_version_number
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_batch_line_status
  (p_batch_line_status     in    pay_batch_lines.batch_line_status%TYPE,
   p_session_date          in    date,
   p_batch_id              in    pay_batch_lines.batch_id%TYPE,
   p_batch_line_id         in    pay_batch_lines.batch_line_id%TYPE,
   p_assignment_id         in    pay_batch_lines.assignment_id%TYPE,
   p_assignment_number     in    pay_batch_lines.assignment_number%TYPE,
   p_object_version_number in    pay_batch_lines.object_version_number%TYPE
   ) is
--
  l_proc  varchar2(72) := g_package||'chk_batch_line_status';
  l_api_updating                 boolean;
--
  cursor csr_batch_header_status is
     select bth.batch_status
       from pay_batch_headers bth
      where bth.batch_id = p_batch_id;
--
  cursor csr_batch_line_asg is
     select null
       from pay_batch_lines btl
      where btl.batch_line_id = p_batch_line_id
        and ((btl.assignment_id is null and p_assignment_id is null)
             or btl.assignment_id = p_assignment_id)
        and ((btl.assignment_number is null and p_assignment_number is null)
             or btl.assignment_number = p_assignment_number);
--
  l_batch_header_status pay_batch_headers.batch_status%TYPE;
  l_dummy number;
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  --    Check mandatory batch_name exists
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'batch_line_status'
    ,p_argument_value               => p_batch_line_status
    );
  --
  --    Check mandatory session_date exists
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'session_date'
    ,p_argument_value               => p_session_date
    );
  --
  hr_utility.set_location(l_proc, 10);
  --
  l_api_updating := pay_btl_shd.api_updating
    (p_batch_line_id           => p_batch_line_id,
     p_object_version_number   => p_object_version_number
    );
  hr_utility.set_location(l_proc,20);
  --
  -- Only proceed with SQL validation if absolutely necessary
  --
  if ((l_api_updating and
       nvl(pay_btl_shd.g_old_rec.batch_line_status,hr_api.g_varchar2) <>
       nvl(p_batch_line_status,hr_api.g_varchar2))
       or (NOT l_api_updating)) then
     --
     hr_utility.set_location(l_proc,30);
     --
     --    Validate against the hr_lookup.
     --
     if hr_api.not_exists_in_hr_lookups
        (p_effective_date => p_session_date,
         p_lookup_type    => 'BATCH_STATUS',
         p_lookup_code    => p_batch_line_status) then
         pay_btl_shd.constraint_error('PAY_BCHL_BATCH_LINE_STATUS_CHK');
     end if;
     --
     --
     if ((l_api_updating) and
         nvl(pay_btl_shd.g_old_rec.batch_line_status,hr_api.g_varchar2) <>
         nvl(p_batch_line_status,hr_api.g_varchar2)) then
        --
        IF pay_btl_shd.g_old_rec.batch_line_status in ('U') then
          if p_batch_line_status not in ('U') then
            Fnd_Message.Set_Name('PER', 'HR_289267_STATUS_INVALID');
            fnd_message.raise_error;
          end if;
        ELSIF pay_btl_shd.g_old_rec.batch_line_status in ('V') then
          if p_batch_line_status not in ('V','U') then
            Fnd_Message.Set_Name('PER', 'HR_289267_STATUS_INVALID');
            fnd_message.raise_error;
          end if;
        ELSIF pay_btl_shd.g_old_rec.batch_line_status in ('T') then
          if p_batch_line_status not in ('T') then
            Fnd_Message.Set_Name('PER', 'HR_289267_STATUS_INVALID');
            fnd_message.raise_error;
          end if;
        ELSIF pay_btl_shd.g_old_rec.batch_line_status in ('E') then
          if p_batch_line_status not in ('E','U') then
            Fnd_Message.Set_Name('PER', 'HR_289267_STATUS_INVALID');
            fnd_message.raise_error;
          end if;
        END IF;
        --
     end if;
     --
  end if;
  --
  --
  open csr_batch_header_status;
  fetch csr_batch_header_status into l_batch_header_status;
  close csr_batch_header_status;
  --
  if l_batch_header_status = 'P' then
    fnd_message.set_name('PAY', 'PAY_33240_BTH_STATUS_CHANGED');
    fnd_message.raise_error;
  end if;
  --
  if l_batch_header_status = 'T' then
    if l_api_updating then
       open csr_batch_line_asg;
       fetch csr_batch_line_asg into l_dummy;
       --
       if (csr_batch_line_asg%notfound) then
         close csr_batch_line_asg;
         fnd_message.set_name('PER', 'HR_289304_BEE_ASG_UPD_RESTRICT');
         fnd_message.raise_error;
       end if;
       --
       close csr_batch_line_asg;
    else
       fnd_message.set_name('PAY', 'PAY_33240_BTH_STATUS_CHANGED');
       fnd_message.raise_error;
    end if;
  end if;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
  --
end chk_batch_line_status;
--
-- ---------------------------------------------------------------------------
-- |----------------------------< chk_entry_type >-------------------------|
-- ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Validate entry_type against HR_LOOKUP.LOOKUP_CODE where LOOKUP_TYPE
--    'ENTRY_TYPE'.
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_entry_type
--    p_session_date
--    p_batch_line_id
--    p_object_version_number
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_entry_type
  (p_entry_type          in    pay_batch_lines.entry_type%TYPE,
   p_session_date          in    date,
   p_batch_line_id              in    pay_batch_lines.batch_line_id%TYPE,
   p_object_version_number in    pay_batch_lines.object_version_number%TYPE
   ) is
--
  l_proc  varchar2(72) := g_package||'chk_entry_type';
  l_api_updating                 boolean;
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  --    Check mandatory session_date exists
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'session_date'
    ,p_argument_value               => p_session_date
    );
  --
  hr_utility.set_location(l_proc, 10);
  --
  l_api_updating := pay_btl_shd.api_updating
    (p_batch_line_id           => p_batch_line_id,
     p_object_version_number   => p_object_version_number
    );
  hr_utility.set_location(l_proc,20);
  --
  -- Only proceed with SQL validation if absolutely necessary
  --
  if ((l_api_updating and
       nvl(pay_btl_shd.g_old_rec.entry_type,hr_api.g_varchar2) <>
       nvl(p_entry_type,hr_api.g_varchar2))
       or (NOT l_api_updating)) then
     --
     hr_utility.set_location(l_proc,30);
     --
     --    Validate against the hr_lookup.
     --
     if (p_entry_type is not null) then
        --
        hr_utility.set_location(l_proc,35);
        --
        --    Validate against the hr_lookup.
        --
        if hr_api.not_exists_in_hr_lookups
           (p_effective_date => p_session_date,
            p_lookup_type    => 'ENTRY_TYPE',
            p_lookup_code    => p_entry_type) then
            pay_btl_shd.constraint_error('PAY_BCHL_ENTRY_TYPE_CHK');
        end if;
        --
     end if;
     --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
  --
end chk_entry_type;
--
-- ---------------------------------------------------------------------------
-- |-------------------------------< chk_delete >----------------------------|
-- ---------------------------------------------------------------------------
--
--  Desciption :
--
--    Check if there is no child row exists in
--    PAY_MESSAGE_LINES.
--
--
--  Pre-conditions :
--
--
--  In Arguments :
--    p_batch_line_id
--
--  Post Success :
--    Processing continues
--
--  Post Failure :
--    An application error will be raised and processing is
--    terminated
--
--  Access Status :
--    Internal Table Handler Use only.
--
-- {End of Comments}
--
-- ---------------------------------------------------------------------------
procedure chk_delete
  (p_batch_line_id                    in    pay_batch_lines.batch_line_id%TYPE
   ) is
--
  l_proc  varchar2(72) := g_package||'chk_delete';
  l_exists   varchar2(1);
--
  cursor csr_message_lines is
    select null
    from   pay_message_lines pml
    where  pml.source_id = p_batch_line_id
    and    pml.source_type = 'L';
--
begin
  hr_utility.set_location('Entering:'||l_proc, 1);
  --
  --    Check mandatory batch_line_id exists
  --
  hr_api.mandatory_arg_error
    (p_api_name                     => l_proc
    ,p_argument                     => 'batch_line_id'
    ,p_argument_value               => p_batch_line_id
    );
  --
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  open csr_message_lines;
  --
  fetch csr_message_lines into l_exists;
  --
  If csr_message_lines%found Then
    --
    close csr_message_lines;
    --
    fnd_message.set_name('PAY','PAY_52681_BHT_CHILD_EXISTS');
    fnd_message.raise_error;
    --
  End If;
  --
  close csr_message_lines;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
  --
end chk_delete;

--
-- ----------------------------------------------------------------------------
-- |-------------------------< chk_flex_segments >----------------------------|
-- ----------------------------------------------------------------------------
procedure chk_flex_segments(
p_rec   in pay_btl_shd.g_rec_type
)
is

cursor csr_bg_id(c_batch_id pay_batch_headers.batch_id%type) is
    select pbh.business_group_id
    from pay_batch_headers pbh
    where pbh.batch_id = c_batch_id;

cursor csr_id_flex_num(c_business_group_id  pay_batch_headers.business_group_id%type)is
    select cost_allocation_structure
    from per_business_groups
    where business_group_id= c_business_group_id;

  l_business_group_id   pay_batch_headers.business_group_id%type;
  l_id_flex_num pay_cost_allocation_keyflex.id_flex_num%type;
  l_segments  pay_btl_shd.segment_value;


begin

open csr_bg_id(p_rec.batch_id);
    fetch csr_bg_id into l_business_group_id;
    close csr_bg_id;

open csr_id_flex_num(l_business_group_id);
    fetch csr_id_flex_num into l_id_flex_num;
    --
    if csr_id_flex_num%notfound then
      close csr_id_flex_num;
      --
      -- the flex structure has not been found therefore we must error
      --
      hr_utility.set_message(801, 'HR_7460_PLK_NO_CST_ALLC_STRUCT');
      hr_utility.set_message_token('BUSINESS_GROUP_ID',l_business_group_id);
      hr_utility.raise_error;
    end if;
    close csr_id_flex_num;


  l_segments := pay_btl_shd.segment_value( p_rec.segment1, p_rec.segment2, p_rec.segment3, p_rec.segment4,
                             p_rec.segment5, p_rec.segment6, p_rec.segment7, p_rec.segment8,
                             p_rec.segment9, p_rec.segment10,p_rec.segment11,p_rec.segment12,
                             p_rec.segment13,p_rec.segment14,p_rec.segment15,p_rec.segment16,
                             p_rec.segment17,p_rec.segment18,p_rec.segment19,p_rec.segment20,
                             p_rec.segment21,p_rec.segment22,p_rec.segment23,p_rec.segment24,
                             p_rec.segment25,p_rec.segment26,p_rec.segment27,p_rec.segment28,
                             p_rec.segment29,p_rec.segment30);

  for i in 1..l_segments.count loop
  if l_segments(i) is not null then
  chk_mandatory_segments(
          p_level               => 'ELEMENT ENTRY',
          p_cost_id_flex_num    => l_id_flex_num,
          p_segment             => l_segments
  );
  exit;
  end if;
  end loop;
end chk_flex_segments;


--
-- ----------------------------------------------------------------------------
-- |---------------------------< insert_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure insert_validate
  (p_session_date                 in date,
   p_rec                          in pay_btl_shd.g_rec_type
  ) is
--



  l_proc  varchar2(72) := g_package||'insert_validate';

--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  chk_batch_id(p_batch_line_id => p_rec.batch_line_id
                  ,p_batch_id => p_rec.batch_id);
  --
  hr_utility.set_location(l_proc, 10);
  --
  pay_bth_bus.set_security_group_id(p_batch_id => p_rec.batch_id);
  --
  hr_utility.set_location(l_proc, 20);
  --
  chk_batch_line_status(p_batch_line_status => p_rec.batch_line_status
                  ,p_session_date => p_session_date
                  ,p_batch_id => p_rec.batch_id
                  ,p_batch_line_id => p_rec.batch_line_id
                  ,p_assignment_id => p_rec.assignment_id
                  ,p_assignment_number => p_rec.assignment_number
                  ,p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc, 30);
  --
  chk_entry_type(p_entry_type => p_rec.entry_type
                  ,p_session_date => p_session_date
                  ,p_batch_line_id => p_rec.batch_line_id
                  ,p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
--Validating input values with Lookup and value sets
-- Validate_Input_Values (p_session_date , p_rec   );

  chk_flex_segments(
                p_rec
		);
 End insert_validate;

--
-- ----------------------------------------------------------------------------
-- |---------------------------< update_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure update_validate
  (p_session_date                 in date,
   p_rec                          in pay_btl_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  pay_btl_bus.set_security_group_id(p_batch_line_id => p_rec.batch_line_id);
  --
  hr_utility.set_location(l_proc, 10);
  --
  chk_non_updateable_args
    (p_rec              => p_rec
    );
  --
  hr_utility.set_location(l_proc, 20);
  --
  --
  chk_transferred_status(p_batch_line_id => p_rec.batch_line_id);
  --
  hr_utility.set_location(l_proc, 25);
  --
  chk_batch_line_status(p_batch_line_status => p_rec.batch_line_status
                  ,p_session_date => p_session_date
                  ,p_batch_id => p_rec.batch_id
                  ,p_batch_line_id => p_rec.batch_line_id
                  ,p_assignment_id => p_rec.assignment_id
                  ,p_assignment_number => p_rec.assignment_number
                  ,p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(l_proc, 30);
  --
  chk_entry_type(p_entry_type => p_rec.entry_type
                  ,p_session_date => p_session_date
                  ,p_batch_line_id => p_rec.batch_line_id
                  ,p_object_version_number => p_rec.object_version_number);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 40);
  --Validating input values with Lookup and value sets
-- Validate_Input_Values (p_session_date , p_rec   );

chk_flex_segments(
                  p_rec
		 );

End update_validate;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< delete_validate >----------------------------|
-- ----------------------------------------------------------------------------
Procedure delete_validate
  (p_rec                          in pay_btl_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_validate';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call all supporting business operations
  --
  --
  if payplnk.g_payplnk_call <> true then
     chk_transferred_status(p_batch_line_id => p_rec.batch_line_id);
  end if;
  --
  hr_utility.set_location(l_proc, 8);
  --
  chk_delete(p_batch_line_id => p_rec.batch_line_id);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End delete_validate;
--
end pay_btl_bus;


/
