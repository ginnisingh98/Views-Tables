--------------------------------------------------------
--  DDL for Package Body EDR_FWK_TEST_POST_OP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDR_FWK_TEST_POST_OP" AS
/* $Header: EDRFWTSB.pls 120.0.12000000.1 2007/01/18 05:53:13 appldev ship $

  /***********************************************************
   ** This Procedure is executed as Post Operation API      **
   ***********************************************************/
  PROCEDURE set_rec_status(P_FWK_TEST_ID NUMBER) IS
  BEGIN
        UPDATE EDR_FWK_TEST_B
        SET STATUS =  decode(EDR_STANDARD_PUB.G_SIGNATURE_STATUS,'SUCCESS','COMPLETE',EDR_PSIG_PAGE_FLOW.SIGNATURE_STATUS)
        WHERE FWK_TEST_ID = P_FWK_TEST_ID;
  END;

END EDR_FWK_TEST_POST_OP;

/
