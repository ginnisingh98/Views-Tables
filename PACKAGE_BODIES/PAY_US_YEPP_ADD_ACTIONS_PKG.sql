--------------------------------------------------------
--  DDL for Package Body PAY_US_YEPP_ADD_ACTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_YEPP_ADD_ACTIONS_PKG" AS
/* $Header: pyusyeaa.pkb 120.3 2006/08/30 00:11:18 sodhingr noship $ */
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

    Name        : pay_us_yepp_add_actions_pkg

    Description : Package used to report the Employees which are not
                  picked up by the Year End Process and mark them for
                  retry. It is used by the concurrent request -
                 'Add Assignment Actions To The Year End Pre-Process'


    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  --------------------------
    01-Sep-2003 kaverma    115.0   2222748  Created.
    03-Sep-2003 kaverma    115.1   2222748  Modified cursor c_w2_magtape_run_exists
                                            to check run of Federal Magtapes
    12-Sep-2003 kaverma    115.2   3137858  Correct the layout and insertion of
                                            person_id when creating actions.
    20-Nov-2003 sdahiya    115.3   3263078  Modified cursor c_w2_magtape_run_exists
                                            to correctly identify whether state 1099R/W2 magtape
                                            processes have been run for GREs in a given
                                            business group. Removed tax_unit_id parameter
                                            and modified statement opening this cursor.
    21-Nov-2003 sdahiya    115.4   3263078  The cursor c_w2_magtape_run_exists is modified to
                                            check existence of 1099R magtape runs for 1099R GRE and
                                            W2 magtape runs for W2 GRE.
    12-Dec-2003 kaverma    115.5   3228332  Report should not pick up rehired employee
                                            if terminated employee is alreday archived in YEPP.
                                            modified c_get_latest_asg cursor.
    13-Dec-2003 sodhingr   115.6   3228332 changed the cursor c_get_latest_asg to check for
                                            assignment_type = 'E' and also added the condition
                                            to check if an assignment action is already created for the
                                            same person
    20-Aug-2004 meshah     115.7   3440806  changed the following
                                            cursor c_get_latest_asg,
                                            cursor c_get_processed_assignments,
                                            PROCEDURE
                                            report_secondary_assignments and
                                            added CURSOR c_get_asg_id
    26-Aug-2004 meshah     115.8            fixed gscc error.
    01-Sep-2004 meshah     115.9            disabled the index on
                                            pay_action_classification
                                            in cursor c_get_latest_asg
    04-Nov-2004 meshah     115.10  3984539  changed the sequence of
                                            get_eligible_assignments and
                                            get_processed_assignments in the
                                            Main of add_actions_to_yepp.
                                            commented the cursor
                                            get_already_marked_assignments.
                                            changed the date join conditions
                                            for CURSOR c_get_asg_id.
    18-Apr-2006 alikhar    115.12  5120818  Performance fix for cursor c_get_latest_asg.
    				   	    Added Ordered hint.
    25-Aug-2006 saurgupt   115.13  3829668  Added the procedure create_archive to insert record into
                                            ff_archive_items while creating assignment actions.
    29-AUG-2006 sodhingr   115.14  3829668  archive A_ADD_ARCHIVE= Y when an assigment
                                            is added to archive
  ********************************************************************/


 /********************************************************************
  ** Local Package Variables
  ********************************************************************/
  gv_title               VARCHAR2(100) := 'Add Assignment Actions Report';
  gv_package_name        VARCHAR2(50)  := 'pay_us_yepp_add_actions_pkg';
  gv_sec_asg_reported    VARCHAR2(1)   := 'N';


 /********************************************************************
  Function to display the Titles of the columns of the employee details
  ********************************************************************/

  FUNCTION  formated_header_string(
              p_output_file_type  in varchar2
             )RETURN varchar2
   IS

    lv_format1          varchar2(32000);

   BEGIN

     hr_utility.set_location(gv_package_name || '.formated_header_string', 10);
     lv_format1 :=
       pay_us_payroll_utils.formated_data_string
                            (p_input_string => 'Year '
                            ,p_bold         => 'Y'
                            ,p_output_file_type => p_output_file_type) ||
       pay_us_payroll_utils.formated_data_string
                            (p_input_string => 'GRE '
                            ,p_bold         => 'Y'
                            ,p_output_file_type => p_output_file_type) ||
       pay_us_payroll_utils.formated_data_string
                            (p_input_string => 'Employee Name '
                            ,p_bold         => 'Y'
                            ,p_output_file_type => p_output_file_type) ||
       pay_us_payroll_utils.formated_data_string
                            (p_input_string => 'Employee SS # '
                            ,p_bold         => 'Y'
                            ,p_output_file_type => p_output_file_type) ||
       pay_us_payroll_utils.formated_data_string
                            (p_input_string => 'Employee #'
                            ,p_bold         => 'Y'
                            ,p_output_file_type => p_output_file_type) ;

     hr_utility.trace('Static Label1 = ' || lv_format1);

     hr_utility.set_location(gv_package_name || '.formated_header_string', 40);
     return lv_format1 ;

   EXCEPTION
      WHEN OTHERS THEN
        hr_utility.trace('Error in gv_package_name' || '.formated_header_string');
        RAISE;

   END formated_header_string;



 /********************************************************************
  Function to display the details of the selected employee
  ********************************************************************/

  FUNCTION  formated_detail_string(
              p_output_file_type  in varchar2
             ,p_year                 varchar2
             ,p_gre                  varchar2
             ,p_Employee_name        varchar2
             ,p_employee_ssn        varchar2
             ,p_emplyee_number       varchar2

             ) RETURN varchar2
   IS

    lv_format1          varchar2(22000);

   BEGIN

     hr_utility.set_location(gv_package_name || '.formated_detail_string', 10);
     lv_format1 :=
       pay_us_payroll_utils.formated_data_string
                            (p_input_string => p_year
                            ,p_bold         => 'N'
                            ,p_output_file_type => p_output_file_type) ||
       pay_us_payroll_utils.formated_data_string
                            (p_input_string => p_gre
                            ,p_bold         => 'N'
                            ,p_output_file_type => p_output_file_type) ||
       pay_us_payroll_utils.formated_data_string
                            (p_input_string => p_employee_name
                            ,p_bold         => 'N'
                            ,p_output_file_type => p_output_file_type) ||
       pay_us_payroll_utils.formated_data_string
                            (p_input_string => P_employee_ssn
                            ,p_bold         => 'N'
                            ,p_output_file_type => p_output_file_type) ||
       pay_us_payroll_utils.formated_data_string
                            (p_input_string => p_emplyee_number
                            ,p_bold         => 'N'
                            ,p_output_file_type => p_output_file_type);

      hr_utility.set_location(gv_package_name || '.formated_detail_string', 20);
      hr_utility.trace('Static Label1 = ' || lv_format1);
      hr_utility.set_location(gv_package_name || '.formated_detail_string', 30);

      return lv_format1;

   EXCEPTION
      WHEN OTHERS THEN
        hr_utility.trace('Error in '|| gv_package_name || '.formated_detail_string');
        RAISE;

   END formated_detail_string;



 /********************************************************************
  Procedure to display message if no employees are selected for
  any of the four sections -
  - Processed Assignments
  - Eligible Assignments
  - Not Eligible Assignments
  - Secondary Assignments
  ********************************************************************/

  PROCEDURE  formated_zero_count(output_file_type varchar2,
                                 p_flag varchar2)
   IS
      lvc_message1 varchar2(200);
      lvc_message2 varchar2(200);
      lvc_message3 varchar2(200);

      lvc_return_message varchar2(400);
   BEGIN

     hr_utility.set_location(gv_package_name || '.formated_zero_count', 10);

     lvc_message1 :=   '1. No employee from assignment set is already processed by'
                       || ' Year End Pre-Process.';
     lvc_message2 :=   '2. No employee from assignment set is eligible for Year'
                       || ' End Pre-Prcocess.';
     lvc_message3 :=   '3. Following employees are not eligible for Year End Pre-'
                       ||'Process: None';

     if output_file_type = 'HTML' then
        lvc_message1 := '<H4> '||lvc_message1||' </H4>';
	lvc_message2 := '<H4> '||lvc_message2||' </H4>';
	lvc_message3 := '<H4> '||lvc_message3||' </H4>';
     end if;

     if p_flag='PROCESSED' then
        fnd_file.put_line(fnd_file.output,lvc_message1);
     end if;

     hr_utility.set_location(gv_package_name || '.formated_zero_count', 20);

     if p_flag='ELGBLE' then
        fnd_file.put_line(fnd_file.output, lvc_message2);
     end if;

     hr_utility.set_location(gv_package_name || '.formated_zero_count', 30);

     if p_flag='NOTELGBLE' then
        fnd_file.put_line(fnd_file.output, lvc_message3);
     end if;

     hr_utility.set_location(gv_package_name || '.formated_zero_count', 40);

   EXCEPTION
      WHEN OTHERS THEN
        hr_utility.trace('Error in '|| gv_package_name || '.formated_zero_count');
        RAISE;

   END formated_zero_count;



 /********************************************************************
  Procedure to print the table in HTML format
  ********************************************************************/

  PROCEDURE print_table_header (p_header_text      in varchar2,
                                p_output_file_type in varchar2)
   IS
    l_header_text  varchar2(200);
   BEGIN
     hr_utility.set_location(gv_package_name || '.print_table_header', 10);
     l_header_text  := p_header_text ;

     if p_output_file_type = 'HTML' then
        l_header_text := '<H4> '||l_header_text||' </H4>';
     end if;

     fnd_file.put_line(fnd_file.output,l_header_text);

     if p_output_file_type ='HTML' then
        fnd_file.put_line(fnd_file.output, '<table border=1 align=center>');
        fnd_file.put_line(fnd_file.output, '<tr>');
     end if;

     hr_utility.set_location(gv_package_name || '.print_table_header', 20);

     fnd_file.put_line(fnd_file.output,formated_header_string(p_output_file_type));

     if p_output_file_type ='HTML' then
        fnd_file.put_line(fnd_file.output, '</tr>');
     end if;

     hr_utility.set_location(gv_package_name || '.print_table_header', 30);

    EXCEPTION
      WHEN OTHERS THEN
        hr_utility.trace('Error in '|| gv_package_name || '.print_table_header');
        RAISE;
   END print_table_header;



 /********************************************************************
  Name    : bal_db_item
  Purpose : Given the name of a balance DB item as would be seen in a
            fast formula it returns the defined_balance_id of the
            balance it represents.
   Notes  : A defined balance_id is required by the PLSQL balance
            function.
  /*******************************************************************/

  FUNCTION bal_db_item (p_db_item_name varchar2)
          RETURN number
  IS

  /* Get the defined_balance_id for the specified balance DB item. */

   cursor csr_defined_balance
    is
    select to_number(ue.creator_id)
     from  ff_user_entities  ue,
           ff_database_items di
     where di.user_name            = p_db_item_name
       and ue.user_entity_id       = di.user_entity_id
       and ue.creator_type         = 'B'
       and ue.legislation_code     = 'US';

   l_defined_balance_id pay_defined_balances.defined_balance_id%type;

  BEGIN
   hr_utility.set_location(gv_package_name || '.bal_db_item', 10);
   hr_utility.trace('p_db_item_name is '||p_db_item_name);

   open csr_defined_balance;
   fetch csr_defined_balance into l_defined_balance_id;

   if csr_defined_balance%notfound then
     close csr_defined_balance;
     raise hr_utility.hr_error;
   else
     close csr_defined_balance;
   end if;

   hr_utility.trace('l_defined_balance_id is '||to_char(l_defined_balance_id));
   hr_utility.set_location(gv_package_name || '.bal_db_item', 20);

   return (l_defined_balance_id);

  EXCEPTION
      WHEN OTHERS THEN
        hr_utility.trace('Error in '|| gv_package_name || '.bal_db_item');
        RAISE;

  END bal_db_item;



 /********************************************************************
  Main procedure called from the concurrent program.
  Name: add_actions_to_yepp

  Description: The input parameters for the procedure are Date,GRE_ID,
               Assignment Set and output file type fromthe concurrent
               program. The procedure identifies the eligible/processed
               /not eligible and secondary assignments from the
               Assignment set and report them as the output in the
               specified format.

  ********************************************************************/

  PROCEDURE add_actions_to_yepp(errbuf             out nocopy varchar2,
                                retcode            out nocopy number,
                                p_effective_date   in varchar2,
                                p_gre_id           in number,
                                p_assign_set       in number,
                                p_output_file_type in varchar2)

  IS

   --Cursor to check if there is a W2 Mag Tape run for the business group and
   --if there are actions which have been picked up for the GRE for which
   --this process is run in the mag tape run

/*---- Cursor modified as per bug 3263078. Removed join with pay_assignment_actions.  ----------*/
  -- This cursor checks existence of 1099R magtape runs for 1099R GRE and W2 magtape runs for W2 GRE.
   cursor c_w2_magtape_run_exists(cp_effective_date    date,
                                  cp_business_group_id number,
                                  cp_gre_type varchar2)
    is
     select 1 from dual
      where exists (
              select 1
                from pay_payroll_actions    ppa
               where ppa.business_group_id  = cp_business_group_id
                 and ppa.action_type        = 'X'
                 and ppa.report_type        = cp_gre_type
                 and ppa.report_category    in ('RM', 'RT')
                 and ppa.effective_date + 0 = add_months(cp_effective_date,12) - 1
                 and ppa.action_status = 'C'
                    ) ;
/*---------------------------------------------------------------------------------------------*/
   -- Cursor to get the type of GRE (W2/1099R)
   cursor c_gre_type(cp_tax_unit_id number)
   is
   select decode(org_information_context,'1099R Magnetic Report Rules','1099R','W2') gre_type
     from hr_organization_information
   where organization_id = cp_tax_unit_id
   and org_information_context in ('1099R Magnetic Report Rules','W2 Reporting Rules');



   -- Cursor to get the GRE Name
   cursor c_gre_name(cp_tax_unit_id number)
    is
    select name,business_group_id
      from hr_organization_units
     where organization_id  = cp_tax_unit_id;

   -- Cursor to get person_id of the assignments selected
   cursor c_person_id (cp_assign_id number)
    is
    select person_id
      from per_assignments_f
     where assignment_id=cp_assign_id;

   -- Cursor to get Employee details
   cursor c_employee_details (cp_person_id number )
    is
    select employee_number,full_name,national_identifier
      from per_people_f
     where  person_id   = cp_person_id;

   lv_result_value         number:=0;
   lv_person_id            per_all_people_f.person_id%type;
   lv_gre_name             hr_organization_units.name%type;
   lv_gre_type             varchar2(10);
   lv_emp_name             per_people_f.full_name%type;
   lv_emp_no               per_people_f.employee_number%type;
   lv_emp_ssn              per_people_f.national_identifier%type;
   lv_data_row             varchar2(4000);
   l_assignment_inserted   number :=0;
   l_effective_date        date;
   l_temp                  number;
   lv_business_group_id    hr_organization_units.business_group_id%type;

   l_elgbl_table_header    varchar2(200):= '2. Following employees are eligible for the Year End '||
                               'Pre-Process archive and marked for Retry:';
   l_prced_table_header    varchar2(200):= '1. Following employees are already processed by the '||
                               'Year End Pre-Process:';
   l_nonelgbl_table_header varchar2(200):= '3. Following employees are not eligible for the Year '||
                               'End Pre-Process:';
   l_secasg_table_header   varchar2(200):= 'Following employees have secondary assignment included '||
                               'in the assignment set:';
   l_othasg_table_header   varchar2(200):= 'Following employees are included in the assignment set '||
                               'but belong to different GRE: ';

-- Bug 3829668
   /******************************************************************
    Procedure create_archive
    Description : Creates an entry into ff_archive_items for user_entity A_W2_CORRECTED. This is needed to
                  print/noprint  'CORRECTED' on Online Employee W2.
    ******************************************************************/
    PROCEDURE  create_archive(cp_asg_action_id in number,
                              cp_gre_id        in number)
    IS
      Cursor c_get_dbi_id(cp_dbi_name in varchar2) is
      select fdi.user_entity_id
        from ff_database_items fdi,
             ff_user_entities  fue
       where fdi.user_name = cp_dbi_name
         and fue.user_entity_id = fdi.user_entity_id
          and fue.legislation_code = 'US';

      l_user_entity_id number;
      l_context_id     number;
    BEGIN

     hr_utility.set_location(gv_package_name || '.create_archive', 10);
     select context_id
       into l_context_id
       from ff_contexts
      where context_name = 'TAX_UNIT_ID';

      open c_get_dbi_id('A_ADD_ARCHIVE');
         fetch c_get_dbi_id into l_user_entity_id;
	 if c_get_dbi_id%notfound then
            raise_application_error(-20001,'Error getting user_entity_id for DBI : '
                       ||'A_ADD_ARCHIVE'||' - '||to_char(sqlcode) || '-' || sqlerrm);
	 end if;
      close c_get_dbi_id;

     hr_utility.set_location(gv_package_name || '.create_archive', 20);

      -- Inserting into ff_archive_items

	insert into ff_archive_items
        (ARCHIVE_ITEM_ID,
         USER_ENTITY_ID,
         CONTEXT1,
         VALUE)
        values
        (ff_archive_items_s.nextval,
         l_user_entity_id,
         cp_asg_action_id,
         'Y');

      -- Inserting into ff_archive_item_contexts

	insert into ff_archive_item_contexts
        (ARCHIVE_ITEM_ID,
         SEQUENCE_NO,
         CONTEXT,
         CONTEXT_ID)
         values
        (ff_archive_items_s.currval,
         1,
         cp_gre_id,
         l_context_id);
     hr_utility.set_location(gv_package_name || '.create_archive', 30);
    end create_archive;
   /******************************************************************
    Procedure get_eligible_assignments
    Description : Gets the list of all primary assignments eligible for
                  the archive by year end process and mark them for retry.
    ******************************************************************/

    PROCEDURE get_eligible_assignments(p_effective_date    in date,
                                       p_gre_id            in number,
                                       p_assignment_set_id in number
				       )
    IS
     -- Curosr to get latest assignment action for the primary assignments
     -- from the assignment set of the payroll process in the given year
     -- and gre

     cursor c_get_latest_asg(cp_effective_date date,
                             cp_gre_id         number,
           	             cp_assign_set_id  number)
     is
      select /*+ ORDERED */max(paa.assignment_action_id),
             paf1.assignment_id,
             paf.person_id
        from hr_assignment_set_amendments has,
	     per_assignments_f            paf,
	     per_assignments_f            paf1,
	     pay_assignment_actions       paa,
             pay_payroll_actions          ppa,
             pay_action_classifications   pac
       where has.assignment_set_id      = cp_assign_set_id
         and has.include_or_exclude     = 'I'
         and paf.assignment_id          = has.assignment_id
         and paf.assignment_type        = 'E'
         and paf.person_id              = paf1.person_id
/* we cannot check for primary assignment. Bug 3440806 */
--         and paf.primary_flag           = 'Y'
--         and paa.assignment_id          = has.assignment_id
         and paa.assignment_id          = paf1.assignment_id
         and paa.tax_unit_id            = cp_gre_id
         and paa.payroll_action_id      = ppa.payroll_action_id
         and ppa.action_type            = pac.action_type
         and pac.classification_name||''    = 'SEQUENCED'
         and ppa.effective_date between paf.effective_start_date
                                    and paf.effective_end_date
         and ppa.effective_date between paf1.effective_start_date
                                    and paf1.effective_end_date
         and ppa.effective_date between cp_effective_date
                                    and add_months(cp_effective_date, 12) - 1
         and ((nvl(paa.run_type_id, ppa.run_type_id) is null
         and  paa.source_action_id is null)
              or (nvl(paa.run_type_id, ppa.run_type_id) is not null
         and paa.source_action_id is not null )
             or (ppa.action_type = 'V' and ppa.run_type_id is null
                 and paa.run_type_id is not null
                 and paa.source_action_id is null))
         and not exists( SELECT 1
                        FROM pay_payroll_actions ppa1,  -- Year End
                             pay_assignment_actions paa1  -- Year End
                       WHERE ppa1.report_type = 'YREND'
                         AND ppa1.action_status = 'C'
                         AND ppa1.effective_date = add_months(cp_effective_date, 12) - 1
                         AND to_number(substr(legislative_parameters,
                                       instr(legislative_parameters,'TRANSFER_GRE=') +
                                       length('TRANSFER_GRE='))) = cp_gre_id   -- Bug 3228332
                         AND ppa1.payroll_action_id = paa1.payroll_action_id
/* we should be checking for existance, irrespective of the action type. If we check for
   action status of C and M then the ones marked for retry will be selected and duplicate
   actions will be created */
--                         AND (paa1.action_status = 'C' or paa1.action_status = 'M')
                         AND paa1.serial_number = to_char(paf.person_id))   -- Bug 3228332
         group by paf1.assignment_id,paf.person_id
         order by paf1.assignment_id desc;


     -- Cursor to get details of payroll action of the Year End Pre-Process
     cursor get_yepp_payroll_action(cp_effective_date date,
                                    cp_gre_id         number)
     is
      select payroll_action_id
        from pay_payroll_actions
       where action_type = 'X'
         and action_status = 'C'
         and report_type = 'YREND'
         and pay_core_utils.get_parameter('TRANSFER_GRE',legislative_parameters) = cp_gre_id
         and effective_date = add_months(cp_effective_date, 12) - 1;


     -- Cursor to get already marked for retry assignment for the Year End Process
     cursor get_already_marked_assignments(cp_payroll_action_id number,
                                           cp_assignment_set_id number,
					   cp_gre_id            number)
     is
      select paa.assignment_id,
             paa.assignment_action_id
        from pay_assignment_actions paa,
	     hr_assignment_set_amendments has
       where paa.payroll_action_id = cp_payroll_action_id
         and paa.action_status     = 'M'
	 and paa.tax_unit_id       = cp_gre_id
	 and has.assignment_set_id = cp_assignment_set_id
	 and paa.assignment_id     = has.assignment_id
	 and nvl(has.include_or_exclude,'I') = 'I';

     l_bal_aaid               pay_assignment_actions.assignment_action_id%type;
     l_assignment_id          per_all_assignments_f.assignment_id%type;
     l_person_id              per_all_assignments_f.person_id%type;
     l_yepp_payroll_action_id pay_payroll_actions.payroll_action_id%type;
     l_value                  number;
     lockingactid             pay_assignment_actions.assignment_action_id%type;
     l_prev_person_id        per_all_assignments_f.person_id%type; -- bug 3315082

   /* we should always be stamping the primary assignment_id, even if the
      assignment selected in the assignment set is secondary */

   /* Get the primary assignment for the given person_id */

   CURSOR c_get_asg_id (p_person_id number) IS
     SELECT assignment_id
     from per_all_assignments_f paf
     where person_id = p_person_id
       and primary_flag = 'Y'
       and assignment_type = 'E'
       and paf.effective_start_date  <= add_months(p_effective_date, 12) - 1
       and paf.effective_end_date    >= p_effective_date
     ORDER BY assignment_id desc;

    BEGIN

     hr_utility.set_location(gv_package_name || '.get_eligible_assignments', 10);

     -- Get the Payroll Action of Year End Archive Pre-Process Run
     -- For given GRE and Year.

     open get_yepp_payroll_action(p_effective_date,
            			  p_gre_id);
     fetch get_yepp_payroll_action into l_yepp_payroll_action_id;
     close get_yepp_payroll_action ;


     hr_utility.set_location(gv_package_name || '.get_eligible_assignments', 20);

     /* Set up the context of tax unit id */
     pay_balance_pkg.set_context('TAX_UNIT_ID',p_gre_id);

     hr_utility.set_location(gv_package_name || '.get_eligible_assignments', 30);


     -- Get the latest assignment actions of all the primary assignments from the
     -- assignment set

     open c_get_latest_asg(p_effective_date,
 	                   p_gre_id,
	                   p_assignment_set_id
	                   );
     LOOP
      fetch c_get_latest_asg into l_bal_aaid, l_assignment_id, l_person_id;
      exit when c_get_latest_asg%NOTFOUND;
      hr_utility.set_location(gv_package_name || '.get_eligible_assignments', 40);

      if (l_prev_person_id <> l_person_id) or
         (l_prev_person_id is null)  then -- bug 3315082
         l_prev_person_id := l_person_id;
      if l_bal_aaid <> -9999 then  /* Assignment action in year */

         hr_utility.trace('bal_aaid = '||to_char(l_bal_aaid));
         hr_utility.trace('defined_balance_id = '||to_char(bal_db_item('GROSS_EARNINGS_PER_GRE_YTD')));
         hr_utility.set_location(gv_package_name || '.get_eligible_assignments', 50);
         l_value :=  nvl(pay_balance_pkg.get_value
                        (p_defined_balance_id   => bal_db_item('GROSS_EARNINGS_PER_GRE_YTD'),
                         p_assignment_action_id => l_bal_aaid),0);

         if l_value = 0 then
            hr_utility.trace('bal_aaid = '||to_char(l_bal_aaid));
            hr_utility.trace('defined_balance_id = '||to_char(bal_db_item('W2_NONTAX_SICK_PER_GRE_YTD')));
            hr_utility.set_location(gv_package_name || '.get_eligible_assignments', 60);
            l_value := nvl(pay_balance_pkg.get_value
                           (p_defined_balance_id   => bal_db_item('W2_NONTAX_SICK_PER_GRE_YTD'),
                            p_assignment_action_id => l_bal_aaid),0);

           if l_value = 0 then
             hr_utility.trace('bal_aaid = '||to_char(l_bal_aaid));
             hr_utility.trace('defined_balance_id = '||to_char(bal_db_item('W2_EXPENSE_REIMB_PER_GRE_YTD')));
             hr_utility.set_location(gv_package_name || '.get_eligible_assignments', 70);
             l_value := nvl(pay_balance_pkg.get_value
                           (p_defined_balance_id  => bal_db_item('W2_EXPENSE_REIMB_PER_GRE_YTD'),
                           p_assignment_action_id => l_bal_aaid),0);

            if l_value = 0 then
               hr_utility.trace('bal_aaid = '||to_char(l_bal_aaid));
               hr_utility.trace('defined_balance_id = '||to_char(bal_db_item('W2_QUAL_MOVE_PER_GRE_YTD')));
               hr_utility.set_location(gv_package_name || '.get_eligible_assignments', 80);
               l_value := nvl(pay_balance_pkg.get_value
                             (p_defined_balance_id   => bal_db_item('W2_QUAL_MOVE_PER_GRE_YTD'),
                              p_assignment_action_id => l_bal_aaid),0);
             if l_value = 0 then
                hr_utility.trace('bal_aaid = '||to_char(l_bal_aaid));
                hr_utility.trace('defined_balance_id = '||to_char(bal_db_item('W2_NO_GROSS_EARNINGS_PER_GRE_YTD')));
                hr_utility.set_location(gv_package_name || '.get_eligible_assignments', 90);
                l_value := nvl(pay_balance_pkg.get_value
                              (p_defined_balance_id   => bal_db_item('W2_NO_GROSS_EARNINGS_PER_GRE_YTD'),
                               p_assignment_action_id  => l_bal_aaid),0);
             end if;
            end if;
           end if;
         end if;

         -- Check if the assignment has got a value for any of the above five balances
         hr_utility.set_location(gv_package_name || '.get_eligible_assignments', 100);
         if l_value <> 0 then

           /* Create the assignment action to represnt the person / tax unit
              combination. */
           hr_utility.set_location(gv_package_name || '.get_eligible_assignments', 110);

           select pay_assignment_actions_s.nextval
             into  lockingactid
              from  dual;

           open c_get_asg_id(l_person_id);
           fetch c_get_asg_id into l_assignment_id;
           if c_get_asg_id%NOTFOUND then
               close c_get_asg_id;
               raise hr_utility.hr_error;
           else
               close c_get_asg_id;
           end if;

           /* Insert into pay_assignment_actions. */
           hr_utility.trace('creating asg action');

           hr_nonrun_asact.insact(lockingactid  => lockingactid,
	     		          assignid      => l_assignment_id,
			          pactid        => l_yepp_payroll_action_id,
			          chunk         => '1',
			          greid         => p_gre_id,
			          status        => 'M' );

           hr_utility.set_location(gv_package_name || '.get_eligible_assignments', 120);

	   /* insert into ff_archive_items */
	   -- Bug 3829668
           hr_utility.trace('creating ff_archive_items entry');
           create_archive(lockingactid ,
                          p_gre_id);

           hr_utility.set_location(gv_package_name || '.get_eligible_assignments', 121);

	   /* Bug No : 3137858 Update the serial number column with the person id
              So that retry us payroll process archives balance values*/
           hr_utility.trace('updating asg action');

           update pay_assignment_actions aa
           set    aa.serial_number = to_char(l_person_id)
           where  aa.assignment_action_id = lockingactid;


           -- Pupulate the plsql table for eligible assignments
           l_yepp_elgble_asg_table(l_assignment_id).c_assignment_id := l_assignment_id;

	   -- Populate plsql table of all reported assignments. It will be used to
	   -- Identify all assignments in different GRE and in the assignment set.
	   l_gre_reported_asg_table(l_assignment_id).c_assignment_id := l_assignment_id;

           hr_utility.set_location(gv_package_name || '.get_eligible_assignments', 130);

         end if; /* l_value <> 0 */
      end if; /* l_prev_person_id <> l_person_id */
      end if; /* l_bal_aaid <> -9999 */

     END LOOP;
     close c_get_latest_asg;

/* We should not be reporting the actions that were not marked for retry outside of this process in the report */

/*
     -- Populate alread marked for retry assignments to the plsql table
     for ma_rec in get_already_marked_assignments(l_yepp_payroll_action_id,
                                                  p_assignment_set_id,p_gre_id)
      loop
         -- Pupulate Pupulate the plsql table for eligible assignments
	 l_yepp_elgble_asg_table(ma_rec.assignment_id).c_assignment_id
                                                      := ma_rec.assignment_id;

	 -- Populate plsql table of all reported assignments
	 l_gre_reported_asg_table(ma_rec.assignment_id).c_assignment_id
                                                      := ma_rec.assignment_id;
     end loop;

*/
     hr_utility.set_location(gv_package_name || '.get_eligible_assignments', 140);

     EXCEPTION
      WHEN OTHERS THEN
        hr_utility.trace('Error in '|| gv_package_name || '.get_eligible_assignments');
        RAISE;

    END get_eligible_assignments;


   /******************************************************************
    Procedure get_processed_assignments
    Description : Gets the list of all primary assignments from the
                  assignment set which are processed by the year end
                  process.
    ******************************************************************/

    PROCEDURE get_processed_assignments(p_effective_date    in date,
                                        p_gre_id            in number,
                                        p_assignment_set_id in number )
    IS

     -- Cursor to get primary assignments from the assignment set which
     -- are processed in the Year End Pre-Process
/*
     cursor c_get_processed_assignments(cp_effective_date    date,
                                        cp_gre_id	     number,
                                        cp_assignment_set_id number)
     is
      select distinct has.assignment_id
       from  hr_assignment_set_amendments has,
             per_assignments_f            paf
       where has.assignment_set_id  = cp_assignment_set_id
         and paf.assignment_id      = has.assignment_id
         and paf.primary_flag       = 'Y'
         and exists
            ( select '1'
               FROM pay_payroll_actions ppa,  -- Year End
	            pay_assignment_actions paa  -- Year End
	      WHERE ppa.report_type    = 'YREND'
	        AND ppa.action_status  = 'C'
	        AND ppa.effective_date = add_months(cp_effective_date, 12) - 1
	        AND instr(ppa.legislative_parameters, cp_gre_id)>0
	        AND ppa.payroll_action_id = paa.payroll_action_id
	        AND paa.action_status = 'C'
            AND paa.assignment_id = has.assignment_id);
*/

     cursor c_get_processed_assignments(cp_effective_date    date,
                                        cp_gre_id	     number,
                                        cp_assignment_set_id number)
     is
      select distinct has.assignment_id
       from  hr_assignment_set_amendments has,
             per_assignments_f            paf
       where has.assignment_set_id  = cp_assignment_set_id
         and paf.assignment_id      = has.assignment_id
         and exists( SELECT 1
                     FROM pay_payroll_actions ppa1,  -- Year End
                          pay_assignment_actions paa1  -- Year End
                     WHERE ppa1.report_type = 'YREND'
                       AND ppa1.action_status = 'C'
                       AND ppa1.effective_date = add_months(cp_effective_date, 12) - 1
                       AND to_number(substr(legislative_parameters,
                                       instr(legislative_parameters,'TRANSFER_GRE=') +
                                       length('TRANSFER_GRE='))) = cp_gre_id   -- Bug 3228332
                       AND ppa1.payroll_action_id = paa1.payroll_action_id
                       AND paa1.serial_number = to_char(paf.person_id));   -- Bug 3228332

     l_processed_assignment_id   per_assignments_f.assignment_id%type;

    BEGIN

     hr_utility.set_location(gv_package_name || '.get_processed_assignments', 10);

     -- Open Curosr c_get_processed_assignments
     open c_get_processed_assignments(p_effective_date ,
                                      p_gre_id,
                                      p_assignment_set_id);
     LOOP

      fetch c_get_processed_assignments into l_processed_assignment_id;
      exit when c_get_processed_assignments%notfound;
      hr_utility.set_location(gv_package_name || '.get_processed_assignments', 20);
      -- Populate plsql tbales
      l_yepp_prc_asg_table(l_processed_assignment_id).c_assignment_id     := l_processed_assignment_id;
      l_gre_reported_asg_table(l_processed_assignment_id).c_assignment_id := l_processed_assignment_id;

     END LOOP;
     close c_get_processed_assignments;

     hr_utility.set_location(gv_package_name || '.get_processed_assignments', 30);

     EXCEPTION
      WHEN OTHERS THEN
        hr_utility.trace('Error in '|| gv_package_name || '.get_processed_assignments');
        RAISE;
    END get_processed_assignments;


   /******************************************************************
    Procedure get_non_elgble_assignments
    Description : Gets the list of all primary assignments from the
                  assignment set which are not eligible for the year
                  end process.
    ******************************************************************/

    PROCEDURE get_non_elgble_assignments(p_assignment_set_id in number,
                                         p_gre_id            in number,
					 p_effective_date    in date)

    IS
     -- Cursor to get all primary assignments from the assignment set.
     cursor c_get_assignments(cp_assignment_set_id number,
                              cp_gre_id            number,
			      cp_effective_date    date)
     is
      select distinct has.assignment_id
        from hr_assignment_set_amendments has,
             per_assignments_f            paf,
	     pay_us_asg_reporting         puar
       where has.assignment_set_id           = cp_assignment_set_id
         and paf.assignment_id               = has.assignment_id
	 and nvl(has.include_or_exclude,'I') = 'I'
	 and paf.effective_start_date        <= add_months(cp_effective_date, 12) - 1
         and paf.effective_end_date          >= cp_effective_date
	 and puar.assignment_id              = paf.assignment_id
	 and puar.tax_unit_id                = cp_gre_id
         and paf.primary_flag                = 'Y';

     l_assignment_id per_assignments_f.assignment_id%type;

    BEGIN

     hr_utility.set_location(gv_package_name || '.get_non_elgble_assignments', 10);
     hr_utility.trace('Assign Set ID'||p_assignment_set_id);

     -- Open Cursor c_get_assignments
     open c_get_assignments(p_assignment_set_id,p_gre_id,p_effective_date);

     LOOP

      fetch c_get_assignments into l_assignment_id;
      exit when c_get_assignments%notfound;
      hr_utility.set_location(gv_package_name || '.get_non_elgble_assignments', 20);

      if l_yepp_elgble_asg_table.exists(l_assignment_id) then
        hr_utility.set_location(gv_package_name || '.get_non_elgble_assignments', 30);
        hr_utility.trace('Assignment Exists');

       elsif l_yepp_prc_asg_table.exists(l_assignment_id) then
         hr_utility.trace('Assignment Exists');
         hr_utility.set_location(gv_package_name || '.get_non_elgble_assignments', 40);

      else
        -- populate not eligible assignments table
        l_yepp_not_elgble_asg_table(l_assignment_id).c_assignment_id := l_assignment_id;
	l_gre_reported_asg_table(l_assignment_id).c_assignment_id    := l_assignment_id;
        hr_utility.set_location(gv_package_name || '.get_non_elgble_assignments', 50);

      end if;

      hr_utility.set_location(gv_package_name || '.get_non_elgble_assignments', 60);
     END LOOP;

     close c_get_assignments;

     hr_utility.set_location(gv_package_name || '.get_non_elgble_assignments', 70);

     EXCEPTION
      WHEN OTHERS THEN
        hr_utility.trace('Error in '|| gv_package_name || '.get_non_elgble_assignments');
        RAISE;

    END get_non_elgble_assignments;


   /******************************************************************
    Procedure print_table_details
    Description : prints the table details in HTML format
    ******************************************************************/
    PROCEDURE print_table_details(p_assignment_id in number)
    IS
    BEGIN
     hr_utility.set_location(gv_package_name || 'print_table_details', 10);

     -- Get person_id of the employee
     open c_person_id(p_assignment_id);
     fetch c_person_id into lv_person_id;
     close c_person_id;

     -- Get Employee Details
     hr_utility.set_location(gv_package_name || 'print_table_details', 20);
     open c_employee_details(lv_person_id);
     fetch c_employee_details into lv_emp_no,lv_emp_name,lv_emp_ssn;
     close c_employee_details;

     hr_utility.set_location(gv_package_name || 'print_table_details', 30);
     l_assignment_inserted  := l_assignment_inserted  + 1;
     lv_data_row :=   formated_detail_string(
                               p_output_file_type
                              ,to_char(l_effective_date,'YYYY')
                              ,lv_gre_name
             		      ,lv_emp_name
			      ,lv_emp_ssn
			      ,lv_emp_no);
     if p_output_file_type ='HTML' then
        lv_data_row := '<tr>' || lv_data_row || '</tr>' ;
     end if;

     fnd_file.put_line(fnd_file.output, lv_data_row);
     hr_utility.set_location(gv_package_name || 'print_table_details', 40);

    END print_table_details;



   /******************************************************************
    Procedure report_secondary_assignments
    Description : Gets the list of secondary assignments from the
                  assignment set and report them
    ******************************************************************/
    PROCEDURE report_secondary_assignments(p_assignment_set_id in number,
                                           p_gre_id            in number,
					   p_effective_date    in date)

    IS
     -- Cursor to get all primary assignments from the assignment set.
     cursor c_get_secondary_assignments(cp_assignment_set_id number,
                                        cp_gre_id            number,
					cp_effective_date    date)
     is
      select distinct has.assignment_id
        from hr_assignment_set_amendments has,
             per_assignments_f            paf,
	     pay_us_asg_reporting         puar
       where assignment_set_id               = cp_assignment_set_id
         and paf.assignment_id               = has.assignment_id
	 and nvl(has.include_or_exclude,'I') = 'I'
	 and paf.effective_start_date        <= add_months(cp_effective_date, 12) - 1
         and paf.effective_end_date          >= cp_effective_date
	 and puar.assignment_id              = paf.assignment_id
	 and puar.tax_unit_id                = cp_gre_id
         and paf.primary_flag                <> 'Y';

     l_assignment_id  per_assignments_f.assignment_id%type;
     l_count          number := 0;
     l_header_printed varchar2(1) := 'N';
    BEGIN

     hr_utility.set_location(gv_package_name || '.report_secondary_Assignments', 10);
     hr_utility.trace('Assign Set ID'||p_assignment_set_id);

     -- Open Cursor c_get_secondary_assignments
     open c_get_secondary_assignments(p_assignment_set_id,
                                      p_gre_id,
				      p_effective_date);
     LOOP

      fetch c_get_secondary_assignments into l_assignment_id;
      exit when c_get_secondary_assignments%notfound;

/* we should be displaying the secondary assignments only if it does not
   exists in any other tables. Bug 3440806 */

      if l_yepp_elgble_asg_table.exists(l_assignment_id) then
        hr_utility.set_location(gv_package_name || '.report_secondary_assignments', 20);
        hr_utility.trace('Assignment Exists');

       elsif l_yepp_prc_asg_table.exists(l_assignment_id) then
         hr_utility.trace('Assignment Exists');
         hr_utility.set_location(gv_package_name || '.report_secondary_assignments', 30);

      elsif  l_yepp_not_elgble_asg_table.exists(l_assignment_id) then
         hr_utility.trace('Assignment Exists');
         hr_utility.set_location(gv_package_name || '.report_secondary_assignments', 40);

      else

         l_count  := l_count + 1 ;
         hr_utility.set_location(gv_package_name || '.report_secondary_Assignments', 20);

         if l_header_printed = 'N' then
           -- Print the Table Header
           print_table_header('4. '||l_secasg_table_header,p_output_file_type);
	   l_header_printed  := 'Y';
         end if;

         -- Print Employee Details
         print_table_details(l_assignment_id);
         l_gre_reported_asg_table(l_assignment_id).c_assignment_id := l_assignment_id;

      end if;

     END LOOP;
     if p_output_file_type ='HTML' then
        fnd_file.put_line(fnd_file.output,'</table>') ;
     end if;

     close c_get_secondary_assignments;
     --
     if l_count > 0 then
        gv_sec_asg_reported := 'Y';
     end if;
     --
     hr_utility.set_location(gv_package_name || '.report_secondary_assignments', 30);

     EXCEPTION
      WHEN OTHERS THEN
        hr_utility.trace('Error in '|| gv_package_name || '.report_secondary_assignments');
        RAISE;

    END report_secondary_assignments;



   /******************************************************************
    Procedure get_other_assignments
    Description : Gets the list of assignments in the assignment set
                  but in different GRE then entered as parameter
    ******************************************************************/
    PROCEDURE get_other_assignments(p_assignment_set_id in number,
                                    p_gre_id            in number,
				    p_effective_date    in date)

    IS
     -- Cursor to get all primary assignments from the assignment set.
     cursor c_other_assignments(cp_assignment_set_id number,
                                cp_gre_id            number,
				cp_effective_date    date)
     is
      select distinct has.assignment_id, puar.tax_unit_id
        from hr_assignment_set_amendments has,
             per_assignments_f            paf,
	     pay_us_asg_reporting         puar
       where assignment_set_id               = cp_assignment_set_id
         and paf.assignment_id               = has.assignment_id
	 and nvl(has.include_or_exclude,'I') = 'I'
	 and paf.effective_start_date        <= add_months(cp_effective_date, 12) - 1
         and paf.effective_end_date          >= cp_effective_date
	 and puar.assignment_id              = paf.assignment_id
	 and puar.tax_unit_id                <> cp_gre_id;

     -- Cursor to get gre name
        cursor c_get_gre_name(cp_gre_id number)
        is
         select name
           from hr_organization_units
          where organization_id  = cp_gre_id;

     l_oth_assignment_id        per_assignments_f.assignment_id%type;
     l_gre_id               pay_us_asg_reporting.tax_unit_id%type;
     l_header_printed       varchar2(1) := 'N';

    BEGIN

     hr_utility.set_location(gv_package_name || '.get_other_assignments', 10);
     hr_utility.trace('Assign Set ID'||p_assignment_set_id);

     -- Check of secondary assignment is reported.
     -- Used for formating of squence number
     if gv_sec_asg_reported = 'Y' then
        l_othasg_table_header := '5. '||l_othasg_table_header;
     else
        l_othasg_table_header := '4. '||l_othasg_table_header;
     end if;
      --

     -- Open Cursor c_other_assignments
     open c_other_assignments(p_assignment_set_id,
                              p_gre_id,
			      p_effective_date);
     LOOP

      fetch c_other_assignments into l_oth_assignment_id,l_gre_id;
      exit when c_other_assignments%notfound;
      hr_utility.set_location(gv_package_name || '.get_other_assignments', 20);

      if l_gre_reported_asg_table.exists(l_oth_assignment_id) then
        hr_utility.trace('The assignment already reported above');
      else
        -- Get other GRE Names
        open c_get_gre_name(l_gre_id);
        fetch c_get_gre_name into lv_gre_name;
        close c_get_gre_name;
        hr_utility.set_location(gv_package_name || '.get_other_assignments', 30);
        if l_header_printed  = 'N' then
          -- Print the Table Header
          print_table_header(l_othasg_table_header,p_output_file_type);
	  l_header_printed  := 'Y';
        end if;
        hr_utility.set_location(gv_package_name || '.get_other_assignments', 40);

        -- Print the details of the employee
        print_table_details(l_oth_assignment_id);
	hr_utility.set_location(gv_package_name || '.get_other_assignments', 50);
      end if;

     END LOOP;
     hr_utility.set_location(gv_package_name || '.get_other_assignments', 60);
     if p_output_file_type ='HTML' then
        fnd_file.put_line(fnd_file.output,'</table>') ;
     end if;

     close c_other_assignments;
     hr_utility.set_location(gv_package_name || '.get_other_assignments', 90);

     EXCEPTION
      WHEN OTHERS THEN
        hr_utility.trace('Error in '|| gv_package_name || '.get_other_assignments');
        RAISE;

    END get_other_assignments;


  --------------------------------------------------------------------
  -- The Main Procedure Begins Here
  --------------------------------------------------------------------

  BEGIN

--   hr_utility.trace_on(null, 'pyusyeaa');
   hr_utility.set_location(gv_package_name || '.add_actions_to_yepp', 10);

   -- Get the date in canonical format
   l_effective_date := fnd_date.canonical_to_date(p_effective_date);

   --Get GRE Name
   open c_gre_name(p_gre_id);
   fetch c_gre_name into lv_gre_name,lv_business_group_id;
   close c_gre_name;

   -- Get GRE type
   hr_utility.trace('Fetching GRE type (1099R/W2)');
   open c_gre_type(p_gre_id);
     fetch c_gre_type into lv_gre_type;
     if c_gre_type%notfound then
       lv_gre_type := 'W2';
     end if;
   close c_gre_type;

   hr_utility.trace('Checking if Federal Magtape is run...');
   -- Check if the Federal Magtape is already processed in the year
   open c_w2_magtape_run_exists(l_effective_date,
                                lv_business_group_id,
                                lv_gre_type);
   fetch c_w2_magtape_run_exists into l_temp;

   -- Format and print the heading of the output page(Bug 3137858)

   fnd_file.put_line(fnd_file.output,
                     pay_us_payroll_utils.formated_header_string(gv_title || ': Tax Year: ' ||
                              to_char(l_effective_date,'YYYY')||', GRE: '||lv_gre_name,p_output_file_type ));

   if p_output_file_type ='HTML' then
     fnd_file.put_line(fnd_file.output, '<body>');
   end if;

   if c_w2_magtape_run_exists%found then  -- Magnetic tape processed

      if p_output_file_type ='HTML' then
         fnd_file.put_line(fnd_file.output, '<br><br><table align=center>');
      end if;

      if p_output_file_type ='HTML' then
        fnd_file.put_line(fnd_file.output, '<tr>');
      end if;

      fnd_file.put_line(fnd_file.output,
                        pay_us_payroll_utils.formated_data_string
                          (p_input_string =>  'The request cannot process the assignments' ||
                           ' since one of the Magnetic tapes is already processed in the tax year.'
                          ,p_bold         => 'Y'
                          ,p_output_file_type => p_output_file_type));

      if p_output_file_type ='HTML' then
        fnd_file.put_line(fnd_file.output, '</tr>');
      end if;

      if p_output_file_type ='HTML' then
        fnd_file.put_line(fnd_file.output, '<tr>');
      end if;

      fnd_file.put_line(fnd_file.output,
                        pay_us_payroll_utils.formated_data_string
                          (p_input_string => 'Please rollback the magnetic tape and try again.'
                          ,p_bold         => 'Y'
                          ,p_output_file_type => p_output_file_type));

      if p_output_file_type ='HTML' then
         fnd_file.put_line(fnd_file.output, '</tr> </table> </body> </HTML>');
      end if;

      close c_w2_magtape_run_exists;

   else -- Magnetic tape not processed

    -- Get the date in canonical format
    l_effective_date := fnd_date.canonical_to_date(p_effective_date);

    /*
     for bug 3984539 we have changed the sequence. get_eligible_assignments
     looks for assignments for whom YEPP is not run and inserts a action with
     M and get_processed_assignments looks for assignment in YEPP. If we have
     get_eligible_assignments before get_processed_assignments we will always
     have an action in YEPP.
    */

    -- Call get_processed_assignments
    hr_utility.set_location(gv_package_name || '.add_actions_to_yepp', 30);
    get_processed_assignments(l_effective_Date,
                              p_gre_id,
                              p_assign_set);

    -- Call get_eligible_assignments
    hr_utility.set_location(gv_package_name || '.add_actions_to_yepp', 20);
    get_eligible_assignments(l_effective_Date,
                             p_gre_id,
                             p_assign_set);

    -- Call get_non_elgble_assignments
    hr_utility.set_location(gv_package_name || '.add_actions_to_yepp', 40);
    get_non_elgble_assignments(p_assign_set,
                               p_gre_id,
			       l_effective_date);

    hr_utility.set_location(gv_package_name || '.add_actions_to_yepp', 50);


    /***Start Formating of the out put for all Processed Assignments***/

    hr_utility.set_location(gv_package_name || '.add_actions_to_yepp', 70);
    if l_yepp_prc_asg_table.count>0 Then

      -- Print the Table Header
      print_table_header(l_prced_table_header,p_output_file_type);

      -- Report the Employees

      hr_utility.set_location(gv_package_name || '.add_actions_to_yepp', 80);

      for l_assignment_id in l_yepp_prc_asg_table.first..l_yepp_prc_asg_table.last
       LOOP
        if l_yepp_prc_asg_table.exists(l_assignment_id) Then
           hr_utility.set_location(gv_package_name || '.add_actions_to_yepp', 90);
           print_table_details(l_yepp_prc_asg_table(l_assignment_id).c_assignment_id);
         end if;
       END LOOP;

       if p_output_file_type ='HTML' then
        fnd_file.put_line(fnd_file.output,'</table>') ;
       end if;

    end if;

    hr_utility.set_location(gv_package_name || '.add_actions_to_yepp', 100);
    -- If not processed assignment found from the assignment set

    if l_assignment_inserted=0 then
       hr_utility.set_location(gv_package_name || '.add_actions_to_yepp', 110);
       formated_zero_count(p_output_file_type,'PROCESSED');
    end if;

    /***End Formating of the out put for all Processed Assignments*****/


    /***Start Formating of the out put for all Eligible Assignments****/

    l_assignment_inserted  := 0;
    hr_utility.set_location(gv_package_name || '.add_actions_to_yepp', 120);
    if l_yepp_elgble_asg_table.count >0 Then

      -- Print the Table Header
      print_table_header(l_elgbl_table_header,p_output_file_type);

      -- Report all Eligible Assignments
      hr_utility.set_location(gv_package_name || '.add_actions_to_yepp', 130);

      for l_assignment_id in l_yepp_elgble_asg_table.first..l_yepp_elgble_asg_table.last

       LOOP

        if l_yepp_elgble_asg_table.exists(l_assignment_id) then
          hr_utility.set_location(gv_package_name || '.add_actions_to_yepp', 140);
	  print_table_details(l_yepp_elgble_asg_table(l_assignment_id).c_assignment_id);

        end if;
       END LOOP;
       if p_output_file_type ='HTML' then
        fnd_file.put_line(fnd_file.output,'</table>') ;
       end if;
      end if;

    hr_utility.set_location(gv_package_name || '.add_actions_to_yepp', 150);

    -- If no elgible assignments found
    if l_assignment_inserted=0 then
       hr_utility.set_location(gv_package_name || '.add_actions_to_yepp', 260);
       formated_zero_count(p_output_file_type,'ELGBLE');
    end if;

    /***End Formating of the out put for all Eligible Assignments******/


    /***Start Formating of the output for Non Eligible Assignments*****/
    --Print Non Eligible Employees
    l_assignment_inserted  := 0;
    hr_utility.set_location(gv_package_name || '.add_actions_to_yepp', 170);
    if l_yepp_not_elgble_asg_table.count >0 then

      -- Print the Table Header
      hr_utility.set_location(gv_package_name || '.add_actions_to_yepp', 180);
      print_table_header(l_nonelgbl_table_header,p_output_file_type);

      --Report Non Elgible Employees Output

      for l_assignment_id in l_yepp_not_elgble_asg_table.first..l_yepp_not_elgble_asg_table.last

       LOOP
        hr_utility.set_location(gv_package_name || '.add_actions_to_yepp', 190);
        if l_yepp_not_elgble_asg_table.exists(l_assignment_id) then
           hr_utility.set_location(gv_package_name || '.add_actions_to_yepp', 200);
           print_table_details(l_yepp_not_elgble_asg_table(l_assignment_id).c_assignment_id);

        end if;
       END LOOP;

       if p_output_file_type ='HTML' then
        fnd_file.put_line(fnd_file.output,'</table>') ;
       end if;

      hr_utility.set_location(gv_package_name || '.add_actions_to_yepp', 210);
    end if;

    hr_utility.set_location(gv_package_name || '.add_actions_to_yepp', 220);

    -- When no employee found who is not elogible
    if l_assignment_inserted=0 then

       hr_utility.set_location(gv_package_name || '.add_actions_to_yepp', 230);
       formated_zero_count(p_output_file_type,'NOTELGBLE');
    end if;

    /***End Formating of the output for Non Eligible Assignments*******/


    -- Call report_secondary_assignments
    hr_utility.set_location(gv_package_name || '.add_actions_to_yepp', 240);
    report_secondary_assignments(p_assign_set,
                                 p_gre_id,
				 l_effective_date);

    hr_utility.set_location(gv_package_name || '.add_actions_to_yepp', 250);
    -- Call get_other_assignments
    get_other_assignments(p_assign_set,
                          p_gre_id,
			  l_effective_date);

    hr_utility.set_location(gv_package_name || '.add_actions_to_yepp', 260);

    close c_w2_magtape_run_exists;

    if p_output_file_type ='HTML' then
       fnd_file.put_line(fnd_file.output, '</body> </HTML>');
    end if;

   end if; -- Magnetic tape not processed

   hr_utility.set_location(gv_package_name || '.add_actions_to_yepp', 270);

   -- Update the concurrent program request if the output type is HTML
   hr_utility.set_location(gv_package_name || '.add_actions_to_yepp', 280);
   if p_output_file_type ='HTML' then
      hr_utility.set_location(gv_package_name || '.add_actions_to_yepp', 290);
      UPDATE fnd_concurrent_requests
      SET output_file_type = 'HTML'
      WHERE request_id = FND_GLOBAL.CONC_REQUEST_ID ;

      commit;
    end if;
    hr_utility.set_location(gv_package_name || '.add_actions_to_yepp', 300);

   EXCEPTION
      WHEN OTHERS THEN
        hr_utility.trace('Error in '|| gv_package_name || '.add_actions_to_yepp');
        RAISE;

  END add_actions_to_yepp;

END pay_us_yepp_add_actions_pkg;

/
