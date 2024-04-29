--------------------------------------------------------
--  DDL for Package Body PA_PAXARPPR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PAXARPPR_XMLP_PKG" AS
/* $Header: PAXARPPRB.pls 120.0 2008/01/02 11:14:54 krreddy noship $ */

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
 ndf char(80);
 errbuf varchar2(200);
 ret_code  varchar2(5);
BEGIN

/*srw.user_exit('FND SRWINIT');*/null;



/*srw.user_exit('FND GETPROFILE
NAME="PA_DEBUG_MODE"
FIELD=":p_debug_mode"
PRINT_ERROR="N"');*/null;



/*srw.user_exit('FND GETPROFILE
NAME="PA_RULE_BASED_OPTIMIZER"
FIELD=":p_rule_optimizer"
PRINT_ERROR="N"');*/null;












  IF (get_company_name <> TRUE) THEN       RAISE init_failure;
  END IF;

   select meaning into ndf from pa_lookups where
    lookup_code = 'NO_DATA_FOUND' and
    lookup_type = 'MESSAGE';
  c_no_data_found := ndf;


SELECT meaning
INTO c_yes
FROM fnd_lookups
WHERE lookup_type = 'YES_NO'
AND lookup_code = 'Y';

SELECT meaning
INTO c_no
FROM fnd_lookups
WHERE lookup_type = 'YES_NO'
AND lookup_code = 'N';

SELECT decode(p_run_purge, 'Y', c_yes, c_no),
	p_commit_size
INTO c_run_purge, c_commit_size
FROM dual;



 PA_PURGE_ERROR_CODE := 0;
/*srw.message(0,'Before ...');*/null;


IF P_run_purge = 'Y' THEN
	ret_code := '0';
        /*srw.message(0,ret_code);*/null;

        pa_purge.purge(p_purge_batch_id,
                       p_commit_size,
                        ret_code,
                        errbuf);
        /*srw.message(0,ret_code);*/null;


	IF (not to_number(ret_code) = 0) THEN

	/*srw.message(0, errbuf);*/null;


             PA_PURGE_ERROR_CODE := ret_code;
             PA_PURGE_ERROR_BUFF := errbuf;
        END IF;
END IF;


/*srw.message(0,'before select into');*/null;

SELECT bat.batch_name, bat.description, bat.batch_status_code, bat.txn_to_date,
	bat.active_closed_flag, lk.meaning, bat.purged_date
INTO c_batch_name, c_batch_description, c_batch_status, c_through_date,
	c_batch_active_closed, c_batch_status_meaning, c_batch_purged_date
FROM pa_purge_batches bat, pa_lookups lk
WHERE purge_batch_id = p_purge_batch_id
AND lk.lookup_type = 'PURGE_BATCH_STATUS'
AND lk.lookup_code = bat.batch_status_code;
/*srw.message(0,'after select into');*/null;



EXCEPTION
  WHEN  NO_DATA_FOUND THEN
  /*srw.message(0,'in when no data found');*/null;

   select meaning into ndf from pa_lookups where
    lookup_code = 'NO_DATA_FOUND' and
    lookup_type = 'MESSAGE';
  c_no_data_found := ndf;
   c_dummy_data := 1;
  WHEN   OTHERS  THEN
  /*srw.message(0,'in others exception');*/null;

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

function AfterReport return boolean is
begin
  declare
	number_of_messages NUMBER;
	message_buf VARCHAR2(256);
         prog_error exception;
  BEGIN
	  number_of_messages := pa_debug.no_of_debug_messages;

  IF (p_debug_mode = 'Y' AND  number_of_messages > 0 ) THEN
    /*srw.message(1,'Debug Messages:');*/null;


    FOR i IN 1..number_of_messages LOOP

      pa_debug.get_message(i,message_buf);
      /*srw.message(1,message_buf);*/null;


    END LOOP;


  END IF;



IF  PA_PURGE_ERROR_CODE <> '0' then
   /*srw.message(0,' '||PA_PURGE_ERR_CODE.PA_PURGE_ERROR_CODE || '  '||PA_PURGE_ERR_CODE.PA_PURGE_ERROR_BUFF);*/null;

   RAISE_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;

End If;

  END;

/*srw.user_exit('FND SRWEXIT') ;*/null;

  return (TRUE);
end;

function BetweenPage return boolean is
begin

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function C_COMPANY_NAME_HEADER_p return varchar2 is
	Begin
	 return C_COMPANY_NAME_HEADER;
	 END;
 Function C_no_data_found_p return varchar2 is
	Begin
	 return C_no_data_found;
	 END;
 Function C_dummy_data_p return number is
	Begin
	 return C_dummy_data;
	 END;
 Function C_batch_name_p return varchar2 is
	Begin
	 return C_batch_name;
	 END;
 Function C_batch_description_p return varchar2 is
	Begin
	 return C_batch_description;
	 END;
 Function C_batch_status_p return varchar2 is
	Begin
	 return C_batch_status;
	 END;
 Function C_Through_date_p return date is
	Begin
	 return C_Through_date;
	 END;
 Function C_batch_status_meaning_p return varchar2 is
	Begin
	 return C_batch_status_meaning;
	 END;
 Function C_batch_active_closed_p return varchar2 is
	Begin
	 return C_batch_active_closed;
	 END;
 Function C_YES_p return varchar2 is
	Begin
	 return C_YES;
	 END;
 Function C_NO_p return varchar2 is
	Begin
	 return C_NO;
	 END;
 Function C_RUN_PURGE_p return varchar2 is
	Begin
	 return C_RUN_PURGE;
	 END;
 Function C_COMMIT_SIZE_p return number is
	Begin
	 return C_COMMIT_SIZE;
	 END;
 Function C_Batch_Purged_Date_p return varchar2 is
	Begin
	 return to_char(C_Batch_Purged_Date,'DD-MON-YYYY hh24:mm');
	 END;
END PA_PAXARPPR_XMLP_PKG ;


/
