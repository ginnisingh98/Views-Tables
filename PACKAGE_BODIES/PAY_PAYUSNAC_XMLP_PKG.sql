--------------------------------------------------------
--  DDL for Package Body PAY_PAYUSNAC_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAYUSNAC_XMLP_PKG" AS
/* $Header: PAYUSNACB.pls 120.0 2007/12/28 06:46:42 srikrish noship $ */

function BeforeReport return boolean is

l_p_value     varchar2(10);
cid number;

begin

     begin

      select parameter_value into l_p_value
      from pay_action_parameters
      where parameter_name = 'TRACE';

     exception when others then

         l_p_value := 'N';

     end;

     if l_p_value = 'Y' then

        /*srw.do_sql('alter session set SQL_TRACE TRUE');*/null;


     end if;
select consolidation_set_id into cid
  from pay_payroll_actions
  where payroll_action_id = p_payroll_action_id;
  c_consolidation_set_id := cid;

begin

--hr_standard.event('BEFORE REPORT');
  null;   c_business_group_name :=
hr_reports.get_business_group(p_business_group_id);
  /*srw.message('1','Business Group ID
 '||c_business_group_name);*/null;

  /*srw.message('2','Consolidation Set Id '||to_char(c_consolidation_set_id));*/null;

  /*srw.message('3','Payroll Action ID '||to_char(p_payroll_action_id));*/null;

end;  return (TRUE);
end;

function get_address(loc_id in number) return varchar2 is
f_address varchar2(300) := null;

 address_line_1 hr_locations_all.address_line_1%TYPE;
 address_line_2 hr_locations_all.address_line_2%TYPE;
 address_line_3 hr_locations_all.address_line_3%TYPE;
 location_code hr_locations_all.location_code%type;
 town_or_city hr_locations_all.town_or_city%TYPE;
 postal_code hr_locations_all.postal_code%TYPE;
 region_2 hr_locations_all.region_2%type;

cursor get_loc_rec is
  select address_line_1,
         address_line_2,
         address_line_3,
         town_or_city,
          region_2,
         postal_code,
         location_code
 from hr_locations_all
  where  location_id = loc_id;
begin
  open get_loc_rec;
  fetch get_loc_rec into address_line_1,
         address_line_2,
         address_line_3,
         town_or_city,
         region_2,
         postal_code,
         location_code;
  if get_loc_rec%found
  then
    if address_line_1 is not null
    then
      f_address := rpad(address_line_1,45,' ');
    end if;
    if address_line_2 is not null
    then
      f_address := f_address ||
                   rpad(address_line_2,45,' ');
    end if;
    if address_line_3 is not null
    then
      f_address := f_address ||
                   rpad(address_line_3,45,' ');
    end if;
    f_address := f_address ||location_code ||'  ';
    if region_2 is not null
    then
      f_address := f_address ||region_2 ||'  ' ||
                   postal_code;
    end if;
    close get_loc_rec;
    return f_address;
  end if;
end;

function calc_pnot(amount in number) return number is
  f_prenot number;
begin
  if amount = 0
  then
    f_prenot := 1;
   else
    f_prenot := 0;
  end if;
  return f_prenot;
end;

function get_cid return number is
cid number;
begin
  select consolidation_set_id into cid
  from pay_payroll_actions
  where payroll_action_id = p_payroll_action_id;
  c_consolidation_set_id := cid;
  return cid;
end;

function get_pay_act_name
return varchar2 is
ret varchar2(150);
begin
   select distinct to_char(a.payroll_action_id) ||
          '-'||
          to_char(effective_date,'DD-MON-YYYY')||
          '-'||
          b.CONSOLIDATION_SET_NAME ||
          decode(c.PAYROLL_NAME,null,null,'-') ||
          c.PAYROLL_NAME
   into   ret
   from   pay_payroll_actions    a,
          pay_consolidation_sets b,
          pay_payrolls_f         c
   where  a.CONSOLIDATION_SET_ID = b.CONSOLIDATION_SET_ID
   and    a.PAYROLL_ID           = c.PAYROLL_ID (+)
   and    a.ACTION_TYPE          = 'M'
   and    a.ACTION_STATUS        = 'C'
   and    a.payroll_action_id    = p_payroll_action_id;
   c_payroll_action_name := ret;
   return ret;
end;

function cf_bal_nachaformula(c_tot_amt in number) return number is
v_flag     PAY_ORG_PAYMENT_METHODS_F.pmeth_information6%TYPE;
v_return   NUMBER(12,2) := 0.00;
begin
   begin
      SELECT nvl(p1.pmeth_information6,'Y')
        INTO v_flag
        FROM pay_org_payment_methods_f p1,
             pay_payroll_actions p2
       WHERE p1.business_group_id = P_BUSINESS_GROUP_ID
         AND p2.payroll_action_id = P_PAYROLL_ACTION_ID
         AND p1.business_group_id = p2.business_group_id
         AND p1.org_payment_method_id = p2.org_payment_method_id
         AND p1.payment_type_id = p2.payment_type_id;
   exception
       WHEN others THEN
            v_flag := 'Y';
   end;
   IF v_flag = 'Y' THEN
      v_return := c_tot_amt;
   ELSE
      v_return := 0.00;
   END IF;
   RETURN v_return;
end;

function AfterReport return boolean is
begin
--hr_standard.event('AFTER REPORT');
  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function C_BUSINESS_GROUP_NAME_p return varchar2 is
	Begin
	 return C_BUSINESS_GROUP_NAME;
	 END;
 Function C_PAYROLL_ACTION_NAME_p return varchar2 is
	Begin
	 return C_PAYROLL_ACTION_NAME;
	 END;
 Function C_CONSOLIDATION_SET_ID_p return number is
	Begin
	 return C_CONSOLIDATION_SET_ID;
	 END;
END PAY_PAYUSNAC_XMLP_PKG ;

/
