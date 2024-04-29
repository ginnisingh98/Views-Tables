--------------------------------------------------------
--  DDL for Package Body IBC_ASSOCIATION_TYPES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBC_ASSOCIATION_TYPES_PVT" AS
/* $Header: ibcvatyb.pls 115.3 2002/11/17 16:06:01 srrangar ship $ */

-- Purpose: API to Populate Association Type.

-- MODIFICATION HISTORY
-- Person            Date        Comments
-- ---------         ------      ------------------------------------------
-- Sri Rangarajan    01/06/2002      Created Package
-- shitij.vatsa      11/04/2002      Updated the record from FND_API.G_MISS_XXX
--                                   to no defaults.
--                                   Changed the OUT to OUT NOCOPY


-- Package name     : Ibc_Association_Types_Pvt
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'Ibc_Association_Types_Pvt';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ibcvatyb.pls';

FUNCTION  Query_Association_type_Row (
              p_Association_type_code 	IN VARCHAR2
) RETURN  Ibc_Association_Types_Pvt.Association_Type_Rec_Type;


PROCEDURE Update_Association_Type(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     ,--:= FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     ,--:= FND_API.G_FALSE,
    P_Validation_Level 			 IN   NUMBER       ,--:= FND_API.G_VALID_LEVEL_FULL,
    P_Association_Type_Rec	 	 IN   Ibc_Association_Types_Pvt.Association_Type_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

FUNCTION IsATypeRecordEmpty(
		 P_Association_Type_Rec  	IN  Ibc_Association_Types_Pvt.Association_Type_Rec_Type)
RETURN BOOLEAN	IS

BEGIN

IF  ((p_Association_type_rec.Association_type_code IS NULL
		OR p_Association_type_rec.Association_type_code = FND_API.G_MISS_CHAR)
		AND (p_Association_type_rec.Association_type_code IS NULL
		OR p_Association_type_rec.Association_type_code = FND_API.G_MISS_CHAR))
		THEN

	RETURN TRUE;

ELSE
	RETURN FALSE;

END IF;

END IsATypeRecordEmpty;


PROCEDURE Validate_Association_Type_Tbl(
   		p_init_msg_list					IN 	VARCHAR2 ,--:= FND_API.G_FALSE,
		p_Association_type_code			IN  VARCHAR2,
    	P_Association_Type_Tbl  		IN  Ibc_Association_Types_Pvt.Association_Type_Tbl_Type,
    	X_Return_Status         		OUT NOCOPY  VARCHAR2,
   		X_Msg_Count             		OUT NOCOPY  NUMBER,
    	X_Msg_Data              		OUT NOCOPY  VARCHAR2)
IS

l_Association_type_rec	Ibc_Association_Types_Pvt.Association_Type_Rec_Type;
l_return_status 		VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

BEGIN

--  Initialize API return status to success
x_return_status := FND_API.G_RET_STS_SUCCESS;


IF	p_Association_type_tbl.COUNT = 0 THEN
	RETURN;
END IF;

FOR i IN p_Association_type_tbl.FIRST..p_Association_type_tbl.LAST LOOP

IF p_Association_type_tbl.EXISTS(i) AND NOT IsATypeRecordEmpty(p_Association_type_tbl(i))
THEN

    l_Association_type_rec := p_Association_type_tbl(i);

  	-- Check for all the NOT NULL Columns
    -- Association_Type_Code Cannot be NULL
       IBC_VALIDATE_PVT.Validate_NotNULL_VARCHAR2 (
       		p_init_msg_list	=> FND_API.G_FALSE,
       		p_column_name	=> 'Association_Type_Code',
       		p_notnull_column=> l_Association_type_rec.Association_type_code,
       		x_return_status => x_return_status,
            x_msg_count     => x_msg_count,
            x_msg_data      => x_msg_data);

  	  IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           l_return_status := x_return_status;
      END IF;


	--
	-- Validate the Association Type Code in Association Rec
	IF (l_Association_type_rec.Association_type_code IS NULL OR
	   l_Association_type_rec.Association_type_code = FND_API.G_MISS_CHAR) THEN
	   l_Association_type_rec.Association_type_code := p_Association_TYPE_CODE;
	ELSE
	   IF l_Association_type_rec.Association_type_code <> p_Association_TYPE_CODE THEN
	   	   x_return_status := FND_API.G_RET_STS_ERROR;
	   	   FND_MESSAGE.Set_Name('IBC', 'Invalid Association TYPE');
              FND_MESSAGE.Set_Token('COLUMN', 'Association_Type_Code', FALSE);
              FND_MSG_PUB.ADD;
	   END IF;
	END IF;

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           l_return_status := x_return_status;
    END IF;


	-- Association_TYpe_Name Cannot be NULL
	IBC_VALIDATE_PVT.Validate_NotNULL_VARCHAR2 (
       		p_init_msg_list	=> FND_API.G_FALSE,
       		p_column_name	=> 'Association_Type_Name',
       		p_notnull_column=> l_Association_type_rec.Association_type_Name,
       		x_return_status => x_return_status,
               x_msg_count     => x_msg_count,
               x_msg_data      => x_msg_data);
END IF;

END LOOP;

x_return_status := l_return_status;

END validate_Association_type_tbl;


PROCEDURE Create_Association_Type(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     ,--:= FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     ,--:= FND_API.G_FALSE,
    P_Validation_Level 			 IN   NUMBER       ,--:= FND_API.G_VALID_LEVEL_FULL,
    P_Association_Type_Rec	 	 IN   Ibc_Association_Types_Pvt.Association_Type_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS

    CURSOR C_Association_Type(p_Association_Type_Code IN VARCHAR2) IS
    SELECT Association_Type_Code
	FROM   ibc_Association_types_b
    WHERE  association_Type_Code = p_Association_Type_Code;

    l_return_status			  VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

	l_api_version_number  	  NUMBER := 1.0;
	l_api_name 				  VARCHAR2(50) := 'Create_Association_Type';
	lx_rowid				  VARCHAR2(240);
	l_Association_type_code	  VARCHAR2(100);

	l_Association_type_rec	  Ibc_Association_Types_Pvt.Association_Type_Rec_Type := P_Association_Type_Rec;

BEGIN

     -- Initialize API return status to SUCCESS
     x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Begin Validation for Association Type Record

  	-- Check for all the NOT NULL Columns
    -- Association_Type_Code Cannot be NULL
       IBC_VALIDATE_PVT.Validate_NotNULL_VARCHAR2 (
       		p_init_msg_list	=> FND_API.G_FALSE,
       		p_column_name	=> 'Association_Type_Code',
       		p_notnull_column=> l_Association_type_rec.Association_type_code,
       		x_return_status => x_return_status,
            x_msg_count     => x_msg_count,
            x_msg_data      => x_msg_data);

  	  IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           l_return_status := x_return_status;
      END IF;

	-- Association_TYpe_Name Cannot be NULL
	IBC_VALIDATE_PVT.Validate_NotNULL_VARCHAR2 (
       		p_init_msg_list	=> FND_API.G_FALSE,
       		p_column_name	=> 'Association_Type_Name',
       		p_notnull_column=> l_Association_type_rec.Association_type_Name,
       		x_return_status => x_return_status,
            x_msg_count     => x_msg_count,
            x_msg_data      => x_msg_data);

  	  IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           l_return_status := x_return_status;
      END IF;

		-- Validate Object Version Number
	 	IF l_Association_type_rec.OBJECT_VERSION_NUMBER IS NULL
		OR l_Association_type_rec.OBJECT_VERSION_NUMBER = FND_API.G_MISS_NUM THEN
		   l_Association_type_rec.OBJECT_VERSION_NUMBER := 1;
		END IF;

 -- Check for Uniqueness
  OPEN  C_Association_Type(p_Association_Type_Code 	=> l_Association_type_rec.Association_type_code);
  FETCH C_Association_Type INTO l_Association_Type_Code;
  IF C_Association_Type%FOUND THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
 	          x_return_status := FND_API.G_RET_STS_ERROR;
              FND_MESSAGE.Set_Name('IBC', 'RECORD Already EXISTS');
              FND_MESSAGE.Set_Token('COLUMN', 'Association_Type_Code',FALSE);
              FND_MSG_PUB.ADD;
      END IF;
  END IF;

  CLOSE C_Association_Type;

IF l_return_status<>FND_API.G_RET_STS_SUCCESS
 OR x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
     RAISE FND_API.G_EXC_ERROR;
END IF;


Ibc_Association_Types_Pkg.insert_row (
	x_rowid						 => lx_rowid,
    p_ASSOCIATION_TYPE_CODE	=>	l_association_type_rec.ASSOCIATION_TYPE_CODE,
    p_ASSOCIATION_TYPE_NAME	=>	l_association_type_rec.ASSOCIATION_TYPE_NAME,
    p_CALL_BACK_PKG	=>	l_association_type_rec.CALL_BACK_PKG,
    p_CREATED_BY	=>	l_association_type_rec.CREATED_BY,
    p_CREATION_DATE	=>	l_association_type_rec.CREATION_DATE,
    p_DESCRIPTION	=>	l_association_type_rec.DESCRIPTION,
    p_LAST_UPDATED_BY	=>	l_association_type_rec.LAST_UPDATED_BY,
    p_LAST_UPDATE_DATE	=>	l_association_type_rec.LAST_UPDATE_DATE,
    p_LAST_UPDATE_LOGIN	=>	l_association_type_rec.LAST_UPDATE_LOGIN,
    p_OBJECT_VERSION_NUMBER	=>	l_association_type_rec.OBJECT_VERSION_NUMBER,
    p_SEARCH_PAGE	=>	l_association_type_rec.SEARCH_PAGE
    );


END create_Association_type;


PROCEDURE Create_Association_Types(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     ,--:= FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     ,--:= FND_API.G_FALSE,
    P_Validation_Level 			 IN   NUMBER       ,--:= FND_API.G_VALID_LEVEL_FULL,
    P_Association_Type_Tbl	 	 IN   Ibc_Association_Types_Pvt.Association_Type_Tbl_Type ,--:= Ibc_Association_Types_Pvt.G_Miss_Association_Type_Tbl,
    X_Return_Status              OUT NOCOPY   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY   NUMBER,
    X_Msg_Data                   OUT NOCOPY   VARCHAR2
    )
IS
    l_temp					  CHAR(1);
	l_return_status			  VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

	l_api_version_number  	  NUMBER := 1.0;
	l_api_name 				  VARCHAR2(50) := 'Create_Association_Type';
	l_Association_Type_Code   VARCHAR2(100);
	lx_rowid				  VARCHAR2(240);

    l_Association_Type_Tbl	  Ibc_Association_Types_Pvt.Association_Type_Tbl_Type := p_Association_Type_Tbl;
	l_Association_type_rec	  Ibc_Association_Types_Pvt.Association_Type_Rec_Type;

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

--dbms_output.put_line('Insert into Association Type Success');
-- Insert The Corresponding Associations in ibc_Association_types_b  table

IF	l_Association_type_tbl.COUNT <> 0 THEN
 FOR i IN l_Association_type_tbl.FIRST..l_Association_type_tbl.LAST LOOP

 IF l_Association_type_tbl.EXISTS(i) AND NOT IsATypeRecordEmpty(l_Association_Type_Tbl(i))
 THEN

 -- l_Association_Type_Tbl(i).Association_type_code := l_Association_type_rec.Association_TYPE_CODE;

            Create_Association_Type(
                P_Api_Version_Number   =>P_Api_Version_Number,
                P_Init_Msg_List        =>P_Init_Msg_List,
                P_Commit               =>P_Commit,
                P_Validation_Level 	   =>FND_API.G_VALID_LEVEL_FULL,
                P_Association_Type_Rec =>l_Association_Type_Tbl(i),
                X_Return_Status        =>X_Return_Status,
                X_Msg_Count            =>X_Msg_Count,
                X_Msg_Data             =>X_Msg_Data);

 END IF;

 END LOOP;

END IF;

---
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

END Create_Association_Types;


PROCEDURE Update_Association_Types(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     ,--:= FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     ,--:= FND_API.G_FALSE,
    P_Validation_Level 			 IN   NUMBER       ,--:= FND_API.G_VALID_LEVEL_FULL,
    P_Association_Type_Tbl	 	 IN   Ibc_Association_Types_Pvt.Association_Type_Tbl_Type ,--:= Ibc_Association_Types_Pvt.G_Miss_Association_Type_Tbl,
    x_Association_Type_Tbl	 	 OUT NOCOPY  Ibc_Association_Types_Pvt.Association_Type_Tbl_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS

    l_temp					  CHAR(1);
	l_return_status			  VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

	l_api_version_number  	  NUMBER := 1.0;
	l_api_name 				  VARCHAR2(50) := 'Update_Association_Type';
	l_Association_Type_Code 	  VARCHAR2(100);
	lx_rowid				  VARCHAR2(240);

    l_Association_Type_Tbl	  Ibc_Association_Types_Pvt.Association_Type_Tbl_Type := p_Association_Type_Tbl;
	l_Association_type_rec	  Ibc_Association_Types_Pvt.Association_Type_Rec_Type;

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

-- Update The Corresponding Associations in ibc_Association_types_b  table

IF	l_Association_type_tbl.COUNT <> 0 THEN

 FOR i IN l_Association_type_tbl.FIRST..l_Association_type_tbl.LAST LOOP

 IF l_Association_type_tbl.EXISTS(i) AND NOT IsATypeRecordEmpty(l_Association_Type_Tbl(i))
 THEN

		    Update_Association_Type(
                P_Api_Version_Number   =>P_Api_Version_Number,
                P_Init_Msg_List        =>P_Init_Msg_List,
                P_Commit               =>P_Commit,
                P_Validation_Level 	   =>FND_API.G_VALID_LEVEL_FULL,
                P_Association_Type_Rec =>l_Association_Type_Tbl(i),
                X_Return_Status        =>X_Return_Status,
                X_Msg_Count            =>X_Msg_Count,
                X_Msg_Data             =>X_Msg_Data);
 END IF;

 END LOOP;

END IF;

---
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

END Update_Association_types;


PROCEDURE delete_Association_Type(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     ,--:= FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     ,--:= FND_API.G_FALSE,
    P_Validation_Level 			 IN   NUMBER       ,--:= FND_API.G_VALID_LEVEL_FULL,
    P_Association_Type_Code		 IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS

    CURSOR C_Association_Type IS
    SELECT
    Association_Type_Code
	FROM ibc_Association_types_b
    WHERE Association_Type_Code = p_Association_Type_Code;


	l_return_status			  VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

	l_api_version_number  	  NUMBER := 1.0;
	l_api_name 				  VARCHAR2(50) := 'Delete_Association_Type';
	l_Association_Type_Code 	  VARCHAR2(100);

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
	  -- Association_TYpe_Code Cannot be NULL
      IBC_VALIDATE_PVT.Validate_NotNULL_VARCHAR2 (
      		p_init_msg_list	=> FND_API.G_FALSE,
      		p_column_name	=> 'Association_Type_Code',
      		p_notnull_column=> p_Association_type_code,
      		x_return_status => x_return_status,
            x_msg_count     => x_msg_count,
            x_msg_data      => x_msg_data);

	  -- Don't RAISE the EXCEPTION Yet. RUN ALL the validation procedures
	  -- and show Exceptions all at once.
  	  IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           l_return_status := x_return_status;
      END IF;


	  -- Check If the Record Exists
	  OPEN  C_Association_Type;
      FETCH C_Association_Type INTO l_Association_Type_Code;
	  IF C_Association_Type%NOTFOUND THEN
	      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.Set_Name('IBC', 'Cannot Find Record to be Deleted');
               FND_MESSAGE.Set_Token('COLUMN', 'Association_Type_Code', FALSE);
               FND_MSG_PUB.ADD;
          END IF;
          CLOSE C_Association_Type;
          RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE C_Association_Type;

  	  OPEN  C_Association_Type;
      FETCH C_Association_Type INTO l_Association_Type_Code;
	  IF C_Association_Type%FOUND THEN
	      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.Set_Name('IBC', 'References_ExistAssociationTypeCode');
               FND_MESSAGE.Set_Token('COLUMN', 'Association_Type_Code', FALSE);
               FND_MSG_PUB.ADD;
          END IF;
          CLOSE C_Association_Type;
          RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE C_Association_Type;


      	  IF x_return_status<>FND_API.G_RET_STS_SUCCESS
		  	 OR l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE FND_API.G_EXC_ERROR;
          END IF;

--
-- Table Handler to Delete Row from IBC_Association_TYPES
--

		Ibc_Association_Types_Pkg.delete_row (
              p_Association_type_code 		   =>p_Association_type_code
            );


        Ibc_Association_Types_Pkg.DELETE_ROW (
             p_Association_TYPE_CODE 		 =>p_Association_TYPE_CODE);


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

END delete_Association_type;

PROCEDURE Update_Association_Type(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     ,--:= FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     ,--:= FND_API.G_FALSE,
    P_Validation_Level 			 IN   NUMBER       ,--:= FND_API.G_VALID_LEVEL_FULL,
    P_Association_Type_Rec	 	 IN   Ibc_Association_Types_Pvt.Association_Type_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS

    CURSOR C_Association_Type(p_Association_Type_Code IN VARCHAR2) IS
    SELECT Association_Type_Code
	FROM ibc_Association_types_b
    WHERE Association_Type_Code = p_Association_Type_Code;

    l_temp					  CHAR(1);
	l_return_status			  VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

	l_api_version_number  	  NUMBER := 1.0;
	l_api_name 				  VARCHAR2(50) := 'Update_Association_Type';
	lx_rowid				  VARCHAR2(240);
	l_Association_type_code		  VARCHAR2(100);

	l_Association_type_rec	  Ibc_Association_Types_Pvt.Association_Type_Rec_Type := P_Association_Type_Rec;
	l_old_Association_type_rec  Ibc_Association_Types_Pvt.Association_Type_Rec_Type;

BEGIN

-- Initialize API return status to SUCCESS
x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Check If Row exists
 l_old_Association_type_rec := Query_Association_Type_Row
 						  	 (p_Association_Type_Code 	=> l_Association_type_rec.Association_type_code);


	-- Begin Validation for Association Type Record
  	-- Check for all the NOT NULL Columns
    -- Association_Type_Code Cannot be NULL
       IBC_VALIDATE_PVT.Validate_NotNULL_VARCHAR2 (
       		p_init_msg_list	=> FND_API.G_FALSE,
       		p_column_name	=> 'Association_Type_Code',
       		p_notnull_column=> l_Association_type_rec.Association_type_code,
       		x_return_status => x_return_status,
            x_msg_count     => x_msg_count,
            x_msg_data      => x_msg_data);

  	  IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           l_return_status := x_return_status;
      END IF;


	IF l_Association_type_rec.Association_type_Name <> FND_API.G_MISS_CHAR THEN
	-- Association_TYpe_Name Cannot be NULL
	IBC_VALIDATE_PVT.Validate_NotNULL_VARCHAR2 (
       		p_init_msg_list	=> FND_API.G_FALSE,
       		p_column_name	=> 'Association_Type_Name',
       		p_notnull_column=> l_Association_type_rec.Association_type_Name,
       		x_return_status => x_return_status,
            x_msg_count     => x_msg_count,
            x_msg_data      => x_msg_data);

  	  IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           l_return_status := x_return_status;
      END IF;

	 END IF;


-- End Validation for Association Type Record

		Ibc_Association_Types_Pkg.Update_row (
         p_ASSOCIATION_TYPE_CODE	=>	l_association_type_rec.ASSOCIATION_TYPE_CODE,
         p_ASSOCIATION_TYPE_NAME	=>	l_association_type_rec.ASSOCIATION_TYPE_NAME,
         p_CALL_BACK_PKG			=>	l_association_type_rec.CALL_BACK_PKG,
         p_DESCRIPTION				=>	l_association_type_rec.DESCRIPTION,
         p_LAST_UPDATED_BY			=>	l_association_type_rec.LAST_UPDATED_BY,
         p_LAST_UPDATE_DATE			=>	l_association_type_rec.LAST_UPDATE_DATE,
         p_LAST_UPDATE_LOGIN		=>	l_association_type_rec.LAST_UPDATE_LOGIN,
         p_OBJECT_VERSION_NUMBER	=>	l_association_type_rec.OBJECT_VERSION_NUMBER,
         p_SEARCH_PAGE				=>	l_association_type_rec.SEARCH_PAGE);

END Update_Association_type;


PROCEDURE delete_Association_Type(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     ,--:= FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     ,--:= FND_API.G_FALSE,
    P_Validation_Level 			 IN   NUMBER       ,--:= FND_API.G_VALID_LEVEL_FULL,
    P_Association_Type_Rec	 	 IN   Ibc_Association_Types_Pvt.Association_Type_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS

    CURSOR C_Association_Type(p_Association_Type_Code IN VARCHAR2) IS
    SELECT Association_Type_Code
	FROM ibc_Association_types_b
    WHERE Association_Type_Code = p_Association_Type_Code;

    l_temp					  CHAR(1);
	l_return_status			  VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

	l_api_version_number  	  NUMBER := 1.0;
	l_api_name 				  VARCHAR2(50) := 'delete_Association_Type';
	lx_rowid				  VARCHAR2(240);
	l_Association_type_code	  VARCHAR2(100);

	l_Association_type_rec	  Ibc_Association_Types_Pvt.Association_Type_Rec_Type := P_Association_Type_Rec;
	l_old_Association_type_rec  Ibc_Association_Types_Pvt.Association_Type_Rec_Type;

BEGIN

-- Initialize API return status to SUCCESS
x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Check If Row exists
 l_old_Association_type_rec := Query_Association_Type_Row
 						  	 (p_Association_Type_Code 	=> l_Association_type_rec.Association_type_code);


	-- Begin Validation for Association Type Record
  	-- Check for all the NOT NULL Columns
    -- Association_Type_Code Cannot be NULL
       IBC_VALIDATE_PVT.Validate_NotNULL_VARCHAR2 (
       		p_init_msg_list	=> FND_API.G_FALSE,
       		p_column_name	=> 'Association_Type_Code',
       		p_notnull_column=> l_Association_type_rec.Association_type_code,
       		x_return_status => x_return_status,
            x_msg_count     => x_msg_count,
            x_msg_data      => x_msg_data);

  	  IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           l_return_status := x_return_status;
      END IF;

	--
	-- Validate the Association Type Code in Association Rec
       IBC_VALIDATE_PVT.Validate_NotNULL_VARCHAR2 (
       		p_init_msg_list	=> FND_API.G_FALSE,
       		p_column_name	=> 'Association_Type_Code',
       		p_notnull_column=> l_Association_type_rec.Association_Type_Code,
       		x_return_status => x_return_status,
            x_msg_count     => x_msg_count,
            x_msg_data      => x_msg_data);

  	  IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           l_return_status := x_return_status;
      END IF;

-- End Validation for Association Type Record

		Ibc_Association_Types_Pkg.delete_row (
              p_Association_type_code 	   =>l_Association_type_rec.Association_type_code);

END delete_Association_type;


FUNCTION  Query_Association_type_Row (
              p_Association_type_code 	IN VARCHAR2)
RETURN  Ibc_Association_Types_Pvt.Association_Type_Rec_Type
IS
l_Association_Type_Rec	 Ibc_Association_Types_Pvt.Association_Type_Rec_Type;
BEGIN
   SELECT
     ASSOCIATION_TYPE_CODE
     ,CALL_BACK_PKG
     ,SEARCH_PAGE
     ,CREATED_BY
     ,CREATION_DATE
     ,LAST_UPDATED_BY
     ,LAST_UPDATE_DATE
     ,LAST_UPDATE_LOGIN
     ,OBJECT_VERSION_NUMBER
     ,ASSOCIATION_TYPE_NAME
     ,DESCRIPTION
   INTO
     l_Association_Type_Rec.ASSOCIATION_TYPE_CODE	,
     l_Association_Type_Rec.CALL_BACK_PKG	,
     l_Association_Type_Rec.SEARCH_PAGE	,
     l_Association_Type_Rec.CREATED_BY	,
     l_Association_Type_Rec.CREATION_DATE	,
     l_Association_Type_Rec.LAST_UPDATED_BY	,
     l_Association_Type_Rec.LAST_UPDATE_DATE	,
     l_Association_Type_Rec.LAST_UPDATE_LOGIN	,
     l_Association_Type_Rec.OBJECT_VERSION_NUMBER	,
     l_Association_Type_Rec.ASSOCIATION_TYPE_NAME	,
     l_Association_Type_Rec.DESCRIPTION
   FROM IBC_Association_TYPES_VL
   WHERE   Association_type_code = p_Association_type_code;

RETURN l_Association_type_rec;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
	RAISE NO_DATA_FOUND;
    WHEN OTHERS THEN
	IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	    FND_MESSAGE.Set_Name('IBC', 'Association TYPE RECORD Error');
	    FND_MSG_PUB.ADD;
	END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Query_Association_Type_Row;

FUNCTION  get_ctype_rec	RETURN  Ibc_Association_Types_Pvt.Association_type_rec_type
IS
    TMP_REC  Ibc_Association_Types_Pvt.Association_type_rec_type;
BEGIN
    RETURN   TMP_REC;
END get_ctype_rec;

END Ibc_Association_Types_Pvt;

/
