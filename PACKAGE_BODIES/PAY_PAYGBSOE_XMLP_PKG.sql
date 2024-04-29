--------------------------------------------------------
--  DDL for Package Body PAY_PAYGBSOE_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAYGBSOE_XMLP_PKG" AS
/* $Header: PAYGBSOEB.pls 120.3 2007/12/27 11:27:08 srikrish noship $ */

function c_amount_paidformula(C_PAYMENT_TOTAL in number, C_DEDUCTION_TOTAL in number) return number is
begin

 return (C_PAYMENT_TOTAL - C_DEDUCTION_TOTAL);
end;

function BeforeReport return boolean is
begin
/*srw.user_exit('FND SRWINIT');*/null;


declare
l_test number;
test varchar2(150);
l_session_date date;
SORT_ORDER1 boolean;
SORT_ORDER2 boolean;
SORT_ORDER3 boolean;
SORT_ORDER4 boolean;
SORT_ORDER5 boolean;
SORT_ORDER6 boolean;


cursor csr_session_date is
select end_date
from   per_time_periods
where  time_period_id = p_time_period_id;

begin
  null;
SORT_ORDER1:=P_SORT_ORDER1ValidTrigger;
SORT_ORDER2 :=P_SORT_ORDER2ValidTrigger;
SORT_ORDER3:=P_SORT_ORDER3ValidTrigger;
SORT_ORDER4:=P_SORT_ORDER4ValidTrigger;
SORT_ORDER5:=P_SORT_ORDER5ValidTrigger;
SORT_ORDER6:=P_SORT_ORDER6ValidTrigger;

PAY_GB_PAYROLL_ACTIONS_PKG.get_input_values_id;

open  csr_session_date;
fetch csr_session_date into l_session_date;
close csr_session_date;

insert into fnd_sessions (session_id, effective_date)
       select userenv('sessionid'), trunc(l_session_date)
       from   dual
       where not exists
             (select 1
              from   fnd_sessions fs
              where fs.session_id = userenv('sessionid'));
select session_id
into l_test
from fnd_sessions
where session_id = userenv('sessionid');
exception
when no_data_found then
	      null;
END;

  return (TRUE);
end;

function P_SORT_ORDER3ValidTrigger return boolean is
begin

P_SORT_ORDER3_dup := nvl(P_SORT_ORDER3_dup,'NULL');  return (TRUE);
end;

function P_SORT_ORDER4ValidTrigger return boolean is
begin

P_SORT_ORDER4_dup := NVL(P_SORT_ORDER4_dup,'NULL');  return (TRUE);
end;

function P_SORT_ORDER5ValidTrigger return boolean is
begin

P_SORT_ORDER5_dup := NVL(P_SORT_ORDER5_dup,'NULL');  return (TRUE);
end;

function P_SORT_ORDER6ValidTrigger return boolean is
begin

P_SORT_ORDER6_dup := NVL(P_SORT_ORDER6_dup,'NULL');  return (TRUE);
end;

function c_nameformula(TITLE in varchar2, INITIALS in varchar2, LAST_NAME in varchar2) return varchar2 is
begin

DECLARE
    A VARCHAR2(300);
BEGIN
A := TITLE ||' '|| INITIALS||'  '|| LAST_NAME ;
RETURN(A);
END;
RETURN NULL; end;

Function Segment1 return varchar2 is
Segment_name varchar2(30);
Seg_num varchar2(60);
begin
If p_sort_order1_dup = 'NULL' then
  return(null);
else
  Seg_num := upper(p_sort_order1_dup);
  --seg_name() );
  Seg_name(Seg_num,Segment_name);
  return(Segment_name);
end if;
RETURN NULL; end;

Procedure Seg_name(a in varchar2 , b out NOCOPY varchar2) is
begin
  Select segment_name into b from fnd_id_flex_segments_vl
  where application_id between 801 and 899
  and id_flex_code = 'GRP'
  and application_column_name = a
  and id_flex_num = (Select people_group_structure from per_business_groups
                     Where business_group_id = p_bus_grp_id);



exception
   When Others then
   null;

end;

Function Segment2 return varchar2 is
Segment_name varchar2(30);
Seg_num      varchar2(60);
Begin
If p_sort_order2_dup = 'NULL' then
  return(null);
else
  Seg_num := upper(p_sort_order2_dup);
  --seg_name() );
  Seg_name(Seg_num,Segment_name);
  return(Segment_name);
end if;
RETURN NULL; End;

Function Segment3 return varchar2 is
Segment_name varchar2(30);
Seg_num      varchar2(60);
Begin
If p_sort_order3_dup = 'NULL' then
  return(null);
else
  Seg_num := upper(p_sort_order3_dup);
  --seg_name() );
  Seg_name(Seg_num,Segment_name);
  return(Segment_name);
end if;
RETURN NULL; end;

Function Segment4 return varchar2 is
Segment_name varchar2(30);
Seg_num      varchar2(60);
Begin
If p_sort_order4_dup = 'NULL' then
  return(null);
else
  Seg_num := upper(p_sort_order4_dup);
  --seg_name() );
  Seg_name(Seg_num , Segment_name);
  return(Segment_name);
end if;
RETURN NULL; end;

Function Segment5 return varchar2 is
Segment_name varchar2(30);
Seg_num      varchar2(60);
Begin
If p_sort_order5_dup = 'NULL' then
  return(null);
else
  Seg_num  := upper(p_sort_order5_dup);
  --seg_name() );
  Seg_name(Seg_num , Segment_name);
  return(Segment_name);
end if;
RETURN NULL; end;

Function Segment6 return varchar2 is
Segment_name varchar2(30);
Seg_num      varchar2(60);
begin
If p_sort_order6_dup = 'NULL' then
return(null);
else
Seg_num := upper(p_sort_order6_dup);
--seg_name() );
Seg_name(Seg_num,Segment_name);
return(Segment_name);
end if;
RETURN NULL; end;

function P_SORT_ORDER1ValidTrigger return boolean is
begin

P_SORT_ORDER1_dup := NVL(P_SORT_ORDER1_dup,'NULL');
  return (TRUE);
end;

function P_SORT_ORDER2ValidTrigger return boolean is
begin

P_SORT_ORDER2_dup := NVL(P_SORT_ORDER2_dup,'NULL');  return (TRUE);
end;

function AfterPForm return boolean is
begin

BEGIN
IF P_SORT_ORDER1 = 'SEGMENTX' THEN
      P_SORT_ORDER1_dup := 'NULL';
  else
  p_sort_order1_dup := p_sort_order1;
END IF;
IF P_SORT_ORDER2 = 'SEGMENTX' THEN
     P_SORT_ORDER2_dup := 'NULL';
     else
  p_sort_order2_dup := p_sort_order2;
END IF;
IF P_SORT_ORDER3 = 'SEGMENTX' THEN
     P_SORT_ORDER3_dup := 'NULL';
     else
  p_sort_order3_dup := p_sort_order3;
END IF;
IF P_SORT_ORDER4 = 'SEGMENTX' THEN
     P_SORT_ORDER4_dup := 'NULL';
     else
  p_sort_order4_dup := p_sort_order4;
END IF;
IF P_SORT_ORDER5 = 'SEGMENTX' THEN
     P_SORT_ORDER5_dup := 'NULL';
     else
  p_sort_order5_dup := p_sort_order5;
END IF;
IF P_SORT_ORDER6 = 'SEGMENTX' THEN
     P_SORT_ORDER6_dup := 'NULL';
     else
  p_sort_order6_dup := p_sort_order6;
END IF;

END;  return (TRUE);
end;

function BeforePForm return boolean is
begin

declare
begin



    null;
END;

  return (TRUE);
end;

function cf_euro_amountformula(c_amount_paid in number) return number is
   calc_amount number;
   currency_code varchar2(15);
begin

   begin

   select currency_code
     into currency_code
     from per_business_groups
    where business_group_id=p_bus_grp_id;

   calc_amount := hr_currency_pkg.convert_amount(
					currency_code,
					'EUR',
					c_pay_date,
					nvl(c_amount_paid,0),
					'H');
   exception
   when others then
      calc_amount := 0;
   end;

   return(calc_amount);

end;

function AfterReport return boolean is
begin
  /*srw.user_exit('FND SRWEXIT');*/null;

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function C_ADDRESS1_p return varchar2 is
	Begin
	 return C_ADDRESS1;
	 END;
 Function C_ADDRESS2_p return varchar2 is
	Begin
	 return C_ADDRESS2;
	 END;
 Function C_ADDRESS3_p return varchar2 is
	Begin
	 return C_ADDRESS3;
	 END;
 Function C_REGION1_p return varchar2 is
	Begin
	 return C_REGION1;
	 END;
 Function C_REGION2_p return varchar2 is
	Begin
	 return C_REGION2;
	 END;
 Function C_REGION3_p return varchar2 is
	Begin
	 return C_REGION3;
	 END;
 Function C_ACCOUNT_NO_p return number is
	Begin
	 return C_ACCOUNT_NO;
	 END;
 Function C_TOWN_p return varchar2 is
	Begin
	 return C_TOWN;
	 END;
 Function C_ANNUAL_SALARY_p return number is
	Begin
	 return C_ANNUAL_SALARY;
	 END;
 Function C_PAY_DATE_p return date is
	Begin
	 return C_PAY_DATE;
	 END;
 Function C_TAX_PERIOD_p return varchar2 is
	Begin
	 return C_TAX_PERIOD;
	 END;
 Function C_TAX_REFERENCE_NO_p return varchar2 is
	Begin
	 return C_TAX_REFERENCE_NO;
	 END;
 Function C_TAX_CODE_p return varchar2 is
	Begin
	 return C_TAX_CODE;
	 END;
 Function C_TAX_BASIS_p return varchar2 is
	Begin
	 return C_TAX_BASIS;
	 END;
 Function C_NI_CATEGORY_p return varchar2 is
	Begin
	 return C_NI_CATEGORY;
	 END;
 Function C_TAX_TEL_NO_p return varchar2 is
	Begin
	 return C_TAX_TEL_NO;
	 END;
 Function C_BALANCE_R1_TXT_p return varchar2 is
	Begin
	 return C_BALANCE_R1_TXT;
	 END;
 Function C_BALANCE_R1_VAL_p return number is
	Begin
	 return C_BALANCE_R1_VAL;
	 END;
 Function C_BALANCE_R2_TXT_p return varchar2 is
	Begin
	 return C_BALANCE_R2_TXT;
	 END;
 Function C_BALANCE_R2_VAL_p return number is
	Begin
	 return C_BALANCE_R2_VAL;
	 END;
 Function C_BALANCE_R3_TXT_p return varchar2 is
	Begin
	 return C_BALANCE_R3_TXT;
	 END;
 Function C_BALANCE_R3_VAL_p return number is
	Begin
	 return C_BALANCE_R3_VAL;
	 END;
 Function C_BALANCE_R4_TXT_p return varchar2 is
	Begin
	 return C_BALANCE_R4_TXT;
	 END;
 Function C_BALANCE_R4_VAL_p return number is
	Begin
	 return C_BALANCE_R4_VAL;
	 END;
 Function C_BALANCE_R5_TXT_p return varchar2 is
	Begin
	 return C_BALANCE_R5_TXT;
	 END;
 Function C_BALANCE_R5_VAL_p return number is
	Begin
	 return C_BALANCE_R5_VAL;
	 END;
 Function C_BALANCE_R6_TXT_p return varchar2 is
	Begin
	 return C_BALANCE_R6_TXT;
	 END;
 Function C_BALANCE_R6_VAL_p return number is
	Begin
	 return C_BALANCE_R6_VAL;
	 END;
 Function C_BALANCE_R7_TXT_p return varchar2 is
	Begin
	 return C_BALANCE_R7_TXT;
	 END;
 Function C_BALANCE_R7_VAL_p return number is
	Begin
	 return C_BALANCE_R7_VAL;
	 END;
 Function C_BALANCE_R8_TXT_p return varchar2 is
	Begin
	 return C_BALANCE_R8_TXT;
	 END;
 Function C_BALANCE_R8_VAL_p return number is
	Begin
	 return C_BALANCE_R8_VAL;
	 END;
 Function C_BALANCE_R9_TXT_p return varchar2 is
	Begin
	 return C_BALANCE_R9_TXT;
	 END;
 Function C_BALANCE_R9_VAL_p return number is
	Begin
	 return C_BALANCE_R9_VAL;
	 END;
 Function C_BALANCE_R10_TXT_p return varchar2 is
	Begin
	 return C_BALANCE_R10_TXT;
	 END;
 Function C_BALANCE_R10_VAL_p return number is
	Begin
	 return C_BALANCE_R10_VAL;
	 END;
 Function C_BALANCE_R11_TXT_p return varchar2 is
	Begin
	 return C_BALANCE_R11_TXT;
	 END;
 Function C_BALANCE_R11_VAL_p return number is
	Begin
	 return C_BALANCE_R11_VAL;
	 END;
 Function C_BALANCE_R12_TXT_p return varchar2 is
	Begin
	 return C_BALANCE_R12_TXT;
	 END;
 Function C_BALANCE_R12_VAL_p return number is
	Begin
	 return C_BALANCE_R12_VAL;
	 END;
 Function C_OUTPUT2_p return number is
	Begin
	 return C_OUTPUT2;
	 END;
 Function C_OUTPUT_p return number is
	Begin
	 return C_OUTPUT;
	 END;
 Function C_2_p return number is
	Begin
	 return C_2;
	 END;
 Function C_FORMULA_ID_p return number is
	Begin
	 return C_FORMULA_ID;
	 END;
 Function C_DATE_EARNED_p return varchar2 is
	Begin
	 return C_DATE_EARNED;
	 END;
 Function C_FORMULA_ID2_p return number is
	Begin
	 return C_FORMULA_ID2;
	 END;
 Function C_OUTPUT3_p return varchar2 is
	Begin
	 return C_OUTPUT3;
	 END;

	 /* ADDED BY P.SREEVALLI*/
function populate_fields(expense_check_send_to_address IN  VARCHAR2,
person_id IN NUMBER,segment1c IN VARCHAR2,segment2c IN VARCHAR2,segment3c IN VARCHAR2,segment4c IN VARCHAR2,segment5c IN VARCHAR2,segment6c IN VARCHAR2) return number is
l_address1 varchar2(240);
l_address2 varchar2(240);
l_address3 varchar2(240);
l_region1  varchar2(120);
l_region2  varchar2(120);
l_region3  varchar2(120);
l_town     varchar2(60);
l_cont     varchar2(60);
l_code     varchar2(60);

begin

IF expense_check_send_to_address = 'H' THEN
  pay_gb_payroll_actions_pkg.get_home_add
            (p_person_id => person_id,
             p_add1 => l_address1,
             p_add2 => l_address2,
             p_add3 => l_address3,
             p_reg1 => l_region1,
             p_reg2 => l_region2,
             p_reg3 => l_region3,
             p_twnc => l_town);

         c_address1 := substr(l_address1,1,27);
         c_address2 := substr(l_address2,1,27);
         c_address3 := substr(l_address3,1,27);
         c_region1  := substr(l_region1,1,27);
         c_region2  := substr(l_region2,1,27);
         c_region3  := substr(l_region3,1,27);
         c_town     := substr(l_town,1,27);



elsif (expense_check_send_to_address <> 'H' or expense_check_send_to_address is null) then

c_address1 := segment1c ;
c_address2 := segment2c ;
c_address3 := segment3c ;
c_town     := segment4c ;
c_region1  := segment5c ;
c_region2  := segment6c ;

END if;

return (c_output2);
end populate_fields;


function get_ff_data(run_effective_date IN DATE ,date_earned IN DATE,assignment_id IN NUMBER
,run_assignment_action_id IN NUMBER,payroll_action_id IN NUMBER,p_bus_grp_id IN NUMBER)
return number  is

l_tax_period         varchar2(30);
l_tax_reference_no   varchar2(30);
l_tax_tel_no         varchar2(20);
L_tax_code           varchar2(15);
l_tax_basis          varchar2(30);
l_ni_category        varchar2(30);

l_balance_r1_txt  varchar2(20);
l_balance_r2_txt  varchar2(20);
l_balance_r3_txt  varchar2(20);
l_balance_r4_txt  varchar2(20);
l_balance_r5_txt  varchar2(20);
l_balance_r6_txt  varchar2(20);
L_balance_r7_txt  varchar2(20);
l_balance_r8_txt  varchar2(20);
l_balance_r9_txt  varchar2(20);
l_balance_r10_txt varchar2(20);
l_balance_r11_txt varchar2(20);
l_balance_r12_txt varchar2(20);
l_balance_r1_val  number;
l_balance_r2_val  number;
l_balance_r3_val  number;
l_balance_r4_val  number;
l_balance_r5_val  number;
l_balance_r6_val  number;
l_balance_r7_val  number;
l_balance_r8_val  number;
l_balance_r9_val  number;
l_balance_r10_val number;
l_balance_r11_val number;
l_balance_r12_val number;

begin

    c_pay_date := run_effective_date;
    c_date_earned:= to_char(date_earned,'YYYY/MM/DD');


   PAY_GB_PAYROLL_ACTIONS_PKG.get_report_db_items
			(p_assignment_id     => assignment_id,
                         p_run_assignment_action_id => run_assignment_action_id,
			 p_date_earned	     => to_char(run_effective_date,'YYYY/MM/DD'),
			 p_payroll_action_id => payroll_action_id,
			 p_tax_period	     => l_tax_period,
			 p_tax_refno	     => l_tax_reference_no,
			 p_tax_phone	     => l_tax_tel_no,
			 p_tax_code	     => l_tax_code,
			 p_tax_basis	     => l_tax_basis,
			 p_ni_category	     => l_ni_category);

c_tax_period       := l_tax_period;
c_tax_reference_no := l_tax_reference_no;
c_tax_tel_no       := SUBSTR(l_tax_tel_no,1,11);
c_tax_code         := l_tax_code;
c_tax_basis        := l_tax_basis;
c_ni_category      := l_ni_category;


 PAY_GB_PAYROLL_ACTIONS_PKG.get_report_balances
                      (p_assignment_action_id => run_assignment_action_id,
		   p_business_group_id    => p_bus_grp_id,
		       p_label_1	      => L_BALANCE_R1_TXT,
                       p_value_1              => L_BALANCE_R1_VAL,
		       p_label_2	      => L_BALANCE_R2_TXT,
                       p_value_2              => L_BALANCE_R2_VAL,
		       p_label_3	      => L_BALANCE_R3_TXT,
                       p_value_3              => L_BALANCE_R3_VAL,
		       p_label_4	      => L_BALANCE_R4_TXT,
                       p_value_4              => L_BALANCE_R4_VAL,
		       p_label_5	      => L_BALANCE_R5_TXT,
                       p_value_5              => L_BALANCE_R5_VAL,
		       p_label_6	      => L_BALANCE_R6_TXT,
                       p_value_6              => L_BALANCE_R6_VAL,
		       p_label_7	      => L_BALANCE_R7_TXT,
                       p_value_7              => L_BALANCE_R7_VAL,
		       p_label_8	      => L_BALANCE_R8_TXT,
                       p_value_8              => L_BALANCE_R8_VAL,
		       p_label_9	      => L_BALANCE_R9_TXT,
                       p_value_9              => L_BALANCE_R9_VAL,
		       p_label_a	      => L_BALANCE_R10_TXT,
                       p_value_a              => L_BALANCE_R10_VAL,
		       p_label_b	      => L_BALANCE_R11_TXT,
                       p_value_b              => L_BALANCE_R11_VAL,
		       p_label_c	      => L_BALANCE_R12_TXT,
                       p_value_c              => L_BALANCE_R12_VAL);



c_balance_r1_txt  := l_balance_r1_txt;
c_balance_r1_val  := l_balance_r1_val;
c_balance_r2_txt  := l_balance_r2_txt;
c_balance_r2_val  := l_balance_r2_val;
c_balance_r3_txt  := l_balance_r3_txt;
c_balance_r3_val  := l_balance_r3_val;
c_balance_r4_txt  := l_balance_r4_txt;
c_balance_r4_val  := l_balance_r4_val;
c_balance_r5_txt  := l_balance_r5_txt;
c_balance_r5_val  := l_balance_r5_val;
c_balance_r6_txt  := l_balance_r6_txt;
c_balance_r6_val  := l_balance_r6_val;
c_balance_r7_txt  := l_balance_r7_txt;
c_balance_r7_val  := l_balance_r7_val;
c_balance_r8_txt  := l_balance_r8_txt;
c_balance_r8_val  := l_balance_r8_val;
c_balance_r9_txt  := l_balance_r9_txt;
c_balance_r9_val  := l_balance_r9_val;
c_balance_r10_txt := l_balance_r10_txt;
c_balance_r10_val := l_balance_r10_val;
c_balance_r11_txt := l_balance_r11_txt;
c_balance_r11_val := l_balance_r11_val;
c_balance_r12_txt := l_balance_r12_txt;
c_balance_r12_val := l_balance_r12_val;







return (c_output);
end;


























END PAY_PAYGBSOE_XMLP_PKG ;

/
