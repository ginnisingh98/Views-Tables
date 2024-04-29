--------------------------------------------------------
--  DDL for Package Body FND_FLEX_DATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_FLEX_DATE" AS
  /* $Header: AFFFDTEB.pls 115.0 99/07/16 23:17:53 porting ship $ */


  /* ---------------------------------------------------------------------- */
  /* Convert date format.                                                   */
  /* ---------------------------------------------------------------------- */
  FUNCTION convert_format(in_date  IN  VARCHAR2,
                          in_mask  IN  VARCHAR2,
                          out_date IN OUT VARCHAR2,
                          out_mask IN  VARCHAR2) RETURN BOOLEAN
  IS
  err_num NUMBER;
  err_msg VARCHAR2(240);
  BEGIN
    out_date := TO_CHAR(TO_DATE(in_date, in_mask), out_mask);
    RETURN (TRUE);
  EXCEPTION
    WHEN OTHERS THEN
      err_num := SQLCODE;
      err_msg := SUBSTR(SQLERRM, 1, 240);
      FND_MESSAGE.set_name('FND', 'SQL_PLSQL_ERROR');
      FND_MESSAGE.set_token('ERRNO', TO_CHAR(err_num));
      FND_MESSAGE.set_token('REASON', err_msg);
      FND_MESSAGE.set_token('ROUTINE', 'FND_FLEX_DATE.CONVERT_FORMAT');
      RETURN (FALSE);
  END convert_format;

END FND_FLEX_DATE;

/
