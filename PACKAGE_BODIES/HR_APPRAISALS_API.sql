--------------------------------------------------------
--  DDL for Package Body HR_APPRAISALS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_APPRAISALS_API" as
/* $Header: peaprapi.pkb 120.2.12010000.3 2009/08/12 14:17:44 rvagvala ship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  hr_appraisals_api.';
--
-- ---------------------------------------------------------------------------
-- |-----------------------< <create_appraisal> >--------------------------|
-- ---------------------------------------------------------------------------
--
procedure create_appraisal
 (p_validate                     in     boolean  	default false,
  p_effective_date               in     date,
  p_business_group_id            in 	number,
  p_appraisal_template_id        in   	number,
  p_appraisee_person_id          in 	number,
  p_appraiser_person_id          in  	number,
  p_appraisal_date               in  	date		 default null,
  p_appraisal_period_start_date  in  	date,
  p_appraisal_period_end_date    in  	date ,
  p_type                         in    	varchar2	 default null,
  p_next_appraisal_date          in     date		 default null,
  p_status                       in    	varchar2 	 default null,
  p_group_date			 in     date             default null,
  p_group_initiator_id	  	 in     number           default null,
  p_comments                     in     varchar2	 default null,
  p_overall_performance_level_id in     number 		 default null,
  p_open			 in     varchar2         default 'Y',
  p_attribute_category           in 	varchar2         default null,
  p_attribute1                   in 	varchar2         default null,
  p_attribute2                   in 	varchar2         default null,
  p_attribute3                   in 	varchar2         default null,
  p_attribute4                   in 	varchar2         default null,
  p_attribute5                   in 	varchar2         default null,
  p_attribute6                   in 	varchar2         default null,
  p_attribute7                   in 	varchar2         default null,
  p_attribute8                   in 	varchar2         default null,
  p_attribute9                   in 	varchar2         default null,
  p_attribute10                  in 	varchar2         default null,
  p_attribute11                  in 	varchar2         default null,
  p_attribute12                  in 	varchar2         default null,
  p_attribute13                  in 	varchar2         default null,
  p_attribute14                  in 	varchar2         default null,
  p_attribute15                  in 	varchar2         default null,
  p_attribute16                  in 	varchar2         default null,
  p_attribute17                  in 	varchar2         default null,
  p_attribute18                  in 	varchar2         default null,
  p_attribute19                  in 	varchar2         default null,
  p_attribute20                  in 	varchar2         default null,
  p_system_type                  in     varchar2         default null,
  p_system_params                in     varchar2         default null,
  p_appraisee_access             in     varchar2 	 default null,
  p_main_appraiser_id            in     number 	 	 default null,
  p_assignment_id                in     number 		 default null,
  p_assignment_start_date        in     date  		 default null,
  p_asg_business_group_id        in     number		 default null,
  p_assignment_organization_id   in     number		 default null,
  p_assignment_job_id            in     number		 default null,
  p_assignment_position_id       in     number		 default null,
  p_assignment_grade_id          in     number		 default null,
  p_appraisal_id                 out nocopy    number,
  p_object_version_number        out nocopy 	number,
  p_appraisal_system_status      in     varchar2        default null,
  p_potential_readiness_level    in varchar2         	default null,
  p_potential_short_term_workopp in varchar2         	default null,
  p_potential_long_term_workopp  in varchar2         	default null,
  p_potential_details            in varchar2         	default null,
  p_event_id                     in number           	default null,
  p_show_competency_ratings      in varchar2            default null,
  p_show_objective_ratings       in varchar2            default null,
  p_show_questionnaire_info      in varchar2            default null,
  p_show_participant_details     in varchar2            default null,
  p_show_participant_ratings     in varchar2            default null,
  p_show_participant_names       in varchar2            default null,
  p_show_overall_ratings         in varchar2            default null,
  p_show_overall_comments        in varchar2            default null,
  p_update_appraisal             in varchar2            default null,
  p_provide_overall_feedback     in varchar2            default null,
  p_appraisee_comments           in varchar2            default null,
  p_plan_id                      in number              default null,
  p_offline_status               in varchar2            default null,
p_retention_potential          in varchar2           default null,
  p_show_participant_comments     in varchar2            default null  -- 8651478 bug fix
  )
 is
  --
  -- Declare cursors and local variables
  --
  --
  l_proc                	varchar2(72) := g_package||'create_appraisal';
  l_appraisal_id              per_appraisals.appraisal_id%TYPE;
  l_object_version_number	per_appraisals.object_version_number%TYPE;

begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint.
  --
  savepoint create_appraisal;
  hr_utility.set_location(l_proc, 6);
  --
  -- Call Before Process User Hook
  --
  begin
	hr_appraisals_bk1.create_appraisal_b	(
       p_effective_date               =>     p_effective_date,
       p_business_group_id            =>     p_business_group_id,
       p_appraisal_template_id        =>     p_appraisal_template_id,
       p_appraisee_person_id          =>     p_appraisee_person_id,
       p_appraiser_person_id          =>     p_appraiser_person_id,
       p_appraisal_date               =>     p_appraisal_date,
       p_appraisal_period_start_date  =>     p_appraisal_period_start_date,
       p_appraisal_period_end_date    =>     p_appraisal_period_end_date,
       p_type                         =>     p_type,
       p_next_appraisal_date          =>     p_next_appraisal_date,
       p_status                       =>     p_status,
       p_group_date                   =>     p_group_date,
       p_group_initiator_id           =>     p_group_initiator_id,
       p_comments                     =>     p_comments,
       p_overall_performance_level_id =>     p_overall_performance_level_id,
       p_open			      =>     p_open,
       p_attribute_category           =>     p_attribute_category,
       p_attribute1                   =>     p_attribute1,
       p_attribute2                   =>     p_attribute2,
       p_attribute3                   =>     p_attribute3,
       p_attribute4                   =>     p_attribute4,
       p_attribute5                   =>     p_attribute5,
       p_attribute6                   =>     p_attribute6,
       p_attribute7                   =>     p_attribute7,
       p_attribute8                   =>     p_attribute8,
       p_attribute9                   =>     p_attribute9,
       p_attribute10                  =>     p_attribute10,
       p_attribute11                  =>     p_attribute11,
       p_attribute12                  =>     p_attribute12,
       p_attribute13                  =>     p_attribute13,
       p_attribute14                  =>     p_attribute14,
       p_attribute15                  =>     p_attribute15,
       p_attribute16                  =>     p_attribute16,
       p_attribute17                  =>     p_attribute17,
       p_attribute18                  =>     p_attribute18,
       p_attribute19                  =>     p_attribute19,
       p_attribute20                  =>     p_attribute20,
       p_system_type                  =>     p_system_type          ,
       p_system_params                =>     p_system_params,
       p_appraisee_access             =>     p_appraisee_access     ,
       p_main_appraiser_id            =>     p_main_appraiser_id    ,
       p_assignment_id                =>     p_assignment_id        ,
       p_assignment_start_date        =>     p_assignment_start_date ,
       p_asg_business_group_id        =>     p_asg_business_group_id ,
       p_assignment_organization_id   =>     p_assignment_organization_id ,
       p_assignment_job_id            =>     p_assignment_job_id          ,
       p_assignment_position_id       =>     p_assignment_position_id     ,
       p_assignment_grade_id          =>     p_assignment_grade_id,
       p_appraisal_system_status      =>     p_appraisal_system_status,
       p_potential_readiness_level    =>     p_potential_readiness_level,
       p_potential_short_term_workopp =>     p_potential_short_term_workopp,
       p_potential_long_term_workopp  =>     p_potential_long_term_workopp,
       p_potential_details            =>     p_potential_details,
       p_event_id                     =>     p_event_id,
       p_show_competency_ratings      =>     p_show_competency_ratings,
       p_show_objective_ratings       =>     p_show_objective_ratings,
       p_show_questionnaire_info      =>     p_show_questionnaire_info,
       p_show_participant_details     =>     p_show_participant_details,
       p_show_participant_ratings     =>     p_show_participant_ratings,
       p_show_participant_names       =>     p_show_participant_names,
       p_show_overall_ratings         =>     p_show_overall_ratings,
       p_show_overall_comments        =>     p_show_overall_comments,
       p_update_appraisal             =>     p_update_appraisal,
       p_provide_overall_feedback     =>     p_provide_overall_feedback,
       p_appraisee_comments           =>     p_appraisee_comments,
       p_plan_id                      =>     p_plan_id,
       p_offline_status               =>     p_offline_status,
p_retention_potential               =>     p_retention_potential,
       p_show_participant_comments     =>     p_show_participant_comments   -- 8651478 bug fix
		);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'create_appraisal',
				 p_hook_type	=> 'BP'
				);
  end;
  --
  -- End of Before Process User Hook call
  --
  -- Validation in addition to Table Handlers
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- Process Logic
  --
  per_apr_ins.ins
 (p_validate                     =>     p_validate,
  p_effective_date               =>     p_effective_date,
  p_business_group_id            =>     p_business_group_id,
  p_appraisal_template_id        =>     p_appraisal_template_id,
  p_appraisee_person_id          =>     p_appraisee_person_id,
  p_appraiser_person_id          =>     p_appraiser_person_id,
  p_appraisal_date               =>     p_appraisal_date,
  p_appraisal_period_start_date  =>     p_appraisal_period_start_date,
  p_appraisal_period_end_date    =>     p_appraisal_period_end_date,
  p_type                         =>     p_type,
  p_next_appraisal_date          =>     p_next_appraisal_date,
  p_status                       =>     p_status,
  p_group_date                   =>     p_group_date,
  p_group_initiator_id           =>     p_group_initiator_id,
  p_comments                     =>     p_comments,
  p_overall_performance_level_id =>     p_overall_performance_level_id,
  p_open	                 =>     p_open,
  p_attribute_category           =>     p_attribute_category,
  p_attribute1                   =>     p_attribute1,
  p_attribute2                   =>     p_attribute2,
  p_attribute3                   =>     p_attribute3,
  p_attribute4                   =>     p_attribute4,
  p_attribute5                   =>     p_attribute5,
  p_attribute6                   =>     p_attribute6,
  p_attribute7                   =>     p_attribute7,
  p_attribute8                   =>     p_attribute8,
  p_attribute9                   =>     p_attribute9,
  p_attribute10                  =>     p_attribute10,
  p_attribute11                  =>     p_attribute11,
  p_attribute12                  =>     p_attribute12,
  p_attribute13                  =>     p_attribute13,
  p_attribute14                  =>     p_attribute14,
  p_attribute15                  =>     p_attribute15,
  p_attribute16                  =>     p_attribute16,
  p_attribute17                  =>     p_attribute17,
  p_attribute18                  =>     p_attribute18,
  p_attribute19                  =>     p_attribute19,
  p_attribute20                  =>     p_attribute20,
  p_appraisal_id                 =>     l_appraisal_id,
  p_object_version_number        =>     l_object_version_number,
  p_system_type                  =>     p_system_type          ,
  p_system_params                =>     p_system_params,
  p_appraisee_access             =>     p_appraisee_access     ,
  p_main_appraiser_id            =>     p_main_appraiser_id    ,
  p_assignment_id                =>     p_assignment_id        ,
  p_assignment_start_date        =>     p_assignment_start_date ,
  p_asg_business_group_id        =>     p_asg_business_group_id ,
  p_assignment_organization_id   =>     p_assignment_organization_id ,
  p_assignment_job_id            =>     p_assignment_job_id          ,
  p_assignment_position_id       =>     p_assignment_position_id     ,
  p_assignment_grade_id          =>     p_assignment_grade_id,
  p_appraisal_system_status      =>     p_appraisal_system_status,
  p_potential_readiness_level    =>     p_potential_readiness_level,
  p_potential_short_term_workopp =>     p_potential_short_term_workopp,
  p_potential_long_term_workopp  =>     p_potential_long_term_workopp,
  p_potential_details            =>     p_potential_details,
  p_event_id                     =>     p_event_id,
  p_show_competency_ratings      =>     p_show_competency_ratings,
  p_show_objective_ratings       =>     p_show_objective_ratings,
  p_show_questionnaire_info      =>     p_show_questionnaire_info,
  p_show_participant_details     =>     p_show_participant_details,
  p_show_participant_ratings     =>     p_show_participant_ratings,
  p_show_participant_names       =>     p_show_participant_names,
  p_show_overall_ratings         =>     p_show_overall_ratings,
  p_show_overall_comments        =>     p_show_overall_comments,
  p_update_appraisal             =>     p_update_appraisal,
  p_provide_overall_feedback     =>     p_provide_overall_feedback,
  p_appraisee_comments           =>     p_appraisee_comments,
  p_plan_id                      =>     p_plan_id,
  p_offline_status               =>     p_offline_status,
p_retention_potential               =>     p_retention_potential,
p_show_participant_comments     =>     p_show_participant_comments -- 8651478 bug fix
  );
  --
  hr_utility.set_location(l_proc, 8);
  --
  -- Call After Process User Hook
  --
  begin
	hr_appraisals_bk1.create_appraisal_a	(
       p_effective_date               =>     p_effective_date,
       p_business_group_id            =>     p_business_group_id,
       p_appraisal_template_id        =>     p_appraisal_template_id,
       p_appraisee_person_id          =>     p_appraisee_person_id,
       p_appraiser_person_id          =>     p_appraiser_person_id,
       p_appraisal_date               =>     p_appraisal_date,
       p_appraisal_period_start_date  =>     p_appraisal_period_start_date,
       p_appraisal_period_end_date    =>     p_appraisal_period_end_date,
       p_type                         =>     p_type,
       p_next_appraisal_date          =>     p_next_appraisal_date,
       p_status                       =>     p_status,
       p_group_date                   =>     p_group_date,
       p_group_initiator_id           =>     p_group_initiator_id,
       p_comments                     =>     p_comments,
       p_overall_performance_level_id =>     p_overall_performance_level_id,
       p_open			      =>     p_open,
       p_attribute_category           =>     p_attribute_category,
       p_attribute1                   =>     p_attribute1,
       p_attribute2                   =>     p_attribute2,
       p_attribute3                   =>     p_attribute3,
       p_attribute4                   =>     p_attribute4,
       p_attribute5                   =>     p_attribute5,
       p_attribute6                   =>     p_attribute6,
       p_attribute7                   =>     p_attribute7,
       p_attribute8                   =>     p_attribute8,
       p_attribute9                   =>     p_attribute9,
       p_attribute10                  =>     p_attribute10,
       p_attribute11                  =>     p_attribute11,
       p_attribute12                  =>     p_attribute12,
       p_attribute13                  =>     p_attribute13,
       p_attribute14                  =>     p_attribute14,
       p_attribute15                  =>     p_attribute15,
       p_attribute16                  =>     p_attribute16,
       p_attribute17                  =>     p_attribute17,
       p_attribute18                  =>     p_attribute18,
       p_attribute19                  =>     p_attribute19,
       p_attribute20                  =>     p_attribute20,
       p_appraisal_id                 =>     l_appraisal_id,
       p_system_type                  =>     p_system_type          ,
       p_system_params                =>     p_system_params,
       p_appraisee_access             =>     p_appraisee_access     ,
       p_main_appraiser_id            =>     p_main_appraiser_id    ,
       p_assignment_id                =>     p_assignment_id        ,
       p_assignment_start_date        =>     p_assignment_start_date ,
       p_asg_business_group_id        =>     p_asg_business_group_id ,
       p_assignment_organization_id   =>     p_assignment_organization_id ,
       p_assignment_job_id            =>     p_assignment_job_id          ,
       p_assignment_position_id       =>     p_assignment_position_id     ,
       p_assignment_grade_id          =>     p_assignment_grade_id ,
       p_object_version_number        =>     l_object_version_number,
       p_appraisal_system_status      =>     p_appraisal_system_status,
       p_potential_readiness_level    =>     p_potential_readiness_level,
       p_potential_short_term_workopp =>     p_potential_short_term_workopp,
       p_potential_long_term_workopp  =>     p_potential_long_term_workopp,
       p_potential_details            =>     p_potential_details,
       p_event_id                     =>     p_event_id,
       p_show_competency_ratings      =>     p_show_competency_ratings,
       p_show_objective_ratings       =>     p_show_objective_ratings,
       p_show_questionnaire_info      =>     p_show_questionnaire_info,
       p_show_participant_details     =>     p_show_participant_details,
       p_show_participant_ratings     =>     p_show_participant_ratings,
       p_show_participant_names       =>     p_show_participant_names,
       p_show_overall_ratings         =>     p_show_overall_ratings,
       p_show_overall_comments        =>     p_show_overall_comments,
       p_update_appraisal             =>     p_update_appraisal,
       p_provide_overall_feedback     =>     p_provide_overall_feedback,
       p_appraisee_comments           =>     p_appraisee_comments,
       p_plan_id                      =>     p_plan_id,
       p_offline_status               =>     p_offline_status,
p_retention_potential               =>     p_retention_potential,
p_show_participant_comments     =>     p_show_participant_comments -- 8651478 bug fix
		);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'create_appraisal',
				 p_hook_type	=> 'AP'
				);
  end;
  --
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
  p_appraisal_id           := l_appraisal_id;
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_appraisal;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_appraisal_id           := null;
    p_object_version_number  := null;
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632482
    --
    ROLLBACK TO create_appraisal;
    raise;
    --
    -- End of fix.
    --
    hr_utility.set_location(' Leaving:'||l_proc, 12);
end create_appraisal;
--
--
-- ---------------------------------------------------------------------------
-- |-----------------------< <update_learning_path> >--------------------------|
-- ---------------------------------------------------------------------------
procedure update_learning_path
 (p_appraisal_id    in number,
  p_appraisal_system_status in varchar2)
is
  l_ota_error_num     NUMBER;
  l_lpmid      NUMBER;
  l_lpmeid     NUMBER;
  l_act_ver_id NUMBER;
  l_ver_name   VARCHAR2(80);
  l_lpeid      NUMBER;
  l_lpid       NUMBER;
  l_lpname     VARCHAR2(80);
  l_lpme_ovn   NUMBER;
  l_lpe_ovn    NUMBER;
  l_found_components boolean;

  TYPE dynamic_ota_cursor_type IS REF CURSOR;
  dynamic_ota_cursor  dynamic_ota_cursor_type;


  dynamic_ota_lpme_query varchar2(3600) := ' select lpm.learning_path_member_id, lpme.lp_member_enrollment_id, ' ||
				' lpm.activity_version_id, tav.version_name , lpe.lp_enrollment_id, lptl.name, ' ||
				' lpme.object_version_number, lpe.object_version_number ' ||
				' from ota_learning_path_members lpm, ota_learning_paths lp,ota_lp_sections lps, ' ||
				' ota_lp_enrollments lpe, ota_lp_member_enrollments lpme, ota_activity_versions tav, ' ||
				' ota_learning_paths_tl lptl ' ||
				' where lp.source_id = :1 ' ||
				' and source_function_code = ''APPRAISAL''' ||
				' and lptl.learning_path_id = lp.learning_path_id ' ||
				' and lptl.language = userenv(''lang'') ' ||
				' and lpe.learning_path_id = lp.learning_path_id ' ||
				' and lps.learning_path_id = lp.learning_path_id  ' ||
				' and lpm.learning_path_section_id = lps.learning_path_section_id ' ||
				' and lpme.learning_path_member_id = lpm.learning_path_member_id ' ||
				' and tav.activity_version_id = lpm.activity_version_id ';

  dynamic_ota_lpe_query varchar2(3600) := ' select lp.learning_path_id, lpe.lp_enrollment_id, ' ||
					  ' lpe.object_version_number ' ||
					  ' from ota_learning_paths lp, ota_lp_enrollments lpe ' ||
					  ' where lp.source_id = :1 ' ||
					  ' and lp.source_function_code = ''APPRAISAL''' ||
					  ' and lpe.learning_path_id = lp.learning_path_id ';

  dynamic_ota_lpme_upd  varchar2(3600) := 'begin ota_lp_member_enrollment_api.update_lp_member_enrollment( ' ||
                  'p_effective_date => trunc(sysdate) , ' ||
                  'p_lp_member_enrollment_id  => :1 ,' ||
                  'p_object_version_number => :2 ,' ||
                  'p_member_status_code => :3); end;';
  dynamic_ota_lpe_upd    varchar2(3600) := ' BEGIN  ota_lp_enrollment_api.update_lp_enrollment( ' ||
                            'p_effective_date => trunc(sysdate) ' ||
							',p_lp_enrollment_id  => :1 ' ||
                            ',p_path_status_code => :2 ' ||
    							',p_object_version_number => :3); END;';

  begin
    if (p_appraisal_system_status = 'DELETED') then
      begin
        open dynamic_ota_cursor for dynamic_ota_lpme_query USING p_appraisal_id;
        loop
           fetch dynamic_ota_cursor into l_lpmid, l_lpmeid, l_act_ver_id, l_ver_name, l_lpeid, l_lpname, l_lpme_ovn , l_lpe_ovn;
           exit when dynamic_ota_cursor%NOTFOUND;

           EXECUTE IMMEDIATE dynamic_ota_lpme_upd USING in l_lpmeid, in out l_lpme_ovn, in 'CANCELLED';
           l_found_components := true;
        end loop;
        close dynamic_ota_cursor;
        exception
          when others then
            if (dynamic_ota_cursor%ISOPEN) then
              close dynamic_ota_cursor;
            end if;
            if (hr_utility.debug_enabled) then
              hr_utility.set_location('Exception raised in update_learning_path while executing dynamic sql dynamic_ota_lpme_query' || sqlerrm, 1);
            end if;
      end;
    end if;

    if l_found_components = true then
        EXECUTE IMMEDIATE dynamic_ota_lpe_upd USING in l_lpeid, in 'CANCELLED', in out l_lpe_ovn ;
    else
     if (p_appraisal_system_status = 'DELETED') then
      begin
        open dynamic_ota_cursor for dynamic_ota_lpe_query USING p_appraisal_id;
        loop
           fetch dynamic_ota_cursor into l_lpid, l_lpeid, l_lpe_ovn;
           exit when dynamic_ota_cursor%NOTFOUND;
           EXECUTE IMMEDIATE dynamic_ota_lpe_upd USING in l_lpeid, in 'CANCELLED', in out l_lpe_ovn ;
        end loop;
        close dynamic_ota_cursor;
        exception
          when others then
            if (dynamic_ota_cursor%ISOPEN) then
              close dynamic_ota_cursor;
            end if;
            if (hr_utility.debug_enabled) then
              hr_utility.set_location('Exception raised in update_learning_path while executing dynamic sql dynamic_ota_lpe_query' || sqlerrm, 1);
            end if;
      end;
     end if;
    end if;
  exception
     when OTHERS then
        l_ota_error_num := sqlcode;
        if (dynamic_ota_cursor%ISOPEN) then
           close dynamic_ota_cursor;
        end if;
        if ((l_ota_error_num= -904) or (l_ota_error_num = -6550) or (l_ota_error_num = -942)) then
           if (hr_utility.debug_enabled) then
               hr_utility.set_location('Oracle iLearning (OTA) is not installed. Contact your System Administrator', 1);
           end if;
        else
           raise;
        end if;
  end;
-- ---------------------------------------------------------------------------
-- |-----------------------< <update_appraisal> >--------------------------|
-- ---------------------------------------------------------------------------
--
procedure update_appraisal
 (p_validate                     in boolean	default false,
  p_effective_date               in date,
  p_appraisal_id                 in number,
  p_object_version_number        in out nocopy number,
  p_appraiser_person_id		 in number,
  p_appraisal_date               in date             default hr_api.g_date,
  p_appraisal_period_end_date    in date             default hr_api.g_date,
  p_appraisal_period_start_date  in date             default hr_api.g_date,
  p_type                         in varchar2         default hr_api.g_varchar2,
  p_next_appraisal_date          in date             default hr_api.g_date,
  p_status                       in varchar2         default hr_api.g_varchar2,
  p_comments                     in varchar2         default hr_api.g_varchar2,
  p_overall_performance_level_id in number           default hr_api.g_number,
  p_open		         in varchar2         default hr_api.g_varchar2,
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
  p_system_type                  in varchar2         default hr_api.g_varchar2,
  p_system_params                in varchar2         default hr_api.g_varchar2,
  p_appraisee_access             in varchar2         default hr_api.g_varchar2,
  p_main_appraiser_id            in number 	     default hr_api.g_number,
  p_assignment_id                in number 	     default hr_api.g_number,
  p_assignment_start_date        in date  	     default hr_api.g_date,
  p_asg_business_group_id        in number	     default hr_api.g_number,
  p_assignment_organization_id   in number	     default hr_api.g_number,
  p_assignment_job_id            in number	     default hr_api.g_number,
  p_assignment_position_id       in number	     default hr_api.g_number,
  p_assignment_grade_id           in number	     default hr_api.g_number,
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
  p_show_participant_comments     in varchar2         default hr_api.g_varchar2  -- 8651478 bug fix
 ) is
  --
  -- Declare cursors and local variables
  --

  l_proc                	varchar2(72) := g_package||'update_appraisal';
  l_object_version_number	per_appraisals.object_version_number%TYPE;
  l_asn_object_version_number	per_assessments.object_version_number%TYPE;
  l_assessment_id		per_assessments.assessment_id%TYPE;
  l_old_mainap_id       per_appraisals.main_appraiser_id%TYPE;
  l_participant_id_1      per_participants.participant_id%TYPE;
  l_participant_id_2      per_participants.participant_id%TYPE;
  l_part_object_version_number_1 per_participants.object_version_number%TYPE;
  l_part_object_version_number_2 per_participants.object_version_number%TYPE;
  --
  lv_object_version_number      number := p_object_version_number ;
  --
  l_person_id         NUMBER(9,0);
  l_ota_installed     varchar2(10);
  -- ----------------------------------------------------------------------
  -- Declare Local Procedure and Functions
  -- ----------------------------------------------------------------------
  --
  -- ----------------------------------------------------------------------
  -- ---------------------< Get_Assessment_Details >-----------------------
  -- ----------------------------------------------------------------------
  PROCEDURE Get_Assessment_Details (p_appraisal_id IN NUMBER
				 ,p_assessment_id OUT NOCOPY NUMBER
				 ,p_object_version_number OUT NOCOPY NUMBER)
  IS
    --
    CURSOR csr_get_asn_details IS
      SELECT assessment_id , object_version_number
      FROM per_assessments
      WHERE appraisal_id = p_appraisal_id;
    --
  BEGIN
    --
    OPEN csr_get_asn_details;
    FETCH csr_get_asn_details into p_assessment_id , p_object_version_number;
    CLOSE csr_get_asn_details;
    --
  exception
  when others then
    p_assessment_id := null;
    p_object_version_number := null;
    raise;

  END Get_Assessment_Details;
  --
  -- ----------------------------------------------------------------------
  -- ------------------< Appraisal_Period_Date_Changed >-------------------
  -- ----------------------------------------------------------------------
  FUNCTION Appraisal_Period_Date_Changed(p_appraisal_id IN NUMBER
					,p_appraisal_period_start_date 	IN DATE
					,p_appraisal_period_end_date 	IN DATE
                                        ,p_appraisal_date               IN DATE
					)
  RETURN BOOLEAN
  IS
    --
    -- The assessment start and end dates will be found if an assessment
    -- is part of this appraisal
    --
    CURSOR csr_get_period IS
      SELECT asn.assessment_period_start_date, asn.assessment_period_end_date,
             asn.assessment_date
      FROM per_assessments asn
      WHERE asn.appraisal_id = p_appraisal_id;
    --
    l_asn_start_date	 per_assessments.assessment_period_start_date%TYPE;
    l_asn_end_date	 per_assessments.assessment_period_end_date%TYPE;
    l_asn_date           per_assessments.assessment_date%TYPE;
    --
  BEGIN
    --
    OPEN csr_get_period;
    FETCH csr_get_period INTO l_asn_start_date, l_asn_end_date, l_asn_date;
    --
    IF csr_get_period%FOUND   		-- i.e.  if there is an assessment
      AND (l_asn_start_date <> p_appraisal_period_start_date  -- and the dates differ ..
          OR l_asn_end_date   <> p_appraisal_period_end_date
          OR l_asn_date <> p_appraisal_date) THEN
      --
      CLOSE csr_get_period;
      --
      -- The assessment will need updating as the dates are different from the appraisals.
      --
      RETURN TRUE;
      --
    ELSE
      --
      CLOSE csr_get_period;
      --
      -- Either there is no assessment for this appraisal, or the dates are the same.
      --
      RETURN FALSE;
      --
    END IF;
  END Appraisal_Period_Date_Changed;
  -- ----------------------------------------------------------------------
  -- ------------------< Participant_Exists >-------------------
  -- ----------------------------------------------------------------------
  PROCEDURE Get_Participant_Id(p_appraisal_id IN NUMBER
                                        ,p_person_id IN NUMBER
                    ,p_participant_id OUT NOCOPY NUMBER
                    ,p_ovn OUT NOCOPY NUMBER
                                        )
  IS
    --
    -- check if Participant exists for the Appraisal and the PersonId
    --
    CURSOR csr_get_participant IS
      SELECT par.participant_id, par.object_version_number
      FROM per_participants par
      WHERE par.participation_in_id = p_appraisal_id
      and par.participation_in_table = 'PER_APPRAISALS'
      and par.participation_in_column = 'APPRAISAL_ID'
      and par.person_id = p_person_id;
   --
  BEGIN
    --
    OPEN csr_get_participant;
    FETCH csr_get_participant INTO p_participant_id, p_ovn;
    if csr_get_participant%NOTFOUND then
      p_participant_id := NULL;
      p_ovn := NULL;
    end if;
    CLOSE csr_get_participant;
  END Get_Participant_Id;
  --
  -- ----------------------------------------------------------------------
  -- ------------------< Participant_Exists >-------------------
  -- ----------------------------------------------------------------------
  FUNCTION Get_Old_Main_Appraiser_Id(p_appraisal_id IN NUMBER
                                        )
  RETURN NUMBER
  IS
    --
    -- check if Participant exists for the Appraisal and the PersonId
    --
   CURSOR csr_get_map_id IS
      SELECT apr.main_appraiser_id
      FROM per_appraisals apr
      WHERE apr.appraisal_id = p_appraisal_id;
    --
    l_main_appraiser_id per_appraisals.main_appraiser_id%TYPE;
  BEGIN
    --
    OPEN csr_get_map_id;
    FETCH csr_get_map_id INTO l_main_appraiser_id;
    --
    IF csr_get_map_id%FOUND THEN
      --
      CLOSE csr_get_map_id;
      --
      -- There is a Participant
      --
      RETURN l_main_appraiser_id;
      --
    ELSE
      --
      CLOSE csr_get_map_id;
      --
      -- There is no Participant for MA
      --
      RETURN NULL;
      --
    END IF;
  END Get_Old_Main_Appraiser_Id;
  --
begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint.
  --
  savepoint update_appraisal;
  hr_utility.set_location(l_proc, 6);
  --
  --
  -- Call Before Process User Hook
  --
  begin
	hr_appraisals_bk2.update_appraisal_b	(
          p_effective_date               =>     p_effective_date,
          p_appraisal_id                 =>     p_appraisal_id,
          p_object_version_number        =>     p_object_version_number,
          p_appraiser_person_id          =>     p_appraiser_person_id,
          p_appraisal_date               =>     p_appraisal_date,
          p_appraisal_period_start_date  =>     p_appraisal_period_start_date,
          p_appraisal_period_end_date    =>     p_appraisal_period_end_date,
          p_type                         =>     p_type,
          p_next_appraisal_date          =>     p_next_appraisal_date,
          p_status                       =>     p_status,
          p_comments                     =>     p_comments,
          p_overall_performance_level_id =>     p_overall_performance_level_id,
          p_open                         =>     p_open,
          p_attribute_category           =>     p_attribute_category,
          p_attribute1                   =>     p_attribute1,
          p_attribute2                   =>     p_attribute2,
          p_attribute3                   =>     p_attribute3,
          p_attribute4                   =>     p_attribute4,
          p_attribute5                   =>     p_attribute5,
          p_attribute6                   =>     p_attribute6,
          p_attribute7                   =>     p_attribute7,
          p_attribute8                   =>     p_attribute8,
          p_attribute9                   =>     p_attribute9,
          p_attribute10                  =>     p_attribute10,
          p_attribute11                  =>     p_attribute11,
          p_attribute12                  =>     p_attribute12,
          p_attribute13                  =>     p_attribute13,
          p_attribute14                  =>     p_attribute14,
          p_attribute15                  =>     p_attribute15,
          p_attribute16                  =>     p_attribute16,
          p_attribute17                  =>     p_attribute17,
          p_attribute18                  =>     p_attribute18,
          p_attribute19                  =>     p_attribute19,
          p_attribute20                  =>     p_attribute20,
          p_system_type                  =>     p_system_type          ,
          p_system_params                =>     p_system_params,
	  p_appraisee_access             =>     p_appraisee_access     ,
	  p_main_appraiser_id            =>     p_main_appraiser_id    ,
	  p_assignment_id                =>     p_assignment_id        ,
	  p_assignment_start_date        =>     p_assignment_start_date ,
	  p_asg_business_group_id        =>     p_asg_business_group_id ,
	  p_assignment_organization_id   =>     p_assignment_organization_id ,
	  p_assignment_job_id            =>     p_assignment_job_id          ,
	  p_assignment_position_id       =>     p_assignment_position_id     ,
          p_assignment_grade_id          =>     p_assignment_grade_id,
	  p_appraisal_system_status      =>     p_appraisal_system_status,
	  p_potential_readiness_level    =>     p_potential_readiness_level,
	  p_potential_short_term_workopp =>     p_potential_short_term_workopp,
	  p_potential_long_term_workopp  =>     p_potential_long_term_workopp,
	  p_potential_details            =>     p_potential_details,
	  p_event_id                     =>     p_event_id,
          p_show_competency_ratings      =>     p_show_competency_ratings,
          p_show_objective_ratings       =>     p_show_objective_ratings,
          p_show_questionnaire_info      =>     p_show_questionnaire_info,
          p_show_participant_details     =>     p_show_participant_details,
          p_show_participant_ratings     =>     p_show_participant_ratings,
          p_show_participant_names       =>     p_show_participant_names,
          p_show_overall_ratings         =>     p_show_overall_ratings,
          p_show_overall_comments        =>     p_show_overall_comments,
          p_update_appraisal             =>     p_update_appraisal,
          p_provide_overall_feedback     =>     p_provide_overall_feedback,
          p_appraisee_comments           =>     p_appraisee_comments,
          p_plan_id                      =>     p_plan_id,
          p_offline_status               =>     p_offline_status,
p_retention_potential               =>     p_retention_potential,
 p_show_participant_comments     =>     p_show_participant_comments -- 8651478 bug fix
		);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'update_appraisal',
				 p_hook_type	=> 'BP'
				);
  end;
  --
  -- End of Before Process User Hook call
  --
  -- Validation in addition to Table Handlers
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- Process Logic
  --
  l_object_version_number := p_object_version_number;
  -- Get Old MA Id and check if MainAppraiser has been switched and based on
  -- that we check if there is a Participant for MA and we change the type. For
  -- the new MA check if he is a Participant and if Yes change his Type to MA
  l_old_mainap_id := Get_Old_Main_Appraiser_Id(p_appraisal_id);

  -- in case of appraisal delete or reject we are going to change the
  -- Learning Path Status to Cancelled.
  hr_util_misc_ss.check_ota_installed(810, l_ota_installed);
  if(l_ota_installed = 'Y') then
    update_learning_path(p_appraisal_id, p_appraisal_system_status);
  end if;
  --
  per_apr_upd.upd
 (p_validate                     =>	p_validate,
  p_effective_date               =>     p_effective_date,
  p_appraisal_id		 =>	p_appraisal_id,
  p_object_version_number	 =>	l_object_version_number,
  p_appraiser_person_id          =>     p_appraiser_person_id,
  p_appraisal_date  		=>	p_appraisal_date,
  p_appraisal_period_start_date  =>	p_appraisal_period_start_date,
  p_appraisal_period_end_date    =>	p_appraisal_period_end_date,
  p_type                         =>	p_type,
  p_next_appraisal_date          =>	p_next_appraisal_date,
  p_status                       =>	p_status,
  p_comments                     =>	p_comments,
  p_overall_performance_level_id =>	p_overall_performance_level_id,
  p_open	                 =>     p_open,
  p_attribute_category           =>     p_attribute_category,
  p_attribute1                   =>     p_attribute1,
  p_attribute2                   =>     p_attribute2,
  p_attribute3                   =>     p_attribute3,
  p_attribute4                   =>     p_attribute4,
  p_attribute5                   =>     p_attribute5,
  p_attribute6                   =>     p_attribute6,
  p_attribute7                   =>     p_attribute7,
  p_attribute8                   =>     p_attribute8,
  p_attribute9                   =>     p_attribute9,
  p_attribute10                  =>     p_attribute10,
  p_attribute11                  =>     p_attribute11,
  p_attribute12                  =>     p_attribute12,
  p_attribute13                  =>     p_attribute13,
  p_attribute14                  =>     p_attribute14,
  p_attribute15                  =>     p_attribute15,
  p_attribute16                  =>     p_attribute16,
  p_attribute17                  =>     p_attribute17,
  p_attribute18                  =>     p_attribute18,
  p_attribute19                  =>     p_attribute19,
  p_attribute20                  =>     p_attribute20,
  p_system_type                  =>     p_system_type      ,
  p_system_params                =>     p_system_params,
  p_appraisee_access             =>     p_appraisee_access ,
  p_main_appraiser_id            =>     p_main_appraiser_id,
  p_assignment_id                =>     p_assignment_id    ,
  p_assignment_start_date        =>     p_assignment_start_date      ,
  p_asg_business_group_id        =>     p_asg_business_group_id      ,
  p_assignment_organization_id   =>     p_assignment_organization_id ,
  p_assignment_job_id            =>     p_assignment_job_id          ,
  p_assignment_position_id       =>     p_assignment_position_id     ,
  p_assignment_grade_id          =>     p_assignment_grade_id,
  p_appraisal_system_status      =>     p_appraisal_system_status,
  p_potential_readiness_level    =>     p_potential_readiness_level,
  p_potential_short_term_workopp =>     p_potential_short_term_workopp,
  p_potential_long_term_workopp  =>     p_potential_long_term_workopp,
  p_potential_details            =>     p_potential_details,
  p_event_id                     =>     p_event_id,
  p_show_competency_ratings      =>     p_show_competency_ratings,
  p_show_objective_ratings       =>     p_show_objective_ratings,
  p_show_questionnaire_info      =>     p_show_questionnaire_info,
  p_show_participant_details     =>     p_show_participant_details,
  p_show_participant_ratings     =>     p_show_participant_ratings,
  p_show_participant_names       =>     p_show_participant_names,
  p_show_overall_ratings         =>     p_show_overall_ratings,
  p_show_overall_comments        =>     p_show_overall_comments,
  p_update_appraisal             =>     p_update_appraisal,
  p_provide_overall_feedback     =>     p_provide_overall_feedback,
  p_appraisee_comments           =>     p_appraisee_comments,
  p_plan_id                      =>     p_plan_id,
  p_offline_status               =>     p_offline_status,
p_retention_potential               =>     p_retention_potential,
 p_show_participant_comments     =>     p_show_participant_comments -- 8651478 bug fix
  );
  --
  --
  hr_utility.set_location(l_proc, 8);
  --
  -- Update the assessment if necessary (as the appraisal_period_start_date and
  -- appraisal_period_end_date may have changed which would affect an assessment
  -- if there is one attached to this appraisal)
  --
  IF  Appraisal_Period_Date_Changed (p_appraisal_id	           => p_appraisal_id
				    ,p_appraisal_period_start_date => p_appraisal_period_start_date
				    ,p_appraisal_period_end_date   => p_appraisal_period_end_date
                                    ,p_appraisal_date              => p_appraisal_date) THEN
    --
    -- [the above IF can be carried out here as the db dates that are checked are from the assessment]
    --
    --
    Get_Assessment_Details(p_appraisal_id, l_assessment_id, l_asn_object_version_number);
    --
    hr_assessments_api.update_assessment    ( p_assessment_id  			=> l_assessment_id
					    , p_object_version_number 		=> l_asn_object_version_number
					    , p_assessment_period_start_date	=> p_appraisal_period_start_date
					    , p_assessment_period_end_date	=> p_appraisal_period_end_date
                                            , p_assessment_date                 => p_appraisal_date
					    , p_validate                	=> p_validate
  					    , p_effective_date          	=> p_effective_date);
  END IF;

  if l_old_mainap_id IS NOT NULL AND p_main_appraiser_id <> hr_api.g_number THEN
    if l_old_mainap_id <> p_main_appraiser_id THEN
      Get_Participant_id(p_appraisal_id, l_old_mainap_id, l_participant_id_1, l_part_object_version_number_1);
      -- if old MA is a Participant change his Type
      if l_participant_id_1 IS NOT NULL THEN
        hr_participants_api.update_participant(p_validate  => p_validate,
                                            p_effective_date => p_effective_date,
                                            p_participant_id => l_participant_id_1,
                                            p_object_version_number => l_part_object_version_number_1,
                                            p_participation_type => 'GROUPAPPRAISER'
                                           );
      end if;
      Get_Participant_id(p_appraisal_id, p_main_appraiser_id, l_participant_id_2, l_part_object_version_number_2);
      if l_participant_id_2 IS NOT NULL THEN
        hr_participants_api.update_participant(p_validate  => p_validate,
                                            p_effective_date => p_effective_date,
                                            p_participant_id => l_participant_id_2,
                                            p_object_version_number => l_part_object_version_number_2,
                                            p_participation_type => 'MAINAP'
                                           );
      end if;
    end if;
  end if;
  --
  -- Call After Process User Hook
  --
  begin
	hr_appraisals_bk2.update_appraisal_a	(
          p_effective_date               =>     p_effective_date,
          p_appraisal_id                 =>     p_appraisal_id,
          p_object_version_number        =>     l_object_version_number,
          p_appraiser_person_id          =>     p_appraiser_person_id,
          p_appraisal_date               =>     p_appraisal_date,
          p_appraisal_period_start_date  =>     p_appraisal_period_start_date,
          p_appraisal_period_end_date    =>     p_appraisal_period_end_date,
          p_type                         =>     p_type,
          p_next_appraisal_date          =>     p_next_appraisal_date,
          p_status                       =>     p_status,
          p_comments                     =>     p_comments,
          p_overall_performance_level_id =>     p_overall_performance_level_id,
          p_open	                 =>     p_open,
          p_attribute_category           =>     p_attribute_category,
          p_attribute1                   =>     p_attribute1,
          p_attribute2                   =>     p_attribute2,
          p_attribute3                   =>     p_attribute3,
          p_attribute4                   =>     p_attribute4,
          p_attribute5                   =>     p_attribute5,
          p_attribute6                   =>     p_attribute6,
          p_attribute7                   =>     p_attribute7,
          p_attribute8                   =>     p_attribute8,
          p_attribute9                   =>     p_attribute9,
          p_attribute10                  =>     p_attribute10,
          p_attribute11                  =>     p_attribute11,
          p_attribute12                  =>     p_attribute12,
          p_attribute13                  =>     p_attribute13,
          p_attribute14                  =>     p_attribute14,
          p_attribute15                  =>     p_attribute15,
          p_attribute16                  =>     p_attribute16,
          p_attribute17                  =>     p_attribute17,
          p_attribute18                  =>     p_attribute18,
          p_attribute19                  =>     p_attribute19,
          p_attribute20                  =>     p_attribute20,
          p_system_type                  =>     p_system_type          ,
          p_system_params                =>     p_system_params,
	  p_appraisee_access             =>     p_appraisee_access     ,
	  p_main_appraiser_id            =>     p_main_appraiser_id    ,
	  p_assignment_id                =>     p_assignment_id        ,
	  p_assignment_start_date        =>     p_assignment_start_date ,
	  p_asg_business_group_id        =>     p_asg_business_group_id ,
	  p_assignment_organization_id   =>     p_assignment_organization_id ,
	  p_assignment_job_id            =>     p_assignment_job_id          ,
	  p_assignment_position_id       =>     p_assignment_position_id     ,
          p_assignment_grade_id          =>     p_assignment_grade_id,
          p_appraisal_system_status      =>     p_appraisal_system_status,
	  p_potential_readiness_level    =>     p_potential_readiness_level,
	  p_potential_short_term_workopp =>     p_potential_short_term_workopp,
	  p_potential_long_term_workopp  =>     p_potential_long_term_workopp,
	  p_potential_details            =>     p_potential_details,
	  p_event_id                     =>     p_event_id,
          p_show_competency_ratings      =>     p_show_competency_ratings,
          p_show_objective_ratings       =>     p_show_objective_ratings,
          p_show_questionnaire_info      =>     p_show_questionnaire_info,
          p_show_participant_details     =>     p_show_participant_details,
          p_show_participant_ratings     =>     p_show_participant_ratings,
          p_show_participant_names       =>     p_show_participant_names,
          p_show_overall_ratings         =>     p_show_overall_ratings,
          p_show_overall_comments        =>     p_show_overall_comments,
          p_update_appraisal             =>     p_update_appraisal,
          p_provide_overall_feedback     =>     p_provide_overall_feedback,
          p_appraisee_comments           =>     p_appraisee_comments,
          p_plan_id                      =>     p_plan_id,
          p_offline_status               =>     p_offline_status,
p_retention_potential               =>     p_retention_potential,
 p_show_participant_comments     =>     p_show_participant_comments -- 8651478 bug fix
		);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'update_appraisal',
				 p_hook_type	=> 'AP'
				);
  end;
  --
  -- End After Process User Hook
  --
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments. l_object_version_number now has the new
  -- object version number as the update was successful
  --
  p_object_version_number  := l_object_version_number;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_appraisal;
    --
    -- Only set output warning arguments and in out arguments back
    -- to their IN value
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_object_version_number  := l_object_version_number;
    --
  when others then
    --
    p_object_version_number := lv_object_version_number ;

    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632482
    --
    ROLLBACK TO update_appraisal;
    raise;
    --
    -- End of fix.
    --
    hr_utility.set_location(' Leaving:'||l_proc, 12);
--
end update_appraisal;
--
--
-- ---------------------------------------------------------------------------
-- |-----------------------< <delete_appraisal> >--------------------------|
-- ---------------------------------------------------------------------------
--
procedure delete_appraisal
(p_validate                           in boolean default false,
 p_appraisal_id                       in number,
 p_object_version_number              in number
) is
  --
  -- Declare cursors and local variables
  --
  --
  cursor c_quest_ans_id
  is
  select questionnaire_answer_id
  from hr_quest_answers
  where hr_quest_answers.type = 'APPRAISAL' and
  hr_quest_answers.type_object_id = p_appraisal_id; -- Fix for Bug No.1386826

 --
  --
     cursor cs_get_participants is
       select participant_id,object_version_number from per_participants
       where participation_in_id = p_appraisal_id
       and participation_in_table = 'PER_APPRAISALS'
       and participation_in_column = 'APPRAISAL_ID';
     --

     cursor cs_get_objectives is
       select objective_id ,object_version_number from per_objectives
       where appraisal_id = p_appraisal_id;
     --
     cursor cs_get_assessments is
       select assessment_id ,object_version_number from per_assessments
       where appraisal_id = p_appraisal_id;
     --
     cursor cs_get_perf_ratings is
       select performance_rating_id ,object_version_number from per_performance_ratings
       where appraisal_id = p_appraisal_id;

     --
     cursor cs_get_comp_elmnt_rec is
     select competence_element_id ,object_version_number
     from per_competence_elements
     where assessment_id in
     (select assessment_id from per_assessments where appraisal_id = p_appraisal_id);

     cursor cs_get_perf_review_rec is
     select performance_review_id, object_version_number
     from per_performance_reviews
     where event_id in (select event_id from per_appraisals where appraisal_id = p_appraisal_id);

     --
     cursor cs_get_per_events_rec is
       select event_id, object_version_number
       from per_events
     where event_id in (select event_id from per_appraisals where appraisal_id = p_appraisal_id);

     --
     /*
     --
     cursor cs_get_apr_quest_answers_rec is
     select quest_answer_val_id from
      hr_quest_answer_values where questionnaire_answer_id in
      (select questionnaire_answer_id from hr_quest_answers
      where type = 'APPRAISAL' and type_object_id=p_appraisal_id );
     --
     cursor cs_get_part_quest_answers_rec is
       select quest_answer_val_id from
        hr_quest_answer_values where questionnaire_answer_id in
        (select questionnaire_answer_id from hr_quest_answers
      	where type = 'PARTICIPANT' and type_object_id  in
      	(select participant_id from per_participants where
      	participation_in_table='PER_APPRAISALS' and participation_in_column='APPRAISAL_ID' and
      	participation_in_id=p_appraisal_id
      	)
       );

  */

  --

  l_quest_ans_id       hr_quest_answers.questionnaire_answer_id%type;
  --
  l_proc                varchar2(72) := g_package||'delete_appraisal';
  l_person_id         NUMBER(9,0);
  l_training_plan_member_id NUMBER(9,0);
  l_ota_error_num     NUMBER;
  l_ota_installed     VARCHAR2(10);

begin
  hr_utility.set_location('Entering:'|| l_proc, 5);
  --
  -- Issue a savepoint.
  --
  savepoint delete_appraisal;
  hr_utility.set_location(l_proc, 6);
  --
  --
  -- Call Before Process User Hook
  --
  begin
	hr_appraisals_bk3.delete_appraisal_b
		(
		p_appraisal_id            =>   p_appraisal_id,
		p_object_version_number   =>   p_object_version_number
		);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'delete_appraisal',
				 p_hook_type	=> 'BP'
				);
  end;
  --
  --  End of before process hook
  --
  -- Validation in addition to Table Handlers
  --
  hr_utility.set_location(l_proc, 7);
  --
  -- Process Logic
  --

  -- To delete Appraisal , Participants, Assessments, Comp Elements, Objectives, Perf Ratings

  -- Fix for bug no. 1386826 begins.
  --
  -- Deleting the related child records in hr_quest_answers and hr_quest_answer_values
  -- tables if the entry in "VALUE" column of hr_quest_answer_values has null entry.
  --
  open c_quest_ans_id;
  fetch c_quest_ans_id into l_quest_ans_id;
  if c_quest_ans_id%found then

  -- deleting answers and answer values.
  hr_quest_perform_web.delete_quest_answer(p_questionnaire_answer_id => l_quest_ans_id);
  end if;
  close c_quest_ans_id;
  --

  -- Fix for bug no. 1386826 ends.
  --


      /*
      Order of delete

      a) delete_competence_elements based on assessment_id
      b) delete_assessment
      c) delete_performance_ratings
      d) delete_objectives
      e) delete_appraisal_quest_answer_values -
      f) delete_appraisal_quest_answer -
      g) delete_participant_quest_answer_values
      	- Done internally, after calling hr_quest_perform_web.delete_quest_answer
      h) delete_participant_quest_answers
      	- Done in Participants API
      i) delete_participants
      j) delete_ota_training_plan_members
      	- this is under review as to how to be deleted . so nothing for this now
      k) hr_perf_review_api.delete_perf_review
      	(we create an entry in per_performance_reviews table and this has the column
      	Event_Id which will be same as Event_Id in Per_Appraisals table)
      l) per_events_api.delete_event
      	(we added an Event_id in Per_Appraisals, using that event_id we go here and delete it)
      m) delete_appraisal finally .

      */


      FOR comp_elmnt_rec in cs_get_comp_elmnt_rec LOOP
        	hr_competence_element_api.delete_competence_element
        	(
        	p_validate => p_validate
        	,p_competence_element_id => comp_elmnt_rec.competence_element_id
        	,p_object_version_number => comp_elmnt_rec.object_version_number
        	);

      END LOOP;

      --
        FOR assessments_rec in cs_get_assessments LOOP
            	hr_assessments_api.delete_assessment
            	(p_validate => p_validate
            	,p_assessment_id => assessments_rec.assessment_id
            	,p_object_version_number => assessments_rec.object_version_number
            	);

      END LOOP;
      --
        FOR perf_rating_rec in cs_get_perf_ratings LOOP
            	hr_performance_ratings_api.delete_performance_rating
            	(p_validate => p_validate
            	,p_performance_rating_id => perf_rating_rec.performance_rating_id
            	,p_object_version_number => perf_rating_rec.object_version_number
            	);

        END LOOP;
      --
      FOR objectives_rec in cs_get_objectives LOOP
        	hr_objectives_api.delete_objective
        	(p_validate => p_validate
        	,p_objective_id => objectives_rec.objective_id
        	,p_object_version_number => objectives_rec.object_version_number
        	);

      END LOOP;
      --
      FOR participants_rec in cs_get_participants LOOP
        	hr_participants_api.delete_participant
        	(p_validate => p_validate
        	,p_participant_id => participants_rec.participant_id
        	,p_object_version_number => participants_rec.object_version_number
        	);

      END LOOP;

      --
  -- in case of appraisal delete or reject we are going to change the
  -- Learning Path Status to Cancelled.
  hr_util_misc_ss.check_ota_installed(810, l_ota_installed);
  if(l_ota_installed = 'Y') then
    update_learning_path(p_appraisal_id, 'DELETED');
  end if;


      FOR perf_review_rec in cs_get_perf_review_rec LOOP
      hr_perf_review_api.delete_perf_review
      	(
      	p_validate => p_validate
      	,p_performance_review_id => perf_review_rec.performance_review_id
      	,p_object_version_number => perf_review_rec.object_version_number
      	);
      END LOOP;

      --
      FOR per_events_rec in cs_get_per_events_rec LOOP
        per_events_api.delete_event
        	(
        	p_validate => p_validate
        	,p_event_id => per_events_rec.event_id
        	,p_object_version_number => per_events_rec.object_version_number
        	);
      END LOOP;
    --


  -- now delete the appraisal itself
  --
     per_apr_del.del
     (p_validate                    => FALSE
     ,p_appraisal_id                => p_appraisal_id
     ,p_object_version_number       => p_object_version_number
     );
  --
  hr_utility.set_location(l_proc, 8);
  --
  -- Call After Process User Hook
  --
  begin
	hr_appraisals_bk3.delete_appraisal_a	(
		p_appraisal_id            =>   p_appraisal_id,
		p_object_version_number   =>   p_object_version_number
		);
      exception
	   when hr_api.cannot_find_prog_unit then
		  hr_api.cannot_find_prog_unit_error
				(p_module_name	=> 'delete_appraisal',
				 p_hook_type	=> 'AP'
				);
  end;
  --
  -- End of After Process User hook
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  if p_validate then
    raise hr_api.validate_enabled;
  end if;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 11);
exception
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO delete_appraisal;
    --
    --
  when others then
    --
    -- A validation or unexpected error has occurred
    --
    -- Added as part of fix to bug 632482
    --
    ROLLBACK TO delete_appraisal;
    raise;
    --
    -- End of fix.
    --
    hr_utility.set_location(' Leaving:'||l_proc, 12);
end delete_appraisal;
--
end hr_appraisals_api;

/
