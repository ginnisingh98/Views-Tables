--------------------------------------------------------
--  DDL for Package Body PAY_CA_PAYREG_EXTRACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_PAYREG_EXTRACT_PKG" AS
/* $Header: pycaprpe.pkb 120.5.12010000.2 2009/05/28 10:02:59 sapalani ship $ */
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

    Name        : pay_ca_payreg_extract_pkg

    Description : Package for the Payment Report. The package
                  generated the output file in the specified user
                  format. The current formats supported are
                      - HTML
                      - CSV

    Change List
    -----------
 Date        Name      Vers   Bug No    Description
 ----        ----      ------ -------   -----------
 10-OCT-2001 ssattini  115.0  1380269   Created.
 20-NOV-2001 ssattini  115.1             Added dbdrv line.
 05-DEC-2001 ssattini  115.2             Fixed bug#2133040.
 19-DEC-2001 ssattini  115.3             Fixed bug#2139427,2136857.
 21-DEC-2001 ssattini  115.4             Changed 'Pay Date' format
                                         using
                                         fnd_date.date_to_canonical
                                         function.
 08-JAN-2002 ssattini  115.5             Fixed bug#2134726, 2133345,
                                         2134807 and 2134821.
 28-JAN-2002 ssattini  115.6             Fixed bug#2164160 and printed
                                         'Total Payment Amount' just
                                         below the 'Amount' field.
 14-MAR-2002 trugless  115.7             Modified c_personal_paymeth_info
                                         cursor for utf8 requirements
 20-MAR-2002 mmukherj  115.8 2271482     Modified the cursor c_assignments
                                         to fix the bug 2241782. Since the
                                         cursor was joining consolidation_set_id
                                         parameter with the consolidation_set_id
                                         of pay_all_payrolls_f if the payroll is
                                        run for a different consolidation_set_id
                                        then the cursor was not picking up any
                                        record.Now the cusrsor has been changed
                                      so that it checks the consolidation_set_id
                                      in pay_payroll_actions table. Also an nvl
                                      has been added in this join, so that it
                                      picks up records if consolidation_set_id
                                      has not been passed from the process.
 20-MAR-2002 mmukherj  115.9 2271482  Bug no in the history has been correctd.
 21-MAR-2002 mmukherj  115.10 2271482 Modified the cursor
                                      c_personal_paymeth_info, while makimg the
                                      UTF8 changes(version 115.7), the decode
                                      statement was incorrectly written, and
                                      it was fetching incorrect data
                                      for bank_number as 'US', even though there
                                      were bank_numbers for an employee.
                                      The cursor has been corrected to that
                                      it brings correct bank_number.
 30-OCT-2002 TCLEWIS  115.11          Modified the c_payment_period cursor
                                      in the payment_extract procedure.
                                      Instead of returning paa.serial_number
                                      now calling pay_us_employee_payslip_web
                                      .get_check_number to retrieve the check
                                      number.
 14-NOV-2002 tclewis 115.12           Changed order of parameters to
                                      pay_us_employee_payslip_web.
                                      get_check_number.  AA_ID PP_ID/
 22-JAN-2003 ssattini 115.14 2745577  Commented out the validation
                                      in c_assignments cursor to
                                      print 'Third Party Payments',
                                      fix for bug#2745577.

 29-JAN-2003 ssattini 115.15 2745577  Added logic to print two
                                      additional columns 'Case/ Court
                                      Order Number' and 'Payee Name'
                                      to support Third Party payments,
                                      fix for bug#2745577.
 30-JAN-2003 ssattini 115.16 2771166  Changed the c_payment_period and
                                      c_payroll_paydate cursors,
                                      removed reference to per_time_periods
                                      in c_payment_period and added it to
                                      c_payroll_paydate cursor.
                                      Fix for bug#2771166.
 30-JAN-2003 ssattini 115.17          Tuned the c_assignments cursor
                                      to avoid full table scan on
                                      pay_org_payment_method_f and
                                      pay_pre_payments tables.
 03-FEB-2003 ssattini 115.18 2745577  Fixed the issue to print correct
                                      Court Order/Case Number when
                                      ran with multiple garnishment
                                      elements for each assignment,
                                      fix for bug#2745577.
 04-AUG-2003 trugless 115.19 3039110  Replaced  payment_labels function
                                      with lookup to
                                      FND_COMMON_LOOKUPS table using
                                      hr_general.decode_fnd_comm_lookup
                                      function.  Deleted gv_title heading
                                      which was not being used.
 17-DEC-2003 ssattini 115.20 3316062  Modified the cursor c_assignments to
                                      to fix the bug#3316062, corrected
                                      paa_key inline view to pick up
                                      T4A Employee Payments also.
 08-JAN-2004 ssattini 115.21 3359412  Modified the cursor c_assignments to
                                      to fix the 11510 performance bug#3359412.
 04-MAR-2004 ssattini 115.22 3479270  Modified the cursor c_assignments to
                                      to fix the bug#3479270, corrected
                                      paa_key inline view to avoid duplicate
                                      payment records.
 23-MAR-2004 ssattini 115.23 3517534  Modified the cursor c_assignments to
                                      to fix the bug#3517534, corrected
                                      parameter values validation.
 02-May-2006 ssmukher 115.24 5178951  Added a new column to display whether
                                      the Cheque/Third Party cheque/Deposit Advice has been voided.
                                      Modified the procedure payment_extract.Added a new cursor
                                      c_payment_status.
 03_May-2006 ssmukher 115.25 5178951  Removed the effective date check from the
                                      cursor c_payment_status.
 16-May-2006 ydevi    115.26 5225939  Modified the code to get the check number and direct deposit
                                      number printed for voided payments too in the payment report

 26-Sep-2006 schowta 115.27 5383895 - Following modifications are done. search for 5383895
							                       for all the changes done.

							a. pay_ca_payreg_extract_pkg > c_payment_period  and
							other cursors the join to date_earned has been changed to effective_date
							in all instances except in c_payroll_paydate

							cursor c_tp_pmt_check is merged with c_assignments cursor.
							c_assignments cursor is modified to include ,popm.defined_balance_id.
							Associated open cursor  is modified to check if it is null.
 13-Nov-2006 schowta 115.28 		Line No. 196 - Observed that "" was missing. Modified to "&nbsp"

 28-May-2009 sapalani 115.29 7280782  Modified cursor c_assignments in procedure
                                      payment_extract. Used paa_pre.tax_unit_id
                                      instead of paa_run.tax_unit_id to use the
                                      tax unit id from pre-payment action.
*/

  /************************************************************
  ** Local Package Variables
  ************************************************************/
  gc_csv_delimiter       VARCHAR2(1) := ',';
  gc_csv_data_delimiter  VARCHAR2(1) := '"';

  gv_html_start_data     VARCHAR2(5) := '<td>'  ;
  gv_html_end_data       VARCHAR2(5) := '</td>' ;

  gv_package_name        VARCHAR2(50) := 'pay_ca_payreg_extract_pkg';

  gv_leg_code            VARCHAR2(3);
  gv_business_group_id   NUMBER;
  gv_tot_amt_lbl         VARCHAR2(100) := ' ';


  /******************************************************************
  ** Function Returns the formated input string based on the
  ** Output format. If the format is CSV then the values are returned
  ** seperated by comma (,). If the format is HTML then the returned
  ** string as the HTML tags. The parameter p_bold only works for
  ** the HTML format.
  ******************************************************************/
  FUNCTION formated_data_string
             (p_input_string     in varchar2
             ,p_output_file_type in varchar2
             ,p_bold             in varchar2 default 'N'
             )
  RETURN VARCHAR2
  IS

    lv_format          varchar2(1000);

  BEGIN
    hr_utility.set_location(gv_package_name || '.formated_data_string', 10);
    if p_output_file_type = 'CSV' then
       hr_utility.set_location(gv_package_name || '.formated_data_string', 20);
       lv_format := gc_csv_data_delimiter || p_input_string ||
                           gc_csv_data_delimiter || gc_csv_delimiter;
    elsif p_output_file_type = 'HTML' then
       if ltrim(rtrim(p_input_string)) is null then
          hr_utility.set_location(gv_package_name ||
                                        '.formated_data_string', 30);

          lv_format := gv_html_start_data || '&nbsp;' || gv_html_end_data;
       else
          if p_bold = 'Y' then
             hr_utility.set_location(gv_package_name ||
                                          '.formated_data_string',40);
             if p_input_string = gv_tot_amt_lbl then
                lv_format := '<td align="right" colspan=12>'||
                      '<b> ' || p_input_string|| '</b>' || gv_html_end_data;
             else
                lv_format := gv_html_start_data || '<b> ' || p_input_string
                             || '</b>' || gv_html_end_data;
             end if;
          else
             hr_utility.set_location(gv_package_name ||
                                        '.formated_data_string',50);

             lv_format := gv_html_start_data || p_input_string ||
                                                          gv_html_end_data;

          end if;
       end if;
    end if;

    hr_utility.set_location(gv_package_name || '.formated_data_string', 60);
    return lv_format;

  END formated_data_string;


/** Function to get the Column labels for report **/

  FUNCTION payment_labels(p_lookup_type in varchar2,
                          p_lookup_code in varchar2,
                          p_person_language in varchar2 default NULL)
           return varchar2 IS

    CURSOR get_meaning IS
    select 1 ord, meaning
    from  fnd_lookup_values
    where lookup_type = p_lookup_type
    and   lookup_code = p_lookup_code
    and ( ( p_person_language is null and language = 'US' ) or
      ( p_person_language is not null and language = p_person_language ) )
    union all
    select 2 ord, meaning
    from  fnd_lookup_values
    where lookup_type = p_lookup_type
    and   lookup_code = p_lookup_code
    and ( language = 'US' and p_person_language is not null
    and language <> p_person_language )
    order by 1;

    lv_meaning varchar2(100);
    lv_order   number;

    BEGIN
        open get_meaning;

        fetch get_meaning into lv_order,lv_meaning;

        if get_meaning%notfound then
           lv_meaning := 'xx';
        end if;

        close get_meaning;

        return lv_meaning;

    END payment_labels;


  /************************************************************
  ** Function returns the string with the HTML Header tags
  ************************************************************/
  FUNCTION formated_header_string
             (p_input_string     in varchar2
             ,p_output_file_type in varchar2
             )
  RETURN VARCHAR2
  IS

    lv_format          varchar2(1000);

  BEGIN
    hr_utility.set_location(gv_package_name || '.formated_header_string', 10);
    if p_output_file_type = 'CSV' then
       hr_utility.set_location(gv_package_name|| '.formated_header_string', 20);

       lv_format := p_input_string;
    elsif p_output_file_type = 'HTML' then
       hr_utility.set_location(gv_package_name|| '.formated_header_string', 30);
       lv_format := '<HTML><HEAD> <CENTER> <H1> <B>' || p_input_string ||
                             '</B></H1></CENTER></HEAD>';
    end if;

    hr_utility.set_location(gv_package_name || '.formated_header_string', 40);
    return lv_format;

  END formated_header_string;


  /*****************************************************************
  ** This procudure returns the Mandatory Static Labels and the
  ** Other Additional Static columns. The other static columns are
  ** printed after all the Payment Information is printed for each
  ** employee assignment.
  ** The users can add hooks to this package to print more additional
  ** data which they require for this report.
  ** The package prints the user data from a PL/SQL table. The users
  ** can insert data and the label in this PL/SQL table which will
  ** be printed at the end of the report.
  ** The PL/SQL table which needs to be populated is
  ** LTT_PAYMENT_EXTRACT_DATA. This PL/SQL table is defined in the
  ** Package pay_ca_payreg_extract_data_pkg (pycaprpd.pkh/pkb).
  *****************************************************************/
  PROCEDURE formated_static_header(
              p_output_file_type  in varchar2
             ,p_static_label1    out  NOCOPY varchar2
             ,p_static_label2    out  NOCOPY varchar2
             )
  IS

    lv_format1          varchar2(32000);
    lv_format2          varchar2(32000);
    lv_bank_code        varchar2(20);
    lv_leg_code         varchar2(3);

  BEGIN

      hr_utility.set_location(gv_package_name || '.formated_static_header', 10);

      begin
        select legislation_code into lv_leg_code
        from   per_business_groups
        where  business_group_id = gv_business_group_id;

        exception
        when no_data_found then
        null;
      end;

/** The following condition added to check legislation code and print the
   label for bank information **/

      if lv_leg_code = 'US' then
         lv_bank_code := 'BNK_NAME';
      elsif lv_leg_code = 'CA' then
         lv_bank_code := 'BNK_NUM';
      end if;

      gv_leg_code := lv_leg_code;

      lv_format1 :=
              formated_data_string (p_input_string =>
                                       hr_general.decode_fnd_comm_lookup
                                           ('PAYMENT_REGISTER_LABELS',
                                            'PMT_TYPE')
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string =>
                                       hr_general.decode_fnd_comm_lookup
                                            ('PAYMENT_REGISTER_LABELS',
                                             'PMT_METH')
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string =>
                                       hr_general.decode_fnd_comm_lookup
                                           ('PAYMENT_REGISTER_LABELS',
                                            'PAY_NAME')
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string =>
                                       hr_general.decode_fnd_comm_lookup
                                            ('PAYMENT_REGISTER_LABELS',
                                             'GRE')
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string =>
                                       hr_general.decode_fnd_comm_lookup
                                           ('PAYMENT_REGISTER_LABELS',
                                            'PAY_DATE')
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string =>
                                       hr_general.decode_fnd_comm_lookup
                                            ('PAYMENT_REGISTER_LABELS',
                                             'PERIOD')
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string =>
                                       hr_general.decode_fnd_comm_lookup
                                           ('PAYMENT_REGISTER_LABELS',
                                            'EMP_NAME')
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string =>
                                       hr_general.decode_fnd_comm_lookup
                                            ('PAYMENT_REGISTER_LABELS',
                                             'ASG_NUM')
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string =>
                                       hr_general.decode_fnd_comm_lookup
                                           ('PAYMENT_REGISTER_LABELS',
                                            'PMT_NUM')
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type);

      hr_utility.set_location(gv_package_name || '.formated_static_header', 20);

      lv_format2 :=
              formated_data_string (p_input_string =>
                                       hr_general.decode_fnd_comm_lookup
                                            ('PAYMENT_REGISTER_LABELS',
                                             lv_bank_code)
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string =>
                                       hr_general.decode_fnd_comm_lookup
                                           ('PAYMENT_REGISTER_LABELS',
                                            'TRAN_CODE')
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string =>
                                       hr_general.decode_fnd_comm_lookup
                                            ('PAYMENT_REGISTER_LABELS',
                                             'ACC_NUM')
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string =>
                                       hr_general.decode_fnd_comm_lookup
                                           ('PAYMENT_REGISTER_LABELS',
                                            'PMT_AMT')
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string =>
                                       hr_general.decode_fnd_comm_lookup
                                            ('PAYMENT_REGISTER_LABELS',
                                             'CASE_NUM')
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string =>
                                       hr_general.decode_fnd_comm_lookup
                                           ('PAYMENT_REGISTER_LABELS',
                                            'PAYEE_NAME')
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string =>
                                       hr_general.decode_fnd_comm_lookup
                                           ('PAYMENT_REGISTER_LABELS',
                                            'PMT_STATUS')
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ;



      /*******************************************************************
      ** Print the User Defined data for each Employee Assignment at the
      ** end of the report
      *******************************************************************/
      hr_utility.set_location(gv_package_name || '.formated_static_header', 30);


      /*******************************************************************
      ** Only do this if there is some configuration data present
      *******************************************************************/
      if pay_ca_payreg_extract_data_pkg.ltt_payment_extract_label.count > 0 then
         for i in pay_ca_payreg_extract_data_pkg.ltt_payment_extract_label.first ..
                  pay_ca_payreg_extract_data_pkg.ltt_payment_extract_label.last
         loop

            lv_format2 := lv_format2 ||
                             formated_data_string (
                               p_input_string =>
                                pay_ca_payreg_extract_data_pkg.ltt_payment_extract_label(i)
                              ,p_bold         => 'Y'
                              ,p_output_file_type => p_output_file_type);

         end loop;
      end if;


      p_static_label1 := lv_format1;
      p_static_label2 := lv_format2;
      hr_utility.trace('Static Label1 = ' || lv_format1);
      hr_utility.trace('Static Label2 = ' || lv_format2);
      hr_utility.set_location(gv_package_name || '.formated_static_header', 40);

  END;


  /*****************************************************************
  ** This procudure returns the Mandatory Static Labels and the
  ** Other Additional Static columns. The other static columns are
  ** printed after all the Payment Information is printed for each
  ** employee assignment.
  ** The users can add hooks to this package to print more additional
  ** data which they require for this report.
  ** The package prints the user data from a PL/SQL table. The users
  ** can insert data and the label in this PL/SQL table which will
  ** be printed at the end of the report.
  ** The PL/SQL table which needs to be populated is
  ** LTT_PAYMENT_EXTRACT_DATA. This PL/SQL table is defined in the
  ** Package pay_ca_payreg_extract_data_pkg (pycaprpd.pkh/pkb).
  *****************************************************************/
 /* Added two columns p_case_number, p_payee_name to format the
    Third Party Payments, to fix bug#2745577 */
 PROCEDURE formated_static_data(
                   p_employee_full_name        in varchar2
                  ,p_employee_number           in varchar2
                  ,p_payment_type              in varchar2
                  ,p_payment_number            in varchar2
                  ,p_bank_number_bank_name     in varchar2
                  ,p_transit_code              in varchar2
                  ,p_account_number            in varchar2
                  ,p_payment_amount            in varchar2
                  ,p_payroll_name              in varchar2
                  ,p_gre_name                  in varchar2
                  ,p_period	               in varchar2
                  ,p_payment_method            in varchar2
                  ,p_pay_date                  in varchar2
                  ,p_case_number               in varchar2
                  ,p_payee_name                in varchar2
                  ,p_payment_status            in varchar2
                  ,p_output_file_type          in varchar2
                  ,p_static_data1             out NOCOPY varchar2
                  ,p_static_data2             out NOCOPY varchar2
             )
  IS

    lv_format1 VARCHAR2(32000);
    lv_format2 VARCHAR2(32000);
    sv_amount  varchar2(200);

  BEGIN

      hr_utility.set_location(gv_package_name || '.formated_static_data_tp', 10);
      lv_format1 :=
              formated_data_string (p_input_string => p_payment_type
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => p_payment_method
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => p_payroll_name
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => p_gre_name
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => p_pay_date
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => p_period
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_employee_full_name
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => p_employee_number
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => p_payment_number
                                   ,p_output_file_type => p_output_file_type);

      hr_utility.set_location(gv_package_name || '.formated_static_data_tp', 20);

      if p_output_file_type = 'HTML' then
         sv_amount := '<td align="right">'||p_payment_amount||gv_html_end_data;
      elsif p_output_file_type = 'CSV' then
         sv_amount := formated_data_string (p_input_string => p_payment_amount
                                     ,p_output_file_type => p_output_file_type);
      end if;

      lv_format2 :=
              formated_data_string (p_input_string => p_bank_number_bank_name
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => p_transit_code
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => p_account_number
                                   ,p_output_file_type => p_output_file_type) ||
              sv_amount ||

              formated_data_string (p_input_string => p_case_number
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => p_payee_name
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => p_payment_status
                                   ,p_output_file_type => p_output_file_type);


      /*******************************************************************
      ** Print the User Defined data for each Employee Assignment at the
      ** end of the report
      *******************************************************************/
      hr_utility.set_location(gv_package_name || '.formated_static_data_tp', 30);
      hr_utility.trace('Before Loop  ');

      hr_utility.trace('Static Data1 = ' || lv_format1);
      hr_utility.trace('Static Data2 = ' || lv_format2);

      /*******************************************************************
      ** Only do this if there is some configuration data present
      *******************************************************************/
      if pay_ca_payreg_extract_data_pkg.ltt_payment_extract_label.count > 0 then

         for i in pay_ca_payreg_extract_data_pkg.ltt_payment_extract_data.first ..
                  pay_ca_payreg_extract_data_pkg.ltt_payment_extract_data.last
         loop

            lv_format2 := lv_format2 ||
                             formated_data_string (
                               p_input_string =>
                                 pay_ca_payreg_extract_data_pkg.ltt_payment_extract_data(i)
                              ,p_output_file_type => p_output_file_type);

         end loop;
      end if;


      p_static_data1 := lv_format1;
      p_static_data2 := lv_format2;
      hr_utility.trace('After Loop  ');
      hr_utility.trace('Static Data1 = ' || lv_format1);
      hr_utility.trace('Static Data2 = ' || lv_format2);
      hr_utility.set_location(gv_package_name || '.formated_static_data_tp', 40);

  END;


  /*****************************************************************
  ** This is the main procedure which is called from the Concurrent
  ** Request. All the paramaters are passed based on which it will
  ** either print a CSV format or an HTML format file.
  *****************************************************************/
  PROCEDURE payment_extract
             (errbuf                      out NOCOPY varchar2
             ,retcode                     out NOCOPY number
             ,p_business_group_id         in  number
             ,p_start_date                in  varchar2
             ,p_end_date                  in  varchar2
             ,p_payroll_id                in  number
             ,p_consolidation_set_id      in  number
             ,p_tax_unit_id               in  number
	     ,p_payment_type_id           in  number
	     ,p_payment_method_id         in  number
             ,p_output_file_type          in  varchar2
             )
  IS

    /************************************************************
    ** Cursor to get all the employee information, Payment info'n
    ** and assignment data. This cursor will return one row for each
    ** Assignment Action for the selection parameters entered by the
    ** user in the SRS. The Assignment Action returned by this cursor
    ** is used to  retreive the Payment Number and Period Name.
    ************************************************************/
   cursor c_assignments (
                       cp_start_date           in date
                      ,cp_end_date             in date
                      ,cp_payroll_id           in number default NULL
                      ,cp_consolidation_set_id in number
		      ,cp_payment_type_id      in number default NULL
		      ,cp_tax_unit_id          in number default NULL
		      ,cp_payment_method_id    in number default NULL
                      ,cp_business_group_id    in number
                      ) is
   select  hou.name
       ,paa_key.tax_unit_id
       ,ppf.full_name
       ,ppf.employee_number
       ,paf.assignment_number
       ,ppt_tl.payment_type_name
       ,ppp.value   /* Payment Amount */
       ,ppp.personal_payment_method_id
       ,popm.org_payment_method_id
       ,popm_tl.org_payment_method_name
       ,ppf.person_id
       ,pap.payroll_name
       ,ppp.pre_payment_id
       ,paa_key.assignment_action_id
       ,paa_key.date_earned
       ,paa_key.effective_date  /*  BUG: 5383895 paa_key.date_earned changed to paa_key.effective_date */
      ,popm.defined_balance_id  /*  BUG: 5383895 added to avoid the cursor c_tp_pmt_check  */
   from  per_all_people_f ppf
        ,per_all_assignments_f paf
        ,hr_all_organization_units_tl hou
        ,pay_all_payrolls_f      pap
        ,pay_payment_types_tl ppt_tl
        ,pay_payment_types ppt
        ,pay_org_payment_methods_f_tl popm_tl
        ,pay_org_payment_methods_f popm
        ,pay_pre_payments ppp
        ,(select distinct paa_pre.assignment_action_id /* Locked Action Id */
                 --,paa_run.tax_unit_id -- commented for bug 7280782
                 ,paa_pre.tax_unit_id   -- Added for bug 7280782
                 ,ppa_pre.date_earned
                 ,paa_pre.assignment_id
                 ,ppa_pre.payroll_id
		             ,ppa_pre.effective_date  /* BUG: 5383895 added ppa_pre.effective_date  */
          from    pay_run_types_f prt
                 ,pay_assignment_actions paa_run
                 ,pay_action_interlocks pai
                 ,pay_assignment_actions paa_pre
                 ,pay_payroll_actions ppa_pre
          where   ppa_pre.business_group_id  = cp_business_group_id
          and     ppa_pre.effective_date between cp_start_date and  cp_end_date /* BUG: 5383895 ppa_pre.date_earned changed to ppa_pre.effective_date */
          and     ppa_pre.action_status = 'C'
          and     ppa_pre.action_type in ('U','P')
          and     ((ppa_pre.consolidation_set_id = cp_consolidation_set_id) OR
                    (cp_consolidation_set_id is NULL))
          and     ppa_pre.payroll_action_id = paa_pre.payroll_action_id
          and     paa_pre.action_status = 'C'
          and     pai.locking_action_id = paa_pre.assignment_action_id
          and     paa_run.assignment_action_id = pai.locked_action_id
          and     ((paa_run.tax_unit_id = cp_tax_unit_id) OR
                    (cp_tax_unit_id is NULL))
          and     paa_run.action_status = 'C'
          and     paa_run.run_type_id is not NULL
          and     prt.run_type_id = paa_run.run_type_id
          and     prt.run_method <> 'C'
         ) paa_key
   where   pap.business_group_id = cp_business_group_id
   and     pap.payroll_id = paa_key.payroll_id
   and     paa_key.effective_date between pap.effective_start_date
                                and pap.effective_end_date  /* BUG: 5383895 paa_key.date_earned changed to paa_key.effective_date */
   and     ((pap.payroll_id = cp_payroll_id) OR
            (cp_payroll_id is NULL))
   and     ppp.assignment_action_id = paa_key.assignment_action_id
   and     ppp.org_payment_method_id = popm.org_payment_method_id
   and     paa_key.effective_date between popm.effective_start_date and
                                    popm.effective_end_date  /* BUG: 5383895 paa_key.date_earned changed to paa_key.effective_date */
   and     popm.business_group_id = cp_business_group_id
   and     ((popm.org_payment_method_id = cp_payment_method_id) OR
            (cp_payment_method_id is NULL))
   and     popm.org_payment_method_id = popm_tl.org_payment_method_id
   and     popm_tl.language = userenv('LANG')
   and     ppt.payment_type_id = popm.payment_type_id
   and     ppt.payment_type_id = ppt_tl.payment_type_id
   and     ppt_tl.language = userenv('LANG')
   and     ((ppt.payment_type_id =  cp_payment_type_id) OR
             (cp_payment_type_id is NULL))
   and     hou.organization_id = paa_key.tax_unit_id
   and     hou.language =  userenv('LANG')
   and     paf.assignment_id = paa_key.assignment_id
   and     paa_key.effective_date between paf.effective_start_date and
                                    paf.effective_end_date  /* BUG: 5383895 paa_key.date_earned changed to paa_key.effective_date */
   and     paf.person_id = ppf.person_id
   and     paa_key.effective_date between ppf.effective_start_date and
                                    ppf.effective_end_date     /* BUG: 5383895 paa_key.date_earned changed to paa_key.effective_date */
   order by ppt_tl.payment_type_name,popm_tl.org_payment_method_name,
        ppf.full_name;

    /*************************************************************
    ** This cursor returns the Payments processed for a particular
    ** assignment action and the Payment Amount. The
    ** cursor also accepts payroll_name, payment_method and
    ** payment_type as an input. Only the payment amount that is paid
    ** by the given payment_type or payment_method are returned .
    **************************************************************/
    Cursor c_payment_period (
                             cp_start_date           in date
                            ,cp_end_date             in date
                            ,cp_business_group_id    in number
                            ,cp_assignment_action_id in number
                            ,cp_pre_payment_id       in number
                             ) is
    select pay_us_employee_payslip_web.get_check_number(cp_assignment_action_id
                                       ,cp_pre_payment_id),/*check_no*/
          /* nvl(to_number(paa.serial_number),paa.assignment_action_id),*/
           paa.assignment_action_id,
           paa.payroll_action_id,
           paa.assignment_id,
           ppa.effective_date
    from
         pay_payroll_actions ppa,
         pay_assignment_actions paa,
         pay_action_interlocks pai
    where  pai.locked_action_id = cp_assignment_action_id
    and pai.locking_action_id = paa.assignment_action_id
    and paa.action_status = 'C'
    and paa.pre_payment_id = cp_pre_payment_id
    and paa.payroll_action_id = ppa.payroll_action_id
    and ppa.effective_date between cp_start_date and cp_end_date /* BUG: 5383895 ppa.date_earned changed to ppa.effective_date */
    and ppa.business_group_id = cp_business_group_id;

    cursor c_personal_paymeth_info (cp_personal_paymeth_id in number
                                                       default NULL,
                                   cp_effective_date         in date) IS   /* BUG: 5383895   cp_date_earned changed to cp_date_earned */
   /* New Query to get the Personal Payment Method Information
      for Payment Report */
   select decode(gv_leg_code,'CA',
                decode(pea.segment7,NULL,' ',
                       rtrim(substrb(pea.segment7,1,150))), 'US',--bug 2254026
                decode(pea.segment5,NULL,' ',
                      rtrim(substrb(pea.segment5,1,150))))
          /*Per'l Payment Method Bank_number for CA, Bank Name for US */
          ,pea.segment4 /* Per'l Payment Method Transit_code */
          ,pea.segment3  /* Per'l Payment Method Account_Number */
   from pay_personal_payment_methods_f pppm /*added newly to fix bug#2133040 */
       ,pay_external_accounts pea
   where pppm.personal_payment_method_id = cp_personal_paymeth_id
   and   cp_effective_date between pppm.effective_start_date and
                                pppm.effective_end_date    /* BUG: 5383895   cp_date_earned changed to cp_effective_date */
   and    pppm.external_account_id = pea.external_account_id(+);


    cursor c_payroll_paydate (cp_assignment_action_id in number,
                              cp_business_group_id    in number) IS
    /* Query to get the Pay Date of Quickpay or Payroll run */
    select ppa.effective_date,ptp.period_name
    from per_time_periods ptp,
         pay_payroll_actions ppa,
         pay_assignment_actions paa,
         pay_action_interlocks pai
    where  pai.locking_action_id = cp_assignment_action_id
    and pai.locked_action_id = paa.assignment_action_id
    and paa.action_status = 'C'
    and paa.run_type_id is not null
    and paa.payroll_action_id = ppa.payroll_action_id
    and ppa.action_type in ('Q','R')
    and ppa.business_group_id = cp_business_group_id
    and ptp.payroll_id = ppa.payroll_id
    and ppa.date_earned between ptp.start_date and ptp.end_date;

    /* Third Party Payment Query to get the Court Order/Case number
       Added this curosr to fix bug#2745577 */
    cursor c_case_number (cp_asg_id number,
                          cp_effective_date date,
                          cp_persnl_pmt_meth_id number,
                          cp_pmt_amount number) IS   /* BUG: 5383895   cp_date_earned changed to cp_effective_date */
    select peev.screen_entry_value
    from
       pay_element_entry_values_f 	peev,
       pay_input_values_f     		piv_att,
       pay_element_entries_f  		peef,
       pay_element_types_f       	pet
    where     peef.assignment_id = cp_asg_id
    AND     EXISTS (select null from pay_element_links_f pelf
                    where pelf.element_link_id= peef.element_link_id
                    and   pelf.element_type_id = pet.element_type_id
        	    and   cp_effective_date between
                        pelf.effective_start_date and pelf.effective_end_date        /* BUG: 5383895  date_earned changed to effective_date */
                    and   cp_effective_date between
                        pet.effective_start_date and pet.effective_end_date      /* BUG: 5383895  date_earned changed to effective_date */
                    AND	    pet.third_party_pay_only_flag = 'Y')
    AND    cp_effective_date between
            peef.effective_start_date and peef.effective_end_date    /* BUG: 5383895  date_earned changed to effective_date */
    AND	  pet.element_type_id	= piv_att.element_type_id
    AND   upper(piv_att.name)	= 'ATTACHMENT NUMBER'
    AND   cp_effective_date between
          piv_att.effective_start_date and piv_att.effective_end_date     /* BUG: 5383895  date_earned changed to effective_date */
    AND	peef.element_entry_id	= peev.element_entry_id
    AND	piv_att.input_value_id	= peev.input_value_id
    AND cp_effective_date between
        peev.effective_start_date and peev.effective_end_date      /* BUG: 5383895  date_earned changed to effective_date */
    AND peef.personal_payment_method_id = cp_persnl_pmt_meth_id
    AND peef.entry_information22 = cp_pmt_amount;


    /* Third Party Payment Check flag, to fix bug#2745577 */
    cursor c_tp_pmt_check (cp_org_pmt_method_id number) IS
    select 'Y'
    from pay_org_payment_methods_f
    where org_payment_method_id = cp_org_pmt_method_id
    and defined_balance_id is null;

   /* New Query to get the Payee_type, Payee_id
      for Third Party Payments, to fix bug#2745577 */
    cursor c_tp_payee_info (cp_personal_paymeth_id number
                                             default NULL,
                            cp_effective_date date) IS      /* BUG: 5383895   cp_date_earned changed to cp_effective_date */
    select pppm.payee_type,pppm.payee_id
    from pay_personal_payment_methods_f pppm
    where pppm.personal_payment_method_id = cp_personal_paymeth_id
    and   cp_effective_date between pppm.effective_start_date and
                                pppm.effective_end_date;     /* BUG: 5383895   cp_date_earned changed to cp_effective_date */

    /* Query to get the payee_name for payee_type 'O'
       Added this curosr to fix bug#2745577 */
    cursor c_payee_org_name (cp_payee_id number) IS
    select name from hr_all_organization_units_tl
    where organization_id = cp_payee_id
    and   language =  userenv('LANG');

    /* Query to get the payee_name for payee_type 'P'
        Added this curosr to fix bug#2745577 */
    cursor c_payee_full_name (cp_payee_id number,cp_effective_date date) IS         /* BUG: 5383895   cp_date_earned changed to cp_effective_date */
    select initcap(rtrim(ppf.title))||' '||rtrim(ppf.first_name)||' '||rtrim(ppf.last_name)
    from per_all_people_f ppf
    where ppf.person_id = cp_payee_id
    and cp_effective_date between ppf.effective_start_date and
                               ppf.effective_end_date;    /* BUG: 5383895   cp_date_earned changed to cp_effective_date */

    /*************************************************************
    To fetch the Payment status for Cheques/Deposit Advice Bug#5178951
    *************************************************************/
    cursor c_payment_status (p_payact_id number,
                             p_chkno number
                             ) IS
     SELECT void_pa.effective_date
      FROM pay_assignment_actions chq_or_mag_aa,
           pay_action_interlocks,
           pay_assignment_actions void_aa,
           pay_payroll_actions    void_pa
      WHERE chq_or_mag_aa.payroll_action_id = p_payact_id
        AND ((fnd_number.canonical_to_number(chq_or_mag_aa.serial_number)
                   = p_chkno) OR ( p_chkno is NULL))
        AND locked_action_id = chq_or_mag_aa.assignment_action_id
        AND locking_action_id = void_aa.assignment_action_id
        AND void_pa.payroll_action_id = void_aa.payroll_action_id
        AND void_pa.action_type = 'D';

    /***************************************************************
      added to fetch the payment number for voided payments bug#5225939
    ********************************************************************/
    Cursor c_check_number(cp_pre_payment_action in number
                       ,cp_pre_payment_id in number) is
    select decode(ppa_pymt.action_type,
                  'M', to_char(NVL(ppp.source_action_id,cp_pre_payment_action)),
                  paa_pymt.serial_number)
      from pay_pre_payments       ppp,
           pay_assignment_actions paa_pymt,
           pay_payroll_actions ppa_pymt,
           pay_action_interlocks pai
     where pai.locked_action_id = cp_pre_payment_action
       and paa_pymt.assignment_action_id = pai.locking_action_id
       and ppa_pymt.payroll_action_id = paa_pymt.payroll_action_id
       and ppa_pymt.action_type in ('M','H', 'E')
       and paa_pymt.pre_payment_id = cp_pre_payment_id
       and ppp.pre_payment_id = paa_pymt.pre_payment_id;

    /*************************************************************
    ** Local Variables
    *************************************************************/
    ln_assignment_action_id        NUMBER;
    ln_assignment_id               NUMBER;
    ln_person_id                   NUMBER;
    ld_effective_date              DATE;
    ld_date_earned                 DATE;
    lv_action_type                 VARCHAR2(100);
    ln_payroll_action_id           NUMBER;
    lv_gre_name                    VARCHAR2(100);
    lv_emp_last_name               VARCHAR2(100);
    lv_emp_first_name              VARCHAR2(100);
    lv_emp_middle_names            VARCHAR2(100);
    lv_emp_number                  VARCHAR2(100);
    lv_emp_full_name               VARCHAR2(200);
    ld_start_date                  DATE;
    ld_end_date                    DATE;
    lv_assignment_number           VARCHAR2(100);
    lv_payroll_name                VARCHAR2(100);
    lv_consolidation_set_name      VARCHAR2(100);
    ln_time_period_id              NUMBER;
    lv_period_name                 VARCHAR2(100);
    ln_payroll_id                  NUMBER;
    ln_tax_unit_id                 NUMBER;
    lv_pmt_type_name               VARCHAR2(100);
    lv_check_no                    NUMBER;
    ln_pmt_amount                  NUMBER;
    ln_pmt_total_amount            NUMBER := 0;
    ln_persnl_pmt_method_id        NUMBER;
    ln_org_pmt_method_id           NUMBER;
    lv_org_pmt_method_name         VARCHAR2(100);
    lv_bank_number                 VARCHAR2(100);
    lv_acct_number                 VARCHAR2(100);
    ld_pay_date                    DATE;
    lv_transit_code                VARCHAR2(100);
    lv_total                       VARCHAR2(100);
    lv_total_label                 VARCHAR2(100);
    ln_locked_action_id            NUMBER;
    ln_pre_payment_id              NUMBER;

    lb_print_row                   BOOLEAN := FALSE;

    lv_header_label                VARCHAR2(32000);
    lv_header_label1               VARCHAR2(32000);
    lv_header_label2               VARCHAR2(32000);

    lv_data_row                    VARCHAR2(32000);
    lv_data_row1                   VARCHAR2(32000);
    lv_data_row2                   VARCHAR2(32000);

    ln_count                       NUMBER := 0;

    /* Third Party Payment Check variables */
    lv_tp_payment_flag             VARCHAR2(5):= 'N';
    lv_case_number                 VARCHAR2(25);
    lv_payee_type                  VARCHAR2(5);
    lv_payee_name                  VARCHAR2(200);
    ln_payee_id                    NUMBER := NULL;
    lv_payroll_actid               NUMBER;
    lv_void_date                   DATE;
    lv_payment_status              VARCHAR2(10);

    ln_defined_balance_id		pay_org_payment_methods_f.defined_balance_id%TYPE;  /* BUG: 5383895 added */

BEGIN
   hr_utility.set_location(gv_package_name || '.payment_extract', 10);
/*   hr_utility.trace_on(null, 'ORACLE');   */

       hr_utility.trace('Payment Type ID = ' ||
                           nvl(to_char(p_payment_type_id), 'NULL'));
       hr_utility.trace('Payment Method ID = '    ||
                                nvl(to_char(p_payment_method_id), 'NULL'));
       hr_utility.trace('Consolidation Set ID = '   ||
                                nvl(to_char(p_consolidation_set_id), 'NULL'));
       hr_utility.trace('Payroll ID = '   ||
                                nvl(to_char(p_payroll_id), 'NULL'));
       hr_utility.trace('Tax Unit ID = '   ||
                                nvl(to_char(p_tax_unit_id), 'NULL'));
       hr_utility.trace('Business Group Id = '   ||
                                nvl(to_char(p_business_group_id), 'NULL'));
       hr_utility.trace('Start Date = '   ||
                                nvl(p_start_date, 'NULL'));
       hr_utility.trace('End Date = '   ||
                                nvl(p_end_date, 'NULL'));

       gv_business_group_id := p_business_group_id;

   formated_static_header( p_output_file_type
                          ,lv_header_label1
                          ,lv_header_label2);

   lv_header_label := lv_header_label1;

   hr_utility.set_location(gv_package_name || '.payment_extract', 70);
   /****************************************************************
   ** Concatenating the second Header Label which includes the User
   ** Defined data set so that it is printed at the end of the
   ** report.
   ****************************************************************/
   lv_header_label := lv_header_label || lv_header_label2;
   hr_utility.set_location(gv_package_name || '.payment_extract', 80);
   hr_utility.trace('Static and Payment Label = ' || lv_header_label);


   fnd_file.put_line(fnd_file.output, formated_header_string(
                                       hr_general.decode_fnd_comm_lookup
                                        ('PAYMENT_REGISTER_LABELS',
                                         'TITLE')
                                         ,p_output_file_type
                                         ));

   hr_utility.set_location(gv_package_name || '.payment_extract', 90);

   /****************************************************************
   ** Print the Header Information. If the format is HTML then open
   ** the body and table before printing the header info, otherwise
   ** just print the header information.
   ****************************************************************/
   if p_output_file_type ='HTML' then
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<body>');
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<table border=1>');
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<tr>');
   end if;
   fnd_file.put_line(fnd_file.output, lv_header_label);

   if p_output_file_type ='HTML' then
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</tr>');
   end if;

   hr_utility.set_location(gv_package_name || '.payment_extract', 100);
   /*****************************************************
   ** Start of the Data Section of the Report
   *****************************************************/
   hr_utility.trace('Before open of c_assignments cursor');
   open c_assignments( fnd_date.canonical_to_date(p_start_date)
                      ,fnd_date.canonical_to_date(p_end_date)
                      ,p_payroll_id
                      ,p_consolidation_set_id
                      ,p_payment_type_id
                      ,p_tax_unit_id
                      ,p_payment_method_id
                      ,p_business_group_id
                     );

   loop

      fetch c_assignments into lv_gre_name
                              ,ln_tax_unit_id
                              ,lv_emp_full_name
                              ,lv_emp_number
                              ,lv_assignment_number
                              ,lv_pmt_type_name
                              ,ln_pmt_amount
                              ,ln_persnl_pmt_method_id
                              ,ln_org_pmt_method_id
                              ,lv_org_pmt_method_name
                              ,ln_person_id
                              ,lv_payroll_name
                              ,ln_pre_payment_id
                              ,ln_locked_action_id
			      ,ld_date_earned
			      ,ld_effective_date   /* BUG: 5383895  added */
			      ,ln_defined_balance_id;  /* BUG: 5383895 added  */


      if c_assignments%notfound then
         hr_utility.set_location(gv_package_name || '.payment_extract', 105);
         exit;
      end if;

      hr_utility.trace('Before open of c_payment_period cursor');
      open c_payment_period ( fnd_date.canonical_to_date(p_start_date)
                            ,fnd_date.canonical_to_date(p_end_date)
                            ,p_business_group_id
                            ,ln_locked_action_id
                            ,ln_pre_payment_id
                            );
       loop   /*to get payment_number and period_name*/

         fetch c_payment_period into lv_check_no
                                    ,ln_assignment_action_id
                                    ,lv_payroll_actid
                                    ,ln_assignment_id
                                    ,ld_effective_date ;

     /***********************************************************************
     *** The following condition checks whether the pre-payment is paid   ***
     *** or not, if its not paid then the c_payment_period cursor doesn't ***
     *** return any record and we will not display that record,           ***
     *** also we will not consider that payment amount for total payment  ***
     ***********************************************************************/

         if c_payment_period%notfound then
            hr_utility.set_location(gv_package_name || '.payment_extract',108);
            exit;
         else
            if ln_pmt_amount > 0 then
              lb_print_row := TRUE;
              ln_pmt_total_amount := ln_pmt_total_amount + ln_pmt_amount;
            end if;
         end if;

         open c_payment_status(lv_payroll_actid,
                               lv_check_no);
         fetch c_payment_status into lv_void_date;
             IF c_payment_status%found THEN
                lv_payment_status := 'Voided';
		/*****added against 5225939****/
                open c_check_number(ln_locked_action_id ,ln_pre_payment_id);
		fetch c_check_number into lv_check_no;
		close c_check_number;
		/****end 5225939********/
             ELSE
                lv_payment_status := ' ';
             END IF;
         close c_payment_status;

         if ln_persnl_pmt_method_id is NULL then
            lv_bank_number  := NULL;
            lv_transit_code := NULL;
            lv_acct_number  := NULL;
         else
            begin

                 hr_utility.trace('Before open of c_personal_paymeth_info cursor');
                 open c_personal_paymeth_info(ln_persnl_pmt_method_id,
                                              ld_effective_date);  /* BUG: 5383895 ld_date_earned changed to ld_effective_date  */

                   fetch c_personal_paymeth_info into lv_bank_number,
                                                      lv_transit_code,
                                                      lv_acct_number;

                   hr_utility.trace('Bank Number = '||lv_bank_number);
                   hr_utility.trace('Transit code = '||lv_transit_code);
                   hr_utility.trace('Acct Number = '||lv_acct_number);

                   if c_personal_paymeth_info%NOTFOUND then
                    hr_utility.trace('Org_Paymeth found and Personal Paymeth not found ');

                     lv_bank_number := NULL;
                     lv_transit_code := NULL;
                     lv_acct_number := NULL;
                   end if;
                   close c_personal_paymeth_info;

                   exception when others then
                    hr_utility.trace('Exception in Persl Paymeth Cursor ');
                    lv_bank_number := NULL;
                    lv_transit_code := NULL;
                    lv_acct_number := NULL;
                    close c_personal_paymeth_info;

              end;
           end if; /* Validation for personal payment method ends here */

           hr_utility.trace('Before open of c_payroll_paydate cursor');
           open c_payroll_paydate(ln_locked_action_id
                                  ,p_business_group_id);

           fetch c_payroll_paydate into ld_pay_date, lv_period_name;
           if c_payroll_paydate%NOTFOUND then
              ld_pay_date := null;
              lv_period_name := null;
              hr_utility.trace('c_payroll_paydate not found ');
              hr_utility.trace('Assignment Action ID = '||ln_assignment_action_id);
           end if;
           close c_payroll_paydate;

        /* Third Party Payment Check start1
           Added this curosr to fix bug#2745577

           hr_utility.trace('Before open of c_tp_pmt_check cursor');
           open c_tp_pmt_check(ln_org_pmt_method_id);
           fetch c_tp_pmt_check into lv_tp_payment_flag;

              if c_tp_pmt_check%NOTFOUND then
                 lv_tp_payment_flag := null;
                 hr_utility.trace('c_tp_pmt_check not found ');
                 hr_utility.trace('Assignment Action ID = '||ln_assignment_action_id);
                 hr_utility.trace('Org Pmt Method id = '||ln_org_pmt_method_id);
              end if;
           close c_tp_pmt_check;

           If lv_tp_payment_flag = 'Y' then     Commented BUG: 5383895  */


        hr_utility.trace('Before check ln_defined_balance_id is NULL  ');

        If ln_defined_balance_id is NULL then   /* 5383895 added in place of the c_tp_pmt_check cursor */

              hr_utility.trace('Third Party Payment Method found ');
              open c_case_number(ln_assignment_id,ld_effective_date,
                                 ln_persnl_pmt_method_id,ln_pmt_amount);   /* BUG: 5383895  ld_date_earned changed to ld_effective_date */
              fetch c_case_number into lv_case_number;

                if c_case_number%NOTFOUND then
                   lv_case_number := null;
                   hr_utility.trace('c_case_number not found ');
                   hr_utility.trace('Assignment ID = '||ln_assignment_id);
                end if;
              close c_case_number;

              open c_tp_payee_info(ln_persnl_pmt_method_id,ld_effective_date );   /* BUG: 5383895  ld_date_earned changed to ld_effective_date */
              fetch c_tp_payee_info into lv_payee_type,ln_payee_id;

                if c_tp_payee_info%NOTFOUND then
                   lv_payee_type := null;
                   ln_payee_id := null;
                   hr_utility.trace('c_tp_payee_info not found ');
                   hr_utility.trace('Assignment Action ID = '||
                                      ln_assignment_action_id);
                end if;
              close c_tp_payee_info;

              if lv_payee_type = 'O' and ln_payee_id is not null then
                 open c_payee_org_name(ln_payee_id);
                 fetch c_payee_org_name into lv_payee_name;

                   if c_payee_org_name%NOTFOUND then
                      lv_payee_name := null;
                      hr_utility.trace('c_payee_org_name not found ');
                      hr_utility.trace('Assignment Action ID = '||
                                            ln_assignment_action_id);
                   end if;
                 close c_payee_org_name;

              end if;

              if lv_payee_type = 'P' and ln_payee_id is not null then
                 open c_payee_full_name(ln_payee_id,ld_effective_date);   /* BUG: 5383895  ld_date_earned changed to ld_effective_date */
                 fetch c_payee_full_name into lv_payee_name;

                 if c_payee_full_name%NOTFOUND then
                    lv_payee_name := null;
                    hr_utility.trace('c_payee_full_name not found ');
                    hr_utility.trace('Assignment Action ID = '||
                                         ln_assignment_action_id);
                 end if;
                 close c_payee_full_name;

              end if;

           Else
                lv_case_number := NULL;
                lv_payee_name  := NULL;

           End if;
         /* Third Party Payment Check end1 */

        end loop;
      close c_payment_period;

      hr_utility.set_location(gv_package_name || '.payment_extract', 110);
      hr_utility.trace('Assignment ID = '     || ln_assignment_id);
      hr_utility.trace('Assignment Action ID = ' || ln_assignment_action_id);

         hr_utility.set_location(gv_package_name || '.payment_extract', 120);
         /********************************************************************
         ** Populate the user defined PL/SQL table to print the additional
         ** columns in the report.
         ********************************************************************/
/*         pay_ca_payreg_extract_data_pkg.populate_table(
                             p_assignment_id => ln_assignment_id
                            ,p_person_id     => ln_person_id
                            ,p_assignment_action_id => ln_assignment_action_id
                            ,p_effective_date=> ld_effective_date
                            );
*/

         hr_utility.set_location(gv_package_name || '.payment_extract', 125);

             formated_static_data(
                               lv_emp_full_name
                              ,lv_assignment_number
                              ,lv_pmt_type_name
                              ,lv_check_no
                              ,lv_bank_number
                              ,lv_transit_code
                              ,lv_acct_number
                              ,to_char(ln_pmt_amount,'9999999990.00')
                              ,lv_payroll_name
                              ,lv_gre_name
                              ,lv_period_name
                              ,lv_org_pmt_method_name
                              ,to_char(ld_pay_date,'YYYY/MM/DD')
                              ,lv_case_number
                              ,lv_payee_name
                              ,lv_payment_status
                              ,p_output_file_type
                              ,lv_data_row1
                              ,lv_data_row2);

         lv_data_row := lv_data_row1;
         hr_utility.set_location(gv_package_name || '.payment_extract', 130);
         hr_utility.trace('Effective Date = '    || to_char(ld_effective_date,
                                                             'dd-mon-yyyy'));

         hr_utility.trace('Assignment Action ID = ' || ln_assignment_action_id);

         hr_utility.trace('Actual Data lv_data_row1 = ' || lv_data_row1);
         hr_utility.trace('Actual Data lv_data_row2 = ' || lv_data_row2);

            /****************************************************************
            ** Concatnating the second Header Label which includes the User
            ** Defined data set so that it is printed at the end of the
            ** report.
            ****************************************************************/

     /*** The following condition added to print only Non-Zero Payments ***/
       if lb_print_row then

            lv_data_row := lv_data_row || lv_data_row2;

            if p_output_file_type ='HTML' then
               lv_data_row := '<tr>' || lv_data_row || '</tr>' ;
            end if;

            FND_FILE.PUT_LINE(FND_FILE.OUTPUT, lv_data_row);

        end if;

     /*** End of condition for Non-Zero Payments ***/


      /*****************************************************************
      ** initialize Print Row valiable again
      *****************************************************************/
      lb_print_row := FALSE;

      /*****************************************************************
      ** initialize Data varaibles
      *****************************************************************/
      lv_data_row  := null;
      lv_data_row1 := null;
      lv_data_row2 := null;
      lv_tp_payment_flag := 'N';
      lv_payee_type := null;
      ln_payee_id := null;

   end loop;
   close c_assignments;

/***  Added to print Payment_Total for output_type HTML only ***/

   if p_output_file_type ='HTML' then


      gv_tot_amt_lbl := hr_general.decode_fnd_comm_lookup --bug 3039110
                             ('PAYMENT_REGISTER_LABELS',
                              'TOT_PMT_AMT');
--      gv_tot_amt_lbl := payment_labels('PAYMENT_REGISTER_LABELS',
--                                       'TOT_PMT_AMT');
   lv_total_label :=
             formated_data_string (p_input_string =>
                                hr_general.decode_fnd_comm_lookup --bug 3039110
                                         ('PAYMENT_REGISTER_LABELS',
                                          'TOT_PMT_AMT')
                                          ,p_bold         => 'Y'
                                          ,p_output_file_type =>
                                                        p_output_file_type);

    lv_total := '<td align="right">'||'<b> '||
                 to_char(ln_pmt_total_amount,'999999999990.00')||'</b>'||
                 gv_html_end_data;

/*   lv_total := formated_data_string (p_input_string =>
                                                 to_char(ln_pmt_total_amount,
                                                          '999999999990.00')
                                     ,p_bold         => 'Y'
                                     ,p_output_file_type => p_output_file_type);
*/

      lv_data_row := lv_total_label||lv_total;
      lv_data_row := '<tr>'||lv_data_row||'</tr>';

      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, lv_data_row);

      lv_data_row  := null;
   end if;

/***      Payment Total Print ends here ***/

   /*****************************************************
   ** Close of the Data Section of the Report
   *****************************************************/
   if p_output_file_type ='HTML' then
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</table></body></html>');
   end if;
   hr_utility.trace('Concurrent Request ID = ' || FND_GLOBAL.CONC_REQUEST_ID);


   /**********************************************************
   ** Not Required as the output file type is HTML by default
   ***********************************************************
   if p_output_file_type ='HTML' then
       update fnd_concurrent_requests
        set output_file_type = 'HTML'
       where request_id = FND_GLOBAL.CONC_REQUEST_ID ;

      commit;
   end if;
   **********************************************************/

   gv_leg_code := NULL;
/*  hr_utility.trace_off; */

  END payment_extract;

end pay_ca_payreg_extract_pkg;

/
