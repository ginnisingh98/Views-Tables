--------------------------------------------------------
--  DDL for Package IBY_BANKACCXFR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_BANKACCXFR_PUB" AUTHID CURRENT_USER AS
/*$Header: ibybareqs.pls 120.2 2005/09/15 01:30:23 rameshsh noship $ */

-------------------------------------------------------------------------
	--**Defining all DataStructures required by the APIs**--
--  The following input and output PL/SQL record/table types are defined
-- to store the objects (entities) necessary for the EC-App PL/SQL APIs.
-------------------------------------------------------------------------

--INPUT DataStructures


TYPE BankAccXfrReq_Rec_Type IS RECORD (
	  PmtInstrType    VARCHAR2(80),
          Org_ID          NUMBER,
	  EcappId         VARCHAR2(80),
	  ECBatch_ID      VARCHAR2(80),
	  Payee_Instr_ID  VARCHAR2(80),
          NLS_LANG        VARCHAR2(80)
        );

TYPE BankAccXfrTrxnReq_Rec_Type IS RECORD (
	  Payer_Instr_ID  VARCHAR2(80),
	  Payer_Name      VARCHAR2(80),
   	  PmtInstrSubType VARCHAR2(80),
	  Tangible_ID     VARCHAR2(80),
          Tangible_Amount NUMBER,
          Currency_Code   VARCHAR2(80),
          RefInfo         VARCHAR2(80),
	  Memo            VARCHAR2(80),
          Settlement_Date DATE,
	  IssueDate       DATE,
          NLS_LANG        VARCHAR2(80),
          OrderMedium     VARCHAR2(30),
          EFTAuthMethod   VARCHAR2(30),
          customerRef     VARCHAR2(240)
        );

TYPE BankAccXfrTrxn_Tbl_Type IS TABLE of BankAccXfrTrxnReq_Rec_Type INDEX BY BINARY_INTEGER;

-- OUPUT DataStructures

TYPE BankAccXfrResp_Rec_Type IS RECORD (
          Batch_ID        VARCHAR2(80),
	  BatchStatus     VARCHAR2(80),
	  ErrorCode       VARCHAR2(80),
	  ErrorMsg        VARCHAR2(80)
        );

TYPE BankAccXfrRespDet_Rec_Type IS RECORD (
          TrxnId          VARCHAR2(80),
          TangibleID      VARCHAR2(80),
	  TrxnStatus      VARCHAR2(80),
	  TrxnRef         VARCHAR2(80),
	  ErrorCode       VARCHAR2(80),
	  ErrorMsg        VARCHAR2(80)
        );

TYPE BankAccXfrRespDet_Tbl_Type IS TABLE of BankAccXfrRespDet_Rec_Type INDEX BY BINARY_INTEGER;


---------------------------------------------------------------
                      -- API Signatures--
---------------------------------------------------------------

/* ============================================================================
   --1. OraPmtBankPayBatchReq
   --   -----------------------
   --   Start of comments
   --      API name  : OraPmtBatchReq
   --      Type      : Public
   --      Pre-reqs  : None
   --      Function  : Handles Batch Payment requests from Accounts Receivables
   --      Parameters:
   --      IN        : p_api_version        IN  NUMBER,
   --                  p_init_msg_list      IN  VARCHAR2,
   --                  p_commit             IN  VARCHAR2,
   --                  p_validation_level   IN  NUMBER,
   --                  p_payee_id           IN  VARCHAR2,
   --                  p_ecapp_id           IN  NUMBER,
   --		       x_return_status      OUT VARCHAR2,
   --                  x_msg_count          OUT NUMBER,
   -- 	               x_msg_data           OUT VARCHAR2,
   --                  p_pmt_batch_req_rec  IN  BankAccXfrReq_Rec_Type,
   --                  p_pmt_batch_trxn_tbl IN  BankAccXfrTrxn_Tbl_Type,
   --                  x_batch_resp_rec     OUT NOCOPY BankAccXfrResp_Rec_Type,
   --                  x_batch_respdet_tbl  OUT NOCOPY BankAccXfrRespDet_Tbl_Type
   --   Version :
   --   Current version      1.0
   --   Previous version     1.0
   --   Initial version      1.0
   --   End of comments
 ============================================================================ */

PROCEDURE OraPmtBatchReq(
         p_api_version        IN    NUMBER,
         p_init_msg_list      IN    VARCHAR2  DEFAULT FND_API.G_FALSE,
         p_commit             IN    VARCHAR2  DEFAULT FND_API.G_FALSE,
         p_validation_level   IN    NUMBER  DEFAULT FND_API.G_VALID_LEVEL_FULL,
	   p_payee_id           In    VARCHAR2,
         p_ecapp_id           IN    NUMBER,
         x_return_status      OUT   NOCOPY VARCHAR2,
         x_msg_count          OUT   NOCOPY NUMBER,
         x_msg_data           OUT   NOCOPY VARCHAR2,
         p_batch_req_rec      IN    BankAccXfrReq_Rec_Type,
         p_accxfr_trxn_tbl    IN    BankAccXfrTrxn_Tbl_Type,
         x_batch_resp_rec     OUT   NOCOPY BankAccXfrResp_Rec_Type,
	 x_batch_respdet_tbl  OUT   NOCOPY BankAccXfrRespDet_Tbl_Type
	 ) ;


END IBY_BANKACCXFR_PUB;

 

/
