--------------------------------------------------------
--  DDL for Package Body PER_MX_SSAFFL_DISPMAG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_MX_SSAFFL_DISPMAG" AS
/* $Header: permxdispmag.pkb 120.1 2006/05/18 23:58:38 vpandya noship $ */
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

    Name        : per_mx_ssaffl_dispmag

    Description : This package is used by the Social Security Affiliation
                  Magnetic (DISPMAG) report to produce the DISPMAG Magnetic file.

    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  --------------------------
    28-MAY-2004 kthirmiy   115.0            Created.
    12-JUL-2004 kthirmiy   115.1   3748081  added nvl condition on getting the names
                                   3751486  in the format_dispmag_emp_record procedure
                                            to fix the bug
    14-JUL-2004 kthirmiy   115.2   3766730  added upper to name components
    15-Jul-2004 kthirmiy   115.3   3753718  added validation logic in
                                            format_dispmag_emp_record to write in
                                            error exception file
    05-Aug-2004 kthirmiy   115.4   3794229  Added to write the error mesg using
                                            push_message.
                                   3815904  changed medical center to Prefix with 0.
    19-Nov-2004 kthirmiy   115.5            added salary_details in the
                                            format_dispmag_emp_record for
                                            Social Security Salary Modification report
    02-Dec-2004 kthirmiy   115.6            Added format to IDW to retrive 4,2 with
                                            implied decimal
    06-May-2005 kthirmiy   115.7   4353084  removed the redundant use of bind variable
                                            payroll_action_id
    18-May-2006 vpandya    115.8   5234421  Calling pay_mx_rules.strip_spl_chars
                                            for all names that are printed in
                                            output files to remove special
                                            characters.
  ******************************************************************************/

   --
   -- < PRIVATE GLOBALS > ---------------------------------------------------
   --

   gv_package             VARCHAR2(100)   ;
   g_concurrent_flag      VARCHAR2(1)  ;
   g_debug_flag           VARCHAR2(1)  ;



  /******************************************************************************
   Name      : msg
   Purpose   : Log a message, either using fnd_file, or hr_utility.trace
  ******************************************************************************/

  PROCEDURE msg(p_text  VARCHAR2)
  IS
  --
  BEGIN
    -- Write to the concurrent request log
    fnd_file.put_line(fnd_file.log, p_text);

  END msg;

  /******************************************************************************
   Name      : dbg
   Purpose   : Log a message, either using fnd_file, or hr_utility.trace
               if debuggging is enabled
  ******************************************************************************/
  PROCEDURE dbg(p_text  VARCHAR2) IS

  BEGIN

   IF (g_debug_flag = 'Y') THEN
     IF (g_concurrent_flag = 'Y') THEN
        -- Write to the concurrent request log
        fnd_file.put_line(fnd_file.log, p_text);
     ELSE
         -- Use HR trace
         hr_utility.trace(p_text);
     END IF;
   END IF;

  END dbg;


  /******************************************************************************
   Name      : get_payroll_action_info
   Purpose   : This returns the Payroll Action level
               information for SS Affiliation Magnetic DISPMAG report.
  ******************************************************************************/
  PROCEDURE get_payroll_action_info(p_payroll_action_id     in        number
                                   ,p_business_group_id    out nocopy number
                                   ,p_trans_gre_id   out nocopy number
                                   ,p_gre_id         out nocopy number
                                   ,p_affl_type      out nocopy varchar2
                                   )
  IS
      -- cursor to get all the parameters from pay_payroll_actions table

      cursor c_payroll_Action_info(cp_payroll_action_id in number) is
      select business_group_id,
             report_qualifier,
             to_number(ltrim(rtrim(substr(legislative_parameters,
                instr(legislative_parameters,
                         'GRE_ID=')
                + length('GRE_ID='))))),
      to_number(ltrim(rtrim(substr(legislative_parameters,
                instr(legislative_parameters,
                         'TRANS_GRE=')
                + length('TRANS_GRE='),
                (instr(legislative_parameters,
                         'GRE_ID=') - 1 )
              - (instr(legislative_parameters,
                         'TRANS_GRE=')
              + length('TRANS_GRE='))))))
      from pay_payroll_actions
      where payroll_action_id = cp_payroll_action_id;


    ln_business_group_id NUMBER;
    ln_trans_gre_id      NUMBER;
    ln_gre_id            NUMBER;
    lv_affl_type         VARCHAR2(11) ;

    lv_procedure_name    VARCHAR2(100) ;
    lv_error_message     VARCHAR2(200) ;
    ln_step              NUMBER;

   BEGIN

       lv_procedure_name    := '.get_payroll_action_info';

       hr_utility.set_location(gv_package || lv_procedure_name, 10);
       ln_step := 1;
       dbg('Entering get_payroll_action_info .......');

       -- open the cursor to get all the parameters from pay_payroll_actions table
       open c_payroll_action_info(p_payroll_action_id);
       fetch c_payroll_action_info into ln_business_group_id,
                                        lv_affl_type,
                                        ln_gre_id,
                                        ln_trans_gre_id
                                        ;
       close c_payroll_action_info;

       ln_step := 2;

       p_business_group_id  := ln_business_group_id;
       p_affl_type          := lv_affl_type ;
       p_gre_id             := ln_gre_id;
       p_trans_gre_id       := ln_trans_gre_id;


       dbg('business group id  : ' || to_char(p_business_group_id)) ;
       dbg('affliation type    : ' || p_affl_type );
       dbg('transmitter gre id : ' || to_char(p_trans_gre_id)) ;
       dbg('gre id             : ' || to_char(p_gre_id)) ;

       hr_utility.set_location(gv_package || lv_procedure_name, 20);
       ln_step := 3;

       dbg('Exiting get_payroll_action_info .......');

  EXCEPTION
    when others then
      lv_error_message := 'Error at step ' || ln_step || ' in ' ||
                           gv_package || lv_procedure_name;

      dbg(lv_error_message || '-' || sqlerrm);
      hr_utility.raise_error;

  END get_payroll_action_info;


  /******************************************************************
   Name      : range_cursor
   Purpose   : This returns the select statement that is
               used to created the range rows for the
               Social Security Affiliation Magnetic DISPMAG report.
   Arguments :
  ******************************************************************/
  PROCEDURE range_cursor( p_payroll_action_id in        number
                         ,p_sqlstr           out nocopy varchar2)
  IS

    ln_business_group_id  NUMBER;
    ln_trans_gre_id NUMBER;
    ln_gre_id       NUMBER;
    lv_affl_type    VARCHAR2(11) ;

    lv_sql_string         VARCHAR2(32000);
    lv_procedure_name     VARCHAR2(100)  ;

  BEGIN

    dbg('Entering range_cursor ....... ') ;

    gv_package            := 'per_mx_ssaffl_dispmag'  ;

    g_debug_flag          := 'Y' ;
    -- g_concurrent_flag     := 'Y' ;

    lv_procedure_name     := '.range_cursor';
    hr_utility.set_location(gv_package || lv_procedure_name, 10);

    --	Get all the parameter information from pay_payroll_actions table
    dbg('Get parameter information from pay_payroll_actions table' ) ;

    get_payroll_action_info(p_payroll_action_id     => p_payroll_action_id
                            ,p_business_group_id    => ln_business_group_id
                            ,p_trans_gre_id         => ln_trans_gre_id
                            ,p_gre_id               => ln_gre_id
                            ,p_affl_type            => lv_affl_type);

     hr_utility.set_location(gv_package || lv_procedure_name, 20);

     lv_sql_string := 'select distinct pai.assignment_id
                       from pay_action_information pai
                       where pai.action_information_category =
                       decode(''' ||lv_affl_type|| ''',''HIRES'',''MX SS HIRE DETAILS'',''SEPARATIONS'',''MX SS SEPARATION DETAILS'')
                       and pai.action_information22 =''A''
                       and :payroll_action_id > 0 ' ;

     hr_utility.set_location(gv_package || lv_procedure_name, 30);
     p_sqlstr := lv_sql_string;
     hr_utility.set_location(gv_package || lv_procedure_name, 40);

     dbg('Exiting range_cursor .......') ;

  END range_cursor;


  /************************************************************
   Name      : action_creation
   Purpose   : This creates the assignment actions for
               a specific chunk of people to be archived
               by the SS Affiliation Magnetic DISPMAG Report.
   Arguments :
   Notes     : Calls procedure - get_payroll_action_info
  ************************************************************/
  PROCEDURE action_creation(
                 p_payroll_action_id   in number
                ,p_start_assignment_id in number
                ,p_end_assignment_id   in number
                ,p_chunk               in number)
  IS

   cursor c_get_asg( cp_start_assignment_id in number
                    ,cp_end_assignment_id   in number
                    ,cp_trans_gre_id  in number
                    ,cp_gre_id        in number
                    ,cp_affl_type     in varchar2
                    ) is

   select pai.action_context_id,pai.assignment_id,pai.tax_unit_id
   from pay_action_information pai
   where pai.assignment_id between cp_start_assignment_id and cp_end_assignment_id
   and   pai.action_information_category =
         decode(cp_affl_type,'HIRES','MX SS HIRE DETAILS','SEPARATIONS','MX SS SEPARATION DETAILS')
   and pai.action_information22 ='A'
   and pai.action_context_type='AAP'
   and (( cp_trans_gre_id is not null and cp_gre_id is not null and pai.tax_unit_id= cp_gre_id )
      or ( cp_trans_gre_id is not null and cp_gre_id is null and
           pai.tax_unit_id in
           (select organization_id
            from hr_organization_information hoi
            where  hoi.org_information_context = 'MX_SOC_SEC_DETAILS'
            and ((org_information6 = cp_trans_gre_id ) OR ( organization_id = cp_trans_gre_id and org_information3='Y')))))
      and not exists (
          select 'Y'
          from pay_action_interlocks pal,
               pay_assignment_actions paa,
               pay_payroll_actions ppa
          where pal.locked_action_id = pai.action_context_id
          and   pal.locking_action_id = paa.assignment_action_id
          and   paa.payroll_action_id = ppa.payroll_action_id
          and   ppa.action_type='X'
          and   ppa.report_type='SS_AFFILIATION'
          and   ppa.report_qualifier=cp_affl_type
          and   paa.tax_unit_id = pai.tax_unit_id
        ) ;


    ln_business_group_id  NUMBER;
    ln_trans_gre_id       NUMBER;
    ln_gre_id             NUMBER;
    lv_affl_type          VARCHAR2(11) ;
    ln_action_context_id  NUMBER;
    ln_assignment_id      NUMBER;
    ln_action_id          NUMBER;
    ln_tax_unit_id        NUMBER;

    lv_procedure_name     VARCHAR2(100) ;
    lv_error_message      VARCHAR2(200);
    ln_step               NUMBER;

  begin

     dbg('Entering Action creation ..............') ;

     gv_package            := 'per_mx_ssaffl_dispmag'  ;
     g_debug_flag          := 'Y' ;
--     g_concurrent_flag     := 'Y' ;

     lv_procedure_name    := '.action_creation';

     hr_utility.set_location(gv_package || lv_procedure_name, 10);
     ln_step := 1;
     dbg('Get parameter information from pay_payroll_actions table' ) ;

     get_payroll_action_info(p_payroll_action_id    => p_payroll_action_id
                            ,p_business_group_id    => ln_business_group_id
                            ,p_trans_gre_id   => ln_trans_gre_id
                            ,p_gre_id         => ln_gre_id
                            ,p_affl_type      => lv_affl_type);


     hr_utility.set_location(gv_package || lv_procedure_name, 20);
     ln_step := 2;
     dbg('Action creation Query parameters') ;
     dbg('Start assignment id : ' || to_char(p_start_assignment_id));
     dbg('End   assignment id : ' || to_char(p_end_assignment_id));
     dbg('tansmitter gre id   : ' || to_char(ln_trans_gre_id));
     dbg('gre id              : ' || to_char(ln_gre_id));
     dbg('affl type           : ' || lv_affl_type);
     dbg('business_group_id   : ' || to_char(ln_business_group_id));

     open c_get_asg( p_start_assignment_id
                    ,p_end_assignment_id
                    ,ln_trans_gre_id
                    ,ln_gre_id
                    ,lv_affl_type);

     -- Loop for all rows returned for SQL statement.
     hr_utility.set_location(gv_package || lv_procedure_name, 30);
     ln_step := 3;

     loop
        fetch c_get_asg into ln_action_context_id,ln_assignment_id,ln_tax_unit_id ;
        exit when c_get_asg%notfound;

        -- create assignment action

        select pay_assignment_actions_s.nextval
        into ln_action_id
        from dual;


        -- insert into pay_assignment_actions.
        hr_nonrun_asact.insact(ln_action_id,
                               ln_assignment_id,
                               p_payroll_action_id,
                               p_chunk,
                               ln_tax_unit_id,  -- nvl(ln_gre_id,ln_trans_gre_id),
                               null,
                               'U',
                               null);

        dbg('assignment action id is ' || to_char(ln_action_id)  );

        -- insert an interlock to this action
        dbg('Locking Action = ' || to_char(ln_action_id));
        dbg('Locked Action  = ' || to_char(ln_action_context_id));
        hr_nonrun_asact.insint(ln_action_id,
                               ln_action_context_id);


     end loop;
     close c_get_asg;

     hr_utility.set_location(gv_package || lv_procedure_name, 50);
     ln_step := 5;

     dbg('Exiting Action creation ..............') ;


  EXCEPTION
    when others then
      lv_error_message := 'Error at step ' || ln_step || ' in ' ||
                           gv_package || lv_procedure_name;
      dbg(lv_error_message || '-' || sqlerrm);
      hr_utility.raise_error;

  END action_creation;

  /************************************************************
   Name      : archinit
   Purpose   : This procedure performs all the required initialization.
   Arguments :
   Notes     :
  ************************************************************/
  PROCEDURE archinit(
                p_payroll_action_id in number)
  IS

    ln_step                   NUMBER;
    lv_procedure_name         VARCHAR2(100) ;

  BEGIN


     dbg('Entering archinit .............');

     gv_package              := 'per_mx_ssaffl_dispmag'  ;
     g_debug_flag            := 'Y' ;    -- Y means debug is ON
--     g_concurrent_flag       := 'Y' ;    -- Y means write in log file
                                         -- Null/N means write as a hr_utility.trace

     lv_procedure_name     := '.archinit';

     hr_utility.set_location(gv_package || lv_procedure_name, 10);
     ln_step := 1;

     dbg('Exiting archinit .............');

  END archinit;

    /************************************************************
    Name      : format_data_string
    Purpose   : This function returns the input string formatted
               with csv data and column delimitter
    Arguments :
    ************************************************************/
    FUNCTION format_data_string
             (p_input_string     in varchar2
             )
    RETURN VARCHAR2
    IS

    lv_format          varchar2(1000);
    lv_csv_delimiter       VARCHAR2(1) ;
    lv_csv_data_delimiter  VARCHAR2(1) ;

    BEGIN

      lv_csv_delimiter       := ',';
      lv_csv_data_delimiter  := '"';

      lv_format := lv_csv_data_delimiter || p_input_string ||
                           lv_csv_data_delimiter || lv_csv_delimiter;

      return lv_format;

    END format_data_string;


    /************************************************************
    Name      : format_dispmag_emp_record
    Purpose   : This function retrieves the archived record from
                pay action information table and format the record
                in the dispmag employee record format.
                This function is called from the DISPMAG_EMPLOYEE
                fast formula by passing the parameters
    Arguments : p_assignment_action_id - assignment_action_id context
                p_affl_type            - affl type parameter
                p_flat_out             - employee record output in
                                         magnetic format
                p_csvr_out             - employee record output in
                                         csv format
                p_flat_ret_str_len     - string length of flat record out
                p_csvr_ret_str_len     - string length of csv  record out
                p_error_flag           - Error flag
                p_error_mesg           - Error Mesg
    **************************************************************/
    FUNCTION format_dispmag_emp_record (
                           p_assignment_action_id    in number, -- context
                           p_affl_type               in varchar2,
                           p_flat_out                out nocopy varchar2,
                           p_csvr_out                out nocopy varchar2,
                           p_flat_ret_str_len        out nocopy number,
                           p_csvr_ret_str_len        out nocopy number,
                           p_error_flag              out nocopy varchar2,
                           p_error_mesg              out nocopy varchar2
     ) RETURN VARCHAR2
    IS

    /************************************************************
    ** Cursor to get the hire/rehire affiliation records from
    ** pay_action_information table
    ************************************************************/

    cursor c_hire_details( cp_assignment_action_id in number
                      ) is
    select action_information1, -- employer ss id
           action_information2, -- employer ss check digit
           action_information3, -- employee ss id
           action_information4, -- employee ss check digit
           action_information5, -- Paternal Last Name
           action_information7, -- Employee Name
           action_information8, -- IDW
           action_information10, -- Worker Type
           action_information11, -- Salary Type
           action_information12, -- Reduced Working Week
           action_information13, -- Date of Hire/Rehire
           action_information17,  -- IMSS Waybill
           rpad(action_information1,10,' ')  ||                     -- employer ss id
           nvl(action_information2,' ')      ||                     -- employer ss check digit
           rpad(action_information3,10,' ')  ||                     -- employee ss id
           nvl(action_information4,' ')      ||                     -- employee ss check digit
           rpad(substr(nvl(pay_mx_rules.STRIP_SPL_CHARS(upper(action_information5)),' '),1,27),27,' ') || -- Paternal Last Name
           rpad(substr(nvl(pay_mx_rules.STRIP_SPL_CHARS(upper(action_information6)),' '),1,27),27,' ') || -- Maternal Last Name
           rpad(substr(nvl(pay_mx_rules.STRIP_SPL_CHARS(upper(action_information7)),' '),1,27),27,' ') || -- Employee Name
           lpad(to_char(to_number(nvl(action_information8,'0'))*100),6,'0') || -- IDW
           rpad(' ',6,' ')       ||                                 -- Filler
           nvl(action_information10,' ')||                          -- Worker Type
           nvl(action_information11,' ') ||                         -- Salary Type
           nvl(action_information12,' ') ||                         -- Reduced Working Week
           rpad(nvl(action_information13,' '),8,' ') ||             -- Date of Hire/Rehire
           lpad(nvl(action_information14,'000'),3,'0') ||           -- Medical Centre
           rpad(' ',2,' ')                 ||                       -- Filler
           action_information16 ||                                  -- Type of Trans
           rpad(action_information17,5,' ') ||                      -- IMSS Waybill
           rpad(action_information18,10,' ') ||                     -- Worker Id
           ' '                  ||                                  -- Filler
           rpad(action_information20,18,' ')||                      -- CURP
           action_information21  ,                                  -- Layout Identifier
           format_data_string(rpad(action_information1,10,' '))  ||
           format_data_string(nvl(action_information2,' '))      ||
           format_data_string(rpad(action_information3,10,' '))  ||
           format_data_string(nvl(action_information4,' '))      ||
           format_data_string(rpad(substr(nvl(pay_mx_rules.STRIP_SPL_CHARS(upper(action_information5)),' '),1,27),27,' ')) ||
           format_data_string(rpad(substr(nvl(pay_mx_rules.STRIP_SPL_CHARS(upper(action_information6)),' '),1,27),27,' ')) ||
           format_data_string(rpad(substr(nvl(pay_mx_rules.STRIP_SPL_CHARS(upper(action_information7)),' '),1,27),27,' ')) ||
           format_data_string(lpad(to_char(to_number(nvl(action_information8,'0'))*100),6,'0')) ||
           format_data_string(rpad(' ',6,' '))       ||
           format_data_string(nvl(action_information10,' ')) ||
           format_data_string(nvl(action_information11,' ')) ||
           format_data_string(nvl(action_information12,' ')) ||
           format_data_string(rpad(nvl(action_information13,' '),8,' ')) ||
           format_data_string(lpad(nvl(action_information14,'000'),3,'0')) ||
           format_data_string(rpad(' ',2,' '))                 ||
           format_data_string(action_information16) ||
           format_data_string(rpad(action_information17,5,' ')) ||
           format_data_string(rpad(action_information18,10,' ')) ||
           format_data_string(' ')                  ||
           format_data_string(rpad(action_information20,18,' '))||
           format_data_string(action_information21)
     from pay_action_information pai,
        pay_action_interlocks  pal,
        pay_assignment_actions paa
     where pal.locking_action_id = cp_assignment_action_id
       and pal.locked_action_id = pai.action_context_id
       and pai.action_context_type ='AAP'
       and pai.action_information_category = 'MX SS HIRE DETAILS'
       and pai.action_information22 ='A'
       and paa.assignment_action_id = pal.locking_action_id
       and pai.tax_unit_id = paa.tax_unit_id ;


    /************************************************************
    ** Cursor to get the SEPARATION affiliation records from
    ** pay_action_information table
    ************************************************************/
    cursor c_sep_details( cp_assignment_action_id in number
                      ) is

    select action_information1,  -- employer ss id
           action_information2,  -- employer ss check digit
           action_information3,  -- employee ss id
           action_information4,  -- employee ss check digit
           action_information5,  -- Paternal Last Name
           action_information7,  -- Employee Name
           action_information9,  -- Date of separation
           action_information12, -- IMSS Waybill
           action_information14, -- Leaving reason
           rpad(action_information1,10,' ')  ||                     -- employer ss id
           nvl(action_information2,' ')      ||                     -- employer ss check digit
           rpad(action_information3,10,' ')  ||                     -- employee ss id
           nvl(action_information4,' ')      ||                     -- employee ss check digit
           rpad(substr(nvl(pay_mx_rules.STRIP_SPL_CHARS(upper(action_information5)),' '),1,27),27,' ') || -- Paternal Last Name
           rpad(substr(nvl(pay_mx_rules.STRIP_SPL_CHARS(upper(action_information6)),' '),1,27),27,' ') || -- Maternal Last Name
           rpad(substr(nvl(pay_mx_rules.STRIP_SPL_CHARS(upper(action_information7)),' '),1,27),27,' ') || -- Employee Name
           rpad('0',15,'0')    ||                                   -- Filler
           rpad(nvl(action_information9,' '),8,' ') ||              -- Date of Emp Separation
           rpad(' ',5,' ')     ||                                   -- Filler
           action_information11 ||                                  -- Type of Trans
           rpad(nvl(action_information12,' '),5,' ') ||             -- IMSS Waybill
           rpad(nvl(action_information13,' '),10,' ') ||            -- Worker Id
           nvl(action_information14,' ') ||                         -- Leaving reason
           rpad(' ',18,' ')     ||                                  -- Filler
           action_information16 ,                                   -- Layout Identifier
           format_data_string(rpad(action_information1,10,' '))  ||
           format_data_string(nvl(action_information2,' '))      ||
           format_data_string(rpad(action_information3,10,' '))  ||
           format_data_string(nvl(action_information4,' '))      ||
           format_data_string(rpad(substr(nvl(pay_mx_rules.STRIP_SPL_CHARS(upper(action_information5)),' '),1,27),27,' ')) ||
           format_data_string(rpad(substr(nvl(pay_mx_rules.STRIP_SPL_CHARS(upper(action_information6)),' '),1,27),27,' ')) ||
           format_data_string(rpad(substr(nvl(pay_mx_rules.STRIP_SPL_CHARS(upper(action_information7)),' '),1,27),27,' ')) ||
           format_data_string(rpad('0',15,'0'))    ||
           format_data_string(rpad(action_information9,8,' ')) ||
           format_data_string(rpad(' ',5,' '))     ||
           format_data_string(action_information11) ||
           format_data_string(rpad(action_information12,5,' ')) ||
           format_data_string(rpad(action_information13,10,' ')) ||
           format_data_string(nvl(action_information14,' ')) ||
           format_data_string(rpad(' ',18,' '))     ||
           format_data_string(action_information16)
     from pay_action_information pai,
        pay_action_interlocks  pal,
        pay_assignment_actions paa
     where pal.locking_action_id = cp_assignment_action_id
       and pal.locked_action_id = pai.action_context_id
       and pai.action_context_type ='AAP'
       and pai.action_information_category = 'MX SS SEPARATION DETAILS'
       and pai.action_information22 ='A'
       and paa.assignment_action_id = pal.locking_action_id
       and pai.tax_unit_id = paa.tax_unit_id ;

    /************************************************************
    ** Cursor to get the salary affiliation records from
    ** pay_action_information table
    ************************************************************/

    cursor c_salary_details( cp_assignment_action_id in number
                      ) is
    select action_information1, -- employer ss id
           action_information2, -- employer ss check digit
           action_information3, -- employee ss id
           action_information4, -- employee ss check digit
           action_information5, -- Paternal Last Name
           action_information7, -- Employee Name
           action_information8, -- IDW
           action_information10, -- Worker Type
           action_information11, -- Salary Type
           action_information12, -- Reduced Working Week
           action_information13, -- Date of Salary modification
           action_information17,  -- IMSS Waybill
           rpad(action_information1,10,' ')  ||                     -- employer ss id
           nvl(action_information2,' ')      ||                     -- employer ss check digit
           rpad(action_information3,10,' ')  ||                     -- employee ss id
           nvl(action_information4,' ')      ||                     -- employee ss check digit
           rpad(substr(nvl(pay_mx_rules.STRIP_SPL_CHARS(upper(action_information5)),' '),1,27),27,' ') || -- Paternal Last Name
           rpad(substr(nvl(pay_mx_rules.STRIP_SPL_CHARS(upper(action_information6)),' '),1,27),27,' ') || -- Maternal Last Name
           rpad(substr(nvl(pay_mx_rules.STRIP_SPL_CHARS(upper(action_information7)),' '),1,27),27,' ') || -- Employee Name
           lpad(to_char(to_number(nvl(action_information8,'0'))*100),6,'0') || -- IDW
           rpad(' ',6,' ')       ||                                 -- Filler
           nvl(action_information10,' ')||                          -- Worker Type
           nvl(action_information11,' ') ||                         -- Salary Type
           nvl(action_information12,' ') ||                         -- Reduced Working Week
           rpad(nvl(action_information13,' '),8,' ') ||             -- Date of Salary Modification
           rpad(' ',5,' ')                 ||                       -- Filler 5 spaces 3 for med center and 2
           action_information16 ||                                  -- Type of Trans
           rpad(action_information17,5,' ') ||                      -- IMSS Waybill
           rpad(action_information18,10,' ') ||                     -- Worker Id
           ' '                  ||                                  -- Filler
           rpad(action_information20,18,' ')||                      -- CURP
           action_information21  ,                                  -- Layout Identifier
           format_data_string(rpad(action_information1,10,' '))  ||
           format_data_string(nvl(action_information2,' '))      ||
           format_data_string(rpad(action_information3,10,' '))  ||
           format_data_string(nvl(action_information4,' '))      ||
           format_data_string(rpad(substr(nvl(pay_mx_rules.STRIP_SPL_CHARS(upper(action_information5)),' '),1,27),27,' ')) ||
           format_data_string(rpad(substr(nvl(pay_mx_rules.STRIP_SPL_CHARS(upper(action_information6)),' '),1,27),27,' ')) ||
           format_data_string(rpad(substr(nvl(pay_mx_rules.STRIP_SPL_CHARS(upper(action_information7)),' '),1,27),27,' ')) ||
           format_data_string(lpad(to_char(to_number(nvl(action_information8,'0'))*100),6,'0')) ||
           format_data_string(rpad(' ',6,' '))       ||
           format_data_string(nvl(action_information10,' ')) ||
           format_data_string(nvl(action_information11,' ')) ||
           format_data_string(nvl(action_information12,' ')) ||
           format_data_string(rpad(nvl(action_information13,' '),8,' ')) ||
           format_data_string(rpad(' ',5,' '))                 ||
           format_data_string(action_information16) ||
           format_data_string(rpad(action_information17,5,' ')) ||
           format_data_string(rpad(action_information18,10,' ')) ||
           format_data_string(' ')                  ||
           format_data_string(rpad(action_information20,18,' '))||
           format_data_string(action_information21)
     from pay_action_information pai
     where pai.action_context_id = cp_assignment_action_id
       and pai.action_information_category = 'MX SS SALARY DETAILS'
       and pai.action_context_type ='AAP'
       and pai.action_information22 ='A' ;

       lv_return_value       varchar2(100);
       lv_er_ss_id           varchar2(100);
       lv_er_ss_chk_digit    varchar2(100);
       lv_ee_ss_id           varchar2(100);
       lv_ee_ss_chk_digit    varchar2(100);
       lv_paternal_last_name varchar2(100);
       lv_name               varchar2(100);
       lv_IDW                varchar2(100);
       lv_worker_type        varchar2(100);
       lv_salary_type        varchar2(100);
       lv_rww                varchar2(100);
       lv_hire_date          varchar2(100);
       lv_sep_date           varchar2(100);
       lv_imss_waybill       varchar2(100);
       lv_leav_reason        varchar2(100);
       lv_flat_out           varchar2(300);
       lv_csvr_out           varchar2(300);
       lv_error_flag         varchar2(1);
       lv_error_mesg         varchar2(300);

    BEGIN

       lv_return_value       := '';
       lv_er_ss_id           := null ;
       lv_er_ss_chk_digit    := null ;
       lv_ee_ss_id           := null ;
       lv_ee_ss_chk_digit    := null ;
       lv_paternal_last_name := null ;
       lv_name               := null ;
       lv_IDW                := null ;
       lv_worker_type        := null ;
       lv_salary_type        := null ;
       lv_rww                := null ;
       lv_hire_date          := null ;
       lv_sep_date           := null ;
       lv_imss_waybill       := null ;
       lv_leav_reason        := null ;
       lv_flat_out           := null ;
       lv_csvr_out           := null ;

       lv_error_flag := 'N' ;
       lv_error_mesg := '' ;

       if p_affl_type ='HIRES' then -- Hires

          open c_hire_details(p_assignment_action_id) ;
          fetch c_hire_details into
           lv_er_ss_id,
           lv_er_ss_chk_digit,
           lv_ee_ss_id,
           lv_ee_ss_chk_digit,
           lv_paternal_last_name,
           lv_name,
           lv_IDW,
           lv_worker_type,
           lv_salary_type,
           lv_rww,
           lv_hire_date,
           lv_imss_waybill,
           lv_flat_out, lv_csvr_out ;

          if lv_er_ss_id is null or
             lv_er_ss_chk_digit is null or
             lv_ee_ss_id is null or
             lv_ee_ss_chk_digit is null or
             lv_name is null or
             (to_number(nvl(lv_idw,'0')) <= 0 ) or
             lv_worker_type is null or
             lv_salary_type is null or
             lv_rww is null or
             lv_hire_date is null or
             lv_imss_waybill is null then

             lv_error_flag := 'Y' ;
             lv_error_mesg := 'Error in DISPMAG record for Employee '||lv_paternal_last_name || ' - ' ;

             if lv_er_ss_id is null then
                lv_error_mesg := lv_error_mesg || 'Employer SS ID is Missing ' ;
                pay_core_utils.push_message(800,'HR_MX_INVALID_DISPMAG_DATA','F');
                pay_core_utils.push_token('RECORD_NAME','DISPMAG') ;
                pay_core_utils.push_token('NAME_OR_NUMBER',lv_paternal_last_name) ;
                pay_core_utils.push_token('DESCRIPTION','Employer SS ID is Missing') ;
             end if;

             if lv_er_ss_chk_digit is null then
                lv_error_mesg := lv_error_mesg || 'Employer SS Check Digit is Missing ' ;
                pay_core_utils.push_message(800,'HR_MX_INVALID_DISPMAG_DATA','F');
                pay_core_utils.push_token('RECORD_NAME','DISPMAG') ;
                pay_core_utils.push_token('NAME_OR_NUMBER',lv_paternal_last_name) ;
                pay_core_utils.push_token('DESCRIPTION','Employer SS Check Digit is Missing') ;
             end if;

             if lv_ee_ss_id is null then
                lv_error_mesg := lv_error_mesg || 'Employee SS ID is Missing ' ;
                pay_core_utils.push_message(800,'HR_MX_INVALID_DISPMAG_DATA','F');
                pay_core_utils.push_token('RECORD_NAME','DISPMAG') ;
                pay_core_utils.push_token('NAME_OR_NUMBER',lv_paternal_last_name) ;
                pay_core_utils.push_token('DESCRIPTION','Employee SS ID is Missing ') ;

             end if;

             if lv_ee_ss_chk_digit is null then
                lv_error_mesg := lv_error_mesg || 'Employee SS Check Digit is Missing ' ;
                pay_core_utils.push_message(800,'HR_MX_INVALID_DISPMAG_DATA','F');
                pay_core_utils.push_token('RECORD_NAME','DISPMAG') ;
                pay_core_utils.push_token('NAME_OR_NUMBER',lv_paternal_last_name) ;
                pay_core_utils.push_token('DESCRIPTION','Employee SS Check Digit is Missing') ;

             end if;


             if lv_name is null then
                lv_error_mesg := lv_error_mesg || 'First Name and/or Second Name is Missing ' ;
                pay_core_utils.push_message(800,'HR_MX_INVALID_DISPMAG_DATA','F');
                pay_core_utils.push_token('RECORD_NAME','DISPMAG') ;
                pay_core_utils.push_token('NAME_OR_NUMBER',lv_paternal_last_name) ;
                pay_core_utils.push_token('DESCRIPTION','First Name and/or Second Name is Missing ') ;

             end if;


             if to_number(nvl(lv_IDW,'0')) <= 0 then
                lv_error_mesg := lv_error_mesg || 'IDW must be greater than zero ' ;
                pay_core_utils.push_message(800,'HR_MX_INVALID_DISPMAG_DATA','F');
                pay_core_utils.push_token('RECORD_NAME','DISPMAG') ;
                pay_core_utils.push_token('NAME_OR_NUMBER',lv_paternal_last_name) ;
                pay_core_utils.push_token('DESCRIPTION','IDW must be greater than zero ') ;

             end if;

             if lv_worker_type is null then
                lv_error_mesg := lv_error_mesg || 'Worker Type is Missing ' ;
                pay_core_utils.push_message(800,'HR_MX_INVALID_DISPMAG_DATA','F');
                pay_core_utils.push_token('RECORD_NAME','DISPMAG') ;
                pay_core_utils.push_token('NAME_OR_NUMBER',lv_paternal_last_name) ;
                pay_core_utils.push_token('DESCRIPTION','Worker Type is Missing ') ;

             end if;


             if lv_salary_type is null then
                lv_error_mesg := lv_error_mesg || 'Salary Type is Missing ' ;
                pay_core_utils.push_message(800,'HR_MX_INVALID_DISPMAG_DATA','F');
                pay_core_utils.push_token('RECORD_NAME','DISPMAG') ;
                pay_core_utils.push_token('NAME_OR_NUMBER',lv_paternal_last_name) ;
                pay_core_utils.push_token('DESCRIPTION','Salary Type is Missing ') ;

             end if;

             if lv_rww is null then
                lv_error_mesg := lv_error_mesg || 'Reduced working week flag is Missing ' ;
                pay_core_utils.push_message(800,'HR_MX_INVALID_DISPMAG_DATA','F');
                pay_core_utils.push_token('RECORD_NAME','DISPMAG') ;
                pay_core_utils.push_token('NAME_OR_NUMBER',lv_paternal_last_name) ;
                pay_core_utils.push_token('DESCRIPTION','Reduced working week flag is Missing ') ;

             end if;

             if lv_hire_date is null then
                lv_error_mesg := lv_error_mesg || 'Hire date is Missing ' ;
                pay_core_utils.push_message(800,'HR_MX_INVALID_DISPMAG_DATA','F');
                pay_core_utils.push_token('RECORD_NAME','DISPMAG') ;
                pay_core_utils.push_token('NAME_OR_NUMBER',lv_paternal_last_name) ;
                pay_core_utils.push_token('DESCRIPTION','Hire date is Missing ') ;

             end if;

             if lv_imss_waybill is null then
                lv_error_mesg := lv_error_mesg || ' IMSS Waybill Number is Missing ' ;
                pay_core_utils.push_message(800,'HR_MX_INVALID_DISPMAG_DATA','F');
                pay_core_utils.push_token('RECORD_NAME','DISPMAG') ;
                pay_core_utils.push_token('NAME_OR_NUMBER',lv_paternal_last_name) ;
                pay_core_utils.push_token('DESCRIPTION',' IMSS Waybill Number is Missing ') ;

             end if;

          end if;
          close c_hire_details ;

       elsif p_affl_type ='SEPARATIONS' then  -- Separations

          open c_sep_details(p_assignment_action_id) ;

          fetch c_sep_details into
           lv_er_ss_id,
           lv_er_ss_chk_digit,
           lv_ee_ss_id,
           lv_ee_ss_chk_digit,
           lv_paternal_last_name,
           lv_name,
           lv_sep_date,
           lv_imss_waybill,
           lv_leav_reason,
           lv_flat_out, lv_csvr_out ;

          if lv_er_ss_id is null or
             lv_er_ss_chk_digit is null or
             lv_ee_ss_id is null or
             lv_ee_ss_chk_digit is null or
             lv_name is null or
             lv_sep_date is null or
             lv_imss_waybill is null or
             lv_leav_reason is null then

             lv_error_flag := 'Y' ;
             lv_error_mesg := 'Error in DISPMAG record for Employee '||lv_paternal_last_name || ' - ' ;

             if lv_er_ss_id is null then
                lv_error_mesg := lv_error_mesg || 'Employer SS ID is Missing ' ;
                pay_core_utils.push_message(800,'HR_MX_INVALID_DISPMAG_DATA','F');
                pay_core_utils.push_token('RECORD_NAME','DISPMAG') ;
                pay_core_utils.push_token('NAME_OR_NUMBER',lv_paternal_last_name) ;
                pay_core_utils.push_token('DESCRIPTION','Employer SS ID is Missing ') ;

             end if;

             if lv_er_ss_chk_digit is null then
                lv_error_mesg := lv_error_mesg || 'Employer SS Check Digit is Missing ' ;
                pay_core_utils.push_message(800,'HR_MX_INVALID_DISPMAG_DATA','F');
                pay_core_utils.push_token('RECORD_NAME','DISPMAG') ;
                pay_core_utils.push_token('NAME_OR_NUMBER',lv_paternal_last_name) ;
                pay_core_utils.push_token('DESCRIPTION','Employer SS Check Digit is Missing') ;

             end if;

             if lv_ee_ss_id is null then
                lv_error_mesg := lv_error_mesg || 'Employee SS ID is Missing ' ;
                pay_core_utils.push_message(800,'HR_MX_INVALID_DISPMAG_DATA','F');
                pay_core_utils.push_token('RECORD_NAME','DISPMAG') ;
                pay_core_utils.push_token('NAME_OR_NUMBER',lv_paternal_last_name) ;
                pay_core_utils.push_token('DESCRIPTION','Employee SS ID is Missing ') ;

             end if;

             if lv_ee_ss_chk_digit is null then
                lv_error_mesg := lv_error_mesg || 'Employee SS Check Digit is Missing ' ;
                pay_core_utils.push_message(800,'HR_MX_INVALID_DISPMAG_DATA','F');
                pay_core_utils.push_token('RECORD_NAME','DISPMAG') ;
                pay_core_utils.push_token('NAME_OR_NUMBER',lv_paternal_last_name) ;
                pay_core_utils.push_token('DESCRIPTION','Employee SS Check Digit is Missing ') ;

             end if;

             if lv_name is null then
                lv_error_mesg := lv_error_mesg || 'First Name and/or Second Name is Missing ' ;
                pay_core_utils.push_message(800,'HR_MX_INVALID_DISPMAG_DATA','F');
                pay_core_utils.push_token('RECORD_NAME','DISPMAG') ;
                pay_core_utils.push_token('NAME_OR_NUMBER',lv_paternal_last_name) ;
                pay_core_utils.push_token('DESCRIPTION','First Name and/or Second Name is Missing') ;

             end if;

             if lv_sep_date is null then
                lv_error_mesg := lv_error_mesg || 'Separation date is Missing ' ;
                pay_core_utils.push_message(800,'HR_MX_INVALID_DISPMAG_DATA','F');
                pay_core_utils.push_token('RECORD_NAME','DISPMAG') ;
                pay_core_utils.push_token('NAME_OR_NUMBER',lv_paternal_last_name) ;
                pay_core_utils.push_token('DESCRIPTION','Separation date is Missing ') ;

             end if;

             if lv_imss_waybill is null then
                lv_error_mesg := lv_error_mesg || ' IMSS Waybill Number is Missing ' ;
                pay_core_utils.push_message(800,'HR_MX_INVALID_DISPMAG_DATA','F');
                pay_core_utils.push_token('RECORD_NAME','DISPMAG') ;
                pay_core_utils.push_token('NAME_OR_NUMBER',lv_paternal_last_name) ;
                pay_core_utils.push_token('DESCRIPTION','IMSS Waybill Number is Missing') ;

             end if;

             if lv_leav_reason is null then
                lv_error_mesg := lv_error_mesg || ' Leaving Reason is Missing ' ;
                pay_core_utils.push_message(800,'HR_MX_INVALID_DISPMAG_DATA','F');
                pay_core_utils.push_token('RECORD_NAME','DISPMAG') ;
                pay_core_utils.push_token('NAME_OR_NUMBER',lv_paternal_last_name) ;
                pay_core_utils.push_token('DESCRIPTION',' Leaving Reason is Missing') ;
--              pay_core_utils.push_token('DESCRIPTION','(Assignment Action Id :'|| to_char(p_assignment_action_id)
--                                     ||') Leaving Reason is Missing') ;
             end if;

         end if;

         close c_sep_details ;


       elsif p_affl_type ='SALARY' then -- Salary

          open c_salary_details(p_assignment_action_id) ;
          fetch c_salary_details into
           lv_er_ss_id,
           lv_er_ss_chk_digit,
           lv_ee_ss_id,
           lv_ee_ss_chk_digit,
           lv_paternal_last_name,
           lv_name,
           lv_IDW,
           lv_worker_type,
           lv_salary_type,
           lv_rww,
           lv_hire_date,
           lv_imss_waybill,
           lv_flat_out, lv_csvr_out ;

          if lv_er_ss_id is null or
             lv_er_ss_chk_digit is null or
             lv_ee_ss_id is null or
             lv_ee_ss_chk_digit is null or
             lv_name is null or
             (to_number(nvl(lv_idw,'0')) <= 0 ) or
             lv_worker_type is null or
             lv_salary_type is null or
             lv_rww is null or
             lv_hire_date is null or
             lv_imss_waybill is null then

             lv_error_flag := 'Y' ;
             lv_error_mesg := 'Error in DISPMAG record for Employee '||lv_paternal_last_name || ' - ' ;

             if lv_er_ss_id is null then
                lv_error_mesg := lv_error_mesg || 'Employer SS ID is Missing ' ;
                pay_core_utils.push_message(800,'HR_MX_INVALID_DISPMAG_DATA','F');
                pay_core_utils.push_token('RECORD_NAME','DISPMAG') ;
                pay_core_utils.push_token('NAME_OR_NUMBER',lv_paternal_last_name) ;
                pay_core_utils.push_token('DESCRIPTION','Employer SS ID is Missing') ;
             end if;

             if lv_er_ss_chk_digit is null then
                lv_error_mesg := lv_error_mesg || 'Employer SS Check Digit is Missing ' ;
                pay_core_utils.push_message(800,'HR_MX_INVALID_DISPMAG_DATA','F');
                pay_core_utils.push_token('RECORD_NAME','DISPMAG') ;
                pay_core_utils.push_token('NAME_OR_NUMBER',lv_paternal_last_name) ;
                pay_core_utils.push_token('DESCRIPTION','Employer SS Check Digit is Missing') ;
             end if;

             if lv_ee_ss_id is null then
                lv_error_mesg := lv_error_mesg || 'Employee SS ID is Missing ' ;
                pay_core_utils.push_message(800,'HR_MX_INVALID_DISPMAG_DATA','F');
                pay_core_utils.push_token('RECORD_NAME','DISPMAG') ;
                pay_core_utils.push_token('NAME_OR_NUMBER',lv_paternal_last_name) ;
                pay_core_utils.push_token('DESCRIPTION','Employee SS ID is Missing ') ;

             end if;

             if lv_ee_ss_chk_digit is null then
                lv_error_mesg := lv_error_mesg || 'Employee SS Check Digit is Missing ' ;
                pay_core_utils.push_message(800,'HR_MX_INVALID_DISPMAG_DATA','F');
                pay_core_utils.push_token('RECORD_NAME','DISPMAG') ;
                pay_core_utils.push_token('NAME_OR_NUMBER',lv_paternal_last_name) ;
                pay_core_utils.push_token('DESCRIPTION','Employee SS Check Digit is Missing') ;

             end if;


             if lv_name is null then
                lv_error_mesg := lv_error_mesg || 'First Name and/or Second Name is Missing ' ;
                pay_core_utils.push_message(800,'HR_MX_INVALID_DISPMAG_DATA','F');
                pay_core_utils.push_token('RECORD_NAME','DISPMAG') ;
                pay_core_utils.push_token('NAME_OR_NUMBER',lv_paternal_last_name) ;
                pay_core_utils.push_token('DESCRIPTION','First Name and/or Second Name is Missing ') ;

             end if;


             if to_number(nvl(lv_IDW,'0')) <= 0 then
                lv_error_mesg := lv_error_mesg || 'IDW must be greater than zero ' ;
                pay_core_utils.push_message(800,'HR_MX_INVALID_DISPMAG_DATA','F');
                pay_core_utils.push_token('RECORD_NAME','DISPMAG') ;
                pay_core_utils.push_token('NAME_OR_NUMBER',lv_paternal_last_name) ;
                pay_core_utils.push_token('DESCRIPTION','IDW must be greater than zero ') ;
             end if;

             if lv_worker_type is null then
                lv_error_mesg := lv_error_mesg || 'Worker Type is Missing ' ;
                pay_core_utils.push_message(800,'HR_MX_INVALID_DISPMAG_DATA','F');
                pay_core_utils.push_token('RECORD_NAME','DISPMAG') ;
                pay_core_utils.push_token('NAME_OR_NUMBER',lv_paternal_last_name) ;
                pay_core_utils.push_token('DESCRIPTION','Worker Type is Missing ') ;

             end if;


             if lv_salary_type is null then
                lv_error_mesg := lv_error_mesg || 'Salary Type is Missing ' ;
                pay_core_utils.push_message(800,'HR_MX_INVALID_DISPMAG_DATA','F');
                pay_core_utils.push_token('RECORD_NAME','DISPMAG') ;
                pay_core_utils.push_token('NAME_OR_NUMBER',lv_paternal_last_name) ;
                pay_core_utils.push_token('DESCRIPTION','Salary Type is Missing ') ;

             end if;

             if lv_rww is null then
                lv_error_mesg := lv_error_mesg || 'Reduced working week flag is Missing ' ;
                pay_core_utils.push_message(800,'HR_MX_INVALID_DISPMAG_DATA','F');
                pay_core_utils.push_token('RECORD_NAME','DISPMAG') ;
                pay_core_utils.push_token('NAME_OR_NUMBER',lv_paternal_last_name) ;
                pay_core_utils.push_token('DESCRIPTION','Reduced working week flag is Missing ') ;

             end if;

             if lv_hire_date is null then
                lv_error_mesg := lv_error_mesg || 'Hire date is Missing ' ;
                pay_core_utils.push_message(800,'HR_MX_INVALID_DISPMAG_DATA','F');
                pay_core_utils.push_token('RECORD_NAME','DISPMAG') ;
                pay_core_utils.push_token('NAME_OR_NUMBER',lv_paternal_last_name) ;
                pay_core_utils.push_token('DESCRIPTION','Hire date is Missing ') ;

             end if;

             if lv_imss_waybill is null then
                lv_error_mesg := lv_error_mesg || ' IMSS Waybill Number is Missing ' ;
                pay_core_utils.push_message(800,'HR_MX_INVALID_DISPMAG_DATA','F');
                pay_core_utils.push_token('RECORD_NAME','DISPMAG') ;
                pay_core_utils.push_token('NAME_OR_NUMBER',lv_paternal_last_name) ;
                pay_core_utils.push_token('DESCRIPTION',' IMSS Waybill Number is Missing ') ;

             end if;

          end if;
          close c_salary_details ;

       end if;   --

       p_error_flag := lv_error_flag ;
       p_error_mesg := lv_error_mesg ;
       p_flat_out := lv_flat_out ;
       p_csvr_out := lv_csvr_out ;
       p_flat_ret_str_len := length(lv_flat_out) ;
       p_csvr_ret_str_len := length(lv_csvr_out) ;

       return lv_return_value ;

    END format_dispmag_emp_record ;

    /************************************************************
    Name      : format_dispmag_total_record
    Purpose   : This function formats and returns the dispmag
                total record.
                This function is called from the DISPMAG_SUBMITTER_TOTAL
                fast formula by passing the parameters
    Arguments : p_trans_gre            - Transmitter Gre Id parameter
                p_gre_id               - GRE Id parameter
                p_total_emps           - Total no of Employees parameter
                                         accumulated and passed from
                                         DISPMAG_EMPLOYEE fastformula
                p_flat_out             - Total record output in
                                         magnetic format
                p_csvr_out             - Total record output in
                                         csv format
                p_flat_ret_str_len     - string length of flat record out
                p_csvr_ret_str_len     - string length of csv  record out

    **************************************************************/
    FUNCTION format_dispmag_total_record(
                           p_trans_gre               in number,
                           p_gre_id                  in number,
                           p_total_emps              in number,
                           p_flat_out                out nocopy varchar2,
                           p_csvr_out                out nocopy varchar2,
                           p_flat_ret_str_len        out nocopy number,
                           p_csvr_ret_str_len        out nocopy number
    ) RETURN VARCHAR2
    IS

    -- Cursor to get the IMSS Waybill Number
    cursor c_get_org_information ( cp_organization_id in number)
    is
    select org_information5
    from hr_organization_information
    where org_information_context= 'MX_SOC_SEC_DETAILS'
    and organization_id = cp_organization_id ;


    lv_return_value varchar2(100);
    lv_total_f1     varchar2(100);
    lv_total_f2     varchar2(100);
    lv_total_f3     varchar2(100);
    lv_total_f4     varchar2(100);
    lv_total_f5     varchar2(100);
    lv_total_f6     varchar2(100);
    lv_total_f7     varchar2(1);
    lv_imss_waybill varchar2(5);
    lv_flat_out     varchar2(300);
    lv_csvr_out     varchar2(300);

    BEGIN

       lv_return_value := '';
       lv_imss_waybill := ' ' ;

       -- Get way bill number for the Transmitter GRE

       open c_get_org_information(p_trans_gre) ;
       fetch c_get_org_information into lv_imss_waybill ;
       close c_get_org_information ;

       lv_total_f1 := '*************' ;
       lv_total_f2 := rpad(' ',43,' ');
       lv_total_f3 := lpad(to_char(p_total_emps),6,'0');
       lv_total_f4 := rpad(' ',71,' ');
       lv_total_f5 := rpad(nvl(lv_imss_waybill,' '),5,' ');
       lv_total_f6 := rpad(' ',29,' ');
       lv_total_f7 := '9';

       lv_flat_out := lv_total_f1 ||     -- Asterisks
                      lv_total_f2 ||     -- Filler
                      lv_total_f3 ||     -- Total Number of Employees HIRE/SEPARATIONS
                      lv_total_f4 ||     -- Filler
                      lv_total_f5 ||     -- IMSS Waybill
                      lv_total_f6 ||     -- Filler
                      lv_total_f7 ;      -- Layout Identifier

       lv_csvr_out := format_data_string(lv_total_f1) ||
                      format_data_string(lv_total_f2) ||
                      format_data_string(lv_total_f3) ||
                      format_data_string(lv_total_f4) ||
                      format_data_string(lv_total_f5) ||
                      format_data_string(lv_total_f6) ||
                      format_data_string(lv_total_f7) ;

       p_flat_out := lv_flat_out ;
       p_csvr_out := lv_csvr_out ;
       p_flat_ret_str_len := length(lv_flat_out) ;
       p_csvr_ret_str_len := length(lv_csvr_out) ;

       return lv_return_value ;

   END format_dispmag_total_record ;


--begin
--hr_utility.trace_on (null, 'SSDISPMAG');

end per_mx_ssaffl_dispmag;

/
