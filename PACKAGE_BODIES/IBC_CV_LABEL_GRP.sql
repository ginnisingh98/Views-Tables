--------------------------------------------------------
--  DDL for Package Body IBC_CV_LABEL_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBC_CV_LABEL_GRP" AS
/* $Header: ibcgcvlb.pls 115.5 2002/11/15 00:48:46 svatsa ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30):= 'IBC_CV_LABEL_GRP';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ibcgcvlb.pls';

FUNCTION  Query_CV_Label_Row (
              p_content_item_id IN NUMBER,
              p_Label_code 		IN VARCHAR2
) RETURN  Ibc_Cv_Label_Grp.CV_Label_Rec_Type;



PROCEDURE Create_CV_Label(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     ,--:= Fnd_Api.G_FALSE,
    P_Commit                     IN   VARCHAR2     ,--:= Fnd_Api.G_FALSE,
    P_Validation_Level 			 IN   NUMBER       ,--:= Fnd_Api.G_VALID_LEVEL_FULL,
    P_CV_Label_Rec		 		 IN   Ibc_Cv_Label_Grp.CV_Label_Rec_Type ,--:= Ibc_Cv_Label_Grp.G_MISS_CV_Label_Rec,
    x_CV_Label_Rec		 		 OUT NOCOPY  Ibc_Cv_Label_Grp.CV_Label_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY   NUMBER,
    X_Msg_Data                   OUT NOCOPY   VARCHAR2
    )
IS
    CURSOR C_CV_Label IS
    SELECT
	label_code
	FROM   IBC_CITEM_VERSION_LABELS
    WHERE  Label_Code = P_CV_Label_Rec.Label_Code
	AND    content_item_id = P_CV_Label_Rec.content_item_id;

	l_api_version_number  	  NUMBER := 1.0;
	l_api_name 				  VARCHAR2(50) := 'Create_CV_Label';
	l_CV_Label_Code 	  	  VARCHAR2(100);
	lx_rowid				  VARCHAR2(240);

	l_CV_Label_Rec	  Ibc_Cv_Label_Grp.CV_Label_Rec_Type   := p_CV_Label_Rec;

BEGIN

     -- Initialize API return status to SUCCESS
     x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      IF Fnd_Global.User_Id IS NULL
      THEN
          IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR)
          THEN
              Fnd_Message.Set_Name(' + appShortName +', 'UT_CANNOT_GET_PROFILE_VALUE');
              Fnd_Message.Set_Token('PROFILE', 'USER_ID', FALSE);
              Fnd_Msg_Pub.ADD;
          END IF;
          RAISE Fnd_Api.G_EXC_ERROR;
      END IF;

	  	-- Check for all the NOT NULL Columns
	    -- CV_Label_Code Cannot be NULL and must exist in IBC_LABELS
    	IF (Ibc_Validate_Pvt.isValidLabel(l_CV_Label_rec.Label_code) = Fnd_Api.g_false) THEN
            IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
    	       Fnd_Message.Set_Name('IBC', 'INVALID_LABEL_CODE');
    	       Fnd_Message.Set_token('LABEL_CODE', l_CV_Label_rec.Label_code);
    	       Fnd_Msg_Pub.ADD;
    	    END IF;
				-- Don't RAISE the EXCEPTION Yet. RUN ALL the validation procedures
	  			-- and show Exceptions all at once.
				x_return_status := Fnd_Api.G_RET_STS_ERROR;
      	  END IF;

    	 -- Check if Content_item_id is Valid
		 IF (Ibc_Validate_Pvt.isValidCitem(l_CV_Label_rec.content_item_id) = Fnd_Api.g_false) THEN
            IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
    	       Fnd_Message.Set_Name('IBC', 'INVALID_CITEM_ID');
    	       Fnd_Message.Set_token('CITEM_ID', l_CV_Label_rec.content_item_id);
    	       Fnd_Msg_Pub.ADD;
    	    END IF;
				x_return_status := Fnd_Api.G_RET_STS_ERROR;
      	  END IF;

	  	 -- Check if Citem_Version_ID exists
		 IF (Ibc_Validate_Pvt.isValidCitemVer(l_CV_Label_rec.citem_version_id) = Fnd_Api.g_false) THEN
            IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
    	       Fnd_Message.Set_Name('IBC', 'INVALID_CITEM_VERSION_ID');
    	       Fnd_Message.Set_token('CITEM_VERSION_ID', l_CV_Label_rec.CITEM_VERSION_id);
    	       Fnd_Msg_Pub.ADD;
    	    END IF;
				x_return_status := Fnd_Api.G_RET_STS_ERROR;
		 END IF;




	  -- Check for Uniqueness
	  OPEN  C_CV_Label;
	  FETCH C_CV_Label INTO l_CV_Label_Code;
	  IF C_CV_Label%FOUND THEN
	      IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
               Fnd_Message.Set_Name('IBC', 'Label Code Already EXISTS');
               Fnd_Message.Set_Token('COLUMN', 'Label_Code', FALSE);
               Fnd_Msg_Pub.ADD;
          END IF;
          x_return_status := Fnd_Api.G_RET_STS_ERROR;
	  END IF;

      CLOSE C_CV_Label;


   	  IF x_return_status<>Fnd_Api.G_RET_STS_SUCCESS THEN
          RAISE Fnd_Api.G_EXC_ERROR;
      END IF;


	 -- Validate Object Version Number
	 	IF l_CV_Label_rec.OBJECT_VERSION_NUMBER IS NULL
		OR l_CV_Label_rec.OBJECT_VERSION_NUMBER = Fnd_Api.G_MISS_NUM THEN
		   l_CV_Label_rec.OBJECT_VERSION_NUMBER := 1;
		END IF;

--
-- Table Handler to Insert Row into IBC_CV_LabelS
--
        Ibc_Citem_Version_Labels_Pkg.INSERT_ROW (
             x_ROWID 					 => lx_rowid
             ,p_content_item_id		 	 =>	l_CV_Label_rec.content_item_id
             ,p_Label_code		 		 =>	l_CV_Label_rec.Label_code
             ,p_citem_version_id		 =>	l_CV_Label_rec.citem_version_id
             ,p_CREATED_BY				 =>	l_CV_Label_rec.CREATED_BY
             ,p_CREATION_DATE			 =>	l_CV_Label_rec.CREATION_DATE
             ,p_LAST_UPDATED_BY			 =>	l_CV_Label_rec.LAST_UPDATED_BY
             ,p_LAST_UPDATE_DATE		 =>	l_CV_Label_rec.LAST_UPDATE_DATE
             ,p_LAST_UPDATE_LOGIN		 =>	l_CV_Label_rec.LAST_UPDATE_LOGIN
			 ,p_OBJECT_VERSION_NUMBER	 =>	l_CV_Label_rec.OBJECT_VERSION_NUMBER);


      IF x_return_status<>Fnd_Api.G_RET_STS_SUCCESS THEN
         IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
	     Fnd_Message.Set_Name('IBC', 'IBC_INSERT_ERROR');
	     Fnd_Msg_Pub.ADD;
	     END IF;

         IF (x_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR) THEN
          RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
         ELSIF (x_return_status = Fnd_Api.G_RET_STS_ERROR) THEN
          RAISE Fnd_Api.G_EXC_ERROR;
         END IF;
      END IF;

      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF Fnd_Api.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      Fnd_Msg_Pub.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );


EXCEPTION
	  WHEN Fnd_Api.G_EXC_ERROR THEN
    	  ROLLBACK;
	      Ibc_Utilities_Pvt.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => Fnd_Msg_Pub.G_MSG_LVL_ERROR
		  ,P_PACKAGE_TYPE => Ibc_Utilities_Pvt.G_PVT
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

	  WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
	   	  ROLLBACK;
	      Ibc_Utilities_Pvt.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR
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

END Create_CV_Label;


PROCEDURE Update_CV_Label(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     ,--:= Fnd_Api.G_FALSE,
    P_Commit                     IN   VARCHAR2     ,--:= Fnd_Api.G_FALSE,
    P_Validation_Level 			 IN   NUMBER       ,--:= Fnd_Api.G_VALID_LEVEL_FULL,
    P_CV_Label_Rec		 		 IN   Ibc_Cv_Label_Grp.CV_Label_Rec_Type ,--:= Ibc_Cv_Label_Grp.G_MISS_CV_Label_Rec,
	x_CV_Label_Rec		 	 	 OUT NOCOPY  Ibc_Cv_Label_Grp.CV_Label_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
    CURSOR C_CV_Label IS
    SELECT
	label_code
	FROM   IBC_CITEM_VERSION_LABELS
    WHERE  Label_Code = P_CV_Label_Rec.Label_Code
	AND    content_item_id = P_CV_Label_Rec.content_item_id;

    l_temp					  CHAR(1);
	l_return_status			  VARCHAR2(1) := Fnd_Api.G_RET_STS_SUCCESS;

	l_api_version_number  	  NUMBER := 1.0;
	l_api_name 				  VARCHAR2(50) := 'Update_CV_Label';
	l_CV_Label_Code 	  	  VARCHAR2(100);
	lx_rowid				  VARCHAR2(240);

	lx_CV_Label_REL_ID  NUMBER;


	l_CV_Label_Rec	  Ibc_Cv_Label_Grp.CV_Label_Rec_Type   := p_CV_Label_Rec;

BEGIN

     -- Initialize API return status to SUCCESS
     x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      IF Fnd_Global.User_Id IS NULL
      THEN
          IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR)
          THEN
              Fnd_Message.Set_Name(' + appShortName +', 'UT_CANNOT_GET_PROFILE_VALUE');
              Fnd_Message.Set_Token('PROFILE', 'USER_ID', FALSE);
              Fnd_Msg_Pub.ADD;
          END IF;
          RAISE Fnd_Api.G_EXC_ERROR;
      END IF;

	  	-- Check for all the NOT NULL Columns
	    -- CV_Label_Code Cannot be NULL and must exist in IBC_LABELS
    	IF (Ibc_Validate_Pvt.isValidLabel(l_CV_Label_rec.Label_code) = Fnd_Api.g_false) THEN
            IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
    	       Fnd_Message.Set_Name('IBC', 'INVALID_LABEL_CODE');
    	       Fnd_Message.Set_token('LABEL_CODE', l_CV_Label_rec.Label_code);
    	       Fnd_Msg_Pub.ADD;
    	    END IF;
				-- Don't RAISE the EXCEPTION Yet. RUN ALL the validation procedures
	  			-- and show Exceptions all at once.
				x_return_status := Fnd_Api.G_RET_STS_ERROR;
      	  END IF;

    	 -- Check if Content_item_id is Valid
		 IF (Ibc_Validate_Pvt.isValidCitem(l_CV_Label_rec.content_item_id) = Fnd_Api.g_false) THEN
            IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
    	       Fnd_Message.Set_Name('IBC', 'INVALID_CITEM_ID');
    	       Fnd_Message.Set_token('CITEM_ID', l_CV_Label_rec.content_item_id);
    	       Fnd_Msg_Pub.ADD;
    	    END IF;
				x_return_status := Fnd_Api.G_RET_STS_ERROR;
      	  END IF;

	  	 -- Check if Citem_Version_ID exists
		 IF (Ibc_Validate_Pvt.isValidCitemVer(l_CV_Label_rec.citem_version_id) = Fnd_Api.g_false) THEN
            IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
    	       Fnd_Message.Set_Name('IBC', 'INVALID_CITEM_VERSION_ID');
    	       Fnd_Message.Set_token('CITEM_VERSION_ID', l_CV_Label_rec.CITEM_VERSION_id);
    	       Fnd_Msg_Pub.ADD;
    	    END IF;
				x_return_status := Fnd_Api.G_RET_STS_ERROR;
		 END IF;




	  -- Check if the label code exists
	  OPEN  C_CV_Label;
	  FETCH C_CV_Label INTO l_CV_Label_Code;
	  IF C_CV_Label%NOTFOUND THEN
	    IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
               Fnd_Message.Set_Name('IBC', 'Label Code doesnot EXIST');
               Fnd_Message.Set_Token('COLUMN', 'Label_Code', FALSE);
               Fnd_Msg_Pub.ADD;
        END IF;
		x_return_status := Fnd_Api.G_RET_STS_ERROR;
      END IF;
      CLOSE C_CV_Label;

  	  IF x_return_status<>Fnd_Api.G_RET_STS_SUCCESS THEN
          RAISE Fnd_Api.G_EXC_ERROR;
      END IF;

-- 	 -- Validate Object Version Number
-- 	 	IF l_CV_Label_rec.OBJECT_VERSION_NUMBER IS NULL THEN
-- 		   l_CV_Label_rec.OBJECT_VERSION_NUMBER := FND_API.G_MISS_NUM;
-- 		END IF;

--
-- Table Handler to Update Row into IBC_CV_LabelS
--
        Ibc_Citem_Version_Labels_Pkg.UPDATE_ROW (
             p_content_item_id		 	 =>	l_CV_Label_rec.content_item_id
             ,p_Label_code		 		 =>	l_CV_Label_rec.Label_code
             ,p_citem_version_id		 =>	l_CV_Label_rec.citem_version_id
             ,p_LAST_UPDATED_BY			 =>	l_CV_Label_rec.LAST_UPDATED_BY
             ,p_LAST_UPDATE_DATE		 =>	l_CV_Label_rec.LAST_UPDATE_DATE
             ,p_LAST_UPDATE_LOGIN		 =>	l_CV_Label_rec.LAST_UPDATE_LOGIN
			 ,p_OBJECT_VERSION_NUMBER	 =>	l_CV_Label_rec.OBJECT_VERSION_NUMBER);



      IF x_return_status<>Fnd_Api.G_RET_STS_SUCCESS THEN
         IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
	     Fnd_Message.Set_Name('IBC', 'IBC_UPDATE_ERROR');
	     Fnd_Msg_Pub.ADD;
	     END IF;

         IF (x_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR) THEN
          RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
         ELSIF (x_return_status = Fnd_Api.G_RET_STS_ERROR) THEN
          RAISE Fnd_Api.G_EXC_ERROR;
         END IF;
      END IF;

      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF Fnd_Api.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      Fnd_Msg_Pub.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );


EXCEPTION
	  WHEN Fnd_Api.G_EXC_ERROR THEN
    	  ROLLBACK;
	      Ibc_Utilities_Pvt.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => Fnd_Msg_Pub.G_MSG_LVL_ERROR
		  ,P_PACKAGE_TYPE => Ibc_Utilities_Pvt.G_PVT
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

	  WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
	   	  ROLLBACK;
	      Ibc_Utilities_Pvt.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR
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

END Update_CV_Label;


PROCEDURE delete_CV_Label(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2     ,--:= Fnd_Api.G_FALSE,
    P_Commit                     IN   VARCHAR2     ,--:= Fnd_Api.G_FALSE,
    P_Validation_Level 			 IN   NUMBER       ,--:= Fnd_Api.G_VALID_LEVEL_FULL,
    P_Label_Code		 	 	 IN   VARCHAR2,
    P_content_item_id	 	 	 IN   NUMBER,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS

    CURSOR C_CV_Label IS
    SELECT
	label_code
	FROM   IBC_CITEM_VERSION_LABELS
    WHERE  Label_Code = P_Label_Code
	AND    content_item_id = P_content_item_id;

    l_temp					  CHAR(1);
	l_return_status			  VARCHAR2(1) := Fnd_Api.G_RET_STS_SUCCESS;

	l_api_version_number  	  NUMBER := 1.0;
	l_api_name 				  VARCHAR2(50) := 'Delete_CV_Label';
	l_CV_Label_Code 	  	  VARCHAR2(100);
	lx_rowid				  VARCHAR2(240);

	lx_CV_Label_REL_ID  NUMBER;


BEGIN

     -- Initialize API return status to SUCCESS
     x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      IF Fnd_Global.User_Id IS NULL
      THEN
          IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR)
          THEN
              Fnd_Message.Set_Name(' + appShortName +', 'UT_CANNOT_GET_PROFILE_VALUE');
              Fnd_Message.Set_Token('PROFILE', 'USER_ID', FALSE);
              Fnd_Msg_Pub.ADD;
          END IF;
          RAISE Fnd_Api.G_EXC_ERROR;
      END IF;


--
-- Table Handler to Insert Row into IBC_CV_LabelS
--
        Ibc_Citem_Version_Labels_Pkg.DELETE_ROW (
             p_content_item_id		 	 =>	p_content_item_id
             ,p_Label_code		 		 =>	p_Label_code);



      IF x_return_status<>Fnd_Api.G_RET_STS_SUCCESS THEN
         IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
	     Fnd_Message.Set_Name('IBC', 'IBC_DELETE_ERROR');
	     Fnd_Msg_Pub.ADD;
	     END IF;

         IF (x_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR) THEN
          RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
         ELSIF (x_return_status = Fnd_Api.G_RET_STS_ERROR) THEN
          RAISE Fnd_Api.G_EXC_ERROR;
         END IF;
      END IF;

      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF Fnd_Api.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      Fnd_Msg_Pub.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );


EXCEPTION
	  WHEN Fnd_Api.G_EXC_ERROR THEN
    	  ROLLBACK;
	      Ibc_Utilities_Pvt.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => Fnd_Msg_Pub.G_MSG_LVL_ERROR
		  ,P_PACKAGE_TYPE => Ibc_Utilities_Pvt.G_PVT
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

	  WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
	   	  ROLLBACK;
	      Ibc_Utilities_Pvt.HANDLE_EXCEPTIONS(
		   P_API_NAME => L_API_NAME
		  ,P_PKG_NAME => G_PKG_NAME
		  ,P_EXCEPTION_LEVEL => Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR
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

END delete_CV_Label;

FUNCTION  Query_CV_Label_Row (
              p_content_item_id IN NUMBER,
              p_Label_code 		IN VARCHAR2
) RETURN  Ibc_Cv_Label_Grp.CV_Label_Rec_Type
IS
l_CV_Label_Rec	 Ibc_Cv_Label_Grp.CV_Label_Rec_Type;
BEGIN

SELECT
     CONTENT_ITEM_ID
    ,CITEM_VERSION_ID
    ,LABEL_CODE
    ,CREATED_BY
    ,CREATION_DATE
    ,LAST_UPDATED_BY
    ,LAST_UPDATE_DATE
    ,LAST_UPDATE_LOGIN
    ,OBJECT_VERSION_NUMBER
INTO
     l_CV_Label_Rec.CONTENT_ITEM_ID
    ,l_CV_Label_Rec.CITEM_VERSION_ID
    ,l_CV_Label_Rec.LABEL_CODE
    ,l_CV_Label_Rec.CREATED_BY
    ,l_CV_Label_Rec.CREATION_DATE
    ,l_CV_Label_Rec.LAST_UPDATED_BY
    ,l_CV_Label_Rec.LAST_UPDATE_DATE
    ,l_CV_Label_Rec.LAST_UPDATE_LOGIN
    ,l_CV_Label_Rec.OBJECT_VERSION_NUMBER
FROM IBC_CITEM_VERSION_LABELS
WHERE CONTENT_ITEM_ID = p_content_item_id
AND	  LABEL_CODE      = p_label_code;

RETURN l_CV_Label_rec;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
	RAISE NO_DATA_FOUND;
    WHEN OTHERS THEN
	IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
	    Fnd_Message.Set_Name('IBC', 'CItem Version Label RECORD Error');
	    Fnd_Msg_Pub.ADD;
	END IF;
        RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
END Query_CV_Label_Row;

FUNCTION  get_CV_Label_rec	RETURN  Ibc_Cv_Label_Grp.CV_Label_rec_type
IS
    TMP_REC  Ibc_Cv_Label_Grp.CV_Label_rec_type;
BEGIN
    RETURN   TMP_REC;
END get_CV_Label_rec;

--
-- Upsert into CV Labels Table
--
PROCEDURE Upsert_Cv_Labels(
	 p_label_code				IN VARCHAR2
    ,p_content_item_ids         IN JTF_NUMBER_TABLE
	,p_citem_version_ids        IN JTF_NUMBER_TABLE
	,p_version_number        	IN JTF_NUMBER_TABLE
    ,p_commit                   IN 	VARCHAR2
    ,p_api_version_number       IN 	NUMBER
    ,p_init_msg_list            IN 	VARCHAR2 --DEFAULT Fnd_Api.G_FALSE
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
)
IS

	l_api_name 					CONSTANT VARCHAR2(30) := 'UPSERT_CV_LABELS';
	l_api_version_number 		CONSTANT NUMBER := 1; --G_API_VERSION_DEFAULT;

	lx_rowid					VARCHAR2(240);
	l_ins_content_item_ids		JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
	l_ins_citem_version_ids		JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
	l_cnt						INTEGER := 1;
	l_temp						INTEGER := 1;
	l_citem_version_ids			JTF_NUMBER_TABLE := p_citem_version_ids;


BEGIN

  --DBMS_OUTPUT.put_line('----- ' || l_api_name || ' -----');


  SAVEPOINT SVPT_UPSERT_CV_LABELS;

      IF (p_init_msg_list = Fnd_Api.g_true) THEN                  --|**|
        Fnd_Msg_Pub.initialize;                                   --|**|
      END IF;                                                     --|**|
                                                                  --|**|
      -- Standard call to check for call compatibility.           --|**|
      IF NOT Fnd_Api.Compatible_API_Call (                        --|**|
            l_api_version_number                                  --|**|
			   ,p_api_version_number                              --|**|
			   ,l_api_name                                        --|**|
			   ,G_PKG_NAME                                        --|**|
      )THEN                                                       --|**|
	     RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;                    --|**|
      END IF;                                                     --|**|
                                                                  --|**|
      -- Initialize API return status to SUCCESS                  --|**|
      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;               --|**|


    IF 	l_citem_version_ids.COUNT <> 0 THEN
    	BEGIN
		--
    	-- Validate and make sure that the content_item_id and citem_version_id
    	-- Exists in database
    	--
    	FOR i IN p_content_item_ids.FIRST..p_content_item_ids.LAST
    		LOOP
    		SELECT '1' INTO l_temp FROM  ibc_citem_versions_b
    		WHERE content_item_id  = p_content_item_ids(i)
    		AND   citem_version_id = l_citem_version_ids(i);
    		END LOOP;
    	EXCEPTION WHEN NO_DATA_FOUND THEN
    		--DBMS_OUTPUT.put_line('CitemVersionId Invalid....');
            x_return_status := Fnd_Api.G_RET_STS_ERROR;
    	    Fnd_Message.Set_Name('IBC', 'API_INVALID_ID');
            Fnd_Message.Set_Token('COLUMN','p_citem_version_ids', FALSE);
            Fnd_Message.Set_Token('VALUE','p_citem_version_ids(i)', FALSE);
            Fnd_Msg_Pub.ADD;
            RAISE Fnd_Api.G_EXC_ERROR;
    	END;
	ELSIF  p_version_number.COUNT <> 0 THEN
		BEGIN
		-- get the citem_version id for all the content item id and
		-- the version numbers into  l_citem_version_id
		--
    	FOR i IN p_content_item_ids.FIRST..p_content_item_ids.LAST
			LOOP
			l_citem_version_ids.extend;
    		SELECT citem_version_id INTO l_citem_version_ids(i)
    		FROM  ibc_citem_versions_b
    		WHERE content_item_id  = p_content_item_ids(i)
    		AND   version_number   = p_version_number(i);
    		END LOOP;
    	EXCEPTION WHEN NO_DATA_FOUND THEN
    		--DBMS_OUTPUT.put_line('CitemVersionId Invalid....');
            x_return_status := Fnd_Api.G_RET_STS_ERROR;
    	    Fnd_Message.Set_Name('IBC', 'API_INVALID_ID');
            Fnd_Message.Set_Token('COLUMN','p_version_number',  FALSE);
            Fnd_Message.Set_Token('VALUE','p_version_number(i)',FALSE);
            Fnd_Msg_Pub.ADD;
            RAISE Fnd_Api.G_EXC_ERROR;
    	END;
    END IF;

	--
	-- Validate if the Label Code passed exists in the Database
	--
	BEGIN
    	SELECT '1' INTO l_temp FROM IBC_LABELS_B
    	WHERE label_code = p_label_code;
    	EXCEPTION WHEN NO_DATA_FOUND THEN
    		--DBMS_OUTPUT.put_line('Label Code is Invalid....');
            x_return_status := Fnd_Api.G_RET_STS_ERROR;
    	    Fnd_Message.Set_Name('IBC', 'API_INVALID_ID');
            Fnd_Message.Set_Token('COLUMN','p_label_code', FALSE);
            Fnd_Message.Set_Token('VALUE',p_label_code, FALSE);
            Fnd_Msg_Pub.ADD;
            RAISE Fnd_Api.G_EXC_ERROR;
	END;

	--
	--  Update
    FORALL i IN p_content_item_ids.FIRST..p_content_item_ids.LAST
	    UPDATE IBC_CITEM_VERSION_LABELS SET
            CITEM_VERSION_ID = l_citem_version_ids(i),
            OBJECT_VERSION_NUMBER = 1,
            LAST_UPDATE_DATE = SYSDATE,
            LAST_UPDATED_BY = Fnd_Global.user_id,
            LAST_UPDATE_LOGIN = Fnd_Global.login_id
		  WHERE label_code = p_label_code
		  AND	content_item_id = p_content_item_ids(i);

   	--DBMS_OUTPUT.put_line('Update Successful....');
	--
	-- Collect all those that could not be updated
	-- Will insert them.
	FOR i IN p_content_item_ids.FIRST..p_content_item_ids.LAST
		LOOP
		  IF SQL%BULK_ROWCOUNT(i) = 0 THEN
		  	 l_ins_content_item_ids.extend;
			 l_ins_citem_version_ids.extend;
		  	 l_ins_content_item_ids(l_cnt) 	:=  p_content_item_ids(i);
			 l_ins_citem_version_ids(l_cnt) :=  l_citem_version_ids(i);
			 l_cnt := l_cnt + 1;
		  END IF;
		END LOOP;

	--DBMS_OUTPUT.put_line('Bulk Count ....');

	-- Insert
	--
 	IF l_ins_content_item_ids.EXISTS(l_ins_content_item_ids.FIRST) THEN

	FORALL i IN l_ins_content_item_ids.FIRST..l_ins_content_item_ids.LAST
       INSERT INTO IBC_CITEM_VERSION_LABELS (
            CONTENT_ITEM_ID,
            LABEL_CODE,
            CITEM_VERSION_ID,
            OBJECT_VERSION_NUMBER,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN
          ) VALUES (
            l_ins_content_item_ids(i),
            p_LABEL_CODE,
            l_ins_citem_version_ids(i),
            1,
            SYSDATE,
            Fnd_Global.user_id,
            SYSDATE,
            Fnd_Global.user_id,
            Fnd_Global.login_id
          );

	END IF;



    -- COMMIT?
    IF ( (x_return_status = Fnd_Api.G_RET_STS_SUCCESS) AND (p_commit = Fnd_Api.g_true) ) THEN
        COMMIT;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    Fnd_Msg_Pub.Count_And_Get(
        p_count           =>      x_msg_count,
        p_data            =>      x_msg_data
    );

EXCEPTION
    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO SVPT_UPSERT_CV_LABELS;
      --DBMS_OUTPUT.put_line('Expected Error');
	     Ibc_Utilities_Pvt.handle_exceptions(
	       p_api_name           => L_API_NAME
	       ,p_pkg_name          => G_PKG_NAME
	       ,p_exception_level   => Fnd_Msg_Pub.G_MSG_LVL_ERROR
	       ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
	       ,p_sqlcode           => SQLCODE
	       ,p_sqlerrm           => SQLERRM
	       ,x_msg_count         => x_msg_count
	       ,x_msg_data          => x_msg_data
	       ,x_return_status     => x_return_status
       );

  WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO SVPT_UPSERT_CV_LABELS;
      --DBMS_OUTPUT.put_line('Unexpected error');
      Ibc_Utilities_Pvt.handle_exceptions(
	       p_api_name           => L_API_NAME
	       ,p_pkg_name          => G_PKG_NAME
	       ,p_exception_level   => Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR
	       ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
	       ,p_sqlcode           => SQLCODE
	       ,p_sqlerrm           => SQLERRM
	       ,x_msg_count         => x_msg_count
	       ,x_msg_data          => x_msg_data
	       ,x_return_status     => x_return_status
      );

  WHEN OTHERS THEN
      ROLLBACK TO SVPT_UPSERT_CV_LABELS;
      --DBMS_OUTPUT.put_line('Other error');
      Ibc_Utilities_Pvt.HANDLE_EXCEPTIONS(
	       p_api_name           => L_API_NAME
	       ,p_pkg_name          => G_PKG_NAME
	       ,p_exception_level   => Ibc_Utilities_Pvt.G_EXC_OTHERS
	       ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
	       ,p_sqlcode           => SQLCODE
	       ,p_sqlerrm           => SQLERRM
	       ,x_msg_count         => x_msg_count
	       ,x_msg_data          => x_msg_data
	       ,x_return_status     => x_return_status
      );
 END Upsert_Cv_Labels;

--
-- Upsert into CV Labels Table
--
PROCEDURE Upsert_Cv_Labels(
	 p_label_code				IN VARCHAR2
    ,p_content_item_ids         IN JTF_NUMBER_TABLE
	,p_citem_version_ids       	IN JTF_NUMBER_TABLE
    ,p_commit                   IN 	VARCHAR2
    ,p_api_version_number       IN 	NUMBER
    ,p_init_msg_list            IN 	VARCHAR2 --DEFAULT Fnd_Api.G_FALSE
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
)
IS




BEGIN

	--
	-- Validate and make sure that the content_item_id and citem_version_id
	-- Exists in database
	--

        Upsert_Cv_Labels(
        	 p_label_code				=> p_label_code
            ,p_content_item_ids         => p_content_item_ids
        	,p_citem_version_ids        => p_citem_version_ids
			,p_version_number        	=> JTF_NUMBER_TABLE()
            ,p_commit                   => p_commit
            ,p_api_version_number       => p_api_version_number
            ,p_init_msg_list            => p_init_msg_list
            ,x_return_status            => x_return_status
            ,x_msg_count                => x_msg_count
            ,x_msg_data                 => x_msg_data);


END Upsert_Cv_Labels;


--
-- Upsert into CV Labels Table
--
PROCEDURE Upsert_Cv_Labels(
	 p_label_code				IN VARCHAR2
    ,p_content_item_ids         IN JTF_NUMBER_TABLE
	,p_version_number        	IN JTF_NUMBER_TABLE
    ,p_commit                   IN 	VARCHAR2
    ,p_api_version_number       IN 	NUMBER
    ,p_init_msg_list            IN 	VARCHAR2 --DEFAULT Fnd_Api.G_FALSE
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
)
IS

	l_citem_version_ids			JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();


BEGIN

	--
	-- Validate and make sure that the content_item_id and citem_version_id
	-- Exists in database
	--

        Upsert_Cv_Labels(
        	 p_label_code				=> p_label_code
            ,p_content_item_ids         => p_content_item_ids
        	,p_version_number        	=> p_version_number
			,p_citem_version_ids		=> JTF_NUMBER_TABLE()
            ,p_commit                   => p_commit
            ,p_api_version_number       => p_api_version_number
            ,p_init_msg_list            => p_init_msg_list
            ,x_return_status            => x_return_status
            ,x_msg_count                => x_msg_count
            ,x_msg_data                 => x_msg_data);

END Upsert_Cv_Labels;

--
-- Delete into CV Labels Table
--
PROCEDURE Delete_Cv_Labels(
	 p_label_code				IN VARCHAR2
    ,p_content_item_ids         IN JTF_NUMBER_TABLE
    ,p_commit                   IN 	VARCHAR2
    ,p_api_version_number       IN 	NUMBER
    ,p_init_msg_list            IN 	VARCHAR2 --DEFAULT Fnd_Api.G_FALSE
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
)
IS

	l_api_name 					CONSTANT VARCHAR2(30) := 'DELETE_CV_LABELS';
	l_api_version_number 		CONSTANT NUMBER := 1; --G_API_VERSION_DEFAULT;

BEGIN

  --DBMS_OUTPUT.put_line('----- ' || l_api_name || ' -----');


  SAVEPOINT SVPT_DELETE_CV_LABELS;

      IF (p_init_msg_list = Fnd_Api.g_true) THEN                  --|**|
        Fnd_Msg_Pub.initialize;                                   --|**|
      END IF;                                                     --|**|
                                                                  --|**|
      -- Standard call to check for call compatibility.           --|**|
      IF NOT Fnd_Api.Compatible_API_Call (                        --|**|
            l_api_version_number                                  --|**|
			   ,p_api_version_number                              --|**|
			   ,l_api_name                                        --|**|
			   ,G_PKG_NAME                                        --|**|
      )THEN                                                       --|**|
	     RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;                    --|**|
      END IF;                                                     --|**|
                                                                  --|**|
      -- Initialize API return status to SUCCESS                  --|**|
      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;               --|**|


	--
	--  Delete
    FORALL i IN p_content_item_ids.FIRST..p_content_item_ids.LAST
	    DELETE FROM IBC_CITEM_VERSION_LABELS
		WHERE label_code = p_label_code
		AND	content_item_id = p_content_item_ids(i);

   	--DBMS_OUTPUT.put_line('Delete Successful....');

    -- COMMIT?
    IF ( (x_return_status = Fnd_Api.G_RET_STS_SUCCESS) AND (p_commit = Fnd_Api.g_true) ) THEN
        COMMIT;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    Fnd_Msg_Pub.Count_And_Get(
        p_count           =>      x_msg_count,
        p_data            =>      x_msg_data
    );

EXCEPTION
    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO SVPT_UPSERT_CV_LABELS;
      --DBMS_OUTPUT.put_line('Expected Error');
	     Ibc_Utilities_Pvt.handle_exceptions(
	       p_api_name           => L_API_NAME
	       ,p_pkg_name          => G_PKG_NAME
	       ,p_exception_level   => Fnd_Msg_Pub.G_MSG_LVL_ERROR
	       ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
	       ,p_sqlcode           => SQLCODE
	       ,p_sqlerrm           => SQLERRM
	       ,x_msg_count         => x_msg_count
	       ,x_msg_data          => x_msg_data
	       ,x_return_status     => x_return_status
       );

  WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO SVPT_UPSERT_CV_LABELS;
      --DBMS_OUTPUT.put_line('Unexpected error');
      Ibc_Utilities_Pvt.handle_exceptions(
	       p_api_name           => L_API_NAME
	       ,p_pkg_name          => G_PKG_NAME
	       ,p_exception_level   => Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR
	       ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
	       ,p_sqlcode           => SQLCODE
	       ,p_sqlerrm           => SQLERRM
	       ,x_msg_count         => x_msg_count
	       ,x_msg_data          => x_msg_data
	       ,x_return_status     => x_return_status
      );

  WHEN OTHERS THEN
      ROLLBACK TO SVPT_UPSERT_CV_LABELS;
      --DBMS_OUTPUT.put_line('Other error');
      Ibc_Utilities_Pvt.HANDLE_EXCEPTIONS(
	       p_api_name           => L_API_NAME
	       ,p_pkg_name          => G_PKG_NAME
	       ,p_exception_level   => Ibc_Utilities_Pvt.G_EXC_OTHERS
	       ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
	       ,p_sqlcode           => SQLCODE
	       ,p_sqlerrm           => SQLERRM
	       ,x_msg_count         => x_msg_count
	       ,x_msg_data          => x_msg_data
	       ,x_return_status     => x_return_status
      );
 END Delete_Cv_Labels;


END Ibc_Cv_Label_Grp;

/
