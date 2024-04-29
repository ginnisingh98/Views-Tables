--------------------------------------------------------
--  DDL for Package Body BEN_CLP_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CLP_SHD" as
/* $Header: beclprhi.pkb 120.0.12010000.2 2008/08/05 14:17:49 ubhat ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_clp_shd.';  -- Global package name
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
  If (p_constraint_name = 'BEN_CLPSE_LF_EVT_F_PK') Then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
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
  (p_effective_date		in date,
   p_clpse_lf_evt_id		in number,
   p_object_version_number	in number
  ) Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	clpse_lf_evt_id,
	effective_start_date,
	effective_end_date,
	business_group_id,
	seq,
	ler1_id,
	bool1_cd,
	ler2_id,
	bool2_cd,
	ler3_id,
	bool3_cd,
	ler4_id,
	bool4_cd,
	ler5_id,
	bool5_cd,
	ler6_id,
	bool6_cd,
	ler7_id,
	bool7_cd,
	ler8_id,
	bool8_cd,
	ler9_id,
	bool9_cd,
	ler10_id,
	eval_cd,
	eval_rl,
	tlrnc_dys_num,
	eval_ler_id,
	eval_ler_det_cd,
	eval_ler_det_rl,
	clp_attribute_category,
	clp_attribute1,
	clp_attribute2,
	clp_attribute3,
	clp_attribute4,
	clp_attribute5,
	clp_attribute6,
	clp_attribute7,
	clp_attribute8,
	clp_attribute9,
	clp_attribute10,
	clp_attribute11,
	clp_attribute12,
	clp_attribute13,
	clp_attribute14,
	clp_attribute15,
	clp_attribute16,
	clp_attribute17,
	clp_attribute18,
	clp_attribute19,
	clp_attribute20,
	clp_attribute21,
	clp_attribute22,
	clp_attribute23,
	clp_attribute24,
	clp_attribute25,
	clp_attribute26,
	clp_attribute27,
	clp_attribute28,
	clp_attribute29,
	clp_attribute30,
	object_version_number
    from	ben_clpse_lf_evt_f
    where	clpse_lf_evt_id = p_clpse_lf_evt_id
    and		p_effective_date
    between	effective_start_date and effective_end_date;
--
  l_proc	varchar2(72)	:= g_package||'api_updating';
  l_fct_ret	boolean;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_effective_date is null or
      p_clpse_lf_evt_id is null or
      p_object_version_number is null) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_clpse_lf_evt_id = g_old_rec.clpse_lf_evt_id and
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
	(p_effective_date	in  date,
	 p_base_key_value	in  number,
	 p_zap		 out nocopy boolean,
	 p_delete	 out nocopy boolean,
	 p_future_change out nocopy boolean,
	 p_delete_next_change out nocopy boolean) is
--
  l_proc 		varchar2(72) 	:= g_package||'find_dt_del_modes';
--
  l_parent_key_value1	number;
  l_parent_key_value2	number;
  l_parent_key_value3	number;
  l_parent_key_value4	number;
  l_parent_key_value5	number;
  l_parent_key_value6	number;
  l_parent_key_value7	number;
  l_parent_key_value8	number;
  l_parent_key_value9	number;
  l_parent_key_value10	number;
  l_parent_key_value11	number;
  l_parent_key_value12	number;
  l_zap                 boolean;
  l_zap1                boolean;
  l_delete              boolean;
  l_delete1             boolean;
  l_future_change       boolean;
  l_future_change1      boolean;
  l_delete_next_change  boolean;
  l_delete_next_change1 boolean;
  --
  Cursor C_Sel1 Is
    select  t.ler1_id,
	    t.ler2_id,
	    t.ler3_id,
	    t.ler4_id,
	    t.ler5_id,
	    t.ler6_id,
	    t.ler7_id,
	    t.ler8_id,
	    t.ler9_id,
	    t.ler10_id,
	    t.eval_ler_id
    from    ben_clpse_lf_evt_f t
    where   t.clpse_lf_evt_id = p_base_key_value
    and     p_effective_date
    between t.effective_start_date and t.effective_end_date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  Open  C_Sel1;
  Fetch C_Sel1 Into l_parent_key_value1,
		    l_parent_key_value2,
		    l_parent_key_value3,
		    l_parent_key_value4,
		    l_parent_key_value5,
		    l_parent_key_value6,
		    l_parent_key_value7,
		    l_parent_key_value8,
		    l_parent_key_value9,
		    l_parent_key_value10,
		    l_parent_key_value11;
  If C_Sel1%notfound then
    Close C_Sel1;
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','10');
    hr_utility.raise_error;
  End If;
  Close C_Sel1;
  --
  -- Call the corresponding datetrack api
  --
  dt_api.find_dt_del_modes
	(p_effective_date	=> p_effective_date,
	 p_base_table_name	=> 'ben_clpse_lf_evt_f',
	 p_base_key_column	=> 'clpse_lf_evt_id',
	 p_base_key_value	=> p_base_key_value,
	 p_parent_table_name1	=> 'ben_ler_f',
	 p_parent_key_column1	=> 'ler_id',
	 p_parent_key_value1	=> l_parent_key_value1,
	 p_parent_table_name2	=> 'ben_ler_f',
	 p_parent_key_column2	=> 'ler_id',
	 p_parent_key_value2	=> l_parent_key_value2,
	 p_parent_table_name3	=> 'ben_ler_f',
	 p_parent_key_column3	=> 'ler_id',
	 p_parent_key_value3	=> l_parent_key_value3,
	 p_parent_table_name4	=> 'ben_ler_f',
	 p_parent_key_column4	=> 'ler_id',
	 p_parent_key_value4	=> l_parent_key_value4,
	 p_parent_table_name5	=> 'ben_ler_f',
	 p_parent_key_column5	=> 'ler_id',
	 p_parent_key_value5	=> l_parent_key_value5,
	 p_parent_table_name6	=> 'ben_ler_f',
	 p_parent_key_column6	=> 'ler_id',
	 p_parent_key_value6	=> l_parent_key_value6,
	 p_parent_table_name7	=> 'ben_ler_f',
	 p_parent_key_column7	=> 'ler_id',
	 p_parent_key_value7	=> l_parent_key_value7,
	 p_parent_table_name8	=> 'ben_ler_f',
	 p_parent_key_column8	=> 'ler_id',
	 p_parent_key_value8	=> l_parent_key_value8,
	 p_parent_table_name9	=> 'ben_ler_f',
	 p_parent_key_column9	=> 'ler_id',
	 p_parent_key_value9	=> l_parent_key_value9,
	 p_parent_table_name10	=> 'ben_ler_f',
	 p_parent_key_column10	=> 'ler_id',
	 p_parent_key_value10	=> l_parent_key_value10,
	 p_zap			=> l_zap,
	 p_delete		=> l_delete,
	 p_future_change	=> l_future_change,
	 p_delete_next_change	=> l_delete_next_change);
  --
  dt_api.find_dt_del_modes
	(p_effective_date	=> p_effective_date,
	 p_base_table_name	=> 'ben_clpse_lf_evt_f',
	 p_base_key_column	=> 'clpse_lf_evt_id',
	 p_base_key_value	=> p_base_key_value,
	 p_parent_table_name2 	=> 'ben_ler_f',
	 p_parent_key_column2 	=> 'ler_id',
	 p_parent_key_value2 	=> l_parent_key_value11,
	 p_zap			=> l_zap1,
	 p_delete		=> l_delete1,
	 p_future_change	=> l_future_change1,
	 p_delete_next_change	=> l_delete_next_change1);
  --
  if l_zap and l_zap1 then
    --
    p_zap := true;
    --
  else
    --
    p_zap := false;
    --
  end if;
  --
  if l_delete and l_delete1 then
    --
    p_delete := true;
    --
  else
    --
    p_delete := false;
    --
  end if;
  --
  if l_future_change and l_future_change1 then
    --
    p_future_change := true;
    --
  else
    --
    p_future_change := false;
    --
  end if;
  --
  if l_delete_next_change and l_delete_next_change1 then
    --
    p_delete_next_change := true;
    --
  else
    --
    p_delete_next_change := false;
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  --
End find_dt_del_modes;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< find_dt_upd_modes >---------------------------|
-- ----------------------------------------------------------------------------
Procedure find_dt_upd_modes
	(p_effective_date	in  date,
	 p_base_key_value	in  number,
	 p_correction	 out nocopy boolean,
	 p_update	 out nocopy boolean,
	 p_update_override out nocopy boolean,
	 p_update_change_insert out nocopy boolean) is
--
  l_proc 	varchar2(72) := g_package||'find_dt_upd_modes';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the corresponding datetrack api
  --
  dt_api.find_dt_upd_modes
	(p_effective_date	=> p_effective_date,
	 p_base_table_name	=> 'ben_clpse_lf_evt_f',
	 p_base_key_column	=> 'clpse_lf_evt_id',
	 p_base_key_value	=> p_base_key_value,
	 p_correction		=> p_correction,
	 p_update		=> p_update,
	 p_update_override	=> p_update_override,
	 p_update_change_insert	=> p_update_change_insert);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End find_dt_upd_modes;
--
-- ----------------------------------------------------------------------------
-- |------------------------< upd_effective_end_date >------------------------|
-- ----------------------------------------------------------------------------
Procedure upd_effective_end_date
	(p_effective_date		in date,
	 p_base_key_value		in number,
	 p_new_effective_end_date	in date,
	 p_validation_start_date	in date,
	 p_validation_end_date		in date,
         p_object_version_number       out nocopy number) is
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
	(p_base_table_name	=> 'ben_clpse_lf_evt_f',
	 p_base_key_column	=> 'clpse_lf_evt_id',
	 p_base_key_value	=> p_base_key_value);
  --
  hr_utility.set_location(l_proc, 10);
  g_api_dml := true;  -- Set the api dml status
  --
  -- Update the specified datetrack row setting the effective
  -- end date to the specified new effective end date.
  --
  update  ben_clpse_lf_evt_f t
  set	  t.effective_end_date	  = p_new_effective_end_date,
	  t.object_version_number = l_object_version_number
  where	  t.clpse_lf_evt_id	  = p_base_key_value
  and	  p_effective_date
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
	(p_effective_date	 in  date,
	 p_datetrack_mode	 in  varchar2,
	 p_clpse_lf_evt_id	 in  number,
	 p_object_version_number in  number,
	 p_validation_start_date out nocopy date,
	 p_validation_end_date	 out nocopy date) is
--
  l_proc		   varchar2(72) := g_package||'lck';
  l_validation_start_date  date;
  l_validation_end_date	   date;
  l_validation_start_date1 date;
  l_validation_end_date1   date;
  l_object_invalid 	   exception;
  l_argument		   varchar2(30);
  --
  -- Cursor C_Sel1 selects the current locked row as of session date
  -- ensuring that the object version numbers match.
  --
  Cursor C_Sel1 is
    select
	clpse_lf_evt_id,
	effective_start_date,
	effective_end_date,
	business_group_id,
	seq,
	ler1_id,
	bool1_cd,
	ler2_id,
	bool2_cd,
	ler3_id,
	bool3_cd,
	ler4_id,
	bool4_cd,
	ler5_id,
	bool5_cd,
	ler6_id,
	bool6_cd,
	ler7_id,
	bool7_cd,
	ler8_id,
	bool8_cd,
	ler9_id,
	bool9_cd,
	ler10_id,
	eval_cd,
	eval_rl,
	tlrnc_dys_num,
	eval_ler_id,
	eval_ler_det_cd,
	eval_ler_det_rl,
	clp_attribute_category,
	clp_attribute1,
	clp_attribute2,
	clp_attribute3,
	clp_attribute4,
	clp_attribute5,
	clp_attribute6,
	clp_attribute7,
	clp_attribute8,
	clp_attribute9,
	clp_attribute10,
	clp_attribute11,
	clp_attribute12,
	clp_attribute13,
	clp_attribute14,
	clp_attribute15,
	clp_attribute16,
	clp_attribute17,
	clp_attribute18,
	clp_attribute19,
	clp_attribute20,
	clp_attribute21,
	clp_attribute22,
	clp_attribute23,
	clp_attribute24,
	clp_attribute25,
	clp_attribute26,
	clp_attribute27,
	clp_attribute28,
	clp_attribute29,
	clp_attribute30,
	object_version_number
    from    ben_clpse_lf_evt_f
    where   clpse_lf_evt_id         = p_clpse_lf_evt_id
    and	    p_effective_date
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
                             p_argument       => 'clpse_lf_evt_id',
                             p_argument_value => p_clpse_lf_evt_id);
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
	(p_effective_date	   => p_effective_date,
	 p_datetrack_mode	   => p_datetrack_mode,
	 p_base_table_name	   => 'ben_clpse_lf_evt_f',
	 p_base_key_column	   => 'clpse_lf_evt_id',
	 p_base_key_value 	   => p_clpse_lf_evt_id,
	 p_parent_table_name1      => 'ben_ler_f',
	 p_parent_key_column1      => 'ler_id',
	 p_parent_key_value1       => g_old_rec.ler1_id,
	 p_parent_table_name2      => 'ben_ler_f',
	 p_parent_key_column2      => 'ler_id',
	 p_parent_key_value2       => g_old_rec.ler2_id,
	 p_parent_table_name3      => 'ben_ler_f',
	 p_parent_key_column3      => 'ler_id',
	 p_parent_key_value3       => g_old_rec.ler3_id,
	 p_parent_table_name4      => 'ben_ler_f',
	 p_parent_key_column4      => 'ler_id',
	 p_parent_key_value4       => g_old_rec.ler4_id,
	 p_parent_table_name5      => 'ben_ler_f',
	 p_parent_key_column5      => 'ler_id',
	 p_parent_key_value5       => g_old_rec.ler5_id,
	 p_parent_table_name6      => 'ben_ler_f',
	 p_parent_key_column6      => 'ler_id',
	 p_parent_key_value6       => g_old_rec.ler6_id,
	 p_parent_table_name7      => 'ben_ler_f',
	 p_parent_key_column7      => 'ler_id',
	 p_parent_key_value7       => g_old_rec.ler7_id,
	 p_parent_table_name8      => 'ben_ler_f',
	 p_parent_key_column8      => 'ler_id',
	 p_parent_key_value8       => g_old_rec.ler8_id,
	 p_parent_table_name9      => 'ben_ler_f',
	 p_parent_key_column9      => 'ler_id',
	 p_parent_key_value9       => g_old_rec.ler9_id,
	 p_parent_table_name10     => 'ben_ler_f',
	 p_parent_key_column10     => 'ler_id',
	 p_parent_key_value10      => g_old_rec.ler10_id,
         p_enforce_foreign_locking => true,
	 p_validation_start_date   => l_validation_start_date,
 	 p_validation_end_date	   => l_validation_end_date);
    --
    dt_api.validate_dt_mode
	(p_effective_date	   => p_effective_date,
	 p_datetrack_mode	   => p_datetrack_mode,
	 p_base_table_name	   => 'ben_clpse_lf_evt_f',
	 p_base_key_column	   => 'clpse_lf_evt_id',
	 p_base_key_value 	   => p_clpse_lf_evt_id,
	 p_parent_table_name1      => 'ben_ler_f',
	 p_parent_key_column1      => 'eval_ler_id',
	 p_parent_key_value1       => g_old_rec.eval_ler_id,
         p_enforce_foreign_locking => true,
	 p_validation_start_date   => l_validation_start_date1,
 	 p_validation_end_date	   => l_validation_end_date1);
    --
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
    --
  End If;
  --
  -- Set the validation start and end date OUT arguments
  --
  if l_validation_start_date > l_validation_start_date1 then
    --
    p_validation_start_date := l_validation_start_date;
    --
  else
    --
    p_validation_start_date := l_validation_start_date1;
    --
  end if;
  --
  if l_validation_end_date > l_validation_end_date1 then
    --
    p_validation_end_date := l_validation_end_date;
    --
  else
    --
    p_validation_end_date := l_validation_end_date1;
    --
  end if;
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
    hr_utility.set_message_token('TABLE_NAME', 'ben_clpse_lf_evt_f');
    hr_utility.raise_error;
  When l_object_invalid then
    --
    -- The object doesn't exist or is invalid
    --
    hr_utility.set_message(801, 'HR_7155_OBJECT_INVALID');
    hr_utility.set_message_token('TABLE_NAME', 'ben_clpse_lf_evt_f');
    hr_utility.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_clpse_lf_evt_id               in number,
	p_effective_start_date          in date,
	p_effective_end_date            in date,
	p_business_group_id             in number,
	p_seq                           in number,
	p_ler1_id                       in number,
	p_bool1_cd                      in varchar2,
	p_ler2_id                       in number,
	p_bool2_cd                      in varchar2,
	p_ler3_id                       in number,
	p_bool3_cd                      in varchar2,
	p_ler4_id                       in number,
	p_bool4_cd                      in varchar2,
	p_ler5_id                       in number,
	p_bool5_cd                      in varchar2,
	p_ler6_id                       in number,
	p_bool6_cd                      in varchar2,
	p_ler7_id                       in number,
	p_bool7_cd                      in varchar2,
	p_ler8_id                       in number,
	p_bool8_cd                      in varchar2,
	p_ler9_id                       in number,
	p_bool9_cd                      in varchar2,
	p_ler10_id                      in number,
	p_eval_cd                       in varchar2,
	p_eval_rl                       in number,
	p_tlrnc_dys_num                 in number,
	p_eval_ler_id                   in number,
	p_eval_ler_det_cd               in varchar2,
	p_eval_ler_det_rl               in number,
	p_clp_attribute_category        in varchar2,
	p_clp_attribute1                in varchar2,
	p_clp_attribute2                in varchar2,
	p_clp_attribute3                in varchar2,
	p_clp_attribute4                in varchar2,
	p_clp_attribute5                in varchar2,
	p_clp_attribute6                in varchar2,
	p_clp_attribute7                in varchar2,
	p_clp_attribute8                in varchar2,
	p_clp_attribute9                in varchar2,
	p_clp_attribute10               in varchar2,
	p_clp_attribute11               in varchar2,
	p_clp_attribute12               in varchar2,
	p_clp_attribute13               in varchar2,
	p_clp_attribute14               in varchar2,
	p_clp_attribute15               in varchar2,
	p_clp_attribute16               in varchar2,
	p_clp_attribute17               in varchar2,
	p_clp_attribute18               in varchar2,
	p_clp_attribute19               in varchar2,
	p_clp_attribute20               in varchar2,
	p_clp_attribute21               in varchar2,
	p_clp_attribute22               in varchar2,
	p_clp_attribute23               in varchar2,
	p_clp_attribute24               in varchar2,
	p_clp_attribute25               in varchar2,
	p_clp_attribute26               in varchar2,
	p_clp_attribute27               in varchar2,
	p_clp_attribute28               in varchar2,
	p_clp_attribute29               in varchar2,
	p_clp_attribute30               in varchar2,
	p_object_version_number         in number
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
  l_rec.clpse_lf_evt_id                  := p_clpse_lf_evt_id;
  l_rec.effective_start_date             := p_effective_start_date;
  l_rec.effective_end_date               := p_effective_end_date;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.seq                              := p_seq;
  l_rec.ler1_id                          := p_ler1_id;
  l_rec.bool1_cd                         := p_bool1_cd;
  l_rec.ler2_id                          := p_ler2_id;
  l_rec.bool2_cd                         := p_bool2_cd;
  l_rec.ler3_id                          := p_ler3_id;
  l_rec.bool3_cd                         := p_bool3_cd;
  l_rec.ler4_id                          := p_ler4_id;
  l_rec.bool4_cd                         := p_bool4_cd;
  l_rec.ler5_id                          := p_ler5_id;
  l_rec.bool5_cd                         := p_bool5_cd;
  l_rec.ler6_id                          := p_ler6_id;
  l_rec.bool6_cd                         := p_bool6_cd;
  l_rec.ler7_id                          := p_ler7_id;
  l_rec.bool7_cd                         := p_bool7_cd;
  l_rec.ler8_id                          := p_ler8_id;
  l_rec.bool8_cd                         := p_bool8_cd;
  l_rec.ler9_id                          := p_ler9_id;
  l_rec.bool9_cd                         := p_bool9_cd;
  l_rec.ler10_id                         := p_ler10_id;
  l_rec.eval_cd                          := p_eval_cd;
  l_rec.eval_rl                          := p_eval_rl;
  l_rec.tlrnc_dys_num                    := p_tlrnc_dys_num;
  l_rec.eval_ler_id                      := p_eval_ler_id;
  l_rec.eval_ler_det_cd                  := p_eval_ler_det_cd;
  l_rec.eval_ler_det_rl                  := p_eval_ler_det_rl;
  l_rec.clp_attribute_category           := p_clp_attribute_category;
  l_rec.clp_attribute1                   := p_clp_attribute1;
  l_rec.clp_attribute2                   := p_clp_attribute2;
  l_rec.clp_attribute3                   := p_clp_attribute3;
  l_rec.clp_attribute4                   := p_clp_attribute4;
  l_rec.clp_attribute5                   := p_clp_attribute5;
  l_rec.clp_attribute6                   := p_clp_attribute6;
  l_rec.clp_attribute7                   := p_clp_attribute7;
  l_rec.clp_attribute8                   := p_clp_attribute8;
  l_rec.clp_attribute9                   := p_clp_attribute9;
  l_rec.clp_attribute10                  := p_clp_attribute10;
  l_rec.clp_attribute11                  := p_clp_attribute11;
  l_rec.clp_attribute12                  := p_clp_attribute12;
  l_rec.clp_attribute13                  := p_clp_attribute13;
  l_rec.clp_attribute14                  := p_clp_attribute14;
  l_rec.clp_attribute15                  := p_clp_attribute15;
  l_rec.clp_attribute16                  := p_clp_attribute16;
  l_rec.clp_attribute17                  := p_clp_attribute17;
  l_rec.clp_attribute18                  := p_clp_attribute18;
  l_rec.clp_attribute19                  := p_clp_attribute19;
  l_rec.clp_attribute20                  := p_clp_attribute20;
  l_rec.clp_attribute21                  := p_clp_attribute21;
  l_rec.clp_attribute22                  := p_clp_attribute22;
  l_rec.clp_attribute23                  := p_clp_attribute23;
  l_rec.clp_attribute24                  := p_clp_attribute24;
  l_rec.clp_attribute25                  := p_clp_attribute25;
  l_rec.clp_attribute26                  := p_clp_attribute26;
  l_rec.clp_attribute27                  := p_clp_attribute27;
  l_rec.clp_attribute28                  := p_clp_attribute28;
  l_rec.clp_attribute29                  := p_clp_attribute29;
  l_rec.clp_attribute30                  := p_clp_attribute30;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_clp_shd;

/
