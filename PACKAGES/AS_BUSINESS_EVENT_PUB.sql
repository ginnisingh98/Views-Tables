--------------------------------------------------------
--  DDL for Package AS_BUSINESS_EVENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_BUSINESS_EVENT_PUB" AUTHID CURRENT_USER as
/* $Header: asxpbevs.pls 115.1 2003/11/21 13:59:37 sumahali noship $ */

-- Start of Comments
--
--      API name        : Before_Oppty_Update
--      Type            : Public
--      Function        : When called before Opportunity header update, takes
--                        snapshot of Opp header and returns an event key in
--                        x_event_key which is to be passed, when raising a
--                        business event after the update is over using the
--                        Update_oppty_post_event procedure. If lead_id is
--                        NULL then a new Event key is returned without taking
--                        a snapshot. This can be used before creating a new
--                        opportunity since no lead_id is available.
--
--      Pre-reqs        : Existing lead_id or NULL value.
--
--      Paramaeters     :
--      IN              :
--          p_api_version_number    IN  NUMBER
--          p_init_msg_list         IN  VARCHAR2
--          p_commit                IN  VARCHAR2
--          p_validation_level      IN  NUMBER
--          p_lead_id               IN NUMBER
--      OUT             :
--          x_return_status         OUT NOCOPY     VARCHAR2(1)
--          x_msg_count             OUT NOCOPY     NUMBER
--          x_msg_data              OUT NOCOPY     VARCHAR2(2000)
--          x_event_key             OUT NOCOPY VARCHAR2
--
--
--      Version :       Current version 2.0
--                      Initial version 2.0
--
--      Notes:
--
--
-- End of Comments


PROCEDURE Before_Oppty_Update(
    p_api_version_number        IN  NUMBER,
    p_init_msg_list             IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit                    IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_validation_level          IN  NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
    p_lead_id                   IN NUMBER,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    x_event_key                 OUT NOCOPY VARCHAR2
);

-- Start of Comments
--
--      API name        : Update_oppty_post_event
--      Type            : Public
--      Function        : Raises a business event for Opportunity header update.
--                        The Procedure Before_Oppty_Update should have been
--                        called and the same event key must be passed.
--
--      Pre-reqs        : Existing lead_id and x_event_key from
--                        Before_Oppty_Update call.
--
--      Paramaeters     :
--      IN              :
--          p_api_version_number    IN  NUMBER
--          p_init_msg_list         IN  VARCHAR2
--          p_commit                IN  VARCHAR2
--          p_validation_level      IN  NUMBER
--          p_event_key             IN  VARCHAR2
--          p_lead_id               IN  NUMBER
--      OUT             :
--          x_return_status         OUT NOCOPY     VARCHAR2(1)
--          x_msg_count             OUT NOCOPY     NUMBER
--          x_msg_data              OUT NOCOPY     VARCHAR2(2000)
--
--
--      Version :       Current version 2.0
--                      Initial version 2.0
--
--      Notes:
--
--
-- End of Comments

PROCEDURE Update_oppty_post_event(
    p_api_version_number        IN  NUMBER,
    p_init_msg_list             IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit                    IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_validation_level          IN  NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
    p_lead_id                   IN NUMBER,
    p_event_key                 IN VARCHAR2,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2
);

-- Start of Comments
--
--      API name        : Before_Opp_Lines_Update
--      Type            : Public
--      Function        : When called before Opportunity line update, takes
--                        snapshot of Opp lines and returns an event key in
--                        x_event_key which is to be passed, when raising a
--                        business event after the update is over using the
--                        Upd_Opp_Lines_post_event procedure. If lead_id is
--                        NULL then a new Event key is returned without taking
--                        a snapshot. This can be used before creating a new
--                        opportunity since no lead_id is available.
--
--      Pre-reqs        : Existing lead_id or NULL value.
--
--      Paramaeters     :
--      IN              :
--          p_api_version_number    IN  NUMBER
--          p_init_msg_list         IN  VARCHAR2
--          p_commit                IN  VARCHAR2
--          p_validation_level      IN  NUMBER
--          p_lead_id               IN NUMBER
--      OUT             :
--          x_return_status         OUT NOCOPY     VARCHAR2(1)
--          x_msg_count             OUT NOCOPY     NUMBER
--          x_msg_data              OUT NOCOPY     VARCHAR2(2000)
--          x_event_key             OUT NOCOPY VARCHAR2
--
--
--      Version :       Current version 2.0
--                      Initial version 2.0
--
--      Notes:
--
--
-- End of Comments


PROCEDURE Before_Opp_Lines_Update(
    p_api_version_number        IN  NUMBER,
    p_init_msg_list             IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit                    IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_validation_level          IN  NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
    p_lead_id                   IN NUMBER,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    x_event_key                 OUT NOCOPY VARCHAR2
);

-- Start of Comments
--
--      API name        : Upd_Opp_Lines_post_event
--      Type            : Public
--      Function        : Raises a business event for Opportunity line update.
--                        The Procedure Before_Opp_Lines_Update should have been
--                        called and the same event key must be passed.
--
--      Pre-reqs        : Existing lead_id and x_event_key from
--                        Before_Opp_Lines_Update call.
--
--      Paramaeters     :
--      IN              :
--          p_api_version_number    IN  NUMBER
--          p_init_msg_list         IN  VARCHAR2
--          p_commit                IN  VARCHAR2
--          p_validation_level      IN  NUMBER
--          p_event_key             IN  VARCHAR2
--          p_lead_id               IN  NUMBER
--      OUT             :
--          x_return_status         OUT NOCOPY     VARCHAR2(1)
--          x_msg_count             OUT NOCOPY     NUMBER
--          x_msg_data              OUT NOCOPY     VARCHAR2(2000)
--
--
--      Version :       Current version 2.0
--                      Initial version 2.0
--
--      Notes:
--
--
-- End of Comments

PROCEDURE Upd_Opp_Lines_post_event(
    p_api_version_number        IN  NUMBER,
    p_init_msg_list             IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit                    IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_validation_level          IN  NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
    p_lead_id                   IN NUMBER,
    p_event_key                 IN VARCHAR2,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2
);

-- Start of Comments
--
--      API name        : Before_Opp_STeam_Update
--      Type            : Public
--      Function        : When called before Opportunity sales team update, takes
--                        snapshot of Opp sales team and returns an event key in
--                        x_event_key which is to be passed, when raising a
--                        business event after the update is over using the
--                        Upd_Opp_STeam_post_event procedure. If lead_id is
--                        NULL then a new Event key is returned without taking
--                        a snapshot. This can be used before creating a new
--                        opportunity since no lead_id is available.
--
--      Pre-reqs        : Existing lead_id or NULL value.
--
--      Paramaeters     :
--      IN              :
--          p_api_version_number    IN  NUMBER
--          p_init_msg_list         IN  VARCHAR2
--          p_commit                IN  VARCHAR2
--          p_validation_level      IN  NUMBER
--          p_lead_id               IN NUMBER
--      OUT             :
--          x_return_status         OUT NOCOPY     VARCHAR2(1)
--          x_msg_count             OUT NOCOPY     NUMBER
--          x_msg_data              OUT NOCOPY     VARCHAR2(2000)
--          x_event_key             OUT NOCOPY VARCHAR2
--
--
--      Version :       Current version 2.0
--                      Initial version 2.0
--
--      Notes:
--
--
-- End of Comments


PROCEDURE Before_Opp_STeam_Update(
    p_api_version_number        IN  NUMBER,
    p_init_msg_list             IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit                    IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_validation_level          IN  NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
    p_lead_id                   IN NUMBER,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    x_event_key                 OUT NOCOPY VARCHAR2
);

-- Start of Comments
--
--      API name        : Upd_Opp_STeam_post_event
--      Type            : Public
--      Function        : Raises a business event for Opportunity sales team
--                        update. The Procedure Before_Opp_STeam_Update should
--                        have been called and the same event key must be passed.
--
--      Pre-reqs        : Existing lead_id and x_event_key from
--                        Before_Opp_STeam_Update call.
--
--      Paramaeters     :
--      IN              :
--          p_api_version_number    IN  NUMBER
--          p_init_msg_list         IN  VARCHAR2
--          p_commit                IN  VARCHAR2
--          p_validation_level      IN  NUMBER
--          p_event_key             IN  VARCHAR2
--          p_lead_id               IN  NUMBER
--      OUT             :
--          x_return_status         OUT NOCOPY     VARCHAR2(1)
--          x_msg_count             OUT NOCOPY     NUMBER
--          x_msg_data              OUT NOCOPY     VARCHAR2(2000)
--
--
--      Version :       Current version 2.0
--                      Initial version 2.0
--
--      Notes:
--
--
-- End of Comments

PROCEDURE Upd_Opp_STeam_post_event(
    p_api_version_number        IN  NUMBER,
    p_init_msg_list             IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit                    IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_validation_level          IN  NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
    p_lead_id                   IN NUMBER,
    p_event_key                 IN VARCHAR2,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2
);

-- Start of Comments
--
--      API name        : Before_Cust_STeam_Update
--      Type            : Public
--      Function        : When called before Customer sales team update, takes
--                        snapshot of Cust sales team and returns an event key in
--                        x_event_key which is to be passed, when raising a
--                        business event after the update is over using the
--                        Upd_Cust_STeam_post_event procedure. If cust_id is
--                        NULL then a new Event key is returned without taking
--                        a snapshot. This can be used before creating a new
--                        customer since no cust_id is available.
--
--      Pre-reqs        : Existing cust_id or NULL value.
--
--      Paramaeters     :
--      IN              :
--          p_api_version_number    IN  NUMBER
--          p_init_msg_list         IN  VARCHAR2
--          p_commit                IN  VARCHAR2
--          p_validation_level      IN  NUMBER
--          p_cust_id               IN NUMBER
--      OUT             :
--          x_return_status         OUT NOCOPY     VARCHAR2(1)
--          x_msg_count             OUT NOCOPY     NUMBER
--          x_msg_data              OUT NOCOPY     VARCHAR2(2000)
--          x_event_key             OUT NOCOPY VARCHAR2
--
--
--      Version :       Current version 2.0
--                      Initial version 2.0
--
--      Notes:
--
--
-- End of Comments


PROCEDURE Before_Cust_STeam_Update(
    p_api_version_number        IN  NUMBER,
    p_init_msg_list             IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit                    IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_validation_level          IN  NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
    p_cust_id                   IN NUMBER,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    x_event_key                 OUT NOCOPY VARCHAR2
);

-- Start of Comments
--
--      API name        : Upd_Cust_STeam_post_event
--      Type            : Public
--      Function        : Raises a business event for Customer sales team
--                        update. The Procedure Before_Cust_STeam_Update should
--                        have been called and the same event key must be passed.
--
--      Pre-reqs        : Existing cust_id and x_event_key from
--                        Before_Cust_STeam_Update call.
--
--      Paramaeters     :
--      IN              :
--          p_api_version_number    IN  NUMBER
--          p_init_msg_list         IN  VARCHAR2
--          p_commit                IN  VARCHAR2
--          p_validation_level      IN  NUMBER
--          p_event_key             IN  VARCHAR2
--          p_cust_id               IN  NUMBER
--      OUT             :
--          x_return_status         OUT NOCOPY     VARCHAR2(1)
--          x_msg_count             OUT NOCOPY     NUMBER
--          x_msg_data              OUT NOCOPY     VARCHAR2(2000)
--
--
--      Version :       Current version 2.0
--                      Initial version 2.0
--
--      Notes:
--
--
-- End of Comments

PROCEDURE Upd_Cust_STeam_post_event(
    p_api_version_number        IN  NUMBER,
    p_init_msg_list             IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit                    IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_validation_level          IN  NUMBER DEFAULT FND_API.G_VALID_LEVEL_FULL,
    p_cust_id                   IN NUMBER,
    p_event_key                 IN VARCHAR2,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2
);

END AS_BUSINESS_EVENT_PUB;

 

/
