--------------------------------------------------------
--  DDL for Package Body IBC_DIRECTORY_NODE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBC_DIRECTORY_NODE_GRP" AS
/* $Header: ibcgdndb.pls 115.5 2003/07/29 21:25:35 enunez ship $ */

-- Purpose: API to Populate Content Type.

-- MODIFICATION HISTORY
-- Person            Date        Comments
-- ---------         ------      ------------------------------------------
-- Sri Rangarajan    01/06/2002      Created Package


-- Package name     : Ibc_Directory_Node_Grp
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'Ibc_Directory_Node_Grp';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ibcgdndb.pls';

FUNCTION  Query_Directory_Node_Row (
              p_Directory_node_id	IN  NUMBER)
RETURN  Ibc_Directory_Node_Grp.Directory_Node_Rec_Type;


PROCEDURE Create_Directory_Node(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_Level 		 IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Directory_Node_Rec	 IN   Ibc_Directory_Node_Grp.Directory_Node_Rec_Type := Ibc_Directory_Node_Grp.G_MISS_Directory_Node_Rec,
	p_parent_dir_node_id	 IN   NUMBER,
    x_Directory_Node_Rec	 OUT NOCOPY  Ibc_Directory_Node_Grp.Directory_Node_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY   NUMBER,
    X_Msg_Data                   OUT NOCOPY   VARCHAR2
    )
IS
    CURSOR C_Directory_Node IS
    SELECT
    Directory_Node_Code
	FROM ibc_Directory_Nodes_b
    WHERE Directory_Node_Code = P_Directory_Node_Rec.Directory_Node_Code
	AND   directory_node_id IN (SELECT child_dir_node_id
	FROM  IBC_DIRECTORY_NODE_RELS WHERE parent_dir_node_id = P_parent_dir_node_id);

    l_temp					  CHAR(1);
	l_return_status			  VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

	l_api_version_number  	  NUMBER := 1.0;
	l_api_name 				  VARCHAR2(50) := 'Create_Directory_Node';
	l_Directory_Node_Code 	  VARCHAR2(100);
	lx_rowid				  VARCHAR2(240);

	lx_DIRECTORY_NODE_REL_ID  NUMBER;


	l_Directory_Node_Rec	  Ibc_Directory_Node_Grp.Directory_Node_Rec_Type   := p_Directory_Node_Rec;

BEGIN

     -- Initialize API return status to SUCCESS
     x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      IF FND_GLOBAL.User_Id IS NULL
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name(' + appShortName +', 'UT_CANNOT_GET_PROFILE_VALUE');
              FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

	  	-- Check for all the NOT NULL Columns
	    -- Directory_Node_Code Cannot be NULL
      Ibc_Validate_Pvt.Validate_NotNULL_VARCHAR2 (
      		p_init_msg_list	=> FND_API.G_FALSE,
      		p_column_name	=> 'Directory_Node_Code',
      		p_notnull_column=> l_Directory_Node_rec.Directory_Node_code,
      		x_return_status => x_return_status,
            x_msg_count     => x_msg_count,
            x_msg_data      => x_msg_data);

	  -- Don't RAISE the EXCEPTION Yet. RUN ALL the validation procedures
	  -- and show Exceptions all at once.
  	  IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           l_return_status := x_return_status;
      END IF;

		-- Directory_Node_Name Cannot be NULL
		Ibc_Validate_Pvt.Validate_NotNULL_VARCHAR2 (
        		p_init_msg_list	=> FND_API.G_FALSE,
        		p_column_name	=> 'Directory_Node_Name',
        		p_notnull_column=> l_Directory_Node_rec.Directory_Node_Name,
        		x_return_status => x_return_status,
                x_msg_count     => x_msg_count,
                x_msg_data      => x_msg_data);

  	  IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           l_return_status := x_return_status;
      END IF;


	  		-- Node_Type Cannot be NULL
		Ibc_Validate_Pvt.Validate_NotNULL_VARCHAR2 (
        		p_init_msg_list	=> FND_API.G_FALSE,
        		p_column_name	=> 'Node_Type',
        		p_notnull_column=> l_Directory_Node_rec.Node_Type,
        		x_return_status => x_return_status,
                x_msg_count     => x_msg_count,
                x_msg_data      => x_msg_data);

  	  IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           l_return_status := x_return_status;
      END IF;


	  -- Check for Uniqueness
	  OPEN  C_Directory_Node;
	  FETCH C_Directory_Node INTO l_Directory_Node_Code;
	  IF C_Directory_Node%FOUND THEN
	      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.Set_Name('IBC', 'Node_Code Already EXISTS');
               FND_MESSAGE.Set_Token('COLUMN', 'Directory_Node_Code', FALSE);
               FND_MSG_PUB.ADD;
          END IF;
          CLOSE C_Directory_Node;
          RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE C_Directory_Node;


	 -- Validate Object Version Number
	 	IF l_Directory_Node_rec.OBJECT_VERSION_NUMBER IS NULL
		OR l_Directory_Node_rec.OBJECT_VERSION_NUMBER = FND_API.G_MISS_NUM THEN
		   l_Directory_Node_rec.OBJECT_VERSION_NUMBER := 1;
		END IF;

--
-- Table Handler to Insert Row into IBC_Directory_NodeS
--
        Ibc_Directory_Nodes_Pkg.INSERT_ROW (
             x_ROWID 					 => lx_rowid,
             px_DIRECTORY_NODE_ID		 =>	l_Directory_Node_rec.DIRECTORY_NODE_ID	,
             p_NODE_TYPE				 =>	l_Directory_Node_rec.NODE_TYPE	,
             p_NODE_STATUS   => l_Directory_Node_rec.NODE_STATUS,
             p_DIRECTORY_PATH => l_Directory_Node_rec.DIRECTORY_PATH,
             p_AVAILABLE_DATE => NULL,
             p_EXPIRATION_DATE => NULL,
             p_HIDDEN_FLAG     => NULL,
             p_DIRECTORY_NODE_CODE		 =>	l_Directory_Node_rec.DIRECTORY_NODE_CODE	,
             p_DIRECTORY_NODE_NAME		 =>	l_Directory_Node_rec.DIRECTORY_NODE_NAME	,
             p_DESCRIPTION				 =>	l_Directory_Node_rec.DESCRIPTION	,
             p_CREATED_BY				 =>	l_Directory_Node_rec.CREATED_BY	,
             p_CREATION_DATE			 =>	l_Directory_Node_rec.CREATION_DATE	,
             p_LAST_UPDATED_BY			 =>	l_Directory_Node_rec.LAST_UPDATED_BY	,
             p_LAST_UPDATE_DATE			 =>	l_Directory_Node_rec.LAST_UPDATE_DATE	,
             p_LAST_UPDATE_LOGIN		 =>	l_Directory_Node_rec.LAST_UPDATE_LOGIN,
			 p_OBJECT_VERSION_NUMBER	 =>	l_Directory_Node_rec.OBJECT_VERSION_NUMBER);


--
-- Add the above Node to the Parent
--
        Ibc_Directory_Node_Rels_Pkg.INSERT_ROW (
             x_ROWID 					=>  lx_rowid,
			 px_DIRECTORY_NODE_REL_ID	=>	lx_DIRECTORY_NODE_REL_ID	,
             p_CHILD_DIR_NODE_ID		=>	l_Directory_Node_rec.DIRECTORY_NODE_ID	,
             p_PARENT_DIR_NODE_ID		=>	p_PARENT_DIR_NODE_ID	,
             p_CREATED_BY				=>	l_Directory_Node_rec.CREATED_BY	,
             p_CREATION_DATE			=>	l_Directory_Node_rec.CREATION_DATE	,
             p_LAST_UPDATED_BY			=>	l_Directory_Node_rec.LAST_UPDATED_BY	,
             p_LAST_UPDATE_DATE			=>	l_Directory_Node_rec.LAST_UPDATE_DATE	,
             p_LAST_UPDATE_LOGIN		=>	l_Directory_Node_rec.LAST_UPDATE_LOGIN	,
             p_OBJECT_VERSION_NUMBER	=>	l_Directory_Node_rec.OBJECT_VERSION_NUMBER);


      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	     FND_MESSAGE.Set_Name('IBC', 'IBC_INSERT_ERROR');
	     FND_MSG_PUB.ADD;
	     END IF;

         IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF;

	  x_Directory_Node_rec := Query_Directory_Node_Row(l_Directory_Node_rec.DIRECTORY_NODE_ID);


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
    	  ROLLBACK;
	      Ibc_Utilities_Pvt.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
		  ,P_PACKAGE_TYPE => Ibc_Utilities_Pvt.G_PVT
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

	  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   	  ROLLBACK;
	      Ibc_Utilities_Pvt.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
		  ,P_PACKAGE_TYPE => Ibc_Utilities_Pvt.G_PVT
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

	  WHEN OTHERS THEN
	   	  ROLLBACK;
	      Ibc_Utilities_Pvt.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => Ibc_Utilities_Pvt.G_EXC_OTHERS
		  ,P_PACKAGE_TYPE => Ibc_Utilities_Pvt.G_PVT
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

END Create_Directory_Node;



PROCEDURE Move_Directory_Node(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_Level 			 IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
	p_Current_parent_node_id	 IN   NUMBER,
	p_New_parent_node_id	 	 IN   NUMBER,
	p_Directory_node_id	 	 	 IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS



    l_temp					  CHAR(1);
	l_return_status			  VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

	l_api_version_number  	  NUMBER := 1.0;
	l_api_name 				  VARCHAR2(50) := 'MOve_Directory_Node';
	l_Directory_Node_Code 	  VARCHAR2(100);

	l_Directory_Node_Rec	 Ibc_Directory_Node_Grp.Directory_Node_Rec_Type;

	l_DIRECTORY_NODE_REL_ID NUMBER;

    CURSOR C_Directory_Node IS
    SELECT
    Directory_Node_Code
	FROM ibc_Directory_Nodes_b
    WHERE Directory_Node_Code = l_Directory_Node_Rec.Directory_Node_Code
	AND directory_node_id IN (SELECT child_dir_node_id
	FROM IBC_DIRECTORY_NODE_RELS WHERE parent_dir_node_id= P_New_parent_node_id);

BEGIN


     -- Initialize API return status to SUCCESS
     x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      IF FND_GLOBAL.User_Id IS NULL
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name(' + appShortName +', 'UT_CANNOT_GET_PROFILE_VALUE');
              FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

  	l_Directory_Node_Rec	:= Query_directory_Node_row(p_directory_node_id);


	  -- Check for all the NOT NULL Columns
	  -- Directory_Node_Code Cannot be NULL
      Ibc_Validate_Pvt.Validate_NotNULL_VARCHAR2 (
      		p_init_msg_list	=> FND_API.G_FALSE,
      		p_column_name	=> 'Directory_Node_id',
      		p_notnull_column=> p_current_parent_node_id,
      		x_return_status => x_return_status,
            x_msg_count     => x_msg_count,
            x_msg_data      => x_msg_data);

	  -- Don't RAISE the EXCEPTION Yet. RUN ALL the validation procedures
	  -- and show Exceptions all at once.
  	  IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           l_return_status := x_return_status;
      END IF;

	  -- Don't RAISE the EXCEPTION Yet. RUN ALL the validation procedures
	  -- and show Exceptions all at once.
	  	  -- Check for all the NOT NULL Columns
	  -- Directory_Node_Code Cannot be NULL
      Ibc_Validate_Pvt.Validate_NotNULL_VARCHAR2 (
      		p_init_msg_list	=> FND_API.G_FALSE,
      		p_column_name	=> 'Directory_Node_id',
      		p_notnull_column=> p_New_parent_node_id,
      		x_return_status => x_return_status,
            x_msg_count     => x_msg_count,
            x_msg_data      => x_msg_data);

	  -- Don't RAISE the EXCEPTION Yet. RUN ALL the validation procedures
	  -- and show Exceptions all at once.
  	  IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           l_return_status := x_return_status;
      END IF;

	  -- Check If the Directory Node Exists under the New Parent
	  -- Check for Uniqueness
	  OPEN  C_Directory_Node;
      FETCH C_Directory_Node INTO l_Directory_Node_Code;
	  IF C_Directory_Node%FOUND THEN
	      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.Set_Name('IBC', 'Node_Code Already EXISTS');
               FND_MESSAGE.Set_Token('COLUMN', 'Directory_Node_Code', FALSE);
               FND_MSG_PUB.ADD;
          END IF;
          CLOSE C_Directory_Node;
          RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE C_Directory_Node;


     SELECT
     	DIRECTORY_NODE_REL_ID
     INTO
     	l_DIRECTORY_NODE_REL_ID
     FROM 	IBC_DIRECTORY_NODE_RELS
     WHERE 	PARENT_DIR_NODE_ID = p_CURRENT_PARENT_NODE_ID
     AND  	CHILD_DIR_NODE_ID  = p_DIRECTORY_NODE_ID;


        Ibc_Directory_Node_Rels_Pkg.UPDATE_ROW (
			 p_DIRECTORY_NODE_REL_ID	=>	l_DIRECTORY_NODE_REL_ID	,
             p_CHILD_DIR_NODE_ID		=>	p_DIRECTORY_NODE_ID	,
             p_PARENT_DIR_NODE_ID		=>	p_New_PARENT_NODE_ID ,
             p_LAST_UPDATED_BY			=>	l_Directory_Node_rec.LAST_UPDATED_BY	,
             p_LAST_UPDATE_DATE			=>	l_Directory_Node_rec.LAST_UPDATE_DATE	,
             p_LAST_UPDATE_LOGIN		=>	l_Directory_Node_rec.LAST_UPDATE_LOGIN	,
             p_OBJECT_VERSION_NUMBER	=>	l_Directory_Node_rec.OBJECT_VERSION_NUMBER);


      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	     FND_MESSAGE.Set_Name('IBC', 'IBC_UPDATE_ERROR');
	     FND_MSG_PUB.ADD;
	     END IF;

         IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR;
         END IF;
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
    	  ROLLBACK;
	      Ibc_Utilities_Pvt.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
		  ,P_PACKAGE_TYPE => Ibc_Utilities_Pvt.G_PVT
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

	  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   	  ROLLBACK;
	      Ibc_Utilities_Pvt.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
		  ,P_PACKAGE_TYPE => Ibc_Utilities_Pvt.G_PVT
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

	  WHEN OTHERS THEN
	   	  ROLLBACK;
	      Ibc_Utilities_Pvt.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => Ibc_Utilities_Pvt.G_EXC_OTHERS
		  ,P_PACKAGE_TYPE => Ibc_Utilities_Pvt.G_PVT
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

END Move_Directory_Node;


PROCEDURE Update_Directory_Node(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_Level 			 IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Directory_Node_Rec		 IN   Ibc_Directory_Node_Grp.Directory_Node_Rec_Type := Ibc_Directory_Node_Grp.G_MISS_Directory_Node_Rec,
	p_parent_dir_node_id		 IN   NUMBER,
    x_Directory_Node_Rec		 OUT NOCOPY  Ibc_Directory_Node_Grp.Directory_Node_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS

    CURSOR C_Directory_Node IS
    SELECT
    Directory_Node_Code
	FROM ibc_Directory_Nodes_b
    WHERE Directory_Node_Code = P_Directory_Node_Rec.Directory_Node_Code
	AND directory_node_id IN (SELECT child_dir_node_id
	FROM IBC_DIRECTORY_NODE_RELS WHERE parent_dir_node_id= P_parent_dir_node_id)
	AND Directory_Node_id <> P_Directory_Node_Rec.directory_node_id;


    l_temp					  CHAR(1);
	l_return_status			  VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

	l_api_version_number  	  NUMBER := 1.0;
	l_api_name 				  VARCHAR2(50) := 'Update_Directory_Node';
	l_Directory_Node_Code 	  VARCHAR2(100);
	lx_rowid				  VARCHAR2(240);

	l_Directory_Node_Rec	 Ibc_Directory_Node_Grp.Directory_Node_Rec_Type   := p_Directory_Node_Rec;
	lx_DIRECTORY_NODE_REL_ID NUMBER;

BEGIN

     -- Initialize API return status to SUCCESS
     x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      IF FND_GLOBAL.User_Id IS NULL
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name(' + appShortName +', 'UT_CANNOT_GET_PROFILE_VALUE');
              FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;


	  -- Check for all the NOT NULL Columns
	  -- Directory_Node_Code Cannot be NULL
      Ibc_Validate_Pvt.Validate_NotNULL_VARCHAR2 (
      		p_init_msg_list	=> FND_API.G_FALSE,
      		p_column_name	=> 'Directory_Node_id',
      		p_notnull_column=> l_Directory_Node_rec.Directory_Node_id,
      		x_return_status => x_return_status,
            x_msg_count     => x_msg_count,
            x_msg_data      => x_msg_data);

	  -- Don't RAISE the EXCEPTION Yet. RUN ALL the validation procedures
	  -- and show Exceptions all at once.
  	  IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           l_return_status := x_return_status;
      END IF;

	  -- Don't RAISE the EXCEPTION Yet. RUN ALL the validation procedures
	  -- and show Exceptions all at once.
  	  IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           l_return_status := x_return_status;
      END IF;

	  -- Check If the Record Exists
	  -- Check for Uniqueness
	  OPEN  C_Directory_Node;
      FETCH C_Directory_Node INTO l_Directory_Node_Code;
	  IF C_Directory_Node%FOUND THEN
	      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.Set_Name('IBC', 'Node_Code Already EXISTS');
               FND_MESSAGE.Set_Token('COLUMN', 'Directory_Node_Code', FALSE);
               FND_MSG_PUB.ADD;
          END IF;
          CLOSE C_Directory_Node;
          RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE C_Directory_Node;


--
-- Table Handler to Update Row into IBC_Directory_NodeS
--
        Ibc_Directory_Nodes_Pkg.UPDATE_ROW (
             p_DIRECTORY_NODE_ID		 =>	l_Directory_Node_rec.DIRECTORY_NODE_ID	,
             p_NODE_TYPE				 =>	l_Directory_Node_rec.NODE_TYPE	,
             p_NODE_STATUS   => l_Directory_Node_rec.NODE_STATUS,
             p_DIRECTORY_PATH => l_Directory_Node_rec.DIRECTORY_PATH,
             p_DIRECTORY_NODE_CODE		 =>	l_Directory_Node_rec.DIRECTORY_NODE_CODE	,
             p_DIRECTORY_NODE_NAME		 =>	l_Directory_Node_rec.DIRECTORY_NODE_NAME	,
             p_DESCRIPTION				 =>	l_Directory_Node_rec.DESCRIPTION	,
             p_LAST_UPDATED_BY			 =>	l_Directory_Node_rec.LAST_UPDATED_BY	,
             p_LAST_UPDATE_DATE			 =>	l_Directory_Node_rec.LAST_UPDATE_DATE	,
             p_LAST_UPDATE_LOGIN		 =>	l_Directory_Node_rec.LAST_UPDATE_LOGIN,
			 p_OBJECT_VERSION_NUMBER	 =>	l_Directory_Node_rec.OBJECT_VERSION_NUMBER);


--         Ibc_Directory_Node_Rels_Pkg.UPDATE_ROW (
-- 			 p_DIRECTORY_NODE_REL_ID	=>	lx_DIRECTORY_NODE_REL_ID	,
--              p_CHILD_DIR_NODE_ID		=>	l_Directory_Node_rec.DIRECTORY_NODE_ID	,
--              p_PARENT_DIR_NODE_ID		=>	p_PARENT_DIR_NODE_ID	,
--              p_LAST_UPDATED_BY			=>	l_Directory_Node_rec.LAST_UPDATED_BY	,
--              p_LAST_UPDATE_DATE			=>	l_Directory_Node_rec.LAST_UPDATE_DATE	,
--              p_LAST_UPDATE_LOGIN		=>	l_Directory_Node_rec.LAST_UPDATE_LOGIN	,
--              p_OBJECT_VERSION_NUMBER	=>	l_Directory_Node_rec.OBJECT_VERSION_NUMBER);


      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	     FND_MESSAGE.Set_Name('IBC', 'IBC_UPDATE_ERROR');
	     FND_MSG_PUB.ADD;
	     END IF;

         IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF;

      --
      -- End of API body
      --

x_Directory_Node_rec := Query_Directory_Node_Row(l_Directory_Node_rec.DIRECTORY_NODE_ID);

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
    	  ROLLBACK;
	      Ibc_Utilities_Pvt.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
		  ,P_PACKAGE_TYPE => Ibc_Utilities_Pvt.G_PVT
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

	  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   	  ROLLBACK;
	      Ibc_Utilities_Pvt.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
		  ,P_PACKAGE_TYPE => Ibc_Utilities_Pvt.G_PVT
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

	  WHEN OTHERS THEN
	   	  ROLLBACK;
	      Ibc_Utilities_Pvt.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => Ibc_Utilities_Pvt.G_EXC_OTHERS
		  ,P_PACKAGE_TYPE => Ibc_Utilities_Pvt.G_PVT
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

END Update_Directory_Node;


PROCEDURE delete_Directory_Node(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_Level 			 IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Directory_Node_id		 	 IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS

    CURSOR C_Directory_Node IS
    SELECT
    Directory_Node_id
	FROM ibc_Directory_Nodes_b
    WHERE Directory_Node_id = p_Directory_Node_id;

	CURSOR C_Child_Nodes IS
	SELECT LPAD(' ',3*(LEVEL-1)) || parent_dir_node_id,child_dir_node_id,directory_node_rel_id
	FROM ibc_directory_node_rels
	START WITH parent_dir_node_id = p_Directory_Node_id
	CONNECT BY PRIOR child_dir_node_id = parent_dir_node_id;

	CURSOR C_Content_Item(p_ci_dir_node_id IN NUMBER) IS
	SELECT directory_node_id FROM ibc_content_items
	WHERE directory_node_id = p_ci_dir_node_id;


	l_return_status			  VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

	l_api_version_number  	  NUMBER := 1.0;
	l_api_name 				  VARCHAR2(50) := 'Delete_Directory_Node';
	l_Directory_Node_ID 	  NUMBER;

BEGIN

     -- Initialize API return status to SUCCESS
     x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      IF FND_GLOBAL.User_Id IS NULL
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name(' + appShortName +', 'UT_CANNOT_GET_PROFILE_VALUE');
              FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;


	  -- Check for all the NOT NULL Columns
	  -- Directory_Node_Code Cannot be NULL
      Ibc_Validate_Pvt.Validate_NotNULL_NUMBER (
      		p_init_msg_list	=> FND_API.G_FALSE,
      		p_column_name	=> 'Directory_Node_ID',
      		p_notnull_column=> p_Directory_Node_ID,
      		x_return_status => x_return_status,
            x_msg_count     => x_msg_count,
            x_msg_data      => x_msg_data);

	  -- Don't RAISE the EXCEPTION Yet. RUN ALL the validation procedures
	  -- and show Exceptions all at once.
  	  IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           l_return_status := x_return_status;
      END IF;


	  -- Check If the Record Exists
	  OPEN  C_Directory_Node;
      FETCH C_Directory_Node INTO l_Directory_Node_id;
	  IF C_Directory_Node%NOTFOUND THEN
	      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.Set_Name('IBC', 'Cannot Find Record to be Deleted');
               FND_MESSAGE.Set_Token('COLUMN', 'Directory_Node_ID', FALSE);
               FND_MSG_PUB.ADD;
          END IF;
          CLOSE C_Directory_Node;
          RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE C_Directory_Node;


   	  IF x_return_status<>FND_API.G_RET_STS_SUCCESS
		  	 OR l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE FND_API.G_EXC_ERROR;
      END IF;

--
-- Table Handler to Delete Row from IBC_Directory_Node
--

FOR i_rec IN C_Child_Nodes
LOOP
	  -- Check If Content Items exists in this Node
	  OPEN  C_Content_Item(p_ci_dir_node_id =>i_rec.child_dir_Node_id);
      FETCH C_Content_Item INTO l_Directory_Node_id;
	  IF C_Directory_Node%FOUND THEN
	      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.Set_Name('IBC', 'Content Items Exists in this Node');
               FND_MESSAGE.Set_Token('COLUMN', 'Directory_Node_ID', FALSE);
               FND_MSG_PUB.ADD;
          END IF;
          CLOSE C_Content_Item;
          RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE C_Content_Item;


        Ibc_Directory_Nodes_Pkg.DELETE_ROW (
             p_Directory_Node_ID 		 =>i_rec.child_dir_Node_id);
		Ibc_Directory_Node_Rels_Pkg.delete_row(
			 p_directory_node_rel_id =>i_rec.directory_node_rel_id);
END LOOP;


      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	     FND_MESSAGE.Set_Name('IBC', 'IBC_DELETE_ERROR');
	     FND_MSG_PUB.ADD;
	     END IF;

         IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
          RAISE FND_API.G_EXC_ERROR;
         END IF;
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
    	  ROLLBACK;
	      Ibc_Utilities_Pvt.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
		  ,P_PACKAGE_TYPE => Ibc_Utilities_Pvt.G_PVT
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

	  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	   	  ROLLBACK;
	      Ibc_Utilities_Pvt.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
		  ,P_PACKAGE_TYPE => Ibc_Utilities_Pvt.G_PVT
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

	  WHEN OTHERS THEN
	   	  ROLLBACK;
	      Ibc_Utilities_Pvt.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => Ibc_Utilities_Pvt.G_EXC_OTHERS
		  ,P_PACKAGE_TYPE => Ibc_Utilities_Pvt.G_PVT
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

END delete_Directory_Node;

FUNCTION  Query_Directory_Node_Row (
              p_Directory_node_id	IN  NUMBER)
RETURN  Ibc_Directory_Node_Grp.Directory_Node_Rec_Type
IS
l_Directory_node_Rec	 Ibc_Directory_Node_Grp.Directory_Node_Rec_Type;
BEGIN

SELECT
   DIRECTORY_NODE_ID	,
   DIRECTORY_NODE_CODE	,
   NODE_TYPE	,
   CREATED_BY	,
   CREATION_DATE	,
   LAST_UPDATED_BY	,
   LAST_UPDATE_DATE	,
   LAST_UPDATE_LOGIN	,
   OBJECT_VERSION_NUMBER	,
   DIRECTORY_NODE_NAME	,
   DESCRIPTION
INTO
   l_directory_node_rec.DIRECTORY_NODE_ID	,
   l_directory_node_rec.DIRECTORY_NODE_CODE	,
   l_directory_node_rec.NODE_TYPE	,
   l_directory_node_rec.CREATED_BY	,
   l_directory_node_rec.CREATION_DATE	,
   l_directory_node_rec.LAST_UPDATED_BY	,
   l_directory_node_rec.LAST_UPDATE_DATE	,
   l_directory_node_rec.LAST_UPDATE_LOGIN	,
   l_directory_node_rec.OBJECT_VERSION_NUMBER	,
   l_directory_node_rec.DIRECTORY_NODE_NAME	,
   l_directory_node_rec.DESCRIPTION
FROM IBC_DIRECTORY_NODES_VL
WHERE directory_node_id = p_directory_node_id;

RETURN l_Directory_node_rec;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
	RAISE NO_DATA_FOUND;
    WHEN OTHERS THEN
	IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	    FND_MESSAGE.Set_Name('IBC', 'Directory Node RECORD Error');
	    FND_MSG_PUB.ADD;
	END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Query_Directory_Node_Row;

FUNCTION  get_directory_node_rec	RETURN  Ibc_Directory_Node_Grp.Directory_Node_rec_type
IS
    TMP_REC  Ibc_Directory_Node_Grp.Directory_Node_rec_type;
BEGIN
    RETURN   TMP_REC;
END get_directory_node_rec;

END Ibc_Directory_Node_Grp;

/
