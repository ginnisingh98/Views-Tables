--------------------------------------------------------
--  DDL for Package IBY_DBCCARD_GRAPH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBY_DBCCARD_GRAPH_PVT" AUTHID CURRENT_USER AS
/*$Header: ibyvgphs.pls 115.2 2002/11/20 01:07:19 jleybovi noship $*/

------------------------------------------------------------------------
-- Constants Declaration
------------------------------------------------------------------------

     C_PERIOD_DAILY  CONSTANT  VARCHAR2(10) := 'DAILY';
     C_PERIOD_WEEKLY  CONSTANT  VARCHAR2(10) := 'WEEKLY';
     C_PERIOD_MONTHLY  CONSTANT  VARCHAR2(10) := 'MONTHLY';
     C_PERIOD_YEARLY  CONSTANT  VARCHAR2(10) := 'YEARLY';

     C_STATUS_SUCCESS CONSTANT  VARCHAR2(10) := 'SUCCESS';
     C_STATUS_FAILED CONSTANT  VARCHAR2(10) := 'FAILED';
     C_STATUS_PENDING CONSTANT  VARCHAR2(10) := 'PENDING';
     C_STATUS_UNKNOWN CONSTANT  VARCHAR2(10) := 'UNKNOWN';

     C_OUTPUTTYPE_TRXN CONSTANT  VARCHAR2(10) := 'TRXN';
     C_OUTPUTTYPE_AMOUNT CONSTANT  VARCHAR2(10) := 'AMOUNT';

-------------------------------------------------------------------------
        --**Defining all DataStructures required by the procedures**--
--  The following input and output PL/SQL record/table types are defined
-- to store the objects (entities) necessary for the Instrument Registration
-- PL/SQL APIs.
-------------------------------------------------------------------------

--INPUT and OUTPUT DataStructures
  --1. Record Types

TYPE HourlyVol_rec_type IS RECORD (
        columnId            NUMBER(2) := 0,
        totalTrxn           NUMBER := 0,
        time                VARCHAR2(10)
        );

TYPE TrxnTrends_rec_type IS RECORD (
        month            VARCHAR2(10),
        value            NUMBER := 0,
        type             VARCHAR2(100),
        tdate            DATE
        );

--2. Table Types

TYPE HourlyVol_tbl_type IS TABLE OF HourlyVol_rec_type
                      INDEX BY BINARY_INTEGER;

TYPE TrxnTrends_tbl_type IS TABLE OF TrxnTrends_rec_type
                      INDEX BY BINARY_INTEGER;

TYPE Trends_tbl_type IS TABLE OF TrxnTrends_rec_type;

--------------------------------------------------------------------------------------
                      -- API Signatures--
--------------------------------------------------------------------------------------
        -- 1. Get_Hourly_Volume
        -- Start of comments
        --   API name        : Get_Hourly_Volume
        --   Type            : Private
        --   Pre-reqs        : None
        --   Function        : Fetches the information for hourly transaction.
        --   Parameters      :
        --   IN              : payee_id            IN    VARCHAR2
        --                     HourlyVol_tbl       OUT   HourlyVol_tbl_type
        -- End of comments
--------------------------------------------------------------------------------------
Procedure Get_Hourly_Volume ( payee_id        IN    VARCHAR2,
                             HourlyVol_tbl     OUT NOCOPY HourlyVol_tbl_type
                            );

--------------------------------------------------------------------------------------
        -- 2. Get_Trxn_Trends
        -- Start of comments
        --   API name        : Get_Trxn_Trends
        --   Type            : Private
        --   Pre-reqs        : None
        --   Function        : Fetches the information for Credit/Purchase Cards.
        --   Parameters      :
        --   IN              : payee_id            IN    VARCHAR2
        --                     output_type         IN    VARCHAR2
        --   OUT             : TrxnTrend_tbl       OUT   TrxnTrends_tbl_type
        -- End of comments
--------------------------------------------------------------------------------------
Procedure Get_Trxn_Trends ( payee_id          IN    VARCHAR2,
                            output_type       IN    VARCHAR2,
                            TrxnTrend_tbl     OUT NOCOPY TrxnTrends_tbl_type
                            );

--------------------------------------------------------------------------------------
        -- 3. Get_Processor_Trends
        -- Start of comments
        --   API name        : Get_Processor_Trends
        --   Type            : Private
        --   Pre-reqs        : None
        --   Function        : Fetches the information for Processors.
        --   Parameters      :
        --   IN              : payee_id            IN    VARCHAR2
        --                     output_type         IN    VARCHAR2
        --   OUT             : TrxnTrend_tbl       OUT   TrxnTrends_tbl_type
        -- End of comments
--------------------------------------------------------------------------------------
Procedure Get_Processor_Trends ( payee_id          IN    VARCHAR2,
                                 output_type       IN    VARCHAR2,
                                 TrxnTrend_tbl     OUT NOCOPY TrxnTrends_tbl_type
                               );

--------------------------------------------------------------------------------------
        -- 4. Get_Subtype_Trends
        -- Start of comments
        --   API name        : Get_Subtype_Trends
        --   Type            : Private
        --   Pre-reqs        : None
        --   Function        : Fetches the information for Credit/Purchase Subtypes.
        --   Parameters      :
        --   IN              : payee_id            IN    VARCHAR2
        --                     output_type         IN    VARCHAR2
        --                     TrxnTrend_tbl       OUT   TrxnTrends_tbl_type
        -- End of comments
--------------------------------------------------------------------------------------
Procedure Get_Subtype_Trends ( payee_id          IN    VARCHAR2,
                               output_type       IN    VARCHAR2,
                               TrxnTrend_tbl     OUT NOCOPY TrxnTrends_tbl_type
                               );

--------------------------------------------------------------------------------------
        -- 5. Get_Failure_Trends
        -- Start of comments
        --   API name        : Get_Failure_Trends
        --   Type            : Private
        --   Pre-reqs        : None
        --   Function        : Fetches the information for Authorization and Settlement failures.
        --   Parameters      :
        --   IN              : payee_id            IN    VARCHAR2
        --                     output_type         IN    VARCHAR2
        --                     TrxnTrend_tbl       OUT NOCOPY TrxnTrends_tbl_type
        -- End of comments
--------------------------------------------------------------------------------------
Procedure Get_Failure_Trends ( payee_id          IN    VARCHAR2,
                               output_type       IN    VARCHAR2,
                               TrxnTrend_tbl     OUT NOCOPY TrxnTrends_tbl_type
                               );

END IBY_DBCCARD_GRAPH_PVT;

 

/
