--------------------------------------------------------
--  DDL for Package HR_GENERAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_GENERAL" AUTHID CURRENT_USER as
/* $Header: hrgenral.pkh 120.0 2005/05/29 02:30:57 appldev noship $ */
------------------------------------------------------------------------------
/*
+==============================================================================+
|                       Copyright (c) 1994 Oracle Corporation                  |
|                          Redwood Shores, California, USA                     |
|                               All rights reserved.                           |
+==============================================================================+
Name
        General HR Utilities
Purpose
        To provide widely used functions in a single shared area
        Other general purpose routines can be found in hr_utility and hr_chkfmt.

        See the package body for details of the functions.
History
         1 Mar 94       N Simpson       Created
         2 Mar 94       PK Attwood      Added init_forms procedure. Corrected
                                        show errors statement.
         4 Mar 94       N Simpson       Added functions to return constants
        27 Apr 94       N Simpson       Added function LOCATION_VALID
        27 Apr 94       N Simpson       Corrected location_valid datatypes
        17 Oct 94       N Simpson       Added restrict_references to
                                        decode_lookup
        16 Jan 95       N Simpson       Added overloaded DEFAULT_CURRENCY_CODE
                                        using p_business_group_id
        15 Mar 95       R Fine          Allowed a session date to be passed in
                                        to init_forms.
        23 Jun 95       D Kerr          Added bg_name and bg_legislation_code
                                        to init_forms together with temp.
                                        overloaded version.
        11 Mar 95       A Forte         Added function calls DECODE_GRADE to
                                        DECODE_ASS_STATUS_TYPE which are called
                                        from peasg03v.sql which allowed the
                                        elimination of outer joins and enhanced
                                        the performance of the asssignments
                                        folder PERWSFAS. Bug 343096.
        13 Jun 96       A.Mills         Added function definition for
                                        GET_SALARY, used by view per
                                        _expanded_assignments_v1, for bug
                                        336409.
        09 DEC 96       Ty Hayden       Added function GET_WORK_PHONE and
                                        GET_HOME_PHONE
        12 DEC 96       Ty Hayden       Modified GET_WORK_PHONE and
                                        GET_HOME_PHONE to be more efficient.

        20 DEC 96       D. Kerr         init_forms: removed temporary overload
                                        Removed p_commit and added
                                        p_enable_hr_trace
        02 APR 1997     HPATEL          Added functions CHK_APPLICATION_ID,
                                        CORE_HR_APP_ID and VERTICAL_APP_ID
    Name     Date      Versn  Bug       Text
    ========================================================================
    rfine    29-Apr-97 40.23  n/a       Leapfrogged from 40.21 over special
                                        p15.1 version. Only change is this
                                        comment in change history.
    dkerr    27-Jul-97 110.3  n/a       Added :
                                           char_to_bool
                                           bool_to_char
                                           get_application_short_name
                                           hrms_object
        19 Aug 97       Sxshah  Banner now on eack line.
    mhoyes   27-AUG-97 110.4  n/a       Added chk_geocodes_installed.
    dkerr    19-OCT-97 110.8  n/a       Added get_business_group_id
    mshah    09-OCT-97 110.9  n/a       Added proc set_calling_context
                                        and function get_calling_context
    fychu    16-Dec-97 110.10 n/a       Added function get_phone_number
                                        from per_phones table.
    fychu    19-Dec-97 110.11 n/a       Fixed the version number in the log.
    dkerr    06-Jan-98 110.12 n/a       char_to_bool/bool_to_char now public
    dkerr    20_MAR-98 40.25  643828    Added DECODE_PEOPLE_GROUP
    ccarter  23-DEC-98 115.2            Added chk_product_installed function.
    sxshah   13-Jan-99 115.3            Added g_data_migrator_mode variable
                                        which will be used by the HRMS
                                        data migrator process.
    sxshah   29-Jan-99 115.4            Default for above var to 'N'
    ccarter  03-Jun-99 115.5            Added get_user_status function.
    skekkar  23-AUG-99 115.6            Added decode_territory ,
                                        decode_organization and
                                        decode_availability_status functions
    hsajja   25-AUG-99 115.7            Added decode_position_current_name
                                        function
    darora   27-Sep-99 115.11           Included functions - DECODE_POSITION_LATEST_NAME,
                                        and DECODE_STEP
    rraina   29-Sep-99 115.9     985430   Added decode_ar_lookup and
                                        hr_lookup_locations functions
    hsajja   01-OCT-99 115.10            Added decode_latest_position_def_id
                                        ,decode_avail_status_start_date function
    hsajja   04-OCT-99 115.12           Added get_position_date_end function
    pzwalker 05-OCT-99 115.12           removed pragma to decode_lookups
    hsajja   07-OCT-99 115.13           Added functions DECODE_PERSON_NAME,
                                        DECODE_GRADE_RULE.
    hsajja   12-OCT-99 115.14           Added Commit at the end
    rraina  10-NOV-1999 115.15           added decode_fnd_comm_lookup for ota views opt
    dkerr    10-NOV-99 115.16           Added p_hr_trace_dest parameter to
                                        init_forms
    cxsimpso 28-DEC-99 115.17           Added get_validation_name function.
    mbocutt  03/01/2000 115.18 1125512  Remove pragma from get_business_group_id
    hsajja   21/02/2000 115.25          Included function DECODE_SHARED_TYPE
    rvydyana 24/05/2000 115.27          Added new function get_xbg_profile
    tcewis   29-FEB-00 115.21           added the function chk_maintain_tax
                                         records.
    arashid  13-OCT-00 115.22           Added a cover routine for:
                                        DBMS_DESCRIBE.DESCRIBE_PROCEDURE to
                                        compile an invalid package. The new
                                        routine is called: DESCRIBE_PROCEDURE.
    stlocke  23-JAN-2001 115.33         Added procedure init-fndload.
    stlocke  08-FEB-2001 115.34         Procedure init-fndload removed.
    hsajja   18-JAN-2002 115.25         added dbdrv command
    hsajja   18-JAN-2002 115.26         replaced -- with rem before create package
    adhunter 28-AUG-2002 115.27         correct gscc warning
    dsaxby   04-DEC-2002 115.28 2692195 Nocopy changes.
    ynegoro  23-JUL-2003 115.29         Added DECODE_GRADE_LADDER function
    hsajja   10-DEC-2004 115.30 3663875 Changed DECODE_POSITION_LATEST_NAME
                                        function
-------------------------------------------------------------------------------

    DO NOT ADD ANY FUTHER PROCEDURES / FUNCTIONS TO THIS FILE!

    IF REQUIRED PLEASE ADD TO HR_GENRAL2 (hrgenrl2.pkh/pkb)

-------------------------------------------------------------------------------

*/
g_data_migrator_mode varchar2(1) := 'N';
-------------------------------------------------------------------------
--Due to bug 286699 you cannot use restrict references for boolean returns
--prior to 8.0.3/7.3.4
function char_to_bool (p_value in varchar2) return boolean ;
pragma restrict_references (char_to_bool, WNPS, RNPS, WNDS, RNDS);
-------------------------------------------------------------------------
function bool_to_char (p_value in boolean) return varchar2 ;
pragma restrict_references (bool_to_char, WNPS, RNPS, WNDS, RNDS);
-------------------------------------------------------------------------
procedure assert_condition (p_condition in boolean);
pragma restrict_references (assert_condition, WNPS, WNDS, RNPS, RNDS);
-------------------------------------------------------------------------
function GET_BUSINESS_GROUP_ID  return number;
-------------------------------------------------------------------------
function CHK_APPLICATION_ID (p_application_id number) return varchar2;
pragma restrict_references (chk_application_id, WNPS, WNDS, RNPS, RNDS);
-------------------------------------------------------------------------
function CORE_HR_APP_ID (p_application_id number) return varchar2;
pragma restrict_references (core_hr_app_id, WNPS, WNDS, RNPS, RNDS);
-------------------------------------------------------------------------
function VERTICAL_APP_ID (p_application_id number) return varchar2;
pragma restrict_references (vertical_app_id, WNPS, WNDS, RNPS, RNDS);
-------------------------------------------------------------------------
function HRMS_OBJECT (p_object_name in varchar2) return varchar2;
pragma restrict_references (hrms_object, WNPS, WNDS);
-------------------------------------------------------------------------
function GET_APPLICATION_SHORT_NAME (p_application_id in varchar2) return varchar2;
pragma restrict_references (get_application_short_name, WNPS, WNDS, RNPS);
-------------------------------------------------------------------------
function EFFECTIVE_DATE return date;
pragma restrict_references (effective_date, WNPS, WNDS);
-------------------------------------------------------------------
function START_OF_TIME  return date;
pragma restrict_references (start_of_time, WNPS,WNDS);
-------------------------------------------------------------------------
function END_OF_TIME    return date;
pragma restrict_references (end_of_time, WNPS,WNDS);
-------------------------------------------------------------------------
function PAY_VALUE      return varchar2;
pragma restrict_references (pay_value, WNPS,WNDS);
-------------------------------------------------------------------------
function MONEY_UNIT     return varchar2;
-------------------------------------------------------------------------
function DEFAULT_CURRENCY_CODE (p_legislation_code varchar2) return varchar2;
-------------------------------------------------------------------------
function DEFAULT_CURRENCY_CODE (p_business_group_id number) return varchar2;
-------------------------------------------------------------------------
function LOCATION_VALID (       p_location_id           number,
                                p_date                  date,
                                p_error_if_invalid      boolean default TRUE
        ) return boolean;
-------------------------------------------------------------------------
function DECODE_LOOKUP (        p_lookup_type varchar2,
                                p_lookup_code varchar2) return varchar2;
-- pragma restrict_references (decode_lookup,  WNPS,WNDS);
-------------------------------------------------------------------------
function DECODE_FND_COMM_LOOKUP (       p_lookup_type varchar2,
                                p_lookup_code varchar2) return varchar2;
-- pragma restrict_references (decode_lookup,  WNPS,WNDS);
----------------------------------------------------------------------
function DECODE_GRADE (p_grade_id number) return varchar2;
pragma restrict_references (decode_grade, WNPS,WNDS);
------------------------------------------------------------
function DECODE_GRADE_LADDER (p_grade_ladder_pgm_id number) return varchar2;
pragma restrict_references (decode_grade_ladder, WNPS,WNDS);
------------------------------------------------------------
function DECODE_PAYROLL (p_payroll_id number) return varchar2;
pragma restrict_references (decode_payroll, WNPS, WNDS);
------------------------------------------------------------
function GET_SALARY (p_pay_basis_id number, p_assignment_id number)
return varchar2;
pragma restrict_references (get_salary, WNPS, WNDS);
--------------------------------------------------------------------
function DECODE_JOB (p_job_id number) return varchar2;
pragma restrict_references (decode_job, WNPS, WNDS);
------------------------------------------------------------
function DECODE_POSITION (p_position_id number) return varchar2;
pragma restrict_references (decode_position, WNPS, WNDS);
------------------------------------------------------------
function DECODE_LOCATION (p_location_id number) return varchar2;
pragma restrict_references (decode_location, WNPS, WNDS);
------------------------------------------------------------
function DECODE_PAY_BASIS (p_pay_basis_id number) return varchar2;
pragma restrict_references (decode_pay_basis, WNPS, WNDS);
------------------------------------------------------------
function DECODE_ASS_STATUS_TYPE (p_assignment_status_type_id number,
                                 p_business_group_id         number)
                  return varchar2;
pragma restrict_references (decode_ass_status_type, WNPS, WNDS);
------------------------------------------------------------
function GET_WORK_PHONE (
         p_person_id              number) return varchar2;
pragma restrict_references (get_work_phone, WNPS, WNDS);
------------------------------------------------------------
function GET_HOME_PHONE (
         p_person_id              number) return varchar2;
pragma restrict_references (get_home_phone, WNPS, WNDS);
------------------------------------------------------------
function DECODE_PEOPLE_GROUP (p_people_group_id number) return varchar2;
pragma restrict_references (decode_people_group, WNPS, WNDS);
------------------------------------------------------------
function decode_ar_lookup (
                        p_lookup_type varchar2,
                        p_lookup_code varchar2) return varchar2;
--pragma restrict_references (decode_ar_lookup, RNPS,RNDS);
------------------------------------------------------------------
function hr_lookup_locations(
                       p_location_id number) return varchar2;
pragma restrict_references (hr_lookup_locations,WNPS,WNDS);
  -----------------------------------------------------------------------------
  -- Name                                                                    --
  --   init_forms                                                            --
  -- Purpose                                                                 --
  --   This procedure obtains session date from fnd_sessions and             --
  --   short_name, legislation_code values from per_business_groups. If      --
  --   there is no row in fnd_sessions for this session, one will be         --
  --   inserted. p_session_date will then set to trunc(sysdate).             --
  --   If a null business group id is past in p_short_name and               --
  --   p_legislation_code will be set to null. Otherwise their               --
  --   values are obtained from per_business_groups.                         --
  -- Arguments                                                               --
  --   In :-                                                                 --
  --   p_business_group_id should be set to the AOL business group profile   --
  --                       value.                                            --
  --   Out :-                                                                --
  --   p_short_name        If p_business_group_id is not null p_short_name   --
  --                       will be set to short_name from                    --
  --                       per_business_groups. If p_business_group_id is    --
  --                       null p_short_name will be null.                   --
  --   p_bg_name           If p_business_group_id is not null p_bg_name      --
  --                       is set to name from per_business_groups           --
  --   p_bg_currency_code  If p_business_group_id is not null p_bg_currency_ --
  --                       code is set to currency_code from per_business    --
  --                       groups.
  --   p_legislation_code  If p_business_group_id is not null                --
  --                       p_legislation_code will be set to                 --
  --                       legislation_code from per_business_groups. If     --
  --                       p_business_group_id is null p_legislation_code    --
  --                       will be null.                                     --
  --   p_session_date      is set to the session date from fnd_sessions. If  --
  --                       no row existed in fnd_sessions p_session_date is  --
  --                       set to trunc(sysdate).                            --
  --                       From 15.03.95., it is an IN OUT parameter. This   --
  --                       is so a date other than sysdate can be passed     --
  --                       in, and the new row in fnd_sessions has this date.--
  --   p_ses_yesterday     set to p_session_date minus one day.              --
  --   p_start_of_time     set to 01-JAN-0001.                               --
  --   p_end_of_time       set to 31-DEC-4712.                               --
  --   p_sys_date          set to sysdate.                                   --
  --   p_enable_hr_trace   Set to TRUE if trace is required for the forms    --
  --                       session.                                          --
  --   p_hr_trace_dest     If p_enable_hr_trace is TRUE then this parameter  --
  --                       is used to set the TRACE_DEST option              --
  -- Notes                                                                   --
  --   None.                                                                 --
-- --------------------------------------------------------------------------
--
--
procedure set_calling_context(p_calling_context IN VARCHAR2);
--
  -----------------------------------------------------------------------------
--
  PROCEDURE init_forms(p_business_group_id    IN  NUMBER,
                       p_short_name           OUT nocopy VARCHAR2,
                       p_bg_name              OUT nocopy VARCHAR2,
                       p_bg_currency_code     OUT nocopy VARCHAR2,
                       p_legislation_code     OUT nocopy VARCHAR2,
                       p_session_date      IN OUT nocopy DATE,
                       p_ses_yesterday        OUT nocopy DATE,
                       p_start_of_time        OUT nocopy DATE,
                       p_end_of_time          OUT nocopy DATE,
                       p_sys_date             OUT nocopy DATE,
                       p_enable_hr_trace      IN  BOOLEAN,
                       p_hr_trace_dest        IN  VARCHAR2 DEFAULT 'DBMS_PIPE');
--
--
--  ---------------------------------------------------------------------------
--  |----------------------<  chk_geocodes_installed   >----------------------|
--  ---------------------------------------------------------------------------
--
--  Description:
--    Determines if GEOCODES is installed.
--
--  Pre-conditions:
--    None
--
--  In Arguments:
--    None
--
--  Out Arguments:
--    None
--
--  Post Success:
--    - When rows exist in the table pay_us_city_names then the value 'Y' is
--    returned.
--    - When rows do not exist in the table pay_us_city_names then the value 'N' is
--    returned.
--
--  Post Failure:
--    None
--
--  Access Status:
--    Public
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--
function chk_geocodes_installed
  return varchar2;
--
-- ----------------------------------------------------------------------------
--
function get_calling_context
  return varchar2;
--
--  ---------------------------------------------------------------------------
--  |----------------------<  get_phone_number  >-----------------------------|
--  ---------------------------------------------------------------------------
--  Description:
--    Retrieve phone number by person_id, phone_type, and effective_date.
--    Different phone_types can be found in hr_common_lookups where lookup_type
--     = 'PHONE_TYPE'.
--

function get_phone_number
         (p_person_id       in number
         ,p_phone_type      in varchar2
         ,p_effective_date  in date default null)
  return varchar2;
  pragma restrict_references (get_phone_number, WNPS, WNDS);
--
-- ----------------------------------------------------------------------------
function chk_product_installed(p_application_id in number)
  return varchar2;
-- ----------------------------------------------------------------------------
function get_user_status(p_assignment_status_type_id in number)
  return varchar2;
-- ----------------------------------------------------------------------------
function DECODE_TERRITORY (p_territory_code varchar2) return varchar2;
------------------------------------------------------------
function DECODE_ORGANIZATION (p_organization_id number) return varchar2;
------------------------------------------------------------
function DECODE_AVAILABILITY_STATUS (p_availability_status_id number) return varchar2;
------------------------------------------------------------
function DECODE_POSITION_CURRENT_NAME (p_position_id in number) return varchar2;
------------------------------------------------------------
function DECODE_POSITION_LATEST_NAME (p_position_id in number,
                                      p_effective_date   in date default null
                                     ) return varchar2;
------------------------------------------------------------
function DECODE_STEP ( p_step_id           number, p_effective_date    date) return varchar2;
------------------------------------------------------------
function DECODE_LATEST_POSITION_DEF_ID (p_position_id in number) return number;
------------------------------------------------------------
function DECODE_AVAIL_STATUS_START_DATE (p_position_id in number,
p_availability_status_id number,p_effective_date date) return date;
------------------------------------------------------------
function GET_POSITION_DATE_END (p_position_id in number) return date;
------------------------------------------------------------
function DECODE_PERSON_NAME ( p_person_id           number) return varchar2;
------------------------------------------------------------
function DECODE_GRADE_RULE ( p_grade_rule_id           number) return varchar2;
------------------------------------------------------------------
-- Function to return localization specific lookup_type (validation_name)
-- for given core lookup_type (validation_type) or return core lookup_type
-- (validation_type) if none found.
--
function GET_VALIDATION_NAME(p_target_location VARCHAR2
					   ,p_field_name VARCHAR2
					   ,p_legislation_code VARCHAR2
					   ,p_validation_type VARCHAR2) return varchar2;
pragma restrict_references(get_validation_name, WNPS, WNDS);
-------------------------------------------------------------------
function decode_shared_type (
   p_shared_type_id      number) return varchar2;
-------------------------------------------------------------------
function get_xbg_profile return varchar2;
--pragma restrict_references (get_xbg_profile, WNPS, WNDS, RNPS, RNDS);
-------------------------------------------------------------------
function  chk_maintain_tax_records return varchar2;
-- ---------------------------------------------------------------------------
-- |----------------------< describe_procedure >-----------------------------|
-- ---------------------------------------------------------------------------
-- Description:
-- Cover routine for DBMS_DESCRIBE.DESCRIBE_PROCEDURE. If describe_procedure
-- fails because a package is not compiled, it will attempt to compile the
-- package and call DESCRIBE_PROCEDURE again. Other DESCRIBE_PROCEDURE errors
-- will be propagated upwards.
-- Notes:
-- If the attempted package compilation fails, the standard -20003 exception
-- from DBMS_DESCRIBE.DESCRIBE_PROCEDURE will be returned. This procedure does
-- not raise any exceptions other then the ones raised by DESCRIBE_PROCEDURE.
-- ---------------------------------------------------------------------------
procedure describe_procedure
(object_name    in  varchar2
,reserved1      in  varchar2
,reserved2      in  varchar2
,overload       out nocopy dbms_describe.number_table
,position       out nocopy dbms_describe.number_table
,level          out nocopy dbms_describe.number_table
,argument_name  out nocopy dbms_describe.varchar2_table
,datatype       out nocopy dbms_describe.number_table
,default_value  out nocopy dbms_describe.number_table
,in_out         out nocopy dbms_describe.number_table
,length         out nocopy dbms_describe.number_table
,precision      out nocopy dbms_describe.number_table
,scale          out nocopy dbms_describe.number_table
,radix          out nocopy dbms_describe.number_table
,spare          out nocopy dbms_describe.number_table
);


end     HR_GENERAL;

 

/

  GRANT EXECUTE ON "APPS"."HR_GENERAL" TO "EBSBI";
