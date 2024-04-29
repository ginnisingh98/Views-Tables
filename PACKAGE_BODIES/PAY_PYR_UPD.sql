--------------------------------------------------------
--  DDL for Package Body PAY_PYR_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PYR_UPD" as
/* $Header: pypyrrhi.pkb 115.3 2003/09/15 04:18:59 adhunter noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  VARCHAR2(33) := '  pay_pyr_upd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml update logic. The processing of
--   this procedure IS:
--   1) Increment the object_version_number by 1 IF the object_version_number
--      IS defined as an attribute for this entity.
--   2) To set AND unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To update the specified row IN the schema using the primary key IN
--      the predicates.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Prerequisites:
--   This IS an internal private procedure which must be called FROM the upd
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
--   g_api_dml status to FALSE.
--   IF a check, unique or parent integrity constraint violation IS raised the
--   constraint_error procedure will be called.
--   IF any other error IS reported, the error will be raised after the
--   g_api_dml status IS reset.
--
-- Developer Implementation Notes:
--   The update 'set' attribute list should be modified IF any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {END Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE update_dml
  (p_rec IN OUT NOCOPY pay_pyr_shd.g_rec_type
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
  pay_pyr_shd.g_api_dml := TRUE;  -- Set the api dml status
  --
  -- Update the pay_rates Row
  --
  update pay_rates
    set
     rate_id                         = p_rec.rate_id
    ,parent_spine_id                 = p_rec.parent_spine_id
    ,name                            = p_rec.name
    ,rate_uom                        = p_rec.rate_uom
    ,comments                        = p_rec.comments
    ,request_id                      = p_rec.request_id
    ,program_application_id          = p_rec.program_application_id
    ,program_id                      = p_rec.program_id
    ,program_update_date             = p_rec.program_update_date
    ,attribute_category              = p_rec.attribute_category
    ,attribute1                      = p_rec.attribute1
    ,attribute2                      = p_rec.attribute2
    ,attribute3                      = p_rec.attribute3
    ,attribute4                      = p_rec.attribute4
    ,attribute5                      = p_rec.attribute5
    ,attribute6                      = p_rec.attribute6
    ,attribute7                      = p_rec.attribute7
    ,attribute8                      = p_rec.attribute8
    ,attribute9                      = p_rec.attribute9
    ,attribute10                     = p_rec.attribute10
    ,attribute11                     = p_rec.attribute11
    ,attribute12                     = p_rec.attribute12
    ,attribute13                     = p_rec.attribute13
    ,attribute14                     = p_rec.attribute14
    ,attribute15                     = p_rec.attribute15
    ,attribute16                     = p_rec.attribute16
    ,attribute17                     = p_rec.attribute17
    ,attribute18                     = p_rec.attribute18
    ,attribute19                     = p_rec.attribute19
    ,attribute20                     = p_rec.attribute20
    ,rate_basis                      = p_rec.rate_basis
    ,asg_rate_type                   = p_rec.asg_rate_type
    ,object_version_number           = p_rec.object_version_number
    WHERE rate_id = p_rec.rate_id;
  --
  pay_pyr_shd.g_api_dml := FALSE;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
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
--   This IS an internal procedure which IS called FROM the upd procedure.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   Processing continues.
--
-- Post Failure:
--   IF an error has occurred, an error message AND exception wil be raised
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
  (p_rec IN pay_pyr_shd.g_rec_type
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
--   This IS an internal procedure which IS called FROM the upd procedure.
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
  ,p_rec                          IN pay_pyr_shd.g_rec_type
  ) IS
--
  l_proc  VARCHAR2(72) := g_package||'post_update';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  BEGIN
    --
    pay_pyr_rku.after_update
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
        ,p_hook_type   => 'AU');
      --
  END;
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
--   It must RETURN the record structure for the row with all system defaulted
--   values converted INTO its corresponding parameter value for update. WHEN
--   we attempt to update a row through the Upd process , certain
--   parameters can be defaulted which enables flexibility IN the calling of
--   the upd process (e.g. only attributes which need to be updated need to be
--   specified). For the upd process to determine which attributes
--   have NOT been specified we need to check IF the parameter has a reserved
--   system DEFAULT value. Therefore, for all parameters which have a
--   corresponding reserved system DEFAULT mechanism specified we need to
--   check IF a system DEFAULT IS being used. IF a system DEFAULT IS being
--   used THEN we convert the defaulted value INTO its corresponding attribute
--   value held IN the g_old_rec data structure.
--
-- Prerequisites:
--   This private function can only be called FROM the upd process.
--
-- In Parameters:
--   A Pl/Sql record structure.
--
-- Post Success:
--   The record structure will be returned with all system defaulted parameter
--   values converted INTO its current row attribute value.
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
  (p_rec IN OUT NOCOPY pay_pyr_shd.g_rec_type
  ) IS
--
BEGIN
  --
  -- We must now examine each argument value IN the
  -- p_rec plsql record structure
  -- to see IF a system DEFAULT IS being used. IF a system DEFAULT
  -- IS being used THEN we must set to the 'current' argument value.
  --
  IF (p_rec.business_group_id = hr_api.g_number) THEN
    p_rec.business_group_id :=
    pay_pyr_shd.g_old_rec.business_group_id;
  END IF;
  IF (p_rec.parent_spine_id = hr_api.g_number) THEN
    p_rec.parent_spine_id :=
    pay_pyr_shd.g_old_rec.parent_spine_id;
  END IF;
  IF (p_rec.name = hr_api.g_VARCHAR2) THEN
    p_rec.name :=
    pay_pyr_shd.g_old_rec.name;
  END IF;
  IF (p_rec.rate_type = hr_api.g_VARCHAR2) THEN
    p_rec.rate_type :=
    pay_pyr_shd.g_old_rec.rate_type;
  END IF;
  IF (p_rec.rate_uom = hr_api.g_VARCHAR2) THEN
    p_rec.rate_uom :=
    pay_pyr_shd.g_old_rec.rate_uom;
  END IF;
  IF (p_rec.comments = hr_api.g_VARCHAR2) THEN
    p_rec.comments :=
    pay_pyr_shd.g_old_rec.comments;
  END IF;
  IF (p_rec.request_id = hr_api.g_number) THEN
    p_rec.request_id :=
    pay_pyr_shd.g_old_rec.request_id;
  END IF;
  IF (p_rec.program_application_id = hr_api.g_number) THEN
    p_rec.program_application_id :=
    pay_pyr_shd.g_old_rec.program_application_id;
  END IF;
  IF (p_rec.program_id = hr_api.g_number) THEN
    p_rec.program_id :=
    pay_pyr_shd.g_old_rec.program_id;
  END IF;
  IF (p_rec.program_update_date = hr_api.g_date) THEN
    p_rec.program_update_date :=
    pay_pyr_shd.g_old_rec.program_update_date;
  END IF;
  IF (p_rec.attribute_category = hr_api.g_VARCHAR2) THEN
    p_rec.attribute_category :=
    pay_pyr_shd.g_old_rec.attribute_category;
  END IF;
  IF (p_rec.attribute1 = hr_api.g_VARCHAR2) THEN
    p_rec.attribute1 :=
    pay_pyr_shd.g_old_rec.attribute1;
  END IF;
  IF (p_rec.attribute2 = hr_api.g_VARCHAR2) THEN
    p_rec.attribute2 :=
    pay_pyr_shd.g_old_rec.attribute2;
  END IF;
  IF (p_rec.attribute3 = hr_api.g_VARCHAR2) THEN
    p_rec.attribute3 :=
    pay_pyr_shd.g_old_rec.attribute3;
  END IF;
  IF (p_rec.attribute4 = hr_api.g_VARCHAR2) THEN
    p_rec.attribute4 :=
    pay_pyr_shd.g_old_rec.attribute4;
  END IF;
  IF (p_rec.attribute5 = hr_api.g_VARCHAR2) THEN
    p_rec.attribute5 :=
    pay_pyr_shd.g_old_rec.attribute5;
  END IF;
  IF (p_rec.attribute6 = hr_api.g_VARCHAR2) THEN
    p_rec.attribute6 :=
    pay_pyr_shd.g_old_rec.attribute6;
  END IF;
  IF (p_rec.attribute7 = hr_api.g_VARCHAR2) THEN
    p_rec.attribute7 :=
    pay_pyr_shd.g_old_rec.attribute7;
  END IF;
  IF (p_rec.attribute8 = hr_api.g_VARCHAR2) THEN
    p_rec.attribute8 :=
    pay_pyr_shd.g_old_rec.attribute8;
  END IF;
  IF (p_rec.attribute9 = hr_api.g_VARCHAR2) THEN
    p_rec.attribute9 :=
    pay_pyr_shd.g_old_rec.attribute9;
  END IF;
  IF (p_rec.attribute10 = hr_api.g_VARCHAR2) THEN
    p_rec.attribute10 :=
    pay_pyr_shd.g_old_rec.attribute10;
  END IF;
  IF (p_rec.attribute11 = hr_api.g_VARCHAR2) THEN
    p_rec.attribute11 :=
    pay_pyr_shd.g_old_rec.attribute11;
  END IF;
  IF (p_rec.attribute12 = hr_api.g_VARCHAR2) THEN
    p_rec.attribute12 :=
    pay_pyr_shd.g_old_rec.attribute12;
  END IF;
  IF (p_rec.attribute13 = hr_api.g_VARCHAR2) THEN
    p_rec.attribute13 :=
    pay_pyr_shd.g_old_rec.attribute13;
  END IF;
  IF (p_rec.attribute14 = hr_api.g_VARCHAR2) THEN
    p_rec.attribute14 :=
    pay_pyr_shd.g_old_rec.attribute14;
  END IF;
  IF (p_rec.attribute15 = hr_api.g_VARCHAR2) THEN
    p_rec.attribute15 :=
    pay_pyr_shd.g_old_rec.attribute15;
  END IF;
  IF (p_rec.attribute16 = hr_api.g_VARCHAR2) THEN
    p_rec.attribute16 :=
    pay_pyr_shd.g_old_rec.attribute16;
  END IF;
  IF (p_rec.attribute17 = hr_api.g_VARCHAR2) THEN
    p_rec.attribute17 :=
    pay_pyr_shd.g_old_rec.attribute17;
  END IF;
  IF (p_rec.attribute18 = hr_api.g_VARCHAR2) THEN
    p_rec.attribute18 :=
    pay_pyr_shd.g_old_rec.attribute18;
  END IF;
  IF (p_rec.attribute19 = hr_api.g_VARCHAR2) THEN
    p_rec.attribute19 :=
    pay_pyr_shd.g_old_rec.attribute19;
  END IF;
  IF (p_rec.attribute20 = hr_api.g_VARCHAR2) THEN
    p_rec.attribute20 :=
    pay_pyr_shd.g_old_rec.attribute20;
  END IF;
  IF (p_rec.rate_basis = hr_api.g_VARCHAR2) THEN
    p_rec.rate_basis :=
    pay_pyr_shd.g_old_rec.rate_basis;
  END IF;
  IF (p_rec.asg_rate_type = hr_api.g_VARCHAR2) THEN
    p_rec.asg_rate_type :=
    pay_pyr_shd.g_old_rec.asg_rate_type;
  END IF;
  --
END convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE upd
  (p_effective_date               IN DATE
  ,p_rec                          IN OUT NOCOPY pay_pyr_shd.g_rec_type
  ) IS
--
  l_proc  VARCHAR2(72) := g_package||'upd';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  pay_pyr_shd.lck
    (p_rec.rate_id
    ,p_rec.object_version_number
    );
  --
  -- 1. During an update system defaults are used to determine IF
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  convert_defs(p_rec);
  pay_pyr_bus.update_validate
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  pay_pyr_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  pay_pyr_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  pay_pyr_upd.post_update
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
END upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE upd
  (p_effective_date               IN     DATE
  ,p_rate_id                      IN     NUMBER
  ,p_object_version_number        IN OUT NOCOPY NUMBER
  ,p_name                         IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_rate_uom                     IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_parent_spine_id              IN     NUMBER    DEFAULT hr_api.g_number
  ,p_comments                     IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute_category           IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute1                   IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute2                   IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute3                   IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute4                   IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute5                   IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute6                   IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute7                   IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute8                   IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute9                   IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute10                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute11                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute12                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute13                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute14                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute15                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute16                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute17                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute18                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute19                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_attribute20                  IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_rate_basis                   IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ,p_asg_rate_type                IN     VARCHAR2  DEFAULT hr_api.g_VARCHAR2
  ) IS
--
  l_rec   pay_pyr_shd.g_rec_type;
  l_proc  VARCHAR2(72) := g_package||'upd';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments INTO the
  -- l_rec structure.
  --
  l_rec :=
  pay_pyr_shd.convert_args
  (p_rate_id
  ,hr_api.g_number  --p_business_group_id
  ,p_parent_spine_id
  ,p_name
  ,hr_api.g_varchar2 --p_rate_type
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
  ,p_object_version_number
  );
  --
  -- Having converted the arguments INTO the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  pay_pyr_upd.upd
     (p_effective_date
     ,l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END upd;
--
END pay_pyr_upd;

/
