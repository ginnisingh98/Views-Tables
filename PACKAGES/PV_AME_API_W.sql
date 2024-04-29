--------------------------------------------------------
--  DDL for Package PV_AME_API_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_AME_API_W" AUTHID CURRENT_USER AS
/* $Header: pvapprls.pls 120.3 2005/10/10 14:44:05 saarumug ship $*/

PROCEDURE START_APPROVAL_PROCESS ( p_api_version_number      IN  NUMBER
                                   ,p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE
                                   ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
                                   ,p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
                                   ,p_referral_id            IN          NUMBER
                                   , p_partner_id            IN  NUMBER   DEFAULT NULL

                                   , p_change_cntry_flag     IN          VARCHAR2  -- if ref country is changed set this to true
                                   , p_country_code          IN          VARCHAR2 -- new country code if change_country_flag is true
                                   , p_approval_entity       IN          VARCHAR2 -- PVREFFRL/PVDEALRN/PVDQMAPR
                                   , x_return_status         OUT  NOCOPY VARCHAR2
                                   , x_msg_count             OUT  NOCOPY NUMBER
                                   , x_msg_data              OUT  NOCOPY VARCHAR2
                                   );

PROCEDURE UPDATE_APPROVER_RESPONSE( p_api_version_number    IN  NUMBER
                                    , p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE
                                    , p_commit              IN  VARCHAR2 := FND_API.G_FALSE
                                    , p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
                                    , p_referral_id         IN  NUMBER
                                    , p_approval_entity     IN  VARCHAR2 -- PVREFFRL/PVDEALRN/PVDQMAPR
                                    , p_response            IN  VARCHAR2 -- refer to AME_UTIL.approverIn
                                    , p_approver_user_id    IN  NUMBER -- userID of the person sending approver resp
                                    , p_forwardee_user_id   IN  NUMBER   -- if forwarding then userID of the forwardee
                                    , p_note_added_flag     IN  VARCHAR2 DEFAULT 'N' -- If note was added as part of this response.
                                    , x_approval_done       OUT NOCOPY   VARCHAR2  -- True if approval process is finished False if not.
                                    , x_return_status       OUT NOCOPY  VARCHAR2
                                    , x_msg_count           OUT NOCOPY  NUMBER
                                    , x_msg_data            OUT NOCOPY  VARCHAR2
                                    );


END PV_AME_API_W;

 

/
