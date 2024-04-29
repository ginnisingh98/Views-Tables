--------------------------------------------------------
--  DDL for Package CSC_PROFILE_VARIABLE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSC_PROFILE_VARIABLE_PUB" AUTHID CURRENT_USER AS
/* $Header: cscppvas.pls 115.14 2002/11/28 09:36:06 bhroy ship $ */

--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:PROFVAR_Rec_Type
--   -------------------------------------------------------
--   Parameters:
--    BLOCK_ID
--    CREATED_BY
--    CREATION_DATE
--    LAST_UPDATED_BY
--    LAST_UPDATE_DATE
--    LAST_UPDATE_LOGIN
--    BLOCK_NAME
--    DESCRIPTION
--    START_DATE_ACTIVE
--    END_DATE_ACTIVE
--    SEEDED_FLAG
--    BLOCK_NAME_CODE
--    FORM_FUNCTION_ID
--	COLUMN_ID
--    SQL_STMNT_FOR_DRILLDOWN
--    SQL_STMNT
--    SELECT_CLAUSE
--    CURRENCY_CODE
--    FROM_CLAUSE
--    WHERE_CLAUSE
--    ORDER_BY_CLAUSE
--    OTHER_CLAUSE
--    BLOCK_LEVEL
--    APPLICATION_ID

TYPE ProfVar_Rec_Type IS RECORD (
      BLOCK_ID                      NUMBER,
      CREATED_BY                    NUMBER,
      CREATION_DATE                 DATE,
      LAST_UPDATED_BY               NUMBER,
      LAST_UPDATE_DATE              DATE,
      LAST_UPDATE_LOGIN             NUMBER,
      BLOCK_NAME                    VARCHAR2(80),
      DESCRIPTION                   VARCHAR2(240),
      START_DATE_ACTIVE             DATE,
      END_DATE_ACTIVE               DATE,
      SEEDED_FLAG                   VARCHAR2(1),
      BLOCK_NAME_CODE               VARCHAR2(80),
      OBJECT_CODE	       	    VARCHAR2(30),
      SQL_STMNT		       	    VARCHAR2(2000),
      SQL_STMNT_FOR_DRILLDOWN       VARCHAR2(2000),
      SELECT_CLAUSE                 VARCHAR2(2000),
      CURRENCY_CODE                 VARCHAR2(30),
      FROM_CLAUSE                   VARCHAR2(200),
      WHERE_CLAUSE                  VARCHAR2(2000),
      ORDER_BY_CLAUSE               VARCHAR2(200),
      OTHER_CLAUSE                  VARCHAR2(200),
      BLOCK_LEVEL                   VARCHAR2(20),
     OBJECT_VERSION_NUMBER   	NUMBER,
     APPLICATION_ID             NUMBER
	);


G_MISS_PROF_REC          ProfVar_Rec_Type;


G_Miss_Table_Column_Tbl       CSC_Profile_Variable_PVT.Table_Column_tbl_TYPE;


-- ------------------------------------------------------------------
-- API name:     Create_Profile_Variable
-- Version :     Initial version	1.0
-- Type: 	     Public
-- Function:     Creates a customer profile variable  in the table CS_PROF_BLOCKS
-- Pre-reqs:     None.

-- Parameters:

-- Standard IN Parameters:

-- p_api_version			IN	NUMBER	Required
-- p_init_msg_list		IN	VARCHAR2	Optional
-- Default = FND_API.G_FALSE
-- p_commit			IN	VARCHAR2	Optional
-- Default = FND_API.G_FALSE

-- Standard OUT NOCOPY Parameters:

-- x_return_status		OUT NOCOPY	VARCHAR2(1)
-- x_msg_count			OUT NOCOPY	NUMBER
-- x_msg_data			OUT NOCOPY	VARCHAR2(2000)

-- Customer Profile Variable  IN Parameters:

-- p_resp_appl_id		IN	NUMBER	Optional
-- Application identifier
-- p_resp_id			IN	NUMBER	Optional
-- Responsibility identifier
-- p_user_id			IN	NUMBER	Required
-- Application user identifier
-- p_login_id			IN	NUMBER	Optional
-- Login session identifier
-- p_org_id			IN	NUMBER	Optional
-- Operating unit identifier
-- Required if Multi-Org is enabled.
-- Ignored if Multi-Org is disabled.
-- p_block_name			IN	VARCHAR2(80)	Required
-- Variable Block Name.
-- P_description			IN	VARCHAR2(240)	Optional
-- Variable Block description
-- p_seeded_flag			IN	VARCHAR2(1)	Optional
-- Indicates whether the Variable is seeded.
-- p_sql_stmnt			IN	VARCHAR2(2000)	Required
-- Sql stmnt. Must be non-null.
-- p_start_date_active		IN	DATE		Optional
-- Start active date for the variable block.
-- p_end_date_active		IN	DATE		Optional
-- End date for the variable block.

-- Customer Profile Variable OUT NOCOPY parameters:
-- p_application_id             IN      NUMBER          Optional
-- x_block_id       		OUT NOCOPY	NUMBER
-- System generated ID of Customer Profile Variable.
--
-----------------------------------------------------------------------

PROCEDURE Create_Profile_Variable(
    p_api_version_number   	IN  NUMBER,
    p_init_msg_list        	IN  VARCHAR2,
    p_commit               	IN  VARCHAR2,
    p_validation_level     	IN  VARCHAR2 DEFAULT NULL,
    x_return_status        	OUT NOCOPY VARCHAR2,
    x_msg_count            	OUT NOCOPY NUMBER,
    x_msg_data             	OUT NOCOPY VARCHAR2,
    p_block_name           	IN  VARCHAR2,
    p_block_name_code      	IN  VARCHAR2 DEFAULT NULL,
    p_description          	IN  VARCHAR2 DEFAULT NULL,
    p_sql_stmnt        		IN  VARCHAR2 DEFAULT NULL,
    p_seeded_flag               IN  VARCHAR2 DEFAULT NULL,
    p_start_date_active    	IN  DATE DEFAULT NULL,
    p_end_date_active      	IN  DATE DEFAULT NULL,
    p_currency_code	      IN  VARCHAR2 DEFAULT NULL,
    --p_form_function_id 		IN  NUMBER   := FND_API.G_MISS_NUM,
    p_object_code			IN  VARCHAR2 DEFAULT NULL,
    p_select_clause		IN  VARCHAR2 DEFAULT NULL,
    p_from_clause			IN  VARCHAR2 DEFAULT NULL,
    p_where_clause		IN  VARCHAR2 DEFAULT NULL,
    p_other_clause	 	IN  VARCHAR2 DEFAULT NULL,
    p_block_level               IN  VARCHAR2 DEFAULT NULL,
    p_CREATED_BY              IN  NUMBER DEFAULT NULL,
    p_CREATION_DATE           IN  DATE DEFAULT NULL,
    p_LAST_UPDATED_BY         IN  NUMBER DEFAULT NULL,
    p_LAST_UPDATE_DATE        IN  DATE DEFAULT NULL,
    p_LAST_UPDATE_LOGIN       IN  NUMBER DEFAULT NULL,
    x_OBJECT_VERSION_NUMBER   OUT NOCOPY  NUMBER,
    p_APPLICATION_ID          IN   NUMBER DEFAULT NULL,
    x_block_id          	OUT NOCOPY NUMBER
    );

-- ------------------------------------------------------------------
-- API name:     Create_Profile_Variable
-- Version :     Initial version	1.0
-- Type: 	     Public
-- Function:     Creates a customer profile variable  in the table CS_PROF_BLOCKS
-- Pre-reqs:     None.

-- Parameters:

-- Standard IN Parameters:

-- p_api_version			IN	NUMBER	Required
-- p_init_msg_list		IN	VARCHAR2	Optional
-- Default = FND_API.G_FALSE
-- p_commit			IN	VARCHAR2	Optional
-- Default = FND_API.G_FALSE

-- Standard OUT NOCOPY Parameters:

-- x_return_status		OUT NOCOPY	VARCHAR2(1)
-- x_msg_count			OUT NOCOPY	NUMBER
-- x_msg_data			OUT NOCOPY	VARCHAR2(2000)

-- Customer Profile Variable  IN Parameters:

-- P_Prof_Var_Rec  	IN	ProfVar_Rec_Type

-- Customer Profile Variable OUT NOCOPY parameters:

-- x_block_id       		OUT NOCOPY	NUMBER
-- System generated ID of Customer Profile Variable.
--
-----------------------------------------------------------------------

PROCEDURE Create_Profile_Variable(
    P_Api_Version_Number  IN   NUMBER,
    P_Init_Msg_List     IN   	VARCHAR2,
    P_Commit            IN   	VARCHAR2,
    P_Validation_Level  IN   	NUMBER DEFAULT NULL,
    P_Prof_Var_Rec	IN	ProfVar_Rec_Type,
    X_Return_Status	OUT NOCOPY 	VARCHAR2,
    X_Msg_Count		OUT NOCOPY	NUMBER,
    X_Msg_Data		OUT NOCOPY	VARCHAR2,
    X_Block_Id          OUT NOCOPY 	NUMBER ,
    x_OBJECT_VERSION_NUMBER   OUT NOCOPY  NUMBER
      );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_table_column
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       P_TabCol_Rec     IN TabCol_Rec_Type  Required
--
--   OUT NOCOPY:
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--
--   Version : Current version 1.0
--
--   End of Comments
--
PROCEDURE Create_table_column(
	P_Api_Version_Number       IN  NUMBER,
	P_Init_Msg_List            IN  VARCHAR2,
	P_Commit                   IN  VARCHAR2,
	P_Validation_level	   IN  NUMBER,
	p_Table_Column_Tbl	   IN  CSC_Profile_Variable_pvt.Table_Column_Tbl_Type,
	--p_Sql_Stmnt_For_Drilldown  IN  VARCHAR2 := FND_API.G_MISS_CHAR,
	--p_BLOCK_ID		   	   IN	 NUMBER,
	X_TABLE_COLUMN_ID     	   OUT NOCOPY NUMBER,
      X_OBJECT_VERSION_NUMBER   OUT NOCOPY  NUMBER,
	X_Return_Status            OUT NOCOPY VARCHAR2,
	X_Msg_Count                OUT NOCOPY NUMBER,
	X_Msg_Data                 OUT NOCOPY VARCHAR2
    );
-- ------------------------------------------------------------------
-- API name:     Update_Profile_Variable
-- Version :     Initial version	1.0
-- Type: 	     Public
-- Function:     Updates a customer profile variable  in the table CS_PROF_BLOCKS
-- Pre-reqs:     None.

-- Parameters:

-- Standard IN Parameters:

-- p_api_version			IN	NUMBER	Required
-- p_init_msg_list		IN	VARCHAR2	Optional
-- Default = FND_API.G_FALSE
-- p_commit			IN	VARCHAR2	Optional
-- Default = FND_API.G_FALSE

-- Standard OUT NOCOPY Parameters:

-- x_return_status		OUT NOCOPY	VARCHAR2(1)
-- x_msg_count			OUT NOCOPY	NUMBER
-- x_msg_data			OUT NOCOPY	VARCHAR2(2000)

-- Customer Profile Variable  IN Parameters:

-- p_resp_appl_id		IN	NUMBER	Optional
-- Application identifier
-- p_resp_id			IN	NUMBER	Optional
-- Responsibility identifier
-- p_user_id			IN	NUMBER	Required
-- Application user identifier
-- p_login_id			IN	NUMBER	Optional
-- Login session identifier
-- p_org_id			IN	NUMBER	Optional
-- Operating unit identifier
-- Required if Multi-Org is enabled.
-- Ignored if Multi-Org is disabled.
-- p_block_id                 IN   NUMBER         Required
-- System generated ID of Customer Profile Variable.
-- p_block_name			IN	VARCHAR2(80)	Required
-- Variable Block Name.
-- P_description			IN	VARCHAR2(240)	Optional
-- Variable Block description
-- p_seeded_flag			IN	VARCHAR2(1)	Optional
-- Indicates whether the Variable is seeded.
-- p_sql_stmnt			IN	VARCHAR2(2000)	Required
-- Sql stmnt. Must be non-null.
-- p_start_date_active		IN	DATE		Optional
-- Start active date for the variable block.
-- p_end_date_active		IN	DATE		Optional
-- End date for the variable block.
-- p_application_id             IN      NUMBER          Optional

-- -----------------------------------------------------------------

PROCEDURE Update_Profile_Variable(
    p_api_version_number  IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2,
    p_commit              IN  VARCHAR2,
    p_validation_level    IN  VARCHAR2 DEFAULT NULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_block_id            IN  NUMBER DEFAULT NULL,
    p_block_name          IN  VARCHAR2 DEFAULT NULL,
    p_block_name_code     IN  VARCHAR2 DEFAULT NULL,
    p_description         IN  VARCHAR2 DEFAULT NULL,
    p_currency_code       IN  VARCHAR2 DEFAULT NULL,
    p_sql_stmnt       	  IN  VARCHAR2 DEFAULT NULL,
    p_seeded_flag         IN  VARCHAR2 DEFAULT NULL,
    --p_form_function_id    IN	NUMBER  DEFAULT NULL,
    p_object_code	        IN	VARCHAR2 DEFAULT NULL,
    p_start_date_active   IN  DATE DEFAULT NULL,
    p_end_date_active     IN  DATE DEFAULT NULL,
    p_select_clause	  IN  VARCHAR2 DEFAULT NULL,
    p_from_clause			IN  VARCHAR2 DEFAULT NULL,
    p_where_clause		IN  VARCHAR2 DEFAULT NULL,
    p_other_clause		IN  VARCHAR2 DEFAULT NULL,
    p_block_level               IN  VARCHAR2 DEFAULT NULL,
    p_CREATED_BY              IN  NUMBER DEFAULT NULL,
    p_CREATION_DATE           IN  DATE DEFAULT NULL,
    p_LAST_UPDATED_BY         IN  NUMBER DEFAULT NULL,
    p_LAST_UPDATE_DATE        IN  DATE DEFAULT NULL,
    p_LAST_UPDATE_LOGIN       IN  NUMBER DEFAULT NULL,
    px_OBJECT_VERSION_NUMBER   IN OUT NOCOPY NUMBER,
    p_APPLICATION_ID          IN   NUMBER DEFAULT NULL
    );


-- ------------------------------------------------------------------
-- API name:     Update_Profile_Variable
-- Version :     Initial version	1.0
-- Type: 	     Public
-- Function:     Updates a customer profile variable  in the table CS_PROF_BLOCKS
-- Pre-reqs:     None.

-- Parameters:

-- Standard IN Parameters:

-- p_api_version			IN	NUMBER	Required
-- p_init_msg_list		IN	VARCHAR2	Optional
-- Default = FND_API.G_FALSE
-- p_commit			IN	VARCHAR2	Optional
-- Default = FND_API.G_FALSE

-- Standard OUT NOCOPY Parameters:

-- x_return_status		OUT NOCOPY	VARCHAR2(1)
-- x_msg_count			OUT NOCOPY	NUMBER
-- x_msg_data			OUT NOCOPY	VARCHAR2(2000)

-- Customer Profile Variable  IN Parameters:
--  P_Prof_Var_Rec 		IN	ProfVar_Rec_Type

-- -----------------------------------------------------------------

PROCEDURE Update_Profile_Variable (
    p_api_version_number	IN	VARCHAR2,
    p_init_msg_list		IN	VARCHAR2,
    p_commit			IN	VARCHAR2,
    p_validation_level		IN	VARCHAR2 DEFAULT NULL,
    p_prof_var_rec 		IN  	ProfVar_Rec_Type,
    px_OBJECT_VERSION_NUMBER   IN OUT NOCOPY NUMBER ,
    x_return_status		OUT NOCOPY	VARCHAR2,
    x_msg_data			OUT NOCOPY	VARCHAR2,
    x_msg_count			OUT NOCOPY	NUMBER
	);

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_table_column
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_identity_salesforce_id  IN   NUMBER     Optional  Default = NULL
--       P_TabCol_Rec     IN TabCol_Rec_Type  Required
--
--   OUT NOCOPY:
--       x_return_status           OUT NOCOPY  VARCHAR2
--       x_msg_count               OUT NOCOPY  NUMBER
--       x_msg_data                OUT NOCOPY  VARCHAR2
--
--   End of Comments
--

PROCEDURE Update_table_column(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_Validation_Level		   IN   NUMBER,
    p_Table_Column_Rec		 IN   CSC_Profile_Variable_PVT.Table_Column_Rec_Type,
    --p_Sql_Stmnt_For_Drilldown    IN   VARCHAR2 := FND_API.G_MISS_CHAR,
    --p_BLOCK_ID			   IN	  NUMBER := FND_API.G_MISS_NUM,
    px_OBJECT_VERSION_NUMBER   IN OUT NOCOPY NUMBER ,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );


END CSC_Profile_Variable_pub;

 

/
