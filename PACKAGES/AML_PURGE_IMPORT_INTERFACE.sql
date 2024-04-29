--------------------------------------------------------
--  DDL for Package AML_PURGE_IMPORT_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AML_PURGE_IMPORT_INTERFACE" AUTHID CURRENT_USER as
/* $Header: amlsprgs.pls 115.3 2004/02/09 12:14:35 bmuthukr noship $ */
-- Start of Comments
-- Package name     : AML_PURGE_IMPORT_INTERFACE
-- Purpose          : Sales Leads Management
-- NOTE             :
-- History          :
--   08/19/2003   BMUTHUKR Created
--   14/11/2003   BMUTHUKR   Modified. Now using bulk delete to improve the performance.
-- End of Comments

TYPE  Import_Interface_Id_Tab IS TABLE OF AS_IMPORT_INTERFACE.IMPORT_INTERFACE_ID%TYPE  INDEX BY binary_integer;

-- *************************
--   Validation Procedures
-- *************************

-- Procedures
PROCEDURE PURGE_IMPORT_INTERFACE(
    ERRBUF         OUT  NOCOPY VARCHAR2,
    RETCODE        OUT  NOCOPY VARCHAR2,
    P_START_DATE   IN   VARCHAR2,
    P_END_DATE     IN   VARCHAR2,
    P_STATUS       IN   VARCHAR2,
    P_DEBUG_MODE   IN   VARCHAR2 DEFAULT 'N',
    P_TRACE_MODE   IN   VARCHAR2 DEFAULT 'N'
    );

End AML_PURGE_IMPORT_INTERFACE;

 

/
