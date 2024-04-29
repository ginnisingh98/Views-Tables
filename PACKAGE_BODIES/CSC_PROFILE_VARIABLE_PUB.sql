--------------------------------------------------------
--  DDL for Package Body CSC_PROFILE_VARIABLE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSC_PROFILE_VARIABLE_PUB" AS
/* $Header: cscppvab.pls 115.18 2002/11/28 09:35:45 bhroy ship $ */

/*********** Global  Variables  ********************************/

G_PKG_NAME     CONSTANT  VARCHAR2(30)  := 'CSC_Profile_Variable_PUB' ;

----------------------------------------------------------------------------
-- Convert_pub_to_pvt_rec Procedure
----------------------------------------------------------------------------

PROCEDURE Convert_pub_to_pvt_Rec (
         P_Profile_Variables_Rec        IN   CSC_profile_variable_PUB.ProfVar_Rec_Type,
         x_pvt_Profile_Variables_rec    OUT NOCOPY   CSC_profile_variable_PVT.ProfVar_Rec_Type
)
IS
l_any_errors       BOOLEAN   := FALSE;
BEGIN

    x_pvt_Profile_Variables_rec.BLOCK_ID := P_Profile_Variables_Rec.BLOCK_ID;
    x_pvt_Profile_Variables_rec.BLOCK_NAME_CODE := P_Profile_Variables_Rec.BLOCK_NAME_CODE;
    x_pvt_Profile_Variables_rec.START_DATE_ACTIVE := P_Profile_Variables_Rec.START_DATE_ACTIVE;
    x_pvt_Profile_Variables_rec.END_DATE_ACTIVE := P_Profile_Variables_Rec.END_DATE_ACTIVE;
    x_pvt_Profile_Variables_rec.SEEDED_FLAG := P_Profile_Variables_Rec.SEEDED_FLAG;
    x_pvt_Profile_Variables_rec.OBJECT_CODE := P_Profile_Variables_Rec.OBJECT_CODE;
    x_pvt_Profile_Variables_rec.SQL_STMNT_FOR_DRILLDOWN := P_Profile_Variables_Rec.SQL_STMNT_FOR_DRILLDOWN;
    x_pvt_Profile_Variables_rec.SQL_STMNT := P_Profile_Variables_Rec.SQL_STMNT;
    x_pvt_Profile_Variables_rec.SELECT_CLAUSE := P_Profile_Variables_Rec.SELECT_CLAUSE;
    x_pvt_Profile_Variables_rec.CURRENCY_CODE := P_Profile_Variables_Rec.CURRENCY_CODE;
    x_pvt_Profile_Variables_rec.FROM_CLAUSE := P_Profile_Variables_Rec.FROM_CLAUSE;
    x_pvt_Profile_Variables_rec.WHERE_CLAUSE := P_Profile_Variables_Rec.WHERE_CLAUSE;
    x_pvt_Profile_Variables_rec.ORDER_BY_CLAUSE := P_Profile_Variables_Rec.ORDER_BY_CLAUSE;
    x_pvt_Profile_Variables_rec.OTHER_CLAUSE := P_Profile_Variables_Rec.OTHER_CLAUSE;
    x_pvt_Profile_Variables_rec.BLOCK_LEVEL  := P_Profile_Variables_Rec.BLOCK_LEVEL;
    x_pvt_Profile_Variables_rec.CREATED_BY := P_Profile_Variables_Rec.CREATED_BY;
    x_pvt_Profile_Variables_rec.CREATION_DATE := P_Profile_Variables_Rec.CREATION_DATE;
    x_pvt_Profile_Variables_rec.LAST_UPDATED_BY := P_Profile_Variables_Rec.LAST_UPDATED_BY;
    x_pvt_Profile_Variables_rec.LAST_UPDATE_DATE := P_Profile_Variables_Rec.LAST_UPDATE_DATE;
    x_pvt_Profile_Variables_rec.LAST_UPDATE_LOGIN := P_Profile_Variables_Rec.LAST_UPDATE_LOGIN;
    x_pvt_Profile_Variables_rec.OBJECT_VERSION_NUMBER := P_Profile_Variables_Rec.OBJECT_VERSION_NUMBER;
    x_pvt_Profile_Variables_rec.APPLICATION_ID := P_Profile_Variables_Rec.APPLICATION_ID;

  -- If there is an error in conversion precessing, raise an error.
    IF l_any_errors
    THEN
        raise FND_API.G_EXC_ERROR;
    END IF;

END Convert_pub_to_pvt_Rec;

----------------------------------------------------------------------------
-- Start of Procedure Body Convert_Columns_to_Rec
----------------------------------------------------------------------------

PROCEDURE Convert_Columns_to_Rec (
    p_block_id			IN  NUMBER DEFAULT NULL,
    p_block_name           	IN  VARCHAR2,
    p_block_name_code      	IN  VARCHAR2,
    p_description          	IN  VARCHAR2,
    p_sql_stmnt        		IN  VARCHAR2,
    p_seeded_flag               IN  VARCHAR2,
    p_start_date_active    	IN  DATE    ,
    p_end_date_active      	IN  DATE    ,
    p_currency_code	      IN  VARCHAR2,
    --p_form_function_id 		IN  NUMBER,
    p_object_code			IN  VARCHAR2,
    p_select_clause		IN  VARCHAR2,
    p_from_clause			IN  VARCHAR2,
    p_where_clause		IN  VARCHAR2,
    p_other_clause	 	IN  VARCHAR2,
    p_block_level               IN  VARCHAR2,
    p_CREATED_BY              IN  NUMBER,
    p_CREATION_DATE           IN  DATE  ,
    p_LAST_UPDATED_BY         IN  NUMBER,
    p_LAST_UPDATE_DATE        IN  DATE  ,
    p_LAST_UPDATE_LOGIN       IN  NUMBER,
    p_OBJECT_VERSION_NUMBER   IN  NUMBER DEFAULT NULL,
    p_APPLICATION_ID          IN  NUMBER,
    x_Profile_Variables_Rec   OUT NOCOPY ProfVar_Rec_Type
    )
  IS
BEGIN
    x_profile_variables_rec.block_id := p_block_id;
    x_Profile_Variables_Rec.block_name := p_block_name;
    x_Profile_Variables_Rec.block_name_code := p_block_name_code;
    x_Profile_Variables_Rec.description := p_description;
    x_Profile_Variables_Rec.currency_code := p_currency_code;
    x_Profile_Variables_Rec.seeded_flag := p_seeded_flag;
    --x_Profile_Variables_Rec.form_function_id := p_form_function_id;
    x_Profile_Variables_Rec.object_code := p_object_code;
    x_Profile_Variables_Rec.start_date_active := p_start_date_active;
    x_Profile_Variables_Rec.end_date_active := p_end_date_active;
    x_Profile_Variables_Rec.select_clause := p_select_clause;
    x_Profile_Variables_Rec.from_clause := p_from_clause;
    x_Profile_Variables_Rec.where_clause := p_where_clause;
    x_Profile_Variables_Rec.other_clause := p_other_clause;
    x_Profile_Variables_Rec.block_level := p_block_level;
    x_Profile_Variables_Rec.created_by := p_created_by;
    x_Profile_Variables_Rec.creation_date := p_creation_date;
    x_Profile_Variables_Rec.last_updated_by := p_last_updated_by;
    x_Profile_Variables_Rec.last_update_date := p_last_update_date;
    x_Profile_Variables_Rec.last_update_login := p_last_update_login;
    x_Profile_Variables_Rec.object_version_number := p_object_version_number;
    x_Profile_Variables_Rec.application_id := p_application_id;

END Convert_Columns_to_Rec;

----------------------------------------------------------------------------
-- Start of Public Procedure Body Create_Prof_Var
----------------------------------------------------------------------------

PROCEDURE Create_Profile_Variable(
    p_api_version_number   	IN  NUMBER,
    p_init_msg_list        	IN  VARCHAR2,
    p_commit               	IN  VARCHAR2,
    p_validation_level     	IN  VARCHAR2,
    x_return_status        	OUT NOCOPY VARCHAR2,
    x_msg_count            	OUT NOCOPY NUMBER,
    x_msg_data             	OUT NOCOPY VARCHAR2,
    p_block_name           	IN  VARCHAR2,
    p_block_name_code      	IN  VARCHAR2,
    p_description          	IN  VARCHAR2,
    p_sql_stmnt        		IN  VARCHAR2,
    p_seeded_flag               IN  VARCHAR2,
    p_start_date_active    	IN  DATE    ,
    p_end_date_active      	IN  DATE    ,
    p_currency_code	        IN  VARCHAR2,
    --p_form_function_id 	IN  NUMBER   := FND_API.G_MISS_NUM,
    p_object_code		IN  VARCHAR2,
    p_select_clause		IN  VARCHAR2,
    p_from_clause		IN  VARCHAR2,
    p_where_clause		IN  VARCHAR2,
    p_other_clause	 	IN  VARCHAR2,
    p_block_level               IN  VARCHAR2,
    p_CREATED_BY                IN  NUMBER,
    p_CREATION_DATE             IN  DATE,
    p_LAST_UPDATED_BY           IN  NUMBER,
    p_LAST_UPDATE_DATE          IN  DATE,
    p_LAST_UPDATE_LOGIN         IN  NUMBER,
    x_OBJECT_VERSION_NUMBER     OUT NOCOPY NUMBER,
    p_APPLICATION_ID            IN  NUMBER,
    x_block_id          	OUT NOCOPY NUMBER )
IS
l_prof_var_rec  ProfVar_Rec_Type;
l_seeded_flag   VARCHAR2(2) := 'N';
BEGIN

  Convert_Columns_to_Rec (
    p_block_name           	=> p_block_name,
    p_block_name_code      	=> p_block_name_code,
    p_description          	=> p_description,
    p_sql_stmnt        		=> p_sql_stmnt,
    p_seeded_flag               => p_seeded_flag,
    p_start_date_active    	=> p_start_date_active,
    p_end_date_active      	=> p_end_date_active,
    p_currency_code	        => p_currency_code,
    --p_form_function_id 	=> p_form_function_id,
    p_object_code		=> p_object_code,
    p_select_clause		=> p_select_clause,
    p_from_clause		=> p_from_clause,
    p_where_clause		=> p_where_clause,
    p_other_clause	 	=> p_other_clause,
    p_block_level               => p_block_level,
    p_CREATED_BY                => p_CREATED_BY,
    p_CREATION_DATE             => p_CREATION_DATE,
    p_LAST_UPDATED_BY           => p_LAST_UPDATED_BY,
    p_LAST_UPDATE_DATE          => p_LAST_UPDATE_DATE,
    p_LAST_UPDATE_LOGIN         => p_LAST_UPDATE_LOGIN,
    p_APPLICATION_ID            => p_APPLICATION_ID,
    x_Profile_Variables_Rec     => l_prof_var_rec
    );


 Create_Profile_Variable(
    p_api_version_number	=> p_api_version_number,
    p_init_msg_list	=> p_init_msg_list,
    p_commit		=> p_Commit,
    p_validation_level  => p_validation_level,
    p_prof_var_rec 	=> l_prof_var_rec,
    x_object_version_number   => x_object_version_number,
    x_msg_data 		=> x_msg_data,
    x_msg_count 		=> x_msg_count,
    x_return_status 	=> x_return_status,
    x_block_id  		=> x_block_id );

END Create_Profile_Variable;
---Actual procedure starts here

PROCEDURE Create_Profile_Variable(
    P_Api_Version_Number  IN   NUMBER,
    P_Init_Msg_List     IN   	VARCHAR2,
    P_Commit            IN   	VARCHAR2,
    P_Validation_Level  IN   	NUMBER  ,
    P_Prof_Var_Rec	IN	ProfVar_Rec_Type,
    X_Return_Status	OUT NOCOPY 	VARCHAR2,
    X_Msg_Count		OUT NOCOPY	NUMBER,
    X_Msg_Data		OUT NOCOPY	VARCHAR2,
    X_Block_Id          OUT NOCOPY 	NUMBER ,
    x_OBJECT_VERSION_NUMBER   OUT NOCOPY  NUMBER
)
IS

l_api_name	     CONSTANT  VARCHAR2(60) := 'Create_Profile_Variable';
l_api_name_full      CONSTANT  VARCHAR2(61) := G_PKG_NAME || '.' || l_api_name ;
l_api_version        CONSTANT  NUMBER       := 1.0 ;

-- pass the parameter record type into a local
-- record type so that you can assign values

l_prof_var_rec 		ProfVar_Rec_Type := p_prof_var_rec;
l_pvt_prof_var_rec	CSC_Profile_Variable_PVT.ProfVar_Rec_Type;
BEGIN

     -- Standard Start of API Savepoint
     SAVEPOINT   Create_Profile_Variable_Pub ;

     -- Standard Call to check API compatibility
     IF NOT FND_API.Compatible_API_Call(   l_api_version,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME        )
     THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
     END IF ;

     -- Initialize the message list  if p_msg_list is set to TRUE
     IF FND_API.To_Boolean(p_init_msg_list)   THEN
          FND_MSG_PUB.initialize ;
     END IF ;


     Convert_pub_to_pvt_Rec (
     P_Profile_Variables_Rec      => p_prof_var_Rec,
     x_pvt_Profile_Variables_rec  => l_pvt_prof_var_Rec
     );


     -- Initialize the API Return Success to True
     x_return_status := FND_API.G_RET_STS_SUCCESS ;

     CSC_Profile_Variable_PVT.Create_Profile_Variable(
     p_api_version_number    => 1.0,
     p_init_msg_list       	=> FND_API.G_FALSE,
     p_commit              	=> FND_API.G_FALSE,
     p_validation_level    	=> FND_API.G_VALID_LEVEL_FULL,
     x_return_status       	=> x_return_status,
     x_msg_count           	=> x_msg_count,
     x_msg_data            	=> x_msg_data,
     p_prof_var_rec		=> l_pvt_Prof_Var_Rec,
     x_block_id            	=> x_block_id ,
     x_object_version_number   => x_object_version_number  );

     IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR;
     ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;


     -- End of API Body
     -- Standard Check of p_commit
     IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK ;
     END IF ;

     -- Standard call to get  message count and if count is 1 , get message info
     FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
                               p_data => x_msg_data) ;

     -- Begin Exception Handling
  EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
           ROLLBACK TO Create_Profile_Variable_Pub  ;
           x_return_status :=  FND_API.G_RET_STS_ERROR ;
           FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
                                     p_data => x_msg_data) ;
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
           ROLLBACK TO Create_Profile_Variable_Pub  ;
           x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;
           FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
                                     p_data => x_msg_data) ;
     WHEN OTHERS THEN
           ROLLBACK TO Create_Profile_Variable_Pub  ;
           x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;
           IF FND_MSG_PUB.Check_Msg_Level
                          (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
           THEN
           FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
           END IF ;
           FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
                                     p_data => x_msg_data) ;

END Create_Profile_Variable ;

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
    )
IS
l_api_name                CONSTANT VARCHAR2(30) := 'Create_Table_Column';
l_api_version_number      CONSTANT NUMBER   := 1.0;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_Table_Column_PUB;

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

      -- Calling Private package: Create_Table_Column
      -- Hint: Primary key needs to be returned

      CSC_Profile_Variable_PVT.Create_table_column(
       P_Api_Version_Number   => l_api_version_number,
       P_Init_Msg_List        => FND_API.G_FALSE,
       P_Commit               => FND_API.G_FALSE,
       P_Validation_Level     => FND_API.G_VALID_LEVEL_FULL,
       p_Table_Column_Tbl	=> p_table_column_tbl,
       --p_Sql_Stmnt_For_Drilldown    => p_sql_stmnt_for_drilldown,
       --p_BLOCK_ID		      => p_block_id,
       X_TABLE_COLUMN_ID    	=> x_TABLE_COLUMN_ID,
       X_object_version_number   => x_object_version_number,
       X_Return_Status        => x_return_status,
       X_Msg_Count            => x_msg_count,
       X_Msg_Data             => x_msg_data   );

      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

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
           ROLLBACK TO CREATE_Table_Column_PUB  ;
           x_return_status :=  FND_API.G_RET_STS_ERROR ;
           FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
                                     p_data => x_msg_data) ;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
           ROLLBACK TO CREATE_Table_Column_PUB  ;
           x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;
           FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
                                     p_data => x_msg_data) ;
    WHEN OTHERS THEN
           ROLLBACK TO CREATE_Table_Column_PUB  ;
           x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;
           IF FND_MSG_PUB.Check_Msg_Level
                          (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
           THEN
           FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
           END IF ;
           FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
                                     p_data => x_msg_data) ;


End Create_table_column;


-----------------------------------------------------------------
-- This procedure updates CS_PROF_BLOCKS
------------------------------------------------------------------

-- update without record type

PROCEDURE Update_Profile_Variable(
    p_api_version_number  IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2,
    p_commit              IN  VARCHAR2,
    p_validation_level    IN  VARCHAR2,
    x_return_status       OUT NOCOPY VARCHAR2,
    x_msg_count           OUT NOCOPY NUMBER,
    x_msg_data            OUT NOCOPY VARCHAR2,
    p_block_id            IN  NUMBER  ,
    p_block_name          IN  VARCHAR2,
    p_block_name_code     IN  VARCHAR2,
    p_description         IN  VARCHAR2,
    p_currency_code       IN  VARCHAR2,
    p_sql_stmnt       	  IN  VARCHAR2,
    p_seeded_flag         IN  VARCHAR2,
    --p_form_function_id    IN	NUMBER  := FND_API.G_MISS_NUM,
    p_object_code	        IN	VARCHAR2,
    p_start_date_active   IN  DATE,
    p_end_date_active     IN  DATE,
    p_select_clause	  IN  VARCHAR2,
    p_from_clause			IN  VARCHAR2,
    p_where_clause		IN  VARCHAR2,
    p_other_clause		IN  VARCHAR2,
    p_block_level               IN  VARCHAR2,
    p_CREATED_BY              IN  NUMBER,
    p_CREATION_DATE           IN  DATE,
    p_LAST_UPDATED_BY         IN  NUMBER,
    p_LAST_UPDATE_DATE        IN  DATE,
    p_LAST_UPDATE_LOGIN       IN  NUMBER,
    px_OBJECT_VERSION_NUMBER   IN OUT NOCOPY NUMBER,
    p_APPLICATION_ID          IN   NUMBER)
IS
l_prof_var_rec  ProfVar_Rec_Type;

BEGIN
-- convert all the parameters into a record type

    Convert_Columns_to_Rec (
    p_block_name           	=> p_block_name,
    p_block_name_code      	=> p_block_name_code,
    p_description          	=> p_description,
    p_sql_stmnt        		=> p_sql_stmnt,
    p_seeded_flag               => p_seeded_flag,
    p_start_date_active    	=> p_start_date_active,
    p_end_date_active      	=> p_end_date_active,
    p_currency_code	        => p_currency_code,
    --p_form_function_id 	=> p_form_function_id,
    p_object_code		=> p_object_code,
    p_select_clause		=> p_select_clause,
    p_from_clause		=> p_from_clause,
    p_where_clause		=> p_where_clause,
    p_other_clause	 	=> p_other_clause,
    p_block_level               => p_block_level,
    p_CREATED_BY                => p_CREATED_BY,
    p_CREATION_DATE             => p_CREATION_DATE,
    p_LAST_UPDATED_BY           => p_LAST_UPDATED_BY,
    p_LAST_UPDATE_DATE          => p_LAST_UPDATE_DATE,
    p_LAST_UPDATE_LOGIN         => p_LAST_UPDATE_LOGIN,
    p_OBJECT_VERSION_NUMBER     => px_OBJECT_VERSION_NUMBER,
    p_APPLICATION_ID            => p_APPLICATION_ID,
    x_Profile_Variables_Rec     => l_prof_var_rec
    );


    Update_Profile_Variable(
    p_api_version_number => p_api_version_number,
    p_init_msg_list	=> p_init_msg_list,
    p_commit		=> p_Commit ,
    p_validation_level	=> p_validation_level,
    p_prof_var_rec 	=> l_prof_var_Rec,
    px_OBJECT_VERSION_NUMBER   => px_OBJECT_VERSION_NUMBER,
    x_msg_data 		=> x_msg_data,
    x_msg_count 		=> x_msg_count,
    x_return_status 	=> x_return_status );

End;

-- Update with record type...

PROCEDURE Update_Profile_Variable (
    p_api_version_number	IN	VARCHAR2,
    p_init_msg_list		IN	VARCHAR2,
    p_commit			IN	VARCHAR2,
    p_validation_level		IN	VARCHAR2,
    p_prof_var_rec 		IN  	ProfVar_Rec_Type,
    px_OBJECT_VERSION_NUMBER   IN OUT NOCOPY NUMBER ,
    x_return_status		OUT NOCOPY	VARCHAR2,
    x_msg_data			OUT NOCOPY	VARCHAR2,
    x_msg_count			OUT NOCOPY	NUMBER )
IS
l_api_name       CONSTANT  VARCHAR2(30) := 'Update_Profile_Variable' ;
l_api_name_full  CONSTANT  VARCHAR2(61) := G_PKG_NAME || '.' || l_api_name ;
l_api_version    CONSTANT  NUMBER       := 1.0 ;

l_prof_var_rec 		ProfVar_Rec_Type	:= p_prof_var_rec;
l_pvt_prof_var_rec	CSC_Profile_Variable_PVT.ProfVar_Rec_Type;
BEGIN

    -- Standard Start of API Savepoint
    SAVEPOINT Update_Profile_Variable_Pub ;

    -- Standard Call to check API compatibility
    IF NOT FND_API.Compatible_API_Call(   l_api_version,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME        )
    THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
    END IF ;

    --   Initialize the message list  if p_msg_list is set to TRUE
    IF FND_API.To_Boolean(p_init_msg_list)   THEN
          FND_MSG_PUB.initialize ;
    END IF ;


    --   Initialize the API Return Success to True
    x_return_status := FND_API.G_RET_STS_SUCCESS ;

    Convert_pub_to_pvt_Rec (
    P_Profile_Variables_Rec      => p_prof_var_Rec,
    x_pvt_Profile_Variables_rec  => l_pvt_prof_var_Rec
    );



    -- Call Private API to Update

    CSC_Profile_Variable_PVT.Update_Profile_Variable(
    p_api_version_number  => 1.0,
    p_init_msg_list       => FND_API.G_FALSE,
    p_commit              => FND_API.G_FALSE,
    p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
    p_prof_var_rec 	  => l_pvt_prof_var_rec,
    px_OBJECT_VERSION_NUMBER   => px_OBJECT_VERSION_NUMBER,
    x_return_status       => x_return_status,
    x_msg_count           => x_msg_count,
    x_msg_data            => x_msg_data
    );

    IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
	    RAISE FND_API.G_EXC_ERROR;
    ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --   End of API Body
    --   Standard Check of p_commit
    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK ;
    END IF ;

    -- Standard call to get  message count and if count is 1 , get message info
    FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
                               p_data => x_msg_data) ;

    -- Begin Exception Handling
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
           ROLLBACK TO Update_Profile_Variable_Pub  ;
           x_return_status :=  FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
                                     p_data => x_msg_data) ;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
           ROLLBACK TO Update_Profile_Variable_Pub  ;
           x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;
           FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
                                     p_data => x_msg_data) ;
    WHEN OTHERS THEN
           ROLLBACK TO Update_Profile_Variable_Pub  ;
           x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;
           IF FND_MSG_PUB.Check_Msg_Level
                          (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
           THEN
           FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
           END IF ;
           FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
                                     p_data => x_msg_data) ;

END Update_Profile_Variable;


PROCEDURE Update_table_column(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2,
    P_Commit                     IN   VARCHAR2,
    P_Validation_Level		 IN   NUMBER,
    p_Table_Column_Rec		 IN   CSC_Profile_Variable_PVT.Table_Column_Rec_Type,
    --p_Sql_Stmnt_For_Drilldown    IN   VARCHAR2 := FND_API.G_MISS_CHAR,
    --p_BLOCK_ID			   IN	  NUMBER := FND_API.G_MISS_NUM,
    px_OBJECT_VERSION_NUMBER   IN OUT NOCOPY NUMBER ,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )

 IS
l_api_name                CONSTANT VARCHAR2(30) := 'Update_table_column';
l_api_version_number      CONSTANT NUMBER   := 1.0;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Table_Column_PUB;

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

      CSC_profile_variable_PVT.Update_table_column(
       P_Api_Version_Number         => l_api_version_number,
       P_Init_Msg_List              => FND_API.G_FALSE,
       P_Commit                     => p_commit,
       P_Validation_Level           => FND_API.G_VALID_LEVEL_FULL,
       p_Table_Column_REC		=> p_table_Column_REC,
       --p_Sql_Stmnt_for_drilldown 	=> p_sql_stmnt_for_drilldown,
       px_OBJECT_VERSION_NUMBER   => px_OBJECT_VERSION_NUMBER,
       X_Return_Status              => x_return_status,
       X_Msg_Count                  => x_msg_count,
       X_Msg_Data                   => x_msg_data);

      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
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
           ROLLBACK TO UPDATE_Table_Column_PUB  ;
           x_return_status :=  FND_API.G_RET_STS_ERROR ;
           FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
                                     p_data => x_msg_data) ;
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
           ROLLBACK TO UPDATE_Table_Column_PUB  ;
           x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;
           FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
                                     p_data => x_msg_data) ;
      WHEN OTHERS THEN
           ROLLBACK TO UPDATE_Table_Column_PUB  ;
           x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;
           IF FND_MSG_PUB.Check_Msg_Level
                          (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
           THEN
           FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
           END IF ;
           FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
                                     p_data => x_msg_data) ;


End Update_table_column;
END;

/
