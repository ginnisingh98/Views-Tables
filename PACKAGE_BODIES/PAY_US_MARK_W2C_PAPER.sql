--------------------------------------------------------
--  DDL for Package Body PAY_US_MARK_W2C_PAPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_MARK_W2C_PAPER" AS
/* $Header: payusmarkw2cpapr.pkb 120.0.12010000.1 2008/07/27 21:55:56 appldev ship $*/
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

    Name        : pay_us_mark_w2c_paper
    File Name   : payusmarkw2cpapr.pkb

    Description : Mark all assignment action included in  W-2c Report process
                  confirming W-2c paper submitted to Govt. Once a corrected
                  assignment is marked as submitted, this assignment will not
                  be picked up by "Federeal W-2c Magnetic Media" process.

    Uses        :

    Change List
    -----------
    Date        Name     Vers    Bug No   Description
    ----        ----     ------  -------  -----------
    10-Oct-2003 ppanda   115.0            Created.
    02-DEC-2003 ppanda   115.1   3275044  A fatal error will be raised
                                          when no W-2c paper assignment action
                                          picked up by the process

    10-NOV-2004 asasthan 115.2   3264740  Detial report provided.
    10-NOV-2004 meshah   115.3            Fixed a gscc error.
    18-NOV-2004 asasthan 115.4   3264740  Updated output_type for HTML
    14-MAR-2005 sackumar  115.6  4222032 Change in the Range Cursor removing redundant
							   use of bind Variable (:payroll_action_id)
*******************************************************************/

 /******************************************************************
  ** Package Local Variables
  ******************************************************************/
  gv_package     varchar2(50);
  gv_title       VARCHAR2(100);

  /*******************************************************************
  ** Procedure return the values for the Payroll Action of
  ** the "Mark Paper W-2c and Exclude From Future Tapes" process.
  ** This is used in Range Code and Action Creation.
  ******************************************************************/

  PROCEDURE get_payroll_action_info
  (
        p_payroll_action_id     in      number,
        p_start_date            in out  nocopy date,
        p_end_date              in out  nocopy date,
        p_report_type           in out  nocopy varchar2,
        p_report_qualifier      in out  nocopy varchar2,
        p_business_group_id     in out  nocopy number,
        p_seq_num               in out  nocopy number
  )
  IS
  cursor c_payroll_action(cp_payroll_action_id in number) is
      select ppa.start_date
            ,ppa.effective_date
            ,ppa.report_type
            ,ppa.report_qualifier
            ,ppa.business_group_id
            ,pay_us_payroll_utils.get_parameter('S_N',
                                                 ppa.legislative_parameters)
       from pay_payroll_actions ppa
      where payroll_action_id = cp_payroll_action_id;

    ld_start_date           date;
    ld_end_date             date;
    lv_report_type          varchar2(50);
    lv_report_qualifier     varchar2(50);
    ln_business_group_id    number;
    ln_seq_num    number;

  BEGIN
    hr_utility.set_location(gv_package || '.get_payroll_action_info', 10);

    open c_payroll_action(p_payroll_action_id);
    fetch c_payroll_action into
            ld_start_date,
            ld_end_date,
            lv_report_type,
            lv_report_qualifier,
            ln_business_group_id,
            ln_seq_num;
    if c_payroll_action%notfound then
       hr_utility.set_location( gv_package || '.get_payroll_action_info',20);
       hr_utility.trace('Payroll Action '||to_char(p_payroll_action_id)||' Not found');
       hr_utility.raise_error;
    end if;
    close c_payroll_action;
    hr_utility.set_location(gv_package || '.get_payroll_action_info', 30);
    p_start_date           := ld_start_date;
    p_end_date             := ld_end_date;
    p_report_type          := lv_report_type;
    p_report_qualifier     := lv_report_qualifier;
    p_business_group_id    := ln_business_group_id;
    p_seq_num              := ln_seq_num;

    hr_utility.set_location(gv_package || '.get_payroll_action_info', 40);
  END get_payroll_action_info;

  --------------------------------------------------------------------------
  --Name
  --    preprocess_check
  -- Purpose
  --  This function checks whether W-2c paper genrated and waiting for W-2c mag
  --  to pick up for processing. If it doesn't find even a single W-2c paper
  --  assignment action, it logs a message for user
  -- Arguments
  --  p_pactid		   payroll_action_id for the report
  --  p_year_start	   start date of the period for which the report
  --			   has been requested
  --  p_year_end	   end date of the period
  --  p_business_group_id  business group for which the report is being run
  --
  --Notes
  --
  --
  --
  -----------------------------------------------------------------------------
  FUNCTION preprocess_check  (p_payroll_action_id   IN NUMBER,
                              p_start_date   	    IN DATE,
                              p_end_date  		    IN DATE,
                              p_business_group_id	IN NUMBER
                              ) RETURN BOOLEAN
  IS
  lb_return_value          BOOLEAN;
  ln_w2c_paper_asgn_actid  number;
  lv_message_text          varchar2(200);
  lv_message_preprocess    varchar2(200);

  cursor get_w2c_paper_assignments (cp_business_group_id    in number
                                   ,cp_start_date           in date
                                   ,cp_end_date             in date
                                    )
   IS
   select paa.assignment_Action_id
     from pay_assignment_actions paa,
          per_all_assignments_f  paf,
          pay_payroll_actions    ppa
    where ppa.business_group_id = cp_business_group_id
      and ppa.effective_date    between cp_start_date and cp_end_date
      and ppa.action_type       = 'X'
      and ppa.report_type       = 'W-2C PAPER'
      and ppa.action_status     = 'C'
      and ppa.payroll_action_id = paa.payroll_action_id
      and paf.assignment_id     = paa.assignment_id
      and paf.effective_start_date <= ppa.effective_date
      and paf.effective_end_date   >= ppa.start_date
      and paf.assignment_type = 'E'
      and not exists
          (select 'x' from pay_Action_interlocks     pai,
                           pay_assignment_actions    paa1,
                           pay_payroll_actions       ppa1
                     where pai.locked_action_id      = paa.assignment_action_id
                       and paa1.assignment_action_id = pai.locking_action_id
                       and ppa1.payroll_action_id    = paa1.payroll_action_id
                       and ppa1.effective_date     between cp_start_date and cp_end_date
                       and ppa1.action_type          = 'X'
                       and ppa1.report_type          = 'MARK_W2C_PAPER'
                       and ppa1.report_category      = 'RT'
                       and ppa1.action_status        = 'C')
      and not exists
          (select 'x' from pay_Action_interlocks     pai,
                           pay_assignment_actions    paa1,
                           pay_payroll_actions       ppa1
                     where pai.locked_action_id      = paa.assignment_action_id
                       and paa1.assignment_action_id = pai.locking_action_id
                       and ppa1.payroll_action_id    = paa1.payroll_action_id
                       and ppa1.effective_date  between cp_start_date and cp_end_date
                       and ppa1.action_type          = 'X'
                       and ppa1.report_type          = 'W2C'
                       and ppa1.report_qualifier     = 'FED'
                       and ppa1.report_category      = 'RM'
                       and ppa1.action_status        = 'C');
  BEGIN
     hr_utility.set_location(gv_package || '.preprocess_check', 10);
     lb_return_value          := TRUE;
     ln_w2c_paper_asgn_actid  := 0;
     lv_message_text          := '';
     lv_message_preprocess    := 'Pre-Process check';
  --
  -- Determine whether any W-2c paper assignment action exist to mark
  -- W-2c Paper and exclude from future tapes. If not log an error message
  -- for user
  --
     OPEN  get_w2c_paper_assignments(p_business_group_id,
                                     p_start_date,
                                     p_end_date);
     FETCH get_w2c_paper_assignments INTO ln_w2c_paper_asgn_actid;
     if (get_w2c_paper_assignments%ROWCOUNT = 0
         or get_w2c_paper_assignments%NOTFOUND )
     then
        hr_utility.set_location(gv_package || '.preprocess_check', 20);
        CLOSE get_w2c_paper_assignments;
     /* message to user -- unable to find W-2c Paper report
                           to exclude from future tapes */
        lv_message_text := 'No W-2c paper printed to mark and exclude from Tape';
        pay_core_utils.push_message(801,'PAY_INVALID_ER_DATA','P');
        pay_core_utils.push_token('record_name',lv_message_preprocess);
        pay_core_utils.push_token('description',lv_message_text);
        lb_return_value := FALSE;
        raise hr_utility.hr_error;
        hr_utility.set_location(gv_package || '.preprocess_check', 30);
     else
        CLOSE get_w2c_paper_assignments;
        lb_return_value := TRUE;
        hr_utility.set_location(gv_package || '.preprocess_check', 30);
     end if;
     hr_utility.set_location(gv_package || '.preprocess_check', 40);
     return lb_return_value;
  END preprocess_check;
  -- End of Function Preprocess_Check


  /******************************************************************
  ** Range Code to pick all the distinct assignment_ids
  ** that need to be marked as submitted to governement.
  *******************************************************************/
  PROCEDURE mark_w2c_range_cursor( p_payroll_action_id in         number
                                  ,p_sqlstr            out nocopy varchar2)
  IS

    ld_start_date           date;
    ld_end_date             date;
    lv_report_type          varchar2(30);
    lv_report_qualifier     varchar2(30);
    ln_business_group_id    number;
    ln_seq_num    number;

    lv_sql_string           varchar2(10000);
  BEGIN
    hr_utility.set_location(gv_package || '.mark_w2c_range_cursor', 10);
    get_payroll_action_info(p_payroll_action_id
                           ,ld_start_date
                           ,ld_end_date
                           ,lv_report_type
                           ,lv_report_qualifier
                           ,ln_business_group_id
                           ,ln_seq_num
                            );

    hr_utility.trace('ld_start_date        = ' || ld_start_date);
    hr_utility.trace('ld_end_date          = ' || ld_end_date);
    hr_utility.trace('lv_report_type       = ' || lv_report_type);
    hr_utility.trace('lv_report_qualifier  = ' || lv_report_qualifier);
    hr_utility.trace('ln_business_group_id = ' || ln_business_group_id);
    hr_utility.trace('ln_seq_num = ' || to_char(ln_seq_num));

    hr_utility.set_location(gv_package || '.mark_w2c_range_cursor', 15);
    if preprocess_check ( p_payroll_action_id
                         ,ld_start_date
                         ,ld_end_date
                         ,ln_business_group_id
                        )
    then
       hr_utility.trace('W-2c paper Assignments exist to process' );
    else
       hr_utility.trace('W-2c paper Assignments does not exist to process');
    end if;

    hr_utility.set_location(gv_package || '.mark_w2c_range_cursor', 20);
    if lv_report_type = 'MARK_W2C_PAPER' then
       hr_utility.set_location(gv_package || '.mark_w2c_range_cursor', 30);
       lv_sql_string :=
                  'select distinct paf.person_id
                     from pay_assignment_actions paa,
                          per_all_assignments_f  paf,
                          pay_payroll_actions    ppa
                    where ppa.business_group_id = '|| ln_business_group_id || '
                      and ppa.effective_date between to_date(''' ||
                          to_char(ld_start_date, 'dd-mon-yyyy') || ''',''dd-mon-yyyy'')
                          and to_date(''' || to_char(ld_end_date, 'dd-mon-yyyy') || ''',''dd-mon-yyyy'')
                      and ppa.action_type = ''X''
                      and ppa.report_type = ''W-2C PAPER''
                      and ppa.action_status = ''C''
                      and ppa.payroll_action_id = paa.payroll_action_id
                      and paf.assignment_id     = paa.assignment_id
                      and paf.effective_start_date <= ppa.effective_date
                      and paf.effective_end_date >= ppa.start_date
                      and paf.assignment_type = ''E''
                      and :payroll_action_id is not null
                      and not exists
                         (select ''x'' from pay_Action_interlocks     pai,
                                            pay_assignment_actions    paa1,
                                            pay_payroll_actions       ppa1
                           where pai.locked_action_id      = paa.assignment_action_id
                             and paa1.assignment_action_id = pai.locking_action_id
                             and ppa1.payroll_action_id    = paa1.payroll_action_id
                             and ppa1.effective_date between to_date(''' ||
                                 to_char(ld_start_date, 'dd-mon-yyyy') || ''',''dd-mon-yyyy'')
                                 and to_date(''' || to_char(ld_end_date, 'dd-mon-yyyy') || ''',''dd-mon-yyyy'')
                             and ppa1.action_type          = ''X''
                             and ppa1.report_type          = ''MARK_W2C_PAPER''
                             and ppa1.action_status        = ''C'')
                      and not exists
                         (select ''x'' from pay_Action_interlocks     pai,
                                          pay_assignment_actions    paa1,
                                          pay_payroll_actions       ppa1
                           where pai.locked_action_id      = paa.assignment_action_id
                             and paa1.assignment_action_id = pai.locking_action_id
                             and ppa1.payroll_action_id    = paa1.payroll_action_id
                             and ppa1.effective_date between to_date(''' ||
                                 to_char(ld_start_date, 'dd-mon-yyyy') || ''',''dd-mon-yyyy'')
                                 and to_date(''' || to_char(ld_end_date, 'dd-mon-yyyy') || ''',''dd-mon-yyyy'')
                             and ppa1.action_type          = ''X''
                             and ppa1.report_type          = ''W2C''
                             and ppa1.report_qualifier     = ''FED''
                             and ppa1.action_status        = ''C'')';
       p_sqlstr := lv_sql_string;
       hr_utility.set_location(gv_package || '.mark_w2c_range_cursor', 40);
       hr_utility.trace('p_sqlstr = ' ||substr(p_sqlstr,1,100));
       hr_utility.trace('p_sqlstr = ' ||substr(p_sqlstr,2000,100));
       hr_utility.trace('length of p_sqlstr <' || to_char(length(p_sqlstr))||'>' );
       hr_utility.trace('Procedure mark_w2c_range_cursor completed successfully');

    else
       hr_utility.trace('Procedure mark_w2c_range_cursor Unsucessful ... ');
    end if;

  end mark_w2c_range_cursor;

  /*******************************************************************
  ** Action Creation Code to create assignment actions for all the
  ** the assignment_ids that need to be marked as submitted to governement
  *******************************************************************/
  PROCEDURE mark_w2c_action_creation( p_payroll_action_id    in number
                                     ,p_start_person_id      in number
                                     ,p_end_person_id        in number
                                     ,p_chunk                in number)
  IS
   cursor get_w2c_paper_assignments (cp_business_group_id    in number
                                    ,cp_start_date           in date
                                    ,cp_end_date             in date
                                    ,cp_start_person_id      in number
                                    ,cp_end_person_id        in number)
   IS
   select paa.assignment_id,
          paa.tax_unit_id,
          paf.person_id,
          paa.assignment_Action_id
     from pay_assignment_actions paa,
          per_all_assignments_f  paf,
          pay_payroll_actions    ppa
    where ppa.business_group_id = cp_business_group_id
      and ppa.effective_date    between cp_start_date and cp_end_date
      and ppa.action_type       = 'X'
      and ppa.report_type       = 'W-2C PAPER'
      and ppa.action_status     = 'C'
      and ppa.payroll_action_id = paa.payroll_action_id
      and paf.assignment_id     = paa.assignment_id
      and paf.effective_start_date <= ppa.effective_date
      and paf.effective_end_date   >= ppa.start_date
      and paf.assignment_type = 'E'
      and paf.person_id     between cp_start_person_id
                                    and cp_end_person_id
      and not exists
          (select 'x' from pay_Action_interlocks     pai,
                           pay_assignment_actions    paa1,
                           pay_payroll_actions       ppa1
                     where pai.locked_action_id      = paa.assignment_action_id
                       and paa1.assignment_action_id = pai.locking_action_id
                       and ppa1.payroll_action_id    = paa1.payroll_action_id
                       and ppa1.effective_date     between cp_start_date and cp_end_date
                       and ppa1.action_type          = 'X'
                       and ppa1.report_type          = 'MARK_W2C_PAPER'
                       and ppa1.report_category      = 'RT'
                       and ppa1.action_status        = 'C')
      and not exists
          (select 'x' from pay_Action_interlocks     pai,
                           pay_assignment_actions    paa1,
                           pay_payroll_actions       ppa1
                     where pai.locked_action_id      = paa.assignment_action_id
                       and paa1.assignment_action_id = pai.locking_action_id
                       and ppa1.payroll_action_id    = paa1.payroll_action_id
                       and ppa1.effective_date  between cp_start_date and cp_end_date
                       and ppa1.action_type          = 'X'
                       and ppa1.report_type          = 'W2C'
                       and ppa1.report_qualifier     = 'FED'
                       and ppa1.report_category      = 'RM'
                       and ppa1.action_status        = 'C');

    ld_start_date           DATE;
    ld_end_date             DATE;
    lv_report_type          VARCHAR2(30);
    lv_report_qualifier     VARCHAR2(30);
    ln_business_group_id    NUMBER;
    ln_seq_num    NUMBER;

    /* Assignment Record Local Variables */
    ln_assignment_id        number;
    ln_emp_tax_unit_id      number;
    ln_person_id            number;
    ln_assignment_action_id number;

   PROCEDURE action_creation (lp_person_id in         number,
                              lp_assignment_id        number,
                              lp_assignment_action_id number,
                              lp_tax_unit_id          number,
                              ld_start_date           date,
                              ld_end_date             date,
                              ln_seq_num              number)
   IS

   cursor ee_details (cp_person_id in number,
                      cp_end_date in date) is
   select ppf.full_name, ppf.national_identifier, ppf.employee_number,
          paf.assignment_number
     from per_all_people_f ppf,
          per_all_assignments_f paf
    where ppf.person_id  = cp_person_id
      and paf.person_id = ppf.person_id
      and cp_end_date between ppf.effective_start_date
                          and ppf.effective_end_date
      and cp_end_date between paf.effective_start_date
                          and paf.effective_end_date;



   cursor gre_name (cp_tax_unit_id in varchar2) is
   SELECT name
    FROM hr_organization_units
   WHERE organization_id = cp_tax_unit_id;

   cursor get_paper_details (cp_assignment_action_id in number) is
   select creation_date
     from pay_payroll_actions ppa,
          pay_assignment_actions paa
    where paa.assignment_action_id = cp_assignment_action_id
      and ppa.payroll_action_id = paa.payroll_action_id;



   ln_w2c_asg_action       NUMBER := 0;
   lv_full_name            per_all_people_f.full_name%type;
   lv_national_identifier  per_all_people_f.national_identifier%type;
   lv_employee_number      per_all_people_f.employee_number%type;
   lv_assignment_number    per_all_assignments_f.assignment_number%type;
   lv_gre_name hr_organization_units.name%type;
   lv_year varchar2(4) ;
   lv_creation_date varchar2(20) ;
   lv_sysdate varchar2(20) ;

   BEGIN
       hr_utility.set_location(gv_package || '.action_creation', 10);
       /* Create an assignment action for this person */


     lv_year := to_char(ld_end_date,'YYYY'); --MOD
     open ee_details (lp_person_id,ld_end_date);
     fetch ee_details into lv_full_name,
                           lv_national_identifier,
                           lv_employee_number,
                           lv_assignment_number;

     close ee_details;


     open gre_name (lp_tax_unit_id);
     fetch gre_name into lv_gre_name;
     close gre_name;

     open get_paper_details (lp_assignment_action_id);
     fetch get_paper_details  into lv_creation_date;
     close get_paper_details;

     select sysdate into lv_sysdate from dual;


       select pay_assignment_actions_s.nextval
         into ln_w2c_asg_action
         from dual;
       hr_utility.set_location(gv_package || '.action_creation', 20);
       hr_utility.trace('New w2c Action = ' || to_char(ln_w2c_asg_action));

       /* Insert into pay_assignment_actions. */
       hr_utility.trace('Creating Assignment Action');

       hr_nonrun_asact.insact(ln_w2c_asg_action
                             ,lp_assignment_id
                             ,p_payroll_action_id
                             ,p_chunk
                             ,lp_tax_unit_id);

       /* Update the serial number column with the person id
          so that the W2C report will not have
          to do an additional checking against the assignment
          table */

       hr_utility.set_location(gv_package || '.action_creation', 30);
       hr_utility.trace('updating asg action');
       update pay_assignment_actions aa
          set aa.serial_number = lp_person_id
        where  aa.assignment_action_id = ln_w2c_asg_action;

       /* Interlock the w2c report action with current mark w2c action */

       hr_utility.trace('Locking Action = ' || ln_w2c_asg_action);
       hr_utility.trace('Locked Action = '  || lp_assignment_action_id);
       hr_nonrun_asact.insint(ln_w2c_asg_action
                             ,lp_assignment_action_id);
       hr_utility.set_location(gv_package || '.action_creation', 40);


       insert into pay_us_rpt_totals
       (GRE_NAME,
        STATE_NAME,
        ATTRIBUTE1, -- FULL_NAME
        ATTRIBUTE2, -- NATIONAL_IDENTIFIER
        ATTRIBUTE3, -- EMPLOYEE_NUMBER
        ATTRIBUTE4, -- ASSIGNMENT_NUMBER
        ATTRIBUTE5, -- ASSIGNMENT_ACTION_ID
        ATTRIBUTE6, -- YEAR
        SESSION_ID, -- SESSION_ID
        ATTRIBUTE7, -- PAPER_CREATION_DATE
        ATTRIBUTE8  -- SYSDATE
       )
       VALUES
       (lv_gre_name,
        'MARKW2C_PROCESS',
        lv_full_name,
        lv_national_identifier,
        lv_employee_number,
        lv_assignment_number,
        lp_assignment_action_id,
        lv_year,
        ln_seq_num,
        lv_creation_date,
        lv_sysdate
       );


       hr_utility.trace('Inserted lv_gre_name ' || lv_gre_name);
       hr_utility.trace('Inserted lv_full_name ' || lv_full_name);
       hr_utility.trace('Inserted lv_natidentifier' ||lv_national_identifier);
       hr_utility.trace('Inserted lv_employee_number' ||lv_employee_number);
       hr_utility.trace('Inserted lv_assignment_number' ||lv_assignment_number);
       hr_utility.trace('Inserted lp_aaid' ||to_char(lp_assignment_action_id));

  end action_creation; -- End of Local function Action_Creation
--
-- Action Creation Main Logic
--
  begin
--{
     hr_utility.set_location(gv_package || '.mark_w2c_action_creation', 10);
     hr_utility.trace('Entered Mark_W2c_action_creation ');
     hr_utility.trace('p_payroll_action_id   = '|| to_char(p_payroll_action_id));
     hr_utility.trace('p_start_person_id     = '|| to_char(p_start_person_id));
     hr_utility.trace('p_end_person_id       = '|| to_char(p_end_person_id));
     hr_utility.trace('p_chunk               = '|| to_char(p_chunk));

     hr_utility.set_location(gv_package || '.mark_w2c_action_creation', 15);
     get_payroll_action_info(p_payroll_action_id
                            ,ld_start_date
                            ,ld_end_date
                            ,lv_report_type
                            ,lv_report_qualifier
                            ,ln_business_group_id
                            ,ln_seq_num);

     hr_utility.trace('ld_start_date        = ' || ld_start_date);
     hr_utility.trace('ld_end_date          = ' || ld_end_date);
     hr_utility.trace('lv_report_type       = ' || lv_report_type);
     hr_utility.trace('lv_report_qualifier  = ' || lv_report_qualifier);
     hr_utility.trace('ln_business_group_id = ' || ln_business_group_id);
     hr_utility.trace('ln_seq_num = ' || to_char(ln_seq_num));

     hr_utility.set_location(gv_package || '.mark_w2c_action_creation', 20);
     open get_w2c_paper_assignments (ln_business_group_id
                                    ,ld_start_date
                                    ,ld_end_date
                                    ,p_start_person_id
                                    ,p_end_person_id
                                    );
     loop
--{
        hr_utility.set_location(gv_package || '.mark_w2c_action_creation', 30);
        fetch get_w2c_paper_assignments into ln_assignment_id,
                                             ln_emp_tax_unit_id,
                                             ln_person_id,
                                             ln_assignment_action_id;

        hr_utility.set_location(gv_package || '.mark_w2c_action_creation', 40);

        if get_w2c_paper_assignments%ROWCOUNT = 0  then
           hr_utility.set_location(gv_package || '.mark_w2c_action_creation', 50);
           hr_utility.trace('No Person found for reporting in this chunk');
        end if;

        EXIT WHEN get_w2c_paper_assignments%NOTFOUND;

        hr_utility.set_location(gv_package || '.mark_w2c_action_creation', 60);
        hr_utility.trace('ln_assignment_id        ='  || ln_assignment_id);
        hr_utility.trace('ln_emp_tax_unit_id      ='  || ln_emp_tax_unit_id);
        hr_utility.trace('ln_person_id            ='  || ln_person_id);
        hr_utility.trace('ln_assignment_action_id ='  || ln_assignment_action_id);

        if ln_person_id is not null then
           hr_utility.set_location(gv_package || '.mark_w2c_action_creation', 70);
           action_creation(ln_person_id,
                           ln_assignment_id,
                           ln_assignment_action_id,
                           ln_emp_tax_unit_id,
                           ld_start_date,
                           ld_end_date,
                           ln_seq_num);
           hr_utility.set_location(gv_package || '.mark_w2c_action_creation', 80);

        end if;
        hr_utility.set_location(gv_package || '.mark_w2c_action_creation', 90);
--}
     end loop;
     close get_w2c_paper_assignments;
     hr_utility.trace('Action Creation for Mark_W2c_Paper completed Successfully');
     hr_utility.set_location(gv_package || '.mark_w2c_action_creation', 100);
--}
  end mark_w2c_action_creation;
-- End of Procedure mar_w2c_action_creation
--alka --

  /*****************************************************************
  ** This procudure returns the Mandatory Static Labels and the
  ** Other Additional Static columns.
  *****************************************************************/
  FUNCTION employee_header(p_output_file_type  in varchar2)
  RETURN VARCHAR2
  IS

    lv_format1          varchar2(32000);
    lv_format2          varchar2(32000);

  BEGIN

      hr_utility.set_location(gv_package || '.formated_static_header', 10);
      hr_utility.trace('Entered employee_header');


      lv_format1 :=
              pay_us_payroll_utils.formated_data_string (
                                    p_input_string => 'GRE Name'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              pay_us_payroll_utils.formated_data_string (
                                    p_input_string => 'Employee''s Name'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              pay_us_payroll_utils.formated_data_string (
                                    p_input_string => 'Social Security Number'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              pay_us_payroll_utils.formated_data_string (
                                    p_input_string => 'Employee Number'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              pay_us_payroll_utils.formated_data_string (
                                    p_input_string => 'Assignment Number'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              pay_us_payroll_utils.formated_data_string (
                                    p_input_string => 'Paper Creation Date'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ;

      hr_utility.trace('Leaving employee_header');
      RETURN (lv_format1);
  END employee_header;


  FUNCTION employee_data (
                   p_tax_unit_name             in varchar2
                  ,p_full_name                 in varchar2
                  ,p_national_identifier       in varchar2
                  ,p_employee_number           in varchar2
                  ,p_assignment_number         in varchar2
                  ,p_assignment_action_id      in varchar2
		  ,p_year                      in varchar2
		  ,p_creation_date             in varchar2
		  ,p_sysdate                   in varchar2
                  ,p_output_file_type          in varchar2 )

  RETURN VARCHAR2
  IS

    lv_format1 VARCHAR2(32000);
    lv_format2 VARCHAR2(32000);


  BEGIN

      hr_utility.set_location(gv_package || '.formated_static_data', 10);
      hr_utility.trace('Entered employee_data');
      hr_utility.trace('ER Name = '||p_tax_unit_name);
      hr_utility.trace('Year = '||p_year);
      hr_utility.trace('EE Name = '||p_full_name);

      lv_format1 :=
              pay_us_payroll_utils.formated_data_string (
                                    p_input_string => p_tax_unit_name
                                   ,p_output_file_type => p_output_file_type)||
              pay_us_payroll_utils.formated_data_string (
                                    p_input_string => p_full_name
                                   ,p_output_file_type => p_output_file_type)||
              pay_us_payroll_utils.formated_data_string (
                                    p_input_string => p_national_identifier
                                   ,p_output_file_type => p_output_file_type)||
              pay_us_payroll_utils.formated_data_string (
                                    p_input_string => p_employee_number
                                   ,p_output_file_type => p_output_file_type)||
              pay_us_payroll_utils.formated_data_string (
                                    p_input_string => p_assignment_number
                                   ,p_output_file_type => p_output_file_type)||
              pay_us_payroll_utils.formated_data_string (
                                    p_input_string => p_creation_date
                                   ,p_output_file_type => p_output_file_type) ;

      hr_utility.set_location(gv_package || '.formated_static_data', 20);


      hr_utility.trace('Static Data1 = ' || lv_format1);
      hr_utility.set_location(gv_package || '.formated_static_data', 40);
      hr_utility.trace('Built employee_data');

      return (lv_format1);
      hr_utility.trace('Leaving employee_data');
  END employee_data;


  PROCEDURE select_ee_details(errbuf        OUT nocopy VARCHAR2,
                              retcode       OUT nocopy NUMBER,
                              p_seq_num      IN        VARCHAR2,
                              p_output_file_type  IN        VARCHAR2)
  IS

     cursor c_get_lookup_code(cp_lookup_meaning in varchar2) is
       select lookup_code from hr_lookups
        where lookup_type = 'REPORT_OUTPUT_TYPE'
          and meaning = cp_lookup_meaning
          and application_id = 800;

     cursor c_ee_details (c_seq_num in VARCHAR2) is
       SELECT
            gre_name,
            attribute1, --full_name,
            attribute2, --national_identifier,
            attribute3, -- employee_number,
            attribute4, -- assignment_number,
            attribute6, -- year
            attribute7, -- PAPER_CREATION_DATE
            attribute8  -- Sysdate
     FROM   pay_us_rpt_totals
     WHERE  state_name = 'MARKW2C_PROCESS'
     AND   session_id = to_number(c_seq_num)
     ORDER BY attribute6,gre_name, attribute1,attribute4,attribute5;

     lv_gre_name        varchar2(240);
     lv_full_name        varchar2(240);
     lv_ssn              varchar2(240);
     lv_ee_number        varchar2(240);
     lv_asg_number       varchar2(240);
     lv_aaid             varchar2(240);
     lv_year             varchar2(240);
     lv_creation_date    varchar2(240);
     lv_sysdate          varchar2(240);
     lv_data_row         varchar2(32000);
     lv_output_file_type varchar2(240);

  BEGIN
     hr_utility.trace('Entered Main package');
     hr_utility.trace('p_seq_num = '||p_seq_num);

     open c_get_lookup_code(p_output_file_type);
     fetch c_get_lookup_code into lv_output_file_type;
     close c_get_lookup_code;


     OPEN c_ee_details(p_seq_num);
     hr_utility.trace('Opened c_ee_details');
     LOOP
        lv_gre_name   := null;
        lv_full_name  := null;
        lv_ssn        := null;
        lv_ee_number  := null;
        lv_asg_number := null;
        lv_year       := null;
        lv_creation_date := null;
        lv_sysdate    := null;

        FETCH c_ee_details INTO lv_gre_name,
                                lv_full_name,
                                lv_ssn,
                                lv_ee_number,
                                lv_asg_number,
                                lv_year,
                                lv_creation_date,
                                lv_sysdate;

        hr_utility.trace('Fetched c_ee_details');
        EXIT WHEN c_ee_details%notfound;

          if c_ee_details%ROWCOUNT =1 THEN

              FND_FILE.PUT_LINE(FND_FILE.OUTPUT
                               ,pay_us_payroll_utils.formated_header_string(
                                          gv_title || ' - Tax Year: ' ||
                                          lv_year  || ' as of '|| lv_sysdate
                                         ,lv_output_file_type ));


              if lv_output_file_type ='HTML' THEN
                 FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<body>');
                 FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<table border=1 align=center>');
                 FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<tr>');
              end if;

               fnd_file.put_line(fnd_file.output
                                ,employee_header(lv_output_file_type));

               if p_output_file_type ='HTML' then
                  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</tr>');
               end if;

          end if;

        lv_data_row :=  employee_data (
                              p_tax_unit_name        => lv_gre_name
                             ,p_full_name            => lv_full_name
                             ,p_national_identifier  => lv_ssn
                             ,p_employee_number      => lv_ee_number
                             ,p_assignment_number    => lv_asg_number
                             ,p_assignment_action_id => lv_aaid
                             ,p_year                 => lv_year
                             ,p_creation_date        => lv_creation_date
                             ,p_sysdate              => lv_sysdate
                             ,p_output_file_type     => lv_output_file_type);

        if p_output_file_type ='HTML' then
           lv_data_row := '<tr>' || lv_data_row || '</tr>' ;
        end if;

        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, lv_data_row);

     END LOOP;
     CLOSE c_ee_details;

     if p_output_file_type ='HTML' then
        UPDATE fnd_concurrent_requests
        SET output_file_type = 'HTML'
        WHERE request_id = FND_GLOBAL.CONC_REQUEST_ID ;
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</table></body></html>');
     end if;

     DELETE FROM pay_us_rpt_totals
      WHERE session_id = to_number(p_seq_num);

  END select_ee_details;

Begin
  --hr_utility.trace_on(null,'MARKW2C');
  gv_package := 'pay_us_mark_w2c_paper';
  gv_title   := 'Assignments Marked to be Excluded from W-2c Tape';
END pay_us_mark_w2c_paper;

/
