--------------------------------------------------------
--  DDL for Package FND_EID_ATTH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_EID_ATTH_PKG" AUTHID CURRENT_USER AS
-- $Header: fndeidatths.pls 120.0.12010000.2 2012/07/17 07:20:17 rnagaraj noship $

/* This functions creates oracle text based preference and policy to filter binary
   documents stored in FND_LOBS table.
   Author :Ranjan Tripathy
   Created : 15th May 2012 */

FUNCTION return_text(p_id NUMBER,p_html NUMBER DEFAULT 1)
        RETURN CLOB;

END FND_EID_ATTH_PKG;

/
