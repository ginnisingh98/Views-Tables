--------------------------------------------------------
--  DDL for Package Body OTA_TPS_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TPS_UPD" AS
/* $Header: ottpsrhi.pkb 120.2 2005/12/14 15:17:58 asud noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ota_tps_upd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml update logic. The processing of
--   this procedure is:
--   1) Increment the object_version_number by 1 if the object_version_number
--      is defined as an attribute for this entity.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To update the specified row in the schema using the primary key in
--      the predicates.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Prerequisites:
--   This is an internal private procedure which must be called from the upd
--   procedure.
--
-- In Parameters:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The specified row will be updated in the schema.
--
-- Post Failure:
--   On the update dml failure it is important to note that we always reset the
--   g_api_dml status to false.
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.
--   If any other error is reported, the error will be raised after the
--   g_api_dml status is reset.
--
-- Developer Implementation Notes:
--   The update 'set' attribute list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE update_dml
  (p_rec IN OUT NOCOPY ota_tps_shd.g_rec_type
  ) IS
--
  l_proc  varchar2(72) := g_package||'update_dml';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Increment the object version
  p_rec.object_version_number := p_rec.object_version_number + 1;
  --
  ota_tps_shd.g_api_dml := TRUE;  -- Set the api dml status
  --
  -- Update the ota_training_plans Row
  --
  UPDATE ota_training_plans
    SET
     training_plan_id                = p_rec.training_plan_id
    ,time_period_id                  = p_rec.time_period_id
    ,plan_status_type_id             = p_rec.plan_status_type_id
    ,budget_currency                 = p_rec.budget_currency
    ,name                            = p_rec.name
    ,description                     = p_rec.description
    ,object_version_number           = p_rec.object_version_number
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
    ,attribute21                     = p_rec.attribute21
    ,attribute22                     = p_rec.attribute22
    ,attribute23                     = p_rec.attribute23
    ,attribute24                     = p_rec.attribute24
    ,attribute25                     = p_rec.attribute25
    ,attribute26                     = p_rec.attribute26
    ,attribute27                     = p_rec.attribute27
    ,attribute28                     = p_rec.attribute28
    ,attribute29                     = p_rec.attribute29
    ,attribute30                     = p_rec.attribute30
    ,plan_source                     = p_rec.plan_source  --changed
    ,start_date                      = p_rec.start_date
    ,end_date                        = p_rec.end_date
    ,creator_person_id              = p_rec.creator_person_id
    ,additional_member_flag        = p_rec.additional_member_flag
    ,learning_path_id              = p_rec.learning_path_id
    ,contact_id                         = p_rec.contact_id
    WHERE training_plan_id = p_rec.training_plan_id;
  --
  ota_tps_shd.g_api_dml := FALSE;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
EXCEPTION
  WHEN hr_api.check_integrity_violated THEN
    -- A check constraint has been violated
    ota_tps_shd.g_api_dml := FALSE;   -- Unset the api dml status
    ota_tps_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  WHEN hr_api.parent_integrity_violated THEN
    -- Parent integrity has been violated
    ota_tps_shd.g_api_dml := FALSE;   -- Unset the api dml status
    ota_tps_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  WHEN hr_api.unique_integrity_violated THEN
    -- Unique integrity has been violated
    ota_tps_shd.g_api_dml := FALSE;   -- Unset the api dml status
    ota_tps_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  WHEN Others THEN
    ota_tps_shd.g_api_dml := FALSE;   -- Unset the api dml status
    RAISE;
END update_dml;
--
-- ----------------------------------------------------------------------------
-- |------------------------------< pre_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required before
--   the update dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
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
--   Any pre-processing required before the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE pre_update
  (p_rec IN ota_tps_shd.g_rec_type
  ) IS
--
  l_proc  varchar2(72) := g_package||'pre_update';
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
--   This private procedure contains any processing which is required after the
--   update dml.
--
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
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
--   Any post-processing required after the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE post_update
  (p_effective_date               IN date
  ,p_rec                          IN ota_tps_shd.g_rec_type
  ) IS
--
  l_proc  varchar2(72) := g_package||'post_update';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  BEGIN
    --
    ota_tps_rku.after_update
      (p_effective_date              => p_effective_date
      ,p_training_plan_id
      => p_rec.training_plan_id
      ,p_time_period_id
      => p_rec.time_period_id
      ,p_plan_status_type_id
      => p_rec.plan_status_type_id
      ,p_organization_id
      => p_rec.organization_id
      ,p_person_id
      => p_rec.person_id
      ,p_budget_currency
      => p_rec.budget_currency
      ,p_name
      => p_rec.name
      ,p_description
      => p_rec.description
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_object_version_number
      => p_rec.object_version_number
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
      ,p_attribute21
      => p_rec.attribute21
      ,p_attribute22
      => p_rec.attribute22
      ,p_attribute23
      => p_rec.attribute23
      ,p_attribute24
      => p_rec.attribute24
      ,p_attribute25
      => p_rec.attribute25
      ,p_attribute26
      => p_rec.attribute26
      ,p_attribute27
      => p_rec.attribute27
      ,p_attribute28
      => p_rec.attribute28
      ,p_attribute29
      => p_rec.attribute29
      ,p_attribute30
      => p_rec.attribute30
      ,p_plan_source => p_rec.plan_source  --changed
      ,p_start_date => p_rec.start_date
      ,p_end_date => p_rec.end_date
      ,p_creator_person_id  => p_rec.creator_person_id
      ,p_additional_member_flag => p_rec.additional_member_flag
      ,p_learning_path_id => p_rec.learning_path_id
      ,p_contact_id             => p_rec.contact_id
      ,p_time_period_id_o
      => ota_tps_shd.g_old_rec.time_period_id
      ,p_plan_status_type_id_o
      => ota_tps_shd.g_old_rec.plan_status_type_id
      ,p_organization_id_o
      => ota_tps_shd.g_old_rec.organization_id
      ,p_person_id_o
      => ota_tps_shd.g_old_rec.person_id
      ,p_budget_currency_o
      => ota_tps_shd.g_old_rec.budget_currency
      ,p_name_o
      => ota_tps_shd.g_old_rec.name
      ,p_description_o
      => ota_tps_shd.g_old_rec.description
      ,p_business_group_id_o
      => ota_tps_shd.g_old_rec.business_group_id
      ,p_object_version_number_o
      => ota_tps_shd.g_old_rec.object_version_number
      ,p_attribute_category_o
      => ota_tps_shd.g_old_rec.attribute_category
      ,p_attribute1_o
      => ota_tps_shd.g_old_rec.attribute1
      ,p_attribute2_o
      => ota_tps_shd.g_old_rec.attribute2
      ,p_attribute3_o
      => ota_tps_shd.g_old_rec.attribute3
      ,p_attribute4_o
      => ota_tps_shd.g_old_rec.attribute4
      ,p_attribute5_o
      => ota_tps_shd.g_old_rec.attribute5
      ,p_attribute6_o
      => ota_tps_shd.g_old_rec.attribute6
      ,p_attribute7_o
      => ota_tps_shd.g_old_rec.attribute7
      ,p_attribute8_o
      => ota_tps_shd.g_old_rec.attribute8
      ,p_attribute9_o
      => ota_tps_shd.g_old_rec.attribute9
      ,p_attribute10_o
      => ota_tps_shd.g_old_rec.attribute10
      ,p_attribute11_o
      => ota_tps_shd.g_old_rec.attribute11
      ,p_attribute12_o
      => ota_tps_shd.g_old_rec.attribute12
      ,p_attribute13_o
      => ota_tps_shd.g_old_rec.attribute13
      ,p_attribute14_o
      => ota_tps_shd.g_old_rec.attribute14
      ,p_attribute15_o
      => ota_tps_shd.g_old_rec.attribute15
      ,p_attribute16_o
      => ota_tps_shd.g_old_rec.attribute16
      ,p_attribute17_o
      => ota_tps_shd.g_old_rec.attribute17
      ,p_attribute18_o
      => ota_tps_shd.g_old_rec.attribute18
      ,p_attribute19_o
      => ota_tps_shd.g_old_rec.attribute19
      ,p_attribute20_o
      => ota_tps_shd.g_old_rec.attribute20
      ,p_attribute21_o
      => ota_tps_shd.g_old_rec.attribute21
      ,p_attribute22_o
      => ota_tps_shd.g_old_rec.attribute22
      ,p_attribute23_o
      => ota_tps_shd.g_old_rec.attribute23
      ,p_attribute24_o
      => ota_tps_shd.g_old_rec.attribute24
      ,p_attribute25_o
      => ota_tps_shd.g_old_rec.attribute25
      ,p_attribute26_o
      => ota_tps_shd.g_old_rec.attribute26
      ,p_attribute27_o
      => ota_tps_shd.g_old_rec.attribute27
      ,p_attribute28_o
      => ota_tps_shd.g_old_rec.attribute28
      ,p_attribute29_o
      => ota_tps_shd.g_old_rec.attribute29
      ,p_attribute30_o
      => ota_tps_shd.g_old_rec.attribute30
      ,p_plan_source_o => ota_tps_shd.g_old_rec.plan_source --changed
      ,p_start_date_o => ota_tps_shd.g_old_rec.start_date
      ,p_end_date_o => ota_tps_shd.g_old_rec.end_date
      ,p_creator_person_id_o => ota_tps_shd.g_old_rec.creator_person_id
      ,p_additional_member_flag_o => ota_tps_shd.g_old_rec.additional_member_flag
      ,p_learning_path_id_o => ota_tps_shd.g_old_rec.learning_path_id
      ,p_contact_id_o       => ota_tps_shd.g_old_rec.contact_id
      );
    --
  EXCEPTION
    --
    WHEN hr_api.cannot_find_prog_unit THEN
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'OTA_TRAINING_PLANS'
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
--   It must return the record structure for the row with all system defaulted
--   values converted into its corresponding parameter value for update. When
--   we attempt to update a row through the Upd process , certain
--   parameters can be defaulted which enables flexibility in the calling of
--   the upd process (e.g. only attributes which need to be updated need to be
--   specified). For the upd process to determine which attributes
--   have NOT been specified we need to check if the parameter has a reserved
--   system default value. Therefore, for all parameters which have a
--   corresponding reserved system default mechanism specified we need to
--   check if a system default is being used. If a system default is being
--   used then we convert the defaulted value into its corresponding attribute
--   value held in the g_old_rec data structure.
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
--   No direct error handling is required within this function. Any possible
--   errors within this procedure will be a PL/SQL value error due to
--   conversion of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
PROCEDURE convert_defs
  (p_rec IN OUT NOCOPY ota_tps_shd.g_rec_type
  ) IS
--
BEGIN
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
   IF (p_rec.training_plan_id = hr_api.g_number) THEN
    p_rec.training_plan_id :=
    ota_tps_shd.g_old_rec.training_plan_id;
  END IF;
  IF (p_rec.time_period_id = hr_api.g_number) THEN
    p_rec.time_period_id :=
    ota_tps_shd.g_old_rec.time_period_id;
  END IF;
  IF (p_rec.plan_status_type_id = hr_api.g_varchar2) THEN
    p_rec.plan_status_type_id :=
    ota_tps_shd.g_old_rec.plan_status_type_id;
  END IF;
  IF (p_rec.organization_id = hr_api.g_number) THEN
    p_rec.organization_id :=
    ota_tps_shd.g_old_rec.organization_id;
  END IF;
  IF (p_rec.person_id = hr_api.g_number) THEN
    p_rec.person_id :=
    ota_tps_shd.g_old_rec.person_id;
  END IF;
  IF (p_rec.budget_currency = hr_api.g_varchar2) THEN
    p_rec.budget_currency :=
    ota_tps_shd.g_old_rec.budget_currency;
  END IF;
  IF (p_rec.name = hr_api.g_varchar2) THEN
    p_rec.name :=
    ota_tps_shd.g_old_rec.name;
  END IF;
  IF (p_rec.description = hr_api.g_varchar2) THEN
    p_rec.description :=
    ota_tps_shd.g_old_rec.description;
  END IF;
  IF (p_rec.business_group_id = hr_api.g_number) THEN
    p_rec.business_group_id :=
    ota_tps_shd.g_old_rec.business_group_id;
  END IF;
  IF (p_rec.attribute_category = hr_api.g_varchar2) THEN
    p_rec.attribute_category :=
    ota_tps_shd.g_old_rec.attribute_category;
  END IF;
  IF (p_rec.attribute1 = hr_api.g_varchar2) THEN
    p_rec.attribute1 :=
    ota_tps_shd.g_old_rec.attribute1;
  END IF;
  IF (p_rec.attribute2 = hr_api.g_varchar2) THEN
    p_rec.attribute2 :=
    ota_tps_shd.g_old_rec.attribute2;
  END IF;
  IF (p_rec.attribute3 = hr_api.g_varchar2) THEN
    p_rec.attribute3 :=
    ota_tps_shd.g_old_rec.attribute3;
  END IF;
  IF (p_rec.attribute4 = hr_api.g_varchar2) THEN
    p_rec.attribute4 :=
    ota_tps_shd.g_old_rec.attribute4;
  END IF;
  IF (p_rec.attribute5 = hr_api.g_varchar2) THEN
    p_rec.attribute5 :=
    ota_tps_shd.g_old_rec.attribute5;
  END IF;
  IF (p_rec.attribute6 = hr_api.g_varchar2) THEN
    p_rec.attribute6 :=
    ota_tps_shd.g_old_rec.attribute6;
  END IF;
  IF (p_rec.attribute7 = hr_api.g_varchar2) THEN
    p_rec.attribute7 :=
    ota_tps_shd.g_old_rec.attribute7;
  END IF;
  IF (p_rec.attribute8 = hr_api.g_varchar2) THEN
    p_rec.attribute8 :=
    ota_tps_shd.g_old_rec.attribute8;
  END IF;
  IF (p_rec.attribute9 = hr_api.g_varchar2) THEN
    p_rec.attribute9 :=
    ota_tps_shd.g_old_rec.attribute9;
  END IF;
  IF (p_rec.attribute10 = hr_api.g_varchar2) THEN
    p_rec.attribute10 :=
    ota_tps_shd.g_old_rec.attribute10;
  END IF;
  IF (p_rec.attribute11 = hr_api.g_varchar2) THEN
    p_rec.attribute11 :=
    ota_tps_shd.g_old_rec.attribute11;
  END IF;
  IF (p_rec.attribute12 = hr_api.g_varchar2) THEN
    p_rec.attribute12 :=
    ota_tps_shd.g_old_rec.attribute12;
  END IF;
  IF (p_rec.attribute13 = hr_api.g_varchar2) THEN
    p_rec.attribute13 :=
    ota_tps_shd.g_old_rec.attribute13;
  END IF;
  IF (p_rec.attribute14 = hr_api.g_varchar2) THEN
    p_rec.attribute14 :=
    ota_tps_shd.g_old_rec.attribute14;
  END IF;
  IF (p_rec.attribute15 = hr_api.g_varchar2) THEN
    p_rec.attribute15 :=
    ota_tps_shd.g_old_rec.attribute15;
  END IF;
  IF (p_rec.attribute16 = hr_api.g_varchar2) THEN
    p_rec.attribute16 :=
    ota_tps_shd.g_old_rec.attribute16;
  END IF;
  IF (p_rec.attribute17 = hr_api.g_varchar2) THEN
    p_rec.attribute17 :=
    ota_tps_shd.g_old_rec.attribute17;
  END IF;
  IF (p_rec.attribute18 = hr_api.g_varchar2) THEN
    p_rec.attribute18 :=
    ota_tps_shd.g_old_rec.attribute18;
  END IF;
  IF (p_rec.attribute19 = hr_api.g_varchar2) THEN
    p_rec.attribute19 :=
    ota_tps_shd.g_old_rec.attribute19;
  END IF;
  IF (p_rec.attribute20 = hr_api.g_varchar2) THEN
    p_rec.attribute20 :=
    ota_tps_shd.g_old_rec.attribute20;
  END IF;
  IF (p_rec.attribute21 = hr_api.g_varchar2) THEN
    p_rec.attribute21 :=
    ota_tps_shd.g_old_rec.attribute21;
  END IF;
  IF (p_rec.attribute22 = hr_api.g_varchar2) THEN
    p_rec.attribute22 :=
    ota_tps_shd.g_old_rec.attribute22;
  END IF;
  IF (p_rec.attribute23 = hr_api.g_varchar2) THEN
    p_rec.attribute23 :=
    ota_tps_shd.g_old_rec.attribute23;
  END IF;
  IF (p_rec.attribute24 = hr_api.g_varchar2) THEN
    p_rec.attribute24 :=
    ota_tps_shd.g_old_rec.attribute24;
  END IF;
  IF (p_rec.attribute25 = hr_api.g_varchar2) THEN
    p_rec.attribute25 :=
    ota_tps_shd.g_old_rec.attribute25;
  END IF;
  IF (p_rec.attribute26 = hr_api.g_varchar2) THEN
    p_rec.attribute26 :=
    ota_tps_shd.g_old_rec.attribute26;
  END IF;
  IF (p_rec.attribute27 = hr_api.g_varchar2) THEN
    p_rec.attribute27 :=
    ota_tps_shd.g_old_rec.attribute27;
  END IF;
  IF (p_rec.attribute28 = hr_api.g_varchar2) THEN
    p_rec.attribute28 :=
    ota_tps_shd.g_old_rec.attribute28;
  END IF;
  IF (p_rec.attribute29 = hr_api.g_varchar2) THEN
    p_rec.attribute29 :=
    ota_tps_shd.g_old_rec.attribute29;
  END IF;
  IF (p_rec.attribute30 = hr_api.g_varchar2) THEN
    p_rec.attribute30 :=
    ota_tps_shd.g_old_rec.attribute30;
  END IF;
  IF (p_rec.plan_source = hr_api.g_varchar2) THEN --cahnged
    p_rec.plan_source :=
    ota_tps_shd.g_old_rec.plan_source;
  END IF;
  IF (p_rec.start_date = hr_api.g_date) THEN
    p_rec.start_date :=
    ota_tps_shd.g_old_rec.start_date;
  END IF;
  IF (p_rec.end_date = hr_api.g_date) THEN
    p_rec.end_date :=
    ota_tps_shd.g_old_rec.end_date;
  END IF;
  IF (p_rec.creator_person_id = hr_api.g_number) THEN
    p_rec.creator_person_id :=
    ota_tps_shd.g_old_rec.creator_person_id;
  END IF;
  IF (p_rec.additional_member_flag = hr_api.g_varchar2) THEN --cahnged
    p_rec.additional_member_flag :=
    ota_tps_shd.g_old_rec.additional_member_flag;
  END IF;
  IF (p_rec.learning_path_id = hr_api.g_number) THEN --new
    p_rec.learning_path_id :=
    ota_tps_shd.g_old_rec.learning_path_id;
  END IF;
    IF (p_rec.contact_id = hr_api.g_number) THEN --new
    p_rec.contact_id :=
    ota_tps_shd.g_old_rec.contact_id;
  END IF;
  --
END convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE upd
  (p_effective_date               IN date
  ,p_rec                          IN OUT NOCOPY ota_tps_shd.g_rec_type
  ) IS
--
  l_proc  varchar2(72) := g_package||'upd';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  ota_tps_shd.lck
    (p_rec.training_plan_id
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
  ota_tps_bus.update_validate
     (p_effective_date
     ,p_rec
     );
  --
  --CALL TO RAISE ANY ERRORS ON MULTI MESSAGE LIST
  hr_multi_message.end_validation_set;


  -- Call the supporting pre-update operation
  --
  ota_tps_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  ota_tps_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  ota_tps_upd.post_update
     (p_effective_date
     ,p_rec
     );

 --CALL TO RAISE ANY ERRORS ON MULTI MESSAGE LIST
  hr_multi_message.end_validation_set;

END upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
PROCEDURE upd
  (p_effective_date               IN     date
  ,p_training_plan_id             IN     number
  ,p_object_version_number        IN OUT NOCOPY number
  ,p_time_period_id               IN     number    DEFAULT hr_api.g_number
  ,p_plan_status_type_id          IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_budget_currency              IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_name                         IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_description                  IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute_category           IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute1                   IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute2                   IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute3                   IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute4                   IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute5                   IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute6                   IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute7                   IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute8                   IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute9                   IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute10                  IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute11                  IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute12                  IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute13                  IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute14                  IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute15                  IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute16                  IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute17                  IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute18                  IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute19                  IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute20                  IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute21                  IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute22                  IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute23                  IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute24                  IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute25                  IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute26                  IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute27                  IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute28                  IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute29                  IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_attribute30                  IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_plan_source                  IN     varchar2  DEFAULT hr_api.g_varchar2 --changed
  ,p_start_date                   IN     date      DEFAULT hr_api.g_date
  ,p_end_date                     IN     date      DEFAULT hr_api.g_date
  ,p_creator_person_id            IN	 number    DEFAULT hr_api.g_number
  ,p_additional_member_flag       IN     varchar2  DEFAULT hr_api.g_varchar2
  ,p_learning_path_id             IN	 number    DEFAULT hr_api.g_number
  ,p_contact_id                          IN	 number    DEFAULT hr_api.g_number
  ) IS
--
  l_rec	  ota_tps_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
BEGIN
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ota_tps_shd.convert_args
  (p_training_plan_id
  ,p_time_period_id
  ,p_plan_status_type_id
  ,hr_api.g_number
  ,hr_api.g_number
  ,p_budget_currency
  ,p_name
  ,p_description
  ,hr_api.g_number
  ,p_object_version_number
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
  ,p_attribute21
  ,p_attribute22
  ,p_attribute23
  ,p_attribute24
  ,p_attribute25
  ,p_attribute26
  ,p_attribute27
  ,p_attribute28
  ,p_attribute29
  ,p_attribute30
  ,p_plan_source --changed
  ,p_start_date
  ,p_end_date
  ,p_creator_person_id
  ,p_additional_member_flag
  ,p_learning_path_id
  ,p_contact_id
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  ota_tps_upd.upd
     (p_effective_date
     ,l_rec
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
END upd;
--
END ota_tps_upd;

/
