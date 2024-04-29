--------------------------------------------------------
--  DDL for Package Body OTATRANS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTATRANS" as
/* $Header: otatrans.pkb 115.2 2002/11/26 12:24:53 dbatra ship $ */
--
--
Procedure gl_transfer (ERRBUF OUT nocopy VARCHAR2,
                       RETCODE OUT nocopy VARCHAR2) as
    p_user_id   NUMBER;
    p_login_id  NUMBER;
    l_completed BOOLEAN;
    failure     EXCEPTION;
--
  BEGIN
   p_user_id  := fnd_profile.value('USER_ID');
   p_login_id := fnd_profile.value('LOGIN_ID');
-- -----------------------------------------------------------------
--                   COST TRANSFER TO GL PACKAGE                   |
-- -----------------------------------------------------------------
--
   ota_cost_transfer_to_gl_pkg.otagls(p_user_id,
                                      p_login_id);
--
--   dbms_output.put_line ('created gl lines');
--
   exception
     when others then
--     dbms_output.put_line ('error during cost transfer');
     rollback;
--
 end gl_transfer;
--
end otatrans;

/
