--------------------------------------------------------
--  DDL for Package Body BEN_ENP_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_ENP_INS" as
/* $Header: beenprhi.pkb 120.1.12000000.3 2007/05/13 22:36:53 rtagarra noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_enp_ins.';  -- Global package name
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
Procedure insert_dml(p_rec in out nocopy ben_enp_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  ben_enp_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ben_enrt_perd
  --
  insert into ben_enrt_perd
  (	enrt_perd_id,
	business_group_id,
	yr_perd_id,
	popl_enrt_typ_cycl_id,
	end_dt,
	strt_dt,
        asnd_lf_evt_dt ,
	cls_enrt_dt_to_use_cd,
	dflt_enrt_dt,
	enrt_cvg_strt_dt_cd,
	rt_strt_dt_rl,
	enrt_cvg_end_dt_cd,
	enrt_cvg_strt_dt_rl,
	enrt_cvg_end_dt_rl,
	procg_end_dt,
	rt_strt_dt_cd,
	rt_end_dt_cd,
	rt_end_dt_rl,
        bdgt_upd_strt_dt,
        bdgt_upd_end_dt,
        ws_upd_strt_dt,
        ws_upd_end_dt,
        dflt_ws_acc_cd,
        prsvr_bdgt_cd,
        uses_bdgt_flag,
        auto_distr_flag,
        hrchy_to_use_cd,
        pos_structure_version_id,
        emp_interview_type_cd,
        wthn_yr_perd_id,
        ler_id,
        perf_revw_strt_dt,
        asg_updt_eff_date,
	enp_attribute_category,
	enp_attribute1,
	enp_attribute2,
	enp_attribute3,
	enp_attribute4,
	enp_attribute5,
	enp_attribute6,
	enp_attribute7,
	enp_attribute8,
	enp_attribute9,
	enp_attribute10,
	enp_attribute11,
	enp_attribute12,
	enp_attribute13,
	enp_attribute14,
	enp_attribute15,
	enp_attribute16,
	enp_attribute17,
	enp_attribute18,
	enp_attribute19,
	enp_attribute20,
	enp_attribute21,
	enp_attribute22,
	enp_attribute23,
	enp_attribute24,
	enp_attribute25,
	enp_attribute26,
	enp_attribute27,
	enp_attribute28,
	enp_attribute29,
	enp_attribute30,
	enrt_perd_det_ovrlp_bckdt_cd,
        --cwb
        data_freeze_date   ,
        Sal_chg_reason_cd ,
        Approval_mode_cd ,
        hrchy_ame_trn_cd,
        hrchy_rl     ,
        hrchy_ame_app_id ,
	object_version_number,
	reinstate_cd,
	reinstate_ovrdn_cd,
	defer_deenrol_flag
  )
  Values
  (	p_rec.enrt_perd_id,
	p_rec.business_group_id,
	p_rec.yr_perd_id,
	p_rec.popl_enrt_typ_cycl_id,
	p_rec.end_dt,
	p_rec.strt_dt,
        p_rec.asnd_lf_evt_dt,
	p_rec.cls_enrt_dt_to_use_cd,
	p_rec.dflt_enrt_dt,
	p_rec.enrt_cvg_strt_dt_cd,
	p_rec.rt_strt_dt_rl,
	p_rec.enrt_cvg_end_dt_cd,
	p_rec.enrt_cvg_strt_dt_rl,
	p_rec.enrt_cvg_end_dt_rl,
	p_rec.procg_end_dt,
	p_rec.rt_strt_dt_cd,
	p_rec.rt_end_dt_cd,
	p_rec.rt_end_dt_rl,
        p_rec.bdgt_upd_strt_dt,
        p_rec.bdgt_upd_end_dt,
        p_rec.ws_upd_strt_dt,
        p_rec.ws_upd_end_dt,
        p_rec.dflt_ws_acc_cd,
        p_rec.prsvr_bdgt_cd,
        p_rec.uses_bdgt_flag,
        p_rec.auto_distr_flag,
        p_rec.hrchy_to_use_cd,
        p_rec.pos_structure_version_id,
        p_rec.emp_interview_type_cd,
        p_rec.wthn_yr_perd_id,
        p_rec.ler_id,
        p_rec.perf_revw_strt_dt,
        p_rec.asg_updt_eff_date,
	p_rec.enp_attribute_category,
	p_rec.enp_attribute1,
	p_rec.enp_attribute2,
	p_rec.enp_attribute3,
	p_rec.enp_attribute4,
	p_rec.enp_attribute5,
	p_rec.enp_attribute6,
	p_rec.enp_attribute7,
	p_rec.enp_attribute8,
	p_rec.enp_attribute9,
	p_rec.enp_attribute10,
	p_rec.enp_attribute11,
	p_rec.enp_attribute12,
	p_rec.enp_attribute13,
	p_rec.enp_attribute14,
	p_rec.enp_attribute15,
	p_rec.enp_attribute16,
	p_rec.enp_attribute17,
	p_rec.enp_attribute18,
	p_rec.enp_attribute19,
	p_rec.enp_attribute20,
	p_rec.enp_attribute21,
	p_rec.enp_attribute22,
	p_rec.enp_attribute23,
	p_rec.enp_attribute24,
	p_rec.enp_attribute25,
	p_rec.enp_attribute26,
	p_rec.enp_attribute27,
	p_rec.enp_attribute28,
	p_rec.enp_attribute29,
	p_rec.enp_attribute30,
	p_rec.enrt_perd_det_ovrlp_bckdt_cd,
         --cwb
        p_rec.data_freeze_date   ,
        p_rec.Sal_chg_reason_cd ,
        p_rec.Approval_mode_cd ,
        p_rec.hrchy_ame_trn_cd,
        p_rec.hrchy_rl     ,
        p_rec.hrchy_ame_app_id ,
	p_rec.object_version_number ,
	p_rec.reinstate_cd,
	p_rec.reinstate_ovrdn_cd,
	p_rec.defer_deenrol_flag
  );
  --
  ben_enp_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_enp_shd.g_api_dml := false;   -- Unset the api dml status
    ben_enp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ben_enp_shd.g_api_dml := false;   -- Unset the api dml status
    ben_enp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_enp_shd.g_api_dml := false;   -- Unset the api dml status
    ben_enp_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_enp_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_insert(p_rec  in out nocopy ben_enp_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select ben_enrt_perd_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.enrt_perd_id;
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
Procedure post_insert(
p_effective_date in date,p_rec in ben_enp_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_insert';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  --
  -- Start of API User Hook for post_insert.
  --
  begin
    --
    ben_enp_rki.after_insert
      (
  p_enrt_perd_id                  =>p_rec.enrt_perd_id
 ,p_business_group_id             =>p_rec.business_group_id
 ,p_yr_perd_id                    =>p_rec.yr_perd_id
 ,p_popl_enrt_typ_cycl_id         =>p_rec.popl_enrt_typ_cycl_id
 ,p_end_dt                        =>p_rec.end_dt
 ,p_strt_dt                       =>p_rec.strt_dt
 ,p_asnd_lf_evt_dt                =>p_rec.asnd_lf_evt_dt
 ,p_cls_enrt_dt_to_use_cd         =>p_rec.cls_enrt_dt_to_use_cd
 ,p_dflt_enrt_dt                  =>p_rec.dflt_enrt_dt
 ,p_enrt_cvg_strt_dt_cd           =>p_rec.enrt_cvg_strt_dt_cd
 ,p_rt_strt_dt_rl                 =>p_rec.rt_strt_dt_rl
 ,p_enrt_cvg_end_dt_cd            =>p_rec.enrt_cvg_end_dt_cd
 ,p_enrt_cvg_strt_dt_rl           =>p_rec.enrt_cvg_strt_dt_rl
 ,p_enrt_cvg_end_dt_rl            =>p_rec.enrt_cvg_end_dt_rl
 ,p_procg_end_dt                  =>p_rec.procg_end_dt
 ,p_rt_strt_dt_cd                 =>p_rec.rt_strt_dt_cd
 ,p_rt_end_dt_cd                  =>p_rec.rt_end_dt_cd
 ,p_rt_end_dt_rl                  =>p_rec.rt_end_dt_rl
 ,p_bdgt_upd_strt_dt              =>p_rec.bdgt_upd_strt_dt
 ,p_bdgt_upd_end_dt               =>p_rec.bdgt_upd_end_dt
 ,p_ws_upd_strt_dt                =>p_rec.ws_upd_strt_dt
 ,p_ws_upd_end_dt                 =>p_rec.ws_upd_end_dt
 ,p_dflt_ws_acc_cd                =>p_rec.dflt_ws_acc_cd
 ,p_prsvr_bdgt_cd                 =>p_rec.prsvr_bdgt_cd
 ,p_uses_bdgt_flag                =>p_rec.uses_bdgt_flag
 ,p_auto_distr_flag               =>p_rec.auto_distr_flag
 ,p_hrchy_to_use_cd               =>p_rec.hrchy_to_use_cd
 ,p_pos_structure_version_id         =>p_rec.pos_structure_version_id
 ,p_emp_interview_type_cd         =>p_rec.emp_interview_type_cd
 ,p_wthn_yr_perd_id               =>p_rec.wthn_yr_perd_id
 ,p_ler_id                        =>p_rec.ler_id
 ,p_perf_revw_strt_dt             =>p_rec.perf_revw_strt_dt
 ,p_asg_updt_eff_date             =>p_rec.asg_updt_eff_date
 ,p_enp_attribute_category        =>p_rec.enp_attribute_category
 ,p_enp_attribute1                =>p_rec.enp_attribute1
 ,p_enp_attribute2                =>p_rec.enp_attribute2
 ,p_enp_attribute3                =>p_rec.enp_attribute3
 ,p_enp_attribute4                =>p_rec.enp_attribute4
 ,p_enp_attribute5                =>p_rec.enp_attribute5
 ,p_enp_attribute6                =>p_rec.enp_attribute6
 ,p_enp_attribute7                =>p_rec.enp_attribute7
 ,p_enp_attribute8                =>p_rec.enp_attribute8
 ,p_enp_attribute9                =>p_rec.enp_attribute9
 ,p_enp_attribute10               =>p_rec.enp_attribute10
 ,p_enp_attribute11               =>p_rec.enp_attribute11
 ,p_enp_attribute12               =>p_rec.enp_attribute12
 ,p_enp_attribute13               =>p_rec.enp_attribute13
 ,p_enp_attribute14               =>p_rec.enp_attribute14
 ,p_enp_attribute15               =>p_rec.enp_attribute15
 ,p_enp_attribute16               =>p_rec.enp_attribute16
 ,p_enp_attribute17               =>p_rec.enp_attribute17
 ,p_enp_attribute18               =>p_rec.enp_attribute18
 ,p_enp_attribute19               =>p_rec.enp_attribute19
 ,p_enp_attribute20               =>p_rec.enp_attribute20
 ,p_enp_attribute21               =>p_rec.enp_attribute21
 ,p_enp_attribute22               =>p_rec.enp_attribute22
 ,p_enp_attribute23               =>p_rec.enp_attribute23
 ,p_enp_attribute24               =>p_rec.enp_attribute24
 ,p_enp_attribute25               =>p_rec.enp_attribute25
 ,p_enp_attribute26               =>p_rec.enp_attribute26
 ,p_enp_attribute27               =>p_rec.enp_attribute27
 ,p_enp_attribute28               =>p_rec.enp_attribute28
 ,p_enp_attribute29               =>p_rec.enp_attribute29
 ,p_enp_attribute30               =>p_rec.enp_attribute30
 ,p_enrt_perd_det_ovrlp_bckdt_cd  =>p_rec.enrt_perd_det_ovrlp_bckdt_cd
    --cwb
 ,p_data_freeze_date              =>p_rec.data_freeze_date
 ,p_Sal_chg_reason_cd             =>p_rec.Sal_chg_reason_cd
 ,p_Approval_mode_cd              =>p_rec.Approval_mode_cd
 ,p_hrchy_ame_trn_cd              =>p_rec.hrchy_ame_trn_cd
 ,p_hrchy_rl                      =>p_rec.hrchy_rl
 ,p_hrchy_ame_app_id              =>p_rec.hrchy_ame_app_id
  --
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_effective_date                =>p_effective_date
 ,p_reinstate_cd		  =>p_rec.reinstate_cd
 ,p_reinstate_ovrdn_cd		  =>p_rec.reinstate_ovrdn_cd
 ,p_defer_deenrol_flag            =>p_rec.defer_deenrol_flag
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_enrt_perd'
        ,p_hook_type   => 'AI');
      --
  end;
  --
  -- End of API User Hook for post_insert.
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_effective_date in date,
  p_rec        in out nocopy ben_enp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  ben_enp_bus.insert_validate(p_rec
                             ,p_effective_date);
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
  post_insert(
p_effective_date,p_rec);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_effective_date in date,
  p_enrt_perd_id                 out nocopy number,
  p_business_group_id            in number,
  p_yr_perd_id                   in number,
  p_popl_enrt_typ_cycl_id        in number,
  p_end_dt                       in date,
  p_strt_dt                      in date,
  p_asnd_lf_evt_dt               in date,
  p_cls_enrt_dt_to_use_cd        in varchar2         ,
  p_dflt_enrt_dt                 in date             ,
  p_enrt_cvg_strt_dt_cd          in varchar2         ,
  p_rt_strt_dt_rl                in number           ,
  p_enrt_cvg_end_dt_cd           in varchar2         ,
  p_enrt_cvg_strt_dt_rl          in number           ,
  p_enrt_cvg_end_dt_rl           in number           ,
  p_procg_end_dt                 in date,
  p_rt_strt_dt_cd                in varchar2         ,
  p_rt_end_dt_cd                 in varchar2         ,
  p_rt_end_dt_rl                 in number           ,
  p_bdgt_upd_strt_dt             in  date            ,
  p_bdgt_upd_end_dt              in  date            ,
  p_ws_upd_strt_dt               in  date            ,
  p_ws_upd_end_dt                in  date            ,
  p_dflt_ws_acc_cd               in  varchar2        ,
  p_prsvr_bdgt_cd                in  varchar2        ,
  p_uses_bdgt_flag               in  varchar2        ,
  p_auto_distr_flag              in  varchar2        ,
  p_hrchy_to_use_cd              in  varchar2        ,
  p_pos_structure_version_id        in  number       ,
  p_emp_interview_type_cd        in  varchar2        ,
  p_wthn_yr_perd_id              in  number          ,
  p_ler_id                       in  number          ,
  p_perf_revw_strt_dt            in date             ,
  p_asg_updt_eff_date            in date             ,
  p_enp_attribute_category       in varchar2         ,
  p_enp_attribute1               in varchar2         ,
  p_enp_attribute2               in varchar2         ,
  p_enp_attribute3               in varchar2         ,
  p_enp_attribute4               in varchar2         ,
  p_enp_attribute5               in varchar2         ,
  p_enp_attribute6               in varchar2         ,
  p_enp_attribute7               in varchar2         ,
  p_enp_attribute8               in varchar2         ,
  p_enp_attribute9               in varchar2         ,
  p_enp_attribute10              in varchar2         ,
  p_enp_attribute11              in varchar2         ,
  p_enp_attribute12              in varchar2         ,
  p_enp_attribute13              in varchar2         ,
  p_enp_attribute14              in varchar2         ,
  p_enp_attribute15              in varchar2         ,
  p_enp_attribute16              in varchar2         ,
  p_enp_attribute17              in varchar2         ,
  p_enp_attribute18              in varchar2         ,
  p_enp_attribute19              in varchar2         ,
  p_enp_attribute20              in varchar2         ,
  p_enp_attribute21              in varchar2         ,
  p_enp_attribute22              in varchar2         ,
  p_enp_attribute23              in varchar2         ,
  p_enp_attribute24              in varchar2         ,
  p_enp_attribute25              in varchar2         ,
  p_enp_attribute26              in varchar2         ,
  p_enp_attribute27              in varchar2         ,
  p_enp_attribute28              in varchar2         ,
  p_enp_attribute29              in varchar2         ,
  p_enp_attribute30              in varchar2         ,
  p_enrt_perd_det_ovrlp_bckdt_cd in varchar2         ,
  --cwb
  p_data_freeze_date               in  date    ,
  p_Sal_chg_reason_cd              in  varchar2,
  p_Approval_mode_cd               in  varchar2,
  p_hrchy_ame_trn_cd               in  varchar2,
  p_hrchy_rl                       in  number,
  p_hrchy_ame_app_id               in  number,
  --
  p_object_version_number        out nocopy number
  ,p_reinstate_cd		in varchar2
  ,p_reinstate_ovrdn_cd	in varchar2
  ,p_defer_deenrol_flag in varchar2
  ) is
--
  l_rec	  ben_enp_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ben_enp_shd.convert_args
  (
  null,
  p_business_group_id,
  p_yr_perd_id,
  p_popl_enrt_typ_cycl_id,
  p_end_dt,
  p_strt_dt,
  p_asnd_lf_evt_dt,
  p_cls_enrt_dt_to_use_cd,
  p_dflt_enrt_dt,
  p_enrt_cvg_strt_dt_cd,
  p_rt_strt_dt_rl,
  p_enrt_cvg_end_dt_cd,
  p_enrt_cvg_strt_dt_rl,
  p_enrt_cvg_end_dt_rl,
  p_procg_end_dt,
  p_rt_strt_dt_cd,
  p_rt_end_dt_cd,
  p_rt_end_dt_rl,
  p_bdgt_upd_strt_dt,
  p_bdgt_upd_end_dt,
  p_ws_upd_strt_dt,
  p_ws_upd_end_dt,
  p_dflt_ws_acc_cd,
  p_prsvr_bdgt_cd,
  p_uses_bdgt_flag,
  p_auto_distr_flag,
  p_hrchy_to_use_cd,
  p_pos_structure_version_id,
  p_emp_interview_type_cd,
  p_wthn_yr_perd_id,
  p_ler_id,
  p_perf_revw_strt_dt,
  p_asg_updt_eff_date,
  p_enp_attribute_category,
  p_enp_attribute1,
  p_enp_attribute2,
  p_enp_attribute3,
  p_enp_attribute4,
  p_enp_attribute5,
  p_enp_attribute6,
  p_enp_attribute7,
  p_enp_attribute8,
  p_enp_attribute9,
  p_enp_attribute10,
  p_enp_attribute11,
  p_enp_attribute12,
  p_enp_attribute13,
  p_enp_attribute14,
  p_enp_attribute15,
  p_enp_attribute16,
  p_enp_attribute17,
  p_enp_attribute18,
  p_enp_attribute19,
  p_enp_attribute20,
  p_enp_attribute21,
  p_enp_attribute22,
  p_enp_attribute23,
  p_enp_attribute24,
  p_enp_attribute25,
  p_enp_attribute26,
  p_enp_attribute27,
  p_enp_attribute28,
  p_enp_attribute29,
  p_enp_attribute30,
  p_enrt_perd_det_ovrlp_bckdt_cd,
  --cwb
  p_data_freeze_date    ,
  p_Sal_chg_reason_cd   ,
  p_Approval_mode_cd    ,
  p_hrchy_ame_trn_cd    ,
  p_hrchy_rl            ,
  p_hrchy_ame_app_id
  , null              -- bug 4341773 :p_reinstate_cd was passed to object_version_number.
  ,p_reinstate_cd
  ,p_reinstate_ovrdn_cd
  --
  ,p_defer_deenrol_flag
  );
  --
  -- Having converted the arguments into the ben_enp_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(
    p_effective_date,l_rec);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_enrt_perd_id := l_rec.enrt_perd_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ben_enp_ins;

/
