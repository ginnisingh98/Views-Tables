--------------------------------------------------------
--  DDL for Package Body BEN_DPNT_EGD_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_DPNT_EGD_SHD" as
/* $Header: beecdrhi.pkb 120.0.12010000.4 2010/05/12 10:10:27 pvelvano noship $ */

--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_dpnt_egd_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
Function return_api_dml_status Return Boolean Is
--
  l_proc 	varchar2(72) := g_package||'return_api_dml_status';
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
  l_proc 	varchar2(72) := g_package||'constraint_error';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_constraint_name = 'BEN_dpnt_eligy_criteria_FK1') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_dpnt_eligy_criteria_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
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
  (
  p_eligy_criteria_dpnt_id                  in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
  eligy_criteria_dpnt_id,
name,
short_code,
description,
criteria_type,
crit_col1_val_type_cd,
crit_col1_datatype,
col1_lookup_type,
col1_value_set_id,
access_table_name1,
access_column_name1,
time_entry_access_table_name1,
time_entry_access_col_name1,
crit_col2_val_type_cd,
crit_col2_datatype,
col2_lookup_type,
col2_value_set_id,
access_table_name2,
access_column_name2,
time_entry_access_table_name2,
time_entry_access_col_name2,
allow_range_validation_flag,
user_defined_flag,
business_group_id,
egd_attribute_category,
egd_attribute1,
egd_attribute2,
egd_attribute3,
egd_attribute4,
egd_attribute5,
egd_attribute6,
egd_attribute7,
egd_attribute8,
egd_attribute9,
egd_attribute10,
egd_attribute11,
egd_attribute12,
egd_attribute13,
egd_attribute14,
egd_attribute15,
egd_attribute16,
egd_attribute17,
egd_attribute18,
egd_attribute19,
egd_attribute20,
egd_attribute21,
egd_attribute22,
egd_attribute23,
egd_attribute24,
egd_attribute25,
egd_attribute26,
egd_attribute27,
egd_attribute28,
egd_attribute29,
egd_attribute30,
object_version_number,
allow_range_validation_flag2,
time_access_calc_rule1,
time_access_calc_rule2
    from	ben_eligy_criteria_dpnt
    where	eligy_criteria_dpnt_id = p_eligy_criteria_dpnt_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_eligy_criteria_dpnt_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_eligy_criteria_dpnt_id = g_old_rec.eligy_criteria_dpnt_id and
	p_object_version_number = g_old_rec.object_version_number
       ) Then

      --
      -- The g_old_rec is current therefore we must
      -- set the returning function to true
      --
      l_fct_ret := true;
    Else
      --
      -- Select the current row into g_old_rec
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

      l_fct_ret := true;
    End If;
  End If;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
  Return (l_fct_ret);
--
End api_updating;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< lck >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure lck
  (
  p_eligy_criteria_dpnt_id                  in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
    eligy_criteria_dpnt_id,
    name,
    short_code,
    description,
    criteria_type,
    crit_col1_val_type_cd,
    crit_col1_datatype,
    col1_lookup_type,
    col1_value_set_id,
    access_table_name1,
    access_column_name1,
    time_entry_access_table_name1,
    time_entry_access_col_name1,
    crit_col2_val_type_cd,
    crit_col2_datatype,
    col2_lookup_type,
    col2_value_set_id,
    access_table_name2,
    access_column_name2,
    time_entry_access_table_name2,
    time_entry_access_col_name2,
    allow_range_validation_flag,
    user_defined_flag,
    business_group_id,
    egd_attribute_category,
    egd_attribute1,
    egd_attribute2,
    egd_attribute3,
    egd_attribute4,
    egd_attribute5,
    egd_attribute6,
    egd_attribute7,
    egd_attribute8,
    egd_attribute9,
    egd_attribute10,
    egd_attribute11,
    egd_attribute12,
    egd_attribute13,
    egd_attribute14,
    egd_attribute15,
    egd_attribute16,
    egd_attribute17,
    egd_attribute18,
    egd_attribute19,
    egd_attribute20,
    egd_attribute21,
    egd_attribute22,
    egd_attribute23,
    egd_attribute24,
    egd_attribute25,
    egd_attribute26,
    egd_attribute27,
    egd_attribute28,
    egd_attribute29,
    egd_attribute30,
    object_version_number,
    allow_range_validation_flag2,
    time_access_calc_rule1,
    time_access_calc_rule2
    from	ben_eligy_criteria_dpnt
    where	eligy_criteria_dpnt_id = p_eligy_criteria_dpnt_id
    for	update nowait;
--
  l_proc	varchar2(72) := g_package||'lck';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --

  -- Add any mandatory argument checking here:
  -- Example:
   hr_api.mandatory_arg_error
    (p_api_name       => l_proc,
     p_argument       => 'object_version_number',
     p_argument_value => p_object_version_number);
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
--
  hr_utility.set_location(' Leaving:'||l_proc, 10);
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
    hr_utility.set_message_token('TABLE_NAME', 'ben_eligy_criteria_dpnt');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_eligy_criteria_dpnt_id              in  number,
	p_name                           in  varchar2,
	p_short_code                     in  varchar2,
	p_description                    in  varchar2,
	p_criteria_type		         in  varchar2,
	p_crit_col1_val_type_cd	         in  varchar2,
	p_crit_col1_datatype	    	 in  varchar2,
	p_col1_lookup_type		 in  varchar2,
	p_col1_value_set_id              in  number,
	p_access_table_name1             in  varchar2,
	p_access_column_name1	         in  varchar2,
	p_time_entry_access_tab_nam1     in  varchar2,
	p_time_entry_access_col_nam1     in  varchar2,
	p_crit_col2_val_type_cd	         in  varchar2,
	p_crit_col2_datatype		 in  varchar2,
	p_col2_lookup_type		 in  varchar2,
	p_col2_value_set_id              in  number,
	p_access_table_name2		 in  varchar2,
	p_access_column_name2	         in  varchar2,
	p_time_entry_access_tab_nam2     in  varchar2,
	p_time_entry_access_col_nam2     in  varchar2,
	p_allow_range_validation_flg     in  varchar2,
	p_user_defined_flag              in  varchar2,
	p_business_group_id 	    	 in  number,
	p_egd_attribute_category         in  varchar2,
	p_egd_attribute1                 in  varchar2,
	p_egd_attribute2                 in  varchar2,
	p_egd_attribute3                 in  varchar2,
	p_egd_attribute4                 in  varchar2,
	p_egd_attribute5                 in  varchar2,
	p_egd_attribute6                 in  varchar2,
	p_egd_attribute7                 in  varchar2,
	p_egd_attribute8                 in  varchar2,
	p_egd_attribute9                 in  varchar2,
	p_egd_attribute10                in  varchar2,
	p_egd_attribute11                in  varchar2,
	p_egd_attribute12                in  varchar2,
	p_egd_attribute13                in  varchar2,
	p_egd_attribute14                in  varchar2,
	p_egd_attribute15                in  varchar2,
	p_egd_attribute16                in  varchar2,
	p_egd_attribute17                in  varchar2,
	p_egd_attribute18                in  varchar2,
	p_egd_attribute19                in  varchar2,
	p_egd_attribute20                in  varchar2,
	p_egd_attribute21                in  varchar2,
	p_egd_attribute22                in  varchar2,
	p_egd_attribute23                in  varchar2,
	p_egd_attribute24                in  varchar2,
	p_egd_attribute25                in  varchar2,
	p_egd_attribute26                in  varchar2,
	p_egd_attribute27                in  varchar2,
	p_egd_attribute28                in  varchar2,
	p_egd_attribute29                in  varchar2,
	p_egd_attribute30                in  varchar2,
	p_object_version_number          in  number  ,
        p_allow_range_validation_flag2   in  varchar2,
        p_time_access_calc_rule1         in  number,
        p_time_access_calc_rule2         in  number
	)
	Return g_rec_type is
--
  l_rec	  g_rec_type;
  l_proc  varchar2(72) := g_package||'convert_args';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.eligy_criteria_dpnt_id                :=  p_eligy_criteria_dpnt_id;
  l_rec.name                             :=  p_name;
  l_rec.short_code                       :=  p_short_code;
  l_rec.description                      :=  p_description;
  l_rec.criteria_type		         :=  p_criteria_type;
  l_rec.crit_col1_val_type_cd	         :=  p_crit_col1_val_type_cd;
  l_rec.crit_col1_datatype	    	 :=  p_crit_col1_datatype;
  l_rec.col1_lookup_type		 :=  p_col1_lookup_type;
  l_rec.col1_value_set_id                :=  p_col1_value_set_id;
  l_rec.access_table_name1               :=  p_access_table_name1;
  l_rec.access_column_name1	         :=  p_access_column_name1;
  l_rec.time_entry_access_tab_nam1       :=  p_time_entry_access_tab_nam1;
  l_rec.time_entry_access_col_nam1       :=  p_time_entry_access_col_nam1;
  l_rec.crit_col2_val_type_cd	         :=  p_crit_col2_val_type_cd;
  l_rec.crit_col2_datatype		 :=  p_crit_col2_datatype;
  l_rec.col2_lookup_type		 :=  p_col2_lookup_type;
  l_rec.col2_value_set_id                :=  p_col2_value_set_id;
  l_rec.access_table_name2		 :=  p_access_table_name2;
  l_rec.access_column_name2	         :=  p_access_column_name2;
  l_rec.time_entry_access_tab_nam2       :=  p_time_entry_access_tab_nam2;
  l_rec.time_entry_access_col_nam2       :=  p_time_entry_access_col_nam2;
  l_rec.allow_range_validation_flg       :=  p_allow_range_validation_flg;
  l_rec.user_defined_flag                :=  p_user_defined_flag;
  l_rec.business_group_id 	    	 :=  p_business_group_id;
  l_rec.egd_attribute_category           :=  p_egd_attribute_category;
  l_rec.egd_attribute1                   :=  p_egd_attribute1;
  l_rec.egd_attribute2                   :=  p_egd_attribute2;
  l_rec.egd_attribute3                   :=  p_egd_attribute3;
  l_rec.egd_attribute4                   :=  p_egd_attribute4;
  l_rec.egd_attribute5                   :=  p_egd_attribute5;
  l_rec.egd_attribute6                   :=  p_egd_attribute6;
  l_rec.egd_attribute7                   :=  p_egd_attribute7;
  l_rec.egd_attribute8                   :=  p_egd_attribute8;
  l_rec.egd_attribute9                   :=  p_egd_attribute9;
  l_rec.egd_attribute10              	 :=  p_egd_attribute10;
  l_rec.egd_attribute11              	 :=  p_egd_attribute11;
  l_rec.egd_attribute12              	 :=  p_egd_attribute12;
  l_rec.egd_attribute13              	 :=  p_egd_attribute13;
  l_rec.egd_attribute14              	 :=  p_egd_attribute14;
  l_rec.egd_attribute15              	 :=  p_egd_attribute15;
  l_rec.egd_attribute16              	 :=  p_egd_attribute16;
  l_rec.egd_attribute17              	 :=  p_egd_attribute17;
  l_rec.egd_attribute18              	 :=  p_egd_attribute18;
  l_rec.egd_attribute19              	 :=  p_egd_attribute19;
  l_rec.egd_attribute20              	 :=  p_egd_attribute20;
  l_rec.egd_attribute21              	 :=  p_egd_attribute21;
  l_rec.egd_attribute22              	 :=  p_egd_attribute22;
  l_rec.egd_attribute23              	 :=  p_egd_attribute23;
  l_rec.egd_attribute24              	 :=  p_egd_attribute24;
  l_rec.egd_attribute25              	 :=  p_egd_attribute25;
  l_rec.egd_attribute26              	 :=  p_egd_attribute26;
  l_rec.egd_attribute27              	 :=  p_egd_attribute27;
  l_rec.egd_attribute28              	 :=  p_egd_attribute28;
  l_rec.egd_attribute29              	 :=  p_egd_attribute29;
  l_rec.egd_attribute30              	 :=  p_egd_attribute30;
  l_rec.object_version_number        	 :=  p_object_version_number;
  l_rec.allow_range_validation_flag2     :=  p_allow_range_validation_flag2;
  l_Rec.time_access_calc_rule1         	 :=  p_time_access_calc_rule1;
  l_rec.time_access_calc_rule2         	 :=  p_time_access_calc_rule2;

  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_dpnt_egd_shd;


/
