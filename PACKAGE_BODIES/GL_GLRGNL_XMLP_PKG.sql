--------------------------------------------------------
--  DDL for Package Body GL_GLRGNL_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_GLRGNL_XMLP_PKG" AS
/* $Header: GLRGNLB.pls 120.0 2007/12/27 14:37:54 vijranga noship $ */

function BeforeReport return boolean is
begin

	/*srw.user_exit('FND SRWINIT');*/null;


	declare
 	errbuf  VARCHAR2(132);
  	errbuf2 VARCHAR2(132);
	begin





                begin
                   SELECT name, chart_of_accounts_id
                   INTO   ACCESS_SET_NAME, STRUCT_NUM
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

  		/*srw.reference(STRUCT_NUM);*/null;


 null;

  		/*srw.reference(STRUCT_NUM);*/null;


 null;

  		/*srw.reference(STRUCT_NUM);*/null;


 null;

  		/*srw.reference(STRUCT_NUM);*/null;


 null;

  		/*srw.reference(STRUCT_NUM);*/null;


 null;

  		/*srw.reference(STRUCT_NUM);*/null;


 null;

  		/*srw.reference(STRUCT_NUM);*/null;


 null;

  		/*srw.reference(STRUCT_NUM);*/null;


 null;



  		if (P_KIND = 'L') then
    			SELECT_REFERENCE := 'jel.reference_1';
  		elsif (P_KIND = 'H') then
    			SELECT_REFERENCE := 'jeh.external_reference';
  		elsif (P_KIND = 'R') or (P_KIND = 'S') then
    			SELECT_REFERENCE := 'jel.reference_4';
  		else
   			SELECT_REFERENCE := 'jel.reference_1';
  		end if;



  		if (p_actual_flag = 'A') then
    			where_actual_type := '1 = 1';
  		elsif (p_actual_flag = 'B') then
    			where_actual_type := 'budget_version_id = ' ||
						to_char(P_BUD_ENC_TYPE_ID);
  		else
   			where_actual_type := 'encumbrance_type_id = '|| to_char(P_BUD_ENC_TYPE_ID);
  		end if;


		if (p_currency_type = 'S') then
  			where_currency_code :=	'(   jeh.currency_code = ''STAT''' ||
    						' OR jel.stat_amount is NOT NULL)';
  			select_dr := 'decode(jeh.currency_code, ''STAT'',' ||
      					'decode(nvl(jel.stat_amount,0),' ||
						'0, jel.accounted_dr,' ||
       					'decode(sign(nvl(jel.stat_amount,0)),' ||
						'-1, jel.accounted_dr,' ||
          					' 1, (nvl(jel.accounted_dr,0) + ' ||
						'jel.stat_amount),' ||
          					'jel.accounted_dr)),' ||
						'decode(sign(nvl(jel.stat_amount,0)),' ||
        					'1, nvl(jel.stat_amount,0), ' ||
						'NULL))';
  			select_cr :=  'decode(jeh.currency_code, ''STAT'',' ||
      				       'decode(nvl(jel.stat_amount,0),' ||
        					'0, jel.accounted_cr,' ||
        				'decode(sign(nvl(jel.stat_amount,0)),' ||
          					'-1, (nvl(jel.accounted_cr,0) - ' ||
                   			'jel.stat_amount),' ||
          				' 1, jel.accounted_cr,' ||
          				'jel.accounted_cr)),' ||
      					'decode(sign(nvl(jel.stat_amount,0)),' ||
        				'-1, (0 - nvl(jel.stat_amount,0)), ' ||
       					'NULL))';
		else
  			where_currency_code := 'jeh.currency_code <> ''STAT''';
  			select_dr := 'nvl(jel.accounted_dr, 0)';

  			select_cr := 'nvl(jel.accounted_cr, 0)';
		end if;

  		WHERE_INDEX := '1 = 1';

IF(P_CURRENCY_TYPE = 'S') THEN
   RESULTING_CURRENCY := 'STAT';
ELSE
   RESULTING_CURRENCY := P_LEDGER_CURRENCY;
END IF;

WHERE_DAS := GL_ACCESS_SET_SECURITY_PKG.GET_SECURITY_CLAUSE(
                P_ACCESS_SET_ID,
                'R',
                'LEDGER_COLUMN',
                'LEDGER_ID',
                'L2',
                'SEG_COLUMN',
                null,
                'CC',
                null);

if (WHERE_DAS is not null) then
  WHERE_DAS := ' and ' || WHERE_DAS ;
end if;

	end;
  	return (TRUE);
end;

function AfterReport return boolean is
begin

/*srw.user_exit('FND SRWEXIT');*/null;
  return (TRUE);
end;

function OLD_CCIDFormula return Number is
begin

/*srw.reference(NEW_RECORD);*/null;

RETURN NULL; end;

function OLD_END_DRFormula return Number is
begin

/*srw.reference(BAD_START);*/null;

RETURN NULL; end;

function OLD_END_CRFormula return Number is
begin

/*srw.reference(BAD_START);*/null;

RETURN NULL; end;

function new_recordformula(ccid in number) return varchar2 is
begin

if ((old_ccid is null) or
    (ccid <> old_ccid)) then
  old_ccid := ccid;

  return('Y');
else
  return('N');
end if;
RETURN NULL; end;

function bad_startformula(new_record in varchar2, period_num in number, period_year in number, begin_dr in number, begin_cr in number, period_dr in number, period_cr in number) return varchar2 is
begin



if (new_record <> 'Y') and
   (period_num <> 1) and
   (period_year = last_period_year) and
   ((begin_dr <> old_end_dr) or
    (begin_cr <> old_end_cr)) then
  old_end_dr := begin_dr + period_dr;
  old_end_cr := begin_cr + period_cr;
  last_period_year := period_year;
  return('Y');
else
  old_end_dr := begin_dr + period_dr;
  old_end_cr := begin_cr + period_cr;
  last_period_year := period_year;
  return('N');
end if;
RETURN NULL; end;

function bad_endformula(period_dr in number, total_dr in number, period_cr in number, total_cr in number, template_id in number) return varchar2 is
begin


if ((period_dr <> total_dr) or
    (period_cr <> total_cr)) and
    (template_id is null) then
  return('Y');
else
  return('N');
end if;
RETURN NULL; end;

function BUD_ENC_TYPE_NAMEFormula return VARCHAR2 is
begin


declare
  name     VARCHAR2(30);
  errbuf   VARCHAR2(132);
  errbuf2  VARCHAR2(132);
begin
  gl_info.gl_get_bud_or_enc_name(P_ACTUAL_FLAG,
                                 P_BUD_ENC_TYPE_ID,
                                 name, errbuf);

  if (errbuf is not null) then


    errbuf2 := gl_message.get_message(
                 'GL_PLL_ROUTINE_ERROR', 'N',
                 'ROUTINE','gl_get_bud_enc_name'
               );
    /*srw.message('00', errbuf2);*/null;


    /*srw.message('00', errbuf);*/null;


    raise_application_error(-20101,null);/*srw.program_abort;*/null;

  end if;

  return(name);
end;
RETURN NULL; end;

function DISP_ACTUAL_FLAGFormula return VARCHAR2 is
begin


declare
  value    VARCHAR2(240);
  errbuf   VARCHAR2(132);
  errbuf2  VARCHAR2(132);
begin
  gl_info.gl_get_lookup_value('D', P_ACTUAL_FLAG,
			      'BATCH_TYPE', value, errbuf);

  if (errbuf is not null) then


    errbuf2 := gl_message.get_message(
                 'GL_PLL_ROUTINE_ERROR', 'N',
                 'ROUTINE','gl_get_lookup_value'
               );
    /*srw.message('00', errbuf2);*/null;


    /*srw.message('00', errbuf);*/null;


    raise_application_error(-20101,null);/*srw.program_abort;*/null;

  end if;

  return(value);
end;

RETURN NULL; end;

function START_DATEFormula return Date is
begin


declare
  pstart   DATE;
  pend     DATE;
  errbuf   VARCHAR2(132);
  errbuf2  VARCHAR2(132);
begin
  gl_get_period_dates(P_LEDGER_ID,
                      P_START_PERIOD,
                      pstart,
                      pend,
                      errbuf);

  if (errbuf is not null) then


    errbuf2 := gl_message.get_message(
                 'GL_PLL_ROUTINE_ERROR', 'N',
                 'ROUTINE','gl_get_period_dates'
               );
    /*srw.message('00', errbuf2);*/null;


    /*srw.message('00', errbuf);*/null;


    raise_application_error(-20101,null);/*srw.program_abort;*/null;

  end if;

  return(pstart);
end;
RETURN NULL; end;

function END_DATEFormula return Date is
begin


declare
  pstart   DATE;
  pend     DATE;
  errbuf   VARCHAR2(132);
  errbuf2  VARCHAR2(132);
begin
  gl_get_period_dates(P_LEDGER_ID,
                      P_END_PERIOD,
                      pstart,
                      pend,
                      errbuf);

  if (errbuf is not null) then


    errbuf2 := gl_message.get_message(
                 'GL_PLL_ROUTINE_ERROR', 'N',
                 'ROUTINE','gl_get_period_dates'
               );
    /*srw.message('00', errbuf2);*/null;


    /*srw.message('00', errbuf);*/null;


    raise_application_error(-20101,null);/*srw.program_abort;*/null;

  end if;

  return(pend);
end;
RETURN NULL; end;

function DISP_CRFormula return VARCHAR2 is
begin


declare
  value    VARCHAR2(80);
  errbuf   VARCHAR2(132);
  errbuf2  VARCHAR2(132);
begin
  gl_info.gl_get_lookup_value('M', 'C', 'DR_CR',
                              value, errbuf);

  if (errbuf is not null) then


    errbuf2 := gl_message.get_message(
                 'GL_PLL_ROUTINE_ERROR', 'N',
                 'ROUTINE','gl_get_lookup_value'
               );
    /*srw.message('00', errbuf2);*/null;


    /*srw.message('00', errbuf);*/null;


    raise_application_error(-20101,null);/*srw.program_abort;*/null;

  end if;

  return(value);
end;

RETURN NULL; end;

function begin_balformula(BEGIN_CR in number, BEGIN_DR in number) return number is
begin

    if  abs(BEGIN_CR) > abs (BEGIN_DR) then
            return (BEGIN_CR - BEGIN_DR);
    else
            return (BEGIN_DR - BEGIN_CR);
    end if;

end;

function end_balformula(BEGIN_CR in number, PERIOD_CR in number, BEGIN_DR in number, PERIOD_DR in number) return number is
begin

   if   abs(BEGIN_CR + PERIOD_CR ) > abs (BEGIN_DR + PERIOD_DR)  then
        return (BEGIN_CR + PERIOD_CR - (BEGIN_DR + PERIOD_DR));
   else
        return (BEGIN_DR + PERIOD_DR - (BEGIN_CR + PERIOD_CR));
   end if;


end;

function accounted_balformula(ACCOUNTED_CR in number, ACCOUNTED_DR in number) return number is
begin

if  ( abs (ACCOUNTED_CR) > abs (ACCOUNTED_DR)) then
       return (  nvl( ACCOUNTED_CR ,0) - nvl(ACCOUNTED_DR , 0)) ;
else
        return (nvl(ACCOUNTED_DR, 0) - nvl(ACCOUNTED_CR, 0));
end if;
end;

function LAST_PERIOD_YEARFormula return Number is
begin

/*srw.reference(BAD_START);*/null;

RETURN NULL; end;

procedure gl_get_period_dates (tledger_id in number,
                                 tperiod_name     in varchar2,
                                 tstart_date      out NOCOPY date ,
                                 tend_date        out NOCOPY date,
                                 errbuf           out NOCOPY varchar2)
  is
    ledger_obj_type  VARCHAR2(1);
    single_ledger_id NUMBER;
  BEGIN
     select object_type_code
     into   ledger_obj_type
     from   gl_ledgers
     where  ledger_id = tledger_id;

     if (ledger_obj_type = 'L') then
        single_ledger_id := tledger_id;
     else
        select l.ledger_id
        into   single_ledger_id
        from   gl_ledger_set_assignments ls, gl_ledgers l
        where  ls.ledger_set_id = tledger_id
        and    l.ledger_id = ls.ledger_id
        and    l.object_type_code = 'L'
        and    rownum = 1;
     end if;

        select start_date, end_date
        into   tstart_date, tend_date
        from gl_period_statuses
        where period_name = tperiod_name
        and ledger_id = single_ledger_id
        and application_id = 101;

  EXCEPTION

  WHEN NO_DATA_FOUND THEN

        errbuf := gl_message.get_message('GL_PLL_INVALID_PERIOD', 'Y',
                                 'PERIOD', tperiod_name,
                                 'LDGID', to_char(tledger_id) );

  WHEN OTHERS THEN

        errbuf := SQLERRM;

  END;

procedure gl_get_eff_period_num (tledger_id       in number,
                                tperiod_name     in varchar2,
                                teffnum          out NOCOPY number,
                                errbuf           out NOCOPY varchar2)
is
  ledger_obj_type  VARCHAR2(1);
  single_ledger_id NUMBER;
BEGIN
  select object_type_code
  into   ledger_obj_type
  from   gl_ledgers
  where  ledger_id = tledger_id;

  if (ledger_obj_type = 'L') then
    single_ledger_id := tledger_id;
  else
    select l.ledger_id
    into   single_ledger_id
    from   gl_ledger_set_assignments ls, gl_ledgers l
    where  ls.ledger_set_id = tledger_id
    and    l.ledger_id = ls.ledger_id
    and    l.object_type_code = 'L'
    and    rownum = 1;
  end if;

  select effective_period_num
  into   teffnum
  from   gl_period_statuses
  where  period_name = tperiod_name
  and    ledger_id = single_ledger_id
  and    application_id = 101;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    errbuf := gl_message.get_message('GL_PLL_INVALID_PERIOD', 'Y',
                                 'PERIOD', tperiod_name,
                                 'LDGID', to_char(tledger_id));

  WHEN OTHERS THEN
    errbuf := SQLERRM;

END;

function START_EFF_PERIOD_NUMFormula return Number is
begin


declare
  peffperiod_num     NUMBER;
  errbuf   VARCHAR2(132);
  errbuf2  VARCHAR2(132);
begin
  gl_get_eff_period_num(P_LEDGER_ID,
                      P_START_PERIOD,
                      peffperiod_num,
                      errbuf);

  if (errbuf is not null) then


    errbuf2 := gl_message.get_message(
                 'GL_PLL_ROUTINE_ERROR', 'N',
                 'ROUTINE','gl_get_eff_period_num'
               );
    /*srw.message('00', errbuf2);*/null;


    /*srw.message('00', errbuf);*/null;


    raise_application_error(-20101,null);/*srw.program_abort;*/null;

  end if;

  return(peffperiod_num);
end;
RETURN NULL; end;

function END_EFF_PERIOD_NUMFormula return Number is
begin


declare
  peffperiod_num     NUMBER;
  errbuf   VARCHAR2(132);
  errbuf2  VARCHAR2(132);
begin
  gl_get_eff_period_num(P_LEDGER_ID,
                      P_END_PERIOD,
                      peffperiod_num,
                      errbuf);

  if (errbuf is not null) then


    errbuf2 := gl_message.get_message(
                 'GL_PLL_ROUTINE_ERROR', 'N',
                 'ROUTINE','gl_get_eff_period_num'
               );
    /*srw.message('00', errbuf2);*/null;


    /*srw.message('00', errbuf);*/null;


    raise_application_error(-20101,null);/*srw.program_abort;*/null;

  end if;

  return(peffperiod_num);
end;
RETURN NULL; end;

function g_balancing_segmentgroupfilter(BAL_SECURE in varchar2) return boolean is
begin
  /*srw.reference(STRUCT_NUM);*/null;

  /*srw.reference(BAL_DATA);*/null;



 if (BAL_SECURE ='S') then
     return(FALSE);
 else
     return (TRUE);
 end if;

end;

function g_accounting_flexfieldgroupfil(FLEX_SECURE in varchar2) return boolean is
begin

  /*srw.reference(STRUCT_NUM);*/null;

  /*srw.reference(FLEXDATA);*/null;



  if(FLEX_SECURE = 'S') then
     return(FALSE);
  else
     return (TRUE);
  end if;

end;

function BeforePForm return boolean is
begin

  return (TRUE);
end;

function AfterPForm return boolean is
begin

  return (TRUE);
end;

function BetweenPage return boolean is
begin

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function CP_1_p return number is
	Begin
	 return CP_1;
	 END;
 Function OLD_CCID_p return number is
	Begin
	 return OLD_CCID;
	 END;
 Function OLD_END_DR_p return number is
	Begin
	 return OLD_END_DR;
	 END;
 Function OLD_END_CR_p return number is
	Begin
	 return OLD_END_CR;
	 END;
 Function LAST_PERIOD_YEAR_p return number is
	Begin
	 return LAST_PERIOD_YEAR;
	 END;
 Function STRUCT_NUM_p return varchar2 is
	Begin
	 return STRUCT_NUM;
	 END;
 Function SELECT_ALL_p return varchar2 is
	Begin
	 return SELECT_ALL;
	 END;
 Function WHERE_p return varchar2 is
	Begin
	-- return WHERE;
 	 return L_WHERE;
	 END;
 Function ORDERBY_BAL_p return varchar2 is
	Begin
	 return ORDERBY_BAL;
	 END;
 Function ORDERBY_ACCT_p return varchar2 is
	Begin
	 return ORDERBY_ACCT;
	 END;
 Function ORDERBY_ALL_p return varchar2 is
	Begin
	 return ORDERBY_ALL;
	 END;
 Function SELECT_BAL_p return varchar2 is
	Begin
	 return SELECT_BAL;
	 END;
 Function EXCLAIMATION_POINT_p return varchar2 is
	Begin
	 return EXCLAIMATION_POINT;
	 END;
 Function STAR_p return varchar2 is
	Begin
	 return STAR;
	 END;
 Function WHERE_ACTUAL_TYPE_p return varchar2 is
	Begin
	 return WHERE_ACTUAL_TYPE;
	 END;
 Function WHERE_CURRENCY_CODE_p return varchar2 is
	Begin
	 return WHERE_CURRENCY_CODE;
	 END;
 Function SELECT_REFERENCE_p return varchar2 is
	Begin
	 return SELECT_REFERENCE;
	 END;
 Function WHERE_INDEX_p return varchar2 is
	Begin
	 return WHERE_INDEX;
	 END;
 Function SELECT_CR_p return varchar2 is
	Begin
	 return SELECT_CR;
	 END;
 Function SELECT_DR_p return varchar2 is
	Begin
	 return SELECT_DR;
	 END;
 Function ORDERBY_BAL2_p return varchar2 is
	Begin
	 return ORDERBY_BAL2;
	 END;
 Function ORDERBY_ACCT2_p return varchar2 is
	Begin
	 return ORDERBY_ACCT2;
	 END;
 Function WHERE_DAS_p return varchar2 is
	Begin
	 return WHERE_DAS;
	 END;
 Function ACCESS_SET_NAME_p return varchar2 is
	Begin
	 return ACCESS_SET_NAME;
	 END;
 Function RESULTING_CURRENCY_p return varchar2 is
	Begin
	 return RESULTING_CURRENCY;
	 END;
	 begin
	 old_ccid:=null;

END GL_GLRGNL_XMLP_PKG ;



/
