--------------------------------------------------------
--  DDL for Package Body PER_CEL_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_CEL_UPD" as
/* $Header: pecelrhi.pkb 120.3 2006/03/28 05:27:21 arumukhe noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  per_cel_upd.';  -- Global package name
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
-- Pre Conditions:
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure update_dml(p_rec in out nocopy per_cel_shd.g_rec_type) is
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
  per_cel_shd.g_api_dml := true;  -- Set the api dml status
  --
  -- Update the per_competence_elements Row
  --
  -- bug fix 3991608
  -- Update statement modified to update the columns
  -- information_category,information1..information20 with
  -- values in p_rec.information_category and p_rec.information1
  -- .. p_rec.information20.

  update per_competence_elements
  set
  competence_element_id             = p_rec.competence_element_id,
  object_version_number             = p_rec.object_version_number,
  proficiency_level_id              = p_rec.proficiency_level_id,
  high_proficiency_level_id         = p_rec.high_proficiency_level_id,
  weighting_level_id                = p_rec.weighting_level_id,
  rating_level_id                   = p_rec.rating_level_id,
  mandatory     	            = p_rec.mandatory,
  effective_date_from               = p_rec.effective_date_from,
  effective_date_to                 = p_rec.effective_date_to,
  group_competence_type             = p_rec.group_competence_type,
  competence_type                   = p_rec.competence_type,
  normal_elapse_duration            = p_rec.normal_elapse_duration,
  normal_elapse_duration_unit       = p_rec.normal_elapse_duration_unit,
  sequence_number                   = p_rec.sequence_number,
  source_of_proficiency_level       = p_rec.source_of_proficiency_level,
  line_score                        = p_rec.line_score,
  certification_date                = p_rec.certification_date,
  certification_method              = p_rec.certification_method,
  next_certification_date           = p_rec.next_certification_date,
  comments                          = p_rec.comments,
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
  party_id                          = p_rec.party_id ,
  qualification_type_id             = p_rec.qualification_type_id ,
  unit_standard_type                = p_rec.unit_standard_type ,
  status               	            = p_rec.status ,
  information_category              = p_rec.information_category,
  information1                      = p_rec.information1,
  information2                      = p_rec.information2,
  information3                      = p_rec.information3,
  information4                      = p_rec.information4,
  information5                      = p_rec.information5,
  information6                      = p_rec.information6,
  information7                      = p_rec.information7,
  information8                      = p_rec.information8,
  information9                      = p_rec.information9,
  information10                     = p_rec.information10,
  information11                     = p_rec.information11,
  information12                     = p_rec.information12,
  information13                     = p_rec.information13,
  information14                     = p_rec.information14,
  information15                     = p_rec.information15,
  information16                     = p_rec.information16,
  information17                     = p_rec.information17,
  information18                     = p_rec.information18,
  information19                     = p_rec.information19,
  information20                     = p_rec.information20,
  achieved_date                     = p_rec.achieved_date,
  appr_line_score                   = p_rec.appr_line_score
  where competence_element_id = p_rec.competence_element_id;
  --
  per_cel_shd.g_api_dml := false;   -- Unset the api dml status
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
--
Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    per_cel_shd.g_api_dml := false;   -- Unset the api dml status
    per_cel_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    per_cel_shd.g_api_dml := false;   -- Unset the api dml status
    per_cel_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    per_cel_shd.g_api_dml := false;   -- Unset the api dml status
    per_cel_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    per_cel_shd.g_api_dml := false;   -- Unset the api dml status
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure pre_update(p_rec in per_cel_shd.g_rec_type) is
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure post_update(p_rec in per_cel_shd.g_rec_type) is
--
  l_proc  varchar2(72) := g_package||'post_update';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- This is a hook point and the user hook for post_update is called here.
  --
  begin
     per_cel_rku.after_update	(
      p_competence_element_id       => p_rec.competence_element_id      ,
      p_business_group_id            => p_rec.business_group_id         ,
      p_object_version_number        => p_rec.object_version_number     ,
      p_type                         => p_rec.type                      ,
      p_competence_id                => p_rec.competence_id             ,
--      p_member_competence_set_id     => p_rec.member_competence_set_id  ,
      p_proficiency_level_id         => p_rec.proficiency_level_id      ,
      p_high_proficiency_level_id    => p_rec.high_proficiency_level_id ,
      p_weighting_level_id           => p_rec.weighting_level_id        ,
      p_rating_level_id              => p_rec.rating_level_id           ,
      p_person_id                    => p_rec.person_id                 ,
      p_enterprise_id                => p_rec.enterprise_id             ,
      p_job_id                       => p_rec.job_id                    ,
      p_valid_grade_id               => p_rec.valid_grade_id            ,
      p_position_id                  => p_rec.position_id               ,
      p_organization_id              => p_rec.organization_id           ,
--      p_work_item_id                 => p_rec.work_item_id              ,
--      p_competence_set_id            => p_rec.competence_set_id         ,
      p_parent_competence_element_id => p_rec.parent_competence_element_id,
      p_activity_version_id          => p_rec.activity_version_id       ,
      p_assessment_id                => p_rec.assessment_id             ,
      p_assessment_type_id           => p_rec.assessment_type_id        ,
      p_mandatory                    => p_rec.mandatory                 ,
      p_effective_date_from          => p_rec.effective_date_from       ,
      p_effective_date_to            => p_rec.effective_date_to         ,
      p_group_competence_type        => p_rec.group_competence_type     ,
      p_competence_type              => p_rec.competence_type           ,
      p_sequence_number              => p_rec.sequence_number           ,
      p_normal_elapse_duration       => p_rec.normal_elapse_duration    ,
      p_normal_elapse_duration_unit  => p_rec.normal_elapse_duration_unit ,
      p_source_of_proficiency_level  => p_rec.source_of_proficiency_level ,
      p_line_score                   => p_rec.line_score                ,
      p_certification_date           => p_rec.certification_date        ,
      p_certification_method         => p_rec.certification_method      ,
      p_next_certification_date      => p_rec.next_certification_date   ,
      p_comments                     => p_rec.comments                  ,
      p_attribute_category           => p_rec.attribute_category        ,
      p_attribute1                   => p_rec.attribute1   ,
      p_attribute2                   => p_rec.attribute2   ,
      p_attribute3                   => p_rec.attribute3   ,
      p_attribute4                   => p_rec.attribute4   ,
      p_attribute5                   => p_rec.attribute5   ,
      p_attribute6                   => p_rec.attribute6   ,
      p_attribute7                   => p_rec.attribute7   ,
      p_attribute8                   => p_rec.attribute8   ,
      p_attribute9                   => p_rec.attribute9   ,
      p_attribute10                  => p_rec.attribute10  ,
      p_attribute11                  => p_rec.attribute11  ,
      p_attribute12                  => p_rec.attribute12  ,
      p_attribute13                  => p_rec.attribute13  ,
      p_attribute14                  => p_rec.attribute14  ,
      p_attribute15                  => p_rec.attribute15  ,
      p_attribute16                  => p_rec.attribute16  ,
      p_attribute17                  => p_rec.attribute17  ,
      p_attribute18                  => p_rec.attribute18  ,
      p_attribute19                  => p_rec.attribute19  ,
      p_attribute20                  => p_rec.attribute20  ,
      p_object_id                    => p_rec.object_id    ,
      p_object_name                  => p_rec.object_name  ,
      p_party_id                     => p_rec.party_id  , -- HR/TCA merge
  -- BUG3356369
      p_qualification_type_id        => p_rec.qualification_type_id,
      p_unit_standard_type           => p_rec.unit_standard_type,
      p_status                       => p_rec.status,
      p_information_category         => p_rec.information_category ,
      p_information1                 => p_rec.information1   ,
      p_information2                 => p_rec.information2   ,
      p_information3                 => p_rec.information3   ,
      p_information4                 => p_rec.information4   ,
      p_information5                 => p_rec.information5   ,
      p_information6                 => p_rec.information6   ,
      p_information7                 => p_rec.information7   ,
      p_information8                 => p_rec.information8   ,
      p_information9                 => p_rec.information9   ,
      p_information10                => p_rec.information10  ,
      p_information11                => p_rec.information11  ,
      p_information12                => p_rec.information12  ,
      p_information13                => p_rec.information13  ,
      p_information14                => p_rec.information14  ,
      p_information15                => p_rec.information15  ,
      p_information16                => p_rec.information16  ,
      p_information17                => p_rec.information17  ,
      p_information18                => p_rec.information18  ,
      p_information19                => p_rec.information19  ,
      p_information20                => p_rec.information20  ,
      p_achieved_date                => p_rec.achieved_date  ,
      p_appr_line_score              => p_rec.appr_line_score,
      p_business_group_id_o     => per_cel_shd.g_old_rec.business_group_id    ,
      p_object_version_number_o => per_cel_shd.g_old_rec.object_version_number,
      p_type_o                  => per_cel_shd.g_old_rec.type                 ,
      p_competence_id_o         => per_cel_shd.g_old_rec.competence_id        ,
--      p_member_competence_set_id_o   =>
--                          per_cel_shd.g_old_rec.member_competence_set_id      ,
      p_proficiency_level_id_o  => per_cel_shd.g_old_rec.proficiency_level_id ,
      p_high_proficiency_level_id_o  =>
                          per_cel_shd.g_old_rec.high_proficiency_level_id     ,
      p_weighting_level_id_o    => per_cel_shd.g_old_rec.weighting_level_id   ,
      p_rating_level_id_o       => per_cel_shd.g_old_rec.rating_level_id      ,
      p_person_id_o             => per_cel_shd.g_old_rec.person_id            ,
      p_enterprise_id_o         => per_cel_shd.g_old_rec.enterprise_id        ,
      p_job_id_o                => per_cel_shd.g_old_rec.job_id               ,
      p_valid_grade_id_o        => per_cel_shd.g_old_rec.valid_grade_id       ,
      p_position_id_o           => per_cel_shd.g_old_rec.position_id          ,
      p_organization_id_o       => per_cel_shd.g_old_rec.organization_id      ,
--      p_work_item_id_o          => per_cel_shd.g_old_rec.work_item_id         ,
--      p_competence_set_id_o     => per_cel_shd.g_old_rec.competence_set_id    ,
      p_parent_competence_element_o  =>
                          per_cel_shd.g_old_rec.parent_competence_element_id  ,
      p_activity_version_id_o   => per_cel_shd.g_old_rec.activity_version_id  ,
      p_assessment_id_o         => per_cel_shd.g_old_rec.assessment_id        ,
      p_assessment_type_id_o    => per_cel_shd.g_old_rec.assessment_type_id   ,
      p_mandatory_o             => per_cel_shd.g_old_rec.mandatory            ,
      p_effective_date_from_o   => per_cel_shd.g_old_rec.effective_date_from  ,
      p_effective_date_to_o     => per_cel_shd.g_old_rec.effective_date_to    ,
      p_group_competence_type_o => per_cel_shd.g_old_rec.group_competence_type,
      p_competence_type_o       => per_cel_shd.g_old_rec.competence_type      ,
      p_sequence_number_o       => per_cel_shd.g_old_rec.sequence_number      ,
      p_normal_elapse_duration_o     =>
                          per_cel_shd.g_old_rec.normal_elapse_duration        ,
      p_normal_elapse_duration_uni_o =>
                          per_cel_shd.g_old_rec.normal_elapse_duration_unit   ,
      p_source_of_proficiency_leve_o =>
                          per_cel_shd.g_old_rec.source_of_proficiency_level   ,
      p_line_score_o            => per_cel_shd.g_old_rec.line_score           ,
      p_certification_date_o    => per_cel_shd.g_old_rec.certification_date   ,
      p_certification_method_o  => per_cel_shd.g_old_rec.certification_method ,
      p_next_certification_date_o    =>
                          per_cel_shd.g_old_rec.next_certification_date       ,
      p_comments_o              => per_cel_shd.g_old_rec.comments             ,
      p_attribute_category_o    => per_cel_shd.g_old_rec.attribute_category   ,
      p_attribute1_o            => per_cel_shd.g_old_rec.attribute1   ,
      p_attribute2_o            => per_cel_shd.g_old_rec.attribute2   ,
      p_attribute3_o            => per_cel_shd.g_old_rec.attribute3   ,
      p_attribute4_o            => per_cel_shd.g_old_rec.attribute4   ,
      p_attribute5_o            => per_cel_shd.g_old_rec.attribute5   ,
      p_attribute6_o            => per_cel_shd.g_old_rec.attribute6   ,
      p_attribute7_o            => per_cel_shd.g_old_rec.attribute7   ,
      p_attribute8_o            => per_cel_shd.g_old_rec.attribute8   ,
      p_attribute9_o            => per_cel_shd.g_old_rec.attribute9   ,
      p_attribute10_o           => per_cel_shd.g_old_rec.attribute10  ,
      p_attribute11_o           => per_cel_shd.g_old_rec.attribute11  ,
      p_attribute12_o           => per_cel_shd.g_old_rec.attribute12  ,
      p_attribute13_o           => per_cel_shd.g_old_rec.attribute13  ,
      p_attribute14_o           => per_cel_shd.g_old_rec.attribute14  ,
      p_attribute15_o           => per_cel_shd.g_old_rec.attribute15  ,
      p_attribute16_o           => per_cel_shd.g_old_rec.attribute16  ,
      p_attribute17_o           => per_cel_shd.g_old_rec.attribute17  ,
      p_attribute18_o           => per_cel_shd.g_old_rec.attribute18  ,
      p_attribute19_o           => per_cel_shd.g_old_rec.attribute19  ,
      p_attribute20_o           => per_cel_shd.g_old_rec.attribute20  ,
      p_object_id_o             => per_cel_shd.g_old_rec.object_id    ,
      p_object_name_o           => per_cel_shd.g_old_rec.object_name  ,
      p_party_id_o              => per_cel_shd.g_old_rec.party_id, -- HR/TCA merge
  -- BUG3356369
      p_qualification_type_id_o  => per_cel_shd.g_old_rec.qualification_type_id,
      p_unit_standard_type_o     => per_cel_shd.g_old_rec.unit_standard_type,
      p_status_o                  => per_cel_shd.g_old_rec.status,
      p_information_category_o    => per_cel_shd.g_old_rec.information_category   ,
      p_information1_o            => per_cel_shd.g_old_rec.information1   ,
      p_information2_o            => per_cel_shd.g_old_rec.information2   ,
      p_information3_o            => per_cel_shd.g_old_rec.information3   ,
      p_information4_o            => per_cel_shd.g_old_rec.information4   ,
      p_information5_o            => per_cel_shd.g_old_rec.information5   ,
      p_information6_o            => per_cel_shd.g_old_rec.information6   ,
      p_information7_o            => per_cel_shd.g_old_rec.information7   ,
      p_information8_o            => per_cel_shd.g_old_rec.information8   ,
      p_information9_o            => per_cel_shd.g_old_rec.information9   ,
      p_information10_o           => per_cel_shd.g_old_rec.information10  ,
      p_information11_o           => per_cel_shd.g_old_rec.information11  ,
      p_information12_o           => per_cel_shd.g_old_rec.information12  ,
      p_information13_o           => per_cel_shd.g_old_rec.information13  ,
      p_information14_o           => per_cel_shd.g_old_rec.information14  ,
      p_information15_o           => per_cel_shd.g_old_rec.information15  ,
      p_information16_o           => per_cel_shd.g_old_rec.information16  ,
      p_information17_o           => per_cel_shd.g_old_rec.information17  ,
      p_information18_o           => per_cel_shd.g_old_rec.information18  ,
      p_information19_o           => per_cel_shd.g_old_rec.information19  ,
      p_information20_o           => per_cel_shd.g_old_rec.information20  ,
      p_achieved_date_o           => per_cel_shd.g_old_rec.achieved_date  ,
      p_appr_line_score_o         => per_cel_shd.g_old_rec.appr_line_score
     );
     exception
        when hr_api.cannot_find_prog_unit then
             hr_api.cannot_find_prog_unit_error
		 (	p_module_name => 'PER_COMPETENCE_ELEMENTS'
		 	,p_hook_type  => 'AU'
	        );
  end;
  -- End of API User Hook for post_update
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
-- Pre Conditions:
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
--   Internal Table Handler Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure convert_defs(p_rec in out nocopy per_cel_shd.g_rec_type) is
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
  If (p_rec.type = hr_api.g_varchar2) then
    p_rec.type :=
    per_cel_shd.g_old_rec.type;
  End If;
  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    per_cel_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.competence_id = hr_api.g_number) then
    p_rec.competence_id :=
    per_cel_shd.g_old_rec.competence_id;
  End If;
  If (p_rec.proficiency_level_id = hr_api.g_number) then
    p_rec.proficiency_level_id :=
    per_cel_shd.g_old_rec.proficiency_level_id;
  End If;
  If (p_rec.high_proficiency_level_id = hr_api.g_number) then
    p_rec.high_proficiency_level_id :=
    per_cel_shd.g_old_rec.high_proficiency_level_id;
  End If;
  If (p_rec.weighting_level_id = hr_api.g_number) then
    p_rec.weighting_level_id :=
    per_cel_shd.g_old_rec.weighting_level_id;
  End If;
  If (p_rec.rating_level_id = hr_api.g_number) then
    p_rec.rating_level_id :=
    per_cel_shd.g_old_rec.rating_level_id;
  End If;
  If (p_rec.person_id = hr_api.g_number) then
    p_rec.person_id :=
    per_cel_shd.g_old_rec.person_id;
  End If;
  If (p_rec.job_id = hr_api.g_number) then
    p_rec.job_id :=
    per_cel_shd.g_old_rec.job_id;
  End If;
  If (p_rec.valid_grade_id = hr_api.g_number) then
    p_rec.valid_grade_id :=
    per_cel_shd.g_old_rec.valid_grade_id;
  end if;
  If (p_rec.enterprise_id = hr_api.g_number) then
    p_rec.enterprise_id :=
    per_cel_shd.g_old_rec.enterprise_id;
  End If;
  If (p_rec.position_id = hr_api.g_number) then
    p_rec.position_id :=
    per_cel_shd.g_old_rec.position_id;
  End If;
  If (p_rec.organization_id = hr_api.g_number) then
    p_rec.organization_id :=
    per_cel_shd.g_old_rec.organization_id;
  End If;
  If (p_rec.parent_competence_element_id = hr_api.g_number) then
    p_rec.parent_competence_element_id :=
    per_cel_shd.g_old_rec.parent_competence_element_id;
  End If;
  If (p_rec.activity_version_id = hr_api.g_number) then
    p_rec.activity_version_id :=
    per_cel_shd.g_old_rec.activity_version_id;
  End If;
  If (p_rec.assessment_id = hr_api.g_number) then
    p_rec.assessment_id :=
    per_cel_shd.g_old_rec.assessment_id;
  End If;
  If (p_rec.assessment_type_id = hr_api.g_number) then
    p_rec.assessment_type_id :=
    per_cel_shd.g_old_rec.assessment_type_id;
  End If;
  If (p_rec.mandatory = hr_api.g_varchar2) then
    p_rec.mandatory :=
    per_cel_shd.g_old_rec.mandatory;
  End If;
  If (p_rec.effective_date_from = hr_api.g_date) then
    p_rec.effective_date_from :=
    per_cel_shd.g_old_rec.effective_date_from;
  End If;
  If (p_rec.effective_date_to = hr_api.g_date) then
    p_rec.effective_date_to :=
    per_cel_shd.g_old_rec.effective_date_to;
  End If;
  If (p_rec.group_competence_type = hr_api.g_varchar2) then
    p_rec.group_competence_type :=
    per_cel_shd.g_old_rec.group_competence_type;
  End If;
  If (p_rec.competence_type = hr_api.g_varchar2) then
    p_rec.competence_type :=
    per_cel_shd.g_old_rec.competence_type;
  End If;
  If (p_rec.normal_elapse_duration = hr_api.g_number) then
    p_rec.normal_elapse_duration :=
    per_cel_shd.g_old_rec.normal_elapse_duration;
  End If;
  If (p_rec.normal_elapse_duration_unit = hr_api.g_varchar2) then
    p_rec.normal_elapse_duration_unit :=
    per_cel_shd.g_old_rec.normal_elapse_duration_unit;
  End If;
  If (p_rec.sequence_number = hr_api.g_number) then
    p_rec.sequence_number :=
    per_cel_shd.g_old_rec.sequence_number;
  End If;
  If (p_rec.source_of_proficiency_level = hr_api.g_varchar2) then
    p_rec.source_of_proficiency_level :=
    per_cel_shd.g_old_rec.source_of_proficiency_level;
  End If;
  If (p_rec.line_score = hr_api.g_number) then
    p_rec.line_score :=
    per_cel_shd.g_old_rec.line_score;
  End If;
  If (p_rec.certification_date = hr_api.g_date) then
    p_rec.certification_date :=
    per_cel_shd.g_old_rec.certification_date;
  End If;
  If (p_rec.certification_method = hr_api.g_varchar2) then
    p_rec.certification_method :=
    per_cel_shd.g_old_rec.certification_method;
  End If;
  If (p_rec.next_certification_date = hr_api.g_date) then
    p_rec.next_certification_date :=
    per_cel_shd.g_old_rec.next_certification_date;
  End If;
  If (p_rec.comments = hr_api.g_varchar2) then
    p_rec.comments :=
    per_cel_shd.g_old_rec.comments;
  End If;
  If (p_rec.attribute_category = hr_api.g_varchar2) then
    p_rec.attribute_category :=
    per_cel_shd.g_old_rec.attribute_category;
  End If;
  If (p_rec.attribute1 = hr_api.g_varchar2) then
    p_rec.attribute1 :=
    per_cel_shd.g_old_rec.attribute1;
  End If;
  If (p_rec.attribute2 = hr_api.g_varchar2) then
    p_rec.attribute2 :=
    per_cel_shd.g_old_rec.attribute2;
  End If;
  If (p_rec.attribute3 = hr_api.g_varchar2) then
    p_rec.attribute3 :=
    per_cel_shd.g_old_rec.attribute3;
  End If;
  If (p_rec.attribute4 = hr_api.g_varchar2) then
    p_rec.attribute4 :=
    per_cel_shd.g_old_rec.attribute4;
  End If;
  If (p_rec.attribute5 = hr_api.g_varchar2) then
    p_rec.attribute5 :=
    per_cel_shd.g_old_rec.attribute5;
  End If;
  If (p_rec.attribute6 = hr_api.g_varchar2) then
    p_rec.attribute6 :=
    per_cel_shd.g_old_rec.attribute6;
  End If;
  If (p_rec.attribute7 = hr_api.g_varchar2) then
    p_rec.attribute7 :=
    per_cel_shd.g_old_rec.attribute7;
  End If;
  If (p_rec.attribute8 = hr_api.g_varchar2) then
    p_rec.attribute8 :=
    per_cel_shd.g_old_rec.attribute8;
  End If;
  If (p_rec.attribute9 = hr_api.g_varchar2) then
    p_rec.attribute9 :=
    per_cel_shd.g_old_rec.attribute9;
  End If;
  If (p_rec.attribute10 = hr_api.g_varchar2) then
    p_rec.attribute10 :=
    per_cel_shd.g_old_rec.attribute10;
  End If;
  If (p_rec.attribute11 = hr_api.g_varchar2) then
    p_rec.attribute11 :=
    per_cel_shd.g_old_rec.attribute11;
  End If;
  If (p_rec.attribute12 = hr_api.g_varchar2) then
    p_rec.attribute12 :=
    per_cel_shd.g_old_rec.attribute12;
  End If;
  If (p_rec.attribute13 = hr_api.g_varchar2) then
    p_rec.attribute13 :=
    per_cel_shd.g_old_rec.attribute13;
  End If;
  If (p_rec.attribute14 = hr_api.g_varchar2) then
    p_rec.attribute14 :=
    per_cel_shd.g_old_rec.attribute14;
  End If;
  If (p_rec.attribute15 = hr_api.g_varchar2) then
    p_rec.attribute15 :=
    per_cel_shd.g_old_rec.attribute15;
  End If;
  If (p_rec.attribute16 = hr_api.g_varchar2) then
    p_rec.attribute16 :=
    per_cel_shd.g_old_rec.attribute16;
  End If;
  If (p_rec.attribute17 = hr_api.g_varchar2) then
    p_rec.attribute17 :=
    per_cel_shd.g_old_rec.attribute17;
  End If;
  If (p_rec.attribute18 = hr_api.g_varchar2) then
    p_rec.attribute18 :=
    per_cel_shd.g_old_rec.attribute18;
  End If;
  If (p_rec.attribute19 = hr_api.g_varchar2) then
    p_rec.attribute19 :=
    per_cel_shd.g_old_rec.attribute19;
  End If;
  If (p_rec.attribute20 = hr_api.g_varchar2) then
    p_rec.attribute20 :=
    per_cel_shd.g_old_rec.attribute20;
  End If;
  if (p_rec.object_id = hr_api.g_number) then
    p_rec.object_id :=
    per_cel_shd.g_old_rec.object_id;
  End If;

  If (p_rec.object_name = hr_api.g_varchar2) then
    p_rec.object_name :=
    per_cel_shd.g_old_rec.object_name;
  End if;
 -- ngundura added last two if conditions for object_id and name
  If (p_rec.party_id = hr_api.g_number) then  -- HR/TCA merge
    p_rec.party_id :=
    per_cel_shd.g_old_rec.party_id;
  End If;
  If (p_rec.qualification_type_id = hr_api.g_number) then
    p_rec.qualification_type_id :=
    per_cel_shd.g_old_rec.qualification_type_id;
  End If;
  If (p_rec.unit_standard_type = hr_api.g_varchar2) then
    p_rec.unit_standard_type :=
    per_cel_shd.g_old_rec.unit_standard_type;
  End If;
  If (p_rec.status = hr_api.g_varchar2) then
    p_rec.status :=
    per_cel_shd.g_old_rec.status;
  End If;
  If (p_rec.information_category = hr_api.g_varchar2) then
    p_rec.information_category :=
    per_cel_shd.g_old_rec.information_category;
  End If;
  If (p_rec.information1 = hr_api.g_varchar2) then
    p_rec.information1 :=
    per_cel_shd.g_old_rec.information1;
  End If;
  If (p_rec.information2 = hr_api.g_varchar2) then
    p_rec.information2 :=
    per_cel_shd.g_old_rec.information2;
  End If;
  If (p_rec.information3 = hr_api.g_varchar2) then
    p_rec.information3 :=
    per_cel_shd.g_old_rec.information3;
  End If;
  If (p_rec.information4 = hr_api.g_varchar2) then
    p_rec.information4 :=
    per_cel_shd.g_old_rec.information4;
  End If;
  If (p_rec.information5 = hr_api.g_varchar2) then
    p_rec.information5 :=
    per_cel_shd.g_old_rec.information5;
  End If;
  If (p_rec.information6 = hr_api.g_varchar2) then
    p_rec.information6 :=
    per_cel_shd.g_old_rec.information6;
  End If;
  If (p_rec.information7 = hr_api.g_varchar2) then
    p_rec.information7 :=
    per_cel_shd.g_old_rec.information7;
  End If;
  If (p_rec.information8 = hr_api.g_varchar2) then
    p_rec.information8 :=
    per_cel_shd.g_old_rec.information8;
  End If;
  If (p_rec.information9 = hr_api.g_varchar2) then
    p_rec.information9 :=
    per_cel_shd.g_old_rec.information9;
  End If;
  If (p_rec.information10 = hr_api.g_varchar2) then
    p_rec.information10 :=
    per_cel_shd.g_old_rec.information10;
  End If;
  If (p_rec.information11 = hr_api.g_varchar2) then
    p_rec.information11 :=
    per_cel_shd.g_old_rec.information11;
  End If;
  If (p_rec.information12 = hr_api.g_varchar2) then
    p_rec.information12 :=
    per_cel_shd.g_old_rec.information12;
  End If;
  If (p_rec.information13 = hr_api.g_varchar2) then
    p_rec.information13 :=
    per_cel_shd.g_old_rec.information13;
  End If;
  If (p_rec.information14 = hr_api.g_varchar2) then
    p_rec.information14 :=
    per_cel_shd.g_old_rec.information14;
  End If;
  If (p_rec.information15 = hr_api.g_varchar2) then
    p_rec.information15 :=
    per_cel_shd.g_old_rec.information15;
  End If;
  If (p_rec.information16 = hr_api.g_varchar2) then
    p_rec.information16 :=
    per_cel_shd.g_old_rec.information16;
  End If;
  If (p_rec.information17 = hr_api.g_varchar2) then
    p_rec.information17 :=
    per_cel_shd.g_old_rec.information17;
  End If;
  If (p_rec.information18 = hr_api.g_varchar2) then
    p_rec.information18 :=
    per_cel_shd.g_old_rec.information18;
  End If;
  If (p_rec.information19 = hr_api.g_varchar2) then
    p_rec.information19 :=
    per_cel_shd.g_old_rec.information19;
  End If;
  If (p_rec.information20 = hr_api.g_varchar2) then
    p_rec.information20 :=
    per_cel_shd.g_old_rec.information20;
  End If;
  If (p_rec.achieved_date = hr_api.g_date) then
    p_rec.achieved_date :=
    per_cel_shd.g_old_rec.achieved_date;
  End If;
  If (p_rec.appr_line_score = hr_api.g_number) then
    p_rec.appr_line_score :=
    per_cel_shd.g_old_rec.appr_line_score;
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
  p_rec        in out nocopy per_cel_shd.g_rec_type,
  p_validate   in     boolean default false,
  p_effective_date	in date
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
    SAVEPOINT upd_per_cel;
  End If;
  --
  -- We must lock the row which we need to update.
  --
  per_cel_shd.lck
	(
	p_rec.competence_element_id,
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

  per_cel_bus.update_validate(p_rec,p_effective_date);
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
    ROLLBACK TO upd_per_cel;
End upd;
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< upd >----------------------------------|
-- ----------------------------------------------------------------------------
Procedure upd
  (
  p_competence_element_id        in number,
  p_object_version_number        in out nocopy number,
  p_proficiency_level_id         in number           default hr_api.g_number,
  p_high_proficiency_level_id    in number           default hr_api.g_number,
  p_weighting_level_id           in number           default hr_api.g_number,
  p_rating_level_id              in number           default hr_api.g_number,
  p_mandatory 		         in varchar2         default hr_api.g_varchar2,
  p_effective_date_from          in date             default hr_api.g_date,
  p_effective_date_to            in date             default hr_api.g_date,
  p_group_competence_type        in varchar2         default hr_api.g_varchar2,
  p_competence_type              in varchar2         default hr_api.g_varchar2,
  p_normal_elapse_duration       in number           default hr_api.g_number,
  p_normal_elapse_duration_unit  in varchar2         default hr_api.g_varchar2,
  p_sequence_number              in number           default hr_api.g_number,
  p_source_of_proficiency_level  in varchar2         default hr_api.g_varchar2,
  p_line_score                   in number           default hr_api.g_number,
  p_certification_date           in date             default hr_api.g_date,
  p_certification_method         in varchar2         default hr_api.g_varchar2,
  p_next_certification_date      in date             default hr_api.g_date,
  p_comments                     in varchar2         default hr_api.g_varchar2,
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
  p_effective_date		 in date,
  p_party_id                     in number           default hr_api.g_number,
  p_validate                     in boolean      default false,
  -- p_object_id                    in number         default hr_api.g_number,
  -- p_object_name                  in varchar2         default hr_api.g_varchar2
  p_qualification_type_id        in number           default hr_api.g_number,
  p_unit_standard_type           in varchar2         default hr_api.g_varchar2,
  p_status                       in varchar2         default hr_api.g_varchar2,
  p_information_category         in varchar2         default hr_api.g_varchar2,
  p_information1                 in varchar2         default hr_api.g_varchar2,
  p_information2                 in varchar2         default hr_api.g_varchar2,
  p_information3                 in varchar2         default hr_api.g_varchar2,
  p_information4                 in varchar2         default hr_api.g_varchar2,
  p_information5                 in varchar2         default hr_api.g_varchar2,
  p_information6                 in varchar2         default hr_api.g_varchar2,
  p_information7                 in varchar2         default hr_api.g_varchar2,
  p_information8                 in varchar2         default hr_api.g_varchar2,
  p_information9                 in varchar2         default hr_api.g_varchar2,
  p_information10                in varchar2         default hr_api.g_varchar2,
  p_information11                in varchar2         default hr_api.g_varchar2,
  p_information12                in varchar2         default hr_api.g_varchar2,
  p_information13                in varchar2         default hr_api.g_varchar2,
  p_information14                in varchar2         default hr_api.g_varchar2,
  p_information15                in varchar2         default hr_api.g_varchar2,
  p_information16                in varchar2         default hr_api.g_varchar2,
  p_information17                in varchar2         default hr_api.g_varchar2,
  p_information18                in varchar2         default hr_api.g_varchar2,
  p_information19                in varchar2         default hr_api.g_varchar2,
  p_information20                in varchar2         default hr_api.g_varchar2,
  p_achieved_date                in date             default hr_api.g_date,
  p_appr_line_score              in number           default hr_api.g_number
  ) is
--
  l_rec	  per_cel_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  -- Call conversion function to turn arguments into the
  -- l_rec structure.
  --
  l_rec :=
  per_cel_shd.convert_args
  (
  p_competence_element_id,
  p_object_version_number,
  hr_api.g_varchar2,
  hr_api.g_number,
  hr_api.g_number,
  hr_api.g_number,
  p_proficiency_level_id,
  p_high_proficiency_level_id,
  p_weighting_level_id,
  p_rating_level_id,
  hr_api.g_number,
  hr_api.g_number,
  hr_api.g_number,
  hr_api.g_number,
  hr_api.g_number,
  hr_api.g_number,
  hr_api.g_number,
  hr_api.g_number,
  hr_api.g_number,
  p_mandatory,
  p_effective_date_from,
  p_effective_date_to,
  p_group_competence_type,
  p_competence_type,
  p_normal_elapse_duration,
  p_normal_elapse_duration_unit,
  p_sequence_number,
  p_source_of_proficiency_level,
  p_line_score,
  p_certification_date,
  p_certification_method,
  p_next_certification_date,
  p_comments,
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
  hr_api.g_number,
  hr_api.g_varchar2,
  p_party_id,  -- HR/TCA merge
  p_qualification_type_id,
  p_unit_standard_type,
  p_status,
  p_information_category,
  p_information1,
  p_information2,
  p_information3,
  p_information4,
  p_information5,
  p_information6,
  p_information7,
  p_information8,
  p_information9,
  p_information10,
  p_information11,
  p_information12,
  p_information13,
  p_information14,
  p_information15,
  p_information16,
  p_information17,
  p_information18,
  p_information19,
  p_information20,
  p_achieved_date,
  p_appr_line_score
  );
  --
  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.
  --
  upd(l_rec, p_validate,p_effective_date);
  p_object_version_number := l_rec.object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;
--
end per_cel_upd;

/
