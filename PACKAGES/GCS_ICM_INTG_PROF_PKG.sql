--------------------------------------------------------
--  DDL for Package GCS_ICM_INTG_PROF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_ICM_INTG_PROF_PKG" AUTHID CURRENT_USER AS
/* $Header: gcsicmps.pls 120.0 2005/09/30 23:13:06 mikeward noship $ */

  PROCEDURE set_profile_option_values
            (x_errbuf    OUT NOCOPY VARCHAR2,
             x_retcode   OUT NOCOPY VARCHAR2);

  PROCEDURE launch_key_account_import;

  PROCEDURE launch_fin_stmt_import;

END GCS_ICM_INTG_PROF_PKG;

 

/
