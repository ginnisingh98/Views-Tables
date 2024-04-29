--------------------------------------------------------
--  DDL for Package Body HR_CTX_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CTX_DEL" as
/* $Header: hrctxrhi.pkb 120.0 2005/05/30 23:30 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_ctx_del.';  -- Global package name
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
  (p_rec in hr_ctx_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  -- Delete the hr_ki_contexts row.
  --
  delete from hr_ki_contexts
  where context_id = p_rec.context_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    --
    hr_ctx_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    --
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
Procedure pre_delete(p_rec in hr_ctx_shd.g_rec_type) is
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
Procedure post_delete(p_rec in hr_ctx_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    hr_ctx_rkd.after_delete
      (p_context_id
      => p_rec.context_id
      ,p_view_name_o
      => hr_ctx_shd.g_old_rec.view_name
      ,p_param_1_o
      => hr_ctx_shd.g_old_rec.param_1
      ,p_param_2_o
      => hr_ctx_shd.g_old_rec.param_2
      ,p_param_3_o
      => hr_ctx_shd.g_old_rec.param_3
      ,p_param_4_o
      => hr_ctx_shd.g_old_rec.param_4
      ,p_param_5_o
      => hr_ctx_shd.g_old_rec.param_5
      ,p_param_6_o
      => hr_ctx_shd.g_old_rec.param_6
      ,p_param_7_o
      => hr_ctx_shd.g_old_rec.param_7
      ,p_param_8_o
      => hr_ctx_shd.g_old_rec.param_8
      ,p_param_9_o
      => hr_ctx_shd.g_old_rec.param_9
      ,p_param_10_o
      => hr_ctx_shd.g_old_rec.param_10
      ,p_param_11_o
      => hr_ctx_shd.g_old_rec.param_11
      ,p_param_12_o
      => hr_ctx_shd.g_old_rec.param_12
      ,p_param_13_o
      => hr_ctx_shd.g_old_rec.param_13
      ,p_param_14_o
      => hr_ctx_shd.g_old_rec.param_14
      ,p_param_15_o
      => hr_ctx_shd.g_old_rec.param_15
      ,p_param_16_o
      => hr_ctx_shd.g_old_rec.param_16
      ,p_param_17_o
      => hr_ctx_shd.g_old_rec.param_17
      ,p_param_18_o
      => hr_ctx_shd.g_old_rec.param_18
      ,p_param_19_o
      => hr_ctx_shd.g_old_rec.param_19
      ,p_param_20_o
      => hr_ctx_shd.g_old_rec.param_20
      ,p_param_21_o
      => hr_ctx_shd.g_old_rec.param_21
      ,p_param_22_o
      => hr_ctx_shd.g_old_rec.param_22
      ,p_param_23_o
      => hr_ctx_shd.g_old_rec.param_23
      ,p_param_24_o
      => hr_ctx_shd.g_old_rec.param_24
      ,p_param_25_o
      => hr_ctx_shd.g_old_rec.param_25
      ,p_param_26_o
      => hr_ctx_shd.g_old_rec.param_26
      ,p_param_27_o
      => hr_ctx_shd.g_old_rec.param_27
      ,p_param_28_o
      => hr_ctx_shd.g_old_rec.param_28
      ,p_param_29_o
      => hr_ctx_shd.g_old_rec.param_29
      ,p_param_30_o
      => hr_ctx_shd.g_old_rec.param_30
      ,p_object_version_number_o
      => hr_ctx_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HR_KI_CONTEXTS'
        ,p_hook_type   => 'AD');
      --
  end;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_rec              in hr_ctx_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  hr_ctx_shd.lck
    (p_rec.context_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  hr_ctx_bus.delete_validate(p_rec);
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-delete operation
  --
  hr_ctx_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  hr_ctx_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  hr_ctx_del.post_delete(p_rec);
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
  (p_context_id                           in     number
  ,p_object_version_number                in     number
  ) is
--
  l_rec   hr_ctx_shd.g_rec_type;
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
  l_rec.context_id := p_context_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the hr_ctx_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  hr_ctx_del.del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end hr_ctx_del;

/