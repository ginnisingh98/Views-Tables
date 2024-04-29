--------------------------------------------------------
--  DDL for Package Body HR_TMP_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_TMP_DEL" as
/* $Header: hrtmprhi.pkb 115.6 2002/12/03 11:31:46 raranjan noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  hr_tmp_del.';  -- Global package name
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
  (p_rec in hr_tmp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  -- Delete the hr_form_templates_b row.
  --
  delete from hr_form_templates_b
  where form_template_id = p_rec.form_template_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    --
    hr_tmp_shd.constraint_error
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
Procedure pre_delete(p_rec in hr_tmp_shd.g_rec_type) is
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
Procedure post_delete(p_rec in hr_tmp_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
    begin
    --
    hr_tmp_rkd.after_delete
      (p_form_template_id
      => p_rec.form_template_id
      ,p_object_version_number_o
      => hr_tmp_shd.g_old_rec.object_version_number
      ,p_application_id_o
      => hr_tmp_shd.g_old_rec.application_id
      ,p_form_id_o
      => hr_tmp_shd.g_old_rec.form_id
      ,p_template_name_o
      => hr_tmp_shd.g_old_rec.template_name
      ,p_enabled_flag_o
      => hr_tmp_shd.g_old_rec.enabled_flag
      ,p_legislation_code_o
      => hr_tmp_shd.g_old_rec.legislation_code
      ,p_attribute_category_o
      => hr_tmp_shd.g_old_rec.attribute_category
      ,p_attribute1_o
      => hr_tmp_shd.g_old_rec.attribute1
      ,p_attribute2_o
      => hr_tmp_shd.g_old_rec.attribute2
      ,p_attribute3_o
      => hr_tmp_shd.g_old_rec.attribute3
      ,p_attribute4_o
      => hr_tmp_shd.g_old_rec.attribute4
      ,p_attribute5_o
      => hr_tmp_shd.g_old_rec.attribute5
      ,p_attribute6_o
      => hr_tmp_shd.g_old_rec.attribute6
      ,p_attribute7_o
      => hr_tmp_shd.g_old_rec.attribute7
      ,p_attribute8_o
      => hr_tmp_shd.g_old_rec.attribute8
      ,p_attribute9_o
      => hr_tmp_shd.g_old_rec.attribute9
      ,p_attribute10_o
      => hr_tmp_shd.g_old_rec.attribute10
      ,p_attribute11_o
      => hr_tmp_shd.g_old_rec.attribute11
      ,p_attribute12_o
      => hr_tmp_shd.g_old_rec.attribute12
      ,p_attribute13_o
      => hr_tmp_shd.g_old_rec.attribute13
      ,p_attribute14_o
      => hr_tmp_shd.g_old_rec.attribute14
      ,p_attribute15_o
      => hr_tmp_shd.g_old_rec.attribute15
      ,p_attribute16_o
      => hr_tmp_shd.g_old_rec.attribute16
      ,p_attribute17_o
      => hr_tmp_shd.g_old_rec.attribute17
      ,p_attribute18_o
      => hr_tmp_shd.g_old_rec.attribute18
      ,p_attribute19_o
      => hr_tmp_shd.g_old_rec.attribute19
      ,p_attribute20_o
      => hr_tmp_shd.g_old_rec.attribute20
      ,p_attribute21_o
      => hr_tmp_shd.g_old_rec.attribute21
      ,p_attribute22_o
      => hr_tmp_shd.g_old_rec.attribute22
      ,p_attribute23_o
      => hr_tmp_shd.g_old_rec.attribute23
      ,p_attribute24_o
      => hr_tmp_shd.g_old_rec.attribute24
      ,p_attribute25_o
      => hr_tmp_shd.g_old_rec.attribute25
      ,p_attribute26_o
      => hr_tmp_shd.g_old_rec.attribute26
      ,p_attribute27_o
      => hr_tmp_shd.g_old_rec.attribute27
      ,p_attribute28_o
      => hr_tmp_shd.g_old_rec.attribute28
      ,p_attribute29_o
      => hr_tmp_shd.g_old_rec.attribute29
      ,p_attribute30_o
      => hr_tmp_shd.g_old_rec.attribute30
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'HR_FORM_TEMPLATES_B'
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
  (p_rec	      in hr_tmp_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  hr_tmp_shd.lck
    (p_rec.form_template_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  hr_tmp_bus.delete_validate(p_rec);
  --
  -- Call the supporting pre-delete operation
  --
  hr_tmp_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  hr_tmp_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  hr_tmp_del.post_delete(p_rec);
  --
End del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure del
  (p_form_template_id                     in     number
  ,p_object_version_number                in     number
  ) is
--
  l_rec	  hr_tmp_shd.g_rec_type;
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
  l_rec.form_template_id := p_form_template_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the hr_tmp_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  hr_tmp_del.del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end hr_tmp_del;

/
