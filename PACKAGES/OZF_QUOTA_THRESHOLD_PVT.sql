--------------------------------------------------------
--  DDL for Package OZF_QUOTA_THRESHOLD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_QUOTA_THRESHOLD_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvqtrs.pls 115.1 2003/12/04 12:04:56 pkarthik noship $*/
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_QUOTA_THRESHOLD_PVT
-- Purpose
--
-- History
--         Created By   - Padmavathi Karthikeyan

-- NOTE
-- -- To validate the Quota Thresholds corresponding to Budgets
-- and write into ozf_act_log table for notification purpose.
-- Arguments
-- End of Comments
-- ===============================================================

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           validate_quota_threshold
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--
--   OUT
--       x_retcode               OUT  NUMBER
--       x_errbuf                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note:     This is the main procedure called while executing concurrent program.
--             For all enabled quota threshold rules, it will check for violation
--             and sent notification accordingly.
--             It also set alert flages for dashboard use.
--   End of Comments
--   ==============================================================================
PROCEDURE validate_quota_threshold
(
     x_errbuf        OUT NOCOPY      VARCHAR2,
     x_retcode       OUT NOCOPY      NUMBER
    );

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

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           update_alerts
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_resource_id             IN   NUMBER   Required
--       p_alert_for               IN   VARCHAR2   Required
--       p_product_attribute       IN   VARCHAR2   Required
--       p_attribute2              IN   NUMBER   Required
--       p_alert_type              IN   VARCHAR2   Required
--       p_select_attribute        IN   VARCHAR2   Required
--       p_cust_account_id         IN   NUMBER   Required
--
--   OUT
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--       x_return_status           OUT  VARCHAR2
--   Version : Current version 1.0
--   Note:  It updates/inserts either ozf_quota_alerts/ozf_dashb_daily_kpi as per
--          the value of p_alert_for.
--
--   End of Comments
--   ==============================================================================

PROCEDURE update_alerts(
    p_api_version_number    IN  NUMBER,
    p_init_msg_list         IN   VARCHAR2     := FND_API.G_FALSE,
    x_Msg_Count       OUT NOCOPY  NUMBER,
    x_Msg_Data        OUT NOCOPY  VARCHAR2,
    x_return_status   OUT NOCOPY VARCHAR2,
    p_resource_id               IN NUMBER,
    p_alert_for                 IN VARCHAR2,
    p_product_attribute         IN VARCHAR2,
    p_attribute2                IN NUMBER, -- product_attr_value/ship_to_site_use_id/sequence_number
    p_alert_type                IN VARCHAR2,
    p_select_attribute          IN VARCHAR2,
    p_cust_account_id           IN NUMBER
    );

END OZF_QUOTA_THRESHOLD_PVT; -- Package spec

 

/
