--------------------------------------------------------
--  DDL for Package Body BEN_EPE_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_EPE_INS" as
/* $Header: beeperhi.pkb 120.0 2005/05/28 02:36:58 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_epe_ins.';  -- Global package name
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
Procedure insert_dml(p_rec in out nocopy ben_epe_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  ben_epe_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ben_elig_per_elctbl_chc
  --
  insert into ben_elig_per_elctbl_chc
  (	elig_per_elctbl_chc_id,
--	enrt_typ_cycl_cd,
	enrt_cvg_strt_dt_cd,
--	enrt_perd_end_dt,
--	enrt_perd_strt_dt,
	enrt_cvg_strt_dt_rl,
--	rt_strt_dt,
--	rt_strt_dt_rl,
--	rt_strt_dt_cd,
        ctfn_rqd_flag,
        pil_elctbl_chc_popl_id,
	roll_crs_flag,
	crntly_enrd_flag,
	dflt_flag,
	elctbl_flag,
	mndtry_flag,
        in_pndg_wkflow_flag,
--	dflt_enrt_dt,
	dpnt_cvg_strt_dt_cd,
	dpnt_cvg_strt_dt_rl,
	enrt_cvg_strt_dt,
	alws_dpnt_dsgn_flag,
	dpnt_dsgn_cd,
	ler_chg_dpnt_cvg_cd,
	erlst_deenrt_dt,
	procg_end_dt,
	comp_lvl_cd,
	pl_id,
	oipl_id,
	pgm_id,
	plip_id,
	ptip_id,
	pl_typ_id,
	oiplip_id,
	cmbn_plip_id,
	cmbn_ptip_id,
	cmbn_ptip_opt_id,
        assignment_id,
	spcl_rt_pl_id,
	spcl_rt_oipl_id,
	must_enrl_anthr_pl_id,
	interim_elig_per_elctbl_chc_id,
	prtt_enrt_rslt_id,
	bnft_prvdr_pool_id,
	per_in_ler_id,
	yr_perd_id,
	auto_enrt_flag,
	business_group_id,
        pl_ordr_num,
        plip_ordr_num,
        ptip_ordr_num,
        oipl_ordr_num,
        -- cwb
        comments,
        elig_flag,
        elig_ovrid_dt,
        elig_ovrid_person_id,
        inelig_rsn_cd,
        mgr_ovrid_dt,
        mgr_ovrid_person_id,
        ws_mgr_id,
        -- cwb
	epe_attribute_category,
	epe_attribute1,
	epe_attribute2,
	epe_attribute3,
	epe_attribute4,
	epe_attribute5,
	epe_attribute6,
	epe_attribute7,
	epe_attribute8,
	epe_attribute9,
	epe_attribute10,
	epe_attribute11,
	epe_attribute12,
	epe_attribute13,
	epe_attribute14,
	epe_attribute15,
	epe_attribute16,
	epe_attribute17,
	epe_attribute18,
	epe_attribute19,
	epe_attribute20,
	epe_attribute21,
	epe_attribute22,
	epe_attribute23,
	epe_attribute24,
	epe_attribute25,
	epe_attribute26,
	epe_attribute27,
	epe_attribute28,
	epe_attribute29,
	epe_attribute30,
	approval_status_cd,
        fonm_cvg_strt_dt,
        cryfwd_elig_dpnt_cd,
	request_id,
	program_application_id,
	program_id,
	program_update_date,
	object_version_number
  )
  Values
  (	p_rec.elig_per_elctbl_chc_id,
--	p_rec.enrt_typ_cycl_cd,
	p_rec.enrt_cvg_strt_dt_cd,
--	p_rec.enrt_perd_end_dt,
--	p_rec.enrt_perd_strt_dt,
	p_rec.enrt_cvg_strt_dt_rl,
--	p_rec.rt_strt_dt,
--	p_rec.rt_strt_dt_rl,
--	p_rec.rt_strt_dt_cd,
        p_rec.ctfn_rqd_flag,
        p_rec.pil_elctbl_chc_popl_id,
	p_rec.roll_crs_flag,
	p_rec.crntly_enrd_flag,
	p_rec.dflt_flag,
	p_rec.elctbl_flag,
	p_rec.mndtry_flag,
        p_rec.in_pndg_wkflow_flag,
--	p_rec.dflt_enrt_dt,
	p_rec.dpnt_cvg_strt_dt_cd,
	p_rec.dpnt_cvg_strt_dt_rl,
	p_rec.enrt_cvg_strt_dt,
	p_rec.alws_dpnt_dsgn_flag,
	p_rec.dpnt_dsgn_cd,
	p_rec.ler_chg_dpnt_cvg_cd,
	p_rec.erlst_deenrt_dt,
	p_rec.procg_end_dt,
	p_rec.comp_lvl_cd,
	p_rec.pl_id,
	p_rec.oipl_id,
	p_rec.pgm_id,
	p_rec.plip_id,
	p_rec.ptip_id,
	p_rec.pl_typ_id,
	p_rec.oiplip_id,
	p_rec.cmbn_plip_id,
	p_rec.cmbn_ptip_id,
	p_rec.cmbn_ptip_opt_id,
        p_rec.assignment_id,
	p_rec.spcl_rt_pl_id,
	p_rec.spcl_rt_oipl_id,
	p_rec.must_enrl_anthr_pl_id,
	p_rec.int_elig_per_elctbl_chc_id,
	p_rec.prtt_enrt_rslt_id,
	p_rec.bnft_prvdr_pool_id,
	p_rec.per_in_ler_id,
	p_rec.yr_perd_id,
	p_rec.auto_enrt_flag,
	p_rec.business_group_id,
        p_rec.pl_ordr_num,
        p_rec.plip_ordr_num,
        p_rec.ptip_ordr_num,
        p_rec.oipl_ordr_num,
        -- cwb
        p_rec.comments,
        p_rec.elig_flag,
        p_rec.elig_ovrid_dt,
        p_rec.elig_ovrid_person_id,
        p_rec.inelig_rsn_cd,
        p_rec.mgr_ovrid_dt,
        p_rec.mgr_ovrid_person_id,
        p_rec.ws_mgr_id,
        -- cwb
	p_rec.epe_attribute_category,
	p_rec.epe_attribute1,
	p_rec.epe_attribute2,
	p_rec.epe_attribute3,
	p_rec.epe_attribute4,
	p_rec.epe_attribute5,
	p_rec.epe_attribute6,
	p_rec.epe_attribute7,
	p_rec.epe_attribute8,
	p_rec.epe_attribute9,
	p_rec.epe_attribute10,
	p_rec.epe_attribute11,
	p_rec.epe_attribute12,
	p_rec.epe_attribute13,
	p_rec.epe_attribute14,
	p_rec.epe_attribute15,
	p_rec.epe_attribute16,
	p_rec.epe_attribute17,
	p_rec.epe_attribute18,
	p_rec.epe_attribute19,
	p_rec.epe_attribute20,
	p_rec.epe_attribute21,
	p_rec.epe_attribute22,
	p_rec.epe_attribute23,
	p_rec.epe_attribute24,
	p_rec.epe_attribute25,
	p_rec.epe_attribute26,
	p_rec.epe_attribute27,
	p_rec.epe_attribute28,
	p_rec.epe_attribute29,
	p_rec.epe_attribute30,
	p_rec.approval_status_cd,
        p_rec.fonm_cvg_strt_dt,
        p_rec.cryfwd_elig_dpnt_cd,
	p_rec.request_id,
	p_rec.program_application_id,
	p_rec.program_id,
	p_rec.program_update_date,
	p_rec.object_version_number
  );
  --
  ben_epe_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_epe_shd.g_api_dml := false;   -- Unset the api dml status
    ben_epe_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ben_epe_shd.g_api_dml := false;   -- Unset the api dml status
    ben_epe_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_epe_shd.g_api_dml := false;   -- Unset the api dml status
    ben_epe_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_epe_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_insert(p_rec  in out nocopy ben_epe_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
--
  Cursor C_Sel1 is select ben_elig_per_elctbl_chc_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.elig_per_elctbl_chc_id;
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
Procedure post_insert(p_rec in ben_epe_shd.g_rec_type) is
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
  (
  p_effective_date               in date,
  p_rec        in out nocopy ben_epe_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  ben_epe_bus.insert_validate(p_rec,p_effective_date);
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
  post_insert(p_rec);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_effective_date               in date,
  p_elig_per_elctbl_chc_id       out nocopy number,
--  p_enrt_typ_cycl_cd             in varchar2         default null,
  p_enrt_cvg_strt_dt_cd          in varchar2         default null,
--  p_enrt_perd_end_dt             in date             default null,
-- p_enrt_perd_strt_dt            in date             default null,
  p_enrt_cvg_strt_dt_rl          in varchar2         default null,
--  p_rt_strt_dt                   in date             default null,
--  p_rt_strt_dt_rl                in varchar2         default null,
--  p_rt_strt_dt_cd                in varchar2         default null,
  p_ctfn_rqd_flag                in varchar2,
  p_pil_elctbl_chc_popl_id       in number,
  p_roll_crs_flag                in varchar2         default null,
  p_crntly_enrd_flag             in varchar2,
  p_dflt_flag                    in varchar2,
  p_elctbl_flag                  in varchar2,
  p_mndtry_flag                  in varchar2,
  p_in_pndg_wkflow_flag          in varchar2        default 'N',
--  p_dflt_enrt_dt                 in date             default null,
  p_dpnt_cvg_strt_dt_cd          in varchar2         default null,
  p_dpnt_cvg_strt_dt_rl          in varchar2         default null,
  p_enrt_cvg_strt_dt             in date             default null,
  p_alws_dpnt_dsgn_flag          in varchar2,
  p_dpnt_dsgn_cd                 in varchar2         default null,
  p_ler_chg_dpnt_cvg_cd          in varchar2         default null,
  p_erlst_deenrt_dt              in date             default null,
  p_procg_end_dt                 in date             default null,
  p_comp_lvl_cd                  in varchar2         default null,
  p_pl_id                        in number,
  p_oipl_id                      in number           default null,
  p_pgm_id                       in number           default null,
  p_plip_id                      in number           default null,
  p_ptip_id                      in number           default null,
  p_pl_typ_id                    in number           default null,
  p_oiplip_id                    in number           default null,
  p_cmbn_plip_id                 in number           default null,
  p_cmbn_ptip_id                 in number           default null,
  p_cmbn_ptip_opt_id             in number           default null,
  p_assignment_id                in number           default null,
  p_spcl_rt_pl_id                in number,
  p_spcl_rt_oipl_id              in number,
  p_must_enrl_anthr_pl_id        in number,
  p_int_elig_per_elctbl_chc_id in number,
  p_prtt_enrt_rslt_id            in number           default null,
  p_bnft_prvdr_pool_id           in number,
  p_per_in_ler_id                in number,
  p_yr_perd_id                   in number           default null,
  p_auto_enrt_flag               in varchar2         default null,
  p_business_group_id            in number,
  p_pl_ordr_num                  in number           default null,
  p_plip_ordr_num                  in number           default null,
  p_ptip_ordr_num                  in number           default null,
  p_oipl_ordr_num                  in number           default null,
  -- cwb
  p_comments                        in  varchar2       default null,
  p_elig_flag                       in  varchar2       default null,
  p_elig_ovrid_dt                   in  date           default null,
  p_elig_ovrid_person_id            in  number         default null,
  p_inelig_rsn_cd                   in  varchar2       default null,
  p_mgr_ovrid_dt                    in  date           default null,
  p_mgr_ovrid_person_id             in  number         default null,
  p_ws_mgr_id                       in  number         default null,
  -- cwb
  p_epe_attribute_category       in varchar2         default null,
  p_epe_attribute1               in varchar2         default null,
  p_epe_attribute2               in varchar2         default null,
  p_epe_attribute3               in varchar2         default null,
  p_epe_attribute4               in varchar2         default null,
  p_epe_attribute5               in varchar2         default null,
  p_epe_attribute6               in varchar2         default null,
  p_epe_attribute7               in varchar2         default null,
  p_epe_attribute8               in varchar2         default null,
  p_epe_attribute9               in varchar2         default null,
  p_epe_attribute10              in varchar2         default null,
  p_epe_attribute11              in varchar2         default null,
  p_epe_attribute12              in varchar2         default null,
  p_epe_attribute13              in varchar2         default null,
  p_epe_attribute14              in varchar2         default null,
  p_epe_attribute15              in varchar2         default null,
  p_epe_attribute16              in varchar2         default null,
  p_epe_attribute17              in varchar2         default null,
  p_epe_attribute18              in varchar2         default null,
  p_epe_attribute19              in varchar2         default null,
  p_epe_attribute20              in varchar2         default null,
  p_epe_attribute21              in varchar2         default null,
  p_epe_attribute22              in varchar2         default null,
  p_epe_attribute23              in varchar2         default null,
  p_epe_attribute24              in varchar2         default null,
  p_epe_attribute25              in varchar2         default null,
  p_epe_attribute26              in varchar2         default null,
  p_epe_attribute27              in varchar2         default null,
  p_epe_attribute28              in varchar2         default null,
  p_epe_attribute29              in varchar2         default null,
  p_epe_attribute30              in varchar2         default null,
  p_approval_status_cd              in varchar2         default null,
  p_fonm_cvg_strt_dt              in date            default null,
  p_cryfwd_elig_dpnt_cd          in varchar2         default null,
  p_request_id                   in number           default null,
  p_program_application_id       in number           default null,
  p_program_id                   in number           default null,
  p_program_update_date          in date             default null,
  p_object_version_number        out nocopy number
  ) is
--
  l_rec	  ben_epe_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ben_epe_shd.convert_args
  (
  null,
-- p_enrt_typ_cycl_cd,
  p_enrt_cvg_strt_dt_cd,
--  p_enrt_perd_end_dt,
-- p_enrt_perd_strt_dt,
  p_enrt_cvg_strt_dt_rl,
--  p_rt_strt_dt,
--  p_rt_strt_dt_rl,
--  p_rt_strt_dt_cd,
  p_ctfn_rqd_flag,
  p_pil_elctbl_chc_popl_id,
  p_roll_crs_flag,
  p_crntly_enrd_flag,
  p_dflt_flag,
  p_elctbl_flag,
  p_mndtry_flag,
  p_in_pndg_wkflow_flag,
--  p_dflt_enrt_dt,
  p_dpnt_cvg_strt_dt_cd,
  p_dpnt_cvg_strt_dt_rl,
  p_enrt_cvg_strt_dt,
  p_alws_dpnt_dsgn_flag,
  p_dpnt_dsgn_cd,
  p_ler_chg_dpnt_cvg_cd,
  p_erlst_deenrt_dt,
  p_procg_end_dt,
  p_comp_lvl_cd,
  p_pl_id,
  p_oipl_id,
  p_pgm_id,
  p_plip_id,
  p_ptip_id,
  p_pl_typ_id,
  p_oiplip_id,
  p_cmbn_plip_id,
  p_cmbn_ptip_id,
  p_cmbn_ptip_opt_id,
  p_assignment_id,
  p_spcl_rt_pl_id,
  p_spcl_rt_oipl_id,
  p_must_enrl_anthr_pl_id,
  p_int_elig_per_elctbl_chc_id,
  p_prtt_enrt_rslt_id,
  p_bnft_prvdr_pool_id,
  p_per_in_ler_id,
  p_yr_perd_id,
  p_auto_enrt_flag,
  p_business_group_id,
  p_pl_ordr_num,
  p_plip_ordr_num,
  p_ptip_ordr_num,
  p_oipl_ordr_num,
  -- cwb
  p_comments,
  p_elig_flag,
  p_elig_ovrid_dt,
  p_elig_ovrid_person_id,
  p_inelig_rsn_cd,
  p_mgr_ovrid_dt,
  p_mgr_ovrid_person_id,
  p_ws_mgr_id,
  -- cwb
  p_epe_attribute_category,
  p_epe_attribute1,
  p_epe_attribute2,
  p_epe_attribute3,
  p_epe_attribute4,
  p_epe_attribute5,
  p_epe_attribute6,
  p_epe_attribute7,
  p_epe_attribute8,
  p_epe_attribute9,
  p_epe_attribute10,
  p_epe_attribute11,
  p_epe_attribute12,
  p_epe_attribute13,
  p_epe_attribute14,
  p_epe_attribute15,
  p_epe_attribute16,
  p_epe_attribute17,
  p_epe_attribute18,
  p_epe_attribute19,
  p_epe_attribute20,
  p_epe_attribute21,
  p_epe_attribute22,
  p_epe_attribute23,
  p_epe_attribute24,
  p_epe_attribute25,
  p_epe_attribute26,
  p_epe_attribute27,
  p_epe_attribute28,
  p_epe_attribute29,
  p_epe_attribute30,
  p_approval_status_cd,
  p_fonm_cvg_strt_dt,
  p_cryfwd_elig_dpnt_cd,
  p_request_id,
  p_program_application_id,
  p_program_id,
  p_program_update_date,
  null
  );
  --
  -- Having converted the arguments into the ben_epe_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(p_effective_date,l_rec);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_elig_per_elctbl_chc_id := l_rec.elig_per_elctbl_chc_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ben_epe_ins;

/
