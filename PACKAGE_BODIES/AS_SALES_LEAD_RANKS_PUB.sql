--------------------------------------------------------
--  DDL for Package Body AS_SALES_LEAD_RANKS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_SALES_LEAD_RANKS_PUB" AS
/* #$Header: asxprnkb.pls 120.0 2005/06/09 17:39:49 appldev noship $ */
-- Start of Comments
-- Package name     : AS_SALES_LEAD_RANKS_PUB
-- Purpose          : to add ranks into AS_SALES_LEAD_RANKS_B and _TL
-- History          : 07/24/2000 raverma created
-- NOTE             :
-- End of Comments


    G_PKG_NAME      CONSTANT VARCHAR2(30) := 'AS_SALES_LEAD_RANKS_PUB';
    G_FILE_NAME     CONSTANT VARCHAR2(12) := 'asxprnkb.pls';
/*
    G_APPL_ID       NUMBER := FND_GLOBAL.Prog_Appl_Id;
    G_LOGIN_ID      NUMBER := FND_GLOBAL.Conc_Login_Id;
    G_PROGRAM_ID    NUMBER := FND_GLOBAL.Conc_Program_Id;
    G_USER_ID       NUMBER := FND_GLOBAL.User_Id;
    G_REQUEST_ID    NUMBER := FND_GLOBAL.Conc_Request_Id;
    G_VERSION_NUM   NUMBER := 2.0;
*/

AS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);
AS_DEBUG_ERROR_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_ERROR);

PROCEDURE Create_Rank (p_api_version         IN NUMBER := 2.0,
                       p_init_msg_list       IN VARCHAR2 := FND_API.G_FALSE,
                       p_commit              IN VARCHAR2 := FND_API.G_FALSE,
                       p_validation_level    IN NUMBER :=
                                                       FND_API.G_VALID_LEVEL_FULL,
                       x_return_status       OUT NOCOPY VARCHAR2,
                       x_msg_count           OUT NOCOPY NUMBER,
                       x_msg_data            OUT NOCOPY VARCHAR2,
                       p_sales_lead_rank_rec IN AS_SALES_LEAD_RANKS_PUB.sales_lead_rank_rec_type,
                       x_sales_lead_rank_id  OUT NOCOPY NUMBER) IS

    l_api_name        CONSTANT VARCHAR2(30) := 'Create_Rank';
    l_api_version     CONSTANT NUMBER := 2.0;
    l_return_status   VARCHAR2(1);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(32767);
    l_sales_lead_rank_rec AS_SALES_LEAD_RANKS_PUB.sales_lead_rank_rec_type;
    l_rank_id         NUMBER;
    l_dummy CHAR(1);

    CURSOR c1 IS SELECT 'X' FROM AS_SALES_LEAD_RANKS_B
      WHERE rank_id = p_sales_lead_rank_rec.RANK_ID;

BEGIN
     -- Standard start of API savepoint
     SAVEPOINT     Create_Rank_PVT;

     -- Standard call to check for call compatibility
     IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE
     IF FND_API.To_Boolean(p_init_msg_list) THEN
          FND_MSG_PUB.initialize;
     END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- API body
    l_sales_lead_rank_rec := p_sales_lead_rank_rec;
    AS_SALES_LEAD_RANKS_PVT.Create_Rank (p_api_version  => l_api_version,
                                        p_commit        => p_commit,
                                        x_return_status       => l_return_status,
                                        x_msg_count           => l_msg_count,
                                        x_msg_data            => l_msg_data,
                                        p_sales_lead_rank_rec => l_sales_lead_rank_rec,
                                        x_sales_lead_rank_id  => l_rank_id);
    x_sales_lead_rank_id := l_rank_id;
    x_return_status      := l_return_status;
    --dbms_output.put_line('public API returns ' || l_return_status);
     -- End of API body

     -- Standard check of p_commit
     IF FND_API.To_Boolean(p_commit) THEN
          COMMIT WORK;
     END IF;

     -- Standard call to get message count and if count is 1, get message info
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
EXCEPTION

     WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Create_Rank_PVT;
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Create_Rank_PVT;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

     WHEN OTHERS THEN
          ROLLBACK TO Create_Rank_PVT;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
               FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

END Create_Rank;

PROCEDURE Update_Rank (p_api_version         IN NUMBER := 2.0,
                       p_init_msg_list       IN VARCHAR2 := FND_API.G_FALSE,
                       p_commit              IN VARCHAR2 := FND_API.G_FALSE,
                       p_validation_level    IN NUMBER :=
                                                       FND_API.G_VALID_LEVEL_FULL,
                       x_return_status       OUT NOCOPY VARCHAR2,
                       x_msg_count           OUT NOCOPY NUMBER,
                       x_msg_data            OUT NOCOPY VARCHAR2,
                       p_sales_lead_rank_rec IN AS_SALES_LEAD_RANKS_PUB.sales_lead_rank_rec_type) IS

    l_api_name        CONSTANT VARCHAR2(30) := 'Update_Rank';
    l_api_version     CONSTANT NUMBER := 2.0;
    l_return_status   VARCHAR2(1);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(32767);
    l_sales_lead_rank_rec AS_SALES_LEAD_RANKS_PUB.sales_lead_rank_rec_type;
    l_dummy CHAR(1);

    CURSOR c1 IS SELECT 'X' FROM AS_SALES_LEAD_RANKS_B
      WHERE rank_id = p_sales_lead_rank_rec.RANK_ID;

BEGIN
     -- Standard start of API savepoint
     SAVEPOINT     Update_Rank_PVT;

     -- Standard call to check for call compatibility
     IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE
     IF FND_API.To_Boolean(p_init_msg_list) THEN
          FND_MSG_PUB.initialize;
     END IF;

    l_sales_lead_rank_rec := p_sales_lead_rank_rec;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- API body
    AS_SALES_LEAD_RANKS_PVT.Update_Rank (p_api_version  => l_api_version,
                                        p_commit        => p_commit,
                                        x_return_status       => l_return_status,
                                        x_msg_count           => l_msg_count,
                                        x_msg_data            => l_msg_data,
                                        p_sales_lead_rank_rec => l_sales_lead_rank_rec);
    x_return_status      := l_return_status;
     -- End of API body

     -- Standard check of p_commit
     IF FND_API.To_Boolean(p_commit) THEN
          COMMIT WORK;
     END IF;

     -- Standard call to get message count and if count is 1, get message info
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Update_Rank_PVT;
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Update_Rank_PVT;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

     WHEN OTHERS THEN
          ROLLBACK TO Update_Rank_PVT;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
               FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
END Update_Rank;

Procedure Delete_Rank (p_api_version         IN NUMBER := 2.0,
                       p_init_msg_list       IN VARCHAR2 := FND_API.G_FALSE,
                       p_commit              IN VARCHAR2 := FND_API.G_FALSE,
                       p_validation_level    IN NUMBER :=
                                                       FND_API.G_VALID_LEVEL_FULL,
                       x_return_status       OUT NOCOPY VARCHAR2,
                       x_msg_count           OUT NOCOPY NUMBER,
                       x_msg_data            OUT NOCOPY VARCHAR2,
                       p_sales_lead_rank_id  IN NUMBER) IS

    l_api_name        CONSTANT VARCHAR2(30) := 'Delete_Rank';
    l_api_version     CONSTANT NUMBER := 2.0;
    l_return_status   VARCHAR2(1);
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(32767);
    l_sales_lead_rank_id NUMBER;
    l_dummy CHAR(1);

BEGIN
     -- Standard start of API savepoint
     SAVEPOINT     Delete_Rank_PVT;

     -- Standard call to check for call compatibility
     IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE
     IF FND_API.To_Boolean(p_init_msg_list) THEN
          FND_MSG_PUB.initialize;
     END IF;

    l_sales_lead_rank_id := p_sales_lead_rank_id;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --dbms_output.put_line('before delete pvt');
    -- API body
        AS_SALES_LEAD_RANKS_PVT.Delete_Rank (p_api_version        => 2.0,
                                            p_commit              => p_commit,
                                            x_return_status       => l_return_status,
                                            x_msg_count           => l_msg_count,
                                            x_msg_data            => l_msg_data,
                                            p_sales_lead_rank_id  => l_sales_lead_rank_id);
    x_return_status      := l_return_status;
     -- End of API body

     -- Standard check of p_commit
     IF FND_API.To_Boolean(p_commit) THEN
          COMMIT WORK;
          --dbms_output.put_line('after delete pvt - commit');
     END IF;

     -- Standard call to get message count and if count is 1, get message info
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Delete_Rank_PVT;
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Delete_Rank_PVT;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

     WHEN OTHERS THEN
          ROLLBACK TO Delete_Rank_PVT;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
               FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
          END IF;
          FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
END DELETE_RANK;

END;

/
