--------------------------------------------------------
--  DDL for Package Body BEN_PEL_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PEL_INS" as
/* $Header: bepelrhi.pkb 120.3.12000000.2 2007/05/13 23:02:25 rtagarra noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_pel_ins.';  -- Global package name
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
Procedure insert_dml(p_rec in out nocopy ben_pel_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'insert_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  ben_pel_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Insert the row into: ben_pil_elctbl_chc_popl
  --
  insert into ben_pil_elctbl_chc_popl
  ( pil_elctbl_chc_popl_id,
    dflt_enrt_dt,
    dflt_asnd_dt,
    elcns_made_dt,
    cls_enrt_dt_to_use_cd,
    enrt_typ_cycl_cd,
    enrt_perd_end_dt,
    enrt_perd_strt_dt,
    procg_end_dt,
    pil_elctbl_popl_stat_cd,
    acty_ref_perd_cd,
    uom,
    comments,
    mgr_ovrid_dt,
    ws_mgr_id,
    mgr_ovrid_person_id,
    assignment_id,
        --cwb
        bdgt_acc_cd,
        pop_cd,
        bdgt_due_dt,
        bdgt_export_flag,
        bdgt_iss_dt,
        bdgt_stat_cd,
        ws_acc_cd,
        ws_due_dt,
        ws_export_flag,
        ws_iss_dt,
        ws_stat_cd,
        --cwb
        reinstate_cd,
        reinstate_ovrdn_cd,
    auto_asnd_dt,
        cbr_elig_perd_strt_dt,
        cbr_elig_perd_end_dt,
    lee_rsn_id,
    enrt_perd_id,
    per_in_ler_id,
    pgm_id,
    pl_id,
    business_group_id,
    pel_attribute_category,
    pel_attribute1,
    pel_attribute2,
    pel_attribute3,
    pel_attribute4,
    pel_attribute5,
    pel_attribute6,
    pel_attribute7,
    pel_attribute8,
    pel_attribute9,
    pel_attribute10,
    pel_attribute11,
    pel_attribute12,
    pel_attribute13,
    pel_attribute14,
    pel_attribute15,
    pel_attribute16,
    pel_attribute17,
    pel_attribute18,
    pel_attribute19,
    pel_attribute20,
    pel_attribute21,
    pel_attribute22,
    pel_attribute23,
    pel_attribute24,
    pel_attribute25,
    pel_attribute26,
    pel_attribute27,
    pel_attribute28,
    pel_attribute29,
    pel_attribute30,
    request_id,
    program_application_id,
    program_id,
    program_update_date,
    object_version_number,
    defer_deenrol_flag,
    deenrol_made_dt
  )
  Values
  ( p_rec.pil_elctbl_chc_popl_id,
    p_rec.dflt_enrt_dt,
    p_rec.dflt_asnd_dt,
    p_rec.elcns_made_dt,
    p_rec.cls_enrt_dt_to_use_cd,
    p_rec.enrt_typ_cycl_cd,
    p_rec.enrt_perd_end_dt,
    p_rec.enrt_perd_strt_dt,
    p_rec.procg_end_dt,
    p_rec.pil_elctbl_popl_stat_cd,
    p_rec.acty_ref_perd_cd,
    p_rec.uom,
    p_rec.comments,
    p_rec.mgr_ovrid_dt,
    p_rec.ws_mgr_id,
    p_rec.mgr_ovrid_person_id,
    p_rec.assignment_id,
        --cwb
        p_rec.bdgt_acc_cd,
        p_rec.pop_cd,
        p_rec.bdgt_due_dt,
        p_rec.bdgt_export_flag,
        p_rec.bdgt_iss_dt,
        p_rec.bdgt_stat_cd,
        p_rec.ws_acc_cd,
        p_rec.ws_due_dt,
        p_rec.ws_export_flag,
        p_rec.ws_iss_dt,
        p_rec.ws_stat_cd,
        --cwb
        p_rec.reinstate_cd,
        p_rec.reinstate_ovrdn_cd,
    p_rec.auto_asnd_dt,
        p_rec.cbr_elig_perd_strt_dt,
        p_rec.cbr_elig_perd_end_dt,
    p_rec.lee_rsn_id,
    p_rec.enrt_perd_id,
    p_rec.per_in_ler_id,
    p_rec.pgm_id,
    p_rec.pl_id,
    p_rec.business_group_id,
    p_rec.pel_attribute_category,
    p_rec.pel_attribute1,
    p_rec.pel_attribute2,
    p_rec.pel_attribute3,
    p_rec.pel_attribute4,
    p_rec.pel_attribute5,
    p_rec.pel_attribute6,
    p_rec.pel_attribute7,
    p_rec.pel_attribute8,
    p_rec.pel_attribute9,
    p_rec.pel_attribute10,
    p_rec.pel_attribute11,
    p_rec.pel_attribute12,
    p_rec.pel_attribute13,
    p_rec.pel_attribute14,
    p_rec.pel_attribute15,
    p_rec.pel_attribute16,
    p_rec.pel_attribute17,
    p_rec.pel_attribute18,
    p_rec.pel_attribute19,
    p_rec.pel_attribute20,
    p_rec.pel_attribute21,
    p_rec.pel_attribute22,
    p_rec.pel_attribute23,
    p_rec.pel_attribute24,
    p_rec.pel_attribute25,
    p_rec.pel_attribute26,
    p_rec.pel_attribute27,
    p_rec.pel_attribute28,
    p_rec.pel_attribute29,
    p_rec.pel_attribute30,
    p_rec.request_id,
    p_rec.program_application_id,
    p_rec.program_id,
    p_rec.program_update_date,
    p_rec.object_version_number,
    p_rec.defer_deenrol_flag,
    p_rec.deenrol_made_dt
  );
  --
  ben_pel_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ben_pel_shd.g_api_dml := false;   -- Unset the api dml status
    ben_pel_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ben_pel_shd.g_api_dml := false;   -- Unset the api dml status
    ben_pel_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ben_pel_shd.g_api_dml := false;   -- Unset the api dml status
    ben_pel_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_pel_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_insert(p_rec  in out nocopy ben_pel_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 is select ben_pil_elctbl_chc_popl_s.nextval from sys.dual;
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence number
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.pil_elctbl_chc_popl_id;
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
p_effective_date in date,p_rec in ben_pel_shd.g_rec_type) is
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
    ben_pel_rki.after_insert
      (
  p_pil_elctbl_chc_popl_id        =>p_rec.pil_elctbl_chc_popl_id
 ,p_dflt_enrt_dt                  =>p_rec.dflt_enrt_dt
 ,p_dflt_asnd_dt                  =>p_rec.dflt_asnd_dt
 ,p_elcns_made_dt                 =>p_rec.elcns_made_dt
 ,p_cls_enrt_dt_to_use_cd         =>p_rec.cls_enrt_dt_to_use_cd
 ,p_enrt_typ_cycl_cd              =>p_rec.enrt_typ_cycl_cd
 ,p_enrt_perd_end_dt              =>p_rec.enrt_perd_end_dt
 ,p_enrt_perd_strt_dt             =>p_rec.enrt_perd_strt_dt
 ,p_procg_end_dt                  =>p_rec.procg_end_dt
 ,p_pil_elctbl_popl_stat_cd       =>p_rec.pil_elctbl_popl_stat_cd
 ,p_acty_ref_perd_cd              =>p_rec.acty_ref_perd_cd
 ,p_uom                           =>p_rec.uom
 ,p_comments                           =>p_rec.comments
 ,p_mgr_ovrid_dt                           =>p_rec.mgr_ovrid_dt
 ,p_ws_mgr_id                           =>p_rec.ws_mgr_id
 ,p_mgr_ovrid_person_id                           =>p_rec.mgr_ovrid_person_id
 ,p_assignment_id                           =>p_rec.assignment_id
 --cwb
 ,p_bdgt_acc_cd                   => p_rec.bdgt_acc_cd
 ,p_pop_cd                        => p_rec.pop_cd
 ,p_bdgt_due_dt                   => p_rec.bdgt_due_dt
 ,p_bdgt_export_flag              => p_rec.bdgt_export_flag
 ,p_bdgt_iss_dt                   => p_rec.bdgt_iss_dt
 ,p_bdgt_stat_cd                  => p_rec.bdgt_stat_cd
 ,p_ws_acc_cd                     => p_rec.ws_acc_cd
 ,p_ws_due_dt                     => p_rec.ws_due_dt
 ,p_ws_export_flag                => p_rec.ws_export_flag
 ,p_ws_iss_dt                     => p_rec.ws_iss_dt
 ,p_ws_stat_cd                    => p_rec.ws_stat_cd
 --cwb
 ,p_reinstate_cd                  =>p_rec.reinstate_cd
 ,p_reinstate_ovrdn_cd            =>p_rec.reinstate_ovrdn_cd
 ,p_auto_asnd_dt                  =>p_rec.auto_asnd_dt
 ,p_cbr_elig_perd_strt_dt         =>p_rec.cbr_elig_perd_strt_dt
 ,p_cbr_elig_perd_end_dt          =>p_rec.cbr_elig_perd_end_dt
 ,p_lee_rsn_id                    =>p_rec.lee_rsn_id
 ,p_enrt_perd_id                  =>p_rec.enrt_perd_id
 ,p_per_in_ler_id                 =>p_rec.per_in_ler_id
 ,p_pgm_id                        =>p_rec.pgm_id
 ,p_pl_id                         =>p_rec.pl_id
 ,p_business_group_id             =>p_rec.business_group_id
 ,p_pel_attribute_category        =>p_rec.pel_attribute_category
 ,p_pel_attribute1                =>p_rec.pel_attribute1
 ,p_pel_attribute2                =>p_rec.pel_attribute2
 ,p_pel_attribute3                =>p_rec.pel_attribute3
 ,p_pel_attribute4                =>p_rec.pel_attribute4
 ,p_pel_attribute5                =>p_rec.pel_attribute5
 ,p_pel_attribute6                =>p_rec.pel_attribute6
 ,p_pel_attribute7                =>p_rec.pel_attribute7
 ,p_pel_attribute8                =>p_rec.pel_attribute8
 ,p_pel_attribute9                =>p_rec.pel_attribute9
 ,p_pel_attribute10               =>p_rec.pel_attribute10
 ,p_pel_attribute11               =>p_rec.pel_attribute11
 ,p_pel_attribute12               =>p_rec.pel_attribute12
 ,p_pel_attribute13               =>p_rec.pel_attribute13
 ,p_pel_attribute14               =>p_rec.pel_attribute14
 ,p_pel_attribute15               =>p_rec.pel_attribute15
 ,p_pel_attribute16               =>p_rec.pel_attribute16
 ,p_pel_attribute17               =>p_rec.pel_attribute17
 ,p_pel_attribute18               =>p_rec.pel_attribute18
 ,p_pel_attribute19               =>p_rec.pel_attribute19
 ,p_pel_attribute20               =>p_rec.pel_attribute20
 ,p_pel_attribute21               =>p_rec.pel_attribute21
 ,p_pel_attribute22               =>p_rec.pel_attribute22
 ,p_pel_attribute23               =>p_rec.pel_attribute23
 ,p_pel_attribute24               =>p_rec.pel_attribute24
 ,p_pel_attribute25               =>p_rec.pel_attribute25
 ,p_pel_attribute26               =>p_rec.pel_attribute26
 ,p_pel_attribute27               =>p_rec.pel_attribute27
 ,p_pel_attribute28               =>p_rec.pel_attribute28
 ,p_pel_attribute29               =>p_rec.pel_attribute29
 ,p_pel_attribute30               =>p_rec.pel_attribute30
 ,p_request_id                    =>p_rec.request_id
 ,p_program_application_id        =>p_rec.program_application_id
 ,p_program_id                    =>p_rec.program_id
 ,p_program_update_date           =>p_rec.program_update_date
 ,p_object_version_number         =>p_rec.object_version_number
 ,p_effective_date                =>p_effective_date
 ,p_defer_deenrol_flag		  =>p_rec.defer_deenrol_flag
 ,p_deenrol_made_dt               =>p_rec.deenrol_made_dt
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_pil_elctbl_chc_popl'
        ,p_hook_type   => 'AI');
      --
  end;
  --
  -- End of API User Hook for post_insert.
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
  p_rec        in out nocopy ben_pel_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  ben_pel_bus.insert_validate(p_rec
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
  post_insert(p_effective_date,p_rec);
  --
  -- added for dbi
  --
  -- DBI - Added DBI Event Logging Hooks
  /* Commented. Need to uncomment when DBI goes into mainline
  5554590 : Enabled DBI logging into mainline. */
  if HRI_BPL_BEN_UTIL.enable_ben_col_evt_que then
    HRI_OPL_BEN_ELCTN_EVNTS_EQ.insert_event (p_rec => p_rec ,
                                             p_pil_rec => null,
                                             p_called_from    => 'PEL' ,
                                             p_effective_date  => p_effective_date,
                                             p_datetrack_mode  => 'INSERT' );

  end if;
  --
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure ins
  (
  p_effective_date in date,
  p_pil_elctbl_chc_popl_id       out nocopy number,
  p_dflt_enrt_dt                 in date             default null,
  p_dflt_asnd_dt                 in date             default null,
  p_elcns_made_dt                in date             default null,
  p_cls_enrt_dt_to_use_cd        in varchar2         default null,
  p_enrt_typ_cycl_cd             in varchar2         default null,
  p_enrt_perd_end_dt             in date             default null,
  p_enrt_perd_strt_dt            in date             default null,
  p_procg_end_dt                 in date             default null,
  p_pil_elctbl_popl_stat_cd      in varchar2         default null,
  p_acty_ref_perd_cd             in varchar2         default null,
  p_uom                          in varchar2         default null,
  p_comments                          in varchar2         default null,
  p_mgr_ovrid_dt                          in date         default null,
  p_ws_mgr_id                          in number         default null,
  p_mgr_ovrid_person_id                          in number         default null,
  p_assignment_id                          in number         default null,
  --cwb
  p_bdgt_acc_cd                  in varchar2         default null,
  p_pop_cd                       in varchar2         default null,
  p_bdgt_due_dt                  in date             default null,
  p_bdgt_export_flag             in varchar2         default null,
  p_bdgt_iss_dt                  in date             default null,
  p_bdgt_stat_cd                 in varchar2         default null,
  p_ws_acc_cd                    in varchar2         default null,
  p_ws_due_dt                    in date             default null,
  p_ws_export_flag               in varchar2         default null,
  p_ws_iss_dt                    in date             default null,
  p_ws_stat_cd                   in varchar2         default null,
   --cwb
  p_reinstate_cd                 in varchar2         default null,
  p_reinstate_ovrdn_cd           in varchar2         default null,
  p_auto_asnd_dt                 in date             default null,
  p_cbr_elig_perd_strt_dt        in date             default null,
  p_cbr_elig_perd_end_dt         in date             default null,
  p_lee_rsn_id                   in number           default null,
  p_enrt_perd_id                 in number           default null,
  p_per_in_ler_id                in number,
  p_pgm_id                       in number           default null,
  p_pl_id                        in number           default null,
  p_business_group_id            in number           default null,
  p_pel_attribute_category       in varchar2         default null,
  p_pel_attribute1               in varchar2         default null,
  p_pel_attribute2               in varchar2         default null,
  p_pel_attribute3               in varchar2         default null,
  p_pel_attribute4               in varchar2         default null,
  p_pel_attribute5               in varchar2         default null,
  p_pel_attribute6               in varchar2         default null,
  p_pel_attribute7               in varchar2         default null,
  p_pel_attribute8               in varchar2         default null,
  p_pel_attribute9               in varchar2         default null,
  p_pel_attribute10              in varchar2         default null,
  p_pel_attribute11              in varchar2         default null,
  p_pel_attribute12              in varchar2         default null,
  p_pel_attribute13              in varchar2         default null,
  p_pel_attribute14              in varchar2         default null,
  p_pel_attribute15              in varchar2         default null,
  p_pel_attribute16              in varchar2         default null,
  p_pel_attribute17              in varchar2         default null,
  p_pel_attribute18              in varchar2         default null,
  p_pel_attribute19              in varchar2         default null,
  p_pel_attribute20              in varchar2         default null,
  p_pel_attribute21              in varchar2         default null,
  p_pel_attribute22              in varchar2         default null,
  p_pel_attribute23              in varchar2         default null,
  p_pel_attribute24              in varchar2         default null,
  p_pel_attribute25              in varchar2         default null,
  p_pel_attribute26              in varchar2         default null,
  p_pel_attribute27              in varchar2         default null,
  p_pel_attribute28              in varchar2         default null,
  p_pel_attribute29              in varchar2         default null,
  p_pel_attribute30              in varchar2         default null,
  p_request_id                   in number           default null,
  p_program_application_id       in number           default null,
  p_program_id                   in number           default null,
  p_program_update_date          in date             default null,
  p_object_version_number        out nocopy number,
  p_defer_deenrol_flag           in varchar2         default 'N',
  p_deenrol_made_dt              in date             default null
  ) is
--
  l_rec   ben_pel_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'ins';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  ben_pel_shd.convert_args
  (
  null,
  p_dflt_enrt_dt,
  p_dflt_asnd_dt,
  p_elcns_made_dt,
  p_cls_enrt_dt_to_use_cd,
  p_enrt_typ_cycl_cd,
  p_enrt_perd_end_dt,
  p_enrt_perd_strt_dt,
  p_procg_end_dt,
  p_pil_elctbl_popl_stat_cd,
  p_acty_ref_perd_cd,
  p_uom,
  p_comments,
  p_mgr_ovrid_dt,
  p_ws_mgr_id,
  p_mgr_ovrid_person_id,
  p_assignment_id,
  --cwb
  p_bdgt_acc_cd,
  p_pop_cd,
  p_bdgt_due_dt,
  p_bdgt_export_flag,
  p_bdgt_iss_dt,
  p_bdgt_stat_cd,
  p_ws_acc_cd,
  p_ws_due_dt,
  p_ws_export_flag,
  p_ws_iss_dt,
  p_ws_stat_cd,
  --cwb
  p_reinstate_cd,
  p_reinstate_ovrdn_cd,
  p_auto_asnd_dt,
  p_cbr_elig_perd_strt_dt,
  p_cbr_elig_perd_end_dt,
  p_lee_rsn_id,
  p_enrt_perd_id,
  p_per_in_ler_id,
  p_pgm_id,
  p_pl_id,
  p_business_group_id,
  p_pel_attribute_category,
  p_pel_attribute1,
  p_pel_attribute2,
  p_pel_attribute3,
  p_pel_attribute4,
  p_pel_attribute5,
  p_pel_attribute6,
  p_pel_attribute7,
  p_pel_attribute8,
  p_pel_attribute9,
  p_pel_attribute10,
  p_pel_attribute11,
  p_pel_attribute12,
  p_pel_attribute13,
  p_pel_attribute14,
  p_pel_attribute15,
  p_pel_attribute16,
  p_pel_attribute17,
  p_pel_attribute18,
  p_pel_attribute19,
  p_pel_attribute20,
  p_pel_attribute21,
  p_pel_attribute22,
  p_pel_attribute23,
  p_pel_attribute24,
  p_pel_attribute25,
  p_pel_attribute26,
  p_pel_attribute27,
  p_pel_attribute28,
  p_pel_attribute29,
  p_pel_attribute30,
  p_request_id,
  p_program_application_id,
  p_program_id,
  p_program_update_date,
  null,
  p_defer_deenrol_flag,
  p_deenrol_made_dt
  );
  --
  -- Having converted the arguments into the ben_pel_rec
  -- plsql record structure we call the corresponding record business process.
  --
  ins(
    p_effective_date,l_rec);
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_pil_elctbl_chc_popl_id := l_rec.pil_elctbl_chc_popl_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End ins;
--
end ben_pel_ins;

/
