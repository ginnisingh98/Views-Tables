--------------------------------------------------------
--  DDL for Package Body PER_APR_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_APR_UPD" as
/* $Header: peaprrhi.pkb 120.8.12010000.18 2010/05/25 12:18:15 psugumar ship $ */

-- ---------------------------------------------------------------------------+
-- |                     Private Global Definitions                           |
-- ---------------------------------------------------------------------------+

g_package  varchar2(33)	:= '  per_apr_upd.';  -- Global package name

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
Procedure update_dml(p_rec in out nocopy per_apr_shd.g_rec_type) is

  l_proc  varchar2(72) := g_package||'update_dml';

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  -- Increment the object version

  p_rec.object_version_number := p_rec.object_version_number + 1;


  -- Update the per_appraisals Row

  update per_appraisals
  set
  appraisal_id                      = p_rec.appraisal_id,
  object_version_number             = p_rec.object_version_number,
  appraisal_period_end_date         = p_rec.appraisal_period_end_date,
  appraisal_period_start_date       = p_rec.appraisal_period_start_date,
  appraiser_person_id               = p_rec.appraiser_person_id,
  appraisal_date                    = p_rec.appraisal_date,
  type                              = p_rec.type,
  next_appraisal_date               = p_rec.next_appraisal_date,
  status                            = p_rec.status,
  comments                          = p_rec.comments,
  overall_performance_level_id      = p_rec.overall_performance_level_id,
  open                              = p_rec.open,
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
  system_type                       = p_rec.system_type,
  system_params                     = p_rec.system_params,
  appraisee_access                  = p_rec.appraisee_access,
  main_appraiser_id                 = p_rec.main_appraiser_id,
  assignment_id                     = p_rec.assignment_id,
  assignment_start_date             = p_rec.assignment_start_date,
  assignment_business_group_id      = p_rec.assignment_business_group_id,
  assignment_organization_id        = p_rec.assignment_organization_id,
  assignment_job_id                 = p_rec.assignment_job_id,
  assignment_position_id            = p_rec.assignment_position_id,
  assignment_grade_id               = p_rec.assignment_grade_id,
  appraisal_system_status           = p_rec.appraisal_system_status,
  potential_readiness_level         = p_rec.potential_readiness_level,
  potential_short_term_workopp      = p_rec.potential_short_term_workopp,
  potential_long_term_workopp       = p_rec.potential_long_term_workopp,
  potential_details                 = p_rec.potential_details,
  event_id    		                = p_rec.event_id,
  show_competency_ratings           = p_rec.show_competency_ratings,
  show_objective_ratings            = p_rec.show_objective_ratings,
  show_questionnaire_info           = p_rec.show_questionnaire_info,
  show_participant_details          = p_rec.show_participant_details,
  show_participant_ratings          = p_rec.show_participant_ratings,
  show_participant_names            = p_rec.show_participant_names,
  show_overall_ratings              = p_rec.show_overall_ratings,
  show_overall_comments             = p_rec.show_overall_comments,
  update_appraisal                  = p_rec.update_appraisal,
  provide_overall_feedback          = p_rec.provide_overall_feedback,
  appraisee_comments                = p_rec.appraisee_comments,
  plan_id                           = p_rec.plan_id,
  offline_status                    = p_rec.offline_status,
  retention_potential                    = p_rec.retention_potential,
  show_participant_comments          = p_rec.show_participant_comments   -- 8651478 bug fix
  where appraisal_id = p_rec.appraisal_id;

  hr_utility.set_location(' Leaving:'||l_proc, 10);

Exception
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    per_apr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    per_apr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    per_apr_shd.constraint_error
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
Procedure pre_update(p_rec in per_apr_shd.g_rec_type) is

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
Procedure post_update(p_rec in per_apr_shd.g_rec_type) is

  l_proc  varchar2(72) := g_package||'post_update';

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  -- This is a hook point and the user hook for post_update is called here.

  begin
     per_apr_rku.after_update	(
            p_appraisal_id                   => p_rec.appraisal_id                          ,
            p_business_group_id              => p_rec.business_group_id                     ,
            p_appraisal_template_id          => p_rec.appraisal_template_id                 ,
            p_appraisee_person_id            => p_rec.appraisee_person_id                   ,
            p_appraiser_person_id            => p_rec.appraiser_person_id                   ,
            p_appraisal_date                 => p_rec.appraisal_date                        ,
            p_group_date                     => p_rec.group_date                            ,
            p_group_initiator_id             => p_rec.group_initiator_id                    ,
            p_appraisal_period_end_date      => p_rec.appraisal_period_end_date             ,
            p_appraisal_period_start_date    => p_rec.appraisal_period_start_date           ,
            p_type                           => p_rec.type                                  ,
            p_next_appraisal_date            => p_rec.next_appraisal_date                   ,
            p_status                         => p_rec.status                                ,
            p_comments                       => p_rec.comments                              ,
            p_overall_performance_level_id   => p_rec.overall_performance_level_id          ,
            p_open                           => p_rec.open                                  ,
            p_attribute_category             => p_rec.attribute_category                    ,
            p_attribute1                     => p_rec.attribute1                            ,
            p_attribute2                     => p_rec.attribute2                            ,
            p_attribute3                     => p_rec.attribute3                            ,
            p_attribute4                     => p_rec.attribute4                            ,
            p_attribute5                     => p_rec.attribute5                            ,
            p_attribute6                     => p_rec.attribute6                            ,
            p_attribute7                     => p_rec.attribute7                            ,
            p_attribute8                     => p_rec.attribute8                            ,
            p_attribute9                     => p_rec.attribute9                            ,
            p_attribute10                    => p_rec.attribute10                           ,
            p_attribute11                    => p_rec.attribute11                           ,
            p_attribute12                    => p_rec.attribute12                           ,
            p_attribute13                    => p_rec.attribute13                           ,
            p_attribute14                    => p_rec.attribute14                           ,
            p_attribute15                    => p_rec.attribute15                           ,
            p_attribute16                    => p_rec.attribute16                           ,
            p_attribute17                    => p_rec.attribute17                           ,
            p_attribute18                    => p_rec.attribute18                           ,
            p_attribute19                    => p_rec.attribute19                           ,
            p_attribute20                    => p_rec.attribute20                           ,
            p_object_version_number          => p_rec.object_version_number                 ,
            p_system_type                    => p_rec.system_type                           ,
            p_system_params                  => p_rec.system_params,
            p_appraisee_access               => p_rec.appraisee_access                      ,
            p_main_appraiser_id              => p_rec.main_appraiser_id                     ,
            p_assignment_id                  => p_rec.assignment_id                         ,
            p_assignment_start_date          => p_rec.assignment_start_date                 ,
            p_asg_business_group_id          => p_rec.assignment_business_group_id          ,
	    p_assignment_organization_id     => p_rec.assignment_organization_id            ,
	    p_assignment_job_id              => p_rec.assignment_job_id                     ,
	    p_assignment_position_id         => p_rec.assignment_position_id                ,
            p_assignment_grade_id            => p_rec.assignment_grade_id                   ,
            p_appraisal_system_status        => p_rec.appraisal_system_status,
            p_potential_readiness_level      => p_rec.potential_readiness_level,
	    p_potential_short_term_workopp     => p_rec.potential_short_term_workopp,
	    p_potential_long_term_workopp      => p_rec.potential_long_term_workopp,
	    p_potential_details              => p_rec.potential_details,
  	    p_event_id    		     => p_rec.event_id,
            p_offline_status                 => p_rec.offline_status,
           p_retention_potential        => p_rec.retention_potential,
            p_business_group_id_o            => per_apr_shd.g_old_rec.business_group_id     ,
            p_appraisal_template_id_o        => per_apr_shd.g_old_rec.appraisal_template_id ,
            p_appraisee_person_id_o          => per_apr_shd.g_old_rec.appraisee_person_id   ,
            p_appraiser_person_id_o          => per_apr_shd.g_old_rec.appraiser_person_id   ,
            p_appraisal_date_o               => per_apr_shd.g_old_rec.appraisal_date        ,
            p_group_date_o                   => per_apr_shd.g_old_rec.group_date            ,
            p_group_initiator_id_o           => per_apr_shd.g_old_rec.group_initiator_id    ,
            p_appraisal_period_end_date_o    => per_apr_shd.g_old_rec.appraisal_period_end_date  ,
            p_appraisal_period_start_dat_o   => per_apr_shd.g_old_rec.appraisal_period_start_date,
            p_type_o                         => per_apr_shd.g_old_rec.type                  ,
            p_next_appraisal_date_o          => per_apr_shd.g_old_rec.next_appraisal_date   ,
            p_status_o                       => per_apr_shd.g_old_rec.status                ,
            p_comments_o                     => per_apr_shd.g_old_rec.comments              ,
            p_overall_performance_level_o    => per_apr_shd.g_old_rec.overall_performance_level_id,
            p_open_o                         => per_apr_shd.g_old_rec.open                  ,
            p_attribute_category_o           => per_apr_shd.g_old_rec.attribute_category          ,
            p_attribute1_o                   => per_apr_shd.g_old_rec.attribute1            ,
            p_attribute2_o                   => per_apr_shd.g_old_rec.attribute2            ,
            p_attribute3_o                   => per_apr_shd.g_old_rec.attribute3            ,
            p_attribute4_o                   => per_apr_shd.g_old_rec.attribute4            ,
            p_attribute5_o                   => per_apr_shd.g_old_rec.attribute5            ,
            p_attribute6_o                   => per_apr_shd.g_old_rec.attribute6            ,
            p_attribute7_o                   => per_apr_shd.g_old_rec.attribute7            ,
            p_attribute8_o                   => per_apr_shd.g_old_rec.attribute8            ,
            p_attribute9_o                   => per_apr_shd.g_old_rec.attribute9            ,
            p_attribute10_o                  => per_apr_shd.g_old_rec.attribute10           ,
            p_attribute11_o                  => per_apr_shd.g_old_rec.attribute11           ,
            p_attribute12_o                  => per_apr_shd.g_old_rec.attribute12          ,
            p_attribute13_o                  => per_apr_shd.g_old_rec.attribute13          ,
            p_attribute14_o                  => per_apr_shd.g_old_rec.attribute14          ,
            p_attribute15_o                  => per_apr_shd.g_old_rec.attribute15          ,
            p_attribute16_o                  => per_apr_shd.g_old_rec.attribute16          ,
            p_attribute17_o                  => per_apr_shd.g_old_rec.attribute17          ,
            p_attribute18_o                  => per_apr_shd.g_old_rec.attribute18          ,
            p_attribute19_o                  => per_apr_shd.g_old_rec.attribute19          ,
            p_attribute20_o                  => per_apr_shd.g_old_rec.attribute20          ,
            p_object_version_number_o        => per_apr_shd.g_old_rec.object_version_number,
            p_system_type_o                  => per_apr_shd.g_old_rec.system_type          ,
            p_system_params_o                => per_apr_shd.g_old_rec.system_params,
            p_appraisee_access_o             => per_apr_shd.g_old_rec.appraisee_access     ,
            p_main_appraiser_id_o            => per_apr_shd.g_old_rec.main_appraiser_id    ,
            p_assignment_id_o                => per_apr_shd.g_old_rec.assignment_id        ,
            p_assignment_start_date_o        => per_apr_shd.g_old_rec.assignment_start_date,
            p_asg_business_group_id_o        => per_apr_shd.g_old_rec.assignment_business_group_id,
	    p_assignment_organization_id_o   => per_apr_shd.g_old_rec.assignment_organization_id,
	    p_assignment_job_id_o            => per_apr_shd.g_old_rec.assignment_job_id  ,
	    p_assignment_position_id_o       => per_apr_shd.g_old_rec.assignment_position_id,
            p_assignment_grade_id_o          => per_apr_shd.g_old_rec.assignment_grade_id ,
            p_appraisal_system_status_o      => per_apr_shd.g_old_rec.appraisal_system_status,
            p_potential_readiness_level_o    => per_apr_shd.g_old_rec.potential_readiness_level,
	    p_potnl_short_term_workopp_o     => per_apr_shd.g_old_rec.potential_short_term_workopp,
	    p_potnl_long_term_workopp_o      => per_apr_shd.g_old_rec.potential_long_term_workopp,
	    p_potential_details_o            => per_apr_shd.g_old_rec.potential_details,
  	    p_event_id_o    		         => per_apr_shd.g_old_rec.event_id,
            p_show_competency_ratings_o      => per_apr_shd.g_old_rec.show_competency_ratings,
            p_show_objective_ratings_o       => per_apr_shd.g_old_rec.show_objective_ratings,
            p_show_questionnaire_info_o      => per_apr_shd.g_old_rec.show_questionnaire_info,
            p_show_participant_details_o     => per_apr_shd.g_old_rec.show_participant_details,
            p_show_participant_ratings_o     => per_apr_shd.g_old_rec.show_participant_ratings,
            p_show_participant_names_o       => per_apr_shd.g_old_rec.show_participant_names,
            p_show_overall_ratings_o         => per_apr_shd.g_old_rec.show_overall_ratings,
            p_show_overall_comments_o        => per_apr_shd.g_old_rec.show_overall_comments,
            p_update_appraisal_o             => per_apr_shd.g_old_rec.update_appraisal,
            p_provide_overall_feedback_o     => per_apr_shd.g_old_rec.provide_overall_feedback,
            p_appraisee_comments_o           => per_apr_shd.g_old_rec.appraisee_comments,
            p_plan_id_o                      => per_apr_shd.g_old_rec.plan_id,
            p_offline_status_o               => per_apr_shd.g_old_rec.offline_status,
            p_retention_potential_o        => per_apr_shd.g_old_rec.retention_potential,
             p_show_participant_comments_o     => per_apr_shd.g_old_rec.show_participant_comments   -- 8651478 bug fix
            );
     exception
        when hr_api.cannot_find_prog_unit then
             hr_api.cannot_find_prog_unit_error
		 (	p_module_name => 'PER_APPRAISALS'
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
Procedure convert_defs(p_rec in out nocopy per_apr_shd.g_rec_type) is

  l_proc  varchar2(72) := g_package||'convert_defs';

Begin

  hr_utility.set_location('Entering:'||l_proc, 5);

  -- We must now examine each argument value in the
  -- p_rec plsql record structure
  -- to see if a system default is being used. If a system default
  -- is being used then we must set to the 'current' argument value.

  If (p_rec.business_group_id = hr_api.g_number) then
    p_rec.business_group_id :=
    per_apr_shd.g_old_rec.business_group_id;
  End If;
  If (p_rec.appraisal_template_id = hr_api.g_number) then
    p_rec.appraisal_template_id :=
    per_apr_shd.g_old_rec.appraisal_template_id;
  End If;
  If (p_rec.appraisee_person_id = hr_api.g_number) then
    p_rec.appraisee_person_id :=
    per_apr_shd.g_old_rec.appraisee_person_id;
  End If;
  If (p_rec.appraiser_person_id = hr_api.g_number) then
    p_rec.appraiser_person_id :=
    per_apr_shd.g_old_rec.appraiser_person_id;
  End If;
  If (p_rec.appraisal_date = hr_api.g_date) then
    p_rec.appraisal_date :=
    per_apr_shd.g_old_rec.appraisal_date;
  End If;
  If (p_rec.appraisal_period_end_date = hr_api.g_date) then
    p_rec.appraisal_period_end_date :=
    per_apr_shd.g_old_rec.appraisal_period_end_date;
  End If;
  If (p_rec.appraisal_period_start_date = hr_api.g_date) then
    p_rec.appraisal_period_start_date :=
    per_apr_shd.g_old_rec.appraisal_period_start_date;
  End If;
  If (p_rec.type = hr_api.g_varchar2) then
    p_rec.type :=
    per_apr_shd.g_old_rec.type;
  End If;
  If (p_rec.next_appraisal_date = hr_api.g_date) then
    p_rec.next_appraisal_date :=
    per_apr_shd.g_old_rec.next_appraisal_date;
  End If;
  If (p_rec.status = hr_api.g_varchar2) then
    p_rec.status :=
    per_apr_shd.g_old_rec.status;
  End If;
  If (p_rec.comments = hr_api.g_varchar2) then
    p_rec.comments :=
    per_apr_shd.g_old_rec.comments;
  End If;
  If (p_rec.overall_performance_level_id = hr_api.g_number) then
    p_rec.overall_performance_level_id :=
    per_apr_shd.g_old_rec.overall_performance_level_id;
  End If;
  If (p_rec.open = hr_api.g_varchar2) then
    p_rec.open := per_apr_shd.g_old_rec.open;
  End If;
  If (p_rec.attribute_category = hr_api.g_varchar2) then
    p_rec.attribute_category :=
    per_apr_shd.g_old_rec.attribute_category;
  End If;
  If (p_rec.attribute1 = hr_api.g_varchar2) then
    p_rec.attribute1 :=
    per_apr_shd.g_old_rec.attribute1;
  End If;
  If (p_rec.attribute2 = hr_api.g_varchar2) then
    p_rec.attribute2 :=
    per_apr_shd.g_old_rec.attribute2;
  End If;
  If (p_rec.attribute3 = hr_api.g_varchar2) then
    p_rec.attribute3 :=
    per_apr_shd.g_old_rec.attribute3;
  End If;
  If (p_rec.attribute4 = hr_api.g_varchar2) then
    p_rec.attribute4 :=
    per_apr_shd.g_old_rec.attribute4;
  End If;
  If (p_rec.attribute5 = hr_api.g_varchar2) then
    p_rec.attribute5 :=
    per_apr_shd.g_old_rec.attribute5;
  End If;
  If (p_rec.attribute6 = hr_api.g_varchar2) then
    p_rec.attribute6 :=
    per_apr_shd.g_old_rec.attribute6;
  End If;
  If (p_rec.attribute7 = hr_api.g_varchar2) then
    p_rec.attribute7 :=
    per_apr_shd.g_old_rec.attribute7;
  End If;
  If (p_rec.attribute8 = hr_api.g_varchar2) then
    p_rec.attribute8 :=
    per_apr_shd.g_old_rec.attribute8;
  End If;
  If (p_rec.attribute9 = hr_api.g_varchar2) then
    p_rec.attribute9 :=
    per_apr_shd.g_old_rec.attribute9;
  End If;
  If (p_rec.attribute10 = hr_api.g_varchar2) then
    p_rec.attribute10 :=
    per_apr_shd.g_old_rec.attribute10;
  End If;
  If (p_rec.attribute11 = hr_api.g_varchar2) then
    p_rec.attribute11 :=
    per_apr_shd.g_old_rec.attribute11;
  End If;
  If (p_rec.attribute12 = hr_api.g_varchar2) then
    p_rec.attribute12 :=
    per_apr_shd.g_old_rec.attribute12;
  End If;
  If (p_rec.attribute13 = hr_api.g_varchar2) then
    p_rec.attribute13 :=
    per_apr_shd.g_old_rec.attribute13;
  End If;
  If (p_rec.attribute14 = hr_api.g_varchar2) then
    p_rec.attribute14 :=
    per_apr_shd.g_old_rec.attribute14;
  End If;
  If (p_rec.attribute15 = hr_api.g_varchar2) then
    p_rec.attribute15 :=
    per_apr_shd.g_old_rec.attribute15;
  End If;
  If (p_rec.attribute16 = hr_api.g_varchar2) then
    p_rec.attribute16 :=
    per_apr_shd.g_old_rec.attribute16;
  End If;
  If (p_rec.attribute17 = hr_api.g_varchar2) then
    p_rec.attribute17 :=
    per_apr_shd.g_old_rec.attribute17;
  End If;
  If (p_rec.attribute18 = hr_api.g_varchar2) then
    p_rec.attribute18 :=
    per_apr_shd.g_old_rec.attribute18;
  End If;
  If (p_rec.attribute19 = hr_api.g_varchar2) then
    p_rec.attribute19 :=
    per_apr_shd.g_old_rec.attribute19;
  End If;
  If (p_rec.attribute20 = hr_api.g_varchar2) then
    p_rec.attribute20 :=
    per_apr_shd.g_old_rec.attribute20;
  End If;

  If (p_rec.system_type = hr_api.g_varchar2) then
    p_rec.system_type :=
    per_apr_shd.g_old_rec.system_type;
  End If;
  If (p_rec.system_params = hr_api.g_varchar2) then
      p_rec.system_params :=
      per_apr_shd.g_old_rec.system_params;
  End If;

  If (p_rec.appraisee_access = hr_api.g_varchar2) then
    p_rec.appraisee_access :=
    per_apr_shd.g_old_rec.appraisee_access;
  End If;
  If (p_rec.main_appraiser_id = hr_api.g_number) then
    p_rec.main_appraiser_id :=
    per_apr_shd.g_old_rec.main_appraiser_id;
  End If;
  If (p_rec.assignment_id = hr_api.g_number) then
    p_rec.assignment_id :=
    per_apr_shd.g_old_rec.assignment_id;
  End If;
  If (p_rec.assignment_start_date = hr_api.g_date) then
    p_rec.assignment_start_date :=
    per_apr_shd.g_old_rec.assignment_start_date;
  End If;

  If (p_rec.assignment_business_group_id = hr_api.g_number) then
      p_rec.assignment_business_group_id :=
      per_apr_shd.g_old_rec.assignment_business_group_id;
  End If;
  If (p_rec.assignment_organization_id = hr_api.g_number) then
      p_rec.assignment_organization_id :=
      per_apr_shd.g_old_rec.assignment_organization_id;
  End If;
  If (p_rec.assignment_job_id = hr_api.g_number) then
      p_rec.assignment_job_id :=
      per_apr_shd.g_old_rec.assignment_job_id;
  End If;
  If (p_rec.assignment_position_id = hr_api.g_number) then
      p_rec.assignment_position_id :=
      per_apr_shd.g_old_rec.assignment_position_id;
  End If;
  If (p_rec.assignment_grade_id = hr_api.g_number) then
      p_rec.assignment_grade_id :=
      per_apr_shd.g_old_rec.assignment_grade_id;
  End If;

  If (p_rec.potential_readiness_level = hr_api.g_varchar2) then
      p_rec.potential_readiness_level :=
      per_apr_shd.g_old_rec.potential_readiness_level;
  End If;
  If (p_rec.potential_short_term_workopp = hr_api.g_varchar2) then
        p_rec.potential_short_term_workopp :=
        per_apr_shd.g_old_rec.potential_short_term_workopp;
  End If;
  If (p_rec.potential_long_term_workopp = hr_api.g_varchar2) then
        p_rec.potential_long_term_workopp :=
        per_apr_shd.g_old_rec.potential_long_term_workopp;
  End If;
  If (p_rec.potential_details = hr_api.g_varchar2) then
        p_rec.potential_details :=
        per_apr_shd.g_old_rec.potential_details;
  End If;
  If (p_rec.event_id = hr_api.g_number) then
        p_rec.event_id :=
        per_apr_shd.g_old_rec.event_id;
  End If;

  If (p_rec.appraisal_system_status = hr_api.g_varchar2) then
        p_rec.appraisal_system_status :=
        per_apr_shd.g_old_rec.appraisal_system_status;
  End If;

  If (p_rec.show_competency_ratings = hr_api.g_varchar2) then
        p_rec.show_competency_ratings :=
        per_apr_shd.g_old_rec.show_competency_ratings;
  End If;

  If (p_rec.show_objective_ratings = hr_api.g_varchar2) then
        p_rec.show_objective_ratings :=
        per_apr_shd.g_old_rec.show_objective_ratings;
  End If;

  If (p_rec.show_questionnaire_info = hr_api.g_varchar2) then
        p_rec.show_questionnaire_info :=
        per_apr_shd.g_old_rec.show_questionnaire_info;
  End If;

  If (p_rec.show_participant_details = hr_api.g_varchar2) then
        p_rec.show_participant_details :=
        per_apr_shd.g_old_rec.show_participant_details;
  End If;

  If (p_rec.show_participant_ratings = hr_api.g_varchar2) then
        p_rec.show_participant_ratings :=
        per_apr_shd.g_old_rec.show_participant_ratings;
  End If;

  If (p_rec.show_participant_names = hr_api.g_varchar2) then
        p_rec.show_participant_names :=
        per_apr_shd.g_old_rec.show_participant_names;
  End If;

  If (p_rec.show_overall_ratings = hr_api.g_varchar2) then
        p_rec.show_overall_ratings :=
        per_apr_shd.g_old_rec.show_overall_ratings;
  End If;

  If (p_rec.show_overall_comments = hr_api.g_varchar2) then
        p_rec.show_overall_comments :=
        per_apr_shd.g_old_rec.show_overall_comments;
  End If;

  If (p_rec.update_appraisal = hr_api.g_varchar2) then
        p_rec.update_appraisal :=
        per_apr_shd.g_old_rec.update_appraisal;
  End If;

  If (p_rec.provide_overall_feedback = hr_api.g_varchar2) then
        p_rec.provide_overall_feedback :=
        per_apr_shd.g_old_rec.provide_overall_feedback;
  End If;

  If (p_rec.appraisee_comments = hr_api.g_varchar2) then
        p_rec.appraisee_comments :=
        per_apr_shd.g_old_rec.appraisee_comments;
  End If;

  If (p_rec.plan_id = hr_api.g_number) then
        p_rec.plan_id :=
        per_apr_shd.g_old_rec.plan_id;
  End If;

  If (p_rec.offline_status = hr_api.g_varchar2) then
        p_rec.offline_status :=
        per_apr_shd.g_old_rec.offline_status;
  End If;

      If (p_rec.retention_potential = hr_api.g_varchar2) then
        p_rec.retention_potential :=
        per_apr_shd.g_old_rec.retention_potential;
  End If;

   -- 8651478 bug fix
 If (p_rec.show_participant_comments = hr_api.g_varchar2) then
        p_rec.show_participant_comments :=
        per_apr_shd.g_old_rec.show_participant_comments;
  End If;

  hr_utility.set_location(' Leaving:'||l_proc, 10);

End convert_defs;

-- ---------------------------------------------------------------------------+
-- |---------------------------------< upd >----------------------------------|
-- ---------------------------------------------------------------------------+
Procedure upd
  (
  p_rec        in out nocopy per_apr_shd.g_rec_type,
  p_effective_date 	in date,
  p_validate   in     boolean default false
  ) is

  l_proc  varchar2(72) := g_package||'upd';

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  -- Determine if the business process is to be validated.

  If p_validate then

    -- Issue the savepoint.

    SAVEPOINT upd_per_apr;
  End If;

  -- We must lock the row which we need to update.

  per_apr_shd.lck
	(
	p_rec.appraisal_id,
	p_rec.object_version_number
	);

  -- 1. During an update system defaults are used to determine if
  --    arguments have been defaulted or not. We must therefore
  --    derive the full record structure values to be updated.

  -- 2. Call the supporting update validate operations.

  convert_defs(p_rec);
  per_apr_bus.update_validate(p_rec,p_effective_date);
  -- raise any errors
  hr_multi_message.end_validation_set;
  -- Call the supporting pre-update operation

  pre_update(p_rec);

  -- Update the row.

  update_dml(p_rec);

  -- Call the supporting post-update operation

  post_update(p_rec);
  -- raise any errors
  hr_multi_message.end_validation_set;

  -- If we are validating then raise the Validate_Enabled exception

  If p_validate then
    Raise HR_Api.Validate_Enabled;
  End If;

  hr_utility.set_location(' Leaving:'||l_proc, 10);
Exception
  When HR_Api.Validate_Enabled Then

    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint

    ROLLBACK TO upd_per_apr;
End upd;

-- ---------------------------------------------------------------------------+
-- |---------------------------------< upd >----------------------------------|
-- ---------------------------------------------------------------------------+
Procedure upd
  (
  p_appraisal_id                 in number,
  p_object_version_number        in out nocopy number,
  p_appraiser_person_id          in number,
  p_appraisal_date		 in date             default hr_api.g_date,
  p_appraisal_period_end_date    in date             default hr_api.g_date,
  p_appraisal_period_start_date  in date             default hr_api.g_date,
  p_type                         in varchar2         default hr_api.g_varchar2,
  p_next_appraisal_date          in date             default hr_api.g_date,
  p_status                       in varchar2         default hr_api.g_varchar2,
  p_comments                     in varchar2         default hr_api.g_varchar2,
  p_overall_performance_level_id in number           default hr_api.g_number,
  p_open                         in varchar2         default hr_api.g_varchar2,
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
  p_system_type                  in varchar2         default hr_api.g_varchar2,
  p_system_params                in varchar2         default hr_api.g_varchar2,
  p_appraisee_access             in varchar2         default hr_api.g_varchar2,
  p_main_appraiser_id            in number           default hr_api.g_number,
  p_assignment_id                in number           default hr_api.g_number,
  p_assignment_start_date        in date             default hr_api.g_date,
  p_asg_business_group_id        in number 	     default hr_api.g_number,
  p_assignment_organization_id   in number 	     default hr_api.g_number,
  p_assignment_job_id            in number 	     default hr_api.g_number,
  p_assignment_position_id       in number 	     default hr_api.g_number,
  p_assignment_grade_id          in number 	     default hr_api.g_number,
  p_appraisal_system_status      in varchar2         default hr_api.g_varchar2,
  p_potential_readiness_level    in varchar2         default hr_api.g_varchar2,
  p_potential_short_term_workopp in varchar2         default hr_api.g_varchar2,
  p_potential_long_term_workopp  in varchar2         default hr_api.g_varchar2,
  p_potential_details            in varchar2         default hr_api.g_varchar2,
  p_event_id                     in number           default hr_api.g_number,
  p_show_competency_ratings      in varchar2         default hr_api.g_varchar2,
  p_show_objective_ratings       in varchar2         default hr_api.g_varchar2,
  p_show_questionnaire_info      in varchar2         default hr_api.g_varchar2,
  p_show_participant_details     in varchar2         default hr_api.g_varchar2,
  p_show_participant_ratings     in varchar2         default hr_api.g_varchar2,
  p_show_participant_names       in varchar2         default hr_api.g_varchar2,
  p_show_overall_ratings         in varchar2         default hr_api.g_varchar2,
  p_show_overall_comments        in varchar2         default hr_api.g_varchar2,
  p_update_appraisal             in varchar2         default hr_api.g_varchar2,
  p_provide_overall_feedback     in varchar2         default hr_api.g_varchar2,
  p_appraisee_comments           in varchar2         default hr_api.g_varchar2,
  p_plan_id                      in number           default hr_api.g_number,
  p_offline_status               in varchar2         default hr_api.g_varchar2,
p_retention_potential                in varchar2         default hr_api.g_varchar2,
  p_validate                     in boolean          default false,
p_show_participant_comments     in varchar2         default hr_api.g_varchar2  -- 8651478 bug fix
  ) is

  l_rec	  per_apr_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'upd';

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  -- Call conversion function to turn arguments into the
  -- l_rec structure.

  l_rec :=
  per_apr_shd.convert_args
  (
  p_appraisal_id,
  hr_api.g_number,
  p_object_version_number,
  hr_api.g_number,
  hr_api.g_number,
  p_appraiser_person_id,
  p_appraisal_date,
  p_appraisal_period_end_date,
  p_appraisal_period_start_date,
  p_type,
  p_next_appraisal_date,
  p_status,
  hr_api.g_date,
  hr_api.g_number,
  p_comments,
  p_overall_performance_level_id,
  p_open,
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
  p_system_type,
  p_system_params,
  p_appraisee_access,
  p_main_appraiser_id,
  p_assignment_id,
  p_assignment_start_date,
  p_asg_business_group_id,
  p_assignment_organization_id  ,
  p_assignment_job_id           ,
  p_assignment_position_id      ,
  p_assignment_grade_id,
  p_appraisal_system_status,
  p_potential_readiness_level,
  p_potential_short_term_workopp,
  p_potential_long_term_workopp,
  p_potential_details,
  p_event_id,
  p_show_competency_ratings,
  p_show_objective_ratings,
  p_show_questionnaire_info,
  p_show_participant_details,
  p_show_participant_ratings,
  p_show_participant_names,
  p_show_overall_ratings,
  p_show_overall_comments,
  p_update_appraisal,
  p_provide_overall_feedback,
  p_appraisee_comments,
  p_plan_id,
  p_offline_status,
p_retention_potential,
p_show_participant_comments    -- 8651478 bug fix
  );

  -- Having converted the arguments into the
  -- plsql record structure we call the corresponding record
  -- business process.

  upd(l_rec, p_effective_date,p_validate);
  p_object_version_number := l_rec.object_version_number;

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End upd;

end per_apr_upd;

/
