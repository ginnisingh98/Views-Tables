--------------------------------------------------------
--  DDL for Package Body GL_GLXRLACH_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_GLXRLACH_XMLP_PKG" AS
/* $Header: GLXRLACHB.pls 120.0 2007/12/27 15:09:32 vijranga noship $ */
function BeforeReport return boolean is
begin

  /*srw.user_exit('FND SRWINIT');*/null;



  declare
    ledname     VARCHAR2(30);
    coaid       NUMBER;
    func_curr   VARCHAR2(15);
    errbuf      VARCHAR2(132);
    errbuf2     VARCHAR2(132);
  begin
   gl_info.gl_get_ledger_info(P_LEDGER_ID,
                       coaid, ledname, func_curr, errbuf);

    if (errbuf is not null) then

      errbuf2 := gl_message.get_message(
                   'GL_PLL_ROUTINE_ERROR', 'N',
                   'ROUTINE','gl_get_ledger_info'
                 );
      /*srw.message('00', errbuf2);*/null;

      /*srw.message('00', errbuf);*/null;

      raise_application_error(-20101,null);/*srw.program_abort;*/null;

    end if;

    STRUCT_NUM:= coaid;
    LEDGER_NAME := ledname;
  end;

  /*SRW.REFERENCE(STRUCT_NUM);*/null;



 null;


 null;


 null;


 null;


  IF (P_TEMPLATE_ID IS NOT NULL) THEN
    WHERE_TEMPLATE := 'and st.template_id = ' || to_char(P_TEMPLATE_ID);
  END IF;
IF (WHERE_TEMPLATE IS NULL) THEN
	WHERE_TEMPLATE := ' ';
END IF;

    WHERE_DAS := GL_ACCESS_SET_SECURITY_PKG.GET_SECURITY_CLAUSE(
                  P_ACCESS_SET_ID,
                  'R',
                  'LEDGER_ID',
                  P_LEDGER_ID,
                  null,
                  'SEG_COLUMN',
                  null,
                  'cs1',
                  null);

  IF (WHERE_DAS is not null) THEN
    WHERE_DAS := ' AND ' || WHERE_DAS;
  END IF;
IF (WHERE_DAS IS NULL) THEN
	WHERE_DAS := ' ';
END IF;

  return (TRUE);
end;

function AfterReport return boolean is
begin
  /*srw.user_exit('FND SRWEXIT');*/null;

  return (TRUE);
end;

function new_descformula(C_DESC_ACCT_DET in varchar2) return varchar2 is
begin
  if (C_DESC_ACCT_DET <> OLD_DESC) or
     (OLD_DESC is null) then
    OLD_DESC := C_DESC_ACCT_DET;
    return('Y');
  else
    return('N');
  end if;

  RETURN NULL;
end;

--Functions to refer Oracle report placeholders--

 Function OLD_DESC_p return varchar2 is
	Begin
	 return OLD_DESC;
	 END;
 Function LEDGER_NAME_p return varchar2 is
	Begin
	 return LEDGER_NAME;
	 END;
 Function P_FLEXDATA_SUM_p return varchar2 is
	Begin
	 return P_FLEXDATA_SUM;
	 END;
 Function P_FLEXDATA_DET_p return varchar2 is
	Begin
	 return P_FLEXDATA_DET;
	 END;
 Function P_ORDER_BY_SUM_p return varchar2 is
	Begin
	 return P_ORDER_BY_SUM;
	 END;
 Function P_ORDER_BY_DET_p return varchar2 is
	Begin
	 return P_ORDER_BY_DET;
	 END;
 Function STRUCT_NUM_p return number is
	Begin
	 return STRUCT_NUM;
	 END;
 Function WHERE_DAS_p return varchar2 is
	Begin
	 return WHERE_DAS;
	 END;
 Function WHERE_TEMPLATE_p return varchar2 is
	Begin
	 return WHERE_TEMPLATE;
	 END;
END GL_GLXRLACH_XMLP_PKG ;


/
