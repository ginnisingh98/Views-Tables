--------------------------------------------------------
--  DDL for Package FND_AUDIT_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_AUDIT_REPORT" AUTHID CURRENT_USER as
/* $Header: AFATRPTS.pls 120.2 2005/10/25 14:26:28 jwsmith noship $ */

--
-- Procedure
--   PRINT_OUTPUT
--
-- Purpose
--   Print to a concurrent manager log file or to dbms_output
--
-- Arguments:
--        IN:
--           LOG - send to cm log file if 'Y' and dbms_output if 'N'
--           DATA - string to print
--           PROGNM  - name of this program, written to logfile for tagging
--           LOG  - send to cm log file if 'Y' and dbms_output if 'N'
--       OUT:
--           ERRBUF  - standard CP output
--           RETCODE - 0 if successful
--
procedure print_output( LOG IN VARCHAR2 DEFAULT 'Y',
                        DATA IN VARCHAR2 DEFAULT null);


--
-- Procedure
--   AUDIT_GROUP_VALIDATION
--
-- Purpose
--   PL/SQL stored procedure concurrent program which creates
--   an exception report for audit schema validation.
--
-- Arguments:
--        IN:
--           GROUP_NAME - name of the audit group
--           PROGNM  - name of this program, written to logfile for tagging
--           LOG  - send to cm log file if 'Y' and dbms_output if 'N'
--       OUT:
--           ERRBUF  - standard CP output
--           RETCODE - 0 if successful
--
procedure audit_group_validation(ERRBUF OUT NOCOPY VARCHAR2,
		                 RETCODE OUT NOCOPY NUMBER,
	    	                 GROUP_NAME IN VARCHAR2 DEFAULT null,
		                 PROGNM  IN VARCHAR2 DEFAULT null,
                                 LOG IN VARCHAR2 DEFAULT 'Y');


end;

 

/
