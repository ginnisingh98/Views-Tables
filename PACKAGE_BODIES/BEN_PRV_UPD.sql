--------------------------------------------------------
--  DDL for Package Body BEN_PRV_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PRV_UPD" as
/* $Header: beprvrhi.pkb 120.0.12000000.3 2007/07/01 19:16:05 mmudigon noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_prv_upd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml update logic. The processing of
--   this procedure is:
--   1) Increment the object_version_number by 1 if the object_version_number
--      is defined as an attribute for this entity.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To update the specified row in the schema using the primary key in
--      the predicates.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the upd
--   procedure.
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
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   The update 'set' attribute list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_dml(p_rec in out nocopy ben_prv_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Increment the object version
  --
  p_rec.object_version_number := p_rec.object_version_number + 1;
  --
  ben_prv_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the ben_prtt_rt_val Row
  --
  update ben_prtt_rt_val
  set
  prtt_rt_val_id                    = p_rec.prtt_rt_val_id,
  rt_strt_dt                        = p_rec.rt_strt_dt,
  rt_end_dt                         = p_rec.rt_end_dt,
  rt_typ_cd                         = p_rec.rt_typ_cd,
  tx_typ_cd                         = p_rec.tx_typ_cd,
  -- ordr_num			    = p_rec.ordr_num,
  acty_typ_cd                       = p_rec.acty_typ_cd,
  mlt_cd                            = p_rec.mlt_cd,
  acty_ref_perd_cd                  = p_rec.acty_ref_perd_cd,
  rt_val                            = p_rec.rt_val,
  ann_rt_val                        = p_rec.ann_rt_val,
  cmcd_rt_val                       = p_rec.cmcd_rt_val,
  cmcd_ref_perd_cd                  = p_rec.cmcd_ref_perd_cd,
  bnft_rt_typ_cd                    = p_rec.bnft_rt_typ_cd,
  dsply_on_enrt_flag                = p_rec.dsply_on_enrt_flag,
  rt_ovridn_flag                    = p_rec.rt_ovridn_flag,
  rt_ovridn_thru_dt                 = p_rec.rt_ovridn_thru_dt,
  elctns_made_dt                    = p_rec.elctns_made_dt,
  prtt_rt_val_stat_cd               = p_rec.prtt_rt_val_stat_cd,
  prtt_enrt_rslt_id                 = p_rec.prtt_enrt_rslt_id,
  cvg_amt_calc_mthd_id              = p_rec.cvg_amt_calc_mthd_id,
  actl_prem_id                      = p_rec.actl_prem_id,
  comp_lvl_fctr_id                  = p_rec.comp_lvl_fctr_id,
  element_entry_value_id            = p_rec.element_entry_value_id,
  per_in_ler_id                     = p_rec.per_in_ler_id,
  ended_per_in_ler_id               = p_rec.ended_per_in_ler_id,
  acty_base_rt_id                   = p_rec.acty_base_rt_id,
  prtt_reimbmt_rqst_id              = p_rec.prtt_reimbmt_rqst_id,
  prtt_rmt_aprvd_fr_pymt_id         = p_rec.prtt_rmt_aprvd_fr_pymt_id,
  pp_in_yr_used_num                 = p_rec.pp_in_yr_used_num,
  business_group_id                 = p_rec.business_group_id,
  prv_attribute_category            = p_rec.prv_attribute_category,
  prv_attribute1                    = p_rec.prv_attribute1,
  prv_attribute2                    = p_rec.prv_attribute2,
  prv_attribute3                    = p_rec.prv_attribute3,
  prv_attribute4                    = p_rec.prv_attribute4,
  prv_attribute5                    = p_rec.prv_attribute5,
  prv_attribute6                    = p_rec.prv_attribute6,
  prv_attribute7                    = p_rec.prv_attribute7,
  prv_attribute8                    = p_rec.prv_attribute8,
  prv_attribute9                    = p_rec.prv_attribute9,
  prv_attribute10                   = p_rec.prv_attribute10,
  prv_attribute11                   = p_rec.prv_attribute11,
  prv_attribute12                   = p_rec.prv_attribute12,
  prv_attribute13                   = p_rec.prv_attribute13,
  prv_attribute14                   = p_rec.prv_attribute14,
  prv_attribute15                   = p_rec.prv_attribute15,
  prv_attribute16                   = p_rec.prv_attribute16,
  prv_attribute17                   = p_rec.prv_attribute17,
  prv_attribute18                   = p_rec.prv_attribute18,
  prv_attribute19                   = p_rec.prv_attribute19,
  prv_attribute20                   = p_rec.prv_attribute20,
  prv_attribute21                   = p_rec.prv_attribute21,
  prv_attribute22                   = p_rec.prv_attribute22,
  prv_attribute23                   = p_rec.prv_attribute23,
  prv_attribute24                   = p_rec.prv_attribute24,
  prv_attribute25                   = p_rec.prv_attribute25,
  prv_attribute26                   = p_rec.prv_attribute26,
  prv_attribute27                   = p_rec.prv_attribute27,
  prv_attribute28                   = p_rec.prv_attribute28,
  prv_attribute29                   = p_rec.prv_attribute29,
  prv_attribute30                   = p_rec.prv_attribute30,
  pk_id_table_name                  = p_rec.pk_id_table_name    ,
  pk_id                             = p_rec.pk_id,
  object_version_number             = p_rec.object_version_number
  where prtt_rt_val_id = p_rec.prtt_rt_val_id;
  --
  ben_prv_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_prv_shd.g_api_dml := false;   -- Unset the api dml status
    ben_prv_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ben_prv_shd.g_api_dml := false;   -- Unset the api dml status
    ben_prv_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_prv_shd.g_api_dml := false;   -- Unset the api dml status
    ben_prv_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_prv_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End update_dml;
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
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update(p_rec in out nocopy ben_prv_shd.g_rec_type ,p_effective_date in date ) is
--
  cursor c1 is
   select enrt_rt_id, object_version_number
   from ben_enrt_rt
   where prtt_rt_val_id = p_rec.prtt_rt_val_id;

  l_enrt_rt_id number := null;
  l_enrt_rt_ovn number := null;
  l_effective_date date := p_effective_date;
  l_proc  varchar2(72) := g_package||'pre_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  -- If the rate is ending before it's starting, void the rate and update
  -- the associated enrt_rt to no longer have an FK to it.

  if p_rec.rt_strt_dt > p_rec.rt_end_dt and
     p_rec.prtt_rt_val_stat_cd is null then
     p_rec.prtt_rt_val_stat_cd := 'VOIDD';
  end if;

  if p_rec.prtt_rt_val_stat_cd = 'VOIDD' then
     open c1;
     fetch c1 into l_enrt_rt_id, l_enrt_rt_ovn;
     close c1;
     if l_enrt_rt_id is not null then
        ben_enrollment_rate_api.update_enrollment_rate(
        p_enrt_rt_id                    => l_enrt_rt_id,
        p_prtt_rt_val_id                => null,
        p_object_version_number         => l_enrt_rt_ovn,
        p_effective_date                => l_effective_date);
    end if;
  end if;
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
Procedure post_update(p_rec in ben_prv_shd.g_rec_type,p_effective_date in date ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
  -- p_effective_date date := sysdate;
  l_old_rec   ben_prv_ler.g_prv_ler_rec ;
  l_new_rec   ben_prv_ler.g_prv_ler_rec ;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  -- Start of API User Hook for post_update.
  --
  begin
     l_old_rec.prtt_enrt_rslt_id   := ben_prv_shd.g_old_rec.prtt_enrt_rslt_id;
     l_old_rec.business_group_id   := ben_prv_shd.g_old_rec.business_group_id;
     l_old_rec.rt_strt_dt          := ben_prv_shd.g_old_rec.rt_strt_dt;
     l_old_rec.rt_end_dt           := ben_prv_shd.g_old_rec.rt_end_dt;
     l_old_rec.cmcd_rt_val         := ben_prv_shd.g_old_rec.cmcd_rt_val;
     l_old_rec.ann_rt_val          := ben_prv_shd.g_old_rec.ann_rt_val;
     l_old_rec.rt_val              := ben_prv_shd.g_old_rec.rt_val;
     l_old_rec.rt_ovridn_flag      := ben_prv_shd.g_old_rec.rt_ovridn_flag;
     l_old_rec.elctns_made_dt      := ben_prv_shd.g_old_rec.elctns_made_dt;
     l_old_rec.rt_ovridn_thru_dt   := ben_prv_shd.g_old_rec.rt_ovridn_thru_dt;
     l_old_rec.tx_typ_cd           := ben_prv_shd.g_old_rec.tx_typ_cd;
     l_old_rec.acty_typ_cd         := ben_prv_shd.g_old_rec.acty_typ_cd;
     l_old_rec.per_in_ler_id       := ben_prv_shd.g_old_rec.per_in_ler_id;
     l_old_rec.acty_base_rt_id     := ben_prv_shd.g_old_rec.acty_base_rt_id;
     l_old_rec.prtt_rt_val_stat_cd := ben_prv_shd.g_old_rec.prtt_rt_val_stat_cd;
     l_old_rec.prtt_rt_val_id      := ben_prv_shd.g_old_rec.prtt_rt_val_id;

     l_new_rec.prtt_enrt_rslt_id := p_rec.prtt_enrt_rslt_id;
     l_new_rec.business_group_id := p_rec.business_group_id;
     l_new_rec.rt_strt_dt        := p_rec.rt_strt_dt;
     l_new_rec.rt_end_dt         := p_rec.rt_end_dt;
     l_new_rec.cmcd_rt_val       := p_rec.cmcd_rt_val;
     l_new_rec.ann_rt_val        := p_rec.ann_rt_val;
     l_new_rec.rt_val            := p_rec.rt_val;
     l_new_rec.rt_ovridn_flag    := p_rec.rt_ovridn_flag;
     l_new_rec.elctns_made_dt    := p_rec.elctns_made_dt;
     l_new_rec.rt_ovridn_thru_dt := p_rec.rt_ovridn_thru_dt;
     l_new_rec.tx_typ_cd         := p_rec.tx_typ_cd;
     l_new_rec.acty_typ_cd       := p_rec.acty_typ_cd;
     l_new_rec.per_in_ler_id     := p_rec.per_in_ler_id;
     l_new_rec.acty_base_rt_id   := p_rec.acty_base_rt_id;
     l_new_rec.prtt_rt_val_stat_cd := p_rec.prtt_rt_val_stat_cd;
     l_new_rec.prtt_rt_val_id      := p_rec.prtt_rt_val_id;
     --
    ben_prv_rku.after_update
      (
  p_prtt_rt_val_id                =>p_rec.prtt_rt_val_id
 ,p_rt_strt_dt                    =>p_rec.rt_strt_dt
 ,p_rt_end_dt                     =>p_rec.rt_end_dt
 ,p_rt_typ_cd                     =>p_rec.rt_typ_cd
 ,p_tx_typ_cd                     =>p_rec.tx_typ_cd
 ,p_ordr_num			  => p_rec.ordr_num
 ,p_acty_typ_cd                   =>p_rec.acty_typ_cd
 ,p_mlt_cd                        =>p_rec.mlt_cd
 ,p_acty_ref_perd_cd              =>p_rec.acty_ref_perd_cd
 ,p_rt_val                        =>p_rec.rt_val
 ,p_ann_rt_val                    =>p_rec.ann_rt_val
 ,p_cmcd_rt_val                   =>p_rec.cmcd_rt_val
 ,p_cmcd_ref_perd_cd              =>p_rec.cmcd_ref_perd_cd
 ,p_bnft_rt_typ_cd                =>p_rec.bnft_rt_typ_cd
 ,p_dsply_on_enrt_flag            =>p_rec.dsply_on_enrt_flag
 ,p_rt_ovridn_flag                =>p_rec.rt_ovridn_flag
 ,p_rt_ovridn_thru_dt             =>p_rec.rt_ovridn_thru_dt
 ,p_elctns_made_dt                =>p_rec.elctns_made_dt
 ,p_prtt_rt_val_stat_cd           =>p_rec.prtt_rt_val_stat_cd
 ,p_prtt_enrt_rslt_id             =>p_rec.prtt_enrt_rslt_id
 ,p_cvg_amt_calc_mthd_id          =>p_rec.cvg_amt_calc_mthd_id
 ,p_actl_prem_id                  =>p_rec.actl_prem_id
 ,p_comp_lvl_fctr_id              =>p_rec.comp_lvl_fctr_id
 ,p_element_entry_value_id        =>p_rec.element_entry_value_id
 ,p_per_in_ler_id                 =>p_rec.per_in_ler_id
 ,p_ended_per_in_ler_id           =>p_rec.ended_per_in_ler_id
 ,p_acty_base_rt_id               =>p_rec.acty_base_rt_id
 ,p_prtt_reimbmt_rqst_id          =>p_rec.prtt_reimbmt_rqst_id
 ,p_prtt_rmt_aprvd_fr_pymt_id     =>p_rec.prtt_rmt_aprvd_fr_pymt_id
 ,p_pp_in_yr_used_num             =>p_rec.pp_in_yr_used_num
 ,p_business_group_id             =>p_rec.business_group_id
 ,p_prv_attribute_category        =>p_rec.prv_attribute_category
 ,p_prv_attribute1                =>p_rec.prv_attribute1
 ,p_prv_attribute2                =>p_rec.prv_attribute2
 ,p_prv_attribute3                =>p_rec.prv_attribute3
 ,p_prv_attribute4                =>p_rec.prv_attribute4
 ,p_prv_attribute5                =>p_rec.prv_attribute5
 ,p_prv_attribute6                =>p_rec.prv_attribute6
 ,p_prv_attribute7                =>p_rec.prv_attribute7
 ,p_prv_attribute8                =>p_rec.prv_attribute8
 ,p_prv_attribute9                =>p_rec.prv_attribute9
 ,p_prv_attribute10               =>p_rec.prv_attribute10
 ,p_prv_attribute11               =>p_rec.prv_attribute11
 ,p_prv_attribute12               =>p_rec.prv_attribute12
 ,p_prv_attribute13               =>p_rec.prv_attribute13
 ,p_prv_attribute14               =>p_rec.prv_attribute14
 ,p_prv_attribute15               =>p_rec.prv_attribute15
 ,p_prv_attribute16               =>p_rec.prv_attribute16
 ,p_prv_attribute17               =>p_rec.prv_attribute17
 ,p_prv_attribute18               =>p_rec.prv_attribute18
 ,p_prv_attribute19               =>p_rec.prv_attribute19
 ,p_prv_attribute20               =>p_rec.prv_attribute20
 ,p_prv_attribute21               =>p_rec.prv_attribute21
 ,p_prv_attribute22               =>p_rec.prv_attribute22
 ,p_prv_attribute23               =>p_rec.prv_attribute23
 ,p_prv_attribute24               =>p_rec.prv_attribute24
 ,p_prv_attribute25               =>p_rec.prv_attribute25
 ,p_prv_attribute26               =>p_rec.prv_attribute26
 ,p_prv_attribute27               =>p_rec.prv_attribute27
 ,p_prv_attribute28               =>p_rec.prv_attribute28
 ,p_prv_attribute29               =>p_rec.prv_attribute29
 ,p_prv_attribute30               =>p_rec.prv_attribute30
 ,p_pk_id_table_name              =>p_rec.pk_id_table_name
 ,p_pk_id                         =>p_rec.pk_id
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_effective_date                =>p_effective_date
 ,p_rt_strt_dt_o                  =>ben_prv_shd.g_old_rec.rt_strt_dt
 ,p_rt_end_dt_o                   =>ben_prv_shd.g_old_rec.rt_end_dt
 ,p_rt_typ_cd_o                   =>ben_prv_shd.g_old_rec.rt_typ_cd
 ,p_tx_typ_cd_o                   =>ben_prv_shd.g_old_rec.tx_typ_cd
 ,p_ordr_num_o	 	          =>ben_abr_shd.g_old_rec.ordr_num
 ,p_acty_typ_cd_o                 =>ben_prv_shd.g_old_rec.acty_typ_cd
 ,p_mlt_cd_o                      =>ben_prv_shd.g_old_rec.mlt_cd
 ,p_acty_ref_perd_cd_o            =>ben_prv_shd.g_old_rec.acty_ref_perd_cd
 ,p_rt_val_o                      =>ben_prv_shd.g_old_rec.rt_val
 ,p_ann_rt_val_o                  =>ben_prv_shd.g_old_rec.ann_rt_val
 ,p_cmcd_rt_val_o                 =>ben_prv_shd.g_old_rec.cmcd_rt_val
 ,p_cmcd_ref_perd_cd_o            =>ben_prv_shd.g_old_rec.cmcd_ref_perd_cd
 ,p_bnft_rt_typ_cd_o              =>ben_prv_shd.g_old_rec.bnft_rt_typ_cd
 ,p_dsply_on_enrt_flag_o          =>ben_prv_shd.g_old_rec.dsply_on_enrt_flag
 ,p_rt_ovridn_flag_o              =>ben_prv_shd.g_old_rec.rt_ovridn_flag
 ,p_rt_ovridn_thru_dt_o           =>ben_prv_shd.g_old_rec.rt_ovridn_thru_dt
 ,p_elctns_made_dt_o              =>ben_prv_shd.g_old_rec.elctns_made_dt
 ,p_prtt_rt_val_stat_cd_o         =>ben_prv_shd.g_old_rec.prtt_rt_val_stat_cd
 ,p_prtt_enrt_rslt_id_o           =>ben_prv_shd.g_old_rec.prtt_enrt_rslt_id
 ,p_cvg_amt_calc_mthd_id_o        =>ben_prv_shd.g_old_rec.cvg_amt_calc_mthd_id
 ,p_actl_prem_id_o                =>ben_prv_shd.g_old_rec.actl_prem_id
 ,p_comp_lvl_fctr_id_o            =>ben_prv_shd.g_old_rec.comp_lvl_fctr_id
 ,p_element_entry_value_id_o      =>ben_prv_shd.g_old_rec.element_entry_value_id
 ,p_per_in_ler_id_o               =>ben_prv_shd.g_old_rec.per_in_ler_id
 ,p_ended_per_in_ler_id_o         =>ben_prv_shd.g_old_rec.ended_per_in_ler_id
 ,p_acty_base_rt_id_o             =>ben_prv_shd.g_old_rec.acty_base_rt_id
 ,p_prtt_reimbmt_rqst_id_o        =>ben_prv_shd.g_old_rec.prtt_reimbmt_rqst_id
 ,p_prtt_rmt_aprvd_fr_pymt_id_o   =>ben_prv_shd.g_old_rec.prtt_rmt_aprvd_fr_pymt_id
 ,p_pp_in_yr_used_num_o           =>ben_prv_shd.g_old_rec.pp_in_yr_used_num
 ,p_business_group_id_o           =>ben_prv_shd.g_old_rec.business_group_id
 ,p_prv_attribute_category_o      =>ben_prv_shd.g_old_rec.prv_attribute_category
 ,p_prv_attribute1_o              =>ben_prv_shd.g_old_rec.prv_attribute1
 ,p_prv_attribute2_o              =>ben_prv_shd.g_old_rec.prv_attribute2
 ,p_prv_attribute3_o              =>ben_prv_shd.g_old_rec.prv_attribute3
 ,p_prv_attribute4_o              =>ben_prv_shd.g_old_rec.prv_attribute4
 ,p_prv_attribute5_o              =>ben_prv_shd.g_old_rec.prv_attribute5
 ,p_prv_attribute6_o              =>ben_prv_shd.g_old_rec.prv_attribute6
 ,p_prv_attribute7_o              =>ben_prv_shd.g_old_rec.prv_attribute7
 ,p_prv_attribute8_o              =>ben_prv_shd.g_old_rec.prv_attribute8
 ,p_prv_attribute9_o              =>ben_prv_shd.g_old_rec.prv_attribute9
 ,p_prv_attribute10_o             =>ben_prv_shd.g_old_rec.prv_attribute10
 ,p_prv_attribute11_o             =>ben_prv_shd.g_old_rec.prv_attribute11
 ,p_prv_attribute12_o             =>ben_prv_shd.g_old_rec.prv_attribute12
 ,p_prv_attribute13_o             =>ben_prv_shd.g_old_rec.prv_attribute13
 ,p_prv_attribute14_o             =>ben_prv_shd.g_old_rec.prv_attribute14
 ,p_prv_attribute15_o             =>ben_prv_shd.g_old_rec.prv_attribute15
 ,p_prv_attribute16_o             =>ben_prv_shd.g_old_rec.prv_attribute16
 ,p_prv_attribute17_o             =>ben_prv_shd.g_old_rec.prv_attribute17
 ,p_prv_attribute18_o             =>ben_prv_shd.g_old_rec.prv_attribute18
 ,p_prv_attribute19_o             =>ben_prv_shd.g_old_rec.prv_attribute19
 ,p_prv_attribute20_o             =>ben_prv_shd.g_old_rec.prv_attribute20
 ,p_prv_attribute21_o             =>ben_prv_shd.g_old_rec.prv_attribute21
 ,p_prv_attribute22_o             =>ben_prv_shd.g_old_rec.prv_attribute22
 ,p_prv_attribute23_o             =>ben_prv_shd.g_old_rec.prv_attribute23
 ,p_prv_attribute24_o             =>ben_prv_shd.g_old_rec.prv_attribute24
 ,p_prv_attribute25_o             =>ben_prv_shd.g_old_rec.prv_attribute25
 ,p_prv_attribute26_o             =>ben_prv_shd.g_old_rec.prv_attribute26
 ,p_prv_attribute27_o             =>ben_prv_shd.g_old_rec.prv_attribute27
 ,p_prv_attribute28_o             =>ben_prv_shd.g_old_rec.prv_attribute28
 ,p_prv_attribute29_o             =>ben_prv_shd.g_old_rec.prv_attribute29
 ,p_prv_attribute30_o             =>ben_prv_shd.g_old_rec.prv_attribute30
 ,p_pk_id_table_name_o            =>ben_prv_shd.g_old_rec.pk_id_table_name
 ,p_pk_id_o                       =>ben_prv_shd.g_old_rec.pk_id
 ,p_object_version_number_o       =>ben_prv_shd.g_old_rec.object_version_number
      );
 hr_utility.set_location('DM Mode prv ' ||hr_general.g_data_migrator_mode ,379);
  --bug 1408379  caliing ler_chk moved from trigger to here
 if hr_general.g_data_migrator_mode not in ( 'Y','P') then
     ben_prv_ler.ler_chk(p_old => l_old_rec
                     ,p_new => l_new_rec
                     ,p_effective_date => p_effective_date  );
  end if ;
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_prtt_rt_val'
        ,p_hook_type   => 'AU');
      --
  end;
  --
  -- End of API User Hook for post_update.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
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
Procedure convert_defs(p_rec in out nocopy ben_prv_shd.g_rec_type) is
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
  If (p_rec.rt_strt_dt = hr_api.g_date) then
    p_rec.rt_strt_dt :=
    ben_prv_shd.g_old_rec.rt_strt_dt;
  End If;
  If (p_rec.rt_end_dt = hr_api.g_date) then
    p_rec.rt_end_dt :=
    ben_prv_shd.g_old_rec.rt_end_dt;
  End If;
  If (p_rec.rt_typ_cd = hr_api.g_varchar2) then
    p_rec.rt_typ_cd :=
    ben_prv_shd.g_old_rec.rt_typ_cd;
  End If;
  If (p_rec.tx_typ_cd = hr_api.g_varchar2) then
    p_rec.tx_typ_cd :=
    ben_prv_shd.g_old_rec.tx_typ_cd;
  End If;
  If (p_rec.ordr_num = hr_api.g_number) then
        p_rec.ordr_num :=
        ben_abr_shd.g_old_rec.ordr_num;
  End If;
  If (p_rec.acty_typ_cd = hr_api.g_varchar2) then
    p_rec.acty_typ_cd :=
    ben_prv_shd.g_old_rec.acty_typ_cd;
  End If;
  If (p_rec.mlt_cd = hr_api.g_varchar2) then
    p_rec.mlt_cd :=
    ben_prv_shd.g_old_rec.mlt_cd;
  End If;
  If (p_rec.acty_ref_perd_cd = hr_api.g_varchar2) then
    p_rec.acty_ref_perd_cd :=
    ben_prv_shd.g_old_rec.acty_ref_perd_cd;
  End If;
  If (p_rec.rt_val = hr_api.g_number) then
    p_rec.rt_val :=
    ben_prv_shd.g_old_rec.rt_val;
  End If;
  If (p_rec.ann_rt_val = hr_api.g_number) then
    p_rec.ann_rt_val :=
    ben_prv_shd.g_old_rec.ann_rt_val;
  End If;
  If (p_rec.cmcd_rt_val = hr_api.g_number) then
    p_rec.cmcd_rt_val :=
    ben_prv_shd.g_old_rec.cmcd_rt_val;
  End If;
  If (p_rec.cmcd_ref_perd_cd = hr_api.g_varchar2) then
    p_rec.cmcd_ref_perd_cd :=
    ben_prv_shd.g_old_rec.cmcd_ref_perd_cd;
  End If;
  If (p_rec.bnft_rt_typ_cd = hr_api.g_varchar2) then
    p_rec.bnft_rt_typ_cd :=
    ben_prv_shd.g_old_rec.bnft_rt_typ_cd;
  End If;
  If (p_rec.dsply_on_enrt_flag = hr_api.g_varchar2) then
    p_rec.dsply_on_enrt_flag :=
    ben_prv_shd.g_old_rec.dsply_on_enrt_flag;
  End If;
  If (p_rec.rt_ovridn_flag = hr_api.g_varchar2) then
    p_rec.rt_ovridn_flag :=
    ben_prv_shd.g_old_rec.rt_ovridn_flag;
  End If;
  If (p_rec.rt_ovridn_thru_dt = hr_api.g_date) then
    p_rec.rt_ovridn_thru_dt :=
    ben_prv_shd.g_old_rec.rt_ovridn_thru_dt;
  End If;
  If (p_rec.elctns_made_dt = hr_api.g_date) then
    p_rec.elctns_made_dt :=
    ben_prv_shd.g_old_rec.elctns_made_dt;
  End If;
  If (p_rec.prtt_rt_val_stat_cd = hr_api.g_varchar2) then
    p_rec.prtt_rt_val_stat_cd :=
    ben_prv_shd.g_old_rec.prtt_rt_val_stat_cd;
  End If;
  If (p_rec.prtt_enrt_rslt_id = hr_api.g_number) then
    p_rec.prtt_enrt_rslt_id :=
    ben_prv_shd.g_old_rec.prtt_enrt_rslt_id;
  End If;
  If (p_rec.cvg_amt_calc_mthd_id = hr_api.g_number) then
    p_rec.cvg_amt_calc_mthd_id :=
    ben_prv_shd.g_old_rec.cvg_amt_calc_mthd_id;
  End If;
  If (p_rec.actl_prem_id = hr_api.g_number) then
    p_rec.actl_prem_id :=
    ben_prv_shd.g_old_rec.actl_prem_id;
  End If;
  If (p_rec.comp_lvl_fctr_id = hr_api.g_number) then
    p_rec.comp_lvl_fctr_id :=
    ben_prv_shd.g_old_rec.comp_lvl_fctr_id;
  End If;
  If (p_rec.element_entry_value_id = hr_api.g_number) then
    p_rec.element_entry_value_id :=
    ben_prv_shd.g_old_rec.element_entry_value_id;
  End If;
  If (p_rec.per_in_ler_id = hr_api.g_number) then
    p_rec.per_in_ler_id :=
    ben_prv_shd.g_old_rec.per_in_ler_id;
  End If;
  If (p_rec.ended_per_in_ler_id = hr_api.g_number) then
    p_rec.ended_per_in_ler_id :=
    ben_prv_shd.g_old_rec.ended_per_in_ler_id;
  End If;
  If (p_rec.acty_base_rt_id = hr_api.g_number) then
    p_rec.acty_base_rt_id :=
    ben_prv_shd.g_old_rec.acty_base_rt_id;
  End If;
  If (p_rec.prtt_reimbmt_rqst_id = hr_api.g_number) then
    p_rec.prtt_reimbmt_rqst_id :=
    ben_prv_shd.g_old_rec.prtt_reimbmt_rqst_id;
  End If;

  If (p_rec.prtt_rmt_aprvd_fr_pymt_id = hr_api.g_number) then
    p_rec.prtt_rmt_aprvd_fr_pymt_id :=
    ben_prv_shd.g_old_rec.prtt_rmt_aprvd_fr_pymt_id;
  End If;

  If (p_rec.pp_in_yr_used_num = hr_api.g_number) then
    p_rec.pp_in_yr_used_num :=
    ben_prv_shd.g_old_rec.pp_in_yr_used_num;
  End If;


  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    ben_prv_shd.g_old_rec.business_group_id;
  End If;

  If (p_rec.prv_attribute_category = hr_api.g_varchar2) then
    p_rec.prv_attribute_category :=
    ben_prv_shd.g_old_rec.prv_attribute_category;
  End If;

  If (p_rec.prv_attribute1 = hr_api.g_varchar2) then
    p_rec.prv_attribute1 :=
    ben_prv_shd.g_old_rec.prv_attribute1;
  End If;

  If (p_rec.prv_attribute2 = hr_api.g_varchar2) then
    p_rec.prv_attribute2 :=
    ben_prv_shd.g_old_rec.prv_attribute2;
  End If;
  If (p_rec.prv_attribute3 = hr_api.g_varchar2) then
    p_rec.prv_attribute3 :=
    ben_prv_shd.g_old_rec.prv_attribute3;
  End If;
  If (p_rec.prv_attribute4 = hr_api.g_varchar2) then
    p_rec.prv_attribute4 :=
    ben_prv_shd.g_old_rec.prv_attribute4;
  End If;
  If (p_rec.prv_attribute5 = hr_api.g_varchar2) then
    p_rec.prv_attribute5 :=
    ben_prv_shd.g_old_rec.prv_attribute5;
  End If;
  If (p_rec.prv_attribute6 = hr_api.g_varchar2) then
    p_rec.prv_attribute6 :=
    ben_prv_shd.g_old_rec.prv_attribute6;
  End If;
  If (p_rec.prv_attribute7 = hr_api.g_varchar2) then
    p_rec.prv_attribute7 :=
    ben_prv_shd.g_old_rec.prv_attribute7;
  End If;
  If (p_rec.prv_attribute8 = hr_api.g_varchar2) then
    p_rec.prv_attribute8 :=
    ben_prv_shd.g_old_rec.prv_attribute8;
  End If;
  If (p_rec.prv_attribute9 = hr_api.g_varchar2) then
    p_rec.prv_attribute9 :=
    ben_prv_shd.g_old_rec.prv_attribute9;
  End If;
  If (p_rec.prv_attribute10 = hr_api.g_varchar2) then
    p_rec.prv_attribute10 :=
    ben_prv_shd.g_old_rec.prv_attribute10;
  End If;
  If (p_rec.prv_attribute11 = hr_api.g_varchar2) then
    p_rec.prv_attribute11 :=
    ben_prv_shd.g_old_rec.prv_attribute11;
  End If;
  If (p_rec.prv_attribute12 = hr_api.g_varchar2) then
    p_rec.prv_attribute12 :=
    ben_prv_shd.g_old_rec.prv_attribute12;
  End If;
  If (p_rec.prv_attribute13 = hr_api.g_varchar2) then
    p_rec.prv_attribute13 :=
    ben_prv_shd.g_old_rec.prv_attribute13;
  End If;
  If (p_rec.prv_attribute14 = hr_api.g_varchar2) then
    p_rec.prv_attribute14 :=
    ben_prv_shd.g_old_rec.prv_attribute14;
  End If;
  If (p_rec.prv_attribute15 = hr_api.g_varchar2) then
    p_rec.prv_attribute15 :=
    ben_prv_shd.g_old_rec.prv_attribute15;
  End If;
  If (p_rec.prv_attribute16 = hr_api.g_varchar2) then
    p_rec.prv_attribute16 :=
    ben_prv_shd.g_old_rec.prv_attribute16;
  End If;
  If (p_rec.prv_attribute17 = hr_api.g_varchar2) then
    p_rec.prv_attribute17 :=
    ben_prv_shd.g_old_rec.prv_attribute17;
  End If;
  If (p_rec.prv_attribute18 = hr_api.g_varchar2) then
    p_rec.prv_attribute18 :=
    ben_prv_shd.g_old_rec.prv_attribute18;
  End If;
  If (p_rec.prv_attribute19 = hr_api.g_varchar2) then
    p_rec.prv_attribute19 :=
    ben_prv_shd.g_old_rec.prv_attribute19;
  End If;
  If (p_rec.prv_attribute20 = hr_api.g_varchar2) then
    p_rec.prv_attribute20 :=
    ben_prv_shd.g_old_rec.prv_attribute20;
  End If;
  If (p_rec.prv_attribute21 = hr_api.g_varchar2) then
    p_rec.prv_attribute21 :=
    ben_prv_shd.g_old_rec.prv_attribute21;
  End If;
  If (p_rec.prv_attribute22 = hr_api.g_varchar2) then
    p_rec.prv_attribute22 :=
    ben_prv_shd.g_old_rec.prv_attribute22;
  End If;
  If (p_rec.prv_attribute23 = hr_api.g_varchar2) then
    p_rec.prv_attribute23 :=
    ben_prv_shd.g_old_rec.prv_attribute23;
  End If;
  If (p_rec.prv_attribute24 = hr_api.g_varchar2) then
    p_rec.prv_attribute24 :=
    ben_prv_shd.g_old_rec.prv_attribute24;
  End If;
  If (p_rec.prv_attribute25 = hr_api.g_varchar2) then
    p_rec.prv_attribute25 :=
    ben_prv_shd.g_old_rec.prv_attribute25;
  End If;
  If (p_rec.prv_attribute26 = hr_api.g_varchar2) then
    p_rec.prv_attribute26 :=
    ben_prv_shd.g_old_rec.prv_attribute26;
  End If;
  If (p_rec.prv_attribute27 = hr_api.g_varchar2) then
    p_rec.prv_attribute27 :=
    ben_prv_shd.g_old_rec.prv_attribute27;
  End If;
  If (p_rec.prv_attribute28 = hr_api.g_varchar2) then
    p_rec.prv_attribute28 :=
    ben_prv_shd.g_old_rec.prv_attribute28;
  End If;
  If (p_rec.prv_attribute29 = hr_api.g_varchar2) then
    p_rec.prv_attribute29 :=
    ben_prv_shd.g_old_rec.prv_attribute29;
  End If;
  If (p_rec.prv_attribute30 = hr_api.g_varchar2) then
    p_rec.prv_attribute30 :=
    ben_prv_shd.g_old_rec.prv_attribute30;
  End If;
  If (p_rec.pk_id_table_name = hr_api.g_varchar2) then
    p_rec.pk_id_table_name :=
    ben_prv_shd.g_old_rec.pk_id_table_name;
  End If;
  If (p_rec.pk_id= hr_api.g_number) then
    p_rec.pk_id :=
    ben_prv_shd.g_old_rec.pk_id;
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
  (   p_rec  in out nocopy ben_prv_shd.g_rec_type ,
      p_effective_date in date ) is
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  ---
  -- We must lock the row which we need to update.
  --
  ben_prv_shd.lck
	(
	p_rec.prtt_rt_val_id,
	p_rec.object_version_number
	);
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  convert_defs(p_rec);
  ben_prv_bus.update_validate(p_rec,p_effective_date);
  --
  -- Call the supporting pre-update operation
  --
  pre_update(p_rec,p_effective_date);
  --
  -- Update the row.
  --
  update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  post_update(p_rec,p_effective_date );

End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_prtt_rt_val_id               in number,
  p_enrt_rt_id		     	 in number	     default hr_api.g_number,
  p_rt_strt_dt                   in date             default hr_api.g_date,
  p_rt_end_dt                    in date             default hr_api.g_date,
  p_rt_typ_cd                    in varchar2         default hr_api.g_varchar2,
  p_tx_typ_cd                    in varchar2         default hr_api.g_varchar2,
  p_ordr_num			 in number           default hr_api.g_number,
  p_acty_typ_cd                  in varchar2         default hr_api.g_varchar2,
  p_mlt_cd                       in varchar2         default hr_api.g_varchar2,
  p_acty_ref_perd_cd             in varchar2         default hr_api.g_varchar2,
  p_rt_val                       in number           default hr_api.g_number,
  p_ann_rt_val                   in number           default hr_api.g_number,
  p_cmcd_rt_val                  in number           default hr_api.g_number,
  p_cmcd_ref_perd_cd             in varchar2         default hr_api.g_varchar2,
  p_bnft_rt_typ_cd               in varchar2         default hr_api.g_varchar2,
  p_dsply_on_enrt_flag           in varchar2         default hr_api.g_varchar2,
  p_rt_ovridn_flag               in varchar2         default hr_api.g_varchar2,
  p_rt_ovridn_thru_dt            in date             default hr_api.g_date,
  p_elctns_made_dt               in date             default hr_api.g_date,
  p_prtt_rt_val_stat_cd          in varchar2         default hr_api.g_varchar2,
  p_prtt_enrt_rslt_id            in number           default hr_api.g_number,
  p_cvg_amt_calc_mthd_id         in number           default hr_api.g_number,
  p_actl_prem_id                 in number           default hr_api.g_number,
  p_comp_lvl_fctr_id             in number           default hr_api.g_number,
  p_element_entry_value_id       in number           default hr_api.g_number,
  p_per_in_ler_id                in number           default hr_api.g_number,
  p_ended_per_in_ler_id          in number           default hr_api.g_number,
  p_acty_base_rt_id              in number           default hr_api.g_number,
  p_prtt_reimbmt_rqst_id         in number           default hr_api.g_number,
  p_prtt_rmt_aprvd_fr_pymt_id    in number           default hr_api.g_number,
  p_pp_in_yr_used_num            in number           default hr_api.g_number,
  p_business_group_id            in number           default hr_api.g_number,
  p_prv_attribute_category       in varchar2         default hr_api.g_varchar2,
  p_prv_attribute1               in varchar2         default hr_api.g_varchar2,
  p_prv_attribute2               in varchar2         default hr_api.g_varchar2,
  p_prv_attribute3               in varchar2         default hr_api.g_varchar2,
  p_prv_attribute4               in varchar2         default hr_api.g_varchar2,
  p_prv_attribute5               in varchar2         default hr_api.g_varchar2,
  p_prv_attribute6               in varchar2         default hr_api.g_varchar2,
  p_prv_attribute7               in varchar2         default hr_api.g_varchar2,
  p_prv_attribute8               in varchar2         default hr_api.g_varchar2,
  p_prv_attribute9               in varchar2         default hr_api.g_varchar2,
  p_prv_attribute10              in varchar2         default hr_api.g_varchar2,
  p_prv_attribute11              in varchar2         default hr_api.g_varchar2,
  p_prv_attribute12              in varchar2         default hr_api.g_varchar2,
  p_prv_attribute13              in varchar2         default hr_api.g_varchar2,
  p_prv_attribute14              in varchar2         default hr_api.g_varchar2,
  p_prv_attribute15              in varchar2         default hr_api.g_varchar2,
  p_prv_attribute16              in varchar2         default hr_api.g_varchar2,
  p_prv_attribute17              in varchar2         default hr_api.g_varchar2,
  p_prv_attribute18              in varchar2         default hr_api.g_varchar2,
  p_prv_attribute19              in varchar2         default hr_api.g_varchar2,
  p_prv_attribute20              in varchar2         default hr_api.g_varchar2,
  p_prv_attribute21              in varchar2         default hr_api.g_varchar2,
  p_prv_attribute22              in varchar2         default hr_api.g_varchar2,
  p_prv_attribute23              in varchar2         default hr_api.g_varchar2,
  p_prv_attribute24              in varchar2         default hr_api.g_varchar2,
  p_prv_attribute25              in varchar2         default hr_api.g_varchar2,
  p_prv_attribute26              in varchar2         default hr_api.g_varchar2,
  p_prv_attribute27              in varchar2         default hr_api.g_varchar2,
  p_prv_attribute28              in varchar2         default hr_api.g_varchar2,
  p_prv_attribute29              in varchar2         default hr_api.g_varchar2,
  p_prv_attribute30              in varchar2         default hr_api.g_varchar2,
  p_pk_id_table_name             in varchar2         default hr_api.g_varchar2,
  p_pk_id                        in number           default hr_api.g_number,
  p_object_version_number        in out nocopy number                                ,
  p_effective_Date               in date
  ) is
--
  l_rec	  ben_prv_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ben_prv_shd.convert_args
  (
  p_prtt_rt_val_id,
  p_enrt_rt_id,
  p_rt_strt_dt,
  p_rt_end_dt,
  p_rt_typ_cd,
  p_tx_typ_cd,
  p_ordr_num,
  p_acty_typ_cd,
  p_mlt_cd,
  p_acty_ref_perd_cd,
  p_rt_val,
  p_ann_rt_val,
  p_cmcd_rt_val,
  p_cmcd_ref_perd_cd,
  p_bnft_rt_typ_cd,
  p_dsply_on_enrt_flag,
  p_rt_ovridn_flag,
  p_rt_ovridn_thru_dt,
  p_elctns_made_dt,
  p_prtt_rt_val_stat_cd,
  p_prtt_enrt_rslt_id,
  p_cvg_amt_calc_mthd_id,
  p_actl_prem_id,
  p_comp_lvl_fctr_id,
  p_element_entry_value_id,
  p_per_in_ler_id,
  p_ended_per_in_ler_id,
  p_acty_base_rt_id,
  p_prtt_reimbmt_rqst_id,
  p_prtt_rmt_aprvd_fr_pymt_id,
  p_pp_in_yr_used_num,
  p_business_group_id,
  p_prv_attribute_category,
  p_prv_attribute1,
  p_prv_attribute2,
  p_prv_attribute3,
  p_prv_attribute4,
  p_prv_attribute5,
  p_prv_attribute6,
  p_prv_attribute7,
  p_prv_attribute8,
  p_prv_attribute9,
  p_prv_attribute10,
  p_prv_attribute11,
  p_prv_attribute12,
  p_prv_attribute13,
  p_prv_attribute14,
  p_prv_attribute15,
  p_prv_attribute16,
  p_prv_attribute17,
  p_prv_attribute18,
  p_prv_attribute19,
  p_prv_attribute20,
  p_prv_attribute21,
  p_prv_attribute22,
  p_prv_attribute23,
  p_prv_attribute24,
  p_prv_attribute25,
  p_prv_attribute26,
  p_prv_attribute27,
  p_prv_attribute28,
  p_prv_attribute29,
  p_prv_attribute30,
  p_pk_id_table_name,
  p_pk_id,
  p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(l_rec , p_effective_date );


  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end ben_prv_upd;

/
