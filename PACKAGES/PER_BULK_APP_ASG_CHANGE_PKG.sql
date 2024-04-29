--------------------------------------------------------
--  DDL for Package PER_BULK_APP_ASG_CHANGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_BULK_APP_ASG_CHANGE_PKG" AUTHID CURRENT_USER AS
/* $Header: peasg03t.pkh 115.3 2003/01/15 19:08:40 asahay ship $ */
-- Name
--   get_db_defaults
-- Purpose
--   Retrieve database default values needed at form startup
-- Arguments
--   p_business_group_id
--   p_grade_structure           -- bg structure id
--   p_people_group_structure    -- bg structure id
--   p_job_structure             -- bg structure id
--   p_postion_structure         -- bg structure id
   procedure get_db_defaults ( p_business_group_id      in number,
	                       p_grade_structure        in out nocopy number,
	                       p_people_group_structure in out nocopy number,
	                       p_job_structure          in out nocopy number,
	                       p_position_structure     in out nocopy number ) ;
--
-- Name
--   validate_asg_change
-- Purpose
--   Validates a change to an applicant assignment
--   The change can be one of the following :
--        Assignment Status
--        Recruiter
--   Will raise an error and set message if the change is disallowed.
--
-- Parameters
--   p_application_id
--   p_person_id
--   p_assignment_id
--   p_status_changed                  Has the status changed.
--   p_new_system_status	       e.g. TERM_APL
--   p_new_asg_status_type_id
--   p_recruiter_id
--   p_dt_update_mode		       DateTrack Update mode ie UPDATE
--				       or correction
--   p_business_group_id
--
--  Notes
--
   procedure validate_asg_change ( p_application_id         in number,
			           p_person_id              in number,
			           p_assignment_id          in number,
			           p_status_changed 	    in boolean,
			           p_new_system_status      in varchar2,
			           p_new_asg_status_type_id in number,
			           p_recruiter_id           in number,
				   p_dt_update_mode         in varchar2,
				   p_business_group_id      in number) ;
--
-- Name
--   update_row
-- Purpose
--   Updates the given applicant assignment row.
--   The change can be one of the following :
--        Assignment Status
--        Recruiter
--   Will raise an error and set message if the change is disallowed.
--
-- Parameters
--   p_application_id
--   p_person_id
--   p_assignment_id
--   p_status_changed
--   p_new_system_status	       e.g. TERM_APL
--   p_new_asg_status_type_id
--   p_recruiter_id
--   p_dt_update_mode		       DateTrack Update mode ie UPDATE
--				       or correction
--   p_effective_date                  Session Date
--   p_effective_start_date            Effective Start of Row to be updated.
--   p_validation_start_date	       DateTrack Validation Start Date
--   p_business_group_id
--
--  Notes
--   Calls validate_asg_change before performing the update.
--   Datetrack handles the creation of the extra row for UPDATE mode.
   procedure update_row ( p_rowid                  in varchar2,
			  p_application_id         in number,
			  p_person_id              in number,
			  p_assignment_id          in number,
			  p_status_changed 	   in boolean,
			  p_new_system_status      in varchar2,
			  p_new_asg_status_type_id in number,
			  p_recruiter_id           in number,
			  p_dt_update_mode         in varchar2,
			  p_effective_date         in date,
			  p_effective_start_date   in date,
			  p_validation_start_date  in date,
			  p_business_group_id	   in number) ;
--
END PER_BULK_APP_ASG_CHANGE_PKG ;

 

/
