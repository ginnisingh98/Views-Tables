--------------------------------------------------------
--  DDL for Package Body OWA_CUSTOM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OWA_CUSTOM" as
/* $Header: AFOAUTHB.pls 115.14 2002/04/11 17:39:31 pkm ship  $ */


--
-- Authorize
--   Custom DAD Authorization callback function
--   It is used when DAD's authorization scheme is set to CUSTOM.
--
function authorize return boolean is
  curproc           varchar2(100);
  path              varchar2(2000);

begin
  -- Get package being executed.
  curproc := upper(owa_util.get_procedure);

  if (curproc is null) then
    -- Must be from a path alias.
    -- Get the path alias instead, and check that it is in the
    -- authorized list.
    curproc := upper(owa_util.get_cgi_env('PATH_ALIAS'));
  else
    -- Check that a schema hasn't been added to the package in the path
    -- PATH_INFO should be '/package.proc?<args>'
    path := upper(owa_util.get_cgi_env('PATH_INFO'));
    if (instr(path, curproc) <> 2) then
      owa_sec.set_protection_realm('SECURITY ERROR:'||curproc||':');
      return FALSE;
    end if;
  end if;

  if (fnd_web_config.check_enabled(curproc) = 'Y') then
    owa_sec.set_protection_realm('SUCCESS');
    return TRUE;
  else
    owa_sec.set_protection_realm('SECURITY ERROR:'||curproc||':');
    return FALSE;
  end if;
end authorize;

begin -- OWA_CUSTOM package initialization

   -- Set the PL/SQL Agent's authorization scheme.
   -- OWA_SEC.CUSTOM level authorizes on a per-schema basis.
   -- It looks first in user's schema for the authorize function, and
   -- if not found defaults to a global one in oas_public schema.
   owa_sec.set_authorization(OWA_SEC.CUSTOM);
end OWA_CUSTOM;

/
