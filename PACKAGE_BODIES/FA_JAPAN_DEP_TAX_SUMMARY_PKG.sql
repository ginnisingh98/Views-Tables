--------------------------------------------------------
--  DDL for Package Body FA_JAPAN_DEP_TAX_SUMMARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_JAPAN_DEP_TAX_SUMMARY_PKG" AS
/* $Header: FADTXSB.pls 120.2.12010000.3 2010/02/16 07:02:26 pmadas ship $ */

function BeforeReport return boolean is

begin

  Select
        SC.Location_flex_structure,
        SOB.Currency_code
  into  h_loc_flex_struct,
        CURRENCY_CODE
  from  FA_SYSTEM_CONTROLS      SC,
        FA_BOOK_CONTROLS        BC,
        GL_SETS_OF_BOOKS        SOB
  where BC.BOOK_TYPE_CODE = P_BOOK
    and SOB.Set_of_books_id = BC.Set_of_books_ID;

  select meaning
  into   h_imperial_code
  from   FA_LOOKUPS
  where  lookup_type ='JP_IMPERIAL'
    and  lookup_code = to_char(to_date(to_char(p_year),'YYYY'),'E','nls_calendar=''Japanese Imperial''');

  select to_number(to_char(to_date(to_char(p_year),'YYYY'),'YY','nls_calendar=''Japanese Imperial'''))
  into   h_imperial_year
  from dual;

  select meaning
  into   h_today_imperial_code
  from   FA_LOOKUPS
  where  lookup_type ='JP_IMPERIAL'
    and  lookup_code = to_char(to_date(to_char(sysdate,'YYYY'),'YYYY'),'E','nls_calendar=''Japanese Imperial''');

  select to_number(to_char(to_date(to_char(sysdate,'YYYY'),'YYYY'),'YY','nls_calendar=''Japanese Imperial'''))
  into   h_today_imperial_year
  from dual;

  return (TRUE);

end;

function AfterReport return boolean is
begin
  return (TRUE);
end;

function d_state_descformula(l_state in varchar2) return varchar2 is
  c_state_desc varchar2(400);
begin
  c_state_desc :=
        fa_rx_flex_pkg.get_description(
                p_application_id        => 140,
                p_id_flex_code          => 'LOC#',
                p_id_flex_num           => h_loc_flex_struct,
                p_qualifier             => 'LOC_STATE',
                p_data                  => l_state);

   c_state_desc := l_state||' - '||c_state_desc;

  return(c_state_desc);
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
 Function H_TODAY_IMPERIAL_CODE_p return varchar2 is
        Begin
         return H_TODAY_IMPERIAL_CODE;
         END;
 Function H_TODAY_IMPERIAL_YEAR_p return number is
        Begin
         return H_TODAY_IMPERIAL_YEAR;
         END;
 Function H_DECISION_p return varchar2 is
        Begin
         return H_DECISION;
         END;
 Function H_STATE_DESC_p return varchar2 is
        Begin
         return H_STATE_DESC;
         END;
 Function CURRENCY_CODE_p return varchar2 is
        Begin
         return CURRENCY_CODE;
         END;
 Function H_LOC_FLEX_STRUCT_p return number is
        Begin
         return H_LOC_FLEX_STRUCT;
         END;

 Function get_fnd_meaning(l_type in varchar2, l_code in varchar2) return varchar2 is
   l_meaning varchar2(80);
 begin
    select meaning
      into l_meaning
    from fnd_lookups
    where lookup_type = l_type
      and lookup_code = l_code;

    return (l_meaning);
 end;

 Function get_fa_meaning(l_type in varchar2, l_code in varchar2) return varchar2 is
   l_meaning varchar2(80);
 begin
    select meaning
      into l_meaning
    from fa_lookups
    where lookup_type = l_type
      and lookup_code = l_code;

    return (l_meaning);
 end;

 function d_decisionformula(l_state in varchar2) return varchar2 is
   c_sum_theoretical_nbv  number;
   c_sum_evaluated_nbv number;
 begin

    select sum(theoretical_nbv), sum(evaluated_nbv)
    into   c_sum_theoretical_nbv, c_sum_evaluated_nbv
    from   FA_DEPRN_TAX_REP_ITF DTI
    where  DTI.END_COST >0
      and  DTI.STATE = l_state
      and  DTI.REQUEST_ID = p_request_id;

    if c_sum_theoretical_nbv > c_sum_evaluated_nbv then
        H_DECISION :='THEORETICAL';
    else
        H_DECISION :='EVALUATED';
    end if;

    return(H_DECISION);

 end;

 -- Bug 9362009: Modified the function to display data even if a single asset exists.
 Function NO_DATA_FOUND_p return varchar2 is
   l_found varchar2(3);
   l_count number;
 begin

    l_found := 'YES';
    l_count := 0;

    begin
      select count(1)
        into l_count
      from   FA_DEPRN_TAX_REP_ITF
      where  REQUEST_ID = p_request_id
      and    ASSET_ID IS NOT NULL;

      if l_count > 0 then
         l_found := 'NO';
      else
         l_found := 'YES';
      end if;

    exception
      when others then
        l_found := 'YES';
    end;

    return (l_found);
 end;
 -- End Bug 9362009

END FA_JAPAN_DEP_TAX_SUMMARY_PKG ;

/
