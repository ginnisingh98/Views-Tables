--------------------------------------------------------
--  DDL for Package Body PAY_PAYUSTIM_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAYUSTIM_XMLP_PKG" AS
/* $Header: PAYUSTIMB.pls 120.0 2007/12/28 06:48:02 srikrish noship $ */

function AfterPForm return boolean is
l_param varchar2(240);
L_FLAG VARCHAR2(5);
begin

 declare
         l_trace varchar2(30):='';
     CURSOR p_trace IS select upper(parameter_value)
    from pay_action_parameters
    where parameter_name = 'TRACE';


     begin

      OPEN p_trace;
      LOOP
      FETCH p_trace INTO l_trace;
      EXIT WHEN p_trace%NOTFOUND;

         if  l_trace = 'Y'
             then
                       /*srw.do_sql('alter session set SQL_TRACE TRUE');*/--null;
                       EXECUTE IMMEDIATE 'alter session set SQL_TRACE TRUE';

         end if;
      END LOOP;
      CLOSE p_trace;
 exception when others then
  null;

  end;


begin

 select tax_unit_id,
        attribute2,
        to_number(attribute3),
        to_date(attribute4,'MM/DD/YYYY'),
       to_date(attribute5,'MM/DD/YYYY')
   into PACTID,
        l_param,
        p_business_group_id,
        p_start_date,
        p_end_date
   from pay_us_rpt_totals
  where organization_id = to_number(PPA_FINDER)
    and attribute1  = 'TIAA-CREF'
    and rownum=1;

  p_consolidation_set_id := pqp_ustiaa_pkg.get_parameter('TRANSFER_CONC_SET',l_param);
  p_payroll_id           := pqp_ustiaa_pkg.get_parameter('TRANSFER_PAYROLL',l_param);
  p_gre_id               := pqp_ustiaa_pkg.get_parameter('TRANSFER_GRE',l_param);

 pqp_tiaalod_pkg.Chk_Neg_Amt(p_payroll_action_id => PACTID);

exception when others then

  /*srw.message(1,'Legislative parameter not found. ERROR');*/null;

delete from pay_us_rpt_totals where tax_unit_id = pactid;
commit;
  raise;
end;

T_START_DATE := to_char(p_start_date,'DD-MON-YYYY');
T_END_DATE := to_char(p_end_date,'DD-MON-YYYY');


  return (TRUE);
end;

function AfterReport return boolean is
l_flag varchar2(5);
begin

select attribute19
into
   l_flag
   from pay_us_rpt_totals
  where tax_unit_id = pactid
    and attribute1  = 'TIAA-CREF'
and  rownum=1;

if l_flag ='Y' then
delete from pay_us_rpt_totals where tax_unit_id = pactid;
  commit;
else

  update pay_us_rpt_totals
 set attribute19='Y'
 where tax_unit_id = pactid
 and attribute1  = 'TIAA-CREF';

commit;
  end if;
  --hr_standard.event('AFTER REPORT');
  return (TRUE);
end;

function BeforeReport return boolean is
begin

begin
   --hr_standard.event('BEFORE REPORT');
  cp_business_group_name := hr_reports.get_business_group(p_business_group_id);

  if p_payroll_id is not null then
     select distinct payroll_name,'Payroll    : '||payroll_name
       into cp_payroll_name,cp_print_set_payroll_name
       from pay_payrolls_f
      where payroll_id = p_payroll_id
        and effective_start_date <= p_start_date
        and effective_end_date >= p_end_date;
  end if;

  if p_payroll_id is null and p_consolidation_set_id is not null then
     select consolidation_set_name,'Consolidation Set : '||consolidation_set_name
       into cp_consolidation_set_name,cp_print_set_payroll_name
       from pay_consolidation_sets
      where consolidation_set_id = p_consolidation_set_id;
  end if;

  if p_gre_id is not null then
     select name
       into cp_gre_name
       from hr_organization_units
      where organization_id = p_gre_id;
  end if;


exception
when others then
 /*srw.message(1,'Legislative parameter not found. ERROR');*/null;

delete from pay_us_rpt_totals where tax_unit_id = pactid;

  raise;
end;
  return (TRUE);
end;

function cf_1formula(assg_exp in varchar2) return char is
cursor err_msg is
select
   distinct attribute15  err_message
from pay_us_rpt_totals  purt
where  tax_unit_id =pactid
  and  attribute1<>'TIAA-CREF'
  and attribute14 is not null
  and attribute5  = assg_exp;

l_err_msg1  varchar2(2000);
l_err_msg  varchar2(2000);

begin
OPEN err_msg;
LOOP
FETCH err_msg into l_err_msg1;
EXIT WHEN err_msg%NOTFOUND;
IF l_err_msg is NULL THEN
l_err_msg:=l_err_msg1;
else

l_err_msg :=l_err_msg||','||l_err_msg1;
end if;
END LOOP;
CLOSE err_msg;

  return(l_err_msg);







end;

function cf_ra_gra_plan_by_instformula(RA_GRA_PLAN_BY_INST1 in number) return number is
begin
  RETURN(RA_GRA_PLAN_BY_INST1*100);
end;

function cf_ra_gra_plan_reductformula(RA_GRA_PLAN_REDUCT1 in number) return number is
begin
  RETURN(RA_GRA_PLAN_REDUCT1*100);
end;

function cf_ra_plan_deductformula(RA_PLAN_DEDUCT1 in number) return number is
begin
  RETURN(RA_PLAN_DEDUCT1*100);
end;

function cf_ra_addl_reductformula(RA_ADDL_REDUCT1 in number) return number is
begin
  RETURN(RA_ADDL_REDUCT1*100);
end;

function cf_ra_addl_deductformula(RA_ADDL_DEDUCT1 in number) return number is
begin
  RETURN(RA_ADDL_DEDUCT1*100);
end;

function cf_sra_gsra_reductformula(SRA_GSRA_REDUCT1 in number) return number is
begin
 RETURN(SRA_GSRA_REDUCT1*100);
end;

--Functions to refer Oracle report placeholders--

 Function CP_BUSINESS_GROUP_NAME_p return varchar2 is
	Begin
	 return CP_BUSINESS_GROUP_NAME;
	 END;
 Function CP_PAYROLL_NAME_p return varchar2 is
	Begin
	 return CP_PAYROLL_NAME;
	 END;
 Function CP_GRE_NAME_p return varchar2 is
	Begin
	 return CP_GRE_NAME;
	 END;
 Function CP_CONSOLIDATION_SET_NAME_p return varchar2 is
	Begin
	 return CP_CONSOLIDATION_SET_NAME;
	 END;
 Function CP_PRINT_SET_PAYROLL_NAME_p return varchar2 is
	Begin
	 return CP_PRINT_SET_PAYROLL_NAME;
	 END;
END PAY_PAYUSTIM_XMLP_PKG ;

/
