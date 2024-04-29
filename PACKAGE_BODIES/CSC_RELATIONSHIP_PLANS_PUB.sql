--------------------------------------------------------
--  DDL for Package Body CSC_RELATIONSHIP_PLANS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSC_RELATIONSHIP_PLANS_PUB" as
/* $Header: cscprlpb.pls 115.15 2002/11/28 04:25:58 bhroy ship $ */
-- Start of Comments
-- Package name     : CSC_RELATIONSHIP_PLANS_PUB
-- Purpose          : This package body contains all procedures and functions that are required
--                    to create and modify plan headers and disable plans.
-- History
-- MM-DD-YYYY   NAME           MODIFICATIONS
-- 10-08-1999   dejoseph       Created.
-- 12-08-1999    dejoseph      'Arcs'ed in for first code freeze.
-- 12-21-1999    dejoseph      'Arcs'ed in for second code freeze.
-- 01-03-2000    dejoseph      'Arcs'ed in for third code freeze. (10-JAN-2000)
-- 01-31-2000    dejoseph      'Arcs'ed in for fourth code freeze. (07-FEB-2000)
-- 02-13-2000    dejoseph      'Arcs'ed on for fifth code freeze. (21-FEB-2000)
-- 02-28-2000    dejoseph      'Arcs'ed on for sixth code freeze. (06-MAR-2000)
-- 04-10-2000    dejoseph      Removed reference to cust_account_org in lieu of TCA's
--                             decision to drop column org_id from hz_cust_accounts.
-- 02-18-2002    dejoseph      Added changes to uptake new functionality for 11.5.8.
--                             Ct. / Agent facing application
--                             - Added new IN parameter END_USER_TYPE to procedures:
--                                 convert_columns_to_rec_type
--                                 create_plan_header
--                                 update_plan_header
--                             Added the dbdrv command.
-- 05-23-2002    dejoseph      Added checkfile syntax.
-- 11-12-2002	 bhroy		NOCOPY changes made
-- 11-27-2002	 bhroy		All the default values have been removed, added WHENEVER OSERROR EXIT FAILURE ROLLBACK
--
-- End of Comments

G_PKG_NAME  CONSTANT VARCHAR2(30) := 'CSC_RELATIONSHIP_PLANS_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'cscprlpb.pls';

   -- Start of Comments
   -- ***************** Private Conversion Routines Values -> Ids **************
   -- Purpose
   --
   -- This procedure takes a public CSC_RELATIONSHIP_PLANS record as input. It may contain
   -- values or ids. All values are then converted into ids and a
   -- private CSC_RELATIONSHIP_PLANS record is returned for the private
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

PROCEDURE CONVERT_CSC_PLAN_HEADERS_B(
         P_CSC_PLAN_HEADERS_B_REC        IN    CSC_relationship_plans_PUB.CSC_PLAN_HEADERS_B_REC_TYPE,
	    P_PARTY_ID_TBL                  IN    CSC_CUST_PLANS_PVT.CSC_PARTY_ID_TBL_TYPE,
         x_pvt_CSC_PLAN_HEADERS_B_REC    OUT NOCOPY   CSC_relationship_plans_PVT.CSC_PLAN_HEADERS_B_REC_TYPE,
	    x_pvt_CSC_PARTY_ID_TBL          OUT NOCOPY   CSC_CUST_PLANS_PVT.CSC_PARTY_ID_TBL_TYPE
)
IS

   CURSOR C_Get_Lookup_Code(X_Lookup_Type VARCHAR2, X_Meaning VARCHAR2) IS
      SELECT lookup_code
      FROM   fnd_lookup_values
      WHERE  lookup_type        = X_Lookup_Type
      AND    nls_upper(meaning) = nls_upper(X_Meaning);

   l_any_errors       BOOLEAN   := FALSE;
BEGIN
   -- As of now there are no columns that need to be changed to ids.Just convert the public
   -- rec type into a pvt. rec type. If in future there is a need to convert a column value
   -- into an id, put in the logic to do so in this proc. DJ

   if ( p_party_id_tbl.count > 0 ) then
      for i in 1..p_party_id_tbl.count
      loop
	    x_pvt_csc_party_id_tbl(i).party_id         := p_party_id_tbl(i).party_id;
	    x_pvt_csc_party_id_tbl(i).cust_account_id  := p_party_id_tbl(i).cust_account_id;
      end loop;
   end if;

   x_pvt_CSC_PLAN_HEADERS_B_REC.PLAN_ID              := P_CSC_PLAN_HEADERS_B_REC.PLAN_ID;
   x_pvt_CSC_PLAN_HEADERS_B_REC.ORIGINAL_PLAN_ID     := P_CSC_PLAN_HEADERS_B_REC.ORIGINAL_PLAN_ID;
   x_pvt_CSC_PLAN_HEADERS_B_REC.PLAN_GROUP_CODE      := P_CSC_PLAN_HEADERS_B_REC.PLAN_GROUP_CODE;
   x_pvt_CSC_PLAN_HEADERS_B_REC.START_DATE_ACTIVE    := P_CSC_PLAN_HEADERS_B_REC.START_DATE_ACTIVE;
   x_pvt_CSC_PLAN_HEADERS_B_REC.END_DATE_ACTIVE      := P_CSC_PLAN_HEADERS_B_REC.END_DATE_ACTIVE;
   x_pvt_CSC_PLAN_HEADERS_B_REC.USE_FOR_CUST_ACCOUNT := P_CSC_PLAN_HEADERS_B_REC.USE_FOR_CUST_ACCOUNT;
   x_pvt_CSC_PLAN_HEADERS_B_REC.END_USER_TYPE        := P_CSC_PLAN_HEADERS_B_REC.END_USER_TYPE;
   x_pvt_CSC_PLAN_HEADERS_B_REC.CUSTOMIZED_PLAN      := P_CSC_PLAN_HEADERS_B_REC.CUSTOMIZED_PLAN;
   x_pvt_CSC_PLAN_HEADERS_B_REC.PROFILE_CHECK_ID     := P_CSC_PLAN_HEADERS_B_REC.PROFILE_CHECK_ID;
   x_pvt_CSC_PLAN_HEADERS_B_REC.RELATIONAL_OPERATOR  := P_CSC_PLAN_HEADERS_B_REC.RELATIONAL_OPERATOR;
   x_pvt_CSC_PLAN_HEADERS_B_REC.CRITERIA_VALUE_HIGH  := P_CSC_PLAN_HEADERS_B_REC.CRITERIA_VALUE_HIGH;
   x_pvt_CSC_PLAN_HEADERS_B_REC.CRITERIA_VALUE_LOW   := P_CSC_PLAN_HEADERS_B_REC.CRITERIA_VALUE_LOW;
   x_pvt_CSC_PLAN_HEADERS_B_REC.CREATION_DATE        := P_CSC_PLAN_HEADERS_B_REC.CREATION_DATE;
   x_pvt_CSC_PLAN_HEADERS_B_REC.LAST_UPDATE_DATE     := P_CSC_PLAN_HEADERS_B_REC.LAST_UPDATE_DATE;
   x_pvt_CSC_PLAN_HEADERS_B_REC.CREATED_BY           := P_CSC_PLAN_HEADERS_B_REC.CREATED_BY;
   x_pvt_CSC_PLAN_HEADERS_B_REC.LAST_UPDATED_BY      := P_CSC_PLAN_HEADERS_B_REC.LAST_UPDATED_BY;
   x_pvt_CSC_PLAN_HEADERS_B_REC.LAST_UPDATE_LOGIN    := P_CSC_PLAN_HEADERS_B_REC.LAST_UPDATE_LOGIN;
   x_pvt_CSC_PLAN_HEADERS_B_REC.ATTRIBUTE1           := P_CSC_PLAN_HEADERS_B_REC.ATTRIBUTE1;
   x_pvt_CSC_PLAN_HEADERS_B_REC.ATTRIBUTE2           := P_CSC_PLAN_HEADERS_B_REC.ATTRIBUTE2;
   x_pvt_CSC_PLAN_HEADERS_B_REC.ATTRIBUTE3           := P_CSC_PLAN_HEADERS_B_REC.ATTRIBUTE3;
   x_pvt_CSC_PLAN_HEADERS_B_REC.ATTRIBUTE4           := P_CSC_PLAN_HEADERS_B_REC.ATTRIBUTE4;
   x_pvt_CSC_PLAN_HEADERS_B_REC.ATTRIBUTE5           := P_CSC_PLAN_HEADERS_B_REC.ATTRIBUTE5;
   x_pvt_CSC_PLAN_HEADERS_B_REC.ATTRIBUTE6           := P_CSC_PLAN_HEADERS_B_REC.ATTRIBUTE6;
   x_pvt_CSC_PLAN_HEADERS_B_REC.ATTRIBUTE7           := P_CSC_PLAN_HEADERS_B_REC.ATTRIBUTE7;
   x_pvt_CSC_PLAN_HEADERS_B_REC.ATTRIBUTE8           := P_CSC_PLAN_HEADERS_B_REC.ATTRIBUTE8;
   x_pvt_CSC_PLAN_HEADERS_B_REC.ATTRIBUTE9           := P_CSC_PLAN_HEADERS_B_REC.ATTRIBUTE9;
   x_pvt_CSC_PLAN_HEADERS_B_REC.ATTRIBUTE10          := P_CSC_PLAN_HEADERS_B_REC.ATTRIBUTE10;
   x_pvt_CSC_PLAN_HEADERS_B_REC.ATTRIBUTE11          := P_CSC_PLAN_HEADERS_B_REC.ATTRIBUTE11;
   x_pvt_CSC_PLAN_HEADERS_B_REC.ATTRIBUTE12          := P_CSC_PLAN_HEADERS_B_REC.ATTRIBUTE12;
   x_pvt_CSC_PLAN_HEADERS_B_REC.ATTRIBUTE13          := P_CSC_PLAN_HEADERS_B_REC.ATTRIBUTE13;
   x_pvt_CSC_PLAN_HEADERS_B_REC.ATTRIBUTE14          := P_CSC_PLAN_HEADERS_B_REC.ATTRIBUTE14;
   x_pvt_CSC_PLAN_HEADERS_B_REC.ATTRIBUTE15          := P_CSC_PLAN_HEADERS_B_REC.ATTRIBUTE15;
   x_pvt_CSC_PLAN_HEADERS_B_REC.ATTRIBUTE_CATEGORY   := P_CSC_PLAN_HEADERS_B_REC.ATTRIBUTE_CATEGORY;
   x_pvt_CSC_PLAN_HEADERS_B_REC.OBJECT_VERSION_NUMBER:= P_CSC_PLAN_HEADERS_B_REC.OBJECT_VERSION_NUMBER;

END CONVERT_CSC_PLAN_HEADERS_B;


/*** PROCEDURE THAT CONVERTS INDIVIDUAL COLUMN PARAMETERS INTO RECORD TYPE FOR
     PROCEDURE OVERLOADING   ***/

PROCEDURE convert_columns_to_rec_type(
    P_ROW_ID                     IN   ROWID ,
    P_PLAN_ID                    IN   NUMBER,
    P_ORIGINAL_PLAN_ID           IN   NUMBER,
    P_PLAN_GROUP_CODE            IN   VARCHAR2,
    P_START_DATE_ACTIVE          IN   DATE ,
    P_END_DATE_ACTIVE            IN   DATE,
    P_USE_FOR_CUST_ACCOUNT       IN   VARCHAR2,
    P_END_USER_TYPE              IN   VARCHAR2,
    P_CUSTOMIZED_PLAN            IN   VARCHAR2,
    P_PROFILE_CHECK_ID           IN   NUMBER ,
    P_RELATIONAL_OPERATOR        IN   VARCHAR2,
    P_CRITERIA_VALUE_HIGH        IN   VARCHAR2,
    P_CRITERIA_VALUE_LOW         IN   VARCHAR2,
    P_CREATION_DATE              IN   DATE ,
    P_LAST_UPDATE_DATE           IN   DATE,
    P_CREATED_BY                 IN   NUMBER,
    P_LAST_UPDATED_BY            IN   NUMBER,
    P_LAST_UPDATE_LOGIN          IN   NUMBER,
    P_ATTRIBUTE1                 IN   VARCHAR2 ,
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
    P_OBJECT_VERSION_NUMBER      IN   NUMBER ,
    X_PUB_CSC_PLAN_HEADERS_B_REC OUT NOCOPY  CSC_PLAN_HEADERS_B_REC_TYPE )
IS

BEGIN
   x_pub_csc_plan_headers_b_rec.ROW_ID               := p_row_id;
   x_pub_csc_plan_headers_b_rec.PLAN_ID              := p_plan_id;
   x_pub_csc_plan_headers_b_rec.ORIGINAL_PLAN_ID     := p_original_plan_id;
   x_pub_csc_plan_headers_b_rec.PLAN_GROUP_CODE      := p_plan_group_code;
   x_pub_csc_plan_headers_b_rec.START_DATE_ACTIVE    := p_start_date_active;
   x_pub_csc_plan_headers_b_rec.END_DATE_ACTIVE      := p_end_date_active;
   x_pub_csc_plan_headers_b_rec.USE_FOR_CUST_ACCOUNT := p_use_for_cust_account;
   x_pub_csc_plan_headers_b_rec.END_USER_TYPE        := p_end_user_type;
   x_pub_csc_plan_headers_b_rec.CUSTOMIZED_PLAN      := p_customized_plan;
   x_pub_csc_plan_headers_b_rec.PROFILE_CHECK_ID     := p_profile_check_id;
   x_pub_csc_plan_headers_b_rec.RELATIONAL_OPERATOR  := p_relational_operator;
   x_pub_csc_plan_headers_b_rec.CRITERIA_VALUE_HIGH  := p_criteria_value_high;
   x_pub_csc_plan_headers_b_rec.CRITERIA_VALUE_LOW   := p_criteria_value_low;
   x_pub_csc_plan_headers_b_rec.CREATION_DATE        := p_creation_date;
   x_pub_csc_plan_headers_b_rec.LAST_UPDATE_DATE     := p_last_update_date;
   x_pub_csc_plan_headers_b_rec.CREATED_BY           := p_created_by;
   x_pub_csc_plan_headers_b_rec.LAST_UPDATED_BY      := p_last_updated_by;
   x_pub_csc_plan_headers_b_rec.LAST_UPDATE_LOGIN    := p_last_update_login;
   x_pub_csc_plan_headers_b_rec.ATTRIBUTE1           := p_attribute1;
   x_pub_csc_plan_headers_b_rec.ATTRIBUTE2           := p_attribute2;
   x_pub_csc_plan_headers_b_rec.ATTRIBUTE3           := p_attribute3;
   x_pub_csc_plan_headers_b_rec.ATTRIBUTE4           := p_attribute4;
   x_pub_csc_plan_headers_b_rec.ATTRIBUTE5           := p_attribute5;
   x_pub_csc_plan_headers_b_rec.ATTRIBUTE6           := p_attribute6;
   x_pub_csc_plan_headers_b_rec.ATTRIBUTE7           := p_attribute7;
   x_pub_csc_plan_headers_b_rec.ATTRIBUTE8           := p_attribute8;
   x_pub_csc_plan_headers_b_rec.ATTRIBUTE9           := p_attribute9;
   x_pub_csc_plan_headers_b_rec.ATTRIBUTE10          := p_attribute10;
   x_pub_csc_plan_headers_b_rec.ATTRIBUTE11          := p_attribute11;
   x_pub_csc_plan_headers_b_rec.ATTRIBUTE12          := p_attribute12;
   x_pub_csc_plan_headers_b_rec.ATTRIBUTE13          := p_attribute13;
   x_pub_csc_plan_headers_b_rec.ATTRIBUTE14          := p_attribute14;
   x_pub_csc_plan_headers_b_rec.ATTRIBUTE15          := p_attribute15;
   x_pub_csc_plan_headers_b_rec.ATTRIBUTE_CATEGORY   := p_attribute_category;
   x_pub_csc_plan_headers_b_rec.OBJECT_VERSION_NUMBER:= p_object_version_number;

END convert_columns_to_rec_type;



/*********** OVERLOADED PROCEDURE TO TAKE COLUMNS INSTEAD OF RECORD TYPE *******/

PROCEDURE create_plan_header(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_ROW_ID                     IN   ROWID,
    P_PLAN_ID                    IN   NUMBER,
    P_ORIGINAL_PLAN_ID           IN   NUMBER,
    P_PLAN_GROUP_CODE            IN   VARCHAR2,
    P_START_DATE_ACTIVE          IN   DATE,
    P_END_DATE_ACTIVE            IN   DATE,
    P_USE_FOR_CUST_ACCOUNT       IN   VARCHAR2,
    P_END_USER_TYPE              IN   VARCHAR2,
    P_CUSTOMIZED_PLAN            IN   VARCHAR2,
    P_PROFILE_CHECK_ID           IN   NUMBER,
    P_RELATIONAL_OPERATOR        IN   VARCHAR2,
    P_CRITERIA_VALUE_HIGH        IN   VARCHAR2,
    P_CRITERIA_VALUE_LOW         IN   VARCHAR2,
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
    P_OBJECT_VERSION_NUMBER      IN   NUMBER ,
    P_DESCRIPTION                IN   VARCHAR2,
    P_NAME                       IN   VARCHAR2,
    P_PARTY_ID_TBL               IN   CSC_CUST_PLANS_PVT.CSC_PARTY_ID_TBL_TYPE,
    X_PLAN_ID                    OUT NOCOPY  NUMBER,
    X_OBJECT_VERSION_NUMBER      OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2  )
IS
   l_pub_csc_plan_headers_b_rec   CSC_PLAN_HEADERS_B_REC_TYPE;

BEGIN

   convert_columns_to_rec_type(
      P_ROW_ID                     => p_row_id,
      P_PLAN_ID                    => p_plan_id,
      P_ORIGINAL_PLAN_ID           => p_original_plan_id,
      P_PLAN_GROUP_CODE            => p_plan_group_code,
      P_START_DATE_ACTIVE          => p_start_date_active,
      P_END_DATE_ACTIVE            => p_end_date_active ,
      P_USE_FOR_CUST_ACCOUNT       => P_use_for_cust_account,
      P_END_USER_TYPE              => P_end_user_type,
      P_CUSTOMIZED_PLAN            => p_customized_plan,
      P_PROFILE_CHECK_ID           => p_profile_check_id,
      P_RELATIONAL_OPERATOR        => p_relational_operator,
      P_CRITERIA_VALUE_HIGH        => p_criteria_value_high,
      P_CRITERIA_VALUE_LOW         => p_criteria_value_low,
      P_CREATION_DATE              => p_creation_date,
      P_LAST_UPDATE_DATE           => p_last_update_date,
      P_CREATED_BY                 => p_created_by,
      P_LAST_UPDATED_BY            => p_last_updated_by,
      P_LAST_UPDATE_LOGIN          => p_last_update_login,
      P_ATTRIBUTE1                 => p_attribute1,
      P_ATTRIBUTE2                 => p_attribute2,
      P_ATTRIBUTE3                 => p_attribute3,
      P_ATTRIBUTE4                 => p_attribute4,
      P_ATTRIBUTE5                 => p_attribute5,
      P_ATTRIBUTE6                 => p_attribute6,
      P_ATTRIBUTE7                 => p_attribute7,
      P_ATTRIBUTE8                 => p_attribute8,
      P_ATTRIBUTE9                 => p_attribute9,
      P_ATTRIBUTE10                => p_attribute10,
      P_ATTRIBUTE11                => p_attribute11,
      P_ATTRIBUTE12                => p_attribute12,
      P_ATTRIBUTE13                => p_attribute13,
      P_ATTRIBUTE14                => p_attribute14,
      P_ATTRIBUTE15                => p_attribute15,
      P_ATTRIBUTE_CATEGORY         => p_attribute_category,
      P_OBJECT_VERSION_NUMBER      => p_object_version_number,
      X_PUB_CSC_PLAN_HEADERS_B_REC => l_pub_csc_plan_headers_b_rec );

/*** CALL PROCEDURE WITH RECORD TYPE STRUCTURE ***/

   create_plan_header(
      p_api_version_number     => p_api_version_number,
      p_init_msg_list          => p_init_msg_list,
      p_commit                 => p_commit,
      p_csc_plan_headers_b_rec => l_pub_csc_plan_headers_b_rec,
      p_description            => p_description,
      p_name                   => p_name,
	 p_party_id_tbl           => p_party_id_tbl,
      x_plan_id                => x_plan_id,
      x_object_version_number  => x_object_version_number,
      x_return_status          => x_return_status,
      x_msg_count              => x_msg_count,
      x_msg_data               => x_msg_data );

END create_plan_header;


PROCEDURE create_plan_header(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_CSC_PLAN_HEADERS_B_REC     IN   CSC_PLAN_HEADERS_B_REC_TYPE,
    P_DESCRIPTION                IN   VARCHAR2,
    P_NAME                       IN   VARCHAR2,
    P_PARTY_ID_TBL               IN   CSC_CUST_PLANS_PVT.CSC_PARTY_ID_TBL_TYPE,
    X_PLAN_ID                    OUT NOCOPY  NUMBER,
    X_OBJECT_VERSION_NUMBER      OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
   l_api_name                   CONSTANT   VARCHAR2(30) := 'create_plan_header';
   l_api_version_number         CONSTANT   NUMBER       := 1.0;
   l_pvt_CSC_PLAN_HEADERS_B_REC CSC_RELATIONSHIP_PLANS_PVT.CSC_PLAN_HEADERS_B_REC_TYPE :=
                                 CSC_RELATIONSHIP_PLANS_PVT.G_MISS_CSC_PLAN_HEADERS_B_REC;
   l_pvt_CSC_PARTY_ID_TBL       CSC_CUST_PLANS_PVT.CSC_PARTY_ID_TBL_TYPE :=
						   CSC_CUST_PLANS_PVT.G_MISS_PARTY_ID_TBL;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT create_plan_header_pub;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Convert the values to ids. As of now there are no values to be converted into ids. But call
   -- the proc. to keep with the standards and to get back a pvt. rec type to pass to the pvt.
   -- package. A table type conversion is also added in this procedure to collect information about
   -- the parties when a 'CUSTOMIZED' plan is created. DJ
   --
   CONVERT_CSC_PLAN_HEADERS_B (
         P_CSC_PLAN_HEADERS_B_REC       =>  P_CSC_PLAN_HEADERS_B_REC,
	    P_PARTY_ID_TBL                 =>  P_PARTY_ID_TBL,
         x_pvt_CSC_PLAN_HEADERS_B_REC   =>  l_pvt_CSC_PLAN_HEADERS_B_REC,
	    x_pvt_CSC_PARTY_ID_TBL         =>  l_pvt_CSC_PARTY_ID_TBL);

   -- Calling Private package : Create_PLAN_HEADERS_B
   -- Hint : Primary key needs to be returned
   CSC_relationship_plans_PVT.Create_plan_header(
      P_Api_Version_Number         => 1.0,
      P_Init_Msg_List              => FND_API.G_FALSE,
      P_Commit                     => FND_API.G_FALSE,
      P_Validation_Level           => FND_API.G_VALID_LEVEL_FULL,
      P_CSC_PLAN_HEADERS_B_REC     => l_pvt_CSC_PLAN_HEADERS_B_REC ,
      P_DESCRIPTION                => p_description,
      P_NAME                       => p_name,
	 P_PARTY_ID_TBL               => l_pvt_CSC_PARTY_ID_TBL,
      X_PLAN_ID                    => x_PLAN_ID,
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
   (  p_encoded        =>   FND_API.G_FALSE,
	 p_count          =>   x_msg_count,
      p_data           =>   x_msg_data );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      CSC_CORE_UTILS_PVT.HANDLE_EXCEPTIONS(
         P_API_NAME        => L_API_NAME,
         P_PKG_NAME        => G_PKG_NAME,
         P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR,
         P_PACKAGE_TYPE    => CSC_CORE_UTILS_PVT.G_PUB,
         X_MSG_COUNT       => X_MSG_COUNT,
         X_MSG_DATA        => X_MSG_DATA,
         X_RETURN_STATUS   => X_RETURN_STATUS);
	    APP_EXCEPTION.RAISE_EXCEPTION;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      CSC_CORE_UTILS_PVT.HANDLE_EXCEPTIONS(
         P_API_NAME        => L_API_NAME,
         P_PKG_NAME        => G_PKG_NAME,
         P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,
         P_PACKAGE_TYPE    => CSC_CORE_UTILS_PVT.G_PUB,
         X_MSG_COUNT       => X_MSG_COUNT,
         X_MSG_DATA        => X_MSG_DATA,
         X_RETURN_STATUS   => X_RETURN_STATUS);
	    APP_EXCEPTION.RAISE_EXCEPTION;

   WHEN OTHERS THEN
      CSC_CORE_UTILS_PVT.HANDLE_EXCEPTIONS(
         P_API_NAME        => L_API_NAME,
         P_PKG_NAME        => G_PKG_NAME,
         P_EXCEPTION_LEVEL => CSC_CORE_UTILS_PVT.G_MSG_LVL_OTHERS,
         P_PACKAGE_TYPE    => CSC_CORE_UTILS_PVT.G_PUB,
         X_MSG_COUNT       => X_MSG_COUNT,
         X_MSG_DATA        => X_MSG_DATA,
         X_RETURN_STATUS   => X_RETURN_STATUS);
	    APP_EXCEPTION.RAISE_EXCEPTION;

End create_plan_header;


/*********** OVERLOADED PROCEDURE TO TAKE COLUMNS INSTEAD OF RECORD TYPE *******/

PROCEDURE update_plan_header(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_ROW_ID                     IN   ROWID,
    P_PLAN_ID                    IN   NUMBER,
    P_ORIGINAL_PLAN_ID           IN   NUMBER,
    P_PLAN_GROUP_CODE            IN   VARCHAR2,
    P_START_DATE_ACTIVE          IN   DATE,
    P_END_DATE_ACTIVE            IN   DATE,
    P_USE_FOR_CUST_ACCOUNT       IN   VARCHAR2,
    P_END_USER_TYPE              IN   VARCHAR2,
    P_CUSTOMIZED_PLAN            IN   VARCHAR2,
    P_PROFILE_CHECK_ID           IN   NUMBER,
    P_RELATIONAL_OPERATOR        IN   VARCHAR2,
    P_CRITERIA_VALUE_HIGH        IN   VARCHAR2,
    P_CRITERIA_VALUE_LOW         IN   VARCHAR2,
    P_CREATION_DATE              IN   DATE,
    P_LAST_UPDATE_DATE           IN   DATE,
    P_CREATED_BY                 IN   NUMBER,
    P_LAST_UPDATED_BY            IN   NUMBER,
    P_LAST_UPDATE_LOGIN          IN   NUMBER,
    P_ATTRIBUTE1                 IN   VARCHAR2 ,
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
    P_OBJECT_VERSION_NUMBER      IN   NUMBER ,
    P_DESCRIPTION                IN   VARCHAR2,
    P_NAME                       IN   VARCHAR2,
    P_PARTY_ID_TBL               IN   CSC_CUST_PLANS_PVT.CSC_PARTY_ID_TBL_TYPE,
    X_OBJECT_VERSION_NUMBER      OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
   l_pub_csc_plan_headers_b_rec   CSC_PLAN_HEADERS_B_REC_TYPE;

BEGIN

   convert_columns_to_rec_type(
      P_ROW_ID                     => p_row_id,
      P_PLAN_ID                    => p_plan_id,
      P_ORIGINAL_PLAN_ID           => p_original_plan_id,
      P_PLAN_GROUP_CODE            => p_plan_group_code,
      P_START_DATE_ACTIVE          => p_start_date_active,
      P_END_DATE_ACTIVE            => p_end_date_active ,
      P_USE_FOR_CUST_ACCOUNT       => P_use_for_cust_account,
      P_END_USER_TYPE              => P_end_user_type,
      P_CUSTOMIZED_PLAN            => p_customized_plan,
      P_PROFILE_CHECK_ID           => p_profile_check_id,
      P_RELATIONAL_OPERATOR        => p_relational_operator,
      P_CRITERIA_VALUE_HIGH        => p_criteria_value_high,
      P_CRITERIA_VALUE_LOW         => p_criteria_value_low,
      P_CREATION_DATE              => p_creation_date,
      P_LAST_UPDATE_DATE           => p_last_update_date,
      P_CREATED_BY                 => p_created_by,
      P_LAST_UPDATED_BY            => p_last_updated_by,
      P_LAST_UPDATE_LOGIN          => p_last_update_login,
      P_ATTRIBUTE1                 => p_attribute1,
      P_ATTRIBUTE2                 => p_attribute2,
      P_ATTRIBUTE3                 => p_attribute3,
      P_ATTRIBUTE4                 => p_attribute4,
      P_ATTRIBUTE5                 => p_attribute5,
      P_ATTRIBUTE6                 => p_attribute6,
      P_ATTRIBUTE7                 => p_attribute7,
      P_ATTRIBUTE8                 => p_attribute8,
      P_ATTRIBUTE9                 => p_attribute9,
      P_ATTRIBUTE10                => p_attribute10,
      P_ATTRIBUTE11                => p_attribute11,
      P_ATTRIBUTE12                => p_attribute12,
      P_ATTRIBUTE13                => p_attribute13,
      P_ATTRIBUTE14                => p_attribute14,
      P_ATTRIBUTE15                => p_attribute15,
      P_ATTRIBUTE_CATEGORY         => p_attribute_category,
      P_OBJECT_VERSION_NUMBER      => p_object_version_number,
      X_PUB_CSC_PLAN_HEADERS_B_REC => l_pub_csc_plan_headers_b_rec );

/*** CALL PROCEDURE WITH RECORD TYPE STRUCTURE ***/
   update_plan_header(
      P_Api_Version_Number         => p_api_version_number,
      P_Init_Msg_List              => p_init_msg_list,
      P_Commit                     => p_commit,
      P_CSC_PLAN_HEADERS_B_REC     => l_pub_csc_plan_headers_b_rec,
      P_DESCRIPTION                => p_description,
      P_NAME                       => p_name,
      P_PARTY_ID_TBL               => p_party_id_tbl,
      X_Object_Version_Number      => x_object_version_number,
      X_Return_Status              => x_return_status,
      X_Msg_Count                  => x_msg_count,
      X_Msg_Data                   => x_msg_data );

END update_plan_header;


PROCEDURE update_plan_header(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_CSC_PLAN_HEADERS_B_REC     IN   CSC_PLAN_HEADERS_B_REC_TYPE,
    P_DESCRIPTION                IN   VARCHAR2,
    P_NAME                       IN   VARCHAR2,
    P_PARTY_ID_TBL               IN   CSC_CUST_PLANS_PVT.CSC_PARTY_ID_TBL_TYPE,
    X_OBJECT_VERSION_NUMBER      OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
   l_api_name                    CONSTANT VARCHAR2(30) := 'update_plan_header';
   l_api_version_number          CONSTANT NUMBER       := 1.0;
   l_pvt_CSC_PLAN_HEADERS_B_REC CSC_RELATIONSHIP_PLANS_PVT.CSC_PLAN_HEADERS_B_REC_TYPE :=
                                 CSC_RELATIONSHIP_PLANS_PVT.G_MISS_CSC_PLAN_HEADERS_B_REC;
   l_pvt_CSC_PARTY_ID_TBL       CSC_CUST_PLANS_PVT.CSC_PARTY_ID_TBL_TYPE :=
						   CSC_CUST_PLANS_PVT.G_MISS_PARTY_ID_TBL;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT update_plan_header_pub;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version_number,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Convert the values to ids. As of now there are no values to be converted into ids. But call
   -- the proc. to keep with the standards and to get back a pvt. rec type to pass to the pvt.
   -- package. DJ
   --
   CONVERT_CSC_PLAN_HEADERS_B (
         P_CSC_PLAN_HEADERS_B_REC       =>  P_CSC_PLAN_HEADERS_B_REC,
	    P_PARTY_ID_TBL                 =>  P_PARTY_ID_TBL,
         x_pvt_CSC_PLAN_HEADERS_B_REC   =>  l_pvt_CSC_PLAN_HEADERS_B_REC,
	    x_pvt_CSC_PARTY_ID_TBL         =>  l_pvt_CSC_PARTY_ID_TBL);

   CSC_relationship_plans_pvt.update_plan_header(
      P_Api_Version_Number         => 1.0,
      P_Init_Msg_List              => FND_API.G_FALSE,
      P_Commit                     => p_commit,
      P_Validation_Level           => FND_API.G_VALID_LEVEL_FULL,
      P_CSC_PLAN_HEADERS_B_REC     => l_pvt_CSC_PLAN_HEADERS_B_REC ,
      P_DESCRIPTION                => p_description,
      P_NAME                       => p_name,
	 P_PARTY_ID_TBL                => l_pvt_CSC_PARTY_ID_TBL,
      X_Object_Version_Number      => x_object_version_number,
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
      (  p_encoded        =>   FND_API.G_FALSE,
	    p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      CSC_CORE_UTILS_PVT.HANDLE_EXCEPTIONS(
            P_API_NAME        => L_API_NAME,
            P_PKG_NAME        => G_PKG_NAME,
            P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR,
            P_PACKAGE_TYPE    => CSC_CORE_UTILS_PVT.G_PUB,
            X_MSG_COUNT       => X_MSG_COUNT,
            X_MSG_DATA        => X_MSG_DATA,
            X_RETURN_STATUS   => X_RETURN_STATUS);
	    APP_EXCEPTION.RAISE_EXCEPTION;

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   CSC_CORE_UTILS_PVT.HANDLE_EXCEPTIONS(
            P_API_NAME        => L_API_NAME,
            P_PKG_NAME        => G_PKG_NAME,
            P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,
            P_PACKAGE_TYPE    => CSC_CORE_UTILS_PVT.G_PUB,
            X_MSG_COUNT       => X_MSG_COUNT,
            X_MSG_DATA        => X_MSG_DATA,
            X_RETURN_STATUS   => X_RETURN_STATUS);
	    APP_EXCEPTION.RAISE_EXCEPTION;

WHEN OTHERS THEN
   CSC_CORE_UTILS_PVT.HANDLE_EXCEPTIONS(
            P_API_NAME        => L_API_NAME,
            P_PKG_NAME        => G_PKG_NAME,
            P_EXCEPTION_LEVEL => CSC_CORE_UTILS_PVT.G_MSG_LVL_OTHERS,
            P_PACKAGE_TYPE    => CSC_CORE_UTILS_PVT.G_PUB,
            X_MSG_COUNT       => X_MSG_COUNT,
            X_MSG_DATA        => X_MSG_DATA,
            X_RETURN_STATUS   => X_RETURN_STATUS);
	    APP_EXCEPTION.RAISE_EXCEPTION;

End update_plan_header;


PROCEDURE Disable_plan(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_Plan_Id                    IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2 )
IS
   l_api_name                    CONSTANT VARCHAR2(30) := 'Disable_Plan';
   l_api_version_number          CONSTANT NUMBER       := 1.0;
   l_pvt_CSC_PLAN_HEADERS_B_REC  CSC_RELATIONSHIP_PLANS_PVT.CSC_PLAN_HEADERS_B_REC_TYPE;
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
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   CSC_relationship_plans_PVT.disable_plan(
            P_Api_Version_Number         => 1.0,
            P_Init_Msg_List              => FND_API.G_FALSE,
            P_Commit                     => p_commit,
            P_plan_id                    => p_plan_id,
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
      (  p_encoded        =>   FND_API.G_FALSE,
	    p_count          =>   x_msg_count,
         p_data           =>   x_msg_data );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      CSC_CORE_UTILS_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME        => L_API_NAME,
               P_PKG_NAME        => G_PKG_NAME,
               P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR,
               P_PACKAGE_TYPE    => CSC_CORE_UTILS_PVT.G_PUB,
               X_MSG_COUNT       => X_MSG_COUNT,
               X_MSG_DATA        => X_MSG_DATA,
               X_RETURN_STATUS   => X_RETURN_STATUS);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      CSC_CORE_UTILS_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME        => L_API_NAME,
               P_PKG_NAME        => G_PKG_NAME,
               P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR,
               P_PACKAGE_TYPE    => CSC_CORE_UTILS_PVT.G_PUB,
               X_MSG_COUNT       => X_MSG_COUNT,
               X_MSG_DATA        => X_MSG_DATA,
               X_RETURN_STATUS   => X_RETURN_STATUS);

   WHEN OTHERS THEN
      CSC_CORE_UTILS_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME        => L_API_NAME,
               P_PKG_NAME        => G_PKG_NAME,
               P_EXCEPTION_LEVEL => CSC_CORE_UTILS_PVT.G_MSG_LVL_OTHERS,
               P_PACKAGE_TYPE    => CSC_CORE_UTILS_PVT.G_PUB,
               X_MSG_COUNT       => X_MSG_COUNT,
               X_MSG_DATA        => X_MSG_DATA,
               X_RETURN_STATUS   => X_RETURN_STATUS);

End Disable_plan;

End CSC_RELATIONSHIP_PLANS_PUB;

/
