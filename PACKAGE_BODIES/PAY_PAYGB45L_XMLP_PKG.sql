--------------------------------------------------------
--  DDL for Package Body PAY_PAYGB45L_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAYGB45L_XMLP_PKG" AS
/* $Header: PAYGB45LB.pls 120.1 2007/12/24 12:42:09 amakrish noship $ */

function BeforeReport return boolean is
begin

declare
l_test number;
l_ers_address varchar2(60);
begin
 /*srw.user_exit('FND SRWINIT');*/null;
    insert into fnd_sessions (session_id,effective_date)
 select userenv('sessionid'),trunc(sysdate)
 from dual
 where not exists
     (select 1
      from fnd_sessions fs
      where fs.session_id = userenv('sessionid'));

    p_session_date:=sysdate;
    p_date_today:=sysdate;


  if P_ASSIGNMENT_ACTION_ID is null then
   P_ACTION_RESTRICTION := 'AND act.payroll_action_id = '||P_PAYROLL_ACTION_ID;
 else
   P_ACTION_RESTRICTION := 'AND act.assignment_action_id = '||P_ASSIGNMENT_ACTION_ID;
 end if;
   select substr(pay_gb_eoy_archive.get_parameter
                (p.legislative_parameters,'TAX_REF'),1,3),
        substr(ltrim(substr(pay_gb_eoy_archive.get_parameter
                (p.legislative_parameters,'TAX_REF'),4,11),'/') ,1,10),
        substr(pay_gb_eoy_archive.get_arch_str
                (p.payroll_action_id,
                 'X_EMPLOYERS_ADDRESS_LINE','0'),1,60),
        substr(pay_gb_eoy_archive.get_arch_str
                (p.payroll_action_id,
                 'X_EMPLOYERS_NAME','0'),1,40)
 into   C_TAX_DIST_NO, C_TAX_DIST_REF, l_ers_address, C_ERS_NAME
 from   pay_payroll_actions p
 where  p.payroll_action_id = P_PAYROLL_ACTION_ID;
  split_employer_address(l_ers_address,
                       c_ers_addr_line1,
                       c_ers_addr_line2,
                       c_ers_addr_line3 );
end;  return (TRUE);
end;

function c_format_dataformula(address_line1 in varchar2, address_line2 in varchar2, address_line3 in varchar2,
town_or_city in varchar2, county in varchar2, post_code in varchar2, taxable_pay in number,
previous_taxable_pay in number, tax_paid in number, previous_tax_paid in number, ni_number in varchar2,
termination_date in date, c_3_part in varchar2, w1_m1_indicator in varchar2, month_number in number,
week_number in number) return varchar2 is
--pragma autonomous_transaction;
begin
c_per_address_line1 := address_line1;
c_per_address_line2 := substr(rtrim(address_line2)||
                         rtrim(', '||address_line3,', '),1,60);

c_per_address_line3 := rpad(rtrim(town_or_city)||' '||
               rtrim(county),37-NVL(length(post_code), 0))||
               ' '||post_code;

    c_total_pay_td := nvl(taxable_pay,0) + nvl(previous_taxable_pay,0);
  c_total_tax_td := nvl(tax_paid,0) + nvl(previous_tax_paid,0);
    c_ni12 := substr(ni_number,1,2);
  c_ni34 := substr(ni_number,3,2);
  c_ni56 := substr(ni_number,5,2);
  c_ni78 := substr(ni_number,7,2);
  c_ni9 := substr(ni_number,9,1);

  c_date_of_leaving_dd := to_char(termination_date,'DD');
  c_date_of_leaving_mm := to_char(termination_date,'MM');
  c_date_of_leaving_yyyy := to_char(termination_date,'YYYY');

  if substr(c_date_of_leaving_dd,1,1) = '0' then
   c_date_of_leaving_dd := ' ' || substr(c_date_of_leaving_dd,2,2);
  end if;

  if substr(c_date_of_leaving_mm,1,1) = '0' then
   c_date_of_leaving_mm := ' ' || substr(c_date_of_leaving_mm,2,2);
  end if;
  If c_3_part = 'TRUE' then

    if w1_m1_indicator is null then
      get_pounds_pence(c_total_pay_td,c_pay_td_pounds,c_pay_td_pence);
      get_pounds_pence(c_total_tax_td,c_tax_td_pounds,c_tax_td_pence);
      c_pay_in_emp_pounds := '';
      c_pay_in_emp_pence  := '';
      c_tax_in_emp_pounds := '';
      c_tax_in_emp_pence  := '';
      c_month_no := month_number;
      c_week_no := week_number;
    else
      get_pounds_pence(taxable_pay,c_pay_in_emp_pounds,c_pay_in_emp_pence);
      get_pounds_pence(tax_paid,c_tax_in_emp_pounds,c_tax_in_emp_pence);
      c_pay_td_pounds := '';
      c_pay_td_pence  := '';
      c_tax_td_pounds := '';
      c_tax_td_pence  := '';
      c_month_no := '';
      c_week_no := '';
    end if;
  Elsif c_3_part = 'FALSE' then

    if w1_m1_indicator is null then
      get_pounds_pence(c_total_pay_td,c_pay_td_pounds,c_pay_td_pence);
      get_pounds_pence(c_total_tax_td,c_tax_td_pounds,c_tax_td_pence);
      if nvl(previous_taxable_pay,0) = 0 and
         nvl(previous_tax_paid,0) = 0 then
        c_pay_in_emp_pounds := '';
        c_pay_in_emp_pence  := '';
        c_tax_in_emp_pounds := '';
        c_tax_in_emp_pence  := '';
      else
        get_pounds_pence(taxable_pay,c_pay_in_emp_pounds,c_pay_in_emp_pence);
        get_pounds_pence(tax_paid,c_tax_in_emp_pounds,c_tax_in_emp_pence);
      end if;
      c_month_no := month_number;
      c_week_no := week_number;
    else
      get_pounds_pence(taxable_pay,c_pay_in_emp_pounds,c_pay_in_emp_pence);
      get_pounds_pence(tax_paid,c_tax_in_emp_pounds,c_tax_in_emp_pence);
      c_pay_td_pounds := '';
      c_pay_td_pence  := '';
      c_tax_td_pounds := '';
      c_tax_td_pence  := '';
      c_month_no := '';
      c_week_no := '';
    end if;

  End if;
  /* insert into log_msg values('sampath','paygb45l','C_TAX_TD_POUNDS',C_TAX_TD_POUNDS);
   commit;*/
return NULL;


end;

procedure get_pounds_pence(p_total in number,
                           p_pounds in out NOCOPY number,
                           p_pence  in out NOCOPY number)  is
begin
if p_total <> 0 then
       p_pounds := trunc(p_total);
       p_pence  := abs(100 * (p_total - p_pounds));
else
       p_pounds := null;
       p_pence  := null;
end if;
end;

procedure split_employer_address(p_employer_address in     varchar2,
                                 p_emp_addr_line_1  in out NOCOPY varchar2,
                                 p_emp_addr_line_2  in out NOCOPY varchar2,
                                 p_emp_addr_line_3  in out NOCOPY varchar2) is

line_length constant number       := 38;
out_line1            varchar2(38) := NULL;
out_line2            varchar2(38) := NULL;
current_char         varchar2(1);
ind                  number;
remaining_chars      number;
wrap_point           number       :=38;
p_remaining_address  varchar2(60);

begin



 if NVL(length(rtrim(p_employer_address)), 0) > 38 then

      for ind in reverse 1..line_length LOOP

         current_char := substr(p_employer_address,ind,1);

         if ind = line_length and current_char = ',' then
             wrap_point := line_length;
             exit;
         elsif ind = line_length and current_char <> ',' then
               null;
         elsif ind < line_length and current_char <> ',' then
               null;
         elsif ind < line_length and current_char = ',' then
               wrap_point := ind;
               exit;
         end if;

      end loop;


      if wrap_point < 21 then



	 remaining_chars       := 60 - wrap_point;

         p_emp_addr_line_1 := substr(p_employer_address,1,wrap_point);


         p_remaining_address := substr(p_employer_address,wrap_point + 1, remaining_chars);

         wrap_point := 38;

         for ind in reverse 1..line_length LOOP

           current_char := substr(p_remaining_address,ind,1);

           if ind = line_length and current_char = ',' then
              wrap_point := line_length;
              exit;
           elsif ind = line_length and current_char <> ',' then
               null;
           elsif ind < line_length and current_char <> ',' then
               null;
           elsif ind < line_length and current_char = ',' then
               wrap_point := ind;
               exit;
           end if;

         end loop;

	 remaining_chars       := 60 - wrap_point;

	          p_emp_addr_line_2 := ltrim(substr(p_remaining_address,1,wrap_point));
         p_emp_addr_line_3 := ltrim(substr(p_remaining_address,wrap_point+1,remaining_chars));


     else


	 remaining_chars       := 60 - wrap_point;


	  	  p_emp_addr_line_1 := substr(p_employer_address,1,wrap_point);
          p_emp_addr_line_2 := ltrim(substr(p_employer_address,wrap_point+1,remaining_chars));

     end if;



 else

     p_emp_addr_line_1 := p_employer_address;
     p_emp_addr_line_2 := NULL;

 end if;

end;

function C_3_PARTFormula return VARCHAR2 is
begin

Declare
l_3_part number(1);
Begin


Select 1 into l_3_part
from   ff_globals_f
where  GLOBAL_NAME = 'P45_REPORT_TYPE'
and    substr(GLOBAL_VALUE,1,1) = '3'
and    sysdate between effective_start_date and effective_end_date;
return('TRUE');

Exception
When no_data_found then
return('FALSE');

End;
RETURN NULL; end;

function AfterReport return boolean is
begin
  /*srw.user_exit('FND SRWEXIT');*/null;

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function C_NI12_p return varchar2 is
	Begin
	 return C_NI12;
	 END;
 Function C_NI34_p return varchar2 is
	Begin
	 return C_NI34;
	 END;
 Function C_NI56_p return varchar2 is
	Begin
	 return C_NI56;
	 END;
 Function C_NI78_p return varchar2 is
	Begin
	 return C_NI78;
	 END;
 Function C_Ni9_p return varchar2 is
	Begin
	 return C_Ni9;
	 END;
 Function C_DATE_OF_LEAVING_DD_p return varchar2 is
	Begin
	 return C_DATE_OF_LEAVING_DD;
	 END;
 Function C_DATE_OF_LEAVING_MM_p return varchar2 is
	Begin
	 return C_DATE_OF_LEAVING_MM;
	 END;
 Function C_DATE_OF_LEAVING_YYYY_p return varchar2 is
	Begin
	 return C_DATE_OF_LEAVING_YYYY;
	 END;
 Function C_WEEK_NO_p return number is
	Begin
	 return C_WEEK_NO;
	 END;
 Function C_MONTH_NO_p return number is
	Begin
	 return C_MONTH_NO;
	 END;
 Function C_TOTAL_TAX_TD_p return number is
	Begin
	 return C_TOTAL_TAX_TD;
	 END;
 Function C_TOTAL_PAY_TD_p return number is
	Begin
	 return C_TOTAL_PAY_TD;
	 END;
 Function C_PER_ADDRESS_LINE1_p return varchar2 is
	Begin
	 return C_PER_ADDRESS_LINE1;
	 END;
 Function C_PER_ADDRESS_LINE2_p return varchar2 is
	Begin
	 return C_PER_ADDRESS_LINE2;
	 END;
 Function C_PER_ADDRESS_LINE3_p return varchar2 is
	Begin
	 return C_PER_ADDRESS_LINE3;
	 END;
 Function C_PER_ADDRESS_LINE4_p return varchar2 is
	Begin
	 return C_PER_ADDRESS_LINE4;
	 END;
 Function C_PAY_IN_EMP_POUNDS_p return number is
	Begin
	 return C_PAY_IN_EMP_POUNDS;
	 END;
 Function C_PAY_IN_EMP_PENCE_p return number is
	Begin
	 return C_PAY_IN_EMP_PENCE;
	 END;
 Function C_TAX_IN_EMP_POUNDS_p return number is
	Begin
	 return C_TAX_IN_EMP_POUNDS;
	 END;
 Function C_TAX_IN_EMP_PENCE_p return number is
	Begin
	 return C_TAX_IN_EMP_PENCE;
	 END;
 Function C_PAY_TD_POUNDS_p return number is
	Begin
	 return C_PAY_TD_POUNDS;
	 END;
 Function C_PAY_TD_PENCE_p return number is
	Begin
	 return C_PAY_TD_PENCE;
	 END;
 Function C_TAX_TD_POUNDS_p return number is
	Begin
	 return C_TAX_TD_POUNDS;
	 END;
 Function C_TAX_TD_PENCE_p return number is
	Begin
	 return C_TAX_TD_PENCE;
	 END;
 Function C_BUSINESS_GROUP_NAME_p return varchar2 is
	Begin
	 return C_BUSINESS_GROUP_NAME;
	 END;
 Function C_REPORT_SUBTITLE_p return varchar2 is
	Begin
	 return C_REPORT_SUBTITLE;
	 END;
 Function C_FORMULA_ID_p return number is
	Begin
	 return C_FORMULA_ID;
	 END;
 Function C_MESSAGE_p return varchar2 is
	Begin
	 return C_MESSAGE;
	 END;
 Function C_NEW_PAGE_p return varchar2 is
	Begin
	 return C_NEW_PAGE;
	 END;
 Function C_ERS_ADDR_LINE1_p return varchar2 is
	Begin
	 return C_ERS_ADDR_LINE1;
	 END;
 Function C_ERS_ADDR_LINE2_p return varchar2 is
	Begin
	 return C_ERS_ADDR_LINE2;
	 END;
 Function C_ERS_ADDR_LINE3_p return varchar2 is
	Begin
	 return C_ERS_ADDR_LINE3;
	 END;
 Function C_TAX_DIST_NO_p return varchar2 is
	Begin
	 return C_TAX_DIST_NO;
	 END;
 Function C_TAX_DIST_REF_p return varchar2 is
	Begin
	 return C_TAX_DIST_REF;
	 END;
 Function C_ERS_NAME_p return varchar2 is
	Begin
	 return C_ERS_NAME;
	 END;
END PAY_PAYGB45L_XMLP_PKG ;

/
