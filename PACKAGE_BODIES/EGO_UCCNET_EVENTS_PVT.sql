--------------------------------------------------------
--  DDL for Package Body EGO_UCCNET_EVENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_UCCNET_EVENTS_PVT" AS
/* $Header: EGOVGTNB.pls 120.1 2005/12/05 01:15:40 dsakalle noship $ */

G_FILE_NAME       CONSTANT  VARCHAR2(12)  :=  'EGOVGTNB.pls';
G_PKG_NAME        CONSTANT  VARCHAR2(30)  :=  'EGO_UCCNET_EVENTS_PVT';


PROCEDURE Update_Event_Disposition (
         p_api_version                  IN      NUMBER
        ,p_commit                       IN      VARCHAR2 DEFAULT FND_API.g_FALSE
        ,p_init_msg_list                IN      VARCHAR2 DEFAULT FND_API.G_FALSE
        ,p_cln_id                       IN      NUMBER
        ,p_disposition_code             IN      VARCHAR2
        ,p_disposition_date             IN      DATE
        ,x_return_status                OUT NOCOPY VARCHAR2
        ,x_msg_count                    OUT NOCOPY VARCHAR2
        ,x_msg_data                     OUT NOCOPY VARCHAR2
)
IS
        --we don't use l_api_version yet, but eventually we might:
        --if we change required parameters, version goes from n.x to (n+1).x
        --if we change optional parameters, version goes from x.n to x.(n+1)

        l_api_version            CONSTANT NUMBER := 1.0;

        l_api_name              CONSTANT        VARCHAR2(30) := 'Update_Event_Disposition';
        l_return_status                         VARCHAR2(1)  := G_MISS_CHAR;
        l_msg_count                             NUMBER       := 0;

BEGIN
        -- Standard start of API savepoint
        SAVEPOINT Update_Disposition_PVT;

        x_return_status := G_RET_STS_SUCCESS;

        -- Check for call compatibility
        IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                            l_api_name, G_PKG_NAME)
        THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        -- Initialize message list even though we don't currently use it
        IF FND_API.To_Boolean(p_init_msg_list) THEN
          FND_MSG_PUB.Initialize;
        END IF;
----- -----------------------------------------------------------------

        UPDATE EGO_UCCNET_EVENTS
          SET DISPOSITION_CODE = p_disposition_code,
              DISPOSITION_DATE = p_disposition_date
          WHERE cln_id = p_cln_id;

        -- Standard check of p_commit
       IF FND_API.To_Boolean(p_commit) THEN
          COMMIT WORK;
       END IF;

      x_return_status := FND_API.G_RET_STS_SUCCESS;


      EXCEPTION
         WHEN OTHERS THEN
           ROLLBACK TO Update_Disposition_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
END Update_Event_Disposition;



PROCEDURE Set_Collaboration_Id (
         p_api_version                  IN      NUMBER
        ,p_commit                       IN      VARCHAR2 DEFAULT FND_API.g_FALSE
        ,p_init_msg_list                IN      VARCHAR2 DEFAULT FND_API.g_FALSE
        ,p_batch_id                     IN      NUMBER
        ,p_subbatch_id                  IN      NUMBER
        ,p_top_gtin                     IN      NUMBER
        ,p_cln_id                       IN      NUMBER
        ,x_return_status                OUT NOCOPY VARCHAR2
        ,x_msg_count                    OUT NOCOPY VARCHAR2
        ,x_msg_data                     OUT NOCOPY VARCHAR2
)
IS
        --we don't use l_api_version yet, but eventually we might:
        --if we change required parameters, version goes from n.x to (n+1).x
        --if we change optional parameters, version goes from x.n to x.(n+1)

        l_api_version            CONSTANT NUMBER := 1.0;

        l_api_name              CONSTANT        VARCHAR2(30) := 'Set_Collaboration_Id';
        l_return_status                         VARCHAR2(1)  := G_MISS_CHAR;
        l_msg_count                             NUMBER       := 0;

BEGIN
        -- Standard start of API savepoint
        SAVEPOINT Set_Collaboration_Id_PVT;

      x_return_status := G_RET_STS_SUCCESS;

      -- Check for call compatibility
      IF NOT FND_API.Compatible_API_Call ( l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME )
      THEN
         RAISE FND_API.g_EXC_UNEXPECTED_ERROR;
      END IF;

     IF FND_API.To_Boolean(p_init_msg_list) THEN
       FND_MSG_PUB.Initialize;
     END IF;
-----------------------------------------------------------------------------

        UPDATE EGO_UCCNET_EVENTS
          SET cln_id = p_cln_id
          WHERE batch_id = p_batch_id
          AND   subbatch_id = p_subbatch_id
          AND   top_gtin = p_top_gtin;

        -- Standard check of p_commit
       IF FND_API.To_Boolean(p_commit) THEN
          COMMIT WORK;
       END IF;

      x_return_status := FND_API.G_RET_STS_SUCCESS;


      EXCEPTION
         WHEN OTHERS THEN
           ROLLBACK TO Set_Collaboration_Id_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

END Set_Collaboration_Id;

PROCEDURE Add_Additional_CIC_Info (
         p_api_version                  IN      NUMBER
        ,p_commit                       IN      VARCHAR2 DEFAULT FND_API.g_FALSE
        ,p_init_msg_list                IN      VARCHAR2 DEFAULT FND_API.G_FALSE
        ,p_cln_id                       IN      NUMBER
        ,p_cic_code                     IN      VARCHAR2
        ,p_cic_description              IN      VARCHAR2
        ,p_cic_action_needed            IN      VARCHAR2
        ,x_return_status                OUT NOCOPY VARCHAR2
        ,x_msg_count                    OUT NOCOPY VARCHAR2
        ,x_msg_data                     OUT NOCOPY VARCHAR2
)
IS

        l_api_version           CONSTANT NUMBER := 1.0;

        l_api_name              CONSTANT        VARCHAR2(30) := 'Add_Additional_CIC_Info';
        l_return_status                         VARCHAR2(1)  := G_MISS_CHAR;
        l_msg_count                             NUMBER       := 0;

BEGIN
      -- Standard start of API savepoint
      SAVEPOINT Add_Additional_CIC_Info_PVT;

      x_return_status := G_RET_STS_SUCCESS;

      -- Check for call compatibility
      IF NOT FND_API.Compatible_API_Call ( l_api_version, p_api_version,
                                        l_api_name, G_PKG_NAME )
      THEN
         RAISE FND_API.g_EXC_UNEXPECTED_ERROR;
      END IF;

      IF FND_API.To_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.Initialize;
      END IF;
-----------------------------------------------------------------------------
      INSERT INTO EGO_UCCNET_ADD_CIC_INFO
        (
        CLN_ID
        ,CODE
        ,DESCRIPTION
        ,ACTION_NEEDED
        ,CREATED_BY
        ,CREATION_DATE
        ,LAST_UPDATED_BY
        ,LAST_UPDATE_DATE
        ,LAST_UPDATE_LOGIN
        )
        VALUES
        (
        p_cln_id
        ,p_cic_code
        ,p_cic_description
        ,p_cic_action_needed
        ,fnd_global.user_id
        ,sysdate
        ,fnd_global.user_id
        ,sysdate
        ,fnd_global.login_id
        );

      -- Standard check of p_commit
      IF FND_API.To_Boolean(p_commit) THEN
         COMMIT WORK;
      END IF;

      x_return_status := FND_API.G_RET_STS_SUCCESS;


      EXCEPTION
         WHEN OTHERS THEN
           ROLLBACK TO Add_Additional_CIC_Info_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
      FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
      FND_MESSAGE.Set_Token('API_NAME', l_api_name);
      FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
END Add_Additional_CIC_info;

END EGO_UCCNET_EVENTS_PVT;

/
