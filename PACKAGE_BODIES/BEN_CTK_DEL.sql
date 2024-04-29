--------------------------------------------------------
--  DDL for Package Body BEN_CTK_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CTK_DEL" as
/* $Header: bectkrhi.pkb 120.0 2005/05/28 01:25 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ben_ctk_del.';  -- Global package name
g_debug boolean := hr_utility.debug_enabled;
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
  (p_rec in ben_ctk_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  if g_debug then
     hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  --
  ben_ctk_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Delete the ben_cwb_person_tasks row.
  --
  delete from ben_cwb_person_tasks
  where group_per_in_ler_id = p_rec.group_per_in_ler_id
    and task_id = p_rec.task_id;
  --
  ben_ctk_shd.g_api_dml := false;   -- Unset the api dml status
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    ben_ctk_shd.g_api_dml := false;   -- Unset the api dml status
    ben_ctk_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ben_ctk_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_delete(p_rec in ben_ctk_shd.g_rec_type) is
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
Procedure post_delete(p_rec in ben_ctk_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  if g_debug then
     hr_utility.set_location('Entering:'||l_proc, 5);
  end if;
  begin
    --
    ben_ctk_rkd.after_delete
      (p_group_per_in_ler_id
      => p_rec.group_per_in_ler_id
      ,p_task_id
      => p_rec.task_id
      ,p_group_pl_id_o
      => ben_ctk_shd.g_old_rec.group_pl_id
      ,p_lf_evt_ocrd_dt_o
      => ben_ctk_shd.g_old_rec.lf_evt_ocrd_dt
      ,p_status_cd_o
      => ben_ctk_shd.g_old_rec.status_cd
      ,p_access_cd_o
      => ben_ctk_shd.g_old_rec.access_cd
      ,p_task_last_update_date_o
      => ben_ctk_shd.g_old_rec.task_last_update_date
      ,p_task_last_update_by_o
      => ben_ctk_shd.g_old_rec.task_last_update_by
      ,p_object_version_number_o
      => ben_ctk_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'BEN_CWB_PERSON_TASKS'
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
  (p_rec              in ben_ctk_shd.g_rec_type
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
  ben_ctk_shd.lck
    (p_rec.group_per_in_ler_id
    ,p_rec.task_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  ben_ctk_bus.delete_validate(p_rec);
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-delete operation
  --
  ben_ctk_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  ben_ctk_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  ben_ctk_del.post_delete(p_rec);
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
  ,p_task_id                              in     number
  ,p_object_version_number                in     number
  ) is
--
  l_rec   ben_ctk_shd.g_rec_type;
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
  l_rec.task_id := p_task_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the ben_ctk_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  ben_ctk_del.del(l_rec);
  --
  if g_debug then
     hr_utility.set_location(' Leaving:'||l_proc, 10);
  end if;
End del;
--
end ben_ctk_del;

/
