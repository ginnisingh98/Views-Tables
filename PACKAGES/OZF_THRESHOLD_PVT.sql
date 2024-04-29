--------------------------------------------------------
--  DDL for Package OZF_THRESHOLD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_THRESHOLD_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvtres.pls 115.0 2003/06/26 05:11:05 mchang noship $*/
-- ===============================================================
-- Start of Comments
-- Package name
--          ozf_threshold_pvt
-- Purpose
--
-- History
--         Created By   - Siddharha Dutta
--         29/04/2001   Feliu updated
--         29/11/2001   Changed signature for  validate_threshold.

-- NOTE
-- -- To validate the Thresholds corresponding to Budgets
-- and write into ozf_act_log table for notification purpose.
-- Arguments
-- End of Comments
-- ===============================================================

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           validate_threshold
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_threshold_rec            IN   threshold_rec_type  Required
--
--   OUT
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--       x_return_status           OUT  VARCHAR2
--   Version : Current version 1.0
--   Note:  This is main procedure called by workflow. it validates the the threshold rules on budgets
--
--   End of Comments
--   ==============================================================================
PROCEDURE validate_threshold
(   /*p_api_version_number    IN  NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_msg_count             OUT NOCOPY NUMBER,
    x_msg_data              OUT NOCOPY VARCHAR2,
    x_msg_buffer        OUT NOCOPY VARCHAR2,
    x_return_status        OUT NOCOPY VARCHAR2
   */
     x_errbuf        OUT NOCOPY      VARCHAR2
     ,x_retcode       OUT NOCOPY      NUMBER
    );

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           value_limit
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_budget_id              IN   NUMBER     Required
--       p_value_limit_type       IN   VARCHAR2   Required
--       p_off_on_line            IN   VARCHAR2   Required

--   OUT
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--       x_return_status           OUT  VARCHAR2
--       x_result                  OUT NUMBER
--   Version : Current version 1.0
--   Note:  it gets value limit for threshold rule validation.
--
--   End of Comments
--   ==============================================================================

PROCEDURE value_limit
(   p_api_version_number    IN  NUMBER,
    p_init_msg_list         IN   VARCHAR2     := FND_API.G_FALSE,
    X_Msg_Count       OUT NOCOPY  NUMBER,
    X_Msg_Data        OUT NOCOPY  VARCHAR2,
    x_return_status   OUT NOCOPY VARCHAR2,
    p_budget_id       IN NUMBER,
    p_value_limit_type IN VARCHAR2,
    p_off_on_line     IN VARCHAR2,
    x_result          OUT NOCOPY NUMBER);

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           base_line_amt
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_budget_id               IN   Required
--       p_percent                 IN   NUMBER     Required
--       p_base_line_type          IN   VARCHAR2  Required
--
--   OUT
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--       x_return_status           OUT  VARCHAR2
--       x_result                  OUT NUMBER
--   Version : Current version 1.0
--   Note:  it gets base line amount for threshold rule validation.
--
--   End of Comments
--   ==============================================================================
PROCEDURE base_line_amt(
    p_api_version_number    IN  NUMBER,
    p_init_msg_list         IN   VARCHAR2     := FND_API.G_FALSE,
    X_Msg_Count       OUT NOCOPY  NUMBER,
    X_Msg_Data        OUT NOCOPY  VARCHAR2,
    x_return_status   OUT NOCOPY VARCHAR2,
    p_budget_id       IN NUMBER,
    p_percent         IN NUMBER,
    p_base_line_type  IN VARCHAR2,
    x_result          OUT NOCOPY NUMBER);

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           operation_result
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_lhs                  IN   NUMBER   Required
--       p_rhs        IN   NUMBER     Optional  Required
--       p_operator_code            IN   VARCHAR2  Required
--
--   OUT
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--       x_return_status           OUT  VARCHAR2
--       x_result                  OUT  VARCHAR2
--   Version : Current version 1.0
--   Note:  It compares value limit amout and base line limit amount to decide validate status.
--
--   End of Comments
--   ==============================================================================
PROCEDURE operation_result(
    p_api_version_number    IN  NUMBER,
    p_init_msg_list         IN   VARCHAR2     := FND_API.G_FALSE,
    X_Msg_Count       OUT NOCOPY  NUMBER,
    X_Msg_Data        OUT NOCOPY  VARCHAR2,
    x_return_status   OUT NOCOPY VARCHAR2,
    p_lhs                IN NUMBER,
    p_rhs                IN NUMBER,
    p_operator_code      IN VARCHAR2,
    x_result          OUT NOCOPY VARCHAR2);
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           verify_notification
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_budget_id                  IN   NUMBER   Required
--       p_threshold_id        IN   NUMBER   Required
--       p_threshold_rule_id            IN   NUMBER   Required
--       p_frequency_period                  IN   VARCHAR2   Required
--       p_repeat_frequency        IN   NUMBER   Required
--       p_rule_start_date            IN   DATE   Required

--
--   OUT
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--       x_return_status           OUT  VARCHAR2
--       x_result                  OUT  VARCHAR2
--   Version : Current version 1.0
--   Note:  it checks ams_act_logs table to see if notification existed or not.
--
--   End of Comments
--   ==============================================================================

PROCEDURE verify_notification(
    p_api_version_number    IN  NUMBER,
    p_init_msg_list         IN   VARCHAR2     := FND_API.G_FALSE,
    X_Msg_Count       OUT NOCOPY  NUMBER,
    X_Msg_Data        OUT NOCOPY  VARCHAR2,
    x_return_status   OUT NOCOPY VARCHAR2,
    p_budget_id          IN NUMBER,
    p_threshold_id       IN NUMBER,
    p_threshold_rule_id  IN NUMBER,
    p_frequency_period   IN VARCHAR2,
    p_repeat_frequency     IN NUMBER,
    p_rule_start_date     IN DATE,
    x_result          OUT NOCOPY VARCHAR2);


END Ozf_Threshold_Pvt;


 

/
