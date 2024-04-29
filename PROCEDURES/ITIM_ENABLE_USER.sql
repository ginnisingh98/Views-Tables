--------------------------------------------------------
--  DDL for Procedure ITIM_ENABLE_USER
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "APPS"."ITIM_ENABLE_USER" (
  user_name in  varchar2,
  startdate in  date default NULL,
  enddate   in  date default fnd_user_pkg.null_date
)
AS
begin

     FND_USER_PKG.EnableUser (
          username   => user_name,
          start_date => startdate,
          end_date   => enddate);
end ITIM_ENABLE_USER;

/

  GRANT EXECUTE ON "APPS"."ITIM_ENABLE_USER" TO "NONAPPS";
