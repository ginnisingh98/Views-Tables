--------------------------------------------------------
--  DDL for Package Body FA_JAPAN_DEP_TAX_ADDITION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_JAPAN_DEP_TAX_ADDITION_PKG" AS
/* $Header: FADTXAB.pls 120.1.12010000.2 2009/07/19 12:47:42 glchen ship $ */

function BeforeReport return boolean is

begin

  Select
	SC.Location_flex_structure,
	SOB.Currency_code
  into	h_loc_flex_struct,
	CURRENCY_CODE
  from	FA_SYSTEM_CONTROLS	SC,
	FA_BOOK_CONTROLS	BC,
	GL_SETS_OF_BOOKS	SOB
  where	BC.BOOK_TYPE_CODE = P_BOOK
  and	SOB.Set_of_books_id = BC.Set_of_books_ID;


  select meaning
  into 	h_classification
  from 	FA_LOOKUPS
  where lookup_type ='JP_CLASSIFICATION'
    and	lookup_code = p_classification;

  if p_classification = 'ADDITION' then
	h_where :='DTI.ADD_DEC_FLAG = ''A'' ';
  else
	h_where :='DTI.END_COST >0';
  end if;

  if p_pagesize =132 then
    h_currency_width :=10;
  else
    h_currency_width :=15;
  end if;


  select meaning
    into h_imperial_code
  from   FA_LOOKUPS
  where  lookup_type ='JP_IMPERIAL'
    and  lookup_code = to_char(to_date(to_char(p_year),'YYYY'),'E','nls_calendar=''Japanese Imperial''');

  select to_number(to_char(to_date(to_char(p_year),'YYYY'),'YY','nls_calendar=''Japanese Imperial'''))
  into   h_imperial_year
  from dual;

  return (TRUE);

EXCEPTION
	when no_data_found then
		h_no_data_found :=0;

  return (TRUE);

end;

function AfterReport return boolean is
begin

/*SRW.USER_EXIT('FND SRWEXIT');*/null;
  return (TRUE);
end;

function d_state_descformula0005(sum_state in varchar2) return char is
  c_state_desc varchar2(400);
begin
  c_state_desc :=
	fa_rx_flex_pkg.get_description(
		p_application_id 	=> 140,
		p_id_flex_code		=> 'LOC#',
		p_id_flex_num		=> h_loc_flex_struct,
		p_qualifier		=> 'LOC_STATE',
		p_data			=> sum_state);

  c_state_desc := sum_state||' - '||c_state_desc;
return(C_STATE_DESC);

end;

function d_decisionformula0007(sum_state in varchar2) return char is
 c_sum_theoretical_nbv  number;
 c_sum_evaluated_nbv   number;
 l_decision   varchar2(20);
begin

 if p_decision_cost ='THEORETICAL' then
	l_decision :='THEORETICAL';
 elsif p_decision_cost ='EVALUATED' then
	l_decision :='EVALUATED';
 else

	select	sum(theoretical_nbv), sum(evaluated_nbv)
	into	c_sum_theoretical_nbv, c_sum_evaluated_nbv
	from 	FA_DEPRN_TAX_REP_ITF DTI
	where	DTI.END_COST >0
	and	DTI.STATE = sum_state
	and 	DTI.REQUEST_ID = p_request_id;

	if c_sum_theoretical_nbv > c_sum_evaluated_nbv then
		l_decision :='THEORETICAL';
	else
		l_decision :='EVALUATED';
	end if;
 end if;

 /*SRW.MESSAGE(1,'State:'||sum_state||'- DECISION COST:'||l_decision);*/null;


 return(l_decision);

end;

function d_state_countformula(sum_state in varchar2) return number is
 c_count number;
begin

 if p_classification ='ADDITION' then
  select count(asset_id)
  into c_count
  from FA_DEPRN_TAX_REP_ITF
  where request_id = p_request_id
  and year =p_year
  and state = sum_state
  and add_dec_flag='A';
 else   select count(asset_id)
  into c_count
  from FA_DEPRN_TAX_REP_ITF
  where request_id = p_request_id
  and year =p_year
  and state = sum_state
  and end_cost >0;
 end if;

 return(c_count);
end;

--Functions to refer Oracle report placeholders--

 Function H_WHERE_p return varchar2 is
	Begin
	 return H_WHERE;
	 END;
 Function H_DECISION_p return varchar2 is
	Begin
	 return H_DECISION;
	 END;
 Function H_IMPERIAL_CODE_p return varchar2 is
	Begin
	 return H_IMPERIAL_CODE;
	 END;
 Function H_IMPERIAL_YEAR_p return number is
	Begin
	 return H_IMPERIAL_YEAR;
	 END;
 Function H_NO_DATA_FOUND_p return number is
	Begin
	 return H_NO_DATA_FOUND;
	 END;
 Function H_STATE_DESC_p return varchar2 is
	Begin
	 return H_STATE_DESC;
	 END;
 Function CURRENCY_CODE_p return varchar2 is
	Begin
	 return CURRENCY_CODE;
	 END;
 Function H_CURRENCY_WIDTH_p return number is
	Begin
	 return H_CURRENCY_WIDTH;
	 END;
 Function H_CLASSIFICATION_p return varchar2 is
	Begin
	 return H_CLASSIFICATION;
	 END;
 Function h_loc_flex_struct_p return number is
	Begin
	 return h_loc_flex_struct;
	 END;
END FA_JAPAN_DEP_TAX_ADDITION_PKG ;

/
