--------------------------------------------------------
--  DDL for Package Body PA_PAXRWPTY_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PAXRWPTY_XMLP_PKG" AS
/* $Header: PAXRWPTYB.pls 120.0 2008/01/02 12:14:11 krreddy noship $ */

FUNCTION  get_company_name    RETURN BOOLEAN IS
  l_name                  gl_sets_of_books.name%TYPE;
BEGIN
  SELECT  gl.name
  INTO    l_name
  FROM    gl_sets_of_books gl,pa_implementations pi
  WHERE   gl.set_of_books_id = pi.set_of_books_id;

  c_company_name_header     := l_name;

  RETURN (TRUE);

EXCEPTION

  WHEN   OTHERS  THEN
    RETURN (FALSE);

END;

function BeforeReport return boolean is
begin


declare
init_error exception;
begin
/*srw.user_exit('FND SRWINIT');*/null;


if ( get_company_name <> TRUE ) then
  raise init_error;
end if;

IF (no_data_found_func <> TRUE) THEN
   RAISE init_error;
END IF;


end;  return (TRUE);
end;

Function NO_DATA_FOUND_FUNC RETURN BOOLEAN IS
message_name VARCHAR2(80);
BEGIN
 select
  meaning
 into
  message_name
 from
  pa_lookups
 where
    lookup_type = 'MESSAGE'
and lookup_code = 'NO_DATA_FOUND';
c_no_data_found := message_name;
RETURN(TRUE);
EXCEPTION
 when others then
 RETURN(FALSE);
END;

function c_desc1formula(cbemc in varchar2) return varchar2 is
begin

return(get_budget_code_desc(cbemc));

end;

Function get_budget_code_desc (code in VARCHAR2) return VARCHAR2 is
desc1    varchar2(255);
cursor c is
  select description
  from pa_budget_entry_methods
  where budget_entry_method_code = code;
begin
  open c;
  fetch c into desc1;
  close c;
  return (desc1);
exception
  when others then
     null;
end ;

function c_desc2formula(rbemc in varchar2) return varchar2 is
begin
  return(get_budget_code_desc(rbemc));
end;

function get_resource_name (list_id number) return VARCHAR2 is
  name varchar2(255);
  cursor c is
   select resource_list_name
   from pa_resource_lists_active_v
   where resource_list_id = list_id;
begin
   open c;
   fetch c into name;
   close c;
   return name;
exception
  when others then
    null;
end;

function c_desc3formula(cbrld in number) return varchar2 is
begin

return(get_resource_name(cbrld));



end;

function c_desc4formula(rbrld in number) return varchar2 is
begin

return(get_resource_name(rbrld));
end;

function c_desc5formula(drli in number) return varchar2 is
begin

return(get_resource_name(drli));
end;

function get_meaning (type in VARCHAR2,code in VARCHAR2) return VARCHAR2 is
v_meaning     varchar2(80);
cursor c is
select meaning
from pa_lookups
where lookup_type = type
and   lookup_code = code;
begin
  open c;
  fetch c into v_meaning;
  close c;
  return v_meaning;
exception
  when others then
    null;
end;

function c_desc6formula(ptcc in varchar2) return varchar2 is
begin

return(get_meaning('PROJECT TYPE CLASS',ptcc));
end;

function c_desc7formula(cctc in varchar2) return varchar2 is
begin

return(get_meaning('CAPITAL COST TYPE',cctc));
end;

function c_desc8formula(cgmc in varchar2) return varchar2 is
begin

return(get_meaning('CIP GROUPING METHOD',cgmc));
end;

function c_desc9formula(icaf in varchar2) return varchar2 is
begin

return(get_meaning('YES_NO',icaf));
end;

function cf_dest_project_idformula(burden_sum_dest_project_id in number) return varchar2 is
temp_proj_name VARCHAR2(25);
begin
IF burden_sum_dest_project_id IS NOT NULL THEN
  SELECT segment1 INTO temp_proj_name FROM pa_projects
  WHERE  project_id = burden_sum_dest_project_id ;
  RETURN temp_proj_name ;
END IF;
  return burden_sum_dest_project_id;
end;

function cf_dest_task_nameformula(burden_sum_dest_task_id in number) return varchar2 is
temp_task_name VARCHAR2(20);
begin
  IF burden_sum_dest_task_id IS NOT NULL THEN
	SELECT task_name INTO temp_task_name FROM pa_tasks
	WHERE  task_id = burden_sum_dest_task_id ;
	RETURN temp_task_name ;
  END IF;
  return (burden_sum_dest_task_id);
end;

function cf_burden_acc_flagformula(burden_account_flag in varchar2) return varchar2 is
temp_yesno VARCHAR2(40) :=null;
begin
  IF  burden_account_flag IS NOT NULL THEN
	 SELECT SUBSTR(meaning,1,40) INTO temp_yesno FROM fnd_lookups
	 WHERE  lookup_type = 'YES_NO' AND lookup_code = burden_account_flag;
  END IF;
RETURN temp_yesno ;
end;

function cf_bur_amt_disp_methformula(burden_amt_display_method in varchar2) return varchar2 is
temp_disp_meth VARCHAR2(40):=null;
begin
   IF burden_amt_display_method IS NOT NULL THEN
      SELECT SUBSTR(meaning,1,40) INTO temp_disp_meth FROM pa_lookups
             WHERE  lookup_type = 'BURDEN_ACCOUNTING'
             AND    lookup_code = burden_amt_display_method ;
   END IF;
   RETURN temp_disp_meth ;
end;

function CF_CURRENCY_CODEFormula return Char is
begin

  return(pa_multi_currency.get_acct_currency_code);

end;

function AfterReport return boolean is
begin
  /*srw.user_exit('FND SRWEXIT');*/null;

  return (TRUE);
end;

function cf_baseline_fiunding_flagformu(baseline_funding_flag in varchar2) return char is
l_meaning varchar2(40):=NULL;
begin
  if baseline_funding_flag IS NOT NULL then
select meaning into l_meaning from fnd_lookups
where lookup_type='YES_NO'
and lookup_code=baseline_funding_flag;
end if;
return l_meaning;
end;

function cf_revaluate_funding_flagformu(revaluate_funding_flag in varchar2) return char is
l_meaning varchar2(40):=NULL;
begin
  if revaluate_funding_flag IS NOT NULL then
select meaning into l_meaning from fnd_lookups
where lookup_type='YES_NO'
and lookup_code=revaluate_funding_flag;
end if;
return l_meaning;
end;

function cf_include_gains_losses_flagfo(include_gains_losses_flag in varchar2) return char is
l_meaning varchar2(40):=NULL;
begin
  if include_gains_losses_flag IS NOT NULL then
select meaning into l_meaning from fnd_lookups
where lookup_type='YES_NO'
and lookup_code=include_gains_losses_flag;
end if;
return l_meaning;
end;

--Functions to refer Oracle report placeholders--

 Function C_Company_Name_Header_p return varchar2 is
	Begin
	 return C_Company_Name_Header;
	 END;
 Function C_no_data_found_p return varchar2 is
	Begin
	 return C_no_data_found;
	 END;
END PA_PAXRWPTY_XMLP_PKG ;


/
