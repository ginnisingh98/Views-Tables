--------------------------------------------------------
--  DDL for Package GMS_ENC_IMPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_ENC_IMPORT_PKG" AUTHID CURRENT_USER AS
-- $Header: gmsencis.pls 120.1 2005/07/26 14:21:51 appldev noship $
-----------------------------------------------------------------
  -- procedure pre_process   called in pa_transaction_import
  -- for transaction source starting with 'GMSE'
  --		P_TRANSACTION_SOURCE like 'GMSE%'
  --		P_BATCH     -- encumbrance batch
  --		P_XFACE_ID  -- internal id for  encumbrance batch
  --		P_USER_ID   -- user running the import process
----------------------------------------------------------------
  PROCEDURE PRE_PROCESS (P_TRANSACTION_SOURCE    IN  VARCHAR2,
                         P_BATCH                 IN  VARCHAR2,
                         P_XFACE_ID              IN  NUMBER,
                         P_USER_ID               IN  NUMBER);
END;

 

/
