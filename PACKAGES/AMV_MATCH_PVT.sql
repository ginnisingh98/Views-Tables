--------------------------------------------------------
--  DDL for Package AMV_MATCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMV_MATCH_PVT" AUTHID CURRENT_USER AS
/* $Header: amvvmats.pls 120.1 2005/06/30 12:49:54 appldev ship $ */
-- Start of Comments
--
-- NAME
--   AMV_MATCH_PVT
--
-- PURPOSE
--   This package is the (content) item-channel match engine api.
--   It will provide procedure for the matching engine and other api to call.
--   It will use package amv_aq_utility_pvt for handling AQ queue details.
--
--   PROCEDURES:
--
--            Stop_MatchingEngine;
--            Start_MatchingEngine;
--            Request_ItemMatch;
--            Request_ChannelMatch;
--            Match_ItemWithChannels;
--            Match_ChannelWithItems;
--            Check_ExistItemChlMatch;
--            Check_MatchingCondition;
--            Do_ItemChannelMatch;
--            Remove_ItemChannelMatch;
--
-- NOTES
--
--
-- HISTORY
--   09/30/1999        PWU            created
--
--   06/23/2000        SHITIJ VATSA   updated
--                     (svatsa)       Changed the spec of the following APIs to
--                                    incorporate the territory intg logic :
--                                    1) Do_ItemChannelMatch(Overloaded) - Added a territory_tbl_type param
--                                    2) Remove_ItemChannelMatch - Added a territory_id param
--                                    Also created a table variable terriotry_tbl_type
--                                    Added two new APIs
--                                    1. Get_UserTerritory
--                                    2. Get_PublishedTerritories
--
-- End of Comments
--
--
-- The following constants are to be finalized.
--
G_VERSION               CONSTANT    NUMBER    :=  1.0;
G_MATCH_ITEM_TABLE  CONSTANT VARCHAR2(30) := AMV_UTILITY_PVT.G_TABLE_NAME_CODE;
G_AMV_APP_ID   	CONSTANT  NUMBER := AMV_UTILITY_PVT.G_AMV_APP_ID;
--
-- Record and Table Type variable for Do_ItemChannelMatch


TYPE terr_id_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE terr_name_tbl_type IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;
--
-- This package contains the following procedure
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Request_ItemMatch
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Make a request to matching engine,
--                 to match channels with the passed item.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_item_id                          NUMBER    Required
--                   the id of the item to be matched with channels.
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Notes      :
--
-- End of comments
--
PROCEDURE Request_ItemMatch
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_item_id           IN  NUMBER
);
--
-- Algorithm:
--      This is simply a wrapper to AMV_AQ_UTILITY_PVT.Enqueue_Message.
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Request_ChannelMatch
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Make a request to matching engine:
--                 to match items with the passed channel.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_channel_id                        NUMBER    Required
--                   the id of the channel to be matched with items.
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Notes      :
--
-- End of comments
--
PROCEDURE Request_ChannelMatch
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_channel_id        IN  NUMBER
);
--
-- Algorithm:
--      This is simply a wrapper to AMV_AQ_UTILITY_PVT.Enqueue_Message.
--
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Stop_MatchingEngine
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Stop the matching engine.
--                 matching engine normally runs all the time. This procedure
--                 provide a way to stop the engine.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Notes      :
--
-- End of comments
--
PROCEDURE Stop_MatchingEngine
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE
);
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Start_MatchingEngine
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Start the matching engine and process any request in queue.
--                 This process cannot guarantees that only one engine instance
--                 is running.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Notes      :
--
-- End of comments
--
PROCEDURE Start_MatchingEngine
(
   errbuf         OUT NOCOPY    VARCHAR2,
   retcode        OUT NOCOPY    NUMBER
);
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Match_ItemWithChannels
--    Type       : Private
--    Pre-reqs   : None
--    Function   : For the passed particular (content) item,
--                 Search for all the matching channels.
--                 and do the matching, process approval.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_item_id                          NUMBER    Required
--                   the id of the item to be matched with channels.
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Notes      :
--
-- End of comments
--
PROCEDURE Match_ItemWithChannels
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_item_id           IN  NUMBER
);
--
-- Algorithm:
--   BEGIN
--     Verify API version compatibility
--     Check that login user's status is active
--     IF user not active THEN
--       Return error 'user account currently suspended'
--     ENDIF
--     Set rollback SAVEPOINT
--       ...
--     Commit transaction if requested
--     ENDIF
--   END
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Match_ChannelWithItems
--    Type       : Private
--    Pre-reqs   : None
--    Function   : For the passed particular channel,
--                 Search for all the matching items.
--                 and do the matching, process approval....
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_channel_id                        NUMBER    Required
--                   the id of the channel to be matched with items.
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Notes      :
--
-- End of comments
--
PROCEDURE Match_ChannelWithItems
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_channel_id        IN  NUMBER
);
--
-- Algorithm:
--   BEGIN
--     Verify API version compatibility
--     Check that login user's status is active
--     IF user not active THEN
--       Return error 'user account currently suspended'
--     ENDIF
--     Set rollback SAVEPOINT
--       ...
--     Commit transaction if requested
--     ENDIF
--   END
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Check_ExistItemChlMatch
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Check if the passed item and the passed channel
--                 has the match. If so, also return the approval status.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_channel_id                        NUMBER    Required
--                   the id of the channel to be matched.
--                 p_item_id                           NUMBER    Required
--                   the id of the item to be matched.
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--                 x_match_exist_flag                 VARCHAR2
--                   the flag of existence of the match.
--                   return FND_API.G_TRUE if exists,
--                   Otherwise return FND_API.G_FALSE.
--                 x_approval_status                  VARCHAR2
--                   return the approval status if the match exists.
--    Notes      :
--
-- End of comments
--
PROCEDURE Check_ExistItemChlMatch
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_channel_id        IN  NUMBER,
    p_item_id           IN  NUMBER,
    x_match_exist_flag  OUT NOCOPY  VARCHAR2,
    x_approval_status   OUT NOCOPY  VARCHAR2
);
--
-- Algorithm:
--   BEGIN
--     Verify API version compatibility
--     Check that login user's status is active
--     IF user not active THEN
--       Return error 'user account currently suspended'
--     ENDIF
--
--     ENDIF
--   END
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Check_MatchingCondition
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Apply matching rule to the passed item and passed channel.
--                 This will completely check if the channel match the item.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_item_id                           NUMBER    Required
--                   the id of the item to be matched.
--                 p_channel_id                        NUMBER    Required
--                   the id of the channel to be matched.
--                 p_match_on_author_flag              VARCHAR2  Required
--                   the (pre-query) match_on_author_flag of the channel.
--                 p_match_on_keyword_flag             VARCHAR2  Required
--                   the (pre-query) match_on_keyword_flag of the channel.
--                 p_match_on_perspective_flag         VARCHAR2  Required
--                   the (pre-query) match_on_perspective_flag of the channel.
--                 p_match_on_content_type_flag        VARCHAR2  Required
--                   the (prequery) p_match_on_content_type_flag of the channel.
--                 match_on_item_type_flag             VARCHAR2  Required
--                   the (pre-query) p_match_on_item_type_flag of the channel.
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--                 x_match_flag                       VARCHAR2
--                   The matching result: return FND_API.G_TRUE if matched
--                                        return FND_API.G_FALSE otherwise
--    Notes      :  Compare procedure Check_MatchingCondition
--                          with Check_MatchingCondition2.
--                  Check_MatchingCondition: Use variable static sql statments.
--                  Check_MatchingCondition: Use native dynamic sql statments.
--                     We will test and see which performs better.
--
--
-- End of comments
--
PROCEDURE Check_MatchingCondition
(
    p_api_version                IN  NUMBER,
    p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_check_login_user           IN  VARCHAR2 := FND_API.G_TRUE,
    p_item_id                    IN  NUMBER,
    p_channel_id                 IN  NUMBER,
    p_match_on_author_flag       IN  VARCHAR2,
    p_match_on_keyword_flag      IN  VARCHAR2,
    p_match_on_perspective_flag  IN  VARCHAR2,
    p_match_on_content_type_flag IN  VARCHAR2,
    p_match_on_item_type_flag    IN  VARCHAR2,
    x_match_flag                 OUT NOCOPY  VARCHAR2
);
--
-- Algorithm:
--   BEGIN
--     Verify API version compatibility
--     Check that login user's status is active
--     IF user not active THEN
--       Return error 'user account currently suspended'
--     ENDIF
--
--     ENDIF
--   END
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Check_MatchingCondition2
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Apply matching rule to the passed item and passed channel.
--                 This will completely check if the channel match the item.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_item_id                           NUMBER    Required
--                   the id of the item to be matched.
--                 p_channel_id                        NUMBER    Required
--                   the id of the channel to be matched.
--                 p_match_on_author_flag              VARCHAR2  Required
--                   the (pre-query) match_on_author_flag of the channel.
--                 p_match_on_keyword_flag             VARCHAR2  Required
--                   the (pre-query) match_on_keyword_flag of the channel.
--                 p_match_on_perspective_flag         VARCHAR2  Required
--                   the (pre-query) match_on_perspective_flag of the channel.
--                 p_match_on_content_type_flag        VARCHAR2  Required
--                   the (prequery) p_match_on_content_type_flag of the channel.
--                 match_on_item_type_flag             VARCHAR2  Required
--                   the (pre-query) p_match_on_item_type_flag of the channel.
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--                 x_match_flag                       VARCHAR2
--                   The matching result: return FND_API.G_TRUE if matched
--                                        return FND_API.G_FALSE otherwise
--    Notes      :  Compare procedure Check_MatchingCondition
--                          with Check_MatchingCondition2.
--                  Check_MatchingCondition: Use variable static sql statments.
--                  Check_MatchingCondition: Use native dynamic sql statments.
--                     We will test and see which performs better.
--
--
-- End of comments
--
PROCEDURE Check_MatchingCondition2
(
    p_api_version                IN  NUMBER,
    p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_check_login_user           IN  VARCHAR2 := FND_API.G_TRUE,
    p_item_id                    IN  NUMBER,
    p_channel_id                 IN  NUMBER,
    p_match_on_author_flag       IN  VARCHAR2,
    p_match_on_keyword_flag      IN  VARCHAR2,
    p_match_on_perspective_flag  IN  VARCHAR2,
    p_match_on_content_type_flag IN  VARCHAR2,
    p_match_on_item_type_flag    IN  VARCHAR2,
    x_match_flag                 OUT NOCOPY  VARCHAR2
);
--
-- Algorithm:
--   BEGIN
--     Verify API version compatibility
--     Check that login user's status is active
--     IF user not active THEN
--       Return error 'user account currently suspended'
--     ENDIF
--
--     ENDIF
--   END
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Do_ItemChannelMatch
--    Type       : Private
--    Pre-reqs   : None
--    Function   : do match the passed item with the passed channel.
--                 Check the reqirement of the channel.
--                 Call approval process procedure if needed.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_category_id                       NUMBER    Optional
--                        Default = FND_API.G_MISS_NUM
--                 p_channel_id                        NUMBER    Optional
--                        Default = FND_API.G_MISS_NUM
--                   the id of the channel to be matched. If missing,
--                   the item is pushed to the category identified by
--                   p_category_id.
--                 p_item_id                           NUMBER    Required
--                   the id of the item to be matched.
--                 p_match_type                        VARCHAR2  Required
--                   matching type: by force or by rule.
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Notes      :  Assume  caller has check the validation of item id
--                  and channel id. And the item has NOT yet been match
--                  with the channel.
--
-- End of comments
--
PROCEDURE Do_ItemChannelMatch
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_application_id    IN  NUMBER   := G_AMV_APP_ID,
    p_category_id       IN  NUMBER   := FND_API.G_MISS_NUM,
    p_channel_id        IN  NUMBER   := FND_API.G_MISS_NUM,
    p_item_id           IN  NUMBER,
    p_table_name_code   IN  VARCHAR2,
    p_match_type        IN  VARCHAR2
);
--
-- Algorithm:
--   BEGIN
--     Verify API version compatibility
--     Check that login user's status is active
--     IF user not active THEN
--       Return error 'user account currently suspended'
--     ENDIF
--     Set rollback SAVEPOINT
--
--     Commit transaction if requested
--     ENDIF
--   END
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Do_ItemChannelMatch (Overloaded)
--    Type       : Private
--    Pre-reqs   : None
--    Function   : do match the passed item with the passed channel.
--                 Check the reqirement of the channel.
--                 Call approval process procedure if needed.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_category_id                       NUMBER    Optional
--                        Default = FND_API.G_MISS_NUM
--                 p_channel_id                        NUMBER    Optional
--                        Default = FND_API.G_MISS_NUM
--                   the id of the channel to be matched. If missing,
--                   the item is pushed to the category identified by
--                   p_category_id.
--                 p_item_id                           NUMBER    Required
--                   the id of the item to be matched.
--                 p_match_type                        VARCHAR2  Required
--                   matching type: by force or by rule.
--                 p_territory_tbl                    territory_tbl_type    Optional
--                   territory to which the item is published.
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Notes      :  Assume  caller has check the validation of item id
--                  and channel id. And the item has NOT yet been match
--                  with the channel.
--
-- End of comments
--
PROCEDURE Do_ItemChannelMatch
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_application_id    IN  NUMBER   := G_AMV_APP_ID,
    p_category_id       IN  NUMBER   := FND_API.G_MISS_NUM,
    p_channel_id        IN  NUMBER   := FND_API.G_MISS_NUM,
    p_item_id           IN  NUMBER,
    p_table_name_code   IN  VARCHAR2,
    p_match_type        IN  VARCHAR2,
    p_territory_tbl     IN  terr_id_tbl_type
);
--
-- Algorithm:
--   BEGIN
--     Verify API version compatibility
--     Check that login user's status is active
--     IF user not active THEN
--       Return error 'user account currently suspended'
--     ENDIF
--     Set rollback SAVEPOINT
--
--     Commit transaction if requested
--     ENDIF
--   END
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Remove_ItemChannelMatch
--    Type       : Private
--    Pre-reqs   : None
--    Function   : do match the passed item with the passed channel.
--                 Check the reqirement of the channel.
--                 Call approval process procedure if needed.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_category_id                       NUMBER    Optional
--                        Default = FND_API.G_MISS_NUM
--                 p_channel_id                        NUMBER    Optional
--                        Default = FND_API.G_MISS_NUM
--                   the id of the channel to be matched. If missing,
--                   the item is pushed to the category identified by
--                   p_category_id.
--                 p_item_id                           NUMBER    Required
--                   the id of the item to be matched.
--                 p_match_type                        VARCHAR2  Required
--                   matching type: by force or by rule.
--                 p_territory_id                      NUMBER    Optional
--                   territory to which the item is published.
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Notes      :  Assume  caller has check the validation of item id
--                  and channel id. And the item has NOT yet been match
--                  with the channel.
--
-- End of comments
--
PROCEDURE Remove_ItemChannelMatch
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_application_id    IN  NUMBER   := G_AMV_APP_ID,
    p_category_id       IN  NUMBER   := FND_API.G_MISS_NUM,
    p_channel_id        IN  NUMBER   := FND_API.G_MISS_NUM,
    p_item_id           IN  NUMBER,
    p_table_name_code   IN  VARCHAR2,
    p_territory_id      IN  NUMBER   := FND_API.G_MISS_NUM
);
--
-- Algorithm:
--   BEGIN
--     Verify API version compatibility
--     Check that login user's status is active
--     IF user not active THEN
--       Return error 'user account currently suspended'
--     ENDIF
--     Set rollback SAVEPOINT
--
--     Commit transaction if requested
--     ENDIF
--   END
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_UserTerritory
--    Type       : Private
--    Pre-reqs   : None
--    Function   : return all the territories(id and name) for the specified user.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_resource_id                          NUMBER    Required
--                    This should be the resource id.
--                 p_resource_type                    VARCHAR2 optional
--                    If not passed will be defaulted to 'EMPLOYEE'
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--                 x_terr_id_varray                   AMV_NUMBER_VARRAY_TYPE
--                 x_territory_varray                   AMV_CHAR_VARRAY_TYPE
--    Notes      :
--
-- End of comments
--
PROCEDURE Get_UserTerritory
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_resource_id       IN  NUMBER,
    p_resource_type     IN  VARCHAR2 := 'RS_EMPLOYEE',
    x_terr_id_tbl       OUT NOCOPY  terr_id_tbl_type,
    x_terr_name_tbl     OUT NOCOPY  terr_name_tbl_type
);
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_PublishedTerritories
--    Type       : Private
--    Pre-reqs   : None
--    Function   : return all the territories(id and name) for the specified user.
--    Parameters :
--    IN           p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_terr_id                          NUMBER    Required
--                    The should be the resource id.
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--                 x_item_id_tbl                      territory_tbl_type
--    Notes      :
--
-- End of comments
--
PROCEDURE Get_PublishedTerritories
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_terr_id           IN  NUMBER,
    p_table_name_code   IN  VARCHAR2,
    x_item_id_tbl       OUT NOCOPY  terr_id_tbl_type
);
--
--------------------------------------------------------------------------------
-- Algorithm:
--   BEGIN
--     Verify API version compatibility
--     Check that login user's status is active
--     IF user not active THEN
--       Return error 'user account currently suspended'
--     ENDIF
--     Set rollback SAVEPOINT
--
--     Commit transaction if requested
--     ENDIF
--   END
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
END amv_match_pvt;

 

/
