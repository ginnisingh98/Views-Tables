--------------------------------------------------------
--  DDL for Package Body OWA_INIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OWA_INIT" as
/* $Header: AFOAUTHB.pls 115.4 99/07/16 23:25:31 porting  $ */

--
-- Authorize
--   Global DCD Authorization callback function
--   It is used when DCD's authorization scheme is set to GLOBAL.
--
function authorize return boolean is
  curproc varchar2(100);
  x_package varchar2(100);
  dot_location number;
  dummy number;
  found boolean := FALSE;

  cursor proc_curs(v_procedure varchar2) is
    SELECT 1
    FROM   FND_ENABLED_PLSQL
    WHERE  PLSQL_TYPE = 'PROCEDURE'
    AND    PLSQL_NAME = v_procedure
    AND    ENABLED = 'Y';

  cursor pack_curs(v_pack varchar2, v_packproc varchar2) is
    SELECT 1
    FROM   FND_ENABLED_PLSQL
    WHERE  (  (PLSQL_TYPE = 'PACKAGE' AND PLSQL_NAME = v_pack)
           OR (PLSQL_TYPE = 'PACKAGE.PROCEDURE' AND PLSQL_NAME = v_packproc))
    AND    ENABLED = 'Y';

begin
  curproc := owa_util.get_procedure;
  dot_location := instr(curproc, '.');

  if (dot_location = 0) then
    -- This is a procedure
    -- Check for procedure match.
    open proc_curs(curproc);
    fetch proc_curs into dummy;
    if (proc_curs%found) then
      found := TRUE;
    end if;
    close proc_curs;
  else
    -- This is a package.procedure
    -- Check for either package or package.procedure match.
    x_package := substr(curproc, 0, dot_location-1);

    open pack_curs(x_package, curproc);
    fetch pack_curs into dummy;
    if (pack_curs%found) then
      found := TRUE;
    end if;
    close pack_curs;
  end if;

  if (found) then
    return TRUE;
  else
    owa_sec.set_protection_realm('SECURITY ERROR');
    return FALSE;
  end if;
end authorize;

begin -- OWA_INIT package initialization

   -- Set the PL/SQL Agent's authorization scheme.
   --   This should be modified to reflect the authorization need of
   --   your Database Connection Descriptor (DCD)
   owa_sec.set_authorization(OWA_SEC.GLOBAL);
end OWA_INIT;

/
