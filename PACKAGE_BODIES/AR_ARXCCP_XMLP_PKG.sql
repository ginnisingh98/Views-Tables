--------------------------------------------------------
--  DDL for Package Body AR_ARXCCP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_ARXCCP_XMLP_PKG" AS
/* $Header: ARXCCPB.pls 120.0 2007/12/27 13:38:01 abraghun noship $ */

function NLS_YES1Formula return VARCHAR2 is
begin

    	 EXECUTE IMMEDIATE 'SELECT meaning
				            FROM ar_lookups
				            WHERE lookup_type = ''YES/NO''
				            AND lookup_code = ''Y'''
				            INTO NLS_YES ;

/*SRW.DO_SQL('SELECT meaning
            INTO :NLS_YES
            FROM ar_lookups
            WHERE lookup_type = ''YES/NO''
            AND lookup_code = ''Y''');*/null;


COMMIT;

RETURN('');

end;

function NLS_YESFormula return VARCHAR2 is
begin

/*SRW.REFERENCE(NLS_YES1);*/null;


RETURN NULL; end;

function NLS_NO1Formula return VARCHAR2 is
begin

	 EXECUTE IMMEDIATE 'SELECT meaning
			            FROM ar_lookups
			            WHERE lookup_type = ''YES/NO''
			            AND lookup_code = ''N'''
			            INTO nls_no ;

/*SRW.DO_SQL('SELECT meaning
            INTO :nls_no
            FROM ar_lookups
            WHERE lookup_type = ''YES/NO''
            AND lookup_code = ''N''');*/null;


COMMIT;

RETURN('');

end;

function NLS_NOFormula return VARCHAR2 is
begin

/*SRW.REFERENCE(NLS_NO1);*/null;


RETURN NULL; end;

function BeforeReport return boolean is
begin
   	P_CONC_REQUEST_ID:=FND_GLOBAL.conc_request_id;
     /*srw.message ('100', 'BeforeReport Trigger.... +');*/null;


     /*srw.user_exit('FND SRWINIT');*/null;


     Set_Sort_Order;

     /*srw.message ('100', 'BeforeReport Trigger -');*/null;


     return (TRUE);
end;

function AfterReport return boolean is
begin

/*srw.user_exit('FND SRWEXIT');*/null;
  return (TRUE);
end;

function Report_NameFormula return VARCHAR2 is
begin

DECLARE
    l_report_name  VARCHAR2(240);
BEGIN
    SELECT substrb(cp.user_concurrent_program_name,1,80)
    INTO   l_report_name
    FROM   FND_CONCURRENT_PROGRAMS_VL cp,
           FND_CONCURRENT_REQUESTS cr
    WHERE
      cp.application_id = cr.program_application_id
    AND  cr.request_id = p_conc_request_id
    AND  cp.concurrent_program_id = cr.concurrent_program_id;

    RP_Report_name := l_report_name;

    RETURN(l_report_name);
EXCEPTION
    WHEN NO_DATA_FOUND
    THEN RP_REPORT_NAME := 'Customer Profiles Report';
         RETURN('Customer Profiles Report');
END;



RETURN NULL; end;

--Functions to refer Oracle report placeholders--

 Function NLS_YES_p return varchar2 is
	Begin
	 return NLS_YES;
	 END;
 Function NLS_NO_p return varchar2 is
	Begin
	 return NLS_NO;
	 END;
 Function RP_REPORT_NAME_p return varchar2 is
	Begin
	 return RP_REPORT_NAME;
	 END;
	PROCEDURE Set_Sort_Order IS
     BEGIN

       --   srw.message ('100', 'BeforeReport_Procs.Set_Sort_Order');

      --    srw.reference(:SORT_BY_PHONETICS);

     /*     srw.user_exit('FND GETPROFILE
                         NAME="RA_CUSTOMERS_SORT_BY_PHONETICS"
	                 FIELD="SORT_BY_PHONETICS"
                         PRINT_ERROR="N"');
*/
          if SORT_BY_PHONETICS = 'Y' then
	     P_SORT1 := 'party.organization_name_phonetic';
	     P_SORT2 := 'null';
          else
	     P_SORT1 := 'cust.account_number';
	     P_SORT2 := 'cust.cust_account_id';
          end if;

     EXCEPTION
          WHEN OTHERS THEN
               SORT_BY_PHONETICS := 'N';
	       P_SORT1 := 'cust.account_number';
	       P_SORT2 := 'cust.cust_account_id';
     END;
END AR_ARXCCP_XMLP_PKG ;


/
