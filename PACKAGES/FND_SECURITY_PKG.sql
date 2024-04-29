--------------------------------------------------------
--  DDL for Package FND_SECURITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_SECURITY_PKG" AUTHID DEFINER AS
/* $Header: AFSCUSVS.pls 120.7 2007/10/19 11:43:09 stadepal ship $ */



-- This routine is for AOL INTERNAL USE ONLY !!!!!!!
--
PROCEDURE fnd_encrypted_pwd(
  p_username IN VARCHAR2,
  p_server_id IN VARCHAR2,
  p_user_id IN OUT NOCOPY VARCHAR2,
  p_password IN OUT NOCOPY VARCHAR2,
  p_module IN VARCHAR2 default 'UNKNOWN',
  p_version IN VARCHAR2 default '',
  p_case_hash_userpwd IN VARCHAR2 default '',  -- Bug 5892249 fskinner
  p_nocase_hash_userpwd IN VARCHAR2 default '');  -- Bug 5892249 fskinner

--
-- fnd_encrypted_password
--   *** OBSOLETE - DO NOT USE ***
--
PROCEDURE fnd_encrypted_password(p_username IN VARCHAR2,
				 p_server_id IN VARCHAR2,
				 p_user_id IN OUT NOCOPY VARCHAR2,
				 p_password IN OUT NOCOPY VARCHAR2);
--
-- Sitename
--   Returns the sitename from the SITENAME profile
--
FUNCTION sitename return VARCHAR2;


--
-- database_id
--   Public wrapper for fnd_web_config.database_id
--
FUNCTION database_id return VARCHAR2;

-- This routine is for AOL INTERNAL USE ONLY !!!!!!!
-- Specifically for AppsAdapterDatasource. No other code should call this api.
--
PROCEDURE fnd_encrypted_pwd_X(
  p_username IN VARCHAR2,
  p_server_id IN VARCHAR2,
  p_user_id IN OUT NOCOPY VARCHAR2,
  p_password IN OUT NOCOPY VARCHAR2,
  p_module IN VARCHAR2 default 'UNKNOWN',
  p_version IN VARCHAR2 default '',
  p_case_hash_userpwd IN VARCHAR2 default '',
  p_nocase_hash_userpwd IN VARCHAR2 default '');

END  fnd_security_pkg;

--
--

/

  GRANT EXECUTE ON "APPS"."FND_SECURITY_PKG" TO "APPLSYSPUB";
