--------------------------------------------------------
--  DDL for Package FND_ORACLE_USER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_ORACLE_USER_PKG" AUTHID CURRENT_USER as
/* $Header: AFSCOUSS.pls 120.1 2005/07/02 03:08:54 appldev ship $ */

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
  x_read_only_flag		        in	VARCHAR2);

--
-- GetReEncryptedPassword (PUBLIC)
--   Return oracle user password encrypted with new key. This just returns the
--   newly encrypted password. It does not set the password in
--   FND_ORACLE_USERID table.
--
-- Usage example in pl/sql
--   declare
--     newpass varchar2(100);
--   begin
--     newpass := fnd_oracle_user_pkg.getreencryptedpassword('SCOTT', 'NEWKEY');
--   end;
--
-- Input (Mandatory)
--   username:  User Name
--   newkey     New Key
--
function GetReEncryptedPassword(username varchar2,
                                newkey   varchar2) return varchar2;

-- Overloaded!!

procedure LOAD_ROW (
  x_oracle_username			in	VARCHAR2,
  x_owner                           	in	VARCHAR2,
  x_encrypted_oracle_password	 	in	VARCHAR2,
  x_description			        in	VARCHAR2,
  x_enabled_flag		        in	VARCHAR2,
  x_read_only_flag		        in	VARCHAR2,
  x_custom_mode				in	VARCHAR2,
  x_last_update_date			in	VARCHAR2);

end FND_ORACLE_USER_PKG;

 

/
