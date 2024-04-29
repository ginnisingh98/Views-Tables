--------------------------------------------------------
--  DDL for Package OZF_RESALE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_RESALE_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvrsss.pls 120.2.12010000.3 2010/03/04 06:16:13 hbandi ship $ */


-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;

---------------------------------------------------------------------
-- PROCEDURE
--    Initiate_Payment
--
-- PURPOSE
--    This procedure to initiate payment process for a batch.
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Initiate_Payment (
    p_api_version            IN  NUMBER
   ,p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_resale_batch_id        IN  NUMBER
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
);

---------------------------------------------------------------------
-- PROCEDURE
--    Initiate_Payment_WFL
--
-- PURPOSE
--    This procedure is called from a work flow to initiate payment process for a batch.
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Initiate_Payment_WFL (
   itemtype   in varchar2,
   itemkey    in varchar2,
   actid      in number,
   funcmode   in varchar2,
   resultout  in OUT NOCOPY varchar2
);

---------------------------------------------------------------------
-- PROCEDURE
--    Process_iface
--
-- PURPOSE
--    This procedure to initiate data process of records in resales interface table.
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Process_iface (
    p_api_version            IN  NUMBER
   ,p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_resale_batch_id        IN  NUMBER
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
);

---------------------------------------------------------------------
-- PROCEDURE
--    Process_Iface_WFL
--
-- PURPOSE
--    This procedure allows user to start the data process
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Process_Iface_WFL (
   itemtype   in varchar2,
   itemkey    in varchar2,
   actid      in number,
   funcmode   in varchar2,
   resultout  in OUT NOCOPY varchar2
);

---------------------------------------------------------------------
-- PROCEDURE
--    Process_Resale
--
-- PURPOSE
--    This procedure to initiate data process of records in resales table.
--    only third party accrual is supported.
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Process_Resale (
    p_api_version            IN  NUMBER
   ,p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_resale_batch_id        IN  NUMBER
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
);

---------------------------------------------------------------------
-- PROCEDURE
--    Process_Resale
--
-- PURPOSE
--    This procedure to initiate data process of records in resales table.
--    only third party accrual is supported.
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Process_Resale (
    p_api_version            IN  NUMBER
   ,p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_start_date             IN  DATE
   ,p_end_date               IN  DATE
   ,p_partner_cust_account_id IN  NUMBER
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
);

---------------------------------------------------------------------
-- PROCEDURE
--    Start_Process_Resale
--
-- PURPOSE
--    This procedure starts to process batches from interface table.
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Start_Process_Resale (
     ERRBUF                           OUT NOCOPY VARCHAR2
    ,RETCODE                          OUT NOCOPY NUMBER
    ,p_resale_batch_id                IN  NUMBER
    ,p_start_date                     IN  VARCHAR2
    ,p_end_date                       IN  VARCHAR2
    ,p_partner_cust_account_id        IN  NUMBER
);

---------------------------------------------------------------------
-- PROCEDURE
--    Purge
--
-- PURPOSE
--    This procedure removes processed data from the interface table.
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Purge (
    p_api_version            IN  NUMBER
   ,p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_data_source_code       IN  VARCHAR2   := NULL
   ,p_resale_batch_id        IN  NUMBER   := NULL
   ,x_return_status          OUT NOCOPY   VARCHAR2
   ,x_msg_data               OUT NOCOPY   VARCHAR2
   ,x_msg_count              OUT NOCOPY   NUMBER
);

---------------------------------------------------------------------
-- PROCEDURE
--    Start_Purge
--
-- PURPOSE
--    This procedure starts to remove processed data from the interface table.
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Start_Purge (
     ERRBUF                           OUT NOCOPY VARCHAR2
    ,RETCODE                          OUT NOCOPY NUMBER
    ,p_data_source_code               IN  VARCHAR2 :=null
    ,p_resale_batch_id                IN  NUMBER := NULL
);

END OZF_RESALE_PVT;

/
