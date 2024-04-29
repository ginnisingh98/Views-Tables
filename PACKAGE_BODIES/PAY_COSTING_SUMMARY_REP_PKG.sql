--------------------------------------------------------
--  DDL for Package Body PAY_COSTING_SUMMARY_REP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_COSTING_SUMMARY_REP_PKG" AS
/* $Header: pyrpcsrp.pkb 120.3.12010000.4 2009/05/05 04:55:23 ankagarw ship $ */

   /************************************************************
   ** Local Package Variables
   ************************************************************/
   gv_title               VARCHAR2(100):= 'Costing Summary Report';
   gc_csv_delimiter       VARCHAR2(1) := ',';
   gc_csv_data_delimiter  VARCHAR2(1) := '"';
   gv_html_start_data     VARCHAR2(5) := '<td>'  ;
   gv_html_END_data       VARCHAR2(5) := '</td>' ;

   gv_package_name        VARCHAR2(50) := 'pay_costing_summary_rep_pkg';
   gv_title1              VARCHAR2(100);
   gv_title2              VARCHAR2(100);


 /************************************************************
  ** Procedure: formated_title_page
  **
  ** Purpose  : This function displays the title part of the
  **            report that shows the Concurrent program
  **		parameters passed.
  ************************************************************/

 PROCEDURE formated_title_page(
               p_output_file_type in VARCHAR2
              ,p_business_group in VARCHAR2
              ,p_start_date in date
              ,p_end_date in date
              ,p_costing in VARCHAR2
              ,p_payroll_name in VARCHAR2
              ,p_consolidation_set_name in VARCHAR2
              ,p_gre_name in VARCHAR2
              ,p_include_accruals in VARCHAR2
              ,p_sort_order1 in VARCHAR2
              ,p_sort_order2 in VARCHAR2
              )
   IS
   lv_payroll_name varchar2(240);
   lv_consolidation_set_name varchar2(240);
   lv_gre_name VARCHAR2(240);
   lv_include_accruals VARCHAR2(240);
   lv_sort_order1 VARCHAR2(240);
   lv_sort_order2 VARCHAR2(240);
   lv_start_date VARCHAR2(20) := to_char(p_start_date,'DD-MON-YYYY'); --Bug 3305391
   lv_end_date VARCHAR2(20) := to_char(p_end_date,'DD-MON-YYYY'); --Bug 3305391

  BEGIN
      IF p_output_file_type ='HTML' THEN
             FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<body>');
             FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<table border=0 align=CENTER>');
             FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<tr>');
             IF p_payroll_name IS NULL THEN
                lv_payroll_name:='&nbsp;';
             ELSE lv_payroll_name:= p_payroll_name;
             END IF;
             IF p_consolidation_set_name IS NULL THEN
	        lv_consolidation_set_name:='&nbsp;';
             ELSE lv_consolidation_set_name:=p_consolidation_set_name;
             END IF;
             IF p_gre_name IS NULL THEN
	        lv_gre_name:='&nbsp;';
             ELSE
                lv_gre_name:=p_gre_name;
             END IF;
             IF p_include_accruals IS NULL THEN
	        lv_include_accruals:='&nbsp;';
             ELSE lv_include_accruals:=p_include_accruals;
             END IF;
             IF p_sort_order1 IS NULL THEN
	        lv_sort_order1:='&nbsp;';
             ELSE lv_sort_order1:=p_sort_order1;
             END IF;
             IF p_sort_order2 IS NULL THEN
	        lv_sort_order2:='&nbsp;';
             ELSE lv_sort_order2:=p_sort_order2;
             END IF;
      END IF;
      hr_utility.set_location(gv_package_name || '.formated_title_page.',10);
      FND_FILE.PUT_LINE(fnd_file.output,pay_us_payroll_utils.formated_data_string(
                         p_input_string=>'Business Group: '
                        ,p_output_file_type=>p_output_file_type
			,p_bold=>'N')||
                         pay_us_payroll_utils.formated_data_string(
                         p_input_string=>p_business_group
                        ,p_output_file_type=>p_output_file_type
			,p_bold=>'N'));

      IF p_output_file_type ='HTML' THEN
	 FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</tr><tr>');
      END IF;

      FND_FILE.PUT_LINE(fnd_file.output,pay_us_payroll_utils.formated_data_string(
                         p_input_string=>'Costing Effective Date Begin: '
                        ,p_output_file_type=>p_output_file_type
			,p_bold=>'N')||
                         pay_us_payroll_utils.formated_data_string(
                         p_input_string=>lv_start_date
                        ,p_output_file_type=>p_output_file_type
			,p_bold=>'N'));


      IF p_output_file_type ='HTML' THEN
	           FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</tr><tr>');
      END IF;

      FND_FILE.PUT_LINE(fnd_file.output,pay_us_payroll_utils.formated_data_string(
                         p_input_string=>'Costing Effective Date End: '
                        ,p_output_file_type=>p_output_file_type
			,p_bold=>'N')||
                         pay_us_payroll_utils.formated_data_string(
                         p_input_string=>lv_end_date
                        ,p_output_file_type=>p_output_file_type
			,p_bold=>'N'));


     IF p_output_file_type ='HTML' THEN
	           FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</tr>');
     END IF;

     IF p_costing IS NOT NULL THEN
        FND_FILE.PUT_LINE(fnd_file.output,pay_us_payroll_utils.formated_data_string(
                          p_input_string=>'Costing Process: '
                         ,p_output_file_type=>p_output_file_type
			 ,p_bold=>'N')||
                          pay_us_payroll_utils.formated_data_string(
                          p_input_string=>lv_start_date ||'('||p_costing||')'
                         ,p_output_file_type=>p_output_file_type
			 ,p_bold=>'N'));
     ELSE
        FND_FILE.PUT_LINE(fnd_file.output,pay_us_payroll_utils.formated_data_string(
	                          p_input_string=>'Costing Process: '
                                 ,p_output_file_type=>p_output_file_type
				 ,p_bold=>'N'));
     END IF;



     IF p_output_file_type ='HTML' THEN
	           FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</tr><tr>');
     END IF;

     FND_FILE.PUT_LINE(fnd_file.output,pay_us_payroll_utils.formated_data_string(
                        p_input_string=>'Payroll Name: '
                       ,p_output_file_type=>p_output_file_type
		       ,p_bold=>'N')||
                        pay_us_payroll_utils.formated_data_string(
                        p_input_string=>lv_payroll_name
                       ,p_output_file_type=>p_output_file_type
		       ,p_bold=>'N'));


     IF p_output_file_type ='HTML' THEN
	           FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</tr><tr>');
     END IF;

     FND_FILE.PUT_LINE(fnd_file.output,pay_us_payroll_utils.formated_data_string(
                        p_input_string=>'Consolidation Set: '
                       ,p_output_file_type=>p_output_file_type
		       ,p_bold=>'N')||
                        pay_us_payroll_utils.formated_data_string(
                        p_input_string=>lv_consolidation_set_name
                       ,p_output_file_type=>p_output_file_type
		       ,p_bold=>'N'));


     IF p_output_file_type ='HTML' THEN
	           FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</tr><tr>');
     END IF;

     FND_FILE.PUT_LINE(fnd_file.output,pay_us_payroll_utils.formated_data_string(
                        p_input_string=>'GRE: '
                       ,p_output_file_type=>p_output_file_type
		       ,p_bold=>'N')||
                        pay_us_payroll_utils.formated_data_string(
                        p_input_string=>lv_gre_name
                       ,p_output_file_type=>p_output_file_type
		       ,p_bold=>'N'));


     IF p_output_file_type ='HTML' THEN
	           FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</tr><tr>');
     END IF;

     FND_FILE.PUT_LINE(fnd_file.output,pay_us_payroll_utils.formated_data_string(
                        p_input_string=>'Include Accruals: '
                       ,p_output_file_type=>p_output_file_type
		       ,p_bold=>'N')||
                        pay_us_payroll_utils.formated_data_string(
                        p_input_string=>lv_include_accruals
                       ,p_output_file_type=>p_output_file_type
		       ,p_bold=>'N'));


     IF p_output_file_type ='HTML' THEN
	           FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</tr><tr>');
     END IF;

     FND_FILE.PUT_LINE(fnd_file.output,pay_us_payroll_utils.formated_data_string(
                        p_input_string=>'Sort Option One: '
                       ,p_output_file_type=>p_output_file_type
		       ,p_bold=>'N')||
                        pay_us_payroll_utils.formated_data_string(
                        p_input_string=>lv_sort_order1
                       ,p_output_file_type=>p_output_file_type
		       ,p_bold=>'N'));


     IF p_output_file_type ='HTML' THEN
	           FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</tr><tr>');
     END IF;

     FND_FILE.PUT_LINE(fnd_file.output,pay_us_payroll_utils.formated_data_string(
                        p_input_string=>'Sort Option Two: '
                       ,p_output_file_type=>p_output_file_type
		       ,p_bold=>'N')||
                        pay_us_payroll_utils.formated_data_string(
                        p_input_string=>lv_sort_order2
                       ,p_output_file_type=>p_output_file_type
		       ,p_bold=>'N'));


     IF p_output_file_type ='HTML' THEN
	           FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</tr></table><br></br>');
     END IF;
     hr_utility.set_location(gv_package_name || '.formated_title_page.',20);

  END formated_title_page;

/************************************************************
  ** Procedure: formated_static_header
  ** Returns  : Concatenated Title strings for the first table
  **            that contains costing info
  ** Purpose  : This procedure is used to get the concatenated
  **            title information for the first table of costing
  **            info.
  ************************************************************/

 PROCEDURE formated_static_header(
               p_output_file_type in VARCHAR2
              ,p_static_label1    out nocopy VARCHAR2
              ,p_static_label2    out nocopy VARCHAR2
              )
   IS

     lv_format1          VARCHAR2(32000);
     lv_format2          VARCHAR2(32000);

  BEGIN
  hr_utility.set_location(gv_package_name || '.formated_static_header.',10);
  lv_format1:= pay_us_payroll_utils.formated_data_string(p_input_string=>'Payroll'
                                                        ,p_output_file_type=>p_output_file_type
                                                        ,p_bold=>'Y')||
               pay_us_payroll_utils.formated_data_string(p_input_string=>'GRE'
                                                        ,p_output_file_type=>p_output_file_type
                                                        ,p_bold=>'Y')||
               pay_us_payroll_utils.formated_data_string(p_input_string=>'Input Value Name'
                                                        ,p_output_file_type=>p_output_file_type
                                                        ,p_bold=>'Y')||
               pay_us_payroll_utils.formated_data_string(p_input_string=>'Unit Of Measure'
                                                        ,p_output_file_type=>p_output_file_type
                                                        ,p_bold=>'Y');


  lv_format2:= pay_us_payroll_utils.formated_data_string(p_input_string=>'Credit Amount'
                                                        ,p_output_file_type=>p_output_file_type
                                                        ,p_bold=>'Y')||
               pay_us_payroll_utils.formated_data_string(p_input_string=>'Debit Amount'
                                                        ,p_output_file_type=>p_output_file_type
                                                        ,p_bold=>'Y')||
               pay_us_payroll_utils.formated_data_string(p_input_string=>'Accrual Type'
                                                        ,p_output_file_type=>p_output_file_type
                                                        ,p_bold=>'Y');

  p_static_label1 := lv_format1;
  p_static_label2 := lv_format2;
  hr_utility.trace('Static Label1 = ' || lv_format1);
  hr_utility.trace('Static Label2 = ' || lv_format2);
  hr_utility.set_location(gv_package_name || '.formated_static_header', 20);

  END formated_static_header;

 /************************************************************
  ** Procedure: formated_totals_header
  ** Returns  : Concatenated Title strings for the second table
  **            that contains cost center wise costing totals
  **            for each payroll or GRE
  ** Purpose  : This procedure is used to get the concatenated
  **            title information for the second table that
  **            contains costing totals for each payroll or GRE
  ************************************************************/

 PROCEDURE formated_totals_header(p_sort_order1 in VARCHAR2
                                 ,p_output_file_type in VARCHAR2
                                 ,p_static_label1    out nocopy VARCHAR2
                                 ,p_static_label2    out nocopy VARCHAR2
                                 )
   IS

     lv_format1          VARCHAR2(32000);
     lv_format2          VARCHAR2(32000);
     lv_gre_or_payroll  VARCHAR2(240);

  BEGIN

  hr_utility.set_location(gv_package_name || '.formated_totals_header', 20);
  IF upper(p_sort_order1)='PAYROLL NAME' THEN
     lv_gre_or_payroll:='Payroll Name';
  ELSE lv_gre_or_payroll:='GRE Name';
  END IF;


  lv_format1:= pay_us_payroll_utils.formated_data_string(p_input_string=>lv_gre_or_payroll
                                                        ,p_output_file_type=>p_output_file_type
                                                        ,p_bold=>'Y')||
               pay_us_payroll_utils.formated_data_string(p_input_string=>'Unit of Measure'
                                                        ,p_output_file_type=>p_output_file_type
                                                        ,p_bold=>'Y');


  lv_format2:= pay_us_payroll_utils.formated_data_string(p_input_string=>'Credit Amount'
                                                        ,p_output_file_type=>p_output_file_type
                                                        ,p_bold=>'Y')||
               pay_us_payroll_utils.formated_data_string(p_input_string=>'Debit Amount'
                                                        ,p_output_file_type=>p_output_file_type
                                                        ,p_bold=>'Y');

  p_static_label1 := lv_format1;
  p_static_label2 := lv_format2;
  hr_utility.trace('Static Label1 = ' || lv_format1);
  hr_utility.trace('Static Label2 = ' || lv_format2);
  hr_utility.set_location(gv_package_name || '.formated_totals_header', 20);

  END formated_totals_header;

  /************************************************************
  ** Procedure: formated_cons_totals_header1
  ** Returns  : Concatenated Title strings for the third table
  **            that contains consolidated costing totals for
  **            the selected payroll or GRE
  ** Purpose  : This procedure is used to get the concatenated
  **            title information for the third table that
  **            contains consolidated costing totals for the
  **            selected payroll or GRE
  ************************************************************/

  PROCEDURE formated_cons_totals_header1(p_sort_order1 in VARCHAR2
                ,p_output_file_type in VARCHAR2
                ,p_static_label    out nocopy VARCHAR2
                 )
     IS

       lv_format          VARCHAR2(32000);
       lv_gre_or_payroll  VARCHAR2(240);

    BEGIN
    hr_utility.set_location(gv_package_name || '.formated_cons_totals_header1', 10);
    IF upper(p_sort_order1)='PAYROLL NAME' THEN
    	lv_gre_or_payroll:='Payroll Name';
    ELSE lv_gre_or_payroll:='GRE Name';
    END IF;

    lv_format:= pay_us_payroll_utils.formated_data_string(p_input_string=>lv_gre_or_payroll
                                                         ,p_output_file_type=>p_output_file_type
                                                         ,p_bold=>'Y')||
                pay_us_payroll_utils.formated_data_string(p_input_string=>'Credit Amount'
                                                          ,p_output_file_type=>p_output_file_type
                                                          ,p_bold=>'Y')||
                pay_us_payroll_utils.formated_data_string(p_input_string=>'Debit Amount'
                                                          ,p_output_file_type=>p_output_file_type
                                                          ,p_bold=>'Y')||
                pay_us_payroll_utils.formated_data_string(p_input_string=>'Unit of Measure'
                                                          ,p_output_file_type=>p_output_file_type
                                                          ,p_bold=>'Y');

    p_static_label := lv_format;
    hr_utility.trace('Static Label = ' || lv_format);
    hr_utility.set_location(gv_package_name || '.formated_cons_total_header1', 20);

  END formated_cons_totals_header1;

  /************************************************************
  ** Procedure: formated_cons_totals_header2
  ** Returns  : Concatenated Title strings for the last table
  **            that contains consolidated report totals
  ** Purpose  : This procedure is used to get the concatenated
  **            title information for the last table that
  **            contains consolidated report totals
  ************************************************************/


  PROCEDURE formated_cons_totals_header2(
                                         p_output_file_type in VARCHAR2
                                        ,p_static_label    out nocopy VARCHAR2
                                        )
       IS

         lv_format          VARCHAR2(32000);

  BEGIN
      hr_utility.set_location(gv_package_name || '.formated_cons_totals_header2', 10);
      lv_format:=  pay_us_payroll_utils.formated_data_string(p_input_string=>'Credit Amount'
                                                            ,p_output_file_type=>p_output_file_type
                                                            ,p_bold=>'Y')||
                   pay_us_payroll_utils.formated_data_string(p_input_string=>'Debit Amount'
                                                            ,p_output_file_type=>p_output_file_type
                                                            ,p_bold=>'Y')||
                   pay_us_payroll_utils.formated_data_string(p_input_string=>'Unit of Measure'
                                                            ,p_output_file_type=>p_output_file_type
                                                            ,p_bold=>'Y') ;


      p_static_label := lv_format;
      hr_utility.trace('Static Label = ' || lv_format);
      hr_utility.set_location(gv_package_name || '.formated_cons_total_header2', 20);

  END formated_cons_totals_header2;

  /************************************************************
  ** Procedure: formated_grand_totals_header
  ** Returns  : Concatenated Title strings for the fourth table
  **            that contains cost center wise grand totals for
  **            the report
  ** Purpose  : This procedure is used to get the concatenated
  **            title information for the fourth table that
  **            contains report totals
  ************************************************************/

  PROCEDURE formated_grand_totals_header(
               p_output_file_type in VARCHAR2
              ,p_static_label1    out nocopy VARCHAR2
              )
   IS

     lv_format        VARCHAR2(32000);


  BEGIN

  hr_utility.set_location(gv_package_name || '.formated_grand_totals_header', 10);
  lv_format:=  pay_us_payroll_utils.formated_data_string(p_input_string=>'Unit of Measure'
                                                        ,p_output_file_type=>p_output_file_type
                                                        ,p_bold=>'Y')||
               pay_us_payroll_utils.formated_data_string(p_input_string=>'Credit Amount'
                                                        ,p_output_file_type=>p_output_file_type
                                                        ,p_bold=>'Y')||
               pay_us_payroll_utils.formated_data_string(p_input_string=>'Debit Amount'
                                                        ,p_output_file_type=>p_output_file_type
                                                        ,p_bold=>'Y');

  p_static_label1 := lv_format;
  hr_utility.trace('Static Label1 = ' || lv_format);
  hr_utility.set_location(gv_package_name || '.formated_grand_totals_header', 20);

  END formated_grand_totals_header;

 /************************************************************
  ** Procedure: formated_data_row
  ** Returns  : Concatenated data values for the first table
  **            that contains costing info
  ** Purpose  : This procedure is used to get the concatenated
  **            data values for the first table of costing
  **            info.
  ************************************************************/

 PROCEDURE formated_data_row (
                    p_payroll_name              in VARCHAR2
                   ,p_gre_name                  in VARCHAR2
                   ,p_input_value_name          in VARCHAR2
                   ,p_uom                       in VARCHAR2
                   ,p_credit_amount             in NUMBER
                   ,p_debit_amount              in NUMBER
                   ,p_accrual_type              in VARCHAR2
                   ,p_output_file_type          in VARCHAR2
                   ,p_static_data1             out nocopy VARCHAR2
                   ,p_static_data2             out nocopy VARCHAR2
              )
   IS

     lv_format1 VARCHAR2(32000);
     lv_format2 VARCHAR2(32000);


   BEGIN

       hr_utility.set_location(gv_package_name || '.formated_data_row', 10);

       lv_format1 :=
                     pay_us_payroll_utils.formated_data_string (p_input_string=>p_payroll_name
                                                               ,p_output_file_type=>p_output_file_type
							       ,p_bold=>'N'
                                                               )||
                     pay_us_payroll_utils.formated_data_string (p_input_string=>p_gre_name
                                                               ,p_output_file_type=>p_output_file_type
							       ,p_bold=>'N'
                                                               )||
                     pay_us_payroll_utils.formated_data_string (p_input_string=>p_input_value_name
                                                               ,p_output_file_type=>p_output_file_type
							       ,p_bold=>'N'
                                                               )||
                     pay_us_payroll_utils.formated_data_string (p_input_string=>p_uom
                                                               ,p_output_file_type=>p_output_file_type
							       ,p_bold=>'N'
                                                               );


       lv_format2 :=
                     pay_us_payroll_utils.formated_data_string (p_input_string=>p_credit_amount
                                                               ,p_output_file_type=>p_output_file_type
							       ,p_bold=>'N')||
                     pay_us_payroll_utils.formated_data_string (p_input_string=>p_debit_amount
                                                               ,p_output_file_type=>p_output_file_type
							       ,p_bold=>'N')||
                     pay_us_payroll_utils.formated_data_string (p_input_string=>p_accrual_type
		                                               ,p_output_file_type=>p_output_file_type
							       ,p_bold=>'N'
                                                               );

       hr_utility.set_location(gv_package_name || '.formated_data_row', 20);

       p_static_data1 := lv_format1;
       p_static_data2 := lv_format2;
       hr_utility.trace('Static Data1 = ' || lv_format1);
       hr_utility.trace('Static Data2 = ' || lv_format2);
       hr_utility.set_location(gv_package_name || '.formated_static_data', 30);

  END formated_data_row;

  /************************************************************
    ** Procedure: formated_totals
    ** Returns  : Concatenated data values for the second table
    **            that contains cost center wise costing totals
    **            for each payroll or GRE
    ** Purpose  : This procedure is used to get the concatenated
    **            data values for the second table that
    **            contains costing totals for each payroll or GRE
  ************************************************************/

  PROCEDURE formated_totals(p_gre_or_payroll in VARCHAR2
                           ,p_uom in VARCHAR2
                           ,p_credit_amount in NUMBER
                           ,p_debit_amount in NUMBER
                           ,p_output_file_type in VARCHAR2
                           ,p_static_data1 out nocopy VARCHAR2
                           ,p_static_data2 out nocopy VARCHAR2
                           ) IS
  lv_format1 VARCHAR2(32000);
  lv_format2 VARCHAR2(32000);

  BEGIN
        hr_utility.set_location(gv_package_name || '.formated_totals', 10);
  	lv_format1:=
  	           pay_us_payroll_utils.formated_data_string (p_input_string=>p_gre_or_payroll
  	                                                     ,p_output_file_type=>p_output_file_type
							     ,p_bold=>'N'
  	                                                     )||
                   pay_us_payroll_utils.formated_data_string (p_input_string=>p_uom
  	                                                     ,p_output_file_type=>p_output_file_type
							     ,p_bold=>'N'
  	                                                     );
        lv_format2:=
                   pay_us_payroll_utils.formated_data_string(p_input_string=>p_credit_amount
                                                            ,p_output_file_type=>p_output_file_type
							    ,p_bold=>'N'
                                                            )||
                   pay_us_payroll_utils.formated_data_string(p_input_string=>p_debit_amount
                                                            ,p_output_file_type=>p_output_file_type
							    ,p_bold=>'N'
                                                            );
       p_static_data1 := lv_format1;
       p_static_data2 := lv_format2;
       hr_utility.trace('Static Data1 = ' || lv_format1);
       hr_utility.trace('Static Data2 = ' || lv_format2);
       hr_utility.set_location(gv_package_name || '.formated_totals', 20);

  END formated_totals;

  /************************************************************
    ** Procedure: formated_cons_totals1
    ** Returns  : Concatenated data values for the third table
    **            that contains consolidated costing totals for
    **            the selected payroll or GRE
    ** Purpose  : This procedure is used to get the concatenated
    **            data values for the third table that
    **            contains consolidated costing totals for the
    **            selected payroll or GRE
  ************************************************************/

  PROCEDURE formated_cons_totals1(p_gre_or_payroll in VARCHAR2
                                 ,p_uom in VARCHAR2
                                 ,p_credit_amount in NUMBER
                                 ,p_debit_amount in NUMBER
                                 ,p_output_file_type in VARCHAR2
                                 ,p_static_data out nocopy VARCHAR2
                                 ) IS
    lv_format VARCHAR2(32000);


    BEGIN
        hr_utility.set_location(gv_package_name || '.formated_cons_totals1', 10);
    	lv_format:=
    	           pay_us_payroll_utils.formated_data_string (p_input_string=>p_gre_or_payroll
    	                                                     ,p_output_file_type=>p_output_file_type
							     ,p_bold=>'N'
    	                                                     )||

                   pay_us_payroll_utils.formated_data_string(p_input_string=>p_credit_amount
                                                              ,p_output_file_type=>p_output_file_type
							      ,p_bold=>'N'
                                                              )||
                   pay_us_payroll_utils.formated_data_string(p_input_string=>p_debit_amount
                                                              ,p_output_file_type=>p_output_file_type
							      ,p_bold=>'N'
                                                              )||
                   pay_us_payroll_utils.formated_data_string (p_input_string=>p_uom
    	                                                     ,p_output_file_type=>p_output_file_type
							     ,p_bold=>'N'
    	                                                     );
         p_static_data := lv_format;
         hr_utility.trace('Static Data = ' || lv_format);
         hr_utility.set_location(gv_package_name || '.formated_cons_totals1', 10);

    END formated_cons_totals1;

  /************************************************************
     ** Procedure: formated_cons_totals2
     ** Returns  : Concatenated data values for the last table
     **            that contains consolidated report totals
     ** Purpose  : This procedure is used to get the concatenated
     **            data values for the last table that
     **            contains consolidated report totals
  ************************************************************/

   PROCEDURE formated_cons_totals2( p_uom in VARCHAR2
                                   ,p_credit_amount in NUMBER
                                   ,p_debit_amount in NUMBER
                                   ,p_output_file_type in VARCHAR2
                                   ,p_static_data out nocopy VARCHAR2
                                   ) IS
   lv_format VARCHAR2(32000);


   BEGIN
        hr_utility.set_location(gv_package_name || '.formated_cons_totals2', 10);
      	lv_format:=  pay_us_payroll_utils.formated_data_string(p_input_string=>p_credit_amount
                                                                ,p_output_file_type=>p_output_file_type
								,p_bold=>'N'
                                                                )||
                     pay_us_payroll_utils.formated_data_string(p_input_string=>p_debit_amount
                                                                ,p_output_file_type=>p_output_file_type
								,p_bold=>'N'
                                                                )||
                     pay_us_payroll_utils.formated_data_string (p_input_string=>p_uom
      	                                                     ,p_output_file_type=>p_output_file_type
							     ,p_bold=>'N'
      	                                                     );
           p_static_data := lv_format;
           hr_utility.trace('Static Data = ' || lv_format);
           hr_utility.set_location(gv_package_name || '.formated_cons_totals2', 20);

   END formated_cons_totals2;

   /************************************************************
     ** Procedure: formated_grand_totals
     ** Returns  : Concatenated data values for the fourth table
     **            that contains cost center wise grand totals for
     **            the report
     ** Purpose  : This procedure is used to get the concatenated
     **            data values for the fourth table that
     **            contains report totals
   ************************************************************/

   PROCEDURE formated_grand_totals(p_uom in VARCHAR2
                                 ,p_credit_amount in NUMBER
                                 ,p_debit_amount in NUMBER
                                 ,p_output_file_type in VARCHAR2
                                 ,p_static_data1 out nocopy VARCHAR2
                                 ) IS
   lv_format VARCHAR2(32000);

   BEGIN
  	hr_utility.set_location(gv_package_name || '.formated_grand_totals', 10);
        lv_format:=
                   pay_us_payroll_utils.formated_data_string(p_input_string=>p_uom
                                                            ,p_output_file_type=>p_output_file_type
							    ,p_bold=>'N'
                                                            )||
                   pay_us_payroll_utils.formated_data_string(p_input_string=>p_credit_amount
                                                            ,p_output_file_type=>p_output_file_type
							    ,p_bold=>'N'
                                                            )||
                   pay_us_payroll_utils.formated_data_string(p_input_string=>p_debit_amount
                                                            ,p_output_file_type=>p_output_file_type
							    ,p_bold=>'N'
                                                            );
       p_static_data1 := lv_format;
       hr_utility.trace('Static Data1 = ' || lv_format);
       hr_utility.set_location(gv_package_name || '.formated_grand_totals', 20);

   END formated_grand_totals;

 /******************************************************************
  Function for returning the optional where clause for the cursor
  c_asg_costing_details
  Bug 3946996
  ******************************************************************/

  function get_optional_where_clause(cp_payroll_id in number
                                    ,cp_consolidation_set_id in number
                                    ,cp_tax_unit_id in number
				    ,cp_costing_process_flag VARCHAR2
				    ,cp_costing   in VARCHAR2
				    ,cp_cost_type in VARCHAR2)
				    return varchar2 is

  dynamic_where_clause varchar2(10000);

  begin

  if cp_consolidation_set_id is not null then
    dynamic_where_clause := ' and pcd.consolidation_set_id = '|| to_char(cp_consolidation_set_id);
  end if;

  if cp_payroll_id is not null then
    dynamic_where_clause := dynamic_where_clause || ' and pcd.payroll_id = '|| to_char(cp_payroll_id);
  end if;

  if cp_tax_unit_id is not null then
    dynamic_where_clause:= dynamic_where_clause || ' and pcd.tax_unit_id = ' || to_char(cp_tax_unit_id);
  end if;

  if cp_costing_process_flag ='Y' then
    dynamic_where_clause := dynamic_where_clause || ' and pcd.payroll_action_id = ' || cp_costing;
  end if;

  if cp_cost_type  is null then
    dynamic_where_clause := dynamic_where_clause || ' and pcd.cost_type = ''COST_TMP''' ;
  elsif cp_cost_type  = 'EST_MODE_COST' then
    dynamic_where_clause := dynamic_where_clause || ' and pcd.cost_type in (''COST_TMP'',''EST_COST'') ';
  elsif cp_cost_type  = 'EST_MODE_ALL' then
    dynamic_where_clause := dynamic_where_clause || ' and pcd.cost_type in (''COST_TMP'',''EST_COST'',''EST_REVERSAL'') ';
  end if;

  return dynamic_where_clause;

  end get_optional_where_clause;


/********************************* End function Bug 3946996 ***************************/

  /************************************************************
   ** Procedure: costing_summary
   **
   ** Purpose  : This procedure is the one that is called from
   **            the concurrent program
  ************************************************************/

 PROCEDURE costing_summary (
                             errbuf                out nocopy VARCHAR2
                            ,retcode               out nocopy NUMBER
                            ,p_business_group_id    in NUMBER
                            ,p_start_date           in VARCHAR2
                            ,p_dummy_start          in VARCHAR2
                            ,p_END_date             in VARCHAR2
                            ,p_costing              in VARCHAR2
                            ,p_dummy_END            in VARCHAR2
                            ,p_payroll_id           in NUMBER
                            ,p_consolidation_set_id in NUMBER
                            ,p_tax_unit_id          in NUMBER
                            ,p_cost_type            in VARCHAR2
                            ,p_sort_order1          in VARCHAR2
                            ,p_sort_order2          in VARCHAR2
                            ,p_output_file_type     in VARCHAR2
                           ) IS

    TYPE  cur_type is REF CURSOR;     -- Bug 3946996
    c_asg_costing_details cur_type;                 --Bug 3946996

    c_query varchar2(5000);     --for the cursor query (Bug 3946996)
    c_clause1 varchar2(5000);   --to store the optional where clause (Bug 3946996)

            /**********************************************************
             CURSOR to get the Business group name
             ************************************************************/
            CURSOR c_get_organization_name (cp_organization_id in NUMBER) IS
              SELECT name
                FROM hr_organization_units
               WHERE organization_id=cp_organization_id;

           /***********************************************************
             CURSORs to get payroll,consolidation set names
            ***********************************************************/
            CURSOR c_get_payroll_name (cp_payroll_id in NUMBER) IS
              SELECT payroll_name
                FROM pay_payrolls_f
               WHERE payroll_id = cp_payroll_id;

            CURSOR c_get_consolidation_set_name (cp_consolidation_set_id in NUMBER) IS
              SELECT consolidation_set_name
                FROM pay_consolidation_sets
               WHERE consolidation_set_id=cp_consolidation_set_id;

            /***********************************************************
             CURSOR to get effective date for a payroll action id
            ************************************************************/

            CURSOR c_get_effective_date(cp_payroll_action_id in NUMBER) IS
              SELECT effective_date
                FROM pay_payroll_actions
               WHERE payroll_action_id=cp_payroll_action_id;

            CURSOR c_get_accruals(cp_cost_type in VARCHAR2) IS
              SELECT nvl(hr_general.decode_lookup('PAY_PAYRPCBR',cp_cost_type),' ')
                FROM dual;


	    /************************************************************
	    ** Cursor to get the Costing flex which IS setup at
	    ** Business Group.
	    ************************************************************/
	    CURSOR c_costing_flex_id (cp_business_group_id in NUMBER) IS
	      SELECT org_information7
	        FROM hr_organization_information hoi
	       WHERE organization_id = cp_business_group_id
	         and org_information_context = 'Business Group Information';

	    /************************************************************
	    ** Cursor returns all the segments defined for the Costing
	    ** Flex which are enabled and displayed.
	    ************************************************************/
	    CURSOR c_costing_flex_segments (cp_id_flex_num in NUMBER) IS
	      SELECT segment_name, application_column_name
	        FROM fnd_id_flex_segments
	       WHERE id_flex_code = 'COST'
	         and id_flex_num = cp_id_flex_num
	         and enabled_flag = 'Y'
	         and display_flag = 'Y'
	      ORDER BY segment_num;

           CURSOR c_get_session_id IS
             SELECT userenv('sessionid')
               FROM dual;

	    /************************************************************
	      ** Cursor returns payroll/gre totals
	    ************************************************************/
	    CURSOR c_costing_summary_rpt_details (cp_session_id in NUMBER
                                                 ,cp_business_group_id in NUMBER
	                                         ,cp_csr in VARCHAR2
	                                         ,cp_sort_order1 in VARCHAR2
	                                         ,cp_sort_order2 in VARCHAR2) IS
              SELECT decode(upper(cp_sort_order1),'PAYROLL NAME',attribute32
                           ,gre_name)
                           ,attribute34  --UOM
                           ,sum(value1)
                           ,sum(value2)
                           ,attribute1
                           ,attribute2
                           ,attribute3
                           ,attribute4
                           ,attribute5
                           ,attribute6
                           ,attribute7
                           ,attribute8
                           ,attribute9
                           ,attribute10
                           ,attribute11
                           ,attribute12
                           ,attribute13
                           ,attribute14
                           ,attribute15
                           ,attribute16
                           ,attribute17
                           ,attribute18
                           ,attribute19
                           ,attribute20
                           ,attribute21
                           ,attribute22
                           ,attribute23
                           ,attribute24
                           ,attribute25
                           ,attribute26
                           ,attribute27
                           ,attribute28
                           ,attribute29
                           ,attribute30
                FROM pay_us_rpt_totals
               WHERE business_group_id=cp_business_group_id
                 and attribute31=cp_csr
                 and session_id=cp_session_id
               GROUP BY decode(upper(cp_sort_order1), 'PAYROLL NAME',attribute32,
	                       gre_name)
	               ,attribute1
                       ,attribute2
	               ,attribute3
                       ,attribute4
                       ,attribute5
                       ,attribute6
                       ,attribute7
                       ,attribute8
                       ,attribute9
                       ,attribute10
                       ,attribute11
                       ,attribute12
                       ,attribute13
                       ,attribute14
                       ,attribute15
                       ,attribute16
                       ,attribute17
                       ,attribute18
                       ,attribute19
                       ,attribute20
                       ,attribute21
                       ,attribute22
                       ,attribute23
                       ,attribute24
                       ,attribute25
                       ,attribute26
                       ,attribute27
                       ,attribute28
                       ,attribute29
                       ,attribute30
                       ,attribute34
		order by
			attribute1
		       ,attribute2
	               ,attribute3
                       ,attribute4
                       ,attribute5
                       ,attribute6
                       ,attribute7
                       ,attribute8
                       ,attribute9
                       ,attribute10
                       ,attribute11
                       ,attribute12
                       ,attribute13
                       ,attribute14
                       ,attribute15
                       ,attribute16
                       ,attribute17
                       ,attribute18
                       ,attribute19
                       ,attribute20
                       ,attribute21
                       ,attribute22
                       ,attribute23
                       ,attribute24
                       ,attribute25
                       ,attribute26
                       ,attribute27
                       ,attribute28
                       ,attribute29
                       ,attribute30
                       ,attribute34
                       ;

           /************************************************************
	      ** Cursor returns grand totals

	    ************************************************************/


CURSOR c_costing_grand_totals (cp_session_id in NUMBER
                                        ,cp_business_group_id in NUMBER
	                                ,cp_csr in VARCHAR2
                                        ) IS
          SELECT     attribute34 --UOM
                    ,sum(value1)
                    ,sum(value2)
                    ,attribute1
                    ,attribute2
                    ,attribute3
                    ,attribute4
                    ,attribute5
                    ,attribute6
                    ,attribute7
                    ,attribute8
                    ,attribute9
                    ,attribute10
                    ,attribute11
                    ,attribute12
                    ,attribute13
                    ,attribute14
                    ,attribute15
                    ,attribute16
                    ,attribute17
                    ,attribute18
                    ,attribute19
                    ,attribute20
                    ,attribute21
                    ,attribute22
                    ,attribute23
                    ,attribute24
                    ,attribute25
                    ,attribute26
                    ,attribute27
                    ,attribute28
                    ,attribute29
                    ,attribute30
                FROM pay_us_rpt_totals
               WHERE business_group_id=cp_business_group_id
                 AND attribute31=cp_csr
                 AND session_id=cp_session_id
               GROUP BY
                    attribute1
                    ,attribute2
                    ,attribute3
                    ,attribute4
                    ,attribute5
                    ,attribute6
                    ,attribute7
                    ,attribute8
                    ,attribute9
                    ,attribute10
                    ,attribute11
                    ,attribute12
                    ,attribute13
                    ,attribute14
                    ,attribute15
                    ,attribute16
                    ,attribute17
                    ,attribute18
                    ,attribute19
                    ,attribute20
                    ,attribute21
                    ,attribute22
                    ,attribute23
                    ,attribute24
                    ,attribute25
                    ,attribute26
                    ,attribute27
                    ,attribute28
                    ,attribute29
                    ,attribute30
                    ,attribute34
			order by
			attribute1
		       ,attribute2
	               ,attribute3
                       ,attribute4
                       ,attribute5
                       ,attribute6
                       ,attribute7
                       ,attribute8
                       ,attribute9
                       ,attribute10
                       ,attribute11
                       ,attribute12
                       ,attribute13
                       ,attribute14
                       ,attribute15
                       ,attribute16
                       ,attribute17
                       ,attribute18
                       ,attribute19
                       ,attribute20
                       ,attribute21
                       ,attribute22
                       ,attribute23
                       ,attribute24
                       ,attribute25
                       ,attribute26
                       ,attribute27
                       ,attribute28
                       ,attribute29
                       ,attribute30
                       ,attribute34
                       ;


           /**************************************************************
            Cursor to get GRE/Payroll totals
            *************************************************************/
            CURSOR c_get_gre_or_payroll_totals(cp_session_id in NUMBER
                                              ,cp_business_group_id in NUMBER
                                              ,cp_total_flag in VARCHAR2
                                              ,cp_sort_order1 in VARCHAR2
                                              ) IS
               SELECT decode(upper(cp_sort_order1), 'PAYROLL NAME',attribute32,
	                       gre_name)
                     ,attribute34 --UOM
                     ,sum(value1)
                     ,sum(value2)
                 FROM pay_us_rpt_totals
                WHERE session_id=cp_session_id
                  AND business_group_id=cp_business_group_id
                  AND attribute31=cp_total_flag
                GROUP BY decode(upper(cp_sort_order1), 'PAYROLL NAME',attribute32,
	                       gre_name)
                        ,attribute34;

          /**************************************************************
           CURSOR to get report total
           **************************************************************/
           CURSOR c_get_report_totals (cp_session_id in NUMBER
                                      ,cp_business_group_id in NUMBER
                                      ,cp_total_flag in VARCHAR2
                                      ) IS
              SELECT attribute34 --UOM
                    ,sum(value1)
                    ,sum(value2)
                FROM pay_us_rpt_totals
               WHERE session_id=cp_session_id
                 AND business_group_id=cp_business_group_id
                 AND attribute31=cp_total_flag
               GROUP BY attribute34;



	    /*************************************************************
	    ** Local Variables
	    *************************************************************/
	    lv_consolidation_set_name      VARCHAR2(100);
	    lv_business_group_name         VARCHAR2(100);
	    lv_payroll_name                VARCHAR2(100);
	    lv_gre_name                    VARCHAR2(240);
	    lv_input_value_name            VARCHAR2(100);
	    lv_uom                         VARCHAR2(100);
	    ln_credit_amount               NUMBER;
	    ln_debit_amount                NUMBER;
	    lv_effective_date              DATE;
	    lv_concatenated_segments       VARCHAR2(200);
	    lv_segment1                    VARCHAR2(200);
	    lv_segment2                    VARCHAR2(200);
	    lv_segment3                    VARCHAR2(200);
	    lv_segment4                    VARCHAR2(200);
	    lv_segment5                    VARCHAR2(200);
	    lv_segment6                    VARCHAR2(200);
	    lv_segment7                    VARCHAR2(200);
	    lv_segment8                    VARCHAR2(200);
	    lv_segment9                    VARCHAR2(200);
	    lv_segment10                   VARCHAR2(200);
	    lv_segment11                   VARCHAR2(200);
	    lv_segment12                   VARCHAR2(200);
	    lv_segment13                   VARCHAR2(200);
	    lv_segment14                   VARCHAR2(200);
	    lv_segment15                   VARCHAR2(200);
	    lv_segment16                   VARCHAR2(200);
	    lv_segment17                   VARCHAR2(200);
	    lv_segment18                   VARCHAR2(200);
	    lv_segment19                   VARCHAR2(200);
	    lv_segment20                   VARCHAR2(200);
	    lv_segment21                   VARCHAR2(200);
	    lv_segment22                   VARCHAR2(200);
	    lv_segment23                   VARCHAR2(200);
	    lv_segment24                   VARCHAR2(200);
	    lv_segment25                   VARCHAR2(200);
	    lv_segment26                   VARCHAR2(200);
	    lv_segment27                   VARCHAR2(200);
	    lv_segment28                   VARCHAR2(200);
	    lv_segment29                   VARCHAR2(200);
	    lv_segment30                   VARCHAR2(200);
	    ln_costing_id_flex_num         NUMBER;
	    lv_segment_name                VARCHAR2(100);
	    lv_segment_value               VARCHAR2(100);
	    lv_column_name                 VARCHAR2(100);

	    lv_header_label                VARCHAR2(32000);
	    lv_header_label1               VARCHAR2(32000);
	    lv_header_label2               VARCHAR2(32000);
	    lv_cost_flex_header            VARCHAR2(32000):= NULL;

	    lv_data_row                    VARCHAR2(32000);
	    lv_data_row1                   VARCHAR2(32000);
	    lv_data_row2                   VARCHAR2(32000);

	    ln_count                       NUMBER := 0;
	    lv_accrual_type                VARCHAR2(100);
	    lv_cost_mode                   VARCHAR2(100);

            ltr_costing_segment  costing_tab;

	    lv_gre_or_payroll              VARCHAR2(240);
            lv_session_id                  NUMBER;
            lv_credit_sum                  NUMBER;
            lv_debit_sum                   NUMBER;
            lv_total_heading               VARCHAR2(240);

            lv_start_date                  date;
            lv_END_date                    date;
            lv_costing_process_flag        VARCHAR2(1) := 'N';
            lv_include_accruals            VARCHAR2(100);

/*sackumar testing*/
i_sackumar number;
 BEGIN

        hr_utility.set_location(gv_package_name || '.costing_summary', 10);
        hr_utility.trace('Start Date = '       || p_start_date);
	hr_utility.trace('End Date = '         || p_END_date);
        hr_utility.trace('Business Group ID = '|| p_business_group_id);
        hr_utility.trace('Costing Process = ' || p_costing);
        hr_utility.trace('Payroll ID = ' || p_payroll_id);
        hr_utility.trace('Consolidation Set ID = ' || p_consolidation_set_id);
        hr_utility.trace('Tax unit ID = ' || p_tax_unit_id);
        hr_utility.trace('Cost Type = ' || p_cost_type);
        hr_utility.trace('Sort Order 1 = ' || p_sort_order1);
        hr_utility.trace('Sort Order 2 = ' || p_sort_order2);
        hr_utility.trace('Output File Type = ' || p_output_file_type);

        formated_static_header(p_output_file_type,
                               lv_header_label1,
                               lv_header_label2);
        hr_utility.trace('Header Label 1 = ' || lv_header_label1);
        hr_utility.trace('Header Label 2 = ' || lv_header_label2);

        lv_header_label:=lv_header_label1;
        OPEN c_costing_flex_id (p_business_group_id);
	   FETCH c_costing_flex_id into ln_costing_id_flex_num;
	   IF c_costing_flex_id%found THEN
	      hr_utility.set_location(gv_package_name || '.costing_summary', 20);
	      OPEN c_costing_flex_segments (ln_costing_id_flex_num);
	      LOOP
	        FETCH c_costing_flex_segments into lv_segment_name, lv_column_name;
	        IF c_costing_flex_segments%notfound THEN
	           exit;
	        END IF;
	        lv_header_label := lv_header_label ||
	                             pay_us_payroll_utils.formated_data_string (p_input_string=>lv_segment_name
	                                                  ,p_bold=>'Y'
	                                                  ,p_output_file_type=>p_output_file_type);
	        lv_cost_flex_header:= lv_cost_flex_header ||
	                             pay_us_payroll_utils.formated_data_string (p_input_string=>lv_segment_name
				     	                                                  ,p_bold=>'Y'
	                                                  ,p_output_file_type=>p_output_file_type);
	        ltr_costing_segment(ln_count).segment_label := lv_segment_name;
	        ltr_costing_segment(ln_count).column_name   := lv_column_name;
	        ln_count := ln_count + 1;
	       END LOOP;
	       CLOSE c_costing_flex_segments;

/*sackumar testing */
      i_sackumar :=0;
      hr_utility.trace('data from cursor c_costing_flex_segments stored in ltr_costing_segment PL/SQL table');
      for i_sackumar in ltr_costing_segment.first .. ltr_costing_segment.last LOOP
	        hr_utility.trace(ltr_costing_segment(i_sackumar).segment_label||'='||ltr_costing_segment(i_sackumar).column_name);
      end loop;
      hr_utility.trace('ends data from cursor c_costing_flex_segments ');
/*end of sac kumar testing */

	   END IF;
       CLOSE c_costing_flex_id;
       lv_header_label:=lv_header_label||lv_header_label2;

       FND_FILE.PUT_LINE(fnd_file.output,pay_us_payroll_utils.formated_header_string(
                                                 gv_title
                                                ,p_output_file_type
                                         ));
       OPEN c_get_organization_name(p_business_group_id);
       FETCH c_get_organization_name into lv_business_group_name;
       CLOSE c_get_organization_name;

       OPEN c_get_organization_name(p_tax_unit_id);
       FETCH c_get_organization_name into lv_gre_name;
       CLOSE c_get_organization_name;

       OPEN c_get_payroll_name(p_payroll_id);
       FETCH c_get_payroll_name into lv_payroll_name;
       CLOSE c_get_payroll_name;

       OPEN c_get_consolidation_set_name(p_consolidation_set_id);
       FETCH c_get_consolidation_set_name into lv_consolidation_set_name;
       CLOSE c_get_consolidation_set_name;

       hr_utility.set_location(gv_package_name || '.costing_summary', 30);

       lv_include_accruals:= nvl(hr_general.decode_lookup('PAY_PAYRPCBR',p_cost_type),' ');
       IF p_output_file_type='HTML' AND lv_include_accruals = ' ' THEN
         lv_include_accruals:='&nbsp;';
       END IF;

       IF p_costing IS not NULL THEN
       hr_utility.trace('to_NUMBER(p_costing)='||to_NUMBER(p_costing));
         OPEN c_get_effective_date(to_NUMBER(p_costing));
         FETCH c_get_effective_date into lv_start_date;
         CLOSE c_get_effective_date;
         lv_end_date := lv_start_date;
         lv_costing_process_flag:='Y';
	ELSE
	 lv_start_date :=to_date(p_start_date, 'YYYY/MM/DD HH24:MI:SS');
         lv_end_date :=to_date(p_end_date, 'YYYY/MM/DD HH24:MI:SS');
         lv_costing_process_flag:='N';
       END IF;

       hr_utility.set_location(gv_package_name || '.costing_summary', 40);

       formated_title_page(p_output_file_type=> p_output_file_type
                          ,p_business_group  => lv_business_group_name
			  ,p_start_date      =>lv_start_date
			  ,p_END_date        =>lv_END_date
			  ,p_costing         =>p_costing
                          ,p_payroll_name    =>lv_payroll_name
                          ,p_consolidation_set_name=>lv_consolidation_set_name
                          ,p_gre_name        =>lv_gre_name
                          ,p_include_accruals=>lv_include_accruals
                          ,p_sort_order1     =>p_sort_order1
                          ,p_sort_order2     =>p_sort_order2
			  );

       hr_utility.set_location(gv_package_name || '.costing_summary', 50);

       /****************************************************************
        ** Print the Header Information. If the format IS HTML THEN OPEN
        ** the body and table before printing the header info, otherwISe
        ** just print the header information.
        ****************************************************************/
       IF p_output_file_type ='HTML' THEN
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<table border=1 align=CENTER>');
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<tr>');
       END IF;

       FND_FILE.PUT_LINE(fnd_file.output, lv_header_label);

       IF p_output_file_type ='HTML' THEN
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</tr>');
       END IF;

       OPEN c_get_session_id;
       FETCH c_get_session_id into lv_session_id;
       CLOSE c_get_session_id;
       hr_utility.trace('Sort Option 1 = ' || p_sort_order1);
       hr_utility.trace('Sort Option 2 = ' || p_sort_order2);

/************* changed to ref cursor 3946996 */

	c_clause1 :=get_optional_where_clause(p_payroll_id,
                                        p_consolidation_set_id,
                                        p_tax_unit_id,
                                        lv_costing_process_flag,
                                        p_costing,
                                        p_cost_type);

       hr_utility.trace('c_clause1 = ' || c_clause1);

	c_query := 'SELECT
		     pcd.payroll_name
		    ,pcd.gre_name
		    ,pcd.input_value_name
		    ,pcd.uom
		    ,sum(pcd.credit_amount)
		    ,sum(pcd.debit_amount)
		    ,pcd.cost_type
		    ,pcd.concatenated_segments
		    ,pcd.segment1
		    ,pcd.segment2
		    ,pcd.segment3
		    ,pcd.segment4
		    ,pcd.segment5
		    ,pcd.segment6
		    ,pcd.segment7
		    ,pcd.segment8
		    ,pcd.segment9
		    ,pcd.segment10
		    ,pcd.segment11
		    ,pcd.segment12
		    ,pcd.segment13
		    ,pcd.segment14
		    ,pcd.segment15
		    ,pcd.segment16
		    ,pcd.segment17
		    ,pcd.segment18
		    ,pcd.segment19
		    ,pcd.segment20
		    ,pcd.segment21
		    ,pcd.segment22
		    ,pcd.segment23
		    ,pcd.segment24
		    ,pcd.segment25
		    ,pcd.segment26
		    ,pcd.segment27
		    ,pcd.segment28
		    ,pcd.segment29
		    ,pcd.segment30
		FROM pay_costing_details_v pcd
	       WHERE
		     pcd.effective_date between :cp_start_date and :cp_end_date
		       ' || c_clause1 || '
		 and pcd.business_group_id = :cp_business_group_id
		GROUP BY pcd.payroll_name,pcd.gre_name
			,pcd.input_value_name
			,pcd.uom,pcd.cost_type
			,pcd.concatenated_segments
			,pcd.segment1
			,pcd.segment2
			,pcd.segment3
			,pcd.segment4
			,pcd.segment5
			,pcd.segment6
			,pcd.segment7
			,pcd.segment8
			,pcd.segment9
			,pcd.segment10
			,pcd.segment11
			,pcd.segment12
			,pcd.segment13
			,pcd.segment14
			,pcd.segment15
			,pcd.segment16
			,pcd.segment17
			,pcd.segment18
			,pcd.segment19
			,pcd.segment20
		        ,pcd.segment21
		        ,pcd.segment22
		        ,pcd.segment23
		        ,pcd.segment24
		        ,pcd.segment25
		        ,pcd.segment26
		        ,pcd.segment27
		        ,pcd.segment28
		        ,pcd.segment29
		        ,pcd.segment30
	       ORDER BY  pcd.cost_type
			,decode (upper(:cp_sort_order1), ''PAYROLL NAME'', pcd.payroll_name,
					pcd.gre_name)
			,decode(upper(:cp_sort_order2), ''GRE'', pcd.gre_name,''PAYROLL NAME'',
					pcd.payroll_name,''X'')
			,pcd.segment1
			,pcd.segment2
			,pcd.segment3
			,pcd.segment4
			,pcd.segment5
			,pcd.segment6
			,pcd.segment7
			,pcd.segment8
			,pcd.segment9
			,pcd.segment10
			,pcd.segment11
			,pcd.segment12
			,pcd.segment13
			,pcd.segment14
			,pcd.segment15
			,pcd.segment16
			,pcd.segment17
			,pcd.segment18
			,pcd.segment19
			,pcd.segment20
		        ,pcd.segment21
		        ,pcd.segment22
		        ,pcd.segment23
		        ,pcd.segment24
		        ,pcd.segment25
		        ,pcd.segment26
		        ,pcd.segment27
		        ,pcd.segment28
		        ,pcd.segment29
		        ,pcd.segment30';


     OPEN c_asg_costing_details
     FOR c_query USING lv_start_date
                      ,lv_end_date
		      ,p_business_group_id
                      ,p_sort_order1
                      ,p_sort_order2;

       hr_utility.trace('Start Date for Query = '||lv_start_date);
       hr_utility.trace('End Date for Query = '||lv_end_date);
       hr_utility.trace('Bussiness Group for Query = '||p_business_group_id);
       hr_utility.trace('Short Order 1 for Query = '||p_sort_order1);
       hr_utility.trace('Short Order 2 for Query = '||p_sort_order2);

       LOOP
       FETCH c_asg_costing_details into
	                        lv_payroll_name
	                       ,lv_gre_name
                               ,lv_input_value_name
	                       ,lv_uom
	                       ,ln_credit_amount
	                       ,ln_debit_amount
	                       ,lv_cost_mode
	                       ,lv_concatenated_segments
	                       ,lv_segment1
	                       ,lv_segment2
	                       ,lv_segment3
	                       ,lv_segment4
	                       ,lv_segment5
	                       ,lv_segment6
	                       ,lv_segment7
	                       ,lv_segment8
	                       ,lv_segment9
	                       ,lv_segment10
	                       ,lv_segment11
	                       ,lv_segment12
	                       ,lv_segment13
	                       ,lv_segment14
	                       ,lv_segment15
	                       ,lv_segment16
	                       ,lv_segment17
	                       ,lv_segment18
	                       ,lv_segment19
	                       ,lv_segment20
	                       ,lv_segment21
	                       ,lv_segment22
	                       ,lv_segment23
	                       ,lv_segment24
	                       ,lv_segment25
	                       ,lv_segment26
	                       ,lv_segment27
	                       ,lv_segment28
	                       ,lv_segment29
	                       ,lv_segment30;

      IF c_asg_costing_details%notfound THEN
	          hr_utility.set_location(gv_package_name || '.costing_summary', 60);
	          exit;
      END IF;

      hr_utility.trace('Record No (After Main Query) - '||c_asg_costing_details%rowcount);

      lv_accrual_type:=nvl(hr_general.decode_lookup('PAY_PAYRPCBR',lv_cost_mode),' ');
      IF p_output_file_type='HTML' AND lv_accrual_type = ' ' THEN
         lv_accrual_type:='&nbsp;';
      END IF;

      /*insert into pay_us_rpt_totals*/
      /*sackumar :  this data is used in the report for geting the other section
      here atrributes1 to 30 used to store the values of the Segments 1 to 30
      and Attribute31 = 'CSR'
	  Attribute32 = Payroll Name
	  Attribute33 = Concatenated Segments Value
	  Attribute34 = UOM
      */
      insert into pay_us_rpt_totals(session_id,business_group_id,gre_name,value1 ,value2 ,attribute1,attribute2
                                    ,attribute3,attribute4,attribute5,attribute6,attribute7,attribute8
                                    ,attribute9,attribute10,attribute11,attribute12,attribute13
                                    ,attribute14,attribute15,attribute16,attribute17,attribute18
                                    ,attribute19,attribute20,attribute21,attribute22,attribute23
                                    ,attribute24,attribute25,attribute26,attribute27,attribute28
                                    ,attribute29,attribute30,attribute31,attribute32,attribute33
                                    ,attribute34) values
                         (lv_session_id            -- session ID is passed
                         ,p_business_group_id
                         ,lv_gre_name
                         ,ln_credit_amount
                         ,ln_debit_amount
                         ,lv_segment1
                         ,lv_segment2
                         ,lv_segment3
                         ,lv_segment4
                         ,lv_segment5
                         ,lv_segment6
                         ,lv_segment7
                         ,lv_segment8
                         ,lv_segment9
                         ,lv_segment10
                         ,lv_segment11
                         ,lv_segment12
                         ,lv_segment13
                         ,lv_segment14
                         ,lv_segment15
                         ,lv_segment16
                         ,lv_segment17
                         ,lv_segment18
                         ,lv_segment19
                         ,lv_segment20
                         ,lv_segment21
                         ,lv_segment22
                         ,lv_segment23
                         ,lv_segment24
                         ,lv_segment25
                         ,lv_segment26
                         ,lv_segment27
                         ,lv_segment28
                         ,lv_segment29
                         ,lv_segment30
                         ,'CSR'     --attribute31               -- denotes that the record is for Costing Summary Report
                         ,lv_payroll_name --attribute32
                         ,lv_concatenated_segments --attribute33
                         ,lv_uom --attribute34
			 );

      hr_utility.set_location(gv_package_name || '.costing_summary', 70);


      formated_data_row(p_payroll_name  => lv_payroll_name
                       ,p_gre_name      => lv_gre_name
                       ,p_input_value_name => lv_input_value_name
                       ,p_uom           => lv_uom
                       ,p_credit_amount => ln_credit_amount
                       ,p_debit_amount  => ln_debit_amount
                       ,p_accrual_type  => lv_accrual_type
                       ,p_output_file_type=> p_output_file_type
                       ,p_static_data1  => lv_data_row1
                       ,p_static_data2  => lv_data_row2
                       ) ;
      hr_utility.set_location(gv_package_name || '.costing_summary', 80);
      hr_utility.trace('lv_data_row1 = ' || lv_data_row1);
      hr_utility.trace('lv_data_row2 = ' || lv_data_row2);


      lv_data_row:= lv_data_row1;

      for i in ltr_costing_segment.first .. ltr_costing_segment.last LOOP
                   IF ltr_costing_segment(i).column_name = 'SEGMENT1' THEN
                      lv_segment_value := lv_segment1;
                   elsIF ltr_costing_segment(i).column_name = 'SEGMENT2' THEN
                      lv_segment_value := lv_segment2;
                   elsIF ltr_costing_segment(i).column_name = 'SEGMENT3' THEN
                      lv_segment_value := lv_segment3;
                   elsIF ltr_costing_segment(i).column_name = 'SEGMENT4' THEN
                      lv_segment_value := lv_segment4;
                   elsIF ltr_costing_segment(i).column_name = 'SEGMENT5' THEN
                      lv_segment_value := lv_segment5;
                   elsIF ltr_costing_segment(i).column_name = 'SEGMENT6' THEN
                      lv_segment_value := lv_segment6;
                   elsIF ltr_costing_segment(i).column_name = 'SEGMENT7' THEN
                      lv_segment_value := lv_segment7;
                   elsIF ltr_costing_segment(i).column_name = 'SEGMENT8' THEN
                      lv_segment_value := lv_segment8;
                   elsIF ltr_costing_segment(i).column_name = 'SEGMENT9' THEN
                      lv_segment_value := lv_segment9;
                   elsIF ltr_costing_segment(i).column_name = 'SEGMENT10' THEN
                      lv_segment_value := lv_segment10;
                   elsIF ltr_costing_segment(i).column_name = 'SEGMENT11' THEN
                      lv_segment_value := lv_segment11;
                   elsIF ltr_costing_segment(i).column_name = 'SEGMENT12' THEN
                      lv_segment_value := lv_segment12;
                   elsIF ltr_costing_segment(i).column_name = 'SEGMENT13' THEN
                      lv_segment_value := lv_segment13;
                   elsIF ltr_costing_segment(i).column_name = 'SEGMENT14' THEN
                      lv_segment_value := lv_segment14;
                   elsIF ltr_costing_segment(i).column_name = 'SEGMENT15' THEN
                      lv_segment_value := lv_segment15;
                   elsIF ltr_costing_segment(i).column_name = 'SEGMENT16' THEN
                      lv_segment_value := lv_segment16;
                   elsIF ltr_costing_segment(i).column_name = 'SEGMENT17' THEN
                      lv_segment_value := lv_segment17;
                   elsIF ltr_costing_segment(i).column_name = 'SEGMENT18' THEN
                      lv_segment_value := lv_segment18;
                   elsIF ltr_costing_segment(i).column_name = 'SEGMENT19' THEN
                      lv_segment_value := lv_segment19;
                   elsIF ltr_costing_segment(i).column_name = 'SEGMENT20' THEN
                      lv_segment_value := lv_segment20;
                   elsIF ltr_costing_segment(i).column_name = 'SEGMENT21' THEN
                      lv_segment_value := lv_segment21;
                   elsIF ltr_costing_segment(i).column_name = 'SEGMENT22' THEN
                      lv_segment_value := lv_segment22;
                   elsIF ltr_costing_segment(i).column_name = 'SEGMENT23' THEN
                      lv_segment_value := lv_segment23;
                   elsIF ltr_costing_segment(i).column_name = 'SEGMENT24' THEN
                      lv_segment_value := lv_segment24;
                   elsIF ltr_costing_segment(i).column_name = 'SEGMENT25' THEN
                      lv_segment_value := lv_segment25;
                   elsIF ltr_costing_segment(i).column_name = 'SEGMENT26' THEN
                      lv_segment_value := lv_segment26;
                   elsIF ltr_costing_segment(i).column_name = 'SEGMENT27' THEN
                      lv_segment_value := lv_segment27;
                   elsIF ltr_costing_segment(i).column_name = 'SEGMENT28' THEN
                      lv_segment_value := lv_segment28;
                   elsIF ltr_costing_segment(i).column_name = 'SEGMENT29' THEN
                      lv_segment_value := lv_segment29;
                   elsIF ltr_costing_segment(i).column_name = 'SEGMENT30' THEN
                      lv_segment_value := lv_segment30;
                   END IF;

                   lv_data_row := lv_data_row ||
                                     pay_us_payroll_utils.formated_data_string (p_input_string=>lv_segment_value
                                                          ,p_output_file_type=>p_output_file_type
							  ,p_bold=>'N'
                                                      );

      END LOOP ;

      lv_data_row:=lv_data_row||lv_data_row2;

      hr_utility.trace('lv_data_row = ' || lv_data_row);

      IF p_output_file_type ='HTML' THEN
	 lv_data_row := '<tr>' || lv_data_row || '</tr>' ;
      END IF;

      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, lv_data_row);

      /*****************************************************************
       ** initialize Data varaibles
      *****************************************************************/
      lv_data_row  := null;
      lv_data_row1 := null;
      lv_data_row2 := null;

      END LOOP;
      IF p_output_file_type='HTML' THEN
	    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</table>');
      END IF;
      CLOSE c_asg_costing_details;

      /*display totals by sort order 1*/
      IF p_sort_order1='Payroll Name' THEN
 	gv_title1:='Costing Summary Report - Payroll Totals';
 	gv_title2:='Costing Summary Report - GRE Totals';
        lv_total_heading:= 'Payroll Totals';
      ELSE
        gv_title1:='Costing Summary Report - GRE Totals';
        gv_title2:='Costing Summary Report - Payroll Totals';
        lv_total_heading:= 'GRE Totals';
      END IF;

      FND_FILE.PUT_LINE(fnd_file.output,pay_us_payroll_utils.formated_header_string(
                                                 gv_title1
                                                ,p_output_file_type
                                         ));
      IF p_output_file_type ='HTML' THEN

        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<table border=1 align=CENTER>');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<tr>');
      END IF;

      formated_totals_header(p_sort_order1,p_output_file_type,lv_header_label1,lv_header_label2);
      lv_header_label1:=lv_header_label1 || lv_cost_flex_header;
      lv_header_label2:=lv_header_label1 || lv_header_label2;

      hr_utility.set_location(gv_package_name || '.costing_summary', 90);

      FND_FILE.PUT_LINE(fnd_file.output, lv_header_label2);


      OPEN c_costing_summary_rpt_details (lv_session_id
                                         ,p_business_group_id
                                         ,'CSR'
                                         ,p_sort_order1
                                         ,p_sort_order2
                                         );
      LOOP
      FETCH c_costing_summary_rpt_details into
                                     lv_gre_or_payroll
                                    ,lv_uom
                                    ,ln_credit_amount
                                    ,ln_debit_amount
                                    ,lv_segment1
                                    ,lv_segment2
                                    ,lv_segment3
                                    ,lv_segment4
                                    ,lv_segment5
                                    ,lv_segment6
                                    ,lv_segment7
                                    ,lv_segment8
                                    ,lv_segment9
                                    ,lv_segment10
                                    ,lv_segment11
                                    ,lv_segment12
                                    ,lv_segment13
                                    ,lv_segment14
                                    ,lv_segment15
                                    ,lv_segment16
                                    ,lv_segment17
                                    ,lv_segment18
                                    ,lv_segment19
                                    ,lv_segment20
                                    ,lv_segment21
                                    ,lv_segment22
                                    ,lv_segment23
                                    ,lv_segment24
                                    ,lv_segment25
                                    ,lv_segment26
                                    ,lv_segment27
                                    ,lv_segment28
                                    ,lv_segment29
                                    ,lv_segment30;
      IF c_costing_summary_rpt_details%notfound THEN
         hr_utility.set_location(gv_package_name || '.costing_summary', 100);
         exit;
      END IF;

      formated_totals(p_gre_or_payroll => lv_gre_or_payroll
                     ,p_uom            => lv_uom
                     ,p_credit_amount  => ln_credit_amount
                     ,p_debit_amount   => ln_debit_amount
                     ,p_output_file_type => p_output_file_type
                     ,p_static_data1   => lv_data_row1
                     ,p_static_data2   => lv_data_row2
                     );

      lv_data_row:= lv_data_row1;

      for i in ltr_costing_segment.first .. ltr_costing_segment.last LOOP
                     IF ltr_costing_segment(i).column_name = 'SEGMENT1' THEN
                        lv_segment_value := lv_segment1;
                     elsIF ltr_costing_segment(i).column_name = 'SEGMENT2' THEN
                        lv_segment_value := lv_segment2;
                     elsIF ltr_costing_segment(i).column_name = 'SEGMENT3' THEN
                        lv_segment_value := lv_segment3;
                     elsIF ltr_costing_segment(i).column_name = 'SEGMENT4' THEN
                        lv_segment_value := lv_segment4;
                     elsIF ltr_costing_segment(i).column_name = 'SEGMENT5' THEN
                        lv_segment_value := lv_segment5;
                     elsIF ltr_costing_segment(i).column_name = 'SEGMENT6' THEN
                        lv_segment_value := lv_segment6;
                     elsIF ltr_costing_segment(i).column_name = 'SEGMENT7' THEN
                        lv_segment_value := lv_segment7;
                     elsIF ltr_costing_segment(i).column_name = 'SEGMENT8' THEN
                        lv_segment_value := lv_segment8;
                     elsIF ltr_costing_segment(i).column_name = 'SEGMENT9' THEN
                        lv_segment_value := lv_segment9;
                     elsIF ltr_costing_segment(i).column_name = 'SEGMENT10' THEN
                        lv_segment_value := lv_segment10;
                     elsIF ltr_costing_segment(i).column_name = 'SEGMENT11' THEN
                        lv_segment_value := lv_segment11;
                     elsIF ltr_costing_segment(i).column_name = 'SEGMENT12' THEN
                        lv_segment_value := lv_segment12;
                     elsIF ltr_costing_segment(i).column_name = 'SEGMENT13' THEN
                        lv_segment_value := lv_segment13;
                     elsIF ltr_costing_segment(i).column_name = 'SEGMENT14' THEN
                        lv_segment_value := lv_segment14;
                     elsIF ltr_costing_segment(i).column_name = 'SEGMENT15' THEN
                        lv_segment_value := lv_segment15;
                     elsIF ltr_costing_segment(i).column_name = 'SEGMENT16' THEN
                        lv_segment_value := lv_segment16;
                     elsIF ltr_costing_segment(i).column_name = 'SEGMENT17' THEN
                        lv_segment_value := lv_segment17;
                     elsIF ltr_costing_segment(i).column_name = 'SEGMENT18' THEN
                        lv_segment_value := lv_segment18;
                     elsIF ltr_costing_segment(i).column_name = 'SEGMENT19' THEN
                        lv_segment_value := lv_segment19;
                     elsIF ltr_costing_segment(i).column_name = 'SEGMENT20' THEN
                        lv_segment_value := lv_segment20;
		     elsIF ltr_costing_segment(i).column_name = 'SEGMENT21' THEN
		        lv_segment_value := lv_segment21;
		     elsIF ltr_costing_segment(i).column_name = 'SEGMENT22' THEN
		        lv_segment_value := lv_segment22;
		     elsIF ltr_costing_segment(i).column_name = 'SEGMENT23' THEN
		        lv_segment_value := lv_segment23;
		     elsIF ltr_costing_segment(i).column_name = 'SEGMENT24' THEN
		        lv_segment_value := lv_segment24;
		     elsIF ltr_costing_segment(i).column_name = 'SEGMENT25' THEN
		        lv_segment_value := lv_segment25;
		     elsIF ltr_costing_segment(i).column_name = 'SEGMENT26' THEN
		        lv_segment_value := lv_segment26;
		     elsIF ltr_costing_segment(i).column_name = 'SEGMENT27' THEN
		        lv_segment_value := lv_segment27;
		     elsIF ltr_costing_segment(i).column_name = 'SEGMENT28' THEN
		        lv_segment_value := lv_segment28;
		     elsIF ltr_costing_segment(i).column_name = 'SEGMENT29' THEN
		        lv_segment_value := lv_segment29;
		     elsIF ltr_costing_segment(i).column_name = 'SEGMENT30' THEN
		        lv_segment_value := lv_segment30;
                     END IF;

      lv_data_row := lv_data_row ||
                     pay_us_payroll_utils.formated_data_string (p_input_string=>lv_segment_value
                                                               ,p_output_file_type=>p_output_file_type
							       ,p_bold=>'N'
                                                               );

      END LOOP ;

      lv_data_row:=lv_data_row||lv_data_row2;

      hr_utility.trace('lv_data_row = ' || lv_data_row);

      IF p_output_file_type ='HTML' THEN
         lv_data_row := '<tr>' || lv_data_row || '</tr>' ;
      END IF;

      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, lv_data_row);

      /*****************************************************************
  	      ** initialize Data varaibles
      *****************************************************************/
      lv_data_row  := null;
      lv_data_row1 := null;
      lv_data_row2 := null;

      END LOOP;
      CLOSE c_costing_summary_rpt_details;
      IF p_output_file_type='HTML' THEN
	 FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</table>');
      END IF;

      /*Display GRE/Payroll Totals*/

      IF p_output_file_type='HTML' THEN
	 FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<br><center><b>' || lv_total_heading || '</b></center></br>');
	 FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<table border=1 align=CENTER>');
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<tr>');
      ELSE
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT, pay_us_payroll_utils.formated_data_string(
                                          p_input_string=>lv_total_heading
                                         ,p_output_file_type=>p_output_file_type
					 ,p_bold=>'N'));
      END IF;


      formated_cons_totals_header1(p_sort_order1,p_output_file_type,lv_header_label);
      hr_utility.set_location(gv_package_name || '.costing_summary', 110);

      FND_FILE.PUT_LINE(fnd_file.output, lv_header_label);

      OPEN c_get_gre_or_payroll_totals (lv_session_id
                                       ,p_business_group_id
                                       ,'CSR'
                                       ,p_sort_order1
                                       );
      LOOP

      FETCH c_get_gre_or_payroll_totals into lv_gre_or_payroll
                                            ,lv_uom
                                            ,ln_credit_amount
                                            ,ln_debit_amount;
      IF c_get_gre_or_payroll_totals%notfound THEN
      hr_utility.set_location(gv_package_name || '.costing_summary', 90);
      exit;
      END IF;

      formated_cons_totals1(p_gre_or_payroll => lv_gre_or_payroll
                           ,p_uom            => lv_uom
                           ,p_credit_amount  => ln_credit_amount
                           ,p_debit_amount   => ln_debit_amount
                           ,p_output_file_type => p_output_file_type
                           ,p_static_data    => lv_data_row
                           );

      hr_utility.trace('lv_data_row = ' || lv_data_row);
      IF p_output_file_type ='HTML' THEN
     	 lv_data_row := '<tr>' || lv_data_row || '</tr>' ;
      END IF;

      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, lv_data_row);

      /*****************************************************************
     	      ** initialize Data varaibles
      *****************************************************************/
      lv_data_row  := null;


      END LOOP;
      CLOSE c_get_gre_or_payroll_totals;

      IF p_output_file_type='HTML' THEN
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</table>');
      END IF;

      FND_FILE.PUT_LINE(fnd_file.output,pay_us_payroll_utils.formated_header_string(
                                                 'Costing Summary Report - Grand Totals'
                                                 ,p_output_file_type
                                         ));
      IF p_output_file_type ='HTML' THEN

         FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<table border=1 align=CENTER>');
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<tr>');
      END IF;

      formated_grand_totals_header(p_output_file_type,lv_header_label1);
      lv_header_label1:=lv_cost_flex_header || lv_header_label1;
      FND_FILE.PUT_LINE(fnd_file.output, lv_header_label1);


      OPEN c_costing_grand_totals (lv_session_id
                                  ,p_business_group_id
                                  ,'CSR'
                                  );
      LOOP
      FETCH c_costing_grand_totals into   lv_uom
                                         ,ln_credit_amount
                                         ,ln_debit_amount
                                         ,lv_segment1
                                         ,lv_segment2
                                         ,lv_segment3
                                         ,lv_segment4
                                         ,lv_segment5
                                         ,lv_segment6
                                         ,lv_segment7
                                         ,lv_segment8
                                         ,lv_segment9
                                         ,lv_segment10
                                         ,lv_segment11
                                         ,lv_segment12
                                         ,lv_segment13
                                         ,lv_segment14
                                         ,lv_segment15
                                         ,lv_segment16
                                         ,lv_segment17
                                         ,lv_segment18
                                         ,lv_segment19
                                         ,lv_segment20
                                         ,lv_segment21
                                         ,lv_segment22
                                         ,lv_segment23
                                         ,lv_segment24
                                         ,lv_segment25
                                         ,lv_segment26
                                         ,lv_segment27
                                         ,lv_segment28
                                         ,lv_segment29
                                         ,lv_segment30;

     lv_credit_sum:= lv_credit_sum + ln_credit_amount;
     lv_debit_sum:= lv_debit_sum + ln_debit_amount;

     IF c_costing_grand_totals%notfound THEN
     hr_utility.set_location(gv_package_name || '.costing_summary', 120);
     exit;
     END IF;

     formated_grand_totals(p_uom            => lv_uom
                          ,p_credit_amount  => ln_credit_amount
                          ,p_debit_amount   => ln_debit_amount
                          ,p_output_file_type => p_output_file_type
                          ,p_static_data1   => lv_data_row1
                          );

     lv_data_row:=null;

     for i in ltr_costing_segment.first .. ltr_costing_segment.last LOOP
                     IF ltr_costing_segment(i).column_name = 'SEGMENT1' THEN
                        lv_segment_value := lv_segment1;
                     elsIF ltr_costing_segment(i).column_name = 'SEGMENT2' THEN
                        lv_segment_value := lv_segment2;
                     elsIF ltr_costing_segment(i).column_name = 'SEGMENT3' THEN
                        lv_segment_value := lv_segment3;
                     elsIF ltr_costing_segment(i).column_name = 'SEGMENT4' THEN
                        lv_segment_value := lv_segment4;
                     elsIF ltr_costing_segment(i).column_name = 'SEGMENT5' THEN
                        lv_segment_value := lv_segment5;
                     elsIF ltr_costing_segment(i).column_name = 'SEGMENT6' THEN
                        lv_segment_value := lv_segment6;
                     elsIF ltr_costing_segment(i).column_name = 'SEGMENT7' THEN
                        lv_segment_value := lv_segment7;
                     elsIF ltr_costing_segment(i).column_name = 'SEGMENT8' THEN
                        lv_segment_value := lv_segment8;
                     elsIF ltr_costing_segment(i).column_name = 'SEGMENT9' THEN
                        lv_segment_value := lv_segment9;
                     elsIF ltr_costing_segment(i).column_name = 'SEGMENT10' THEN
                        lv_segment_value := lv_segment10;
                     elsIF ltr_costing_segment(i).column_name = 'SEGMENT11' THEN
                        lv_segment_value := lv_segment11;
                     elsIF ltr_costing_segment(i).column_name = 'SEGMENT12' THEN
                        lv_segment_value := lv_segment12;
                     elsIF ltr_costing_segment(i).column_name = 'SEGMENT13' THEN
                        lv_segment_value := lv_segment13;
                     elsIF ltr_costing_segment(i).column_name = 'SEGMENT14' THEN
                        lv_segment_value := lv_segment14;
                     elsIF ltr_costing_segment(i).column_name = 'SEGMENT15' THEN
                        lv_segment_value := lv_segment15;
                     elsIF ltr_costing_segment(i).column_name = 'SEGMENT16' THEN
                        lv_segment_value := lv_segment16;
                     elsIF ltr_costing_segment(i).column_name = 'SEGMENT17' THEN
                        lv_segment_value := lv_segment17;
                     elsIF ltr_costing_segment(i).column_name = 'SEGMENT18' THEN
                        lv_segment_value := lv_segment18;
                     elsIF ltr_costing_segment(i).column_name = 'SEGMENT19' THEN
                        lv_segment_value := lv_segment19;
                     elsIF ltr_costing_segment(i).column_name = 'SEGMENT20' THEN
                        lv_segment_value := lv_segment20;
		     elsIF ltr_costing_segment(i).column_name = 'SEGMENT21' THEN
		        lv_segment_value := lv_segment21;
		     elsIF ltr_costing_segment(i).column_name = 'SEGMENT22' THEN
		        lv_segment_value := lv_segment22;
		     elsIF ltr_costing_segment(i).column_name = 'SEGMENT23' THEN
		        lv_segment_value := lv_segment23;
		     elsIF ltr_costing_segment(i).column_name = 'SEGMENT24' THEN
		        lv_segment_value := lv_segment24;
		     elsIF ltr_costing_segment(i).column_name = 'SEGMENT25' THEN
		        lv_segment_value := lv_segment25;
		     elsIF ltr_costing_segment(i).column_name = 'SEGMENT26' THEN
		        lv_segment_value := lv_segment26;
		     elsIF ltr_costing_segment(i).column_name = 'SEGMENT27' THEN
		        lv_segment_value := lv_segment27;
		     elsIF ltr_costing_segment(i).column_name = 'SEGMENT28' THEN
		        lv_segment_value := lv_segment28;
		     elsIF ltr_costing_segment(i).column_name = 'SEGMENT29' THEN
		        lv_segment_value := lv_segment29;
		     elsIF ltr_costing_segment(i).column_name = 'SEGMENT30' THEN
		        lv_segment_value := lv_segment30;
                     END IF;

      lv_data_row := lv_data_row ||
                     pay_us_payroll_utils.formated_data_string (p_input_string=>lv_segment_value
                                                               ,p_output_file_type=>p_output_file_type
							       ,p_bold=>'N'
                                                               );

      END LOOP ;

      lv_data_row:=lv_data_row||lv_data_row1;
      hr_utility.trace('lv_data_row = ' || lv_data_row);
      IF p_output_file_type ='HTML' THEN
  	 lv_data_row := '<tr>' || lv_data_row || '</tr>' ;
      END IF;

      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, lv_data_row);

      /*****************************************************************
  	      ** initialize Data varaibles
      *****************************************************************/
      lv_data_row  := null;
      lv_data_row1 := null;
      lv_data_row2 := null;
      END LOOP;
      CLOSE c_costing_grand_totals;
      IF p_output_file_type='HTML' THEN
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</table>');
      END IF;

      /* display report totals*/
      IF p_output_file_type='HTML' THEN
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<br><center><b>' || 'Report Totals' || '</b></center></br>');
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<table border=1 align=CENTER>');
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<tr>');
      ELSE
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT, pay_us_payroll_utils.formated_data_string(
                                              p_input_string=>'Report Totals'
                                             ,p_output_file_type=>p_output_file_type
					     ,p_bold=>'N'));
      END IF;

      formated_cons_totals_header2(p_output_file_type,lv_header_label);
      hr_utility.set_location(gv_package_name || '.costing_summary', 140);

      FND_FILE.PUT_LINE(fnd_file.output, lv_header_label);


      OPEN c_get_report_totals(lv_session_id,p_business_group_id,'CSR');
      LOOP
      FETCH c_get_report_totals into
              lv_uom
             ,lv_credit_sum
             ,lv_debit_sum;
      IF c_get_report_totals%notfound THEN
      hr_utility.set_location(gv_package_name || '.costing_summary', 150);
      exit;
      END IF;

      formated_cons_totals2    (p_uom            => lv_uom
                               ,p_credit_amount  => lv_credit_sum
                               ,p_debit_amount   => lv_debit_sum
                               ,p_output_file_type => p_output_file_type
                               ,p_static_data    => lv_data_row
                               );

      hr_utility.trace(lv_data_row);

      IF p_output_file_type ='HTML' THEN
         lv_data_row := '<tr>' || lv_data_row || '</tr>' ;
      END IF;

     FND_FILE.PUT_LINE(FND_FILE.OUTPUT, lv_data_row);

     /****************************************************************
         	      ** initialize Data varaibles
     *****************************************************************/
     lv_data_row  := null;
     END LOOP;
     CLOSE c_get_report_totals;

     DELETE FROM pay_us_rpt_totals where attribute31='CSR';
     hr_utility.trace('Concurrent Request ID = ' || FND_GLOBAL.CONC_REQUEST_ID);
  END costing_summary;
--begin
--hr_utility.trace_on(null, 'COSTING');
  END pay_costing_summary_rep_pkg;

/
