--------------------------------------------------------
--  DDL for Package Body CSC_CUST_PLANS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSC_CUST_PLANS_PUB" as
/* $Header: cscpctpb.pls 115.13 2002/11/27 09:05:30 bhroy ship $ */
-- Start of Comments
-- Package name     : CSC_CUST_PLANS_PUB
-- Purpose          : Public package contains procedure to insert, update and
--                    delete records from CSC_CUST_PLANS table. This package
--                    calls the private API with validation level 100 (FULL).
-- History          :
-- MM-DD-YYYY    NAME          MODIFICATIONS
-- 10-28-1999    dejoseph      Created.
-- 12-08-1999    dejoseph      'Arcs'ed in for first code freeze.
-- 12-21-1999    dejoseph      'Arcs'ed in for second code freeze.
-- 01-03-2000    dejoseph      'Arcs'ed in for third code freeze. (10-JAN-2000)
-- 01-31-2000    dejoseph      'Arcs'ed in for fourth code freeze. (07-FEB-2000)
-- 02-13-2000    dejoseph      'Arcs'ed on for fifth code freeze. (21-FEB-2000)
-- 02-28-2000    dejoseph      'Arcs'ed on for sixth code freeze. (06-MAR-2000)
-- 04-10-2000    dejoseph      Removed reference to cust_account_org in lieu of TCA's
--                             decision to drop column org_id from hz_cust_accounts.

-- 26-11-2002	bhroy		G_MISS_XXX defaults of API parameters removed, added WHENEVER OSERROR EXIT FAILURE ROLLBACK

-- NOTE             :
-- End of Comments


G_PKG_NAME    CONSTANT VARCHAR2(30) := 'CSC_CUST_PLANS_PUB';
G_FILE_NAME   CONSTANT VARCHAR2(12) := 'cscpctpb.pls';

-- Start of Comments
-- ***************** Private Conversion Routines Values -> Ids **************
-- Purpose
--
-- This procedure takes a public CUST_PLANS record as input. It may contain
-- values or ids. All values are then converted into ids and a
-- private CUST_PLANSrecord is returned for the private
-- API call.
--
-- Conversions:
--
-- Notes
--
-- 1. IDs take precedence over values. If both are present for a field, ID is used,
--    the value based parameter is ignored and a warning message is created.
-- 2. This is automatically generated procedure, it converts public record type to
--    private record type for all attributes.
--    Developer must manually add conversion logic to the attributes.
--
-- End of Comments

PROCEDURE CONVERT_CSC_CUST_PLANS(
         P_CSC_CUST_PLANS_Rec        IN   CSC_cust_plans_PUB.CSC_CUST_PLANS_Rec_Type,
         x_pvt_CSC_CUST_PLANS_rec    OUT   NOCOPY CSC_cust_plans_PVT.CSC_CUST_PLANS_Rec_Type
)
IS
-- Hint: Declare cursor and local variables
-- Example: CURSOR C_Get_Lookup_Code(X_Lookup_Type VARCHAR2, X_Meaning VARCHAR2) IS
--          SELECT lookup_code
--          FROM   as_lookups
--          WHERE  lookup_type = X_Lookup_Type and nls_upper(meaning) = nls_upper(X_Meaning);
l_any_errors       BOOLEAN   := FALSE;
BEGIN
    x_pvt_CSC_CUST_PLANS_rec.CUST_PLAN_ID := P_CSC_CUST_PLANS_Rec.CUST_PLAN_ID;
    x_pvt_CSC_CUST_PLANS_rec.PLAN_ID := P_CSC_CUST_PLANS_Rec.PLAN_ID;
    x_pvt_CSC_CUST_PLANS_rec.PARTY_ID := P_CSC_CUST_PLANS_Rec.PARTY_ID;
    x_pvt_CSC_CUST_PLANS_rec.CUST_ACCOUNT_ID := P_CSC_CUST_PLANS_Rec.CUST_ACCOUNT_ID;
    --x_pvt_CSC_CUST_PLANS_rec.CUST_ACCOUNT_ORG := P_CSC_CUST_PLANS_Rec.CUST_ACCOUNT_ORG;
    x_pvt_CSC_CUST_PLANS_rec.START_DATE_ACTIVE := P_CSC_CUST_PLANS_Rec.START_DATE_ACTIVE;
    x_pvt_CSC_CUST_PLANS_rec.END_DATE_ACTIVE := P_CSC_CUST_PLANS_Rec.END_DATE_ACTIVE;
    x_pvt_CSC_CUST_PLANS_rec.MANUAL_FLAG := P_CSC_CUST_PLANS_Rec.MANUAL_FLAG;
    x_pvt_CSC_CUST_PLANS_rec.PLAN_STATUS_CODE := P_CSC_CUST_PLANS_Rec.PLAN_STATUS_CODE;
    x_pvt_CSC_CUST_PLANS_rec.REQUEST_ID := P_CSC_CUST_PLANS_Rec.REQUEST_ID;
    x_pvt_CSC_CUST_PLANS_rec.PROGRAM_APPLICATION_ID := P_CSC_CUST_PLANS_Rec.PROGRAM_APPLICATION_ID;
    x_pvt_CSC_CUST_PLANS_rec.PROGRAM_ID := P_CSC_CUST_PLANS_Rec.PROGRAM_ID;
    x_pvt_CSC_CUST_PLANS_rec.PROGRAM_UPDATE_DATE := P_CSC_CUST_PLANS_Rec.PROGRAM_UPDATE_DATE;
    x_pvt_CSC_CUST_PLANS_rec.LAST_UPDATE_DATE := P_CSC_CUST_PLANS_Rec.LAST_UPDATE_DATE;
    x_pvt_CSC_CUST_PLANS_rec.CREATION_DATE := P_CSC_CUST_PLANS_Rec.CREATION_DATE;
    x_pvt_CSC_CUST_PLANS_rec.LAST_UPDATED_BY := P_CSC_CUST_PLANS_Rec.LAST_UPDATED_BY;
    x_pvt_CSC_CUST_PLANS_rec.CREATED_BY := P_CSC_CUST_PLANS_Rec.CREATED_BY;
    x_pvt_CSC_CUST_PLANS_rec.LAST_UPDATE_LOGIN := P_CSC_CUST_PLANS_Rec.LAST_UPDATE_LOGIN;
    x_pvt_CSC_CUST_PLANS_rec.ATTRIBUTE1 := P_CSC_CUST_PLANS_Rec.ATTRIBUTE1;
    x_pvt_CSC_CUST_PLANS_rec.ATTRIBUTE2 := P_CSC_CUST_PLANS_Rec.ATTRIBUTE2;
    x_pvt_CSC_CUST_PLANS_rec.ATTRIBUTE3 := P_CSC_CUST_PLANS_Rec.ATTRIBUTE3;
    x_pvt_CSC_CUST_PLANS_rec.ATTRIBUTE4 := P_CSC_CUST_PLANS_Rec.ATTRIBUTE4;
    x_pvt_CSC_CUST_PLANS_rec.ATTRIBUTE5 := P_CSC_CUST_PLANS_Rec.ATTRIBUTE5;
    x_pvt_CSC_CUST_PLANS_rec.ATTRIBUTE6 := P_CSC_CUST_PLANS_Rec.ATTRIBUTE6;
    x_pvt_CSC_CUST_PLANS_rec.ATTRIBUTE7 := P_CSC_CUST_PLANS_Rec.ATTRIBUTE7;
    x_pvt_CSC_CUST_PLANS_rec.ATTRIBUTE8 := P_CSC_CUST_PLANS_Rec.ATTRIBUTE8;
    x_pvt_CSC_CUST_PLANS_rec.ATTRIBUTE9 := P_CSC_CUST_PLANS_Rec.ATTRIBUTE9;
    x_pvt_CSC_CUST_PLANS_rec.ATTRIBUTE10 := P_CSC_CUST_PLANS_Rec.ATTRIBUTE10;
    x_pvt_CSC_CUST_PLANS_rec.ATTRIBUTE11 := P_CSC_CUST_PLANS_Rec.ATTRIBUTE11;
    x_pvt_CSC_CUST_PLANS_rec.ATTRIBUTE12 := P_CSC_CUST_PLANS_Rec.ATTRIBUTE12;
    x_pvt_CSC_CUST_PLANS_rec.ATTRIBUTE13 := P_CSC_CUST_PLANS_Rec.ATTRIBUTE13;
    x_pvt_CSC_CUST_PLANS_rec.ATTRIBUTE14 := P_CSC_CUST_PLANS_Rec.ATTRIBUTE14;
    x_pvt_CSC_CUST_PLANS_rec.ATTRIBUTE15 := P_CSC_CUST_PLANS_Rec.ATTRIBUTE15;
    x_pvt_CSC_CUST_PLANS_rec.ATTRIBUTE_CATEGORY := P_CSC_CUST_PLANS_Rec.ATTRIBUTE_CATEGORY;
    x_pvt_CSC_CUST_PLANS_rec.OBJECT_VERSION_NUMBER := P_CSC_CUST_PLANS_Rec.OBJECT_VERSION_NUMBER;

  -- If there is an error in conversion precessing, raise an error.
    IF l_any_errors
    THEN
        raise FND_API.G_EXC_ERROR;
    END IF;

END CONVERT_CSC_CUST_PLANS;

PROCEDURE CONVERT_COLUMNS_TO_REC_TYPE(
       P_ROW_ID                   IN     ROWID,
       P_PLAN_ID                  IN     NUMBER,
       P_CUST_PLAN_ID             IN     NUMBER,
       P_PARTY_ID                 IN     NUMBER,
       P_CUST_ACCOUNT_ID          IN     NUMBER,
       P_PLAN_NAME                IN     VARCHAR2,
       P_GROUP_NAME               IN     VARCHAR2,
       P_PARTY_NUMBER             IN     VARCHAR2,
       P_PARTY_NAME               IN     VARCHAR2,
       P_PARTY_TYPE               IN     VARCHAR2,
       P_ACCOUNT_NUMBER           IN     VARCHAR2,
       P_ACCOUNT_NAME             IN     VARCHAR2,
       P_START_DATE_ACTIVE        IN     DATE,
       P_END_DATE_ACTIVE          IN     DATE,
       P_CUSTOMIZED_PLAN          IN     VARCHAR2,
       P_USE_FOR_CUST_ACCOUNT     IN     VARCHAR2,
       P_PLAN_STATUS_CODE         IN     VARCHAR2,
       P_PLAN_STATUS_MEANING      IN     VARCHAR2,
       P_MANUAL_FLAG              IN     VARCHAR2,
       P_REQUEST_ID               IN     NUMBER,
       P_PROGRAM_APPLICATION_ID   IN     NUMBER,
       P_PROGRAM_ID               IN     NUMBER,
       P_PROGRAM_UPDATE_DATE      IN     DATE,
       P_CREATION_DATE            IN     DATE,
       P_LAST_UPDATE_DATE         IN     DATE,
       P_CREATED_BY               IN     NUMBER,
       P_LAST_UPDATED_BY          IN     NUMBER,
       P_USER_NAME                IN     VARCHAR2,
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
       x_csc_cust_plans_rec_type.ROW_ID := P_ROW_ID ;
       x_csc_cust_plans_rec_type.PLAN_ID := P_PLAN_ID ;
       x_csc_cust_plans_rec_type.CUST_PLAN_ID := P_CUST_PLAN_ID ;
       x_csc_cust_plans_rec_type.PARTY_ID := P_PARTY_ID ;
       x_csc_cust_plans_rec_type.CUST_ACCOUNT_ID := P_CUST_ACCOUNT_ID ;
       --x_csc_cust_plans_rec_type.CUST_ACCOUNT_ORG  := P_CUST_ACCOUNT_ORG  ;
       x_csc_cust_plans_rec_type.PLAN_NAME := P_PLAN_NAME ;
       x_csc_cust_plans_rec_type.GROUP_NAME := P_GROUP_NAME ;
       x_csc_cust_plans_rec_type.PARTY_NUMBER := P_PARTY_NUMBER ;
       x_csc_cust_plans_rec_type.PARTY_NAME := P_PARTY_NAME ;
       x_csc_cust_plans_rec_type.PARTY_TYPE := P_PARTY_TYPE ;
       x_csc_cust_plans_rec_type.ACCOUNT_NUMBER := P_ACCOUNT_NUMBER ;
       x_csc_cust_plans_rec_type.ACCOUNT_NAME := P_ACCOUNT_NAME ;
       --x_csc_cust_plans_rec_type.PRIORITY := P_PRIORITY ;
       x_csc_cust_plans_rec_type.START_DATE_ACTIVE := P_START_DATE_ACTIVE ;
       x_csc_cust_plans_rec_type.END_DATE_ACTIVE := P_END_DATE_ACTIVE ;
       x_csc_cust_plans_rec_type.CUSTOMIZED_PLAN := P_CUSTOMIZED_PLAN ;
       x_csc_cust_plans_rec_type.USE_FOR_CUST_ACCOUNT := P_USE_FOR_CUST_ACCOUNT ;
       x_csc_cust_plans_rec_type.PLAN_STATUS_CODE := P_PLAN_STATUS_CODE ;
       x_csc_cust_plans_rec_type.PLAN_STATUS_MEANING := P_PLAN_STATUS_MEANING ;
       x_csc_cust_plans_rec_type.MANUAL_FLAG := P_MANUAL_FLAG ;
       x_csc_cust_plans_rec_type.REQUEST_ID := P_REQUEST_ID ;
       x_csc_cust_plans_rec_type.PROGRAM_APPLICATION_ID := P_PROGRAM_APPLICATION_ID ;
       x_csc_cust_plans_rec_type.PROGRAM_ID := P_PROGRAM_ID ;
       x_csc_cust_plans_rec_type.PROGRAM_UPDATE_DATE := P_PROGRAM_UPDATE_DATE ;
       x_csc_cust_plans_rec_type.CREATION_DATE := P_CREATION_DATE ;
       x_csc_cust_plans_rec_type.LAST_UPDATE_DATE := P_LAST_UPDATE_DATE ;
       x_csc_cust_plans_rec_type.CREATED_BY := P_CREATED_BY ;
       x_csc_cust_plans_rec_type.LAST_UPDATED_BY := P_LAST_UPDATED_BY ;
       x_csc_cust_plans_rec_type.USER_NAME := P_USER_NAME ;
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
    P_ROW_ID                     IN   ROWID,
    P_PLAN_ID                    IN   NUMBER,
    P_CUST_PLAN_ID               IN   NUMBER,
    P_PARTY_ID                   IN   NUMBER,
    P_CUST_ACCOUNT_ID            IN   NUMBER,
    P_PLAN_NAME                  IN   VARCHAR2,
    P_GROUP_NAME                 IN   VARCHAR2,
    P_PARTY_NUMBER               IN   VARCHAR2,
    P_PARTY_NAME                 IN   VARCHAR2,
    P_PARTY_TYPE                 IN   VARCHAR2,
    P_ACCOUNT_NUMBER             IN   VARCHAR2,
    P_ACCOUNT_NAME               IN   VARCHAR2,
    --P_PRIORITY                   IN   NUMBER,
    P_START_DATE_ACTIVE          IN   DATE,
    P_END_DATE_ACTIVE            IN   DATE,
    P_CUSTOMIZED_PLAN            IN   VARCHAR2,
    P_USE_FOR_CUST_ACCOUNT       IN   VARCHAR2,
    P_PLAN_STATUS_CODE           IN   VARCHAR2,
    P_PLAN_STATUS_MEANING        IN   VARCHAR2,
    P_MANUAL_FLAG                IN   VARCHAR2,
    P_REQUEST_ID                 IN   NUMBER,
    P_PROGRAM_APPLICATION_ID     IN   NUMBER,
    P_PROGRAM_ID                 IN   NUMBER,
    P_PROGRAM_UPDATE_DATE        IN   DATE,
    P_CREATION_DATE              IN   DATE,
    P_LAST_UPDATE_DATE           IN   DATE,
    P_CREATED_BY                 IN   NUMBER,
    P_LAST_UPDATED_BY            IN   NUMBER,
    P_USER_NAME                  IN   VARCHAR2,
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
       P_ROW_ID                    => P_ROW_ID ,
       P_PLAN_ID                   => P_PLAN_ID ,
       P_CUST_PLAN_ID              => P_CUST_PLAN_ID ,
       P_PARTY_ID                  => P_PARTY_ID ,
       P_CUST_ACCOUNT_ID           => P_CUST_ACCOUNT_ID ,
       --P_CUST_ACCOUNT_ORG          => P_CUST_ACCOUNT_ORG ,
       P_PLAN_NAME                 => P_PLAN_NAME ,
       P_GROUP_NAME                => P_GROUP_NAME ,
       P_PARTY_NUMBER              => P_PARTY_NUMBER ,
       P_PARTY_NAME                => P_PARTY_NAME ,
       P_PARTY_TYPE                => P_PARTY_TYPE ,
       P_ACCOUNT_NUMBER            => P_ACCOUNT_NUMBER ,
       P_ACCOUNT_NAME              => P_ACCOUNT_NAME ,
       --P_PRIORITY                  => P_PRIORITY ,
       P_START_DATE_ACTIVE         => P_START_DATE_ACTIVE ,
       P_END_DATE_ACTIVE           => P_END_DATE_ACTIVE ,
       P_CUSTOMIZED_PLAN           => P_CUSTOMIZED_PLAN ,
       P_USE_FOR_CUST_ACCOUNT      => P_USE_FOR_CUST_ACCOUNT ,
       P_PLAN_STATUS_CODE          => P_PLAN_STATUS_CODE ,
       P_PLAN_STATUS_MEANING       => P_PLAN_STATUS_MEANING ,
       P_MANUAL_FLAG               => P_MANUAL_FLAG ,
       P_REQUEST_ID                => P_REQUEST_ID ,
       P_PROGRAM_APPLICATION_ID    => P_PROGRAM_APPLICATION_ID ,
       P_PROGRAM_ID                => P_PROGRAM_ID ,
       P_PROGRAM_UPDATE_DATE       => P_PROGRAM_UPDATE_DATE ,
       P_CREATION_DATE             => P_CREATION_DATE ,
       P_LAST_UPDATE_DATE          => P_LAST_UPDATE_DATE ,
       P_CREATED_BY                => P_CREATED_BY ,
       P_LAST_UPDATED_BY           => P_LAST_UPDATED_BY ,
       P_USER_NAME                 => P_USER_NAME ,
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
       P_CSC_CUST_PLANS_Rec         => l_csc_cust_plans_rec,
       X_CUST_PLAN_ID               => x_cust_plan_id,
       X_OBJECT_VERSION_NUMBER      => x_object_version_number,
       X_Return_Status              => x_return_status,
       X_Msg_Count                  => x_msg_count,
       X_Msg_Data                   => x_msg_data );

END   CREATE_CUST_PLANS;



PROCEDURE Create_cust_plans(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_CSC_CUST_PLANS_Rec         IN   CSC_CUST_PLANS_Rec_Type,
    X_CUST_PLAN_ID               OUT  NOCOPY NUMBER,
    X_OBJECT_VERSION_NUMBER      OUT  NOCOPY NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    )
IS
   l_api_name                  CONSTANT VARCHAR2(30) := 'Create_cust_plans';
   l_api_version_number        CONSTANT NUMBER       := 1.0;
   l_pvt_CSC_CUST_PLANS_rec    CSC_CUST_PLANS_PVT.CSC_CUST_PLANS_Rec_Type;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_CUST_PLANS_PUB;

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

      -- Convert the values to ids
      --
      CONVERT_CSC_CUST_PLANS (
            p_CSC_CUST_PLANS_rec       =>  p_CSC_CUST_PLANS_rec,
            x_pvt_CSC_CUST_PLANS_rec   =>  l_pvt_CSC_CUST_PLANS_rec );

    -- Calling Private package: Create_CUST_PLANS
    -- Hint: Primary key needs to be returned

      CSC_cust_plans_PVT.Create_cust_plans(
         P_Api_Version_Number         => 1.0,
         P_Init_Msg_List              => FND_API.G_FALSE,
         P_Commit                     => FND_API.G_FALSE,
         P_Validation_Level           => FND_API.G_VALID_LEVEL_FULL,
         P_CSC_CUST_PLANS_Rec         => l_pvt_CSC_CUST_PLANS_Rec ,
         X_CUST_PLAN_ID               => x_CUST_PLAN_ID,
         X_OBJECT_VERSION_NUMBER      => x_object_version_number,
         X_Return_Status              => x_return_status,
         X_Msg_Count                  => x_msg_count,
         X_Msg_Data                   => x_msg_data);

      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data  );

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
      --APP_EXCEPTION.RAISE_EXCEPTION;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      CSC_CORE_UTILS_PVT.HANDLE_EXCEPTIONS(
            P_API_NAME        => L_API_NAME,
            P_PKG_NAME        => G_PKG_NAME,
            P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,
            P_PACKAGE_TYPE    => CSC_CORE_UTILS_PVT.G_PVT,
            X_MSG_COUNT       => X_MSG_COUNT,
            X_MSG_DATA        => X_MSG_DATA,
            X_RETURN_STATUS   => X_RETURN_STATUS);
      --APP_EXCEPTION.RAISE_EXCEPTION;

   WHEN OTHERS THEN
      CSC_CORE_UTILS_PVT.HANDLE_EXCEPTIONS(
            P_API_NAME        => L_API_NAME,
            P_PKG_NAME        => G_PKG_NAME,
            P_EXCEPTION_LEVEL => CSC_CORE_UTILS_PVT.G_MSG_LVL_OTHERS,
            P_PACKAGE_TYPE    => CSC_CORE_UTILS_PVT.G_PVT,
            X_MSG_COUNT       => X_MSG_COUNT,
            X_MSG_DATA        => X_MSG_DATA,
            X_RETURN_STATUS   => X_RETURN_STATUS);
      --APP_EXCEPTION.RAISE_EXCEPTION;

End Create_cust_plans;

/*** Overloaded proc. that accepts a detailed parameter list, converts the list
     into a record type parameter and calls the create procedure that accepts
     a record type IN parameter  ***/

PROCEDURE Update_cust_plans(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_ROW_ID                     IN   ROWID,
    P_PLAN_ID                    IN   NUMBER,
    P_CUST_PLAN_ID               IN   NUMBER,
    P_PARTY_ID                   IN   NUMBER,
    P_CUST_ACCOUNT_ID            IN   NUMBER,
    P_PLAN_NAME                  IN   VARCHAR2,
    P_GROUP_NAME                 IN   VARCHAR2,
    P_PARTY_NUMBER               IN   VARCHAR2,
    P_PARTY_NAME                 IN   VARCHAR2,
    P_PARTY_TYPE                 IN   VARCHAR2,
    P_ACCOUNT_NUMBER             IN   VARCHAR2,
    P_ACCOUNT_NAME               IN   VARCHAR2,
    P_START_DATE_ACTIVE          IN   DATE,
    P_END_DATE_ACTIVE            IN   DATE,
    P_CUSTOMIZED_PLAN            IN   VARCHAR2,
    P_USE_FOR_CUST_ACCOUNT       IN   VARCHAR2,
    P_PLAN_STATUS_CODE           IN   VARCHAR2,
    P_PLAN_STATUS_MEANING        IN   VARCHAR2,
    P_MANUAL_FLAG                IN   VARCHAR2,
    P_REQUEST_ID                 IN   NUMBER,
    P_PROGRAM_APPLICATION_ID     IN   NUMBER,
    P_PROGRAM_ID                 IN   NUMBER,
    P_PROGRAM_UPDATE_DATE        IN   DATE,
    P_CREATION_DATE              IN   DATE,
    P_LAST_UPDATE_DATE           IN   DATE,
    P_CREATED_BY                 IN   NUMBER,
    P_LAST_UPDATED_BY            IN   NUMBER,
    P_USER_NAME                  IN   VARCHAR2,
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
       P_ROW_ID                    => P_ROW_ID ,
       P_PLAN_ID                   => P_PLAN_ID ,
       P_CUST_PLAN_ID              => P_CUST_PLAN_ID ,
       P_PARTY_ID                  => P_PARTY_ID ,
       P_CUST_ACCOUNT_ID           => P_CUST_ACCOUNT_ID ,
       --P_CUST_ACCOUNT_ORG          => P_CUST_ACCOUNT_ORG ,
       P_PLAN_NAME                 => P_PLAN_NAME ,
       P_GROUP_NAME                => P_GROUP_NAME ,
       P_PARTY_NUMBER              => P_PARTY_NUMBER ,
       P_PARTY_NAME                => P_PARTY_NAME ,
       P_PARTY_TYPE                => P_PARTY_TYPE ,
       P_ACCOUNT_NUMBER            => P_ACCOUNT_NUMBER ,
       P_ACCOUNT_NAME              => P_ACCOUNT_NAME ,
       --P_PRIORITY                  => P_PRIORITY ,
       P_START_DATE_ACTIVE         => P_START_DATE_ACTIVE ,
       P_END_DATE_ACTIVE           => P_END_DATE_ACTIVE ,
       P_CUSTOMIZED_PLAN           => P_CUSTOMIZED_PLAN ,
       P_USE_FOR_CUST_ACCOUNT      => P_USE_FOR_CUST_ACCOUNT ,
       P_PLAN_STATUS_CODE          => P_PLAN_STATUS_CODE ,
       P_PLAN_STATUS_MEANING       => P_PLAN_STATUS_MEANING ,
       P_MANUAL_FLAG               => P_MANUAL_FLAG ,
       P_REQUEST_ID                => P_REQUEST_ID ,
       P_PROGRAM_APPLICATION_ID    => P_PROGRAM_APPLICATION_ID ,
       P_PROGRAM_ID                => P_PROGRAM_ID ,
       P_PROGRAM_UPDATE_DATE       => P_PROGRAM_UPDATE_DATE ,
       P_CREATION_DATE             => P_CREATION_DATE ,
       P_LAST_UPDATE_DATE          => P_LAST_UPDATE_DATE ,
       P_CREATED_BY                => P_CREATED_BY ,
       P_LAST_UPDATED_BY           => P_LAST_UPDATED_BY ,
       P_USER_NAME                 => P_USER_NAME ,
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
    P_CSC_CUST_PLANS_Rec         IN   CSC_CUST_PLANS_Rec_Type,
    X_OBJECT_VERSION_NUMBER      OUT  NOCOPY NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    )
IS
   l_api_name                CONSTANT VARCHAR2(30) := 'Update_cust_plans';
   l_api_version_number      CONSTANT NUMBER       := 1.0;
   l_pvt_CSC_CUST_PLANS_rec  CSC_CUST_PLANS_PVT.CSC_CUST_PLANS_Rec_Type;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_CUST_PLANS_PUB;

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

      -- Convert the values to ids
      --
      CONVERT_CSC_CUST_PLANS (
            p_CSC_CUST_PLANS_rec       =>  p_CSC_CUST_PLANS_rec,
            x_pvt_CSC_CUST_PLANS_rec   =>  l_pvt_CSC_CUST_PLANS_rec );

    CSC_cust_plans_PVT.Update_cust_plans(
       P_Api_Version_Number         => 1.0,
       P_Init_Msg_List              => FND_API.G_FALSE,
       P_Commit                     => p_commit,
       P_Validation_Level           => FND_API.G_VALID_LEVEL_FULL,
       P_CSC_CUST_PLANS_Rec         => l_pvt_CSC_CUST_PLANS_Rec ,
       X_OBJECT_VERSION_NUMBER      => x_object_version_number,
       X_Return_Status              => x_return_status,
       X_Msg_Count                  => x_msg_count,
       X_Msg_Data                   => x_msg_data);

      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

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
      --APP_EXCEPTION.RAISE_EXCEPTION;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      CSC_CORE_UTILS_PVT.HANDLE_EXCEPTIONS(
            P_API_NAME        => L_API_NAME,
            P_PKG_NAME        => G_PKG_NAME,
            P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,
            P_PACKAGE_TYPE    => CSC_CORE_UTILS_PVT.G_PVT,
            X_MSG_COUNT       => X_MSG_COUNT,
            X_MSG_DATA        => X_MSG_DATA,
            X_RETURN_STATUS   => X_RETURN_STATUS);
      --APP_EXCEPTION.RAISE_EXCEPTION;

   WHEN OTHERS THEN
      CSC_CORE_UTILS_PVT.HANDLE_EXCEPTIONS(
            P_API_NAME        => L_API_NAME,
            P_PKG_NAME        => G_PKG_NAME,
            P_EXCEPTION_LEVEL => CSC_CORE_UTILS_PVT.G_MSG_LVL_OTHERS,
            P_PACKAGE_TYPE    => CSC_CORE_UTILS_PVT.G_PVT,
            X_MSG_COUNT       => X_MSG_COUNT,
            X_MSG_DATA        => X_MSG_DATA,
            X_RETURN_STATUS   => X_RETURN_STATUS);
      --APP_EXCEPTION.RAISE_EXCEPTION;

End Update_cust_plans;

PROCEDURE ENABLE_PLAN (
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_plan_id                    IN   NUMBER,
    p_party_id_tbl               IN   CSC_PARTY_ID_TBL_TYPE,
    p_plan_status_code           IN   VARCHAR2,
    X_OBJECT_VERSION_NUMBER      OUT  NOCOPY NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
   )
IS
   l_csc_cust_plans_rec        CSC_CUST_PLANS_PVT.CSC_CUST_PLANS_REC_TYPE;
   l_api_name                  CONSTANT VARCHAR2(30) := 'Enable_Plan';
   l_api_version_number        CONSTANT NUMBER       := 1.0;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT ENABLE_PLAN_PUB;

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

      l_csc_cust_plans_rec.plan_status_code := p_plan_status_code;
      l_csc_cust_plans_rec.plan_id          := p_plan_id;
      l_csc_cust_plans_rec.object_version_number := 1;
      l_csc_cust_plans_rec.cust_plan_id     := NULL;
      l_csc_cust_plans_rec.party_id         := NULL;
      l_csc_cust_plans_rec.cust_account_id  := NULL;
      --l_csc_cust_plans_rec.cust_account_org := NULL;

      csc_cust_plans_pvt.update_cust_plans(
         P_Api_Version_Number         =>  p_api_version_number,
         P_Init_Msg_List              =>  p_init_msg_list,
         P_Commit                     =>  p_commit,
	    p_validation_level           =>  FND_API.G_VALID_LEVEL_NONE,
         P_CSC_CUST_PLANS_Rec         =>  l_csc_cust_plans_rec,
         X_OBJECT_VERSION_NUMBER      =>  x_object_version_number,
         X_Return_Status              =>  x_return_status,
         X_Msg_Count                  =>  x_msg_count,
         X_Msg_Data                   =>  x_msg_data );

      if ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) then
	    APP_EXCEPTION.RAISE_EXCEPTION;
      end if;

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
    X_OBJECT_VERSION_NUMBER      OUT  NOCOPY NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
   )
IS
   l_csc_cust_plans_rec        CSC_CUST_PLANS_PVT.CSC_CUST_PLANS_REC_TYPE;
   l_api_name                  CONSTANT VARCHAR2(30) := 'Disable_Plan';
   l_api_version_number        CONSTANT NUMBER       := 1.0;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DISABLE_PLAN_PUB;

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

      l_csc_cust_plans_rec.plan_status_code := p_plan_status_code;
      l_csc_cust_plans_rec.plan_id          := p_plan_id;
      l_csc_cust_plans_rec.object_version_number          := 1;

      csc_cust_plans_pvt.update_cust_plans(
         P_Api_Version_Number         =>  p_api_version_number,
         P_Init_Msg_List              =>  p_init_msg_list,
         P_Commit                     =>  p_commit,
	    p_validation_level           =>  FND_API.G_VALID_LEVEL_NONE,
         P_CSC_CUST_PLANS_Rec         =>  l_csc_cust_plans_rec,
         X_OBJECT_VERSION_NUMBER      =>  x_object_version_number,
         X_Return_Status              =>  x_return_status,
         X_Msg_Count                  =>  x_msg_count,
         X_Msg_Data                   =>  x_msg_data );

      if ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) then
	    APP_EXCEPTION.RAISE_EXCEPTION;
      end if;

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

PROCEDURE Delete_cust_plans(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_CUST_PLAN_ID               IN   NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    )
IS
   l_api_name                CONSTANT VARCHAR2(30) := 'Delete_cust_plans';
   l_api_version_number      CONSTANT NUMBER       := 1.0;
   l_pvt_CSC_CUST_PLANS_rec  CSC_CUST_PLANS_PVT.CSC_CUST_PLANS_Rec_Type;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_CUST_PLANS_PUB;

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

      CSC_CUST_PLANS_PKG.Delete_Row(
                       P_CUST_PLAN_ID       => P_CUST_PLAN_ID);

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
      --APP_EXCEPTION.RAISE_EXCEPTION;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      CSC_CORE_UTILS_PVT.HANDLE_EXCEPTIONS(
            P_API_NAME        => L_API_NAME,
            P_PKG_NAME        => G_PKG_NAME,
            P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,
            P_PACKAGE_TYPE    => CSC_CORE_UTILS_PVT.G_PVT,
            X_MSG_COUNT       => X_MSG_COUNT,
            X_MSG_DATA        => X_MSG_DATA,
            X_RETURN_STATUS   => X_RETURN_STATUS);
      --APP_EXCEPTION.RAISE_EXCEPTION;

   WHEN OTHERS THEN
      CSC_CORE_UTILS_PVT.HANDLE_EXCEPTIONS(
            P_API_NAME        => L_API_NAME,
            P_PKG_NAME        => G_PKG_NAME,
            P_EXCEPTION_LEVEL => CSC_CORE_UTILS_PVT.G_MSG_LVL_OTHERS,
            P_PACKAGE_TYPE    => CSC_CORE_UTILS_PVT.G_PVT,
            X_MSG_COUNT       => X_MSG_COUNT,
            X_MSG_DATA        => X_MSG_DATA,
            X_RETURN_STATUS   => X_RETURN_STATUS);
      --APP_EXCEPTION.RAISE_EXCEPTION;

End Delete_cust_plans;

End CSC_CUST_PLANS_PUB;

/
