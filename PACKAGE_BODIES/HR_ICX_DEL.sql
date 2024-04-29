--------------------------------------------------------
--  DDL for Package Body HR_ICX_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ICX_DEL" as
/* $Header: hricxrhi.pkb 115.5 2003/10/23 01:44:08 bsubrama noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  hr_icx_del.';  -- Global package name
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
  (p_rec in hr_icx_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  -- Delete the hr_item_contexts row.
  --
  delete from hr_item_contexts
  where item_context_id = p_rec.item_context_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    --
    hr_icx_shd.constraint_error
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
Procedure pre_delete(p_rec in hr_icx_shd.g_rec_type) is
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
Procedure post_delete(p_rec in hr_icx_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
    begin
    --
    hr_icx_rkd.after_delete
      (p_item_context_id
      => p_rec.item_context_id
      ,p_object_version_number_o
      => hr_icx_shd.g_old_rec.object_version_number
      ,p_id_flex_num_o
      => hr_icx_shd.g_old_rec.id_flex_num
      ,p_summary_flag_o
      => hr_icx_shd.g_old_rec.summary_flag
      ,p_enabled_flag_o
      => hr_icx_shd.g_old_rec.enabled_flag
      ,p_start_date_active_o
      => hr_icx_shd.g_old_rec.start_date_active
      ,p_end_date_active_o
      => hr_icx_shd.g_old_rec.end_date_active
      ,p_segment1_o
      => hr_icx_shd.g_old_rec.segment1
      ,p_segment2_o
      => hr_icx_shd.g_old_rec.segment2
      ,p_segment3_o
      => hr_icx_shd.g_old_rec.segment3
      ,p_segment4_o
      => hr_icx_shd.g_old_rec.segment4
      ,p_segment5_o
      => hr_icx_shd.g_old_rec.segment5
      ,p_segment6_o
      => hr_icx_shd.g_old_rec.segment6
      ,p_segment7_o
      => hr_icx_shd.g_old_rec.segment7
      ,p_segment8_o
      => hr_icx_shd.g_old_rec.segment8
      ,p_segment9_o
      => hr_icx_shd.g_old_rec.segment9
      ,p_segment10_o
      => hr_icx_shd.g_old_rec.segment10
      ,p_segment11_o
      => hr_icx_shd.g_old_rec.segment11
      ,p_segment12_o
      => hr_icx_shd.g_old_rec.segment12
      ,p_segment13_o
      => hr_icx_shd.g_old_rec.segment13
      ,p_segment14_o
      => hr_icx_shd.g_old_rec.segment14
      ,p_segment15_o
      => hr_icx_shd.g_old_rec.segment15
      ,p_segment16_o
      => hr_icx_shd.g_old_rec.segment16
      ,p_segment17_o
      => hr_icx_shd.g_old_rec.segment17
      ,p_segment18_o
      => hr_icx_shd.g_old_rec.segment18
      ,p_segment19_o
      => hr_icx_shd.g_old_rec.segment19
      ,p_segment20_o
      => hr_icx_shd.g_old_rec.segment20
      ,p_segment21_o
      => hr_icx_shd.g_old_rec.segment21
      ,p_segment22_o
      => hr_icx_shd.g_old_rec.segment22
      ,p_segment23_o
      => hr_icx_shd.g_old_rec.segment23
      ,p_segment24_o
      => hr_icx_shd.g_old_rec.segment24
      ,p_segment25_o
      => hr_icx_shd.g_old_rec.segment25
      ,p_segment26_o
      => hr_icx_shd.g_old_rec.segment26
      ,p_segment27_o
      => hr_icx_shd.g_old_rec.segment27
      ,p_segment28_o
      => hr_icx_shd.g_old_rec.segment28
      ,p_segment29_o
      => hr_icx_shd.g_old_rec.segment29
      ,p_segment30_o
      => hr_icx_shd.g_old_rec.segment30
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HR_ITEM_CONTEXTS'
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
  (p_rec        in hr_icx_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  hr_icx_shd.lck
    (p_rec.item_context_id ,
     p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  hr_icx_bus.delete_validate(p_rec);
  --
  -- Call the supporting pre-delete operation
  --
  hr_icx_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  hr_icx_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  hr_icx_del.post_delete(p_rec);
  --
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_item_context_id                      in     number
  ,p_object_version_number                in     number
  ) is
--
  l_rec   hr_icx_shd.g_rec_type;
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
  l_rec.item_context_id := p_item_context_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the hr_icx_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  hr_icx_del.del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end hr_icx_del;

/
