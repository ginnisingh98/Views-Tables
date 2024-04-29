--------------------------------------------------------
--  DDL for Package Body AS_SCORECARD_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_SCORECARD_PUB" AS
/* $Header: asxpscdb.pls 115.9 2003/03/28 20:32:54 solin ship $ */

G_PKG_NAME  CONSTANT VARCHAR2(30):= 'AS_SCORECARD_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asxpscdb.pls';


/* begin raverma 01312001
    add params for security check
                p_identity_salesforce_id  IN  NUMBER,
                p_admin_flag              IN  Varchar2(1),
                p_admin_group_id          IN  NUMBER,
    always check update access = 'Y'
*/
-- ffang 050901, add parameter p_check_access_flag
-- from UI, this parameter should be past 'Y'
-- from lead import concurr. program, 'N' should be past

-- this will be the main call of the scoreCard scoring engine
AS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);
AS_DEBUG_ERROR_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_ERROR);

Procedure Get_Score (
    p_api_version             IN  NUMBER := 2.0,
    p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit                  IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level        IN  NUMBER   := AS_UTILITY_PUB.G_VALID_LEVEL_ITEM,
    P_Check_Access_Flag       IN  VARCHAR2 := FND_API.G_MISS_CHAR,
    p_sales_lead_id           IN  NUMBER,
    p_scorecard_id            IN  NUMBER,
-- swkhanna 2260459
    p_marketing_score         IN  NUMBER := 0,
    p_identity_salesforce_id  IN  NUMBER,
    p_admin_flag              IN  Varchar2,
    p_admin_group_id          IN  NUMBER,
    x_rank_id                 OUT NOCOPY NUMBER,
    X_SCORE                   OUT NOCOPY NUMBER,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2 )
IS
    l_api_name               CONSTANT VARCHAR2(30) := 'Get_Score';
    l_api_version_number     CONSTANT NUMBER   := 2.0;
    l_return_status          VARCHAR2(1);
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(32767);

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT GET_SCORE_PUB;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.DEBUG_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'PUB: ' || l_api_name || ' start');
      END IF;
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                           'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- Calling Private package: Create_CARD_RULE
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                   'Public API: Calling AS_SCORECARD_PVT.Get_score');
      END IF;

      -- implement AS_SCORECARD_PVT here
      AS_SCORECARD_PVT.Get_Score (
          p_api_version             => 2.0,
          p_init_msg_list           => FND_API.G_FALSE,
          p_commit                  => FND_API.G_FALSE,  -- p_commit,
          p_validation_level        => p_validation_level,
          p_check_access_flag       => p_check_access_flag,
          p_sales_lead_id           => p_sales_lead_id,
          p_scorecard_id            => p_scorecard_id,
-- swkhanna 2260459
          p_marketing_score         => p_marketing_score,
          p_identity_salesforce_id  => p_identity_salesforce_id,
          p_admin_flag              => p_admin_flag,
          p_admin_group_id          => p_admin_group_id,
          x_rank_id                 => x_rank_id,
          X_SCORE                   => x_score,
          x_return_status           => x_return_status,
          x_msg_count               => l_msg_count,
          x_msg_data                => l_msg_data);


      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Debug Message
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.DEBUG_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'PUB: ' || l_api_name || ' end');
      END IF;
      IF (AS_DEBUG_LOW_ON) THEN

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'End time:'
                                   || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              as_utility_pvt.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              as_utility_pvt.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              as_utility_pvt.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => as_utility_pvt.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

END Get_Score;


END AS_SCORECARD_PUB;

/
