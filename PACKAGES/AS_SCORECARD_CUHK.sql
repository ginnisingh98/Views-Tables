--------------------------------------------------------
--  DDL for Package AS_SCORECARD_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_SCORECARD_CUHK" AUTHID CURRENT_USER AS
/* $Header: asxcscds.pls 115.6 2002/11/06 00:40:32 appldev ship $ */

-- Start of Comments
-- Package Name     : AS_SCORECARD_CUHK
--
-- Purpose          : If user want to implement custom scoring engine, create
--                    a package body for this spec.
--
-- NOTE             : Please do not 'commit' in the package body. Once the
--                    transaction is completed, Oracle Application code will
--                    issue a commit.
--
--                    This user hook will be called while creating and updating
--                    lead from OSO leads tab, Telesales leads tab, and lead
--                    import program when scoring engine is called.
--                    The calling package: AS_SCORECARD_PVT.Get_Score
--
-- History          :
--       08/14/2001   SOLIN   Created
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
--   API name   : Get_Score_Pre
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
--       p_sales_lead_id     :
--                             This is the sales lead identifier. Pass the
--                             sales_lead_id which you want to compute the
--                             score.
--       p_scorecard_id      :
--                             Pass the scorecard_id of the scorecard which
--                             you want to use for scoring the lead.
--   OUT        :
--       x_score             :
--                             This is the score of the lead. User's score
--                             engine should return this score and Oracle API
--                             will rank the lead base on this score.
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
PROCEDURE Get_Score_Pre(
    p_api_version_number    IN  NUMBER,
    p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level      IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
    p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
    p_sales_lead_id         IN  NUMBER,
    p_scorecard_id          IN  NUMBER,
    x_score                 OUT NUMBER,
    x_return_status         OUT VARCHAR2,
    x_msg_count             OUT NUMBER,
    x_msg_data              OUT VARCHAR2);


END AS_SCORECARD_CUHK;


 

/
