--------------------------------------------------------
--  DDL for Package AMV_AQ_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMV_AQ_UTILITY_PVT" AUTHID CURRENT_USER AS
/* $Header: amvvaqus.pls 120.1 2005/06/22 17:22:23 appldev ship $ */
-- Start of Comments
--
-- NAME
--   AMV_AQ_UTILITY_PVT
--
-- PURPOSE
--   This package is a private Oracle 8i AQ utility API in AMV.
--   It will hide all the AQ details from the callers and provide high level
--   procedures to other APIs. The callers do not have to know AQ
--   to use this package.
--
--   In case we determine to use better technology, other than AQ, all we
--   need to change is this packgae. Other portions of the match engine
--   remains the same.  However, the AQ has lots of features we might
--   use in later for enhancement. Likely we will continue to use AQ.
--
--   Procedures:
--
--         Add_Queue
--         Delete_Queue
--         Enqueue_Message
--         Dequeue_Message
--
-- NOTES
--
--
-- HISTORY
--   09/17/1999        PWU        CREATED
-- End of Comments
--
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Add_Queue
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Create the AQ table, the AQ itself, and start it.
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
--                 p_queue_table_name                  VARCHAR2  Optional
--                     The underline table used by the AQ queue.
--                     Default 'AMV_MATCHING_QUEUE_TBL'
--                     This procedure is mainly for MES matching engine.
--                     However, we provide it for more general purpose.
--                     The message object to be enqueued to the AQ queue.
--                 p_queue_name                       VARCHAR2  Optional
--                     The underline table used by the AQ queue.
--                     Default 'AMV_MATCHING_QUEUE'
--                 p_payload_obj_type                 VARCHAR2  Optional
--                     The name of the payload (DB object) handled
--                     by the AQ queue.  Default 'AMV_AQ_MSG_OBJECT_TYPE'
--    OUT        : x_return_status                    VARCHAR2
--                 x_msg_count                        NUMBER
--                 x_msg_data                         VARCHAR2
--    Notes      :
--
-- End of comments
--
PROCEDURE Add_Queue
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_queue_table_name  IN  VARCHAR2 := AMV_QUEUE.queue_table_name,
    p_queue_name        IN  VARCHAR2 := AMV_QUEUE.queue_name,
    p_payload_obj_type  IN  VARCHAR2 := 'SYSTEM.AMV_AQ_MSG_OBJECT_TYPE'
);
--
-- Algorithm:
--   BEGIN
--     Verify API version compatibility
--     Check that login user's status is active
--     IF user not active THEN
--       Return error 'user account currently suspended'
--     ENDIF
--     Check that user has administrative privileges
--     IF user not privileged THEN
--       Return error 'User does not have proper privileges.'
--     ENDIF
--     Set rollback SAVEPOINT
--     Call the overloaded version to create the AQ queue and its related obj.
--         The overloaded version check if the AQ table exist.
--            If so, do not try to re-create the table.
--         Same for the AQ queue itself.
--     Commit transaction if requested
--   END
--
--    Notes :
-- End of comments
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Delete_Queue
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Stop the AQ queue, drop it, and then drop the AQ table.
--    Parameters :
--    IN         : p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_queue_table_name                 VARCHAR2  Optional
--                     The underline table used by the AQ queue.
--                     Default 'AMV_MATCHING_QUEUE_TBL'
--                     This procedure is mainly for MES matching engine.
--                     However, we provide it for more general purpose.
--                     The message object to be enqueued to the AQ queue.
--                 p_queue_name                       VARCHAR2  Optional
--                     The underline table used by the AQ queue.
--                     Default 'AMV_MATCHING_QUEUE'
--    OUT        : None
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Note       :
-- End of comments
--
PROCEDURE Delete_Queue
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_queue_table_name  IN  VARCHAR2 := AMV_QUEUE.queue_table_name,
    p_queue_name        IN  VARCHAR2 := AMV_QUEUE.queue_name
);
--
-- Algorithm:
--   BEGIN
--     Verify API version compatibility
--     Check that login user's status is active
--     IF user not active THEN
--       Return error 'user account currently suspended'
--     ENDIF
--     Check that user has administrative privileges
--     IF user not privileged THEN
--       Return error 'User does not have proper privileges.'
--     ENDIF
--     Set rollback SAVEPOINT
--     Call the overloaded version to drop the AQ queue and its related table.
--         The overloaded version check if the AQ queue exist.
--            If not, do not try to drop the queue.
--         Same for the AQ queue table.
--     Commit transaction if requested
--   END
--
-- End of comments
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Enqueue_Message
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Put (enqueue) the message into the AQ queue.
--    Parameters :
--    IN         : p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_queue_table_name                 VARCHAR2  Optional
--                 p_message_obj                      AMV_AQ_MSG_OBJECT_TYPE
--                                                              Required
--                 The message object to be enqueued to the AQ queue.
--    OUT        : None
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Note       :
-- End of comments
--
PROCEDURE Enqueue_Message
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_message_obj       IN  SYSTEM.AMV_AQ_MSG_OBJECT_TYPE
);
--
-- Algorithm:
--   BEGIN
--     Verify API version compatibility
--     Check that login user's status is active
--     IF user not active THEN
--       Return error 'user account currently suspended'
--     ENDIF
--     Check that user has administrative privileges
--     IF user not privileged THEN
--       Return error 'User does not have proper privileges.'
--     ENDIF
--     Set rollback SAVEPOINT
--     Call the overloaded private version to do the job:
--          enqueue the message to the AQ queue.
--     Commit transaction if requested
--   END
--
-- End of comments
--
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Dequeue_Message
--    Type       : Group
--    Pre-reqs   : None
--    Function   : Get (dequeue) a message from the AQ queue.
--    Parameters :
--    IN         : p_api_version                      NUMBER    Required
--                 p_init_msg_list                    VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                           VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level                 NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_check_login_user                 VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for checking user privilege and if user is login.
--                 p_delete_flag                      VARCHAR2  Optional
--                        Default = FND_API.G_TRUE
--                    Flag for delete the message from the queue.
--    OUT        : x_message_obj                      AMV_AQ_MSG_OBJECT_TYPE
--                 The message object to be dequeued from the AQ queue.
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Note       :
-- End of comments
--
PROCEDURE Dequeue_Message
(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    p_check_login_user  IN  VARCHAR2 := FND_API.G_TRUE,
    p_delete_flag       IN  VARCHAR2 := FND_API.G_TRUE,
    x_message_obj       OUT NOCOPY  SYSTEM.AMV_AQ_MSG_OBJECT_TYPE
);
--
-- Algorithm:
--   BEGIN
--     Verify API version compatibility
--     Check that login user's status is active
--     IF user not active THEN
--       Return error 'user account currently suspended'
--     ENDIF
--     Check that user has administrative privileges
--     IF user not privileged THEN
--       Return error 'User does not have proper privileges.'
--     ENDIF
--     Set rollback SAVEPOINT
--     Call the overloaded private version to do the job:
--          enqueue the message to the AQ queue.
--          If p_delete_flag is true, the message is deleted from the queue.
--     Commit transaction if requested
--   END
--
-- End of comments
--
--------------------------------------------------------------------------------
END amv_aq_utility_pvt;

 

/
