--------------------------------------------------------
--  DDL for Package Body PAY_BLT_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_BLT_DEL" as
/* $Header: pybltrhi.pkb 120.0.12010000.2 2008/10/16 09:57:17 asnell ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_blt_del.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- ----------------------< delete_app_ownerships >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Deletes row(s) from hr_application_ownerships depending on the mode that
--   the row handler has been called in.
--
-- ----------------------------------------------------------------------------
PROCEDURE delete_app_ownerships(p_pk_column  IN  varchar2
                               ,p_pk_value   IN  varchar2) IS
--
BEGIN
  --
  IF (hr_startup_data_api_support.return_startup_mode
                           IN ('STARTUP','GENERIC')) THEN
     --
     DELETE FROM hr_application_ownerships
      WHERE key_name = p_pk_column
        AND key_value = p_pk_value;
     --
  END IF;
END delete_app_ownerships;
--
-- ----------------------------------------------------------------------------
-- ----------------------< delete_app_ownerships >----------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE delete_app_ownerships(p_pk_column IN varchar2
                               ,p_pk_value  IN number) IS
--
BEGIN
  delete_app_ownerships(p_pk_column, to_char(p_pk_value));
END delete_app_ownerships;
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
  (p_rec in pay_blt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  pay_blt_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Delete the pay_balance_types row.
  --
  delete from pay_balance_types
  where balance_type_id = p_rec.balance_type_id;
  --
  pay_blt_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    pay_blt_shd.g_api_dml := false;   -- Unset the api dml status
    pay_blt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    pay_blt_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_delete(p_rec in pay_blt_shd.g_rec_type) is
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
Procedure post_delete(p_rec in pay_blt_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    -- Delete ownerships if applicable
    delete_app_ownerships
      ('BALANCE_TYPE_ID', p_rec.balance_type_id
      );
    --
    pay_blt_rkd.after_delete
      (p_balance_type_id
      => p_rec.balance_type_id
      ,p_business_group_id_o
      => pay_blt_shd.g_old_rec.business_group_id
      ,p_legislation_code_o
      => pay_blt_shd.g_old_rec.legislation_code
      ,p_currency_code_o
      => pay_blt_shd.g_old_rec.currency_code
      ,p_assignment_remuneration_fl_o
      => pay_blt_shd.g_old_rec.assignment_remuneration_flag
      ,p_balance_name_o
      => pay_blt_shd.g_old_rec.balance_name
      ,p_balance_uom_o
      => pay_blt_shd.g_old_rec.balance_uom
      ,p_comments_o
      => pay_blt_shd.g_old_rec.comments
      ,p_legislation_subgroup_o
      => pay_blt_shd.g_old_rec.legislation_subgroup
      ,p_reporting_name_o
      => pay_blt_shd.g_old_rec.reporting_name
      ,p_attribute_category_o
      => pay_blt_shd.g_old_rec.attribute_category
      ,p_attribute1_o
      => pay_blt_shd.g_old_rec.attribute1
      ,p_attribute2_o
      => pay_blt_shd.g_old_rec.attribute2
      ,p_attribute3_o
      => pay_blt_shd.g_old_rec.attribute3
      ,p_attribute4_o
      => pay_blt_shd.g_old_rec.attribute4
      ,p_attribute5_o
      => pay_blt_shd.g_old_rec.attribute5
      ,p_attribute6_o
      => pay_blt_shd.g_old_rec.attribute6
      ,p_attribute7_o
      => pay_blt_shd.g_old_rec.attribute7
      ,p_attribute8_o
      => pay_blt_shd.g_old_rec.attribute8
      ,p_attribute9_o
      => pay_blt_shd.g_old_rec.attribute9
      ,p_attribute10_o
      => pay_blt_shd.g_old_rec.attribute10
      ,p_attribute11_o
      => pay_blt_shd.g_old_rec.attribute11
      ,p_attribute12_o
      => pay_blt_shd.g_old_rec.attribute12
      ,p_attribute13_o
      => pay_blt_shd.g_old_rec.attribute13
      ,p_attribute14_o
      => pay_blt_shd.g_old_rec.attribute14
      ,p_attribute15_o
      => pay_blt_shd.g_old_rec.attribute15
      ,p_attribute16_o
      => pay_blt_shd.g_old_rec.attribute16
      ,p_attribute17_o
      => pay_blt_shd.g_old_rec.attribute17
      ,p_attribute18_o
      => pay_blt_shd.g_old_rec.attribute18
      ,p_attribute19_o
      => pay_blt_shd.g_old_rec.attribute19
      ,p_attribute20_o
      => pay_blt_shd.g_old_rec.attribute20
      ,p_jurisdiction_level_o
      => pay_blt_shd.g_old_rec.jurisdiction_level
      ,p_tax_type_o
      => pay_blt_shd.g_old_rec.tax_type
      ,p_object_version_number_o
      => pay_blt_shd.g_old_rec.object_version_number
      ,p_balance_category_id_o
      => pay_blt_shd.g_old_rec.balance_category_id
      ,p_base_balance_type_id_o
      => pay_blt_shd.g_old_rec.base_balance_type_id
      ,p_input_value_id_o
      => pay_blt_shd.g_old_rec.input_value_id
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PAY_BALANCE_TYPES'
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
  (p_rec              in pay_blt_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  pay_blt_shd.lck
    (p_rec.balance_type_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  pay_blt_bus.delete_validate(p_rec);
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-delete operation
  --
  pay_blt_del.pre_delete(p_rec);
  --
  -- Remove balance feeds, balance classifications and defined balances.
  --
     pay_balance_types_pkg.balance_type_cascade_delete(p_rec.Balance_Type_Id);
  --
  -- Delete the row.
  --
  pay_blt_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  pay_blt_del.post_delete(p_rec);
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
  (p_balance_type_id                      in     number
  ,p_object_version_number                in     number
  ) is
--
  l_rec   pay_blt_shd.g_rec_type;
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
  l_rec.balance_type_id := p_balance_type_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the pay_blt_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  pay_blt_del.del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end pay_blt_del;

/
