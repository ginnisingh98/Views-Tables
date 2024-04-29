--------------------------------------------------------
--  DDL for Package Body PAY_ETP_SHD_ND
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ETP_SHD_ND" as
/* $Header: pyetpmhi.pkb 120.3.12010000.3 2008/08/06 07:12:57 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_etp_shd_nd.';  -- Global package name
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
  l_proc        varchar2(72) := g_package||'constraint_error';
--
Begin
  --
  If (p_constraint_name = 'PAY_ELEMENT_ADDITIONAL_ENT_CHK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_ELEMENT_ADJUSTMENT_ONL_CHK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_ELEMENT_CLOSED_FOR_ENT_CHK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_ELEMENT_INDIRECT_ONLY_CHK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','20');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_ELEMENT_MULTIPLE_ENTRI_CHK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','25');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_ELEMENT_MULTIPLY_VALUE_CHK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','30');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_ELEMENT_POST_TERMINATI_CHK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','35');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_ELEMENT_PROCESSING_TYP_CHK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','40');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_ELEMENT_PROCESS_IN_RUN_CHK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','45');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_ELEMENT_STANDARD_LINK_CHK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','50');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_ELEMENT_THIRD_PARTY_PA_CHK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','55');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_ELEMENT_TYPES_F_FK1') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','60');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_ELEMENT_TYPES_F_FK2') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','65');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_ELEMENT_TYPES_F_FK3') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','70');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_ELEMENT_TYPES_F_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','75');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_ELEMENT_TYPES_F_UK2') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','80');
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
  ,p_element_type_id                  in number
  ,p_object_version_number            in number
  ) Return Boolean Is
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
     element_type_id
    ,effective_start_date
    ,effective_end_date
    ,business_group_id
    ,legislation_code
    ,formula_id
    ,input_currency_code
    ,output_currency_code
    ,classification_id
    ,benefit_classification_id
    ,additional_entry_allowed_flag
    ,adjustment_only_flag
    ,closed_for_entry_flag
    ,element_name
    ,indirect_only_flag
    ,multiple_entries_allowed_flag
    ,multiply_value_flag
    ,post_termination_rule
    ,process_in_run_flag
    ,processing_priority
    ,processing_type
    ,standard_link_flag
    ,comment_id
    ,null
    ,description
    ,legislation_subgroup
    ,qualifying_age
    ,qualifying_length_of_service
    ,qualifying_units
    ,reporting_name
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
    ,element_information_category
    ,element_information1
    ,element_information2
    ,element_information3
    ,element_information4
    ,element_information5
    ,element_information6
    ,element_information7
    ,element_information8
    ,element_information9
    ,element_information10
    ,element_information11
    ,element_information12
    ,element_information13
    ,element_information14
    ,element_information15
    ,element_information16
    ,element_information17
    ,element_information18
    ,element_information19
    ,element_information20
    ,third_party_pay_only_flag
    ,object_version_number
    ,iterative_flag
    ,iterative_formula_id
    ,iterative_priority
    ,creator_type
    ,retro_summ_ele_id
    ,grossup_flag
    ,process_mode
    ,advance_indicator
    ,advance_payable
    ,advance_deduction
    ,process_advance_entry
    ,proration_group_id
    ,proration_formula_id
    ,recalc_event_group_id
    ,once_each_period_flag
    ,time_definition_type
    ,time_definition_id
    from        pay_element_types_f
    where       element_type_id = p_element_type_id
    and         p_effective_date
    between     effective_start_date and effective_end_date;
--
  l_fct_ret     boolean;
--
Begin
  --
  If (p_effective_date is null or
      p_element_type_id is null or
      p_object_version_number is null) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_element_type_id =
        pay_etp_shd_nd.g_old_rec.element_type_id and
        p_object_version_number =
        pay_etp_shd_nd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into pay_etp_shd_nd.g_old_rec;
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
          <> pay_etp_shd_nd.g_old_rec.object_version_number) Then
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
    ,p_base_table_name       => 'pay_element_types_f'
    ,p_base_key_column       => 'element_type_id'
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
   ,p_base_table_name               => 'pay_element_types_f'
   ,p_base_key_column               => 'element_type_id'
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
      (p_base_table_name    => 'pay_element_types_f'
      ,p_base_key_column    => 'element_type_id'
      ,p_base_key_value     => p_base_key_value
      );
  --
  hr_utility.set_location(l_proc, 10);
  pay_etp_shd_nd.g_api_dml := true;  -- Set the api dml status
--
  -- Update the specified datetrack row setting the effective
  -- end date to the specified new effective end date.
  --
  update  pay_element_types_f t
  set     t.effective_end_date    = p_new_effective_end_date
    ,     t.object_version_number = l_object_version_number
  where   t.element_type_id        = p_base_key_value
  and     p_effective_date
  between t.effective_start_date and t.effective_end_date;
  --
  pay_etp_shd_nd.g_api_dml := false;   -- Unset the api dml status
  p_object_version_number := l_object_version_number;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
Exception
  When Others Then
    pay_etp_shd_nd.g_api_dml := false;   -- Unset the api dml status
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
  ,p_element_type_id                  in number
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
     element_type_id
    ,effective_start_date
    ,effective_end_date
    ,business_group_id
    ,legislation_code
    ,formula_id
    ,input_currency_code
    ,output_currency_code
    ,classification_id
    ,benefit_classification_id
    ,additional_entry_allowed_flag
    ,adjustment_only_flag
    ,closed_for_entry_flag
    ,element_name
    ,indirect_only_flag
    ,multiple_entries_allowed_flag
    ,multiply_value_flag
    ,post_termination_rule
    ,process_in_run_flag
    ,processing_priority
    ,processing_type
    ,standard_link_flag
    ,comment_id
    ,null
    ,description
    ,legislation_subgroup
    ,qualifying_age
    ,qualifying_length_of_service
    ,qualifying_units
    ,reporting_name
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
    ,element_information_category
    ,element_information1
    ,element_information2
    ,element_information3
    ,element_information4
    ,element_information5
    ,element_information6
    ,element_information7
    ,element_information8
    ,element_information9
    ,element_information10
    ,element_information11
    ,element_information12
    ,element_information13
    ,element_information14
    ,element_information15
    ,element_information16
    ,element_information17
    ,element_information18
    ,element_information19
    ,element_information20
    ,third_party_pay_only_flag
    ,object_version_number
    ,iterative_flag
    ,iterative_formula_id
    ,iterative_priority
    ,creator_type
    ,retro_summ_ele_id
    ,grossup_flag
    ,process_mode
    ,advance_indicator
    ,advance_payable
    ,advance_deduction
    ,process_advance_entry
    ,proration_group_id
    ,proration_formula_id
    ,recalc_event_group_id
    ,once_each_period_flag
    ,time_definition_type
    ,time_definition_id
    from    pay_element_types_f
    where   element_type_id = p_element_type_id
    and     p_effective_date
    between effective_start_date and effective_end_date
    for update nowait;
  --
  -- Cursor C_Sel3 select comment text
  --
  Cursor C_Sel3 is
    select hc.comment_text
    from   hr_comments hc
    where  hc.comment_id = pay_etp_shd_nd.g_old_rec.comment_id;
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
                            ,p_argument       => 'element_type_id'
                            ,p_argument_value => p_element_type_id
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
    Fetch C_Sel1 Into pay_etp_shd_nd.g_old_rec;
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
          <> pay_etp_shd_nd.g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
    End If;
    --
    -- Providing we are doing an update and a comment_id exists then
    -- we select the comment text.
    --
    If ((pay_etp_shd_nd.g_old_rec.comment_id is not null) and
        (p_datetrack_mode = hr_api.g_update             or
         p_datetrack_mode = hr_api.g_correction         or
         p_datetrack_mode = hr_api.g_update_override    or
         p_datetrack_mode = hr_api.g_update_change_insert)) then
       Open C_Sel3;
       Fetch C_Sel3 Into pay_etp_shd_nd.g_old_rec.comments;
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
    -- Validate the datetrack mode mode getting the validation start
    -- and end dates for the specified datetrack operation.
    --
    dt_api.validate_dt_mode
      (p_effective_date          	=> p_effective_date
      ,p_datetrack_mode          	=> p_datetrack_mode
      ,p_base_table_name         	=> 'pay_element_types_f'
      ,p_base_key_column         	=> 'element_type_id'
      ,p_base_key_value          	=> p_element_type_id
      ,p_child_table_name1       	=> 'pay_input_values_f'
      ,p_child_key_column1         	=> 'input_value_id'
      ,p_child_alt_base_key_column1 => 'element_type_id'
      ,p_child_table_name2       	=> 'ben_acty_base_rt_f'
      ,p_child_key_column2       	=> 'acty_base_rt_id'
      ,p_child_alt_base_key_column2 => 'element_type_id'
      ,p_child_table_name3       	=> 'pay_element_links_f'
      ,p_child_key_column3       	=> 'element_link_id'
      ,p_child_alt_base_key_column3 => 'element_type_id'
      ,p_child_table_name4       	=> 'pay_element_type_usages_f'
      ,p_child_key_column4       	=> 'element_type_usage_id'
      ,p_child_alt_base_key_column4 => 'element_type_id'
      ,p_enforce_foreign_locking 	=> true
      ,p_validation_start_date   	=> l_validation_start_date
      ,p_validation_end_date     	=> l_validation_end_date
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
    fnd_message.set_token('TABLE_NAME', 'pay_element_types_f');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_element_type_id                in number
  ,p_effective_start_date           in date
  ,p_effective_end_date             in date
  ,p_business_group_id              in number
  ,p_legislation_code               in varchar2
  ,p_formula_id                     in number
  ,p_input_currency_code            in varchar2
  ,p_output_currency_code           in varchar2
  ,p_classification_id              in number
  ,p_benefit_classification_id      in number
  ,p_additional_entry_allowed_fla   in varchar2
  ,p_adjustment_only_flag           in varchar2
  ,p_closed_for_entry_flag          in varchar2
  ,p_element_name                   in varchar2
  ,p_indirect_only_flag             in varchar2
  ,p_multiple_entries_allowed_fla   in varchar2
  ,p_multiply_value_flag            in varchar2
  ,p_post_termination_rule          in varchar2
  ,p_process_in_run_flag            in varchar2
  ,p_processing_priority            in number
  ,p_processing_type                in varchar2
  ,p_standard_link_flag             in varchar2
  ,p_comment_id                     in number
  ,p_comments                       in varchar2
  ,p_description                    in varchar2
  ,p_legislation_subgroup           in varchar2
  ,p_qualifying_age                 in number
  ,p_qualifying_length_of_service   in number
  ,p_qualifying_units               in varchar2
  ,p_reporting_name                 in varchar2
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
  ,p_element_information_category   in varchar2
  ,p_element_information1           in varchar2
  ,p_element_information2           in varchar2
  ,p_element_information3           in varchar2
  ,p_element_information4           in varchar2
  ,p_element_information5           in varchar2
  ,p_element_information6           in varchar2
  ,p_element_information7           in varchar2
  ,p_element_information8           in varchar2
  ,p_element_information9           in varchar2
  ,p_element_information10          in varchar2
  ,p_element_information11          in varchar2
  ,p_element_information12          in varchar2
  ,p_element_information13          in varchar2
  ,p_element_information14          in varchar2
  ,p_element_information15          in varchar2
  ,p_element_information16          in varchar2
  ,p_element_information17          in varchar2
  ,p_element_information18          in varchar2
  ,p_element_information19          in varchar2
  ,p_element_information20          in varchar2
  ,p_third_party_pay_only_flag      in varchar2
  ,p_object_version_number          in number
  ,p_iterative_flag                 in varchar2
  ,p_iterative_formula_id           in number
  ,p_iterative_priority             in number
  ,p_creator_type                   in varchar2
  ,p_retro_summ_ele_id              in number
  ,p_grossup_flag                   in varchar2
  ,p_process_mode                   in varchar2
  ,p_advance_indicator              in varchar2
  ,p_advance_payable                in varchar2
  ,p_advance_deduction              in varchar2
  ,p_process_advance_entry          in varchar2
  ,p_proration_group_id             in number
  ,p_proration_formula_id           in number
  ,p_recalc_event_group_id          in number
  ,p_once_each_period_flag          in varchar2
  ,p_time_definition_type           in varchar2
  ,p_time_definition_id		    in number
  )
  Return g_rec_type is
--
  l_rec   g_rec_type;
--
Begin
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.element_type_id                  := p_element_type_id;
  l_rec.effective_start_date             := p_effective_start_date;
  l_rec.effective_end_date               := p_effective_end_date;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.legislation_code                 := p_legislation_code;
  l_rec.formula_id                       := p_formula_id;
  l_rec.input_currency_code              := p_input_currency_code;
  l_rec.output_currency_code             := p_output_currency_code;
  l_rec.classification_id                := p_classification_id;
  l_rec.benefit_classification_id        := p_benefit_classification_id;
  l_rec.additional_entry_allowed_flag    := p_additional_entry_allowed_fla;
  l_rec.adjustment_only_flag             := p_adjustment_only_flag;
  l_rec.closed_for_entry_flag            := p_closed_for_entry_flag;
  l_rec.element_name                     := p_element_name;
  l_rec.indirect_only_flag               := p_indirect_only_flag;
  l_rec.multiple_entries_allowed_flag    := p_multiple_entries_allowed_fla;
  l_rec.multiply_value_flag              := p_multiply_value_flag;
  l_rec.post_termination_rule            := p_post_termination_rule;
  l_rec.process_in_run_flag              := p_process_in_run_flag;
  l_rec.processing_priority              := p_processing_priority;
  l_rec.processing_type                  := p_processing_type;
  l_rec.standard_link_flag               := p_standard_link_flag;
  l_rec.comment_id                       := p_comment_id;
  l_rec.comments                         := p_comments;
  l_rec.description                      := p_description;
  l_rec.legislation_subgroup             := p_legislation_subgroup;
  l_rec.qualifying_age                   := p_qualifying_age;
  l_rec.qualifying_length_of_service     := p_qualifying_length_of_service;
  l_rec.qualifying_units                 := p_qualifying_units;
  l_rec.reporting_name                   := p_reporting_name;
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
  l_rec.element_information_category     := p_element_information_category;
  l_rec.element_information1             := p_element_information1;
  l_rec.element_information2             := p_element_information2;
  l_rec.element_information3             := p_element_information3;
  l_rec.element_information4             := p_element_information4;
  l_rec.element_information5             := p_element_information5;
  l_rec.element_information6             := p_element_information6;
  l_rec.element_information7             := p_element_information7;
  l_rec.element_information8             := p_element_information8;
  l_rec.element_information9             := p_element_information9;
  l_rec.element_information10            := p_element_information10;
  l_rec.element_information11            := p_element_information11;
  l_rec.element_information12            := p_element_information12;
  l_rec.element_information13            := p_element_information13;
  l_rec.element_information14            := p_element_information14;
  l_rec.element_information15            := p_element_information15;
  l_rec.element_information16            := p_element_information16;
  l_rec.element_information17            := p_element_information17;
  l_rec.element_information18            := p_element_information18;
  l_rec.element_information19            := p_element_information19;
  l_rec.element_information20            := p_element_information20;
  l_rec.third_party_pay_only_flag        := p_third_party_pay_only_flag;
  l_rec.object_version_number            := p_object_version_number;
  l_rec.iterative_flag                   := p_iterative_flag;
  l_rec.iterative_formula_id             := p_iterative_formula_id;
  l_rec.iterative_priority               := p_iterative_priority;
  l_rec.creator_type                     := p_creator_type;
  l_rec.retro_summ_ele_id                := p_retro_summ_ele_id;
  l_rec.grossup_flag                     := p_grossup_flag;
  l_rec.process_mode                     := p_process_mode;
  l_rec.advance_indicator                := p_advance_indicator;
  l_rec.advance_payable                  := p_advance_payable;
  l_rec.advance_deduction                := p_advance_deduction;
  l_rec.process_advance_entry            := p_process_advance_entry;
  l_rec.proration_group_id               := p_proration_group_id;
  l_rec.proration_formula_id             := p_proration_formula_id;
  l_rec.recalc_event_group_id            := p_recalc_event_group_id;
  l_rec.once_each_period_flag            := p_once_each_period_flag;
  l_rec.time_definition_type		 := p_time_definition_type;
  l_rec.time_definition_id		 := p_time_definition_id;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end pay_etp_shd_nd;

/
