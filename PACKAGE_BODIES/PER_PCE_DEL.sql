--------------------------------------------------------
--  DDL for Package Body PER_PCE_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PCE_DEL" as
/* $Header: pepcerhi.pkb 120.1 2006/10/18 09:19:34 grreddy noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  VARCHAR2(33) := '  per_pce_del.';  -- Global package name
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
--   2) To delete the specified row from the schema using the primary key IN
--      the predicates.
--   3) To trap any constraint violations that may have occurred.
--   4) To raise any other errors.
--
-- Prerequisites:
--   This IS an internal private procedure which must be called from the del
--   procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be delete from the schema.
--
-- Post Failure:
--   On the delete dml failure it IS important to note that we always reset the
--   g_api_dml status to false.
--   If a child integrity constraint violation IS raised the
--   constraint_error procedure will be called.
--   If any other error IS reported, the error will be raised after the
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
  (p_rec IN per_pce_shd.g_rec_type
  ) IS
--
  l_proc  VARCHAR2(72) := g_package||'delete_dml';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  --
  -- Delete the per_cagr_entitlements row.
  --
  delete from per_cagr_entitlements
  where cagr_entitlement_id = p_rec.cagr_entitlement_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
EXCEPTION
  WHEN hr_api.child_integrity_violated then
    -- Child integrity has been violated
    --
    per_pce_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  WHEN Others THEN
    --
    RAISE;
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
--   This IS an internal procedure which IS called from the del procedure.
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
--   Any pre-processing required before the delete dml IS issued should be
--   coded within this procedure. It IS important to note that any 3rd party
--   maintenance should be reviewed before placing IN this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {END Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE pre_delete(p_rec IN per_pce_shd.g_rec_type) IS
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
--   This IS an internal procedure which IS called from the del procedure.
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
--   Any post-processing required after the delete dml IS issued should be
--   coded within this procedure. It IS important to note that any 3rd party
--   maintenance should be reviewed before placing IN this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {END Of Comments}
-- -----------------------------------------------------------------------------
PROCEDURE post_delete(p_rec IN per_pce_shd.g_rec_type) IS
--
  l_proc  VARCHAR2(72) := g_package||'post_delete';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
    begin
    --
    per_pce_rkd.after_delete
      (p_cagr_entitlement_id        => p_rec.cagr_entitlement_id
      ,p_cagr_entitlement_item_id_o => per_pce_shd.g_old_rec.cagr_entitlement_item_id
      ,p_collective_agreement_id_o  => per_pce_shd.g_old_rec.collective_agreement_id
      ,p_start_date_o               => per_pce_shd.g_old_rec.start_date
      ,p_end_date_o                 => per_pce_shd.g_old_rec.end_date
      ,p_status_o                   => per_pce_shd.g_old_rec.status
      ,p_formula_criteria_o         => per_pce_shd.g_old_rec.formula_criteria
      ,p_formula_id_o               => per_pce_shd.g_old_rec.formula_id
      ,p_units_of_measure_o         => per_pce_shd.g_old_rec.units_of_measure
	  ,p_message_level_o            => per_pce_shd.g_old_rec.message_level
      ,p_object_version_number_o    => per_pce_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_CAGR_ENTITLEMENTS'
        ,p_hook_type   => 'AD');
      --
  end;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END post_delete;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE del
  (p_rec              IN per_pce_shd.g_rec_type
  ) IS
--
  l_proc  VARCHAR2(72) := g_package||'del';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to delete.
  --
  per_pce_shd.lck
    (p_rec.cagr_entitlement_id
    ,p_rec.object_version_number
    );
  --
  -- Call the supporting delete validate operation
  --
  per_pce_bus.delete_validate(p_rec);
  --
  -- Call the supporting pre-delete operation
  --
  per_pce_del.pre_delete(p_rec);
  --
  -- Delete the row.
  --
  per_pce_del.delete_dml(p_rec);
  --
  -- Call the supporting post-delete operation
  --
  per_pce_del.post_delete(p_rec);
  --
END del;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< del >----------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE del
  (p_cagr_entitlement_id                  IN     NUMBER
  ,p_object_version_number                IN     NUMBER
  ) IS
--
  l_rec   per_pce_shd.g_rec_type;
  l_proc  VARCHAR2(72) := g_package||'del';
--
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the  arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.
  --
  l_rec.cagr_entitlement_id := p_cagr_entitlement_id;
  l_rec.object_version_number := p_object_version_number;
  --
  -- Having converted the arguments into the per_pce_rec
  -- plsql record structure we must call the corresponding entity
  -- business process
  --
  per_pce_del.del(l_rec);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END del;
--
END per_pce_del;

/
