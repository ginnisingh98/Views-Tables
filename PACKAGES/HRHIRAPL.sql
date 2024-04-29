--------------------------------------------------------
--  DDL for Package HRHIRAPL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRHIRAPL" AUTHID CURRENT_USER AS
/* $Header: pehirapl.pkh 120.0.12010000.1 2008/07/28 04:48:18 appldev ship $ */
/*
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
 Name        : hrhirapl  (HEADER)

 Description : Package contains procedures used when hiring an
               applicant (PER_SYSTEM_STATUS='APL') or an
               employee_applicant (PER_SYSTEM_STATUS='EMP_APL').

 Change List
 -----------
 Version Date      Author     ER/CR No. Description of Change
 -------+---------+----------+---------+--------------------------
 70.0    11-JAN-93 JRHODES              Date Created
 70.1    19-APR-93 TMATHERS             Added end_unaccepted_app_assign.
 70.2    10-Jun-93 TMathers             Added p_employee_number to
                                        employ applicant.
 70.5    10-Jan-94 TMathers             Added p_set_of_books_id to
                                        employ applicant.
 70.7    29-Apr-95 TMathers   275870    Added End bookings.
 70.9    23-Apr-96 AMills     294004    Added definition of ins_per_list
                                        to make the procedure externally
                                        visible.
115.1    05-May-98 CCarter              p_adjusted_svc_date added to
                                        employ_applicant procedure for OAB
                                        development
115.2    13-MAR-1999 mmillmor 795287    corrected ins_per_list to work with
                                        EMP-APL's
115.5    18-mar-2002 irgonzal           Reverted 2119831 changes.
115.6    17-apr-2002 irgonzal 2264569   Modified employ_applicant procedure.
                                        Includes fix to WWBUG 2119831.
115.8    20-APR-2004 kjagadee 3564129   Added parameter p_session_date to
                                        procedure EMPLOY_APPLICANT.
================================================================= */
PROCEDURE employ_applicant (p_person_id IN INTEGER
                                 ,p_business_group_id IN INTEGER
                                 ,p_legislation_code IN VARCHAR2
                                 ,p_new_primary_id IN INTEGER
                                 ,p_assignment_status_type_id IN INTEGER
                                 ,p_user_id IN INTEGER
                                 ,p_login_id IN INTEGER
                                 ,p_start_date IN DATE
                                 ,p_end_of_time IN DATE
                                 ,p_current_date IN DATE
                                 ,p_update_primary_flag VARCHAR2
                                 ,p_employee_number VARCHAR2
                                 ,p_set_of_books_id IN INTEGER
                                 ,p_emp_apl VARCHAR2
                                 ,p_adjusted_svc_date IN DATE
                                 ,p_session_date IN DATE -- Bug 3564129
                                 -- #2264569
                                 ,p_table IN hr_employee_applicant_api.t_ApplTable
                                       default hr_employee_applicant_api.T_EmptyAPPL
--
                                );
--
--
procedure end_unaccepted_app_assign(p_person_id IN INTEGER
                                   ,p_business_group_id IN INTEGER
                                   ,p_legislation_code IN VARCHAR2
                                   ,p_end_date IN DATE
                                   -- #2264569
                                   ,p_table IN hr_employee_applicant_api.t_ApplTable
                                       default hr_employee_applicant_api.T_EmptyAPPL
                                   );
--
--
procedure ins_per_list(p_person_id IN number
                      ,p_business_group_id IN  number
                      ,p_legislation_code IN VARCHAR2 default NULL
                      ,p_start_date IN DATE
                      ,p_apl in VARCHAR2 default 'Y'
                      ,p_emp in VARCHAR2 default 'N');
--
--
procedure end_bookings(p_person_id number
                          ,p_business_group_id number
                          ,p_start_date DATE);
--
end hrhirapl;

/
