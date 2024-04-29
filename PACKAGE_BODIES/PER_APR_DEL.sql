--------------------------------------------------------
--  DDL for Package Body PER_APR_DEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_APR_DEL" as
/* $Header: peaprrhi.pkb 120.8.12010000.18 2010/05/25 12:18:15 psugumar ship $ */

-- ---------------------------------------------------------------------------+
-- |                     Private Global Definitions                           |
-- ---------------------------------------------------------------------------+

g_package  varchar2(33)	:= '  per_apr_del.';  -- Global package name

-- ---------------------------------------------------------------------------+
-- |------------------------------< delete_dml >------------------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}

-- Description:
--   This procedure controls the actual dml delete logic. The functions of
--   this procedure are as follows:
--   1) To delete the specified row from the schema using the primary key in
--      the predicates.
--   2) To trap any constraint violations that may have occurred.
--   3) To raise any other errors.

-- Pre Conditions:
--   This is an internal private procedure which must be called from the del
--   procedure.

-- In Parameters:
--   A Pl/Sql record structre.

-- Post Success:
--   The specified row will be delete from the schema.

-- Post Failure:
--   If a child integrity constraint violation is raised the
--   constraint_error procedure will be called.

-- Developer Implementation Notes:
--   None.

-- Access Status:
--   Internal Table Handler Use Only.

-- {End Of Comments}
-- ---------------------------------------------------------------------------+
Procedure delete_dml(p_rec in per_apr_shd.g_rec_type) is

  l_proc  varchar2(72) := g_package||'delete_dml';

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);


  -- Delete the per_appraisals row.

  delete from per_appraisals
  where appraisal_id = p_rec.appraisal_id;


  hr_utility.set_location(' Leaving:'||l_proc, 10);

Exception
  When hr_api.child_integrity_violated then
    -- Child integrity has been violated
    per_apr_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When Others Then
    Raise;
End delete_dml;

-- ---------------------------------------------------------------------------+
-- |------------------------------< pre_delete >------------------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}

-- Description:
--   This private procedure contains any processing which is required before
--   the delete dml.

-- Pre Conditions:
--   This is an internal procedure which is called from the del procedure.

-- In Parameters:
--   A Pl/Sql record structre.

-- Post Success:
--   Processing continues.

-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.

-- Developer Implementation Notes:
--   Any pre-processing required before the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.

-- Access Status:
--   Internal Table Handler Use Only.

-- {End Of Comments}
-- ---------------------------------------------------------------------------+
Procedure pre_delete(p_rec in per_apr_shd.g_rec_type) is

  l_proc  varchar2(72) := g_package||'pre_delete';

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End pre_delete;

-- ---------------------------------------------------------------------------+
-- |-----------------------------< post_delete >------------------------------|
-- ---------------------------------------------------------------------------+
-- {Start Of Comments}

-- Description:
--   This private procedure contains any processing which is required after the
--   delete dml.

-- Pre Conditions:
--   This is an internal procedure which is called from the del procedure.

-- In Parameters:
--   A Pl/Sql record structre.

-- Post Success:
--   Processing continues.

-- Post Failure:
--   If an error has occurred, an error message and exception will be raised
--   but not handled.

-- Developer Implementation Notes:
--   Any post-processing required after the delete dml is issued should be
--   coded within this procedure. It is important to note that any 3rd party
--   maintenance should be reviewed before placing in this procedure.

-- Access Status:
--   Internal table Handler Use Only.

-- {End Of Comments}
-- ---------------------------------------------------------------------------+
Procedure post_delete(p_rec in per_apr_shd.g_rec_type) is

  l_proc  varchar2(72) := g_package||'post_delete';

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  -- This is a hook point and the user hook for post_delete is called here.

  begin
     per_apr_rkd.after_delete	(
            p_appraisal_id                   => p_rec.appraisal_id                          ,
            p_business_group_id_o            => per_apr_shd.g_old_rec.business_group_id     ,
            p_appraisal_template_id_o        => per_apr_shd.g_old_rec.appraisal_template_id ,
            p_appraisee_person_id_o          => per_apr_shd.g_old_rec.appraisee_person_id   ,
            p_appraiser_person_id_o          => per_apr_shd.g_old_rec.appraiser_person_id   ,
            p_appraisal_date_o               => per_apr_shd.g_old_rec.appraisal_date        ,
            p_group_date_o                   => per_apr_shd.g_old_rec.group_date            ,
            p_group_initiator_id_o           => per_apr_shd.g_old_rec.group_initiator_id    ,
            p_appraisal_period_end_date_o    => per_apr_shd.g_old_rec.appraisal_period_end_date   ,
            p_appraisal_period_start_dat_o   => per_apr_shd.g_old_rec.appraisal_period_start_date ,
            p_type_o                         => per_apr_shd.g_old_rec.type                  ,
            p_next_appraisal_date_o          => per_apr_shd.g_old_rec.next_appraisal_date   ,
            p_status_o                       => per_apr_shd.g_old_rec.status                ,
            p_comments_o                     => per_apr_shd.g_old_rec.comments              ,
            p_overall_performance_level_o    => per_apr_shd.g_old_rec.overall_performance_level_id,
            p_open_o                         => per_apr_shd.g_old_rec.open                  ,
            p_attribute_category_o           => per_apr_shd.g_old_rec.attribute_category    ,
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
            p_attribute12_o                  => per_apr_shd.g_old_rec.attribute12           ,
            p_attribute13_o                  => per_apr_shd.g_old_rec.attribute13           ,
            p_attribute14_o                  => per_apr_shd.g_old_rec.attribute14           ,
            p_attribute15_o                  => per_apr_shd.g_old_rec.attribute15           ,
            p_attribute16_o                  => per_apr_shd.g_old_rec.attribute16           ,
            p_attribute17_o                  => per_apr_shd.g_old_rec.attribute17           ,
            p_attribute18_o                  => per_apr_shd.g_old_rec.attribute18           ,
            p_attribute19_o                  => per_apr_shd.g_old_rec.attribute19           ,
            p_attribute20_o                  => per_apr_shd.g_old_rec.attribute20           ,
            p_object_version_number_o        => per_apr_shd.g_old_rec.object_version_number ,
            p_system_type_o                  => per_apr_shd.g_old_rec.system_type           ,
            p_system_params_o                => per_apr_shd.g_old_rec.system_params         ,
            p_appraisee_access_o             => per_apr_shd.g_old_rec.appraisee_access      ,
            p_main_appraiser_id_o            => per_apr_shd.g_old_rec.main_appraiser_id     ,
            p_assignment_id_o                => per_apr_shd.g_old_rec.assignment_id         ,
            p_assignment_start_date_o        => per_apr_shd.g_old_rec.assignment_start_date ,
            p_asg_business_group_id_o        => per_apr_shd.g_old_rec.assignment_business_group_id ,
	    p_assignment_organization_id_o   => per_apr_shd.g_old_rec.assignment_organization_id ,
	    p_assignment_job_id_o            => per_apr_shd.g_old_rec.assignment_job_id,
	    p_assignment_position_id_o       => per_apr_shd.g_old_rec.assignment_position_id,
            p_assignment_grade_id_o          => per_apr_shd.g_old_rec.assignment_grade_id,
            p_appraisal_system_status_o      => per_apr_shd.g_old_rec.appraisal_system_status,
            p_potential_readiness_level_o    => per_apr_shd.g_old_rec.potential_readiness_level,
	    p_potnl_short_term_workopp_o => per_apr_shd.g_old_rec.potential_short_term_workopp,
	    p_potnl_long_term_workopp_o  => per_apr_shd.g_old_rec.potential_long_term_workopp,
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
 p_retention_potential_o               => per_apr_shd.g_old_rec.retention_potential,
            p_show_participant_comments_o     => per_apr_shd.g_old_rec.show_participant_comments   -- 8651478 bug fix
            );
     exception
        when hr_api.cannot_find_prog_unit then
             hr_api.cannot_find_prog_unit_error
		 (	p_module_name => 'PER_APPRAISALS'
		 	,p_hook_type  => 'AD'
	        );
  end;
  -- End of API User Hook for post_delete.

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End post_delete;

-- ---------------------------------------------------------------------------+
-- |---------------------------------< del >----------------------------------|
-- ---------------------------------------------------------------------------+
Procedure del
  (
  p_rec	      in per_apr_shd.g_rec_type,
  p_validate  in boolean default false
  ) is

  l_proc  varchar2(72) := g_package||'del';

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  -- Determine if the business process is to be validated.

  If p_validate then

    -- Issue the savepoint.

    SAVEPOINT del_per_apr;
  End If;

  -- We must lock the row which we need to delete.

  per_apr_shd.lck
	(
	p_rec.appraisal_id,
	p_rec.object_version_number
	);

  -- Call the supporting delete validate operation

  per_apr_bus.delete_validate(p_rec);
  -- raise any errors
  hr_multi_message.end_validation_set;

  -- Call the supporting pre-delete operation

  pre_delete(p_rec);

  -- Delete the row.

  delete_dml(p_rec);

  -- Call the supporting post-delete operation

  post_delete(p_rec);
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

    ROLLBACK TO del_per_apr;
End del;

-- ---------------------------------------------------------------------------+
-- |---------------------------------< del >----------------------------------|
-- ---------------------------------------------------------------------------+
Procedure del
  (
  p_appraisal_id                       in number,
  p_object_version_number              in number,
  p_validate                           in boolean default false
  ) is

  l_rec	  per_apr_shd.g_rec_type;
  l_proc  varchar2(72) := g_package||'del';

Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

  -- As the delete procedure accepts a plsql record structure we do need to
  -- convert the  arguments into the record structure.
  -- We don't need to call the supplied conversion argument routine as we
  -- only need a few attributes.

  l_rec.appraisal_id:= p_appraisal_id;
  l_rec.object_version_number := p_object_version_number;

  -- Having converted the arguments into the per_apr_rec
  -- plsql record structure we must call the corresponding entity
  -- business process

  del(l_rec, p_validate);

  hr_utility.set_location(' Leaving:'||l_proc, 10);
End del;

end per_apr_del;

/
