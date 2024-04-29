--------------------------------------------------------
--  DDL for Package Body FND_SSO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_SSO" as
/* $Header: afssob.pls 120.1.12010000.1 2008/07/25 14:33:22 appldev ship $ */

----------------------------------------------------------------------------
/*
**  authenticate_user
*/
FUNCTION authenticate_user(p_user		in varchar2,
                           p_password	in varchar2) return pls_integer
is	pragma autonomous_transaction;
	result		varchar2(1);
	p_login_id	number;
	p_expired	varchar2(1);

begin

	-- Validate the username/password combination.  If valid, a session will be created and
	-- 'Y' will be returned.  If invalid, 'N' will be returned.
	result := fnd_web_sec.validate_login(p_user, p_password, p_login_id, p_expired);
	commit;

 	-- If result != 'Y' then raise the exception EXT_AUTH_FAILURE_EXCEPTION
	if (result <> 'Y') then
		raise EXT_AUTH_FAILURE_EXCEPTION;

	-- If result = 'Y', then check if the password is expired.  If it is, then
	-- return EXT_AUTH_PASSWD_EXPIRED
	elsif (p_expired = 'Y') then
		return EXT_AUTH_PASSWD_EXPIRED;

	-- If result = 'Y' and password is not expired, then return EXT_AUTH_SUCCESS
	else
		return EXT_AUTH_SUCCESS;
	end if;

exception
  when EXT_AUTH_FAILURE_EXCEPTION then
    raise;
  when others then
    raise EXT_AUTH_UNKNOWN_EXCEPTION;
end;
----------------------------------------------------------------------------
/*
**  change_passwd
*/
PROCEDURE change_passwd(p_user   in varchar2,
                        p_oldpwd in varchar2,
                        p_newpwd in varchar2)
is
  res varchar2(1);
begin
  if (p_user is null) then
    raise EXT_NOT_SUPPORTED_EXCEPTION;
  end if;

  res := fnd_web_sec.change_password(p_user, p_oldpwd, p_newpwd, p_newpwd);

  if (res <> 'Y') then
    raise EXT_CHANGE_PASSWORD_EXCEPTION;
  end if;
exception
  when EXT_NOT_SUPPORTED_EXCEPTION then
    raise;
  when EXT_CHANGE_PASSWORD_EXCEPTION then
    raise;
  when others then
    raise EXT_AUTH_UNKNOWN_EXCEPTION;
end;
----------------------------------------------------------------------------
/*
**  get_configuration
*/
PROCEDURE get_configuration(p_config out NOCOPY ext_config)
is
  ourConfig ext_config_rec_type;
begin
  raise EXT_NOT_SUPPORTED_EXCEPTION;

  -- This looks like our big chance to return a list of parameter
  -- name/value pairs.  Is there anything we want to pass on?
  p_config(1) := ourConfig;
end;
----------------------------------------------------------------------------
/*
**  get_authentication_name
*/
FUNCTION get_authentication_name return varchar2
is
begin
  return 'Application Object Library';
end;
----------------------------------------------------------------------------
end fnd_sso;

/
