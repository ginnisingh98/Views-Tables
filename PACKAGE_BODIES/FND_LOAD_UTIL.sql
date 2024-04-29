--------------------------------------------------------
--  DDL for Package Body FND_LOAD_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_LOAD_UTIL" as
/* $Header: AFLDUTLB.pls 120.10.12010000.1 2008/07/25 14:15:56 appldev ship $ */


--
-- OWNER_NAME
--   Return owner tag to be used in FNDLOAD data file
-- IN
--   p_id - user_id of last_updated_by column
-- RETURNS
--   OWNER attribute value for FNDLOAD data file
--
function OWNER_NAME(
  p_id in number)
return varchar2 is
  l_owner_name varchar2(100);
  l_release_name varchar2(50);
begin
  -- Look for profile over-ride for internal seed env
  l_owner_name := fnd_profile.value('FNDLOAD_OWNER');
  if (l_owner_name is not null) then
     return l_owner_name;
  end if;

  if (p_id in (0, 1, 2) or ((p_id >=120) and (p_id<=129))) then
   begin
    -- Seed data, old or new
    -- get release name of source seed database
    select RELEASE_NAME
    into l_release_name
    from FND_PRODUCT_GROUPS;

    if ( l_release_name like '12.%.%') then
    	-- embody OWNER with RELEASE_NAME info only for R12 release
    	l_owner_name := 'ORACLE' || l_release_name;
    else
    	-- old fashion to back support 11i development
    	l_owner_name := 'ORACLE';
    end if;

    exception
      when no_data_found then
      	-- if FND_PRODUCT_GROUPS is not seeded, back to 11i old fashion
      	l_owner_name := 'ORACLE';
   end;
  else
   begin
    -- User customized data
    select user_name
     into l_owner_name
     from fnd_user
    where user_id = p_id;

    exception
     when no_data_found then
        l_owner_name := 'USER';
   end;
  end if;

  return l_owner_name;
end OWNER_NAME;

--
-- OWNER_ID
--   Return the user_id of the OWNER attribute
-- IN
--   p_name - OWNER attribute value from FNDLOAD data file
-- RETURNS
--   user_id of owner to use in who columns
--
function OWNER_ID(
  p_name in varchar2)
return number is
l_user_id number;
begin
  if (p_name in ('SEED','CUSTOM')) then
    -- Old loader seed data
    return 1;
  elsif (p_name = 'ORACLE') then
    -- New loader seed data
    return 2;
  elsif (p_name like 'ORACLE12._.%') then
    return 120+to_number(substr(p_name,10,1));
  else
   begin
    -- User customized data
    select user_id
     into l_user_id
     from fnd_user
    where p_name = user_name;
     return l_user_id;
    exception
     when no_data_found then
        return -1;
   end;
  end if;
end OWNER_ID;

--
-- UPLOAD_TEST
--   Test whether or not to over-write database row when uploading
--   data from FNDLOAD data file, based on owner attributes of both
--   database row and row in file being uploaded.
-- IN
--   p_file_id - FND_LOAD_UTIL.OWNER_ID(<OWNER attribute from data file>)
--   p_file_lud - LAST_UPDATE_DATE attribute from data file
--   p_db_id - LAST_UPDATED_BY of db row
--   p_db_lud - LAST_UPDATE_DATE of db row
--   p_custom_mode - CUSTOM_MODE FNDLOAD parameter value
-- RETURNS
--   TRUE if safe to over-write.
--
function UPLOAD_TEST(
  p_file_id     in number,
  p_file_lud    in date,
  p_db_id       in number,
  p_db_lud      in date,
  p_custom_mode in varchar2)
return boolean is
  l_db_id number;
  l_file_id number;
  l_original_seed_data_window date;
  retcode boolean;
begin
  -- CUSTOM_MODE=FORCE trumps all.
  if (p_custom_mode = 'FORCE') then
    retcode := TRUE;
    return retcode;
  end if;

  -- Handle cases where data was previously up/downloaded with
  -- 'SEED'/1 owner instead of 'ORACLE'/2, but DOES have a version
  -- date.  These rows can be distinguished by the lud timestamp;
  -- Rows without versions were uploaded with sysdate, rows with
  -- versions were uploaded with a date (with time truncated) from
  -- the file.

  -- Check file row for SEED/version
  l_file_id := p_file_id;
  if ((l_file_id in (0,1)) and (p_file_lud = trunc(p_file_lud)) and
      (p_file_lud < sysdate - .1)) then
    l_file_id := 2;
  end if;

  -- Check db row for SEED/version.
  -- NOTE: if db ludate < seed_data_window, then consider this to be
  -- original seed data, never touched by FNDLOAD, even if it doesn't
  -- have a timestamp.
  l_db_id := p_db_id;
  l_original_seed_data_window := to_date('01/01/1990','MM/DD/YYYY');
  if ((l_db_id in (0,1)) and (p_db_lud = trunc(p_db_lud)) and
      (p_db_lud > l_original_seed_data_window)) then
    l_db_id := 2;
  end if;


if (NLS_MODE) then
  if (l_file_id in (0,1)) then
    -- File owner is old FNDLOAD.
    if (l_db_id in (0,1)) then
      -- DB owner is also old FNDLOAD.
      -- Over-write, but only if file ludate >= db ludate.
      if (p_file_lud >= p_db_lud) then
        retcode := TRUE;
      else
        retcode := FALSE;
      end if;
    else
      retcode := FALSE;
    end if;
  elsif (l_file_id = 2) then
    -- File owner is new FNDLOAD.  Over-write if:
    -- 1. Db owner is old FNDLOAD, or
    -- 2. Db owner is new FNDLOAD, and file date >= db date
    if ((l_db_id in (0,1)) or
	((l_db_id = 2) and (p_file_lud >= p_db_lud))) then
      retcode :=  TRUE;
    else
      retcode := FALSE;
    end if;
 elsif ((l_file_id >= 120)  and (l_file_id<=129)) then
    -- File owner is R12 seed data, Over-write if:
    -- 1. Db owner is (0, 1, 2,120..129) and l_db_id<l_file_id, or
    -- 2. Db owner is file owner, and file date >= db date
    if (
        ((l_db_id in (0,1,2) or ((l_db_id>=120) and (l_db_id<=129))) and (l_db_id<l_file_id)) or
        ((l_db_id = l_file_id) and (p_file_lud >= p_db_lud))
       ) then
      retcode :=  TRUE;
    else
      retcode := FALSE;
    end if;


  else
    -- File owner is USER.  Over-write if:
    -- 1. Db owner is old or new FNDLOAD, or
    -- 2. File date >= db date
    if ((l_db_id in (0,1,2,120,121,122,123,124,125,126,127,128,129)) or
	(trunc(p_file_lud) >= trunc(p_db_lud))) then
      retcode := TRUE;
    else
      retcode := FALSE;
    end if;
  end if;
else
  if (l_file_id in (0,1)) then
    -- File owner is old FNDLOAD.
    if (l_db_id in (0,1)) then
      -- DB owner is also old FNDLOAD.
      -- Over-write, but only if file ludate > db ludate.
      if (p_file_lud > p_db_lud) then
        retcode := TRUE;
      else
        retcode := FALSE;
      end if;
    else
      retcode := FALSE;
    end if;
  elsif (l_file_id = 2) then
    -- File owner is new FNDLOAD.  Over-write if:
    -- 1. Db owner is old FNDLOAD, or
    -- 2. Db owner is new FNDLOAD, and file date > db date
    if ((l_db_id in (0,1)) or
        ((l_db_id = 2) and (p_file_lud > p_db_lud))) then
      retcode :=  TRUE;
    else
      retcode := FALSE;
    end if;
 elsif ((l_file_id >= 120) and (l_file_id <= 129)) then
    -- File owner is R12 seed data, Over-write if:
    -- 1. Db owner is (0,1), or
    -- 2. Db owner is 2 and p_file_lud != p_db_lud, or
    -- 2. Db owner is 120 and file date > db date
    if ((l_db_id in (0,1)) or
        ((l_db_id in ( 2,120,121,122,123,124,125,126,127,128,129) and (l_db_id < l_file_id)) and (p_file_lud <> p_db_lud)) or
        ((l_db_id = l_file_id) and (p_file_lud > p_db_lud))) then
      retcode :=  TRUE;
    else
      retcode := FALSE;
    end if;


  else
    -- File owner is USER.  Over-write if:
    -- 1. Db owner is old or new FNDLOAD, or
    -- 2. File date > db date
    if ((l_db_id in (0,1,2,120,121,122,123,124,125,126,127,128,129)) or
        (trunc(p_file_lud) > trunc(p_db_lud))) then
      retcode := TRUE;
    else
      retcode := FALSE;
    end if;
  end if;

end if;


  if (NLS_MODE) then
    if (retcode = FALSE) then
      fnd_message.set_name('FND', 'FNDLOAD_CUSTOMIZED');
    end if;
  else
    if (retcode = FALSE) then
      fnd_message.set_name('FND', 'FNDLOAD_CUSTOMIZED_US');
    end if;
  end if;

  return retcode;
end UPLOAD_TEST;

-- Bug 2438503 Routine to return NULL value.

function NULL_VALUE
 return varchar2 is
begin
   return '*NULL*';
end NULL_VALUE;

procedure SET_NLS_MODE is
begin
  NLS_MODE:=TRUE;
end SET_NLS_MODE;

end FND_LOAD_UTIL;

/
