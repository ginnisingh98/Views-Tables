--------------------------------------------------------
--  DDL for Package Body AP_AMOUNT_UTILITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_AMOUNT_UTILITIES_PKG" AS
/* $Header: apamtutb.pls 120.3 2004/10/27 01:26:08 pjena noship $ */

function ap_convert_number (in_numeral IN NUMBER) return varchar2  is
  c_zero              ap_lookup_codes.displayed_field%TYPE;
  c_thousand          ap_lookup_codes.displayed_field%TYPE;
  c_million           ap_lookup_codes.displayed_field%TYPE;
  c_billion           ap_lookup_codes.displayed_field%TYPE;
  number_too_large    exception;
  numeral             integer := abs(in_numeral);
  max_digit           integer := 12;  -- for numbers less than a trillion
  number_text         varchar2(240) := '';
  billion_seg         varchar2(25);
  million_seg         varchar2(25);
  thousand_seg        varchar2(25);
  units_seg           varchar2(25);
  billion_lookup      varchar2(80);
  million_lookup      varchar2(80);
  thousand_lookup     varchar2(80);
  units_lookup        varchar2(80);
  session_language    fnd_languages.nls_language%TYPE;
  thousand            number      := power(10,3);
  million             number      := power(10,6);
  billion             number      := power(10,9);

begin
  if numeral >= power(10,max_digit) then
     raise number_too_large;
  end if;

--For Bug459665
if numeral = 0 then
  select ' '||displayed_field||' '
  into
         c_zero
  from   ap_lookup_codes
  where  lookup_code = 'ZERO';
     return(c_zero);
  end if;

 billion_seg := to_char(trunc(numeral/billion));
  numeral := numeral - (trunc(numeral/billion) * billion);
  million_seg := to_char(trunc(numeral/million));
  numeral := numeral - (trunc(numeral/million) * million);
  thousand_seg := to_char(trunc(numeral/thousand));
  units_seg := to_char(mod(numeral,thousand));

  select ' '||lc1.displayed_field||' ',
         ' '||lc2.displayed_field||' ',
         ' '||lc3.displayed_field||' ',
         ' '||lc4.displayed_field,
         lc5.description,
         lc6.description,
         lc7.description,
         lc8.description
  into   c_billion,
         c_million,
         c_thousand,
         c_zero,
         billion_lookup,
         million_lookup,
         thousand_lookup,
         units_lookup
  from   ap_lookup_codes lc1,
         ap_lookup_codes lc2,
         ap_lookup_codes lc3,
         ap_lookup_codes lc4,
         ap_lookup_codes lc5,
         ap_lookup_codes lc6,
         ap_lookup_codes lc7,
         ap_lookup_codes lc8
  where  lc1.lookup_code = 'BILLION'
  and    lc1.lookup_type = 'NLS TRANSLATION'
  and    lc2.lookup_code = 'MILLION'
  and    lc2.lookup_type = 'NLS TRANSLATION'
  and    lc3.lookup_code = 'THOUSAND'
  and    lc3.lookup_type = 'NLS TRANSLATION'
  and    lc4.lookup_code = 'ZERO'
  and    lc4.lookup_type = 'NLS TRANSLATION'
  and    lc5.lookup_code = billion_seg
  and    lc5.lookup_type = 'NUMBERS'
  and    lc6.lookup_code = million_seg
  and    lc6.lookup_type = 'NUMBERS'
  and    lc7.lookup_code = thousand_seg
  and    lc7.lookup_type = 'NUMBERS'
  and    lc8.lookup_code = units_seg
  and    lc8.lookup_type = 'NUMBERS';

--Commented For Bug459665
/*
if numeral = 0 then
     return(c_zero);
  end if;
*/
 select substr(userenv('LANGUAGE'),1,instr(userenv('LANGUAGE'),'_')-1)
  into   session_language
  from   dual;

--Bug 335063 fix.

  if (session_language = 'FRENCH' or session_language = 'CANADIAN FRENCH')
     and thousand_seg = '1' then
     thousand_lookup := null;
  end if;
--

  if billion_seg <> '0' then
     number_text := number_text||billion_lookup ||c_billion;
  end if;

  if million_seg <> '0' then
     number_text := number_text||million_lookup||c_million;
  end if;

  if thousand_seg <> '0' then
     number_text := number_text||thousand_lookup||c_thousand;
  end if;

  if units_seg <> '0' then
     number_text := number_text||units_lookup;
  end if;

  number_text := ltrim(number_text);
  number_text := upper(substr(number_text,1,1)) ||
                 rtrim(lower(substr(number_text,2,length(number_text))));

  return(number_text);

exception
  when number_too_large then
        return(null);
  when others then
        return(null);
end;

END AP_AMOUNT_UTILITIES_PKG;

/
