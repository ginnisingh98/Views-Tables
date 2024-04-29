--------------------------------------------------------
--  DDL for Package Body PAY_CA_AMT_IN_WORDS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_AMT_IN_WORDS" as
/* $Header: pycaamtw.pkb 115.4 2003/06/03 08:39:24 sfmorris noship $*/
/*

   ******************************************************************
   *                                                                *
   *  Copyright (C) 1992 Oracle Corporation UK Ltd.,                *
   *                   Chertsey, England.                           *
   *                                                                *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation UK Ltd,  *
   *  Oracle Park, Bittams Lane, Guildford Road, Chertsey, Surrey,  *
   *  England.                                                      *
   *                                                                *
   ******************************************************************

    Name        : pay_ca_amt_in_words

    Description : Package for converting amount in words using lookup type
                  for translating in Canadian French.

   Change List
   -----------
   Date         Name        Vers   Bug No   Description
   -----------  ----------  -----  -------  -----------------------------------
   04-Jan-2002  vpandya     115.0           Created
   04-Jan-2002  vpandya     115.1           One '$' sign added in indent line.
   05-Jan-2002  vpandya     115.2           Using AP's lookup type 'NUMBERS'
                                            for lookup values from '0' to '999'
   27-MAR-2002  vpandya     115.3           Commented out the trace_on(#2285625)
   03-JUN-2003  sfmorris    115.4  2888822  Added parameters p_denomination and
                                            p_sub_denomination to support
                                            output in Euros for French
                                            Localisation
--
*/

function pay_amount_in_words (in_numeral IN NUMBER,
                              p_language IN VARCHAR2,
                              p_denomination IN VARCHAR2,
                              p_sub_denomination IN VARCHAR2) return varchar2  is

  c_zero              ap_lookup_codes.displayed_field%TYPE;
  c_thousand          ap_lookup_codes.displayed_field%TYPE;
  c_million           ap_lookup_codes.displayed_field%TYPE;
  c_billion           ap_lookup_codes.displayed_field%TYPE;
  number_too_large    exception;
  abs_num             varchar2(25)  := to_char(in_numeral,'999999999990.00');
  numeral             integer := abs(in_numeral);
  max_digit           integer := 12;  -- for numbers less than a trillion
  number_text         varchar2(240) := '';
  billion_seg         varchar2(25);
  million_seg         varchar2(25);
  thousand_seg        varchar2(25);
  units_seg           varchar2(25);
  cents_seg           varchar2(25);
  cents               varchar2(25);
  billion_lookup      varchar2(80);
  million_lookup      varchar2(80);
  thousand_lookup     varchar2(80);
  units_lookup        varchar2(80);
  and_lookup          varchar2(25);
  dollars_lookup      varchar2(25);
  cents_lookup        varchar2(25);
  session_language    fnd_languages.nls_language%TYPE;
  thousand            number      := power(10,3);
  million             number      := power(10,6);
  billion             number      := power(10,9);

begin
--hr_utility.trace_on(null,'AMT');

  hr_utility.trace('LANGUAGE '||p_language);
  hr_utility.trace('ABS_NUM '||abs_num);

select substr(abs_num,1,instr(abs_num,'.'))
into   numeral
from dual;


  hr_utility.trace('NUMERAL '||to_char(numeral));

  if numeral >= power(10,max_digit) then
     raise number_too_large;
  end if;

  if numeral = 0 and to_number(abs_num) = 0 then
     select description
     into   c_zero
     from   fnd_lookup_types  flt,
            fnd_lookup_values flv
     where  flt.application_id = 200
     and    flt.lookup_type    = 'NUMBERS'
     and    flv.lookup_type    = flt.lookup_type
     and    flv.lookup_code    = '0'
     and    flv.language       = p_language;
     return(c_zero);
  end if;

  cents     := to_char( (abs_num - numeral),'9.99' );
  cents_seg := substr(cents,instr(cents,'.')+1,2);
  hr_utility.trace('CENTS NUMERAL '||cents_seg);
  hr_utility.trace('BILLION NUMERAL '||to_char(numeral));
  billion_seg := to_char(trunc(numeral/billion));
  hr_utility.trace('BILLION '||billion_seg);
  numeral := numeral - (trunc(numeral/billion) * billion);
  hr_utility.trace('MILLION NUMERAL '||to_char(numeral));
  million_seg := to_char(trunc(numeral/million));
  hr_utility.trace('MILLION '||million_seg);
  numeral := numeral - (trunc(numeral/million) * million);
  hr_utility.trace('THOUSAND NUMERAL '||to_char(numeral));
  thousand_seg := to_char(trunc(numeral/thousand));
  hr_utility.trace('THOUSAND '||thousand_seg);
  units_seg := numeral - (trunc(numeral/thousand) * thousand);
  hr_utility.trace('UNITS NUMERAL '||units_seg);
  hr_utility.trace('UNITS '||units_seg);
  --units_seg := to_char(mod(numeral,thousand));


  select flv9.meaning,
         flv10.meaning,
         flv11.meaning
  into   and_lookup,
         dollars_lookup,
         cents_lookup
  from   fnd_lookup_types  flt9,
         fnd_lookup_values flv9,
         fnd_lookup_types  flt10,
         fnd_lookup_values flv10,
         fnd_lookup_types  flt11,
         fnd_lookup_values flv11
  where  flt9.application_id  = 800
  and    flt9.lookup_type     = 'AMOUNT_IN_WORDS'
  and    flv9.lookup_type     = flt9.lookup_type
  and    flv9.lookup_code     = 'AND'
  and    flv9.language        = p_language
  and    flt10.application_id = 800
  and    flt10.lookup_type    = 'AMOUNT_IN_WORDS'
  and    flv10.lookup_type    = flt9.lookup_type
  and    flv10.lookup_code    = p_denomination
  and    flv10.language       = p_language
  and    flt11.application_id = 800
  and    flt11.lookup_type    = 'AMOUNT_IN_WORDS'
  and    flv11.lookup_type    = flt9.lookup_type
  and    flv11.lookup_code    = p_sub_denomination
  and    flv11.language       = p_language;

  if billion_seg <> '0' then
     select ' '||flv1.meaning||' ',
            flv2.description
     into   c_billion,
            billion_lookup
     from   fnd_lookup_values flv1,
            fnd_lookup_types  flt1,
            fnd_lookup_values flv2,
            fnd_lookup_types  flt2
     where  flt1.application_id = 800
     and    flt1.lookup_type    = 'AMOUNT_IN_WORDS'
     and    flv1.lookup_type    = flt1.lookup_type
     and    flv1.lookup_code    = 'BILLION'
     and    flv1.language       = p_language
     and    flt2.application_id = 200
     and    flt2.lookup_type    = 'NUMBERS'
     and    flv2.lookup_type    = flt2.lookup_type
     and    flv2.lookup_code    = billion_seg
     and    flv2.language       = p_language;

     number_text := number_text||billion_lookup ||c_billion;
  end if;

  if million_seg <> '0' then
     select ' '||flv3.meaning||' ',
            flv4.description
     into   c_million,
            million_lookup
     from   fnd_lookup_values flv3,
            fnd_lookup_types  flt3,
            fnd_lookup_values flv4,
            fnd_lookup_types  flt4
     where  flt3.application_id = 800
     and    flt3.lookup_type    = 'AMOUNT_IN_WORDS'
     and    flv3.lookup_type    = flt3.lookup_type
     and    flv3.lookup_code    = 'MILLION'
     and    flv3.language       = p_language
     and    flt4.application_id = 200
     and    flt4.lookup_type    = 'NUMBERS'
     and    flv4.lookup_type    = flt4.lookup_type
     and    flv4.lookup_code    = million_seg
     and    flv4.language       = p_language;

     number_text := number_text||million_lookup||c_million;
  end if;

  if thousand_seg <> '0' then
     select ' '||flv5.meaning||' ',
            flv6.description
     into   c_thousand,
            thousand_lookup
     from   fnd_lookup_values flv5,
            fnd_lookup_types  flt5,
            fnd_lookup_values flv6,
            fnd_lookup_types  flt6
     where  flt5.application_id = 800
     and    flt5.lookup_type    = 'AMOUNT_IN_WORDS'
     and    flv5.lookup_type    = flt5.lookup_type
     and    flv5.lookup_code    = 'THOUSAND'
     and    flv5.language       = p_language
     and    flt6.application_id = 200
     and    flt6.lookup_type    = 'NUMBERS'
     and    flv6.lookup_type    = flt6.lookup_type
     and    flv6.lookup_code    = thousand_seg
     and    flv6.language       = p_language;

     if thousand_seg = '1' then
        thousand_lookup := null;
     end if;

     number_text := number_text||thousand_lookup||c_thousand;
  end if;

  if units_seg <> '0' then
     select flv7.description
     into   units_lookup
     from   fnd_lookup_values flv7,
            fnd_lookup_types  flt7
     where  flt7.application_id = 200
     and    flt7.lookup_type    = 'NUMBERS'
     and    flv7.lookup_type    = flt7.lookup_type
     and    flv7.lookup_code    = units_seg
     and    flv7.language       = p_language;

     number_text := number_text||units_lookup;
  end if;

  number_text := ltrim(number_text);
  number_text := upper(substr(number_text,1,1)) ||
                 rtrim(lower(substr(number_text,2,length(number_text))));

  if number_text is null and cents_seg is not null then
     number_text := cents_seg||' '||cents_lookup;
  else
     number_text := number_text || ' '||dollars_lookup||' '||and_lookup ||
                    ' '||cents_seg||' '||cents_lookup;
  end if;

--hr_utility.trace_off;
  return(number_text);

exception
  when number_too_large then
        return(null);
  when others then
        return(null);
end;

end pay_ca_amt_in_words;

/
