--------------------------------------------------------
--  DDL for Package PAY_CA_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_RULES" AUTHID CURRENT_USER as
/*   $Header: pycarule.pkh 120.4.12010000.4 2010/05/07 09:00:08 sneelapa ship $ */
/*
   Copyright (c) Oracle Corporation 1991,1992,1993,1994. All rights reserved
--
   Name        : pay_ca_rules
--
   Change List
   -----------
   Date         Name        Vers   Description
   -----------  ----------  -----  -------------------------------------------
   07-MAY-2010  sneelapa    115.9  Bug 9692321.
                                   Added add_custom_xml procedure without parameters.

   18-MAR-2010  aneghosh    115.8  Bug 9445414. CA PDF payslip Enhancement.
                                   Added add_custom_xml procedure with parameters.
   30-APR-2009  sapalani    115.7  For bug 8459792, Added new IN OUT parameter
                                   p_wk_sch_found to function
                                   work_schedule_total_hours.
   10-AUG-2006  pganguly    115.6  Added nocopy in FILE_NO out parameter.
   10-AUG-2006  pganguly    115.5  Added get_file_creation_number prcedure.
                                   Also changed the signature of add_custom
                                   _xml procedure.
   27-OCT-2005  mmukherj   115.4   Added the function work_schedule_total_hours
                                   used by new work schedule functionality
   03-OCT-2005  mmukherj    115.3  Added add_custom_xml procedure
   10-APR-2003  vpandya     115.2  Added get_multi_tax_unit_pay_flag procedure
                                   to get 'Payroll Archiver Level' of the
                                   business group to process payroll run.
   04-SEP-2002  vpandya     115.1  Added get_dynamic_tax_unit procedure for
                                   Multi GRE functionality.
   23-APR-1999  mmukherj    110.0  Created.
*/

   procedure get_default_jurisdiction(p_asg_act_id number,
                                      p_ee_id number,
                                      p_jurisdiction in out nocopy varchar2);

   procedure get_dynamic_tax_unit(p_asg_act_id   in     number,
                                  p_run_type_id  in     number,
                                  p_tax_unit_id  in out nocopy number);

   procedure get_multi_tax_unit_pay_flag
                              (p_bus_grp   in number,
                               p_mtup_flag in out nocopy varchar2);

   PROCEDURE add_custom_xml;

   -- add_custom_xml with parameters is added for CA PDF Payslip enhancement.

   PROCEDURE add_custom_xml(P_ASSIGNMENT_ACTION_ID IN NUMBER ,
                          P_ACTION_INFORMATION_CATEGORY IN VARCHAR2,
                          P_DOCUMENT_TYPE IN VARCHAR2);

   FUNCTION work_schedule_total_hours(
                assignment_action_id  IN NUMBER   --Context
               ,assignment_id         IN NUMBER   --Context
               ,p_bg_id		      in NUMBER   -- Context
               ,element_entry_id      IN NUMBER   --Context
               ,date_earned           IN DATE
	       ,p_range_start	      IN DATE
      	       ,p_range_end           IN DATE
               ,p_wk_sch_found   IN OUT NOCOPY VARCHAR2)
   RETURN NUMBER ;

   PROCEDURE get_file_creation_no(
              PACTID IN NUMBER,
              FILE_NO OUT NOCOPY NUMBER);

end pay_ca_rules;

/
