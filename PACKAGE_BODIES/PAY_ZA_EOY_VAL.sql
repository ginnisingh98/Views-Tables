--------------------------------------------------------
--  DDL for Package Body PAY_ZA_EOY_VAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ZA_EOY_VAL" as
/* $Header: pyzatyev.pkb 120.9.12010000.30 2010/03/25 09:16:36 rpahune ship $ */
-- Pacakge Body
g_xml_element_count number:=0;
g_asg_set_where varchar2(500);
g_sort_order_clause varchar2(500);

type msgtext_tab is table of varchar2(2000) index by binary_integer;

Function modulus_10_test
  (p_tax_number                    in     number) return number
-- return 1 if correct, else return 0
is

     nine_digits        number(9);
     tax_no             number(10);
     n1                 number(2);
     n2                 number(1):= substr(p_tax_number,2,1);
     n3                 number(2):= 2 * substr(p_tax_number,3,1);
     n4                 number(1):= substr(p_tax_number,4,1);
     n5                 number(2):= 2 * substr(p_tax_number,5,1);
     n6                 number(1):= substr(p_tax_number,6,1);
     n7                 number(2):= 2 * substr(p_tax_number,7,1);
     n8                 number(1):= substr(p_tax_number,8,1);
     n9                 number(2):= 2* substr(p_tax_number,9,1);
     n10                number(2):= substr(p_tax_number,10,1);
     temp               number(2);
     temp1              number(2);
     res                number(2);
  begin
-- Store the 10 digit tax number
-- only the first nine chars are used for the test


      tax_no:=p_tax_number;
      If ((length(tax_no) <> 10) or (tax_no is NULL)) then
          return 0;
      elsif tax_no between 7000000000 and 7980000000 then
-- replace the first digit 7 by 4
          nine_digits := substr(tax_no,2,10);
          tax_no := 4||nine_digits;
      end if;

-- otherwise do not replace the first digit
-- Multiply the first number and thereafter every second number by 2
-- if the result is greater than 9, add the individual digits to get
-- the final answer

      n1 := 2 * substr(tax_no,1,1);
      if n1 > 9 then
         n1 := substr(n1,1,1) + substr(n1,2,1);
      end if;
      if n3 > 9 then
               n3 := substr(n3,1,1) + substr(n3,2,1);
      end if;
      if n5 > 9 then
               n5 := substr(n5,1,1) + substr(n5,2,1);
      end if;
      if n7 > 9 then
               n7 := substr(n7,1,1) + substr(n7,2,1);
      end if;
      if n9 > 9 then
               n9 := substr(n9,1,1) + substr(n9,2,1);
      end if;
      temp := n1 + n2 + n3 + n4 + n5 + n6 + n7 + n8 + n9;

-- deduct the total result from the next full ten to get the last digit
      if mod(temp,10) > 0 then
         temp1 :=  temp - mod(temp,10) + 10;
      else
         temp1 := temp;
      end if;
      res := temp1 - temp;
      if res = n10 then
        return 1;
      else
        return 0;
      end if;

  exception

   when value_error then
        return 0;

   when others then
        raise_application_error(-20101,'PAY_ZA_EOY_VAL.MODULUS_10_TEST exception');



  end modulus_10_test;

--For validation of SDL and UIF number, p_type is not null.
--For PAYE Reference number, this is null
 Function modulus_10_test
  (p_tax_number                    in     varchar2
  ,p_type                          in     varchar2 default null)
return number
-- return 1 if correct, else return 0
is

     nine_digits        varchar2(9);
     tax_no             varchar2(10);
     n1                 varchar2(2);
     n2                 varchar2(1);
     n3                 varchar2(2);
     n4                 varchar2(1);
     n5                 varchar2(2);
     n6                 varchar2(1);
     n7                 varchar2(2);
     n8                 varchar2(1);
     n9                 varchar2(2);
     n10                varchar2(2);
     temp               varchar2(2);
     temp1              varchar2(2);
     res                varchar2(2);
  begin
-- Store the 10 digit tax number
-- only the first nine chars are used for the test

      n2   := substr(p_tax_number,2,1);
      n3   := 2 * substr(p_tax_number,3,1);
      n4   := substr(p_tax_number,4,1);
      n5   := 2 * substr(p_tax_number,5,1);
      n6   := substr(p_tax_number,6,1);
      n7   := 2 * substr(p_tax_number,7,1);
      n8   := substr(p_tax_number,8,1);
      n9   := 2* substr(p_tax_number,9,1);
      n10  := substr(p_tax_number,10,1);

      tax_no:=p_tax_number;
      If ((length(tax_no) <> 10) or (tax_no is NULL)) then
          return 0;
      --For UIF and SDL, replace first letter by 4.
      elsif p_type is not null then
          -- replace the first letter by 4
          nine_digits := substr(tax_no,2,10);
          tax_no := 4||nine_digits;
      elsif tax_no between 7000000000 and 7980000000 then
-- replace the first digit 7 by 4
          nine_digits := substr(tax_no,2,10);
          tax_no := 4||nine_digits;
      end if;

-- otherwise do not replace the first digit
-- Multiply the first number and thereafter every second number by 2
-- if the result is greater than 9, add the individual digits to get
-- the final answer

      n1 := 2 * substr(tax_no,1,1);
      if n1 > 9 then
         n1 := substr(n1,1,1) + substr(n1,2,1);
      end if;
      if n3 > 9 then
               n3 := substr(n3,1,1) + substr(n3,2,1);
      end if;
      if n5 > 9 then
               n5 := substr(n5,1,1) + substr(n5,2,1);
      end if;
      if n7 > 9 then
               n7 := substr(n7,1,1) + substr(n7,2,1);
      end if;
      if n9 > 9 then
               n9 := substr(n9,1,1) + substr(n9,2,1);
      end if;
      temp := n1 + n2 + n3 + n4 + n5 + n6 + n7 + n8 + n9;

-- deduct the total result from the next full ten to get the last digit
      if mod(temp,10) > 0 then
         temp1 :=  temp - mod(temp,10) + 10;
      else
         temp1 := temp;
      end if;
      res := temp1 - temp;
      if res = n10 then
        return 1;
      else
        return 0;
      end if;

  exception

   when value_error then
        return 0;

   when others then
        raise_application_error(-20101,'PAY_ZA_EOY_VAL.MODULUS_10_TEST exception');

  end modulus_10_test;

---------------------------------------------------------------------------------------
--Modulus_13_test for ID Number
---------------------------------------------------------------------------------------
Function modulus_13_test
  (p_id_number                    in     varchar2)
return number
-- return 1 if correct, else return 0
is

     nine_digits                    varchar2(9);
     l_national_identifier          varchar2(13);
     check_digit                    varchar2(1);
     digit_11_12                    varchar2(2);
     sum_odd_digits                 varchar2(3);
     combine_even_digits            varchar2(6);
     combine_even_digits_mul_2      varchar2(8);
     sum_combine_even_digits_mul_2  varchar2(3);
     final_sum                      varchar2(3);
     final_sum_last_digit           varchar2(2);
     last_digit                     varchar2(2);
     temp               varchar2(2);
     temp1              varchar2(2);
     res                varchar2(2);
begin
      -- Store the 13 ID number
      if length(p_id_number) <> 13 or p_id_number is null then
            return 0;
      end if;

      l_national_identifier:=p_id_number;
      check_digit := substr(l_national_identifier,13,1);
      digit_11_12 := substr(l_national_identifier,11,1) || substr(l_national_identifier,12,1);

      if(to_number(digit_11_12) < 8)
      then
           /* Move '08' to digit 11 and 12 */
           l_national_identifier := substr(l_national_identifier, 1, 10) || '0' || '8' || check_digit;
       end if;

      if(to_number(digit_11_12) > 9 and to_number(digit_11_12) < 14)
      then
           /* Move '18' to digit 11 and 12 */
           l_national_identifier := substr(l_national_identifier, 1, 10) || '1' || '8' || check_digit;
       end if;

      -- otherwise do not replace
      -- a)Add all the digits in the odd positions (excluding last digit).
      -- b)Move the even positions into a field and multiply the number by 2
      -- c)Add the digits of the result in b
      -- d)Add the answer in [a] to the answer in [c].
      -- e)Subtract the last digit of d from 10. The number must tally with the last number in the ID Number.
      --   If the result is 2 digits, the last digit is used to compare against the last number in the ID Number.
      --   If the answer differs, the ID number is invalid.

      sum_odd_digits := substr(l_national_identifier,1,1) +
                       substr(l_national_identifier,3,1) +
                       substr(l_national_identifier,5,1) +
                       substr(l_national_identifier,7,1) +
                       substr(l_national_identifier,9,1) +
                       substr(l_national_identifier,11,1);

      combine_even_digits := substr(l_national_identifier,2,1) ||
                            substr(l_national_identifier,4,1) ||
                            substr(l_national_identifier,6,1) ||
                            substr(l_national_identifier,8,1) ||
                            substr(l_national_identifier,10,1) ||
                            substr(l_national_identifier,12,1);

      combine_even_digits_mul_2 := (combine_even_digits) * 2;

              /* Length of combine_even_digits_mul_2 should be atleast 7 */
      combine_even_digits_mul_2    := lpad(combine_even_digits_mul_2,7,0);

      sum_combine_even_digits_mul_2:= substr(combine_even_digits_mul_2,1,1) +
                                      substr(combine_even_digits_mul_2,2,1) +
                                      substr(combine_even_digits_mul_2,3,1) +
                                      substr(combine_even_digits_mul_2,4,1) +
                                      substr(combine_even_digits_mul_2,5,1) +
                                      substr(combine_even_digits_mul_2,6,1) +
                                      substr(combine_even_digits_mul_2,7,1);

      final_sum := sum_odd_digits + sum_combine_even_digits_mul_2;
      final_sum_last_digit := mod(final_sum, 10);

      last_digit := to_char(10 - final_sum_last_digit);
      if(length(last_digit) = 2) then
              last_digit := substr(last_digit,2,1);
      end if;

      if(last_digit <> check_digit) then
              return 0;
      end if;
      return 1;
 exception
   when others then
        return 0;

 end modulus_13_test;

-- Function to check id ID number and Data of birth of a person.
--
Function check_id_dob(p_id_number in number,p_dob in date) return number
is
-- return 0 if false, else return 1

        id_six_nos number(6);
        dob_six_nos varchar2(6);
    begin
        if (p_id_number is NULL  OR p_dob is NULL) OR (length(p_id_number) <> 13) then
           return 0;
        else
-- Get the first six characters of the ID number
-- Get the data of birth in YYMMDD format and compare

        id_six_nos := substr(p_id_number,1,6);

        dob_six_nos := to_char(p_dob,'YYMMDD');
           if id_six_nos <> to_number(dob_six_nos) then
              return 0;
           else
              return 1;
           end if;
        end if;

 exception

   when others then
        raise_application_error(-20102,'PAY_ZA_EOY_VAL.CHECK_ID_DOB exception');


  end check_id_dob;

-- Function to check id ID number and Data of birth of a person.
-- From Tax Year 2010 onwards
Function check_id_dob
( p_id_number  in varchar2
 ,p_dob        in date
 ,p_new_format in varchar2) return number
is
-- return 0 if false, else return 1

        id_six_nos varchar2(6);
        dob_six_nos varchar2(6);
    begin

        id_six_nos := substr(p_id_number,1,6);

        dob_six_nos := to_char(p_dob,'YYMMDD');
           if id_six_nos <> dob_six_nos then
              return 0;
           else
              return 1;
           end if;
--        end if;

 exception

   when others then
        raise_application_error(-20102,'PAY_ZA_EOY_VAL.CHECK_ID_DOB exception');

  end check_id_dob;


-- Function to check unique IRP5 number
 Function check_IRP5_no( p_payroll_id   in Number
                        ,p_irp5no      in varchar2
                        ,p_tax_year    in varchar2) return Number
-- return 0 if false, else return 1
  is
  v_count number;
  v_tax_start_date varchar2(20);
  v_tax_end_date varchar2(20);
  begin
   If (p_payroll_id is NULL) or (p_irp5no is NULL) or (p_tax_year is NULL) then
     return 0;
   else

      get_tax_start_end_dates(p_payroll_id,p_tax_year,v_tax_start_date,v_tax_end_date);
   --removed the sub query for selecting the max effective date ,since the date tracked
   --checks would anyway get the latest payroll details

      select count(*)
      into v_count
      from pay_all_payrolls_f pap,
      hr_soft_coding_keyflex scl
      where pap.business_group_id = (select pap2.business_group_id from pay_all_payrolls_f pap2 where pap2.payroll_id=p_payroll_id and rownum=1)
      and pap.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
      and scl.segment8 = p_irp5no
      and to_date(v_tax_end_date,'DD-MM-YYYY') between pap.effective_start_date and pap.effective_end_date;
      if v_count > 1 then
         return 0;
      else
         return 1;
      end if;
    end if;

   exception

   when others then
        raise_application_error(-20103,'PAY_ZA_EOY_VAL.CHECK_IRP5_NO exception');


   end check_IRP5_no;

-- Prcoedure to get the Tax Year Start Date and End date
   Procedure get_tax_start_end_dates
     (p_payroll_id                    in     number
     ,p_tax_year                      in     varchar2
     ,p_tax_start_date                out nocopy    varchar2
     ,p_tax_end_date                  out nocopy    varchar2) as
   begin

      select to_char(min(start_date),'dd-mon-yyyy'),to_char(max(end_date),'dd-mon-yyyy')
      into   p_tax_start_date,p_tax_end_date
      from   per_time_periods
      where  payroll_id = p_payroll_id
             and prd_information1 = p_tax_year;

   exception

      when others then
        raise_application_error(-20104,'PAY_ZA_EOY_VAL.GET_TAX_START_END_DATE exception');


   end get_tax_start_end_dates;



-- Procedure to populate the validation messages form FND_NEW_MESSAGES
   Procedure populate_messages(c_name OUT NOCOPY VARCHAR2,
                                        c_ref_no OUT NOCOPY VARCHAR2,
                                        c_ref_no_invalid OUT NOCOPY VARCHAR2,
                                        c_person_name OUT NOCOPY VARCHAR2,
                                        c_telephone OUT NOCOPY VARCHAR2,
                                        c_add_line1 OUT NOCOPY VARCHAR2,
                                        c_pcode OUT NOCOPY VARCHAR2,
                                        c_pcode1 OUT NOCOPY VARCHAR2,
                                        trade_name OUT NOCOPY VARCHAR2,
                                        paye_no OUT NOCOPY VARCHAR2,
                                        paye_no1 OUT NOCOPY VARCHAR2,
                                        address OUT NOCOPY VARCHAR2,
                                        pcode OUT NOCOPY VARCHAR2,
                                        pcode1 OUT NOCOPY VARCHAR2,
                                        payroll_number OUT NOCOPY VARCHAR2,
                                        nature_entered OUT NOCOPY VARCHAR2,
                                        id_passport OUT NOCOPY VARCHAR2,
                                        no_id_passport OUT NOCOPY VARCHAR2,
                                        sur_trade_name OUT NOCOPY VARCHAR2,
                                        cc_no OUT NOCOPY VARCHAR2,
                                        sur_first_name OUT NOCOPY VARCHAR2,
                                        M_sur_fname OUT NOCOPY VARCHAR2,
                                        M_id_pno_fname OUT NOCOPY VARCHAR2,
                                        M_cc_trade_name OUT NOCOPY VARCHAR2,
                                        M_lname_fname_cc OUT NOCOPY VARCHAR2,
                                        invalid_it_no OUT NOCOPY VARCHAR2,
                                        birth_id OUT NOCOPY VARCHAR2,
                                        legal_entity  OUT NOCOPY VARCHAR2,
                                        no_site_paye_split OUT NOCOPY VARCHAR2,
                                        neg_bal_not_alwd OUT NOCOPY VARCHAR2,
                                        clearance_num OUT NOCOPY VARCHAR2,
                                        terminate_emp OUT NOCOPY VARCHAR2,
                                        town_city OUT NOCOPY VARCHAR2,
                                        employer_name OUT NOCOPY VARCHAR2)   as
   begin
        -- File header record messages
        c_name:=fnd_message.get_string('PAY','PY_ZA_ENTER_CREATOR');
        c_ref_no:=fnd_message.get_string('PAY','PY_ZA_ENTER_CREATOR_REF_NO');
        c_ref_no_invalid:=fnd_message.get_string('PAY','PY_ZA_INVALID_CREATOR_REF_NO');
        c_person_name:=fnd_message.get_string('PAY','PY_ZA_ENTER_CONTACT_NAME');
        c_telephone:=fnd_message.get_string('PAY','PY_ZA_ENTER_CONTACT_PHONE_NO');
        c_add_line1:=fnd_message.get_string('PAY','PY_ZA_ENTER_ADDRESS_LINE1');
        c_pcode:=fnd_message.get_string('PAY','PY_ZA_ENTER_POSTAL_CODE');
        c_pcode1:=fnd_message.get_string('PAY','PY_ZA_INVALID_POSTAL_CODE');

        -- Employer validation  messages
        trade_name:=fnd_message.get_string('PAY','PY_ZA_ENTER_TRADING_NAME');
        paye_no:=fnd_message.get_string('PAY','PY_ZA_ENTER_TAX_REF_NO');
        paye_no1:=fnd_message.get_string('PAY','PY_ZA_INVALID_TAX_REF_NO');
        address:=c_add_line1;
        pcode:=  c_pcode;
        pcode1:=c_pcode1;
        --Added for TYE09
        employer_name :=fnd_message.get_string('PAY','PY_ZA_INVALID_EMPLOYER_NAME');
        -- Payroll validation message
        payroll_number:=fnd_message.get_string('PAY','PY_ZA_INVALID_IRP5_NO');

        --Employee validation messages
        nature_entered:=fnd_message.get_string('PAY','PY_ZA_ENTER_NATURE_PERSON');
        id_passport:=fnd_message.get_string('PAY','PY_ZA_ENTER_NAT_AC_ID_PASSNO');
        no_id_passport:=fnd_message.get_string('PAY','PY_ZA_ENTER_NAT_B_ID_PASSNO');
        sur_trade_name:=fnd_message.get_string('PAY','PY_ZA_ENTER_NAT_DEFGHK_TRADE');
        cc_no:=fnd_message.get_string('PAY','PY_ZA_ENTER_NAT_DEHK_CC_NO');

        sur_first_name:=fnd_message.get_string('PAY','PY_ZA_ENTER_NAT_ABC_S_F_NAME');
        M_sur_fname:=fnd_message.get_string('PAY','PY_ZA_ENTER_NAT_M_S_F_NAME');
        M_id_pno_fname:=fnd_message.get_string('PAY','PY_ZA_ENTER_NAT_M_IDPNO_SF_NAM');
        M_cc_trade_name:=fnd_message.get_string('PAY','PY_ZA_ENTER_NAT_M_CC_NO');

        M_lname_fname_cc:=fnd_message.get_string('PAY','PY_ZA_ENTER_NAT_M_FM_NAME_CCNO');

        invalid_it_no:=fnd_message.get_string('PAY','PY_ZA_INVALID_IT_TAX_NO');
        birth_id:=fnd_message.get_string('PER','HR_ZA_INVALID_NI_DOB');
        legal_entity:=fnd_message.get_string('PAY','PY_ZA_ENTER_LEGAL_ENTITY');

        no_site_paye_split:=fnd_message.get_string('PAY','PY_ZA_NO_SITE_PAYE_SPLIT');
        neg_bal_not_alwd :=fnd_message.get_string('PAY','PY_ZA_NEG_BAL_NOT_ALWD');
        clearance_num:=fnd_message.get_string('PAY','PA_ZA_ENTER_CLEARANCE_NUM');
        terminate_emp:=fnd_message.get_string('PAY','PA_ZA_TERMINATE_EMP');
        town_city := fnd_message.get_string('PAY','PAY_ZA_ENTER_TOWN_CITY');

   exception

      when others then
        raise_application_error(-20105,'PAY_ZA_EOY_VAL.POPULATE_MESSAGES exception');


   end populate_messages;

-- function to convert the decimal separator if it is ',' Eg 123,45 => 123.45
function decimal_character_conversion ( amount_char in varchar2) return varchar2 is
    amount_num number ;
    amount_ret varchar2(100) ;
begin
    amount_num := to_number(amount_char) ;
    return amount_char ;
exception
    when others then
       amount_ret := replace(amount_char,',','.') ;
       return amount_ret ;
end decimal_character_conversion ;

-- for TYE 2008 write the exceptions to the log file
PROCEDURE VALIDATE_TYE_DATA (
                      errbuf                     out nocopy varchar2,
                      retcode                    out nocopy number,
                      p_payroll_action_id        in pay_payroll_actions.payroll_action_id%type,
                      p_tax_yr_start_date               IN DATE,
                      p_tax_yr_end_date                 IN DATE
                      )is
    /* Cursor to select all Income Sars Codes which have negative balances*/
   g_default_clrno CONSTANT VARCHAR2(11) := '99999999999' ;
   g_default_dirno CONSTANT VARCHAR2(7) := 'Default' ;
   g_application_id CONSTANT NUMBER := 801 ;

   CURSOR negative_amt_check_cur(p_asgn_action_id pay_assignment_actions.assignment_action_id%TYPE) IS
     select irp5.code,
            sum(trunc(to_number(pay_za_eoy_val.decimal_character_conversion(nvl(arc.value,0)))))  value
     FROM pay_za_irp5_bal_codes irp5,
       ff_archive_items      arc,
       ff_database_items     dbi
     WHERE     dbi.user_entity_id = arc.user_entity_id
        and    irp5.user_name = dbi.user_name
        AND    arc.context1 = p_asgn_action_id
        and    (( irp5.balance_sequence = 1  and
                 (
                 (irp5.code BETWEEN 3601 AND 3607)
                  OR
                 (irp5.code BETWEEN 3609 AND 3613)
                 or
                 (irp5.code BETWEEN 3615 AND 3617 ) -- 3608 and 3614 are LMPSM balance
                 or
                 (irp5.code BETWEEN 3651 AND 3667)
                 OR
                 (irp5.code BETWEEN 3701 AND 3706)
                 OR
                 (irp5.code BETWEEN 3708 AND 3717) -- 3707 and 3718 are LMPSM balances
                 OR
                 (irp5.code BETWEEN 3751 AND 3768)
                 or
                 (irp5.code BETWEEN 3801 and 3810)
                 or
                 (irp5.code BETWEEN 3851 and 3860)
                 or
                 (irp5.code BETWEEN 3813 and 3863)
                 OR                                -- 3901 to 3907 are LMPSM balances
                 (irp5.code = 3908)
                 OR
                 (irp5.code BETWEEN 3951 and 3957)
                 or
                 (irp5.code BETWEEN 3695 and 3699)
                 OR                                --  4001 to 4004, 4006, 4007 are Deduction balances
                 (irp5.code = 4005 )
                 or
                 (irp5.code = 4018)
                 or
                 (irp5.code BETWEEN 4024 and 4025)
                 or
                 (irp5.code BETWEEN 4101 and 4103)
                 or
                 (irp5.code BETWEEN 4472 and 4474)
                 or
                 (irp5.code BETWEEN 4485 and 4487)
                 or
                 (irp5.code = 4493)
                )
              )
              OR
              ( irp5.code = 4005 AND irp5.balance_sequence = 2))    --Added for Bug 8213478
     group by irp5.code
     HAVING     sum(trunc(to_number(pay_za_eoy_val.decimal_character_conversion(nvl(arc.value,0))))) < 0 ;

     /* Cursor to fetch all LumpSum Balance Sars Codes ( For Main Certificate) which have neagtive amounts*/
     CURSOR fetch_lmpsm_bal_cur ( p_asgn_action_id pay_assignment_actions.assignment_action_id%TYPE) is
     select irp5.code,
            sum(trunc(to_number(pay_za_eoy_val.decimal_character_conversion(nvl(arc.value,0)))))  value
     FROM pay_za_irp5_bal_codes irp5,
       ff_archive_items      arc,
       ff_database_items     dbi,
       ff_archive_item_contexts faic2,
       ff_contexts ffc2
     WHERE     irp5.code IN (3608, 3614, 3707, 3718, 3901, 3902, 3903, 3904, 3905, 3906, 3907, 3909, 3915, 3920)
        AND    irp5.balance_sequence = 3
        AND    irp5.user_name = dbi.user_name
        AND    dbi.user_entity_id = arc.user_entity_id
        AND    arc.context1 = p_asgn_action_id
        AND    faic2.archive_item_id = arc.archive_item_id
        AND    ffc2.context_id = faic2.context_id
        AND    ffc2.context_name = 'SOURCE_TEXT'
        AND    faic2.CONTEXT = 'To Be Advised'
     group by irp5.code
     HAVING sum(trunc(to_number(pay_za_eoy_val.decimal_character_conversion(nvl(arc.value,0)))))<0 ;

     /* Cursor to fetch The -ve Lump Sum balances with Directive Number other than Default
     That is checking the Lump Sum Certificate balances */
     CURSOR get_lmpsm_crt_bal (p_asg_act_id pay_assignment_actions.assignment_action_id%TYPE) is
     select sum(trunc(to_number(pay_za_eoy_val.decimal_character_conversion(arc.value)))) value
              , faic2.CONTEXT  Tax_Directive_Number
              , irp5.code      code
         from   pay_za_irp5_bal_codes irp5,
                ff_archive_items      arc,
                ff_database_items     dbi,
                ff_archive_item_contexts faic2,
                ff_contexts ffc2
         where  arc.context1 in (select ch.assignment_action_id
                                 from pay_assignment_actions main
                                 ,    pay_assignment_actions ch
                                 where main.assignment_action_id = p_asg_act_id
                                 and   ch.payroll_action_id     = main.payroll_action_id
                                 and   ch.assignment_action_id < main.assignment_action_id
                                 AND   ch.assignment_id        = main.assignment_id)
         and
         (
            arc.value is not null
            or
            (
               arc.value is not null
               and arc.value <> 0
            )
         )
         and    dbi.user_entity_id = arc.user_entity_id
         and    irp5.code IN (3608, 3614, 3707, 3718, 3901, 3902, 3903, 3904, 3905, 3906, 3907, 3909, 3915, 3920)
         AND    irp5.balance_sequence = 3
         AND    dbi.user_name = irp5.user_name
         AND    faic2.archive_item_id = arc.archive_item_id
         AND    ffc2.context_id = faic2.context_id
         AND    ffc2.context_name = 'SOURCE_TEXT'
         group BY faic2.CONTEXT
                , irp5.code
          HAVING  sum(trunc(to_number(pay_za_eoy_val.decimal_character_conversion(arc.value)))) < 0;


     CURSOR fetch_deduction_bal_cur ( p_asgn_action_id pay_assignment_actions.assignment_action_id%type) IS
     select irp5.code ,
            faic2.CONTEXT clearance_num,
            sum(trunc(to_number(pay_za_eoy_val.decimal_character_conversion(nvl(arc.value,0)))))  value
     FROM pay_za_irp5_bal_codes irp5,
       ff_archive_items      arc,
       ff_database_items     dbi,
       ff_archive_item_contexts faic2,
       ff_contexts ffc2
     WHERE     irp5.code IN (4001, 4002, 4003, 4004, 4006, 4007)
        AND    irp5.balance_sequence = 1
        AND    irp5.user_name = dbi.user_name
        AND    dbi.user_entity_id = arc.user_entity_id
        AND    arc.context1 = p_asgn_action_id
        AND    faic2.archive_item_id = arc.archive_item_id
        AND    ffc2.context_id = faic2.context_id
        AND    ffc2.context_name = 'SOURCE_NUMBER'
     group by irp5.code,
              faic2.CONTEXT
     HAVING (sum(trunc(to_number(pay_za_eoy_val.decimal_character_conversion(nvl(arc.value,0)))))<0)
         OR (faic2.CONTEXT = g_default_clrno
             and sum(trunc(to_number(pay_za_eoy_val.decimal_character_conversion(nvl(arc.value,0))))) <> 0)
            --added above condition for Bug 7214056
     UNION /*Added for Bug 8406456 to report negative amount in code 4030. This deduction doesnt have clearance number */
     select irp5.code ,
            '11111111111' clearance_num,
            sum(trunc(to_number(pay_za_eoy_val.decimal_character_conversion(nvl(arc.value,0)))))  value
     FROM pay_za_irp5_bal_codes irp5,
       ff_archive_items      arc,
       ff_database_items     dbi
     WHERE     irp5.code IN (4030)
        AND    irp5.balance_sequence = 1
        AND    irp5.user_name = dbi.user_name
        AND    dbi.user_entity_id = arc.user_entity_id
        AND    arc.context1 = p_asgn_action_id
     group by irp5.code
     HAVING (sum(trunc(to_number(pay_za_eoy_val.decimal_character_conversion(nvl(arc.value,0)))))<0);

     /*Cursor to fetch Medical Aid Code Values/Lump Sums for Cross Validation*/
     CURSOR fetch_med_code_bal_cur ( p_asgn_action_id pay_assignment_actions.assignment_action_id%TYPE) IS
     select irp5.code,
            sum(trunc(to_number(pay_za_eoy_val.decimal_character_conversion(nvl(arc.value,0)))))  value
     FROM pay_za_irp5_bal_codes irp5,
       ff_archive_items      arc,
       ff_database_items     dbi
     WHERE   ((irp5.code IN (3810, 3813, 4005, 4024, 4025, 4474, 4485, 4486, 4493, 4030) --Added 4474 and 4493 for TYE09
                   AND
               irp5.balance_sequence = 1
               )
             OR      -- Added for Bug 8213478
              ( irp5.code = 4005 AND irp5.balance_sequence = 2
              )
              )
        AND    irp5.user_name = dbi.user_name
        AND    dbi.user_entity_id = arc.user_entity_id
        AND    arc.context1 = p_asgn_action_id
     group by irp5.code;


     /* Cursor to fetch all assignment_id and max(assignment_action_id) for given payroll_action_id */
     CURSOR asgn_for_payroll_action_cur IS
        SELECT assignment_id,
               max(assignment_action_id) assignment_action_id  -- max assignment_action_id relates to Main Certificate
        FROM   pay_assignment_actions
        WHERE  payroll_action_id = p_payroll_action_id
        GROUP BY assignment_id ;

      /*Cursor to fetch assignment_action_id corresponding to payroll run for given assignment_id and that tax year*/
      CURSOR payroll_asgn_ac_id_cur(p_asgn_id pay_assignment_actions.assignment_id%type,
                                    p_start_date DATE,
                                    p_end_date DATE) IS
         select paa.assignment_action_id
           from   pay_action_contexts    pac,
                  pay_assignment_actions paa,
                  pay_payroll_actions    ppa,
                  ff_contexts            ffc
           where  paa.assignment_id = p_asgn_id
             and  paa.payroll_action_id = ppa.payroll_action_id
             and  ppa.action_type in ('R', 'Q','B')
             AND  pac.assignment_Action_id = paa.assignment_action_id
             And  pac.context_value = g_default_clrno
             and  ffc.context_name = 'SOURCE_NUMBER'
             and  ffc.context_id = pac.context_id
             and ppa.effective_date >= p_start_date
             and ppa.effective_date <= p_end_date;

        /*Cursor the fetch all element names which have missing clearance numbers for given assignment_id*/
        CURSOR elem_names_cur (p_asgn_ac_id pay_assignment_actions.assignment_action_id%type)IS
                Select  element_name
                FROM    pay_assignment_actions paa,
                        pay_payroll_actions ppa,
                        pay_element_types_f pet,
                        pay_input_values_f piv,
                        pay_run_results prr,
                        pay_run_result_values prv
                Where   paa.assignment_action_id = p_asgn_ac_id
                   and  prr.assignment_Action_id = paa.assignment_action_id
                   and  pet.element_type_id     = prr.element_type_id
                   and  piv.element_type_id      = pet.element_type_id
                   and  piv.name                 = 'Clearance Number'
                   and  prv.run_result_id    = prr.run_result_id
                   and  prv.input_value_id   = piv.input_value_id
                   and  prv.RESULT_VALUE     = g_default_clrno
                   and  ppa.payroll_action_id    = paa.payroll_action_id
                   and  ppa.effective_date      between pet.effective_start_date and pet.effective_end_date
                   and  ppa.effective_date      between piv.effective_start_date and piv.effective_end_date ;

/*To fetch PKG balance feed for employee not on pension basis */
       CURSOR fetch_pkg_balances( p_asgn_action_id pay_assignment_actions.assignment_action_id%type) IS
       select irp5.code,
              irp5.full_balance_name bal_name,
              irp5.balance_type_id bal_type_id,
              trunc(to_number(pay_za_eoy_val.decimal_character_conversion(nvl(arc.value,0))))  value
       FROM pay_za_irp5_bal_codes irp5,
         ff_archive_items      arc,
         ff_database_items     dbi,
         per_assignment_extra_info paei,
         pay_assignment_actions paa
       WHERE     dbi.user_name in
       (
          'A_ANNUAL_ASSET_PURCHASED_AT_REDUCED_VALUE_PKG_ASG_TAX_YTD',
          'A_ASSET_PURCHASED_AT_REDUCED_VALUE_PKG_ASG_TAX_YTD',
          'A_USE_OF_MOTOR_VEHICLE_PKG_ASG_TAX_YTD',
          'A_RIGHT_OF_USE_OF_ASSET_PKG_ASG_TAX_YTD',
          'A_MEALS_REFRESHMENTS_AND_VOUCHERS_PKG_ASG_TAX_YTD',
          'A_FREE_OR_CHEAP_ACCOMMODATION_PKG_ASG_TAX_YTD',
          'A_FREE_OR_CHEAP_SERVICES_PKG_ASG_TAX_YTD',
          'A_LOW_OR_INTEREST_FREE_LOANS_PKG_ASG_TAX_YTD',
          'A_ANNUAL_PAYMENT_OF_EMPLOYEE_DEBT_PKG_ASG_TAX_YTD',
          'A_PAYMENT_OF_EMPLOYEE_DEBT_PKG_ASG_TAX_YTD',
          'A_ANNUAL_BURSARIES_AND_SCHOLARSHIPS_PKG_ASG_TAX_YTD',
          'A_BURSARIES_AND_SCHOLARSHIPS_PKG_ASG_TAX_YTD',
          'A_MEDICAL_AID_PAID_ON_BEHALF_OF_EMPLOYEE_PKG_ASG_TAX_YTD',
          'A_MED_COSTS_PD_BY_ER_IRO_EE_FAMILY_PKG_ASG_TAX_YTD',
          'A_ANNUAL_MED_COSTS_PD_BY_ER_IRO_EE_FAMILY_PKG_ASG_TAX_YTD',
          'A_MED_COSTS_PD_BY_ER_IRO_OTHER_PKG_ASG_TAX_YTD',
          'A_ANNUAL_MED_COSTS_PD_BY_ER_IRO_OTHER_PKG_ASG_TAX_YTD',
          'A_TAXABLE_INCOME_PKG_ASG_TAX_YTD',
          'A_TAXABLE_PENSION_PKG_ASG_TAX_YTD',
          'A_ANNUAL_BONUS_PKG_ASG_TAX_YTD',
          'A_TAXABLE_ANNUAL_PAYMENT_PKG_ASG_TAX_YTD',
          'A_ANNUAL_COMMISSION_PKG_ASG_TAX_YTD',
          'A_COMMISSION_PKG_ASG_TAX_YTD',
          'A_ANNUAL_OVERTIME_PKG_ASG_TAX_YTD',
          'A_OVERTIME_PKG_ASG_TAX_YTD',
          'A_ANNUITY_FROM_RETIREMENT_FUND_PKG_ASG_TAX_YTD',
          'A_PURCHASED_ANNUITY_TAXABLE_PKG_ASG_TAX_YTD',
          'A_ANNUAL_RESTRAINT_OF_TRADE_PKG_ASG_TAX_YTD',
          'A_RESTRAINT_OF_TRADE_PKG_ASG_TAX_YTD',
          'A_ANNUAL_INDEPENDENT_CONTRACTOR_PAYMENTS_PKG_ASG_TAX_YTD',
          'A_INDEPENDENT_CONTRACTOR_PAYMENTS_PKG_ASG_TAX_YTD',
          'A_ANNUAL_LABOUR_BROKER_PAYMENTS_PKG_ASG_TAX_YTD',
          'A_LABOUR_BROKER_PAYMENTS_PKG_ASG_TAX_YTD',
          'A_TRAVEL_ALLOWANCE_PKG_ASG_TAX_YTD',
          'A_TAXABLE_REIMBURSIVE_TRAVEL_PKG_ASG_TAX_YTD',
          'A_TAXABLE_SUBSISTENCE_PKG_ASG_TAX_YTD',
          'A_ENTERTAINMENT_ALLOWANCE_PKG_ASG_TAX_YTD',
          'A_PUBLIC_OFFICE_ALLOWANCE_PKG_ASG_TAX_YTD',
          'A_TOOL_ALLOWANCE_PKG_ASG_TAX_YTD',
          'A_COMPUTER_ALLOWANCE_PKG_ASG_TAX_YTD',
          'A_TELEPHONE_ALLOWANCE_PKG_ASG_TAX_YTD',
          'A_OTHER_TAXABLE_ALLOWANCE_PKG_ASG_TAX_YTD',
          'A_TAXABLE_SUBSISTENCE_ALLOWANCE_FOREIGN_TRAVEL_PKG_ASG_TAX_YTD',
          'A_EE_BROADBASED_SHARE_PLAN_PKG_ASG_TAX_YTD',
          'A_OTHER_LUMP_SUM_TAXED_AS_ANNUAL_PAYMENT_PKG_ASG_TAX_YTD',
          'A_MEDICAL_AID_PAID_ON_BEHALF_OF_EMPLOYEE_PKG_ASG_TAX_YTD',
          'A_MED_COSTS_DMD_PD_BY_EE_EE_FAMILY_PKG_ASG_TAX_YTD',
          'A_ANNUAL_MED_COSTS_DMD_PD_BY_EE_EE_FAMILY_PKG_ASG_TAX_YTD',
          'A_MED_COSTS_DMD_PD_BY_EE_OTHER_PKG_ASG_TAX_YTD',
          'A_ANNUAL_MED_COSTS_DMD_PD_BY_EE_OTHER_PKG_ASG_TAX_YTD'
       )
          AND    irp5.user_name = dbi.user_name
          AND    dbi.user_entity_id = arc.user_entity_id
          AND    paei.assignment_id = paa.assignment_id
          AND    arc.context1 = p_asgn_action_id
          AND    arc.context1 = paa.assignment_action_id
          AND    paei.AEI_INFORMATION8 <> '1' -- 'Pension Basis: Fixed Percentage of Specific Income
          AND    paei.information_type = 'ZA_SPECIFIC_INFO'
          AND    pay_za_eoy_val.decimal_character_conversion(nvl(arc.value,0)) <> '0';

/*Fetch elements feeding to PKG classification */
      CURSOR fetch_pkg_ele( p_asgn_action_id pay_assignment_actions.assignment_action_id%type, p_bal_typ_id pay_balance_types.balance_type_id%type) IS
      SELECT  ELEM.element_name element_name,
            sum(trunc(to_number(pay_za_eoy_val.decimal_character_conversion(nvl(TARGET.RESULT_VALUE,0)))))
      from   pay_balance_feeds_f               FEED
           , pay_run_result_values             TARGET
           , pay_run_results                   RR
           , per_time_periods                  PPTP
           , per_time_periods                  BPTP
           , pay_payroll_actions               PACT
           , pay_assignment_actions            ASSACT
           , pay_payroll_actions               BACT
           , pay_assignment_actions            BAL_ASSACT
          , pay_element_types_f               ELEM
       where BAL_ASSACT.assignment_action_id = p_asgn_action_id
         and BAL_ASSACT.payroll_action_id    = BACT.payroll_action_id
         and FEED.input_value_id             = TARGET.input_value_id
         and TARGET.run_result_id            = RR.run_result_id
         and RR.assignment_action_id         = ASSACT.assignment_action_id
         + decode(PPTP.year_number, 0, 0, 0)
         and ASSACT.payroll_action_id        = PACT.payroll_action_id
         and PACT.effective_date       between FEED.effective_start_date
                                           and FEED.effective_end_date
         and BPTP.payroll_id                 = BACT.payroll_id
         and PPTP.payroll_id                 = PACT.payroll_id
         and nvl(BACT.date_earned,BACT.effective_date)
                                       between BPTP.start_date and BPTP.end_date
         and PACT.date_earned          between PPTP.start_date and PPTP.end_date
         and RR.status                      in ('P','PA')
         AND ELEM.element_type_id = RR.element_type_id
         and PPTP.prd_information1           = BPTP.prd_information1
         and ASSACT.action_sequence         <= BAL_ASSACT.action_sequence
         and ASSACT.assignment_id            = BAL_ASSACT.assignment_id
         AND feed.BALANCE_TYPE_ID            = p_bal_typ_id
         GROUP BY ELEM.element_name
         HAVING sum(trunc(to_number(pay_za_eoy_val.decimal_character_conversion(nvl(TARGET.RESULT_VALUE,0))))) <> 0;


         TYPE med_code_tab IS TABLE OF NUMBER Index BY PLS_INTEGER;
         med_code_t med_code_tab ;

         TYPE lmpsm_code_tab IS TABLE OF number Index BY VARCHAR2(50);  --Index by Code||Tax Directive Number
         retiremnt_fund_lmpsum lmpsm_code_tab;


        l_empno per_all_people_f.employee_number%type;
        l_assgno per_all_assignments_f.assignment_number%type;
        l_tax_ytd ff_archive_items.value%TYPE ;   -- to save Tax paid by employee during tax year
        l_site ff_archive_items.value%TYPE ;
        l_paye ff_archive_items.value%TYPE ;
        l_msgtext varchar2(2000);
        l_missing_clrno_flag VARCHAR2(1) ;
        l_count NUMBER :=0;
        l_count1 NUMBER :=0;
        l_65date    date;
        l_65flag NUMBER :=0; --Flag indicating whether employee is greater than 65 yr or not
        l_3902 NUMBER :=0; --Flag indicating whether 3902/3904 is present for the employee
        l_tax_dir_num varchar2(50):='';
        a varchar2(50):='';

       --Changes done for Bug No 6749775 and
        CURSOR emp_number_cur ( asgn_ac_id pay_assignment_actions.assignment_action_id%TYPE) IS
        SELECT  per.employee_number empno, asgn2.assignment_number assgno,
                add_months(per.date_of_birth,780) dateb--Added for TYE09
                FROM pay_assignment_actions paa,
                per_all_assignments_f asgn2,
                per_all_people_f per,
                pay_payroll_actions ppa
         WHERE paa.assignment_action_id = asgn_ac_id
         AND ppa.payroll_action_id    = paa.payroll_action_id
         AND asgn2.assignment_id      = paa.assignment_id
         AND per.person_id            = asgn2.person_id
         AND asgn2.effective_start_date =
           ( select max(paf2.effective_start_date)
             from   per_assignments_f paf2
             where paf2.effective_start_date <= ppa.effective_date
             and    paf2.assignment_id         = asgn2.assignment_id
          )
        AND per.effective_start_date =
         ( select max(per2.effective_start_date)
           from   per_all_people_f per2
           where per2.effective_start_date <= ppa.effective_date
           and    per2.person_id = per.person_id
          );
          --End changes for Bug No 6749775

     /* Cursor to check sanity of 3915 and 4115 codes */

     CURSOR chk_rtrmnt_fnd_cur ( p_asgn_action_id pay_assignment_actions.assignment_action_id%TYPE) IS
      SELECT irp5.code, sum(trunc(to_number(pay_za_eoy_val.decimal_character_conversion(nvl(arc.value,0))))) value,
             faic2.CONTEXT Tax_Directive_Number
      FROM ff_archive_items arc,
           ff_database_items dbi,
           pay_za_irp5_bal_codes irp5,
           ff_archive_item_contexts faic2,
           ff_contexts ffc2
      WHERE arc.user_entity_id = dbi.user_entity_id
        and irp5.user_name = dbi.user_name
        and arc.context1 in (select ch.assignment_action_id
                                 from pay_assignment_actions main
                                 ,    pay_assignment_actions ch
                                 where main.assignment_action_id = p_asgn_action_id
                                 and   ch.payroll_action_id     = main.payroll_action_id
                                 and   ch.assignment_action_id <= main.assignment_action_id
                                 AND   ch.assignment_id        = main.assignment_id)
        and irp5.code in (3915,4115,3920)  --Modified for TYS2010 Bug 8406456
        and faic2.archive_item_id = arc.archive_item_id
        and ffc2.context_id = faic2.context_id
        and ffc2.context_name = 'SOURCE_TEXT'
      GROUP BY irp5.code,faic2.CONTEXT ;

      /*Added for TYS2010 */
      CURSOR fetch_lmpsm_code_bal_cur ( p_asgn_action_id pay_assignment_actions.assignment_action_id%TYPE) IS
      SELECT irp5.code, sum(trunc(to_number(pay_za_eoy_val.decimal_character_conversion(nvl(arc.value,0))))) value,
             faic2.CONTEXT Tax_Directive_Number
      FROM ff_archive_items arc,
           ff_database_items dbi,
           pay_za_irp5_bal_codes irp5,
           ff_archive_item_contexts faic2,
           ff_contexts ffc2
      WHERE arc.user_entity_id = dbi.user_entity_id
        and irp5.user_name = dbi.user_name
        and arc.context1 in (select ch.assignment_action_id
                                 from pay_assignment_actions main
                                 ,    pay_assignment_actions ch
                                 where main.assignment_action_id = p_asgn_action_id
                                 and   ch.payroll_action_id     = main.payroll_action_id
                                 and   ch.assignment_action_id <= main.assignment_action_id
                                 AND   ch.assignment_id        = main.assignment_id)
        and irp5.code in (3902,3904,3920)
        and irp5.balance_sequence = 3
        and faic2.archive_item_id = arc.archive_item_id
        and ffc2.context_id = faic2.context_id
        and ffc2.context_name = 'SOURCE_TEXT'
      GROUP BY irp5.code,faic2.CONTEXT ;

   begin
    retcode := 0;
--    hr_utility.trace_on(null,'ZATYEVL');
    FND_FILE.PUT_LINE(FND_FILE.LOG,'In validate_tye_data');
    FND_FILE.PUT_LINE(FND_FILE.LOG,'p_payroll_action_id    :' || p_payroll_action_id);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Inside validate_tye_data');

     /*Loop through all Assignments for given payroll_action_id*/
    FOR asgn IN asgn_for_payroll_action_cur
    LOOP
    l_count:=0;
    l_count1:=0;
    l_65flag:=0;
    l_3902:=0;
        /* Fetch Employee_number */
--     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Assignment Action Id : ' || asgn.assignment_action_id);
--     FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
--     FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
    FOR emp_num IN emp_number_cur(asgn.assignment_action_id)
    LOOP
        l_empno := emp_num.empno ;
        l_assgno:= emp_num.assgno;
        l_65date:=emp_num.dateb;
--        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Employee Number : ' || l_empno);
    END LOOP;

    --Added for TYE09
    IF l_65date <= p_tax_yr_end_date then
         l_65flag:=1;
    END if;
         -- Rule 1) If an employee has paid any Tax during the current tax year,
         --            they must have a value in the SITE and/or PAYE balance (SITE_ASG_TAX_YTD or PAYE_ASG_TAX_YTD)
--         FND_FILE.PUT_LINE(FND_FILE.LOG, 'Rule 1) If Employee has paid tax during current tax year, he should have SITE/PAYE split');
         select pay_za_eoy_val.decimal_character_conversion(nvl(arc.value,0))
         into   l_tax_ytd
         from   ff_archive_items  arc,
                ff_database_items dbi
         where  dbi.user_name      = 'A_TAX_ASG_TAX_YTD'
         and    arc.user_entity_id = dbi.user_entity_id
         and    arc.context1       = asgn.assignment_action_id;

         IF l_tax_ytd > 0 THEN
                 select pay_za_eoy_val.decimal_character_conversion(nvl(arc.value,0))
                 into   l_site
                 from   ff_archive_items  arc,
                        ff_database_items dbi
                 where  dbi.user_name      = 'A_SITE_ASG_TAX_YTD'
                 and    arc.user_entity_id = dbi.user_entity_id
                 and    arc.context1       = asgn.assignment_action_id;

                 select pay_za_eoy_val.decimal_character_conversion(nvl(arc.value,0))
                 into   l_paye
                 from   ff_archive_items  arc,
                        ff_database_items dbi
                 where  dbi.user_name      = 'A_PAYE_ASG_TAX_YTD'
                 and    arc.user_entity_id = dbi.user_entity_id
                 and    arc.context1       = asgn.assignment_action_id;

                 IF l_site = 0  AND l_paye = 0 THEN
                      l_count:=1;
                      FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                      FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Employee Number   : ' || l_empno);
                      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Assignment Number : ' || l_assgno);
                      fnd_message.set_name('PAY', 'PY_ZA_NO_SITE_PAYE_SPLIT');
                      fnd_message.set_token('EMPNO',l_empno);
                      l_msgtext := fnd_message.get('Y');
                      FND_FILE.PUT_LINE(FND_FILE.LOG, ' Tax Amount : '||l_tax_ytd) ;
                      FND_FILE.PUT_LINE(FND_FILE.LOG, ' SITE balance : '||l_site) ;
                      FND_FILE.PUT_LINE(FND_FILE.LOG, ' PAYE balance : '||l_paye) ;
                      FND_FILE.PUT_LINE(FND_FILE.LOG, l_msgtext);
                 END IF ;
       END IF ;

       --  Rule 2) Check for Income Balances which may not contain negative amounts
--       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Rule 2) Check for Income Balances which may not contain negative amounts');
       FOR neg_amt_check IN negative_amt_check_cur(asgn.assignment_action_id)
       LOOP
              if l_count <>1 then
                l_count:=1;
                FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Employee Number   : ' || l_empno);
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Assignment Number : ' || l_assgno);
              end if;
              fnd_message.set_name('PAY', 'PY_ZA_NEG_BAL_NOT_ALWD');
              fnd_message.set_token('EMPno',l_empno);
              fnd_message.set_token('SARScode',neg_amt_check.code);
              l_msgtext := fnd_message.get('Y');
              FND_FILE.PUT_LINE(FND_FILE.LOG, l_msgtext);
       END LOOP ;

       --  Rule 3) Check Lumpsum balances which may not contain negative amounts
--       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Rule 3) Check Lumpsum balances which may not contain negative amounts');
       FOR lmpsum_bal IN fetch_lmpsm_bal_cur(asgn.assignment_action_id)
       LOOP
              if l_count <>1 then
                l_count:=1;
                FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Employee Number   : ' || l_empno);
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Assignment Number : ' || l_assgno);
              end if;
              FND_FILE.PUT_LINE(FND_FILE.LOG, 'Tax Directive Number ' || g_default_dirno);
              fnd_message.set_name('PAY', 'PY_ZA_NEG_BAL_NOT_ALWD');
              fnd_message.set_token('EMPno',l_empno);
              fnd_message.set_token('SARScode',lmpsum_bal.code);
              l_msgtext := fnd_message.get('Y');
              FND_FILE.PUT_LINE(FND_FILE.LOG, l_msgtext);
       END LOOP ;
---- Check for the Lump Sum Balances with Directive Number Other than the Defoult directive number

       FOR rec_lmpsm_crt_bal IN get_lmpsm_crt_bal(asgn.assignment_action_id)
       loop
              if l_count <>1 then
                l_count:=1;
                FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Employee Number   : ' || l_empno);
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Assignment Number : ' || l_assgno);
              end if;
              FND_FILE.PUT_LINE(FND_FILE.LOG, 'Tax Directive Number ' || rec_lmpsm_crt_bal.Tax_Directive_Number);
              fnd_message.set_name('PAY', 'PY_ZA_NEG_BAL_NOT_ALWD');
              fnd_message.set_token('EMPno',l_empno);
              fnd_message.set_token('SARScode',rec_lmpsm_crt_bal.code);
              l_msgtext := fnd_message.get('Y');
              FND_FILE.PUT_LINE(FND_FILE.LOG, l_msgtext);


       END loop;
--   End check for Lump Sum Balances with Directive Number Other than the Defoult directive number
       -- Rule 4) Check for Deduction Balances
                 -- a) may not contain negative amounts
                 -- b) Clearance number must be entered
--       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Rule 4) Check for Deduction Balances ') ;
       l_missing_clrno_flag := 'N' ;
       FOR ded_bal IN fetch_deduction_bal_cur(asgn.assignment_action_id)
       LOOP
           IF ded_bal.value <0 THEN
              if l_count <>1 then
                l_count:=1;
                FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Employee Number   : ' || l_empno);
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Assignment Number : ' || l_assgno);
              end if;
              fnd_message.set_name('PAY', 'PY_ZA_NEG_BAL_NOT_ALWD');
              fnd_message.set_token('EMPno',l_empno);
              fnd_message.set_token('SARScode',ded_bal.code);
              l_msgtext := fnd_message.get('Y');
              FND_FILE.PUT_LINE(FND_FILE.LOG, l_msgtext);
           END IF ;
           IF ded_bal.clearance_num = g_default_clrno  THEN
                 l_missing_clrno_flag := 'Y' ;
           END IF ;
       END LOOP ;

      -- If clearance number is g_default_clrno,
      --  find out the element(s) whose run_result_values contain defaults (99999999999) for 'Clearance' Input value
       IF l_missing_clrno_flag = 'Y' THEN
              /*Loop through all assignment_action_id for payroll run for given assignment*/
--              FND_FILE.PUT_LINE(FND_FILE.LOG, 'Clearance Number is default ') ;
              FOR paa IN  payroll_asgn_ac_id_cur(asgn.assignment_id, p_tax_yr_start_date, p_tax_yr_end_date)
              LOOP
                  /*Loop through all element names for which the employee has missing clearance numbers*/
--                FND_FILE.PUT_LINE(FND_FILE.LOG, 'For payroll assignment_action id : '||paa.assignment_action_id) ;
                  FOR elem_names IN elem_names_cur (paa.assignment_action_id)
                  LOOP
                      if l_count <>1 then
                        l_count:=1;
                        FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                        FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Employee Number   : ' || l_empno);
                        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Assignment Number : ' || l_assgno);
                      end if;
                      fnd_message.set_name('PAY', 'PA_ZA_ENTER_CLEARANCE_NUM');
                      fnd_message.set_token('EMPno',l_empno);
                      fnd_message.set_token('ELEMENTname',elem_names.element_name);
                      l_msgtext := fnd_message.get('Y');
                      FND_FILE.PUT_LINE(FND_FILE.LOG, l_msgtext);
                  END LOOP ;
              END LOOP ;
       END IF;

/* Loop through all the PKG balances fed through elements for employee not on PKG structure
     For Bug 7264311 */
      FOR pkg_bal IN fetch_pkg_balances(asgn.assignment_action_id)
      LOOP
            if l_count <>1 then
              l_count:=1;
              FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
              FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
              FND_FILE.PUT_LINE(FND_FILE.LOG, 'Employee Number   : ' || l_empno);
              FND_FILE.PUT_LINE(FND_FILE.LOG, 'Assignment Number : ' || l_assgno);
            end if;

            IF l_count1 <>1 then
               fnd_message.set_name('PAY', 'PY_ZA_PKG_BAL_NT_ALLOW');
               fnd_message.set_token('EMPno',l_empno);
               l_msgtext := fnd_message.get('Y');
               FND_FILE.PUT_LINE (FND_FILE.LOG,l_msgtext);
               l_count1:=1;
            END IF;

            FOR pkg_ele IN fetch_pkg_ele(asgn.assignment_action_id, pkg_bal.bal_type_id)
            LOOP
                fnd_message.set_name('PAY', 'PY_ZA_ELE_FEED_PKG_BAL');
                fnd_message.set_token('ELEMENTname',pkg_ele.element_name);
                fnd_message.set_token('BALANCEname',pkg_bal.bal_name);
                l_msgtext := fnd_message.get('Y');
                FND_FILE.PUT_LINE (FND_FILE.LOG,l_msgtext);
            END LOOP;

      END LOOP;

       -- Rule 5) Cross validation of Medical Aid Codes
       -- initialize table of medical aid codes
--       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Rule 5) Cross validation of Medical Aid Codes');
       med_code_t(3810) := 0 ;
       med_code_t(3813) := 0 ;
       med_code_t(4005) := 0 ;
       med_code_t(4024) := 0 ;
       med_code_t(4025) := 0 ;
       med_code_t(4485) := 0 ;
       med_code_t(4486) := 0 ;
       --Added for TYE09
       med_code_t(4474) := 0 ;
       med_code_t(4493) := 0 ;
       --Added for TYS09
       med_code_t(4030) := 0 ;

       FOR med_code_bal IN fetch_med_code_bal_cur(asgn.assignment_action_id)
       LOOP
           med_code_t(med_code_bal.code) := med_code_bal.value ;
       END LOOP ;

        -- Added for TYE09
        -- Code 3810 must be less than 4474
        IF med_code_t(3810) >= med_code_t(4474) AND (med_code_t(3810) <>0 OR med_code_t(4474) <>0) THEN
              if l_count <>1 then
                l_count:=1;
                FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Employee Number   : ' || l_empno);
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Assignment Number : ' || l_assgno);
              end if;
              FND_FILE.PUT_LINE(FND_FILE.LOG, 'Code 3810 must be less than Code 4474.') ;
        END IF ;


       -- 5a) Code 3813 must be equal to the sum of Codes 4024 and 4485
      IF med_code_t(3813) <> (med_code_t(4024) + med_code_t(4485))  THEN
            if l_count <>1 then
                l_count:=1;
                FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Employee Number   : ' || l_empno);
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Assignment Number : ' || l_assgno);
              end if;
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Code 3813 must be equal to the sum of Codes 4024 and 4485') ;
      END IF ;
       -- 5b) Code 4005 must be greater than zero if there is a value in 3810 or 4025
       IF (med_code_t(3810) <>0) OR (med_code_t(4025) <>0) THEN
            IF med_code_t(4005) <=0 THEN
                if l_count <>1 then
                    l_count:=1;
                    FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                    FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Employee Number   : ' || l_empno);
                    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Assignment Number : ' || l_assgno);
                end if;
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Code 4005 must be greater than zero if Code 3810 or 4025 has a value') ;
            END IF;
       END IF ;
        -- 5d) Code 4025 may not be greater than 4005
        --Modified for TYE09 so that 4025 may not be greater than 4005 except when employee >=65 yr
        IF med_code_t(4025) > med_code_t(4005) AND l_65flag=0 THEN
              if l_count <>1 then
                l_count:=1;
                FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Employee Number   : ' || l_empno);
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Assignment Number : ' || l_assgno);
              end if;
              FND_FILE.PUT_LINE(FND_FILE.LOG, 'Code 4025 must not be greater than Code 4005 except when the employee is 65 years or older.') ;
        END IF ;

        --Added for TYE09
        --Code 4025 may not be greater than 4486 except when employee >=65 yr
        IF med_code_t(4025) > med_code_t(4486) AND l_65flag=0 THEN
              if l_count <>1 then
                l_count:=1;
                FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Employee Number   : ' || l_empno);
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Assignment Number : ' || l_assgno);
              end if;
              FND_FILE.PUT_LINE(FND_FILE.LOG, 'Code 4025 must not be greater than Code 4486 except when the employee is 65 years or older.') ;
        END IF ;


        --Added for TYE09
        IF med_code_t(3810) <>0 THEN
                IF med_code_t(4474) = 0 THEN
                        if l_count <>1 then
                            l_count:=1;
                            FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                            FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Employee Number   : ' || l_empno);
                            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Assignment Number : ' || l_assgno);
                        end if;
                        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Code 4474 must be greater than zero if Code 3810 has a value.') ;
                END IF ;
        END IF ;


        -- Added for TYE09
        --Code  4474 and 3810 not allowed when 4493 is present
        IF med_code_t(4493) <> 0 THEN
                IF med_code_t(4474) <>0 OR med_code_t(3810) <>0 THEN
                        if l_count <>1 then
                            l_count:=1;
                            FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                            FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Employee Number   : ' || l_empno);
                            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Assignment Number : ' || l_assgno);
                        end if;
                        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Code 4474 or Code 3810 not allowed if Code 4493 is specified.') ;
                END IF ;
        END IF ;

       -- 5c) Code 4486 must be greater than zero if there is a value in 4025
       IF med_code_t(4025) <>0 THEN
                IF med_code_t(4486) <= 0 THEN
                        if l_count <>1 then
                            l_count:=1;
                            FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                            FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Employee Number   : ' || l_empno);
                            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Assignment Number : ' || l_assgno);
                        end if;
                        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Code 4486 must be greater than zero if Code 4025 has a value') ;
                END IF ;
       END IF ;


       --Added for TYS2010

       FOR rec_lmpsm_bal IN fetch_lmpsm_code_bal_cur(asgn.assignment_action_id)
       loop
           IF (rec_lmpsm_bal.code = 3920 and length(trunc(pay_za_eoy_val.decimal_character_conversion(rec_lmpsm_bal.value))) > 11) THEN
                if l_count <>1 then
                    l_count:=1;
                    FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                    FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Employee Number   : ' || l_empno);
                    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Assignment Number : ' || l_assgno);
                end if;
                if rec_lmpsm_bal.Tax_Directive_Number <> g_default_dirno then
                    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Tax Directive Number ' || rec_lmpsm_bal.Tax_Directive_Number);
                else
                    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Tax Directive Number ' || g_default_dirno);
                end if;
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Code 3920 must not exceed 11 digits.') ;
         END IF ;

         /*Check for l_3902 is placed for if the message is printed once, say for code 3902,
           must not display the message again if code 3904 is present */
         IF (l_3902 = 0 ) then
           IF ((rec_lmpsm_bal.code = 3902 and rec_lmpsm_bal.value <>0) OR (rec_lmpsm_bal.code = 3904 and rec_lmpsm_bal.value <>0))
               and to_number(to_char(p_tax_yr_end_date,'YYYY')) > 2009 THEN
                l_3902 :=1;
                if l_count <>1 then
                    l_count:=1;
                    FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                    FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Employee Number   : ' || l_empno);
                    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Assignment Number : ' || l_assgno);
                end if;
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Codes 3902 and 3904 are obsolete from 01-Mar-2009.') ;
                       --Codes 3902 and 3902 must not be used after tax year 2009
           end if;
        end if;
       END loop;

       --Added for TYS2010
       IF (length(trunc(pay_za_eoy_val.decimal_character_conversion(med_code_t(4030)))) > 11) THEN
                if l_count <>1 then
                    l_count:=1;
                    FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                    FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Employee Number   : ' || l_empno);
                    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Assignment Number : ' || l_assgno);
                end if;
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Code 4030 must not exceed 11 digits.') ;
       END IF ;



        -- Retirement Fund Lumpsum PAYE balance (4115) should not be present if
        -- Retirement Fund Lumpsum (3915) or retiremnt_fund_lmpsum(3920) itself is not present
/*        retiremnt_fund_lmpsum(3915) := 0 ;
        retiremnt_fund_lmpsum(4115) := 0 ;
        retiremnt_fund_lmpsum(3920) := 0 ; */
--        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Rule 6) Cross Validation of codes 3915 and 4115 ') ;
        FOR chk_rtrmnt_fnd IN chk_rtrmnt_fnd_cur(asgn.assignment_action_id)
        LOOP
            retiremnt_fund_lmpsum(chk_rtrmnt_fnd.code||chk_rtrmnt_fnd.Tax_Directive_Number) := chk_rtrmnt_fnd.value ;
        end loop;

         a:=retiremnt_fund_lmpsum.first();
         FOR i in 1..retiremnt_fund_lmpsum.count
         loop

           hr_utility.set_location('a:'||a,10);
           hr_utility.set_location('substr(a,1,4):'||substr(a,1,4),10);
           hr_utility.set_location('retiremnt_fund_lmpsum(a):'||retiremnt_fund_lmpsum(a),10);

           IF (substr(a,1,4)=4115 and retiremnt_fund_lmpsum(a) <>0  ) THEN
                l_tax_dir_num := substr(a,5);
                hr_utility.set_location('l_tax_dir_num:'||l_tax_dir_num,10);

                if ((retiremnt_fund_lmpsum.exists('3920'||l_tax_dir_num) and retiremnt_fund_lmpsum('3920'||l_tax_dir_num) <> 0)
                OR (retiremnt_fund_lmpsum.exists('3915'||l_tax_dir_num) and retiremnt_fund_lmpsum('3915'||l_tax_dir_num) <> 0)) then
                   null;
                else
                  if l_count <>1 then
                    l_count:=1;
                    FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                    FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Employee Number   : ' || l_empno);
                    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Assignment Number : ' || l_assgno);
                  end if;
                  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Tax Directive Number ' || l_tax_dir_num);
                  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Code 4115 must not be present if Codes 3915 or 3920 are not present.');
                end if;
            END IF ;
            a:=retiremnt_fund_lmpsum.next(a);
         end loop;
         retiremnt_fund_lmpsum.delete();



    END LOOP ; -- End of assignment Loop
    FND_FILE.PUT_LINE(FND_FILE.LOG,'End of log file');
    FND_FILE.PUT_LINE(FND_FILE.LOG,'               ');
--    hr_utility.trace_off;
    EXCEPTION
        WHEN OTHERS then
            errbuf := substr(SQLERRM,1,255);
            retcode := sqlcode;
   end VALIDATE_TYE_DATA;

----------------------------------------------------------------------------
--Validate Character Set
----------------------------------------------------------------------------
    function validate_character_set (p_input_value in varchar2
                                   , p_mode in varchar2 ) return boolean as

         l_result boolean := true ;
         l_translated varchar2(1024);
         l_num varchar2(10)        := '0123456789' ;

         l_invalid_in_alphanum varchar2(100):= '~`!@#$%^&*()_+=|\[]{}<>":;?/.';
         l_invalid_in_alpha    varchar2(100):= '~`!@#$%^&*()_+=|\[]{}<>":;?/.0123456789';
    begin
        hr_utility.trace('Validating value : '||p_input_value||' as '||p_mode);
        if p_mode = 'NUMERIC' then
            l_translated := translate (p_input_value
                                     , '~' || l_num
                                     , '~');
            if l_translated is not null then
                 l_result := false;
            end if ;
        elsif p_mode = 'ALPHA' then
            l_translated := translate (p_input_value
                                     , l_invalid_in_alpha
                                     , lpad('~',length(l_invalid_in_alpha),'~'));
            if instr(l_translated,'~') >0 then
                 l_result := false;
            end if ;
       elsif p_mode = 'ALPHANUM' then
            l_translated := translate (p_input_value
                                     , l_invalid_in_alphanum
                                     , lpad('~',length(l_invalid_in_alphanum),'~'));
            if instr(l_translated,'~') >0 then
                 l_result := false;
            end if ;
       elsif p_mode = 'FREETEXT' then
           null;
           -- we will not validate for freetext
       end if;

       hr_utility.trace('l_translated='||l_translated);
       return l_result ;
    end validate_character_set;


----------------------------------------------------------------------------
-- Validate Email ID
----------------------------------------------------------------------------
   function validate_email_id (p_email_id varchar2)
   return boolean
   is
         l_validate_flag boolean := true ;
    begin
        if instr(p_email_id,'@') <= 0 then
            l_validate_flag := false ;
        elsif instr(p_email_id,'.') <= 0 then
            l_validate_flag := false ;
        end if ;
        return l_validate_flag;
    end validate_email_id ;

---------------------------------------------------------------------------
-- Validate Address
---------------------------------------------------------------------------
procedure  validate_address (P_STYLE           in varchar2
                            ,P_TAX_YEAR        in number
                            ,P_ADDRESS_TYPE    in varchar2 default null
                            ,P_PRIMARY_FLAG    in varchar2 default null
                            ,P_UNIT_NUMBER     in varchar2 default null
                            ,P_COMPLEX         in varchar2 default null
                            ,P_STREET_NUMBER   in varchar2 default null
                            ,P_STREET_NAME     in varchar2 default null
                            ,P_SUBURB_DISTRICT in varchar2 default null
                            ,P_TOWN_OR_CITY    in varchar2 default null
                            ,P_POSTAL_CODE     in varchar2 default null
                            ,P_SAME_AS_RES_ADD in varchar2 default null
                            ,P_ADDRESS_LINE1   in varchar2 default null
                            ,P_ADDRESS_LINE2   in varchar2 default null
                            ,P_ADDRESS_LINE3   in varchar2 default null
                            ,P_NATURE          in varchar2 default null
                            ,P_MSG_TXT         in out nocopy msgtext_tab
                            ,P_WARN_TXT        in out nocopy msgtext_tab
) as
   l_location varchar2(50);
   l_msg_count number(5):=0;
   l_warn_count number(5):=0;
   begin

       hr_utility.trace('P_STYLE:'||P_STYLE);
       hr_utility.trace('P_TAX_YEAR:'||P_TAX_YEAR);
       hr_utility.trace('P_ADDRESS_TYPE:'||P_ADDRESS_TYPE);
       hr_utility.trace('P_PRIMARY_FLAG:'||P_PRIMARY_FLAG);
       hr_utility.trace('P_UNIT_NUMBER:'||P_UNIT_NUMBER);
       hr_utility.trace('P_COMPLEX:'||P_COMPLEX);
       hr_utility.trace('P_STREET_NUMBER:'||P_STREET_NUMBER);
       hr_utility.trace('P_STREET_NAME:'||P_STREET_NAME);
       hr_utility.trace('P_SUBURB_DISTRICT:'||P_SUBURB_DISTRICT);
       hr_utility.trace('P_TOWN_OR_CITY:'||P_TOWN_OR_CITY);
       hr_utility.trace('P_POSTAL_CODE:'||P_POSTAL_CODE);
       hr_utility.trace('P_SAME_AS_RES_ADD:'||P_SAME_AS_RES_ADD);
       hr_utility.trace('P_ADDRESS_LINE1:'||P_ADDRESS_LINE1);
       hr_utility.trace('P_ADDRESS_LINE2:'||P_ADDRESS_LINE2);
       hr_utility.trace('P_ADDRESS_LINE3:'||P_ADDRESS_LINE3);
       hr_utility.trace('P_NATURE:'||P_NATURE);

        --Check which address is passed
       if P_STYLE = 'ZA_GRE' then
            l_location := 'ZA Tax File Information';
       elsif P_STYLE = 'ZA_SARS' and P_ADDRESS_TYPE='ZA_BUS' then
            l_location := 'the Business Address';
       elsif P_STYLE = 'ZA_SARS' and P_ADDRESS_TYPE='ZA_RES' then
            l_location := 'the Residential Address';
       else
            l_location := 'the Postal Address';
       end if;

       l_msg_count  := P_MSG_TXT.count;
       l_warn_count := P_WARN_TXT.count;

       if P_STYLE in ('ZA_GRE','ZA_SARS') then
         -- Validate Unit Number
         hr_utility.set_location('Validating Unit Number',10);
         if validate_character_set(P_UNIT_NUMBER,'ALPHANUM') = false then
              fnd_message.set_name('PER', 'HR_ZA_INVALID_CHAR');
              fnd_message.set_token('FIELD', 'Unit Number in '||l_location);
              p_msg_txt(l_msg_count):=fnd_message.get('Y');
              l_msg_count := l_msg_count + 1;
         end if;

         --Validate Complex
         hr_utility.set_location('Validating Complex',20);
         if validate_character_set(P_COMPLEX,'FREETEXT') = false then
              fnd_message.set_name('PER', 'HR_ZA_INVALID_CHAR');
              fnd_message.set_token('FIELD', 'Complex in '||l_location);
              p_msg_txt(l_msg_count):=fnd_message.get('Y');
              l_msg_count := l_msg_count + 1;
         end if;

         --Validate Street Number
         hr_utility.set_location('Validating Street Number',25);
         if validate_character_set(P_STREET_NUMBER,'ALPHANUM') = false then
              fnd_message.set_name('PER', 'HR_ZA_INVALID_CHAR');
              fnd_message.set_token('FIELD', 'Street Number in '||l_location);
              p_msg_txt(l_msg_count):=fnd_message.get('Y');
              l_msg_count := l_msg_count + 1;
         end if;

         --For residential, it is mandatory irrespective of nature
         --Validate Street or Name of Farm
         hr_utility.set_location('Validating Street or Name of Farm',30);
         if P_STREET_NAME is null and nvl(P_NATURE,'X') <> 'N' then
               fnd_message.set_name('PER', 'HR_ZA_ENTER_STREET_NAME_FARM');
               fnd_message.set_token('LOCATION', l_location);
                if P_STYLE = 'ZA_GRE' OR (P_STYLE='ZA_SARS' and P_TAX_YEAR <>2010) then
                     p_msg_txt(l_msg_count):=fnd_message.get('Y');
                     l_msg_count := l_msg_count + 1;
                else
                --Made a warning as per revision 8.0.0 of SARS PAYE Reconiliation 2010 for only Tax Year 2010
                     p_warn_txt(l_warn_count):=fnd_message.get('Y');
                     l_warn_count := l_warn_count + 1;
                end if;
         elsif validate_character_set(P_STREET_NAME,'FREETEXT') = false then
                fnd_message.set_name('PER', 'HR_ZA_INVALID_CHAR');
                fnd_message.set_token('FIELD', 'Street or Name of Farm in '||l_location);
                p_msg_txt(l_msg_count):=fnd_message.get('Y');
                l_msg_count := l_msg_count + 1;
         end if;

         --Validate Suburb or District
         hr_utility.set_location('Validating Suburb/District',35);
         if validate_character_set(P_SUBURB_DISTRICT,'FREETEXT') = false then
              fnd_message.set_name('PER', 'HR_ZA_INVALID_CHAR');
              fnd_message.set_token('FIELD', 'Suburb or District in '||l_location);
              p_msg_txt(l_msg_count):=fnd_message.get('Y');
              l_msg_count := l_msg_count + 1;
         end if;

         --Validate City or Town
         hr_utility.set_location('Validating City/Town',40);
         if validate_character_set(P_TOWN_OR_CITY,'FREETEXT') = false then
              fnd_message.set_name('PER', 'HR_ZA_INVALID_CHAR');
              fnd_message.set_token('FIELD', 'City or Town in '||l_location);
              p_msg_txt(l_msg_count):=fnd_message.get('Y');
              l_msg_count := l_msg_count + 1;
         end if;

         if P_SUBURB_DISTRICT is null and P_TOWN_OR_CITY is null and nvl(P_NATURE,'X') <> 'N' then
              fnd_message.set_name('PER', 'HR_ZA_ENTER_DISTRICT_OR_TOWN');
              fnd_message.set_token('LOCATION', l_location);
              if P_STYLE = 'ZA_GRE' OR (P_STYLE='ZA_SARS' and P_TAX_YEAR <>2010) then
                     p_msg_txt(l_msg_count):=fnd_message.get('Y');
                     l_msg_count := l_msg_count + 1;
              else
              --Made a warning as per revision 8.0.0 of SARS PAYE Reconiliation 2010 for only Tax Year 2010
                     p_warn_txt(l_warn_count):=fnd_message.get('Y');
                     l_warn_count := l_warn_count + 1;
              end if;
         end if ;

         --Validate Postal Code
         hr_utility.set_location('Validating Postal Code',50);
         if P_POSTAL_CODE is null and nvl(P_NATURE,'X') <> 'N' then
              fnd_message.set_name('PER', 'HR_ZA_NEW_ENTER_POSTAL_CODE');
              fnd_message.set_token('LOCATION', l_location);
              if P_STYLE = 'ZA_GRE' OR (P_STYLE='ZA_SARS' and P_TAX_YEAR <>2010) then
                     p_msg_txt(l_msg_count):=fnd_message.get('Y');
                     l_msg_count := l_msg_count + 1;
              else
              --Made a warning as per revision 8.0.0 of SARS PAYE Reconiliation 2010 for only Tax Year 2010
                     p_warn_txt(l_warn_count):=fnd_message.get('Y');
                     l_warn_count := l_warn_count + 1;
              end if;
        else
              if P_STYLE='ZA_GRE' and length(P_POSTAL_CODE) <> 4 then
                 hr_utility.set_location('Invalid postal code',50);
                 fnd_message.set_name('PER', 'HR_ZA_INVALID_LENGTH');
                 fnd_message.set_token('FIELD', 'Postal Code in '||l_location );
                 fnd_message.set_token('LENGTH', 4);
                 fnd_message.set_token('UNITS', 'digits');
                 p_msg_txt(l_msg_count):=fnd_message.get('Y');
                 l_msg_count := l_msg_count + 1;
              end if;
              if validate_character_set(P_POSTAL_CODE,'ALPHANUM') = false then
                  fnd_message.set_name('PER', 'HR_ZA_INVALID_CHAR');
                  fnd_message.set_token('FIELD', 'Postal Code in '||l_location);
                  p_msg_txt(l_msg_count):=fnd_message.get('Y');
                  l_msg_count := l_msg_count + 1;
              end if;
        end if;

     elsif P_STYLE ='ZA' then
         --Validate Address Line1
         if P_ADDRESS_LINE1 is null then
                fnd_message.set_name('PER', 'HR_ZA_NEW_ENTER_ADDRESS_LINE1');
                p_msg_txt(l_msg_count):=fnd_message.get('Y');
                l_msg_count := l_msg_count + 1;
         elsif validate_character_set(P_ADDRESS_LINE1,'FREETEXT') = false then
                  fnd_message.set_name('PER', 'HR_ZA_INVALID_CHAR');
                  fnd_message.set_token('FIELD', 'Address Line1 in '||l_location);
                  p_msg_txt(l_msg_count):=fnd_message.get('Y');
                  l_msg_count := l_msg_count + 1;
         end if;

         --Validate address line2
         if validate_character_set(P_ADDRESS_LINE2,'FREETEXT') = false then
               fnd_message.set_name('PER', 'HR_ZA_INVALID_CHAR');
               fnd_message.set_token('FIELD', 'Address Line2 in '||l_location);
               p_msg_txt(l_msg_count):=fnd_message.get('Y');
               l_msg_count := l_msg_count + 1;
         end if;

         --Validate address line3
         if validate_character_set(P_ADDRESS_LINE3,'FREETEXT') = false then
               fnd_message.set_name('PER', 'HR_ZA_INVALID_CHAR');
               fnd_message.set_token('FIELD', 'Address Line3 in '||l_location);
               p_msg_txt(l_msg_count):=fnd_message.get('Y');
               l_msg_count := l_msg_count + 1;
         end if;

         --Validate postal code
         if P_POSTAL_CODE is null then
                fnd_message.set_name('PER', 'HR_ZA_NEW_ENTER_POSTAL_CODE');
               fnd_message.set_token('LOCATION', l_location);
                p_msg_txt(l_msg_count):=fnd_message.get('Y');
                l_msg_count := l_msg_count + 1;
         end if;
         if validate_character_set(P_POSTAL_CODE,'ALPHANUM') = false then
               fnd_message.set_name('PER', 'HR_ZA_INVALID_CHAR');
               fnd_message.set_token('FIELD', 'Postal Code in '||l_location);
               p_msg_txt(l_msg_count):=fnd_message.get('Y');
               l_msg_count := l_msg_count + 1;
         end if;
     end if;

   end validate_address;

 -- -----------------------------------------------------------------------------
 -- Get the correct characterset for XML generation
 -- -----------------------------------------------------------------------------
 --
 FUNCTION get_IANA_charset RETURN VARCHAR2 IS
   CURSOR csr_get_iana_charset IS
     SELECT tag
       FROM fnd_lookup_values
      WHERE lookup_type = 'FND_ISO_CHARACTER_SET_MAP'
        AND lookup_code = SUBSTR(USERENV('LANGUAGE'),
                                    INSTR(USERENV('LANGUAGE'), '.') + 1)
        AND language = 'US';
 --
  lv_iana_charset fnd_lookup_values.tag%type;
 BEGIN
   OPEN csr_get_iana_charset;
     FETCH csr_get_iana_charset INTO lv_iana_charset;
   CLOSE csr_get_iana_charset;
   RETURN (lv_iana_charset);
 END get_IANA_charset;

  PROCEDURE write_to_clob (p_clob OUT NOCOPY CLOB) IS

  --  l_xml_element_template0 VARCHAR2(20) := '<TAG>VALUE</TAG>';
  --  l_xml_element_template1 VARCHAR2(30) := '<TAG><![CDATA[VALUE]]></TAG>';
  --  l_xml_element_template2 VARCHAR2(10) := '<TAG>';
  --  l_xml_element_template3 VARCHAR2(10) := '</TAG>';
  l_str1                  VARCHAR2(80) ;
  l_str2                  VARCHAR2(20) := '</EOY> </ROOT>';
  l_xml_element           VARCHAR2(800);
  l_clob                  CLOB;
  --
 BEGIN

  l_str1 := '<?xml version="1.0" encoding="' || get_IANA_charset || '"?>' ;

  dbms_lob.createtemporary(l_clob, FALSE, DBMS_LOB.CALL);
  dbms_lob.open(l_clob, DBMS_LOB.LOB_READWRITE);
  --
  dbms_lob.writeappend(l_clob, LENGTH(l_str1), l_str1);
  --
  IF g_xml_element_table.COUNT > 0 THEN
  --
   FOR table_counter IN g_xml_element_table.FIRST .. g_xml_element_table.LAST LOOP
   --
      IF g_xml_element_table(table_counter).tagvalue = '_START_' THEN
         l_xml_element := '<' || g_xml_element_table(table_counter).tagname || '>';
      ELSIF g_xml_element_table(table_counter).tagvalue = '_END_' THEN
         l_xml_element := '</' || g_xml_element_table(table_counter).tagname || '>';
      ELSIF g_xml_element_table(table_counter).tagvalue = '_COMMENT_' THEN
         l_xml_element := '<!-- ' || g_xml_element_table(table_counter).tagname || ' -->';
      ELSE
         l_xml_element := '<' || g_xml_element_table(table_counter).tagname ||
                      '><![CDATA[' || g_xml_element_table(table_counter).tagvalue ||
                     ']]></' || g_xml_element_table(table_counter).tagname || '>';
      END IF;
      --
      dbms_lob.writeappend(l_clob, LENGTH(l_xml_element), l_xml_element);
   --
   END LOOP;
  --
  END IF;

  p_clob := l_clob;
  --
  EXCEPTION
   WHEN OTHERS THEN
     --Fnd_file.put_line(FND_FILE.LOG,'## SQLERR ' || sqlerrm(sqlcode));
      hr_utility.set_location(sqlerrm(sqlcode),110);
 --
 END write_to_clob;

procedure get_tyev_parameters
(P_LEGAL_ENTITY   number,
 P_PAYROLL_ID     number,
 P_TAX_YEAR       varchar2,
 P_CERT_TYPE      varchar2,
 P_ASG_SET_ID     number,
 P_PERSON_ID      number,
 P_TEST_RUN       varchar2,
 P_TAX_YEAR_END   date,
 P_SORT_ORDER1    varchar2,
 P_SORT_ORDER2    varchar2,
 P_SORT_ORDER3    varchar2
-- P_ASG_SET_WHERE varchar2,
-- P_SORT_ORDER_CLAUSE varchar2
)
as
CURSOR get_asg_set_status(c_asg_set_id hr_assignment_sets.assignment_set_id%TYPE) IS
SELECT include_or_exclude
FROM   hr_assignment_set_amendments hasa
WHERE  hasa.assignment_set_id = c_asg_set_id;

l_ass_set_name varchar2(80);
l_set_flag varchar2(1);
--g_asg_set_where varchar2(500);
l_person_name varchar2(40);
l_test_run varchar2(4);
l_cert_type varchar2(12);
--g_sort_order_clause varchar2(500);
l_sort_order1 varchar2(30);
l_sort_order2 varchar2(30);
l_sort_order3 varchar2(30);
l_legal_entity varchar2(240);
l_payroll_name pay_all_payrolls_f.payroll_name%type;
l_proc varchar2(250):='PAY_ZA_EOY_VAL.GET_TYEV_PARAMETERS';
begin
  -- Retrieve the Report Parameter Information

  hr_utility.set_location('Entering '||l_proc,10);

  --Legal Entity Name
  select name
  into l_legal_entity
  from hr_all_organization_units
  where organization_id=P_LEGAL_ENTITY;

  --Certificate Type
  select meaning
  into l_cert_type
  from hr_lookups
  where lookup_type='ZA_TAX_CERTIFICATES' and lookup_code=P_CERT_TYPE;

  hr_utility.set_location('l_legal_entity: '||l_legal_entity,10);
  hr_utility.set_location('l_cert_type:    '||l_cert_type,10);


  --Payroll Name
    if P_PAYROLL_ID is not null
    then
      select ppf.payroll_name
      into   l_payroll_name
      from   pay_payrolls_f ppf
      where  ppf.payroll_id=P_PAYROLL_ID
              and ppf.effective_start_date =
              (select  max(effective_start_date)
               from    pay_all_payrolls_f ppf1
              where   ppf1.payroll_id=ppf.payroll_id
              and P_TAX_YEAR_END between ppf1.effective_start_date and ppf1.effective_end_date);
    end if;

   hr_utility.set_location('l_payroll_name: '||l_payroll_name,10);

  --Assignment Set Info
    if P_ASG_SET_ID is not null
    then
      select assignment_set_name into l_ass_set_name
      from   hr_assignment_sets
      where  assignment_set_id=P_ASG_SET_ID;

      OPEN get_asg_set_status(P_ASG_SET_ID);
      FETCH get_asg_set_status INTO l_set_flag;

      IF l_set_flag = 'E' THEN  -- if EXCLUDE
       g_asg_set_where := ' AND ass.assignment_id NOT IN  ( SELECT hasa.assignment_id  FROM   hr_assignment_set_amendments hasa WHERE  hasa.assignment_set_id = ' ||  P_ASG_SET_ID || ' AND hasa.assignment_id = ass.assignment_id) ';

      ELSIF l_set_flag = 'I' THEN -- if INCLUDE
       g_asg_set_where := ' AND ass.assignment_id IN  ( SELECT hasa.assignment_id  FROM   hr_assignment_set_amendments hasa  WHERE  hasa.assignment_set_id = ' || P_ASG_SET_ID ||  ' AND hasa.assignment_id = ass.assignment_id) ';
      ELSE -- Select all assignments assigned to the payroll associated with this assignment set
       g_asg_set_where := ' AND 1= 1 ';
      END IF;

        CLOSE get_asg_set_status;
    end if;

    if g_asg_set_where is null then
       g_asg_set_where := ' AND 1= 1 ';
    end if;

    hr_utility.set_location('Retrieved Assignment Set Info',10);

  --Employee Name Info
    if P_PERSON_ID is not null then
                select  substr(per.full_name,1,40)
      into l_person_name
                from   per_all_people_f per
        where  person_id=P_PERSON_ID
        and per.effective_start_date = ( select max(effective_start_date) from per_all_people_f per1
                                       where per.person_id=per1.person_id
                                       and P_TAX_YEAR_END between per1.effective_start_date and per1.effective_end_date);
    end if;

    --Test Run Parameters
    if P_TEST_RUN is not null then
      select meaning
      into l_test_run
      from fnd_lookups
      where lookup_type='YES_NO' and lookup_code=P_TEST_RUN;
   else
      l_test_run:='N';
   end if;

   hr_utility.set_location('l_person_name:  '||l_person_name,10);
   hr_utility.set_location('l_test_run:     '||l_test_run,10);


    --SORT ORDER parameters
   if p_sort_order1 is not null or p_sort_order2 is not null or p_sort_order3 is not null then
           g_sort_order_clause:=' order by ';

           hr_utility.set_location('Order by clause present',15);
           -- Append first sort order
           if p_sort_order1 = '3' then
              g_sort_order_clause := g_sort_order_clause || ' substr(per.full_name,1,40), ';
                                l_sort_order1:='Employee Name';
           elsif p_sort_order1 = '4' then
              g_sort_order_clause := g_sort_order_clause || ' lpad(per.employee_number, 30, ''0''), ';
              l_sort_order1:='Employee Number';
           elsif p_sort_order1 = '5' then
              g_sort_order_clause := g_sort_order_clause || ' lpad(ass.assignment_number, 30, ''0''), ';
              l_sort_order1:='Assignment Number';
           end if;

           -- Append second sort order
           if p_sort_order2 = '3' then
              g_sort_order_clause := g_sort_order_clause || ' substr(per.full_name,1,40),';
              l_sort_order2:='Employee Name';
           elsif p_sort_order2 = '4' then
              g_sort_order_clause := g_sort_order_clause || ' lpad(per.employee_number, 30, ''0''),';
              l_sort_order2:='Employee Number';
           elsif p_sort_order2 = '5' then
              g_sort_order_clause := g_sort_order_clause || ' lpad(ass.assignment_number, 30, ''0''),';
              l_sort_order2:='Assignment Number';
           end if;

           -- Append third sort order
           if p_sort_order3 = '3' then
              g_sort_order_clause := g_sort_order_clause || ' substr(per.full_name,1,40),';
              l_sort_order3:='Employee Name';
           elsif p_sort_order3 = '4' then
              g_sort_order_clause := g_sort_order_clause || ' lpad(per.employee_number, 30, ''0''),';
              l_sort_order3:='Employee Number';
           elsif p_sort_order3 = '5' then
              g_sort_order_clause := g_sort_order_clause || ' lpad(ass.assignment_number, 30, ''0''),';
              l_sort_order3:='Assignment Number';
           end if;

           g_sort_order_clause:=g_sort_order_clause || ' ass.assignment_id';

   end if;

   hr_utility.set_location('Retrieved Sort Order Info',20);

   hr_utility.set_location('Populating XML Table',90);

  --Build XML for report parameters
  g_xml_element_table(g_xml_element_count).tagname  := 'LEGAL_ENTITY_NAME';
  g_xml_element_table(g_xml_element_count).tagvalue := l_legal_entity;
  g_xml_element_count := g_xml_element_count + 1;

  g_xml_element_table(g_xml_element_count).tagname  := 'TAX_YEAR';
  g_xml_element_table(g_xml_element_count).tagvalue := p_tax_year;
  g_xml_element_count := g_xml_element_count + 1;

  g_xml_element_table(g_xml_element_count).tagname  := 'CERT_TYPE';
  g_xml_element_table(g_xml_element_count).tagvalue := l_cert_type;
  g_xml_element_count := g_xml_element_count + 1;

  g_xml_element_table(g_xml_element_count).tagname  := 'PAYROLL_NAME';
  g_xml_element_table(g_xml_element_count).tagvalue := l_payroll_name;
  g_xml_element_count := g_xml_element_count + 1;

  g_xml_element_table(g_xml_element_count).tagname  := 'ASSIGN_SET';
  g_xml_element_table(g_xml_element_count).tagvalue := l_ass_set_name;
  g_xml_element_count := g_xml_element_count + 1;

  g_xml_element_table(g_xml_element_count).tagname  := 'EMP_NAME';
  g_xml_element_table(g_xml_element_count).tagvalue := l_person_name;
  g_xml_element_count := g_xml_element_count + 1;

  g_xml_element_table(g_xml_element_count).tagname  := 'TEST_RUN';
  g_xml_element_table(g_xml_element_count).tagvalue := l_test_run;
  g_xml_element_count := g_xml_element_count + 1;

  g_xml_element_table(g_xml_element_count).tagname  := 'SORT1';
  g_xml_element_table(g_xml_element_count).tagvalue := l_sort_order1;
  g_xml_element_count := g_xml_element_count + 1;

  g_xml_element_table(g_xml_element_count).tagname  := 'SORT2';
  g_xml_element_table(g_xml_element_count).tagvalue := l_sort_order2;
  g_xml_element_count := g_xml_element_count + 1;

  g_xml_element_table(g_xml_element_count).tagname  := 'SORT3';
  g_xml_element_table(g_xml_element_count).tagvalue := l_sort_order3;
  g_xml_element_count := g_xml_element_count + 1;
  --END XML for Report parameters

  g_xml_element_table(g_xml_element_count).tagname  := 'End Parameter Information';
  g_xml_element_table(g_xml_element_count).tagvalue := '_COMMENT_';
  g_xml_element_count := g_xml_element_count + 1;

  hr_utility.set_location('Leaving '||l_proc,20);

end get_tyev_parameters;

procedure get_employer_info
(p_business_group_id   number,
 p_legal_entity        number,
 p_tax_year            number,
 p_er_info  OUT nocopy varchar2
)
is
--Retrieve 'ZA Tax Information' (Context ZA_LEGAL_ENTITY) and Location Address details
cursor csr_tax_info is
   select hoi.org_information1                er_trade_name,  -- Employer Trading or Other Name (Code 2010)
          hoi.org_information3                paye_ref_num,   -- PAYE Ref Num (Code 2020)
          pay_za_eoy_val.modulus_10_test(hoi.org_information3)  paye_ref_num_mod,
          upper(hoi.org_information12)        sdl_ref_num,    -- SDL Num (Code 2022)
          upper(hoi.org_information6)         uif_ref_num,    -- UIF Ref Num (Code 2024)
          hoi.org_information13               er_trade_class  -- Employer Trade Classification (Code 2035)
   from   hr_organization_information hoi
   where  hoi.organization_id = p_legal_entity
     and  hoi.org_information_context = 'ZA_LEGAL_ENTITY';

-- Retrieve 'ZA GRE Tax File Creator Info' (Context ZA_GRE_TAX_FILE_ENTITY) from Legal Entity level
cursor csr_tax_file_creator_inf  is
   select hoi.org_information1          er_contact_person, -- code 2025
          hoi.org_information2          er_contact_number, -- code 2026
          hoi.org_information3          er_email_address,  -- code 2027
          hoi.org_information4          er_unit_num,       -- code 2061
          hoi.org_information5          er_complex,        -- code 2062
          hoi.org_information6          er_street_num,     -- code 2063
          hoi.org_information7          er_street_name_farm, -- code 2063
          hoi.org_information8          er_suburb_district, -- code 2063
          hoi.org_information9          er_town_city,       -- code 2063
          hoi.org_information10         er_postal_code      -- code 2063
   from   hr_organization_information hoi
   where  hoi.organization_id = p_legal_entity
     and  hoi.org_information_context = 'ZA_GRE_TAX_FILE_ENTITY';

rec_tax_info               csr_tax_info%rowtype;
rec_tax_file_creator_inf   csr_tax_file_creator_inf%rowtype;
l_proc                     varchar2(250):='PAY_ZA_EOY_VAL.GET_EMPLOYER_INFO';
l_er_info                  varchar2(1):='N';
l_msgtext                  varchar2(2000);
--type msgtext_tab is table of varchar2(2000) index by binary_integer;
l_er_msg_tab               msgtext_tab;
l_er_warn_tab              msgtext_tab;
l_msg_count                number(5):=0;
begin

  --  hr_utility.trace_on(null,'ZATYEV');
    hr_utility.set_location('Entered '||l_proc,10);

    g_xml_element_table(g_xml_element_count).tagname  := 'Employer Information';
    g_xml_element_table(g_xml_element_count).tagvalue := '_COMMENT_';
    g_xml_element_count := g_xml_element_count + 1;

    hr_utility.set_location('Get ZA Tax Information',15);
    open csr_tax_info;
    fetch csr_tax_info into rec_tax_info;
    close csr_tax_info;

    hr_utility.set_location('Get ZA GRE Tax File Creator Info',15);
    open csr_tax_file_creator_inf;
    fetch csr_tax_file_creator_inf into rec_tax_file_creator_inf;
    if csr_tax_file_creator_inf%rowcount = 0 then
        rec_tax_file_creator_inf.er_contact_person:=null;
        rec_tax_file_creator_inf.er_contact_number:=null;
        rec_tax_file_creator_inf.er_email_address:=null;
    end if;
    close csr_tax_file_creator_inf;

    l_er_msg_tab.delete;

    hr_utility.set_location('Start the Employer level validation',15);

    --Validate the Company Trading Name (Code 2010):
    hr_utility.set_location('Validate Company Trading Name - Code 2010',15);
    if rec_tax_info.er_trade_name is null then
          hr_utility.set_location('Company Trading Name is null',15);
          fnd_message.set_name('PAY', 'PY_ZA_ENTER_TRADING_NAME');
          l_er_msg_tab(l_msg_count) := fnd_message.get('Y');
          l_msg_count := l_msg_count + 1;
          l_er_info :='Y';
    /* Commented as per revision 8.0.0 of SARS PAYE Reconiliation 2010
    elsif length(translate(rec_tax_info.er_trade_name,'~\/*?:><|','~')) <> length(rec_tax_info.er_trade_name)
           OR instr(rec_tax_info.er_trade_name,'""')<>0 then
          hr_utility.set_location('Company Trading Name is invalid',15);
          fnd_message.set_name('PAY', 'PY_ZA_INVALID_EMPLOYER_NAME');
          l_er_msg_tab(l_msg_count) := fnd_message.get('Y');
          l_msg_count := l_msg_count + 1;
          l_er_info :='Y'; */
    elsif validate_character_set(rec_tax_info.er_trade_name,'FREETEXT') = FALSE then
          hr_utility.set_location('Company Trading Name is invalid',15);
          fnd_message.set_name('PER', 'HR_ZA_INVALID_CHAR');
          fnd_message.set_token('FIELD','Company Trading or Other Name');
          l_er_msg_tab(l_msg_count) := fnd_message.get('Y');
          l_msg_count := l_msg_count + 1;
          l_er_info :='Y';
    end if;

    --Validate Trade classification (Code 2035)
    --Updated as per revision 8.0.0 of SARS PAYE Reconiliation 2010
    hr_utility.set_location('Validate Company Trade Classification - Code 2035',20);
    if rec_tax_info.er_trade_class is null and p_tax_year <> 2010 then
          hr_utility.set_location('Company Trade Classification is null',20);
          fnd_message.set_name('PAY', 'PY_ZA_ENTER_TRADE_CLASS');
          l_er_msg_tab(l_msg_count) := fnd_message.get('Y');
          l_msg_count := l_msg_count + 1;
          l_er_info :='Y';
    else
          hr_utility.set_location('Company Trade Classification is not null',20);
          if validate_character_set(rec_tax_info.er_trade_class,'NUMERIC')=FALSE then
                fnd_message.set_name('PER', 'HR_ZA_INVALID_CHAR');
                fnd_message.set_token('FIELD', 'Trade Classification in ZA Tax Information');
                l_er_msg_tab(l_msg_count) := fnd_message.get('Y');
                l_msg_count := l_msg_count + 1;
                l_er_info :='Y';
          end if;
          if length(rec_tax_info.er_trade_class) > 4 then
                fnd_message.set_name('PER', 'HR_ZA_INVALID_MAX_LENGTH');
                fnd_message.set_token('FIELD', 'Trade Classification in ZA Tax Information');
                fnd_message.set_token('LENGTH', '4');
                fnd_message.set_token('UNITS', 'digits');
                l_er_msg_tab(l_msg_count) := fnd_message.get('Y');
                l_msg_count := l_msg_count + 1;
                l_er_info :='Y';
          end if;
    end if;

    -- Validate the PAYE Reference Number (Code 2020)
    hr_utility.set_location('Validating PAYE Ref Number - Code 2020',22);
    if rec_tax_info.paye_ref_num is null then
          hr_utility.set_location('PAYE Ref Number is null',22);
          fnd_message.set_name('PAY', 'PY_ZA_ENTER_TAX_REF_NO');
          l_er_msg_tab(l_msg_count) := fnd_message.get('Y');
          l_msg_count := l_msg_count + 1;
          l_er_info :='Y';
    elsif substr(rec_tax_info.paye_ref_num,1,1) not in ('0','1','2','3','7','9') then
          hr_utility.set_location('PAYE Ref Number begins with invalid character',22);
          fnd_message.set_name('PAY', 'PY_ZA_INVALID_TAX_REF_NO');
          l_er_msg_tab(l_msg_count) := fnd_message.get('Y');
          l_msg_count := l_msg_count + 1;
          l_er_info :='Y';
   elsif rec_tax_info.paye_ref_num_mod = 0 then
          hr_utility.set_location('PAYE Ref Number fails modulus 10 test',22);
          fnd_message.set_name('PAY', 'PY_ZA_INVALID_TAX_REF_NO');
          l_er_msg_tab(l_msg_count) := fnd_message.get('Y');
          l_msg_count := l_msg_count + 1;
          l_er_info :='Y';
   end if;

    -- Validate the SDL Number (Code 2022)
    hr_utility.set_location('Validating SDL Number - Code 2022',25);
    if rec_tax_info.sdl_ref_num is not null then
      hr_utility.set_location('SDL Number is not null',25);
      if substr(rec_tax_info.sdl_ref_num,1,1) <> 'L' OR length(rec_tax_info.sdl_ref_num) <> 10 then
            hr_utility.set_location('SDL Number begins with invalid character',25);
            fnd_message.set_name('PAY', 'PY_ZA_INVALID_FIRST_CHAR');
            fnd_message.set_token('FIELD','SDL Number');
            fnd_message.set_token('CHAR1','L');
            l_er_msg_tab(l_msg_count) := fnd_message.get('Y');
            l_msg_count := l_msg_count + 1;
            l_er_info :='Y';
      end if;
      if substr(rec_tax_info.sdl_ref_num,2,9) <> substr(rec_tax_info.paye_ref_num,2,9)
         AND substr(rec_tax_info.paye_ref_num,1,1) = '7' then
            hr_utility.set_location('SDL Number doesnt match with PAYE Number',25);
            fnd_message.set_name('PAY', 'PY_ZA_INVALID_LAST_NINE_CHAR');
            fnd_message.set_token('FIELD','SDL Number');
            l_er_msg_tab(l_msg_count) := fnd_message.get('Y');
            l_msg_count := l_msg_count + 1;
            l_er_info :='Y';
     end if;
     if pay_za_eoy_val.modulus_10_test(rec_tax_info.sdl_ref_num,'S') =0 then
            hr_utility.set_location('SDL Number fails modulus 10 test',25);
            fnd_message.set_name('PAY', 'PY_ZA_INVALID_SDL_NO');
            l_er_msg_tab(l_msg_count) := fnd_message.get('Y');
            l_msg_count := l_msg_count + 1;
            l_er_info :='Y';
     end if;
    end if;

    -- Validate the UIF Number (Code 2024)
    -- First replacing any char other than U and digits with null as earlier UIF Number segment
    -- allowed value greater than 10 digits.
    hr_utility.set_location('Validating UIF Number - Code 2024',27);
    rec_tax_info.uif_ref_num := translate(rec_tax_info.uif_ref_num,
                                        'U0123456789ABCDEFGHIJKLMNOPQRSTVWXYZ- "\/?@&$!#+=;:,''().',
                                        'U0123456789');
    if rec_tax_info.uif_ref_num is not null then
      hr_utility.set_location('UIF Number not null',27);
      if substr(rec_tax_info.uif_ref_num,1,1) <> 'U' OR length(rec_tax_info.uif_ref_num) <> 10 then
            hr_utility.set_location('UIF Number begins with invalid character',27);
            fnd_message.set_name('PAY', 'PY_ZA_INVALID_FIRST_CHAR');
            fnd_message.set_token('FIELD','UIF Number');
            fnd_message.set_token('CHAR1','U');
            l_er_msg_tab(l_msg_count) := fnd_message.get('Y');
            l_msg_count := l_msg_count + 1;
            l_er_info :='Y';
      end if;
      if substr(rec_tax_info.uif_ref_num,2,9) <> substr(rec_tax_info.paye_ref_num,2,9)
         AND substr(rec_tax_info.paye_ref_num,1,1) = '7' then
            hr_utility.set_location('UIF Number doesnt match with PAYE Number',27);
            fnd_message.set_name('PAY', 'PY_ZA_INVALID_LAST_NINE_CHAR');
            fnd_message.set_token('FIELD','UIF Number');
            l_er_msg_tab(l_msg_count) := fnd_message.get('Y');
            l_msg_count := l_msg_count + 1;
            l_er_info :='Y';
     end if;
     if pay_za_eoy_val.modulus_10_test(rec_tax_info.uif_ref_num,'U') =0 then
            hr_utility.set_location('UIF Number fails modulus 10 test',25);
            fnd_message.set_name('PAY', 'PY_ZA_INVALID_UIF_NO');
            l_er_msg_tab(l_msg_count) := fnd_message.get('Y');
            l_msg_count := l_msg_count + 1;
            l_er_info :='Y';
     end if;
    end if;

    -- Validate GRE Tax File Creator Info
    -- Validate Contact Person Name (Code 2025)
    hr_utility.set_location('Validating Contact Person Name - Code 2025',30);
    if rec_tax_file_creator_inf.er_contact_person is null then
            hr_utility.set_location('Contact Person Name is null',30);
            fnd_message.set_name('PAY', 'PY_ZA_NEW_ENTER_CONTACT_NAME');
            l_er_msg_tab(l_msg_count) := fnd_message.get('Y');
            l_msg_count := l_msg_count + 1;
            l_er_info :='Y';
    elsif validate_character_set(rec_tax_file_creator_inf.er_contact_person,'ALPHA') = FALSE then
            hr_utility.set_location('Contact Person Name contains invalid characters',30);
            fnd_message.set_name('PER', 'HR_ZA_INVALID_CHAR');
            fnd_message.set_token('FIELD','Contact Person in ZA Tax File Information');
            l_er_msg_tab(l_msg_count) := fnd_message.get('Y');
            l_msg_count := l_msg_count + 1;
            l_er_info :='Y';
    end if;

    -- Validate Contact Person Number (Code 2026)
    hr_utility.set_location('Validating Contact Person Number - Code 2026',32);
    if rec_tax_file_creator_inf.er_contact_number is null then
            hr_utility.set_location('Contact Person Number is null',32);
            hr_utility.set_location('l_msg_count:'||l_msg_count,32);
            fnd_message.set_name('PAY', 'PY_ZA_NEW_ENTER_CONTACT_PH_NO');
            l_er_msg_tab(l_msg_count) := fnd_message.get('Y');
            l_msg_count := l_msg_count + 1;
            l_er_info :='Y';
    elsif length(rec_tax_file_creator_inf.er_contact_number) not between 9 and 11 then
            hr_utility.set_location('Contact Person Number length not between 9 and 11',32);
            fnd_message.set_name('PAY', 'PY_ZA_INVALID_PH_NO');
            fnd_message.set_token('FIELD','Contact Number in ZA Tax File Information');
            l_er_msg_tab(l_msg_count) := fnd_message.get('Y');
            l_msg_count := l_msg_count + 1;
            l_er_info :='Y';
    end if;

    -- Validate Employer Email Address (Code 2027)
    hr_utility.set_location('Validating Employer Email Address - Code 2027',35);
    if rec_tax_file_creator_inf.er_email_address is not null then
      hr_utility.set_location('Email Address not null',35);
      if validate_email_id(rec_tax_file_creator_inf.er_email_address) = FALSE then
              hr_utility.set_location('Email Address doesnt contain @ or .',35);
              fnd_message.set_name('PER', 'HR_ZA_INVALID_CONTACT_EMAIL');
              fnd_message.set_token('CONTACT','Email Address in ZA Tax File Information');
              l_er_msg_tab(l_msg_count) := fnd_message.get('Y');
              l_msg_count := l_msg_count + 1;
              l_er_info :='Y';
      end if;
      if validate_character_set(rec_tax_file_creator_inf.er_email_address,'FREETEXT') = FALSE then
              hr_utility.set_location('Email Address contains invalid characters.',35);
              fnd_message.set_name('PER', 'HR_ZA_INVALID_CHAR');
              fnd_message.set_token('FIELD','Email Address in ZA Tax File Information');
              l_er_msg_tab(l_msg_count) := fnd_message.get('Y');
              l_msg_count := l_msg_count + 1;
              l_er_info :='Y';
      end if;
    end if;
    -- End Validate GRE Tax File Creator Info general info

    hr_utility.set_location('l_msg_count:'||l_msg_count,35);
   --Validate employer address
    validate_address( P_STYLE           => 'ZA_GRE'
                     ,P_TAX_YEAR        => null
                     ,P_UNIT_NUMBER     => rec_tax_file_creator_inf.er_unit_num
                     ,P_COMPLEX         => rec_tax_file_creator_inf.er_complex
                     ,P_STREET_NUMBER   => rec_tax_file_creator_inf.er_street_num
                     ,P_STREET_NAME     => rec_tax_file_creator_inf.er_street_name_farm
                     ,P_SUBURB_DISTRICT => rec_tax_file_creator_inf.er_suburb_district
                     ,P_TOWN_OR_CITY    => rec_tax_file_creator_inf.er_town_city
                     ,P_POSTAL_CODE     => rec_tax_file_creator_inf.er_postal_code
                     ,P_MSG_TXT         => l_er_msg_tab
                     ,P_WARN_TXT        => l_er_warn_tab
                   );

    hr_utility.set_location('l_msg_count:'||l_msg_count,36);

    hr_utility.set_location('Populating XML Table',90);

    l_msg_count:=l_er_msg_tab.count;
    if l_er_info = 'Y' OR l_msg_count >0 then
        g_xml_element_table(g_xml_element_count).tagname  := 'ER_INFO';
        g_xml_element_table(g_xml_element_count).tagvalue := 'Y';
        g_xml_element_count := g_xml_element_count + 1;
        l_er_info :='Y';


        for i in l_er_msg_tab.first .. l_er_msg_tab.last
        loop
            g_xml_element_table(g_xml_element_count).tagname  := 'ER_ERROR';
            g_xml_element_table(g_xml_element_count).tagvalue := '_START_';
            g_xml_element_count := g_xml_element_count + 1;

           g_xml_element_table(g_xml_element_count).tagname  := 'ERROR';
           g_xml_element_table(g_xml_element_count).tagvalue := l_er_msg_tab(i);
           g_xml_element_count := g_xml_element_count + 1;

           g_xml_element_table(g_xml_element_count).tagname  := 'ER_ERROR';
           g_xml_element_table(g_xml_element_count).tagvalue := '_END_';
           g_xml_element_count := g_xml_element_count + 1;
        end loop;
    end if;

   hr_utility.set_location('l_er_msg_tab.first:'||l_er_msg_tab.first,90);
   hr_utility.set_location('l_er_msg_tab.last:'||l_er_msg_tab.last,90);

    g_xml_element_table(g_xml_element_count).tagname  := 'End Employer Information';
    g_xml_element_table(g_xml_element_count).tagvalue := '_COMMENT_';
    g_xml_element_count := g_xml_element_count + 1;

    p_er_info:=l_er_info;

    hr_utility.set_location('Leaving '||l_proc,200);

end get_employer_info;

----------------------------------------------------------------------------
-- Validate phone numbers
----------------------------------------------------------------------------
procedure validate_phones (p_person_id      number
                         , p_nature         varchar2
                         , p_effective_date date
                         , p_tax_year       number
                         , p_ee_msg_tab  in out nocopy msgtext_tab
                         , p_ee_warn_tab in out nocopy msgtext_tab
) is
-- employees returns phone details
  cursor csr_phones (p_phone_type varchar2) is
    select translate(upper(phone_number),
                    '0123456789+-. ',
                    '0123456789')   -- remove any character other than digits
      from per_phones
      where parent_table = 'PER_ALL_PEOPLE_F'
       and parent_id = p_person_id
       and phone_type = p_phone_type
       and p_effective_date between date_from and nvl(date_to,to_date('31-12-4712','DD-MM-YYYY')) ;

  l_temp number;
  l_home_no varchar2(60);
  l_work_no varchar2(60);
  l_fax varchar2(60);
  l_cell_no varchar2(60);
  l_msg_count number(5):=0;
  l_warn_count number(5):=0;
  l_proc      varchar2(250):='PAY_ZA_EOY_VAL.VALIDATE_PHONES';
begin

   hr_utility.set_location('Entering '||l_proc,10);
   l_msg_count  :=p_ee_msg_tab.count;
   l_warn_count := p_ee_warn_tab.count;

   -- Validate Home Phone Number (Code 3135)

   hr_utility.set_location('Validating Home Telephone Number -Code 3135',15);
   hr_utility.set_location('Retrieve Home Primary Number',15);
   open csr_phones('H1');
   fetch csr_phones into l_home_no;
   close csr_phones;

   if l_home_no is null then
      hr_utility.set_location('Retrieve Home Secondary Number',15);
      open csr_phones('H2');
      fetch csr_phones into l_home_no;
      close csr_phones;

      if l_home_no is null then
         hr_utility.set_location('Retrieve Home Tertiary Number',15);
         open csr_phones('H3');
         fetch csr_phones into l_home_no;
         close csr_phones;
      end if;
   end if ;

   if l_home_no is not null then
      if length(l_home_no) not between 9 and 11 then
            fnd_message.set_name('PER', 'HR_ZA_INVALID_PH_NO');
            fnd_message.set_token('FIELD', 'Home Telephone Number');
            p_ee_msg_tab(l_msg_count):=fnd_message.get('Y');
            l_msg_count := l_msg_count + 1;
      end if;
      if validate_character_set(l_home_no,'NUMERIC') = FALSE then
            fnd_message.set_name('PER', 'HR_ZA_INVALID_CHAR');
            fnd_message.set_token('FIELD', 'Home Telephone Number');
            p_ee_msg_tab(l_msg_count):=fnd_message.get('Y');
            l_msg_count := l_msg_count + 1;
      end if;
   end if;

   -- Validate Business Phone Number (Code 3136)
  hr_utility.set_location('Validating Business Telephone Number -Code 3136',20);
  hr_utility.set_location('Retrieve Work Primary Number',20);
  open csr_phones('W1');
  fetch csr_phones into l_work_no;
  close csr_phones;

  if l_work_no is null then
     hr_utility.set_location('Retrieve Work Secondary Number',20);
     open csr_phones('W2');
     fetch csr_phones into l_work_no;
     close csr_phones;

     if l_work_no is null then
        hr_utility.set_location('Retrieve Work Tertiary Number',20);
        open csr_phones('W3');
        fetch csr_phones into l_work_no;
        close csr_phones;
     end if;
  end if ;

   if p_nature <> 'N' and l_work_no is null then
        fnd_message.set_name('PER', 'HR_ZA_ENTER_BUS_PH_NO');
        if p_tax_year=2010 then
              p_ee_warn_tab(l_warn_count):=fnd_message.get('Y');
              l_warn_count := l_warn_count + 1;
        else
              p_ee_msg_tab(l_msg_count):=fnd_message.get('Y');
              l_msg_count := l_msg_count + 1;
        end if;
   elsif l_work_no is not null then
      if length(l_work_no) not between 9 and 11 then
            fnd_message.set_name('PER', 'HR_ZA_INVALID_PH_NO');
            fnd_message.set_token('FIELD', 'Work Telephone Number');
            p_ee_msg_tab(l_msg_count):=fnd_message.get('Y');
            l_msg_count := l_msg_count + 1;
      end if;
      if validate_character_set(l_work_no,'NUMERIC') = FALSE then
            fnd_message.set_name('PER', 'HR_ZA_INVALID_CHAR');
            fnd_message.set_token('FIELD', 'Work Telephone Number');
            p_ee_msg_tab(l_msg_count):=fnd_message.get('Y');
            l_msg_count := l_msg_count + 1;
      end if;
   end if;

   -- Validate Fax Number (Code 3137)
   hr_utility.set_location('Validating Fax Number -Code 3137',25);
   hr_utility.set_location('Retrieve Work Fax Number',25);
   open csr_phones('WF');
   fetch csr_phones into l_fax;
   close csr_phones;

   if l_fax is null then
      hr_utility.set_location('Retrieve Home Fax Number',25);
      open csr_phones('HF');
      fetch csr_phones into l_fax;
      close csr_phones;
   end if;

   if l_fax is not null then
      if length(l_fax) not between 9 and 11 then
            fnd_message.set_name('PER', 'HR_ZA_INVALID_PH_NO');
            fnd_message.set_token('FIELD', 'Work Fax/ Home Fax');
            p_ee_msg_tab(l_msg_count):=fnd_message.get('Y');
            l_msg_count := l_msg_count + 1;
      end if;
      if validate_character_set(l_fax,'NUMERIC') = FALSE then
            fnd_message.set_name('PER', 'HR_ZA_INVALID_CHAR');
            fnd_message.set_token('FIELD', 'Work Fax/ Home Fax');
            p_ee_msg_tab(l_msg_count):=fnd_message.get('Y');
            l_msg_count := l_msg_count + 1;
      end if;
   end if;

   --Validate cell number (code 3138)
   hr_utility.set_location('Validating Cell Number -Code 3138',30);
   open csr_phones('M');
   fetch csr_phones into l_cell_no;
   close csr_phones;

   if l_cell_no is not null then
      if length(l_cell_no) <> 10 then
/*            fnd_message.set_name('PER', 'HR_ZA_INVALID_LENGTH');
            fnd_message.set_token('FIELD', 'Mobile Number');
            fnd_message.set_token('LENGTH', '10');
            fnd_message.set_token('UNITS', 'digits');
            p_ee_msg_tab(l_msg_count):=fnd_message.get('Y'); */
            p_ee_msg_tab(l_msg_count):='The Mobile Number is invalid. Its length must be between 10 and 11 digits.';
            l_msg_count := l_msg_count + 1;
      end if;
      if validate_character_set(l_cell_no,'NUMERIC') = FALSE then
            fnd_message.set_name('PER', 'HR_ZA_INVALID_CHAR');
            fnd_message.set_token('FIELD', 'Mobile Number');
            p_ee_msg_tab(l_msg_count):=fnd_message.get('Y');
            l_msg_count := l_msg_count + 1;
      end if;
   end if;

   hr_utility.set_location('Leaving '||l_proc,200);

end validate_phones;

---------------------------------------------------------------------------
-- Validate Nature
---------------------------------------------------------------------------
procedure validate_nature
(P_NATURE varchar2,
 P_FNAME  varchar2,
 P_MNAME  varchar2,
 P_LNAME  varchar2,
 P_EMPNO  varchar2,
 P_TRADING_NAME varchar2,
 P_NI varchar2,
 P_ID_DOB varchar2,
 P_PASSPORT_NO varchar2,
 P_COUNTRY_PASSPORT varchar2,
 P_IT_NO_VALUE varchar2,
 P_IT_NO_VAL number,
 P_CERT_TYPE varchar2,
 P_TAX_YEAR number,
 P_EE_MSG_TAB IN OUT nocopy msgtext_tab,
 P_EE_WARN_TAB IN OUT nocopy msgtext_tab
)
is
l_msg_count number(5):=0;
l_warn_count number(5):=0;
l_proc      varchar2(250) := 'PAY_ZA_EOY_VAL.VALIDATE_NATURE';
l_alpha     varchar2(52)  := '- ,''.';
l_invalid_char varchar2(1) := '~';
begin

     hr_utility.set_location('Entering '||l_proc,10);

     --Validate Nature of Person (Code 3020)
     hr_utility.set_location('Validation Nature of Person -Code 3020',10);
     if p_nature is null then
            hr_utility.set_location('Nature of Person is null',10);
            fnd_message.set_name('PAY', 'PY_ZA_ENTER_NATURE_PERSON');
            p_ee_msg_tab(l_msg_count):=fnd_message.get('Y');
            l_msg_count := l_msg_count + 1;
     elsif p_nature = 'M' then
            hr_utility.set_location('Nature of Person is M',10);
            fnd_message.set_name('PAY', 'PY_ZA_INVALID_NATURE_PERSON');
            fnd_message.set_token('NATURE', 'M');
            p_ee_msg_tab(l_msg_count):=fnd_message.get('Y');
            l_msg_count := l_msg_count + 1;
     elsif p_nature = 'K' then
            hr_utility.set_location('Nature of Person is K',10);
            fnd_message.set_name('PAY', 'PY_ZA_INVALID_NATURE_PERSON');
            fnd_message.set_token('NATURE', 'K');
            p_ee_msg_tab(l_msg_count):=fnd_message.get('Y');
            l_msg_count := l_msg_count + 1;
     end if;

    -- Validate Code Employee Surname/Trading Name (Code 3030)
    hr_utility.set_location('Validation EE Surname/Trading Name -Code 3030',15);
    if p_nature in ('D','E','F','G','H') then
       if p_trading_name is null then
            hr_utility.set_location('EE Surname is null',15);
            fnd_message.set_name('PAY', 'PY_ZA_ENTER_NAT_DEFGH_TRADE');
            p_ee_msg_tab(l_msg_count):=fnd_message.get('Y');
            l_msg_count := l_msg_count + 1;
       elsif validate_character_set(p_trading_name,'FREETEXT')= FALSE then
            hr_utility.set_location('EE Surname contains invalid characters',15);
            fnd_message.set_name('PER', 'HR_ZA_INVALID_CHAR');
            fnd_message.set_token('FIELD', 'Employee Trading Name');
            p_ee_msg_tab(l_msg_count):=fnd_message.get('Y');
            l_msg_count := l_msg_count + 1;
       /* Commented as per revision 8.0.0 of SARS PAYE Reconiliation 2010
       elsif translate(p_trading_name,'~/\*?:><|','~') is not null OR instr(p_trading_name,'""')<>0  then
            hr_utility.set_location('EE Surname contains invalid characters',15);
            fnd_message.set_name('PER', 'HR_ZA_INVALID_CHAR');
            fnd_message.set_token('FIELD', 'Employee Trading Name');
            p_ee_msg_tab(l_msg_count):=fnd_message.get('Y');
            l_msg_count := l_msg_count + 1; */
       end if;
    elsif p_nature in ('A','B','C','N') then
       --Validate code 3030
       --Checking IF the Surname IS Null
         IF p_lname IS NULL then
            hr_utility.set_location('EE Surname is null',16);
            fnd_message.set_name('PAY', 'PY_ZA_ENTER_NAT_ABC_S_F_NAME');
--            fnd_message.set_token('FIELD', 'Employee''s Surname');
            p_ee_msg_tab(l_msg_count):=fnd_message.get('Y');
            l_msg_count := l_msg_count + 1;
         END if;
        /* commented as the numeric are allowed in 3030 as it is free text bug 9507670*/
/*       if nvl(length(translate(p_lname,'~0123456789','~')),0) <> length(p_lname) then
            hr_utility.set_location('EE last name contains invalid characters',15);
            fnd_message.set_name('PER', 'HR_ZA_INVALID_CHAR');
            fnd_message.set_token('FIELD', 'Employee''s Surname');
            p_ee_msg_tab(l_msg_count):=fnd_message.get('Y');
            l_msg_count := l_msg_count + 1;
       end if;*/
    end if;

    --Validate First Two Names ( Code 3040 )
    hr_utility.set_location('Validation First Two Names -Code 3040',20);
    if p_nature in ('A','B','C','N')  then
        if p_fname is null and p_mname is null then
            fnd_message.set_name('PAY', 'PY_ZA_ENTER_NAT_ABCN_F_NAME');
            p_ee_msg_tab(l_msg_count):=fnd_message.get('Y');
            l_msg_count := l_msg_count + 1;
            /* commented as the numeric are allowed in first two Names bug 9507670*/
/*        elsif  nvl(length(translate(p_fname,'~0123456789','~')),0) <> nvl(length(p_fname),0)
             OR nvl(length(translate(p_mname,'~0123456789','~')),0) <> nvl(length(p_mname),0) then
            fnd_message.set_name('PER', 'HR_ZA_INVALID_CHAR');
            fnd_message.set_token('FIELD', 'First or Middle Name');
            p_ee_msg_tab(l_msg_count):=fnd_message.get('Y');
            l_msg_count := l_msg_count + 1;*/
       end if;

     --First and Middle name contains invalid characters only
     --characters like ' ',- etc (Invalid characters for Initials
     --Validate Initials
       if nvl(length(translate(p_fname,l_invalid_char||l_alpha,l_invalid_char)),0) = 0
         AND nvl(length(translate(p_mname,l_invalid_char||l_alpha,l_invalid_char)),0) = 0
         AND (p_fname is not null OR p_mname is not null) then
            fnd_message.set_name('PAY', 'PY_ZA_INVALID_INITIALS');
            p_ee_msg_tab(l_msg_count):=fnd_message.get('Y');
            l_msg_count := l_msg_count + 1;
       end if;
    end if;


    --Validate Identity Number (Code 3060)
    hr_utility.set_location('Validating Identity Number -Code 3060',22);
    if p_nature in ('A','C','N') then
        if p_ni is null and p_passport_no is null and p_nature <> 'N' then
            fnd_message.set_name('PAY', 'PY_ZA_ENTER_NAT_ACN_ID_PASSNO');
            p_ee_msg_tab(l_msg_count):=fnd_message.get('Y');
            l_msg_count := l_msg_count + 1;
        end if;
        if nvl(length(p_ni),13)<>13 then
            fnd_message.set_name('PER', 'HR_ZA_INVALID_LENGTH');
            fnd_message.set_token('FIELD', 'ID Number');
            fnd_message.set_token('LENGTH', '13');
            fnd_message.set_token('UNITS', 'digits');
            p_ee_msg_tab(l_msg_count):=fnd_message.get('Y');
            l_msg_count := l_msg_count + 1;
        end if;
        if validate_character_set(p_ni,'NUMERIC')= FALSE then
            fnd_message.set_name('PER', 'HR_ZA_INVALID_CHAR');
            fnd_message.set_token('FIELD', 'ID Number');
            p_ee_msg_tab(l_msg_count):=fnd_message.get('Y');
            l_msg_count := l_msg_count + 1;
        end if;
        if p_ni is not null then
            if modulus_13_test(p_ni)=0 then
                 fnd_message.set_name('PER', 'HR_ZA_INVALID_NI');
                 p_ee_msg_tab(l_msg_count):=fnd_message.get('Y');
                 l_msg_count := l_msg_count + 1;
            end if;
        end if;
        if p_id_dob = 0 then
            fnd_message.set_name('PAY', 'PY_ZA_INVALID_ID_DOB_CORRELAT');
            p_ee_msg_tab(l_msg_count):=fnd_message.get('Y');
            l_msg_count := l_msg_count + 1;
        end if;
    end if;

    --Validate Passport Number (Code 3070)
   hr_utility.set_location('Validating Passport Number -Code 3070',22);
   if p_nature not in ('B','D','E','F','G','H') and p_passport_no is not null then
        if length(p_passport_no)< 7 then
            fnd_message.set_name('PAY', 'PY_ZA_INVALID_MIN_LENGTH');
            fnd_message.set_token('FIELD', 'Passport Number');
            fnd_message.set_token('LENGTH', '7');
            fnd_message.set_token('UNITS', 'characters');
            p_ee_msg_tab(l_msg_count):=fnd_message.get('Y');
            l_msg_count := l_msg_count + 1;
        end if;
        if validate_character_set(p_passport_no,'ALPHANUM')= FALSE then
            fnd_message.set_name('PER', 'HR_ZA_INVALID_CHAR');
            fnd_message.set_token('FIELD', 'Passport Number');
            p_ee_msg_tab(l_msg_count):=fnd_message.get('Y');
            l_msg_count := l_msg_count + 1;
        end if;
   end if;

    --Validate Country of Issue ( Code 3075 )
    --If Nature of Person is B, then country of Issue is archived as ZNC, hence validation not required.
   hr_utility.set_location('Validating Country of Issue -Code 3075',25);
   if (p_country_passport is null and p_passport_no is not null) and p_nature not in ('B','N') then
            fnd_message.set_name('PAY', 'PY_ZA_ENTER_PASS_COUNTRY_ISSUE');
           --Made a warning as per revision 8.0.0 of SARS PAYE Reconiliation 2010 for only Tax Year 2010
            if p_tax_year = 2010 then
                 p_ee_warn_tab(l_warn_count):=fnd_message.get('Y');
                 l_warn_count := l_warn_count + 1;
            else
                 p_ee_msg_tab(l_msg_count):=fnd_message.get('Y');
                 l_msg_count := l_msg_count + 1;
            end if;
   elsif p_country_passport is not null then
       if p_nature <>'B' and validate_character_set(p_country_passport,'ALPHA')= FALSE then
            fnd_message.set_name('PER', 'HR_ZA_INVALID_CHAR');
            fnd_message.set_token('FIELD', 'Country of Passport Issue');
            p_ee_msg_tab(l_msg_count):=fnd_message.get('Y');
            l_msg_count := l_msg_count + 1;
       end if;
       if p_nature <>'B' and length(p_country_passport)> 3 then
            fnd_message.set_name('PER', 'HR_ZA_INVALID_MAX_LENGTH');
            fnd_message.set_token('FIELD', 'Country of Passport Issue');
            fnd_message.set_token('LENGTH', '3');
            fnd_message.set_token('UNITS', 'characters');
            p_ee_msg_tab(l_msg_count):=fnd_message.get('Y');
            l_msg_count := l_msg_count + 1;
       end if;
   end if;

   --Validate code Income Tax Number (Code 3100)
   hr_utility.set_location('Validating Income Tax Number -Code 3100',27);
   if p_it_no_value is null and p_cert_type <> '2' and p_nature <> 'F' then
            fnd_message.set_name('PAY', 'PY_ZA_ENTER_IT_TAX_NO');
            --Made a warning as per revision 8.0.0 of SARS PAYE Reconiliation 2010 for only Tax Year 2010
            if p_tax_year = 2010 then
                 p_ee_warn_tab(l_warn_count):=fnd_message.get('Y');
                 l_warn_count := l_warn_count + 1;
            else
                 p_ee_msg_tab(l_msg_count):=fnd_message.get('Y');
                 l_msg_count := l_msg_count + 1;
            end if;
   elsif p_it_no_value is not null and p_nature <> 'F' then
       --Check the modulus 10 test
       if p_it_no_val = 0 then
            fnd_message.set_name('PAY', 'PY_ZA_INVALID_IT_TAX_NO');
            p_ee_msg_tab(l_msg_count):=fnd_message.get('Y');
            l_msg_count := l_msg_count + 1;
       end if;
       if p_nature in ('A','B','C','D','N') and substr(p_it_no_value,1,1) not in ('0','1','2','3') then
            fnd_message.set_name('PAY', 'PY_ZA_INVALID_NAT_IT_TAX_NO');
            fnd_message.set_token('VALID_NUM', '0, 1, 2 or 3');
            fnd_message.set_token('VALID_NATURE', 'A, B, C, D, or N');
            p_ee_msg_tab(l_msg_count):=fnd_message.get('Y');
            l_msg_count := l_msg_count + 1;
       elsif p_nature in ('E','G','H') and substr(p_it_no_value,1,1) <> '9' then
            fnd_message.set_name('PAY', 'PY_ZA_INVALID_NAT_IT_TAX_NO');
            fnd_message.set_token('VALID_NUM', '9');
            fnd_message.set_token('VALID_NATURE', 'E, G, or H');
            p_ee_msg_tab(l_msg_count):=fnd_message.get('Y');
            l_msg_count := l_msg_count + 1;
       end if;
       if  validate_character_set(p_it_no_value,'NUMERIC')= FALSE then
            fnd_message.set_name('PER', 'HR_ZA_INVALID_CHAR');
            fnd_message.set_token('FIELD', 'Income Tax Number');
            p_ee_msg_tab(l_msg_count):=fnd_message.get('Y');
            l_msg_count := l_msg_count + 1;
       end if;
   end if;

   --Validate Employee Number (Code 3160)
   if validate_character_set(P_EMPNO,'ALPHANUM')= FALSE then
            fnd_message.set_name('PER', 'HR_ZA_INVALID_CHAR');
            fnd_message.set_token('FIELD', 'Employee Number');
            p_ee_msg_tab(l_msg_count):=fnd_message.get('Y');
            l_msg_count := l_msg_count + 1;
   end if;

   hr_utility.set_location('Leaving '||l_proc,200);

end validate_nature;

--------------------------------------------------------------------------
--Validate contact details
--------------------------------------------------------------------------
procedure validate_contact_details(P_PERSON_ID number,
                                   P_NATURE varchar2,
                                   P_EMAIL varchar2,
                                   P_TAX_YEAR_END date,
                                   P_TAX_YEAR number,
                                   P_EE_MSG_TAB IN OUT nocopy msgtext_tab,
                                   P_EE_WARN_TAB IN OUT nocopy msgtext_tab)
is
l_msg_count number(5):=0;
l_proc  varchar2(250):='PAY_ZA_EOY_VAL.VALIDATE_CONTACT_DETAILS';
begin
    l_msg_count := p_ee_msg_tab.count;

    hr_utility.set_location('Entering '||l_proc,10);

    -- Validate email id (Code 3125)
    hr_utility.set_location('Validating Email Address -Code 3125',10);
    if p_email is not null then
        if validate_email_id(p_email) = FALSE then
              fnd_message.set_name('PER', 'HR_ZA_INVALID_CONTACT_EMAIL');
              fnd_message.set_token('CONTACT', 'Employee');
              p_ee_msg_tab(l_msg_count):=fnd_message.get('Y');
              l_msg_count := l_msg_count + 1;
        end if;
        if validate_character_set(p_email,'FREETEXT') = FALSE then
              fnd_message.set_name('PER', 'HR_ZA_INVALID_CHAR');
              fnd_message.set_token('FIELD', 'Employee Email Address');
              p_ee_msg_tab(l_msg_count):=fnd_message.get('Y');
              l_msg_count := l_msg_count + 1;
        end if;
        if length(p_email) > 70 then
              fnd_message.set_name('PER', 'HR_ZA_INVALID_MAX_LENGTH');
              fnd_message.set_token('FIELD', 'Employee Email Address');
              fnd_message.set_token('LENGTH', '70');
              fnd_message.set_token('UNITS', 'characters');
              p_ee_msg_tab(l_msg_count):=fnd_message.get('Y');
              l_msg_count := l_msg_count + 1;
        end if;
    end if;

    --validate the phones i.e. codes 3135 to 3138
    hr_utility.set_location('Validating Phone Numbers',15);
    validate_phones(P_PERSON_ID, P_NATURE, P_TAX_YEAR_END, P_TAX_YEAR, P_EE_MSG_TAB, P_EE_WARN_TAB);

    hr_utility.set_location('Leaving '||l_proc,200);
end validate_contact_details;

---------------------------------------------------------------------------
--Validate Bank Details
---------------------------------------------------------------------------
procedure validate_bank_details(P_PERSON_ID number,
                                   P_ASG_ID number,
                                   P_NATURE varchar2,
                                   P_PAYMENT_TYPE varchar2,
                                   P_PAY_METHOD_ID number,
                                   P_EFFECTIVE_DATE date,
                                   P_TAX_YEAR number,
                                   P_EE_MSG_TAB IN OUT nocopy msgtext_tab,
                                   P_EE_WARN_TAB IN OUT nocopy msgtext_tab )
is
   l_msg_count number(5):=0;
   l_warn_count number(5):=0;
   l_count number :=0;

   -- At Assignment Extra Info, Payment Type contains values
   -- 0 (Cash Payment)
   -- 1 (Internal Account Payment)
   -- 7 (Foreign Bank Account Payment)
   -- If it is 1 (Internal Account Payment),
   -- then account details needs to be validated
   cursor csr_asg_eit_acc
   is
      select pea.external_account_id ext_acc_id,
             pea.segment3 sars_acc_no,
     --        pea.segment2 account_type,
     --        pea.segment1 branch_code,
             pea.segment4 acc_holder_name,
             pea.segment6 acc_holder_reln,
             p_payment_type account_type
      from pay_external_accounts pea,
           pay_personal_payment_methods_f ppm
      where ppm.assignment_id = P_ASG_ID
      and   ppm.personal_payment_method_id = P_PAY_METHOD_ID
      and   ppm.external_account_id = pea.external_account_id
      and   p_effective_date between ppm.effective_start_date and ppm.effective_end_date;

   -- At bank detail DDF, account type contains values
   -- Y (Internal Account Payment)
   -- 0 (Cash Payment)
   -- 7 (Foreign Bank Account Payment)
   -- If it is 1 (Internal Account Payment),
   -- then account details needs to be validated
   cursor csr_bank_ddf_info
   is
      select pea.external_account_id ext_acc_id,
             pea.segment3 sars_acc_no,
             pea.segment4 acc_holder_name,
             pea.segment6 acc_holder_reln,
             ppm.ppm_information1 account_type
      from   pay_personal_payment_methods_f ppm,
             pay_external_accounts pea
      where ppm.assignment_id = P_ASG_ID
      and   ppm.external_account_id = pea.external_account_id(+)
      and   ppm.ppm_information_category in ('ZA_ACB','ZA_CHEQUE','ZA_CREDIT TRANSFER','ZA_MANUAL PAYMENT')
      and   ppm.ppm_information1 in ('Y','0','7')
      and   p_effective_date between ppm.effective_start_date and ppm.effective_end_date;

   rec_asg_bnk_det csr_asg_eit_acc%rowtype;
   l_external_account_id number;
   l_proc varchar2(250):= 'PAY_ZA_OEY_VAL.VALIDATE_BANK_DETAILS';
begin

   hr_utility.set_location('Entering '||l_proc,10);
   l_msg_count := P_EE_MSG_TAB.count;
   l_warn_count := P_EE_WARN_TAB.count;

   select count(*)
   into   l_count
   from   pay_personal_payment_methods_f
   where  assignment_id = P_ASG_ID
   and    PPM_INFORMATION_CATEGORY in ('ZA_ACB','ZA_CHEQUE','ZA_CREDIT TRANSFER','ZA_MANUAL PAYMENT')
   and    ppm_information1 in ('Y','0','7')
   and    p_effective_date between effective_start_date and effective_end_date;

   --Only one account can be set to SARS reporting
   if l_count > 1 then
       fnd_message.set_name('PAY', 'PY_ZA_INV_PERS_PAYM_DDF');
       p_ee_msg_tab(l_msg_count):=fnd_message.get('Y');
       l_msg_count := l_msg_count + 1;
   elsif l_count = 1 then
        open csr_bank_ddf_info;
        fetch csr_bank_ddf_info into rec_asg_bnk_det;
        close csr_bank_ddf_info;
   else  --Bank Detail DDF not set. Hence retrieve from Assignment EIT
         if P_PAY_METHOD_ID is null and P_PAYMENT_TYPE = 1 then
              fnd_message.set_name('PAY', 'PY_ZA_ENTER_REP_ACC_NO');
              p_ee_msg_tab(l_msg_count):=fnd_message.get('Y');
              l_msg_count := l_msg_count + 1;
	 elsif P_PAYMENT_TYPE = 1 then
              open csr_asg_eit_acc;
              fetch csr_asg_eit_acc into rec_asg_bnk_det;
              if csr_asg_eit_acc%notfound then
                   --Raise an error stating the personal payment method doesnt exists
                   fnd_message.set_name('PAY', 'PY_ZA_DEL_PAY_METHOD');
                   p_ee_msg_tab(l_msg_count):=fnd_message.get('Y');
                   l_msg_count := l_msg_count + 1;
              end if;
              close csr_asg_eit_acc;
	 elsif P_PAYMENT_TYPE is null then
              --Raise an error stating the account type is not configured
              fnd_message.set_name('PAY', 'PY_ZA_ENTER_ACC_TYPE');
              p_ee_msg_tab(l_msg_count):=fnd_message.get('Y');
              l_msg_count := l_msg_count + 1;
	 end if;
   end if;

   --Validate the information for account holder's name and relationship
   if rec_asg_bnk_det.account_type in ('Y','1') then
       --Added as per revision 8.0.0 of SARS PAYE Reconiliation 2010
       if rec_asg_bnk_det.acc_holder_name is null then
          fnd_message.set_name('PAY', 'PY_ZA_ENTER_ACC_HOLDER_NAME');
          if p_tax_year=2010 then
               p_ee_warn_tab(l_warn_count):=fnd_message.get('Y');
               l_warn_count := l_warn_count + 1;
          else
               p_ee_msg_tab(l_msg_count):=fnd_message.get('Y');
               l_msg_count := l_msg_count + 1;
          end if;
       end if;

       if validate_character_set(rec_asg_bnk_det.acc_holder_name,'FREETEXT') = FALSE then
          fnd_message.set_name('PER', 'HR_ZA_INVALID_CHAR');
          fnd_message.set_token('FIELD', 'Account Holder''s Name');
          p_ee_msg_tab(l_msg_count):=fnd_message.get('Y');
          l_msg_count := l_msg_count + 1;
       end if;
       if rec_asg_bnk_det.acc_holder_reln is null then
          fnd_message.set_name('PAY', 'PY_ZA_ENTER_ACC_HOLDER_REL');
          --Made warning as per revision 8.0.0 of SARS PAYE Reconiliation 2010 for only Tax Year 2010
          if p_tax_year=2010 then
               p_ee_warn_tab(l_warn_count):=fnd_message.get('Y');
               l_warn_count := l_warn_count + 1;
          else
               p_ee_msg_tab(l_msg_count):=fnd_message.get('Y');
               l_msg_count := l_msg_count + 1;
          end if;
       end if;
   end if;


   hr_utility.set_location('Leaving '||l_proc,100);

end validate_bank_details;
---------------------------------------------------------------------------
--Get Employee Information
---------------------------------------------------------------------------
procedure get_employee_info
(P_BUSINESS_GROUP_ID number,
 P_LEGAL_ENTITY number,
 P_PAYROLL_ID number,
 P_ASG_SET_ID number,
 P_PERSON_ID  number,
 P_TAX_YEAR   number,
 P_TAX_YEAR_START date,
 P_TAX_YEAR_END   date,
 P_CERT_TYPE varchar2,
 P_EE_NDF_INFO OUT nocopy varchar2
)
is
--For ITREG certificate I dont think Warning section is required.
type t_csr_employee is ref cursor;
csr_employee t_csr_employee;


cursor csr_sars_address(p_person_id number, l_effective_date date
                      , p_address_style varchar2, p_address_type varchar2)
is
 select address_line1  ee_unit_num
      , address_line2  ee_complex
      , address_line3  ee_street_num
      , region_1       ee_street_name
      , region_2       ee_suburb_district
      , town_or_city   ee_town_city
      , postal_code    ee_postal_code
   from per_addresses
  where person_id = p_person_id
    and l_effective_date between date_from and nvl(date_to,to_date('31-12-4712','DD-MM-YYYY'))
    and style        = p_address_style
    and address_type = p_address_type;

cursor csr_sars_loc_address(p_location_id number)
is
 select lei_information1  ee_unit_num
      , lei_information2  ee_complex
      , lei_information3  ee_street_num
      , lei_information4  ee_street_name
      , lei_information5  ee_suburb_district
      , lei_information6  ee_town_city
      , lei_information7  ee_postal_code
   from hr_location_extra_info
  where location_id      = p_location_id
    and information_type ='ZA_SARS_ADDRESS';

cursor csr_postal_address(p_person_id number, l_effective_date date)
is
 select nvl(region_2,'N')      ee_indicator        -- Postal Address same as residential address flag
      , decode(region_2,'Y',null,address_line1) ee_add_line1 -- if flag = Y, then don't populate remaining postal address fields
      , decode(region_2,'Y',null,address_line2) ee_add_line2
      , decode(region_2,'Y',null,address_line3) ee_add_line3
      , decode(region_2,'Y',null,postal_code)   ee_postal_code
   from per_addresses
  where person_id = p_person_id
    and l_effective_date between date_from and nvl(date_to,to_date('31-12-4712','DD-MM-YYYY'))
    and style        = 'ZA'
    and primary_flag = 'Y';

l_proc varchar2(250) :='PAY_ZA_EOY_VAL.get_employee_info';
rec_employee csr_employee%type;
type missing_LE_rec is record
( emp_no    per_all_people_f.employee_number%type,
  emp_name  varchar2(600),
  asg_no    per_all_assignments_f.assignment_number%type
);
type missing_LE_table is table of missing_LE_rec index by binary_integer;
l_miss_LE_tab missing_LE_table;
l_ee_msg_tab msgtext_tab;
l_ee_warn_tab msgtext_tab;
l_msg_count number(5):=0;
l_warn_count number(5):=0;
l_tax_year_end date;
l_effective_date date;
l_ee_info varchar2(1):='N';
l_warn_info varchar2(1):='N';
l_miss_LE_warn_info varchar2(1):='N';
rec_sars_bus_address    csr_sars_address%rowtype;
rec_sars_res_address    csr_sars_address%rowtype;
rec_postal_address  csr_postal_address%rowtype;
l_emp_no     per_all_people_f.employee_number%type;
l_person_id  per_all_people_f.person_id%type;
l_assignment_id per_all_assignments_f.assignment_id%type;
l_emp_name   varchar2(600);
l_asg_no     per_all_assignments_f.assignment_number%type;
l_lname      per_all_people_f.last_name%type;
l_fname      per_all_people_f.first_name%type;
l_mname      per_all_people_f.middle_names%type;
l_ni         per_all_people_f.national_identifier%type;
l_location_id per_all_assignments_f.location_id%type;
l_passport_no         varchar2(150);
l_country_passport    varchar2(150);
l_id_dob              number(1);
l_it_no_val           number(1);
l_it_no_value         varchar2(150);
l_email               per_all_people_f.email_address%type;
l_emp_trading_name    varchar2(150);
l_emp_cc_no           varchar2(150);
l_nature              varchar2(3);
l_legal_entity        varchar2(150);
l_payment_type        varchar2(150);
l_personal_pay_meth_id   varchar2(150);
l_organization_id1    varchar2(150);
l_miss_LE_count       number(5):=0;
l_ee_missing_LE_msg   varchar2(90);

l_sql varchar2(4000);
begin
--    hr_utility.trace_on(null,'ZATYEV');
    hr_utility.set_location('Entering '||l_proc,10);

    hr_utility.set_location('P_BUSINESS_GROUP_ID :'||P_BUSINESS_GROUP_ID,10);
    hr_utility.set_location('P_LEGAL_ENTITY  :'||P_LEGAL_ENTITY,10);
    hr_utility.set_location('P_PAYROLL_ID    :'||P_PAYROLL_ID,10);
    hr_utility.set_location('P_ASG_SET_ID    :'||P_ASG_SET_ID,10);
    hr_utility.set_location('P_PERSON_ID     :'||P_PERSON_ID,10);
    hr_utility.set_location('P_TAX_YEAR      :'||P_TAX_YEAR ,10);
    hr_utility.set_location('P_TAX_YEAR_START:'||to_char(P_TAX_YEAR_START,'dd-mon-yyyy hh24:mi:ss'),10);
    hr_utility.set_location('P_TAX_YEAR_END  :'||to_char(P_TAX_YEAR_END,'dd-mon-yyyy hh24:mi:ss'),10);
    hr_utility.set_location('P_CERT_TYPE    :'||P_CERT_TYPE,10);
    hr_utility.set_location('P_TAX_YEAR    :'||P_TAX_YEAR,10);
    hr_utility.trace('g_asg_set_where:'|| g_asg_set_where);
    hr_utility.trace('g_sort_order_clause:'|| g_sort_order_clause);
    l_miss_LE_tab.delete;

    g_xml_element_table(g_xml_element_count).tagname  := 'Employee Information';
    g_xml_element_table(g_xml_element_count).tagvalue := '_COMMENT_';
    g_xml_element_count := g_xml_element_count + 1;

    l_sql :='select   ass.assignment_id ,
         ass.person_id  ,
         per.employee_number ,
         per.last_name || '' ,'' || initcap(per.title) || '' '' || per.first_name ,
         ass.assignment_number ,
         per.last_name ,
         per.first_name  ,
         per.middle_names ,
         per.national_identifier ,
         per.per_information2 ,
         per.per_information10 ,
         pay_za_eoy_val.check_id_dob(per.national_identifier,per.date_of_birth,''Y'') ,
         per.per_information1 ,
         pay_za_eoy_val.modulus_10_test(per.per_information1) ,
         per.email_address ,
         aei.aei_information2 ,
         aei.aei_information3 ,
         hr_general.decode_lookup(''ZA_PER_NATURES'',aei.aei_information4) ,
         aei.aei_information7 ,
         aei.aei_information13 ,
         aei.aei_information14 ,
         nvl(aei.aei_information7,''-1''),
         ass.location_id
from
         per_assignments_f     ass,
         per_all_people_f         per,
         per_assignment_extra_info aei
where
        ass.payroll_id = nvl(:1,ass.payroll_id)
        and ass.business_group_id=:2
        and aei.assignment_id(+)=ass.assignment_id
        and (aei.information_type(+)=''ZA_SPECIFIC_INFO''  )
        and nvl(aei.aei_information7,:3) = :4
        and ( :5 = ''1''
              OR (:6 =''2'' and aei.aei_information4 in (''01'',''02'',''03'',''11''))
             )
        and  exists (select  1
                            from  pay_payroll_actions      ppa,
                                  pay_assignment_actions   paa,
                                  per_time_periods         ptp
                            where
                                  ppa.payroll_id=ass.payroll_id
                                  and paa.assignment_id=ass.assignment_id
                                  and ptp.payroll_id       = ppa.payroll_id
                                  and ptp.prd_information1 = :7
                                  and paa.payroll_action_id=ppa.payroll_action_id
                                  and ptp.time_period_id = ppa.time_period_id
                                  and  ppa.action_type in (''R'', ''Q'', ''V'', ''B'', ''I'')
                                  and  paa.action_status=''C''
                     )
        and  (:8 between ass.effective_start_date and ass.effective_end_date
              OR
                (ass.effective_end_date <=:9
                 and ass.effective_end_date = ( select max(ass1.effective_end_date)
                                                from per_assignments_f ass1
                                                where ass.assignment_id = ass1.assignment_id
                                               )))
        and  per.person_id = ass.person_id
        and  :10 between per.effective_start_date and per.effective_end_date
        and  per.person_id=nvl(:11,per.person_id)
        and  per.per_information_category=''ZA'''||g_asg_set_where||g_sort_order_clause;


    open csr_employee for l_sql using p_payroll_id, p_business_group_id,p_legal_entity, p_legal_entity,
        p_cert_type,p_cert_type,p_tax_year,p_tax_year_end,p_tax_year_end,p_tax_year_end,
                     p_person_id;
    loop
       fetch csr_employee into l_assignment_id,l_person_id,l_emp_no,l_emp_name,l_asg_no
       ,l_lname,l_fname,l_mname,l_ni,l_passport_no,l_country_passport,l_id_dob
       ,l_it_no_value,l_it_no_val,l_email,l_emp_trading_name,l_emp_cc_no,l_nature,l_legal_entity
       ,l_payment_type,l_personal_pay_meth_id,l_organization_id1,l_location_id;
       exit when csr_employee%notfound;
/*
    for rec_employee in csr_employee(p_cert_type)
    loop */
       hr_utility.set_location('Employee Number:'||l_emp_no, 10);
       hr_utility.set_location('Employee Name:'||l_emp_name,10);
       hr_utility.set_location('Legal Entity:'||l_legal_entity,10 );

       l_ee_msg_tab.delete;
       l_ee_warn_tab.delete;

       --Fetch the least of assignment's max effective end date and tax year end date
       select least(max(paaf.effective_end_date),p_tax_year_end)
       into   l_effective_date
       from   per_all_assignments_f paaf
       where  paaf.effective_start_date <= p_tax_year_end
       and    paaf.assignment_id = l_assignment_id;

       hr_utility.set_location('l_effective_date:'||to_char(l_effective_date,'dd-mon-yyyy'),10);

       --Legal entity not provided. Hence populate the warnings table
        if l_legal_entity is null then
            hr_utility.set_location('Legal Entity not provided.',20);

            --create a warnings table for missing legal entities and populate it.
            -- fnd_message.set_name('PAY', 'PY_ZA_ENTER_LEGAL_ENTITY');
            -- l_ee_warn_tab(l_warn_count):=fnd_message.get('Y');
            -- l_warn_count := l_warn_count + 1;
            l_miss_LE_tab(l_miss_LE_count).emp_no:=l_emp_no;
            l_miss_LE_tab(l_miss_LE_count).asg_no:=l_asg_no;
            l_miss_LE_tab(l_miss_LE_count).emp_name:=l_emp_name;
            l_miss_LE_count := l_miss_LE_count + 1;
        else
            hr_utility.set_location('Validating Nature',20);
            -- Validate nature of person

             validate_nature( P_NATURE =>  l_nature
                             ,P_FNAME  =>  l_fname
                             ,P_MNAME  =>  l_mname
                             ,P_LNAME  =>  l_lname
                             ,P_EMPNO  =>  l_emp_no
                             ,P_TRADING_NAME     =>  l_emp_trading_name
                             ,P_NI               =>  l_ni
                             ,P_ID_DOB           =>  l_id_dob
                             ,P_PASSPORT_NO      =>  l_passport_no
                             ,P_COUNTRY_PASSPORT =>  l_country_passport
                             ,P_IT_NO_VALUE      =>  l_it_no_value
                             ,P_IT_NO_VAL        =>  l_it_no_val
                             ,P_CERT_TYPE        =>  p_cert_type
                             ,P_TAX_YEAR         =>  p_tax_year
                             ,P_EE_MSG_TAB       =>  l_ee_msg_tab
                             ,P_EE_WARN_TAB      =>  l_ee_warn_tab
                            );

             l_msg_count := l_ee_msg_tab.count;

             --Validate contact details
             hr_utility.set_location('Validating Contact details',20);
             validate_contact_details( P_PERSON_ID   => l_person_id
                                      ,P_NATURE      => l_nature
                                      ,P_EMAIL       => l_email
                                      ,P_TAX_YEAR_END=> l_effective_date
                                      ,P_TAX_YEAR    => p_tax_year
                                      ,P_EE_MSG_TAB  => l_ee_msg_tab
                                      ,P_EE_WARN_TAB =>  l_ee_warn_tab
                                     );


            --Retrieve employee's business address
             hr_utility.set_location('Retrieve Business address',20);
             open csr_sars_address(l_person_id, l_effective_date,
                                  'ZA_SARS', 'ZA_BUS');
             fetch csr_sars_address into rec_sars_bus_address;
             if csr_sars_address%notfound then
                --Business address not specified at employee level
                --Hence check the address at Extra Location Information for assignment's location id.
                open csr_sars_loc_address(l_location_id);
                fetch csr_sars_loc_address into rec_sars_bus_address;
                if csr_sars_loc_address%notfound then
                     rec_sars_bus_address.ee_unit_num:=null;
                     rec_sars_bus_address.ee_complex:=null;
                     rec_sars_bus_address.ee_street_num:=null;
                     rec_sars_bus_address.ee_street_name:=null;
                     rec_sars_bus_address.ee_suburb_district:=null;
                     rec_sars_bus_address.ee_town_city:=null;
                     rec_sars_bus_address.ee_postal_code:=null;
                end if;
                close csr_sars_loc_address;
             end if;
             close csr_sars_address;

             validate_address( P_STYLE           => 'ZA_SARS'
                              ,P_TAX_YEAR        => p_tax_year
                              ,P_ADDRESS_TYPE    => 'ZA_BUS'
                              ,P_UNIT_NUMBER     => rec_sars_bus_address.ee_unit_num
                              ,P_COMPLEX         => rec_sars_bus_address.ee_complex
                              ,P_STREET_NUMBER   => rec_sars_bus_address.ee_street_num
                              ,P_STREET_NAME     => rec_sars_bus_address.ee_street_name
                              ,P_SUBURB_DISTRICT => rec_sars_bus_address.ee_suburb_district
                              ,P_TOWN_OR_CITY    => rec_sars_bus_address.ee_town_city
                              ,P_POSTAL_CODE     => rec_sars_bus_address.ee_postal_code
                              ,P_NATURE          => l_nature
                              ,P_MSG_TXT         => l_ee_msg_tab
                              ,P_WARN_TXT        => l_ee_warn_tab
                             );

            --Retrieve employee's residential address
             hr_utility.set_location('Retrieve Residential address',20);
             open csr_sars_address(l_person_id, l_effective_date,
                                  'ZA_SARS', 'ZA_RES');
             fetch csr_sars_address into rec_sars_res_address;
             if csr_sars_address%notfound then
                rec_sars_res_address.ee_unit_num:=null;
                rec_sars_res_address.ee_complex:=null;
                rec_sars_res_address.ee_street_num:=null;
                rec_sars_res_address.ee_street_name:=null;
                rec_sars_res_address.ee_suburb_district:=null;
                rec_sars_res_address.ee_town_city:=null;
                rec_sars_res_address.ee_postal_code:=null;
             end if;
             close csr_sars_address;
             --No nature 'N' check for residential address, hence nature not passed.
             validate_address( P_STYLE           => 'ZA_SARS'
                              ,P_TAX_YEAR        => p_tax_year
                              ,P_ADDRESS_TYPE    => 'ZA_RES'
                              ,P_UNIT_NUMBER     => rec_sars_res_address.ee_unit_num
                              ,P_COMPLEX         => rec_sars_res_address.ee_complex
                              ,P_STREET_NUMBER   => rec_sars_res_address.ee_street_num
                              ,P_STREET_NAME     => rec_sars_res_address.ee_street_name
                              ,P_SUBURB_DISTRICT => rec_sars_res_address.ee_suburb_district
                              ,P_TOWN_OR_CITY    => rec_sars_res_address.ee_town_city
                              ,P_POSTAL_CODE     => rec_sars_res_address.ee_postal_code
                              ,P_MSG_TXT         => l_ee_msg_tab
                              ,P_WARN_TXT        => l_ee_warn_tab
                             );

             hr_utility.set_location('Retrieve Postal address',20);
            --Retrieve employee's postal address
            open csr_postal_address(l_person_id, l_effective_date);
            fetch csr_postal_address into rec_postal_address;
            if csr_postal_address%notfound then
                 l_msg_count :=l_ee_msg_tab.count;
                 l_warn_count:=l_ee_warn_tab.count;
                 fnd_message.set_name('PER', 'HR_ZA_PRIM_ADD_STYLE');
                 if p_tax_year = 2010 then
                      l_ee_warn_tab(l_warn_count):=fnd_message.get('Y');
                      l_warn_count := l_warn_count + 1;
                 else
                      l_ee_msg_tab(l_msg_count):=fnd_message.get('Y');
                      l_msg_count := l_msg_count + 1;
                 end if;
            elsif rec_postal_address.ee_indicator = 'N' then
                validate_address( P_STYLE           => 'ZA'
                                 ,P_TAX_YEAR        => p_tax_year
                                 ,P_ADDRESS_LINE1   => rec_postal_address.ee_add_line1
                                 ,P_ADDRESS_LINE2   => rec_postal_address.ee_add_line2
                                 ,P_ADDRESS_LINE3   => rec_postal_address.ee_add_line3
                                 ,P_POSTAL_CODE     => rec_postal_address.ee_postal_code
                                 ,P_MSG_TXT         => l_ee_msg_tab
                                 ,P_WARN_TXT        => l_ee_warn_tab
                               );
            end if;
            close csr_postal_address;

             --Validate bank details
             hr_utility.set_location('Validating bank details',20);
             validate_bank_details(l_person_id,l_assignment_id,l_nature,
                                   l_payment_type,l_personal_pay_meth_id,
                                   l_effective_date, p_tax_year,l_ee_msg_tab,l_ee_warn_tab);

        end if;

        -- Populate XML
        -- If any employee errors present then show the section
        hr_utility.set_location('Populate XML Error Table',50);

        if l_ee_msg_tab.count > 0 and l_ee_info = 'N' then
              hr_utility.set_location('Employee level errors exists',20);
              l_ee_info := 'Y';
              g_xml_element_table(g_xml_element_count).tagname  := 'EE_INFO';
              g_xml_element_table(g_xml_element_count).tagvalue := l_ee_info;
              g_xml_element_count := g_xml_element_count + 1;
        end if;

        if l_ee_msg_tab.count > 0 then
              g_xml_element_table(g_xml_element_count).tagname  := 'EMP';
              g_xml_element_table(g_xml_element_count).tagvalue := '_START_';
              g_xml_element_count := g_xml_element_count + 1;

              g_xml_element_table(g_xml_element_count).tagname  := 'EMP_NO';
              g_xml_element_table(g_xml_element_count).tagvalue := l_emp_no;
              g_xml_element_count := g_xml_element_count + 1;

              g_xml_element_table(g_xml_element_count).tagname  := 'ASG_NO';
              g_xml_element_table(g_xml_element_count).tagvalue := l_asg_no;
              g_xml_element_count := g_xml_element_count + 1;

              g_xml_element_table(g_xml_element_count).tagname  := 'EMP_NAME';
              g_xml_element_table(g_xml_element_count).tagvalue := l_emp_name;
              g_xml_element_count := g_xml_element_count + 1;


              hr_utility.trace('l_ee_msg_tab.first:'||l_ee_msg_tab.first);
              hr_utility.trace('l_ee_msg_tab.last:'||l_ee_msg_tab.last);

              for i in l_ee_msg_tab.first .. l_ee_msg_tab.last
              loop
                   g_xml_element_table(g_xml_element_count).tagname  := 'EE_ERROR';
                   g_xml_element_table(g_xml_element_count).tagvalue := '_START_';
                   g_xml_element_count := g_xml_element_count + 1;

                    g_xml_element_table(g_xml_element_count).tagname  := 'ERROR';
                    g_xml_element_table(g_xml_element_count).tagvalue := l_ee_msg_tab(i);
                    g_xml_element_count := g_xml_element_count + 1;

                   g_xml_element_table(g_xml_element_count).tagname  := 'EE_ERROR';
                   g_xml_element_table(g_xml_element_count).tagvalue := '_END_';
                   g_xml_element_count := g_xml_element_count + 1;

              end loop;

              g_xml_element_table(g_xml_element_count).tagname  := 'EMP';
              g_xml_element_table(g_xml_element_count).tagvalue := '_END_';
              g_xml_element_count := g_xml_element_count + 1;
        end if;

        -- Populate warnings
        hr_utility.set_location('Populate XML Warnings Table',70);
        if l_ee_warn_tab.count > 0 and l_warn_info = 'N' then
              l_warn_info := 'Y';
              g_xml_element_table(g_xml_element_count).tagname  := 'WARN_INFO';
              g_xml_element_table(g_xml_element_count).tagvalue := l_warn_info;
              g_xml_element_count := g_xml_element_count + 1;
       end if;

        if l_ee_warn_tab.count > 0 then
              g_xml_element_table(g_xml_element_count).tagname  := 'WARN_EMP';
              g_xml_element_table(g_xml_element_count).tagvalue := '_START_';
              g_xml_element_count := g_xml_element_count + 1;

              g_xml_element_table(g_xml_element_count).tagname  := 'EMP_NO';
              g_xml_element_table(g_xml_element_count).tagvalue := l_emp_no;
              g_xml_element_count := g_xml_element_count + 1;

              g_xml_element_table(g_xml_element_count).tagname  := 'ASG_NO';
              g_xml_element_table(g_xml_element_count).tagvalue := l_asg_no;
              g_xml_element_count := g_xml_element_count + 1;

              g_xml_element_table(g_xml_element_count).tagname  := 'EMP_NAME';
              g_xml_element_table(g_xml_element_count).tagvalue := l_emp_name;
              g_xml_element_count := g_xml_element_count + 1;

              for i in l_ee_warn_tab.first .. l_ee_warn_tab.last
              loop
                    g_xml_element_table(g_xml_element_count).tagname  := 'EE_WARN';
                    g_xml_element_table(g_xml_element_count).tagvalue := '_START_';
                    g_xml_element_count := g_xml_element_count + 1;

                    g_xml_element_table(g_xml_element_count).tagname  := 'WARN';
                    g_xml_element_table(g_xml_element_count).tagvalue := l_ee_warn_tab(i);
                    g_xml_element_count := g_xml_element_count + 1;

                    g_xml_element_table(g_xml_element_count).tagname  := 'EE_WARN';
                    g_xml_element_table(g_xml_element_count).tagvalue := '_END_';
                    g_xml_element_count := g_xml_element_count + 1;

              end loop;

              g_xml_element_table(g_xml_element_count).tagname  := 'WARN_EMP';
              g_xml_element_table(g_xml_element_count).tagvalue := '_END_';
              g_xml_element_count := g_xml_element_count + 1;
        end if;

    end loop;

    --Report the missing Legal Entities warning
    if l_miss_LE_tab.count > 0 then
           l_miss_LE_warn_info := 'Y';
           g_xml_element_table(g_xml_element_count).tagname  := 'WARN_LE_INFO';
           g_xml_element_table(g_xml_element_count).tagvalue := l_warn_info;
           g_xml_element_count := g_xml_element_count + 1;
    end if;

    if l_miss_LE_tab.count > 0 then
          fnd_message.set_name('PAY', 'PY_ZA_ENTER_LEGAL_ENTITY');
          l_ee_missing_LE_msg:=fnd_message.get('Y');

          for i in l_miss_LE_tab.first .. l_miss_LE_tab.last
          loop
                g_xml_element_table(g_xml_element_count).tagname  := 'WARN_LE_EMP';
                g_xml_element_table(g_xml_element_count).tagvalue := '_START_';
                g_xml_element_count := g_xml_element_count + 1;

                g_xml_element_table(g_xml_element_count).tagname  := 'EMP_NO';
                g_xml_element_table(g_xml_element_count).tagvalue := l_miss_LE_tab(i).emp_no;
                g_xml_element_count := g_xml_element_count + 1;

                g_xml_element_table(g_xml_element_count).tagname  := 'ASG_NO';
                g_xml_element_table(g_xml_element_count).tagvalue := l_miss_LE_tab(i).asg_no;
                g_xml_element_count := g_xml_element_count + 1;

                g_xml_element_table(g_xml_element_count).tagname  := 'EMP_NAME';
                g_xml_element_table(g_xml_element_count).tagvalue := l_miss_LE_tab(i).emp_name;
                g_xml_element_count := g_xml_element_count + 1;
/*
                g_xml_element_table(g_xml_element_count).tagname  := 'EE_WARN';
                g_xml_element_table(g_xml_element_count).tagvalue := '_START_';
                g_xml_element_count := g_xml_element_count + 1;

                g_xml_element_table(g_xml_element_count).tagname  := 'WARN';
                g_xml_element_table(g_xml_element_count).tagvalue := l_ee_missing_LE_msg;
                g_xml_element_count := g_xml_element_count + 1;

                g_xml_element_table(g_xml_element_count).tagname  := 'EE_WARN';
                g_xml_element_table(g_xml_element_count).tagvalue := '_END_';
                g_xml_element_count := g_xml_element_count + 1;
*/

                g_xml_element_table(g_xml_element_count).tagname  := 'WARN_LE_EMP';
                g_xml_element_table(g_xml_element_count).tagvalue := '_END_';
                g_xml_element_count := g_xml_element_count + 1;

          end loop;

    end if;

    if csr_employee%ISOPEN then
         close csr_employee;
    end if;

    g_xml_element_table(g_xml_element_count).tagname  := 'End Employee Information';
    g_xml_element_table(g_xml_element_count).tagvalue := '_COMMENT_';
    g_xml_element_count := g_xml_element_count + 1;

    if l_warn_info='N' and l_ee_info='N' and l_miss_LE_warn_info='N' then
        P_EE_NDF_INFO:='N';
    elsif l_ee_info='N' then
        P_EE_NDF_INFO:='Y';
    end if;

    hr_utility.set_location('l_warn_info:'||l_warn_info,100);
    hr_utility.set_location('l_ee_info:'||l_ee_info,100);
    hr_utility.set_location('P_EE_NDF_INFO:'||P_EE_NDF_INFO,100);
    hr_utility.set_location('Leaving '||l_proc,200);
end get_employee_info;

procedure get_tyev_xml(
                      P_PROCESS_NAME          IN varchar2,
                      P_BUSINESS_GROUP_ID     IN number,
                      P_ACTN_PARAMTR_GRP_ID   IN number,
                      P_LEGAL_ENTITY          IN number,
                      P_LEGAL_ENTITY_HIDDEN   IN varchar2,
                      P_TAX_YEAR              IN varchar2,
                      P_TAX_YEAR_H            IN varchar2,
                      P_CERT_TYPE             IN varchar2,
                      P_CERT_TYPE_H           IN varchar2,
                      P_PAYROLL_ID            IN number,
                      P_PAYROLL_ID_H          IN varchar2,
                      P_START_DATE            IN varchar2,
                      P_END_DATE              IN varchar2,
                      P_ASG_SET_ID            IN number,
                      P_ASG_SET_ID_H          IN varchar2,
                      P_PERSON_ID             IN number,
                      P_PERSON_ID_H           IN varchar2,
                      P_TEST_RUN              IN varchar2,
                      P_SORT_ORDER1           IN varchar2,
                      P_SORT_ORDER2           IN varchar2,
                      P_SORT_ORDER3           IN varchar2,
                      P_MONTHLY_RUN           IN varchar2,
                      p_template_name         IN varchar2,
                      p_xml out nocopy CLOB
)
is

l_proc varchar2(250):='PAY_ZA_EOY_VAL.GET_TYEV_XML';
--g_xml_element_count number(5):=0;
p_clob              clob;
l_tax_year          number(4);
l_tax_year_start_v  varchar2(20);
l_tax_year_end_v    varchar2(20);
l_tax_year_start    date;
l_tax_year_end      date;
--g_asg_set_where     varchar2(500);
--g_sort_order_clause varchar2(500);
l_req_id            number;
--Variables to indicate no data found (NDF) in the template
l_er_ndf_info       varchar2(1);
l_ee_ndf_info       varchar2(1);
l_archiver_flag     number(1):=0;

/*

cursor csr_payrolls (l_tax_year number)
IS
select distinct payroll_id
from pay_all_payrolls_f papf
where business_group_id = P_BUSINESS_GROUP_ID
and   exists (        select ''
                      from per_time_periods ptp2
                      where ptp2.prd_information1=l_tax_year
                      and   ptp2.payroll_id = papf.payroll_id
             );
*/

begin
 -- hr_utility.trace_on(null,'ZATYEV');
  hr_utility.set_location('Entering '||l_proc,10);

  g_xml_element_table.DELETE;
  g_xml_element_count:=0;
  ---
  -- Start XML
  ---
  g_xml_element_table(g_xml_element_count).tagname  := 'ZATYE2010';
  g_xml_element_table(g_xml_element_count).tagvalue := '_START_';
  g_xml_element_count := g_xml_element_count + 1;


  g_xml_element_table(g_xml_element_count).tagname  := 'Parameter Information';
  g_xml_element_table(g_xml_element_count).tagvalue := '_COMMENT_';
  g_xml_element_count := g_xml_element_count + 1;

  -- Tax Year Information
  l_tax_year :=rtrim(substr(P_TAX_YEAR_H,10,4));



  l_tax_year_start:=fnd_date.canonical_to_date(substr(P_START_DATE,12,10));
  l_tax_year_end  :=fnd_date.canonical_to_date(substr(P_END_DATE,10,10));


  hr_utility.set_location('Before retrieving parameter info',10);

  -- Retrieve parameter details
  get_tyev_parameters(P_LEGAL_ENTITY => P_LEGAL_ENTITY
                     ,P_PAYROLL_ID   => P_PAYROLL_ID
                     ,P_TAX_YEAR     => l_TAX_YEAR
                     ,P_CERT_TYPE    => P_CERT_TYPE
                     ,P_ASG_SET_ID   => P_ASG_SET_ID
                     ,P_PERSON_ID    => P_PERSON_ID
                     ,P_TEST_RUN     => P_TEST_RUN
                     ,P_TAX_YEAR_END => l_tax_year_end
                     ,P_SORT_ORDER1  => P_SORT_ORDER1
                     ,P_SORT_ORDER2  => P_SORT_ORDER2
                     ,P_SORT_ORDER3  => P_SORT_ORDER3
                     );

  hr_utility.set_location('Before retrieving Employer info',10);
  -- Retrieve Employer specific errors/warnings
  get_employer_info(P_BUSINESS_GROUP_ID   => P_BUSINESS_GROUP_ID
                   ,P_LEGAL_ENTITY        => P_LEGAL_ENTITY
                   ,P_TAX_YEAR            => l_TAX_YEAR
                   ,P_ER_INFO             => l_er_ndf_info
                    );

  hr_utility.set_location('Before retrieving Employee info',10);
  -- Retrieve Employee specific errors/warnings
  get_employee_info(P_BUSINESS_GROUP_ID  => P_BUSINESS_GROUP_ID
                   ,P_LEGAL_ENTITY       => P_LEGAL_ENTITY
                   ,P_PAYROLL_ID         => P_PAYROLL_ID
                   ,P_ASG_SET_ID         => P_ASG_SET_ID
                   ,P_PERSON_ID          => P_PERSON_ID
                   ,P_TAX_YEAR           => l_tax_year
                   ,P_TAX_YEAR_START     => l_tax_year_start
                   ,P_TAX_YEAR_END       => l_tax_year_end
                   ,P_CERT_TYPE          => P_CERT_TYPE
                   ,P_EE_NDF_INFO        => l_ee_ndf_info
                   );

  if l_ee_ndf_info='N' and l_er_ndf_info='N' then
     g_xml_element_table(g_xml_element_count).tagname  := 'NDF';
     g_xml_element_table(g_xml_element_count).tagvalue := 'Y';
     g_xml_element_count := g_xml_element_count + 1;
  end if;

  g_xml_element_table(g_xml_element_count).tagname  := 'ZATYE2010';
  g_xml_element_table(g_xml_element_count).tagvalue := '_END_';
  g_xml_element_count := g_xml_element_count + 1;

/*
  dbms_lob.createtemporary(p_clob, FALSE, DBMS_LOB.CALL);
  dbms_lob.open(p_clob, DBMS_LOB.LOB_READWRITE);
  --
  dbms_lob.writeappend(p_clob, 10, '<AB>1</AB>');
p_xml:=p_clob;
*/
    write_to_clob(p_xml);

    hr_utility.set_location('l_ee_ndf_info:'||l_ee_ndf_info,40);
    hr_utility.set_location('l_er_ndf_info:'||l_er_ndf_info,40);
    hr_utility.set_location('P_MONTHLY_RUN:'||P_MONTHLY_RUN,40);
    hr_utility.set_location('P_TEST_RUN:'||P_TEST_RUN,40);


    if (P_TEST_RUN='Y' OR (l_ee_ndf_info is not null and l_er_ndf_info<>'Y'))
    then
       --No errors encountered for Non Test Run Annual report
        if P_TEST_RUN='N' then
             if P_MONTHLY_RUN='N' then
                 FND_FILE.PUT_LINE(FND_FILE.LOG,'Tax Year End data has been validated and appears correct.');
             else
                 FND_FILE.PUT_LINE(FND_FILE.LOG,'No errors identified when validating tax year end data.');
             end if;
        end if;

        if P_MONTHLY_RUN='N' then
           l_req_id := fnd_request.submit_request( 'PAY',
                                               'PYZAIRPA2010',
                                                'Tax Certificate Preprocess',NULL,NULL,
                                                'ARCHIVE','ZA_TYE','Tax Certificate Preprocess',
                                                '','',
                                                'ARCHIVE',P_BUSINESS_GROUP_ID,null,-- action_param_group
                                                P_LEGAL_ENTITY, P_LEGAL_ENTITY_HIDDEN,
                                                P_TAX_YEAR, P_TAX_YEAR_H,
                                                P_CERT_TYPE, P_CERT_TYPE_H,
                                                P_PAYROLL_ID,P_PAYROLL_ID_H,
                                                P_START_DATE,P_END_DATE,
                                                P_ASG_SET_ID,P_ASG_SET_ID_H,
                                                P_PERSON_ID,P_PERSON_ID_H,
                                                chr(0),
                                                '','','','','','','',
                                                       '','','','','','','','','','',
                                                       '','','','','','','','','','',
                                                       '','','','','','','','','','',
                                                       '','','','','','','','','','',
                                                       '','','','','','','','','','',
                                                       '','','','','','','','','','',
                                                       '','','','','','','','','','');
        end if;
    else
        if P_TEST_RUN ='N' then
             --errors found and archiver was not fired
            if P_MONTHLY_RUN='N' then
               FND_FILE.PUT_LINE(FND_FILE.LOG,'Tax Year End data errors exist. Refer to Tax Year End Data Validation Report output and correct the data.');
           else
               FND_FILE.PUT_LINE(FND_FILE.LOG,'Errors identified when validating tax year end data. Refer to the Tax Year End Data Validation Report output for further details.');
           end if;
        end if;
    end if;


end get_tyev_xml;


PROCEDURE VALIDATE_TYE_DATA_EOY2010 (
                      errbuf                     out nocopy varchar2,
                      retcode                    out nocopy number,
                      p_payroll_action_id        in pay_payroll_actions.payroll_action_id%type,
                      p_tax_yr_start_date        IN DATE,
                      p_tax_yr_end_date          IN DATE,
                      p_tax_year                 IN number
                      )
is

     -- Fetch the assignment actions processed in the Tax Certificate Preprocess.
     CURSOR asgn_for_payroll_action_cur IS
        SELECT assignment_id, assignment_action_id
        FROM   pay_assignment_actions
        WHERE  payroll_action_id = p_payroll_action_id
        ORDER BY assignment_id ;

      --Fetch the assignment details
      CURSOR emp_number_cur ( asgn_ac_id pay_assignment_actions.assignment_action_id%TYPE) IS
        SELECT  per.employee_number empno, asgn2.assignment_number assgno
        FROM    pay_assignment_actions paa,
                per_all_assignments_f asgn2,
                per_all_people_f per
        WHERE paa.assignment_action_id = asgn_ac_id
         AND asgn2.assignment_id      = paa.assignment_id
         AND per.person_id            = asgn2.person_id
         AND asgn2.effective_start_date =
           ( select max(paf2.effective_start_date)
             from   per_assignments_f paf2
             where paf2.effective_start_date <= ( select max(ptp.end_date)
                                                  from per_time_periods ptp
                                                  where ptp.prd_information1 = p_tax_year
                                                  and ptp.payroll_id = asgn2.payroll_id)
             and    paf2.assignment_id         = asgn2.assignment_id
          )
        AND asgn2.effective_start_date between per.effective_start_date and per.effective_end_date;


      -- Retrieve the Tax details for main certificate
      CURSOR tax_info ( asgn_ac_id pay_assignment_actions.assignment_action_id%TYPE
                       ,cert_num varchar2) IS
        select nvl(pai.action_information3,0)  SITE,
               nvl(pai.action_information11,0) PAYE,
               nvl(pai.action_information10,0) TAX
        from   pay_action_information pai
        where  pai.action_context_id = asgn_ac_id
        and    pai.action_context_type = 'AAP'
        and    pai.action_information_category = 'ZATYE_EMPLOYEE_TAX_AND_REASONS'
        and    pai.action_information30 = cert_num;

      -- Retrieve the number of income codes for main certificate
      -- Lump sum codes are less than 13, hence the number of income codes in
      -- lumpsum certificate cannot exceed 13.
      CURSOR csr_num_inc_codes ( asgn_ac_id pay_assignment_actions.assignment_action_id%TYPE
                       ,cert_num varchar2) IS
        select count(1)
        from   pay_action_information pai
        where  pai.action_context_id = asgn_ac_id
        and    pai.action_context_type = 'AAP'
        and    ( pai.action_information_category = 'ZATYE_EMPLOYEE_INCOME'
                 OR
                 pai.action_information_category = 'ZATYE_EMPLOYEE_LUMPSUMS'
               )
        and    pai.action_information30 = cert_num
        and    pai.action_information3 is null
        and    pai.action_information2 <> '3907'
        and    trunc(to_number(pay_za_eoy_val.decimal_character_conversion(nvl(pai.action_information5,0)))) <> 0;

      CURSOR csr_num_3907 ( asgn_ac_id pay_assignment_actions.assignment_action_id%TYPE
                       ,cert_num varchar2) IS
        select 1
        from   pay_action_information pai
        where  pai.action_context_id = asgn_ac_id
        and    pai.action_context_type = 'AAP'
        and    ( pai.action_information_category = 'ZATYE_EMPLOYEE_INCOME'
                 OR
                 pai.action_information_category = 'ZATYE_EMPLOYEE_LUMPSUMS'
               )
        and    pai.action_information30 = cert_num
        and    pai.action_information3 is null
        and    pai.action_information2 = '3907'
        and    trunc(to_number(pay_za_eoy_val.decimal_character_conversion(nvl(pai.action_information5,0)))) <> 0;


      -- Retrieve the number of deduction codes. These exist in main certificate only
      CURSOR csr_num_ded_codes ( asgn_ac_id pay_assignment_actions.assignment_action_id%TYPE
                       ,cert_num varchar2) IS
        select count(1)
        from   pay_action_information pai
        where  pai.action_context_id = asgn_ac_id
        and    pai.action_context_type = 'AAP'
        and    pai.action_information_category = 'ZATYE_EMPLOYEE_DEDUCTIONS'
        and    pai.action_information30 = cert_num
        and    pai.action_information3 is null
        and    trunc(to_number(pay_za_eoy_val.decimal_character_conversion(nvl(pai.action_information5,0)))) <> 0;


       -- Retrieve main certificate number
      CURSOR csr_cert_num( asgn_ac_id pay_assignment_actions.assignment_action_id%TYPE) IS
        select pai.action_information30 temp_cert_num
               ,pai2.action_information2 cert_type --IRP5/IT3A/ITREG
        from   pay_action_information pai
              ,pay_action_information pai2
        where  pai.action_context_id = asgn_ac_id
        and    pai.action_context_type = 'AAP'
        and    pai.action_information_category = 'ZATYE_EMPLOYEE_CONTACT_INFO'
        and    pai2.action_information_category ='ZATYE_EMPLOYEE_INFO'
        and    pai2.action_context_id=pai.action_context_id
        and    pai2.action_context_type=pai.action_context_type
        and    pai.action_information26='MAIN'
        and    pai2.action_information30=pai.action_information30;


     --Retrieve negative normal incomes (not lump sums). These are included in main certificate only
     CURSOR csr_neg_income(p_asgn_action_id pay_assignment_actions.assignment_action_id%TYPE
                             ,p_cert_num varchar2 ) IS
        select pai.action_information2 code,
            trunc(to_number(pay_za_eoy_val.decimal_character_conversion(nvl(pai.action_information5,0))))  value --code_group_value
        FROM   pay_action_information pai
        where  pai.action_context_id = p_asgn_action_id
          and  pai.action_context_type = 'AAP'
          and  pai.action_information_category = 'ZATYE_EMPLOYEE_INCOME'
          and  pai.action_information30 = p_cert_num
          and  pai.action_information3 is null  --code included in
          and  trunc(to_number(pay_za_eoy_val.decimal_character_conversion(nvl(pai.action_information5,0)))) < 0
     order by  pai.action_information2;

     --Retrieve negative lump sums. These are included in main certificate.
     CURSOR csr_neg_lmpsm(p_asgn_action_id pay_assignment_actions.assignment_action_id%TYPE
                         ,p_cert_num varchar2 ) IS
        select pai.action_information2 code,
            'To Be Advised'      to_be_adv,
            nvl(pai.action_information4,0)  to_be_adv_val, --To Be Advised value
            pai.action_information7         direct1,
            nvl(pai.action_information8,0)  value1,
            pai.action_information9         direct2,
            nvl(pai.action_information10,0) value2,
            pai.action_information11        direct3,
            nvl(pai.action_information12,0) value3
        FROM   pay_action_information pai
        where  pai.action_context_id = p_asgn_action_id
          and  pai.action_context_type = 'AAP'
          and  pai.action_information_category = 'ZATYE_EMPLOYEE_LUMPSUMS'
          and  pai.action_information30 = p_cert_num
          and  pai.action_information3 is null  --code included in
          and  (trunc(to_number(pay_za_eoy_val.decimal_character_conversion(nvl(pai.action_information5,0)))) < 0
                )
     order by  pai.action_information2;

     --Retrieve negative lump sums. These are included in lump sum certificate.
     --p_cert_num is main certificate number
     CURSOR csr_neg_lmpsm2(p_asgn_action_id pay_assignment_actions.assignment_action_id%TYPE
                         ,p_cert_num varchar2 ) IS
        select pai.action_information2 code,
               pai.action_information5 value,
               pai2.action_information18 direct1
        FROM   pay_action_information pai,
               pay_action_information pai2
        where  pai.action_context_id = p_asgn_action_id
          and  pai.action_context_type = 'AAP'
          and  pai.action_information_category = 'ZATYE_EMPLOYEE_LUMPSUMS'
          and  pai2.action_information_category ='ZATYE_EMPLOYEE_INFO'
          and  pai2.action_context_id = pai.action_context_id
          and  pai2.action_context_type = pai.action_context_type
          and  pai.action_information30 = pai2.action_information30
          and  pai.action_information30 <> p_cert_num
          and  pai.action_information3 is null  --code included in
          and  (trunc(to_number(pay_za_eoy_val.decimal_character_conversion(nvl(pai.action_information5,0)))) < 0
                )
     order by  pai.action_information2;


     --Retrieve negative deductions. These are included in main certificate only
     CURSOR csr_neg_deduct(p_asgn_action_id pay_assignment_actions.assignment_action_id%TYPE
                             ,p_cert_num varchar2 ) IS
        select pai.action_information2 code,
            trunc(to_number(pay_za_eoy_val.decimal_character_conversion(nvl(pai.action_information5,0))))  value --code_group_value
        FROM   pay_action_information pai
        where  pai.action_context_id = p_asgn_action_id
          and  pai.action_context_type = 'AAP'
          and  pai.action_information_category = 'ZATYE_EMPLOYEE_DEDUCTIONS'
          and  pai.action_information30 = p_cert_num
          and  pai.action_information3 is null  --code included in
          and trunc(to_number(pay_za_eoy_val.decimal_character_conversion(nvl(pai.action_information5,0)))) < 0
     order by  pai.action_information2;

     -- Retrieve the PAYE Reference number of the employer
     CURSOR csr_paye_ref_num IS
        SELECT pai.action_information2 PAYE_REF_NUM
          FROM pay_action_information pai
         WHERE pai.action_context_id = p_payroll_action_id
           AND pai.action_context_type = 'PA'
           AND pai.action_information_category = 'ZATYE_EMPLOYER_INFO';

      -- Retrieve the value for Tax and Tax on Retirement Fund
      CURSOR tax_codes ( asgn_ac_id pay_assignment_actions.assignment_action_id%TYPE) IS
        select '1'
        from   pay_action_information pai
        where  pai.action_context_id = asgn_ac_id
        and    pai.action_context_type = 'AAP'
        and    pai.action_information_category = 'ZATYE_EMPLOYEE_TAX_AND_REASONS'
        and    ( trunc(to_number(pay_za_eoy_val.decimal_character_conversion(nvl(pai.action_information10,0)))) <> 0
                 OR
                 trunc(to_number(pay_za_eoy_val.decimal_character_conversion(nvl(pai.action_information5,0)))) <> 0
               )
               ;


    --Check whether the employee on specific income has PKG balances
    CURSOR fetch_pkg_balances( p_asgn_action_id pay_assignment_actions.assignment_action_id%type
                                , p_cert_num varchar2 ) IS
       select '1' flag
       FROM   pay_action_information pai,
              per_assignment_extra_info paei
       where  pai.action_context_id = p_asgn_action_id
          and paei.assignment_id    = pai.assignment_id
          AND paei.AEI_INFORMATION8 <> '1' -- 'Pension Basis:1 is Fixed Percentage of Specific Income
          AND paei.information_type = 'ZA_SPECIFIC_INFO'
          and pai.action_information_category = 'ZATYE_EMPLOYEE_GROSS_REMUNERATIONS'
          and pai.action_information30 = p_cert_num
          AND pay_za_eoy_val.decimal_character_conversion(nvl(pai.action_information5,0)) <> '0'; --Gross PKG

    --Retrieve the elements feeding PKG balances.
    CURSOR fetch_pkg_ele( p_asgn_action_id pay_assignment_actions.assignment_action_id%type) IS
      SELECT  ELEM.element_name element_name,
            sum(trunc(to_number(pay_za_eoy_val.decimal_character_conversion(nvl(TARGET.RESULT_VALUE,0)))))
      from   pay_balance_feeds_f               FEED
           , pay_run_result_values             TARGET
           , pay_run_results                   RR
           , per_time_periods                  PPTP
           , per_time_periods                  BPTP
           , pay_payroll_actions               PACT
           , pay_assignment_actions            ASSACT
           , pay_payroll_actions               BACT
           , pay_assignment_actions            BAL_ASSACT
           , pay_element_types_f               ELEM
           , pay_balance_types                 PBT
       where BAL_ASSACT.assignment_action_id = p_asgn_action_id
         and BAL_ASSACT.payroll_action_id    = BACT.payroll_action_id
         and FEED.input_value_id             = TARGET.input_value_id
         and TARGET.run_result_id            = RR.run_result_id
         and RR.assignment_action_id         = ASSACT.assignment_action_id
         + decode(PPTP.year_number, 0, 0, 0)
         and ASSACT.payroll_action_id        = PACT.payroll_action_id
         and PACT.effective_date       between FEED.effective_start_date
                                           and FEED.effective_end_date
         and BPTP.payroll_id                 = BACT.payroll_id
         and PPTP.payroll_id                 = PACT.payroll_id
         and nvl(BACT.date_earned,BACT.effective_date)
                                       between BPTP.start_date and BPTP.end_date
         and PACT.date_earned          between PPTP.start_date and PPTP.end_date
         and RR.status                      in ('P','PA')
         AND ELEM.element_type_id = RR.element_type_id
         and PPTP.prd_information1           = BPTP.prd_information1
         and ASSACT.action_sequence         <= BAL_ASSACT.action_sequence
         and ASSACT.assignment_id            = BAL_ASSACT.assignment_id
         AND feed.BALANCE_TYPE_ID            = PBT.balance_type_id
         AND PBT.balance_name               in ('Taxable Package Components',
                                                'Annual Taxable Package Components'
                                               )
         GROUP BY ELEM.element_name
         HAVING sum(trunc(to_number(pay_za_eoy_val.decimal_character_conversion(nvl(TARGET.RESULT_VALUE,0))))) <> 0;


    -- Retrieve the value of code 4115
    CURSOR chk_tax_ret_fund_ls ( p_asgn_action_id pay_assignment_actions.assignment_action_id%type) IS
        select pai.action_information5,
               pai.action_information30 temp_cert_num,
               pai2.action_information18 direct1 --Directive1
        FROM   pay_action_information pai,
               pay_action_information pai2
        where  pai.action_context_id = p_asgn_action_id
          and  pai.action_context_type = 'AAP'
          and  pai.action_information_category = 'ZATYE_EMPLOYEE_TAX_AND_REASONS'
          and  pai2.action_information_category = 'ZATYE_EMPLOYEE_INFO'
          and  pai.action_context_id = pai2.action_context_id
          and  pai.action_context_type = pai2.action_context_type
          and  pai.action_information30 = pai2.action_information30
          and  trunc(to_number(pay_za_eoy_val.decimal_character_conversion(nvl(pai.action_information5,0)))) <> 0
     order by  pai.action_information30;

    --Retrieve the value of codes 3915,3920, 3921 for certificate which has some value in code 4115
    CURSOR chk_ret_fund_ls ( p_asgn_action_id pay_assignment_actions.assignment_action_id%type
                            ,p_cert_num varchar2) IS
        select pai.action_information2 code, --either 3920, 3921, 3915
               pai.action_information30 temp_cert_num
        FROM   pay_action_information pai
        where  pai.action_context_id = p_asgn_action_id
          and  pai.action_context_type = 'AAP'
          and  pai.action_information_category = 'ZATYE_EMPLOYEE_LUMPSUMS'
          and  pai.action_information30 = p_cert_num
          and  pai.action_information3 is null  --code included in
          and  to_number(pai.action_information2) in (3915,3920,3921)
          and  trunc(to_number(pay_za_eoy_val.decimal_character_conversion(nvl(pai.action_information5,0)))) <> 0
     order by  pai.action_information2;


    -- Cursor for cross validation - Income codes - Main certificate only
    CURSOR cross_val_inc_codes ( p_asgn_action_id pay_assignment_actions.assignment_action_id%type
                                ,p_cert_num varchar2) IS
        select to_number(pai.action_information2) code --income code
              ,trunc(to_number(pay_za_eoy_val.decimal_character_conversion(nvl(pai.action_information5,0)))) value--income value
              ,pai.action_information30 temp_cert_num
          from pay_action_information pai
         where pai.action_context_id = p_asgn_action_id
           and pai.action_context_type='AAP'
           and pai.action_information_category = 'ZATYE_EMPLOYEE_INCOME'
           and pai.action_information3 is null
           and to_number(pai.action_information2) in (3810,3813,3860,3863)
           and pai.action_information30=p_cert_num
         order by pai.action_information30;

    -- Cursor for cross validation - Deduction codes --Main Certificate only
    CURSOR cross_val_ded_codes ( p_asgn_action_id pay_assignment_actions.assignment_action_id%type
                                ,p_cert_num varchar2) IS
        select to_number(pai.action_information2) code --deduction code
              ,trunc(to_number(pay_za_eoy_val.decimal_character_conversion(nvl(pai.action_information5,0)))) value--deduction value
              ,pai.action_information30 temp_cert_num
          from pay_action_information pai
         where pai.action_context_id = p_asgn_action_id
           and pai.action_context_type='AAP'
           and pai.action_information_category = 'ZATYE_EMPLOYEE_DEDUCTIONS'
           and pai.action_information3 is null
           and to_number(pai.action_information2) in (4005,4024,4474,4493)
           and pai.action_information30=p_cert_num
         order by pai.action_information30;

    --Retrieve negative values for context ZATYE_EMPLOYEE_TAX_AND_REASONS
    CURSOR chk_neg_tax ( p_asgn_action_id pay_assignment_actions.assignment_action_id%type)
                         IS
        select pai.action_information30 temp_cert_num,
               pai2.action_information18 direct1, --Directive1
               nvl(pai.action_information3,0) site,
               nvl(pai.action_information4,0) paye,
               nvl(pai.action_information5,0) tax_ret,
               nvl(pai.action_information6,0) uif,
               nvl(pai.action_information7,0) sdl,
               nvl(pai.action_information8,0) total
        FROM   pay_action_information pai,
               pay_action_information pai2
        where  pai.action_context_id = p_asgn_action_id
          and  pai.action_context_type = 'AAP'
          and  pai.action_information_category = 'ZATYE_EMPLOYEE_TAX_AND_REASONS'
          and  pai.action_information3 is null  --code included in
          and  pai2.action_information_category = 'ZATYE_EMPLOYEE_INFO'
          and  pai2.action_context_id = pai.action_context_id
          and  pai.action_context_type = pai2.action_context_type
          and  pai.action_information30 = pai2.action_information30
          and  (trunc(to_number(pay_za_eoy_val.decimal_character_conversion(nvl(pai.action_information3,0)))) < 0
                 OR trunc(to_number(pay_za_eoy_val.decimal_character_conversion(nvl(pai.action_information4,0)))) < 0
                 OR trunc(to_number(pay_za_eoy_val.decimal_character_conversion(nvl(pai.action_information5,0)))) < 0
                 OR trunc(to_number(pay_za_eoy_val.decimal_character_conversion(nvl(pai.action_information6,0)))) < 0
                 OR trunc(to_number(pay_za_eoy_val.decimal_character_conversion(nvl(pai.action_information7,0)))) < 0
                 OR trunc(to_number(pay_za_eoy_val.decimal_character_conversion(nvl(pai.action_information8,0)))) < 0
               )
     order by  pai.action_information2;



        rec_info tax_info%rowtype;
        rec_ret_fund_ls chk_ret_fund_ls%rowtype;
        l_msgtext varchar2(2000);
        l_empno per_all_people_f.employee_number%type;
        l_assgno per_all_assignments_f.assignment_number%type;
        l_count number(1):=0;
        l_main_cert_num varchar2(30);
        l_cert_type  varchar2(10);
        l_code number(4);
        l_index varchar2(50);
        l_cert_num varchar2(30);
        l_num_ded_codes number(2);
        l_num_inc_codes number(2);
        l_num_inc_temp  number(2);
        l_paye_ref_num number(10);
        l_tax_code_ind varchar2(1);
        l_run_ass_act_id number;
        l_run_action_seq number;
        l_directive1 varchar2(100);
        l_ass_act_id pay_assignment_actions.assignment_action_id%type;
        l_leg_param pay_payroll_actions.legislative_parameters%type;

        type cross_val_tab is table of number index by binary_integer;
        --Index in above table is temp certificate num + code
        cross_val_t cross_val_tab;

begin
    retcode := 0;
  --  hr_utility.trace_on(null,'ZATYEVL');
    FND_FILE.PUT_LINE(FND_FILE.LOG,'In validate_tye_data');
    FND_FILE.PUT_LINE(FND_FILE.LOG,'p_payroll_action_id    :' || p_payroll_action_id);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Inside validate_tye_data');

    --For ITREG no validations required as codes are not archived.
    select legislative_parameters
    into   l_leg_param
    from   pay_payroll_actions
    where  payroll_action_id = p_payroll_action_id;

    --For ITREG certificate dont do any validations
    if pay_za_irp5_archive_pkg.get_parameter('CERT_TYPE', l_leg_param)=2 then
         hr_utility.set_location('ITREG Certificate',10);
         return;
    end if;

     /*Loop through all Assignments for given payroll_action_id*/
    FOR rec_asgn IN asgn_for_payroll_action_cur
    LOOP
         l_count:=0;
         l_num_inc_codes:=0;
         l_ass_act_id:=rec_asgn.assignment_action_id;

         --Fetch employee number and assignment number
         FOR emp_num IN emp_number_cur(l_ass_act_id)
         LOOP
             l_empno := emp_num.empno ;
             l_assgno:= emp_num.assgno;
         END LOOP;
         hr_utility.set_location('Processing Employee:'||l_empno,15);

         --Fetch the temporary number generated for main certificate
         hr_utility.set_location('Fetching Main certificate Number',15);
         open csr_cert_num(l_ass_act_id);
         fetch csr_cert_num into l_main_cert_num,l_cert_type;
         close csr_cert_num;

         hr_utility.set_location('l_main_cert_num:'||l_main_cert_num,15);
         hr_utility.set_location('l_cert_type:    '||l_cert_type,15);

         -- Check whether the SITE PAYE split exists
         hr_utility.set_location('Fetching Tax Details',15);


         open tax_info(l_ass_act_id,l_main_cert_num);
         fetch tax_info into rec_info;
         close tax_info;
         hr_utility.set_location('Fetched Tax Details',15);

         if rec_info.tax <>0 and (rec_info.site=0 and rec_info.paye=0) then
             l_count:=1;
             FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
             FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
             FND_FILE.PUT_LINE(FND_FILE.LOG, 'Employee Number   : ' || l_empno);
             FND_FILE.PUT_LINE(FND_FILE.LOG, 'Assignment Number : ' || l_assgno);
             fnd_message.set_name('PAY', 'PY_ZA_NO_SITE_PAYE_SPLIT');
             fnd_message.set_token('EMPNO',l_empno);
             l_msgtext := fnd_message.get('Y');
             FND_FILE.PUT_LINE(FND_FILE.LOG, ' Tax Amount   : '||rec_info.tax) ;
             FND_FILE.PUT_LINE(FND_FILE.LOG, ' SITE balance : '||rec_info.site) ;
             FND_FILE.PUT_LINE(FND_FILE.LOG, ' PAYE balance : '||rec_info.paye) ;
             FND_FILE.PUT_LINE(FND_FILE.LOG, l_msgtext);
         end if;


         --Validate negative income in the main certificate
         hr_utility.set_location('Validating negative income for main certificate',20);
         for rec_neg_income in csr_neg_income(l_ass_act_id, l_main_cert_num)
         loop
              if l_count <>1 then
                  l_count:=1;
                  FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                  FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Employee Number   : ' || l_empno);
                  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Assignment Number : ' || l_assgno);
              end if;
              fnd_message.set_name('PAY', 'PY_ZA_NEG_BAL_NOT_ALWD');
              fnd_message.set_token('EMPno',l_empno);
              fnd_message.set_token('SARScode',rec_neg_income.code);
              l_msgtext := fnd_message.get('Y');
              FND_FILE.PUT_LINE(FND_FILE.LOG, l_msgtext);
         end loop;

         --Validate negative lump sums in the main certificate
         hr_utility.set_location('Validating negative income for lump sum',20);
         for rec_neg_lmpsm in csr_neg_lmpsm(l_ass_act_id, l_main_cert_num)
         loop
              if l_count <>1 then
                  l_count:=1;
                  FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                  FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Employee Number   : ' || l_empno);
                  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Assignment Number : ' || l_assgno);
              end if;

              -- To Be Advised directive has negative value
              if rec_neg_lmpsm.to_be_adv_val < 0 then
                  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Tax Directive Number ' || rec_neg_lmpsm.to_be_adv);
                  fnd_message.set_name('PAY', 'PY_ZA_NEG_BAL_NOT_ALWD');
                  fnd_message.set_token('EMPno',l_empno);
                  fnd_message.set_token('SARScode',rec_neg_lmpsm.code);
                  l_msgtext := fnd_message.get('Y');
                  FND_FILE.PUT_LINE(FND_FILE.LOG, l_msgtext);
              end if;

             --Directive 1 has negative value
              if rec_neg_lmpsm.value1 < 0 then
                  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Tax Directive Number ' || rec_neg_lmpsm.direct1);
                  fnd_message.set_name('PAY', 'PY_ZA_NEG_BAL_NOT_ALWD');
                  fnd_message.set_token('EMPno',l_empno);
                  fnd_message.set_token('SARScode',rec_neg_lmpsm.code);
                  l_msgtext := fnd_message.get('Y');
                  FND_FILE.PUT_LINE(FND_FILE.LOG, l_msgtext);
              end if;

             --Directive 2 has negative value
              if rec_neg_lmpsm.value2 < 0 then
                  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Tax Directive Number ' || rec_neg_lmpsm.direct2);
                  fnd_message.set_name('PAY', 'PY_ZA_NEG_BAL_NOT_ALWD');
                  fnd_message.set_token('EMPno',l_empno);
                  fnd_message.set_token('SARScode',rec_neg_lmpsm.code);
                  l_msgtext := fnd_message.get('Y');
                  FND_FILE.PUT_LINE(FND_FILE.LOG, l_msgtext);
              end if;

             --Directive 3 has negative value
              if rec_neg_lmpsm.value3 < 0 then
                  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Tax Directive Number ' || rec_neg_lmpsm.direct3);
                  fnd_message.set_name('PAY', 'PY_ZA_NEG_BAL_NOT_ALWD');
                  fnd_message.set_token('EMPno',l_empno);
                  fnd_message.set_token('SARScode',rec_neg_lmpsm.code);
                  l_msgtext := fnd_message.get('Y');
                  FND_FILE.PUT_LINE(FND_FILE.LOG, l_msgtext);
              end if;
         end loop;

         --Validate negative lump sums in the lump sum certificate
         hr_utility.set_location('Validating negative income for lump sum',20);
         for rec_neg_lmpsm in csr_neg_lmpsm2(l_ass_act_id, l_main_cert_num)
         loop
              if l_count <>1 then
                  l_count:=1;
                  FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                  FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Employee Number   : ' || l_empno);
                  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Assignment Number : ' || l_assgno);
              end if;

              -- To Be Advised directive has negative value
              if rec_neg_lmpsm.value < 0 then
                  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Tax Directive Number ' || rec_neg_lmpsm.direct1);
                  fnd_message.set_name('PAY', 'PY_ZA_NEG_BAL_NOT_ALWD');
                  fnd_message.set_token('EMPno',l_empno);
                  fnd_message.set_token('SARScode',rec_neg_lmpsm.code);
                  l_msgtext := fnd_message.get('Y');
                  FND_FILE.PUT_LINE(FND_FILE.LOG, l_msgtext);
              end if;
         end loop;

         for rec_neg_tax in chk_neg_tax(l_ass_act_id)
         loop
              if l_count <>1 then
                  l_count:=1;
                  FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                  FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Employee Number   : ' || l_empno);
                  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Assignment Number : ' || l_assgno);
              end if;
              if rec_neg_tax.temp_cert_num = l_main_cert_num then
                  l_directive1:='Certificate: Main Certificate';
              else
                  l_directive1:='Tax Directive Number '||rec_neg_tax.direct1;
              end if;

              --Site has negative value
              if rec_neg_tax.site < 0 then
                  FND_FILE.PUT_LINE(FND_FILE.LOG, l_directive1);
                  fnd_message.set_name('PAY', 'PY_ZA_NEG_BAL_NOT_ALWD');
                  fnd_message.set_token('EMPno',l_empno);
                  fnd_message.set_token('SARScode','4101');
                  l_msgtext := fnd_message.get('Y');
                  FND_FILE.PUT_LINE(FND_FILE.LOG, l_msgtext);
              end if;

              --Paye has negative value
              if rec_neg_tax.paye < 0 then
                  FND_FILE.PUT_LINE(FND_FILE.LOG, l_directive1);
                  fnd_message.set_name('PAY', 'PY_ZA_NEG_BAL_NOT_ALWD');
                  fnd_message.set_token('EMPno',l_empno);
                  fnd_message.set_token('SARScode','4102');
                  l_msgtext := fnd_message.get('Y');
                  FND_FILE.PUT_LINE(FND_FILE.LOG, l_msgtext);
              end if;

              --Tax on Retirement Fund has negative value
              if rec_neg_tax.tax_ret < 0 then
                  FND_FILE.PUT_LINE(FND_FILE.LOG, l_directive1);
                  fnd_message.set_name('PAY', 'PY_ZA_NEG_BAL_NOT_ALWD');
                  fnd_message.set_token('EMPno',l_empno);
                  fnd_message.set_token('SARScode','4115');
                  l_msgtext := fnd_message.get('Y');
                  FND_FILE.PUT_LINE(FND_FILE.LOG, l_msgtext);
              end if;

              --UIF has negative value
              if rec_neg_tax.uif < 0 then
                  FND_FILE.PUT_LINE(FND_FILE.LOG, l_directive1);
                  fnd_message.set_name('PAY', 'PY_ZA_NEG_BAL_NOT_ALWD');
                  fnd_message.set_token('EMPno',l_empno);
                  fnd_message.set_token('SARScode','4141');
                  l_msgtext := fnd_message.get('Y');
                  FND_FILE.PUT_LINE(FND_FILE.LOG, l_msgtext);
              end if;

              --SDL has negative value
              if rec_neg_tax.sdl < 0 then
                  FND_FILE.PUT_LINE(FND_FILE.LOG, l_directive1);
                  fnd_message.set_name('PAY', 'PY_ZA_NEG_BAL_NOT_ALWD');
                  fnd_message.set_token('EMPno',l_empno);
                  fnd_message.set_token('SARScode','4142');
                  l_msgtext := fnd_message.get('Y');
                  FND_FILE.PUT_LINE(FND_FILE.LOG, l_msgtext);
              end if;

              --total has negative value
              if rec_neg_tax.total < 0 then
                  FND_FILE.PUT_LINE(FND_FILE.LOG, l_directive1);
                  fnd_message.set_name('PAY', 'PY_ZA_NEG_BAL_NOT_ALWD');
                  fnd_message.set_token('EMPno',l_empno);
                  fnd_message.set_token('SARScode','4149');
                  l_msgtext := fnd_message.get('Y');
                  FND_FILE.PUT_LINE(FND_FILE.LOG, l_msgtext);
              end if;

         end loop;

         --Validate negative deductions in the main certificate
         hr_utility.set_location('Validating negative deductions in main certificate',20);
         for rec_neg_deduct in csr_neg_deduct(l_ass_act_id, l_main_cert_num)
         loop
              if l_count <>1 then
                  l_count:=1;
                  FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                  FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Employee Number   : ' || l_empno);
                  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Assignment Number : ' || l_assgno);
              end if;
              fnd_message.set_name('PAY', 'PY_ZA_NEG_BAL_NOT_ALWD');
              fnd_message.set_token('EMPno',l_empno);
              fnd_message.set_token('SARScode',rec_neg_deduct.code);
              l_msgtext := fnd_message.get('Y');
              FND_FILE.PUT_LINE(FND_FILE.LOG, l_msgtext);
         end loop;

         --Employee not on package structure but has PKG balances
         hr_utility.set_location('Check whether Emp on PKG Structure',25);
         for rec_pkg_balances in fetch_pkg_balances(l_ass_act_id, l_main_cert_num)
         loop
              if l_count <>1 then
                  l_count:=1;
                  FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                  FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Employee Number   : ' || l_empno);
                  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Assignment Number : ' || l_assgno);
              end if;

              fnd_message.set_name('PAY', 'PY_ZA_PKG_BAL_NT_ALLOW');
              fnd_message.set_token('EMPno',l_empno);
              l_msgtext := fnd_message.get('Y');
              FND_FILE.PUT_LINE (FND_FILE.LOG,l_msgtext);

              select   max(paa.action_sequence)
                into   l_run_action_seq
                from   pay_assignment_actions     paa,
                       pay_payroll_actions        ppa,
                       per_time_periods           ptp
                where  paa.assignment_id = rec_asgn.assignment_id
                  and  paa.action_status = 'C'
                  and  paa.payroll_action_id = ppa.payroll_action_id
                  and  ppa.action_type IN ('R', 'Q', 'V', 'B', 'I')
                  and  ppa.action_status = 'C'
                  and  ppa.time_period_id = ptp.time_period_id
                  and  ptp.prd_information1 = p_tax_year;

              select   assignment_action_id
                into   l_run_ass_act_id
                from   pay_assignment_actions
                where  assignment_id = rec_asgn.assignment_id
                  and  action_sequence = l_run_action_seq;


              hr_utility.set_location('Employee not on Package structure but has PKG balances',25);
              FOR pkg_ele IN fetch_pkg_ele(l_run_ass_act_id)
              LOOP
                  fnd_message.set_name('PAY', 'PY_ZA_NEW_ELE_FEED_PKG_BAL');
                  fnd_message.set_token('ELEMENTname',pkg_ele.element_name);
                  l_msgtext := fnd_message.get('Y');
                  FND_FILE.PUT_LINE (FND_FILE.LOG,l_msgtext);
              END LOOP;
         end loop;  --end loop for fetch_pkg_balances

         -- Code 4115 must be present only if code 3915, 3920, 3921 are present.
         hr_utility.set_location('Tax on Retirement Fund check',30);
         for rec_tax_ret_fund_ls in chk_tax_ret_fund_ls(l_ass_act_id)
         loop
                 open chk_ret_fund_ls(l_ass_act_id, rec_tax_ret_fund_ls.temp_cert_num);
                 fetch chk_ret_fund_ls into rec_ret_fund_ls;
                 if chk_ret_fund_ls%notfound then
                      if l_count <>1 then
                           l_count:=1;
                           FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                           FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                           FND_FILE.PUT_LINE(FND_FILE.LOG, 'Employee Number   : ' || l_empno);
                           FND_FILE.PUT_LINE(FND_FILE.LOG, 'Assignment Number : ' || l_assgno);
                      end if;
                      --If main certificate has code 4115 but 3915,3920,3921 not present
                      if rec_tax_ret_fund_ls.temp_cert_num =  l_main_cert_num then
                            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Certificate ' || 'Main Certificate');
                      else
                            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Tax Directive Number ' || rec_tax_ret_fund_ls.direct1);
                      end if;
                      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Code 4115 must not be present if Codes 3915, 3920, and 3921 are not present.');
                  end if;
                 close chk_ret_fund_ls;
         end loop;
         hr_utility.set_location('End Tax on Retirement Fund check',35);


         --Delete the cross validation table
         cross_val_t.delete;
         cross_val_t(3810):=0;
         cross_val_t(3860):=0;
         cross_val_t(3813):=0;
         cross_val_t(3863):=0;
         cross_val_t(4005):=0;
         cross_val_t(4024):=0;
         cross_val_t(4474):=0;
         cross_val_t(4493):=0;

        hr_utility.set_location('Before populating cross validation table',40);
         --Populate the cross validation table
         FOR rec_cv_inc_codes IN cross_val_inc_codes(l_ass_act_id , l_main_cert_num)
         LOOP
               cross_val_t(rec_cv_inc_codes.code)
                    := rec_cv_inc_codes.value;
         END LOOP;

         hr_utility.set_location('Intermediate cross validation table',40);

         FOR rec_cv_ded_codes IN cross_val_ded_codes(l_ass_act_id, l_main_cert_num)
         LOOP
               cross_val_t(rec_cv_ded_codes.code)
                    := rec_cv_ded_codes.value;
         END LOOP;

         hr_utility.set_location('After cross validation table',40);

         -- Code 3810 must be less than code 4474
         if ((cross_val_t(3810) >= cross_val_t(4474)) AND
             (cross_val_t(3810) <> 0  OR cross_val_t(4474)<>0)) then
                 if l_count <>1 then
                      l_count:=1;
                      FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                      FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Employee Number   : ' || l_empno);
                      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Assignment Number : ' || l_assgno);
                 end if;
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Code 3810 must be less than Code 4474.');
         end if;

         hr_utility.set_location('check whether 3813 greater than 4024',45);
         --Code 3813/3863 must be greater than or equal to the value of code 4024
         if ((case when cross_val_t(3813)=0 then cross_val_t(3863) else cross_val_t(3813) end) < cross_val_t(4024)) then
                 if l_count <>1 then
                      l_count:=1;
                      FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                      FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Employee Number   : ' || l_empno);
                      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Assignment Number : ' || l_assgno);
                 end if;
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Codes 3813 and 3863 must not be less than Code 4024.');
         end if;

        --Code 3810/3860 and 4474 is not allowed if code 4493 is specified
       hr_utility.set_location('check whether 3810 OR 4474 present if 4493 specified',45);
        if cross_val_t(4493) <> 0 then
             if cross_val_t(3810) <>0 OR cross_val_t(3860) <>0 OR cross_val_t(4474) <>0 then
                 if l_count <>1 then
                      l_count:=1;
                      FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                      FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Employee Number   : ' || l_empno);
                      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Assignment Number : ' || l_assgno);
                 end if;
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Codes 3810, 3860, and 4474 not allowed if Code 4493 is specified.');
             end if;
        end if;

/* --Already handled in message Code 3813/3863 must be greater than or equal to the value of code 4024
       --Code 4024 cannot be greater than the sum of the values for codes 3813 and 3863
        hr_utility.set_location('Check whether 4024 greater than 3813/3863',45);
        if cross_val_t(4024) > cross_val_t(3813) OR cross_val_t(4024) > cross_val_t(3863) then
             if l_count <>1 then
                l_count:=1;
                FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Employee Number   : ' || l_empno);
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Assignment Number : ' || l_assgno);
             end if;
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Code 4024 must be less than Codes 3813 and 3863.');
        end if;
*/

        --Code 4474 is mandatory if an amount is specified for code 3810/3860
        hr_utility.set_location('4474 mandatory for 3810',45);
        if (cross_val_t(3810) <> 0 OR cross_val_t(3860)<>0) AND cross_val_t(4474)=0 then
             if l_count <>1 then
                l_count:=1;
                FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Employee Number   : ' || l_empno);
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Assignment Number : ' || l_assgno);
             end if;
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Code 4474 must be greater than zero if Code 3810 or Code 3860 has a value.');
        end if;

        --Code 4005 is mandatory if an amount is specified for code 3810/3860
        hr_utility.set_location('4005 mandatory for 3810',45);
        if (cross_val_t(3810) <> 0 OR cross_val_t(3860)<>0) AND cross_val_t(4005)=0 then
             if l_count <>1 then
                l_count:=1;
                FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Employee Number   : ' || l_empno);
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Assignment Number : ' || l_assgno);
             end if;
            FND_FILE.PUT_LINE(FND_FILE.LOG, 'Code 4005 must be greater than zero if Code 3810 or Code 3860 has a value.');
        end if;


        -- Check that number of deduction codes must not exceed 7.
        hr_utility.set_location('Count deduction codes',45);
        open csr_num_ded_codes(l_ass_act_id , l_main_cert_num);
        fetch csr_num_ded_codes into l_num_ded_codes;
        close csr_num_ded_codes;

        if l_num_ded_codes > 7 then
             if l_count <>1 then
                l_count:=1;
                FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Employee Number   : ' || l_empno);
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Assignment Number : ' || l_assgno);
             end if;
             fnd_message.set_name('PAY', 'PY_ZA_INVALID_NUM_CODES');
             fnd_message.set_token('EMPNO',l_empno);
             fnd_message.set_token('COUNT','7');
             fnd_message.set_token('TYPE','deductions and/or contribution');
             l_msgtext := fnd_message.get('Y');
             FND_FILE.PUT_LINE (FND_FILE.LOG,l_msgtext);
       end if;

        -- Check that number of income codes must not exceed 13.
        hr_utility.set_location('Count income codes',50);
        open csr_num_inc_codes(l_ass_act_id , l_main_cert_num);
        fetch csr_num_inc_codes into l_num_inc_temp;
        close csr_num_inc_codes;

        open csr_num_3907(l_ass_act_id , l_main_cert_num);
        fetch csr_num_3907 into l_num_inc_codes;
        close csr_num_3907;

        l_num_inc_codes:=nvl(l_num_inc_codes,0) + nvl(l_num_inc_temp,0);

        if l_num_inc_codes > 13 then
             if l_count <>1 then
                l_count:=1;
                FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Employee Number   : ' || l_empno);
                FND_FILE.PUT_LINE(FND_FILE.LOG, 'Assignment Number : ' || l_assgno);
             end if;
             fnd_message.set_name('PAY', 'PY_ZA_INVALID_NUM_CODES');
             fnd_message.set_token('EMPNO',l_empno);
             fnd_message.set_token('COUNT','13');
             fnd_message.set_token('TYPE','income');
             l_msgtext := fnd_message.get('Y');
             FND_FILE.PUT_LINE (FND_FILE.LOG,l_msgtext);
       end if;

       --If the employer is not register for PAYE (Paye Reference number doesnot start with 7)
       --but any employee has code 4101,4102,4115 then it is invalid
       hr_utility.set_location('Check PAYE Ref Num',60);
       open csr_paye_ref_num;
       fetch csr_paye_ref_num into l_paye_ref_num;
       if csr_paye_ref_num%notfound then
             l_paye_ref_num:=7;
       end if;
       close csr_paye_ref_num;

         hr_utility.set_location('Retrieved PAYE Ref Num',60);
       if substr(l_paye_ref_num,1,1) <> 7 then
           open tax_codes(l_ass_act_id);
           fetch tax_codes into l_tax_code_ind;
           close tax_codes;

           if l_tax_code_ind is not null then
               if l_count <>1 then
                   l_count:=1;
                   FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                   FND_FILE.PUT_LINE(FND_FILE.LOG,'  ');
                   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Employee Number   : ' || l_empno);
                   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Assignment Number : ' || l_assgno);
               end if;
               fnd_message.set_name('PAY', 'PY_ZA_INVALID_TAX_PAYENUM_COM');
               fnd_message.set_token('EMPNO',l_empno);
               l_msgtext := fnd_message.get('Y');
               FND_FILE.PUT_LINE (FND_FILE.LOG,l_msgtext);
           end if;
       end if;

    END LOOP; --end of assignment loop



    FND_FILE.PUT_LINE(FND_FILE.LOG,'End of log file');
    FND_FILE.PUT_LINE(FND_FILE.LOG,'               ');
--    hr_utility.trace_off;
    EXCEPTION
        WHEN OTHERS then
            errbuf := substr(SQLERRM,1,255);
            retcode := sqlcode;

end VALIDATE_TYE_DATA_EOY2010;

end PAY_ZA_EOY_VAL;

/
