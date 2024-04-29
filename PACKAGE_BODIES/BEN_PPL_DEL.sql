--------------------------------------------------------
--  DDL for Package Body BEN_PPL_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PPL_DEL" as
/* $Header: bepplrhi.pkb 120.0.12000000.3 2007/02/08 07:41:23 vborkar noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ben_ppl_del.';  -- Global package name
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
Procedure delete_dml(p_rec in ben_ppl_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  ben_ppl_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Delete the ben_ptnl_ler_for_per row.
  --
  delete from ben_ptnl_ler_for_per
  where ptnl_ler_for_per_id = p_rec.ptnl_ler_for_per_id;
  --
  ben_ppl_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    ben_ppl_shd.g_api_dml := false;   -- Unset the api dml status
    ben_ppl_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_ppl_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_delete(p_rec in ben_ppl_shd.g_rec_type) is
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
p_effective_date in date,p_rec in ben_ppl_shd.g_rec_type) is
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
    ben_ppl_rkd.after_delete
      (
  p_ptnl_ler_for_per_id           =>p_rec.ptnl_ler_for_per_id
 ,p_csd_by_ptnl_ler_for_per_id_o    =>ben_ppl_shd.g_old_rec.csd_by_ptnl_ler_for_per_id
 ,p_lf_evt_ocrd_dt_o              =>ben_ppl_shd.g_old_rec.lf_evt_ocrd_dt
 ,p_trgr_table_pk_id_o            =>ben_ppl_shd.g_old_rec.trgr_table_pk_id
 ,p_ptnl_ler_for_per_stat_cd_o    =>ben_ppl_shd.g_old_rec.ptnl_ler_for_per_stat_cd
 ,p_ptnl_ler_for_per_src_cd_o     =>ben_ppl_shd.g_old_rec.ptnl_ler_for_per_src_cd
 ,p_mnl_dt_o                      =>ben_ppl_shd.g_old_rec.mnl_dt
 ,p_enrt_perd_id_o                =>ben_ppl_shd.g_old_rec.enrt_perd_id
 ,p_ntfn_dt_o                     =>ben_ppl_shd.g_old_rec.ntfn_dt
 ,p_dtctd_dt_o                    =>ben_ppl_shd.g_old_rec.dtctd_dt
 ,p_procd_dt_o                    =>ben_ppl_shd.g_old_rec.procd_dt
 ,p_unprocd_dt_o                  =>ben_ppl_shd.g_old_rec.unprocd_dt
 ,p_voidd_dt_o                    =>ben_ppl_shd.g_old_rec.voidd_dt
 ,p_mnlo_dt_o                     =>ben_ppl_shd.g_old_rec.mnlo_dt
 ,p_ler_id_o                      =>ben_ppl_shd.g_old_rec.ler_id
 ,p_person_id_o                   =>ben_ppl_shd.g_old_rec.person_id
 ,p_business_group_id_o           =>ben_ppl_shd.g_old_rec.business_group_id
 ,p_request_id_o                  =>ben_ppl_shd.g_old_rec.request_id
 ,p_program_application_id_o      =>ben_ppl_shd.g_old_rec.program_application_id
 ,p_program_id_o                  =>ben_ppl_shd.g_old_rec.program_id
 ,p_program_update_date_o         =>ben_ppl_shd.g_old_rec.program_update_date
 ,p_object_version_number_o       =>ben_ppl_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'ben_ptnl_ler_for_per'
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
  p_rec	      in ben_ppl_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  ben_ppl_shd.lck
	(
	p_rec.ptnl_ler_for_per_id,
	p_rec.object_version_number
	);
  --
  -- Call the supporting delete validate operation
  --
  ben_ppl_bus.delete_validate(p_rec,p_effective_date);
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
  post_delete(p_effective_date,p_rec);
  --
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (
  p_effective_date in date,
  p_ptnl_ler_for_per_id                in number,
  p_object_version_number              in number
  ) is
--
  l_rec	  ben_ppl_shd.g_rec_type;
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
  l_rec.ptnl_ler_for_per_id:= p_ptnl_ler_for_per_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the ben_ppl_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  del(p_effective_date,l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end ben_ppl_del;

/
