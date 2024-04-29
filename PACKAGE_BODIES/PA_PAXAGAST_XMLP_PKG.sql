--------------------------------------------------------
--  DDL for Package Body PA_PAXAGAST_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PAXAGAST_XMLP_PKG" AS
/* $Header: PAXAGASTB.pls 120.0 2008/01/02 11:13:20 krreddy noship $ */

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
cust_name VARCHAR2(50);
BEGIN


/*srw.user_exit('FND SRWINIT');*/null;


/*srw.user_exit('FND GETPROFILE
NAME="PA_RULE_BASED_OPTIMIZER"
FIELD=":p_rule_optimizer"
PRINT_ERROR="N"');*/null;







/*srw.user_exit('FND GETPROFILE
NAME="PA_DEBUG_MODE"
FIELD=":p_debug_mode"
PRINT_ERROR="N"');*/null;









IF cust is not null then
    select p.party_name into cust_name from
    hz_parties p, hz_cust_accounts c
    where p.party_id = c.party_id
      and c.cust_account_id = CUST;
end if;

c_customer_name := cust_name;

IF sort is not null then
    c_sort := initcap(sort);
end if;

  IF (get_company_name <> TRUE) THEN       RAISE init_failure;
  END IF;

EXCEPTION
  WHEN   OTHERS  THEN
    RAISE_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;

END;  return (TRUE);
end;

FUNCTION  get_company_name    RETURN BOOLEAN IS
  l_name               gl_sets_of_books.name%TYPE;

BEGIN
  SELECT  rtrim(gl.name)
  INTO    l_name
  FROM    gl_sets_of_books gl,pa_implementations pi
  WHERE   gl.set_of_books_id = pi.set_of_books_id;

  c_company_name_header     := l_name;

  RETURN (TRUE);

EXCEPTION

  WHEN   OTHERS  THEN
    RETURN (FALSE);

END;

function AfterReport return boolean is
begin

BEGIN
 /*srw.user_exit('FND SRWEXIT');*/null;

END;  return (TRUE);
end;

function CF_1Formula return VARCHAR2 is
begin
  return(pa_multi_currency.get_acct_currency_code);
end;

--Functions to refer Oracle report placeholders--

 Function C_COMPANY_NAME_HEADER_p return varchar2 is
	Begin
	 return C_COMPANY_NAME_HEADER;
	 END;
 Function C_customer_name_p return varchar2 is
	Begin
	 return C_customer_name;
	 END;
 Function C_sort_p return varchar2 is
	Begin
	 return C_sort;
	 END;
END PA_PAXAGAST_XMLP_PKG ;


/
