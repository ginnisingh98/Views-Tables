--------------------------------------------------------
--  DDL for Package CE_AUTO_BANK_UNREC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CE_AUTO_BANK_UNREC" AUTHID CURRENT_USER AS
/* $Header: ceaurecs.pls 120.1 2002/11/12 21:24:58 bhchung ship $ */

--
-- Global variables
--
G_spec_revision         VARCHAR2(1000) := '$Revision: 120.1 $';

FUNCTION body_revision RETURN VARCHAR2;

FUNCTION spec_revision RETURN VARCHAR2;

PROCEDURE unreconcile_all(errbuf                  OUT NOCOPY 	VARCHAR2,
                          retcode                 OUT NOCOPY 	NUMBER,
			  X_bank_account_id 	  IN	NUMBER,
			  X_statement_number	  IN	VARCHAR2,
			  X_statement_line_id	  IN	NUMBER,
			  X_display_debug         IN 	VARCHAR2,
                          X_debug_path            IN 	VARCHAR2,
                          X_debug_file            IN 	VARCHAR2);
END CE_AUTO_BANK_UNREC;

 

/
