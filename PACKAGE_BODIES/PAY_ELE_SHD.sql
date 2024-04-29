--------------------------------------------------------
--  DDL for Package Body PAY_ELE_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ELE_SHD" as
/* $Header: pyelerhi.pkb 120.1 2005/05/30 05:19:19 rajeesha noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_ele_shd.';  -- Global package name
g_counter  number;
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
Function return_api_dml_status Return Boolean Is
--
Begin
  --
  Return (nvl(g_api_dml, false));
  --
End return_api_dml_status;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
Procedure constraint_error
  (p_constraint_name in all_constraints.constraint_name%TYPE
  ) Is
--
  l_proc 	varchar2(72) := g_package||'constraint_error';
--
Begin
  --
  If (p_constraint_name = 'PAY_ELEMENT_ENTRIES_F_FK1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_ELEMENT_ENTRIES_F_FK3') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_ELEMENT_ENTRIES_F_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_EL_ENTRY_CREATOR_TYPE_CHK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','20');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_EL_ENTRY_ENTRY_TYPE_CHK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','25');
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
  ,p_element_entry_id                 in number
  ,p_object_version_number            in number
  ) Return Boolean Is
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
     element_entry_id
    ,effective_start_date
    ,effective_end_date
    ,cost_allocation_keyflex_id
    ,assignment_id
    ,updating_action_id
    ,updating_action_type
    ,element_link_id
    ,original_entry_id
    ,creator_type
    ,entry_type
    ,comment_id
    ,null
    ,creator_id
    ,reason
    ,target_entry_id
    ,attribute_category
    ,attribute1
    ,attribute2
    ,attribute3
    ,attribute4
    ,attribute5
    ,attribute6
    ,attribute7
    ,attribute8
    ,attribute9
    ,attribute10
    ,attribute11
    ,attribute12
    ,attribute13
    ,attribute14
    ,attribute15
    ,attribute16
    ,attribute17
    ,attribute18
    ,attribute19
    ,attribute20
-- --
  ,
  entry_information_category,
  entry_information1,
  entry_information2,
  entry_information3,
  entry_information4,
  entry_information5,
  entry_information6,
  entry_information7,
  entry_information8,
  entry_information9,
  entry_information10,
  entry_information11,
  entry_information12,
  entry_information13,
  entry_information14,
  entry_information15,
  entry_information16,
  entry_information17,
  entry_information18,
  entry_information19,
  entry_information20,
  entry_information21,
  entry_information22,
  entry_information23,
  entry_information24,
  entry_information25,
  entry_information26,
  entry_information27,
  entry_information28,
  entry_information29,
  entry_information30
    ,subpriority
    ,personal_payment_method_id
    ,date_earned
    ,object_version_number
    ,source_id
    ,balance_adj_cost_flag
    ,element_type_id
    ,all_entry_values_null
    from	pay_element_entries_f
    where	element_entry_id = p_element_entry_id
    and		p_effective_date
    between	effective_start_date and effective_end_date;
--

  l_fct_ret	boolean;
--
Begin
  --
  If (p_effective_date is null or
      p_element_entry_id is null or
      p_object_version_number is null) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_element_entry_id =
        pay_ele_shd.g_old_rec.element_entry_id and
        p_object_version_number =
        pay_ele_shd.g_old_rec.object_version_number) Then
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
      Fetch C_Sel1 Into pay_ele_shd.g_old_rec;
      If C_Sel1%notfound Then
        Close C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
        fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
        fnd_message.raise_error;
      End If;
      Close C_Sel1;

    -- 11-NOV-03
    -- Caching for Hard calls to DYT_PKG removed

      If (p_object_version_number
          <> pay_ele_shd.g_old_rec.object_version_number) Then
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
  l_proc 	varchar2(72) := g_package||'find_dt_upd_modes';
--
  l_type	varchar2(1);
--
  Cursor C_chk_type Is
    select  pet.processing_type
    from    pay_element_types_f   pet,
            pay_element_entries_f pee,
            pay_element_links_f   pel
    where   pet.element_type_id = pel.element_type_id
    and     pel.element_link_id = pee.element_link_id
    and     pee.element_entry_id = p_base_key_value
    and     p_effective_date
      between pee.effective_start_date and pee.effective_end_date
    and     p_effective_date
      between pel.effective_start_date and pel.effective_end_date
    and     p_effective_date
      between pet.effective_start_date and pet.effective_end_date;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the corresponding datetrack api
  --
  dt_api.find_dt_upd_modes
    (p_effective_date        => p_effective_date
    ,p_base_table_name       => 'pay_element_entries_f'
    ,p_base_key_column       => 'element_entry_id'
    ,p_base_key_value        => p_base_key_value
    ,p_correction            => p_correction
    ,p_update                => p_update
    ,p_update_override       => p_update_override
    ,p_update_change_insert  => p_update_change_insert
    );
  --
  -- Entity  modifications
  -- For UPDATES: All Datetrack update functions can be performed for
  -- Recurring Entries, while only 'CORRECTION' is valid for Non Recurring
  -- Entries (since they are only valid over a single Payroll period)
  --
  Open  C_chk_type;
  Fetch C_chk_type Into l_type;
  If C_chk_type%notfound then
    Close C_chk_type;
    hr_utility.set_message(800, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  End If;
  Close C_chk_type;
  --
  if l_type = 'N' then
    p_update := FALSE;
    p_update_override := FALSE;
    p_update_change_insert := FALSE;
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
  l_proc 		varchar2(72) 	:= g_package||'find_dt_del_modes';
  --
  l_parent_key_value1   number;
  l_parent_key_value2   number;
  l_type                varchar2(1);
  --
  Cursor C_Sel1 Is
    select
     t.assignment_id
    ,t.element_link_id
    from   pay_element_entries_f t
    where  t.element_entry_id = p_base_key_value
    and    p_effective_date
    between t.effective_start_date and t.effective_end_date;
  --
  Cursor C_chk_type Is
    select  pet.processing_type
    from    pay_element_types_f   pet,
            pay_element_entries_f pee,
            pay_element_links_f   pel
    where   pet.element_type_id = pel.element_type_id
    and     pel.element_link_id = pee.element_link_id
    and     pee.element_entry_id = p_base_key_value
    and     p_effective_date
      between pee.effective_start_date and pee.effective_end_date
    and     p_effective_date
      between pel.effective_start_date and pel.effective_end_date
    and     p_effective_date
      between pet.effective_start_date and pet.effective_end_date;
  --
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  Open C_sel1;
  Fetch C_Sel1 Into
     l_parent_key_value1
    ,l_parent_key_value2;
  If C_Sel1%NOTFOUND then
    Close C_Sel1;
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
     fnd_message.set_token('PROCEDURE',l_proc);
     fnd_message.set_token('STEP','10');
     fnd_message.raise_error;
  End If;
  Close C_Sel1;
  --
  -- Call the corresponding datetrack api
  --
  dt_api.find_dt_del_modes
   (p_effective_date                => p_effective_date
   ,p_base_table_name               => 'pay_element_entries_f'
   ,p_base_key_column               => 'element_entry_id'
   ,p_base_key_value                => p_base_key_value
   ,p_parent_table_name1            => 'per_all_assignments_f'
   ,p_parent_key_column1            => 'assignment_id'
   ,p_parent_key_value1             => l_parent_key_value1
   ,p_parent_table_name2            => 'pay_element_links_f'
   ,p_parent_key_column2            => 'element_link_id'
   ,p_parent_key_value2             => l_parent_key_value2
   ,p_zap                           => p_zap
   ,p_delete                        => p_delete
   ,p_future_change                 => p_future_change
   ,p_delete_next_change            => p_delete_next_change
   );
  --
  -- Entity specific modifications
  --
  -- For DELETES: All Datetrack delete functions can be performed for
  -- Recurring Entries while only 'Purge' is valid for Non Recurring Entries
  -- since these Entries are only valid over a single Payroll period.
  --
  Open  C_chk_type;
  Fetch C_chk_type Into l_type;
  If C_chk_type%notfound then
    Close C_chk_type;
    hr_utility.set_message(800, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  End If;
  Close C_chk_type;
  --
  if l_type = 'N' then
    p_delete := FALSE;
    p_future_change := FALSE;
    p_delete_next_change := FALSE;
  end if;
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
  ,p_object_version_number  out nocopy number
  ) is
--
  l_proc 		  varchar2(72) := g_package||'upd_effective_end_date';
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
      (p_base_table_name    => 'pay_element_entries_f'
      ,p_base_key_column    => 'element_entry_id'
      ,p_base_key_value     => p_base_key_value
      );
  --
  hr_utility.set_location(l_proc, 10);
  pay_ele_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the specified datetrack row setting the effective
  -- end date to the specified new effective end date.
  --
  update  pay_element_entries_f t
  set     t.effective_end_date    = p_new_effective_end_date
    ,     t.object_version_number = l_object_version_number
  where   t.element_entry_id        = p_base_key_value
  and     p_effective_date
  between t.effective_start_date and t.effective_end_date;
  --
  pay_ele_shd.g_api_dml := false;   -- Unset the api dml status
  p_object_version_number := l_object_version_number;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
Exception
  When Others Then
    pay_ele_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
--
End upd_effective_end_date;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
  (p_effective_date                   in date
  ,p_datetrack_mode                   in varchar2
  ,p_element_entry_id                 in number
  ,p_object_version_number            in number
  ,p_validation_start_date            out nocopy date
  ,p_validation_end_date              out nocopy date
  ) is
--
  l_proc		  varchar2(72) := g_package||'lck';
  l_validation_start_date date;
  l_validation_end_date	  date;
  l_argument		  varchar2(30);


  v_assignment_id number;
  cur_id number;
  --
  -- Cursor C_Sel1 selects the current locked row as of session date
  -- ensuring that the object version numbers match.
  --
  Cursor C_Sel1 is
    select
     element_entry_id
    ,effective_start_date
    ,effective_end_date
    ,cost_allocation_keyflex_id
    ,assignment_id
    ,updating_action_id
    ,updating_action_type
    ,element_link_id
    ,original_entry_id
    ,creator_type
    ,entry_type
    ,comment_id
    ,null
    ,creator_id
    ,reason
    ,target_entry_id
    ,attribute_category
    ,attribute1
    ,attribute2
    ,attribute3
    ,attribute4
    ,attribute5
    ,attribute6
    ,attribute7
    ,attribute8
    ,attribute9
    ,attribute10
    ,attribute11
    ,attribute12
    ,attribute13
    ,attribute14
    ,attribute15
    ,attribute16
    ,attribute17
    ,attribute18
    ,attribute19
    ,attribute20
-- --
  ,
  entry_information_category,
  entry_information1,
  entry_information2,
  entry_information3,
  entry_information4,
  entry_information5,
  entry_information6,
  entry_information7,
  entry_information8,
  entry_information9,
  entry_information10,
  entry_information11,
  entry_information12,
  entry_information13,
  entry_information14,
  entry_information15,
  entry_information16,
  entry_information17,
  entry_information18,
  entry_information19,
  entry_information20,
  entry_information21,
  entry_information22,
  entry_information23,
  entry_information24,
  entry_information25,
  entry_information26,
  entry_information27,
  entry_information28,
  entry_information29,
  entry_information30
    ,subpriority
    ,personal_payment_method_id
    ,date_earned
    ,object_version_number
    ,source_id
    ,balance_adj_cost_flag
    ,element_type_id
    ,all_entry_values_null
    from    pay_element_entries_f
    where   element_entry_id = p_element_entry_id
    and	    p_effective_date
    between effective_start_date and effective_end_date
    for update nowait;
  --
  -- Cursor C_Sel3 select comment text
  --
  Cursor C_Sel3 is
    select hc.comment_text
    from   hr_comments hc
    where  hc.comment_id = pay_ele_shd.g_old_rec.comment_id;
  --
  -- Assignment locking cursor
  --
  cursor c_sel4 is
    select assignment_id
    from   per_all_assignments_f
    where  assignment_id = pay_ele_shd.g_old_rec.assignment_id
    for update nowait;
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
                            ,p_argument       => 'element_entry_id'
                            ,p_argument_value => p_element_entry_id
                            );
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc
                            ,p_argument       => 'object_version_number'
                            ,p_argument_value => p_object_version_number
                            );

  hr_utility.set_location('done arg error check'||l_proc, 51);

  --
  -- Check to ensure the datetrack mode is not INSERT.
  --

  If (p_datetrack_mode <> hr_api.g_insert) then
    --
    -- We must select and lock the current row.
    --
    Open  C_Sel1;
    Fetch C_Sel1 Into pay_ele_shd.g_old_rec;
    If C_Sel1%notfound then
      Close C_Sel1;
      --
      -- The primary key is invalid therefore we must error
      --
      fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
      fnd_message.raise_error;
    End If;
    Close C_Sel1;
    hr_utility.set_location('Entering ovn check:'||l_proc, 52);

    If (p_object_version_number
          <> pay_ele_shd.g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
    End If;
    --
    -- Providing we are doing an update and a comment_id exists then
    -- we select the comment text.
    --
    If ((pay_ele_shd.g_old_rec.comment_id is not null) and
        (p_datetrack_mode = hr_api.g_update             or
         p_datetrack_mode = hr_api.g_correction         or
         p_datetrack_mode = hr_api.g_update_override    or
         p_datetrack_mode = hr_api.g_update_change_insert)) then
       Open C_Sel3;
       Fetch C_Sel3 Into pay_ele_shd.g_old_rec.comments;
       If C_Sel3%notfound then
          --
          -- The comments for the specified comment_id does not exist.
          -- We must error due to data integrity problems.
          --
          Close C_Sel3;
          fnd_message.set_name('PAY', 'HR_7202_COMMENT_TEXT_NOT_EXIST');
          fnd_message.raise_error;
       End If;
       Close C_Sel3;
    End If;

    --
    -- Note, we are doing the foreign table locking ourselves now
    -- First, lock all rows with given assignment ID on
    -- PER_ALL_ASSIGNMENTS_F table with exclusive row locks
    --
	-- Lock rows in per_all_assignments_f based on passed assignment_id.
	-- Simply select the row for update to lock it in exclusive mode
	-- as we are taking this functionality out of the validate_dt_mode
	-- below
	for i in c_sel4 loop
	  null;
     end loop;

    -- We must also lock the pay_element_links_f in shared mode.
    lock table pay_element_links_f in row share mode nowait;

    --
    -- Validate the datetrack mode mode getting the validation start
    -- and end dates for the specified datetrack operation.
    --
    dt_api.validate_dt_mode
      (p_effective_date          => p_effective_date
      ,p_datetrack_mode          => p_datetrack_mode
      ,p_base_table_name         => 'pay_element_entries_f'
      ,p_base_key_column         => 'element_entry_id'
      ,p_base_key_value          => p_element_entry_id
      ,p_parent_table_name1      => 'per_all_assignments_f'
      ,p_parent_key_column1      => 'assignment_id'
      ,p_parent_key_value1       => pay_ele_shd.g_old_rec.assignment_id
      ,p_parent_table_name2      => 'pay_element_links_f'
      ,p_parent_key_column2      => 'element_link_id'
      ,p_parent_key_value2       => pay_ele_shd.g_old_rec.element_link_id
      ,p_enforce_foreign_locking => false
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
    fnd_message.set_token('TABLE_NAME', 'pay_element_entries_f');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< convert_lookups >----------------------------|
-- ----------------------------------------------------------------------------
FUNCTION convert_lookups
  (
  p_input_value_id number,
  p_entry_value    varchar2,
  p_effective_date date
  ) RETURN VARCHAR2 IS
  --
  CURSOR C_Lookup IS
  SELECT piv.lookup_type,
         piv.value_set_id
  FROM   pay_input_values_f piv
  WHERE  piv.input_value_id = p_input_value_id
  AND    nvl(p_effective_date,sysdate)
                          between piv.effective_start_date
                              and piv.effective_end_date;
  --
  l_proc	varchar2(72) := g_package||'convert_lookups';
  l_lookup_type hr_lookups.lookup_type%type := NULL;
  l_meaning     varchar2(240) := NULL;
  l_value_set_id number(10) := NULL;
  --
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Validate the length of the entry
  --
  IF LENGTH(p_entry_value) > 60 THEN
     hr_utility.set_location('Entering:'||l_proc, 7);
     hr_utility.set_message(801, 'HR_7049_ELE_ENTRY_LENGTH');
     hr_utility.raise_error;
  END IF;
  --
  hr_utility.set_location('Entering:'||l_proc, 9);
  OPEN  C_Lookup;
  FETCH C_Lookup
  INTO  l_lookup_type, l_value_set_id;
  IF l_lookup_type IS NOT NULL THEN
     hr_utility.set_location('Entering:'||l_proc, 11);
     l_meaning := hr_general.decode_lookup(l_lookup_type, p_entry_value);
     --
     IF l_meaning IS NULL THEN
       --
       -- Bugfix 2678606
       -- No matching meaning was found, therefore entry value must be
       -- invalid. Raise appropriate error
       --
       hr_utility.set_message(801, 'HR_7033_ELE_ENTRY_LKUP_INVLD');
       hr_utility.set_message_token('LOOKUP_TYPE',l_lookup_type);
       hr_utility.raise_error;
       --
     END IF;
     --
  ELSIF l_value_set_id IS NOT NULL THEN
    --
    -- Enhancement 2793978
    -- Convert value set value
    --
    hr_utility.set_location('Entering:'||l_proc, 12);
    l_meaning := pay_input_values_pkg.decode_vset_value(
      l_value_set_id,
      p_entry_value);
    --
    IF l_meaning IS NULL THEN
      --
      -- No matching meaning was found, therefore entry value must be
      -- invalid. Raise appropriate error.
      --
      hr_utility.set_message(800, 'HR_34927_ELE_ENTRY_VSET_INVLD');
      hr_utility.set_message_token('VALUE',p_entry_value);
      hr_utility.raise_error;
      --
    END IF;
    --
  ELSE
     l_meaning := p_entry_value;
  END IF;
  CLOSE C_Lookup;
  --
  RETURN(l_meaning);
  hr_utility.set_location(' Leaving:'||l_proc, 20);
  --
END convert_lookups;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_element_entry_id               in number
  ,p_effective_start_date           in date
  ,p_effective_end_date             in date
  ,p_cost_allocation_keyflex_id     in number
  ,p_assignment_id                  in number
  ,p_updating_action_id             in number
  ,p_updating_action_type           in varchar2
  ,p_element_link_id                in number
  ,p_original_entry_id              in number
  ,p_creator_type                   in varchar2
  ,p_entry_type                     in varchar2
  ,p_comment_id                     in number
  ,p_comments                       in varchar2
  ,p_creator_id                     in number
  ,p_reason                         in varchar2
  ,p_target_entry_id                in number
  ,p_attribute_category             in varchar2
  ,p_attribute1                     in varchar2
  ,p_attribute2                     in varchar2
  ,p_attribute3                     in varchar2
  ,p_attribute4                     in varchar2
  ,p_attribute5                     in varchar2
  ,p_attribute6                     in varchar2
  ,p_attribute7                     in varchar2
  ,p_attribute8                     in varchar2
  ,p_attribute9                     in varchar2
  ,p_attribute10                    in varchar2
  ,p_attribute11                    in varchar2
  ,p_attribute12                    in varchar2
  ,p_attribute13                    in varchar2
  ,p_attribute14                    in varchar2
  ,p_attribute15                    in varchar2
  ,p_attribute16                    in varchar2
  ,p_attribute17                    in varchar2
  ,p_attribute18                    in varchar2
  ,p_attribute19                    in varchar2
  ,p_attribute20                    in varchar2
  ,p_subpriority                    in number
  ,p_personal_payment_method_id     in number
  ,p_date_earned                    in date
  ,p_object_version_number          in number
  ,p_source_id                      in number
  ,p_balance_adj_cost_flag          in varchar2
  ,p_element_type_id                in number
  ,p_all_entry_values_null          in varchar2
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.element_entry_id                 := p_element_entry_id;
  l_rec.effective_start_date             := p_effective_start_date;
  l_rec.effective_end_date               := p_effective_end_date;
  l_rec.cost_allocation_keyflex_id       := p_cost_allocation_keyflex_id;
  l_rec.assignment_id                    := p_assignment_id;
  l_rec.updating_action_id               := p_updating_action_id;
  l_rec.updating_action_type             := p_updating_action_type;
  l_rec.element_link_id                  := p_element_link_id;
  l_rec.original_entry_id                := p_original_entry_id;
  l_rec.creator_type                     := p_creator_type;
  l_rec.entry_type                       := p_entry_type;
  l_rec.comment_id                       := p_comment_id;
  l_rec.comments                         := p_comments;
  l_rec.creator_id                       := p_creator_id;
  l_rec.reason                           := p_reason;
  l_rec.target_entry_id                  := p_target_entry_id;
  l_rec.attribute_category               := p_attribute_category;
  l_rec.attribute1                       := p_attribute1;
  l_rec.attribute2                       := p_attribute2;
  l_rec.attribute3                       := p_attribute3;
  l_rec.attribute4                       := p_attribute4;
  l_rec.attribute5                       := p_attribute5;
  l_rec.attribute6                       := p_attribute6;
  l_rec.attribute7                       := p_attribute7;
  l_rec.attribute8                       := p_attribute8;
  l_rec.attribute9                       := p_attribute9;
  l_rec.attribute10                      := p_attribute10;
  l_rec.attribute11                      := p_attribute11;
  l_rec.attribute12                      := p_attribute12;
  l_rec.attribute13                      := p_attribute13;
  l_rec.attribute14                      := p_attribute14;
  l_rec.attribute15                      := p_attribute15;
  l_rec.attribute16                      := p_attribute16;
  l_rec.attribute17                      := p_attribute17;
  l_rec.attribute18                      := p_attribute18;
  l_rec.attribute19                      := p_attribute19;
  l_rec.attribute20                      := p_attribute20;
  l_rec.subpriority                      := p_subpriority;
  l_rec.personal_payment_method_id       := p_personal_payment_method_id;
  l_rec.date_earned                      := p_date_earned;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.source_id                        := p_source_id;
  l_rec.balance_adj_cost_flag            := p_balance_adj_cost_flag;
  l_rec.element_type_id                  := p_element_type_id;
  l_rec.all_entry_values_null            := p_all_entry_values_null;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end pay_ele_shd;

/
