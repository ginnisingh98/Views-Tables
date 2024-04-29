--------------------------------------------------------
--  DDL for Procedure ITIM_RENAME_USER
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "APPS"."ITIM_RENAME_USER" (
  old_user_name                  in  varchar2,
  new_user_name                  in  varchar2
)
AS
begin

     FND_USER_PKG.change_user_name (
          x_old_user_name              => old_user_name,
          x_new_user_name              => new_user_name);
end ITIM_RENAME_USER;

/

  GRANT EXECUTE ON "APPS"."ITIM_RENAME_USER" TO "NONAPPS";
