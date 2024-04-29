--------------------------------------------------------
--  DDL for Package ARCM_EXTRACT_XML_CF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARCM_EXTRACT_XML_CF" AUTHID CURRENT_USER AS
/* $Header: ARCMXTCFS.pls 120.1 2005/12/05 09:29:25 kjoshi noship $ */
PROCEDURE EXTRACT (
                  ERRBUF	           IN OUT NOCOPY VARCHAR2,
                  RETCODE	           IN OUT NOCOPY VARCHAR2,
                  P_CASE_FOLDER_ID	   IN		 NUMBER);

END ARCM_EXTRACT_XML_CF;

 

/
