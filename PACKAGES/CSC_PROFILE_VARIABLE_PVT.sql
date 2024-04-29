--------------------------------------------------------
--  DDL for Package CSC_PROFILE_VARIABLE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSC_PROFILE_VARIABLE_PVT" AUTHID CURRENT_USER AS
/* $Header: cscvpvas.pls 120.1 2005/08/26 02:50:56 adhanara noship $ */

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
--	   COLUMN_ID
--    SQL_STMNT_FOR_DRILLDOWN
--    SQL_STMNT
--    SELECT_CLAUSE
--    CURRENCY_CODE
--    FROM_CLAUSE
--    WHERE_CLAUSE
--    ORDER_BY_CLAUSE
--    BLOCK_LEVEL
--    OTHER_CLAUSE
--    APPLICATION_ID

TYPE ProfVar_Rec_Type IS RECORD(
       BLOCK_ID                        NUMBER ,
       CREATED_BY                      NUMBER ,
       CREATION_DATE                   DATE 	,
       LAST_UPDATED_BY                 NUMBER ,
       LAST_UPDATE_DATE                DATE 	,
       LAST_UPDATE_LOGIN               NUMBER ,
       BLOCK_NAME                      VARCHAR2(240) ,
       DESCRIPTION                     VARCHAR2(240),
       START_DATE_ACTIVE               DATE 	,
       END_DATE_ACTIVE                 DATE 	,
       SEEDED_FLAG                     VARCHAR2(1),
       BLOCK_NAME_CODE                 VARCHAR2(240),
       OBJECT_CODE		       VARCHAR2(30)   ,
       SQL_STMNT		       VARCHAR2(2000),
       BATCH_SQL_STMNT                 VARCHAR2(4000),
       SQL_STMNT_FOR_DRILLDOWN         VARCHAR2(4000) ,  /* increased to 4000 for bug 4205145 */
       SELECT_CLAUSE                   VARCHAR2(2000),
       CURRENCY_CODE                   VARCHAR2(30),
       FROM_CLAUSE                     VARCHAR2(240),
       WHERE_CLAUSE                    VARCHAR2(2000),
       ORDER_BY_CLAUSE                 VARCHAR2(200),
       OTHER_CLAUSE                 	VARCHAR2(200),
       BLOCK_LEVEL                     VARCHAR2(20),
       OBJECT_VERSION_NUMBER		      NUMBER,
       APPLICATION_ID                  NUMBER
	);

G_MISS_PROF_REC          ProfVar_Rec_Type;


--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name:TabCol_Rec_Type
--   -------------------------------------------------------
--   Parameters:
--    TABLE_COLUMN_ID
--    BLOCK_ID
--    TABLE_NAME
--    COLUMN_NAME
--    LABEL
--    LAST_UPDATE_DATE
--    LAST_UPDATED_BY
--    CREATION_DATE
--    CREATED_BY
--    LAST_UPDATE_LOGIN
--    SEEDED_FLAG
--
--
--   End of Comments



TYPE Table_Column_Rec_Type IS RECORD
(
       TABLE_COLUMN_ID                 NUMBER ,
       BLOCK_ID                        NUMBER ,
       TABLE_NAME                      VARCHAR2(30),
       COLUMN_NAME                     VARCHAR2(30),
       LABEL                           VARCHAR2(80),
       TABLE_ALIAS		               VARCHAR2(80) ,
       COLUMN_SEQUENCE		            NUMBER ,
       DRILLDOWN_COLUMN_FLAG           VARCHAR2(3),
       LAST_UPDATE_DATE                DATE ,
       LAST_UPDATED_BY                 NUMBER,
       CREATION_DATE                   DATE ,
       CREATED_BY                      NUMBER,
       LAST_UPDATE_LOGIN               NUMBER,
       SEEDED_FLAG                      VARCHAR2(3)
);

G_MISS_Table_Column_REC          Table_Column_Rec_Type;

TYPE Table_Column_Tbl_Type      IS TABLE OF Table_Column_Rec_Type
                                    INDEX BY BINARY_INTEGER;
G_MISS_Table_Column_TBL          Table_Column_Tbl_Type;

-- ------------------------------------------------------------------
-- Create_Profile_Variable
-- -----------------------------------------------------------------
-- Start Of Comments

-- API name:   Create_Profile_Variable
-- Version :   Initial version	1.0
-- Type: 	   Private
-- Function:   Creates a profile variable  in the table CSC_PROF_BLOCKS_B
-- Pre-reqs:   None.

-- Parameters:

-- Standard IN Parameters:

-- p_api_version			IN	NUMBER	Required
-- p_init_msg_list		IN	VARCHAR2	Optional
-- Default = CSC_CORE_UTILS_PVT.G_FALSE
-- p_commit			IN	VARCHAR2	Optional
-- Default = CSC_CORE_UTILS_PVT.G_FALSE

-- Standard OUT Parameters:

-- x_return_status		OUT	VARCHAR2(1)
-- x_msg_count			OUT	NUMBER
-- x_msg_data			OUT	VARCHAR2(2000)

-- Customer Profile Variable  IN Parameters:

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

-- Customer Profile Variable OUT parameters:

-- x_block_id       		OUT	NUMBER
-- System generated ID of  Profile Variable.

-- End Of Comments
-- -----------------------------------------------------------------

PROCEDURE Create_Profile_Variable(
    p_api_version_number   IN  NUMBER,
    p_init_msg_list        IN  VARCHAR2 := CSC_CORE_UTILS_PVT.G_FALSE,
    p_commit               IN  VARCHAR2 := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level     IN  NUMBER := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    x_return_status        OUT NOCOPY VARCHAR2,
    x_msg_count            OUT NOCOPY NUMBER,
    x_msg_data             OUT NOCOPY VARCHAR2,
    p_block_name           IN  VARCHAR2,
    p_block_name_code      IN  VARCHAR2 ,
    p_description          IN  VARCHAR2 ,
    p_sql_stmnt            IN  VARCHAR2 ,
    p_batch_sql_stmnt      IN  VARCHAR2 ,
    p_sql_stmnt_for_drilldown  IN  VARCHAR2 DEFAULT NULL,
    p_seeded_flag          IN  VARCHAR2 ,
    p_start_date_active    IN  DATE  ,
    p_end_date_active      IN  DATE  ,
    p_currency_code	      IN  VARCHAR2,
    --p_form_function_id   IN	 NUMBER ,
    p_object_code		      IN	 VARCHAR2  DEFAULT NULL ,
    p_select_clause		   IN  VARCHAR2,
    p_from_clause		      IN  VARCHAR2 ,
    p_where_clause		   IN  VARCHAR2 ,
    p_order_by_clause	   IN  VARCHAR2 DEFAULT NULL,
    p_other_clause	 	   IN  VARCHAR2 ,
    p_block_level          IN  VARCHAR2 ,
    p_CREATED_BY           IN  NUMBER ,
    p_CREATION_DATE        IN  DATE ,
    p_LAST_UPDATED_BY      IN  NUMBER ,
    p_LAST_UPDATE_DATE     IN  DATE ,
    p_LAST_UPDATE_LOGIN    IN  NUMBER,
    x_OBJECT_VERSION_NUMBER OUT NOCOPY  NUMBER,
    p_APPLICATION_ID       IN   NUMBER,
    x_block_id          	OUT NOCOPY NUMBER
    );

-- ------------------------------------------------------------------
-- Create_Profile_Variable
-- -----------------------------------------------------------------
-- Start Of Comments

-- API name:   Create_Profile_Variable
-- Version :   Initial version	1.0
-- Type: 	   Private
-- Function:   Creates a profile variable  in the table CSC_PROF_BLOCKS_B
-- Pre-reqs:   None.

-- Parameters:

-- Standard IN Parameters:

-- p_api_version			IN	NUMBER	Required
-- p_init_msg_list		IN	VARCHAR2	Optional
-- Default = CSC_CORE_UTILS_PVT.G_FALSE
-- p_commit			IN	VARCHAR2	Optional
-- Default = CSC_CORE_UTILS_PVT.G_FALSE

-- Standard OUT Parameters:

-- x_return_status		OUT	VARCHAR2(1)
-- x_msg_count			OUT	NUMBER
-- x_msg_data			OUT	VARCHAR2(2000)

-- Customer Profile Variable  IN Parameters:
-- P_prof_var_Rec  		IN	ProfVar_Rec_Type

-- Customer Profile Variable OUT parameters:

-- x_block_id       		OUT	NUMBER
-- System generated ID of  Profile Variable.
-- -----------------------------------------------------------------

-- End Of Comments

PROCEDURE  Create_Profile_Variable(
    p_api_version_number	IN	NUMBER,
    p_init_msg_list		   IN	VARCHAR2 := CSC_CORE_UTILS_PVT.G_FALSE,
    p_commit			      IN	VARCHAR2 := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level 	   IN	NUMBER := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    p_prof_var_rec 		   IN 	ProfVar_Rec_Type := G_MISS_PROF_REC,
    x_msg_data		         OUT NOCOPY	VARCHAR2,
    x_msg_count		      OUT NOCOPY	NUMBER,
    x_return_status 	      OUT NOCOPY	VARCHAR2,
    x_block_id 		      OUT NOCOPY	NUMBER,
    x_object_version_number  OUT NOCOPY NUMBER
    );

--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_table_column
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = CSC_CORE_UTILS_PVT.G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = CSC_CORE_UTILS_PVT.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL
--       P_TabCol_Rec     IN TabCol_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2

--
--   End of Comments
--
PROCEDURE Create_table_column(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    p_Table_Column_Tbl		   IN   Table_Column_Tbl_Type := G_MISS_Table_Column_TBL,
    --p_Sql_Stmnt_For_Drilldown    IN   VARCHAR2 := CSC_CORE_UTILS_PVT.G_MISS_CHAR,
    --p_BLOCK_ID			        IN   NUMBER := CSC_CORE_UTILS_PVT.G_MISS_NUM,
    X_TABLE_COLUMN_ID     	     OUT NOCOPY  NUMBER,
    X_object_version_number	  OUT NOCOPY  NUMBER,
    X_Return_Status             OUT NOCOPY VARCHAR2,
    X_Msg_Count                 OUT NOCOPY NUMBER,
    X_Msg_Data                  OUT NOCOPY VARCHAR2
    );


PROCEDURE Create_table_column(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    p_Table_Column_REC		 IN   Table_Column_Rec_Type := G_MISS_Table_Column_REC,
    --p_Sql_Stmnt_For_Drilldown    IN   VARCHAR2 := CSC_CORE_UTILS_PVT.G_MISS_CHAR,
    --p_BLOCK_ID			 IN   NUMBER := CSC_CORE_UTILS_PVT.G_MISS_NUM,
    X_TABLE_COLUMN_ID     	      OUT NOCOPY NUMBER,
    X_OBJECT_VERSION_NUMBER      OUT NOCOPY NUMBER,
    X_Return_Status              OUT NOCOPY VARCHAR2,
    X_Msg_Count                  OUT NOCOPY NUMBER,
    X_Msg_Data                   OUT NOCOPY VARCHAR2
    );

-- ------------------------------------------------------------------
--Update_Profile_Variable
-- -----------------------------------------------------------------
-- ------------------------------------------------------------------
-- API name:	 Update_Profile_Variable
-- Version :     Initial version	1.0
-- Type: 	 Private
-- Function:     Updates a profile variable  in the table CSC_PROF_BLOCKS_B
-- Pre-reqs:     None.

-- Parameters:

-- Standard IN Parameters:

-- p_api_version		IN	NUMBER	Required
-- p_init_msg_list		IN	VARCHAR2	Optional
-- Default = CSC_CORE_UTILS_PVT.G_FALSE
-- p_commit			IN	VARCHAR2	Optional
-- Default = CSC_CORE_UTILS_PVT.G_FALSE

-- Standard OUT Parameters:

-- x_return_status		OUT	VARCHAR2(1)
-- x_msg_count			OUT	NUMBER
-- x_msg_data			OUT	VARCHAR2(2000)

-- Customer Profile Variable  IN Parameters:
-- p_block_id              	IN  	NUMBER   	Required
-- default CSC_CORE_UTILS_PVT.G_MISS_NUM
-- p_block_name			IN	VARCHAR2(80)	Optional
-- Variable Block Name.
-- P_description		IN	VARCHAR2(240)	Optional
-- Variable Block description
-- p_seeded_flag		IN	VARCHAR2(1)	Optional
-- Indicates whether the Variable is seeded.
-- p_sql_stmnt			IN	VARCHAR2(2000)	Optional
-- Sql stmnt. Must be non-null.
-- p_start_date_active		IN	DATE		Optional
-- Start active date for the variable block.
-- p_end_date_active		IN	DATE		Optional
-- End date for the variable block.
-- p_sql_stmnt_for_drilldown 	IN  	VARCHAR2 	Optional
-- Defualt CSC_CORE_UTILS_PVT.G_MISS_CHAR,
-- p_select_clause		IN  	VARCHAR2  	Optional
-- Defualt CSC_CORE_UTILS_PVT.G_MISS_CHAR,
-- p_from_clause		IN  	VARCHAR2        Optional
-- Defualt CSC_CORE_UTILS_PVT.G_MISS_CHAR,
-- p_where_clause		IN  	VARCHAR2 	Optional
-- Defualt CSC_CORE_UTILS_PVT.G_MISS_CHAR,
-- p_other_clause		IN  	VARCHAR2 	Optional
-- Defualt CSC_CORE_UTILS_PVT.G_MISS_CHAR,
-- Customer Profile Variable OUT parameters:
-- p_APPLICATION_ID             IN      NUMBER          Optional
-- Default =  CSC_CORE_UTILS_PVT.G_MISS_NUM
--
-- -----------------------------------------------------------------
-- End of comments

PROCEDURE Update_Profile_Variable(
    p_api_version_number  IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := CSC_CORE_UTILS_PVT.G_FALSE,
    p_commit              IN  VARCHAR2 := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level    IN  NUMBER   := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_block_id            IN  NUMBER ,
    p_block_name          IN  VARCHAR2 DEFAULT NULL,
    p_block_name_code     IN  VARCHAR2 DEFAULT NULL,
    p_description         IN  VARCHAR2 DEFAULT NULL,
    p_currency_code	     IN  VARCHAR2 DEFAULT NULL,
    p_sql_stmnt           IN  VARCHAR2 DEFAULT NULL,
    p_batch_sql_stmnt     IN  VARCHAR2 DEFAULT NULL,
    p_seeded_flag         IN  VARCHAR2 DEFAULT NULL,
    --p_form_function_id  IN	NUMBER  ,
    p_object_code		     IN	VARCHAR2 DEFAULT NULL  ,
    p_start_date_active   IN  DATE DEFAULT NULL,
    p_end_date_active     IN  DATE DEFAULT NULL ,
    p_sql_stmnt_for_drilldown IN  VARCHAR2 DEFAULT NULL ,
    p_select_clause		IN  VARCHAR2 DEFAULT NULL ,
    p_from_clause		   IN  VARCHAR2 DEFAULT NULL,
    p_where_clause		IN  VARCHAR2 DEFAULT NULL,
    p_order_by_clause	IN  VARCHAR2 DEFAULT NULL ,
    p_other_clause		IN  VARCHAR2 DEFAULT NULL,
    p_block_level       IN  VARCHAR2 DEFAULT NULL,
    p_CREATED_BY        IN  NUMBER DEFAULT NULL,
    p_CREATION_DATE     IN  DATE DEFAULT NULL ,
    p_LAST_UPDATED_BY   IN  NUMBER DEFAULT NULL,
    p_LAST_UPDATE_DATE  IN  DATE DEFAULT NULL,
    p_LAST_UPDATE_LOGIN IN  NUMBER DEFAULT NULL,
    px_OBJECT_VERSION_NUMBER  IN OUT NOCOPY  NUMBER ,
    p_APPLICATION_ID          IN  NUMBER DEFAULT NULL);

-- ------------------------------------------------------------------
-- API name:	 Update_Profile_Variable
-- Version :     Initial version	1.0
-- Type: 	 Private
-- Function:     Updates a profile variable  in the table CSC_PROF_BLOCKS_B
-- Pre-reqs:     None.

-- Parameters:

-- Standard IN Parameters:

-- p_api_version		IN	NUMBER	Required
-- p_init_msg_list		IN	VARCHAR2	Optional
-- Default = CSC_CORE_UTILS_PVT.G_FALSE
-- p_commit			IN	VARCHAR2	Optional
-- Default = CSC_CORE_UTILS_PVT.G_FALSE

-- Standard OUT Parameters:

-- x_return_status		OUT	VARCHAR2(1)
-- x_msg_count			OUT	NUMBER
-- x_msg_data			OUT	VARCHAR2(2000)

-- Customer Profile Variable  IN Parameters:
-- p_prof_var_rec			IN	ProfVar_Rec_Type
-- Customer Profile Variable OUT parameters:

--
-- -----------------------------------------------------------------
-- End of comments


PROCEDURE Update_Profile_Variable(
	p_api_version_number	IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2:= CSC_CORE_UTILS_PVT.G_FALSE,
	p_commit		IN	VARCHAR2:= CSC_CORE_UTILS_PVT.G_FALSE,
	p_validation_level 	IN	NUMBER := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
	p_prof_var_rec 		IN 	ProfVar_Rec_Type := G_MISS_PROF_REC,
   px_Object_Version_Number IN OUT NOCOPY    NUMBER,
	x_msg_data	  	OUT NOCOPY	VARCHAR2,
	x_msg_count	  	OUT NOCOPY	VARCHAR2,
	x_return_status OUT NOCOPY VARCHAR2
      );
--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Update_table_column
--   Type    :  Private
--   Pre-Req :
--   Parameters:
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = CSC_CORE_UTILS_PVT.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL
--       p_identity_salesforce_id  IN   NUMBER     Optional  Default = NULL
--       P_TabCol_Rec     IN TabCol_Rec_Type  Required
--
--   OUT:
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2

--
--   End of Comments

PROCEDURE Update_table_column(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Commit                     IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    p_validation_level           IN   NUMBER       := CSC_CORE_UTILS_PVT.G_VALID_LEVEL_FULL,
    p_Table_Column_REC		 IN   Table_Column_Rec_Type := G_MISS_TABLE_COLUMN_REC,
    --p_Sql_Stmnt_For_Drilldown    IN   VARCHAR2 := CSC_CORE_UTILS_PVT.G_MISS_CHAR,
    --p_BLOCK_ID			 IN   NUMBER := CSC_CORE_UTILS_PVT.G_MISS_NUM,
    px_Object_Version_Number	 IN OUT NOCOPY NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    );



PROCEDURE Delete_profile_variables(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_BLOCK_ID			   IN   NUMBER,
    p_OBJECT_VERSION_NUMBER IN   NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    );


PROCEDURE Delete_Table_Columns(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_BLOCK_ID			            IN   NUMBER,
    px_OBJECT_VERSION_NUMBER     IN OUT NOCOPY  NUMBER,
    X_Return_Status              OUT  NOCOPY VARCHAR2,
    X_Msg_Count                  OUT  NOCOPY NUMBER,
    X_Msg_Data                   OUT  NOCOPY VARCHAR2
    );


--------------------------------------------------------------------------
-- Procedure Build_Sql_Stmnt
-- Description: Concatenates the select_Clause, from_clause, where_clause
--   and Other_clause to build an sql statement which will be stored in
--   the sql_statement column in cs_prof_blocks table.
-- Input Parameters
-- p_api_name, standard parameter for writting messages
-- p_validation_mode, whether an update or an insert uses CSC_CORE_UTILS_PVT.G_UPDATE
--  or CSC_CORE_UTILS_PVT.G_CREATE global variable
-- p_sql_statement, concatented field using select_Clause, from_clause
--    where_clause and Other_Clause columns using the Build_Sql_Stmnt
--    procedure
-- Out Parameters
-- x_return_status, standard parameter for the return status
--------------------------------------------------------------------------

PROCEDURE Build_Sql_Stmnt
( p_api_name	IN	VARCHAR2,
  p_select_clause IN	VARCHAR2,
  p_from_clause	IN	VARCHAR2,
  p_where_clause	IN	VARCHAR2,
  p_other_clause 	IN	VARCHAR2,
  x_sql_Stmnt	OUT NOCOPY	VARCHAR2,
  x_return_status	OUT NOCOPY	VARCHAR2 );

PROCEDURE Build_Drilldown_Sql_Stmnt(
	p_block_id	 	IN  NUMBER,
	P_TABLE_COLUMN_TBL 	IN  Table_Column_Tbl_Type,
	x_sql_stmnt 	OUT NOCOPY VARCHAR2 );

PROCEDURE Build_PLSQL_Table(
		  p_block_id  IN NUMBER,
		  x_table_column_tbl OUT NOCOPY Table_Column_Tbl_Type );



PROCEDURE Build_Drilldown_Sql_Stmnt(
	p_block_id  NUMBER,
	x_sql_stmnt 	OUT NOCOPY VARCHAR2 );


-- ------------------------------------------------------------------
-- API name:	 Validate_Prof_Var_attributes
-- Version :     Initial version	1.0
-- Type: 	 Validates a profile variables  for the table CSC_PROF_BLOCKS_B
-- Pre-reqs:     None.

-- Parameters:

-- Standard IN Parameters:

-- p_api_name		IN	NUMBER	Required

-- Standard OUT Parameters:

-- x_return_status	OUT	VARCHAR2(1)

-- Customer Profile Variable  IN Parameters:
-- p_validate_var_rec	IN	ProfVar_Rec_Type

-- Customer Profile Variable OUT parameters:

--
-- -----------------------------------------------------------------
-- End of comments

PROCEDURE Validate_Profile_Variables(
	p_api_name	      IN	VARCHAR2,
  	p_validation_mode IN	VARCHAR2,
  	p_validate_rec    IN	ProfVar_Rec_Type,
  	x_return_status	OUT NOCOPY	VARCHAR2,
        x_msg_count  OUT NOCOPY NUMBER,
        x_msg_data   OUT NOCOPY VARCHAR2 ) ;



-- ------------------------------------------------------------------
-- API name:	 Get_Prof_Var_Rec
-- Version :     Initial version	1.0
-- Type: 	 Gets the Profile variable record type
-- Pre-reqs:     None.
-- Parameters:

-- Standard IN Parameters:

-- p_api_name		IN	NUMBER	Required

-- Standard OUT Parameters:

-- x_return_status	OUT	VARCHAR2(1)

-- Customer Profile Variable  IN Parameters:
-- p_block_id		IN	VARCHAR2
-- p_validate_var_rec	IN	ProfVar_Rec_Type

-- Customer Profile Variable OUT parameters:
-- x_prof_var_rec	OUT	CSC_PROF_BLOCKS_B%ROWTYPE

--
-- -----------------------------------------------------------------
-- End of comments

PROCEDURE GET_PROF_BLOCKS(
   p_Api_Name      IN VARCHAR2,
   p_BLOCK_ID      IN NUMBER,
   p_Object_Version_Number IN NUMBER,
   X_PROF_BLOCKS_REC  OUT NOCOPY CSC_PROF_BLOCKS_VL%ROWTYPE,
   X_return_status OUT NOCOPY VARCHAR2
   );


Procedure GET_TABLE_COLUMN(
   p_Api_Name in VARCHAR2,
   p_Table_Column_Id IN NUMBER,
   p_Object_Version_Number IN NUMBER,
   X_Table_Column_Rec OUT NOCOPY CSC_PROF_TABLE_COLUMNS_VL%ROWTYPE ,
   X_Return_status OUT NOCOPY VARCHAR2
   );


-- Start of Comments
--
--  validation procedures
--
-- p_validation_mode is a constant defined in package
--                  For create: G_CREATE, for update: G_UPDATE
-- End of Comments
PROCEDURE Validate_table_column(
    P_Api_Name			 IN   VARCHAR2,
    P_Init_Msg_List   IN   VARCHAR2     := CSC_CORE_UTILS_PVT.G_FALSE,
    P_Validation_mode IN   VARCHAR2,
    p_validate_rec	 IN   Table_Column_Rec_Type,
    X_Return_Status   OUT NOCOPY  VARCHAR2
    );

PROCEDURE Validate_block_level
( p_api_name         IN  VARCHAR2,
  p_parameter_name   IN  VARCHAR2,
  p_block_level      IN  VARCHAR2,
  x_return_status    OUT NOCOPY VARCHAR2
);

END CSC_Profile_Variable_Pvt;

 

/
