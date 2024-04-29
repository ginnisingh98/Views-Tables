--------------------------------------------------------
--  DDL for Package GMS_LD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_LD_PKG" AUTHID CURRENT_USER AS
-- $Header: gmsenxfs.pls 120.2 2005/09/02 02:50:52 appldev ship $
-----------------------------------------------------------------
  -- procedure pre_process   called in pa_transaction_import
  -- for transaction source of 'GOLDE'
  --		P_TRANSACTION_SOURCE = 'GOLDE' -- pre-defined
  --		P_BATCH     -- encumbrance batch
  --		P_XFACE_ID  -- internal id for  encumbrance batch
  --		P_USER_ID   -- user running the import process
----------------------------------------------------------------
  PROCEDURE PRE_PROCESS (P_TRANSACTION_SOURCE    IN  VARCHAR2,
                        P_BATCH                 IN  VARCHAR2,
                        P_XFACE_ID              IN  NUMBER,
                        P_USER_ID               IN  NUMBER);

  /* Added this procedure for the Bug# 4138033 */
  PROCEDURE Validate_Dates_YN
             ( l_award_id1           IN gms_awards_all.award_id%TYPE,
	       l_project_id1         IN pa_projects_all.project_id%TYPE,
	       l_task_id1            IN pa_tasks.task_id%TYPE,
	       l_orig_enc_item_id1   IN gms_encumbrance_items_all.encumbrance_item_id%TYPE);

END;

 

/
