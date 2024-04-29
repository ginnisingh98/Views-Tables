--------------------------------------------------------
--  DDL for Package Body PA_PAXRWSBR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PAXRWSBR_XMLP_PKG" AS
/* $Header: PAXRWSBRB.pls 120.0 2008/01/02 12:16:32 krreddy noship $ */

FUNCTION  get_cover_page_values   RETURN BOOLEAN IS

BEGIN

RETURN(TRUE);

EXCEPTION
WHEN OTHERS THEN
  RETURN(FALSE);

END;

function BeforeReport return boolean is
begin

Declare
 init_failure exception;
 hold_org_name    hr_organization_units.name%TYPE;

BEGIN

EFFECTIVE_DATE1:=to_char(EFFECTIVE_DATE,'DD-MON-YY');

/*srw.user_exit('FND SRWINIT');*/null;

/*srw.user_exit('FND GETPROFILE
NAME="PA_RULE_BASED_OPTIMIZER"
FIELD=":p_rule_optimizer"
PRINT_ERROR="N"');*/null;







If organization_id is not null
  then
    select substr(name, 1, 60)
    into   hold_org_name
    from   hr_organization_units
    where  organization_id = PA_PAXRWSBR_XMLP_PKG.organization_id;
    c_org_name := hold_org_name;
end if;


  IF (get_company_name <> TRUE) THEN       RAISE init_failure;
  END IF;

EXCEPTION
  WHEN   OTHERS  THEN
    RAISE_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;

END;  return (TRUE);
end;

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

function CF_ACCT_CURRENCY_CODEFormula return varchar2 is
begin
  return(pa_multi_currency.get_acct_currency_code);
end;

function AfterReport return boolean is
begin
  /*srw.user_exit('FND SRWEXIT');*/null;

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function C_COMPANY_NAME_HEADER_p return varchar2 is
 Begin
  return C_COMPANY_NAME_HEADER;
  END;
 Function C_org_name_p return varchar2 is
 Begin
  return C_org_name;
  END;
END PA_PAXRWSBR_XMLP_PKG ;


/
