--------------------------------------------------------
--  DDL for Package Body PAY_CA_YEER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_YEER_PKG" AS
/* $Header: pycayeer.pkb 120.18 2007/09/28 07:02:15 amigarg noship $ */
--
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1996 Oracle Corporation.                        *
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

    Name        : pay_ca_yeer_pkg

    Description : Package for the Elements Reports. The package
                  generated the output file in the specified user
                  format. The current formats supported are
                      - HTML
                      - CSV

    Change List
    -----------
     Date        Name      Vers    Bug No    Description
     ----        ----      ------  -------   -----------
     28-NOV-2000 vpandya   115.0             Created.
     06-MAR-2001 vpandya   115.1             CPP/EI Reason.
     26-MAR-2001 vpandya   115.2             Omit QPP from federal, print
                                             balance name for Neg.Bal.
     27-MAR-2001 vpandya   115.3             Replaced CPP/QPP Exempt with
                                             CPP/QPP Eligible Pay Periods.
     30-MAR-2001 vpandya   115.4             Added Multiple Jurisdiction Reason
                                             for Provincial and aligned code.
     02-APR-2001 vpandya   115.5             Added CPP/QPP Basic Exemption.
     04-APR-2001 vpandya   115.6             Removed CPP/QPP Basic Exemption,
                                             should print from the archiver.
     09-NOV-2001 vpandya   115.7             Added CPP/QPP Basic Exemption,
                                             now we use DBI for that.
     09-NOV-2001 vpandya   115.8             Changed cursor rl_tax_unit_id.
     10-NOV-2001 vpandya   115.9             Added set veify off at top.
     12-NOV-2001 vpandya   115.10            Added dbdrv line.
     12-DEC-2001 mmukherj  115.12            Taken out to_number from employee
                                             number, because employee number can
                                             be  alphanumeric
     10-AUG-2002 vpandya   115.16            Modified cursor cur_lkup, added
                                             condition language=userenv('LANG')
     10-AUG-2002 vpandya   115.17            Added OSERROR command at top
     15-DEC-2002 vpandya   115.18            Added nocopy with out parameter and
                                             bug 2718862, pick employee for CPP,
                                             QPP or EI deficiency only if it is
                                             negative and more than a dollar.
     20-DEC-2002 vpandya   115.19            Bug 2718862, new requirement.
                                             Print exceptions Employee Hired in
                                             this year, terminated in this year,
                                             turned 18 and 70 in this year only
                                             when there is a CPP/QPP/EI defici..
     29-AUG-2003 irgonzal  115.20  2406070   Changed format of employee name:
                                             <last>, <first>.
     13-NOV-2003 ssouresr  115.21            Passing PRE Organization Id to pier_yeer
                                             instead of quebec identification number
     19-DEC-2003 ssouresr  115.22            Exception Report first looks at RL1
                                             Amendment before it looks at the RL1
     30-DEC-2003 ssouresr  115.23            Exception Report first looks at T4
                                             Amendment before it looks at the T4
     31-DEC-2003 ssouresr  115.25            The PIER report should not display employees
                                             that have had a CPP/QPP or EI block in the
                                             year but do not have a deficiency in their
                                             CPP or EI deductions.
     01-JUL-2004 schauhan  115.26 3352591    Added Employee number in print_employee when report
					     type is T4A.
     19-NOV-2004 ssouresr  115.27            Overpayment for CPP/QPP/EI will not be reported
                                             anymore. Deficiency will be set to 0 in these cases
                                             Also Deficiencies will not be reported as negative
                                             anymore
     20-NOV-2004 ssouresr  115.28            QPP Exempt is now reported if it has been set and
                                             the provincial parameter has been selected
     22-NOV-2004 ssouresr  115.29            Added exists clauses to main cursors returning
                                             assignments to report
     28-NOV-2004 ssouresr  115.30            Changed 'Quebec Bn' to 'Quebec Identification Number'
     29-APR-2005 ssouresr  115.31            The Year End Exception Report now picks up T4A
                                             Amendment data too. Also made changes so that box
                                             names with negative balances are correctly displayed
     15-JUN-2005 ssouresr  115.32            Replaced hr_organization_units with hr_all_organization_units
                                             this allows correct output to be produced when a
                                             a secure user runs the report
     30-AUG-2005 ssattini  115.33  2689672   Modified prov_employer_validation,provincial_process
                                             prov_employee_validation and print_employee to print YEER
                                             report for RL2 PRE.
     31-AUG-2005 ssattini  115.34  3977930   Modified provincial_process,federal_process to add sort
                                             by last_name,first_name,middle_names.
     04-OCT-2005 ssouresr  115.35            Modified archive data cursors to reduce their cost
     08-NOV-2005 ssouresr  115.36            Commented out Youth Hire Program Indicator
                                             check
     09-NOV-2005 ssouresr  115.37            Added checks for fields that are mandatory
                                             for year end magnetic media
     22-DEC-2005 ssouresr  115.38            The exception report will now also detect negative
                                             T4A and RL1 non box footnotes.
     31-JUL-2006 ydevi     115.39            all monetary values are converted into number by using
                                             fnd_number.number_to_canonical function instead of to_number
					     function
					     The masking of the monetory values has been done using
					     pay_us_employee_payslip_web.get_format_value instead of
					     to_char.
     01-Aug-2006 ssmukher  115.40            Implementation of PPIP tax in the package.Also the
                                             use of diff EI rates (For Quebec and Non Quebec Employees).
                                             Modified the following procedures
					     1) fed_employee_validation, 2) prov_employee_validation,
					     3) print_employee.
     04-Sep-2006 ssmukher  115.41            Removed the reference of PPIP earnings from Federal
                                             processes.Modifiwed the print_employee procedure to remove
                                             all references of PPIP for Federal option.Also added a cursor
                                             get_jurisdiction_code in federal_process to fetch the jurisdiction
                                             for the employee based on which the EI_Rate will be applicable.
     15-Sep-2006 ssmukher  115.42  5531874   Modified the cursor get_jurisdiction_code to  use
                                             CAEOY_PROVINCE_OF_EMPLOYMENT instead of CAEOY_EMPLOYMENT_PROVINCE.
                                             Also modified the l_info_value variable size to NUMBER(12,3) in
                                             legi_info function.Also modified the sv_ppip_rate and sv_ei_ppip_rate
                                             variable size to NUMBER(12,3).
     21-Sep-2006 ssmukher  115.43  5531874   Modified the print_employee.
     29-NOV-2006 meshah    115.44  5552744   Modified initialize_static_var,
                                             print_employee and
                                             fed_employee_validation to distinguish
                                             between EI for Fed and QC.
     30-NOV-2006 meshah    115.45  5552744   missed backslash for nbsp.
     08-DEC-2006 meshah    115.46  5703506   modified the procedure federal_process.
                                             Added DISTINCT to cursor cur_asg_act.
     03-Jan-2007 ssmukher  115.47 5723058    Overloaded the function legi_info.
                                             Also modified the procedure
                                             pier_yeer to fetch the value for
                                             EI_RATE using the new overloaded
                                             legi_info function.
     24-Sep-2007 amigarg   115.48 6443068    Increased the variable size of sv_employee_name to 300
     28-Sep-2007 amigarg   115.49 6443068    put the substr in sv_Employee_name

*/

  /************************************************************
  ** Local Package Variables ( Static Variables )
  ************************************************************/
  gv_title               VARCHAR2(100) := ' Year End Exception report ';
  gc_csv_delimiter       VARCHAR2(1) := ',';
  gc_csv_data_delimiter  VARCHAR2(1) := '"';

  gv_html_start_data     VARCHAR2(5) := '<td>'  ;
  gv_html_end_data       VARCHAR2(5) := '</td>' ;

  gv_package_name        VARCHAR2(50) := 'pay_ca_yeer_pkg';

  sv_date                varchar2(20) := ' ';
  sv_page                number(4)    := 0;

  sv_reporting_year      varchar2(4) := ' ';   /* Reporting Year */
  sv_p_y                 varchar2(1) := ' ';   /* PIER or Exception Flag */
  sv_pier_yeer           varchar2(80) := ' ';  /* PIER or Exception Title */
  sv_f_p                 varchar2(1) := ' ';   /* Fed. or Prov. Flag */
  sv_fed_prov            varchar2(240) := ' ';  /* Fed. or Prov. Full name */
  sv_gre_name            varchar2(255) := ' '; /* GRE Name */
  sv_pre_name            varchar2(255) := ' '; /* PRE Name */
  sv_qin                 varchar2(16) := ' ';  /* Quebec Id. Number */
  sv_gre                 number(20)   := 0;    /* GRE - Tax Unit Id */
  sv_pre                 number(20)   := 0;    /* PRE - Organization Id */
  sv_b_g_id              number(20)   := 0;    /* Business Group Id */
  sv_print_line          number(2)    := 31;   /* Lines per page */
  sv_line                number(4)    := 0;    /* Counter for lines */
  sv_busi_no             varchar2(80) := ' ';  /* Business Number */
  sv_trans_y_n           char(1);              /* Trans. GRE or not flag */
  sv_report_type         varchar2(30) := ' ';  /* Archiver Report Type*/
  sv_context_id          number(9)    := 0;    /* Jurisdiction Context Id*/
  sv_asg_id              number(10)   := 0;    /* Assignment Id */

  sv_lkup      tab_dbi;     /* PL/SQL Lookup Table for Reasons and Title */
  sv_neg_bal   tab_dbi;     /* Database Items for Employee */
  sv_dbi       tab_dbi;     /* Database Items for Employee */
  sv_msg       tab_mesg;    /* Messages */
  sv_col       tab_col_name;/* Required Columns */
  sv_m         number(2);   /* Message Counter */
  sv_c         number(2);   /* Column Counter */
  sv_nb        number(2);   /* Negative Balance Counter */

/* CPP/QPP and EI Variables */

  sv_cpp_max_earn    number(12,2);
  sv_ei_max_earn     number(12,2);
  sv_cpp_max_exempt  number(12,2);
  sv_ei_max_exempt   number(12,2);
  sv_cpp_exempt      number(12,2);
  sv_cpp_rate        number(12,2);
  sv_ei_rate         number(12,2);

/* Added by ssmukher for PPIP tax */

  sv_ppip_rate         number(12,3);
  sv_ppip_ei_rate      number(12,3);
  sv_ppip_max_earn     number(12,2);
  sv_ppip_max_exempt   number(12,2);
  sv_jurisdiction      varchar2(5);

/* Employer Static Variables */

  sv_employer_name          varchar2(240);
  sv_employer_address_line1 varchar2(240);
  sv_employer_address_line2 varchar2(240);
  sv_employer_city          varchar2(240);
  sv_employer_province      varchar2(240);
  sv_employer_postal_code   varchar2(240);

/* Employee Static Variables */

  sv_person_id              varchar2(240);
  sv_no_of_cpp_periods      number(10);
  sv_date_of_birth          date;
  sv_hire_date              date;
  sv_terminate_date         date;
  sv_total_earnings         NUMBER;
  sv_pensionable_earnings   NUMBER;
  sv_ded_reported_16        NUMBER;
  sv_rl1_slip_no            varchar2(240);
  sv_insurable_earnings     NUMBER;
  sv_ded_reported_18        NUMBER;

/* bug 5552744 */
  sv_qc_insurable_earnings     NUMBER;
  sv_qc_ded_reported_18        NUMBER;
  sv_qc_ei_ded_required        number(12,2);
  sv_qc_ei_max_exempt          number(12,2);
  sv_qc_ei_deficiency          NUMBER;


/* Added by ssmukher for PPIP tax */
  sv_ppip_insurable_earnings NUMBER;
  sv_ded_reported_ppip      NUMBER;
  sv_ppip_ded_required      NUMBER;
  sv_ppip_deficiency        NUMBER;
  sv_ppip_block             varchar2(1);

  sv_cpp_qpp_deficiency     NUMBER;
  sv_ei_deficiency          NUMBER;
  sv_employee_name          varchar2(240);
  sv_employee_sin           varchar2(240);
  sv_employee_no            varchar2(240);
  sv_cpp_block              varchar2(1);
  sv_ei_block               varchar2(1);
  sv_cpp_ded_required       number(12,2);
  sv_ei_ded_required        number(12,2);
  sv_print                  number(1);
  sv_emp_jurisdiction       varchar2(30);
  sv_cpp_exempt_bal         number(12,2) := 0.00;
  sv_cpp_basic_exemption    number(12,2) := 0.00;

  /* Initialize static variables from different level
     lv_type = E   Employee Level, lv_type = R Employer level */

   /* RL2 Employer and Employee records */
   lr_rl2_transrec PAY_CA_EOY_RL2_TRANS_INFO_V%ROWTYPE;
   lr_rl2_emprec   PAY_CA_EOY_RL2_EMPLOYEE_INFO_V%ROWTYPE;

  procedure initialize_static_var ( lv_type in varchar2 ) is
  begin
   if lv_type = 'E' then
      sv_dbi.delete;
      sv_nb := 0;
      sv_col.delete;
      sv_c := 0;
      sv_msg.delete;
      sv_m := 0;
      sv_neg_bal.delete;
      sv_person_id              := null;
 --   sv_no_of_cpp_periods      := null;
      sv_date_of_birth          := null;
      sv_hire_date              := null;
      sv_terminate_date         := null;
      sv_total_earnings         := 0;
      sv_pensionable_earnings   := 0;
      sv_ded_reported_16        := 0;
      sv_rl1_slip_no            := null;
      sv_insurable_earnings     := 0;
      sv_ded_reported_18        := 0;
      sv_ded_reported_ppip      := 0;
      sv_ppip_insurable_earnings  := 0;
      sv_cpp_qpp_deficiency     := 0;
      sv_ei_deficiency          := 0;
      sv_ppip_deficiency        := 0;
      sv_employee_name          := null;
      sv_employee_sin           := null;
      sv_cpp_block              := null;
      sv_ei_block               := null;
      sv_ppip_block             := null;
      sv_cpp_ded_required       := 0;
      sv_ei_ded_required        := 0;
      sv_ppip_ded_required      := 0;
      sv_print                  := 0;
      sv_cpp_exempt_bal         := 0;
      sv_cpp_basic_exemption    := 0;

/* bug 5552744 */
      sv_qc_insurable_earnings  := 0;
      sv_qc_ded_reported_18     := 0;
      sv_qc_ei_deficiency       := 0;
      sv_qc_ei_ded_required     := 0;
/* bug 5552744 */

   elsif lv_type = 'R' then
      sv_c := 0;
      sv_m := 0;
      sv_dbi.delete;
      sv_col.delete;
      sv_msg.delete;
      sv_employer_name           := null;
      sv_employer_address_line1  := null;
      sv_employer_address_line2  := null;
      sv_employer_city           := null;
      sv_employer_province       := null;
      sv_employer_postal_code    := null;
   end if;
  end initialize_static_var;

   /* The cursor Cur_multi_juris is used to verify whether an employee worked
      in miltiple jurisdiction during the ewporting year */

  function  get_multi_jd ( p_person_id  in number )
  return number is
  l_multi_jd number := 0;
  begin

       select count( distinct lkp.meaning )
       into   l_multi_jd
       from   PER_ALL_ASSIGNMENTS_F paf,
              HR_LOCATIONS_ALL      hrl,
              HR_LOOKUPS            lkp
       where  paf.person_id = p_person_id
       and    sv_reporting_year between
              to_char(paf.effective_start_date,'YYYY') and
              to_char(paf.effective_end_date,'YYYY')
       and    paf.location_id   = hrl.location_id
       and    lkp.lookup_code   = hrl.region_1
       and    lkp.lookup_type   = 'CA_PROVINCE';

   return(l_multi_jd);

  end;

  /*
   The function get_bal_name is used to print balance name (for
   boxes with negative balance).
  */

  function  get_bal_name ( p_bal_name in varchar2 )
  return varchar2 is
  l_bal_name varchar2(240) := ' ';
  cp_bal_name varchar2(240) := ' ';
  begin
   if instr(upper(p_bal_name),'BOX') > 0 then
       cp_bal_name := sv_report_type || '_' || p_bal_name;
   else
       cp_bal_name := p_bal_name;
   end if;

   select   replace(replace(replace(replace(tl.balance_name,'T4A'),
            'T4'), 'RL1' ), '_' )
   into  l_bal_name
   from  pay_balance_types bal, pay_balance_types_tl tl
   where upper(bal.balance_name) = upper(cp_bal_name)
   and   tl.balance_type_id      = bal.balance_type_id
   and   tl.language             = userenv('LANG');

   return(l_bal_name);

   exception
   when others then
   return(l_bal_name);
  end get_bal_name;

  /*
   This legi_info function is returning the information value based on
   information type (p_info_type) for the reporting year.
   Type, CPP_MAXIMUM, CPP_RATE, CPP_EXEMPT, EI_MAXIMUM and EI_RATE
  */

  function  legi_info ( p_info_type in varchar2 )
  return number is
  l_info_value number(12,3) := 0;
  begin
   select information_value
   into   l_info_value
   from   pay_ca_legislation_info
   where  information_type = p_info_type
   and    jurisdiction_code is NULL
   and    sv_reporting_year between to_char(start_date,'YYYY')
                            and     to_char(end_date,'YYYY');

   return(l_info_value);

   exception
   when others then
   return(0.00);
  end legi_info;

/*
   This legi_info function is returning the information value based on
   information type (p_info_type) and jurisdiction code for the
   reporting year.   Type EI_RATE
  */
  function  legi_info ( p_info_type in varchar2,
                        p_jurisdiction in varchar2)
  return number is
  l_info_value number(12,3) := 0;
  begin
   select information_value
   into   l_info_value
   from   pay_ca_legislation_info
   where  information_type = p_info_type
   and    jurisdiction_code = p_jurisdiction
   and    sv_reporting_year between to_char(start_date,'YYYY')
                            and     to_char(end_date,'YYYY');

   return(l_info_value);

   exception
   when others then
   return(0.00);
  end legi_info;
  /* The procedure format_data writes the value in file */

  procedure format_data ( lv_format in varchar2 ) is
  begin
   --sv_line := sv_line + 1;
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, lv_format);
  end format_data;

  /* The function get_lookup_meaning returns values of exceptions
     and labels, this is used for translation purpose. */

  FUNCTION get_lookup_meaning( fp_lookup_code in varchar2 )
  RETURN VARCHAR2
  IS
     lv_meaning varchar2(240);
  begin
   for i in sv_lkup.first..sv_lkup.last
        loop
      if sv_lkup(i).dbi_name = fp_lookup_code then
         lv_meaning := sv_lkup(i).dbi_value;
         exit;
      end if;
   end loop;
hr_utility.set_location(fp_lookup_code||'   '||lv_meaning, 1111 );
        return(lv_meaning);
  end get_lookup_meaning;

  /* The function print_spaces returns spaces to print spaces in the file */

  FUNCTION print_spaces( p_no_of_spaces in number )
  RETURN VARCHAR2
  IS
     l_space varchar2(25) := '&nbsp';
     l_no_of_spaces varchar2(32000);
  begin
   for i in 1..p_no_of_spaces
        loop
      l_no_of_spaces := l_no_of_spaces || l_space;
        end loop;
        return(l_no_of_spaces);
  end print_spaces;

  /* The function new_page is used to print blank lines if the pagesize is
     fixed with no. of lines e.g 31 lines per page.
     set two variables  1. sv_print_line ( total no. of line per page )
     2. sv_line ( add one to it when a line print to file )
  */

  FUNCTION new_page
  RETURN VARCHAR2
  IS
     l_add_row varchar2(25) := '<tr><td>&nbsp</td></tr>';
     l_blank_rows varchar2(2000);
  begin
   for i in 1..sv_print_line - sv_line
        loop
      l_blank_rows := l_blank_rows || l_add_row;
        end loop;
        return(l_blank_rows);
  end;

  /* The function print_line forms a line with entered character
     and width of line */

  FUNCTION print_line
             (p_print     in varchar2
             ,p_number    in number
             )
  RETURN VARCHAR2
  IS
  l_line varchar2(200);
  begin
   for i in 1..p_number
   loop
      l_line := l_line || p_print;
   end loop;
   return(l_line);
  end;

  /* The procedure employee_header prints the header of Employee Exceptions */

  procedure employee_header is
  lv_format    varchar2(32000);
  begin
      lv_format := '<table border=0><tr><td></td><td><HEAD> <CENTER>  <B>' ||
                   sv_pier_yeer || '</B></CENTER></HEAD></td>';
      lv_format := lv_format || '<td align="left">' ||
                   get_lookup_meaning('L_DATE') || sv_date || '</td></tr>';
      format_data(lv_format);

      sv_page := sv_page + 1;
      lv_format := '<tr><td></td>';
      if ( sv_p_y = 'E' ) then
         lv_format := lv_format || '<td align="center"><B>'||
                      get_lookup_meaning('L_EMPL_EXCEPTION')||
                      '</B></td></tr><tr></tr>';
      else
         lv_format := lv_format ||
                      '<td align="center">&nbsp</B></td></tr><tr></tr>';
      end if;
      format_data(lv_format);

      lv_format := '<tr><td align="left"><B>';
      if ( sv_f_p = 'F' ) then
         lv_format := lv_format || get_lookup_meaning('L_GRE_NAME')||
                      sv_gre_name|| '</B></td><td align="left"><B>'||
                      get_lookup_meaning('L_BUSI_NO')||sv_busi_no;
      else
         lv_format := lv_format || get_lookup_meaning('L_PRE_NAME')||
                      sv_pre_name || '</B></td><td align="left"><B>'||
                      get_lookup_meaning('L_QCIDNO')||sv_qin;
      end if;

      lv_format := lv_format || '</B></td><td align="left"><B>' ||
                   get_lookup_meaning('L_REPORTING_YEAR')||sv_reporting_year||
                   '</B></td></tr>';
      format_data(lv_format);

      lv_format := '<tr><td>'|| print_line('-',50)|| '</td><td>'||
                   print_line('-',52)||
                   '</td><td>'|| print_line('-',50)|| '</td></tr>';
      format_data(lv_format);

      lv_format := '</table>';
      format_data(lv_format);

      lv_format := '<table border=0>';
      format_data(lv_format);

      sv_line := 8;

  end employee_header;

  /* The procedure employer_header prints the header of Employer Exceptions */

  procedure employer_header is
  lv_format    varchar2(32000);
  begin
      lv_format := '<table border=0><tr><td></td><td><HEAD> <CENTER>  <B>' ||
                   sv_pier_yeer || '</B></CENTER></HEAD></td>'||
                   '<td align="left">' || get_lookup_meaning('L_DATE')||
                   sv_date || '</td></tr>';
      format_data(lv_format);

      lv_format := '<tr><td></td><td align="center"><B>'||
                   get_lookup_meaning('L_EMPR_EXCEPTION')||'</B></td></tr>';
      format_data(lv_format);

      lv_format := '<tr><td>' || print_line('-',50)|| '</td><td>'||
                   print_line('-',52)|| '</td><td>'|| print_line('-',50)||
                   '</tr>'|| '</table>';
      format_data(lv_format);

      lv_format := '<table border=0><tr>'||
                   '<td align="left"><B>'||get_lookup_meaning('L_EMPR_NAME')||
                   '</B></td>';
      format_data(lv_format);

      if ( sv_f_p = 'F' ) then
         lv_format := '<td align="left" colspan=2><B>' ||
                      get_lookup_meaning('L_BUSINESS_NO') || '</B></td>';
      else
         lv_format := '<td align="left" colspan=2><B>' ||
                      get_lookup_meaning('L_QCID_NUMBER') || '</B></td>';
      end if;
      format_data(lv_format);

      lv_format := '<td align="left"><B>' ||
                   get_lookup_meaning('L_REPORTING_YR') || '</B></td>';
      format_data(lv_format);

      if sv_f_p = 'F' then
         lv_format := '<td align="left"><B>' ||
                      get_lookup_meaning('L_TR_GRE') || '</B></td>';
      else
         lv_format := '<td align="left"><B>' || get_lookup_meaning('L_TR_PRE')
                      || '</B></td>';
      end if;
      lv_format := lv_format || '</tr>';
      format_data(lv_format);

      lv_format := '<tr><td>' || print_line('-',80)|| '</td><td>'||
                   print_line('-',20)|| '</td><td>'|| print_line('-',20)||
                   '</td><td>'|| print_line('-',10)||
                   '</td><td>'|| print_line('-',20)|| '</td></tr>';
      format_data(lv_format);

      sv_line := 5;

  end employer_header;

  /* The procedure print_employee is used to print Employee Exception data
     for T4, T4A and RL1. */

  procedure print_employee is
  lv_format    varchar2(32000);
  lv_req_flds  varchar2(32000);
  l_sort_neg   tab_dbi;
  l_juris_cd   varchar2(240);
  l_juris_cd1  varchar2(240);
  i            number(3);
  l            number(3);
  begin

   if ((sv_report_type = 'T4A') or
       (sv_report_type = 'CAEOY_T4A_AMEND_PP')) then

     lv_format :=  '<tr><td align="right"><B>'||get_lookup_meaning('L_EMPL_NAME')    -- Bug 3352591-Added Employee
                ||'</B></td>'|| '<td align="left" colspan=3>'||sv_employee_name    -- number when report type = T4A.
                ||'</td><td align="right"><B>'||get_lookup_meaning('L_EMP_NO')
                ||'</B></td><td align="right">'||sv_employee_no||'</td></tr>';
     format_data(lv_format);

     lv_format :=  '<tr><td align="right"><B>'||get_lookup_meaning('L_SIN')||
                 '</B></td>'|| '<td align="left">'||sv_employee_sin||'</td>'||
                 '<td align="right"><B>'||get_lookup_meaning('L_DOB')||
                 '</B></td>'|| '<td align="left">'||sv_date_of_birth||
                 '</td></tr>';
     format_data(lv_format);

     lv_format :=  '<tr><td align="right"><B>'||get_lookup_meaning('L_DATE_HIRE')
                ||'</B></td>'|| '<td align="left">'||sv_hire_date||'</td>'||
                 '<td align="right"><B>'||
                get_lookup_meaning('L_DATE_TERMINATION')||'</B></td>'||
                '<td align="left">'||sv_terminate_date||'</td></tr>';
     format_data(lv_format);

     /*
      elsif ( sv_m = 0 and
            to_number(sv_cpp_qpp_deficiency,'999,999,990.00') = 0.00 and
            to_number(sv_ei_deficiency,'999,999,990.00') = 0.00 ) then

     lv_format :=  '<tr><td align="right"><B>'||get_lookup_meaning('L_EMPL_NAME')
                ||'</B></td>'|| '<td align="left" colspan=3>'||sv_employee_name
                ||'</td>' || '<td align="right"><B>'||
                get_lookup_meaning('L_SIN')||'</B></td>'||
                '<td align="left">'||sv_employee_sin||'</td></tr>';
     format_data(lv_format);
    */

   -- RL2 Employee Print
   elsif (sv_report_type = 'RL2') then

     lv_format :=  '<tr><td align="right"><B>'||get_lookup_meaning('L_EMPL_NAME')    -- Bug 3352591-Added Employee
                ||'</B></td>'|| '<td align="left" colspan=3>'||sv_employee_name    -- number when report type = T4A.
                ||'</td><td align="right"><B>'||get_lookup_meaning('L_EMP_NO')
                ||'</B></td><td align="right">'||sv_employee_no||'</td></tr>';
     format_data(lv_format);

     lv_format :=  '<tr><td align="right"><B>'||get_lookup_meaning('L_SIN')||
                 '</B></td>'|| '<td align="left">'||sv_employee_sin||'</td>'||
                 '<td align="right"><B>'||get_lookup_meaning('L_DOB')||
                 '</B></td>'|| '<td align="left">'||sv_date_of_birth||
                 '</td></tr>';
     format_data(lv_format);

     lv_format :=  '<tr><td align="right"><B>'||get_lookup_meaning('L_DATE_HIRE')
                ||'</B></td>'|| '<td align="left">'||sv_hire_date||'</td>'||
                 '<td align="right"><B>'||
                get_lookup_meaning('L_DATE_TERMINATION')||'</B></td>'||
                '<td align="left">'||sv_terminate_date||'</td></tr>';
     format_data(lv_format);

     lv_format :=  '<tr><td align="right"><B>'||
                    get_lookup_meaning('L_RL2_SLIP_NO')||'</B></td>'||
                    '<td align="left">'||
                    sv_rl1_slip_no ||'</td>'||
                    '<td>&nbsp</td>'|| '<td>&nbsp</td></tr>';

     format_data(lv_format);

   else
     lv_format :=  '<tr><td align="right"><B>'||get_lookup_meaning('L_EMPL_NAME')
                ||'</B></td>'|| '<td align="left" colspan=3>'||sv_employee_name
                ||'</td><td align="right"><B>'||get_lookup_meaning('L_EMP_NO')
                ||'</B></td><td align="right">'||sv_employee_no||'</td></tr>';
     format_data(lv_format);

     lv_format :=  '<tr><td align="right"><B>'||get_lookup_meaning('L_SIN')||
                 '</B></td>'|| '<td align="left">'||sv_employee_sin||'</td>'||
                 '<td align="right"><B>'||get_lookup_meaning('L_TOT_EARN')||
                 '</B></td>'|| '<td align="right">'
		 ||pay_us_employee_payslip_web.get_format_value(sv_b_g_id,sv_total_earnings)||'</td>'
                 || '<td align="right">&nbsp</td>'|| '<td>&nbsp</td></tr>';
     format_data(lv_format);

     lv_format :=  '<tr><td align="right"><B>'||get_lookup_meaning('L_DOB')||
                 '</B></td>'|| '<td align="left">'||sv_date_of_birth||'</td>';
     if sv_f_p = 'F' then
       lv_format :=  lv_format ||
                 '<td align="right"><B>'||get_lookup_meaning('L_CPP_PENS_EARN')
                 ||'</B></td>'|| '<td align="right">'
		 ||pay_us_employee_payslip_web.get_format_value(sv_b_g_id,sv_pensionable_earnings)
                 ||'</td>';

     else
       lv_format :=  lv_format ||
                 '<td align="right"><B>'||get_lookup_meaning('L_QPP_PENS_EARN')
                ||'</B></td>'|| '<td align="right">'
		||pay_us_employee_payslip_web.get_format_value(sv_b_g_id,sv_pensionable_earnings)||
                '</td>';
     end if;

     if ( sv_f_p = 'F' ) then
       lv_format :=  lv_format || '<td align="right"><B>'||
                     get_lookup_meaning('L_INS_EARN')||'</B></td>'||
                     '<td align="right">'||
		     pay_us_employee_payslip_web.get_format_value(sv_b_g_id,sv_insurable_earnings)||'</td></tr>';
     else
            lv_format := lv_format || '<td align="right"><B>'||
                     get_lookup_meaning('L_PPIP_INSEARN')||'</B></td>'||
                     '<td align="right">'||
		     pay_us_employee_payslip_web.get_format_value(sv_b_g_id,sv_ppip_insurable_earnings)||'</td></tr>';
     end if;
     format_data(lv_format);

     lv_format :=  '<tr><td align="right"><B>'||
                 get_lookup_meaning('L_DATE_HIRE')||'</B></td>'||
                 '<td align="left">'||sv_hire_date||'</td>';

     if sv_f_p = 'F' then
      lv_format := lv_format || '<td align="right"><B>'||
                   get_lookup_meaning('L_CPP_REPORTED')||'</B></td>'||
                   '<td align="right">'
		   ||pay_us_employee_payslip_web.get_format_value(sv_b_g_id,sv_ded_reported_16)||'</td>'||
                   '<td align="right"><B>'||get_lookup_meaning('L_EI_REPORTED')
                   ||'</B></td>'|| '<td align="right">'
		   ||pay_us_employee_payslip_web.get_format_value(sv_b_g_id,sv_ded_reported_18)||'</td></tr>';
     else
      lv_format := lv_format || '<td align="right"><B>'||
                   get_lookup_meaning('L_QPP_REPORTED')||'</B></td>'||
                   '<td align="right">'||
		   pay_us_employee_payslip_web.get_format_value(sv_b_g_id,sv_ded_reported_16)||'</td>'||
                   '<td align="right"><B>'||get_lookup_meaning('L_PPIP_REPORTED')
                   ||'</B></td>'|| '<td align="right" >'
		   ||pay_us_employee_payslip_web.get_format_value(sv_b_g_id,sv_ded_reported_ppip)||
                   '</td></tr>';
     end if;
     format_data(lv_format);

     lv_format :=  '<tr><td align="right"><B>'||
                 get_lookup_meaning('L_DATE_TERMINATION')||'</B></td>'||
                '<td align="left">'||sv_terminate_date||'</td>';

     if sv_f_p = 'F' then
      lv_format := lv_format || '<td align="right"><B>'||
                   get_lookup_meaning('L_CPP_REQUIRED')||'</B></td>'||
                   '<td align="right">'||
                   pay_us_employee_payslip_web.get_format_value(sv_b_g_id,sv_cpp_ded_required)||'</td>'||
                   '<td align="right"><B>'||get_lookup_meaning('L_EI_REQUIRED')
                   ||'</B></td>'|| '<td align="right">'||
                   pay_us_employee_payslip_web.get_format_value(sv_b_g_id,sv_ei_ded_required)||'</td></tr>';
     else
      lv_format := lv_format || '<td align="right"><B>'||
                   get_lookup_meaning('L_QPP_REQUIRED')||'</B></td>'||
                   '<td align="right">'||
                   pay_us_employee_payslip_web.get_format_value(sv_b_g_id,sv_cpp_ded_required)||'</td>'||
                   '<td align="right"><B>'||get_lookup_meaning('L_PPIP_REQUIRED')
                   ||'</B></td>'|| '<td align="right" >'||
                   pay_us_employee_payslip_web.get_format_value(sv_b_g_id,sv_ppip_ded_required)||
                   '</td></tr>';
     end if;
     format_data(lv_format);

     if sv_f_p = 'F' then
      lv_format := '<tr><td align="right"><B>'||
                   '&nbsp' ||'</B></td>'||
                   '<td align="right">'||
                   '&nbsp'||'</td>'||
                   '<td align="right"><B>'||
                   get_lookup_meaning('L_CPP_DEFICIENCY')||'</B></td>'||
                   '<td align="right">'||
		   pay_us_employee_payslip_web.get_format_value(sv_b_g_id,sv_cpp_qpp_deficiency)||'</td>'||
                   '<td align="right"><B>'||
                   get_lookup_meaning('L_EI_DEFICIENCY')||'</B></td>'||
                   '<td align="right">'||
		   pay_us_employee_payslip_web.get_format_value(sv_b_g_id,sv_ei_deficiency)||'</td></tr>';
               --'<td align="left">'||sv_no_of_cpp_periods||'</td>'||
     else
      lv_format :=  '<tr><td align="right"><B>'||
                    get_lookup_meaning('L_RL_SLIP_NO')||'</B></td>'||
                    '<td align="left">'||
                    sv_rl1_slip_no ||'</td>'||
                    '<td align="right"><B>'||
                    get_lookup_meaning('L_QPP_DEFICIENCY')||'</B></td>'||
                    '<td align="right">'||
                    pay_us_employee_payslip_web.get_format_value(sv_b_g_id,sv_cpp_qpp_deficiency)||'</td>'||
		    '<td align="right"><B>'||
                   get_lookup_meaning('L_PPIP_DEFICIENCY')||'</B></td>'||
                   '<td align="right">'||
		   pay_us_employee_payslip_web.get_format_value(sv_b_g_id,sv_ppip_deficiency)||
		   '</td></tr>';
               --'<td align="left">'||sv_no_of_cpp_periods||'</td>'||
     end if;
     format_data(lv_format);

     if sv_f_p = 'F' then
      lv_format :=  '<tr><td align="right"><B>'||
                   get_lookup_meaning('L_CPP_BASIC_EXEMPT')||'</B></td>'||
                   '<td align="right">'||
               pay_us_employee_payslip_web.get_format_value(sv_b_g_id,sv_cpp_basic_exemption)||'</td>'||
                    '<td align="right"><B>'||
                   get_lookup_meaning('L_CPP_EXEMPT')||'</B></td>'||
                   '<td align="right">'||
               pay_us_employee_payslip_web.get_format_value(sv_b_g_id,sv_cpp_exempt_bal)||'</td>'||
/* bug 5552744 */
               /* QC Insurable Earning */
                   '<td align="right"><B>'||
                   get_lookup_meaning('L_INS_EARN')||' (QC)'||'</B></td>'||
                   '<td align="right">'||
    		   pay_us_employee_payslip_web.get_format_value(sv_b_g_id,sv_qc_insurable_earnings)||'</td></tr>'||
               /* QC EI Reported */
    		   '<tr><td align="right"><B>'||
                   '&nbsp' ||'</B></td>'||
                   '<td align="right">'||
                   '&nbsp'||'</td>'||
                   '<td align="right"><B>'||
                   '&nbsp' ||'</B></td>'||
                   '<td align="right">'||
                   '&nbsp'||'</td>'||
                   '<td align="right"><B>'||
                   get_lookup_meaning('L_EI_REPORTED')||' (QC)'||'</B></td>'||
                   '<td align="right">'||
         		   pay_us_employee_payslip_web.get_format_value(sv_b_g_id,sv_qc_ded_reported_18)||'</td></tr>'||
               /* QC EI Required */
    		   '<tr><td align="right"><B>'||
                   '&nbsp' ||'</B></td>'||
                   '<td align="right">'||
                   '&nbsp'||'</td>'||
                   '<td align="right"><B>'||
                   '&nbsp' ||'</B></td>'||
                   '<td align="right">'||
                   '&nbsp'||'</td>'||
                   '<td align="right"><B>'||
                   get_lookup_meaning('L_EI_REQUIRED')||' (QC)'||'</B></td>'||
                   '<td align="right">'||
         		   pay_us_employee_payslip_web.get_format_value(sv_b_g_id,sv_qc_ei_ded_required)||'</td></tr>'||
               /* QC EI Deficiency */
    		   '<tr><td align="right"><B>'||
                   '&nbsp' ||'</B></td>'||
                   '<td align="right">'||
                   '&nbsp'||'</td>'||
                   '<td align="right"><B>'||
                   '&nbsp' ||'</B></td>'||
                   '<td align="right">'||
                   '&nbsp'||'</td>'||
                   '<td align="right"><B>'||
                   get_lookup_meaning('L_EI_DEFICIENCY')||' (QC)'||'</B></td>'||
                   '<td align="right">'||
         		   pay_us_employee_payslip_web.get_format_value(sv_b_g_id,sv_qc_ei_deficiency)||'</td></tr>';

     else
      lv_format :=  '<tr><td align="right"><B>'||
                   get_lookup_meaning('L_QPP_BASIC_EXEMPT')||'</B></td>'||
                   '<td align="right">'||
               pay_us_employee_payslip_web.get_format_value(sv_b_g_id,sv_cpp_basic_exemption)||'</td>'||
                    '<td align="right"><B>'||
                   get_lookup_meaning('L_QPP_EXEMPT')||'</B></td>'||
                   '<td align="right">'||
               pay_us_employee_payslip_web.get_format_value(sv_b_g_id,sv_cpp_exempt_bal)||'</td></tr>';
     end if;
     format_data(lv_format);

   end if;  -- End of sv_report_type = 'T4A'

   if sv_nb > 0 then
      lv_format :=  '<tr><td align=right>&nbsp</td></tr>';
      format_data(lv_format);
      lv_format := null;
      lv_req_flds := null;

     /* The below logic introduce to sort negative balance jurisdictionwise
        and print only for T4. For T4A and RL1 control will go to else part. */

      if ((sv_report_type = 'T4') or
          (sv_report_type = 'CAEOY_T4_AMEND_PP')) then

         lv_format :=  '<tr><td align=right><B>'||
                       get_lookup_meaning('R_NEG_BOX')||'</B></td></tr>';
        format_data(lv_format);

        while sv_neg_bal.count > 0
        loop

           hr_utility.set_location(to_char(sv_neg_bal.count),888);
           i := 0;
           l := 0;
           l_juris_cd := sv_neg_bal(1).dbi_name;

           for k in sv_neg_bal.first..sv_neg_bal.last
           loop

              l_juris_cd1 := sv_neg_bal(k).dbi_name;
              hr_utility.set_location('K = '||to_char(k),888);
              hr_utility.set_location('JURI = *'||sv_neg_bal(k).dbi_name||'*',888);

              if l_juris_cd1 = l_juris_cd then
                 i := i + 1;

                 hr_utility.set_location('I = '||to_char(i),888);

                 if mod(i,5) = 1 then
                     if i = 1 then
                          lv_format :=  '<tr><td align=right><B>'||
                          l_juris_cd ||'</B></td>';
                     else
                          lv_format :=  '<tr><td align=right>&nbsp</td>';
                     end if;
                     lv_req_flds :=   '<tr><td align=right>&nbsp</td>';
                     lv_format := lv_format || '<td align="right"><B>'||
                     --get_bal_name(sv_neg_bal(k).dbi_short_name)||'</B></td>';
                     sv_neg_bal(k).dbi_short_name||'</B></td>';
                     lv_req_flds := lv_req_flds || '<td align="right">'||
                     sv_neg_bal(k).dbi_value||'</td>';
                 elsif mod(i,5) = 0 then
                     lv_format := lv_format || '<td align="right"><B>'||
                                  --get_bal_name(sv_neg_bal(k).dbi_short_name)||
                                  sv_neg_bal(k).dbi_short_name||
                                  '</B></td></tr>';
                     lv_req_flds := lv_req_flds || '<td align="right">'||
                                    sv_neg_bal(k).dbi_value||'</td></tr>';
                     format_data(lv_format);
                     format_data(lv_req_flds);
                     lv_format := null;
                     lv_req_flds := null;
                 else
                     lv_format := lv_format || '<td align="right"><B>'||
                        --get_bal_name(sv_neg_bal(k).dbi_short_name)||'</B></td>';
                        sv_neg_bal(k).dbi_short_name||'</B></td>';
                     lv_req_flds := lv_req_flds || '<td align="right">'||
                        sv_neg_bal(k).dbi_value||'</td>';
                 end if;
             else
                l := l + 1;
                hr_utility.set_location('L = '||to_char(l),888);
                l_sort_neg(l).dbi_name       := sv_neg_bal(k).dbi_name;
                l_sort_neg(l).dbi_value      := sv_neg_bal(k).dbi_value;
                l_sort_neg(l).dbi_short_name := sv_neg_bal(k).dbi_short_name;
             end if;
           end loop;

          lv_format := rtrim(ltrim(lv_format));
          lv_req_flds := rtrim(ltrim(lv_req_flds));

          if mod(i,5) <> 0 then
                   lv_format := lv_format ||'</tr>';
                   lv_req_flds := lv_req_flds ||'</tr>';
                   format_data(lv_format);
                   format_data(lv_req_flds);
                   lv_format := null;
                   lv_req_flds := null;
          end if;

          sv_neg_bal.delete;

          if l_sort_neg.first is not null then

            for k in l_sort_neg.first..l_sort_neg.last
            loop
              sv_neg_bal(k).dbi_name       := l_sort_neg(k).dbi_name;
              sv_neg_bal(k).dbi_value      := l_sort_neg(k).dbi_value;
              sv_neg_bal(k).dbi_short_name := l_sort_neg(k).dbi_short_name;
            end loop;

            l_sort_neg.delete;

          end if;


        end loop;
     else

   for i in 1..sv_nb loop

      hr_utility.set_location(to_char(mod(i,5)),888);

      if mod(i,5) = 1 then
         if i = 1 then
            lv_format :=  '<tr><td align=right><B>'||
                          get_lookup_meaning('R_NEG_BOX')||'</B></td>';
         else
            lv_format :=  '<tr><td align=right>&nbsp</td>';
         end if;
         lv_req_flds :=   '<tr><td align=right>&nbsp</td>';
         lv_format := lv_format || '<td align="right"><B>'||
                   --   get_bal_name(sv_neg_bal(i).dbi_short_name)||'</B></td>';
                                     sv_neg_bal(i).dbi_short_name||'</B></td>';
         lv_req_flds := lv_req_flds || '<td align="right">'||
                        sv_neg_bal(i).dbi_value||'</td>';
      elsif mod(i,5) = 0 then
         lv_format := lv_format || '<td align="right"><B>'||
                 --     get_bal_name(sv_neg_bal(i).dbi_short_name)||
                                     sv_neg_bal(i).dbi_short_name||
                      '</B></td></tr>';
         lv_req_flds := lv_req_flds || '<td align="right">'||
                        sv_neg_bal(i).dbi_value||'</td></tr>';
         format_data(lv_format);
         format_data(lv_req_flds);
         lv_format := null;
         lv_req_flds := null;
      else
         lv_format := lv_format || '<td align="right"><B>'||
                      --get_bal_name(sv_neg_bal(i).dbi_short_name)||'</B></td>';
                                     sv_neg_bal(i).dbi_short_name||'</B></td>';
         lv_req_flds := lv_req_flds || '<td align="right">'||
                        sv_neg_bal(i).dbi_value||'</td>';
      end if;
      lv_format := rtrim(ltrim(lv_format));
      lv_req_flds := rtrim(ltrim(lv_req_flds));

   end loop;
   if mod(sv_nb,5) <> 0 then
         lv_format := lv_format ||'</tr>';
         lv_req_flds := lv_req_flds ||'</tr>';
         format_data(lv_format);
         format_data(lv_req_flds);
         lv_format := null;
         lv_req_flds := null;
   end if;

   end if;

 end if;

 if ( ( sv_c + sv_m ) > 0 ) then

   hr_utility.set_location('5',888);
   lv_format := '<tr><td>&nbsp</td></tr>';
   format_data(lv_format);

   hr_utility.set_location('6',888);
   lv_format := '<tr><td><B>'||get_lookup_meaning('R_REASON')||'</B></td></tr>';
   format_data(lv_format);

   if ( sv_m > 0 ) then
      for i in 1..sv_m
      loop
         hr_utility.set_location('7',888);
         lv_format := '<tr><td colspan=6>'||print_spaces(30);
         lv_format := lv_format||' '||to_char(i)||'. '||sv_msg(i)||'</td></tr>';
         format_data(lv_format);
      end loop;
   end if;
   if sv_c > 0 then
      hr_utility.set_location('8',888);
      lv_format := '<tr><td colspan=6>'||print_spaces(30);
      lv_format := lv_format||' '||to_char(sv_m+1)||'. '||
                   get_lookup_meaning('R_REQ_FIELDS')||'</td></tr>';
      format_data(lv_format);
      lv_req_flds := null;
      for i in 1..sv_c
      loop
          if i <> 1 then
             lv_req_flds := lv_req_flds || ', ';
          end if;
          lv_req_flds := lv_req_flds || sv_col(i);
      end loop;
      if ( length(lv_req_flds) < 135 ) then
         lv_req_flds := lv_req_flds ||
                        print_spaces( 135 - length(lv_req_flds) );
      end if;
      hr_utility.set_location('9',888);
      lv_format := '<tr><td colspan=5>'||print_spaces(30);
      lv_format := lv_format||' '||lv_req_flds||'</td></tr>';
      format_data(lv_format);
   end if;
   end if;
      hr_utility.set_location('10',888);
      lv_format := '<tr><td colspan=6>'||print_line('-',156)||'</td></tr>';
      format_data(lv_format);
  end print_employee;

  /* The procedure print_employer prints Employer Data for T4, T4A and RL1. */

  procedure print_employer is
  lv_format    varchar2(32000);
  lv_req_flds    varchar2(32000);
  begin
      lv_format := '<tr><td>'|| sv_employer_name || '</td><td colspan=2>';
      if sv_f_p = 'P' then
         lv_format := lv_format || sv_qin;
      else
        lv_format := lv_format || sv_busi_no;
      end if;
      lv_format := lv_format || '</td><td>' || sv_reporting_year ||
                   '</td><td align="center">' || sv_trans_y_n || '</td></tr>';
      format_data(lv_format);

      lv_format := '<tr><td>' || sv_employer_address_line1 || '</td></tr>';
      format_data(lv_format);

      if ( sv_employer_address_line2 is not null ) then
         lv_format := '<tr><td>' || sv_employer_address_line2 || '</td></tr>';
        format_data(lv_format);
      end if;

      lv_format := '<tr><td>' || sv_employer_city||','||sv_employer_province||
                   ' '|| sv_employer_postal_code || '</td></tr>';
      format_data(lv_format);

      if ( ( sv_c + sv_m ) > 0 ) then

        lv_format := '</table>' ||
                     '<table border=0><tr><td>&nbsp</td><td></td></tr>';
        format_data(lv_format);

         lv_format := '<tr><td colspan=2><B>' ||
                      get_lookup_meaning('R_REASON') ||
                      '</B></td></tr>';
        format_data(lv_format);

   if ( sv_m > 0 ) then
      for i in 1..sv_m
      loop
               lv_format := '<tr><td>'||print_spaces(30)||'</td><td>' ||
                            to_char(i)||'. '||sv_msg(i)||
                            print_spaces(135-length(sv_msg(i)))||
                            '</td></tr>';
               format_data(lv_format);
      end loop;
   end if;
        if sv_c > 0 then
            lv_format := '<tr><td>'||print_spaces(30)||'</td><td>' ||
                         to_char(sv_m+1)||'. '||
                         get_lookup_meaning('R_REQ_FIELDS') ||
                         '</td></tr><tr></tr>';
            format_data(lv_format);

            for i in 1..sv_c
            loop
                if i <> 1 then
                   lv_req_flds := lv_req_flds || ', ';
                end if;
                lv_req_flds := lv_req_flds || sv_col(i);
             end loop;
             if ( length(lv_req_flds) < 135 ) then
                lv_req_flds := lv_req_flds ||
                        print_spaces( 135 - length(lv_req_flds) );
             end if;
             lv_format := '<tr><td></td><td>'||lv_req_flds||'</td></tr>';
             format_data(lv_format);
         end if;
        lv_format := '<tr><td colspan=2>' || print_line('-',156) ||
                     '</td></tr>';
        format_data(lv_format);
     else
        lv_format := '<tr><td colspan=5>' || print_line('-',156) ||
                     '</td></tr>';
        format_data(lv_format);
     end if;
     lv_format := '</table>';
     format_data(lv_format);
  end print_employer;

  /* The procedure static_header prints the input parameters */

  procedure static_header is
  lv_format    varchar2(32000);
  begin

      lv_format := '<table border=0><tr><td></td><td><HEAD> <CENTER>  <B>' ||
                   sv_pier_yeer || '</B></CENTER></HEAD></td>'||
                   '<td align="left">' || get_lookup_meaning('L_DATE')||
                   sv_date || '</td></tr>';
      format_data(lv_format);

      lv_format := '<tr><td>&nbsp</td></tr>';
      format_data(lv_format);

      lv_format := '<tr><td>'|| print_line('-',50) || '</td><td>'||
                   print_line('-',50) || '</td><td>' || print_line('-',50) ||
                   '</td></tr>';
      format_data(lv_format);

      lv_format := '<tr><td align="left"><B>' ||
                   get_lookup_meaning('L_REPORT_PARAMETERS') ||
                   '</B></td></tr>';
      format_data(lv_format);

      lv_format := '<tr><td align="right"><B>' ||
                   get_lookup_meaning('L_REPORTING_YEAR') || '</B></td>' ||
                   '<td align="left">' || sv_reporting_year || '</td></tr>';
      format_data(lv_format);

      lv_format := '<tr><td align="right"><B>' ||
                   get_lookup_meaning('L_REPORT_NAME') || '</B></td>' ||
                   '<td align="left">' || sv_pier_yeer || '</td></tr>';
      format_data(lv_format);

      lv_format := '<tr><td align="right"><B>' ||
                   get_lookup_meaning('L_FED_PROV') || '</B></td>' ||
                   '<td align="left">' || sv_fed_prov  || '</td></tr>';
      format_data(lv_format);

      lv_format := '<tr><td align="right"><B>' ||
                   get_lookup_meaning('L_BUSINESS_NO') || '</B></td>'||
                   '<td align="left">' || sv_busi_no  || '</td></tr>';
      format_data(lv_format);

      lv_format := '<tr><td align="right"><B>' ||
                   get_lookup_meaning('L_ARCHIVED_GRE') || '</B></td>' ||
                   '<td align="left">' || sv_gre_name  || '</td></tr>';
      format_data(lv_format);

      lv_format := '<tr><td align="right"><B>' ||
                   get_lookup_meaning('L_QC_ID_NO') || '</B></td>' ||
                   '<td align="left">' || sv_qin || '</td></tr>';
      format_data(lv_format);

      lv_format := '<tr><td align="right"><B>' ||
                   get_lookup_meaning('L_ARCHIVED_PRE') || '</B></td>'||
                   '<td align="left">' || sv_pre_name  || '</td></tr>';
      format_data(lv_format);

      lv_format := '<tr><td>&nbsp</td></tr>';
      format_data(lv_format);

      lv_format := '<tr><td colspan=3>'||print_line('-',156)||'</td></tr>';
      format_data(lv_format);

      sv_line := 11;
--      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, new_page);

      lv_format := '</table>';
      format_data(lv_format);

  end static_header;

  /* The procedure prov_employee_validation validates the value of
     RL1 and RL2 Employee */

  PROCEDURE prov_employee_validation is
  l_emp_first_name varchar2(240);
  l_emp_last_name  varchar2(240);
  lv_overlimit      number(1) := 0;
  lv_missing_adr    number(1) := 0;
  lv_person_id      number(10) := 0;
  lv_asg_act_id     number(10) := 0;

  begin
    sv_ei_deficiency := 0;

  if sv_report_type in ('RL1','CAEOY_RL1_AMEND_PP') then

    for i in sv_dbi.first..sv_dbi.last
     loop
      hr_utility.set_location(to_char(i)||'. '||sv_dbi(i).dbi_name||' '||
      sv_dbi(i).dbi_value||' '||sv_dbi(i).dbi_short_name, 999 );

      if sv_dbi(i).dbi_name = 'CAEOY_PERSON_ID' then
         lv_person_id := to_number(sv_dbi(i).dbi_value);
      end if;

      if sv_dbi(i).dbi_name = 'CAEOY_EMPLOYEE_NUMBER' then
         sv_employee_no := sv_dbi(i).dbi_value;
      end if;

      if sv_dbi(i).dbi_name = 'CAEOY_EMPLOYEE_FIRST_NAME' then
         l_emp_first_name := sv_dbi(i).dbi_value;
         if l_emp_first_name is null then
            sv_c := sv_c + 1;
            sv_col(sv_c) := upper(sv_dbi(i).dbi_short_name);
                 sv_print := 1;
         end if;
      end if;

      if sv_dbi(i).dbi_name = 'CAEOY_EMPLOYEE_LAST_NAME' then
         l_emp_last_name := sv_dbi(i).dbi_value;
         if l_emp_last_name is null then
            sv_c := sv_c + 1;
            sv_col(sv_c) := upper(sv_dbi(i).dbi_short_name);
                 sv_print := 1;
         end if;
      end if;

      if sv_dbi(i).dbi_name = 'CAEOY_RL1_SLIP_NUMBER' then
         sv_rl1_slip_no := sv_dbi(i).dbi_value;
         if sv_rl1_slip_no is null then
            sv_c := sv_c + 1;
            sv_col(sv_c) := upper(sv_dbi(i).dbi_short_name);
                 sv_print := 1;
         end if;
      end if;

      if sv_dbi(i).dbi_name = 'CAEOY_EMPLOYEE_ADDRESS_LINE1' and
         sv_dbi(i).dbi_value is null
                then
         if lv_missing_adr = 0 then
           sv_m := sv_m + 1;
           sv_msg(sv_m) := get_lookup_meaning('R_MISSING_ADR');
           sv_print     := 1;
           lv_missing_adr := 1;
         end if;
      end if;

      if sv_dbi(i).dbi_name = 'CAEOY_EMPLOYEE_CITY' and
         sv_dbi(i).dbi_value is null
                then
         if lv_missing_adr = 0 then
         sv_m := sv_m + 1;
         sv_msg(sv_m) := get_lookup_meaning('R_MISSING_ADR');
         sv_print     := 1;
         lv_missing_adr := 1;
         end if;
      end if;

      if sv_dbi(i).dbi_name = 'CAEOY_EMPLOYEE_PROVINCE' and
         sv_dbi(i).dbi_value is null
                then
         if lv_missing_adr = 0 then
         sv_m := sv_m + 1;
         sv_msg(sv_m) := get_lookup_meaning('R_MISSING_ADR');
         sv_print     := 1;
         lv_missing_adr := 1;
         end if;
      end if;

      if sv_dbi(i).dbi_name = 'CAEOY_EMPLOYEE_POSTAL_CODE' and
         sv_dbi(i).dbi_value is null
                then
         if lv_missing_adr = 0 then
            sv_m := sv_m + 1;
            sv_msg(sv_m) := get_lookup_meaning('R_MISSING_ADR');
            sv_print     := 1;
            lv_missing_adr := 1;
         end if;
      end if;

      if sv_dbi(i).dbi_name = 'CAEOY_EMPLOYEE_SIN' then
         sv_employee_sin  := substr(sv_dbi(i).dbi_value,1,3) ||' '||
                   substr(sv_dbi(i).dbi_value,4,3) ||' '||
                   substr(sv_dbi(i).dbi_value,7,3) ;

         if sv_dbi(i).dbi_value is null then
         sv_c := sv_c + 1;
         sv_col(sv_c) := upper(sv_dbi(i).dbi_short_name);
         sv_print := 1;
         end if;

         if length(sv_dbi(i).dbi_value) <> 9 then
         sv_m := sv_m + 1;
         sv_msg(sv_m) := get_lookup_meaning('R_SIN_INVALID');
         sv_print := 1;
         end if;

      end if;

      if sv_dbi(i).dbi_name = 'CAEOY_GROSS_EARNINGS_PER_JD_YTD' then
         sv_total_earnings  := nvl(sv_total_earnings,0) + fnd_number.canonical_to_number(sv_dbi(i).dbi_value);
	 hr_utility.trace('sv_total_earnings ='|| sv_total_earnings);
      end if;

      if sv_dbi(i).dbi_name = 'CAEOY_QPP_EE_TAXABLE_PER_JD_YTD' then
         sv_pensionable_earnings  := nvl(sv_pensionable_earnings,0) +fnd_number.canonical_to_number(sv_dbi(i).dbi_value);
      end if;

      if sv_dbi(i).dbi_name = 'CAEOY_QPP_EE_WITHHELD_PER_JD_YTD' then
         sv_ded_reported_16  :=  nvl(sv_ded_reported_16,0) + fnd_number.canonical_to_number(sv_dbi(i).dbi_value);
      end if;

      if sv_dbi(i).dbi_name = 'CAEOY_QPP_BASIC_EXEMPTION_PER_JD_YTD' then
         sv_cpp_basic_exemption  :=
         nvl(sv_cpp_basic_exemption,0) + fnd_number.canonical_to_number(sv_dbi(i).dbi_value);
      end if;

      if sv_dbi(i).dbi_name = 'CAEOY_QPP_EXEMPT_PER_JD_YTD' then
         sv_cpp_exempt_bal  :=
         nvl(sv_cpp_exempt_bal,0) + fnd_number.canonical_to_number(sv_dbi(i).dbi_value);
      end if;

      /* Added by ssmukher for PPIP tax */
      if sv_dbi(i).dbi_name = 'CAEOY_PPIP_EE_TAXABLE_PER_JD_YTD' then
          sv_ppip_insurable_earnings  := nvl(sv_ppip_insurable_earnings,0) + fnd_number.canonical_to_number(sv_dbi(i).dbi_value);
      end if;
      if sv_dbi(i).dbi_name = 'CAEOY_PPIP_EE_WITHHELD_PER_JD_YTD' then
	 sv_ded_reported_ppip  :=nvl(sv_ded_reported_ppip,0) + fnd_number.canonical_to_number(sv_dbi(i).dbi_value);
      end if;

      sv_ppip_ded_required := ((sv_ppip_insurable_earnings * sv_ppip_rate )/ 100 );

      if sv_ppip_ded_required  > sv_ppip_max_exempt  then
        sv_ppip_ded_required := sv_ppip_max_exempt;
        lv_overlimit        := 1;
      end if;

      if sv_ppip_ded_required < 0 then
         sv_ppip_deficiency    := sv_ded_reported_ppip ;
      end if;

      sv_ppip_deficiency := (sv_ppip_ded_required - sv_ded_reported_ppip);

      if sv_ppip_deficiency < 0 then
         sv_ppip_deficiency := 0;
      end if;

      if sv_p_y = 'E' then

         if instr(sv_dbi(i).dbi_name, 'YTD') > 0  and
            instr(sv_dbi(i).dbi_name, 'CODE') = 0  and
            fnd_number.canonical_to_number(nvl(sv_dbi(i).dbi_value,'0')) < 0 then

            sv_nb := sv_nb + 1;
            sv_neg_bal(sv_nb).dbi_name := sv_dbi(i).dbi_name;
            sv_neg_bal(sv_nb).dbi_value :=
               pay_us_employee_payslip_web.get_format_value(sv_b_g_id,fnd_number.canonical_to_number(sv_dbi(i).dbi_value));
            sv_neg_bal(sv_nb).dbi_short_name := sv_dbi(i).dbi_short_name;
            sv_print := 1;

         end if;

         if (sv_dbi(i).dbi_name = 'CAEOY_RL1_NONBOX_FOOTNOTE') and
            (fnd_number.canonical_to_number(nvl(sv_dbi(i).dbi_value,'0')) < 0)  then

            sv_nb := sv_nb + 1;
            sv_neg_bal(sv_nb).dbi_name := sv_dbi(i).dbi_name;
            sv_neg_bal(sv_nb).dbi_value :=
              pay_us_employee_payslip_web.get_format_value(sv_b_g_id,fnd_number.canonical_to_number(sv_dbi(i).dbi_value));
            sv_neg_bal(sv_nb).dbi_short_name := sv_dbi(i).dbi_short_name;
            sv_print := 1;

         end if;

      end if;

   end loop;

   sv_employee_name := substr(l_emp_last_name,1,120)||', '||substr(l_emp_first_name,1,118); -- #2406070

   sv_cpp_ded_required := ((sv_pensionable_earnings - sv_cpp_exempt ) * sv_cpp_rate / 100 );

   if sv_cpp_ded_required  > sv_cpp_max_exempt  then
      sv_cpp_ded_required := sv_cpp_max_exempt;
      lv_overlimit         := 1;
   end if;

   if sv_cpp_ded_required < 0 then
      sv_cpp_ded_required :=  0.00;
   end if;

   /*sv_cpp_qpp_deficiency := to_char((fnd_number.canonical_to_number(sv_ded_reported_16,'999,999,990.00')
                                     - sv_cpp_ded_required ),'999,990.00');   */

     sv_cpp_qpp_deficiency := sv_cpp_ded_required - sv_ded_reported_16;

   /* The deficiency field should not display over-payments */
   if sv_cpp_qpp_deficiency < 0 then  ----till here
      sv_cpp_qpp_deficiency := 0;
   end if;

   if  sv_nb > 0  then
      sv_m := sv_m + 1;
      sv_msg(sv_m) := get_lookup_meaning('R_NEG_BAL');
      sv_print := 1;
   end if;

   if  lv_overlimit > 0  then
      sv_m := sv_m + 1;
      sv_msg(sv_m) := get_lookup_meaning('R_OVERLIMIT_BAL');
      sv_print := 1;
   end if;

   if sv_p_y = 'P' then
      /* When option is PIER Report, the following messages should print
         if they fullfill their conditions except Negative Balance. */
      sv_print := 0;
      sv_nb := 0;
      sv_m  := 0;
      sv_c  := 0;
      sv_msg.delete;
      sv_col.delete;
      sv_neg_bal.delete;
   end if;

   /*  if ( ( fnd_number.canonical_to_number( sv_cpp_qpp_deficiency, '999,990.00') > 0 and
          abs(fnd_number.canonical_to_number( sv_cpp_qpp_deficiency, '999,990.00')) > 1 ) or
        ( fnd_number.canonical_to_number( sv_ei_deficiency, '999,990.00') > 0 and
         abs(fnd_number.canonical_to_number( sv_ei_deficiency, '999,990.00')) > 1 ) ) then */

   if (sv_cpp_qpp_deficiency > 1) or (sv_ppip_deficiency > 1) then

      sv_print := 1;

      if to_number(sv_reporting_year) -
         to_number(to_char(sv_date_of_birth,'YYYY') ) = 18 then
         sv_m := sv_m + 1;
         sv_msg(sv_m) := get_lookup_meaning('R_EMP_TURNED_18');
      end if;

      if sv_reporting_year = to_char(sv_hire_date,'YYYY')  then
         sv_m := sv_m + 1;
         sv_msg(sv_m) := get_lookup_meaning('R_EMP_HIRED');
      end if;

      if sv_reporting_year = to_char(sv_terminate_date,'YYYY')  then
         sv_m := sv_m + 1;
         sv_msg(sv_m) := get_lookup_meaning('R_EMP_TERMINATED');
      end if;

      if sv_p_y = 'P' then

         if (sv_cpp_block = 'Y')  then
            sv_m := sv_m + 1;
            sv_msg(sv_m) := get_lookup_meaning('R_QPP_BLOCK');
         end if;

	 if (sv_ppip_block = 'Y')  then
            sv_m := sv_m + 1;
            sv_msg(sv_m) := get_lookup_meaning('R_PPIP_BLOCK');
         end if;

      end if;

   end if;

     if  sv_p_y = 'E' then

       if (sv_cpp_block = 'Y')  then
         sv_m := sv_m + 1;
         sv_msg(sv_m) := get_lookup_meaning('R_QPP_BLOCK');
         sv_print     := 1;
       end if;

	if (sv_ppip_block = 'Y')  then
            sv_m := sv_m + 1;
            sv_msg(sv_m) := get_lookup_meaning('R_PPIP_BLOCK');
        end if;

       if get_multi_jd(lv_person_id) > 1 then
         sv_m := sv_m + 1;
         sv_msg(sv_m) := get_lookup_meaning('R_EMP_MULTI_JD');
         sv_print     := 1;
       end if;

     end if;

   end if;   /* End of sv_report_type in ('RL1','CAEOY_RL1_AMEND_PP') */

   /* RL2 Employee Validation */

   if sv_report_type = 'RL2' then

         lv_person_id := to_number(lr_rl2_emprec.PERSON_ID);
         sv_employee_no := lr_rl2_emprec.EMPLOYEE_NUMBER;

         l_emp_first_name := lr_rl2_emprec.EMPLOYEE_FIRST_NAME;
         if l_emp_first_name is null then
            sv_c := sv_c + 1;
            sv_col(sv_c) := upper('First Name');
                 sv_print := 1;
         end if;

         l_emp_last_name := lr_rl2_emprec.EMPLOYEE_LAST_NAME;
         if l_emp_last_name is null then
            sv_c := sv_c + 1;
            sv_col(sv_c) := upper('Last Name');
            sv_print := 1;
         end if;

         sv_employee_name := substr(l_emp_last_name,1,120)||', '||substr(l_emp_first_name,1,118);
         sv_rl1_slip_no := lr_rl2_emprec.RL2_SLIP_NUMBER;
         if sv_rl1_slip_no is null then
            sv_c := sv_c + 1;
            sv_col(sv_c) := upper('Slip Number');
            sv_print := 1;
         end if;


      if lr_rl2_emprec.EMPLOYEE_ADDRESS_LINE1 is null then
         if lv_missing_adr = 0 then
           sv_m := sv_m + 1;
           sv_msg(sv_m) := get_lookup_meaning('R_MISSING_ADR');
           sv_print     := 1;
           lv_missing_adr := 1;
         end if;
      end if;

      if lr_rl2_emprec.EMPLOYEE_CITY is null then
         if lv_missing_adr = 0 then
         sv_m := sv_m + 1;
         sv_msg(sv_m) := get_lookup_meaning('R_MISSING_ADR');
         sv_print     := 1;
         lv_missing_adr := 1;
         end if;
      end if;

      if lr_rl2_emprec.EMPLOYEE_PROVINCE is null then
         if lv_missing_adr = 0 then
         sv_m := sv_m + 1;
         sv_msg(sv_m) := get_lookup_meaning('R_MISSING_ADR');
         sv_print     := 1;
         lv_missing_adr := 1;
         end if;
      end if;

      if lr_rl2_emprec.EMPLOYEE_POSTAL_CODE is null then
         if lv_missing_adr = 0 then
            sv_m := sv_m + 1;
            sv_msg(sv_m) := get_lookup_meaning('R_MISSING_ADR');
            sv_print     := 1;
            lv_missing_adr := 1;
         end if;
      end if;

         sv_employee_sin  := substr(lr_rl2_emprec.EMPLOYEE_SIN,1,3) ||' '||
                   substr(lr_rl2_emprec.EMPLOYEE_SIN,4,3) ||' '||
                   substr(lr_rl2_emprec.EMPLOYEE_SIN,7,3) ;

         if lr_rl2_emprec.EMPLOYEE_SIN is null then
           sv_c := sv_c + 1;
           sv_col(sv_c) := upper('Sin');
           sv_print := 1;
         end if;

         if length(lr_rl2_emprec.EMPLOYEE_SIN) <> 9 then
           sv_m := sv_m + 1;
           sv_msg(sv_m) := get_lookup_meaning('R_SIN_INVALID');
           sv_print := 1;
         end if;

         if lr_rl2_emprec.RL2_SOURCE_OF_INCOME is null then
           sv_c := sv_c + 1;
           sv_col(sv_c) := upper('Source of Income');
           sv_print := 1;
         end if;


       if sv_p_y = 'E' then
         /* Checking for Negative Balance values for RL2 */
         if lr_rl2_emprec.NEGATIVE_BALANCE_FLAG = 'Y' then

            if fnd_number.canonical_to_number(nvl(lr_rl2_emprec.RL2_BOX_A,'0')) < 0 then

              sv_nb := sv_nb + 1;
              sv_neg_bal(sv_nb).dbi_name := 'RL2_BOX_A';
              sv_neg_bal(sv_nb).dbi_value :=
                 pay_us_employee_payslip_web.get_format_value(sv_b_g_id
		                                             ,fnd_number.canonical_to_number(lr_rl2_emprec.RL2_BOX_A));

              sv_neg_bal(sv_nb).dbi_short_name := 'RL2 Box A';
              sv_print := 1;
            end if;

            if fnd_number.canonical_to_number(nvl(lr_rl2_emprec.RL2_BOX_B,'0')) < 0 then

              sv_nb := sv_nb + 1;
              sv_neg_bal(sv_nb).dbi_name := 'RL2_BOX_B';
              sv_neg_bal(sv_nb).dbi_value :=
                 pay_us_employee_payslip_web.get_format_value(sv_b_g_id
		                                             ,fnd_number.canonical_to_number(lr_rl2_emprec.RL2_BOX_B));

              sv_neg_bal(sv_nb).dbi_short_name := 'RL2 Box B';
              sv_print := 1;
            end if;

            if fnd_number.canonical_to_number(nvl(lr_rl2_emprec.RL2_BOX_C,'0')) < 0 then

              sv_nb := sv_nb + 1;
              sv_neg_bal(sv_nb).dbi_name := 'RL2_BOX_C';
              sv_neg_bal(sv_nb).dbi_value :=
                 pay_us_employee_payslip_web.get_format_value(sv_b_g_id
		                                             ,fnd_number.canonical_to_number(lr_rl2_emprec.RL2_BOX_C));

              sv_neg_bal(sv_nb).dbi_short_name := 'RL2 Box C';
              sv_print := 1;
            end if;

            if fnd_number.canonical_to_number(nvl(lr_rl2_emprec.RL2_BOX_D,'0')) < 0 then

              sv_nb := sv_nb + 1;
              sv_neg_bal(sv_nb).dbi_name := 'RL2_BOX_D';
              sv_neg_bal(sv_nb).dbi_value :=
                 pay_us_employee_payslip_web.get_format_value(sv_b_g_id
		                                             ,fnd_number.canonical_to_number(lr_rl2_emprec.RL2_BOX_D));

              sv_neg_bal(sv_nb).dbi_short_name := 'RL2 Box D';
              sv_print := 1;
            end if;

            if fnd_number.canonical_to_number(nvl(lr_rl2_emprec.RL2_BOX_E,'0')) < 0 then

              sv_nb := sv_nb + 1;
              sv_neg_bal(sv_nb).dbi_name := 'RL2_BOX_E';
              sv_neg_bal(sv_nb).dbi_value :=
                 pay_us_employee_payslip_web.get_format_value(sv_b_g_id
		                                             ,fnd_number.canonical_to_number(lr_rl2_emprec.RL2_BOX_E));

              sv_neg_bal(sv_nb).dbi_short_name := 'RL2 Box E';
              sv_print := 1;
            end if;

            if fnd_number.canonical_to_number(nvl(lr_rl2_emprec.RL2_BOX_F,'0')) < 0 then

              sv_nb := sv_nb + 1;
              sv_neg_bal(sv_nb).dbi_name := 'RL2_BOX_F';
              sv_neg_bal(sv_nb).dbi_value :=
                 pay_us_employee_payslip_web.get_format_value(sv_b_g_id
		                                             ,fnd_number.canonical_to_number(lr_rl2_emprec.RL2_BOX_F));

              sv_neg_bal(sv_nb).dbi_short_name := 'RL2 Box F';
              sv_print := 1;
            end if;

            if fnd_number.canonical_to_number(nvl(lr_rl2_emprec.RL2_BOX_G,'0')) < 0 then

              sv_nb := sv_nb + 1;
              sv_neg_bal(sv_nb).dbi_name := 'RL2_BOX_G';
              sv_neg_bal(sv_nb).dbi_value :=
                 pay_us_employee_payslip_web.get_format_value(sv_b_g_id
		                                             ,fnd_number.canonical_to_number(lr_rl2_emprec.RL2_BOX_G));

              sv_neg_bal(sv_nb).dbi_short_name := 'RL2 Box G';
              sv_print := 1;
            end if;

            if fnd_number.canonical_to_number(nvl(lr_rl2_emprec.RL2_BOX_H,'0')) < 0 then

              sv_nb := sv_nb + 1;
              sv_neg_bal(sv_nb).dbi_name := 'RL2_BOX_H';
              sv_neg_bal(sv_nb).dbi_value :=
                 pay_us_employee_payslip_web.get_format_value(sv_b_g_id
		                                             ,fnd_number.canonical_to_number(lr_rl2_emprec.RL2_BOX_H));

              sv_neg_bal(sv_nb).dbi_short_name := 'RL2 Box H';
              sv_print := 1;
            end if;

            if fnd_number.canonical_to_number(nvl(lr_rl2_emprec.RL2_BOX_I,'0')) < 0 then

              sv_nb := sv_nb + 1;
              sv_neg_bal(sv_nb).dbi_name := 'RL2_BOX_I';
              sv_neg_bal(sv_nb).dbi_value :=
                 pay_us_employee_payslip_web.get_format_value(sv_b_g_id
		                                             ,fnd_number.canonical_to_number(lr_rl2_emprec.RL2_BOX_I));

              sv_neg_bal(sv_nb).dbi_short_name := 'RL2 Box I';
              sv_print := 1;
            end if;

            if fnd_number.canonical_to_number(nvl(lr_rl2_emprec.RL2_BOX_J,'0')) < 0 then

              sv_nb := sv_nb + 1;
              sv_neg_bal(sv_nb).dbi_name := 'RL2_BOX_J';
              sv_neg_bal(sv_nb).dbi_value :=
                 pay_us_employee_payslip_web.get_format_value(sv_b_g_id
		                                             ,fnd_number.canonical_to_number(lr_rl2_emprec.RL2_BOX_J));

              sv_neg_bal(sv_nb).dbi_short_name := 'RL2 Box J';
              sv_print := 1;
            end if;

            if fnd_number.canonical_to_number(nvl(lr_rl2_emprec.RL2_BOX_K,'0')) < 0 then

              sv_nb := sv_nb + 1;
              sv_neg_bal(sv_nb).dbi_name := 'RL2_BOX_K';
              sv_neg_bal(sv_nb).dbi_value :=
                 pay_us_employee_payslip_web.get_format_value(sv_b_g_id
		                                             ,fnd_number.canonical_to_number(lr_rl2_emprec.RL2_BOX_K));

              sv_neg_bal(sv_nb).dbi_short_name := 'RL2 Box K';
              sv_print := 1;
            end if;

            if fnd_number.canonical_to_number(nvl(lr_rl2_emprec.RL2_BOX_L,'0')) < 0 then

              sv_nb := sv_nb + 1;
              sv_neg_bal(sv_nb).dbi_name := 'RL2_BOX_L';
              sv_neg_bal(sv_nb).dbi_value :=
                 pay_us_employee_payslip_web.get_format_value(sv_b_g_id
		                                             ,fnd_number.canonical_to_number(lr_rl2_emprec.RL2_BOX_L));

              sv_neg_bal(sv_nb).dbi_short_name := 'RL2 Box L';
              sv_print := 1;
            end if;

            if fnd_number.canonical_to_number(nvl(lr_rl2_emprec.RL2_BOX_M,'0')) < 0 then

              sv_nb := sv_nb + 1;
              sv_neg_bal(sv_nb).dbi_name := 'RL2_BOX_M';
              sv_neg_bal(sv_nb).dbi_value :=
                 pay_us_employee_payslip_web.get_format_value(sv_b_g_id
		                                             ,fnd_number.canonical_to_number(lr_rl2_emprec.RL2_BOX_M));

              sv_neg_bal(sv_nb).dbi_short_name := 'RL2 Box M';
              sv_print := 1;
            end if;

            if fnd_number.canonical_to_number(nvl(lr_rl2_emprec.RL2_BOX_O,'0')) < 0 then

              sv_nb := sv_nb + 1;
              sv_neg_bal(sv_nb).dbi_name := 'RL2_BOX_O';
              sv_neg_bal(sv_nb).dbi_value :=
                 pay_us_employee_payslip_web.get_format_value(sv_b_g_id
		                                             ,fnd_number.canonical_to_number(lr_rl2_emprec.RL2_BOX_O));

              sv_neg_bal(sv_nb).dbi_short_name := 'RL2 Box O';
              sv_print := 1;
            end if;

         end if; /* End of NEGATIVE_BALANCE_FLAG = 'Y' */


           if  sv_nb > 0  then
               sv_m := sv_m + 1;
               sv_msg(sv_m) := get_lookup_meaning('R_NEG_BAL');
               sv_print := 1;
           end if;

       end if;  /* End of sv_p_y = 'E' */

    end if; /* End of sv_report_type = 'RL2' */

   /* End of RL2 Employee Validation */

  end prov_employee_validation;

  /* The procedure prov_employer_validation validates the value
     of RL1 Employer */

  PROCEDURE prov_employer_validation is
  begin
  if sv_report_type in ('RL1','CAEOY_RL1_AMEND_PP') then
   for i in sv_dbi.first..sv_dbi.last
   loop
    hr_utility.set_location(sv_dbi(i).dbi_short_name, 601);
    if sv_trans_y_n = 'Y' then
      if sv_dbi(i).dbi_name = 'CAEOY_RL1_TRANSMITTER_NUMBER' then
         if sv_dbi(i).dbi_value is null then
            sv_c := sv_c + 1;
            sv_col(sv_c) := sv_dbi(i).dbi_short_name;
            hr_utility.set_location('Required column '||sv_col(sv_c), 610);
         else
            if ( ( substr(sv_dbi(i).dbi_value,1,2) <> 'NP' )  or
               ( length(sv_dbi(i).dbi_value) <> 8 ) or
               ( not ( substr(sv_dbi(i).dbi_value,3) >= '000000' ) and
               ( substr(sv_dbi(i).dbi_value,3) <= '999999' ) ) )
            then
               sv_m := sv_m + 1;
               sv_msg(sv_m) := get_lookup_meaning('R_INVALID_TRANS_NO');
        hr_utility.set_location(sv_msg(sv_m)|| ' '||sv_dbi(i).dbi_value, 611);
            end if;
         end if;
      end if;
      if sv_dbi(i).dbi_name = 'CAEOY_RL1_TRANSMITTER_NAME' and
            sv_dbi(i).dbi_value is null then
         sv_c := sv_c + 1;
         sv_col(sv_c) := sv_dbi(i).dbi_short_name;
            hr_utility.set_location('Required column '||sv_col(sv_c), 612);
      end if;
      if sv_dbi(i).dbi_name = 'CAEOY_RL1_TRANSMITTER_CITY' and
         sv_dbi(i).dbi_value is null then
         sv_c := sv_c + 1;
         sv_col(sv_c) := sv_dbi(i).dbi_short_name;
         hr_utility.set_location('Required column '||sv_col(sv_c), 613);
      end if;
      if sv_dbi(i).dbi_name = 'CAEOY_RL1_TRANSMITTER_PROVINCE' and
         sv_dbi(i).dbi_value is null then
         sv_c := sv_c + 1;
         sv_col(sv_c) := sv_dbi(i).dbi_short_name;
         hr_utility.set_location('Required column '||sv_col(sv_c), 614);
      end if;
      if sv_dbi(i).dbi_name = 'CAEOY_RL1_TRANSMITTER_POSTAL_CODE' and
         sv_dbi(i).dbi_value is null then
         sv_c := sv_c + 1;
         sv_col(sv_c) := sv_dbi(i).dbi_short_name;
         hr_utility.set_location('Required column '||sv_col(sv_c), 615);
      end if;
      if sv_dbi(i).dbi_name = 'CAEOY_RL1_TECHNICAL_CONTACT_NAME' and
         sv_dbi(i).dbi_value is null then
         sv_c := sv_c + 1;
         sv_col(sv_c) := sv_dbi(i).dbi_short_name;
         hr_utility.set_location('Required column '||sv_col(sv_c), 616);
      end if;
      if sv_dbi(i).dbi_name = 'CAEOY_RL1_TECHNICAL_CONTACT_PHONE' and
         sv_dbi(i).dbi_value is null then
         sv_c := sv_c + 1;
         sv_col(sv_c) := sv_dbi(i).dbi_short_name;
         hr_utility.set_location('Required column '||sv_col(sv_c), 617);
      end if;
      if sv_dbi(i).dbi_name = 'CAEOY_RL1_TECHNICAL_CONTACT_AREA_CODE' and
         sv_dbi(i).dbi_value is null then
         sv_c := sv_c + 1;
         sv_col(sv_c) := sv_dbi(i).dbi_short_name;
         hr_utility.set_location('Required column '||sv_col(sv_c), 618);
      end if;
      if sv_dbi(i).dbi_name = 'CAEOY_RL1_TECHNICAL_CONTACT_LANGUAGE' and
         sv_dbi(i).dbi_value is null then
         sv_c := sv_c + 1;
         sv_col(sv_c) := sv_dbi(i).dbi_short_name;
         hr_utility.set_location('Required column '||sv_col(sv_c), 619);
      end if;
      if sv_dbi(i).dbi_name = 'CAEOY_RL1_TRANSMITTER_ADDRESS_LINE1' and
         sv_dbi(i).dbi_value is null then
         sv_c := sv_c + 1;
         sv_col(sv_c) := sv_dbi(i).dbi_short_name;
         hr_utility.set_location('Required column '||sv_col(sv_c), 620);
      end if;
      if sv_dbi(i).dbi_name = 'CAEOY_RL1_TRANSMITTER_PACKAGE_TYPE' and
         sv_dbi(i).dbi_value is null then
         sv_c := sv_c + 1;
         sv_col(sv_c) := sv_dbi(i).dbi_short_name;
         hr_utility.set_location('Required column '||sv_col(sv_c), 621);
      end if;
      if sv_dbi(i).dbi_name = 'CAEOY_RL1_SOURCE_OF_SLIPS' and
         sv_dbi(i).dbi_value is null then
         sv_c := sv_c + 1;
         sv_col(sv_c) := sv_dbi(i).dbi_short_name;
         hr_utility.set_location('Required column '||sv_col(sv_c), 622);
      end if;
   end if;

   if sv_dbi(i).dbi_name = 'CAEOY_RL1_QUEBEC_BN' then
      sv_qin := sv_dbi(i).dbi_value;
      if sv_dbi(i).dbi_value is null then
         sv_c := sv_c + 1;
         --sv_col(sv_c) := sv_dbi(i).dbi_short_name;
         sv_col(sv_c) := get_lookup_meaning('L_QCID_NUMBER');
            hr_utility.set_location('Required column '||sv_col(sv_c), 650);
      else
         if length(sv_dbi(i).dbi_value) <> 16 then
            sv_m := sv_m + 1;
            sv_msg(sv_m) := get_lookup_meaning('R_QIN_LENGTH');
        hr_utility.set_location(sv_msg(sv_m)|| ' '||sv_dbi(i).dbi_value, 603);
         else
            for j in 1..length(sv_dbi(i).dbi_value)
            loop
            if ( j not in (  11, 12 ) ) then
               if instr('1234567890',substr(sv_dbi(i).dbi_value,j,1)) = 0 then
                  sv_m := sv_m + 1;
                  sv_msg(sv_m) := get_lookup_meaning('R_QIN_INVALID');
         hr_utility.set_location(sv_msg(sv_m)|| ' '||sv_dbi(i).dbi_value, 651);
                  exit;
               end if;
            else
               if instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ',
                  substr(sv_dbi(i).dbi_value,j,1)) = 0 then
                  sv_m := sv_m + 1;
                  sv_msg(sv_m) := get_lookup_meaning('R_QIN_INVALID');
          hr_utility.set_location(sv_msg(sv_m)|| ' '||sv_dbi(i).dbi_value, 652);
                  exit;
               end if;
            end if;
         end loop;
         end if;
      end if;
   end if;

   if sv_dbi(i).dbi_name = 'CAEOY_RL1_EMPLOYER_NAME' then
      sv_employer_name := sv_dbi(i).dbi_value;
      if sv_dbi(i).dbi_value is null then
         sv_c := sv_c + 1;
         sv_col(sv_c) := sv_dbi(i).dbi_short_name;
         hr_utility.set_location('Required column '||sv_col(sv_c), 653);
      end if;
   end if;

   if sv_dbi(i).dbi_name = 'CAEOY_RL1_EMPLOYER_CITY' then
      sv_employer_city := sv_dbi(i).dbi_value;
      if sv_dbi(i).dbi_value is null then
         sv_c := sv_c + 1;
         sv_col(sv_c) := sv_dbi(i).dbi_short_name;
         hr_utility.set_location('Required column '||sv_col(sv_c), 654);
      end if;
   end if;

   if sv_dbi(i).dbi_name = 'CAEOY_RL1_EMPLOYER_PROVINCE' then
      sv_employer_province := sv_dbi(i).dbi_value;
      if sv_dbi(i).dbi_value is null then
         sv_c := sv_c + 1;
         sv_col(sv_c) := sv_dbi(i).dbi_short_name;
         hr_utility.set_location('Required column '||sv_col(sv_c), 655);
      end if;
   end if;

   if sv_dbi(i).dbi_name = 'CAEOY_RL1_EMPLOYER_POSTAL_CODE' then
      sv_employer_postal_code := sv_dbi(i).dbi_value;
      if sv_dbi(i).dbi_value is null then
         sv_c := sv_c + 1;
         sv_col(sv_c) := sv_dbi(i).dbi_short_name;
         hr_utility.set_location('Required column '||sv_col(sv_c), 656);
      end if;
   end if;

   if sv_dbi(i).dbi_name = 'CAEOY_RL1_ACCOUNTING_CONTACT_NAME' and
         sv_dbi(i).dbi_value is null then
         sv_c := sv_c + 1;
         sv_col(sv_c) := sv_dbi(i).dbi_short_name;
         hr_utility.set_location('Required column '||sv_col(sv_c), 657);
   end if;

   if sv_dbi(i).dbi_name = 'CAEOY_RL1_ACCOUNTING_CONTACT_PHONE' and
         sv_dbi(i).dbi_value is null then
         sv_c := sv_c + 1;
         sv_col(sv_c) := sv_dbi(i).dbi_short_name;
         hr_utility.set_location('Required column '||sv_col(sv_c), 658);
   end if;

    if sv_dbi(i).dbi_name = 'CAEOY_TAXATION_YEAR' and
         sv_dbi(i).dbi_value is null then
         sv_c := sv_c + 1;
         sv_col(sv_c) := sv_dbi(i).dbi_short_name;
         hr_utility.set_location('Required column '||sv_col(sv_c), 659);
    end if;

    if sv_dbi(i).dbi_name = 'CAEOY_RL1_EMPLOYER_ADDRESS_LINE1' then
      sv_employer_address_line1 := sv_dbi(i).dbi_value;
      if sv_dbi(i).dbi_value is null then
         sv_m := sv_m + 1;
         sv_msg(sv_m) := get_lookup_meaning('R_MISSING_ADR');
      end if;
    end if;

     if sv_dbi(i).dbi_name = 'CAEOY_RL1_EMPLOYER_ADDRESS_LINE2' then
      sv_employer_address_line2 := sv_dbi(i).dbi_value;
     end if;

    end loop;

   end if; -- End if for sv_report_type in ('RL1','CAEOY_RL1_AMEND_PP')

   /* Start of RL2 Employer Validation */
   hr_utility.set_location('RL2 Employer validation', 699);
   if sv_report_type = 'RL2' then

     if sv_trans_y_n = 'Y' then

         if lr_rl2_transrec.TRANSMITTER_NUMBER is null then
            sv_c := sv_c + 1;
            sv_col(sv_c) := 'Transmitter Number';
            hr_utility.set_location('Required column '||sv_col(sv_c), 710);
         else
            if ( ( substr(lr_rl2_transrec.TRANSMITTER_NUMBER,1,2) <> 'NP' )  or
               ( length(lr_rl2_transrec.TRANSMITTER_NUMBER) <> 8 ) or
               ( not ( substr(lr_rl2_transrec.TRANSMITTER_NUMBER,3) >= '000000' ) and
               ( substr(lr_rl2_transrec.TRANSMITTER_NUMBER,3) <= '999999' ) ) )
            then
               sv_m := sv_m + 1;
               sv_msg(sv_m) := get_lookup_meaning('R_INVALID_TRANS_NO');
               hr_utility.set_location(sv_msg(sv_m)|| ' '||lr_rl2_transrec.TRANSMITTER_NUMBER, 711);
            end if;
         end if;

      if lr_rl2_transrec.TRANSMITTER_NAME is null then
         sv_c := sv_c + 1;
         sv_col(sv_c) := 'Transmitter Name';
            hr_utility.set_location('Required column '||sv_col(sv_c), 712);
      end if;

      if lr_rl2_transrec.TRANSMITTER_CITY is null then
         sv_c := sv_c + 1;
         sv_col(sv_c) := 'Transmitter City';
         hr_utility.set_location('Required column '||sv_col(sv_c), 713);
      end if;

      if lr_rl2_transrec.TRANSMITTER_PROVINCE is null then
         sv_c := sv_c + 1;
         sv_col(sv_c) := 'Transmitter Province';
         hr_utility.set_location('Required column '||sv_col(sv_c), 714);
      end if;

      if lr_rl2_transrec.TRANSMITTER_POSTAL_CODE is null then
         sv_c := sv_c + 1;
         sv_col(sv_c) := 'Transmitter Postal Code';
         hr_utility.set_location('Required column '||sv_col(sv_c), 715);
      end if;

      if lr_rl2_transrec.TRANSMITTER_TECH_CONTACT_NAME is null then
         sv_c := sv_c + 1;
         sv_col(sv_c) := 'Technical Contact Name';
         hr_utility.set_location('Required column '||sv_col(sv_c), 716);
      end if;

      if lr_rl2_transrec.TRANSMITTER_TECH_CONTACT_PHONE is null then
         sv_c := sv_c + 1;
         sv_col(sv_c) := 'Technical Contact Phone';
         hr_utility.set_location('Required column '||sv_col(sv_c), 717);
      end if;

      if lr_rl2_transrec.TRANSMITTER_TECH_CONTACT_CODE is null then
         sv_c := sv_c + 1;
         sv_col(sv_c) := 'Technical Contact Area Code';
         hr_utility.set_location('Required column '||sv_col(sv_c), 718);
      end if;

      if lr_rl2_transrec.TRANSMITTER_TECH_CONTACT_LANG is null then
         sv_c := sv_c + 1;
         sv_col(sv_c) := 'Technical Contact Language';
         hr_utility.set_location('Required column '||sv_col(sv_c), 719);
      end if;

      if lr_rl2_transrec.TRANSMITTER_PACKAGE_TYPE is null then
         sv_c := sv_c + 1;
         sv_col(sv_c) := 'Transmitter Package Type';
         hr_utility.set_location('Required column '||sv_col(sv_c), 720);
      end if;

      if lr_rl2_transrec.SOURCE_OF_SLIPS is null then
         sv_c := sv_c + 1;
         sv_col(sv_c) := 'Source of Slips';
         hr_utility.set_location('Required column '||sv_col(sv_c), 721);
      end if;

      if lr_rl2_transrec.TRANSMITTER_ADDRESS_LINE1 is null then
         sv_c := sv_c + 1;
         sv_col(sv_c) := 'Transmitter Address Line 1';
         hr_utility.set_location('Required column '||sv_col(sv_c), 722);
      end if;

   end if; -- end of sv_trans_y_n = 'Y'

      -- Quebec Business Number validation
      sv_qin := lr_rl2_transrec.QUEBEC_BUSINESS_NUMBER;
      if lr_rl2_transrec.QUEBEC_BUSINESS_NUMBER is null then
         sv_c := sv_c + 1;
         sv_col(sv_c) := get_lookup_meaning('L_QCID_NUMBER');
            hr_utility.set_location('Required column '||sv_col(sv_c), 750);
      else
         if length(lr_rl2_transrec.QUEBEC_BUSINESS_NUMBER) <> 16 then
            sv_m := sv_m + 1;
            sv_msg(sv_m) := get_lookup_meaning('R_QIN_LENGTH');
            hr_utility.set_location(sv_msg(sv_m)|| ' '||lr_rl2_transrec.QUEBEC_BUSINESS_NUMBER, 703);
         else
            for j in 1..length(lr_rl2_transrec.QUEBEC_BUSINESS_NUMBER)
            loop
             if ( j not in (  11, 12 ) ) then
                if instr('1234567890',substr(lr_rl2_transrec.QUEBEC_BUSINESS_NUMBER,j,1)) = 0 then
                  sv_m := sv_m + 1;
                  sv_msg(sv_m) := get_lookup_meaning('R_QIN_INVALID');
                  hr_utility.set_location(sv_msg(sv_m)|| ' '||lr_rl2_transrec.QUEBEC_BUSINESS_NUMBER, 751);
                  exit;
                end if;
             else
               if instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ',
                  substr(lr_rl2_transrec.QUEBEC_BUSINESS_NUMBER,j,1)) = 0 then
                  sv_m := sv_m + 1;
                  sv_msg(sv_m) := get_lookup_meaning('R_QIN_INVALID');
                  hr_utility.set_location(sv_msg(sv_m)|| ' '||lr_rl2_transrec.QUEBEC_BUSINESS_NUMBER, 752);
                  exit;
               end if;
             end if;
            end loop;
         end if;-- End if for length(lr_rl2_transrec.QUEBEC_BUSINESS_NUMBER)
      end if;   -- End if for lr_rl2_transrec.QUEBEC_BUSINESS_NUMBER is null


      sv_employer_name := lr_rl2_transrec.EMPLOYER_NAME;
      if lr_rl2_transrec.EMPLOYER_NAME is null then
         sv_c := sv_c + 1;
         sv_col(sv_c) := 'Employer Name';
         hr_utility.set_location('Required column '||sv_col(sv_c), 753);
      end if;

      sv_employer_city := lr_rl2_transrec.EMPLOYER_CITY;
      if lr_rl2_transrec.EMPLOYER_CITY is null then
         sv_c := sv_c + 1;
         sv_col(sv_c) := 'Employer City';
         hr_utility.set_location('Required column '||sv_col(sv_c), 754);
      end if;

      sv_employer_province := lr_rl2_transrec.EMPLOYER_PROVINCE;
      if lr_rl2_transrec.EMPLOYER_PROVINCE is null then
         sv_c := sv_c + 1;
         sv_col(sv_c) := 'Employer Province';
         hr_utility.set_location('Required column '||sv_col(sv_c), 755);
      end if;

      sv_employer_postal_code := lr_rl2_transrec.EMPLOYER_POSTAL_CODE;
      if lr_rl2_transrec.EMPLOYER_POSTAL_CODE is null then
         sv_c := sv_c + 1;
         sv_col(sv_c) := 'Employer Postal Code';
         hr_utility.set_location('Required column '||sv_col(sv_c), 756);
      end if;

      if lr_rl2_transrec.TRANSMITTER_ACCT_CONTACT_NAME is null then
         sv_c := sv_c + 1;
         sv_col(sv_c) := 'Accounting Contact Name';
         hr_utility.set_location('Required column '||sv_col(sv_c), 757);
      end if;

      if lr_rl2_transrec.TRANSMITTER_ACCT_CONTACT_PHONE is null then
         sv_c := sv_c + 1;
         sv_col(sv_c) := 'Accounting Contact Phone';
         hr_utility.set_location('Required column '||sv_col(sv_c), 758);
      end if;

      if lr_rl2_transrec.REPORTING_YEAR is null then
         sv_c := sv_c + 1;
         sv_col(sv_c) := 'Taxation Year';
         hr_utility.set_location('Required column '||sv_col(sv_c), 759);
      end if;

      sv_employer_address_line1 := lr_rl2_transrec.EMPLOYER_ADD_LINE1;
      if lr_rl2_transrec.EMPLOYER_ADD_LINE1 is null then
         sv_m := sv_m + 1;
         sv_msg(sv_m) := get_lookup_meaning('R_MISSING_ADR');
      end if;

      sv_employer_address_line2 := lr_rl2_transrec.EMPLOYER_ADD_LINE2;

   end if; -- end if for sv_report_type = 'RL2' then
   /* End of RL2 Employer Validation */

  end prov_employer_validation;

  /* The procedure fed_employee_validation validates the value of
     T4/T4A Employee */

  PROCEDURE fed_employee_validation is
  l_emp_first_name varchar2(240);
  l_emp_last_name  varchar2(240);
  lv_overlimit      number(1) := 0;
  lv_missing_adr    number(1) := 0;
  lv_multi_jurisdiction      number(2) := 0;
  lv_person_id      number(10) := 0;
  lv_asg_act_id     number(10) := 0;
  begin
    for i in sv_dbi.first..sv_dbi.last
    loop
hr_utility.set_location(to_char(i)||'. '||sv_dbi(i).dbi_name||' '||
     sv_dbi(i).dbi_value||' '||sv_dbi(i).dbi_short_name, 999 );
      if sv_dbi(i).dbi_name = 'CAEOY_PERSON_ID' then
         lv_person_id := to_number(sv_dbi(i).dbi_value);
      end if;

      if sv_dbi(i).dbi_name = 'CAEOY_EMPLOYEE_NUMBER' then
         sv_employee_no := sv_dbi(i).dbi_value;
      end if;

      if sv_dbi(i).dbi_name = 'CAEOY_EMPLOYEE_FIRST_NAME' then
         l_emp_first_name := sv_dbi(i).dbi_value;
         if l_emp_first_name is null then
            sv_c := sv_c + 1;
            sv_col(sv_c) := upper(sv_dbi(i).dbi_short_name);
            sv_print     := 1;
         end if;
      end if;
      if sv_dbi(i).dbi_name = 'CAEOY_EMPLOYEE_LAST_NAME' then
         l_emp_last_name := sv_dbi(i).dbi_value;
         if l_emp_last_name is null then
            sv_c := sv_c + 1;
            sv_col(sv_c) := upper(sv_dbi(i).dbi_short_name);
            sv_print     := 1;
         end if;
      end if;
      if sv_dbi(i).dbi_name = 'CAEOY_EMPLOYEE_ADDRESS_LINE1' and
         sv_dbi(i).dbi_value is null then
         if lv_missing_adr = 0 then
            sv_m := sv_m + 1;
            sv_msg(sv_m) := get_lookup_meaning('R_MISSING_ADR');
            sv_print     := 1;
            lv_missing_adr := 1;
         end if;
      end if;
      if sv_dbi(i).dbi_name = 'CAEOY_EMPLOYEE_CITY' and
         sv_dbi(i).dbi_value is null then
         if lv_missing_adr = 0 then
            sv_m := sv_m + 1;
            sv_msg(sv_m) := get_lookup_meaning('R_MISSING_ADR');
            sv_print     := 1;
            lv_missing_adr := 1;
         end if;
      end if;
      if sv_dbi(i).dbi_name = 'CAEOY_EMPLOYEE_PROVINCE' and
         sv_dbi(i).dbi_value is null then
         if lv_missing_adr = 0 then
            sv_m := sv_m + 1;
            sv_msg(sv_m) := get_lookup_meaning('R_MISSING_ADR');
            sv_print     := 1;
            lv_missing_adr := 1;
         end if;
      end if;
      if sv_dbi(i).dbi_name = 'CAEOY_EMPLOYEE_POSTAL_CODE' and
         sv_dbi(i).dbi_value is null then
         if lv_missing_adr = 0 then
            sv_m := sv_m + 1;
            sv_msg(sv_m) := get_lookup_meaning('R_MISSING_ADR');
            sv_print     := 1;
            lv_missing_adr := 1;
         end if;
      end if;
      if sv_dbi(i).dbi_name = 'CAEOY_EMPLOYEE_SIN' then
         sv_employee_sin  := substr(sv_dbi(i).dbi_value,1,3) ||' '||
                   substr(sv_dbi(i).dbi_value,4,3) ||' '||
                   substr(sv_dbi(i).dbi_value,7,3) ;
         if sv_dbi(i).dbi_value is null then
            sv_c := sv_c + 1;
            sv_col(sv_c) := upper(sv_dbi(i).dbi_short_name);
            sv_print     := 1;
         end if;
         if length(sv_dbi(i).dbi_value) <> 9 then
            sv_m := sv_m + 1;
            sv_msg(sv_m) := get_lookup_meaning('R_SIN_INVALID');
            sv_print     := 1;
         end if;
      end if;
      if sv_dbi(i).dbi_name = 'CAEOY_GROSS_EARNINGS_PER_JD_GRE_YTD' then
         sv_total_earnings  :=nvl(sv_total_earnings,0) + fnd_number.canonical_to_number(sv_dbi(i).dbi_value);
         --lv_multi_jurisdiction := lv_multi_jurisdiction + 1;
hr_utility.set_location('Multi Jurisdiction : '||
           to_char(lv_multi_jurisdiction), 999 );
      end if;
      if sv_dbi(i).dbi_name = 'CAEOY_CPP_EE_TAXABLE_PER_JD_GRE_YTD' then
         sv_pensionable_earnings  :=nvl(sv_pensionable_earnings,0) + fnd_number.canonical_to_number(sv_dbi(i).dbi_value);
      end if;
/* Commented because bug# 1701287
      --if sv_dbi(i).dbi_name = 'CAEOY_QPP_EE_TAXABLE_PER_JD_GRE_YTD' then
         --sv_pensionable_earnings  :=
      -- to_char(fnd_number.canonical_to_number(nvl(sv_pensionable_earnings,'0'),'999,999,990.00') +
       --fnd_number.canonical_to_number(sv_dbi(i).dbi_value),'999,999,990.00');
      --end if;
*/
      if sv_dbi(i).dbi_name = 'CAEOY_CPP_EE_WITHHELD_PER_JD_GRE_YTD' then
         sv_ded_reported_16  :=nvl(sv_ded_reported_16,0) + fnd_number.canonical_to_number(sv_dbi(i).dbi_value);
      end if;
/*
      if sv_dbi(i).dbi_name = 'CAEOY_QPP_EE_WITHHELD_PER_JD_GRE_YTD' then
         sv_ded_reported_16  :=
         to_char(fnd_number.canonical_to_number(nvl(sv_ded_reported_16,'0'),'999,999,990.00') +
         fnd_number.canonical_to_number(sv_dbi(i).dbi_value),'999,999,990.00');
      end if;
*/

/* bug 5552744 */

      if sv_dbi(i).dbi_name = 'CAEOY_EI_EE_TAXABLE_PER_JD_GRE_YTD' OR
         sv_dbi(i).dbi_name = 'CAEOY_EI_EE_WITHHELD_PER_JD_GRE_YTD' then

         select context into   sv_emp_jurisdiction
         from   ff_archive_item_contexts
         where  archive_item_id = sv_dbi(i).archive_item_id
            and context_id      = sv_context_id;

         hr_utility.trace('Emp JD is '||sv_emp_jurisdiction);

         if sv_emp_jurisdiction = 'QC' then

            if sv_dbi(i).dbi_name = 'CAEOY_EI_EE_TAXABLE_PER_JD_GRE_YTD' then
               sv_qc_insurable_earnings := nvl(sv_qc_insurable_earnings,0) + fnd_number.canonical_to_number(sv_dbi(i).dbi_value);
               hr_utility.trace('QC Insurable Earning : '|| sv_qc_insurable_earnings);
            end if;

            if sv_dbi(i).dbi_name = 'CAEOY_EI_EE_WITHHELD_PER_JD_GRE_YTD' then
               sv_qc_ded_reported_18 := nvl(sv_qc_ded_reported_18,0) + fnd_number.canonical_to_number(sv_dbi(i).dbi_value);
               hr_utility.trace('QC Withheld : '|| sv_qc_ded_reported_18);
            end if;

         else

            if sv_dbi(i).dbi_name = 'CAEOY_EI_EE_TAXABLE_PER_JD_GRE_YTD' then
               sv_insurable_earnings := nvl(sv_insurable_earnings,0) + fnd_number.canonical_to_number(sv_dbi(i).dbi_value);
               hr_utility.trace('FED Insurable Earning : '|| sv_insurable_earnings);
            end if;

            if sv_dbi(i).dbi_name = 'CAEOY_EI_EE_WITHHELD_PER_JD_GRE_YTD' then
               sv_ded_reported_18 := nvl(sv_ded_reported_18,0) + fnd_number.canonical_to_number(sv_dbi(i).dbi_value);
               hr_utility.trace('FED Withheld : '|| sv_ded_reported_18);
            end if;

         end if; /* 'QC' */

      end if;


/* bug 5552744 */
/*
      if sv_dbi(i).dbi_name = 'CAEOY_EI_EE_TAXABLE_PER_JD_GRE_YTD' then
         sv_insurable_earnings  := nvl(sv_insurable_earnings,0) + fnd_number.canonical_to_number(sv_dbi(i).dbi_value);
      end if;
      if sv_dbi(i).dbi_name = 'CAEOY_EI_EE_WITHHELD_PER_JD_GRE_YTD' then
         sv_ded_reported_18  :=nvl(sv_ded_reported_18,0) + fnd_number.canonical_to_number(sv_dbi(i).dbi_value);
      end if;
*/

      if sv_dbi(i).dbi_name = 'CAEOY_CPP_BASIC_EXEMPTION_PER_JD_GRE_YTD' then
         sv_cpp_basic_exemption  :=
         nvl(sv_cpp_basic_exemption,0) + fnd_number.canonical_to_number(sv_dbi(i).dbi_value);
      end if;
      if sv_dbi(i).dbi_name = 'CAEOY_CPP_EXEMPT_PER_JD_GRE_YTD' then
         sv_cpp_exempt_bal  :=
         nvl(sv_cpp_exempt_bal,0) + fnd_number.canonical_to_number(sv_dbi(i).dbi_value);
      end if;
      if sv_p_y = 'E' then
         if instr(sv_dbi(i).dbi_name, 'GRE_YTD') > 0  and
            fnd_number.canonical_to_number(nvl(sv_dbi(i).dbi_value,'0')) < 0
         then
             if ((sv_report_type = 'T4') or
                 (sv_report_type = 'CAEOY_T4_AMEND_PP')) then
                begin
                   select context
                   into   sv_emp_jurisdiction
                   from   ff_archive_item_contexts
                   where  archive_item_id = sv_dbi(i).archive_item_id
                   and    context_id      = sv_context_id;

                   exception
                   when others then
                   null;
                 end;
              end if;
              sv_nb := sv_nb + 1;
              if ((sv_report_type = 'T4') or
                  (sv_report_type = 'CAEOY_T4_AMEND_PP')) then
                 sv_neg_bal(sv_nb).dbi_name := sv_emp_jurisdiction;
              else
                 sv_neg_bal(sv_nb).dbi_name := sv_dbi(i).dbi_name;
              end if;
              sv_neg_bal(sv_nb).dbi_value :=
                   pay_us_employee_payslip_web.get_format_value(sv_b_g_id
		                                                ,fnd_number.canonical_to_number(sv_dbi(i).dbi_value));
              sv_neg_bal(sv_nb).dbi_short_name := sv_dbi(i).dbi_short_name;
              sv_print     := 1;
         end if;

         if (sv_dbi(i).dbi_name = 'CAEOY_T4A_NONBOX_FOOTNOTE') and
           (fnd_number.canonical_to_number(nvl(sv_dbi(i).dbi_value,'0')) < 0)  then

           sv_nb := sv_nb + 1;
           sv_neg_bal(sv_nb).dbi_name := sv_dbi(i).dbi_name;
           sv_neg_bal(sv_nb).dbi_value :=
             pay_us_employee_payslip_web.get_format_value(sv_b_g_id
		                                         ,fnd_number.canonical_to_number(sv_dbi(i).dbi_value));
           sv_neg_bal(sv_nb).dbi_short_name := sv_dbi(i).dbi_short_name;
           sv_print := 1;

         end if;

      end if;
   end loop;

   sv_employee_name := substr(l_emp_last_name,1,120)||', '||substr(l_emp_first_name,1,118); -- #2406070
     sv_cpp_ded_required := ((sv_pensionable_earnings - sv_cpp_exempt ) * sv_cpp_rate / 100 );

   if sv_cpp_ded_required  > sv_cpp_max_exempt  then
           sv_cpp_ded_required := sv_cpp_max_exempt;
      lv_overlimit        := 1;
   end if;

   if sv_cpp_ded_required < 0 then
        sv_cpp_ded_required := 0.00;
   end if;

/* bug 5552744 */

   sv_qc_ei_ded_required := (( sv_qc_insurable_earnings * sv_ppip_ei_rate )/ 100 );
   sv_qc_ei_max_exempt := ( ( sv_ei_max_earn ) * sv_ppip_ei_rate / 100 );

   sv_ei_ded_required := (( sv_insurable_earnings * sv_ei_rate )/ 100 );
   sv_ei_max_exempt := ( ( sv_ei_max_earn ) * sv_ei_rate / 100 );

   hr_utility.trace('QC EI Dedn Req. ' || sv_qc_ei_ded_required);
   hr_utility.trace('QC EI Max Exempt ' || sv_qc_ei_max_exempt);
   hr_utility.trace('QC EI Withheld ' || sv_qc_ded_reported_18);

   hr_utility.trace('FED EI Dedn Req. ' || sv_ei_ded_required);
   hr_utility.trace('FED EI Max Exempt ' || sv_ei_max_exempt);
   hr_utility.trace('FED EI Withheld ' || sv_ded_reported_18);

/* overlimit condition */
   if sv_ei_ded_required  > sv_ei_max_exempt  then
      sv_ei_ded_required := sv_ei_max_exempt;
      lv_overlimit        := 1;
   end if;

   if sv_qc_ei_ded_required  > sv_qc_ei_max_exempt  then
      sv_qc_ei_ded_required := sv_qc_ei_max_exempt;
      lv_overlimit        := 1;
   end if;

/* under withheld */
   if sv_ei_ded_required < 0 then
        sv_ei_deficiency    := sv_ded_reported_18 ;
   end if;

   if sv_qc_ei_ded_required < 0 then
        sv_qc_ei_deficiency    := sv_qc_ded_reported_18 ;
   end if;

/* difference */

   sv_qc_insurable_earnings := sv_qc_insurable_earnings;

   hr_utility.trace('sv_ei_ded_required : '|| sv_ei_ded_required);
   hr_utility.trace('sv_ded_reported_18 : '|| sv_ded_reported_18);
   hr_utility.trace('sv_insurable_earnings : '|| sv_insurable_earnings);

   hr_utility.trace('sv_qc_ei_ded_required : '|| sv_qc_ei_ded_required);
   hr_utility.trace('sv_qc_ded_reported_18 : '|| sv_qc_ded_reported_18);
   hr_utility.trace('sv_qc_insurable_earnings : '|| sv_qc_insurable_earnings);

   sv_ei_deficiency := sv_ei_ded_required - sv_ded_reported_18 ;
   sv_qc_ei_deficiency := sv_qc_ei_ded_required - sv_qc_ded_reported_18 ;

   hr_utility.trace('sv_ei_deficiency : '|| sv_ei_deficiency);
   hr_utility.trace('sv_qc_ei_deficiency : '|| sv_qc_ei_deficiency);

   if sv_ei_deficiency < 0 then
      sv_ei_deficiency := 0;
   end if;

   if sv_qc_ei_deficiency < 0 then
      sv_qc_ei_deficiency := 0;
   end if;

/* bug 5552744 */

/* Added by ssmukher for incorporating diff EI rate for employees working in  Quebec
   but belonging to Non Quebec province*/
/*
   if  sv_jurisdiction = 'QC' then
       sv_ei_ded_required := (( sv_insurable_earnings * sv_ppip_ei_rate )/ 100 );
   else
       sv_ei_ded_required := (( sv_insurable_earnings * sv_ei_rate )/ 100 );
   end if;

   if sv_jurisdiction = 'QC' then
      sv_ei_max_exempt := ( ( sv_ei_max_earn ) * sv_ppip_ei_rate / 100 );
   else
      sv_ei_max_exempt := ( ( sv_ei_max_earn ) * sv_ei_rate / 100 );
   end if;

   if sv_ei_ded_required  > sv_ei_max_exempt  then
      sv_ei_ded_required := sv_ei_max_exempt;
      lv_overlimit        := 1;
   end if;

   if sv_ei_ded_required < 0 then
        sv_ei_deficiency    := sv_ded_reported_18 ;
   end if;
*/

   /*  sv_cpp_qpp_deficiency :=
            to_char( (fnd_number.canonical_to_number(sv_ded_reported_16,'999,999,990.00')
            - sv_cpp_ded_required ),'999,990.00');

     sv_ei_deficiency      :=
            to_char( (fnd_number.canonical_to_number(sv_ded_reported_18,'999,999,990.00')
            - sv_ei_ded_required ),'999,990.00');
   */

   sv_cpp_qpp_deficiency := (sv_cpp_ded_required - sv_ded_reported_16);

   /* The deficiency fields should not display over-payments */

   if sv_cpp_qpp_deficiency < 0 then
      sv_cpp_qpp_deficiency := 0;
   end if;

   if  sv_nb > 0  then
      sv_m := sv_m + 1;
      sv_msg(sv_m) := get_lookup_meaning('R_NEG_BAL');
      sv_print     := 1;
   end if;
   if  lv_overlimit > 0  then
      sv_m := sv_m + 1;
      sv_msg(sv_m) := get_lookup_meaning('R_OVERLIMIT_BAL');
      sv_print     := 1;
   end if;
   --if  lv_multi_jurisdiction > 1  then
   if  get_multi_jd(lv_person_id) > 1  and sv_p_y = 'E' then
      sv_m := sv_m + 1;
      sv_msg(sv_m) := get_lookup_meaning('R_EMP_MULTI_JD');
      sv_print     := 1;
   end if;
   if sv_p_y = 'P' then
      /* When option is PIER Report, the following messages should print
                   if they fullfill their conditions except Negative Balance. */
      sv_nb := 0;
      sv_m  := 0;
      sv_c  := 0;
      sv_print     := 0;
      sv_msg.delete;
      sv_col.delete;
      sv_neg_bal.delete;
   end if;

/*   if ( ( fnd_number.canonical_to_number( sv_cpp_qpp_deficiency, '999,990.00') < 0 and
          abs(fnd_number.canonical_to_number( sv_cpp_qpp_deficiency, '999,990.00')) > 1 ) or
        ( fnd_number.canonical_to_number( sv_ei_deficiency, '999,990.00') < 0 and
          abs(fnd_number.canonical_to_number( sv_ei_deficiency, '999,990.00')) > 1 ) ) then
*/

   if ( (sv_cpp_qpp_deficiency > 1) or (sv_ei_deficiency > 1) or (sv_qc_ei_deficiency > 1)) then

      sv_print := 1;

      if to_number(sv_reporting_year) -
         to_number(to_char(sv_date_of_birth,'YYYY') ) = 18 then
         sv_m := sv_m + 1;
         sv_msg(sv_m) := get_lookup_meaning('R_EMP_TURNED_18');
      end if;
      if to_number(sv_reporting_year) -
         to_number(to_char(sv_date_of_birth,'YYYY') ) = 70 then
         sv_m := sv_m + 1;
         sv_msg(sv_m) := get_lookup_meaning('R_EMP_TURNED_70');
      end if;
      if sv_reporting_year = to_char(sv_hire_date,'YYYY')  then
         sv_m := sv_m + 1;
         sv_msg(sv_m) := get_lookup_meaning('R_EMP_HIRED');
      end if;
      if sv_reporting_year = to_char(sv_terminate_date,'YYYY')  then
         sv_m := sv_m + 1;
         sv_msg(sv_m) := get_lookup_meaning('R_EMP_TERMINATED');
      end if;

      if sv_p_y = 'P' then

         if ( sv_cpp_block = 'Y' ) then
            sv_m := sv_m + 1;
            sv_msg(sv_m) := get_lookup_meaning('R_CPP_BLOCK');
         end if;

         if ( sv_ei_block = 'Y' ) then
            sv_m := sv_m + 1;
            sv_msg(sv_m) := get_lookup_meaning('R_EI_BLOCK');
         end if;

      end if;

   end if;

   if sv_p_y = 'E' then

      if ( sv_cpp_block = 'Y' ) then
         sv_m := sv_m + 1;
         sv_msg(sv_m) := get_lookup_meaning('R_CPP_BLOCK');
         sv_print     := 1;
      end if;

      if ( sv_ei_block = 'Y' ) then
         sv_m := sv_m + 1;
         sv_msg(sv_m) := get_lookup_meaning('R_EI_BLOCK');
         sv_print     := 1;
      end if;

   end if;

  end fed_employee_validation;

  /* The procedure fed_employer_validation validates the value of
     T4/T4A Employer */

  PROCEDURE fed_employer_validation (    p_dbi_name in varchar2,
               p_dbi_value in varchar2,
               p_dbi_short_name in varchar2) is
  begin
     --hr_utility.set_location(p_dbi_short_name, 201);
   if sv_trans_y_n = 'Y' then
      if p_dbi_name = 'CAEOY_TRANSMITTER_NUMBER' then
         if p_dbi_value is null then
            sv_c := sv_c + 1;
            sv_col(sv_c) := p_dbi_short_name;
            hr_utility.set_location('Required column '||sv_col(sv_c), 210);
         else
            if ( ( substr(p_dbi_value,1,2) <> 'MM' )  or
               ( length(p_dbi_value) <> 8 ) or
               ( not ( substr(p_dbi_value,3) >= '000000' ) and
               ( substr(p_dbi_value,3) <= '999999' ) ) )
            then
               sv_m := sv_m + 1;
               sv_msg(sv_m) := get_lookup_meaning('R_INVALID_TRANS_NO');
               hr_utility.set_location(sv_msg(sv_m)|| ' '||p_dbi_value, 211);
            end if;
         end if;
      end if;
      if p_dbi_name = 'CAEOY_TRANSMITTER_NAME' and
         p_dbi_value is null then
         sv_c := sv_c + 1;
         sv_col(sv_c) := p_dbi_short_name;
         hr_utility.set_location('Required column '||sv_col(sv_c), 212);
      end if;
      if p_dbi_name = 'CAEOY_TRANSMITTER_CITY' and
         p_dbi_value is null then
         sv_c := sv_c + 1;
         sv_col(sv_c) := p_dbi_short_name;
         hr_utility.set_location('Required column '||sv_col(sv_c), 213);
      end if;
      if p_dbi_name = 'CAEOY_TRANSMITTER_PROVINCE' and
         p_dbi_value is null then
         sv_c := sv_c + 1;
         sv_col(sv_c) := p_dbi_short_name;
         hr_utility.set_location('Required column '||sv_col(sv_c), 214);
      end if;
      if p_dbi_name = 'CAEOY_TRANSMITTER_POSTAL_CODE' and
         p_dbi_value is null then
         sv_c := sv_c + 1;
         sv_col(sv_c) := p_dbi_short_name;
          hr_utility.set_location('Required column '||sv_col(sv_c), 215);
      end if;
      if p_dbi_name = 'CAEOY_TECHNICAL_CONTACT_NAME' and
         p_dbi_value is null then
         sv_c := sv_c + 1;
         sv_col(sv_c) := p_dbi_short_name;
         hr_utility.set_location('Required column '||sv_col(sv_c), 216);
      end if;
      if p_dbi_name = 'CAEOY_TECHNICAL_CONTACT_PHONE' and
         p_dbi_value is null then
         sv_c := sv_c + 1;
         sv_col(sv_c) := p_dbi_short_name;
         hr_utility.set_location('Required column '||sv_col(sv_c), 217);
      end if;
      if p_dbi_name = 'CAEOY_TECHNICAL_CONTACT_AREA_CODE' and
         p_dbi_value is null then
         sv_c := sv_c + 1;
         sv_col(sv_c) := p_dbi_short_name;
         hr_utility.set_location('Required column '||sv_col(sv_c), 218);
      end if;
      if p_dbi_name = 'CAEOY_TECHNICAL_CONTACT_LANGUAGE' and
         p_dbi_value is null then
         sv_c := sv_c + 1;
         sv_col(sv_c) := p_dbi_short_name;
         hr_utility.set_location('Required column '||sv_col(sv_c), 219);
      end if;
      if p_dbi_name = 'CAEOY_TRANSMITTER_TYPE_INDICATOR' and
         p_dbi_value is null then
         sv_c := sv_c + 1;
         sv_col(sv_c) := p_dbi_short_name;
         hr_utility.set_location('Required column '||sv_col(sv_c), 220);
      end if;
   end if;
   if p_dbi_name = 'CAEOY_EMPLOYER_IDENTIFICATION_NUMBER' then
      sv_busi_no := p_dbi_value;
      if p_dbi_value is null then
         sv_c := sv_c + 1;
         sv_col(sv_c) := p_dbi_short_name;
         hr_utility.set_location('Required column '||sv_col(sv_c), 250);
      else
         if length(p_dbi_value) <> 15 then
            sv_m := sv_m + 1;
            sv_msg(sv_m) := get_lookup_meaning('R_BN_LENGTH');
            hr_utility.set_location(sv_msg(sv_m)|| ' '||p_dbi_value, 203);
         else
            for i in 1..length(p_dbi_value)
            loop
            if ( i not in (  10, 11 ) ) then
               if instr('1234567890',substr(p_dbi_value,i,1)) = 0 then
                  sv_m := sv_m + 1;
                  sv_msg(sv_m) := get_lookup_meaning('R_BN_INVALID');
                  hr_utility.set_location(sv_msg(sv_m)|| ' '||p_dbi_value, 251);
                  exit;
               end if;
            else
               if instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ',substr(p_dbi_value,i,1)) =
                  0 then
                  sv_m := sv_m + 1;
                  sv_msg(sv_m) := get_lookup_meaning('R_BN_INVALID');
                  hr_utility.set_location(sv_msg(sv_m)|| ' '||p_dbi_value, 252);
                  exit;
               end if;
            end if;

            end loop;
          end if;
      end if;
   end if;
   if p_dbi_name = 'CAEOY_EMPLOYER_NAME' then
      sv_employer_name := p_dbi_value;
      if p_dbi_value is null then
      sv_c := sv_c + 1;
      sv_col(sv_c) := p_dbi_short_name;
         hr_utility.set_location('Required column '||sv_col(sv_c), 253);
      end if;
   end if;
   if p_dbi_name = 'CAEOY_EMPLOYER_CITY' then
      sv_employer_city := p_dbi_value;
      if p_dbi_value is null then
      sv_c := sv_c + 1;
      sv_col(sv_c) := p_dbi_short_name;
         hr_utility.set_location('Required column '||sv_col(sv_c), 254);
      end if;
   end if;
   if p_dbi_name = 'CAEOY_EMPLOYER_PROVINCE' then
      sv_employer_province := p_dbi_value;
      if p_dbi_value is null then
      sv_c := sv_c + 1;
      sv_col(sv_c) := p_dbi_short_name;
         hr_utility.set_location('Required column '||sv_col(sv_c), 255);
      end if;
   end if;
   if p_dbi_name = 'CAEOY_EMPLOYER_POSTAL_CODE' then
      sv_employer_postal_code := p_dbi_value;
      if p_dbi_value is null then
      sv_c := sv_c + 1;
      sv_col(sv_c) := p_dbi_short_name;
         hr_utility.set_location('Required column '||sv_col(sv_c), 256);
      end if;
   end if;
   if p_dbi_name = 'CAEOY_ACCOUNTING_CONTACT_NAME' and
      p_dbi_value is null then
      sv_c := sv_c + 1;
      sv_col(sv_c) := p_dbi_short_name;
      hr_utility.set_location('Required column '||sv_col(sv_c), 257);
   end if;
   if p_dbi_name = 'CAEOY_ACCOUNTING_CONTACT_PHONE' and
      p_dbi_value is null then
      sv_c := sv_c + 1;
      sv_col(sv_c) := p_dbi_short_name;
      hr_utility.set_location('Required column '||sv_col(sv_c), 258);
   end if;
   if p_dbi_name = 'CAEOY_TAXATION_YEAR' and
      p_dbi_value is null then
      sv_c := sv_c + 1;
      sv_col(sv_c) := p_dbi_short_name;
      hr_utility.set_location('Required column '||sv_col(sv_c), 259);
   end if;
   /*
   if p_dbi_name = 'CAEOY_FEDERAL_YOUTH_HIRE_PROGRAM_INDICATOR' and
      p_dbi_value is null then
      sv_c := sv_c + 1;
      sv_col(sv_c) := p_dbi_short_name;
      hr_utility.set_location('Required column '||sv_col(sv_c), 260);

   end if;
   */
   if p_dbi_name = 'CAEOY_EMPLOYER_ADDRESS_LINE1' then
      sv_employer_address_line1 := p_dbi_value;
      if p_dbi_value is null then
         sv_m := sv_m + 1;
         sv_msg(sv_m) := get_lookup_meaning('R_MISSING_ADR');
      end if;
   end if;
   if p_dbi_name = 'CAEOY_EMPLOYER_ADDRESS_LINE2' then
      sv_employer_address_line2 := p_dbi_value;
   end if;
  end fed_employer_validation;

  /* The procedure provincial_process is executed when user has selected option
     Provincial. This procedure is called from the main procedure pier_yeer.*/

  PROCEDURE provincial_process ( fp_pre in number, fp_b_g_id in number) is

  /* The cursor cur_rl_pay_act retrieves archived payroll_action_id(PACTID).
     If Prov Reporting Establishment(PRE) is selected, this cursor selects
     PACTID for that PRE otherwise it selects all PACTID for all archived
     PRE */

    -- Need to modify the cursor cur_rl_pay_act to enable RL2 PRE (Modified)
    cursor cur_rl_pay_act is
    select  ppa.payroll_action_id ,
            hoi.org_information1 business_number,
            hou.organization_id,
            hou.name,
            ppa.payroll_id,
            ppa.effective_date,
            ppa.report_type,
            hoi.org_information2
    from    hr_organization_information hoi,
            hr_all_organization_units hou,
            pay_payroll_actions ppa
    where hou.business_group_id  = fp_b_g_id
    and   hoi.organization_id = hou.organization_id
    and   hoi.org_information_context = 'Prov Reporting Est'
    and   ppa.business_group_id = fp_b_g_id
    and   hoi.organization_id =
          pycadar_pkg.get_parameter('PRE_ORGANIZATION_ID',
                                    ppa.legislative_parameters)
    and   pycadar_pkg.get_parameter('PRE_ORGANIZATION_ID',
                                    ppa.legislative_parameters) =
          nvl(to_char(fp_pre),pycadar_pkg.get_parameter('PRE_ORGANIZATION_ID',
                                                        ppa.legislative_parameters))
    and   ppa.report_type in ('RL1', 'CAEOY_RL1_AMEND_PP','RL2')
    and   ppa.action_status = 'C'
    and   to_char(ppa.effective_date,'YYYY') = sv_reporting_year
    and   to_char(ppa.effective_date,'DD-MM') = '31-12'
    order by hou.organization_id, ppa.payroll_action_id;

   /* The cursor cur_rl_trans_y_n is used to verify whether retrieved GRE is
      the type of transmitter or not */

   cursor cur_rl_trans_y_n ( cp_org_id in number,
          cp_qin    in varchar2 ) is
   select 'Y'
   from hr_organization_information
   where organization_id = cp_org_id
   and   org_information2 = cp_qin
   and   org_information3 = 'Y'
   and   org_information_context = 'Prov Reporting Est';

   /* The cursor cur_rl_dbi retrieves archive items and its value depending on
      context ( PACTID or ASGACTID) */

    cursor cur_rl_dbi ( cp_context in number ) is
    select    distinct rtrim(ltrim(fdi.user_name)),
    rtrim(ltrim(fai.value)),
      initcap(rtrim(ltrim(replace(replace(replace(replace(replace(replace(
      fdi.user_name,'CAEOY'),'RL1_'),'PER_YTD'),'PER_JD_YTD'),'EMPLOYEE_'),
      '_',' ')))) req_col
    from   ff_database_items fdi
          ,ff_archive_items fai
    where  fai.user_entity_id = fdi.user_entity_id
    and    fai.context1 = to_char(cp_context)
    and    fdi.user_name like 'CAEOY%';

   /* The cursor cur_rl_cpp_periods retrives the QPP periods for an Employee. */

   cursor cur_rl_cpp_periods ( cp_payroll_id in number ) is
   select    count(regular_payment_date)
   from     per_time_periods target
   where    payroll_id     = cp_payroll_id
   and     to_char( target.regular_payment_date,'YYYY' ) = sv_reporting_year;

   /* The cursor cur_rl_asg_act retrieves all assignment action ids for input
      PACTID that have not been amended. Added sort option to fix bug#3977930 */

   cursor cur_rl_asg_act (cp_pactid in number) is
   select paa.assignment_action_id,
          paa.assignment_id,
          paa.serial_number person_id,
          paa.action_status
   from  pay_assignment_actions paa,
         pay_payroll_actions    ppa,
         per_all_people_f ppf
   where paa.payroll_action_id = cp_pactid
   and   ppa.payroll_action_id = paa.payroll_action_id
   and   ppa.business_group_id = fp_b_g_id
   and not exists
   (select 1
    from pay_assignment_actions paa_amend,
         pay_payroll_actions    ppa_amend
    where paa_amend.payroll_action_id > cp_pactid
    and   paa.serial_number = paa_amend.serial_number
    and   ppa_amend.payroll_action_id = paa_amend.payroll_action_id
    and   ppa_amend.report_type = 'CAEOY_RL1_AMEND_PP'
    and   ppa_amend.business_group_id = fp_b_g_id
    and   ppa_amend.action_status     = 'C'
    and   pycadar_pkg.get_parameter('PRE_ORGANIZATION_ID',ppa.legislative_parameters) =
          pycadar_pkg.get_parameter('PRE_ORGANIZATION_ID',ppa_amend.legislative_parameters)
    and   to_char(ppa_amend.effective_date,'YYYY') = sv_reporting_year
    and   to_char(ppa_amend.effective_date,'YYYY') = to_char(ppa.effective_date,'YYYY')
    and   to_char(ppa_amend.effective_date,'DD-MM') = '31-12'
    and   to_char(ppa_amend.effective_date,'DD-MM') = to_char(ppa.effective_date,'DD-MM'))
    and exists
    (select 1
     from per_assignments_f paf
     where paf.assignment_id = paa.assignment_id
     and paf.effective_start_date <= ppa.effective_date
     and paf.effective_end_date   >= trunc(ppa.effective_date,'Y')
	)
    and ppf.person_id = paa.serial_number
    and ppf.effective_start_date <= ppa.effective_date
    and ppf.effective_end_date   >= trunc(ppa.effective_date,'Y')
    order by ppf.last_name,ppf.first_name,ppf.middle_names;


    /* The cursor cur_rl_dob retrieves the Birth Date and Hired Date
      for an employee. */

   cursor  cur_rl_dob ( cp_person_id in number,
                        cp_effective_date in date ) is
   select  ppf.date_of_birth,
           ppf.original_date_of_hire
   from    per_all_people_f ppf
   where   ppf.person_id = cp_person_id
   and     cp_effective_date between ppf.effective_start_date
           and     ppf.effective_end_date;

   /* The cursor cur_rl_dob retrieves the termination Date if any.*/

   cursor   cur_rl_terminate ( cp_person_id in number ) is
   select   actual_termination_date
   from     per_periods_of_service
   where    person_id = cp_person_id
   and      actual_termination_date is not null;

   /* The cursor cur_rl_qpp_block is used to verify whether an employee has
      QPP Block or not. */

   cursor cur_rl_qpp_block (cp_bg_id in number,
                            cp_person_id in number,
                            cp_effective_date in date ) is
   select    qpp_exempt_flag
   from      per_all_assignments_f paaf,
             pay_ca_emp_prov_tax_info_f pcefti
   where     paaf.person_id = cp_person_id
   and       to_char(cp_effective_date,'YYYY') between
             to_char(paaf.effective_start_date,'YYYY') and
                    to_char(paaf.effective_end_date, 'YYYY' )
   and       pcefti.assignment_id = paaf.assignment_id
   and       pcefti.business_group_id+0 = cp_bg_id
   and       to_char(cp_effective_date,'YYYY')  between
                    to_char(pcefti.effective_start_date,'YYYY') and
                    to_char(pcefti.effective_end_date,'YYYY')
   and       pcefti.qpp_exempt_flag = 'Y';

      /* The cursor cur_rl1_qpip_block is used to verify whether an employee has
      PPIP Block or not. */

   cursor cur_rl_qpip_block (cp_bg_id in number,
                              cp_person_id in number,
                              cp_effective_date in date ) is
   select    ppip_exempt_flag
   from      per_all_assignments_f paaf,
             pay_ca_emp_prov_tax_info_f pcefti
   where     paaf.person_id = cp_person_id
   and       to_char(cp_effective_date,'YYYY') between
             to_char(paaf.effective_start_date,'YYYY') and
                    to_char(paaf.effective_end_date, 'YYYY' )
   and       pcefti.assignment_id = paaf.assignment_id
   and       pcefti.business_group_id+0 = cp_bg_id
   and       to_char(cp_effective_date,'YYYY')  between
                    to_char(pcefti.effective_start_date,'YYYY') and
                    to_char(pcefti.effective_end_date,'YYYY')
   and       pcefti.ppip_exempt_flag = 'Y';

   cursor cur_rl_tax_unit_id( cp_asg_id in number ) is
   select nvl(hsck.segment1, hsck.segment11)
   from   per_all_assignments_f paf,
          hr_soft_coding_keyflex hsck
   where  paf.assignment_id = cp_asg_id
   and    add_months(trunc(to_date(sv_reporting_year,'YYYY'),'Y'),12)-1 between
               paf.effective_start_date and paf.effective_end_date
   and    hsck.soft_coding_keyflex_id = paf.soft_coding_keyflex_id;

   /* Cursor to get the RL2 Transmitter and Employer Info */
   CURSOR cur_rl2_transmitter(cp_bg_id number,
                              cp_pact_id number) IS
   select * from PAY_CA_EOY_RL2_TRANS_INFO_V
   where business_group_id = cp_bg_id
   and payroll_action_id = cp_pact_id;

   /* Cursor to get the RL2 Employee Info */
   CURSOR cur_rl2_employee(cp_bg_id number,
                           cp_asgact_id number) IS
   select * from PAY_CA_EOY_RL2_EMPLOYEE_INFO_V
   where business_group_id = cp_bg_id
   and assignment_action_id = cp_asgact_id;

   cursor cur_rl_nonbox_footnote(cp_asgact_id number) is
   select pai.action_information5,
          flv.meaning,
          'CAEOY_RL1_NONBOX_FOOTNOTE'
   from pay_action_information pai,
        fnd_lookup_types  flt,
        fnd_lookup_values flv
   where pai.action_context_id = cp_asgact_id
   and   pai.action_context_type = 'AAP'
   and   pai.jurisdiction_code   = 'QC'
   and   pai.action_information_category = 'CA FOOTNOTES'
   and   pai.action_information6 = 'RL1'
   and   flt.lookup_type  = 'PAY_CA_RL1_NONBOX_FOOTNOTES'
   and   flv.lookup_type  = flt.lookup_type
   and   flv.language     = userenv('LANG')
   and   flv.enabled_flag = 'Y'
   and   flv.lookup_code  = pai.action_information4;

   l_print_y_n  number(1) := 0;
   l_transmitter_y_n  char(1);

   l_payroll_action_id number(20);
   l_first_employee    number(20);
   l_business_number   varchar2(180);
   l_org_id            number(20);
   l_pre_name          varchar2(180);
   l_payroll_id        number(9);
   l_effective_date    date;

   l_dbi_name         varchar2(240);
   l_dbi_value        varchar2(240);
   l_dbi_short_name   varchar2(240);

   l_assignment_action_id number(15);
   l_assignment_id        number(10);
   l_person_id            varchar2(30);
   l_action_status        varchar2(1);
   l_tax_unit_id          varchar2(60);
   i  number(3);

  begin

     open cur_rl_pay_act;
     loop
       fetch cur_rl_pay_act into
              l_payroll_action_id,
              l_business_number,
              l_org_id,
              l_pre_name,
              l_payroll_id,
              l_effective_date,
              sv_report_type,
              sv_qin;

       exit when cur_rl_pay_act%notfound;

       hr_utility.set_location('PACTID  ' || to_char(l_payroll_action_id), 510);
       hr_utility.set_location('ORG ID  ' || to_char(l_org_id), 520);
       hr_utility.set_location('BUSI NO.  ' || l_business_number, 530);
       hr_utility.set_location('PRE NAME  ' || l_pre_name, 540);
       hr_utility.set_location('QIN ' || sv_qin, 550);

       sv_busi_no := l_business_number;
       sv_pre_name := l_pre_name;

       l_transmitter_y_n := 'N';

       open cur_rl_trans_y_n(l_org_id, sv_qin);
       fetch cur_rl_trans_y_n into l_transmitter_y_n;
       close cur_rl_trans_y_n;

       sv_trans_y_n := l_transmitter_y_n;
       hr_utility.set_location('Transmitter ?  ' || sv_trans_y_n, 550);

       if (sv_report_type <> 'CAEOY_RL1_AMEND_PP') then

         if sv_p_y = 'E' then

            initialize_static_var('R');

            /* Added for RL2 Exception Report */
            if sv_report_type = 'RL2' then

               open cur_rl2_transmitter(fp_b_g_id,l_payroll_action_id);
               i := 0;
               fetch cur_rl2_transmitter into lr_rl2_transrec;
               if cur_rl2_transmitter%FOUND then
                  i := 1;
               end if;
               close cur_rl2_transmitter;

            else
              open cur_rl_dbi(l_payroll_action_id);

              hr_utility.set_location(' Cursor DBI Before Validation ', 560);
              i := 0;
              loop
               fetch cur_rl_dbi into l_dbi_name,
                                     l_dbi_value,
                                     l_dbi_short_name;
               exit when cur_rl_dbi%notfound;

               i := i + 1;
               sv_dbi(i).dbi_name  := l_dbi_name;
               sv_dbi(i).dbi_value := l_dbi_value;
               sv_dbi(i).dbi_short_name := l_dbi_short_name;
              end loop;

              hr_utility.set_location(' Cursor DBI After Validation ', 570);
              close cur_rl_dbi;

            end if;  /* End of RL2 report type validation */

             if i <> 0 then
                prov_employer_validation;
                employer_header;
                print_employer;
             end if;

          end if; /* end of validation sv_p_y = 'E' */

        end if;  /* end of sv_report_type validation */

        open  cur_rl_cpp_periods(l_payroll_id);
        fetch cur_rl_cpp_periods into sv_no_of_cpp_periods;
        close cur_rl_cpp_periods;

        l_first_employee := 0;

        open cur_rl_asg_act(l_payroll_action_id);
        loop
           fetch cur_rl_asg_act into  l_assignment_action_id,
                                      l_assignment_id,
                                      l_person_id,
                                      l_action_status;
            exit when cur_rl_asg_act%notfound;

            if l_first_employee = 0 then
               employee_header;
               l_first_employee := 1;
            end if;

            sv_asg_id := l_assignment_id;

            initialize_static_var('E');

            hr_utility.set_location(' CUR_TAX_UNIT_ID', 587 );

            open  cur_rl_tax_unit_id( l_assignment_id );
            fetch cur_rl_tax_unit_id into l_tax_unit_id;
            close cur_rl_tax_unit_id;

            sv_gre := l_tax_unit_id;

            hr_utility.set_location(' CUR_DOB', 588 );

            open  cur_rl_dob( l_person_id, l_effective_date);
            fetch cur_rl_dob into sv_date_of_birth, sv_hire_date;
            close cur_rl_dob;

            hr_utility.set_location('CUR_TERMINATE',577);

            open  cur_rl_terminate( l_person_id);
            fetch cur_rl_terminate into sv_terminate_date;
            close cur_rl_terminate;

            hr_utility.set_location('CUR_QPP_BLOCK',566);

            open  cur_rl_qpp_block(fp_b_g_id, l_person_id, l_effective_date);
            fetch cur_rl_qpp_block into sv_cpp_block;
            close cur_rl_qpp_block;

            hr_utility.set_location('CUR_PPIP_BLOCK',566);

            open  cur_rl_qpip_block(fp_b_g_id, l_person_id, l_effective_date);
            fetch cur_rl_qpip_block into sv_ppip_block;
            close cur_rl_qpip_block;

            hr_utility.set_location('CUR_DBI',555);

            if sv_report_type = 'RL2' then

              open cur_rl2_employee(fp_b_g_id,
                                    l_assignment_action_id);
              fetch cur_rl2_employee into lr_rl2_emprec;

              if cur_rl2_employee%FOUND then
		    i := 1;
	      end if;

	      close cur_rl2_employee;

	    else

              open cur_rl_dbi(l_assignment_action_id);
              hr_utility.set_location(' Cursor Assignment actions '||to_char(l_assignment_action_id), 199);
              i := 0;
              loop
                fetch cur_rl_dbi into l_dbi_name,
                                     l_dbi_value,
                                     l_dbi_short_name;
                exit when cur_rl_dbi%notfound;

                i := i + 1;
                sv_dbi(i).dbi_name  := l_dbi_name;
                sv_dbi(i).dbi_value := l_dbi_value;
                sv_dbi(i).dbi_short_name := l_dbi_short_name;

              end loop;
              close cur_rl_dbi;

              open cur_rl_nonbox_footnote(l_assignment_action_id);
              loop
                fetch cur_rl_nonbox_footnote into l_dbi_value,
                                                  l_dbi_short_name,
                                                  l_dbi_name;
                exit when cur_rl_nonbox_footnote%notfound;

                i := i + 1;
                sv_dbi(i).dbi_name  := l_dbi_name;
                sv_dbi(i).dbi_value := l_dbi_value;
                sv_dbi(i).dbi_short_name := l_dbi_short_name;

              end loop;
              close cur_rl_nonbox_footnote;

            end if; /* End of sv_report_type = 'RL2' */


            if i <> 0 then
               prov_employee_validation;
               if sv_print = 1 then
                  print_employee;
               end if;
            end if;

         end loop;
         close  cur_rl_asg_act;

         format_data('</table>');

      end loop;
      close cur_rl_pay_act;

  end provincial_process;

  /* The procedure federal_process is executed when user has selected option
     Federal. This procedure is called from the main procedure pier_yeer.*/

  PROCEDURE federal_process ( fp_gre in number, fp_b_g_id in number) is

  /* The cursor cur_pay_act retrieves archived payroll_action_id(PACTID).
     If GRE is selected, this cursor selects PACTID for that GRE otherwise
     it selects all PACTID for all archived GRE */

   cursor cur_pay_act is
   select  ppa.payroll_action_id ,
           hoi.org_information1 business_number,
           hou.organization_id,
           hou.name,
           ppa.payroll_id,
           ppa.effective_date,
           ppa.report_type
   from    hr_organization_information hoi,
           hr_all_organization_units hou,
           pay_payroll_actions ppa
   where   hou.business_group_id  = fp_b_g_id
   and     hoi.organization_id = hou.organization_id
   and     hoi.org_information_context = 'Canada Employer Identification'
   and     ppa.business_group_id = fp_b_g_id
   and     hoi.organization_id = pycadar_pkg.get_parameter('TRANSFER_GRE',
                                 ppa.legislative_parameters )
   and   ( ( hoi.organization_id = fp_gre ) OR
           ( fp_gre is null  and hoi.organization_id = hoi.organization_id ))
   and   ( ( ppa.report_type in ('T4', 'CAEOY_T4_AMEND_PP', 'T4A', 'CAEOY_T4A_AMEND_PP' ) and sv_p_y = 'E' ) or
           ( ppa.report_type in ('T4', 'CAEOY_T4_AMEND_PP') and sv_p_y = 'P' ) )
   and   ppa.action_status = 'C'
   and   to_char(ppa.effective_date,'YYYY') = sv_reporting_year
   and   to_char(ppa.effective_date,'DD-MM') = '31-12'
   order by hou.organization_id, ppa.payroll_action_id;

   /* The cursor cur_trans_y_n is used to verify whether retrieved GRE is
      the type of transmitter or not */

   cursor cur_trans_y_n ( cp_org_id in number ) is
   select  'Y'
   from    hr_organization_information
   where   organization_id = cp_org_id
   and     org_information1 = 'Y'
   and     org_information_context = 'Fed Magnetic Reporting';

   /* The cursor cur_dbi retrieves archive items and its value depending on
      context ( PACTID or ASGACTID) for T4 and T4A. */

   cursor   cur_dbi ( cp_context in number ) is
   select   distinct rtrim(ltrim(fdi.user_name)),
            rtrim(ltrim(fai.value)),
            initcap(rtrim(ltrim(replace(replace(replace(replace(replace(
            replace(replace( fdi.user_name,'CAEOY'),'T4A'),'T4'),'PER_GRE_YTD')
            ,'PER_JD_GRE_YTD'),'EMPLOYEE_'),'_',' ')))) req_col,
            fai.archive_item_id
	   from   ff_database_items fdi
		 ,ff_archive_items fai
	   where  fai.user_entity_id = fdi.user_entity_id
	   and    fai.context1 = to_char(cp_context)
           and    fdi.user_name like 'CAEOY%';

   /* Cursor to find the Employment Jurisdiction code for the employee */
   cursor get_jurisdiction_code( cp_context in number ) is
   select  rtrim(ltrim(fai.value))
	   from   ff_database_items fdi
		 ,ff_archive_items fai
	   where  fai.user_entity_id = fdi.user_entity_id
	   and    fai.context1 = to_char(cp_context)
           and    fdi.user_name = 'CAEOY_PROVINCE_OF_EMPLOYMENT';

   /* The cursor cur_cpp_periods retrives the CPP periods for an Employee. */

   cursor  cur_cpp_periods ( cp_payroll_id in number ) is
   select  count(regular_payment_date)
   from    per_time_periods target
   where   payroll_id     = cp_payroll_id
   and     to_char( target.regular_payment_date,'YYYY' ) = sv_reporting_year;

   /* The cursor cur_asg_act retrieves all assignment action ids for input
      PACTID that have not been amended.  Added sort option to fix bug#3977930 */

   /* For bug 5703506, added DISTINCT to the query. Also had to added the
      person_name in the select and other columns in select in the order by.

      The is because of the date join on the table per_people_f. If there
      are date track records in that table there will be multiple records */

   cursor cur_asg_act (cp_pactid in number) is
   select DISTINCT
          paa.assignment_action_id,
          paa.assignment_id,
          paa.serial_number person_id,
          paa.action_status,
          ppf.last_name,ppf.first_name,ppf.middle_names
   from  pay_assignment_actions paa,
         pay_payroll_actions    ppa,
         per_all_people_f ppf
   where paa.payroll_action_id = cp_pactid
   and   ppa.payroll_action_id = paa.payroll_action_id
   and   ppa.business_group_id = fp_b_g_id
   and not exists
   (select 1
    from pay_assignment_actions paa_amend,
         pay_payroll_actions    ppa_amend
    where paa_amend.payroll_action_id > cp_pactid
    and   paa.serial_number = paa_amend.serial_number
    and   ppa_amend.payroll_action_id = paa_amend.payroll_action_id
    and   ppa_amend.report_type in ('CAEOY_T4_AMEND_PP','CAEOY_T4A_AMEND_PP')
    and   ppa_amend.business_group_id = fp_b_g_id
    and   ppa_amend.action_status     = 'C'
    and   pycadar_pkg.get_parameter('TRANSFER_GRE',ppa.legislative_parameters) =
          pycadar_pkg.get_parameter('TRANSFER_GRE',ppa_amend.legislative_parameters)
    and   to_char(ppa_amend.effective_date,'YYYY') = sv_reporting_year
    and   to_char(ppa_amend.effective_date,'YYYY') = to_char(ppa.effective_date,'YYYY')
    and   to_char(ppa_amend.effective_date,'DD-MM') = '31-12'
    and   to_char(ppa_amend.effective_date,'DD-MM') = to_char(ppa.effective_date,'DD-MM'))
   and exists
    (select 1
     from per_assignments_f paf
     where paf.assignment_id = paa.assignment_id
     and paf.effective_start_date <= ppa.effective_date
     and paf.effective_end_date   >= trunc(ppa.effective_date,'Y')
	)
    and ppf.person_id = paa.serial_number
    and ppf.effective_start_date <= ppa.effective_date
    and ppf.effective_end_date   >= trunc(ppa.effective_date,'Y')
   order by ppf.last_name,ppf.first_name,ppf.middle_names,
            paa.assignment_action_id,
            paa.assignment_id,
            paa.serial_number,
            paa.action_status;

 /* The cursor cur_rl_dob retrieves the Birth Date and Hired Date
    for an employee. */

   cursor  cur_dob ( cp_person_id in number,
                     cp_effective_date in date ) is
   select  ppf.date_of_birth,
           ppf.original_date_of_hire
   from    per_all_people_f ppf
   where   ppf.person_id = cp_person_id
   and     cp_effective_date between ppf.effective_start_date
   and     ppf.effective_end_date;

   /* The cursor cur_rl_dob retrieves the termination Date if any.*/

   cursor   cur_terminate ( cp_person_id in number ) is
   select   actual_termination_date
   from     per_periods_of_service
   where    person_id = cp_person_id
   and      actual_termination_date is not null;

   /* The cursor cur_cpp_block is used to verify whether an employee has
      CPP Block or not. */

   cursor cur_cpp_block ( cp_bg_id in number,
                          cp_person_id in number,
                          cp_effective_date in date ) is
   select   cpp_qpp_exempt_flag
   from     per_all_assignments_f paaf, pay_ca_emp_fed_tax_info_f pcefti
   where    paaf.person_id = cp_person_id
   and      to_char(cp_effective_date,'YYYY') between
                    to_char(paaf.effective_start_date,'YYYY') and
                    to_char(paaf.effective_end_date, 'YYYY' )
   and      pcefti.assignment_id = paaf.assignment_id
   and      pcefti.business_group_id+0 = cp_bg_id
   and      to_char(cp_effective_date,'YYYY')  between
                    to_char(pcefti.effective_start_date,'YYYY') and
                    to_char(pcefti.effective_end_date,'YYYY')
   and       pcefti.cpp_qpp_exempt_flag = 'Y';

   /* The cursor cur_ei_block is used to verify whether an employee has
           EI Block or not. */

   cursor cur_ei_block  ( cp_bg_id in number,
                          cp_person_id in number,
                          cp_effective_date in date ) is
   select   ei_exempt_flag
   from     per_all_assignments_f paaf, pay_ca_emp_fed_tax_info_f pcefti
   where    paaf.person_id = cp_person_id
   and      to_char(cp_effective_date,'YYYY') between
                    to_char(paaf.effective_start_date,'YYYY') and
                    to_char(paaf.effective_end_date, 'YYYY' )
   and      pcefti.assignment_id = paaf.assignment_id
   and      pcefti.business_group_id+0 = cp_bg_id
   and      to_char(cp_effective_date,'YYYY')  between
                    to_char(pcefti.effective_start_date,'YYYY') and
                    to_char(pcefti.effective_end_date,'YYYY')
   and       pcefti.ei_exempt_flag = 'Y';

   cursor cur_t4a_nonbox_footnote(cp_asgact_id number) is
   select pai.action_information5,
          flv.meaning,
          'CAEOY_T4A_NONBOX_FOOTNOTE'
   from pay_action_information pai,
        fnd_lookup_types  flt,
        fnd_lookup_values flv
   where pai.action_context_id = cp_asgact_id
   and   pai.action_context_type = 'AAP'
   and   pai.action_information_category = 'CA FOOTNOTES'
   and   pai.action_information6 = 'T4A'
   and   flt.lookup_type  = 'PAY_CA_T4A_NONBOX_FOOTNOTES'
   and   flv.lookup_type  = flt.lookup_type
   and   flv.language     = userenv('LANG')
   and   flv.enabled_flag = 'Y'
   and   flv.lookup_code  = pai.action_information4;

   l_print_y_n  number(1) := 0;
   l_transmitter_y_n  char(1);

   l_payroll_action_id number(20);
   l_business_number   varchar2(180);
   l_first_employee    number(20);
   l_org_id            number(20);
   l_gre_name          varchar2(180);
   l_payroll_id        number(9);
   l_effective_date    date;

   l_dbi_name         varchar2(240);
   l_dbi_value        varchar2(240);
   l_dbi_short_name   varchar2(240);
   l_arc_item_id      number(15);

   l_assignment_action_id number(15);
   l_assignment_id        number(10);
   l_person_id            varchar2(30);
   l_action_status        varchar2(1);
   i  number(3);

   l_last_name            per_people_f.last_name%TYPE;
   l_first_name           per_people_f.first_name%TYPE;
   l_middle_names         per_people_f.middle_names%TYPE;

  begin
     open cur_pay_act;
     loop
        fetch  cur_pay_act into l_payroll_action_id,
                                l_business_number,
                                l_org_id,
                                l_gre_name,
                                l_payroll_id,
                                l_effective_date,
                                sv_report_type;

         exit when cur_pay_act%notfound;

      hr_utility.set_location('PACTID  ' || to_char(l_payroll_action_id), 110);
      hr_utility.set_location('ORG ID  ' || to_char(l_org_id), 120);
      hr_utility.set_location('BUSI NO.  ' || l_business_number, 130);
      hr_utility.set_location('GRE NAME  ' || l_gre_name, 140);

         sv_busi_no  := l_business_number;
         sv_gre_name := l_gre_name;
         sv_gre      := l_org_id;

         l_transmitter_y_n := 'N';

         open cur_trans_y_n(l_org_id);
         fetch cur_trans_y_n into l_transmitter_y_n;
         close cur_trans_y_n;

         sv_trans_y_n := l_transmitter_y_n;
         hr_utility.set_location('Transmitter ?  ' || sv_trans_y_n, 150);

         if ((sv_report_type <> 'CAEOY_T4_AMEND_PP') and
             (sv_report_type <> 'CAEOY_T4A_AMEND_PP')) then

           if sv_p_y = 'E' then

              initialize_static_var('R');
              open cur_dbi(l_payroll_action_id);

              hr_utility.set_location(' Cursor DBI Before Validation ', 160);
              loop

              fetch cur_dbi into l_dbi_name,
                                 l_dbi_value,
                                 l_dbi_short_name,
                                 l_arc_item_id;
              exit when cur_dbi%notfound;

              fed_employer_validation(l_dbi_name,l_dbi_value,l_dbi_short_name);

              end loop;

              hr_utility.set_location(' Cursor DBI After Validation ', 170);
              close cur_dbi;
              employer_header;
              print_employer;
           end if;

         end if;

         open  cur_cpp_periods(l_payroll_id);
         fetch cur_cpp_periods into sv_no_of_cpp_periods;
         close cur_cpp_periods;

         l_first_employee := 0;

         open  cur_asg_act(l_payroll_action_id);
         loop
            fetch cur_asg_act into  l_assignment_action_id,
                                    l_assignment_id,
                                    l_person_id,
                                    l_action_status,
                                    l_last_name,
                                    l_first_name,
                                    l_middle_names;

            exit when cur_asg_act%notfound;

            if l_first_employee = 0 then
               employee_header;
               l_first_employee := 1;
            end if;

            sv_asg_id := l_assignment_id;

            initialize_static_var('E');

            hr_utility.set_location(' CUR_DOB', 188 );

            open  cur_dob( l_person_id, l_effective_date);
            fetch cur_dob into sv_date_of_birth, sv_hire_date;
            close cur_dob;

            hr_utility.set_location('CUR_TERMINATE',177);

            open  cur_terminate( l_person_id);
            fetch cur_terminate into sv_terminate_date;
            close cur_terminate;

            hr_utility.set_location('CUR_CPP_BLOCK',166);

            open  cur_cpp_block( fp_b_g_id, l_person_id, l_effective_date);
            fetch cur_cpp_block into sv_cpp_block;
            close cur_cpp_block;

            hr_utility.set_location('CUR_EI_BLOCK',156);

            open  cur_ei_block( fp_b_g_id, l_person_id, l_effective_date);
            fetch cur_ei_block into sv_ei_block;
            close cur_ei_block;

            hr_utility.set_location('JURISDICTION_CODE',157);

            open get_jurisdiction_code(l_assignment_action_id);
            fetch get_jurisdiction_code into sv_jurisdiction;
	    close get_jurisdiction_code;

            hr_utility.set_location('CUR_DBI',159);

            open cur_dbi(l_assignment_action_id);
            hr_utility.set_location(' Cursor Assignment actions '||
                              to_char(l_assignment_action_id), 199);
            i := 0;
            loop
               fetch cur_dbi into l_dbi_name,
                                  l_dbi_value,
                                  l_dbi_short_name,
                                  l_arc_item_id;
               exit when cur_dbi%notfound;

               i := i + 1;
               sv_dbi(i).dbi_name  := l_dbi_name;
               sv_dbi(i).dbi_value := l_dbi_value;
               sv_dbi(i).dbi_short_name := l_dbi_short_name;
               sv_dbi(i).archive_item_id := l_arc_item_id;
            end loop;
            close cur_dbi;

            open cur_t4a_nonbox_footnote(l_assignment_action_id);
            loop
                fetch cur_t4a_nonbox_footnote into l_dbi_value,
                                                   l_dbi_short_name,
                                                   l_dbi_name;
                exit when cur_t4a_nonbox_footnote%notfound;

                i := i + 1;
                sv_dbi(i).dbi_name  := l_dbi_name;
                sv_dbi(i).dbi_value := l_dbi_value;
                sv_dbi(i).dbi_short_name := l_dbi_short_name;

            end loop;
            close cur_t4a_nonbox_footnote;

            if i <> 0 then
               fed_employee_validation;
               if sv_print = 1 then
                  print_employee;
               end if;
            end if;

         end loop;
         close  cur_asg_act;
         format_data('</table>');

     end loop;
     close cur_pay_act;
  end federal_process;

  /*****************************************************************
  ** This is the main procedure which is called from the Concurrent
  ** Request. All the paramaters are passed based on which it will
  ** print an HTML format file.
  *****************************************************************/

  PROCEDURE pier_yeer
             (errbuf                      out nocopy varchar2
             ,retcode                     out nocopy number
             ,p_reporting_year            in  varchar2
             ,p_pier_yeer                 in  varchar2
             ,p_fed_prov                  in  varchar2
             ,p_gre                       in  number
             ,p_pre                       in  number
             ,p_b_g_id                    in  number
             )
  IS

  /* The cursor cur_lkup is used to store all reasons and labels in
     PL/SQL table so we no need to retrieve this table many times. */

   cursor cur_lkup is
   select flv.lookup_code,
          flv.meaning,
          flv.description
   from   fnd_lookup_types flt,
          fnd_lookup_values flv
   where  flt.lookup_type = 'PAY_CA_EOY_EXCEPTIONS'
   and    flv.lookup_type = flt.lookup_type
   and    flv.language    = userenv('LANG');

   p_output_file_type varchar2(10) := ' ';
   lv_lookup_code     varchar2(30);
   lv_meaning         varchar2(80);
   lv_description     varchar2(240);
   i                  number := 0;
 BEGIN
  -- hr_utility.trace_on(null,'VRP');
   hr_utility.set_location(gv_package_name || '.pier_yeer', 10);
   hr_utility.set_location('Reporting Year ' || p_reporting_year, 20);
   hr_utility.set_location('Report Name ' || p_pier_yeer, 30);
   hr_utility.set_location('Fed/Prov  ' || p_fed_prov, 40);
   hr_utility.set_location('GRE  ' || to_char(p_gre), 50);
   hr_utility.set_location('PRE  ' || to_char(p_pre), 60);
   hr_utility.set_location('BGID  ' || to_char(p_b_g_id), 70);

   open  cur_lkup;
   loop
      fetch cur_lkup into lv_lookup_code,
                          lv_meaning,
                          lv_description;
      exit when cur_lkup%notfound;
      i := i + 1;
      sv_lkup(i).dbi_name       := lv_lookup_code;
      sv_lkup(i).dbi_value      := lv_meaning;
      sv_lkup(i).dbi_short_name := lv_description;
   end loop;
   close cur_lkup;

   select to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS') into sv_date from dual;
   hr_utility.set_location('DATE  ' || sv_date, 80);

   /* Report Parameters print first using static_header procedure */

   sv_gre := p_gre;
   sv_pre := p_pre;
   sv_reporting_year := substr(p_reporting_year,1,4);
   sv_p_y := p_pier_yeer;
   sv_f_p := p_fed_prov;
   sv_b_g_id := p_b_g_id;

   /* Select all CPP and EI information */

   sv_cpp_max_earn := legi_info('MAX_CPP_EARNINGS');
   sv_cpp_exempt   := legi_info('CPP_EXEMPTION');
   sv_cpp_rate     := legi_info('CPP_RATE');
   sv_ei_max_earn  := legi_info('MAX_EI_EARNINGS');
   sv_ei_rate      := legi_info('EI_RATE');
   /* Added by ssmukher for PPIP tax implementation */
   sv_ppip_max_earn  := legi_info('MAX_PPIP_EARNINGS');
   sv_ppip_rate      := legi_info('PPIP_RATE');
   sv_ppip_ei_rate   := legi_info('EI_RATE','QC');

   sv_ppip_max_exempt := ( ( sv_ppip_max_earn ) * sv_ppip_rate / 100 );

   sv_cpp_max_exempt := ( ( sv_cpp_max_earn - sv_cpp_exempt ) *
                            sv_cpp_rate / 100 );
/*
   if sv_ppip_insurable_earnings > 0 then
      sv_ei_max_exempt := ( ( sv_ei_max_earn ) * sv_ppip_ei_rate / 100 );
   else
      sv_ei_max_exempt := ( ( sv_ei_max_earn ) * sv_ei_rate / 100 );
   end if;
*/
   hr_utility.set_location('Report:  ' || p_pier_yeer, 85);

   if ( p_pier_yeer = 'P' ) then
   if ( p_fed_prov = 'F' ) then
      sv_pier_yeer := get_lookup_meaning('L_PIER');
   else
      sv_pier_yeer := get_lookup_meaning('L_QPP_RPT');
   end if;
   else
      sv_pier_yeer := get_lookup_meaning('L_YEER');
   end if;

   hr_utility.set_location('Report:  ' || sv_pier_yeer, 90);


   if p_fed_prov = 'P' then
      sv_fed_prov := get_lookup_meaning('L_PROV');
   else
      sv_fed_prov := get_lookup_meaning('L_FED');
   end if;
   hr_utility.set_location('FEd/Prov:  ' || sv_fed_prov, 100);

   if ( p_gre is not null ) then
   begin
      /* Used to print GRE name as report parameter. */
      select  name, org_information1
      into    sv_gre_name, sv_busi_no
      from    hr_organization_information hoi,
              hr_all_organization_units hou
      where   hoi.organization_id = hou.organization_id
      and     hoi.organization_id = p_gre
      and     hoi.org_information_context = 'Canada Employer Identification'
      and     hou.business_group_id = p_b_g_id;

      exception
      when others then
      null;
   end;
   hr_utility.set_location('GRE        ' || sv_gre_name, 110);
   end if;

   if ( p_pre is not null ) then
      begin
         /* Used to print PRE name as report parameter. */
         select hou.name,
                hoi.org_information2
         into   sv_pre_name,
                sv_qin
         from   hr_organization_information hoi,
                hr_all_organization_units hou
         where   hoi.organization_id = hou.organization_id
         and     hoi.organization_id = p_pre
         and     hoi.org_information1 = 'QC'
         and     hoi.org_information_context = 'Prov Reporting Est'
         and     hou.business_group_id = p_b_g_id;

         exception
         when others then
         null;
      end;
      hr_utility.set_location('PRE        ' || sv_pre_name, 120);
      hr_utility.set_location('QIN        ' || sv_qin, 120);
   end if;

   begin

       /* Select context id for Jurisdiction and is used for T4 Neg. Bal. */
      select context_id
      into   sv_context_id
      from   ff_contexts
      where  context_name = 'JURISDICTION_CODE';

      exception
      when others then
      null;
   end;

   format_data('<html><body>');
   static_header;
   if p_fed_prov = 'F' then
      federal_process(p_gre, p_b_g_id);
   else
      provincial_process(p_pre, p_b_g_id);
   end if;
   format_data('</body></html>');
  END pier_yeer;

end pay_ca_yeer_pkg;

/
