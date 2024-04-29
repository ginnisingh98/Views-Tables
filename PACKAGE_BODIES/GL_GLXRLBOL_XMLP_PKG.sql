--------------------------------------------------------
--  DDL for Package Body GL_GLXRLBOL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_GLXRLBOL_XMLP_PKG" AS
/* $Header: GLXRLBOLB.pls 120.0 2007/12/27 15:11:29 vijranga noship $ */

function BeforeReport return boolean is
errbuf  VARCHAR2(132);
  errbuf2 VARCHAR2(132);
  name VARCHAR2(25);
  description VARCHAR2(240);
  pass_reqd VARCHAR2(30);
  start_date date;
  end_date date;
  control_flag VARCHAR2(1);
begin

  /*srw.user_exit('FND SRWINIT');*/null;


P_BUDGET_ENTITY_ID_NEW := P_BUDGET_ENTITY_ID;
  declare
    ledname     VARCHAR2(30);
    coaid       NUMBER;
    func_curr   VARCHAR2(15);
  begin
    gl_info.gl_get_ledger_info(P_LEDGER_ID,
                       coaid, ledname,func_curr, errbuf);

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

  select enable_budgetary_control_flag
  into control_flag
  from gl_ledgers led
  where led.ledger_id = P_LEDGER_ID;

  budgetary_control_flag := control_flag;


/*  if (gl_get_all_org_id = P_BUDGET_ENTITY_ID) then
    P_BUDGET_ENTITY_ID := -1;*/
  if (gl_get_all_org_id = P_BUDGET_ENTITY_ID_NEW) then
    P_BUDGET_ENTITY_ID_NEW := -1;

  else
    SELECT be.name, be.description, lk.meaning, be.start_date, be.end_date
    INTO   ORGNAME, ORGDESC, ORGPASS, STARTDATE, ENDDATE
    FROM   GL_BUDGET_ENTITIES be, GL_LOOKUPS lk
    --WHERE  be.budget_entity_id = P_BUDGET_ENTITY_ID
    WHERE  be.budget_entity_id = P_BUDGET_ENTITY_ID_NEW
    AND    lk.lookup_code = be.budget_password_required_flag
    AND    lk.lookup_type = 'YES/NO';
  end if;

  /*SRW.REFERENCE(STRUCT_NUM);*/null;


 null;

  /*srw.reference(STRUCT_NUM);*/null;


 null;

  return (TRUE);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    errbuf := SQLERRM;
    /*SRW.MESSAGE('000',errbuf);*/null;

    raise_application_error(-20101,null);/*srw.program_abort;*/null;

end;

function AfterReport return boolean is
begin

/*srw.user_exit('FND SRWEXIT');*/null;
  return (TRUE);
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
  and    be.ledger_id = p_ledger_id;

  return(all_bud_ent_id);

RETURN NULL; EXCEPTION
  when NO_DATA_FOUND then
    return -1;
end;

--Functions to refer Oracle report placeholders--

 Function LEDGER_NAME_p return varchar2 is
	Begin
	 return LEDGER_NAME;
	 END;
 Function ORGNAME_p return varchar2 is
	Begin
	 return ORGNAME;
	 END;
 Function ORGDESC_p return varchar2 is
	Begin
	 return ORGDESC;
	 END;
 Function ORGPASS_p return varchar2 is
	Begin
	 return ORGPASS;
	 END;
 Function STARTDATE_p return date is
	Begin
	 return STARTDATE;
	 END;
 Function ENDDATE_p return date is
	Begin
	 return ENDDATE;
	 END;
 Function STRUCT_NUM_p return number is
	Begin
	 return STRUCT_NUM;
	 END;
 Function budgetary_control_flag_p return varchar2 is
	Begin
	 return budgetary_control_flag;
	 END;
 Function DAS_NAME_p return varchar2 is
	Begin
	 return DAS_NAME;
	 END;
END GL_GLXRLBOL_XMLP_PKG ;


/
