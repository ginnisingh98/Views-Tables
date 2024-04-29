--------------------------------------------------------
--  DDL for Package Body GL_SHARES_ACTIVITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_SHARES_ACTIVITY_PKG" AS
/* $Header: glistacb.pls 120.3 2005/05/05 01:21:45 kvora ship $ */
--
-- PRIVATE FUNCTIONS
--

-- None

--
-- PUBLIC FUNCTIONS
--

  PROCEDURE check_unique( X_rowid              VARCHAR2,
                          X_ledger_id          NUMBER,
                          X_activity_date      DATE,
                          X_activity_type_code VARCHAR2) IS

  dummy NUMBER;

  BEGIN
    SELECT 1
    INTO   dummy
    FROM   dual
    WHERE NOT EXISTS
    (SELECT 1
     FROM  GL_SHARES_ACTIVITY
     WHERE  ledger_id          = X_ledger_id
     AND    activity_date      = X_activity_date
     AND    activity_type_code = X_activity_type_code
     AND    ((X_rowid is null) OR (rowid <> X_rowid)));

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_SHARES_ACTIVITY_UNIQUE');
      app_exception.raise_exception;
   END check_unique;

END GL_SHARES_ACTIVITY_PKG;

/
