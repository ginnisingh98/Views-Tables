--------------------------------------------------------
--  DDL for Package Body BEN_EGL_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EGL_SHD" as
/* $Header: beeglrhi.pkb 120.9 2006/06/19 12:07:41 swjain noship $ */

--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_egl_shd.';  -- Global package name
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
  If (p_constraint_name = 'BEN_eligy_criteria_FK1') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  ElsIf (p_constraint_name = 'BEN_eligy_criteria_PK') Then
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
  p_eligy_criteria_id                  in number,
  p_object_version_number              in number
  )      Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
  eligy_criteria_id,
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
access_calc_rule,
allow_range_validation_flag,
user_defined_flag,
business_group_id,
legislation_code,
egl_attribute_category,
egl_attribute1,
egl_attribute2,
egl_attribute3,
egl_attribute4,
egl_attribute5,
egl_attribute6,
egl_attribute7,
egl_attribute8,
egl_attribute9,
egl_attribute10,
egl_attribute11,
egl_attribute12,
egl_attribute13,
egl_attribute14,
egl_attribute15,
egl_attribute16,
egl_attribute17,
egl_attribute18,
egl_attribute19,
egl_attribute20,
egl_attribute21,
egl_attribute22,
egl_attribute23,
egl_attribute24,
egl_attribute25,
egl_attribute26,
egl_attribute27,
egl_attribute28,
egl_attribute29,
egl_attribute30,
object_version_number,
allow_range_validation_flag2,
access_calc_rule2,
time_access_calc_rule1,
time_access_calc_rule2
    from	ben_eligy_criteria
    where	eligy_criteria_id = p_eligy_criteria_id;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (
	p_eligy_criteria_id is null and
	p_object_version_number is null
     ) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (
	p_eligy_criteria_id = g_old_rec.eligy_criteria_id and
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
  p_eligy_criteria_id                  in number,
  p_object_version_number              in number
  ) is
--
-- Cursor selects the 'current' row from the HR Schema
--
  Cursor C_Sel1 is
    select
    eligy_criteria_id,
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
    access_calc_rule,
    allow_range_validation_flag,
    user_defined_flag,
    business_group_id,
    legislation_code,
    egl_attribute_category,
    egl_attribute1,
    egl_attribute2,
    egl_attribute3,
    egl_attribute4,
    egl_attribute5,
    egl_attribute6,
    egl_attribute7,
    egl_attribute8,
    egl_attribute9,
    egl_attribute10,
    egl_attribute11,
    egl_attribute12,
    egl_attribute13,
    egl_attribute14,
    egl_attribute15,
    egl_attribute16,
    egl_attribute17,
    egl_attribute18,
    egl_attribute19,
    egl_attribute20,
    egl_attribute21,
    egl_attribute22,
    egl_attribute23,
    egl_attribute24,
    egl_attribute25,
    egl_attribute26,
    egl_attribute27,
    egl_attribute28,
    egl_attribute29,
    egl_attribute30,
    object_version_number,
    allow_range_validation_flag2,
    access_calc_rule2,
    time_access_calc_rule1,
    time_access_calc_rule2
    from	ben_eligy_criteria
    where	eligy_criteria_id = p_eligy_criteria_id
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
    hr_utility.set_message_token('TABLE_NAME', 'ben_eligy_criteria');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_eligy_criteria_id              in  number,
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
	p_access_calc_rule		 in  number,
	p_allow_range_validation_flg     in  varchar2,
	p_user_defined_flag              in  varchar2,
	p_business_group_id 	    	 in  number,
	p_legislation_code 	    	 in  varchar2,
	p_egl_attribute_category         in  varchar2,
	p_egl_attribute1                 in  varchar2,
	p_egl_attribute2                 in  varchar2,
	p_egl_attribute3                 in  varchar2,
	p_egl_attribute4                 in  varchar2,
	p_egl_attribute5                 in  varchar2,
	p_egl_attribute6                 in  varchar2,
	p_egl_attribute7                 in  varchar2,
	p_egl_attribute8                 in  varchar2,
	p_egl_attribute9                 in  varchar2,
	p_egl_attribute10                in  varchar2,
	p_egl_attribute11                in  varchar2,
	p_egl_attribute12                in  varchar2,
	p_egl_attribute13                in  varchar2,
	p_egl_attribute14                in  varchar2,
	p_egl_attribute15                in  varchar2,
	p_egl_attribute16                in  varchar2,
	p_egl_attribute17                in  varchar2,
	p_egl_attribute18                in  varchar2,
	p_egl_attribute19                in  varchar2,
	p_egl_attribute20                in  varchar2,
	p_egl_attribute21                in  varchar2,
	p_egl_attribute22                in  varchar2,
	p_egl_attribute23                in  varchar2,
	p_egl_attribute24                in  varchar2,
	p_egl_attribute25                in  varchar2,
	p_egl_attribute26                in  varchar2,
	p_egl_attribute27                in  varchar2,
	p_egl_attribute28                in  varchar2,
	p_egl_attribute29                in  varchar2,
	p_egl_attribute30                in  varchar2,
	p_object_version_number          in  number  ,
        p_allow_range_validation_flag2   in  varchar2,
        p_access_calc_rule2              in  number ,
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
  l_rec.eligy_criteria_id                :=  p_eligy_criteria_id;
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
  l_rec.access_calc_rule		 :=  p_access_calc_rule;
  l_rec.allow_range_validation_flg       :=  p_allow_range_validation_flg;
  l_rec.user_defined_flag                :=  p_user_defined_flag;
  l_rec.business_group_id 	    	 :=  p_business_group_id;
  l_rec.legislation_code 	    	 :=  p_legislation_code;
  l_rec.egl_attribute_category           :=  p_egl_attribute_category;
  l_rec.egl_attribute1                   :=  p_egl_attribute1;
  l_rec.egl_attribute2                   :=  p_egl_attribute2;
  l_rec.egl_attribute3                   :=  p_egl_attribute3;
  l_rec.egl_attribute4                   :=  p_egl_attribute4;
  l_rec.egl_attribute5                   :=  p_egl_attribute5;
  l_rec.egl_attribute6                   :=  p_egl_attribute6;
  l_rec.egl_attribute7                   :=  p_egl_attribute7;
  l_rec.egl_attribute8                   :=  p_egl_attribute8;
  l_rec.egl_attribute9                   :=  p_egl_attribute9;
  l_rec.egl_attribute10              	 :=  p_egl_attribute10;
  l_rec.egl_attribute11              	 :=  p_egl_attribute11;
  l_rec.egl_attribute12              	 :=  p_egl_attribute12;
  l_rec.egl_attribute13              	 :=  p_egl_attribute13;
  l_rec.egl_attribute14              	 :=  p_egl_attribute14;
  l_rec.egl_attribute15              	 :=  p_egl_attribute15;
  l_rec.egl_attribute16              	 :=  p_egl_attribute16;
  l_rec.egl_attribute17              	 :=  p_egl_attribute17;
  l_rec.egl_attribute18              	 :=  p_egl_attribute18;
  l_rec.egl_attribute19              	 :=  p_egl_attribute19;
  l_rec.egl_attribute20              	 :=  p_egl_attribute20;
  l_rec.egl_attribute21              	 :=  p_egl_attribute21;
  l_rec.egl_attribute22              	 :=  p_egl_attribute22;
  l_rec.egl_attribute23              	 :=  p_egl_attribute23;
  l_rec.egl_attribute24              	 :=  p_egl_attribute24;
  l_rec.egl_attribute25              	 :=  p_egl_attribute25;
  l_rec.egl_attribute26              	 :=  p_egl_attribute26;
  l_rec.egl_attribute27              	 :=  p_egl_attribute27;
  l_rec.egl_attribute28              	 :=  p_egl_attribute28;
  l_rec.egl_attribute29              	 :=  p_egl_attribute29;
  l_rec.egl_attribute30              	 :=  p_egl_attribute30;
  l_rec.object_version_number        	 :=  p_object_version_number;
  l_rec.allow_range_validation_flag2     :=  p_allow_range_validation_flag2;
  l_rec.access_calc_rule2              	 :=  p_access_calc_rule2;
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
end ben_egl_shd;


/
