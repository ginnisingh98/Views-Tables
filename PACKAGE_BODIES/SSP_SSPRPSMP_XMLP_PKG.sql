--------------------------------------------------------
--  DDL for Package Body SSP_SSPRPSMP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."SSP_SSPRPSMP_XMLP_PKG" AS
/* $Header: SSPRPSMPB.pls 120.1 2007/12/24 14:07:13 amakrish noship $ */

function BeforeReport return boolean is
begin

declare
   l_test number;
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
Select distinct  payroll_name into C_payroll_name
  from pay_payrolls
 where business_group_id = p_business_group_id
   and payroll_id        = p_payroll_id;
end if;

if P_person_id is not null then
Select distinct substr(full_name,1,80) into C_person_name
  from per_people_f ppf
 where person_id = P_person_id
   and business_group_id = P_business_group_id
   and (
          (p_session_date between ppf.effective_start_date and ppf.effective_end_date)
          or
          (p_session_date > ppf.effective_end_date
           and ppf.effective_end_date = (select max(p1.effective_end_date)
                                           from per_all_people_f  p1
                                          where p1.person_id = ppf.person_id)
          )
          or
          (p_session_date < ppf.effective_start_date
           and ppf.effective_start_date = ppf.start_date
          )
       );

end if;
fnd_date.initialize('YYYY/MM/DD',null);
exception
   when NO_DATA_FOUND then
      null;
end;

  return (TRUE);
end;

function c_smpformula(M_due_date in date, M_PERSON_ID in number) return varchar2 is
begin

Declare
    Ewc          date;
    Qw           date;
    Due_date     date;
    Avg_earnings number(10,2);
Begin
Due_date := M_due_date;
Ewc := ssp_smp_pkg.expected_week_of_confinement(Due_date);
Qw  := ssp_smp_pkg.qualifying_week(Due_date);

C_EWC := Ewc;
C_WQ  := Qw;

Select  average_earnings_amount into Avg_earnings
  from  ssp_earnings_calculations
 where  effective_date = Qw
   and  person_id = M_PERSON_ID;

C_AVG_EARNINGS := Avg_earnings;

return NULL;

Exception
   When Others then null;



End;

RETURN NULL; end;

function c_processedformula(E_Element_entry_id in number) return varchar2 is
begin

Begin
if ssp_smp_support_pkg.entry_already_processed(E_Element_entry_id) then
   return('Yes');
else
   return(null);
end if;
End;
RETURN NULL; end;

function c_amount_processedformula(C_Processed in varchar2, E_amount in number) return number is
begin

Begin

If C_Processed = 'Yes' then
    return(E_amount);
else
    return(0);
end if;

End;
RETURN NULL; end;

function c_recoverable_processedformula(C_Processed in varchar2, E_recoverable in number) return number is
begin

Begin

If C_Processed = 'Yes' then
    return(E_recoverable);
else
    return(0);
End if;

End;
RETURN NULL; end;

function AfterReport return boolean is
begin
  /*srw.user_exit('FND SRWEXIT');*/null;

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function C_EWC_p return date is
	Begin
	 return C_EWC;
	 END;
 Function C_WQ_p return date is
	Begin
	 return C_WQ;
	 END;
 Function C_AVG_EARNINGS_p return number is
	Begin
	 return C_AVG_EARNINGS;
	 END;
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


END SSP_SSPRPSMP_XMLP_PKG ;

/
