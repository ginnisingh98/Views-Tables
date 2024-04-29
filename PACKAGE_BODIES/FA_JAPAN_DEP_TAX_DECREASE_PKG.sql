--------------------------------------------------------
--  DDL for Package Body FA_JAPAN_DEP_TAX_DECREASE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_JAPAN_DEP_TAX_DECREASE_PKG" AS
/* $Header: FADTXDB.pls 120.1.12010000.2 2009/07/19 12:48:57 glchen ship $ */

function BeforeReport return boolean is

	c_state_desc		varchar(240);
	loc_flex_struct		number;


begin

/*SRW.USER_EXIT('FND SRWINIT');*/null;


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


select 	meaning
into 	h_imperial_code
from 	FA_LOOKUPS
where 	lookup_type ='JP_IMPERIAL'
and	lookup_code = to_char(to_date(to_char(p_year),'YYYY'),'E','nls_calendar=''Japanese Imperial''');

select to_number(to_char(to_date(to_char(p_year),'YYYY'),'YY','nls_calendar=''Japanese Imperial'''))
into   h_imperial_year
from dual;



  return (TRUE);
end;

function AfterReport return boolean is
begin

/*SRW.USER_EXIT('FND SRWEXIT');*/null;
  return (TRUE);
end;

function BetweenPage return boolean is
begin
  return (TRUE);
end;

function state_descformula(sum_state in varchar2) return char is
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

function state_countformula(sum_state in varchar2) return number is
 c_count number;
begin
 select count(asset_id)
 into c_count
 from FA_DEPRN_TAX_REP_ITF
 where request_id = p_request_id
 and year =p_year
 and state = sum_state
 and add_dec_flag ='D';

 return(c_count);

end;

--Functions to refer Oracle report placeholders--

 Function H_IMPERIAL_CODE_p return varchar2 is
	Begin
	 return H_IMPERIAL_CODE;
	 END;
 Function H_IMPERIAL_YEAR_p return number is
	Begin
	 return H_IMPERIAL_YEAR;
	 END;
 Function H_STATE_DESC_p return varchar2 is
	Begin
	 return H_STATE_DESC;
	 END;
 Function CURRENCY_CODE_p return varchar2 is
	Begin
	 return CURRENCY_CODE;
	 END;
 Function h_loc_flex_struct_p return number is
	Begin
	 return h_loc_flex_struct;
	 END;
END FA_JAPAN_DEP_TAX_DECREASE_PKG ;

/
