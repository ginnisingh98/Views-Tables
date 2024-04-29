--------------------------------------------------------
--  DDL for Procedure ITIM_DEL_RESP
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "APPS"."ITIM_DEL_RESP" (
  x_user_name      in  varchar2,
  x_resp_app       in  varchar2,
  x_resp_key       in  varchar2,
  x_security_group in  varchar2
)
AS
begin

     FND_USER_PKG.DelResp (
          username       => x_user_name,
          resp_app       => x_resp_app,
          resp_key       => x_resp_key,
          security_group => x_security_group);
end ITIM_DEL_RESP;

/

  GRANT EXECUTE ON "APPS"."ITIM_DEL_RESP" TO "NONAPPS";
