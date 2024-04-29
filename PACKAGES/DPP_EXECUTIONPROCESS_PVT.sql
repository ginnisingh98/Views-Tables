--------------------------------------------------------
--  DDL for Package DPP_EXECUTIONPROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DPP_EXECUTIONPROCESS_PVT" AUTHID CURRENT_USER AS
/* $Header: dppexpps.pls 120.0.12010000.7 2009/08/20 04:44:55 anbbalas noship $ */

-- Package name     : DPP_EXECUTIONPROCESS_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

---------------------------------------------------------------------
-- PROCEDURE
--    Populate_ExecutionProcess
--
-- PURPOSE
--    Populate Execution Process as soon as the transaction is created
--
-- PARAMETERS
--
-- NOTES
--    1.
--    2.
----------------------------------------------------------------------
PROCEDURE populate_ExecutionProcess(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2    := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2    := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER      := FND_API.g_valid_level_full,
    x_return_status              OUT  NOCOPY  VARCHAR2,
    x_msg_count                  OUT  NOCOPY  NUMBER,
    x_msg_data                   OUT  NOCOPY  VARCHAR2,
    p_org_id                  IN NUMBER,
    p_txn_hdr_id              IN NUMBER,
    p_txn_number              IN VARCHAR2,
    p_vendor_id               IN NUMBER,
    p_vendor_site_id	      IN NUMBER
);

---------------------------------------------------------------------
-- PROCEDURE
--    InsertExecProcesses
--
-- PURPOSE
--    Insert Execution Process as soon as the transaction is created
--
-- PARAMETERS
--
-- NOTES
--    1.
--    2.
----------------------------------------------------------------------
PROCEDURE InsertExecProcesses(
    p_txn_hdr_id              IN NUMBER,
    p_org_id                  IN NUMBER,
    p_supp_trd_prfl_id        IN NUMBER,
    x_msg_count               OUT  NOCOPY  NUMBER,
    x_msg_data                OUT  NOCOPY  VARCHAR2,
    x_return_status           OUT  NOCOPY  VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    Initiate_ExecutionProcess
--
-- PURPOSE
--    Initiate Execution Process
--
-- PARAMETERS
--
-- NOTES
--    1.
--    2.
----------------------------------------------------------------------

  PROCEDURE Initiate_ExecutionProcess(
                                       errbuf    OUT  NOCOPY VARCHAR2,
                                       retcode    OUT  NOCOPY VARCHAR2,
                                       p_in_org_id     IN   NUMBER,
                                       p_in_txn_number  IN VARCHAR2
                                       );

---------------------------------------------------------------------
-- PROCEDURE
--    Initiate_Notification_Process
--
-- PURPOSE
--    Initiates all the notification processes only.
--
----------------------------------------------------------------------
PROCEDURE Initiate_Notification_Process(errbuf        OUT NOCOPY VARCHAR2,
                                    retcode        OUT NOCOPY VARCHAR2,
                                    p_in_org_id          IN   NUMBER
                                   );

---------------------------------------------------------------------
-- PROCEDURE
--    Change_Status
--
-- PURPOSE
--    Future dated Transactions will be moved from Active to Pending Adjustment
--  status on the effective date. Further, Work Flow notification will be sent to
--  the creator of the transactions.
--
-- PARAMETERS
--     p_in_org_id - operating unit
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Change_Status (
    errbuf               OUT NOCOPY   VARCHAR2
   ,retcode              OUT NOCOPY   VARCHAR2
   ,p_in_org_id          IN           NUMBER);

---------------------------------------------------------------------
-- PROCEDURE
--    approve_transaction
--
-- PURPOSE
--    This procedure will directly update the transaction status to
-- APPROVED without going through the AME approval and initiate the
-- automated execution processes
--
-- PARAMETERS
--
-- NOTES
--    1.
--    2.
----------------------------------------------------------------------
PROCEDURE approve_transaction(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2    := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2    := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER      := FND_API.g_valid_level_full,
    x_return_status              OUT  NOCOPY  VARCHAR2,
    x_msg_count                  OUT  NOCOPY  NUMBER,
    x_msg_data                   OUT  NOCOPY  VARCHAR2,
    p_txn_hdr_id                 IN   NUMBER
);

---------------------------------------------------------------------
-- PROCEDURE
--    update_status
--
-- PURPOSE
--    This procedure will update the transaction status of a particular
-- Price Protection transaction.
--
-- PARAMETERS
--
-- NOTES
--    1.
--    2.
----------------------------------------------------------------------
PROCEDURE update_status(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2    := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2    := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER      := FND_API.g_valid_level_full,
    x_return_status              OUT  NOCOPY  VARCHAR2,
    x_msg_count                  OUT  NOCOPY  NUMBER,
    x_msg_data                   OUT  NOCOPY  VARCHAR2,
    p_txn_hdr_id                 IN   NUMBER,
    p_to_status                  IN   VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    Update_HeaderLog
--
-- PURPOSE
--    This procedure will update the transaction header log of a particular
-- Price Protection transaction.
--
-- PARAMETERS
--
-- NOTES
--    1.
--    2.
----------------------------------------------------------------------
PROCEDURE Update_HeaderLog(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2    := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2    := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER      := FND_API.g_valid_level_full,
    x_return_status              OUT  NOCOPY  VARCHAR2,
    x_msg_count                  OUT  NOCOPY  NUMBER,
    x_msg_data                   OUT  NOCOPY  VARCHAR2,
    p_transaction_header_id      IN   NUMBER
);

END DPP_EXECUTIONPROCESS_PVT;

/
