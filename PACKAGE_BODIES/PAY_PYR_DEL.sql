--------------------------------------------------------
--  DDL for Package Body PAY_PYR_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PYR_DEL" as
/* $Header: pypyrrhi.pkb 115.3 2003/09/15 04:18:59 adhunter noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  VARCHAR2(33) := '  pay_pyr_del.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< delete_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml delete logic. The functions of
--   this procedure are as follows:
--   1) To set AND unset the g_api_dml status as required (as we are about to
--      perform dml).
--   2) To delete the specified row FROM the schema using the primary key IN
--      the predicates.
--   3) To trap any constraint violations that may have occurred.
--   4) To raise any other errors.
--
-- Prerequisites:
--   This IS an internal private procedure which must be called FROM the del
--   procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be delete FROM the schema.
--
-- Post Failure:
--   On the delete dml failure it IS important to note that we always reset the
--   g_api_dml status to FALSE.
--   IF a child integrity constraint violation IS raised the
--   constraint_error procedure will be called.
--   IF any other error IS reported, the error will be raised after the
--   g_api_dml status IS reset.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {END Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE delete_dml
  (p_rec IN pay_pyr_shd.g_rec_type
  ) IS
--
  l_proc  VARCHAR2(72) := g_package||'delete_dml';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  pay_pyr_shd.g_api_dml := TRUE;  -- Set the api dml status
  --
  -- Delete the pay_rates row.
  --
  delete FROM pay_rates
  WHERE rate_id = p_rec.rate_id;
  --
  pay_pyr_shd.g_api_dml := FALSE;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
EXCEPTION
  WHEN hr_api.child_integrity_violated THEN
    -- Child integrity has been violated
    pay_pyr_shd.g_api_dml := FALSE;   -- Unset the api dml status
    pay_pyr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  WHEN Others THEN
    pay_pyr_shd.g_api_dml := FALSE;   -- Unset the api dml status
    Raise;
END delete_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_delete >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which IS required before
--   the delete dml.
--
-- Prerequisites:
--   This IS an internal procedure which IS called FROM the del procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   IF an error has occurred, an error message AND exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any pre-processing required before the delete dml IS issued should be
--   coded within this procedure. It IS important to note that any 3rd party
--   maintenance should be reviewed before placing IN this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {END Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE pre_delete(p_rec IN pay_pyr_shd.g_rec_type) IS
--
  l_proc  VARCHAR2(72) := g_package||'pre_delete';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END pre_delete;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_delete >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which IS required after
--   the delete dml.
--
-- Prerequistes:
--   This IS an internal procedure which IS called FROM the del procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   IF an error has occurred, an error message AND exception will be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any post-processing required after the delete dml IS issued should be
--   coded within this procedure. It IS important to note that any 3rd party
--   maintenance should be reviewed before placing IN this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {END Of Comments}
-- -----------------------------------------------------------------------------
PROCEDURE post_delete(p_rec IN pay_pyr_shd.g_rec_type) IS
--
  l_proc  VARCHAR2(72) := g_package||'post_delete';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  BEGIN
    --
    pay_pyr_rkd.after_delete
      (p_rate_id
      => p_rec.rate_id
      ,p_business_group_id_o
      => pay_pyr_shd.g_old_rec.business_group_id
      ,p_parent_spine_id_o
      => pay_pyr_shd.g_old_rec.parent_spine_id
      ,p_name_o
      => pay_pyr_shd.g_old_rec.name
      ,p_rate_type_o
      => pay_pyr_shd.g_old_rec.rate_type
      ,p_rate_uom_o
      => pay_pyr_shd.g_old_rec.rate_uom
      ,p_comments_o
      => pay_pyr_shd.g_old_rec.comments
      ,p_request_id_o
      => pay_pyr_shd.g_old_rec.request_id
      ,p_program_application_id_o
      => pay_pyr_shd.g_old_rec.program_application_id
      ,p_program_id_o
      => pay_pyr_shd.g_old_rec.program_id
      ,p_program_update_date_o
      => pay_pyr_shd.g_old_rec.program_update_date
      ,p_attribute_category_o
      => pay_pyr_shd.g_old_rec.attribute_category
      ,p_attribute1_o
      => pay_pyr_shd.g_old_rec.attribute1
      ,p_attribute2_o
      => pay_pyr_shd.g_old_rec.attribute2
      ,p_attribute3_o
      => pay_pyr_shd.g_old_rec.attribute3
      ,p_attribute4_o
      => pay_pyr_shd.g_old_rec.attribute4
      ,p_attribute5_o
      => pay_pyr_shd.g_old_rec.attribute5
      ,p_attribute6_o
      => pay_pyr_shd.g_old_rec.attribute6
      ,p_attribute7_o
      => pay_pyr_shd.g_old_rec.attribute7
      ,p_attribute8_o
      => pay_pyr_shd.g_old_rec.attribute8
      ,p_attribute9_o
      => pay_pyr_shd.g_old_rec.attribute9
      ,p_attribute10_o
      => pay_pyr_shd.g_old_rec.attribute10
      ,p_attribute11_o
      => pay_pyr_shd.g_old_rec.attribute11
      ,p_attribute12_o
      => pay_pyr_shd.g_old_rec.attribute12
      ,p_attribute13_o
      => pay_pyr_shd.g_old_rec.attribute13
      ,p_attribute14_o
      => pay_pyr_shd.g_old_rec.attribute14
      ,p_attribute15_o
      => pay_pyr_shd.g_old_rec.attribute15
      ,p_attribute16_o
      => pay_pyr_shd.g_old_rec.attribute16
      ,p_attribute17_o
      => pay_pyr_shd.g_old_rec.attribute17
      ,p_attribute18_o
      => pay_pyr_shd.g_old_rec.attribute18
      ,p_attribute19_o
      => pay_pyr_shd.g_old_rec.attribute19
      ,p_attribute20_o
      => pay_pyr_shd.g_old_rec.attribute20
      ,p_rate_basis_o
      => pay_pyr_shd.g_old_rec.rate_basis
      ,p_asg_rate_type_o
      => pay_pyr_shd.g_old_rec.asg_rate_type
      ,p_object_version_number_o
      => pay_pyr_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit THEN
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PAY_RATES'
        ,p_hook_type   => 'AD');
      --
  END;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE del
  (p_rec              IN pay_pyr_shd.g_rec_type
  ) IS
--
  l_proc  VARCHAR2(72) := g_package||'del';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  pay_pyr_shd.lck
    (p_rec.rate_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  pay_pyr_bus.delete_validate(p_rec);
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-delete operation
  --
  pay_pyr_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  pay_pyr_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  pay_pyr_del.post_delete(p_rec);
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
END del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE del
  (p_rate_id                IN  NUMBER
  ,p_object_version_number  IN  NUMBER
  ,p_rate_type              IN  VARCHAR2) IS
--
  l_rec   pay_pyr_shd.g_rec_type;
  l_proc  VARCHAR2(72) := g_package||'del';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the  arguments INTO the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  l_rec.rate_id               := p_rate_id;
  l_rec.object_version_number := p_object_version_number;
  l_rec.rate_type             := p_rate_type;
  --
  -- Having converted the arguments INTO the pay_pyr_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  pay_pyr_del.del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 999);
  --
END del;
--
END pay_pyr_del;

/
