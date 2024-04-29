--------------------------------------------------------
--  DDL for Package IPA_CLIENT_EXTN_TRX_SRC_PROC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IPA_CLIENT_EXTN_TRX_SRC_PROC" AUTHID CURRENT_USER AS
/* $Header: IPACLPRS.pls 120.0 2005/05/31 16:27:56 appldev noship $ */

/*=============================================================================
 Name          : PRE_PROCESS_EXTN
 Type          : PUBLIC
 Pre-Reqs      : None
 Type          : Procedure
 Function      : This procedure is an extension provided for Pre-Processing
                 extension for 'Capitalized Interest' transaction Source.
 Parameters    :
 IN
           P_Transaction_source: Unique identifier for source of the txn
           P_batch: Batch Name to group txns into batches
           P_xface_id: Interface Id
           P_user_id: User Id
==============================================================================*/
PROCEDURE PRE_PROCESS_EXTN(
                P_transaction_source IN VARCHAR2,
                P_batch              IN VARCHAR2,
                P_xface_id           IN NUMBER,
                P_user_id            IN NUMBER);

/*=============================================================================
 Name          : POST_PROCESS_EXTN
 Type          : PUBLIC
 Pre-Reqs      : None
 Type          : Procedure
 Function      : This procedure is an extension provided for Post-Processing
                 extension for 'Capitalized Interest' transaction Source.
 Parameters    :
 IN
           P_Transaction_source: Unique identifier for source of the txn
           P_batch: Batch Name to group txns into batches
           P_xface_id: Interface Id
           P_user_id: User Id
==============================================================================*/
PROCEDURE POST_PROCESS_EXTN(
                P_transaction_source IN VARCHAR2,
                P_batch              IN VARCHAR2,
                P_xface_id           IN NUMBER,
                P_user_id            IN NUMBER);


END IPA_CLIENT_EXTN_TRX_SRC_PROC;
 

/
