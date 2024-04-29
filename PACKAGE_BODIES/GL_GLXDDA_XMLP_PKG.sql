--------------------------------------------------------
--  DDL for Package Body GL_GLXDDA_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_GLXDDA_XMLP_PKG" AS
/* $Header: GLXDDAB.pls 120.0 2007/12/27 14:54:00 vijranga noship $ */

function AfterReport return boolean is
begin

/*SRW.USER_EXIT('FND SRWEXIT');*/null;
  return (TRUE);
end;

function BeforeReport return boolean is
begin

/*SRW.USER_EXIT('FND SRWINIT');*/null;


DECLARE
 t_ledger_id                          NUMBER;
 t_ledger_name                        VARCHAR2(30);
 t_chart_of_accounts_id               NUMBER;
 t_base_currency                      VARCHAR2(15);
 t_to_ledger_name                     VARCHAR2(30);
 t_to_ledger_id                       NUMBER;
 t_to_chart_of_accounts_id            NUMBER;
 t_to_base_currency                   VARCHAR2(15);
 t_from_ledger_name                   VARCHAR2(30);
 t_from_ledger_id                     NUMBER;
 t_from_chart_of_accounts_id          NUMBER;
 t_from_base_currency                 VARCHAR2(15);
 t_consolidation_id                   NUMBER;
 t_consolidation_name                 VARCHAR2(33);
 t_consolidation_method               VARCHAR2(30);
 t_consolidation_currency_code        VARCHAR2(15);
 t_consolidation_description          VARCHAR2(240);
 t_error_buffer                       VARCHAR2(400);

CURSOR t_cursorLedgerName IS
  SELECT glr.target_ledger_name
  FROM gl_ledger_relationships glr, gl_consolidation gcs
  WHERE glr.target_currency_code = gcs.from_currency_code
  AND glr.source_ledger_id = gcs.from_ledger_id
  AND glr.target_ledger_id = gcs.from_ledger_id
  AND gcs.consolidation_id = P_CONSOLIDATION_ID;

BEGIN

 t_consolidation_id := to_number(P_CONSOLIDATION_ID);
 gl_get_consolidation_info(t_consolidation_id,
                           t_consolidation_name,
                           t_consolidation_method,
                           t_consolidation_currency_code,
                           t_from_ledger_id,
                           t_to_ledger_id,
                           t_consolidation_description,
                           t_error_buffer);

 if (t_error_buffer is not NULL) then
    /*SRW.MESSAGE(0, t_error_buffer);*/null;

    RAISE_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;

 else
    ConsolidationName := t_consolidation_name;
 end if;

 gl_info.gl_get_ledger_info(t_to_ledger_id,
                          t_to_chart_of_accounts_id,
                          t_to_ledger_name,
                          t_to_base_currency,
                          t_error_buffer);

 if (t_error_buffer is not NULL) then
    /*SRW.MESSAGE(0, t_error_buffer);*/null;

    RAISE_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;

 else
    STRUCT_NUM           := to_char(t_to_chart_of_accounts_id);
    To_Ledger_Name       := t_to_ledger_name;
 end if;

open t_cursorLedgerName;
fetch t_cursorLedgerName into FROM_LEDGER_NAME;
if t_cursorLedgerName%NOTFOUND then
  t_error_buffer := gl_message.get_message('GL_PLL_INVALID_CONSOLID_ID', 'Y',
                                   'CID', to_char(t_consolidation_id));
  /*SRW.MESSAGE(0, t_error_buffer);*/null;

  RAISE_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;

end if;
close t_cursorLedgerName;


gl_info.gl_get_ledger_info(t_from_ledger_id,
                          t_from_chart_of_accounts_id,
                          t_from_ledger_name,
                          t_from_base_currency,
                          t_error_buffer);

 if (t_error_buffer is not NULL) then
    /*SRW.MESSAGE(0, t_error_buffer);*/null;

    RAISE_application_error(-20101,null);/*SRW.PROGRAM_ABORT;*/null;

 end if;


 if (t_from_base_currency = t_consolidation_currency_code) then
   WHERE_DR_CR_NOT_ZERO
      := '(   (nvl(glca.entered_dr,0) <> 0)
           OR (nvl(glca.entered_cr,0) <> 0))';
 else
   WHERE_DR_CR_NOT_ZERO
      := '(  nvl(glca.entered_dr,0)
           - nvl(glca.entered_cr,0) <> 0)';
 end if;

 LEDGER_NAME := t_to_ledger_name;

END;

/*SRW.REFERENCE(STRUCT_NUM);*/null;


 null;
/*SRW.REFERENCE(STRUCT_NUM);*/null;


 null;  return (TRUE);
end;

procedure gl_get_consolidation_info(
                           cons_id number, cons_name out NOCOPY varchar2,
                           method out NOCOPY varchar2, curr_code out NOCOPY varchar2,
                           from_ledid out NOCOPY number, to_ledid out NOCOPY number,
                           description out NOCOPY varchar2, errbuf out NOCOPY varchar2) is
  begin
    select glc.name, glc.method, glc.from_currency_code,
           glc.from_ledger_id, glc.to_ledger_id,
           glc.description
    into cons_name, method, curr_code, from_ledid, to_ledid,
         description
    from gl_consolidation glc
    where glc.consolidation_id = cons_id;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      errbuf := gl_message.get_message('GL_PLL_INVALID_CONSOLID_ID', 'Y',
                                   'CID', to_char(cons_id));
  end;

--Functions to refer Oracle report placeholders--

 Function STRUCT_NUM_p return varchar2 is
	Begin
	 return STRUCT_NUM;
	 END;
 Function Ledger_Name_p return varchar2 is
	Begin
	 return Ledger_Name;
	 END;
 Function To_Ledger_Name_p return varchar2 is
	Begin
	 return To_Ledger_Name;
	 END;
 Function From_Ledger_Name_p return varchar2 is
	Begin
	 return From_Ledger_Name;
	 END;
 Function ConsolidationName_p return varchar2 is
	Begin
	 return ConsolidationName;
	 END;
 Function WHERE_DR_CR_NOT_ZERO_p return varchar2 is
	Begin
	 return WHERE_DR_CR_NOT_ZERO;
	 END;
END GL_GLXDDA_XMLP_PKG ;



/
