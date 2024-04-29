--------------------------------------------------------
--  DDL for Package OTA_GENERAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_GENERAL" AUTHID CURRENT_USER as
/* $Header: otgenral.pkh 120.3 2005/07/20 01:02:44 dbatra noship $ */
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
        10 Nov 94       M Roychowdhury       Added check for dates
        11 Nov 94       M Roychowdhury       Added check for person
                                             Added value changed function
        17 Nov 94       M Roychowdhury       Added check for current employee
        31 Aug 94       J Rhodes             Added check_fnd_user
        31 Aug 94       J Rhodes             Added get_fnd_user
        16 Feb 96       G Perry              Added get_session_date
  10.14 29 Mar 96       S Shah               Added check_par_child_dates_fun
  110.1 03 Sep 97       K habibul            Fixed problem with 255 chrs width
  110.2 03-Dec-98       C Tredwin            Added char_to_number
  115.2 11-OCT-99       R Raina    Added function fnd_lang_desc
  115.3 12-OCT-99       R Raina    Added function fnd_currency_name,
                                                  fnd_lang_code,
                                                  hr_org_name
  115.4 11-MAY-01	D HMulia   Added function get_training_center ,
				         function get_location
  115.5 10-JUL-01       D Hulia    Added Function get_finance.
  115.8 29-Nov-02       Jbharath   Bug#2684733 NOCOPY added for IN OUT/OUT arguments of procedure
  115.9 03-Nov-2004     sgokhale      Bug  3953333 Validation for checking vendor validity wrt start date
 rem 115.10 07-Apr-05   dbatra      Added get_event_name and get_course_name
 rem 115.11 30-Jun-05   dbatra  4465618    Modified get_course_name signature
 rem 115.12 18-Jul-05   rdola   4490656 Added get_legislation_code method
 rem 115.13 20-Jul-2005 dbatra  4496361 Added get_offering_name
*/
--------------------------------------------------------------------------------
--
function get_event_name (p_event_id in number)
return varchar2;

function get_offering_name (p_offering_id in number)
return varchar2;

function get_course_name (p_activity_version_id in number default null,p_eventid in number default null)
return varchar2;

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
Return boolean;
--
-- ----------------------------------------------------------------------------
-- |------------------------< check_domain_value >----------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
--
-- Description : Used to check if a value is in the specified domain
--
Procedure check_domain_value
  (
   p_domain_type        in  varchar2
  ,p_domain_value       in  varchar2
  );
-- ----------------------------------------------------------------------------
-- |------------------------< get_session_date >------------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
--
-- Description : Get session date from dual
--
function get_session_date(p_session_id number) return date;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< check_start_end_date >-----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
--
-- Description:
--   Validates the startdate and enddate.
--   p_start_date must be less than, or equal to, p_end_date.
--
Procedure check_start_end_dates
  (
   p_start_date     in     date
  ,p_end_date       in     date
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< check_par_child_dates >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PUPLIC
--
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
  );
--
-- ----------------------------------------------------------------------------
-- |-----------------------< check_par_child_dates_fun >----------------------|
-- ----------------------------------------------------------------------------
--
-- PUPLIC
--
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
  ) Return Boolean;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< check_start_end_time >-----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
--
-- Description:
--   Validates the starttime and endtime.
--   start_time must be less than, or equal to, end_time.
--
Procedure check_start_end_time
  (
   p_start_time     in     varchar2
  ,p_end_time       in     varchar2
  );
--
-- ----------------------------------------------------------------------------
-- |----------------------------< get_fnd_user >----------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Get FND USER
--
--
function get_fnd_user(p_user_id in number)
  return varchar2;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------------< check_fnd_user >----------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Check Person
--
--              Checks that a given person is active on a given date
--
Function check_fnd_user(p_user_id  in number) return boolean;
--
--
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
                       p_date       in date) return boolean;
--
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< value_changed >----------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description: Value Changed (overloaded function)
--
--              Checks if two values are different
--
Function value_changed (p_old_value  in varchar2,
                        p_new_value  in varchar2) return boolean;
--
Function value_changed (p_old_value  in number,
                        p_new_value  in number) return boolean;
--
Function value_changed (p_old_value  in date,
                        p_new_value  in date) return boolean;
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
function char_to_number (p_input in varchar2) return number;
--
--
--------------------------------------------------------------------------------
function valid_vendor (p_vendor_id              number,p_date date default null) return boolean;
function valid_vendor ( p_vendor_name           varchar2) return boolean;
procedure check_vendor_is_valid (p_vendor_id number,p_date date default null);
--------------------------------------------------------------------------------
function valid_currency (p_currency_code        varchar2) return boolean;
procedure check_currency_is_valid (p_currency_code varchar2);
--------------------------------------------------------------------------------
function valid_language (p_language_id          number) return boolean;
procedure check_language_is_valid (p_language_id number);
--------------------------------------------------------------------------------
function vendor_name (  p_vendor_id     number) return varchar2;
-- The following pragma allows this function to be used in SQL views
pragma restrict_references (vendor_name, WNDS, WNPS);
--------------------------------------------------------------------------------
function fnd_lang_desc  (
                        p_language_id number
                        ) return varchar2;
pragma restrict_references (fnd_lang_desc, WNPS,WNDS);

-------------------------------------------------------------------------------
function fnd_currency_name  (
                        p_currency_code varchar2
                        ) return varchar2;
pragma restrict_references (fnd_lang_desc, WNPS,WNDS);


--------------------------------------------------------------------------------
function fnd_lang_code  (
                        p_language_id number
                        ) return varchar2;
pragma restrict_references (fnd_lang_code, WNPS,WNDS);

--------------------------------------------------------------------------------
function hr_org_name  (
                        p_organization_id  number
                        ) return varchar2;
pragma restrict_references (hr_org_name, WNPS,WNDS);

---------------------------------------------------------------------------------
procedure get_defaults(p_business_group_id in number
                      ,p_default_activity_version out nocopy varchar2);
procedure get_defaults(p_default_source_of_booking out nocopy varchar2
                      ,p_default_enrolment_status  out nocopy varchar2
                      ,p_overbooking_rule          out nocopy varchar2);
procedure get_defaults(p_autogen_scheduled_event out nocopy varchar2
                      ,p_update_scheduled_event  out nocopy varchar2);
procedure get_defaults(p_autogen_development_event out nocopy varchar2
                      ,p_update_development_event  out nocopy varchar2);
--------------------------------------------------------------------------------

function get_business_group_id return number ;
--
-- If the user has signed on through applications then returns the value
-- of the Business Group profile option otherwise returns null.
--
-- Note the check that the user has signed on is so that views which
-- would normally restrict on business group can be made to retrieve
-- all rows when running in sql*plus or other environments. By default
-- the Business Group Profile option is defined at site level to be
-- the Setup Business group.
--

function get_training_center (p_training_center_id in number)
return varchar2 ;


function get_location (p_location_id in number)
return varchar2 ;

FUNCTION get_finance (p_booking_id in number)
return number ;

-- ----------------------------------------------------------------------------
-- |-------------------------< get_Location_code  >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description: get the location code for the id passed in as a parameter.
--
--
FUNCTION get_Location_code(p_location_id IN NUMBER) RETURN VARCHAR2;
-- ----------------------------------------------------------------------------
-- |-------------------------< get_org_name >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description: get the name for the organization id passed in as a parameter.
--
--

FUNCTION get_org_name(p_organization_id IN NUMBER) RETURN VARCHAR2;

--
--------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------
-- |-------------------------< get_legislation_code  >----------------------------|
-- ----------------------------------------------------------------------------
--
-- Description: get the legislation code of the business group
--
--
FUNCTION get_legislation_code RETURN VARCHAR2;

end     OTA_GENERAL;

 

/
