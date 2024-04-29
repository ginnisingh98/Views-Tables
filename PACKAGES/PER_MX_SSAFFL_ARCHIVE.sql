--------------------------------------------------------
--  DDL for Package PER_MX_SSAFFL_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_MX_SSAFFL_ARCHIVE" AUTHID CURRENT_USER AS
/* $Header: pemxafar.pkh 120.0.12000000.1 2007/01/22 00:14:40 appldev ship $ */
--
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
   ******************************************************************

   Change List
   -----------
   Date         Name        Vers   Bug No   Description
   -----------  ----------  -----  -------  -----------------------------------
   03-MAY-2004  kthirmiy    115.0           Created.
   16-JUL-2004  kthirmiy    115.1           Added t_int_asg_event_rec and
                                            t_int_asg_event_table.
                                            Added new function get_start_date
                                            to return the archive run start date.
   02-AUG-2004  kthirmiy    115.2           Removed t_details_table type.
   02-AUG-2004  kthirmiy    115.3           Added Invalid_rec_flag.
   05-AUG-2004  kthirmiy    115.4           Removed Invlaid_rec_flag.
   07-Jan-2005  kthirmiy    115.5  4104743  Added a new function get_default_imp_date
                                            to return the default Implementation date
                                            from pay_mx_legislation_info_f table.
   20-Jan-2005  ardsouza    115.6  4129001  Added p_business_group_id parameter to
                                            procedure "derive_gre_from_loc_scl".

*/
--

  FUNCTION get_default_imp_date
  RETURN VARCHAR2 ;

  FUNCTION get_start_date( p_legal_emp_id IN VARCHAR2
                          ,p_tran_gre_id  IN VARCHAR2
                          ,p_gre_id       IN VARCHAR2
                         ) RETURN VARCHAR2 ;


  PROCEDURE get_payroll_action_info(p_payroll_action_id   IN         NUMBER
                                   ,p_start_date          OUT NOCOPY DATE
                                   ,p_end_date            OUT NOCOPY DATE
                                   ,p_business_group_id   OUT NOCOPY NUMBER
                                   ,p_tran_gre_id         OUT NOCOPY NUMBER
                                   ,p_gre_id              OUT NOCOPY NUMBER
                                   ,p_event_group_id      OUT NOCOPY NUMBER
                                   );

  PROCEDURE range_cursor(p_payroll_action_id IN        NUMBER
                        ,p_sqlstr           OUT NOCOPY VARCHAR2);

  PROCEDURE action_creation(p_payroll_action_id   IN NUMBER
                           ,p_start_assignment_id IN NUMBER
                           ,p_end_assignment_id   IN NUMBER
                           ,p_chunk               IN NUMBER);

  PROCEDURE archive_data(p_assignment_action_id  IN NUMBER
                        ,p_effective_date        IN DATE);


  PROCEDURE archinit(p_payroll_action_id IN NUMBER);

  FUNCTION derive_gre_from_loc_scl(
                 p_location_id             IN NUMBER
                ,p_business_group_id       IN NUMBER -- Bug 4129001
                ,p_soft_coding_keyflex_id  IN NUMBER
                ,p_effective_date          IN DATE ) RETURN NUMBER ;


TYPE t_int_asg_event_rec IS RECORD
(
    update_type          pay_datetracked_events.update_type%TYPE  ,
    effective_date       DATE,
    column_name          pay_event_updates.column_name%TYPE       ,
    old_value            VARCHAR2(2000),
    new_value            VARCHAR2(2000),
    column_name1         pay_event_updates.column_name%TYPE       ,
    old_value1           VARCHAR2(2000),
    new_value1           VARCHAR2(2000)
);

  TYPE t_int_asg_event_table IS
      TABLE OF t_int_asg_event_rec
        INDEX BY BINARY_INTEGER;

END per_mx_ssaffl_archive;

 

/
