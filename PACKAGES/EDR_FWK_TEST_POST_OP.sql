--------------------------------------------------------
--  DDL for Package EDR_FWK_TEST_POST_OP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDR_FWK_TEST_POST_OP" AUTHID CURRENT_USER AS
/* $Header: EDRFWTSS.pls 120.0.12000000.1 2007/01/18 05:53:15 appldev ship $

  /***********************************************************
   ** This Procedure is executed as Post Operation API      **
   ***********************************************************/
  PROCEDURE set_rec_status(P_FWK_TEST_ID NUMBER);

END EDR_FWK_TEST_POST_OP;

 

/
