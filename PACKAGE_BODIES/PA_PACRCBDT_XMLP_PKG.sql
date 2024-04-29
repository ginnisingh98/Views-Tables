--------------------------------------------------------
--  DDL for Package Body PA_PACRCBDT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PACRCBDT_XMLP_PKG" AS
/* $Header: PACRCBDTB.pls 120.0 2008/01/02 10:57:25 krreddy noship $ */
function cf_total_costformula(p_project_id in number, capital_event_id in number) return number is
l_total_cost NUMBER :=0;
begin
  begin
    select SUM(decode(cp_capital_cost_type_flag,'R',
                                            amount,
                                            decode(cdl.line_type,'D',cdl.amount,
                                                                     cdl.burdened_cost)))
    into  l_total_cost
    from  pa_cost_distribution_lines_all cdl,
           pa_expenditure_items_all ei
   where  ei.expenditure_item_id = cdl.expenditure_item_id
     and  cdl.project_id = cf_total_costformula.p_project_id
     and  ei.capital_event_id = cf_total_costformula.capital_event_id
     and  (cdl.line_type =  decode(cp_line_type, 'D', 'D', 'R', 'R')  OR
           cdl.line_type = decode(cp_line_type, 'D', 'D', 'R', 'I')
          );
  exception
    when no_data_found then
    l_total_Cost:=0;
   end;
return(l_total_cost);
end;
function cf_project_setupformula(project_id in number) return char is
CURSOR C_project_setup IS (SELECT PPT.capital_cost_type_code ,PPT.total_burden_flag,PPT.burden_amt_display_method
	 			 FROM PA_PROJECT_TYPES PPT,
           			      PA_PROJECTS_ALL PP
    				WHERE PP.project_type = PPT.project_type
	 			  AND PP.project_id=cf_project_setupformula.project_id);
r_project_setup c_project_setup%ROWTYPE;
begin
OPEN C_project_setup;
FETCH C_project_setup INTO r_project_setup;
cp_capital_cost_type_flag:=r_project_setup.capital_cost_type_code;
if (cp_capital_cost_type_flag = 'B' and
      nvl(r_project_setup.total_burden_flag,'N') = 'Y') then
        cp_line_type := 'D' ;
  else
        cp_line_type := 'R' ;
end if ;
CLOSE C_project_setup;
return('X');
end;
function cf_locationformula(location_id in number) return char is
BEGIN
RETURN (fnd_flex_ext.get_segs('OFA', 'LOC#',101, location_id));
end;
function cf_categoryformula(asset_category_id in number) return char is
BEGIN
RETURN (fnd_flex_ext.get_segs('OFA', 'CAT#',101, asset_category_id));
end;
FUNCTION  get_company_name    RETURN BOOLEAN IS
  l_name                  gl_sets_of_books.name%TYPE;
BEGIN
  SELECT  gl.name
  INTO    l_name
  FROM    gl_sets_of_books gl,pa_implementations pi
  WHERE   gl.set_of_books_id = pi.set_of_books_id;
  cp_company_name     := l_name;
  RETURN (TRUE);
EXCEPTION
  WHEN   OTHERS  THEN
    RETURN (FALSE);
END;
function BeforeReport return boolean is
l_purgeable         varchar2(20);
l_retcode           NUMBER:=0;
l_errbuf            VARCHAR2(2000):=Null;
number_of_messages  NUMBER;
message_buf         VARCHAR2(2000);
init_failure        EXCEPTION;
BEGIN

     P_DEBUG_MODE:='G';
        /*SRW.MESSAGE('100','BEFORE CALLING INIT USEREXIT');*/null;
    /*srw.user_exit('FND SRWINIT');*/null;
        IF P_CONC_REQUEST_ID IS NULL THEN
        P_CONC_REQUEST_ID:=-1;
	/*SRW.MESSAGE('100','P_CONC_ID IS NULL');*/null;
    END IF;
IF p_project_id IS NOT NULL THEN
  Begin
    select segment1
    into p_project_number
    from pa_projects_all
   where project_id=p_project_id;
  EXCEPTION
   when no_data_found then null;
  END;
END IF;
p_project_number_parameter :=p_project_number;
IF p_org_id IS NOT NULL THEN
   BEGIN
    select name
    INTO p_org_name
    from pa_organizations_proj_all_bg_v
    where organization_id=p_org_id;
  EXCEPTION
    when no_data_found then null;
  END;
END IF;

    /*SRW.MESSAGE('100','BEFORE GETTTING THE DEBUG MODE PROFILE VALUE');*/null;
        /*srw.user_exit('FND GETPROFILE
                   NAME="PA_DEBUG_MODE"
	           FIELD=":p_debug_mode"
		   PRINT_ERROR="N"');*/null;
    /*SRW.MESSAGE('100','BEFORE SETTING ALTER SEESION');*/null;
    If p_debug_mode = 'Y' then
       /*srw.do_sql('ALTER SESSION SET SQL_TRACE TRUE');*/null;
    End If;
    /*SRW.MESSAGE('100','BEFORE GETTTING THE COMP NAME');*/null;
        IF (get_company_name <> TRUE) THEN          RAISE init_failure;
    END IF;
    /*SRW.MESSAGE('100','BEFORE CALLING THE GET CAP');*/null;
    /*SRW.MESSAGE('100','BEFORE CALLING THE GET CAP P1'||p_project_type);*/null;
    /*SRW.MESSAGE('100','BEFORE CALLING THE GET CAP P2'||p_project_id);*/null;
    /*SRW.MESSAGE('100','BEFORE CALLING THE GET CAP P3'||p_event_period);*/null;
    /*SRW.MESSAGE('100','BEFORE CALLING THE GET CAP P4'||p_class_category);*/null;
    /*SRW.MESSAGE('100','BEFORE CALLING THE GET CAP P5'||p_class_code);*/null;
    /*SRW.MESSAGE('100','BEFORE CALLING THE GET CAP P6'||p_show_detail);*/null;
    return (TRUE);
EXCEPTION
    WHEN init_failure then
        /*srw.message('102','Unable to get the Title');*/null;
        return (TRUE);
    WHEN   OTHERS  THEN
        l_retcode := SQLCODE;
        l_errbuf := SQLERRM;
        /*srw.message('101','Unexpected Error'||substr(l_errbuf,1,100));*/null;
        RAISE_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;
        return (TRUE);
end ;
function CF_currency_CodeFormula return Char is
begin
 return(pa_multi_currency.get_acct_currency_code);
end;
function AfterReport return boolean is
begin
  /*srw.user_exit('FND SRWEXIT');*/null;
  return (TRUE);
end;
function project_asset_type_dispformula(project_asset_type in varchar2) return char is
l_meaning pa_lookups.meaning%TYPE:=NULL;
begin
  BEGIN
    select meaning
      into l_meaning
      from pa_lookups
     where lookup_type ='PROJECT_ASSET_TYPES'
       and lookup_code=project_asset_type;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
  END;
return(l_meaning);
end;
function event_type_dspformula(event_type in varchar2) return char is
l_meaning pa_lookups.meaning%type;
begin
  BEGIN
   select meaning
     into l_meaning
     from pa_lookups
   where lookup_type ='CAPITAL_TYPE'
     and lookup_code=event_type;
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
     l_meaning :=NULL;
   END;
return(l_meaning);
end;
function organization_dspformula(CARRYING_OUT_ORGANIZATION_ID in number) return char is
l_name HR_ORGANIZATION_UNITS .name%TYPE;
begin
  BEGIN
  select  ORG.name
   INTO l_name
   from HR_ORGANIZATION_UNITS  ORG
   where  ORG.ORGANIZATION_ID = CARRYING_OUT_ORGANIZATION_ID;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
  l_name :=NULL;
  END;
return(l_name);
end;
function b_capital_event_number1formatt(capital_event_id in number) return boolean is
begin

    if ((capital_event_id = '-1') )
  then
    return (FALSE);
  end if;

  return (TRUE);
end;

function b_project_type3formattrigger(no_rec in number) return boolean is
begin
  if (no_rec <>0)
  then
    return (FALSE);
  end if;
  return (TRUE);
end;
function b_sumcurrent_asset_costpercap2(sumcurrent_asset_costperasset in number) return boolean is
begin
    if (P_SHOW_DETAIL <> 'Y')
  then
       return (FALSE);
     end if;
if (sumcurrent_asset_costperasset IS NULL)
    then
  return (TRUE);
else
return(false);
end if;
end;
function b_8formattrigger(capital_event_id in number) return boolean is
begin
    if ((capital_event_id = '-1') )
  then
    return (FALSE);
  end if;
  return (TRUE);
end;
function b_9formattrigger(capital_event_id in number) return boolean is
begin
    if ((capital_event_id = '-1') )
  then
    return (FALSE);
  end if;
  return (TRUE);
end;
--Functions to refer Oracle report placeholders--
 Function CP_line_type_p return varchar2 is
	Begin
	 return CP_line_type;
	 END;
 Function CP_capital_cost_type_flag_p return varchar2 is
	Begin
	 return CP_capital_cost_type_flag;
	 END;
 Function cp_company_name_p return varchar2 is
	Begin
	 return cp_company_name;
	 END;
Function p_project_number_parameter_p return varchar2 is
Begin
	 return p_project_number_parameter;
END;

END PA_PACRCBDT_XMLP_PKG ;


/
