--------------------------------------------------------
--  DDL for Package Body GHR_PDI_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_PDI_UPD" as
/* $Header: ghpdirhi.pkb 120.1 2005/06/13 12:28:25 vravikan noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  ghr_pdi_upd.';  -- Global package name
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
Procedure update_dml(p_rec in out nocopy ghr_pdi_shd.g_rec_type) is
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
  --ghr_pdi_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the ghr_position_descriptions Row
  --
  update ghr_position_descriptions
  set
  routing_group_id                  = p_rec.routing_group_id,
  date_from                         = p_rec.date_from,
  date_to                           = p_rec.date_to,
  opm_cert_num                      = p_rec.opm_cert_num,
  flsa                              = p_rec.flsa,
  financial_statement               = p_rec.financial_statement,
  subject_to_ia_action              = p_rec.subject_to_ia_action,
  position_status                   = p_rec.position_status,
  position_is                       = p_rec.position_is,
  position_sensitivity              = p_rec.position_sensitivity,
  competitive_level                 = p_rec.competitive_level,
  pd_remarks                        = p_rec.pd_remarks,
  position_class_std                = p_rec.position_class_std,
  category                          = p_rec.category,
  career_ladder                     = p_rec.career_ladder,
  supervisor_name		    = p_rec.supervisor_name,
  supervisor_title 		    = p_rec.supervisor_title,
  supervisor_date                   = p_rec.supervisor_date,
  manager_name		            = p_rec.manager_name,
  manager_title 		    = p_rec.manager_title,
  manager_date                      = p_rec.manager_date,
  classifier_name		    = p_rec.classifier_name,
  classifier_title 		    = p_rec.classifier_title,
  classifier_date                   = p_rec.classifier_date,
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
  attribute20                       = p_rec.attribute20,
  business_group_id                       = p_rec.business_group_id,
  object_version_number             = p_rec.object_version_number
  where position_description_id = p_rec.position_description_id;
  --
  --ghr_pdi_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --ghr_pdi_shd.g_api_dml := false;   -- Unset the api dml status
    ghr_pdi_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --ghr_pdi_shd.g_api_dml := false;   -- Unset the api dml status
    ghr_pdi_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --ghr_pdi_shd.g_api_dml := false;   -- Unset the api dml status
    ghr_pdi_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    --ghr_pdi_shd.g_api_dml := false;   -- Unset the api dml status
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
Procedure pre_update(p_rec in ghr_pdi_shd.g_rec_type) is
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
Procedure post_update(p_rec in ghr_pdi_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  --
  -- This is a hook point and the user hook for post_update is called here.
  --
  begin
     ghr_pdi_rku.after_update	(
      p_position_description_id => p_rec.position_description_id,
      p_classifier_date         => p_rec.classifier_date,
--      p_pa_request_id           => p_rec.pa_request_id,
      p_attribute_category      => p_rec.attribute_category,
      p_routing_group_id        => p_rec.routing_group_id,
      p_date_from               => p_rec.date_from,
      p_date_to                 => p_rec.date_to,
      p_opm_cert_num            => p_rec.opm_cert_num,
      p_flsa                    => p_rec.flsa,
      p_financial_statement     => p_rec.financial_statement,
      p_subject_to_ia_action    => p_rec.subject_to_ia_action,
      p_position_status         => p_rec.position_status,
      p_position_is             => p_rec.position_is,
      p_position_sensitivity    => p_rec.position_sensitivity,
      p_competitive_level       => p_rec.competitive_level,
      p_pd_remarks              => p_rec.pd_remarks,
      p_position_class_std      => p_rec.position_class_std,
      p_category                => p_rec.category,
      p_career_ladder           => p_rec.career_ladder,
      p_supervisor_name         => p_rec.supervisor_name,
      p_supervisor_title        => p_rec.supervisor_title,
      p_supervisor_date         => p_rec.supervisor_date,
      p_manager_name            => p_rec.manager_name,
      p_manager_title           => p_rec.manager_title,
      p_manager_date            => p_rec.manager_date,
      p_classifier_name         => p_rec.classifier_name,
      p_classifier_title        => p_rec.classifier_title,
      p_attribute1              => p_rec.attribute1,
      p_attribute2              => p_rec.attribute2,
      p_attribute3              => p_rec.attribute3,
      p_attribute4              => p_rec.attribute4,
      p_attribute5              => p_rec.attribute5,
      p_attribute6              => p_rec.attribute6,
      p_attribute7              => p_rec.attribute7,
      p_attribute8              => p_rec.attribute8,
      p_attribute9              => p_rec.attribute9,
      p_attribute10             => p_rec.attribute10,
      p_attribute11             => p_rec.attribute11,
      p_attribute12             => p_rec.attribute12,
      p_attribute13             => p_rec.attribute13,
      p_attribute14             => p_rec.attribute14,
      p_attribute15             => p_rec.attribute15,
      p_attribute16             => p_rec.attribute16,
      p_attribute17             => p_rec.attribute17,
      p_attribute18             => p_rec.attribute18,
      p_attribute19             => p_rec.attribute19,
      p_attribute20             => p_rec.attribute20,
      p_business_group_id             => p_rec.business_group_id,
      p_object_version_number   => p_rec.object_version_number,
      p_classifier_date_o       => ghr_pdi_shd.g_old_rec.classifier_date,
--      p_pa_request_id_o         => ghr_pdi_shd.g_old_rec.pa_request_id,
      p_attribute_category_o    => ghr_pdi_shd.g_old_rec.attribute_category,
      p_routing_group_id_o      => ghr_pdi_shd.g_old_rec.routing_group_id,
      p_date_from_o             => ghr_pdi_shd.g_old_rec.date_from,
      p_date_to_o               => ghr_pdi_shd.g_old_rec.date_to,
      p_opm_cert_num_o          => ghr_pdi_shd.g_old_rec.opm_cert_num,
      p_flsa_o                  => ghr_pdi_shd.g_old_rec.flsa,
      p_financial_statement_o   => ghr_pdi_shd.g_old_rec.financial_statement,
      p_subject_to_ia_action_o  => ghr_pdi_shd.g_old_rec.subject_to_ia_action,
      p_position_status_o       => ghr_pdi_shd.g_old_rec.position_status,
      p_position_is_o           => ghr_pdi_shd.g_old_rec.position_is,
      p_position_sensitivity_o  => ghr_pdi_shd.g_old_rec.position_sensitivity,
      p_competitive_level_o     => ghr_pdi_shd.g_old_rec.competitive_level,
      p_pd_remarks_o            => ghr_pdi_shd.g_old_rec.pd_remarks,
      p_position_class_std_o    => ghr_pdi_shd.g_old_rec.position_class_std,
      p_category_o              => ghr_pdi_shd.g_old_rec.category,
      p_career_ladder_o         => ghr_pdi_shd.g_old_rec.career_ladder,
      p_supervisor_name_o       => ghr_pdi_shd.g_old_rec.supervisor_name,
      p_supervisor_title_o      => ghr_pdi_shd.g_old_rec.supervisor_title,
      p_supervisor_date_o       => ghr_pdi_shd.g_old_rec.supervisor_date,
      p_manager_name_o          => ghr_pdi_shd.g_old_rec.manager_name,
      p_manager_title_o         => ghr_pdi_shd.g_old_rec.manager_title,
      p_manager_date_o          => ghr_pdi_shd.g_old_rec.manager_date,
      p_classifier_name_o       => ghr_pdi_shd.g_old_rec.classifier_name,
      p_classifier_title_o      => ghr_pdi_shd.g_old_rec.classifier_title,
      p_attribute1_o            => ghr_pdi_shd.g_old_rec.attribute1,
      p_attribute2_o            => ghr_pdi_shd.g_old_rec.attribute2,
      p_attribute3_o            => ghr_pdi_shd.g_old_rec.attribute3,
      p_attribute4_o            => ghr_pdi_shd.g_old_rec.attribute4,
      p_attribute5_o            => ghr_pdi_shd.g_old_rec.attribute5,
      p_attribute6_o            => ghr_pdi_shd.g_old_rec.attribute6,
      p_attribute7_o            => ghr_pdi_shd.g_old_rec.attribute7,
      p_attribute8_o            => ghr_pdi_shd.g_old_rec.attribute8,
      p_attribute9_o            => ghr_pdi_shd.g_old_rec.attribute9,
      p_attribute10_o           => ghr_pdi_shd.g_old_rec.attribute10,
      p_attribute11_o           => ghr_pdi_shd.g_old_rec.attribute11,
      p_attribute12_o           => ghr_pdi_shd.g_old_rec.attribute12,
      p_attribute13_o           => ghr_pdi_shd.g_old_rec.attribute13,
      p_attribute14_o           => ghr_pdi_shd.g_old_rec.attribute14,
      p_attribute15_o           => ghr_pdi_shd.g_old_rec.attribute15,
      p_attribute16_o           => ghr_pdi_shd.g_old_rec.attribute16,
      p_attribute17_o           => ghr_pdi_shd.g_old_rec.attribute17,
      p_attribute18_o           => ghr_pdi_shd.g_old_rec.attribute18,
      p_attribute19_o           => ghr_pdi_shd.g_old_rec.attribute19,
      p_attribute20_o           => ghr_pdi_shd.g_old_rec.attribute20,
      p_business_group_id_o           => ghr_pdi_shd.g_old_rec.business_group_id,
      p_object_version_number_o => ghr_pdi_shd.g_old_rec.object_version_number
      );

  exception
        when hr_api.cannot_find_prog_unit then
             hr_api.cannot_find_prog_unit_error
		 (	 p_module_name => 'GHR_POSITION_DESCRIPTIONS'
			,p_hook_type   => 'AU'
	        );
  end;
  -- End of API User Hook for post_update.
  --
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
Procedure convert_defs(p_rec in out nocopy ghr_pdi_shd.g_rec_type) is
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
  If (p_rec.routing_group_id = hr_api.g_number) then
    p_rec.routing_group_id :=
    ghr_pdi_shd.g_old_rec.routing_group_id;
  End If;
  If (p_rec.date_from = hr_api.g_date) then
    p_rec.date_from :=
    ghr_pdi_shd.g_old_rec.date_from;
  End If;
  If (p_rec.date_to = hr_api.g_date) then
    p_rec.date_to :=
    ghr_pdi_shd.g_old_rec.date_to;
  End If;
  If (p_rec.opm_cert_num = hr_api.g_varchar2) then
    p_rec.opm_cert_num :=
    ghr_pdi_shd.g_old_rec.opm_cert_num;
  End If;
  If (p_rec.flsa = hr_api.g_varchar2) then
    p_rec.flsa :=
    ghr_pdi_shd.g_old_rec.flsa;
  End If;
  If (p_rec.financial_statement = hr_api.g_varchar2) then
    p_rec.financial_statement :=
    ghr_pdi_shd.g_old_rec.financial_statement;
  End If;
  If (p_rec.subject_to_ia_action = hr_api.g_varchar2) then
    p_rec.subject_to_ia_action :=
    ghr_pdi_shd.g_old_rec.subject_to_ia_action;
  End If;
  If (p_rec.position_status = hr_api.g_number) then
    p_rec.position_status :=
    ghr_pdi_shd.g_old_rec.position_status;
  End If;
  If (p_rec.position_is = hr_api.g_varchar2) then
    p_rec.position_is :=
    ghr_pdi_shd.g_old_rec.position_is;
  End If;
  If (p_rec.position_sensitivity = hr_api.g_varchar2) then
    p_rec.position_sensitivity :=
    ghr_pdi_shd.g_old_rec.position_sensitivity;
  End If;
  If (p_rec.competitive_level = hr_api.g_varchar2) then
    p_rec.competitive_level :=
    ghr_pdi_shd.g_old_rec.competitive_level;
  End If;
  If (p_rec.pd_remarks = hr_api.g_varchar2) then
    p_rec.pd_remarks :=
    ghr_pdi_shd.g_old_rec.pd_remarks;
  End If;
  If (p_rec.position_class_std = hr_api.g_varchar2) then
    p_rec.position_class_std :=
    ghr_pdi_shd.g_old_rec.position_class_std;
  End If;
  If (p_rec.category = hr_api.g_varchar2) then
    p_rec.category :=
    ghr_pdi_shd.g_old_rec.category;
  End If;
  If (p_rec.career_ladder = hr_api.g_varchar2) then
    p_rec.career_ladder :=
    ghr_pdi_shd.g_old_rec.career_ladder;
  End If;

/* Added by Dinkar. Karumuri for PD Phase II */

  If (p_rec.supervisor_name = hr_api.g_varchar2) then
    p_rec.supervisor_name :=
    ghr_pdi_shd.g_old_rec.supervisor_name;
  End If;
  If (p_rec.supervisor_title = hr_api.g_varchar2) then
    p_rec.supervisor_title :=
    ghr_pdi_shd.g_old_rec.supervisor_title;
  End If;
  If (p_rec.supervisor_date = hr_api.g_date) then
    p_rec.supervisor_date :=
    ghr_pdi_shd.g_old_rec.supervisor_date;
  End If;

  If (p_rec.manager_name = hr_api.g_varchar2) then
    p_rec.manager_name :=
    ghr_pdi_shd.g_old_rec.manager_name;
  End If;
  If (p_rec.manager_title = hr_api.g_varchar2) then
    p_rec.manager_title :=
    ghr_pdi_shd.g_old_rec.manager_title;
  End If;
  If (p_rec.manager_date = hr_api.g_date) then
    p_rec.manager_date :=
    ghr_pdi_shd.g_old_rec.manager_date;
  End If;

  If (p_rec.classifier_name = hr_api.g_varchar2) then
    p_rec.classifier_name :=
    ghr_pdi_shd.g_old_rec.classifier_name;
  End If;
  If (p_rec.classifier_title = hr_api.g_varchar2) then
    p_rec.classifier_title :=
    ghr_pdi_shd.g_old_rec.classifier_title;
  End If;
  If (p_rec.classifier_date = hr_api.g_date) then
    p_rec.classifier_date :=
    ghr_pdi_shd.g_old_rec.classifier_date;
  End If;

---------------------------------------------------------------------------

  If (p_rec.attribute_category = hr_api.g_varchar2) then
    p_rec.attribute_category :=
    ghr_pdi_shd.g_old_rec.attribute_category;
  End If;
  If (p_rec.attribute1 = hr_api.g_varchar2) then
    p_rec.attribute1 :=
    ghr_pdi_shd.g_old_rec.attribute1;
  End If;
  If (p_rec.attribute2 = hr_api.g_varchar2) then
    p_rec.attribute2 :=
    ghr_pdi_shd.g_old_rec.attribute2;
  End If;
  If (p_rec.attribute3 = hr_api.g_varchar2) then
    p_rec.attribute3 :=
    ghr_pdi_shd.g_old_rec.attribute3;
  End If;
  If (p_rec.attribute4 = hr_api.g_varchar2) then
    p_rec.attribute4 :=
    ghr_pdi_shd.g_old_rec.attribute4;
  End If;
  If (p_rec.attribute5 = hr_api.g_varchar2) then
    p_rec.attribute5 :=
    ghr_pdi_shd.g_old_rec.attribute5;
  End If;
  If (p_rec.attribute6 = hr_api.g_varchar2) then
    p_rec.attribute6 :=
    ghr_pdi_shd.g_old_rec.attribute6;
  End If;
  If (p_rec.attribute7 = hr_api.g_varchar2) then
    p_rec.attribute7 :=
    ghr_pdi_shd.g_old_rec.attribute7;
  End If;
  If (p_rec.attribute8 = hr_api.g_varchar2) then
    p_rec.attribute8 :=
    ghr_pdi_shd.g_old_rec.attribute8;
  End If;
  If (p_rec.attribute9 = hr_api.g_varchar2) then
    p_rec.attribute9 :=
    ghr_pdi_shd.g_old_rec.attribute9;
  End If;
  If (p_rec.attribute10 = hr_api.g_varchar2) then
    p_rec.attribute10 :=
    ghr_pdi_shd.g_old_rec.attribute10;
  End If;
  If (p_rec.attribute11 = hr_api.g_varchar2) then
    p_rec.attribute11 :=
    ghr_pdi_shd.g_old_rec.attribute11;
  End If;
  If (p_rec.attribute12 = hr_api.g_varchar2) then
    p_rec.attribute12 :=
    ghr_pdi_shd.g_old_rec.attribute12;
  End If;
  If (p_rec.attribute13 = hr_api.g_varchar2) then
    p_rec.attribute13 :=
    ghr_pdi_shd.g_old_rec.attribute13;
  End If;
  If (p_rec.attribute14 = hr_api.g_varchar2) then
    p_rec.attribute14 :=
    ghr_pdi_shd.g_old_rec.attribute14;
  End If;
  If (p_rec.attribute15 = hr_api.g_varchar2) then
    p_rec.attribute15 :=
    ghr_pdi_shd.g_old_rec.attribute15;
  End If;
  If (p_rec.attribute16 = hr_api.g_varchar2) then
    p_rec.attribute16 :=
    ghr_pdi_shd.g_old_rec.attribute16;
  End If;
  If (p_rec.attribute17 = hr_api.g_varchar2) then
    p_rec.attribute17 :=
    ghr_pdi_shd.g_old_rec.attribute17;
  End If;
  If (p_rec.attribute18 = hr_api.g_varchar2) then
    p_rec.attribute18 :=
    ghr_pdi_shd.g_old_rec.attribute18;
  End If;
  If (p_rec.attribute19 = hr_api.g_varchar2) then
    p_rec.attribute19 :=
    ghr_pdi_shd.g_old_rec.attribute19;
  End If;
  If (p_rec.attribute20 = hr_api.g_varchar2) then
    p_rec.attribute20 :=
    ghr_pdi_shd.g_old_rec.attribute20;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    ghr_pdi_shd.g_old_rec.business_group_id;
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
  p_rec        in out nocopy ghr_pdi_shd.g_rec_type
  ) is
--
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- We must lock the row which we need to update.
  --

  ghr_pdi_shd.lck
	(
	p_rec.position_description_id,
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
  ghr_pdi_bus.update_validate(p_rec);
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
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_position_description_id  in number,
  p_routing_group_id             in number           default hr_api.g_number,
  p_date_from                    in date             default hr_api.g_date,
  p_date_to                      in date             default hr_api.g_date,
  p_opm_cert_num                 in varchar2         default hr_api.g_varchar2,
  p_flsa                         in varchar2         default hr_api.g_varchar2,
  p_financial_statement          in varchar2         default hr_api.g_varchar2,
  p_subject_to_ia_action                in varchar2         default hr_api.g_varchar2,
  p_position_status              in number           default hr_api.g_number,
  p_position_is                  in varchar2         default hr_api.g_varchar2,
  p_position_sensitivity         in varchar2         default hr_api.g_varchar2,
  p_competitive_level            in varchar2         default hr_api.g_varchar2,
  p_pd_remarks                   in varchar2         default hr_api.g_varchar2,
  p_position_class_std           in varchar2         default hr_api.g_varchar2,
  p_category                     in varchar2         default hr_api.g_varchar2,
  p_career_ladder                in varchar2         default hr_api.g_varchar2,
  p_supervisor_name		 in varchar2	     default hr_api.g_varchar2,
  p_supervisor_title 		 in varchar2         default hr_api.g_varchar2,
  p_supervisor_date              in date             default hr_api.g_date,
  p_manager_name		 in varchar2         default hr_api.g_varchar2,
  p_manager_title 		 in varchar2         default hr_api.g_varchar2,
  p_manager_date                 in date             default hr_api.g_date,
  p_classifier_name		 in varchar2         default hr_api.g_varchar2,
  p_classifier_title 		 in varchar2         default hr_api.g_varchar2,
  p_classifier_date              in date             default hr_api.g_date,
  p_attribute_category           in varchar2         default hr_api.g_varchar2,
  p_attribute1                   in varchar2         default hr_api.g_varchar2,
  p_attribute2                   in varchar2         default hr_api.g_varchar2,
  p_attribute3                   in varchar2         default hr_api.g_varchar2,
  p_attribute4                   in varchar2         default hr_api.g_varchar2,
  p_attribute5                   in varchar2         default hr_api.g_varchar2,
  p_attribute6                   in varchar2         default hr_api.g_varchar2,
  p_attribute7                   in varchar2         default hr_api.g_varchar2,
  p_attribute8                   in varchar2         default hr_api.g_varchar2,
  p_attribute9                   in varchar2         default hr_api.g_varchar2,
  p_attribute10                  in varchar2         default hr_api.g_varchar2,
  p_attribute11                  in varchar2         default hr_api.g_varchar2,
  p_attribute12                  in varchar2         default hr_api.g_varchar2,
  p_attribute13                  in varchar2         default hr_api.g_varchar2,
  p_attribute14                  in varchar2         default hr_api.g_varchar2,
  p_attribute15                  in varchar2         default hr_api.g_varchar2,
  p_attribute16                  in varchar2         default hr_api.g_varchar2,
  p_attribute17                  in varchar2         default hr_api.g_varchar2,
  p_attribute18                  in varchar2         default hr_api.g_varchar2,
  p_attribute19                  in varchar2         default hr_api.g_varchar2,
  p_attribute20                  in varchar2         default hr_api.g_varchar2,
  p_business_group_id            in number           default hr_api.g_number,
  p_object_version_number        in out nocopy number
  ) is
--
  l_rec	  ghr_pdi_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin


  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  ghr_pdi_shd.convert_args
  (
  p_position_description_id,
  p_routing_group_id,
  p_date_from,
  p_date_to,
  p_opm_cert_num,
  p_flsa,
  p_financial_statement,
  p_subject_to_ia_action,
  p_position_status,
  p_position_is,
  p_position_sensitivity,
  p_competitive_level,
  p_pd_remarks,
  p_position_class_std,
  p_category,
  p_career_ladder,
  p_supervisor_name,
  p_supervisor_title,
  p_supervisor_date,
  p_manager_name,
  p_manager_title,
  p_manager_date,
  p_classifier_name,
  p_classifier_title,
  p_classifier_date,
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
  p_attribute20,
  p_business_group_id,
  p_object_version_number
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(l_rec);
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end ghr_pdi_upd;

/
