--------------------------------------------------------
--  DDL for Package Body PAY_PYSG8SAD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PYSG8SAD_XMLP_PKG" AS
/* $Header: PYSG8SADB.pls 120.0 2007/12/13 12:23:46 amakrish noship $ */

function AfterReport return boolean is
   t number;

begin

  t := DELETE_ARCHIVE_DATA(p_payroll_action_id);
  /*srw.user_exit('FND SRWEXIT');*/null;

  return (TRUE);

end;

function CF_business_groupFormula return VARCHAR2 is
  v_business_group  hr_all_organization_units.name%type;

begin
 v_business_group := hr_reports.get_business_group(p_business_group_id);
 return v_business_group;
 end;

function BeforeReport return boolean is
begin


    return (TRUE);
end;

function CF_legislation_codeFormula return VARCHAR2 is
   v_cpf_cap varchar2(10);
   v_sys_date varchar2(11);
   v_legislation_code    hr_organization_information.org_information9%type := null;

   cursor cpf_cap_method
      (c_legal_entity_id hr_organization_information.organization_id%type) is
   select org_information7
   from   hr_organization_information
   where  org_information_context = 'SG_LEGAL_ENTITY'
   and    organization_id = c_legal_entity_id;

  cursor legislation_code
    (c_business_group_id hr_organization_information.organization_id%type) is
  select org_information9
  from   hr_organization_information
  where  organization_id  = c_business_group_id
  and    org_information9 is not null;


begin

  open legislation_code (p_business_group_id);
  fetch legislation_code into v_legislation_code;
  close legislation_code;

  open cpf_cap_method(p_legal_entity);
  fetch cpf_cap_method into v_cpf_cap;
  close cpf_cap_method;

  If v_cpf_cap = 'NOSA' then
     CP_CPF_CAP_NO  := 'X';
  Else
     CP_CPF_CAP_YES := 'X';
  End If;
  v_sys_date    := to_char(sysdate,'DD-MON-YYYY');
  CP_SYS_DATE  := v_sys_date;
  CP_BASIS_END := to_char(P_BASIS_END,'DD-MON-YYYY');

  return v_legislation_code;
End;

function cf_currency_format_maskformula(cf_legislation_code in varchar2) return varchar2 is

  v_currency_code    fnd_currencies.currency_code%type;
  v_format_mask      varchar2(100) := null;
  v_field_length     number(3)    := 15;

  cursor currency_format_mask
    (c_territory_code in fnd_currencies.issuing_territory_code%type) is
  select currency_code
  from   fnd_currencies
  where  issuing_territory_code = c_territory_code;

begin
  open currency_format_mask (cf_legislation_code);
  fetch currency_format_mask into v_currency_code;
  close currency_format_mask;

  v_format_mask := fnd_currency.get_format_mask(v_currency_code, v_field_length);

  return v_format_mask;
end;

function cf_monthly_detailsformula(assignment_action_id in number, date_earned in varchar2) return number is
begin

   IF assignment_action_id IS NOT NULL THEN
    BEGIN

       PAY_BALANCE_PKG.SET_CONTEXT
		       ( P_CONTEXT_NAME  => 'ASSIGNMENT_ACTION_ID'
            ,P_CONTEXT_VALUE => assignment_action_id );
       PAY_BALANCE_PKG.SET_CONTEXT
		       ( P_CONTEXT_NAME  => 'TAX_UNIT_ID'
            ,P_CONTEXT_VALUE => P_LEGAL_ENTITY );
       PAY_BALANCE_PKG.SET_CONTEXT
		       ( P_CONTEXT_NAME  => 'DATE_EARNED'
            ,P_CONTEXT_VALUE => date_earned );

      CP_OW := to_number(PAY_BALANCE_PKG.RUN_DB_ITEM
                                ( P_DATABASE_NAME    => 'X_ORDINARY_EARNINGS_PER_LE_MONTH'
                                 ,P_BUS_GROUP_ID     => P_BUSINESS_GROUP_ID
                                 ,P_LEGISLATION_CODE => 'SG' ));

      CP_OW_CPF_ER := to_number(PAY_BALANCE_PKG.RUN_DB_ITEM
     		                ( P_DATABASE_NAME    => 'X_EMPLOYER_CPF_CONTRIBUTIONS_ORDINARY_EARNINGS_PER_LE_MONTH'
                                 ,P_BUS_GROUP_ID     => P_BUSINESS_GROUP_ID
                                 ,P_LEGISLATION_CODE => 'SG' ));
      CP_OW_CPF_EE := to_number(PAY_BALANCE_PKG.RUN_DB_ITEM
     		                        ( P_DATABASE_NAME    => 'X_EMPLOYEE_CPF_CONTRIBUTIONS_ORDINARY_EARNINGS_PER_LE_MONTH'
                                         ,P_BUS_GROUP_ID     => P_BUSINESS_GROUP_ID
                                         ,P_LEGISLATION_CODE => 'SG' ));
      CP_OW_APR_FUND := to_number(PAY_BALANCE_PKG.RUN_DB_ITEM
     		                        ( P_DATABASE_NAME    => 'X_IR8S_MOA_403_PER_LE_MONTH'
                                         ,P_BUS_GROUP_ID     => P_BUSINESS_GROUP_ID
                                         ,P_LEGISLATION_CODE => 'SG' ));
      CP_AW := to_number(PAY_BALANCE_PKG.RUN_DB_ITEM
     		                        ( P_DATABASE_NAME    => 'X_ADDITIONAL_EARNINGS_PER_LE_MONTH'
                                         ,P_BUS_GROUP_ID     => P_BUSINESS_GROUP_ID
                                         ,P_LEGISLATION_CODE => 'SG' ));

      CP_AW_CPF_ER := to_number(PAY_BALANCE_PKG.RUN_DB_ITEM
     		                        ( P_DATABASE_NAME    => 'X_EMPLOYER_CPF_CONTRIBUTIONS_ADDITIONAL_EARNINGS_PER_LE_MONTH'
                                         ,P_BUS_GROUP_ID     => P_BUSINESS_GROUP_ID
                                         ,P_LEGISLATION_CODE => 'SG' ));

      CP_AW_CPF_EE := to_number(PAY_BALANCE_PKG.RUN_DB_ITEM
     		                        ( P_DATABASE_NAME    => 'X_EMPLOYEE_CPF_CONTRIBUTIONS_ADDITIONAL_EARNINGS_PER_LE_MONTH'
                                         ,P_BUS_GROUP_ID     => P_BUSINESS_GROUP_ID
                                         ,P_LEGISLATION_CODE => 'SG' ));

      CP_AW_APR_FUND := to_number(PAY_BALANCE_PKG.RUN_DB_ITEM
     		                        ( P_DATABASE_NAME    => 'X_IR8S_MOA_407_PER_LE_MONTH'
                                         ,P_BUS_GROUP_ID     => P_BUSINESS_GROUP_ID
                                         ,P_LEGISLATION_CODE => 'SG' ));

   END;
   END IF;
   return 0;
   EXCEPTION
 	WHEN NO_DATA_FOUND THEN
  	  RAISE;
  	WHEN OTHERS THEN
           RAISE;

end;

function cf_refund_detailsformula(ASSIGNMENT_ACTION_ID2 in number, ASS_EXTRA_ID in varchar2) return number is
  l_aw_fr_date  varchar2(28);
  l_aw_to_date  varchar2(28);
  l_refund_date varchar2(28);
  l_er_date     varchar2(28);
  l_ee_date     varchar2(28);

BEGIN
   BEGIN

       PAY_BALANCE_PKG.SET_CONTEXT
		       ( P_CONTEXT_NAME  => 'ASSIGNMENT_ACTION_ID'
                        ,P_CONTEXT_VALUE => ASSIGNMENT_ACTION_ID2  );
       PAY_BALANCE_PKG.SET_CONTEXT
		       ( P_CONTEXT_NAME  => 'TAX_UNIT_ID'
                        ,P_CONTEXT_VALUE => P_LEGAL_ENTITY );
       PAY_BALANCE_PKG.SET_CONTEXT
		       ( P_CONTEXT_NAME  => 'SOURCE_ID'
                        ,P_CONTEXT_VALUE => ASS_EXTRA_ID );

      CP_AW_AMT := PAY_BALANCE_PKG.RUN_DB_ITEM
    	                        ( P_DATABASE_NAME    => 'X_MOA410'
                                 ,P_BUS_GROUP_ID     => P_BUSINESS_GROUP_ID
                                 ,P_LEGISLATION_CODE => 'SG' );

      l_aw_fr_date   := PAY_BALANCE_PKG.RUN_DB_ITEM
     	                        ( P_DATABASE_NAME    => 'X_DTM502'
                                 ,P_BUS_GROUP_ID     => P_BUSINESS_GROUP_ID
                                 ,P_LEGISLATION_CODE => 'SG' );
      CP_AW_FR_DATE := to_char(fnd_date.canonical_to_date(l_aw_fr_date),'DD-MON-YYYY');

      l_aw_to_date := PAY_BALANCE_PKG.RUN_DB_ITEM
     		                ( P_DATABASE_NAME    => 'X_DTM503'
                                 ,P_BUS_GROUP_ID     => P_BUSINESS_GROUP_ID
                                 ,P_LEGISLATION_CODE => 'SG' );
      CP_AW_TO_DATE := to_char(fnd_date.canonical_to_date(l_aw_fr_date),'DD-MON-YYYY');

      l_refund_date := PAY_BALANCE_PKG.RUN_DB_ITEM
     		                ( P_DATABASE_NAME    => 'X_DTM504'
                                 ,P_BUS_GROUP_ID     => P_BUSINESS_GROUP_ID
                                 ,P_LEGISLATION_CODE => 'SG' );
      CP_REFUND_DATE := to_char(fnd_date.canonical_to_date(l_refund_date),'DD-MON-YYYY');

      CP_ER_CONTRIB := PAY_BALANCE_PKG.RUN_DB_ITEM
     		                ( P_DATABASE_NAME    => 'X_MOA411'
                                 ,P_BUS_GROUP_ID     => P_BUSINESS_GROUP_ID
                                 ,P_LEGISLATION_CODE => 'SG' );

      CP_ER_INTR := PAY_BALANCE_PKG.RUN_DB_ITEM
     		                ( P_DATABASE_NAME    => 'X_MOA412'
                                 ,P_BUS_GROUP_ID     => P_BUSINESS_GROUP_ID
                                 ,P_LEGISLATION_CODE => 'SG' );

      l_er_date := PAY_BALANCE_PKG.RUN_DB_ITEM
     		                ( P_DATABASE_NAME    => 'X_DTM505'
                                 ,P_BUS_GROUP_ID     => P_BUSINESS_GROUP_ID
                                 ,P_LEGISLATION_CODE => 'SG' );
      CP_ER_DATE := to_char(fnd_date.canonical_to_date(l_er_date),'DD-MON-YYYY');

      CP_EE_CONTRIB := PAY_BALANCE_PKG.RUN_DB_ITEM
     		                ( P_DATABASE_NAME    => 'X_MOA413'
                                 ,P_BUS_GROUP_ID     => P_BUSINESS_GROUP_ID
                                 ,P_LEGISLATION_CODE => 'SG' );

      CP_EE_INTR := PAY_BALANCE_PKG.RUN_DB_ITEM
     		                ( P_DATABASE_NAME    => 'X_MOA414'
                                 ,P_BUS_GROUP_ID     => P_BUSINESS_GROUP_ID
                                 ,P_LEGISLATION_CODE => 'SG' );

      l_ee_date  := PAY_BALANCE_PKG.RUN_DB_ITEM
     		                ( P_DATABASE_NAME    => 'X_DTM506'
                                 ,P_BUS_GROUP_ID     => P_BUSINESS_GROUP_ID
                                 ,P_LEGISLATION_CODE => 'SG' );
      CP_EE_DATE := to_char(fnd_date.canonical_to_date(l_ee_date),'DD-MON-YYYY');


  END;
  return 0;

END;

--function delete_archive_data(t_payroll_action_id in number)(t_payroll_action_id  in number) return number is
  function delete_archive_data(t_payroll_action_id in number) return number is

  cursor c_get_asact_id
  (c_pact_id in pay_payroll_actions.payroll_action_id%type) is
  select distinct assignment_action_id
    from pay_assignment_actions
   where payroll_action_id = t_payroll_action_id;

  cursor c_get_arch_item_id
  (c_asact_id pay_assignment_actions.assignment_action_id%type) is
  select distinct archive_item_id
    from ff_archive_items
   where context1= c_asact_id;


  TYPE t_asact_id_tab IS TABLE OF pay_assignment_actions.assignment_action_id%type;
  asact_id_list t_asact_id_tab;

  TYPE t_arch_item_id_tab IS TABLE OF ff_archive_items.archive_item_id%type;
  arc_item_id_list t_arch_item_id_tab;

  v_archive_item_id ff_archive_items.archive_item_id%type;


BEGIN
         for process_rec in c_get_asact_id(t_payroll_action_id)
         loop
             open c_get_arch_item_id(process_rec.assignment_action_id);
             loop
               fetch c_get_arch_item_id into v_archive_item_id;
               exit when c_get_arch_item_id%NOTFOUND;
               delete from ff_archive_item_contexts where archive_item_id = v_archive_item_id;
		       delete from ff_archive_items where archive_item_id = v_archive_item_id;
             end loop;
             close c_get_arch_item_id;
          end loop;
          pay_archive.remove_report_actions(t_payroll_action_id);
          return(0);

END;

--Functions to refer Oracle report placeholders--

 Function CP_OW_p return number is
	Begin
	 return CP_OW;
	 END;
 Function CP_OW_CPF_ER_p return number is
	Begin
	 return CP_OW_CPF_ER;
	 END;
 Function CP_OW_CPF_EE_p return number is
	Begin
	 return CP_OW_CPF_EE;
	 END;
 Function CP_OW_APR_FUND_p return number is
	Begin
	 return CP_OW_APR_FUND;
	 END;
 Function CP_AW_p return number is
	Begin
	 return CP_AW;
	 END;
 Function CP_AW_CPF_ER_p return number is
	Begin
	 return CP_AW_CPF_ER;
	 END;
 Function CP_AW_CPF_EE_p return number is
	Begin
	 return CP_AW_CPF_EE;
	 END;
 Function CP_AW_APR_FUND_p return number is
	Begin
	 return CP_AW_APR_FUND;
	 END;
 Function CP_AW_AMT_p return number is
	Begin
	 return CP_AW_AMT;
	 END;
 Function CP_AW_FR_DATE_p return varchar2 is
	Begin
	 return CP_AW_FR_DATE;
	 END;
 Function CP_AW_TO_DATE_p return varchar2 is
	Begin
	 return CP_AW_TO_DATE;
	 END;
 Function CP_REFUND_DATE_p return varchar2 is
	Begin
	 return CP_REFUND_DATE;
	 END;
 Function CP_ER_CONTRIB_p return number is
	Begin
	 return CP_ER_CONTRIB;
	 END;
 Function CP_ER_INTR_p return number is
	Begin
	 return CP_ER_INTR;
	 END;
 Function CP_ER_DATE_p return varchar2 is
	Begin
	 return CP_ER_DATE;
	 END;
 Function CP_EE_CONTRIB_p return number is
	Begin
	 return CP_EE_CONTRIB;
	 END;
 Function CP_EE_INTR_p return number is
	Begin
	 return CP_EE_INTR;
	 END;
 Function CP_EE_DATE_p return varchar2 is
	Begin
	 return CP_EE_DATE;
	 END;
 Function CP_CPF_CAP_YES_p return varchar2 is
	Begin
	 return CP_CPF_CAP_YES;
	 END;
 Function CP_ASG_SET_NAME_p return varchar2 is
	Begin
	 return CP_ASG_SET_NAME;
	 END;
 Function CP_EMP_NO_p return varchar2 is
	Begin
	 return CP_EMP_NO;
	 END;
 Function CP_CPF_CAP_NO_p return varchar2 is
	Begin
	 return CP_CPF_CAP_NO;
	 END;
 Function CP_SYS_DATE_p return varchar2 is
	Begin
	 return CP_SYS_DATE;
	 END;
 Function CP_BASIS_END_p return varchar2 is
	Begin
	 return CP_BASIS_END;
	 END;
END PAY_PYSG8SAD_XMLP_PKG ;

/
