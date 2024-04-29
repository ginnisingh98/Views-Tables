--------------------------------------------------------
--  DDL for Package Body PA_TRANSACTION_SOURCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_TRANSACTION_SOURCES_PKG" AS
/* $Header: PAXTIXSB.pls 120.2 2005/08/03 13:58:37 aaggarwa noship $ */

--  =====================================================================
--  This procedure performs a referential integrity check for

  PROCEDURE check_references(  X_trx_source  IN      VARCHAR2
                             , status        IN OUT NOCOPY  NUMBER
                             , outcome	     IN OUT NOCOPY  VARCHAR2 ) IS
	dummy	NUMBER;

  BEGIN
    outcome := NULL;         -- initialize
    status  := 0;

    SELECT  count(1)
      INTO  dummy
      FROM  dual
     WHERE EXISTS
            ( SELECT  1
                FROM  pa_transaction_xface_control txc
               WHERE  txc.transaction_source = X_trx_source )
        OR EXISTS
            ( SELECT  1
                FROM  pa_expenditure_items_all ei
               WHERE  ei.transaction_source = X_trx_source );

    IF ( dummy = 1 ) THEN
      outcome := 'PA_TR_TRX_SRC_IN_USE';
      status  := 1;
    END IF;

  EXCEPTION
    WHEN  OTHERS THEN
      status := SQLCODE;

  END check_references;


--  =====================================================================
--  This procedure checks if the
--  exists, and if so, returns an error message.

  PROCEDURE check_unique(  X_trx_source       IN      VARCHAR2
			 , X_user_trx_source  IN      VARCHAR2
			 , X_rowid            IN      VARCHAR2
                         , status             IN OUT NOCOPY  NUMBER
			 , outcome            IN OUT NOCOPY  VARCHAR2 ) IS
    dummy   	NUMBER;

  BEGIN
    outcome := NULL;
    status  := 0;

    SELECT 1
      INTO dummy
      FROM dual
     WHERE NOT EXISTS
            ( SELECT 1
                FROM pa_transaction_sources
               WHERE ( transaction_source = nvl(X_trx_source, -99)
                       OR user_transaction_source = X_user_trx_source)
                 AND  (   ( X_rowid IS NULL )
                       OR ( rowid <> X_rowid ) ) );

  EXCEPTION
    WHEN  NO_DATA_FOUND  THEN
      status  := 1;
      outcome := 'PA_SU_NAME_ALREADY_EXISTS';
    WHEN  OTHERS  THEN
      status  := SQLCODE;

  END check_unique;

END PA_TRANSACTION_SOURCES_PKG;

/
