--------------------------------------------------------
--  DDL for Package Body PAY_CNT_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CNT_SHD" AS
/* $Header: pycntrhi.pkb 120.0.12000000.2 2007/05/01 22:43:42 ahanda noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_cnt_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
Function return_api_dml_status Return Boolean Is
--
  l_proc    varchar2(72) := g_package||'return_api_dml_status';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  Return (nvl(g_api_dml, false));
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End return_api_dml_status;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< constraint_error >---------------------------|
-- ----------------------------------------------------------------------------
Procedure constraint_error
            (p_constraint_name in all_constraints.constraint_name%TYPE) Is
--
  l_proc    varchar2(72) := g_package||'constraint_error';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_constraint_name = 'PAY_USCOUNTY_HT_EXEMPT_CHK') Then
    hr_utility.set_message(801, 'PAY_72766_CNT_HT_Y_OR_N');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PAY_USCOUNTY_LIT_EXEMPT_CHK') Then
    hr_utility.set_message(801, 'PAY_72767_CNT_LIT_Y_OR_N');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PAY_USCOUNTY_SD_EXEMPT_CHK') Then
    hr_utility.set_message(801, 'PAY_72773_CNT_SD_Y_OR_N');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PAY_US_EMP_COUNTY_TAX_RULE_FK1') Then
    hr_utility.set_message(801, 'HR_7952_ADDR_NO_STATE_CODE');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PAY_US_EMP_COUNTY_TAX_RULE_FK2') Then
    hr_utility.set_message(801, 'PAY_52969_TAX_BG_MATCH_ASG');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'PAY_US_EMP_COUNTY_TAX_RULE_FK3') Then
    hr_utility.set_message(801, 'HR_51279_ADD_INV_CTY_CO_ST_CMB');
    hr_utility.raise_error;
  Else
    hr_utility.set_message(801, 'HR_7877_API_INVALID_CONSTRAINT');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('CONSTRAINT_NAME', p_constraint_name);
    hr_utility.raise_error;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating
  (p_effective_date           in date,
   p_emp_county_tax_rule_id   in number,
   p_object_version_number    in number
  ) Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
      emp_county_tax_rule_id,
      effective_start_date,
      effective_end_date,
      assignment_id,
      state_code,
      county_code,
      business_group_id,
      additional_wa_rate,
      filing_status_code,
      jurisdiction_code,
      lit_additional_tax,
      lit_override_amount,
      lit_override_rate,
      withholding_allowances,
      lit_exempt,
      sd_exempt,
      ht_exempt,
      wage_exempt,
      school_district_code,
      object_version_number,
      attribute_category,
      attribute1,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15,
      attribute16,
      attribute17,
      attribute18,
      attribute19,
      attribute20,
      attribute21,
      attribute22,
      attribute23,
      attribute24,
      attribute25,
      attribute26,
      attribute27,
      attribute28,
      attribute29,
      attribute30,
      cnt_information_category,
      cnt_information1,
      cnt_information2,
      cnt_information3,
      cnt_information4,
      cnt_information5,
      cnt_information6,
      cnt_information7,
      cnt_information8,
      cnt_information9,
      cnt_information10,
      cnt_information11,
      cnt_information12,
      cnt_information13,
      cnt_information14,
      cnt_information15,
      cnt_information16,
      cnt_information17,
      cnt_information18,
      cnt_information19,
      cnt_information20,
      cnt_information21,
      cnt_information22,
      cnt_information23,
      cnt_information24,
      cnt_information25,
      cnt_information26,
      cnt_information27,
      cnt_information28,
      cnt_information29,
      cnt_information30
    from    pay_us_emp_county_tax_rules_f
    where   emp_county_tax_rule_id = p_emp_county_tax_rule_id
    and            p_effective_date
    between effective_start_date and effective_end_date;
--
  l_proc      varchar2(72)      := g_package||'api_updating';
  l_fct_ret   boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_effective_date is null or
      p_emp_county_tax_rule_id is null or
      p_object_version_number is null) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_emp_county_tax_rule_id = g_old_rec.emp_county_tax_rule_id and
        p_object_version_number = g_old_rec.object_version_number) Then
      hr_utility.set_location(l_proc, 10);
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
      Fetch C_Sel1 Into g_old_rec;
      If C_Sel1%notfound Then
        Close C_Sel1;
        --
        -- The primary key is invalid therefore we must error
        --
        hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
        hr_utility.raise_error;
      End If;
      Close C_Sel1;
      If (p_object_version_number <> g_old_rec.object_version_number) Then
        hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
        hr_utility.raise_error;
      End If;
      hr_utility.set_location(l_proc, 15);
      l_fct_ret := true;
    End If;
  End If;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
  Return (l_fct_ret);
--
End api_updating;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< find_dt_del_modes >---------------------------|
-- ----------------------------------------------------------------------------
Procedure find_dt_del_modes
      (p_effective_date      in  date,
       p_base_key_value      in  number,
       p_zap                 out nocopy boolean,
       p_delete              out nocopy boolean,
       p_future_change       out nocopy boolean,
       p_delete_next_change  out nocopy boolean) is
--
  l_proc      varchar2(72)    := g_package||'find_dt_del_modes';
--
  --
  --
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
    --
  --
  -- Call the corresponding datetrack api
  --
  dt_api.find_dt_del_modes
      (p_effective_date     => p_effective_date,
       p_base_table_name    => 'pay_us_emp_county_tax_rules_f',
       p_base_key_column    => 'emp_county_tax_rule_id',
       p_base_key_value     => p_base_key_value,
       p_zap                => p_zap,
       p_delete             => p_delete,
       p_future_change      => p_future_change,
       p_delete_next_change => p_delete_next_change);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End find_dt_del_modes;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< find_dt_upd_modes >---------------------------|
-- ----------------------------------------------------------------------------
Procedure find_dt_upd_modes
      (p_effective_date       in  date,
       p_base_key_value       in  number,
       p_correction           out nocopy boolean,
       p_update               out nocopy boolean,
       p_update_override      out nocopy boolean,
       p_update_change_insert out nocopy boolean) is
--
  l_proc       varchar2(72) := g_package||'find_dt_upd_modes';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the corresponding datetrack api
  --
  dt_api.find_dt_upd_modes
      (p_effective_date       => p_effective_date,
       p_base_table_name      => 'pay_us_emp_county_tax_rules_f',
       p_base_key_column      => 'emp_county_tax_rule_id',
       p_base_key_value       => p_base_key_value,
       p_correction           => p_correction,
       p_update               => p_update,
       p_update_override      => p_update_override,
       p_update_change_insert => p_update_change_insert);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End find_dt_upd_modes;
--
-- ----------------------------------------------------------------------------
-- |------------------------< upd_effective_end_date >------------------------|
-- ----------------------------------------------------------------------------
Procedure upd_effective_end_date
      (p_effective_date            in date,
       p_base_key_value            in number,
       p_new_effective_end_date    in date,
       p_validation_start_date     in date,
       p_validation_end_date       in date,
         p_object_version_number       out nocopy number) is
--
  l_proc          varchar2(72) := g_package||'upd_effective_end_date';
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
      (p_base_table_name      => 'pay_us_emp_county_tax_rules_f',
       p_base_key_column      => 'emp_county_tax_rule_id',
       p_base_key_value       => p_base_key_value);
  --
  hr_utility.set_location(l_proc, 10);
  g_api_dml := true;  -- Set the api dml status
  --
  -- Update the specified datetrack row setting the effective
  -- end date to the specified new effective end date.
  --
  update  pay_us_emp_county_tax_rules_f t
  set   t.effective_end_date    = p_new_effective_end_date,
        t.object_version_number = l_object_version_number
  where   t.emp_county_tax_rule_id  = p_base_key_value
  and  p_effective_date
  between t.effective_start_date and t.effective_end_date;
  --
  g_api_dml := false;   -- Unset the api dml status
  p_object_version_number := l_object_version_number;
  hr_utility.set_location(' Leaving:'||l_proc, 15);
--
Exception
  When Others Then
    g_api_dml := false;   -- Unset the api dml status
    Raise;
End upd_effective_end_date;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
      (p_effective_date       in  date,
       p_datetrack_mode       in  varchar2,
       p_emp_county_tax_rule_id       in  number,
       p_object_version_number in  number,
       p_validation_start_date out nocopy date,
       p_validation_end_date   out nocopy date) is
--
  l_proc        varchar2(72) := g_package||'lck';
  l_validation_start_date date;
  l_validation_end_date   date;
  l_object_invalid         exception;
  l_argument              varchar2(30);
  --
  -- Cursor C_Sel1 selects the current locked row as of session date
  -- ensuring that the object version numbers match.
  --
  Cursor C_Sel1 is
    select
      emp_county_tax_rule_id,
      effective_start_date,
      effective_end_date,
      assignment_id,
      state_code,
      county_code,
      business_group_id,
      additional_wa_rate,
      filing_status_code,
      jurisdiction_code,
      lit_additional_tax,
      lit_override_amount,
      lit_override_rate,
      withholding_allowances,
      lit_exempt,
      sd_exempt,
      ht_exempt,
      wage_exempt,
      school_district_code,
      object_version_number,
      attribute_category,
      attribute1,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15,
      attribute16,
      attribute17,
      attribute18,
      attribute19,
      attribute20,
      attribute21,
      attribute22,
      attribute23,
      attribute24,
      attribute25,
      attribute26,
      attribute27,
      attribute28,
      attribute29,
      attribute30,
      cnt_information_category,
      cnt_information1,
      cnt_information2,
      cnt_information3,
      cnt_information4,
      cnt_information5,
      cnt_information6,
      cnt_information7,
      cnt_information8,
      cnt_information9,
      cnt_information10,
      cnt_information11,
      cnt_information12,
      cnt_information13,
      cnt_information14,
      cnt_information15,
      cnt_information16,
      cnt_information17,
      cnt_information18,
      cnt_information19,
      cnt_information20,
      cnt_information21,
      cnt_information22,
      cnt_information23,
      cnt_information24,
      cnt_information25,
      cnt_information26,
      cnt_information27,
      cnt_information28,
      cnt_information29,
      cnt_information30
    from    pay_us_emp_county_tax_rules_f
    where   emp_county_tax_rule_id         = p_emp_county_tax_rule_id
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
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'effective_date',
                             p_argument_value => p_effective_date);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'datetrack_mode',
                             p_argument_value => p_datetrack_mode);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'emp_county_tax_rule_id',
                             p_argument_value => p_emp_county_tax_rule_id);
  --
  hr_api.mandatory_arg_error(p_api_name       => l_proc,
                             p_argument       => 'object_version_number',
                             p_argument_value => p_object_version_number);
  --
  -- Check to ensure the datetrack mode is not INSERT.
  --
  If (p_datetrack_mode <> 'INSERT') then
    --
    -- We must select and lock the current row.
    --
    Open  C_Sel1;
    Fetch C_Sel1 Into g_old_rec;
    If C_Sel1%notfound then
      Close C_Sel1;
      --
      -- The primary key is invalid therefore we must error
      --
      hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
      hr_utility.raise_error;
    End If;
    Close C_Sel1;
    If (p_object_version_number <> g_old_rec.object_version_number) Then
        hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
        hr_utility.raise_error;
      End If;
    hr_utility.set_location(l_proc, 15);
    --
    --
    -- Validate the datetrack mode mode getting the validation start
    -- and end dates for the specified datetrack operation.
    --
    dt_api.validate_dt_mode
      (p_effective_date   => p_effective_date,
       p_datetrack_mode   => p_datetrack_mode,
       p_base_table_name  => 'pay_us_emp_county_tax_rules_f',
       p_base_key_column  => 'emp_county_tax_rule_id',
       p_base_key_value   => p_emp_county_tax_rule_id,

       p_enforce_foreign_locking => true,
       p_validation_start_date   => l_validation_start_date,
       p_validation_end_date     => l_validation_end_date);
  Else
    --
    -- We are doing a datetrack 'INSERT' which is illegal within this
    -- procedure therefore we must error (note: to lck on insert the
    -- private procedure ins_lck should be called).
    --
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','20');
    hr_utility.raise_error;
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
    hr_utility.set_message(801, 'HR_7165_OBJECT_LOCKED');
    hr_utility.set_message_token('TABLE_NAME',
                                 'pay_us_emp_county_tax_rules_f');
    hr_utility.raise_error;
  When l_object_invalid then
    --
    -- The object doesn't exist or is invalid
    --
    hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
    hr_utility.set_message_token('TABLE_NAME',
                                 'pay_us_emp_county_tax_rules_f');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
      (
      p_emp_county_tax_rule_id        in number,
      p_effective_start_date          in date,
      p_effective_end_date            in date,
      p_assignment_id                 in number,
      p_state_code                    in varchar2,
      p_county_code                   in varchar2,
      p_business_group_id             in number,
      p_additional_wa_rate            in number,
      p_filing_status_code            in varchar2,
      p_jurisdiction_code             in varchar2,
      p_lit_additional_tax            in number,
      p_lit_override_amount           in number,
      p_lit_override_rate             in number,
      p_withholding_allowances        in number,
      p_lit_exempt                    in varchar2,
      p_sd_exempt                     in varchar2,
      p_ht_exempt                     in varchar2,
      p_wage_exempt                   in varchar2,
      p_school_district_code          in varchar2,
      p_object_version_number         in number,
      p_attribute_category              in varchar2,
      p_attribute1                      in varchar2,
      p_attribute2                      in varchar2,
      p_attribute3                      in varchar2,
      p_attribute4                      in varchar2,
      p_attribute5                      in varchar2,
      p_attribute6                      in varchar2,
      p_attribute7                      in varchar2,
      p_attribute8                      in varchar2,
      p_attribute9                      in varchar2,
      p_attribute10                     in varchar2,
      p_attribute11                     in varchar2,
      p_attribute12                     in varchar2,
      p_attribute13                     in varchar2,
      p_attribute14                     in varchar2,
      p_attribute15                     in varchar2,
      p_attribute16                     in varchar2,
      p_attribute17                     in varchar2,
      p_attribute18                     in varchar2,
      p_attribute19                     in varchar2,
      p_attribute20                     in varchar2,
      p_attribute21                     in varchar2,
      p_attribute22                     in varchar2,
      p_attribute23                     in varchar2,
      p_attribute24                     in varchar2,
      p_attribute25                     in varchar2,
      p_attribute26                     in varchar2,
      p_attribute27                     in varchar2,
      p_attribute28                     in varchar2,
      p_attribute29                     in varchar2,
      p_attribute30                     in varchar2,
      p_cnt_information_category        in varchar2,
      p_cnt_information1                in varchar2,
      p_cnt_information2                in varchar2,
      p_cnt_information3                in varchar2,
      p_cnt_information4                in varchar2,
      p_cnt_information5                in varchar2,
      p_cnt_information6                in varchar2,
      p_cnt_information7                in varchar2,
      p_cnt_information8                in varchar2,
      p_cnt_information9                in varchar2,
      p_cnt_information10               in varchar2,
      p_cnt_information11               in varchar2,
      p_cnt_information12               in varchar2,
      p_cnt_information13               in varchar2,
      p_cnt_information14               in varchar2,
      p_cnt_information15               in varchar2,
      p_cnt_information16               in varchar2,
      p_cnt_information17               in varchar2,
      p_cnt_information18               in varchar2,
      p_cnt_information19               in varchar2,
      p_cnt_information20               in varchar2,
      p_cnt_information21               in varchar2,
      p_cnt_information22               in varchar2,
      p_cnt_information23               in varchar2,
      p_cnt_information24               in varchar2,
      p_cnt_information25               in varchar2,
      p_cnt_information26               in varchar2,
      p_cnt_information27               in varchar2,
      p_cnt_information28               in varchar2,
      p_cnt_information29               in varchar2,
      p_cnt_information30               in varchar2

      )
      Return g_rec_type is
--
  l_rec        g_rec_type;
  l_proc  varchar2(72) := g_package||'convert_args';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.emp_county_tax_rule_id           := p_emp_county_tax_rule_id;
  l_rec.effective_start_date             := p_effective_start_date;
  l_rec.effective_end_date               := p_effective_end_date;
  l_rec.assignment_id                    := p_assignment_id;
  l_rec.state_code                       := p_state_code;
  l_rec.county_code                      := p_county_code;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.additional_wa_rate               := p_additional_wa_rate;
  l_rec.filing_status_code               := p_filing_status_code;
  l_rec.jurisdiction_code                := p_jurisdiction_code;
  l_rec.lit_additional_tax               := p_lit_additional_tax;
  l_rec.lit_override_amount              := p_lit_override_amount;
  l_rec.lit_override_rate                := p_lit_override_rate;
  l_rec.withholding_allowances           := p_withholding_allowances;
  l_rec.lit_exempt                       := p_lit_exempt;
  l_rec.sd_exempt                        := p_sd_exempt;
  l_rec.ht_exempt                        := p_ht_exempt;
  l_rec.wage_exempt                      := p_wage_exempt;
  l_rec.school_district_code             := p_school_district_code;
  l_rec.object_version_number            := p_object_version_number;
 l_rec.attribute_category                := p_attribute_category;
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
  l_rec.attribute21                      := p_attribute21;
  l_rec.attribute22                      := p_attribute22;
  l_rec.attribute23                      := p_attribute23;
  l_rec.attribute24                      := p_attribute24;
  l_rec.attribute25                      := p_attribute25;
  l_rec.attribute26                      := p_attribute26;
  l_rec.attribute27                      := p_attribute27;
  l_rec.attribute28                      := p_attribute28;
  l_rec.attribute29                      := p_attribute29;
  l_rec.attribute30                      := p_attribute30;
  l_rec.cnt_information_category         := p_cnt_information_category;
  l_rec.cnt_information1                 := p_cnt_information1;
  l_rec.cnt_information2                 := p_cnt_information2;
  l_rec.cnt_information3                 := p_cnt_information3;
  l_rec.cnt_information4                 := p_cnt_information4;
  l_rec.cnt_information5                 := p_cnt_information5;
  l_rec.cnt_information6                 := p_cnt_information6;
  l_rec.cnt_information7                 := p_cnt_information7;
  l_rec.cnt_information8                 := p_cnt_information8;
  l_rec.cnt_information9                 := p_cnt_information9;
  l_rec.cnt_information10                := p_cnt_information10;
  l_rec.cnt_information11                := p_cnt_information11;
  l_rec.cnt_information12                := p_cnt_information12;
  l_rec.cnt_information13                := p_cnt_information13;
  l_rec.cnt_information14                := p_cnt_information14;
  l_rec.cnt_information15                := p_cnt_information15;
  l_rec.cnt_information16                := p_cnt_information16;
  l_rec.cnt_information17                := p_cnt_information17;
  l_rec.cnt_information18                := p_cnt_information18;
  l_rec.cnt_information19                := p_cnt_information19;
  l_rec.cnt_information20                := p_cnt_information20;
  l_rec.cnt_information21                := p_cnt_information21;
  l_rec.cnt_information22                := p_cnt_information22;
  l_rec.cnt_information23                := p_cnt_information23;
  l_rec.cnt_information24                := p_cnt_information24;
  l_rec.cnt_information25                := p_cnt_information25;
  l_rec.cnt_information26                := p_cnt_information26;
  l_rec.cnt_information27                := p_cnt_information27;
  l_rec.cnt_information28                := p_cnt_information28;
  l_rec.cnt_information29                := p_cnt_information29;
  l_rec.cnt_information30                := p_cnt_information30;

  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end pay_cnt_shd;

/
