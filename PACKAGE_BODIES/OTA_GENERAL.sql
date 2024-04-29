--------------------------------------------------------
--  DDL for Package Body OTA_GENERAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_GENERAL" as
/* $Header: otgenral.pkb 120.3 2005/07/20 01:03:03 dbatra noship $ */
/*
  ===========================================================================
 |               Copyright (c) 1996 Oracle Corporation                       |
 |                       All rights reserved.                                |
  ===========================================================================
Name
        General Oracle Training utilities
Purpose
        To provide widely used functions in a single shared area
History
         9 Nov 94       M Roychowdhury       Created
        10 Nov 94       M Roychowdhury       Added procedure
                                             check_start_end_dates
        11 Nov 94       M Roychowdhury       Added check for person
        17 Nov 94       M Roychowdhury       Added check for current employee
        7 Dec 94        N Simpson               Added functions
                                                VALID_VENDOR,
                                                VALID_CURRENCY
        07 Mar 95       J Rhodes             Include correct messages
        24 Jul 95       J Rhodes             Changed per_people_f to
                                             per_all_people_f
        23 Aug 95       J Rhodes             Dummy cursor get_default_values
        31 Aug 95       J Rhodes             Added check_fnd_user
        31 Aug 95       J Rhodes             Added get_fnd_user
        16 Feb 96       G Perry              Added get_session_date
  10.18 29 Mar 96       S Shah               Added check_par_child_dates_fun
  110.2 03 Dec 98       C Tredwin            Added char_to_number
  115.4 11-OCT-99       R Raina              Added function fnd_lang_desc
  115.5 12-OCT-99       R Raina              Added function fnd_curr_name,
                                                            fnd_lang_code,
                                                            hr_org_name
  115.6 31-Aug-00       D Hmulia             modified length of decription
 				             in fnd_lang_desc to 255
  115.8 11-MAY-01	D HMulia   	     Added function get_training_center,
						function get_location
  115.10 10-JUL-01      D HMulia 	     Added Function get_finance.
  115.11 12-Mar-02      A Sud                Bug 2256328. Modified the length
                                             of variables for Organization name
                                             and training center.
  115.12 26-Oct-02      J Bharath            Enh 253086 - Modified the ota_general.check_current_employee
                                             cursor(c_current_employee) query to support PTU for CWK.
  115.15 29-Nov-02      Jbharath             Bug#2684733 NOCOPY added for IN OUT/OUT arguments of procedure
  115.16 11-Dec-02      Arkashya	     Bug#2705857 Removed the debug routines eg.set_location as a part
                                             debug performance changes.Package classified as R11.5.9 category A.
  115.17 13-Mar-03      Pbhasin              CSR_LOOKUP cursor in hr_org_name function changed.
  115.20 16-Jan-04      Hdshah               get_business_group_id function modified.
  115.21 03-Nov-04 sgokhale  Bug  3953333 Validation for checking vendor validity wrt start date
   rem 115.22 07-Apr-05   dbatra      Added get_event_name and get_course_name
rem 115.23 16-May-2005  jbharath 3885568    Modified cursor c_current_employee to support applicants.
 rem 115.24 30-Jun-05   dbatra  4465618    Modified get_course_name signature
  rem 115.25 18-Jul-05   rdola   4490656 Added get_legislation_code method
   rem 115.13 20-Jul-2005 dbatra  4496361 Added get_offering_name
*/

-- Global package name
--
g_package               varchar2(33)    := '  ota_general.';
g_dummy                 number (1);
--
--------------------------------------------------------------------------------
--

function get_event_name (p_event_id in number)
return varchar2
IS

l_event_name ota_events.title%TYPE;

CURSOR c_get_event_name
IS
SELECT  title from ota_events_vl
where
event_id = p_event_id;

BEGIN


 OPEN c_get_event_name;
    FETCH c_get_event_name INTO l_event_name;
    close c_get_event_name;
 return(l_event_name);

end get_event_name ;

function get_offering_name (p_offering_id in number)
return varchar2
IS

l_offering_name ota_offerings_tl.name%TYPE;

CURSOR c_get_offering_name
IS
SELECT name from ota_offerings_tl
where
language=userenv('LANG')
and
offering_id = p_offering_id;

BEGIN


 OPEN c_get_offering_name;
    FETCH c_get_offering_name INTO l_offering_name;
    close c_get_offering_name;
 return(l_offering_name);

end get_offering_name ;

function get_course_name (p_activity_version_id in number default null,p_eventid in number default null)
return varchar2
IS
l_business_group_id number;
l_course_name OTA_ACTIVITY_VERSIONS_TL.version_name%TYPE;

CURSOR c_get_course_name
IS
SELECT version_name
FROM OTA_ACTIVITY_VERSIONS_TL
WHERE activity_version_id = p_activity_version_id
AND language=userenv('LANG');

CURSOR c_get_course_name2
IS
SELECT oav.version_name
FROM OTA_ACTIVITY_VERSIONS_TL oav,ota_events oev
WHERE oav.activity_version_id = oev.activity_version_id
AND oav.language=userenv('LANG')
and oev.event_id = p_eventid;

BEGIN

 if p_activity_version_id is not null then
 OPEN c_get_course_name;
    FETCH c_get_course_name INTO l_course_name;
    close c_get_course_name;
 elsif p_eventid is not null then
    OPEN c_get_course_name2;
    FETCH c_get_course_name2 INTO l_course_name;
    close c_get_course_name2;
 end if;

 return(l_course_name);

end get_course_name ;


-- ----------------------------------------------------------------------------
-- |------------------------< check_current_employee >------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Check Current Employee
--
--              Checks if the given person is a current employee on a given
--              date
--
Function check_current_employee (p_person_id  in number,
                                 p_date       in date)
Return boolean is
--
  -- cursor to check if the person has current employee flag set
  --
  Cursor c_current_employee is
    select 'X'
    from per_all_people_f ppf,
    per_person_type_usages_f ptu,
    per_person_types ppt
    where p_date between ptu.effective_start_date and ptu.effective_end_date
    and   p_date between ppf.effective_start_date and ppf.effective_end_date
    and	  ptu.person_id = ppf.person_id
    and   ppt.system_person_type in ('EMP','CWK','APL')  -- Added 'APL' for 3885568
    and   ppt.business_group_id = ppf.business_group_id
    and   ptu.person_type_id = ppt.person_type_id
    and   ppf.person_id = p_person_id ;
  --
  --
  l_result      boolean;
  l_dummy       varchar2(1);
--
Begin
  --
  open c_current_employee;
  fetch c_current_employee into l_dummy;
  l_result := c_current_employee%found;
  close c_current_employee;
  --
  --
  Return (l_result);
  --
End check_current_employee;
--
-- ----------------------------------------------------------------------------
-- |------------------------< check_domain_value >----------------------------|
-- ----------------------------------------------------------------------------
-- PUBLIC
--
-- Description : Used to check if a value is in the specified domain
--
Procedure check_domain_value
  (
   p_domain_type        in  varchar2
  ,p_domain_value       in  varchar2
  ) is
  --
  l_lookup_exists       boolean;
  l_proc                varchar2(72) := g_package||'check_domain_value';
  --
  cursor csr_check_domain is
        --
        select  1
        from    hr_lookups
        where   lookup_type  =  p_domain_type
        and     lookup_code  =  p_domain_value;
--
procedure check_parameters is
        --
        begin
        hr_api.mandatory_arg_error (    g_package,
                                        'p_domain_type',
                                        p_domain_type);
        end check_parameters;
        --
Begin
--
--
check_parameters;
--
if p_domain_value is not null then
  --
  Open csr_check_domain;
  Fetch csr_check_domain into g_dummy;
  l_lookup_exists := csr_check_domain%found;
  close csr_check_domain;
  --
  If not l_lookup_exists then
    hr_utility.set_message(801, 'HR_7033_ELE_ENTRY_LKUP_INVLD');
    hr_utility.set_message_token('LOOKUP_TYPE', p_domain_type);
    hr_utility.set_message_token('PROCEDURE', l_proc);
    hr_utility.set_message_token('STEP','5');
    hr_utility.raise_error;
  End if;
  --
  --
end if;
--
End check_domain_value;
-- ----------------------------------------------------------------------------
-- |---------------------------< check_start_end_dates >----------------------|
-- ----------------------------------------------------------------------------
-- PUBLIC (See header for details.)
--
Procedure check_start_end_dates
  (
   p_start_date           in  date,
   p_end_date             in  date
  ) is
  --
  --
Begin
  --
  If p_end_date is not null then
     if p_start_date > p_end_date then
        fnd_message.set_name('OTA', 'OTA_13312_GEN_DATE_ORDER');
        fnd_message.raise_error;
     end if;
  end if;
  --
End check_start_end_dates;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< check_par_child_dates >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PUPLIC
-- Description:
--   Validate the parent startdate, enddate and the child startdate, enddate.
--   The child start- and enddate have to be whitin the parent start-, enddate.
--
Procedure check_par_child_dates
  (
   p_par_start    in  date
  ,p_par_end      in  date
  ,p_child_start  in  date
  ,p_child_end    in  date
  ) Is
--
  v_proc        varchar2(72) := g_package||'check_par_child_dates';
--
Begin
    --
    -- Existing date for the parent startdate => Boundary parent startdate
    --
    If p_par_start is not null  Then
      --
      -- Child startdate is earlier than parent startdate
      --
      If nvl( p_child_start, hr_api.g_sot) < p_par_start  Then
        --
        -- ** TEMP ** Add error message with the following text.
        fnd_message.set_name('OTA', 'OTA_13314_GEN_CS_PS');
        fnd_message.raise_error;
        --
      End if;
      --
      -- Child enddate is earlier than parent startdate
      --
      If nvl( p_child_end, hr_api.g_eot) < p_par_start Then
        --
        -- ** TEMP ** Add error message with the following text.
        fnd_message.set_name('OTA', 'OTA_13314_GEN_CS_PS');
        fnd_message.raise_error;
        --
      End if;
      --
    End if;
    --
    -- Existing date for the parent enddate => Boundary parent enddate
    --
    If p_par_end is not null  Then
      --
      -- Child startdate is later than parent enddate
      --
      If nvl( p_child_start, hr_api.g_sot) > p_par_end Then
        --
        -- ** TEMP ** Add error message with the following text.
        fnd_message.set_name('OTA', 'OTA_13314_GEN_CS_PS');
        fnd_message.raise_error;
        --
      End if;
      --
      -- Child enddate is later than parent enddate
      --
      If nvl( p_child_end, hr_api.g_eot) > p_par_end Then
        --
        -- ** TEMP ** Add error message with the following text.
        fnd_message.set_name('OTA', 'OTA_13314_GEN_CS_PS');
        fnd_message.raise_error;
        --
      End if;
      --
    End if;
  --
End check_par_child_dates;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< check_par_child_dates_fun >----------------------|
-- ----------------------------------------------------------------------------
--
-- PUPLIC
-- Description:
--   Validate the parent startdate, enddate and the child startdate, enddate.
--   The child start- and enddate have to be whitin the parent start-, enddate.
--
Function check_par_child_dates_fun
  (
   p_par_start    in  date
  ,p_par_end      in  date
  ,p_child_start  in  date
  ,p_child_end    in  date
  ) Return Boolean Is
--
  v_proc        varchar2(72) := g_package||'check_par_child_dates_fun';
--
Begin
    --
    -- Existing date for the parent startdate => Boundary parent startdate
    --
    If p_par_start is not null  Then
      --
      -- Child startdate is earlier than parent startdate
      --
      If nvl( p_child_start, hr_api.g_sot) < p_par_start  Then
        --
        return TRUE;
        --
      End if;
      --
      -- Child enddate is earlier than parent startdate
      --
      If nvl( p_child_end, hr_api.g_eot) < p_par_start Then
        --
        return TRUE;
        --
      End if;
      --
    End if;
    --
    -- Existing date for the parent enddate => Boundary parent enddate
    --
    If p_par_end is not null  Then
      --
      -- Child startdate is later than parent enddate
      --
      If nvl( p_child_start, hr_api.g_sot) > p_par_end Then
        --
        return TRUE;
        --
      End if;
      --
      -- Child enddate is later than parent enddate
      --
      If nvl( p_child_end, hr_api.g_eot) > p_par_end Then
        --
        return TRUE;
        --
      End if;
      --
    End if;
  --
  return FALSE;
  --
End check_par_child_dates_fun;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< check_start_end_time >-----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Validates the starttime and endtime.
--   p_start_time must be less than, or equal to, p_end_time.
--
Procedure check_start_end_time
  (
   p_start_time     in     varchar2
  ,p_end_time       in     varchar2
  ) is
  --
  --
Begin
  --
  if p_start_time is null  AND   p_end_time is NOT null  then
    --
        fnd_message.set_name('OTA', 'OTA_13316_GEN_TIMES_ORDER');
        fnd_message.raise_error;
    --
  elsif p_start_time is NOT null  AND   p_end_time is null  then
    --
        fnd_message.set_name('OTA', 'OTA_13316_GEN_TIMES_ORDER');
        fnd_message.raise_error;
    --
  elsif substr( p_start_time, 1, 2)  =  substr( p_end_time, 1, 2)  then
    --
    if substr( p_start_time, 4, 2)  >  substr( p_end_time, 4, 2)  then
      --
        fnd_message.set_name('OTA', 'OTA_13316_GEN_TIMES_ORDER');
        fnd_message.raise_error;
      --
    end if;
    --
  elsif substr( p_start_time, 1, 2)  >  substr( p_end_time, 1, 2)  then
    --
        fnd_message.set_name('OTA', 'OTA_13316_GEN_TIMES_ORDER');
        fnd_message.raise_error;
    --
  end if;
  --
End check_start_end_time;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< get_fnd_user >----------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Get FND USer
--
function get_fnd_user (p_user_id  in number) return varchar2 is
--
l_username fnd_user.user_name%TYPE;
--
cursor get_user is
select user_name
from fnd_user
where user_id = p_user_id;
--
begin
   open get_user;
   fetch get_user into l_username;
   close get_user;
   return l_username;
end;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< get_session_date >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Get Session Date
--
function get_session_date(p_session_id number) return date is
  l_date date;
  cursor c_session_date is
    select effective_date
    from   fnd_sessions
    where  session_id = p_session_id;
  --
begin
  --
  open c_session_date;
    fetch c_session_date into l_date;
  close c_session_date;
  return l_date;
  --
end get_session_date;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< check_fnd_user >----------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Check FND USer
--
Function check_fnd_user (p_user_id  in number) return boolean is
--
l_user varchar2(30);
--
cursor get_user is
select 'Y'
from fnd_user
where user_id = p_user_id;
--
begin
   open get_user;
   fetch get_user into l_user;
   if get_user%notfound then
      close get_user;
      return FALSE;
   end if;
   close get_user;
   return TRUE;
end;
-- ----------------------------------------------------------------------------
-- |----------------------------< check_person >------------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Check Person
--
--              Checks that a given person is active on a given date
--
Function check_person (p_person_id  in number,
                       p_date       in date) return boolean is
--
  -- cursor to check the existence of the person on a given date
  --
  Cursor c_person (l_date IN DATE) is  -- **** l_date added to cursor definition for bug #2154926
                                       -- **** l_date added to where clause for bug #2154926
    select 'X'
    from per_all_people_f
    where person_id = p_person_id
      and l_date between effective_start_date and effective_end_date;
  --
  l_dummy       varchar2(1);
  l_result      boolean;
  l_date        date;    --  **** added for bug #2154926
--
Begin
  --
  -- **** start added for bug #2154926
  --
  l_date := p_date;
  --
  if l_date = hr_api.g_date or l_date is null or l_date = hr_api.g_sot then
     -- l_date := get_session_date(USERENV('SESSIONID'));
     -- changed for bug 3242405.
     l_date := trunc(sysdate);
  end if;
  --
  -- **** end added for bug #2154926
  --
  open c_person (l_date);  -- **** l_date added for bug #2154926
  fetch c_person into l_dummy;
  l_result := c_person%found;
  close c_person;
  --
  Return l_result;
  --
End check_person;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< value_changed >----------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Value Changed (for varchar2 types)
--
--              Checks if two values are different
--
Function value_changed (p_old_value  in varchar2,
                        p_new_value  in varchar2) return boolean is
--
--
Begin
  --
  return nvl(p_old_value,hr_api.g_varchar2) <>
         nvl(p_new_value,hr_api.g_varchar2);
  --
End value_changed;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< value_changed >----------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Value Changed (for number types)
--
--              Checks if two values are different
--
Function value_changed (p_old_value  in number,
                        p_new_value  in number) return boolean is
--
--
Begin
  --
  return nvl(p_old_value,hr_api.g_number) <>
         nvl(p_new_value,hr_api.g_number);
  --
End value_changed;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< value_changed >----------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Value Changed (for date types)
--
--              Checks if two values are different
--
Function value_changed (p_old_value  in date,
                        p_new_value  in date) return boolean is
--
--
Begin
  --
  return nvl(p_old_value,hr_api.g_date) <>
         nvl(p_new_value,hr_api.g_date);
  --
End value_changed;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< char_to_number >----------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Converts character to number. Executed on the server
--              because clients are unable to read non-US values for
--              NLS_NUMERIC_CHARACTERS.
--
function char_to_number (p_input in varchar2) return number is
--
--
begin
--
  return to_number(p_input);
--
exception
  when others then
    raise;
--
end;
--
--------------------------------------------------------------------------------
function valid_currency (p_currency_code varchar2) return boolean is
--
--******************************************************************************
--* Returns TRUE if the currency exists on the currencies table.
--******************************************************************************
--
cursor csr_currency is
        select  1
        from    fnd_currencies
        where   currency_code = p_currency_code;
        --
l_currency_OK   boolean;
--
begin
--
--
open csr_currency;
fetch csr_currency into g_dummy;
l_currency_OK := csr_currency%found;
close csr_currency;
--
--
return l_currency_OK;
--
end valid_currency;
--------------------------------------------------------------------------------
procedure CHECK_CURRENCY_IS_VALID (p_currency_code varchar2) is
--
begin
--
if p_currency_code is not null and NOT Valid_currency (p_currency_code) then
  hr_utility.set_message (810,'OTA_13038_INVALID_CURRENCY');
  hr_utility.raise_error;
end if;
--
end check_currency_is_valid;
--------------------------------------------------------------------------------
function Valid_language (
--
--******************************************************************************
--* Returns TRUE if the language ID exists on the language table. If it does not
--* exist, then an error will be produced unless p_suppress_messages is set
--* to TRUE, in which case it will just return FALSE
--******************************************************************************
--
p_language_id           number ) return boolean is
--
cursor csr_language is
        select  1
        from    fnd_languages
        where   language_id = p_language_id;
        --
l_language_OK   boolean;
--
begin
--
--
open csr_language;
fetch csr_language into g_dummy;
l_language_OK := csr_language%found;
close csr_language;
--
--
return l_language_OK;
--
end valid_language;
--------------------------------------------------------------------------------
procedure CHECK_LANGUAGE_IS_VALID (p_language_id number) is
--
begin
--
if p_language_id is not null and NOT valid_language (p_language_id) then
  hr_utility.set_message (810,'OTA_13448_EVT_INVALID_LANGUAGE');
  hr_utility.raise_error;
end if;
--
end check_language_is_valid;
--------------------------------------------------------------------------------
function vendor_name (p_vendor_id number) return varchar2 is
--
--******************************************************************************
--* Returns the vendor_name for a vendor_ID.
--******************************************************************************
--
cursor csr_vendor is
        select  vendor_name
        from    po_vendors
        where   vendor_id = p_vendor_id;
        --
l_vendor_name   po_vendors.vendor_name%type := null;
--
begin
--
if p_vendor_id is not null then
  --
  open csr_vendor;
  fetch csr_vendor into l_vendor_name;
  close csr_vendor;
  --
end if;
--
return l_vendor_name;
--
end vendor_name;
--------------------------------------------------------------------------------
function Valid_vendor (
--
--******************************************************************************
--* Returns TRUE if the vendor name exists on the vendor table.
--******************************************************************************
--
p_vendor_name           varchar2 ) return boolean is
--
cursor csr_vendor is
        select  1
        from    po_vendors
        where   vendor_name = p_vendor_name;
        --
l_vendor_OK     boolean;

--
begin
--
--
open csr_vendor;
fetch csr_vendor into g_dummy;
l_vendor_OK := csr_vendor%found;
close csr_vendor;
--
return l_vendor_OK;
--
end valid_vendor;
--------------------------------------------------------------------------------
function Valid_vendor (
--
--******************************************************************************
--* Returns TRUE if the vendor ID exists on the vendor table.
--******************************************************************************
--
p_vendor_id             number,p_date date default null) return boolean is
--
cursor csr_vendor(l_date IN DATE) is
        select  1
        from    po_vendors
        where   vendor_id = p_vendor_id
	and nvl(end_date_active,to_date('31-12-4712', 'DD-MM-YYYY')) > l_date;
        --
l_vendor_OK     boolean;
l_date date;
--
begin
--
--
l_date := p_date;
if p_date is null then
l_date := to_date('01-01-1001','DD-MM-YYYY');
end if;
open csr_vendor(l_date);
fetch csr_vendor into g_dummy;
l_vendor_OK := csr_vendor%found;
close csr_vendor;
--
return l_vendor_OK;
--
--
end valid_vendor;
--------------------------------------------------------------------------------
function fnd_lang_desc
      (
      p_language_id number
      ) return varchar2 is
--
cursor csr_lookup is
  select description
   from fnd_languages_vl
   where language_id  = p_language_id;

--
v_description fnd_languages_vl.description%TYPE := null;
begin
if p_language_id  is not null  then
   --
    open csr_lookup;
    fetch csr_lookup into v_description;
    close csr_lookup;
end if;
--
return v_description;
--
end fnd_lang_desc;

--------------------------------------------------------------------------------
function hr_org_name
      (
      p_organization_id number
      ) return varchar2 is
--
cursor csr_lookup is
--Bug 2846475
select orgs_tl.name
from hr_all_organization_units orgs,hr_all_organization_units_tl orgs_tl
where orgs.organization_id = p_organization_id
      and orgs.organization_id = orgs_tl.organization_id
      and orgs_tl.language = userenv('LANG');
--  select name
--   from hr_organization_units
--   where organization_id  = p_organization_id;

--
v_description hr_all_organization_units.name%TYPE := null;
begin
if p_organization_id  is not null  then
   --
    open csr_lookup;
    fetch csr_lookup into v_description;
    close csr_lookup;
end if;
--
return v_description;
--
end hr_org_name;


--------------------------------------------------------------------------------
function fnd_currency_name
      (
      p_currency_code varchar2
      ) return varchar2 is
--
cursor csr_lookup is
  select name
   from fnd_currencies_vl
   where currency_code  = p_currency_code;

--
v_name fnd_currencies_vl.name%TYPE := null;
begin
if p_currency_code  is not null  then
   --
    open csr_lookup;
    fetch csr_lookup into v_name;
    close csr_lookup;
end if;
--
return v_name;
--
end fnd_currency_name;

---------------------------------------------------------------------------------
function fnd_lang_code
      (
      p_language_id number
      ) return varchar2 is
--
cursor csr_lookup is
  select language_code
   from fnd_languages_vl
   where language_id  = p_language_id;

--
v_language_code fnd_languages_vl.language_code%TYPE := null;
begin
if p_language_id  is not null  then
   --
    open csr_lookup;
    fetch csr_lookup into v_language_code;
    close csr_lookup;
end if;
--
return v_language_code;
--
end fnd_lang_code;

----------------------------------------------------------------------------------
procedure CHECK_VENDOR_IS_VALID (p_vendor_id number,p_date date default null) is
--
begin
--
if p_vendor_id is not null and NOT valid_vendor (p_vendor_id,p_date) then
  hr_utility.set_message (810,'OTA_13039_INVALID_VENDOR');
  hr_utility.raise_error;
end if;
--
end check_vendor_is_valid;
--------------------------------------------------------------------------------
/* Procedure get_defaults returns a number of values derived from the
   Business Group set up
*/
procedure get_defaults(p_business_group_id         in  number
                      ,p_default_activity_version  out nocopy varchar2
                      ,p_default_source_of_booking out nocopy varchar2
                      ,p_default_enrolment_status  out nocopy varchar2
                      ,p_overbooking_rule          out nocopy varchar2
                      ,p_autogen_scheduled_event   out nocopy varchar2
                      ,p_update_scheduled_event    out nocopy varchar2
                      ,p_autogen_development_event out nocopy varchar2
                      ,p_update_development_event  out nocopy varchar2) is
cursor get_default_values is
select null
,      null
,      null
,      null
,      null
,      null
,      null
,      null
from sys.dual;
begin
   open get_default_values;
   fetch get_default_values into p_default_activity_version
                                ,p_default_source_of_booking
                                ,p_default_enrolment_status
                                ,p_overbooking_rule
                                ,p_autogen_scheduled_event
                                ,p_update_scheduled_event
                                ,p_autogen_development_event
                                ,p_update_development_event;
   close get_default_values;
end;
--
procedure get_defaults(p_business_group_id        in  number
                      ,p_default_activity_version out nocopy varchar2) is
l_default_activity_version  varchar2(30);
l_default_source_of_booking varchar2(30);
l_default_enrolment_status  varchar2(30);
l_overbooking_rule          varchar2(150);
l_autogen_scheduled_event   varchar2(30);
l_update_scheduled_event    varchar2(30);
l_autogen_development_event varchar2(30);
l_update_development_event  varchar2(30);
begin
  get_defaults(p_business_group_id
              ,p_default_activity_version
              ,l_default_source_of_booking
              ,l_default_enrolment_status
              ,l_overbooking_rule
              ,l_autogen_scheduled_event
              ,l_update_scheduled_event
              ,l_autogen_development_event
              ,l_update_development_event);
end;

procedure get_defaults(p_default_source_of_booking out nocopy varchar2
                      ,p_default_enrolment_status  out nocopy varchar2
                      ,p_overbooking_rule          out nocopy varchar2) is
begin
   null;
end;

procedure get_defaults(p_autogen_scheduled_event out nocopy varchar2
                      ,p_update_scheduled_event  out nocopy varchar2) is
begin
   null;
end;

procedure get_defaults(p_autogen_development_event out nocopy varchar2
                      ,p_update_development_event  out nocopy varchar2) is
begin
   null;
end;

function get_business_group_id return number is
--
-- If the user has signed on through applications then returns the value
-- of the Business Group profile option otherwise returns null.
--
--
-- Note the check that the user has signed on is so that views which
-- would normally restrict on business group can be made to retrieve
-- all rows when running in sql*plus or other environments. By default
-- the Business Group Profile option is defined at site level to be
-- the Setup Business group.
--

begin

-- Below if condition commented out to avoid empty pages issues in eBS project.
--  if ( fnd_global.user_id = -1 ) then
--     return(null);
--  else
     if (fnd_profile.value('OTA_HR_GLOBAL_BUSINESS_GROUP_ID'))is not null then
		return(fnd_profile.value('OTA_HR_GLOBAL_BUSINESS_GROUP_ID'));
     else
        return(fnd_profile.value('PER_BUSINESS_GROUP_ID'));
     end if;
--  end if;

end get_business_group_id ;


function get_training_center (p_training_center_id in number)
return varchar2
IS
l_business_group_id number;
l_training_center hr_all_organization_units.name%TYPE;

CURSOR c_get_training_center
IS
SELECT  org.name
FROM  hr_all_organization_units org, hr_organization_information ori
WHERE org.business_group_id = l_business_group_id
      AND org.organization_id = p_training_center_id
      AND org.organization_id = ori.organization_id
      AND ori.org_information_context = 'CLASS'
      AND ori.org_information1 ='OTA_TC';

BEGIN
 l_business_group_id := OTA_GENERAL.get_business_group_id;
 For a in c_get_training_center
 loop
   l_training_center := a.name;
 end loop;
 return(l_training_center);

end get_training_center ;


function get_location (p_location_id in number)
return varchar2  IS

l_location_code    hr_locations.location_code%type;

CURSOR c_get_location IS
SELECT  loc.location_code
FROM  hr_locations_all  loc
WHERE loc.Location_id = p_location_id;

BEGIN
 For a in c_get_location
 loop
   l_location_code := a.location_code;
 end loop;
 return(l_location_code);

end get_location ;

FUNCTION get_finance (p_booking_id in number)
return number
  IS
  Cursor
  C_finance
  IS
  SELECT count(*) total
  FROM ota_finance_lines fl,
  ota_finance_headers fh
  where fl.booking_id = p_booking_id and
  fh.finance_header_id = fl.Finance_header_id and
   fh.type= 'CT' and
   fl.cancelled_flag  ='Y';
  l_return  number;

  Begin
    For r_fl in c_finance
    LOOP
        l_return := r_fl.total;
    END LOOP;
      return(l_return);
  end;

--------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
-- |-------------------------< Get_Location_Code >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description: Get the location code for the location id passed in as a parameter.
--
--
FUNCTION get_Location_code(p_location_id IN NUMBER) RETURN VARCHAR2
IS
  --
CURSOR loc_country_cr IS
SELECT loc.location_code
  FROM hr_locations_all_tl loc
 WHERE loc.location_id = p_location_id
   AND loc.language = USERENV('LANG');

  --
  l_loc_code	hr_locations_all.location_code%TYPE := null;
  --
BEGIN
  --
  --
  --
  -- get country for OM org

    if p_location_id is not null then
    --
	FOR loc_country IN loc_country_cr
       LOOP
	    l_loc_code := loc_country.location_code;

	END LOOP;

      end if;
RETURN l_loc_code;
    --
  --
EXCEPTION
     WHEN others then
   RETURN l_loc_code;
END get_location_code;

--------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
-- |-------------------------< Get_Org_Name  >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description: get the name for the organization id passed in.
--
--
FUNCTION get_org_name(p_organization_id IN NUMBER) RETURN VARCHAR2
IS
  --
CURSOR org_name_cr IS
SELECT org.name
  FROM hr_all_organization_units_tl org
 WHERE org.organization_id = p_organization_id
   AND org.language = USERENV('LANG');

  --
  l_org_name	hr_all_organization_units.name%TYPE := null;
  --
begin
  --
  --
  --
  -- get country for OM org

    if p_organization_id is not null then
    --
	FOR org_name IN org_name_cr
       LOOP
	    l_org_name := org_name.name;

	END LOOP;

      end if;
RETURN l_org_name;
    --
  --
EXCEPTION
     WHEN others then
   RETURN l_org_name;
END get_org_name;
--
--------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
-- |-------------------------< get_legislation_code  >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description: get the legislation code of the business group
--
--
FUNCTION get_legislation_code
RETURN VARCHAR2
IS
  CURSOR csr_get_legislation_code IS
    SELECT PBG.legislation_code
    FROM per_business_groups PBG
    WHERE PBG.business_group_id = ota_general.get_business_group_id;

  l_legislation_code per_business_groups.legislation_code%TYPE;
BEGIN
   OPEN csr_get_legislation_code;
   FETCH csr_get_legislation_code INTO l_legislation_code;
   CLOSE csr_get_legislation_code;

   RETURN l_legislation_code;

END get_legislation_code;
end     OTA_GENERAL;

/
