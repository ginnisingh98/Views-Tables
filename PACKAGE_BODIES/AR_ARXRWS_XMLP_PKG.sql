--------------------------------------------------------
--  DDL for Package Body AR_ARXRWS_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_ARXRWS_XMLP_PKG" AS
/* $Header: ARXRWSB.pls 120.0 2007/12/27 14:07:26 abraghun noship $ */

function BeforeReport return boolean is
begin

begin
	P_CONC_REQUEST_ID:=FND_GLOBAL.conc_request_id;
/*srw.user_exit('FND SRWINIT');*/null;


SELECT sob.name
INTO   p_company_name
FROM   gl_sets_of_books sob,ar_system_parameters ar
WHERE  sob.set_of_books_id  = ar.set_of_books_id;

p_no_data_found :=
               ARP_STANDARD.FND_MESSAGE('AR_NO_DATA_FOUND');


exception when no_data_found then p_no_data_found := 'No Data Found';

end;  return (TRUE);
end;

function AfterReport return boolean is
begin

/*srw.user_exit('FND SRWEXIT');*/null;
  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

END AR_ARXRWS_XMLP_PKG ;


/
