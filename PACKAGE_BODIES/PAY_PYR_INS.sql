--------------------------------------------------------
--  DDL for Package Body PAY_PYR_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PYR_INS" as
/* $Header: pypyrrhi.pkb 115.3 2003/09/15 04:18:59 adhunter noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  VARCHAR2(33) := '  pay_pyr_ins.';  -- Global package name
--
-- The following global variables are only to be used by
-- the set_base_key_value AND pre_insert procedures.
--
g_rate_id_i  NUMBER   DEFAULT NULL;
--
-- ----------------------------------------------------------------------------
-- |------------------------< set_base_key_value >----------------------------|
-- ----------------------------------------------------------------------------
procedure set_base_key_value
  (p_rate_id  IN  NUMBER) IS
--
  l_proc       VARCHAR2(72) := g_package||'set_base_key_value';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 10);
  --
  pay_pyr_ins.g_rate_id_i := p_rate_id;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 20);
END set_base_key_value;
--
--
-- ----------------------------------------------------------------------------
-- |------------------------------< insert_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml insert logic. The processing of
--   this procedure are as follows:
--   1) Initialise the object_version_number to 1 IF the object_version_number
--      IS defined as an attribute for this entity.
--   2) To set AND unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To insert the row INTO the schema.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Prerequisites:
--   This IS an internal private procedure which must be called FROM the ins
--   procedure AND must have all mandatory attributes set (except the
--   object_version_number which IS initialised within this procedure).
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be inserted INTO the schema.
--
-- Post Failure:
--   On the insert dml failure it IS important to note that we always reset the
--   g_api_dml status to FALSE.
--   IF a check, unique or parent integrity constraint violation IS raised the
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
PROCEDURE insert_dml
  (p_rec IN OUT NOCOPY pay_pyr_shd.g_rec_type
  ) IS
--
  l_proc  VARCHAR2(72) := g_package||'insert_dml';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_rec.object_version_number := 1;  -- Initialise the object version
  --
  pay_pyr_shd.g_api_dml := TRUE;  -- Set the api dml status
  --
  -- Insert the row INTO: pay_rates
  --
  insert INTO pay_rates
      (rate_id
      ,business_group_id
      ,parent_spine_id
      ,name
      ,rate_type
      ,rate_uom
      ,comments
      ,request_id
      ,program_application_id
      ,program_id
      ,program_update_date
      ,attribute_category
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
      ,attribute6
      ,attribute7
      ,attribute8
      ,attribute9
      ,attribute10
      ,attribute11
      ,attribute12
      ,attribute13
      ,attribute14
      ,attribute15
      ,attribute16
      ,attribute17
      ,attribute18
      ,attribute19
      ,attribute20
      ,rate_basis
      ,asg_rate_type
      ,object_version_number
      )
  Values
    (p_rec.rate_id
    ,p_rec.business_group_id
    ,p_rec.parent_spine_id
    ,p_rec.name
    ,p_rec.rate_type
    ,p_rec.rate_uom
    ,p_rec.comments
    ,p_rec.request_id
    ,p_rec.program_application_id
    ,p_rec.program_id
    ,p_rec.program_update_date
    ,p_rec.attribute_category
    ,p_rec.attribute1
    ,p_rec.attribute2
    ,p_rec.attribute3
    ,p_rec.attribute4
    ,p_rec.attribute5
    ,p_rec.attribute6
    ,p_rec.attribute7
    ,p_rec.attribute8
    ,p_rec.attribute9
    ,p_rec.attribute10
    ,p_rec.attribute11
    ,p_rec.attribute12
    ,p_rec.attribute13
    ,p_rec.attribute14
    ,p_rec.attribute15
    ,p_rec.attribute16
    ,p_rec.attribute17
    ,p_rec.attribute18
    ,p_rec.attribute19
    ,p_rec.attribute20
    ,p_rec.rate_basis
    ,p_rec.asg_rate_type
    ,p_rec.object_version_number
    );
  --
  pay_pyr_shd.g_api_dml := FALSE;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
EXCEPTION
  WHEN hr_api.check_integrity_violated THEN
    -- A check constraint has been violated
    pay_pyr_shd.g_api_dml := FALSE;   -- Unset the api dml status
    pay_pyr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  WHEN hr_api.parent_integrity_violated THEN
    -- Parent integrity has been violated
    pay_pyr_shd.g_api_dml := FALSE;   -- Unset the api dml status
    pay_pyr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  WHEN hr_api.unique_integrity_violated THEN
    -- Unique integrity has been violated
    pay_pyr_shd.g_api_dml := FALSE;   -- Unset the api dml status
    pay_pyr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  WHEN Others THEN
    pay_pyr_shd.g_api_dml := FALSE;   -- Unset the api dml status
    Raise;
END insert_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_insert >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which IS required before
--   the insert dml. Presently, IF the entity has a corresponding primary
--   key which IS maintained by an associating sequence, the primary key for
--   the entity will be populated with the next sequence value IN
--   preparation for the insert dml.
--
-- Prerequisites:
--   This IS an internal procedure which IS called FROM the ins procedure.
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
  (p_rec  IN OUT NOCOPY pay_pyr_shd.g_rec_type
  ) IS
--
  CURSOR C_Sel1 IS SELECT pay_rates_s.nextval FROM sys.dual;
--
  CURSOR C_Sel2 IS
    Select NULL
      FROM pay_rates
     WHERE rate_id =
             pay_pyr_ins.g_rate_id_i;
--
  l_proc   VARCHAR2(72) := g_package||'pre_insert';
  l_exists VARCHAR2(1);
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  IF (pay_pyr_ins.g_rate_id_i IS not NULL) THEN
    --
    -- Verify registered primary key values not already IN use
    --
    OPEN C_Sel2;
    FETCH C_Sel2 INTO l_exists;
    IF C_Sel2%found THEN
       CLOSE C_Sel2;
       --
       -- The primary key values are already IN use.
       --
       fnd_message.set_name('PER','PER_289391_KEY_ALREADY_USED');
       fnd_message.set_token('TABLE_NAME','pay_rates');
       fnd_message.raise_error;
    END IF;
    CLOSE C_Sel2;
    --
    -- Use registered key values AND clear globals
    --
    p_rec.rate_id :=
      pay_pyr_ins.g_rate_id_i;
    pay_pyr_ins.g_rate_id_i := NULL;
  ELSE
    --
    -- No registerd key values, so SELECT the next sequence NUMBER
    --
    --
    -- Select the next sequence NUMBER
    --
    OPEN C_Sel1;
    FETCH C_Sel1 INTO p_rec.rate_id;
    CLOSE C_Sel1;
  END IF;
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
--   This IS an internal procedure which IS called FROM the ins procedure.
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
  ,p_rec                          IN pay_pyr_shd.g_rec_type
  ) IS
--
  l_proc  VARCHAR2(72) := g_package||'post_insert';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  BEGIN
    --
    pay_pyr_rki.after_insert
      (p_effective_date              => p_effective_date
      ,p_rate_id
      => p_rec.rate_id
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_parent_spine_id
      => p_rec.parent_spine_id
      ,p_name
      => p_rec.name
      ,p_rate_type
      => p_rec.rate_type
      ,p_rate_uom
      => p_rec.rate_uom
      ,p_comments
      => p_rec.comments
      ,p_request_id
      => p_rec.request_id
      ,p_program_application_id
      => p_rec.program_application_id
      ,p_program_id
      => p_rec.program_id
      ,p_program_update_date
      => p_rec.program_update_date
      ,p_attribute_category
      => p_rec.attribute_category
      ,p_attribute1
      => p_rec.attribute1
      ,p_attribute2
      => p_rec.attribute2
      ,p_attribute3
      => p_rec.attribute3
      ,p_attribute4
      => p_rec.attribute4
      ,p_attribute5
      => p_rec.attribute5
      ,p_attribute6
      => p_rec.attribute6
      ,p_attribute7
      => p_rec.attribute7
      ,p_attribute8
      => p_rec.attribute8
      ,p_attribute9
      => p_rec.attribute9
      ,p_attribute10
      => p_rec.attribute10
      ,p_attribute11
      => p_rec.attribute11
      ,p_attribute12
      => p_rec.attribute12
      ,p_attribute13
      => p_rec.attribute13
      ,p_attribute14
      => p_rec.attribute14
      ,p_attribute15
      => p_rec.attribute15
      ,p_attribute16
      => p_rec.attribute16
      ,p_attribute17
      => p_rec.attribute17
      ,p_attribute18
      => p_rec.attribute18
      ,p_attribute19
      => p_rec.attribute19
      ,p_attribute20
      => p_rec.attribute20
      ,p_rate_basis
      => p_rec.rate_basis
      ,p_asg_rate_type
      => p_rec.asg_rate_type
      ,p_object_version_number
      => p_rec.object_version_number
      );
    --
  exception
    --
    when hr_api.cannot_find_prog_unit THEN
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'PAY_RATES'
        ,p_hook_type   => 'AI');
      --
  END;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END post_insert;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE ins
  (p_effective_date               IN DATE
  ,p_rec                          IN OUT NOCOPY pay_pyr_shd.g_rec_type
  ) IS
--
  l_proc  VARCHAR2(72) := g_package||'ins';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call the supporting insert validate operations
  --
  pay_pyr_bus.insert_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-insert operation
  --
  pay_pyr_ins.pre_insert(p_rec);
  --
  -- Insert the row
  --
  pay_pyr_ins.insert_dml(p_rec);
  --
  -- Call the supporting post-insert operation
  --
  pay_pyr_ins.post_insert
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  hr_utility.set_location('Leaving:'||l_proc, 20);
END ins;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE ins
  (p_effective_date                 IN            DATE
  ,p_business_group_id              IN            NUMBER
  ,p_name                           IN            VARCHAR2
  ,p_rate_type                      IN            VARCHAR2
  ,p_rate_uom                       IN            VARCHAR2
  ,p_parent_spine_id                IN            NUMBER   DEFAULT NULL
  ,p_comments                       IN            VARCHAR2 DEFAULT NULL
  ,p_request_id                     IN            NUMBER   DEFAULT NULL
  ,p_program_application_id         IN            NUMBER   DEFAULT NULL
  ,p_program_id                     IN            NUMBER   DEFAULT NULL
  ,p_program_update_date            IN            DATE     DEFAULT NULL
  ,p_attribute_category             IN            VARCHAR2 DEFAULT NULL
  ,p_attribute1                     IN            VARCHAR2 DEFAULT NULL
  ,p_attribute2                     IN            VARCHAR2 DEFAULT NULL
  ,p_attribute3                     IN            VARCHAR2 DEFAULT NULL
  ,p_attribute4                     IN            VARCHAR2 DEFAULT NULL
  ,p_attribute5                     IN            VARCHAR2 DEFAULT NULL
  ,p_attribute6                     IN            VARCHAR2 DEFAULT NULL
  ,p_attribute7                     IN            VARCHAR2 DEFAULT NULL
  ,p_attribute8                     IN            VARCHAR2 DEFAULT NULL
  ,p_attribute9                     IN            VARCHAR2 DEFAULT NULL
  ,p_attribute10                    IN            VARCHAR2 DEFAULT NULL
  ,p_attribute11                    IN            VARCHAR2 DEFAULT NULL
  ,p_attribute12                    IN            VARCHAR2 DEFAULT NULL
  ,p_attribute13                    IN            VARCHAR2 DEFAULT NULL
  ,p_attribute14                    IN            VARCHAR2 DEFAULT NULL
  ,p_attribute15                    IN            VARCHAR2 DEFAULT NULL
  ,p_attribute16                    IN            VARCHAR2 DEFAULT NULL
  ,p_attribute17                    IN            VARCHAR2 DEFAULT NULL
  ,p_attribute18                    IN            VARCHAR2 DEFAULT NULL
  ,p_attribute19                    IN            VARCHAR2 DEFAULT NULL
  ,p_attribute20                    IN            VARCHAR2 DEFAULT NULL
  ,p_rate_basis                     IN            VARCHAR2 DEFAULT NULL
  ,p_asg_rate_type                  IN            VARCHAR2 DEFAULT NULL
  ,p_rate_id                           OUT NOCOPY NUMBER
  ,p_object_version_number             OUT NOCOPY NUMBER
  ) IS
--
  l_rec   pay_pyr_shd.g_rec_type;
  l_proc  VARCHAR2(72) := g_package||'ins';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments INTO the
  -- p_rec structure.
  --
  l_rec :=
  pay_pyr_shd.convert_args
    (NULL
    ,p_business_group_id
    ,p_parent_spine_id
    ,p_name
    ,p_rate_type
    ,p_rate_uom
    ,p_comments
    ,p_attribute_category
    ,p_attribute1
    ,p_attribute2
    ,p_attribute3
    ,p_attribute4
    ,p_attribute5
    ,p_attribute6
    ,p_attribute7
    ,p_attribute8
    ,p_attribute9
    ,p_attribute10
    ,p_attribute11
    ,p_attribute12
    ,p_attribute13
    ,p_attribute14
    ,p_attribute15
    ,p_attribute16
    ,p_attribute17
    ,p_attribute18
    ,p_attribute19
    ,p_attribute20
    ,p_rate_basis
    ,p_asg_rate_type
    ,NULL
    );
  --
  -- Having converted the arguments INTO the pay_pyr_rec
  -- plsql record structure we call the corresponding record business process.
  --
  pay_pyr_ins.ins
     (p_effective_date
     ,l_rec
     );
  --
  -- As the primary key argument(s)
  -- are specified as an OUT's we must set these values.
  --
  p_rate_id := l_rec.rate_id;
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END ins;
--
END pay_pyr_ins;

/
