--------------------------------------------------------
--  DDL for Package Body PSP_ER_EXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_ER_EXT" AS
  /* $Header: PSPEREXB.pls 115.3 2002/04/17 19:20:49 pkm ship     $ */
   ----
   PROCEDURE upd_include_flag(a_template_id IN NUMBER)
   IS
   BEGIN
      NULL;
      ---  This procedure is a hook which will be called after a New Effort Report is created
      ---  using SUBMIT button and before it is submitted to Concurrent Manager.
   END;
END;

/
