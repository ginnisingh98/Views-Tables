--------------------------------------------------------
--  DDL for Package AML_PURGE_SALES_LEADS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AML_PURGE_SALES_LEADS" AUTHID CURRENT_USER AS
/* $Header: amlslprgs.pls 115.3 2004/02/09 12:13:20 bmuthukr noship $ */
-- Start of Comments
-- Package name     : AML_PURGE_UNQUALIFIED_LEADS
-- Purpose          : Sales Leads Management
-- NOTE             :
-- History          :
--      10/17/2003   BMUTHUKR   Created
--
-- END of Comments

TYPE  Sales_Lead_Id_Tab IS TABLE OF AS_SALES_LEADS.SALES_LEAD_ID%TYPE  INDEX BY binary_integer;

PROCEDURE Purge_Unqualified_Leads(
    errbuf             OUT NOCOPY VARCHAR2,
    retcode            OUT NOCOPY VARCHAR2,
    p_start_date       IN  VARCHAR2,
    p_end_date         IN  VARCHAR2,
    p_debug_mode       IN  VARCHAR2 DEFAULT 'N',
    p_trace_mode       IN  VARCHAR2 DEFAULT 'N');

END AML_PURGE_SALES_LEADS;

 

/
