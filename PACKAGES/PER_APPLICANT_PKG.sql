--------------------------------------------------------
--  DDL for Package PER_APPLICANT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_APPLICANT_PKG" AUTHID CURRENT_USER as
/* $Header: peper02t.pkh 120.0.12010000.2 2009/07/21 13:38:46 sidsaxen ship $ */

--
procedure insert_row ( p_rowid in out nocopy varchar2
,p_business_group_id NUMBER
,p_person_type_id              in out nocopy NUMBER
,p_person_id 		       in out nocopy NUMBER
,p_effective_start_date DATE
,p_effective_end_date DATE
,p_last_name VARCHAR2
,p_first_name VARCHAR2
,p_title VARCHAR2
,p_full_name VARCHAR2
,p_sex VARCHAR2
,p_work_telephone VARCHAR2
,p_applicant_number 		in out nocopy VARCHAR2
,p_assignment_status_type_id NUMBER
,p_request_id NUMBER
,p_program_application_id NUMBER
,p_program_id NUMBER
,p_program_update_date DATE
,p_attribute_category VARCHAR2
,p_attribute1 VARCHAR2
,p_attribute2 VARCHAR2
,p_attribute3 VARCHAR2
,p_attribute4 VARCHAR2
,p_attribute5 VARCHAR2
,p_attribute6 VARCHAR2
,p_attribute7 VARCHAR2
,p_attribute8 VARCHAR2
,p_attribute9 VARCHAR2
,p_attribute10 VARCHAR2
,p_attribute11 VARCHAR2
,p_attribute12 VARCHAR2
,p_attribute13 VARCHAR2
,p_attribute14 VARCHAR2
,p_attribute15 VARCHAR2
,p_attribute16 VARCHAR2
,p_attribute17 VARCHAR2
,p_attribute18 VARCHAR2
,p_attribute19 VARCHAR2
,p_attribute20 VARCHAR2
,p_attribute21 VARCHAR2
,p_attribute22 VARCHAR2
,p_attribute23 VARCHAR2
,p_attribute24 VARCHAR2
,p_attribute25 VARCHAR2
,p_attribute26 VARCHAR2
,p_attribute27 VARCHAR2
,p_attribute28 VARCHAR2
,p_attribute29 VARCHAR2
,p_attribute30 VARCHAR2
,p_per_information_category VARCHAR2
,p_per_information1 VARCHAR2
,p_per_information2 VARCHAR2
,p_per_information3 VARCHAR2
,p_per_information4 VARCHAR2
,p_per_information5 VARCHAR2
,p_per_information6 VARCHAR2
,p_per_information7 VARCHAR2
,p_per_information8 VARCHAR2
,p_per_information9 VARCHAR2
,p_per_information10 VARCHAR2
,p_per_information11 VARCHAR2
,p_per_information12 VARCHAR2
,p_per_information13 VARCHAR2
,p_per_information14 VARCHAR2
,p_per_information15 VARCHAR2
,p_per_information16 VARCHAR2
,p_per_information17 VARCHAR2
,p_per_information18 VARCHAR2
,p_per_information19 VARCHAR2
,p_per_information20 VARCHAR2
,p_per_information21 VARCHAR2
,p_per_information22 VARCHAR2
,p_per_information23 VARCHAR2
,p_per_information24 VARCHAR2
,p_per_information25 VARCHAR2
,p_per_information26 VARCHAR2
,p_per_information27 VARCHAR2
,p_per_information28 VARCHAR2
,p_per_information29 VARCHAR2
,p_per_information30 VARCHAR2
,p_style VARCHAR2
,p_address_line1 VARCHAR2
,p_address_line2 VARCHAR2
,p_address_line3 VARCHAR2
,p_address_type VARCHAR2
,p_country VARCHAR2
,p_postal_code VARCHAR2
,p_region_1 VARCHAR2
,p_region_2 VARCHAR2
,p_region_3 VARCHAR2
,p_telephone_number_1 VARCHAR2
,p_telephone_number_2 VARCHAR2
,p_telephone_number_3 VARCHAR2
,p_town_or_city VARCHAR2
,p_addr_attribute_category VARCHAR2
,p_addr_attribute1 VARCHAR2
,p_addr_attribute2 VARCHAR2
,p_addr_attribute3 VARCHAR2
,p_addr_attribute4 VARCHAR2
,p_addr_attribute5 VARCHAR2
,p_addr_attribute6 VARCHAR2
,p_addr_attribute7 VARCHAR2
,p_addr_attribute8 VARCHAR2
,p_addr_attribute9 VARCHAR2
,p_addr_attribute10 VARCHAR2
,p_addr_attribute11 VARCHAR2
,p_addr_attribute12 VARCHAR2
,p_addr_attribute13 VARCHAR2
,p_addr_attribute14 VARCHAR2
,p_addr_attribute15 VARCHAR2
,p_addr_attribute16 VARCHAR2
,p_addr_attribute17 VARCHAR2
,p_addr_attribute18 VARCHAR2
,p_addr_attribute19 VARCHAR2
,p_addr_attribute20 VARCHAR2
-- ***** Start new code for bug 2711964 **************
,p_add_information13           VARCHAR2
,p_add_information14           VARCHAR2
,p_add_information15           VARCHAR2
,p_add_information16           VARCHAR2
,p_add_information17           VARCHAR2
,p_add_information18           VARCHAR2
,p_add_information19           VARCHAR2
,p_add_information20           VARCHAR2
-- ***** End new code for bug 2711964 ***************
,p_date_received DATE
,p_current_employer VARCHAR2
,p_appl_attribute_category VARCHAR2
,p_appl_attribute1 VARCHAR2
,p_appl_attribute2 VARCHAR2
,p_appl_attribute3 VARCHAR2
,p_appl_attribute4 VARCHAR2
,p_appl_attribute5 VARCHAR2
,p_appl_attribute6 VARCHAR2
,p_appl_attribute7 VARCHAR2
,p_appl_attribute8 VARCHAR2
,p_appl_attribute9 VARCHAR2
,p_appl_attribute10 VARCHAR2
,p_appl_attribute11 VARCHAR2
,p_appl_attribute12 VARCHAR2
,p_appl_attribute13 VARCHAR2
,p_appl_attribute14 VARCHAR2
,p_appl_attribute15 VARCHAR2
,p_appl_attribute16 VARCHAR2
,p_appl_attribute17 VARCHAR2
,p_appl_attribute18 VARCHAR2
,p_appl_attribute19 VARCHAR2
,p_appl_attribute20 VARCHAR2
,p_recruitment_activity_id NUMBER
,p_source_organization_id NUMBER
,p_person_referred_by_id NUMBER
,p_vacancy_id NUMBER
,p_recruiter_id NUMBER
,p_organization_id NUMBER
,p_people_group_id NUMBER
,p_people_group_name VARCHAR2
,p_job_id NUMBER
,p_position_id NUMBER
,p_grade_id NUMBER
,p_location_id NUMBER
,p_location_code                 in out nocopy  VARCHAR2
,p_source_type VARCHAR2
,p_ass_attribute_category VARCHAR2
,p_ass_attribute1 VARCHAR2
,p_ass_attribute2 VARCHAR2
,p_ass_attribute3 VARCHAR2
,p_ass_attribute4 VARCHAR2
,p_ass_attribute5 VARCHAR2
,p_ass_attribute6 VARCHAR2
,p_ass_attribute7 VARCHAR2
,p_ass_attribute8 VARCHAR2
,p_ass_attribute9 VARCHAR2
,p_ass_attribute10 VARCHAR2
,p_ass_attribute11 VARCHAR2
,p_ass_attribute12 VARCHAR2
,p_ass_attribute13 VARCHAR2
,p_ass_attribute14 VARCHAR2
,p_ass_attribute15 VARCHAR2
,p_ass_attribute16 VARCHAR2
,p_ass_attribute17 VARCHAR2
,p_ass_attribute18 VARCHAR2
,p_ass_attribute19 VARCHAR2
,p_ass_attribute20 VARCHAR2
,p_ass_attribute21 VARCHAR2
,p_ass_attribute22 VARCHAR2
,p_ass_attribute23 VARCHAR2
,p_ass_attribute24 VARCHAR2
,p_ass_attribute25 VARCHAR2
,p_ass_attribute26 VARCHAR2
,p_ass_attribute27 VARCHAR2
,p_ass_attribute28 VARCHAR2
,p_ass_attribute29 VARCHAR2
,p_ass_attribute30 VARCHAR2
,p_per_system_status VARCHAR2
,p_address_set       BOOLEAN     -- Indicates that an address has been entered
,p_method_of_apl_num_gen VARCHAR2
,p_party_id NUMBER default NULL
,p_date_of_birth        DATE default NULL
,p_known_as             VARCHAR2 default NULL
,p_marital_status       VARCHAR2 default NULL
,p_middle_names         VARCHAR2 default NULL
,p_nationality          VARCHAR2 default NULL
,p_blood_type            VARCHAR2 default NULL
,p_correspondence_language VARCHAR2 default NULL
,p_honors                 VARCHAR2 default NULL
,p_pre_name_adjunct       VARCHAR2 default NULL
,p_rehire_authorizor      VARCHAR2 default NULL
,p_rehire_recommendation  VARCHAR2 default NULL
,p_resume_exists          VARCHAR2 default NULL
,p_resume_last_updated    DATE default NULL
,p_second_passport_exists VARCHAR2 default NULL
,p_student_status     VARCHAR2 default NULL
,p_suffix             VARCHAR2 default NULL
,p_date_of_death      DATE default NULL
,p_uses_tobacco_flag  VARCHAR2 default NULL
,p_town_of_birth      VARCHAR2 default NULL
,p_region_of_birth    VARCHAR2 default NULL
,p_country_of_birth   VARCHAR2 default NULL
,p_fast_path_employee VARCHAR2 default NULL
,p_email_address   VARCHAR2 default NULL
,p_fte_capacity    VARCHAR2 default NULL
,p_national_identifier VARCHAR2 default NULL);
--
-- Name
--   lock_row
-- Purpose
--   Attemps to lock the person row
--   Only the person fields are compared. Calls the person package lock
--   row procedure
-- Arguments
--
procedure lock_row(p_rowid VARCHAR2
   ,p_person_id NUMBER
   ,p_effective_start_date DATE
   ,p_effective_end_date DATE
   ,p_business_group_id NUMBER
   ,p_person_type_id NUMBER
   ,p_last_name VARCHAR2
   ,p_start_date DATE
   ,p_applicant_number VARCHAR2
   ,p_comment_id NUMBER
   ,p_current_applicant_flag VARCHAR2
   ,p_current_emp_or_apl_flag VARCHAR2
   ,p_current_employee_flag VARCHAR2
   ,p_date_employee_data_verified DATE
   ,p_date_of_birth DATE
   ,p_email_address VARCHAR2
   ,p_employee_number VARCHAR2
   ,p_expense_check_send_to_addr VARCHAR2
   ,p_first_name VARCHAR2
   ,p_full_name VARCHAR2
   ,p_known_as  VARCHAR2
   ,p_marital_status VARCHAR2
   ,p_middle_names  VARCHAR2
   ,p_nationality VARCHAR2
   ,p_national_identifier VARCHAR2
   ,p_previous_last_name VARCHAR2
   ,p_registered_disabled_flag VARCHAR2
   ,p_sex VARCHAR2
   ,p_title VARCHAR2
   ,p_vendor_id NUMBER
   ,p_work_telephone VARCHAR2
   ,p_attribute_category VARCHAR2
   ,p_attribute1 VARCHAR2
   ,p_attribute2 VARCHAR2
   ,p_attribute3 VARCHAR2
   ,p_attribute4 VARCHAR2
   ,p_attribute5 VARCHAR2
   ,p_attribute6 VARCHAR2
   ,p_attribute7 VARCHAR2
   ,p_attribute8 VARCHAR2
   ,p_attribute9 VARCHAR2
   ,p_attribute10 VARCHAR2
   ,p_attribute11 VARCHAR2
   ,p_attribute12 VARCHAR2
   ,p_attribute13 VARCHAR2
   ,p_attribute14 VARCHAR2
   ,p_attribute15 VARCHAR2
   ,p_attribute16 VARCHAR2
   ,p_attribute17 VARCHAR2
   ,p_attribute18 VARCHAR2
   ,p_attribute19 VARCHAR2
   ,p_attribute20 VARCHAR2
   ,p_attribute21 VARCHAR2
   ,p_attribute22 VARCHAR2
   ,p_attribute23 VARCHAR2
   ,p_attribute24 VARCHAR2
   ,p_attribute25 VARCHAR2
   ,p_attribute26 VARCHAR2
   ,p_attribute27 VARCHAR2
   ,p_attribute28 VARCHAR2
   ,p_attribute29 VARCHAR2
   ,p_attribute30 VARCHAR2
   ,p_per_information_category VARCHAR2
   ,p_per_information1 VARCHAR2
   ,p_per_information2 VARCHAR2
   ,p_per_information3 VARCHAR2
   ,p_per_information4 VARCHAR2
   ,p_per_information5 VARCHAR2
   ,p_per_information6 VARCHAR2
   ,p_per_information7 VARCHAR2
   ,p_per_information8 VARCHAR2
   ,p_per_information9 VARCHAR2
   ,p_per_information10 VARCHAR2
   ,p_per_information11 VARCHAR2
   ,p_per_information12 VARCHAR2
   ,p_per_information13 VARCHAR2
   ,p_per_information14 VARCHAR2
   ,p_per_information15 VARCHAR2
   ,p_per_information16 VARCHAR2
   ,p_per_information17 VARCHAR2
   ,p_per_information18 VARCHAR2
   ,p_per_information19 VARCHAR2
   ,p_per_information20 VARCHAR2
   ,p_per_information21 VARCHAR2
   ,p_per_information22 VARCHAR2
   ,p_per_information23 VARCHAR2
   ,p_per_information24 VARCHAR2
   ,p_per_information25 VARCHAR2
   ,p_per_information26 VARCHAR2
   ,p_per_information27 VARCHAR2
   ,p_per_information28 VARCHAR2
   ,p_per_information29 VARCHAR2
   ,p_per_information30 VARCHAR2) ;
--
-- Fix for 3908271 starts here.
--
-- Name
--   delete_row
-- Purpose
--   Validates delete and then calls hr_person.applicant_default_deletes
-- Arguments
--   See below
--procedure delete_row ( p_person_id    in number,
--		       p_session_date in date  ) ;
--
-- Fix for 3908271 ends here.
--
--
-- Name
--   get_location_code
-- Purpose
--   Retrieve the location code for the given location id
-- Arguments
--   See below
function get_location_code ( p_location_id in number ) return varchar2 ;
--
-- Name
--   get_db_default_values (overloaded)
-- Purpose
--   Retrieves the default values used by the form
--   These are
--         Business Group Defaults
--         Default Assignment Status
--         Territory Short Name
-- Arguments
--   See below
-- Notes
procedure get_db_default_values (  p_business_group_id      in number ,
				   p_legislation_code       in varchar2,
				   p_bg_name		    in out nocopy varchar2,
				   p_bg_location_id	    in out nocopy number,
				   p_bg_working_hours	    in out nocopy number,
				   p_bg_frequency	    in out nocopy varchar2,
				   p_bg_default_start_time  in out nocopy varchar2,
				   p_bg_default_end_time    in out nocopy varchar2,
				   p_system_person_type	    in out nocopy varchar2,
				   p_person_type_id	    in out nocopy number,
				   p_ass_status_type_id     in out nocopy number,
				   p_ass_status_type_desc   in out nocopy varchar2,
				   p_ass_per_system_status  in out nocopy varchar2,
				   p_country_meaning        in out nocopy varchar2,
				   p_default_yes_desc       in out nocopy varchar2,
				   p_default_no_desc        in out nocopy varchar2,
				   p_people_group_structure in out nocopy varchar2,
				   p_method_of_apl_gen      in out nocopy varchar2);
--
-- Name
--   get_db_default_values
-- Purpose
--   Retrieves the default values used by the form
--   These are
--         Business Group Defaults
--         Default Assignment Status
--         Territory Short Name
-- Arguments
--   See below
-- Notes
procedure get_db_default_values (  p_business_group_id      in number ,
				   p_legislation_code       in varchar2,
				   p_bg_name		    in out nocopy varchar2,
				   p_bg_location_id	    in out nocopy number,
				   p_bg_working_hours	    in out nocopy number,
				   p_bg_frequency	    in out nocopy varchar2,
				   p_bg_default_start_time  in out nocopy varchar2,
				   p_bg_default_end_time    in out nocopy varchar2,
				   p_system_person_type	    in out nocopy varchar2,
				   p_person_type_id	    in out nocopy number,
				   p_ass_status_type_id     in out nocopy number,
				   p_ass_status_type_desc   in out nocopy varchar2,
				   p_ass_per_system_status  in out nocopy varchar2,
				   p_country_meaning        in out nocopy varchar2,
				   p_default_yes_desc       in out nocopy varchar2,
				   p_default_no_desc        in out nocopy varchar2,
				   p_people_group_structure in out nocopy varchar2,
				   p_method_of_apl_gen      in out nocopy varchar2,
				   p_style                  in out nocopy varchar2);
--
-- Name
--   vacancy_in_activity
-- Purpose
--   Determines whether the the given vacancy_id is in the given
--   recruitment activity.
--   Returns TRUE if it is and FALSE otherwise.
-- Arguments
--   See below
-- Notes
function vacancy_in_activity ( p_recruitment_activity_id in number,
			       p_vacancy_id              in number )return boolean ;
--
-- Name
--   uniq_vac_for_rec_act
-- Purpose
--  Returns the vacancy_id for the given recruitment activity if there
--  is a unique one on the given date
--  Otherwise returns NULL
-- Arguments
--   See below
-- Notes
function uniq_vac_for_rec_act ( p_recruitment_activity_id in number ,
				p_date_received           in date )
			      return number ;
--
-- Name
--   get_vacancy_details
-- Purpose
--   Returns all of the details for a given vacancy
-- Arguments
--   See below
-- ***TEMP Should ideally use out variables
-- Notes
-- If a p_vacancy_name is not null then the other id fields are also assumed
-- to have been supplied.
procedure get_vacancy_details ( p_vacancy_id      in number,
				p_vacancy_name    in out nocopy varchar2,
				p_recruiter_id    in out nocopy number,
				p_recruiter_name  in out nocopy varchar2,
				p_org_id	  in out nocopy number,
				p_org_name	  in out nocopy varchar2,
				p_people_group_id in out nocopy number,
				p_job_id	  in out nocopy number,
				p_job_name	  in out nocopy varchar2,
				p_pos_id	  in out nocopy number,
				p_pos_name	  in out nocopy varchar2,
				p_grade_id	  in out nocopy number,
				p_grade_name	  in out nocopy varchar2,
				p_location_id     in out nocopy number,
				p_location_code   in out nocopy varchar2,
                                p_recruiter_number in out nocopy varchar2,
                                --Start changes for bug 8678206
                                p_manager_id       in out nocopy number,
                                p_manager_name     in out nocopy varchar2,
                                p_manager_number   in out nocopy varchar2) ;

--
-- Provide overloaded version of get_vacancy_details to prevent other
-- forms/packages breaking due to new argument added in previous
-- version.
--
procedure get_vacancy_details ( p_vacancy_id      in number,
                                p_vacancy_name    in out nocopy varchar2,
                                p_recruiter_id    in out nocopy number,
                                p_recruiter_name  in out nocopy varchar2,
                                p_org_id          in out nocopy number,
                                p_org_name        in out nocopy varchar2,
                                p_people_group_id in out nocopy number,
                                p_job_id          in out nocopy number,
                                p_job_name        in out nocopy varchar2,
                                p_pos_id          in out nocopy number,
                                p_pos_name        in out nocopy varchar2,
                                p_grade_id        in out nocopy number,
                                p_grade_name      in out nocopy varchar2,
                                p_location_id     in out nocopy number,
                                p_location_code   in out nocopy varchar2,
                                p_recruiter_number in out nocopy varchar2 ) ;
--End changes for bug 8678206

--
-- Provide overloaded version of get_vacancy_details to prevent other
-- forms/packages breaking due to new argument added in previous
-- version.
--
procedure get_vacancy_details ( p_vacancy_id      in number,
                                p_vacancy_name    in out nocopy varchar2,
                                p_recruiter_id    in out nocopy number,
                                p_recruiter_name  in out nocopy varchar2,
                                p_org_id          in out nocopy number,
                                p_org_name        in out nocopy varchar2,
                                p_people_group_id in out nocopy number,
                                p_job_id          in out nocopy number,
                                p_job_name        in out nocopy varchar2,
                                p_pos_id          in out nocopy number,
                                p_pos_name        in out nocopy varchar2,
                                p_grade_id        in out nocopy number,
                                p_grade_name      in out nocopy varchar2,
                                p_location_id     in out nocopy number,
                                p_location_code   in out nocopy varchar2) ;
--
-- Name
--   set_vac_from_rec_act
-- Purpose
--   Sets the vacancy details for a given recruitment activity
--   If there is a unique vacancy for the recruitment activity at the
--   given date then the vacancy details are retrieved.
-- Arguments
--   See below
-- ***TEMP Should ideally use out variables
procedure set_vac_from_rec_act ( p_recruitment_activity_id in number,
                                 p_date_received           in date,
                                 p_vacancy_id      	   in out nocopy number,
			 	 p_vacancy_name            in out nocopy varchar2,
				 p_recruiter_id    	   in out nocopy number,
				 p_recruiter_name  	   in out nocopy varchar2,
				 p_org_id	  	   in out nocopy number,
				 p_org_name	  	   in out nocopy varchar2,
				 p_people_group_id 	   in out nocopy number,
				 p_job_id	  	   in out nocopy number,
				 p_job_name	  	   in out nocopy varchar2,
				 p_pos_id	  	   in out nocopy number,
				 p_pos_name	  	   in out nocopy varchar2,
				 p_grade_id	  	   in out nocopy number,
				 p_grade_name	  	   in out nocopy varchar2,
				 p_location_id     	   in out nocopy number,
				 p_location_code   	   in out nocopy varchar2,
                                 -- Start changes for bug 8678206
                                 p_manager_id              in out nocopy number,
                                 p_manager_name            in out nocopy varchar2,
                                 p_manager_number          in out nocopy varchar2) ;
--
-- Provide overloaded version of set_vac_from_rec_act to prevent other
-- forms/packages breaking due to new argument added in previous
-- version.
--
procedure set_vac_from_rec_act ( p_recruitment_activity_id in number,
                                 p_date_received           in date,
                                 p_vacancy_id      	   in out nocopy number,
			 	 p_vacancy_name            in out nocopy varchar2,
				 p_recruiter_id    	   in out nocopy number,
				 p_recruiter_name  	   in out nocopy varchar2,
				 p_org_id	  	   in out nocopy number,
				 p_org_name	  	   in out nocopy varchar2,
				 p_people_group_id 	   in out nocopy number,
				 p_job_id	  	   in out nocopy number,
				 p_job_name	  	   in out nocopy varchar2,
				 p_pos_id	  	   in out nocopy number,
				 p_pos_name	  	   in out nocopy varchar2,
				 p_grade_id	  	   in out nocopy number,
				 p_grade_name	  	   in out nocopy varchar2,
				 p_location_id     	   in out nocopy number,
				 p_location_code   	   in out nocopy varchar2 ) ;
-- End changes for bug 8678206

--
-- Name
--   chk_job_org_pos_comb
-- Purpose
--   Checks that the given combination of job , organization and position is
--   valid.
--   Returns TRUE if the combination is valid otherwise FALSE.
-- Arguments
--   See below
function chk_job_org_pos_comb ( p_job_id        in number,
				p_org_id        in number,
				p_pos_id        in number,
				p_date_received in date    ) return boolean ;
--
-- Name
--   update_group
-- Purpose
--   Updates the group keyflex combinations table
-- Arguments
--   See below
-- Notes
--  Code taken from PER_ASSIGNMENTS_F_PACKAGE
procedure update_group( p_pg_id         number,
			p_group_name    varchar2) ;
--
--
-- Name
--   exists_val_grd_for_pos_and_job
-- Purpose
--   Checks that there is a valid grade set up for either the job or position
--   at the given date.
--   If there valid grades for the position then the corresponing output
--   variable is set to TRUE otherwise it is FALSE
--   If there valid grades for the job then the corresponing output
--   variable is set to TRUE otherwise it is FALSE
-- Arguments
--   See below
procedure exists_val_grd_for_pos_and_job ( p_business_group_id  in number,
					   p_date_received      in date,
					   p_job_id             in number,
					   p_exists_grd_for_job out nocopy boolean,
					   p_pos_id             in number,
					   p_exists_grd_for_pos out nocopy boolean );

--
-- Name
--   check_apl_num_unique ***OBSOLETE
-- Purpose
--   Checks that the given application number is unique for the person
--   within the given business group.
--   This procedure should only be called if the method of number generation
--   is not automatic
procedure check_apl_num_unique( p_business_group_id in number,
			        p_applicant_number  in number ) ;
--
-- Name
--   check_delete_allowed
-- Purpose
--   Checks delete is allowed.  In addition to calling the standard
--   pre delete validation procedure this procedure also checks that there
--   is only a single person and a single address record for the person.
-- Arguments
--   See below
procedure check_delete_allowed ( p_person_id    in number,
				 p_session_date in date )  ;
--
--
-- Name
--   create_default_budget_values
-- Purpose
--   Creates a default set of budget values for an assignment
procedure create_default_budget_values ( p_business_group_id    in number,
					 p_assignment_id        in number,
					 p_effective_start_date in date,
					 p_effective_end_date   in date);
--
-- Name
--  check_for_letter_requests
-- Purpose
--  Create a letter request if there is no entry pending for the
--  particular letter type required.
--
procedure check_for_letter_requests ( p_business_group_id         in number,
				      p_per_system_status         in varchar2,
				      p_assignment_status_type_id in number,
				      p_person_id	          in number,
				      p_assignment_id             in number,
				      p_effective_start_date      in date,
				      p_validation_start_date     in date,
				      p_vacancy_id		  in number );
--
-- Name
--  pre_update
-- Purpose
--  Used in PERWSAPA to perform referential integrity checks at pre update
--  time.
--  Checks that if the date received has changed that it is valid
procedure pre_update ( p_rowid              in varchar2,
		       p_person_id	    in number,
		       p_business_group_id  in number,
		       p_date_received      in date,
		       p_old_date_received  in out nocopy date ) ;
--
-- Name
--  get_territory_short_name
-- Purpose
--  Retrieve the territory_short_name for a given territory_code
function get_territory_short_name ( p_territory_code in varchar2 )
    return varchar2 ;
pragma restrict_references (get_territory_short_name, WNPS, WNDS, RNPS);
--
-- Function get_style_name
--
function get_style_name (p_style in varchar2)
    return varchar2 ;
pragma restrict_references (get_style_name, WNPS, WNDS, RNPS);
--
end PER_APPLICANT_PKG ;

/
