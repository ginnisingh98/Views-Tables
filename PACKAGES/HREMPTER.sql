--------------------------------------------------------
--  DDL for Package HREMPTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HREMPTER" AUTHID CURRENT_USER AS
/* $Header: peempter.pkh 120.1.12010000.1 2008/07/28 04:36:08 appldev ship $ */
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
 Name        : hrempter  (HEADER)

 Description : This package declares procedures required to
               terminate and cancel the termination of an employee.


 Change List
 -----------

 Version Date      Author     ER/CR No. Description of Change
 -------+---------+----------+---------+--------------------------
 70.0    11-FEB-93 SZWILLIA             Date Created
 70.1	 11-MAR-93 NKHAN		Added 'exit' to end of code
 70.6	   20-APR-95 TMathers	271941    Fixed the WWBUG
					 Also added flag to allow only
					 some of Term
					 details to be deleted.
 70.7   26-MAR-1995 TMathers    276096  Added Legislation code to
                                        terminate_alu procedure.
 70.8   25-Oct-1995 JTHURING            Missing ???.
 70.9   17-Oct-1996 VTreiger    306710  Added parameter p_entries
                                        _changed_warning to procedure
                                        terminate_entries_and_alus.
70.10   01-Nov-1996 VTreiger    306710  Added procedure terminate_
                                        entries_and_alus overload.
110.1   14-Sep-2001 M Bocutt   1271513  Added some additional procedures
                                        required for terminations rework.
115.4   22-AUG-2002 adhunter            correct GSCC warning
115.5   05-DEC-2002 pkakar              -
115.6   22-MAR-2006 LSilveir   4449472  Overloaded the procedure
                                        terminate_entries_and_alus
 ================================================================= */
--
--
  PROCEDURE terminate_employee(p_trigger                    VARCHAR2
                              ,p_business_group_id          NUMBER
                              ,p_person_id                  NUMBER
                              ,p_assignment_status_type_id  NUMBER
                              ,p_actual_termination_date    DATE
                              ,p_last_standard_process_date DATE
                              ,p_final_process_date         DATE);
--
--
  PROCEDURE employee_shutdown(p_trigger            VARCHAR2
                             ,p_person_id          NUMBER
                             ,p_final_process_date DATE);
--
--
  PROCEDURE cancel_termination(p_person_id                NUMBER
                              ,p_actual_termination_date  DATE
                              ,p_clear_details            VARCHAR2 DEFAULT 'N');
--
--
  PROCEDURE terminate_entries_and_alus(p_assignment_id      NUMBER,
                                       p_actual_term_date   DATE,
                                       p_last_standard_date DATE,
                                       p_final_process_date DATE,
                                       p_legislation_code VARCHAR2 DEFAULT
                                       NULL);
--
--
  PROCEDURE terminate_entries_and_alus(p_assignment_id      NUMBER,
                                       p_actual_term_date   DATE,
                                       p_last_standard_date DATE,
                                       p_final_process_date DATE,
                                       p_legislation_code VARCHAR2 DEFAULT
                                       NULL,
                                       p_entries_changed_warning IN OUT
                                       VARCHAR2);
--
-- 115.6 (START)
--
  PROCEDURE terminate_entries_and_alus(p_assignment_id      NUMBER,
                                       p_actual_term_date   DATE,
                                       p_last_standard_date DATE,
                                       p_final_process_date DATE,
                                       p_legislation_code VARCHAR2 DEFAULT
                                       NULL,
                                       p_entries_changed_warning IN OUT
                                       VARCHAR2,
                                       p_alu_change_warning      IN OUT
                                       VARCHAR2);
--
-- 115.6 (END)
--
  PROCEDURE delete_de_assign(p_assignment_id    NUMBER
                            ,p_delete_date      DATE);

--
--
  PROCEDURE delete_assign_fpd(p_assignment_id        NUMBER
                             ,p_final_process_date   DATE);
--
--
  PROCEDURE delete_assign_atd(p_assignment_id           NUMBER
                             ,p_actual_termination_date DATE);



end hrempter;

/
