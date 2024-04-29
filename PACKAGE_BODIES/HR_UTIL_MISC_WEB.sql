--------------------------------------------------------
--  DDL for Package Body HR_UTIL_MISC_WEB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_UTIL_MISC_WEB" AS
/* $Header: hrutlmsw.pkb 120.1 2005/09/23 16:01:33 svittal noship $ */

  g_debug             boolean := hr_utility.debug_enabled;
  g_package           varchar2(31)   := 'hr_util_misc_web.';
  g_owa_package       varchar2(2000) := hr_util_misc_web.g_owa||g_package;
  --
  g_image_directory           varchar2(30)  default null;
  g_html_directory            varchar2(30)  default null;

-- ------------------------------------------------------------------------
-- get_nls_parameter
-- ------------------------------------------------------------------------
FUNCTION get_nls_parameter(p_parameter in varchar2)
RETURN VARCHAR2 IS

    cursor csr_group_separator is
    select value
    from V$NLS_PARAMETERS
    where parameter = p_parameter;

    l_parameter     V$NLS_PARAMETERS.value%type;
   l_proc constant varchar2(100) := g_package || ' get_nls_parameter';


BEGIN
    --
    hr_utility.set_location('Entering: '|| l_proc,5);
    open csr_group_separator;
    fetch csr_group_separator into l_parameter;
    close csr_group_separator;
    hr_utility.set_location('Leaving: '|| l_proc,10);
    RETURN (l_parameter);

EXCEPTION
  WHEN OTHERS THEN
  hr_utility.set_location('EXCEPTION: '|| l_proc,555);
    RETURN null;

END get_nls_parameter;

-- ------------------------------------------------------------------------
-- get_currency_mask
-- ------------------------------------------------------------------------
FUNCTION get_currency_mask
RETURN VARCHAR2 IS
l_proc constant varchar2(100) := g_package || ' get_currency_mask';
BEGIN
    hr_utility.set_location('Entering: '|| l_proc,5);
    hr_utility.set_location('Leaving: '|| l_proc,10);
    RETURN (substr(get_nls_parameter('NLS_CURRENCY'),1,1));

END get_currency_mask;

-- ------------------------------------------------------------------------
-- get_group_separator
-- ------------------------------------------------------------------------
FUNCTION get_group_separator
RETURN VARCHAR2 IS
l_proc constant varchar2(100) := g_package || ' get_group_separator';
BEGIN
    hr_utility.set_location('Entering: '|| l_proc,5);
    hr_utility.set_location('Leaving: '|| l_proc,10);
    RETURN (substr(get_nls_parameter('NLS_NUMERIC_CHARACTERS'),2,1));

END get_group_separator;

-- ------------------------------------------------------------------------
-- is_valid_number
-- ------------------------------------------------------------------------
FUNCTION is_valid_number(p_number in varchar2)
RETURN BOOLEAN IS

  l_group_separator    V$NLS_PARAMETERS.value%type;
  l_number             number;
  l_proc constant varchar2(100) := g_package || ' is_valid_number';
BEGIN
    hr_utility.set_location('Entering: '|| l_proc,5);
    l_group_separator := get_group_separator;

    l_number := to_number
      (replace(p_number,substr(l_group_separator,1,1)));
     hr_utility.set_location('Leaving: '|| l_proc,10);
    RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
    hr_utility.set_location('EXCEPTION: '|| l_proc,555);
      RETURN FALSE;

END is_valid_number;

-- ------------------------------------------------------------------------
-- is_valid_currency
-- ------------------------------------------------------------------------
FUNCTION is_valid_currency(p_currency in varchar2)
RETURN BOOLEAN IS

    l_group_separator     V$NLS_PARAMETERS.value%type;
    l_currency_mask       V$NLS_PARAMETERS.value%type;
    l_number              number;
    l_proc constant varchar2(100) := g_package || ' is_valid_currency';
  BEGIN
  hr_utility.set_location('Entering: '|| l_proc,5);
    --
    l_group_separator := get_group_separator;
    l_currency_mask := get_currency_mask;

    l_number := to_number
      (replace(replace(p_currency
                      ,substr(l_group_separator,1,1))
              ,substr(l_currency_mask,1,1)));
hr_utility.set_location('Leaving: '|| l_proc,10);
    RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
     hr_utility.set_location('EXCEPTION: '|| l_proc,555);
      RETURN FALSE;

END is_valid_currency;

-- ------------------------------------------------------------------------
-- ------------------------------------------------------------------------
-- get_language_code
-- ------------------------------------------------------------------------

FUNCTION get_language_code
RETURN varchar2 IS
l_proc constant varchar2(100) := g_package || ' get_language_code';
BEGIN
   hr_utility.set_location('Entering: '|| l_proc,5);
   hr_utility.set_location('Leaving: '|| l_proc,10);
  RETURN(icx_sec.getID(icx_sec.PV_LANGUAGE_CODE));

END get_language_code;

-- ------------------------------------------------------------------------
-- get_image_directory
-- ------------------------------------------------------------------------

FUNCTION get_image_directory
RETURN varchar2 IS
l_proc constant varchar2(100) := g_package || ' get_image_directory';
BEGIN
  hr_utility.set_location('Entering: '|| l_proc,5);
  --
  IF g_image_directory IS null THEN
    g_image_directory := hr_util_misc_web.g_image_dir;
  END IF;
  --
  hr_utility.set_location('Leaving: '|| l_proc,10);
  RETURN g_image_directory;
  --
END get_image_directory;

-- ------------------------------------------------------------------------
-- get_calendar_file
-- This function is required because the cabo_calendar.html file is located
-- in different directories in r11 and r115.
-- In r11 it is in: /OA_HTML/webtools/cabo_calendar.html
-- In r115 it is in: /OA_HTML/webtools/jslib/cabo_calendar.html
-- This is for r115 release.
-- ------------------------------------------------------------------------

FUNCTION get_calendar_file
RETURN VARCHAR2 IS
l_proc constant varchar2(100) := g_package || ' get_calendar_file';
BEGIN
   hr_utility.set_location('Entering: '|| l_proc,5);
   hr_utility.set_location('Leaving: '|| l_proc,10);
  RETURN (hr_util_misc_web.g_html_dir || 'webtools/jslib/cabo_calendar.html');
END get_calendar_file;


-- ------------------------------------------------------------------------
-- get_html_directory
-- ------------------------------------------------------------------------

FUNCTION get_html_directory
RETURN varchar2 IS
l_proc constant varchar2(100) := g_package || ' get_html_directory';
BEGIN
 hr_utility.set_location('Entering: '|| l_proc,5);
  --
  IF g_html_directory IS null THEN
    g_html_directory := hr_util_misc_web.g_html_dir||get_language_code||'/';
  END IF;
  --
   hr_utility.set_location('Leaving: '|| l_proc,10);
  RETURN g_html_directory;
  --
END get_html_directory;

-- ------------------------------------------------------------------------
-- get_person_rec
-- ------------------------------------------------------------------------

FUNCTION get_person_rec(p_effective_date in varchar2
                       ,p_person_id      in number)
RETURN per_people_f%ROWTYPE IS

-----------------------------------------------------------------------------
-- Fix Bug 1615428:
-- In testing WebDB stateful mode, we found that in WF Notification
-- responsibility, the Business Group Id profile option is never set for the WF
-- Notification responsibility.  This will cause no record to return because
-- the cursor is using the per_people_f view instead of the base table.  Changed
-- the cursor to use per_all_people_f base table because if a person id is
-- passed to this function, the caller should have validation done first to
-- make sure if the person is within access or not.
-----------------------------------------------------------------------------
  CURSOR csr_pp(p_person_id in per_people_f.person_id%type
               ,p_legislation_code in varchar2) IS
  SELECT pp.business_group_id
        ,decode(p_legislation_code,'JP',pp.per_information18,pp.last_name)
         last_name
        ,decode(p_legislation_code,'JP',pp.per_information19,pp.first_name)
         first_name
        ,pp.person_type_id
        ,pp.email_address
        ,pp.title
        ,pp.full_name
   FROM  per_all_people_f pp    -- 02/09/2001 changed from per_people_f
  WHERE  pp.person_id = p_person_id;


  -----------------------------------------------------------------------------
  -- Fix Bug 1615428:
  -- Intead of calling per_per_bus.return_legislation_code to derive the
  -- legislation_code, we query legislation code here because per_per_bus api
  -- uses per_people_f view instead of per_all_people_f base table.  The view
  -- will cause no rec found error when accessed from WF Notification
  -- responsibility.  In addition, per_per_bus.return_legislation_code function
  -- uses two global variables in the package body: g_person_id and
  -- g_legislation_code which may cause obscure error when running in WebDB
  -- stateful mode.
  -- The following cursor is copied from per_per_bus.return_legislation_code
  -- with a change to the table per_all_people_f instead of per_people_f.
  -----------------------------------------------------------------------------
  cursor csr_leg_code is
    select pbg.legislation_code
      from per_business_groups      pbg
         , per_all_people_f         per
     where per.person_id         = p_person_id
       and pbg.business_group_id = per.business_group_id
       and p_effective_date between per.effective_start_date
                                and per.effective_end_date
  order by per.effective_start_date;


 -- l_proc_name  varchar2(200) default 'get_person_rec';
  l_person_rec per_people_f%ROWTYPE;
  l_legislation_code    per_business_groups.legislation_code%type default null;
  l_proc constant varchar2(100) := g_package || ' get_person_rec';

BEGIN
  hr_utility.set_location('Entering: '|| l_proc,5);
  l_legislation_code := null;
  OPEN csr_leg_code;
  hr_utility.trace('Going into Fetch after (OPEN csr_leg_code): '|| l_proc);
  FETCH csr_leg_code into l_legislation_code;
  IF csr_leg_code%NOTFOUND
  THEN
     CLOSE csr_leg_code;
     hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
     hr_utility.trace(' Exception HR_7220_INVALID_PRIMARY_KEY ');
     RAISE g_error_handled;
  ELSE
     CLOSE csr_leg_code;
  END IF;

  -- Now get the person record using the legislation code found.
  OPEN csr_pp(p_person_id => p_person_id
             ,p_legislation_code => l_legislation_code);
  hr_utility.trace('Going into Fetch after (OPEN csr_pp(p_person_id p_legislation_code )): '|| l_proc);
  FETCH csr_pp INTO l_person_rec.business_group_id
       ,l_person_rec.last_name
       ,l_person_rec.first_name
       ,l_person_rec.person_type_id
       ,l_person_rec.email_address
       ,l_person_rec.title
       ,l_person_rec.full_name;

  IF csr_pp%NOTFOUND OR csr_pp%NOTFOUND IS null THEN
    CLOSE csr_pp;
    fnd_message.set_name('PER','HR_51396_WEB_PERSON_NOT_FND');
    hr_utility.trace(' Exception HR_51396_WEB_PERSON_NOT_FND ');
    RAISE g_error_handled;
  END IF;
  CLOSE csr_pp;
  hr_utility.set_location('Leaving: '|| l_proc,20);
  RETURN (l_person_rec);
--
EXCEPTION
  WHEN others THEN
  hr_utility.set_location('EXCEPTION: '|| l_proc,555);
    hr_utility.trace(' Exception ' || sqlerrm );
    RAISE g_error_handled;
END get_person_rec;
--
-- ------------------------------------------------------------------------
-- return_msg_text
--
-- Purpose: This function can be called to return the message text which
--          can then be used for display in javascript alert or confirm box.
-- ------------------------------------------------------------------------
FUNCTION return_msg_text(p_message_name IN VARCHAR2
                        ,p_application_id IN VARCHAR2 DEFAULT 'PER')
RETURN VARCHAR2
IS
l_proc constant varchar2(100) := g_package || ' return_msg_text';
BEGIN
hr_utility.set_location('Entering: '|| l_proc,5);


  fnd_message.set_name (p_application_id, p_message_name);
  -- To fix 2095929
  --RETURN fnd_message.get;
  hr_utility.set_location('Leaving: '|| l_proc,10);
  RETURN replace(fnd_message.get,'''','\''');
END return_msg_text;
-- ----------------------------------------------------------------------------
-- |--< Get_lookup_values >---------------------------------------------------|
-- ----------------------------------------------------------------------------
FUNCTION Get_lookup_values
  ( p_lookup_type 	IN VARCHAR2
  , p_schema		IN VARCHAR2 DEFAULT 'HR'
  )
RETURN g_lookup_values_tab_type
IS
  l_array	g_lookup_values_tab_type;
  l_temp_array HR_GENERAL_UTILITIES.g_lookup_values_tab_type;
  l_proc constant varchar2(100) := g_package || ' Get_lookup_values';
--
--  l_proc	VARCHAR2 (72) := g_package || ' Get_lookup_values';
--
BEGIN
hr_utility.set_location('Entering: '|| l_proc,5);
--
  l_temp_array := HR_GENERAL_UTILITIES.Get_lookup_values
				(p_lookup_type => p_lookup_type);

  FOR i IN 1..l_temp_array.count LOOP
    l_array(i).lookup_type := l_temp_array(i).lookup_type;
    l_array(i).lookup_code := l_temp_array(i).lookup_code;
    l_array(i).meaning := l_temp_array(i).meaning;
  END LOOP;
hr_utility.set_location('Leaving: '|| l_proc,10);
  RETURN l_array;
END Get_lookup_values;
-- ----------------------------------------------------------------------------
-- ------------------------------------------------------------------------
-- ------------------------ < get_user_date_format> -----------------------
-- ------------------------------------------------------------------------
-- name:
--   get_user_date_format
--
-- description:
--   This function retrieves user's preference date format mask from
--   icx.
-- ------------------------------------------------------------------------
FUNCTION get_user_date_format
  return varchar2
  is
  l_date_fmt      varchar2(200);
  l_person_id     number;
  l_proc constant varchar2(100) := g_package || ' get_user_date_format';
  --
  begin
  hr_utility.set_location('Entering: '|| l_proc,5);
   validate_session(p_person_id => l_person_id
                   ,p_icx_update => false);
   l_date_fmt := icx_sec.getID(icx_sec.PV_DATE_FORMAT);
   --
   hr_utility.set_location('Leaving: '|| l_proc,10);
  return l_date_fmt;
  --
  Exception
  when others then
  hr_utility.set_location('EXCEPTION: '|| l_proc,555);
  hr_utility.trace(' Exception ' || sqlerrm );
    raise g_date_error;
  --
end get_user_date_format;
--
-- ---------------------------------------------------------------------------
-- ------------------------ <decode_date_lookup_code> ------------------------
-- ---------------------------------------------------------------------------
-- Usage: This function accepts input of a lookup code, a table column name
--        which must be in date data type.  This function will decode the
--        lookup code and return an expression based on the date column passed
--        in.  The expression is in the form of a sql where clause for building
--        the dynamic sql.
--
-- Input:
-- 1) p_date_compare_to_column
--    - This is the column name of a table.  It must be in date data type.
--      For example, if you want to compare the Hire Date with a calculated
--      date, the value in this parameter would be 'date_start' or
--      'ppos.date_start' (where pps is the alias for per_periods_of_service'
--      table if alias is used for the table).
--
-- 2) p_date_lookup_code
--    - The following examples depicts some of the formats represented:
--          Position
--        123456789012    Lookup Code Meaning
--        ------------    --------------------
--        001-WL-001-D    within last 1 day
--        020-WL-180-D    within last 180 days
--        200-WL-001-W    within last week
--        202-WL-050-W    within last 50 weeks
--        400-WL-001-M    within last 1 month
--        403-WL-003-M    within last 3 months
--        406-WL-006-M    within last 6 months
--        700-WL-001-Y    within last 1 year
--        710-WL-010-Y    within last 10 years
--
--        001-WN-001-D    within next 1 day
--        020-WN-180-D    within next 180 days
--        200-WN-001-W    within next week
--        202-WN-050-W    within next 50 weeks
--        400-WN-001-M    within next 1 month
--        403-WN-003-M    within next 3 months
--        406-WN-006-M    within next 6 months
--        700-WN-001-Y    within next 1 year
--        710-WN-010-Y    within next 10 years
--
--        001-MP-001-D    more than 1 day in the past
--        020-MP-180-D    more than 180 days in the past
--        200-MP-001-W    more than 1 week in the past
--        202-MP-050-W    more than 50 weeks in the past
--        400-MP-001-M    more than 1 month in the past
--        403-MP-003-M    more than 3 months in the past
--        406-MP-006-M    more than 6 months in the past
--        700-MP-001-Y    more than 1 year in the past
--        710-MP-010-Y    more than 10 years in the past
--
--        001-MF-001-D    more than 1 day in the future
--        020-MF-180-D    more than 180 days in the future
--        200-MF-001-W    more than 1 week in the future
--        202-MF-050-W    more than 50 weeks in the future
--        400-MF-001-M    more than 1 month in the future
--        403-MF-003-M    more than 3 months in the future
--        406-MF-006-M    more than 6 months in the future
--        700-MF-001-Y    more than 1 year in the future
--        710-MF-010-Y    more than 10 years in the future
--
--    Position Meaning
--    -----------------------------------------------------------------------
--    1-3  Collating Sequence
--         Numeric collating sequence for sorting the lookup code. The numeric
--         values are from 000 to 999.  The lookup codes are sorted in
--         ascending order of this collating sequence.
--         These collating sequence digits are used in display page. They are
--         ignored by this function.
--
--    4    delimiter
--
--    5-6  Time Period
--         WL -> within last, specifies a range from a calculated date to
--               either today's date or some effective date
--
--         WN -> within next, specifies a range from either today's date or
--               some effective date to a calculated date.
--
--         MP -> more than x (days, weeks, months, or years) in the past.
--
--         MF -> more than x (days, weeks, months, or years) in the future.
--
--    7    delimiter
--
--    8-10 Length of Time
--         999 -> numeric values from 001 thru 999
--
--    11   delimiter
--
--    12   Unit of Time
--         D -> day
--         W -> week
--         M -> month
--         Y -> year
--
--    NOTE: This function does not support quarter at this time.
--
-- 3) p_effective_date
--    This parameter is optional.  If it is not passed in, it will use sysdate
--    (subtract or add) to derive the calculated the date.  Otherwise, it will
--    use the date passed in.
--
-- Output:
-- ------
-- varchar2
--  - an expression in the form like, for example:
--       Lookup Code  Expression
--       ------------ -------------------------------------------------------
--       710-WL-010-Y ppos.date_start >= add_months(trunc(sysdate), -10*12)
--                    and ppos.date_start <= trunc(sysdate)
--
--       710-MP-010-Y ppos.date_start < add_months(trunc(sysdate), -10*12)
--
--       710-WN-010-Y ppos.date_start >= trunc(sysdate) and
--                    ppos.date_start <= add_months(trunc(sysdate), 10*12)
--
--       710-MF-010-Y ppos.date_start >= add_months(trunc(sysdate), 10*12)
--
-- ---------------------------------------------------------------------------
Function decode_date_lookup_code
         (p_date_compare_to_column  in varchar2 default null
         ,p_date_lookup_code        in varchar2
         ,p_effective_date          in date default trunc(sysdate))
 return varchar2 is
  --
  l_date_lookup_code    varchar2(30) default null;
  l_sql_expression      varchar2(2000) default null;
  l_date_range          varchar2(10) default null;
  l_length_of_time_char varchar2(10) default null;
  l_length_of_time      number(15) default null;
  l_unit_of_time        varchar2(10) default null;
  l_months              number(15) default null;
  l_effective_date      date default null;
  l_effective_date_exp  varchar2(2000) default null;
  l_calculated_date     date default null;
  l_calculated_date_exp varchar2(2000) default null;
  l_date_format         varchar2(200) default null;
  l_proc constant varchar2(100) := g_package || ' decode_date_lookup_code';
  --
Begin
   hr_utility.set_location('Entering: '|| l_proc,5);
  --
  IF p_date_lookup_code is null or p_date_compare_to_column is null THEN
     goto done;
  END IF;
  --
  -- get ICX user date format
  l_date_format := get_user_date_format;
  --
  IF p_effective_date is null THEN
     l_effective_date := trunc(sysdate);
  ELSE
     l_effective_date := p_effective_date;
  END IF;
  --
  -- -------------------------------------------------------------------------
  -- Build the effective date sql expression first.
  -- -------------------------------------------------------------------------
  l_effective_date_exp := build_date2char_expression
                          (p_date         => l_effective_date
                          ,p_date_format  => l_date_format);
  --
  -- Ignore the first 3 collating digits and the delimiter.
  l_date_lookup_code := substr(p_date_lookup_code, 5);
  --
  -- Now the lookup code would look like XX-999-X
  l_date_range := substr(l_date_lookup_code, 1, 2);
  l_length_of_time_char := substr(l_date_lookup_code, 4, 3);
  --
  -- Convert the length of time to numeric
  l_length_of_time := to_number(l_length_of_time_char);
  --
  l_unit_of_time := substr(l_date_lookup_code, 8);
  --
  IF upper(l_date_range) = 'WL' or upper(l_date_range) = 'MP' THEN
  hr_utility.trace('In(  IF upper(l_date_range) = WL or upper(l_date_range) = MP): '|| l_proc);
     -- 'WL' -> Within Last
     -- 'MP' -> more than x(days, weeks, months, years) in the past
     -- We need to subtract the calculated date from the p_effective_date for
     -- either 'WL' or 'MP'
     IF upper(l_unit_of_time) = 'D' THEN  -- Days
        l_calculated_date := l_effective_date - l_length_of_time;
     ELSIF upper(l_unit_of_time) = 'W' THEN -- Weeks
        l_calculated_date := l_effective_date - l_length_of_time * 7;
     ELSIF upper(l_unit_of_time) = 'M' THEN -- Months
        l_calculated_date := add_months(l_effective_date,-(l_length_of_time));
     ELSIF upper(l_unit_of_time) = 'Y' THEN -- Years
        l_calculated_date :=
                  add_months(l_effective_date,-(l_length_of_time * 12));
     END IF;
     --
     --------------------------------------------------------------------------
     -- Construct the sql clause:
     -- For example: p_date_compare_to_column = 'ppos.date_start'
     --              p_effective_date is null
     --              p_lookup_code = '710WL010Y'
     --              where l_calculated_date=add_months(trunc(sysdate), -10*12)
     --
     --              l_sql_expression = 'ppos.date_start between '||
     --                                 l_calculated_date ||
     --                                 ' and trunc(sysdate)'
     --
     -- Need to call a function to convert the date to char first and then
     -- use to_date('05-Aug-1998', 'dd-mon-rrrr') in the sql expression.
     -- Otherwise, we would have created an expression like
     -- 'ppos.hire_date >= 05-FEB-98 and ppos.hire_date <= 05-AUG-98' which
     -- will cause invalid data type error because '05-FEB-98' is not in date
     -- data type.
     -- We need to get the date to char expression for the calculated first.
     --------------------------------------------------------------------------
     --
     l_calculated_date_exp := build_date2char_expression
                              (p_date           => l_calculated_date
                              ,p_date_format    => l_date_format);
     --
     IF upper(l_date_range) = 'WL' THEN
        l_sql_expression := p_date_compare_to_column || ' between '
                      || l_calculated_date_exp
                      || ' and ' || l_effective_date_exp;
     ELSE
        l_sql_expression := p_date_compare_to_column || ' < '
                      || l_calculated_date_exp;
     END IF;
  ELSE
    hr_utility.trace('In else of (  IF upper(l_date_range) = WL or upper(l_date_range) = MP): '|| l_proc);
       IF upper(l_date_range) = 'WN' or upper(l_date_range) = 'MF' THEN
        -- 'WN' -> Within Next
        -- 'MP' -> more than x(days, weeks, months, years) in the future
        -- We need to add the calculated date from the p_effective_date for
        -- either 'WN' or 'MF'
        --
        IF upper(l_unit_of_time) = 'D' THEN  -- Days
           l_calculated_date := l_effective_date + l_length_of_time * 2;
        ELSIF upper(l_unit_of_time) = 'W' THEN -- Weeks
           l_calculated_date := l_effective_date + l_length_of_time * 7;
        ELSIF upper(l_unit_of_time) = 'M' THEN -- Months
           l_calculated_date := add_months(l_effective_date, l_length_of_time);
        ELSIF upper(l_unit_of_time) = 'Y' THEN -- Years
           l_calculated_date :=
                  add_months(l_effective_date, l_length_of_time * 12);
        END IF;
        --
        l_calculated_date_exp := build_date2char_expression
                              (p_date           => l_calculated_date
                              ,p_date_format    => l_date_format);
        --
        IF upper(l_date_range) = 'WN' THEN
           l_sql_expression := p_date_compare_to_column || ' between '
                      || l_effective_date_exp
                      || ' and ' || l_calculated_date_exp;
        ELSE
           l_sql_expression := p_date_compare_to_column || ' >= '
                      || l_calculated_date_exp;
        END IF;
        --
     END IF;
  END IF;
  --
  <<done>>
  hr_utility.set_location('Leaving: '|| l_proc,15);
  return l_sql_expression;
  --
End decode_date_lookup_code;
--
-- ---------------------------------------------------------------------------
-- ------------------------ <build_date2char_expression>----------------------
-- ---------------------------------------------------------------------------
-- This function will convert the input date parameter to character first and
-- then construct an sql expression which can be included in a dynamic sql
-- clause.
-- ---------------------------------------------------------------------------
Function build_date2char_expression(p_date        in date
                                   ,p_date_format in varchar2)
  return varchar2 is
  --
  l_date_char             varchar2(100) default null;
  l_date2char_exp        varchar2(2000) default null;
  --
  l_proc constant varchar2(100) := g_package || ' build_date2char_expression';
Begin
hr_utility.set_location('Entering: '|| l_proc,5);
  --Convert the incoming date to character format first using the passed in
  --date format.
  l_date_char := to_char(p_date, p_date_format);
  --
  ---------------------------------------------------------------------------
  -- chr(39) is single quote.
  -- The following construct the string:
  --  "to_date(''05-AUG-1998'', ''DD-MON-RRRR'')"
  --
  -- 05-MAY-1999
  -- Changed by skamatka for Bug# 884748
  -- Can't use chr functions!
  ---------------------------------------------------------------------------
  --
  l_date2char_exp := 'to_date(' ||
		     '''' ||
		      l_date_char ||
		     '''' ||
                     ', ' ||
		     '''' ||
		     p_date_format ||
		     '''' ||
                     ')';
  --
  hr_utility.set_location('Leaving: '|| l_proc,10);
  return l_date2char_exp;
  --
  EXCEPTION
    When others THEN
      hr_utility.set_location('EXCEPTION: '|| l_proc,555);
      hr_utility.trace(' Exception ' || sqlerrm );
      raise g_date_error;
  --
END build_date2char_expression;
--
-- ---------------------------------------------------------------------------
-- ------------------------ <validate_date_lookup_code> ----------------------
-- ---------------------------------------------------------------------------
-- This function will validate the date lookup code passed in to make sure that
-- the lookup code conforms to the pre-defined format.  Any incorrect lookup
-- codes will be written to the error stack.  The correct format will be
-- written to a record structure and return to the caller.
-- ---------------------------------------------------------------------------
--
Function validate_date_lookup_code
         (p_lookup_type            in varchar2
         ,p_effective_date         in date default trunc(sysdate))
  return hr_util_misc_web.g_lookup_values_tab_type  is
  --
  cursor   get_lookup_code_meaning is
  select   lookup_code, meaning
  from     hr_lookups
  where    lookup_type = p_lookup_type
  and      enabled_flag = 'Y'
  and      nvl(p_effective_date, trunc(sysdate))
  between  nvl(start_date_active,hr_api.g_sot)
  and      nvl(end_date_active,hr_api.g_eot)
  order by lookup_code;
  --
  l_lookup_code_meaning_row      get_lookup_code_meaning%rowtype;
  l_lookup_code_meaning_rec_tbl  hr_util_misc_web.g_lookup_values_tab_type
                         default hr_util_misc_web.g_lookup_values_tab_default;
  l_index  binary_integer        default 0;
  l_length                       number default 0;
  l_time_period                  varchar2(10) default null;
  l_length_of_time               varchar2(10) default null;
  l_unit_of_time                 varchar2(10) default null;
  l_number                       number default 0;
  l_date_error                   varchar2(1) default null;
  l_msg_text                     varchar2(2000) default null;
  l_msg_text2                    varchar2(2000) default null;
  l_proc constant varchar2(100) := g_package || ' validate_date_lookup_code';
  --
Begin
 hr_utility.set_location('Entering: '|| l_proc,5);
  --
  IF p_lookup_type is null THEN
     -- issue error
     fnd_message.set_name('PER','HR_WEB_INVALID_DATE_LKUP_CODE');
     l_msg_text := fnd_message.get;
     --
     fnd_message.set_name('PER','HR_WEB_INVALID_DATE_LKUP_TOKEN');
     fnd_message.set_token('LOOKUP_TYPE', p_lookup_type);
     fnd_message.set_token('LOOKUP_CODE'
                          ,l_lookup_code_meaning_row.lookup_code);
     l_msg_text2 := fnd_message.get;
     l_length := instr(l_msg_text2, '(');
     l_msg_text := l_msg_text || substr(l_msg_text2, l_length);
     --
     hr_errors_api.addErrorToTable
                  (p_errorcode   => ' '
                  ,p_errormsg    => l_msg_text);
     --
     goto done;
  END IF;
  --
  OPEN get_lookup_code_meaning;
  LOOP
   hr_utility.trace('Going into Fetch after (OPEN get_lookup_code_meaning ): '|| l_proc);
    FETCH get_lookup_code_meaning into l_lookup_code_meaning_row;
    exit when get_lookup_code_meaning%NOTFOUND;
    -------------------------------------------------------------------------
    -- We want to capture all the errors for each component of the code.  Hence,
    -- we need to set a switch to continue on and that switch will be checked
    -- at the last component.  If the switch is null, then we write the lookup
    -- code to the record structure table.
    --------------------------------------------------------------------------
    l_date_error := null;
    --
    l_index := l_index + 1;
    --
    -- Validate the lookup format, which must be in '999-XX-999-X' format.
    l_length := length(l_lookup_code_meaning_row.lookup_code);
    IF l_length <> 12 THEN
       l_date_error := 'Y';
       goto check_if_err_found;
    END IF;
    --
    l_time_period := substr(l_lookup_code_meaning_row.lookup_code, 5, 2);
    l_length_of_time := substr(l_lookup_code_meaning_row.lookup_code, 8, 3);
    l_unit_of_time := substr(l_lookup_code_meaning_row.lookup_code, 12, 1);
    --
    BEGIN  -- Time Period block
      IF upper(l_time_period) = 'WL' or
         upper(l_time_period) = 'WN' or
         upper(l_time_period) = 'MP' or
         upper(l_time_period) = 'MF' THEN
         null;
      ELSE
         raise hr_util_misc_web.g_invalid_time_period;
      END IF;
      --
      EXCEPTION
        WHEN g_invalid_time_period THEN
             hr_utility.set_location('EXCEPTION: '|| l_proc,555);
             l_date_error := 'Y';
             goto check_if_err_found;
             --
        WHEN others THEN
             hr_utility.set_location('EXCEPTION: '|| l_proc,560);
             l_date_error := 'Y';
             goto check_if_err_found;

    END;  -- End Time Period block
    --
    BEGIN
      l_number := to_number(l_length_of_time);
      --
      -- IF l_length_of_time contains non-numeric values, it will issue
      -- "ORA-06502: PL/SQL: numeric or value error".
      --
      Exception
         When others THEN
             hr_utility.set_location('EXCEPTION: '|| l_proc,565);
            l_date_error := 'Y';
           goto check_if_err_found;

    END;
    --
    BEGIN
      IF upper(l_unit_of_time) = 'D' or
         upper(l_unit_of_time) = 'W' or
         upper(l_unit_of_time) = 'M' or
         upper(l_unit_of_time) = 'Y' THEN
         --
         IF l_date_error is null THEN
            l_lookup_code_meaning_rec_tbl(l_index).lookup_code :=
                            l_lookup_code_meaning_row.lookup_code;
            --
            l_lookup_code_meaning_rec_tbl(l_index).meaning :=
                            l_lookup_code_meaning_row.meaning;
         END IF;
      ELSE
         raise hr_util_misc_web.g_invalid_time_unit;
      END IF;
      --
      Exception
        WHEN g_invalid_time_unit THEN
        hr_utility.set_location('EXCEPTION: '|| l_proc,570);
          l_date_error := 'Y';
          goto check_if_err_found;

    END;
    --
    <<check_if_err_found>>
    --
    IF l_date_error = 'Y' THEN
       fnd_message.set_name('PER','HR_WEB_INVALID_DATE_LKUP_CODE');
       l_msg_text := fnd_message.get;
       --
       fnd_message.set_name('PER','HR_WEB_INVALID_DATE_LKUP_TOKEN');
       fnd_message.set_token('LOOKUP_TYPE', p_lookup_type);
       fnd_message.set_token('LOOKUP_CODE'
                           ,l_lookup_code_meaning_row.lookup_code);
       l_msg_text2 := fnd_message.get;
       l_length := instr(l_msg_text2, '(');
       l_msg_text := l_msg_text || substr(l_msg_text2, l_length);
       --
       hr_errors_api.addErrorToTable
                       (p_errorcode   => ' '
                       ,p_errormsg    => l_msg_text);
    END IF;
    --

  END LOOP;
  --
  <<done>>
  hr_utility.set_location('Leaving: '|| l_proc,15);
  return l_lookup_code_meaning_rec_tbl;
  --
  Exception
    When others THEN
     hr_utility.set_location('EXCEPTION: '|| l_proc,575);
      -- Add error to error table
      fnd_message.set_name('PER','HR_WEB_INVALID_DATE_LKUP_CODE');
      l_msg_text := fnd_message.get;
      --
      fnd_message.set_name('PER','HR_WEB_INVALID_DATE_LKUP_TOKEN');
      fnd_message.set_token('lookup_type', p_lookup_type);
      fnd_message.set_token('lookup_code'
                           ,l_lookup_code_meaning_row.lookup_code);
      l_msg_text2 := fnd_message.get;
      l_length := instr(l_msg_text2, '(');
      l_msg_text := l_msg_text || substr(l_msg_text2, l_length);
      --
      hr_errors_api.addErrorToTable
                   (p_errorcode   => ' '
                   ,p_errormsg    => l_msg_text);

END validate_date_lookup_code;
--
-- ------------------------------------------------------------------------
-- insert_session_row
--
-- Description:
--   This procedure insert a record into the fnd_sessions table so that we
--   may select data from date-tracked tables.  It's over-loaded to accept a
--   date field or a varchar2 encrypted date.  It also checks the user's
--   security
--
-- Updated for bug 1994945
-- ------------------------------------------------------------------------
PROCEDURE insert_session_row(p_effective_date in date) IS
 --
  l_proc varchar2(100) := g_package || 'insert_session_row';
 --
BEGIN
    hr_utility.set_location('Entering: '|| l_proc,5);
    --
  /* g_debug := hr_utility.debug_enabled;
  if g_debug then
  l_proc := g_package || 'insert_session_row';
  hr_utility.set_location('Entering : ' || l_proc, 5);
  end if; */
  --
  dt_fndate.set_effective_date(trunc(p_effective_date));
  --
  /* if g_debug then
  hr_utility.set_location('Leaving : ' || l_proc, 10);
  end if; */
  --
    hr_utility.set_location('Leaving: '|| l_proc,10);
EXCEPTION
  WHEN others THEN
  hr_utility.set_location('EXCEPTION: '|| l_proc,555);
    null;
END insert_session_row;

-- ------------------------------------------------------------------------
-- autonomous_commit_fnd_sess_row
--
-- Description:
--   This procedure inserts a record into the fnd_sessions table so that we
--   may select data from date-tracked tables.  It also checks the user's
--   security.
--   This procedure returns an output parameter on session_id to aid debugging,
--   especially when the caller is a Java program.
--
-- Updated for bug 1940440
-- ------------------------------------------------------------------------
PROCEDURE autonomous_commit_fnd_sess_row
     (p_effective_date    in  date
     ,p_session_id        out nocopy number)
IS

   PRAGMA AUTONOMOUS_TRANSACTION;
 --

  -- 09/18/2001 SRAMASAMY advised to select from dual instead of
  -- using 'select session_id from fnd_sessions where userenv('sessionid') =
  -- FND_SESSIONS.session_id' because of the hit on fnd_sessions table.
  CURSOR get_session_id IS
  SELECT userenv('sessionid')
  FROM   dual;

  l_session_id        number default null;
  l_proc constant varchar2(100) := g_package || ' autonomous_commit_fnd_sess_row';


BEGIN

  --
  g_debug := hr_utility.debug_enabled;
  if g_debug then
  --l_proc := g_package || 'insert_session_row';
  hr_utility.set_location('Entering : ' || l_proc, 5);
  end if;
  --
  dt_fndate.set_effective_date(trunc(p_effective_date));
  --
  commit;

  -- The following select query is to retreive the session_id just created.
  -- This will aid debugging to the caller.
  OPEN get_session_id;
  hr_utility.trace('Going into Fetch after ( OPEN get_session_id): '|| l_proc);
  FETCH get_session_id into l_session_id;
  IF get_session_id%NOTFOUND
  THEN
     l_session_id := null;
  END IF;

  CLOSE get_session_id;

  p_session_id := l_session_id;

  if g_debug then
  hr_utility.set_location('Leaving : ' || l_proc, 15);
  end if;
  --
EXCEPTION
  WHEN others THEN
  hr_utility.set_location('EXCEPTION: '|| l_proc,555);
    rollback;
    raise;
END autonomous_commit_fnd_sess_row;


PROCEDURE remove_session_row IS

  l_person_id  per_people_f.person_id%type;
  l_proc constant varchar2(100) := g_package || ' remove_session_row';
BEGIN
  hr_utility.set_location('Entering: '|| l_proc,5);
  delete from fnd_sessions
  where session_id = userenv('sessionid');
  hr_utility.set_location('Leaving : ' || l_proc, 10);
EXCEPTION
  WHEN others THEN
    hr_utility.set_location('EXCEPTION: '|| l_proc,555);
    raise;
END remove_session_row;

-- ------------------------------------------------------------------------
-- validate_session
--
-- Description:
--   This procedure calls the Internet Commerce security routine that check
--   that the user has a full, appropriate 'cookie' for their web session.
--   It also obtains the Person_Id of the user.
-- ------------------------------------------------------------------------

PROCEDURE validate_session(p_person_id  out nocopy    number
                          ,p_check_ota  in   varchar2 default 'N'
                          ,p_check_ben  in   varchar2 default 'N'
                          ,p_check_pay  in   varchar2 default 'N'
                          ,p_icx_update in   boolean default true
                          ,p_icx_commit in   boolean default false) IS
--
  l_web_username  varchar2(80) default null;
  l_person_id     per_people_f.person_id%type;
  l_proc constant varchar2(100) := g_package || ' validate_session';
--
BEGIN
  hr_utility.set_location('Entering: '|| l_proc,5);
  hr_util_misc_web.validate_session
              (p_person_id    => l_person_id
              ,p_web_username => l_web_username
              ,p_check_ota    => p_check_ota
              ,p_check_ben    => p_check_ben
              ,p_check_pay    => p_check_pay
              ,p_icx_update   => p_icx_update
              ,p_icx_commit   => p_icx_commit);
  p_person_id := l_person_id;
    hr_utility.set_location('Leaving : ' || l_proc, 10);
EXCEPTION
  WHEN OTHERS THEN
  hr_utility.set_location('EXCEPTION: '|| l_proc,555);
  NULL;
END validate_session;

PROCEDURE validate_session(p_person_id  out nocopy  number
                          ,p_web_username out nocopy  varchar2
                          ,p_check_ota    in   varchar2 default 'N'
                          ,p_check_ben    in   varchar2 default 'N'
                          ,p_check_pay    in   varchar2 default 'N'
                          ,p_icx_update   in   boolean  default true
                          ,p_icx_commit   in   boolean  default false) IS

  CURSOR  csr_hr_installation_status(p_application_id number) IS
  SELECT  fpi.status status
    FROM  fnd_product_installations fpi
   WHERE  fpi.application_id = p_application_id;

  l_web_user_id   number;
  l_web_username  varchar2(80) default null;

  l_cookie        owa_cookie.cookie;
  l_person_id     per_people_f.person_id%TYPE;
  l_hr_installation_status	fnd_product_installations.status%TYPE default null;
  l_proc constant varchar2(100) := g_package || ' validate_session';

BEGIN
  hr_utility.set_location('Entering: '|| l_proc,5);
  IF NOT(icx_sec.validateSession(c_update => p_icx_update
                                ,c_commit => p_icx_commit)) THEN
    RAISE g_error_handled;
  ELSE
    -- ensure HR is fully installed
    -- If not then raise an error
    OPEN csr_hr_installation_status(p_application_id => 800);
    hr_utility.trace('Going into Fetch after(OPEN csr_hr_installation_status(p_application_id 800) ): '|| l_proc);
    FETCH csr_hr_installation_status into l_hr_installation_status;
    CLOSE csr_hr_installation_status;
    IF NOT l_hr_installation_status = 'I' THEN
        --
        fnd_message.set_name('PER', 'HR_7079_HR_NOT_INSTALLED');
        RAISE g_no_app_error;
    END IF;
    --
    IF p_check_ota = 'Y' THEN
      -- ensure ota is fully installed
      -- If not then raise an error
      OPEN csr_hr_installation_status(p_application_id => 810);
      hr_utility.trace('Going into Fetch after(OPEN csr_hr_installation_status(p_application_id 810) ): '|| l_proc);
      FETCH csr_hr_installation_status into l_hr_installation_status;
      CLOSE csr_hr_installation_status;
      IF NOT l_hr_installation_status = 'I' THEN
          --
          fnd_message.set_name('OTA','OTA_13629_WEB_OTA_NOT_INSTALL');
          RAISE g_no_app_error;
      END IF;
    END IF;
    IF p_check_ben = 'Y' THEN
      -- ensure benefits is fully installed
      -- If not then raise an error
      -- We don't know the benefits number yet...must change that here:
      OPEN csr_hr_installation_status(p_application_id => 1234);
      hr_utility.trace('Going into Fetch after( OPEN csr_hr_installation_status(p_application_id => 1234)) ): '|| l_proc);
      FETCH csr_hr_installation_status into l_hr_installation_status;
      CLOSE csr_hr_installation_status;
      IF NOT l_hr_installation_status = 'I' THEN
          --
          -- We don't have a abbrev or message yet, chang that here:
          fnd_message.set_name('BEN','BEN_???_BEN_NOT_INSTALLED');
          RAISE g_no_app_error;
      END IF;
    END IF;
    IF p_check_pay = 'Y' THEN
      -- ensure Payroll is fully installed
      -- If not then raise an error
      OPEN csr_hr_installation_status(p_application_id => 801);
      hr_utility.trace('Going into Fetch after(OPEN csr_hr_installation_status(p_application_id => 801) ): '|| l_proc);
      FETCH csr_hr_installation_status into l_hr_installation_status;
      CLOSE csr_hr_installation_status;
      IF NOT l_hr_installation_status = 'I' THEN
          --
          -- We don't have a abbrev or message yet, chang that here:
          fnd_message.set_name('PAY','PAY_78031_PAY_NOT_INSTALLED');
          RAISE g_no_app_error;
      END IF;
    END IF;

     --
      -- getid with a parm of 10 returns the web user id.
      -- we don't need this id in our code, but getid
      -- also returns a -1 into the web user id if we are in
      -- a psuedo session situation:  this we do need to know
      -- so that we can manually get the person information when
      -- there is a psuedo session.
    l_web_user_id := icx_sec.getID(n_param => 10);
	--
    -- determine if the web user is -1 (pseudo session)
    IF l_web_user_id = -1 THEN
          hr_utility.trace('In if( IF l_web_user_id = -1 ) ): '|| l_proc);
      -- as we are in a pseudo session get the cookie record
      -- for the cookie WF_SESSION
      l_cookie := owa_cookie.get('WF_SESSION');
      -- ensure the cookie exists
      IF l_cookie.num_vals > 0 THEN
        -- as the cookie does exist get the web username from
        -- the workflow system
        l_web_username := wf_notification.accesscheck
                            (l_cookie.vals(l_cookie.num_vals));
        --
        -- getid with a parm of 9 returns the internal-contact-id,
        l_person_id := icx_sec.getID(n_param => 9);
        --
      ELSE
        -- the WF_SESSION cookie does not exist. a serious error
        -- has ocurred which must be reported
        --
        fnd_message.set_name('PER','HR_51393_WEB_COOKIE_ERROR');
        hr_utility.trace(' Exception  HR_51393_WEB_COOKIE_ERROR ');
        RAISE g_error_handled;
      END IF;
    ELSE
      hr_utility.trace('In else of if( IF l_web_user_id = -1 ) ): '|| l_proc);
      l_person_id := icx_sec.getID(n_param => 9);
	  --
	  -- getid with a parm of 99 returns the web user name.
      l_web_username := icx_sec.getID(n_param => 99);
    END IF;
  END IF;
  p_person_id    := l_person_id;
  p_web_username := l_web_username;
  g_error_handled_var := FALSE;
  hr_utility.set_location('Leaving: '|| l_proc,40);
EXCEPTION
  WHEN g_no_app_error THEN
    hr_utility.trace(' validate_session ' || SQLERRM );
    hr_utility.set_location('EXCEPTION: '|| l_proc,555);
    raise;
  WHEN TOO_MANY_ROWS then
     hr_utility.set_location('EXCEPTION: '|| l_proc,560);
    -- too many rows will be returned if the csr_iwu returns more than
    -- one person id for the web user.
       fnd_message.set_name('PER','HR_51776_WEB_TOO_MANY_USERS');
       hr_utility.trace(' Exception HR_51776_WEB_TOO_MANY_USERS ');
  WHEN g_error_handled then
  hr_utility.set_location('EXCEPTION: '|| l_proc,565);
  g_error_handled_var := TRUE;
   raise;
  WHEN others then
       hr_utility.set_location('EXCEPTION: '|| l_proc,570);
       hr_utility.trace(' Exception ' || sqlerrm );
       raise;
END validate_session;
-- ------------------------------------------------------------------------
-- prepare_parameter
--
-- Description:
--   This procedure takes in a parameter and makes it URL ready by changing
--   spaces to '+' and placing a '&' at the front of the parmameter name
--   when p_prefix is true (the parameter is not first in the list).
-- ------------------------------------------------------------------------

FUNCTION prepare_parameter(p_name   in varchar2
                          ,p_value  in varchar2
                          ,p_prefix in boolean default true)
RETURN varchar2 IS

  l_prefix varchar2(1);
  l_proc constant varchar2(100) := g_package || ' prepare_parameter';

BEGIN
 hr_utility.set_location('Entering: '|| l_proc,5);
  IF p_value IS NOT null THEN
    IF p_prefix THEN
       l_prefix := '&';
    END IF;
       hr_utility.set_location('Leaving: '|| l_proc,10);
    RETURN(l_prefix||p_name||'='||replace(p_value, ' ', '+'));
  ELSE
     hr_utility.set_location('Leaving: '|| l_proc,20);
    RETURN(null);
  END IF;
END prepare_parameter;
-------------------------------------------------------------------------------
-- This function will append the given url to the
-- value returned from get_owa_url to get a complete url.
-- If no URL is passed to this function then the owa URL
-- is returned.
-------------------------------------------------------------------------------
FUNCTION get_complete_url(p_url IN VARCHAR2 DEFAULT NULL) RETURN LONG IS
l_url LONG;
l_proc constant varchar2(100) := g_package || ' get_complete_url';
BEGIN
    hr_utility.set_location('Entering: '|| l_proc,5);
	IF p_url IS NOT NULL THEN
		l_url := hr_util_misc_web.get_owa_url || p_url;
	ELSE
		l_url := hr_util_misc_web.get_owa_url;
	END IF;
hr_utility.set_location('Leaving: '|| l_proc,10);
	RETURN l_url;
END get_complete_url;

-- This function will return a url with following format
-- http://<hostname>:<server port>/<DAD NAME>/<PLSQL AGENT NAME>/
-- e.g. http://myhost.com:1234/test/owa/

FUNCTION get_owa_url RETURN VARCHAR2 IS
l_owa VARCHAR2(2000);
l_proc constant varchar2(100) := g_package || ' get_owa_url';
BEGIN
    hr_utility.set_location('Entering: '|| l_proc,5);
 -- Fix for bug 894682
	l_owa := FND_WEB_CONFIG.PLSQL_AGENT;
	hr_utility.set_location('Leaving: '|| l_proc,10);
	RETURN l_owa;
END get_owa_url;

-- ------------------------------------------------------------------------
-- get_resume
-- ------------------------------------------------------------------------
-- This procedure is used in 'Apply for Job' and 'Professional Info' Modules
-- Duplicated from hrcustwf.pkb (hr_offer_custom)

procedure get_resume
		(p_person_id IN NUMBER DEFAULT NULL
		,p_resume out nocopy varchar2
		,p_rowid out nocopy varchar2
                ,p_creation_date out nocopy varchar2) is
  --
  l_person_id                 per_people_f.person_id%type;
  l_resume_from_database      varchar2(32000);
  l_attached_document_id  fnd_attached_documents.attached_document_id%TYPE
                          default null;
  l_document_id           fnd_documents.document_id%TYPE default null;
  l_media_id              fnd_documents_tl.media_id%TYPE default null;
  l_attachment_text       long default null;
  l_rowid                 varchar2(50) default null;
  l_category_id           fnd_documents.category_id%type default null;
  l_seq_num               fnd_attached_documents.seq_num%type default 0;
  l_creation_date         fnd_documents_tl.creation_date%TYPE default null;
  l_proc constant varchar2(100) := g_package || ' get_resume';
begin
 hr_utility.set_location('Entering: '|| l_proc,5);
  ----------------------------------------------------------------------------
  -- 10/15/97
  -- The following validate_session is not for security check because this
  -- procedure is not registered in fnd_enabled_plsql table.  The real reason
  -- is for retrieving the login person_id for use in later calls to other
  -- procedures.
  ----------------------------------------------------------------------------
  ----------------------------------------------------------------------------
  -- 12-SEP-1998
  -- If person id is passed then, reusme for this person is fetched else,
  -- resume for the logged in person is retrieved.
  ----------------------------------------------------------------------------
  IF p_person_id IS NULL THEN
  	hr_util_misc_web.validate_session(p_person_id   => l_person_id
                              ,p_icx_update  => false     -- 10/15/97 Changed
                              ,p_icx_commit  => false);   -- 10/15/97 Changed
  ELSE
	l_person_id := p_person_id;
  END IF;
  --
  --get resume from database
  --
  -- Bug #1180110 Fix
  -- Changed the p_entity_name to use 'PER_PEOPLE_F' so that the Resume
  -- category attachment can be viewed via Forms.

  get_attachment
     (p_attachment_text       => l_resume_from_database
     ,p_entity_name           => 'PER_PEOPLE_F'
     ,p_pk1_value             => to_char(l_person_id)
     ,p_effective_date        => sysdate
     ,p_attached_document_id  => l_attached_document_id
     ,p_document_id           => l_document_id
     ,p_media_id              => l_media_id
     ,p_rowid                 => l_rowid
     ,p_category_id           => l_category_id
     ,p_seq_num               => l_seq_num
     ,p_user_name             => 'HR_RESUME'
     ,p_creation_date         => l_creation_date);
  p_resume := l_resume_from_database;
  p_rowid := l_rowid;
  p_creation_date := l_creation_date;
  --
  hr_utility.set_location('Leaving: '|| l_proc,10);
  EXCEPTION
  WHEN OTHERS THEN
     hr_utility.set_location('EXCEPTION: '|| l_proc,555);
     -- an error has occurred but because we are producing HTML
     -- just raise the exception
     p_resume := null;
     p_rowid := null;
     hr_utility.trace(' Exception ' || sqlerrm);
     raise;
end get_resume;


procedure insert_attachment_v4
          (p_attachment_text    in long default null
          ,p_entity_name        in varchar2 default null
          ,p_pk1_value          in varchar2 default null
          ,p_name               in fnd_document_categories_tl.name%TYPE
          ,p_rowid              out nocopy varchar2
          ,p_login_person_id   in  number) is

  l_attached_document_id  fnd_attached_documents.attached_document_id%TYPE;
  l_document_id           fnd_documents.document_id%TYPE;
  l_media_id              fnd_documents_tl.media_id%TYPE;
  l_proc constant varchar2(100) := g_package || ' insert_attachment_v4';
begin
  hr_utility.set_location('Entering: '|| l_proc,5);
  insert_attachment
    (p_attachment_text => p_attachment_text
    ,p_entity_name => p_entity_name
    ,p_pk1_value => p_pk1_value
    ,p_name => p_name
    ,p_rowid => p_rowid
    ,p_login_person_id => p_login_person_id
    ,p_attached_document_id => l_attached_document_id
    ,p_document_id => l_document_id
    ,p_media_id => l_media_id);
  hr_utility.set_location('Leaving: '|| l_proc,10);
end insert_attachment_v4;
-- ----------------------------------------------------------------------------
-- |--------------------------< insert_attachment >----------------------------|
-- ----------------------------------------------------------------------------
-- Duplicated from hrcustwf.pkb (hr_offer_custom)
procedure insert_attachment
          (p_attachment_text    in long default null
          ,p_entity_name        in varchar2 default null
          ,p_pk1_value          in varchar2 default null
          ,p_name               in fnd_document_categories_tl.name%TYPE
                                   default 'HR_RESUME'
          ,p_attached_document_id  out
              fnd_attached_documents.attached_document_id%TYPE
          ,p_document_id           out
              fnd_documents.document_id%TYPE
          ,p_media_id              out
              fnd_documents_tl.media_id%TYPE
          ,p_rowid                 out nocopy varchar2
          ,p_login_person_id   in  number) is   -- 10/14/97 Changed

  -- [CUSTOMIZE]
  -- Call fnd_attached_documents_pkg.insert_row api to insert into fnd_documents
  -- table.  If customer uses third party software to store the resume, modify
  -- the code here.

  l_rowid                  varchar2(50) default null;
  l_media_id               fnd_documents_tl.media_id%TYPE;
  l_attached_document_id   fnd_attached_documents.attached_document_id%TYPE
                             default null;
  l_document_id            fnd_documents.document_id%TYPE default null;
  l_category_id            fnd_document_categories.category_id%TYPE
                           default null;
  l_datatype_id            fnd_document_datatypes.datatype_id%TYPE default 2;
  l_language               varchar2(30) default 'AMERICAN';
  l_seq_num                fnd_attached_documents.seq_num%type;
  l_attachment_text        long;
  l_proc constant varchar2(100) := g_package || ' insert_attachment';
  cursor csr_get_seq_num is
         select nvl(max(seq_num),0) + 10
           from fnd_attached_documents
          where entity_name = p_entity_name
            and pk1_value   = p_pk1_value
            and pk2_value is null
            and pk3_value is null
            and pk4_value is null
            and pk5_value is null;

  cursor csr_get_category_id (csr_p_lang in varchar2) is
         select category_id
           from fnd_document_categories_tl
          where language = csr_p_lang
            and name = p_name;
  --

  Begin
  hr_utility.set_location('Entering: '|| l_proc,5);
  --
  -- Get language
  select userenv('LANG') into l_language from dual;
  --
  --  Get seq num
  --
  l_seq_num := 0;
  open csr_get_seq_num;
  hr_utility.trace('Going into Fetch after ( open csr_get_seq_num): '|| l_proc);
  fetch csr_get_seq_num into l_seq_num;
  close csr_get_seq_num;
  --
  --  Get category ID
  --
  open csr_get_category_id (csr_p_lang => l_language);
  hr_utility.trace('Going into Fetch after (open csr_get_category_id (csr_p_lang => l_language)m): '|| l_proc);
  fetch csr_get_category_id into l_category_id;
  if csr_get_category_id%notfound then
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  end if;
  close csr_get_category_id;
  --
  -- get sequence id for attached_document_id
     select fnd_attached_documents_s.nextval
       into l_attached_document_id
       from sys.dual;

  -- Insert document to fnd_documents_long_text
  --
            fnd_attached_documents_pkg.insert_row
            (x_rowid                      => l_rowid
            ,x_attached_document_id       => l_attached_document_id
            ,x_document_id                => l_document_id
            ,x_creation_date              => trunc(sysdate)
            ,x_created_by                 => p_login_person_id --10/14/97Chg
            ,x_last_update_date           => trunc(sysdate)
            ,x_last_updated_by            => p_login_person_id --10/14/97Chg
            ,x_seq_num                    => l_seq_num
            ,x_entity_name                => p_entity_name
            ,x_column1                    => 'PERSON_ID'
            ,x_pk1_value                  => p_pk1_value
            ,x_pk2_value                  => null
            ,x_pk3_value                  => null
            ,x_pk4_value                  => null
            ,x_pk5_value                  => null
            ,x_automatically_added_flag   => 'N'
            ,x_datatype_id                => l_datatype_id
            ,x_category_id                => l_category_id
            ,x_security_type              => 4
            ,x_publish_flag               =>'N'
            ,x_usage_type                 =>'O'
            ,x_language                   => l_language
            ,x_media_id                   => l_media_id
            ,x_doc_attribute_category     => null
            ,x_doc_attribute1             => null
            ,x_doc_attribute2             => null
            ,x_doc_attribute3             => null
            ,x_doc_attribute4             => null
            ,x_doc_attribute5             => null
            ,x_doc_attribute6             => null
            ,x_doc_attribute7             => null
            ,x_doc_attribute8             => null
            ,x_doc_attribute9             => null
            ,x_doc_attribute10            => null
            ,x_doc_attribute11            => null
            ,x_doc_attribute12            => null
            ,x_doc_attribute13            => null
            ,x_doc_attribute14            => null
            ,x_doc_attribute15            => null);
        --

  -- Now insert into fnd_documents_long_text using the media_id
  -- generated from the above api call
  --
  --replace chr(13)chr(10) with chr(10)
  l_attachment_text := replace(p_attachment_text,
        g_carriage_return||g_line_feed,g_line_feed);
  insert into fnd_documents_long_text
    (media_id
    ,long_text)
  values
    (l_media_id
    ,l_attachment_text);

  p_attached_document_id := l_attached_document_id;
  p_document_id          := l_document_id;
  p_media_id             := l_media_id;
  p_rowid                := l_rowid;

hr_utility.set_location('Leaving: '|| l_proc,20);
  EXCEPTION
    When others then
    hr_utility.set_location('EXCEPTION: '|| l_proc,555);
         raise;
  --
end insert_attachment;

-- ----------------------------------------------------------------------------
-- |--------------------------< update_attachment >----------------------------|
-- ----------------------------------------------------------------------------
-- Duplicated from hrcustwf.pkb (hr_offer_custom)

procedure update_attachment
          (p_attachment_text    in long default null
          ,p_entity_name        in varchar2 default null
          ,p_pk1_value          in varchar2 default null
          ,p_rowid              in varchar2
          ,p_login_person_id in number) is   -- 10/14/97 Changed

  -- [CUSTOMIZE]
  -- Call fnd_attached_documents_pkg.update_row api to update fnd_documents
  -- table.  If customer uses third party software to store the resume, modify
  -- the code here.

  l_rowid                  varchar2(50);
  l_language               varchar2(30) default 'AMERICAN';
  l_attachment_text        long;
  l_proc constant varchar2(100) := g_package || ' update_attachment';
  data_error               exception;
  --
  -- -------------------------------------------------------------
  -- Get the before update nullable fields so that we can
  -- preserve the values entered in 10SC GUI after the update.
  -- -------------------------------------------------------------
  cursor csr_get_attached_doc  is
    select *
    from   fnd_attached_documents
    where  rowid = p_rowid;
  --
  cursor csr_get_doc(csr_p_document_id in number)  is
    select *
    from   fnd_documents
    where  document_id = csr_p_document_id;
  --
  cursor csr_get_doc_tl  (csr_p_lang in varchar2
                         ,csr_p_document_id in number) is
    select *
    from   fnd_documents_tl
    where  document_id = csr_p_document_id
    and    language = csr_p_lang;
  --
  l_attached_doc_pre_upd   csr_get_attached_doc%rowtype;
  l_doc_pre_upd            csr_get_doc%rowtype;
  l_doc_tl_pre_upd         csr_get_doc_tl%rowtype;
  --
  --
  Begin
  hr_utility.set_location('Entering: '|| l_proc,5);
  --
  -- Get language
  select userenv('LANG') into l_language from dual;
  --
  -- Get the before update nullable fields which are not used by the
  -- Web page to ensure the values are propagated.
     Open csr_get_attached_doc;
     hr_utility.trace('Going into Fetch after (  Open csr_get_attached_doc): '|| l_proc);
     fetch csr_get_attached_doc into l_attached_doc_pre_upd;
     IF csr_get_attached_doc%NOTFOUND THEN
        close csr_get_attached_doc;
        raise data_error;
     END IF;

     Open csr_get_doc(l_attached_doc_pre_upd.document_id);
     hr_utility.trace('Going into Fetch after ( Open csr_get_doc(l_attached_doc_pre_upd.document_id)): '|| l_proc);
     fetch csr_get_doc into l_doc_pre_upd;
     IF csr_get_doc%NOTFOUND then
        close csr_get_doc;
        raise data_error;
     END IF;

     Open csr_get_doc_tl (csr_p_lang => l_language
                      ,csr_p_document_id => l_attached_doc_pre_upd.document_id);
     hr_utility.trace('Going into Fetch after (Open csr_get_doc_tl (csr_p_lang => l_language,csr_p_document_id => l_attached_doc_pre_upd.document_id)): '|| l_proc);
     fetch csr_get_doc_tl into l_doc_tl_pre_upd;
     IF csr_get_doc_tl%NOTFOUND then
        close csr_get_doc_tl;
        raise data_error;
     END IF;

     -- Now, lock the rows.
     fnd_attached_documents_pkg.lock_row
            (x_rowid                      => p_rowid
            ,x_attached_document_id       =>
                      l_attached_doc_pre_upd.attached_document_id
            ,x_document_id                => l_doc_pre_upd.document_id
            ,x_seq_num                    => l_attached_doc_pre_upd.seq_num
            ,x_entity_name                => l_attached_doc_pre_upd.entity_name
            ,x_column1                    => l_attached_doc_pre_upd.column1
            ,x_pk1_value                  => l_attached_doc_pre_upd.pk1_value
            ,x_pk2_value                  => l_attached_doc_pre_upd.pk2_value
            ,x_pk3_value                  => l_attached_doc_pre_upd.pk3_value
            ,x_pk4_value                  => l_attached_doc_pre_upd.pk4_value
            ,x_pk5_value                  => l_attached_doc_pre_upd.pk5_value
            ,x_automatically_added_flag   =>
                    l_attached_doc_pre_upd.automatically_added_flag
            ,x_attribute_category         =>
                    l_attached_doc_pre_upd.attribute_category
            ,x_attribute1                 => l_attached_doc_pre_upd.attribute1
            ,x_attribute2                 => l_attached_doc_pre_upd.attribute2
            ,x_attribute3                 => l_attached_doc_pre_upd.attribute3
            ,x_attribute4                 => l_attached_doc_pre_upd.attribute4
            ,x_attribute5                 => l_attached_doc_pre_upd.attribute5
            ,x_attribute6                 => l_attached_doc_pre_upd.attribute6
            ,x_attribute7                 => l_attached_doc_pre_upd.attribute7
            ,x_attribute8                 => l_attached_doc_pre_upd.attribute8
            ,x_attribute9                 => l_attached_doc_pre_upd.attribute9
            ,x_attribute10                => l_attached_doc_pre_upd.attribute10
            ,x_attribute11                => l_attached_doc_pre_upd.attribute11
            ,x_attribute12                => l_attached_doc_pre_upd.attribute12
            ,x_attribute13                => l_attached_doc_pre_upd.attribute13
            ,x_attribute14                => l_attached_doc_pre_upd.attribute14
            ,x_attribute15                => l_attached_doc_pre_upd.attribute15
            ,x_datatype_id                => l_doc_pre_upd.datatype_id
            ,x_category_id                => l_doc_pre_upd.category_id
            ,x_security_type              => l_doc_pre_upd.security_type
            ,x_security_id                => l_doc_pre_upd.security_id
            ,x_publish_flag               => l_doc_pre_upd.publish_flag
            ,x_image_type                 => l_doc_pre_upd.image_type
            ,x_storage_type               => l_doc_pre_upd.storage_type
            ,x_usage_type                 => l_doc_pre_upd.usage_type
            ,x_start_date_active          => l_doc_pre_upd.start_date_active
            ,x_end_date_active            => l_doc_pre_upd.end_date_active
            ,x_language                   => l_doc_tl_pre_upd.language
            ,x_description                => l_doc_tl_pre_upd.description
            ,x_file_name                  => l_doc_tl_pre_upd.file_name
            ,x_media_id                   => l_doc_tl_pre_upd.media_id
            ,x_doc_attribute_category     =>
                          l_doc_tl_pre_upd.doc_attribute_category
            ,x_doc_attribute1             => l_doc_tl_pre_upd.doc_attribute1
            ,x_doc_attribute2             => l_doc_tl_pre_upd.doc_attribute2
            ,x_doc_attribute3             => l_doc_tl_pre_upd.doc_attribute3
            ,x_doc_attribute4             => l_doc_tl_pre_upd.doc_attribute4
            ,x_doc_attribute5             => l_doc_tl_pre_upd.doc_attribute5
            ,x_doc_attribute6             => l_doc_tl_pre_upd.doc_attribute6
            ,x_doc_attribute7             => l_doc_tl_pre_upd.doc_attribute7
            ,x_doc_attribute8             => l_doc_tl_pre_upd.doc_attribute8
            ,x_doc_attribute9             => l_doc_tl_pre_upd.doc_attribute9
            ,x_doc_attribute10            => l_doc_tl_pre_upd.doc_attribute10
            ,x_doc_attribute11            => l_doc_tl_pre_upd.doc_attribute11
            ,x_doc_attribute12            => l_doc_tl_pre_upd.doc_attribute12
            ,x_doc_attribute13            => l_doc_tl_pre_upd.doc_attribute13
            ,x_doc_attribute14            => l_doc_tl_pre_upd.doc_attribute14
            ,x_doc_attribute15            => l_doc_tl_pre_upd.doc_attribute15);


  -- Update document to fnd_attached_documents, fnd_documents,
  -- fnd_documents_tl and fnd_documents_long_text
  --
            fnd_attached_documents_pkg.update_row
            (x_rowid                      => p_rowid
            ,x_attached_document_id       =>
                        l_attached_doc_pre_upd.attached_document_id
            ,x_document_id                => l_doc_pre_upd.document_id
            ,x_last_update_date           => trunc(sysdate)
            ,x_last_updated_by            => p_login_person_id --10/14/97chg
            ,x_seq_num                    => l_attached_doc_pre_upd.seq_num
            ,x_entity_name                => p_entity_name
            ,x_column1                    => 'PERSON_ID'
            ,x_pk1_value                  => p_pk1_value
            ,x_pk2_value                  => l_attached_doc_pre_upd.pk2_value
            ,x_pk3_value                  => l_attached_doc_pre_upd.pk3_value
            ,x_pk4_value                  => l_attached_doc_pre_upd.pk4_value
            ,x_pk5_value                  => l_attached_doc_pre_upd.pk5_value
            ,x_automatically_added_flag   =>
                      l_attached_doc_pre_upd.automatically_added_flag
            ,x_attribute_category         =>
                      l_attached_doc_pre_upd.attribute_category
            ,x_attribute1                 => l_attached_doc_pre_upd.attribute1
            ,x_attribute2                 => l_attached_doc_pre_upd.attribute2
            ,x_attribute3                 => l_attached_doc_pre_upd.attribute3
            ,x_attribute4                 => l_attached_doc_pre_upd.attribute4
            ,x_attribute5                 => l_attached_doc_pre_upd.attribute5
            ,x_attribute6                 => l_attached_doc_pre_upd.attribute6
            ,x_attribute7                 => l_attached_doc_pre_upd.attribute7
            ,x_attribute8                 => l_attached_doc_pre_upd.attribute8
            ,x_attribute9                 => l_attached_doc_pre_upd.attribute9
            ,x_attribute10                => l_attached_doc_pre_upd.attribute10
            ,x_attribute11                => l_attached_doc_pre_upd.attribute11
            ,x_attribute12                => l_attached_doc_pre_upd.attribute12
            ,x_attribute13                => l_attached_doc_pre_upd.attribute13
            ,x_attribute14                => l_attached_doc_pre_upd.attribute14
            ,x_attribute15                => l_attached_doc_pre_upd.attribute15
            /*   columns necessary for creating a document on the fly  */
            ,x_datatype_id                => l_doc_pre_upd.datatype_id
            ,x_category_id                => l_doc_pre_upd.category_id
            ,x_security_type              => l_doc_pre_upd.security_type
            ,x_security_id                => l_doc_pre_upd.security_id
            ,x_publish_flag               => l_doc_pre_upd.publish_flag
            ,x_image_type                 => l_doc_pre_upd.image_type
            ,x_storage_type               => l_doc_pre_upd.storage_type
            ,x_usage_type                 => l_doc_pre_upd.usage_type
            ,x_start_date_active          => trunc(sysdate)
            ,x_end_date_active            => l_doc_pre_upd.end_date_active
            ,x_language                   => l_language
            ,x_description                => l_doc_tl_pre_upd.description
            ,x_file_name                  => l_doc_tl_pre_upd.file_name
            ,x_media_id                   => l_doc_tl_pre_upd.media_id
            ,x_doc_attribute_category     =>
                      l_doc_tl_pre_upd.doc_attribute_category
            ,x_doc_attribute1             => l_doc_tl_pre_upd.doc_attribute1
            ,x_doc_attribute2             => l_doc_tl_pre_upd.doc_attribute2
            ,x_doc_attribute3             => l_doc_tl_pre_upd.doc_attribute3
            ,x_doc_attribute4             => l_doc_tl_pre_upd.doc_attribute4
            ,x_doc_attribute5             => l_doc_tl_pre_upd.doc_attribute5
            ,x_doc_attribute6             => l_doc_tl_pre_upd.doc_attribute6
            ,x_doc_attribute7             => l_doc_tl_pre_upd.doc_attribute7
            ,x_doc_attribute8             => l_doc_tl_pre_upd.doc_attribute8
            ,x_doc_attribute9             => l_doc_tl_pre_upd.doc_attribute9
            ,x_doc_attribute10            => l_doc_tl_pre_upd.doc_attribute10
            ,x_doc_attribute11            => l_doc_tl_pre_upd.doc_attribute11
            ,x_doc_attribute12            => l_doc_tl_pre_upd.doc_attribute12
            ,x_doc_attribute13            => l_doc_tl_pre_upd.doc_attribute13
            ,x_doc_attribute14            => l_doc_tl_pre_upd.doc_attribute14
            ,x_doc_attribute15            => l_doc_tl_pre_upd.doc_attribute15);

  -- remove chr(13)
     l_attachment_text := replace(p_attachment_text,
          g_carriage_return||g_line_feed,g_line_feed);
  -- Now update the long text table
     update fnd_documents_long_text
        set long_text = l_attachment_text
      where media_id  = l_doc_tl_pre_upd.media_id;
hr_utility.set_location('Leaving: '|| l_proc,25);
  EXCEPTION
    when others then
    hr_utility.set_location('EXCEPTION: '|| l_proc,555);
         raise;
  --
  End update_attachment;

procedure get_attachment_v4
          (p_attachment_text    out nocopy long
          ,p_entity_name        in varchar2 default null
          ,p_pk1_value          in varchar2 default null
          ,p_effective_date     in date
          ,p_name               in fnd_document_categories_tl.name%TYPE
          ,p_rowid              out nocopy varchar2
          ) is

  l_attached_document_id fnd_attached_documents.attached_document_id%TYPE;
  l_document_id          fnd_documents.document_id%TYPE;
  l_media_id             fnd_documents_tl.media_id%TYPE;
  l_category_id          fnd_documents.category_id%type;
  l_seq_num              fnd_attached_documents.seq_num%type;
  l_creation_date        fnd_documents_tl.creation_date%type;
  l_proc constant varchar2(100) := g_package || ' get_attachment_v4';
begin
  hr_utility.set_location('Entering: '|| l_proc,5);
  get_attachment
    (p_attachment_text => p_attachment_text
    ,p_entity_name => p_entity_name
    ,p_pk1_value => p_pk1_value
    ,p_effective_date => to_char(nvl(p_effective_date, trunc(sysdate)))
    ,p_attached_document_id => l_attached_document_id
    ,p_document_id => l_document_id
    ,p_media_id => l_media_id
    ,p_rowid => p_rowid
    ,p_category_id => l_category_id
    ,p_seq_num => l_seq_num
    ,p_creation_date => l_creation_date
    ,p_user_name => p_name);
hr_utility.set_location('Leaving: '|| l_proc,10);

exception
  when others then
    hr_utility.set_location('EXCEPTION: '|| l_proc,555);
    p_attachment_text := null;
    p_rowid := null;

end get_attachment_v4;

-- ----------------------------------------------------------------------------
-- |--------------------------< get_attachment >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Duplicated from hrcustwf.pkb (hr_offer_custom), modified to get
-- creation_date

procedure get_attachment
          (p_attachment_text    out nocopy long
          ,p_entity_name        in varchar2 default null
          ,p_pk1_value          in varchar2 default null
          ,p_effective_date     in varchar2
          ,p_attached_document_id  out
              fnd_attached_documents.attached_document_id%TYPE
          ,p_document_id           out nocopy fnd_documents.document_id%TYPE
          ,p_media_id              out nocopy fnd_documents_tl.media_id%TYPE
          ,p_rowid                 out nocopy varchar2
          ,p_category_id           out nocopy fnd_documents.category_id%type
          ,p_seq_num               out nocopy fnd_attached_documents.seq_num%type
          ,p_creation_date         out nocopy fnd_documents_tl.creation_date%type
          ,p_user_name          in
                                  fnd_document_categories_tl.user_name%TYPE
                                           DEFAULT 'HR_RESUME'
          ) is

  -- [CUSTOMIZE]
  -- Call fnd_attached_documents, fnd_documents_tl and
  -- fnd_documents_long_text tables. If customer uses third party
  -- software to store the resumes, modify the code here.

  l_attached_document_id  fnd_attached_documents.attached_document_id%TYPE
                          default null;
  l_document_id           fnd_documents.document_id%TYPE default null;
  l_media_id              fnd_documents_tl.media_id%TYPE default null;
  l_attachment_text       long default null;
  l_rowid                 varchar2(50) default null;
  l_category_id           fnd_documents.category_id%type default null;
  l_language              varchar2(30) default 'AMERICAN';
  l_seq_num               fnd_attached_documents.seq_num%type default null;
  l_update_date           date default null;
  l_creation_date         fnd_documents_tl.creation_date%TYPE default null;
  l_proc constant varchar2(100) := g_package || ' get_attachment';
  cursor csr_get_category_id (csr_p_lang in varchar2) is
  select category_id
    from fnd_document_categories_tl
   where language = csr_p_lang
     and name = p_user_name;

  cursor csr_attached_documents (csr_p_cat_id in number) is
  select fatd.rowid, fatd.attached_document_id, fatd.document_id, fatd.seq_num
         ,fd.last_update_date
    from fnd_attached_documents  fatd
         ,fnd_documents          fd
   where fd.category_id = csr_p_cat_id
     and fatd.entity_name = p_entity_name
     and fatd.pk1_value   = p_pk1_value
     and fatd.document_id = fd.document_id
     and p_effective_date
         between nvl(fd.start_date_active, trunc(sysdate))
             and nvl(fd.end_date_active, hr_api.g_eot)
   order by fd.last_update_date desc,
         fd.document_id desc;   -- retrieve the one updated the last

  cursor csr_documents_tl (csr_p_document_id in number) is
  select media_id , creation_date
    from fnd_documents_tl
   where document_id = csr_p_document_id
     and media_id is not null;

  cursor csr_documents_long_text (csr_p_media_id in number) is
  select long_text
    from fnd_documents_long_text
   where media_id = csr_p_media_id;

Begin
  hr_utility.set_location('Entering: '|| l_proc,5);
  --
  -- Get language
  select userenv('LANG') into l_language from dual;
  --
  -- -------------------------------------------------------------------------
  -- Retrieving a resume requires 4 steps:
  --   1) Get Category ID.
  --   2) Get the attached_document_id, document_id and other fields from
  --      the table join of fnd_attached_documents and fnd_documents.  The
  --      result set can have more than 1 row and is sorted by descending
  --      order of the last_update_date.  So, if there are multipe resumes
  --      returned (which could be possible because a user in 10SC Person
  --      form can add an attachment with the category of 'Resume'.  When
  --      that happens, we only want the one which is updated most recently.
  --   3) Use the document_id obtained from the 1st record of step 2 to
  --      get the media_id from fnd_documents_tl.
  --   4) Use the media_id from step 3 to obtain the resume text from
  --      fnd_documents_long_text.
  -- -------------------------------------------------------------------------
  --
  -- -------------------------------------------------------------------------
  -- 1) Get Category ID.
  -- -------------------------------------------------------------------------
  open csr_get_category_id (csr_p_lang => l_language);
   hr_utility.trace('Going into Fetch after (open csr_get_category_id (csr_p_lang => l_language) ): '|| l_proc);
  fetch csr_get_category_id into l_category_id;
  if csr_get_category_id%notfound then
    hr_utility.set_message(801, 'HR_7220_INVALID_PRIMARY_KEY');
    hr_utility.raise_error;
  end if;
  close csr_get_category_id;
  --
  -- -------------------------------------------------------------------------
  -- 2) Get attached_document_id, document_id.
  -- -------------------------------------------------------------------------
  --
  Open csr_attached_documents (csr_p_cat_id => l_category_id);
  hr_utility.trace('Going into Fetch after (Open csr_attached_documents (csr_p_cat_id => l_category_id)) ): '|| l_proc);
  fetch csr_attached_documents into l_rowid, l_attached_document_id,
                                    l_document_id, l_seq_num, l_update_date;

  IF csr_attached_documents%NOTFOUND THEN
  hr_utility.trace('In( IF csr_attached_documents%NOTFOUND): '|| l_proc);
     close csr_attached_documents;
  ELSE
   hr_utility.trace('In else of ( IF csr_attached_documents%NOTFOUND): '|| l_proc);
     open csr_documents_tl(csr_p_document_id => l_document_id);
     hr_utility.trace('Going into Fetch after (open csr_documents_tl(csr_p_document_id => l_document_id)): '|| l_proc);
     fetch csr_documents_tl into l_media_id , l_creation_date;
     IF csr_documents_tl%NOTFOUND THEN

        close csr_attached_documents;
        close csr_documents_tl;
        raise hr_utility.hr_error;
     ELSE
        open csr_documents_long_text(csr_p_media_id  => l_media_id);
        hr_utility.trace('Going into Fetch after (open csr_documents_long_text(csr_p_media_id  => l_media_id)): '|| l_proc);
        fetch csr_documents_long_text into l_attachment_text;
        IF csr_documents_long_text%NOTFOUND THEN
           close csr_attached_documents;
           close csr_documents_tl;
           close csr_documents_long_text;
           raise hr_utility.hr_error;
        ELSE
           close csr_attached_documents;
           close csr_documents_tl;
           close csr_documents_long_text;
        END IF;
     END IF;
  END IF;

  p_attachment_text := l_attachment_text;
  p_attached_document_id := l_attached_document_id;
  p_document_id := l_document_id;
  p_media_id := l_media_id;
  p_rowid := l_rowid;
  p_category_id := l_category_id;
  p_seq_num := l_seq_num;
  p_creation_date := l_creation_date;
hr_utility.set_location('Leaving: '|| l_proc,35);

exception
  when hr_utility.hr_error THEN
  hr_utility.set_location('EXCEPTION: '|| l_proc,555);
       raise;

  when others then
  hr_utility.set_location('EXCEPTION: '|| l_proc,560);
    hr_utility.trace(' Exception ' || sqlerrm );
    raise;

end get_attachment;


----------------------------------------------------------------------------
--Fuction string to URL
----------------------------------------------------------------------------
FUNCTION string_to_url ( p_url in varchar2) return varchar2
/* "percent-sign"
"plus-sign"
"space"
"ampersand"
"question-mark"
...must be handled specially withing a URL parameter

For eg... (cat + s%) & ?mat

*/
IS
v_url varchar2(32000);
l_proc constant varchar2(100) := g_package || ' string_to_url';
BEGIN
hr_utility.set_location('Entering: '|| l_proc,5);
/* The order of the next three "replace" calls matters! */

v_url := replace ( p_url, '%', '%25' );
v_url := replace ( v_url, '+', '%2B' );
v_url := replace ( v_url, ' ', '+' );
v_url := replace ( v_url, '#', '%23');

/* but the order of the next "replace" calls doen't matter */

v_url := replace ( v_url, '&', '%26' );
v_url := replace ( v_url, '?', '%3F' );
hr_utility.set_location('Leaving: '|| l_proc,10);
return v_url;
END string_to_url;


/*-----------------------------------------------------------------------------
|
|   Name         : isManager
|
|   Purpose      :
|                This functions returns TRUE if the logged in person is in
|                LM mode or returns FALSE if the logged in person is in
|                Employee Mode
|
|  In Parameters :
|
|    p_item_type  = Workflow Item Type for the Current Process (HRSSA).
|    p_item_key   = Workflow Item Key for the Current Process.
|
|  Returns       : BOOLEAN
|     TRUE       = If it's a manager
|     FALSE      = If it's a employee.
+-----------------------------------------------------------------------------*/
FUNCTION isManager
	(p_item_type IN VARCHAR2
	,p_item_key IN VARCHAR
	) RETURN BOOLEAN IS
l_text_value VARCHAR2(2000);
l_proc constant varchar2(100) := g_package || ' isManager';
BEGIN
hr_utility.set_location('Entering: '|| l_proc,5);


	l_text_value :=
		wf_engine.getItemAttrText
		(itemtype => p_item_type
		,itemkey => p_item_key
		,aname => 'P_PERSON_ID');

	IF l_text_value IS NULL THEN
	    hr_utility.set_location('Leaving: '|| l_proc,10);
		-- Since no value is set for P_PERSON_ID, it must be Employee.
		RETURN FALSE;
	ELSE
		-- Since P_PERSON_ID is set, it must be  Manager.
		hr_utility.set_location('Leaving: '|| l_proc,15);
		RETURN TRUE;
	END IF;

	EXCEPTION
	WHEN OTHERS THEN

        hr_utility.set_location('EXCEPTION: '|| l_proc,555);
		RETURN FALSE;
END isManager;
/*------------------------------------------------------------------------------
|       Name           : isSelfUpdating
|   Purpose      :
|                This functions returns TRUE if the logged in person is same as
|                person being updated in LM mode.
|                Returns FALSE if the logged in person is different from the
|                person being updated.
|
|  In Parameters :
|
|    p_item_type  = Workflow Item Type for the Current Process (HRSSA).
|    p_item_key   = Workflow Item Key for the Current Process.
|
|  Returns       : BOOLEAN
|     TRUE       = If it's a manager updating himself in LMDA mode or
|                  If a person logged in EDA mode
|     FALSE      = If it's a employee is updated by his manger in LMDA mode.
+-----------------------------------------------------------------------------*/

FUNCTION isSelfUpdating
        (p_item_type IN VARCHAR2
        ,p_item_key IN VARCHAR
        ) RETURN BOOLEAN IS
l_text_value VARCHAR2(2000);
g_person_id per_all_people_f.person_id%TYPE;
l_proc constant varchar2(100) := g_package || ' isSelfUpdating';
BEGIN
hr_utility.set_location('Entering: '|| l_proc,5);
        l_text_value :=
                wf_engine.getItemAttrText
                (itemtype => p_item_type
                ,itemkey => p_item_key
                ,aname => 'P_PERSON_ID');

     -- get the g_person_id from validate session
        hr_util_misc_web.validate_session(p_person_id => g_person_id,p_icx_update => false);

 	IF  l_text_value IS NULL OR to_number(l_text_value) = g_person_id THEN
 	     hr_utility.set_location('Leaving: '|| l_proc,10);
                RETURN TRUE; -- Manager updating him/herself or EDA mode
        ELSE
          hr_utility.set_location('Leaving: '|| l_proc,15);
                RETURN FALSE; -- Manager updating his/her employee
        END IF;

        EXCEPTION
        WHEN OTHERS THEN
         hr_utility.set_location('EXCEPTION: '|| l_proc,555);
                RETURN TRUE;
END isSelfUpdating;
/*------------------------------------------------------------------------------
|       Name           : get_called_from
|
|       Purpose        :
|
|       This function will return the string which appears after
|       'p_called_from=' for line manager direct access menu function's.
|       parameters.
|
|       This code assumes that hr_person_search_tree_web.setup is taking
|       ONLY 1 parameter and which is p_called_from. So, if the definition for
|       hr_person_search_tree_web.setup is changed, then this function also
|       needs to be modified accordingly.
+-----------------------------------------------------------------------------*/
  FUNCTION get_called_from RETURN VARCHAR2 IS

  l_fnd_form_function fnd_form_functions%ROWTYPE;
  l_function_id fnd_Form_functions.function_id%TYPE;
  l_called_from fnd_Form_functions.parameters%TYPE;
  l_proc constant varchar2(100) := g_package || ' get_called_from';
  CURSOR csr_icx_session(p_session_id IN NUMBER) IS
	 SELECT a.function_id
	 FROM   icx_sessions a
	 WHERE  session_id = p_session_id;
  BEGIN
    hr_utility.set_location('Entering: '|| l_proc,5);
	-- --------------------------------------------------------
	-- Get the Function ID
	-- --------------------------------------------------------
	OPEN csr_icx_session( icx_sec.getID(n_param => icx_sec.PV_SESSION_ID));
	 hr_utility.trace('Going into Fetch after (csr_icx_session( icx_sec.getID(n_param => icx_sec.PV_SESSION_ID)) ): '|| l_proc);
	FETCH csr_icx_session INTO l_function_id;
	CLOSE csr_icx_session;

	-- --------------------------------------------------------
	-- Get the function information
	-- --------------------------------------------------------
	l_fnd_form_function := get_fnd_form_function(l_function_id);
	l_called_from := SUBSTR(UPPER(l_fnd_form_function.parameters)
		      ,LENGTH('P_CALLED_FROM=') + 1);
   	hr_utility.set_location('Leaving: '|| l_proc,15);
	RETURN  l_called_from;
	EXCEPTION
	WHEN OTHERS THEN
	   hr_utility.set_location('EXCEPTION: '|| l_proc,555);
	   RAISE;
  END get_called_from;

/*------------------------------------------------------------------------------
|       Name           : get_fnd_form_function
|
|       Purpose        :
|
|       This function will return all the information needed for any
|       fnd_form_function row.
+-----------------------------------------------------------------------------*/
  FUNCTION get_fnd_form_function(p_function_id IN NUMBER)
		RETURN fnd_form_functions%ROWTYPE IS
	CURSOR csr_fnd_form_functions IS
	  SELECT *
	  FROM	fnd_form_functions
	  WHERE function_id = p_function_id;
  l_function fnd_form_functions%ROWTYPE;
  l_proc constant varchar2(100) := g_package || ' get_fnd_form_function';
  BEGIN
     hr_utility.set_location('Entering: '|| l_proc,5);
	OPEN csr_fnd_form_functions;
	 hr_utility.trace('Going into Fetch after (OPEN csr_fnd_form_functions ): '|| l_proc);
	FETCH csr_fnd_form_functions INTO l_function;
	CLOSE csr_fnd_form_functions;
    hr_utility.set_location('Leaving: '|| l_proc,15);
	RETURN l_function;
	EXCEPTION
	WHEN OTHERS THEN
	hr_utility.set_location('EXCEPTION: '|| l_proc,555);
	 RAISE;
  END get_fnd_Form_function;


/*------------------------------------------------------------------------------
|       Name           : get_process_name
|
|       Purpose        :
|
|       This function will return the string which appears after
|       'p_process_name=' in the direct access menu function's.
|       parameters.
| 	Usage          :
|        This function is to be used when the FND form Function is
|       defined as exactly 'P_PROCESS_NAME=YourProcess&P_ITEM_TYPE=...'
|       i.e P_PROCESS_NAMEis followed by &P_ITEM_TYPE
+-----------------------------------------------------------------------------*/
  FUNCTION get_process_name RETURN VARCHAR2 IS

  l_fnd_form_function fnd_form_functions%ROWTYPE;
  l_function_id fnd_Form_functions.function_id%TYPE;
  l_called_from fnd_Form_functions.parameters%TYPE;
  l_proc constant varchar2(100) := g_package || ' get_process_name ';
  CURSOR csr_icx_session(p_session_id IN NUMBER) IS
	 SELECT a.function_id
	 FROM   icx_sessions a
	 WHERE  session_id = p_session_id;
  BEGIN
   hr_utility.set_location('Entering: '|| l_proc,5);
	-- --------------------------------------------------------
	-- Get the Function ID
	-- --------------------------------------------------------
	OPEN csr_icx_session( icx_sec.getID(n_param => icx_sec.PV_SESSION_ID));
	hr_utility.trace('Going into Fetch after (OPEN csr_icx_session( icx_sec.getID(n_param => icx_sec.PV_SESSION_ID))): '|| l_proc);
	FETCH csr_icx_session INTO l_function_id;
	CLOSE csr_icx_session;

	-- --------------------------------------------------------
	-- Get the function information
	-- --------------------------------------------------------
	l_fnd_form_function := get_fnd_form_function(l_function_id);
	l_called_from := SUBSTR(UPPER(l_fnd_form_function.parameters)
		      	,LENGTH('P_PROCESS_NAME=') + 1);
	l_called_from := SUBSTR(UPPER(l_called_from)
			,1
			,INSTR(UPPER(l_called_from),'&P_ITEM') -1 );
    hr_utility.set_location('Leaving: '|| l_proc,15);
	RETURN  l_called_from;
	EXCEPTION
	WHEN OTHERS THEN
    hr_utility.set_location('EXCEPTION: '|| l_proc,555);
	  RAISE;
  END get_process_name;

/*------------------------------------------------------------------------------
|       Name           : get_item_type
|
|       Purpose        :
s function will return the string which appears after
|       'p_item_type=' in the direct access menu function's.
|       parameters.
|       Usage          :
|        This function is used to get the item_type from FND form Function
+-----------------------------------------------------------------------------*/
  FUNCTION get_item_type RETURN VARCHAR2 is

  l_fnd_form_function fnd_form_functions%ROWTYPE;
  l_function_id fnd_Form_functions.function_id%TYPE;
  l_called_from fnd_Form_functions.parameters%TYPE;
  l_number  	integer;
  l_proc constant varchar2(100) := g_package || ' get_item_type';
  CURSOR csr_icx_session(p_session_id IN NUMBER) IS
	 SELECT a.function_id
	 FROM   icx_sessions a
	 WHERE  session_id = p_session_id;
  BEGIN
     hr_utility.set_location('Entering: '|| l_proc,5);

	-- --------------------------------------------------------
	-- Get the Function ID
	-- --------------------------------------------------------
	OPEN csr_icx_session( icx_sec.getID(n_param => icx_sec.PV_SESSION_ID));
	hr_utility.trace('Going into Fetch after (	OPEN csr_icx_session( icx_sec.getID(n_param => icx_sec.PV_SESSION_ID))): '|| l_proc);
	FETCH csr_icx_session INTO l_function_id;
	CLOSE csr_icx_session;

	-- --------------------------------------------------------
	-- Get the function information
	-- --------------------------------------------------------
	l_fnd_form_function := get_fnd_form_function(l_function_id);
	l_called_from := SUBSTR(UPPER(l_fnd_form_function.parameters)
		      	,INSTR(UPPER(l_fnd_form_function.parameters)
					, '&P_ITEM_TYPE=')
				);
 	l_number := INSTR(UPPER(l_called_from), '&P',4) ;

	IF l_number <> 0 THEN
 	l_number := l_number -14;
	  l_called_from := SUBSTR(UPPER(l_called_from)
			,14
                        ,l_number );
        ELSE
	  l_called_from := SUBSTR(UPPER(l_called_from)
				,14);
	END IF;
    hr_utility.set_location('Leaving: '|| l_proc,15);
	RETURN  l_called_from;
	EXCEPTION
	WHEN OTHERS THEN
	hr_utility.set_location('EXCEPTION: '|| l_proc,555);
	 RAISE;
  END get_item_type;

  /*
 ||===========================================================================
 || FUNCTION: get_business_group_id
 ||---------------------------------------------------------------------------
 ||
 || Description:
 ||     If p_person_id is passed, the function call returns
 ||     Business Group ID for the current person. Otherwise,
 ||     the Function call returns the Business Group ID
 ||     for the current session's login responsibility.
 ||     The defaulting levels are as defined in the
 ||     package FND_PROFILE. It returns business group id
 ||     value for a specific user/resp/appl combo.
 ||     Default is user/resp/appl/site is current login.
 ||
 || Pre Conditions:
 ||
 || In Arguments:
 ||
 || out nocopy Arguments:
 ||
 || In out nocopy Arguments:
 ||
 || Post Success:
 ||     Returns the business group id.
 ||
 || Post Failure:
 ||
 || Access Status:
 ||     Public.
 ||
 ||===========================================================================
  */
  FUNCTION get_business_group_id
		 (p_person_id IN NUMBER DEFAULT NULL)
  RETURN   per_business_groups.business_group_id%TYPE IS

  -- Local Variables.
  ln_business_group_id  per_business_groups.business_group_id%TYPE;
  ln_person_rec per_people_f%ROWTYPE;
  l_person_id   per_people_f.person_id%type;
  l_proc constant varchar2(100) := g_package || ' get_business_group_id';

  BEGIN
    hr_utility.set_location('Entering: '|| l_proc,5);
    IF p_person_id is null then
	 validate_session(p_person_id => l_person_id
				  ,p_icx_update => false);
	 fnd_profile.get (
      name => 'PER_BUSINESS_GROUP_ID',
	 val  => ln_business_group_id
	  );
    ELSE
	 ln_person_rec := get_person_rec(p_effective_date => TRUNC(SYSDATE)
							  ,p_person_id => p_person_id);
      ln_business_group_id := ln_person_rec.business_group_id;
    END IF;
   hr_utility.set_location('Leaving: '|| l_proc,10);

    RETURN (ln_business_group_id);

    EXCEPTION
	 WHEN OTHERS THEN
	 hr_utility.set_location('EXCEPTION: '|| l_proc,555);
        htp.p ('Exception in hr_utl'
			 || g_package || '.get_business_group_id - '
			 || SQLERRM || ' ' || SQLCODE
        );
       RETURN NULL;
END get_business_group_id;

  /*
  ||===========================================================================
  || PROCEDURE check_business_group
  ||===========================================================================
  || Description:  This procedure display error page if the passed person is
  ||               not visible through the per_people_f view
  ||===========================================================================
  */
  PROCEDURE check_business_group
    (p_person_id IN NUMBER) IS

    cursor check_person is
    select person_id from per_people_f
    where person_id = p_person_id;

    l_person_id NUMBER;
    l_proc constant varchar2(100) := g_package || ' check_business_group';
    invalid_security_permission exception;
  BEGIN

    hr_utility.set_location('Entering: '|| l_proc,5);
    open check_person;
    hr_utility.trace('Going into Fetch after (open check_person): '|| l_proc);
    fetch check_person into l_person_id;
    if check_person%notfound then
        close check_person;
        fnd_message.set_name('PER', 'HR_INVALID_SECURITY_PERMISSION');
        hr_utility.trace(' Exception in hr_util_misc_web.check_businss_group ' || SQLERRM );
        raise invalid_security_permission;
    end if;
    close check_person;
  /*
    IF get_business_group_id <> get_business_group_id(p_person_id) THEN
      fnd_message.set_name('PER', 'HR_WEB_BUS_GROUP_ERR');
      hr_util_disp_web.display_fatal_errors
        (p_message => fnd_message.get);
    END IF;
  */

  hr_utility.set_location('Leaving: '|| l_proc,15);
  EXCEPTION
	when invalid_security_permission then
        hr_utility.trace(' Exception HR_INVALID_SECURITY_PERMISSION in hr_util_misc_web.check_business_group ' || SQLERRM );
        hr_utility.set_location('Leaving: '|| l_proc,15);
	raise;
        when others then
        hr_utility.trace(' Exception in hr_util_misc_web.check_business_group ' || SQLERRM );
        hr_utility.set_location('Leaving: '|| l_proc,15);
	raise;
  END check_business_group;

  /*
  ||===========================================================================
  || PROCEDURE initialize_hr_globals
  ||===========================================================================
  || Description:
  ||===========================================================================
  */
  PROCEDURE initialize_hr_globals
     (p_reset_errors IN VARCHAR2 DEFAULT 'Y') IS
     l_proc constant varchar2(100) := g_package || ' initialize_hr_globals';
  BEGIN
  hr_utility.set_location('Entering: '|| l_proc,5);
   IF p_reset_errors = 'Y' THEN
     hr_errors_api.g_error       := false;
     hr_errors_api.g_errorTable.delete;
     hr_errors_api.g_count       := 0;
   END IF;
hr_utility.set_location('Leaving: '|| l_proc,10);
  END initialize_hr_globals;

END hr_util_misc_web;

/
