--------------------------------------------------------
--  DDL for Package Body PER_APT_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_APT_UPD" as
/* $Header: peaptrhi.pkb 120.4.12010000.7 2010/02/09 15:06:58 psugumar ship $ */

-- ---------------------------------------------------------------------------+
-- |                     Private Global Definitions                           |
-- ---------------------------------------------------------------------------+

g_package  varchar2(33)	:= '  per_apt_upd.';  -- Global package name

-- ---------------------------------------------------------------------------+
-- |------------------------------< update_dml >------------------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}

-- Description:
--   This procedure controls the actual dml update logic. The processing of
--   this procedure is:
--   1) Increment the object_version_number by 1 if the object_version_number
--      is defined as an attribute for this entity.
--   2) To update the specified row in the schema using the primary key in
--      the predicates.
--   3) To trap any constraint violations that may have occurred.
--   4) To raise any other errors.

-- Pre Conditions:
--   This is an internal private procedure which must be called from the upd
--   procedure.

-- In Parameters:
--   A Pl/Sql record structre.

-- Post Success:
--   The specified row will be updated in the schema.

-- Post Failure:
--   If a check, unique or parent integrity constraint violation is raised the
--   constraint_error procedure will be called.

-- Developer Implementation Notes:
--   The update 'set' attribute list should be modified if any of your
--   attributes are not updateable.

-- Access Status:
--   Internal Table Handler Use Only.

-- {End Of Comments}
-- ---------------------------------------------------------------------------+
Procedure update_dml(p_rec in out nocopy per_apt_shd.g_rec_type) is

  l_proc  varchar2(72) := g_package||'update_dml';

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  -- Increment the object version

  p_rec.object_version_number := p_rec.object_version_number + 1;

  -- Update the per_appraisal_templates Row

  update per_appraisal_templates
  set
  appraisal_template_id             = p_rec.appraisal_template_id,
  object_version_number             = p_rec.object_version_number,
  name                              = p_rec.name,
  description                       = p_rec.description,
  instructions                      = p_rec.instructions,
  date_from                         = p_rec.date_from,
  date_to                           = p_rec.date_to,
  assessment_type_id                = p_rec.assessment_type_id,
  rating_scale_id                   = p_rec.rating_scale_id,
  questionnaire_template_id         = p_rec.questionnaire_template_id,
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
  objective_asmnt_type_id         = p_rec.objective_asmnt_type_id,
  ma_quest_template_id            = p_rec.ma_quest_template_id,
  link_appr_to_learning_path      = p_rec.link_appr_to_learning_path,
  final_score_formula_id          = p_rec.final_score_formula_id,
  update_personal_comp_profile    = p_rec.update_personal_comp_profile,
  comp_profile_source_type        = p_rec.comp_profile_source_type,
  show_competency_ratings         = p_rec.show_competency_ratings,
  show_objective_ratings          = p_rec.show_objective_ratings,
  show_overall_ratings            = p_rec.show_overall_ratings,
  show_overall_comments           = p_rec.show_overall_comments,
  provide_overall_feedback        = p_rec.provide_overall_feedback,
  show_participant_details        = p_rec.show_participant_details,
  allow_add_participant           = p_rec.allow_add_participant,
  show_additional_details         = p_rec.show_additional_details,
  show_participant_names          = p_rec.show_participant_names,
  show_participant_ratings        = p_rec.show_participant_ratings,
  available_flag                  = p_rec.available_flag,
  show_questionnaire_info        = p_rec.show_questionnaire_info,
  ma_off_template_code			     = p_rec.ma_off_template_code,
  appraisee_off_template_code		  =	p_rec.appraisee_off_template_code,
  other_part_off_template_code	  =	p_rec.other_part_off_template_code,
  part_app_off_template_code	  	=	p_rec.part_app_off_template_code,
  part_rev_off_template_code		  = p_rec.part_rev_off_template_code,
     show_participant_comments          = p_rec.show_participant_comments   -- 8651478 bug fix

,show_term_employee = p_rec.show_term_employee
,show_term_contigent =  p_rec.show_term_contigent
,disp_term_emp_period_from = p_rec.disp_term_emp_period_from
,show_future_term_employee = p_rec.show_future_term_employee

  where appraisal_template_id = p_rec.appraisal_template_id;

  hr_utility.set_location(' Leaving:'||l_proc, 10);

Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    per_apt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    per_apt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    per_apt_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    Raise;
End update_dml;

-- ---------------------------------------------------------------------------+
-- |------------------------------< pre_update >------------------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}

-- Description:
--   This private procedure contains any processing which is required before
--   the update dml.

-- Pre Conditions:
--   This is an internal procedure which is called from the upd procedure.

-- In Parameters:
--   A Pl/Sql record structre.

-- Post Success:
--   Processing continues.

-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.

-- Developer Implementation Notes:
--   Any pre-processing required before the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.

-- Access Status:
--   Internal Table Handler Use Only.

-- {End Of Comments}
-- ---------------------------------------------------------------------------+
Procedure pre_update(p_rec in per_apt_shd.g_rec_type) is

  l_proc  varchar2(72) := g_package||'pre_update';

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_update;

-- ---------------------------------------------------------------------------+
-- |-----------------------------< post_update >------------------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}

-- Description:
--   This private procedure contains any processing which is required after the
--   update dml.

-- Pre Conditions:
--   This is an internal procedure which is called from the upd procedure.

-- In Parameters:
--   A Pl/Sql record structre.

-- Post Success:
--   Processing continues.

-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.

-- Developer Implementation Notes:
--   Any post-processing required after the update dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.

-- Access Status:
--   Internal Table Handler Use Only.

-- {End Of Comments}
-- ---------------------------------------------------------------------------+
Procedure post_update(p_rec in per_apt_shd.g_rec_type) is

  l_proc  varchar2(72) := g_package||'post_update';

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  -- This is a hook point and the user hook for post_update is called here.

  begin
     per_apt_rku.after_update	(
       p_appraisal_template_id        => p_rec.appraisal_template_id  ,
       p_business_group_id            => p_rec.business_group_id      ,
       p_object_version_number        => p_rec.object_version_number  ,
       p_name                         => p_rec.name                   ,
       p_description                  => p_rec.description            ,
       p_instructions                 => p_rec.instructions           ,
       p_date_from                    => p_rec.date_from              ,
       p_date_to                      => p_rec.date_to                ,
       p_assessment_type_id           => p_rec.assessment_type_id        ,
       p_rating_scale_id              => p_rec.rating_scale_id           ,
       p_questionnaire_template_id    => p_rec.questionnaire_template_id ,
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
       p_objective_asmnt_type_id      => p_rec.objective_asmnt_type_id,
       p_ma_quest_template_id      => p_rec.ma_quest_template_id,
       p_link_appr_to_learning_path      => p_rec.link_appr_to_learning_path,
       p_final_score_formula_id      => p_rec.final_score_formula_id,
       p_update_personal_comp_profile      => p_rec.update_personal_comp_profile,
       p_comp_profile_source_type      => p_rec.comp_profile_source_type,
       p_show_competency_ratings      => p_rec.show_competency_ratings,
       p_show_objective_ratings      => p_rec.show_objective_ratings,
       p_show_overall_ratings      => p_rec.show_overall_ratings,
       p_show_overall_comments      => p_rec.show_overall_comments,
       p_provide_overall_feedback      => p_rec.provide_overall_feedback,
       p_show_participant_details      => p_rec.show_participant_details,
       p_allow_add_participant      => p_rec.allow_add_participant,
       p_show_additional_details      => p_rec.show_additional_details,
       p_show_participant_names      => p_rec.show_participant_names,
       p_show_participant_ratings      => p_rec.show_participant_ratings,
       p_available_flag      => p_rec.available_flag,
       p_show_questionnaire_info      => p_rec.show_questionnaire_info,
       p_ma_off_template_code			  => p_rec.ma_off_template_code,
       p_appraisee_off_template_code	  => p_rec.appraisee_off_template_code,
       p_other_part_off_template_code	  => p_rec.other_part_off_template_code,
       p_part_app_off_template_code	  => p_rec.part_app_off_template_code,
       p_part_rev_off_template_code	  => p_rec.part_rev_off_template_code,
      p_show_participant_comments     => p_rec.show_participant_comments, -- 8651478 bug fix

     p_show_term_employee           => p_rec.show_term_employee  -- 6181267 bug fix
    ,p_show_term_contigent          => p_rec.show_term_contigent   -- 6181267 bug fix
    ,p_disp_term_emp_period_from    => p_rec.disp_term_emp_period_from   -- 6181267 bug fix
    ,p_show_future_term_employee         => p_rec.show_future_term_employee, -- 6181267 bug fix

       p_business_group_id_o         => per_apt_shd.g_old_rec.business_group_id     ,
       p_object_version_number_o     => per_apt_shd.g_old_rec.object_version_number ,
       p_name_o                      => per_apt_shd.g_old_rec.name          ,
       p_description_o               => per_apt_shd.g_old_rec.description   ,
       p_instructions_o              => per_apt_shd.g_old_rec.instructions  ,
       p_date_from_o                 => per_apt_shd.g_old_rec.date_from     ,
       p_date_to_o                   => per_apt_shd.g_old_rec.date_to       ,
       p_assessment_type_id_o        => per_apt_shd.g_old_rec.assessment_type_id        ,
       p_rating_scale_id_o           => per_apt_shd.g_old_rec.rating_scale_id           ,
       p_questionnaire_template_id_o => per_apt_shd.g_old_rec.questionnaire_template_id ,
       p_attribute_category_o        => per_apt_shd.g_old_rec.attribute_category        ,
       p_attribute1_o                => per_apt_shd.g_old_rec.attribute1   ,
       p_attribute2_o                => per_apt_shd.g_old_rec.attribute2   ,
       p_attribute3_o                => per_apt_shd.g_old_rec.attribute3   ,
       p_attribute4_o                => per_apt_shd.g_old_rec.attribute4   ,
       p_attribute5_o                => per_apt_shd.g_old_rec.attribute5   ,
       p_attribute6_o                => per_apt_shd.g_old_rec.attribute6   ,
       p_attribute7_o                => per_apt_shd.g_old_rec.attribute7   ,
       p_attribute8_o                => per_apt_shd.g_old_rec.attribute8   ,
       p_attribute9_o                => per_apt_shd.g_old_rec.attribute9   ,
       p_attribute10_o               => per_apt_shd.g_old_rec.attribute10   ,
       p_attribute11_o               => per_apt_shd.g_old_rec.attribute11   ,
       p_attribute12_o               => per_apt_shd.g_old_rec.attribute12   ,
       p_attribute13_o               => per_apt_shd.g_old_rec.attribute13   ,
       p_attribute14_o               => per_apt_shd.g_old_rec.attribute14   ,
       p_attribute15_o               => per_apt_shd.g_old_rec.attribute15   ,
       p_attribute16_o               => per_apt_shd.g_old_rec.attribute16   ,
       p_attribute17_o               => per_apt_shd.g_old_rec.attribute17   ,
       p_attribute18_o               => per_apt_shd.g_old_rec.attribute18   ,
       p_attribute19_o               => per_apt_shd.g_old_rec.attribute19   ,
       p_attribute20_o               => per_apt_shd.g_old_rec.attribute20 ,
       p_objective_asmnt_type_id_o      => per_apt_shd.g_old_rec.objective_asmnt_type_id,
       p_ma_quest_template_id_o      => per_apt_shd.g_old_rec.ma_quest_template_id,
       p_link_appr_to_learning_path_o      => per_apt_shd.g_old_rec.link_appr_to_learning_path,
       p_final_score_formula_id_o      => per_apt_shd.g_old_rec.final_score_formula_id,
       p_update_personal_comp_profi_o      => per_apt_shd.g_old_rec.update_personal_comp_profile,
       p_comp_profile_source_type_o      => per_apt_shd.g_old_rec.comp_profile_source_type,
       p_show_competency_ratings_o      => per_apt_shd.g_old_rec.show_competency_ratings,
       p_show_objective_ratings_o      => per_apt_shd.g_old_rec.show_objective_ratings,
       p_show_overall_ratings_o      => per_apt_shd.g_old_rec.show_overall_ratings,
       p_show_overall_comments_o      => per_apt_shd.g_old_rec.show_overall_comments,
       p_provide_overall_feedback_o      => per_apt_shd.g_old_rec.provide_overall_feedback,
       p_show_participant_details_o      => per_apt_shd.g_old_rec.show_participant_details,
       p_allow_add_participant_o      => per_apt_shd.g_old_rec.allow_add_participant,
       p_show_additional_details_o      => per_apt_shd.g_old_rec.show_additional_details,
       p_show_participant_names_o      => per_apt_shd.g_old_rec.show_participant_names,
       p_show_participant_ratings_o      => per_apt_shd.g_old_rec.show_participant_ratings,
       p_available_flag_o      => per_apt_shd.g_old_rec.available_flag,
       p_show_questionnaire_info_o => per_apt_shd.g_old_rec.show_questionnaire_info,
       p_ma_off_template_cd_o			  => per_apt_shd.g_old_rec.ma_off_template_code,
       p_appraisee_off_template_cd_o	  => per_apt_shd.g_old_rec.appraisee_off_template_code,
       p_other_part_off_template_cd_o	  => per_apt_shd.g_old_rec.other_part_off_template_code,
       p_part_app_off_template_cd_o	  	  => per_apt_shd.g_old_rec.part_app_off_template_code,
       p_part_rev_off_template_cd_o	  	  => per_apt_shd.g_old_rec.part_rev_off_template_code,
            p_show_participant_comments_o      => per_apt_shd.g_old_rec.show_participant_comments  -- 8651478 bug fix

    ,p_show_term_employee_o           => per_apt_shd.g_old_rec.show_term_employee  -- 6181267 bug fix
    ,p_show_term_contigent_o          => per_apt_shd.g_old_rec.show_term_contigent   -- 6181267 bug fix
    ,p_disp_term_emp_period_from_o    => per_apt_shd.g_old_rec.disp_term_emp_period_from   -- 6181267 bug fix
    ,p_show_future_term_employee_o         => per_apt_shd.g_old_rec.show_future_term_employee -- 6181267 bug fix

       );

     exception
        when hr_api.cannot_find_prog_unit then
             hr_api.cannot_find_prog_unit_error
		 (	p_module_name => 'PER_APPRAISAL_TEMPLATES'
		 	,p_hook_type  => 'AU'
	        );
  end;
  -- End of API User Hook for post_update

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_update;

-- ---------------------------------------------------------------------------+
-- |-----------------------------< convert_defs >-----------------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}

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

-- Pre Conditions:
--   This private function can only be called from the upd process.

-- In Parameters:
--   A Pl/Sql record structre.

-- Post Success:
--   The record structure will be returned with all system defaulted parameter
--   values converted into its current row attribute value.

-- Post Failure:
--   No direct error handling is required within this function. Any possible
--   errors within this procedure will be a PL/SQL value error due to conversion

--   of datatypes or data lengths.

-- Developer Implementation Notes:
--   None.

-- Access Status:
--   Internal Table Handler Use Only.

-- {End Of Comments}
-- ---------------------------------------------------------------------------+
Procedure convert_defs(p_rec in out nocopy per_apt_shd.g_rec_type) is

  l_proc  varchar2(72) := g_package||'convert_defs';

Begin

  hr_utility.set_location('Entering:'||l_proc, 5);

  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.

  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    per_apt_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.name = hr_api.g_varchar2) then
    p_rec.name :=
    per_apt_shd.g_old_rec.name;
  End If;
  If (p_rec.description = hr_api.g_varchar2) then
    p_rec.description :=
    per_apt_shd.g_old_rec.description;
  End If;
  If (p_rec.instructions = hr_api.g_varchar2) then
    p_rec.instructions :=
    per_apt_shd.g_old_rec.instructions;
  End If;
  If (p_rec.date_from = hr_api.g_date) then
    p_rec.date_from :=
    per_apt_shd.g_old_rec.date_from;
  End If;
  If (p_rec.date_to = hr_api.g_date) then
    p_rec.date_to :=
    per_apt_shd.g_old_rec.date_to;
  End If;
  If (p_rec.assessment_type_id = hr_api.g_number) then
    p_rec.assessment_type_id :=
    per_apt_shd.g_old_rec.assessment_type_id;
  End If;
  If (p_rec.rating_scale_id = hr_api.g_number) then
    p_rec.rating_scale_id :=
    per_apt_shd.g_old_rec.rating_scale_id;
  End If;
  If (p_rec.questionnaire_template_id = hr_api.g_number) then
    p_rec.questionnaire_template_id :=
    per_apt_shd.g_old_rec.questionnaire_template_id;
  End If;
  If (p_rec.attribute_category = hr_api.g_varchar2) then
    p_rec.attribute_category :=
    per_apt_shd.g_old_rec.attribute_category;
  End If;
  If (p_rec.attribute1 = hr_api.g_varchar2) then
    p_rec.attribute1 :=
    per_apt_shd.g_old_rec.attribute1;
  End If;
  If (p_rec.attribute2 = hr_api.g_varchar2) then
    p_rec.attribute2 :=
    per_apt_shd.g_old_rec.attribute2;
  End If;
  If (p_rec.attribute3 = hr_api.g_varchar2) then
    p_rec.attribute3 :=
    per_apt_shd.g_old_rec.attribute3;
  End If;
  If (p_rec.attribute4 = hr_api.g_varchar2) then
    p_rec.attribute4 :=
    per_apt_shd.g_old_rec.attribute4;
  End If;
  If (p_rec.attribute5 = hr_api.g_varchar2) then
    p_rec.attribute5 :=
    per_apt_shd.g_old_rec.attribute5;
  End If;
  If (p_rec.attribute6 = hr_api.g_varchar2) then
    p_rec.attribute6 :=
    per_apt_shd.g_old_rec.attribute6;
  End If;
  If (p_rec.attribute7 = hr_api.g_varchar2) then
    p_rec.attribute7 :=
    per_apt_shd.g_old_rec.attribute7;
  End If;
  If (p_rec.attribute8 = hr_api.g_varchar2) then
    p_rec.attribute8 :=
    per_apt_shd.g_old_rec.attribute8;
  End If;
  If (p_rec.attribute9 = hr_api.g_varchar2) then
    p_rec.attribute9 :=
    per_apt_shd.g_old_rec.attribute9;
  End If;
  If (p_rec.attribute10 = hr_api.g_varchar2) then
    p_rec.attribute10 :=
    per_apt_shd.g_old_rec.attribute10;
  End If;
  If (p_rec.attribute11 = hr_api.g_varchar2) then
    p_rec.attribute11 :=
    per_apt_shd.g_old_rec.attribute11;
  End If;
  If (p_rec.attribute12 = hr_api.g_varchar2) then
    p_rec.attribute12 :=
    per_apt_shd.g_old_rec.attribute12;
  End If;
  If (p_rec.attribute13 = hr_api.g_varchar2) then
    p_rec.attribute13 :=
    per_apt_shd.g_old_rec.attribute13;
  End If;
  If (p_rec.attribute14 = hr_api.g_varchar2) then
    p_rec.attribute14 :=
    per_apt_shd.g_old_rec.attribute14;
  End If;
  If (p_rec.attribute15 = hr_api.g_varchar2) then
    p_rec.attribute15 :=
    per_apt_shd.g_old_rec.attribute15;
  End If;
  If (p_rec.attribute16 = hr_api.g_varchar2) then
    p_rec.attribute16 :=
    per_apt_shd.g_old_rec.attribute16;
  End If;
  If (p_rec.attribute17 = hr_api.g_varchar2) then
    p_rec.attribute17 :=
    per_apt_shd.g_old_rec.attribute17;
  End If;
  If (p_rec.attribute18 = hr_api.g_varchar2) then
    p_rec.attribute18 :=
    per_apt_shd.g_old_rec.attribute18;
  End If;
  If (p_rec.attribute19 = hr_api.g_varchar2) then
    p_rec.attribute19 :=
    per_apt_shd.g_old_rec.attribute19;
  End If;
  If (p_rec.attribute20 = hr_api.g_varchar2) then
    p_rec.attribute20 :=
    per_apt_shd.g_old_rec.attribute20;
  End If;
   If (p_rec.objective_asmnt_type_id = hr_api.g_number) then
    p_rec.objective_asmnt_type_id :=
    per_apt_shd.g_old_rec.objective_asmnt_type_id;
  End If;
  If (p_rec.ma_quest_template_id = hr_api.g_number) then
    p_rec.ma_quest_template_id :=
    per_apt_shd.g_old_rec.ma_quest_template_id;
  End If;
  If (p_rec.link_appr_to_learning_path = hr_api.g_varchar2) then
    p_rec.link_appr_to_learning_path :=
    per_apt_shd.g_old_rec.link_appr_to_learning_path;
  End If;
  If (p_rec.final_score_formula_id = hr_api.g_number) then
    p_rec.final_score_formula_id :=
    per_apt_shd.g_old_rec.final_score_formula_id;
  End If;
  If (p_rec.update_personal_comp_profile = hr_api.g_varchar2) then
    p_rec.update_personal_comp_profile :=
    per_apt_shd.g_old_rec.update_personal_comp_profile;
  End If;
  If (p_rec.comp_profile_source_type = hr_api.g_varchar2) then
    p_rec.comp_profile_source_type :=
    per_apt_shd.g_old_rec.comp_profile_source_type;
  End If;
  If (p_rec.show_competency_ratings = hr_api.g_varchar2) then
    p_rec.show_competency_ratings :=
    per_apt_shd.g_old_rec.show_competency_ratings;
  End If;
  If (p_rec.show_objective_ratings = hr_api.g_varchar2) then
    p_rec.show_objective_ratings :=
    per_apt_shd.g_old_rec.show_objective_ratings;
  End If;
  If (p_rec.show_overall_ratings = hr_api.g_varchar2) then
    p_rec.show_overall_ratings :=
    per_apt_shd.g_old_rec.show_overall_ratings;
  End If;
  If (p_rec.show_overall_comments = hr_api.g_varchar2) then
    p_rec.show_overall_comments :=
    per_apt_shd.g_old_rec.show_overall_comments;
  End If;
  If (p_rec.provide_overall_feedback = hr_api.g_varchar2) then
    p_rec.provide_overall_feedback :=
    per_apt_shd.g_old_rec.provide_overall_feedback;
  End If;
  If (p_rec.show_participant_details = hr_api.g_varchar2) then
    p_rec.show_participant_details :=
    per_apt_shd.g_old_rec.show_participant_details;
  End If;
  If (p_rec.allow_add_participant = hr_api.g_varchar2) then
    p_rec.allow_add_participant :=
    per_apt_shd.g_old_rec.allow_add_participant;
  End If;
  If (p_rec.show_additional_details = hr_api.g_varchar2) then
    p_rec.show_additional_details :=
    per_apt_shd.g_old_rec.show_additional_details;
  End If;
  If (p_rec.show_participant_names = hr_api.g_varchar2) then
    p_rec.show_participant_names :=
    per_apt_shd.g_old_rec.show_participant_names;
  End If;
  If (p_rec.show_participant_ratings = hr_api.g_varchar2) then
    p_rec.show_participant_ratings :=
    per_apt_shd.g_old_rec.show_participant_ratings;
  End If;
  If (p_rec.available_flag = hr_api.g_varchar2) then
    p_rec.available_flag :=
    per_apt_shd.g_old_rec.available_flag;
  End If;
  If (p_rec.show_questionnaire_info = hr_api.g_varchar2) then
    p_rec.show_questionnaire_info :=
    per_apt_shd.g_old_rec.show_questionnaire_info;
  End If;
  If (p_rec.ma_off_template_code =hr_api.g_varchar2) then
  	 p_rec.ma_off_template_code :=
  	 per_apt_shd.g_old_rec.ma_off_template_code;
  End If;
  If (p_rec.appraisee_off_template_code =hr_api.g_varchar2) then
  	 p_rec.appraisee_off_template_code :=
  	 per_apt_shd.g_old_rec.appraisee_off_template_code;
  End If;
  If (p_rec.other_part_off_template_code =hr_api.g_varchar2) then
  	 p_rec.other_part_off_template_code :=
  	 per_apt_shd.g_old_rec.other_part_off_template_code;
  End If;
  If (p_rec.part_rev_off_template_code =hr_api.g_varchar2) then
  	 p_rec.part_rev_off_template_code :=
  	 per_apt_shd.g_old_rec.part_rev_off_template_code;
  End If;
  If (p_rec.part_app_off_template_code  =hr_api.g_varchar2) then
  	 p_rec.part_app_off_template_code  :=
  	 per_apt_shd.g_old_rec.part_app_off_template_code ;
  End If;

-- 8651478 bug fix
If (p_rec.show_participant_comments = hr_api.g_varchar2) then
    p_rec.show_participant_comments :=
    per_apt_shd.g_old_rec.show_participant_comments;
  End If;


If (p_rec.show_term_employee = hr_api.g_varchar2) then
    p_rec.show_term_employee :=
    per_apt_shd.g_old_rec.show_term_employee;
  End If;

If (p_rec.show_term_contigent = hr_api.g_varchar2) then
    p_rec.show_term_contigent :=
    per_apt_shd.g_old_rec.show_term_contigent;
  End If;

If (p_rec.disp_term_emp_period_from = hr_api.g_number) then
    p_rec.disp_term_emp_period_from :=
    per_apt_shd.g_old_rec.disp_term_emp_period_from;
  End If;

If (p_rec.show_future_term_employee = hr_api.g_varchar2) then
    p_rec.show_future_term_employee :=
    per_apt_shd.g_old_rec.show_future_term_employee;
  End If;


  hr_utility.set_location(' Leaving:'||l_proc, 10);

End convert_defs;

-- ---------------------------------------------------------------------------+
-- |---------------------------------< upd >----------------------------------|
-- ---------------------------------------------------------------------------+
Procedure upd
  (
  p_rec        		in out nocopy per_apt_shd.g_rec_type,
  p_effective_date	in date,
  p_validate   		in     boolean default false
  ) is

  l_proc  varchar2(72) := g_package||'upd';

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  -- Determine if the business process is to be validated.

  If p_validate then

    -- Issue the savepoint.

    SAVEPOINT upd_per_apt;
  End If;

  -- We must lock the row which we need to update.

  per_apt_shd.lck
	(
	p_rec.appraisal_template_id,
	p_rec.object_version_number
	);

  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.

  -- 2. Call the supporting update validate operations.

  convert_defs(p_rec);
  per_apt_bus.update_validate(p_rec,p_effective_date);

  -- Call the supporting pre-update operation

  pre_update(p_rec);

  -- Update the row.

  update_dml(p_rec);

  -- Call the supporting post-update operation

  post_update(p_rec);

  -- If we are validating then raise the Validate_Enabled exception

  If p_validate then
    Raise HR_Api.Validate_Enabled;
  End If;

  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When HR_Api.Validate_Enabled Then

    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint

    ROLLBACK TO upd_per_apt;
End upd;

-- ---------------------------------------------------------------------------+
-- |---------------------------------< upd >----------------------------------|
-- ---------------------------------------------------------------------------+
Procedure upd
  (
  p_appraisal_template_id        in number,
  p_object_version_number        in out nocopy number,
  p_name                         in varchar2         default hr_api.g_varchar2,
  p_description                  in varchar2         default hr_api.g_varchar2,
  p_instructions                 in varchar2         default hr_api.g_varchar2,
  p_date_from                    in date             default hr_api.g_date,
  p_date_to                      in date             default hr_api.g_date,
  p_assessment_type_id           in number           default hr_api.g_number,
  p_rating_scale_id              in number           default hr_api.g_number,
  p_questionnaire_template_id    in number           default hr_api.g_number,
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
  p_objective_asmnt_type_id      in     number    default hr_api.g_number,
  p_ma_quest_template_id         in     number    default hr_api.g_number,
  p_link_appr_to_learning_path   in     varchar2  default hr_api.g_varchar2,
  p_final_score_formula_id       in     number    default hr_api.g_number,
  p_update_personal_comp_profile in     varchar2  default hr_api.g_varchar2,
  p_comp_profile_source_type     in     varchar2  default hr_api.g_varchar2,
  p_show_competency_ratings      in     varchar2  default hr_api.g_varchar2,
  p_show_objective_ratings       in     varchar2  default hr_api.g_varchar2,
  p_show_overall_ratings         in     varchar2  default hr_api.g_varchar2,
  p_show_overall_comments        in     varchar2  default hr_api.g_varchar2,
  p_provide_overall_feedback     in     varchar2  default hr_api.g_varchar2,
  p_show_participant_details     in     varchar2  default hr_api.g_varchar2,
  p_allow_add_participant        in     varchar2  default hr_api.g_varchar2,
  p_show_additional_details      in     varchar2  default hr_api.g_varchar2,
  p_show_participant_names       in     varchar2  default hr_api.g_varchar2,
  p_show_participant_ratings     in     varchar2  default hr_api.g_varchar2,
  p_available_flag               in     varchar2  default hr_api.g_varchar2,
  p_show_questionnaire_info     in     varchar2  default hr_api.g_varchar2,
  p_effective_date		 in date
  ,p_ma_off_template_code			   in varchar2 	  default hr_api.g_varchar2
  ,p_appraisee_off_template_code	in varchar2		  default hr_api.g_varchar2
  ,p_other_part_off_template_code	 in varchar2		  default hr_api.g_varchar2
  ,p_part_app_off_template_code	  in varchar2		  default hr_api.g_varchar2
  ,p_part_rev_off_template_code	  in varchar2		  default hr_api.g_varchar2,
  p_validate                     in boolean      default false ,
p_show_participant_comments     in varchar2         default hr_api.g_varchar2  -- 8651478 bug fix
  ,p_show_term_employee            in varchar2            default hr_api.g_varchar2  -- 6181267 bug fix
  ,p_show_term_contigent           in varchar2            default hr_api.g_varchar2  -- 6181267 bug fix
  ,p_disp_term_emp_period_from     in     number            default hr_api.g_number  -- 6181267 bug fix
  ,p_show_future_term_employee          in varchar2            default hr_api.g_varchar2  -- 6181267 bug fix
  ) is

  l_rec	  per_apt_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  -- Call conversion function to turn arguments into the
  -- l_rec structure.

  l_rec :=
  per_apt_shd.convert_args
  (
  p_appraisal_template_id,
  hr_api.g_number,
  p_object_version_number,
  p_name,
  p_description,
  p_instructions,
  p_date_from,
  p_date_to,
  p_assessment_type_id,
  p_rating_scale_id,
  p_questionnaire_template_id,
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
  p_objective_asmnt_type_id,
  p_ma_quest_template_id,
  p_link_appr_to_learning_path,
  p_final_score_formula_id,
  p_update_personal_comp_profile,
  p_comp_profile_source_type,
  p_show_competency_ratings,
  p_show_objective_ratings,
  p_show_overall_ratings,
  p_show_overall_comments,
  p_provide_overall_feedback,
  p_show_participant_details,
  p_allow_add_participant,
  p_show_additional_details,
  p_show_participant_names,
  p_show_participant_ratings,
  p_available_flag,
  p_show_questionnaire_info,
  p_ma_off_template_code,
  p_appraisee_off_template_code,
  p_other_part_off_template_code,
  p_part_app_off_template_code,
  p_part_rev_off_template_code,
  p_show_participant_comments    -- 8651478 bug fix
  ,p_show_term_employee
  ,p_show_term_contigent
  ,p_disp_term_emp_period_from
  ,p_show_future_term_employee

  );

  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.

  upd(l_rec, p_effective_date,p_validate);

  if not p_validate then
    p_object_version_number := l_rec.object_version_number;
  end if;

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;

end per_apt_upd;

/
