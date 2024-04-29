--------------------------------------------------------
--  DDL for Package Body PER_DPF_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_DPF_UPD" as
/* $Header: pedpfrhi.pkb 115.13 2002/12/05 10:20:52 pkakar ship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_dpf_upd.';  -- Global package name
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
Procedure update_dml(p_rec in out nocopy per_dpf_shd.g_rec_type) is
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
  per_dpf_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the per_deployment_factors Row
  --
  update per_deployment_factors
  set
  deployment_factor_id              = p_rec.deployment_factor_id,
  position_id                       = p_rec.position_id,
  person_id                         = p_rec.person_id,
  job_id                            = p_rec.job_id,
  business_group_id                 = p_rec.business_group_id,
  work_any_country                  = p_rec.work_any_country,
  work_any_location                 = p_rec.work_any_location,
  relocate_domestically             = p_rec.relocate_domestically,
  relocate_internationally          = p_rec.relocate_internationally,
  travel_required                   = p_rec.travel_required,
  country1                          = p_rec.country1,
  country2                          = p_rec.country2,
  country3                          = p_rec.country3,
  work_duration                     = p_rec.work_duration,
  work_schedule                     = p_rec.work_schedule,
  work_hours                        = p_rec.work_hours,
  fte_capacity                      = p_rec.fte_capacity,
  visit_internationally             = p_rec.visit_internationally,
  only_current_location             = p_rec.only_current_location,
  no_country1                       = p_rec.no_country1,
  no_country2                       = p_rec.no_country2,
  no_country3                       = p_rec.no_country3,
  comments                          = p_rec.comments,
  earliest_available_date           = p_rec.earliest_available_date,
  available_for_transfer            = p_rec.available_for_transfer,
  relocation_preference             = p_rec.relocation_preference,
  relocation_required               = p_rec.relocation_required,
  passport_required                 = p_rec.passport_required,
  location1                         = p_rec.location1,
  location2                         = p_rec.location2,
  location3                         = p_rec.location3,
  other_requirements                = p_rec.other_requirements,
  service_minimum                   = p_rec.service_minimum,
  object_version_number             = p_rec.object_version_number,
  attribute_category                = p_rec.attribute_category,
  attribute1                        = p_rec.attribute1,
  attribute2                        = p_rec.attribute2,
  attribute3                        = p_rec.attribute3,
  attribute4                        = p_rec.attribute4,
  attribute5                        = p_rec.attribute5,
  attribute6                        = p_rec.attribute6,
  attribute7                        = p_rec.attribute7,
  attribute8                        = p_rec.attribute8,
  attribute9                        = p_rec.attribute9,
  attribute10                       = p_rec.attribute10,
  attribute11                       = p_rec.attribute11,
  attribute12                       = p_rec.attribute12,
  attribute13                       = p_rec.attribute13,
  attribute14                       = p_rec.attribute14,
  attribute15                       = p_rec.attribute15,
  attribute16                       = p_rec.attribute16,
  attribute17                       = p_rec.attribute17,
  attribute18                       = p_rec.attribute18,
  attribute19                       = p_rec.attribute19,
  attribute20                       = p_rec.attribute20
  where deployment_factor_id = p_rec.deployment_factor_id;
  --
  per_dpf_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    per_dpf_shd.g_api_dml := false;   -- Unset the api dml status
    per_dpf_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    per_dpf_shd.g_api_dml := false;   -- Unset the api dml status
    per_dpf_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    per_dpf_shd.g_api_dml := false;   -- Unset the api dml status
    per_dpf_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    per_dpf_shd.g_api_dml := false;   -- Unset the api dml status
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
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update(p_rec in per_dpf_shd.g_rec_type) is
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
-- Prerequisites:
--   This is an internal procedure which is called from the upd procedure.
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
--   Any post-processing required after the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_update(p_rec in per_dpf_shd.g_rec_type,p_effective_date in date) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Start of API User Hook for post_update.
  begin
    per_dpf_rku.after_update
      (
         p_deployment_factor_id			=>p_rec.deployment_factor_id,
  	 p_business_group_id         		=>p_rec.business_group_id,
 	 p_work_any_country			=>p_rec.work_any_country,
  	 p_work_any_location			=>p_rec.work_any_location,
  	 p_relocate_domestically		=>p_rec.relocate_domestically,
	 p_relocate_internationally		=>p_rec.relocate_internationally,
  	 p_travel_required			=>p_rec.travel_required,
  	 p_country1				=>p_rec.country1,
  	 p_country2				=>p_rec.country2,
  	 p_country3				=>p_rec.country3,
  	 p_work_duration			=>p_rec.work_duration,
  	 p_work_schedule			=>p_rec.work_schedule,
  	 p_work_hours				=>p_rec.work_hours,
  	 p_fte_capacity				=>p_rec.fte_capacity,
  	 p_visit_internationally		=>p_rec.visit_internationally,
  	 p_only_current_location		=>p_rec.only_current_location,
  	 p_no_country1				=>p_rec.no_country1,
  	 p_no_country2				=>p_rec.no_country2,
 	 p_no_country3				=>p_rec.no_country3,
  	 p_comments				=>p_rec.comments,
  	 p_earliest_available_date		=>p_rec.earliest_available_date,
  	 p_available_for_transfer		=>p_rec.available_for_transfer,
  	 p_relocation_preference		=>p_rec.relocation_preference,
  	 p_relocation_required			=>p_rec.relocation_required,
         p_passport_required 			=>p_rec.passport_required,
 	 p_location1        			=>p_rec.location1,
 	 p_location2				=>p_rec.location2,
  	 p_location3				=>p_rec.location3,
 	 p_other_requirements			=>p_rec.other_requirements,
 	 p_service_minimum			=>p_rec.service_minimum,
 	 p_object_version_number		=>p_rec.object_version_number,
 	 p_effective_date			=>p_effective_date,
 	 p_attribute_category			=>p_rec.attribute_category,
 	 p_attribute1				=>p_rec.attribute1,
 	 p_attribute2				=>p_rec.attribute2,
 	 p_attribute3				=>p_rec.attribute3,
  	 p_attribute4				=>p_rec.attribute4,
 	 p_attribute5				=>p_rec.attribute5,
 	 p_attribute6                           =>p_rec.attribute6,
 	 p_attribute7                           =>p_rec.attribute7,
 	 p_attribute8                           =>p_rec.attribute8,
 	 p_attribute9                           =>p_rec.attribute9,
 	 p_attribute10                          =>p_rec.attribute10,
 	 p_attribute11                          =>p_rec.attribute11,
 	 p_attribute12                          =>p_rec.attribute12,
 	 p_attribute13                          =>p_rec.attribute13,
 	 p_attribute14                          =>p_rec.attribute14,
 	 p_attribute15                          =>p_rec.attribute15,
 	 p_attribute16                          =>p_rec.attribute16,
 	 p_attribute17                          =>p_rec.attribute17,
 	 p_attribute18                          =>p_rec.attribute18,
 	 p_attribute19                          =>p_rec.attribute19,
 	 p_attribute20                          =>p_rec.attribute20,
 	 p_position_id_o			=>per_dpf_shd.g_old_rec.position_id,
 	 p_person_id_o				=>per_dpf_shd.g_old_rec.person_id,
 	 p_job_id_o                		=>per_dpf_shd.g_old_rec.job_id,
 	 p_business_group_id_o    		=>per_dpf_shd.g_old_rec.business_group_id,
 	 p_work_any_country_o      		=>per_dpf_shd.g_old_rec.work_any_country,
 	 p_work_any_location_o    		=>per_dpf_shd.g_old_rec.work_any_location,
 	 p_relocate_domestically_o		=>per_dpf_shd.g_old_rec.relocate_domestically,
 	 p_relocate_internationally_o  		=>per_dpf_shd.g_old_rec.relocate_internationally,
 	 p_travel_required_o          		=>per_dpf_shd.g_old_rec.travel_required,
 	 p_country1_o                		=>per_dpf_shd.g_old_rec.country1,
 	 p_country2_o               		=>per_dpf_shd.g_old_rec.country2,
 	 p_country3_o              		=>per_dpf_shd.g_old_rec.country3,
 	 p_work_duration_o        		=>per_dpf_shd.g_old_rec.work_duration,
 	 p_work_schedule_o       		=>per_dpf_shd.g_old_rec.work_schedule,
 	 p_work_hours_o         		=>per_dpf_shd.g_old_rec.work_hours,
 	 p_fte_capacity_o      			=>per_dpf_shd.g_old_rec.fte_capacity,
 	 p_visit_internationally_o     		=>per_dpf_shd.g_old_rec.visit_internationally,
 	 p_only_current_location_o    		=>per_dpf_shd.g_old_rec.only_current_location,
 	 p_no_country1_o             		=>per_dpf_shd.g_old_rec.no_country1,
 	 p_no_country2_o            		=>per_dpf_shd.g_old_rec.no_country2,
 	 p_no_country3_o           		=>per_dpf_shd.g_old_rec.no_country3,
 	 p_comments_o             		=>per_dpf_shd.g_old_rec.comments,
 	 p_earliest_available_date_o   		=>per_dpf_shd.g_old_rec.earliest_available_date,
 	 p_available_for_transfer_o   		=>per_dpf_shd.g_old_rec.available_for_transfer,
 	 p_relocation_preference_o   		=>per_dpf_shd.g_old_rec.relocation_preference,
 	 p_relocation_required_o    		=>per_dpf_shd.g_old_rec.relocation_required,
 	 p_passport_required_o     		=>per_dpf_shd.g_old_rec.passport_required,
 	 p_location1_o            		=>per_dpf_shd.g_old_rec.location1,
 	 p_location2_o          		=>per_dpf_shd.g_old_rec.location2,
 	 p_location3_o         			=>per_dpf_shd.g_old_rec.location3,
 	 p_other_requirements_o			=>per_dpf_shd.g_old_rec.other_requirements,
 	 p_service_minimum_o 			=>per_dpf_shd.g_old_rec.service_minimum,
 	 p_object_version_number_o  		=>per_dpf_shd.g_old_rec.object_version_number,
 	 p_attribute_category_o   		=>per_dpf_shd.g_old_rec.attribute_category,
 	 p_attribute1_o          		=>per_dpf_shd.g_old_rec.attribute1,
 	 p_attribute2_o         		=>per_dpf_shd.g_old_rec.attribute2,
 	 p_attribute3_o                		=>per_dpf_shd.g_old_rec.attribute3,
 	 p_attribute4_o               		=>per_dpf_shd.g_old_rec.attribute4,
 	 p_attribute5_o              		=>per_dpf_shd.g_old_rec.attribute5,
 	 p_attribute6_o           		=>per_dpf_shd.g_old_rec.attribute6,
 	 p_attribute7_o            		=>per_dpf_shd.g_old_rec.attribute7,
 	 p_attribute8_o           		=>per_dpf_shd.g_old_rec.attribute8,
 	 p_attribute9_o          		=>per_dpf_shd.g_old_rec.attribute9,
 	 p_attribute10_o        		=>per_dpf_shd.g_old_rec.attribute10,
 	 p_attribute11_o       			=>per_dpf_shd.g_old_rec.attribute11,
 	 p_attribute12_o 			=>per_dpf_shd.g_old_rec.attribute12,
 	 p_attribute13_o     			=>per_dpf_shd.g_old_rec.attribute13,
 	 p_attribute14_o 			=>per_dpf_shd.g_old_rec.attribute14,
 	 p_attribute15_o           		=>per_dpf_shd.g_old_rec.attribute15,
 	 p_attribute16_o          		=>per_dpf_shd.g_old_rec.attribute16,
 	 p_attribute17_o         		=>per_dpf_shd.g_old_rec.attribute17,
 	 p_attribute18_o        		=>per_dpf_shd.g_old_rec.attribute18,
 	 p_attribute19_o       			=>per_dpf_shd.g_old_rec.attribute19,
 	 p_attribute20_o      			=>per_dpf_shd.g_old_rec.attribute20
     	 );
       	exception
        when hr_api.cannot_find_prog_unit then
             hr_api.cannot_find_prog_unit_error
                 (
		 p_module_name => 'PER_DEPLOYMENT_FACTORS',
                 p_hook_type   => 'AU'
                 );
     end;
--   End of API User Hook for post_update.
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
--   A Pl/Sql record structre.
--
-- Post Success:
--   The record structure will be returned with all system defaulted parameter
--   values converted into its current row attribute value.
--
-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this procedure will be a PL/SQL value error due to conversion

--   of datatypes or data lengths.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Row Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure convert_defs(p_rec in out nocopy per_dpf_shd.g_rec_type) is
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
  If (p_rec.position_id = hr_api.g_number) then
    p_rec.position_id :=
    per_dpf_shd.g_old_rec.position_id;
  End If;
  If (p_rec.person_id = hr_api.g_number) then
    p_rec.person_id :=
    per_dpf_shd.g_old_rec.person_id;
  End If;
  If (p_rec.job_id = hr_api.g_number) then
    p_rec.job_id :=
    per_dpf_shd.g_old_rec.job_id;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    per_dpf_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.work_any_country = hr_api.g_varchar2) then
    p_rec.work_any_country :=
    per_dpf_shd.g_old_rec.work_any_country;
  End If;
  If (p_rec.work_any_location = hr_api.g_varchar2) then
    p_rec.work_any_location :=
    per_dpf_shd.g_old_rec.work_any_location;
  End If;
  If (p_rec.relocate_domestically = hr_api.g_varchar2) then
    p_rec.relocate_domestically :=
    per_dpf_shd.g_old_rec.relocate_domestically;
  End If;
  If (p_rec.relocate_internationally = hr_api.g_varchar2) then
    p_rec.relocate_internationally :=
    per_dpf_shd.g_old_rec.relocate_internationally;
  End If;
  If (p_rec.travel_required = hr_api.g_varchar2) then
    p_rec.travel_required :=
    per_dpf_shd.g_old_rec.travel_required;
  End If;
  If (p_rec.country1 = hr_api.g_varchar2) then
    p_rec.country1 :=
    per_dpf_shd.g_old_rec.country1;
  End If;
  If (p_rec.country2 = hr_api.g_varchar2) then
    p_rec.country2 :=
    per_dpf_shd.g_old_rec.country2;
  End If;
  If (p_rec.country3 = hr_api.g_varchar2) then
    p_rec.country3 :=
    per_dpf_shd.g_old_rec.country3;
  End If;
  If (p_rec.work_duration = hr_api.g_varchar2) then
    p_rec.work_duration :=
    per_dpf_shd.g_old_rec.work_duration;
  End If;
  If (p_rec.work_schedule = hr_api.g_varchar2) then
    p_rec.work_schedule :=
    per_dpf_shd.g_old_rec.work_schedule;
  End If;
  If (p_rec.work_hours = hr_api.g_varchar2) then
    p_rec.work_hours :=
    per_dpf_shd.g_old_rec.work_hours;
  End If;
  If (p_rec.fte_capacity = hr_api.g_varchar2) then
    p_rec.fte_capacity :=
    per_dpf_shd.g_old_rec.fte_capacity;
  End If;
  If (p_rec.visit_internationally = hr_api.g_varchar2) then
    p_rec.visit_internationally :=
    per_dpf_shd.g_old_rec.visit_internationally;
  End If;
  If (p_rec.only_current_location = hr_api.g_varchar2) then
    p_rec.only_current_location :=
    per_dpf_shd.g_old_rec.only_current_location;
  End If;
  If (p_rec.no_country1 = hr_api.g_varchar2) then
    p_rec.no_country1 :=
    per_dpf_shd.g_old_rec.no_country1;
  End If;
  If (p_rec.no_country2 = hr_api.g_varchar2) then
    p_rec.no_country2 :=
    per_dpf_shd.g_old_rec.no_country2;
  End If;
  If (p_rec.no_country3 = hr_api.g_varchar2) then
    p_rec.no_country3 :=
    per_dpf_shd.g_old_rec.no_country3;
  End If;
  If (p_rec.comments = hr_api.g_varchar2) then
    p_rec.comments :=
    per_dpf_shd.g_old_rec.comments;
  End If;
  If (p_rec.earliest_available_date = hr_api.g_date) then
    p_rec.earliest_available_date :=
    per_dpf_shd.g_old_rec.earliest_available_date;
  End If;
  If (p_rec.available_for_transfer = hr_api.g_varchar2) then
    p_rec.available_for_transfer :=
    per_dpf_shd.g_old_rec.available_for_transfer;
  End If;
  If (p_rec.relocation_preference = hr_api.g_varchar2) then
    p_rec.relocation_preference :=
    per_dpf_shd.g_old_rec.relocation_preference;
  End If;
  If (p_rec.relocation_required = hr_api.g_varchar2) then
    p_rec.relocation_required :=
    per_dpf_shd.g_old_rec.relocation_required;
  End If;
  If (p_rec.passport_required = hr_api.g_varchar2) then
    p_rec.passport_required :=
    per_dpf_shd.g_old_rec.passport_required;
  End If;
  If (p_rec.location1 = hr_api.g_varchar2) then
    p_rec.location1 :=
    per_dpf_shd.g_old_rec.location1;
  End If;
  If (p_rec.location2 = hr_api.g_varchar2) then
    p_rec.location2 :=
    per_dpf_shd.g_old_rec.location2;
  End If;
  If (p_rec.location3 = hr_api.g_varchar2) then
    p_rec.location3 :=
    per_dpf_shd.g_old_rec.location3;
  End If;
  If (p_rec.other_requirements = hr_api.g_varchar2) then
    p_rec.other_requirements :=
    per_dpf_shd.g_old_rec.other_requirements;
  End If;
  If (p_rec.service_minimum = hr_api.g_varchar2) then
    p_rec.service_minimum :=
    per_dpf_shd.g_old_rec.service_minimum;
  End If;
  If (p_rec.attribute_category = hr_api.g_varchar2) then
    p_rec.attribute_category :=
    per_dpf_shd.g_old_rec.attribute_category;
  End If;
  If (p_rec.attribute1 = hr_api.g_varchar2) then
    p_rec.attribute1 :=
    per_dpf_shd.g_old_rec.attribute1;
  End If;
  If (p_rec.attribute2 = hr_api.g_varchar2) then
    p_rec.attribute2 :=
    per_dpf_shd.g_old_rec.attribute2;
  End If;
  If (p_rec.attribute3 = hr_api.g_varchar2) then
    p_rec.attribute3 :=
    per_dpf_shd.g_old_rec.attribute3;
  End If;
  If (p_rec.attribute4 = hr_api.g_varchar2) then
    p_rec.attribute4 :=
    per_dpf_shd.g_old_rec.attribute4;
  End If;
  If (p_rec.attribute5 = hr_api.g_varchar2) then
    p_rec.attribute5 :=
    per_dpf_shd.g_old_rec.attribute5;
  End If;
  If (p_rec.attribute6 = hr_api.g_varchar2) then
    p_rec.attribute6 :=
    per_dpf_shd.g_old_rec.attribute6;
  End If;
  If (p_rec.attribute7 = hr_api.g_varchar2) then
    p_rec.attribute7 :=
    per_dpf_shd.g_old_rec.attribute7;
  End If;
  If (p_rec.attribute8 = hr_api.g_varchar2) then
    p_rec.attribute8 :=
    per_dpf_shd.g_old_rec.attribute8;
  End If;
  If (p_rec.attribute9 = hr_api.g_varchar2) then
    p_rec.attribute9 :=
    per_dpf_shd.g_old_rec.attribute9;
  End If;
  If (p_rec.attribute10 = hr_api.g_varchar2) then
    p_rec.attribute10 :=
    per_dpf_shd.g_old_rec.attribute10;
  End If;
  If (p_rec.attribute11 = hr_api.g_varchar2) then
    p_rec.attribute11 :=
    per_dpf_shd.g_old_rec.attribute11;
  End If;
  If (p_rec.attribute12 = hr_api.g_varchar2) then
    p_rec.attribute12 :=
    per_dpf_shd.g_old_rec.attribute12;
  End If;
  If (p_rec.attribute13 = hr_api.g_varchar2) then
    p_rec.attribute13 :=
    per_dpf_shd.g_old_rec.attribute13;
  End If;
  If (p_rec.attribute14 = hr_api.g_varchar2) then
    p_rec.attribute14 :=
    per_dpf_shd.g_old_rec.attribute14;
  End If;
  If (p_rec.attribute15 = hr_api.g_varchar2) then
    p_rec.attribute15 :=
    per_dpf_shd.g_old_rec.attribute15;
  End If;
  If (p_rec.attribute16 = hr_api.g_varchar2) then
    p_rec.attribute16 :=
    per_dpf_shd.g_old_rec.attribute16;
  End If;
  If (p_rec.attribute17 = hr_api.g_varchar2) then
    p_rec.attribute17 :=
    per_dpf_shd.g_old_rec.attribute17;
  End If;
  If (p_rec.attribute18 = hr_api.g_varchar2) then
    p_rec.attribute18 :=
    per_dpf_shd.g_old_rec.attribute18;
  End If;
  If (p_rec.attribute19 = hr_api.g_varchar2) then
    p_rec.attribute19 :=
    per_dpf_shd.g_old_rec.attribute19;
  End If;
  If (p_rec.attribute20 = hr_api.g_varchar2) then
    p_rec.attribute20 :=
    per_dpf_shd.g_old_rec.attribute20;
  End If;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
End convert_defs;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_rec        in out nocopy per_dpf_shd.g_rec_type,
  p_effective_date in date
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --
  per_dpf_shd.lck
	(
	p_rec.deployment_factor_id,
	p_rec.object_version_number
	);
  --
  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.
  --
  -- 2. Call the supporting update validate operations.
  --
  convert_defs(p_rec);
  per_dpf_bus.update_validate(p_rec,p_effective_date);
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
  post_update(p_rec, p_effective_date);
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_deployment_factor_id         in number,
  p_position_id                  in number           ,
  p_person_id                    in number           ,
  p_job_id                       in number           ,
  p_business_group_id            in number           ,
  p_work_any_country             in varchar2         ,
  p_work_any_location            in varchar2         ,
  p_relocate_domestically        in varchar2         ,
  p_relocate_internationally     in varchar2         ,
  p_travel_required              in varchar2         ,
  p_country1                     in varchar2         ,
  p_country2                     in varchar2         ,
  p_country3                     in varchar2         ,
  p_work_duration                in varchar2         ,
  p_work_schedule                in varchar2         ,
  p_work_hours                   in varchar2         ,
  p_fte_capacity                 in varchar2         ,
  p_visit_internationally        in varchar2         ,
  p_only_current_location        in varchar2         ,
  p_no_country1                  in varchar2         ,
  p_no_country2                  in varchar2         ,
  p_no_country3                  in varchar2         ,
  p_comments                     in varchar2         ,
  p_earliest_available_date      in date             ,
  p_available_for_transfer       in varchar2         ,
  p_relocation_preference        in varchar2         ,
  p_relocation_required          in varchar2         ,
  p_passport_required            in varchar2         ,
  p_location1                    in varchar2         ,
  p_location2                    in varchar2         ,
  p_location3                    in varchar2         ,
  p_other_requirements           in varchar2         ,
  p_service_minimum              in varchar2         ,
  p_object_version_number        in out nocopy number,
  p_effective_date               in date,
  p_attribute_category           in varchar2         ,
  p_attribute1                   in varchar2         ,
  p_attribute2                   in varchar2         ,
  p_attribute3                   in varchar2         ,
  p_attribute4                   in varchar2         ,
  p_attribute5                   in varchar2         ,
  p_attribute6                   in varchar2         ,
  p_attribute7                   in varchar2         ,
  p_attribute8                   in varchar2         ,
  p_attribute9                   in varchar2         ,
  p_attribute10                  in varchar2         ,
  p_attribute11                  in varchar2         ,
  p_attribute12                  in varchar2         ,
  p_attribute13                  in varchar2         ,
  p_attribute14                  in varchar2         ,
  p_attribute15                  in varchar2         ,
  p_attribute16                  in varchar2         ,
  p_attribute17                  in varchar2         ,
  p_attribute18                  in varchar2         ,
  p_attribute19                  in varchar2         ,
  p_attribute20                  in varchar2         ) is
--
  l_rec	  per_dpf_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  per_dpf_shd.convert_args
  (
  p_deployment_factor_id,
  p_position_id,
  p_person_id,
  p_job_id,
  p_business_group_id,
  p_work_any_country,
  p_work_any_location,
  p_relocate_domestically,
  p_relocate_internationally,
  p_travel_required,
  p_country1,
  p_country2,
  p_country3,
  p_work_duration,
  p_work_schedule,
  p_work_hours,
  p_fte_capacity,
  p_visit_internationally,
  p_only_current_location,
  p_no_country1,
  p_no_country2,
  p_no_country3,
  p_comments,
  p_earliest_available_date,
  p_available_for_transfer,
  p_relocation_preference,
  p_relocation_required,
  p_passport_required,
  p_location1,
  p_location2,
  p_location3,
  p_other_requirements,
  p_service_minimum,
  p_object_version_number,
  p_attribute_category,
  p_attribute1,
  p_attribute2,
  p_attribute3,
  p_attribute4,
  p_attribute5,
  p_attribute6,
  p_attribute7,
  p_attribute8,
  p_attribute9,
  p_attribute10,
  p_attribute11,
  p_attribute12,
  p_attribute13,
  p_attribute14,
  p_attribute15,
  p_attribute16,
  p_attribute17,
  p_attribute18,
  p_attribute19,
  p_attribute20
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(l_rec,p_effective_date);
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end per_dpf_upd;

/