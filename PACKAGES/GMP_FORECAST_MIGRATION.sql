--------------------------------------------------------
--  DDL for Package GMP_FORECAST_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMP_FORECAST_MIGRATION" AUTHID CURRENT_USER AS
/* $Header: GMPFCMIS.pls 120.1 2005/07/19 07:14:03 rpatangy noship $ */

PROCEDURE Exec_forecast_Migration
(     P_migration_run_id   IN NUMBER,
      P_commit             IN VARCHAR2,
      X_failure_count      OUT NOCOPY NUMBER
);

END GMP_forecast_migration;

 

/
