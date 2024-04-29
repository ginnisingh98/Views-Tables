--------------------------------------------------------
--  DDL for Package Body OTA_OFF_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_OFF_UPD" as
/* $Header: otoffrhi.pkb 120.1.12000000.2 2007/02/06 15:25:23 vkkolla noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := '  ota_off_upd.';  -- Global package name

l_event_id number(30);
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
Procedure update_dml
  (p_rec in out nocopy ota_off_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Increment the object version
  p_rec.object_version_number := p_rec.object_version_number + 1;
  --
  --
  --
  -- Update the ota_offerings Row
  --
  update ota_offerings
    set
     offering_id                     = p_rec.offering_id
    ,activity_version_id             = p_rec.activity_version_id
    ,business_group_id               = p_rec.business_group_id
    ,start_date                      = p_rec.start_date
    ,end_date                        = p_rec.end_date
    ,owner_id                        = p_rec.owner_id
    ,delivery_mode_id                = p_rec.delivery_mode_id
    ,language_id                     = p_rec.language_id
    ,duration                        = p_rec.duration
    ,duration_units                  = p_rec.duration_units
    ,learning_object_id              = p_rec.learning_object_id
    ,player_toolbar_flag             = p_rec.player_toolbar_flag
    ,player_toolbar_bitset           = p_rec.player_toolbar_bitset
    ,player_new_window_flag          = p_rec.player_new_window_flag
    ,maximum_attendees               = p_rec.maximum_attendees
    ,maximum_internal_attendees      = p_rec.maximum_internal_attendees
    ,minimum_attendees               = p_rec.minimum_attendees
    ,actual_cost                     = p_rec.actual_cost
    ,budget_cost                     = p_rec.budget_cost
    ,budget_currency_code            = p_rec.budget_currency_code
    ,price_basis                     = p_rec.price_basis
    ,currency_code                   = p_rec.currency_code
    ,standard_price                  = p_rec.standard_price
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
    ,data_source                     = p_rec.data_source
    ,vendor_id                       = p_rec.vendor_id
    ,competency_update_level      = p_rec.competency_update_level
    ,language_code                = p_rec.language_code  -- 2733966
    where offering_id = p_rec.offering_id;
  --
  --
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    ota_off_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    ota_off_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    ota_off_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    --
    Raise;
End update_dml;
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
Procedure pre_update
  (p_rec in ota_off_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'pre_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_update;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< post_update >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This private procedure contains any processing which is required after
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
Procedure post_update
  (p_effective_date               in date
  ,p_rec                          in ota_off_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'post_update';
  l_activity_version_id_changed boolean :=  ota_general.value_changed(ota_off_shd.g_old_rec.activity_version_id,
					p_rec.activity_version_id);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  begin
    --
    if  l_activity_version_id_changed then
         update_evt_when_course_change( p_rec.offering_id , p_rec.activity_version_id);
    end if;
    ota_off_rku.after_update
      (p_effective_date              => p_effective_date
      ,p_offering_id
      => p_rec.offering_id
      ,p_activity_version_id
      => p_rec.activity_version_id
      ,p_business_group_id
      => p_rec.business_group_id
      ,p_start_date
      => p_rec.start_date
      ,p_end_date
      => p_rec.end_date
      ,p_owner_id
      => p_rec.owner_id
      ,p_delivery_mode_id
      => p_rec.delivery_mode_id
      ,p_language_id
      => p_rec.language_id
      ,p_duration
      => p_rec.duration
      ,p_duration_units
      => p_rec.duration_units
      ,p_learning_object_id
      => p_rec.learning_object_id
      ,p_player_toolbar_flag
      => p_rec.player_toolbar_flag
      ,p_player_toolbar_bitset
      => p_rec.player_toolbar_bitset
      ,p_player_new_window_flag
      => p_rec.player_new_window_flag
      ,p_maximum_attendees
      => p_rec.maximum_attendees
      ,p_maximum_internal_attendees
      => p_rec.maximum_internal_attendees
      ,p_minimum_attendees
      => p_rec.minimum_attendees
      ,p_actual_cost
      => p_rec.actual_cost
      ,p_budget_cost
      => p_rec.budget_cost
      ,p_budget_currency_code
      => p_rec.budget_currency_code
      ,p_price_basis
      => p_rec.price_basis
      ,p_currency_code
      => p_rec.currency_code
      ,p_standard_price
      => p_rec.standard_price
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
      ,p_data_source
      => p_rec.data_source
      ,p_vendor_id
      => p_rec.vendor_id
      ,p_competency_update_level      => p_rec.competency_update_level
      ,p_activity_version_id_o
      => ota_off_shd.g_old_rec.activity_version_id
      ,p_business_group_id_o
      => ota_off_shd.g_old_rec.business_group_id
      ,p_start_date_o
      => ota_off_shd.g_old_rec.start_date
      ,p_end_date_o
      => ota_off_shd.g_old_rec.end_date
      ,p_owner_id_o
      => ota_off_shd.g_old_rec.owner_id
      ,p_delivery_mode_id_o
      => ota_off_shd.g_old_rec.delivery_mode_id
      ,p_language_id_o
      => ota_off_shd.g_old_rec.language_id
      ,p_duration_o
      => ota_off_shd.g_old_rec.duration
      ,p_duration_units_o
      => ota_off_shd.g_old_rec.duration_units
      ,p_learning_object_id_o
      => ota_off_shd.g_old_rec.learning_object_id
      ,p_player_toolbar_flag_o
      => ota_off_shd.g_old_rec.player_toolbar_flag
      ,p_player_toolbar_bitset_o
      => ota_off_shd.g_old_rec.player_toolbar_bitset
      ,p_player_new_window_flag_o
      => ota_off_shd.g_old_rec.player_new_window_flag
      ,p_maximum_attendees_o
      => ota_off_shd.g_old_rec.maximum_attendees
      ,p_maximum_internal_attendees_o
      => ota_off_shd.g_old_rec.maximum_internal_attendees
      ,p_minimum_attendees_o
      => ota_off_shd.g_old_rec.minimum_attendees
      ,p_actual_cost_o
      => ota_off_shd.g_old_rec.actual_cost
      ,p_budget_cost_o
      => ota_off_shd.g_old_rec.budget_cost
      ,p_budget_currency_code_o
      => ota_off_shd.g_old_rec.budget_currency_code
      ,p_price_basis_o
      => ota_off_shd.g_old_rec.price_basis
      ,p_currency_code_o
      => ota_off_shd.g_old_rec.currency_code
      ,p_standard_price_o
      => ota_off_shd.g_old_rec.standard_price
      ,p_object_version_number_o
      => ota_off_shd.g_old_rec.object_version_number
      ,p_attribute_category_o
      => ota_off_shd.g_old_rec.attribute_category
      ,p_attribute1_o
      => ota_off_shd.g_old_rec.attribute1
      ,p_attribute2_o
      => ota_off_shd.g_old_rec.attribute2
      ,p_attribute3_o
      => ota_off_shd.g_old_rec.attribute3
      ,p_attribute4_o
      => ota_off_shd.g_old_rec.attribute4
      ,p_attribute5_o
      => ota_off_shd.g_old_rec.attribute5
      ,p_attribute6_o
      => ota_off_shd.g_old_rec.attribute6
      ,p_attribute7_o
      => ota_off_shd.g_old_rec.attribute7
      ,p_attribute8_o
      => ota_off_shd.g_old_rec.attribute8
      ,p_attribute9_o
      => ota_off_shd.g_old_rec.attribute9
      ,p_attribute10_o
      => ota_off_shd.g_old_rec.attribute10
      ,p_attribute11_o
      => ota_off_shd.g_old_rec.attribute11
      ,p_attribute12_o
      => ota_off_shd.g_old_rec.attribute12
      ,p_attribute13_o
      => ota_off_shd.g_old_rec.attribute13
      ,p_attribute14_o
      => ota_off_shd.g_old_rec.attribute14
      ,p_attribute15_o
      => ota_off_shd.g_old_rec.attribute15
      ,p_attribute16_o
      => ota_off_shd.g_old_rec.attribute16
      ,p_attribute17_o
      => ota_off_shd.g_old_rec.attribute17
      ,p_attribute18_o
      => ota_off_shd.g_old_rec.attribute18
      ,p_attribute19_o
      => ota_off_shd.g_old_rec.attribute19
      ,p_attribute20_o
      => ota_off_shd.g_old_rec.attribute20
      ,p_data_source_o
      => ota_off_shd.g_old_rec.data_source
      ,p_vendor_id_o
      => ota_off_shd.g_old_rec.vendor_id
      ,p_competency_update_level_o      => ota_off_shd.g_old_rec.competency_update_level
      ,p_language_code                  => ota_off_shd.g_old_rec.language_code  -- 2733966
      );
      null;
    --
  exception
    --
    when hr_api.cannot_find_prog_unit then
      --
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'OTA_OFFERINGS'
        ,p_hook_type   => 'AU');
      --
  end;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_update;
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
Procedure convert_defs
  (p_rec in out nocopy ota_off_shd.g_rec_type
  ) is
--
Begin
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.activity_version_id = hr_api.g_number) then
    p_rec.activity_version_id :=
    ota_off_shd.g_old_rec.activity_version_id;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    ota_off_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.start_date = hr_api.g_date) then
    p_rec.start_date :=
    ota_off_shd.g_old_rec.start_date;
  End If;
  If (p_rec.end_date = hr_api.g_date) then
    p_rec.end_date :=
    ota_off_shd.g_old_rec.end_date;
  End If;
  If (p_rec.owner_id = hr_api.g_number) then
    p_rec.owner_id :=
    ota_off_shd.g_old_rec.owner_id;
  End If;
  If (p_rec.delivery_mode_id = hr_api.g_number) then
    p_rec.delivery_mode_id :=
    ota_off_shd.g_old_rec.delivery_mode_id;
  End If;
  If (p_rec.language_id = hr_api.g_number) then
    p_rec.language_id :=
    ota_off_shd.g_old_rec.language_id;
  End If;
  If (p_rec.duration = hr_api.g_number) then
    p_rec.duration :=
    ota_off_shd.g_old_rec.duration;
  End If;
  If (p_rec.duration_units = hr_api.g_varchar2) then
    p_rec.duration_units :=
    ota_off_shd.g_old_rec.duration_units;
  End If;
  If (p_rec.learning_object_id = hr_api.g_number) then
    p_rec.learning_object_id :=
    ota_off_shd.g_old_rec.learning_object_id;
  End If;
  If (p_rec.player_toolbar_flag = hr_api.g_varchar2) then
    p_rec.player_toolbar_flag :=
    ota_off_shd.g_old_rec.player_toolbar_flag;
  End If;
  If (p_rec.player_toolbar_bitset = hr_api.g_number) then
    p_rec.player_toolbar_bitset :=
    ota_off_shd.g_old_rec.player_toolbar_bitset;
  End If;
  If (p_rec.player_new_window_flag = hr_api.g_varchar2) then
    p_rec.player_new_window_flag :=
    ota_off_shd.g_old_rec.player_new_window_flag;
  End If;
  If (p_rec.maximum_attendees = hr_api.g_number) then
    p_rec.maximum_attendees :=
    ota_off_shd.g_old_rec.maximum_attendees;
  End If;
  If (p_rec.maximum_internal_attendees = hr_api.g_number) then
    p_rec.maximum_internal_attendees :=
    ota_off_shd.g_old_rec.maximum_internal_attendees;
  End If;
  If (p_rec.minimum_attendees = hr_api.g_number) then
    p_rec.minimum_attendees :=
    ota_off_shd.g_old_rec.minimum_attendees;
  End If;
  If (p_rec.actual_cost = hr_api.g_number) then
    p_rec.actual_cost :=
    ota_off_shd.g_old_rec.actual_cost;
  End If;
  If (p_rec.budget_cost = hr_api.g_number) then
    p_rec.budget_cost :=
    ota_off_shd.g_old_rec.budget_cost;
  End If;
  If (p_rec.budget_currency_code = hr_api.g_varchar2) then
    p_rec.budget_currency_code :=
    ota_off_shd.g_old_rec.budget_currency_code;
  End If;
  If (p_rec.price_basis = hr_api.g_varchar2) then
    p_rec.price_basis :=
    ota_off_shd.g_old_rec.price_basis;
  End If;
  If (p_rec.currency_code = hr_api.g_varchar2) then
    p_rec.currency_code :=
    ota_off_shd.g_old_rec.currency_code;
  End If;
  If (p_rec.standard_price = hr_api.g_number) then
    p_rec.standard_price :=
    ota_off_shd.g_old_rec.standard_price;
  End If;
  If (p_rec.attribute_category = hr_api.g_varchar2) then
    p_rec.attribute_category :=
    ota_off_shd.g_old_rec.attribute_category;
  End If;
  If (p_rec.attribute1 = hr_api.g_varchar2) then
    p_rec.attribute1 :=
    ota_off_shd.g_old_rec.attribute1;
  End If;
  If (p_rec.attribute2 = hr_api.g_varchar2) then
    p_rec.attribute2 :=
    ota_off_shd.g_old_rec.attribute2;
  End If;
  If (p_rec.attribute3 = hr_api.g_varchar2) then
    p_rec.attribute3 :=
    ota_off_shd.g_old_rec.attribute3;
  End If;
  If (p_rec.attribute4 = hr_api.g_varchar2) then
    p_rec.attribute4 :=
    ota_off_shd.g_old_rec.attribute4;
  End If;
  If (p_rec.attribute5 = hr_api.g_varchar2) then
    p_rec.attribute5 :=
    ota_off_shd.g_old_rec.attribute5;
  End If;
  If (p_rec.attribute6 = hr_api.g_varchar2) then
    p_rec.attribute6 :=
    ota_off_shd.g_old_rec.attribute6;
  End If;
  If (p_rec.attribute7 = hr_api.g_varchar2) then
    p_rec.attribute7 :=
    ota_off_shd.g_old_rec.attribute7;
  End If;
  If (p_rec.attribute8 = hr_api.g_varchar2) then
    p_rec.attribute8 :=
    ota_off_shd.g_old_rec.attribute8;
  End If;
  If (p_rec.attribute9 = hr_api.g_varchar2) then
    p_rec.attribute9 :=
    ota_off_shd.g_old_rec.attribute9;
  End If;
  If (p_rec.attribute10 = hr_api.g_varchar2) then
    p_rec.attribute10 :=
    ota_off_shd.g_old_rec.attribute10;
  End If;
  If (p_rec.attribute11 = hr_api.g_varchar2) then
    p_rec.attribute11 :=
    ota_off_shd.g_old_rec.attribute11;
  End If;
  If (p_rec.attribute12 = hr_api.g_varchar2) then
    p_rec.attribute12 :=
    ota_off_shd.g_old_rec.attribute12;
  End If;
  If (p_rec.attribute13 = hr_api.g_varchar2) then
    p_rec.attribute13 :=
    ota_off_shd.g_old_rec.attribute13;
  End If;
  If (p_rec.attribute14 = hr_api.g_varchar2) then
    p_rec.attribute14 :=
    ota_off_shd.g_old_rec.attribute14;
  End If;
  If (p_rec.attribute15 = hr_api.g_varchar2) then
    p_rec.attribute15 :=
    ota_off_shd.g_old_rec.attribute15;
  End If;
  If (p_rec.attribute16 = hr_api.g_varchar2) then
    p_rec.attribute16 :=
    ota_off_shd.g_old_rec.attribute16;
  End If;
  If (p_rec.attribute17 = hr_api.g_varchar2) then
    p_rec.attribute17 :=
    ota_off_shd.g_old_rec.attribute17;
  End If;
  If (p_rec.attribute18 = hr_api.g_varchar2) then
    p_rec.attribute18 :=
    ota_off_shd.g_old_rec.attribute18;
  End If;
  If (p_rec.attribute19 = hr_api.g_varchar2) then
    p_rec.attribute19 :=
    ota_off_shd.g_old_rec.attribute19;
  End If;
  If (p_rec.attribute20 = hr_api.g_varchar2) then
    p_rec.attribute20 :=
    ota_off_shd.g_old_rec.attribute20;
  End If;
  If (p_rec.data_source = hr_api.g_varchar2) then
    p_rec.data_source :=
    ota_off_shd.g_old_rec.data_source;
  End If;
  If (p_rec.vendor_id = hr_api.g_number) then
    p_rec.vendor_id :=
    ota_off_shd.g_old_rec.vendor_id;
  End If;
  If (p_rec.competency_update_level = hr_api.g_varchar2) then
    p_rec.competency_update_level :=
    ota_off_shd.g_old_rec.competency_update_level;
  End If;
   If (p_rec.language_code = hr_api.g_varchar2) then  -- 2733966
    p_rec.language_code :=
    ota_off_shd.g_old_rec.language_code;
  End If;
  --
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in date
  ,p_rec                          in out nocopy ota_off_shd.g_rec_type
  ,p_name                         in varchar2
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  ota_off_shd.lck
    (p_rec.offering_id
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
  ota_off_bus.update_validate
     (p_effective_date
     ,p_rec
     ,p_name
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  ota_off_upd.pre_update(p_rec);
  --
  -- Update the row.
  --
  ota_off_upd.update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  ota_off_upd.post_update
     (p_effective_date
     ,p_rec
     );
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (p_effective_date               in     date
  ,p_offering_id                  in     number
  ,p_object_version_number        in out nocopy number
  ,p_business_group_id            in     number    default hr_api.g_number
  ,p_name                         in     varchar2  default hr_api.g_varchar2
  ,p_start_date                   in     date      default hr_api.g_date
  ,p_activity_version_id          in     number    default hr_api.g_number
  ,p_end_date                     in     date      default hr_api.g_date
  ,p_owner_id                     in     number    default hr_api.g_number
  ,p_delivery_mode_id             in     number    default hr_api.g_number
  ,p_language_id                  in     number    default hr_api.g_number
  ,p_duration                     in     number    default hr_api.g_number
  ,p_duration_units               in     varchar2  default hr_api.g_varchar2
  ,p_learning_object_id           in     number    default hr_api.g_number
  ,p_player_toolbar_flag          in     varchar2  default hr_api.g_varchar2
  ,p_player_toolbar_bitset        in     number    default hr_api.g_number
  ,p_player_new_window_flag       in     varchar2  default hr_api.g_varchar2
  ,p_maximum_attendees            in     number    default hr_api.g_number
  ,p_maximum_internal_attendees   in     number    default hr_api.g_number
  ,p_minimum_attendees            in     number    default hr_api.g_number
  ,p_actual_cost                  in     number    default hr_api.g_number
  ,p_budget_cost                  in     number    default hr_api.g_number
  ,p_budget_currency_code         in     varchar2  default hr_api.g_varchar2
  ,p_price_basis                  in     varchar2  default hr_api.g_varchar2
  ,p_currency_code                in     varchar2  default hr_api.g_varchar2
  ,p_standard_price               in     number    default hr_api.g_number
  ,p_attribute_category           in     varchar2  default hr_api.g_varchar2
  ,p_attribute1                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute2                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute3                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute4                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute5                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute6                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute7                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute8                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute9                   in     varchar2  default hr_api.g_varchar2
  ,p_attribute10                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute11                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute12                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute13                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute14                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute15                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute16                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute17                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute18                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute19                  in     varchar2  default hr_api.g_varchar2
  ,p_attribute20                  in     varchar2  default hr_api.g_varchar2
  ,p_data_source                  in     varchar2  default hr_api.g_varchar2
  ,p_vendor_id                    in     number    default hr_api.g_number
  ,p_competency_update_level      in     varchar2  default hr_api.g_varchar2
  ,p_language_code                in     varchar2  default hr_api.g_varchar2 -- 2733966
  ) is
--
  l_rec   ota_off_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ota_off_shd.convert_args
  (p_offering_id
  ,p_activity_version_id
  ,p_business_group_id
  ,p_name
  ,p_start_date
  ,p_end_date
  ,p_owner_id
  ,p_delivery_mode_id
  ,p_language_id
  ,p_duration
  ,p_duration_units
  ,p_learning_object_id
  ,p_player_toolbar_flag
  ,p_player_toolbar_bitset
  ,p_player_new_window_flag
  ,p_maximum_attendees
  ,p_maximum_internal_attendees
  ,p_minimum_attendees
  ,p_actual_cost
  ,p_budget_cost
  ,p_budget_currency_code
  ,p_price_basis
  ,p_currency_code
  ,p_standard_price
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
  ,p_data_source
  ,p_vendor_id
  ,p_competency_update_level
  ,p_language_code  -- 2733966
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  ota_off_upd.upd
     (p_effective_date
     ,l_rec
     ,p_name
     );
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
Procedure update_evt_when_course_change
  (
   p_offering_id  in  number,
   p_activity_version_id in number
  ) is
  --
  v_exists                varchar2(1);
  v_proc                  varchar2(72) := g_package||'update_evt_when_course_changed';
  TYPE EventIdTab IS TABLE OF ota_events.event_id%TYPE;
  v_event_tab EventIdTab;
  p_effective_date date := sysdate ;
  p_object_version_number number(30);
  --
  cursor sel_evt is
    select event_id,object_version_number
      from ota_events              evt
     where evt.parent_offering_id = p_offering_id ;
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  /*open sel_evt;
  fetch sel_evt BULK COLLECT  into v_event_tab;*/

  for event IN  sel_evt
  loop
   l_event_id := event.event_id;
	OTA_EVENT_API.update_class
	(
		p_effective_date => p_effective_date,
		p_event_id => event.event_id,
		p_activity_version_id => p_activity_version_id,
        p_object_version_number => event.object_version_number,
        p_parent_offering_id => p_offering_id
	);
  end loop;
  --
  --close sel_evt;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End update_evt_when_course_change;
end ota_off_upd;

/
