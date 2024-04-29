--------------------------------------------------------
--  DDL for Package Body GL_SHARES_OUTSTANDING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_SHARES_OUTSTANDING_PKG" AS
/* $Header: glistoub.pls 120.3 2005/05/05 01:23:37 kvora ship $ */
--
-- PRIVATE FUNCTIONS
--

-- None

--
-- PUBLIC FUNCTIONS
--

  PROCEDURE check_unique( X_rowid              VARCHAR2,
                          X_ledger_id    NUMBER,
                          X_fiscal_year        NUMBER,
                          X_share_measure_code VARCHAR2,
                          X_measure_type_code  VARCHAR2) IS

  dummy NUMBER;

  BEGIN
    SELECT 1
    INTO   dummy
    FROM   dual
    WHERE NOT EXISTS
    (SELECT 1
     FROM  GL_SHARES_OUTSTANDING
     WHERE  ledger_id    = X_ledger_id
     AND    fiscal_year        = X_fiscal_year
     AND    share_measure_code = X_share_measure_code
     AND    measure_type_code  = X_measure_type_code
     AND    ((X_rowid is null) OR (rowid <> X_rowid)));

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_SHARES_OUTSTANDING_UNIQUE');
      app_exception.raise_exception;
   END check_unique;

END GL_SHARES_OUTSTANDING_PKG;

/
