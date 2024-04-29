--------------------------------------------------------
--  DDL for Package Body CSTRVHKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTRVHKS" AS
/* $Header: CSTRVHKB.pls 115.3 2002/11/11 22:44:42 awwang ship $ */

FUNCTION disable_accrual (
           ERR_NUM                      OUT NOCOPY     NUMBER,
           ERR_CODE                     OUT NOCOPY     VARCHAR2,
           ERR_MSG                      OUT NOCOPY     VARCHAR2)
RETURN integer
is
   stmt_num			NUMBER;
   BEGIN
      stmt_num := 0;
      /*
      0 - means do perpetual accruals
      1 - means disable perpetual accruals
      Default should be 0 - do perpetual accruals
      Change it to 1 only if you are very sure that
      you want to disable perpetual accruals
      */
      return(0);

   EXCEPTION
   WHEN OTHERS THEN
       err_num := SQLCODE;
       err_msg := 'CSTRVHKS:disable_accrual' || to_char(stmt_num) || substr(SQLERRM,1,150);
   return(-999);
   END disable_accrual;

END CSTRVHKS;

/
