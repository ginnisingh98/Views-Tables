--------------------------------------------------------
--  DDL for Package Body PER_PCE_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PCE_INS" AS
/* $Header: pepcerhi.pkb 120.1 2006/10/18 09:19:34 grreddy noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  VARCHAR2(33) := '  per_pce_ins.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml insert logic. The processing of
--   this procedure are as follows:
--   1) Initialise the object_version_number to 1 if the object_version_number
--      IS defined as an attribute for this entity.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To insert the row into the schema.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Prerequisites:
--   This IS an internal private procedure which must be called from the ins
--   procedure and must have all mandatory attributes set (except the
--   object_version_number which IS initialised within this procedure).
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be inserted into the schema.
--
-- Post Failure:
--   On the insert dml failure it IS important to note that we always reset the
--   g_api_dml status to false.
--   If a check, unique or parent integrity constraint violation IS raised the
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
PROCEDURE insert_dml
  (p_rec IN OUT NOCOPY per_pce_shd.g_rec_type
  ) IS
--
  l_proc  VARCHAR2(72) := g_package||'insert_dml';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  --
  --
  -- Insert the row into: per_cagr_entitlements
  --
  INSERT INTO per_cagr_entitlements
      (cagr_entitlement_id
      ,cagr_entitlement_item_id
      ,collective_agreement_id
      ,start_date
      ,end_date
      ,status
      ,formula_criteria
      ,formula_id
      ,units_of_measure
	  ,message_level
      ,object_version_number
      )
  VALUES
    (p_rec.cagr_entitlement_id
    ,p_rec.cagr_entitlement_item_id
    ,p_rec.collective_agreement_id
    ,p_rec.start_date
    ,p_rec.end_date
    ,p_rec.status
    ,p_rec.formula_criteria
    ,p_rec.formula_id
    ,p_rec.units_of_measure
	,p_rec.message_level
    ,p_rec.object_version_number
    );
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
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
END insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which IS required before
--   the insert dml. Presently, if the entity has a corresponding primary
--   key which IS maintained by an associating sequence, the primary key for
--   the entity will be populated with the next sequence value IN
--   preparation for the insert dml.
--
-- Prerequisites:
--   This IS an internal procedure which IS called from the ins procedure.
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
--   Any pre-processing required before the insert dml IS issued should be
--   coded within this procedure. As stated above, a good example IS the
--   generation of a primary key NUMBER via a corresponding sequence.
--   It IS important to note that any 3rd party maintenance should be reviewed
--   before placing IN this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {END Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE pre_insert
  (p_rec  IN OUT NOCOPY per_pce_shd.g_rec_type
  ) IS
--
  l_proc  VARCHAR2(72) := g_package||'pre_insert';
--
  Cursor C_Sel1 IS select per_cagr_entitlements_s.nextval from sys.dual;
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- Select the next sequence NUMBER
  --
  Open C_Sel1;
  Fetch C_Sel1 Into p_rec.cagr_entitlement_id;
  Close C_Sel1;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END pre_insert;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which IS required after
--   the insert dml.
--
-- Prerequisites:
--   This IS an internal procedure which IS called from the ins procedure.
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
--   Any post-processing required after the insert dml IS issued should be
--   coded within this procedure. It IS important to note that any 3rd party
--   maintenance should be reviewed before placing IN this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {END Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE post_insert
  (p_effective_date               IN DATE
  ,p_rec                          IN per_pce_shd.g_rec_type
  ) IS
--
  l_proc  VARCHAR2(72) := g_package||'post_insert';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    per_pce_rki.after_insert
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
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PER_CAGR_ENTITLEMENTS'
        ,p_hook_type   => 'AI');
      --
  end;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE ins
  (p_effective_date               IN DATE
  ,p_rec                          IN OUT NOCOPY per_pce_shd.g_rec_type
  ) IS
--
  l_proc  VARCHAR2(72) := g_package||'ins';
--
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  p_rec.start_date := TRUNC(p_effective_date);
  --
  -- Call the supporting insert validate operations
  --
  per_pce_bus.insert_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call the supporting pre-insert operation
  --
  per_pce_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  per_pce_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  per_pce_ins.post_insert
     (p_effective_date
     ,p_rec
     );
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
end ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE ins
  (p_effective_date                 IN     DATE
  ,p_cagr_entitlement_item_id       IN     NUMBER
  ,p_collective_agreement_id        IN     NUMBER
  ,p_status                         IN     VARCHAR2
  ,p_formula_criteria               IN     VARCHAR2
  ,p_end_date                       IN     DATE     DEFAULT NULL
  ,p_formula_id                     IN     NUMBER   DEFAULT NULL
  ,p_units_of_measure               IN     VARCHAR2 DEFAULT NULL
  ,p_message_level                  IN     VARCHAR2
  ,p_cagr_entitlement_id               OUT NOCOPY NUMBER
  ,p_object_version_number             OUT NOCOPY NUMBER
  ) IS
  --
  l_rec   per_pce_shd.g_rec_type;
  l_proc  VARCHAR2(72) := g_package||'ins';
  l_start_date DATE;
  --
BEGIN
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  l_start_Date := TRUNC(p_effective_date);
  --
  -- Call conversion function to turn arguments into the
  -- p_rec structure.
  --
  l_rec :=
  per_pce_shd.convert_args
    (NULL
    ,p_cagr_entitlement_item_id
    ,p_collective_agreement_id
    ,l_start_date
    ,p_end_date
    ,p_status
    ,p_formula_criteria
    ,p_formula_id
    ,p_units_of_measure
	,p_message_level
    ,NULL
    );
  --
  -- Having converted the arguments into the per_pce_rec
  -- plsql record structure we call the corresponding record business process.
  --
  per_pce_ins.ins
     (p_effective_date
     ,l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_cagr_entitlement_id := l_rec.cagr_entitlement_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END ins;
--
end per_pce_ins;

/
