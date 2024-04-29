--------------------------------------------------------
--  DDL for Package Body CSC_CUST_PLANS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSC_CUST_PLANS_PVT" as
/* $Header: cscvctpb.pls 115.18 2003/05/01 23:23:57 jamose ship $ */
-- Start of Comments
-- Package name     : CSC_CUST_PLANS_PVT
-- Purpose          : Private package to perform inserts, updates and deletes operations
--                    on CSC_CUST_PLANS table. It contains procedure to perform item
--                    level validations if the validation level is set to 100 (FULL).
-- History          :
-- MM-DD-YYYY    NAME          MODIFICATIONS
-- 10-28-1999    dejoseph      Created.
-- 12-08-1999    dejoseph      'Arcs'ed in for first code freeze.
-- 12-21-1999    dejoseph      'Arcs'ed in for second code freeze.
-- 01-03-2000    dejoseph      'Arcs'ed in for third code freeze. (10-JAN-2000)
-- 01-31-2000    dejoseph      'Arcs'ed in for fourth code freeze. (07-FEB-2000)
-- 02-13-2000    dejoseph      'Arcs'ed on for fifth code freeze. (21-FEB-2000)
-- 02-28-2000    dejoseph      'Arcs'ed on for sixth code freeze. (06-MAR-2000)
-- 03-28-2000    dejoseph      Removed references to CUST_ACCOUNT_ID and ORG_ID from all
--                             'where' clauses. ie. and   nvl(cust_account_org,0) =
--                             nvl(p_cust_account_org, nvl(cust_account_org,0) )
--                             Replaced call to HZ_CUST_ACCOUNT_ALL to HZ_CUST_ACCOUNTS.
-- 04-10-2000    dejoseph      Removed org_id validations and all reference to org_id in lieu
--                             of TCA's decision to drop column ORG_ID from
--                             hz_cust_accounts table. Also removed references to all
--                             'HZ_' tables and used 'JTF_'.
--                             Removed reference to cust_account_org.
-- 10-23-2000    dejoseph      Removed references to px_plan_audit_id when invoking procedure
--                             to perform insert into CSC_CUST_PLANS_AUDIT table. Fix to
--                             Bug # 1467071.
--				NOCOPY changes made for OUT parameters
--
-- 26-11-2002	bhroy		G_MISS_XXX defaults of API parameters removed, added WHENEVER OSERROR EXIT FAILURE ROLLBACK
-- 01-05-2003  jamose           The code has been changed on the procedure get_cust_plan_id
--                              for making the dynamic sql bind variable complains. Bug# for
--                              reference is 2935833
-- NOTE             :
-- End of Comments

G_PKG_NAME  CONSTANT VARCHAR2(30) := 'CSC_CUST_PLANS_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'cscvctpb.pls';

PROCEDURE CONVERT_COLUMNS_TO_REC_TYPE(
       P_PLAN_ID                  IN     NUMBER ,
       P_CUST_PLAN_ID             IN     NUMBER ,
       P_PARTY_ID                 IN     NUMBER ,
       P_CUST_ACCOUNT_ID          IN     NUMBER ,
       -- P_CUST_ACCOUNT_ORG         IN     NUMBER,
       P_START_DATE_ACTIVE        IN     DATE ,
       P_END_DATE_ACTIVE          IN     DATE ,
       P_MANUAL_FLAG              IN     VARCHAR2,
       P_PLAN_STATUS_CODE         IN     VARCHAR2 ,
       P_REQUEST_ID               IN     NUMBER ,
       P_PROGRAM_APPLICATION_ID   IN     NUMBER ,
       P_PROGRAM_ID               IN     NUMBER ,
       P_PROGRAM_UPDATE_DATE      IN     DATE ,
       P_CREATION_DATE            IN     DATE,
       P_CREATED_BY               IN     NUMBER,
       P_LAST_UPDATE_DATE         IN     DATE ,
       P_LAST_UPDATED_BY          IN     NUMBER,
       P_LAST_UPDATE_LOGIN        IN     NUMBER,
       P_ATTRIBUTE1               IN     VARCHAR2,
       P_ATTRIBUTE2               IN     VARCHAR2,
       P_ATTRIBUTE3               IN     VARCHAR2,
       P_ATTRIBUTE4               IN     VARCHAR2,
       P_ATTRIBUTE5               IN     VARCHAR2,
       P_ATTRIBUTE6               IN     VARCHAR2,
       P_ATTRIBUTE7               IN     VARCHAR2,
       P_ATTRIBUTE8               IN     VARCHAR2,
       P_ATTRIBUTE9               IN     VARCHAR2,
       P_ATTRIBUTE10              IN     VARCHAR2,
       P_ATTRIBUTE11              IN     VARCHAR2,
       P_ATTRIBUTE12              IN     VARCHAR2,
       P_ATTRIBUTE13              IN     VARCHAR2,
       P_ATTRIBUTE14              IN     VARCHAR2,
       P_ATTRIBUTE15              IN     VARCHAR2,
       P_ATTRIBUTE_CATEGORY       IN     VARCHAR2,
       P_OBJECT_VERSION_NUMBER    IN     NUMBER,
       X_CSC_CUST_PLANS_REC_TYPE  OUT    NOCOPY CSC_CUST_PLANS_REC_TYPE )
IS
BEGIN
       x_csc_cust_plans_rec_type.PLAN_ID := P_PLAN_ID ;
       x_csc_cust_plans_rec_type.CUST_PLAN_ID := P_CUST_PLAN_ID ;
       x_csc_cust_plans_rec_type.PARTY_ID := P_PARTY_ID ;
       x_csc_cust_plans_rec_type.CUST_ACCOUNT_ID := P_CUST_ACCOUNT_ID ;
       -- x_csc_cust_plans_rec_type.CUST_ACCOUNT_ORG  := P_CUST_ACCOUNT_ORG  ;
       x_csc_cust_plans_rec_type.START_DATE_ACTIVE := P_START_DATE_ACTIVE ;
       x_csc_cust_plans_rec_type.END_DATE_ACTIVE := P_END_DATE_ACTIVE ;
       x_csc_cust_plans_rec_type.MANUAL_FLAG := P_MANUAL_FLAG ;
       x_csc_cust_plans_rec_type.PLAN_STATUS_CODE := P_PLAN_STATUS_CODE ;
       x_csc_cust_plans_rec_type.REQUEST_ID := P_REQUEST_ID ;
       x_csc_cust_plans_rec_type.PROGRAM_APPLICATION_ID := P_PROGRAM_APPLICATION_ID ;
       x_csc_cust_plans_rec_type.PROGRAM_ID := P_PROGRAM_ID ;
       x_csc_cust_plans_rec_type.PROGRAM_UPDATE_DATE := P_PROGRAM_UPDATE_DATE ;
       x_csc_cust_plans_rec_type.CREATION_DATE := P_CREATION_DATE ;
       x_csc_cust_plans_rec_type.LAST_UPDATE_DATE := P_LAST_UPDATE_DATE ;
       x_csc_cust_plans_rec_type.CREATED_BY := P_CREATED_BY ;
       x_csc_cust_plans_rec_type.LAST_UPDATED_BY := P_LAST_UPDATED_BY ;
       x_csc_cust_plans_rec_type.LAST_UPDATE_LOGIN := P_LAST_UPDATE_LOGIN ;
       x_csc_cust_plans_rec_type.ATTRIBUTE1 := P_ATTRIBUTE1 ;
       x_csc_cust_plans_rec_type.ATTRIBUTE2 := P_ATTRIBUTE2 ;
       x_csc_cust_plans_rec_type.ATTRIBUTE3 := P_ATTRIBUTE3 ;
       x_csc_cust_plans_rec_type.ATTRIBUTE4 := P_ATTRIBUTE4 ;
       x_csc_cust_plans_rec_type.ATTRIBUTE5 := P_ATTRIBUTE5 ;
       x_csc_cust_plans_rec_type.ATTRIBUTE6 := P_ATTRIBUTE6 ;
       x_csc_cust_plans_rec_type.ATTRIBUTE7 := P_ATTRIBUTE7 ;
       x_csc_cust_plans_rec_type.ATTRIBUTE8 := P_ATTRIBUTE8 ;
       x_csc_cust_plans_rec_type.ATTRIBUTE9 := P_ATTRIBUTE9 ;
       x_csc_cust_plans_rec_type.ATTRIBUTE10 := P_ATTRIBUTE10 ;
       x_csc_cust_plans_rec_type.ATTRIBUTE11 := P_ATTRIBUTE11 ;
       x_csc_cust_plans_rec_type.ATTRIBUTE12 := P_ATTRIBUTE12 ;
       x_csc_cust_plans_rec_type.ATTRIBUTE13 := P_ATTRIBUTE13 ;
       x_csc_cust_plans_rec_type.ATTRIBUTE14 := P_ATTRIBUTE14 ;
       x_csc_cust_plans_rec_type.ATTRIBUTE15 := P_ATTRIBUTE15 ;
       x_csc_cust_plans_rec_type.ATTRIBUTE_CATEGORY := P_ATTRIBUTE_CATEGORY ;
       x_csc_cust_plans_rec_type.OBJECT_VERSION_NUMBER := P_OBJECT_VERSION_NUMBER ;

END  CONVERT_COLUMNS_TO_REC_TYPE;

/*** Overloaded proc. that accepts a detailed parameter list, converts the list
     into a record type parameter and calls the create procedure that accepts
     a record type IN parameter  ***/

PROCEDURE Create_cust_plans(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER  ,
    P_PLAN_ID                    IN   NUMBER ,
    P_CUST_PLAN_ID               IN   NUMBER ,
    P_PARTY_ID                   IN   NUMBER ,
    P_CUST_ACCOUNT_ID            IN   NUMBER ,
    -- P_CUST_ACCOUNT_ORG           IN   NUMBER,
    P_START_DATE_ACTIVE          IN   DATE,
    P_END_DATE_ACTIVE            IN   DATE,
    P_MANUAL_FLAG                IN   VARCHAR2,
    P_PLAN_STATUS_CODE           IN   VARCHAR2,
    P_REQUEST_ID                 IN   NUMBER,
    P_PROGRAM_APPLICATION_ID     IN   NUMBER,
    P_PROGRAM_ID                 IN   NUMBER,
    P_PROGRAM_UPDATE_DATE        IN   DATE ,
    P_CREATION_DATE              IN   DATE ,
    P_LAST_UPDATE_DATE           IN   DATE ,
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
    X_CUST_PLAN_ID               OUT  NOCOPY NUMBER,
    X_OBJECT_VERSION_NUMBER      OUT  NOCOPY NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
)
IS
    l_csc_cust_plans_rec     CSC_CUST_PLANS_REC_TYPE;
BEGIN

   CONVERT_COLUMNS_TO_REC_TYPE(
       P_PLAN_ID                   => P_PLAN_ID ,
       P_CUST_PLAN_ID              => P_CUST_PLAN_ID ,
       P_PARTY_ID                  => P_PARTY_ID ,
       P_CUST_ACCOUNT_ID           => P_CUST_ACCOUNT_ID ,
       -- P_CUST_ACCOUNT_ORG          => P_CUST_ACCOUNT_ORG ,
       P_START_DATE_ACTIVE         => P_START_DATE_ACTIVE ,
       P_END_DATE_ACTIVE           => P_END_DATE_ACTIVE ,
       P_PLAN_STATUS_CODE          => P_PLAN_STATUS_CODE ,
       P_MANUAL_FLAG               => P_MANUAL_FLAG ,
       P_REQUEST_ID                => P_REQUEST_ID ,
       P_PROGRAM_APPLICATION_ID    => P_PROGRAM_APPLICATION_ID ,
       P_PROGRAM_ID                => P_PROGRAM_ID ,
       P_PROGRAM_UPDATE_DATE       => P_PROGRAM_UPDATE_DATE ,
       P_CREATION_DATE             => P_CREATION_DATE ,
       P_LAST_UPDATE_DATE          => P_LAST_UPDATE_DATE ,
       P_CREATED_BY                => P_CREATED_BY ,
       P_LAST_UPDATED_BY           => P_LAST_UPDATED_BY ,
       P_LAST_UPDATE_LOGIN         => P_LAST_UPDATE_LOGIN ,
       P_ATTRIBUTE1                => P_ATTRIBUTE1 ,
       P_ATTRIBUTE2                => P_ATTRIBUTE2 ,
       P_ATTRIBUTE3                => P_ATTRIBUTE3 ,
       P_ATTRIBUTE4                => P_ATTRIBUTE4 ,
       P_ATTRIBUTE5                => P_ATTRIBUTE5 ,
       P_ATTRIBUTE6                => P_ATTRIBUTE6 ,
       P_ATTRIBUTE7                => P_ATTRIBUTE7 ,
       P_ATTRIBUTE8                => P_ATTRIBUTE8 ,
       P_ATTRIBUTE9                => P_ATTRIBUTE9 ,
       P_ATTRIBUTE10               => P_ATTRIBUTE10 ,
       P_ATTRIBUTE11               => P_ATTRIBUTE11 ,
       P_ATTRIBUTE12               => P_ATTRIBUTE12 ,
       P_ATTRIBUTE13               => P_ATTRIBUTE13 ,
       P_ATTRIBUTE14               => P_ATTRIBUTE14 ,
       P_ATTRIBUTE15               => P_ATTRIBUTE15 ,
       P_ATTRIBUTE_CATEGORY        => P_ATTRIBUTE_CATEGORY ,
       P_OBJECT_VERSION_NUMBER     => P_OBJECT_VERSION_NUMBER ,
       X_CSC_CUST_PLANS_REC_TYPE   => l_csc_cust_plans_rec );

-- issue a call to the create_cust_plans proc. with the record type parameter
   Create_cust_plans(
       P_Api_Version_Number         => p_api_version_number,
       P_Init_Msg_List              => p_init_msg_list,
       P_Commit                     => p_commit,
       P_Validation_level           => p_validation_level,
       P_CSC_CUST_PLANS_Rec         => l_csc_cust_plans_rec,
       X_CUST_PLAN_ID               => x_cust_plan_id,
       X_OBJECT_VERSION_NUMBER      => x_object_version_number,
       X_Return_Status              => x_return_status,
       X_Msg_Count                  => x_msg_count,
       X_Msg_Data                   => x_msg_data );

END   CREATE_CUST_PLANS;

-- Hint: Primary key needs to be returned.
PROCEDURE Create_cust_plans(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER  ,
    P_CSC_CUST_PLANS_Rec         IN   CSC_CUST_PLANS_Rec_Type  ,
    X_CUST_PLAN_ID               OUT  NOCOPY NUMBER,
    X_OBJECT_VERSION_NUMBER      OUT  NOCOPY NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    )
IS
   -- Retreive the start and end date of the given plan_id to default
   -- it into the cust_plans table, if they are passed in as nulls.
   cursor c1( c_plan_id number ) is
   select start_date_active,
		end_date_active
   from   csc_plan_headers_b
   where  plan_id = c_plan_id;

   l_api_name                CONSTANT VARCHAR2(30) := 'Create_cust_plans';
   l_api_version_number      CONSTANT NUMBER       := 1.0;
   l_return_status_full      VARCHAR2(1);

   l_start_date_active       DATE := p_csc_cust_plans_rec.start_date_active;
   l_end_date_active         DATE := p_csc_cust_plans_rec.end_date_active;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_CUST_PLANS_PVT;

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

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Invoke validation procedures
          Validate_csc_cust_plans(
              p_init_msg_list         => FND_API.G_FALSE,
              p_validation_level      => p_validation_level,
              p_validation_mode       => CSC_CORE_UTILS_PVT.G_CREATE,
              P_CSC_CUST_PLANS_Rec    => P_CSC_CUST_PLANS_Rec,
              x_return_status         => x_return_status,
              x_msg_count             => x_msg_count,
              x_msg_data              => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

	 -- if either start_date_active or end_date_active is passed in as null, then
	 -- retreive these value from the csc_plan_headers_b table for the given plan_id;

      if (( p_csc_cust_plans_rec.START_DATE_ACTIVE is NULL OR
		  p_csc_cust_plans_rec.START_DATE_ACTIVE =  FND_API.G_MISS_DATE ) OR
		 ( p_csc_cust_plans_rec.END_DATE_ACTIVE is NULL OR
		   p_csc_cust_plans_rec.END_DATE_ACTIVE =  FND_API.G_MISS_DATE )) THEN
	    OPEN c1 (p_csc_cust_plans_rec.plan_id);
	    FETCH c1 INTO l_start_date_active, l_end_date_active;
	    IF C1%NOTFOUND THEN
	       --FND_MESSAGE.SET_NAME(CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, '
            CLOSE c1;
	       RAISE NO_DATA_FOUND;
         END IF;
	    CLOSE c1;
      end if;

	 x_cust_plan_id := p_csc_cust_plans_rec.cust_plan_id;

      -- Invoke table handler(CSC_CUST_PLANS_PKG.Insert_Row)
      CSC_CUST_PLANS_PKG.Insert_Row(
          px_CUST_PLAN_ID           => x_CUST_PLAN_ID,
          p_PLAN_ID                 => p_CSC_CUST_PLANS_rec.PLAN_ID,
          p_PARTY_ID                => p_CSC_CUST_PLANS_rec.PARTY_ID,
          p_CUST_ACCOUNT_ID         => p_CSC_CUST_PLANS_rec.CUST_ACCOUNT_ID,
          -- p_CUST_ACCOUNT_ORG        => p_CSC_CUST_PLANS_rec.CUST_ACCOUNT_ORG,
          p_START_DATE_ACTIVE       => l_start_date_active,
          p_END_DATE_ACTIVE         => l_end_date_active,
          p_MANUAL_FLAG             => p_CSC_CUST_PLANS_rec.MANUAL_FLAG,
          p_PLAN_STATUS_CODE        => CSC_CORE_UTILS_PVT.APPLY_PLAN,
          p_REQUEST_ID              => p_CSC_CUST_PLANS_rec.REQUEST_ID,
          p_PROGRAM_APPLICATION_ID  => p_CSC_CUST_PLANS_rec.PROGRAM_APPLICATION_ID,
          p_PROGRAM_ID              => p_CSC_CUST_PLANS_rec.PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE     => p_CSC_CUST_PLANS_rec.PROGRAM_UPDATE_DATE,
          p_CREATION_DATE           => SYSDATE,
          p_LAST_UPDATE_DATE        => SYSDATE,
          p_CREATED_BY              => FND_GLOBAL.USER_ID,
          p_LAST_UPDATED_BY         => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_LOGIN       => FND_GLOBAL.CONC_LOGIN_ID,
          p_ATTRIBUTE1              => p_CSC_CUST_PLANS_rec.ATTRIBUTE1,
          p_ATTRIBUTE2              => p_CSC_CUST_PLANS_rec.ATTRIBUTE2,
          p_ATTRIBUTE3              => p_CSC_CUST_PLANS_rec.ATTRIBUTE3,
          p_ATTRIBUTE4              => p_CSC_CUST_PLANS_rec.ATTRIBUTE4,
          p_ATTRIBUTE5              => p_CSC_CUST_PLANS_rec.ATTRIBUTE5,
          p_ATTRIBUTE6              => p_CSC_CUST_PLANS_rec.ATTRIBUTE6,
          p_ATTRIBUTE7              => p_CSC_CUST_PLANS_rec.ATTRIBUTE7,
          p_ATTRIBUTE8              => p_CSC_CUST_PLANS_rec.ATTRIBUTE8,
          p_ATTRIBUTE9              => p_CSC_CUST_PLANS_rec.ATTRIBUTE9,
          p_ATTRIBUTE10             => p_CSC_CUST_PLANS_rec.ATTRIBUTE10,
          p_ATTRIBUTE11             => p_CSC_CUST_PLANS_rec.ATTRIBUTE11,
          p_ATTRIBUTE12             => p_CSC_CUST_PLANS_rec.ATTRIBUTE12,
          p_ATTRIBUTE13             => p_CSC_CUST_PLANS_rec.ATTRIBUTE13,
          p_ATTRIBUTE14             => p_CSC_CUST_PLANS_rec.ATTRIBUTE14,
          p_ATTRIBUTE15             => p_CSC_CUST_PLANS_rec.ATTRIBUTE15,
          p_ATTRIBUTE_CATEGORY      => p_CSC_CUST_PLANS_rec.ATTRIBUTE_CATEGORY,
          X_OBJECT_VERSION_NUMBER   => X_OBJECT_VERSION_NUMBER);

   -- For every operation on the CSC_CUST_PLANS table insert a record in the
   -- CSC_CUST_PLANS_AUDIT table.

      CSC_CUST_PLANS_AUDIT_PKG.Insert_Row(
          --px_PLAN_AUDIT_ID         => G_PLAN_AUDIT_ID,-- will be selected from the sequence.
          p_PLAN_ID                => p_CSC_CUST_PLANS_rec.PLAN_ID ,
          p_PARTY_ID               => p_CSC_CUST_PLANS_rec.PARTY_ID ,
          p_CUST_ACCOUNT_ID        => p_CSC_CUST_PLANS_rec.CUST_ACCOUNT_ID ,
          -- p_CUST_ACCOUNT_ORG       => p_CSC_CUST_PLANS_rec.CUST_ACCOUNT_ORG ,
          p_PLAN_STATUS_CODE       => CSC_CORE_UTILS_PVT.APPLY_PLAN,
          p_REQUEST_ID             => p_CSC_CUST_PLANS_rec.REQUEST_ID ,
          p_PROGRAM_APPLICATION_ID => p_CSC_CUST_PLANS_rec.PROGRAM_APPLICATION_ID ,
          p_PROGRAM_ID             => p_CSC_CUST_PLANS_rec.PROGRAM_ID ,
          p_PROGRAM_UPDATE_DATE    => p_CSC_CUST_PLANS_rec.PROGRAM_UPDATE_DATE ,
          p_CREATION_DATE          => SYSDATE,
          p_LAST_UPDATE_DATE       => SYSDATE,
          p_CREATED_BY             => FND_GLOBAL.USER_ID,
          p_LAST_UPDATED_BY        => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_LOGIN      => FND_GLOBAL.CONC_LOGIN_ID,
          p_ATTRIBUTE1             => p_CSC_CUST_PLANS_rec.ATTRIBUTE1 ,
          p_ATTRIBUTE2             => p_CSC_CUST_PLANS_rec.ATTRIBUTE2 ,
          p_ATTRIBUTE3             => p_CSC_CUST_PLANS_rec.ATTRIBUTE3 ,
          p_ATTRIBUTE4             => p_CSC_CUST_PLANS_rec.ATTRIBUTE4 ,
          p_ATTRIBUTE5             => p_CSC_CUST_PLANS_rec.ATTRIBUTE5 ,
          p_ATTRIBUTE6             => p_CSC_CUST_PLANS_rec.ATTRIBUTE6 ,
          p_ATTRIBUTE7             => p_CSC_CUST_PLANS_rec.ATTRIBUTE7 ,
          p_ATTRIBUTE8             => p_CSC_CUST_PLANS_rec.ATTRIBUTE8 ,
          p_ATTRIBUTE9             => p_CSC_CUST_PLANS_rec.ATTRIBUTE9 ,
          p_ATTRIBUTE10            => p_CSC_CUST_PLANS_rec.ATTRIBUTE10 ,
          p_ATTRIBUTE11            => p_CSC_CUST_PLANS_rec.ATTRIBUTE11 ,
          p_ATTRIBUTE12            => p_CSC_CUST_PLANS_rec.ATTRIBUTE12 ,
          p_ATTRIBUTE13            => p_CSC_CUST_PLANS_rec.ATTRIBUTE13 ,
          p_ATTRIBUTE14            => p_CSC_CUST_PLANS_rec.ATTRIBUTE14 ,
          p_ATTRIBUTE15            => p_CSC_CUST_PLANS_rec.ATTRIBUTE15 ,
          p_ATTRIBUTE_CATEGORY     => p_CSC_CUST_PLANS_rec.ATTRIBUTE_CATEGORY,
          x_PLAN_AUDIT_ID          => G_PLAN_AUDIT_ID );

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

End Create_cust_plans;


/*** Overloaded proc. that accepts a detailed parameter list, converts the list
     into a record type parameter and calls the create procedure that accepts
     a record type IN parameter  ***/

PROCEDURE Update_cust_plans(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
    P_PLAN_ID                    IN   NUMBER,
    P_CUST_PLAN_ID               IN   NUMBER,
    P_PARTY_ID                   IN   NUMBER,
    P_CUST_ACCOUNT_ID            IN   NUMBER,
    -- P_CUST_ACCOUNT_ORG           IN   NUMBER := FND_API.G_MISS_NUM,
    P_START_DATE_ACTIVE          IN   DATE,
    P_END_DATE_ACTIVE            IN   DATE,
    P_MANUAL_FLAG                IN   VARCHAR2,
    P_PLAN_STATUS_CODE           IN   VARCHAR2,
    P_REQUEST_ID                 IN   NUMBER,
    P_PROGRAM_APPLICATION_ID     IN   NUMBER,
    P_PROGRAM_ID                 IN   NUMBER,
    P_PROGRAM_UPDATE_DATE        IN   DATE,
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
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
)
IS
   l_csc_cust_plans_rec      CSC_CUST_PLANS_REC_TYPE;
BEGIN

   CONVERT_COLUMNS_TO_REC_TYPE(
       P_PLAN_ID                   => P_PLAN_ID ,
       P_CUST_PLAN_ID              => P_CUST_PLAN_ID ,
       P_PARTY_ID                  => P_PARTY_ID ,
       P_CUST_ACCOUNT_ID           => P_CUST_ACCOUNT_ID ,
       -- P_CUST_ACCOUNT_ORG          => P_CUST_ACCOUNT_ORG ,
       P_START_DATE_ACTIVE         => P_START_DATE_ACTIVE ,
       P_END_DATE_ACTIVE           => P_END_DATE_ACTIVE ,
       P_MANUAL_FLAG               => P_MANUAL_FLAG ,
       P_PLAN_STATUS_CODE          => P_PLAN_STATUS_CODE ,
       P_REQUEST_ID                => P_REQUEST_ID ,
       P_PROGRAM_APPLICATION_ID    => P_PROGRAM_APPLICATION_ID ,
       P_PROGRAM_ID                => P_PROGRAM_ID ,
       P_PROGRAM_UPDATE_DATE       => P_PROGRAM_UPDATE_DATE ,
       P_CREATION_DATE             => P_CREATION_DATE ,
       P_LAST_UPDATE_DATE          => P_LAST_UPDATE_DATE ,
       P_CREATED_BY                => P_CREATED_BY ,
       P_LAST_UPDATED_BY           => P_LAST_UPDATED_BY ,
       P_LAST_UPDATE_LOGIN         => P_LAST_UPDATE_LOGIN ,
       P_ATTRIBUTE1                => P_ATTRIBUTE1 ,
       P_ATTRIBUTE2                => P_ATTRIBUTE2 ,
       P_ATTRIBUTE3                => P_ATTRIBUTE3 ,
       P_ATTRIBUTE4                => P_ATTRIBUTE4 ,
       P_ATTRIBUTE5                => P_ATTRIBUTE5 ,
       P_ATTRIBUTE6                => P_ATTRIBUTE6 ,
       P_ATTRIBUTE7                => P_ATTRIBUTE7 ,
       P_ATTRIBUTE8                => P_ATTRIBUTE8 ,
       P_ATTRIBUTE9                => P_ATTRIBUTE9 ,
       P_ATTRIBUTE10               => P_ATTRIBUTE10 ,
       P_ATTRIBUTE11               => P_ATTRIBUTE11 ,
       P_ATTRIBUTE12               => P_ATTRIBUTE12 ,
       P_ATTRIBUTE13               => P_ATTRIBUTE13 ,
       P_ATTRIBUTE14               => P_ATTRIBUTE14 ,
       P_ATTRIBUTE15               => P_ATTRIBUTE15 ,
       P_ATTRIBUTE_CATEGORY        => P_ATTRIBUTE_CATEGORY ,
       P_OBJECT_VERSION_NUMBER     => P_OBJECT_VERSION_NUMBER ,
       X_CSC_CUST_PLANS_REC_TYPE   => l_csc_cust_plans_rec );

-- issue a call to the create_cust_plans proc. with the record type parameter
   Update_cust_plans(
       P_Api_Version_Number         => p_api_version_number,
       P_Init_Msg_List              => p_init_msg_list,
       P_Commit                     => p_commit,
       p_validation_level           => p_validation_level,
       P_CSC_CUST_PLANS_Rec         => l_csc_cust_plans_rec,
       X_OBJECT_VERSION_NUMBER      => x_object_version_number,
       X_Return_Status              => x_return_status,
       X_Msg_Count                  => x_msg_count,
       X_Msg_Data                   => x_msg_data);

END  UPDATE_CUST_PLANS;   -- end of overloaded procedure;

-- Hint: Add corresponding update detail table procedures if it's master-detail relationship.
PROCEDURE Update_cust_plans(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER ,
    P_CSC_CUST_PLANS_Rec         IN   CSC_CUST_PLANS_Rec_Type,
    X_OBJECT_VERSION_NUMBER      OUT  NOCOPY NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    )
IS
   Cursor C_Get_cust_plans IS
     Select rowid,           CUST_PLAN_ID,         PLAN_ID,
        PARTY_ID,            CUST_ACCOUNT_ID,      -- CUST_ACCOUNT_ORG,
        START_DATE_ACTIVE,   END_DATE_ACTIVE,      MANUAL_FLAG,
        PLAN_STATUS_CODE,    REQUEST_ID,           PROGRAM_APPLICATION_ID,
        PROGRAM_ID,          PROGRAM_UPDATE_DATE,  LAST_UPDATE_DATE,
        CREATION_DATE,       LAST_UPDATED_BY,      CREATED_BY,
        LAST_UPDATE_LOGIN,   ATTRIBUTE1,           ATTRIBUTE2,
        ATTRIBUTE3,          ATTRIBUTE4,           ATTRIBUTE5,
        ATTRIBUTE6,          ATTRIBUTE7,           ATTRIBUTE8,
        ATTRIBUTE9,          ATTRIBUTE10,          ATTRIBUTE11,
        ATTRIBUTE12,         ATTRIBUTE13,          ATTRIBUTE14,
        ATTRIBUTE15,         ATTRIBUTE_CATEGORY,   OBJECT_VERSION_NUMBER
     From  CSC_CUST_PLANS
     WHERE CUST_PLAN_ID            =  nvl(p_csc_cust_plans_rec.cust_plan_id, cust_plan_id)
     AND   PLAN_ID                 =  nvl(p_csc_cust_plans_rec.plan_id,      plan_id)
     AND   PARTY_ID                =  nvl(p_csc_cust_plans_rec.party_id,     party_id)
	AND   nvl(CUST_ACCOUNT_ID,0)  =  nvl(p_csc_cust_plans_rec.cust_account_id,
												    nvl(cust_account_id,0) );

   l_api_name                CONSTANT VARCHAR2(30) := 'Update_cust_plans';
   l_api_version_number      CONSTANT NUMBER       := 1.0;

   l_ref_CSC_CUST_PLANS_rec  CSC_cust_plans_PVT.CSC_CUST_PLANS_Rec_Type;
   --l_tar_CSC_CUST_PLANS_rec  CSC_cust_plans_PVT.CSC_CUST_PLANS_Rec_Type := P_CSC_CUST_PLANS_Rec;
   l_upd_CSC_CUST_PLANS_rec  CSC_cust_plans_PVT.CSC_CUST_PLANS_Rec_Type := P_CSC_CUST_PLANS_REC;
   l_rowid  ROWID;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_CUST_PLANS_PVT;

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

      CSC_CUST_PLANS_PKG.Lock_Row(
          p_CUST_PLAN_ID            =>  p_csc_cust_plans_rec.cust_plan_id,
          p_PLAN_ID                 =>  p_csc_cust_plans_rec.plan_id,
          p_PARTY_ID                =>  p_csc_cust_plans_rec.party_id,
		P_CUST_ACCOUNT_ID         =>  p_csc_cust_plans_rec.cust_account_id,
		-- P_CUST_ACCOUNT_ORG        =>  p_csc_cust_plans_rec.cust_account_org,
          p_OBJECT_VERSION_NUMBER   =>  p_csc_cust_plans_rec.object_version_number);

      Open C_Get_cust_plans;

      Fetch C_Get_cust_plans into
               l_rowid,
               l_ref_CSC_CUST_PLANS_rec.CUST_PLAN_ID,
               l_ref_CSC_CUST_PLANS_rec.PLAN_ID,
               l_ref_CSC_CUST_PLANS_rec.PARTY_ID,
               l_ref_CSC_CUST_PLANS_rec.CUST_ACCOUNT_ID,
               -- l_ref_CSC_CUST_PLANS_rec.CUST_ACCOUNT_ORG,
               l_ref_CSC_CUST_PLANS_rec.START_DATE_ACTIVE,
               l_ref_CSC_CUST_PLANS_rec.END_DATE_ACTIVE,
               l_ref_CSC_CUST_PLANS_rec.MANUAL_FLAG,
               l_ref_CSC_CUST_PLANS_rec.PLAN_STATUS_CODE,
               l_ref_CSC_CUST_PLANS_rec.REQUEST_ID,
               l_ref_CSC_CUST_PLANS_rec.PROGRAM_APPLICATION_ID,
               l_ref_CSC_CUST_PLANS_rec.PROGRAM_ID,
               l_ref_CSC_CUST_PLANS_rec.PROGRAM_UPDATE_DATE,
               l_ref_CSC_CUST_PLANS_rec.LAST_UPDATE_DATE,
               l_ref_CSC_CUST_PLANS_rec.CREATION_DATE,
               l_ref_CSC_CUST_PLANS_rec.LAST_UPDATED_BY,
               l_ref_CSC_CUST_PLANS_rec.CREATED_BY,
               l_ref_CSC_CUST_PLANS_rec.LAST_UPDATE_LOGIN,
               l_ref_CSC_CUST_PLANS_rec.ATTRIBUTE1,
               l_ref_CSC_CUST_PLANS_rec.ATTRIBUTE2,
               l_ref_CSC_CUST_PLANS_rec.ATTRIBUTE3,
               l_ref_CSC_CUST_PLANS_rec.ATTRIBUTE4,
               l_ref_CSC_CUST_PLANS_rec.ATTRIBUTE5,
               l_ref_CSC_CUST_PLANS_rec.ATTRIBUTE6,
               l_ref_CSC_CUST_PLANS_rec.ATTRIBUTE7,
               l_ref_CSC_CUST_PLANS_rec.ATTRIBUTE8,
               l_ref_CSC_CUST_PLANS_rec.ATTRIBUTE9,
               l_ref_CSC_CUST_PLANS_rec.ATTRIBUTE10,
               l_ref_CSC_CUST_PLANS_rec.ATTRIBUTE11,
               l_ref_CSC_CUST_PLANS_rec.ATTRIBUTE12,
               l_ref_CSC_CUST_PLANS_rec.ATTRIBUTE13,
               l_ref_CSC_CUST_PLANS_rec.ATTRIBUTE14,
               l_ref_CSC_CUST_PLANS_rec.ATTRIBUTE15,
               l_ref_CSC_CUST_PLANS_rec.ATTRIBUTE_CATEGORY,
               l_ref_CSC_CUST_PLANS_rec.OBJECT_VERSION_NUMBER;

      If ( C_Get_cust_plans%NOTFOUND) Then
           IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
           THEN
               Close  C_Get_cust_plans;
               FND_MESSAGE.Set_Name(CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'API_MISSING_UPDATE_TARGET');
               FND_MESSAGE.Set_Token ('INFO', 'cust_plans', FALSE);
               -- FND_MSG_PUB.Add;
           END IF;
           raise FND_API.G_EXC_ERROR;
      END IF;
      Close  C_Get_cust_plans;

	l_upd_csc_cust_plans_rec.cust_account_id := CSC_CORE_UTILS_PVT.Get_G_Miss_Num(p_csc_cust_plans_rec.cust_account_id, l_ref_CSC_CUST_PLANS_rec.CUST_ACCOUNT_ID);

         l_upd_csc_cust_plans_rec.start_date_active :=  CSC_CORE_UTILS_PVT.Get_G_Miss_date(p_csc_cust_plans_rec.start_date_active, l_ref_CSC_CUST_PLANS_rec.START_DATE_ACTIVE);

         l_upd_csc_cust_plans_rec.end_date_active :=  CSC_CORE_UTILS_PVT.Get_G_Miss_date(p_csc_cust_plans_rec.end_date_active, l_ref_CSC_CUST_PLANS_rec.END_DATE_ACTIVE);

	l_upd_csc_cust_plans_rec.manual_flag := CSC_CORE_UTILS_PVT.Get_G_Miss_Char(p_csc_cust_plans_rec.manual_flag, l_ref_CSC_CUST_PLANS_rec.MANUAL_FLAG);

	l_upd_csc_cust_plans_rec.plan_status_code := CSC_CORE_UTILS_PVT.Get_G_Miss_Char(p_csc_cust_plans_rec.plan_status_code, l_ref_CSC_CUST_PLANS_rec.PLAN_STATUS_CODE);

	l_upd_csc_cust_plans_rec.request_id := CSC_CORE_UTILS_PVT.Get_G_Miss_Num(p_csc_cust_plans_rec.request_id, l_ref_CSC_CUST_PLANS_rec.REQUEST_ID);

	l_upd_csc_cust_plans_rec.program_application_id := CSC_CORE_UTILS_PVT.Get_G_Miss_Num(p_csc_cust_plans_rec.program_application_id, l_ref_CSC_CUST_PLANS_rec.PROGRAM_APPLICATION_ID);

	l_upd_csc_cust_plans_rec.program_id := CSC_CORE_UTILS_PVT.Get_G_Miss_Num(p_csc_cust_plans_rec.program_id, l_ref_CSC_CUST_PLANS_rec.PROGRAM_ID);

         l_upd_csc_cust_plans_rec.program_update_date :=  CSC_CORE_UTILS_PVT.Get_G_Miss_date(p_csc_cust_plans_rec.program_update_date, l_ref_CSC_CUST_PLANS_rec.PROGRAM_UPDATE_DATE);

         l_upd_csc_cust_plans_rec.last_update_date :=  CSC_CORE_UTILS_PVT.Get_G_Miss_date(p_csc_cust_plans_rec.last_update_date, l_ref_CSC_CUST_PLANS_rec.LAST_UPDATE_DATE);

	l_upd_csc_cust_plans_rec.attribute1 := CSC_CORE_UTILS_PVT.Get_G_Miss_Char(p_csc_cust_plans_rec.attribute1, l_ref_CSC_CUST_PLANS_rec.ATTRIBUTE1);

	l_upd_csc_cust_plans_rec.attribute2 := CSC_CORE_UTILS_PVT.Get_G_Miss_Char(p_csc_cust_plans_rec.attribute2, l_ref_CSC_CUST_PLANS_rec.ATTRIBUTE2);

	l_upd_csc_cust_plans_rec.attribute3 := CSC_CORE_UTILS_PVT.Get_G_Miss_Char(p_csc_cust_plans_rec.attribute3, l_ref_CSC_CUST_PLANS_rec.ATTRIBUTE3);

	l_upd_csc_cust_plans_rec.attribute4 := CSC_CORE_UTILS_PVT.Get_G_Miss_Char(p_csc_cust_plans_rec.attribute4, l_ref_CSC_CUST_PLANS_rec.ATTRIBUTE4);

	l_upd_csc_cust_plans_rec.attribute5 := CSC_CORE_UTILS_PVT.Get_G_Miss_Char(p_csc_cust_plans_rec.attribute5, l_ref_CSC_CUST_PLANS_rec.ATTRIBUTE5);

	l_upd_csc_cust_plans_rec.attribute6 := CSC_CORE_UTILS_PVT.Get_G_Miss_Char(p_csc_cust_plans_rec.attribute6, l_ref_CSC_CUST_PLANS_rec.ATTRIBUTE6);

	l_upd_csc_cust_plans_rec.attribute7 := CSC_CORE_UTILS_PVT.Get_G_Miss_Char(p_csc_cust_plans_rec.attribute7, l_ref_CSC_CUST_PLANS_rec.ATTRIBUTE7);

	l_upd_csc_cust_plans_rec.attribute8 := CSC_CORE_UTILS_PVT.Get_G_Miss_Char(p_csc_cust_plans_rec.attribute8, l_ref_CSC_CUST_PLANS_rec.ATTRIBUTE8);

	l_upd_csc_cust_plans_rec.attribute9 := CSC_CORE_UTILS_PVT.Get_G_Miss_Char(p_csc_cust_plans_rec.attribute9, l_ref_CSC_CUST_PLANS_rec.ATTRIBUTE9);

	l_upd_csc_cust_plans_rec.attribute10 := CSC_CORE_UTILS_PVT.Get_G_Miss_Char(p_csc_cust_plans_rec.attribute10, l_ref_CSC_CUST_PLANS_rec.ATTRIBUTE10);

	l_upd_csc_cust_plans_rec.attribute11 := CSC_CORE_UTILS_PVT.Get_G_Miss_Char(p_csc_cust_plans_rec.attribute11, l_ref_CSC_CUST_PLANS_rec.ATTRIBUTE11);

	l_upd_csc_cust_plans_rec.attribute12 := CSC_CORE_UTILS_PVT.Get_G_Miss_Char(p_csc_cust_plans_rec.attribute12, l_ref_CSC_CUST_PLANS_rec.ATTRIBUTE12);

	l_upd_csc_cust_plans_rec.attribute13 := CSC_CORE_UTILS_PVT.Get_G_Miss_Char(p_csc_cust_plans_rec.attribute13, l_ref_CSC_CUST_PLANS_rec.ATTRIBUTE13);

	l_upd_csc_cust_plans_rec.attribute14 := CSC_CORE_UTILS_PVT.Get_G_Miss_Char(p_csc_cust_plans_rec.attribute14, l_ref_CSC_CUST_PLANS_rec.ATTRIBUTE14);

	l_upd_csc_cust_plans_rec.attribute15 := CSC_CORE_UTILS_PVT.Get_G_Miss_Char(p_csc_cust_plans_rec.attribute15, l_ref_CSC_CUST_PLANS_rec.ATTRIBUTE15);

	l_upd_csc_cust_plans_rec.attribute_category := CSC_CORE_UTILS_PVT.Get_G_Miss_Char(p_csc_cust_plans_rec.attribute_category, l_ref_CSC_CUST_PLANS_rec.ATTRIBUTE_CATEGORY);

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL )
      THEN
          -- Invoke validation procedures
          Validate_csc_cust_plans(
              p_init_msg_list       => FND_API.G_FALSE,
              p_validation_level    => p_validation_level,
              p_validation_mode     => CSC_CORE_UTILS_PVT.G_UPDATE,
              P_CSC_CUST_PLANS_Rec  => L_UPD_CSC_CUST_PLANS_REC,
              x_return_status       => x_return_status,
              x_msg_count           => x_msg_count,
              x_msg_data            => x_msg_data);

         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF;

      -- Invoke table handler(CSC_CUST_PLANS_PKG.Update_Row)
      CSC_CUST_PLANS_PKG.Update_Row(
          p_CUST_PLAN_ID             => l_upd_csc_cust_plans_rec.CUST_PLAN_ID,
          p_PLAN_ID                  => l_upd_csc_cust_plans_rec.PLAN_ID,
          p_PARTY_ID                 => l_upd_csc_cust_plans_rec.PARTY_ID,
          p_CUST_ACCOUNT_ID          => l_upd_csc_cust_plans_rec.CUST_ACCOUNT_ID,
          -- p_CUST_ACCOUNT_ORG         => l_upd_csc_cust_plans_rec.CUST_ACCOUNT_ORG,
          p_START_DATE_ACTIVE        => l_upd_csc_cust_plans_rec.START_DATE_ACTIVE,
          p_END_DATE_ACTIVE          => l_upd_csc_cust_plans_rec.END_DATE_ACTIVE,
          p_MANUAL_FLAG              => l_upd_csc_cust_plans_rec.MANUAL_FLAG,
          p_PLAN_STATUS_CODE         => l_upd_csc_cust_plans_rec.PLAN_STATUS_CODE,
          p_REQUEST_ID               => l_upd_csc_cust_plans_rec.REQUEST_ID,
          p_PROGRAM_APPLICATION_ID   => l_upd_csc_cust_plans_rec.PROGRAM_APPLICATION_ID,
          p_PROGRAM_ID               => l_upd_csc_cust_plans_rec.PROGRAM_ID,
          p_PROGRAM_UPDATE_DATE      => l_upd_csc_cust_plans_rec.PROGRAM_UPDATE_DATE,
          p_LAST_UPDATE_DATE         => SYSDATE,
          p_LAST_UPDATED_BY          => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_LOGIN        => FND_GLOBAL.CONC_LOGIN_ID,
          p_ATTRIBUTE1               => l_upd_csc_cust_plans_rec.ATTRIBUTE1,
          p_ATTRIBUTE2               => l_upd_csc_cust_plans_rec.ATTRIBUTE2,
          p_ATTRIBUTE3               => l_upd_csc_cust_plans_rec.ATTRIBUTE3,
          p_ATTRIBUTE4               => l_upd_csc_cust_plans_rec.ATTRIBUTE4,
          p_ATTRIBUTE5               => l_upd_csc_cust_plans_rec.ATTRIBUTE5,
          p_ATTRIBUTE6               => l_upd_csc_cust_plans_rec.ATTRIBUTE6,
          p_ATTRIBUTE7               => l_upd_csc_cust_plans_rec.ATTRIBUTE7,
          p_ATTRIBUTE8               => l_upd_csc_cust_plans_rec.ATTRIBUTE8,
          p_ATTRIBUTE9               => l_upd_csc_cust_plans_rec.ATTRIBUTE9,
          p_ATTRIBUTE10              => l_upd_csc_cust_plans_rec.ATTRIBUTE10,
          p_ATTRIBUTE11              => l_upd_csc_cust_plans_rec.ATTRIBUTE11,
          p_ATTRIBUTE12              => l_upd_csc_cust_plans_rec.ATTRIBUTE12,
          p_ATTRIBUTE13              => l_upd_csc_cust_plans_rec.ATTRIBUTE13,
          p_ATTRIBUTE14              => l_upd_csc_cust_plans_rec.ATTRIBUTE14,
          p_ATTRIBUTE15              => l_upd_csc_cust_plans_rec.ATTRIBUTE15,
          p_ATTRIBUTE_CATEGORY       => l_upd_csc_cust_plans_rec.ATTRIBUTE_CATEGORY,
          X_OBJECT_VERSION_NUMBER    => X_OBJECT_VERSION_NUMBER);

      CSC_CUST_PLANS_AUDIT_PKG.Insert_Row(
          --px_PLAN_AUDIT_ID         => G_PLAN_AUDIT_ID,-- will be selected from the sequence.
          p_PLAN_ID                => l_upd_csc_cust_plans_rec.PLAN_ID ,
          p_PARTY_ID               => l_upd_csc_cust_plans_rec.PARTY_ID ,
          p_CUST_ACCOUNT_ID        => l_upd_csc_cust_plans_rec.CUST_ACCOUNT_ID ,
          -- p_CUST_ACCOUNT_ORG       => l_upd_csc_cust_plans_rec.CUST_ACCOUNT_ORG ,
          p_PLAN_STATUS_CODE       => l_upd_csc_cust_plans_rec.PLAN_STATUS_CODE ,
          p_REQUEST_ID             => l_upd_csc_cust_plans_rec.REQUEST_ID ,
          p_PROGRAM_APPLICATION_ID => l_upd_csc_cust_plans_rec.PROGRAM_APPLICATION_ID ,
          p_PROGRAM_ID             => l_upd_csc_cust_plans_rec.PROGRAM_ID ,
          p_PROGRAM_UPDATE_DATE    => l_upd_csc_cust_plans_rec.PROGRAM_UPDATE_DATE ,
          p_CREATION_DATE          => SYSDATE,
          p_LAST_UPDATE_DATE       => SYSDATE,
          p_CREATED_BY             => FND_GLOBAL.USER_ID,
          p_LAST_UPDATED_BY        => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_LOGIN      => FND_GLOBAL.CONC_LOGIN_ID,
          p_ATTRIBUTE1             => l_upd_csc_cust_plans_rec.ATTRIBUTE1 ,
          p_ATTRIBUTE2             => l_upd_csc_cust_plans_rec.ATTRIBUTE2 ,
          p_ATTRIBUTE3             => l_upd_csc_cust_plans_rec.ATTRIBUTE3 ,
          p_ATTRIBUTE4             => l_upd_csc_cust_plans_rec.ATTRIBUTE4 ,
          p_ATTRIBUTE5             => l_upd_csc_cust_plans_rec.ATTRIBUTE5 ,
          p_ATTRIBUTE6             => l_upd_csc_cust_plans_rec.ATTRIBUTE6 ,
          p_ATTRIBUTE7             => l_upd_csc_cust_plans_rec.ATTRIBUTE7 ,
          p_ATTRIBUTE8             => l_upd_csc_cust_plans_rec.ATTRIBUTE8 ,
          p_ATTRIBUTE9             => l_upd_csc_cust_plans_rec.ATTRIBUTE9 ,
          p_ATTRIBUTE10            => l_upd_csc_cust_plans_rec.ATTRIBUTE10 ,
          p_ATTRIBUTE11            => l_upd_csc_cust_plans_rec.ATTRIBUTE11 ,
          p_ATTRIBUTE12            => l_upd_csc_cust_plans_rec.ATTRIBUTE12 ,
          p_ATTRIBUTE13            => l_upd_csc_cust_plans_rec.ATTRIBUTE13 ,
          p_ATTRIBUTE14            => l_upd_csc_cust_plans_rec.ATTRIBUTE14 ,
          p_ATTRIBUTE15            => l_upd_csc_cust_plans_rec.ATTRIBUTE15 ,
          p_ATTRIBUTE_CATEGORY     => p_CSC_CUST_PLANS_rec.ATTRIBUTE_CATEGORY,
          x_PLAN_AUDIT_ID          => G_PLAN_AUDIT_ID );

--denzb***************************************************/
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

End Update_cust_plans;

PROCEDURE ENABLE_PLAN (
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_plan_id                    IN   NUMBER,
    p_party_id_tbl               IN   CSC_PARTY_ID_TBL_TYPE,
    p_plan_status_code           IN   VARCHAR2,
    X_OBJ_VER_NUM_TBL            OUT  NOCOPY CSC_OBJ_VER_NUM_TBL_TYPE,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
   )
IS
   l_csc_cust_plans_rec        CSC_CUST_PLANS_REC_TYPE;
   l_api_name                  CONSTANT VARCHAR2(30) := 'Enable_Plan';
   l_api_version_number        CONSTANT NUMBER       := 1.0;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT ENABLE_PLAN_PVT;

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


      for i in 1..p_party_id_tbl.count
	 loop
         Update_cust_plans(
            P_Api_Version_Number         =>  1.0,
            P_Init_Msg_List              =>  p_init_msg_list,
            P_Commit                     =>  p_commit,
            p_validation_level           =>  FND_API.G_VALID_LEVEL_NONE,
		  p_cust_plan_id               =>  NULL,
            P_PLAN_ID                    =>  p_plan_id,
            P_PARTY_ID                   =>  p_party_id_tbl(i).party_id,
            P_CUST_ACCOUNT_ID            =>  p_party_id_tbl(i).cust_account_id,
            -- P_CUST_ACCOUNT_ORG           =>  p_party_id_tbl(i).cust_account_org,
            P_PLAN_STATUS_CODE           =>  p_plan_status_code,
            P_OBJECT_VERSION_NUMBER      =>  p_party_id_tbl(i).object_version_number,
            X_OBJECT_VERSION_NUMBER      =>  x_obj_ver_num_tbl(i),
            X_Return_Status              =>  x_return_status,
            X_Msg_Count                  =>  x_msg_count,
            X_Msg_Data                   =>  x_msg_data );

         if ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) then
            raise FND_API.G_EXC_ERROR;
         end if;
      end loop;


/******************* using regular update procedure

         CSC_CUST_PLANS_PKG.LOCK_ROW (
		  p_plan_id               => p_plan_id,
		  p_party_id              => p_party_id_tbl(i).party_id,
		  p_cust_account_id       => p_party_id_tbl(i).cust_account_id,
            -- p_cust_account_org      => p_party_id_tbl(i).cust_account_org,
		  p_object_version_number => p_party_id_tbl(i).object_version_number );

         update csc_cust_plans
	    set    plan_status_code      = p_plan_status_code,
		      object_version_number = object_version_number + 1
	    where plan_id                = p_plan_id
	    and   party_id               = p_party_id_tbl(i).party_id
	    and   nvl(cust_account_id,0) = nvl(p_party_id_tbl(i).cust_account_id,0)
	    and   object_version_number  = p_party_id_tbl(i).object_version_number;

         X_OBJ_VER_NUM_TBL(i)    :=  p_party_id_tbl(i).object_version_number + 1;
      end loop;
****************/

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

END ENABLE_PLAN;

PROCEDURE DISABLE_PLAN (
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_plan_id                    IN   NUMBER,
    p_party_id_tbl               IN   CSC_PARTY_ID_TBL_TYPE,
    p_plan_status_code           IN   VARCHAR2,
    X_OBJ_VER_NUM_TBL            OUT  NOCOPY CSC_OBJ_VER_NUM_TBL_TYPE,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
   )
IS
   l_csc_cust_plans_rec        CSC_CUST_PLANS_REC_TYPE;
   l_api_name                  CONSTANT VARCHAR2(30) := 'Disable_Plan';
   l_api_version_number        CONSTANT NUMBER       := 1.0;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DISABLE_PLAN_PVT;

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

      for i in 1..p_party_id_tbl.count
	 loop
         Update_cust_plans(
            P_Api_Version_Number         =>  1.0,
            P_Init_Msg_List              =>  p_init_msg_list,
            P_Commit                     =>  p_commit,
            p_validation_level           =>  FND_API.G_VALID_LEVEL_NONE,
		  p_cust_plan_id               =>  NULL,
            P_PLAN_ID                    =>  p_plan_id,
            P_PARTY_ID                   =>  p_party_id_tbl(i).party_id,
            P_CUST_ACCOUNT_ID            =>  p_party_id_tbl(i).cust_account_id,
            -- P_CUST_ACCOUNT_ORG           =>  p_party_id_tbl(i).cust_account_org,
            P_PLAN_STATUS_CODE           =>  p_plan_status_code,
            P_OBJECT_VERSION_NUMBER      =>  p_party_id_tbl(i).object_version_number,
            X_OBJECT_VERSION_NUMBER      =>  x_obj_ver_num_tbl(i),
            X_Return_Status              =>  x_return_status,
            X_Msg_Count                  =>  x_msg_count,
            X_Msg_Data                   =>  x_msg_data );

         if ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) then
            raise FND_API.G_EXC_ERROR;
         end if;
      end loop;

/******* using regular update procedure to take of audit insert

         CSC_CUST_PLANS_PKG.LOCK_ROW (
		  p_plan_id               => p_plan_id,
		  p_party_id              => p_party_id_tbl(i).party_id,
		  p_cust_account_id       => p_party_id_tbl(i).cust_account_id,
            -- p_cust_account_org      => p_party_id_tbl(i).cust_account_org,
		  p_object_version_number => p_party_id_tbl(i).object_version_number );

         update csc_cust_plans
	    set    plan_status_code      = p_plan_status_code,
		      object_version_number = object_version_number + 1
	    where plan_id                = p_plan_id
	    and   party_id               = p_party_id_tbl(i).party_id
	    and   nvl(cust_account_id,0) = nvl(p_party_id_tbl(i).cust_account_id,0)
	    and   object_version_number  = p_party_id_tbl(i).object_version_number;

         X_OBJ_VER_NUM_TBL(i)    :=  p_party_id_tbl(i).object_version_number + 1;

      end loop;
***********/

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

END DISABLE_PLAN;

PROCEDURE Update_for_customized_plans (
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_PLAN_ID                    IN   NUMBER,
    P_ORIGINAL_PLAN_ID           IN   NUMBER,
    P_PARTY_ID                   IN   NUMBER,
    P_CUST_ACCOUNT_ID            IN   NUMBER := NULL,
    -- P_CUST_ACCOUNT_ORG           IN   NUMBER := NULL,
    P_OBJECT_VERSION_NUMBER      IN   NUMBER,
    X_OBJECT_VERSION_NUMBER      OUT  NOCOPY NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    )
IS
   cursor c1 is
	 select *
	 from   csc_cust_plans
	 where  plan_id                  = p_original_plan_id
	 and    party_id                 = p_party_id
	 and    nvl(cust_account_id,0)   = nvl(p_cust_account_id, nvl(cust_account_id,0))
	 and    object_version_number    = p_object_version_number;

   c1rec   c1%rowtype;

   l_api_name                CONSTANT VARCHAR2(30) := 'Update_for_customized_plans';
   l_api_version_number      CONSTANT NUMBER       := 1.0;

   l_cust_plan_id             NUMBER;
   l_object_version_number    NUMBER;
   lx_object_version_number   NUMBER;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_FOR_CUSTMIZED_PLANS_PVT;

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

      open c1;
      fetch c1 into c1rec;

      if ( c1%NOTFOUND ) then
         close c1;
         FND_MESSAGE.Set_Name(CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'API_MISSING_UPDATE_TARGET');
         FND_MESSAGE.Set_Token ('INFO', 'CSC_CUST_PLANS', FALSE);
         x_return_status := FND_API.G_RET_STS_ERROR;
         raise FND_API.G_EXC_ERROR;
      END IF;
      close c1;

      CSC_CUST_PLANS_PKG.LOCK_ROW(
	    p_plan_id                 => p_original_plan_id,
	    p_party_id                => p_party_id,
	    p_cust_account_id         => p_cust_account_id,
	    -- p_cust_account_org        => p_cust_account_org,
	    p_object_version_number   => p_object_version_number );


	    update csc_cust_plans
	    SET    PLAN_ID               = P_PLAN_ID,
			 OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1
	    where  plan_id                  = p_original_plan_id
	    and    party_id                 = nvl(p_party_id, party_id)
	    and    nvl(cust_account_id, 0)  = nvl(p_cust_account_id, nvl(cust_account_id,0) )
         and    object_version_number    = p_object_version_number;

      CSC_CUST_PLANS_AUDIT_PKG.Insert_Row(
          --px_PLAN_AUDIT_ID         => G_PLAN_AUDIT_ID,-- will be selected from the sequence.
          p_PLAN_ID                => P_PLAN_ID ,
          p_PARTY_ID               => P_PARTY_ID ,
          p_CUST_ACCOUNT_ID        => P_CUST_ACCOUNT_ID ,
          -- p_CUST_ACCOUNT_ORG       => P_CUST_ACCOUNT_ORG ,
          p_PLAN_STATUS_CODE       => c1rec.PLAN_STATUS_CODE ,
          p_REQUEST_ID             => c1rec.REQUEST_ID ,
          p_PROGRAM_APPLICATION_ID => c1rec.PROGRAM_APPLICATION_ID ,
          p_PROGRAM_ID             => c1rec.PROGRAM_ID ,
          p_PROGRAM_UPDATE_DATE    => c1rec.PROGRAM_UPDATE_DATE ,
          p_CREATION_DATE          => SYSDATE,
          p_LAST_UPDATE_DATE       => SYSDATE,
          p_CREATED_BY             => FND_GLOBAL.USER_ID,
          p_LAST_UPDATED_BY        => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_LOGIN      => FND_GLOBAL.CONC_LOGIN_ID,
          p_ATTRIBUTE1             => c1rec.ATTRIBUTE1 ,
          p_ATTRIBUTE2             => c1rec.ATTRIBUTE2 ,
          p_ATTRIBUTE3             => c1rec.ATTRIBUTE3 ,
          p_ATTRIBUTE4             => c1rec.ATTRIBUTE4 ,
          p_ATTRIBUTE5             => c1rec.ATTRIBUTE5 ,
          p_ATTRIBUTE6             => c1rec.ATTRIBUTE6 ,
          p_ATTRIBUTE7             => c1rec.ATTRIBUTE7 ,
          p_ATTRIBUTE8             => c1rec.ATTRIBUTE8 ,
          p_ATTRIBUTE9             => c1rec.ATTRIBUTE9 ,
          p_ATTRIBUTE10            => c1rec.ATTRIBUTE10 ,
          p_ATTRIBUTE11            => c1rec.ATTRIBUTE11 ,
          p_ATTRIBUTE12            => c1rec.ATTRIBUTE12 ,
          p_ATTRIBUTE13            => c1rec.ATTRIBUTE13 ,
          p_ATTRIBUTE14            => c1rec.ATTRIBUTE14 ,
          p_ATTRIBUTE15            => c1rec.ATTRIBUTE15 ,
          p_ATTRIBUTE_CATEGORY     => c1rec.ATTRIBUTE_CATEGORY,
          x_PLAN_AUDIT_ID          => G_PLAN_AUDIT_ID );

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

END   update_for_customized_plans;

PROCEDURE Delete_cust_plans(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER  ,
    P_CUST_PLAN_ID               IN   NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    )
IS
-- cursor to select the values of CSC_CUST_PLANS table which will be used as
-- input values to do insert into CSC_CUST_PLANS_AUDIT table.
   cursor C1 ( C_CUST_PLAN_ID NUMBER ) is
   SELECT CUST_PLAN_ID ,        PLAN_ID ,                PARTY_ID ,
          CUST_ACCOUNT_ID ,     -- CUST_ACCOUNT_ORG ,       START_DATE_ACTIVE ,
          END_DATE_ACTIVE ,     MANUAL_FLAG ,            PLAN_STATUS_CODE ,
          REQUEST_ID ,          PROGRAM_APPLICATION_ID , PROGRAM_ID ,
          PROGRAM_UPDATE_DATE , LAST_UPDATE_DATE ,       CREATION_DATE ,
          LAST_UPDATED_BY ,     CREATED_BY ,             LAST_UPDATE_LOGIN ,
          ATTRIBUTE1 ,          ATTRIBUTE2 ,             ATTRIBUTE3 ,
          ATTRIBUTE4 ,          ATTRIBUTE5 ,             ATTRIBUTE6 ,
          ATTRIBUTE7 ,          ATTRIBUTE8 ,             ATTRIBUTE9 ,
          ATTRIBUTE10 ,         ATTRIBUTE11 ,            ATTRIBUTE12 ,
          ATTRIBUTE13 ,         ATTRIBUTE14 ,            ATTRIBUTE15 ,
          ATTRIBUTE_CATEGORY ,  OBJECT_VERSION_NUMBER
   FROM   csc_cust_plans
   WHERE  cust_plan_id = c_cust_plan_id;

   C1REC                     C1%ROWTYPE;

   l_api_name                CONSTANT VARCHAR2(30) := 'Delete_cust_plans';
   l_api_version_number      CONSTANT NUMBER       := 1.0;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_CUST_PLANS_PVT;

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

	 -- Fetch the values of the cust_plans rec to insert into the audit table.
      open c1 (p_cust_plan_id);
	 fetch c1 into c1rec;
	 if c1%notfound then
	    close c1;
	    raise no_data_found;
      end if;
	 close c1;

      -- Invoke table handler(CSC_CUST_PLANS_PKG.Delete_Row)
      CSC_CUST_PLANS_PKG.Delete_Row(
                    p_CUST_PLAN_ID  => p_CUST_PLAN_ID);

      -- Insert row into CSC_CUST_PLANS_AUDIT table with the selected cursor values
	 -- and with PLAN_STATUS_CODE = 'DELETED';
      CSC_CUST_PLANS_AUDIT_PKG.Insert_Row(
          --px_PLAN_AUDIT_ID         => G_PLAN_AUDIT_ID,-- will be selected from the sequence.
          p_PLAN_ID                => c1rec.PLAN_ID ,
          p_PARTY_ID               => c1rec.PARTY_ID ,
          p_CUST_ACCOUNT_ID        => c1rec.CUST_ACCOUNT_ID ,
          -- p_CUST_ACCOUNT_ORG       => c1rec.CUST_ACCOUNT_ORG ,
          p_PLAN_STATUS_CODE       => CSC_CORE_UTILS_PVT.REMOVE_PLAN,
          p_REQUEST_ID             => c1rec.REQUEST_ID ,
          p_PROGRAM_APPLICATION_ID => c1rec.PROGRAM_APPLICATION_ID ,
          p_PROGRAM_ID             => c1rec.PROGRAM_ID ,
          p_PROGRAM_UPDATE_DATE    => c1rec.PROGRAM_UPDATE_DATE ,
          p_CREATION_DATE          => SYSDATE,
          p_LAST_UPDATE_DATE       => SYSDATE,
          p_CREATED_BY             => FND_GLOBAL.USER_ID,
          p_LAST_UPDATED_BY        => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_LOGIN      => FND_GLOBAL.CONC_LOGIN_ID,
          p_ATTRIBUTE1             => c1rec.ATTRIBUTE1 ,
          p_ATTRIBUTE2             => c1rec.ATTRIBUTE2 ,
          p_ATTRIBUTE3             => c1rec.ATTRIBUTE3 ,
          p_ATTRIBUTE4             => c1rec.ATTRIBUTE4 ,
          p_ATTRIBUTE5             => c1rec.ATTRIBUTE5 ,
          p_ATTRIBUTE6             => c1rec.ATTRIBUTE6 ,
          p_ATTRIBUTE7             => c1rec.ATTRIBUTE7 ,
          p_ATTRIBUTE8             => c1rec.ATTRIBUTE8 ,
          p_ATTRIBUTE9             => c1rec.ATTRIBUTE9 ,
          p_ATTRIBUTE10            => c1rec.ATTRIBUTE10 ,
          p_ATTRIBUTE11            => c1rec.ATTRIBUTE11 ,
          p_ATTRIBUTE12            => c1rec.ATTRIBUTE12 ,
          p_ATTRIBUTE13            => c1rec.ATTRIBUTE13 ,
          p_ATTRIBUTE14            => c1rec.ATTRIBUTE14 ,
          p_ATTRIBUTE15            => c1rec.ATTRIBUTE15 ,
          p_ATTRIBUTE_CATEGORY     => c1rec.ATTRIBUTE_CATEGORY,
          x_PLAN_AUDIT_ID          => G_PLAN_AUDIT_ID );

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

End Delete_cust_plans;


PROCEDURE GET_CUST_PLAN_ID(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_WHERE_CLAUSE               IN   VARCHAR2,
    X_CUST_PLAN_ID               OUT  NOCOPY NUMBER
    --X_Return_Status              OUT  NOCOPY VARCHAR2,
    --X_Msg_Count                  OUT  NOCOPY NUMBER,
    --X_Msg_Data                   OUT  NOCOPY VARCHAR2
    )
IS
   sql_stmt     varchar2(500);

   v_party_id   NUMBER(15);
   v_plan_id    NUMBER(15);
   v_c_acct_id  NUMBER(15);

   v_position1  NUMBER(10);
   v_position2  NUMBER(10);

   v_where varchar2(300);

BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      -- x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- sql_stmt := 'select cust_plan_id from csc_cust_plans where ' || p_where_clause;
     -- execute immediate sql_stmt into x_cust_plan_id;

     /* The code has been modfied to have dynamic sql bind variable complaince
        The existing dynamic where clause has two parts, the second part of the where cluase
        is return from the ftree funtion there it already constructs the column
        values. In order to make the sql to have bind variable complains, the following
        changs has been made */

     v_where := upper(p_where_clause);
     v_position1 := instr(v_where , '=',1,1);
     v_position2 := instr(v_where , 'AND' ,1,1);
     v_party_id := substr(v_where,v_position1+1,(v_position2-v_position1-1));

     v_position1 := instr(v_where,'=',1,2);
     v_position2 := instr(v_where , 'AND' ,1,2);
     v_plan_id := substr(v_where,v_position1+1,(v_position2-v_position1-1));

     if (instr(v_where,'IS',1,1)>0) then
        sql_stmt := 'select cust_plan_id from csc_cust_plans where ' ||
         ' party_id = :1 and plan_id = :2 and cust_account_id is null ';
        execute immediate sql_stmt into x_cust_plan_id using v_party_id,v_plan_id;
     else
           sql_stmt := 'select cust_plan_id from csc_cust_plans where ' ||
         ' party_id = :1 and plan_id = :2 and cust_account_id = :3 ';
         v_position1 := instr(v_where,'=',1,3);
         v_position2 := length(v_where);
         v_c_acct_id := substr(v_where,v_position1+1,(v_position2-v_position1));
         execute immediate sql_stmt into x_cust_plan_id using v_party_id,v_plan_id,v_c_acct_id;
     end if;

END  get_cust_plan_id;


-- Item-level validation procedures

PROCEDURE Validate_CUST_PLAN_ID (
    P_Init_Msg_List              IN   VARCHAR2,
    P_Validation_mode            IN   VARCHAR2,
    P_CUST_PLAN_ID               IN   NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    )
IS
   cursor check_dup_id is
   select cust_plan_id
   from   CSC_CUST_PLANS
   where  cust_plan_id = p_cust_plan_id;

   l_cust_plan_id   number;
   l_api_name       varchar2(30) := 'Validate_Cust_Plan_Id';
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- validate NOT NULL column.
      if (p_validation_mode = CSC_CORE_UTILS_PVT.G_UPDATE) then
         IF(p_CUST_PLAN_ID is NULL or p_CUST_PLAN_ID = FND_API.G_MISS_NUM) then
            fnd_message.set_name (CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'CS_API_ALL_NULL_PARAMETER');
            fnd_message.set_token ('API_NAME', G_PKG_NAME||'.'|| l_api_name);
            fnd_message.set_token('NULL_PARAM', 'CUST_PLAN_ID');
            -- fnd_msg_pub.add;
            x_return_status := FND_API.G_RET_STS_ERROR;
         END IF;
      end if;

      -- validate for duplicate plan_ids.
      IF (p_validation_mode = CSC_CORE_UTILS_PVT.G_CREATE)
      THEN
         open check_dup_id;
         fetch check_dup_id into l_cust_plan_id;
         if check_dup_id%FOUND then
            fnd_message.set_name (CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'CS_API_ALL_DUPLICATE_VALUE');
            fnd_message.set_token ('API_NAME', G_PKG_NAME||'.'|| l_api_name);
            fnd_message.set_token('DUPLICATE_VAL_PARAM', 'CUST_PLAN_ID');
            -- fnd_msg_pub.add;
            x_return_status := FND_API.G_RET_STS_ERROR;
         end if;
         close check_dup_id;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

END Validate_CUST_PLAN_ID;


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
      IF(p_PLAN_ID is NULL or p_plan_id = FND_API.G_MISS_NUM) then
         fnd_message.set_name (CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'CS_API_ALL_NULL_PARAMETER');
         fnd_message.set_token ('API_NAME', G_PKG_NAME||'.'|| l_api_name);
         fnd_message.set_token('NULL_PARAM', 'PLAN_ID');
         -- fnd_msg_pub.add;
         x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      -- validate for valid plan_ids.
      if ( x_return_status = FND_API.G_RET_STS_SUCCESS ) then
         open c1;
         fetch c1 into l_plan_id;
         if c1%NOTFOUND then
            fnd_message.set_name(CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'CS_API_ALL_INVALID_ARGUMENT');
            fnd_message.set_token('API_NAME',  G_PKG_NAME||'.'|| l_api_name);
            fnd_message.set_token('VALUE',     p_plan_id);
            fnd_message.set_token('PARAMETER', 'PLAN_ID');
            -- fnd_msg_pub.add;
            x_return_status := FND_API.G_RET_STS_ERROR;
         end if;
         close c1;
      end if;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data  );

END Validate_PLAN_ID;

PROCEDURE Validate_PARTY_ID (
    P_Init_Msg_List              IN   VARCHAR2,
    P_Validation_mode            IN   VARCHAR2,
    P_PARTY_ID                   IN   NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    )
IS
   cursor c1 is
      select party_id
      from   jtf_parties_all_v
      where  party_id = p_party_id;

   l_party_id      NUMBER;
   l_api_name      varchar2(30) := 'Validate_Party_Id';
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- validate NOT NULL column
      IF( p_PARTY_ID is NULL or p_party_id = FND_API.G_MISS_NUM ) then
         fnd_message.set_name (CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'CS_API_ALL_NULL_PARAMETER');
         fnd_message.set_token ('API_NAME', G_PKG_NAME||'.'|| l_api_name);
         fnd_message.set_token('NULL_PARAM', 'PARTY_ID');
         -- fnd_msg_pub.add;
         x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      -- validate for valid party_ids.
      if ( x_return_status = FND_API.G_RET_STS_SUCCESS ) then
         open c1;
         fetch c1 into l_party_id;
         if c1%NOTFOUND then
            fnd_message.set_name(CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'CS_API_ALL_INVALID_ARGUMENT');
            fnd_message.set_token('API_NAME',  G_PKG_NAME||'.'|| l_api_name);
            fnd_message.set_token('VALUE',     p_party_id);
            fnd_message.set_token('PARAMETER', 'PARTY_ID');
            -- fnd_msg_pub.add;
            x_return_status := FND_API.G_RET_STS_ERROR;
         end if;
         close c1;
      end if;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

END Validate_PARTY_ID;


/******************************REMOVE ORG_ID  04-10-2000 ************************
Incorparating TCA changes - Removing org_id reference completely

PROCEDURE Validate_CUST_ACC_ORG_ID (
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_mode            IN   VARCHAR2,
    P_PARTY_ID                   IN   NUMBER,
    P_CUST_ACCOUNT_ID            IN   NUMBER,
    P_CUST_ACCOUNT_ORG           IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    )
IS
   cursor c1 is
      select cust_account_id, org_id
      from   jtf_cust_accounts_all_v
      where  party_id        = p_party_id
	 and    cust_account_id = p_cust_account_id;

   l_cust_account_id     number;
   l_org_id              number;
   l_api_name            varchar2(30) := 'Validate_Cust_Acc_Org_Id';

BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

	 if (p_cust_account_id is NULL or p_cust_account_org is NULL ) THEN
         fnd_message.set_name (CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'CS_API_ALL_NULL_PARAMETER');
         fnd_message.set_token ('API_NAME', G_PKG_NAME||'.'|| l_api_name);
	    if ( p_cust_account_id is NULL and p_cust_account_org is NULL ) then
            fnd_message.set_token('NULL_PARAM', 'P_CUST_ACCOUNT_ID'||' and '||'P_CUST_ACCOUNT_ORG' );
	    elsif ( p_cust_account_id is NULL and p_cust_account_org is not NULL ) then
            fnd_message.set_token('NULL_PARAM', 'P_CUST_ACCOUNT_ID');
	    else
            fnd_message.set_token('NULL_PARAM', 'P_CUST_ACCOUNT_ORG');
         end if;
         -- fnd_msg_pub.add;
         x_return_status := FND_API.G_RET_STS_ERROR;
      end if;

      if ( p_cust_account_id is not null and p_cust_account_org is not null ) then
         open c1;
         fetch c1 into l_cust_account_id, l_org_id;
         if c1%NOTFOUND then
            fnd_message.set_name(CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'CS_API_ALL_INVALID_ARGUMENT');
            fnd_message.set_token('API_NAME',  G_PKG_NAME||'.'|| l_api_name);
            fnd_message.set_token('VALUE',     p_cust_account_id ||',  '|| p_cust_account_org);
            fnd_message.set_token('PARAMETER', 'CUST_ACCOUNT_ID, CUST_ACCOUNT_ORG');
            -- fnd_msg_pub.add;
            x_return_status := FND_API.G_RET_STS_ERROR;
         end if;
         close c1;
      end if;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

END Validate_CUST_ACC_ORG_ID ;
*/

PROCEDURE Validate_MANUAL_FLAG (
    P_Init_Msg_List              IN   VARCHAR2,
    P_Validation_mode            IN   VARCHAR2,
    P_MANUAL_FLAG                IN   VARCHAR2,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    )
IS
   l_api_name    varchar2(30)  := 'Validate_Manual_Flag';
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- validate NOT NULL column
      IF( p_MANUAL_FLAG is NULL or p_MANUAL_FLAG = FND_API.G_MISS_CHAR ) then
         fnd_message.set_name (CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'CS_API_ALL_NULL_PARAMETER');
         fnd_message.set_token ('API_NAME', G_PKG_NAME||'.'|| l_api_name);
         fnd_message.set_token('NULL_PARAM', 'MANUAL_FLAG');
         -- fnd_msg_pub.add;
         x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      if ( x_return_status = FND_API.G_RET_STS_SUCCESS ) then
         if ( p_manual_flag <> 'Y' and p_manual_flag <> 'N' ) then
            fnd_message.set_name(CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'CS_API_ALL_INVALID_ARGUMENT');
            fnd_message.set_token('API_NAME',  G_PKG_NAME||'.'|| l_api_name);
            fnd_message.set_token('VALUE',     p_manual_flag);
            fnd_message.set_token('PARAMETER', 'P_MANUAL_FLAG');
            -- fnd_msg_pub.add;
            x_return_status := FND_API.G_RET_STS_ERROR;
         end if;
      end if;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

END Validate_MANUAL_FLAG;

PROCEDURE Validate_PLAN_STATUS_CODE (
    P_Init_Msg_List              IN   VARCHAR2,
    P_Validation_mode            IN   VARCHAR2,
    P_PLAN_STATUS_CODE           IN   VARCHAR2,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    )
IS
   cursor group_in_lookup is
      select count(*)
      from   csc_lookups
      where  lookup_type = 'CSC_PLAN_STATUS'
	 and    lookup_code = p_PLAN_STATUS_CODE
      and    sysdate between nvl(start_date_active, sysdate)
                         and nvl(end_date_active, sysdate);

   l_count      NUMBER  := 0;
   l_api_name   varchar2(30) := 'Validate_Plan_Status_Code';
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- validate NOT NULL column
      IF (p_PLAN_STATUS_CODE is NULL or p_PLAN_STATUS_CODE = FND_API.G_MISS_CHAR) then
          fnd_message.set_name (CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'CS_API_ALL_NULL_PARAMETER');
          fnd_message.set_token ('API_NAME', G_PKG_NAME||'.'||l_api_name);
          fnd_message.set_token('NULL_PARAM', 'PLAN_STATUS_CODE');
          -- fnd_msg_pub.add;
          x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      -- validate PLAN_STATUS_CODE exists in fnd_lookup_values.
      if ( x_return_status = FND_API.G_RET_STS_SUCCESS ) then
         open group_in_lookup;
         fetch group_in_lookup into l_count;
         close group_in_lookup;

         if ( l_count = 0  or l_count > 1 ) then
            fnd_message.set_name(CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'CS_API_ALL_INVALID_ARGUMENT');
            fnd_message.set_token('API_NAME',  G_PKG_NAME||'.'|| l_api_name);
            fnd_message.set_token('VALUE',     p_plan_status_code);
            fnd_message.set_token('PARAMETER', 'P_STATUS_CODE');
            -- fnd_msg_pub.add;
            x_return_status := FND_API.G_RET_STS_ERROR;
         end if;
      end if;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data  );

END Validate_PLAN_STATUS_CODE;


PROCEDURE Validate_csc_cust_plans(
    P_Init_Msg_List              IN   VARCHAR2,
    P_Validation_level           IN   NUMBER  ,
    P_Validation_mode            IN   VARCHAR2,
    P_CSC_CUST_PLANS_Rec         IN   CSC_CUST_PLANS_Rec_Type,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    )
IS
   l_api_name   CONSTANT VARCHAR2(30) := 'Validate_csc_cust_plans';
BEGIN
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN

          Validate_CUST_PLAN_ID(
              p_init_msg_list          => FND_API.G_TRUE,
              p_validation_mode        => p_validation_mode,
              p_CUST_PLAN_ID           => P_CSC_CUST_PLANS_Rec.CUST_PLAN_ID,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PLAN_ID(
              p_init_msg_list          => FND_API.G_TRUE,
              p_validation_mode        => p_validation_mode,
              p_PLAN_ID                => P_CSC_CUST_PLANS_Rec.PLAN_ID,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PARTY_ID(
              p_init_msg_list          => FND_API.G_TRUE,
              p_validation_mode        => p_validation_mode,
              p_PARTY_ID               => P_CSC_CUST_PLANS_Rec.PARTY_ID,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

/******************************REMOVE ORG_ID************************
Incorparating TCA changes - Removing org_id reference completely

          Validate_CUST_ACC_ORG_ID (
              p_init_msg_list          => FND_API.G_TRUE,
              p_validation_mode        => p_validation_mode,
		    p_PARTY_ID               => P_CSC_CUST_PLANS_Rec.PARTY_ID,
              p_CUST_ACCOUNT_ID        => P_CSC_CUST_PLANS_Rec.CUST_ACCOUNT_ID,
              p_CUST_ACCOUNT_ORG       => P_CSC_CUST_PLANS_Rec.CUST_ACCOUNT_ORG,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
**********************************************************/

          Validate_MANUAL_FLAG(
              p_init_msg_list          => FND_API.G_TRUE,
              p_validation_mode        => p_validation_mode,
              p_MANUAL_FLAG            => P_CSC_CUST_PLANS_Rec.MANUAL_FLAG,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PLAN_STATUS_CODE(
              p_init_msg_list          => FND_API.G_TRUE,
              p_validation_mode        => p_validation_mode,
              p_PLAN_STATUS_CODE       => P_CSC_CUST_PLANS_Rec.PLAN_STATUS_CODE,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

/*
          CSC_CORE_UTILS_PVT.VALIDATE_NOT_NULLS(
             p_init_msg_list       =>  FND_API.G_TRUE,
             p_validation_mode     =>  p_validation_mode,
             P_COLUMN_NAME         =>  'CREATION_DATE',
             P_COLUMN_VALUE        =>  P_CSC_CUST_PLANS_REC.CREATION_DATE,
             x_return_status       =>  x_return_status,
             x_msg_count           =>  x_msg_count,
             x_msg_data            =>  x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          CSC_CORE_UTILS_PVT.VALIDATE_NOT_NULLS(
             p_init_msg_list       =>  FND_API.G_TRUE,
             p_validation_mode     =>  p_validation_mode,
             P_COLUMN_NAME         =>  'LAST_UPDATE_DATE',
             P_COLUMN_VALUE        =>  P_CSC_CUST_PLANS_REC.LAST_UPDATE_DATE,
             x_return_status       =>  x_return_status,
             x_msg_count           =>  x_msg_count,
             x_msg_data            =>  x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          CSC_CORE_UTILS_PVT.VALIDATE_NOT_NULLS(
             p_init_msg_list       =>  FND_API.G_TRUE,
             p_validation_mode     =>  p_validation_mode,
             P_COLUMN_NAME         =>  'CREATED_BY',
             P_COLUMN_VALUE        =>  P_CSC_CUST_PLANS_REC.CREATED_BY,
             x_return_status       =>  x_return_status,
             x_msg_count           =>  x_msg_count,
             x_msg_data            =>  x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          CSC_CORE_UTILS_PVT.VALIDATE_NOT_NULLS(
             p_init_msg_list       =>  FND_API.G_TRUE,
             p_validation_mode     =>  p_validation_mode,
             P_COLUMN_NAME         =>  'LAST_UPDATED_BY',
             P_COLUMN_VALUE        =>  P_CSC_CUST_PLANS_REC.LAST_UPDATED_BY,
             x_return_status       =>  x_return_status,
             x_msg_count           =>  x_msg_count,
             x_msg_data            =>  x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          CSC_CORE_UTILS_PVT.VALIDATE_NOT_NULLS(
             p_init_msg_list       =>  FND_API.G_TRUE,
             p_validation_mode     =>  p_validation_mode,
             P_COLUMN_NAME         =>  'OBJECT_VERSION_NUMBER',
             P_COLUMN_VALUE        =>  P_CSC_CUST_PLANS_REC.OBJECT_VERSION_NUMBER,
             x_return_status       =>  x_return_status,
             x_msg_count           =>  x_msg_count,
             x_msg_data            =>  x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;
*/
      END IF;

END Validate_csc_cust_plans;

End CSC_CUST_PLANS_PVT;

/
