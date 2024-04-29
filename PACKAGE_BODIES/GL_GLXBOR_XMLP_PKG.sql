--------------------------------------------------------
--  DDL for Package Body GL_GLXBOR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_GLXBOR_XMLP_PKG" AS
/* $Header: GLXBORB.pls 120.2 2008/01/02 06:05:29 npannamp noship $ */

function flexfield_lowformula(FLEXDATA_LOW in varchar2) return varchar2 is
FLEXFIELD_LOW varchar2(1000);
begin

/*srw.reference(STRUCT_NUM);*/null;

/*srw.reference(FLEXDATA_LOW);*/null;

/*srw.user_exit('FND FLEXRIDVAL CODE="GL#"
               NUM=":STRUCT_NUM"
               APPL_SHORT_NAME="SQLGL"
               DATA=":FLEXDATA_LOW"
               VALUE=":FLEXFIELD_LOW"');*/null;
FLEXFIELD_LOW := replace(FLEXDATA_LOW,'\n',C_DELIMITER);

RETURN(FLEXFIELD_LOW);

end;

FUNCTION gl_get_all_org_id RETURN NUMBER IS
  all_bud_ent_id          NUMBER;
begin
  select be.budget_entity_id
  into   all_bud_ent_id
  from   gl_lookups l, gl_budget_entities be
  where  l.lookup_type = 'LITERAL'
  and    l.lookup_code = 'ALL'
  and    upper(be.name) = upper(l.meaning)
  and    be.ledger_id = P_LEDGER_ID;

  return(all_bud_ent_id);

RETURN NULL; EXCEPTION
  when NO_DATA_FOUND then
    return -1;
end;

function AfterReport return boolean is
begin

/*srw.user_exit('FND SRWEXIT');*/null;
  return (TRUE);
end;

function flexfield_highformula(FLEXDATA_HIGH in varchar2) return varchar2 is
FLEXFIELD_HIGH varchar2(1000);
begin

/*srw.reference(STRUCT_NUM);*/null;

/*srw.reference(FLEXDATA_HIGH);*/null;

/*srw.user_exit('FND FLEXRIDVAL CODE="GL#"
               NUM=":STRUCT_NUM"
               APPL_SHORT_NAME="SQLGL"
               DATA=":FLEXDATA_HIGH"
               VALUE=":FLEXFIELD_HIGH"');*/null;
FLEXFIELD_HIGH := replace(FLEXDATA_HIGH,'\n',C_DELIMITER);
RETURN(FLEXFIELD_HIGH);
end;

function BeforeReport return boolean is
errbuf         VARCHAR2(132);
  errbuf2        VARCHAR2(132);
begin

  /*srw.user_exit('FND SRWINIT');*/null;


  declare
    coaid          NUMBER;
    ledgername     VARCHAR2(30);
    functcurr      VARCHAR2(15);
  begin

        gl_info.gl_get_ledger_info(P_LEDGER_ID,
                               coaid, ledgername, functcurr,
                               errbuf);

    if (errbuf is not null) then

      errbuf2 := gl_message.get_message(
                   'GL_PLL_ROUTINE_ERROR', 'N',
                   'ROUTINE','gl_get_ledger_info');
      /*srw.message('00', errbuf2);*/null;

      /*srw.message('00', errbuf);*/null;

      raise_application_error(-20101,null);/*srw.program_abort;*/null;

    end if;

    STRUCT_NUM  := coaid;
    LEDGER_NAME := ledgername;
  end;

  P_BUDGET_ENTITY_ID1 := P_BUDGET_ENTITY_ID ;
  if (gl_get_all_org_id = P_BUDGET_ENTITY_ID1) then
--    P_BUDGET_ENTITY_ID := -1;
    P_BUDGET_ENTITY_ID1 := -1;
  end if;

  /*srw.reference(STRUCT_NUM);*/null;

  /*srw.user_exit('FND FLEXRSQL CODE="GL#" NUM=":STRUCT_NUM"
                APPL_SHORT_NAME="SQLGL"
                OUTPUT=":SELECT_FLEX" TABLEALIAS="BAR"');*/null;
select FND_FLEX_APIS.gbl_get_segment_delimiter(101,'GL#',STRUCT_NUM) into C_DELIMITER from dual;
  begin
    SELECT name
    INTO   DAS_NAME
    FROM   gl_access_sets
    WHERE  access_set_id = P_DAS_ID;

  exception
    WHEN NO_DATA_FOUND THEN
      errbuf := gl_message.get_message('GL_PLL_INVALID_DATA_ACCESS_SET', 'Y',
                              'DASID', to_char(P_DAS_ID));
      /*srw.message('00', errbuf);*/null;

      raise_application_error(-20101,null);/*srw.program_abort;*/null;


    WHEN OTHERS THEN
      errbuf := SQLERRM;
      /*srw.message('00', errbuf);*/null;

      raise_application_error(-20101,null);/*srw.program_abort;*/null;

  end;

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function STRUCT_NUM_p return varchar2 is
	Begin
	 return STRUCT_NUM;
	 END;
 Function LEDGER_NAME_p return varchar2 is
	Begin
	 return LEDGER_NAME;
	 END;
 Function SELECT_FLEX_LOW_p return varchar2 is
	Begin
	 return SELECT_FLEX_LOW;
	 END;
 Function SELECT_FLEX_HIGH_p return varchar2 is
	Begin
	 return SELECT_FLEX_HIGH;
	 END;
 Function DAS_NAME_p return varchar2 is
	Begin
	 return DAS_NAME;
	 END;
END GL_GLXBOR_XMLP_PKG ;



/
