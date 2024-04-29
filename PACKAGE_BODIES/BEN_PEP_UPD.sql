--------------------------------------------------------
--  DDL for Package Body BEN_PEP_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PEP_UPD" as
/* $Header: bepeprhi.pkb 120.0 2005/05/28 10:39:57 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)    := '  ben_pep_upd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_update_dml >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the execution of dml from the datetrack mode
--   of CORRECTION only. It is important to note that the object version
--   number is only increment by 1 because the datetrack correction is
--   soley for one datetracked row.
--   This procedure controls the actual dml update logic. The functions of this
--   procedure are as follows:
--   1) Get the next object_version_number.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To update the specified row in the schema using the primary key in
--      the predicates.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the
--   update_dml procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be updated in the schema.
--
-- Post Failure:
--   On the update dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check or unique integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   The update 'set' arguments list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_update_dml
    (p_rec              in out nocopy ben_pep_shd.g_rec_type,
     p_effective_date     in    date,
     p_datetrack_mode     in    varchar2,
     p_validation_start_date in    date,
     p_validation_end_date     in    date) is
--
  l_proc    varchar2(72) := g_package||'dt_update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If (p_datetrack_mode = 'CORRECTION') then
    hr_utility.set_location(l_proc, 10);
    --
    -- Because we are updating a row we must get the next object
    -- version number.
    --
    p_rec.object_version_number :=
      dt_api.get_object_version_number
      (p_base_table_name    => 'ben_elig_per_f',
       p_base_key_column    => 'elig_per_id',
       p_base_key_value    => p_rec.elig_per_id);
    --
    ben_pep_shd.g_api_dml := true;  -- Set the api dml status
    --
    -- Update the ben_elig_per_f Row
    --
    update  ben_elig_per_f
    set
    elig_per_id                     = p_rec.elig_per_id,
    business_group_id               = p_rec.business_group_id,
    pl_id                           = p_rec.pl_id,
    pgm_id                          = p_rec.pgm_id,
    plip_id                         = p_rec.plip_id,
    ptip_id                         = p_rec.ptip_id,
    ler_id                          = p_rec.ler_id,
    person_id                       = p_rec.person_id,
    per_in_ler_id                       = p_rec.per_in_ler_id,
    dpnt_othr_pl_cvrd_rl_flag       = p_rec.dpnt_othr_pl_cvrd_rl_flag,
    prtn_ovridn_thru_dt             = p_rec.prtn_ovridn_thru_dt,
    pl_key_ee_flag                  = p_rec.pl_key_ee_flag,
    pl_hghly_compd_flag             = p_rec.pl_hghly_compd_flag,
    elig_flag                       = p_rec.elig_flag,
    comp_ref_amt                    = p_rec.comp_ref_amt,
    cmbn_age_n_los_val              = p_rec.cmbn_age_n_los_val,
    comp_ref_uom                    = p_rec.comp_ref_uom,
    age_val                         = p_rec.age_val,
    los_val                         = p_rec.los_val,
    prtn_end_dt                     = p_rec.prtn_end_dt,
    prtn_strt_dt                    = p_rec.prtn_strt_dt,
    wait_perd_cmpltn_dt             = p_rec.wait_perd_cmpltn_dt,
    wait_perd_strt_dt               = p_rec.wait_perd_strt_dt,
    wv_ctfn_typ_cd                  = p_rec.wv_ctfn_typ_cd,
    hrs_wkd_val                     = p_rec.hrs_wkd_val,
    hrs_wkd_bndry_perd_cd           = p_rec.hrs_wkd_bndry_perd_cd,
    prtn_ovridn_flag                = p_rec.prtn_ovridn_flag,
    no_mx_prtn_ovrid_thru_flag      = p_rec.no_mx_prtn_ovrid_thru_flag,
    prtn_ovridn_rsn_cd              = p_rec.prtn_ovridn_rsn_cd,
    age_uom                         = p_rec.age_uom,
    los_uom                         = p_rec.los_uom,
    ovrid_svc_dt                    = p_rec.ovrid_svc_dt,
    inelg_rsn_cd                    = p_rec.inelg_rsn_cd,
    frz_los_flag                    = p_rec.frz_los_flag,
    frz_age_flag                    = p_rec.frz_age_flag,
    frz_cmp_lvl_flag                = p_rec.frz_cmp_lvl_flag,
    frz_pct_fl_tm_flag              = p_rec.frz_pct_fl_tm_flag,
    frz_hrs_wkd_flag                = p_rec.frz_hrs_wkd_flag,
    frz_comb_age_and_los_flag       = p_rec.frz_comb_age_and_los_flag,
    dstr_rstcn_flag                 = p_rec.dstr_rstcn_flag,
    pct_fl_tm_val                   = p_rec.pct_fl_tm_val,
    wv_prtn_rsn_cd                  = p_rec.wv_prtn_rsn_cd,
    pl_wvd_flag                     = p_rec.pl_wvd_flag,
    rt_comp_ref_amt                 = p_rec.rt_comp_ref_amt,
    rt_cmbn_age_n_los_val           = p_rec.rt_cmbn_age_n_los_val,
    rt_comp_ref_uom                 = p_rec.rt_comp_ref_uom,
    rt_age_val                      = p_rec.rt_age_val,
    rt_los_val                      = p_rec.rt_los_val,
    rt_hrs_wkd_val                  = p_rec.rt_hrs_wkd_val,
    rt_hrs_wkd_bndry_perd_cd        = p_rec.rt_hrs_wkd_bndry_perd_cd,
    rt_age_uom                      = p_rec.rt_age_uom,
    rt_los_uom                      = p_rec.rt_los_uom,
    rt_pct_fl_tm_val                = p_rec.rt_pct_fl_tm_val,
    rt_frz_los_flag                 = p_rec.rt_frz_los_flag,
    rt_frz_age_flag                 = p_rec.rt_frz_age_flag,
    rt_frz_cmp_lvl_flag             = p_rec.rt_frz_cmp_lvl_flag,
    rt_frz_pct_fl_tm_flag           = p_rec.rt_frz_pct_fl_tm_flag,
    rt_frz_hrs_wkd_flag             = p_rec.rt_frz_hrs_wkd_flag,
    rt_frz_comb_age_and_los_flag    = p_rec.rt_frz_comb_age_and_los_flag,
    once_r_cntug_cd                 = p_rec.once_r_cntug_cd,
    pl_ordr_num                     = p_rec.pl_ordr_num,
    plip_ordr_num                   = p_rec.plip_ordr_num,
    ptip_ordr_num                   = p_rec.ptip_ordr_num,
    pep_attribute_category          = p_rec.pep_attribute_category,
    pep_attribute1                  = p_rec.pep_attribute1,
    pep_attribute2                  = p_rec.pep_attribute2,
    pep_attribute3                  = p_rec.pep_attribute3,
    pep_attribute4                  = p_rec.pep_attribute4,
    pep_attribute5                  = p_rec.pep_attribute5,
    pep_attribute6                  = p_rec.pep_attribute6,
    pep_attribute7                  = p_rec.pep_attribute7,
    pep_attribute8                  = p_rec.pep_attribute8,
    pep_attribute9                  = p_rec.pep_attribute9,
    pep_attribute10                 = p_rec.pep_attribute10,
    pep_attribute11                 = p_rec.pep_attribute11,
    pep_attribute12                 = p_rec.pep_attribute12,
    pep_attribute13                 = p_rec.pep_attribute13,
    pep_attribute14                 = p_rec.pep_attribute14,
    pep_attribute15                 = p_rec.pep_attribute15,
    pep_attribute16                 = p_rec.pep_attribute16,
    pep_attribute17                 = p_rec.pep_attribute17,
    pep_attribute18                 = p_rec.pep_attribute18,
    pep_attribute19                 = p_rec.pep_attribute19,
    pep_attribute20                 = p_rec.pep_attribute20,
    pep_attribute21                 = p_rec.pep_attribute21,
    pep_attribute22                 = p_rec.pep_attribute22,
    pep_attribute23                 = p_rec.pep_attribute23,
    pep_attribute24                 = p_rec.pep_attribute24,
    pep_attribute25                 = p_rec.pep_attribute25,
    pep_attribute26                 = p_rec.pep_attribute26,
    pep_attribute27                 = p_rec.pep_attribute27,
    pep_attribute28                 = p_rec.pep_attribute28,
    pep_attribute29                 = p_rec.pep_attribute29,
    pep_attribute30                 = p_rec.pep_attribute30,
    request_id                      = p_rec.request_id,
    program_application_id          = p_rec.program_application_id,
    program_id                      = p_rec.program_id,
    program_update_date             = p_rec.program_update_date,
    object_version_number           = p_rec.object_version_number
    where   elig_per_id = p_rec.elig_per_id
    and     effective_start_date = p_validation_start_date
    and     effective_end_date   = p_validation_end_date;
    --
    ben_pep_shd.g_api_dml := false;   -- Unset the api dml status
    --
    -- Set the effective start and end dates
    --
    p_rec.effective_start_date := p_validation_start_date;
    p_rec.effective_end_date   := p_validation_end_date;
  End If;
--
hr_utility.set_location(' Leaving:'||l_proc, 15);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_pep_shd.g_api_dml := false;   -- Unset the api dml status
    ben_pep_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_pep_shd.g_api_dml := false;   -- Unset the api dml status
    ben_pep_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_pep_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End dt_update_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure calls the dt_update_dml control logic which handles
--   the actual datetrack dml.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the upd
--   procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing contines.
--
-- Post Failure:
--   No specific error handling is required within this procedure.
--
-- Developer Implementation Notes:
--   The update 'set' arguments list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_dml
    (p_rec              in out nocopy ben_pep_shd.g_rec_type,
     p_effective_date     in    date,
     p_datetrack_mode     in    varchar2,
     p_validation_start_date in    date,
     p_validation_end_date     in    date) is
--
  l_proc    varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  dt_update_dml(p_rec            => p_rec,
        p_effective_date    => p_effective_date,
        p_datetrack_mode    => p_datetrack_mode,
               p_validation_start_date    => p_validation_start_date,
        p_validation_end_date    => p_validation_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End update_dml;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< dt_pre_update >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The dt_pre_update procedure controls the execution
--   of dml for the datetrack modes of: UPDATE, UPDATE_OVERRIDE
--   and UPDATE_CHANGE_INSERT only. The execution required is as
--   follows:
--
--   1) Providing the datetrack update mode is not 'CORRECTION'
--      then set the effective end date of the current row (this
--      will be the validation_start_date - 1).
--   2) If the datetrack mode is 'UPDATE_OVERRIDE' then call the
--      corresponding delete_dml process to delete any future rows
--      where the effective_start_date is greater than or equal to
--    the validation_start_date.
--   3) Call the insert_dml process to insert the new updated row
--      details.
--
-- Prerequisites:
--   This is an internal procedure which is called from the
--   pre_update procedure.
--
-- In Parameters:
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   This is an internal procedure which is required by Datetrack. Don't
--   remove or modify.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure dt_pre_update
    (p_rec              in out nocopy    ben_pep_shd.g_rec_type,
     p_effective_date     in    date,
     p_datetrack_mode     in    varchar2,
     p_validation_start_date in    date,
     p_validation_end_date     in    date) is
--
  l_proc             varchar2(72) := g_package||'dt_pre_update';
  l_dummy_version_number number;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  If (p_datetrack_mode <> 'CORRECTION') then
    hr_utility.set_location(l_proc, 10);
    --
    -- Update the current effective end date
    --
    ben_pep_shd.upd_effective_end_date
     (p_effective_date           => p_effective_date,
      p_base_key_value           => p_rec.elig_per_id,
      p_new_effective_end_date => (p_validation_start_date - 1),
      p_validation_start_date  => p_validation_start_date,
      p_validation_end_date    => p_validation_end_date,
      p_object_version_number  => l_dummy_version_number);
    --
    If (p_datetrack_mode = 'UPDATE_OVERRIDE') then
      hr_utility.set_location(l_proc, 15);
      --
      -- As the datetrack mode is 'UPDATE_OVERRIDE' then we must
      -- delete any future rows
      --
      ben_pep_del.delete_dml
        (p_rec             => p_rec,
     p_effective_date     => p_effective_date,
     p_datetrack_mode     => p_datetrack_mode,
     p_validation_start_date => p_validation_start_date,
     p_validation_end_date   => p_validation_end_date);
    End If;
    hr_utility.set_location(l_proc, 20);
    --
    -- We must now insert the updated row
    --
    ben_pep_ins.insert_dml
      (p_rec            => p_rec,
       p_effective_date        => p_effective_date,
       p_datetrack_mode        => p_datetrack_mode,
       p_validation_start_date    => p_validation_start_date,
       p_validation_end_date    => p_validation_end_date);
  End If;
  hr_utility.set_location(' Leaving:'||l_proc, 20);
End dt_pre_update;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the update dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any pre-processing required before the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure. The call
--   to the dt_update_dml procedure should NOT be removed.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update
    (p_rec              in out nocopy    ben_pep_shd.g_rec_type,
     p_effective_date     in    date,
     p_datetrack_mode     in    varchar2,
     p_validation_start_date in    date,
     p_validation_end_date     in    date) is
--
  l_proc    varchar2(72) := g_package||'pre_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  dt_pre_update
    (p_rec              => p_rec,
     p_effective_date         => p_effective_date,
     p_datetrack_mode         => p_datetrack_mode,
     p_validation_start_date => p_validation_start_date,
     p_validation_end_date   => p_validation_end_date);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   update dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any post-processing required after the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_update
    (p_rec              in ben_pep_shd.g_rec_type,
     p_effective_date     in date,
     p_datetrack_mode     in varchar2,
     p_validation_start_date in date,
     p_validation_end_date     in date) is
--
  l_proc    varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

ben_pep_rku.after_update
  (
 p_elig_per_id                    => p_rec.elig_per_id,
 p_effective_start_date           => p_rec.effective_start_date,
 p_effective_end_date             => p_rec.effective_end_date,
 p_business_group_id              => p_rec.business_group_id,
 p_pl_id                          => p_rec.pl_id,
 p_pgm_id                         => p_rec.pgm_id,
 p_plip_id                        => p_rec.plip_id,
 p_ptip_id                        => p_rec.ptip_id,
 p_ler_id                         => p_rec.ler_id,
 p_person_id                      => p_rec.person_id,
 p_per_in_ler_id                      => p_rec.per_in_ler_id,
 p_dpnt_othr_pl_cvrd_rl_flag      => p_rec.dpnt_othr_pl_cvrd_rl_flag,
 p_prtn_ovridn_thru_dt            => p_rec.prtn_ovridn_thru_dt,
 p_pl_key_ee_flag                 => p_rec.pl_key_ee_flag,
 p_pl_hghly_compd_flag            => p_rec.pl_hghly_compd_flag,
 p_elig_flag                      => p_rec.elig_flag,
 p_comp_ref_amt                   => p_rec.comp_ref_amt,
 p_cmbn_age_n_los_val             => p_rec.cmbn_age_n_los_val,
 p_comp_ref_uom                   => p_rec.comp_ref_uom,
 p_age_val                        => p_rec.age_val,
 p_los_val                        => p_rec.los_val,
 p_prtn_end_dt                    => p_rec.prtn_end_dt,
 p_prtn_strt_dt                   => p_rec.prtn_strt_dt,
 p_wait_perd_cmpltn_dt            => p_rec.wait_perd_cmpltn_dt,
 p_wait_perd_strt_dt              => p_rec.wait_perd_strt_dt,
 p_wv_ctfn_typ_cd                 => p_rec.wv_ctfn_typ_cd,
 p_hrs_wkd_val                    => p_rec.hrs_wkd_val,
 p_hrs_wkd_bndry_perd_cd          => p_rec.hrs_wkd_bndry_perd_cd,
 p_prtn_ovridn_flag               => p_rec.prtn_ovridn_flag,
 p_no_mx_prtn_ovrid_thru_flag     => p_rec.no_mx_prtn_ovrid_thru_flag,
 p_prtn_ovridn_rsn_cd             => p_rec.prtn_ovridn_rsn_cd,
 p_age_uom                        => p_rec.age_uom,
 p_los_uom                        => p_rec.los_uom,
 p_ovrid_svc_dt                   => p_rec.ovrid_svc_dt,
 p_inelg_rsn_cd                   => p_rec.inelg_rsn_cd,
 p_frz_los_flag                   => p_rec.frz_los_flag,
 p_frz_age_flag                   => p_rec.frz_age_flag,
 p_frz_cmp_lvl_flag               => p_rec.frz_cmp_lvl_flag,
 p_frz_pct_fl_tm_flag             => p_rec.frz_pct_fl_tm_flag,
 p_frz_hrs_wkd_flag               => p_rec.frz_hrs_wkd_flag,
 p_frz_comb_age_and_los_flag      => p_rec.frz_comb_age_and_los_flag,
 p_dstr_rstcn_flag                => p_rec.dstr_rstcn_flag,
 p_pct_fl_tm_val                  => p_rec.pct_fl_tm_val,
 p_wv_prtn_rsn_cd                 => p_rec.wv_prtn_rsn_cd,
 p_pl_wvd_flag                    => p_rec.pl_wvd_flag,
 p_rt_comp_ref_amt                => p_rec.rt_comp_ref_amt,
 p_rt_cmbn_age_n_los_val          => p_rec.rt_cmbn_age_n_los_val,
 p_rt_comp_ref_uom                => p_rec.rt_comp_ref_uom,
 p_rt_age_val                     => p_rec.rt_age_val,
 p_rt_los_val                     => p_rec.rt_los_val,
 p_rt_hrs_wkd_val                 => p_rec.rt_hrs_wkd_val,
 p_rt_hrs_wkd_bndry_perd_cd       => p_rec.rt_hrs_wkd_bndry_perd_cd,
 p_rt_age_uom                     => p_rec.rt_age_uom,
 p_rt_los_uom                     => p_rec.rt_los_uom,
 p_rt_pct_fl_tm_val               => p_rec.rt_pct_fl_tm_val,
 p_rt_frz_los_flag                => p_rec.rt_frz_los_flag,
 p_rt_frz_age_flag                => p_rec.rt_frz_age_flag,
 p_rt_frz_cmp_lvl_flag            => p_rec.rt_frz_cmp_lvl_flag,
 p_rt_frz_pct_fl_tm_flag          => p_rec.rt_frz_pct_fl_tm_flag,
 p_rt_frz_hrs_wkd_flag            => p_rec.rt_frz_hrs_wkd_flag,
 p_rt_frz_comb_age_and_los_flag   => p_rec.rt_frz_comb_age_and_los_flag,
 p_once_r_cntug_cd                => p_rec.once_r_cntug_cd,
 p_pl_ordr_num                    => p_rec.pl_ordr_num,
 p_plip_ordr_num                  => p_rec.plip_ordr_num,
 p_ptip_ordr_num                  => p_rec.ptip_ordr_num,
 p_pep_attribute_category         => p_rec.pep_attribute_category,
 p_pep_attribute1                 => p_rec.pep_attribute1,
 p_pep_attribute2                 => p_rec.pep_attribute2,
 p_pep_attribute3                 => p_rec.pep_attribute3,
 p_pep_attribute4                 => p_rec.pep_attribute4,
 p_pep_attribute5                 => p_rec.pep_attribute5,
 p_pep_attribute6                 => p_rec.pep_attribute6,
 p_pep_attribute7                 => p_rec.pep_attribute7,
 p_pep_attribute8                 => p_rec.pep_attribute8,
 p_pep_attribute9                 => p_rec.pep_attribute9,
 p_pep_attribute10                => p_rec.pep_attribute10,
 p_pep_attribute11                => p_rec.pep_attribute11,
 p_pep_attribute12                => p_rec.pep_attribute12,
 p_pep_attribute13                => p_rec.pep_attribute13,
 p_pep_attribute14                => p_rec.pep_attribute14,
 p_pep_attribute15                => p_rec.pep_attribute15,
 p_pep_attribute16                => p_rec.pep_attribute16,
 p_pep_attribute17                => p_rec.pep_attribute17,
 p_pep_attribute18                => p_rec.pep_attribute18,
 p_pep_attribute19                => p_rec.pep_attribute19,
 p_pep_attribute20                => p_rec.pep_attribute20,
 p_pep_attribute21                => p_rec.pep_attribute21,
 p_pep_attribute22                => p_rec.pep_attribute22,
 p_pep_attribute23                => p_rec.pep_attribute23,
 p_pep_attribute24                => p_rec.pep_attribute24,
 p_pep_attribute25                => p_rec.pep_attribute25,
 p_pep_attribute26                => p_rec.pep_attribute26,
 p_pep_attribute27                => p_rec.pep_attribute27,
 p_pep_attribute28                => p_rec.pep_attribute28,
 p_pep_attribute29                => p_rec.pep_attribute29,
 p_pep_attribute30                => p_rec.pep_attribute30,
 p_request_id                     => p_rec.request_id,
 p_program_application_id         => p_rec.program_application_id,
 p_program_id                     => p_rec.program_id,
 p_program_update_date            => p_rec.program_update_date,
 p_object_version_number          => p_rec.object_version_number,
 p_effective_date                 => p_effective_date,
 p_datetrack_mode                 => p_datetrack_mode,
 p_validation_start_date          => p_validation_start_date,
 p_validation_end_date            => p_validation_end_date,
 p_effective_start_date_o         => ben_pep_shd.g_old_rec.effective_start_date,
 p_effective_end_date_o           => ben_pep_shd.g_old_rec.effective_end_date,
 p_business_group_id_o            => ben_pep_shd.g_old_rec.business_group_id,
 p_pl_id_o                        => ben_pep_shd.g_old_rec.pl_id,
 p_pgm_id_o                       => ben_pep_shd.g_old_rec.pgm_id,
 p_plip_id_o                      => ben_pep_shd.g_old_rec.plip_id,
 p_ptip_id_o                      => ben_pep_shd.g_old_rec.ptip_id,
 p_ler_id_o                       => ben_pep_shd.g_old_rec.ler_id,
 p_person_id_o                    => ben_pep_shd.g_old_rec.person_id,
 p_per_in_ler_id_o                    => ben_pep_shd.g_old_rec.per_in_ler_id,
 p_dpnt_othr_pl_cvrd_rl_flag_o    => ben_pep_shd.g_old_rec.dpnt_othr_pl_cvrd_rl_flag,
 p_prtn_ovridn_thru_dt_o          => ben_pep_shd.g_old_rec.prtn_ovridn_thru_dt,
 p_pl_key_ee_flag_o               => ben_pep_shd.g_old_rec. pl_key_ee_flag,
 p_pl_hghly_compd_flag_o          => ben_pep_shd.g_old_rec.pl_hghly_compd_flag,
 p_elig_flag_o                    => ben_pep_shd.g_old_rec.elig_flag,
 p_comp_ref_amt_o                 => ben_pep_shd.g_old_rec. comp_ref_amt,
 p_cmbn_age_n_los_val_o           => ben_pep_shd.g_old_rec. cmbn_age_n_los_val,
 p_comp_ref_uom_o                 => ben_pep_shd.g_old_rec. comp_ref_uom,
 p_age_val_o                      => ben_pep_shd.g_old_rec.age_val,
 p_los_val_o                      => ben_pep_shd.g_old_rec.los_val,
 p_prtn_end_dt_o                  => ben_pep_shd.g_old_rec.prtn_end_dt,
 p_prtn_strt_dt_o                 => ben_pep_shd.g_old_rec.prtn_strt_dt,
 p_wait_perd_cmpltn_dt_o          => ben_pep_shd.g_old_rec.wait_perd_cmpltn_dt,
 p_wait_perd_strt_dt_o            => ben_pep_shd.g_old_rec.wait_perd_strt_dt,
 p_wv_ctfn_typ_cd_o               => ben_pep_shd.g_old_rec. wv_ctfn_typ_cd,
 p_hrs_wkd_val_o                  => ben_pep_shd.g_old_rec.hrs_wkd_val,
 p_hrs_wkd_bndry_perd_cd_o        => ben_pep_shd.g_old_rec.hrs_wkd_bndry_perd_cd,
 p_prtn_ovridn_flag_o             => ben_pep_shd.g_old_rec. prtn_ovridn_flag,
 p_no_mx_prtn_ovrid_thru_flag_o   => ben_pep_shd.g_old_rec.no_mx_prtn_ovrid_thru_flag,
 p_prtn_ovridn_rsn_cd_o           => ben_pep_shd.g_old_rec.prtn_ovridn_rsn_cd,
 p_age_uom_o                      => ben_pep_shd.g_old_rec.age_uom,
 p_los_uom_o                      => ben_pep_shd.g_old_rec.los_uom,
 p_ovrid_svc_dt_o                 => ben_pep_shd.g_old_rec.ovrid_svc_dt,
 p_inelg_rsn_cd_o                 => ben_pep_shd.g_old_rec.inelg_rsn_cd,
 p_frz_los_flag_o                 => ben_pep_shd.g_old_rec.frz_los_flag,
 p_frz_age_flag_o                 => ben_pep_shd.g_old_rec.frz_age_flag,
 p_frz_cmp_lvl_flag_o             => ben_pep_shd.g_old_rec.frz_cmp_lvl_flag,
 p_frz_pct_fl_tm_flag_o           => ben_pep_shd.g_old_rec.frz_pct_fl_tm_flag,
 p_frz_hrs_wkd_flag_o             => ben_pep_shd.g_old_rec.frz_hrs_wkd_flag,
 p_frz_comb_age_and_los_flag_o    => ben_pep_shd.g_old_rec.frz_comb_age_and_los_flag,
 p_dstr_rstcn_flag_o              => ben_pep_shd.g_old_rec.dstr_rstcn_flag,
 p_pct_fl_tm_val_o                => ben_pep_shd.g_old_rec.pct_fl_tm_val,
 p_wv_prtn_rsn_cd_o               => ben_pep_shd.g_old_rec.wv_prtn_rsn_cd,
 p_pl_wvd_flag_o                  => ben_pep_shd.g_old_rec.pl_wvd_flag,
 p_rt_comp_ref_amt_o              => ben_pep_shd.g_old_rec.comp_ref_amt,
 p_rt_cmbn_age_n_los_val_o        => ben_pep_shd.g_old_rec.cmbn_age_n_los_val,
 p_rt_comp_ref_uom_o              => ben_pep_shd.g_old_rec.comp_ref_uom,
 p_rt_age_val_o                   => ben_pep_shd.g_old_rec.rt_age_val,
 p_rt_los_val_o                   => ben_pep_shd.g_old_rec.rt_los_val,
 p_rt_hrs_wkd_val_o               => ben_pep_shd.g_old_rec.rt_hrs_wkd_val,
 p_rt_hrs_wkd_bndry_perd_cd_o     => ben_pep_shd.g_old_rec.rt_hrs_wkd_bndry_perd_cd,
 p_rt_age_uom_o                   => ben_pep_shd.g_old_rec.rt_age_uom,
 p_rt_los_uom_o                   => ben_pep_shd.g_old_rec.rt_los_uom,
 p_rt_pct_fl_tm_val_o             => ben_pep_shd.g_old_rec.rt_pct_fl_tm_val,
 p_rt_frz_los_flag_o              => ben_pep_shd.g_old_rec.rt_frz_los_flag,
 p_rt_frz_age_flag_o              => ben_pep_shd.g_old_rec.rt_frz_age_flag,
 p_rt_frz_cmp_lvl_flag_o          => ben_pep_shd.g_old_rec.rt_frz_cmp_lvl_flag,
 p_rt_frz_pct_fl_tm_flag_o        => ben_pep_shd.g_old_rec.rt_frz_pct_fl_tm_flag,
 p_rt_frz_hrs_wkd_flag_o          => ben_pep_shd.g_old_rec.rt_frz_hrs_wkd_flag,
 p_rt_frz_comb_age_and_los_fl_o   => ben_pep_shd.g_old_rec.rt_frz_comb_age_and_los_flag,
 p_once_r_cntug_cd_o              => ben_pep_shd.g_old_rec.once_r_cntug_cd,
 p_pl_ordr_num_o                  => ben_pep_shd.g_old_rec.pl_ordr_num,
 p_plip_ordr_num_o                => ben_pep_shd.g_old_rec.plip_ordr_num,
 p_ptip_ordr_num_o                => ben_pep_shd.g_old_rec.ptip_ordr_num,
 p_pep_attribute_category_o       => ben_pep_shd.g_old_rec.pep_attribute_category,
 p_pep_attribute1_o               => ben_pep_shd.g_old_rec.pep_attribute1,
 p_pep_attribute2_o               => ben_pep_shd.g_old_rec.pep_attribute2,
 p_pep_attribute3_o               => ben_pep_shd.g_old_rec.pep_attribute3,
 p_pep_attribute4_o               => ben_pep_shd.g_old_rec.pep_attribute4,
 p_pep_attribute5_o               => ben_pep_shd.g_old_rec.pep_attribute5,
 p_pep_attribute6_o               => ben_pep_shd.g_old_rec.pep_attribute6,
 p_pep_attribute7_o               => ben_pep_shd.g_old_rec.pep_attribute7,
 p_pep_attribute8_o               => ben_pep_shd.g_old_rec.pep_attribute8,
 p_pep_attribute9_o               => ben_pep_shd.g_old_rec.pep_attribute9,
 p_pep_attribute10_o              => ben_pep_shd.g_old_rec.pep_attribute10,
 p_pep_attribute11_o              => ben_pep_shd.g_old_rec.pep_attribute11,
 p_pep_attribute12_o              => ben_pep_shd.g_old_rec.pep_attribute12,
 p_pep_attribute13_o              => ben_pep_shd.g_old_rec.pep_attribute13,
 p_pep_attribute14_o              => ben_pep_shd.g_old_rec.pep_attribute14,
 p_pep_attribute15_o              => ben_pep_shd.g_old_rec.pep_attribute15,
 p_pep_attribute16_o              => ben_pep_shd.g_old_rec.pep_attribute16,
 p_pep_attribute17_o              => ben_pep_shd.g_old_rec.pep_attribute17,
 p_pep_attribute18_o              => ben_pep_shd.g_old_rec.pep_attribute18,
 p_pep_attribute19_o              => ben_pep_shd.g_old_rec.pep_attribute19,
 p_pep_attribute20_o              => ben_pep_shd.g_old_rec.pep_attribute20,
 p_pep_attribute21_o              => ben_pep_shd.g_old_rec.pep_attribute21,
 p_pep_attribute22_o              => ben_pep_shd.g_old_rec.pep_attribute22,
 p_pep_attribute23_o              => ben_pep_shd.g_old_rec.pep_attribute23,
 p_pep_attribute24_o              => ben_pep_shd.g_old_rec.pep_attribute24,
 p_pep_attribute25_o              => ben_pep_shd.g_old_rec.pep_attribute25,
 p_pep_attribute26_o              => ben_pep_shd.g_old_rec.pep_attribute26,
 p_pep_attribute27_o              => ben_pep_shd.g_old_rec.pep_attribute27,
 p_pep_attribute28_o              => ben_pep_shd.g_old_rec.pep_attribute28,
 p_pep_attribute29_o              => ben_pep_shd.g_old_rec.pep_attribute29,
 p_pep_attribute30_o              => ben_pep_shd.g_old_rec.pep_attribute30,
 p_request_id_o                   => ben_pep_shd.g_old_rec.request_id,
 p_program_application_id_o       => ben_pep_shd.g_old_rec.program_application_id,
 p_program_id_o                   => ben_pep_shd.g_old_rec.program_id,
 p_program_update_date_o          => ben_pep_shd.g_old_rec.program_update_date,
 p_object_version_number_o        => ben_pep_shd.g_old_rec.object_version_number);

exception
  when hr_api.cannot_find_prog_unit then
    --
    hr_api.cannot_find_prog_unit_error
             (p_module_name => 'ben_elig_per_f',
              p_hook_type => 'AU');

End post_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_defs >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The Convert_Defs procedure has one very important function:
--   It must return the record structure for the row with all system defaulted
--   values converted into its corresponding parameter value for update. When
--   we attempt to update a row through the Upd process , certain
--   parameters can be defaulted which enables flexibility in the calling of
--   the upd process (e.g. only attributes which need to be updated need to be
--   specified). For the upd process to determine which attributes
--   have NOT been specified we need to check if the parameter has a reserved
--   system default value. Therefore, for all parameters which have a
--   corresponding reserved system default mechanism specified we need to
--   check if a system default is being used. If a system default is being
--   used then we convert the defaulted value into its corresponding attribute
--   value held in the g_old_rec data structure.
--
-- Prerequisites:
--   This private function can only be called from the upd process.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The record structure will be returned with all system defaulted parameter
--   values converted into its current row attribute value.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this procedure will be a PL/SQL value error due to conversion

--   of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure convert_defs(p_rec in out nocopy ben_pep_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'convert_defs';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    ben_pep_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.pl_id = hr_api.g_number) then
    p_rec.pl_id :=
    ben_pep_shd.g_old_rec.pl_id;
  End If;
  If (p_rec.pgm_id = hr_api.g_number) then
    p_rec.pgm_id :=
    ben_pep_shd.g_old_rec.pgm_id;
  End If;
  If (p_rec.plip_id = hr_api.g_number) then
    p_rec.plip_id :=
    ben_pep_shd.g_old_rec.plip_id;
  End If;
  If (p_rec.ptip_id = hr_api.g_number) then
    p_rec.ptip_id :=
    ben_pep_shd.g_old_rec.ptip_id;
  End If;
  If (p_rec.ler_id = hr_api.g_number) then
    p_rec.ler_id :=
    ben_pep_shd.g_old_rec.ler_id;
  End If;
  If (p_rec.person_id = hr_api.g_number) then
    p_rec.person_id :=
    ben_pep_shd.g_old_rec.person_id;
  End If;
  If (p_rec.per_in_ler_id = hr_api.g_number) then
    p_rec.per_in_ler_id :=
    ben_pep_shd.g_old_rec.per_in_ler_id;
  End If;
  If (p_rec.dpnt_othr_pl_cvrd_rl_flag = hr_api.g_varchar2) then
    p_rec.dpnt_othr_pl_cvrd_rl_flag :=
    ben_pep_shd.g_old_rec.dpnt_othr_pl_cvrd_rl_flag;
  End If;
  If (p_rec.prtn_ovridn_thru_dt = hr_api.g_date) then
    p_rec.prtn_ovridn_thru_dt :=
    ben_pep_shd.g_old_rec.prtn_ovridn_thru_dt;
  End If;
  If (p_rec.pl_key_ee_flag = hr_api.g_varchar2) then
    p_rec.pl_key_ee_flag :=
    ben_pep_shd.g_old_rec.pl_key_ee_flag;
  End If;
  If (p_rec.pl_hghly_compd_flag = hr_api.g_varchar2) then
    p_rec.pl_hghly_compd_flag :=
    ben_pep_shd.g_old_rec.pl_hghly_compd_flag;
  End If;
  If (p_rec.elig_flag = hr_api.g_varchar2) then
    p_rec.elig_flag :=
    ben_pep_shd.g_old_rec.elig_flag;
  End If;
  If (p_rec.comp_ref_amt = hr_api.g_number) then
    p_rec.comp_ref_amt :=
    ben_pep_shd.g_old_rec.comp_ref_amt;
  End If;
  If (p_rec.cmbn_age_n_los_val = hr_api.g_number) then
    p_rec.cmbn_age_n_los_val :=
    ben_pep_shd.g_old_rec.cmbn_age_n_los_val;
  End If;
  If (p_rec.comp_ref_uom = hr_api.g_varchar2) then
    p_rec.comp_ref_uom :=
    ben_pep_shd.g_old_rec.comp_ref_uom;
  End If;
  If (p_rec.age_val = hr_api.g_number) then
    p_rec.age_val :=
    ben_pep_shd.g_old_rec.age_val;
  End If;
  If (p_rec.los_val = hr_api.g_number) then
    p_rec.los_val :=
    ben_pep_shd.g_old_rec.los_val;
  End If;
  If (p_rec.prtn_end_dt = hr_api.g_date) then
    p_rec.prtn_end_dt :=
    ben_pep_shd.g_old_rec.prtn_end_dt;
  End If;
  If (p_rec.prtn_strt_dt = hr_api.g_date) then
    p_rec.prtn_strt_dt :=
    ben_pep_shd.g_old_rec.prtn_strt_dt;
  End If;
  If (p_rec.wait_perd_cmpltn_dt = hr_api.g_date) then
    p_rec.wait_perd_cmpltn_dt :=
    ben_pep_shd.g_old_rec.wait_perd_cmpltn_dt;
  End If;

  If (p_rec.wait_perd_strt_dt  = hr_api.g_date) then
    p_rec.wait_perd_strt_dt :=
    ben_pep_shd.g_old_rec.wait_perd_strt_dt;
  End If;
  If (p_rec.wv_ctfn_typ_cd = hr_api.g_varchar2) then
    p_rec.wv_ctfn_typ_cd :=
    ben_pep_shd.g_old_rec.wv_ctfn_typ_cd;
  End If;
  If (p_rec.hrs_wkd_val = hr_api.g_number) then
    p_rec.hrs_wkd_val :=
    ben_pep_shd.g_old_rec.hrs_wkd_val;
  End If;
  If (p_rec.hrs_wkd_bndry_perd_cd = hr_api.g_varchar2) then
    p_rec.hrs_wkd_bndry_perd_cd :=
    ben_pep_shd.g_old_rec.hrs_wkd_bndry_perd_cd;
  End If;
  If (p_rec.prtn_ovridn_flag = hr_api.g_varchar2) then
    p_rec.prtn_ovridn_flag :=
    ben_pep_shd.g_old_rec.prtn_ovridn_flag;
  End If;
  If (p_rec.no_mx_prtn_ovrid_thru_flag = hr_api.g_varchar2) then
    p_rec.no_mx_prtn_ovrid_thru_flag :=
    ben_pep_shd.g_old_rec.no_mx_prtn_ovrid_thru_flag;
  End If;
  If (p_rec.prtn_ovridn_rsn_cd = hr_api.g_varchar2) then
    p_rec.prtn_ovridn_rsn_cd :=
    ben_pep_shd.g_old_rec.prtn_ovridn_rsn_cd;
  End If;
  If (p_rec.age_uom = hr_api.g_varchar2) then
    p_rec.age_uom :=
    ben_pep_shd.g_old_rec.age_uom;
  End If;
  If (p_rec.los_uom = hr_api.g_varchar2) then
    p_rec.los_uom :=
    ben_pep_shd.g_old_rec.los_uom;
  End If;
  If (p_rec.ovrid_svc_dt = hr_api.g_date) then
    p_rec.ovrid_svc_dt :=
    ben_pep_shd.g_old_rec.ovrid_svc_dt;
  End If;
  If (p_rec.inelg_rsn_cd = hr_api.g_varchar2) then
    p_rec.inelg_rsn_cd :=
    ben_pep_shd.g_old_rec.inelg_rsn_cd;
  End If;
  If (p_rec.frz_los_flag = hr_api.g_varchar2) then
    p_rec.frz_los_flag :=
    ben_pep_shd.g_old_rec.frz_los_flag;
  End If;
  If (p_rec.frz_age_flag = hr_api.g_varchar2) then
    p_rec.frz_age_flag :=
    ben_pep_shd.g_old_rec.frz_age_flag;
  End If;
  If (p_rec.frz_cmp_lvl_flag = hr_api.g_varchar2) then
    p_rec.frz_cmp_lvl_flag :=
    ben_pep_shd.g_old_rec.frz_cmp_lvl_flag;
  End If;
  If (p_rec.frz_pct_fl_tm_flag = hr_api.g_varchar2) then
    p_rec.frz_pct_fl_tm_flag :=
    ben_pep_shd.g_old_rec.frz_pct_fl_tm_flag;
  End If;
  If (p_rec.frz_hrs_wkd_flag = hr_api.g_varchar2) then
    p_rec.frz_hrs_wkd_flag :=
    ben_pep_shd.g_old_rec.frz_hrs_wkd_flag;
  End If;
  If (p_rec.frz_comb_age_and_los_flag = hr_api.g_varchar2) then
    p_rec.frz_comb_age_and_los_flag :=
    ben_pep_shd.g_old_rec.frz_comb_age_and_los_flag;
  End If;
  If (p_rec.dstr_rstcn_flag = hr_api.g_varchar2) then
    p_rec.dstr_rstcn_flag :=
    ben_pep_shd.g_old_rec.dstr_rstcn_flag;
  End If;
  If (p_rec.pct_fl_tm_val = hr_api.g_number) then
    p_rec.pct_fl_tm_val :=
    ben_pep_shd.g_old_rec.pct_fl_tm_val;
  End If;
  If (p_rec.wv_prtn_rsn_cd = hr_api.g_varchar2) then
    p_rec.wv_prtn_rsn_cd :=
    ben_pep_shd.g_old_rec.wv_prtn_rsn_cd;
  End If;
  If (p_rec.pl_wvd_flag = hr_api.g_varchar2) then
    p_rec.pl_wvd_flag :=
    ben_pep_shd.g_old_rec.pl_wvd_flag;
  End If;
  If (p_rec.rt_comp_ref_amt = hr_api.g_number) then
    p_rec.rt_comp_ref_amt :=
    ben_pep_shd.g_old_rec.rt_comp_ref_amt;
  End If;
  If (p_rec.rt_cmbn_age_n_los_val = hr_api.g_number) then
    p_rec.rt_cmbn_age_n_los_val :=
    ben_pep_shd.g_old_rec.rt_cmbn_age_n_los_val;
  End If;
  If (p_rec.rt_comp_ref_uom = hr_api.g_varchar2) then
    p_rec.rt_comp_ref_uom :=
    ben_pep_shd.g_old_rec.rt_comp_ref_uom;
  End If;
  If (p_rec.rt_age_val = hr_api.g_number) then
    p_rec.rt_age_val :=
    ben_pep_shd.g_old_rec.rt_age_val;
  End If;
  If (p_rec.rt_los_val = hr_api.g_number) then
    p_rec.rt_los_val :=
    ben_pep_shd.g_old_rec.rt_los_val;
  End If;
  If (p_rec.rt_hrs_wkd_val = hr_api.g_number) then
    p_rec.rt_hrs_wkd_val :=
    ben_pep_shd.g_old_rec.rt_hrs_wkd_val;
  End If;
  If (p_rec.rt_hrs_wkd_bndry_perd_cd = hr_api.g_varchar2) then
    p_rec.rt_hrs_wkd_bndry_perd_cd :=
    ben_pep_shd.g_old_rec.rt_hrs_wkd_bndry_perd_cd;
  End If;
  If (p_rec.rt_age_uom = hr_api.g_varchar2) then
    p_rec.rt_age_uom :=
    ben_pep_shd.g_old_rec.rt_age_uom;
  End If;
  If (p_rec.rt_los_uom = hr_api.g_varchar2) then
    p_rec.rt_los_uom :=
    ben_pep_shd.g_old_rec.rt_los_uom;
  End If;
  If (p_rec.rt_pct_fl_tm_val = hr_api.g_number) then
    p_rec.rt_pct_fl_tm_val :=
    ben_pep_shd.g_old_rec.rt_pct_fl_tm_val;
  End If;
  If (p_rec.rt_frz_los_flag = hr_api.g_varchar2) then
    p_rec.rt_frz_los_flag :=
    ben_pep_shd.g_old_rec.rt_frz_los_flag;
  End If;
  If (p_rec.rt_frz_age_flag = hr_api.g_varchar2) then
    p_rec.rt_frz_age_flag :=
    ben_pep_shd.g_old_rec.rt_frz_age_flag;
  End If;
  If (p_rec.rt_frz_cmp_lvl_flag = hr_api.g_varchar2) then
    p_rec.rt_frz_cmp_lvl_flag :=
    ben_pep_shd.g_old_rec.rt_frz_cmp_lvl_flag;
  End If;
  If (p_rec.rt_frz_pct_fl_tm_flag = hr_api.g_varchar2) then
    p_rec.rt_frz_pct_fl_tm_flag :=
    ben_pep_shd.g_old_rec.rt_frz_pct_fl_tm_flag;
  End If;
  If (p_rec.rt_frz_hrs_wkd_flag = hr_api.g_varchar2) then
    p_rec.rt_frz_hrs_wkd_flag :=
    ben_pep_shd.g_old_rec.rt_frz_hrs_wkd_flag;
  End If;
  If (p_rec.rt_frz_comb_age_and_los_flag = hr_api.g_varchar2) then
    p_rec.rt_frz_comb_age_and_los_flag :=
    ben_pep_shd.g_old_rec.rt_frz_comb_age_and_los_flag;
  End If;
  If (p_rec.once_r_cntug_cd = hr_api.g_varchar2) then
    p_rec.once_r_cntug_cd :=
    ben_pep_shd.g_old_rec.once_r_cntug_cd;
  End If;
  If (p_rec.pl_ordr_num = hr_api.g_number) then
    p_rec.pl_ordr_num :=
    ben_pep_shd.g_old_rec.pl_ordr_num;
  End If;
  If (p_rec.plip_ordr_num = hr_api.g_number) then
    p_rec.plip_ordr_num :=
    ben_pep_shd.g_old_rec.plip_ordr_num;
  End If;
  If (p_rec.ptip_ordr_num = hr_api.g_number) then
    p_rec.ptip_ordr_num :=
    ben_pep_shd.g_old_rec.ptip_ordr_num;
  End If;
  If (p_rec.pep_attribute_category = hr_api.g_varchar2) then
    p_rec.pep_attribute_category :=
    ben_pep_shd.g_old_rec.pep_attribute_category;
  End If;
  If (p_rec.pep_attribute1 = hr_api.g_varchar2) then
    p_rec.pep_attribute1 :=
    ben_pep_shd.g_old_rec.pep_attribute1;
  End If;
  If (p_rec.pep_attribute2 = hr_api.g_varchar2) then
    p_rec.pep_attribute2 :=
    ben_pep_shd.g_old_rec.pep_attribute2;
  End If;
  If (p_rec.pep_attribute3 = hr_api.g_varchar2) then
    p_rec.pep_attribute3 :=
    ben_pep_shd.g_old_rec.pep_attribute3;
  End If;
  If (p_rec.pep_attribute4 = hr_api.g_varchar2) then
    p_rec.pep_attribute4 :=
    ben_pep_shd.g_old_rec.pep_attribute4;
  End If;
  If (p_rec.pep_attribute5 = hr_api.g_varchar2) then
    p_rec.pep_attribute5 :=
    ben_pep_shd.g_old_rec.pep_attribute5;
  End If;
  If (p_rec.pep_attribute6 = hr_api.g_varchar2) then
    p_rec.pep_attribute6 :=
    ben_pep_shd.g_old_rec.pep_attribute6;
  End If;
  If (p_rec.pep_attribute7 = hr_api.g_varchar2) then
    p_rec.pep_attribute7 :=
    ben_pep_shd.g_old_rec.pep_attribute7;
  End If;
  If (p_rec.pep_attribute8 = hr_api.g_varchar2) then
    p_rec.pep_attribute8 :=
    ben_pep_shd.g_old_rec.pep_attribute8;
  End If;
  If (p_rec.pep_attribute9 = hr_api.g_varchar2) then
    p_rec.pep_attribute9 :=
    ben_pep_shd.g_old_rec.pep_attribute9;
  End If;
  If (p_rec.pep_attribute10 = hr_api.g_varchar2) then
    p_rec.pep_attribute10 :=
    ben_pep_shd.g_old_rec.pep_attribute10;
  End If;
  If (p_rec.pep_attribute11 = hr_api.g_varchar2) then
    p_rec.pep_attribute11 :=
    ben_pep_shd.g_old_rec.pep_attribute11;
  End If;
  If (p_rec.pep_attribute12 = hr_api.g_varchar2) then
    p_rec.pep_attribute12 :=
    ben_pep_shd.g_old_rec.pep_attribute12;
  End If;
  If (p_rec.pep_attribute13 = hr_api.g_varchar2) then
    p_rec.pep_attribute13 :=
    ben_pep_shd.g_old_rec.pep_attribute13;
  End If;
  If (p_rec.pep_attribute14 = hr_api.g_varchar2) then
    p_rec.pep_attribute14 :=
    ben_pep_shd.g_old_rec.pep_attribute14;
  End If;
  If (p_rec.pep_attribute15 = hr_api.g_varchar2) then
    p_rec.pep_attribute15 :=
    ben_pep_shd.g_old_rec.pep_attribute15;
  End If;
  If (p_rec.pep_attribute16 = hr_api.g_varchar2) then
    p_rec.pep_attribute16 :=
    ben_pep_shd.g_old_rec.pep_attribute16;
  End If;
  If (p_rec.pep_attribute17 = hr_api.g_varchar2) then
    p_rec.pep_attribute17 :=
    ben_pep_shd.g_old_rec.pep_attribute17;
  End If;
  If (p_rec.pep_attribute18 = hr_api.g_varchar2) then
    p_rec.pep_attribute18 :=
    ben_pep_shd.g_old_rec.pep_attribute18;
  End If;
  If (p_rec.pep_attribute19 = hr_api.g_varchar2) then
    p_rec.pep_attribute19 :=
    ben_pep_shd.g_old_rec.pep_attribute19;
  End If;
  If (p_rec.pep_attribute20 = hr_api.g_varchar2) then
    p_rec.pep_attribute20 :=
    ben_pep_shd.g_old_rec.pep_attribute20;
  End If;
  If (p_rec.pep_attribute21 = hr_api.g_varchar2) then
    p_rec.pep_attribute21 :=
    ben_pep_shd.g_old_rec.pep_attribute21;
  End If;
  If (p_rec.pep_attribute22 = hr_api.g_varchar2) then
    p_rec.pep_attribute22 :=
    ben_pep_shd.g_old_rec.pep_attribute22;
  End If;
  If (p_rec.pep_attribute23 = hr_api.g_varchar2) then
    p_rec.pep_attribute23 :=
    ben_pep_shd.g_old_rec.pep_attribute23;
  End If;
  If (p_rec.pep_attribute24 = hr_api.g_varchar2) then
    p_rec.pep_attribute24 :=
    ben_pep_shd.g_old_rec.pep_attribute24;
  End If;
  If (p_rec.pep_attribute25 = hr_api.g_varchar2) then
    p_rec.pep_attribute25 :=
    ben_pep_shd.g_old_rec.pep_attribute25;
  End If;
  If (p_rec.pep_attribute26 = hr_api.g_varchar2) then
    p_rec.pep_attribute26 :=
    ben_pep_shd.g_old_rec.pep_attribute26;
  End If;
  If (p_rec.pep_attribute27 = hr_api.g_varchar2) then
    p_rec.pep_attribute27 :=
    ben_pep_shd.g_old_rec.pep_attribute27;
  End If;
  If (p_rec.pep_attribute28 = hr_api.g_varchar2) then
    p_rec.pep_attribute28 :=
    ben_pep_shd.g_old_rec.pep_attribute28;
  End If;
  If (p_rec.pep_attribute29 = hr_api.g_varchar2) then
    p_rec.pep_attribute29 :=
    ben_pep_shd.g_old_rec.pep_attribute29;
  End If;
  If (p_rec.pep_attribute30 = hr_api.g_varchar2) then
    p_rec.pep_attribute30 :=
    ben_pep_shd.g_old_rec.pep_attribute30;
  End If;
  If (p_rec.request_id = hr_api.g_number) then
    p_rec.request_id :=
    ben_pep_shd.g_old_rec.request_id;
  End If;
  If (p_rec.program_application_id = hr_api.g_number) then
    p_rec.program_application_id :=
    ben_pep_shd.g_old_rec.program_application_id;
  End If;
  If (p_rec.program_id = hr_api.g_number) then
    p_rec.program_id :=
    ben_pep_shd.g_old_rec.program_id;
  End If;
  If (p_rec.program_update_date = hr_api.g_date) then
    p_rec.program_update_date :=
    ben_pep_shd.g_old_rec.program_update_date;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_rec            in out nocopy     ben_pep_shd.g_rec_type,
  p_effective_date    in     date,
  p_datetrack_mode    in     varchar2
  ) is
--
  l_proc            varchar2(72) := g_package||'upd';
  l_validation_start_date    date;
  l_validation_end_date        date;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Ensure that the DateTrack update mode is valid
  --
  dt_api.validate_dt_upd_mode(p_datetrack_mode => p_datetrack_mode);
  --
  -- We must lock the row which we need to update.
  --
  ben_pep_shd.lck
    (p_effective_date     => p_effective_date,
           p_datetrack_mode     => p_datetrack_mode,
           p_elig_per_id     => p_rec.elig_per_id,
           p_object_version_number => p_rec.object_version_number,
           p_validation_start_date => l_validation_start_date,
           p_validation_end_date     => l_validation_end_date);
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  convert_defs(p_rec);
  ben_pep_bus.update_validate
    (p_rec             => p_rec,
     p_effective_date     => p_effective_date,
     p_datetrack_mode       => p_datetrack_mode,
     p_validation_start_date => l_validation_start_date,
     p_validation_end_date     => l_validation_end_date);
  --
  -- Call the supporting pre-update operation
  --
  pre_update
    (p_rec             => p_rec,
     p_effective_date     => p_effective_date,
     p_datetrack_mode     => p_datetrack_mode,
     p_validation_start_date => l_validation_start_date,
     p_validation_end_date     => l_validation_end_date);
  --
  -- Update the row.
  --
  update_dml
    (p_rec             => p_rec,
     p_effective_date     => p_effective_date,
     p_datetrack_mode     => p_datetrack_mode,
     p_validation_start_date => l_validation_start_date,
     p_validation_end_date     => l_validation_end_date);
  --
  -- Call the supporting post-update operation
  --
  post_update
    (p_rec             => p_rec,
     p_effective_date     => p_effective_date,
     p_datetrack_mode     => p_datetrack_mode,
     p_validation_start_date => l_validation_start_date,
     p_validation_end_date     => l_validation_end_date);
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_elig_per_id                  in number,
  p_effective_start_date         out nocopy date,
  p_effective_end_date           out nocopy date,
  p_business_group_id            in number           default hr_api.g_number,
  p_pl_id                        in number           default hr_api.g_number,
  p_pgm_id                       in number           default hr_api.g_number,
  p_plip_id                      in number           default hr_api.g_number,
  p_ptip_id                      in number           default hr_api.g_number,
  p_ler_id                       in number           default hr_api.g_number,
  p_person_id                    in number           default hr_api.g_number,
  p_per_in_ler_id                in number           default hr_api.g_number,
  p_dpnt_othr_pl_cvrd_rl_flag    in varchar2         default hr_api.g_varchar2,
  p_prtn_ovridn_thru_dt          in date             default hr_api.g_date,
  p_pl_key_ee_flag               in varchar2         default hr_api.g_varchar2,
  p_pl_hghly_compd_flag          in varchar2         default hr_api.g_varchar2,
  p_elig_flag                    in varchar2         default hr_api.g_varchar2,
  p_comp_ref_amt                 in number           default hr_api.g_number,
  p_cmbn_age_n_los_val           in number           default hr_api.g_number,
  p_comp_ref_uom                 in varchar2         default hr_api.g_varchar2,
  p_age_val                      in number           default hr_api.g_number,
  p_los_val                      in number           default hr_api.g_number,
  p_prtn_end_dt                  in date             default hr_api.g_date,
  p_prtn_strt_dt                 in date             default hr_api.g_date,
  p_wait_perd_cmpltn_dt          in date             default hr_api.g_date,
  p_wait_perd_strt_dt            in date             default hr_api.g_date,
  p_wv_ctfn_typ_cd               in varchar2         default hr_api.g_varchar2,
  p_hrs_wkd_val                  in number           default hr_api.g_number,
  p_hrs_wkd_bndry_perd_cd        in varchar2         default hr_api.g_varchar2,
  p_prtn_ovridn_flag             in varchar2         default hr_api.g_varchar2,
  p_no_mx_prtn_ovrid_thru_flag   in varchar2         default hr_api.g_varchar2,
  p_prtn_ovridn_rsn_cd           in varchar2         default hr_api.g_varchar2,
  p_age_uom                      in varchar2         default hr_api.g_varchar2,
  p_los_uom                      in varchar2         default hr_api.g_varchar2,
  p_ovrid_svc_dt                 in date             default hr_api.g_date,
  p_inelg_rsn_cd                 in varchar2         default hr_api.g_varchar2,
  p_frz_los_flag                 in varchar2         default hr_api.g_varchar2,
  p_frz_age_flag                 in varchar2         default hr_api.g_varchar2,
  p_frz_cmp_lvl_flag             in varchar2         default hr_api.g_varchar2,
  p_frz_pct_fl_tm_flag           in varchar2         default hr_api.g_varchar2,
  p_frz_hrs_wkd_flag             in varchar2         default hr_api.g_varchar2,
  p_frz_comb_age_and_los_flag    in varchar2         default hr_api.g_varchar2,
  p_dstr_rstcn_flag              in varchar2         default hr_api.g_varchar2,
  p_pct_fl_tm_val                in number           default hr_api.g_number,
  p_wv_prtn_rsn_cd               in varchar2         default hr_api.g_varchar2,
  p_pl_wvd_flag                  in varchar2         default hr_api.g_varchar2,
  p_rt_comp_ref_amt              in number           default hr_api.g_number,
  p_rt_cmbn_age_n_los_val        in number           default hr_api.g_number,
  p_rt_comp_ref_uom              in varchar2         default hr_api.g_varchar2,
  p_rt_age_val                   in number           default hr_api.g_number,
  p_rt_los_val                   in number           default hr_api.g_number,
  p_rt_hrs_wkd_val               in number           default hr_api.g_number,
  p_rt_hrs_wkd_bndry_perd_cd     in varchar2         default hr_api.g_varchar2,
  p_rt_age_uom                   in varchar2         default hr_api.g_varchar2,
  p_rt_los_uom                   in varchar2         default hr_api.g_varchar2,
  p_rt_pct_fl_tm_val             in number           default hr_api.g_number,
  p_rt_frz_los_flag              in varchar2         default hr_api.g_varchar2,
  p_rt_frz_age_flag              in varchar2         default hr_api.g_varchar2,
  p_rt_frz_cmp_lvl_flag          in varchar2         default hr_api.g_varchar2,
  p_rt_frz_pct_fl_tm_flag        in varchar2         default hr_api.g_varchar2,
  p_rt_frz_hrs_wkd_flag          in varchar2         default hr_api.g_varchar2,
  p_rt_frz_comb_age_and_los_flag in varchar2         default hr_api.g_varchar2,
  p_once_r_cntug_cd              in varchar2         default hr_api.g_varchar2,
  p_pl_ordr_num                  in number           default hr_api.g_number,
  p_plip_ordr_num                  in number           default hr_api.g_number,
  p_ptip_ordr_num                  in number           default hr_api.g_number,
  p_pep_attribute_category       in varchar2         default hr_api.g_varchar2,
  p_pep_attribute1               in varchar2         default hr_api.g_varchar2,
  p_pep_attribute2               in varchar2         default hr_api.g_varchar2,
  p_pep_attribute3               in varchar2         default hr_api.g_varchar2,
  p_pep_attribute4               in varchar2         default hr_api.g_varchar2,
  p_pep_attribute5               in varchar2         default hr_api.g_varchar2,
  p_pep_attribute6               in varchar2         default hr_api.g_varchar2,
  p_pep_attribute7               in varchar2         default hr_api.g_varchar2,
  p_pep_attribute8               in varchar2         default hr_api.g_varchar2,
  p_pep_attribute9               in varchar2         default hr_api.g_varchar2,
  p_pep_attribute10              in varchar2         default hr_api.g_varchar2,
  p_pep_attribute11              in varchar2         default hr_api.g_varchar2,
  p_pep_attribute12              in varchar2         default hr_api.g_varchar2,
  p_pep_attribute13              in varchar2         default hr_api.g_varchar2,
  p_pep_attribute14              in varchar2         default hr_api.g_varchar2,
  p_pep_attribute15              in varchar2         default hr_api.g_varchar2,
  p_pep_attribute16              in varchar2         default hr_api.g_varchar2,
  p_pep_attribute17              in varchar2         default hr_api.g_varchar2,
  p_pep_attribute18              in varchar2         default hr_api.g_varchar2,
  p_pep_attribute19              in varchar2         default hr_api.g_varchar2,
  p_pep_attribute20              in varchar2         default hr_api.g_varchar2,
  p_pep_attribute21              in varchar2         default hr_api.g_varchar2,
  p_pep_attribute22              in varchar2         default hr_api.g_varchar2,
  p_pep_attribute23              in varchar2         default hr_api.g_varchar2,
  p_pep_attribute24              in varchar2         default hr_api.g_varchar2,
  p_pep_attribute25              in varchar2         default hr_api.g_varchar2,
  p_pep_attribute26              in varchar2         default hr_api.g_varchar2,
  p_pep_attribute27              in varchar2         default hr_api.g_varchar2,
  p_pep_attribute28              in varchar2         default hr_api.g_varchar2,
  p_pep_attribute29              in varchar2         default hr_api.g_varchar2,
  p_pep_attribute30              in varchar2         default hr_api.g_varchar2,
  p_request_id                   in number           default hr_api.g_number,
  p_program_application_id       in number           default hr_api.g_number,
  p_program_id                   in number           default hr_api.g_number,
  p_program_update_date          in date             default hr_api.g_date,
  p_object_version_number        in out nocopy number,
  p_effective_date         in date,
  p_datetrack_mode         in varchar2
  ) is
--
  l_rec        ben_pep_shd.g_rec_type;
  l_proc    varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ben_pep_shd.convert_args
  (
  p_elig_per_id,
  null,
  null,
  p_business_group_id,
  p_pl_id,
  p_pgm_id,
  p_plip_id,
  p_ptip_id,
  p_ler_id,
  p_person_id,
  p_per_in_ler_id,
  p_dpnt_othr_pl_cvrd_rl_flag,
  p_prtn_ovridn_thru_dt,
  p_pl_key_ee_flag,
  p_pl_hghly_compd_flag,
  p_elig_flag,
  p_comp_ref_amt,
  p_cmbn_age_n_los_val,
  p_comp_ref_uom,
  p_age_val,
  p_los_val,
  p_prtn_end_dt,
  p_prtn_strt_dt,
  p_wait_perd_cmpltn_dt,
  p_wait_perd_strt_dt  ,
  p_wv_ctfn_typ_cd,
  p_hrs_wkd_val,
  p_hrs_wkd_bndry_perd_cd,
  p_prtn_ovridn_flag,
  p_no_mx_prtn_ovrid_thru_flag,
  p_prtn_ovridn_rsn_cd,
  p_age_uom,
  p_los_uom,
  p_ovrid_svc_dt,
  p_inelg_rsn_cd,
  p_frz_los_flag,
  p_frz_age_flag,
  p_frz_cmp_lvl_flag,
  p_frz_pct_fl_tm_flag,
  p_frz_hrs_wkd_flag,
  p_frz_comb_age_and_los_flag,
  p_dstr_rstcn_flag,
  p_pct_fl_tm_val,
  p_wv_prtn_rsn_cd,
  p_pl_wvd_flag,
  p_rt_comp_ref_amt,
  p_rt_cmbn_age_n_los_val,
  p_rt_comp_ref_uom,
  p_rt_age_val,
  p_rt_los_val,
  p_rt_hrs_wkd_val,
  p_rt_hrs_wkd_bndry_perd_cd,
  p_rt_age_uom,
  p_rt_los_uom,
  p_rt_pct_fl_tm_val,
  p_rt_frz_los_flag,
  p_rt_frz_age_flag,
  p_rt_frz_cmp_lvl_flag,
  p_rt_frz_pct_fl_tm_flag,
  p_rt_frz_hrs_wkd_flag,
  p_rt_frz_comb_age_and_los_flag,
  p_once_r_cntug_cd,
  p_pl_ordr_num,
  p_plip_ordr_num,
  p_ptip_ordr_num,
  p_pep_attribute_category,
  p_pep_attribute1,
  p_pep_attribute2,
  p_pep_attribute3,
  p_pep_attribute4,
  p_pep_attribute5,
  p_pep_attribute6,
  p_pep_attribute7,
  p_pep_attribute8,
  p_pep_attribute9,
  p_pep_attribute10,
  p_pep_attribute11,
  p_pep_attribute12,
  p_pep_attribute13,
  p_pep_attribute14,
  p_pep_attribute15,
  p_pep_attribute16,
  p_pep_attribute17,
  p_pep_attribute18,
  p_pep_attribute19,
  p_pep_attribute20,
  p_pep_attribute21,
  p_pep_attribute22,
  p_pep_attribute23,
  p_pep_attribute24,
  p_pep_attribute25,
  p_pep_attribute26,
  p_pep_attribute27,
  p_pep_attribute28,
  p_pep_attribute29,
  p_pep_attribute30,
  p_request_id,
  p_program_application_id,
  p_program_id,
  p_program_update_date,
  p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(l_rec, p_effective_date, p_datetrack_mode);
  p_object_version_number       := l_rec.object_version_number;
  p_effective_start_date        := l_rec.effective_start_date;
  p_effective_end_date          := l_rec.effective_end_date;
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end ben_pep_upd;

/
