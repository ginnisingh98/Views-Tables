--------------------------------------------------------
--  DDL for Package Body PO_POXREQAC_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_POXREQAC_XMLP_PKG" AS
/* $Header: POXREQACB.pls 120.1 2007/12/25 11:39:47 krreddy noship $ */

USER_EXIT_FAILURE EXCEPTION;

function BeforeReport return boolean is
begin

DECLARE
   l_req_type     po_lookup_codes.displayed_field%type;
BEGIN
  /*SRW.USER_EXIT('FND SRWINIT');*/null;


  IF P_TYPE is NOT NULL THEN

    SELECT displayed_field
    INTO l_req_type
    FROM po_lookup_codes
    WHERE lookup_code = P_TYPE
    AND lookup_type = 'REQUISITION TYPE';

    P_TYPE_DISPLAYED := l_req_type;

  ELSE

    P_TYPE_DISPLAYED := '';

  END IF;
  LP_CREATION_DATE_FROM:=to_char(P_CREATION_DATE_FROM,'DD-MON-YY');
  LP_CREATION_DATE_TO:=to_char(P_CREATION_DATE_TO,'DD-MON-YY');
  RETURN TRUE;

END;

return (TRUE);
end;

function AfterReport return boolean is
begin

/*SRW.USER_EXIT('FND SRWEXIT');*/null;
   return (TRUE);
end;

function round_amount_req(c_amount_req in number, c_currency_precision in number) return number is
begin

  /*srw.reference(c_amount_req);*/null;

  /*srw.reference(c_currency_precision);*/null;


  return(round(c_amount_req, c_currency_precision));
end;

function round_amount_sum_req(c_amount_sum_req in number, c_currency_precision in number) return number is
begin

  /*srw.reference(c_amount_sum_req);*/null;

  /*srw.reference(c_currency_precision);*/null;


  return(round(c_amount_sum_req, c_currency_precision));
end;

function round_amount_report(c_amount_report in number, c_curr_precision in number) return number is
begin

  /*srw.reference(c_amount_report);*/null;

  /*srw.reference(c_curr_precision);*/null;


  return(round(c_amount_report, c_curr_precision));
end;

--Functions to refer Oracle report placeholders--

END PO_POXREQAC_XMLP_PKG ;


/
