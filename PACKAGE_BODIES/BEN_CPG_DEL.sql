--------------------------------------------------------
--  DDL for Package Body BEN_CPG_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CPG_DEL" as
/* $Header: becpgrhi.pkb 120.0 2005/05/28 01:13 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_cpg_del.';  -- Global package name
g_debug  boolean := hr_utility.debug_enabled;
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
Procedure delete_dml
  (p_rec in ben_cpg_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  if g_debug then
     hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  ben_cpg_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Delete the ben_cwb_person_groups row.
  --
  delete from ben_cwb_person_groups
  where group_per_in_ler_id = p_rec.group_per_in_ler_id
    and group_pl_id = p_rec.group_pl_id
    and group_oipl_id = p_rec.group_oipl_id;
  --
  ben_cpg_shd.g_api_dml := false;   -- Unset the api dml status
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    ben_cpg_shd.g_api_dml := false;   -- Unset the api dml status
    ben_cpg_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_cpg_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_delete(p_rec in ben_cpg_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'pre_delete';
--
Begin
  if g_debug then
     hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End pre_delete;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_delete >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after
--   the delete dml.
--
-- Prerequistes:
--   This is an internal procedure which is called from the del procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- -----------------------------------------------------------------------------
Procedure post_delete(p_rec in ben_cpg_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  if g_debug then
     hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  begin
    --
    ben_cpg_rkd.after_delete
      (p_group_per_in_ler_id
      => p_rec.group_per_in_ler_id
      ,p_group_pl_id
      => p_rec.group_pl_id
      ,p_group_oipl_id
      => p_rec.group_oipl_id
      ,p_lf_evt_ocrd_dt_o
      => ben_cpg_shd.g_old_rec.lf_evt_ocrd_dt
      ,p_bdgt_pop_cd_o
      => ben_cpg_shd.g_old_rec.bdgt_pop_cd
      ,p_due_dt_o
      => ben_cpg_shd.g_old_rec.due_dt
      ,p_access_cd_o
      => ben_cpg_shd.g_old_rec.access_cd
      ,p_approval_cd_o
      => ben_cpg_shd.g_old_rec.approval_cd
      ,p_approval_date_o
      => ben_cpg_shd.g_old_rec.approval_date
      ,p_approval_comments_o
      => ben_cpg_shd.g_old_rec.approval_comments
      ,p_submit_cd_o
      => ben_cpg_shd.g_old_rec.submit_cd
      ,p_submit_date_o
      => ben_cpg_shd.g_old_rec.submit_date
      ,p_submit_comments_o
      => ben_cpg_shd.g_old_rec.submit_comments
      ,p_dist_bdgt_val_o
      => ben_cpg_shd.g_old_rec.dist_bdgt_val
      ,p_ws_bdgt_val_o
      => ben_cpg_shd.g_old_rec.ws_bdgt_val
      ,p_rsrv_val_o
      => ben_cpg_shd.g_old_rec.rsrv_val
      ,p_dist_bdgt_mn_val_o
      => ben_cpg_shd.g_old_rec.dist_bdgt_mn_val
      ,p_dist_bdgt_mx_val_o
      => ben_cpg_shd.g_old_rec.dist_bdgt_mx_val
      ,p_dist_bdgt_incr_val_o
      => ben_cpg_shd.g_old_rec.dist_bdgt_incr_val
      ,p_ws_bdgt_mn_val_o
      => ben_cpg_shd.g_old_rec.ws_bdgt_mn_val
      ,p_ws_bdgt_mx_val_o
      => ben_cpg_shd.g_old_rec.ws_bdgt_mx_val
      ,p_ws_bdgt_incr_val_o
      => ben_cpg_shd.g_old_rec.ws_bdgt_incr_val
      ,p_rsrv_mn_val_o
      => ben_cpg_shd.g_old_rec.rsrv_mn_val
      ,p_rsrv_mx_val_o
      => ben_cpg_shd.g_old_rec.rsrv_mx_val
      ,p_rsrv_incr_val_o
      => ben_cpg_shd.g_old_rec.rsrv_incr_val
      ,p_dist_bdgt_iss_val_o
      => ben_cpg_shd.g_old_rec.dist_bdgt_iss_val
      ,p_ws_bdgt_iss_val_o
      => ben_cpg_shd.g_old_rec.ws_bdgt_iss_val
      ,p_dist_bdgt_iss_date_o
      => ben_cpg_shd.g_old_rec.dist_bdgt_iss_date
      ,p_ws_bdgt_iss_date_o
      => ben_cpg_shd.g_old_rec.ws_bdgt_iss_date
      ,p_ws_bdgt_val_last_upd_date_o
      => ben_cpg_shd.g_old_rec.ws_bdgt_val_last_upd_date
      ,p_dist_bdgt_val_last_upd_dat_o
      => ben_cpg_shd.g_old_rec.dist_bdgt_val_last_upd_date
      ,p_rsrv_val_last_upd_date_o
      => ben_cpg_shd.g_old_rec.rsrv_val_last_upd_date
      ,p_ws_bdgt_val_last_upd_by_o
      => ben_cpg_shd.g_old_rec.ws_bdgt_val_last_upd_by
      ,p_dist_bdgt_val_last_upd_by_o
      => ben_cpg_shd.g_old_rec.dist_bdgt_val_last_upd_by
      ,p_rsrv_val_last_upd_by_o
      => ben_cpg_shd.g_old_rec.rsrv_val_last_upd_by
      ,p_object_version_number_o
      => ben_cpg_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'BEN_CWB_PERSON_GROUPS'
        ,p_hook_type   => 'AD');
      --
  end;
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_rec              in ben_cpg_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  if g_debug then
     hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- We must lock the row which we need to delete.
  --
  ben_cpg_shd.lck
    (p_rec.group_per_in_ler_id
    ,p_rec.group_pl_id
    ,p_rec.group_oipl_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  ben_cpg_bus.delete_validate(p_rec);
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-delete operation
  --
  ben_cpg_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  ben_cpg_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  ben_cpg_del.post_delete(p_rec);
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_group_per_in_ler_id                  in     number
  ,p_group_pl_id                          in     number
  ,p_group_oipl_id                        in     number
  ,p_object_version_number                in     number
  ) is
--
  l_rec   ben_cpg_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  if g_debug then
     hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the  arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  l_rec.group_per_in_ler_id := p_group_per_in_ler_id;
  l_rec.group_pl_id := p_group_pl_id;
  l_rec.group_oipl_id := p_group_oipl_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the ben_cpg_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  ben_cpg_del.del(l_rec);
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End del;
--
end ben_cpg_del;

/
