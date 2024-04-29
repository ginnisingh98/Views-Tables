--------------------------------------------------------
--  DDL for Package Body AS_SCORECARD_RULES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_SCORECARD_RULES_PUB" AS
/* $Header: asxpscob.pls 120.1 2005/06/24 16:56:39 appldev ship $ */

G_PKG_NAME  CONSTANT VARCHAR2(30):= 'AS_SCORECARD_RULES_PUB';
G_FILE_NAME CONSTANT VARCHAR2(16) := 'asxpscob.pls';


  -- *****************************************************
  -- FOR AS_SCORECARD_RULES_PUB
  FUNCTION Init_AS_SCORECARD_Rec RETURN AS_SCORECARD_RULES_PUB.SCORECARD_REC_TYPE IS
      l_return_rec AS_SCORECARD_RULES_PUB.SCORECARD_REC_TYPE ;
  BEGIN
      l_return_rec := AS_SCORECARD_RULES_PUB.G_MISS_SCORECARD_REC;
      RETURN l_return_rec ;
  END;


  FUNCTION Init_AS_CARDRULE_QUAL_Rec RETURN AS_SCORECARD_RULES_PUB.CARDRULE_QUAL_REC_TYPE IS
      l_return_rec AS_SCORECARD_RULES_PUB.CARDRULE_QUAL_REC_TYPE;
  BEGIN
      l_return_rec := AS_SCORECARD_RULES_PUB.G_MISS_CARDRULE_QUAL_REC;
      RETURN l_return_rec ;
  END;

  FUNCTION Init_AS_CARDRULE_QUAL_Tbl RETURN AS_SCORECARD_RULES_PUB.CARDRULE_QUAL_Tbl_TYPE IS
      l_return_rec AS_SCORECARD_RULES_PUB.CARDRULE_QUAL_Tbl_TYPE;
  BEGIN
      l_return_rec := AS_SCORECARD_RULES_PUB.G_MISS_CARDRULE_QUAL_TBL;
      RETURN l_return_rec ;
  END;


Procedure Create_ScoreCard (
    p_api_version       IN  NUMBER := 2.0,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level  IN  NUMBER  := AS_UTILITY_PUB.G_VALID_LEVEL_ITEM,
    x_return_status     OUT NOCOPY  VARCHAR2,
    x_msg_count         OUT NOCOPY  NUMBER,
    x_msg_data          OUT NOCOPY  VARCHAR2,
    P_SCORECARD_REC     IN  AS_SCORECARD_RULES_PUB.SCORECARD_REC_TYPE
                              := G_MISS_SCORECARD_REC,
    X_SCORECARD_ID     OUT NOCOPY  NUMBER)
IS
    l_api_name             CONSTANT VARCHAR2(30) := 'Create_ScoreCard';
    l_api_version_number   CONSTANT NUMBER   := 2.0;
    l_return_status   VARCHAR2(1);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(32767);

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_SCORECARD_PUB;

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
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'Public API: ' || l_api_name || 'start');

      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                           'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- Calling Private package: Create_SALES_LEADS
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                   'Public API: Calling AS_SCORECARD_RULES_PVT.Create_Scorecard');

      AS_SCORECARD_RULES_PVT.Create_ScoreCard(
         p_api_version              => p_api_version
       , p_init_msg_list            => FND_API.G_FALSE
       , p_commit                   => p_commit
       , p_validation_level         => p_validation_level
       , p_scorecard_rec            => p_scorecard_rec
       , x_scorecard_id             => x_scorecard_id
       , x_return_status            => x_return_status
       , x_msg_count                => x_msg_count
       , x_msg_data                 => x_msg_data
       );


      IF x_return_status = FND_API.G_RET_STS_ERROR then
                raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
               raise FND_API.G_EXC_UNEXPECTED_ERROR;
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
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'PUB: ' || l_api_name || ' end');
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'End time:'
                                   || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

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


END CREATE_SCORECARD;



Procedure Update_ScoreCard (
    p_api_version             IN NUMBER := 2.0,
    p_init_msg_list           IN VARCHAR2 := FND_API.G_FALSE,
    p_commit                  IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_level        IN NUMBER := AS_UTILITY_PUB.G_VALID_LEVEL_ITEM,
    x_return_status           OUT NOCOPY  VARCHAR2,
    x_msg_count               OUT NOCOPY  NUMBER,
    x_msg_data                OUT NOCOPY  VARCHAR2,
    P_SCORECARD_REC           IN AS_SCORECARD_RULES_PUB.SCORECARD_REC_TYPE
                                                          := G_MISS_SCORECARD_REC)
IS
    l_api_name                CONSTANT VARCHAR2(30) := 'Update_ScoreCard';
    l_api_version_number      CONSTANT NUMBER   := 2.0;
    l_return_status   VARCHAR2(1);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(32767);

BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_SCORECARD_PUB;

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
      AS_UTILITY_PVT.DEBUG_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'PUB: ' || l_api_name || ' start');
      AS_UTILITY_PVT.DEBUG_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                           'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --

      -- Debug Message
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                   'Public API: Calling AS_SALES_LEADS_PVT.Update_sales_lead');

      AS_SCORECARD_RULES_PVT.Update_ScoreCard(
         p_api_version              => p_api_version
       , p_init_msg_list            => p_init_msg_list
       , p_commit                   => p_commit
       , p_validation_level         => p_validation_level
       , p_scorecard_rec            => p_scorecard_rec
       , x_return_status            => x_return_status
       , x_msg_count                => x_msg_count
       , x_msg_data                 => x_msg_data
       );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Debug Message
      AS_UTILITY_PVT.DEBUG_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'PUB: ' || l_api_name || ' end');
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'End time:'
                                   || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

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

END Update_ScoreCard;



Procedure Delete_ScoreCard (
    p_api_version             IN NUMBER := 2.0,
    p_init_msg_list           IN VARCHAR2 := FND_API.G_FALSE,
    p_commit                  IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_level        IN NUMBER := AS_UTILITY_PUB.G_VALID_LEVEL_ITEM,
    x_return_status           OUT NOCOPY  VARCHAR2,
    x_msg_count               OUT NOCOPY  NUMBER,
    x_msg_data                OUT NOCOPY  VARCHAR2,
    P_SCORECARD_ID            IN NUMBER)
IS

    l_api_name               CONSTANT VARCHAR2(30) := 'Delete_ScoreCard';
    l_api_version_number     CONSTANT NUMBER   := 2.0;
    l_return_status   VARCHAR2(1);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(32767);
    l_scorecard_id    NUMBER := P_scorecard_id;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_SCORECARD_PUB;

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
      AS_UTILITY_PVT.DEBUG_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'PUB:' || l_api_name || 'start');
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                           'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --

      AS_UTILITY_PVT.DEBUG_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                   'Public API: Calling AS_SCORECARD_RULES_PVT.Delete_SCORECARD');

      AS_SCORECARD_RULES_PVT.Delete_ScoreCard(
              p_api_version              => p_api_version
            , p_init_msg_list            => p_init_msg_list
            , p_commit                   => p_commit
            , p_validation_level         => p_validation_level
            , p_scorecard_id             => l_scorecard_id
            , x_return_status            => l_return_status
            , x_msg_count                => l_msg_count
            , x_msg_data                 => l_msg_data
            );
--shdeshpa
-- delete from as_scorecard_qual_rules where scorecard_id = p_scorecard_id

      IF x_return_status = FND_API.G_RET_STS_ERROR then
                raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
               raise FND_API.G_EXC_UNEXPECTED_ERROR;
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
      AS_UTILITY_PVT.DEBUG_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'PUB: ' || l_api_name || ' end');
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'End time:'
                                   || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

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

END Delete_ScoreCard;


Procedure Create_CardRule_QUAL (
    p_api_version             IN NUMBER := 2.0,
    p_init_msg_list           IN VARCHAR2 := FND_API.G_FALSE,
    p_commit                  IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_level        IN NUMBER := AS_UTILITY_PUB.G_VALID_LEVEL_ITEM,
    x_return_status           OUT NOCOPY  VARCHAR2,
    x_msg_count               OUT NOCOPY  NUMBER,
    x_msg_data                OUT NOCOPY  VARCHAR2,
    p_CardRule_Qual_rec       IN AS_SCORECARD_RULES_PUB.CARDRULE_QUAL_REC_TYPE,
    x_qual_value_id           OUT NOCOPY  NUMBER)
IS
    l_api_name                CONSTANT VARCHAR2(30) := 'Create_CardRule_QUAL';
    l_api_version_number      CONSTANT NUMBER   := 2.0;
    l_return_status   VARCHAR2(1);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(32767);

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_CARD_RULE_PUB;

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
      AS_UTILITY_PVT.DEBUG_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'PUB: ' || l_api_name || ' start');
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                           'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- Calling Private package: Create_SALES_LEADS
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                   'Public API: Calling AS_SCORECARD_RULES_PVT.Create_CardRule_Qual');

      AS_SCORECARD_RULES_PVT.Create_CardRule_Qual(
         p_api_version              => p_api_version
       , p_init_msg_list            => FND_API.G_FALSE
       , p_commit                   => p_commit
       , p_validation_level         => p_validation_level
       , p_cardrule_qual_rec        => p_cardrule_qual_rec
       , x_qual_value_id            => x_qual_value_id
       , x_return_status            => x_return_status
       , x_msg_count                => x_msg_count
       , x_msg_data                 => x_msg_data
       );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
               raise FND_API.G_EXC_UNEXPECTED_ERROR;
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
      AS_UTILITY_PVT.DEBUG_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'PUB: ' || l_api_name || ' end');
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'End time:'
                                   || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

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

END Create_CardRule_Qual;



Procedure Update_CardRule_QUAL (
    p_api_version             IN NUMBER := 2.0,
    p_init_msg_list           IN VARCHAR2 := FND_API.G_FALSE,
    p_commit                  IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_level        IN NUMBER := AS_UTILITY_PUB.G_VALID_LEVEL_ITEM,
    x_return_status           OUT NOCOPY  VARCHAR2,
    x_msg_count               OUT NOCOPY  NUMBER,
    x_msg_data                OUT NOCOPY  VARCHAR2,
    p_CardRule_Qual_rec       IN AS_SCORECARD_RULES_PUB.CARDRULE_QUAL_REC_TYPE)
IS
    l_api_name                CONSTANT VARCHAR2(30) := 'Update_CARDRULE_QUAL';
    l_api_version_number      CONSTANT NUMBER   := 2.0;
    l_return_status   VARCHAR2(1);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(32767);

BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_CARDRULE_QUAL_PUB;

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
      AS_UTILITY_PVT.DEBUG_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'PUB: ' || l_api_name || ' start');
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                           'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --

      -- Debug Message
      AS_UTILITY_PVT.DEBUG_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                   'Public API: Calling AS_SCORECARD_RULES_PVT.Update_CardRule_Qual');


      AS_SCORECARD_RULES_PVT.Update_CardRule_Qual(
         p_api_version              => p_api_version
       , p_init_msg_list            => FND_API.G_FALSE
       , p_commit                   => p_commit
       , p_validation_level         => p_validation_level
       , p_cardrule_qual_rec        => p_cardrule_qual_rec
       , x_return_status            => x_return_status
       , x_msg_count                => x_msg_count
       , x_msg_data                 => x_msg_data
       );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
               raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Debug Message
      AS_UTILITY_PVT.DEBUG_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'PUB: ' || l_api_name || ' end');
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'End time:'
                                   || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

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
END Update_CardRule_Qual;



-- pass in the qual value Id
Procedure Delete_CardRule_QUAL (
    p_api_version             IN NUMBER := 2.0,
    p_init_msg_list           IN VARCHAR2 := FND_API.G_FALSE,
    p_commit                  IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_level        IN NUMBER := AS_UTILITY_PUB.G_VALID_LEVEL_ITEM,
    x_return_status           OUT NOCOPY  VARCHAR2,
    x_msg_count               OUT NOCOPY  NUMBER,
    x_msg_data                OUT NOCOPY  VARCHAR2,
    p_qual_value_id           IN NUMBER)
IS
    l_api_name                CONSTANT VARCHAR2(30) := 'Delete_CARDRULE_QUAL';
    l_api_version_number      CONSTANT NUMBER   := 2.0;
    l_return_status   VARCHAR2(1);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(32767);

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_CARD_RULE_PUB;

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
      AS_UTILITY_PVT.DEBUG_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'PUB:' || l_api_name || 'start');
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                           'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --

      AS_UTILITY_PVT.DEBUG_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                   'Public API: Calling AS_SCORECARD_RULES_PVT.Delete_CardRule_Qual');

      AS_SCORECARD_RULES_PVT.Delete_CardRule_Qual(
         p_api_version              => p_api_version
       , p_init_msg_list            => FND_API.G_FALSE
       , p_commit                   => p_commit
       , p_validation_level         => p_validation_level
       , p_qual_value_id            => p_qual_value_id
       , x_return_status            => x_return_status
       , x_msg_count                => x_msg_count
       , x_msg_data                 => x_msg_data
       );

      IF x_return_status = FND_API.G_RET_STS_ERROR then
                raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
               raise FND_API.G_EXC_UNEXPECTED_ERROR;
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
      AS_UTILITY_PVT.DEBUG_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                                   'PUB: ' || l_api_name || ' end');
      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'End time:'
                                   || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

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

END Delete_CardRule_Qual;



END AS_SCORECARD_RULES_PUB;

/
