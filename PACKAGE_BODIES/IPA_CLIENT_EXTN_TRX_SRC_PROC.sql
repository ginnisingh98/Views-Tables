--------------------------------------------------------
--  DDL for Package Body IPA_CLIENT_EXTN_TRX_SRC_PROC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IPA_CLIENT_EXTN_TRX_SRC_PROC" AS
/* $Header: IPACLPRB.pls 120.0 2005/05/29 13:16:32 appldev noship $ */

/*========================================================================*/
/*                PRE-PROCESS EXTENSION                                   */
/*========================================================================*/
/* Pre-Process Extension for Transaction Source - 'Capitalized Interest'  */
PROCEDURE PRE_PROCESS_EXTN(
                P_transaction_source IN VARCHAR2,
                P_batch              IN VARCHAR2,
                P_xface_id           IN NUMBER,
                P_user_id            IN NUMBER) IS

/* Declare here any local Variables that might need to be used
   for this Pre-Processing Extension */
/* Begin Declaring Variables */




/* End Declaring Variables */

BEGIN

/* The eligible records for Post-Processing are those whose
   transaction_status_code is 'P'. After Processing, mark the
   transaction_status_code as 'P' for Success and 'PR' for Rejection.
   This needs to be strictly adhered to inorder to view the
   Transactions in Review transactions accordingly. */

/* Include Cusotmised code for Pre-Processing Extension */

/* Begin Customised Code */
/* If Customised Code is included here,
   comment the next line containing NULL; */
   NULL;






/* End Customised Code */

EXCEPTION
     WHEN OTHERS THEN
        RAISE;

END PRE_PROCESS_EXTN;

/*========================================================================*/
/*                POST-PROCESS EXTENSION                                  */
/*========================================================================*/
/* Post-Process Extension for Transaction Source - 'Capitalized Interest' */
PROCEDURE POST_PROCESS_EXTN(
                P_transaction_source IN VARCHAR2,
                P_batch              IN VARCHAR2,
                P_xface_id           IN NUMBER,
                P_user_id            IN NUMBER) IS

/* Declare here any local Variables that might need to be used
   for this Post-Processing Extension  */
/* Begin Declaring Variables */




/* End Declaring Variables */

BEGIN

/* The eligible records for Post-Processing are those whose
   transaction_status_code is 'I'. After Processing, mark the
   transaction_status_code as 'A' for Success and 'PO' for Rejection.
   This needs to be strictly adhered to inorder to view the
   Transactions in Review transactions accordingly. */

/* Include Cusotmised code for Post-Processing Extension */

/* Begin Customised Code */
/* If Customised Code is included here,
   comment the next line containing NULL; */
   NULL;






/* End Customised Code */

EXCEPTION
     WHEN OTHERS THEN
        RAISE;

END POST_PROCESS_EXTN;

END IPA_CLIENT_EXTN_TRX_SRC_PROC;

/
