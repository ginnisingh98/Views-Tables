--------------------------------------------------------
--  DDL for Package Body PER_MX_SSAFFL_EXTRACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_MX_SSAFFL_EXTRACT_PKG" AS
/* $Header: pemxssrp.pkb 120.0 2005/05/31 11:28:19 appldev noship $ */
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

    Name        : per_mx_ssaffl_extract_pkg

    Description : Package for the SS Affiliation Reports. The package
                  generated the output file in the specified user
                  format. The current formats supported are
                      - HTML
                      - CSV

    Change List
    -----------
     Date        Name      Vers    Bug No    Description
     ----        ----      ------  -------   -----------
     07-MAY-2004 kthirmiy    115.0           Created.
     19-MAY-2004 kthirmiy    115.1           Changed affltype to check
                                             for R - Hires/Rehires
                                             for B - Separations
     11-JUN-2004 kthirmiy    115.2           Changed affltype to check
                                             for HIRES - Hires/Rehires
                                             for SEPARATIONS - Separations
     17-JUN-2004 kthirmiy    115.3           version update
*/

  /************************************************************
  ** Local Package Variables
  ************************************************************/
  gv_title               VARCHAR2(100);
  gc_csv_delimiter       VARCHAR2(1) ;
  gc_csv_data_delimiter  VARCHAR2(1) ;

  gv_html_start_data     VARCHAR2(5) ;
  gv_html_end_data       VARCHAR2(5) ;

  gv_package_name        VARCHAR2(50) ;
  g_output_file_type     VARCHAR2(10) ;

  /******************************************************************
  ** Function Returns the formated input string based on the
  ** Output format. If the format is CSV then the values are returned
  ** seperated by comma (,). If the format is HTML then the returned
  ** string as the HTML tags. The parameter p_bold only works for
  ** the HTML format.
  ******************************************************************/
  FUNCTION formated_data_string
             (p_input_string     in varchar2
             )
  RETURN VARCHAR2
  IS

    lv_format          varchar2(1000);
    lv_bold            varchar2(1);
  BEGIN
    lv_bold :='N' ;

    hr_utility.set_location(gv_package_name || '.formated_data_string', 10);
    if g_output_file_type = 'CSV' then
       hr_utility.set_location(gv_package_name || '.formated_data_string', 20);
       lv_format := gc_csv_data_delimiter || p_input_string ||
                           gc_csv_data_delimiter || gc_csv_delimiter;
    elsif g_output_file_type = 'HTML' then
       if p_input_string is null then
          hr_utility.set_location(gv_package_name || '.formated_data_string', 30);
          lv_format := gv_html_start_data || '\&nbsp;' || gv_html_end_data;
       else
          if lv_bold = 'Y' then
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
             )
  RETURN VARCHAR2
  IS

    lv_format          varchar2(1000);

  BEGIN
    hr_utility.set_location(gv_package_name || '.formated_header_string', 10);
    if g_output_file_type = 'CSV' then
       hr_utility.set_location(gv_package_name || '.formated_header_string', 20);
       lv_format := p_input_string;
    elsif g_output_file_type = 'HTML' then
       hr_utility.set_location(gv_package_name || '.formated_header_string', 30);
       lv_format := '<HTML><HEAD> <CENTER> <H1> <B>' || p_input_string ||
                             '</B></H1></CENTER></HEAD>';
    end if;

    hr_utility.set_location(gv_package_name || '.formated_header_string', 40);
    return lv_format;

  END formated_header_string;



  /*****************************************************************
  ** This is the main procedure which is called from the Concurrent
  ** Request. All the paramaters are passed based on which it will
  ** either print a CSV format or an HTML format file.
  *****************************************************************/
  PROCEDURE ssaffl_extract
             (errbuf                      out nocopy varchar2
             ,retcode                     out nocopy number
             ,p_business_group_id         in  number
             ,p_tax_unit_id               in  number
             ,p_affl_type                 in  varchar2
             ,p_output_file_type          in  varchar2
             )
  IS


    /************************************************************
    ** Cursor to get the hire/rehire affiliation records from
    ** pay_action_information table
    ************************************************************/
    cursor c_hire_details( cp_tax_unit_id          in number
                      ) is
    select formated_data_string(action_information1)||
           formated_data_string(action_information2)||
           formated_data_string(action_information3) ||
           formated_data_string(action_information4) ||
           formated_data_string(action_information5) ||
           formated_data_string(action_information6) ||
           formated_data_string(action_information7) ||
           formated_data_string(action_information8) ||
           formated_data_string('      ')              ||
           formated_data_string(action_information10) ||
           formated_data_string(action_information11) ||
           formated_data_string(action_information12) ||
           formated_data_string(action_information13) ||
           formated_data_string(action_information14) ||
           formated_data_string('  ')                   ||
           formated_data_string(action_information16) ||
           formated_data_string(action_information17) ||
           formated_data_string(action_information18) ||
           formated_data_string(' ')                    ||
           formated_data_string(action_information20) ||
           formated_data_string(action_information21)
     from pay_action_information
     where tax_unit_id = cp_tax_unit_id
     and action_context_type ='AAP'
     and action_information_category = 'MX SS HIRE DETAILS'
     and action_information22 ='A' ;



    /************************************************************
    ** Cursor to get the HIRE/reHIRE affiliation records from
    ** pay_action_information table
    ************************************************************/
    cursor c_sep_details( cp_tax_unit_id          in number
                      ) is
    select
          formated_data_string(action_information1) ||
          formated_data_string(action_information2) ||
          formated_data_string(action_information3) ||
          formated_data_string(action_information4) ||
          formated_data_string(action_information5) ||
          formated_data_string(action_information6) ||
          formated_data_string(action_information7) ||
          formated_data_string('000000000000000') ||
          formated_data_string(action_information9) ||
          formated_data_string('     ')                ||
          formated_data_string(action_information11) ||
          formated_data_string(action_information12) ||
          formated_data_string(action_information13) ||
          formated_data_string(action_information14) ||
          formated_data_string('                  ')   ||
          formated_data_string(action_information16)
     from pay_action_information
     where tax_unit_id = cp_tax_unit_id
     and action_context_type ='AAP'
     and action_information_category = 'MX SS SEPARATION DETAILS'
     and action_information22 ='A' ;

    /*************************************************************
    ** Local Variables
    *************************************************************/

    lv_title1                      VARCHAR2(100);
    lv_title2                      VARCHAR2(100);

    lv_data_row                    VARCHAR2(32000);

BEGIN

   gv_package_name        := 'per_mx_ssaffl_extract_pkg';
   g_output_file_type     := p_output_file_type ;
   gc_csv_delimiter       := ',';
   gc_csv_data_delimiter  := '"';

   gv_html_start_data     := '<td>'  ;
   gv_html_end_data       := '</td>' ;


   lv_data_row  := null ;

   hr_utility.set_location(gv_package_name || '.ssaffl_extract', 10);

   if p_affl_type = 'HIRES' then
      lv_title1 := 'Soical Security Hire/Rehire Affiliation Transactions'  ;
   elsif p_affl_type ='SEPARATIONS' then
      lv_title1 := 'Soical Security Separation Transactions' ;
   end if;

/*
   fnd_file.put_line(fnd_file.output, formated_header_string(
                                          lv_title1
                                         ));

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                          '                                         '
                                         ));
*/


   if p_affl_type='HIRES' then
      hr_utility.set_location(gv_package_name || '.ssaffl_extract', 20);
      open c_HIRE_details(p_tax_unit_id );
      loop
        fetch c_HIRE_details into lv_data_row;
        if c_HIRE_details%notfound then
           hr_utility.set_location(gv_package_name || '.ssaffl_extract', 100);
           exit;
        end if;
        if g_output_file_type ='HTML' then
           lv_data_row := '<tr>' || lv_data_row || '</tr>' ;
        end if;
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, lv_data_row);
      end loop ;
      close c_HIRE_details ;


      update pay_action_information
      set action_information22='M',
          action_information23='Reported in the IMSS Mag Tape'
      where tax_unit_id = p_tax_unit_id
      and action_context_type ='AAP'
      and action_information_category = 'MX SS HIRE DETAILS'
      and action_information22 ='A' ;


    elsif p_affl_type='SEPARATIONS' then

      hr_utility.set_location(gv_package_name || '.ssaffl_extract', 30);
      open c_SEP_details(p_tax_unit_id );
      loop
         fetch c_sep_details into lv_data_row ;
         if c_sep_details%notfound then
            hr_utility.set_location(gv_package_name || '.ssaffl_extract', 100);
            exit;
         end if;
         if g_output_file_type ='HTML' then
            lv_data_row := '<tr>' || lv_data_row || '</tr>' ;
         end if;
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT, lv_data_row);
      end loop ;
      close c_sep_details ;

      update pay_action_information
      set action_information22='M',
          action_information23='Reported in the IMSS Mag Tape'
      where tax_unit_id = p_tax_unit_id
      and action_context_type ='AAP'
      and action_information_category = 'MX SS SEPARATION DETAILS'
      and action_information22 ='A' ;

   end if;
   hr_utility.set_location(gv_package_name || '.ssaffl_extract', 40);

   if p_output_file_type ='HTML' then
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</table></body></html>');
   end if;
   commit ;

  END ssaffl_extract;

--begin
--hr_utility.trace_on(null, 'ELE');
end per_mx_ssaffl_extract_pkg;

/
