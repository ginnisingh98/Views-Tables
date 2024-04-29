--------------------------------------------------------
--  DDL for Package PER_APP_ASG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_APP_ASG_PKG" AUTHID CURRENT_USER as
/* $Header: peasg02t.pkh 120.2 2006/05/17 19:20:25 irgonzal ship $ */
--
-- Procedure
--   cleanup_letters
-- Purpose
--   Remove extra letters for the given assignment
-- Arguments
procedure cleanup_letters ( p_assignment_id             in number ) ;

procedure insert_row(
	p_row_id			   in out nocopy varchar2,
	p_assignment_id                    in out nocopy number,
	p_effective_start_date             date,
	p_effective_end_date               date,
	p_business_group_id                number,
	p_recruiter_id                     number,
	p_grade_id                         number,
	p_position_id                      number,
	p_job_id                           number,
	p_assignment_status_type_id        number,
	p_location_id                      number,
	p_location_code                    in out nocopy varchar2,
	p_person_referred_by_id            number,
	p_supervisor_id                    number,
	p_person_id                        number,
	p_recruitment_activity_id          number,
	p_source_organization_id           number,
	p_organization_id                  number,
	p_people_group_id                  number,
	p_people_group_name                varchar2 ,
	p_vacancy_id                       number,
	p_assignment_sequence              in out nocopy number,
	p_assignment_type                  in out nocopy varchar2,
	p_primary_flag                     in out nocopy varchar2,
	p_application_id                   number,
	p_change_reason                    varchar2,
	p_comment_id                       number,
	p_date_probation_end               date,
	p_frequency                        varchar2,
	p_frequency_meaning                in out nocopy varchar2,
	p_manager_flag                     varchar2,
	p_normal_hours                     number,
	p_probation_period                 number,
	p_probation_unit                   varchar2,
	p_source_type                      varchar2,
	p_time_normal_finish               varchar2,
	p_time_normal_start                varchar2,
	p_request_id                       number,
	p_program_application_id           number,
	p_program_id                       number,
	p_program_update_date              date,
	p_ass_attribute_category           varchar2,
	p_ass_attribute1                   varchar2,
	p_ass_attribute2                   varchar2,
	p_ass_attribute3                   varchar2,
	p_ass_attribute4                   varchar2,
	p_ass_attribute5                   varchar2,
	p_ass_attribute6                   varchar2,
	p_ass_attribute7                   varchar2,
	p_ass_attribute8                   varchar2,
	p_ass_attribute9                   varchar2,
	p_ass_attribute10                  varchar2,
	p_ass_attribute11                  varchar2,
	p_ass_attribute12                  varchar2,
	p_ass_attribute13                  varchar2,
	p_ass_attribute14                  varchar2,
	p_ass_attribute15                  varchar2,
	p_ass_attribute16                  varchar2,
	p_ass_attribute17                  varchar2,
	p_ass_attribute18                  varchar2,
	p_ass_attribute19                  varchar2,
	p_ass_attribute20                  varchar2,
	p_ass_attribute21                  varchar2,
	p_ass_attribute22                  varchar2,
	p_ass_attribute23                  varchar2,
	p_ass_attribute24                  varchar2,
	p_ass_attribute25                  varchar2,
	p_ass_attribute26                  varchar2,
	p_ass_attribute27                  varchar2,
	p_ass_attribute28                  varchar2,
	p_ass_attribute29                  varchar2,
	p_ass_attribute30                  varchar2,
	p_session_date			   date,
	p_contract_id                      number default null,
	p_cagr_id_flex_num                 number default null,
	p_cagr_grade_def_id                number default null,
	p_establishment_id                 number default null,
	p_collective_agreement_id          number default null,
        p_notice_period			   number   default null,
        p_notice_period_uom		   varchar2 default null,
        p_employee_category		   varchar2 default null,
        p_work_at_home			   varchar2 default null,
        p_job_post_source_name		   varchar2 default null,
        p_grade_ladder_pgm_id		   number   default null,
        p_supervisor_assignment_id         number   default null
     );
-----------------------------------------------------------------------------
--
-- Standard delete procedure
--
procedure delete_row(p_row_id	           varchar2,
		     p_assignment_id       number,
		     p_new_end_date        date,
		     p_effective_end_date  date,
		     p_validation_end_date date,
		     p_session_date	   date,
		     p_delete_mode         varchar2 );
-----------------------------------------------------------------------------
--
-- Standard lock procedure
--
procedure lock_row(
	p_row_id			   varchar2,
	p_assignment_id                    number,
	p_effective_start_date             date,
	p_effective_end_date               date,
	p_business_group_id                number,
	p_recruiter_id                     number,
	p_grade_id                         number,
	p_position_id                      number,
	p_job_id                           number,
	p_assignment_status_type_id        number,
	p_location_id                      number,
	p_person_referred_by_id            number,
	p_supervisor_id                    number,
	p_person_id                        number,
	p_recruitment_activity_id          number,
	p_source_organization_id           number,
	p_organization_id                  number,
	p_people_group_id                  number,
	p_vacancy_id                       number,
	p_assignment_sequence              number,
	p_assignment_type                  varchar2,
	p_primary_flag                     varchar2,
	p_application_id                   number,
	p_change_reason                    varchar2,
	p_comment_id                       number,
	p_date_probation_end               date,
	p_frequency                        varchar2,
	p_manager_flag                     varchar2,
	p_normal_hours                     number,
	p_probation_period                 number,
	p_probation_unit                   varchar2,
	p_source_type                      varchar2,
	p_time_normal_finish               varchar2,
	p_time_normal_start                varchar2,
	p_request_id                       number,
	p_program_application_id           number,
	p_program_id                       number,
	p_program_update_date              date,
	p_ass_attribute_category           varchar2,
	p_ass_attribute1                   varchar2,
	p_ass_attribute2                   varchar2,
	p_ass_attribute3                   varchar2,
	p_ass_attribute4                   varchar2,
	p_ass_attribute5                   varchar2,
	p_ass_attribute6                   varchar2,
	p_ass_attribute7                   varchar2,
	p_ass_attribute8                   varchar2,
	p_ass_attribute9                   varchar2,
	p_ass_attribute10                  varchar2,
	p_ass_attribute11                  varchar2,
	p_ass_attribute12                  varchar2,
	p_ass_attribute13                  varchar2,
	p_ass_attribute14                  varchar2,
	p_ass_attribute15                  varchar2,
	p_ass_attribute16                  varchar2,
	p_ass_attribute17                  varchar2,
	p_ass_attribute18                  varchar2,
	p_ass_attribute19                  varchar2,
	p_ass_attribute20                  varchar2,
	p_ass_attribute21                  varchar2,
	p_ass_attribute22                  varchar2,
	p_ass_attribute23                  varchar2,
	p_ass_attribute24                  varchar2,
	p_ass_attribute25                  varchar2,
	p_ass_attribute26                  varchar2,
	p_ass_attribute27                  varchar2,
	p_ass_attribute28                  varchar2,
	p_ass_attribute29                  varchar2,
	p_ass_attribute30                  varchar2,
	p_contract_id                      number,
	p_cagr_id_flex_num                 number,
	p_cagr_grade_def_id                number,
	p_establishment_id                 number,
	p_collective_agreement_id          number,
        p_notice_period			   number,
        p_notice_period_uom		   varchar2,
        p_employee_category		   varchar2,
        p_work_at_home			   varchar2,
        p_job_post_source_name		   varchar2,
        p_grade_ladder_pgm_id		   number,
        p_supervisor_assignment_id         number
      ) ;
-----------------------------------------------------------------------------
--
-- Standard update procedure
--
procedure update_row(
	p_row_id			   varchar2,
	p_assignment_id                    number,
	p_effective_start_date             date,
	p_effective_end_date               date,
	p_validation_start_date            date,
	p_business_group_id                number,
	p_recruiter_id                     number,
	p_grade_id                         number,
	p_position_id                      number,
	p_job_id                           number,
	p_assignment_status_type_id        number,
	p_per_system_status	           varchar2,
	p_location_id                      number,
	p_location_code                    in out nocopy varchar2,
	p_person_referred_by_id            number,
	p_supervisor_id                    number,
	p_person_id                        number,
	p_recruitment_activity_id          number,
	p_source_organization_id           number,
	p_organization_id                  number,
	p_people_group_id                  number,
	p_vacancy_id                       number,
	p_assignment_sequence              number,
	p_assignment_type                  varchar2,
	p_primary_flag                     varchar2,
	p_application_id                   number,
	p_change_reason                    varchar2,
	p_comment_id                       number,
	p_date_probation_end               date,
	p_frequency                        varchar2,
	p_frequency_meaning                in out nocopy varchar2,
	p_manager_flag                     varchar2,
	p_normal_hours                     number,
	p_probation_period                 number,
	p_probation_unit                   varchar2,
	p_source_type                      varchar2,
	p_time_normal_finish               varchar2,
	p_time_normal_start                varchar2,
	p_request_id                       number,
	p_program_application_id           number,
	p_program_id                       number,
	p_program_update_date              date,
	p_ass_attribute_category           varchar2,
	p_ass_attribute1                   varchar2,
 	p_ass_attribute2                   varchar2,
	p_ass_attribute3                   varchar2,
	p_ass_attribute4                   varchar2,
	p_ass_attribute5                   varchar2,
	p_ass_attribute6                   varchar2,
	p_ass_attribute7                   varchar2,
	p_ass_attribute8                   varchar2,
	p_ass_attribute9                   varchar2,
	p_ass_attribute10                  varchar2,
	p_ass_attribute11                  varchar2,
	p_ass_attribute12                  varchar2,
	p_ass_attribute13                  varchar2,
	p_ass_attribute14                  varchar2,
	p_ass_attribute15                  varchar2,
	p_ass_attribute16                  varchar2,
	p_ass_attribute17                  varchar2,
	p_ass_attribute18                  varchar2,
	p_ass_attribute19                  varchar2,
	p_ass_attribute20                  varchar2,
	p_ass_attribute21                  varchar2,
	p_ass_attribute22                  varchar2,
	p_ass_attribute23                  varchar2,
	p_ass_attribute24                  varchar2,
	p_ass_attribute25                  varchar2,
	p_ass_attribute26                  varchar2,
	p_ass_attribute27                  varchar2,
	p_ass_attribute28                  varchar2,
	p_ass_attribute29                  varchar2,
	p_ass_attribute30                  varchar2,
	p_session_date		           date,
	p_status_changed		   boolean,
	p_contract_id                      number default null,
	p_cagr_id_flex_num                 number default null,
	p_cagr_grade_def_id                number default null,
	p_establishment_id                 number default null,
	p_collective_agreement_id          number default null,
	p_notice_period			   number   default null,
        p_notice_period_uom		   varchar2 default null,
        p_employee_category		   varchar2 default null,
        p_work_at_home			   varchar2 default null,
        p_job_post_source_name		   varchar2 default null,
        p_grade_ladder_pgm_id		   number default null,
        p_supervisor_assignment_id         number   default null,
        p_payroll_id                       number   default null,--Added for Bug 4861490
	p_pay_basis_id			   number   default null --Added for BUg 4861490
        )  ;
----------------------------------------------------------------------
--                      Validation Procedures                      ---
----------------------------------------------------------------------
-- Procedure
--   check_apl_update_allowed
-- Purpose
--   Determines if the assignment refers to a current applicant
--   or an applicant that was subsequently hired. If the assignment
--   is for a current applicant, both updates and corrections are
--   allowed; if the assignment is for an applicant that was
--   later hired, changes are limited to corrections.
--   Used to limit changes of applicant assignment information to
--   active applications or applications of those subsequently hired.
-- Arguments
--   See below
procedure check_apl_update_allowed( p_application_id in number,
                                    p_assignment_id  in number,
                                    p_person_id      in number,
                                    p_status         out nocopy varchar2 );
--
-- Procedure
--   check_apl_end_date
-- Purpose
--   Fails if the end date has been set on the given application.
--   Used to prevent creation of a new assignment when the application
--   has its end date set.
-- Arguments
--   See below
procedure check_apl_end_date ( p_application_id in number ) ;
--
-- Procedure
--   check_current_applicant
-- Purpose
--   Checks whether the given person is (still) a current applicant
--   at the given date
-- Arguments
--   See below
procedure check_current_applicant ( p_person_id    in number,
				    p_session_date in date ) ;
--
--
--
-- Procedure
--   check_valid_status
-- Purpose
--   Checks that the current status is still active
-- Arguments
--   See below
procedure check_valid_asg_status ( p_business_group_id         in number,
				   p_legislation_code          in varchar2,
				   p_assignment_status_type_id in number,
				   p_per_system_status         in varchar2 );
--
--
-- Procedure
--   check_future_stat_change
-- Purpose
--   Checks that there isn't a status of ACTIVE_APL or ACTIVE_ASSIGN
--   at some point
-- Arguments
--   See below
procedure check_future_stat_change ( p_assignment_id in number ) ;
--
-- Procedure
--   check_end_date
-- Purpose
--   Checks whether the assignment has been ended at some point
--   Sets a message so that the user can opt to continue or not.
-- Arguments
--   See below
procedure check_end_date ( p_assignment_id in number,
			   p_warning_set   out nocopy boolean ) ;
--
-- Procedure
--   check_assignment_continuity
-- Purpose
--   Checks that that another assignment exists continuously until the
--   application end date ( or end of time )
-- Arguments
--   See below
procedure check_assignment_continuity ( p_business_group_id in number,
					p_assignment_id     in number,
					p_person_id	    in number,
					p_max_end_date      in date,
					p_session_date	    in date   ) ;
--
-- Procedure
--   process_end_status
-- Purpose
--   Checks that it is ok to set 'TERM_APL' status
--   Calls check_assignment_continuity (above)
--   and   hr_assignment.del_ref_int_check
-- Arguments
--   See below
procedure process_end_status ( p_business_group_id in number,
			       p_assignment_id     in number,
			       p_person_id	   in number,
			       p_max_end_date      in date,
                               p_session_date      in date,
                               p_application_id    in number);

--
-- Procedure
--   rec_act_has_source_type
-- Purpose
--   Checks that the given recruitment activity uses the given
--   source type.
--   Returns TRUE if the source type is used otherwise FALSE
-- Arguments
--   See below
function rec_act_has_source_type ( p_recruitment_activity_id in number,
				   p_source_type             in varchar2 )
				   return boolean ;
--
-- Procedure
--   key_delrec
-- Purpose
--   Checks the given delete mode is ok for the assignment at operation
--   time
-- Arguments
--   See below
procedure key_delrec ( p_business_group_id     in number,
		       p_assignment_id         in number,
		       p_person_id	       in number,
		       p_session_date	       in date,
		       p_validation_start_date in date,
		       p_delete_mode           in varchar2 ) ;
--
-- Procedure
--   pre_delete_validation
-- Purpose
--   Performs pre_delete_validation
-- Arguments
--   See below
procedure pre_delete_validation ( p_business_group_id     in number,
		                  p_assignment_id         in number,
		                  p_application_id        in number,
		                  p_person_id	          in number,
		                  p_session_date	  in date,
		                  p_validation_start_date in date,
		                  p_validation_end_date   in date,
		                  p_delete_mode           in varchar2,
				  p_new_end_date	  in out nocopy date )  ;
--
--
-- Procedure
--   post_delete
-- Purpose
--   Removes related rows after a zap
-- Arguments
--   See below
procedure post_delete ( p_assignment_id 	in number,
			p_validation_start_date in date ) ;

procedure chk_upd_mode ( p_event 		in varchar2,
                         p_object 		in varchar2,
                         p_assignment_id 	in number,
                         p_effective_start_date in date,
			 p_update_mode 		in varchar2,
			 p_record_status 	in varchar2,
			 p_per_system_status 	in varchar2,
			 p_allowed 	       out nocopy varchar2 ) ;

end PER_APP_ASG_PKG ;

 

/
