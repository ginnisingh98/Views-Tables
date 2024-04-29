--------------------------------------------------------
--  DDL for Package Body IBC_LABELS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBC_LABELS_GRP" AS
/* $Header: ibcglabb.pls 115.3 2002/11/13 23:45:35 vicho ship $ */

-- Purpose: API to Populate Association Type.

-- MODIFICATION HISTORY
-- Person            Date        Comments
-- ---------         ------      ------------------------------------------
-- Sri Rangarajan    01/06/2002      Created Package


-- Package name     : Ibc_Labels_GRP
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'Ibc_Labels_GRP';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ibcglabb.pls';

FUNCTION  Query_Label_Row (
              p_Label_code 	IN VARCHAR2
) RETURN  Ibc_Labels_GRP.Label_Rec_Type;


PROCEDURE Update_Label(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_Level 			 IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Label_Rec	 	 IN   Ibc_Labels_GRP.Label_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );


FUNCTION IsLabelRecordEmpty(
		 P_Label_Rec  	IN  Ibc_Labels_GRP.Label_Rec_Type)
RETURN BOOLEAN	IS

BEGIN

IF  ((p_Label_rec.Label_code IS NULL
		OR p_Label_rec.Label_code = FND_API.G_MISS_CHAR)
		AND (p_Label_rec.Label_code IS NULL
		OR p_Label_rec.Label_code = FND_API.G_MISS_CHAR))
		THEN

	RETURN TRUE;

ELSE
	RETURN FALSE;

END IF;

END IsLabelRecordEmpty;


PROCEDURE Validate_Label_Tbl(
   		p_init_msg_list					IN 	VARCHAR2 := FND_API.G_FALSE,
		p_Label_code			IN  VARCHAR2,
    	P_Label_Tbl  		IN  Ibc_Labels_GRP.Label_Tbl_Type,
    	X_Return_Status         		OUT NOCOPY  VARCHAR2,
   		X_Msg_Count             		OUT NOCOPY  NUMBER,
    	X_Msg_Data              		OUT NOCOPY  VARCHAR2)
IS

l_Label_rec	Ibc_Labels_GRP.Label_Rec_Type;
l_return_status 		VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

BEGIN

--  Initialize API return status to success
x_return_status := FND_API.G_RET_STS_SUCCESS;


IF	p_Label_tbl.COUNT = 0 THEN
	RETURN;
END IF;

FOR i IN p_Label_tbl.FIRST..p_Label_tbl.LAST LOOP

IF p_Label_tbl.EXISTS(i) AND NOT IsLabelRecordEmpty(p_Label_tbl(i))
THEN

    l_Label_rec := p_Label_tbl(i);

  	-- Check for all the NOT NULL Columns
    -- Label_Code Cannot be NULL
       IBC_VALIDATE_PVT.VALidate_NotNULL_VARCHAR2 (
       		p_init_msg_list	=> FND_API.G_FALSE,
       		p_column_name	=> 'Label_Code',
       		p_notnull_column=> l_Label_rec.Label_code,
       		x_return_status => x_return_status,
            x_msg_count     => x_msg_count,
            x_msg_data      => x_msg_data);

  	  IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           l_return_status := x_return_status;
      END IF;


	--
	-- Validate the Association Type Code in Association Rec
	IF (l_Label_rec.Label_code IS NULL OR
	   l_Label_rec.Label_code = FND_API.G_MISS_CHAR) THEN
	   l_Label_rec.Label_code := p_Label_CODE;
	ELSE
	   IF l_Label_rec.Label_code <> p_Label_CODE THEN
	   	   x_return_status := FND_API.G_RET_STS_ERROR;
	   	   FND_MESSAGE.Set_Name('IBC', 'Invalid Association TYPE');
              FND_MESSAGE.Set_Token('COLUMN', 'Label_Code', FALSE);
              FND_MSG_PUB.ADD;
	   END IF;
	END IF;

	IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           l_return_status := x_return_status;
    END IF;


	-- Label_Name Cannot be NULL
	IBC_VALIDATE_PVT.VALidate_NotNULL_VARCHAR2 (
       		p_init_msg_list	=> FND_API.G_FALSE,
       		p_column_name	=> 'Label_Name',
       		p_notnull_column=> l_Label_rec.Label_Name,
       		x_return_status => x_return_status,
               x_msg_count     => x_msg_count,
               x_msg_data      => x_msg_data);
END IF;

END LOOP;

x_return_status := l_return_status;

END validate_Label_tbl;


PROCEDURE Create_Label(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_Level 			 IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Label_Rec	 	 			 IN   Ibc_Labels_GRP.Label_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS

    CURSOR C_Label(p_Label_Code IN VARCHAR2) IS
    SELECT Label_Code
	FROM   ibc_Labels_b
    WHERE  Label_Code = p_Label_Code;

    l_return_status			  VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

	l_api_version_number  	  NUMBER := 1.0;
	l_api_name 				  VARCHAR2(50) := 'Create_Label';
	lx_rowid				  VARCHAR2(240);
	l_Label_code	  VARCHAR2(100);

	l_Label_rec	  Ibc_Labels_GRP.Label_Rec_Type := P_Label_Rec;

BEGIN

     -- Initialize API return status to SUCCESS
     x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Begin Validation for Association Type Record

  	-- Check for all the NOT NULL Columns
    -- Label_Code Cannot be NULL
       IBC_VALIDATE_PVT.VALidate_NotNULL_VARCHAR2 (
       		p_init_msg_list	=> FND_API.G_FALSE,
       		p_column_name	=> 'Label_Code',
       		p_notnull_column=> l_Label_rec.Label_code,
       		x_return_status => x_return_status,
            x_msg_count     => x_msg_count,
            x_msg_data      => x_msg_data);

  	  IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           l_return_status := x_return_status;
      END IF;

	-- Label_Name Cannot be NULL
	IBC_VALIDATE_PVT.VALidate_NotNULL_VARCHAR2 (
       		p_init_msg_list	=> FND_API.G_FALSE,
       		p_column_name	=> 'Label_Name',
       		p_notnull_column=> l_Label_rec.Label_Name,
       		x_return_status => x_return_status,
            x_msg_count     => x_msg_count,
            x_msg_data      => x_msg_data);

  	  IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           l_return_status := x_return_status;
      END IF;

		-- Validate Object Version Number
	 	IF l_Label_rec.OBJECT_VERSION_NUMBER IS NULL
		OR l_Label_rec.OBJECT_VERSION_NUMBER = FND_API.G_MISS_NUM THEN
		   l_Label_rec.OBJECT_VERSION_NUMBER := 1;
		END IF;

 -- Check for Uniqueness
  OPEN  C_Label(p_Label_Code 	=> l_Label_rec.Label_code);
  FETCH C_Label INTO l_Label_Code;
  IF C_Label%FOUND THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
 	          x_return_status := FND_API.G_RET_STS_ERROR;
              FND_MESSAGE.Set_Name('IBC', 'RECORD Already EXISTS');
              FND_MESSAGE.Set_Token('COLUMN', 'Label_Code',FALSE);
              FND_MSG_PUB.ADD;
      END IF;
  END IF;

  CLOSE C_Label;

IF l_return_status<>FND_API.G_RET_STS_SUCCESS
 OR x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
     RAISE FND_API.G_EXC_ERROR;
END IF;


       Ibc_Labels_Pkg.insert_row (
       	   x_rowid			 	 => lx_rowid,
           p_Label_CODE	 	 	 =>	l_Label_rec.Label_CODE,
           p_Label_NAME		 	 =>	l_Label_rec.Label_NAME,
           p_CREATED_BY		 	 =>	l_Label_rec.CREATED_BY,
           p_CREATION_DATE	 	 =>	l_Label_rec.CREATION_DATE,
           p_DESCRIPTION	 	 =>	l_Label_rec.DESCRIPTION,
           p_LAST_UPDATED_BY	 =>	l_Label_rec.LAST_UPDATED_BY,
           p_LAST_UPDATE_DATE	 =>	l_Label_rec.LAST_UPDATE_DATE,
           p_LAST_UPDATE_LOGIN	 =>	l_Label_rec.LAST_UPDATE_LOGIN,
           p_OBJECT_VERSION_NUMBER	=>	l_Label_rec.OBJECT_VERSION_NUMBER
           );


END create_Label;


PROCEDURE Create_Labels(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_Level 			 IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Label_Tbl	 	 			 IN   Ibc_Labels_GRP.Label_Tbl_Type := Ibc_Labels_GRP.G_Miss_Label_Tbl,
    x_Label_Tbl	 	 			 OUT NOCOPY   Ibc_Labels_GRP.Label_Tbl_Type,
    X_Return_Status              OUT NOCOPY   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY   NUMBER,
    X_Msg_Data                   OUT NOCOPY   VARCHAR2
    )
IS
    l_temp					  CHAR(1);
	l_return_status			  VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

	l_api_version_number  	  NUMBER := 1.0;
	l_api_name 				  VARCHAR2(50) := 'Create_Label';
	l_Label_Code   			  VARCHAR2(100);
	lx_rowid				  VARCHAR2(240);

    l_Label_Tbl	  Ibc_Labels_GRP.Label_Tbl_Type := p_Label_Tbl;
	l_Label_rec	  Ibc_Labels_GRP.Label_Rec_Type;

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
-- Insert The Corresponding Associations in ibc_Labels_b  table

IF	l_Label_tbl.COUNT <> 0 THEN
 FOR i IN l_Label_tbl.FIRST..l_Label_tbl.LAST LOOP

 IF l_Label_tbl.EXISTS(i) AND NOT IsLabelRecordEmpty(l_Label_Tbl(i))
 THEN

 -- l_Label_Tbl(i).Label_code := l_Label_rec.Label_CODE;

            Create_Label(
                P_Api_Version_Number   =>P_Api_Version_Number,
                P_Init_Msg_List        =>P_Init_Msg_List,
                P_Commit               =>P_Commit,
                P_Validation_Level 	   =>FND_API.G_VALID_LEVEL_FULL,
                P_Label_Rec 		   =>l_Label_Tbl(i),
                X_Return_Status        =>X_Return_Status,
                X_Msg_Count            =>X_Msg_Count,
                X_Msg_Data             =>X_Msg_Data);

	x_Label_Tbl(i) := Query_Label_Row (p_Label_code=>l_Label_Tbl(i).label_code);

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

END Create_Labels;


PROCEDURE Update_Labels(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_Level 			 IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Label_Tbl	 	 IN   Ibc_Labels_GRP.Label_Tbl_Type := Ibc_Labels_GRP.G_Miss_Label_Tbl,
    x_Label_Tbl	 	 OUT NOCOPY  Ibc_Labels_GRP.Label_Tbl_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS

    l_temp					  CHAR(1);
	l_return_status			  VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

	l_api_version_number  	  NUMBER := 1.0;
	l_api_name 				  VARCHAR2(50) := 'Update_Label';
	l_Label_Code 	  VARCHAR2(100);
	lx_rowid				  VARCHAR2(240);

    l_Label_Tbl	  Ibc_Labels_GRP.Label_Tbl_Type := p_Label_Tbl;
	l_Label_rec	  Ibc_Labels_GRP.Label_Rec_Type;

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

-- Update The Corresponding Associations in ibc_Labels_b  table

IF	l_Label_tbl.COUNT <> 0 THEN

 FOR i IN l_Label_tbl.FIRST..l_Label_tbl.LAST LOOP

 IF l_Label_tbl.EXISTS(i) AND NOT IsLabelRecordEmpty(l_Label_Tbl(i))
 THEN

		    Update_Label(
                P_Api_Version_Number   =>P_Api_Version_Number,
                P_Init_Msg_List        =>P_Init_Msg_List,
                P_Commit               =>P_Commit,
                P_Validation_Level 	   =>FND_API.G_VALID_LEVEL_FULL,
                P_Label_Rec 		   =>l_Label_Tbl(i),
                X_Return_Status        =>X_Return_Status,
                X_Msg_Count            =>X_Msg_Count,
                X_Msg_Data             =>X_Msg_Data);

	x_Label_Tbl(i) := Query_Label_Row (p_Label_code=>l_Label_Tbl(i).label_code);

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

END Update_Labels;


PROCEDURE delete_Label(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_Level 			 IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Label_Code		 IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS

    CURSOR C_Label IS
    SELECT
    Label_Code
	FROM ibc_Labels_b
    WHERE Label_Code = p_Label_Code;


	l_return_status			  VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

	l_api_version_number  	  NUMBER := 1.0;
	l_api_name 				  VARCHAR2(50) := 'Delete_Label';
	l_Label_Code 	  VARCHAR2(100);

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
	  -- Label_Code Cannot be NULL
      IBC_VALIDATE_PVT.VALidate_NotNULL_VARCHAR2 (
      		p_init_msg_list	=> FND_API.G_FALSE,
      		p_column_name	=> 'Label_Code',
      		p_notnull_column=> p_Label_code,
      		x_return_status => x_return_status,
            x_msg_count     => x_msg_count,
            x_msg_data      => x_msg_data);

	  -- Don't RAISE the EXCEPTION Yet. RUN ALL the validation procedures
	  -- and show Exceptions all at once.
  	  IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           l_return_status := x_return_status;
      END IF;


	  -- Check If the Record Exists
	  OPEN  C_Label;
      FETCH C_Label INTO l_Label_Code;
	  IF C_Label%NOTFOUND THEN
	      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.Set_Name('IBC', 'Cannot Find Record to be Deleted');
               FND_MESSAGE.Set_Token('COLUMN', 'Label_Code', FALSE);
               FND_MSG_PUB.ADD;
          END IF;
          CLOSE C_Label;
          RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE C_Label;

  	  OPEN  C_Label;
      FETCH C_Label INTO l_Label_Code;
	  IF C_Label%FOUND THEN
	      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
               FND_MESSAGE.Set_Name('IBC', 'References_ExistAssociationTypeCode');
               FND_MESSAGE.Set_Token('COLUMN', 'Label_Code', FALSE);
               FND_MSG_PUB.ADD;
          END IF;
          CLOSE C_Label;
          RAISE FND_API.G_EXC_ERROR;
      END IF;
      CLOSE C_Label;


      	  IF x_return_status<>FND_API.G_RET_STS_SUCCESS
		  	 OR l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE FND_API.G_EXC_ERROR;
          END IF;

--
-- Table Handler to Delete Row from IBC_LabelS
--

		Ibc_Labels_Pkg.delete_row (
              p_Label_code 		   =>p_Label_code
            );


        Ibc_Labels_Pkg.DELETE_ROW (
             p_Label_CODE 		 =>p_Label_CODE);


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

END delete_Label;

PROCEDURE Update_Label(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_Level 			 IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Label_Rec	 	 IN   Ibc_Labels_GRP.Label_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS

    CURSOR C_Label(p_Label_Code IN VARCHAR2) IS
    SELECT Label_Code
	FROM ibc_Labels_b
    WHERE Label_Code = p_Label_Code;

    l_temp					  CHAR(1);
	l_return_status			  VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

	l_api_version_number  	  NUMBER := 1.0;
	l_api_name 				  VARCHAR2(50) := 'Update_Label';
	lx_rowid				  VARCHAR2(240);
	l_Label_code		  VARCHAR2(100);

	l_Label_rec	  Ibc_Labels_GRP.Label_Rec_Type := P_Label_Rec;
	l_old_Label_rec  Ibc_Labels_GRP.Label_Rec_Type;

BEGIN

-- Initialize API return status to SUCCESS
x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Check If Row exists
 l_old_Label_rec := Query_Label_Row
 						  	 (p_Label_Code 	=> l_Label_rec.Label_code);


	-- Begin Validation for Association Type Record
  	-- Check for all the NOT NULL Columns
    -- Label_Code Cannot be NULL
       IBC_VALIDATE_PVT.VALidate_NotNULL_VARCHAR2 (
       		p_init_msg_list	=> FND_API.G_FALSE,
       		p_column_name	=> 'Label_Code',
       		p_notnull_column=> l_Label_rec.Label_code,
       		x_return_status => x_return_status,
            x_msg_count     => x_msg_count,
            x_msg_data      => x_msg_data);

  	  IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           l_return_status := x_return_status;
      END IF;


	IF l_Label_rec.Label_Name <> FND_API.G_MISS_CHAR THEN
	-- Label_Name Cannot be NULL
	IBC_VALIDATE_PVT.VALidate_NotNULL_VARCHAR2 (
       		p_init_msg_list	=> FND_API.G_FALSE,
       		p_column_name	=> 'Label_Name',
       		p_notnull_column=> l_Label_rec.Label_Name,
       		x_return_status => x_return_status,
            x_msg_count     => x_msg_count,
            x_msg_data      => x_msg_data);

  	  IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           l_return_status := x_return_status;
      END IF;

	 END IF;


-- End Validation for Association Type Record

		Ibc_Labels_Pkg.Update_row (
         p_Label_CODE	=>	l_Label_rec.Label_CODE,
         p_Label_NAME	=>	l_Label_rec.Label_NAME,
         p_DESCRIPTION				=>	l_Label_rec.DESCRIPTION,
         p_LAST_UPDATED_BY			=>	l_Label_rec.LAST_UPDATED_BY,
         p_LAST_UPDATE_DATE			=>	l_Label_rec.LAST_UPDATE_DATE,
         p_LAST_UPDATE_LOGIN		=>	l_Label_rec.LAST_UPDATE_LOGIN,
         p_OBJECT_VERSION_NUMBER	=>	l_Label_rec.OBJECT_VERSION_NUMBER
		 );

END Update_Label;


PROCEDURE delete_Label(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    P_Validation_Level 			 IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_Label_Rec	 	 IN   Ibc_Labels_GRP.Label_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS

    CURSOR C_Label(p_Label_Code IN VARCHAR2) IS
    SELECT Label_Code
	FROM ibc_Labels_b
    WHERE Label_Code = p_Label_Code;

    l_temp					  CHAR(1);
	l_return_status			  VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

	l_api_version_number  	  NUMBER := 1.0;
	l_api_name 				  VARCHAR2(50) := 'delete_Label';
	lx_rowid				  VARCHAR2(240);
	l_Label_code	  VARCHAR2(100);

	l_Label_rec	  Ibc_Labels_GRP.Label_Rec_Type := P_Label_Rec;
	l_old_Label_rec  Ibc_Labels_GRP.Label_Rec_Type;

BEGIN

-- Initialize API return status to SUCCESS
x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Check If Row exists
 l_old_Label_rec := Query_Label_Row
 						  	 (p_Label_Code 	=> l_Label_rec.Label_code);


	-- Begin Validation for Association Type Record
  	-- Check for all the NOT NULL Columns
    -- Label_Code Cannot be NULL
       IBC_VALIDATE_PVT.VALidate_NotNULL_VARCHAR2 (
       		p_init_msg_list	=> FND_API.G_FALSE,
       		p_column_name	=> 'Label_Code',
       		p_notnull_column=> l_Label_rec.Label_code,
       		x_return_status => x_return_status,
            x_msg_count     => x_msg_count,
            x_msg_data      => x_msg_data);

  	  IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           l_return_status := x_return_status;
      END IF;

	--
	-- Validate the Association Type Code in Association Rec
       IBC_VALIDATE_PVT.VALidate_NotNULL_VARCHAR2 (
       		p_init_msg_list	=> FND_API.G_FALSE,
       		p_column_name	=> 'Label_Code',
       		p_notnull_column=> l_Label_rec.Label_Code,
       		x_return_status => x_return_status,
            x_msg_count     => x_msg_count,
            x_msg_data      => x_msg_data);

  	  IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           l_return_status := x_return_status;
      END IF;

-- End Validation for Association Type Record

		Ibc_Labels_Pkg.delete_row (
              p_Label_code 	   =>l_Label_rec.Label_code);

END delete_Label;


FUNCTION  Query_Label_Row (
              p_Label_code 	IN VARCHAR2)
RETURN  Ibc_Labels_GRP.Label_Rec_Type
IS
l_Label_Rec	 Ibc_Labels_GRP.Label_Rec_Type;
BEGIN
   SELECT
     Label_CODE
     ,CREATED_BY
     ,CREATION_DATE
     ,LAST_UPDATED_BY
     ,LAST_UPDATE_DATE
     ,LAST_UPDATE_LOGIN
     ,OBJECT_VERSION_NUMBER
     ,Label_NAME
     ,DESCRIPTION
   INTO
     l_Label_Rec.Label_CODE	,
     l_Label_Rec.CREATED_BY	,
     l_Label_Rec.CREATION_DATE	,
     l_Label_Rec.LAST_UPDATED_BY	,
     l_Label_Rec.LAST_UPDATE_DATE	,
     l_Label_Rec.LAST_UPDATE_LOGIN	,
     l_Label_Rec.OBJECT_VERSION_NUMBER	,
     l_Label_Rec.Label_NAME	,
     l_Label_Rec.DESCRIPTION
   FROM IBC_LabelS_VL
   WHERE   Label_code = p_Label_code;

RETURN l_Label_rec;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
	RAISE NO_DATA_FOUND;
    WHEN OTHERS THEN
	IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	    FND_MESSAGE.Set_Name('IBC', 'Association TYPE RECORD Error');
	    FND_MSG_PUB.ADD;
	END IF;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Query_Label_Row;

FUNCTION  get_label_rec	RETURN  Ibc_Labels_GRP.Label_rec_type
IS
    TMP_REC  Ibc_Labels_GRP.Label_rec_type;
BEGIN
    RETURN   TMP_REC;
END get_label_rec;

END Ibc_Labels_GRP;

/
