--------------------------------------------------------
--  DDL for Package Body IEX_STATUS_RULE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_STATUS_RULE_PUB" AS
/* $Header: iexpcstb.pls 120.1 2006/05/30 17:25:42 scherkas noship $ */


G_PKG_NAME  CONSTANT VARCHAR2(30):= 'IEX_STATUS_RULE_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'iexpcstb.pls';


PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));

Procedure Create_Status_Rule
           (p_api_version             IN NUMBER,
            p_init_msg_list           IN VARCHAR2,
            p_commit                  IN VARCHAR2,
            p_status_rule_rec         IN iex_status_rule_pub.status_rule_rec_type,
            x_dup_status              OUT NOCOPY VARCHAR2,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2,
            x_status_rule_id          OUT NOCOPY NUMBER)

IS
    l_api_name                    CONSTANT VARCHAR2(30) := 'Create_Status_Rule';
    l_api_version_number          CONSTANT NUMBER   := 1.0;
    l_return_status               VARCHAR2(1);
    l_msg_count                   NUMBER;
    l_msg_data                    VARCHAR2(32767);

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Create_Status_Rule_PUB;

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
      IEX_DEBUG_PUB.LogMessage('Public API: ' || l_api_name || ' start');

      IEX_DEBUG_PUB.LogMessage('Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      IEX_DEBUG_PUB.LogMessage('Public API: Calling IEX_STATUS_RULE_PVT.Create_Status_Rule');

      IEX_STATUS_RULE_PVT.Create_Status_Rule(
         p_api_version              => p_api_version
       , p_init_msg_list            => FND_API.G_FALSE
       , p_commit                   => p_commit
       , p_status_rule_rec          => p_status_rule_rec
       , x_status_rule_id                  => x_status_rule_id
       , x_dup_status               => x_dup_status
       , x_return_status            => x_return_status
       , x_msg_count                => x_msg_count
       , x_msg_data                 => x_msg_data);

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
      IEX_DEBUG_PUB.LogMessage('PUB: ' || l_api_name || ' end');
      IEX_DEBUG_PUB.LogMessage('End time:'
                                   || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK TO Create_Status_Rule_PUB;
              x_return_status := FND_API.G_RET_STS_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );
		    /*
              as_utility_pvt.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
               */

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK TO Create_Status_Rule_PUB;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );
		    /*
              as_utility_pvt.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
               */

          WHEN OTHERS THEN
              ROLLBACK TO Create_Status_Rule_PUB;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );
		    /*
              as_utility_pvt.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => as_utility_pvt.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
               */


END Create_Status_Rule;



Procedure Update_Status_Rule
	   (p_api_version             IN NUMBER,
            p_init_msg_list           IN VARCHAR2,
            p_commit                  IN VARCHAR2,
            p_status_rule_tbl         IN iex_status_rule_pub.status_rule_tbl_type,
            x_dup_status              OUT NOCOPY VARCHAR2,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2)
IS
    l_api_name                    CONSTANT VARCHAR2(30) := 'Update_Status_Rule';
    l_api_version_number          CONSTANT NUMBER   := 1.0;
    l_return_status               VARCHAR2(1);
    l_msg_count                   NUMBER;
    l_msg_data                    VARCHAR2(32767);
    l_status_rule_rec                   iex_status_rule_pub.status_rule_rec_type;

BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT Update_Status_Rule_PUB;

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
      IEX_DEBUG_PUB.LogMessage('PUB: ' || l_api_name || ' start');
      IEX_DEBUG_PUB.LogMessage('Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --

      -- Debug Message
      IEX_DEBUG_PUB.LogMessage('Public API: Calling IEX_STATUS_RULE_PVT.Update_Status_Rule');

      for i in 1..p_status_rule_tbl.count
      LOOP
          l_status_rule_rec := p_status_rule_tbl(i);

          IEX_STATUS_RULE_PVT.Update_Status_Rule(
            p_api_version              => p_api_version
          , p_init_msg_list            => p_init_msg_list
          , p_commit                   => p_commit
          , p_status_rule_rec          => l_status_rule_rec
          , x_dup_status               => x_dup_status
          , x_return_status            => x_return_status
          , x_msg_count                => x_msg_count
          , x_msg_data                 => x_msg_data
          );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             RAISE FND_API.G_EXC_ERROR;
          elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
             raise FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

      END LOOP;
      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Debug Message
      IEX_DEBUG_PUB.LogMessage('PUB: ' || l_api_name || ' end');
      IEX_DEBUG_PUB.LogMessage('End time:'
                                   || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK TO Update_Status_Rule_PUB;
              x_return_status := FND_API.G_RET_STS_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );
		    /*
              as_utility_pvt.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
              */

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK TO Update_Status_Rule_PUB;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );
		    /*
              as_utility_pvt.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
              */

          WHEN OTHERS THEN
              ROLLBACK TO Update_Status_Rule_PUB;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );
		    /*
              as_utility_pvt.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => as_utility_pvt.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
              */

END Update_Status_Rule;



Procedure Delete_Status_Rule
           (p_api_version             IN NUMBER,
            p_init_msg_list           IN VARCHAR2,
            p_commit                  IN VARCHAR2,
            p_status_rule_id_tbl             IN iex_status_rule_pub.status_rule_id_TBL_type,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2)

IS

    l_status_rule_id              NUMBER;
    l_api_name              CONSTANT VARCHAR2(30) := 'Delete_Status_Rule';
    l_api_version_number    CONSTANT NUMBER   := 1.0;
    l_return_status         VARCHAR2(1);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(32767);

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Delete_Status_Rule_PUB;

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
      IEX_DEBUG_PUB.LogMessage('PUB:' || l_api_name || ' start');
      IEX_DEBUG_PUB.LogMessage('Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --

      IEX_DEBUG_PUB.LogMessage('Public API: Calling IEX_STATUS_RULE_PVT.Delete_Status_Rule');

      for i in 1..p_status_rule_id_tbl.count
      loop
         l_status_rule_id := p_status_rule_id_tbl(i);

         IEX_STATUS_RULE_PVT.Delete_Status_Rule(
              p_api_version              => p_api_version
            , p_init_msg_list            => p_init_msg_list
            , p_commit                   => p_commit
            , p_status_rule_id                  => l_status_rule_id
            , x_return_status            => l_return_status
            , x_msg_count                => l_msg_count
            , x_msg_data                 => l_msg_data
            );

         IF x_return_status = FND_API.G_RET_STS_ERROR then
                raise FND_API.G_EXC_ERROR;
         elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
               raise FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

      END loop;

      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Debug Message
      IEX_DEBUG_PUB.LogMessage('PUB: ' || l_api_name || ' end');
      IEX_DEBUG_PUB.LogMessage('End time:'
                                   || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK TO Delete_Status_Rule_PUB;
              x_return_status := FND_API.G_RET_STS_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );
		    /*
              as_utility_pvt.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
              */
          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK TO Delete_Status_Rule_PUB;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );
		    /*
              as_utility_pvt.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
              */
          WHEN OTHERS THEN
              ROLLBACK TO Delete_Status_Rule_PUB;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );
		    /*
              as_utility_pvt.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => as_utility_pvt.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
              */

END Delete_Status_Rule;


Procedure Create_Status_Rule_Line
            ( p_api_version             IN NUMBER,
              p_init_msg_list           IN VARCHAR2,
              p_commit                  IN VARCHAR2,
              p_status_rule_line_rec    IN iex_status_rule_pub.status_rule_line_rec_type,
              x_return_status           OUT NOCOPY VARCHAR2,
              x_msg_count               OUT NOCOPY NUMBER,
              x_msg_data                OUT NOCOPY VARCHAR2)

IS
    l_api_name                    CONSTANT VARCHAR2(30) := 'Create_Status_Rule_Line';
    l_api_version_number          CONSTANT NUMBER   := 1.0;
    l_return_status   VARCHAR2(1);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(32767);
    l_status_rule_line_rec        iex_status_rule_pub.status_rule_line_rec_type;
    x_status_rule_line_id         NUMBER;


BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Create_Status_Rule_Line_PUB;

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
      IEX_DEBUG_PUB.LogMessage('PUB: ' || l_api_name || ' start');
      IEX_DEBUG_PUB.LogMessage('Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      IEX_DEBUG_PUB.LogMessage('Public API: Calling IEX_STATUS_RULE_PVT.Create_Status_Rule_Line');


          IEX_STATUS_RULE_PVT.Create_Status_Rule_Line(
             p_api_version              => p_api_version
           , p_init_msg_list            => FND_API.G_FALSE
           , p_commit                   => p_Commit
           , p_status_rule_line_rec     => p_status_rule_line_rec
           , x_return_status            => x_return_status
           , x_msg_count                => x_msg_count
           , x_msg_data                 => x_msg_data
           , x_status_rule_line_id        => x_status_rule_line_id
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
      IEX_DEBUG_PUB.LogMessage('PUB: ' || l_api_name || ' end');
      IEX_DEBUG_PUB.LogMessage('End time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK To Create_Status_Rule_Line_PUB;
              x_return_status := FND_API.G_RET_STS_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK TO Create_Status_Rule_Line_PUB;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );

          WHEN OTHERS THEN
              ROLLBACK TO Create_Status_Rule_Line_PUB;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );

END Create_Status_Rule_Line;



Procedure Update_Status_Rule_Line
            ( p_api_version             IN NUMBER,
              p_init_msg_list           IN VARCHAR2,
              p_commit                  IN VARCHAR2,
              p_status_rule_line_TBL      IN iex_status_rule_pub.status_rule_line_tbl_type,
              x_dup_status              OUT NOCOPY VARCHAR2,
              x_return_status           OUT NOCOPY VARCHAR2,
              x_msg_count               OUT NOCOPY NUMBER,
              x_msg_data                OUT NOCOPY VARCHAR2)

IS
    l_api_name                  CONSTANT VARCHAR2(30) := 'Update_Status_Rule_Line';
    l_api_version_number        CONSTANT NUMBER   := 1.0;
    l_return_status   VARCHAR2(1);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(32767);
    l_status_rule_line_REC        iex_status_rule_pub.status_rule_line_rec_type;

BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT Update_Status_Rule_Line_PUB;

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
      IEX_DEBUG_PUB.LogMessage('PUB: ' || l_api_name || ' start');
      IEX_DEBUG_PUB.LogMessage('Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --

      IEX_DEBUG_PUB.LogMessage('Public API: Calling IEX_STATUS_RULE_PVT.Update_Status_Rule_Line');

      for i in 1..p_status_rule_line_tbl.count
      loop
          l_status_rule_line_rec := p_status_rule_line_tbl(i);

          IEX_STATUS_RULE_PVT.Update_Status_Rule_Line(
            p_api_version              => p_api_version
          , p_init_msg_list            => FND_API.G_FALSE
          , p_commit                   => p_commit
          , p_status_rule_line_rec       => l_status_rule_line_rec
          , x_return_status            => x_return_status
          , x_msg_count                => x_msg_count
          , x_msg_data                 => x_msg_data
          );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             RAISE FND_API.G_EXC_ERROR;
          elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
             raise FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
      END LOOP;
      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Debug Message
      IEX_DEBUG_PUB.LogMessage('PUB: ' || l_api_name || ' end');
      IEX_DEBUG_PUB.LogMessage('End time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK To Update_Status_Rule_Line_PUB;
              x_return_status := FND_API.G_RET_STS_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK TO Update_Status_Rule_Line_PUB;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );

          WHEN OTHERS THEN
              ROLLBACK TO Update_Status_Rule_Line_PUB;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );

END Update_Status_Rule_Line;



Procedure Delete_Status_Rule_Line
            ( p_api_version             IN NUMBER,
              p_init_msg_list           IN VARCHAR2,
              p_commit                  IN VARCHAR2,
              p_status_rule_id          IN NUMBER,
              p_status_rule_line_ID_TBL IN iex_status_rule_pub.status_rule_line_ID_TBL_type,
              x_return_status           OUT NOCOPY VARCHAR2,
              x_msg_count               OUT NOCOPY NUMBER,
              x_msg_data                OUT NOCOPY VARCHAR2)

IS
    l_api_name                    CONSTANT VARCHAR2(30) := 'Delete_Status_Rule_Line';
    l_api_version_number          CONSTANT NUMBER   := 1.0;
    l_return_status   VARCHAR2(1);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(32767);
    l_status_rule_line_id           NUMBER;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Delete_Status_Rule_Line_PUB;

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
      IEX_DEBUG_PUB.LogMessage('PUB:' || l_api_name || 'start');
      IEX_DEBUG_PUB.LogMessage('Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --

      IEX_DEBUG_PUB.LogMessage('Public API: Calling IEX_STATUS_RULE_PVT.Delete_Status_Rule_Line');

      for i in 1..p_status_rule_line_id_Tbl.count
      loop
          l_status_rule_line_id := p_status_rule_line_id_tbl(i);

          IEX_STATUS_RULE_PVT.Delete_Status_Rule_Line(
            p_api_version              => p_api_version
          , p_init_msg_list            => FND_API.G_FALSE
          , p_commit                   => p_commit
          , p_status_rule_id           => p_status_rule_id
          , p_status_rule_line_id        => l_status_rule_line_id
          , x_return_status            => x_return_status
          , x_msg_count                => x_msg_count
          , x_msg_data                 => x_msg_data
          );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             RAISE FND_API.G_EXC_ERROR;
          elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
             raise FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
      end loop;
      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Debug Message
      IEX_DEBUG_PUB.LogMessage('PUB: ' || l_api_name || ' end');
      IEX_DEBUG_PUB.LogMessage('End time:' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK To Delete_Status_Rule_Line_PUB;
              x_return_status := FND_API.G_RET_STS_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK TO Delete_Status_Rule_Line_PUB;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );

          WHEN OTHERS THEN
              ROLLBACK TO Delete_Status_Rule_Line_PUB;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );

END Delete_Status_Rule_Line;

END IEX_STATUS_RULE_PUB;

/
