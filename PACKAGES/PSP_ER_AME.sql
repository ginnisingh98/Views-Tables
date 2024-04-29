--------------------------------------------------------
--  DDL for Package PSP_ER_AME
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_ER_AME" AUTHID CURRENT_USER as
/* $Header: PSPERAMS.pls 120.0 2005/06/02 16:02 appldev noship $*/
  procedure get_first_approvers(p_request_id    in integer,
                              p_start_person  in integer,
                              p_end_person    in integer,
                              p_return_status out nocopy varchar2,
                              p_retry_request_id in integer default null);

 /* The global variable G_APPROVER_BASIS is concatenated string of Effort Detail
 * attributes, for example it can take value "Assignment, Expenditure_Type".
 *
 * This variable will be  used when approval_type is CUSTOM,
 * and it is not used at all when seeded approval option is used.
 *
 * By default, when user chooses approval Type as CUSTOM, AME (Oracle Approvals
 *  Management) will be invoked for each Effort Detail record. A Effort report
 *  detail record contains effort percentages at the detail choosen in the
 *  summarization critera in the Template. For example effort detail record can
 *  contain values Asg, Project, Award, Task, Exp type.
 *
 *  When AME is invoked, it returns a single approver or list of Approvers
 *  for detail record as setup in AME. For example, if a employee works on 6
 *  different combinations of Project/Task/Award/Exp org/GL account, then
 *  AME will invoked 6 times.
 *
 *  However if at a customer site, a approver is based on
 *  distinct combination of Project and Exp type, there is no point in invoking
 *  AME for each detail record. In this case, AME should be invoked only for
 *  each distinct combination of emp or/and asg, Project, Exp type.
 *
 *  This kind of optimization is already built-in, for Seeded options. For example,
 *  when approval type is "Principal Investigator of Grant" then AME will be invoked
 *  only for each Award. In order to extend similar optimization to CUSTOM approval
 *  type, this global variable has been introduced. This global
 *  variable will be set to string of effort attributes such that, invoking AME
 *  once for each distinct combination of these attributes will suffice to get all
 *  required approvers.
 *
 * In other words, this global variable can be used to improve performance
 * (by reducing calls to AME) when approval type is CUSTOM. To get the exact
 * names of the attributes please see the column names of table
 * PSP_EFF_REPORT_DETAILS.
 *
 * Another Global variable G_NO_OF_ATTRIBUTES should be set to  number of
 * attributes  in the concatenated string G_APPROVAL_BASIS. In the example above
 * it should be set to 2.
 */


  g_approver_basis varchar2(2000) := ' ';
  g_no_of_attributes integer := 0;
end;

 

/
