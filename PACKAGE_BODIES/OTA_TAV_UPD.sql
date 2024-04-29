--------------------------------------------------------
--  DDL for Package Body OTA_TAV_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TAV_UPD" as
/* $Header: ottav01t.pkb 120.2.12010000.3 2009/08/11 13:44:21 smahanka ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ota_tav_upd.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |------------------------------< update_dml >------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure controls the actual dml update logic. The functions of this
--   procedure are as follows:
--   1) Increment the object_version_number by 1 if the object_version_number
--      is defined as an attribute for this entity.
--   2) To set and unset the g_api_dml status as required (as we are about to
--      perform dml).
--   3) To update the specified row in the schema using the primary key in
--      the predicates.
--   4) To trap any constraint violations that may have occurred.
--   5) To raise any other errors.
--
-- Pre Conditions:
--   This is an internal private procedure which must be called from the upd
--   procedure.
--
-- In Arguments:
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
--   The update 'set' arguments list should be modified if any of your
--   attributes are not updateable.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_dml(p_rec in out nocopy ota_tav_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'update_dml';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Increment the object version
  --
  p_rec.object_version_number := p_rec.object_version_number + 1;
  --
  ota_tav_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the ota_activity_versions Row
  --
  update ota_activity_versions
  set
  activity_version_id               = p_rec.activity_version_id,
  activity_id                       = p_rec.activity_id,
  superseded_by_act_version_id      = p_rec.superseded_by_act_version_id,
  developer_organization_id         = p_rec.developer_organization_id,
  controlling_person_id             = p_rec.controlling_person_id,
  object_version_number             = p_rec.object_version_number,
  version_name                      = p_rec.version_name,
  comments                          = p_rec.comments,
  description                       = p_rec.description,
  duration                          = p_rec.duration,
  duration_units                    = p_rec.duration_units,
  end_date                          = p_rec.end_date,
  intended_audience                 = p_rec.intended_audience,
  language_id                       = p_rec.language_id,
  maximum_attendees                 = p_rec.maximum_attendees,
  minimum_attendees                 = p_rec.minimum_attendees,
  objectives                        = p_rec.objectives,
  start_date                        = p_rec.start_date,
  success_criteria                  = p_rec.success_criteria,
  user_status                       = p_rec.user_status,
  vendor_id                         = p_rec.vendor_id,
  actual_cost                       = p_rec.actual_cost,
  budget_cost                       = p_rec.budget_cost,
  budget_currency_code              = p_rec.budget_currency_code,
  expenses_allowed                  = p_rec.expenses_allowed,
  professional_credit_type          = p_rec.professional_credit_type,
  professional_credits              = p_rec.professional_credits,
  maximum_internal_attendees        = p_rec.maximum_internal_attendees,
  tav_information_category          = p_rec.tav_information_category,
  tav_information1                  = p_rec.tav_information1,
  tav_information2                  = p_rec.tav_information2,
  tav_information3                  = p_rec.tav_information3,
  tav_information4                  = p_rec.tav_information4,
  tav_information5                  = p_rec.tav_information5,
  tav_information6                  = p_rec.tav_information6,
  tav_information7                  = p_rec.tav_information7,
  tav_information8                  = p_rec.tav_information8,
  tav_information9                  = p_rec.tav_information9,
  tav_information10                 = p_rec.tav_information10,
  tav_information11                 = p_rec.tav_information11,
  tav_information12                 = p_rec.tav_information12,
  tav_information13                 = p_rec.tav_information13,
  tav_information14                 = p_rec.tav_information14,
  tav_information15                 = p_rec.tav_information15,
  tav_information16                 = p_rec.tav_information16,
  tav_information17                 = p_rec.tav_information17,
  tav_information18                 = p_rec.tav_information18,
  tav_information19                 = p_rec.tav_information19,
  tav_information20                 = p_rec.tav_information20,
  inventory_item_id			= p_rec.inventory_item_id,
  organization_id				= p_rec.organization_id,
  rco_id				      = p_rec.rco_id,
  version_code                = p_rec.version_code,
  business_group_id                    = p_rec.business_group_id,
  data_source                   = p_rec.data_source,
      competency_update_level          = p_rec.competency_update_level,
      eres_enabled                  = p_rec.eres_enabled

  where activity_version_id = p_rec.activity_version_id;
  --
  ota_tav_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    ota_tav_shd.g_api_dml := false;   -- Unset the api dml status
    ota_tav_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    ota_tav_shd.g_api_dml := false;   -- Unset the api dml status
    ota_tav_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    ota_tav_shd.g_api_dml := false;   -- Unset the api dml status
    ota_tav_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    ota_tav_shd.g_api_dml := false;   -- Unset the api dml status
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
-- Pre Conditions:
--   This is an internal procedure which is called from the upd procedure.
--
-- In Arguments:
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
--   Any pre-processing required before the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update(p_rec in ota_tav_shd.g_rec_type) is
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
--   This private procedure contains any processing which is required after the
--   update dml.
--
-- Pre Conditions:
--   This is an internal procedure which is called from the upd procedure.
--
-- In Arguments:
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
--   Any post-processing required after the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_update(p_rec in ota_tav_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_update';
  l_start_date_changed boolean := ota_general.value_changed(ota_tav_shd.g_old_rec.start_date, p_rec.start_date);
 l_end_date_changed boolean := ota_general.value_changed(ota_tav_shd.g_old_rec.end_date, p_rec.end_date);
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  If not l_start_date_changed and not l_end_date_changed Then
     return;
  Else
 /*
     ota_rud_api.update_resource_usage_dates( p_rec.activity_version_id
                                            ,ota_tav_shd.g_old_rec.start_date
                                            , p_rec.start_date
                                             , ota_tav_shd.g_old_rec.end_date
                                             , p_rec.end_date
                                             );
 */
     hr_competence_element_api.update_delivered_dates
                                           ( p_rec.activity_version_id
                                            ,ota_tav_shd.g_old_rec.start_date
                                            , p_rec.start_date
                                             , ota_tav_shd.g_old_rec.end_date
                                             , p_rec.end_date
                                             );
  End if;
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
--   The Convert_Defs function has one very important function:
--   It must return the record structure for the row with all system defaulted
--   values converted into its corresponding argument value for update. When
--   we attempt to update a row through the Upd business process , certain
--   arguments can be defaulted which enables flexibility in the calling of
--   the upd process (e.g. only attributes which need to be updated need to be
--   specified). For the upd business process to determine which attributes
--   have NOT been specified we need to check if the argument has a reserved
--   system default value. Therefore, for all attributes which have a
--   corresponding reserved system default mechanism specified we need to
--   check if a system default is being used. If a system default is being
--   used then we convert the defaulted value into its corresponding attribute
--   value held in the g_old_rec data structure.
--
-- Pre Conditions:
--   This private function can only be called from the upd process.
--
-- In Arguments:
--   A Pl/Sql record structre.
--
-- Post Success:
--   The record structure will be returned with all system defaulted argument
--   values converted into its current row attribute value.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this function will be a PL/SQL value error due to conversion
--   of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Function convert_defs(p_rec in out nocopy ota_tav_shd.g_rec_type)
         Return ota_tav_shd.g_rec_type is
--
  l_proc  varchar2(72) := g_package||'convert_defs';
--
Begin
  --
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.
  --
  If (p_rec.activity_id = hr_api.g_number) then
    p_rec.activity_id :=
    ota_tav_shd.g_old_rec.activity_id;
  End If;
  If (p_rec.superseded_by_act_version_id = hr_api.g_number) then
    p_rec.superseded_by_act_version_id :=
    ota_tav_shd.g_old_rec.superseded_by_act_version_id;
  End If;
  If (p_rec.developer_organization_id = hr_api.g_number) then
    p_rec.developer_organization_id :=
    ota_tav_shd.g_old_rec.developer_organization_id;
  End If;
  If (p_rec.controlling_person_id = hr_api.g_number) then
    p_rec.controlling_person_id :=
    ota_tav_shd.g_old_rec.controlling_person_id;
  End If;
  If (p_rec.version_name = hr_api.g_varchar2) then
    p_rec.version_name :=
    ota_tav_shd.g_old_rec.version_name;
  End If;
  If (p_rec.comments = hr_api.g_varchar2) then
    p_rec.comments :=
    ota_tav_shd.g_old_rec.comments;
  End If;
  If (p_rec.description = hr_api.g_varchar2) then
    p_rec.description :=
    ota_tav_shd.g_old_rec.description;
  End If;
  If (p_rec.duration = hr_api.g_number) then
    p_rec.duration :=
    ota_tav_shd.g_old_rec.duration;
  End If;
  If (p_rec.duration_units = hr_api.g_varchar2) then
    p_rec.duration_units :=
    ota_tav_shd.g_old_rec.duration_units;
  End If;
  If (p_rec.end_date = hr_api.g_date) then
    p_rec.end_date :=
    ota_tav_shd.g_old_rec.end_date;
  End If;
  If (p_rec.intended_audience = hr_api.g_varchar2) then
    p_rec.intended_audience :=
    ota_tav_shd.g_old_rec.intended_audience;
  End If;
  If (p_rec.language_id = hr_api.g_number) then
    p_rec.language_id :=
    ota_tav_shd.g_old_rec.language_id;
  End If;
  If (p_rec.maximum_attendees = hr_api.g_number) then
    p_rec.maximum_attendees :=
    ota_tav_shd.g_old_rec.maximum_attendees;
  End If;
  If (p_rec.minimum_attendees = hr_api.g_number) then
    p_rec.minimum_attendees :=
    ota_tav_shd.g_old_rec.minimum_attendees;
  End If;
  If (p_rec.objectives = hr_api.g_varchar2) then
    p_rec.objectives :=
    ota_tav_shd.g_old_rec.objectives;
  End If;
  If (p_rec.start_date = hr_api.g_date) then
    p_rec.start_date :=
    ota_tav_shd.g_old_rec.start_date;
  End If;
  If (p_rec.success_criteria = hr_api.g_varchar2) then
    p_rec.success_criteria :=
    ota_tav_shd.g_old_rec.success_criteria;
  End If;
  If (p_rec.user_status = hr_api.g_varchar2) then
    p_rec.user_status :=
    ota_tav_shd.g_old_rec.user_status;
  End If;
  If (p_rec.vendor_id = hr_api.g_number) then
    p_rec.vendor_id :=
    ota_tav_shd.g_old_rec.vendor_id;
  End If;
  If (p_rec.actual_cost = hr_api.g_number) then
    p_rec.actual_cost :=
    ota_tav_shd.g_old_rec.actual_cost;
  End If;
  If (p_rec.budget_cost = hr_api.g_number) then
    p_rec.budget_cost :=
    ota_tav_shd.g_old_rec.budget_cost;
  End If;
  If (p_rec.budget_currency_code = hr_api.g_varchar2) then
    p_rec.budget_currency_code :=
    ota_tav_shd.g_old_rec.budget_currency_code;
  End If;
  If (p_rec.expenses_allowed = hr_api.g_varchar2) then
    p_rec.expenses_allowed :=
    ota_tav_shd.g_old_rec.expenses_allowed;
  End If;
  If (p_rec.professional_credit_type = hr_api.g_varchar2) then
    p_rec.professional_credit_type :=
    ota_tav_shd.g_old_rec.professional_credit_type;
  End If;
  If (p_rec.professional_credits = hr_api.g_number) then
    p_rec.professional_credits :=
    ota_tav_shd.g_old_rec.professional_credits;
  End If;
  If (p_rec.maximum_internal_attendees = hr_api.g_number) then
    p_rec.maximum_internal_attendees :=
    ota_tav_shd.g_old_rec.maximum_internal_attendees;
  End If;
  If (p_rec.tav_information_category = hr_api.g_varchar2) then
    p_rec.tav_information_category :=
    ota_tav_shd.g_old_rec.tav_information_category;
  End If;
  If (p_rec.tav_information1 = hr_api.g_varchar2) then
    p_rec.tav_information1 :=
    ota_tav_shd.g_old_rec.tav_information1;
  End If;
  If (p_rec.tav_information2 = hr_api.g_varchar2) then
    p_rec.tav_information2 :=
    ota_tav_shd.g_old_rec.tav_information2;
  End If;
  If (p_rec.tav_information3 = hr_api.g_varchar2) then
    p_rec.tav_information3 :=
    ota_tav_shd.g_old_rec.tav_information3;
  End If;
  If (p_rec.tav_information4 = hr_api.g_varchar2) then
    p_rec.tav_information4 :=
    ota_tav_shd.g_old_rec.tav_information4;
  End If;
  If (p_rec.tav_information5 = hr_api.g_varchar2) then
    p_rec.tav_information5 :=
    ota_tav_shd.g_old_rec.tav_information5;
  End If;
  If (p_rec.tav_information6 = hr_api.g_varchar2) then
    p_rec.tav_information6 :=
    ota_tav_shd.g_old_rec.tav_information6;
  End If;
  If (p_rec.tav_information7 = hr_api.g_varchar2) then
    p_rec.tav_information7 :=
    ota_tav_shd.g_old_rec.tav_information7;
  End If;
  If (p_rec.tav_information8 = hr_api.g_varchar2) then
    p_rec.tav_information8 :=
    ota_tav_shd.g_old_rec.tav_information8;
  End If;
  If (p_rec.tav_information9 = hr_api.g_varchar2) then
    p_rec.tav_information9 :=
    ota_tav_shd.g_old_rec.tav_information9;
  End If;
  If (p_rec.tav_information10 = hr_api.g_varchar2) then
    p_rec.tav_information10 :=
    ota_tav_shd.g_old_rec.tav_information10;
  End If;
  If (p_rec.tav_information11 = hr_api.g_varchar2) then
    p_rec.tav_information11 :=
    ota_tav_shd.g_old_rec.tav_information11;
  End If;
  If (p_rec.tav_information12 = hr_api.g_varchar2) then
    p_rec.tav_information12 :=
    ota_tav_shd.g_old_rec.tav_information12;
  End If;
  If (p_rec.tav_information13 = hr_api.g_varchar2) then
    p_rec.tav_information13 :=
    ota_tav_shd.g_old_rec.tav_information13;
  End If;
  If (p_rec.tav_information14 = hr_api.g_varchar2) then
    p_rec.tav_information14 :=
    ota_tav_shd.g_old_rec.tav_information14;
  End If;
  If (p_rec.tav_information15 = hr_api.g_varchar2) then
    p_rec.tav_information15 :=
    ota_tav_shd.g_old_rec.tav_information15;
  End If;
  If (p_rec.tav_information16 = hr_api.g_varchar2) then
    p_rec.tav_information16 :=
    ota_tav_shd.g_old_rec.tav_information16;
  End If;
  If (p_rec.tav_information17 = hr_api.g_varchar2) then
    p_rec.tav_information17 :=
    ota_tav_shd.g_old_rec.tav_information17;
  End If;
  If (p_rec.tav_information18 = hr_api.g_varchar2) then
    p_rec.tav_information18 :=
    ota_tav_shd.g_old_rec.tav_information18;
  End If;
  If (p_rec.tav_information19 = hr_api.g_varchar2) then
    p_rec.tav_information19 :=
    ota_tav_shd.g_old_rec.tav_information19;
  End If;
  If (p_rec.tav_information20 = hr_api.g_varchar2) then
    p_rec.tav_information20 :=
    ota_tav_shd.g_old_rec.tav_information20;
  End If;
  If (p_rec.inventory_item_id = hr_api.g_number) then
    p_rec.inventory_item_id :=
    ota_tav_shd.g_old_rec.inventory_item_id;
  End If;
   If (p_rec.organization_id = hr_api.g_number) then
    p_rec.organization_id :=
    ota_tav_shd.g_old_rec.organization_id;
  End If;
   If (p_rec.rco_id = hr_api.g_number) then
    p_rec.rco_id :=
    ota_tav_shd.g_old_rec.rco_id;
  End If;
   If (p_rec.version_code = hr_api.g_varchar2) then
    p_rec.version_code :=
    ota_tav_shd.g_old_rec.version_code;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    ota_tav_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.data_source = hr_api.g_varchar2) then
    p_rec.data_source  :=
    ota_tav_shd.g_old_rec.data_source;
  End If;
  If (p_rec.competency_update_level = hr_api.g_varchar2) then
    p_rec.competency_update_level  :=
    ota_tav_shd.g_old_rec.competency_update_level;
  End If;
  If (p_rec.eres_enabled = hr_api.g_varchar2) then
    p_rec.eres_enabled  :=
    ota_tav_shd.g_old_rec.eres_enabled;
  End If;
  --
  -- Return the plsql record structure.
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
  Return(p_rec);
--
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_rec        in out nocopy ota_tav_shd.g_rec_type,
  p_validate   in     boolean
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Determine if the business process is to be validated.
  --
  If p_validate then
    --
    -- Issue the savepoint.
    --
    SAVEPOINT upd_ota_tav;
  End If;
  --
  -- We must lock the row which we need to update.
  --
  ota_tav_shd.lck
	(
	p_rec.activity_version_id,
	p_rec.object_version_number
	);
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  ota_tav_bus.update_validate(convert_defs(p_rec));
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- Call the supporting pre-update operation
  --
  pre_update(p_rec);
  --
  -- Update the row.
  --
  update_dml(p_rec);
  --
  -- Call the supporting post-update operation
  --
  post_update(p_rec);
  --
  -- Call to raise any errors on multi-message list
  hr_multi_message.end_validation_set;
  --
  -- If we are validating then raise the Validate_Enabled exception
  --
  If p_validate then
    Raise HR_Api.Validate_Enabled;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When HR_Api.Validate_Enabled Then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO upd_ota_tav;
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_activity_version_id          in number,
  p_activity_id                  in number           ,
  p_superseded_by_act_version_id in number           ,
  p_developer_organization_id    in number           ,
  p_controlling_person_id        in number           ,
  p_object_version_number        in out nocopy number,
  p_version_name                 in varchar2         ,
  p_comments                     in varchar2         ,
  p_description                  in varchar2         ,
  p_duration                     in number           ,
  p_duration_units               in varchar2         ,
  p_end_date                     in date             ,
  p_intended_audience            in varchar2         ,
  p_language_id                  in number           ,
  p_maximum_attendees            in number           ,
  p_minimum_attendees            in number           ,
  p_objectives                   in varchar2         ,
  p_start_date                   in date             ,
  p_success_criteria             in varchar2         ,
  p_user_status                  in varchar2         ,
  p_vendor_id                  in number            ,
  p_actual_cost                in number            ,
  p_budget_cost                in number            ,
  p_budget_currency_code       in varchar2         ,
  p_expenses_allowed           in varchar2         ,
  p_professional_credit_type   in varchar2         ,
  p_professional_credits       in number           ,
  p_maximum_internal_attendees in number           ,
  p_tav_information_category     in varchar2       ,
  p_tav_information1             in varchar2       ,
  p_tav_information2             in varchar2       ,
  p_tav_information3             in varchar2       ,
  p_tav_information4             in varchar2       ,
  p_tav_information5             in varchar2       ,
  p_tav_information6             in varchar2       ,
  p_tav_information7             in varchar2       ,
  p_tav_information8             in varchar2       ,
  p_tav_information9             in varchar2       ,
  p_tav_information10            in varchar2       ,
  p_tav_information11            in varchar2       ,
  p_tav_information12            in varchar2       ,
  p_tav_information13            in varchar2       ,
  p_tav_information14            in varchar2       ,
  p_tav_information15            in varchar2       ,
  p_tav_information16            in varchar2       ,
  p_tav_information17            in varchar2       ,
  p_tav_information18            in varchar2         ,
  p_tav_information19            in varchar2         ,
  p_tav_information20            in varchar2         ,
  p_inventory_item_id		   in number	     ,
  p_organization_id		   in number 	     ,
  p_rco_id		   		   in number 	  ,
 -- p_rco_id		   		   in number 	     default null,
  p_version_code                 in varchar2,
  p_business_group_id                     in number,
  p_validate                     in boolean,
  p_data_source                  in varchar2
  ,p_competency_update_level        in     varchar2 ,
  p_eres_enabled                 in varchar2

  ) is
--
  l_rec	  ota_tav_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ota_tav_shd.convert_args
  (
  p_activity_version_id,
  p_activity_id,
  p_superseded_by_act_version_id,
  p_developer_organization_id,
  p_controlling_person_id,
  p_object_version_number,
  p_version_name,
  p_comments,
  p_description,
  p_duration,
  p_duration_units,
  p_end_date,
  p_intended_audience,
  p_language_id,
  p_maximum_attendees,
  p_minimum_attendees,
  p_objectives,
  p_start_date,
  p_success_criteria,
  p_user_status,
  p_vendor_id,
  p_actual_cost,
  p_budget_cost,
  p_budget_currency_code,
  p_expenses_allowed,
  p_professional_credit_type,
  p_professional_credits,
  p_maximum_internal_attendees,
  p_tav_information_category,
  p_tav_information1,
  p_tav_information2,
  p_tav_information3,
  p_tav_information4,
  p_tav_information5,
  p_tav_information6,
  p_tav_information7,
  p_tav_information8,
  p_tav_information9,
  p_tav_information10,
  p_tav_information11,
  p_tav_information12,
  p_tav_information13,
  p_tav_information14,
  p_tav_information15,
  p_tav_information16,
  p_tav_information17,
  p_tav_information18,
  p_tav_information19,
  p_tav_information20,
  p_inventory_item_id,
  p_organization_id,
  p_rco_id,
  p_version_code,
  p_business_group_id,
  p_data_source
  ,p_competency_update_level,
  p_eres_enabled

  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(l_rec, p_validate);
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end ota_tav_upd;

/
