--------------------------------------------------------
--  DDL for Package AMS_DELIVERABLERULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_DELIVERABLERULES_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvders.pls 120.0 2005/05/31 18:52:16 appldev noship $ */

--========================================================================
-- PROCEDURE
--    update_delv_status
--
-- PURPOSE
--    Update deliverable status through workflow.
--========================================================================
PROCEDURE update_delv_status(
    p_deliverable_id   IN   NUMBER
   ,p_user_status_id   IN   NUMBER
);


--========================================================================
-- PROCEDURE
--    update_status
--
-- PURPOSE
--   This api will be used by Delv api and also by approval api
--   to update the status of a deliverable
--========================================================================

PROCEDURE update_status(
    p_deliverable_id          IN   NUMBER
   ,p_new_status_id           IN   NUMBER
   ,p_new_status_code         IN   VARCHAR2
   );


--========================================================================
-- PROCEDURE
--    Approve_Content_Item
--
-- PURPOSE
--   This api will be used to approve the content item before the deliv
--   goes active
--========================================================================
PROCEDURE Approve_Content_Item(
  p_deliverable_id             IN   NUMBER,
  p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
  p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
  p_api_version_number         IN  NUMBER,
  x_return_status              OUT NOCOPY  VARCHAR2,
  x_msg_count                  OUT NOCOPY  NUMBER,
  x_msg_data                   OUT NOCOPY  VARCHAR2
   );


END AMS_DeliverableRules_PVT;

 

/
