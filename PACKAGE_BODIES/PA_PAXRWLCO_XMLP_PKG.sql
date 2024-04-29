--------------------------------------------------------
--  DDL for Package Body PA_PAXRWLCO_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PAXRWLCO_XMLP_PKG" AS
/* $Header: PAXRWLCOB.pls 120.0 2008/01/02 11:58:44 krreddy noship $ */

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
Org_Name hr_organization_units.name%TYPE;
Sort_By_Name pa_lookups.meaning%TYPE;

begin

/*srw.user_exit('FND SRWINIT');*/null;



if START_ORG_ID is not NULL then
    select substr(name,1,60) into Org_Name from
           hr_organization_units
    where organization_id = START_ORG_ID;
end if;
C_Org_Name := Org_Name;
if SORT_BY is not NULL then
   select meaning into Sort_By_Name from pa_lookups
   where lookup_code = SORT_BY
      and lookup_type ='LABOR RATE SORT BY';
end if;
C_Sort_By_Name := Sort_By_Name;
if ( get_company_name <> TRUE ) then
  raise init_error;
end if;

if ( get_start_org <> TRUE) then
    raise init_error;
end if;

end;
  return (TRUE);
end;

FUNCTION get_start_org RETURN BOOLEAN IS
  c_start_organization_id number;


BEGIN
select
 decode(start_org_id,null,      start_organization_id,start_org_id)
 into
     c_start_organization_id
 from
  pa_implementations;

insert into
pa_org_reporting_sessions
(start_organization_id,session_id)
values
(c_start_organization_id,userenv('SESSIONID'));

RETURN (TRUE);

EXCEPTION
 WHEN OTHERS THEN
  RETURN (FALSE);

END;

function AfterReport return boolean is
begin

Begin
 /*srw.user_exit('FND SRWEXIT');*/null;

 Rollback;
End;  return (TRUE);
end;

function BeforePForm return boolean is
begin

  return (TRUE);
end;

function AfterPForm return boolean is
begin

  return (TRUE);
end;

function BetweenPage return boolean is
begin

  return (TRUE);
end;

function CF_Currency_CodeFormula return Char is
begin
  return(pa_multi_currency.get_acct_currency_code);
end;

--Functions to refer Oracle report placeholders--

 Function C_Company_Name_Header_p return varchar2 is
	Begin
	 return C_Company_Name_Header;
	 END;
 Function C_Org_Name_p return varchar2 is
	Begin
	 return C_Org_Name;
	 END;
 Function C_Sort_By_Name_p return varchar2 is
	Begin
	 return C_Sort_By_Name;
	 END;
END PA_PAXRWLCO_XMLP_PKG ;


/
