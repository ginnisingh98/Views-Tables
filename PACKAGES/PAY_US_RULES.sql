--------------------------------------------------------
--  DDL for Package PAY_US_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_RULES" AUTHID CURRENT_USER as
/* $Header: pyusrule.pkh 120.6.12010000.5 2009/04/17 13:31:27 sudedas ship $ */
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1993 Oracle Corporation.                        *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************

    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  -------------------------------
    23-APR-2004 sdahiya    115.0            Created.
    17-APR-2005 rdhingra   115.1            Added Global Variable and
                                            Declarations for user exit
                                            calls Pre-Process, upd_user_stru
                                            and Post-Process made from Global
                                            Element Template. Also added
                                            declaration of get_obj_id
                                            function.
    28-APR-2005 sodhingr   115.2            Added the function work_schedule
                                            _total_hours used by new work
                                            schedule functionality
    29-APR-2005 rdhingra   115.3   FLSA     Added Procedure call for
                                            get_time_def_for_entry
                                            and related Global variables
    19-JUL-2005 rdhingra   115.4   FLSA2    Added Procedure call for
                                            delete_pre_process and
                                            delete_post_process
    11-AUG-2005 kvsankar   115.5   FLSA2    Added a new function
                                            get_time_def_for_entry_func
                                            which has a pragma restric
                                            reference associated with it.
    13-MAR-2007 kvsankar   115.6   FLSA     Added a new global variable
                                            g_get_time_def_flag
    24-May-2007 sausingh   115.7   5635335  Added procedure add_custom_xml
                                            for displaying Net Pay Amount in
                                            words in (Archived) Check Writer/
                                            Deposit Advice.
    26-Jun-2007            115.8            Modified add_custom_xml to print
                                            Check Number and Amount. Added
                                            procedure get_token_names.
   15-Jan-2009 sudedas    115.10  7583387   Added 3 functions for DA(XML) -
                                            get_payslip_sort_order1
                                            get_payslip_sort_order2
                                            get_payslip_sort_order3
                                            Added payslip_range_cursor.
   21-Jan-2009 sudedas      115.11 7583387  Changed Function DAxml_range_cursor
                                            to Procedure.
                            115.12 7583387  Added NOCOPY hint for OUT variable.
   17-Apr-2009 sudedas      115.13 8414024  Added IN OUT parameter to function
                                            work_schedule_total_hours.
  *****************************************************************************/

  /****************************************************************************
    Name        : GET_DEFAULT_JUSRIDICTION
    Description : This function returns the default jurisdiction code which is
                  used for involuntary deduction elements if the end user does
                  not specify jurisdiction input value.
  *****************************************************************************/

PROCEDURE get_default_jurisdiction(p_asg_act_id number,
                                   p_ee_id number,
                                   p_jurisdiction in out nocopy varchar2);

l_pkg_name varchar2(20);

-- GLOBAL VARIABLE ADDED
lrec   pay_ele_tmplt_obj;
-- For Procedure get_time_def_for_entry
g_current_asg_id NUMBER;
g_current_time_def_id NUMBER;
g_get_time_def_flag BOOLEAN;

FUNCTION element_template_pre_process (p_rec IN pay_ele_tmplt_obj)
                                       RETURN pay_ele_tmplt_obj;


PROCEDURE element_template_upd_user_stru (p_element_template_id IN NUMBER);

PROCEDURE element_template_post_process (p_element_template_id IN NUMBER);

PROCEDURE delete_pre_process(p_element_template_id IN NUMBER);

PROCEDURE delete_post_process(p_element_template_id IN NUMBER);

FUNCTION get_obj_id(p_business_group_id IN NUMBER
                    ,p_legislation_code IN VARCHAR2
                    ,p_object_type IN VARCHAR2
                    ,p_object_name IN VARCHAR2
                    ,p_object_id IN NUMBER DEFAULT NULL)
                    RETURN NUMBER;

FUNCTION work_schedule_total_hours(
                assignment_action_id  IN NUMBER   --Context
               ,assignment_id         IN NUMBER   --Context
               ,p_bg_id		          in NUMBER   -- Context
               ,element_entry_id      IN NUMBER   --Context
               ,date_earned           IN DATE
     		   ,p_range_start	      IN DATE
      	   ,p_range_end           IN DATE
               ,p_wk_sch_found   IN OUT NOCOPY VARCHAR2)
RETURN NUMBER ;

PROCEDURE get_time_def_for_entry (
   p_element_entry_id      IN              NUMBER,
   p_assignment_id         IN              NUMBER,
   p_assignment_action_id  IN              NUMBER,
   p_business_group_id     IN              NUMBER,
   p_time_definition_id    IN OUT NOCOPY   VARCHAR2
);

FUNCTION get_time_def_for_entry_func(
   p_element_entry_id      IN              NUMBER,
   p_assignment_id         IN              NUMBER,
   p_assignment_action_id  IN              NUMBER,
   p_business_group_id     IN              NUMBER,
   p_time_def_date         IN              DATE
) RETURN NUMBER;

pragma restrict_references(get_time_def_for_entry_func, WNDS, WNPS);

-- Converting Numeric Amounts to Words (To be Displayed on Check Writer)
FUNCTION convert_number(IN_NUMERAL INTEGER := 0) RETURN VARCHAR2 ;
FUNCTION get_word_value (P_AMOUNT NUMBER) RETURN VARCHAR2 ;
FUNCTION CF_word_amountFormula(CP_LN_AMOUNT IN NUMBER) RETURN VARCHAR2 ;

PROCEDURE add_custom_xml( P_ASSIGNMENT_ACTION_ID IN NUMBER ,
                          P_ACTION_INFORMATION_CATEGORY IN VARCHAR2,
                          P_DOCUMENT_TYPE IN VARCHAR2);
-- Added Procedure get_token_names to be used by Global Payslip Printing
-- Solution pay_payslip_report.xml_asg
procedure get_token_names(p_pa_token out nocopy varchar2
                         ,p_cs_token out nocopy varchar2);

--
--
FUNCTION get_payslip_sort_order1 RETURN VARCHAR2;
--
FUNCTION get_payslip_sort_order2 RETURN VARCHAR2;
--
FUNCTION get_payslip_sort_order3 RETURN VARCHAR2;
--
--

PROCEDURE payslip_range_cursor(p_pactid in number
                              ,p_sqlstr out NOCOPY varchar2);

END PAY_US_RULES;

/
