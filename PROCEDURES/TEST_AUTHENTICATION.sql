--------------------------------------------------------
--  DDL for Procedure TEST_AUTHENTICATION
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "APPS"."TEST_AUTHENTICATION" AUTHID CURRENT_USER as
begin
htp.bodyOpen();
htp.htmlOpen();
htp.bodyClose();
htp.p('Does authentication work?');
htp.p(fnd_web_sec.validate_login('SYSADMIN','SYSADMIN'));
htp.htmlClose();
END test_authentication;

 

/
