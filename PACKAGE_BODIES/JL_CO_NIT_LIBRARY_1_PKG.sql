--------------------------------------------------------
--  DDL for Package Body JL_CO_NIT_LIBRARY_1_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_CO_NIT_LIBRARY_1_PKG" AS
/* $Header: jlconl1b.pls 115.2 99/08/03 20:07:45 porting ship $ */

FUNCTION nit_required (account VARCHAR2, sob_id NUMBER) return Varchar2 IS
  nit_reqd jl_co_gl_nit_accts.nit_required%TYPE;
BEGIN

  SELECT nit_required INTO nit_reqd
  FROM JL_CO_GL_NIT_ACCTS
  WHERE account_code = account and
        chart_of_accounts_id = (SELECT chart_of_accounts_id
                                FROM   gl_sets_of_books
                                WHERE  set_of_books_id = sob_id);
  RETURN NVL(nit_reqd,'N');
  Exception When Others THEN
             RETURN 'N';

END nit_required;

END jl_co_nit_library_1_pkg;

/
