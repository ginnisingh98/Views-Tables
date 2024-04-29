--------------------------------------------------------
--  DDL for Package Body PAY_EBRA_DIAGNOSTICS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_EBRA_DIAGNOSTICS" AS
/* $Header: payrundiag.pkb 120.0 2005/05/29 10:49 appldev noship $ */
--
/*****************************************************************************
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

    Name        : pay_ebra_diagnostic

    File        :

    Description : This package is used to create report many
                  error condition in Ebra architecture.
                  Output from the report can be in

                      - HTML
                      - CSV
                      - TAB

    Change List
    -----------
     Date        Name      Vers    Bug No    Description
     ----        ----      ------  -------   -----------
     17-aug-2004 djoshi    115.0             Created.
                                             in pay_payroll_actions to improve
                                             performance.
     03-sep-2004 djoshi    115.2             changed the format for date to
                                             show four year
     09-Sep-2004 kvsankar  115.3   3651755   Modified the cursors
                                             c_get_valid_count
                                             c_get_attribute_count
                                             c_run_balance_status
                                             c_attrib_bal
                                             c_attribute_validation
                                             to retriece data correctly
     09-Sep-2004 kvsankar  115.4   3651755  Modified check_balance_status
                                            function to use l_trunc_date
     16-sep-2004 djoshi    115.5            Reverted the changes that were
                                            made with legislation sepcific
                                            code. Also added the code
                                            to have valid from date to null
                                            in case of invalid Status.
                                            Code was modified to support
                                            additoinal parameter of SRS.
     11-nov-2004 djoshi   115.6  4004320    Corrected the balance

*****************************************************************************/

 /************************************************************
  ** Local Package Variables
  ************************************************************/
  gv_title       VARCHAR2(100) := ' Run Balance Diagnostic Report ';

  gv_title_sec1  VARCHAR2(100) := ' Run Balance Status ';
  gv_title_sec2  VARCHAR2(100) := ' Balance Attribute Status';
  gv_title_sec3  VARCHAR2(100) := ' Balances By Attribute ';
  gv_title_sec4  VARCHAR2(100) := ' Incorrect Run Balance and Attribute Setup';
  gv_Invalid     VARCHAR2(100);
  gv_valid       VARCHAR2(100);
  gc_csv_delimiter       VARCHAR2(1) := ',';
  gc_csv_data_delimiter  VARCHAR2(1) := '"';

  gv_html_start_data     VARCHAR2(5) := '<td>'  ;
  gv_html_end_data       VARCHAR2(5) := '</td>' ;

  gv_package_name        VARCHAR2(50) := 'pay_us_ebra_diagnostic';


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
       lv_format := '<HTML><HEAD> <CENTER> <H1> <B>' || p_input_string ||
                             '</B></H1></CENTER></HEAD>';
    end if;

    hr_utility.set_location(gv_package_name || '.formated_header_string', 40);
    return lv_format;

  END formated_header_string;


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
             ,p_bold             in varchar2
             )
  RETURN VARCHAR2
  IS

    lv_format          varchar2(1000);
    lv_bold           varchar2(10);
  BEGIN
    lv_bold := nvl(p_bold,'N');
    hr_utility.set_location(gv_package_name || '.formated_data_string', 10);
    if p_output_file_type = 'CSV' then
       hr_utility.set_location(gv_package_name || '.formated_data_string', 20);
       lv_format := gc_csv_data_delimiter || p_input_string ||
                           gc_csv_data_delimiter || gc_csv_delimiter;
    elsif p_output_file_type = 'HTML' then
       if p_input_string is null then
          hr_utility.set_location(gv_package_name || '.formated_data_string', 30);
          lv_format := gv_html_start_data || '&nbsp;' || gv_html_end_data;
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


 FUNCTION  formated_header_sec1(
              p_output_file_type  in varchar2
             )RETURN VARCHAR2
  IS

    lv_format1          varchar2(32000);

  BEGIN

      hr_utility.set_location(gv_package_name || '.formated_header_state', 10);
      lv_format1 :=
              formated_data_string (p_input_string => 'Balance Name '
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Dimension Name '
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Valid From Date'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Balance Status'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ;


      hr_utility.trace('Static Label1 = ' || lv_format1);

      return lv_format1 ;

      hr_utility.set_location(gv_package_name || '.formated_header_sec1', 40);

  END formated_header_sec1;


 FUNCTION  formated_header_sec2(
              p_output_file_type  in varchar2
             )RETURN VARCHAR2
  IS

    lv_format1          varchar2(32000);

  BEGIN

      hr_utility.set_location(gv_package_name || '.formated_header_state', 10);
      lv_format1 :=
              formated_data_string (p_input_string => 'Attribute Name '
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Valid From Date'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Attribute Status'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ;


      hr_utility.trace('Static Label1 = ' || lv_format1);

      return lv_format1 ;

      hr_utility.set_location(gv_package_name || '.formated_header_sec2', 40);

  END formated_header_sec2;



 FUNCTION  formated_header_sec3(
              p_output_file_type  in varchar2
             )RETURN VARCHAR2
  IS

    lv_format1          varchar2(32000);

  BEGIN

      hr_utility.set_location(gv_package_name || '.formated_header_state', 10);
      lv_format1 :=
              formated_data_string (p_input_string => 'Attribute Name '
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Balance Name '
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => 'Dimension Name '
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type);


      hr_utility.trace('Static Label1 = ' || lv_format1);

      return lv_format1 ;

      hr_utility.set_location(gv_package_name || '.formated_header_sec3', 40);

  END formated_header_sec3;


  FUNCTION  formated_header_sec4(
              p_output_file_type  in varchar2
             )RETURN VARCHAR2
  IS

    lv_format1          varchar2(32000);
    lv_format2          varchar2(32000);

  BEGIN

      hr_utility.set_location(gv_package_name || '.formated_header_sec4', 10);
      lv_format1 :=
              formated_data_string (p_input_string => 'Business Group Name '
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => 'Attribute Name '
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => 'Balance Name '
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => 'Dimension Name '
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ||

              formated_data_string (p_input_string => 'Save Run Balance'
                                   ,p_bold         => 'Y'
                                   ,p_output_file_type => p_output_file_type) ;



      hr_utility.trace('Static Label1 = ' || lv_format1);

      return lv_format1 ;

      hr_utility.set_location(gv_package_name || '.formated_header_sec4', 40);

  END formated_header_sec4;




 FUNCTION  formated_validation_detail(
              p_output_file_type     varchar2
             ,p_input_1                 varchar2
             ,p_input_2                 varchar2
             ,p_input_3                 varchar2
             ,p_input_4                 varchar2
             ,p_input_5                 varchar2
             ) RETURN varchar2
  IS

    lv_format1          varchar2(22000);
    lv_format2          varchar2(10000);

  BEGIN

      hr_utility.set_location(gv_package_name || '.formated_validation_detail', 10);
      lv_format1 :=
              formated_data_string (p_input_string => p_input_1
                                   ,p_bold         => 'N'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_input_2
                                   ,p_bold         => 'N'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_input_3
                                   ,p_bold         => 'N'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_input_4
                                   ,p_bold         => 'N'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_input_5
                                   ,p_bold         => 'N'
                                   ,p_output_file_type => p_output_file_type)
              ;


      hr_utility.trace('Static Label1 = ' || lv_format1);

      hr_utility.set_location(gv_package_name || '.formated_validation_details', 30);

      return lv_format1  ;

  END formated_validation_detail;


FUNCTION check_balance_status(
              p_start_date        in date,
              p_business_group_id in number,
              p_attribute_id    in number,
              p_legislation_code in varchar2
            )

  RETURN VARCHAR2
  IS

    /*************************************************************
    ** Cursor to check if the attribute_name passed as parameter
    ** exists or not.
    **************************************************************/

    CURSOR c_get_valid_count(cp_start_date           in date,
                             cp_business_group_id    in per_business_groups.business_group_id%type,
                             cp_attribute_id         in number) IS
              select /*+ ORDERED */ count(*)
                from
                     pay_balance_attributes        pba,
                     pay_balance_validation        pbv
               where pba.attribute_id     = cp_attribute_id
                 and (pba.business_group_id = cp_business_group_id
		      or pba.legislation_code  = p_legislation_code)
                 and pba.defined_balance_id  = pbv.defined_balance_id
                 and pbv.business_group_id = cp_business_group_id
                 and NVL(pbv.balance_load_date, cp_start_date) <= cp_start_date
                 and nvl(pbv.run_balance_status, 'I') = 'V';

    CURSOR c_get_attribute_count(cp_attribute_id       in number,
                                 cp_business_group_id    in per_business_groups.business_group_id%type) IS

              select count(*)
                from
                     pay_balance_attributes        pba
               where pba.attribute_id     = cp_attribute_id
	         and (pba.business_group_id = cp_business_group_id
		      or pba.legislation_code  = p_legislation_code);

     ln_attribute_exists NUMBER(1);
     ln_valid_bal_exists NUMBER(1);
     lv_return_status    VARCHAR2(10);
     lv_package_stage    VARCHAR2(50) := 'check_balance_status';

     l_attribute_count   number;
     l_valid_count       number;
     l_trunc_date        date; /* Bug 3258868 */

  BEGIN
     hr_utility.trace('Start of Procedure '||lv_package_stage);
     hr_utility.set_location(lv_package_stage,10);



     -- Validate if the attribute passed as parameter exists

     hr_utility.set_location(lv_package_stage,30);

     l_trunc_date := NVL(p_start_date, fnd_date.canonical_to_date('0001/01/01 00:00:00') ) ;

     open c_get_valid_count(l_trunc_date,
                            p_business_group_id,
                            p_attribute_id );
     fetch c_get_valid_count into l_valid_count;
     close c_get_valid_count;

     hr_utility.trace('Valid Count for '
                       ||p_attribute_id||' is '||to_char(l_valid_count));

     open c_get_attribute_count( p_attribute_id, p_business_group_id );
     fetch c_get_attribute_count into l_attribute_count;
     close c_get_attribute_count;

     hr_utility.trace('Attribute Count for '||p_attribute_id||' is '||to_char(l_attribute_count));

     if l_valid_count = l_attribute_count then

        hr_utility.set_location(lv_package_stage,40);
        lv_return_status := gv_valid;
     else

        hr_utility.set_location(lv_package_stage,50);
        hr_utility.trace('Balance Status is Invalid for Attribute -> ' ||p_attribute_id);
        lv_return_status := gv_invalid;
     end if;

     hr_utility.trace('End of Procedure ' || lv_package_stage);
     return(lv_return_status);


  EXCEPTION
    WHEN others THEN
      hr_utility.set_location(lv_package_stage,60);
      hr_utility.trace('Invalid Attribute Name');
      raise_application_error(-20101, 'Error in check_balance_status');
      raise;
  END check_balance_status;

FUNCTION  formated_detail4(
              p_output_file_type     varchar2
             ,p_input_1                 varchar2
             ,p_input_2                 varchar2
             ,p_input_3                 varchar2
             ,p_input_4                 varchar2
             ) RETURN varchar2
  IS

    lv_format1          varchar2(22000);
    lv_format2          varchar2(10000);

  BEGIN

      hr_utility.set_location(gv_package_name || '.formated_detail4', 10);
      lv_format1 :=
              formated_data_string (p_input_string => p_input_1
                                   ,p_bold         => 'N'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_input_2
                                   ,p_bold         => 'N'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_input_3
                                   ,p_bold         => 'N'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_input_4
                                   ,p_bold         => 'N'
                                   ,p_output_file_type => p_output_file_type)
              ;


      hr_utility.trace('Static Label1 = ' || lv_format1);

      hr_utility.set_location(gv_package_name || '.formated__detail4', 30);

      return lv_format1  ;

  END formated_detail4;


FUNCTION  formated_detail3(
              p_output_file_type     varchar2
             ,p_input_1                 varchar2
             ,p_input_2                 varchar2
             ,p_input_3                 varchar2
             ) RETURN varchar2
  IS

    lv_format1          varchar2(22000);
    lv_format2          varchar2(10000);

  BEGIN

      hr_utility.set_location(gv_package_name || '.formated_detail3', 10);
      lv_format1 :=
              formated_data_string (p_input_string => p_input_1
                                   ,p_bold         => 'N'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_input_2
                                   ,p_bold         => 'N'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_input_3
                                   ,p_bold         => 'N'
                                   ,p_output_file_type => p_output_file_type)
              ;


      hr_utility.trace('Static Label1 = ' || lv_format1);

      hr_utility.set_location(gv_package_name || '.formated__detail3', 30);

     return lv_format1  ;

  END formated_detail3;

 FUNCTION  formated_detail(
              p_output_file_type     varchar2
             ,p_input_1                 varchar2
             ,p_input_2                 varchar2
             ,p_input_3                 varchar2
             ,p_input_4                 varchar2
             ,p_input_5                 varchar2
             ,p_input_6                 varchar2
             ,p_input_7                 varchar2
             ) RETURN varchar2
  IS

    lv_format1          varchar2(22000);
    lv_format2          varchar2(10000);

  BEGIN

      hr_utility.set_location(gv_package_name || '.formated_detail', 10);
      lv_format1 :=
              formated_data_string (p_input_string => p_input_1
                                   ,p_bold         => 'N'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_input_2
                                   ,p_bold         => 'N'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_input_3
                                   ,p_bold         => 'N'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_input_4
                                   ,p_bold         => 'N'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_input_5
                                   ,p_bold         => 'N'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => P_input_6
                                   ,p_bold         => 'N'
                                   ,p_output_file_type => p_output_file_type) ||
              formated_data_string (p_input_string => p_input_7
                                   ,p_bold         => 'N'
                                   ,p_output_file_type => p_output_file_type)
              ;


      hr_utility.trace('Static Label1 = ' || lv_format1);

      hr_utility.set_location(gv_package_name || '.formated_detail', 30);

      return lv_format1  ;

  END formated_detail;





  /*****************************************************************
  ** This procedure is called from the Concurrent Request. Based on
  ** paramaters selected in SRS the report will
  **
  **
  **
  *****************************************************************/

  PROCEDURE ebra_diagnostics
           (errbuf                OUT nocopy    varchar2,
            retcode               OUT nocopy    number,
            p_output_file_type    IN      VARCHAR2,
            p_attribute_balance   IN      VARCHAR2
           )
  IS


    /************************************************************
    ** get_legi_Cd : Cursor to get legislation code and Business
                     group name
    ** Parameter   : Business Group Id from SRS
    ** Return      : 1.Legislation Code,
                     2.Name of the Business group

    ************************************************************/

     cursor  c_get_leg_cd(cp_business_group_id number) is
     select  org_information9,hou.name
       from  hr_organization_information hoi,hr_all_organization_units hou
      where  hoi.organization_id         =  cp_business_group_id
        and  hoi.org_information_context = 'Business Group Information'
        and  hou.organization_id = hoi.organization_id;


   /**************************************************************
     Cursor for    : Get the seeded Attributes definitions
                   : for the Legislation related to business
                   : group
     Parameter for the Cursor :
                  cp_seeded_att_details : Get attribute
     Returns
                  Attribute_id, Attribute Name
   **************************************************************/
             CURSOR c_seeded_att( cp_legislation_code varchar2)
                IS
            SELECT   attribute_id, attribute_name
              FROM
                     pay_bal_attribute_Definitions    pbad
             WHERE   pbad.legislation_code      = cp_legislation_code
          ORDER BY  attribute_name;

   /**************************************************************
     Cursor for    : Get User defined  Attributes definitions
                   : for a business group
     Parameter for the Cursor :
                  cp_userdef_att_details    :  Business group
     Returns
                  Attribute_id, Attribute Name
   **************************************************************/
             CURSOR c_userdef_att( cp_business_group_id number)
                IS
            SELECT   attribute_id, attribute_name
              FROM
                     pay_bal_attribute_Definitions    pbad
             WHERE   pbad.business_group_id   = cp_business_group_id
           order by  attribute_name;

   /**************************************************************
     Cursor for    : Get meaning of Attribute Status
                   :
     Parameter for the Cursor :

     Returns
                  Attribute_status
   **************************************************************/
             CURSOR c_valid_invalid
                IS
            SELECT hl1.meaning,hl2.meaning
              FROM hr_lookups hl1,hr_lookups hl2
             WHERE hl2.lookup_type = 'RUN_BALANCE_STATUS'
               AND hl2.lookup_code = 'V'
               AND hl1.lookup_type = 'RUN_BALANCE_STATUS'
               AND hl1.lookup_code = 'I';

   /**************************************************************
     Cursor for    : To get info on status of defined_balances
     Parameter for the Cursor        :
                cp_attribute_id      : attribute_id
                cp_business_group_id : business_group_id
     Returns
                   1. Balance_Name
                   2. Dimension_name
                   3. Load_date
                   4. run_balance_status

   **************************************************************/

          CURSOR c_run_balance_status(
                              cp_business_group_id number)

                IS
          SELECT   pbt.balance_name, pbd.dimension_name
                   , decode(pbv.run_balance_status, 'I', null
                   ,to_char(pbv.balance_load_date,'yyyy/mm/dd'))  balance_load_date
                   ,nvl(hl.meaning, hl2.meaning) Status
            FROM
                   pay_defined_balances pdb, pay_balance_types pbt
                 , pay_balance_dimensions pbd
                 , per_business_groups pbg, hr_lookups hl
                 , pay_balance_validation pbv
                 , hr_lookups hl2
           WHERE pdb.balance_type_id = pbt.balance_type_id
             AND pdb.balance_dimension_id = pbd.balance_dimension_id
             AND pdb.save_run_balance = 'Y'
             AND ((pdb.legislation_code = pbg.legislation_code)
             or  (pdb.business_group_id = pbg.business_group_id))
             AND pbg.business_group_id = cp_business_group_id
             AND hl.lookup_type(+) = 'RUN_BALANCE_STATUS'
             AND hl.lookup_code(+) = pbv.run_balance_status
             AND pbv.defined_balance_id (+) = pdb.defined_balance_id
             AND pbv.business_group_id (+) = nvl(pdb.business_group_id, cp_business_group_id)
             AND hl2.lookup_type = 'RUN_BALANCE_STATUS'
             AND hl2.lookup_code = 'I'
           ORDER BY STATUS,BALANCE_LOAD_DATE,BALANCE_NAME,DIMENSION_NAME ;




/**************************************************************
     Cursor for    : Find status of the attribute
     Parameter for the Cursor        :
                cp_business_group_id : business_group_id
     Returns
                   1. Attribute_name
                   4. Load Date
**************************************************************/

 CURSOR   c_attrib_status( cp_business_group_id number,
                           cp_attribute_id number)
   IS
  select distinct pba.attribute_id,
                   max(balance_load_date)
              FROM
                   PAY_BALANCE_VALIDATION PBV
                   ,PAY_BALANCE_ATTRIBUTES PBA
             WHERE
                    PBV.business_group_id = cp_business_group_id
                AND PBA.attribute_id = cp_attribute_id
                AND PBV.defined_balance_id = pba.defined_balance_id
                group by attribute_id;


/**************************************************************
     Cursor for    :


     Parameter for the Cursor        :
                cp_attribute_id      : attribute_id

     Returns
                   1. Attribute_name
                   2. Balance_name
                   3. Dimension_name
**************************************************************/
    CURSOR c_attrib_bal(cp_business_group_id number,
                        cp_attribute_id number
                       ,cp_legislation_code varchar2 )
        IS
     SELECT
            PBT.balance_name
           ,DIM.DIMENSION_NAME
      FROM
             PAY_BALANCE_DIMENSIONS DIM
           , PAY_BALANCE_TYPES  PBT
           , PAY_DEFINED_BALANCES PDB
           , PAY_BALANCE_ATTRIBUTES PBA
     WHERE
            PBA.attribute_id = cp_attribute_id
       and  PBA.defined_balance_id = PDB.defined_balance_id
       and  PDB.balance_type_id = PBT.balance_type_id
       and  (PBT.business_group_id = cp_business_group_id or
             PBT.legislation_code = cp_legislation_code)
       and  PDB.balance_dimension_id = DIM.balance_dimension_id;

   /**************************************************************
     Cursor for    : Find if the Balance is in Attribute but
                     Does not have save run Balancei
                     or not found in PAY_BALANCE_VALIDATIONS
     Parameter for the Cursor        :
                cp_attribute_id      : attribute_id
                cp_business_group_id : business_group_id
     Returns
                   1. Attribute_name
                   2. Dimension_name
                   3. Balance_name
                   4. run_balance_status
   **************************************************************/
    CURSOR   c_attribute_validation( cp_business_group_id number
                                     ,cp_legislation_code varchar2)
       IS
    SELECT
              BAD.ATTRIBUTE_NAME
             ,PBT.balance_name
             ,DIM.DIMENSION_NAME
             ,PDB.save_run_balance
     FROM
               PAY_BALANCE_ATTRIBUTES PBA
             , PAY_BAL_ATTRIBUTE_DEFINITIONS BAD
             , PAY_DEFINED_BALANCES PDB
             , PAY_BALANCE_TYPES  PBT
             , PAY_BALANCE_DIMENSIONS DIM
       Where  pba.attribute_id = bad.attribute_id
         and  pba.defined_balance_id = pdb.defined_balance_id
         and  pdb.balance_type_id = pbt.balance_type_id
         and  pdb.balance_dimension_id = dim.balance_dimension_id
	 and  pdb.save_run_balance is NULL
         and  ((pba.business_group_id = cp_business_group_id and pba.legislation_code is NULL) OR
               (pba.legislation_code = cp_legislation_code and pba.business_group_id is NULL))
         and  nvl(bad.legislation_code, cp_legislation_code) = cp_legislation_Code
/*         and  not Exists
             (select 1 from pay_balance_validation PBV
               where PBV.defined_balance_id = PBA.defined_balance_id
             )*/
         order by bad.attribute_name;


    /*************************************************************
    ** Local Variables
    *************************************************************/
    lvc_attribute_id               VARCHAR2(150);
    lvc_attribute_name              VARCHAR2(150);
    lvc_balance_name                VARCHAR2(150);
    lvc_dimension_name              VARCHAR2(150);
    lvc_save_run_balance_status     VARCHAR2(150);
    lvc_legislation_code            VARCHAR2(150);
    lvc_Business_group_name         VARCHAR2(150);
    lvc_date_time                   VARCHAR2(150);
    lvc_load_date                   date;
    lvd_start_date                  date;
    lvc_start_date                  VARCHAR2(150);
    lvc_balance_status              VARCHAR2(100);
    lvc_load_dates_status           VARCHAR2(150);
    lvn_business_group_id           number;
    lvn_attribute_id                number;
    lvn_start_date                  date;
    lb_print_row                   BOOLEAN := FALSE;

    lv_header_label                VARCHAR2(32000);
    /* Changed from 32000 to 22000 and 100000 */
    lv_header_label1               VARCHAR2(22000);
    lv_header_label2               VARCHAR2(10000);
    lv_report_asgn                 VARCHAR2(1) := 'N';
    lv_data_row                   VARCHAR2(32000);

    lvn_count number := 0;
    lvc_message    varchar2(32000);
BEGIN
    hr_utility.set_location(gv_package_name || 'Get Legislation code', 10);

    lvc_date_time := to_char(sysdate,'mm/dd/yyyy HH:MI');

    lvn_business_group_id := fnd_global.per_business_group_id;

    hr_utility.trace(' lvn_business_group_id = ' || lvn_business_group_id);


/* Get the Meaning of Valid and Invalid Status */


    open c_valid_invalid;
    FETCH c_valid_invalid into gv_invalid,gv_valid;
    CLOSE c_valid_invalid;

/* Initialize status to Invalid */

    lvc_balance_status := gv_invalid;

/* Print Header for the FIle */
                 fnd_file.put_line(fnd_file.output, formated_header_string(
                                   gv_title || ':-   (  ' || lvc_date_time || ' )'
                                  ,p_output_file_type
                                         ));


/* Leave 4 blank line */
    for i in 1..4 LOOP
         fnd_file.put_line(fnd_file.output, formated_header_string(
                                  '                               '
                                  ,p_output_file_type
                                         ));
    END LOOP;



/* STEP 1 : Get the Legislation Code */

       hr_utility.trace('P_OUTPUT_FILE_TYPE = ' ||  p_output_file_type );

       OPEN  c_get_leg_cd(  lvn_business_group_id );
       FETCH c_get_leg_cd INTO  lvc_legislation_code,lvc_business_group_name;
       CLOSE c_get_leg_cd;

       hr_utility.trace('Lvc_legislation_code  = ' || nvl(lvc_legislation_code,'NULL'));
       hr_utility.set_location(gv_package_name || '', 20);




/* STEP 2: Run Balance Status  Section */

      fnd_file.put_line(fnd_file.output, formated_header_string(
                                   gv_title_sec1 || '  '
                                  ,p_output_file_type
                                         ));

        IF p_output_file_type ='HTML' THEN
               FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<body>');
               FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<table border=1>');
               FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<tr>');
        END IF;

     /* Write the column  Header */

     fnd_file.put_line(fnd_file.output,formated_header_sec1( p_output_file_type));

     IF p_output_file_type ='HTML' THEN
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</tr>');
     END IF;

     FOR i in c_run_balance_status(lvn_business_Group_id) LOOP

         lv_data_row :=  formated_detail4(
                          p_output_file_type
                         ,i.balance_name
                         ,i.dimension_name
                         ,i.balance_load_date
                         ,i.status
                                   );

                      if p_output_file_type ='HTML' then
                                  lv_data_row := '<tr>' || lv_data_row || '</tr>' ;
                      end if;
                      hr_utility.trace(lv_data_row);
                      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, lv_data_row);
     END LOOP ;

     IF p_output_file_type ='HTML' THEN
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</table>');
     END IF;


/* STEP 3: FOR  the SEEDED Attribute */
/* Leave 4 blank line */
      FOR i in 1..4 LOOP
         fnd_file.put_line(fnd_file.output, formated_header_string(
                                  '                               '
                                  ,p_output_file_type
                                         ));
      END LOOP;

      fnd_file.put_line(fnd_file.output, formated_header_string(
                                   gv_title_sec2 || ' '
                                  ,p_output_file_type
                                         ));

        IF p_output_file_type ='HTML' THEN
               FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<table border=1>');
               FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<tr>');
        END IF;

    /* Write the column  Header */

     fnd_file.put_line(fnd_file.output,formated_header_sec2( p_output_file_type));

     IF p_output_file_type ='HTML' THEN
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</tr>');
     END IF;

      For i in  c_seeded_att( lvc_legislation_code ) loop
          hr_utility.trace( 'Attribute name :- ' ||  i.attribute_name);

          /* get the  max date  for attribute */

             open c_attrib_status( lvn_business_group_id ,
                                   i.attribute_id );
             fetch  c_attrib_status into lvn_attribute_id,lvd_start_date; -- 3651755
             close  c_attrib_status;

             lvc_balance_status := check_balance_status(
                                     lvd_start_date ,
                                     lvn_business_Group_id,
                                     lvn_attribute_id,
                                     lvc_legislation_code );

            hr_utility.trace('Returned status is ' ||  lvc_balance_status );
            /* if the Status is INVALID then we will not give the valid date*/
              IF lvc_balance_status = gv_invalid THEN
                   lvd_start_date := NULL;
              END IF;

                      lv_data_row :=  formated_detail3(
                                    p_output_file_type
                                   ,i.attribute_name
                                   ,to_Char(lvd_start_date,'yyyy/mm/dd')
                                   ,lvc_balance_status
                                   );

                      if p_output_file_type ='HTML' then
                                  lv_data_row := '<tr>' || lv_data_row || '</tr>' ;
                      end if;
                      hr_utility.trace(lv_data_row);
                      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, lv_data_row);


   END LOOP ; /* c_seeded_att */

   /* STEP 5 : For USER DEFINED attributes*/

  For i in  c_userdef_att( lvn_business_group_id ) loop
          hr_utility.trace( 'Attribute name :- ' ||  i.attribute_name);

          /* get the attribute_id and max date  for attribute */

             open c_attrib_status( lvn_business_group_id ,
                                   i.attribute_id );
             fetch  c_attrib_status into lvn_attribute_id,lvd_start_date;
             close  c_attrib_status;

             lvc_balance_status := check_balance_status(
                                     lvd_start_date ,
                                     lvn_business_Group_id,
                                     lvn_attribute_id,
                                     lvc_legislation_code );
           /* if the Status is INVALID then we will not give the valid date*/
              IF lvc_balance_status = gv_invalid THEN
                   lvd_start_date := NULL;
              END IF;

            lv_data_row :=  formated_detail3(
                                    p_output_file_type
                                   ,i.attribute_name
                                   ,to_Char(lvd_start_date,'yyyy/mm/dd')
                                   ,lvc_balance_status
                                   );

                      if p_output_file_type ='HTML' then
                                  lv_data_row := '<tr>' || lv_data_row || '</tr>' ;
                      end if;
                      hr_utility.trace(lv_data_row);
                      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, lv_data_row);


   END LOOP ; /* c_userdef_att */

     IF p_output_file_type ='HTML' THEN
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</table>');
     END IF;



    /* Step 6 section 3 */

    /* If the Parameter  has been selected in SRS as Yes then only Execute this Section 3 */

   IF  p_attribute_balance = 'Y' THEN

      FOR i in 1..4 LOOP
         fnd_file.put_line(fnd_file.output, formated_header_string(
                                  '                               '
                                  ,p_output_file_type
                                         ));
      END LOOP;

      fnd_file.put_line(fnd_file.output, formated_header_string(
                                   gv_title_sec3 || '  '
                                  ,p_output_file_type
                                         ));

        IF p_output_file_type ='HTML' THEN
               FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<table border=1>');
               FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<tr>');
        END IF;

    /* Write the column  Header */

     fnd_file.put_line(fnd_file.output,formated_header_sec3( p_output_file_type));

     IF p_output_file_type ='HTML' THEN
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</tr>');
     END IF;

      For i in  c_seeded_att( lvc_legislation_code ) loop
          hr_utility.trace( 'Attribute name :- ' ||  i.attribute_name);

          /* write the balance and dimension name */

           FOR J IN  c_attrib_bal(lvn_business_group_id, i.attribute_id,lvc_legislation_code) loop

                      lv_data_row :=  formated_detail3(
                                    p_output_file_type
                                   ,i.attribute_name
                                   ,j.balance_name
                                   ,j.dimension_name
                                   );

                      if p_output_file_type ='HTML' then
                                  lv_data_row := '<tr>' || lv_data_row || '</tr>' ;
                      end if;
                      hr_utility.trace(lv_data_row);
                      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, lv_data_row);
            END LOOP;

   END LOOP ; /* c_seeded_att */

     For i in  c_userdef_att( lvn_business_group_id ) loop
          hr_utility.trace( 'Attribute name :- ' ||  i.attribute_name);

         /* write the balance and dimension name */

           FOR J IN  c_attrib_bal(lvn_business_group_id, i.attribute_id,lvc_legislation_code) loop

                      lv_data_row :=  formated_detail3(
                                    p_output_file_type
                                   ,i.attribute_name
                                   ,j.balance_name
                                   ,j.dimension_name
                                   );

                      if p_output_file_type ='HTML' then
                                  lv_data_row := '<tr>' || lv_data_row || '</tr>' ;
                      end if;
                      hr_utility.trace(lv_data_row);
                      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, lv_data_row);
            END LOOP;

     END LOOP ; /* c_userdef_att */

   IF p_output_file_type ='HTML' THEN
               FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</table>');

   END IF;

   END IF ; /*  IF  p_attribute_balance = 'Y'  */



   /* STEP 8 Last section */
   hr_utility.trace('STEP 8 Validation Section ');

     FOR j in   c_attribute_validation(   lvn_business_group_id
                ,lvc_legislation_code )
     LOOP
        lvn_count := lvn_count   +1;
        /* Print only first time */
        IF lvn_count = 1 THEN

             fnd_file.put_line(fnd_file.output, formated_header_string(
                        gv_title_sec4  || '  '
                        ,p_output_file_type
                       ));



          IF p_output_file_type ='HTML' THEN
               FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<table border=1>');
               FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<tr>');
          END IF;

          /* Write the column  Header */

          fnd_file.put_line(fnd_file.output,formated_header_sec4( p_output_file_type));

          IF p_output_file_type ='HTML' THEN
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</tr>');
          END IF;

        END IF; /* lvn_count */

        lv_data_row :=  formated_validation_detail(
                         p_output_file_type
                        ,lvc_business_group_name
                        ,j.attribute_name
                         ,j.balance_name
                         ,j.dimension_name
                         ,j.save_run_balance
                         );

         if p_output_file_type ='HTML' then
                        lv_data_row := '<tr>' || lv_data_row || '</tr>' ;
         end if;
         hr_utility.trace(lv_data_row);
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT, lv_data_row);


     END LOOP; /* c_attrib_details */


          IF p_output_file_type ='HTML' THEN
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</table>');
         END IF;

     IF p_output_file_type ='HTML' THEN
        UPDATE fnd_concurrent_requests
           SET output_file_type = 'HTML'
         WHERE request_id = FND_GLOBAL.CONC_REQUEST_ID ;
     END IF;

end ebra_diagnostics;
--begin
--hr_utility.trace_on(null, 'ORACLE');
end   pay_ebra_diagnostics;

/
