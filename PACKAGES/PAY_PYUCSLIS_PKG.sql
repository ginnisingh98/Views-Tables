--------------------------------------------------------
--  DDL for Package PAY_PYUCSLIS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PYUCSLIS_PKG" AUTHID CURRENT_USER AS
/* $Header: pyucslis.pkh 120.4.12010000.1 2008/07/27 23:46:52 appldev ship $ */
--
-- Globals to hold concurrent request WHO column information.
--
  p_request_id  		     number(15);
  p_program_application_id	     number(15);
  p_program_id  		     number(15);
  p_update_date                      date;
--
-- -----------------------------------------------------------------------------
-- |-----------------------< add_contacts_for_person >-------------------------|
--
-- Purpose - Procedure to add the contacts (people of SPT OTHER) for this
--           person to the list of visible people in profiles which
--           restrict access to contacts.
-- -----------------------------------------------------------------------------
Procedure add_contacts_for_person
        	(p_person_id		number,
		 p_business_group_id    number,
		 p_generation_scope     varchar2,
   		 p_effective_date	date);

--
-- -----------------------------------------------------------------------------
-- |---------------------< add_unrelated_contacts>-----------------------------|
--
-- Purpose - Procedure to add all unrelated contacts (people of SPT OTHER)
--           to the list of visible people in profiles which
--           restrict access to contacts.
-- -----------------------------------------------------------------------------
Procedure add_unrelated_contacts
	(p_business_group_id    number,
	 p_generation_scope     varchar2,
	 p_effective_date	date);

-- -----------------------------------------------------------------------------
-- |------------------< build_lists_for_user >---------------------------------|
--
-- Purpose - Procedure to allow re-evaluation of security permissions for one
--           user for one particular security profile which is then stored in
--           the internal security tables ready for quick access when they log
--           onto that security profile.
-- WARNING!!!
--           customers have been granted permission to call this
--           procedure DIRECTLY!
--           However as this package (pay_pyucslis_pkg) is a security API
--          (calling hr_security_internal) it cannot be a documented public API.
--           Therefore please *do not* change these parameters as this will
--           invalidate customer code.
-- -----------------------------------------------------------------------------
Procedure build_lists_for_user
        (p_security_profile_id number,
         p_user_id number,
         p_effective_date date default trunc(sysdate));
-- |--------------------< generate lists >-------------------------------------|
--
-- Purpose - Called from the PYUCSL.sql script when LISTGEN and GLISTGEN
--           processes are submitted. This routine is provided for backwards
--           compatibility only.
--
-- -----------------------------------------------------------------------------
--
  PROCEDURE generate_lists
  (p_effective_date        IN DATE
  ,p_security_profile_name IN VARCHAR2 DEFAULT 'ALL_SECURITY_PROFILES'
  ,p_business_group_mode   IN VARCHAR2 DEFAULT 'LOCAL'
  );
--
-- -----------------------------------------------------------------------------
-- |--------------------< generate lists >-------------------------------------|
--
-- Purpose - This routine is called when generating security list information
--           for a single profile or when an HR foundation installation runs
--           SLM.
--
-- -----------------------------------------------------------------------------
--
  PROCEDURE generate_lists
  (p_effective_date         IN DATE
  ,p_generation_scope       IN VARCHAR2
  ,p_business_group_id      IN NUMBER   default null
  ,p_security_profile_id    IN NUMBER   default null
  ,p_security_profile_name  IN VARCHAR2 default null
  ,p_who_to_process         IN VARCHAR2 default null
  ,p_user_id                IN NUMBER   default null
  ,p_static_user_processing IN VARCHAR2 default 'ALL_STATIC'
  );

--
-- ----------------------------------------------------------------------------
-- |-------------------------< submit_security >------------------------------|
--
-- Purpose - Called on submission of the SLM process. Simply an entry point
--           to the process and calls generate_list_control.
--
-- ----------------------------------------------------------------------------
--
procedure submit_security(errbuf  out        NOCOPY   varchar2,
                          retcode out        NOCOPY   number,
                          p_effective_date            varchar2 default null,
                          p_generation_scope          varchar2 default null,
                          p_business_group_id         varchar2 default null,
                          p_security_profile_id       varchar2 default null,
		          p_who_to_process            varchar2 default null,
		          p_action_parameter_group_id varchar2 default null,
		          p_user_name                 varchar2 default null,
			  p_static_user_processing    varchar2 default 'ALL_STATIC');
--
-- -----------------------------------------------------------------------------
-- |--------------------< generate list_control >------------------------------|
--
-- Purpose - Called from the submit_security when the security list maintenance
--           process is submitted. It controls the execution of the list
--           information code. For full HR customers it submits a request to
--           use PYUGEN for the generation of the PPL.
--           This process is re-submitted when the sub-requests are complete
--           to complete the processing.
--
-- -----------------------------------------------------------------------------
--
  procedure generate_list_control(p_effective_date      date,
                            p_generation_scope          varchar2,
	  			            p_business_group_id         varchar2 default null,
				            p_security_profile_id       varchar2 default null,
		                    p_who_to_process            varchar2 default null,
		                    p_action_parameter_group_id varchar2 default null,
					        p_user_id                   varchar2 default null,
					        p_static_user_processing    varchar2 default 'ALL_STATIC',
							errbuf           out NOCOPY varchar2,
             	            retcode          out NOCOPY number);
--
-- -----------------------------------------------------------------------------
-- |----------------------< range_cursor >-------------------------------------|
--
-- Purpose - This routine is called from PYUGEN. It returns a SQL select used
--           to identify the people who need to be processed.
--
-- -----------------------------------------------------------------------------
--
  procedure range_cursor (pactid in 	    number,
                          sqlstr out NOCOPY varchar2);
--
-- -----------------------------------------------------------------------------
-- |--------------------< action_creation >------------------------------------|
--
-- Purpose - This routine is called to create assignment actions for each
--           person to be processed by PYUGEN.
--
-- -----------------------------------------------------------------------------
--
  procedure action_creation (pactid    in number,
                             stperson  in number,
			     endperson in number,
			     chunk     in number);
--
-- -----------------------------------------------------------------------------
-- |----------------------< archive_data >-------------------------------------|
--
-- Purpose - This routine is called to process each assignment action and
--           generate security access for the person concerned.
--
-- -----------------------------------------------------------------------------
--
  procedure archive_data(p_assactid       in number,
                         p_effective_date in date);
--
-- ----------------------------------------------------------------------------
-- |---------------------------< initialization >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Purpose : This process is called for each slave process to perform
--           standard initialization.
--
-- Notes :
--
procedure initialization(p_payroll_action_id in number);
--
-- -----------------------------------------------------------------------------
-- |--------------------< chk_person_in_profile >------------------------------|
--
-- Purpose - A checking routine indicating if the person is in the profile.
--           Used for testing purposes.
--
-- -----------------------------------------------------------------------------
--
  function chk_person_in_profile (p_person_id in        number,
                                  p_security_profile_id number)
  return varchar2;

--
-- ----------------------------------------------------------------------------
-- |---------------------< process_person >------------------------------------|
--
-- Purpose - Process security code for all assignments for specific person.
--
-- ----------------------------------------------------------------------------
--
  procedure process_person (p_person_id         per_all_people_f.person_id%TYPE,
                            p_effective_date    date,
			    p_business_group_id number,
			    p_generation_scope  varchar2,
			    p_who_to_process    varchar2);
--
-- ----------------------------------------------------------------------------
-- |-----------------------< submit_cand_sec_opt >----------------------------|
--
-- Purpose - This PL/SQL procedure is for the concurrent program
--           'Change Candidate Access for Security Profiles'.
--           This process will take only one parameter, values are either
--           'Y -> All' or 'X -> None'. Default value for the parameter
--           p_profile_option will be 'X' (None).
--
--           None -> Candidates will not be visible to that security profile
--           All  -> Candidates will be visible to that security profile.
--
--           This process is intended for customer's those installed
--           iRecruitment. The default value for the view_all_candidates_flag
--           in per_security_profiles is 'Y'. Customer's can change that
--           option by running this process in one go.
--
-- Pre-Req - This process will run only if the iRecruitment is installed.
-- ----------------------------------------------------------------------------
--
procedure submit_cand_sec_opt(
          errbuf            out nocopy varchar2,
          retcode           out nocopy number,
          p_profile_option  in  varchar2
          );
--
END pay_pyucslis_pkg;


/
