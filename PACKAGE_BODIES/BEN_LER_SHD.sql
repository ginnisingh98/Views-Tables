--------------------------------------------------------
--  DDL for Package Body BEN_LER_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_LER_SHD" as
/* $Header: belerrhi.pkb 120.2 2006/11/03 10:34:58 vborkar noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_ler_shd.';  -- Global package name
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
  If (p_constraint_name = 'BEN_LER_FK1') Then
    fnd_message.set_name('BEN', 'BEN_91000_INVALID_BUS_GROUP');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_LER_PK') Then
    fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_LER_UK1') Then
    fnd_message.set_name('BEN', 'BEN_91009_NAME_NOT_UNIQUE');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_LER_UK2') Then
    fnd_message.set_name('BEN', 'BEN_91001_SEQ_NOT_UNIQUE');
    fnd_message.raise_error;
  Else
    fnd_message.set_name('PAY', 'HR_7877_API_INVALID_CONSTRAINT');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('CONSTRAINT_NAME', p_constraint_name);
    fnd_message.raise_error;
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
   p_ler_id	             	in number,
   p_object_version_number	in number
  ) Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
	ler_id,
	effective_start_date,
	effective_end_date,
	name,
	business_group_id,
	typ_cd,
	lf_evt_oper_cd,
	short_name,
	short_code,
	ptnl_ler_trtmt_cd,
	ck_rltd_per_elig_flag,
	ler_eval_rl,
	cm_aply_flag,
	ovridg_le_flag,
	qualg_evt_flag,
	whn_to_prcs_cd,
	desc_txt,
	tmlns_eval_cd,
	tmlns_perd_cd,
	tmlns_dys_num,
	tmlns_perd_rl,
	ocrd_dt_det_cd,
  ler_stat_cd,
  slctbl_slf_svc_cd,
	ss_pcp_disp_cd,
	ler_attribute_category,
	ler_attribute1,
	ler_attribute2,
	ler_attribute3,
	ler_attribute4,
	ler_attribute5,
	ler_attribute6,
	ler_attribute7,
	ler_attribute8,
	ler_attribute9,
	ler_attribute10,
	ler_attribute11,
	ler_attribute12,
	ler_attribute13,
	ler_attribute14,
	ler_attribute15,
	ler_attribute16,
	ler_attribute17,
	ler_attribute18,
	ler_attribute19,
	ler_attribute20,
	ler_attribute21,
	ler_attribute22,
	ler_attribute23,
	ler_attribute24,
	ler_attribute25,
	ler_attribute26,
	ler_attribute27,
	ler_attribute28,
	ler_attribute29,
	ler_attribute30,
	object_version_number
    from	ben_ler_f
    where	ler_id = p_ler_id
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
      p_ler_id is null or
      p_object_version_number is null) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_ler_id = g_old_rec.ler_id and
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
        fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
        fnd_message.raise_error;
      End If;
      Close C_Sel1;
      If (p_object_version_number <> g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
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
  --
  Cursor C_Sel1 Is
    select  t.ler_eval_rl
    from    ben_ler_f t
    where   t.ler_id = p_base_key_value
    and     p_effective_date
    between t.effective_start_date and t.effective_end_date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  Open  C_Sel1;
  Fetch C_Sel1 Into l_parent_key_value1;
  If C_Sel1%notfound then
    Close C_Sel1;
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','10');
    fnd_message.raise_error;
  End If;
  Close C_Sel1;
  --
  -- Call the corresponding datetrack api
  --
  dt_api.find_dt_del_modes
	(p_effective_date	=> p_effective_date,
	 p_base_table_name	=> 'ben_ler_f',
	 p_base_key_column	=> 'ler_id',
	 p_base_key_value	=> p_base_key_value,
	 p_parent_table_name1	=> 'ff_formulas_f',
	 p_parent_key_column1	=> 'formula_id',
	 p_parent_key_value1	=> l_parent_key_value1,
	 p_zap			=> p_zap,
	 p_delete		=> p_delete,
	 p_future_change	=> p_future_change,
	 p_delete_next_change	=> p_delete_next_change);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
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
	 p_base_table_name	=> 'ben_ler_f',
	 p_base_key_column	=> 'ler_id',
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
	(p_base_table_name	=> 'ben_ler_f',
	 p_base_key_column	=> 'ler_id',
	 p_base_key_value	=> p_base_key_value);
  --
  hr_utility.set_location(l_proc, 10);
  g_api_dml := true;  -- Set the api dml status
  --
  -- Update the specified datetrack row setting the effective
  -- end date to the specified new effective end date.
  --
  update  ben_ler_f t
  set	  t.effective_end_date	  = p_new_effective_end_date,
	  t.object_version_number = l_object_version_number
  where	  t.ler_id	  = p_base_key_value
  and	  p_effective_date
  between t.effective_start_date and t.effective_end_date;
  --
  update  ben_ler_f_tl t
  set	  t.effective_end_date	  = p_new_effective_end_date,
          t.last_update_date = sysdate,
          t.last_updated_by = fnd_global.user_id,
          t.last_update_login = fnd_global.login_id
  where	  t.ler_id	  = p_base_key_value
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
	 p_ler_id	 in  number,
	 p_object_version_number in  number,
	 p_validation_start_date out nocopy date,
	 p_validation_end_date	 out nocopy date) is
--
  l_proc		  varchar2(72) := g_package||'lck';
  l_validation_start_date date;
  l_validation_end_date	  date;
  l_val_end_date1	  date;
  l_val_start_date1 date;
  l_val_end_date2	  date;
  l_val_start_date2 date;
  l_object_invalid 	  exception;
  l_argument		  varchar2(30);
  --
  -- Cursor C_Sel1 selects the current locked row as of session date
  -- ensuring that the object version numbers match.
  --
  Cursor C_Sel1 is
    select
	ler_id,
	effective_start_date,
	effective_end_date,
	name,
	business_group_id,
	typ_cd,
	lf_evt_oper_cd,
	short_name,
	short_code,
	ptnl_ler_trtmt_cd,
	ck_rltd_per_elig_flag,
	ler_eval_rl,
	cm_aply_flag,
	ovridg_le_flag,
	qualg_evt_flag,
	whn_to_prcs_cd,
	desc_txt,
	tmlns_eval_cd,
	tmlns_perd_cd,
	tmlns_dys_num,
	tmlns_perd_rl,
	ocrd_dt_det_cd,
  ler_stat_cd,
  slctbl_slf_svc_cd,
	ss_pcp_disp_cd,
	ler_attribute_category,
	ler_attribute1,
	ler_attribute2,
	ler_attribute3,
	ler_attribute4,
	ler_attribute5,
	ler_attribute6,
	ler_attribute7,
	ler_attribute8,
	ler_attribute9,
	ler_attribute10,
	ler_attribute11,
	ler_attribute12,
	ler_attribute13,
	ler_attribute14,
	ler_attribute15,
	ler_attribute16,
	ler_attribute17,
	ler_attribute18,
	ler_attribute19,
	ler_attribute20,
	ler_attribute21,
	ler_attribute22,
	ler_attribute23,
	ler_attribute24,
	ler_attribute25,
	ler_attribute26,
	ler_attribute27,
	ler_attribute28,
	ler_attribute29,
	ler_attribute30,
	object_version_number
    from    ben_ler_f
    where   ler_id         = p_ler_id
    and	    p_effective_date
    between effective_start_date and effective_end_date
    for update nowait;
  --
  -- Cursor for special locking code :
  --
  -- Do not select rows where the rsltg_ler_id = ler_id because
  -- those rows would have already been locked by the call to
  -- dt_api.validate_dt_mode.
  --
  Cursor C_lock (p_ler_id in number)  is
      select t1.effective_end_date effective_end_date
      from   ben_css_rltd_per_per_in_ler_f  t1
      where  (t1.css_rltd_per_per_in_ler_id,
              t1.effective_start_date,
              t1.effective_end_date) in
             (select t2.css_rltd_per_per_in_ler_id,
                     max(t2.effective_start_date),
                     max(t2.effective_end_date)
              from   ben_css_rltd_per_per_in_ler_f t2
              where  t2.rsltg_ler_id = p_ler_id
                and  t2.ler_id       <> p_ler_id
              group by t2.css_rltd_per_per_in_ler_id)
      order  by t1.css_rltd_per_per_in_ler_id
      for    update nowait;
  l_lck_date    date;                   -- locked date
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
                             p_argument       => 'ler_id',
                             p_argument_value => p_ler_id);
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
      fnd_message.set_name('PAY', 'HR_7220_INVALID_PRIMARY_KEY');
      fnd_message.raise_error;
    End If;
    Close C_Sel1;
    If (p_object_version_number <> g_old_rec.object_version_number) Then
        fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
        fnd_message.raise_error;
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
	 p_base_table_name	   => 'ben_ler_f',
	 p_base_key_column	   => 'ler_id',
	 p_base_key_value 	   => p_ler_id,
	 p_parent_table_name1      => 'ff_formulas_f',
	 p_parent_key_column1      => 'formula_id',
	 p_parent_key_value1       => g_old_rec.ler_eval_rl,
	 p_child_table_name1       => 'ben_lee_rsn_f',
	 p_child_key_column1       => 'lee_rsn_id',
	 p_child_table_name2       => 'ben_ler_chg_plip_enrt_f',
	 p_child_key_column2       => 'ler_chg_plip_enrt_id',
	 p_child_table_name3       => 'ben_ler_chg_pl_nip_enrt_f',
	 p_child_key_column3       => 'ler_chg_pl_nip_enrt_id',
	 p_child_table_name4       => 'ben_ler_chg_oipl_enrt_f',
	 p_child_key_column4       => 'ler_chg_oipl_enrt_id',
	 p_child_table_name5       => 'ben_elig_to_prte_rsn_f',
	 p_child_key_column5       => 'elig_to_prte_rsn_id',
	 p_child_table_name6       => 'ben_ler_chg_dpnt_cvg_f',
	 p_child_key_column6       => 'ler_chg_dpnt_cvg_id',
	 p_child_table_name8       => 'ben_elig_per_f',
	 p_child_key_column8       => 'elig_per_id',
	 p_child_table_name9       => 'ben_ler_per_info_cs_ler_f',
	 p_child_key_column9       => 'ler_per_info_cs_ler_id',
         p_enforce_foreign_locking => false, --true,  -- 3301171
	 p_validation_start_date   => l_val_start_date1,
 	 p_validation_end_date	   => l_val_end_date1);

    dt_api.validate_dt_mode
	(p_effective_date	   => p_effective_date,
	 p_datetrack_mode	   => p_datetrack_mode,
	 p_base_table_name	   => 'ben_ler_f',
	 p_base_key_column	   => 'ler_id',
	 p_base_key_value 	   => p_ler_id,
	 p_child_table_name1       => 'ben_ler_rltd_per_cs_ler_f',
	 p_child_key_column1       => 'ler_rltd_per_cs_ler_id',
	 p_child_table_name2       => 'ben_css_rltd_per_per_in_ler_f',
	 p_child_key_column2       => 'css_rltd_per_per_in_ler_id',
         p_enforce_foreign_locking => false, --true, -- 3301171
	 p_validation_start_date   => l_val_start_date2,
 	 p_validation_end_date	   => l_val_end_date2);

    --
    -- because we call dt_api.validate_dt_mode twice, we must check
    -- which set of validation dates we should use.
    --
    -- PETER, DO WE REALLY NEED TO DO THIS HERE, SINCE WE ARE ONLY CALLING
    -- IT TWICE DUE TO ADDITIONAL CHILD TABLES, NOT ADDITIONAL PARENT
    -- RECORDS??
    --
    if l_val_start_date1 > l_val_start_date2 then
       l_validation_start_date := l_val_start_date1;
    else
       l_validation_start_date := l_val_start_date2;
    end if;

    if l_val_end_date1 < l_val_end_date2 then
       l_validation_end_date := l_val_end_date1;
    else
       l_validation_end_date := l_val_end_date2;
    end if;


    -- Since we have two foreign keys from child ben_css_rltd_per_per_in_ler_f
    -- to parent ben_ler_f, we must manually lock the rows on the child
    -- where the foreign key name is not ler_id.
    --
    begin     -- special locking code
      if p_datetrack_mode = hr_api.g_delete and p_ler_id is not null then
         Open C_lock(p_ler_id => p_ler_id);
         <<Outer1>>
         loop
            Fetch C_lock Into l_lck_date;
            If C_lock%notfound or C_lock%notfound is null then
               exit Outer1;
            elsif (l_lck_date > l_validation_start_date) then
              --
              -- The maximum end date is greater than the validation start date
              -- therefore we must error
              --
              Close C_lock;
              fnd_message.set_name('PAY', 'HR_7201_DT_NO_DELETE_CHILD');
              fnd_message.raise_error;
            end if;
         end loop;
         Close C_lock;
      end if;
    Exception
      When HR_Api.Object_Locked then
      --
      -- The object is locked therefore we need to supply a meaningful
      -- error message.
      --
      if C_lock%isopen then
         Close C_lock;
      end if;
      fnd_message.set_name('PAY', 'HR_7165_OBJECT_LOCKED');
      fnd_message.set_token('TABLE_NAME', 'ben_css_rltd_per_per_in_ler_f');
      fnd_message.raise_error;
    end;  -- special locking code

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
    fnd_message.set_token('TABLE_NAME', 'ben_ler_f');
    fnd_message.raise_error;
  When l_object_invalid then
    --
    -- The object doesn't exist or is invalid
    --
    fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
    fnd_message.set_token('TABLE_NAME', 'ben_ler_f');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
	(
	p_ler_id                        in number,
	p_effective_start_date          in date,
	p_effective_end_date            in date,
	p_name                          in varchar2,
	p_business_group_id             in number,
	p_typ_cd                        in varchar2,
	p_lf_evt_oper_cd                in varchar2,
	p_short_name                in varchar2,
	p_short_code                in varchar2,
	p_ptnl_ler_trtmt_cd             in varchar2,
	p_ck_rltd_per_elig_flag         in varchar2,
	p_ler_eval_rl                   in number,
	p_cm_aply_flag                  in varchar2,
	p_ovridg_le_flag                in varchar2,
	p_qualg_evt_flag                in varchar2,
	p_whn_to_prcs_cd                in varchar2,
	p_desc_txt                      in varchar2,
	p_tmlns_eval_cd                 in varchar2,
	p_tmlns_perd_cd                 in varchar2,
	p_tmlns_dys_num                 in number,
	p_tmlns_perd_rl                 in number,
	p_ocrd_dt_det_cd                in varchar2,
  p_ler_stat_cd                   in varchar2,
  p_slctbl_slf_svc_cd             in varchar2,
  p_ss_pcp_disp_cd                in varchar2,
	p_ler_attribute_category        in varchar2,
	p_ler_attribute1                in varchar2,
	p_ler_attribute2                in varchar2,
	p_ler_attribute3                in varchar2,
	p_ler_attribute4                in varchar2,
	p_ler_attribute5                in varchar2,
	p_ler_attribute6                in varchar2,
	p_ler_attribute7                in varchar2,
	p_ler_attribute8                in varchar2,
	p_ler_attribute9                in varchar2,
	p_ler_attribute10               in varchar2,
	p_ler_attribute11               in varchar2,
	p_ler_attribute12               in varchar2,
	p_ler_attribute13               in varchar2,
	p_ler_attribute14               in varchar2,
	p_ler_attribute15               in varchar2,
	p_ler_attribute16               in varchar2,
	p_ler_attribute17               in varchar2,
	p_ler_attribute18               in varchar2,
	p_ler_attribute19               in varchar2,
	p_ler_attribute20               in varchar2,
	p_ler_attribute21               in varchar2,
	p_ler_attribute22               in varchar2,
	p_ler_attribute23               in varchar2,
	p_ler_attribute24               in varchar2,
	p_ler_attribute25               in varchar2,
	p_ler_attribute26               in varchar2,
	p_ler_attribute27               in varchar2,
	p_ler_attribute28               in varchar2,
	p_ler_attribute29               in varchar2,
	p_ler_attribute30               in varchar2,
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
  l_rec.ler_id                           := p_ler_id;
  l_rec.effective_start_date             := p_effective_start_date;
  l_rec.effective_end_date               := p_effective_end_date;
  l_rec.name                             := p_name;
  l_rec.lf_evt_oper_cd                   := p_lf_evt_oper_cd;
  l_rec.short_name                       := p_short_name;
  l_rec.short_code                       := p_short_code;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.typ_cd                           := p_typ_cd;
  l_rec.ptnl_ler_trtmt_cd                := p_ptnl_ler_trtmt_cd;
  l_rec.ck_rltd_per_elig_flag            := p_ck_rltd_per_elig_flag;
  l_rec.ler_eval_rl                      := p_ler_eval_rl;
  l_rec.cm_aply_flag                     := p_cm_aply_flag;
  l_rec.ovridg_le_flag                   := p_ovridg_le_flag;
  l_rec.qualg_evt_flag                   := p_qualg_evt_flag;
  l_rec.whn_to_prcs_cd                   := p_whn_to_prcs_cd;
  l_rec.desc_txt                         := p_desc_txt;
  l_rec.tmlns_eval_cd                    := p_tmlns_eval_cd;
  l_rec.tmlns_perd_cd                    := p_tmlns_perd_cd;
  l_rec.tmlns_dys_num                    := p_tmlns_dys_num;
  l_rec.tmlns_perd_rl                    := p_tmlns_perd_rl;
  l_rec.ocrd_dt_det_cd                   := p_ocrd_dt_det_cd;
  l_rec.ler_stat_cd                      := p_ler_stat_cd;
  l_rec.slctbl_slf_svc_cd                := p_slctbl_slf_svc_cd;
  l_rec.ss_pcp_disp_cd                   := p_ss_pcp_disp_cd;
  l_rec.ler_attribute_category           := p_ler_attribute_category;
  l_rec.ler_attribute1                   := p_ler_attribute1;
  l_rec.ler_attribute2                   := p_ler_attribute2;
  l_rec.ler_attribute3                   := p_ler_attribute3;
  l_rec.ler_attribute4                   := p_ler_attribute4;
  l_rec.ler_attribute5                   := p_ler_attribute5;
  l_rec.ler_attribute6                   := p_ler_attribute6;
  l_rec.ler_attribute7                   := p_ler_attribute7;
  l_rec.ler_attribute8                   := p_ler_attribute8;
  l_rec.ler_attribute9                   := p_ler_attribute9;
  l_rec.ler_attribute10                  := p_ler_attribute10;
  l_rec.ler_attribute11                  := p_ler_attribute11;
  l_rec.ler_attribute12                  := p_ler_attribute12;
  l_rec.ler_attribute13                  := p_ler_attribute13;
  l_rec.ler_attribute14                  := p_ler_attribute14;
  l_rec.ler_attribute15                  := p_ler_attribute15;
  l_rec.ler_attribute16                  := p_ler_attribute16;
  l_rec.ler_attribute17                  := p_ler_attribute17;
  l_rec.ler_attribute18                  := p_ler_attribute18;
  l_rec.ler_attribute19                  := p_ler_attribute19;
  l_rec.ler_attribute20                  := p_ler_attribute20;
  l_rec.ler_attribute21                  := p_ler_attribute21;
  l_rec.ler_attribute22                  := p_ler_attribute22;
  l_rec.ler_attribute23                  := p_ler_attribute23;
  l_rec.ler_attribute24                  := p_ler_attribute24;
  l_rec.ler_attribute25                  := p_ler_attribute25;
  l_rec.ler_attribute26                  := p_ler_attribute26;
  l_rec.ler_attribute27                  := p_ler_attribute27;
  l_rec.ler_attribute28                  := p_ler_attribute28;
  l_rec.ler_attribute29                  := p_ler_attribute29;
  l_rec.ler_attribute30                  := p_ler_attribute30;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
-- ----------------------------------------------------------------------------
-- |--------------------------<add_language>----------------------------------|
-- ----------------------------------------------------------------------------
Procedure add_language
is
begin
  delete from ben_ler_f_tl t
  where not exists
    (select null
    from ben_ler_f_tl b
    where b.ler_id = t.ler_id
    and b.effective_start_date = t.effective_start_date
    );

  update ben_ler_f_tl t set (
      typ_cd,
      name
    ) = (select
      b.typ_cd,
      b.name
    from ben_ler_f_tl b
    where b.ler_id = t.ler_id
    and b.effective_start_date = t.effective_start_date
    and b.language = t.source_lang)
  where (
      t.ler_id,
      t.effective_start_date,
      t.language
  ) in (select
      subt.ler_id,
      subt.effective_start_date,
      subt.language
    from ben_ler_f_tl subb, ben_ler_f_tl subt
    where subb.ler_id = subt.ler_id
    and   subb.effective_start_date = subt.effective_start_date
    and   subb.language = subt.source_lang
    and (subb.name <> subt.name
         or subb.typ_cd <> subt.typ_cd
  ));

  insert into ben_ler_f_tl (
    ler_id,
    effective_start_date,
    effective_end_date,
    typ_cd,
--    lf_evt_oper_cd,
    name,
    language,
    source_lang,
    last_update_date,
    last_updated_by,
    last_update_login,
    created_by,
    creation_date
  ) select
    b.ler_id,
    b.effective_start_date,
    b.effective_end_date,
    b.typ_cd,
--    b.lf_evt_oper_cd,
    b.name,
    l.language_code,
    b.source_lang,
    b.last_update_date,
    b.last_updated_by,
    b.last_update_login,
    b.created_by,
    b.creation_date
  from ben_ler_f_tl b, fnd_languages l
  where l.installed_flag in ('I', 'B')
  and b.language = userenv('LANG')
  and not exists
    (select null
    from ben_ler_f_tl t
    where t.ler_id = b.ler_id
    and   t.effective_start_date = b.effective_start_date
    and   t.language = l.language_code);
end add_language;
--
end ben_ler_shd;

/
