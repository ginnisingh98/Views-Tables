--------------------------------------------------------
--  DDL for Package Body PSP_PEE_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_PEE_DEL" as
/* $Header: PSPEERHB.pls 120.3 2006/02/08 05:35 dpaudel noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  psp_pee_del.';  -- Global package name
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
  (p_rec in psp_pee_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  -- Delete the psp_external_effort_lines row.
  --
  delete from psp_external_effort_lines
  where external_effort_line_id = p_rec.external_effort_line_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    --
    psp_pee_shd.constraint_error
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
Procedure pre_delete(p_rec in psp_pee_shd.g_rec_type) is
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
Procedure post_delete(p_rec in psp_pee_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    psp_pee_rkd.after_delete
      (p_external_effort_line_id
      => p_rec.external_effort_line_id
      ,p_batch_name_o
      => psp_pee_shd.g_old_rec.batch_name
      ,p_object_version_number_o
      => psp_pee_shd.g_old_rec.object_version_number
      ,p_distribution_date_o
      => psp_pee_shd.g_old_rec.distribution_date
      ,p_person_id_o
      => psp_pee_shd.g_old_rec.person_id
      ,p_assignment_id_o
      => psp_pee_shd.g_old_rec.assignment_id
      ,p_currency_code_o
      => psp_pee_shd.g_old_rec.currency_code
      ,p_distribution_amount_o
      => psp_pee_shd.g_old_rec.distribution_amount
      ,p_business_group_id_o
      => psp_pee_shd.g_old_rec.business_group_id
      ,p_set_of_books_id_o
      => psp_pee_shd.g_old_rec.set_of_books_id
      ,p_gl_code_combination_id_o
      => psp_pee_shd.g_old_rec.gl_code_combination_id
      ,p_project_id_o
      => psp_pee_shd.g_old_rec.project_id
      ,p_task_id_o
      => psp_pee_shd.g_old_rec.task_id
      ,p_award_id_o
      => psp_pee_shd.g_old_rec.award_id
      ,p_expenditure_organization_i_o
      => psp_pee_shd.g_old_rec.expenditure_organization_id
      ,p_expenditure_type_o
      => psp_pee_shd.g_old_rec.expenditure_type
      ,p_attribute_category_o
      => psp_pee_shd.g_old_rec.attribute_category
      ,p_attribute1_o
      => psp_pee_shd.g_old_rec.attribute1
      ,p_attribute2_o
      => psp_pee_shd.g_old_rec.attribute2
      ,p_attribute3_o
      => psp_pee_shd.g_old_rec.attribute3
      ,p_attribute4_o
      => psp_pee_shd.g_old_rec.attribute4
      ,p_attribute5_o
      => psp_pee_shd.g_old_rec.attribute5
      ,p_attribute6_o
      => psp_pee_shd.g_old_rec.attribute6
      ,p_attribute7_o
      => psp_pee_shd.g_old_rec.attribute7
      ,p_attribute8_o
      => psp_pee_shd.g_old_rec.attribute8
      ,p_attribute9_o
      => psp_pee_shd.g_old_rec.attribute9
      ,p_attribute10_o
      => psp_pee_shd.g_old_rec.attribute10
      ,p_attribute11_o
      => psp_pee_shd.g_old_rec.attribute11
      ,p_attribute12_o
      => psp_pee_shd.g_old_rec.attribute12
      ,p_attribute13_o
      => psp_pee_shd.g_old_rec.attribute13
      ,p_attribute14_o
      => psp_pee_shd.g_old_rec.attribute14
      ,p_attribute15_o
      => psp_pee_shd.g_old_rec.attribute15
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PSP_EXTERNAL_EFFORT_LINES'
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
  (p_rec              in psp_pee_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  psp_pee_shd.lck
    (p_rec.external_effort_line_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  psp_pee_bus.delete_validate(p_rec);
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-delete operation
  --
  psp_pee_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  psp_pee_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  psp_pee_del.post_delete(p_rec);
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
  (p_external_effort_line_id              in     number
  ,p_object_version_number                in     number
  ) is
--
  l_rec   psp_pee_shd.g_rec_type;
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
  l_rec.external_effort_line_id := p_external_effort_line_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the psp_pee_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  psp_pee_del.del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end psp_pee_del;

/
