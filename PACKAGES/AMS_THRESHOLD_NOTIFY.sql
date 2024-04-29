--------------------------------------------------------
--  DDL for Package AMS_THRESHOLD_NOTIFY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_THRESHOLD_NOTIFY" AUTHID CURRENT_USER AS
/* $Header: amsvtnos.pls 115.10 2001/12/18 10:33:23 pkm ship        $*/
-- ===============================================================
-- Start of Comments
-- Package name
--          ams_threshold_notify
-- Purpose
--    Runs the Workflow process to create the Threshold Notification
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Start_Process
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_owner_id                  IN   NUMBER   Required
--       p_parent_owner_id        IN   NUMBER   Required
--       p_threshold_rule_id            IN   NUMBER   Required

--   OUT
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--       x_return_status           OUT  VARCHAR2
--   Version : Current version 1.0
--   Note:  it gets value limit for threshold rule validation.
--
--   End of Comments
--   ==============================================================================

PROCEDURE Start_Process
(
    p_api_version_number    IN  NUMBER,
    x_msg_count             OUT NUMBER,
    x_msg_data              OUT VARCHAR2,
    x_return_status         OUT VARCHAR2,
    p_owner_id              IN  NUMBER,
    p_parent_owner_id       IN  NUMBER DEFAULT NULL,
    p_message_text          IN  VARCHAR2,
    p_activity_log_id       IN  NUMBER
);
     --------------------------------------------------------------------------
   -- PROCEDURE
   --   notify_threshold_violate
   --
   -- PURPOSE
   --   Generate the Approval Document for display in messages, either
   --   text or html
   -- IN
   --   document_id  - Item Key
   --   display_type - either 'text/plain' or 'text/html'
   --   document     - document buffer
   --   document_type   - type of document buffer created, either 'text/plain'
   --         or 'text/html'
   -- OUT
   -- USED BY
   --                      - Oracle MArketing Generic Apporval
   -- HISTORY
   --   05/15/2001        MUMU PANDE        CREATION
   ----------------------------------------------------------------------------
   PROCEDURE notify_threshold_violate(
      document_id     IN       VARCHAR2
     ,display_type    IN       VARCHAR2
     ,document        IN OUT   VARCHAR2
     ,document_type   IN OUT   VARCHAR2);


END ams_threshold_notify;


 

/
