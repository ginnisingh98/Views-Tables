--------------------------------------------------------
--  DDL for Package Body PAY_US_GEOCODE_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_GEOCODE_REPORT_PKG" AS
/* $Header: pyusgeoa.pkb 120.2.12010000.2 2009/09/07 09:34:45 jdevasah ship $ */
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

    Name        : pay_us_geocode_report_pkg

    Description : Package for the geocode upgrade reporting
                      - HTML

    Change List
    -----------
     Date        Name      Vers    Bug No    Description
     ----        ----      ------  -------   -----------
     12-SEP-2005 tclewis   115.0             Created.
     05-NOV-2008 tclewis   115.3   7516651   Added distinct to Report 14,
                                             7 and 8.
     27-Aug-2009 jdevasah  115.4   8829668   changed size of local variables
                                             defined in report14 and report15
     28-Aug-2009 jdevasah  115.5,6 8843479   Report7: changed cursor definition
*/

  /************************************************************
  ** Local Package Variables
  ************************************************************/
  gv_title               VARCHAR2(100);

  gc_csv_delimiter       VARCHAR2(1) := ',';
  gc_csv_data_delimiter  VARCHAR2(1) := '"';

  gv_html_start_data     VARCHAR2(5) := '<td>'  ;
  gv_html_end_data       VARCHAR2(5) := '</td>' ;

  gv_package_name        VARCHAR2(50) := 'pay_us_geocode_report_pkg';


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
       if p_input_string is null then
          hr_utility.set_location(gv_package_name || '.formated_data_string', 30);
          lv_format := gv_html_start_data || '&'||'nbsp;' || gv_html_end_data;
       else
          if p_bold = 'Y' then
             hr_utility.set_location(gv_package_name || '.formated_data_string', 40);
             lv_format := gv_html_start_data || '<b> ' || p_input_string
                             || '</b>' || gv_html_end_data;
          else
             hr_utility.set_location(gv_package_name || '.formated_data_string', 50);
             lv_format := gv_html_start_data || p_input_string || gv_html_end_data;
          end if;
       end if;
    end if;

    hr_utility.set_location(gv_package_name || '.formated_data_string', 60);
    return lv_format;

  END formated_data_string;


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
       hr_utility.set_location(gv_package_name || '.formated_header_string', 20);
       lv_format := p_input_string;
    elsif p_output_file_type = 'HTML' then
       hr_utility.set_location(gv_package_name || '.formated_header_string', 30);
--       lv_format := '<HTML><HEAD> <CENTER> <H1> <B>' || p_input_string ||
--                             '</B></H1></CENTER></HEAD>';
       lv_format := '<HTML>  <P> ' || p_input_string ||
                             '</P>';
    end if;

    hr_utility.set_location(gv_package_name || '.formated_header_string', 40);
    return lv_format;

  END formated_header_string;


  /*****************************************************************
  ** This procudure returns the Mandatory Static Labels.
  *****************************************************************/
  PROCEDURE formated_static_header(
              p_output_file_type  in varchar2
             ,p_static_label1    out nocopy varchar2
             )
  IS

    lv_format1          varchar2(32000);

  BEGIN

      hr_utility.set_location(gv_package_name || '.formated_static_header', 10);

      lv_format1 :=
              formated_data_string (p_input_string =>  'Full Name'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => 'Assignment Id'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Assignment Number'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string =>'Error Description'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type)
              ;

      hr_utility.set_location(gv_package_name || '.formated_static_header', 20);

      p_static_label1 := lv_format1;
      hr_utility.trace('Static Label1 = ' || lv_format1);
      hr_utility.set_location(gv_package_name || '.formated_static_header', 40);

  END;


  /*****************************************************************
  ** This procudure returns the Mandatory Static Labels.
  *****************************************************************/
  PROCEDURE formated_static_data (
                   p_full_name                 in varchar2
                  ,p_assignment_id             in number
                  ,p_assignment_number         in varchar2
                  ,p_error_description         in varchar2
                  ,p_juri_code_1               in varchar2
                  ,p_city_name_1               in varchar2
                  ,p_juri_code_2               in varchar2
                  ,p_city_name_2               in varchar2
                  ,p_table_updated             in varchar2
                  ,p_output_file_type          in varchar2
                  ,p_static_data1              out nocopy varchar2
             )
  IS

    lv_format1 VARCHAR2(32000);
    lv_format2 VARCHAR2(32000);


  BEGIN

      hr_utility.set_location(gv_package_name || '.formated_static_data', 10);

       if p_full_name is not NULL THEN

           lv_format1 := lv_format1 ||
              formated_data_string (p_input_string => p_full_name
                                   ,p_output_file_type => p_output_file_type) ;
       end if;

       if p_assignment_id is not NULL then
           lv_format1 := lv_format1 ||
              formated_data_string (p_input_string => p_assignment_id
                                   ,p_output_file_type => p_output_file_type);
       end if;

       if p_assignment_number is not NULL then
           lv_format1 := lv_format1 ||
              formated_data_string (p_input_string => p_assignment_number
                                   ,p_output_file_type => p_output_file_type);
       end if;

       if p_error_description is not NULL then
           lv_format1 := lv_format1 ||
              formated_data_string (p_input_string => p_error_description
                                   ,p_output_file_type => p_output_file_type);
       end if;

       if p_juri_code_1 is not NULL then
           lv_format1 := lv_format1 ||
              formated_data_string (p_input_string => p_juri_code_1
                                   ,p_output_file_type => p_output_file_type);
       end if;

       if p_city_name_1 is not NULL then
           lv_format1 := lv_format1 ||
              formated_data_string (p_input_string => p_city_name_1
                                   ,p_output_file_type => p_output_file_type);
       end if;

       if p_juri_code_2 is not NULL then
           lv_format1 := lv_format1 ||
              formated_data_string (p_input_string => p_juri_code_2
                                   ,p_output_file_type => p_output_file_type);
       end if;

       if p_city_name_2 is not NULL then
           lv_format1 := lv_format1 ||
              formated_data_string (p_input_string => p_city_name_2
                                   ,p_output_file_type => p_output_file_type);
       end if;

       if p_table_updated is not NULL then
           lv_format1 := lv_format1 ||
              formated_data_string (p_input_string => p_table_updated
                                   ,p_output_file_type => p_output_file_type);
       end if;


      hr_utility.set_location(gv_package_name || '.formated_static_data', 30);


      p_static_data1 := lv_format1;
      hr_utility.trace('Static Data1 = ' || lv_format1);
      hr_utility.set_location(gv_package_name || '.formated_static_data', 40);

  END formated_static_data;
  /*****************************************************************
  ** This procudure returns the Mandatory Static Labels.
  *****************************************************************/
  PROCEDURE formated_static_data2 (
                   p_full_name                 in varchar2
                  ,p_assignment_id             in number
                  ,p_assignment_number         in varchar2
                  ,p_city_name                 in varchar2
                  ,p_county_name               in varchar2
                  ,p_state_abbrev              in varchar2
                  ,p_old_juri_code             in varchar2
                  ,p_new_juri_code             in varchar2
                  ,p_output_file_type          in varchar2
                  ,p_static_data1              out nocopy varchar2
             )
  IS

    lv_format1 VARCHAR2(32000);
    lv_format2 VARCHAR2(32000);


  BEGIN

      hr_utility.set_location(gv_package_name || '.formated_static_data2', 10);
      lv_format1 :=
              formated_data_string (p_input_string => p_full_name
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_assignment_id
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_assignment_number
                                   ,p_output_file_type => p_output_file_type) ;


       if p_city_name is not NULL then
           lv_format1 := lv_format1 ||
              formated_data_string (p_input_string => p_city_name
                                   ,p_output_file_type => p_output_file_type);
       end if;

       if p_county_name is not NULL then
           lv_format1 := lv_format1 ||
              formated_data_string (p_input_string => p_county_name
                                   ,p_output_file_type => p_output_file_type);
       end if;

       if p_state_abbrev is not NULL then
           lv_format1 := lv_format1 ||
              formated_data_string (p_input_string => p_state_abbrev
                                   ,p_output_file_type => p_output_file_type);
       end if;

       if p_old_juri_code is not NULL then
           lv_format1 := lv_format1 ||
              formated_data_string (p_input_string => p_old_juri_code
                                   ,p_output_file_type => p_output_file_type);
       end if;

       if p_new_juri_code is not NULL then
           lv_format1 := lv_format1 ||
              formated_data_string (p_input_string => p_new_juri_code
                                   ,p_output_file_type => p_output_file_type);
       end if;


      hr_utility.set_location(gv_package_name || '.formated_static_data2', 30);


      p_static_data1 := lv_format1;
      hr_utility.trace('Static Data1 = ' || lv_format1);
      hr_utility.set_location(gv_package_name || '.formated_static_data2', 40);

  END formated_static_data2;

  PROCEDURE report_1
             ( p_process_mode              in  varchar2
              ,p_geocode_patch_name        in  varchar2
              ,p_output_file_type          in  varchar2
             )
  IS


    /************************************************************
    ** Cursor to get all the employee and assignment data.
    ************************************************************/
    cursor c_cursor ( cp_process_mode         in varchar
                          ,cp_geocode_patch_name   in varchar
                      ) is
         select distinct substr(ppf.full_name,1,40)  ,
                 pef.assignment_id   ,
                 substr(pef.assignment_number,1,17) ,
                 substr(pgu.description,1,65)
          from   per_people_f ppf,
                 per_assignments_f pef,
                 pay_us_geo_update pgu,
                 pay_patch_status pps
          where    pef.assignment_id = pgu.assignment_id
          and    ppf.person_id = pef.person_id
          and    pgu.id = pps.id
          and    pps.patch_name = p_geocode_patch_name
          and    pgu.status = 'P'
          and    pgu.process_mode = p_process_mode;

    ln_full_name                   varchar2(40);
    ln_assignment_id               number;
    ln_assignment_number           varchar2(17);
    ln_error_description           varchar2(65);

    lv_header_label                VARCHAR2(32000);

    lv_data_row                    VARCHAR2(32000);
    lv_data_row1                   VARCHAR2(32000);


    lv_format1          varchar2(32000);


BEGIN

   hr_utility.set_location(gv_package_name || '.report_1', 10);

   /****************************************************************
   ** Concatnating the second Header Label which includes the User
   ** Defined data set so that it is printed at the end of the
   ** report.
   ****************************************************************/

   fnd_file.put_line(fnd_file.output, formated_header_string(
      'THIS IS A LIST OF ASSIGNMENT INFORMATION FOR THE GEOCODE UPDATE QUARTERLY PATCH'
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
      'Please correct all the following situations(if needed) before running your next payroll'
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'I. Errored Employees'
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'ACTION REQUIRED'
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'WARNING!! Employees that have ERRORED during the upgrade process'
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'Please address these errors immediately as the patch will not complete succesfully'
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         ' until all the assignments are processed without error.'
                                         ,p_output_file_type
                                         ));


   hr_utility.set_location(gv_package_name || '.report_1', 12);
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
      hr_utility.set_location(gv_package_name || '.report_1', 15);

      lv_format1 :=
              formated_data_string (p_input_string =>  'Full Name'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => 'Assignment Id'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Assignment Number'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string =>'Error Description'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type)
              ;

      hr_utility.set_location(gv_package_name || '.report_1', 20);


   fnd_file.put_line(fnd_file.output, lv_format1);

   if p_output_file_type ='HTML' then
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</tr>');
   end if;

   hr_utility.set_location(gv_package_name || '.report_1', 30);
   /*****************************************************
   ** Start of the Data Section of the Report
   *****************************************************/

-- HR_UTILITY.TRACE_ON(NULL,'TCL');
   open c_cursor( p_process_mode
                      ,p_geocode_patch_name
                     );

   loop
         hr_utility.set_location(gv_package_name || '.report_1', 40);

      fetch c_cursor into ln_full_name
                              ,ln_assignment_id
                              ,ln_assignment_number
                              ,ln_error_description;

      if c_cursor%notfound then
         hr_utility.set_location(gv_package_name || '.report_1', 50);
         exit;
      end if;


      /************************************************************
      ** If Assignment Set is used, pick up only those employee
      ** assignments which are part of the Assignment Set - STATIC
      ** or DYNAMIC.
      ************************************************************/
      hr_utility.set_location(gv_package_name || '.report_1', 60);
      hr_utility.trace('Assignment ID = '     || ln_assignment_id);

         formated_static_data( ln_full_name
                              ,ln_assignment_id
                              ,ln_assignment_number
                              ,ln_error_description
                              ,null
                              ,null
                              ,null
                              ,null
                              ,null
                              ,p_output_file_type
                              ,lv_data_row1);

         lv_data_row := lv_data_row1;
         hr_utility.set_location(gv_package_name || '.report_1', 70);

--           if p_output_file_type ='HTML' then
               lv_data_row := '<tr>' || lv_data_row || '</tr>' ;
--            end if;

        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, lv_data_row);


      /*****************************************************************
      ** initialize Data varaibles
      *****************************************************************/
      lv_data_row  := null;
   end loop;
   close c_cursor;

   /*****************************************************
   ** Close of the Data Section of the Report
   *****************************************************/

   if p_output_file_type ='HTML' then
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</table></body></html>');
   end if;

  END report_1;

  PROCEDURE report_2
             (p_process_mode              in  varchar2
             ,p_geocode_patch_name        in  varchar2
             ,p_output_file_type          in  varchar2
             )
  IS


    /************************************************************
    ** Cursor to get all the employee and assignment data.
    ************************************************************/
    cursor c_cursor ( cp_process_mode         in varchar
                          ,cp_geocode_patch_name   in varchar
                      ) is

         select distinct substr(ppf.full_name,1,40) ,
                 pef.assignment_id ,
                 substr(pef.assignment_number,1,17)
          from   per_people_f ppf,
                 per_assignments_f pef,
                 pay_us_geo_update pgu,
        	 pay_patch_status pps
          where  pgu.process_type = 'PERCENTAGE_OVER_100'
          and    pef.assignment_id = pgu.assignment_id
          and    ppf.person_id = pef.person_id
          and    pgu.process_mode = p_process_mode
          and    pgu.id = pps.id
          and    pps.patch_name = p_geocode_patch_name;

    ln_full_name                   varchar2(40);
    ln_assignment_id               number;
    ln_assignment_number           varchar2(17);

    lv_header_label                VARCHAR2(32000);

    lv_data_row                    VARCHAR2(32000);
    lv_data_row1                   VARCHAR2(32000);

    lv_format1          varchar2(32000);


BEGIN

   hr_utility.set_location(gv_package_name || '.report_2', 10);

   /****************************************************************
   ** Concatnating the second Header Label which includes the User
   ** Defined data set so that it is printed at the end of the
   ** report.
   ****************************************************************/

    fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'II. Incorrect percent in time.'
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'ACTION REQUIRED'
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'Employees whose sum of percent in time is greater then 100% at the local level.'
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'Due to jurisdiction code upgrade, some cities may have exceeded 100% in time.'
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'Please correct this at the W-4 Percentage screen by setting the percent in time for the city'
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         '(or total of all the cities) to not exceed 100% time in total. '
                                         ,p_output_file_type
                                         ));

       hr_utility.set_location(gv_package_name || '.report_2', 15);
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
      hr_utility.set_location(gv_package_name || '.report_2', 20);

      lv_format1 :=
              formated_data_string (p_input_string =>  'Full Name'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => 'Assignment Id'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Assignment Number'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ;

      hr_utility.set_location(gv_package_name || '.report_2', 30);


   fnd_file.put_line(fnd_file.output, lv_format1);

   if p_output_file_type ='HTML' then
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</tr>');
   end if;

   hr_utility.set_location(gv_package_name || '.report_2', 40);
   /*****************************************************
   ** Start of the Data Section of the Report
   *****************************************************/

-- HR_UTILITY.TRACE_ON(NULL,'TCL');
   open c_cursor( p_process_mode
                      ,p_geocode_patch_name
                     );

   loop
         hr_utility.set_location(gv_package_name || '.report_2', 50);

      fetch c_cursor into ln_full_name
                              ,ln_assignment_id
                              ,ln_assignment_number;

      if c_cursor%notfound then
         hr_utility.set_location(gv_package_name || '.report_2', 60);
         exit;
      end if;


      /************************************************************
      ** If Assignment Set is used, pick up only those employee
      ** assignments which are part of the Assignment Set - STATIC
      ** or DYNAMIC.
      ************************************************************/
      hr_utility.set_location(gv_package_name || '.report_2', 70);

         hr_utility.set_location(gv_package_name || '.report_2', 80);
         formated_static_data( ln_full_name
                              ,ln_assignment_id
                              ,ln_assignment_number
                              ,null
                              ,null
                              ,null
                              ,null
                              ,null
                              ,null
                              ,p_output_file_type
                              ,lv_data_row1);

         lv_data_row := lv_data_row1;
         hr_utility.set_location(gv_package_name || '.report_2', 90);

--           if p_output_file_type ='HTML' then
               lv_data_row := '<tr>' || lv_data_row || '</tr>' ;
--            end if;

        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, lv_data_row);


      /*****************************************************************
      ** initialize Data varaibles
      *****************************************************************/
      lv_data_row  := null;
   end loop;
   close c_cursor;

   /*****************************************************
   ** Close of the Data Section of the Report
   *****************************************************/

   if p_output_file_type ='HTML' then
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</table></body></html>');
   end if;

  END report_2;

  PROCEDURE report_3
             (p_process_mode              in  varchar2
             ,p_geocode_patch_name        in  varchar2
             ,p_output_file_type          in  varchar2
             )
  IS


    /************************************************************
    ** Cursor to get all the employee and assignment data.
    ************************************************************/
    cursor c_cursor ( cp_process_mode         in varchar
                          ,cp_geocode_patch_name   in varchar
                      ) is

  select distinct substr(ppf.full_name,1,40) ,
                 pef.assignment_id ,
                 substr(pef.assignment_number,1,17)
  from   per_people_f ppf,
         per_assignments_f pef,
         pay_us_geo_update pgu,
         pay_patch_status pps
  where  pgu.process_type = 'MISSING_COUNTY_RECORDS'
  and    pef.assignment_id = pgu.assignment_id
  and    ppf.person_id = pef.person_id
  and    pgu.process_mode = cp_process_mode
  and    pgu.id = pps.id
  and    pps.patch_name = cp_geocode_patch_name;

    ln_full_name                   varchar2(40);
    ln_assignment_id               number;
    ln_assignment_number           varchar2(17);

    lv_header_label                VARCHAR2(32000);

    lv_data_row                    VARCHAR2(32000);
    lv_data_row1                   VARCHAR2(32000);

    lv_format1          varchar2(32000);


BEGIN

   hr_utility.set_location(gv_package_name || '.report_3', 10);

   /****************************************************************
   ** Concatnating the second Header Label which includes the User
   ** Defined data set so that it is printed at the end of the
   ** report.
   ****************************************************************/

    fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'III.  Missing county tax records.'
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'ACTION REQUIRED'
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'Employees who have missing county tax records.'
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'Please correct this by creating a new county tax record from the W-4 form.'
                                         ,p_output_file_type
                                         ));

       hr_utility.set_location(gv_package_name || '.report_3', 15);
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
      hr_utility.set_location(gv_package_name || '.report_3', 20);

      lv_format1 :=
              formated_data_string (p_input_string =>  'Full Name'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => 'Assignment Id'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Assignment Number'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type)
              ;

      hr_utility.set_location(gv_package_name || '.report_3', 30);


   fnd_file.put_line(fnd_file.output, lv_format1);

   if p_output_file_type ='HTML' then
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</tr>');
   end if;

   hr_utility.set_location(gv_package_name || '.report_3', 40);
   /*****************************************************
   ** Start of the Data Section of the Report
   *****************************************************/

-- HR_UTILITY.TRACE_ON(NULL,'TCL');
   open c_cursor( p_process_mode
                      ,p_geocode_patch_name
                     );

   loop
         hr_utility.set_location(gv_package_name || '.report_3', 50);

      fetch c_cursor into ln_full_name
                              ,ln_assignment_id
                              ,ln_assignment_number;

      if c_cursor%notfound then
         hr_utility.set_location(gv_package_name || '.report_3', 60);
         exit;
      end if;


      /************************************************************
      ** If Assignment Set is used, pick up only those employee
      ** assignments which are part of the Assignment Set - STATIC
      ** or DYNAMIC.
      ************************************************************/
      hr_utility.set_location(gv_package_name || '.report_3', 70);
      hr_utility.trace('Assignment ID = '     || ln_assignment_id);


         hr_utility.set_location(gv_package_name || '.report_3', 80);
         formated_static_data( ln_full_name
                              ,ln_assignment_id
                              ,ln_assignment_number
                              ,null
                              ,null
                              ,null
                              ,null
                              ,null
                              ,null
                              ,p_output_file_type
                              ,lv_data_row1);

         lv_data_row := lv_data_row1;
         hr_utility.set_location(gv_package_name || '.report_3', 90);

--           if p_output_file_type ='HTML' then
               lv_data_row := '<tr>' || lv_data_row || '</tr>' ;
--            end if;

        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, lv_data_row);


      /*****************************************************************
      ** initialize Data varaibles
      *****************************************************************/
      lv_data_row  := null;
   end loop;
   close c_cursor;

   /*****************************************************
   ** Close of the Data Section of the Report
   *****************************************************/

   if p_output_file_type ='HTML' then
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</table></body></html>');
   end if;

  END report_3;

  PROCEDURE report_4
             (p_process_mode              in  varchar2
             ,p_geocode_patch_name        in  varchar2
             ,p_output_file_type          in  varchar2
             )
  IS


    /************************************************************
    ** Cursor to get all the employee and assignment data.
    ************************************************************/
    cursor c_cursor ( cp_process_mode         in varchar
                          ,cp_geocode_patch_name   in varchar
                      ) is

  select /*+ index(pmod PAY_US_MODIFIED_GEOCODES_PK)*/  -- Bug 3350007
         distinct substr(ppf.full_name,1,40) ,
         pef.assignment_id ,
         substr(pef.assignment_number,1,17),
         pgu.new_juri_code ,
         substr(pusc.city_name,1,20),
         pgu.old_juri_code,
         substr(pmod.city_name,1,20),
         substr(pgu.table_name ,1,20)
  from   pay_us_modified_geocodes pmod,
         pay_us_city_names pusc ,
	 pay_patch_status pps,
         per_people_f ppf,
         per_assignments_f pef,
         pay_us_geo_update pgu
  where  pgu.process_type = 'PU'
  and    pef.assignment_id = pgu.assignment_id
  and    ppf.person_id = pef.person_id
  and    pgu.table_name is not null
  and    substr(new_juri_code,1,2) = pmod.state_code
  and    substr(new_juri_code,4,3) = pmod.county_code
  and    substr(new_juri_code,8,4) = pmod.new_city_code
  and    substr(old_juri_code,8,4) = pmod.old_city_code
  and    pmod.process_type = 'PU'
  and    pusc.city_code = substr(new_juri_code,8,4)
  and    pusc.county_code = substr(new_juri_code,4,3)
  and    pusc.state_code = substr(new_juri_code,1,2)
  and    pusc.primary_flag = 'Y'
  and    pgu.process_mode = cp_process_mode
  and    pgu.id = pps.id
  and    pps.patch_name = cp_geocode_patch_name;

    ln_full_name                   varchar2(40);
    ln_assignment_id               number;
    ln_assignment_number           varchar2(17);
    ln_new_juri_code               varchar2(11);
    ln_new_pri_city                varchar2(20);
    ln_old_juri_code               varchar2(11);
    ln_old_pri_city                varchar2(20);
    ln_table_name                  varchar2(20);

    lv_header_label                VARCHAR2(32000);

    lv_data_row                    VARCHAR2(32000);
    lv_data_row1                   VARCHAR2(32000);

    lv_format1          varchar2(32000);


BEGIN

   hr_utility.set_location(gv_package_name || '.report_4', 10);

   /****************************************************************
   ** Concatnating the second Header Label which includes the User
   ** Defined data set so that it is printed at the end of the
   ** report.
   ****************************************************************/

    fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'IV. Primary city becoming Secondary with jurisdiction code change'
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'NO ACTION IS REQUIRED. This is for information ONLY.'
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'Employees who have records updated in the following tables because'
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'a primary city has changed to a secondary city with a jurisdiction'
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'code change.'
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'The city displayed here is the NEW PRIMARY CITY for the assignment.'
                                         ,p_output_file_type
                                         ));

       hr_utility.set_location(gv_package_name || '.report_4', 15);
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
      hr_utility.set_location(gv_package_name || '.report_4', 20);

      lv_format1 :=
              formated_data_string (p_input_string =>  'Full Name'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => 'Assignment Id'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => 'Assignment Number'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => 'New JD'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string =>  'New Primary City'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => 'Old JD'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string =>  'Old Primary City'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string =>  'Table Updated'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type)
              ;


      hr_utility.set_location(gv_package_name || '.report_4', 30);


   fnd_file.put_line(fnd_file.output, lv_format1);

   if p_output_file_type ='HTML' then
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</tr>');
   end if;

   hr_utility.set_location(gv_package_name || '.report_4', 40);
   /*****************************************************
   ** Start of the Data Section of the Report
   *****************************************************/

-- HR_UTILITY.TRACE_ON(NULL,'TCL');
   open c_cursor( p_process_mode
                      ,p_geocode_patch_name
                     );

   loop
         hr_utility.set_location(gv_package_name || '.report_4', 50);

      fetch c_cursor into ln_full_name
                              ,ln_assignment_id
                              ,ln_assignment_number
                              ,ln_new_juri_code
                              ,ln_new_pri_city
                              ,ln_old_juri_code
                              ,ln_old_pri_city
                              ,ln_table_name;

      if c_cursor%notfound then
         hr_utility.set_location(gv_package_name || '.report_4', 60);
         exit;
      end if;


      /************************************************************
      ** If Assignment Set is used, pick up only those employee
      ** assignments which are part of the Assignment Set - STATIC
      ** or DYNAMIC.
      ************************************************************/
      hr_utility.set_location(gv_package_name || '.report_4', 70);
      hr_utility.trace('Assignment ID = '     || ln_assignment_id);


         hr_utility.set_location(gv_package_name || '.report_4', 80);
         formated_static_data( ln_full_name
                              ,ln_assignment_id
                              ,ln_assignment_number
                              ,null
                              ,ln_new_juri_code
                              ,ln_new_pri_city
                              ,ln_old_juri_code
                              ,ln_old_pri_city
                              ,ln_table_name
                              ,p_output_file_type
                              ,lv_data_row1);

         lv_data_row := lv_data_row1;
         hr_utility.set_location(gv_package_name || '.report_4', 90);

--           if p_output_file_type ='HTML' then
               lv_data_row := '<tr>' || lv_data_row || '</tr>' ;
--            end if;

        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, lv_data_row);


      /*****************************************************************
      ** initialize Data varaibles
      *****************************************************************/
      lv_data_row  := null;
   end loop;
   close c_cursor;

   /*****************************************************
   ** Close of the Data Section of the Report
   *****************************************************/

   if p_output_file_type ='HTML' then
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</table></body></html>');
   end if;

  END report_4;


  PROCEDURE report_5
             (p_process_mode              in  varchar2
             ,p_geocode_patch_name        in  varchar2
             ,p_output_file_type          in  varchar2
             )
  IS


    /************************************************************
    ** Cursor to get all the employee and assignment data.
    ************************************************************/
    cursor c_cursor ( cp_process_mode         in varchar
                          ,cp_geocode_patch_name   in varchar
                      ) is

  select distinct substr(ppf.full_name,1,40) ,
         pef.assignment_id "Assignment Id" ,
         substr(pef.assignment_number,1,17),
         substr(pusc.city_name,1,20),
         old_juri_code "Old JD",
         new_juri_code "New JD",
         substr(table_name,1,20)
  from   per_people_f ppf,
         per_assignments_f pef,
         pay_us_geo_update pgu,
         pay_us_city_names pusc,
	 pay_patch_status pps
  where  pgu.process_type = 'UP'
  and    pgu.table_name is not null
  and    pef.assignment_id = pgu.assignment_id
  and    ppf.person_id = pef.person_id
  and    pusc.city_code = substr(new_juri_code,8,4)
  and    pusc.county_code = substr(new_juri_code,4,3)
  and    pusc.state_code = substr(new_juri_code,1,2)
  and    pusc.primary_flag = 'Y'
  and    pgu.process_mode = p_process_mode
  and    pgu.id = pps.id
  and    pps.patch_name = p_geocode_patch_name;

    ln_full_name                   varchar2(40);
    ln_assignment_id               number;
    ln_assignment_number           varchar2(17);
    ln_new_juri_code               varchar2(11);
    ln_new_pri_city                varchar2(20);
    ln_old_juri_code               varchar2(11);
    ln_old_pri_city                varchar2(20);
    ln_table_name                  varchar2(20);

    lv_header_label                VARCHAR2(32000);

    lv_data_row                    VARCHAR2(32000);
    lv_data_row1                   VARCHAR2(32000);

    lv_format1          varchar2(32000);


BEGIN

   hr_utility.set_location(gv_package_name || '.report_5', 10);

   /****************************************************************
   ** Concatnating the second Header Label which includes the User
   ** Defined data set so that it is printed at the end of the
   ** report.
   ****************************************************************/

    fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'V. Primary city jurisdiction code change.'
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'NO ACTION IS REQUIRED.  This is for information ONLY.'
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'Employees whose records have been updated in the following tables'
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'because a primary citys jurisdiction code has changed.'
                                         ,p_output_file_type
                                         ));

       hr_utility.set_location(gv_package_name || '.report_5', 15);
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
      hr_utility.set_location(gv_package_name || '.report_5', 20);

      lv_format1 :=
              formated_data_string (p_input_string =>  'Full Name'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => 'Assignment Id'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => 'Assignment Number'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => 'New JD'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string =>  'New Primary City'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => 'Old JD'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

             formated_data_string (p_input_string =>  'Table Updated'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type)
              ;


      hr_utility.set_location(gv_package_name || '.report_5', 30);


   fnd_file.put_line(fnd_file.output, lv_format1);

   if p_output_file_type ='HTML' then
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</tr>');
   end if;

   hr_utility.set_location(gv_package_name || '.report_5', 40);
   /*****************************************************
   ** Start of the Data Section of the Report
   *****************************************************/

-- HR_UTILITY.TRACE_ON(NULL,'TCL');
   open c_cursor( p_process_mode
                      ,p_geocode_patch_name
                     );

   loop
         hr_utility.set_location(gv_package_name || '.report_5', 50);

      fetch c_cursor into ln_full_name
                              ,ln_assignment_id
                              ,ln_assignment_number
                              ,ln_new_pri_city
                              ,ln_new_juri_code
                              ,ln_old_juri_code
                              ,ln_table_name;

      if c_cursor%notfound then
         hr_utility.set_location(gv_package_name || '.report_5', 60);
         exit;
      end if;


      /************************************************************
      ** If Assignment Set is used, pick up only those employee
      ** assignments which are part of the Assignment Set - STATIC
      ** or DYNAMIC.
      ************************************************************/
      hr_utility.set_location(gv_package_name || '.report_5', 70);
      hr_utility.trace('Assignment ID = '     || ln_assignment_id);


         hr_utility.set_location(gv_package_name || '.report_5', 80);
         formated_static_data( ln_full_name
                              ,ln_assignment_id
                              ,ln_assignment_number
                              ,null
                              ,ln_new_juri_code
                              ,ln_new_pri_city
                              ,ln_old_juri_code
                              ,null
                              ,ln_table_name
                              ,p_output_file_type
                              ,lv_data_row1);

         lv_data_row := lv_data_row1;
         hr_utility.set_location(gv_package_name || '.report_5', 90);

--           if p_output_file_type ='HTML' then
               lv_data_row := '<tr>' || lv_data_row || '</tr>' ;
--            end if;

        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, lv_data_row);


      /*****************************************************************
      ** initialize Data varaibles
      *****************************************************************/
      lv_data_row  := null;
   end loop;
   close c_cursor;

   /*****************************************************
   ** Close of the Data Section of the Report
   *****************************************************/

   if p_output_file_type ='HTML' then
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</table></body></html>');
   end if;

  END report_5;


  PROCEDURE report_6
             (p_process_mode              in  varchar2
             ,p_geocode_patch_name        in  varchar2
             ,p_output_file_type          in  varchar2
             )
  IS


    /************************************************************
    ** Cursor to get all the employee and assignment data.
    ************************************************************/
    cursor c_cursor ( cp_process_mode         in varchar
                          ,cp_geocode_patch_name   in varchar
                      ) is

  select distinct substr(ppf.full_name,1,40) ,
         pef.assignment_id "Assignment Id" ,
         substr(pef.assignment_number,1,17),
         substr(pusc.city_name,1,20),
    	 substr(puscn.county_name,1,20),
         substr(pust.state_abbrev,1,2),
	     old_juri_code ,
         new_juri_code
   from  per_people_f ppf,
         per_assignments_f pef,
         pay_us_geo_update pgu,
         pay_us_city_names pusc,
	 pay_patch_status pps ,
	 pay_us_states pust,
	 pay_us_counties puscn
  where  pgu.process_type = 'US'
  and    pgu.status = 'A'
  and    pgu.table_name is null
  and    pef.assignment_id = pgu.assignment_id
  and    ppf.person_id = pef.person_id
  and    pusc.city_code = substr(new_juri_code,8,4)
  and    pusc.county_code = substr(new_juri_code,4,3)
  and    pusc.state_code = substr(new_juri_code,1,2)
  and    puscn.county_code = pusc.county_code
  and    puscn.state_code = pusc.state_code
  and    pust.state_code = pusc.state_code
  and    pusc.primary_flag = 'Y'
  and    pgu.process_mode = cp_process_mode
  and    pgu.id = pps.id
  and    pps.patch_name = cp_geocode_patch_name;

    ln_full_name                   varchar2(40);
    ln_assignment_id               number;
    ln_assignment_number           varchar2(17);
    ln_city_name                   varchar2(20);
    ln_county_name                 varchar2(20);
    ln_state_abbrev                varchar2(20);
    ln_old_juri_code               varchar2(11);
    ln_new_juri_code               varchar2(11);

    lv_header_label                VARCHAR2(32000);

    lv_data_row                    VARCHAR2(32000);
    lv_data_row1                   VARCHAR2(32000);

    lv_format1          varchar2(32000);


BEGIN

   hr_utility.set_location(gv_package_name || '.report_6', 10);

   /****************************************************************
   ** Concatnating the second Header Label which includes the User
   ** Defined data set so that it is printed at the end of the
   ** report.
   ****************************************************************/

    fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'VI. Secondary jurisdiction code change.'
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'ACTION REQUIRED'
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'WARNING! Employees whose secondary city jurisdiction code has changed. Thus this means'
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'the employees will have different or a new Primary City.'
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'New city tax records and Vertex Element Entries have been created for'
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'these assignments with the new jurisdiction code.'
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'Please check the records of these employees and determine which CITY is to be the Primary City.'
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'Then, ensure that the percentages reflect the new primary city.'
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'also ensure that the subject to balances are correct.  Some manual balance adjustments'
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'may be required to reflect the new taxing jurisdictions of highlighted cities.'
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'The resident city and work city listed reflects the location as of the day this patch is run.'
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'NOTE : This only applies to those cities that have local level taxes.  All other'
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'cities may be ignored and are listed for information only.'
                                         ,p_output_file_type
                                         ));

       hr_utility.set_location(gv_package_name || '.report_6', 15);
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
      hr_utility.set_location(gv_package_name || '.report_6', 20);

      lv_format1 :=
              formated_data_string (p_input_string =>  'Full Name'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => 'Assignment Id'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => 'Assignment Number'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => 'Primary City'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string =>  'County Name'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => 'State'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string =>  'Old JD'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string =>  'New JD'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type)
              ;


      hr_utility.set_location(gv_package_name || '.report_6', 30);


   fnd_file.put_line(fnd_file.output, lv_format1);

   if p_output_file_type ='HTML' then
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</tr>');
   end if;

   hr_utility.set_location(gv_package_name || '.report_6', 40);
   /*****************************************************
   ** Start of the Data Section of the Report
   *****************************************************/

-- HR_UTILITY.TRACE_ON(NULL,'TCL');
   open c_cursor( p_process_mode
                      ,p_geocode_patch_name
                     );

   loop
         hr_utility.set_location(gv_package_name || '.report_6', 50);

      fetch c_cursor into ln_full_name
                              ,ln_assignment_id
                              ,ln_assignment_number
                              ,ln_city_name
                              ,ln_county_name
                              ,ln_state_abbrev
                              ,ln_old_juri_code
                              ,ln_new_juri_code;

      if c_cursor%notfound then
         hr_utility.set_location(gv_package_name || '.report_6', 60);
         exit;
      end if;


      /************************************************************
      ** If Assignment Set is used, pick up only those employee
      ** assignments which are part of the Assignment Set - STATIC
      ** or DYNAMIC.
      ************************************************************/
      hr_utility.set_location(gv_package_name || '.report_6', 70);
      hr_utility.trace('Assignment ID = '     || ln_assignment_id);


         hr_utility.set_location(gv_package_name || '.report_6', 80);
         formated_static_data2(ln_full_name
                              ,ln_assignment_id
                              ,ln_assignment_number
                              ,ln_city_name
                              ,ln_county_name
                              ,ln_state_abbrev
                              ,ln_old_juri_code
                              ,ln_new_juri_code
                              ,p_output_file_type
                              ,lv_data_row1);

         lv_data_row := lv_data_row1;
         hr_utility.set_location(gv_package_name || '.report_6', 90);

--           if p_output_file_type ='HTML' then
               lv_data_row := '<tr>' || lv_data_row || '</tr>' ;
--            end if;

        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, lv_data_row);


      /*****************************************************************
      ** initialize Data varaibles
      *****************************************************************/
      lv_data_row  := null;
   end loop;
   close c_cursor;

   /*****************************************************
   ** Close of the Data Section of the Report
   *****************************************************/

   if p_output_file_type ='HTML' then
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</table></body></html>');
   end if;

  END report_6;


  PROCEDURE report_7
             (p_process_mode              in  varchar2
             ,p_geocode_patch_name        in  varchar2
             ,p_output_file_type          in  varchar2
             )
  IS


    /************************************************************
    ** Cursor to get all the employee and assignment data.
    ************************************************************/
    cursor c_cursor ( cp_process_mode         in varchar
                          ,cp_geocode_patch_name   in varchar
                      ) is

        SELECT  /*+ ORDERED
                    INDEX (PAY_US_MODIFIED_GEOCODES PAY_US_MODIFIED_GEOCODES_N1)
                    INDEX (PAY_US_CITY_NAMES  PAY_US_CITY_NAMES_FK1)
                    INDEX (PAY_US_EMP_CITY_TAX_RULES_F PAY_US_EMP_CITY_TAX_RULES_N3)   */
                 SUBSTR(ppf.full_name,1,40),
                 SUBSTR(pmod.city_name,1,20),
                 SUBSTR(pucn.city_name,1,20)
          FROM   pay_us_modified_geocodes pmod,
                 pay_us_city_names pucn,
                 pay_us_emp_city_tax_rules_f ectr,
                 per_assignments_f paf,
                 per_people_f ppf
         WHERE pmod.process_type = 'P'
           AND pmod.state_code = pucn.state_code
           AND pmod.county_code = pucn.county_code
           AND pmod.new_city_code = pucn.city_code
           AND pucn.primary_flag = 'Y'
           AND pmod.state_code = ectr.state_code
           AND pmod.county_code = ectr.county_code
           AND pmod.old_city_code = ectr.city_code
           AND ectr.assignment_id = paf.assignment_id
           AND paf.person_id = ppf.person_id
           AND pmod.patch_name = cp_geocode_patch_name
        UNION
        SELECT /*+ ORDERED
                     INDEX (PAY_US_MODIFIED_GEOCODES PAY_US_MODIFIED_GEOCODES_N1)
                     INDEX (PAY_US_EMP_CITY_TAX_RULES_F PAY_US_EMP_CITY_TAX_RULES_N3) */
                 SUBSTR(ppf.full_name,1,40),
                 SUBSTR(pmod2.city_name,1,20),
                 SUBSTR(pmod.city_name,1,20)
          FROM   pay_us_modified_geocodes pmod,
                 pay_us_emp_city_tax_rules_f ectr,
                 per_assignments_f paf,
                 per_people_f ppf,
                 pay_us_modified_geocodes pmod2
           WHERE pmod.process_type = 'S'
             and pmod2.process_type in ('UP','PU','P')
             and pmod2.state_code = ectr.state_code
             and pmod2.county_code = ectr.county_code
             and pmod2.old_city_code = ectr.city_code
             AND pmod.state_code = ectr.state_code
             AND pmod.county_code = ectr.county_code
             AND pmod.new_city_code = ectr.city_code
             AND ectr.assignment_id = paf.assignment_id
             AND paf.person_id = ppf.person_id
             AND pmod.patch_name = cp_geocode_patch_name
             AND pmod2.patch_name = cp_geocode_patch_name;


    ln_full_name                   varchar2(40);
    ln_old_city_name               varchar2(20);
    ln_new_city_name               varchar2(20);

    lv_header_label                VARCHAR2(32000);

    lv_data_row                    VARCHAR2(32000);
    lv_data_row1                   VARCHAR2(32000);

    lv_format1          varchar2(32000);


BEGIN

   hr_utility.set_location(gv_package_name || '.report_7', 10);

   /****************************************************************
   ** Concatnating the second Header Label which includes the User
   ** Defined data set so that it is printed at the end of the
   ** report.
   ****************************************************************/

    fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'VII. Employees who have new Primary City.'
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'NO ACTION IS REQUIRED. This is for information ONLY.'
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'The jurisdction code has not changed thus the tax rates will stay the same.'
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'the employees will have different or a new Primary City.'
                                         ,p_output_file_type
                                         ));


       hr_utility.set_location(gv_package_name || '.report_7', 15);
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
      hr_utility.set_location(gv_package_name || '.report_7', 20);

      lv_format1 :=
              formated_data_string (p_input_string =>  'Full Name'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => 'Old Primary City'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => 'New Primary City'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type)
              ;

      hr_utility.set_location(gv_package_name || '.report_7', 30);


   fnd_file.put_line(fnd_file.output, lv_format1);

   if p_output_file_type ='HTML' then
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</tr>');
   end if;

   hr_utility.set_location(gv_package_name || '.report_7', 40);
   /*****************************************************
   ** Start of the Data Section of the Report
   *****************************************************/

-- HR_UTILITY.TRACE_ON(NULL,'TCL');
   open c_cursor( p_process_mode
                      ,p_geocode_patch_name
                     );

   loop
         hr_utility.set_location(gv_package_name || '.report_7', 50);

      fetch c_cursor into ln_full_name
                              ,ln_old_city_name
                              ,ln_new_city_name;

      if c_cursor%notfound then
         hr_utility.set_location(gv_package_name || '.report_7', 60);
         exit;
      end if;


      /************************************************************
      ** If Assignment Set is used, pick up only those employee
      ** assignments which are part of the Assignment Set - STATIC
      ** or DYNAMIC.
      ************************************************************/
      hr_utility.set_location(gv_package_name || '.report_7', 70);

         hr_utility.set_location(gv_package_name || '.report_7', 80);
         formated_static_data(ln_full_name
                              ,null
                              ,null
                              ,null
                              ,ln_old_city_name  -- Intentional see report format
                              ,null
                              ,ln_new_city_name  -- Intentional see report format
                              ,null
                              ,null
                              ,p_output_file_type
                              ,lv_data_row1);

         lv_data_row := lv_data_row1;
         hr_utility.set_location(gv_package_name || '.report_7', 90);

--           if p_output_file_type ='HTML' then
               lv_data_row := '<tr>' || lv_data_row || '</tr>' ;
--            end if;

        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, lv_data_row);


      /*****************************************************************
      ** initialize Data varaibles
      *****************************************************************/
      lv_data_row  := null;
   end loop;
   close c_cursor;

   /*****************************************************
   ** Close of the Data Section of the Report
   *****************************************************/

   if p_output_file_type ='HTML' then
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</table></body></html>');
   end if;

  END report_7;

  PROCEDURE report_8
             (p_process_mode              in  varchar2
             ,p_geocode_patch_name        in  varchar2
             ,p_output_file_type          in  varchar2
             )
  IS


    /************************************************************
    ** Cursor to get all the employee and assignment data.
    ************************************************************/
    cursor c_cursor ( cp_process_mode         in varchar
                          ,cp_geocode_patch_name   in varchar
                      ) is

        select distinct state_code||'-'||county_code||'-'||old_city_code ,
               state_code||'-'||county_code||'-'||new_city_code ,
               substr(city_name,1,20)
          from pay_us_modified_geocodes
         where old_city_code like 'U%';


    ln_old_juri_code               varchar2(11);
    ln_new_juri_code               varchar2(11);
    ln_city_name                   varchar2(20);

    lv_header_label                VARCHAR2(32000);

    lv_data_row                    VARCHAR2(32000);
    lv_data_row1                   VARCHAR2(32000);

    lv_format1          varchar2(32000);


BEGIN

   hr_utility.set_location(gv_package_name || '.report_8', 10);

   /****************************************************************
   ** Concatnating the second Header Label which includes the User
   ** Defined data set so that it is printed at the end of the
   ** report.
   ****************************************************************/

    fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'VIII.   User Defined cities that are now supported by Vertex'
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'NO ACTION IS REQUIRED.  This is for information ONLY.'
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'The following lists user defined cities that are now supported by Vertex.'
                                         ,p_output_file_type
                                         ));


       hr_utility.set_location(gv_package_name || '.report_8', 15);
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
      hr_utility.set_location(gv_package_name || '.report_8', 20);

      lv_format1 :=
              formated_data_string (p_input_string =>  'Old User Defined JD'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => 'Supported New JD'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => 'City Name'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type)
              ;

      hr_utility.set_location(gv_package_name || '.report_8', 30);


   fnd_file.put_line(fnd_file.output, lv_format1);

   if p_output_file_type ='HTML' then
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</tr>');
   end if;

   hr_utility.set_location(gv_package_name || '.report_8', 40);
   /*****************************************************
   ** Start of the Data Section of the Report
   *****************************************************/

-- HR_UTILITY.TRACE_ON(NULL,'TCL');
   open c_cursor( p_process_mode
                      ,p_geocode_patch_name
                     );

   loop
         hr_utility.set_location(gv_package_name || '.report_8', 50);

      fetch c_cursor into  ln_old_juri_code
                               ,ln_new_juri_code
                               ,ln_city_name;

      if c_cursor%notfound then
         hr_utility.set_location(gv_package_name || '.report_8', 60);
         exit;
      end if;


      /************************************************************
      ** If Assignment Set is used, pick up only those employee
      ** assignments which are part of the Assignment Set - STATIC
      ** or DYNAMIC.
      ************************************************************/
      hr_utility.set_location(gv_package_name || '.report_8', 70);

         hr_utility.set_location(gv_package_name || '.report_8', 80);
         formated_static_data( null
                              ,null
                              ,null
                              ,ln_old_juri_code  -- Intentional see report format
                              ,null
                              ,ln_new_juri_code  -- Intentional see report format
                              ,ln_city_name
                              ,null
                              ,null
                              ,p_output_file_type
                              ,lv_data_row1);

         lv_data_row := lv_data_row1;
         hr_utility.set_location(gv_package_name || '.report_8', 90);

--           if p_output_file_type ='HTML' then
               lv_data_row := '<tr>' || lv_data_row || '</tr>' ;
--            end if;

        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, lv_data_row);


      /*****************************************************************
      ** initialize Data varaibles
      *****************************************************************/
      lv_data_row  := null;
   end loop;
   close c_cursor;

   /*****************************************************
   ** Close of the Data Section of the Report
   *****************************************************/

   if p_output_file_type ='HTML' then
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</table></body></html>');
   end if;

  END report_8;


  PROCEDURE report_9
             (p_process_mode              in  varchar2
             ,p_geocode_patch_name        in  varchar2
             ,p_output_file_type          in  varchar2
             )
  IS


    /************************************************************
    ** Cursor to get all the employee and assignment data.
    ************************************************************/
    cursor c_cursor ( cp_process_mode         in varchar
                          ,cp_geocode_patch_name   in varchar
                      ) is

         select /*+ ORDERED
                   INDEX (PAY_US_GEO_UPDATE PAY_US_GEO_UPDATE_N2)
                   INDEX (PAY_PATCH_STATUS  PAY_PATCH_STATUS_N1) */
                 distinct substr(ppf.full_name,1,40) ,
                 pef.assignment_id ,
                 substr(pef.assignment_number,1,17),
                 substr(pusc.city_name,1,20),
                 pgu.new_juri_code
          from   pay_patch_status pps,
                 pay_us_geo_update pgu,
                 pay_us_city_names pusc,
                 per_assignments_f pef,
                 per_people_f ppf
          where  pgu.process_type = 'NEW_CITY_RECORDS'
          and    pef.assignment_id = pgu.assignment_id
          and    ppf.person_id = pef.person_id
          and    pusc.city_code = substr(new_juri_code,8,4)
          and    pusc.county_code = substr(new_juri_code,4,3)
          and    pusc.state_code = substr(new_juri_code,1,2)
          and    pgu.process_mode = cp_process_mode
          and    pusc.primary_flag = 'Y'
          and    pgu.id = pps.id
          and    pps.patch_name = cp_geocode_patch_name;



    ln_full_name                   varchar2(40);
    ln_assignment_id               number;
    ln_assignment_number           varchar2(17);
    ln_city_name                   varchar2(20);
    ln_jd_code                     varchar2(11);

    lv_header_label                VARCHAR2(32000);

    lv_data_row                    VARCHAR2(32000);
    lv_data_row1                   VARCHAR2(32000);

    lv_format1          varchar2(32000);


BEGIN

   hr_utility.set_location(gv_package_name || '.report_9', 10);

   /****************************************************************
   ** Concatnating the second Header Label which includes the User
   ** Defined data set so that it is printed at the end of the
   ** report.
   ****************************************************************/

    fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'IX.  Summary of employees for whom new city tax records have been created'
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'NO ACTION IS REQUIRED.  This is for information ONLY.'
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'Please ensure that for these assignments, the tax records are as expected and the percent'
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'of time spent in each city is correct. These names may be duplicated from above.'
                                         ,p_output_file_type
                                         ));


       hr_utility.set_location(gv_package_name || '.report_9', 15);
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
      hr_utility.set_location(gv_package_name || '.report_9', 20);

      lv_format1 :=
              formated_data_string (p_input_string =>  'Full Name'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => 'Assignment Id'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => 'Assignment Number'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => 'Primary City'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => 'Jurisdiction Code'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ;

      hr_utility.set_location(gv_package_name || '.report_9', 30);


   fnd_file.put_line(fnd_file.output, lv_format1);

   if p_output_file_type ='HTML' then
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</tr>');
   end if;

   hr_utility.set_location(gv_package_name || '.report_9', 40);
   /*****************************************************
   ** Start of the Data Section of the Report
   *****************************************************/

-- HR_UTILITY.TRACE_ON(NULL,'TCL');
   open c_cursor( p_process_mode
                      ,p_geocode_patch_name
                     );

   loop
         hr_utility.set_location(gv_package_name || '.report_9', 50);

      fetch c_cursor into  ln_full_name
                               ,ln_assignment_id
                               ,ln_assignment_number
                               ,ln_city_name
                               ,ln_jd_code;

      if c_cursor%notfound then
         hr_utility.set_location(gv_package_name || '.report_9', 60);
         exit;
      end if;


      /************************************************************
      ** If Assignment Set is used, pick up only those employee
      ** assignments which are part of the Assignment Set - STATIC
      ** or DYNAMIC.
      ************************************************************/
      hr_utility.set_location(gv_package_name || '.report_9', 70);
      hr_utility.trace('Assignment ID = '     || ln_assignment_id);


         hr_utility.set_location(gv_package_name || '.report_9', 80);
         formated_static_data( ln_full_name
                              ,ln_assignment_id
                              ,ln_assignment_number
                              ,null
                              ,ln_city_name
                              ,ln_jd_code
                              ,null
                              ,null
                              ,null
                              ,p_output_file_type
                              ,lv_data_row1);

         lv_data_row := lv_data_row1;
         hr_utility.set_location(gv_package_name || '.report_9', 90);

--           if p_output_file_type ='HTML' then
               lv_data_row := '<tr>' || lv_data_row || '</tr>' ;
--            end if;

        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, lv_data_row);


      /*****************************************************************
      ** initialize Data varaibles
      *****************************************************************/
      lv_data_row  := null;
   end loop;
   close c_cursor;

   /*****************************************************
   ** Close of the Data Section of the Report
   *****************************************************/

   if p_output_file_type ='HTML' then
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</table></body></html>');
   end if;

  END report_9;


  PROCEDURE report_10
             (p_process_mode              in  varchar2
             ,p_geocode_patch_name        in  varchar2
             ,p_output_file_type          in  varchar2
             )
  IS


    /************************************************************
    ** Cursor to get all the employee and assignment data.
    ************************************************************/
    cursor c_cursor ( cp_process_mode         in varchar
                          ,cp_geocode_patch_name   in varchar
                      ) is

         select    /*+ ORDERED
                   INDEX (PAY_US_GEO_UPDATE PAY_US_GEO_UPDATE_N2 )
                   INDEX (PAY_PATCH_STATUS  PAY_PATCH_STATUS_N1) */
                 distinct substr(ppf.full_name,1,40) ,
                 pef.assignment_id ,
                 substr(pef.assignment_number,1,17),
                 substr(pusc.city_name,1,20),
                 pgu.new_juri_code
          from   pay_patch_status pps,
                 pay_us_geo_update pgu,
                 pay_us_city_names pusc,
                 per_assignments_f pef,
                 per_people_f ppf
          where  pgu.process_type = 'NEW_VERTEX_RECORDS'
          and    pef.assignment_id = pgu.assignment_id
          and    ppf.person_id = pef.person_id
          and    pusc.city_code = substr(new_juri_code,8,4)
          and    pusc.county_code = substr(new_juri_code,4,3)
          and    pusc.state_code = substr(new_juri_code,1,2)
          and    pusc.primary_flag = 'Y'
          and    pgu.process_mode = cp_process_mode
          and    pgu.id = pps.id
          and    pps.patch_name = cp_geocode_patch_name;




    ln_full_name                   varchar2(40);
    ln_assignment_id               number;
    ln_assignment_number           varchar2(17);
    ln_city_name                   varchar2(20);
    ln_jd_code                     varchar2(11);

    lv_header_label                VARCHAR2(32000);

    lv_data_row                    VARCHAR2(32000);
    lv_data_row1                   VARCHAR2(32000);

    lv_format1          varchar2(32000);


BEGIN

   hr_utility.set_location(gv_package_name || '.report_10', 10);

   /****************************************************************
   ** Concatnating the second Header Label which includes the User
   ** Defined data set so that it is printed at the end of the
   ** report.
   ****************************************************************/

    fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'X.  Summary of employees for whom new Vertex Element Entry records have been created'
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'NO ACTION IS REQUIRED.  This is for information ONLY.'
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'Please ensure that for these assignments, the tax records are as expected and the percent'
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'of time spent in each city is correct and the sum of percent of time spent in all states equals 100.'
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'These names may be duplicated from above. They are listed just for a reference.'
                                         ,p_output_file_type
                                         ));


       hr_utility.set_location(gv_package_name || '.report_10', 15);
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
      hr_utility.set_location(gv_package_name || '.report_10', 20);

      lv_format1 :=
              formated_data_string (p_input_string =>  'Full Name'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => 'Assignment Id'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => 'Assignment Number'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => 'Primary City'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => 'Jurisdiction Code'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ;

      hr_utility.set_location(gv_package_name || '.report_10', 30);


   fnd_file.put_line(fnd_file.output, lv_format1);

   if p_output_file_type ='HTML' then
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</tr>');
   end if;

   hr_utility.set_location(gv_package_name || '.report_10', 40);
   /*****************************************************
   ** Start of the Data Section of the Report
   *****************************************************/

-- HR_UTILITY.TRACE_ON(NULL,'TCL');
   open c_cursor( p_process_mode
                      ,p_geocode_patch_name
                     );

   loop
         hr_utility.set_location(gv_package_name || '.report_10', 50);

      fetch c_cursor into  ln_full_name
                               ,ln_assignment_id
                               ,ln_assignment_number
                               ,ln_city_name
                               ,ln_jd_code;

      if c_cursor%notfound then
         hr_utility.set_location(gv_package_name || '.report_10', 60);
         exit;
      end if;


      /************************************************************
      ** If Assignment Set is used, pick up only those employee
      ** assignments which are part of the Assignment Set - STATIC
      ** or DYNAMIC.
      ************************************************************/
      hr_utility.set_location(gv_package_name || '.report_10', 70);
      hr_utility.trace('Assignment ID = '     || ln_assignment_id);


         hr_utility.set_location(gv_package_name || '.report_10', 80);
         formated_static_data( ln_full_name
                              ,ln_assignment_id
                              ,ln_assignment_number
                              ,null
                              ,ln_city_name
                              ,ln_jd_code
                              ,null
                              ,null
                              ,null
                              ,p_output_file_type
                              ,lv_data_row1);

         lv_data_row := lv_data_row1;
         hr_utility.set_location(gv_package_name || '.report_10', 90);

--           if p_output_file_type ='HTML' then
               lv_data_row := '<tr>' || lv_data_row || '</tr>' ;
--            end if;

        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, lv_data_row);


      /*****************************************************************
      ** initialize Data varaibles
      *****************************************************************/
      lv_data_row  := null;
   end loop;
   close c_cursor;

   /*****************************************************
   ** Close of the Data Section of the Report
   *****************************************************/

   if p_output_file_type ='HTML' then
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</table></body></html>');
   end if;

  END report_10;

  PROCEDURE report_11
             (p_process_mode              in  varchar2
             ,p_geocode_patch_name        in  varchar2
             ,p_output_file_type          in  varchar2
             )
  IS


    /************************************************************
    ** Cursor to get all the employee and assignment data.
    ************************************************************/
    cursor c_cursor ( cp_process_mode         in varchar
                          ,cp_geocode_patch_name   in varchar
                      ) is

          select    /*+ ORDERED
                   INDEX (PAY_US_GEO_UPDATE PAY_US_GEO_UPDATE_N2 )
                   INDEX (PAY_PATCH_STATUS  PAY_PATCH_STATUS_N1) */
                  distinct old_juri_code ,
                  new_juri_code
           from  pay_patch_status pps,
                 pay_us_geo_update pgu
          where  pgu.process_type = 'TAX_RULES_CHANGE'
          and    pgu.process_mode = cp_process_mode
          and    pgu.id = pps.id
          and    pps.patch_name = cp_geocode_patch_name;

    ln_old_jd_code                     varchar2(11);
    ln_new_jd_code                     varchar2(11);

    lv_header_label                VARCHAR2(32000);

    lv_data_row                    VARCHAR2(32000);
    lv_data_row1                   VARCHAR2(32000);

    lv_format1          varchar2(32000);


BEGIN

   hr_utility.set_location(gv_package_name || '.report_11', 10);

   /****************************************************************
   ** Concatnating the second Header Label which includes the User
   ** Defined data set so that it is printed at the end of the
   ** report.
   ****************************************************************/

    fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'XI.  New taxability rules.'
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'The taxability rules have been changed for the following jurisdiction codes to reflect the new jurisdiction code.'
                                         ,p_output_file_type
                                         ));

       hr_utility.set_location(gv_package_name || '.report_11', 15);
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
      hr_utility.set_location(gv_package_name || '.report_11', 20);

      lv_format1 :=
              formated_data_string (p_input_string =>  'Old JD'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => 'New JD'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type)
              ;

      hr_utility.set_location(gv_package_name || '.report_11', 30);


   fnd_file.put_line(fnd_file.output, lv_format1);

   if p_output_file_type ='HTML' then
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</tr>');
   end if;

   hr_utility.set_location(gv_package_name || '.report_11', 40);
   /*****************************************************
   ** Start of the Data Section of the Report
   *****************************************************/

-- HR_UTILITY.TRACE_ON(NULL,'TCL');
   open c_cursor( p_process_mode
                      ,p_geocode_patch_name
                     );

   loop
         hr_utility.set_location(gv_package_name || '.report_11', 50);

      fetch c_cursor into  ln_old_jd_code
                               ,ln_new_jd_code;

      if c_cursor%notfound then
         hr_utility.set_location(gv_package_name || '.report_11', 60);
         exit;
      end if;


      /************************************************************
      ** If Assignment Set is used, pick up only those employee
      ** assignments which are part of the Assignment Set - STATIC
      ** or DYNAMIC.
      ************************************************************/
      hr_utility.set_location(gv_package_name || '.report_11', 70);

         hr_utility.set_location(gv_package_name || '.report_11', 80);
         formated_static_data( null
                              ,null
                              ,null
                              ,ln_old_jd_code
                              ,null
                              ,ln_new_jd_code
                              ,null
                              ,null
                              ,null
                              ,p_output_file_type
                              ,lv_data_row1);

         lv_data_row := lv_data_row1;
         hr_utility.set_location(gv_package_name || '.report_11', 90);

--           if p_output_file_type ='HTML' then
               lv_data_row := '<tr>' || lv_data_row || '</tr>' ;
--            end if;

        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, lv_data_row);


      /*****************************************************************
      ** initialize Data varaibles
      *****************************************************************/
      lv_data_row  := null;
   end loop;
   close c_cursor;

   /*****************************************************
   ** Close of the Data Section of the Report
   *****************************************************/

   if p_output_file_type ='HTML' then
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</table></body></html>');
   end if;

  END report_11;


  PROCEDURE report_12
             (p_process_mode              in  varchar2
             ,p_geocode_patch_name        in  varchar2
             ,p_output_file_type          in  varchar2
             )
  IS


    /************************************************************
    ** Cursor to get all the employee and assignment data.
    ************************************************************/
    cursor c_cursor ( cp_process_mode         in varchar
                      ,cp_geocode_patch_name   in varchar
                      ) is

          SELECT   /*+ ORDERED
                     INDEX (PAY_US_MODIFIED_GEOCODES PAY_US_MODIFIED_GEOCODES_N1) */
                 distinct
                     substr(ppf.full_name,1,40),
                     paf.assignment_id ,
                     substr(paf.assignment_number,1,17),
                     substr(pmod.city_name,1,20),
                     ectr.jurisdiction_code,
                     substr(puc1.county_name,1,20),
                     pmod.state_code||'-'||pmod.new_county_code||'-'||pmod.new_city_code "New JD",
                     substr(puc2.county_name,1,20)
           FROM  pay_us_modified_geocodes pmod,
                 pay_us_emp_city_tax_rules_f ectr,
                 per_assignments_f paf,
                 per_people_f ppf,
                 pay_us_counties puc1,
                 pay_us_counties puc2
          WHERE  ppf.person_id = paf.person_id
            AND  pmod.state_code = ectr.state_code
            AND  pmod.state_code = puc1.state_code
            AND  pmod.state_code = puc2.state_code
            AND  pmod.county_code = puc1.county_code
            AND  pmod.new_county_code = puc2.county_code
            AND  pmod.county_code = ectr.county_code
            AND  pmod.new_county_code is not null
            AND  pmod.old_city_code = ectr.city_code
            AND  ectr.assignment_id = paf.assignment_id
            AND  pmod.patch_name = cp_geocode_patch_name
            and  pmod.process_type in ('P', 'PC', 'PU', 'S', 'SU', 'UP', 'US');


    ln_full_name                   varchar2(40);
    ln_assignment_id               number;
    ln_assignment_number           varchar2(17);
    ln_city_name                   varchar2(20);
    ln_old_juri_code               varchar2(11);
    ln_old_county                  varchar2(20);
    ln_new_juri_code               varchar2(11);
    ln_new_county                  varchar2(20);


    lv_header_label                VARCHAR2(32000);

    lv_data_row                    VARCHAR2(32000);
    lv_data_row1                   VARCHAR2(32000);

    lv_format1          varchar2(32000);


BEGIN

   hr_utility.set_location(gv_package_name || '.report_12', 10);

   /****************************************************************
   ** Concatnating the second Header Label which includes the User
   ** Defined data set so that it is printed at the end of the
   ** report.
   ****************************************************************/

    fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'XII. County Code Change. '
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'ACTION REQUIRED.'
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'The following assignments are located in jurisdictions which are '
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'changing their county codes. You must update the jurisdiction information'
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'for these assignments as Vertex will discontinue support for the'
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'old jurisdictions in upcoming data files and taxes will stop being withheld'
                                         ,p_output_file_type
                                         ));


       hr_utility.set_location(gv_package_name || '.report_12', 15);
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
      hr_utility.set_location(gv_package_name || '.report_12', 20);

      lv_format1 :=
              formated_data_string (p_input_string =>  'Full Name'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => 'Assignment Id'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => 'Assignment Number'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => 'Old JD'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => 'Old County'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => 'New JD'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => 'New County'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => 'City Name'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type)  ;

      hr_utility.set_location(gv_package_name || '.report_12', 30);


   fnd_file.put_line(fnd_file.output, lv_format1);

   if p_output_file_type ='HTML' then
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</tr>');
   end if;

   hr_utility.set_location(gv_package_name || '.report_12', 40);
   /*****************************************************
   ** Start of the Data Section of the Report
   *****************************************************/

-- HR_UTILITY.TRACE_ON(NULL,'TCL');
   open c_cursor( p_process_mode
                      ,p_geocode_patch_name
                     );

   loop
         hr_utility.set_location(gv_package_name || '.report_12', 50);

      fetch c_cursor into     ln_full_name
                                  ,ln_assignment_id
                                  ,ln_assignment_number
                                  ,ln_city_name
                                  ,ln_old_juri_code
                                  ,ln_old_county
                                  ,ln_new_juri_code
                                  ,ln_new_county;

      if c_cursor%notfound then
         hr_utility.set_location(gv_package_name || '.report_12', 60);
         exit;
      end if;


      /************************************************************
      ** If Assignment Set is used, pick up only those employee
      ** assignments which are part of the Assignment Set - STATIC
      ** or DYNAMIC.
      ************************************************************/
      hr_utility.set_location(gv_package_name || '.report_12', 70);
      hr_utility.trace('Assignment ID = '     || ln_assignment_id);


         hr_utility.set_location(gv_package_name || '.report_12', 80);
         formated_static_data( ln_full_name
                              ,ln_assignment_id
                              ,ln_assignment_number
                              ,null
                              ,ln_old_juri_code
                              ,ln_old_county
                              ,ln_new_juri_code
                              ,ln_new_county
                              ,ln_city_name
                              ,p_output_file_type
                              ,lv_data_row1);

         lv_data_row := lv_data_row1;
         hr_utility.set_location(gv_package_name || '.report_12', 90);

--           if p_output_file_type ='HTML' then
               lv_data_row := '<tr>' || lv_data_row || '</tr>' ;
--            end if;

        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, lv_data_row);


      /*****************************************************************
      ** initialize Data varaibles
      *****************************************************************/
      lv_data_row  := null;
   end loop;
   close c_cursor;

   /*****************************************************
   ** Close of the Data Section of the Report
   *****************************************************/

   if p_output_file_type ='HTML' then
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</table></body></html>');
   end if;

  END report_12;

  PROCEDURE report_13
             (p_process_mode              in  varchar2
             ,p_geocode_patch_name        in  varchar2
             ,p_output_file_type          in  varchar2
             )
  IS

    ln_row_count               number;


    lv_header_label                VARCHAR2(32000);

    lv_data_row                    VARCHAR2(32000);
    lv_data_row1                   VARCHAR2(32000);

    lv_format1          varchar2(32000);


BEGIN

   hr_utility.set_location(gv_package_name || '.report_13', 10);

   /****************************************************************
   ** Concatnating the second Header Label which includes the User
   ** Defined data set so that it is printed at the end of the
   ** report.
   ****************************************************************/

    fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'XIII. Table Row Counts. '
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'NO ACTION IS REQUIRED.  This is for information ONLY.'
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'The following tables were updated and now have the following row counts:'
                                         ,p_output_file_type
                                         ));


       hr_utility.set_location(gv_package_name || '.report_13', 15);
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
      hr_utility.set_location(gv_package_name || '.report_13', 20);

      lv_format1 :=
              formated_data_string (p_input_string =>  'Table Name'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => 'Row Count'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type)
              ;

      hr_utility.set_location(gv_package_name || '.report_13', 30);


   fnd_file.put_line(fnd_file.output, lv_format1);

   if p_output_file_type ='HTML' then
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</tr>');
   end if;

   hr_utility.set_location(gv_package_name || '.report_13', 40);
   /*****************************************************
   ** Start of the Data Section of the Report
   *****************************************************/

     hr_utility.set_location(gv_package_name || '.report_13', 50);

      /************************************************************
      ** If Assignment Set is used, pick up only those employee
      ** assignments which are part of the Assignment Set - STATIC
      ** or DYNAMIC.
      ************************************************************/

      hr_utility.set_location(gv_package_name || '.report_13', 60);

      --  count for pay_us_states --

       ln_row_count := 0;

       select count(*)
       into  ln_row_count
       from pay_us_states;

       formated_static_data( 'PAY_US_STATES'
                              ,ln_row_count
                              ,null
                              ,null
                              ,null
                              ,null
                              ,null
                              ,null
                              ,null
                              ,p_output_file_type
                              ,lv_data_row1);


      lv_data_row := lv_data_row1;
      hr_utility.set_location(gv_package_name || '.report_13', 65);

      lv_data_row := '<tr>' || lv_data_row || '</tr>' ;

      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, lv_data_row);

      --  count for pay_us_counties --

       ln_row_count := 0;

       select count(*)
       into  ln_row_count
       from pay_us_counties;

       formated_static_data( 'PAY_US_COUNTIES'
                            ,ln_row_count
                            ,null
                            ,null
                            ,null
                            ,null
                            ,null
                            ,null
                            ,null
                            ,p_output_file_type
                            ,lv_data_row1);


      lv_data_row := lv_data_row1;
      hr_utility.set_location(gv_package_name || '.report_13', 70);

      lv_data_row := '<tr>' || lv_data_row || '</tr>' ;

      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, lv_data_row);

      --  count for pay_us_city_geocodes --

       ln_row_count := 0;

       select count(*)
       into  ln_row_count
       from pay_us_city_geocodes;

       formated_static_data( 'PAY_US_CITY_GEOCODES'
                            ,ln_row_count
                            ,null
                            ,null
                            ,null
                            ,null
                            ,null
                            ,null
                            ,null
                            ,p_output_file_type
                            ,lv_data_row1);

      lv_data_row := lv_data_row1;
      hr_utility.set_location(gv_package_name || '.report_13', 75);

      lv_data_row := '<tr>' || lv_data_row || '</tr>' ;

      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, lv_data_row);

      --  count for pay_us_city_names --

       ln_row_count := 0;

       select count(*)
       into  ln_row_count
       from pay_us_city_names;

       formated_static_data( 'PAY_US_CITY_NAMES'
                            ,ln_row_count
                            ,null
                            ,null
                            ,null
                            ,null
                            ,null
                            ,null
                            ,null
                            ,p_output_file_type
                            ,lv_data_row1);

      lv_data_row := lv_data_row1;
      hr_utility.set_location(gv_package_name || '.report_13', 80);

      lv_data_row := '<tr>' || lv_data_row || '</tr>' ;

      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, lv_data_row);

      --  count for pay_us_zip_codes --

       ln_row_count := 0;

       select count(*)
       into  ln_row_count
       from pay_us_zip_codes;

       formated_static_data( 'PAY_US_ZIP_CODES'
                            ,ln_row_count
                            ,null
                            ,null
                            ,null
                            ,null
                            ,null
                            ,null
                            ,null
                            ,p_output_file_type
                            ,lv_data_row1);

      lv_data_row := lv_data_row1;
      hr_utility.set_location(gv_package_name || '.report_13', 85);

      lv_data_row := '<tr>' || lv_data_row || '</tr>' ;

      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, lv_data_row);

      --  count for pay_us_modified_geocodes --

       ln_row_count := 0;

       select count(*)
       into  ln_row_count
       from pay_us_modified_geocodes;

       formated_static_data( 'PAY_US_MODIFIED_GEOCODES'
                            ,ln_row_count
                            ,null
                            ,null
                            ,null
                            ,null
                            ,null
                            ,null
                            ,null
                            ,p_output_file_type
                            ,lv_data_row1);

      lv_data_row := lv_data_row1;
      hr_utility.set_location(gv_package_name || '.report_13', 90);

      lv_data_row := '<tr>' || lv_data_row || '</tr>' ;

      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, lv_data_row);
      /*****************************************************************
      ** initialize Data varaibles
      *****************************************************************/
      lv_data_row  := null;


   /*****************************************************
   ** Close of the Data Section of the Report
   *****************************************************/

   if p_output_file_type ='HTML' then
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</table></body></html>');
   end if;

  END report_13;

  PROCEDURE report_14
             (p_process_mode              in  varchar2
             ,p_geocode_patch_name        in  varchar2
             ,p_output_file_type          in  varchar2
             )
  IS


    /************************************************************
    ** Cursor to get all the employee and assignment data.
    ************************************************************/
    cursor c_cursor ( cp_process_mode         in varchar
                          ,cp_geocode_patch_name   in varchar
                      ) is

         select distinct hla.location_code "Work Location",
               hla.description "Location Description",
               hla.address_line_1 "Address",
               hla.town_or_city "City Name",
               hla.region_1 "County",
               hla.region_2 "State",
               hla.postal_code "Zipcode"
        from hr_locations_all hla
        where hla.location_id in
            (select distinct location_id
            from   per_assignments_f paf,
                   pay_us_emp_city_tax_rules_f pctr
            where  ( (        pctr.STATE_CODE  = '26'
                       and    pctr.county_code = '510'
                       and    pctr.city_code   = '1270')
                   or (       pctr.state_code  = '21'
                       and    pctr.county_code = '510'
                       and    pctr.city_code   = '0040')
                    )
            and  pctr.assignment_id = paf.assignment_id  )
        and  postal_code in
               ( '63142',
                 '63148',
                 '63149',
                 '63152',
                 '63153',
                 '63154',
                 '63159',
                 '63161',
                 '63162',
                 '63165',
                 '63168',
                 '63170',
                 '63172',
                 '63173',
                 '63174',
                 '63175',
                 '63176',
                 '63181',
                 '63183',
                 '63184',
                 '63185',
                 '63186',
                 '63187',
                 '63189',
                 '63191',
                 '63192',
                 '63193',
                 '63194',
                 '21232',
                 '21238',
                 '21242',
                 '21243',
                 '21245',
                 '21246',
                 '21247',
                 '21248',
                 '21249',
                 '21253',
                 '21254',
                 '21255',
                 '21256',
                 '21257',
                 '21258',
                 '21259',
                 '21260',
                 '21261',
                 '21262',
                 '21266',
                 '21267',
                 '21269',
                 '21271',
                 '21272',
                 '21276',
                 '21277',
                 '21291',
                 '21292',
                 '21293',
                 '21294',
                 '21295',
                 '21296',
                 '21299' );



    ln_work_location              varchar2(60);
    ln_loc_description            varchar2(240);
    ln_address                    varchar2(240);
    ln_city_name                  varchar2(30);
    ln_county                     varchar2(120);
    ln_state                      varchar2(120);
    ln_zip_code                   varchar2(30);

    lv_header_label                VARCHAR2(32000);

    lv_data_row                    VARCHAR2(32000);
    lv_data_row1                   VARCHAR2(32000);

    lv_format1          varchar2(32000);


BEGIN

   hr_utility.set_location(gv_package_name || '.report_14', 10);

   /****************************************************************
   ** Concatnating the second Header Label which includes the User
   ** Defined data set so that it is printed at the end of the
   ** report.
   ****************************************************************/

    fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'XIV. Work Location ZIP Code Support.'
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'ACTION REQUIRED.'
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'The following work locations are using ZIP Codes no longer '
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'supported by Vertex. Please review these locations and adjust'
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'Their ZIP Codes to supported values.'
                                         ,p_output_file_type
                                         ));


       hr_utility.set_location(gv_package_name || '.report_14', 15);
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
      hr_utility.set_location(gv_package_name || '.report_14', 20);

      lv_format1 :=
              formated_data_string (p_input_string =>  'Work Location'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => 'Location Description'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => 'Address'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => 'City Name'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => 'County'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => 'State'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => 'Zipcode'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type)
              ;

      hr_utility.set_location(gv_package_name || '.report_14', 30);


   fnd_file.put_line(fnd_file.output, lv_format1);

   if p_output_file_type ='HTML' then
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</tr>');
   end if;

   hr_utility.set_location(gv_package_name || '.report_14', 40);
   /*****************************************************
   ** Start of the Data Section of the Report
   *****************************************************/

-- HR_UTILITY.TRACE_ON(NULL,'TCL');
   open c_cursor( p_process_mode
                      ,p_geocode_patch_name
                     );

   loop
         hr_utility.set_location(gv_package_name || '.report_14', 50);

      fetch c_cursor into    ln_work_location
                            ,ln_loc_description
                            ,ln_address
                            ,ln_city_name
                            ,ln_county
                            ,ln_state
                            ,ln_zip_code;

      if c_cursor%notfound then
         hr_utility.set_location(gv_package_name || '.report_14', 60);
         exit;
      end if;


      /************************************************************
      ** If Assignment Set is used, pick up only those employee
      ** assignments which are part of the Assignment Set - STATIC
      ** or DYNAMIC.
      ************************************************************/
      hr_utility.set_location(gv_package_name || '.report_14', 70);

         hr_utility.set_location(gv_package_name || '.report_14', 80);
         formated_static_data( ln_work_location
                              ,null
                              ,ln_loc_description
                              ,ln_city_name
                              ,ln_county
                              ,ln_state
                              ,ln_zip_code
                              ,null
                              ,ln_address
                              ,p_output_file_type
                              ,lv_data_row1);

         lv_data_row := lv_data_row1;
         hr_utility.set_location(gv_package_name || '.report_14', 90);

--           if p_output_file_type ='HTML' then
               lv_data_row := '<tr>' || lv_data_row || '</tr>' ;
--            end if;

        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, lv_data_row);


      /*****************************************************************
      ** initialize Data varaibles
      *****************************************************************/
      lv_data_row  := null;
   end loop;
   close c_cursor;

   /*****************************************************
   ** Close of the Data Section of the Report
   *****************************************************/

   if p_output_file_type ='HTML' then
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</table></body></html>');
   end if;

  END report_14;

  PROCEDURE report_15
             (p_process_mode              in  varchar2
             ,p_geocode_patch_name        in  varchar2
             ,p_output_file_type          in  varchar2
             )
  IS


    /************************************************************
    ** Cursor to get all the employee and assignment data.
    ************************************************************/
    cursor c_cursor ( cp_process_mode         in varchar
                          ,cp_geocode_patch_name   in varchar
                      ) is

        SELECT distinct substr(ppf.full_name,1,40),
               substr(addr.address_line1 ,1,30),
               substr(addr.town_or_city,1,20),
               substr(addr.region_1 ,1,20),
               substr(addr.region_2 ,1,5),
               substr(addr.postal_code ,1,10)
        from per_addresses addr,
             per_all_people_f ppf
        where addr.person_id = ppf.person_id
        and ppf.person_id in
            (select distinct person_id
            from   per_assignments_f paf,
                   pay_us_emp_city_tax_rules_f pctr
            where  ( (        pctr.STATE_CODE  = '26'
                       and    pctr.county_code = '510'
                       and    pctr.city_code   = '1270')
                   or (       pctr.state_code  = '21'
                       and    pctr.county_code = '510'
                       and    pctr.city_code   = '0040')
                    )
            and  pctr.assignment_id = paf.assignment_id  )
        and  addr.postal_code in
               ( '63142',
                 '63148',
                 '63149',
                 '63152',
                 '63153',
                 '63154',
                 '63159',
                 '63161',
                 '63162',
                 '63165',
                 '63168',
                 '63170',
                 '63172',
                 '63173',
                 '63174',
                 '63175',
                 '63176',
                 '63181',
                 '63183',
                 '63184',
                 '63185',
                 '63186',
                 '63187',
                 '63189',
                 '63191',
                 '63192',
                 '63193',
                 '63194',
                 '21232',
                 '21238',
                 '21242',
                 '21243',
                 '21245',
                 '21246',
                 '21247',
                 '21248',
                 '21249',
                 '21253',
                 '21254',
                 '21255',
                 '21256',
                 '21257',
                 '21258',
                 '21259',
                 '21260',
                 '21261',
                 '21262',
                 '21266',
                 '21267',
                 '21269',
                 '21271',
                 '21272',
                 '21276',
                 '21277',
                 '21291',
                 '21292',
                 '21293',
                 '21294',
                 '21295',
                 '21296',
                 '21299' );



    ln_full_name                  varchar2(240);
    ln_address                    varchar2(240);
    ln_city_name                  varchar2(30);
    ln_county                     varchar2(120);
    ln_state                      varchar2(120);
    ln_zip_code                   varchar2(30);

    lv_header_label                VARCHAR2(32000);

    lv_data_row                    VARCHAR2(32000);
    lv_data_row1                   VARCHAR2(32000);

    lv_format1          varchar2(32000);


BEGIN

   hr_utility.set_location(gv_package_name || '.report_15', 10);

   /****************************************************************
   ** Concatnating the second Header Label which includes the User
   ** Defined data set so that it is printed at the end of the
   ** report.
   ****************************************************************/

    fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'XV.  Home Address ZIP Code Support.'
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'ACTION REQUIRED.'
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'The following home addresses are using ZIP Codes no longer '
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'supported by Vertex. Please review these addresses and adjust'
                                         ,p_output_file_type
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                         'their ZIP Codes to supported values.'
                                         ,p_output_file_type
                                         ));


       hr_utility.set_location(gv_package_name || '.report_15', 15);
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
      hr_utility.set_location(gv_package_name || '.report_15', 20);

      lv_format1 :=
              formated_data_string (p_input_string =>  'Full Name'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => 'Address'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => 'City Name'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => 'County'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => 'State'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => 'Zipcode'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type)
              ;

      hr_utility.set_location(gv_package_name || '.report_15', 30);


   fnd_file.put_line(fnd_file.output, lv_format1);

   if p_output_file_type ='HTML' then
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</tr>');
   end if;

   hr_utility.set_location(gv_package_name || '.report_15', 40);
   /*****************************************************
   ** Start of the Data Section of the Report
   *****************************************************/

-- HR_UTILITY.TRACE_ON(NULL,'TCL');
   open c_cursor( p_process_mode
                      ,p_geocode_patch_name
                     );

   loop
         hr_utility.set_location(gv_package_name || '.report_15', 50);

      fetch c_cursor into    ln_full_name
                            ,ln_address
                            ,ln_city_name
                            ,ln_county
                            ,ln_state
                            ,ln_zip_code;

      if c_cursor%notfound then
         hr_utility.set_location(gv_package_name || '.report_15', 60);
         exit;
      end if;


      /************************************************************
      ** If Assignment Set is used, pick up only those employee
      ** assignments which are part of the Assignment Set - STATIC
      ** or DYNAMIC.
      ************************************************************/
      hr_utility.set_location(gv_package_name || '.report_15', 70);

         hr_utility.set_location(gv_package_name || '.report_15', 80);
         formated_static_data( ln_full_name
                              ,null
                              ,ln_address
                              ,ln_city_name
                              ,ln_county
                              ,ln_state
                              ,ln_zip_code
                              ,null
                              ,null
                              ,p_output_file_type
                              ,lv_data_row1);

         lv_data_row := lv_data_row1;
         hr_utility.set_location(gv_package_name || '.report_15', 90);

--           if p_output_file_type ='HTML' then
               lv_data_row := '<tr>' || lv_data_row || '</tr>' ;
--            end if;

        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, lv_data_row);


      /*****************************************************************
      ** initialize Data varaibles
      *****************************************************************/
      lv_data_row  := null;
   end loop;
   close c_cursor;

   /*****************************************************
   ** Close of the Data Section of the Report
   *****************************************************/

   if p_output_file_type ='HTML' then
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</table></body></html>');
   end if;

  END report_15;


  /*****************************************************************
  ** This is the main procedure which is called from the Concurrent
  ** Request. All the paramaters are passed based on which it will
  ** either print a CSV format or an HTML format file.
  *****************************************************************/
  PROCEDURE extract_data
             (errbuf                      out nocopy varchar2
             ,retcode                     out nocopy number
             ,p_process_mode              in  varchar2
             ,p_geocode_patch_name        in  varchar2

             )
  IS

  lv_output_file_type varchar2(4);

BEGIN

   lv_output_file_type := 'HTML';

   hr_utility.set_location(gv_package_name || '.extract_data', 10);

   report_1 ( p_process_mode => p_process_mode
             ,p_geocode_patch_name => p_geocode_patch_name
             ,p_output_file_type   => lv_output_file_type);

   report_2 ( p_process_mode => p_process_mode
             ,p_geocode_patch_name => p_geocode_patch_name
             ,p_output_file_type   => lv_output_file_type);

   report_3 ( p_process_mode => p_process_mode
             ,p_geocode_patch_name => p_geocode_patch_name
             ,p_output_file_type   => lv_output_file_type);

   report_4 ( p_process_mode => p_process_mode
             ,p_geocode_patch_name => p_geocode_patch_name
             ,p_output_file_type   => lv_output_file_type);

   report_5 ( p_process_mode => p_process_mode
             ,p_geocode_patch_name => p_geocode_patch_name
             ,p_output_file_type   => lv_output_file_type);

   report_6 ( p_process_mode => p_process_mode
             ,p_geocode_patch_name => p_geocode_patch_name
             ,p_output_file_type   => lv_output_file_type);

   report_7 ( p_process_mode => p_process_mode
             ,p_geocode_patch_name => p_geocode_patch_name
             ,p_output_file_type   => lv_output_file_type);

   report_8 ( p_process_mode => p_process_mode
             ,p_geocode_patch_name => p_geocode_patch_name
             ,p_output_file_type   => lv_output_file_type);

   report_9 ( p_process_mode => p_process_mode
             ,p_geocode_patch_name => p_geocode_patch_name
             ,p_output_file_type   => lv_output_file_type);

   report_10 ( p_process_mode => p_process_mode
             ,p_geocode_patch_name => p_geocode_patch_name
             ,p_output_file_type   => lv_output_file_type);

   report_11 ( p_process_mode => p_process_mode
             ,p_geocode_patch_name => p_geocode_patch_name
             ,p_output_file_type   => lv_output_file_type);

   report_12 ( p_process_mode => p_process_mode
             ,p_geocode_patch_name => p_geocode_patch_name
             ,p_output_file_type   => lv_output_file_type);

   report_13 ( p_process_mode => p_process_mode
             ,p_geocode_patch_name => p_geocode_patch_name
             ,p_output_file_type   => lv_output_file_type);

   report_14 ( p_process_mode => p_process_mode
             ,p_geocode_patch_name => p_geocode_patch_name
             ,p_output_file_type   => lv_output_file_type);

   report_15 ( p_process_mode => p_process_mode
             ,p_geocode_patch_name => p_geocode_patch_name
             ,p_output_file_type   => lv_output_file_type);

   hr_utility.trace('Concurrent Request ID = ' || FND_GLOBAL.CONC_REQUEST_ID);

  END extract_data;

--begin
--hr_utility.trace_on(null, 'ELE');
end pay_us_geocode_report_pkg;

/
