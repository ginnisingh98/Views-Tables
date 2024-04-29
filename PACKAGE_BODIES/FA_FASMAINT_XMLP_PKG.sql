--------------------------------------------------------
--  DDL for Package Body FA_FASMAINT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_FASMAINT_XMLP_PKG" AS
/* $Header: FASMAINTB.pls 120.0.12010000.1 2008/07/28 13:16:57 appldev ship $ */

procedure get_currency_code(book varchar2) is
BEGIN

 NULL;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
	NULL;
  WHEN OTHERS THEN
        RAISE_ORA_ERR('20050');
END;

procedure raise_ora_err(errno in varchar2) is
ERRMSG VARCHAR2(1000);
BEGIN
  ERRMSG := SQLERRM;
  /*SRW.MESSAGE(ERRNO,ERRMSG);*/null;

  RAISE_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;

END;

function AfterReport return boolean is
begin

  delete from fa_maint_rep_itf
  where request_id = C_request_id;

  /*srw.user_exit('FND SRWEXIT');*/null;

  return (TRUE);
end;

function RP_COMPANY_NAMEFormula return VARCHAR2 is
  l_company_name	VARCHAR2(30);
begin
  SELECT SC.Company_Name INTO l_company_name
  FROM FA_SYSTEM_CONTROLS SC;
  RETURN (l_company_name);
RETURN NULL; EXCEPTION
  WHEN NO_DATA_FOUND THEN
     RETURN (' ');
end;

function BeforeReport return boolean is
begin
P_CONC_REQUEST_ID := fnd_global.CONC_REQUEST_ID;

  /*SRW.USER_EXIT('FND SRWINIT');*/null;
  declare
    l_currency_code varchar2(15);
    l_precision	    number(15);

  begin
    select sob.currency_code,
           cur.precision
    into l_currency_code,
     	 l_precision
    from fa_book_controls bc,
         gl_sets_of_books sob,
         fnd_currencies cur
    where bc.book_type_code = P_BOOK
    and   sob.set_of_books_id = bc.set_of_books_id
    and   cur.currency_code = sob.currency_code;

    C_Currency_Code := l_currency_code;
    P_Min_Precision   := l_precision;

    return (TRUE);
  end;

RETURN NULL; end;

--Functions to refer Oracle report placeholders--

 Function C_currency_code_p return varchar2 is
	Begin
	 return C_currency_code;
	 END;
 Function C_request_id_p return number is
	Begin
	 return C_request_id;
	 END;


	 --added by

	 function Do_InsertFormula return number is
   h_retcode  number;

begin

	FARX_C_MT.do_insert(P_BOOK,
			    P_event_name,
			    P_maint_date_from,
			    P_maint_date_to,
			    P_asset_number_from,
			    P_asset_number_to,
			    P_dpis_from,
			    P_dpis_to,
			    P_Category_id,
			    P_CONC_REQUEST_ID,
			     h_retcode);

   c_request_id := P_CONC_REQUEST_ID;
    return(c_request_id);

end;
END FA_FASMAINT_XMLP_PKG ;


/
