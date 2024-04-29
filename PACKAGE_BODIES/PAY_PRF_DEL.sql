--------------------------------------------------------
--  DDL for Package Body PAY_PRF_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PRF_DEL" as
/* $Header: pyprfrhi.pkb 120.0 2005/05/29 07:49 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pay_prf_del.';  -- Global package name
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
  (p_rec in pay_prf_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  -- Delete the pay_range_tables_f row.
  --
  delete from pay_range_tables_f
  where range_table_id = p_rec.range_table_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    --
    pay_prf_shd.constraint_error
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
Procedure pre_delete(p_rec in pay_prf_shd.g_rec_type) is
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
Procedure post_delete(p_rec in pay_prf_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    -- Delete ownerships if applicable
    delete_app_ownerships
      ('RANGE_TABLE_ID', p_rec.range_table_id
      );
    --
    pay_prf_rkd.after_delete
      (p_range_table_id
      => p_rec.range_table_id
      ,p_effective_start_date_o
      => pay_prf_shd.g_old_rec.effective_start_date
      ,p_effective_end_date_o
      => pay_prf_shd.g_old_rec.effective_end_date
      ,p_range_table_number_o
      => pay_prf_shd.g_old_rec.range_table_number
      ,p_row_value_uom_o
      => pay_prf_shd.g_old_rec.row_value_uom
      ,p_period_frequency_o
      => pay_prf_shd.g_old_rec.period_frequency
      ,p_earnings_type_o
      => pay_prf_shd.g_old_rec.earnings_type
      ,p_business_group_id_o
      => pay_prf_shd.g_old_rec.business_group_id
      ,p_legislation_code_o
      => pay_prf_shd.g_old_rec.legislation_code
      ,p_last_updated_login_o
      => pay_prf_shd.g_old_rec.last_updated_login
      ,p_created_date_o
      => pay_prf_shd.g_old_rec.created_date
      ,p_object_version_number_o
      => pay_prf_shd.g_old_rec.object_version_number
      ,p_attribute_category_o
      => pay_prf_shd.g_old_rec.attribute_category
      ,p_attribute1_o
      => pay_prf_shd.g_old_rec.attribute1
      ,p_attribute2_o
      => pay_prf_shd.g_old_rec.attribute2
      ,p_attribute3_o
      => pay_prf_shd.g_old_rec.attribute3
      ,p_attribute4_o
      => pay_prf_shd.g_old_rec.attribute4
      ,p_attribute5_o
      => pay_prf_shd.g_old_rec.attribute5
      ,p_attribute6_o
      => pay_prf_shd.g_old_rec.attribute6
      ,p_attribute7_o
      => pay_prf_shd.g_old_rec.attribute7
      ,p_attribute8_o
      => pay_prf_shd.g_old_rec.attribute8
      ,p_attribute9_o
      => pay_prf_shd.g_old_rec.attribute9
      ,p_attribute10_o
      => pay_prf_shd.g_old_rec.attribute10
      ,p_attribute11_o
      => pay_prf_shd.g_old_rec.attribute11
      ,p_attribute12_o
      => pay_prf_shd.g_old_rec.attribute12
      ,p_attribute13_o
      => pay_prf_shd.g_old_rec.attribute13
      ,p_attribute14_o
      => pay_prf_shd.g_old_rec.attribute14
      ,p_attribute15_o
      => pay_prf_shd.g_old_rec.attribute15
      ,p_attribute16_o
      => pay_prf_shd.g_old_rec.attribute16
      ,p_attribute17_o
      => pay_prf_shd.g_old_rec.attribute17
      ,p_attribute18_o
      => pay_prf_shd.g_old_rec.attribute18
      ,p_attribute19_o
      => pay_prf_shd.g_old_rec.attribute19
      ,p_attribute20_o
      => pay_prf_shd.g_old_rec.attribute20
      ,p_attribute21_o
      => pay_prf_shd.g_old_rec.attribute21
      ,p_attribute22_o
      => pay_prf_shd.g_old_rec.attribute22
      ,p_attribute23_o
      => pay_prf_shd.g_old_rec.attribute23
      ,p_attribute24_o
      => pay_prf_shd.g_old_rec.attribute24
      ,p_attribute25_o
      => pay_prf_shd.g_old_rec.attribute25
      ,p_attribute26_o
      => pay_prf_shd.g_old_rec.attribute26
      ,p_attribute27_o
      => pay_prf_shd.g_old_rec.attribute27
      ,p_attribute28_o
      => pay_prf_shd.g_old_rec.attribute28
      ,p_attribute29_o
      => pay_prf_shd.g_old_rec.attribute29
      ,p_attribute30_o
      => pay_prf_shd.g_old_rec.attribute30
      ,p_ran_information_category_o
      => pay_prf_shd.g_old_rec.ran_information_category
      ,p_ran_information1_o
      => pay_prf_shd.g_old_rec.ran_information1
      ,p_ran_information2_o
      => pay_prf_shd.g_old_rec.ran_information2
      ,p_ran_information3_o
      => pay_prf_shd.g_old_rec.ran_information3
      ,p_ran_information4_o
      => pay_prf_shd.g_old_rec.ran_information4
      ,p_ran_information5_o
      => pay_prf_shd.g_old_rec.ran_information5
      ,p_ran_information6_o
      => pay_prf_shd.g_old_rec.ran_information6
      ,p_ran_information7_o
      => pay_prf_shd.g_old_rec.ran_information7
      ,p_ran_information8_o
      => pay_prf_shd.g_old_rec.ran_information8
      ,p_ran_information9_o
      => pay_prf_shd.g_old_rec.ran_information9
      ,p_ran_information10_o
      => pay_prf_shd.g_old_rec.ran_information10
      ,p_ran_information11_o
      => pay_prf_shd.g_old_rec.ran_information11
      ,p_ran_information12_o
      => pay_prf_shd.g_old_rec.ran_information12
      ,p_ran_information13_o
      => pay_prf_shd.g_old_rec.ran_information13
      ,p_ran_information14_o
      => pay_prf_shd.g_old_rec.ran_information14
      ,p_ran_information15_o
      => pay_prf_shd.g_old_rec.ran_information15
      ,p_ran_information16_o
      => pay_prf_shd.g_old_rec.ran_information16
      ,p_ran_information17_o
      => pay_prf_shd.g_old_rec.ran_information17
      ,p_ran_information18_o
      => pay_prf_shd.g_old_rec.ran_information18
      ,p_ran_information19_o
      => pay_prf_shd.g_old_rec.ran_information19
      ,p_ran_information20_o
      => pay_prf_shd.g_old_rec.ran_information20
      ,p_ran_information21_o
      => pay_prf_shd.g_old_rec.ran_information21
      ,p_ran_information22_o
      => pay_prf_shd.g_old_rec.ran_information22
      ,p_ran_information23_o
      => pay_prf_shd.g_old_rec.ran_information23
      ,p_ran_information24_o
      => pay_prf_shd.g_old_rec.ran_information24
      ,p_ran_information25_o
      => pay_prf_shd.g_old_rec.ran_information25
      ,p_ran_information26_o
      => pay_prf_shd.g_old_rec.ran_information26
      ,p_ran_information27_o
      => pay_prf_shd.g_old_rec.ran_information27
      ,p_ran_information28_o
      => pay_prf_shd.g_old_rec.ran_information28
      ,p_ran_information29_o
      => pay_prf_shd.g_old_rec.ran_information29
      ,p_ran_information30_o
      => pay_prf_shd.g_old_rec.ran_information30
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PAY_RANGE_TABLES_F'
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
  (p_rec              in pay_prf_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  pay_prf_shd.lck
    (p_rec.range_table_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  pay_prf_bus.delete_validate(p_rec);
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-delete operation
  --
  pay_prf_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  pay_prf_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
 -- Commented Because not supported as of now.
 /*
 pay_prf_del.post_delete(p_rec);
 */
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
  (p_range_table_id                       in     number
  ,p_object_version_number                in     number
  ) is
--
  l_rec   pay_prf_shd.g_rec_type;
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
  l_rec.range_table_id := p_range_table_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the pay_prf_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  pay_prf_del.del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end pay_prf_del;

/
