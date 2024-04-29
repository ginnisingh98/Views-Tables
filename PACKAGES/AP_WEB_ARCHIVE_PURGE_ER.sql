--------------------------------------------------------
--  DDL for Package AP_WEB_ARCHIVE_PURGE_ER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_ARCHIVE_PURGE_ER" AUTHID CURRENT_USER AS
/* $Header: apwxprgs.pls 120.0.12010000.2 2009/08/10 10:20:14 rveliche noship $ */

TYPE	report_headers IS TABLE OF NUMBER;

PROCEDURE RunProgram(errbuf          		OUT NOCOPY VARCHAR2,
                     retcode         		OUT NOCOPY NUMBER,
                     p_org_id                   IN NUMBER DEFAULT NULL,
	             p_source_date		IN VARCHAR2,
		     p_purge_wf_attach_flag	IN VARCHAR2);

END AP_WEB_ARCHIVE_PURGE_ER;

/
