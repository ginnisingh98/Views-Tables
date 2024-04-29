--------------------------------------------------------
--  DDL for Package EDR_INDEXED_XML_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDR_INDEXED_XML_UTIL" AUTHID CURRENT_USER as
/*  $Header: EDRGIXES.pls 120.0.12000000.1 2007/01/18 05:53:34 appldev ship $ */

PROCEDURE create_index(ERRBUF OUT nocopy VARCHAR2, RETCODE OUT nocopy VARCHAR2);

-- bug 2979172 need new procedures to sync/optimize index
-- remove (p_IndexName	IN	VARCHAR2) in both before value set defined
PROCEDURE Synchronize_Index (
	ERRBUF		OUT 	NOCOPY VARCHAR2,
	RETCODE		OUT 	NOCOPY NUMBER	);

PROCEDURE Optimize_Index (
	ERRBUF		OUT 	NOCOPY VARCHAR2,
	RETCODE		OUT 	NOCOPY NUMBER,
	p_optimize_level IN  	VARCHAR2,
       	p_duration 	IN  	NUMBER     	);
-- bug 2979172 fix use these procedures in concurrent program

FUNCTION GET_WF_PARAMS(p_param_name IN VARCHAR2, p_event_guid IN RAW)
	RETURN VARCHAR2;

end EDR_INDEXED_XML_UTIL;

 

/
