--------------------------------------------------------
--  DDL for Package AS_ATA_UHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_ATA_UHK" AUTHID CURRENT_USER AS
/* $Header: asxcatas.pls 120.0 2005/06/02 17:20:40 appldev noship $ */

-- Start of Comments
-- Package Name     : AS_ATA_UHK
--
-- Purpose          : If user want to implement custom territory assignment
--                    logic, create a package body for this spec.
--
-- NOTE             : Please do not 'commit' in the package body. Once the
--                    transaction is completed, Oracle Application code will
--                    issue a commit.
--
--                    This user hooks will be called before/after Assign
--                    Territory Accesses
--
-- History          :
--       06/13/2002   FFANG   Created
--
-- End of Comments

/*-------------------------------------------------------------------------*
 |
 |                             PUBLIC CONSTANTS
 |
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |
 |                             PUBLIC DATATYPES
 |
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |
 |                             PUBLIC VARIABLES
 |
 *-------------------------------------------------------------------------*/

/*-------------------------------------------------------------------------*
 |
 |                             PUBLIC ROUTINES
 |
 *-------------------------------------------------------------------------*/

-- Start of Comments
--
--   API name   : ATA_Pre
--   Parameters :
--   IN         :
--       p_api_version_number: For 11i Oracle Sales application, this is 2.0.
--       p_init_msg_list     : Initialize message stack or not. It's
--                             FND_API.G_FALSE by default.
--       p_validation_level  : Validation level for pass-in values.
--                             It's FND_API.G_VALID_LEVEL_FULL by default.
--       p_commit            : Whether commit the whole API at the end of API.
--                             It's FND_API.G_FALSE by default.
--
--                             The above four parameters are standard input.
--
--   IN         :
--       p_param1            :
--       p_param2            :
--       p_param3            :
--
--   OUT        :
--       x_return_status     :
--                             The return status. If your code completes
--                             successfully, then FND_API.G_RET_STS_SUCCESS
--                             should be returned; if you get an expected error,
--                             then return FND_API.G_RET_STS_ERROR; otherwise
--                             return FND_API.G_RET_STS_UNEXP_ERROR.
--       x_msg_count         :
--                             The message count.
--                             Call FND_MSG_PUB.Count_And_Get to get the message
--                             count and messages.
--       x_msg_data          :
--                             The messages.
--                             Call FND_MSG_PUB.Count_And_Get to get the message
--                             count and messages.
--
--                             The above three parameters are standard output
--                             parameters.
--
PROCEDURE ATA_Pre(
    p_api_version_number    IN      NUMBER,
    p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE,
    p_validation_level      IN      VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
    p_commit                IN      VARCHAR2 := FND_API.G_FALSE,
    p_param1                IN      VARCHAR2,
    p_param2                IN      VARCHAR2,
    p_param3                IN      VARCHAR2,
    x_return_status         OUT NOCOPY    VARCHAR2,
    x_msg_count             OUT NOCOPY    NUMBER,
    x_msg_data              OUT NOCOPY    VARCHAR2);


-- Start of Comments
--
--   API name   : ATA_Post
--   Parameters :
--   IN         :
--       p_api_version_number: For 11i Oracle Sales application, this is 2.0.
--       p_init_msg_list     : Initialize message stack or not. It's
--                             FND_API.G_FALSE by default.
--       p_validation_level  : Validation level for pass-in values.
--                             It's FND_API.G_VALID_LEVEL_FULL by default.
--       p_commit            : Whether commit the whole API at the end of API.
--                             It's FND_API.G_FALSE by default.
--
--                             The above four parameters are standard input.
--
--   IN         :
--       p_param1            :
--       p_param2            :
--       p_param3            :
--
--   OUT        :
--       x_return_status     :
--                             The return status. If your code completes
--                             successfully, then FND_API.G_RET_STS_SUCCESS
--                             should be returned; if you get an expected error,
--                             then return FND_API.G_RET_STS_ERROR; otherwise
--                             return FND_API.G_RET_STS_UNEXP_ERROR.
--       x_msg_count         :
--                             The message count.
--                             Call FND_MSG_PUB.Count_And_Get to get the message
--                             count and messages.
--       x_msg_data          :
--                             The messages.
--                             Call FND_MSG_PUB.Count_And_Get to get the message
--                             count and messages.
--
--                             The above three parameters are standard output
--                             parameters.
--
PROCEDURE ATA_Post(
    p_api_version_number    IN      NUMBER,
    p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE,
    p_validation_level      IN      VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
    p_commit                IN      VARCHAR2 := FND_API.G_FALSE,
    p_param1                IN      VARCHAR2,
    p_param2                IN      VARCHAR2,
    p_param3                IN      VARCHAR2,
    p_request_id            IN      NUMBER,
    x_return_status         OUT NOCOPY    VARCHAR2,
    x_msg_count             OUT NOCOPY    NUMBER,
    x_msg_data              OUT NOCOPY    VARCHAR2);


END AS_ATA_UHK;


 

/
