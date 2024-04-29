--------------------------------------------------------
--  DDL for Package Body BEN_ECR_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ECR_INS" as
/* $Header: beecrrhi.pkb 115.21 2002/12/27 20:59:56 pabodla ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_ecr_ins.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   this procedure controls the actual dml insert logic. the processing of
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
Procedure insert_dml(p_rec in out nocopy ben_ecr_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  ben_ecr_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ben_enrt_rt
  --
  insert into ben_enrt_rt
   (enrt_rt_id            ,
   	ordr_num,
	acty_typ_cd           ,
	tx_typ_cd             ,
	ctfn_rqd_flag         ,
	dflt_flag             ,
	dflt_pndg_ctfn_flag   ,
	dsply_on_enrt_flag    ,
	use_to_calc_net_flx_cr_flag,
	entr_val_at_enrt_flag ,
	asn_on_enrt_flag      ,
	rl_crs_only_flag      ,
	dflt_val              ,
	ann_val               ,
	ann_mn_elcn_val       ,
	ann_mx_elcn_val       ,
	val                   ,
	nnmntry_uom           ,
	mx_elcn_val           ,
	mn_elcn_val           ,
	incrmt_elcn_val       ,
	cmcd_acty_ref_perd_cd ,
	cmcd_mn_elcn_val      ,
	cmcd_mx_elcn_val      ,
	cmcd_val              ,
	cmcd_dflt_val         ,
	rt_usg_cd             ,
	ann_dflt_val          ,
	bnft_rt_typ_cd        ,
	rt_mlt_cd             ,
	dsply_mn_elcn_val     ,
	dsply_mx_elcn_val     ,
	entr_ann_val_flag     ,
	rt_strt_dt            ,
	rt_strt_dt_cd         ,
	rt_strt_dt_rl         ,
	rt_typ_cd             ,
	elig_per_elctbl_chc_id,
	acty_base_rt_id       ,
	spcl_rt_enrt_rt_id    ,
	enrt_bnft_id          ,
	prtt_rt_val_id        ,
	decr_bnft_prvdr_pool_id,
	cvg_amt_calc_mthd_id  ,
	actl_prem_id          ,
	comp_lvl_fctr_id      ,
	ptd_comp_lvl_fctr_id  ,
	clm_comp_lvl_fctr_id  ,
	business_group_id     ,
        --cwb
        iss_val               ,
        val_last_upd_date     ,
        val_last_upd_person_id,
        --cwb
        pp_in_yr_used_num,
	ecr_attribute_category,
	ecr_attribute1        ,
	ecr_attribute2        ,
	ecr_attribute3        ,
	ecr_attribute4        ,
	ecr_attribute5        ,
	ecr_attribute6        ,
	ecr_attribute7        ,
	ecr_attribute8        ,
	ecr_attribute9        ,
	ecr_attribute10       ,
	ecr_attribute11       ,
	ecr_attribute12       ,
	ecr_attribute13       ,
	ecr_attribute14       ,
	ecr_attribute15       ,
	ecr_attribute16       ,
	ecr_attribute17       ,
	ecr_attribute18       ,
	ecr_attribute19       ,
	ecr_attribute20       ,
	ecr_attribute21       ,
	ecr_attribute22       ,
    ecr_attribute23       ,
    ecr_attribute24       ,
    ecr_attribute25       ,
    ecr_attribute26       ,
    ecr_attribute27       ,
    ecr_attribute28       ,
    ecr_attribute29       ,
    ecr_attribute30       ,
    last_update_login     ,
    created_by            ,
    creation_date         ,
    last_updated_by       ,
    last_update_date      ,
    request_id            ,
    program_application_id,
    program_id            ,
    program_update_date   ,
    object_version_number
  )
  Values
  (
  p_rec.enrt_rt_id,
  p_rec.ordr_num,
  p_rec.acty_typ_cd,
  p_rec.tx_typ_cd,
  p_rec.ctfn_rqd_flag,
  p_rec.dflt_flag,
  p_rec.dflt_pndg_ctfn_flag,
  p_rec.dsply_on_enrt_flag,
  p_rec.use_to_calc_net_flx_cr_flag,
  p_rec.entr_val_at_enrt_flag,
  p_rec.asn_on_enrt_flag,
  p_rec.rl_crs_only_flag,
  p_rec.dflt_val,
  p_rec.ann_val,
  p_rec.ann_mn_elcn_val,
  p_rec.ann_mx_elcn_val,
  p_rec.val,
  p_rec.nnmntry_uom,
  p_rec.mx_elcn_val,
  p_rec.mn_elcn_val,
  p_rec.incrmt_elcn_val,
  p_rec.cmcd_acty_ref_perd_cd,
  p_rec.cmcd_mn_elcn_val,
  p_rec.cmcd_mx_elcn_val,
  p_rec.cmcd_val,
  p_rec.cmcd_dflt_val,
  p_rec.rt_usg_cd,
  p_rec.ann_dflt_val,
  p_rec.bnft_rt_typ_cd,
  p_rec.rt_mlt_cd,
  p_rec.dsply_mn_elcn_val,
  p_rec.dsply_mx_elcn_val,
  p_rec.entr_ann_val_flag,
  p_rec.rt_strt_dt,
  p_rec.rt_strt_dt_cd,
  p_rec.rt_strt_dt_rl,
  p_rec.rt_typ_cd,
  p_rec.elig_per_elctbl_chc_id,
  p_rec.acty_base_rt_id,
  p_rec.spcl_rt_enrt_rt_id,
  p_rec.enrt_bnft_id,
  p_rec.prtt_rt_val_id,
  p_rec.decr_bnft_prvdr_pool_id,
  p_rec.cvg_amt_calc_mthd_id,
  p_rec.actl_prem_id,
  p_rec.comp_lvl_fctr_id,
  p_rec.ptd_comp_lvl_fctr_id,
  p_rec.clm_comp_lvl_fctr_id,
  p_rec.business_group_id,
  --cwb
  p_rec.iss_val               ,
  p_rec.val_last_upd_date     ,
  p_rec.val_last_upd_person_id,
  --cwb
  p_rec.pp_in_yr_used_num,
  p_rec.ecr_attribute_category,
  p_rec.ecr_attribute1,
  p_rec.ecr_attribute2,
  p_rec.ecr_attribute3,
  p_rec.ecr_attribute4,
  p_rec.ecr_attribute5,
  p_rec.ecr_attribute6,
  p_rec.ecr_attribute7,
  p_rec.ecr_attribute8,
  p_rec.ecr_attribute9,
  p_rec.ecr_attribute10,
  p_rec.ecr_attribute11,
  p_rec.ecr_attribute12,
  p_rec.ecr_attribute13,
  p_rec.ecr_attribute14,
  p_rec.ecr_attribute15,
  p_rec.ecr_attribute16,
  p_rec.ecr_attribute17,
  p_rec.ecr_attribute18,
  p_rec.ecr_attribute19,
  p_rec.ecr_attribute20,
  p_rec.ecr_attribute21,
  p_rec.ecr_attribute22,
  p_rec.ecr_attribute23,
  p_rec.ecr_attribute24,
  p_rec.ecr_attribute25,
  p_rec.ecr_attribute26,
  p_rec.ecr_attribute27,
  p_rec.ecr_attribute28,
  p_rec.ecr_attribute29,
  p_rec.ecr_attribute30,
  p_rec.last_update_login,
  p_rec.created_by,
  p_rec.creation_date,
  p_rec.last_updated_by,
  p_rec.last_update_date,
  p_rec.request_id,
  p_rec.program_application_id,
  p_rec.program_id,
  p_rec.program_update_date,
  p_rec.object_version_number
  );
  --
  ben_ecr_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_ecr_shd.g_api_dml := false;   -- Unset the api dml status
    ben_ecr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ben_ecr_shd.g_api_dml := false;   -- Unset the api dml status
    ben_ecr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_ecr_shd.g_api_dml := false;   -- Unset the api dml status
    ben_ecr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_ecr_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_insert(p_rec  in out nocopy ben_ecr_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select ben_enrt_rt_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.enrt_rt_id;
  Close C_Sel1;
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
Procedure post_insert(p_rec            in ben_ecr_shd.g_rec_type,
                      p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (p_rec            in out nocopy ben_ecr_shd.g_rec_type,
   p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  ben_ecr_bus.insert_validate(p_rec,p_effective_date);
  --
  -- Call the supporting pre-insert operation
  --
  pre_insert(p_rec);
  --
  -- Insert the row
  --
  insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  post_insert(p_rec,p_effective_date);
end ins;
--

-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
    p_effective_date              in date,
	p_enrt_rt_id                  out nocopy NUMBER,
	p_ordr_num			 in number           default null,
	p_acty_typ_cd                 in  VARCHAR2,
	p_tx_typ_cd                   in  VARCHAR2,
	p_ctfn_rqd_flag               in  VARCHAR2,
	p_dflt_flag                   in  VARCHAR2,
	p_dflt_pndg_ctfn_flag         in  VARCHAR2,
	p_dsply_on_enrt_flag          in  VARCHAR2,
	p_use_to_calc_net_flx_cr_flag in  VARCHAR2,
	p_entr_val_at_enrt_flag       in  VARCHAR2,
	p_asn_on_enrt_flag            in  VARCHAR2,
	p_rl_crs_only_flag            in  VARCHAR2,
	p_dflt_val                    in  NUMBER    DEFAULT NULL,
	p_ann_val                     in  NUMBER    DEFAULT NULL,
	p_ann_mn_elcn_val             in  NUMBER    DEFAULT NULL,
	p_ann_mx_elcn_val             in  NUMBER    DEFAULT NULL,
	p_val                         in  NUMBER    DEFAULT NULL,
	p_nnmntry_uom                 in  VARCHAR2  DEFAULT NULL,
	p_mx_elcn_val                 in  NUMBER    DEFAULT NULL,
	p_mn_elcn_val                 in  NUMBER    DEFAULT NULL,
	p_incrmt_elcn_val             in  NUMBER    DEFAULT NULL,
	p_cmcd_acty_ref_perd_cd       in  VARCHAR2  DEFAULT NULL,
	p_cmcd_mn_elcn_val            in  NUMBER    DEFAULT NULL,
	p_cmcd_mx_elcn_val            in  NUMBER    DEFAULT NULL,
	p_cmcd_val                    in  NUMBER    DEFAULT NULL,
	p_cmcd_dflt_val               in  NUMBER    DEFAULT NULL,
	p_rt_usg_cd                   in  VARCHAR2  DEFAULT NULL,
	p_ann_dflt_val                in  NUMBER    DEFAULT NULL,
	p_bnft_rt_typ_cd              in  VARCHAR2  DEFAULT NULL,
	p_rt_mlt_cd                   in  VARCHAR2  DEFAULT NULL,
	p_dsply_mn_elcn_val           in  NUMBER    DEFAULT NULL,
	p_dsply_mx_elcn_val           in  NUMBER    DEFAULT NULL,
	p_entr_ann_val_flag           in  VARCHAR2,
	p_rt_strt_dt                  in  DATE      DEFAULT NULL,
	p_rt_strt_dt_cd               in  VARCHAR2  DEFAULT NULL,
	p_rt_strt_dt_rl               in  NUMBER    DEFAULT NULL,
	p_rt_typ_cd                   in  VARCHAR2  DEFAULT NULL,
	p_elig_per_elctbl_chc_id      in  NUMBER    DEFAULT NULL,
	p_acty_base_rt_id             in  NUMBER    DEFAULT NULL,
	p_spcl_rt_enrt_rt_id          in  NUMBER    DEFAULT NULL,
	p_enrt_bnft_id                in  NUMBER    DEFAULT NULL,
	p_prtt_rt_val_id              in  NUMBER    DEFAULT NULL,
	p_decr_bnft_prvdr_pool_id     in  NUMBER    DEFAULT NULL,
	p_cvg_amt_calc_mthd_id        in  NUMBER    DEFAULT NULL,
	p_actl_prem_id                in  NUMBER    DEFAULT NULL,
	p_comp_lvl_fctr_id            in  NUMBER    DEFAULT NULL,
	p_ptd_comp_lvl_fctr_id        in  NUMBER    DEFAULT NULL,
	p_clm_comp_lvl_fctr_id        in  NUMBER    DEFAULT NULL,
	p_business_group_id           in  NUMBER,
        --cwb
        p_iss_val                     in  number    DEFAULT NULL,
        p_val_last_upd_date           in  date      DEFAULT NULL,
        p_val_last_upd_person_id      in  number    DEFAULT NULL,
        --cwb
        p_pp_in_yr_used_num           in  number    default NULL,
	p_ecr_attribute_category      in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute1              in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute2              in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute3              in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute4              in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute5              in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute6              in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute7              in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute8              in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute9              in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute10             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute11             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute12             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute13             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute14             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute15             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute16             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute17             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute18             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute19             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute20             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute21             in  VARCHAR2  DEFAULT NULL,
	p_ecr_attribute22             in  VARCHAR2  DEFAULT NULL,
    p_ecr_attribute23             in  VARCHAR2  DEFAULT NULL,
    p_ecr_attribute24             in  VARCHAR2  DEFAULT NULL,
    p_ecr_attribute25             in  VARCHAR2  DEFAULT NULL,
    p_ecr_attribute26             in  VARCHAR2  DEFAULT NULL,
    p_ecr_attribute27             in  VARCHAR2  DEFAULT NULL,
    p_ecr_attribute28             in  VARCHAR2  DEFAULT NULL,
    p_ecr_attribute29             in  VARCHAR2  DEFAULT NULL,
    p_ecr_attribute30             in  VARCHAR2  DEFAULT NULL,
    p_last_update_login           in  NUMBER    DEFAULT NULL,
    p_created_by                  in  NUMBER    DEFAULT NULL,
    p_creation_date               in  DATE      DEFAULT NULL,
    p_last_updated_by             in  NUMBER    DEFAULT NULL,
    p_last_update_date            in  DATE      DEFAULT NULL,
    p_request_id                  in  NUMBER    DEFAULT NULL,
    p_program_application_id      in  NUMBER    DEFAULT NULL,
    p_program_id                  in  NUMBER    DEFAULT NULL,
    p_program_update_date         in  DATE      DEFAULT NULL,
    p_object_version_number       out nocopy NUMBER )
 is
--
  l_rec	  ben_ecr_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ben_ecr_shd.convert_args
  (
  null,
  p_ordr_num,
  p_acty_typ_cd,
  p_tx_typ_cd,
  p_ctfn_rqd_flag,
  p_dflt_flag,
  p_dflt_pndg_ctfn_flag,
  p_dsply_on_enrt_flag,
  p_use_to_calc_net_flx_cr_flag,
  p_entr_val_at_enrt_flag,
  p_asn_on_enrt_flag,
  p_rl_crs_only_flag,
  p_dflt_val,
  p_ann_val,
  p_ann_mn_elcn_val,
  p_ann_mx_elcn_val,
  p_val,
  p_nnmntry_uom,
  p_mx_elcn_val,
  p_mn_elcn_val,
  p_incrmt_elcn_val,
  p_cmcd_acty_ref_perd_cd,
  p_cmcd_mn_elcn_val,
  p_cmcd_mx_elcn_val,
  p_cmcd_val,
  p_cmcd_dflt_val,
  p_rt_usg_cd,
  p_ann_dflt_val,
  p_bnft_rt_typ_cd,
  p_rt_mlt_cd,
  p_dsply_mn_elcn_val,
  p_dsply_mx_elcn_val,
  p_entr_ann_val_flag,
  p_rt_strt_dt,
  p_rt_strt_dt_cd,
  p_rt_strt_dt_rl,
  p_rt_typ_cd,
  p_elig_per_elctbl_chc_id,
  p_acty_base_rt_id,
  p_spcl_rt_enrt_rt_id,
  p_enrt_bnft_id,
  p_prtt_rt_val_id,
  p_decr_bnft_prvdr_pool_id,
  p_cvg_amt_calc_mthd_id,
  p_actl_prem_id,
  p_comp_lvl_fctr_id,
  p_ptd_comp_lvl_fctr_id,
  p_clm_comp_lvl_fctr_id,
  p_business_group_id,
  --cwb
  p_iss_val               ,
  p_val_last_upd_date     ,
  p_val_last_upd_person_id,
  --cwb
  p_pp_in_yr_used_num,
  p_ecr_attribute_category,
  p_ecr_attribute1,
  p_ecr_attribute2,
  p_ecr_attribute3,
  p_ecr_attribute4,
  p_ecr_attribute5,
  p_ecr_attribute6,
  p_ecr_attribute7,
  p_ecr_attribute8,
  p_ecr_attribute9,
  p_ecr_attribute10,
  p_ecr_attribute11,
  p_ecr_attribute12,
  p_ecr_attribute13,
  p_ecr_attribute14,
  p_ecr_attribute15,
  p_ecr_attribute16,
  p_ecr_attribute17,
  p_ecr_attribute18,
  p_ecr_attribute19,
  p_ecr_attribute20,
  p_ecr_attribute21,
  p_ecr_attribute22,
  p_ecr_attribute23,
  p_ecr_attribute24,
  p_ecr_attribute25,
  p_ecr_attribute26,
  p_ecr_attribute27,
  p_ecr_attribute28,
  p_ecr_attribute29,
  p_ecr_attribute30,
  p_last_update_login,
  p_created_by,
  p_creation_date,
  p_last_updated_by,
  p_last_update_date,
  p_request_id,
  p_program_application_id,
  p_program_id,
  p_program_update_date,
  null
  );
  --
  -- Having converted the arguments into the ben_ecr_rec
  -- plsql record structure we call the corresponding record business process.
  --
    ins(l_rec,p_effective_date);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_enrt_rt_id := l_rec.enrt_rt_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ben_ecr_ins;

/
