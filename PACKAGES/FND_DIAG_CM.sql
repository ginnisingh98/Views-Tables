--------------------------------------------------------
--  DDL for Package FND_DIAG_CM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_DIAG_CM" AUTHID CURRENT_USER as
/* $Header: AFCPDCMS.pls 120.2 2005/08/19 18:45:50 tkamiya noship $ */

--
-- Procedure
--   DIAG_SQL_PROG
--
-- Purpose
--   Simple PL/SQL stored procedure concurrent program. Will sleep and exit.
--
-- Arguments:
--        IN:
--           SLEEPT  - number of seconds to sleep (default is 20)
--           PROGNM  - name of this program, written to logfile for tagging
--       OUT:
--           ERRBUF  - standard CP output
--           RETCODE - 0 if successful
--
procedure diag_sql_prog(ERRBUF OUT NOCOPY VARCHAR2,
		        RETCODE OUT NOCOPY NUMBER,
	    	        SLEEPT  IN NUMBER default 20,
		        PROGNM  IN VARCHAR2 default null);

--
-- Procedure
--   DIAG_CRM
--
-- Purpose
--   Test Conflict Resolution Manager. Will submit multiple incompatible
--   requests for various conflict domains to determine if any incompatible
--   programs are being incorrectly released to run.
--
-- Arguments:
--        IN:
--           VOLREQ  - number of requests to submit (default is 100)
--           NUMDOM  - number of different domains to use (default is 10)
--       OUT:
--           ERRBUF  - standard CP output
--           RETCODE - 0 if successful, 1 if CRM has been found to have error
--
procedure diag_crm(ERRBUF OUT NOCOPY VARCHAR2,
		   RETCODE OUT NOCOPY NUMBER,
	    	   VOLREQ  IN NUMBER default 100,
		   NUMDOM  IN NUMBER default 10);
end;

 

/
