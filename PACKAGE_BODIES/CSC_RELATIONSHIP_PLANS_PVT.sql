--------------------------------------------------------
--  DDL for Package Body CSC_RELATIONSHIP_PLANS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSC_RELATIONSHIP_PLANS_PVT" as
/* $Header: cscvrlpb.pls 115.28 2004/02/24 07:09:12 bhroy ship $ */
-- Start of Comments
-- Package name     : CSC_RELATIONSHIP_PLANS_PVT
-- Purpose          : This package contains all procedures and functions that are required
--                    to create and modify plan headers and details and disable plans.
-- History
-- MM-DD-YYYY    NAME          MODIFICATIONS
-- 10-08-1999    dejoseph      Created.
-- 12-08-1999    dejoseph      'Arcs'ed in for first code freeze.
-- 12-21-1999    dejoseph      'Arcs'ed in for second code freeze.
-- 01-03-2000    dejoseph      'Arcs'ed in for third code freeze. (10-JAN-2000)
-- 01-31-2000    dejoseph      'Arcs'ed in for fourth code freeze. (07-FEB-2000)
-- 02-13-2000    dejoseph      'Arcs'ed on for fifth code freeze. (21-FEB-2000)
-- 02-28-2000    dejoseph      'Arcs'ed on for sixth code freeze. (06-MAR-2000)
-- 04-06-2000    dejoseph      Modified validate_end_date_active proc. to denote the
--                             correct operand '<' instead of '>'.
-- 04-10-2000    dejoseph      Removed reference to cust_account_org in lieu of TCA's
--                             decision to drop column org_id from hz_cust_accounts.
-- 04-10-2000    dejoseph      Added logic not to allow update of end_date_active to < sysdate
--                             when existing end_date_active is null;
-- 06-28-2001    dejoseph      Corrected default values for parameters 'p_description' and
--                             'p_name' in procedure UPDATE_PLAN_HEADER to match with the
--                             package spec. default values. Fix to bug# 1852893.
-- 02-18-2002    dejoseph      Added changes to uptake new functionality for 11.5.8.
--                             Ct. / Agent facing application
--                             - Added new IN parameter END_USER_TYPE to procedures:
--                                 convert_columns_to_rec_type
--                                 create_plan_header
--                                 update_plan_header
--                             - Added a new procedure VALIDATE_END_USER_TYPE
--                             Added the dbdrv command.
-- 05-23-2002    dejoseph      Added checkfile syntax.
-- 02-11-2002	 bhroy		Fixed Bug# 2412929,2250056 - CSC_CUST_PLANS table was not
--				getting updated when user changes End_Date_Active
--
-- 04-Nov-2002   kmotepal      Added OSERROR command to fix GSCC warnings for patch 2633080
-- 13-Nov-2002	 bhroy		NOCOPY changes made
-- 11-27-2002	 bhroy		All the default values have been removed, also fixed Bug# 2250056
-- 16-JUN-2003	bhroy		Modified CSC_CORE_UTILS_PVT.G_APP_SHORTNAME to CS, it was pointed to CSC, messages are in CS
-- 26-NOV-2003  bhroy		Fixed bug# 2805474, update Start_Date_Active
-- 22-DEC-2003  bhroy		Fixed bug# 3319977, 3319946, chanegd text messages, removed FND_API.G_MISS_NUM for G_CUSTOMIZED_ID
--
-- End of Comments


G_PKG_NAME                CONSTANT VARCHAR2(30)  := 'CSC_RELATIONSHIP_PLANS_PVT';
G_FILE_NAME               CONSTANT VARCHAR2(12)  := 'cscvrlpb.pls';

G_CUSTOMIZED_ID           NUMBER;
-- G_CUSTOMIZED_ID           NUMBER := FND_API.G_MISS_NUM;
-- used to get back the id of the record
-- created in CSC_CUSTOMIZED_PLANS table
-- when a customzied plan is created.

-- not using this global variable coz, when executing the validation procedure stand-alone
-- from forms, this errors out.
--G_CUST_PLANS_REC_CNT      NUMBER := FND_API.G_MISS_NUM;
							    -- Used to keep a count on the number of records in
							    -- CSC_CUST_PLANS table. This count is used while performing
							    -- update on columns which requires that there should be no
							    -- association between plans and customers. ie. if a record
							    -- exist in this table, then do not allow the update on that
							    -- column. eg. use_for_cust_account, profile_check_id etc.

/*** PROCEDURE THAT CONVERTS INDIVIDUAL COLUMN PARAMETERS INTO RECORD TYPE FOR
     PROCEDURE OVERLOADING   ***/

PROCEDURE convert_columns_to_rec_type(
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
    P_OBJECT_VERSION_NUMBER      IN   NUMBER,
    X_PVT_CSC_PLAN_HEADERS_B_REC OUT NOCOPY  CSC_PLAN_HEADERS_B_REC_TYPE )
IS

BEGIN
   x_pvt_csc_plan_headers_b_rec.ROW_ID               := p_row_id;
   x_pvt_csc_plan_headers_b_rec.PLAN_ID              := p_plan_id;
   x_pvt_csc_plan_headers_b_rec.ORIGINAL_PLAN_ID     := p_original_plan_id;
   x_pvt_csc_plan_headers_b_rec.PLAN_GROUP_CODE      := p_plan_group_code;
   x_pvt_csc_plan_headers_b_rec.START_DATE_ACTIVE    := p_start_date_active;
   x_pvt_csc_plan_headers_b_rec.END_DATE_ACTIVE      := p_end_date_active;
   x_pvt_csc_plan_headers_b_rec.USE_FOR_CUST_ACCOUNT := p_use_for_cust_account;
   x_pvt_csc_plan_headers_b_rec.END_USER_TYPE        := p_end_user_type;
   x_pvt_csc_plan_headers_b_rec.CUSTOMIZED_PLAN      := p_customized_plan;
   x_pvt_csc_plan_headers_b_rec.PROFILE_CHECK_ID     := p_profile_check_id;
   x_pvt_csc_plan_headers_b_rec.RELATIONAL_OPERATOR  := p_relational_operator;
   x_pvt_csc_plan_headers_b_rec.CRITERIA_VALUE_HIGH  := p_criteria_value_high;
   x_pvt_csc_plan_headers_b_rec.CRITERIA_VALUE_LOW   := p_criteria_value_low;
   x_pvt_csc_plan_headers_b_rec.CREATION_DATE        := p_creation_date;
   x_pvt_csc_plan_headers_b_rec.LAST_UPDATE_DATE     := p_last_update_date;
   x_pvt_csc_plan_headers_b_rec.CREATED_BY           := p_created_by;
   x_pvt_csc_plan_headers_b_rec.LAST_UPDATED_BY      := p_last_updated_by;
   x_pvt_csc_plan_headers_b_rec.LAST_UPDATE_LOGIN    := p_last_update_login;
   x_pvt_csc_plan_headers_b_rec.ATTRIBUTE1           := p_attribute1;
   x_pvt_csc_plan_headers_b_rec.ATTRIBUTE2           := p_attribute2;
   x_pvt_csc_plan_headers_b_rec.ATTRIBUTE3           := p_attribute3;
   x_pvt_csc_plan_headers_b_rec.ATTRIBUTE4           := p_attribute4;
   x_pvt_csc_plan_headers_b_rec.ATTRIBUTE5           := p_attribute5;
   x_pvt_csc_plan_headers_b_rec.ATTRIBUTE6           := p_attribute6;
   x_pvt_csc_plan_headers_b_rec.ATTRIBUTE7           := p_attribute7;
   x_pvt_csc_plan_headers_b_rec.ATTRIBUTE8           := p_attribute8;
   x_pvt_csc_plan_headers_b_rec.ATTRIBUTE9           := p_attribute9;
   x_pvt_csc_plan_headers_b_rec.ATTRIBUTE10          := p_attribute10;
   x_pvt_csc_plan_headers_b_rec.ATTRIBUTE11          := p_attribute11;
   x_pvt_csc_plan_headers_b_rec.ATTRIBUTE12          := p_attribute12;
   x_pvt_csc_plan_headers_b_rec.ATTRIBUTE13          := p_attribute13;
   x_pvt_csc_plan_headers_b_rec.ATTRIBUTE14          := p_attribute14;
   x_pvt_csc_plan_headers_b_rec.ATTRIBUTE15          := p_attribute15;
   x_pvt_csc_plan_headers_b_rec.ATTRIBUTE_CATEGORY   := p_attribute_category;
   x_pvt_csc_plan_headers_b_rec.OBJECT_VERSION_NUMBER:= p_object_version_number;

END convert_columns_to_rec_type;


/*********** OVERLOADED PROCEDURE TO TAKE COLUMNS INSTEAD OF RECORD TYPE *******/

PROCEDURE create_plan_header(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
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
    P_OBJECT_VERSION_NUMBER      IN   NUMBER,
    P_DESCRIPTION                IN   VARCHAR2,
    P_NAME                       IN   VARCHAR2,
    P_PARTY_ID_TBL               IN   CSC_CUST_PLANS_PVT.CSC_PARTY_ID_TBL_TYPE,
    X_PLAN_ID                    OUT NOCOPY  NUMBER,
    X_OBJECT_VERSION_NUMBER      OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2  )
IS
   l_pvt_csc_plan_headers_b_rec   CSC_PLAN_HEADERS_B_REC_TYPE;

BEGIN
   convert_columns_to_rec_type(
      p_row_id                     => p_row_id,
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
      X_PVT_CSC_PLAN_HEADERS_B_REC => l_pvt_csc_plan_headers_b_rec );

/*** CALL PROCEDURE WITH RECORD TYPE STRUCTURE ***/

   create_plan_header(
      p_api_version_number     => p_api_version_number,
      p_init_msg_list          => p_init_msg_list,
      p_commit                 => p_commit,
      p_validation_level       => p_validation_level,
      p_csc_plan_headers_b_rec => l_pvt_csc_plan_headers_b_rec,
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
   p_validation_level           IN   NUMBER,
   P_CSC_PLAN_HEADERS_B_REC     IN   CSC_PLAN_HEADERS_B_REC_TYPE,
   P_DESCRIPTION                IN   VARCHAR2,
   P_NAME                       IN   VARCHAR2,
   P_PARTY_ID_TBL               IN   CSC_CUST_PLANS_PVT.CSC_PARTY_ID_TBL_TYPE,
   X_PLAN_ID                    OUT NOCOPY  NUMBER,
   X_Object_Version_Number      OUT NOCOPY  NUMBER,
   X_Return_Status              OUT NOCOPY  VARCHAR2,
   X_Msg_Count                  OUT NOCOPY  NUMBER,
   X_Msg_Data                   OUT NOCOPY  VARCHAR2
   )
IS
   l_api_name                CONSTANT VARCHAR2(30) := 'create_plan_header';
   l_api_version_number      CONSTANT NUMBER       := 1.0;
   l_cust_plan_id            NUMBER;
   -- The following assignment is done, because the correct values have to be passed into the
   -- table handler insert pkg. If FND_API.G_MISS_ is being passed in, then these values have to
   -- be nullified because FND_API.G_MISS_NUM is a huge value and does not fit into most db
   -- columns. These assignments are done before the call to the table handler API.
   l_ins_plan_headers_b_rec  CSC_PLAN_HEADERS_B_REC_TYPE := P_CSC_PLAN_HEADERS_B_REC;
   l_name                             VARCHAR2(90)  := P_NAME;
   l_description                      VARCHAR2(720) := P_DESCRIPTION;

   -- A local party_id table type is declared because sometimes plans can be customized
   -- at party level, in which case the cust_account_id and cust_account_org should be
   -- nullified. 'IN' parameters cannot be assigned a value, so this local table type is
   -- used.
   --l_party_id_tbl            CSC_PARTY_ID_TBL_TYPE := P_PARTY_ID_TBL;
   l_party_id_tbl            CSC_CUST_PLANS_PVT.CSC_PARTY_ID_TBL_TYPE := P_PARTY_ID_TBL;

   x_cust_object_version_number  NUMBER; -- used to get back the OUT NOCOPY value when updating
								 -- CSC_CUST_PLANS table, when customizing plans
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT CREATE_PLAN_HEADER_PVT;

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
   IF FND_GLOBAL.User_Id IS NULL THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         FND_MESSAGE.Set_Name(CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'UT_CANNOT_GET_PROFILE_VALUE');
         FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
         --FND_MSG_PUB.ADD;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN
      -- Invoke validation procedures
      Validate_csc_relationship_plan(
                       p_init_msg_list           => FND_API.G_FALSE,
                       p_validation_level        => p_validation_level,
                       p_validation_mode         => CSC_CORE_UTILS_PVT.G_CREATE,
                       P_CSC_PLAN_HEADERS_B_REC  => P_CSC_PLAN_HEADERS_B_REC,
                       P_DESCRIPTION             => p_description,
                       P_NAME                    => p_name,
                       x_return_status           => x_return_status,
                       x_msg_count               => x_msg_count,
                       x_msg_data                => x_msg_data);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

--
-- Default checks to be performed, ir-respective of the validation level passed in.
--
   -- if a customized plan is being created,ie. CUST0MIZED_PLAN = 'Y' then
   -- 1. Validate party_id.
   -- 2. If plan is being customized for account level, ie.USE_FOR_CUST_ACCOUNTS = 'Y' then
   --    2a. Validate CUST_ACCOUNT_ID and CUST_ACCOUNT_ORG
   -- 3. Insert a record into CSC_CUSTOMIZED_PLANS table to save the
   --    customer-plan relationship.
   -- 4. Insert a record into CSC_CUST_PLANS table.
   -- 5. Update CSC_CUST_PLANS table to show new customized plan_id where ever the customer
   --    plan association exists
   -- NOTE : If parent plan which is customized is a PARTY level plan, then allow the
   -- customization only at PARTY level, else return back and error status. The same
   -- applies to ACCOUNT level plans.

   IF ( P_CSC_PLAN_HEADERS_B_REC.CUSTOMIZED_PLAN = 'Y' ) then
      Validate_ORIGINAL_PLAN_ID(
            p_init_msg_list          => FND_API.G_FALSE,
            p_validation_mode        => CSC_CORE_UTILS_PVT.G_CREATE,
            p_PLAN_ID                => P_CSC_PLAN_HEADERS_B_REC.PLAN_ID,
            p_ORIGINAL_PLAN_ID       => P_CSC_PLAN_HEADERS_B_REC.ORIGINAL_PLAN_ID,
		  p_CUSTOMIZED_PLAN        => P_CSC_PLAN_HEADERS_B_REC.CUSTOMIZED_PLAN,
            x_return_status          => x_return_status,
            x_msg_count              => x_msg_count,
            x_msg_data               => x_msg_data);
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         raise FND_API.G_EXC_ERROR;
      END IF;
	 if ( l_party_id_tbl.count = 0 ) then
--         fnd_message.set_name (CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'CS_API_ALL_NULL_PARAMETER');
         fnd_message.set_name ('CS', 'CS_API_ALL_NULL_PARAMETER');
         fnd_message.set_token ('API_NAME', G_PKG_NAME||'.'|| l_api_name);
         fnd_message.set_token('NULL_PARAM', 'PARTY_ID');
         -- fnd_msg_pub.add;
         x_return_status := FND_API.G_RET_STS_ERROR;
         RAISE FND_API.G_EXC_ERROR;
      else
         for i in 1..l_party_id_tbl.count
         loop
	       if ( p_csc_plan_headers_b_rec.use_for_cust_account = 'N' ) then
               if ( l_party_id_tbl(i).cust_account_id  is not NULL )
			-- OR l_party_id_tbl(i).cust_account_org is not NULL )
		     then
			-- cannot allow update because parent plan is at account level and this
			-- operation is trying to customize at party level.
--                  fnd_message.set_name (CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'CS_API_ALL_INVALID_ARGUMENT');
                  fnd_message.set_name ('CS', 'CS_API_ALL_INVALID_ARGUMENT');
                  fnd_message.set_token ('API_NAME', G_PKG_NAME||'.'||l_api_name);
                  fnd_message.set_token('VALUE', p_csc_plan_headers_b_rec.use_for_cust_account);
                  fnd_message.set_token('PARAMETER', 'USE_FOR_CUST_ACCOUNT');
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  RAISE FND_API.G_EXC_ERROR;
			end if;
            end if;
            CSC_CUST_PLANS_PVT.Validate_PARTY_ID (
                  P_Init_Msg_List       =>  FND_API.G_TRUE,
                  P_Validation_mode     =>  CSC_CORE_UTILS_PVT.G_CREATE,
                  P_PARTY_ID            =>  l_party_id_tbl(i).party_id,
                  x_Return_Status       =>  x_return_status,
                  X_Msg_Count           =>  x_msg_count,
                  X_Msg_Data            =>  x_msg_data );
            if ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) then
               RAISE FND_API.G_EXC_ERROR;
            end if;

            /**********************   04-10-2000

            IF ( P_CSC_PLAN_HEADERS_B_REC.USE_FOR_CUST_ACCOUNT = 'Y' ) then
               CSC_CUST_PLANS_PVT.Validate_CUST_ACC_ORG_ID (
                     P_Init_Msg_List        =>  FND_API.G_TRUE,
                     P_Validation_mode      =>  CSC_CORE_UTILS_PVT.G_CREATE,
                     P_PARTY_ID             =>  l_party_id_tbl(i).party_id,
                     P_CUST_ACCOUNT_ID      =>  l_party_id_tbl(i).cust_account_id,
                     -- CUST_ACCOUNT_ORG      =>  l_party_id_tbl(i).cust_account_org,
                     X_Return_Status        =>  x_return_status,
                     X_Msg_Count            =>  x_msg_count,
                     X_Msg_Data             =>  x_msg_data );
               if ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) then
                  RAISE FND_API.G_EXC_ERROR;
               end if;
            END IF;  -- end of use_for_cust_account = 'Y'

            ***********************************/
         end loop;
      end if; -- end for count = 0
   END IF; -- end for customized_plan = 'Y'

-- Get the final values of all the parameters that have to be passed into the table
-- handler insert package; The decode is done here rather than in the insert statement
-- of the table handler, because, when submitting the insert sql. statement to the SGA,
-- we need to pass an identical insert statement every time. This saves SGA space and
-- increases performance by using shared pool.

/********** This check is not required, NULL can be passed directly as parameter value

   if ( p_csc_plan_headers_b_rec.original_plan_id = FND_API.G_MISS_NUM ) then
	 l_ins_plan_headers_b_rec.original_plan_id := NULL;
   end if;

   if ( p_csc_plan_headers_b_rec.plan_group_code = FND_API.G_MISS_CHAR ) then
	 l_ins_plan_headers_b_rec.plan_group_code := NULL;
   end if;

   if ( p_csc_plan_headers_b_rec.start_date_active = FND_API.G_MISS_DATE ) then
	 l_ins_plan_headers_b_rec.start_date_active := NULL;
   end if;

   if ( p_csc_plan_headers_b_rec.end_date_active = FND_API.G_MISS_DATE ) then
	 l_ins_plan_headers_b_rec.end_date_active := NULL;
   end if;

   if ( p_csc_plan_headers_b_rec.use_for_cust_account = FND_API.G_MISS_CHAR ) then
	 l_ins_plan_headers_b_rec.use_for_cust_account := NULL;
   end if;

   if ( p_csc_plan_headers_b_rec.end_user_type = CSC_CORE_UTILS_PVT.G_MISS_CHAR ) then
	 l_ins_plan_headers_b_rec.end_user_type := NULL;
   end if;

   if ( p_csc_plan_headers_b_rec.customized_plan = FND_API.G_MISS_CHAR ) then
	 l_ins_plan_headers_b_rec.customized_plan := NULL;
   end if;

   if ( p_csc_plan_headers_b_rec.profile_check_id = FND_API.G_MISS_NUM ) then
	 l_ins_plan_headers_b_rec.profile_check_id := NULL;
   end if;

   if ( p_csc_plan_headers_b_rec.relational_operator = FND_API.G_MISS_CHAR ) then
	 l_ins_plan_headers_b_rec.relational_operator := NULL;
   end if;

   if ( p_csc_plan_headers_b_rec.criteria_value_high = FND_API.G_MISS_CHAR ) then
	 l_ins_plan_headers_b_rec.criteria_value_high := NULL;
   end if;

   if ( p_csc_plan_headers_b_rec.criteria_value_low = FND_API.G_MISS_CHAR ) then
	 l_ins_plan_headers_b_rec.criteria_value_low := NULL;
   end if;

   if ( p_csc_plan_headers_b_rec.attribute1 = FND_API.G_MISS_CHAR ) then
	 l_ins_plan_headers_b_rec.attribute1 := NULL;
   end if;

   if ( p_csc_plan_headers_b_rec.attribute2 = FND_API.G_MISS_CHAR ) then
	 l_ins_plan_headers_b_rec.attribute2 := NULL;
   end if;

   if ( p_csc_plan_headers_b_rec.attribute3 = FND_API.G_MISS_CHAR ) then
	 l_ins_plan_headers_b_rec.attribute3 := NULL;
   end if;

   if ( p_csc_plan_headers_b_rec.attribute4 = FND_API.G_MISS_CHAR ) then
	 l_ins_plan_headers_b_rec.attribute4 := NULL;
   end if;

   if ( p_csc_plan_headers_b_rec.attribute5 = FND_API.G_MISS_CHAR ) then
	 l_ins_plan_headers_b_rec.attribute5 := NULL;
   end if;

   if ( p_csc_plan_headers_b_rec.attribute6 = FND_API.G_MISS_CHAR ) then
	 l_ins_plan_headers_b_rec.attribute6 := NULL;
   end if;

   if ( p_csc_plan_headers_b_rec.attribute7 = FND_API.G_MISS_CHAR ) then
	 l_ins_plan_headers_b_rec.attribute7 := NULL;
   end if;

   if ( p_csc_plan_headers_b_rec.attribute8 = FND_API.G_MISS_CHAR ) then
	 l_ins_plan_headers_b_rec.attribute8 := NULL;
   end if;

   if ( p_csc_plan_headers_b_rec.attribute9 = FND_API.G_MISS_CHAR ) then
	 l_ins_plan_headers_b_rec.attribute9 := NULL;
   end if;

   if ( p_csc_plan_headers_b_rec.attribute10 = FND_API.G_MISS_CHAR ) then
	 l_ins_plan_headers_b_rec.attribute10 := NULL;
   end if;

   if ( p_csc_plan_headers_b_rec.attribute11 = FND_API.G_MISS_CHAR ) then
	 l_ins_plan_headers_b_rec.attribute11 := NULL;
   end if;

   if ( p_csc_plan_headers_b_rec.attribute12 = FND_API.G_MISS_CHAR ) then
	 l_ins_plan_headers_b_rec.attribute12 := NULL;
   end if;

   if ( p_csc_plan_headers_b_rec.attribute13 = FND_API.G_MISS_CHAR ) then
	 l_ins_plan_headers_b_rec.attribute13 := NULL;
   end if;

   if ( p_csc_plan_headers_b_rec.attribute14 = FND_API.G_MISS_CHAR ) then
	 l_ins_plan_headers_b_rec.attribute14 := NULL;
   end if;

   if ( p_csc_plan_headers_b_rec.attribute15 = FND_API.G_MISS_CHAR ) then
	 l_ins_plan_headers_b_rec.attribute15 := NULL;
   end if;

   if ( p_csc_plan_headers_b_rec.attribute_category = FND_API.G_MISS_CHAR ) then
	 l_ins_plan_headers_b_rec.attribute_category := NULL;
   end if;

**************************/

   if ( p_name <> FND_API.G_MISS_CHAR ) then
	 l_name:= p_name;
   end if;

   if ( p_description <> FND_API.G_MISS_CHAR ) then
	 l_description:= p_description;
   end if;

   -- Invoke table handler(CSC_PLAN_HEADERS_B_PKG.Insert_Row)
   x_plan_id := p_csc_plan_headers_b_rec.plan_id;
   CSC_PLAN_HEADERS_B_PKG.Insert_Row(
                px_PLAN_ID              => x_plan_id,
                p_ORIGINAL_PLAN_ID      => l_ins_plan_headers_b_rec.ORIGINAL_PLAN_ID,
                p_PLAN_GROUP_CODE       => l_ins_plan_headers_b_rec.PLAN_GROUP_CODE,
                p_START_DATE_ACTIVE     => l_ins_plan_headers_b_rec.START_DATE_ACTIVE,
                p_END_DATE_ACTIVE       => l_ins_plan_headers_b_rec.END_DATE_ACTIVE,
                p_USE_FOR_CUST_ACCOUNT  => l_ins_plan_headers_b_rec.USE_FOR_CUST_ACCOUNT,
                p_END_USER_TYPE         => l_ins_plan_headers_b_rec.END_USER_TYPE,
	        p_CUSTOMIZED_PLAN       => l_ins_plan_headers_b_rec.CUSTOMIZED_PLAN,
                p_PROFILE_CHECK_ID      => l_ins_plan_headers_b_rec.PROFILE_CHECK_ID,
                p_RELATIONAL_OPERATOR   => l_ins_plan_headers_b_rec.RELATIONAL_OPERATOR,
                p_CRITERIA_VALUE_HIGH   => l_ins_plan_headers_b_rec.CRITERIA_VALUE_HIGH,
                p_CRITERIA_VALUE_LOW    => l_ins_plan_headers_b_rec.CRITERIA_VALUE_LOW,
                p_CREATION_DATE         => SYSDATE,
                p_LAST_UPDATE_DATE      => SYSDATE,
                p_CREATED_BY            => FND_GLOBAL.USER_ID,
                p_LAST_UPDATED_BY       => FND_GLOBAL.USER_ID,
                p_LAST_UPDATE_LOGIN     => FND_GLOBAL.CONC_LOGIN_ID,
                p_ATTRIBUTE1            => l_ins_plan_headers_b_rec.ATTRIBUTE1,
                p_ATTRIBUTE2            => l_ins_plan_headers_b_rec.ATTRIBUTE2,
                p_ATTRIBUTE3            => l_ins_plan_headers_b_rec.ATTRIBUTE3,
                p_ATTRIBUTE4            => l_ins_plan_headers_b_rec.ATTRIBUTE4,
                p_ATTRIBUTE5            => l_ins_plan_headers_b_rec.ATTRIBUTE5,
                p_ATTRIBUTE6            => l_ins_plan_headers_b_rec.ATTRIBUTE6,
                p_ATTRIBUTE7            => l_ins_plan_headers_b_rec.ATTRIBUTE7,
                p_ATTRIBUTE8            => l_ins_plan_headers_b_rec.ATTRIBUTE8,
                p_ATTRIBUTE9            => l_ins_plan_headers_b_rec.ATTRIBUTE9,
                p_ATTRIBUTE10           => l_ins_plan_headers_b_rec.ATTRIBUTE10,
                p_ATTRIBUTE11           => l_ins_plan_headers_b_rec.ATTRIBUTE11,
                p_ATTRIBUTE12           => l_ins_plan_headers_b_rec.ATTRIBUTE12,
                p_ATTRIBUTE13           => l_ins_plan_headers_b_rec.ATTRIBUTE13,
                p_ATTRIBUTE14           => l_ins_plan_headers_b_rec.ATTRIBUTE14,
                p_ATTRIBUTE15           => l_ins_plan_headers_b_rec.ATTRIBUTE15,
                p_ATTRIBUTE_CATEGORY    => l_ins_plan_headers_b_rec.ATTRIBUTE_CATEGORY,
                p_DESCRIPTION           => l_DESCRIPTION,
                p_NAME                  => l_NAME,
                x_OBJECT_VERSION_NUMBER => x_object_version_number );

   IF ( p_csc_plan_headers_b_rec.customized_plan = 'Y' ) then
      for i in 1..l_party_id_tbl.count
	 LOOP
         CSC_CUSTOMIZED_PLANS_PKG.INSERT_ROW(
            px_id                   => g_customized_id,
            p_plan_id               => x_plan_id,
            p_party_id              => l_party_id_tbl(i).party_id,
		  p_cust_account_id       => l_party_id_tbl(i).cust_account_id );
		  --p_cust_account_org      => l_party_id_tbl(i).cust_account_org );

-- Call update_for_customized_plans to do the update of the plan_id for all the parties
-- with the new plan_id that was customzied.
         CSC_CUST_PLANS_PVT.Update_for_customized_plans (
            P_Api_Version_Number         =>  1.0,
            P_Init_Msg_List              =>  FND_API.G_TRUE,
            P_Commit                     =>  p_commit,
            P_PLAN_ID                    =>  x_plan_id,
	       P_ORIGINAL_PLAN_ID           =>  p_csc_plan_headers_b_rec.original_plan_id,
	       P_PARTY_ID                   =>  l_party_id_tbl(i).party_id,
	       P_CUST_ACCOUNT_ID            =>  l_party_id_tbl(i).cust_account_id,
	       -- P_CUST_ACCOUNT_ORG           =>  l_party_id_tbl(i).cust_account_org,
		  P_OBJECT_VERSION_NUMBER      =>  l_party_id_tbl(i).object_version_number,
            X_OBJECT_VERSION_NUMBER      =>  x_cust_object_version_number,
            X_Return_Status              =>  x_return_status,
            X_Msg_Count                  =>  x_msg_count,
            X_Msg_Data                   =>  x_msg_data );
	    if ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) then
	       RAISE FND_API.G_EXC_ERROR;
	    end if;
      END LOOP;
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

End create_plan_header;


/*********** OVERLOADED PROCEDURE TO TAKE COLUMNS INSTEAD OF RECORD TYPE *******/

PROCEDURE update_plan_header(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_Validation_level           IN   NUMBER,
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
    P_OBJECT_VERSION_NUMBER      IN   NUMBER,
    P_DESCRIPTION                IN   VARCHAR2,
    P_NAME                       IN   VARCHAR2,
    P_PARTY_ID_TBL               IN   CSC_CUST_PLANS_PVT.CSC_PARTY_ID_TBL_TYPE,
    X_OBJECT_VERSION_NUMBER      OUT NOCOPY  NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
   l_pvt_csc_plan_headers_b_rec   CSC_PLAN_HEADERS_B_REC_TYPE;

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
      X_PVT_CSC_PLAN_HEADERS_B_REC => l_pvt_csc_plan_headers_b_rec );

/*** CALL PROCEDURE WITH RECORD TYPE STRUCTURE ***/
   update_plan_header(
      P_Api_Version_Number         => p_api_version_number,
      P_Init_Msg_List              => p_init_msg_list,
      P_Commit                     => p_commit,
      P_Validation_level           => p_validation_level,
      P_CSC_PLAN_HEADERS_B_REC     => l_pvt_csc_plan_headers_b_rec,
      P_DESCRIPTION                => p_description,
      P_NAME                       => p_name,
      P_PARTY_ID_TBL               => p_party_id_tbl,
      X_Object_Version_number      => x_object_version_number,
      X_Return_Status              => x_return_status,
      X_Msg_Count                  => x_msg_count,
      X_Msg_Data                   => x_msg_data );

END update_plan_header;


PROCEDURE Update_plan_header(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    p_validation_level           IN   NUMBER,
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
   Cursor c_get_csc_plan_headers( c_PLAN_ID Number ) IS
   Select rowid,                PLAN_ID,               ORIGINAL_PLAN_ID,
          PLAN_GROUP_CODE,      START_DATE_ACTIVE,     END_DATE_ACTIVE,
          USE_FOR_CUST_ACCOUNT, END_USER_TYPE,         CUSTOMIZED_PLAN,
          PROFILE_CHECK_ID,     RELATIONAL_OPERATOR,   CRITERIA_VALUE_HIGH,
          CRITERIA_VALUE_LOW,   CREATION_DATE,         LAST_UPDATE_DATE,
          CREATED_BY,           LAST_UPDATED_BY,       LAST_UPDATE_LOGIN,
          ATTRIBUTE1,           ATTRIBUTE2,            ATTRIBUTE3,
          ATTRIBUTE4,           ATTRIBUTE5,            ATTRIBUTE6,
          ATTRIBUTE7,           ATTRIBUTE8,            ATTRIBUTE9,
          ATTRIBUTE10,          ATTRIBUTE11,           ATTRIBUTE12,
          ATTRIBUTE13,          ATTRIBUTE14,           ATTRIBUTE15,
          ATTRIBUTE_CATEGORY,   OBJECT_VERSION_NUMBER, NAME,
		DESCRIPTION
   From   CSC_PLAN_HEADERS_VL
   where  plan_id = c_plan_id;

   l_api_name                CONSTANT VARCHAR2(30) := 'Update_plan_header';
   l_api_version_number      CONSTANT NUMBER       := 1.0;

-- Local Variables
   l_ref_PLAN_HEADER_rec     CSC_relationship_plans_PVT.CSC_PLAN_HEADERS_B_REC_TYPE;
   l_upd_plan_headers_b_rec  CSC_relationship_plans_PVT.CSC_PLAN_HEADERS_B_REC_TYPE :=
					    P_CSC_PLAN_HEADERS_B_REC;
   l_name                    VARCHAR2(90) := p_name;
   l_description             VARCHAR2(720):= p_description;
   l_rowid  ROWID;

    Cursor C_Get_cust_plans IS
        Select CUST_PLAN_ID, PARTY_ID, CUST_ACCOUNT_ID, OBJECT_VERSION_NUMBER
        From  CSC_CUST_PLANS
        WHERE PLAN_ID                 =  nvl(p_csc_plan_headers_b_rec.plan_id,      plan_id)
        AND plan_status_code not in ('MERGED', 'TRANSFERED') ORDER BY OBJECT_VERSION_NUMBER;
   l_ref_CSC_CUST_PLANS_rec  CSC_cust_plans_PVT.CSC_CUST_PLANS_Rec_Type;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT UPDATE_PLAN_HEADER_PVT;

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

   CSC_PLAN_HEADERS_B_PKG.LOCK_ROW(
	 P_PLAN_ID                 => p_csc_plan_headers_b_rec.plan_id,
	 P_OBJECT_VERSION_NUMBER   => p_csc_plan_headers_b_rec.OBJECT_VERSION_NUMBER );

   Open c_get_csc_plan_headers( p_csc_plan_headers_b_rec.PLAN_ID );

   Fetch c_get_csc_plan_headers into
         l_rowid,
         l_ref_PLAN_HEADER_rec.PLAN_ID,
         l_ref_PLAN_HEADER_rec.ORIGINAL_PLAN_ID,
         l_ref_PLAN_HEADER_rec.PLAN_GROUP_CODE,
         l_ref_PLAN_HEADER_rec.START_DATE_ACTIVE,
         l_ref_PLAN_HEADER_rec.END_DATE_ACTIVE,
         l_ref_PLAN_HEADER_rec.USE_FOR_CUST_ACCOUNT,
         l_ref_PLAN_HEADER_rec.END_USER_TYPE,
         l_ref_PLAN_HEADER_rec.CUSTOMIZED_PLAN,
         l_ref_PLAN_HEADER_rec.PROFILE_CHECK_ID,
         l_ref_PLAN_HEADER_rec.RELATIONAL_OPERATOR,
         l_ref_PLAN_HEADER_rec.CRITERIA_VALUE_HIGH,
         l_ref_PLAN_HEADER_rec.CRITERIA_VALUE_LOW,
         l_ref_PLAN_HEADER_rec.CREATION_DATE,
         l_ref_PLAN_HEADER_rec.LAST_UPDATE_DATE,
         l_ref_PLAN_HEADER_rec.CREATED_BY,
         l_ref_PLAN_HEADER_rec.LAST_UPDATED_BY,
         l_ref_PLAN_HEADER_rec.LAST_UPDATE_LOGIN,
         l_ref_PLAN_HEADER_rec.ATTRIBUTE1,
         l_ref_PLAN_HEADER_rec.ATTRIBUTE2,
         l_ref_PLAN_HEADER_rec.ATTRIBUTE3,
         l_ref_PLAN_HEADER_rec.ATTRIBUTE4,
         l_ref_PLAN_HEADER_rec.ATTRIBUTE5,
         l_ref_PLAN_HEADER_rec.ATTRIBUTE6,
         l_ref_PLAN_HEADER_rec.ATTRIBUTE7,
         l_ref_PLAN_HEADER_rec.ATTRIBUTE8,
         l_ref_PLAN_HEADER_rec.ATTRIBUTE9,
         l_ref_PLAN_HEADER_rec.ATTRIBUTE10,
         l_ref_PLAN_HEADER_rec.ATTRIBUTE11,
         l_ref_PLAN_HEADER_rec.ATTRIBUTE12,
         l_ref_PLAN_HEADER_rec.ATTRIBUTE13,
         l_ref_PLAN_HEADER_rec.ATTRIBUTE14,
         l_ref_PLAN_HEADER_rec.ATTRIBUTE15,
         l_ref_PLAN_HEADER_rec.ATTRIBUTE_CATEGORY,
         l_ref_PLAN_HEADER_rec.OBJECT_VERSION_NUMBER,
	    l_name,
	    l_description;

   If ( c_get_csc_plan_headers%NOTFOUND) Then
      --IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      --THEN
         FND_MESSAGE.Set_Name(CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'API_MISSING_UPDATE_TARGET');
         FND_MESSAGE.Set_Token ('INFO', 'csc_relationship_plans', FALSE);
         -- FND_MSG_PUB.Add;
      --END IF;
      Close c_get_csc_plan_headers;
      raise FND_API.G_EXC_ERROR;
   END IF;
   Close     c_get_csc_plan_headers;

   -- Check Whether record has been changed by someone else
   -- This check is not neccessary because we do the locking based on the plan_id and the
   -- object_version_number. This lock would fail if any other user updates the selected
   -- record because the object_version_number would be different.

   If (  P_CSC_PLAN_HEADERS_B_rec.object_version_number <>
         l_ref_PLAN_HEADER_rec.OBJECT_VERSION_NUMBER  )    THEN
      --IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
      --THEN
         FND_MESSAGE.Set_Name(CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'API_RECORD_CHANGED');
         FND_MESSAGE.Set_Token('INFO', 'csc_relationship_plans', FALSE);
         -- FND_MSG_PUB.ADD;
      --END IF;
      raise FND_API.G_EXC_ERROR;
   End if;

-- Get the final values of all the parameters that have to be passed into the table
-- handler update package; The decode is done here rather than in the update statement
-- of the table handler, because, when submitting the update sql. statement to the SGA,
-- we need to pass an identical update statement every time. This saves SGA space and
-- increases performance by using shared pool.

	 l_upd_plan_headers_b_rec.original_plan_id := CSC_CORE_UTILS_PVT.Get_G_Miss_Num(p_csc_plan_headers_b_rec.original_plan_id, l_ref_plan_header_rec.original_plan_id);

	 l_upd_plan_headers_b_rec.plan_group_code := CSC_CORE_UTILS_PVT.Get_G_Miss_Char(p_csc_plan_headers_b_rec.plan_group_code, l_ref_plan_header_rec.plan_group_code);

	 l_upd_plan_headers_b_rec.start_date_active := CSC_CORE_UTILS_PVT.Get_G_Miss_Date(p_csc_plan_headers_b_rec.start_date_active, l_ref_plan_header_rec.start_date_active);

	 l_upd_plan_headers_b_rec.end_date_active := CSC_CORE_UTILS_PVT.Get_G_Miss_Date(p_csc_plan_headers_b_rec.end_date_active, l_ref_plan_header_rec.end_date_active);

	 l_upd_plan_headers_b_rec.use_for_cust_account := p_csc_plan_headers_b_rec.use_for_cust_account;

	 l_upd_plan_headers_b_rec.end_user_type := CSC_CORE_UTILS_PVT.Get_G_Miss_Char(p_csc_plan_headers_b_rec.end_user_type, l_ref_plan_header_rec.end_user_type);

	 l_upd_plan_headers_b_rec.customized_plan := p_csc_plan_headers_b_rec.customized_plan;

	 l_upd_plan_headers_b_rec.profile_check_id := p_csc_plan_headers_b_rec.profile_check_id;

	 l_upd_plan_headers_b_rec.relational_operator := p_csc_plan_headers_b_rec.relational_operator;

	 l_upd_plan_headers_b_rec.criteria_value_high := CSC_CORE_UTILS_PVT.Get_G_Miss_Char(p_csc_plan_headers_b_rec.criteria_value_high, l_ref_plan_header_rec.criteria_value_high);

	 l_upd_plan_headers_b_rec.criteria_value_low := CSC_CORE_UTILS_PVT.Get_G_Miss_Char(p_csc_plan_headers_b_rec.criteria_value_low, l_ref_plan_header_rec.criteria_value_low);

	 l_upd_plan_headers_b_rec.attribute1 := CSC_CORE_UTILS_PVT.Get_G_Miss_Char(p_csc_plan_headers_b_rec.attribute1, l_ref_plan_header_rec.attribute1);

	 l_upd_plan_headers_b_rec.attribute2 := CSC_CORE_UTILS_PVT.Get_G_Miss_Char(p_csc_plan_headers_b_rec.attribute2, l_ref_plan_header_rec.attribute2);

	 l_upd_plan_headers_b_rec.attribute3 := CSC_CORE_UTILS_PVT.Get_G_Miss_Char(p_csc_plan_headers_b_rec.attribute3, l_ref_plan_header_rec.attribute3);

	 l_upd_plan_headers_b_rec.attribute4 := CSC_CORE_UTILS_PVT.Get_G_Miss_Char(p_csc_plan_headers_b_rec.attribute4, l_ref_plan_header_rec.attribute4);

	 l_upd_plan_headers_b_rec.attribute5 := CSC_CORE_UTILS_PVT.Get_G_Miss_Char(p_csc_plan_headers_b_rec.attribute5, l_ref_plan_header_rec.attribute5);

	 l_upd_plan_headers_b_rec.attribute6 := CSC_CORE_UTILS_PVT.Get_G_Miss_Char(p_csc_plan_headers_b_rec.attribute6, l_ref_plan_header_rec.attribute6);

	 l_upd_plan_headers_b_rec.attribute7 := CSC_CORE_UTILS_PVT.Get_G_Miss_Char(p_csc_plan_headers_b_rec.attribute7, l_ref_plan_header_rec.attribute7);

	 l_upd_plan_headers_b_rec.attribute8 := CSC_CORE_UTILS_PVT.Get_G_Miss_Char(p_csc_plan_headers_b_rec.attribute8, l_ref_plan_header_rec.attribute8);

	 l_upd_plan_headers_b_rec.attribute9 := CSC_CORE_UTILS_PVT.Get_G_Miss_Char(p_csc_plan_headers_b_rec.attribute9, l_ref_plan_header_rec.attribute9);

	 l_upd_plan_headers_b_rec.attribute10 := CSC_CORE_UTILS_PVT.Get_G_Miss_Char(p_csc_plan_headers_b_rec.attribute10, l_ref_plan_header_rec.attribute10);

	 l_upd_plan_headers_b_rec.attribute11 := CSC_CORE_UTILS_PVT.Get_G_Miss_Char(p_csc_plan_headers_b_rec.attribute11, l_ref_plan_header_rec.attribute11);

	 l_upd_plan_headers_b_rec.attribute12 := CSC_CORE_UTILS_PVT.Get_G_Miss_Char(p_csc_plan_headers_b_rec.attribute12, l_ref_plan_header_rec.attribute12);

	 l_upd_plan_headers_b_rec.attribute13 := CSC_CORE_UTILS_PVT.Get_G_Miss_Char(p_csc_plan_headers_b_rec.attribute13, l_ref_plan_header_rec.attribute13);

	 l_upd_plan_headers_b_rec.attribute14 := CSC_CORE_UTILS_PVT.Get_G_Miss_Char(p_csc_plan_headers_b_rec.attribute14, l_ref_plan_header_rec.attribute14);

	 l_upd_plan_headers_b_rec.attribute15 := CSC_CORE_UTILS_PVT.Get_G_Miss_Char(p_csc_plan_headers_b_rec.attribute15, l_ref_plan_header_rec.attribute15);

	 l_upd_plan_headers_b_rec.attribute_category := CSC_CORE_UTILS_PVT.Get_G_Miss_Char(p_csc_plan_headers_b_rec.attribute_category, l_ref_plan_header_rec.attribute_category);

   if ( p_name <> FND_API.G_MISS_CHAR ) then
	 l_name := p_name;
   end if;

   if ( p_description <> FND_API.G_MISS_CHAR ) then
	 l_description := p_description;
   else
	l_description := NULL;
   end if;

   IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL )
   THEN
      -- Invoke validation procedures
      Validate_csc_relationship_plan(
                p_init_msg_list           => FND_API.G_FALSE,
                p_validation_level        => p_validation_level,
                p_validation_mode         => CSC_CORE_UTILS_PVT.G_UPDATE,
                P_CSC_PLAN_HEADERS_B_REC  => L_UPD_PLAN_HEADERS_B_REC,
			 P_OLD_PLAN_HEADERS_B_REC  => l_ref_plan_header_rec,
                P_DESCRIPTION             => l_description,
                P_NAME                    => l_name,
                --P_PARTY_ID                => p_party_id,
	           --P_CUST_ACCOUNT_ID         => p_cust_account_id,
	           --P_CUST_ACCOUNT_ORG        => p_cust_account_org,
                x_return_status           => x_return_status,
                x_msg_count               => x_msg_count,
                x_msg_data                => x_msg_data);
   END IF;

   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Invoke table handler(CSC_PLAN_HEADERS_B_PKG.Update_Row)
   CSC_PLAN_HEADERS_B_PKG.Update_Row(
          p_PLAN_ID                => l_upd_plan_headers_b_rec.PLAN_ID,
          p_ORIGINAL_PLAN_ID       => l_upd_plan_headers_b_rec.ORIGINAL_PLAN_ID,
          p_PLAN_GROUP_CODE        => l_upd_plan_headers_b_rec.PLAN_GROUP_CODE,
          p_START_DATE_ACTIVE      => l_upd_plan_headers_b_rec.START_DATE_ACTIVE,
          p_END_DATE_ACTIVE        => l_upd_plan_headers_b_rec.END_DATE_ACTIVE,
          p_USE_FOR_CUST_ACCOUNT   => l_upd_plan_headers_b_rec.USE_FOR_CUST_ACCOUNT,
          p_END_USER_TYPE          => l_upd_plan_headers_b_rec.END_USER_TYPE,
          p_CUSTOMIZED_PLAN        => l_upd_plan_headers_b_rec.CUSTOMIZED_PLAN,
          p_PROFILE_CHECK_ID       => l_upd_plan_headers_b_rec.PROFILE_CHECK_ID,
          p_RELATIONAL_OPERATOR    => l_upd_plan_headers_b_rec.RELATIONAL_OPERATOR,
          p_CRITERIA_VALUE_HIGH    => l_upd_plan_headers_b_rec.CRITERIA_VALUE_HIGH,
          p_CRITERIA_VALUE_LOW     => l_upd_plan_headers_b_rec.CRITERIA_VALUE_LOW,
          p_LAST_UPDATE_DATE       => SYSDATE,
          p_LAST_UPDATED_BY        => FND_GLOBAL.USER_ID,
          p_LAST_UPDATE_LOGIN      => FND_GLOBAL.CONC_LOGIN_ID,
          p_ATTRIBUTE1             => l_upd_plan_headers_b_rec.ATTRIBUTE1,
          p_ATTRIBUTE2             => l_upd_plan_headers_b_rec.ATTRIBUTE2,
          p_ATTRIBUTE3             => l_upd_plan_headers_b_rec.ATTRIBUTE3,
          p_ATTRIBUTE4             => l_upd_plan_headers_b_rec.ATTRIBUTE4,
          p_ATTRIBUTE5             => l_upd_plan_headers_b_rec.ATTRIBUTE5,
          p_ATTRIBUTE6             => l_upd_plan_headers_b_rec.ATTRIBUTE6,
          p_ATTRIBUTE7             => l_upd_plan_headers_b_rec.ATTRIBUTE7,
          p_ATTRIBUTE8             => l_upd_plan_headers_b_rec.ATTRIBUTE8,
          p_ATTRIBUTE9             => l_upd_plan_headers_b_rec.ATTRIBUTE9,
          p_ATTRIBUTE10            => l_upd_plan_headers_b_rec.ATTRIBUTE10,
          p_ATTRIBUTE11            => l_upd_plan_headers_b_rec.ATTRIBUTE11,
          p_ATTRIBUTE12            => l_upd_plan_headers_b_rec.ATTRIBUTE12,
          p_ATTRIBUTE13            => l_upd_plan_headers_b_rec.ATTRIBUTE13,
          p_ATTRIBUTE14            => l_upd_plan_headers_b_rec.ATTRIBUTE14,
          p_ATTRIBUTE15            => l_upd_plan_headers_b_rec.ATTRIBUTE15,
          p_ATTRIBUTE_CATEGORY     => l_upd_plan_headers_b_rec.ATTRIBUTE_CATEGORY,
          P_DESCRIPTION            => l_description,
          P_NAME                   => l_name,
          X_OBJECT_VERSION_NUMBER  => x_object_version_number );

-- if customized_plans is updated from 'Y' to 'N' then delete the customer-plan
-- relationship in CSC_CUSTOMIZED_PLANS table.
-- Do not delete records from the CSC_CUST_PLANS table, because the only thing
-- happening here is removing the customization part of the plan to the customer
-- and making the plan available to all other eligible customers. The customer
-- may still be assigned to the plan.

   if (      l_ref_plan_header_rec.customized_plan    = 'Y'
	   and  p_csc_plan_headers_b_rec.customized_plan = 'N' ) then
	 delete from csc_customized_plans
	 where  plan_id = p_csc_plan_headers_b_rec.plan_id;
   end if;

-- if plan header end_date_active was null and is updated, update the end_date_active
-- in CSC_CUST_PLANS table for all customers associated to this plan.
-- as per bug# 2250056, first condition is taken out, even the old date not null, user is
-- allowed to change the end date to any future date to extend the plan
-- also party_id, cust_plan_id, cust_account_id and object_version_number, otherwise
-- update fails
-- check for the existing and the new date, before update
-- Fixed bug# 2805474, update Start_Date_Active

--	if ( p_csc_plan_headers_b_rec.end_date_active >= TRUNC (SYSDATE) ) then

--	if (      l_ref_plan_header_rec.end_date_active    is null ) or
   if ( l_ref_plan_header_rec.end_date_active <> p_csc_plan_headers_b_rec.end_date_active ) or
   ( l_ref_plan_header_rec.start_date_active <> p_csc_plan_headers_b_rec.start_date_active ) then

    Open C_Get_cust_plans;

    LOOP

    Fetch C_Get_cust_plans into
               l_ref_CSC_CUST_PLANS_rec.CUST_PLAN_ID,
               l_ref_CSC_CUST_PLANS_rec.PARTY_ID,
               l_ref_CSC_CUST_PLANS_rec.CUST_ACCOUNT_ID,
               l_ref_CSC_CUST_PLANS_rec.OBJECT_VERSION_NUMBER;

    Exit when C_Get_cust_plans%NOTFOUND;

      CSC_CUST_PLANS_PVT.UPDATE_CUST_PLANS (
          P_Api_Version_Number         =>   p_api_version_number,
          P_Init_Msg_List              =>   p_init_msg_list,
          P_Commit                     =>   p_commit,
          p_Validation_Level           =>   FND_API.G_VALID_LEVEL_NONE,
          P_PLAN_ID                    =>   p_csc_plan_headers_b_rec.plan_id,
          P_CUST_PLAN_ID               =>   l_ref_CSC_CUST_PLANS_rec.CUST_PLAN_ID,
          P_PARTY_ID                   =>   l_ref_CSC_CUST_PLANS_rec.PARTY_ID,
          P_CUST_ACCOUNT_ID            =>   l_ref_CSC_CUST_PLANS_rec.CUST_ACCOUNT_ID,
	     p_start_date_active            =>   p_csc_plan_headers_b_rec.start_date_active,
	     p_end_date_active            =>   p_csc_plan_headers_b_rec.end_date_active,
          P_OBJECT_VERSION_NUMBER      =>   l_ref_CSC_CUST_PLANS_rec.OBJECT_VERSION_NUMBER,
          X_Object_Version_number      =>   x_object_version_number,
          X_Return_Status              =>   x_return_status,
          X_Msg_Count                  =>   x_msg_count,
          X_Msg_Data                   =>   x_msg_data );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      END LOOP;

      Close  C_Get_cust_plans;

   end if;

 --  end if;


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
End Update_plan_header;


PROCEDURE Disable_plan(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_plan_id                    IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
   cursor c1 is
	 select cust_plan_id, party_id, cust_account_id, -- cust_account_org,
		   object_version_number
	 from   csc_cust_plans
	 where  plan_id = p_plan_id;

   c1rec     c1%rowtype;

   l_api_name                CONSTANT VARCHAR2(30) := 'Disable_plan';
   l_api_version_number      CONSTANT NUMBER       := 1.0;
   x_object_version_number   NUMBER;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT Disable_plan_pvt;

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

   -- Invoke table handler(CSC_PLAN_HEADERS_B_PKG.Disable_Row)
   CSC_PLAN_HEADERS_B_PKG.Disable_Row(
         p_PLAN_ID  => p_PLAN_ID);

   -- Change the end_date_active of the CSC_CUST_PLANS table to sysdate+1 for all records
   -- with this plan_id. The plan assignment engine will then check all records with
   -- end_date not valid and delete the records.

   open c1;
   loop
      fetch c1 into c1rec;
	 exit when c1%notfound;

      CSC_CUST_PLANS_PVT.UPDATE_CUST_PLANS (
          P_Api_Version_Number         =>   p_api_version_number,
          P_Init_Msg_List              =>   p_init_msg_list,
          P_Commit                     =>   p_commit,
          p_Validation_Level           =>   FND_API.G_VALID_LEVEL_NONE,
		p_CUST_PLAN_ID               =>   c1rec.cust_plan_id,
          P_PLAN_ID                    =>   p_plan_id,
	     p_end_date_active            =>   sysdate+1,
		p_party_id                   =>   c1rec.party_id,
		p_cust_account_id            =>   c1rec.cust_account_id,
		-- p_cust_account_org           =>   c1rec.cust_account_org,
		p_object_version_number      =>   c1rec.object_version_number,
          X_Object_Version_number      =>   x_object_version_number,
          X_Return_Status              =>   x_return_status,
          X_Msg_Count                  =>   x_msg_count,
          X_Msg_Data                   =>   x_msg_data );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	    close c1;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

   end loop;
   close c1;

   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
   (  p_encoded        =>   FND_API.G_FALSE,
	 p_count          =>   x_msg_count,
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
End Disable_plan;


-- Item-level validation procedures
PROCEDURE Validate_PLAN_ID (
   P_Init_Msg_List              IN   VARCHAR2,
   P_Validation_mode            IN   VARCHAR2,
   P_PLAN_ID                    IN   NUMBER,
   X_Return_Status              OUT NOCOPY  VARCHAR2,
   X_Msg_Count                  OUT NOCOPY  NUMBER,
   X_Msg_Data                   OUT NOCOPY  VARCHAR2
   )
IS
   cursor check_dup_plan_id is
   select plan_id
   from   CSC_PLAN_HEADERS_B
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

   -- validate NOT NULL column.
   if (p_validation_mode = CSC_CORE_UTILS_PVT.G_UPDATE) then
      IF(p_PLAN_ID is NULL or p_plan_id = FND_API.G_MISS_NUM) then
--         fnd_message.set_name (CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'CS_API_ALL_NULL_PARAMETER');
         fnd_message.set_name ('CS', 'CS_API_ALL_NULL_PARAMETER');
         fnd_message.set_token ('API_NAME', G_PKG_NAME||'.'|| l_api_name);
         fnd_message.set_token('NULL_PARAM', 'PLAN_ID');
         -- fnd_msg_pub.add;
         x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
   end if;

   -- validate for duplicate plan_ids.
   IF (p_validation_mode = CSC_CORE_UTILS_PVT.G_CREATE)
   THEN
      open check_dup_plan_id;
      fetch check_dup_plan_id into l_plan_id;
      if check_dup_plan_id%FOUND then
--         fnd_message.set_name (CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'CS_API_ALL_DUPLICATE_VALUE');
         fnd_message.set_name ('CS', 'CS_API_ALL_DUPLICATE_VALUE');
         fnd_message.set_token ('API_NAME', G_PKG_NAME||'.'|| l_api_name);
         fnd_message.set_token('DUPLICATE_VAL_PARAM', 'PLAN_ID');
         -- fnd_msg_pub.add;
         x_return_status := FND_API.G_RET_STS_ERROR;
      end if;
      close check_dup_plan_id;
   END IF;

   if ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
      APP_EXCEPTION.RAISE_EXCEPTION;
   end if;

END Validate_PLAN_ID;


PROCEDURE Validate_NAME (
    P_Init_Msg_List              IN   VARCHAR2,
    P_Validation_mode            IN   VARCHAR2,
    P_PLAN_ID                    IN   NUMBER,
    P_NAME                       IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
   cursor check_dup_plan_name is
      select plan_id
      from   CSC_PLAN_HEADERS_VL
      where  name = p_name;

   l_plan_id    NUMBER;
   l_api_name   varchar2(30) := 'Validate_Name';
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- validate NOT NULL column
      IF(p_NAME is NULL or p_name = FND_API.G_MISS_CHAR) then
--         fnd_message.set_name (CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'CS_API_ALL_NULL_PARAMETER');
         fnd_message.set_name ('CS', 'CS_API_ALL_NULL_PARAMETER');
         fnd_message.set_token ('API_NAME', G_PKG_NAME||'.'||l_api_name);
         fnd_message.set_token('NULL_PARAM', 'PLAN_NAME');
         -- fnd_msg_pub.add;
         x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      -- validate for duplicate plan_names.
      if ( x_return_status = FND_API.G_RET_STS_SUCCESS ) then
         if p_validation_mode = CSC_CORE_UTILS_PVT.G_CREATE then
            l_plan_id := 0;
         else
            l_plan_id := p_plan_id;
         end if;

         open  check_dup_plan_name;
         fetch check_dup_plan_name into l_plan_id;
         close check_dup_plan_name;

         if (p_validation_mode = CSC_CORE_UTILS_PVT.G_CREATE and l_plan_id <> 0 ) then
--            fnd_message.set_name (CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'CS_API_ALL_DUPLICATE_VALUE');
--            fnd_message.set_name ('CS', 'CS_API_ALL_DUPLICATE_VALUE');
--            fnd_message.set_token ('API_NAME', G_PKG_NAME||'.'|| l_api_name);
--            fnd_message.set_token('DUPLICATE_VAL_PARAM', 'PLAN_NAME');
            -- fnd_msg_pub.add;
            fnd_message.set_name ('CSC', 'CSC_RSP_DUPLICATE_NAME');
            x_return_status := FND_API.G_RET_STS_ERROR;
         else
	       if ( p_validation_mode = CSC_CORE_UTILS_PVT.G_UPDATE and
                 l_plan_id        <> p_plan_id ) then  -- some other plan exists with this name
--               fnd_message.set_name (CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'CS_API_ALL_DUPLICATE_VALUE');
               fnd_message.set_name ('CS', 'CS_API_ALL_DUPLICATE_VALUE');
               fnd_message.set_token ('API_NAME', G_PKG_NAME||'.'|| l_api_name);
               fnd_message.set_token('DUPLICATE_VAL_PARAM', 'PLAN_NAME');
               -- fnd_msg_pub.add;
               x_return_status := FND_API.G_RET_STS_ERROR;
            end if;
         end if;
      end if;

	 if ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
	    APP_EXCEPTION.RAISE_EXCEPTION;
      end if;

END Validate_NAME;


PROCEDURE Validate_ORIGINAL_PLAN_ID (
    P_Init_Msg_List              IN   VARCHAR2,
    P_Validation_mode            IN   VARCHAR2,
    P_PLAN_ID                    IN   NUMBER,
    P_ORIGINAL_PLAN_ID           IN   NUMBER,
    P_CUSTOMIZED_PLAN            IN   VARCHAR2     := 'N',
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
   cursor chk_original_plan_id is
      select plan_id
      from   CSC_PLAN_HEADERS_B
      where  plan_id = p_original_plan_id;

   l_plan_id     number;
   l_api_name    varchar2(30) := 'Validate_Original_Plan_Id';
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- validate NOT NULL column
      IF ( p_original_plan_id is NULL or p_original_plan_id = FND_API.G_MISS_NUM ) THEN
	    IF ( p_validation_mode = CSC_CORE_UTILS_PVT.G_UPDATE ) OR
		  ( p_validation_mode = CSC_CORE_UTILS_PVT.G_CREATE AND
		    p_customized_plan = 'Y' )
         THEN
--            fnd_message.set_name (CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'CS_API_ALL_NULL_PARAMETER');
            fnd_message.set_name ('CS', 'CS_API_ALL_NULL_PARAMETER');
            fnd_message.set_token ('API_NAME', G_PKG_NAME||'.'||l_api_name);
            fnd_message.set_token('NULL_PARAM', 'ORIGINAL_PLAN_ID');
            -- fnd_msg_pub.add;
            x_return_status := FND_API.G_RET_STS_ERROR;
            APP_EXCEPTION.RAISE_EXCEPTION;
         END IF;
      END IF;

      IF ( p_original_plan_id is not NULL and p_original_plan_id <> FND_API.G_MISS_NUM ) THEN
	    open  chk_original_plan_id;
	    fetch chk_original_plan_id into l_plan_id;
	    if ( chk_original_plan_id%notfound ) then
--            fnd_message.set_name (CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'CS_API_ALL_INVALID_ARGUMENT');
            fnd_message.set_name ('CS', 'CS_API_ALL_INVALID_ARGUMENT');
            fnd_message.set_token ('API_NAME', G_PKG_NAME||'.'||l_api_name);
            fnd_message.set_token('VALUE', p_original_plan_id);
            fnd_message.set_token('PARAMETER', 'ORIGINAL_PLAN_ID');
            x_return_status := FND_API.G_RET_STS_ERROR;
         end if;
	    close chk_original_plan_id;
      END IF;

      if ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
         APP_EXCEPTION.RAISE_EXCEPTION;
      end if;

END Validate_ORIGINAL_PLAN_ID;

PROCEDURE Validate_PLAN_GROUP_CODE (
    P_Init_Msg_List              IN   VARCHAR2,
    P_Validation_mode            IN   VARCHAR2,
    P_PLAN_GROUP_CODE            IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
   cursor group_in_lookup is
      select count(*)
      from   fnd_lookups
      where  lookup_code = p_PLAN_GROUP_CODE
      and    sysdate between nvl(start_date_active, sysdate)
                         and nvl(end_date_active, sysdate);

   l_rec_count    NUMBER  := 0;
   l_api_name     varchar2(30) := 'Validate_Plan_Group_Code';
BEGIN
   NULL;
/**********  commented out; change to make plan_group NULLABLE
01-26-2000
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- validate NOT NULL column
      IF (p_PLAN_GROUP_CODE is NULL or p_PLAN_GROUP_CODE = FND_API.G_MISS_CHAR) then
--          fnd_message.set_name (CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'CS_API_ALL_NULL_PARAMETER');
          fnd_message.set_name ('CS', 'CS_API_ALL_NULL_PARAMETER');
          fnd_message.set_token ('API_NAME', G_PKG_NAME||'.'||l_api_name);
          fnd_message.set_token('NULL_PARAM', 'PLAN_GROUP_CODE');
          -- fnd_msg_pub.add;
          x_return_status := FND_API.G_RET_STS_ERROR;
      else
         -- validate PLAN_GROUP_CODE exists in fnd_lookup_values.
         open group_in_lookup;
         fetch group_in_lookup into l_rec_count;
         close group_in_lookup;

         if ( l_rec_count = 0 ) then
--            fnd_message.set_name (CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'CS_API_ALL_INVALID_ARGUMENT');
            fnd_message.set_name ('CS', 'CS_API_ALL_INVALID_ARGUMENT');
            fnd_message.set_token ('API_NAME', G_PKG_NAME||'.'||l_api_name);
            fnd_message.set_token('VALUE', p_plan_group_code);
            fnd_message.set_token('PARAMETER', 'PLAN_GROUP_CODE');
            -- fnd_msg_pub.add;
            x_return_status := FND_API.G_RET_STS_ERROR;
         end if;
      --end if;

      if ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
         APP_EXCEPTION.RAISE_EXCEPTION;
      end if;
*********  commented out; change to make plan_group NULLABLE  */

END Validate_PLAN_GROUP_CODE;


PROCEDURE Validate_USE_FOR_CUST_ACCOUNT (
    P_Init_Msg_List              IN   VARCHAR2,
    P_Validation_mode            IN   VARCHAR2,
    P_PLAN_ID                    IN   NUMBER,
    P_USE_FOR_CUST_ACCOUNT       IN   VARCHAR2,
    P_OLD_USE_FOR_CUST_ACCOUNT   IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
   cursor c1 is
      select count(*)
      from   csc_cust_plans
      where  plan_id = p_plan_id;

   l_rec_count  number := 0;
   l_api_name   varchar2(30) := 'Validate_Use_For_Cust_Account';
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- validate NOT NULL column
      IF (  p_use_for_cust_account is NULL or p_use_for_cust_account = FND_API.G_MISS_CHAR ) then
--         fnd_message.set_name (CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'CS_API_ALL_NULL_PARAMETER');
         fnd_message.set_name ('CS', 'CS_API_ALL_NULL_PARAMETER');
         fnd_message.set_token ('API_NAME', G_PKG_NAME||'.'||l_api_name);
         fnd_message.set_token('NULL_PARAM', 'USE_FOR_CUST_ACCOUNT');
         -- fnd_msg_pub.add;
         x_return_status := FND_API.G_RET_STS_ERROR;
      ELSIF ( p_use_for_cust_account <> 'Y' and p_use_for_cust_account <> 'N' ) then
--         fnd_message.set_name (CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'CS_API_ALL_INVALID_ARGUMENT');
         fnd_message.set_name ('CS', 'CS_API_ALL_INVALID_ARGUMENT');
         fnd_message.set_token ('API_NAME', G_PKG_NAME||'.'||l_api_name);
         fnd_message.set_token('VALUE', p_use_for_cust_account);
         fnd_message.set_token('PARAMETER', 'USE_FOR_CUST_ACCOUNT');
         -- fnd_msg_pub.add;
         x_return_status := FND_API.G_RET_STS_ERROR;
      ELSIF ( p_validation_mode = CSC_CORE_UTILS_PVT.G_UPDATE ) then
	    if ( p_use_for_cust_account <> p_old_use_for_cust_account ) then
            -- Check if there are any existing customer-to-plan associations for this particular
	       -- PLAN_ID. If ther are, then do not allow the update on the column.
	       open c1;
	       fetch c1 into l_rec_count;
	       close c1;
	       if ( l_rec_count <> 0 ) then
	       -- Use_for_cust_account cannot be updated. There are existing customers
	       -- associated to this plan.
--               fnd_message.set_name (CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'CS_ALL_UPDATE_NOT_ALLOWED');
--               fnd_message.set_name ('CS', 'CS_ALL_UPDATE_NOT_ALLOWED');
-- Fixed bug# 3319977
               fnd_message.set_name ('CSC', 'CSC_RSP_INVALID_UPDATE');
               fnd_message.set_token('UPDATE_PARAM', 'PLAN_LEVEL');
               -- fnd_msg_pub.add;
	          x_return_status := FND_API.G_RET_STS_ERROR;
	       end if;
         end if;
      END IF;

      if ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
         APP_EXCEPTION.RAISE_EXCEPTION;
      end if;

END Validate_USE_FOR_CUST_ACCOUNT;

PROCEDURE Validate_END_USER_TYPE (
    P_Init_Msg_List              IN   VARCHAR2,
    P_Validation_mode            IN   VARCHAR2,
    P_END_USER_TYPE              IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
   cursor type_in_lookup is
      select count(*)
      from   csc_lookups
      where  lookup_type = 'CSC_END_USER_TYPE'
      and    lookup_code = P_END_USER_TYPE
      and    sysdate between nvl(start_date_active, sysdate)
                         and nvl(end_date_active, sysdate);

--      from   fnd_lookups
   l_rec_count    NUMBER  := 0;
   l_api_name     varchar2(30) := 'Validate_End_User_Type';
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_END_USER_TYPE is NULL or p_END_USER_TYPE = FND_API.G_MISS_CHAR) then
	 return;
      else
         -- validate PLAN_GROUP_CODE exists in fnd_lookup_values.
         open  type_in_lookup;
         fetch type_in_lookup into l_rec_count;
         close type_in_lookup;

         if ( l_rec_count = 0 ) then
--            fnd_message.set_name (CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'CS_API_ALL_INVALID_ARGUMENT');
            fnd_message.set_name ('CS', 'CS_API_ALL_INVALID_ARGUMENT');
            fnd_message.set_token ('API_NAME', G_PKG_NAME||'.'||l_api_name);
            fnd_message.set_token('VALUE', p_end_user_type);
            fnd_message.set_token('PARAMETER', 'END_USER_TYPE');
            x_return_status := FND_API.G_RET_STS_ERROR;
         end if;
      end if;

      if ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
         APP_EXCEPTION.RAISE_EXCEPTION;
      end if;

END Validate_END_USER_TYPE;

PROCEDURE Validate_CUSTOMIZED_PLAN (
    P_Init_Msg_List              IN   VARCHAR2,
    P_Validation_mode            IN   VARCHAR2,
    P_CUSTOMIZED_PLAN            IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
   l_api_name   varchar2(30) := 'Validate_Customized_Plan';
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- validate NOT NULL column
      IF( p_CUSTOMIZED_PLAN is NULL or p_customized_plan = FND_API.G_MISS_CHAR ) then
--         fnd_message.set_name (CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'CS_API_ALL_NULL_PARAMETER');
         fnd_message.set_name ('CS', 'CS_API_ALL_NULL_PARAMETER');
         fnd_message.set_token ('API_NAME', G_PKG_NAME||'.'||l_api_name);
         fnd_message.set_token('NULL_PARAM', 'CUSTOMIZED_PLAN');
         x_return_status := FND_API.G_RET_STS_ERROR;
      ELSIF ( p_customized_plan <> 'Y' and p_customized_plan <> 'N' ) then
--         fnd_message.set_name (CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'CS_API_ALL_INVALID_ARGUMENT');
         fnd_message.set_name ('CS', 'CS_API_ALL_INVALID_ARGUMENT');
         fnd_message.set_token ('API_NAME', G_PKG_NAME||'.'||l_api_name);
         fnd_message.set_token('VALUE', p_customized_plan);
         fnd_message.set_token('PARAMETER', 'CUSTOMIZED_PLAN');
         -- fnd_msg_pub.add;
         x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      if ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
         APP_EXCEPTION.RAISE_EXCEPTION;
      end if;

END Validate_CUSTOMIZED_PLAN;

PROCEDURE Validate_PROFILE_CHECK_ID (
    P_Init_Msg_List              IN   VARCHAR2,
    P_Validation_mode            IN   VARCHAR2,
    P_PLAN_ID                    IN   NUMBER,
    P_PROFILE_CHECK_ID           IN   NUMBER,
    P_OLD_PROFILE_CHECK_ID       IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
   cursor id_in_prof_checks is
   select count(*)
   from   csc_prof_checks_b
   where  check_id = p_profile_check_id
   and    sysdate between nvl(start_date_active, sysdate)
                      and nvl(end_date_active, sysdate);

   cursor c1 is
      select count(*)
      from   csc_cust_plans
      where  plan_id = p_plan_id;

   l_rec_count    number := 0;
   l_api_name     varchar2(30) := 'Validate_Profile_Check_Id';
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- validate NOT NULL column
      IF(p_PROFILE_CHECK_ID is NULL or p_profile_check_id = FND_API.G_MISS_NUM) then
--         fnd_message.set_name (CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'CS_API_ALL_NULL_PARAMETER');
         fnd_message.set_name ('CS', 'CS_API_ALL_NULL_PARAMETER');
         fnd_message.set_token ('API_NAME', G_PKG_NAME||'.'||l_api_name);
         fnd_message.set_token('NULL_PARAM', 'PROFILE_CHECK_ID');
         -- fnd_msg_pub.add;
         x_return_status := FND_API.G_RET_STS_ERROR;
      ELSIF ( p_validation_mode = CSC_CORE_UTILS_PVT.G_UPDATE AND
		    p_profile_check_id <> p_old_profile_check_id ) then
         --if ( G_CUST_PLANS_REC_CNT = FND_API.G_MISS_NUM ) then
	       open c1;
	       fetch c1 into l_rec_count;
	       close c1;
         --end if;
	    if ( l_rec_count <> 0 ) then
	    -- Profile check id cannot be updated. There are customers attached to this plan.
--            fnd_message.set_name (CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'CS_ALL_UPDATE_NOT_ALLOWED');
--            fnd_message.set_name ('CS', 'CS_ALL_UPDATE_NOT_ALLOWED');
-- Fixed bug# 3319977
               fnd_message.set_name ('CSC', 'CSC_RSP_INVALID_UPDATE');
               fnd_message.set_token('UPDATE_PARAM', 'PROFILE_CHECK_ID');
	       x_return_status := FND_API.G_RET_STS_ERROR;
         end if;
      END IF;

	 IF ( x_return_status = FND_API.G_RET_STS_SUCCESS ) then
         -- validate PROFILE_CHECK_ID exists in fnd_lookup_values.
	    if ( ( p_validation_mode = CSC_CORE_UTILS_PVT.G_UPDATE AND
		      p_profile_check_id <> p_old_profile_check_id ) OR
		    p_validation_mode = CSC_CORE_UTILS_PVT.G_CREATE )
	    then
            open id_in_prof_checks;
            fetch id_in_prof_checks into l_rec_count;
            close id_in_prof_checks;

            if ( l_rec_count = 0 or l_rec_count > 1 ) then
	       -- Profile check id is not a valid condition id.
--               fnd_message.set_name (CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'CS_API_ALL_INVALID_ARGUMENT');
               fnd_message.set_name ('CS', 'CS_API_ALL_INVALID_ARGUMENT');
               fnd_message.set_token ('API_NAME', G_PKG_NAME||'.'||l_api_name);
               fnd_message.set_token('VALUE', p_profile_check_id);
               fnd_message.set_token('PARAMETER', 'PROFILE_CHECK_ID');
               -- fnd_msg_pub.add;
	          x_return_status := FND_API.G_RET_STS_ERROR;
            end if;
         end if;
      END IF;
      if ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
         APP_EXCEPTION.RAISE_EXCEPTION;
      end if;

END Validate_PROFILE_CHECK_ID;

PROCEDURE Validate_CRITERIA_VALUE_LOW (
    P_Init_Msg_List              IN   VARCHAR2,
    P_Validation_mode            IN   VARCHAR2,
    P_PLAN_ID                    IN   NUMBER,
    P_CRITERIA_VALUE_LOW         IN   VARCHAR2,
    P_OLD_CRITERIA_VALUE_LOW     IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
   cursor c1 is
      select count(*)
      from   csc_cust_plans
      where  plan_id = p_plan_id;

   l_rec_count    number := 0;
   l_api_name     varchar2(30) := 'Validate_Criteria_Value_Low';
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- validate NOT NULL column
      --IF(p_CRITERIA_VALUE_LOW is NULL or p_CRITERIA_VALUE_LOW = FND_API.G_MISS_CHAR ) then
         --fnd_message.set_name (CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'CS_API_ALL_NULL_PARAMETER');
         --fnd_message.set_token ('API_NAME', G_PKG_NAME||'.'||l_api_name);
         --fnd_message.set_token('NULL_PARAM', 'CRITERIA_VALUE_LOW');
         -- fnd_msg_pub.add;
         --x_return_status := FND_API.G_RET_STS_ERROR;
      IF ( p_validation_mode = CSC_CORE_UTILS_PVT.G_UPDATE AND
		 p_criteria_value_low <> p_old_criteria_value_low ) then
         --if ( G_CUST_PLANS_REC_CNT = FND_API.G_MISS_NUM ) then
	       open c1;
	       fetch c1 into l_rec_count;
	       close c1;
         --end if;
	    if ( l_rec_count <> 0 ) then
	    -- Criteria_value_low cannot be updated. There are customers attached to this plan.
--            fnd_message.set_name (CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'CS_ALL_UPDATE_NOT_ALLOWED');
--            fnd_message.set_name ('CS', 'CS_ALL_UPDATE_NOT_ALLOWED');
-- Fixed bug# 3319977
               fnd_message.set_name ('CSC', 'CSC_RSP_INVALID_UPDATE');
               fnd_message.set_token('UPDATE_PARAM', 'CRITERIA_VALUE_LOW');
	       x_return_status := FND_API.G_RET_STS_ERROR;
         end if;
      END IF;

      if ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
         APP_EXCEPTION.RAISE_EXCEPTION;
      end if;

END Validate_CRITERIA_VALUE_LOW;

PROCEDURE Validate_CRITERIA_VALUE_HIGH (
    P_Init_Msg_List              IN   VARCHAR2,
    P_Validation_mode            IN   VARCHAR2,
    P_PLAN_ID                    IN   NUMBER,
    P_CRITERIA_VALUE_HIGH        IN   VARCHAR2,
    P_OLD_CRITERIA_VALUE_HIGH    IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
   cursor c1 is
      select count(*)
      from   csc_cust_plans
      where  plan_id = p_plan_id;

   l_rec_count    number := 0;
   l_api_name     varchar2(30) := 'Validate_Criteria_Value_High';
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF ( p_validation_mode = CSC_CORE_UTILS_PVT.G_UPDATE AND
		 nvl(p_criteria_value_high,0) <> nvl(p_old_criteria_value_high,0) ) then
         --if ( G_CUST_PLANS_REC_CNT = FND_API.G_MISS_NUM ) then
	       open c1;
	       fetch c1 into l_rec_count;
	       close c1;
         --end if;
	    if ( l_rec_count <> 0 ) then
	    -- Criteria_value_high cannot be updated. There are customers attached to this plan.
--            fnd_message.set_name (CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'CS_ALL_UPDATE_NOT_ALLOWED');
--            fnd_message.set_name ('CS', 'CS_ALL_UPDATE_NOT_ALLOWED');
-- Fixed bug# 3319977
               fnd_message.set_name ('CSC', 'CSC_RSP_INVALID_UPDATE');
               fnd_message.set_token('UPDATE_PARAM', 'CRITERIA_VALUE_HIGH');
	       x_return_status := FND_API.G_RET_STS_ERROR;
         end if;
      END IF;

      if ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
         APP_EXCEPTION.RAISE_EXCEPTION;
      end if;

END Validate_CRITERIA_VALUE_HIGH;

PROCEDURE Validate_RELATIONAL_OPERATOR (
    P_Init_Msg_List              IN   VARCHAR2,
    P_Validation_mode            IN   VARCHAR2,
    P_PLAN_ID                    IN   NUMBER,
    P_RELATIONAL_OPERATOR        IN   VARCHAR2,
    P_OLD_RELATIONAL_OPERATOR    IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
   cursor c1 is
      select count(*)
      from   csc_cust_plans
      where  plan_id = p_plan_id;

   l_rec_count    number := 0;
   l_api_name     varchar2(30) := 'Validate_Relational_Operator';
BEGIN

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- validate NOT NULL column
      IF(p_RELATIONAL_OPERATOR is NULL or p_RELATIONAL_OPERATOR = FND_API.G_MISS_CHAR ) then
--         fnd_message.set_name (CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'CS_API_ALL_NULL_PARAMETER');
         fnd_message.set_name ('CS', 'CS_API_ALL_NULL_PARAMETER');
         fnd_message.set_token ('API_NAME', G_PKG_NAME||'.'||l_api_name);
         fnd_message.set_token('NULL_PARAM', 'RELATIONAL_OPERATOR');
         -- fnd_msg_pub.add;
         x_return_status := FND_API.G_RET_STS_ERROR;
      ELSIF ( p_validation_mode = CSC_CORE_UTILS_PVT.G_UPDATE AND
		    p_relational_operator <> p_old_relational_operator ) then
         --if ( G_CUST_PLANS_REC_CNT = FND_API.G_MISS_NUM ) then
	       open c1;
	       fetch c1 into l_rec_count;
	       close c1;
         --end if;
	    if ( l_rec_count <> 0 ) then
	    -- Relational_operator cannot be updated. There are customers attached to this plan.
--            fnd_message.set_name (CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'CS_ALL_UPDATE_NOT_ALLOWED');
--            fnd_message.set_name ('CS', 'CS_ALL_UPDATE_NOT_ALLOWED');
-- Fixed bug# 3319977
               fnd_message.set_name ('CSC', 'CSC_RSP_INVALID_UPDATE');
               fnd_message.set_token('UPDATE_PARAM', 'RELATIONAL_OPERATOR');
	       x_return_status := FND_API.G_RET_STS_ERROR;
         end if;
      END IF;

      if ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
         APP_EXCEPTION.RAISE_EXCEPTION;
      end if;

END Validate_RELATIONAL_OPERATOR;

PROCEDURE Validate_Plan_Criteria (
    P_Init_Msg_List              IN   VARCHAR2,
    P_Validation_mode            IN   VARCHAR2,
    P_PLAN_ID                    IN   NUMBER,
    P_RELATIONAL_OPERATOR        IN   VARCHAR2,
    P_CRITERIA_VALUE_LOW         IN   VARCHAR2,
    P_CRITERIA_VALUE_HIGH        IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
   l_api_name     varchar2(30) := 'Validate_Plan_Criteria';
BEGIN
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
       FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF ( p_relational_operator =  '='      OR
	   p_relational_operator =  '<>'     OR
	   p_relational_operator =  '>'      OR
	   p_relational_operator =  '<'      OR
	   p_relational_operator =  '>='     OR
	   p_relational_operator =  '<='     OR
	   p_relational_operator =  'LIKE'   OR
	   p_relational_operator =  'NOT LIKE' )
   THEN
	 if ( p_criteria_value_low IS NULL AND p_criteria_value_high IS NOT NULL ) then
	    -- Error in plan criteria. Criteria value low should be specified and criteria
	    -- value high should not be specified.
--         fnd_message.set_name (CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'CS_API_ALL_INVALID_ARGUMENT');
         fnd_message.set_name ('CS', 'CS_API_ALL_INVALID_ARGUMENT');
         fnd_message.set_token ('API_NAME', G_PKG_NAME||'.'||l_api_name);
         fnd_message.set_token('VALUE', p_relational_operator);
         fnd_message.set_token('PARAMETER', 'RELATIONAL OPERATOR');
	    x_return_status := FND_API.G_RET_STS_ERROR;
      elsif ( p_criteria_value_low is NULL AND p_criteria_value_high IS NULL ) then
	    -- Error in plan criteria. Criteria value low should be specified.
 --        fnd_message.set_name (CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'CS_API_ALL_INVALID_ARGUMENT');
         fnd_message.set_name ('CS', 'CS_API_ALL_INVALID_ARGUMENT');
         fnd_message.set_token ('API_NAME', G_PKG_NAME||'.'||l_api_name);
         fnd_message.set_token('VALUE', p_criteria_value_low);
         fnd_message.set_token('PARAMETER', 'CRITERIA VALUE LOW');
	    x_return_status := FND_API.G_RET_STS_ERROR;
      elsif ( p_criteria_value_low IS NOT NULL AND p_criteria_value_high IS NOT NULL ) then
	    -- Error in plan criteria. Criteria value high should not be specified.
--         fnd_message.set_name (CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'CS_API_ALL_INVALID_ARGUMENT');
         fnd_message.set_name ('CS', 'CS_API_ALL_INVALID_ARGUMENT');
         fnd_message.set_token ('API_NAME', G_PKG_NAME||'.'||l_api_name);
         fnd_message.set_token('VALUE', p_criteria_value_high);
         fnd_message.set_token('PARAMETER', 'CRITERIA VALUE HIGH');
	    x_return_status := FND_API.G_RET_STS_ERROR;
      end if;
   ELSIF ( p_relational_operator =  'BETWEEN' OR
		 p_relational_operator =  'NOT BETWEEN' )
   THEN
	 if ( p_criteria_value_low IS NULL OR p_criteria_value_high IS NULL ) then
	    -- Error in plan criteria. Criteria value low and high should be specified.
--         fnd_message.set_name (CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'CS_API_ALL_INVALID_ARGUMENT');
         fnd_message.set_name ('CS', 'CS_API_ALL_INVALID_ARGUMENT');
         fnd_message.set_token ('API_NAME', G_PKG_NAME||'.'||l_api_name);
         fnd_message.set_token('VALUE', p_relational_operator);
         fnd_message.set_token('PARAMETER', 'RELATIONAL OPERATOR');
	    x_return_status := FND_API.G_RET_STS_ERROR;
      elsif ( p_criteria_value_low > p_criteria_value_high ) then
	    -- Error in plan criteria. Criteria value low should be less than criteria
	    -- value high.
--         fnd_message.set_name (CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'CS_API_ALL_INVALID_ARGUMENT');
         fnd_message.set_name ('CS', 'CS_API_ALL_INVALID_ARGUMENT');
         fnd_message.set_token ('API_NAME', G_PKG_NAME||'.'||l_api_name);
         fnd_message.set_token('VALUE', p_criteria_value_high);
         fnd_message.set_token('PARAMETER', 'CRITERIA VALUE HIGH');
	    x_return_status := FND_API.G_RET_STS_ERROR;
      end if;
   ELSIF ( p_relational_operator =  'IS NULL'  OR
		 p_relational_operator =  'IS NOT NULL' )
   THEN
	 if ( p_criteria_value_low IS NOT NULL OR p_criteria_value_high IS NOT NULL ) then
	    -- Error in plan criteria. Criteria value low and high should not be specified.
--         fnd_message.set_name (CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'CS_API_ALL_INVALID_ARGUMENT');
         fnd_message.set_name ('CS', 'CS_API_ALL_INVALID_ARGUMENT');
         fnd_message.set_token ('API_NAME', G_PKG_NAME||'.'||l_api_name);
         fnd_message.set_token('VALUE', p_relational_operator);
         fnd_message.set_token('PARAMETER', 'RELATIONAL OPERATOR');
	    x_return_status := FND_API.G_RET_STS_ERROR;
      end if;
   END IF;

END Validate_Plan_Criteria;


PROCEDURE Validate_START_DATE_ACTIVE (
    P_Init_Msg_List              IN   VARCHAR2,
    P_Validation_mode            IN   VARCHAR2,
    P_PLAN_ID                    IN   NUMBER,
    P_START_DATE_ACTIVE          IN   DATE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
   cursor c1 is
	 select min(start_date_active)
	 from   csc_cust_plans
	 where  plan_id = p_plan_id;

   l_min_date          DATE;
   l_api_name          VARCHAR2(30) := 'Validate_Start_Date_Active';

BEGIN

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
       FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   if ( p_validation_mode = CSC_CORE_UTILS_PVT.G_UPDATE ) then
	 open  c1;
	 fetch c1 into l_min_date;
      close c1;

	 if ( trunc(p_start_date_active) > trunc(l_min_date) ) then
	 -- START date cannot be updated to specified value. There are customers who are associated
	 -- to this plan EARLIER than the specified date. Valid dates are LESS than MIN_DATE;
--         fnd_message.set_name (CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'CS_API_ALL_INVALID_ARGUMENT');
         fnd_message.set_name ('CS', 'CS_API_ALL_INVALID_ARGUMENT');
         fnd_message.set_token ('API_NAME', G_PKG_NAME||'.'||l_api_name);
         fnd_message.set_token('VALUE', p_start_date_active);
         fnd_message.set_token('PARAMETER', 'START_DATE_ACTIVE');
         -- fnd_msg_pub.add;
	    x_return_status := FND_API.G_RET_STS_ERROR;
      end if;
   end if;

   if ( x_Return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
      APP_EXCEPTION.RAISE_EXCEPTION;
   end if;

END Validate_START_DATE_ACTIVE;


PROCEDURE Validate_END_DATE_ACTIVE (
    P_Init_Msg_List              IN   VARCHAR2,
    P_Validation_mode            IN   VARCHAR2,
    P_PLAN_ID                    IN   NUMBER,
    P_END_DATE_ACTIVE            IN   DATE,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
   cursor c1 is
	 select max(end_date_active)
	 from   csc_cust_plans
	 where  plan_id = p_plan_id;

   l_max_date          DATE;
   l_api_name          VARCHAR2(30) := 'Validate_End_Date_Active';

BEGIN
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
       FND_MSG_PUB.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   if ( p_validation_mode = CSC_CORE_UTILS_PVT.G_UPDATE ) then
	 open  c1;
	 fetch c1 into l_max_date;
      close c1;

	 if l_max_date is null then
	    l_max_date := SYSDATE;
      end if;

	 if ( trunc(p_end_date_active) < trunc(l_max_date) ) then
	 -- DATE_TYPE date cannot be updated to specified value. There are customers who are associated
	 -- to this plan EARLIER_LATER than the specified date. Valid dates are GREATER_LESSER than
	 -- MAX_MIN_DATE;
         fnd_message.set_name (CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'CSC_RSP_INVALID_DATE_UPDATE');
         fnd_message.set_token ('DATE_TYPE', 'End Date Active');
         fnd_message.set_token('EARLIER_LATER', 'later');
         fnd_message.set_token('GREATER_LESSER', 'greater');
         fnd_message.set_token('MAX_MIN_DATE', l_max_date);
	    x_return_status := FND_API.G_RET_STS_ERROR;
      end if;

	 /*
	 if ( trunc(p_end_date_active) < trunc(l_max_date) ) then
	 -- END date cannot be updated to specified value. There are customers who are associated
	 -- to this plan LATER than the specified date. Valid dates are GREATER than MAX_DATE;
--         fnd_message.set_name (CSC_CORE_UTILS_PVT.G_APP_SHORTNAME, 'CS_API_ALL_INVALID_ARGUMENT');
         fnd_message.set_name ('CS', 'CS_API_ALL_INVALID_ARGUMENT');
         fnd_message.set_token ('API_NAME', G_PKG_NAME||'.'||l_api_name);
         fnd_message.set_token('VALUE', p_end_date_active);
         fnd_message.set_token('PARAMETER', 'END_DATE_ACTIVE');
         -- fnd_msg_pub.add;
	    x_return_status := FND_API.G_RET_STS_ERROR;
      end if;
	 */
   end if;

   if ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
      APP_EXCEPTION.RAISE_EXCEPTION;
   end if;

END Validate_END_DATE_ACTIVE;


PROCEDURE Validate_csc_relationship_plan(
   P_Init_Msg_List              IN   VARCHAR2,
   P_Validation_level           IN   NUMBER,
   P_Validation_mode            IN   VARCHAR2,
   P_CSC_PLAN_HEADERS_B_REC     IN   CSC_PLAN_HEADERS_B_REC_TYPE,
   P_OLD_PLAN_HEADERS_B_REC     IN   CSC_PLAN_HEADERS_B_REC_TYPE,
   P_DESCRIPTION                IN   VARCHAR2,
   P_NAME                       IN   VARCHAR2,
   --P_PARTY_ID                   IN   NUMBER := FND_API.G_MISS_NUM,
   --P_CUST_ACCOUNT_ID            IN   NUMBER := FND_API.G_MISS_NUM,
   --P_CUST_ACCOUNT_ORG           IN   NUMBER := FND_API.G_MISS_NUM,
   X_Return_Status              OUT NOCOPY  VARCHAR2,
   X_Msg_Count                  OUT NOCOPY  NUMBER,
   X_Msg_Data                   OUT NOCOPY  VARCHAR2
   )
IS
   l_api_name   CONSTANT VARCHAR2(30) := 'Validate_csc_relationship_plan';
BEGIN
      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF (p_validation_level >= FND_API.G_VALID_LEVEL_FULL) THEN
          Validate_PLAN_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PLAN_ID                => P_CSC_PLAN_HEADERS_B_REC.PLAN_ID,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_NAME(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_plan_id                => P_CSC_PLAN_HEADERS_B_REC.PLAN_ID,
              p_NAME                   => P_NAME,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_ORIGINAL_PLAN_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PLAN_ID                => P_CSC_PLAN_HEADERS_B_REC.PLAN_ID,
              p_ORIGINAL_PLAN_ID       => P_CSC_PLAN_HEADERS_B_REC.ORIGINAL_PLAN_ID,
              p_CUSTOMIZED_PLAN        => P_CSC_PLAN_HEADERS_B_REC.CUSTOMIZED_PLAN,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PLAN_GROUP_CODE(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_PLAN_GROUP_CODE        => P_CSC_PLAN_HEADERS_B_REC.PLAN_GROUP_CODE,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_START_DATE_ACTIVE (
             P_Init_Msg_List           =>  FND_API.G_TRUE,
             P_Validation_mode         =>  p_validation_mode,
             P_PLAN_ID                 =>  P_CSC_PLAN_HEADERS_B_REC.PLAN_ID,
             P_START_DATE_ACTIVE       =>  P_CSC_PLAN_HEADERS_B_REC.START_DATE_ACTIVE,
             X_Return_Status           =>  x_return_status,
             X_Msg_Count               =>  x_msg_count,
             X_Msg_Data                =>  x_msg_data );
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_END_DATE_ACTIVE (
             P_Init_Msg_List           =>  FND_API.G_TRUE,
             P_Validation_mode         =>  p_validation_mode,
             P_PLAN_ID                 =>  P_CSC_PLAN_HEADERS_B_REC.PLAN_ID,
             P_END_DATE_ACTIVE         =>  P_CSC_PLAN_HEADERS_B_REC.END_DATE_ACTIVE,
             X_Return_Status           =>  x_return_status,
             X_Msg_Count               =>  x_msg_count,
             X_Msg_Data                =>  x_msg_data );
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

  -- issue a call to the CORE UTILITIES package to validate the date fields.
          CSC_CORE_UTILS_PVT.VALIDATE_DATES(
             p_init_msg_list   =>  FND_API.G_FALSE,
             p_validation_mode =>  p_validation_mode,
             P_START_DATE      =>  p_csc_plan_headers_b_rec.start_date_active,
             P_END_DATE        =>  p_csc_plan_headers_b_rec.end_date_active,
             x_return_status   =>  x_return_status,
             x_msg_count       =>  x_msg_count,
             x_msg_data        =>  x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_USE_FOR_CUST_ACCOUNT(
              p_init_msg_list            => FND_API.G_FALSE,
              p_validation_mode          => p_validation_mode,
	      p_PLAN_ID                  => P_CSC_PLAN_HEADERS_B_REC.PLAN_ID,
              p_USE_FOR_CUST_ACCOUNT     => P_CSC_PLAN_HEADERS_B_REC.USE_FOR_CUST_ACCOUNT,
	      p_OLD_USE_FOR_CUST_ACCOUNT => P_OLD_PLAN_HEADERS_B_REC.USE_FOR_CUST_ACCOUNT,
              x_return_status            => x_return_status,
              x_msg_count                => x_msg_count,
              x_msg_data                 => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_END_USER_TYPE (
              P_Init_Msg_List            => FND_API.G_FALSE,
              P_Validation_mode          => p_validation_mode,
              P_END_USER_TYPE            => P_CSC_PLAN_HEADERS_B_REC.END_USER_TYPE,
              X_Return_Status            => x_return_status,
              X_Msg_Count                => x_msg_count,
              X_Msg_Data                 => x_msg_data );
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_CUSTOMIZED_PLAN(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_CUSTOMIZED_PLAN        => P_CSC_PLAN_HEADERS_B_REC.CUSTOMIZED_PLAN,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_PROFILE_CHECK_ID(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
	      p_plan_id                => P_CSC_PLAN_HEADERS_B_REC.PLAN_ID,
              p_PROFILE_CHECK_ID       => P_CSC_PLAN_HEADERS_B_REC.PROFILE_CHECK_ID,
	      p_OLD_PROFILE_CHECK_ID   => P_OLD_PLAN_HEADERS_B_REC.PROFILE_CHECK_ID,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_CRITERIA_VALUE_LOW(
              p_init_msg_list          => FND_API.G_FALSE,
              p_validation_mode        => p_validation_mode,
              p_plan_id                => P_CSC_PLAN_HEADERS_B_REC.PLAN_ID,
              p_CRITERIA_VALUE_LOW     => P_CSC_PLAN_HEADERS_B_REC.CRITERIA_VALUE_LOW,
	      p_OLD_CRITERIA_VALUE_LOW => P_OLD_PLAN_HEADERS_B_REC.CRITERIA_VALUE_LOW,
              x_return_status          => x_return_status,
              x_msg_count              => x_msg_count,
              x_msg_data               => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_CRITERIA_VALUE_HIGH(
              p_init_msg_list           => FND_API.G_FALSE,
              p_validation_mode         => p_validation_mode,
	      p_plan_id                 => P_CSC_PLAN_HEADERS_B_REC.PLAN_ID,
              p_CRITERIA_VALUE_HIGH     => P_CSC_PLAN_HEADERS_B_REC.CRITERIA_VALUE_HIGH,
	      p_OLD_CRITERIA_VALUE_HIGH => P_OLD_PLAN_HEADERS_B_REC.CRITERIA_VALUE_HIGH,
              x_return_status           => x_return_status,
              x_msg_count               => x_msg_count,
              x_msg_data                => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_RELATIONAL_OPERATOR(
              p_init_msg_list           => FND_API.G_FALSE,
              p_validation_mode         => p_validation_mode,
	      p_plan_id                 => P_CSC_PLAN_HEADERS_B_REC.PLAN_ID,
              p_RELATIONAL_OPERATOR     => P_CSC_PLAN_HEADERS_B_REC.RELATIONAL_OPERATOR,
	      p_OLD_RELATIONAL_OPERATOR => P_OLD_PLAN_HEADERS_B_REC.RELATIONAL_OPERATOR,
              x_return_status           => x_return_status,
              x_msg_count               => x_msg_count,
              x_msg_data                => x_msg_data);
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

          Validate_Plan_Criteria (
              P_Init_Msg_List              =>  p_init_msg_list,
              P_Validation_mode            =>  p_validation_mode,
              P_PLAN_ID                    =>  P_CSC_PLAN_HEADERS_B_REC.PLAN_ID,
              P_RELATIONAL_OPERATOR        =>  P_CSC_PLAN_HEADERS_B_REC.RELATIONAL_OPERATOR,
              P_CRITERIA_VALUE_LOW         =>  P_CSC_PLAN_HEADERS_B_REC.CRITERIA_VALUE_LOW,
              P_CRITERIA_VALUE_HIGH        =>  P_CSC_PLAN_HEADERS_B_REC.CRITERIA_VALUE_HIGH,
              X_Return_Status              =>  x_return_status,
              X_Msg_Count                  =>  x_msg_count,
              X_Msg_Data                   =>  x_msg_data );
          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              raise FND_API.G_EXC_ERROR;
          END IF;

      END IF;

END Validate_csc_relationship_plan;

End CSC_RELATIONSHIP_PLANS_PVT;

/
