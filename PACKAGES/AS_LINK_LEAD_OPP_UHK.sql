--------------------------------------------------------
--  DDL for Package AS_LINK_LEAD_OPP_UHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_LINK_LEAD_OPP_UHK" AUTHID CURRENT_USER AS
/* $Header: asxclnks.pls 115.1 2002/11/15 01:37:04 axavier ship $ */

-- Start of Comments
-- Package Name     : AS_LINK_LEAD_OPP_UHK
--
-- Purpose          : If user want to implement custom link lead to opportunity
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
--       07/01/2002   FFANG   Created
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
--   API name   : Copy_Lead_To_Opp_Pre
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
--       p_sales_lead_id     : sales lead ID
--       p_opportunity_id    : opportunity ID
--
--   OUT        :
--       x_return_status     : The return status. If your code completes
--                             successfully, then FND_API.G_RET_STS_SUCCESS
--                             should be returned; if you get an expected error,
--                             then return FND_API.G_RET_STS_ERROR; otherwise
--                             return FND_API.G_RET_STS_UNEXP_ERROR.
--       x_msg_count         : The message count.
--                             Call FND_MSG_PUB.Count_And_Get to get the message
--                             count and messages.
--       x_msg_data          : The messages.
--                             Call FND_MSG_PUB.Count_And_Get to get the message
--                             count and messages.
--
--                             The above three parameters are standard output
--                             parameters.
--
PROCEDURE Copy_Lead_To_Opp_Pre(
    p_api_version_number    IN      NUMBER,
    p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE,
    p_validation_level      IN      VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
    p_commit                IN      VARCHAR2 := FND_API.G_FALSE,
    P_SALES_LEAD_ID         IN      NUMBER,
    P_OPPORTUNITY_ID        IN      NUMBER,
    x_return_status         OUT NOCOPY    VARCHAR2,
    x_msg_count             OUT NOCOPY    NUMBER,
    x_msg_data              OUT NOCOPY    VARCHAR2);



-- Start of Comments
--
--   API name   : Copy_Lead_To_Opp_Post
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
--       p_sales_lead_id     : sales lead ID
--       p_opportunity_id    : opportunity ID
--
--   OUT        :
--       x_return_status     : The return status. If your code completes
--                             successfully, then FND_API.G_RET_STS_SUCCESS
--                             should be returned; if you get an expected error,
--                             then return FND_API.G_RET_STS_ERROR; otherwise
--                             return FND_API.G_RET_STS_UNEXP_ERROR.
--       x_msg_count         : The message count.
--                             Call FND_MSG_PUB.Count_And_Get to get the message
--                             count and messages.
--       x_msg_data          : The messages.
--                             Call FND_MSG_PUB.Count_And_Get to get the message
--                             count and messages.
--
--                             The above three parameters are standard output
--                             parameters.
--
PROCEDURE Copy_Lead_To_Opp_Post(
    p_api_version_number    IN      NUMBER,
    p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE,
    p_validation_level      IN      VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
    p_commit                IN      VARCHAR2 := FND_API.G_FALSE,
    P_SALES_LEAD_ID         IN      NUMBER,
    P_OPPORTUNITY_ID        IN      NUMBER,
    x_return_status         OUT NOCOPY    VARCHAR2,
    x_msg_count             OUT NOCOPY    NUMBER,
    x_msg_data              OUT NOCOPY    VARCHAR2);



-- Start of Comments
--
--   API name   : Link_Lead_To_Opp_Pre
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
--       p_sales_lead_id     : sales lead ID
--       p_opportunity_id    : opportunity ID
--
--   OUT        :
--       x_return_status     : The return status. If your code completes
--                             successfully, then FND_API.G_RET_STS_SUCCESS
--                             should be returned; if you get an expected error,
--                             then return FND_API.G_RET_STS_ERROR; otherwise
--                             return FND_API.G_RET_STS_UNEXP_ERROR.
--       x_msg_count         : The message count.
--                             Call FND_MSG_PUB.Count_And_Get to get the message
--                             count and messages.
--       x_msg_data          : The messages.
--                             Call FND_MSG_PUB.Count_And_Get to get the message
--                             count and messages.
--
--                             The above three parameters are standard output
--                             parameters.
--
PROCEDURE Link_Lead_To_Opp_Pre(
    p_api_version_number    IN      NUMBER,
    p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE,
    p_validation_level      IN      VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
    p_commit                IN      VARCHAR2 := FND_API.G_FALSE,
    P_SALES_LEAD_ID         IN      NUMBER,
    P_OPPORTUNITY_ID        IN      NUMBER,
    x_return_status         OUT NOCOPY    VARCHAR2,
    x_msg_count             OUT NOCOPY    NUMBER,
    x_msg_data              OUT NOCOPY    VARCHAR2);



-- Start of Comments
--
--   API name   : Link_Lead_To_Opp_Post
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
--       p_sales_lead_id     : sales lead ID
--       p_opportunity_id    : opportunity ID
--
--   OUT        :
--       x_return_status     : The return status. If your code completes
--                             successfully, then FND_API.G_RET_STS_SUCCESS
--                             should be returned; if you get an expected error,
--                             then return FND_API.G_RET_STS_ERROR; otherwise
--                             return FND_API.G_RET_STS_UNEXP_ERROR.
--       x_msg_count         : The message count.
--                             Call FND_MSG_PUB.Count_And_Get to get the message
--                             count and messages.
--       x_msg_data          : The messages.
--                             Call FND_MSG_PUB.Count_And_Get to get the message
--                             count and messages.
--
--                             The above three parameters are standard output
--                             parameters.
--
PROCEDURE Link_Lead_To_Opp_Post(
    p_api_version_number    IN      NUMBER,
    p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE,
    p_validation_level      IN      VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
    p_commit                IN      VARCHAR2 := FND_API.G_FALSE,
    P_SALES_LEAD_ID         IN      NUMBER,
    P_OPPORTUNITY_ID        IN      NUMBER,
    x_return_status         OUT NOCOPY    VARCHAR2,
    x_msg_count             OUT NOCOPY    NUMBER,
    x_msg_data              OUT NOCOPY    VARCHAR2);



-- Start of Comments
--
--   API name   : Create_Opp_For_Lead_Pre
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
--       p_sales_lead_id     : sales lead ID
--       p_opportunity_id    : opportunity ID
--
--   OUT        :
--       x_return_status     : The return status. If your code completes
--                             successfully, then FND_API.G_RET_STS_SUCCESS
--                             should be returned; if you get an expected error,
--                             then return FND_API.G_RET_STS_ERROR; otherwise
--                             return FND_API.G_RET_STS_UNEXP_ERROR.
--       x_msg_count         : The message count.
--                             Call FND_MSG_PUB.Count_And_Get to get the message
--                             count and messages.
--       x_msg_data          : The messages.
--                             Call FND_MSG_PUB.Count_And_Get to get the message
--                             count and messages.
--
--                             The above three parameters are standard output
--                             parameters.
--
PROCEDURE Create_Opp_For_Lead_Pre(
    p_api_version_number    IN      NUMBER,
    p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE,
    p_validation_level      IN      VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
    p_commit                IN      VARCHAR2 := FND_API.G_FALSE,
    P_SALES_LEAD_ID         IN      NUMBER,
    P_OPPORTUNITY_ID        IN      NUMBER,
    x_return_status         OUT NOCOPY    VARCHAR2,
    x_msg_count             OUT NOCOPY    NUMBER,
    x_msg_data              OUT NOCOPY    VARCHAR2);



-- Start of Comments
--
--   API name   : Create_Opp_For_Lead_Post
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
--       p_sales_lead_id     : sales lead ID
--       p_opportunity_id    : opportunity ID
--
--   OUT        :
--       x_return_status     : The return status. If your code completes
--                             successfully, then FND_API.G_RET_STS_SUCCESS
--                             should be returned; if you get an expected error,
--                             then return FND_API.G_RET_STS_ERROR; otherwise
--                             return FND_API.G_RET_STS_UNEXP_ERROR.
--       x_msg_count         : The message count.
--                             Call FND_MSG_PUB.Count_And_Get to get the message
--                             count and messages.
--       x_msg_data          : The messages.
--                             Call FND_MSG_PUB.Count_And_Get to get the message
--                             count and messages.
--
--                             The above three parameters are standard output
--                             parameters.
--
PROCEDURE Create_Opp_For_Lead_Post(
    p_api_version_number    IN      NUMBER,
    p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE,
    p_validation_level      IN      VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
    p_commit                IN      VARCHAR2 := FND_API.G_FALSE,
    P_SALES_LEAD_ID         IN      NUMBER,
    P_OPPORTUNITY_ID        IN      NUMBER,
    x_return_status         OUT NOCOPY    VARCHAR2,
    x_msg_count             OUT NOCOPY    NUMBER,
    x_msg_data              OUT NOCOPY    VARCHAR2);


End AS_LINK_LEAD_OPP_UHK;

 

/
