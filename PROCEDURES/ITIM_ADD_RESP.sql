--------------------------------------------------------
--  DDL for Procedure ITIM_ADD_RESP
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "APPS"."ITIM_ADD_RESP" (
  x_user_name      in  varchar2,
  x_resp_app       in  varchar2,
  x_resp_key       in  varchar2,
  x_security_group in  varchar2,
  x_description    in  varchar2,
  x_start_date     in  date,
  x_end_date       in  date
)
AS
begin

     FND_USER_PKG.AddResp (
          username       => x_user_name,
          resp_app       => x_resp_app,
          resp_key       => x_resp_key,
          security_group => x_security_group,
          description    => x_description,
          start_date     => x_start_date,
          end_date       => x_end_date);
end ITIM_ADD_RESP;

/

  GRANT EXECUTE ON "APPS"."ITIM_ADD_RESP" TO "NONAPPS";
