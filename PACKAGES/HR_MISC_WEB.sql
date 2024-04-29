--------------------------------------------------------
--  DDL for Package HR_MISC_WEB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_MISC_WEB" AUTHID CURRENT_USER AS
/* $Header: hrmscmnw.pkh 120.1 2005/09/23 15:05:34 svittal noship $*/

  -- Global Variables.
  gv_IMAGE_DIR        CONSTANT  VARCHAR2(50)    := '/OA_MEDIA/';
  gv_HTML_DIR         CONSTANT  VARCHAR2(50)    := '/OA_HTML/';
  gv_MEE_CSS_FILE     CONSTANT  VARCHAR2(50)    :=
                                           'webtools/images/cabo_styles.css';
  gv_MEE_JS_FILE      CONSTANT  VARCHAR2(50)    := 'hrmecmnw.js';
  gv_cancel           CONSTANT  VARCHAR2(200)    := 'cancel_button_onClick';
  gv_hr_menu          CONSTANT  VARCHAR2(200)    := 'main_menu_onClick';

  -- Variables to mimic the functionality of CHR() functions.
  gv_NULL             CONSTANT  VARCHAR2(10) :=
                                  CONVERT (
                                    fnd_global.local_chr(0),
                                    SUBSTR(userenv('LANGUAGE'),
                                      INSTR(userenv('LANGUAGE'),'.') +1),
                                    'WE8ISO8859P1'
                                  );
  gv_NEW_LINE         CONSTANT  VARCHAR2(10) :=
                                  CONVERT (
                                    fnd_global.local_chr(10),
                                    SUBSTR(userenv('LANGUAGE'),
                                      INSTR(userenv('LANGUAGE'),'.') +1),
                                    'WE8ISO8859P1'
                                  );
  gv_SPACE            CONSTANT  VARCHAR2(10) :=
                                  CONVERT (
                                    fnd_global.local_chr(32),
                                    SUBSTR(userenv('LANGUAGE'),
                                      INSTR(userenv('LANGUAGE'),'.') +1),
                                    'WE8ISO8859P1'
                                  );
  gv_SINGLE_QUOTE     CONSTANT  VARCHAR2(10) :=
                                  CONVERT (
                                    fnd_global.local_chr(39),
                                    SUBSTR(userenv('LANGUAGE'),
                                      INSTR(userenv('LANGUAGE'),'.') +1),
                                    'WE8ISO8859P1'
                                  );
  gv_COMMA            CONSTANT  VARCHAR2(10) :=
                                  CONVERT (
                                    fnd_global.local_chr(44),
                                    SUBSTR(userenv('LANGUAGE'),
                                      INSTR(userenv('LANGUAGE'),'.') +1),
                                    'WE8ISO8859P1'
                                  );

  -- Global TYPES.
  TYPE grt_trans_info IS RECORD (
    item_type   wf_items.item_type%TYPE,
    item_key    wf_items.item_key%TYPE,
    actid       NUMBER
  );

  TYPE grt_assignment_details IS RECORD (
    assignment_id          per_assignments_f.assignment_id%TYPE,
    person_id              per_people_f.person_id%TYPE,
    person_full_name       per_people_f.full_name%TYPE,
    supervisor_id          per_people_f.person_id%TYPE,
    supervisor_full_name   per_people_f.full_name%TYPE,
    job_id                 per_jobs.job_id%TYPE,
    job_name               per_jobs.name%TYPE,
    organization_id        hr_organization_units.organization_id%TYPE,
    organization_name      hr_organization_units.name%TYPE,
    assignment_number      per_assignments_f.assignment_number%TYPE,
    business_group_id      per_assignments_f.business_group_id%TYPE,
    effective_start_date   per_assignments_f.effective_start_date%TYPE,
    effective_end_date     per_assignments_f.effective_end_date%TYPE,
    payroll_id             per_assignments_f.payroll_id%TYPE,
    location_id            per_assignments_f.location_id%TYPE,
    primary_flag           per_assignments_f.primary_flag%TYPE,
    object_version_number  per_assignments_f.object_version_number%TYPE
  );


  TYPE grt_person_details IS RECORD (
    full_name              per_people_f.full_name%TYPE,
    business_group_id      per_people_f.business_group_id%TYPE
  );


  TYPE grt_enter_process_checks IS RECORD (
    hire_date              VARCHAR2(10) DEFAULT 'N',
    termination_date       VARCHAR2(10) DEFAULT 'N',
    future_assignment      VARCHAR2(10) DEFAULT 'N',
    pending_workflow       VARCHAR2(10) DEFAULT 'N',
    correction_mode        VARCHAR2(10) DEFAULT 'N',
    earlier_date           VARCHAR2(10) DEFAULT 'N',
    hire_date2             DATE         DEFAULT NULL,
    termination_date2      DATE         DEFAULT NULL,
    future_assignment_date DATE         DEFAULT NULL
  );

   TYPE g_number_tbl_type
      is table of number
      index by binary_integer;

   g_number_tbl_default         g_number_tbl_type;

/*
||===========================================================================
|| PROCEDURE: remove_transaction
||----------------------------------------------------------------------------
||
|| Description:
||     This procedure removes transaction steps, transaction step values
||      and transaction id on Cancel or Exit to Main Menu.
||
|| Pre-Conditions:
||
|| Input Parameters:
||
|| Output Parameters:
||
|| In out nocopy Parameters:
||
|| Post Success:
||
||
|| Post Failure:
||     Raise exception.
||
|| Access Status:
||     Public
||
||=============================================================================
*/
--
  PROCEDURE remove_transaction(p_item_type    in varchar2
                              ,p_item_key     in varchar2
                              ,p_actid        in number);
--
/*
  ||===========================================================================
  || FUNCTION: get_language_code
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     This function returns the current language code.
  ||     Example:-   US  -  United States
  ||                 JP  -  Japan
  ||                 UK  -  United Kingdom
  ||
  || Pre Conditions:
  ||
  || In Arguments:
  ||
  || out nocopy Arguments:
  ||
  || In out nocopy Arguments:
  ||
  || Post Success:
  ||     Returns the language code of this installation.
  ||
  || Post Failure:
  ||     Prints the SQLEERM mesg.
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */
  FUNCTION get_language_code
  RETURN VARCHAR2;


  /*
  ||===========================================================================
  || FUNCTION: get_image_directory
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     This function returns the image directory.
  ||     Example:-  '/OA_MEDIA/US/'
  ||
  || Pre Conditions:
  ||
  || In Arguments:
  ||
  || out nocopy Arguments:
  ||
  || In out nocopy Arguments:
  ||
  || Post Success:
  ||     Returns the image directory.
  ||
  || Post Failure:
  ||     Prints the SQLEERM mesg.
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */
  FUNCTION get_image_directory
  RETURN VARCHAR2;

  /*
  ||===========================================================================
  || FUNCTION: get_business_group_id
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     This function is overloaded to get the business group id either from
  ||     the logged in person or from the selected resposibility.
  ||     Logged in Person -  This function will return the business group of
  ||                         the logged in person.
  ||     Responsibility   -  The Function call returns the Business Group ID
  ||                         for the current session's login responsibility.
  ||                         The defaulting levels are as defined in the
  ||                         package FND_PROFILE. It returns business group id
  ||                         value for a specific user/resp/appl combo.
  ||                         Default is user/resp/appl/site is current login.
  ||
  || Pre Conditions:
  ||
  || In Arguments:
  ||     p_person_id --  Person ID for whom the business group is required.
  ||
  || out nocopy Arguments:
  ||
  || In out nocopy Arguments:
  ||
  || Post Success:
  ||     Returns the business group id.
  ||
  || Post Failure:
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */
  FUNCTION get_business_group_id (
    p_person_id IN per_people_f.person_id%TYPE
  )
  RETURN per_business_groups.business_group_id%TYPE;

  FUNCTION get_business_group_id
  RETURN   per_business_groups.business_group_id%TYPE;


  /*
  ||===========================================================================
  || FUNCTION: get_legislation_code
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     This function will return the legislation code of a person,
  ||     an assignment, or of a business_group_id which ever is provided.
  ||
  || Pre Conditions:
  ||
  || In Arguments:
  ||     p_person_id         --  Legislation code based on this person id.
  ||     p_assignment_id     --  Legislation code based on this assignment id.
  ||     p_business_group_id --  Legislation code based on this business group.
  ||     p_effective_date    --  The legislation code returned should be valid
  ||                             on this date.
  ||
  || out nocopy Arguments:
  ||
  || In out nocopy Arguments:
  ||
  || Post Success:
  ||     Returns the legislation code.
  ||
  || Post Failure:
  ||     Prints out nocopy error message.
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */
  FUNCTION get_legislation_code (
    p_person_id         IN per_people_f.person_id%TYPE DEFAULT NULL,
    p_assignment_id     IN per_assignments_f.assignment_id%TYPE DEFAULT NULL,
    p_business_group_id IN per_business_groups.business_group_id%TYPE
                           DEFAULT NULL,
    p_effective_date    IN DATE DEFAULT SYSDATE
  )
  RETURN per_business_groups.legislation_code%TYPE;


  /*
  ||===========================================================================
  || FUNCTION: get_person_details
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     This function will return details pertaining to the passed
  ||     person ID. It will return a record structure.
  ||
  || Pre Conditions:
  ||
  || In Arguments:
  ||     p_person_id --  Person ID for whom details are required.
  ||
  || out nocopy Arguments:
  ||
  || In out nocopy Arguments:
  ||
  || Post Success:
  ||     Returns a record structure.
  ||
  || Post Failure:
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */
  FUNCTION get_person_details (
    p_person_id    IN per_people_f.person_id%TYPE
  )
  RETURN hr_misc_web.grt_person_details;



  /*
  ||===========================================================================
  || FUNCTION: get_sshr_segment_value
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     This function returns the segment value of the given segment name
  ||     from the context "Self Service HR Information" of Org DDF.
  ||
  || Pre Conditions:
  ||
  || In Arguments:
  ||     p_bg_id --  Business Group Id.
  ||     p_user_column_name -- Segment Name in "Self Service HR Information"
  ||                           context
  ||
  || out nocopy Arguments: Segment value of the give Segment Name.
  ||
  || In out nocopy Arguments:
  ||
  || Post Success:
  ||     Returns a record structure.
  ||
  || Post Failure:
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */

  FUNCTION   get_sshr_segment_value
   ( p_bg_id IN per_all_people_f.business_group_id%TYPE DEFAULT NULL,
     p_user_column_name IN varchar2 )
  RETURN VARCHAR2;



  /*
  ||===========================================================================
  || FUNCTION: get_user_defined_job_segments
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     Derive the Job Name from the segment string passed as input.
  ||
  || Pre Conditions:
  ||
  || In Arguments:
  ||     p_job_segments - User defined Segment string.
  ||     p_job_name     - Job Name from per_jobs.
  ||     p_job_id       - Job Id from per_jobs.
  ||
  || out nocopy Arguments: Derived string.
  ||
  || In out nocopy Arguments:
  ||
  || Post Success:
  ||     Returns a record structure.
  ||
  || Post Failure:
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */


  FUNCTION  get_user_defined_job_segments
   ( p_job_segments IN varchar2 DEFAULT NULL,
     p_job_name IN per_jobs.name%TYPE DEFAULT NULL,
     p_job_id IN per_jobs.job_id%TYPE DEFAULT NULL)
   RETURN VARCHAR2;


  /*
  --===========================================================================
  --|| PROCEDURE: get_job_segments
  --||-------------------------------------------------------------------------
  --||
  --|| Description:
  --||     Utility method used in V4 to get User Defined Job Segments.
  --||
  --||
  --|| Pre-Conditions: See the context "SSHR Information" is added
  --||                 and the segment "Display MEE Job Segments" if want any
  --||                 configuration.
  --||
  --|| Input Parameters: p_bg_id, job_name, job_id
  --||
  --|| Output Parameters: derived Job Name
  --||
  --|| In Out Parameters:
  --||
  --|| Post Success:
  --||
  --|| Post Failure:
  --||     Raise exception.
  --||
  --|| Access Status:
  --||     Public
  --||
  --||==========================================================================
  */


  FUNCTION   get_job_segments
     ( p_bg_id IN per_all_people_f.business_group_id%TYPE,
       p_job_id IN hr_organization_units.organization_id%TYPE,
       p_job_name IN hr_organization_units.name%TYPE)
  RETURN VARCHAR2;



  /*
  ||===========================================================================
  || FUNCTION: get_assignment_details
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     This function will return details pertaining to the passed
  ||     assignment ID. It will return a record structure.
  ||
  || Pre Conditions:
  ||
  || In Arguments:
  ||     p_assignment_id  -- Returns deatails of this assignment ID.
  ||     p_effective_date -- Assignment that is effective on this date.
  ||
  || out nocopy Arguments:
  ||
  || In out nocopy Arguments:
  ||
  || Post Success:
  ||     Returns grt_assignment_details record structure.
  ||
  || Post Failure:
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */
  FUNCTION get_assignment_details (
    p_assignment_id    IN per_assignments_f.assignment_id%TYPE,
    p_effective_date   IN DATE
  )
  RETURN hr_misc_web.grt_assignment_details;


  /*
  ||===========================================================================
  || FUNCTION: get_assignment_id
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     This function will return the grt_assignment_details structure
  ||     which will have the current assignment id, effective start date
  ||     of the person based on the person id.
  ||
  || Pre Conditions:
  ||
  || In Arguments:
  ||     p_person_id  -- Returns assignment id of this person id.
  ||
  || out nocopy Arguments:
  ||
  || In out nocopy Arguments:
  ||
  || Post Success:
  ||     Returns grt_assignment_details structure.
  ||
  || Post Failure:
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */
  FUNCTION get_assignment_id (
    p_person_id    IN per_people_f.person_id%TYPE
  )
  RETURN hr_misc_web.grt_assignment_details;

  /*
  ||===========================================================================
  || FUNCTION: get_assignment_id
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     Gets a lookup code meaning from HR_LOOKUPS table for
  ||     a given lookup code and type and date.
  ||
  || Pre Conditions:
  ||
  || In Arguments:
  ||     p_proposal_code  -- Lookup_code in HR_LOOKUPS
  ||     p_lookup_type    -- lookup type in HR_LOOKUPS
  ||     p_date           -- effective_date
  ||
  || out nocopy Arguments:
  ||
  || In out nocopy Arguments:
  ||
  || Post Success:
  ||     Returns assignment id.
  ||
  || Post Failure:
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */
  FUNCTION get_lookup_meaning (
    p_code        IN VARCHAR2,
    p_lookup_type IN VARCHAR2,
    p_date        IN DATE
  )
  RETURN VARCHAR2;


  /*
  ||===========================================================================
  || FUNCTION: get_enter_process_checks
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     This function will return a record which will contain the data to
  ||     do the required error checking before launching a module from the
  ||     effective date dialog box.
  ||
  || Pre Conditions:
  ||     None
  ||
  || In Arguments:
  ||     p_assignment_id         --  Assignment ID to get the dates
  ||     p_effective_date        --  To get future date transactions based on
  ||                                 this date.
  ||     p_enter_process_checks  --  Structure which will hold all the required
  ||                                 checks.
  ||
  || out nocopy Arguments:
  ||
  || In out nocopy Arguments:
  ||
  || Post Success:
  ||     Returs grt_enter_process_checks structure.
  ||
  || Post Failure:
  ||     Throws exception.
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */
  FUNCTION get_enter_process_checks (
    p_assignment_id        IN NUMBER                               DEFAULT NULL,
    p_effective_date       IN DATE                                 DEFAULT NULL,
    p_enter_process_checks IN hr_misc_web.grt_enter_process_checks DEFAULT NULL
  )
  RETURN hr_misc_web.grt_enter_process_checks;


END hr_misc_web;

 

/
