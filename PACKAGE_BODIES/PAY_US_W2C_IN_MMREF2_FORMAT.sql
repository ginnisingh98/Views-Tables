--------------------------------------------------------
--  DDL for Package Body PAY_US_W2C_IN_MMREF2_FORMAT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_W2C_IN_MMREF2_FORMAT" AS
/* $Header: payusw2cinmmref2.pkb 120.2 2007/01/10 12:46:30 sudedas noship $  */

 /*===========================================================================+
 |               Copyright (c) 2001 Oracle Corporation                        |
 |                  Redwood Shores, California, USA                           |
 |                       All rights reserved.                                 |
 +============================================================================+
  Name
    pay_us_w2c_in_mmref2_format

  File Name:
    payusw2cinmmref2.pkb

  Purpose
    The purpose of this package is to support the generation of magnetic tape W-2c
    reports in MMREF-2 format for US legilsative requirements.

  Notes

  Parameters: The following parameters are used in all the functions.
               p_effective_date -
                           This parameter indicates the year for the function.
               p_report_type -
                           This parameter will have the type of the report.
                           eg: 'W2C'
               p_format -
                          This parameter will have the format to be printed
                          on W2C. eg:'MMREF2'
               p_report_qualifier -
                          This will support currently only FED as W2c doesn't
                          support State
               p_record_name -
                          This parameter will have the particular
                               record name. eg: RCA,RCF,RCE,RCT etc.
               p_validate -
                           This parameter will check whether it wants to
                            validate the error condition or override the checking.
                            'N'- Override
                            'Y'- Check
               p_exclude_from_output -
                           This out parameter gives the information on
                           whether the record has to be printed or not.
                           'Y'- Do not print.
                           'N'- Print.

  Change List
  -----------
  Date        Name     Vers   Bug No  Description
  ----------- -------- ------ ------- --------------------------
  24-OCT-2003 ppanda   115.0          created
  10-DEC-2003 ppanda                  RCW and RCO record formatting changed
  11-DEC-2003 ppanda   115.   3313413 RCU reocod formatting changed for all
                                      amounts
  18-OCT-2004 meshah   115.6  3769733 RCW has been changed to use
                                      A_W2_TP_SICK_PAY_PER_GRE_YTD(wages)
                                      instead of
                                      A_FIT_3RD_PARTY_PER_GRE_YTD(withheld).
  26-OCT-2004 meshah   115.6  3650105 added parameter_record(21) in
                                      format_w2c_total_record for ER Health
                                      Savings account. using p_output_43 and
                                      p_output_44 to store old and new values.
                                      GET_ARCHIVED_VALUES has also been changed
                                      to fetch the archived values for ER HSA.
  09-NOV-2004 meshah   115.7  3996391 changed format_w2c_total_record function.
                                      changed the p_parameter_name for 15 and
                                      16.
  16-NOV-2004 meshah   115.8          now checking for l_rco_neg_flag and
                                      l_rcw_neg_flag before adding the values
                                      for the total record.
  30-DEC-2004 rsethupa                now checking for l_rcw_neg_flag also
                                      before incrementing the count for valid
                                      RCU records.
  03-Jan-2005 sodhingr 115.9  4398606 RCW changed to report combatpay and 409
                                      deferrals.
                                      RCO changed to report 409 income and
                                      also changed RCU and RCT record to report
                                      totals.
                                      RCA changed to restrict the trns_pin to
                                      8 chars.
  10-Jan-2007 sausingh 115.11 5358272 Changed GET_ARCHIVED_VALUES,
              sudedas                 pay_us_w2c_RCW_record,format_w2c_total_record,
                                      print_w2c_record_header for Roth 401k/403b
 ============================================================================*/
 -- Global Variable

    g_number	NUMBER;
    l_return    varchar2(100);
    end_date    date := to_date('31/12/4712','DD/MM/YYYY');

  /******************************************************************
   ** Package Local Variables
   ******************************************************************/
   gv_package varchar2(50) := 'pay_us_w2c_in_mmref2_format';

/* -------------------------------------------------------------
   Function Name : print_record_header
   Purpose       : Function will return the String for header
                   or title line for the Table or table heading
                   related to record for printing in audit files

   Error checking

   Special Note  :

  -------------------------------------------------------------- */

FUNCTION print_w2c_record_header(
                   p_effective_date       IN  varchar2,
                   p_report_type          IN  varchar2,
                   p_format               IN  varchar2,
                   p_report_qualifier     IN  varchar2,
                   p_record_name          IN  varchar2,
                   p_input_1              IN  varchar2,
                   p_input_2              IN  varchar2,
                   p_input_3              IN  varchar2,
                   p_input_4              IN  varchar2,
                   p_input_5              IN  varchar2,
                   p_validate             IN  varchar2,
                   p_exclude_from_output  OUT nocopy varchar2,
                   sp_out_1               OUT nocopy varchar2,
                   sp_out_2               OUT nocopy varchar2,
                   sp_out_3               OUT nocopy varchar2,
                   sp_out_4               OUT nocopy varchar2,
                   sp_out_5               OUT nocopy varchar2,
                   sp_out_6               OUT nocopy varchar2,
                   sp_out_7               OUT nocopy varchar2,
                   sp_out_8               OUT nocopy varchar2,
                   sp_out_9               OUT nocopy varchar2,
                   sp_out_10              OUT nocopy varchar2
                 )  RETURN VARCHAR2
IS

  header_string        varchar2(2500);
  return_header_string varchar2(2500);

  l_header_2      varchar2(900);
  l_header_3      varchar2(900);
  l_header_4      varchar2(900);
  l_header_5      varchar2(900);
  l_header_8      varchar2(900);
  l_header_9      varchar2(900);

  l_header_20     varchar2(900);
  l_header_21     varchar2(900);
  l_report_format varchar2(15);
  l_header_29     varchar2(900);
  l_header_34     varchar2(900);
  l_name_header   varchar2(900);
  l_records       varchar2(900);


BEGIN
    l_report_format := p_input_1;
    hr_utility.trace('Begin Function'|| gv_package ||'.print_w2c_record_header ');
    IF p_format = 'MMREF2' THEN

       IF p_record_name = 'RCW' THEN
          hr_utility.trace('Formating RCW Record in'|| gv_package ||'.print_w2c_record_header ');
          header_string :=
            pay_us_mmrf_print_rec_header.mmrf2_format_rcw_record_header(
                                                         p_report_type,
                                                         p_format,
                                                         p_report_qualifier,
                                                         p_record_name
                                                       );
       ELSIF p_record_name = 'RCO' THEN
          hr_utility.trace('Formating RCO Record in'|| gv_package ||'.print_w2c_record_header ');
          header_string:=
            pay_us_mmrf_print_rec_header.mmrf2_format_rco_record_header(
                                                        p_report_type,
                                                        p_format,
                                                        p_report_qualifier,
                                                        p_record_name
                                                      );
       END IF; /* p_record_name */
    END IF; /* p_format */
    hr_utility.trace('splitting the header string ');
    return_header_string := substr(header_string,1,200);
    sp_out_1:=substr(header_string,201,250);
    sp_out_2:=substr(header_string,451,250);
    sp_out_3:=substr(header_string,701,250);
    sp_out_4:=substr(header_string,951,250);
    sp_out_5:=substr(header_string,1201,250);
    sp_out_6:=substr(header_string,1451,250);
    sp_out_7:=substr(header_string,1701,250);
    sp_out_8:=substr(header_string,1951,250);
    sp_out_9:=substr(header_string,2201,250);
    sp_out_10:=substr(header_string,2451);

    p_exclude_from_output:='N';
    hr_utility.trace('Length of return_header_string := ' || length(return_header_string)) ;
    hr_utility.trace('return_header_string  = '||return_header_string);
    hr_utility.trace('sp_out_1:='||sp_out_1);
    hr_utility.trace('sp_out_2:='||sp_out_2);
    hr_utility.trace('sp_out_3:='||sp_out_3);
    hr_utility.trace('sp_out_4:='||sp_out_4);
    hr_utility.trace('sp_out_5:='||sp_out_5);
    hr_utility.trace('sp_out_6:='||sp_out_6);
    hr_utility.trace('sp_out_7:='||sp_out_7);
    hr_utility.trace('sp_out_8:='||sp_out_8);
    hr_utility.trace('sp_out_9:='||sp_out_9);
    hr_utility.trace('sp_out_10:='||sp_out_10);
    hr_utility.trace('Recod Header Formating completed in'|| gv_package
                      ||'.print_w2c_record_header ');
   RETURN return_header_string;
END print_w2c_record_header;

/* ---------------------------------------------------------------
   Function Name : format_w2c_record
   Purpose       : This is a geralised function which can be used
                   in W-2c MAg Formula to format Variaous records
   Error checking

   Special Note  :

   parameters    :

-------------------------------------------------------------------- */

FUNCTION format_w2c_record(
                   p_effective_date       IN  varchar2,
                   p_report_type          IN  varchar2,
                   p_format               IN  varchar2,
                   p_report_qualifier     IN  varchar2,
                   p_record_name          IN  varchar2,
                   p_input_1              IN  varchar2,
                   p_input_2              IN  varchar2,
                   p_input_3              IN  varchar2,
                   p_input_4              IN  varchar2,
                   p_input_5              IN  varchar2,
                   p_input_6              IN  varchar2,
                   p_input_7              IN  varchar2,
                   p_input_8              IN  varchar2,
                   p_input_9              IN  varchar2,
                   p_input_10             IN  varchar2,
                   p_input_11             IN  varchar2,
                   p_input_12             IN  varchar2,
                   p_input_13             IN  varchar2,
                   p_input_14             IN  varchar2,
                   p_input_15             IN  varchar2,
                   p_input_16             IN  varchar2,
                   p_input_17             IN  varchar2,
                   p_input_18             IN  varchar2,
                   p_input_19             IN  varchar2,
                   p_input_20             IN  varchar2,
                   p_input_21             IN  varchar2,
                   p_input_22             IN  varchar2,
                   p_input_23             IN  varchar2,
                   p_input_24             IN  varchar2,
                   p_input_25             IN  varchar2,
                   p_input_26             IN  varchar2,
                   p_input_27             IN  varchar2,
                   p_input_28             IN  varchar2,
                   p_input_29             IN  varchar2,
                   p_input_30             IN  varchar2,
                   p_input_31             IN  varchar2,
                   p_input_32             IN  varchar2,
                   p_input_33             IN  varchar2,
                   p_input_34             IN  varchar2,
                   p_input_35             IN  varchar2,
                   p_input_36             IN  varchar2,
                   p_input_37             IN  varchar2,
                   p_input_38             IN  varchar2,
                   p_input_39             IN  varchar2,
                   p_input_40             IN  varchar2,
                   p_validate             IN  varchar2,
                   p_exclude_from_output  OUT nocopy varchar2,
                   sp_out_1               OUT nocopy varchar2,
                   sp_out_2               OUT nocopy varchar2,
                   sp_out_3               OUT nocopy varchar2,
                   sp_out_4               OUT nocopy varchar2,
                   sp_out_5               OUT nocopy varchar2,
                   ret_str_len            OUT nocopy number
                 ) RETURN VARCHAR2
IS

return_value               varchar2(32767);
l_exclude_from_output_chk  boolean;
main_return_string         varchar2(300);
l_total_rcw_records        number := 0;
ln_return_value            number := 0;
BEGIN

  hr_utility.trace(' p_report_qualifier  = '||p_report_qualifier);
  hr_utility.trace(' p_record_name  = '     ||p_record_name);
  hr_utility.trace(' p_input_2      = '     ||p_input_2);
  hr_utility.trace(' p_input_2      = '     ||p_input_2);
  hr_utility.trace(' p_input_3      = '     ||p_input_3);
  hr_utility.trace(' p_input_4      = '     ||p_input_4);
  hr_utility.trace(' p_input_5      = '     ||p_input_5);
  hr_utility.trace(' p_input_6      = '     ||p_input_6);
  hr_utility.trace(' p_input_7      = '     ||p_input_7);
  hr_utility.trace(' p_input_8      = '     ||p_input_8);
  hr_utility.trace(' p_input_9      = '     ||p_input_9);
  hr_utility.trace(' p_input_10     = '     ||p_input_10);
  hr_utility.trace(' p_input_11     = '     ||p_input_11);
  hr_utility.trace(' p_input_12     = '     ||p_input_12);
  hr_utility.trace(' p_input_13     = '     ||p_input_13);
  hr_utility.trace(' p_input_14     = '     ||p_input_14);
  hr_utility.trace(' p_input_15     = '     ||p_input_15);
  hr_utility.trace(' p_input_16     = '     ||p_input_16);
  hr_utility.trace(' p_input_17     = '     ||p_input_17);
  hr_utility.trace(' p_input_18     = '     ||p_input_18);
  hr_utility.trace(' p_input_19     = '     ||p_input_19);
  hr_utility.trace(' p_input_20     = '     ||p_input_20);
  hr_utility.trace(' p_input_21     = '     ||p_input_21);
  hr_utility.trace(' p_input_22     = '     ||p_input_22);
  hr_utility.trace(' p_input_23     = '     ||p_input_23);
  hr_utility.trace(' p_input_24     = '     ||p_input_24);
  hr_utility.trace(' p_input_25     = '     ||p_input_25);
  hr_utility.trace(' p_input_26     = '     ||p_input_26);
  hr_utility.trace(' p_input_27     = '     ||p_input_27);
  hr_utility.trace(' p_input_28     = '     ||p_input_28);
  hr_utility.trace(' p_input_29     = '     ||p_input_29);
  hr_utility.trace(' p_input_30     = '     ||p_input_30);
  hr_utility.trace(' p_input_31     = '     ||p_input_31);
  hr_utility.trace(' p_input_32     = '     ||p_input_32);
  hr_utility.trace(' p_input_33     = '     ||p_input_33);
  hr_utility.trace(' p_input_34     = '     ||p_input_34);
  hr_utility.trace(' p_input_35     = '     ||p_input_35);
  hr_utility.trace(' p_input_36     = '     ||p_input_36);
  hr_utility.trace(' p_input_37     = '     ||p_input_37);
  hr_utility.trace(' p_input_38     = '     ||p_input_38);
  hr_utility.trace(' p_input_39     = '     ||p_input_39);
  hr_utility.trace(' p_input_40     = '     ||p_input_40);

  IF p_format = 'MMREF2' THEN  -- p_format
--{
     IF (p_report_type = 'W2C') THEN
--{
        IF  p_record_name = 'RCA' THEN -- p_record_name
            hr_utility.set_location( gv_package || '.format_w2c_record',10);
            return_value := pay_us_mmrf2_w2c_format_record.format_W2C_RCA_record(
                                                p_effective_date,
                                                p_report_type,
                                                p_format,
                                                p_report_qualifier,
                                                p_record_name,
                                                p_input_1,
                                                p_input_2,
                                                p_input_3,
                                                p_input_4,
                                                p_input_5,
                                                p_input_6,
                                                p_input_7,
                                                p_input_8,
                                                p_input_9 ,
                                                p_input_10,
                                                p_input_11,
                                                p_input_12,
                                                p_input_13,
                                                p_input_14,
                                                p_input_15,
                                                p_input_16,
                                                p_input_17,
                                                p_input_18,
                                                p_input_19,
                                                p_input_20,
                                                p_input_21,
                                                p_input_22,
                                                p_input_23,
                                                p_input_24,
                                                p_input_25,
                                                p_input_26,
                                                p_input_27,
                                                p_input_28,
                                                p_input_29,
                                                p_input_30,
                                                p_input_31,
                                                p_input_32,
                                                p_input_33,
                                                p_input_34,
                                                p_input_35,
                                                p_input_36,
                                                p_input_37,
                                                p_input_38,
                                                p_input_39,
                                                p_input_40,
                                                p_validate,
                                                p_exclude_from_output,
                                                sp_out_1,
                                                sp_out_2,
                                                sp_out_3,
                                                sp_out_4,
                                                sp_out_5,
                                                ret_str_len,
                                                l_exclude_from_output_chk
                                              );
            hr_utility.set_location( gv_package || '.format_w2c_record',20);
        ELSIF p_record_name = 'RCE' THEN
            hr_utility.set_location( gv_package || '.format_w2c_record',30);
        --
        -- Initialize GRE level Totals globally defined
        --
              ln_return_value := Initialize_GRE_Level_total;
            hr_utility.set_location( gv_package || '.format_w2c_record',40);
        --
        -- Format RCE Record for the GRE
        --
              return_value :=
                   pay_us_mmrf2_w2c_format_record.format_W2C_RCE_record(
                                                p_effective_date,
                                                p_report_type,
                                                p_format,
                                                p_report_qualifier,
                                                p_record_name,
                                                p_input_1,
                                                p_input_2,
                                                p_input_3,
                                                p_input_4,
                                                p_input_5,
                                                p_input_6,
                                                p_input_7,
                                                p_input_8,
                                                p_input_9 ,
                                                p_input_10,
                                                p_input_11,
                                                p_input_12,
                                                p_input_13,
                                                p_input_14,
                                                p_input_15,
                                                p_input_16,
                                                p_input_17,
                                                p_input_18,
                                                p_input_19,
                                                p_input_20,
                                                p_input_21,
                                                p_input_22,
                                                p_input_23,
                                                p_input_24,
                                                p_input_25,
                                                p_input_26,
                                                p_input_27,
                                                p_input_28,
                                                p_input_29,
                                                p_input_30,
                                                p_input_31,
                                                p_input_32,
                                                p_input_33,
                                                p_input_34,
                                                p_input_35,
                                                p_input_36,
                                                p_input_37,
                                                p_input_38,
                                                p_input_39,
                                                p_input_40,
                                                p_validate,
                                                p_exclude_from_output,
                                                sp_out_1,
                                                sp_out_2,
                                                sp_out_3,
                                                sp_out_4,
                                                sp_out_5,
                                                ret_str_len,
                                                l_exclude_from_output_chk
                                              );
            hr_utility.set_location( gv_package || '.format_w2c_record',50);
        ELSIF p_record_name = 'RCF' THEN
            hr_utility.set_location( gv_package || '.format_w2c_record',60);
            ln_return_value := Initialize_GRE_Level_total;
              l_total_rcw_records :=
                NVL(pay_us_w2c_in_mmref2_format.number_of_valid_rcw_rcf,0);
            hr_utility.trace('Total No of RCW processed for File Total ' ||to_char(l_total_rcw_records) );
            hr_utility.trace('Formula feed Total No of RCW processed   ' ||p_input_2 );
              return_value :=
                pay_us_mmrf2_w2c_format_record.format_W2C_RCF_record(
                                                  p_effective_date,
                                                  p_report_type,
                                                  p_format,
                                                  p_report_qualifier,
                                                  p_record_name,
                                                  p_input_1,
                                                  l_total_rcw_records,
                                                  p_input_3,
                                                  p_input_4,
                                                  p_input_40,
                                                  p_validate,
                                                  p_exclude_from_output,
                                                  ret_str_len,
                                                  l_exclude_from_output_chk
                                                 );
            hr_utility.set_location( gv_package || '.format_w2c_record',70);

        ELSIF p_record_name = 'RCW' then
            hr_utility.set_location( gv_package || '.format_w2c_record',80);
            if p_input_40 = 'FLAT' then
            --{
               return_value := pay_us_w2c_in_mmref2_format.pay_us_w2c_RCW_record (
                                                p_effective_date,
                                                p_report_type,
                                                p_format,
                                                p_report_qualifier,
                                                p_record_name,
                                                p_input_18,          -- Tax_unit_ud
                                                p_input_1,           -- Record Identifier
                                                p_input_2,           --ssn,
                                                p_input_3,           --first_name,
                                                p_input_4,           --middle_name,
                                                p_input_5,           --last_name,
                                                p_input_6,           --sufix,
                                                p_input_7,           --location_address,
                                                p_input_8,           --delivery_address,
                                                p_input_9,           --city,
                                                p_input_10,          --state,
                                                p_input_11,          --zip,
                                                p_input_12,          --zip_extension,
                                                p_input_13,          --foreign_state,
                                                p_input_14,          --foreign_postal_code
                                                p_input_15,          --country_code,
                                                p_input_16,          --old_asgn_action_id,
                                                p_input_17,          --new_asgn_action_id,
                                                p_input_39,          --employee_number
                                                p_input_40,          --format_type (FLAT,CSV,BLANK)
                                                p_validate,
                                                p_exclude_from_output,
                                                sp_out_1,
                                                sp_out_2,
                                                sp_out_3,
                                                sp_out_4,
                                                sp_out_5,
                                                ret_str_len,
                                                l_exclude_from_output_chk
                                              );
            hr_utility.set_location( gv_package || '.format_w2c_record',90);
            elsif p_input_40 = 'CSV' then
            --
            -- When RCW record is formatted for FLAT format, it also formats CSV and stores
            -- the value when required it would use the CSV format record for audit purpose
            --
                  hr_utility.set_location( gv_package || '.format_w2c_record',100);
                  return_value := pay_us_w2c_in_mmref2_format.rcw_csv_record;
            elsif p_input_40 = 'BLANK' then
            --
            -- When RCW record is formatted for FLAT format, it also formats
            -- Blank CSV of RCW for audit purpose only. The blank RCW would
            -- be used for reporting Error on RCO.
            --
                  hr_utility.set_location( gv_package || '.format_w2c_record',110);
                  return_value := pay_us_w2c_in_mmref2_format.rcw_blank_csv_record;
            end if;
        ELSIF p_record_name = 'RCO' then
        --{
            hr_utility.set_location( gv_package || '.format_w2c_record',150);
            if p_input_40 = 'FLAT' then
            --{
               hr_utility.trace('Formating RCO for mf file ');
               hr_utility.trace('RCO Exclude from output Flag '||
                            pay_us_w2c_in_mmref2_format.rco_exclude_flag);
               return_value := pay_us_w2c_in_mmref2_format.rco_mf_record;
               if pay_us_w2c_in_mmref2_format.rco_exclude_flag = 'Y'
               then
                  l_exclude_from_output_chk := TRUE;
               else
                  l_exclude_from_output_chk := FALSE;
               end if;
               hr_utility.set_location( gv_package || '.format_w2c_record',160);
            --}
            elsif p_input_40 = 'CSV' then
            --
            -- When RCW record is formatted for FLAT format, it also formats CSV and stores
            -- the value when required it would use the CSV format record for audit purpose
            --
                  hr_utility.trace('Formating RCO in CSV format for Audit file ');
                  hr_utility.set_location( gv_package || '.format_w2c_record',170);
                  return_value := pay_us_w2c_in_mmref2_format.rco_csv_record;
            elsif p_input_40 = 'BLANK' then
            --
            -- When RCW record is formatted for FLAT format, it also formats
            -- Blank CSV of RCW for audit purpose only. The blank RCW would
            -- be used for reporting Error on RCO.
            --
                  hr_utility.trace('Formating BLANK RCO in CSV format for Audit file ');
                  hr_utility.set_location( gv_package || '.format_w2c_record',180);
                  return_value := pay_us_w2c_in_mmref2_format.rco_blank_csv_record;
                  ret_str_len := pay_us_w2c_in_mmref2_format.rco_number_of_correction;
                  hr_utility.trace('No of Correction on RCO record '|| to_char(ret_str_len));
            end if;
        --}
        END IF;  --p_record_name
--}
     END IF; --p_report_type
--}
   END IF; -- p_format
   return_value:=upper(return_value);
--
-- As formula function out parameter value can't exceed 200 characters
-- multiple out prameters are used to return a long varchar2
--
   hr_utility.set_location( gv_package || '.format_w2_record',190);
   main_return_string := substr(return_value,1,200);
   sp_out_1:=substr(return_value,201,200);
   sp_out_2:=substr(return_value,401,200);
   sp_out_3:=substr(return_value,601,200);
   sp_out_4:=substr(return_value,801,200);
   sp_out_5:=substr(return_value,1001,200);

   IF l_exclude_from_output_chk  THEN
      p_exclude_from_output := 'Y';
   ELSE
      p_exclude_from_output := 'N';
   END IF;
   hr_utility.set_location( gv_package || '.format_w2_record',200);
   hr_utility.trace('main_return_string = '||main_return_string);
   hr_utility.trace(' length of main_return_string = '||to_char(length(main_return_string)));
   hr_utility.trace('sp_out_1 = '||sp_out_1);
   hr_utility.trace(' length of sp_out_1 = '||to_char(length(sp_out_1)));
   hr_utility.trace('sp_out_2 = '||sp_out_2);
   hr_utility.trace(' length of sp_out_2 = '||to_char(length(sp_out_2)));
   hr_utility.trace('sp_out_3 = '||sp_out_3);
   hr_utility.trace(' length of sp_out_3 = '||to_char(length(sp_out_3)));
   hr_utility.trace('sp_out_4 = '||sp_out_4);
   hr_utility.trace(' length of sp_out_4 = '||to_char(length(sp_out_4)));
   hr_utility.trace('sp_out_5 = '||sp_out_5);
   hr_utility.trace(' length of sp_out_5 = '||to_char(length(sp_out_5)));
   hr_utility.trace('p_exclude_from_output = '||p_exclude_from_output);
   hr_utility.set_location( gv_package || '.format_w2_record',210);

   RETURN main_return_string;
END Format_W2C_Record;
-- End of formatting record for W2C reporting
--

/*NEW*/

/* ---------------------------------------------------------------
   Function Name : format_w2c_total_record
   Purpose       : This is a generalised function which can be used
                   in W-2c MAg Formula to format RCT and RCU recods
   Error checking

   Special Note  :

   parameters    :

-------------------------------------------------------------------- */

FUNCTION format_w2c_total_record(
                   p_effective_date        IN  varchar2,
                   p_report_type           IN  varchar2,
                   p_format                IN  varchar2,
                   p_report_qualifier      IN  varchar2,
                   p_record_name           IN  varchar2,
                   p_input_1               IN  varchar2,
                   p_input_2               IN  varchar2,
                   p_input_3               IN  varchar2,
                   p_input_4               IN  varchar2,
                   p_input_5               IN  varchar2,
                   p_output_1              OUT nocopy  varchar2,
                   p_output_2              OUT nocopy  varchar2,
                   p_output_3              OUT nocopy  varchar2,
                   p_output_4              OUT nocopy  varchar2,
                   p_output_5              OUT nocopy  varchar2,
                   p_output_6              OUT nocopy  varchar2,
                   p_output_7              OUT nocopy  varchar2,
                   p_output_8              OUT nocopy  varchar2,
                   p_output_9              OUT nocopy  varchar2,
                   p_output_10             OUT nocopy  varchar2,
                   p_output_11             OUT nocopy  varchar2,
                   p_output_12             OUT nocopy  varchar2,
                   p_output_13             OUT nocopy  varchar2,
                   p_output_14             OUT nocopy  varchar2,
                   p_output_15             OUT nocopy  varchar2,
                   p_output_16             OUT nocopy  varchar2,
                   p_output_17             OUT nocopy  varchar2,
                   p_output_18             OUT nocopy  varchar2,
                   p_output_19             OUT nocopy  varchar2,
                   p_output_20             OUT nocopy  varchar2,
                   p_output_21             OUT nocopy  varchar2,
                   p_output_22             OUT nocopy  varchar2,
                   p_output_23             OUT nocopy  varchar2,
                   p_output_24             OUT nocopy  varchar2,
                   p_output_25             OUT nocopy  varchar2,
                   p_output_26             OUT nocopy  varchar2,
                   p_output_27             OUT nocopy  varchar2,
                   p_output_28             OUT nocopy  varchar2,
                   p_output_29             OUT nocopy  varchar2,
                   p_output_30             OUT nocopy  varchar2,
                   p_output_31             OUT nocopy  varchar2,
                   p_output_32             OUT nocopy  varchar2,
                   p_output_33             OUT nocopy  varchar2,
                   p_output_34             OUT nocopy  varchar2,
                   p_output_35             OUT nocopy  varchar2,
                   p_output_36             OUT nocopy  varchar2,
                   p_output_37             OUT nocopy  varchar2,
                   p_output_38             OUT nocopy  varchar2,
                   p_output_39             OUT nocopy  varchar2,
                   p_output_40             OUT nocopy  varchar2,
                   p_output_41             OUT nocopy  varchar2,
                   p_output_42             OUT nocopy  varchar2,
                   p_output_43             OUT nocopy  varchar2,
                   p_output_44             OUT nocopy  varchar2,
                   p_output_45             OUT nocopy  varchar2,
                   p_output_46             OUT nocopy  varchar2,
                   p_output_51             OUT nocopy  varchar2, /* saurabh */
                   p_output_52             OUT nocopy  varchar2, /* saurabh */
                   p_output_53             OUT nocopy  varchar2, /* saurabh */
                   p_output_54             OUT nocopy  varchar2, /* saurabh */
                   p_validate              IN  varchar2,
                   p_exclude_from_output   OUT nocopy varchar2,
                   sp_out_1                OUT nocopy varchar2,
                   sp_out_2                OUT nocopy varchar2,
                   sp_out_3                OUT nocopy varchar2,
                   sp_out_4                OUT nocopy varchar2,
                   sp_out_5                OUT nocopy varchar2,
                   ret_str_len             OUT nocopy varchar2,
                   p_output_47             OUT nocopy  varchar2,
                   p_output_48             OUT nocopy  varchar2,
                   p_output_49             OUT nocopy  varchar2,
                   p_output_50             OUT nocopy  varchar2
                 ) RETURN VARCHAR2
IS

return_value               varchar2(32767);
l_exclude_from_output_chk  boolean;
main_return_string         varchar2(300);
ln_no_of_rcw_wages         number := 23;
ln_no_of_rco_wages         number := 8;
TYPE function_columns IS RECORD(
                                p_parameter_name  varchar2(100)
                               );
function_parameter_rec  function_columns;
TYPE input_parameter_record IS TABLE OF function_parameter_rec%TYPE
                               INDEX BY BINARY_INTEGER;
parameter_record input_parameter_record;
lb_exclude_from_output_chk  boolean    := FALSE;
lv_wage_value_in_cents      varchar2(100) := ' ';
BEGIN

  hr_utility.set_location( gv_package || '.format_w2c_total_record',10);
  hr_utility.trace(' p_report_qualifier  = '||p_report_qualifier);
  hr_utility.trace(' p_record_name  = '     ||p_record_name);

  IF p_format = 'MMREF2' THEN  -- p_format
--{
    IF (p_report_type = 'W2C') THEN
--{
      IF  p_record_name = 'RCT' THEN -- p_record_name
--{
          hr_utility.set_location( gv_package || '.format_w2c_total_record',20);
          parameter_record.delete;
          parameter_record(1).p_parameter_name := 'Wages,Tips And Other Compensation';
          parameter_record(2).p_parameter_name := 'Federal Income Tax Withheld';
          parameter_record(3).p_parameter_name := 'Social Security Wages';
          parameter_record(4).p_parameter_name := 'Social Security Tax Withheld';
          parameter_record(5).p_parameter_name := 'Medicare Wages And Tips';
          parameter_record(6).p_parameter_name := 'Medicare Tax Withheld';
          parameter_record(7).p_parameter_name := 'Social Security Tips';
          parameter_record(8).p_parameter_name := 'Advance Earned Income Credit';
          parameter_record(9).p_parameter_name := 'Dependent Care Benefits';
          parameter_record(10).p_parameter_name:= 'Deferred Comp Contr. to Sec 401(k)';
          parameter_record(11).p_parameter_name:= 'Deferred Comp Contr. to Sec 403(b)';
          parameter_record(12).p_parameter_name:= 'Deferred Comp Contr. to Sec 408(k)(6)';
          parameter_record(13).p_parameter_name:= 'Deferred Comp Contr. to Sec 457(b)';
          parameter_record(14).p_parameter_name:= 'Deferred Comp Contr. to Sec 501(c)';
          parameter_record(15).p_parameter_name:= 'Deferred Compensation Contribution';
          parameter_record(16).p_parameter_name:= 'Military Combat Pay';
          parameter_record(17).p_parameter_name:= 'Non-Qual. plan Sec 457';
          parameter_record(18).p_parameter_name:= 'Non-Qual. plan NOT Sec 457';
          parameter_record(19).p_parameter_name:= 'Employer cost of premiun';
          parameter_record(20).p_parameter_name:= 'Income from nonqualified stock option';
          parameter_record(21).p_parameter_name:= 'ER Contribution to HSA';
          parameter_record(22).p_parameter_name:= 'Nontaxable Combat Pay';
          parameter_record(23).p_parameter_name:= 'Nonqual 409A Deferral Amount';
          parameter_record(24).p_parameter_name:= 'Designated Roth Contr. to 401k Plan'; /* saurabh */
          parameter_record(25).p_parameter_name:= 'Designated Roth Contr. to 403b Plan'; /* saurabh */


          ln_no_of_rcw_wages := 25; /* saurabh */


          hr_utility.set_location( gv_package || '.format_w2c_total_record',30);

          FOR i IN 1..ln_no_of_rcw_wages
          LOOP
            if (NVL(pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_old,0) <>
                NVL(pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_new,0)) then
--{
               pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_identical_flag := 'N';

            /* Negative Value check For Originally Reported Value on RCT */
               lv_wage_value_in_cents :=
                 to_char(nvl(pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_old,0 ));

               hr_utility.set_location( gv_package || '.format_w2c_total_record',40);

               pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_old_formated :=
                  pay_us_reporting_utils_pkg.data_validation(
                         p_effective_date,
                         p_report_type,
                         p_format,
                         p_report_qualifier,
                         p_record_name,
                         'NEG_CHECK',
                         lv_wage_value_in_cents,
                         parameter_record(i).p_parameter_name||'(Old)',
                         p_input_1,
                         null,
                         p_validate,
                         p_exclude_from_output,
                         sp_out_1,
                         sp_out_2);

               IF p_exclude_from_output = 'Y' THEN
                  lb_exclude_from_output_chk := TRUE;
               END IF;

               hr_utility.trace(parameter_record(i).p_parameter_name||'(Old) = '
                    ||pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_old);

               hr_utility.trace('p_exclude_from_output = '||p_exclude_from_output);

               hr_utility.set_location( gv_package || '.format_w2c_total_record',50);
             /* Negative Value check For Corrected Value to be reported on RCT */

               lv_wage_value_in_cents :=
                 to_char(nvl(pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_new,0));

               pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_new_formated :=
               pay_us_reporting_utils_pkg.data_validation(
                         p_effective_date,
                         p_report_type,
                         p_format,
                         p_report_qualifier,
                         p_record_name,
                         'NEG_CHECK',
                         lv_wage_value_in_cents,
                         parameter_record(i).p_parameter_name||'(New)',
                         p_input_1,
                         null,
                         p_validate,
                         p_exclude_from_output,
                         sp_out_1,
                         sp_out_2);

               IF p_exclude_from_output = 'Y' THEN
                       lb_exclude_from_output_chk := TRUE;
               END IF;

               hr_utility.set_location( gv_package || '.format_w2c_total_record',60);
               hr_utility.trace(parameter_record(i).p_parameter_name||'(New) = '
                    ||pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_new);
               hr_utility.trace('p_exclude_from_output = '||p_exclude_from_output);

            /* Set output parameters when RCT Originally reported value and Corrected values
               are not identical */
            --{
               if i = 1 then
                  p_output_1  := nvl(pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_old,0);
                  p_output_21 := nvl(pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_new,0);
               elsif i = 2 then
                  p_output_2  := nvl(pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_old,0);
                  p_output_22 := nvl(pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_new,0);
               elsif i = 3 then
                  p_output_3  := nvl(pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_old,0);
                  p_output_23 := nvl(pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_new,0);
               elsif i = 4 then
                  p_output_4  := nvl(pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_old,0);
                  p_output_24 := nvl(pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_new,0);
               elsif i = 5 then
                  p_output_5  := nvl(pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_old,0);
                  p_output_25 := nvl(pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_new,0);
               elsif i = 6 then
                  p_output_6  := nvl(pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_old,0);
                  p_output_26 := nvl(pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_new,0);
               elsif i = 7 then
                  p_output_7  := nvl(pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_old,0);
                  p_output_27 := nvl(pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_new,0);
               elsif i = 8 then
                  p_output_8  := nvl(pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_old,0);
                  p_output_28 := nvl(pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_new,0);
               elsif i = 9 then
                  p_output_9  := nvl(pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_old,0);
                  p_output_29 := nvl(pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_new,0);
               elsif i = 10 then
                  p_output_10  := nvl(pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_old,0);
                  p_output_30 := nvl(pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_new,0);
               elsif i = 11 then
                  p_output_11  := nvl(pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_old,0);
                  p_output_31 := nvl(pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_new,0);
               elsif i = 12 then
                  p_output_12  := nvl(pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_old,0);
                  p_output_32 := nvl(pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_new,0);
               elsif i = 13 then
                  p_output_13  := nvl(pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_old,0);
                  p_output_33 := nvl(pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_new,0);
               elsif i = 14 then
                  p_output_14  := nvl(pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_old,0);
                  p_output_34 := nvl(pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_new,0);
               elsif i = 15 then
                  p_output_15  := nvl(pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_old,0);
                  p_output_35 := nvl(pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_new,0);
               elsif i = 16 then
                  p_output_16  := nvl(pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_old,0);
                  p_output_36 := nvl(pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_new,0);
               elsif i = 17 then
                  p_output_17  := nvl(pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_old,0);
                  p_output_37 := nvl(pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_new,0);
               elsif i = 18 then
                  p_output_18  := nvl(pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_old,0);
                  p_output_38 := nvl(pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_new,0);
               elsif i = 19 then
                  p_output_19  := nvl(pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_old,0);
                  p_output_39 := nvl(pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_new,0);
               elsif i = 20 then
                  p_output_20  := nvl(pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_old,0);
                  p_output_40 := nvl(pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_new,0);
               elsif i = 21 then
                  p_output_43 := nvl(pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_old,0);
                  p_output_44 := nvl(pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_new,0);
               elsif i = 22 then
                  p_output_47 := nvl(pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_old,0);
                  p_output_48 := nvl(pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_new,0);
               elsif i = 23 then
                  p_output_45 := nvl(pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_old,0);
                  p_output_46 := nvl(pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_new,0);
               elsif i = 24 then                                                                     /* saurabh */
                  p_output_51 := nvl(pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_old,0);
                  p_output_53 := nvl(pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_new,0);
               elsif i = 25 then                                                                     /* saurabh */
                  p_output_52 := nvl(pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_old,0);
                  p_output_54 := nvl(pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_new,0);
               end if;

               hr_utility.set_location( gv_package || '.format_w2c_total_record',70);
            --}
--}
            else
--{
               hr_utility.set_location( gv_package || '.format_w2c_total_record',80);

               pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_identical_flag := 'Y';
               pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_old_formated :=
                                   lpad(' ',15);
               pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_new_formated :=
                                   lpad(' ',15);
            /* Set output parameters as 0 when RCT Originally reported value and Corrected values
               are identical */
            --{
               if i = 1 then
                  p_output_1  := '0';
                  p_output_21 := '0';
               elsif i = 2 then
                  p_output_2  := '0';
                  p_output_22 := '0';
               elsif i = 3 then
                  p_output_3  := '0';
                  p_output_23 := '0';
               elsif i = 4 then
                  p_output_4  := '0';
                  p_output_24 := '0';
               elsif i = 5 then
                  p_output_5  := '0';
                  p_output_25 := '0';
               elsif i = 6 then
                  p_output_6  := '0';
                  p_output_26 := '0';
               elsif i = 7 then
                  p_output_7  := '0';
                  p_output_27 := '0';
               elsif i = 8 then
                  p_output_8  := '0';
                  p_output_28 := '0';
               elsif i = 9 then
                  p_output_9  := '0';
                  p_output_29 := '0';
               elsif i = 10 then
                  p_output_10  := '0';
                  p_output_30  := '0';
               elsif i = 11 then
                  p_output_11  := '0';
                  p_output_31  := '0';
               elsif i = 12 then
                  p_output_12  := '0';
                  p_output_32  := '0';
               elsif i = 13 then
                  p_output_13  := '0';
                  p_output_33 := '0';
               elsif i = 14 then
                  p_output_14  := '0';
                  p_output_34  := '0';
               elsif i = 15 then
                  p_output_15 := '0';
                  p_output_35 := '0';
               elsif i = 16 then
                  p_output_16  := '0';
                  p_output_36 := '0';
               elsif i = 17 then
                  p_output_17  := '0';
                  p_output_37  := '0';
               elsif i = 18 then
                  p_output_18  := '0';
                  p_output_38  := '0';
               elsif i = 19 then
                  p_output_19  := '0';
                  p_output_39 := '0';
               elsif i = 20 then
                  p_output_20  := '0';
                  p_output_40 := '0';
               elsif i = 21 then
                  p_output_43  := '0';
                  p_output_44 := '0';
               elsif i = 22 then
                  p_output_47  := '0';
                  p_output_48 := '0';
               elsif i = 23 then
                  p_output_45  := '0';
                  p_output_46 := '0';
               elsif i = 24 then             /* saurabh */
                  p_output_51  := '0';
                  p_output_53 := '0';
               elsif i = 25 then             /* saurabh */
                  p_output_52  := '0';
                  p_output_54 := '0';
               end if;

            --}
               hr_utility.set_location( gv_package || '.format_w2c_total_record',90);
--}
            end if;

          END LOOP;

          hr_utility.trace('p_output_47 '||p_output_47);
          hr_utility.trace('p_output_48 '||p_output_48);

          p_output_41 := lpad(NVL(pay_us_w2c_in_mmref2_format.number_of_valid_rcw_rct,0),7,'0');
          p_output_42 := lpad(NVL(pay_us_w2c_in_mmref2_format.number_of_error_rcw_rct,0),7,'0');

          hr_utility.set_location( gv_package || '.format_w2c_total_record',100);

          return_value :=
                pay_us_mmrf2_w2c_format_record.format_W2C_RCT_record(
                                                  p_effective_date,
                                                  p_report_type,
                                                  p_format,
                                                  p_report_qualifier,
                                                  p_record_name,
                                                  p_input_1,
                                                  p_input_2,
                                                  p_input_3,
                                                  p_input_4,
                                                  p_output_41,
                                                  p_validate,
                                                  p_exclude_from_output,
                                                  ret_str_len,
                                                  lb_exclude_from_output_chk
                                                 );

          hr_utility.set_location( gv_package || '.format_w2c_total_record',110);
-- End of Formating RCT Record
--
--}
        ELSIF p_record_name = 'RCU' THEN
--{
          hr_utility.set_location( gv_package || '.format_w2c_total_record',120);
          parameter_record.delete;
          ln_no_of_rco_wages := 8;
          parameter_record(1).p_parameter_name:= ' Allocated Tips';
          parameter_record(2).p_parameter_name:= 'Uncollected employee tax on tips';
          parameter_record(3).p_parameter_name:= 'medical savings a/c';
          parameter_record(4).p_parameter_name:= 'simple retirement a/c';
          parameter_record(5).p_parameter_name:= 'qualified adoption expenses';
          parameter_record(6).p_parameter_name:= 'Uncollected SS tax';
          parameter_record(7).p_parameter_name:= 'Uncollected medicaroe tax';
          parameter_record(8).p_parameter_name:= 'income under 409A';
--
--        Compare RCO Wage total for formatting RCU Total Wage Record
--
          hr_utility.set_location( gv_package || '.format_w2c_total_record',130);
          FOR i IN 1..ln_no_of_rco_wages
          LOOP
            if (NVL(pay_us_w2c_in_mmref2_format.ltr_rcu_info(i).rcu_wage_old,0) <>
                NVL(pay_us_w2c_in_mmref2_format.ltr_rcu_info(i).rcu_wage_new,0)) then
--{
               hr_utility.set_location( gv_package || '.format_w2c_total_record',140);
               pay_us_w2c_in_mmref2_format.ltr_rcu_info(i).rcu_identical_flag := 'N';

            /* Negative Value check For Originally Reported Value on RCT */
               lv_wage_value_in_cents :=
                 to_char(nvl(pay_us_w2c_in_mmref2_format.ltr_rcu_info(i).rcu_wage_old,0));
               pay_us_w2c_in_mmref2_format.ltr_rcu_info(i).rcu_wage_old_formated :=
               pay_us_reporting_utils_pkg.data_validation(
                         p_effective_date,
                         p_report_type,
                         p_format,
                         p_report_qualifier,
                         p_record_name,
                         'NEG_CHECK',
                         lv_wage_value_in_cents,
                         parameter_record(i).p_parameter_name||'(Old)',
                         p_input_1,
                         null,
                         p_validate,
                         p_exclude_from_output,
                         sp_out_1,
                         sp_out_2);
               IF p_exclude_from_output = 'Y' THEN
                  lb_exclude_from_output_chk := TRUE;
               END IF;
               hr_utility.set_location( gv_package || '.format_w2c_total_record',150);
               hr_utility.trace(parameter_record(i).p_parameter_name||'(Old) = '
                    ||lv_wage_value_in_cents);
               hr_utility.trace('p_exclude_from_output = '||p_exclude_from_output);

             /* Negative Value check For Corrected Value to be reported on RCU */
               hr_utility.set_location( gv_package || '.format_w2c_total_record',160);
               lv_wage_value_in_cents :=
                 to_char(nvl(pay_us_w2c_in_mmref2_format.ltr_rcu_info(i).rcu_wage_new,0));
               pay_us_w2c_in_mmref2_format.ltr_rcu_info(i).rcu_wage_new_formated :=
               pay_us_reporting_utils_pkg.data_validation(
                         p_effective_date,
                         p_report_type,
                         p_format,
                         p_report_qualifier,
                         p_record_name,
                         'NEG_CHECK',
                         lv_wage_value_in_cents,
                         parameter_record(i).p_parameter_name||'(New)',
                         p_input_1,
                         null,
                         p_validate,
                         p_exclude_from_output,
                         sp_out_1,
                         sp_out_2);
               IF p_exclude_from_output = 'Y' THEN
                       lb_exclude_from_output_chk := TRUE;
               END IF;
               hr_utility.set_location( gv_package || '.format_w2c_total_record',170);
               hr_utility.trace(parameter_record(i).p_parameter_name||'(New) = '
                    ||lv_wage_value_in_cents);
               hr_utility.trace('p_exclude_from_output = '||p_exclude_from_output);
            /* Set output parameters when RCT Originally reported value and Corrected values
               are not identical */
            --{
               if i = 1 then
                  p_output_1  := nvl(pay_us_w2c_in_mmref2_format.ltr_rcu_info(i).rcu_wage_old,0);
                  p_output_21 := nvl(pay_us_w2c_in_mmref2_format.ltr_rcu_info(i).rcu_wage_new,0);
               elsif i = 2 then
                  p_output_2  := nvl(pay_us_w2c_in_mmref2_format.ltr_rcu_info(i).rcu_wage_old,0);
                  p_output_22 := nvl(pay_us_w2c_in_mmref2_format.ltr_rcu_info(i).rcu_wage_new,0);
               elsif i = 3 then
                  p_output_3  := nvl(pay_us_w2c_in_mmref2_format.ltr_rcu_info(i).rcu_wage_old,0);
                  p_output_23 := nvl(pay_us_w2c_in_mmref2_format.ltr_rcu_info(i).rcu_wage_new,0);
               elsif i = 4 then
                  p_output_4  := nvl(pay_us_w2c_in_mmref2_format.ltr_rcu_info(i).rcu_wage_old,0);
                  p_output_24 := nvl(pay_us_w2c_in_mmref2_format.ltr_rcu_info(i).rcu_wage_new,0);
               elsif i = 5 then
                  p_output_5  := nvl(pay_us_w2c_in_mmref2_format.ltr_rcu_info(i).rcu_wage_old,0);
                  p_output_25 := nvl(pay_us_w2c_in_mmref2_format.ltr_rcu_info(i).rcu_wage_new,0);
               elsif i = 6 then
                  p_output_6  := nvl(pay_us_w2c_in_mmref2_format.ltr_rcu_info(i).rcu_wage_old,0);
                  p_output_26 := nvl(pay_us_w2c_in_mmref2_format.ltr_rcu_info(i).rcu_wage_new,0);
               elsif i = 7 then
                  p_output_7  := nvl(pay_us_w2c_in_mmref2_format.ltr_rcu_info(i).rcu_wage_old,0);
                  p_output_27 := nvl(pay_us_w2c_in_mmref2_format.ltr_rcu_info(i).rcu_wage_new,0);
               elsif i = 8 then
                  p_output_8  := nvl(pay_us_w2c_in_mmref2_format.ltr_rcu_info(i).rcu_wage_old,0);
                  p_output_28 := nvl(pay_us_w2c_in_mmref2_format.ltr_rcu_info(i).rcu_wage_new,0);
               end if;
               hr_utility.trace('p_output_8 '||p_output_8);
               hr_utility.trace('p_output_28 '||p_output_28);

               hr_utility.set_location( gv_package || '.format_w2c_total_record',180);
            --}
--}
            else
--{
               hr_utility.set_location( gv_package || '.format_w2c_total_record',190);
               pay_us_w2c_in_mmref2_format.ltr_rcu_info(i).rcu_identical_flag := 'Y';
               pay_us_w2c_in_mmref2_format.ltr_rcu_info(i).rcu_wage_old_formated :=
                                   lpad(' ',15);
               pay_us_w2c_in_mmref2_format.ltr_rcu_info(i).rcu_wage_new_formated :=
                                   lpad(' ',15);
               if i = 1 then
                  p_output_1  := '0';
                  p_output_21 := '0';
               elsif i = 2 then
                  p_output_2  := '0';
                  p_output_22 := '0';
               elsif i = 3 then
                  p_output_3  :='0';
                  p_output_23 := '0';
               elsif i = 4 then
                  p_output_4  := '0';
                  p_output_24 := '0';
               elsif i = 5 then
                  p_output_5  := '0';
                  p_output_25 := '0';
               elsif i = 6 then
                  p_output_6  := '0';
                  p_output_26 := '0';
               elsif i = 7 then
                  p_output_7  := '0';
                  p_output_27 := '0';
               elsif i = 8 then
                  p_output_8  := '0';
                  p_output_28 := '0';
               end if;
--}
            end if;
          END LOOP;
          hr_utility.set_location( gv_package || '.format_w2c_total_record',200);
          p_output_41 := lpad(NVL(pay_us_w2c_in_mmref2_format.number_of_valid_rco_rcu,0),7,'0');
          p_output_42 := lpad(NVL(pay_us_w2c_in_mmref2_format.number_of_error_rco_rcu,0),7,'0');
          return_value :=
                pay_us_mmrf2_w2c_format_record.format_W2C_RCU_record(
                                                  p_effective_date,
                                                  p_report_type,
                                                  p_format,
                                                  p_report_qualifier,
                                                  p_record_name,
                                                  p_input_1,
                                                  p_input_2,
                                                  p_input_3,
                                                  p_input_4,
                                                  p_output_41,
                                                  p_validate,
                                                  p_exclude_from_output,
                                                  ret_str_len,
                                                  lb_exclude_from_output_chk
                                                 );
          hr_utility.set_location( gv_package || '.format_w2c_total_record',210);
--}
        END IF;  --p_record_name
--}
     END IF; --p_report_type
--}
   END IF; -- p_format
   return_value:=upper(return_value);
--
-- As formula function out parameter value can't exceed 200 characters
-- multiple out prameters are used to return a long varchar2
--
   main_return_string := substr(return_value,1,200);
   sp_out_1:=substr(return_value,201,200);
   sp_out_2:=substr(return_value,401,200);
   sp_out_3:=substr(return_value,601,200);
   sp_out_4:=substr(return_value,801,200);
   sp_out_5:=substr(return_value,1001,200);

   IF l_exclude_from_output_chk  THEN
      p_exclude_from_output := 'Y';
   ELSE
      p_exclude_from_output := 'N';
   END IF;
   hr_utility.trace('main_return_string = '||main_return_string);
   hr_utility.trace(' length of main_return_string = '||to_char(length(main_return_string)));
   hr_utility.trace('sp_out_1 = '||sp_out_1);
   hr_utility.trace(' length of sp_out_1 = '||to_char(length(sp_out_1)));
   hr_utility.trace('sp_out_2 = '||sp_out_2);
   hr_utility.trace(' length of sp_out_2 = '||to_char(length(sp_out_2)));
   hr_utility.trace('sp_out_3 = '||sp_out_3);
   hr_utility.trace(' length of sp_out_3 = '||to_char(length(sp_out_3)));
   hr_utility.trace('sp_out_4 = '||sp_out_4);
   hr_utility.trace(' length of sp_out_4 = '||to_char(length(sp_out_4)));
   hr_utility.trace('sp_out_5 = '||sp_out_5);
   hr_utility.trace(' length of sp_out_5 = '||to_char(length(sp_out_5)));
   hr_utility.trace('p_exclude_from_output = '||p_exclude_from_output);
   hr_utility.set_location( gv_package || '.format_w2c_total_record',220);

   RETURN main_return_string;
END Format_W2C_total_Record;
/* NEW*/

--
-- This function is used to initialize all the GRE level data used
-- for Reporting in RCT and RCU records. This function is called
-- when RCE record is being formatted
-- There is no parameter for this function
Function Initialize_GRE_Level_total return number
IS
ln_no_of_rcw_wages   number := 25;  /* saurabh */
ln_no_of_rco_wages   number := 8;
BEGIN
   hr_utility.set_location( gv_package || '.Initialize_GRE_Level_total',10);
   hr_utility.trace('Entered in pay_us_w2c_in_mmref2_format.Initialize_GRE_Level_total');
   hr_utility.trace('Initializing GRE Level Totals');
   if pay_us_w2c_in_mmref2_format.number_of_valid_rcw_rct > 0 then
      pay_us_w2c_in_mmref2_format.number_of_valid_rcw_rcf :=
            pay_us_w2c_in_mmref2_format.number_of_valid_rcw_rcf +
            pay_us_w2c_in_mmref2_format.number_of_valid_rcw_rct ;
   end if;

   -- Number of Valid RCW Record to be reported in RCT
   pay_us_w2c_in_mmref2_format.number_of_valid_rcw_rct := 0; --3;

   if pay_us_w2c_in_mmref2_format.number_of_error_rcw_rct > 0 then
      pay_us_w2c_in_mmref2_format.number_of_error_rcw_rcf :=
            pay_us_w2c_in_mmref2_format.number_of_error_rcw_rcf +
            pay_us_w2c_in_mmref2_format.number_of_error_rcw_rct ;
   end if;
   -- Number of Error RCW Record to be reported in RCT
   pay_us_w2c_in_mmref2_format.number_of_error_rcw_rct := 0;

   if pay_us_w2c_in_mmref2_format.number_of_valid_rco_rcu > 0 then
      pay_us_w2c_in_mmref2_format.number_of_valid_rco_rcf :=
            pay_us_w2c_in_mmref2_format.number_of_valid_rco_rcf +
            pay_us_w2c_in_mmref2_format.number_of_valid_rco_rcu ;
   end if;
   -- Number of Valid RCO Record to be reported in RCU
   pay_us_w2c_in_mmref2_format.number_of_valid_rco_rcu :=0; -- 3;

   if pay_us_w2c_in_mmref2_format.number_of_error_rco_rcu > 0 then
      pay_us_w2c_in_mmref2_format.number_of_error_rco_rcf :=
            pay_us_w2c_in_mmref2_format.number_of_error_rco_rcf +
            pay_us_w2c_in_mmref2_format.number_of_error_rco_rcu ;
   end if;
   -- Number of Error RCO Record to be reported in RCU
   pay_us_w2c_in_mmref2_format.number_of_error_rco_rcu := 0;

   -- Initialize all the PL/SQL table defined for RCT Wages
   ln_no_of_rcw_wages := 25;  /* saurabh */
   pay_us_w2c_in_mmref2_format.ltr_rct_info.delete;
   FOR i IN 1..ln_no_of_rcw_wages
   LOOP
       pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_old := 0; --100000;
       pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_new := 0; --200000;
       pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_old_formated  := ' ';
       pay_us_w2c_in_mmref2_format.ltr_rct_info(i).rct_wage_new_formated  := ' ';
   END LOOP;
   -- Initialize all the PL/SQL table defined for RCU Wages
   hr_utility.set_location( gv_package || '.Initialize_GRE_Level_total',20);
   pay_us_w2c_in_mmref2_format.ltr_rcu_info.delete;
   ln_no_of_rco_wages := 8;

   FOR i IN 1..ln_no_of_rco_wages
   LOOP
       pay_us_w2c_in_mmref2_format.ltr_rcu_info(i).rcu_wage_old := 0; --100000;
       pay_us_w2c_in_mmref2_format.ltr_rcu_info(i).rcu_wage_new := 0; --200000;
       pay_us_w2c_in_mmref2_format.ltr_rcu_info(i).rcu_wage_old_formated  := ' ';
       pay_us_w2c_in_mmref2_format.ltr_rcu_info(i).rcu_wage_new_formated  := ' ';
   END LOOP;
   hr_utility.set_location( gv_package || '.Initialize_GRE_Level_total',30);
   hr_utility.trace('Leaving pay_us_w2c_in_mmref2_format.Initialize_GRE_Level_total');
   return(0);
EXCEPTION
when others then
    return(1);
END Initialize_GRE_Level_total;


--
-- This procedure would be used for Fetching the archived values of RCW or RCO record
--
PROCEDURE  GET_ARCHIVED_VALUES ( p_action_type            varchar2 -- O Originally Reported,  C Corrected
                                ,p_record_type            varchar2 -- RCW, RCO
                                ,p_assignment_action_id   number
                                ,p_tax_unit_id            number)
IS
i                           number := 0;
j                           number := 0;
ln_gross_wages              number := 0;
ln_non_qual_not457          number := 0;
lv_statutory_employee       varchar2(200) :='';
ln_401k_contribution        number := 0;
ln_403b_contribution        number := 0;
ln_408k_contribution        number := 0;
ln_457_contribution         number := 0;
ln_501c_contribution        number := 0;
ln_total_contribution       number := 0;
ln_nonqual_457              number := 0;
ln_nonqual_not457           number := 0;
ln_nonqual_plan             number := 0;
ln_3rd_party                number := 0;
ln_no_of_rcw_wages          number := 25;  /* saurabh */
ln_no_of_rco_wages          number := 8;
ln_roth_401k_contribution   number := 0; /* saurabh */
ln_roth_403b_contribution   number := 0; /* saurabh */
BEGIN
--
-- In PL/SQL table 1st record would be Originally reported arhived value for an Assignment_Action_Id
-- and 2nd record would be Corrected values
   hr_utility.set_location( gv_package || '.GET_ARCHIVED_VALUES',10);
   if p_action_type = 'O'
   then
       i := 1;
   elsif p_action_type = 'C' then
       i := 2;
   end if;

   if p_record_type = 'RCW' then
--{
      hr_utility.set_location( gv_package || '.GET_ARCHIVED_VALUES',20);
      pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).SSN                       := '';
      pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).first_name                := '';
      pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).middle_name               := '';
      pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).last_name                 := '';
      pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).action_information1       := 0;   -- wages, tips and other compensation
      pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).action_information2       := 0;    -- FIT withheld
      pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).action_information3       := 0;    -- SS Wages
      pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).action_information4       := 0;    -- SS Tax withheld
      pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).action_information5       := 0;    -- Medicare Wages/Tips
      pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).action_information6       := 0;    -- Medicare Tax withheld
      pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).action_information7       := 0;    -- Social Security Tips
      pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).action_information8       := 0;    -- Advanced EIC
      pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).action_information9       := 0;    -- Dependent Care benefits
      pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).action_information10      := 0;    -- deferred compensation contributions to section 401(K)
      pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).action_information11      := 0;    -- deferred compensation contributions to section 403(b)
      pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).action_information12      := 0;    -- deferred compensation contributions to section 408(K)(6)
      pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).action_information13      := 0;    -- deferred compensation contributions to section 457(b)
      pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).action_information14      := 0;    -- deferred compensation contributions to section 501(c)(18)(D)
      pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).action_information15      := 0;    -- Deferred compensation contributions
      pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).action_information16      := 0;    -- Military employees basic quarters, subsistence and combat pay
      pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).action_information17      := 0;    -- nonqualified plan section 457 distributions or contributions
      pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).action_information18      := 0;    -- nonqualified plan not section 457 distributions or contributions
      pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).action_information19      := 0;    -- employer cost of premiums for GTL over $50000
      pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).action_information20      := 0;    -- income from the exercise of nonstatutory stock options
      pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).action_information21      := 0;    -- ER contribution to Health Savings Account
      pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).action_information22      := 0;    -- Nontax Combat Pay
      pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).action_information23      := 0;    -- 409A Deferrals
      pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).action_information24      := 0;    -- deferred compensation contributions to section roth 401(K)  /* saurabh */
      pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).action_information25      := 0;    -- deferred compensation contributions to section roth 403(b)  /* saurabh */


      pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).statutory_emp_indicator   := '';
      pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).retirement_plan_indicator := '';
      pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).sick_pay_indicator        := '';
      hr_utility.set_location( gv_package || '.GET_ARCHIVED_VALUES',30);
      pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).SSN         :=
         hr_us_w2_rep.get_per_item(p_assignment_action_id,'A_PER_NATIONAL_IDENTIFIER') ;
      pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).first_name  :=
         hr_us_w2_rep.get_per_item(p_assignment_action_id,'A_PER_FIRST_NAME') ;
      pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).middle_name :=
         hr_us_w2_rep.get_per_item(p_assignment_action_id, 'A_PER_MIDDLE_NAMES') ;
      pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).last_name   :=
         hr_us_w2_rep.get_per_item(p_assignment_action_id, 'A_PER_LAST_NAME') ;

-- wages, tips and other compensation
      ln_gross_wages := 0;
      ln_gross_wages := hr_us_w2_rep.get_w2_arch_bal( p_assignment_action_id
                                                  ,'A_REGULAR_EARNINGS_PER_GRE_YTD'
                                                  ,p_tax_unit_id
                                                  ,'00-000-0000'
                                                  , 0) +
                        hr_us_w2_rep.get_w2_arch_bal( p_assignment_action_id,
                                                  'A_SUPPLEMENTAL_EARNINGS_FOR_NWFIT_SUBJECT_TO_TAX_PER_GRE_YTD'
                                                  ,p_tax_unit_id
                                                  ,'00-000-0000'
                                                  ,0) +
                        hr_us_w2_rep.get_w2_arch_bal( p_assignment_action_id,
                                                  'A_SUPPLEMENTAL_EARNINGS_FOR_FIT_SUBJECT_TO_TAX_PER_GRE_YTD'
                                                  ,p_tax_unit_id
                                                  ,'00-000-0000'
                                                  ,0) -
                        hr_us_w2_rep.get_w2_arch_bal(p_assignment_action_id
                                                  ,'A_PRE_TAX_DEDUCTIONS_PER_GRE_YTD'
                                                  ,p_tax_unit_id
                                                  ,'00-000-0000'
                                                  ,0)+
                        hr_us_w2_rep.get_w2_arch_bal( p_assignment_action_id,
                                                  'A_FIT_NON_W2_PRE_TAX_DEDNS_PER_GRE_YTD'
                                                  ,p_tax_unit_id
                                                  ,'00-000-0000'
                                                  ,0)+
                        hr_us_w2_rep.get_w2_arch_bal( p_assignment_action_id,
                                                  'A_PRE_TAX_DEDUCTIONS_FOR_FIT_SUBJECT_TO_TAX_PER_GRE_YTD'
                                                  ,p_tax_unit_id
                                                  ,'00-000-0000'
                                                  ,0);
      pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).action_information1  := ln_gross_wages;

      hr_utility.set_location( gv_package || '.GET_ARCHIVED_VALUES',40);
-- FIT withheld
      pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).action_information2  :=
         hr_us_w2_rep.get_w2_arch_bal(p_assignment_action_id
                                  ,'A_FIT_WITHHELD_PER_GRE_YTD'
                                  ,p_tax_unit_id
                                  ,'00-000-0000'
                                  ,0);
-- SS Wages
      pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).action_information3  :=
         hr_us_w2_rep.get_w2_arch_bal(p_assignment_action_id
                                  ,'A_SS_EE_TAXABLE_PER_GRE_YTD'
                                  ,p_tax_unit_id
                                  ,'00-000-0000'
                                  ,0);
-- SS Tax withheld
      pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).action_information4  :=
         hr_us_w2_rep.get_w2_arch_bal(p_assignment_action_id
                                  ,'A_SS_EE_WITHHELD_PER_GRE_YTD'
                                  ,p_tax_unit_id
                                  ,'00-000-0000'
                                  ,0);
-- Medicare Wages/Tips
      pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).action_information5  :=
         hr_us_w2_rep.get_w2_arch_bal(p_assignment_action_id
                                  ,'A_MEDICARE_EE_TAXABLE_PER_GRE_YTD'
                                  ,p_tax_unit_id
                                  ,'00-000-0000'
                                  ,0);
-- Medicare Tax withheld
      pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).action_information6  :=
         hr_us_w2_rep.get_w2_arch_bal(p_assignment_action_id
                                  ,'A_MEDICARE_EE_WITHHELD_PER_GRE_YTD'
                                  ,p_tax_unit_id
                                  ,'00-000-0000'
                                  ,0);
-- Social Security Tips
      pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).action_information7  :=
         hr_us_w2_rep.get_w2_arch_bal(p_assignment_action_id
                                  ,'A_W2_BOX_7_PER_GRE_YTD'
                                  ,p_tax_unit_id
                                  ,'00-000-0000'
                                  ,0);
-- Advanced EIC
      pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).action_information8  :=
         hr_us_w2_rep.get_w2_arch_bal(p_assignment_action_id
                                  ,'A_EIC_ADVANCE_PER_GRE_YTD'
                                  ,p_tax_unit_id
                                  ,'00-000-0000'
                                  ,0);
-- Dependent Care benefits
      pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).action_information9  :=
         hr_us_w2_rep.get_w2_arch_bal(p_assignment_action_id
                                  ,'A_W2_DEPENDENT_CARE_PER_GRE_YTD'
                                  ,p_tax_unit_id
                                  ,'00-000-0000'
                                  ,0);
-- deferred compensation contributions to section 401(K)
      ln_401k_contribution :=
         hr_us_w2_rep.get_w2_arch_bal(p_assignment_action_id
                                  ,'A_W2_401K_PER_GRE_YTD'
                                  ,p_tax_unit_id
                                  ,'00-000-0000'
                                  ,0);
      pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).action_information10 := ln_401k_contribution;
-- deferred compensation contributions to section 403(b)
      ln_403b_contribution :=
         hr_us_w2_rep.get_w2_arch_bal(p_assignment_action_id
                                  ,'A_W2_403B_PER_GRE_YTD'
                                  ,p_tax_unit_id
                                  ,'00-000-0000'
                                  ,0);

-- 'Designated Roth Contr. to 401k Plan'           /* saurabh */
      ln_roth_401k_contribution :=
         hr_us_w2_rep.get_w2_arch_bal(p_assignment_action_id
                                  ,'A_W2_ROTH_401K_PER_GRE_YTD'
                                  ,p_tax_unit_id
                                  ,'00-000-0000'
                                  ,0);
      pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).action_information24 := ln_roth_401k_contribution;
-- 'Designated Roth Contr. to 403b Plan'       /* saurabh */
      ln_roth_403b_contribution :=
         hr_us_w2_rep.get_w2_arch_bal(p_assignment_action_id
                                  ,'A_W2_ROTH_403B_PER_GRE_YTD'
                                  ,p_tax_unit_id
                                  ,'00-000-0000'
                                  ,0);

      pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).action_information25 := ln_roth_403b_contribution;
-- deferred compensation contributions to section 408(K)(6)
      ln_408k_contribution :=
         hr_us_w2_rep.get_w2_arch_bal(p_assignment_action_id
                                  ,'A_W2_408K_PER_GRE_YTD'
                                  ,p_tax_unit_id
                                  ,'00-000-0000'
                                  ,0);
      pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).action_information12 := ln_408k_contribution;
-- deferred compensation contributions to section 457(b)
      ln_457_contribution :=
         hr_us_w2_rep.get_w2_arch_bal(p_assignment_action_id
                                  ,'A_W2_457_PER_GRE_YTD'
                                  ,p_tax_unit_id
                                  ,'00-000-0000'
                                  ,0);
      pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).action_information13 := ln_457_contribution;
-- deferred compensation contributions to section 501(c)(18)(D)
      ln_501c_contribution :=
         hr_us_w2_rep.get_w2_arch_bal(p_assignment_action_id
                                  ,'A_W2_501C_PER_GRE_YTD'
                                  ,p_tax_unit_id
                                  ,'00-000-0000'
                                  ,0);
      pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).action_information14 :=
         ln_501c_contribution;
      hr_utility.set_location( gv_package || '.GET_ARCHIVED_VALUES',50);
-- Deferred compensation contributions
-- This need to be clarified
      ln_total_contribution  := ln_401k_contribution +
                                ln_403b_contribution +
                                ln_408k_contribution +
                                ln_457_contribution  +
                                ln_501c_contribution;
      pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).action_information15 :=
         ln_total_contribution;
--
-- Military employees basic quarters, subsistence and combat pay
-- This field is not report in FED W2 That is why field is initialized with 0
--
      pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).action_information16 := 0;
-- nonqualified plan section 457 distributions or contributions
      ln_nonqual_457 := hr_us_w2_rep.get_w2_arch_bal(p_assignment_action_id
                                  ,'A_W2_NONQUAL_457_PER_GRE_YTD'
                                  ,p_tax_unit_id
                                  ,'00-000-0000'
                                  ,0);
      pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).action_information17 :=
              ln_nonqual_457;

-- nonqualified plan not section 457 distributions or contributions
     ln_nonqual_plan :=
        hr_us_w2_rep.get_w2_arch_bal(p_assignment_action_id
                                  ,'A_W2_NONQUAL_PLAN_PER_GRE_YTD'
                                  ,p_tax_unit_id
                                  ,'00-000-0000'
                                  ,0);
     if ln_nonqual_plan > ln_nonqual_457 then
        ln_non_qual_not457 := ln_nonqual_plan - ln_nonqual_457;
     end if;
     pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).action_information18 :=
        ln_non_qual_not457;
-- employer cost of premiums for GTL over $50000
     pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).action_information19 :=
        hr_us_w2_rep.get_w2_arch_bal(p_assignment_action_id
                                 ,'A_W2_GROUP_TERM_LIFE_PER_GRE_YTD'
                                 ,p_tax_unit_id
                                 ,'00-000-0000'
                                 ,0);
-- income from the exercise of nonstatutory stock options
      pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).action_information20      :=
         hr_us_w2_rep.get_w2_arch_bal(p_assignment_action_id
                                 ,'A_W2_NONQUAL_STOCK_PER_GRE_YTD'
                                 ,p_tax_unit_id
                                 ,'00-000-0000'
                                 ,0);

-- ER contribution to Health Savings Account
      pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).action_information21      :=
         hr_us_w2_rep.get_w2_arch_bal(p_assignment_action_id
                                 ,'A_W2_HSA_PER_GRE_YTD'
                                 ,p_tax_unit_id
                                 ,'00-000-0000'
                                 ,0);
-- Non Combat Pay , for bug 4398606
      hr_utility.trace(' Getting  Non combat pay ' );
      pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).action_information22      :=
         hr_us_w2_rep.get_w2_arch_bal(p_assignment_action_id
                                 ,'A_W2_NONTAX_COMBAT_PER_GRE_YTD'
                                 ,p_tax_unit_id
                                 ,'00-000-0000'
                                 ,0);
      hr_utility.trace('Nontax Combat ' ||  pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).action_information22);


-- 409A Deferrals , for bug 4398606
      hr_utility.trace(' Getting  NonQual Def Comp ' );
      pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).action_information23      :=
         hr_us_w2_rep.get_w2_arch_bal(p_assignment_action_id
                                 ,'A_W2_NONQUAL_DEF_COMP_PER_GRE_YTD'
                                 ,p_tax_unit_id
                                 ,'00-000-0000'
                                 ,0);
      hr_utility.trace('NonQual Def Comp ' ||  pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).action_information23);


      hr_utility.set_location( gv_package || '.GET_ARCHIVED_VALUES',60);
-- Statutory Employee Indicator
      lv_statutory_employee :=
         hr_us_w2_rep.get_per_item(p_assignment_action_id,'A_W2_ASG_STATUTORY_EMPLOYEE');
      if lv_statutory_employee = 'Y' then
         pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).statutory_emp_indicator := '1';
      else
         pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).statutory_emp_indicator := '0';
      end if;
      hr_utility.set_location( gv_package || '.GET_ARCHIVED_VALUES',70);
--
-- Retirement Plan Indicator
-- If any of the contribution is > 0 then retirement plan indicator is set to 1
--    otherwise 0
--
      if ((ln_401k_contribution > 0) OR
          (ln_403b_contribution > 0) OR
          (ln_408k_contribution > 0) OR
          (ln_501c_contribution > 0))
      then
          pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).retirement_plan_indicator := '1';
      else
         pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).retirement_plan_indicator := '0';
      end if;
-- Third Party Sick Pay Indicator
      ln_3rd_party :=
         hr_us_w2_rep.get_w2_arch_bal(p_assignment_action_id
                                  ,'A_W2_TP_SICK_PAY_PER_GRE_YTD'
                                  ,p_tax_unit_id
                                  ,'00-000-0000'
                                  ,0);
/* We should be using the Wages for Third Party Sick Pay Indicator because
   an employee can have wages and be marked for exempt ie no taxes withheld.
   If there are wages we should be reporting the employee */
/*
         hr_us_w2_rep.get_w2_arch_bal(p_assignment_action_id
                                  ,'A_FIT_3RD_PARTY_PER_GRE_YTD'
                                  ,p_tax_unit_id
                                  ,'00-000-0000'
                                  ,0);
*/
      if ln_3rd_party > 0 then
         pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).sick_pay_indicator  := '1';
      else
         pay_us_w2c_in_mmref2_format.ltr_rcw_info(i).sick_pay_indicator  := '0';
      end if;
      hr_utility.set_location(gv_package || '.GET_ARCHIVED_VALUES',80);
--}
 ELSIF p_record_type = 'RCO' then
--{
      hr_utility.set_location(gv_package || '.GET_ARCHIVED_VALUES',100);
      pay_us_w2c_in_mmref2_format.ltr_rco_info(i).action_information1       := 0;   -- allocated tips
      pay_us_w2c_in_mmref2_format.ltr_rco_info(i).action_information2       := 0;    -- uncollected employee tax on tips
      pay_us_w2c_in_mmref2_format.ltr_rco_info(i).action_information3       := 0;    -- Medical Savings Account
      pay_us_w2c_in_mmref2_format.ltr_rco_info(i).action_information4       := 0;    -- Simple Retirement Account
      pay_us_w2c_in_mmref2_format.ltr_rco_info(i).action_information5       := 0;    -- Qualified adoption expenses
      pay_us_w2c_in_mmref2_format.ltr_rco_info(i).action_information6       := 0;    -- uncollected social security or RRTA tax on GTL insurance over $50000
      pay_us_w2c_in_mmref2_format.ltr_rco_info(i).action_information7       := 0;    -- uncollected medicare tax on GTL insurance over $50,000
      pay_us_w2c_in_mmref2_format.ltr_rco_info(i).action_information8       := 0;    -- uncollected medicare tax on GTL insurance over $50,000
      hr_utility.set_location(gv_package || '.GET_ARCHIVED_VALUES',105);

   -- allocated tips
      pay_us_w2c_in_mmref2_format.ltr_rco_info(i).action_information1  :=
         hr_us_w2_rep.get_w2_arch_bal(p_assignment_action_id
                                  ,'A_W2_BOX_8_PER_GRE_YTD'
                                  ,p_tax_unit_id
                                  ,'00-000-0000'
                                  ,0);
      hr_utility.set_location(gv_package || '.GET_ARCHIVED_VALUES',110);
   -- uncollected employee tax on tips
      pay_us_w2c_in_mmref2_format.ltr_rco_info(i).action_information2  :=
         hr_us_w2_rep.get_w2_arch_bal(p_assignment_action_id
                                  ,'A_W2_UNCOLL_SS_TAX_TIPS_PER_GRE_YTD'
                                  ,p_tax_unit_id
                                  ,'00-000-0000'
                                  ,0) +
         hr_us_w2_rep.get_w2_arch_bal(p_assignment_action_id
                                  ,'A_W2_UNCOLL_MED_TIPS_PER_GRE_YTD'
                                  ,p_tax_unit_id
                                  ,'00-000-0000'
                                  ,0);
      hr_utility.set_location(gv_package || '.GET_ARCHIVED_VALUES',120);
   -- Medical Savings Account
      pay_us_w2c_in_mmref2_format.ltr_rco_info(i).action_information3  :=
         hr_us_w2_rep.get_w2_arch_bal(p_assignment_action_id
                                  ,'A_W2_MSA_PER_GRE_YTD'
                                  ,p_tax_unit_id
                                  ,'00-000-0000'
                                  ,0);
      hr_utility.set_location(gv_package || '.GET_ARCHIVED_VALUES',130);
   -- Simple Retirement Account
      pay_us_w2c_in_mmref2_format.ltr_rco_info(i).action_information4  :=
         hr_us_w2_rep.get_w2_arch_bal(p_assignment_action_id
                                  ,'A_W2_408P_PER_GRE_YTD'
                                  ,p_tax_unit_id
                                  ,'00-000-0000'
                                  ,0);
      hr_utility.set_location(gv_package || '.GET_ARCHIVED_VALUES',140);
   -- Qualified adoption expenses
      pay_us_w2c_in_mmref2_format.ltr_rco_info(i).action_information5  :=
         hr_us_w2_rep.get_w2_arch_bal(p_assignment_action_id
                                  ,'A_W2_ADOPTION_PER_GRE_YTD'
                                  ,p_tax_unit_id
                                  ,'00-000-0000'
                                  ,0);
      hr_utility.set_location(gv_package || '.GET_ARCHIVED_VALUES',150);
   -- uncollected social security or RRTA tax on GTL insurance over $50000
      pay_us_w2c_in_mmref2_format.ltr_rco_info(i).action_information6  :=
         hr_us_w2_rep.get_w2_arch_bal(p_assignment_action_id
                                  ,'A_W2_UNCOLL_SS_GTL_PER_GRE_YTD'
                                  ,p_tax_unit_id
                                  ,'00-000-0000'
                                  ,0);
      hr_utility.set_location(gv_package || '.GET_ARCHIVED_VALUES',160);
   -- uncollected medicare tax on GTL insurance over $50,000
      pay_us_w2c_in_mmref2_format.ltr_rco_info(i).action_information7  :=
         hr_us_w2_rep.get_w2_arch_bal(p_assignment_action_id
                                  ,'A_W2_UNCOLL_MED_GTL_PER_GRE_YTD'
                                  ,p_tax_unit_id
                                  ,'00-000-0000'
                                  ,0);
     -- 409A Income , for bug 4398606
      pay_us_w2c_in_mmref2_format.ltr_rco_info(i).action_information8      :=
         hr_us_w2_rep.get_w2_arch_bal(p_assignment_action_id
                                 ,'A_W2_409A_NONQUAL_INCOME_PER_GRE_YTD'
                                 ,p_tax_unit_id
                                 ,'00-000-0000'
                                 ,0);
      hr_utility.trace('getting 409A Income for RCO record ' ||pay_us_w2c_in_mmref2_format.ltr_rco_info(i).action_information8);

      hr_utility.set_location(gv_package || '.GET_ARCHIVED_VALUES',170);
   -- End of fetching Archived values RCO
--}
 END IF; -- p_record_type  check
--
EXCEPTION
WHEN OTHERS then
     hr_utility.set_location(gv_package || '.GET_ARCHIVED_VALUES',180);
END GET_ARCHIVED_VALUES;
-- End of Get_Archived_Values function
--

-- Following Function used to compare Originally Reported values and Corrected
-- values on RCW or RCO record and format the record
FUNCTION  pay_us_w2c_RCW_record ( p_effective_date            IN varchar2,
                                  p_report_type               IN varchar2,
                                  p_format                    IN varchar2,
                                  p_report_qualifier          IN varchar2,
                                  p_record_name               IN varchar2,
                                  p_tax_unit_id               IN varchar2,
                                  p_record_identifier         IN varchar2,
                                  p_ssn                       IN varchar2,
                                  p_first_name                IN varchar2,
                                  p_middle_name               IN varchar2,
                                  p_last_name                 IN varchar2,
                                  p_sufix                     IN varchar2,
                                  p_location_address          IN varchar2,
                                  p_delivery_address          IN varchar2,
                                  p_city                      IN varchar2,
                                  p_state                     IN varchar2,
                                  p_zip                       IN varchar2,
                                  p_zip_extension             IN varchar2,
                                  p_foreign_state             IN varchar2,
                                  p_foreign_postal_code       IN varchar2,
                                  p_country_code              IN varchar2,
                                  p_orig_assignment_actid     IN varchar2,
                                  p_correct_assignment_actid  IN varchar2,
                                  p_employee_number           IN varchar2,
                                  p_format_type               IN varchar2,
                                  p_validate                  IN varchar2,
                                  p_exclude_from_output       OUT nocopy varchar2,
                                  sp_out_1                    OUT nocopy varchar2,
                                  sp_out_2                    OUT nocopy varchar2,
                                  sp_out_3                    OUT nocopy varchar2,
                                  sp_out_4                    OUT nocopy varchar2,
                                  sp_out_5                    OUT nocopy varchar2,
                                  ret_str_len                 OUT nocopy varchar2,
                                  p_error                     OUT nocopy boolean
                                  ) return varchar2
IS

lv_action_type                  varchar2(10)  := '';
lv_record_type                  varchar2(10)  := '';
ln_num_corrections              number        := 0;
ln_num_corrections_rcw          number        := 0;
ln_num_corrections_rco          number        := 0;
ln_num_corrections_rct          number        := 0;
ln_num_corrections_rcu          number        := 0;
lv_old_ssn                      varchar2(100) := '';
lv_new_ssn                      varchar2(100) := '';
lv_ssn_identical_flag           varchar2(10)  := 'Y';
lv_first_name_old               varchar2(200) := ' ';
lv_middle_name_old              varchar2(200) := ' ';
lv_last_name_old                varchar2(200) := ' ';
lv_statutory_emp_indicator_old  varchar2(10)  := ' ';
lv_statutory_emp_indicator_new  varchar2(10)  := ' ';
lv_retire_plan_indicator_old    varchar2(10)  := ' ';
lv_retire_plan_indicator_new    varchar2(10)  := ' ';
lv_sickpay_indicator_old        varchar2(10)  := ' ';
lv_sickpay_indicator_new        varchar2(10)  := ' ';
rcw_return_value                varchar2(32467) := lpad(' ',1024);
rco_return_value                varchar2(32467) := lpad(' ',1024);
lb_rco_error                    boolean := FALSE;
lv_rco_ret_str_len              varchar2(100) := '0';
lv_rco_exclude_from_output      varchar2(100) := 'N';
return_value_blank              varchar2(32767);
TYPE wage_value IS RECORD( p_parameter_name       varchar2(100),
                           p_parameter_value_old  number,
                           p_parameter_value_new  number
                         );
function_parameter_rec  wage_value;
TYPE input_parameter_record IS TABLE OF function_parameter_rec%TYPE
                               INDEX BY BINARY_INTEGER;
parameter_record input_parameter_record;

rcw_compared_rec pay_us_w2c_in_mmref2_format.table_wage_record;
rco_compared_rec pay_us_w2c_in_mmref2_format.table_wage_record;

l_rcw_neg_flag                   boolean := FALSE;
l_rco_neg_flag                   boolean := FALSE;

BEGIN
   hr_utility.set_location(gv_package || '.pay_us_w2c_RCW_record', 10);
   ln_num_corrections_rcw := 0;
   ln_num_corrections_rco := 0;
-- Employee Level Global Variables are initialized here

   pay_us_w2c_in_mmref2_format.rcw_exclude_flag       := 'N';
   pay_us_w2c_in_mmref2_format.rco_exclude_flag       := 'N';
   pay_us_w2c_in_mmref2_format.rcw_mf_record          := '';
   pay_us_w2c_in_mmref2_format.rcw_csv_record         := '';
   pay_us_w2c_in_mmref2_format.rcw_blank_csv_record   := '';
   pay_us_w2c_in_mmref2_format.rco_mf_record          := '';
   pay_us_w2c_in_mmref2_format.rco_csv_record         := '';
   pay_us_w2c_in_mmref2_format.rco_blank_csv_record   := '';
   pay_us_w2c_in_mmref2_format.rcw_number_of_correction := 0;
   pay_us_w2c_in_mmref2_format.rco_number_of_correction := 0;
--
-- Set Originally Reported RCW values
-- This procedure call will set the value in PL/SQL session table
--      pay_us_w2c_in_mmref2_format.ltr_rcw_info. Orginally reported value
--      would be stored in 1st row of the Pl/SQL table
   lv_action_type := 'O';
   lv_record_type := 'RCW';
   pay_us_w2c_in_mmref2_format.ltr_rcw_info.delete;
   hr_utility.trace('Calling Procedure pay_us_w2c_in_mmref2_format.GET_ARCHIVED_VALUES to set RCW record ');
   pay_us_w2c_in_mmref2_format.GET_ARCHIVED_VALUES ( lv_action_type
                                                    ,lv_record_type
                                                    ,p_orig_assignment_actid
                                                    ,p_tax_unit_id
                                                   );
   hr_utility.set_location(gv_package || '.pay_us_w2c_RCW_record', 20);
--
-- Set Corrected RCW values in PL/SQL table pay_us_w2c_in_mmref2_format.ltr_rcw_info
-- Corrected value would be stored in 2nd row of the Pl/SQL table
--
   lv_action_type := 'C';
   pay_us_w2c_in_mmref2_format.GET_ARCHIVED_VALUES ( lv_action_type
                                                    ,p_record_name
                                                    ,p_correct_assignment_actid
                                                    ,p_tax_unit_id
                                                   );
    hr_utility.set_location(gv_package || '.pay_us_w2c_RCW_record', 30);
--
-- Compare Orginally Reported and Corrected values to  decide whether RCW record
-- would be written to mf file or moved to .a02.
--

-- Compare Orignally Reported and Corrected <SSN>
   lv_old_ssn := replace(replace(replace(replace(
                  replace(pay_us_reporting_utils_pkg.character_check(pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).SSN),
                               ' '),'I'),'-'),'.'),'''');
   lv_new_ssn := replace(replace(replace(replace(
                  replace(pay_us_reporting_utils_pkg.character_check(pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).SSN),
                               ' '),'I'),'-'),'.'),'''');
   if NVL(lv_old_ssn,'ZZ') <> NVL(lv_new_ssn,'ZZ')
   then
       ln_num_corrections := ln_num_corrections + 1;
       lv_ssn_identical_flag := 'N';
   else
       lv_ssn_identical_flag := 'Y';
       lv_old_ssn := lpad(' ',9);
   end if;
   hr_utility.trace('SSN Comparision completed ');
   hr_utility.set_location(gv_package || '.pay_us_w2c_RCW_record', 40);
--
-- Compare Orignally Reported and Corrected <First Name>
--
   lv_first_name_old := ' ';
   if (pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).first_name is not null
       and pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).first_name is null)
   then
      ln_num_corrections := ln_num_corrections + 1;
      lv_first_name_old := pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).first_name;
   elsif (pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).first_name is not null
       and pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).first_name is null) then
      ln_num_corrections := ln_num_corrections + 1;
      lv_first_name_old := ' ';
   elsif (pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).first_name <>
          pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).first_name) then
      ln_num_corrections := ln_num_corrections + 1;
      lv_first_name_old := pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).first_name;
   end if;
   hr_utility.trace('First Name Comparision completed ');
   hr_utility.set_location(gv_package || '.pay_us_w2c_RCW_record', 50);
--
-- Compare Orignally Reported and Corrected <Middle Name>
--
   lv_middle_name_old := ' ';
   if (pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).middle_name is not null
       and pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).middle_name is null)
   then
      ln_num_corrections := ln_num_corrections + 1;
      lv_middle_name_old := pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).middle_name;
   elsif (pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).middle_name is not null
       and pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).middle_name is null) then
      ln_num_corrections := ln_num_corrections + 1;
   elsif (substr(pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).middle_name,1,1) <>
          substr(pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).middle_name,1,1)) then
      ln_num_corrections := ln_num_corrections + 1;
      lv_middle_name_old := pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).middle_name;
   elsif (pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).middle_name <>
          pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).middle_name) then
      ln_num_corrections := ln_num_corrections + 1;
      lv_middle_name_old := pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).middle_name;
   end if;
   hr_utility.trace('Middle Name Comparision completed ');
   hr_utility.set_location(gv_package || '.pay_us_w2c_RCW_record', 60);
--
-- Compare Orignally Reported and Corrected <Last Name>
--
   lv_last_name_old := ' ';
   if (pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).last_name is not null
       and pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).last_name is null)
   then
      ln_num_corrections := ln_num_corrections + 1;
      lv_last_name_old := pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).last_name;
   elsif (pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).last_name is not null
       and pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).last_name is null) then
      ln_num_corrections := ln_num_corrections + 1;
   elsif (pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).last_name <>
          pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).last_name) then
      ln_num_corrections := ln_num_corrections + 1;
      lv_last_name_old := pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).last_name;
   end if;
   hr_utility.set_location(gv_package || '.pay_us_w2c_RCW_record', 70);
   hr_utility.trace('Last Name Comparision completed ');
--
-- Compare Orignally Reported and Corrected <Statutory Employee Indicator>
--
   if (pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).statutory_emp_indicator = '0' and
       pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).statutory_emp_indicator = '0') then
   --{
       lv_statutory_emp_indicator_old  := ' ';
       lv_statutory_emp_indicator_new  := ' ';
   --}
   elsif (pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).statutory_emp_indicator <>
       pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).statutory_emp_indicator) then
   --{
       hr_utility.trace(' Statutory Employee Indicator Values are not equal ');
       ln_num_corrections := ln_num_corrections + 1;
       lv_statutory_emp_indicator_old  :=
          pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).statutory_emp_indicator;
       lv_statutory_emp_indicator_new  :=
          pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).statutory_emp_indicator;
   --}
   else
       lv_statutory_emp_indicator_old  := ' ';
       lv_statutory_emp_indicator_new  := ' ';
   end if;

   hr_utility.set_location(gv_package || '.pay_us_w2c_RCW_record', 80);

-- Compare Orignally Reported and Corrected <Retirement Plan Indicator>
   if (pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).retirement_plan_indicator ='0' and
       pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).retirement_plan_indicator ='0') then
   --{
       lv_retire_plan_indicator_old    := ' ';
       lv_retire_plan_indicator_new    := ' ';
   --}
   elsif (pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).retirement_plan_indicator <>
       pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).retirement_plan_indicator) then
   --{
       hr_utility.trace(' Retirement Plan Indicator Values are not equal ');
       ln_num_corrections := ln_num_corrections + 1;
       lv_retire_plan_indicator_old    :=
          pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).retirement_plan_indicator;
       lv_retire_plan_indicator_new    :=
          pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).retirement_plan_indicator;
   --}
   else
       lv_retire_plan_indicator_old    := ' ';
       lv_retire_plan_indicator_new    := ' ';
   end if;
   hr_utility.set_location(gv_package || '.pay_us_w2c_RCW_record', 90);

-- Compare Orignally Reported and Corrected < Third Part SickPay Indicator>
   if (pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).sick_pay_indicator = '0' and
       pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).sick_pay_indicator ='0' ) then
   --{
       lv_sickpay_indicator_old  := ' ';
       lv_sickpay_indicator_new  := ' ';
   --}
   elsif (pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).sick_pay_indicator <>
       pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).sick_pay_indicator) then
   --{
       hr_utility.trace(' Third Party Sick Pay Indicator Values are not equal ');
       ln_num_corrections := ln_num_corrections + 1;
       lv_sickpay_indicator_old  :=
                pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).sick_pay_indicator;
       lv_sickpay_indicator_new  :=
                pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).sick_pay_indicator;
   --}
   else
       lv_sickpay_indicator_old  := ' ';
       lv_sickpay_indicator_new  := ' ';
   end if;
   hr_utility.set_location(gv_package || '.pay_us_w2c_RCW_record', 100);
--
-- Following section is to compare all Wage values of RCW Record
--
   parameter_record.delete;

   parameter_record(1).p_parameter_name:= ' Wages,Tips And Other Compensation';
   parameter_record(1).p_parameter_value_old:=pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).action_information1;
   parameter_record(1).p_parameter_value_new:=pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).action_information1;

   parameter_record(2).p_parameter_name:= ' Federal Income Tax Withheld';
   parameter_record(2).p_parameter_value_old:=pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).action_information2;
   parameter_record(2).p_parameter_value_new:=pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).action_information2;

   parameter_record(3).p_parameter_name:= 'SS Wages';
   parameter_record(3).p_parameter_value_old:=pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).action_information3;
   parameter_record(3).p_parameter_value_new:=pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).action_information3;

   parameter_record(4).p_parameter_name:= ' Social Security Tax Withheld';
   parameter_record(4).p_parameter_value_old:=pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).action_information4;
   parameter_record(4).p_parameter_value_new:=pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).action_information4;

   parameter_record(5).p_parameter_name:= 'Medicare Wages And Tips';
   parameter_record(5).p_parameter_value_old:=pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).action_information5;
   parameter_record(5).p_parameter_value_new:=pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).action_information5;

   parameter_record(6).p_parameter_name:= 'Medicare Tax Withheld';
   parameter_record(6).p_parameter_value_old:=pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).action_information6;
   parameter_record(6).p_parameter_value_new:=pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).action_information6;

   parameter_record(7).p_parameter_name:= 'SS Tips';
   parameter_record(7).p_parameter_value_old:=pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).action_information7;
   parameter_record(7).p_parameter_value_new:=pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).action_information7;

   parameter_record(8).p_parameter_name:= 'Advance Earned Income Credit';
   parameter_record(8).p_parameter_value_old:=pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).action_information8;
   parameter_record(8).p_parameter_value_new:=pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).action_information8;

   parameter_record(9).p_parameter_name:= 'Dependent Care Benefits';
   parameter_record(9).p_parameter_value_old:=pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).action_information9;
   parameter_record(9).p_parameter_value_new:=pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).action_information9;

   parameter_record(10).p_parameter_name:= 'Deferred Comp Contr. to Sec 401(k)';
   parameter_record(10).p_parameter_value_old:=pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).action_information10;
   parameter_record(10).p_parameter_value_new:=pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).action_information10;

   parameter_record(11).p_parameter_name:= 'Deferred Comp Contr. to Sec 403(b)';
   parameter_record(11).p_parameter_value_old:=pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).action_information11;
   parameter_record(11).p_parameter_value_new:=pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).action_information11;

   parameter_record(12).p_parameter_name:= 'Deferred Comp Contr. to Sec 408(k)(6)';
   parameter_record(12).p_parameter_value_old:=pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).action_information12;
   parameter_record(12).p_parameter_value_new:=pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).action_information12;

   parameter_record(13).p_parameter_name:= 'Deferred Comp Contr. to Sec 457(b)';
   parameter_record(13).p_parameter_value_old:=pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).action_information13;
   parameter_record(13).p_parameter_value_new:=pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).action_information13;

   parameter_record(14).p_parameter_name:= 'Deferred Comp Contr. to Sec 501(c)';
   parameter_record(14).p_parameter_value_old:=pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).action_information14;
   parameter_record(14).p_parameter_value_new:=pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).action_information14;

   parameter_record(15).p_parameter_name:= 'Deferred Compensation Contribution ';
   parameter_record(15).p_parameter_value_old:=pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).action_information15;
   parameter_record(15).p_parameter_value_new:=pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).action_information15;

   parameter_record(16).p_parameter_name:= 'Military Combat Pay';
   parameter_record(16).p_parameter_value_old:=pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).action_information16;
   parameter_record(16).p_parameter_value_new:=pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).action_information16;

   parameter_record(17).p_parameter_name:= 'Non-Qual. plan Sec 457';
   parameter_record(17).p_parameter_value_old:=pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).action_information17;
   parameter_record(17).p_parameter_value_new:=pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).action_information17;

   parameter_record(18).p_parameter_name:= 'Non-Qual. plan NOT Sec 457';
   parameter_record(18).p_parameter_value_old:=pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).action_information18;
   parameter_record(18).p_parameter_value_new:=pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).action_information18;

   parameter_record(19).p_parameter_name:= 'Employer cost of premiun';
   parameter_record(19).p_parameter_value_old:=pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).action_information19;
   parameter_record(19).p_parameter_value_new:=pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).action_information19;

   parameter_record(20).p_parameter_name:= 'Income from nonqualified stock option';
   parameter_record(20).p_parameter_value_old:=pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).action_information20;
   parameter_record(20).p_parameter_value_new:=pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).action_information20;

   parameter_record(21).p_parameter_name:= 'ER Contribution to HSA';
   parameter_record(21).p_parameter_value_old:=pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).action_information21;
   parameter_record(21).p_parameter_value_new:=pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).action_information21;

   parameter_record(22).p_parameter_name:= 'Nontaxable Combat Pay';
   parameter_record(22).p_parameter_value_old:=pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).action_information22;
   parameter_record(22).p_parameter_value_new:=pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).action_information22;

   parameter_record(23).p_parameter_name:= 'Nonqual 409A Deferral Amount';
   parameter_record(23).p_parameter_value_old:=pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).action_information23;
   parameter_record(23).p_parameter_value_new:=pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).action_information23;

   parameter_record(24).p_parameter_name:= 'Designed   Roth Contr. to 401k Plan';    /* saurabh */
   parameter_record(24).p_parameter_value_old:=pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).action_information24;
   parameter_record(24).p_parameter_value_new:=pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).action_information24;

   parameter_record(25).p_parameter_name:= 'Designed   Roth Contr. to 403b Plan';   /* saurabh */
   parameter_record(25).p_parameter_value_old:=pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).action_information25;
   parameter_record(25).p_parameter_value_new:=pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).action_information25;
   hr_utility.set_location(gv_package || '.pay_us_w2c_RCW_record', 110);

   hr_utility.set_location(gv_package || '.pay_us_w2c_RCW_record', 110);

-- Delete all value from PL/SQL table used for storing RCW record wage values
-- after comparision. This table normally stores 20 wage values

   rcw_compared_rec.delete;

   l_rcw_neg_flag := FALSE;

   for m in 1..25 loop   /* saurabh */

       if ((parameter_record(m).p_parameter_value_old < 0 ) OR
           (parameter_record(m).p_parameter_value_new < 0 )) then

          l_rcw_neg_flag := TRUE;
          exit;

       end if;

   end loop;

--
-- This loop will be used to compare all the wage data associated with RCW
--
   FOR k in 1..25 /* saurabh */
   LOOP
     /*
      if (parameter_record(k).p_parameter_value_old = 0 and
          parameter_record(k).p_parameter_value_new = 0) then
     */

      if (parameter_record(k).p_parameter_value_old =
                    parameter_record(k).p_parameter_value_new ) then
      --{
          rcw_compared_rec(k).identical_flag := 'Y';
          rcw_compared_rec(k).wage_old_value := 0;
          rcw_compared_rec(k).wage_new_value := 0;
          rcw_compared_rec(k).wage_old_value_formated := lpad(' ',11);
          rcw_compared_rec(k).wage_new_value_formated := lpad(' ',11);
      --}
      elsif parameter_record(k).p_parameter_value_old <>
                         parameter_record(k).p_parameter_value_new
      then
      --{
          hr_utility.trace(to_char(k)||'. '||parameter_record(k).p_parameter_name ||'Value are not equal ');

          ln_num_corrections := ln_num_corrections + 1;

          if NOT l_rcw_neg_flag then

             -- These values will be used for formating RCT record

             if ( parameter_record(k).p_parameter_value_old > 0 AND
                  parameter_record(k).p_parameter_value_new >= 0 ) then

                 pay_us_w2c_in_mmref2_format.ltr_rct_info(k).rct_wage_old :=
                    pay_us_w2c_in_mmref2_format.ltr_rct_info(k).rct_wage_old +
                       (parameter_record(k).p_parameter_value_old*100);
             end if;

             if parameter_record(k).p_parameter_value_new > 0 then

                pay_us_w2c_in_mmref2_format.ltr_rct_info(k).rct_wage_new :=
                   pay_us_w2c_in_mmref2_format.ltr_rct_info(k).rct_wage_new +
                      (parameter_record(k).p_parameter_value_new*100);
             end if;

          end if; /* l_rcw_neg_flag */


-- These values will be used for formatting RCW record
          rcw_compared_rec(k).wage_old_value :=
              to_char(trunc(parameter_record(k).p_parameter_value_old*100));
          rcw_compared_rec(k).wage_new_value :=
              to_char(trunc(parameter_record(k).p_parameter_value_new*100));
          rcw_compared_rec(k).identical_flag := 'N';
      --}

/*
      else
-- These values will be used for formatting RCW record
          rcw_compared_rec(k).identical_flag := 'Y';
          rcw_compared_rec(k).wage_old_value := 0;
          rcw_compared_rec(k).wage_new_value := 0;
          rcw_compared_rec(k).wage_old_value_formated := lpad(' ',11);
          rcw_compared_rec(k).wage_new_value_formated := lpad(' ',11);
*/

      end if;
   END LOOP;
   hr_utility.set_location(gv_package || '.pay_us_w2c_RCW_record', 120);
   ln_num_corrections_rcw := ln_num_corrections;

--
-- Set Originally Reported RCO values
-- This procedure call will set the value in PL/SQL session table
--      pay_us_w2c_in_mmref2_format.ltr_rco_info. Orginally reported value
--      would be stored in 1st row of the Pl/SQL table

   lv_action_type := 'O';
   lv_record_type := 'RCO';

   pay_us_w2c_in_mmref2_format.ltr_rco_info.delete;

   hr_utility.trace('Calling pay_us_w2c_in_mmref2_format.GET_ARCHIVED_VALUES'
                    || 'to set  Originally reported RCO record values');

   pay_us_w2c_in_mmref2_format.GET_ARCHIVED_VALUES ( lv_action_type
                                                    ,lv_record_type
                                                    ,p_orig_assignment_actid
                                                    ,p_tax_unit_id
                                                   );
   hr_utility.set_location(gv_package || '.pay_us_w2c_RCW_record', 130);
-- Set Corrected RCO values in PL/SQL table
-- pay_us_w2c_in_mmref2_format.ltr_rco_info
-- Corrected value would be stored in 2nd row of the Pl/SQL table
--

   lv_action_type := 'C';
   hr_utility.trace('Calling pay_us_w2c_in_mmref2_format.GET_ARCHIVED_VALUES'
                    || 'to set Corrected RCO record values');

   pay_us_w2c_in_mmref2_format.GET_ARCHIVED_VALUES ( lv_action_type
                                                    ,lv_record_type
                                                    ,p_correct_assignment_actid
                                                    ,p_tax_unit_id
                                                   );
   hr_utility.set_location(gv_package || '.pay_us_w2c_RCW_record', 140);

--
-- Following section is to compare all Wage values of RCO Record
--
-- Delete the Temp parameter table

   parameter_record.delete;

-- Initialize temp prameter table for comparing RCO Wages

   parameter_record(1).p_parameter_name:= ' allocated tips';
   parameter_record(1).p_parameter_value_old:=pay_us_w2c_in_mmref2_format.ltr_rco_info(1).action_information1;
   parameter_record(1).p_parameter_value_new:=pay_us_w2c_in_mmref2_format.ltr_rco_info(2).action_information1;

   parameter_record(2).p_parameter_name:= ' uncollected employee tax on tips';
   parameter_record(2).p_parameter_value_old:=pay_us_w2c_in_mmref2_format.ltr_rco_info(1).action_information2;
   parameter_record(2).p_parameter_value_new:=pay_us_w2c_in_mmref2_format.ltr_rco_info(2).action_information2;

   parameter_record(3).p_parameter_name:= ' Medical Savings Account';
   parameter_record(3).p_parameter_value_old:=pay_us_w2c_in_mmref2_format.ltr_rco_info(1).action_information3;
   parameter_record(3).p_parameter_value_new:=pay_us_w2c_in_mmref2_format.ltr_rco_info(2).action_information3;

   parameter_record(4).p_parameter_name:= ' Simple Retirement Account';
   parameter_record(4).p_parameter_value_old:=pay_us_w2c_in_mmref2_format.ltr_rco_info(1).action_information4;
   parameter_record(4).p_parameter_value_new:=pay_us_w2c_in_mmref2_format.ltr_rco_info(2).action_information4;

   parameter_record(5).p_parameter_name:= ' Qualified adoption expenses';
   parameter_record(5).p_parameter_value_old:=pay_us_w2c_in_mmref2_format.ltr_rco_info(1).action_information5;
   parameter_record(5).p_parameter_value_new:=pay_us_w2c_in_mmref2_format.ltr_rco_info(2).action_information5;

   parameter_record(6).p_parameter_name:= 'uncollected social security or RRTA tax on GTL insurance over $50000';
   parameter_record(6).p_parameter_value_old:=pay_us_w2c_in_mmref2_format.ltr_rco_info(1).action_information6;
   parameter_record(6).p_parameter_value_new:=pay_us_w2c_in_mmref2_format.ltr_rco_info(2).action_information6;

   parameter_record(7).p_parameter_name:= 'uncollected medicare tax on GTL insurance over $50,000';
   parameter_record(7).p_parameter_value_old:=pay_us_w2c_in_mmref2_format.ltr_rco_info(1).action_information7;
   parameter_record(7).p_parameter_value_new:=pay_us_w2c_in_mmref2_format.ltr_rco_info(2).action_information7;

   parameter_record(8).p_parameter_name:= 'income under 409A';
   parameter_record(8).p_parameter_value_old:=pay_us_w2c_in_mmref2_format.ltr_rco_info(1).action_information8;
   parameter_record(8).p_parameter_value_new:=pay_us_w2c_in_mmref2_format.ltr_rco_info(2).action_information8;

   hr_utility.trace('Old value of income under 409A '||parameter_record(8).p_parameter_value_old);
   hr_utility.trace('New value of income under 409A '||parameter_record(8).p_parameter_value_new);


   hr_utility.set_location(gv_package || '.pay_us_w2c_RCW_record', 150);

-- Delete all value from PL/SQL table used for storing RCO record wage values
-- after comparision. This table normally stores 7 wage values

   rco_compared_rec.delete;

   l_rco_neg_flag := FALSE;

   for m in 1..8 loop

       if ((parameter_record(m).p_parameter_value_old < 0 ) OR
           (parameter_record(m).p_parameter_value_new < 0 )) then

          l_rco_neg_flag := TRUE;
          exit;

       end if;

   end loop;

--
-- This loop will be used to compare all the wage data associated with RCO
--
   hr_utility.trace('Comparing RCO Values of Originally reported and Corrected W2');

   FOR k in 1..8 LOOP

      if (parameter_record(k).p_parameter_value_old =
          parameter_record(k).p_parameter_value_new ) then
      --{
          rco_compared_rec(k).identical_flag := 'Y';
          rco_compared_rec(k).wage_old_value := 0;
          rco_compared_rec(k).wage_new_value := 0;
          rco_compared_rec(k).wage_old_value_formated := lpad(' ', 11);
          rco_compared_rec(k).wage_new_value_formated := lpad(' ', 11);
      --}
      elsif parameter_record(k).p_parameter_value_old <>
                       parameter_record(k).p_parameter_value_new
      then
      --{
          hr_utility.trace(to_char(k)||'. '||parameter_record(k).p_parameter_name ||'Value are not equal ');

          ln_num_corrections := ln_num_corrections + 1;

          if NOT l_rco_neg_flag then

             -- These values will be used for formating RCU record
             if (parameter_record(k).p_parameter_value_old > 0 AND
                 parameter_record(k).p_parameter_value_new >= 0 )then

                pay_us_w2c_in_mmref2_format.ltr_rcu_info(k).rcu_wage_old :=
                    pay_us_w2c_in_mmref2_format.ltr_rcu_info(k).rcu_wage_old +
                        (parameter_record(k).p_parameter_value_old*100);

             end if;

             if parameter_record(k).p_parameter_value_new > 0 then

                pay_us_w2c_in_mmref2_format.ltr_rcu_info(k).rcu_wage_new :=
                    pay_us_w2c_in_mmref2_format.ltr_rcu_info(k).rcu_wage_new +
                        (parameter_record(k).p_parameter_value_new*100);

             end if;

           end if; /* l_rco_neg_flag */

-- These values will be used for formatting RCO record
          rco_compared_rec(k).wage_old_value :=
              to_char(trunc(parameter_record(k).p_parameter_value_old*100));
          rco_compared_rec(k).wage_new_value :=
              to_char(trunc(parameter_record(k).p_parameter_value_new*100));
          rco_compared_rec(k).identical_flag := 'N';
      --}

/*
      else
-- These values will be used for formatting RCO record
          rco_compared_rec(k).identical_flag := 'Y';
          rco_compared_rec(k).wage_old_value := 0;
          rco_compared_rec(k).wage_new_value := 0;
          rco_compared_rec(k).wage_old_value_formated := lpad(' ', 11);
          rco_compared_rec(k).wage_new_value_formated := lpad(' ', 11);
*/

      end if;
   END LOOP;

   hr_utility.trace('Comparision for RCO values completed ');
   hr_utility.set_location(gv_package || '.pay_us_w2c_RCW_record',160);

   ln_num_corrections_rco := ln_num_corrections -ln_num_corrections_rcw;

   pay_us_w2c_in_mmref2_format.rcw_number_of_correction  := ln_num_corrections_rcw;

   pay_us_w2c_in_mmref2_format.rco_number_of_correction  := ln_num_corrections_rco;

   hr_utility.trace('RCW No of Corrections '||to_char(ln_num_corrections_rcw));
   hr_utility.trace('RCO No of Corrections '||to_char(ln_num_corrections_rco));
   hr_utility.trace('Before RCW Format and Validation p_exclude_from_output '||p_exclude_from_output);

   pay_us_w2c_in_mmref2_format.rcw_number_of_correction  := ln_num_corrections_rcw;

   pay_us_w2c_in_mmref2_format.rco_number_of_correction  := ln_num_corrections_rco;

-- This section Validates and Formats RCW  Record
-- Call to format_W2C_RCW_record to format RCW record
--
   rcw_return_value := pay_us_mmrf2_w2c_format_record.format_W2C_RCW_record (
                                  p_effective_date,
                                  p_report_type,
                                  p_format,
                                  p_report_qualifier,
                                  p_record_name,
                                  p_tax_unit_id,
                                  p_record_identifier,
                                  lv_old_ssn,
                                  lv_new_ssn,
                                  lv_first_name_old,
                                  lv_middle_name_old,
                                  lv_last_name_old,
                                  pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).first_name,
                                  pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).middle_name,
                                  pay_us_w2c_in_mmref2_format.ltr_rcw_info(1).last_name,
                                  pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).first_name,
                                  pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).middle_name,
                                  pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).last_name,
                                  p_location_address,
                                  p_delivery_address,
                                  p_city,
                                  p_state,
                                  p_zip,
                                  p_zip_extension,
                                  p_foreign_state,
                                  p_foreign_postal_code,
                                  p_country_code,
                                  lv_statutory_emp_indicator_old,
                                  lv_statutory_emp_indicator_new,
                                  lv_retire_plan_indicator_old,
                                  lv_retire_plan_indicator_new,
                                  lv_sickpay_indicator_old,
                                  lv_sickpay_indicator_new,
                                  p_orig_assignment_actid,
                                  p_correct_assignment_actid,
                                  p_employee_number,
                                  rcw_compared_rec,
                                  p_format_type,
                                  p_validate,
                                  p_exclude_from_output,
                                  ret_str_len,
                                  p_error
                               );
   hr_utility.set_location(gv_package || '.pay_us_w2c_RCW_record',165);

   if p_error then
      hr_utility.trace('RCW Format and Validation resulted ERROR with p_exclude_from_output '||p_exclude_from_output);
   else
      hr_utility.trace('RCW Format and Validation resulted NO Error with p_exclude_from_output '||p_exclude_from_output);
   end if;
   hr_utility.trace('Before RCO Format and Validation p_exclude_from_output '||lv_rco_exclude_from_output);

-- This section Validates and Formats RCO Record
-- Call to format_W2C_RCO_record to set Originally reported formattted values for reporting
  if ln_num_corrections_rco > 0 then
     rco_return_value := pay_us_mmrf2_w2c_format_record.format_W2C_RCO_record
                               (
                                  p_effective_date,
                                  p_report_type,
                                  p_format,
                                  p_report_qualifier,
                                  'RCO',
                                  p_tax_unit_id,
                                  'RCO',
                                  lv_new_ssn,
                                  pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).first_name,
                                  pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).middle_name,
                                  pay_us_w2c_in_mmref2_format.ltr_rcw_info(2).last_name,
                                  p_orig_assignment_actid,
                                  p_correct_assignment_actid,
                                  p_employee_number,
                                  rco_compared_rec,
                                  p_format_type,
                                  p_validate,
                                  lv_rco_exclude_from_output,
                                  lv_rco_ret_str_len,
                                  lb_rco_error
                               );


   if lb_rco_error then
      hr_utility.trace('RCO Format and Validation resulted ERROR with p_exclude_from_output '||lv_rco_exclude_from_output);
   else
      hr_utility.trace('RCO Format and Validation resulted NO Error with p_exclude_from_output '||lv_rco_exclude_from_output);
   end if;
  else
     hr_utility.set_location(gv_package || '.pay_us_w2c_RCW_record',168);
   -- Format Blank RCO record in MMREF-2 format
   -- This Blank record would be used when RCO record is moved to .a02 for error
   --{

     hr_utility.trace('Formatting BLANK RCO Record ');
     return_value_blank :=   ','
                             ||' '
                             ||','||lpad(' ',9)
                             ||','||' '
                             ||','||' '
                             ||','||' '
                             ||','||' '
                             ||','||' '
                             ||','||' '
                             ||','||' '
                             ||','||' '
                             ||','||' '
                             ||','||' '
                             ||','||' '
                             ||','||' '
                             ||','||' '
                             ||','||' '
                             ||','||' ';
    pay_us_w2c_in_mmref2_format.rco_blank_csv_record := return_value_blank;
   --}
   lb_rco_error := FALSE;
   lv_rco_exclude_from_output := 'Y';
   pay_us_w2c_in_mmref2_format.rco_exclude_flag := 'Y';
  end if;

   hr_utility.set_location(gv_package || '.pay_us_w2c_RCW_record',170);
   if NOT p_error then
--{
      hr_utility.set_location(gv_package || '.pay_us_w2c_RCW_record',180);
      hr_utility.trace('RCW formating and Validation was successful');
--
-- This section increments the counter to be reported in RCT record for Valid
-- or Error Record
-- Valid condtion is atleast one value of RCW is corrected for given employee
-- Error condition is not even a single value is corrected for the employee
--
      if ln_num_corrections_rcw > 0 then
      -- RCT Valid Record Total
         pay_us_w2c_in_mmref2_format.number_of_valid_rcw_rct :=
            pay_us_w2c_in_mmref2_format.number_of_valid_rcw_rct + 1;
         pay_us_w2c_in_mmref2_format.rcw_exclude_flag := 'N';
      -- RCF Valid Record Total
      --   pay_us_w2c_in_mmref2_format.number_of_valid_rcw_rcf :=
      --      pay_us_w2c_in_mmref2_format.number_of_valid_rcw_rcf + 1;

      else
      -- RCT Error Record Total
         pay_us_w2c_in_mmref2_format.number_of_error_rcw_rct :=
            pay_us_w2c_in_mmref2_format.number_of_error_rcw_rct + 1;
         pay_us_w2c_in_mmref2_format.rcw_exclude_flag := 'Y';
      -- RCF Error Record Total
      --   pay_us_w2c_in_mmref2_format.number_of_error_rcw_rcf :=
      --      pay_us_w2c_in_mmref2_format.number_of_error_rcw_rcf + 1;

      end if;
--}
   else
   --{
         hr_utility.set_location(gv_package || '.pay_us_w2c_RCW_record',190);
         pay_us_w2c_in_mmref2_format.number_of_error_rcw_rct :=
            pay_us_w2c_in_mmref2_format.number_of_error_rcw_rct + 1;
         pay_us_w2c_in_mmref2_format.rcw_exclude_flag := 'Y';
      -- RCF Error Record Total
      --   pay_us_w2c_in_mmref2_format.number_of_error_rcw_rcf :=
      --      pay_us_w2c_in_mmref2_format.number_of_error_rcw_rcf + 1;
   --}
   end if;

   if NOT lb_rco_error and NOT l_rcw_neg_flag then
--{
      hr_utility.set_location(gv_package || '.pay_us_w2c_RCW_record',200);
      hr_utility.trace('RCO formating and Validation was successful');
--
-- This section increments the counter to be reported in RCU record for Valid
-- or Error Record
-- Valid condtion is atleast one value of RCO is corrected for given employee
-- Error condition is not even a single value is corrected for the employee
--
      if ln_num_corrections_rco > 0 then
         hr_utility.set_location(gv_package || '.pay_us_w2c_RCW_record',205);
         pay_us_w2c_in_mmref2_format.number_of_valid_rco_rcu :=
            pay_us_w2c_in_mmref2_format.number_of_valid_rco_rcu + 1;
            pay_us_w2c_in_mmref2_format.rco_exclude_flag := 'N';
      else
         hr_utility.set_location(gv_package || '.pay_us_w2c_RCW_record',206);
         pay_us_w2c_in_mmref2_format.number_of_error_rco_rcu :=
            pay_us_w2c_in_mmref2_format.number_of_error_rco_rcu + 1;
            pay_us_w2c_in_mmref2_format.rco_exclude_flag := 'Y';
      end if;
--}
   else
   --{
      hr_utility.set_location(gv_package || '.pay_us_w2c_RCW_record',210);
      hr_utility.trace('RCO formating and Validation ERROR out');
         pay_us_w2c_in_mmref2_format.number_of_error_rco_rcu :=
            pay_us_w2c_in_mmref2_format.number_of_error_rco_rcu + 1;
            pay_us_w2c_in_mmref2_format.rco_exclude_flag := 'Y';
   --}
   end if;
   if lv_rco_exclude_from_output = 'Y'
   then
       pay_us_w2c_in_mmref2_format.rco_exclude_flag := 'Y';
   else
       pay_us_w2c_in_mmref2_format.rco_exclude_flag := 'N';
   end if;
-- return Flat format RCW record
   hr_utility.trace('RCW Exlcude from output Flag '||pay_us_w2c_in_mmref2_format.rcw_exclude_flag);
   hr_utility.trace('RCO Exlcude from output Flag '||pay_us_w2c_in_mmref2_format.rco_exclude_flag);
   hr_utility.trace('Number of Values corrected '||to_char(ln_num_corrections));
   hr_utility.trace(gv_package || '.pay_us_w2c_RCW_record'||' successfully completed');
   return (rcw_return_value);
Exception
WHEN OTHERS THEN
   hr_utility.trace('Error encountered in '||gv_package || '.pay_us_w2c_RCW_record');
   hr_utility.trace('Error: '||sqlerrm);
END pay_us_w2c_RCW_record;

--
-- End of Procedure to get the Archived values of RCW/RCO record
--
--BEGIN
--hr_utility.trace_on(null,'W2CGAV');
END pay_us_w2c_in_mmref2_format;

/
