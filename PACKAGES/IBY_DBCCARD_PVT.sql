--------------------------------------------------------
--  DDL for Package IBY_DBCCARD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_DBCCARD_PVT" AUTHID CURRENT_USER AS
/*$Header: ibyvdbcs.pls 120.2 2005/10/30 05:51:30 appldev noship $*/

------------------------------------------------------------------------
-- Constants Declaration
------------------------------------------------------------------------
     C_INSTRTYPE_CREDITCARD  CONSTANT  VARCHAR2(20) := 'CREDITCARD';
     C_INSTRTYPE_PURCHASECARD  CONSTANT  VARCHAR2(20) := 'PURCHASECARD';

     C_PERIOD_DAILY  CONSTANT  VARCHAR2(10) := 'DAILY';
     C_PERIOD_WEEKLY  CONSTANT  VARCHAR2(10) := 'WEEKLY';
     C_PERIOD_MONTHLY  CONSTANT  VARCHAR2(10) := 'MONTHLY';

     -- Bug 3714173: C_TO_CURRENCY is from the profile option after the fix
     -- C_TO_CURRENCY CONSTANT  VARCHAR2(5) := 'USD';

     C_STATUS_SUCCESS CONSTANT  VARCHAR2(10) := 'SUCCESS';
     C_STATUS_FAILED CONSTANT  VARCHAR2(10) := 'FAILED';
     C_STATUS_PENDING CONSTANT  VARCHAR2(10) := 'PENDING';
     C_STATUS_UNKNOWN CONSTANT  VARCHAR2(10) := 'UNKNOWN';

-------------------------------------------------------------------------
        --**Defining all DataStructures required by the procedures**--
--  The following input and output PL/SQL record/table types are defined
-- to store the objects (entities) necessary for the Instrument Registration
-- PL/SQL APIs.
-------------------------------------------------------------------------

--INPUT and OUTPUT DataStructures
  --1. Record Types

TYPE Summary_rec_type IS RECORD (
        columnId            NUMBER(2) := 0,
        totalTrxn           NUMBER := 0,
        totalAmt            NUMBER := 0
        );

TYPE TrxnSum_rec_type IS RECORD (
        columnId            NUMBER(2) := 0,
        totalReq            NUMBER := 0,
        totalSuc            NUMBER := 0,
        totalFail           NUMBER := 0,
        totalPend           NUMBER := 0
        );

TYPE TrxnFail_rec_type IS RECORD (
        columnId            NUMBER(2) := 0,
        status              NUMBER(15) := 0,
        cause               VARCHAR2(80),
        totalTrxn           NUMBER := 0,
        totalAmt            NUMBER := 0
        );

--2. Table Types

TYPE Summary_tbl_type IS TABLE OF Summary_rec_type
                      INDEX BY BINARY_INTEGER;

TYPE TrxnSum_tbl_type IS TABLE OF TrxnSum_rec_type
                      INDEX BY BINARY_INTEGER;

TYPE TrxnFail_tbl_type IS TABLE OF TrxnFail_rec_type
                      INDEX BY BINARY_INTEGER;

--------------------------------------------------------------------------------------
                      -- API Signatures--
--------------------------------------------------------------------------------------
        -- 1. Get_Trxn_Summary
        -- Start of comments
        --   API name        : Get_Trxn_Summary
        --   Type            : Private
        --   Pre-reqs        : None
        --   Function        : Fetches the information for a transactions.
        --   Parameters      :
        --   IN              : payee_id            IN    VARCHAR2
        --                     period              IN    VARCHAR2            Required
        --                     summary_tbl         OUT   Summary_tbl_type
        --                     trxnSum_tbl         OUT   TrxnSum_tbl_type
        -- End of comments
--------------------------------------------------------------------------------------
Procedure Get_Trxn_Summary ( payee_id        IN    VARCHAR2,
                             period          IN    VARCHAR2,
                             summary_tbl     OUT NOCOPY Summary_tbl_type,
                             trxnSum_tbl     OUT NOCOPY TrxnSum_tbl_type
                            );

--------------------------------------------------------------------------------------
        -- 2. Get_Failure_Summary
        -- Start of comments
        --   API name        : Get_Failure_Summary
        --   Type            : Private
        --   Pre-reqs        : None
        --   Function        : Fetches the information for failures.
        --   Parameters      :
        --   IN              : payee_id             IN    VARCHAR2
        --                     period               IN    VARCHAR2            Required
        --                     authFail_tbl         OUT   TrxnFail_tbl_type
        --                     settFail_tbl         OUT   TrxnFail_tbl_type
        -- End of comments
--------------------------------------------------------------------------------------
Procedure Get_Failure_Summary ( payee_id        IN    VARCHAR2,
                                period          IN    VARCHAR2,
                                authFail_tbl     OUT NOCOPY TrxnFail_tbl_type,
                                settFail_tbl     OUT NOCOPY TrxnFail_tbl_type
                               );

--------------------------------------------------------------------------------------
        -- 3. Get_CardType_Summary
        -- Start of comments
        --   API name        : Get_CardType_Summary
        --   Type            : Private
        --   Pre-reqs        : None
        --   Function        : Fetches the information for Card sub types.
        --   Parameters      :
        --   IN              : payee_id             IN    VARCHAR2
        --                     period               IN    VARCHAR2            Required
        --                     cardType_tbl         OUT   TrxnFail_tbl_type
        -- End of comments
--------------------------------------------------------------------------------------
Procedure Get_CardType_Summary ( payee_id         IN    VARCHAR2,
                                 period           IN    VARCHAR2,
                                 cardType_tbl     OUT NOCOPY TrxnFail_tbl_type
                                );

--------------------------------------------------------------------------------------
        -- 4. Get_Processor_Summary
        -- Start of comments
        --   API name        : Get_Processor_Summary
        --   Type            : Private
        --   Pre-reqs        : None
        --   Function        : Fetches the information for Processors.
        --   Parameters      :
        --   IN              : payee_id             IN    VARCHAR2
        --                     period               IN    VARCHAR2            Required
        --                     Processor_tbl         OUT   TrxnFail_tbl_type
        -- End of comments
--------------------------------------------------------------------------------------
Procedure Get_Processor_Summary ( payee_id         IN    VARCHAR2,
                                  period           IN    VARCHAR2,
                                  Processor_tbl     OUT NOCOPY TrxnFail_tbl_type
                                );

--------------------------------------------------------------------------------------
        -- 5. Get_Risk_Summary
        -- Start of comments
        --   API name        : Get_Risk_Summary
        --   Type            : Private
        --   Pre-reqs        : None
        --   Function        : Fetches the information for Risks.
        --   Parameters      :
        --   IN              : payee_id             IN    VARCHAR2
        --                     period               IN    VARCHAR2            Required
        --                     total_screened       OUT   NUMBER
        --                     total_risky          OUT   NUMBER
        -- End of comments
--------------------------------------------------------------------------------------
Procedure Get_Risk_Summary ( payee_id         IN    VARCHAR2,
                             period           IN    VARCHAR2,
                             total_screened   OUT NOCOPY NUMBER,
                             total_risky      OUT NOCOPY NUMBER
                           );

/*
The following function is a wrapper on a GL function that returns a converted amount.
If the rate is not found or the currency does not exist, GL functions a negative number.
*/
   FUNCTION Convert_Amount ( from_currency  VARCHAR2,
                             to_currency    VARCHAR2,
                             eff_date       DATE,
                             amount         NUMBER,
                             conv_type      VARCHAR2
                           ) RETURN NUMBER;
END IBY_DBCCARD_PVT;

/
