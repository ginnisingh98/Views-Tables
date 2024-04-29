--------------------------------------------------------
--  DDL for Package Body CSC_PLAN_LINES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSC_PLAN_LINES_PVT" as
/* $Header: cscvplnb.pls 115.16 2002/11/25 12:35:17 bhroy ship $ */
-- Start of Comments
-- Package name     : CSC_PLAN_LINES_PVT
-- Purpose          : Private package to perform inserts, updates and delete operations
--                    on CSC_PLAN_LINES table. It contains procedures to perform item
--                    level validations if validation level is set to 100 (FULL).
-- History          :
-- MM-DD-YYYY    NAME          MODIFICATIONS
-- 10-21-1999    dejoseph      Created.
-- 12-08-1999    dejoseph      'Arcs'ed in for first code freeze.
-- 12-21-1999    dejoseph      'Arcs'ed in for second code freeze.
-- 01-03-2000    dejoseph      'Arcs'ed in for third code freeze. (10-JAN-2000)
-- 01-31-2000    dejoseph      'Arcs'ed in for fourth code freeze. (07-FEB-2000)
-- 02-13-2000    dejoseph      'Arcs'ed on for fifth code freeze. (21-FEB-2000)
-- 02-28-2000    dejoseph      'Arcs'ed on for sixth code freeze. (06-MAR-2000)
-- 11-11-2002	bhroy		NOCOPY changes made
-- 11-25-2002	bhroy		FND_API defaults removed, added WHENEVER OSERROR EXIT FAILURE ROLLBACK;

-- NOTE             :
-- End of Comments

G_PKG_NAME        CONSTANT VARCHAR2(30) := 'CSC_PLAN_LINES_PVT';
G_FILE_NAME       CONSTANT VARCHAR2(12) := 'cscvplnb.pls';

PROCEDURE convert_columns_to_rec_type(
    P_LINE_ID                    IN   NUMBER,
    P_PLAN_ID                    IN   NUMBER,
    P_CONDITION_ID               IN   NUMBER,
    P_CREATION_DATE              IN   DATE,
    P_LAST_UPDATE_DATE           IN   DATE,
    P_CREATED_BY                 IN   NUMBER,
    P_LAST_UPDATED_BY            IN   NUMBER,
    P_LAST_UPDATE_LOGIN          IN   NUMBER,
    P_ATTRIBUTE1                 IN   VARCHAR2,
    P_ATTRIBUTE2                 IN   VARCHAR2 ,
    P_ATTRIBUTE3                 IN   VARCHAR2,
    P_ATTRIBUTE4                 IN   VARCHAR2,
    P_ATTRIBUTE5                 IN   VARCHAR2,
    P_ATTRIBUTE6                 IN   VARCHAR2,
    P_ATTRIBUTE7                 IN   VARCHAR2,
    P_ATTRIBUTE8                 IN   VARCHAR2,
    P_ATTRIBUTE9                 IN   VARCHAR2,
    P_ATTRIBUTE10                IN   VARCHAR2,
    P_ATTRIBUTE11                IN   VARCHAR2,
    P_ATTRIBUTE12                IN   VARCHAR2,
    P_ATTRIBUTE13                IN   VARCHAR2,
    P_ATTRIBUTE14                IN   VARCHAR2,
    P_ATTRIBUTE15                IN   VARCHAR2,
    P_ATTRIBUTE_CATEGORY         IN   VARCHAR2,
    P_OBJECT_VERSION_NUMBER      IN   NUMBER ,
    x_csc_plan_lines_rec         OUT  NOCOPY CSC_PLAN_LINES_REC_TYPE)
IS
BEGIN
   x_csc_plan_lines_rec.LINE_ID               := P_LINE_ID;
   x_csc_plan_lines_rec.PLAN_ID               := P_PLAN_ID ;
   x_csc_plan_lines_rec.CONDITION_ID          := P_CONDITION_ID ;
   x_csc_plan_lines_rec.CREATION_DATE         := P_CREATION_DATE ;
   x_csc_plan_lines_rec.LAST_UPDATE_DATE      := P_LAST_UPDATE_DATE ;
   x_csc_plan_lines_rec.CREATED_BY            := P_CREATED_BY ;
   x_csc_plan_lines_rec.LAST_UPDATED_BY       := P_LAST_UPDATED_BY ;
   x_csc_plan_lines_rec.LAST_UPDATE_LOGIN     := P_LAST_UPDATE_LOGIN ;
   x_csc_plan_lines_rec.ATTRIBUTE1            := P_ATTRIBUTE1 ;
   x_csc_plan_lines_rec.ATTRIBUTE2            := P_ATTRIBUTE2 ;
   x_csc_plan_lines_rec.ATTRIBUTE3            := P_ATTRIBUTE3 ;
   x_csc_plan_lines_rec.ATTRIBUTE4            := P_ATTRIBUTE4 ;
   x_csc_plan_lines_rec.ATTRIBUTE5            := P_ATTRIBUTE5 ;
   x_csc_plan_lines_rec.ATTRIBUTE6            := P_ATTRIBUTE6 ;
   x_csc_plan_lines_rec.ATTRIBUTE7            := P_ATTRIBUTE7 ;
   x_csc_plan_lines_rec.ATTRIBUTE8            := P_ATTRIBUTE8 ;
   x_csc_plan_lines_rec.ATTRIBUTE9            := P_ATTRIBUTE9 ;
   x_csc_plan_lines_rec.ATTRIBUTE10           := P_ATTRIBUTE10 ;
   x_csc_plan_lines_rec.ATTRIBUTE11           := P_ATTRIBUTE11 ;
   x_csc_plan_lines_rec.ATTRIBUTE12           := P_ATTRIBUTE12 ;
   x_csc_plan_lines_rec.ATTRIBUTE13           := P_ATTRIBUTE13 ;
   x_csc_plan_lines_rec.ATTRIBUTE14           := P_ATTRIBUTE14 ;
   x_csc_plan_lines_rec.ATTRIBUTE15           := P_ATTRIBUTE15 ;
   x_csc_plan_lines_rec.ATTRIBUTE_CATEGORY    := P_ATTRIBUTE_CATEGORY ;
   x_csc_plan_lines_rec.OBJECT_VERSION_NUMBER := P_OBJECT_VERSION_NUMBER ;

END convert_columns_to_rec_type;


/* Overloaded procedure to take a detailed parameter list instead of a
   record type parameter */

PROCEDURE Create_plan_lines(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    P_LINE_ID                    IN   NUMBER,
    P_PLAN_ID                    IN   NUMBER,
    P_CONDITION_ID               IN   NUMBER,
    P_CREATION_DATE              IN   DATE,
    P_LAST_UPDATE_DATE           IN   DATE,
    P_CREATED_BY                 IN   NUMBER,
    P_LAST_UPDATED_BY            IN   NUMBER,
    P_LAST_UPDATE_LOGIN          IN   NUMBER,
    P_ATTRIBUTE1                 IN   VARCHAR2,
    P_ATTRIBUTE2                 IN   VARCHAR2,
    P_ATTRIBUTE3                 IN   VARCHAR2,
    P_ATTRIBUTE4                 IN   VARCHAR2,
    P_ATTRIBUTE5                 IN   VARCHAR2,
    P_ATTRIBUTE6                 IN   VARCHAR2,
    P_ATTRIBUTE7                 IN   VARCHAR2,
    P_ATTRIBUTE8                 IN   VARCHAR2,
    P_ATTRIBUTE9                 IN   VARCHAR2,
    P_ATTRIBUTE10                IN   VARCHAR2,
    P_ATTRIBUTE11                IN   VARCHAR2,
    P_ATTRIBUTE12                IN   VARCHAR2,
    P_ATTRIBUTE13                IN   VARCHAR2,
    P_ATTRIBUTE14                IN   VARCHAR2,
    P_ATTRIBUTE15                IN   VARCHAR2,
    P_ATTRIBUTE_CATEGORY         IN   VARCHAR2,
    P_OBJECT_VERSION_NUMBER      IN   NUMBER,
    X_LINE_ID                    OUT  NOCOPY NUMBER,
    X_OBJECT_VERSION_NUMBER      OUT  NOCOPY NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    )
IS
   l_csc_plan_lines_rec       CSC_PLAN_LINES_REC_TYPE;

BEGIN
   CONVERT_COLUMNS_TO_REC_TYPE(
      P_LINE_ID               => p_line_id,
      P_PLAN_ID               => p_plan_id,
      P_CONDITION_ID          => p_condition_id,
      P_CREATION_DATE         => p_creation_date,
      P_LAST_UPDATE_DATE      => p_last_update_date,
      P_CREATED_BY            => p_created_by,
      P_LAST_UPDATED_BY       => p_last_updated_by,
      P_LAST_UPDATE_LOGIN     => p_last_update_login,
      P_ATTRIBUTE1            => p_attribute1,
      P_ATTRIBUTE2            => p_attribute2,
      P_ATTRIBUTE3            => p_attribute3,
      P_ATTRIBUTE4            => p_attribute4,
      P_ATTRIBUTE5            => p_attribute5,
      P_ATTRIBUTE6            => p_attribute6,
      P_ATTRIBUTE7            => p_attribute7,
      P_ATTRIBUTE8            => p_attribute8,
      P_ATTRIBUTE9            => p_attribute9,
      P_ATTRIBUTE10           => p_attribute10,
      P_ATTRIBUTE11           => p_attribute11,
      P_ATTRIBUTE12           => p_attribute12,
      P_ATTRIBUTE13           => p_attribute13,
      P_ATTRIBUTE14           => p_attribute14,
      P_ATTRIBUTE15           => p_attribute15,
      P_ATTRIBUTE_CATEGORY    => p_attribute_category,
      P_OBJECT_VERSION_NUMBER => p_object_version_number,
      x_csc_plan_lines_rec    => l_csc_plan_lines_rec);

-- issue a call to the create_plan_lines proc. that accepts record_type parameters.

   Create_plan_lines(
      P_Api_Version_Number    => p_api_version_number,
      P_Init_Msg_List         => p_init_msg_list,
      P_Commit                => p_commit,
      P_Validation_level      => p_validation_level,
      P_CSC_PLAN_LINES_Rec    => l_csc_plan_lines_rec,
      X_LINE_ID               => x_line_id,
      X_OBJECT_VERSION_NUMBER => x_object_version_number,
      X_Return_Status         => x_return_status,
      X_Msg_Count             => x_msg_count,
      X_Msg_Data              => x_msg_data );

END  Create_plan_lines; /* overloaded procedure */



PROCEDURE Create_plan_lines(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    P_CSC_PLAN_LINES_Rec         IN   CSC_PLAN_LINES_Rec_Type,
    X_LINE_ID                    OUT  NOCOPY NUMBER,
    X_OBJECT_VERSION_NUMBER      OUT  NOCOPY NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    )
IS
   l_api_name                CONSTANT VARCHAR2(30) := 'Create_plan_lines';
   l_api_version_number      CONSTANT NUMBER       := 1.0;
   l_return_status_full      VARCHAR2(1);
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_PLAN_LINES_PVT;

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

      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      IF FND_GLOBAL.User_Id IS NULL
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name(CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'UT_CANNOT_GET_PROFILE_VALUE');
              FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
              -- FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL )
      THEN
          -- Invoke validation procedures
          Validate_csc_plan_lines(
              p_init_msg_list       => FND_API.G_FALSE,
              p_validation_level    => p_validation_level,
              p_validation_mode     => CSC_CORE_UTILS_PVT.G_CREATE,
              P_CSC_PLAN_LINES_Rec  => P_CSC_PLAN_LINES_Rec,
              x_return_status       => x_return_status,
              x_msg_count           => x_msg_count,
              x_msg_data            => x_msg_data);
         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF;

      -- Invoke table handler(CSC_PLAN_LINES_PKG.Insert_Row)
      CSC_PLAN_LINES_PKG.Insert_Row(
          px_LINE_ID               => x_LINE_ID,
          p_PLAN_ID                => p_CSC_PLAN_LINES_rec.PLAN_ID,
          p_CONDITION_ID           => p_CSC_PLAN_LINES_rec.CONDITION_ID,
          p_CREATION_DATE          => SYSDATE,
          p_LAST_UPDATE_DATE       => SYSDATE,
          p_CREATED_BY             => FND_GLOBAL.USER_ID,
          p_LAST_UPDATED_BY        => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_LOGIN      => FND_GLOBAL.CONC_LOGIN_ID,
          p_ATTRIBUTE1             => p_CSC_PLAN_LINES_rec.ATTRIBUTE1,
          p_ATTRIBUTE2             => p_CSC_PLAN_LINES_rec.ATTRIBUTE2,
          p_ATTRIBUTE3             => p_CSC_PLAN_LINES_rec.ATTRIBUTE3,
          p_ATTRIBUTE4             => p_CSC_PLAN_LINES_rec.ATTRIBUTE4,
          p_ATTRIBUTE5             => p_CSC_PLAN_LINES_rec.ATTRIBUTE5,
          p_ATTRIBUTE6             => p_CSC_PLAN_LINES_rec.ATTRIBUTE6,
          p_ATTRIBUTE7             => p_CSC_PLAN_LINES_rec.ATTRIBUTE7,
          p_ATTRIBUTE8             => p_CSC_PLAN_LINES_rec.ATTRIBUTE8,
          p_ATTRIBUTE9             => p_CSC_PLAN_LINES_rec.ATTRIBUTE9,
          p_ATTRIBUTE10            => p_CSC_PLAN_LINES_rec.ATTRIBUTE10,
          p_ATTRIBUTE11            => p_CSC_PLAN_LINES_rec.ATTRIBUTE11,
          p_ATTRIBUTE12            => p_CSC_PLAN_LINES_rec.ATTRIBUTE12,
          p_ATTRIBUTE13            => p_CSC_PLAN_LINES_rec.ATTRIBUTE13,
          p_ATTRIBUTE14            => p_CSC_PLAN_LINES_rec.ATTRIBUTE14,
          p_ATTRIBUTE15            => p_CSC_PLAN_LINES_rec.ATTRIBUTE15,
          p_ATTRIBUTE_CATEGORY     => p_CSC_PLAN_LINES_rec.ATTRIBUTE_CATEGORY,
          x_OBJECT_VERSION_NUMBER  => X_OBJECT_VERSION_NUMBER);

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      CSC_CORE_UTILS_PVT.HANDLE_EXCEPTIONS(
            P_API_NAME        => L_API_NAME,
            P_PKG_NAME        => G_PKG_NAME,
            P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR,
            P_PACKAGE_TYPE    => CSC_CORE_UTILS_PVT.G_PVT,
            X_MSG_COUNT       => X_MSG_COUNT,
            X_MSG_DATA        => X_MSG_DATA,
            X_RETURN_STATUS   => X_RETURN_STATUS);
      APP_EXCEPTION.RAISE_EXCEPTION;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      CSC_CORE_UTILS_PVT.HANDLE_EXCEPTIONS(
            P_API_NAME        => L_API_NAME,
            P_PKG_NAME        => G_PKG_NAME,
            P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,
            P_PACKAGE_TYPE    => CSC_CORE_UTILS_PVT.G_PVT,
            X_MSG_COUNT       => X_MSG_COUNT,
            X_MSG_DATA        => X_MSG_DATA,
            X_RETURN_STATUS   => X_RETURN_STATUS);
      APP_EXCEPTION.RAISE_EXCEPTION;

   WHEN OTHERS THEN
      CSC_CORE_UTILS_PVT.HANDLE_EXCEPTIONS(
            P_API_NAME        => L_API_NAME,
            P_PKG_NAME        => G_PKG_NAME,
            P_EXCEPTION_LEVEL => CSC_CORE_UTILS_PVT.G_MSG_LVL_OTHERS,
            P_PACKAGE_TYPE    => CSC_CORE_UTILS_PVT.G_PVT,
            X_MSG_COUNT       => X_MSG_COUNT,
            X_MSG_DATA        => X_MSG_DATA,
            X_RETURN_STATUS   => X_RETURN_STATUS);
      APP_EXCEPTION.RAISE_EXCEPTION;

End Create_plan_lines;

/* Overloaded procedure to take a detailed parameter list instead of a
   record type parameter */

PROCEDURE Update_plan_lines(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    P_LINE_ID                    IN   NUMBER,
    P_PLAN_ID                    IN   NUMBER,
    P_CONDITION_ID               IN   NUMBER,
    P_CREATION_DATE              IN   DATE,
    P_LAST_UPDATE_DATE           IN   DATE,
    P_CREATED_BY                 IN   NUMBER,
    P_LAST_UPDATED_BY            IN   NUMBER,
    P_LAST_UPDATE_LOGIN          IN   NUMBER,
    P_ATTRIBUTE1                 IN   VARCHAR2,
    P_ATTRIBUTE2                 IN   VARCHAR2,
    P_ATTRIBUTE3                 IN   VARCHAR2,
    P_ATTRIBUTE4                 IN   VARCHAR2,
    P_ATTRIBUTE5                 IN   VARCHAR2,
    P_ATTRIBUTE6                 IN   VARCHAR2,
    P_ATTRIBUTE7                 IN   VARCHAR2,
    P_ATTRIBUTE8                 IN   VARCHAR2,
    P_ATTRIBUTE9                 IN   VARCHAR2,
    P_ATTRIBUTE10                IN   VARCHAR2,
    P_ATTRIBUTE11                IN   VARCHAR2,
    P_ATTRIBUTE12                IN   VARCHAR2,
    P_ATTRIBUTE13                IN   VARCHAR2,
    P_ATTRIBUTE14                IN   VARCHAR2,
    P_ATTRIBUTE15                IN   VARCHAR2,
    P_ATTRIBUTE_CATEGORY         IN   VARCHAR2,
    P_OBJECT_VERSION_NUMBER      IN   NUMBER,
    X_OBJECT_VERSION_NUMBER      OUT  NOCOPY NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2)
IS

   l_csc_plan_lines_rec       CSC_PLAN_LINES_REC_TYPE;

BEGIN
   convert_columns_to_rec_type(
      P_LINE_ID               => p_line_id,
      P_PLAN_ID               => p_plan_id,
      P_CONDITION_ID          => p_condition_id,
      P_CREATION_DATE         => p_creation_date,
      P_LAST_UPDATE_DATE      => p_last_update_date,
      P_CREATED_BY            => p_created_by,
      P_LAST_UPDATED_BY       => p_last_updated_by,
      P_LAST_UPDATE_LOGIN     => p_last_update_login,
      P_ATTRIBUTE1            => p_attribute1,
      P_ATTRIBUTE2            => p_attribute2,
      P_ATTRIBUTE3            => p_attribute3,
      P_ATTRIBUTE4            => p_attribute4,
      P_ATTRIBUTE5            => p_attribute5,
      P_ATTRIBUTE6            => p_attribute6,
      P_ATTRIBUTE7            => p_attribute7,
      P_ATTRIBUTE8            => p_attribute8,
      P_ATTRIBUTE9            => p_attribute9,
      P_ATTRIBUTE10           => p_attribute10,
      P_ATTRIBUTE11           => p_attribute11,
      P_ATTRIBUTE12           => p_attribute12,
      P_ATTRIBUTE13           => p_attribute13,
      P_ATTRIBUTE14           => p_attribute14,
      P_ATTRIBUTE15           => p_attribute15,
      P_ATTRIBUTE_CATEGORY    => p_attribute_category,
      P_OBJECT_VERSION_NUMBER => p_object_version_number,
      x_csc_plan_lines_rec    => l_csc_plan_lines_rec);

-- issue a call to the create_plan_lines proc. that accepts record_type parameters.

   Update_plan_lines(
      P_Api_Version_Number    => p_api_version_number,
      P_Init_Msg_List         => p_init_msg_list,
      P_Commit                => p_commit,
      P_Validation_level      => p_validation_level,
      P_CSC_PLAN_LINES_Rec    => l_csc_plan_lines_rec,
      X_OBJECT_VERSION_NUMBER => x_object_version_number,
      X_Return_Status         => x_return_status,
      X_Msg_Count             => x_msg_count,
      X_Msg_Data              => x_msg_data );

END  update_plan_lines;  /* end of overloaded update */

PROCEDURE Update_plan_lines(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    P_CSC_PLAN_LINES_Rec         IN   CSC_PLAN_LINES_Rec_Type,
    X_OBJECT_VERSION_NUMBER      OUT  NOCOPY NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    )
IS
   Cursor C_Get_plan_lines(C_LINE_ID Number) IS
    Select rowid,             LINE_ID,          PLAN_ID,
           CONDITION_ID,      LAST_UPDATE_DATE, CREATION_DATE,
           LAST_UPDATED_BY,   CREATED_BY,       LAST_UPDATE_LOGIN,
           ATTRIBUTE1,        ATTRIBUTE2,       ATTRIBUTE3,
           ATTRIBUTE4,        ATTRIBUTE5,       ATTRIBUTE6,
           ATTRIBUTE7,        ATTRIBUTE8,       ATTRIBUTE9,
           ATTRIBUTE10,       ATTRIBUTE11,      ATTRIBUTE12,
           ATTRIBUTE13,       ATTRIBUTE14,      ATTRIBUTE15,
           ATTRIBUTE_CATEGORY,OBJECT_VERSION_NUMBER
    From  CSC_PLAN_LINES
    where line_id = c_line_id
    For Update NOWAIT;

   l_api_name                CONSTANT VARCHAR2(30) := 'Update_plan_lines';
   l_api_version_number      CONSTANT NUMBER   := 1.0;

   l_ref_CSC_PLAN_LINES_rec  CSC_plan_lines_PVT.CSC_PLAN_LINES_Rec_Type;
   l_tar_CSC_PLAN_LINES_rec  CSC_plan_lines_PVT.CSC_PLAN_LINES_Rec_Type := P_CSC_PLAN_LINES_Rec;
   l_rowid  ROWID;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_PLAN_LINES_PVT;

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

      Open C_Get_plan_lines( l_tar_CSC_PLAN_LINES_rec.LINE_ID);

      Fetch C_Get_plan_lines into
               l_rowid,
               l_ref_CSC_PLAN_LINES_rec.LINE_ID,
               l_ref_CSC_PLAN_LINES_rec.PLAN_ID,
               l_ref_CSC_PLAN_LINES_rec.CONDITION_ID,
               l_ref_CSC_PLAN_LINES_rec.LAST_UPDATE_DATE,
               l_ref_CSC_PLAN_LINES_rec.CREATION_DATE,
               l_ref_CSC_PLAN_LINES_rec.LAST_UPDATED_BY,
               l_ref_CSC_PLAN_LINES_rec.CREATED_BY,
               l_ref_CSC_PLAN_LINES_rec.LAST_UPDATE_LOGIN,
               l_ref_CSC_PLAN_LINES_rec.ATTRIBUTE1,
               l_ref_CSC_PLAN_LINES_rec.ATTRIBUTE2,
               l_ref_CSC_PLAN_LINES_rec.ATTRIBUTE3,
               l_ref_CSC_PLAN_LINES_rec.ATTRIBUTE4,
               l_ref_CSC_PLAN_LINES_rec.ATTRIBUTE5,
               l_ref_CSC_PLAN_LINES_rec.ATTRIBUTE6,
               l_ref_CSC_PLAN_LINES_rec.ATTRIBUTE7,
               l_ref_CSC_PLAN_LINES_rec.ATTRIBUTE8,
               l_ref_CSC_PLAN_LINES_rec.ATTRIBUTE9,
               l_ref_CSC_PLAN_LINES_rec.ATTRIBUTE10,
               l_ref_CSC_PLAN_LINES_rec.ATTRIBUTE11,
               l_ref_CSC_PLAN_LINES_rec.ATTRIBUTE12,
               l_ref_CSC_PLAN_LINES_rec.ATTRIBUTE13,
               l_ref_CSC_PLAN_LINES_rec.ATTRIBUTE14,
               l_ref_CSC_PLAN_LINES_rec.ATTRIBUTE15,
               l_ref_CSC_PLAN_LINES_rec.ATTRIBUTE_CATEGORY,
               l_ref_CSC_PLAN_LINES_rec.OBJECT_VERSION_NUMBER;

      If ( C_Get_plan_lines%NOTFOUND) Then
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
               Close     C_Get_plan_lines;
               FND_MESSAGE.Set_Name(CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'API_MISSING_UPDATE_TARGET');
               FND_MESSAGE.Set_Token ('INFO', 'plan_lines', FALSE);
               -- FND_MSG_PUB.Add;
           END IF;
           raise FND_API.G_EXC_ERROR;
      END IF;

      Close     C_Get_plan_lines;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Invoke validation procedures
          Validate_csc_plan_lines(
              p_init_msg_list       => FND_API.G_FALSE,
              p_validation_level    => p_validation_level,
              p_validation_mode     => CSC_CORE_UTILS_PVT.G_UPDATE,
              P_CSC_PLAN_LINES_Rec  => P_CSC_PLAN_LINES_Rec,
              x_return_status       => x_return_status,
              x_msg_count           => x_msg_count,
              x_msg_data            => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Invoke table handler(CSC_PLAN_LINES_PKG.Update_Row)
      CSC_PLAN_LINES_PKG.Update_Row(
          p_LINE_ID                => p_CSC_PLAN_LINES_rec.LINE_ID,
          p_PLAN_ID                => p_CSC_PLAN_LINES_rec.PLAN_ID,
          p_CONDITION_ID           => p_CSC_PLAN_LINES_rec.CONDITION_ID,
          p_CREATION_DATE          => SYSDATE,
          p_LAST_UPDATE_DATE       => SYSDATE,
          p_CREATED_BY             => FND_GLOBAL.USER_ID,
          p_LAST_UPDATED_BY        => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_LOGIN      => FND_GLOBAL.CONC_LOGIN_ID,
          p_ATTRIBUTE1             => p_CSC_PLAN_LINES_rec.ATTRIBUTE1,
          p_ATTRIBUTE2             => p_CSC_PLAN_LINES_rec.ATTRIBUTE2,
          p_ATTRIBUTE3             => p_CSC_PLAN_LINES_rec.ATTRIBUTE3,
          p_ATTRIBUTE4             => p_CSC_PLAN_LINES_rec.ATTRIBUTE4,
          p_ATTRIBUTE5             => p_CSC_PLAN_LINES_rec.ATTRIBUTE5,
          p_ATTRIBUTE6             => p_CSC_PLAN_LINES_rec.ATTRIBUTE6,
          p_ATTRIBUTE7             => p_CSC_PLAN_LINES_rec.ATTRIBUTE7,
          p_ATTRIBUTE8             => p_CSC_PLAN_LINES_rec.ATTRIBUTE8,
          p_ATTRIBUTE9             => p_CSC_PLAN_LINES_rec.ATTRIBUTE9,
          p_ATTRIBUTE10            => p_CSC_PLAN_LINES_rec.ATTRIBUTE10,
          p_ATTRIBUTE11            => p_CSC_PLAN_LINES_rec.ATTRIBUTE11,
          p_ATTRIBUTE12            => p_CSC_PLAN_LINES_rec.ATTRIBUTE12,
          p_ATTRIBUTE13            => p_CSC_PLAN_LINES_rec.ATTRIBUTE13,
          p_ATTRIBUTE14            => p_CSC_PLAN_LINES_rec.ATTRIBUTE14,
          p_ATTRIBUTE15            => p_CSC_PLAN_LINES_rec.ATTRIBUTE15,
          p_ATTRIBUTE_CATEGORY     => p_CSC_PLAN_LINES_rec.ATTRIBUTE_CATEGORY,
          x_OBJECT_VERSION_NUMBER  => X_OBJECT_VERSION_NUMBER);

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
      CSC_CORE_UTILS_PVT.HANDLE_EXCEPTIONS(
            P_API_NAME        => L_API_NAME,
            P_PKG_NAME        => G_PKG_NAME,
            P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR,
            P_PACKAGE_TYPE    => CSC_CORE_UTILS_PVT.G_PVT,
            X_MSG_COUNT       => X_MSG_COUNT,
            X_MSG_DATA        => X_MSG_DATA,
            X_RETURN_STATUS   => X_RETURN_STATUS);
      APP_EXCEPTION.RAISE_EXCEPTION;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      CSC_CORE_UTILS_PVT.HANDLE_EXCEPTIONS(
            P_API_NAME        => L_API_NAME,
            P_PKG_NAME        => G_PKG_NAME,
            P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,
            P_PACKAGE_TYPE    => CSC_CORE_UTILS_PVT.G_PVT,
            X_MSG_COUNT       => X_MSG_COUNT,
            X_MSG_DATA        => X_MSG_DATA,
            X_RETURN_STATUS   => X_RETURN_STATUS);
      APP_EXCEPTION.RAISE_EXCEPTION;

   WHEN OTHERS THEN
      CSC_CORE_UTILS_PVT.HANDLE_EXCEPTIONS(
            P_API_NAME        => L_API_NAME,
            P_PKG_NAME        => G_PKG_NAME,
            P_EXCEPTION_LEVEL => CSC_CORE_UTILS_PVT.G_MSG_LVL_OTHERS,
            P_PACKAGE_TYPE    => CSC_CORE_UTILS_PVT.G_PVT,
            X_MSG_COUNT       => X_MSG_COUNT,
            X_MSG_DATA        => X_MSG_DATA,
            X_RETURN_STATUS   => X_RETURN_STATUS);
      APP_EXCEPTION.RAISE_EXCEPTION;

End Update_plan_lines;


PROCEDURE Delete_plan_lines(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_PLAN_ID                    IN   NUMBER,
    P_LINE_ID                    IN   NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    )
IS
   l_api_name                CONSTANT VARCHAR2(30) := 'Delete_plan_lines';
   l_api_version_number      CONSTANT NUMBER       := 1.0;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_PLAN_LINES_PVT;

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

      -- Invoke table handler(CSC_PLAN_LINES_PKG.Delete_Row)
      CSC_PLAN_LINES_PKG.Delete_Row(
                            p_PLAN_ID  => P_PLAN_ID,
                            p_LINE_ID  => P_LINE_ID);

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      CSC_CORE_UTILS_PVT.HANDLE_EXCEPTIONS(
            P_API_NAME        => L_API_NAME,
            P_PKG_NAME        => G_PKG_NAME,
            P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR,
            P_PACKAGE_TYPE    => CSC_CORE_UTILS_PVT.G_PVT,
            X_MSG_COUNT       => X_MSG_COUNT,
            X_MSG_DATA        => X_MSG_DATA,
            X_RETURN_STATUS   => X_RETURN_STATUS);
      APP_EXCEPTION.RAISE_EXCEPTION;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      CSC_CORE_UTILS_PVT.HANDLE_EXCEPTIONS(
            P_API_NAME        => L_API_NAME,
            P_PKG_NAME        => G_PKG_NAME,
            P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,
            P_PACKAGE_TYPE    => CSC_CORE_UTILS_PVT.G_PVT,
            X_MSG_COUNT       => X_MSG_COUNT,
            X_MSG_DATA        => X_MSG_DATA,
            X_RETURN_STATUS   => X_RETURN_STATUS);
      APP_EXCEPTION.RAISE_EXCEPTION;

   WHEN OTHERS THEN
      CSC_CORE_UTILS_PVT.HANDLE_EXCEPTIONS(
            P_API_NAME        => L_API_NAME,
            P_PKG_NAME        => G_PKG_NAME,
            P_EXCEPTION_LEVEL => CSC_CORE_UTILS_PVT.G_MSG_LVL_OTHERS,
            P_PACKAGE_TYPE    => CSC_CORE_UTILS_PVT.G_PVT,
            X_MSG_COUNT       => X_MSG_COUNT,
            X_MSG_DATA        => X_MSG_DATA,
            X_RETURN_STATUS   => X_RETURN_STATUS);
      APP_EXCEPTION.RAISE_EXCEPTION;

End Delete_plan_lines;


-- Item-level validation procedures

PROCEDURE Validate_LINE_ID (
    P_Init_Msg_List              IN   VARCHAR2,
    P_Validation_mode            IN   VARCHAR2,
    P_LINE_ID                    IN   NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    )
IS
   cursor check_dup_line_id is
      select line_id
      from   CSC_PLAN_LINES
      where  line_id = p_line_id;

   l_line_id    number;
   l_api_name   varchar2(30) := 'Validate_Line_Id';
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- validate NOT NULL column for updates
      IF( p_validation_mode = CSC_CORE_UTILS_PVT.G_UPDATE ) THEN
         if ( p_line_id is NULL or p_line_id = FND_API.G_MISS_NUM ) then
            fnd_message.set_name (CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'CS_API_ALL_NULL_PARAMETER');
            fnd_message.set_token ('API_NAME', G_PKG_NAME||'.'|| l_api_name);
            fnd_message.set_token('NULL_PARAM', 'LINE_ID');
            x_return_status := FND_API.G_RET_STS_ERROR;
         end if;
      ELSIF( p_validation_mode = CSC_CORE_UTILS_PVT.G_CREATE AND
		   p_line_id is not NULL and p_line_id <> FND_API.G_MISS_NUM ) THEN
      -- check for duplicate line_ids.
         open check_dup_line_id;
         fetch check_dup_line_id into l_line_id;
         if check_dup_line_id%FOUND then
            fnd_message.set_name (CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'CS_API_ALL_DUPLICATE_VALUE');
            fnd_message.set_token ('API_NAME', G_PKG_NAME||'.'|| l_api_name);
            fnd_message.set_token('DUPLICATE_VAL_PARAM', 'LINE_ID');
            -- fnd_msg_pub.add;
            x_return_status := FND_API.G_RET_STS_ERROR;
         end if;
         close check_dup_line_id;
      END IF;

      IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) then
	    APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

END Validate_LINE_ID;


PROCEDURE Validate_PLAN_ID (
    P_Init_Msg_List              IN   VARCHAR2,
    P_Validation_mode            IN   VARCHAR2,
    P_PLAN_ID                    IN   NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    )
IS
   cursor c1 is
     select plan_id
     from   csc_plan_headers_b
     where  plan_id = p_plan_id;

   l_plan_id    number;
   l_api_name   varchar2(30) := 'Validate_Plan_Id';
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- validate NOT NULL column
	 IF( p_PLAN_ID is NULL or p_plan_id = FND_API.G_MISS_NUM ) then
         fnd_message.set_name (CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'CS_API_ALL_NULL_PARAMETER');
         fnd_message.set_token ('API_NAME', G_PKG_NAME||'.'|| l_api_name);
         fnd_message.set_token('NULL_PARAM', 'PLAN_ID');
         x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      -- validate for valid plan_ids.
      IF ( x_return_status = FND_API.G_RET_STS_SUCCESS ) then
         open c1;
         fetch c1 into l_plan_id;
         if c1%NOTFOUND then
            fnd_message.set_name(CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'CS_API_ALL_INVALID_ARGUMENT');
            fnd_message.set_token('API_NAME',  G_PKG_NAME||'.'|| l_api_name);
            fnd_message.set_token('VALUE',     p_plan_id);
            fnd_message.set_token('PARAMETER', 'PLAN_ID');
            x_return_status := FND_API.G_RET_STS_ERROR;
         end if;
         close c1;
      END IF;

      IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) then
	    APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data  );

END Validate_PLAN_ID;


PROCEDURE Validate_CONDITION_ID (
    P_Init_Msg_List              IN   VARCHAR2,
    P_Validation_mode            IN   VARCHAR2,
    P_PLAN_ID                    IN   NUMBER,
    P_CONDITION_ID               IN   NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    )
IS
   cursor c1 is
      select id
      from   okc_condition_headers_b
      where  id = p_condition_id;

   cursor c2 is
	 select 1
	 from   csc_plan_lines
	 where  plan_id      = p_plan_id
	 and    condition_id = p_condition_id;

   l_id          NUMBER;
   l_api_name    VARCHAR2(30) := 'Validate_Condition_Id';

BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- validate NOT NULL column
      IF( p_CONDITION_ID is NULL or p_condition_id = FND_API.G_MISS_NUM ) THEN
         fnd_message.set_name (CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'CS_API_ALL_NULL_PARAMETER');
         fnd_message.set_token ('API_NAME', G_PKG_NAME||'.'|| l_api_name);
         fnd_message.set_token('NULL_PARAM', 'CONDITION_ID');
         -- fnd_msg_pub.add;
         x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF ( x_return_status = FND_API.G_RET_STS_SUCCESS ) then
         -- validate for valid condition_id.
         open c1;
         fetch c1 into l_id;
         if c1%NOTFOUND then
            fnd_message.set_name (CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'CS_API_ALL_INVALID_ARGUMENT');
            fnd_message.set_token ('API_NAME', G_PKG_NAME||'.'||l_api_name);
            fnd_message.set_token('VALUE', p_condition_id);
            fnd_message.set_token('PARAMETER', 'CONDITION_ID');
            x_return_status := FND_API.G_RET_STS_ERROR;
         end if;
         close c1;
      END IF;

      IF ( x_return_status = FND_API.G_RET_STS_SUCCESS ) then
	    -- validate for duplicate plan_id and condition_id
	    open c2;
	    fetch c2 into l_id;
      if ( (p_validation_mode <> CSC_CORE_UTILS_PVT.G_UPDATE) AND  (c2%FOUND) ) then
            fnd_message.set_name (CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'CS_API_ALL_DUPLICATE_VALUE');
            fnd_message.set_token ('API_NAME', G_PKG_NAME||'.'|| l_api_name);
            fnd_message.set_token('DUPLICATE_VAL_PARAM', 'CONDITION_ID');
            x_return_status := FND_API.G_RET_STS_ERROR;
         end if;
         close c2;
      END IF;

	 IF ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) then
	    APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;

END Validate_CONDITION_ID;


PROCEDURE Validate_OBJECT_VERSION_NUMBER (
    P_Init_Msg_List              IN   VARCHAR2,
    P_Validation_mode            IN   VARCHAR2,
    P_OBJECT_VERSION_NUMBER      IN   NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    )
IS
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- validate NOT NULL column
      IF(p_OBJECT_VERSION_NUMBER is NULL)
      THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF(p_validation_mode = CSC_CORE_UTILS_PVT.G_CREATE)
      THEN
          -- Hint: Validate data
          -- IF p_OBJECT_VERSION_NUMBER is not NULL and p_OBJECT_VERSION_NUMBER <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      ELSIF(p_validation_mode = CSC_CORE_UTILS_PVT.G_UPDATE)
      THEN
          -- Hint: Validate data
          -- IF p_OBJECT_VERSION_NUMBER <> G_MISS_CHAR
          -- verify if data is valid
          -- if data is not valid : x_return_status := FND_API.G_RET_STS_ERROR;
          NULL;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

END Validate_OBJECT_VERSION_NUMBER;


PROCEDURE Validate_csc_plan_lines(
    P_Init_Msg_List              IN   VARCHAR2,
    P_Validation_level           IN   NUMBER,
    P_Validation_mode            IN   VARCHAR2,
    P_CSC_PLAN_LINES_Rec         IN   CSC_PLAN_LINES_Rec_Type,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    )
IS
   l_api_name   CONSTANT VARCHAR2(30) := 'Validate_csc_plan_lines';
BEGIN
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN
          Validate_LINE_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_LINE_ID                => P_CSC_PLAN_LINES_Rec.LINE_ID,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PLAN_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PLAN_ID                => P_CSC_PLAN_LINES_Rec.PLAN_ID,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_CONDITION_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
		    P_PLAN_ID                => P_CSC_PLAN_LINES_REC.PLAN_ID,
              p_CONDITION_ID           => P_CSC_PLAN_LINES_Rec.CONDITION_ID,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
      END IF;


END Validate_csc_plan_lines;

End CSC_PLAN_LINES_PVT;

/
