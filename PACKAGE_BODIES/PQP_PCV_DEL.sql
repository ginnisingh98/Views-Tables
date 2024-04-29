--------------------------------------------------------
--  DDL for Package Body PQP_PCV_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_PCV_DEL" as
/* $Header: pqpcvrhi.pkb 120.0 2005/05/29 01:55:22 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  pqp_pcv_del.';  -- Global package name
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
  (p_rec in pqp_pcv_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'delete_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  -- Delete the pqp_configuration_values row.
  --
  delete from pqp_configuration_values
  where configuration_value_id = p_rec.configuration_value_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    --
    pqp_pcv_shd.constraint_error
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
Procedure pre_delete(p_rec in pqp_pcv_shd.g_rec_type) is
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
Procedure post_delete(p_rec in pqp_pcv_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_delete';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    -- Delete ownerships if applicable
    delete_app_ownerships
      ('CONFIGURATION_VALUE_ID', p_rec.configuration_value_id
      );
    --
    pqp_pcv_rkd.after_delete
      (p_configuration_value_id
      => p_rec.configuration_value_id
      ,p_business_group_id_o
      => pqp_pcv_shd.g_old_rec.business_group_id
      ,p_legislation_code_o
      => pqp_pcv_shd.g_old_rec.legislation_code
      ,p_pcv_attribute_category_o
      => pqp_pcv_shd.g_old_rec.pcv_attribute_category
      ,p_pcv_attribute1_o
      => pqp_pcv_shd.g_old_rec.pcv_attribute1
      ,p_pcv_attribute2_o
      => pqp_pcv_shd.g_old_rec.pcv_attribute2
      ,p_pcv_attribute3_o
      => pqp_pcv_shd.g_old_rec.pcv_attribute3
      ,p_pcv_attribute4_o
      => pqp_pcv_shd.g_old_rec.pcv_attribute4
      ,p_pcv_attribute5_o
      => pqp_pcv_shd.g_old_rec.pcv_attribute5
      ,p_pcv_attribute6_o
      => pqp_pcv_shd.g_old_rec.pcv_attribute6
      ,p_pcv_attribute7_o
      => pqp_pcv_shd.g_old_rec.pcv_attribute7
      ,p_pcv_attribute8_o
      => pqp_pcv_shd.g_old_rec.pcv_attribute8
      ,p_pcv_attribute9_o
      => pqp_pcv_shd.g_old_rec.pcv_attribute9
      ,p_pcv_attribute10_o
      => pqp_pcv_shd.g_old_rec.pcv_attribute10
      ,p_pcv_attribute11_o
      => pqp_pcv_shd.g_old_rec.pcv_attribute11
      ,p_pcv_attribute12_o
      => pqp_pcv_shd.g_old_rec.pcv_attribute12
      ,p_pcv_attribute13_o
      => pqp_pcv_shd.g_old_rec.pcv_attribute13
      ,p_pcv_attribute14_o
      => pqp_pcv_shd.g_old_rec.pcv_attribute14
      ,p_pcv_attribute15_o
      => pqp_pcv_shd.g_old_rec.pcv_attribute15
      ,p_pcv_attribute16_o
      => pqp_pcv_shd.g_old_rec.pcv_attribute16
      ,p_pcv_attribute17_o
      => pqp_pcv_shd.g_old_rec.pcv_attribute17
      ,p_pcv_attribute18_o
      => pqp_pcv_shd.g_old_rec.pcv_attribute18
      ,p_pcv_attribute19_o
      => pqp_pcv_shd.g_old_rec.pcv_attribute19
      ,p_pcv_attribute20_o
      => pqp_pcv_shd.g_old_rec.pcv_attribute20
      ,p_pcv_information_category_o
      => pqp_pcv_shd.g_old_rec.pcv_information_category
      ,p_pcv_information1_o
      => pqp_pcv_shd.g_old_rec.pcv_information1
      ,p_pcv_information2_o
      => pqp_pcv_shd.g_old_rec.pcv_information2
      ,p_pcv_information3_o
      => pqp_pcv_shd.g_old_rec.pcv_information3
      ,p_pcv_information4_o
      => pqp_pcv_shd.g_old_rec.pcv_information4
      ,p_pcv_information5_o
      => pqp_pcv_shd.g_old_rec.pcv_information5
      ,p_pcv_information6_o
      => pqp_pcv_shd.g_old_rec.pcv_information6
      ,p_pcv_information7_o
      => pqp_pcv_shd.g_old_rec.pcv_information7
      ,p_pcv_information8_o
      => pqp_pcv_shd.g_old_rec.pcv_information8
      ,p_pcv_information9_o
      => pqp_pcv_shd.g_old_rec.pcv_information9
      ,p_pcv_information10_o
      => pqp_pcv_shd.g_old_rec.pcv_information10
      ,p_pcv_information11_o
      => pqp_pcv_shd.g_old_rec.pcv_information11
      ,p_pcv_information12_o
      => pqp_pcv_shd.g_old_rec.pcv_information12
      ,p_pcv_information13_o
      => pqp_pcv_shd.g_old_rec.pcv_information13
      ,p_pcv_information14_o
      => pqp_pcv_shd.g_old_rec.pcv_information14
      ,p_pcv_information15_o
      => pqp_pcv_shd.g_old_rec.pcv_information15
      ,p_pcv_information16_o
      => pqp_pcv_shd.g_old_rec.pcv_information16
      ,p_pcv_information17_o
      => pqp_pcv_shd.g_old_rec.pcv_information17
      ,p_pcv_information18_o
      => pqp_pcv_shd.g_old_rec.pcv_information18
      ,p_pcv_information19_o
      => pqp_pcv_shd.g_old_rec.pcv_information19
      ,p_pcv_information20_o
      => pqp_pcv_shd.g_old_rec.pcv_information20
      ,p_object_version_number_o
      => pqp_pcv_shd.g_old_rec.object_version_number
      ,p_configuration_name_o
      => pqp_pcv_shd.g_old_rec.configuration_name

      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PQP_CONFIGURATION_VALUES'
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
  (p_rec              in pqp_pcv_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'del';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  pqp_pcv_shd.lck
    (p_rec.configuration_value_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  pqp_pcv_bus.delete_validate(p_rec);
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-delete operation
  --
  pqp_pcv_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  pqp_pcv_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  pqp_pcv_del.post_delete(p_rec);
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
  (p_configuration_value_id               in     number
  ,p_object_version_number                in     number
  ) is
--
  l_rec   pqp_pcv_shd.g_rec_type;
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
  l_rec.configuration_value_id := p_configuration_value_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the pqp_pcv_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  pqp_pcv_del.del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;
--
end pqp_pcv_del;

/
