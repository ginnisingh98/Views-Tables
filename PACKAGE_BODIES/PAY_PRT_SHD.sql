--------------------------------------------------------
--  DDL for Package Body PAY_PRT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PRT_SHD" as
/* $Header: pyprtrhi.pkb 115.13 2003/02/28 15:52:21 alogue noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_prt_shd.';  -- Global package name
g_dynamic_sql VARCHAR2(2000); -- dynamic SQL text string
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
Procedure constraint_error
  (p_constraint_name in all_constraints.constraint_name%TYPE
  ) Is
--
  l_proc    varchar2(72) := g_package||'constraint_error';
--
Begin
  --
  If (p_constraint_name = 'PAY_RUN_TYPES_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_RUN_TYPES_UK1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  Else
    fnd_message.set_name('PAY', 'HR_7877_API_INVALID_CONSTRAINT');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('CONSTRAINT_NAME', p_constraint_name);
    fnd_message.raise_error;
  End If;
  --
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating
  (p_effective_date                   in date
  ,p_run_type_id                      in number
  ,p_object_version_number            in number
  ) Return Boolean Is
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
     run_type_id
    ,run_type_name
    ,run_method
    ,effective_start_date
    ,effective_end_date
    ,business_group_id
    ,legislation_code
    ,shortname
    ,srs_flag
    ,run_information_category
    ,run_information1
    ,run_information2
    ,run_information3
    ,run_information4
    ,run_information5
    ,run_information6
    ,run_information7
    ,run_information8
    ,run_information9
    ,run_information10
    ,run_information11
    ,run_information12
    ,run_information13
    ,run_information14
    ,run_information15
    ,run_information16
    ,run_information17
    ,run_information18
    ,run_information19
    ,run_information20
    ,run_information21
    ,run_information22
    ,run_information23
    ,run_information24
    ,run_information25
    ,run_information26
    ,run_information27
    ,run_information28
    ,run_information29
    ,run_information30
    ,object_version_number
    from    pay_run_types_f
    where   run_type_id = p_run_type_id
    and     p_effective_date
    between effective_start_date and effective_end_date;
--
  l_fct_ret boolean;
--
Begin
  --
  If (p_effective_date is null or
      p_run_type_id is null or
      p_object_version_number is null) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_run_type_id =
        pay_prt_shd.g_old_rec.run_type_id and
        p_object_version_number =
        pay_prt_shd.g_old_rec.object_version_number) Then
      --
      -- The g_old_rec is current therefore we must
      -- set the returning function to true
      --
      l_fct_ret := true;
    Else
      --
      -- Select the current row
      --
      Open C_Sel1;
      Fetch C_Sel1 Into pay_prt_shd.g_old_rec;
      If C_Sel1%notfound Then
        Close C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
        fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
        fnd_message.raise_error;
      End If;
      Close C_Sel1;
      If (p_object_version_number
          <> pay_prt_shd.g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
      End If;
      l_fct_ret := true;
    End If;
  End If;
  Return (l_fct_ret);
--
End api_updating;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< Effective_Date_Valid >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE - copied from dt_api
--
-- Description: Procedure ensures that the effective date is not null and
--              exists on or after the start of time.
--
-- ----------------------------------------------------------------------------
Procedure Effective_Date_Valid(p_effective_date in  date) Is
--
  l_proc varchar2(72) := g_package||'Effective_Date_Valid';
--
Begin
  Hr_Utility.Set_Location('Entering:'||l_proc, 5);
  --
  -- Ensure that all the mandatory arguments are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'p_effective_date',
                             p_argument_value => p_effective_date);

  If (p_effective_date < Hr_Api.g_sot) then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  End If;
  --
  -- Check that effective_date does not include a time component. If set
  -- then raise an error because it should have been truncated to just a day,
  -- month year value before the DT logic is called.
  --
  if p_effective_date <> trunc(p_effective_date) then
    hr_utility.set_message(801, 'HR_51322_DT_TIME_SET');
    hr_utility.raise_error;
  end if;
  --
  Hr_Utility.Set_Location('Leaving :'||l_proc, 10);
End Effective_Date_Valid;
-- ----------------------------------------------------------------------------
-- |----------------------< Return_Effective_Dates >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
--
-- Description: Procedure which returns the effective start and end dates for
--              the specified table and primary key as of session date.
--
-- ----------------------------------------------------------------------------
PROCEDURE return_effective_dates
          (p_effective_date         IN      DATE,
           p_base_table_name        IN      VARCHAR2,
           p_base_key_column        IN      VARCHAR2,
           p_base_key_value         IN      NUMBER,
           p_effective_start_date   IN OUT  NOCOPY  DATE,
           p_effective_end_date     IN OUT  NOCOPY  DATE) IS
--
  l_proc        VARCHAR2(72) := g_package||'return_effective_dates';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  effective_date_valid(p_effective_date => p_effective_date);
  -- Define dynamic sql text with substitution tokens
  pay_prt_shd.g_dynamic_sql :=
    'select  t.effective_start_date, '                    ||
    '        t.effective_end_date '                       ||
    'from    '||p_base_table_name||' t '                  ||
    'where   t.'||p_base_key_column||' = :p_base_key_value '  ||
    'and     :p_effective_date '                          ||
    'between t.effective_start_date and t.effective_end_date';
  -- native dynamic PL/SQL call
  EXECUTE IMMEDIATE pay_prt_shd.g_dynamic_sql
  INTO    p_effective_start_date
         ,p_effective_end_date
  USING   p_base_key_value
         ,p_effective_date;
  --
  hr_utility.set_location('Leaving :'||l_proc, 45);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    -- As no rows were returned we must error
    hr_utility.set_message(801, 'HR_7180_DT_NO_ROW_EXIST');
    hr_utility.set_message_token('TABLE_NAME', p_base_table_name);
    hr_utility.set_message_token
      ('SESSION_DATE'
      ,fnd_date.date_to_chardate(p_effective_date)
      );
    hr_utility.raise_error;
  WHEN TOO_MANY_ROWS THEN
    hr_utility.set_message(801, 'HR_7181_DT_OVERLAP_ROWS');
    hr_utility.set_message_token('TABLE_NAME', p_base_table_name);
    hr_utility.set_message_token
      ('SESSION_DATE'
      ,fnd_date.date_to_chardate(p_effective_date)
      );
    hr_utility.set_message_token('PRIMARY_VALUE', to_char(p_base_key_value));
    hr_utility.raise_error;
  WHEN OTHERS THEN
    RAISE;
--
END return_effective_dates;
-- ----------------------------------------------------------------------------
-- |------------------------< Return_Max_End_Date >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE - copied from dt_api
--
-- Description: Function returns the maximum effective_end_date for the
--              specified table and primary key.
--              NOTE: if the maximum end date doesn't exist (i.e. no rows
--                    exist for the specified table, key values) then we
--                    return the null value.
-- ----------------------------------------------------------------------------
FUNCTION return_max_end_date
         (p_base_table_name     IN  VARCHAR2,
          p_base_key_column     IN  VARCHAR2,
          p_base_key_value      IN  NUMBER)
         RETURN DATE IS
--
  l_proc     VARCHAR2(72) := g_package||'return_max_end_date';
  l_max_date DATE;
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  -- Ensure that all the mandatory arguments are not null
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'p_base_table_name',
                             p_argument_value => p_base_table_name);
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'p_base_key_column',
                             p_argument_value => p_base_key_column);
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'p_base_key_value',
                             p_argument_value => p_base_key_value);
  -- [ end of change 30.14 ]
  -- Define dynamic sql text with substitution tokens
  pay_prt_shd.g_dynamic_sql:=
    'select  max(t.effective_end_date) '||
    'from    '||p_base_table_name||' t '||
    'where   t.'||p_base_key_column||' = :p_base_key_value';
  --
  EXECUTE IMMEDIATE pay_prt_shd.g_dynamic_sql
  INTO  l_max_date
  USING p_base_key_value;
  --
  hr_utility.set_location('Leaving :'||l_proc, 10);
  RETURN(l_max_date);
--
END return_max_end_date;
-- ----------------------------------------------------------------------------
-- |----------------------< Return_Min_Start_Date >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
--
-- Description: Function returns the minimum effective_start_date for the
--              specified table and primary key.
--
-- ----------------------------------------------------------------------------
FUNCTION return_min_start_date
         (p_base_table_name in varchar2,
          p_base_key_column in varchar2,
          p_base_key_value  in number)
         RETURN DATE IS
--
  l_proc        VARCHAR2(72)    := g_package||'return_min_start_date';
  l_min_date    DATE;
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  -- Define dynamic sql text with substitution tokens
  pay_prt_shd.g_dynamic_sql :=
    'select  min(t.effective_start_date) '||
    'from    '||p_base_table_name||' t '||
    'where   t.'||p_base_key_column||' = :p_base_key_value';
  --
  EXECUTE IMMEDIATE pay_prt_shd.g_dynamic_sql
  INTO  l_min_date
  USING p_base_key_value;
  -- Need to ensure that the minimum date is NOT null. If it is then we
  -- must error
  IF (l_min_date IS NULL) THEN
      hr_utility.set_message(801, 'HR_7182_DT_NO_MIN_MAX_ROWS');
      hr_utility.set_message_token('TABLE_NAME',   p_base_table_name);
      hr_utility.raise_error;
  END IF;
  --
  hr_utility.set_location('Leaving :'||l_proc, 45);
  RETURN(l_min_date);
END return_min_start_date;
-- ----------------------------------------------------------------------------
-- |-------------------------< Future_Rows_Exists >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
--
-- Description: Function returns a boolean value. TRUE will be set if a future
--              row exists for the specified table as of effective date else
--              FALSE will be returned. A row must exist as of the effective
--              date otherwise an error will be returned.
--
-- ----------------------------------------------------------------------------
Function Future_Rows_Exist
         (p_effective_date      in  date,
          p_base_table_name     in  varchar2,
          p_base_key_column     in  varchar2,
          p_base_key_value      in  number)
         Return Boolean Is
--
  l_proc                    varchar2(72) := g_package||'Future_Rows_Exist';
  l_boolean                 boolean := false;
  l_dummy_esd               date;   -- Not required
  l_effective_end_date      date;   -- Current effective end date
  l_max_effective_end_date  date;   -- Maximum effective end date
--
Begin
  Hr_Utility.Set_Location('Entering:'||l_proc, 5);
  --
  -- Must ensure that a row exists as of the effective date supplied
  -- and we need the current effective end date
  --
  Return_Effective_Dates
    (p_effective_date           => p_effective_date,
     p_base_table_name          => p_base_table_name,
     p_base_key_column          => p_base_key_column,
     p_base_key_value           => p_base_key_value,
     p_effective_start_date     => l_dummy_esd,
     p_effective_end_date       => l_effective_end_date);
  --
  -- We must select the maximum effective end date for the datetracked
  -- rows
  --
  l_max_effective_end_date :=
    Return_Max_End_Date
      (p_base_table_name    => p_base_table_name,
       p_base_key_column        => p_base_key_column,
       p_base_key_value         => p_base_key_value);
  --
  -- If the maximum effective end date is greater than the current effective
  -- end date then future rows exist
  --
  If (l_max_effective_end_date > l_effective_end_date) then
    l_boolean := TRUE;
  End If;
  --
  Hr_Utility.Set_Location('Leaving :'||l_proc, 15);
  Return(l_boolean);
--
End Future_Rows_Exist;
-- ----------------------------------------------------------------------------
-- |--------------------< Return_Min_Parent_End_Date >------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
--
-- Description: Function returns the minimum validation end date for all the
--              specified parental entitites.
--
-- ----------------------------------------------------------------------------
Function Return_Min_Parent_End_Date
         (p_effective_date      in      date,
          p_parent_table_name1  in  varchar2 default hr_api.g_varchar2,
          p_parent_key_column1  in  varchar2 default hr_api.g_varchar2,
          p_parent_key_value1   in  number   default hr_api.g_number)
/*
          p_parent_table_name2  in      varchar2 default hr_api.g_varchar2,
          p_parent_key_column2  in      varchar2 default hr_api.g_varchar2,
          p_parent_key_value2   in      number   default hr_api.g_number,
          p_parent_table_name3  in      varchar2 default hr_api.g_varchar2,
          p_parent_key_column3  in      varchar2 default hr_api.g_varchar2,
          p_parent_key_value3   in      number   default hr_api.g_number,
          p_parent_table_name4  in      varchar2 default hr_api.g_varchar2,
          p_parent_key_column4  in      varchar2 default hr_api.g_varchar2,
          p_parent_key_value4   in      number   default hr_api.g_number,
          p_parent_table_name5  in      varchar2 default hr_api.g_varchar2,
          p_parent_key_column5  in      varchar2 default hr_api.g_varchar2,
          p_parent_key_value5   in      number   default hr_api.g_number,
          p_parent_table_name6  in  varchar2 default hr_api.g_varchar2,
          p_parent_key_column6  in  varchar2 default hr_api.g_varchar2,
          p_parent_key_value6   in  number   default hr_api.g_number,
          p_parent_table_name7  in      varchar2 default hr_api.g_varchar2,
          p_parent_key_column7  in      varchar2 default hr_api.g_varchar2,
          p_parent_key_value7   in      number   default hr_api.g_number,
          p_parent_table_name8  in      varchar2 default hr_api.g_varchar2,
          p_parent_key_column8  in      varchar2 default hr_api.g_varchar2,
          p_parent_key_value8   in      number   default hr_api.g_number,
          p_parent_table_name9  in      varchar2 default hr_api.g_varchar2,
          p_parent_key_column9  in      varchar2 default hr_api.g_varchar2,
          p_parent_key_value9   in      number   default hr_api.g_number,
          p_parent_table_name10 in      varchar2 default hr_api.g_varchar2,
          p_parent_key_column10 in      varchar2 default hr_api.g_varchar2,
          p_parent_key_value10  in      number   default hr_api.g_number)
*/
         Return Date Is
--
  l_proc        varchar2(72)    := g_package||
                                   'Return_Min_Parent_End_Date';
--
  l_min_date    date        := hr_api.g_eot;    -- End Of Time
  l_counter integer;                                -- Loop counter
  l_temp_date   date;
--
  l_parent_table_name   varchar2(30);
  l_parent_key_column   varchar2(30);
  l_parent_key_value    number;
--
Begin
  Hr_Utility.Set_Location('Entering:'||l_proc, 5);
  --
--  <<Loop1>>
--  For l_counter In 1..1 Loop
    --
    -- Set the current working arguments to the corresponding functional
    -- argument values
    --
--    If    (l_counter = 1) then
      l_parent_table_name := p_parent_table_name1;
      l_parent_key_column := p_parent_key_column1;
      l_parent_key_value  := p_parent_key_value1;
/*
    ElsIf (l_counter = 2) then
      l_parent_table_name := p_parent_table_name2;
      l_parent_key_column := p_parent_key_column2;
      l_parent_key_value  := p_parent_key_value2;
    ElsIf (l_counter = 3) then
      l_parent_table_name := p_parent_table_name3;
      l_parent_key_column := p_parent_key_column3;
      l_parent_key_value  := p_parent_key_value3;
    ElsIf (l_counter = 4) then
      l_parent_table_name := p_parent_table_name4;
      l_parent_key_column := p_parent_key_column4;
      l_parent_key_value  := p_parent_key_value4;
    ElsIf (l_counter = 5) then
      l_parent_table_name := p_parent_table_name5;
      l_parent_key_column := p_parent_key_column5;
      l_parent_key_value  := p_parent_key_value5;
    ElsIf (l_counter = 6) then
      l_parent_table_name := p_parent_table_name6;
      l_parent_key_column := p_parent_key_column6;
      l_parent_key_value  := p_parent_key_value6;
    ElsIf (l_counter = 7) then
      l_parent_table_name := p_parent_table_name7;
      l_parent_key_column := p_parent_key_column7;
      l_parent_key_value  := p_parent_key_value7;
    ElsIf (l_counter = 8) then
      l_parent_table_name := p_parent_table_name8;
      l_parent_key_column := p_parent_key_column8;
      l_parent_key_value  := p_parent_key_value8;
    ElsIf (l_counter = 9) then
      l_parent_table_name := p_parent_table_name9;
      l_parent_key_column := p_parent_key_column9;
      l_parent_key_value  := p_parent_key_value9;
    Else
      l_parent_table_name := p_parent_table_name10;
      l_parent_key_column := p_parent_key_column10;
      l_parent_key_value  := p_parent_key_value10;
    End If;
*/
    --
    -- Ensure that all the working parental details have been specified
    --
    If NOT ((nvl(l_parent_table_name, hr_api.g_varchar2) =
             hr_api.g_varchar2) or
            (nvl(l_parent_key_column, hr_api.g_varchar2) =
             hr_api.g_varchar2) or
            (nvl(l_parent_key_value, hr_api.g_number)    =
             hr_api.g_number))  then
      --
      -- All the parental arguments have been specified therefore we must get
      -- the maximum effective end date for the given parent.
      --
      l_temp_date := Return_Max_End_Date
                       (p_base_table_name => l_parent_table_name,
                        p_base_key_column => l_parent_key_column,
                        p_base_key_value  => l_parent_key_value);
      --
      -- If the returned l_temp_date is null or the less than the
      -- effective_date then error because a parental row does NOT exist.
      --
      If ( l_temp_date is null or
          (l_temp_date < p_effective_date)) then
        --
        -- The parental rows specified do not exist as of the effective date
        -- therefore a serious integrity problem has ocurred
        --
        hr_utility.set_message(801, 'HR_7423_DT_INVALID_ID');
        hr_utility.set_message_token('ARGUMENT', upper(l_parent_key_column));
        hr_utility.raise_error;
      Else
        --
        -- The LEAST function will then compare the working l_min_date with the
        -- returned maximum effective end date (l_temp_date) and set the
        -- l_min_date to the minimum of these dates
        --
        l_min_date := least(l_min_date, l_temp_date);
      End If;
    End If;
--  End Loop;
  --
  Hr_Utility.Set_Location('Leaving :'||l_proc, 15);
  Return(l_min_date);
--
End Return_Min_Parent_End_Date;
-- ----------------------------------------------------------------------------
-- |--------------------< Return_Min_Parent_Start_Date >----------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
--
-- Description: Function returns the minimum validation start date for all the
--              specified parental entitites.
--
-- ----------------------------------------------------------------------------
Function Return_Min_Parent_Start_Date
         (p_effective_date      in      date,
          p_parent_table_name1  in  varchar2 default hr_api.g_varchar2,
          p_parent_key_column1  in  varchar2 default hr_api.g_varchar2,
          p_parent_key_value1   in  number   default hr_api.g_number)
/*
          p_parent_table_name2  in      varchar2 default hr_api.g_varchar2,
          p_parent_key_column2  in      varchar2 default hr_api.g_varchar2,
          p_parent_key_value2   in      number   default hr_api.g_number,
          p_parent_table_name3  in      varchar2 default hr_api.g_varchar2,
          p_parent_key_column3  in      varchar2 default hr_api.g_varchar2,
          p_parent_key_value3   in      number   default hr_api.g_number,
          p_parent_table_name4  in      varchar2 default hr_api.g_varchar2,
          p_parent_key_column4  in      varchar2 default hr_api.g_varchar2,
          p_parent_key_value4   in      number   default hr_api.g_number,
          p_parent_table_name5  in      varchar2 default hr_api.g_varchar2,
          p_parent_key_column5  in      varchar2 default hr_api.g_varchar2,
          p_parent_key_value5   in      number   default hr_api.g_number,
          p_parent_table_name6  in  varchar2 default hr_api.g_varchar2,
          p_parent_key_column6  in  varchar2 default hr_api.g_varchar2,
          p_parent_key_value6   in  number   default hr_api.g_number,
          p_parent_table_name7  in      varchar2 default hr_api.g_varchar2,
          p_parent_key_column7  in      varchar2 default hr_api.g_varchar2,
          p_parent_key_value7   in      number   default hr_api.g_number,
          p_parent_table_name8  in      varchar2 default hr_api.g_varchar2,
          p_parent_key_column8  in      varchar2 default hr_api.g_varchar2,
          p_parent_key_value8   in      number   default hr_api.g_number,
          p_parent_table_name9  in      varchar2 default hr_api.g_varchar2,
          p_parent_key_column9  in      varchar2 default hr_api.g_varchar2,
          p_parent_key_value9   in      number   default hr_api.g_number,
          p_parent_table_name10 in      varchar2 default hr_api.g_varchar2,
          p_parent_key_column10 in      varchar2 default hr_api.g_varchar2,
          p_parent_key_value10  in      number   default hr_api.g_number)
*/
         Return Date Is
--
  l_proc        varchar2(72)    := g_package||
                                   'Return_Min_Parent_Start_Date';
--
  l_min_date    date        := hr_api.g_sot;    -- Start Of Time
  l_counter integer;                                -- Loop counter
  l_temp_date   date;
--
  l_parent_table_name   varchar2(30);
  l_parent_key_column   varchar2(30);
  l_parent_key_value    number;
--
Begin
  Hr_Utility.Set_Location('Entering:'||l_proc, 5);
  --
/*
  <<Loop1>>
  For l_counter In 1..10 Loop
    --
    -- Set the current working arguments to the corresponding functional
    -- argument values
    --
    If    (l_counter = 1) then
*/
      l_parent_table_name := p_parent_table_name1;
      l_parent_key_column := p_parent_key_column1;
      l_parent_key_value  := p_parent_key_value1;
/*
    ElsIf (l_counter = 2) then
      l_parent_table_name := p_parent_table_name2;
      l_parent_key_column := p_parent_key_column2;
      l_parent_key_value  := p_parent_key_value2;
    ElsIf (l_counter = 3) then
      l_parent_table_name := p_parent_table_name3;
      l_parent_key_column := p_parent_key_column3;
      l_parent_key_value  := p_parent_key_value3;
    ElsIf (l_counter = 4) then
      l_parent_table_name := p_parent_table_name4;
      l_parent_key_column := p_parent_key_column4;
      l_parent_key_value  := p_parent_key_value4;
    ElsIf (l_counter = 5) then
      l_parent_table_name := p_parent_table_name5;
      l_parent_key_column := p_parent_key_column5;
      l_parent_key_value  := p_parent_key_value5;
    ElsIf (l_counter = 6) then
      l_parent_table_name := p_parent_table_name6;
      l_parent_key_column := p_parent_key_column6;
      l_parent_key_value  := p_parent_key_value6;
    ElsIf (l_counter = 7) then
      l_parent_table_name := p_parent_table_name7;
      l_parent_key_column := p_parent_key_column7;
      l_parent_key_value  := p_parent_key_value7;
    ElsIf (l_counter = 8) then
      l_parent_table_name := p_parent_table_name8;
      l_parent_key_column := p_parent_key_column8;
      l_parent_key_value  := p_parent_key_value8;
    ElsIf (l_counter = 9) then
      l_parent_table_name := p_parent_table_name9;
      l_parent_key_column := p_parent_key_column9;
      l_parent_key_value  := p_parent_key_value9;
    Else
      l_parent_table_name := p_parent_table_name10;
      l_parent_key_column := p_parent_key_column10;
      l_parent_key_value  := p_parent_key_value10;
    End If;
*/
    --
    -- Ensure that all the working parental details have been specified
    --
    If NOT ((nvl(l_parent_table_name, hr_api.g_varchar2) =
             hr_api.g_varchar2) or
            (nvl(l_parent_key_column, hr_api.g_varchar2) =
             hr_api.g_varchar2) or
            (nvl(l_parent_key_value, hr_api.g_number)    =
             hr_api.g_number))  then
      --
      -- All the parental arguments have been specified therefore we must get
      -- the minimum effective start date for the given parent.
      --
      l_temp_date := Return_Min_Start_Date
                       (p_base_table_name => l_parent_table_name,
                        p_base_key_column => l_parent_key_column,
                        p_base_key_value  => l_parent_key_value);
      --
      -- If the returned l_temp_date is null or greater than the
      -- effective_date then error because a parental row does NOT exist.
      --
      If ( l_temp_date is null or
          (l_temp_date > p_effective_date)) then
        --
        -- The parental rows specified do not exist as of the effective date
        -- therefore a serious integrity problem has ocurred
        --
        hr_utility.set_message(801, 'HR_7423_DT_INVALID_ID');
        hr_utility.set_message_token('ARGUMENT', upper(l_parent_key_column));
        hr_utility.raise_error;
      Else
        --
        -- The LEAST function will then compare the working l_min_date with the
        -- returned miniumum effective start date (l_temp_date) and set the
        -- l_min_date to the maximum of these dates
        --
        l_min_date := greatest(l_min_date, l_temp_date);
      End If;
    End If;
--  End Loop;
  --
  Hr_Utility.Set_Location('Leaving :'||l_proc, 15);
  Return(l_min_date);
--
End Return_Min_Parent_Start_Date;
-- ----------------------------------------------------------------------------
-- |-----------------------< Lck_Future_Rows >--------------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE - copied from dt_api
--
-- Description: Locks the entity from the effective_date to the end-of-time.
--              No processing will be completed if the p_key_value is
--              null because the column could be defined as nullable.
--              If no rows where locked for the given values then the procedure
--              will error because at least 1 row must be locked.
--
-- ----------------------------------------------------------------------------
PROCEDURE lck_future_rows
         (p_effective_date  IN DATE,
          p_table_name      IN VARCHAR2,
          p_key_column      IN VARCHAR2,
          p_key_value       IN NUMBER) IS
--
  l_proc          VARCHAR2(72)    := g_package||'lck_future_rows';
  l_dummy_num     NUMBER;
  TYPE l_csr_type IS REF CURSOR;  -- define weak REF CURSOR type
  l_csr           l_csr_type;
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that all the required parameters exist
  -- Note: we don't check the p_key_value argument
  --
  -- [ start of change 30.14 ]
    hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'p_effective_date',
                             p_argument_value => p_effective_date);
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'p_table_name',
                             p_argument_value => p_table_name);
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'p_key_column',
                             p_argument_value => p_key_column);
  -- [ end of change 30.14 ]
  -- If the p_key_value is null then we must not
  -- process the sql as it could be a nullable column.
  IF (p_key_value IS NOT NULL) THEN
    -- Define dynamic sql text with substitution tokens
    pay_prt_shd.g_dynamic_sql :=
      'select 1 '                                              ||
      'from   '||p_table_name||' t1 '                          ||
      'where  t1.'||p_key_column||' = :p_key_value '           ||
      'and    t1.effective_end_date   >= :p_effective_date '   ||
      'order  by t1.effective_start_date '                     ||
      'for    update nowait';
    --
    OPEN l_csr FOR pay_prt_shd.g_dynamic_sql USING p_key_value, p_effective_date
;
    LOOP
      FETCH l_csr INTO l_dummy_num;
      EXIT WHEN l_csr%NOTFOUND;  -- exit loop when last row is fetched
    END LOOP;
    CLOSE l_csr;
    --
    hr_utility.set_location(' Leaving:'||l_proc, 10);
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    -- The parental rows specified do not exist as of the effective date
    -- therefore a serious integrity problem has ocurred
    hr_utility.set_message(801, 'HR_7423_DT_INVALID_ID');
    hr_utility.set_message_token('ARGUMENT', upper(p_key_column));
    hr_utility.raise_error;
  WHEN hr_api.object_locked THEN
    -- The object is locked therefore we need to supply a meaningful
    -- error message.
    hr_utility.set_message(801, 'HR_7165_OBJECT_LOCKED');
    hr_utility.set_message_token('TABLE_NAME', p_table_name);
    hr_utility.raise_error;
  WHEN OTHERS THEN
    RAISE;
--
END lck_future_rows;
-- ----------------------------------------------------------------------------
-- |----------------------------< Lck_Parent >--------------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
--
-- Description: Locks the specified parental entity from the effective_date
--              to the end-of-time by calling the Lck_Future_Rows procedure.
--
-- ----------------------------------------------------------------------------
Procedure Lck_Parent
         (p_effective_date      in date,
          p_parent_table_name   in varchar2,
      p_parent_key_column   in varchar2,
      p_parent_key_value    in number) Is
--
  l_proc        varchar2(72)    := g_package||'Lck_Parent';
--
Begin
  Hr_Utility.Set_Location('Entering:'||l_proc, 5);
  --
  Lck_Future_Rows
    (p_effective_date => p_effective_date,
     p_table_name     => p_parent_table_name,
     p_key_column     => p_parent_key_column,
     p_key_value      => p_parent_key_value);
  --
  Hr_Utility.Set_Location(' Leaving:'||l_proc, 35);
End Lck_Parent;
-- ----------------------------------------------------------------------------
-- |----------------------------< Lck_Child >---------------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE - copied from dt_api
--
-- Description: Locks the specified child entity maximum row for the specified
--              parent key value:
--
--              E.g. ('X' denotes locked rows)
--
--              |---------------------------------------| Parent Entity
--              |---------|XXXXXXXXXX|                    Child DT Rows 1
--              |-------------|XXXXXXXXXXXXXXX|           Child DT Rows 2
--              |---|-----|XXXXXXXXXXXXX|                 Child DT Rows 3
--
--              After locking the maximum row, we must ensure that the
--              effective end date of the locked row cannot exceed
--              the validation start date.
--
--              No processing will be completed if the p_parent_key_value is
--              null because the column could be defined as nullable.
--
-- ----------------------------------------------------------------------------
PROCEDURE lck_child
         (p_child_table_name      IN      VARCHAR2,
          p_child_key_column      IN      VARCHAR2,
          p_parent_key_column     IN      VARCHAR2,
          p_parent_key_value      IN      NUMBER,
          p_child_fk_column       IN      VARCHAR2,
          p_validation_start_date IN      DATE) IS
--
  l_proc        VARCHAR2(72)    := g_package||'lck_child';
--
  l_lck_date    DATE;
  TYPE          l_cursor_type IS REF CURSOR;  -- define weak REF CURSOR type
  l_cursor      l_cursor_type;
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that all the required parameters exist
  -- Note: we don't check the p_parent_key_value argument
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'p_child_table_name',
                             p_argument_value => p_child_table_name);
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'p_child_key_column',
                             p_argument_value => p_child_key_column);
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'p_parent_key_column',
                             p_argument_value => p_parent_key_column);
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'p_validation_start_date',
                             p_argument_value => p_validation_start_date);
  --
  -- If the p_parent_key_value is null then we must not
  -- process the sql as it could be a nullable column.
  --
  IF (p_parent_key_value IS NOT NULL) THEN
  hr_utility.set_location(l_proc, 10);
    -- Define dynamic sql text with substitution tokens
    pay_prt_shd.g_dynamic_sql :=
      'select t1.effective_end_date effective_end_date '                   ||
      'from   '||p_child_table_name||'  t1 '                               ||
      'where  (t1.'||p_child_key_column||', '                              ||
      '        t1.effective_start_date, '                                  ||
      '        t1.effective_end_date) in '                                 ||
      '       (select t2.'||p_child_key_column||', '                       ||
      '               max(t2.effective_start_date), '                      ||
      '               max(t2.effective_end_date) '                         ||
      '        from   '||p_child_table_name||' t2 '                        ||
      '        where  t2.'||p_child_fk_column||' = :p_parent_key_value ' ||
      '        group by t2.'||p_child_key_column||')'                      ||
      'order  by t1.'||p_child_key_column||' '                             ||
      'for    update nowait';
    -- open a cursor
    OPEN  l_cursor
    FOR   pay_prt_shd.g_dynamic_sql
    USING p_parent_key_value;
  hr_utility.set_location(l_proc, 15);
    --
    LOOP
      FETCH l_cursor INTO l_lck_date;
  hr_utility.set_location(l_proc, 20);
      EXIT WHEN l_cursor%NOTFOUND;
      -- For each locked row we must ensure that the maximum end date is NOT
      -- greater than the validation start date
      IF (l_lck_date >= p_validation_start_date) THEN
        -- The maximum end date is greater than or equal to the
        -- validation start date therefore we must error
        hr_utility.set_location(l_proc, 22);
        hr_utility.set_message(801, 'HR_7201_DT_NO_DELETE_CHILD');
        hr_utility.raise_error;
      END IF;
  hr_utility.set_location('Entering:'||l_proc, 25);
    END LOOP;
    --
    CLOSE l_cursor;
    hr_utility.set_location(' Leaving:'||l_proc, 35);
  END IF;
EXCEPTION
  WHEN hr_api.object_locked THEN
    IF l_cursor%ISOPEN THEN
      CLOSE l_cursor;
    END IF;
    -- The object is locked therefore we need to supply a meaningful
    -- error message.
    hr_utility.set_message(801, 'HR_7165_OBJECT_LOCKED');
    hr_utility.set_message_token('TABLE_NAME', p_child_table_name);
    hr_utility.raise_error;
  --
  WHEN OTHERS THEN
    IF l_cursor%ISOPEN THEN
      CLOSE l_cursor;
    END IF;
    RAISE;
END lck_child;
-- ----------------------------------------------------------------------------
-- |-------------------------< Get_Insert_Dates >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE - copied from dt_api
--
-- Description: Locks and parental entity rows (if supplied) and Returns
--              the validation start and end dates for the DateTrack
--              INSERT mode
--
-- ----------------------------------------------------------------------------
Procedure Get_Insert_Dates
          (p_effective_date          in   date,
           p_base_table_name         in   varchar2,
           p_base_key_column         in   varchar2,
           p_base_key_value          in   number,
           p_parent_table_name1      in   varchar2 default hr_api.g_varchar2,
           p_parent_key_column1      in   varchar2 default hr_api.g_varchar2,
           p_parent_key_value1       in   number   default hr_api.g_number,
/*
           p_parent_table_name2      in   varchar2 default hr_api.g_varchar2,
           p_parent_key_column2      in   varchar2 default hr_api.g_varchar2,
           p_parent_key_value2       in   number   default hr_api.g_number,
           p_parent_table_name3      in   varchar2 default hr_api.g_varchar2,
           p_parent_key_column3      in   varchar2 default hr_api.g_varchar2,
           p_parent_key_value3       in   number   default hr_api.g_number,
           p_parent_table_name4      in   varchar2 default hr_api.g_varchar2,
           p_parent_key_column4      in   varchar2 default hr_api.g_varchar2,
           p_parent_key_value4       in   number   default hr_api.g_number,
           p_parent_table_name5      in   varchar2 default hr_api.g_varchar2,
           p_parent_key_column5      in   varchar2 default hr_api.g_varchar2,
           p_parent_key_value5       in   number   default hr_api.g_number,
           p_parent_table_name6      in   varchar2 default hr_api.g_varchar2,
           p_parent_key_column6      in   varchar2 default hr_api.g_varchar2,
           p_parent_key_value6       in   number   default hr_api.g_number,
           p_parent_table_name7      in   varchar2 default hr_api.g_varchar2,
           p_parent_key_column7      in   varchar2 default hr_api.g_varchar2,
           p_parent_key_value7       in   number   default hr_api.g_number,
           p_parent_table_name8      in   varchar2 default hr_api.g_varchar2,
           p_parent_key_column8      in   varchar2 default hr_api.g_varchar2,
           p_parent_key_value8       in   number   default hr_api.g_number,
           p_parent_table_name9      in   varchar2 default hr_api.g_varchar2,
           p_parent_key_column9      in   varchar2 default hr_api.g_varchar2,
           p_parent_key_value9       in   number   default hr_api.g_number,
           p_parent_table_name10     in   varchar2 default hr_api.g_varchar2,
           p_parent_key_column10     in   varchar2 default hr_api.g_varchar2,
           p_parent_key_value10      in   number   default hr_api.g_number,
*/
           p_enforce_foreign_locking in   boolean,
           p_validation_start_date   out  nocopy  date,
           p_validation_end_date     out  nocopy  date) Is
--
  l_proc        varchar2(72) := g_package||'Get_Insert_Dates';
  l_parent_table_name   varchar2(30);
  l_parent_key_column   varchar2(30);
  l_parent_key_value    number;
  l_counter             integer;   -- Loop counter
  l_dummy_date          date;
--
Begin
  Hr_Utility.Set_Location('Entering:'||l_proc, 5);
  --
  -- Step 1: Lock all parent rows specified from the effective date onwards
  --         providing that the p_enforce_foreign_locking is TRUE.
  --
  If p_enforce_foreign_locking Then
/*    For l_counter In 1..10 Loop
      --
      -- Set the current working arguments to the corresponding functional
      -- argument values
      --
      If    (l_counter = 1) then
*/
        l_parent_table_name := p_parent_table_name1;
        l_parent_key_column := p_parent_key_column1;
        l_parent_key_value  := p_parent_key_value1;
/*
      ElsIf (l_counter = 2) then
        l_parent_table_name := p_parent_table_name2;
        l_parent_key_column := p_parent_key_column2;
        l_parent_key_value  := p_parent_key_value2;
      ElsIf (l_counter = 3) then
        l_parent_table_name := p_parent_table_name3;
        l_parent_key_column := p_parent_key_column3;
        l_parent_key_value  := p_parent_key_value3;
      ElsIf (l_counter = 4) then
        l_parent_table_name := p_parent_table_name4;
        l_parent_key_column := p_parent_key_column4;
        l_parent_key_value  := p_parent_key_value4;
      ElsIf (l_counter = 5) then
        l_parent_table_name := p_parent_table_name5;
        l_parent_key_column := p_parent_key_column5;
        l_parent_key_value  := p_parent_key_value5;
      ElsIf (l_counter = 6) then
        l_parent_table_name := p_parent_table_name6;
        l_parent_key_column := p_parent_key_column6;
        l_parent_key_value  := p_parent_key_value6;
      ElsIf (l_counter = 7) then
        l_parent_table_name := p_parent_table_name7;
        l_parent_key_column := p_parent_key_column7;
        l_parent_key_value  := p_parent_key_value7;
      ElsIf (l_counter = 8) then
        l_parent_table_name := p_parent_table_name8;
        l_parent_key_column := p_parent_key_column8;
        l_parent_key_value  := p_parent_key_value8;
      ElsIf (l_counter = 9) then
        l_parent_table_name := p_parent_table_name9;
        l_parent_key_column := p_parent_key_column9;
        l_parent_key_value  := p_parent_key_value9;
      Else
        l_parent_table_name := p_parent_table_name10;
        l_parent_key_column := p_parent_key_column10;
        l_parent_key_value  := p_parent_key_value10;
      End If;
*/
      --
      -- Ensure that all the working parental details have been specified
      --
      If NOT ((nvl(l_parent_table_name, hr_api.g_varchar2) =
               hr_api.g_varchar2) or
              (nvl(l_parent_key_column, hr_api.g_varchar2) =
               hr_api.g_varchar2) or
              (nvl(l_parent_key_value, hr_api.g_number)    =
               hr_api.g_number))  then
        --
        -- All the parental arguments have been specified therefore we must
        -- attempt to lock the specified parent rows.
        --
        Lck_Parent
           (p_effective_date    => p_effective_date,
            p_parent_table_name => l_parent_table_name,
            p_parent_key_column => l_parent_key_column,
            p_parent_key_value  => l_parent_key_value);
      End If;
 --   End Loop;
  End If;
  --
  -- Set the validation start date to the effective date and
  -- the validation end date to the minimum parental end date
  --
  -- Validate the effective date
  --
  l_dummy_date :=
    Return_Min_Parent_Start_Date
      (p_effective_date      => p_effective_date,
       p_parent_table_name1  => p_parent_table_name1,
       p_parent_key_column1  => p_parent_key_column1,
       p_parent_key_value1   => p_parent_key_value1);
/*
       p_parent_table_name2  => p_parent_table_name2,
       p_parent_key_column2  => p_parent_key_column2,
       p_parent_key_value2   => p_parent_key_value2,
       p_parent_table_name3  => p_parent_table_name3,
       p_parent_key_column3  => p_parent_key_column3,
       p_parent_key_value3   => p_parent_key_value3,
       p_parent_table_name4  => p_parent_table_name4,
       p_parent_key_column4  => p_parent_key_column4,
       p_parent_key_value4   => p_parent_key_value4,
       p_parent_table_name5  => p_parent_table_name5,
       p_parent_key_column5  => p_parent_key_column5,
       p_parent_key_value5   => p_parent_key_value5,
       p_parent_table_name6  => p_parent_table_name6,
       p_parent_key_column6  => p_parent_key_column6,
       p_parent_key_value6   => p_parent_key_value6,
       p_parent_table_name7  => p_parent_table_name7,
       p_parent_key_column7  => p_parent_key_column7,
       p_parent_key_value7   => p_parent_key_value7,
       p_parent_table_name8  => p_parent_table_name8,
       p_parent_key_column8  => p_parent_key_column8,
       p_parent_key_value8   => p_parent_key_value8,
       p_parent_table_name9  => p_parent_table_name9,
       p_parent_key_column9  => p_parent_key_column9,
       p_parent_key_value9   => p_parent_key_value9,
       p_parent_table_name10 => p_parent_table_name10,
       p_parent_key_column10 => p_parent_key_column10,
       p_parent_key_value10  => p_parent_key_value10);
*/
  --
  p_validation_start_date := p_effective_date;
  p_validation_end_date   :=
    Return_Min_Parent_End_Date
      (p_effective_date     => p_effective_date,
       p_parent_table_name1 => p_parent_table_name1,
       p_parent_key_column1 => p_parent_key_column1,
       p_parent_key_value1  => p_parent_key_value1);
/*
       p_parent_table_name2 => p_parent_table_name2,
       p_parent_key_column2 => p_parent_key_column2,
       p_parent_key_value2  => p_parent_key_value2,
       p_parent_table_name3 => p_parent_table_name3,
       p_parent_key_column3 => p_parent_key_column3,
       p_parent_key_value3  => p_parent_key_value3,
       p_parent_table_name4 => p_parent_table_name4,
       p_parent_key_column4 => p_parent_key_column4,
       p_parent_key_value4  => p_parent_key_value4,
       p_parent_table_name5 => p_parent_table_name5,
       p_parent_key_column5 => p_parent_key_column5,
       p_parent_key_value5  => p_parent_key_value5,
       p_parent_table_name6  => p_parent_table_name6,
       p_parent_key_column6  => p_parent_key_column6,
       p_parent_key_value6   => p_parent_key_value6,
       p_parent_table_name7  => p_parent_table_name7,
       p_parent_key_column7  => p_parent_key_column7,
       p_parent_key_value7   => p_parent_key_value7,
       p_parent_table_name8  => p_parent_table_name8,
       p_parent_key_column8  => p_parent_key_column8,
       p_parent_key_value8   => p_parent_key_value8,
       p_parent_table_name9  => p_parent_table_name9,
       p_parent_key_column9  => p_parent_key_column9,
       p_parent_key_value9   => p_parent_key_value9,
       p_parent_table_name10 => p_parent_table_name10,
       p_parent_key_column10 => p_parent_key_column10,
       p_parent_key_value10  => p_parent_key_value10);
*/
  --
  Hr_Utility.Set_Location('Leaving :'||l_proc, 20);
--
End Get_Insert_Dates;
-- ----------------------------------------------------------------------------
-- |-----------------------< Get_Correction_Dates >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
--
-- Description: Returns the validation start and end dates for the
--              DateTrack CORRECTION mode.
--
-- ----------------------------------------------------------------------------
Procedure Get_Correction_Dates
         (p_effective_date              in      date,
          p_base_table_name             in      varchar2,
          p_base_key_column             in      varchar2,
          p_base_key_value              in      number,
          p_validation_start_date       out nocopy date,
          p_validation_end_date         out nocopy date) Is
--
  l_proc        varchar2(72)    := g_package||'Get_Correction_Dates';
  l_effective_start_date        date;   -- Holds current effective start date
  l_effective_end_date          date;   -- Holds current effective end date
--
Begin
  Hr_Utility.Set_Location('Entering:'||l_proc, 5);
  Return_Effective_Dates
    (p_effective_date           => p_effective_date,
     p_base_table_name          => p_base_table_name,
     p_base_key_column          => p_base_key_column,
     p_base_key_value           => p_base_key_value,
     p_effective_start_date     => l_effective_start_date,
     p_effective_end_date       => l_effective_end_date);
  --
  -- The CORRECTION mode will always be valid therefore we must just
  -- return the validation start and end dates
  --
  p_validation_start_date := l_effective_start_date;
  p_validation_end_date   := l_effective_end_date;
  --
  Hr_Utility.Set_Location('Leaving :'||l_proc, 10);
End Get_Correction_Dates;
-- ----------------------------------------------------------------------------
-- |--------------------------< Get_Update_Dates >----------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
--
-- Description: Returns the validation start and end dates for the
--              DateTrack UPDATE mode if allowed.
--
-- ----------------------------------------------------------------------------
Procedure Get_Update_Dates
         (p_effective_date              in      date,
          p_base_table_name             in      varchar2,
          p_base_key_column             in      varchar2,
          p_base_key_value              in      number,
          p_validation_start_date       out nocopy date,
          p_validation_end_date         out nocopy date) Is
--
  l_proc        varchar2(72)    := g_package||'Get_Update_Dates';
  l_effective_start_date        date;   -- Holds current effective start date
  l_effective_end_date          date;   -- Holds current effective end date
--
Begin
  Hr_Utility.Set_Location('Entering:'||l_proc, 5);
  --
  -- Determine if any future rows exist
  --
  If NOT (Future_Rows_Exist
          (p_effective_date     => p_effective_date,
           p_base_table_name    => p_base_table_name,
           p_base_key_column    => p_base_key_column,
           p_base_key_value     => p_base_key_value)) then
    --
    Return_Effective_Dates
      (p_effective_date           => p_effective_date,
       p_base_table_name          => p_base_table_name,
       p_base_key_column          => p_base_key_column,
       p_base_key_value           => p_base_key_value,
       p_effective_start_date     => l_effective_start_date,
       p_effective_end_date       => l_effective_end_date);
    --
    -- Providing the current effective start date is not equal to the effective
    -- date we must return the the validation start and end dates
    --
    If (l_effective_start_date <> p_effective_date) then
      p_validation_start_date := p_effective_date;
      p_validation_end_date   := l_effective_end_date;
    Else
      --
      -- We cannot perform a DateTrack update operation where the effective
      -- date is the same as the current effective end date
      --
      hr_utility.set_message(801, 'HR_7179_DT_UPD_NOT_ALLOWED');
      hr_utility.raise_error;
    End If;
  Else
      hr_utility.set_message(801, 'HR_7211_DT_UPD_ROWS_IN_FUTURE');
      hr_utility.raise_error;
  End If;
  Hr_Utility.Set_Location('Leaving :'||l_proc, 10);
--
End Get_Update_Dates;
-- ----------------------------------------------------------------------------
-- |-------------------< Get_Update_Override_Dates >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
--
-- Description: Returns the validation start and end dates for the
--              DateTrack UPDATE_OVERRIDE mode if allowed.
--
-- ----------------------------------------------------------------------------
Procedure Get_Update_Override_Dates
         (p_effective_date              in      date,
          p_base_table_name             in      varchar2,
          p_base_key_column             in      varchar2,
          p_base_key_value              in      number,
          p_validation_start_date       out nocopy     date,
          p_validation_end_date         out nocopy     date) Is
--
  l_proc        varchar2(72)    := g_package||
                                   'Get_Update_Override_Dates';
  l_effective_start_date        date;   -- Holds current effective start date
  l_effective_end_date          date;   -- Holds current effective end date
--
Begin
  Hr_Utility.Set_Location('Entering:'||l_proc, 5);
  Return_Effective_Dates
    (p_effective_date           => p_effective_date,
     p_base_table_name          => p_base_table_name,
     p_base_key_column          => p_base_key_column,
     p_base_key_value           => p_base_key_value,
     p_effective_start_date     => l_effective_start_date,
     p_effective_end_date       => l_effective_end_date);
  --
  -- If the current effective start date is not the same as the effective date
  -- and at least one future row exists then we must return the validation
  -- start and end dates
  --
  If (l_effective_start_date <> p_effective_date) then
    --
    -- As the current row does not start on the effective date we determine if
    -- any future rows exist
    --
    If (Future_Rows_Exist
          (p_effective_date     => p_effective_date,
           p_base_table_name    => p_base_table_name,
           p_base_key_column    => p_base_key_column,
           p_base_key_value     => p_base_key_value)) then
      p_validation_start_date := p_effective_date;
      p_validation_end_date   := Return_Max_End_Date
                                   (p_base_table_name => p_base_table_name,
                                    p_base_key_column => p_base_key_column,
                                    p_base_key_value  => p_base_key_value);
    Else
      hr_utility.set_message(801, 'HR_7183_DT_NO_FUTURE_ROWS');
      hr_utility.set_message_token('DT_MODE', 'update override');
      hr_utility.raise_error;
    End If;
  Else
    hr_utility.set_message(801, 'HR_7179_DT_UPD_NOT_ALLOWED');
    hr_utility.raise_error;
  End If;
  Hr_Utility.Set_Location('Leaving :'||l_proc, 20);
--
End Get_Update_Override_Dates;
-- ----------------------------------------------------------------------------
-- |-----------------< Get_Update_Change_Insert_Dates >-----------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
--
-- Description: Returns the validation start and end dates for the
--              DateTrack UPDATE_CHANGE_INSERT mode if allowed.
--
-- ----------------------------------------------------------------------------
Procedure Get_Update_Change_Insert_Dates
         (p_effective_date              in      date,
          p_base_table_name             in      varchar2,
          p_base_key_column             in      varchar2,
          p_base_key_value              in      number,
          p_validation_start_date       out nocopy     date,
          p_validation_end_date         out nocopy     date) Is
--
  l_proc        varchar2(72)    := g_package||
                                   'Get_Update_Change_Insert_Dates';
  l_effective_start_date        date;   -- Holds current effective start date
  l_effective_end_date          date;   -- Holds current effective end date
--
Begin
  Hr_Utility.Set_Location('Entering:'||l_proc, 5);
  Return_Effective_Dates
    (p_effective_date           => p_effective_date,
     p_base_table_name          => p_base_table_name,
     p_base_key_column          => p_base_key_column,
     p_base_key_value           => p_base_key_value,
     p_effective_start_date     => l_effective_start_date,
     p_effective_end_date       => l_effective_end_date);
  --
  -- If the current effective start date is not the same as the effective date
  -- and at least one future row exists then we must return the validation
  -- start and end dates
  --
  If (l_effective_start_date <> p_effective_date) then
    --
    -- As the current row does not start on the effective date we determine if
    -- any future rows exist
    --
    If (Future_Rows_Exist
          (p_effective_date     => p_effective_date,
           p_base_table_name    => p_base_table_name,
           p_base_key_column    => p_base_key_column,
           p_base_key_value     => p_base_key_value)) then
      p_validation_start_date := p_effective_date;
      p_validation_end_date   := l_effective_end_date;
    Else
      hr_utility.set_message(801, 'HR_7183_DT_NO_FUTURE_ROWS');
      hr_utility.set_message_token('DT_MODE', 'update change insert');
      hr_utility.raise_error;
    End If;
  Else
    hr_utility.set_message(801, 'HR_7179_DT_UPD_NOT_ALLOWED');
    hr_utility.raise_error;
  End If;
  Hr_Utility.Set_Location('Leaving :'||l_proc, 20);
--
End Get_Update_Change_Insert_Dates;
-- ----------------------------------------------------------------------------
-- |----------------------------< Get_Zap_Dates >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
--
-- Description: Returns the validation start and end dates for the
--              DateTrack ZAP mode.
--
-- ----------------------------------------------------------------------------
Procedure Get_Zap_Dates
         (p_effective_date              in      date,
          p_base_table_name             in      varchar2,
          p_base_key_column             in      varchar2,
          p_base_key_value              in      number,
          p_validation_start_date       out nocopy     date,
          p_validation_end_date         out nocopy     date) Is
--
  l_proc        varchar2(72)    := g_package||'Get_Zap_Dates';
--
Begin
  Hr_Utility.Set_Location('Entering:'||l_proc, 5);
  p_validation_start_date := Return_Min_Start_Date
                               (p_base_table_name => p_base_table_name,
                                p_base_key_column => p_base_key_column,
                                p_base_key_value  => p_base_key_value);
  --
  p_validation_end_date := Return_Max_End_Date
                             (p_base_table_name => p_base_table_name,
                              p_base_key_column => p_base_key_column,
                              p_base_key_value  => p_base_key_value);
  --
  Hr_Utility.Set_Location('Leaving :'||l_proc, 20);
--
End Get_Zap_Dates;
-- ----------------------------------------------------------------------------
-- |--------------------------< Get_Delete_Dates >----------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE - copied from dt_api
--
-- Description: Returns the validation start and end dates for the
--              DateTrack DELETE mode if allowed.
--
-- ----------------------------------------------------------------------------
Procedure Get_Delete_Dates
         (p_effective_date           in   date,
          p_base_table_name          in   varchar2,
          p_base_key_column          in   varchar2,
          p_base_key_value           in   number,
          p_child_table_name1        in   varchar2 default hr_api.g_varchar2,
          p_child_key_column1        in   varchar2 default hr_api.g_varchar2,
          p_child_fk_column1         in   varchar2 default hr_api.g_varchar2,
          p_child_table_name2        in   varchar2 default hr_api.g_varchar2,
          p_child_key_column2        in   varchar2 default hr_api.g_varchar2,
          p_child_fk_column2         in   varchar2 default hr_api.g_varchar2,
          p_enforce_foreign_locking  in   boolean  default true,
          p_validation_start_date    out  nocopy  date,
          p_validation_end_date      out  nocopy  date) Is
--
  l_proc         varchar2(72)    := g_package||'Get_Delete_Dates';
  l_max_end_date date;
  l_counter      integer;        -- Loop counter
--
  l_child_table_name   varchar2(30);
  l_child_key_column   varchar2(30);
  l_child_fk_column    varchar2(30);
--
Begin
  Hr_Utility.Set_Location('Entering:'||l_proc, 5);
  --
  If p_enforce_foreign_locking Then
    <<Loop1>>
    For l_counter In 1..2 Loop
      --
      -- Set the current working arguments to the corresponding functional
      -- argument values
      --
      If    (l_counter = 1) then
        l_child_table_name := p_child_table_name1;
        l_child_key_column := p_child_key_column1;
        l_child_fk_column  := p_child_fk_column1;
      ElsIf (l_counter = 2) then
        l_child_table_name := p_child_table_name2;
        l_child_key_column := p_child_key_column2;
        l_child_fk_column  := p_child_fk_column2;
      End If;
      --
      -- Ensure that all the working child details have been specified
      --
      If NOT ((nvl(l_child_table_name, hr_api.g_varchar2) =
               hr_api.g_varchar2) or
              (nvl(l_child_key_column, hr_api.g_varchar2) =
               hr_api.g_varchar2)) then
        --
        --
        -- All the child arguments have been specified therefore we must lock
        -- the child rows (if they exist).
        --
        Lck_Child
          (p_child_table_name      => l_child_table_name,
           p_child_key_column      => l_child_key_column,
           p_parent_key_column     => p_base_key_column,
           p_parent_key_value      => p_base_key_value,
           p_child_fk_column       => l_child_fk_column,
           p_validation_start_date => (p_effective_date + 1));
      End If;
    End Loop;
  End If;
  --
  -- We must get the maximum effective end date of all the DT rows for the
  -- given key.
  --
  l_max_end_date := Return_Max_End_Date
                      (p_base_table_name => p_base_table_name,
                       p_base_key_column => p_base_key_column,
                       p_base_key_value  => p_base_key_value);
  --
  -- Providing the maximum effective end date is not the same as the current
  -- effective date then we must return the validation start and end dates.
  -- However, if you attempt to do a datetrack delete where the session date is
  -- the same as your maximum date then we must error.
  --
  If (p_effective_date <> l_max_end_date) then
    p_validation_start_date := p_effective_date + 1;
    p_validation_end_date   := l_max_end_date;
  Else
    --
    -- We cannot perform a DateTrack delete operation where the effective date
    -- is the same as the maximum effective end date.
    --
    hr_utility.set_message(801, 'HR_7185_DT_DEL_NOT_ALLOWED');
    hr_utility.raise_error;
  End If;
  Hr_Utility.Set_Location('Leaving :'||l_proc, 10);
--
End Get_Delete_Dates;
-- ----------------------------------------------------------------------------
-- |-----------------------< Get_Future_Change_Dates >------------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
--
-- Description: Returns the validation start and end dates for the
--              DateTrack FUTURE_CHANGE mode if allowed.
--
-- ----------------------------------------------------------------------------
Procedure Get_Future_Change_Dates
         (p_effective_date        in   date,
          p_base_table_name       in   varchar2,
          p_base_key_column       in   varchar2,
          p_base_key_value        in   number,
          p_parent_table_name1    in   varchar2 default hr_api.g_varchar2,
          p_parent_key_column1    in   varchar2 default hr_api.g_varchar2,
          p_parent_key_value1     in   number   default hr_api.g_number,
/*
          p_parent_table_name2    in   varchar2 default hr_api.g_varchar2,
          p_parent_key_column2    in   varchar2 default hr_api.g_varchar2,
          p_parent_key_value2     in   number   default hr_api.g_number,
          p_parent_table_name3    in   varchar2 default hr_api.g_varchar2,
          p_parent_key_column3    in   varchar2 default hr_api.g_varchar2,
          p_parent_key_value3     in   number   default hr_api.g_number,
          p_parent_table_name4    in   varchar2 default hr_api.g_varchar2,
          p_parent_key_column4    in   varchar2 default hr_api.g_varchar2,
          p_parent_key_value4     in   number   default hr_api.g_number,
          p_parent_table_name5    in   varchar2 default hr_api.g_varchar2,
          p_parent_key_column5    in   varchar2 default hr_api.g_varchar2,
          p_parent_key_value5     in   number   default hr_api.g_number,
          p_parent_table_name6    in   varchar2 default hr_api.g_varchar2,
          p_parent_key_column6    in   varchar2 default hr_api.g_varchar2,
          p_parent_key_value6     in   number   default hr_api.g_number,
          p_parent_table_name7    in   varchar2 default hr_api.g_varchar2,
          p_parent_key_column7    in   varchar2 default hr_api.g_varchar2,
          p_parent_key_value7     in   number   default hr_api.g_number,
          p_parent_table_name8    in   varchar2 default hr_api.g_varchar2,
          p_parent_key_column8    in   varchar2 default hr_api.g_varchar2,
          p_parent_key_value8     in   number   default hr_api.g_number,
          p_parent_table_name9    in   varchar2 default hr_api.g_varchar2,
          p_parent_key_column9    in   varchar2 default hr_api.g_varchar2,
          p_parent_key_value9     in   number   default hr_api.g_number,
          p_parent_table_name10   in   varchar2 default hr_api.g_varchar2,
          p_parent_key_column10   in   varchar2 default hr_api.g_varchar2,
          p_parent_key_value10    in   number   default hr_api.g_number,
*/
          p_validation_start_date out nocopy  date,
          p_validation_end_date   out nocopy  date) Is
--
  l_proc        varchar2(72) := g_package||'Get_Future_Change_Dates';
  l_effective_start_date        date;   -- Holds current effective start date
  l_effective_end_date          date;   -- Holds current effective end date
  l_validation_end_date     date;
--
Begin
  Hr_Utility.Set_Location('Entering:'||l_proc, 5);
  Return_Effective_Dates
    (p_effective_date           => p_effective_date,
     p_base_table_name          => p_base_table_name,
     p_base_key_column          => p_base_key_column,
     p_base_key_value           => p_base_key_value,
     p_effective_start_date     => l_effective_start_date,
     p_effective_end_date       => l_effective_end_date);
  --
  -- Providing the current effective end date is not the end of time
  -- then we must set the validation dates
  --
  If (l_effective_end_date <> HR_Api.g_eot) then
    --
    p_validation_start_date := l_effective_end_date + 1;
    l_validation_end_date   :=
      Return_Min_Parent_End_Date
       (p_effective_date      => p_effective_date,
        p_parent_table_name1  => p_parent_table_name1,
        p_parent_key_column1  => p_parent_key_column1,
        p_parent_key_value1   => p_parent_key_value1);
/*
        p_parent_table_name2  => p_parent_table_name2,
        p_parent_key_column2  => p_parent_key_column2,
        p_parent_key_value2   => p_parent_key_value2,
        p_parent_table_name3  => p_parent_table_name3,
        p_parent_key_column3  => p_parent_key_column3,
        p_parent_key_value3   => p_parent_key_value3,
        p_parent_table_name4  => p_parent_table_name4,
        p_parent_key_column4  => p_parent_key_column4,
        p_parent_key_value4   => p_parent_key_value4,
        p_parent_table_name5  => p_parent_table_name5,
        p_parent_key_column5  => p_parent_key_column5,
        p_parent_key_value5   => p_parent_key_value5,
        p_parent_table_name6  => p_parent_table_name6,
        p_parent_key_column6  => p_parent_key_column6,
        p_parent_key_value6   => p_parent_key_value6,
        p_parent_table_name7  => p_parent_table_name7,
        p_parent_key_column7  => p_parent_key_column7,
        p_parent_key_value7   => p_parent_key_value7,
        p_parent_table_name8  => p_parent_table_name8,
        p_parent_key_column8  => p_parent_key_column8,
        p_parent_key_value8   => p_parent_key_value8,
        p_parent_table_name9  => p_parent_table_name9,
        p_parent_key_column9  => p_parent_key_column9,
        p_parent_key_value9   => p_parent_key_value9,
        p_parent_table_name10 => p_parent_table_name10,
        p_parent_key_column10 => p_parent_key_column10,
        p_parent_key_value10  => p_parent_key_value10);
*/
    --
    -- If the validation end date is set to the current effective end date
    -- then we must error as we cannot extend the end date of the current
    -- row
    --
    If (l_validation_end_date <= l_effective_end_date) then
      hr_utility.set_message(801, 'HR_7187_DT_CANNOT_EXTEND_END');
      hr_utility.set_message_token('DT_MODE', ' future changes');
      hr_utility.raise_error;
    Else
      p_validation_end_date := l_validation_end_date;
    End If;
  Else
    --
    -- The current effective end date is alreay the end of time therefore
    -- we cannot extend the end date
    --
    hr_utility.set_message(801, 'HR_7188_DT_DATE_IS_EOT');
    hr_utility.raise_error;
  End If;
  --
  Hr_Utility.Set_Location(' Leaving:'||l_proc, 15);
--
End Get_Future_Change_Dates;
-- ----------------------------------------------------------------------------
-- |--------------------< Get_Delete_Next_Change_Dates >----------------------|
-- ----------------------------------------------------------------------------
--
-- PRIVATE
--
-- Description: Returns the validation start and end dates for the
--              DateTrack FUTURE_CHANGE mode if allowed.
--
-- ----------------------------------------------------------------------------
Procedure Get_Delete_Next_Change_Dates
         (p_effective_date        in   date,
          p_base_table_name       in   varchar2,
          p_base_key_column       in   varchar2,
          p_base_key_value        in   number,
          p_parent_table_name1    in   varchar2 default hr_api.g_varchar2,
          p_parent_key_column1    in   varchar2 default hr_api.g_varchar2,
          p_parent_key_value1     in   number   default hr_api.g_number,
/*
          p_parent_table_name2    in   varchar2 default hr_api.g_varchar2,
          p_parent_key_column2    in   varchar2 default hr_api.g_varchar2,
          p_parent_key_value2     in   number   default hr_api.g_number,
          p_parent_table_name3    in   varchar2 default hr_api.g_varchar2,
          p_parent_key_column3    in   varchar2 default hr_api.g_varchar2,
          p_parent_key_value3     in   number   default hr_api.g_number,
          p_parent_table_name4    in   varchar2 default hr_api.g_varchar2,
          p_parent_key_column4    in   varchar2 default hr_api.g_varchar2,
          p_parent_key_value4     in   number   default hr_api.g_number,
          p_parent_table_name5    in   varchar2 default hr_api.g_varchar2,
          p_parent_key_column5    in   varchar2 default hr_api.g_varchar2,
          p_parent_key_value5     in   number   default hr_api.g_number,
          p_parent_table_name6    in   varchar2 default hr_api.g_varchar2,
          p_parent_key_column6    in   varchar2 default hr_api.g_varchar2,
          p_parent_key_value6     in   number   default hr_api.g_number,
          p_parent_table_name7    in   varchar2 default hr_api.g_varchar2,
          p_parent_key_column7    in   varchar2 default hr_api.g_varchar2,
          p_parent_key_value7     in   number   default hr_api.g_number,
          p_parent_table_name8    in   varchar2 default hr_api.g_varchar2,
          p_parent_key_column8    in   varchar2 default hr_api.g_varchar2,
          p_parent_key_value8     in   number   default hr_api.g_number,
          p_parent_table_name9    in   varchar2 default hr_api.g_varchar2,
          p_parent_key_column9    in   varchar2 default hr_api.g_varchar2,
          p_parent_key_value9     in   number   default hr_api.g_number,
          p_parent_table_name10   in   varchar2 default hr_api.g_varchar2,
          p_parent_key_column10   in   varchar2 default hr_api.g_varchar2,
          p_parent_key_value10    in   number   default hr_api.g_number,
*/
          p_validation_start_date out nocopy  date,
          p_validation_end_date   out nocopy  date) Is
--
  l_proc        varchar2(72) := g_package||'Get_Delete_Next_Change_Dates';
  l_effective_start_date        date;   -- Holds current effective start date
  l_effective_end_date          date;   -- Holds current effective end date
  l_validation_start_date   date;
  l_validation_end_date         date;
  l_dummy_date          date;   -- Date not used
  l_future_effective_end_date   date;   -- Holds the end date of next row
  l_min_parent_end_date     date;   -- Holds the min parental end date
--
Begin
  Hr_Utility.Set_Location('Entering:'||l_proc, 5);
  Return_Effective_Dates
    (p_effective_date           => p_effective_date,
     p_base_table_name          => p_base_table_name,
     p_base_key_column          => p_base_key_column,
     p_base_key_value           => p_base_key_value,
     p_effective_start_date     => l_effective_start_date,
     p_effective_end_date       => l_effective_end_date);
  --
  -- Providing the current effective end date is not the end of time
  -- then we must set the validation dates
  --
  If (l_effective_end_date <> HR_Api.g_eot) then
    --
    l_validation_start_date := l_effective_end_date + 1;
    p_validation_start_date := l_validation_start_date;
    --
    -- To determine the validation end date we must take the minimum date
    -- from the following three possible dates:
    -- 1: Minimum parent entity entity end date
    -- 2: If future rows exist then the effective end date of the next row
    -- 3: If no future rows exist then the end of time
    --
    l_min_parent_end_date :=
      Return_Min_Parent_End_Date
        (p_effective_date      => p_effective_date,
         p_parent_table_name1  => p_parent_table_name1,
         p_parent_key_column1  => p_parent_key_column1,
         p_parent_key_value1   => p_parent_key_value1);
/*
         p_parent_table_name2  => p_parent_table_name2,
         p_parent_key_column2  => p_parent_key_column2,
         p_parent_key_value2   => p_parent_key_value2,
         p_parent_table_name3  => p_parent_table_name3,
         p_parent_key_column3  => p_parent_key_column3,
         p_parent_key_value3   => p_parent_key_value3,
         p_parent_table_name4  => p_parent_table_name4,
         p_parent_key_column4  => p_parent_key_column4,
         p_parent_key_value4   => p_parent_key_value4,
         p_parent_table_name5  => p_parent_table_name5,
         p_parent_key_column5  => p_parent_key_column5,
         p_parent_key_value5   => p_parent_key_value5,
         p_parent_table_name6  => p_parent_table_name6,
         p_parent_key_column6  => p_parent_key_column6,
         p_parent_key_value6   => p_parent_key_value6,
         p_parent_table_name7  => p_parent_table_name7,
         p_parent_key_column7  => p_parent_key_column7,
         p_parent_key_value7   => p_parent_key_value7,
         p_parent_table_name8  => p_parent_table_name8,
         p_parent_key_column8  => p_parent_key_column8,
         p_parent_key_value8   => p_parent_key_value8,
         p_parent_table_name9  => p_parent_table_name9,
         p_parent_key_column9  => p_parent_key_column9,
         p_parent_key_value9   => p_parent_key_value9,
         p_parent_table_name10 => p_parent_table_name10,
         p_parent_key_column10 => p_parent_key_column10,
         p_parent_key_value10  => p_parent_key_value10);
*/
    --
    If (Future_Rows_Exist
          (p_effective_date     => p_effective_date,
           p_base_table_name    => p_base_table_name,
           p_base_key_column    => p_base_key_column,
           p_base_key_value     => p_base_key_value)) then
      --
      Return_Effective_Dates
        (p_effective_date             => l_validation_start_date,
         p_base_table_name            => p_base_table_name,
         p_base_key_column            => p_base_key_column,
         p_base_key_value             => p_base_key_value,
         p_effective_start_date       => l_dummy_date,
         p_effective_end_date         => l_future_effective_end_date);
      --
      l_validation_end_date :=
        least(l_min_parent_end_date, l_future_effective_end_date);
    Else
      --
      -- We only need to set the validation end date to the parent end date
      -- because if no parent end dates have been set then we always return
      -- the end of time (even if no parental details are specified)
      --
      l_validation_end_date := l_min_parent_end_date;
    End If;
    --
    -- If the validation end date is set to the current effective end date
    -- then we must error as we cannot extend the end date of the current
    -- row
    --
    If (l_validation_end_date <= l_effective_end_date) then
      hr_utility.set_message(801, 'HR_7187_DT_CANNOT_EXTEND_END');
      hr_utility.set_message_token('DT_MODE', ' delete next change');
      hr_utility.raise_error;
    Else
      p_validation_end_date := l_validation_end_date;
    End If;
  Else
    --
    -- The current effective end date is alreay the end of time therefore
    -- we cannot extend the end date
    --
    hr_utility.set_message(801, 'HR_7188_DT_DATE_IS_EOT');
    hr_utility.raise_error;
  End If;
  --
  Hr_Utility.Set_Location(' Leaving:'||l_proc, 25);
--
End Get_Delete_Next_Change_Dates;
--  ---------------------------------------------------------------------------
--  |-------------------------< validate_dt_mode >----------------------------|
--  ---------------------------------------------------------------------------
--
-- PRIVATE - copied from package dt_api. 20 procedures/functions have been
-- dopied from dt_api, to get around the invalid column error caused by the
-- assumption in dt_api.lck_child, that a child table's key will be the same
-- name as the parent table's foreign key.
--
-- As these 20 functions are copied for use only with pay_run_type_usages_f,
-- some of the code has been changed slightly to use hard coded values.
--
-- Description: Validates and returns the validation start and end dates for
--              the DateTrack mode provided.
--              Locking is also enforced within this procedure.
--              The argument p_enforce_foreign_locking determines if for the
--              correct DT mode (INSERT or DELETE) parental or child
--              foreign key entities should be locked. If this value if set to
--              false this procedure will not perform any foreign lockng
--              and it is expected to be handled by the calling process
--              (this is useful if a different method of locking is required
--              where the row  exclusive locking mechanisms is too
--              restrictive).
--
--              Locking Processing:
--
--              1. Entity range row locking:
--                 Mode                  Lock Comments
--                 --------------        ---- ---------------------------------
--                 INSERT                  N  No rows exists at this point
--                 UPDATE                  N  Current row already locked
--                 CORRECTION              N  Current row already locked
--                 UPDATE_OVERRIDE         Y  Have to lock future rows
--                 UPDATE_CHANGE_INSERT    N  Current row already locked
--                 DELETE                  Y  Have to lock future rows
--                 FUTURE_CHANGE           Y  Have to lock future rows
--                 DELETE_NEXT_CHANGE      Y  Have to lock future rows
--                                            We always lock all future rows
--                                            too ensure consistency. This
--                                            means that we may over-lock some
--                                            future rows unnessarily.
--                 ZAP                     Y  Have to lock all rows
--
--              2. Insert
--                 Parental rows are locked provided the argument
--                 p_enforce_foreign_locking has been set to TRUE.
--
--              3. Delete
--                 Child rows are locked provided the argument
--                 p_enforce_foreign_locking has been set to TRUE.
--
-- ----------------------------------------------------------------------------
Procedure Validate_DT_Mode
         (p_datetrack_mode      in   varchar2,
          p_effective_date          in   date,
          p_base_table_name         in   varchar2,
          p_base_key_column         in   varchar2,
          p_base_key_value          in   number,
          p_parent_table_name1      in   varchar2 default hr_api.g_varchar2,
          p_parent_key_column1      in   varchar2 default hr_api.g_varchar2,
          p_parent_key_value1       in   number   default hr_api.g_number,
          p_child_table_name1       in   varchar2 default hr_api.g_varchar2,
          p_child_key_column1       in   varchar2 default hr_api.g_varchar2,
          p_child_fk_column1        in   varchar2 default hr_api.g_varchar2,
          p_child_table_name2       in   varchar2 default hr_api.g_varchar2,
          p_child_key_column2       in   varchar2 default hr_api.g_varchar2,
          p_child_fk_column2        in   varchar2 default hr_api.g_varchar2,
          p_enforce_foreign_locking in   boolean  default true,
          p_validation_start_date   out  nocopy  date,
          p_validation_end_date     out  nocopy  date) Is
--
  l_proc            varchar2(72) := g_package||'Validate_DT_Mode';
  l_datetrack_mode  varchar2(30);
--
Begin
  Hr_Utility.Set_Location('Entering:'||l_proc, 5);
  l_datetrack_mode := upper(p_datetrack_mode);
  --
  Effective_Date_Valid(p_effective_date => p_effective_date);
  --
  -- Ensure that all the mandatory arguments are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'p_datetrack_mode',
                             p_argument_value => p_datetrack_mode);
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'p_base_table_name',
                             p_argument_value => p_base_table_name);
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'p_base_key_column',
                             p_argument_value => p_base_key_column);
  --
  -- Determine if any entity range row locking is required
  --
  If (l_datetrack_mode = hr_api.g_update_override     or
      l_datetrack_mode = hr_api.g_delete              or
      l_datetrack_mode = hr_api.g_future_change       or
      l_datetrack_mode = hr_api.g_delete_next_change) then
    --
    -- Perform the entity range row locking processing
    --
    Lck_Future_Rows
      (p_effective_date => p_effective_date,
       p_table_name     => p_base_table_name,
       p_key_column     => p_base_key_column,
       p_key_value      => p_base_key_value);
  --
  ElsIf l_datetrack_mode = hr_api.g_zap then
    -- As we are performing a ZAP we must lock all rows from
    -- the start of time
    Lck_Future_Rows
      (p_effective_date => hr_api.g_sot,
       p_table_name     => p_base_table_name,
       p_key_column     => p_base_key_column,
       p_key_value      => p_base_key_value);
    --
  End If;
  --
  If    (l_datetrack_mode = hr_api.g_insert) then
    --
    Get_Insert_Dates
      (p_effective_date           => p_effective_date,
       p_base_table_name          => p_base_table_name,
       p_base_key_column          => p_base_key_column,
       p_base_key_value           => p_base_key_value,
       p_parent_table_name1       => p_parent_table_name1,
       p_parent_key_column1       => p_parent_key_column1,
       p_parent_key_value1        => p_parent_key_value1,
/*
       p_parent_table_name2       => p_parent_table_name2,
       p_parent_key_column2       => p_parent_key_column2,
       p_parent_key_value2        => p_parent_key_value2,
       p_parent_table_name3       => p_parent_table_name3,
       p_parent_key_column3       => p_parent_key_column3,
       p_parent_key_value3        => p_parent_key_value3,
       p_parent_table_name4       => p_parent_table_name4,
       p_parent_key_column4       => p_parent_key_column4,
       p_parent_key_value4        => p_parent_key_value4,
       p_parent_table_name5       => p_parent_table_name5,
       p_parent_key_column5       => p_parent_key_column5,
       p_parent_key_value5        => p_parent_key_value5,
       p_parent_table_name6       => p_parent_table_name6,
       p_parent_key_column6       => p_parent_key_column6,
       p_parent_key_value6        => p_parent_key_value6,
       p_parent_table_name7       => p_parent_table_name7,
       p_parent_key_column7       => p_parent_key_column7,
       p_parent_key_value7        => p_parent_key_value7,
       p_parent_table_name8       => p_parent_table_name8,
       p_parent_key_column8       => p_parent_key_column8,
       p_parent_key_value8        => p_parent_key_value8,
       p_parent_table_name9       => p_parent_table_name9,
       p_parent_key_column9       => p_parent_key_column9,
       p_parent_key_value9        => p_parent_key_value9,
       p_parent_table_name10      => p_parent_table_name10,
       p_parent_key_column10      => p_parent_key_column10,
       p_parent_key_value10       => p_parent_key_value10,
*/
       p_enforce_foreign_locking  => p_enforce_foreign_locking,
       p_validation_start_date    => p_validation_start_date,
       p_validation_end_date      => p_validation_end_date);
    --
  ElsIf (l_datetrack_mode = hr_api.g_correction) then
    --
    Get_Correction_Dates
      (p_effective_date           => p_effective_date,
       p_base_table_name          => p_base_table_name,
       p_base_key_column          => p_base_key_column,
       p_base_key_value           => p_base_key_value,
       p_validation_start_date    => p_validation_start_date,
       p_validation_end_date      => p_validation_end_date);
    --
  ElsIf (l_datetrack_mode = hr_api.g_update) then
    --
    Get_Update_Dates
      (p_effective_date           => p_effective_date,
       p_base_table_name          => p_base_table_name,
       p_base_key_column          => p_base_key_column,
       p_base_key_value           => p_base_key_value,
       p_validation_start_date    => p_validation_start_date,
       p_validation_end_date      => p_validation_end_date);
    --
  ElsIf (l_datetrack_mode = hr_api.g_update_override) then
    --
    Get_Update_Override_Dates
      (p_effective_date           => p_effective_date,
       p_base_table_name          => p_base_table_name,
       p_base_key_column          => p_base_key_column,
       p_base_key_value           => p_base_key_value,
       p_validation_start_date    => p_validation_start_date,
       p_validation_end_date      => p_validation_end_date);
    --
  ElsIf (l_datetrack_mode = hr_api.g_update_change_insert) then
    --
    Get_Update_Change_Insert_Dates
      (p_effective_date           => p_effective_date,
       p_base_table_name          => p_base_table_name,
       p_base_key_column          => p_base_key_column,
       p_base_key_value           => p_base_key_value,
       p_validation_start_date    => p_validation_start_date,
       p_validation_end_date      => p_validation_end_date);
    --
  ElsIf (l_datetrack_mode = hr_api.g_zap) then
    --
    Get_Zap_Dates
      (p_effective_date           => p_effective_date,
       p_base_table_name          => p_base_table_name,
       p_base_key_column          => p_base_key_column,
       p_base_key_value           => p_base_key_value,
       p_validation_start_date    => p_validation_start_date,
       p_validation_end_date      => p_validation_end_date);
    --
  ElsIf (l_datetrack_mode = hr_api.g_delete) then
--   if (l_datetrack_mode = hr_api.g_delete) then
    --
    Get_Delete_Dates
      (p_effective_date           => p_effective_date,
       p_base_table_name          => p_base_table_name,
       p_base_key_column          => p_base_key_column,
       p_base_key_value           => p_base_key_value,
       p_child_table_name1        => p_child_table_name1,
       p_child_key_column1        => p_child_key_column1,
       p_child_fk_column1         => p_child_fk_column1,
       p_child_table_name2        => p_child_table_name2,
       p_child_key_column2        => p_child_key_column2,
       p_child_fk_column2         => p_child_fk_column2,
       p_enforce_foreign_locking  => p_enforce_foreign_locking,
       p_validation_start_date    => p_validation_start_date,
       p_validation_end_date      => p_validation_end_date);
    --
  ElsIf (l_datetrack_mode = hr_api.g_future_change) then
    --
    Get_Future_Change_Dates
      (p_effective_date           => p_effective_date,
       p_base_table_name          => p_base_table_name,
       p_base_key_column          => p_base_key_column,
       p_base_key_value           => p_base_key_value,
       p_parent_table_name1       => p_parent_table_name1,
       p_parent_key_column1       => p_parent_key_column1,
       p_parent_key_value1        => p_parent_key_value1,
/*
       p_parent_table_name2       => p_parent_table_name2,
       p_parent_key_column2       => p_parent_key_column2,
       p_parent_key_value2        => p_parent_key_value2,
       p_parent_table_name3       => p_parent_table_name3,
       p_parent_key_column3       => p_parent_key_column3,
       p_parent_key_value3        => p_parent_key_value3,
       p_parent_table_name4       => p_parent_table_name4,
       p_parent_key_column4       => p_parent_key_column4,
       p_parent_key_value4        => p_parent_key_value4,
       p_parent_table_name5       => p_parent_table_name5,
       p_parent_key_column5       => p_parent_key_column5,
       p_parent_key_value5        => p_parent_key_value5,
       p_parent_table_name6       => p_parent_table_name6,
       p_parent_key_column6       => p_parent_key_column6,
       p_parent_key_value6        => p_parent_key_value6,
       p_parent_table_name7       => p_parent_table_name7,
       p_parent_key_column7       => p_parent_key_column7,
       p_parent_key_value7        => p_parent_key_value7,
       p_parent_table_name8       => p_parent_table_name8,
       p_parent_key_column8       => p_parent_key_column8,
       p_parent_key_value8        => p_parent_key_value8,
       p_parent_table_name9       => p_parent_table_name9,
       p_parent_key_column9       => p_parent_key_column9,
       p_parent_key_value9        => p_parent_key_value9,
       p_parent_table_name10      => p_parent_table_name10,
       p_parent_key_column10      => p_parent_key_column10,
       p_parent_key_value10       => p_parent_key_value10,
*/
       p_validation_start_date    => p_validation_start_date,
       p_validation_end_date      => p_validation_end_date);
    --
  ElsIf (l_datetrack_mode = hr_api.g_delete_next_change) then
    --
    Get_Delete_Next_Change_Dates
      (p_effective_date           => p_effective_date,
       p_base_table_name          => p_base_table_name,
       p_base_key_column          => p_base_key_column,
       p_base_key_value           => p_base_key_value,
       p_parent_table_name1       => p_parent_table_name1,
       p_parent_key_column1       => p_parent_key_column1,
       p_parent_key_value1        => p_parent_key_value1,
/*
       p_parent_table_name2       => p_parent_table_name2,
       p_parent_key_column2       => p_parent_key_column2,
       p_parent_key_value2        => p_parent_key_value2,
       p_parent_table_name3       => p_parent_table_name3,
       p_parent_key_column3       => p_parent_key_column3,
       p_parent_key_value3        => p_parent_key_value3,
       p_parent_table_name4       => p_parent_table_name4,
       p_parent_key_column4       => p_parent_key_column4,
       p_parent_key_value4        => p_parent_key_value4,
       p_parent_table_name5       => p_parent_table_name5,
       p_parent_key_column5       => p_parent_key_column5,
       p_parent_key_value5        => p_parent_key_value5,
       p_parent_table_name6       => p_parent_table_name6,
       p_parent_key_column6       => p_parent_key_column6,
       p_parent_key_value6        => p_parent_key_value6,
       p_parent_table_name7       => p_parent_table_name7,
       p_parent_key_column7       => p_parent_key_column7,
       p_parent_key_value7        => p_parent_key_value7,
       p_parent_table_name8       => p_parent_table_name8,
       p_parent_key_column8       => p_parent_key_column8,
       p_parent_key_value8        => p_parent_key_value8,
       p_parent_table_name9       => p_parent_table_name9,
       p_parent_key_column9       => p_parent_key_column9,
       p_parent_key_value9        => p_parent_key_value9,
       p_parent_table_name10      => p_parent_table_name10,
       p_parent_key_column10      => p_parent_key_column10,
       p_parent_key_value10       => p_parent_key_value10,
*/
       p_validation_start_date    => p_validation_start_date,
       p_validation_end_date      => p_validation_end_date);
    --
  Else
    hr_utility.set_message(801, 'HR_7184_DT_MODE_UNKNOWN');
    hr_utility.set_message_token('DT_MODE', l_datetrack_mode);
    hr_utility.raise_error;
  End If;
  --
  Hr_Utility.Set_Location(' Leaving:'||l_proc, 55);
--
End Validate_DT_Mode;
-- ----------------------------------------------------------------------------
-- |---------------------------< find_dt_upd_modes >--------------------------|
-- ----------------------------------------------------------------------------
Procedure find_dt_upd_modes
  (p_effective_date         in date
  ,p_base_key_value         in number
  ,p_correction             out nocopy boolean
  ,p_update                 out nocopy boolean
  ,p_update_override        out nocopy boolean
  ,p_update_change_insert   out nocopy boolean
  ) is
--
  l_proc        varchar2(72) := g_package||'find_dt_upd_modes';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the corresponding datetrack api
  --
  dt_api.find_dt_upd_modes
    (p_effective_date        => p_effective_date
    ,p_base_table_name       => 'pay_run_types_f'
    ,p_base_key_column       => 'run_type_id'
    ,p_base_key_value        => p_base_key_value
    ,p_correction            => p_correction
    ,p_update                => p_update
    ,p_update_override       => p_update_override
    ,p_update_change_insert  => p_update_change_insert
    );
  --
  -- As run_type_name and shortname are the only updatable columns in the table,
  -- and these are limited to update mode of 'CORRECTION', following the call
  -- to dt_api.find_dt_upd_modes, if any of the parameters other than
  -- p_correction are returned as 'true' then hardcode them to false.
  -- NOTE: if columns are added in the future that need to have other update
  -- modes, then this will need to be changed.
  -- RET 12-DEC-2001 Note: run_type_name is now non-updatable, due to it being
  -- the key used in lct for uploading and downloading run type data.
  --
  if p_update then
    p_update     := false;
  end if;
  if p_update_override then
    p_update_override := false;
  end if;
  if p_update_change_insert then
    p_update_change_insert := false;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End find_dt_upd_modes;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< find_dt_del_modes >--------------------------|
-- ----------------------------------------------------------------------------
Procedure find_dt_del_modes
  (p_effective_date        in date
  ,p_base_key_value        in number
  ,p_zap                   out nocopy boolean
  ,p_delete                out nocopy boolean
  ,p_future_change         out nocopy boolean
  ,p_delete_next_change    out nocopy boolean
  ) is
  --
  l_proc                varchar2(72)    := g_package||'find_dt_del_modes';
  --
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the corresponding datetrack api
  --
  dt_api.find_dt_del_modes
   (p_effective_date                => p_effective_date
   ,p_base_table_name               => 'pay_run_types_f'
   ,p_base_key_column               => 'run_type_id'
   ,p_base_key_value                => p_base_key_value
   ,p_zap                           => p_zap
   ,p_delete                        => p_delete
   ,p_future_change                 => p_future_change
   ,p_delete_next_change            => p_delete_next_change
   );
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End find_dt_del_modes;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< upd_effective_end_date >-------------------------|
-- ----------------------------------------------------------------------------
Procedure upd_effective_end_date
  (p_effective_date                   in date
  ,p_base_key_value                   in number
  ,p_new_effective_end_date           in date
  ,p_validation_start_date            in date
  ,p_validation_end_date              in date
  ,p_object_version_number            out nocopy number
  ) is
--
  l_proc                  varchar2(72) := g_package||'upd_effective_end_date';
  l_object_version_number number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Because we are updating a row we must get the next object
  -- version number.
  --
  l_object_version_number :=
    dt_api.get_object_version_number
      (p_base_table_name    => 'pay_run_types_f'
      ,p_base_key_column    => 'run_type_id'
      ,p_base_key_value     => p_base_key_value
      );
  --
  hr_utility.set_location(l_proc, 10);
  --
  -- Update the specified datetrack row setting the effective
  -- end date to the specified new effective end date.
  --
  update  pay_run_types_f t
  set     t.effective_end_date    = p_new_effective_end_date
    ,     t.object_version_number = l_object_version_number
  where   t.run_type_id        = p_base_key_value
  and     p_effective_date
  between t.effective_start_date and t.effective_end_date;
  --
  p_object_version_number := l_object_version_number;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
End upd_effective_end_date;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
  (p_effective_date                   in date
  ,p_datetrack_mode                   in varchar2
  ,p_run_type_id                      in number
  ,p_object_version_number            in number
  ,p_validation_start_date            out nocopy date
  ,p_validation_end_date              out nocopy date
  ) is
--
  l_proc                  varchar2(72) := g_package||'lck';
  l_validation_start_date date;
  l_validation_end_date   date;
  l_argument              varchar2(30);
  --
  -- Cursor C_Sel1 selects the current locked row as of session date
  -- ensuring that the object version numbers match.
  --
  Cursor C_Sel1 is
    select
     run_type_id
    ,run_type_name
    ,run_method
    ,effective_start_date
    ,effective_end_date
    ,business_group_id
    ,legislation_code
    ,shortname
    ,srs_flag
    ,run_information_category
    ,run_information1
    ,run_information2
    ,run_information3
    ,run_information4
    ,run_information5
    ,run_information6
    ,run_information7
    ,run_information8
    ,run_information9
    ,run_information10
    ,run_information11
    ,run_information12
    ,run_information13
    ,run_information14
    ,run_information15
    ,run_information16
    ,run_information17
    ,run_information18
    ,run_information19
    ,run_information20
    ,run_information21
    ,run_information22
    ,run_information23
    ,run_information24
    ,run_information25
    ,run_information26
    ,run_information27
    ,run_information28
    ,run_information29
    ,run_information30
    ,object_version_number
    from    pay_run_types_f
    where   run_type_id = p_run_type_id
    and     p_effective_date
    between effective_start_date and effective_end_date
    for update nowait;
  --
  --
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that all the mandatory arguments are not null
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc
                            ,p_argument       => 'effective_date'
                            ,p_argument_value => p_effective_date
                            );
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc
                            ,p_argument       => 'datetrack_mode'
                            ,p_argument_value => p_datetrack_mode
                            );
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc
                            ,p_argument       => 'run_type_id'
                            ,p_argument_value => p_run_type_id
                            );
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc
                            ,p_argument       => 'object_version_number'
                            ,p_argument_value => p_object_version_number
                            );
  --
  -- Check to ensure the datetrack mode is not INSERT.
  --
  If (p_datetrack_mode <> hr_api.g_insert) then
    --
    -- We must select and lock the current row.
    --
    Open  C_Sel1;
    Fetch C_Sel1 Into pay_prt_shd.g_old_rec;
    If C_Sel1%notfound then
      Close C_Sel1;
      --
      -- The primary key is invalid therefore we must error
      --
      fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
      fnd_message.raise_error;
    End If;
    Close C_Sel1;
    If (p_object_version_number
          <> pay_prt_shd.g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
    End If;
    --
    --
    -- Validate the datetrack mode mode getting the validation start
    -- and end dates for the specified datetrack operation.
    --
    dt_api.validate_dt_mode
      (p_effective_date          => p_effective_date
      ,p_datetrack_mode          => p_datetrack_mode
      ,p_base_table_name         => 'pay_run_types_f'
      ,p_base_key_column         => 'run_type_id'
      ,p_base_key_value          => p_run_type_id
      ,p_child_table_name1       => 'pay_element_type_usages_f'
      ,p_child_key_column1       => 'element_type_usage_id'
      ,p_child_table_name2       => 'pay_run_type_org_methods_f'
      ,p_child_key_column2       => 'run_type_org_method_id'
      ,p_enforce_foreign_locking => true
      ,p_validation_start_date   => l_validation_start_date
      ,p_validation_end_date     => l_validation_end_date
      );
    --
    -- now call local validate_dt_mode for pay_run_type_usages_f
    -- Note: dt_api.validate_dt_mode cannot be used as it assumes that the
    -- child table key column has the same name as the parent table fk.
    --
    validate_dt_mode
      (p_effective_date          => p_effective_date
      ,p_datetrack_mode          => p_datetrack_mode
      ,p_base_table_name         => 'pay_run_types_f'
      ,p_base_key_column         => 'run_type_id'
      ,p_base_key_value          => p_run_type_id
      ,p_child_table_name1       => 'pay_run_type_usages_f'
      ,p_child_key_column1       => 'run_type_usage_id'
      ,p_child_fk_column1        => 'parent_run_type_id'
      ,p_child_table_name2       => 'pay_run_type_usages_f'
      ,p_child_key_column2       => 'run_type_usage_id'
      ,p_child_fk_column2        => 'child_run_type_id'
      ,p_enforce_foreign_locking => true
      ,p_validation_start_date   => l_validation_start_date
      ,p_validation_end_date     => l_validation_end_date
      );
  Else
    --
    -- We are doing a datetrack 'INSERT' which is illegal within this
    -- procedure therefore we must error (note: to lck on insert the
    -- private procedure ins_lck should be called).
    --
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','20');
    fnd_message.raise_error;
  End If;
  --
  -- Set the validation start and end date OUT arguments
  --
  p_validation_start_date := l_validation_start_date;
  p_validation_end_date   := l_validation_end_date;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 30);
--
-- We need to trap the ORA LOCK exception
--
Exception
  When HR_Api.Object_Locked then
    --
    -- The object is locked therefore we need to supply a meaningful
    -- error message.
    --
    fnd_message.set_name('PAY', 'HR_7165_OBJECT_LOCKED');
    fnd_message.set_token('TABLE_NAME', 'pay_run_types_f');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_run_type_id                    in number
  ,p_run_type_name                  in varchar2
  ,p_run_method                     in varchar2
  ,p_effective_start_date           in date
  ,p_effective_end_date             in date
  ,p_business_group_id              in number
  ,p_legislation_code               in varchar2
  ,p_shortname                      in varchar2
  ,p_srs_flag                       in varchar2
  ,p_run_information_category	    in varchar2
  ,p_run_information1		    in varchar2
  ,p_run_information2		    in varchar2
  ,p_run_information3		    in varchar2
  ,p_run_information4		    in varchar2
  ,p_run_information5		    in varchar2
  ,p_run_information6		    in varchar2
  ,p_run_information7		    in varchar2
  ,p_run_information8		    in varchar2
  ,p_run_information9		    in varchar2
  ,p_run_information10		    in varchar2
  ,p_run_information11		    in varchar2
  ,p_run_information12		    in varchar2
  ,p_run_information13		    in varchar2
  ,p_run_information14		    in varchar2
  ,p_run_information15		    in varchar2
  ,p_run_information16		    in varchar2
  ,p_run_information17		    in varchar2
  ,p_run_information18		    in varchar2
  ,p_run_information19		    in varchar2
  ,p_run_information20		    in varchar2
  ,p_run_information21		    in varchar2
  ,p_run_information22		    in varchar2
  ,p_run_information23		    in varchar2
  ,p_run_information24		    in varchar2
  ,p_run_information25		    in varchar2
  ,p_run_information26		    in varchar2
  ,p_run_information27		    in varchar2
  ,p_run_information28		    in varchar2
  ,p_run_information29		    in varchar2
  ,p_run_information30		    in varchar2
  ,p_object_version_number          in number
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.run_type_id                      := p_run_type_id;
  l_rec.run_type_name                    := p_run_type_name;
  l_rec.run_method                       := p_run_method;
  l_rec.effective_start_date             := p_effective_start_date;
  l_rec.effective_end_date               := p_effective_end_date;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.legislation_code                 := p_legislation_code;
  l_rec.shortname                        := p_shortname;
  l_rec.srs_flag                         := p_srs_flag;
  l_rec.run_information_category	 := p_run_information_category;
  l_rec.run_information1		 := p_run_information1;
  l_rec.run_information2		 := p_run_information2;
  l_rec.run_information3		 := p_run_information3;
  l_rec.run_information4		 := p_run_information4;
  l_rec.run_information5		 := p_run_information5;
  l_rec.run_information6		 := p_run_information6;
  l_rec.run_information7		 := p_run_information7;
  l_rec.run_information8		 := p_run_information8;
  l_rec.run_information9		 := p_run_information9;
  l_rec.run_information10		 := p_run_information10;
  l_rec.run_information11		 := p_run_information11;
  l_rec.run_information12		 := p_run_information12;
  l_rec.run_information13		 := p_run_information13;
  l_rec.run_information14		 := p_run_information14;
  l_rec.run_information15		 := p_run_information15;
  l_rec.run_information16		 := p_run_information16;
  l_rec.run_information17		 := p_run_information17;
  l_rec.run_information18		 := p_run_information18;
  l_rec.run_information19		 := p_run_information19;
  l_rec.run_information20		 := p_run_information20;
  l_rec.run_information21		 := p_run_information21;
  l_rec.run_information22		 := p_run_information22;
  l_rec.run_information23		 := p_run_information23;
  l_rec.run_information24		 := p_run_information24;
  l_rec.run_information25		 := p_run_information25;
  l_rec.run_information26		 := p_run_information26;
  l_rec.run_information27		 := p_run_information27;
  l_rec.run_information28		 := p_run_information28;
  l_rec.run_information29		 := p_run_information29;
  l_rec.run_information30		 := p_run_information30;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end pay_prt_shd;

/
