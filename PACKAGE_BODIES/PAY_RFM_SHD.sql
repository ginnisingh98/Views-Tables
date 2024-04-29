--------------------------------------------------------
--  DDL for Package Body PAY_RFM_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_RFM_SHD" as
/* $Header: pyrfmrhi.pkb 120.0 2005/05/29 08:20 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_rfm_shd.';  -- Global package name
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
  If (p_constraint_name = 'PAY_REPORT_FORMAT_MAPPINGS_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
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
  ,p_report_format_mapping_id         in number
  ,p_object_version_number            in number
  ) Return Boolean Is
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
     report_type
    ,report_qualifier
    ,report_format
    ,effective_start_date
    ,effective_end_date
    ,range_code
    ,assignment_action_code
    ,initialization_code
    ,archive_code
    ,magnetic_code
    ,report_category
    ,report_name
    ,sort_code
    ,updatable_flag
    ,deinitialization_code
    ,report_format_mapping_id
    ,business_group_id
    ,legislation_code
    ,temporary_action_flag
    ,object_version_number
    from        pay_report_format_mappings_f
    where       report_format_mapping_id = p_report_format_mapping_id
    and         p_effective_date
    between     effective_start_date and effective_end_date;
--
  l_fct_ret     boolean;
--
Begin
  --
  If (p_effective_date is null or
      p_report_format_mapping_id is null or
      p_object_version_number is null) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_report_format_mapping_id =
        pay_rfm_shd.g_old_rec.report_format_mapping_id and
        p_object_version_number =
        pay_rfm_shd.g_old_rec.object_version_number
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
      Fetch C_Sel1 Into pay_rfm_shd.g_old_rec;
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
          <> pay_rfm_shd.g_old_rec.object_version_number) Then
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
    ,p_base_table_name       => 'pay_report_format_mappings_f'
    ,p_base_key_column       => 'report_format_mapping_id'
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
   ,p_base_table_name               => 'pay_report_format_mappings_f'
   ,p_base_key_column               => 'report_format_mapping_id'
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
      (p_base_table_name    => 'pay_report_format_mappings_f'
      ,p_base_key_column    => 'report_format_mapping_id'
      ,p_base_key_value     => p_base_key_value
      );
  --
  hr_utility.set_location(l_proc, 10);
  pay_rfm_shd.g_api_dml := true;  -- Set the api dml status
--
  -- Update the specified datetrack row setting the effective
  -- end date to the specified new effective end date.
  --
  update  pay_report_format_mappings_f t
  set     t.effective_end_date    = p_new_effective_end_date
    ,     t.object_version_number = l_object_version_number
  where   t.report_format_mapping_id        = p_base_key_value
  and     p_effective_date
  between t.effective_start_date and t.effective_end_date;
  --
  pay_rfm_shd.g_api_dml := false;   -- Unset the api dml status
  p_object_version_number := l_object_version_number;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
Exception
  When Others Then
    pay_rfm_shd.g_api_dml := false;   -- Unset the api dml status
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
  ,p_report_format_mapping_id         in number
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
     report_type
    ,report_qualifier
    ,report_format
    ,effective_start_date
    ,effective_end_date
    ,range_code
    ,assignment_action_code
    ,initialization_code
    ,archive_code
    ,magnetic_code
    ,report_category
    ,report_name
    ,sort_code
    ,updatable_flag
    ,deinitialization_code
    ,report_format_mapping_id
    ,business_group_id
    ,legislation_code
    ,temporary_action_flag
    ,object_version_number
    from    pay_report_format_mappings_f
    where   report_format_mapping_id = p_report_format_mapping_id
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
                            ,p_argument       => 'report_format_mapping_id'
                            ,p_argument_value => p_report_format_mapping_id
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
    Fetch C_Sel1 Into pay_rfm_shd.g_old_rec;
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
          <> pay_rfm_shd.g_old_rec.object_version_number) Then
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
      ,p_base_table_name         => 'pay_report_format_mappings_f'
      ,p_base_key_column         => 'report_format_mapping_id'
      ,p_base_key_value          => p_report_format_mapping_id
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
    fnd_message.set_token('TABLE_NAME', 'pay_report_format_mappings_f');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
  (p_report_type                    in varchar2
  ,p_report_qualifier               in varchar2
  ,p_report_format                  in varchar2
  ,p_effective_start_date           in date
  ,p_effective_end_date             in date
  ,p_range_code                     in varchar2
  ,p_assignment_action_code         in varchar2
  ,p_initialization_code            in varchar2
  ,p_archive_code                   in varchar2
  ,p_magnetic_code                  in varchar2
  ,p_report_category                in varchar2
  ,p_report_name                    in varchar2
  ,p_sort_code                      in varchar2
  ,p_updatable_flag                 in varchar2
  ,p_deinitialization_code          in varchar2
  ,p_report_format_mapping_id       in number
  ,p_business_group_id              in number
  ,p_legislation_code               in varchar2
  ,p_temporary_action_flag          in varchar2
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
  l_rec.report_type                      := p_report_type;
  l_rec.report_qualifier                 := p_report_qualifier;
  l_rec.report_format                    := p_report_format;
  l_rec.effective_start_date             := p_effective_start_date;
  l_rec.effective_end_date               := p_effective_end_date;
  l_rec.range_code                       := p_range_code;
  l_rec.assignment_action_code           := p_assignment_action_code;
  l_rec.initialization_code              := p_initialization_code;
  l_rec.archive_code                     := p_archive_code;
  l_rec.magnetic_code                    := p_magnetic_code;
  l_rec.report_category                  := p_report_category;
  l_rec.report_name                      := p_report_name;
  l_rec.sort_code                        := p_sort_code;
  l_rec.updatable_flag                   := p_updatable_flag;
  l_rec.deinitialization_code            := p_deinitialization_code;
  l_rec.report_format_mapping_id         := p_report_format_mapping_id;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.legislation_code                 := p_legislation_code;
  l_rec.temporary_action_flag            := p_temporary_action_flag;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  Return(l_rec);
--
End convert_args;
--
-- ----------------------------------------------------------------------------
-- |---------------------< get_report_format_mapping_id >---------------------|
-- ----------------------------------------------------------------------------
Function get_report_format_mapping_id
  (p_report_type                    in varchar2
  ,p_report_qualifier               in varchar2
  ,p_report_category                in varchar2
  )
  Return number is
--
  cursor csr_format_mapping_id is
       select distinct report_format_mapping_id
          from pay_report_format_mappings_f
          where report_type = p_report_type
          and   report_qualifier = p_report_qualifier
          and   report_category  = p_report_category;
--
  l_proc   varchar2(72) := g_package||'get_report_format_mapping_id';
  l_report_format_mapping_id PAY_REPORT_FORMAT_MAPPINGS_F.REPORT_FORMAT_MAPPING_ID%TYPE;
--
Begin
--
  hr_utility.set_location('Entering:'||l_proc, 5);

  if p_report_type is null  or  p_report_qualifier is null  or
        p_report_category is null then

        return  null;

  end if;

  open csr_format_mapping_id;
  fetch csr_format_mapping_id into l_report_format_mapping_id;

  if csr_format_mapping_id%ROWCOUNT > 1 then

        close csr_format_mapping_id;

        fnd_message.set_name( 'PAY' , 'PAY_33255_INV_SKEY' );
        fnd_message.set_token( 'SURROGATE_ID' , 'REPORT_FORMAT_MAPPING_ID' );
        fnd_message.set_token( 'ENTITY' , 'REPORT FORMAT MAPPING' );
        fnd_message.raise_error ;

  end if;

  if csr_format_mapping_id%found and l_report_format_mapping_id is null then

        close csr_format_mapping_id;

        fnd_message.set_name( 'PAY' , 'PAY_33255_INV_SKEY' );
        fnd_message.set_token( 'SURROGATE_ID' , 'REPORT_FORMAT_MAPPING_ID' );
        fnd_message.set_token( 'ENTITY' , 'REPORT FORMAT MAPPING' );
        fnd_message.raise_error ;

  end if;

  close csr_format_mapping_id;

  hr_utility.set_location(' Leaving:'||l_proc, 10);

  return l_report_format_mapping_id;

--
End get_report_format_mapping_id;
--
end pay_rfm_shd;

/
