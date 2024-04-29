--------------------------------------------------------
--  DDL for Package ASO_PURGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_PURGE_PVT" AUTHID CURRENT_USER AS
/* $Header: asopurges.pls 120.0.12010000.6 2015/02/05 21:49:35 vidsrini noship $ */
-- Start of Comments
-- Start of Comments
-- Package name     : ASO_PURGE_PVT
-- Purpose          :
-- This is a new API to purge ASO tables based on the parameters from the Asopurge CCP.

    PROCEDURE  PURGE_ASO_QUOTE_DETAILS
(      errbuf				 OUT NOCOPY  /* file.sql.39 change */  VARCHAR2,
       retcode				 OUT NOCOPY  /* file.sql.39 change */  Number,
       p_review_candidate_quotes IN  VARCHAR2,
	   p_dummy                   IN VARCHAR2,
       p_operating_unit IN NUMBER,
       p_quote_expiration_days IN  NUMBER,
	  p_last_update_days IN  NUMBER,
	  p_istore_cart IN  VARCHAR2
 );
  END ;

/
