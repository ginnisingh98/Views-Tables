--------------------------------------------------------
--  DDL for Package ICX_POR_POPULATE_DESC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_POR_POPULATE_DESC" AUTHID CURRENT_USER AS
/* $Header: ICXPLCDS.pls 115.4 2004/03/31 21:43:20 vkartik ship $*/

PROCEDURE populateCtxDescAll(p_jobno IN INTEGER := 0,
			     p_rebuildAll IN VARCHAR2 := 'N') ;
PROCEDURE populateCtxDescAll(p_jobno IN INTEGER := 0,
                             p_rebuildAll IN VARCHAR2 := 'N',
                             p_loglevel IN NUMBER,
			     p_logfile IN VARCHAR2) ;
PROCEDURE populateCtxDescAll(p_jobno IN INTEGER := 0,
                             p_rebuildAll IN VARCHAR2 := 'Y',
			     p_logfile IN VARCHAR2) ;
PROCEDURE populateDescAll(p_jobno IN INTEGER := 0) ;
PROCEDURE rebuildAll;
PROCEDURE rebuild_indexes;

END ICX_POR_POPULATE_DESC;

 

/
