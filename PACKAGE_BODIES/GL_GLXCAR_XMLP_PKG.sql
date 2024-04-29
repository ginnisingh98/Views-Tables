--------------------------------------------------------
--  DDL for Package Body GL_GLXCAR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_GLXCAR_XMLP_PKG" AS
/* $Header: GLXCARB.pls 120.0 2007/12/27 14:48:49 vijranga noship $ */

function BeforeReport return boolean is
begin

/*srw.user_exit('FND SRWINIT');*/null;


declare
  to_ledgerid    NUMBER;
  from_ledgerid  NUMBER;
  coaid          NUMBER;
  tmpname        VARCHAR2(100);
  functcurr      VARCHAR2(15);
  errbuf         VARCHAR2(132);
  errbuf2        VARCHAR2(132);
  method         VARCHAR2(1);
  description    VARCHAR2(240);
CURSOR t_cursorLedgerName IS
  SELECT glr.target_ledger_name
  FROM gl_ledger_relationships glr, gl_consolidation gcs, gl_ledgers gll
  WHERE gll.ledger_id = decode(gcs.from_currency_code,
         'STAT', gcs.from_ledger_id, gll.ledger_id)
  AND glr.target_currency_code = decode(gcs.from_currency_code,
        'STAT', gll.currency_code, gcs.from_currency_code)
  AND glr.source_ledger_id = gcs.from_ledger_id
  AND glr.target_ledger_id = gcs.from_ledger_id
  AND gcs.consolidation_id = P_CONSOLIDATION_ID;

begin

    gl_get_consolidation_info(
                            P_CONSOLIDATION_ID, tmpname,
                            method, functcurr, from_ledgerid,
                            to_ledgerid, description,
                            errbuf);

  if (errbuf is not null) then


    errbuf2 := gl_message.get_message(
                 'GL_PLL_ROUTINE_ERROR', 'N',
                 'ROUTINE','gl_get_consolidation_info'
               );
    /*srw.message('00', errbuf2);*/null;


    /*srw.message('00', errbuf);*/null;


    raise_application_error(-20101,null);/*srw.program_abort;*/null;

  end if;

  TO_LEDGER_ID := to_ledgerid;
  FROM_LEDGER_ID := from_ledgerid;
  CONSOLIDATION_NAME := tmpname;
  CURRENCY_CODE := functcurr;



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


    open t_cursorLedgerName;
  fetch t_cursorLedgerName into FROM_LEDGER_NAME;
  if t_cursorLedgerName%NOTFOUND then
     errbuf := gl_message.get_message('GL_PLL_INVALID_CONSOLID_ID', 'Y',
                                   'CID', to_char(P_CONSOLIDATION_ID));
     /*SRW.MESSAGE(0, errbuf);*/null;

     RAISE_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;

  end if;
  close t_cursorLedgerName;

    gl_info.gl_get_ledger_info(FROM_LEDGER_ID,
                                   coaid, tmpname, functcurr,
                                   errbuf);

  if (errbuf is not null) then


    errbuf2 := gl_message.get_message(
                 'GL_PLL_ROUTINE_ERROR', 'N',
                 'ROUTINE','gl_ledger_info'
              );
    /*srw.message('00', errbuf2);*/null;


    /*srw.message('00', errbuf);*/null;


    raise_application_error(-20101,null);/*srw.program_abort;*/null;

  end if;

  FROM_CHART_OF_ACCOUNTS_ID := coaid;
  FROM_CURRENCY_CODE := functcurr;


  if (functcurr = CURRENCY_CODE) then
    WHERE_DR_CR_NOT_ZERO
       := '(   (nvl(ca.entered_dr,0) <> 0)
            OR (nvl(ca.entered_cr,0) <> 0))';
  else
    WHERE_DR_CR_NOT_ZERO
       := '(  nvl(ca.entered_dr,0)
            - nvl(ca.entered_cr,0) <> 0)';
  end if;
end;

   if (P_BALANCE_TYPE = 'A') then
      WHERE_BALANCE := 'ca.actual_flag = ''A''';
   elsif (P_BALANCE_TYPE = 'B') then
      WHERE_BALANCE := 'ca.actual_flag = ''B''';
   else
      WHERE_BALANCE := 'ca.actual_flag in (''A'', ''B'')';
   end if;


/*srw.reference(FROM_CHART_OF_ACCOUNTS_ID);*/null;


 null;


 null;

/*srw.reference(TO_CHART_OF_ACCOUNTS_ID);*/null;


 null;


 null;
  return (TRUE);
end;

function SUBTITLE1Formula return VARCHAR2 is
begin

 return(gl_message.get_message(
                 'GL_PLL_PERIOD_CURR', 'N',
                 'PERIOD', P_PERIOD_NAME
                 ));

end;

function AfterReport return boolean is
begin

/*srw.user_exit('FND SRWEXIT');*/null;
  return (TRUE);
end;

procedure gl_get_consolidation_info(
                           cons_id number, cons_name out NOCOPY varchar2,
                           method out NOCOPY varchar2, curr_code out NOCOPY varchar2,
                           from_ledgerid out NOCOPY number, to_ledgerid out NOCOPY number,
                           description out NOCOPY varchar2,
                           errbuf out NOCOPY varchar2) is
  begin
    select glc.name, glc.method, glc.from_currency_code,
           glc.from_ledger_id, glc.to_ledger_id,
           glc.description
    into cons_name, method, curr_code, from_ledgerid, to_ledgerid,
         description
    from gl_consolidation glc
    where glc.consolidation_id = cons_id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      errbuf := gl_message.get_message('GL_PLL_INVALID_CONSOLID_ID', 'Y',
                                   'CID', to_char(cons_id));
  end;

function USAGE_DISPLAYFormula return VARCHAR2 is
begin

DECLARE
 errorbuffer VARCHAR2(2000);
 meaning     VARCHAR2(80);

BEGIN
  gl_info.gl_get_lookup_value('M',
                      P_USAGE,
                      'CONSOLIDATION_USAGE',
                      meaning,
                      errorbuffer);
  if (errorbuffer is not NULL) then
     /*SRW.MESSAGE(0,errorbuffer);*/null;

     raise_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;

  else
     return(meaning);
  end if;
END;
RETURN NULL; end;

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
 Function TO_LEDGER_ID_p return number is
	Begin
	 return TO_LEDGER_ID;
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
 Function WHERE_DR_CR_NOT_ZERO_p return varchar2 is
	Begin
	 return WHERE_DR_CR_NOT_ZERO;
	 END;
 Function FROM_CURRENCY_CODE_p return varchar2 is
	Begin
	 return FROM_CURRENCY_CODE;
	 END;
 Function WHERE_BALANCE_p return varchar2 is
	Begin
	 return WHERE_BALANCE;
	 END;
END GL_GLXCAR_XMLP_PKG ;


/
