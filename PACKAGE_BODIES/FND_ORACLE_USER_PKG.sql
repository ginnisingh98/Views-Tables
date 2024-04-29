--------------------------------------------------------
--  DDL for Package Body FND_ORACLE_USER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_ORACLE_USER_PKG" as
/* $Header: AFSCOUSB.pls 120.1 2005/07/02 03:08:50 appldev ship $ */

----------------------------------------------------------------------------
/* PRIVATE */
function boolRet(ret varchar2) return boolean is
begin
  if (ret = 'Y') then
    return TRUE;
  end if;
  return FALSE;
end;

/* PRIVATE */
-- Called by LOAD_ROW() with a reencrypted_password
procedure CreateOracleUser (
  x_oracle_username            in varchar2,
  x_owner                      in varchar2,
  x_reencrypted_oracle_password in varchar2,
  x_description                in varchar2 default null,
  x_enabled_flag	       in varchar2 default null,
  x_read_only_flag	       in varchar2 default null) is

  owner_id number := 0;
  ouser_id number;
  ret varchar2(1) := 'N';
  reason varchar2(32000);

begin
  if (x_owner = 'SEED') then
    owner_id := 1;
  elsif (x_owner = 'CUST') then
    owner_id := 0;
  end if;

  /* Java layer takes care of decrypting and encrypting password and */
  /* store in table */
  ret :=fnd_web_sec.create_oracle_user(x_oracle_username,
                                         x_reencrypted_oracle_password,
                                         'LOADER',
                                         ouser_id);
  if (ret = 'Y') then

    -- update the rest of the data except password
    update fnd_oracle_userid set
      last_update_date = sysdate,
      last_updated_by = owner_id,
      last_update_login = 0,
      description = nvl(x_description, description),
      enabled_flag = x_enabled_flag,
       read_only_flag = x_read_only_flag
    where oracle_username = upper(x_oracle_username);

  else
    -- The java layer puts message onto the message stack.
    -- WHAT TO DO WITH THE REAL MESSAGE????
    reason := fnd_message.get();
    fnd_message.set_name('FND', 'FND_CREATE_ORACLE_USER_FAILED');
    fnd_message.set_token('ORACLE_USER_NAME', x_oracle_username);
    fnd_message.set_token('REASON', reason);
    app_exception.raise_exception;
  end if;

end CreateOracleUser;

----------------------------------------------------------------------------
--
-- LOAD_ROW (PUBLIC): used by the FNDLOAD not meant for public use
--
--
procedure LOAD_ROW (
  x_oracle_username			in	VARCHAR2,
  x_owner                           	in	VARCHAR2,
  x_encrypted_oracle_password	 	in	VARCHAR2,
  x_description			        in	VARCHAR2,
  x_enabled_flag		        in	VARCHAR2,
  x_read_only_flag		        in	VARCHAR2) IS
begin

  fnd_oracle_user_pkg.load_row(
	x_oracle_username => x_oracle_username,
	x_owner => x_owner,
	x_encrypted_oracle_password => x_encrypted_oracle_password,
	x_description => x_description,
	x_enabled_flag => x_enabled_flag,
	x_read_only_flag => x_read_only_flag,
	x_custom_mode => null,
	x_last_update_date => null);
end LOAD_ROW;

-- Overloaded !!

procedure LOAD_ROW (
  x_oracle_username			in	VARCHAR2,
  x_owner                           	in	VARCHAR2,
  x_encrypted_oracle_password	 	in	VARCHAR2,
  x_description			        in	VARCHAR2,
  x_enabled_flag		        in	VARCHAR2,
  x_read_only_flag		        in	VARCHAR2,
  x_custom_mode				in	VARCHAR2,
  x_last_update_date			in	VARCHAR2) IS

  owner_id number := 0;
  ret boolean;
  f_luby    number;  -- entity owner in file
  f_ludate  date;    -- entity update date in file
  db_luby   number;  -- entity owner in db
  db_ludate date;    -- entity update date in db
  enc_pwd   varchar2(100); -- encrypted password to go in database

begin
   -- Translate owner to file_last_updated_by
  f_luby := fnd_load_util.owner_id(x_owner);

  -- Translate char last_update_date to date
  f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);

  begin
    select LAST_UPDATED_BY, LAST_UPDATE_DATE
     into db_luby, db_ludate
     from fnd_oracle_userid
    where oracle_username = x_oracle_username;

    if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, X_CUSTOM_MODE)) then

      /* Convert the password from being encrypted with the loader key to */
      /* being encrypted with right key for storing it in the database */
      /* (apps pwd) */
      enc_pwd := x_encrypted_oracle_password;
      if ((enc_pwd <> 'EXTERNAL') AND (enc_pwd <> 'INVALID')) then
        enc_pwd := fnd_web_sec.cvt_reencrypted_oracle_pwd(
                    x_encrypted_oracle_password, 'LOADER');
      end if;
      if(enc_pwd is NULL) then
         enc_pwd := 'INVALID';
      end if;

      update fnd_oracle_userid set
        last_update_date = f_ludate,
        last_updated_by = f_luby,
        last_update_login = 0,
        description = nvl(x_description, description),
        enabled_flag = x_enabled_flag,
        read_only_flag = x_read_only_flag,
        encrypted_oracle_password = enc_pwd
      where oracle_username = x_oracle_username;
    end if;
   exception
     when no_data_found then

      fnd_oracle_user_pkg.createoracleuser(
         x_oracle_username,
         x_owner,
         x_encrypted_oracle_password,
         x_description,
         x_enabled_flag,
         x_read_only_flag);

  end;
end LOAD_ROW;

--
-- GetReEncryptedPassword (PUBLIC)
--   Return user password encrypted with new key. This just returns the
--   newly encrypted password. It does not set the password in
--   FND_ORACLE_USERID table.
--
-- Usage example in pl/sql
--   declare
--     newpass varchar2(100);
--   begin
--     newpass := fnd_oracle_user_pkg.getreencryptedpassword('SCOTT','NEWKEY');
--   end;
--
-- Input (Mandatory)
--   username:  User Name
--   newkey     New Key
--
function GetReEncryptedPassword(username varchar2,
                                newkey   varchar2) return varchar2 is
begin
  return (fnd_web_sec.get_reencrypted_oracle_pwd(username, newkey));
end;

end FND_ORACLE_USER_PKG;

/
