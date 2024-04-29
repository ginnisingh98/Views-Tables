--------------------------------------------------------
--  DDL for Package FV_FLATFILES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_FLATFILES" AUTHID CURRENT_USER AS
--  $Header: FVFILCRS.pls 120.4 2004/03/25 22:29:40 rgera ship $
PROCEDURE main (errbuf     OUT NOCOPY VARCHAR2,
		retcode    OUT NOCOPY VARCHAR2,
                conc_prog  IN VARCHAR2,
		parameter1 IN NUMBER DEFAULT 0,
		parameter2 IN NUMBER DEFAULT 0,
		parameter3 IN VARCHAR2 DEFAULT NULL,
		parameter4 IN VARCHAR2 DEFAULT NULL,
		parameter5 IN VARCHAR2 DEFAULT NULL,
		parameter6 IN VARCHAR2 DEFAULT NULL,
		parameter7 IN VARCHAR2 DEFAULT NULL);

PROCEDURE create_flat_file(v_statement VARCHAR2);
END;

 

/
