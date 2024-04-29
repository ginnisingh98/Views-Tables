--------------------------------------------------------
--  DDL for Package Body HR_QSF_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_QSF_DEL" as
/* $Header: hrqsfrhi.pkb 115.11 2003/08/27 00:16:45 hpandya ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
 g_package  varchar2(33)  := '  hr_qsf_del.';  -- Global package name
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
 Procedure delete_dml(p_rec in hr_qsf_shd.g_rec_type) is
--
   l_proc  varchar2(72) := g_package||'delete_dml';
--
 Begin
  hr_utility.set_location('Entering:'||l_proc, 5);


  -- Delete the hr_quest_fields row.

   delete from hr_quest_fields
   where field_id = p_rec.field_id;


   hr_utility.set_location(' Leaving:'||l_proc, 10);

 Exception
   When hr_api.child_integrity_violated then
    -- Child integrity has been violated
     hr_qsf_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
   When Others Then
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
Procedure pre_delete(p_rec in hr_qsf_shd.g_rec_type) is

   l_proc  varchar2(72) := g_package||'pre_delete';

 Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

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
 Procedure post_delete(p_rec in hr_qsf_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
 Begin
   hr_utility.set_location('Entering:'||l_proc, 5);
   hr_qsf_rkd.after_delete
      (p_field_id
      => p_rec.field_id
      ,p_questionnaire_template_id_o
      => hr_qsf_shd.g_old_rec.questionnaire_template_id
      ,p_name_o
      => hr_qsf_shd.g_old_rec.name
      ,p_type_o
      => hr_qsf_shd.g_old_rec.type
      ,p_html_text_o
      => hr_qsf_shd.g_old_rec.html_text
      ,p_sql_required_flag_o
      => hr_qsf_shd.g_old_rec.sql_required_flag
      ,p_sql_text_o
      => hr_qsf_shd.g_old_rec.sql_text
      ,p_object_version_number_o
      => hr_qsf_shd.g_old_rec.object_version_number
      );
   --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HR_QUEST_FIELDS'
        ,p_hook_type   => 'AD');
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
   p_rec        in hr_qsf_shd.g_rec_type
  ) is

   l_proc  varchar2(72) := g_package||'del';
--
 Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  -- We must lock the row which we need to delete.
  --
   hr_qsf_shd.lck
   (
    p_rec.field_id,
    p_rec.object_version_number
   );
  --
  -- Call the supporting delete validate operation
  --
  hr_qsf_bus.delete_validate(p_rec);
  hr_multi_message.end_validation_set;
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
  post_delete(p_rec);
  hr_multi_message.end_validation_set;
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
   (
    p_field_id                           in number,
    p_object_version_number              in number
   ) is
--
   l_rec    hr_qsf_shd.g_rec_type;
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
   l_rec.field_id:= p_field_id;
   l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the hr_qsf_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
   del(l_rec);
  --
   hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end hr_qsf_del;

/
