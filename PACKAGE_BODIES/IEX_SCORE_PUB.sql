--------------------------------------------------------
--  DDL for Package Body IEX_SCORE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_SCORE_PUB" AS
/* $Header: iexpscrb.pls 120.4 2005/03/02 21:02:01 ctlee ship $ */


G_PKG_NAME  CONSTANT VARCHAR2(30):= 'IEX_SCORE_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'iexpscrb.pls';


/*
  FUNCTION Init_IEX_SCORE_Rec RETURN IEX_SCORE_PUB.SCORE_REC_TYPE IS
    l_return_rec IEX_SCORE_PUB.SCORE_REC_TYPE ;
  BEGIN
    l_return_rec := IEX_SCORE_PUB.G_MISS_SCORE_REC;
    RETURN l_return_rec ;
  END;


  FUNCTION Init_IEX_SCORE_COMP_Rec RETURN IEX_SCORE_PUB.SCORE_COMP_REC_TYPE IS
    l_return_rec IEX_SCORE_PUB.SCORE_COMP_REC_TYPE;
  BEGIN
    l_return_rec := IEX_SCORE_PUB.G_MISS_SCORE_COMP_REC;
    RETURN l_return_rec ;
  END;

  FUNCTION Init_IEX_SCORE_COMP_Tbl RETURN IEX_SCORE_PUB.SCORE_COMP_TBL_TYPE IS
    l_return_rec IEX_SCORE_PUB.SCORE_COMP_Tbl_TYPE;
  BEGIN
    l_return_rec := IEX_SCORE_PUB.G_MISS_SCORE_COMP_TBL;
    RETURN l_return_rec ;
  END;
*/



PG_DEBUG NUMBER(2) ;

Procedure Create_Score
           (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 ,
            p_commit                  IN VARCHAR2 ,
            P_SCORE_REC               IN IEX_SCORE_PUB.SCORE_REC_TYPE,
            x_dup_status              OUT NOCOPY VARCHAR2,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2,
            X_SCORE_ID                OUT NOCOPY NUMBER)

IS
    l_api_name                    CONSTANT VARCHAR2(30) := 'Create_Score';
    l_api_version_number          CONSTANT NUMBER   := 1.0;
    l_return_status               VARCHAR2(1);
    l_msg_count                   NUMBER;
    l_msg_data                    VARCHAR2(32767);

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_SCORE_PUB;

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
      iex_score_pvt.WriteLog('iexpscrb:CreateScore:Start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --


      IEX_SCORE_PVT.Create_Score(
         p_api_version              => p_api_version
       , p_init_msg_list            => p_init_msg_list
       , p_commit                   => p_commit
       , p_score_rec                => p_score_rec
       , x_score_id                 => x_score_id
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
      iex_score_pvt.WriteLog('iexpscrb:CreateScore:End');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK TO CREATE_SCORE_PUB;
              x_return_status := FND_API.G_RET_STS_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK TO CREATE_SCORE_PUB;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );

          WHEN OTHERS THEN
              ROLLBACK TO CREATE_SCORE_PUB;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );


END CREATE_SCORE;



Procedure Update_Score
	   (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 ,
            p_commit                  IN VARCHAR2 ,
            P_SCORE_TBL               IN IEX_SCORE_PUB.SCORE_TBL_TYPE,
            x_dup_status              OUT NOCOPY VARCHAR2,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2)
IS
    l_api_name                    CONSTANT VARCHAR2(30) := 'Update_Score';
    l_api_version_number          CONSTANT NUMBER   := 1.0;
    l_return_status               VARCHAR2(1);
    l_msg_count                   NUMBER;
    l_msg_data                    VARCHAR2(32767);
    l_SCORE_REC                   IEX_SCORE_PUB.SCORE_REC_TYPE;

BEGIN


      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_SCORE_PUB;

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
      iex_score_pvt.WriteLog('iexpscrb:UpdateScore:Start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --


      for i in 1..p_score_tbl.count
      LOOP
          l_score_rec := p_score_tbl(i);

          IEX_SCORE_PVT.Update_Score(
            p_api_version              => p_api_version
          , p_init_msg_list            => p_init_msg_list
          , p_commit                   => p_commit
          , p_score_rec                => l_score_rec
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
      iex_score_pvt.WriteLog('iexpscrb:UpdateScore:End');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK TO UPDATE_SCORE_PUB;
              x_return_status := FND_API.G_RET_STS_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK TO UPDATE_SCORE_PUB;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );

          WHEN OTHERS THEN
              ROLLBACK TO UPDATE_SCORE_PUB;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );

END Update_Score;



Procedure Delete_Score
           (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 ,
            p_commit                  IN VARCHAR2 ,
            P_SCORE_ID_TBL            IN IEX_SCORE_PUB.SCORE_ID_TBL,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2)

IS

    l_score_id              NUMBER;
    l_api_name              CONSTANT VARCHAR2(30) := 'Delete_Score';
    l_api_version_number    CONSTANT NUMBER   := 1.0;
    l_return_status         VARCHAR2(1);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(32767);

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_SCORE_PUB;

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
      iex_score_pvt.WriteLog('iexpscrb:DeleteScore:Start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --

      iex_score_pvt.WriteLog('iexpscrb:DeleteScore:scrcnt='||p_score_id_tbl.count);
      for i in 1..p_score_id_tbl.count
      loop
         l_score_id := p_score_id_tbl(i);
         iex_score_pvt.WriteLog('iexpscrb:DeleteScore:scoreId='||l_score_id);

         IEX_SCORE_PVT.Delete_Score(
              p_api_version              => p_api_version
            , p_init_msg_list            => p_init_msg_list
            , p_commit                   => p_commit
            , p_score_id                 => l_score_id
            , x_return_status            => x_return_status
            , x_msg_count                => x_msg_count
            , x_msg_data                 => x_msg_data
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
      iex_score_pvt.WriteLog('iexpscrb:DeleteScore:End');

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK TO DELETE_SCORE_PUB;
              x_return_status := FND_API.G_RET_STS_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );
          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK TO DELETE_SCORE_PUB;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );
          WHEN OTHERS THEN
              ROLLBACK TO DELETE_SCORE_PUB;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );

END Delete_Score;



Procedure Create_SCORE_COMP
            ( p_api_version             IN NUMBER := 1.0,
              p_init_msg_list           IN VARCHAR2 ,
              p_commit                  IN VARCHAR2 ,
              p_SCORE_COMP_Rec          IN IEX_SCORE_PUB.SCORE_COMP_REC_Type,
              x_return_status           OUT NOCOPY VARCHAR2,
              x_msg_count               OUT NOCOPY NUMBER,
              x_msg_data                OUT NOCOPY VARCHAR2,
              x_SCORE_COMP_ID           OUT NOCOPY NUMBER)

IS
    l_api_name                    CONSTANT VARCHAR2(30) := 'Create_Score_Comp';
    l_api_version_number          CONSTANT NUMBER   := 1.0;
    l_return_status   VARCHAR2(1);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(32767);

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_Score_Comp_PUB;

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
      iex_score_pvt.WriteLog('iexpscrb:CreateScoreComp: Start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --


      IEX_SCORE_PVT.Create_Score_Comp(
         p_api_version              => p_api_version
       , p_init_msg_list            => p_init_msg_list
       , p_commit                   => p_Commit
       , p_score_comp_rec           => p_score_comp_rec
       , x_score_comp_id            => x_score_comp_id
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
      iex_score_pvt.WriteLog('iexpscrb:CreateScoreComp: End');


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK TO CREATE_SCORE_COMP_PUB;
              x_return_status := FND_API.G_RET_STS_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK TO CREATE_SCORE_COMP_PUB;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );

          WHEN OTHERS THEN
              ROLLBACK TO CREATE_SCORE_COMP_PUB;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );

END Create_Score_Comp;



Procedure Update_SCORE_COMP
            ( p_api_version             IN NUMBER := 1.0,
              p_init_msg_list           IN VARCHAR2 ,
              p_commit                  IN VARCHAR2 ,
              p_SCORE_COMP_TBL          IN IEX_SCORE_PUB.SCORE_COMP_TBL_TYPE,
              x_return_status           OUT NOCOPY VARCHAR2,
              x_msg_count               OUT NOCOPY NUMBER,
              x_msg_data                OUT NOCOPY VARCHAR2)

IS
    l_api_name                  CONSTANT VARCHAR2(30) := 'Update_Score_Comp';
    l_api_version_number        CONSTANT NUMBER   := 1.0;
    l_return_status   VARCHAR2(1);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(32767);
    l_SCORE_COMP_Rec            IEX_SCORE_PUB.SCORE_COMP_REC_Type;

BEGIN


      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Score_Comp_PUB;

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
      iex_score_pvt.WriteLog('iexpscrb:UpdateScoreComp: Start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --


      iex_score_pvt.WriteLog('iexpscrb:UpdateScoreComp: scrcompcnt='||p_score_comp_tbl.count);

      for i in 1..p_score_comp_tbl.count
      loop
          l_score_comp_rec := p_score_comp_tbl(i);

         IEX_SCORE_PVT.Update_Score_Comp(
            p_api_version              => p_api_version
          , p_init_msg_list            => p_init_msg_list
          , p_commit                   => p_commit
          , p_score_comp_rec           => l_score_comp_rec
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
      iex_score_pvt.WriteLog('iexpscrb:UpdateScoreComp: End');


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK TO UPDATE_SCORE_COMP_PUB;
              x_return_status := FND_API.G_RET_STS_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK TO UPDATE_SCORE_COMP_PUB;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );

          WHEN OTHERS THEN
              ROLLBACK TO UPDATE_SCORE_COMP_PUB;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );

END Update_Score_Comp;



Procedure Delete_SCORE_COMP
            ( p_api_version             IN NUMBER := 1.0,
              p_init_msg_list           IN VARCHAR2,
              p_commit                  IN VARCHAR2,
              p_SCORE_ID                IN NUMBER,
              p_SCORE_COMP_ID_TBL       IN IEX_SCORE_PUB.SCORE_COMP_ID_TBL,
              x_return_status           OUT NOCOPY VARCHAR2,
              x_msg_count               OUT NOCOPY NUMBER,
              x_msg_data                OUT NOCOPY VARCHAR2)

IS
    l_api_name                    CONSTANT VARCHAR2(30) := 'Delete_Score_COMP';
    l_api_version_number          CONSTANT NUMBER   := 1.0;
    l_return_status   VARCHAR2(1);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(32767);
    l_score_comp_id   NUMBER;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_SCORE_COMP_PUB;

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
      iex_score_pvt.WriteLog('iexpscrb:DeleteScoreComp: Start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --

      for i in 1..p_score_comp_id_tbl.count
      loop

         l_score_comp_id := p_score_comp_id_tbl(i);
         iex_score_pvt.WriteLog('iexpscrb:DeleteScoreComp: scorecompid='||l_score_comp_id);

         IEX_SCORE_PVT.Delete_Score_Comp(
            p_api_version              => p_api_version
          , p_init_msg_list            => p_init_msg_list
          , p_commit                   => p_commit
          , p_score_id                 => p_score_id
          , p_score_comp_id            => l_score_comp_id
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
      iex_score_pvt.WriteLog('iexpscrb:DeleteScoreComp: End');

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK TO DELETE_SCORE_COMP_PUB;
              x_return_status := FND_API.G_RET_STS_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK TO DELETE_SCORE_COMP_PUB;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );

          WHEN OTHERS THEN
              ROLLBACK TO DELETE_SCORE_COMP_PUB;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );

END Delete_Score_Comp;




Procedure Create_SCORE_COMP_TYPE
	    ( p_api_version             IN NUMBER := 1.0,
        p_init_msg_list           IN VARCHAR2,
        p_commit                  IN VARCHAR2,
        p_SCORE_COMP_TYPE_Rec     IN IEX_SCORE_PUB.SCORE_COMP_TYPE_REC_Type,
        x_dup_status              OUT NOCOPY VARCHAR2,
        x_return_status           OUT NOCOPY VARCHAR2,
        x_msg_count               OUT NOCOPY NUMBER,
        x_msg_data                OUT NOCOPY VARCHAR2,
        x_SCORE_COMP_TYPE_ID      OUT NOCOPY NUMBER)

IS
    l_api_name                    CONSTANT VARCHAR2(30) := 'Create_Score_Comp_type';
    l_api_version_number          CONSTANT NUMBER   := 1.0;
    l_return_status   VARCHAR2(1);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(32767);

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_Score_Comp_Type_PUB;

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
      iex_score_pvt.WriteLog('iexpscrb:CreateScrCompType: Start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --


      IEX_SCORE_PVT.Create_Score_Comp_Type(
         p_api_version              => p_api_version
       , p_init_msg_list            => FND_API.G_FALSE
       , p_commit                   => p_Commit
       , p_score_comp_type_rec      => p_score_comp_type_rec
       , x_score_comp_type_id       => x_score_comp_type_id
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


      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Debug Message
      iex_score_pvt.WriteLog('iexpscrb:CreateScrCompType: End');


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK TO CREATE_SCORE_COMP_TYPE_PUB;
              x_return_status := FND_API.G_RET_STS_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK TO CREATE_SCORE_COMP_TYPE_PUB;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );

          WHEN OTHERS THEN
              ROLLBACK TO CREATE_SCORE_COMP_TYPE_PUB;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );

END Create_Score_Comp_TYPE;



Procedure Update_SCORE_COMP_TYPE
            ( p_api_version             IN NUMBER := 1.0,
              p_init_msg_list           IN VARCHAR2 ,
              p_commit                  IN VARCHAR2 ,
              p_SCORE_COMP_TYPE_TBL     IN IEX_SCORE_PUB.SCORE_COMP_TYPE_TBL_TYPE,
              x_dup_status              OUT NOCOPY VARCHAR2,
              x_return_status           OUT NOCOPY VARCHAR2,
              x_msg_count               OUT NOCOPY NUMBER,
              x_msg_data                OUT NOCOPY VARCHAR2)

IS
    l_api_name                  CONSTANT VARCHAR2(30) := 'Update_Score_Comp_TYPE';
    l_api_version_number        CONSTANT NUMBER   := 1.0;
    l_return_status   VARCHAR2(1);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(32767);
    l_SCORE_COMP_TYPE_Rec       IEX_SCORE_PUB.SCORE_COMP_TYPE_REC_Type;

BEGIN


      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Score_Comp_TYPE_PUB;

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
      iex_score_pvt.WriteLog('iexpscrb:UpdateScrCompType: Start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --

      iex_score_pvt.WriteLog('iexpscrb:UpdateScrCompType: scrcomptypecnt='||p_score_comp_type_tbl.count);

      for i in 1..p_score_comp_Type_tbl.count
      loop
          l_score_comp_type_rec := p_score_comp_type_tbl(i);

         IEX_SCORE_PVT.Update_Score_Comp_Type(
            p_api_version              => p_api_version
          , p_init_msg_list            => p_init_msg_list
          , p_commit                   => p_commit
          , p_score_comp_type_rec      => l_score_comp_type_rec
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
      iex_score_pvt.WriteLog('iexpscrb:UpdateScrCompType: End');


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK To UPDATE_Score_Comp_TYPE_PUB;
              x_return_status := FND_API.G_RET_STS_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK To UPDATE_Score_Comp_TYPE_PUB;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );

          WHEN OTHERS THEN
              ROLLBACK To UPDATE_Score_Comp_TYPE_PUB;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );

END Update_Score_Comp_Type;




Procedure Delete_Score_Comp_Type
           (p_api_version             IN NUMBER := 1.0,
            p_init_msg_list           IN VARCHAR2 ,
            p_commit                  IN VARCHAR2 ,
            p_SCORE_COMP_TYPE_TBL     IN IEX_SCORE_PUB.SCORE_COMP_TYPE_TBL_TYPE,
            x_return_status           OUT NOCOPY VARCHAR2,
            x_msg_count               OUT NOCOPY NUMBER,
            x_msg_data                OUT NOCOPY VARCHAR2)

IS

    l_score_comp_type_id    NUMBER ;
    l_api_name              CONSTANT VARCHAR2(30) := 'Delete_Score_Comp_Type';
    l_api_version_number    CONSTANT NUMBER   := 1.0;
    l_return_status         VARCHAR2(1);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(32767);

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_SCORE_COMP_TYPE_PUB;

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
      iex_score_pvt.WriteLog('iexpscrb:UpdateScrCompType: Start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --


      for i in 1..p_score_comp_type_tbl.count
      loop
         l_score_comp_type_id := p_score_comp_type_tbl(i).score_comp_type_id;
         iex_score_pvt.WriteLog('iexpscrb:UpdateScrCompType: scrcomptypeid='||l_score_comp_type_id);


         IEX_SCORE_PVT.Delete_Score_comp_type(
              p_api_version              => p_api_version
            , p_init_msg_list            => p_init_msg_list
            , p_commit                   => p_commit
            , p_score_comp_type_id       => l_score_comp_type_id
            , x_return_status            => x_return_status
            , x_msg_count                => x_msg_count
            , x_msg_data                 => x_msg_data
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
      iex_score_pvt.WriteLog('iexpscrb:UpdateScrCompType: End');

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK To DELETE_Score_Comp_TYPE_PUB;
              x_return_status := FND_API.G_RET_STS_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK TO DELETE_SCORE_COMP_TYPE_PUB;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );

          WHEN OTHERS THEN
              ROLLBACK TO DELETE_SCORE_COMP_TYPE_PUB;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );

END Delete_Score_comp_type;




Procedure Create_SCORE_COMP_DET
            ( p_api_version             IN NUMBER := 1.0,
              p_init_msg_list           IN VARCHAR2 ,
              p_commit                  IN VARCHAR2 ,
              px_SCORE_COMP_DET_TBL     IN OUT NOCOPY IEX_SCORE_PUB.SCORE_COMP_DET_TBL_Type,
              x_return_status           OUT NOCOPY VARCHAR2,
              x_msg_count               OUT NOCOPY NUMBER,
              x_msg_data                OUT NOCOPY VARCHAR2)

IS
    l_api_name                    CONSTANT VARCHAR2(30) := 'Create_Score_Comp_Det';
    l_api_version_number          CONSTANT NUMBER   := 1.0;
    l_return_status   VARCHAR2(1);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(32767);
    l_SCORE_COMP_Det_REC        IEX_SCORE_PUB.SCORE_COMP_DET_REC_Type;
    x_score_comp_det_id         NUMBER;


BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_Score_Comp_DET_PUB;


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
      iex_score_pvt.WriteLog('iexpscrb:CreateScrCompDet: Start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --


      iex_score_pvt.WriteLog('iexpscrb:CreateScrCompDet: count='||px_score_comp_det_tbl.count);
      for i in 1..px_score_Comp_det_tbl.count
      loop

          --l_score_comp_det_rec := IEX_SCORE_PUB.G_MISS_SCORE_COMP_DET_REC;
          l_score_comp_det_rec := null;
          l_score_comp_det_rec := px_score_comp_det_tbl(i);

          IEX_SCORE_PVT.Create_Score_Comp_Det(
             p_api_version              => p_api_version
           , p_init_msg_list            => p_init_msg_list
           , p_commit                   => p_Commit
           , p_score_comp_det_rec       => l_score_comp_Det_rec
           , x_return_status            => x_return_status
           , x_msg_count                => x_msg_count
           , x_msg_data                 => x_msg_data
           , x_score_Comp_det_id        => x_score_comp_det_id
          );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             RAISE FND_API.G_EXC_ERROR;
          elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
               raise FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

          l_score_comp_Det_rec.score_comp_det_id := x_score_comp_Det_id;
          px_score_comp_Det_tbl(i) := l_score_comp_det_rec;

     END LOOP;


      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Debug Message
      iex_score_pvt.WriteLog('iexpscrb:CreateScrCompDet: End');


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK To DELETE_Score_Comp_DET_PUB;
              x_return_status := FND_API.G_RET_STS_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK TO DELETE_SCORE_COMP_DET_PUB;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );

          WHEN OTHERS THEN
              ROLLBACK TO DELETE_SCORE_COMP_DET_PUB;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );

END Create_Score_Comp_Det;



Procedure Update_SCORE_COMP_DET
            ( p_api_version             IN NUMBER := 1.0,
              p_init_msg_list           IN VARCHAR2 ,
              p_commit                  IN VARCHAR2 ,
              p_SCORE_COMP_Det_TBL      IN IEX_SCORE_PUB.SCORE_COMP_DET_TBL_Type,
              x_return_status           OUT NOCOPY VARCHAR2,
              x_msg_count               OUT NOCOPY NUMBER,
              x_msg_data                OUT NOCOPY VARCHAR2)

IS
    l_api_name                  CONSTANT VARCHAR2(30) := 'Update_Score_Comp_DET';
    l_api_version_number        CONSTANT NUMBER   := 1.0;
    l_return_status   VARCHAR2(1);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(32767);
    l_SCORE_COMP_Det_REC        IEX_SCORE_PUB.SCORE_COMP_DET_REC_Type;

BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Score_Comp_PUB_DET;

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
      iex_score_pvt.WriteLog('iexpscrb:UpdScrCompDet: Start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --

      iex_score_pvt.WriteLog('iexpscrb:UpdScrCompDet: cnt='||p_score_comp_det_tbl.count);

      for i in 1..p_score_Comp_det_tbl.count
      loop
          l_score_comp_det_rec := p_score_comp_det_tbl(i);

          IEX_SCORE_PVT.Update_Score_Comp_DET(
            p_api_version              => p_api_version
          , p_init_msg_list            => p_init_msg_list
          , p_commit                   => p_commit
          , p_score_comp_det_rec       => l_score_comp_det_rec
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
      iex_score_pvt.WriteLog('iexpscrb:UpdScrCompDet: End');


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK To UPDATE_Score_Comp_DET_PUB;
              x_return_status := FND_API.G_RET_STS_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK TO UPDATE_SCORE_COMP_DET_PUB;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );

          WHEN OTHERS THEN
              ROLLBACK TO UPDATE_SCORE_COMP_DET_PUB;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );

END Update_Score_Comp_DET;



Procedure Delete_SCORE_COMP_DET
            ( p_api_version             IN NUMBER := 1.0,
              p_init_msg_list           IN VARCHAR2 ,
              p_commit                  IN VARCHAR2 ,
              p_SCORE_COMP_ID           IN NUMBER,
              p_SCORE_COMP_DET_ID_TBL   IN IEX_SCORE_PUB.SCORE_COMP_DET_ID_TBL,
              x_return_status           OUT NOCOPY VARCHAR2,
              x_msg_count               OUT NOCOPY NUMBER,
              x_msg_data                OUT NOCOPY VARCHAR2)

IS
    l_api_name                    CONSTANT VARCHAR2(30) := 'Delete_Score_COMP_DET';
    l_api_version_number          CONSTANT NUMBER   := 1.0;
    l_return_status   VARCHAR2(1);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(32767);
    l_score_Comp_det_id           NUMBER;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_SCORE_COMP_DET_PUB;

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
      iex_score_pvt.WriteLog('iexpscrb:DelScrCompDet: Start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --


      for i in 1..p_score_comp_det_id_Tbl.count
      loop
          l_score_Comp_det_id := p_score_comp_det_id_tbl(i);
          iex_score_pvt.WriteLog('iexpscrb:DelScrCompDet: detid='||l_score_comp_Det_id);

          IEX_SCORE_PVT.Delete_Score_Comp_Det(
            p_api_version              => p_api_version
          , p_init_msg_list            => p_init_msg_list
          , p_commit                   => p_commit
          , p_score_comp_id            => p_score_comp_id
          , p_score_comp_Det_id        => l_score_comp_det_id
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
      iex_score_pvt.WriteLog('iexpscrb:DelScrCompDet: End');

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK To DELETE_Score_Comp_DET_PUB;
              x_return_status := FND_API.G_RET_STS_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK TO DELETE_SCORE_COMP_DET_PUB;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );

          WHEN OTHERS THEN
              ROLLBACK TO DELETE_SCORE_COMP_DET_PUB;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );

END Delete_Score_Comp_Det;



/* 12/09/2002 clchang added
 * new function to make a copy of scoring engine.
 */
Procedure Copy_ScoringEngine
                   (p_api_version   IN  NUMBER := 1.0,
                    p_init_msg_list IN  VARCHAR2 ,
                    p_commit        IN  VARCHAR2 ,
                    p_score_id      IN  NUMBER ,
                    x_score_id      OUT NOCOPY NUMBER ,
                    x_return_status OUT NOCOPY VARCHAR2,
                    x_msg_count     OUT NOCOPY NUMBER,
                    x_msg_data      OUT NOCOPY VARCHAR2)
IS
    l_api_name                    CONSTANT VARCHAR2(30) := 'COPY_SCORINGENGINE';
    l_api_version_number          CONSTANT NUMBER   := 1.0;
    l_return_status   VARCHAR2(1);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(32767);
    l_score_Comp_det_id           NUMBER;
    l_msg                         VARCHAR2(50);

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT COPY_SCORINGENGINE_PUB;

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

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      l_msg := 'iexpscrb.pls=>Copy_SE:';

      IEX_SCORE_PVT.WriteLog(l_msg ||'START');
      IEX_SCORE_PVT.WriteLog(l_msg ||'score_id='||p_score_id);

      --
      -- Api body
      --

      IEX_SCORE_PVT.WriteLog(l_msg ||
                   'Public API: Calling IEX_SCORE_PVT.Copy_ScoringEngine');


      IEX_SCORE_PVT.Copy_ScoringEngine(
            p_api_version              => p_api_version
          , p_init_msg_list            => p_init_msg_list
          , p_commit                   => p_commit
          , p_score_id                 => p_score_id
          , x_score_id                 => x_score_id
          , x_return_status            => x_return_status
          , x_msg_count                => x_msg_count
          , x_msg_data                 => x_msg_data
          );

      IEX_SCORE_PVT.WriteLog(l_msg ||'return_status='||x_return_status);


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

      IEX_SCORE_PVT.WriteLog(l_msg ||'score_id='||x_score_id);

      -- Debug Message

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK To COPY_SCORINGENGINE_PUB;
              x_return_status := FND_API.G_RET_STS_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK TO COPY_SCORINGENGINE_PUB;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );
          WHEN OTHERS THEN
              ROLLBACK TO COPY_SCORINGENGINE_PUB;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );

END COPY_ScoringEngine;




Procedure Get_Score(p_api_version   IN  NUMBER := 1.0,
                    p_init_msg_list IN  VARCHAR2,
                    p_commit        IN  VARCHAR2,
                    p_score_id      IN  NUMBER ,
                    x_return_status OUT NOCOPY VARCHAR2,
                    x_msg_count     OUT NOCOPY NUMBER,
                    x_msg_data      OUT NOCOPY VARCHAR2)
IS
    l_api_name                    CONSTANT VARCHAR2(30) := 'Get_score';
    l_api_version_number          CONSTANT NUMBER   := 1.0;
    l_return_status   VARCHAR2(1);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(32767);

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

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --

          IEX_SCORE_PVT.Get_Score(
                    p_api_version   => p_api_version  ,
                    p_init_msg_list => p_init_msg_list,
                    p_commit        => p_commit       ,
                    p_score_id      => p_score_id     ,
                    x_return_status => x_return_status,
                    x_msg_count     => x_msg_count    ,
                    x_msg_data      => x_msg_data     );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             RAISE FND_API.G_EXC_ERROR;
          ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
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

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              ROLLBACK To GET_SCORE_PUB;
              x_return_status := FND_API.G_RET_STS_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              ROLLBACK To GET_SCORE_PUB;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );
          WHEN OTHERS THEN
              ROLLBACK To GET_SCORE_PUB;
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
              FND_MSG_PUB.Count_And_Get
              (  p_count          =>   x_msg_count,
                 p_data           =>   x_msg_data
              );

END Get_Score;

BEGIN
   PG_DEBUG := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));

END IEX_SCORE_PUB;

/
