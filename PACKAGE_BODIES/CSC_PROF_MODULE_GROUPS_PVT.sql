--------------------------------------------------------
--  DDL for Package Body CSC_PROF_MODULE_GROUPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSC_PROF_MODULE_GROUPS_PVT" as
/* $Header: cscvpmgb.pls 115.23 2003/02/18 23:33:08 agaddam ship $ */
-- Start of Comments
-- Package name     : CSC_PROF_MODULE_GROUPS_PVT
-- Purpose          :
-- History          :
--  26 Nov 02 JAmose  Addition of NOCOPY and the Removal of Fnd_Api.G_MISS*
--                    from the definition for the performance reason
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSC_PROF_MODULE_GROUPS_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'cscvpmgb.pls';

l_dummy VARCHAR2(100);


PROCEDURE Convert_Columns_to_Rec (
     p_MODULE_GROUP_ID                 NUMBER DEFAULT NULL,
     p_FORM_FUNCTION_ID                NUMBER,
     p_FORM_FUNCTION_NAME              VARCHAR2,
     p_RESPONSIBILITY_ID               NUMBER,
     p_RESP_APPL_ID                    NUMBER,
     p_PARTY_TYPE                      VARCHAR2,
     p_GROUP_ID                        NUMBER,
     p_DASHBOARD_GROUP_FLAG            VARCHAR2,
     p_CURRENCY_CODE                   VARCHAR2,
     p_LAST_UPDATE_DATE                DATE,
     p_LAST_UPDATED_BY                 NUMBER,
     p_CREATION_DATE                   DATE,
     p_CREATED_BY                      NUMBER,
     p_LAST_UPDATE_LOGIN               NUMBER,
     p_SEEDED_FLAG                     VARCHAR2,
     p_APPLICATION_ID                  NUMBER,
     p_DASHBOARD_GROUP_ID              NUMBER,
     x_PROF_MODULE_GRP_Rec     OUT NOCOPY   PROF_MODULE_GRP_Rec_Type    )
  IS
BEGIN

    x_PROF_MODULE_GRP_rec.MODULE_GROUP_ID := P_MODULE_GROUP_ID;
    x_PROF_MODULE_GRP_rec.FORM_FUNCTION_ID := P_FORM_FUNCTION_ID;
    x_PROF_MODULE_GRP_rec.FORM_FUNCTION_NAME := P_FORM_FUNCTION_NAME;
    x_PROF_MODULE_GRP_rec.RESPONSIBILITY_ID := P_RESPONSIBILITY_ID;
    x_PROF_MODULE_GRP_rec.RESP_APPL_ID := P_RESP_APPL_ID;
    x_PROF_MODULE_GRP_rec.PARTY_TYPE := P_PARTY_TYPE;
    x_PROF_MODULE_GRP_rec.GROUP_ID := P_GROUP_ID;
    x_PROF_MODULE_GRP_rec.DASHBOARD_GROUP_FLAG := P_DASHBOARD_GROUP_FLAG;
    x_PROF_MODULE_GRP_rec.CURRENCY_CODE := P_CURRENCY_CODE;
    x_PROF_MODULE_GRP_rec.LAST_UPDATE_DATE := P_LAST_UPDATE_DATE;
    x_PROF_MODULE_GRP_rec.LAST_UPDATED_BY := P_LAST_UPDATED_BY;
    x_PROF_MODULE_GRP_rec.CREATION_DATE := P_CREATION_DATE;
    x_PROF_MODULE_GRP_rec.CREATED_BY := P_CREATED_BY;
    x_PROF_MODULE_GRP_rec.LAST_UPDATE_LOGIN := P_LAST_UPDATE_LOGIN;
    x_PROF_MODULE_GRP_rec.SEEDED_FLAG:=P_SEEDED_FLAG;
    x_PROF_MODULE_GRP_rec.APPLICATION_ID:=P_APPLICATION_ID;
    x_PROF_MODULE_GRP_rec.DASHBOARD_GROUP_ID := P_DASHBOARD_GROUP_ID;

END Convert_Columns_to_Rec;


PROCEDURE Create_prof_module_groups(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    PX_MODULE_GROUP_ID     IN OUT NOCOPY NUMBER,
    p_FORM_FUNCTION_ID                NUMBER,
    p_FORM_FUNCTION_NAME              VARCHAR2,
    p_RESPONSIBILITY_ID                NUMBER,
    p_RESP_APPL_ID                    NUMBER,
    p_PARTY_TYPE                      VARCHAR2,
    p_GROUP_ID                        NUMBER,
    p_DASHBOARD_GROUP_FLAG            VARCHAR2,
    p_CURRENCY_CODE                   VARCHAR2,
    p_LAST_UPDATE_DATE                DATE,
    p_LAST_UPDATED_BY                 NUMBER,
    p_CREATION_DATE                   DATE,
    p_CREATED_BY                      NUMBER,
    p_LAST_UPDATE_LOGIN               NUMBER,
    p_SEEDED_FLAG                     VARCHAR2,
    p_APPLICATION_ID                  NUMBER,
    p_DASHBOARD_GROUP_ID              NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )
IS
 l_PROF_MODULE_GRP_REC PROF_MODULE_GRP_REC_TYPE;
BEGIN

 Convert_Columns_to_Rec (
     p_MODULE_GROUP_ID  =>   PX_MODULE_GROUP_ID,
     p_FORM_FUNCTION_ID    => p_FORM_FUNCTION_ID,
     p_FORM_FUNCTION_NAME  => p_FORM_FUNCTION_NAME,
     p_RESPONSIBILITY_ID    => p_RESPONSIBILITY_ID,
     p_RESP_APPL_ID    => p_RESP_APPL_ID,
     p_PARTY_TYPE          => p_PARTY_TYPE,
     p_GROUP_ID            => p_GROUP_ID,
     p_DASHBOARD_GROUP_FLAG => p_DASHBOARD_GROUP_FLAG,
     p_CURRENCY_CODE        => p_CURRENCY_CODE,
     p_LAST_UPDATE_DATE     => p_LAST_UPDATE_DATE,
     p_LAST_UPDATED_BY      => p_LAST_UPDATED_BY,
     p_CREATION_DATE        => p_CREATION_DATE,
     p_CREATED_BY           => p_CREATED_BY,
     p_LAST_UPDATE_LOGIN    => p_LAST_UPDATE_LOGIN,
     p_SEEDED_FLAG          => p_SEEDED_FLAG,
     p_APPLICATION_ID       => p_APPLICATION_ID,
     p_DASHBOARD_GROUP_ID   => p_DASHBOARD_GROUP_ID,
     x_PROF_MODULE_GRP_Rec  => l_PROF_MODULE_GRP_Rec    );


Create_prof_module_groups(
    P_Api_Version_Number     => P_Api_Version_Number,
    P_Init_Msg_List          => P_Init_Msg_List,
    P_Commit                 => P_Commit,
    p_validation_level       => p_validation_level,
    P_PROF_MODULE_GRP_Rec    => l_PROF_MODULE_GRP_Rec,
    PX_MODULE_GROUP_ID     => PX_MODULE_GROUP_ID,
    X_Return_Status        => X_Return_Status,
    X_Msg_Count            => X_Msg_Count,
    X_Msg_Data             => X_Msg_Data
    );

END Create_prof_module_groups;

PROCEDURE Create_prof_module_groups(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_PROF_MODULE_GRP_Rec     IN    PROF_MODULE_GRP_Rec_Type  := G_MISS_PROF_MODULE_GRP_REC,
    PX_MODULE_GROUP_ID     IN OUT NOCOPY NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_prof_module_groups';
l_api_version_number      CONSTANT NUMBER   := 1.0;
l_return_status_full        VARCHAR2(1);
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_PROF_MODULE_GROUPS_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	             p_api_version_number,
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

      --
      -- API body
      --


      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN

          -- Invoke validation procedures
          Validate_prof_module_groups(
              p_init_msg_list    => CSC_CORE_UTILS_PVT.G_FALSE,
              p_validation_level => p_validation_level,
              p_validation_mode  => CSC_CORE_UTILS_PVT.G_CREATE,
              P_PROF_MODULE_GRP_Rec  =>  P_PROF_MODULE_GRP_Rec,
              x_return_status    => x_return_status,
              x_msg_count        => x_msg_count,
              x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Invoke table handler(CSC_PROF_MODULE_GROUPS_PKG.Insert_Row)
      CSC_PROF_MODULE_GROUPS_PKG.Insert_Row(
          px_MODULE_GROUP_ID  => px_MODULE_GROUP_ID,
          p_FORM_FUNCTION_ID  => p_PROF_MODULE_GRP_rec.FORM_FUNCTION_ID,
          p_FORM_FUNCTION_NAME => p_PROF_MODULE_GRP_rec.FORM_FUNCTION_NAME,
          p_RESPONSIBILITY_ID  => p_PROF_MODULE_GRP_rec.RESPONSIBILITY_ID,
          p_RESP_APPL_ID  => p_PROF_MODULE_GRP_rec.RESP_APPL_ID,
          p_PARTY_TYPE  => p_PROF_MODULE_GRP_rec.PARTY_TYPE,
          p_GROUP_ID  => p_PROF_MODULE_GRP_rec.GROUP_ID,
          p_DASHBOARD_GROUP_FLAG  => p_PROF_MODULE_GRP_rec.DASHBOARD_GROUP_FLAG,
          p_CURRENCY_CODE  => p_PROF_MODULE_GRP_rec.CURRENCY_CODE,
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
          p_CREATION_DATE  => SYSDATE,
          p_CREATED_BY  => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_LOGIN  => p_PROF_MODULE_GRP_rec.LAST_UPDATE_LOGIN,
          p_SEEDED_FLAG   =>  p_PROF_MODULE_GRP_rec.SEEDED_FLAG,
          p_APPLICATION_ID => p_PROF_MODULE_GRP_rec.APPLICATION_ID,
          p_DASHBOARD_GROUP_ID  => p_PROF_MODULE_GRP_rec.DASHBOARD_GROUP_ID);

      -- x_MODULE_GROUP_ID := px_MODULE_GROUP_ID;

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
		 ROLLBACK TO CREATE_PROF_MODULE_GROUPS_PVT;
    		  x_return_status := FND_API.G_RET_STS_ERROR;
            APP_EXCEPTION.RAISE_EXCEPTION;

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		 ROLLBACK TO CREATE_PROF_MODULE_GROUPS_PVT;
    		  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            APP_EXCEPTION.RAISE_EXCEPTION;

          WHEN OTHERS THEN
		 ROLLBACK TO CREATE_PROF_MODULE_GROUPS_PVT;
    		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Build_Exc_Msg;
          APP_EXCEPTION.RAISE_EXCEPTION;
End Create_prof_module_groups;


PROCEDURE Update_prof_module_groups(
    P_Api_Version_Number  IN   NUMBER,
    P_Init_Msg_List       IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level    IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_MODULE_GROUP_ID     NUMBER,
    p_FORM_FUNCTION_ID    NUMBER,
    p_FORM_FUNCTION_NAME  VARCHAR2,
    p_RESPONSIBILITY_ID   NUMBER,
    p_RESP_APPL_ID                    NUMBER,
    p_PARTY_TYPE          VARCHAR2,
    p_GROUP_ID             NUMBER,
    p_DASHBOARD_GROUP_FLAG  VARCHAR2,
    p_CURRENCY_CODE        VARCHAR2,
    p_LAST_UPDATE_DATE     DATE,
    p_LAST_UPDATED_BY      NUMBER,
    p_CREATION_DATE        DATE DEFAULT NULL,
    p_CREATED_BY           NUMBER DEFAULT NULL,
    p_LAST_UPDATE_LOGIN    NUMBER,
    p_SEEDED_FLAG          VARCHAR2,
    p_APPLICATION_ID       NUMBER,
    p_DASHBOARD_GROUP_ID   NUMBER,
    X_Return_Status        OUT NOCOPY VARCHAR2,
    X_Msg_Count            OUT NOCOPY NUMBER,
    X_Msg_Data             OUT NOCOPY VARCHAR2
    )
IS
 l_PROF_MODULE_GRP_REC PROF_MODULE_GRP_REC_TYPE;
BEGIN

 -- Added by anand for bug 1334616 (p_module_group_id)
 Convert_Columns_to_Rec (
     p_MODULE_GROUP_ID     => p_MODULE_GROUP_ID,
     p_FORM_FUNCTION_ID    => p_FORM_FUNCTION_ID,
     p_FORM_FUNCTION_NAME  => p_FORM_FUNCTION_NAME,
     p_RESPONSIBILITY_ID    => p_RESPONSIBILITY_ID,
     p_RESP_APPL_ID    => p_RESP_APPL_ID,
     p_PARTY_TYPE          => p_PARTY_TYPE,
     p_GROUP_ID            => p_GROUP_ID,
     p_DASHBOARD_GROUP_FLAG => p_DASHBOARD_GROUP_FLAG,
     p_CURRENCY_CODE        => p_CURRENCY_CODE,
     p_LAST_UPDATE_DATE     => p_LAST_UPDATE_DATE,
     p_LAST_UPDATED_BY      => p_LAST_UPDATED_BY,
     p_CREATION_DATE        => p_CREATION_DATE,
     p_CREATED_BY           => p_CREATED_BY,
     p_LAST_UPDATE_LOGIN    => p_LAST_UPDATE_LOGIN,
     p_SEEDED_FLAG          => p_SEEDED_FLAG,
     p_APPLICATION_ID       => p_APPLICATION_ID,
     p_DASHBOARD_GROUP_ID   => p_DASHBOARD_GROUP_ID,
     x_PROF_MODULE_GRP_Rec  => l_PROF_MODULE_GRP_Rec    );


 Update_prof_module_groups(
    P_Api_Version_Number     => P_Api_Version_Number,
    P_Init_Msg_List          => P_Init_Msg_List,
    P_Commit                 => P_Commit,
    p_validation_level       => p_validation_level,
    P_PROF_MODULE_GRP_Rec    => l_PROF_MODULE_GRP_Rec,
    X_Return_Status        => X_Return_Status,
    X_Msg_Count            => X_Msg_Count,
    X_Msg_Data             => X_Msg_Data
    );

END Update_prof_module_groups;


PROCEDURE Update_prof_module_groups(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN  NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_PROF_MODULE_GRP_Rec     IN    PROF_MODULE_GRP_Rec_Type,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )

 IS

Cursor C_Get_prof_module_groups(c_MODULE_GROUP_ID Number) IS
    Select rowid,
           MODULE_GROUP_ID,
           FORM_FUNCTION_ID,
           FORM_FUNCTION_NAME,
           RESPONSIBILITY_ID,
           RESP_APPL_ID,
           PARTY_TYPE,
           GROUP_ID,
           DASHBOARD_GROUP_FLAG,
           CURRENCY_CODE,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_LOGIN,
           SEEDED_FLAG,
           APPLICATION_ID,
           DASHBOARD_GROUP_ID
    From  CSC_PROF_MODULE_GROUPS
    Where module_group_id = c_module_group_id
    For Update NOWAIT;
l_api_name                CONSTANT VARCHAR2(30) := 'Update_prof_module_groups';
l_api_version_number      CONSTANT NUMBER   := 1.0;
-- Local Variables
l_old_PROF_MODULE_GRP_rec  PROF_MODULE_GRP_Rec_Type;
l_PROF_MODULE_GRP_Rec  PROF_MODULE_GRP_Rec_Type := p_PROF_MODULE_GRP_REC;
l_rowid  ROWID;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_PROF_MODULE_GROUPS_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	             p_api_version_number,
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

      Open C_Get_prof_module_groups( P_PROF_MODULE_GRP_rec.MODULE_GROUP_ID);

      Fetch C_Get_prof_module_groups into
               l_rowid,
               l_old_PROF_MODULE_GRP_rec.MODULE_GROUP_ID,
               l_old_PROF_MODULE_GRP_rec.FORM_FUNCTION_ID,
               l_old_PROF_MODULE_GRP_rec.FORM_FUNCTION_NAME,
               l_old_PROF_MODULE_GRP_rec.RESPONSIBILITY_ID,
               l_old_PROF_MODULE_GRP_rec.RESP_APPL_ID,
               l_old_PROF_MODULE_GRP_rec.PARTY_TYPE,
               l_old_PROF_MODULE_GRP_rec.GROUP_ID,
               l_old_PROF_MODULE_GRP_rec.DASHBOARD_GROUP_FLAG,
               l_old_PROF_MODULE_GRP_rec.CURRENCY_CODE,
               l_old_PROF_MODULE_GRP_rec.LAST_UPDATE_DATE,
               l_old_PROF_MODULE_GRP_rec.LAST_UPDATED_BY,
               l_old_PROF_MODULE_GRP_rec.CREATION_DATE,
               l_old_PROF_MODULE_GRP_rec.CREATED_BY,
               l_old_PROF_MODULE_GRP_rec.LAST_UPDATE_LOGIN,
               l_old_PROF_MODULE_GRP_rec.SEEDED_FLAG,
               l_old_PROF_MODULE_GRP_rec.APPLICATION_ID,
               l_old_PROF_MODULE_GRP_rec.DASHBOARD_GROUP_ID;

       If ( C_Get_prof_module_groups%NOTFOUND) Then

           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
		  CSC_CORE_UTILS_PVT.RECORD_IS_LOCKED_MSG(p_Api_Name => l_api_name);
           END IF;
           raise FND_API.G_EXC_ERROR;

       END IF;
       Close     C_Get_prof_module_groups;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
       /*
          IF p_prof_module_grp_rec.group_id = CSC_CORE_UTILS_PVT.G_MISS_NUM THEN
		  l_prof_module_grp_rec.group_id := l_old_prof_module_grp_rec.group_id;
          END IF;
          IF p_prof_module_grp_rec.dashboard_group_flag = CSC_CORE_UTILS_PVT.G_MISS_CHAR THEN
		  l_prof_module_grp_rec.dashboard_group_Flag := l_old_prof_module_grp_rec.dashboard_group_flag;
          END IF;
	  IF p_prof_module_grp_rec.form_function_id = CSC_CORE_UTILS_PVT.G_MISS_NUM THEN
	       l_prof_module_grp_Rec.form_function_id := l_old_prof_module_grp_rec.form_function_id;
          END IF;
	  IF p_prof_module_grp_rec.responsibility_id = CSC_CORE_UTILS_PVT.G_MISS_NUM THEN
	       l_prof_module_grp_rec.responsibility_id := l_old_prof_module_grp_rec.responsibility_id;
          END IF;
	  IF p_prof_module_grp_rec.resp_appl_id = CSC_CORE_UTILS_PVT.G_MISS_NUM THEN
	       l_prof_module_grp_rec.resp_appl_id := l_old_prof_module_grp_rec.resp_appl_id;
          END IF;
         */
         l_prof_module_grp_rec.group_id := CSC_CORE_UTILS_PVT.Get_G_Miss_Num(p_prof_module_grp_rec.group_id,l_old_prof_module_grp_rec.group_id);
         l_prof_module_grp_rec.dashboard_group_Flag := CSC_CORE_UTILS_PVT.Get_G_Miss_Char(p_prof_module_grp_rec.dashboard_group_flag,l_old_prof_module_grp_rec.dashboard_group_flag);
         l_prof_module_grp_Rec.form_function_id := CSC_CORE_UTILS_PVT.Get_G_Miss_Num(p_prof_module_grp_rec.form_function_id,l_old_prof_module_grp_rec.form_function_id);
         l_prof_module_grp_rec.responsibility_id := CSC_CORE_UTILS_PVT.Get_G_Miss_Num(p_prof_module_grp_rec.responsibility_id,l_old_prof_module_grp_rec.responsibility_id);

         l_prof_module_grp_rec.resp_appl_id := CSC_CORE_UTILS_PVT.Get_G_Miss_Num(p_prof_module_grp_rec.resp_appl_id,l_old_prof_module_grp_rec.resp_appl_id);

          -- Invoke validation procedures
          Validate_prof_module_groups(
              p_init_msg_list    => CSC_CORE_UTILS_PVT.G_FALSE,
              p_validation_level => p_validation_level,
              p_validation_mode  => CSC_CORE_UTILS_PVT.G_UPDATE,
              P_PROF_MODULE_GRP_Rec  =>  l_PROF_MODULE_GRP_Rec,
              x_return_status    => x_return_status,
              x_msg_count        => x_msg_count,
              x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Invoke table handler(CSC_PROF_MODULE_GROUPS_PKG.Update_Row)
      CSC_PROF_MODULE_GROUPS_PKG.Update_Row(
          p_MODULE_GROUP_ID  =>csc_core_utils_pvt.Get_G_Miss_Num(p_PROF_MODULE_GRP_rec.MODULE_GROUP_ID,l_old_PROF_MODULE_GRP_rec.MODULE_GROUP_ID),
          p_FORM_FUNCTION_ID  =>csc_core_utils_pvt.Get_G_Miss_Num(p_PROF_MODULE_GRP_rec.FORM_FUNCTION_ID,l_old_PROF_MODULE_GRP_rec.FORM_FUNCTION_ID),
          p_FORM_FUNCTION_NAME =>csc_core_utils_pvt.Get_G_Miss_Char(p_PROF_MODULE_GRP_rec.FORM_FUNCTION_NAME,l_old_PROF_MODULE_GRP_rec.FORM_FUNCTION_NAME),
          p_RESPONSIBILITY_ID  =>csc_core_utils_pvt.Get_G_Miss_Num(p_PROF_MODULE_GRP_rec.RESPONSIBILITY_ID,l_old_PROF_MODULE_GRP_rec.RESPONSIBILITY_ID),
          p_RESP_APPL_ID  =>csc_core_utils_pvt.Get_G_Miss_Num(p_PROF_MODULE_GRP_rec.RESP_APPL_ID,l_old_PROF_MODULE_GRP_rec.RESP_APPL_ID),
          p_PARTY_TYPE  =>csc_core_utils_pvt.Get_G_Miss_Char(p_PROF_MODULE_GRP_rec.PARTY_TYPE,l_old_PROF_MODULE_GRP_rec.PARTY_TYPE),
          p_GROUP_ID  =>csc_core_utils_pvt.Get_G_Miss_Num(p_PROF_MODULE_GRP_rec.GROUP_ID,l_old_PROF_MODULE_GRP_rec.GROUP_ID),
          p_DASHBOARD_GROUP_FLAG  =>csc_core_utils_pvt.Get_G_Miss_Char(p_PROF_MODULE_GRP_rec.DASHBOARD_GROUP_FLAG,l_old_PROF_MODULE_GRP_rec.DASHBOARD_GROUP_FLAG),
          p_CURRENCY_CODE  => csc_core_utils_pvt.Get_G_Miss_Char(p_PROF_MODULE_GRP_rec.CURRENCY_CODE,l_old_PROF_MODULE_GRP_rec.CURRENCY_CODE),
          p_LAST_UPDATE_DATE  => SYSDATE,
          p_LAST_UPDATED_BY  => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_LOGIN  =>csc_core_utils_pvt.Get_G_Miss_Num(p_PROF_MODULE_GRP_rec.LAST_UPDATE_LOGIN,l_old_PROF_MODULE_GRP_rec.LAST_UPDATE_LOGIN),
          p_SEEDED_FLAG       => csc_core_utils_pvt.Get_G_Miss_Char(p_PROF_MODULE_GRP_rec.SEEDED_FLAG,l_old_PROF_MODULE_GRP_rec.SEEDED_FLAG),
          p_APPLICATION_ID      =>csc_core_utils_pvt.Get_G_Miss_Num(p_PROF_MODULE_GRP_rec.APPLICATION_ID,l_old_PROF_MODULE_GRP_rec.APPLICATION_ID),
          p_DASHBOARD_GROUP_ID  =>csc_core_utils_pvt.Get_G_Miss_Num(p_PROF_MODULE_GRP_rec.DASHBOARD_GROUP_ID,l_old_PROF_MODULE_GRP_rec.DASHBOARD_GROUP_ID));
      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
		 ROLLBACK TO UPDATE_PROF_MODULE_GROUPS_PVT;
		    x_return_status := FND_API.G_RET_STS_ERROR;
		    APP_EXCEPTION.RAISE_EXCEPTION;

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		 ROLLBACK TO UPDATE_PROF_MODULE_GROUPS_PVT;
		    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		    APP_EXCEPTION.RAISE_EXCEPTION;

          WHEN OTHERS THEN
		 ROLLBACK TO UPDATE_PROF_MODULE_GROUPS_PVT;
    	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    	      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		 THEN
           	    FND_MSG_PUB.Build_Exc_Msg(G_PKG_NAME, l_api_name);
    	      END IF;
         APP_EXCEPTION.RAISE_EXCEPTION;
End Update_prof_module_groups;


PROCEDURE Delete_prof_module_groups(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_PROF_MODULE_GRP_Id         IN NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_prof_module_groups';
l_api_version_number      CONSTANT NUMBER   := 1.0;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_PROF_MODULE_GROUPS_PVT;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	             p_api_version_number,
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

      -- Invoke table handler(CSC_PROF_MODULE_GROUPS_PKG.Delete_Row)
      CSC_PROF_MODULE_GROUPS_PKG.Delete_Row(
          p_MODULE_GROUP_ID  => p_PROF_MODULE_GRP_Id);
      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;



      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
		 ROLLBACK TO DELETE_PROF_MODULE_GROUPS_PVT;
         	  x_return_status :=  FND_API.G_RET_STS_ERROR ;
         	  APP_EXCEPTION.RAISE_EXCEPTION;

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		 ROLLBACK TO DELETE_PROF_MODULE_GROUPS_PVT;
         	  x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;
         	  APP_EXCEPTION.RAISE_EXCEPTION;

          WHEN OTHERS THEN
		 ROLLBACK TO DELETE_PROF_MODULE_GROUPS_PVT;
         	x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;
         	IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
         	THEN
         	    FND_MSG_PUB.Build_Exc_Msg(G_PKG_NAME,l_api_name);
         	END IF ;
         	APP_EXCEPTION.RAISE_EXCEPTION;
End Delete_prof_module_groups;



-- Item-level validation procedures
PROCEDURE Validate_MODULE_GROUP_ID (
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_MODULE_GROUP_ID                IN   NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )
IS
 p_Api_Name VARCHAR2(100) := 'Validate_Module_Group_Id';
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- validate NOT NULL column

      IF(p_validation_mode = CSC_CORE_UTILS_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_MODULE_GROUP_ID is not NULL and p_MODULE_GROUP_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = CSC_CORE_UTILS_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_MODULE_GROUP_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          -- NULL;
           IF(p_MODULE_GROUP_ID is NULL)
            THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
           END IF;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_MODULE_GROUP_ID;


PROCEDURE Validate_RESPONSIBILITY_ID (
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_RESPONSIBILITY_ID          IN   NUMBER,
    P_RESP_APPL_ID          IN   NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )
IS
 p_Api_Name VARCHAR2(100) := 'Validate Responsibility';

 Cursor C1 is
  Select NULL
  from fnd_responsibility_vl
  where responsibility_id = p_responsibility_id
  and application_id = p_resp_appl_id;

BEGIN


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF p_RESPONSIBILITY_ID is not NULL and p_RESPONSIBILITY_ID <> CSC_CORE_UTILS_PVT.G_MISS_CHAR
      THEN
	Open C1;
        Fetch C1 INTO l_dummy;
         IF C1%NOTFOUND THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
           CSC_CORE_UTILS_PVT.Add_Invalid_Argument_Msg(
		     p_api_name => p_api_name,
		     p_argument_value  => p_Responsibility_id,
		     p_argument  => 'P_RESPONSIBILITY_ID');
         END IF;
        Close C1;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );


END Validate_Responsibility_id;


PROCEDURE Validate_FORM_FUNCTION_NAME (
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_FORM_FUNCTION_NAME                IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )
IS
 p_Api_Name VARCHAR2(100) := 'Validate Form Function Name';
 Cursor C1 is
  Select NULL
  from fnd_form_functions
  where function_name = p_form_function_name;

BEGIN


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF p_FORM_FUNCTION_NAME is not NULL and p_FORM_FUNCTION_NAME <> CSC_CORE_UTILS_PVT.G_MISS_CHAR
      THEN
	Open C1;
        Fetch C1 INTO l_dummy;
         IF C1%NOTFOUND THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
           CSC_CORE_UTILS_PVT.Add_Invalid_Argument_Msg(
		     p_api_name => p_api_name,
		     p_argument_value  => p_form_function_name,
		     p_argument  => 'P_FORM_FUNCTION_NAME');
         END IF;
        Close C1;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_Form_Function_Name;

PROCEDURE Validate_FORM_FUNCTION_ID (
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_FORM_FUNCTION_ID                IN   NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )
IS
 p_Api_Name VARCHAR2(100) := 'Validate Form Function Id';
 Cursor C1 is
  Select NULL
  from fnd_form_functions
  where function_id = p_form_function_id;

BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      IF p_FORM_FUNCTION_ID is not NULL and p_FORM_FUNCTION_ID <> CSC_CORE_UTILS_PVT.G_MISS_NUM
      THEN
	   open C1;
        fetch C1 INTO l_dummy;
        if C1%NOTFOUND then
	      -- if the form_function_id is not valid its an invalid argument
           x_return_status := FND_API.G_RET_STS_ERROR;
           CSC_CORE_UTILS_PVT.Add_Invalid_Argument_Msg(
		     p_api_name => p_api_name,
		     p_argument_value  => p_form_function_id,
		     p_argument  => 'P_FORM_FUNCTION_ID');
        end if;
        close C1;
	END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_FORM_FUNCTION_ID;


PROCEDURE Validate_PARTY_TYPE (
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PARTY_TYPE                IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )
IS
 p_Api_Name VARCHAR2(100) := 'Validate_Party_Type';
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = CSC_CORE_UTILS_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_PARTY_TYPE is not NULL and p_PARTY_TYPE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
	    IF p_PARTY_TYPE is not NULL and p_PARTY_TYPE <> CSC_CORE_UTILS_PVT.G_MISS_CHAR
	    THEN
		 IF p_PARTY_TYPE NOT IN ('ALL','GROUP','PERSON','ORGANIZATION') THEN
               x_return_status := FND_API.G_RET_STS_ERROR;
               CSC_CORE_UTILS_PVT.Add_Invalid_Argument_Msg(
		       p_api_name => p_api_name,
		       p_argument_value  => p_PARTY_TYPE,
		       p_argument  => 'P_PARTY_TYPE');
		 END IF;
	     END IF;
      ELSIF(p_validation_mode = CSC_CORE_UTILS_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_PARTY_TYPE <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
	    IF p_PARTY_TYPE is not NULL and p_PARTY_TYPE <> CSC_CORE_UTILS_PVT.G_MISS_CHAR
	    THEN
		 IF p_PARTY_TYPE NOT IN ('ALL','GROUP','PERSON','ORGANIZATION') THEN
               x_return_status := FND_API.G_RET_STS_ERROR;
               CSC_CORE_UTILS_PVT.Add_Invalid_Argument_Msg(
		       p_api_name => p_api_name,
		       p_argument_value  => p_PARTY_TYPE,
		       p_argument  => 'P_PARTY_TYPE');
		 END IF;
	     END IF;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PARTY_TYPE;


PROCEDURE Validate_GROUP_ID (
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_GROUP_ID                   IN   NUMBER,
    P_PARTY_TYPE			IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )
IS
 p_Api_Name VARCHAR2(100) := 'Validate_Group_Id';
 --keep an UNION fo r ALL party type..
 Cursor C1 is
  Select NULL
  from csc_prof_groups_vl
  where group_id = P_GROUP_ID
  and party_type = p_party_type
  and nvl(use_in_customer_dashboard,'Y') = 'N'
  UNION
  Select NULL
  from csc_prof_groups_vl
  where group_id = P_GROUP_ID
  and party_type = 'ALL'
  and nvl(use_in_customer_dashboard,'Y') = 'N';
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = CSC_CORE_UTILS_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_GROUP_ID is not NULL and p_GROUP_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
/*         IF p_GROUP_ID = CSC_CORE_UTILS_PVT.G_MISS_NUM
	    THEN
    		x_return_status := FND_API.G_RET_STS_ERROR;
 		CSC_CORE_UTILS_PVT.mandatory_arg_error(
				p_api_name => p_api_name,
				p_argument => 'p_GROUP_ID',
				p_argument_value => p_GROUP_ID);
*/
         IF p_GROUP_ID is not NULL and p_GROUP_ID <> CSC_CORE_UTILS_PVT.G_MISS_NUM
	    THEN
		Open C1;
		Fetch C1 into l_dummy;
		IF C1%NOTFOUND THEN
        		x_return_status := FND_API.G_RET_STS_ERROR;
        		CSC_CORE_UTILS_PVT.Add_Invalid_Argument_Msg(
					p_api_name => p_api_name,
			            p_argument_value  => p_GROUP_ID,
			            p_argument  => 'P_GROUP_ID' );
	        END IF;
		CLOSE C1;
	 END IF;
      ELSIF(p_validation_mode = CSC_CORE_UTILS_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_GROUP_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
         IF p_GROUP_ID is not NULL and p_GROUP_ID <> CSC_CORE_UTILS_PVT.G_MISS_NUM
	    THEN
		Open C1;
		Fetch C1 into l_dummy;
		IF C1%NOTFOUND THEN
        		x_return_status := FND_API.G_RET_STS_ERROR;
        		CSC_CORE_UTILS_PVT.Add_Invalid_Argument_Msg(
					p_api_name => p_api_name,
			            p_argument_value  => p_GROUP_ID,
			            p_argument  => 'P_GROUP_ID' );
	         END IF;
		Close C1;
         END IF;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_GROUP_ID;


PROCEDURE Validate_DASHBOARD_GROUP_FLAG (
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_DASHBOARD_GROUP_FLAG       IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )
IS
 p_Api_Name VARCHAR2(100) := 'Validate_Dashboard_Group_Flag';
BEGIN

null;
/*
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- validate NOT NULL column
      IF(p_DASHBOARD_GROUP_FLAG is NULL)
      THEN
               x_return_status := FND_API.G_RET_STS_ERROR;
		     CSC_CORE_UTILS_PVT.mandatory_arg_error(
			       p_api_name => p_api_name,
		            p_argument => 'P_DASHBOARD_GROUP_FLAG',
				  p_argument_value => p_dashboard_group_flag);
      END IF;

      IF(p_validation_mode = CSC_CORE_UTILS_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_DASHBOARD_GROUP_FLAG is not NULL and p_DASHBOARD_GROUP_FLAG <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          IF p_DASHBOARD_GROUP_FLAG is not NULL AND
			  p_DASHBOARD_GROUP_FLAG <> CSC_CORE_UTILS_PVT.G_MISS_CHAR
          THEN
		  IF p_DASHBOARD_GROUP_FLAG NOT IN ('Y','N')
		  THEN
		     x_return_status := FND_API.G_RET_STS_ERROR;
		     CSC_CORE_UTILS_PVT.Add_Invalid_Argument_Msg(
					  p_api_name => p_api_name,
				          p_argument_value  => p_dashboard_group_flag,
					  p_argument  => 'P_DASHBOARD_GROUP_FLAG');
	       END IF;
          END IF;
      ELSIF(p_validation_mode = CSC_CORE_UTILS_PVT.G_UPDATE)
	 THEN
        IF p_DASHBOARD_GROUP_FLAG IS NOT NULL AND
				p_DASHBOARD_GROUP_FLAG <> CSC_CORE_UTILS_PVT.G_MISS_CHAR
	   THEN
		IF p_DASHBOARD_GROUP_FLAG NOT IN ('Y','N')
		THEN
		     x_return_status := FND_API.G_RET_STS_ERROR;
		     CSC_CORE_UTILS_PVT.Add_Invalid_Argument_Msg(
					  p_api_name => p_api_name,
				          p_argument_value  => p_dashboard_group_flag,
					  p_argument  => 'P_Dashboard_Group_Flag');
          END IF;
        END IF;
	 END IF;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
*/

END Validate_DASHBOARD_GROUP_FLAG;


PROCEDURE Validate_CURRENCY_CODE (
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_CURRENCY_CODE                IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )
IS
 p_Api_Name VARCHAR2(100) := 'Validate_Currency_Code';
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

	 IF (p_currency_Code <> CSC_CORE_UTILS_PVT.G_MISS_CHAR ) AND
	        p_currency_code IS NOT NULL
      THEN
	    IF CSC_CORE_UTILS_PVT.Currency_code_not_exists(
				   p_effective_date  => sysdate,
				   p_currency_code   => p_currency_code ) <> FND_API.G_RET_STS_SUCCESS
	    THEN

		  x_return_status := FND_API.G_RET_STS_ERROR;
		  CSC_CORE_UTILS_PVT.Add_Invalid_Argument_Msg(
					  p_api_name => p_api_name,
				          p_argument_value  => p_currency_code,
					  p_argument  => 'P_CURRENCY_CODE');

         END IF;
      END IF;
	 -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_CURRENCY_CODE;


PROCEDURE Validate_PROF_MODULE_GRP_Rec(
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PROF_MODULE_GRP_Rec     IN    PROF_MODULE_GRP_Rec_Type,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )
IS
 p_Api_Name VARCHAR2(100) := 'Validate_PROF_MODULE_GRP_Rec';
 l_function_name VARCHAR2(240);
 l_group_flag    VARCHAR2(240);
 X               NUMBER;

 Cursor C1(c_form_function_id number) is
  Select function_name
  from fnd_form_functions
  where function_id = c_form_function_id;
/*
 Cursor C2 (c_group_id number) is
  Select use_in_customer_dashboard
  from csc_prof_groups_vl
  where group_id = c_group_id;
*/

/* BUG 1806606 - SRP2:PREFERENCES- MULTI-RECORDS (SAME TYPE) CAN BE SAVED
FOR MODULE W/O PROBLEM- to solve this problem this cursor is added*/

 Cursor C3(c_form_function_name varchar2 ,c_party_type varchar2,
           c_resp_id number, c_resp_appl_id number ) is
 select count(*) from csc_prof_module_groups
 where form_function_name=c_form_function_name
 and party_type=c_party_type
 and responsibility_id = c_resp_id
 and resp_appl_id = c_resp_appl_id;

 Cursor C4(c_form_function_name varchar2 ,c_party_type varchar2,
           c_resp_id number, c_resp_appl_id number, c_mod_grp_id number ) is
 select count(*) from csc_prof_module_groups
 where form_function_name=c_form_function_name
 and party_type=c_party_type
 and responsibility_id = c_resp_id
 and resp_appl_id = c_resp_appl_id
 and module_group_id <>  c_mod_grp_id;

BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF p_prof_module_grp_rec.form_function_name IS NULL then
	 	OPEN C1(p_PROF_MODULE_GRP_Rec.form_function_id);
	 	FETCH C1 into l_function_name;
	 	CLOSE C1;
      ELSE
		l_function_name := p_prof_module_grp_rec.form_function_name;
      END IF;

      If ( p_prof_module_grp_rec.group_id is null
         or p_prof_module_grp_rec.group_id = CSC_CORE_UTILS_PVT.G_MISS_NUM )
       and ( p_prof_module_grp_rec.dashboard_group_id is null
           or p_prof_module_grp_rec.dashboard_group_id = CSC_CORE_UTILS_PVT.G_MISS_NUM ) then

           x_return_status := FND_API.G_RET_STS_ERROR;
           FND_MESSAGE.Set_Name('CSC', 'CSC_PROFILE_GROUP_UNDEFINED');

      End If;



      if p_Validation_mode = CSC_CORE_UTILS_PVT.G_CREATE then
        Open C3(p_prof_module_grp_rec.form_function_name,p_prof_module_grp_rec.party_type,
              p_prof_module_grp_rec.responsibility_id, p_prof_module_grp_rec.resp_appl_id);
        Fetch C3 into x;
        Close C3;

        If x<>0 then   -- and P_Validation_mode=CSC_CORE_UTILS_PVT.G_CREATE then
           x_return_status := FND_API.G_RET_STS_ERROR;
           FND_MESSAGE.Set_Name('CSC', 'CSC_PROFILE_DUPLICATE_RECORD');
        End If;

      elsif p_validation_mode = CSC_CORE_UTILS_PVT.G_UPDATE then

        Open C4(p_prof_module_grp_rec.form_function_name,p_prof_module_grp_rec.party_type,
              p_prof_module_grp_rec.responsibility_id, p_prof_module_grp_rec.resp_appl_id,
              p_prof_module_grp_rec.module_group_id);
        Fetch C4 into x;
        Close C4;

        If x<>0 then
           x_return_status := FND_API.G_RET_STS_ERROR;
           FND_MESSAGE.Set_Name('CSC', 'CSC_PROFILE_DUPLICATE_RECORD');
        End If;

      end if;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_PROF_MODULE_GRP_Rec;


PROCEDURE Validate_DASHBOARD_GROUP_ID (
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_DASHBOARD_GROUP_ID         IN   NUMBER,
    P_PARTY_TYPE		 IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )
IS
 p_Api_Name VARCHAR2(100) := 'Validate_Dashboard_Group_Id';
 --keep an UNION fo r ALL party type..
 Cursor C1 is
  Select NULL
  from csc_prof_groups_vl
  where group_id = P_DASHBOARD_GROUP_ID
  and party_type = p_party_type
  and  nvl(use_in_customer_dashboard,'N') = 'Y'
  UNION
  Select NULL
  from csc_prof_groups_vl
  where group_id = P_DASHBOARD_GROUP_ID
  and party_type = 'ALL'
  and  nvl(use_in_customer_dashboard,'N') = 'Y';
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF(p_validation_mode = CSC_CORE_UTILS_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_DASHBOARD_GROUP_ID is not NULL and p_DASHBOARD_GROUP_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;

         IF p_DASHBOARD_GROUP_ID is not NULL and p_DASHBOARD_GROUP_ID <> CSC_CORE_UTILS_PVT.G_MISS_NUM
	    THEN
		Open C1;
		Fetch C1 into l_dummy;
		IF C1%NOTFOUND THEN
        		x_return_status := FND_API.G_RET_STS_ERROR;
        		CSC_CORE_UTILS_PVT.Add_Invalid_Argument_Msg(
					p_api_name => p_api_name,
			            p_argument_value  => p_DASHBOARD_GROUP_ID,
			            p_argument  => 'P_DASHBOARD_GROUP_ID' );
	         END IF;
		CLOSE C1;
         END IF;
      ELSIF(p_validation_mode = CSC_CORE_UTILS_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_DASHBOARD_GROUP_ID <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
         IF p_DASHBOARD_GROUP_ID is not NULL and p_DASHBOARD_GROUP_ID <> CSC_CORE_UTILS_PVT.G_MISS_NUM
	    THEN
		Open C1;
		Fetch C1 into l_dummy;
		IF C1%NOTFOUND THEN
        		x_return_status := FND_API.G_RET_STS_ERROR;
        		CSC_CORE_UTILS_PVT.Add_Invalid_Argument_Msg(
					p_api_name => p_api_name,
			            p_argument_value  => p_DASHBOARD_GROUP_ID,
			            p_argument  => 'P_DASHBOARD_GROUP_ID' );
                END IF;
		Close C1;
	 END IF;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_DASHBOARD_GROUP_ID;



PROCEDURE Validate_prof_module_groups(
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_level           IN   NUMBER := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    P_Validation_mode            IN   VARCHAR2,
    P_PROF_MODULE_GRP_Rec     IN    PROF_MODULE_GRP_Rec_Type,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )
IS
l_api_name   CONSTANT VARCHAR2(30) := 'Validate_Prof_Module_Groups';
 BEGIN


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_validation_level > CSC_CORE_UTILS_PVT.G_VALID_LEVEL_NONE) THEN

		Validate_MODULE_GROUP_ID(
              p_init_msg_list          => CSC_CORE_UTILS_PVT.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_MODULE_GROUP_ID   => P_PROF_MODULE_GRP_Rec.MODULE_GROUP_ID,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

    /*      Validate_FORM_FUNCTION_ID(
              p_init_msg_list          => CSC_CORE_UTILS_PVT.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_FORM_FUNCTION_ID   => P_PROF_MODULE_GRP_Rec.FORM_FUNCTION_ID,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
*/

          Validate_FORM_FUNCTION_NAME(
              p_init_msg_list          => CSC_CORE_UTILS_PVT.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_FORM_FUNCTION_NAME   => P_PROF_MODULE_GRP_Rec.FORM_FUNCTION_NAME,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_FORM_FUNCTION_NAME(
              p_init_msg_list          => CSC_CORE_UTILS_PVT.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_FORM_FUNCTION_NAME   => P_PROF_MODULE_GRP_Rec.FORM_FUNCTION_NAME,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PARTY_TYPE(
              p_init_msg_list          => CSC_CORE_UTILS_PVT.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PARTY_TYPE   => P_PROF_MODULE_GRP_Rec.PARTY_TYPE,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_GROUP_ID(
              p_init_msg_list          => CSC_CORE_UTILS_PVT.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_GROUP_ID      => P_PROF_MODULE_GRP_Rec.GROUP_ID,
    		  P_PARTY_TYPE     => P_PROF_MODULE_GRP_Rec.PARTY_TYPE,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

    /*      Validate_DASHBOARD_GROUP_FLAG(
              p_init_msg_list          => CSC_CORE_UTILS_PVT.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_DASHBOARD_GROUP_FLAG   => P_PROF_MODULE_GRP_Rec.DASHBOARD_GROUP_FLAG,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
*/

          Validate_CURRENCY_CODE(
              p_init_msg_list          => CSC_CORE_UTILS_PVT.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_CURRENCY_CODE   => P_PROF_MODULE_GRP_Rec.CURRENCY_CODE,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

        --Validate seeded flag

        CSC_CORE_UTILS_PVT.Validate_Seeded_Flag(
         p_api_name        =>'CSC_PROF_MODULE_GROUPS_PVT.VALIDATE_SEEDED_FLAG',
         p_seeded_flag     => p_PROF_MODULE_GRP_rec.seeded_flag,
         x_return_status   => x_return_status );

        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE FND_API.G_EXC_ERROR;
        END IF;

     /* This Call added for Enhancement 1781726 for Validating Application_id*/

        CSC_CORE_UTILS_PVT.Validate_APPLICATION_ID (
           P_Init_Msg_List              => CSC_CORE_UTILS_PVT.G_FALSE,
           P_Application_ID             => p_PROF_MODULE_GRP_rec.application_id,
           X_Return_Status              => x_return_status,
           X_Msg_Count                  => x_msg_count,
           X_Msg_Data                   => x_msg_data,
           p_effective_date             => SYSDATE );

        IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                RAISE FND_API.G_EXC_ERROR;
        END IF;

         Validate_DASHBOARD_GROUP_ID(
              p_init_msg_list          => CSC_CORE_UTILS_PVT.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_DASHBOARD_GROUP_ID     => P_PROF_MODULE_GRP_Rec.DASHBOARD_GROUP_ID,

              P_PARTY_TYPE             => P_PROF_MODULE_GRP_Rec.PARTY_TYPE,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

           Validate_PROF_MODULE_GRP_Rec(
              p_init_msg_list          => CSC_CORE_UTILS_PVT.G_FALSE,
              p_validation_mode        => p_validation_mode,
                  p_PROF_MODULE_GRP_Rec    => P_PROF_MODULE_GRP_Rec,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;





      END IF;


END Validate_prof_module_groups;

End CSC_PROF_MODULE_GROUPS_PVT;

/
