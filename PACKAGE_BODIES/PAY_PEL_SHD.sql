--------------------------------------------------------
--  DDL for Package Body PAY_PEL_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PEL_SHD" as
/* $Header: pypelrhi.pkb 120.7.12010000.3 2008/10/03 08:41:56 ankagarw ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_pel_shd.';  -- Global package name

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
  If (p_constraint_name = 'PAY_ELEMENT_LINKS_F_FK10') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_ELEMENT_LINKS_F_FK11') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_ELEMENT_LINKS_F_FK12') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','15');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_ELEMENT_LINKS_F_FK13') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','20');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_ELEMENT_LINKS_F_FK2') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','25');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_ELEMENT_LINKS_F_FK4') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','30');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_ELEMENT_LINKS_F_FK5') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','35');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_ELEMENT_LINKS_F_FK6') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','40');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_ELEMENT_LINKS_F_FK8') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','45');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_ELEMENT_LINKS_F_FK9') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','50');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_ELEMENT_LINKS_F_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','55');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_LINK_COSTABLE_TYPE_CHK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','60');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_LINK_LINK_TO_ALL_PAYRO_CHK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','65');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_LINK_MULTIPLY_VALUE_FL_CHK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','70');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_LINK_STANDARD_LINK_FLA_CHK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','75');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'PAY_LINK_TRANSFER_TO_GL_FL_CHK') Then
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
  ,p_element_link_id                  in number
  ,p_object_version_number            in number
  ) Return Boolean Is
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
     element_link_id
    ,effective_start_date
    ,effective_end_date
    ,payroll_id
    ,job_id
    ,position_id
    ,people_group_id
    ,cost_allocation_keyflex_id
    ,organization_id
    ,element_type_id
    ,location_id
    ,grade_id
    ,balancing_keyflex_id
    ,business_group_id
    ,element_set_id
    ,pay_basis_id
    ,costable_type
    ,link_to_all_payrolls_flag
    ,multiply_value_flag
    ,standard_link_flag
    ,transfer_to_gl_flag
    ,comment_id
    ,null
    ,employment_category
    ,qualifying_age
    ,qualifying_length_of_service
    ,qualifying_units
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
    ,object_version_number
    from        pay_element_links_f
    where       element_link_id = p_element_link_id
    and         p_effective_date
    between     effective_start_date and effective_end_date;
--
  l_fct_ret     boolean;
--
Begin
  --
  If (p_effective_date is null or
      p_element_link_id is null or
      p_object_version_number is null) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_element_link_id =
        pay_pel_shd.g_old_rec.element_link_id and
        p_object_version_number =
        pay_pel_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into pay_pel_shd.g_old_rec;
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
          <> pay_pel_shd.g_old_rec.object_version_number) Then
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
    ,p_base_table_name       => 'pay_element_links_f'
    ,p_base_key_column       => 'element_link_id'
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
  l_parent_key_value1     pay_element_links_f.PAYROLL_ID%TYPE;
  l_parent_key_value2     pay_element_links_f.ELEMENT_TYPE_ID%TYPE;
  --
  Cursor C_Sel1 Is
    select
     t.payroll_id
    ,t.element_type_id
    from   pay_element_links_f t
    where  t.element_link_id = p_base_key_value
    and    p_effective_date
    between t.effective_start_date and t.effective_end_date;
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
   ,p_base_table_name               => 'pay_element_links_f'
   ,p_base_key_column               => 'element_link_id'
   ,p_base_key_value                => p_base_key_value
   ,p_parent_table_name1            => 'pay_all_payrolls_f'
   ,p_parent_key_column1            => 'payroll_id'
   ,p_parent_key_value1             => l_parent_key_value1
   ,p_parent_table_name2            => 'pay_element_types_f'
   ,p_parent_key_column2            => 'element_type_id'
   ,p_parent_key_value2             => l_parent_key_value2
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
  l_object_version_number     pay_element_links_f.OBJECT_VERSION_NUMBER%TYPE;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Because we are updating a row we must get the next object
  -- version number.
  --
  l_object_version_number :=
    dt_api.get_object_version_number
      (p_base_table_name    => 'pay_element_links_f'
      ,p_base_key_column    => 'element_link_id'
      ,p_base_key_value     => p_base_key_value
      );
  --
  hr_utility.set_location(l_proc, 10);
  pay_pel_shd.g_api_dml := true;  -- Set the api dml status
--
  -- Update the specified datetrack row setting the effective
  -- end date to the specified new effective end date.
  --
  update  pay_element_links_f t
  set     t.effective_end_date    = p_new_effective_end_date
    ,     t.object_version_number = l_object_version_number
  where   t.element_link_id        = p_base_key_value
  and     p_effective_date
  between t.effective_start_date and t.effective_end_date;
  --
  pay_pel_shd.g_api_dml := false;   -- Unset the api dml status
  p_object_version_number := l_object_version_number;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
Exception
  When Others Then
    pay_pel_shd.g_api_dml := false;   -- Unset the api dml status
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
  ,p_element_link_id                  in number
  ,p_object_version_number            in number
  ,p_enforce_foreign_locking          in boolean default true
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
     element_link_id
    ,effective_start_date
    ,effective_end_date
    ,payroll_id
    ,job_id
    ,position_id
    ,people_group_id
    ,cost_allocation_keyflex_id
    ,organization_id
    ,element_type_id
    ,location_id
    ,grade_id
    ,balancing_keyflex_id
    ,business_group_id
    ,element_set_id
    ,pay_basis_id
    ,costable_type
    ,link_to_all_payrolls_flag
    ,multiply_value_flag
    ,standard_link_flag
    ,transfer_to_gl_flag
    ,comment_id
    ,null
    ,employment_category
    ,qualifying_age
    ,qualifying_length_of_service
    ,qualifying_units
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
    ,object_version_number
    from    pay_element_links_f
    where   element_link_id = p_element_link_id
    and     p_effective_date
    between effective_start_date and effective_end_date
    for update nowait;
  --
  -- Cursor C_Sel3 select comment text
  --
  Cursor C_Sel3 is
    select hc.comment_text
    from   hr_comments hc
    where  hc.comment_id = pay_pel_shd.g_old_rec.comment_id;
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
                            ,p_argument       => 'element_link_id'
                            ,p_argument_value => p_element_link_id
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
    Fetch C_Sel1 Into pay_pel_shd.g_old_rec;
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
          <> pay_pel_shd.g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
    End If;
    --
    -- Providing we are doing an update and a comment_id exists then
    -- we select the comment text.
    --
    If ((pay_pel_shd.g_old_rec.comment_id is not null) and
        (p_datetrack_mode = hr_api.g_update             or
         p_datetrack_mode = hr_api.g_correction         or
         p_datetrack_mode = hr_api.g_update_override    or
         p_datetrack_mode = hr_api.g_update_change_insert)) then
       Open C_Sel3;
       Fetch C_Sel3 Into pay_pel_shd.g_old_rec.comments;
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
      (p_effective_date          => p_effective_date
      ,p_datetrack_mode          => p_datetrack_mode
      ,p_base_table_name         => 'pay_element_links_f'
      ,p_base_key_column         => 'element_link_id'
      ,p_base_key_value          => p_element_link_id
      ,p_parent_table_name1      => 'pay_all_payrolls_f'
      ,p_parent_key_column1      => 'payroll_id'
      ,p_parent_key_value1       => pay_pel_shd.g_old_rec.payroll_id
      ,p_parent_table_name2      => 'pay_element_types_f'
      ,p_parent_key_column2      => 'element_type_id'
      ,p_parent_key_value2       => pay_pel_shd.g_old_rec.element_type_id
      ,p_child_table_name1       => 'pay_link_input_values_f'
      ,p_child_key_column1       => 'link_input_value_id'
      ,p_child_alt_base_key_column1       => null
      ,p_child_table_name2       => 'pay_element_entries_f'
      ,p_child_key_column2       => 'element_entry_id'
      ,p_child_alt_base_key_column2       => null
      ,p_enforce_foreign_locking => p_enforce_foreign_locking
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
    fnd_message.set_token('TABLE_NAME', 'pay_element_links_f');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_element_link_id                in number
  ,p_effective_start_date           in date
  ,p_effective_end_date             in date
  ,p_payroll_id                     in number
  ,p_job_id                         in number
  ,p_position_id                    in number
  ,p_people_group_id                in number
  ,p_cost_allocation_keyflex_id     in number
  ,p_organization_id                in number
  ,p_element_type_id                in number
  ,p_location_id                    in number
  ,p_grade_id                       in number
  ,p_balancing_keyflex_id           in number
  ,p_business_group_id              in number
  ,p_element_set_id                 in number
  ,p_pay_basis_id                   in number
  ,p_costable_type                  in varchar2
  ,p_link_to_all_payrolls_flag      in varchar2
  ,p_multiply_value_flag            in varchar2
  ,p_standard_link_flag             in varchar2
  ,p_transfer_to_gl_flag            in varchar2
  ,p_comment_id                     in number
  ,p_comments                       in varchar2
  ,p_employment_category            in varchar2
  ,p_qualifying_age                 in number
  ,p_qualifying_length_of_service   in number
  ,p_qualifying_units               in varchar2
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
  l_rec.element_link_id                  := p_element_link_id;
  l_rec.effective_start_date             := p_effective_start_date;
  l_rec.effective_end_date               := p_effective_end_date;
  l_rec.payroll_id                       := p_payroll_id;
  l_rec.job_id                           := p_job_id;
  l_rec.position_id                      := p_position_id;
  l_rec.people_group_id                  := p_people_group_id;
  l_rec.cost_allocation_keyflex_id       := p_cost_allocation_keyflex_id;
  l_rec.organization_id                  := p_organization_id;
  l_rec.element_type_id                  := p_element_type_id;
  l_rec.location_id                      := p_location_id;
  l_rec.grade_id                         := p_grade_id;
  l_rec.balancing_keyflex_id             := p_balancing_keyflex_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.element_set_id                   := p_element_set_id;
  l_rec.pay_basis_id                     := p_pay_basis_id;
  l_rec.costable_type                    := p_costable_type;
  l_rec.link_to_all_payrolls_flag        := p_link_to_all_payrolls_flag;
  l_rec.multiply_value_flag              := p_multiply_value_flag;
  l_rec.standard_link_flag               := p_standard_link_flag;
  l_rec.transfer_to_gl_flag              := p_transfer_to_gl_flag;
  l_rec.comment_id                       := p_comment_id;
  l_rec.comments                         := p_comments;
  l_rec.employment_category              := p_employment_category;
  l_rec.qualifying_age                   := p_qualifying_age;
  l_rec.qualifying_length_of_service     := p_qualifying_length_of_service;
  l_rec.qualifying_units                 := p_qualifying_units;
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
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
end pay_pel_shd;

/
