--------------------------------------------------------
--  DDL for Package Body GL_GLCRDR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_GLCRDR_XMLP_PKG" AS
/* $Header: GLCRDRB.pls 120.0 2007/12/27 14:21:57 vijranga noship $ */

procedure gl_consolidation_name(cons_id number, cons_name out NOCOPY varchar2,
                                curr_code out NOCOPY varchar2,
                                errbuf out NOCOPY varchar2) is
begin
  select name, from_currency_code
  into   cons_name, curr_code
  from gl_consolidation
  where consolidation_id = cons_id;

EXCEPTION
  when NO_DATA_FOUND then
    errbuf := gl_message.get_message(
                 'GL_PLL_INVALID_CONSOLID_ID', 'Y',
                 'CID', to_char(cons_id));
end;

procedure gl_get_batch_info(batch_id number, batch_name out NOCOPY varchar2,
                            to_ledid out NOCOPY number, to_period out NOCOPY varchar2,
                            from_ledid out NOCOPY number, cons_id out NOCOPY number,
                            errbuf out NOCOPY varchar2) is
  header_id          NUMBER;
  ccid               NUMBER;
  s_consolidation_id VARCHAR2(25) default null;
  s_header_id        VARCHAR2(25) default null;
  s_ccid             VARCHAR2(50) default null;

begin



  begin
      select jeb.name, jeb.default_period_name
      into batch_name, to_period
      from gl_je_batches jeb,
           gl_je_headers jeh,
           gl_je_lines    jel
      where jeb.je_batch_id = batch_id
      and  jeh.je_batch_id = jeb.je_batch_id
      and  (jeh.display_alc_journal_flag is null or jeh.display_alc_journal_flag = 'Y')
      and  jel.je_header_id = jeh.je_header_id
      and  rownum < 2;

      EXCEPTION
        when NO_DATA_FOUND then
          errbuf := gl_message.get_message(
                    'GL_PLL_INVALID_BATCH_ID', 'Y',
                    'BID', to_char(batch_id)
                    );
          return;
  end;


  begin

      select jir.reference_3, jir.reference_1, jir.reference_4
      into  s_header_id, s_consolidation_id, s_ccid
      from gl_import_references jir, gl_je_headers jeh
      where jeh.je_batch_id = batch_id
      and   jir.je_header_id = jeh.je_header_id
      and   rownum < 2;

      EXCEPTION
        when NO_DATA_FOUND then
          errbuf := gl_message.get_message(
                    'GL_PLL_INVALID_BATCH_ID', 'Y',
                    'BID', to_char(batch_id)
                    );
          return;
      end;

      cons_id := to_number(s_consolidation_id);
      header_id := to_number(s_header_id);
      ccid := to_number(s_ccid);
  begin
      select jeh.ledger_id
      into  from_ledid
      from  gl_je_headers jeh
      where jeh.je_header_id = header_id;

      EXCEPTION
        when NO_DATA_FOUND OR INVALID_NUMBER OR VALUE_ERROR then
          errbuf := gl_message.get_message(
                     'GL_PLL_INVALID_CONS_BATCH', 'Y'
                     );
          return;
  end;


  begin
      select gca.to_ledger_id
      into to_ledid
      from gl_consolidation gca
      where  gca.consolidation_id = cons_id ;

      EXCEPTION
        when NO_DATA_FOUND OR INVALID_NUMBER OR VALUE_ERROR then
          errbuf := gl_message.get_message(
                     'GL_PLL_INVALID_CONS_BATCH', 'Y'
                     );
          return;

  end;

EXCEPTION
  when NO_DATA_FOUND OR INVALID_NUMBER OR VALUE_ERROR then
    errbuf := gl_message.get_message(
                 'GL_PLL_INVALID_CONS_BATCH', 'Y'
              );
end;

function AfterReport return boolean is
begin

/*srw.user_exit('FND SRWEXIT');*/null;
  return (TRUE);
end;

function BeforeReport return boolean is
begin

/*srw.user_exit('FND SRWINIT');*/null;


declare
  to_ledid       NUMBER;
  --to_batch_name  VARCHAR2(100);
  to_batch_name_1  VARCHAR2(100);
 -- to_period      VARCHAR2(15);
   to_period_1     VARCHAR2(15);
  from_ledid     NUMBER;
  cons_id        NUMBER;
  coaid          NUMBER;
  tmpname        VARCHAR2(100);
  functcurr      VARCHAR2(15);
  errbuf         VARCHAR2(132);
  errbuf2        VARCHAR2(132);


begin

begin
  SELECT name
  INTO   DAS_NAME
  FROM   gl_access_sets
  WHERE  access_set_id = P_ACCESS_SET_ID;

exception
  WHEN NO_DATA_FOUND THEN
    errbuf := gl_message.get_message('GL_PLL_INVALID_DATA_ACCESS_SET', 'Y',
                                     'DASID', to_char(P_ACCESS_SET_ID));
    /*srw.message('00', errbuf);*/null;

    raise_application_error(-20101,null);/*srw.program_abort;*/null;


  WHEN OTHERS THEN
    errbuf := SQLERRM;
    /*srw.message('00', errbuf);*/null;

    raise_application_error(-20101,null);/*srw.program_abort;*/null;

end;

WHERE_DAS_CLAUSE := gl_access_set_security_pkg.get_security_clause(
			P_ACCESS_SET_ID,
			'R',
			'LEDGER_COLUMN',
			'LEDGER_ID',
			'to_jel',
			'SEG_COLUMN',
			null,
			'to_cc',
			null);
IF (WHERE_DAS_CLAUSE IS NOT NULL) THEN
  WHERE_DAS_CLAUSE := ' AND ' || WHERE_DAS_CLAUSE;
END IF;


   /* gl_get_batch_info(P_TO_BATCH_ID, to_batch_name,
                    to_ledid, to_period,
                    from_ledid, cons_id, errbuf);*/

		      gl_get_batch_info(P_TO_BATCH_ID, to_batch_name_1,
                    to_ledid, to_period_1,
                    from_ledid, cons_id, errbuf);


  if (errbuf is not null) then


    errbuf2 := gl_message.get_message(
                 'GL_PLL_ROUTINE_ERROR', 'N',
                 'ROUTINE','gl_get_batch_info'
               );
    /*srw.message('00', errbuf2);*/null;


    /*srw.message('00', errbuf);*/null;


    raise_application_error(-20101,null);/*srw.program_abort;*/null;

  end if;

 -- TO_BATCH_NAME := to_batch_name;
  TO_BATCH_NAME := to_batch_name_1;
  TO_LEDGER_ID := to_ledid;
  FROM_LEDGER_ID := from_ledid;
  --TO_PERIOD := to_period;
  TO_PERIOD := to_period_1;



    gl_info.gl_get_ledger_info(TO_LEDGER_ID,
                                 coaid, tmpname, functcurr,
                                   errbuf);

  if (errbuf is not null) then


    errbuf2 := gl_message.get_message(
                 'GL_PLL_ROUTINE_ERROR', 'N',
                 'ROUTINE','gl_get_ledger_info'
              );
    /*srw.message('00', errbuf2);*/null;


    /*srw.message('00', errbuf);*/null;


    raise_application_error(-20101,null);/*srw.program_abort;*/null;

  end if;

  TO_CHART_OF_ACCOUNTS_ID := coaid;
  TO_LEDGER_NAME := tmpname;

    begin
  SELECT glr.target_ledger_name
  INTO FROM_LEDGER_NAME
  FROM gl_ledger_relationships glr, gl_consolidation gcs
  WHERE glr.target_currency_code = gcs.from_currency_code
  AND glr.source_ledger_id = gcs.from_ledger_id
  AND glr.target_ledger_id = gcs.from_ledger_id
  AND gcs.consolidation_id = cons_id;
  exception
    when NO_DATA_FOUND then
    errbuf2 := SQLERRM;
    /*srw.message('00', errbuf2);*/null;

    /*srw.message('00', errbuf);*/null;

    raise_application_error(-20101,null);/*srw.program_abort;*/null;

  end;

    gl_info.gl_get_ledger_info(FROM_LEDGER_ID,
                                   coaid, tmpname, functcurr,
                                   errbuf);

  if (errbuf is not null) then


    errbuf2 := gl_message.get_message(
                 'GL_PLL_ROUTINE_ERROR', 'N',
                 'ROUTINE','gl_get_ledger_info'
              );
    /*srw.message('00', errbuf2);*/null;


    /*srw.message('00', errbuf);*/null;


    raise_application_error(-20101,null);/*srw.program_abort;*/null;

  end if;

  FROM_CHART_OF_ACCOUNTS_ID := coaid;


    gl_consolidation_name(cons_id, tmpname, functcurr, errbuf);

  if (errbuf is not null) then


    errbuf2 := gl_message.get_message(
                     'GL_PLL_ROUTINE_ERROR', 'N',
                     'ROUTINE', 'gl_consolidation_name');
    /*srw.message('00', errbuf2);*/null;

    /*srw.message('00', errbuf);*/null;

    raise_application_error(-20101,null);/*srw.program_abort;*/null;

  end if;

  CONSOLIDATION_NAME := tmpname;
  CURRENCY_CODE := functcurr;
end;

/*srw.reference(FROM_CHART_OF_ACCOUNTS_ID);*/null;


 null;


 null;

/*srw.reference(TO_CHART_OF_ACCOUNTS_ID);*/null;


 null;


 null;
  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function TO_CHART_OF_ACCOUNTS_ID_p return varchar2 is
	Begin
	 return TO_CHART_OF_ACCOUNTS_ID;
	 END;
 Function TO_LEDGER_NAME_p return varchar2 is
	Begin
	 return TO_LEDGER_NAME;
	 END;
 Function SELECT_TO_FLEX_p return varchar2 is
	Begin
	 return SELECT_TO_FLEX;
	 END;
 Function ORDERBY_FROM_FLEX_p return varchar2 is
	Begin
	 return ORDERBY_FROM_FLEX;
	 END;
 Function SELECT_FROM_FLEX_p return varchar2 is
	Begin
	 return SELECT_FROM_FLEX;
	 END;
 Function ORDERBY_TO_FLEX_p return varchar2 is
	Begin
	 return ORDERBY_TO_FLEX;
	 END;
 Function TO_BATCH_NAME_p return varchar2 is
	Begin
	 return TO_BATCH_NAME;
	 END;
 Function TO_LEDGER_ID_p return number is
	Begin
	 return TO_LEDGER_ID;
	 END;
 Function TO_PERIOD_p return varchar2 is
	Begin
	 return TO_PERIOD;
	 END;
 Function FROM_LEDGER_ID_p return number is
	Begin
	 return FROM_LEDGER_ID;
	 END;
 Function FROM_CHART_OF_ACCOUNTS_ID_p return varchar2 is
	Begin
	 return FROM_CHART_OF_ACCOUNTS_ID;
	 END;
 Function FROM_LEDGER_NAME_p return varchar2 is
	Begin
	 return FROM_LEDGER_NAME;
	 END;
 Function CONSOLIDATION_NAME_p return varchar2 is
	Begin
	 return CONSOLIDATION_NAME;
	 END;
 Function CURRENCY_CODE_p return varchar2 is
	Begin
	 return CURRENCY_CODE;
	 END;
 Function WHERE_DAS_CLAUSE_p return varchar2 is
	Begin
	 return WHERE_DAS_CLAUSE;
	 END;
 Function DAS_NAME_p return varchar2 is
	Begin
	 return DAS_NAME;
	 END;
END GL_GLCRDR_XMLP_PKG ;



/
