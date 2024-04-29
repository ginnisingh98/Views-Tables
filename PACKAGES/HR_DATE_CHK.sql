--------------------------------------------------------
--  DDL for Package HR_DATE_CHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_DATE_CHK" AUTHID CURRENT_USER as
/* $Header: pehchchk.pkh 115.2 2003/05/26 06:43:58 vramanai ship $ */
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
 Name        : hr_date_chk  (HEADER)

 Description : This package declares procedures required to test
               for the update of either period_of_service DATE_START
               or application DATE_RECEIVED.
               If the tests do not error then certain tables can be updated
               the new values for the fields.
*/
/*
 Change List
 -----------

 Version Date      Author     ER/CR No. Description of Change
 -------+---------+----------+---------+--------------------------
 70.0    23-MAY-93 Tmathers             Date Created
 70.4    15-feb-95 TMathers   264072    Added extra checks to check_sp_place
                                        ments.
 70.5    29-APR-95 TMathers   275487    Added check for supervisor/Payroll
                                        not existing
 70.7    15-May-95 RFine		Changed 'show errors' from package body
					to package.
 70.8    13-Jul-95 TMathers		Added check_for_cost_alloc for
                              292807
 70.9    27-Nov-96 VTreiger   401587    Added check_for_compl_actions.
 			      399253    Added check_for_contig_pos.
 115.2   26-may-03 vramanai   2947287   corrected GSCC errors and warnings
*/
------------------------- BEGIN: check_for_compl_actions ------------
procedure check_for_compl_actions(p_person_id NUMBER
                            ,p_s_start_date DATE
                            ,p_start_date DATE);
--
------------------------- BEGIN: check_for_contig_pos --------------------
procedure check_for_contig_pos(p_person_id NUMBER
                            ,p_s_start_date DATE
                            ,p_start_date DATE);
--
------------------------- BEGIN: check_supe_pay --------------------
procedure check_supe_pay(p_period_of_service_id NUMBER
                        ,p_start_date DATE);
--
------------------------- BEGIN: check_for_entries --------------------
procedure  check_for_entries(p_person_id NUMBER
                            ,p_period_of_service_id NUMBER
                            ,p_start_date DATE);
--
------------------------- BEGIN: check_for_sp_placements --------------------
procedure  check_for_sp_placements(p_person_id NUMBER
                            ,p_period_of_service_id NUMBER
                             ,p_start_date DATE);
--
------------------------- BEGIN: check_for_cost_alloc --------------------
procedure  check_for_cost_alloc(p_person_id NUMBER
                            ,p_period_of_service_id NUMBER
                             ,p_start_date DATE);
--
------------------------- BEGIN: check_people_changes --------------------
procedure check_people_changes(p_person_id NUMBER
                              ,p_earlier_date DATE
                              ,p_later_date DATE
                              ,p_start_date DATE);
--
------------------------- BEGIN: check_for_ass_st_chg --------------------
procedure check_for_ass_st_chg(p_person_id NUMBER
                              ,p_earlier_date DATE
                              ,p_later_date DATE
                              ,p_assignment_type VARCHAR2
                              ,p_start_date DATE);
--
------------------------- BEGIN: check_for_ass_chg --------------------
procedure check_for_ass_chg(p_person_id NUMBER
                            ,p_earlier_date DATE
                            ,p_later_date DATE
                            ,p_assignment_type VARCHAR2
                            ,p_s_start_date DATE
                            ,p_start_date DATE);
--
------------------------- BEGIN: check_for_prev_emp_ass --------------------
procedure check_for_prev_emp_ass(p_person_id NUMBER
                              ,p_assignment_type VARCHAR2
                              ,p_s_start_date DATE
                              ,p_start_date DATE);
--
------------------------- BEGIN: check_hire_ref_int --------------------
procedure check_hire_ref_int(p_person_id NUMBER
                              ,p_business_group_id NUMBER
                              ,p_period_of_service_id NUMBER
                              ,p_s_start_date DATE
                              ,p_system_person_type VARCHAR2
                              ,p_start_date DATE);
--
------------------------- BEGIN: update_hire_records --------------------
procedure update_hire_records(p_person_id NUMBER
                             ,p_app_number VARCHAR2
                             ,p_start_date DATE
                             ,p_s_start_date DATE
                             ,p_user_id NUMBER
                             ,p_login_id NUMBER);
--
------------------------- BEGIN: check_apl_ref_int --------------------
procedure check_apl_ref_int(p_person_id NUMBER
                           ,p_business_group_id NUMBER
                           ,p_system_person_type VARCHAR2
                           ,p_s_start_date DATE
                           ,p_start_date DATE);
--
------------------------- BEGIN: update_appl_records --------------------
procedure update_appl_records(p_person_id NUMBER
                             ,p_start_date DATE
                             ,p_s_start_date DATE
                             ,p_user_id NUMBER
                             ,p_login_id NUMBER);
--
end hr_date_chk;

 

/
