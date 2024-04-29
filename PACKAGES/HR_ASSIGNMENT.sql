--------------------------------------------------------
--  DDL for Package HR_ASSIGNMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ASSIGNMENT" AUTHID CURRENT_USER AS
/* $Header: peassign.pkh 120.4.12010000.1 2008/07/28 04:12:11 appldev ship $ */
/*
 ******************************************************************
 *                                                                *
 *  Copyright (C) 1992 Oracle Corporation UK Ltd.,                *
 *                   Chertsey, England.                           *
 *                                                                *
 *  All rights reserved.                                          *
 *                                                                *
 *  This material has been provided pursuant to an agreement      *
 *  containing restrictions on its use.  The material is also     *
 *  protected by copyright law.  No part of this material may     *
 *  be copied or distributed, transmitted or transcribed, in      *
 *  any form or by any means, electronic, mechanical, magnetic,   *
 *  manual, or otherwise, or disclosed to third parties without   *
 *  the express written permission of Oracle Corporation UK Ltd,  *
 *  Oracle Park, Bittams Lane, Guildford Road, Chertsey, Surrey,  *
 *  England.                                                      *
 *                                                                *
 ****************************************************************** */
/*
 Name        : hr_assignment  (HEADER)

 Description : This package declares procedures required to
               INSERT, UPDATE and DELETE assignments and all
               associated tables :

                  PER_ASSIGNMENTS_F
                  PER_SECONDARY_ASSIGNMENT_STATUSES
                  PER_ASSIGNMENT_BUDGET_VALUES

 Change List
 -----------

 Version Date      Author     ER/CR No. Description of Change
 -------+---------+----------+---------+--------------------------
 70.0    19-NOV-92 SZWILLIA             Date Created
 70.6    30-DEC-92 SZWILLIA             Changed Integer refs to NUMBER.
 70.7    16-FEB-93 JHOBBS               Added maintain_alu_asg procedure for
					maintaining alus for the assignment.
 70.8    03-MAR-93 JHOBBS               Removed maintain_alu_asg. It is now in
					hrentmnt.
 70.9    10-MAR-93 JRHODES              Made all Date fields type DATE
 70.10   11-MAR-93 NKHAN		Added 'exit' to the end
 70.11   25-MAR-93 JRHODES              New Procedure 'tidy_up_ref_int'
 70.12   07-JUN-93 JRHODES              New Procedure 'call_terminate_entries'
 80.1    15-OCT-93 JRHODES              Added check for cobra
 80.2    09-DEC-93 JRhodes              New Procedure 'test_for_cancel_reterm'
 70.22   04-JUL-94 JRhodes              Added Validate_Pos
 110.1   01-APR-98 SASmith              Change to the load_budget_values parameters to include
                                        effective start and end dates. Required as per_assignments
                                        _budget_values_f is now datetracked.

 115.3  26-Nov-2001 HSAJJA              Added procedure load_assignment_allocation
 115.4  27-Nov-2001 HSAJJA              Added dbdrv command
 115.5  15-Feb-2001 M Bocutt 1681015    Added p_cost_warning to tidy_up_ref_int
                                        to pass back warning condition about
                                        costing maintenance.
 115.6  26-FEB-2002 M Gettins           Added update_primary_cwk as part of
                                        of the contingent labour project.                                  08-MAR-2002 adhunter            Added overloaded gen_new_ass_number
 115.7  04-OCT-2002 adhunter            Added whenever oserror exit failure rollback
 115.11 05-nov-2007 sidsaxen            Created update_assgn_context_value and
                                        get_assgn_dff_value new procedures.
 ================================================================= */
--
--
------------------- gen_probation_end -----------------------------
/*
  NAME
     gen_probation_end
  DESCRIPTION

  PARAMETERS
     p_assignment_id    - assignment_id or NULL if in insert mode
     p_probation_period - probation period, NULL if validating DATE_END
     p_probation_unit   - probation unit, NULL if validating DATE_END
     p_start_date       - Validation start date of the assignment
     p_date_probation_end - User entered date or NULL when default required
*/
PROCEDURE gen_probation_end
 			   ( p_assignment_id        IN     INTEGER
			   , p_probation_period     IN     NUMBER
			   , p_probation_unit       IN     VARCHAR2
			   , p_start_date           IN     DATE
			   , p_date_probation_end   IN OUT NOCOPY DATE
			   );
--
--
------------------- gen_new_ass_sequence --------------------------
/*
  NAME
    gen_new_ass_sequence
  DESCRIPTION
    Generates a new assignment sequence for Applicant and Employee
    Assignments.
*/
PROCEDURE gen_new_ass_sequence
			   (  p_person_id 	    in  number
			   ,  p_assignment_type     in  varchar2
			   ,  p_assignment_sequence in out nocopy number
			   );
--
--
------------------- gen_new_ass_number ----------------------------
/*
  NAME
    gen_new_ass_number
  DESCRIPTION
    If an Assignment Number is passed to the procedure it validates
    that it is a unique number for the Person.

    If no Assignment Number is passed to the procedure then it determines
    the value of the newxt assignment number. If the assignment sequence
    is 1 then it is just the value of the employee number otherwise it is
    the employee number || assignment sequence. If the generated assignment
    number is not unique then the assignment sequence is incremented until
    a valid assignment number is generated.
*/
PROCEDURE gen_new_ass_number
			   (  p_assignment_id 	    IN    number
			   ,  p_business_group_id   IN    number
			   ,  p_employee_number     IN    VARCHAR2
			   ,  p_assignment_sequence IN    number
			   ,  p_assignment_number   IN OUT NOCOPY VARCHAR2
			   );
--
------------------- gen_new_ass_number ---OVERLOADED---------------
/*
  NAME
    gen_new_ass_number
  DESCRIPTION
    If an Assignment Number is passed to the procedure it validates
    that it is a unique number for the Person.

    If no Assignment Number is passed to the procedure then it determines
    the value of the newxt assignment number. If the assignment sequence
    is 1 then it is just the value of the worker number otherwise it is
    the worker number || assignment sequence. If the generated assignment
    number is not unique then the assignment sequence is incremented until
    a valid assignment number is generated.
*/
PROCEDURE gen_new_ass_number
			   (  p_assignment_id 	    IN    number
			   ,  p_business_group_id   IN    number
			   ,  p_worker_number        IN    VARCHAR2
                           ,  p_assignment_type     IN    VARCHAR2
			   ,  p_assignment_sequence IN    number
			   ,  p_assignment_number   IN OUT NOCOPY VARCHAR2
			   );
--
--
------------------- check_hours -----------------------------------
/*
  NAME
     check_hours
  DESCRIPTION
     Validation to ensure that the normal working hours do not exceed
     the maximum availble for the Frequency.
  PARAMETERS
     p_frequency        - Standard Conditions PER field
			- only D,W,M,Y are valid values
     p_normal_hours     - Standard Conditions WORKING HOURS field
*/
PROCEDURE check_hours
 			   ( p_frequency            IN     VARCHAR2
			   , p_normal_hours         IN     NUMBER
			   );
--
--
------------------- check_term -----------------------------
/*
  NAME
     check_term
  DESCRIPTION
     If an Update Override, Delete Next Change or Future Change Delete
     will remove TERM_ASSIGNed assignments or END DATES after
     assignment status changes of TERM_ASSIGN then the end date may need
     to be fixed to either the Actual Termination Date or the Final
     Process Date or the Employees Period of Service. This procedure
     determines the requirement and returns an new End Date if one is
     required.
  PARAMETERS
     p_period_of_service_id	- Employee's Current Period of Service ID
     p_assignment_id		- Assignment ID
     p_sdate               	- Start Date of current Assignment row
     p_edate             	- End Date of current Assignment row
     p_current_status           - The PER_SYSTEM_STATUS of the current row
     p_mode			- FUTURE_CHANGES, DELETE_NEXT_CHANGE,
				  UPDATE_OVERRIDE
     p_newdate                  - The New ASsignment End Date
*/
PROCEDURE check_term
			    (
			     p_period_of_service_id IN INTEGER
                            ,p_assignment_id IN INTEGER
			    ,p_sdate IN DATE
			    ,p_edate IN DATE
			    ,p_current_status IN VARCHAR2
			    ,p_mode IN VARCHAR2
  	                    ,p_newdate OUT NOCOPY DATE
			    );
--
--
------------------- warn_del_term      ----------------------------
/*
  NAME
     warn_del_term
  DESCRIPTION
     If the operation will remove an assignment with TERM_ASSIGN status
     then a warning will be issued from the form. This procedure
     determines whether such an operation will take place.
  PARAMETERS
     p_assignment_id		- Assignment ID
     p_effective_start_date	- Start Date of current Assignment row
     p_effective_end_date	- End Date of current Assignment row
     p_mode			- FUTURE_CHANGES, DELETE_NEXT_CHANGE,
				  UPDATE_OVERRIDE
*/
procedure warn_del_term
			    (
			     p_assignment_id IN INTEGER
                            ,p_mode IN VARCHAR2
			    ,p_effective_start_date IN DATE
			    ,p_effective_end_date IN DATE
			    );
--
--
------------------- delete_ass_ref_int ----------------------------
/*
  NAME
     delete_ass_ref_int
  DESCRIPTION
     Determines whether there are any dependent records for the Assignment.
     If any are found then delete them.
     The following tables are examined
		PER_SPINAL_POINT_PLACEMENTS
		PER_SECONDARY_ASG_STATUSES
		PER_ASSIGNMENT_BUDGET_VALUES

  PARAMETERS
     p_business_group_id	- Business Group ID
     p_assignment_id		- Assignment ID
*/
PROCEDURE delete_ass_ref_int
			    (
			     p_business_group_id    IN INTEGER
                            ,p_assignment_id IN INTEGER
			    );
--
--
------------------- get_act_term_date -----------------------------
/*
  NAME
     get_act_term_date
  DESCRIPTION
     Returns the Actual Termination Date of the Employee Period of Service.

  PARAMETERS
     p_period_of_service_id
     p_actual_termination_date
*/
PROCEDURE get_act_term_date
			    (
			     p_period_of_service_id IN INTEGER
			    ,p_actual_termination_date OUT NOCOPY DATE
			    );
--
--
------------------- check_future_primary --------------------------
/*
  NAME
     check_future_primary
  DESCRIPTION
     Checks to see whether the operation will remove a row
     that has a primary flag value differnet to the current one.
     If such a row is found then the P_CHANGE_FLAG is set to 'Y' and
     the date from which changes to other assignment primary flag
     changes must be catered for is determined and passed back in
     P_PRIMARY_DATE_FROM.
  PARAMETERS
     p_assignment_id	- The current assignment to be checked
     p_sdate		- The start date of the current row
			  NB this depends on the Mode
			  UPDATE_OVERRIDE ==> Validation Start Date
			  Otherwise ==> Effective Start Date
     p_edate		- Effective End Date of the current row
     p_mode		- The DT_UPDATE_MODE or DT_DELETE_MODE
     p_primary_flag	- The Primary Flag Value for the current assignment
     p_change_flag	- An indicator to detect whether primary changes are
			  required.
     p_new_primary_flag	- The value that the current assignment will have
			  after the operation
     p_primary_date_from- The date from which changes to other assignments
			  must be catered for
*/
PROCEDURE check_future_primary
			    (
                             p_assignment_id IN INTEGER
			    ,p_sdate IN DATE
			    ,p_edate IN DATE
			    ,p_mode  IN VARCHAR2
			    ,p_primary_flag IN VARCHAR2
			    ,p_change_flag IN OUT NOCOPY VARCHAR2
			    ,p_new_primary_flag IN OUT NOCOPY VARCHAR2
			    ,p_primary_date_from OUT NOCOPY DATE
			    );
--
--
------------------- check_ass_for_primary -------------------------
/*
  NAME
     check_ass_for_primary
  DESCRIPTION
     Checks to ensure that the record is continuous until the end
     of the Period Of Service and that if it has been terminated
     then termination was as a result of the termination of the employee
     i.e. the termination date is the same as the ACTUAL TERMINATION DATE.
  PARAMETERS
     p_period_of_service_id - The current Period of Service ID
     p_assignment_id        - The current assignment ID
     p_sdate                - The validation start date of the updated record
*/
PROCEDURE check_ass_for_primary
			    (
			     p_period_of_service_id IN INTEGER
                            ,p_assignment_id IN INTEGER
			    ,p_sdate IN DATE
			    );
--
/*
  NAME
     update_primary_cwk
  DESCRIPTION
     For the Current Assignment, if the operation is not ZAP then updates
     all the future rows to the NEW_PRIMARY_FLAG value.
     For other assignments,if the other assignment is the new primary
     then ensure that there is a record starting on the correct date
     with Primary Flag = 'Y' and update all other future changes to
     the same Primary value. For any other assignments
     if the assignment is primary on the date in question then
	 ensure that that there is a row on this date with primary
	 flag = 'N' and that all future changes are set to 'N'
	 otherwise ensure that all future primary flags are set to 'N'.
     NB. This uses several calls to DO_PRIMARY_UPDATE which handles the
	 date effective insert for an individual assignment row if one
	 is required.
  PARAMETERS
     p_assignment_id        - The current assignment
     p_pop_date_start       - The current Period of Placement
     p_new_primary_ass_id	- The Assignment ID that will be primary after
				              the operation
     p_sdate			    - The date from which changes are to be made
     p_new_primary_flag  	- The current assignment primary flag after the
				              operation
     p_mode			        - The DT_DELETE_MODE or DT_UPDATE_MODE
*/
--
PROCEDURE update_primary_cwk
  (p_assignment_id        IN INTEGER
  ,p_person_id            IN NUMBER
  ,p_pop_date_start       IN DATE
  ,p_new_primary_ass_id   IN INTEGER
  ,p_sdate                IN DATE
  ,p_new_primary_flag     IN VARCHAR2
  ,p_mode                 IN VARCHAR2
  ,p_last_updated_by      IN INTEGER
  ,p_last_update_login    IN INTEGER  );
--
------------------- update_primary    -----------------------------
/*
  NAME
     update_primary
  DESCRIPTION
     For the Current Assignment, if the operation is not ZAP then updates
     all the future rows to the NEW_PRIMARY_FLAG value.
     For other assignments,
	if the other assignment is the new primary then ensure that there
	is a record starting on the correct date with Primary Flag = 'Y'
	and update all other future changes to the same Primary value.
     For any other assignments
	    if the assignment is primary on the date in question then
	    ensure that that there is a row on this date with primary
	    flag = 'N' and that all future changes are set to 'N'
	    otherwise
	    ensure that all future primary flags are set to 'N'.
     NB. This uses several calls to DO_PRIMARY_UPDATE which handles the
	 date effective insert for an individual assignment row if one
	 is required.
  PARAMETERS
     p_assignment_id		- The current assignment
     p_period_of_service_id	- The current Period of Service
     p_new_primary_ass_id	- The Assignment ID that will be primary after
				  the operation
     p_sdate			- The date from which changes are to be made
     p_new_primary_flag  	- The current assignment primary flag after the
				  operation
     p_mode			- The DT_DELETE_MODE or DT_UPDATE_MODE
     p_last_updated_by 		- For Audit
     p_last_update_login 	- For Audit
*/
PROCEDURE update_primary
			    (
                             p_assignment_id IN INTEGER
			    ,p_period_of_service_id IN INTEGER
                            ,p_new_primary_ass_id IN INTEGER
			    ,p_sdate IN DATE
			    ,p_new_primary_flag IN VARCHAR2
			    ,p_mode IN VARCHAR2
			    ,p_last_updated_by IN INTEGER
			    ,p_last_update_login IN INTEGER
			    );
--
--
------------------- do_primary_update -----------------------------
/*
  NAME
     do_primary_update
  DESCRIPTION
     Performs updates on the Assignment to set the Primary Flag to the value
     passed in to the procedure.
     If a Primary Flag is to be reset on the Date passed in and a row does
     not start on this date then a date effective insert is performed.
  PARAMETERS
     p_assignment_id - The assignment to be updated
     p_sdate         - The date from which to update
     p_primary_flag  - The primary flag value
     p_current_ass   - Whether the assignment is the current one (Y/N)
     p_last_updated_by
     p_last_update_login
*/
PROCEDURE do_primary_update
			    (
			     p_assignment_id IN INTEGER
                            ,p_sdate IN DATE
			    ,p_primary_flag IN VARCHAR2
			    ,p_current_ass IN VARCHAR2
			    ,p_last_updated_by IN INTEGER
			    ,p_last_update_login IN INTEGER
			    );
--
--
------------------- get_new_primary_assignment --------------------
/*
   NAME
      get_new_primary_assignment
   DESCRIPTION
      Searches for a candidate assignment which will become Primary
      on the Date passed into the procedure. The assignment must be continuous
      to the end of the period of service and if it is terminated the
      first termination must be as aresult of termination of the employee.
      If more than one candidate assignment is found then a warning status is
      raised (the form detect the warning and pops a QuickPick).
   PARAMETERS
      p_assignment_id		- The current assignment
      p_period_of_service_id	- The current period of service
      p_sdate			- The date upon which the assignment will
				  become primary
      p_new_primary_ass_id	- The new Primary Assignment ID
*/
PROCEDURE get_new_primary_assignment
			    (
                             p_assignment_id IN NUMBER
                            ,p_period_of_service_id IN NUMBER
			    ,p_sdate IN DATE
			    ,p_new_primary_ass_id OUT NOCOPY VARCHAR2
			    );
--
--
------------------- load_budget_values         --------------------
/*
   NAME
      load_budget_values
   DESCRIPTION
      Creates Assignment Budget Values form the Default ones for the Business
      Group.
   PARAMETERS
      p_assignment_id		- The current assignment
      p_business_group_id       - The business Group
      p_userid
      p_login
      p_effective_start_date    - start date of the assignment.
      p_effective_end_date      - end date of the assignment.
*/
-- Change to parameter structure to include effective start and end dates.
-- This is required as per_assignment_budget_values now date tracked.
-- SASmith : 01-APR-1998.
--
PROCEDURE load_budget_values
				 (p_assignment_id        IN INTEGER
				 ,p_business_group_id    IN INTEGER
				 ,p_userid               IN VARCHAR2
				 ,p_login                IN VARCHAR2
				 ,p_effective_start_date IN DATE
				 ,p_effective_end_date   IN DATE
				 );
--
--
------------------- del_ref_int_check          --------------------
/*
   NAME
      del_ref_int_check
   DESCRIPTION
      Performs Referential Integrity Checks on the following tables
      For 'ZAP'
          PER_EVENTS
          PER_LETTER_REQUEST_LINES
          PAY_COST_ALLOCATIONS_F
          PER_ASSIGNMENT_EXTRA_INFO
          PER_SECONDARY_ASG_STATUSES
          PAY_PERSONAL_PAYMENT_METHODS_F
	  HR_ASSIGNMENT_SET_AMENDMENTS
	  PAY_ASSIGNMENT_ACTIONS

      For 'END' (date effective delete)
          PER_EVENTS
          PER_LETTER_REQUEST_LINES
          PAY_COST_ALLOCATIONS_F
          PER_SECONDARY_ASG_STATUSES
          PAY_PERSONAL_PAYMENT_METHODS_F
	  PAY_ASSIGNMENT_ACTIONS

      Determines whether the delete operation is permissible
   PARAMETERS
      p_assignment_id		- The current assignment
      p_mode			- The mode of operation (ZAP or END)
      p_edate			- The date the assignment is ENDed
					only required for 'END'
*/
PROCEDURE del_ref_int_check
			    (
                             p_assignment_id IN INTEGER
			    ,p_mode IN VARCHAR2
			    ,p_edate IN DATE
			    );
--
--
------------------- del_ref_int_delete         --------------------
/*
   NAME
      del_ref_int_delete
   DESCRIPTION
      Performs Third Party Delete on data that is not checked in
      del_ref_in_check. Removes data from the following tables

      For 'ZAP'
		HR_ASSIGNMENT_SET_AMENDMENTS
		PER_ASSIGNMENT_BUDGET_VALUES
		PER_SPINAL_POINT_PLACEMENTS_F

      For 'END' (performs a date effective delete)
		PER_SPINAL_POINT_PLACEMENTS_F

      For 'FUTURE' (including FUTURE_CHANGES, DELETE_NEXT_CHANGE,
			      UPDATE_OVERRIDE)
                PER_SPINAL_POINT_PLACEMENTS_F

   PARAMETERS
      p_assignment_id		- The current assignment
      p_grade_id                - The current grade ('FUTURE' only')
      p_mode			- The mode of operation (ZAP, END or FUTURE)
      p_edate			- For END  the date the assignment is ENDed
				  For FUTURE the date the change applies from
				  For ZAP not required
      p_last_updated_by
      p_last_update_login
*/
PROCEDURE del_ref_int_delete
			    (
                             p_assignment_id IN INTEGER
			    ,p_grade_id IN INTEGER
			    ,p_mode IN VARCHAR2
			    ,p_edate IN DATE
			    ,p_last_updated_by IN INTEGER
			    ,p_last_update_login IN INTEGER
			    ,p_calling_proc IN VARCHAR2 DEFAULT NULL
			    ,p_val_st_date IN DATE DEFAULT NULL
                            ,p_val_end_date IN DATE DEFAULT NULL
			    ,p_datetrack_mode IN VARCHAR2 DEFAULT NULL
			    ,p_future_spp_warning OUT NOCOPY BOOLEAN
			    );
--
--
------------------- tidy_up_ref_int            --------------------
/*
  NAME
     tidy_up_ref_int
  DESCRIPTION
     This procedure performs two operations.
     The first occurs when it is called with a parameter of 'END' - the
     procedure then moves the end date of any child rows for the assignment
     so that it is set to be the end date of the assignment.

     The second occurs when it is called with a parameter of 'FUTURE'.
     This is the case when a FUTURE_CHANGE of DELETE_NEXT_CHANGE is going
     to open the assignment out nocopy beyond its current End Date. The procedure
     resets the End Dates of any child rows to be that on the Assignment. In
     the case of Costing records dates are only changed if there are not
     future records.

     The following tables are affected.

     PAY_COST_ALLOCATIONS_F
     PER_SECONDARY_ASS_STATUSES
     PAY_PERSONAL_PAYMENT_METHODS_F

  PARAMETERS
     p_assignment_id		- Assignment ID
     p_mode                     - 'END' or 'FUTURE'
     p_new_end_date             - The new end date of the parent Assignment
     p_old_end_date             - The Assignment End Date before the operation
     p_last_updated_by
     p_last_update_login
     p_cost_warning             - Pass back warning if future costing records
                                  exist. Can only set to TRUE if mode is
                                  FUTURE.
*/
PROCEDURE tidy_up_ref_int
			    (
                             p_assignment_id IN INTEGER
			    ,p_mode IN VARCHAR2
			    ,p_new_end_date IN DATE
  	                    ,p_old_end_date DATE
			    ,p_last_updated_by INTEGER
			    ,p_last_update_login INTEGER
                            ,p_cost_warning OUT NOCOPY BOOLEAN
			    );
--
--
------------------- call_terminate_entries     --------------------
/*
  NAME
     call_terminate_entries
  DESCRIPTION
     This procedure determines the Actual Termination Date, Last Standard
     Processing Date and Final Process Date in order to terminate element
     entries and ALUs when an individual assignment is terminated or ended.

     There are several cases :-

     i. Status is END and there are no prior TERM_ASSIGNs
	=> ATD = Session date
	   LSD = Session date
	   FPD = Session date

    ii. Status is END and there is a prior TERM_ASSIGN
	=> ATD = NULL
	   LSD = NULL
	   FPD = Session Date

   iii. Status is TERM_ASSIGN and there are no prior TERM_ASSIGNs
	=> ATD = Validation Start Date - 1
	   LSD = (IF Assignment has Payroll then END_DATE of current
		  processing period
		  ELSE
		     Validation Start Date - 1)
           FPD = NULL

    iv. Status is TERM_ASSIGN and there is a prior TERM_ASSIGN
	=> No processing required

  PARAMETERS
     p_assignment_id		- Assignment ID
     p_status                   - 'END' or 'TERM_ASSIGN'
     p_start_date               - Validation Start Date for TERM_ASSIGN or
				  Session Date for 'END'
*/
PROCEDURE call_terminate_entries
			    (
                             p_assignment_id IN NUMBER
			    ,p_status IN VARCHAR2
			    ,p_start_date IN DATE
			    );
--
------------ test_for_cancel_reterm ------------------------------------
  /*
   This procedure works out nocopy whether a Cancel or retermination is required
   follwoing an operation that affects the "leading TERM_ASSIGN" status
   */
procedure test_for_cancel_reterm
(p_assignment_id         in number
,p_validation_start_date in date
,p_validation_end_date   in date
,p_mode                  in varchar2
,p_current_status_type   in varchar2
,p_old_status_type       in varchar2
,p_cancel_atd            in out nocopy date
,p_cancel_lspd           in out nocopy date
,p_reterm_atd            in out nocopy date
,p_reterm_lspd           in out nocopy date
);
--
-----------------------------------------------------------------------
-- check_for_cobra
--
-- This procedure checks to see if there are COBRA Enrollments
-- that have a Qualifying Date on Termination Date + 1 (i.e. Enrollment
-- is as a result of the termination)
--
-- If this Termination will be removed as a result of the operation
-- then issue a warning stating that COBRA Coverage may no longer be
-- applicable
--
PROCEDURE check_for_cobra
(p_assignment_id IN INTEGER
,p_sdate         IN DATE
,p_edate         IN DATE
);
--
--
-----------------------------------------------------------------------
-- validate_pos
--
-- This procedure is called from hr_chg_date.call_session_date to ensure
-- that a new session date that is being set in PERWSEMA does not lie
-- outside the bounds of a Period of Service.
--
PROCEDURE validate_pos
(p_person_id IN VARCHAR2
,p_new_date  IN VARCHAR2
);
--
--
PROCEDURE load_assignment_allocation
                                 (p_assignment_id IN INTEGER
                                 ,p_business_group_id IN INTEGER
                                 ,p_effective_date IN DATE
                                 ,p_position_id in number);
--

--for bug 6598795
--mirror type of PER_ASSIGNMENTS_V

TYPE g_asg_type IS RECORD
(
ASSIGNMENT_ID                          PER_ALL_ASSIGNMENTS_F.ASSIGNMENT_ID%TYPE,
ROW_ID                                 VARCHAR2(16),
EFFECTIVE_START_DATE                   PER_ALL_ASSIGNMENTS_F.EFFECTIVE_START_DATE%TYPE,
D_EFFECTIVE_END_DATE                   PER_ALL_ASSIGNMENTS_F.EFFECTIVE_END_DATE%TYPE,
EFFECTIVE_END_DATE                     PER_ALL_ASSIGNMENTS_F.EFFECTIVE_END_DATE%TYPE,
BUSINESS_GROUP_ID                      PER_ALL_ASSIGNMENTS_F.BUSINESS_GROUP_ID%TYPE,
GRADE_ID                               PER_ALL_ASSIGNMENTS_F.GRADE_ID%TYPE,
GRADE_NAME                             PER_GRADES_TL.NAME%TYPE,
POSITION_ID                            PER_ALL_ASSIGNMENTS_F.POSITION_ID%TYPE,
POSITION_NAME                          VARCHAR2(240),
JOB_ID                                 PER_ALL_ASSIGNMENTS_F.JOB_ID%TYPE,
JOB_NAME                               PER_JOBS_TL.NAME%TYPE,
ASSIGNMENT_STATUS_TYPE_ID              PER_ALL_ASSIGNMENTS_F.ASSIGNMENT_STATUS_TYPE_ID%TYPE,
USER_STATUS                            PER_ASS_STATUS_TYPE_AMENDS_TL.USER_STATUS%TYPE,
PER_SYSTEM_STATUS                      PER_ASS_STATUS_TYPE_AMENDS.PER_SYSTEM_STATUS%TYPE,
PAYROLL_ID                             PER_ALL_ASSIGNMENTS_F.PAYROLL_ID%TYPE,
PAYROLL_NAME                           PAY_ALL_PAYROLLS_F.PAYROLL_NAME%TYPE,
LOCATION_ID                            PER_ALL_ASSIGNMENTS_F.LOCATION_ID%TYPE,
LOCATION_CODE                          HR_LOCATIONS_ALL_TL.LOCATION_CODE%TYPE,
SUPERVISOR_ID                          PER_ALL_ASSIGNMENTS_F.SUPERVISOR_ID%TYPE,
SUPERVISOR_NAME                        PER_ALL_PEOPLE_F.FULL_NAME%TYPE,
SUPERVISOR_EMPLOYEE_NUMBER             PER_ALL_PEOPLE_F.EMPLOYEE_NUMBER%TYPE,
SPECIAL_CEILING_STEP_ID                PER_ALL_ASSIGNMENTS_F.SPECIAL_CEILING_STEP_ID%TYPE,
SPINAL_POINT                           PER_SPINAL_POINTS.SPINAL_POINT%TYPE,
SPINAL_POINT_STEP_SEQUENCE             PER_SPINAL_POINT_STEPS_F.SEQUENCE%TYPE,
PERSON_ID                              PER_ALL_ASSIGNMENTS_F.PERSON_ID%TYPE,
ORGANIZATION_ID                        PER_ALL_ASSIGNMENTS_F.ORGANIZATION_ID%TYPE,
ORGANIZATION_NAME                      HR_ALL_ORGANIZATION_UNITS_TL.NAME%TYPE,
PEOPLE_GROUP_ID                        PER_ALL_ASSIGNMENTS_F.PEOPLE_GROUP_ID%TYPE,
ASSIGNMENT_SEQUENCE                    PER_ALL_ASSIGNMENTS_F.ASSIGNMENT_SEQUENCE%TYPE,
PRIMARY_FLAG                           PER_ALL_ASSIGNMENTS_F.PRIMARY_FLAG%TYPE,
ASSIGNMENT_NUMBER                      PER_ALL_ASSIGNMENTS_F.ASSIGNMENT_NUMBER%TYPE,
CHANGE_REASON                          PER_ALL_ASSIGNMENTS_F.CHANGE_REASON%TYPE,
CHANGE_REASON_MEANING                  VARCHAR2(240),
COMMENT_ID                             PER_ALL_ASSIGNMENTS_F.COMMENT_ID%TYPE,
COMMENT_TEXT                           HR_COMMENTS.COMMENT_TEXT%TYPE,
DATE_PROBATION_END                     PER_ALL_ASSIGNMENTS_F.DATE_PROBATION_END%TYPE,
D_DATE_PROBATION_END                   PER_ALL_ASSIGNMENTS_F.DATE_PROBATION_END%TYPE,
FREQUENCY                              PER_ALL_ASSIGNMENTS_F.FREQUENCY%TYPE,
FREQUENCY_MEANING                      VARCHAR2(240),
INTERNAL_ADDRESS_LINE                  PER_ALL_ASSIGNMENTS_F.INTERNAL_ADDRESS_LINE%TYPE,
MANAGER_FLAG                           PER_ALL_ASSIGNMENTS_F.MANAGER_FLAG%TYPE,
NORMAL_HOURS                           PER_ALL_ASSIGNMENTS_F.NORMAL_HOURS%TYPE,
PROBATION_PERIOD                       PER_ALL_ASSIGNMENTS_F.PROBATION_PERIOD%TYPE,
PROBATION_UNIT                         PER_ALL_ASSIGNMENTS_F.PROBATION_UNIT%TYPE,
PROBATION_UNIT_MEANING                 VARCHAR2(240),
TIME_NORMAL_FINISH                     PER_ALL_ASSIGNMENTS_F.TIME_NORMAL_FINISH%TYPE,
TIME_NORMAL_START                      PER_ALL_ASSIGNMENTS_F.TIME_NORMAL_START%TYPE,
BARGAINING_UNIT_CODE                   PER_ALL_ASSIGNMENTS_F.BARGAINING_UNIT_CODE%TYPE,
BARGAINING_UNIT_CODE_MEANING           VARCHAR2(240),
LABOUR_UNION_MEMBER_FLAG               PER_ALL_ASSIGNMENTS_F.LABOUR_UNION_MEMBER_FLAG%TYPE,
HOURLY_SALARIED_CODE                   PER_ALL_ASSIGNMENTS_F.HOURLY_SALARIED_CODE%TYPE,
HOURLY_SALARIED_CODE_MEANING           VARCHAR2(240),
LAST_UPDATE_DATE                       PER_ALL_ASSIGNMENTS_F.LAST_UPDATE_DATE%TYPE,
LAST_UPDATED_BY                        PER_ALL_ASSIGNMENTS_F.LAST_UPDATED_BY%TYPE,
LAST_UPDATE_LOGIN                      PER_ALL_ASSIGNMENTS_F.LAST_UPDATE_LOGIN%TYPE,
CREATED_BY                             PER_ALL_ASSIGNMENTS_F.CREATED_BY%TYPE,
CREATION_DATE                          PER_ALL_ASSIGNMENTS_F.CREATION_DATE%TYPE,
SAL_REVIEW_PERIOD                      PER_ALL_ASSIGNMENTS_F.SAL_REVIEW_PERIOD%TYPE,
SAL_REV_PERIOD_FREQ_MEANING            VARCHAR2(240),
SAL_REVIEW_PERIOD_FREQUENCY            PER_ALL_ASSIGNMENTS_F.SAL_REVIEW_PERIOD_FREQUENCY%TYPE,
PERF_REVIEW_PERIOD                     PER_ALL_ASSIGNMENTS_F.PERF_REVIEW_PERIOD%TYPE,
PERF_REV_PERIOD_FREQ_MEANING           VARCHAR2(240),
PERF_REVIEW_PERIOD_FREQUENCY           PER_ALL_ASSIGNMENTS_F.PERF_REVIEW_PERIOD_FREQUENCY%TYPE,
PAY_BASIS_ID                           PER_ALL_ASSIGNMENTS_F.PAY_BASIS_ID%TYPE,
SALARY_BASIS                           PER_PAY_BASES.NAME%TYPE,
PAY_BASIS                              PER_PAY_BASES.PAY_BASIS%TYPE,
RECRUITER_ID                           PER_ALL_ASSIGNMENTS_F.RECRUITER_ID%TYPE,
PERSON_REFERRED_BY_ID                  PER_ALL_ASSIGNMENTS_F.PERSON_REFERRED_BY_ID%TYPE,
RECRUITMENT_ACTIVITY_ID                PER_ALL_ASSIGNMENTS_F.RECRUITMENT_ACTIVITY_ID%TYPE,
SOURCE_ORGANIZATION_ID                 PER_ALL_ASSIGNMENTS_F.SOURCE_ORGANIZATION_ID%TYPE,
SOFT_CODING_KEYFLEX_ID                 PER_ALL_ASSIGNMENTS_F.SOFT_CODING_KEYFLEX_ID%TYPE,
VACANCY_ID                             PER_ALL_ASSIGNMENTS_F.VACANCY_ID%TYPE,
ASSIGNMENT_TYPE                        PER_ALL_ASSIGNMENTS_F.ASSIGNMENT_TYPE%TYPE,
APPLICATION_ID                         PER_ALL_ASSIGNMENTS_F.APPLICATION_ID%TYPE,
DEFAULT_CODE_COMB_ID                   PER_ALL_ASSIGNMENTS_F.DEFAULT_CODE_COMB_ID%TYPE,
PERIOD_OF_SERVICE_ID                   PER_ALL_ASSIGNMENTS_F.PERIOD_OF_SERVICE_ID%TYPE,
SET_OF_BOOKS_ID                        PER_ALL_ASSIGNMENTS_F.SET_OF_BOOKS_ID%TYPE,
D_SET_OF_BOOKS                         GL_SETS_OF_BOOKS.NAME%TYPE,
GL_KEYFLEX_STRUCTURE                   GL_SETS_OF_BOOKS.CHART_OF_ACCOUNTS_ID%TYPE,
SOURCE_TYPE                            PER_ALL_ASSIGNMENTS_F.SOURCE_TYPE%TYPE,
REQUEST_ID                             PER_ALL_ASSIGNMENTS_F.REQUEST_ID%TYPE,
PROGRAM_APPLICATION_ID                 PER_ALL_ASSIGNMENTS_F.PROGRAM_APPLICATION_ID%TYPE,
PROGRAM_ID                             PER_ALL_ASSIGNMENTS_F.PROGRAM_ID%TYPE,
PROGRAM_UPDATE_DATE                    PER_ALL_ASSIGNMENTS_F.PROGRAM_UPDATE_DATE%TYPE,
ASS_ATTRIBUTE_CATEGORY                 PER_ALL_ASSIGNMENTS_F.ASS_ATTRIBUTE_CATEGORY%TYPE,
ASS_ATTRIBUTE1                         PER_ALL_ASSIGNMENTS_F.ASS_ATTRIBUTE1%TYPE,
ASS_ATTRIBUTE2                         PER_ALL_ASSIGNMENTS_F.ASS_ATTRIBUTE2%TYPE,
ASS_ATTRIBUTE3                         PER_ALL_ASSIGNMENTS_F.ASS_ATTRIBUTE3%TYPE,
ASS_ATTRIBUTE4                         PER_ALL_ASSIGNMENTS_F.ASS_ATTRIBUTE4%TYPE,
ASS_ATTRIBUTE5                         PER_ALL_ASSIGNMENTS_F.ASS_ATTRIBUTE5%TYPE,
ASS_ATTRIBUTE6                         PER_ALL_ASSIGNMENTS_F.ASS_ATTRIBUTE6%TYPE,
ASS_ATTRIBUTE7                         PER_ALL_ASSIGNMENTS_F.ASS_ATTRIBUTE7%TYPE,
ASS_ATTRIBUTE8                         PER_ALL_ASSIGNMENTS_F.ASS_ATTRIBUTE8%TYPE,
ASS_ATTRIBUTE9                         PER_ALL_ASSIGNMENTS_F.ASS_ATTRIBUTE9%TYPE,
ASS_ATTRIBUTE10                        PER_ALL_ASSIGNMENTS_F.ASS_ATTRIBUTE10%TYPE,
ASS_ATTRIBUTE11                        PER_ALL_ASSIGNMENTS_F.ASS_ATTRIBUTE11%TYPE,
ASS_ATTRIBUTE12                        PER_ALL_ASSIGNMENTS_F.ASS_ATTRIBUTE12%TYPE,
ASS_ATTRIBUTE13                        PER_ALL_ASSIGNMENTS_F.ASS_ATTRIBUTE13%TYPE,
ASS_ATTRIBUTE14                        PER_ALL_ASSIGNMENTS_F.ASS_ATTRIBUTE14%TYPE,
ASS_ATTRIBUTE15                        PER_ALL_ASSIGNMENTS_F.ASS_ATTRIBUTE15%TYPE,
ASS_ATTRIBUTE16                        PER_ALL_ASSIGNMENTS_F.ASS_ATTRIBUTE16%TYPE,
ASS_ATTRIBUTE17                        PER_ALL_ASSIGNMENTS_F.ASS_ATTRIBUTE17%TYPE,
ASS_ATTRIBUTE18                        PER_ALL_ASSIGNMENTS_F.ASS_ATTRIBUTE18%TYPE,
ASS_ATTRIBUTE19                        PER_ALL_ASSIGNMENTS_F.ASS_ATTRIBUTE19%TYPE,
ASS_ATTRIBUTE20                        PER_ALL_ASSIGNMENTS_F.ASS_ATTRIBUTE20%TYPE,
ASS_ATTRIBUTE21                        PER_ALL_ASSIGNMENTS_F.ASS_ATTRIBUTE21%TYPE,
ASS_ATTRIBUTE22                        PER_ALL_ASSIGNMENTS_F.ASS_ATTRIBUTE22%TYPE,
ASS_ATTRIBUTE23                        PER_ALL_ASSIGNMENTS_F.ASS_ATTRIBUTE23%TYPE,
ASS_ATTRIBUTE24                        PER_ALL_ASSIGNMENTS_F.ASS_ATTRIBUTE24%TYPE,
ASS_ATTRIBUTE25                        PER_ALL_ASSIGNMENTS_F.ASS_ATTRIBUTE25%TYPE,
ASS_ATTRIBUTE26                        PER_ALL_ASSIGNMENTS_F.ASS_ATTRIBUTE26%TYPE,
ASS_ATTRIBUTE27                        PER_ALL_ASSIGNMENTS_F.ASS_ATTRIBUTE27%TYPE,
ASS_ATTRIBUTE28                        PER_ALL_ASSIGNMENTS_F.ASS_ATTRIBUTE28%TYPE,
ASS_ATTRIBUTE29                        PER_ALL_ASSIGNMENTS_F.ASS_ATTRIBUTE29%TYPE,
ASS_ATTRIBUTE30                        PER_ALL_ASSIGNMENTS_F.ASS_ATTRIBUTE30%TYPE,
EMPLOYMENT_CATEGORY                    PER_ALL_ASSIGNMENTS_F.EMPLOYMENT_CATEGORY%TYPE,
EMPLOYMENT_CATEGORY_MEANING            VARCHAR2(240),
ESTABLISHMENT_ID                       PER_ALL_ASSIGNMENTS_F.ESTABLISHMENT_ID%TYPE,
COLLECTIVE_AGREEMENT_ID                PER_ALL_ASSIGNMENTS_F.COLLECTIVE_AGREEMENT_ID%TYPE,
CONTRACT_ID                            PER_ALL_ASSIGNMENTS_F.CONTRACT_ID%TYPE,
CAGR_GRADE_DEF_ID                      PER_ALL_ASSIGNMENTS_F.CAGR_GRADE_DEF_ID%TYPE,
CAGR_ID_FLEX_NUM                       PER_ALL_ASSIGNMENTS_F.CAGR_ID_FLEX_NUM%TYPE,
AGREEMENT_NAME                         PER_COLLECTIVE_AGREEMENTS.NAME%TYPE,
ESTABLISHMENT_NAME                     HR_ALL_ORGANIZATION_UNITS.NAME%TYPE,
REFERENCE                              PER_CONTRACTS_F.REFERENCE%TYPE,
NOTICE_PERIOD                          PER_ALL_ASSIGNMENTS_F.NOTICE_PERIOD%TYPE,
NOTICE_PERIOD_UOM                      PER_ALL_ASSIGNMENTS_F.NOTICE_PERIOD_UOM%TYPE,
NOTICE_PERIOD_UOM_MEANING              VARCHAR2(240),
EMPLOYEE_CATEGORY                      PER_ALL_ASSIGNMENTS_F.EMPLOYEE_CATEGORY%TYPE,
EMPLOYEE_CATEGORY_MEANING              VARCHAR2(240),
WORK_AT_HOME                           PER_ALL_ASSIGNMENTS_F.WORK_AT_HOME%TYPE,
JOB_POST_SOURCE_NAME                   PER_ALL_ASSIGNMENTS_F.JOB_POST_SOURCE_NAME%TYPE,
TITLE                                  PER_ALL_ASSIGNMENTS_F.TITLE%TYPE,
PROJECT_TITLE                          PER_ALL_ASSIGNMENTS_F.PROJECT_TITLE%TYPE,
PERIOD_OF_PLACEMENT_DATE_START         PER_ALL_ASSIGNMENTS_F.PERIOD_OF_PLACEMENT_DATE_START%TYPE,
VENDOR_ID                              PER_ALL_ASSIGNMENTS_F.VENDOR_ID%TYPE,
VENDOR_NAME                            PO_VENDORS.VENDOR_NAME%TYPE,
VENDOR_SITE_ID                         PER_ALL_ASSIGNMENTS_F.VENDOR_SITE_ID%TYPE,
VENDOR_SITE_CODE                       PO_VENDOR_SITES_ALL.VENDOR_SITE_CODE%TYPE,
PO_HEADER_ID                           PER_ALL_ASSIGNMENTS_F.PO_HEADER_ID%TYPE,
PO_NUMBER                              PO_HEADERS_ALL.SEGMENT1%TYPE,
PO_LINE_ID                             PER_ALL_ASSIGNMENTS_F.PO_LINE_ID%TYPE,
PO_LINE_NUMBER                         PO_LINES_ALL.LINE_NUM%TYPE,
PROJECTED_ASSIGNMENT_END               PER_ALL_ASSIGNMENTS_F.PROJECTED_ASSIGNMENT_END%TYPE,
VENDOR_EMPLOYEE_NUMBER                 PER_ALL_ASSIGNMENTS_F.VENDOR_EMPLOYEE_NUMBER%TYPE,
VENDOR_ASSIGNMENT_NUMBER               PER_ALL_ASSIGNMENTS_F.VENDOR_ASSIGNMENT_NUMBER%TYPE,
ASSIGNMENT_CATEGORY                    PER_ALL_ASSIGNMENTS_F.ASSIGNMENT_CATEGORY%TYPE,
GRADE_LADDER_PGM_ID                    PER_ALL_ASSIGNMENTS_F.GRADE_LADDER_PGM_ID%TYPE,
SUPERVISOR_ASSIGNMENT_ID               PER_ALL_ASSIGNMENTS_F.SUPERVISOR_ASSIGNMENT_ID%TYPE,
GRADE_LADDER_NAME                      BEN_PGM_F.NAME%TYPE,
SUPERVISOR_ASSIGNMENT_NUMBER	         PER_ALL_ASSIGNMENTS_F.ASSIGNMENT_NUMBER%TYPE
);

-- update_assgn_context_value
--
-- populates the per_all_assignments_f.ass_attribute_category value
--
PROCEDURE update_assgn_context_value(
                                 p_business_group_id IN number
                                 ,p_person_id IN number
                                 ,p_assignment_id IN number
                                 ,p_effective_start_date IN date);

-- get_assgn_dff_value
--
-- returns the per_assignments_v row according to the passed arguments
--
PROCEDURE get_assgn_dff_value(
                                 p_business_group_id IN number
                                 ,p_person_id IN number
                                 ,p_assignment_id IN number
                                 ,p_effective_start_date IN DATE
                                 , p_asg_rec in out NOCOPY g_asg_type);
--end for bug 6598795
--
end hr_assignment;

/
