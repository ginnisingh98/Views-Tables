--------------------------------------------------------
--  DDL for Package Body PAY_EVQ_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_EVQ_SHD" as
/* $Header: pyevqrhi.pkb 120.0 2005/05/29 04:49:50 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_evq_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
Procedure constraint_error
  (p_constraint_name in all_constraints.constraint_name%TYPE
  ) Is
--
  l_proc        varchar2(72) := g_package||'constraint_error';
--
Begin
  --
  If (p_constraint_name = 'PAY_EVENT_QUALIFIERS_F_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_EVENT_QUALIFIERS_PK') Then
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
  ,p_event_qualifier_id               in number
  ,p_object_version_number            in number
  ) Return Boolean Is
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
     event_qualifier_id
    ,effective_start_date
    ,effective_end_date
    ,dated_table_id
    ,column_name
    ,qualifier_name
    ,legislation_code
    ,business_group_id
    ,comparison_column
    ,qualifier_definition
    ,qualifier_where_clause
    ,entry_qualification
    ,assignment_qualification
    ,multi_event_sql
    ,object_version_number
    from        pay_event_qualifiers_f
    where       event_qualifier_id = p_event_qualifier_id
    and         p_effective_date
    between     effective_start_date and effective_end_date;
--
  l_fct_ret     boolean;
--
Begin
  --
  If (p_effective_date is null or
      p_event_qualifier_id is null or
      p_object_version_number is null) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_event_qualifier_id =
        pay_evq_shd.g_old_rec.event_qualifier_id and
        p_object_version_number =
        pay_evq_shd.g_old_rec.object_version_number
) Then
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
      Fetch C_Sel1 Into pay_evq_shd.g_old_rec;
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
          <> pay_evq_shd.g_old_rec.object_version_number) Then
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
  l_proc        varchar2(72) := g_package||'find_dt_upd_modes';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the corresponding datetrack api
  --
  dt_api.find_dt_upd_modes
    (p_effective_date        => p_effective_date
    ,p_base_table_name       => 'pay_event_qualifiers_f'
    ,p_base_key_column       => 'event_qualifier_id'
    ,p_base_key_value        => p_base_key_value
    ,p_correction            => p_correction
    ,p_update                => p_update
    ,p_update_override       => p_update_override
    ,p_update_change_insert  => p_update_change_insert
    );
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
   ,p_base_table_name               => 'pay_event_qualifiers_f'
   ,p_base_key_column               => 'event_qualifier_id'
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
  ,p_object_version_number  out nocopy number
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
      (p_base_table_name    => 'pay_event_qualifiers_f'
      ,p_base_key_column    => 'event_qualifier_id'
      ,p_base_key_value     => p_base_key_value
      );
  --
  hr_utility.set_location(l_proc, 10);
  --
--
  -- Update the specified datetrack row setting the effective
  -- end date to the specified new effective end date.
  --
  update  pay_event_qualifiers_f t
  set     t.effective_end_date    = p_new_effective_end_date
    ,     t.object_version_number = l_object_version_number
  where   t.event_qualifier_id        = p_base_key_value
  and     p_effective_date
  between t.effective_start_date and t.effective_end_date;
  --
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
  ,p_event_qualifier_id               in number
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
     event_qualifier_id
    ,effective_start_date
    ,effective_end_date
    ,dated_table_id
    ,column_name
    ,qualifier_name
    ,legislation_code
    ,business_group_id
    ,comparison_column
    ,qualifier_definition
    ,qualifier_where_clause
    ,entry_qualification
    ,assignment_qualification
    ,multi_event_sql
    ,object_version_number
    from    pay_event_qualifiers_f
    where   event_qualifier_id = p_event_qualifier_id
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
                            ,p_argument       => 'event_qualifier_id'
                            ,p_argument_value => p_event_qualifier_id
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
    Fetch C_Sel1 Into pay_evq_shd.g_old_rec;
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
          <> pay_evq_shd.g_old_rec.object_version_number) Then
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
      ,p_base_table_name         => 'pay_event_qualifiers_f'
      ,p_base_key_column         => 'event_qualifier_id'
      ,p_base_key_value          => p_event_qualifier_id
      ,p_child_table_name1       => 'pay_event_value_changes_f'
      ,p_child_key_column1       => 'event_value_change_id'
      ,p_child_alt_base_key_column1       => 'event_value_change_id'
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
    fnd_message.set_token('TABLE_NAME', 'pay_event_qualifiers_f');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_event_qualifier_id             in number
  ,p_effective_start_date           in date
  ,p_effective_end_date             in date
  ,p_dated_table_id                 in number
  ,p_column_name                    in varchar2
  ,p_qualifier_name                 in varchar2
  ,p_legislation_code               in varchar2
  ,p_business_group_id              in number
  ,p_comparison_column              in varchar2
  ,p_qualifier_definition           in varchar2
  ,p_qualifier_where_clause         in varchar2
  ,p_entry_qualification            in varchar2
  ,p_assignment_qualification       in varchar2
  ,p_multi_event_sql                in varchar2
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
  l_rec.event_qualifier_id               := p_event_qualifier_id;
  l_rec.effective_start_date             := p_effective_start_date;
  l_rec.effective_end_date               := p_effective_end_date;
  l_rec.dated_table_id                   := p_dated_table_id;
  l_rec.column_name                      := p_column_name;
  l_rec.qualifier_name                   := p_qualifier_name;
  l_rec.legislation_code                 := p_legislation_code;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.comparison_column                := p_comparison_column;
  l_rec.qualifier_definition             := p_qualifier_definition;
  l_rec.qualifier_where_clause           := p_qualifier_where_clause;
  l_rec.entry_qualification              := p_entry_qualification;
  l_rec.assignment_qualification         := p_assignment_qualification;
  l_rec.multi_event_sql                  := p_multi_event_sql;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end pay_evq_shd;

/
