--------------------------------------------------------
--  DDL for Package AP_CONC_PROG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_CONC_PROG_PKG" AUTHID CURRENT_USER AS
/* $Header: apcpreqs.pls 120.4 2004/10/27 01:30:22 pjena noship $ */

    PROCEDURE pay_batch_requests_finished(X_batch_name IN VARCHAR2,
					  X_calling_sequence IN VARCHAR2,
					  X_finished_flag OUT NOCOPY BOOLEAN);

    PROCEDURE requests_finished(X_program_name IN VARCHAR2,
			        X_application_name IN VARCHAR2,
			        X_calling_sequence IN VARCHAR2,
				X_finished_flag OUT NOCOPY BOOLEAN);

    PROCEDURE execution_method(X_program_name IN VARCHAR2,
			       X_calling_sequence IN VARCHAR2,
			       X_execution_method OUT NOCOPY VARCHAR2);

    PROCEDURE is_program_srs(X_program_name IN VARCHAR2,
			       X_calling_sequence IN VARCHAR2,
			       X_srs_flag OUT NOCOPY VARCHAR2);
END AP_CONC_PROG_PKG;

 

/
