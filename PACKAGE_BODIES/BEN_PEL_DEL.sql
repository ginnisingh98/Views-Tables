--------------------------------------------------------
--  DDL for Package Body BEN_PEL_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PEL_DEL" as
/* $Header: bepelrhi.pkb 120.3.12000000.2 2007/05/13 23:02:25 rtagarra noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_pel_del.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml delete logic. The functions of
--   this procedure are as follows:
--   1) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   2) To delete the specified row from the schema using the primary key in
--      the predicates.
--   3) To trap any constraint violations that may have occurred.
--   4) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the del
--   procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be delete from the schema.
--
-- Post Failure:
--   On the delete dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a child integrity constraint violation is raised the
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
Procedure delete_dml(p_rec in ben_pel_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  ben_pel_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Delete the ben_pil_elctbl_chc_popl row.
  --
  delete from ben_pil_elctbl_chc_popl
  where pil_elctbl_chc_popl_id = p_rec.pil_elctbl_chc_popl_id;
  --
  ben_pel_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    ben_pel_shd.g_api_dml := false;   -- Unset the api dml status
    ben_pel_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_pel_shd.g_api_dml := false;   -- Unset the api dml status
    Raise;
End delete_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_delete >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the delete dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the del procedure.
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
--   Any pre-processing required before the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_delete(p_rec in ben_pel_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_delete;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_delete >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after the
--   delete dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the del procedure.
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
--   Any post-processing required after the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_delete(
p_effective_date in date,p_rec in ben_pel_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
--
  --
  -- Start of API User Hook for post_delete.
  --
  begin
    --
    ben_pel_rkd.after_delete
      (
  p_pil_elctbl_chc_popl_id        =>p_rec.pil_elctbl_chc_popl_id
 ,p_dflt_enrt_dt_o                =>ben_pel_shd.g_old_rec.dflt_enrt_dt
 ,p_dflt_asnd_dt_o                =>ben_pel_shd.g_old_rec.dflt_asnd_dt
 ,p_elcns_made_dt_o               =>ben_pel_shd.g_old_rec.elcns_made_dt
 ,p_cls_enrt_dt_to_use_cd_o       =>ben_pel_shd.g_old_rec.cls_enrt_dt_to_use_cd
 ,p_enrt_typ_cycl_cd_o            =>ben_pel_shd.g_old_rec.enrt_typ_cycl_cd
 ,p_enrt_perd_end_dt_o            =>ben_pel_shd.g_old_rec.enrt_perd_end_dt
 ,p_enrt_perd_strt_dt_o           =>ben_pel_shd.g_old_rec.enrt_perd_strt_dt
 ,p_procg_end_dt_o                =>ben_pel_shd.g_old_rec.procg_end_dt
 ,p_pil_elctbl_popl_stat_cd_o     =>ben_pel_shd.g_old_rec.pil_elctbl_popl_stat_cd
 ,p_acty_ref_perd_cd_o            =>ben_pel_shd.g_old_rec.acty_ref_perd_cd
 ,p_uom_o                         =>ben_pel_shd.g_old_rec.uom
 ,p_comments_o                         =>ben_pel_shd.g_old_rec.comments
 ,p_mgr_ovrid_dt_o                         =>ben_pel_shd.g_old_rec.mgr_ovrid_dt
 ,p_ws_mgr_id_o                         =>ben_pel_shd.g_old_rec.ws_mgr_id
 ,p_mgr_ovrid_person_id_o                         =>ben_pel_shd.g_old_rec.mgr_ovrid_person_id
 ,p_assignment_id_o                         =>ben_pel_shd.g_old_rec.assignment_id
 --cwb
 ,p_bdgt_acc_cd_o                   => ben_pel_shd.g_old_rec.bdgt_acc_cd
 ,p_pop_cd_o                        => ben_pel_shd.g_old_rec.pop_cd
 ,p_bdgt_due_dt_o                   => ben_pel_shd.g_old_rec.bdgt_due_dt
 ,p_bdgt_export_flag_o              => ben_pel_shd.g_old_rec.bdgt_export_flag
 ,p_bdgt_iss_dt_o                   => ben_pel_shd.g_old_rec.bdgt_iss_dt
 ,p_bdgt_stat_cd_o                  => ben_pel_shd.g_old_rec.bdgt_stat_cd
 ,p_ws_acc_cd_o                     => ben_pel_shd.g_old_rec.ws_acc_cd
 ,p_ws_due_dt_o                     => ben_pel_shd.g_old_rec.ws_due_dt
 ,p_ws_export_flag_o                => ben_pel_shd.g_old_rec.ws_export_flag
 ,p_ws_iss_dt_o                     => ben_pel_shd.g_old_rec.ws_iss_dt
 ,p_ws_stat_cd_o                    => ben_pel_shd.g_old_rec.ws_stat_cd
 --cwb
 ,p_reinstate_cd_o                =>ben_pel_shd.g_old_rec.reinstate_cd
 ,p_reinstate_ovrdn_cd_o          =>ben_pel_shd.g_old_rec.reinstate_ovrdn_cd
 ,p_auto_asnd_dt_o                =>ben_pel_shd.g_old_rec.auto_asnd_dt
 ,p_cbr_elig_perd_strt_dt_o       =>ben_pel_shd.g_old_rec.cbr_elig_perd_strt_dt
 ,p_cbr_elig_perd_end_dt_o        =>ben_pel_shd.g_old_rec.cbr_elig_perd_end_dt
 ,p_lee_rsn_id_o                  =>ben_pel_shd.g_old_rec.lee_rsn_id
 ,p_enrt_perd_id_o                =>ben_pel_shd.g_old_rec.enrt_perd_id
 ,p_per_in_ler_id_o               =>ben_pel_shd.g_old_rec.per_in_ler_id
 ,p_pgm_id_o                      =>ben_pel_shd.g_old_rec.pgm_id
 ,p_pl_id_o                       =>ben_pel_shd.g_old_rec.pl_id
 ,p_business_group_id_o           =>ben_pel_shd.g_old_rec.business_group_id
 ,p_pel_attribute_category_o      =>ben_pel_shd.g_old_rec.pel_attribute_category
 ,p_pel_attribute1_o              =>ben_pel_shd.g_old_rec.pel_attribute1
 ,p_pel_attribute2_o              =>ben_pel_shd.g_old_rec.pel_attribute2
 ,p_pel_attribute3_o              =>ben_pel_shd.g_old_rec.pel_attribute3
 ,p_pel_attribute4_o              =>ben_pel_shd.g_old_rec.pel_attribute4
 ,p_pel_attribute5_o              =>ben_pel_shd.g_old_rec.pel_attribute5
 ,p_pel_attribute6_o              =>ben_pel_shd.g_old_rec.pel_attribute6
 ,p_pel_attribute7_o              =>ben_pel_shd.g_old_rec.pel_attribute7
 ,p_pel_attribute8_o              =>ben_pel_shd.g_old_rec.pel_attribute8
 ,p_pel_attribute9_o              =>ben_pel_shd.g_old_rec.pel_attribute9
 ,p_pel_attribute10_o             =>ben_pel_shd.g_old_rec.pel_attribute10
 ,p_pel_attribute11_o             =>ben_pel_shd.g_old_rec.pel_attribute11
 ,p_pel_attribute12_o             =>ben_pel_shd.g_old_rec.pel_attribute12
 ,p_pel_attribute13_o             =>ben_pel_shd.g_old_rec.pel_attribute13
 ,p_pel_attribute14_o             =>ben_pel_shd.g_old_rec.pel_attribute14
 ,p_pel_attribute15_o             =>ben_pel_shd.g_old_rec.pel_attribute15
 ,p_pel_attribute16_o             =>ben_pel_shd.g_old_rec.pel_attribute16
 ,p_pel_attribute17_o             =>ben_pel_shd.g_old_rec.pel_attribute17
 ,p_pel_attribute18_o             =>ben_pel_shd.g_old_rec.pel_attribute18
 ,p_pel_attribute19_o             =>ben_pel_shd.g_old_rec.pel_attribute19
 ,p_pel_attribute20_o             =>ben_pel_shd.g_old_rec.pel_attribute20
 ,p_pel_attribute21_o             =>ben_pel_shd.g_old_rec.pel_attribute21
 ,p_pel_attribute22_o             =>ben_pel_shd.g_old_rec.pel_attribute22
 ,p_pel_attribute23_o             =>ben_pel_shd.g_old_rec.pel_attribute23
 ,p_pel_attribute24_o             =>ben_pel_shd.g_old_rec.pel_attribute24
 ,p_pel_attribute25_o             =>ben_pel_shd.g_old_rec.pel_attribute25
 ,p_pel_attribute26_o             =>ben_pel_shd.g_old_rec.pel_attribute26
 ,p_pel_attribute27_o             =>ben_pel_shd.g_old_rec.pel_attribute27
 ,p_pel_attribute28_o             =>ben_pel_shd.g_old_rec.pel_attribute28
 ,p_pel_attribute29_o             =>ben_pel_shd.g_old_rec.pel_attribute29
 ,p_pel_attribute30_o             =>ben_pel_shd.g_old_rec.pel_attribute30
 ,p_request_id_o                  =>ben_pel_shd.g_old_rec.request_id
 ,p_program_application_id_o      =>ben_pel_shd.g_old_rec.program_application_id
 ,p_program_id_o                  =>ben_pel_shd.g_old_rec.program_id
 ,p_program_update_date_o         =>ben_pel_shd.g_old_rec.program_update_date
 ,p_object_version_number_o       =>ben_pel_shd.g_old_rec.object_version_number
 ,p_defer_deenrol_flag_o          =>ben_pel_shd.g_old_rec.defer_deenrol_flag
 ,p_deenrol_made_dt_o             =>ben_pel_shd.g_old_rec.deenrol_made_dt
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_pil_elctbl_chc_popl'
        ,p_hook_type   => 'AD');
      --
  end;
  --
  -- End of API User Hook for post_delete.
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_effective_date in date,
  p_rec       in ben_pel_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  ben_pel_shd.lck
    (
    p_rec.pil_elctbl_chc_popl_id,
    p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  ben_pel_bus.delete_validate(p_rec
  ,p_effective_date);
  --
  -- Call the supporting pre-delete operation
  --
  pre_delete(p_rec);
  --
  -- Delete the row.
  --
  delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  post_delete(
p_effective_date,p_rec);
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_effective_date in date,
  p_pil_elctbl_chc_popl_id             in number,
  p_object_version_number              in number
  ) is
--
  l_rec   ben_pel_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the  arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  l_rec.pil_elctbl_chc_popl_id:= p_pil_elctbl_chc_popl_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the ben_pel_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(
    p_effective_date,l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end ben_pel_del;

/
