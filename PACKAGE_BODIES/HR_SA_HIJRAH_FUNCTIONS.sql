--------------------------------------------------------
--  DDL for Package Body HR_SA_HIJRAH_FUNCTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_SA_HIJRAH_FUNCTIONS" as
/* $Header: pesahjdt.pkb 120.0.12010000.2 2008/08/06 09:37:10 ubhat ship $ */

  function hijrah_to_gregorian
    (p_input_date      in  varchar2)
  return varchar2 as
 /*   l_year             number := 0;
    l_month            number := 0;
    l_day              number := 0;
    l_fourtons         number := 0;
    l_tons             number := 0;
    l_leaps            number := 0;
    l_norm_yrs         number := 0;
    l_bal1             number := 0;
    l_bal2             number := 0;
    l_bal3             number := 0;
    l_bal4             number := 0;
    l_cnt1             number := 0;
    l_cnt2             number := 0;
    l_days_elapsed     number := 0;*/
    l_hij_year         number := 0;
    l_hij_month        number := 0;
    l_hij_day          number := 0;
    l_date             varchar2(10);
    l_input_date       varchar2(10);
  begin
  --	hr_utility.trace_on(null,'SADTCNV');
  	hr_utility.set_location('In side hijrah_to_gregorian',1);
  	hr_utility.set_location('p_input_date '|| p_input_date,1);
    if p_input_date is not null then
      hr_sa_hijrah_functions.validate_date(p_input_date,l_input_date);
      /*l_hij_year := to_number(substr(l_input_date,1,4)) - 1;
      l_hij_month := to_number(substr(l_input_date,6,2)) - 1;
      l_hij_day := to_number(substr(l_input_date,9,2)) ;*/
      l_hij_year    := to_number(substr(l_input_date,1,4)) ;
      l_hij_month   := to_number(substr(l_input_date,6,2)) ;
      l_hij_day     := to_number(substr(l_input_date,9,2)) ;
      l_input_date  := l_hij_year ||'/'||l_hij_month||'/'||l_hij_day;
      hr_utility.set_location('l_input_date '|| l_input_date,2);
      select to_char                             /* Bug No : 6823109 */
             (
                to_date
                (  l_input_date,'YYYY/MM/DD','NLS_CALENDAR=''ENGLISH HIJRAH'''
                )
                ,'YYYY/MM/DD'
             )
         into l_date
      from dual;
      hr_utility.set_location('l_date '|| l_date,3);
    --  hr_utility.trace_off;
      /*
      l_cnt1 := floor(l_hij_year * 354.36887);
      l_cnt2 := floor(l_hij_month * 29.5305);
      l_days_elapsed := 227011 + l_cnt1 + l_cnt2 + l_hij_day;
      l_fourtons := floor(l_days_elapsed/146097);
      l_bal1 := mod(l_days_elapsed,146097);
      l_tons := floor(l_bal1/36524);
      l_bal2 := mod(l_bal1,36524);
      l_leaps := floor(l_bal2/1461);
      l_bal3 := mod(l_bal2,1461);
      l_norm_yrs := floor(l_bal3/365);
      l_bal4 := floor(mod(l_bal3,365));
      l_year := (l_fourtons * 400) + (l_tons * 100) + (l_leaps * 4) + l_norm_yrs + 1;
      l_date := to_date(l_year||'/01/01','YYYY/MM/DD') + l_bal4;
      */
      return(l_date);
    else
      return null;
    end if;
  end hijrah_to_gregorian;

  function gregorian_to_hijrah
    (p_input_date      in  date)
  return varchar2 as
  /*  l_year             number := 0;
    l_month            number := 0;
    l_day              number := 0;
    l_fourtons         number := 0;
    l_tons             number := 0;
    l_leaps            number := 0;
    l_bal1             number := 0;
    l_bal2             number := 0;
    l_bal3             number := 0;
    l_cnt1             number := 0;
    l_cnt2             number := 0;
    l_cnt3             number := 0;
    l_cnt4             number := 0;
    l_hij_count        number := 0;
    l_days_elapsed     number := 0;
    l_days_curr_year   number := 0;
    l_hij_year         number := 0;
    l_hij_month        number := 0;
    l_hij_day          number := 0;
    l_hij_bal1         number := 0;
    l_hij_bal2         number := 0;*/
    l_hij_date         varchar2(30);
    l_input_date      varchar2(10);
  begin
    if p_input_date is not null then
      l_input_date := to_char (p_input_date,'RRRR-MM-DD');
      --  hr_utility.trace_on(null,'SADTCNV');
      hr_utility.set_location('In side gregorian_to_hijrah',1);
      hr_utility.set_location('p_input_date '|| p_input_date,1);
/*    l_year := to_number(substr(l_input_date,1,4)) - 1;
      l_month := to_number(substr(l_input_date,6,2)) - 1;
      l_day := to_number(substr(l_input_date,9,2));
      l_fourtons := floor(l_year/400);
      l_bal1 := mod(l_year,400);
      l_cnt1 := l_fourtons * 146097;
      l_tons := floor(l_bal1/100);
      l_bal2 := mod(l_bal1,100);
      l_cnt2 := l_tons * 36524;
      l_leaps := floor(l_bal2/4);
      l_bal3 := mod(l_bal2,4);
      l_cnt3 := l_leaps * 1461;
      l_cnt4 := l_bal3 * 365;
      l_days_curr_year := (to_date(l_input_date,'YYYY/MM/DD') - to_date(substr(l_input_date,1,4)||'/01/01','YYYY/MM/DD'));
      l_days_elapsed := l_cnt1 + l_cnt2 + l_cnt3 + l_cnt4 + l_days_curr_year;
      l_hij_count := l_days_elapsed - 227011;
      l_hij_year := floor(l_hij_count/354.36887) + 1;
      l_hij_bal1 := mod(l_hij_count,354.36887);
      l_hij_month := floor(l_hij_bal1/29.5305) + 1;*/
      /* Fix for bug 4024967 */
 /*     if(l_hij_month > 12) then
      l_hij_year := l_hij_year + 1;
      l_hij_month := 1;
      end if; */
      /* End of fix for bug 4024967 */
/*      l_hij_bal2 := mod(l_hij_bal1,29.5305);
      l_hij_day := floor(l_hij_bal2) + 1;
      l_hij_date := lpad(l_hij_year,4,'0')||'/'||lpad(l_hij_month,2,'0')||'/'||lpad(l_hij_day,2,'0');*/
      /* Bug No : 6823109 */
      select to_char
             (
                to_date
                ( l_input_date,'RRRR-MM-DD'
                )
                ,'YYYY/MM/DD','NLS_CALENDAR=''ENGLISH HIJRAH'''
              )
        into l_hij_date
      from dual ;
      hr_utility.set_location('l_hij_date '|| l_hij_date,2);
    --  hr_utility.trace_off;
      return (l_hij_date);
    else
      return null;
    end if;
  end gregorian_to_hijrah;

  function add_days
    (p_input_date    in  varchar2
    ,p_num           in  number)
  return varchar2 as
    l_greg_date     date;
    l_new_greg_date date;
    l_new_hij_date  varchar2(10);
    l_input_date    varchar2(10);
  begin
    hr_sa_hijrah_functions.validate_date(p_input_date,l_input_date);
    l_greg_date := to_date(hr_sa_hijrah_functions.hijrah_to_gregorian(l_input_date),'YYYY/MM/DD');
    l_new_greg_date := l_greg_date + p_num;
    l_new_hij_date := hr_sa_hijrah_functions.gregorian_to_hijrah(l_new_greg_date);
    return (l_new_hij_date);
  end add_days;

  function days_between
    (p_high_date     in  varchar2
    ,p_low_date      in  varchar2)
  return number as
    l_high_greg_date     date;
    l_low_greg_date      date;
    l_diff               number;
    l_high_date          varchar2(10);
    l_low_date           varchar2(10);
  begin
    hr_sa_hijrah_functions.validate_date(p_high_date,l_high_date);
    hr_sa_hijrah_functions.validate_date(p_low_date,l_low_date);
    l_high_greg_date := to_date(hr_sa_hijrah_functions.hijrah_to_gregorian(l_high_date),'YYYY/MM/DD');
    l_low_greg_date := to_date(hr_sa_hijrah_functions.hijrah_to_gregorian(l_low_date),'YYYY/MM/DD');
    l_diff := l_high_greg_date - l_low_greg_date;
    return(l_diff);
  end days_between;

  function get_day
    (p_input_date    in  varchar2)
  return varchar2 as
    l_day           varchar2(30);
    l_greg_date     date;
    l_input_date    varchar2(10);
  begin
    hr_sa_hijrah_functions.validate_date(p_input_date,l_input_date);
    l_greg_date := to_date(hr_sa_hijrah_functions.hijrah_to_gregorian(l_input_date),'YYYY/MM/DD');
    select ltrim(rtrim(to_char(l_greg_date,'D')))
    into   l_day
    from   dual;
    return(hr_general.decode_lookup('SA_HIJRAH_DAYS',l_day));
  end get_day;

  function get_month
    (p_input_date    in  varchar2)
  return varchar2 as
    l_month         number;
    l_greg_date     date;
    l_input_date    varchar2(10);
  begin
    hr_sa_hijrah_functions.validate_date(p_input_date,l_input_date);
    l_month := to_number(substr(l_input_date,6,2));
    return(hr_general.decode_lookup('SA_HIJRAH_MONTHS',l_month));
  end get_month;

  function get_weekday
    (p_input_date    in  varchar2)
  return number as
    l_day           varchar2(10);
    l_greg_date     date;
    l_input_date    varchar2(10);
  begin
    hr_sa_hijrah_functions.validate_date(p_input_date,l_input_date);
    l_greg_date := to_date(hr_sa_hijrah_functions.hijrah_to_gregorian(l_input_date),'YYYY/MM/DD');
    select ltrim(rtrim(to_char(l_greg_date,'D')))
    into   l_day
    from   dual;
    return(l_day);
  end get_weekday;

  function get_yearday
    (p_input_date    in  varchar2)
  return number as
    l_first_date    varchar2(10);
    l_input_date    varchar2(10);
  begin
    hr_sa_hijrah_functions.validate_date(p_input_date,l_input_date);
    l_first_date := substr(l_input_date,1,4)||'/01/01';
    return(days_between(l_input_date,l_first_date));
  end get_yearday;

  procedure validate_date
    (p_input_date    in  varchar2,
     p_output_date out nocopy varchar2)
  as
    l_date_in varchar2(100);
l_field varchar2(100);
l_range varchar2(100);
l_length number;
l_position1 number default 0;
l_position2 number default 0;
l_error number;
l_year number;
l_month number;
l_day number;
l_year_date varchar2(10);
l_month_date varchar2(10);
l_day_date varchar2(10);
l_flag number := 0;


begin
    l_length := length(p_input_date);

        l_date_in := translate(p_input_date,'.-',
                                            '//');   --change every special character to '/'
        l_position1 := instr(l_date_in,'/',1,1);
        l_position2 := instr(l_date_in,'/',1,2);
        if( (instr(l_date_in,'/',1,3) <> 0) or (l_position1 = 0) )then
            l_error :=1;
        end if;
        if(l_error = 1) then
            l_field := hr_general.decode_lookup('SA_FORM_LABELS','HIJRAH_DATE');
            l_range := hr_general.decode_lookup('SA_FORM_LABELS','INVALID_FORMAT');
            hr_utility.set_message(800, 'HR_374809_SA_INVALID_DATE');
            hr_utility.set_message_token('FIELD',l_field);
            hr_utility.set_message_token('RANGE',l_range);
            hr_utility.raise_error;
        end if;
     l_year := to_number(substr(l_date_in,0,l_position1-1));
     l_month := to_number(substr(l_date_in,l_position1+1,l_position2-l_position1-1));
     l_day := to_number(substr(l_date_in,l_position2+1,l_length-l_position2));

     if(l_year<=0 or l_year >4089) then  --check if year/month/day is negative
        l_flag := 1;
        l_field := hr_general.decode_lookup('SA_FORM_LABELS','HIJRAH_YEAR');
        l_range := hr_general.decode_lookup('SA_FORM_LABELS','YEAR_RANGE');
        hr_utility.set_message(800, 'HR_374809_SA_INVALID_DATE');
        hr_utility.set_message_token('FIELD',l_field);
        hr_utility.set_message_token('RANGE',l_range);
        hr_utility.raise_error;
     end if;
     if(l_month <= 0 or l_month> 12)then
        l_flag := 2;
        l_field := hr_general.decode_lookup('SA_FORM_LABELS','HIJRAH_MONTH');
        l_range := hr_general.decode_lookup('SA_FORM_LABELS','MONTH_RANGE');
        hr_utility.set_message(800, 'HR_374809_SA_INVALID_DATE');
        hr_utility.set_message_token('FIELD',l_field);
        hr_utility.set_message_token('RANGE',l_range);
        hr_utility.raise_error;
     end if;
     if(l_day <= 0 or l_day >30)then
        l_flag := 3;
        l_field := hr_general.decode_lookup('SA_FORM_LABELS','HIJRAH_DATE');
        l_range := hr_general.decode_lookup('SA_FORM_LABELS','DATE_RANGE');
        hr_utility.set_message(800, 'HR_374809_SA_INVALID_DATE');
        hr_utility.set_message_token('FIELD',l_field);
        hr_utility.set_message_token('RANGE',l_range);
        hr_utility.raise_error;
     end if;
     if(l_year < 1000) then
        l_year_date := lpad(to_char(l_year),4,'0');
     else
        l_year_date := to_char(l_year);
     end if;
     if(l_month < 10) then
        l_month_date := lpad(to_char(l_month),2,'0');
     else
        l_month_date := to_char(l_month);
     end if;
     if(l_day < 10) then
        l_day_date := lpad(to_char(l_day),2,'0');
     else
        l_day_date := to_char(l_day);
     end if;

     p_output_date := l_year_date || '/' || l_month_date || '/' || l_day_date;

     EXCEPTION
     WHEN OTHERS
     then
         if l_flag = 0 then
            l_field := hr_general.decode_lookup('SA_FORM_LABELS','HIJRAH_DATE');
            l_range := hr_general.decode_lookup('SA_FORM_LABELS','INVALID_FORMAT');
            hr_utility.set_message(800, 'HR_374809_SA_INVALID_DATE');
            hr_utility.set_message_token('FIELD',l_field);
            hr_utility.set_message_token('RANGE',l_range);
            hr_utility.raise_error;
         elsif l_flag = 1 then
            l_field := hr_general.decode_lookup('SA_FORM_LABELS','HIJRAH_YEAR');
            l_range := hr_general.decode_lookup('SA_FORM_LABELS','YEAR_RANGE');
            hr_utility.set_message(800, 'HR_374809_SA_INVALID_DATE');
            hr_utility.set_message_token('FIELD',l_field);
            hr_utility.set_message_token('RANGE',l_range);
            hr_utility.raise_error;
         elsif l_flag = 2 then
            l_field := hr_general.decode_lookup('SA_FORM_LABELS','HIJRAH_MONTH');
            l_range := hr_general.decode_lookup('SA_FORM_LABELS','MONTH_RANGE');
            hr_utility.set_message(800, 'HR_374809_SA_INVALID_DATE');
            hr_utility.set_message_token('FIELD',l_field);
            hr_utility.set_message_token('RANGE',l_range);
            hr_utility.raise_error;
         elsif l_flag = 3 then
            l_field := hr_general.decode_lookup('SA_FORM_LABELS','HIJRAH_DATE');
            l_range := hr_general.decode_lookup('SA_FORM_LABELS','DATE_RANGE');
            hr_utility.set_message(800, 'HR_374809_SA_INVALID_DATE');
            hr_utility.set_message_token('FIELD',l_field);
            hr_utility.set_message_token('RANGE',l_range);
            hr_utility.raise_error;
         end if;

  end validate_date;

end hr_sa_hijrah_functions;

/
