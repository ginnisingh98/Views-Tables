--------------------------------------------------------
--  DDL for Package Body BEN_EPO_SHD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EPO_SHD" as
/* $Header: beeporhi.pkb 120.0 2005/05/28 02:42:27 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)    := '  ben_epo_shd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------< return_api_dml_status >-------------------------|
-- ----------------------------------------------------------------------------
Function return_api_dml_status Return Boolean Is
--
  l_proc     varchar2(72) := g_package||'return_api_dml_status';
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
  l_proc     varchar2(72) := g_package||'constraint_error';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_constraint_name = 'BEN_ELIG_PER_F_PK') Then
    fnd_message.set_name('PAY', 'HR_6153_ALL_PROCEDURE_FAIL');
    fnd_message.set_token('PROCEDURE', l_proc);
    fnd_message.set_token('STEP','5');
    fnd_message.raise_error;
  ElsIf (p_constraint_name = 'BEN_ELIG_PER_OPT_FK1') Then
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
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End constraint_error;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< api_updating >-----------------------------|
-- ----------------------------------------------------------------------------
Function api_updating
  (p_effective_date        in date,
   p_elig_per_opt_id        in number,
   p_object_version_number    in number
  ) Return Boolean Is
--
  --
  -- Cursor selects the 'current' row from the HR Schema
  --
  Cursor C_Sel1 is
    select
    elig_per_opt_id,
    elig_per_id,
    effective_start_date,
    effective_end_date,
    prtn_ovridn_flag,
    prtn_ovridn_thru_dt,
    no_mx_prtn_ovrid_thru_flag,
    elig_flag,
    prtn_strt_dt,
    prtn_end_dt,
    wait_perd_cmpltn_date,
    wait_perd_strt_dt,
    prtn_ovridn_rsn_cd,
    pct_fl_tm_val,
    opt_id,
    per_in_ler_id,
    rt_comp_ref_amt,
    rt_cmbn_age_n_los_val,
    rt_comp_ref_uom,
    rt_age_val,
    rt_los_val,
    rt_hrs_wkd_val,
    rt_hrs_wkd_bndry_perd_cd,
    rt_age_uom,
    rt_los_uom,
    rt_pct_fl_tm_val,
    rt_frz_los_flag,
    rt_frz_age_flag,
    rt_frz_cmp_lvl_flag,
    rt_frz_pct_fl_tm_flag,
    rt_frz_hrs_wkd_flag,
    rt_frz_comb_age_and_los_flag,
    comp_ref_amt,
    cmbn_age_n_los_val,
    comp_ref_uom,
    age_val,
    los_val,
    hrs_wkd_val,
    hrs_wkd_bndry_perd_cd,
    age_uom,
    los_uom,
    frz_los_flag,
    frz_age_flag,
    frz_cmp_lvl_flag,
    frz_pct_fl_tm_flag,
    frz_hrs_wkd_flag,
    frz_comb_age_and_los_flag,
    ovrid_svc_dt,
    inelg_rsn_cd,
    once_r_cntug_cd,
    oipl_ordr_num,
    business_group_id,
    epo_attribute_category,
    epo_attribute1,
    epo_attribute2,
    epo_attribute3,
    epo_attribute4,
    epo_attribute5,
    epo_attribute6,
    epo_attribute7,
    epo_attribute8,
    epo_attribute9,
    epo_attribute10,
    epo_attribute11,
    epo_attribute12,
    epo_attribute13,
    epo_attribute14,
    epo_attribute15,
    epo_attribute16,
    epo_attribute17,
    epo_attribute18,
    epo_attribute19,
    epo_attribute20,
    epo_attribute21,
    epo_attribute22,
    epo_attribute23,
    epo_attribute24,
    epo_attribute25,
    epo_attribute26,
    epo_attribute27,
    epo_attribute28,
    epo_attribute29,
    epo_attribute30,
    request_id,
    program_application_id,
    program_id,
    program_update_date,
    object_version_number
    from    ben_elig_per_opt_f
    where    elig_per_opt_id = p_elig_per_opt_id
    and        p_effective_date
    between    effective_start_date and effective_end_date;
--
  l_proc    varchar2(72)    := g_package||'api_updating';
  l_fct_ret    boolean;
--
Begin
/*
  hr_utility.set_location('Entering:'||l_proc, 5);
*/
  --
  If (p_effective_date is null or
      p_elig_per_opt_id is null or
      p_object_version_number is null) Then
    --
    -- One of the primary key arguments is null therefore we must
    -- set the returning function value to false
    --
    l_fct_ret := false;
  Else
    If (p_elig_per_opt_id = g_old_rec.elig_per_opt_id and
        p_object_version_number = g_old_rec.object_version_number) Then
/*
      hr_utility.set_location(l_proc, 10);
*/
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
/*
      hr_utility.set_location(l_proc, 15);
*/
      l_fct_ret := true;
    End If;
  End If;
/*
  hr_utility.set_location(' Leaving:'||l_proc, 20);
*/
  Return (l_fct_ret);
--
End api_updating;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< find_dt_del_modes >---------------------------|
-- ----------------------------------------------------------------------------
Procedure find_dt_del_modes
    (p_effective_date    in  date,
     p_base_key_value    in  number,
     p_zap            out nocopy boolean,
     p_delete        out nocopy boolean,
     p_future_change    out nocopy boolean,
     p_delete_next_change    out nocopy boolean) is
--
  l_proc         varchar2(72)     := g_package||'find_dt_del_modes';
--
  l_parent_key_value1    number;
  l_parent_key_value2    number;
  --
  Cursor C_Sel1 Is
    select  t.elig_per_id,
            t.opt_id
    from    ben_elig_per_opt_f t
    where   t.elig_per_opt_id = p_base_key_value
    and     p_effective_date
    between t.effective_start_date and t.effective_end_date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  Open  C_Sel1;
  Fetch C_Sel1 Into l_parent_key_value1,
            l_parent_key_value2;
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
    (p_effective_date    => p_effective_date,
     p_base_table_name    => 'ben_elig_per_opt_f',
     p_base_key_column    => 'elig_per_opt_id',
     p_base_key_value    => p_base_key_value,
     p_parent_table_name1    => 'ben_elig_per_f',
     p_parent_key_column1    => 'elig_per_id',
     p_parent_key_value1    => l_parent_key_value1,
     p_parent_table_name2    => 'ben_opt_f',
     p_parent_key_column2    => 'opt_id',
     p_parent_key_value2    => l_parent_key_value2,
     p_zap            => p_zap,
     p_delete        => p_delete,
     p_future_change    => p_future_change,
     p_delete_next_change    => p_delete_next_change);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End find_dt_del_modes;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< find_dt_upd_modes >---------------------------|
-- ----------------------------------------------------------------------------
Procedure find_dt_upd_modes
    (p_effective_date    in  date,
     p_base_key_value    in  number,
     p_correction        out nocopy boolean,
     p_update        out nocopy boolean,
     p_update_override    out nocopy boolean,
     p_update_change_insert    out nocopy boolean) is
--
  l_proc     varchar2(72) := g_package||'find_dt_upd_modes';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the corresponding datetrack api
  --
  dt_api.find_dt_upd_modes
    (p_effective_date    => p_effective_date,
     p_base_table_name    => 'ben_elig_per_opt_f',
     p_base_key_column    => 'elig_per_opt_id',
     p_base_key_value    => p_base_key_value,
     p_correction        => p_correction,
     p_update        => p_update,
     p_update_override    => p_update_override,
     p_update_change_insert    => p_update_change_insert);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End find_dt_upd_modes;
--
-- ----------------------------------------------------------------------------
-- |------------------------< upd_effective_end_date >------------------------|
-- ----------------------------------------------------------------------------
Procedure upd_effective_end_date
    (p_effective_date        in date,
     p_base_key_value        in number,
     p_new_effective_end_date    in date,
     p_validation_start_date    in date,
     p_validation_end_date        in date,
         p_object_version_number       out nocopy number) is
--
  l_proc           varchar2(72) := g_package||'upd_effective_end_date';
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
    (p_base_table_name    => 'ben_elig_per_opt_f',
     p_base_key_column    => 'elig_per_opt_id',
     p_base_key_value    => p_base_key_value);
  --
  hr_utility.set_location(l_proc, 10);
  g_api_dml := true;  -- Set the api dml status
  --
  -- Update the specified datetrack row setting the effective
  -- end date to the specified new effective end date.
  --
  update  ben_elig_per_opt_f t
  set      t.effective_end_date      = p_new_effective_end_date,
      t.object_version_number = l_object_version_number
  where      t.elig_per_opt_id      = p_base_key_value
  and      p_effective_date
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
    (p_effective_date     in  date,
     p_datetrack_mode     in  varchar2,
     p_elig_per_opt_id     in  number,
     p_object_version_number in  number,
     p_validation_start_date out nocopy date,
     p_validation_end_date     out nocopy date) is
--
  l_proc          varchar2(72) := g_package||'lck';
  l_validation_start_date date;
  l_validation_end_date      date;
  l_object_invalid       exception;
  l_argument          varchar2(30);
  --
  -- Cursor C_Sel1 selects the current locked row as of session date
  -- ensuring that the object version numbers match.
  --
  Cursor C_Sel1 is
    select
    elig_per_opt_id,
    elig_per_id,
    effective_start_date,
    effective_end_date,
    prtn_ovridn_flag,
    prtn_ovridn_thru_dt,
    no_mx_prtn_ovrid_thru_flag,
    elig_flag,
    prtn_strt_dt,
    prtn_end_dt,
    wait_perd_cmpltn_date,
    wait_perd_strt_dt,
    prtn_ovridn_rsn_cd,
    pct_fl_tm_val,
    opt_id,
    per_in_ler_id,
    rt_comp_ref_amt,
    rt_cmbn_age_n_los_val,
    rt_comp_ref_uom,
    rt_age_val,
    rt_los_val,
    rt_hrs_wkd_val,
    rt_hrs_wkd_bndry_perd_cd,
    rt_age_uom,
    rt_los_uom,
    rt_pct_fl_tm_val,
    rt_frz_los_flag,
    rt_frz_age_flag,
    rt_frz_cmp_lvl_flag,
    rt_frz_pct_fl_tm_flag,
    rt_frz_hrs_wkd_flag,
    rt_frz_comb_age_and_los_flag,
    comp_ref_amt,
    cmbn_age_n_los_val,
    comp_ref_uom,
    age_val,
    los_val,
    hrs_wkd_val,
    hrs_wkd_bndry_perd_cd,
    age_uom,
    los_uom,
    frz_los_flag,
    frz_age_flag,
    frz_cmp_lvl_flag,
    frz_pct_fl_tm_flag,
    frz_hrs_wkd_flag,
    frz_comb_age_and_los_flag,
    ovrid_svc_dt,
    inelg_rsn_cd,
    once_r_cntug_cd,
    oipl_ordr_num,
    business_group_id,
    epo_attribute_category,
    epo_attribute1,
    epo_attribute2,
    epo_attribute3,
    epo_attribute4,
    epo_attribute5,
    epo_attribute6,
    epo_attribute7,
    epo_attribute8,
    epo_attribute9,
    epo_attribute10,
    epo_attribute11,
    epo_attribute12,
    epo_attribute13,
    epo_attribute14,
    epo_attribute15,
    epo_attribute16,
    epo_attribute17,
    epo_attribute18,
    epo_attribute19,
    epo_attribute20,
    epo_attribute21,
    epo_attribute22,
    epo_attribute23,
    epo_attribute24,
    epo_attribute25,
    epo_attribute26,
    epo_attribute27,
    epo_attribute28,
    epo_attribute29,
    epo_attribute30,
    request_id,
    program_application_id,
    program_id,
    program_update_date,
    object_version_number
    from    ben_elig_per_opt_f
    where   elig_per_opt_id         = p_elig_per_opt_id
    and        p_effective_date
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
                             p_argument       => 'elig_per_opt_id',
                             p_argument_value => p_elig_per_opt_id);
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
    (p_effective_date       => p_effective_date,
     p_datetrack_mode       => p_datetrack_mode,
     p_base_table_name       => 'ben_elig_per_opt_f',
     p_base_key_column       => 'elig_per_opt_id',
     p_base_key_value        => p_elig_per_opt_id,
     p_parent_table_name1      => 'ben_elig_per_f',
     p_parent_key_column1      => 'elig_per_id',
     p_parent_key_value1       => g_old_rec.elig_per_id,
     p_parent_table_name2      => 'ben_opt_f',
     p_parent_key_column2      => 'opt_id',
     p_parent_key_value2       => g_old_rec.opt_id,
     p_enforce_foreign_locking => false,
     p_validation_start_date   => l_validation_start_date,
     p_validation_end_date       => l_validation_end_date);
    --
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
    fnd_message.set_token('TABLE_NAME', 'ben_elig_per_opt_f');
    fnd_message.raise_error;
  When l_object_invalid then
    --
    -- The object doesn't exist or is invalid
    --
    fnd_message.set_name('PAY', 'HR_7155_OBJECT_INVALID');
    fnd_message.set_token('TABLE_NAME', 'ben_elig_per_opt_f');
    fnd_message.raise_error;
End lck;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_args >-----------------------------|
-- ----------------------------------------------------------------------------
Function convert_args
    (
    p_elig_per_opt_id               in number,
    p_elig_per_id                   in number,
    p_effective_start_date          in date,
    p_effective_end_date            in date,
    p_prtn_ovridn_flag              in varchar2,
    p_prtn_ovridn_thru_dt           in date,
    p_no_mx_prtn_ovrid_thru_flag    in varchar2,
    p_elig_flag                     in varchar2,
    p_prtn_strt_dt                  in date,
    p_prtn_end_dt                   in date,
    p_wait_perd_cmpltn_date           in date,
    p_wait_perd_strt_dt             in date,
    p_prtn_ovridn_rsn_cd            in varchar2,
    p_pct_fl_tm_val                 in number,
    p_opt_id                        in number,
    p_per_in_ler_id                 in number,
    p_rt_comp_ref_amt               in number,
    p_rt_cmbn_age_n_los_val         in number,
    p_rt_comp_ref_uom               in varchar2,
    p_rt_age_val                    in number,
    p_rt_los_val                    in number,
    p_rt_hrs_wkd_val                in number,
    p_rt_hrs_wkd_bndry_perd_cd      in varchar2,
    p_rt_age_uom                    in varchar2,
    p_rt_los_uom                    in varchar2,
    p_rt_pct_fl_tm_val              in number,
    p_rt_frz_los_flag               in varchar2,
    p_rt_frz_age_flag               in varchar2,
    p_rt_frz_cmp_lvl_flag           in varchar2,
    p_rt_frz_pct_fl_tm_flag         in varchar2,
    p_rt_frz_hrs_wkd_flag           in varchar2,
    p_rt_frz_comb_age_and_los_flag  in varchar2,
    p_comp_ref_amt                  in number,
    p_cmbn_age_n_los_val            in number,
    p_comp_ref_uom                  in varchar2,
    p_age_val                       in number,
    p_los_val                       in number,
    p_hrs_wkd_val                   in number,
    p_hrs_wkd_bndry_perd_cd         in varchar2,
    p_age_uom                       in varchar2,
    p_los_uom                       in varchar2,
    p_frz_los_flag                  in varchar2,
    p_frz_age_flag                  in varchar2,
    p_frz_cmp_lvl_flag              in varchar2,
    p_frz_pct_fl_tm_flag            in varchar2,
    p_frz_hrs_wkd_flag              in varchar2,
    p_frz_comb_age_and_los_flag     in varchar2,
    p_ovrid_svc_dt                  in date,
    p_inelg_rsn_cd                  in varchar2,
    p_once_r_cntug_cd               in varchar2,
    p_oipl_ordr_num                 in number,
    p_business_group_id             in number,
    p_epo_attribute_category        in varchar2,
    p_epo_attribute1                in varchar2,
    p_epo_attribute2                in varchar2,
    p_epo_attribute3                in varchar2,
    p_epo_attribute4                in varchar2,
    p_epo_attribute5                in varchar2,
    p_epo_attribute6                in varchar2,
    p_epo_attribute7                in varchar2,
    p_epo_attribute8                in varchar2,
    p_epo_attribute9                in varchar2,
    p_epo_attribute10               in varchar2,
    p_epo_attribute11               in varchar2,
    p_epo_attribute12               in varchar2,
    p_epo_attribute13               in varchar2,
    p_epo_attribute14               in varchar2,
    p_epo_attribute15               in varchar2,
    p_epo_attribute16               in varchar2,
    p_epo_attribute17               in varchar2,
    p_epo_attribute18               in varchar2,
    p_epo_attribute19               in varchar2,
    p_epo_attribute20               in varchar2,
    p_epo_attribute21               in varchar2,
    p_epo_attribute22               in varchar2,
    p_epo_attribute23               in varchar2,
    p_epo_attribute24               in varchar2,
    p_epo_attribute25               in varchar2,
    p_epo_attribute26               in varchar2,
    p_epo_attribute27               in varchar2,
    p_epo_attribute28               in varchar2,
    p_epo_attribute29               in varchar2,
    p_epo_attribute30               in varchar2,
    p_request_id                    in number,
    p_program_application_id        in number,
    p_program_id                    in number,
    p_program_update_date           in date,
    p_object_version_number         in number
    )
    Return g_rec_type is
--
  l_rec      g_rec_type;
  l_proc  varchar2(72) := g_package||'convert_args';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Convert arguments into local l_rec structure.
  --
  l_rec.elig_per_opt_id                  := p_elig_per_opt_id;
  l_rec.elig_per_id                      := p_elig_per_id;
  l_rec.effective_start_date             := p_effective_start_date;
  l_rec.effective_end_date               := p_effective_end_date;
  l_rec.prtn_ovridn_flag                 := p_prtn_ovridn_flag;
  l_rec.prtn_ovridn_thru_dt              := p_prtn_ovridn_thru_dt;
  l_rec.no_mx_prtn_ovrid_thru_flag       := p_no_mx_prtn_ovrid_thru_flag;
  l_rec.elig_flag                        := p_elig_flag;
  l_rec.prtn_strt_dt                     := p_prtn_strt_dt;
  l_rec.prtn_end_dt                      := p_prtn_end_dt;
  l_rec.wait_perd_cmpltn_date              := p_wait_perd_cmpltn_date;
  l_rec.wait_perd_strt_dt                := p_wait_perd_strt_dt ;
  l_rec.prtn_ovridn_rsn_cd               := p_prtn_ovridn_rsn_cd;
  l_rec.pct_fl_tm_val                    := p_pct_fl_tm_val;
  l_rec.opt_id                           := p_opt_id;
  l_rec.per_in_ler_id                    := p_per_in_ler_id;
  l_rec.rt_comp_ref_amt                  := p_rt_comp_ref_amt;
  l_rec.rt_cmbn_age_n_los_val            := p_rt_cmbn_age_n_los_val;
  l_rec.rt_comp_ref_uom                  := p_rt_comp_ref_uom;
  l_rec.rt_age_val                       := p_rt_age_val;
  l_rec.rt_los_val                       := p_rt_los_val;
  l_rec.rt_hrs_wkd_val                   := p_rt_hrs_wkd_val;
  l_rec.rt_hrs_wkd_bndry_perd_cd         := p_rt_hrs_wkd_bndry_perd_cd;
  l_rec.rt_age_uom                       := p_rt_age_uom;
  l_rec.rt_los_uom                       := p_rt_los_uom;
  l_rec.rt_pct_fl_tm_val                 := p_rt_pct_fl_tm_val;
  l_rec.rt_frz_los_flag                  := p_rt_frz_los_flag;
  l_rec.rt_frz_age_flag                  := p_rt_frz_age_flag;
  l_rec.rt_frz_cmp_lvl_flag              := p_rt_frz_cmp_lvl_flag;
  l_rec.rt_frz_pct_fl_tm_flag            := p_rt_frz_pct_fl_tm_flag;
  l_rec.rt_frz_hrs_wkd_flag              := p_rt_frz_hrs_wkd_flag;
  l_rec.rt_frz_comb_age_and_los_flag     := p_rt_frz_comb_age_and_los_flag;
  l_rec.comp_ref_amt                     := p_comp_ref_amt;
  l_rec.cmbn_age_n_los_val               := p_cmbn_age_n_los_val;
  l_rec.comp_ref_uom                     := p_comp_ref_uom;
  l_rec.age_val                          := p_age_val;
  l_rec.los_val                          := p_los_val;
  l_rec.hrs_wkd_val                      := p_hrs_wkd_val;
  l_rec.hrs_wkd_bndry_perd_cd            := p_hrs_wkd_bndry_perd_cd;
  l_rec.age_uom                          := p_age_uom;
  l_rec.los_uom                          := p_los_uom;
  l_rec.frz_los_flag                     := p_frz_los_flag;
  l_rec.frz_age_flag                     := p_frz_age_flag;
  l_rec.frz_cmp_lvl_flag                 := p_frz_cmp_lvl_flag;
  l_rec.frz_pct_fl_tm_flag               := p_frz_pct_fl_tm_flag;
  l_rec.frz_hrs_wkd_flag                 := p_frz_hrs_wkd_flag;
  l_rec.frz_comb_age_and_los_flag        := p_frz_comb_age_and_los_flag;
  l_rec.ovrid_svc_dt                     := p_ovrid_svc_dt;
  l_rec.inelg_rsn_cd                     := p_inelg_rsn_cd;
  l_rec.once_r_cntug_cd                  := p_once_r_cntug_cd;
  l_rec.oipl_ordr_num                    := p_oipl_ordr_num;
  l_rec.business_group_id                := p_business_group_id;
  l_rec.epo_attribute_category           := p_epo_attribute_category;
  l_rec.epo_attribute1                   := p_epo_attribute1;
  l_rec.epo_attribute2                   := p_epo_attribute2;
  l_rec.epo_attribute3                   := p_epo_attribute3;
  l_rec.epo_attribute4                   := p_epo_attribute4;
  l_rec.epo_attribute5                   := p_epo_attribute5;
  l_rec.epo_attribute6                   := p_epo_attribute6;
  l_rec.epo_attribute7                   := p_epo_attribute7;
  l_rec.epo_attribute8                   := p_epo_attribute8;
  l_rec.epo_attribute9                   := p_epo_attribute9;
  l_rec.epo_attribute10                  := p_epo_attribute10;
  l_rec.epo_attribute11                  := p_epo_attribute11;
  l_rec.epo_attribute12                  := p_epo_attribute12;
  l_rec.epo_attribute13                  := p_epo_attribute13;
  l_rec.epo_attribute14                  := p_epo_attribute14;
  l_rec.epo_attribute15                  := p_epo_attribute15;
  l_rec.epo_attribute16                  := p_epo_attribute16;
  l_rec.epo_attribute17                  := p_epo_attribute17;
  l_rec.epo_attribute18                  := p_epo_attribute18;
  l_rec.epo_attribute19                  := p_epo_attribute19;
  l_rec.epo_attribute20                  := p_epo_attribute20;
  l_rec.epo_attribute21                  := p_epo_attribute21;
  l_rec.epo_attribute22                  := p_epo_attribute22;
  l_rec.epo_attribute23                  := p_epo_attribute23;
  l_rec.epo_attribute24                  := p_epo_attribute24;
  l_rec.epo_attribute25                  := p_epo_attribute25;
  l_rec.epo_attribute26                  := p_epo_attribute26;
  l_rec.epo_attribute27                  := p_epo_attribute27;
  l_rec.epo_attribute28                  := p_epo_attribute28;
  l_rec.epo_attribute29                  := p_epo_attribute29;
  l_rec.epo_attribute30                  := p_epo_attribute30;
  l_rec.request_id             := p_request_id;
  l_rec.program_application_id         := p_program_application_id;
  l_rec.program_id             := p_program_id;
  l_rec.program_update_date         := p_program_update_date;
  l_rec.object_version_number            := p_object_version_number;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(l_rec);
--
End convert_args;
--
end ben_epo_shd;

/
