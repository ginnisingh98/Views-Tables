--------------------------------------------------------
--  DDL for Package CSP_EXCESS_PARTS_CUST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_EXCESS_PARTS_CUST" AUTHID CURRENT_USER AS
/* $Header: cspexccusts.pls 120.0.12010000.1 2009/05/14 13:08:13 htank noship $ */


-- Start of Comments
-- Package name     : CSP_EXCESS_PARTS_CUST
-- Purpose          : Custom code to override return information
-- History          :
-- NOTE             :
-- End of Comments

FUNCTION excess_parts (
   p_excess_part  IN CSP_EXCESS_LISTS_PKG.EXCESS_RECORD_TYPE
) RETURN CSP_EXCESS_LISTS_PKG.EXCESS_TBL_TYPE;

End CSP_EXCESS_PARTS_CUST;

/
