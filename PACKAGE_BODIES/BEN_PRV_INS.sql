--------------------------------------------------------
--  DDL for Package Body BEN_PRV_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PRV_INS" as
/* $Header: beprvrhi.pkb 120.0.12000000.3 2007/07/01 19:16:05 mmudigon noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_prv_ins.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml insert logic. The processing of
--   this procedure are as follows:
--   1) Initialise the object_version_number to 1 if the object_version_number
--      is defined as an attribute for this entity.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To insert the row into the schema.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the ins
--   procedure and must have all mandatory attributes set (except the
--   object_version_number which is initialised within this procedure).
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be inserted into the schema.
--
-- Post Failure:
--   On the insert dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure insert_dml(p_rec in out nocopy ben_prv_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  ben_prv_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ben_prtt_rt_val
  --
  insert into ben_prtt_rt_val
  (	prtt_rt_val_id,
	rt_strt_dt,
	rt_end_dt,
	rt_typ_cd,
	tx_typ_cd,
	ordr_num,
	acty_typ_cd,
	mlt_cd,
	acty_ref_perd_cd,
	rt_val,
	ann_rt_val,
	cmcd_rt_val,
	cmcd_ref_perd_cd,
	bnft_rt_typ_cd,
	dsply_on_enrt_flag,
	rt_ovridn_flag,
	rt_ovridn_thru_dt,
	elctns_made_dt,
	prtt_rt_val_stat_cd,
	prtt_enrt_rslt_id,
	cvg_amt_calc_mthd_id,
	actl_prem_id,
	comp_lvl_fctr_id,
	element_entry_value_id,
	per_in_ler_id,
	ended_per_in_ler_id,
	acty_base_rt_id,
	prtt_reimbmt_rqst_id,
        prtt_rmt_aprvd_fr_pymt_id,
        pp_in_yr_used_num,
	business_group_id,
	prv_attribute_category,
	prv_attribute1,
	prv_attribute2,
	prv_attribute3,
	prv_attribute4,
	prv_attribute5,
	prv_attribute6,
	prv_attribute7,
	prv_attribute8,
	prv_attribute9,
	prv_attribute10,
	prv_attribute11,
	prv_attribute12,
	prv_attribute13,
	prv_attribute14,
	prv_attribute15,
	prv_attribute16,
	prv_attribute17,
	prv_attribute18,
	prv_attribute19,
	prv_attribute20,
	prv_attribute21,
	prv_attribute22,
	prv_attribute23,
	prv_attribute24,
	prv_attribute25,
	prv_attribute26,
	prv_attribute27,
	prv_attribute28,
	prv_attribute29,
	prv_attribute30,
        pk_id_table_name,
        pk_id,
	object_version_number
  )
  Values
  (	p_rec.prtt_rt_val_id,
	p_rec.rt_strt_dt,
	p_rec.rt_end_dt,
	p_rec.rt_typ_cd,
	p_rec.tx_typ_cd,
	p_rec.ordr_num,
	p_rec.acty_typ_cd,
	p_rec.mlt_cd,
	p_rec.acty_ref_perd_cd,
	p_rec.rt_val,
	p_rec.ann_rt_val,
	p_rec.cmcd_rt_val,
	p_rec.cmcd_ref_perd_cd,
	p_rec.bnft_rt_typ_cd,
	p_rec.dsply_on_enrt_flag,
	p_rec.rt_ovridn_flag,
	p_rec.rt_ovridn_thru_dt,
	p_rec.elctns_made_dt,
	p_rec.prtt_rt_val_stat_cd,
	p_rec.prtt_enrt_rslt_id,
	p_rec.cvg_amt_calc_mthd_id,
	p_rec.actl_prem_id,
	p_rec.comp_lvl_fctr_id,
	p_rec.element_entry_value_id,
	p_rec.per_in_ler_id,
	p_rec.ended_per_in_ler_id,
	p_rec.acty_base_rt_id,
	p_rec.prtt_reimbmt_rqst_id,
        p_rec.prtt_rmt_aprvd_fr_pymt_id,
        p_rec.pp_in_yr_used_num,
	p_rec.business_group_id,
	p_rec.prv_attribute_category,
	p_rec.prv_attribute1,
	p_rec.prv_attribute2,
	p_rec.prv_attribute3,
	p_rec.prv_attribute4,
	p_rec.prv_attribute5,
	p_rec.prv_attribute6,
	p_rec.prv_attribute7,
	p_rec.prv_attribute8,
	p_rec.prv_attribute9,
	p_rec.prv_attribute10,
	p_rec.prv_attribute11,
	p_rec.prv_attribute12,
	p_rec.prv_attribute13,
	p_rec.prv_attribute14,
	p_rec.prv_attribute15,
	p_rec.prv_attribute16,
	p_rec.prv_attribute17,
	p_rec.prv_attribute18,
	p_rec.prv_attribute19,
	p_rec.prv_attribute20,
	p_rec.prv_attribute21,
	p_rec.prv_attribute22,
	p_rec.prv_attribute23,
	p_rec.prv_attribute24,
	p_rec.prv_attribute25,
	p_rec.prv_attribute26,
	p_rec.prv_attribute27,
	p_rec.prv_attribute28,
	p_rec.prv_attribute29,
	p_rec.prv_attribute30,
	p_rec.pk_id_table_name,
	p_rec.pk_id,
	p_rec.object_version_number
  );
  --
  ben_prv_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
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
End insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the insert dml. Presently, if the entity has a corresponding primary
--   key which is maintained by an associating sequence, the primary key for
--   the entity will be populated with the next sequence value in
--   preparation for the insert dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the ins procedure.
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
--   Any pre-processing required before the insert dml is issued should be
--   coded within this procedure. As stated above, a good example is the
--   generation of a primary key number via a corresponding sequence.
--   It is important to note that any 3rd party maintenance should be reviewed
--   before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_insert(p_rec  in out nocopy ben_prv_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select ben_prtt_rt_val_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.prtt_rt_val_id;
  Close C_Sel1;

  if p_rec.rt_strt_dt > p_rec.rt_end_dt and
     p_rec.prtt_rt_val_stat_cd is null then
     p_rec.prtt_rt_val_stat_cd := 'VOIDD';
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_insert;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   insert dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the ins procedure.
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
--   Any post-processing required after the insert dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_insert(p_rec in ben_prv_shd.g_rec_type,p_effective_date  in date) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--  p_effective_date date := sysdate;
  l_old_rec   ben_prv_ler.g_prv_ler_rec ;
  l_new_rec   ben_prv_ler.g_prv_ler_rec ;
--
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  begin
     -- intialising variable for calling ler_check
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
     -- Start of API User Hook for post_insert.
    --
    ben_prv_rki.after_insert
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
 ,p_prtt_rt_val_stat_cd           => p_rec.prtt_rt_val_stat_cd
 ,p_prtt_enrt_rslt_id             =>p_rec.prtt_enrt_rslt_id
 ,p_cvg_amt_calc_mthd_id          =>p_rec.cvg_amt_calc_mthd_id
 ,p_actl_prem_id                  =>p_rec.actl_prem_id
 ,p_comp_lvl_fctr_id              =>p_rec.comp_lvl_fctr_id
 ,p_element_entry_value_id        =>p_rec.element_entry_value_id
 ,p_per_in_ler_id                 =>p_rec.per_in_ler_id
 ,p_ended_per_in_ler_id           =>p_rec.ended_per_in_ler_id
 ,p_acty_base_rt_id               =>p_rec.acty_base_rt_id
 ,p_prtt_reimbmt_rqst_id          =>p_rec.prtt_reimbmt_rqst_id
 ,p_prtt_rmt_aprvd_fr_pymt_id     =>P_rec.prtt_rmt_aprvd_fr_pymt_id
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
      );
 --
 hr_utility.set_location('DM Mode prv ' ||hr_general.g_data_migrator_mode ,379);
 if hr_general.g_data_migrator_mode not in ( 'Y','P') then
    --bug 1408379  caliing ler_chk moved from trigger to here
     ben_prv_ler.ler_chk(p_old  => l_old_rec
                     ,p_new =>  l_new_rec
                     ,p_effective_date => p_effective_date  );
  End if ;
 exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_prtt_rt_val'
        ,p_hook_type   => 'AI');
      --
  end;
  --
  -- End of API User Hook for post_insert.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_rec        in out nocopy ben_prv_shd.g_rec_type ,
  p_effective_date in date
  ) is
  --
  l_proc  varchar2(72) := g_package||'ins';
Begin

  hr_utility.set_location('Entering:'||l_proc, 5);

  --
  -- Call the supporting insert validate operations
  --
  ben_prv_bus.insert_validate(p_rec,p_effective_date );
  --
  -- Call the supporting pre-insert operation
  --
  pre_insert(p_rec );
  --
  -- Insert the row
  --
  insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  post_insert(p_rec,p_effective_date );

end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_prtt_rt_val_id               out nocopy number,
  p_enrt_rt_id			 in number	     default null,
  p_rt_strt_dt                   in date,
  p_rt_end_dt                    in date,
  p_rt_typ_cd                    in varchar2         default null,
  p_tx_typ_cd                    in varchar2         default null,
  p_ordr_num			 in number           default null,
  p_acty_typ_cd                  in varchar2         default null,
  p_mlt_cd                       in varchar2         default null,
  p_acty_ref_perd_cd             in varchar2         default null,
  p_rt_val                       in number           default null,
  p_ann_rt_val                   in number           default null,
  p_cmcd_rt_val                  in number           default null,
  p_cmcd_ref_perd_cd             in varchar2         default null,
  p_bnft_rt_typ_cd               in varchar2         default null,
  p_dsply_on_enrt_flag           in varchar2,
  p_rt_ovridn_flag               in varchar2,
  p_rt_ovridn_thru_dt            in date             default null,
  p_elctns_made_dt               in date             default null,
  p_prtt_rt_val_stat_cd          in varchar2         default null,
  p_prtt_enrt_rslt_id            in number,
  p_cvg_amt_calc_mthd_id         in number           default null,
  p_actl_prem_id                 in number           default null,
  p_comp_lvl_fctr_id             in number           default null,
  p_element_entry_value_id       in number           default null,
  p_per_in_ler_id                in number           default null,
  p_ended_per_in_ler_id          in number           default null,
  p_acty_base_rt_id              in number           default null,
  p_prtt_reimbmt_rqst_id         in number           default null,
  p_prtt_rmt_aprvd_fr_pymt_id    in number           default null,
  p_pp_in_yr_used_num            in number           default null,
  p_business_group_id            in number,
  p_prv_attribute_category       in varchar2         default null,
  p_prv_attribute1               in varchar2         default null,
  p_prv_attribute2               in varchar2         default null,
  p_prv_attribute3               in varchar2         default null,
  p_prv_attribute4               in varchar2         default null,
  p_prv_attribute5               in varchar2         default null,
  p_prv_attribute6               in varchar2         default null,
  p_prv_attribute7               in varchar2         default null,
  p_prv_attribute8               in varchar2         default null,
  p_prv_attribute9               in varchar2         default null,
  p_prv_attribute10              in varchar2         default null,
  p_prv_attribute11              in varchar2         default null,
  p_prv_attribute12              in varchar2         default null,
  p_prv_attribute13              in varchar2         default null,
  p_prv_attribute14              in varchar2         default null,
  p_prv_attribute15              in varchar2         default null,
  p_prv_attribute16              in varchar2         default null,
  p_prv_attribute17              in varchar2         default null,
  p_prv_attribute18              in varchar2         default null,
  p_prv_attribute19              in varchar2         default null,
  p_prv_attribute20              in varchar2         default null,
  p_prv_attribute21              in varchar2         default null,
  p_prv_attribute22              in varchar2         default null,
  p_prv_attribute23              in varchar2         default null,
  p_prv_attribute24              in varchar2         default null,
  p_prv_attribute25              in varchar2         default null,
  p_prv_attribute26              in varchar2         default null,
  p_prv_attribute27              in varchar2         default null,
  p_prv_attribute28              in varchar2         default null,
  p_prv_attribute29              in varchar2         default null,
  p_prv_attribute30              in varchar2         default null,
  p_pk_id_table_name             in varchar2         default null,
  p_pk_id                        in number           default null,
  p_object_version_number        out nocopy number                      ,
  p_effective_date               in  date
  ) is
--
  l_rec	  ben_prv_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ben_prv_shd.convert_args
  (
  null,
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
  null
  );
  --
  -- Having converted the arguments into the ben_prv_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(p_rec => l_rec,p_effective_date => p_effective_date );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_prtt_rt_val_id := l_rec.prtt_rt_val_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ben_prv_ins;

/
