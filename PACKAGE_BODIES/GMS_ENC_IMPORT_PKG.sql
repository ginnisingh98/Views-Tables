--------------------------------------------------------
--  DDL for Package Body GMS_ENC_IMPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_ENC_IMPORT_PKG" AS
-- $Header: gmsencib.pls 120.0 2005/05/29 12:02:14 appldev noship $

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
                         P_USER_ID               IN  NUMBER ) IS
BEGIN

   pa_cc_utils.log_message('GMS_ENC_IMPORT_PKG.PRE_PROCESS : Start - Before calling GMS_LD_PKG.PRE_PROCESS ',1);

   GMS_LD_PKG.PRE_PROCESS (P_TRANSACTION_SOURCE  ,
                           P_BATCH               ,
                           P_XFACE_ID            ,
                           P_USER_ID              );

   pa_cc_utils.log_message('GMS_ENC_IMPORT_PKG.PRE_PROCESS : End - after calling GMS_LD_PKG.PRE_PROCESS  ',1);

EXCEPTION
  WHEN OTHERS THEN
      pa_cc_utils.log_message('Unexpected error: '||SQLERRM,1);
      rollback ;
      raise_application_error(SQLCODE, SQLERRM) ;
END;
END GMS_ENC_IMPORT_PKG;

/
