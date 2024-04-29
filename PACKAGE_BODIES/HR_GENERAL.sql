--------------------------------------------------------
--  DDL for Package Body HR_GENERAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_GENERAL" as
/* $Header: hrgenral.pkb 120.3.12010000.2 2008/10/07 08:21:44 nerao ship $ */
------------------------------------------------------------------------------
/*
+==============================================================================+
|                       Copyright (c) 1994 Oracle Corporation                  |
|                          Redwood Shores, California, USA                     |
|                               All rights reserved.                           |
+==============================================================================+
Name
        General HR utilities
Purpose
        To provide widely used functions in a single shared area
History
         1 Mar 94       N Simpson       Created
         2 Mar 94       PK Attwood      Added init_forms procedure
         4 Mar 94       N Simpson       Added constants and functions to
                                        return them
        27 Apr 94       N Simpson       Added function LOCATION_VALID
        27 Apr 94       N Simpson       Corrected location_valid datatypes
        11 May 94       PK Attwood      Added extra exception condition to
                                        init_forms procedure.
        05 Oct 94       R Fine          Changed call from dtfndate to dt_fndate
                                        as package has been renamed
        17 Oct 94       N Simpson       Modified decode_lookup to avoid
                                        cursor fetch if parameters are null
        24 Nov 94       R Fine          Suppressed index on business_group_id
        16 Jan 95       N Simpson       Added overloaded default_currency_code
                                        using business group
        15 Mar 95       R Fine          Allowed a session date to be passed in
                                        to init_forms. Now that we have to put
                                        a row in fnd_sessions every time we
                                        open a form, the initial value is not
                                        always sysdate.
        18 Apr 95       N Simpson       Added check_HR_version
        23 Jun 95       D Kerr          Added bg_name and bg_legislation_code
                                        to init_forms together with temp.
                                        overloaded version.
        4  Sep 95       N Simpson       Changed error message in
                                        default_currency_code.
        11 Mar 96       A Forte         Added functions DECODE_GRADE to
                                        DECODE_ASS_STATUS_TYPE called from
                                        peasg03v.sql to eliminate the need
                                        for outer joins and enhance the
                                        performance of the Assignments folder
                                        PERWSFAS. Bug 343096.
        16 Apr 96       D Kerr          Bug 358870
                                        Ensure that ses_yesterday is maintained
                                        correctly in init_forms.
        13 Jun 96       A.Mills         Added function GET_SALARY used by the
                                        view per_expanded_assignments_v1, to
                                        speed performance of PERWILAS.  Bug
                                        336409. Also added sessionid check to
                                        DECODE_PAYROLL.
        09 DEC 96       Ty Hayden       Added function GET_WORK_PHONE and
                                        GET_HOME_PHONE
        12 DEC 96       Ty Hayden       Modified GET_WORK_PHONE and
                                        GET_HOME_PHONE to be more efficient.
        22 DEC 96       D. Kerr         init_forms:removed unncessary overload
                                        Removed p_commit and added
                                        p_enable_hr_trace
        02 APR 1997     HPATEL          Added function CHK_APPLICATION_ID,
                                        CORE_HR_APP_ID and VERTICAL_APP_ID
        14 APR 1997     HPATEL          Added calls CORE_HR_APP_ID and
                                        VERTICAL_APP_ID to CHK_APPLICATION_ID

    Name     Date      Versn  Bug       Text
    ========================================================================
    rfine    29-Apr-97 40.29  n/a       Leapfrogged from 40.27 over special
                                        p15.1 version. Only change is this
                                        comment in change history.
    dkerr    27-Jul-97 110.3  n/a       Added :
                                           char_to_bool
                                           bool_to_char
                                           get_application_short_name
                                           hrms_object
    dkerr    29-Jul-97 110.3  n/a       Added PE_ to HRMS_OBJECT
    dkerr    08-AUG-97 110.4  n/a       Added OTV_ to HRMS_OBJECT
                                        Added EFFECTIVE_DATE function.
    Iharding                            Changed get_work_phone so that
                                        PER_PEOPLE is not searched.
        Sxshah 19 Aug 97                Banner now on eack line.
    mhoyes   27-AUG-97 110.5  n/a       Added chk_geocodes_installed.
    iharding 10-SEP-97 110.8  495719    Suppressed index on PER_PAY_BASES
                                        within function GET_SALARY
    dkerr    20-OCT-97 110.9  n/a       Added get_business_group_id
    mshah    17-NOV-97 110.10 n/a       Added proc set_calling_context
                                        and function get_calling_context
                                        and added call to set_calling_context
                                        to proc init_forms, setting it to
                                        'FORMS'
    fychu    16-Dec-97 110.11 n/a       Added get_phone_number function.
    dkerr    20-MAR-98 40.32  643828    Added DECODE_PEOPLE_GROUP
    ccarter  23-Dec-98 115.2  n/a       Added chk_product_installed function
    dkerr    23-Feb-99 115.3  n/a       Added PQH and PQP as prefixes
    dkerr    23-Mar-99 115.4  n/a       hrms_object
    avergori 23-Apr-99 115.5  n/a       substringed c_pay_value to max of 30
                                        chars to enable inserts into
                                        pay_input_values_f.
    ccarter  03-Jun-99 115.6            Added get_user_status function
    ccarter  30-Jun-99 115.7            Change made to get_user_status function
    skekkar  23-AUG-99 115.8            Added decode_territory ,
                                        decode_organization and
                                        decode_availability_status functions
    hsajja   25-AUG-99 115.9            Added DECODE_POSITION_CURRENT_NAME
                                        function
    hsajja   27-AUG-99 115.10           Change made to VERTICAL_APP_ID function
                                        to add 8302(PQH) and 8303(PQP)
    darora   27-Sep-99 115.11           Included functions - DECODE_POSITION_LATEST_NAME,
                                       and DECODE_STEP

   rraina  29-Sep-99 115.12  985430  Added functions decode_ar_lookup and
                                     hr_lookup_locations
    hsajja   01-OCT-99 115.13           Added DECODE_LATEST_POSITION_DEF_ID,
                                        DECODE_AVAIL_STATUS_START_DATE functions
    hsajja   04-OCT-99 115.14           Added GET_POSITION_DATE_END function
                                        Changed per_all_positions to
                                        hr_all_positions in decode_position
                                        function
    hsajja   07-OCT-99 115.15           Added functions DECODE_PERSON_NAME,
                                        DECODE_GRADE_RULE.
    hsajja   12-OCT-99 115.16           Modified DECODE_POSITION_LATEST_NAME,
                                        and DECODE_LATEST_POSITION_DEF_ID
    hsajja   16-OCT-99 115.17           Modified DECODE_AVAIL_STATUS_START_DATE
  mmillmor 10-Nov-1999 115.18           Added check to init_forms to check that
                                        the business group id matches that of
                                        the security profile.
   rraina  10-NOV-1999 115.19           added decode_fnd_comm_lookup for ota views opt

    dkerr    10-NOV-99 115.20           Added p_hr_trace_dest parameter to
                                        init_forms
    cxsimpso 28-DEC-99 115.21           Added get_validation_name function.
    smcmilla 29-DEC-99 115.22           Added product id 453 to
                                        core_hr_app_id function (HRI)
    mbocutt  03/01/2000 115.23 1125512  Change get_business_group_id. Replace
                                        usage of fnd_profile.value_wnps to use
                                        fnd_profile.value. This routine writes
                                        the profile value to cache thus aiding
                                        performance.
    alogue   14/02/2000 115.24          Utf8 support.
    hsajja   21/02/2000 115.25          Included function DECODE_SHARED_TYPE
    alogue   01/03/2000 115.26          Support of change to hr_locations.
    rvydyana 24/05/2000 115.27          Added new function get_xbg_profile
    mbocutt  06/06/2000 115.29          Fixed error in function descriptions
                                        for get_work/home_phone
    tclewis  29-feb-2000 115.30         added function maintain_tax_Records.
    arashid  13-OCT-00 115.22           Added a cover routine for:
                                        DBMS_DESCRIBE.DESCRIBE_PROCEDURE to
                                        compile an invalid package. The new
                                        routine is called: DESCRIBE_PROCEDURE
    pattwood 16-NOV-2000 115.32         Changed DESCRIBE_PROCEDURE so it
                                        only attempts to compile the package
                                        header, instead of the header and
                                        body. Required by hr_api_user_hooks
                                        package changes for deferred
                                        compilation changes.
    stlocke  23-JAN-2001 115.33		Added procedure init-fndload.
    stlocke  08-FEB-2001 115.34		Procedure init-fndload removed.
    cnholmes 28-NOV-2001 115.35         Add iRecruitment to HRSM_OBJECT.
    hsajja   17-JAN-2002 115.36         NLS fix: Changed per_shared_types to
                                        per_shared_types_vl in function
                                        DECODE_AVAILABILITY_STATUS
    gsayers  05-FEB-2002 115.37         Added check to prevent '01/01/0001'-1
                                        in init_forms.
    gperry   08-FEB-2002 115.38         Fixed WWBUG 2110218.
                                        Added userenv('sessionid') to query.
    dkerr    13-MAY-2002 115.38 2372279 Added check for null security profile
                                        to get_xbg_profile
    sgoyal   07-JUN-2002 115.41 2406408 Local variable defined as varchar2(60) changed
                                        to %type of organization name
    sgoyal   07-JUN-2002 115.42         Local variable defined as varchar2(60) changed
                                        to %type of location,position name
    hsajja   28-AUG-2002 115.43         Modified DECODE_POSITION_LATEST_NAME,
                                        and DECODE_LATEST_POSITION_DEF_ID
    adhunter 29-AUG-2002 115.46         2534838: cursors in get_user_status need to restrict
                                        to current language.
                                        GSCC warning: "exit when" clause in loop
                                        in DECODE_AVAIL_START_DATE not liked, changed to "if"
                                        clause with "exit".
    adhunter 07-OCT-2002 115.47 2610865 init_forms: remove "+0" from SELECT
                                        b.legislation_code clause.
    dsaxby   04-DEC-2002 115.48 2692195 Nocopy changes.
    joward   09-DEC-2002 115.49         MLS enabled grade name
    pmfletch 10-DEC-2002 115.50         Pointed decode_position_latest_name to select
                                        from MLS table hr_all_positions_f_tl
    joward   23-DEC-2002 115.51         MLS enabled job name
    kjagadee 26-JUN-2003 115.52 2519443 Modified the cursor csr_amend_user_status
                                        in function get_user_status, so that the
                                        amends in status types will affect only the
                                        concerned business group
    ynegoro  23-JUL-2003 115.53         Added DECODE_GRADE_LADDER
    njaladi  28-AUG-2003 115.54 2555987 Modified the size of v_meaning in
    					            procedure DECODE_ASS_STATUS_TYPE from
    					            30 to 80.
    njaladi  05-SEP-2003 115.55 2555987 Modified the size of v_meaning in
    					            procedure DECODE_ASS_STATUS_TYPE from
    					            80 to %type.
    adudekul 29-JAN-2004 115.56 3355231 Modified cursor csr_get_us_city_names in
                                        function chk_geocodes_installed.
    kkoh     31-AUG-2004 115.57 3078158 Modified function CORE_HR_APP_ID to include
                                        application_id range of 800 - 859
                                        Modified function VERTICAL_APP_ID to include
                                3491930 check on application_id 8403 Oracle Labor Distribution
                                        Modified function HRMS_OBJECT to include
                                        checks on application_short_name AME and PSP
    kkoh     01-SEP-2004 115.58         Typo in change history
    adhunter 06-OCT-2004 115.59 3902208 hr_lookup_locations is erroring when concatenated
                                        address segs exceed 600 chars. Added substr
                                        to limit returned details.
    hsajja   10-DEC-2004 115.60 3663875 Changed function
                                          DECODE_POSITION_LATEST_NAME
    hsajja   10-DEC-2004 115.61 3663875 Removed old/previous duplicate function
                                          DECODE_POSITION_LATEST_NAME
========================================================================================
    svittal  30-SEP-2005 120.1          Global Name Format from R12
                                        changed decode_person_name
-------------------------------------------------------------------------------
    rnemani 06-OCT-2008  120.3.12000000.2 New predicate "fnd_global.per_security_profile_id =-1" is
                                          added to function get_xbg_profile'.
------------------------------------------------------------------------------------------------
    DO NOT ADD ANY FUTHER PROCEDURES / FUNCTIONS TO THIS FILE!

    IF REQUIRED PLEASE ADD TO HR_GENRAL2 (hrgenrl2.pkh/pkb)

--------------------------------------------------------------------------------
*/
--
-- Invalid package exception returned from DBMS_DESCRIBE.DESCRIBE_PROCEDURE.
--
invalid_package exception;
pragma exception_init(invalid_package, -20003);
--
c_start_of_time constant date := to_date ('01/01/0001','DD/MM/YYYY');
c_end_of_time   constant date := to_date ('31/12/4712','DD/MM/YYYY');
--
-- The length of constant c_pay_value is restricted to 30 char to enable inserts
-- into pay_input_values_f and alike.  No translation of a Pay Value should
-- ever be longer than 30 chars but the "meaning" column of the lookups table
-- is length 80, so the following substrb is included as a fail-safe.
--
c_pay_value     constant varchar2(80)
        := substrb(hr_general.decode_lookup ('NAME_TRANSLATIONS','PAY VALUE')
                  ,1,80);
c_money_unit    constant varchar2(255)
                := hr_general.decode_lookup ('UNITS','M');
g_dummy         number (1);     -- dummy variable for select statements
g_calling_context varchar2(30); -- global variable used by get_calling_context
                               -- and set_calling_context
-- ---------------------------------------------------------------------------
-- |----------------------< describe_procedure >-----------------------------|
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
) is
l_package varchar2(128);
l_dotpos  number;
compile   boolean := false;
l_csr_sql integer;
l_rows    integer;
begin
  loop
    begin
      dbms_describe.describe_procedure
      (object_name   => object_name
      ,reserved1     => reserved1
      ,reserved2     => reserved2
      ,overload      => overload
      ,position      => position
      ,level         => level
      ,argument_name => argument_name
      ,datatype      => datatype
      ,default_value => default_value
      ,in_out        => in_out
      ,length        => length
      ,precision     => precision
      ,scale         => scale
      ,radix         => radix
      ,spare         => spare
      );
      compile := false;
    exception
      when invalid_package then
        --
        -- Set the compile flag once only.
        --
        if not  compile then
          compile := true;
        --
        -- Just reraise the exception if the code has already been here.
        --
        else
          raise;
        end if;
      when others then
        raise;
    end;
    --
    -- Attempt to compile the invalid package.
    --
    if compile then
      --
      -- Avoid excessive looping.
      --
      begin
        l_dotpos := instr(object_name, '.');
        if l_dotpos > 1 then
          l_package := substr(object_name, 1, l_dotpos-1);
          l_csr_sql := dbms_sql.open_cursor;
          dbms_sql.parse
          (l_csr_sql
          ,'ALTER PACKAGE ' || l_package || ' COMPILE SPECIFICATION'
          ,dbms_sql.native
          );
          l_rows := dbms_sql.execute( l_csr_sql );
          dbms_sql.close_cursor( l_csr_sql );
        else
          --
          -- The name supplied is that of a standalone procedure/function
          -- or some other odd name.
          --
          raise  invalid_package;
        end if;
      exception
        when others then
          if dbms_sql.is_open( l_csr_sql ) then
            dbms_sql.close_cursor( l_csr_sql );
          end if;
          --
          -- Compilation failed so the package is still invalid.
          --
          raise invalid_package;
      end;
    --
    -- DBMS_DESCRIBE.DESCRIBE_PROCEDURE succeeded so exit the loop.
    --
    else
      exit;
    end if;
  end loop;
end describe_procedure;
------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Name
--  char_to_bool
-- Purpose
--  Converts a boolean char value eg. 'TRUE','FALSE' to the
--  the corresponding boolean value.
-- Arguments
--  p_value   Char value to be converted.
-- Notes
--  Value is not case sensitive.
--  If not recognized then null is returned. Should possibly raise an error.
--
function char_to_bool (p_value in varchar2) return boolean is
l_return_value boolean ;
begin

   if ( upper(p_value) = 'TRUE' )
   then
       l_return_value := true ;
   elsif ( upper(p_value) = 'FALSE')
   then
       l_return_value := false ;
   else
       l_return_value := null ;
   end if ;

   return (l_return_value) ;

end char_to_bool ;
-------------------------------------------------------------------------
-- Name
--  bool_to_char
-- Purpose
--  Converts a boolean value to the corresponding character string.
--  This is useful for cases where a function is used in a view.
-- Arguments
--  p_value   boolean value to be converted.
-- Notes
--  The values returned are the strings 'TRUE','FALSE' and null
--
function bool_to_char (p_value in boolean) return varchar2 is
l_return_value varchar2(10) ;
begin

  if ( p_value = true )
  then
      l_return_value := 'TRUE' ;
  elsif ( p_value = false )
  then
      l_return_value := 'FALSE' ;
  else
      l_return_value := null ;
  end if;

  return (l_return_value) ;

end bool_to_char ;
-------------------------------------------------------------------------
--------------------------------------------------------------------------------
procedure assert_condition (p_condition in boolean) is
--
-- Checks that assumptions made within pl/sql code are true. Use to check the
-- parameters to a pl/sql function or procedure before processing. If the
-- assumption made by a procedure (eg p_parameter is not null) is not true
-- then an error is raised to prevent processing from continuing.
--
begin
--
if not p_condition
then
  raise value_error;
end if;
--
end assert_condition;
--
function get_business_group_id return number is
--
-- If the user has signed on through applications then returns the value
-- of the Business Group profile option otherwise returns null.
--
-- See 1125512 - Replace value_wnps with value due to performance issues
--               caused by value_wnps not writing profile option value to
--               cache.
--             - PROGMA restriction on this function has been removed as a
--               result of this change.
--
-- Note the check that the user has signed on is so that views which
-- would normally restrict on business group can be made to retrieve
-- all rows when running in sql*plus or other environments. By default
-- the Business Group Profile option is defined at site level to be
-- the Setup Business group.
--
begin

  if ( fnd_global.user_id = -1 ) then
     return(null);
  else
     return(fnd_profile.value('PER_BUSINESS_GROUP_ID'));
  end if;

end get_business_group_id ;
--------------------------------------------------------------------------------
function CHK_APPLICATION_ID(p_application_id number) return varchar2 is
--
-- If the application id is between 800 and 859 or if it is 8301, 8302, 8303 or 8403
-- then return True otherwise return False
--
v_valid_application_id varchar2(10);
--
Begin
--
If core_hr_app_id(p_application_id)= 'TRUE' or vertical_app_id(p_application_id)='TRUE'
Then
  v_valid_application_id := 'TRUE';
Else
  v_valid_application_id := 'FALSE';
End If;
--
RETURN v_valid_application_id;
End chk_application_id;
--------------------------------------------------------------------------------
function CORE_HR_APP_ID(p_application_id number) return varchar2 is
--
-- If the application_id is between 800 and 859 then return True otherwise
-- return false
--
v_valid_application_id varchar2(10);
--
Begin
--
If p_application_id between 800 and 859
Then
   v_valid_application_id := 'TRUE';
Elsif p_application_id = 453 Then
   -- HRI application id
   v_valid_application_id := 'TRUE';
Else
   v_valid_application_id := 'FALSE';
End If;
--
RETURN v_valid_application_id;
End core_hr_app_id;
--------------------------------------------------------------------------------
function VERTICAL_APP_ID(p_application_id number) return varchar2 is
--
-- If application_id is 8301, 8302, 8303, 8403
-- then return True otherwise return false
--
v_valid_application_id varchar2(10);
--
Begin
--
If p_application_id in ( 8301, 8302, 8303, 8403 )
Then
   v_valid_application_id := 'TRUE';
Else
   v_valid_application_id := 'FALSE';
End If;
--
RETURN v_valid_application_id;
End vertical_app_id;
-------------------------------------------------------------------------
-- Name
--   hrms_object
-- Purpose
--   *** INTERNAL HRDEV USE ONLY ***
--   Determines whether given object has an HRMS prefix
-- Arguments
--   p_object_name   - The name of the object to be checked
-- Notes
--   This function does not handle objects with a non-standard
--   prefix. Ideally these should be added.
--
function hrms_object (p_object_name in varchar2) return varchar2 is
begin

  return (bool_to_char(

            --
            -- 'Core products'
            --
               --
               -- Most HR is really PER but may find itself
               -- in PAY
               --
               (instr(p_object_name,'HR')  = 1 )
            OR (instr(p_object_name,'PE_') = 1 )
            OR (instr(p_object_name,'PER') = 1 )

            OR (instr(p_object_name,'PAY') = 1 )
            OR (instr(p_object_name,'PY')  = 1 )

            -- DT and FF are psuedo-products and required for PER
            OR (instr(p_object_name,'DT')  = 1 )
            OR (instr(p_object_name,'FF')  = 1 )


            --
            -- 'Optional Products'
            --

               --
               -- OT is really
               -- OTA
               -- OTFV,OTFG  - 'Business Views'
               --
            OR (instr(p_object_name,'OT') = 1 )

               --
               -- BEN - Oracle Advanced Benefits
               --
            OR (instr(p_object_name,'BEN') = 1 )

            -- HX is really
            -- HXT  - Oracle Time Management
            -- HXC  - Oracle Time Capture
            OR (instr(p_object_name,'HX') = 1 )

            --
            -- 'Verticalizations'
            --
            OR (instr(p_object_name,'GHR') = 1 )
            OR (instr(p_object_name,'PQH') = 1 )
            OR (instr(p_object_name,'PQP') = 1 )

            --
            -- 'Localizations'
            --

            OR (instr(p_object_name,'SSP') = 1 )

            --
            -- 'iRecruitment'
            --

            OR (instr(p_object_name,'IRC') = 1 )

            --
            -- AME - Oracle Approvals Management
            --

            OR (instr(p_object_name,'AME') = 1 )

            --
            -- PSP - Oracle Labor Distribution
            --

            OR (instr(p_object_name,'PSP') = 1 )


         ));

end hrms_object;
-------------------------------------------------------------------------
function get_application_short_name (p_application_id in varchar2) return varchar2 is
  l_return_value fnd_application.application_short_name%type ;
  cursor c1 (p_app_id in number ) is
     select fa.application_short_name
     from   fnd_application  fa
     where  fa.application_id = p_app_id ;
begin

  -- Special case the most common ones. This is to save a select
  -- in calls to hr_utility.set_message.
  if ( p_application_id = 800 )
  then
      l_return_value := 'PER' ;
  elsif ( p_application_id = 801 )
  then
      l_return_value := 'PAY' ;
  elsif ( p_application_id = 802 )
  then
      l_return_value := 'FF' ;
  elsif ( p_application_id = 803 )
  then
      l_return_value := 'DT' ;
  else
      open c1(p_application_id) ;
      fetch c1 into l_return_value ;
      close c1 ;
  end if;

  return(l_return_value) ;

end get_application_short_name ;
-------------------------------------------------------------------------
-------------------------------------------------------------------------------e
function LOCATION_VALID (
--
--***************************************************************
--* Returns TRUE if the location is valid on the specified date *
--***************************************************************
--
        p_location_id           number,
        p_date                  date,
        p_error_if_invalid      boolean default TRUE    ) return boolean is
--
cursor csr_location is
        select  1
        from    hr_locations
        where   location_id     = p_location_id
        and     location_use    = 'HR'
        and     nvl (inactive_date, c_end_of_time) >= p_date;
--
v_location_valid        boolean;
--
begin
--
hr_utility.set_location ('HR_GENERAL.LOCATION_VALID',1);
--
open csr_location;
fetch csr_location into g_dummy;
v_location_valid := csr_location%found;
close csr_location;
--
if (not v_location_valid) and p_error_if_invalid then
  hr_utility.set_message (801, 'HR_7104_LOC_LOCATION_INVALID');
  hr_utility.raise_error;
end if;
--
return v_location_valid;
--
end location_valid;
-------------------------------------------------------------------------
-- Returns the session date if set otherwise trunc('sysdate');
-- Ideally this should use a cached variable in the datetrack package
--
function EFFECTIVE_DATE return date is
l_effective_date date ;
cursor c1 is
  select effective_date
  from   fnd_sessions
  where  session_id = userenv('sessionid');
begin

  open c1 ;
  fetch c1 into l_effective_date ;
  if c1%notfound then l_effective_date := trunc(sysdate) ;
  end if;
  close c1 ;

  return (l_effective_date);

end effective_date ;
-------------------------------------------------------------------------
function START_OF_TIME return date is
begin
return c_start_of_time;
end start_of_time;
-------------------------------------------------------------------------
function END_OF_TIME return date is
begin
return c_end_of_time;
end end_of_time;
-------------------------------------------------------------------------
function PAY_VALUE return varchar2 is
begin
return c_pay_value;
end pay_value;
-------------------------------------------------------------------------
function MONEY_UNIT return varchar2 is
begin
return c_money_unit;
end money_unit;
-------------------------------------------------------------------------
function DEFAULT_CURRENCY_CODE (p_legislation_code varchar2) return varchar2 is
--
--**********************************************************
--* Returns the default currency for specified legislation *
--**********************************************************
--
cursor csr_legislation is
        select  rule_mode
        from    pay_legislation_rules
        where   legislation_code        = p_legislation_code
        and     rule_type               = 'DC';
--
cursor csr_currency is
        select  currency_code
        from    fnd_currencies  CURRENCY,
                fnd_sessions    SESH
        where   currency.enabled_flag           = 'Y'
        and     currency.issuing_territory_code = p_legislation_code
        and     sesh.session_id         = userenv ('sessionid')
        and     sesh.effective_date     between nvl(currency.start_date_active,
                                                        sesh.effective_date)
                                        and     nvl(currency.end_date_active,
                                                        sesh.effective_date);
--
v_default_currency      varchar2(255) := null;
--
begin
hr_utility.set_location ('hr_general.default_currency_code',1);
--
-- Find the user-specified default currency
--
open csr_legislation;
fetch csr_legislation into v_default_currency;
--
-- If no default is specified, then find the first currency available
--
if csr_legislation%notfound then
  open csr_currency;
  fetch csr_currency into v_default_currency;
--
-- If no currency is available, then return an error
--
  if csr_currency%notfound then
    close csr_currency;
    hr_utility.set_message(801, 'HR_7989_HR_DEFAULT_CURRENCY');
    hr_utility.raise_error;
  else
    close csr_currency;
  end if;
--
end if;
--
close csr_legislation;
return v_default_currency;
--
end default_currency_code;
---------------------------------------------------------------------------
function DEFAULT_CURRENCY_CODE (p_business_group_id     number) return varchar2
--*****************************************************************************
--* Returns the default currency code for the specified business group ID
--* NB For data legacy reasons, the default currency for the business group
--* is derived differently from that for the legislation. In some cases,
--* eg PAYWSDET, both default derivation methods are in use.
--*****************************************************************************
--
is
--
cursor csr_default_currency is
        select  currency_code
        from    per_business_groups_perf
        where   business_group_id = p_business_group_id;
        --
currency        per_business_groups_perf.currency_code%type;
--
begin
--
open csr_default_currency;
fetch csr_default_currency into currency;
close csr_default_currency;
--
return currency;
--
end default_currency_code;
---------------------------------------------------------------------------
function DECODE_LOOKUP (
--******************************************************************************
--* Returns the meaning for a lookup code of a specified type.
--******************************************************************************
--
        p_lookup_type   varchar2,
        p_lookup_code   varchar2) return varchar2 is
--
cursor csr_lookup is
        select meaning
        from    hr_lookups
        where   lookup_type     = p_lookup_type
        and     lookup_code     = p_lookup_code;
--
v_meaning       varchar2(80) := null;
--
begin
--
-- Only open the cursor if the parameters are going to retrieve anything
--
if p_lookup_type is not null and p_lookup_code is not null then
  --
  open csr_lookup;
  fetch csr_lookup into v_meaning;
  close csr_lookup;
  --
end if;
--
return v_meaning;
--
end decode_lookup;
---------------------------------------------------------------------------
function DECODE_FND_COMM_LOOKUP (
--******************************************************************************
--* Returns the meaning for a lookup code of a specified type.
--******************************************************************************
--
        p_lookup_type   varchar2,
        p_lookup_code   varchar2) return varchar2 is
--
cursor csr_lookup is
        select meaning
        from    fnd_common_lookups
        where   lookup_type     = p_lookup_type
        and     lookup_code     = p_lookup_code
      and   APPLICATION_ID = 800;
--
v_meaning       varchar2(80) := null;
--
begin
--
-- Only open the cursor if the parameters are going to retrieve anything
--
if p_lookup_type is not null and p_lookup_code is not null then
  --
  open csr_lookup;
  fetch csr_lookup into v_meaning;
  close csr_lookup;
  --
end if;
--
return v_meaning;
--
end decode_fnd_comm_lookup;

---------------------------------------------------------------------------
function DECODE_GRADE (

--
         p_grade_id      number) return varchar2 is
--
cursor csr_lookup is
         select    name
         from      per_grades_vl
         where     grade_id      = p_grade_id;
--
v_meaning          varchar2(240) := null;
--
begin
--
-- Only open the cursor if the parameter is going to retrieve anything
--
if p_grade_id is not null then
  --
  open csr_lookup;
  fetch csr_lookup into v_meaning;
  close csr_lookup;
  --
end if;
return v_meaning;
end decode_grade;
---------------------------------------------------------------------------
function DECODE_GRADE_LADDER (

--
         p_grade_ladder_pgm_id      number) return varchar2 is
--
cursor csr_lookup is
         select    name
         from      ben_pgm_f pgm
                  ,fnd_sessions s
         where     pgm_id      = p_grade_ladder_pgm_id
         and       s.effective_date between
                   pgm.effective_start_date and pgm.effective_end_date
         and       s.session_id         = userenv ('sessionid');
--
v_meaning          varchar2(240) := null;
--
begin
--
-- Only open the cursor if the parameter is going to retrieve anything
--
if p_grade_ladder_pgm_id is not null then
  --
  open csr_lookup;
  fetch csr_lookup into v_meaning;
  close csr_lookup;
  --
end if;
return v_meaning;
end decode_grade_ladder;

---------------------------------------------------------------------------
function DECODE_PAYROLL (

--
         p_payroll_id      number) return varchar2 is
--
cursor csr_lookup is
         select    payroll_name
         from      pay_all_payrolls_f pay, fnd_sessions f
         where     payroll_id      = p_payroll_id
         and       f.effective_date between
                   pay.effective_start_date and pay.effective_end_date
         and       f.session_id         = userenv ('sessionid');
--
v_meaning          varchar2(80) := null;
--
begin
--
-- Only open the cursor if the parameter is going to retrieve anything
--
if p_payroll_id is not null then
  --
  open csr_lookup;
  fetch csr_lookup into v_meaning;
  close csr_lookup;
  --
end if;
return v_meaning;
end decode_payroll;
-----------------------------------------------------------------------
function GET_SALARY (
--
           p_pay_basis_id   number,
           p_assignment_id  number)   return varchar2  is
--
-- This cursor gets the screen_entry_value from pay_element_entry_values_f.
-- This is the salary amount
-- obtained when the pay basis isn't null. The pay basis and assignment_id
-- are passed in by the view. A check is made on the effective date of
-- pay_element_entry_values_f and pay_element_entries_f as they're datetracked.
--
cursor csr_lookup is
       select eev.screen_entry_value
       from   pay_element_entry_values_f eev,
              per_pay_bases              ppb,
              pay_element_entries_f       pe,
              fnd_sessions                 f
       where  ppb.pay_basis_id  +0 = p_pay_basis_id
       and    pe.assignment_id     = p_assignment_id
       and    eev.input_value_id   = ppb.input_value_id
       and    eev.element_entry_id = pe.element_entry_id
       and    f.effective_date between
                        eev.effective_start_date and eev.effective_end_date
       and    f.effective_date between
                        pe.effective_start_date and pe.effective_end_date
       and    f.session_id         = userenv ('sessionid');
--
  v_meaning          varchar2(60) := null;
begin
  --
  -- Only open the cursor if the parameter may retrieve anything
  -- In practice, p_assignment_id is always going to be non null;
  -- p_pay_basis_id may be null, though. If it is, don't bother trying
  -- to fetch a salary.
  --
  -- If we do have a pay basis, try and get a salary. There may not be one,
  -- in which case no problem: just return null.
  --
    if p_pay_basis_id is not null and p_assignment_id is not null then
      open csr_lookup;
      fetch csr_lookup into v_meaning;
      close csr_lookup;
    end if;
  --
  -- Return the salary value, if this does not exist, return a null value.
  --
  return v_meaning;
end get_salary;
--
-----------------------------------------------------------------------
function DECODE_JOB (

--
         p_job_id      number) return varchar2 is
--
cursor csr_lookup is
         select    name
         from      per_jobs_vl
         where     job_id      = p_job_id;
--
v_meaning          per_jobs.name%TYPE := null;
--
begin
--
-- Only open the cursor if the parameter is going to retrieve anything
--
if p_job_id is not null then
  --
  open csr_lookup;
  fetch csr_lookup into v_meaning;
  close csr_lookup;
  --
end if;
--
return v_meaning;
end decode_job;
-------------------------------------------------------------------------
function DECODE_POSITION (

--
         p_position_id      number) return varchar2 is
--
cursor csr_lookup is
         select    name
         from      hr_all_positions
         where     position_id      = p_position_id;
--
v_meaning          hr_all_positions.name%TYPE := null;
--
begin
--
-- Only open the cursor if the parameter is going to retrieve anything
--
if p_position_id is not null then
  --
  open csr_lookup;
  fetch csr_lookup into v_meaning;
  close csr_lookup;
  --
end if;
return v_meaning;
end decode_position;
------------------------------------------------------------------------
function DECODE_LOCATION (

--
         p_location_id      number) return varchar2 is
--
cursor csr_lookup is
         select    location_code
         from      hr_locations
         where     location_id      = p_location_id
         and       location_use     = 'HR';
--
v_meaning          hr_locations.location_code%TYPE := null;
--
begin
--
-- Only open the cursor if the parameter is going to retrieve anything
--
if p_location_id is not null then
  --
  open csr_lookup;
  fetch csr_lookup into v_meaning;
  close csr_lookup;
  --
end if;
return v_meaning;
end decode_location;
-----------------------------------------------------------------------
function DECODE_PAY_BASIS (

--
         p_pay_basis_id      number) return varchar2 is
--
cursor csr_lookup is
         select    name
         from      per_pay_bases
         where     pay_basis_id      = p_pay_basis_id;
--
v_meaning          varchar2(30) := null;
--
begin
--
-- Only open the cursor if the parameter is going to retrieve anything
--
if p_pay_basis_id is not null then
  --
  open csr_lookup;
  fetch csr_lookup into v_meaning;
  close csr_lookup;
  --
end if;
return v_meaning;
end decode_pay_basis;
------------------------------------------------------------------------
function DECODE_ASS_STATUS_TYPE (

--
         p_assignment_status_type_id      number,
         p_business_group_id              number) return varchar2 is
--
cursor csr_lookup is
         select    user_status
         from      per_ass_status_type_amends
         where     assignment_status_type_id = p_assignment_status_type_id
         and       business_group_id         = p_business_group_id;
--
v_meaning          per_ass_status_type_amends.user_status%type := null; --#2555987 changed size from 30 to %type.
--
begin
--
-- Only open the cursor if the parameter is going to retrieve anything
--
if p_assignment_status_type_id is not null then
  --
  open csr_lookup;
  fetch csr_lookup into v_meaning;
  close csr_lookup;
  --
end if;
--
return v_meaning;
end decode_ass_status_type;

--------------------------------------------------------------------------------
-- -------------------------< get_phone_number >--------------------------------
--------------------------------------------------------------------------------
-- This function will return phone number by phone_type which is passed in and
-- by effective_date from the per_phones table.  If effective_date is not passed
-- in, it will use the either the session date or sysdate.
--
-- NOTES:
--   This is a generic procedure to get phone number by phone_type.  The
--   phone number returned will be as follows:
--   1)  If there are more than 1 records active for a give phone_type within
--       the effective_date passed, return the latest date_from, then date_to.
--       Note that Date_to can be null.  We do not use an nvl(date_to, ..)
--       in the order by clause so that the null value date_to record will be
--       sorted first.  For example:
--       Phone ID    Phone Type   Phone Number   Date From      Date To
--       --------    ----------   -------------  -------------  -------------
--        1           WF          650-001-0001   01-Dec-97      31-Dec-97
--        2           WF          650-002-0002   01-Dec-97      <null>
--        3           WF          650-003-0003   05-Dec-97      16-Dec-97
--
--       IF the effective date = 10-Dec-97, then all 3 records are effective
--       as of 10-Dec-97.  With the order by clause coded as "date_from desc,
--       date_to desc", phone_id 2 will be sorted ahead of phone_id 1
--       because of the null value in the date_to field.  We want the no
--       expiration date to be retrieved first in the case where there are
--       multiple records with the same date_from date.
--       Hence, the result set will appear as follows:
--       Phone ID    Phone Type   Phone Number   Date From      Date To
--       --------    ----------   -------------  -------------  -------------
--        3           WF          650-003-0003   05-Dec-97      16-Dec-97
--        2           WF          650-002-0002   01-Dec-97      <null>
--        1           WF          650-001-0001   01-Dec-97      31-Dec-97

--   2)  If no date is passed in, the system will use fnd_session effective date--       or sysdate to retrieve the record.
--   3)  Return null value if no record found for the type, person_id and
--       the specific date.
--
--------------------------------------------------------------------------------
function GET_PHONE_NUMBER
         (p_person_id         in number
         ,p_phone_type        in varchar2
         ,p_effective_date    in date default null)  return varchar2 is


    cursor csr_phones(c_effective_date in date) is
    select  phn.phone_number
           ,phn.date_from
           ,phn.date_to
      from  per_phones phn
     where  phn.parent_id = p_person_id
       and  phn.parent_table = 'PER_ALL_PEOPLE_F'
       and  phn.phone_type = p_phone_type
       and  c_effective_date between phn.date_from and
            nvl(phn.date_to,c_effective_date)
   order by phn.date_from DESC    -- This is not a mistake of not using
           ,phn.date_to   DESC;   -- nvl(date_to, c_effective_date) in the order
                                  -- by clause because we want the null date_to
                                  -- record to be sorted first.

l_effective_date   date;
--
BEGIN

IF p_effective_date is null THEN
   l_effective_date := hr_general.effective_date;
ELSE
   l_effective_date := p_effective_date;
END IF;
--
For c_get_phones in csr_phones(c_effective_date => l_effective_date)
    LOOP
        return c_get_phones.phone_number;
    END LOOP;
--
Return null;
--
Exception
  WHEN no_data_found THEN
       return null;
--
--
  When others THEN
       raise;

END get_phone_number;

--------------------------------------------------------------------------------
-- This function will return the work phone number from PER_PHONES
--
function GET_WORK_PHONE (
         p_person_id              number) return varchar2 is
--
l_per_people_phone varchar2(60);
l_per_phones_phone varchar2(60);
l_effective_date   date;
cursor csr_phones1(c_effective_date in date) is
         select    phone_number
         from      per_phones phn
         where     phn.parent_id = p_person_id
         and       phn.parent_table = 'PER_ALL_PEOPLE_F'
         and       phn.phone_type = 'W1'
         and       c_effective_date between phn.date_from and
                        nvl(phn.date_to,c_effective_date);


begin
  l_effective_date := hr_general.effective_date;
  open csr_phones1(l_effective_date);
  fetch csr_phones1 into l_per_phones_phone;
  close csr_phones1;
  return l_per_phones_phone;

end get_work_phone;
--------------------------------------------------------------------------------
-- This function will return the home phone number from PER_PHONES
--
function GET_HOME_PHONE (

         p_person_id              number) return varchar2 is
--
l_per_address_phone varchar2(60);
l_per_phones_phone varchar2(60);

cursor csr_phones1 is
         select    phone_number
         from      per_phones phn,
                   fnd_sessions f
         where     phn.parent_id = p_person_id
         and       phn.parent_table = 'PER_ALL_PEOPLE_F'
         and       phn.phone_type = 'H1'
         and       f.effective_date between phn.date_from and
                        nvl(phn.date_to,f.effective_date)
         and       f.session_id         = userenv ('sessionid');

cursor csr_phones2 is
         select    telephone_number_1
         from      per_addresses adr,
                   fnd_sessions f
         where     adr.person_id = p_person_id
         and       adr.primary_flag = 'Y'
         and       f.effective_date between adr.date_from and
                        nvl(adr.date_to,f.effective_date)
         and       f.session_id         = userenv ('sessionid');

begin

  open csr_phones1;
  fetch csr_phones1 into l_per_phones_phone;
  close csr_phones1;

 if l_per_phones_phone is not null then
   return l_per_phones_phone;
 else
   open csr_phones2;
   fetch csr_phones2 into l_per_address_phone;
   close csr_phones2;
   return l_per_address_phone;
 end if;
end get_home_phone;

--------------------------------------------------------------------------------
function DECODE_PEOPLE_GROUP (
         p_people_group_id      number) return varchar2 is
--
cursor csr_lookup is
         select    group_name
         from      pay_people_groups
         where     people_group_id      = p_people_group_id;
--
v_meaning          pay_people_groups.group_name%type := null;
--
begin
--
-- Only open the cursor if the parameter is going to retrieve anything
--
if p_people_group_id is not null then
  --
  open csr_lookup;
  fetch csr_lookup into v_meaning;
  close csr_lookup;
  --
end if;
--
return v_meaning;
end decode_people_group;
--------------------------------------------------------------------------------
procedure check_HR_version (
--
-- Checks the in-use form version against the latest version of the form
-- If there is a mismatch then an error is raised
--
p_object_name           varchar2,
p_actual_version        varchar2) is
--
l_dbms_cursor   integer;
l_dummy         integer;
-- The text below will be run dynamically after substituting the parameters
l_text          varchar2 (2000) :=
'begin '||
'if hr_version.<variable_name> != ''<actual_version>'' then'||
'  hr_utility.set_message (801, ''HR_7345_INVALID_FILE'');'||
'  hr_utility.set_message_token (''FILENAME'',''<object_name>'');'||
'  hr_utility.set_message_token (''OLD_VERSION'', ''<actual_version>'');'||
'  hr_utility.set_message_token (''LATEST_VERSION'', hr_version.<variable_name>);'||
'  hr_utility.raise_error;'||
'end if;'||
'end;';
--
begin
--
-- Substitute the embedded variables in the dynamic pl/sql above
--
l_text := replace (l_text, '<variable_name>', p_object_name);
l_text := replace (l_text, '<object_name>', p_object_name);
l_text := replace (l_text, '<actual_version>', p_actual_version);
--
-- Run the dynamic pl/sql
--
l_dbms_cursor := dbms_sql.open_cursor;
dbms_sql.parse  (       l_dbms_cursor,
                        l_text,
                        dbms_sql.v7);
l_dummy := dbms_sql.execute (l_dbms_cursor);
dbms_sql.close_cursor (l_dbms_cursor);
--
exception
when others then
  if dbms_sql.is_open (l_dbms_cursor) then
    dbms_sql.close_cursor (l_dbms_cursor);
  end if;
  raise;
  --
end check_HR_version;

-- --------------------------------------------------------------------------
--
procedure set_calling_context(p_calling_context IN varchar2) is
--
-- Sets the global variable g_calling_context to p_calling_context
-- The value 'FORMS' will be passed in if called from a form
--
begin
--
  g_calling_context := p_calling_context;
--
end set_calling_context;
--
--------------------------------------------------------------------------------
--
PROCEDURE init_forms(p_business_group_id     IN   NUMBER,
                     p_short_name            OUT  nocopy VARCHAR2,
                     p_bg_name               OUT  nocopy VARCHAR2,
                     p_bg_currency_code      OUT  nocopy VARCHAR2,
                     p_legislation_code      OUT  nocopy VARCHAR2,
                     p_session_date       IN OUT  nocopy DATE,
                     p_ses_yesterday         OUT  nocopy DATE,
                     p_start_of_time         OUT  nocopy DATE,
                     p_end_of_time           OUT  nocopy DATE,
                     p_sys_date              OUT  nocopy DATE,
                     p_enable_hr_trace       IN   BOOLEAN,
                     p_hr_trace_dest         IN   VARCHAR2 DEFAULT 'DBMS_PIPE'

                     /* This code not yet implemented
                     p_form_name               varchar2 default null,
                     p_actual_version          varchar2 default null
                      */

                     ) IS
  --
  l_session_date        date;
  l_commit_flag         number;  -- See note below
--
  l_security_profile_id number;
  l_security_business_group_id number;
--
  cursor sec_bg is
  select business_group_id
  from per_security_profiles
  where security_profile_id=l_security_profile_id;
--
begin
  --
  /* This code not yet implemented
  if p_form_name is not null and p_actual_version is not null then
    check_HR_version (p_form_name, p_actual_version);
  end if;
  */
  --
  if p_business_group_id is not null then
    -- Attempt to get business group details from database
    begin
      select b.legislation_code
           , b.short_name
           , b.name
           , b.currency_code
        into p_legislation_code
           , p_short_name
           , p_bg_name
           , p_bg_currency_code
        from per_business_groups b
       where b.business_group_id = p_business_group_id;
    exception
      when no_data_found then
        hr_utility.set_message('801', 'HR_6153_ALL_PROCEDURE_FAIL');
        hr_utility.set_message_token('PROCEDURE', 'INIT_FORMS');
        hr_utility.set_message_token('STEP', '1');
        hr_utility.raise_error;
      when too_many_rows then
        hr_utility.set_message('801', 'HR_6153_ALL_PROCEDURE_FAIL');
        hr_utility.set_message_token('PROCEDURE', 'INIT_FORMS');
        hr_utility.set_message_token('STEP', '2');
        hr_utility.raise_error;
    end;
    -- check that the security profile business group matches the
    -- set business group.
    l_security_profile_id:=fnd_profile.value('PER_SECURITY_PROFILE_ID');
    --
    open sec_bg;
    fetch sec_bg into l_security_business_group_id;
    if sec_bg%notfound then
      close sec_bg;
      -- the security profile does not exist, so raise an error.
      hr_utility.set_message('800', 'PER_52803_SEC_INV_BG');
      hr_utility.raise_error;
    else
      close sec_bg;
      if nvl(l_security_business_group_id,p_business_group_id)
         <>p_business_group_id then
        -- the security profile business group id is not null and
        -- it dies not match our business group id so raise an error.
        hr_utility.set_message('800', 'PER_52803_SEC_INV_BG');
        hr_utility.raise_error;
      end if;
    end if;
  --
  else  -- p_business_group_id is null
    p_legislation_code := null;
    p_short_name       := null;
  end if;
  --
  -- Call DateTrack procedure to get date values
  --
  dt_fndate.get_dates(
    p_ses_date           => l_session_date,
    p_ses_yesterday_date => p_ses_yesterday,
    p_start_of_time      => p_start_of_time,
    p_end_of_time        => p_end_of_time,
    p_sys_date           => p_sys_date,
    p_commit             => l_commit_flag);
  --
  -- If there was a session date passed in, and it's not sysdate,
  -- update the row just inserted in fnd_sessions to the date passed
  -- in. This is not the most efficient way to do it, but it means no
  -- change is needed to dt_fndate.
  --
  if l_session_date = nvl (p_session_date, l_session_date) then
    p_session_date := l_session_date;
  else

    dt_fndate.change_ses_date (p_session_date, l_commit_flag);

    -- Bug 358870
    -- If this is the case then p_ses_yesterday needs to be
    -- to be re-set
    --
    -- Must prevent '01/01/0001'-1 as any earlier date would be invalid
    --
    if p_session_date = to_date('01/01/0001', 'DD/MM/YYYY') then
      p_ses_yesterday := null;
    else
      p_ses_yesterday := p_session_date - 1;
    end if;

  end if;
  --
  -- Enable HR trace. This is done as each form starts up
  --
  if ( p_enable_hr_trace ) then
     hr_utility.trace_on('F','PID');
     hr_utility.set_trace_options('TRACE_DEST:'||p_hr_trace_dest);
  end if;


  -- DK 22-DEC-1996 Ideally we should remove p_commit_flag altogether
  -- but as we are not regenerating for Prod-16 this is not feasible
  if ( l_commit_flag = 1 ) then
     commit ;
  end if;

  -- Bug no 581122 - Part of fix
  -- hr_general.set_calling_context(p_calling_context => 'FORMS');

end init_forms;
--------------------------------------------------------------------------------
--
function chk_geocodes_installed
  return varchar2
   is
--
   l_proc             varchar2(72)  :=  'hr_general.chk_geocodes_installed';
--
   l_exists           varchar2(1);
--
-- Declare cursor.
--
-- Fix for Bug 3355231 starts here.
-- Performance issue. Modified below cursor.
--
   cursor csr_get_us_city_names
   is
     select 'Y' from dual
     where exists(select null
                  from   pay_us_city_names
                  where rownum =1);
--
-- Fix for bug 3355231 ends here.
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  --  Check if any rows exist in the pay_us_city_names
  --
  open csr_get_us_city_names;
  fetch csr_get_us_city_names into l_exists;
  if csr_get_us_city_names%FOUND then
    return 'Y';
  else
    return 'N';
  end if;
  close csr_get_us_city_names;
  --
  hr_utility.set_location(' Leaving:'|| l_proc, 3);
  --
end chk_geocodes_installed;
-- --------------------------------------------------------------------------
-- This function will be called to determine if we need to maintain tax record
-- If US payroll is installed or if GEO_codes are installed and the profile
-- option PER_ENABLE_DTW4 is set to Yes we will maintain the tax record.
-- by default or if PER_ENABLE_DTW4 is installed on the system the value will
-- be 'Yes'.
--
function chk_maintain_tax_records
  return varchar2
   is
--
   l_proc             varchar2(72)  :=  'hr_general.chk_maintain_tax_records';
--
   l_dtw4_profile_option_value    VARCHAR2(3);
begin
  hr_utility.set_location('Entering:'|| l_proc, 1);
  --
  -- Get the profile value for the PER_ENABLE_DTW4.
  --
  FND_PROFILE.GET('PER_ENABLE_DTW4',
                  l_dtw4_profile_option_value);
  --
  IF  hr_utility.chk_product_install(p_product =>'Oracle Payroll',
                                           p_legislation => 'US')         OR
           (hr_general.chk_geocodes_installed ='Y' and
           NVL(l_dtw4_profile_option_value,'Y') = 'Y' )                THEN
      return 'Y';
  else
     return  'N';
  end if;


  --
  hr_utility.set_location(' Leaving:'|| l_proc, 3);
  --
end chk_maintain_tax_records;
-- --------------------------------------------------------------------------
--
--
function get_calling_context return varchar2 is
--
-- Returns the value of g_calling_context
--
begin
--
  return g_calling_context;
--
end get_calling_context;
--
-- --------------------------------------------------------------------------
function chk_product_installed(p_application_id in number) return varchar2 is
--
l_installed varchar2(10);
--
cursor csr_install is
  select 'X'
  from fnd_product_installations
  where application_id = p_application_id
  and status = 'I';
--
begin
  --
  open csr_install;
  fetch csr_install into l_installed;
  if csr_install%FOUND then
    close csr_install;
    return 'TRUE';
  else
    close csr_install;
    return 'FALSE';
  end if;
  --
end chk_product_installed;
--
-- -------------------------------------------------------------------------
function get_user_status (p_assignment_status_type_id in number) return varchar2 is
--
l_user_status varchar2(80);
--
cursor csr_amend_user_status is
  select tl.user_status
  from per_ass_status_type_amends am,
       per_ass_status_type_amends_tl tl
  where am.assignment_status_type_id = p_assignment_status_type_id
  and am.business_group_id = get_business_group_id -- Bug #2519443
  and am.ass_status_type_amend_id =
      tl.ass_status_type_amend_id
  and tl.language=USERENV('LANG');
--
cursor csr_assign_user_status is
  select tl.user_status
  from per_assignment_status_types asg,
       per_assignment_status_types_tl tl
  where asg.assignment_status_type_id = p_assignment_status_type_id
  and asg.assignment_status_type_id =
      tl.assignment_status_type_id
  and tl.language=USERENV('LANG');
--
begin
--
  open csr_amend_user_status;
  fetch csr_amend_user_status into l_user_status;
  if csr_amend_user_status%found then
    close csr_amend_user_status;
    return l_user_status;
  else
    close csr_amend_user_status;
    open csr_assign_user_status;
    fetch csr_assign_user_status into l_user_status;
      if csr_assign_user_status%found then
        close csr_assign_user_status;
        return l_user_status;
      end if;
    close csr_assign_user_status;
  end if;
  return l_user_status;
--
end;
--

------------------------------------------------------------------------
function DECODE_TERRITORY (

--
         p_territory_code      varchar2) return varchar2 is
--
cursor csr_lookup is
         select    territory_short_name
         from      fnd_territories_vl
         where     territory_code      = p_territory_code;
--
v_meaning          varchar2(80) := null;
--
begin
--
-- Only open the cursor if the parameter is going to retrieve anything
--
if p_territory_code is not null then
  --
  open csr_lookup;
  fetch csr_lookup into v_meaning;
  close csr_lookup;
  --
end if;
return v_meaning;
end decode_territory;
-----------------------------------------------------------------------

function DECODE_ORGANIZATION (

--
         p_organization_id      number) return varchar2 is
--
cursor csr_lookup is
         select    name
         from      hr_all_organization_units_tl
         where     organization_id  = p_organization_id
           and     language = userenv('LANG');
--
v_meaning          hr_all_organization_units_tl.name%TYPE := null;
--
begin
--
-- Only open the cursor if the parameter is going to retrieve anything
--
if p_organization_id is not null then
  --
  open csr_lookup;
  fetch csr_lookup into v_meaning;
  close csr_lookup;
  --
end if;
return v_meaning;
end decode_organization;
-----------------------------------------------------------------------

function DECODE_AVAILABILITY_STATUS (

--
         p_availability_status_id      number) return varchar2 is
--
cursor csr_lookup is
         select    shared_type_name
         from      per_shared_types_vl
         where     shared_type_id  = p_availability_status_id;
--
v_meaning          per_shared_types_vl.shared_type_name%TYPE := null;
--
begin
--
-- Only open the cursor if the parameter is going to retrieve anything
--
if p_availability_status_id is not null then
  --
  open csr_lookup;
  fetch csr_lookup into v_meaning;
  close csr_lookup;
  --
end if;
return v_meaning;
end decode_availability_status;
-----------------------------------------------------------------------

function DECODE_POSITION_CURRENT_NAME (
--
         p_position_id      number) return varchar2 is
--
cursor csr_position is
         select    name
         from      hr_positions_x
         where     position_id  = p_position_id;
--
v_position_current_name          hr_positions_x.name%TYPE := null;
--
begin
--
-- Only open the cursor if the parameter is going to retrieve anything
--
if p_position_id is not null then
  --
  open csr_position;
  fetch csr_position into v_position_current_name;
  close csr_position;
  --
end if;
return v_position_current_name;
--
end decode_position_current_name;
--
-----------------------------------------------------------------------
--
function DECODE_POSITION_LATEST_NAME (
--
         p_position_id      in number,
         p_effective_date   in date default null) return varchar2 is
--
cursor csr_latest_position is
         select    pft.name
         from      hr_all_positions_f_tl pft
         where     pft.position_id  = p_position_id
            and    pft.language = userenv('LANG');
--
cursor csr_date_eff_position(p_position_id number, p_effective_date date) is
         select    psf.name
         from      hr_all_positions_f psf
         where     psf.position_id  = p_position_id
            and    p_effective_date between
                      psf.effective_start_date and psf.effective_end_date;
--
cursor c_session_date is
select effective_date
from fnd_sessions
where session_id = userenv('sessionid');
--
v_position_latest_name          hr_all_positions_f_tl.name%TYPE := null;
l_hr_pos_name_profile_value      varchar2(20);
l_effective_date date;
--
begin
--
-- Only open the cursor if the parameter is going to retrieve anything
--
if p_position_id is not null then
  --
  fnd_profile.get('HR_POSITION_NAME',l_hr_pos_name_profile_value);
  --
  if l_hr_pos_name_profile_value is null or l_hr_pos_name_profile_value = 'L' then
    --
    open csr_latest_position;
    fetch csr_latest_position into v_position_latest_name;
    close csr_latest_position;
    --
  else
    if p_effective_date is not null then
      l_effective_date := p_effective_date;
    else
      open c_session_date;
      fetch c_session_date into l_effective_date;
      close c_session_date;
      --
      if l_effective_date is null then
        l_effective_date := trunc(sysdate);
      end if;
      --
    end if;
    open csr_date_eff_position(p_position_id, l_effective_date);
    fetch csr_date_eff_position into v_position_latest_name;
    close csr_date_eff_position;
  end if;
end if;
return v_position_latest_name;
--
end decode_position_latest_name;
--
-----------------------------------------------------------------------

function DECODE_STEP (
--
         p_step_id           number
       , p_effective_date    date) return varchar2 is
--
cursor csr_step is
        select  psp.spinal_point
        from    per_spinal_point_steps_f sps, per_spinal_points psp
        where   sps.step_id = p_step_id
                and p_effective_date between sps.effective_start_date and sps.effective_end_date
                and sps.spinal_point_id = psp.spinal_point_id;
--
v_spinal_point          varchar2(2000) := null;
--
begin
--
-- Only open the cursor if the parameter is going to retrieve anything
--
if p_step_id is not null and p_effective_date is not null then
  --
  open csr_step;
  fetch csr_step into v_spinal_point;
  close csr_step;
  --
end if;
return v_spinal_point;
--
end decode_step;
--
-----------------------------------------------------------------------
function decode_ar_lookup
      (
      p_lookup_type varchar2,
      p_lookup_code varchar2) return varchar2 is
--
cursor csr_lookup is
  select meaning
   from ar_lookups
   where lookup_type = p_lookup_type
   and lookup_code = p_lookup_code;
--
v_meaning varchar2(80) := null;
begin
if p_lookup_type is not null and p_lookup_code is not null then
   --
    open csr_lookup;
    fetch csr_lookup into v_meaning;
    close csr_lookup;
end if;
--
return v_meaning;
--
end decode_ar_lookup;
----------------

function hr_lookup_locations
      (
      p_location_id number)
       return varchar2 is
--
-- 3902208 added substrb function to cursor
--
cursor csr_addr_lookup is
  select
substrb(
     LOC1.ADDRESS_LINE_1||
     decode(LOC1.ADDRESS_LINE_1,null,'',', ')|| LOC1.ADDRESS_LINE_2||
     decode(LOC1.ADDRESS_LINE_2,null,'',', ')|| LOC1.ADDRESS_LINE_3||
     decode(LOC1.ADDRESS_LINE_3,null,'',', ')||
     LOC1.TOWN_OR_CITY||decode(LOC1.TOWN_OR_CITY,null,'',', ')||
     LOC1.REGION_1||decode(LOC1.REGION_1,null,'',', ')|| LOC1.REGION_2||
     decode(LOC1.REGION_2,null,'',', ')||
     LOC1.REGION_3||decode(LOC1.REGION_3,null,'',', ')|| LOC1.POSTAL_CODE||
     decode(LOC1.POSTAL_CODE,null,'',', ')|| LOC1.COUNTRY||
     decode(LOC1.COUNTRY,null,' ',', ')
,1,600)
   from hr_locations LOC1
   where location_id  = p_location_id
   and   location_use = 'HR';
--
v_address varchar2(600) := null;
begin
if p_location_id  is not null  then
   --
    open csr_addr_lookup;
    fetch csr_addr_lookup into v_address;
    close csr_addr_lookup;
end if;
--
return v_address;
--
end hr_lookup_locations;
-----------------------------------------------------------------------
--
function DECODE_LATEST_POSITION_DEF_ID (
--
         p_position_id      number) return number is
--
cursor csr_position is
         select    position_definition_id
         from      hr_all_positions_f
         where     position_id  = p_position_id
            and    effective_end_date = hr_general.end_of_time;
--
v_position_definition_id          number(20) := null;
--
begin
--
-- Only open the cursor if the parameter is going to retrieve anything
--
if p_position_id is not null then
  --
  open csr_position;
  fetch csr_position into v_position_definition_id;
  close csr_position;
  --
end if;
return v_position_definition_id;
--
end decode_latest_position_def_id;

--------------------------------------------------------------
function DECODE_AVAIL_STATUS_START_DATE (
--
p_position_id in number,
p_availability_status_id number,p_effective_date date) return date is
--
cursor csr_avail_status is
select psf.availability_status_id, psf.effective_start_date
from hr_all_positions_f psf
where psf.position_id = p_position_id
and psf.effective_start_date < p_effective_date
order by psf.effective_start_date desc;
--
v_avail_status_start_dt date := p_effective_date;
l_availability_status_id        number(15);
l_effective_start_date          date;
--
begin
--
-- Only open the cursor if the parameter is going to retrieve anything
--
if p_position_id is not null
 and p_availability_status_id is not null
 and p_effective_date is not null  then
  --
  open csr_avail_status;
  loop
  fetch csr_avail_status into l_availability_status_id, l_effective_start_date;

  if l_availability_status_id <> p_availability_status_id
                or csr_avail_status%notfound then exit;
  end if;
      v_avail_status_start_dt := l_effective_start_date;
  end loop;
  close csr_avail_status;
  --
end if;
return nvl(v_avail_status_start_dt,p_effective_date);
--
end DECODE_AVAIL_STATUS_START_DATE;
--------------------------------------------------------------
function GET_POSITION_DATE_END (p_position_id in number) return date is
--
l_effective_start_date  date;
--
cursor csr_date_end is
select psf.effective_start_date - 1
from hr_all_positions_f psf, per_shared_types sht
where psf.position_id = p_position_id
and psf.availability_status_id = sht.shared_type_id
and sht.system_type_cd in ('DELETED','ELIMINATED');
--
begin
if p_position_id is not null then
  --
  open csr_date_end;
  fetch csr_date_end into l_effective_start_date;
  close csr_date_end;
  --
end if;
return l_effective_start_date;
end;
--------------------------------------------------------------
function DECODE_PERSON_NAME ( p_person_id           number) return varchar2 is
--
l_full_name     varchar2(240);
--
--
begin
if p_person_id is not null then
  --
  l_full_name := hr_person_name.get_person_name(p_person_id,trunc(sysdate));
  --
end if;
return l_full_name;
end;
--------------------------------------------------------------
function DECODE_GRADE_RULE ( p_grade_rule_id           number) return varchar2 is
--
cursor csr_grade_rule is
select pr.name
from pay_grade_rules pgr, pay_rates pr
where pgr.rate_id = pr.rate_id
and pgr.grade_rule_id = p_grade_rule_id;
--
l_pay_rate      varchar2(240);
--
begin
--
if p_grade_rule_id is not null then
  --
  open csr_grade_rule;
  fetch csr_grade_rule into l_pay_rate;
  close csr_grade_rule;
  --
end if;
return l_pay_rate;
--
end;
--------------------------------------------------------------
FUNCTION get_validation_name (p_target_location  IN VARCHAR2
                             ,p_field_name       IN VARCHAR2
                             ,p_legislation_code IN VARCHAR2
                             ,p_validation_type  IN VARCHAR2) return VARCHAR2 IS
--
 CURSOR c_plfi IS
   SELECT validation_name
   FROM pay_legislative_field_info
   WHERE UPPER(target_location) = UPPER(p_target_location)
     AND UPPER(field_name) = UPPER(p_field_name)
     AND UPPER(legislation_code) = UPPER(p_legislation_code)
     AND UPPER(validation_type) = UPPER(p_validation_type);
--
  l_validation_name pay_legislative_field_info.validation_name%TYPE;
--
  BEGIN
--
	OPEN c_plfi;
     FETCH c_plfi into l_validation_name;
     IF c_plfi%found THEN
	  CLOSE c_plfi;
       -- return the localization lookup type
       RETURN l_validation_name;
     ELSE
  	  CLOSE c_plfi;
         -- return the supplied core lookup type
	  RETURN p_validation_type;
	END IF;
--
END get_validation_name;
--------------------------------------------------------------
function decode_shared_type (
   p_shared_type_id      number) return varchar2 is
begin
  return(decode_availability_status(p_shared_type_id));
end;
--------------------------------------------------------------
--------------------------------------------------------------
function get_xbg_profile return varchar2 is
--
-- Returns the value of the 'HR: Cross Business Group' profile option
-- unless either :
--
--     A. No applications context is established
-- OR  B. The 'HR:Security Profile' profile option is null.
--
-- In these two cases the value 'Y' is returned.
-- The assumption for these cases is that the user needs an unrestricted
-- view. For example they are accessing from outside applications or in a
-- responsibility like one used for workflow notifications
--
-- Bug 2372279
-- Condition B. is to address the issues bugs like 2111280
-- This is that some code may run with an applications context but
-- have no security profile in which case we ignore the profile
-- option and allow a cross business group view. This guarantees
-- that a secure view behaves like the base table if the security
-- profile is not set.
--

--
begin

  --
  -- bug2372279
  --
  -- Using fnd_global.per_security_profile_id for performance
  -- reasons. hr_security.get_security_profile should probably
  -- be used as it looks like reporting users are getting an
  -- unrestricted bg view but will address this later as a
  -- separate pre-existing issue.
  --
  if ( fnd_global.user_id = -1
          or fnd_global.per_security_profile_id is null
          or fnd_global.per_security_profile_id = -1 )
  then
     return 'Y' ;
  else
     return( fnd_profile.value('HR_CROSS_BUSINESS_GROUP') );
  end if;

end get_xbg_profile;
--------------------------------------------------------------
end    HR_GENERAL;

/

  GRANT EXECUTE ON "APPS"."HR_GENERAL" TO "EBSBI";
