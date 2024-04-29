--------------------------------------------------------
--  DDL for Package Body PER_PCE_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PCE_UPD" as
/* $Header: pepcerhi.pkb 120.1 2006/10/18 09:19:34 grreddy noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  VARCHAR2(33) := '  per_pce_upd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml update logic. The processing of
--   this procedure IS:
--   1) Increment the object_version_number by 1 if the object_version_number
--      IS defined as an attribute for this entity.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To update the specified row IN the schema using the primary key IN
--      the predicates.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Prerequisites:
--   This IS an internal private procedure which must be called from the upd
--   procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be updated IN the schema.
--
-- Post Failure:
--   On the update dml failure it IS important to note that we always reset the
--   g_api_dml status to false.
--   If a check, unique or parent integrity constraint violation IS raised the
--   constraint_error procedure will be called.
--   If any other error IS reported, the error will be raised after the
--   g_api_dml status IS reset.
--
-- Developer Implementation Notes:
--   The update 'set' attribute list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {END Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE update_dml
  (p_rec IN OUT NOCOPY per_pce_shd.g_rec_type
  ) IS
--
  l_proc  VARCHAR2(72) := g_package||'update_dml';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Increment the object version
  p_rec.object_version_number := p_rec.object_version_number + 1;
  --
  --
  --
  -- Update the per_cagr_entitlements Row
  --
  update per_cagr_entitlements
    set
     cagr_entitlement_id             = p_rec.cagr_entitlement_id
    ,cagr_entitlement_item_id        = p_rec.cagr_entitlement_item_id
    ,collective_agreement_id         = p_rec.collective_agreement_id
    ,status                          = p_rec.status
	,end_date                        = p_rec.end_date
    ,formula_criteria                = p_rec.formula_criteria
    ,formula_id                      = p_rec.formula_id
    ,units_of_measure                = p_rec.units_of_measure
	,message_level                   = p_rec.message_level
    ,object_version_number           = p_rec.object_version_number
    where cagr_entitlement_id = p_rec.cagr_entitlement_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
EXCEPTION
  WHEN hr_api.check_integrity_violated THEN
    -- A check constraint has been violated
    --
    per_pce_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  WHEN hr_api.parent_integrity_violated THEN
    -- Parent integrity has been violated
    --
    per_pce_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  WHEN hr_api.unique_integrity_violated THEN
    -- Unique integrity has been violated
    --
    per_pce_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  WHEN Others THEN
    --
    RAISE;
END update_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which IS required before
--   the update dml.
--
-- Prerequisites:
--   This IS an internal procedure which IS called from the upd procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   If an error has occurred, an error message and exception wil be raised
--   but not handled.
--
-- Developer Implementation Notes:
--   Any pre-processing required before the update dml IS issued should be
--   coded within this procedure. It IS important to note that any 3rd party
--   maintenance should be reviewed before placing IN this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {END Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE pre_update
  (p_rec IN per_pce_shd.g_rec_type
  ) IS
--
  l_proc  VARCHAR2(72) := g_package||'pre_update';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END pre_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which IS required after
--   the update dml.
--
-- Prerequisites:
--   This IS an internal procedure which IS called from the upd procedure.
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
--   Any post-processing required after the update dml IS issued should be
--   coded within this procedure. It IS important to note that any 3rd party
--   maintenance should be reviewed before placing IN this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {END Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE post_update
  (p_effective_date               IN DATE
  ,p_rec                          IN per_pce_shd.g_rec_type
  ) IS
--
  l_proc  VARCHAR2(72) := g_package||'post_update';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    per_pce_rku.after_update
      (p_effective_date              => p_effective_date
      ,p_cagr_entitlement_id         => p_rec.cagr_entitlement_id
      ,p_cagr_entitlement_item_id    => p_rec.cagr_entitlement_item_id
      ,p_collective_agreement_id     => p_rec.collective_agreement_id
      ,p_start_date                  => p_rec.start_date
      ,p_end_date                    => p_rec.end_date
      ,p_status                      => p_rec.status
      ,p_formula_criteria            => p_rec.formula_criteria
      ,p_formula_id                  => p_rec.formula_id
      ,p_units_of_measure            => p_rec.units_of_measure
	  ,p_message_level               => p_rec.message_level
      ,p_object_version_number       => p_rec.object_version_number
      ,p_cagr_entitlement_item_id_o  => per_pce_shd.g_old_rec.cagr_entitlement_item_id
      ,p_collective_agreement_id_o   => per_pce_shd.g_old_rec.collective_agreement_id
      ,p_start_date_o                => per_pce_shd.g_old_rec.start_date
      ,p_end_date_o                  => per_pce_shd.g_old_rec.end_date
      ,p_status_o                    => per_pce_shd.g_old_rec.status
      ,p_formula_criteria_o          => per_pce_shd.g_old_rec.formula_criteria
      ,p_formula_id_o                => per_pce_shd.g_old_rec.formula_id
      ,p_units_of_measure_o          => per_pce_shd.g_old_rec.units_of_measure
	  ,p_message_level_o             => per_pce_shd.g_old_rec.message_level
      ,p_object_version_number_o     => per_pce_shd.g_old_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_CAGR_ENTITLEMENTS'
        ,p_hook_type   => 'AU');
      --
  end;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END post_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< convert_defs >-----------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   The Convert_Defs procedure has one very important function:
--   It must return the record structure for the row with all system defaulted
--   values converted into its corresponding parameter value for update. WHEN
--   we attempt to update a row through the Upd process , certain
--   parameters can be defaulted which enables flexibility IN the calling of
--   the upd process (e.g. only attributes which need to be updated need to be
--   specified). For the upd process to determine which attributes
--   have NOT been specified we need to check if the parameter has a reserved
--   system DEFAULT value. Therefore, for all parameters which have a
--   corresponding reserved system DEFAULT mechanism specified we need to
--   check if a system DEFAULT IS being used. If a system DEFAULT IS being
--   used then we convert the defaulted value into its corresponding attribute
--   value held IN the g_old_rec data structure.
--
-- Prerequisites:
--   This private function can only be called from the upd process.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   The record structure will be returned with all system defaulted parameter
--   values converted into its current row attribute value.
--
-- Post Failure:
--   No direct error handling IS required within this function. Any possible
--   errors within this procedure will be a PL/SQL value error due to
--   conversion of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {END Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE convert_defs
  (p_rec IN OUT NOCOPY per_pce_shd.g_rec_type
  ) IS
--
BEGIN
  --
  -- We must now examine each argument value IN the
  -- p_rec plsql record structure
  -- to see if a system DEFAULT IS being used. If a system DEFAULT
  -- IS being used then we must set to the 'current' argument value.
  --
  If (p_rec.cagr_entitlement_item_id = hr_api.g_number) then
    p_rec.cagr_entitlement_item_id :=
    per_pce_shd.g_old_rec.cagr_entitlement_item_id;
  END If;
  If (p_rec.collective_agreement_id = hr_api.g_number) then
    p_rec.collective_agreement_id :=
    per_pce_shd.g_old_rec.collective_agreement_id;
  END If;
  If (p_rec.start_date = hr_api.g_date) then
    p_rec.start_date :=
    per_pce_shd.g_old_rec.start_date;
  END If;
  If (p_rec.end_date = hr_api.g_date) then
    p_rec.end_date :=
    per_pce_shd.g_old_rec.end_date;
  END If;
  If (p_rec.status = hr_api.g_VARCHAR2) then
    p_rec.status :=
    per_pce_shd.g_old_rec.status;
  END If;
  If (p_rec.formula_criteria = hr_api.g_VARCHAR2) then
    p_rec.formula_criteria :=
    per_pce_shd.g_old_rec.formula_criteria;
  END If;
  If (p_rec.formula_id = hr_api.g_number) then
    p_rec.formula_id :=
    per_pce_shd.g_old_rec.formula_id;
  END If;
  If (p_rec.units_of_measure = hr_api.g_VARCHAR2) then
    p_rec.units_of_measure := per_pce_shd.g_old_rec.units_of_measure;
  END If;
  --
  IF (p_rec.message_level = hr_api.g_VARCHAR2) then
    p_rec.message_level := per_pce_shd.g_old_rec.message_level;
  END IF;
  --
END convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE upd
  (p_effective_date               IN DATE
  ,p_rec                          IN OUT NOCOPY per_pce_shd.g_rec_type
  ) IS
--
  l_proc  VARCHAR2(72) := g_package||'upd';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  per_pce_shd.lck
    (p_rec.cagr_entitlement_id
    ,p_rec.object_version_number
    );
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  convert_defs(p_rec);
  --
  per_pce_bus.update_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call the supporting pre-update operation
  --
  per_pce_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  per_pce_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  per_pce_upd.post_update
     (p_effective_date
     ,p_rec
     );
END upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE upd
  (p_effective_date               IN     DATE
  ,p_cagr_entitlement_id          IN     NUMBER
  ,p_object_version_number        IN OUT NOCOPY NUMBER
  ,p_cagr_entitlement_item_id     IN     NUMBER    DEFAULT hr_api.g_number
  ,p_collective_agreement_id      IN     NUMBER    DEFAULT hr_api.g_number
  ,p_status                       IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_end_date                     IN     DATE      DEFAULT hr_api.g_date
  ,p_formula_criteria             IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_formula_id                   IN     NUMBER    DEFAULT hr_api.g_number
  ,p_units_of_measure             IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_message_level                IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ) IS
  --
  l_rec   per_pce_shd.g_rec_type;
  l_proc  VARCHAR2(72) := g_package||'upd';
  --
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  per_pce_shd.convert_args
  (p_cagr_entitlement_id
  ,p_cagr_entitlement_item_id
  ,p_collective_agreement_id
  ,NULL -- p_start_date
  ,p_end_date
  ,p_status
  ,p_formula_criteria
  ,p_formula_id
  ,p_units_of_measure
  ,p_message_level
  ,p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  per_pce_upd.upd
     (p_effective_date
     ,l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END upd;
--
end per_pce_upd;

/
