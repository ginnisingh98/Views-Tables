--------------------------------------------------------
--  DDL for Procedure ITIM_DISABLE_USER
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "APPS"."ITIM_DISABLE_USER" (
  user_name          in    varchar2
)
AS
begin

     FND_USER_PKG.DisableUser (
          username => user_name);
end ITIM_DISABLE_USER;

/

  GRANT EXECUTE ON "APPS"."ITIM_DISABLE_USER" TO "NONAPPS";
