--------------------------------------------------------
--  DDL for Package Body FND_CLIENT_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_CLIENT_INFO" as
/* $Header: AFCINFOB.pls 120.2.12000000.6 2007/12/06 01:59:49 pdeluna ship $ */


--
-- Private Functions and Procedures
--
procedure generic_error(routine in varchar2,
         errcode in number,
         errmsg in varchar2) is
begin
    fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
    fnd_message.set_token('ROUTINE', routine);
    fnd_message.set_token('ERRNO', errcode);
    fnd_message.set_token('REASON', dbms_utility.format_error_stack);
--    dbms_output.put_line(fnd_message.get);
    fnd_message.raise_error;
end;

--
-- Public Functions and Procedures
--

--
-- Name
--   setup_client_info
-- Purpose
--   Sets up the operating unit context and the Multi-Currency context
--   in the client info area based on the current application,
--   responsibility, user, security_group and organization.
--
-- Arguments
--   application_id
--   responsibility_id
--   user_id
--   security_group_id
--   org_id
--
procedure setup_client_info(application_id in number,
                            responsibility_id in number,
                            user_id in number,
                            security_group_id in number,
                            org_id in number) is
   org_id_char varchar2(240);
   org_id_defined boolean;
   sp_id_char varchar2(240);
   sp_id_defined boolean;
   is_multi_org varchar2(1);
   no_morg_profile_value exception;
   reporting_sob_id_char varchar2(240);
   reporting_sob_id_defined boolean;
   is_multi_currency varchar2(1);
   no_mcur_profile_value exception;
   security_profile_id_char varchar2(240);
--   security_profile_id_defined boolean;
   l_security_profile_id NUMBER;
   l_morg_profile_name  varchar2(240);
begin

/* Bug 5646892: APPSPERFR12:FND:EXTRA FND_PROFILE.GET_SPECIFIC CALL IN
   FND_CLIENT_INFO.SETUP_CLIENT_INFO
   FND_GLOBAL will now pass in the org_id context, i.e. FND_GLOBAL.org_id.
   There is no need for setup_client_info to get the ORG_ID value again.
 */

--
-- Set MultiOrg Context
--
-- Check if org_id is NULL or -1. It is likely that org_id = -1, not NULL since
-- fnd_global is passing it in. When fnd_global calls fnd_profile to get the
-- org_id value and the value returned is NULL, fnd_global does not set org_id
-- to NULL. It just leaves the default value of -1. So, org_id = -1 means there
-- was no value returned by fnd_profile. A benefit of calling fnd_profile in
-- setup_client_info was that it did not check the value, but rather whether a
-- value was defined.
   if (org_id is NULL) or (org_id = -1) then
   -- If not R12, then check if the instance is multiorg-enabled.
      if fnd_release.major_version < 12 then
      -- Check FND_PRODUCT_GROUPS for multi-org/currency flags
         select nvl(multi_org_flag, 'N'), nvl(multi_currency_flag, 'N')
         into   is_multi_org, is_multi_currency
         from fnd_product_groups;
      -- If multiorg-enabled, raise an error since org_id should not be NULL.
      -- FND_GLOBAL.org_id should not be NULL if instance is multiorg-enabled.
         if is_multi_org = 'Y' then
         /* Bug 6637377: This fnd_profile.get_specific call is a LAST CHECK to
            make sure that org_id is, indeed, not set. Need to make sure before
            the error is raised. This should not undo the fix for 5646892
            completely and is needed.
         */
            fnd_profile.get_specific('ORG_ID', user_id, responsibility_id,
               application_id, org_id_char, org_id_defined);

            -- If org_id is really not defined, then raise the exception, as
            -- planned.
            if (not org_id_defined) then

               select  user_profile_option_name
               into   l_morg_profile_name
               from   fnd_profile_options_vl
               where  profile_option_name = 'ORG_ID';

               raise no_morg_profile_value;
            end if;
         end if;
      else
      -- Bug 2852842: Due to MOAC re-architecture for R12, a default org_id
      -- is no longer required. If ORG_ID is not set, then default the org
      -- client_info area to null. No need to raise an error in R12.
         org_id_char := '';
      end if;
   else
   -- If org_id is NOT NULL, convert to string.
      org_id_char := to_char(org_id);
   end if;

   fnd_client_info.set_org_context(org_id_char);

--
-- Set MultiCurrency Context.
-- This applies to releases before R12.
--
   if fnd_release.major_version < 12 then
      if is_multi_currency = 'Y' then
      --
      -- Get MRC_REPORTING_SOB_ID profile option value
      --
        fnd_profile.get_specific('MRC_REPORTING_SOB_ID',
                                 user_id, responsibility_id, application_id,
                                 reporting_sob_id_char, reporting_sob_id_defined);
      --
      -- If MRC_REPORTING_SOB_ID profile option defined for this responsibility,
      -- set the currency context = MRC_REPORTING_SOB_ID for this resp
      --
        if reporting_sob_id_defined then
          fnd_client_info.set_currency_context(reporting_sob_id_char);
        else
          raise no_mcur_profile_value;
        end if;

      end if;
   end if;

--
-- Set Security Group Context
--
  fnd_client_info.set_security_group_context(to_char(security_group_id));

exception
   when no_morg_profile_value then
     fnd_message.set_name('FND', 'FND-ORG_ID PROFILE CANNOT READ');
     fnd_message.set_token('OPTION', l_morg_profile_name);
--     dbms_output.put_line(fnd_message.get);
     fnd_message.raise_error;
--     generic_error('FND_CLIENT_INFO.SETUP_CLIENT_INFO', -20000,
--      'MultiOrg enabled but ORG_ID profile not defined');
   when no_mcur_profile_value then
     generic_error('FND_CLIENT_INFO.SETUP_CLIENT_INFO', -20000,
      'MultiCurrency enabled but MRC_REPORTING_SOB_ID profile not defined');
   when others then
     generic_error('FND_CLIENT_INFO.SETUP_CLIENT_INFO', sqlcode, sqlerrm);

end setup_client_info;

--
-- Name
--   setup_client_info
-- Purpose
--   Sets up the operating unit context and the Multi-Currency context
--   in the client info area based on the current application,
--   responsibility, user, and security_group.
--   This is an overloaded version for backwards compatibility.
--
-- Arguments
--   application_id
--   responsibility_id
--   user_id
--   security_group_id
--
procedure setup_client_info(application_id in number,
                            responsibility_id in number,
                            user_id in number,
                            security_group_id in number) is
begin

   -- Call setup_client_info and pass in fnd_global.org_id for
   -- org argument.
   setup_client_info(application_id, responsibility_id, user_id,
      security_group_id, fnd_global.org_id);

end setup_client_info;

--
-- Name
--   set_org_context
-- Purpose
--   Sets up the operating unit context in the client info area
--
-- Arguments
--   context    - org_id for the operating unit; can be up to 10
--                bytes long
--
procedure set_org_context (context in varchar2) is
   context_area      varchar2(64);
   context_too_long  exception;
   bad_characters    exception;
   local_context     varchar2(30);
begin

   -- check for multibyte characters

   if length(context) <> lengthb(context) then
      raise bad_characters;
   end if;

   -- check for input string too long

   if lengthb(context) > 10 then
      raise context_too_long;
   end if;

   -- set local_context to first ten chars of context
   -- set to a single space if context was null

   local_context := substrb(nvl(context,' '),1,10);

   -- pad local_context on the right with blanks to exactly 10 bytes
   -- Do not use RPAD(), because it may not work as expected with a
   -- MultiByte character set

   while lengthb(local_context) < 10 loop
     local_context := local_context || ' ';
   end loop;

   -- Get current CLIENT_INFO value in context_area variable

   dbms_application_info.read_client_info(context_area);

   -- pad context_area on the right with blanks to exactly 64 bytes
   -- Do not use RPAD(), because it may not work as expected with a
   -- MultiByte character set

   context_area := nvl(context_area,' ');

   while lengthb(context_area) < 64 loop
     context_area := context_area || ' ';
   end loop;

   -- load new value into context_area

   context_area := local_context ||
                   substrb(context_area,11,54);

   -- save context_area variable to CLIENT_INFO

   dbms_application_info.set_client_info(context_area);

exception
   when context_too_long then
      fnd_message.set_name('FND', 'CLIENT_INFO_ARG_TOO_LONG');
      fnd_message.set_token('ROUTINE', 'SET_ORG_CONTEXT');
      fnd_message.set_token('BAD_ARG', context);
--      dbms_output.put_line(fnd_message.get);
      fnd_message.raise_error;
   when bad_characters then
      generic_error('FND_CLIENT_INFO.SET_ORG_CONTEXT', -20000,
      'Only single-byte characters are valid input');
   when others then
      generic_error('FND_CLIENT_INFO.SET_ORG_CONTEXT', sqlcode, sqlerrm);

end set_org_context;

--
-- Name
--   set_currency_context
-- Purpose
--   Sets up the client info area for Multi-Currency reporting
--
-- Arguments
--   context    - context information up to 10 bytes
--
procedure set_currency_context (context in varchar2) is
   context_area      varchar2(64);
   context_too_long  exception;
   bad_characters    exception;
   local_context     varchar2(30);
begin

   -- check for multibyte characters

   if length(context) <> lengthb(context) then
      raise bad_characters;
   end if;

   -- check for input string too long

   if lengthb(context) > 10 then
      raise context_too_long;
   end if;

   -- set local_context to first ten chars of context
   -- set to a single space if context was null

   local_context := substrb(nvl(context,' '),1,10);

   -- pad local_context on the right with blanks to exactly 10 bytes
   -- Do not use RPAD(), because it may not work as expected with a
   -- MultiByte character set

   while lengthb(local_context) < 10 loop
     local_context := local_context || ' ';
   end loop;

   -- Get current CLIENT_INFO value in context_area variable

   dbms_application_info.read_client_info(context_area);

   -- pad context_area on the right with blanks to exactly 64 bytes
   -- Do not use RPAD(), because it may not work as expected with a
   -- MultiByte character set

   context_area := nvl(context_area,' ');

   while lengthb(context_area) < 64 loop
     context_area := context_area || ' ';
   end loop;

   -- load new value into context_area

   context_area := substrb(context_area,1,44) ||
                   local_context ||
                   substrb(context_area,55,10);

   -- save context_area variable to CLIENT_INFO

   dbms_application_info.set_client_info(context_area);

exception
   when context_too_long then
      fnd_message.set_name('FND', 'CLIENT_INFO_ARG_TOO_LONG');
      fnd_message.set_token('ROUTINE', 'SET_CURRENCY_CONTEXT');
      fnd_message.set_token('BAD_ARG', context);
--      dbms_output.put_line(fnd_message.get);
      fnd_message.raise_error;
   when bad_characters then
      generic_error('FND_CLIENT_INFO.SET_CURRENCY_CONTEXT', -20000,
      'Only single-byte characters are valid input');
   when others then
      generic_error('FND_CLIENT_INFO.SET_CURRENCY_CONTEXT', sqlcode, sqlerrm);

end set_currency_context;

--
-- Name
--   set_security_group_context
-- Purpose
--   Sets up the the security group context in the client info area
--
-- Arguments
--   context    - security_group_id; can be up to 10 bytes long
--
procedure set_security_group_context (context in varchar2) is
   context_area      varchar2(64);
   context_too_long  exception;
   bad_characters    exception;
   local_context     varchar2(30);
begin

   -- check for multibyte characters

   if length(context) <> lengthb(context) then
      raise bad_characters;
   end if;

   -- check for input string too long

   if lengthb(context) > 10 then
      raise context_too_long;
   end if;

   -- set local_context to first ten chars of context
   -- set to a single space if context was null

   local_context := substrb(nvl(context,' '),1,10);

   -- pad local_context on the right with blanks to exactly 10 bytes
   -- Do not use RPAD(), because it may not work as expected with a
   -- MultiByte character set

   while lengthb(local_context) < 10 loop
     local_context := local_context || ' ';
   end loop;

   -- Get current CLIENT_INFO value in context_area variable

   dbms_application_info.read_client_info(context_area);

   -- pad context_area on the right with blanks to exactly 64 bytes
   -- Do not use RPAD(), because it may not work as expected with a
   -- MultiByte character set

   context_area := nvl(context_area,' ');

   while lengthb(context_area) < 64 loop
     context_area := context_area || ' ';
   end loop;

   -- load new value into context_area
   context_area := substrb(context_area,1,54) ||
                   local_context;

   -- save context_area variable to CLIENT_INFO

   dbms_application_info.set_client_info(context_area);

exception
   when context_too_long then
      fnd_message.set_name('FND', 'CLIENT_INFO_ARG_TOO_LONG');
      fnd_message.set_token('ROUTINE', 'SET_SECURITY_GROUP_CONTEXT');
      fnd_message.set_token('BAD_ARG', context);
--      dbms_output.put_line(fnd_message.get);
      fnd_message.raise_error;
   when bad_characters then
      generic_error('FND_CLIENT_INFO.SET_SECURITY_GROUP_CONTEXT', -20000,
      'Only single-byte characters are valid input');
   when others then
      generic_error('FND_CLIENT_INFO.SET_SECURITY_GROUP_CONTEXT',
          sqlcode, sqlerrm);
end set_security_group_context;

--
-- Name
--   org_security
-- Purpose
--   Called by oracle server during parsing sql statment
--
-- Arguments
--   obj_schema   - schema of the object
--   obj_name     - name of the object
--
FUNCTION org_security(
  obj_schema          VARCHAR2
, obj_name            VARCHAR2
)
RETURN VARCHAR2
IS

   -- AOL suggested that all product-specific logic should be moved to
   -- product-specific packages. Hence, the org_security logic is moved
   -- to the new package MO_GLOBAL.
   --
   -- However, FND_CLIENT_INFO.org_security is referenced in many CRM
   -- views. Removing it from this package is out of the question since
   -- all CRM code would break.
   --
   -- So, only option is to keep it as a wrapper function for
   -- MO_GLOBAL.org_security

   l_sql_stmt  VARCHAR2(1000);
   l_predicate VARCHAR2(2000) := '';


BEGIN

   -- For backward compatible purpose
   l_sql_stmt := 'select mo_global.org_security(:1, :2) from dual';
   EXECUTE IMMEDIATE l_sql_stmt INTO l_predicate USING
     IN obj_schema,
     IN obj_name;

   RETURN l_predicate;

   -- Alternatively, we could have avoided the dynamic SQL by simply
   -- returning MO_GLOBAL.org_security(obj_schema, obj_name) but we don't
   -- want this package to have dependencies on other packages during
   -- compilation.

EXCEPTION
   WHEN OTHERS  THEN
     fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
     fnd_message.set_token('ERRNO', to_char(sqlcode));
     fnd_message.set_token('REASON', dbms_utility.format_error_stack);
     fnd_message.set_token('ROUTINE', 'ORG_SECURITY');
     app_exception.raise_exception;
END org_security;

end fnd_client_info;

/
