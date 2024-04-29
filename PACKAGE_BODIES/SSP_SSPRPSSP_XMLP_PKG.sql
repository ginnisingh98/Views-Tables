--------------------------------------------------------
--  DDL for Package Body SSP_SSPRPSSP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."SSP_SSPRPSSP_XMLP_PKG" AS
/* $Header: SSPRPSSPB.pls 120.1 2007/12/24 14:07:37 amakrish noship $ */

function BeforeReport return boolean is
begin
declare

cursor payroll_name is
Select payroll_name
  from pay_payrolls_f
 where business_group_id = p_business_group_id
   and payroll_id        = p_payroll_id
   and effective_start_date <= p_date_to
   and effective_end_date >= p_date_from
order by effective_start_date desc;

cursor person_name is
Select full_name
  from per_people_f
 where person_id = p_person_id
   and business_group_id = p_business_group_id
   and effective_start_date <= p_date_to
   and effective_end_date >= p_date_from
order by effective_start_date desc;

begin
   /*srw.user_exit('FND SRWINIT');*/null;

   insert into fnd_sessions
      (session_id, effective_date)
   select userenv('sessionid'),
          trunc(sysdate)
   from   sys.dual
   where  not exists
             (select 1
              from   fnd_sessions fs
              where  fs.session_id = userenv('sessionid'));
c_business_group_name :=
                      hr_reports.get_business_group(p_business_group_id);

if p_payroll_id is not null then
open payroll_name;
fetch payroll_name into C_payroll_name;
close payroll_name;
end if;
if P_person_id is not null then
open person_name;
fetch person_name into C_person_name;
close person_name;
end if;
fnd_date.initialize('YYYY/MM/DD',null);
exception
   when NO_DATA_FOUND then
      null;
end;
  return (TRUE);
end;

function e_processedformula(E_ELEMENT_ENTRY_ID in number) return varchar2 is
begin

if (ssp_smp_support_pkg.entry_already_processed(E_ELEMENT_ENTRY_ID)) then
   return('Yes');
else
   return(NULL);
end if;
RETURN NULL; end;

function e_ssp_weeks_processedformula(E_PROCESSED in varchar2, E_SSP_WEEKS in number) return number is
begin

if (E_PROCESSED = 'Yes') then
   return(E_SSP_WEEKS);
else
   return(0);
end if;
RETURN NULL; end;

function e_amount_processedformula(E_PROCESSED in varchar2, E_AMOUNT in number) return number is
begin

if (E_PROCESSED = 'Yes') then
   return(E_AMOUNT);
else
   return(0);
end if;
RETURN NULL; end;

function AfterReport return boolean is
begin
  /*srw.user_exit('FND SRWEXIT');*/null;

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function C_BUSINESS_GROUP_NAME_p return varchar2 is
	Begin
	 return C_BUSINESS_GROUP_NAME;
	 END;
 Function C_REPORT_SUBTITLE_p return varchar2 is
	Begin
	 return C_REPORT_SUBTITLE;
	 END;
 Function C_PAYROLL_NAME_p return varchar2 is
	Begin
	 return C_PAYROLL_NAME;
	 END;
 Function C_PERSON_NAME_p return varchar2 is
	Begin
	 return C_PERSON_NAME;
	 END;
END SSP_SSPRPSSP_XMLP_PKG ;

/
