--------------------------------------------------------
--  DDL for Package Body IBC_CTYPE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBC_CTYPE_PVT" AS
/* $Header: ibcvctyb.pls 120.2 2005/06/01 23:50:00 appldev  $ */

-- Purpose: API to Populate Content Type.

-- MODIFICATION HISTORY
-- Person            Date        Comments
-- ---------         ------      ------------------------------------------
-- Sri Rangarajan    01/06/2002      Created Package
-- shitij.vatsa      11/04/2002      Updated for NOCOPY
-- Sri Rangarajan    01/06/2004      Added the Method get_sql_from_flex

-- Package Name     : IBC_Ctype_Pvt
-- Purpose          :
-- History          : 05/18/2005 Sharma GSCC NOCOPY issue fixed
-- NOTE             :
-- End of Comments


G_PKG_Name CONSTANT VARCHAR2(30):= 'Ibc_Ctype_Pvt';
G_FILE_Name CONSTANT VARCHAR2(12) := 'ibcvctyb.pls';

PROCEDURE Update_Attribute_Type(
    P_Api_Version_Number         IN     NUMBER,
    P_Init_Msg_List              IN     VARCHAR2     ,--:= FND_API.G_FALSE,
    P_Commit                     IN     VARCHAR2     ,--:= FND_API.G_FALSE,
    P_Validation_Level     IN     NUMBER       ,--:= FND_API.G_VALID_LEVEL_FULL,
    P_Attribute_Type_Rec    IN     Ibc_Ctype_Pvt.Attribute_Type_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

PROCEDURE Delete_Attribute_Type(
    P_Api_Version_Number         IN     NUMBER,
    P_Init_Msg_List              IN     VARCHAR2     ,--:= FND_API.G_FALSE,
    P_Commit                     IN     VARCHAR2     ,--:= FND_API.G_FALSE,
    P_Validation_Level     IN     NUMBER       ,--:= FND_API.G_VALID_LEVEL_FULL,
    P_Attribute_Type_Rec    IN     Ibc_Ctype_Pvt.Attribute_Type_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    );

FUNCTION  Query_Attribute_type_Row (
              p_attribute_type_code  IN   VARCHAR2,
              p_content_type_code   IN   VARCHAR2
) RETURN  Ibc_Ctype_Pvt.Attribute_Type_Rec_Type;


FUNCTION IsATypeRecordEmpty(
   P_Attribute_Type_Rec   IN    Ibc_Ctype_Pvt.Attribute_Type_Rec_Type)
RETURN BOOLEAN IS

BEGIN

IF  ((p_attribute_type_rec.content_type_code IS NULL
  OR p_attribute_type_rec.content_type_code = Fnd_Api.G_MISS_CHAR)
  AND (p_attribute_type_rec.attribute_type_code IS NULL
  OR p_attribute_type_rec.attribute_type_code = Fnd_Api.G_MISS_CHAR))
  THEN

 RETURN TRUE;
ELSE
 RETURN FALSE;
END IF;

END IsATypeRecordEmpty;


FUNCTION IsCTypeRecordEmpty(
   P_content_Type_Rec   IN    Ibc_Ctype_Pvt.Content_Type_Rec_Type)
RETURN BOOLEAN IS

BEGIN

IF  ((P_content_Type_Rec.content_type_code IS NULL
  OR P_content_Type_Rec.content_type_code = Fnd_Api.G_MISS_CHAR)
  AND (P_content_Type_Rec.content_type_status IS NULL
  OR P_content_Type_Rec.content_type_status = Fnd_Api.G_MISS_CHAR))
  THEN

 RETURN TRUE;

ELSE
 RETURN FALSE;

END IF;

END IsCTypeRecordEmpty;

PROCEDURE Create_Content_Type(
    P_Api_Version_Number   IN     NUMBER,
    P_Init_Msg_List        IN     VARCHAR2     ,--:= FND_API.G_FALSE,
    P_Commit               IN     VARCHAR2     ,--:= FND_API.G_FALSE,
    P_Validation_Level     IN     NUMBER       ,--:= FND_API.G_VALID_LEVEL_FULL,
    P_Content_Type_Rec     IN    Ibc_Ctype_Pvt.Content_Type_Rec_Type   ,--:= Ibc_Ctype_Pvt.G_MISS_Content_Type_Rec,
    P_Attribute_Type_Tbl   IN   Ibc_Ctype_Pvt.Attribute_Type_Tbl_Type ,--:= Ibc_Ctype_Pvt.G_Miss_Attribute_Type_Tbl,
    X_Return_Status        OUT NOCOPY   VARCHAR2,
    X_Msg_Count            OUT NOCOPY   NUMBER,
    X_Msg_Data             OUT NOCOPY   VARCHAR2
    )
IS
    CURSOR C_Content_Type(p_Content_Type_Code IN VARCHAR2) IS
    SELECT
    Content_Type_Code
 FROM ibc_content_types_b
    WHERE Content_Type_Code = p_Content_Type_Code;


    CURSOR C_Attribute_Type(p_content_type_code IN VARCHAR2
             ,p_attribute_type_code IN VARCHAR2)
    IS
    SELECT '1'
    FROM IBC_ATTRIBUTE_TYPES_B
    WHERE content_type_code = p_content_type_code
    AND   attribute_type_code = p_attribute_type_code;

    l_temp       CHAR(1);
 l_return_status     VARCHAR2(1) := Fnd_Api.G_RET_STS_SUCCESS;

 l_api_version_number     NUMBER := 1.0;
 l_api_name       VARCHAR2(50) := 'Create_Content_Type';
 l_Content_Type_Code    VARCHAR2(100);
 lx_rowid      VARCHAR2(240);

 l_Content_Type_Rec    Ibc_Ctype_Pvt.Content_Type_Rec_Type   := p_Content_Type_Rec;
    l_Attribute_Type_Tbl   Ibc_Ctype_Pvt.Attribute_Type_Tbl_Type := p_Attribute_Type_Tbl;
 l_attribute_type_rec   Ibc_Ctype_Pvt.Attribute_Type_Rec_Type;

 l_Does_name_exist    BOOLEAN  := FALSE;
 l_Does_Description_exist  BOOLEAN  := FALSE;

BEGIN
  -- Standard Start of API savepoint
  DBMS_TRANSACTION.SAVEPOINT(l_api_name);
     --SAVEPOINT l_api_name;
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
              Fnd_Message.Set_Name(' + appShortname +', 'UT_CANNOT_GET_PROFILE_VALUE');
              Fnd_Message.Set_Token('PROFILE', 'USER_ID', FALSE);
              Fnd_Msg_Pub.ADD;
          END IF;
          RAISE Fnd_Api.G_EXC_ERROR;
      END IF;

    -- Check for all the NOT NULL Columns
     -- Content_TYpe_Code Cannot be NULL
      Ibc_Validate_Pvt.validate_NotNULL_VARCHAR2 (
        p_init_msg_list => Fnd_Api.G_FALSE,
        p_column_name => 'Content_Type_Code',
        p_notnull_column=> l_content_type_rec.content_type_code,
        x_return_status => x_return_status,
            x_msg_count     => x_msg_count,
            x_msg_data      => x_msg_data);

   -- Don't RAISE the EXCEPTION Yet. RUN ALL the validation procedures
   -- and show Exceptions all at once.
     IF x_return_status<>Fnd_Api.G_RET_STS_SUCCESS THEN
           l_return_status := x_return_status;
      END IF;

  -- Content_TYpe_Status Cannot be NULL
  Ibc_Validate_Pvt.validate_NotNULL_VARCHAR2 (
          p_init_msg_list => Fnd_Api.G_FALSE,
          p_column_name => 'Content_Type_Status',
          p_notnull_column=> l_content_type_rec.content_type_Status,
          x_return_status => x_return_status,
                x_msg_count     => x_msg_count,
                x_msg_data      => x_msg_data);

     IF x_return_status<>Fnd_Api.G_RET_STS_SUCCESS THEN
           l_return_status := x_return_status;
      END IF;

  -- Content_TYpe_name Cannot be NULL
  Ibc_Validate_Pvt.validate_NotNULL_VARCHAR2 (
          p_init_msg_list => Fnd_Api.G_FALSE,
          p_column_name => 'Content_Type_name',
          p_notnull_column=> l_content_type_rec.content_type_name,
          x_return_status => x_return_status,
                x_msg_count     => x_msg_count,
                x_msg_data      => x_msg_data);

     IF x_return_status<>Fnd_Api.G_RET_STS_SUCCESS THEN
           l_return_status := x_return_status;
      END IF;


   -- Check for Uniqueness
   OPEN  C_Content_Type(p_Content_Type_Code => l_content_type_rec.content_type_code);
      FETCH C_Content_Type INTO l_Content_Type_Code;
   IF C_Content_Type%FOUND THEN
       IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
               Fnd_Message.Set_name('IBC', 'IBC_ALREADY_EXISTS');
               Fnd_Message.Set_Token('DUPLICATE_OBJECT_TOKEN', 'Content_Type_Code', FALSE);
               Fnd_Msg_Pub.ADD;
          END IF;
          CLOSE C_Content_Type;
          RAISE Fnd_Api.G_EXC_ERROR;
      END IF;
      CLOSE C_Content_Type;


   -- Validate Content Type Status
    Ibc_Validate_Pvt.validate_Content_Type_Status(
      p_init_msg_list    => Fnd_Api.G_FALSE,
      p_Content_Type_Status => l_content_type_rec.content_type_status,
      x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);

     IF x_return_status<>Fnd_Api.G_RET_STS_SUCCESS THEN
           l_return_status := x_return_status;
      END IF;


   -- Validate Application Id
    Ibc_Validate_Pvt.validate_application_id(
      p_init_msg_list    => Fnd_Api.G_FALSE,
      p_application_id    => l_content_type_rec.application_id,
      x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);

     IF x_return_status<>Fnd_Api.G_RET_STS_SUCCESS
     OR l_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
            RAISE Fnd_Api.G_EXC_ERROR;
      END IF;

  -- Validate Object Version Number
   IF l_content_type_rec.OBJECT_VERSION_NUMBER IS NULL
  OR l_content_type_rec.OBJECT_VERSION_NUMBER = Fnd_Api.G_MISS_NUM THEN
     l_content_type_rec.OBJECT_VERSION_NUMBER := 1;
  END IF;

--dbms_output.put_line('Validation complete FOR content TYPE');


--
-- Table Handler to Insert Row into IBC_CONTENT_TYPES
--
        Ibc_Content_Types_Pkg.INSERT_ROW (
             x_ROWID       =>lx_rowid,
             p_CONTENT_TYPE_CODE    =>l_content_type_rec.CONTENT_TYPE_CODE,
             p_CONTENT_TYPE_STATUS    =>l_content_type_rec.CONTENT_TYPE_STATUS,
             p_APPLICATION_ID     =>l_content_type_rec.APPLICATION_ID,
             p_REQUEST_ID      =>l_content_type_rec.REQUEST_ID,
             p_OBJECT_VERSION_NUMBER   =>l_content_type_rec.oBJECT_VERSION_NUMBER,
             p_CONTENT_TYPE_Name    =>l_content_type_rec.CONTENT_TYPE_name,
             p_DESCRIPTION      =>l_content_type_rec.DESCRIPTION,
             p_CREATION_DATE     =>l_content_type_rec.CREATION_DATE,
             p_CREATED_BY      =>l_content_type_rec.CREATED_BY,
             p_LAST_UPDATE_DATE    =>l_content_type_rec.LAST_UPDATE_DATE,
             p_LAST_UPDATED_BY     =>l_content_type_rec.LAST_UPDATED_BY,
             p_LAST_UPDATE_LOGIN    =>l_content_type_rec.LAST_UPDATE_LOGIN);


-- Insert The Corresponding Attributes in ibc_attribute_types_b  table
IF l_attribute_type_tbl.COUNT <> 0 THEN
 FOR i IN l_attribute_type_tbl.FIRST..l_attribute_type_tbl.LAST LOOP

 IF l_attribute_type_tbl.EXISTS(i) AND NOT IsATypeRecordEmpty(l_Attribute_Type_Tbl(i))
 THEN
      --
      -- Check to see if name and Description are already a part of the Attribute_Tbl
      -- if NOT then Create name and DESCRIPTION attribute Types by default
      --
   -- Check if name exists in the Attribute Types
   IF UPPER(l_Attribute_Type_Tbl(i).attribute_type_code) = G_NAME THEN
       l_Does_name_exist := TRUE;
    END IF;
   -- Check if Description exists in the Attribute Types
   IF UPPER(l_Attribute_Type_Tbl(i).attribute_type_code) = G_DESCRIPTION THEN
       l_Does_Description_exist := TRUE;
   END IF;

            Create_Attribute_Type(
                P_Api_Version_Number   =>P_Api_Version_Number,
                P_Init_Msg_List        =>P_Init_Msg_List,
                P_Commit               =>P_Commit,
                P_Validation_Level     =>Fnd_Api.G_VALID_LEVEL_FULL,
                P_Attribute_Type_Rec   =>l_Attribute_Type_Tbl(i),
                X_Return_Status        =>X_Return_Status,
                X_Msg_Count            =>X_Msg_Count,
                X_Msg_Data             =>X_Msg_Data);

 END IF;

 END LOOP;

END IF;

IF NOT l_Does_Description_exist THEN
   -- Create Default Description Attribs
   l_ATTRIBUTE_TYPE_rec.ATTRIBUTE_TYPE_CODE := G_DESCRIPTION;
   l_ATTRIBUTE_TYPE_rec.ATTRIBUTE_TYPE_name := 'Description';
   l_ATTRIBUTE_TYPE_rec.DESCRIPTION := 'Description OF the ' || l_content_type_rec.CONTENT_TYPE_CODE||'.';
   l_ATTRIBUTE_TYPE_rec.CONTENT_TYPE_CODE := l_content_type_rec.CONTENT_TYPE_CODE;
   l_ATTRIBUTE_TYPE_rec.DATA_TYPE_CODE := 'string';
   l_ATTRIBUTE_TYPE_rec.DATA_LENGTH := 2000;
   l_ATTRIBUTE_TYPE_rec.MIN_INSTANCES := 1;
   l_ATTRIBUTE_TYPE_rec.MAX_INSTANCES := 1;
   l_ATTRIBUTE_TYPE_rec.UPDATEABLE_FLAG := 'T';

               Create_Attribute_Type(
                P_Api_Version_Number   =>P_Api_Version_Number,
                P_Init_Msg_List        =>P_Init_Msg_List,
                P_Commit               =>P_Commit,
                P_Validation_Level     =>Fnd_Api.G_VALID_LEVEL_FULL,
                P_Attribute_Type_Rec   =>l_Attribute_Type_rec,
                X_Return_Status        =>X_Return_Status,
                X_Msg_Count            =>X_Msg_Count,
                X_Msg_Data             =>X_Msg_Data);

END IF;



IF NOT l_Does_name_exist THEN
   -- Create Default name Attribs
   l_ATTRIBUTE_TYPE_TBL(1).ATTRIBUTE_TYPE_CODE := G_NAME;
   l_ATTRIBUTE_TYPE_TBL(1).ATTRIBUTE_TYPE_name := 'Name';
   l_ATTRIBUTE_TYPE_TBL(1).DESCRIPTION := 'Name of the ' || l_content_type_rec.CONTENT_TYPE_CODE ||'.';
   l_ATTRIBUTE_TYPE_TBL(1).CONTENT_TYPE_CODE := l_content_type_rec.CONTENT_TYPE_CODE;
   l_ATTRIBUTE_TYPE_TBL(1).DATA_TYPE_CODE := 'string';
   l_ATTRIBUTE_TYPE_TBL(1).DATA_LENGTH := 240;
   l_ATTRIBUTE_TYPE_TBL(1).MIN_INSTANCES := 0;
   l_ATTRIBUTE_TYPE_TBL(1).MAX_INSTANCES := 1;
   l_ATTRIBUTE_TYPE_TBL(1).UPDATEABLE_FLAG := 'T';
               Create_Attribute_Type(
                P_Api_Version_Number   =>P_Api_Version_Number,
                P_Init_Msg_List        =>P_Init_Msg_List,
                P_Commit               =>P_Commit,
                P_Validation_Level     =>Fnd_Api.G_VALID_LEVEL_FULL,
                P_Attribute_Type_Rec   =>l_Attribute_Type_Tbl(1),
                X_Return_Status        =>X_Return_Status,
                X_Msg_Count            =>X_Msg_Count,
                X_Msg_Data             =>X_Msg_Data);

END IF;


-- SELECT A.*
-- INTO l_temp
-- FROM TABLE(CAST(l_atype_code AS JTF_VARCHAR2_TABLE_100)) A;


-- dbms_output.put_line('COUNT ' || l_temp);
---
      IF x_return_status<>Fnd_Api.G_RET_STS_SUCCESS THEN
         IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
      Fnd_Message.Set_name('IBC', 'IBC_INSERT_ERROR');
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
        DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name);
        --ROLLBACK TO SAVEPOINT l_api_name;
       Ibc_Utilities_Pvt.HANDLE_EXCEPTIONS(
     P_API_name => L_API_name
    ,P_PKG_name => G_PKG_name
    ,P_EXCEPTION_LEVEL => Fnd_Msg_Pub.G_MSG_LVL_ERROR
    ,P_PACKAGE_TYPE => Ibc_Utilities_Pvt.G_PVT
    ,P_SQLCODE => SQLCODE
    ,P_SQLERRM => SQLERRM
    ,X_MSG_COUNT => X_MSG_COUNT
    ,X_MSG_DATA => X_MSG_DATA
    ,X_RETURN_STATUS => X_RETURN_STATUS);

   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
       DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name);
       Ibc_Utilities_Pvt.HANDLE_EXCEPTIONS(
     P_API_name => L_API_name
    ,P_PKG_name => G_PKG_name
    ,P_EXCEPTION_LEVEL => Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR
    ,P_PACKAGE_TYPE => Ibc_Utilities_Pvt.G_PVT
    ,P_SQLCODE => SQLCODE
    ,P_SQLERRM => SQLERRM
    ,X_MSG_COUNT => X_MSG_COUNT
    ,X_MSG_DATA => X_MSG_DATA
    ,X_RETURN_STATUS => X_RETURN_STATUS);

   WHEN OTHERS THEN
         DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name);
       Ibc_Utilities_Pvt.HANDLE_EXCEPTIONS(
     P_API_name => L_API_name
    ,P_PKG_name => G_PKG_name
    ,P_EXCEPTION_LEVEL => Ibc_Utilities_Pvt.G_EXC_OTHERS
    ,P_PACKAGE_TYPE => Ibc_Utilities_Pvt.G_PVT
    ,P_SQLCODE => SQLCODE
    ,P_SQLERRM => SQLERRM
    ,X_MSG_COUNT => X_MSG_COUNT
    ,X_MSG_DATA => X_MSG_DATA
    ,X_RETURN_STATUS => X_RETURN_STATUS);

END Create_Content_Type;


PROCEDURE Create_Attribute_Type(
    P_Api_Version_Number         IN     NUMBER,
    P_Init_Msg_List              IN     VARCHAR2     ,--:= FND_API.G_FALSE,
    P_Commit                     IN     VARCHAR2     ,--:= FND_API.G_FALSE,
    P_Validation_Level     IN     NUMBER       ,--:= FND_API.G_VALID_LEVEL_FULL,
    P_Attribute_Type_Rec    IN     Ibc_Ctype_Pvt.Attribute_Type_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS

    CURSOR C_Content_Type(p_Content_Type_Code IN VARCHAR2) IS
    SELECT Content_Type_Code
 FROM ibc_content_types_b
    WHERE Content_Type_Code = p_Content_Type_Code;

    CURSOR C_Attribute_Type(p_content_type_code IN VARCHAR2
             ,p_attribute_type_code IN VARCHAR2)
    IS
    SELECT '1'
    FROM IBC_ATTRIBUTE_TYPES_B
    WHERE content_type_code = p_content_type_code
    AND   attribute_type_code = p_attribute_type_code;

    l_temp       CHAR(1);
 l_return_status     VARCHAR2(1) := Fnd_Api.G_RET_STS_SUCCESS;

 l_api_version_number     NUMBER := 1.0;
 l_api_name       VARCHAR2(50) := 'Create_Attribute_Type';
 lx_rowid      VARCHAR2(240);
 l_content_type_code    VARCHAR2(100);

 l_attribute_type_rec   Ibc_Ctype_Pvt.Attribute_Type_Rec_Type := P_Attribute_Type_Rec;

BEGIN

     -- Initialize API return status to SUCCESS
     x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

    -- Begin Validation for Attribute Type Record

   -- Check for all the NOT NULL Columns
    -- Attribute_Type_Code Cannot be NULL
       Ibc_Validate_Pvt.validate_NotNULL_VARCHAR2 (
         p_init_msg_list => Fnd_Api.G_FALSE,
         p_column_name => 'Attribute_Type_Code',
         p_notnull_column=> l_attribute_type_rec.attribute_type_code,
         x_return_status => x_return_status,
            x_msg_count     => x_msg_count,
            x_msg_data      => x_msg_data);

     IF x_return_status<>Fnd_Api.G_RET_STS_SUCCESS THEN
           l_return_status := x_return_status;
      END IF;


 --
 -- Validate the Content Type Code in Attribute Rec
       Ibc_Validate_Pvt.validate_NotNULL_VARCHAR2 (
         p_init_msg_list => Fnd_Api.G_FALSE,
         p_column_name => 'Content_Type_Code',
         p_notnull_column=> l_attribute_type_rec.Content_Type_Code,
         x_return_status => x_return_status,
            x_msg_count     => x_msg_count,
            x_msg_data      => x_msg_data);

     IF x_return_status<>Fnd_Api.G_RET_STS_SUCCESS THEN
           l_return_status := x_return_status;
      END IF;


   -- Check for Content Type Code exits in Content Type Table
   OPEN  C_Content_Type(p_Content_Type_Code => l_attribute_type_rec.Content_Type_Code);
      FETCH C_Content_Type INTO l_Content_Type_Code;
   IF C_Content_Type%NOTFOUND THEN
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
       IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
               Fnd_Message.Set_name('IBC', 'INVALID_CONTENT_TYPE_CODE');
               Fnd_Message.Set_Token('COLUMN', 'Content_Type_Code', FALSE);
               Fnd_Msg_Pub.ADD;
          END IF;
          CLOSE C_Content_Type;
          RAISE Fnd_Api.G_EXC_ERROR;
      END IF;
      CLOSE C_Content_Type;

 -- Attribute_Type_name Cannot be NULL
 Ibc_Validate_Pvt.validate_NotNULL_VARCHAR2 (
         p_init_msg_list => Fnd_Api.G_FALSE,
         p_column_name => 'Attribute_Type_Name',
         p_notnull_column=> l_attribute_type_rec.Attribute_type_name,
         x_return_status => x_return_status,
            x_msg_count     => x_msg_count,
            x_msg_data      => x_msg_data);

     IF x_return_status<>Fnd_Api.G_RET_STS_SUCCESS THEN
           l_return_status := x_return_status;
      END IF;

 -- Data_Type_Code Cannot be NULL
 Ibc_Validate_Pvt.validate_NotNULL_VARCHAR2 (
         p_init_msg_list => Fnd_Api.G_FALSE,
         p_column_name => 'Data_Type_code',
         p_notnull_column=> l_attribute_type_rec.Data_Type_code,
         x_return_status => x_return_status,
            x_msg_count     => x_msg_count,
            x_msg_data      => x_msg_data);

     IF x_return_status<>Fnd_Api.G_RET_STS_SUCCESS THEN
           l_return_status := x_return_status;
      END IF;


   -- Validate Data Type Code
   Ibc_Validate_Pvt.validate_Data_Type_Code(
     p_init_msg_list    => Fnd_Api.G_FALSE,
     p_data_Type_Code    => l_attribute_type_rec.Data_Type_code,
     x_return_status    => x_return_status,
        x_msg_count        => x_msg_count,
        x_msg_data         => x_msg_data);

     IF x_return_status<>Fnd_Api.G_RET_STS_SUCCESS THEN
           l_return_status := x_return_status;
      END IF;

   -- Validate Default Value
   Ibc_Validate_Pvt.validate_Default_Value(
     p_init_msg_list    => Fnd_Api.G_FALSE,
  p_data_type_code   => l_attribute_type_rec.data_type_code,
     p_default_Value    => l_attribute_type_rec.Default_value,
     x_return_status    => x_return_status,
           x_msg_count        => x_msg_count,
           x_msg_data         => x_msg_data);

     IF x_return_status<>Fnd_Api.G_RET_STS_SUCCESS THEN
           l_return_status := x_return_status;
      END IF;

  -- Validate Reference code
   Ibc_Validate_Pvt.validate_Reference_Code(
     p_init_msg_list    => Fnd_Api.G_FALSE,
     p_data_type_Code    => l_attribute_type_rec.data_type_Code,
     p_Reference_Code    => l_attribute_type_rec.Reference_Code,
     x_return_status    => x_return_status,
        x_msg_count        => x_msg_count,
        x_msg_data         => x_msg_data);

     IF x_return_status<>Fnd_Api.G_RET_STS_SUCCESS THEN
           l_return_status := x_return_status;
      END IF;

  -- Default Values for MIN and MAX Instances
  IF l_attribute_type_rec.min_instances IS NULL
  OR l_attribute_type_rec.min_instances = Fnd_Api.G_MISS_NUM THEN
     l_attribute_type_rec.min_instances := 0;
  END IF;

--   IF l_attribute_type_rec.max_instances IS NULL
--   OR l_attribute_type_rec.max_instances = FND_API.G_MISS_NUM THEN
--      l_attribute_type_rec.max_instances := 1;
--   END IF;

  -- Validate Min Max Instances
   Ibc_Validate_Pvt.validate_Min_Max_Instances(
     p_init_msg_list    => Fnd_Api.G_FALSE,
     p_Min_Instances    => l_attribute_type_rec.Min_instances,
     p_Max_Instances    => l_attribute_type_rec.Max_instances,
     x_return_status    => x_return_status,
        x_msg_count        => x_msg_count,
        x_msg_data         => x_msg_data);

     IF x_return_status<>Fnd_Api.G_RET_STS_SUCCESS THEN
           l_return_status := x_return_status;
      END IF;


  -- End Validation for Attribute Type Record


  -- Validate Object Version Number
   IF l_attribute_type_rec.OBJECT_VERSION_NUMBER IS NULL
  OR l_attribute_type_rec.OBJECT_VERSION_NUMBER = Fnd_Api.G_MISS_NUM THEN
     l_attribute_type_rec.OBJECT_VERSION_NUMBER := 1;
  END IF;

 -- Check for Uniqueness
  OPEN  C_Attribute_Type(p_Content_Type_Code  => l_attribute_type_rec.content_type_code
         ,p_attribute_Type_Code  => l_attribute_type_rec.Attribute_type_code);
  FETCH C_Attribute_Type INTO l_temp;
  IF C_Attribute_Type%FOUND THEN
     x_return_status := Fnd_Api.G_RET_STS_ERROR;
      IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
           Fnd_Message.Set_name('IBC', 'IBC_ALREADY_EXISTS');
              Fnd_Message.Set_Token('DUPLICATE_OBJECT_TOKEN', 'Attribute_Type_Code',FALSE);
              Fnd_Msg_Pub.ADD;
      END IF;
  END IF;

  CLOSE C_Attribute_Type;



IF l_return_status<>Fnd_Api.G_RET_STS_SUCCESS
 OR x_return_status<>Fnd_Api.G_RET_STS_SUCCESS THEN
     RAISE Fnd_Api.G_EXC_ERROR;
END IF;



  Ibc_Attribute_Types_Pkg.insert_row (
              x_rowid         =>lx_rowid,
              p_attribute_type_code     =>l_attribute_type_rec.attribute_type_code,
              p_content_type_code      =>l_attribute_type_rec.content_type_code,
              p_data_type_code       =>l_attribute_type_rec.data_type_code,
              p_data_length       =>l_attribute_type_rec.data_length,
              p_min_instances       =>l_attribute_type_rec.min_instances,
              p_max_instances       =>l_attribute_type_rec.max_instances,
              p_reference_code       =>l_attribute_type_rec.reference_code,
              p_default_value       =>l_attribute_type_rec.default_value,
              p_updateable_flag      =>l_attribute_type_rec.updateable_flag,
              p_object_version_number     =>l_attribute_type_rec.object_version_number,
              p_attribute_type_name     =>l_attribute_type_rec.attribute_type_name,
              p_description       =>l_attribute_type_rec.description,
              p_creation_date       =>l_attribute_type_rec.creation_date,
              p_created_by        =>l_attribute_type_rec.created_by,
              p_last_update_date      =>l_attribute_type_rec.last_update_date,
              p_last_updated_by      =>l_attribute_type_rec.last_updated_by,
              p_last_update_login      =>l_attribute_type_rec.last_update_login
            );


END create_attribute_type;


PROCEDURE Update_Content_Type(
    P_Api_Version_Number         IN     NUMBER,
    P_Init_Msg_List              IN     VARCHAR2     ,--:= FND_API.G_FALSE,
    P_Commit                     IN     VARCHAR2     ,--:= FND_API.G_FALSE,
    P_Validation_Level     IN     NUMBER       ,--:= FND_API.G_VALID_LEVEL_FULL,
    P_Content_Type_Rec     IN     Ibc_Ctype_Pvt.Content_Type_Rec_Type   ,--:= Ibc_Ctype_Pvt.G_MISS_Content_Type_Rec,
    P_Attribute_Type_Tbl    IN     Ibc_Ctype_Pvt.Attribute_Type_Tbl_Type ,--:= Ibc_Ctype_Pvt.G_Miss_Attribute_Type_Tbl,
    x_Content_Type_Rec     OUT NOCOPY  Ibc_Ctype_Pvt.Content_Type_Rec_Type,
    x_Attribute_Type_Tbl    OUT NOCOPY  Ibc_Ctype_Pvt.Attribute_Type_Tbl_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS

    CURSOR C_Content_Type(p_Content_Type_Code IN VARCHAR2) IS
    SELECT
    Content_Type_Code
 FROM ibc_content_types_b
    WHERE Content_Type_Code = p_Content_Type_Code;


    CURSOR C_Attribute_Type(p_content_type_code IN VARCHAR2
             ,p_attribute_type_code IN VARCHAR2)
    IS
    SELECT '1'
    FROM IBC_ATTRIBUTE_TYPES_B
    WHERE content_type_code = p_content_type_code
    AND   attribute_type_code = p_attribute_type_code;

    l_temp       CHAR(1);
 l_return_status     VARCHAR2(1) := Fnd_Api.G_RET_STS_SUCCESS;

 l_api_version_number     NUMBER := 1.0;
 l_api_name       VARCHAR2(50) := 'Update_Content_Type';
 l_Content_Type_Code    VARCHAR2(100);
 lx_rowid      VARCHAR2(240);

 l_Content_Type_Rec    Ibc_Ctype_Pvt.Content_Type_Rec_Type   := p_Content_Type_Rec;
    l_Attribute_Type_Tbl   Ibc_Ctype_Pvt.Attribute_Type_Tbl_Type := p_Attribute_Type_Tbl;
 l_attribute_type_rec   Ibc_Ctype_Pvt.Attribute_Type_Rec_Type;

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
              Fnd_Message.Set_name(' + appShortname +', 'UT_CANNOT_GET_PROFILE_VALUE');
              Fnd_Message.Set_Token('PROFILE', 'USER_ID', FALSE);
              Fnd_Msg_Pub.ADD;
          END IF;
          RAISE Fnd_Api.G_EXC_ERROR;
      END IF;


IF NOT IsCTypeRecordEmpty(l_content_type_rec) THEN

   -- Check for all the NOT NULL Columns
   -- Content_TYpe_Code Cannot be NULL
      Ibc_Validate_Pvt.validate_NotNULL_VARCHAR2 (
        p_init_msg_list => Fnd_Api.G_FALSE,
        p_column_name => 'Content_Type_Code',
        p_notnull_column=> l_content_type_rec.content_type_code,
        x_return_status => x_return_status,
            x_msg_count     => x_msg_count,
            x_msg_data      => x_msg_data);

   -- Don't RAISE the EXCEPTION Yet. RUN ALL the validation procedures
   -- and show Exceptions all at once.
     IF x_return_status<>Fnd_Api.G_RET_STS_SUCCESS THEN
           l_return_status := x_return_status;
      END IF;


   -- Check If the Record Exists
   OPEN  C_Content_Type(p_Content_Type_Code => l_content_type_rec.content_type_code);
      FETCH C_Content_Type INTO l_Content_Type_Code;
   IF C_Content_Type%NOTFOUND THEN
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
       IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
               Fnd_Message.Set_name('IBC', 'INVALID_CONTENT_TYPE_CODE');
               Fnd_Message.Set_Token('COLUMN', 'Content_Type_Code', FALSE);
               Fnd_Msg_Pub.ADD;
          END IF;
          CLOSE C_Content_Type;
          RAISE Fnd_Api.G_EXC_ERROR;
      END IF;
      CLOSE C_Content_Type;


   IF l_content_type_rec.content_type_status <> Fnd_Api.G_MISS_CHAR THEN
   -- Validate Content Type Status
    Ibc_Validate_Pvt.validate_Content_Type_Status(
      p_init_msg_list    => Fnd_Api.G_FALSE,
      p_Content_Type_Status => l_content_type_rec.content_type_status,
      x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);

         IF x_return_status<>Fnd_Api.G_RET_STS_SUCCESS THEN
               l_return_status := x_return_status;
          END IF;
   END IF;


   IF l_content_type_rec.application_id <> Fnd_Api.G_MISS_NUM THEN
   -- Validate Application Id
   Ibc_Validate_Pvt.validate_application_id(
      p_init_msg_list    => Fnd_Api.G_FALSE,
      p_application_id    => l_content_type_rec.application_id,
      x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);

         IF x_return_status<>Fnd_Api.G_RET_STS_SUCCESS
      OR l_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
                RAISE Fnd_Api.G_EXC_ERROR;
          END IF;
   END IF;

--
-- Table Handler to Update Row into IBC_CONTENT_TYPES
--
        Ibc_Content_Types_Pkg.UPDATE_ROW (
             p_CONTENT_TYPE_CODE    =>l_content_type_rec.CONTENT_TYPE_CODE,
             p_CONTENT_TYPE_STATUS    =>l_content_type_rec.CONTENT_TYPE_STATUS,
             p_APPLICATION_ID     =>l_content_type_rec.APPLICATION_ID,
             p_REQUEST_ID      =>l_content_type_rec.REQUEST_ID,
             p_OBJECT_VERSION_NUMBER   =>l_content_type_rec.oBJECT_VERSION_NUMBER,
             p_CONTENT_TYPE_name    =>l_content_type_rec.CONTENT_TYPE_name,
             p_DESCRIPTION      =>l_content_type_rec.DESCRIPTION,
             p_LAST_UPDATE_DATE    =>l_content_type_rec.LAST_UPDATE_DATE,
             p_LAST_UPDATED_BY     =>l_content_type_rec.LAST_UPDATED_BY,
             p_LAST_UPDATE_LOGIN    =>l_content_type_rec.LAST_UPDATE_LOGIN);


END IF;


-- Insert Or Update The Corresponding Attributes in ibc_attribute_types_b  table

IF l_attribute_type_tbl.COUNT <> 0 THEN

 FOR i IN l_attribute_type_tbl.FIRST..l_attribute_type_tbl.LAST LOOP

 IF l_attribute_type_tbl.EXISTS(i) AND NOT IsATypeRecordEmpty(l_Attribute_Type_Tbl(i))
 THEN

  IF l_Attribute_Type_Tbl(i).OPERATION_CODE = 'CREATE' THEN

            Create_Attribute_Type(
                P_Api_Version_Number   =>P_Api_Version_Number,
                P_Init_Msg_List        =>P_Init_Msg_List,
                P_Commit               =>P_Commit,
                P_Validation_Level     =>Fnd_Api.G_VALID_LEVEL_FULL,
                P_Attribute_Type_Rec   =>l_Attribute_Type_Tbl(i),
                X_Return_Status        =>X_Return_Status,
                X_Msg_Count            =>X_Msg_Count,
                X_Msg_Data             =>X_Msg_Data);

  ELSIF l_Attribute_Type_Tbl(i).OPERATION_CODE = 'UPDATE' THEN

      Update_Attribute_Type(
                P_Api_Version_Number   =>P_Api_Version_Number,
                P_Init_Msg_List        =>P_Init_Msg_List,
                P_Commit               =>P_Commit,
                P_Validation_Level     =>Fnd_Api.G_VALID_LEVEL_FULL,
                P_Attribute_Type_Rec   =>l_Attribute_Type_Tbl(i),
                X_Return_Status        =>X_Return_Status,
                X_Msg_Count            =>X_Msg_Count,
                X_Msg_Data             =>X_Msg_Data);

   ELSIF l_Attribute_Type_Tbl(i).OPERATION_CODE = 'DELETE' THEN

      Delete_Attribute_Type(
                P_Api_Version_Number   =>P_Api_Version_Number,
                P_Init_Msg_List        =>P_Init_Msg_List,
                P_Commit               =>P_Commit,
                P_Validation_Level     =>Fnd_Api.G_VALID_LEVEL_FULL,
                P_Attribute_Type_Rec   =>l_Attribute_Type_Tbl(i),
                X_Return_Status        =>X_Return_Status,
                X_Msg_Count            =>X_Msg_Count,
                X_Msg_Data             =>X_Msg_Data);

  END IF;

 END IF;

 END LOOP;

END IF;

---
      IF x_return_status<>Fnd_Api.G_RET_STS_SUCCESS THEN
         IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
      Fnd_Message.Set_name('IBC', 'IBC_UPDATE_ERROR');
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
     P_API_name => L_API_name
    ,P_PKG_name => G_PKG_name
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
     P_API_name => L_API_name
    ,P_PKG_name => G_PKG_name
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
     P_API_name => L_API_name
    ,P_PKG_name => G_PKG_name
    ,P_EXCEPTION_LEVEL => Ibc_Utilities_Pvt.G_EXC_OTHERS
    ,P_PACKAGE_TYPE => Ibc_Utilities_Pvt.G_PVT
    ,P_SQLCODE => SQLCODE
    ,P_SQLERRM => SQLERRM
    ,X_MSG_COUNT => X_MSG_COUNT
    ,X_MSG_DATA => X_MSG_DATA
    ,X_RETURN_STATUS => X_RETURN_STATUS);

END Update_Content_type;


PROCEDURE Delete_Content_Type(
    P_Api_Version_Number         IN     NUMBER,
    P_Init_Msg_List              IN     VARCHAR2     ,--:= FND_API.G_FALSE,
    P_Commit                     IN     VARCHAR2     ,--:= FND_API.G_FALSE,
    P_Validation_Level     IN     NUMBER       ,--:= FND_API.G_VALID_LEVEL_FULL,
    P_Content_Type_Code     IN     VARCHAR2,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS

    CURSOR C_Content_Type IS
    SELECT
    Content_Type_Code
 FROM ibc_content_types_b
    WHERE Content_Type_Code = p_Content_Type_Code;


    CURSOR C_Attribute_Type
    IS
    SELECT attribute_Type_code
    FROM IBC_ATTRIBUTE_TYPES_B
    WHERE Reference_code = p_content_type_code;

 l_return_status     VARCHAR2(1) := Fnd_Api.G_RET_STS_SUCCESS;

 l_api_version_number     NUMBER := 1.0;
 l_api_name       VARCHAR2(50) := 'Delete_Content_Type';
 l_Content_Type_Code    VARCHAR2(100);
 l_Attribute_Type_Code    VARCHAR2(100);

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
              Fnd_Message.Set_name(' + appShortname +', 'UT_CANNOT_GET_PROFILE_VALUE');
              Fnd_Message.Set_Token('PROFILE', 'USER_ID', FALSE);
              Fnd_Msg_Pub.ADD;
          END IF;
          RAISE Fnd_Api.G_EXC_ERROR;
      END IF;


   -- Check for all the NOT NULL Columns
   -- Content_TYpe_Code Cannot be NULL
      Ibc_Validate_Pvt.validate_NotNULL_VARCHAR2 (
        p_init_msg_list => Fnd_Api.G_FALSE,
        p_column_name => 'Content_Type_Code',
        p_notnull_column=> p_content_type_code,
        x_return_status => x_return_status,
            x_msg_count     => x_msg_count,
            x_msg_data      => x_msg_data);

   -- Don't RAISE the EXCEPTION Yet. RUN ALL the validation procedures
   -- and show Exceptions all at once.
     IF x_return_status<>Fnd_Api.G_RET_STS_SUCCESS THEN
           l_return_status := x_return_status;
      END IF;


   -- Check If the Record Exists
   OPEN  C_Content_Type;
      FETCH C_Content_Type INTO l_Content_Type_Code;
   IF C_Content_Type%NOTFOUND THEN
       IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
               Fnd_Message.Set_name('IBC', 'Cannot Find Record to be Deleted');
               Fnd_Message.Set_Token('COLUMN', 'Content_Type_Code', FALSE);
               Fnd_Msg_Pub.ADD;
          END IF;
          CLOSE C_Content_Type;
          RAISE Fnd_Api.G_EXC_ERROR;
      END IF;
      CLOSE C_Content_Type;

     OPEN  C_Attribute_Type;
      FETCH C_Attribute_Type INTO l_Content_Type_Code;
   IF C_Attribute_Type%FOUND THEN
       IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
               Fnd_Message.Set_name('IBC', 'References_ExistContentTypeCode');
               Fnd_Message.Set_Token('COLUMN', 'Content_Type_Code', FALSE);
               Fnd_Msg_Pub.ADD;
          END IF;
          CLOSE C_Attribute_Type;
          RAISE Fnd_Api.G_EXC_ERROR;
      END IF;
      CLOSE C_Attribute_Type;


         IF x_return_status<>Fnd_Api.G_RET_STS_SUCCESS
      OR l_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
                RAISE Fnd_Api.G_EXC_ERROR;
          END IF;

--
-- Table Handler to Delete Row from IBC_ATTRIBUTE_TYPES
-- If a Content Type does not have any attributes. Don't
-- give Error
--
     BEGIN
  Ibc_Attribute_Types_Pkg.delete_rows (
              p_content_type_code      =>p_content_type_code
            );
  EXCEPTION WHEN NO_DATA_FOUND THEN
   NULL;
  END;

        Ibc_Content_Types_Pkg.DELETE_ROW (
             p_CONTENT_TYPE_CODE    =>p_CONTENT_TYPE_CODE);


      IF x_return_status<>Fnd_Api.G_RET_STS_SUCCESS THEN
         IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
      Fnd_Message.Set_name('IBC', 'IBC_DELETE_ERROR');
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
     P_API_name => L_API_name
    ,P_PKG_name => G_PKG_name
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
     P_API_name => L_API_name
    ,P_PKG_name => G_PKG_name
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
     P_API_name => L_API_name
    ,P_PKG_name => G_PKG_name
    ,P_EXCEPTION_LEVEL => Ibc_Utilities_Pvt.G_EXC_OTHERS
    ,P_PACKAGE_TYPE => Ibc_Utilities_Pvt.G_PVT
    ,P_SQLCODE => SQLCODE
    ,P_SQLERRM => SQLERRM
    ,X_MSG_COUNT => X_MSG_COUNT
    ,X_MSG_DATA => X_MSG_DATA
    ,X_RETURN_STATUS => X_RETURN_STATUS);

END Delete_Content_Type;

PROCEDURE Update_Attribute_Type(
    P_Api_Version_Number         IN     NUMBER,
    P_Init_Msg_List              IN     VARCHAR2     ,--:= FND_API.G_FALSE,
    P_Commit                     IN     VARCHAR2     ,--:= FND_API.G_FALSE,
    P_Validation_Level     IN     NUMBER       ,--:= FND_API.G_VALID_LEVEL_FULL,
    P_Attribute_Type_Rec    IN     Ibc_Ctype_Pvt.Attribute_Type_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS

    CURSOR C_Content_Type(p_Content_Type_Code IN VARCHAR2) IS
    SELECT Content_Type_Code
 FROM ibc_content_types_b
    WHERE Content_Type_Code = p_Content_Type_Code;

    CURSOR C_Attribute_Type(p_content_type_code IN VARCHAR2
             ,p_attribute_type_code IN VARCHAR2)
    IS
    SELECT '1'
    FROM IBC_ATTRIBUTE_TYPES_B
    WHERE content_type_code = p_content_type_code
    AND   attribute_type_code = p_attribute_type_code;

    l_temp       CHAR(1);
 l_return_status     VARCHAR2(1) := Fnd_Api.G_RET_STS_SUCCESS;

 l_api_version_number     NUMBER := 1.0;
 l_api_name       VARCHAR2(50) := 'Update_Attribute_Type';
 lx_rowid      VARCHAR2(240);
 l_content_type_code    VARCHAR2(100);

 l_attribute_type_rec   Ibc_Ctype_Pvt.Attribute_Type_Rec_Type := P_Attribute_Type_Rec;
 l_old_attribute_type_rec  Ibc_Ctype_Pvt.Attribute_Type_Rec_Type;

BEGIN

-- Initialize API return status to SUCCESS
x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

-- Check If Row exists
 l_old_attribute_type_rec := Query_Attribute_Type_Row
           (p_Content_Type_Code  => l_attribute_type_rec.content_type_code
           ,p_attribute_Type_Code => l_attribute_type_rec.Attribute_type_code);


 -- Begin Validation for Attribute Type Record
   -- Check for all the NOT NULL Columns
    -- Attribute_Type_Code Cannot be NULL
       Ibc_Validate_Pvt.validate_NotNULL_VARCHAR2 (
         p_init_msg_list => Fnd_Api.G_FALSE,
         p_column_name => 'Attribute_Type_Code',
         p_notnull_column=> l_attribute_type_rec.attribute_type_code,
         x_return_status => x_return_status,
            x_msg_count     => x_msg_count,
            x_msg_data      => x_msg_data);

     IF x_return_status<>Fnd_Api.G_RET_STS_SUCCESS THEN
           l_return_status := x_return_status;
      END IF;

 --
 -- Validate the Content Type Code in Attribute Rec
       Ibc_Validate_Pvt.validate_NotNULL_VARCHAR2 (
         p_init_msg_list => Fnd_Api.G_FALSE,
         p_column_name => 'Content_Type_Code',
         p_notnull_column=> l_attribute_type_rec.Content_Type_Code,
         x_return_status => x_return_status,
            x_msg_count     => x_msg_count,
            x_msg_data      => x_msg_data);

     IF x_return_status<>Fnd_Api.G_RET_STS_SUCCESS THEN
           l_return_status := x_return_status;
      END IF;


 IF l_attribute_type_rec.Attribute_type_name <> Fnd_Api.G_MISS_CHAR THEN
 -- Content_TYpe_name Cannot be NULL
 Ibc_Validate_Pvt.validate_NotNULL_VARCHAR2 (
         p_init_msg_list => Fnd_Api.G_FALSE,
         p_column_name => 'Attribute_Type_name',
         p_notnull_column=> l_attribute_type_rec.Attribute_type_name,
         x_return_status => x_return_status,
            x_msg_count     => x_msg_count,
            x_msg_data      => x_msg_data);

     IF x_return_status<>Fnd_Api.G_RET_STS_SUCCESS THEN
           l_return_status := x_return_status;
      END IF;

  END IF;


 IF l_attribute_type_rec.Data_Type_code <> Fnd_Api.G_MISS_CHAR THEN
 -- Data_Type_Code Cannot be NULL
 Ibc_Validate_Pvt.validate_NotNULL_VARCHAR2 (
         p_init_msg_list => Fnd_Api.G_FALSE,
         p_column_name => 'Data_Type_code',
         p_notnull_column=> l_attribute_type_rec.Data_Type_code,
         x_return_status => x_return_status,
            x_msg_count     => x_msg_count,
            x_msg_data      => x_msg_data);

     IF x_return_status<>Fnd_Api.G_RET_STS_SUCCESS THEN
           l_return_status := x_return_status;
      END IF;

 END IF;


 IF l_attribute_type_rec.Data_Type_code <> Fnd_Api.G_MISS_CHAR THEN
    -- Validate Data Type Code
     Ibc_Validate_Pvt.validate_Data_Type_Code(
       p_init_msg_list    => Fnd_Api.G_FALSE,
       p_data_Type_Code    => l_attribute_type_rec.Data_Type_code,
       x_return_status    => x_return_status,
          x_msg_count        => x_msg_count,
          x_msg_data         => x_msg_data);

     IF x_return_status<>Fnd_Api.G_RET_STS_SUCCESS THEN
             l_return_status := x_return_status;
        END IF;
 END IF;


IF l_attribute_type_rec.Default_value <> Fnd_Api.G_MISS_CHAR THEN

   IF l_attribute_type_rec.Data_Type_code = Fnd_Api.G_MISS_CHAR THEN
      l_attribute_type_rec.data_type_code := l_old_attribute_type_rec.data_type_code;
   END IF;

   -- Validate Default Value
   Ibc_Validate_Pvt.validate_Default_Value(
     p_init_msg_list    => Fnd_Api.G_FALSE,
  p_data_type_code   => l_attribute_type_rec.data_type_code,
     p_default_Value    => l_attribute_type_rec.Default_value,
     x_return_status    => x_return_status,
        x_msg_count        => x_msg_count,
        x_msg_data         => x_msg_data);

     IF x_return_status<>Fnd_Api.G_RET_STS_SUCCESS THEN
           l_return_status := x_return_status;
      END IF;
END IF;


IF l_attribute_type_rec.Reference_Code <> Fnd_Api.G_MISS_CHAR THEN

   IF l_attribute_type_rec.Data_Type_code = Fnd_Api.G_MISS_CHAR THEN
      l_attribute_type_rec.data_type_code := l_old_attribute_type_rec.data_type_code;
   END IF;

  -- Validate Reference code
   Ibc_Validate_Pvt.validate_Reference_Code(
     p_init_msg_list    => Fnd_Api.G_FALSE,
     p_data_type_Code    => l_attribute_type_rec.data_type_Code,
     p_Reference_Code    => l_attribute_type_rec.Reference_Code,
     x_return_status    => x_return_status,
           x_msg_count        => x_msg_count,
           x_msg_data         => x_msg_data);

     IF x_return_status<>Fnd_Api.G_RET_STS_SUCCESS THEN
           l_return_status := x_return_status;
      END IF;

END IF;



IF l_attribute_type_rec.min_instances IS NULL THEN
   l_attribute_type_rec.min_instances := 0;
END IF;

-- IF l_attribute_type_rec.max_instances IS NULL THEN
--    l_attribute_type_rec.max_instances := 1;
-- END IF;

IF l_attribute_type_rec.Min_instances =  Fnd_Api.G_MISS_NUM THEN
   l_attribute_type_rec.Min_instances  := l_old_attribute_type_rec.Min_instances;
END IF;

IF l_attribute_type_rec.Max_instances =  Fnd_Api.G_MISS_NUM THEN
   l_attribute_type_rec.Max_instances  := l_old_attribute_type_rec.Max_instances;
END IF;

   -- Validate Min Max Instances
   Ibc_Validate_Pvt.validate_Min_Max_Instances(
     p_init_msg_list    => Fnd_Api.G_FALSE,
     p_Min_Instances    => l_attribute_type_rec.Min_instances,
     p_Max_Instances    => l_attribute_type_rec.Max_instances,
     x_return_status    => x_return_status,
           x_msg_count        => x_msg_count,
           x_msg_data         => x_msg_data);

   IF x_return_status<>Fnd_Api.G_RET_STS_SUCCESS THEN
           l_return_status := x_return_status;
   END IF;


  IF l_return_status<>Fnd_Api.G_RET_STS_SUCCESS
   OR x_return_status<>Fnd_Api.G_RET_STS_SUCCESS THEN
       x_return_status := l_return_status;
       RAISE Fnd_Api.G_EXC_ERROR;
  END IF;


-- End Validation for Attribute Type Record

  Ibc_Attribute_Types_Pkg.Update_row (
              p_attribute_type_code     =>l_attribute_type_rec.attribute_type_code,
              p_content_type_code      =>l_attribute_type_rec.content_type_code,
              p_data_type_code       =>l_attribute_type_rec.data_type_code,
              p_data_length       =>l_attribute_type_rec.data_length,
              p_min_instances       =>l_attribute_type_rec.min_instances,
              p_max_instances       =>l_attribute_type_rec.max_instances,
              p_reference_code       =>l_attribute_type_rec.reference_code,
              p_default_value       =>l_attribute_type_rec.default_value,
              p_updateable_flag      =>l_attribute_type_rec.updateable_flag,
              p_object_version_number     =>l_attribute_type_rec.object_version_number,
              p_attribute_type_name     =>l_attribute_type_rec.attribute_type_name,
              p_description       =>l_attribute_type_rec.description,
              p_last_update_date      =>l_attribute_type_rec.last_update_date,
              p_last_updated_by      =>l_attribute_type_rec.last_updated_by,
              p_last_update_login      =>l_attribute_type_rec.last_update_login
            );

END Update_attribute_type;


PROCEDURE Delete_Attribute_Type(
    P_Api_Version_Number         IN     NUMBER,
    P_Init_Msg_List              IN     VARCHAR2     ,--:= FND_API.G_FALSE,
    P_Commit                     IN     VARCHAR2     ,--:= FND_API.G_FALSE,
    P_Validation_Level     IN     NUMBER       ,--:= FND_API.G_VALID_LEVEL_FULL,
    P_Attribute_Type_Rec    IN     Ibc_Ctype_Pvt.Attribute_Type_Rec_Type,
    X_Return_Status              OUT NOCOPY  VARCHAR2,
    X_Msg_Count                  OUT NOCOPY  NUMBER,
    X_Msg_Data                   OUT NOCOPY  VARCHAR2
    )
IS
 l_return_status     VARCHAR2(1) := Fnd_Api.G_RET_STS_SUCCESS;
 l_api_name       VARCHAR2(50) := 'Delete_Attribute_Type';
 l_attribute_type_rec   Ibc_Ctype_Pvt.Attribute_Type_Rec_Type := P_Attribute_Type_Rec;

BEGIN

-- Initialize API return status to SUCCESS
x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

IF l_attribute_type_rec.attribute_type_code IN (G_NAME,G_DESCRIPTION) THEN
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      IF Fnd_Msg_Pub.Check_Msg_Level (Fnd_Msg_Pub.G_MSG_LVL_ERROR) THEN
           Fnd_Message.Set_name('IBC', 'Name OR Description Cannot be Deleted');
              Fnd_Msg_Pub.ADD;
      END IF;
     RAISE Fnd_Api.G_EXC_ERROR;
END IF;

 -- Begin Validation for Attribute Type Record
   -- Check for all the NOT NULL Columns
    -- Attribute_Type_Code Cannot be NULL
       Ibc_Validate_Pvt.validate_NotNULL_VARCHAR2 (
         p_init_msg_list => Fnd_Api.G_FALSE,
         p_column_name => 'Attribute_Type_Code',
         p_notnull_column=> l_attribute_type_rec.attribute_type_code,
         x_return_status => x_return_status,
            x_msg_count     => x_msg_count,
            x_msg_data      => x_msg_data);

     IF x_return_status<>Fnd_Api.G_RET_STS_SUCCESS THEN
           l_return_status := x_return_status;
      END IF;

 --
 -- Validate the Content Type Code in Attribute Rec
       Ibc_Validate_Pvt.validate_NotNULL_VARCHAR2 (
         p_init_msg_list => Fnd_Api.G_FALSE,
         p_column_name => 'Content_Type_Code',
         p_notnull_column=> l_attribute_type_rec.Content_Type_Code,
         x_return_status => x_return_status,
            x_msg_count     => x_msg_count,
            x_msg_data      => x_msg_data);

     IF x_return_status<>Fnd_Api.G_RET_STS_SUCCESS THEN
           l_return_status := x_return_status;
      END IF;


      IF l_return_status<>Fnd_Api.G_RET_STS_SUCCESS
       OR x_return_status<>Fnd_Api.G_RET_STS_SUCCESS THEN
        x_return_status := l_return_status;
           RAISE Fnd_Api.G_EXC_ERROR;
      END IF;


  Ibc_Attribute_Types_Pkg.delete_row (
              p_attribute_type_code     =>l_attribute_type_rec.attribute_type_code,
              p_content_type_code      =>l_attribute_type_rec.content_type_code
            );

END Delete_Attribute_Type;



PROCEDURE get_Attribute_Type_LOV(
  P_Api_Version_Number         IN     NUMBER
    ,P_Init_Msg_List              IN     VARCHAR2     --:= FND_API.G_FALSE
 ,p_content_type_code     IN     VARCHAR2 --1
    ,p_attribute_type_code     IN     VARCHAR2  --2
    ,x_code        OUT NOCOPY JTF_VARCHAR2_TABLE_100 --4
    ,x_name        OUT NOCOPY JTF_VARCHAR2_TABLE_300 -- 5
 ,x_description       OUT NOCOPY JTF_VARCHAR2_TABLE_2000 --3
 ,X_Return_Status              OUT NOCOPY  VARCHAR2 --6
    ,X_Msg_Count                  OUT NOCOPY  NUMBER -- 7
    ,X_Msg_Data                   OUT NOCOPY  VARCHAR2 -- 8
    ) IS

CURSOR C_Attribs IS
SELECT A.flex_value_set_id,validation_type
FROM IBC_ATTRIBUTE_TYPES_B A, fnd_flex_value_sets F
WHERE a.flex_value_set_id = F.flex_value_set_id
AND A.attribute_type_code = p_attribute_type_code
AND A.content_type_code = p_content_type_code;

l_value_set_id    NUMBER;
lx_select        VARCHAR2(32000);
lx_success        VARCHAR2(10);
lx_mapping_code   VARCHAR2(32000);
l_vset_type    VARCHAR2(1);
l_api_name     VARCHAR2(30) := 'Get_Attribute_Type_LOV';

BEGIN

x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

OPEN C_attribs;
FETCH C_attribs INTO l_value_set_id,l_vset_type;

    IF C_attribs%NOTFOUND THEN
      CLOSE C_ATTRIBS;
     RETURN;
   END IF;
--        FND_MESSAGE.Set_name('IBC', 'Invalid Flex Value SET');
--           FND_MESSAGE.Set_Token('COLUMN',p_attribute_type_code, FALSE);
--           FND_MSG_PUB.ADD;
--           CLOSE C_attribs;
--           RAISE FND_API.G_EXC_ERROR;
--    END IF;

CLOSE C_ATTRIBS;

-- dbms_output.put_line(l_value_set_id);
-- dbms_output.put_line(l_vset_type);

IF  l_vset_type = 'F' THEN
   Fnd_Flex_Val_Api.get_table_vset_select
    (p_value_set_id       => l_value_set_id,
      x_select         =>lx_select,
      x_mapping_code      =>lx_mapping_code,
      x_success     =>lx_success);
--   dbms_output.put_line(lx_success);
ELSIF l_vset_type = 'I' THEN
   Fnd_Flex_Val_Api.get_independent_vset_select
   (p_value_set_id     => l_value_set_id,
      x_select     =>lx_select,
      x_mapping_code  =>lx_mapping_code,
      x_success   =>lx_success);
--  dbms_output.put_line(lx_success);
ELSE
 RETURN;
END IF;



lx_select := REPLACE(UPPER(lx_select),'FROM','BULK COLLECT INTO :tab1,:tab2,:tab3  FROM  ');

-- dbms_output.put_line(SUBSTR(lx_select,1,240));
-- dbms_output.put_line(SUBSTR(lx_select,241,480));


EXECUTE IMMEDIATE 'BEGIN ' || lx_select || ';  END;'
   USING OUT x_code, OUT x_name, OUT x_description;

      -- Standard call to get message count and if count is 1, get message info.
      Fnd_Msg_Pub.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );


EXCEPTION
   WHEN Fnd_Api.G_EXC_ERROR THEN
       ROLLBACK;
       Ibc_Utilities_Pvt.HANDLE_EXCEPTIONS(
     P_API_name => L_API_name
    ,P_PKG_name => G_PKG_name
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
     P_API_name => L_API_name
    ,P_PKG_name => G_PKG_name
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
     P_API_name => L_API_name
    ,P_PKG_name => G_PKG_name
    ,P_EXCEPTION_LEVEL => Ibc_Utilities_Pvt.G_EXC_OTHERS
    ,P_PACKAGE_TYPE => Ibc_Utilities_Pvt.G_PVT
    ,P_SQLCODE => SQLCODE
    ,P_SQLERRM => SQLERRM
    ,X_MSG_COUNT => X_MSG_COUNT
    ,X_MSG_DATA => X_MSG_DATA
    ,X_RETURN_STATUS => X_RETURN_STATUS);

END get_Attribute_Type_LOV;


PROCEDURE get_Content_Type(
     p_api_version_number      IN   NUMBER --DEFAULT 1.0
 ,p_init_msg_list           IN   VARCHAR2 --DEFAULT FND_API.g_false
    ,p_content_type_code         IN   VARCHAR2 -- 1
    ,x_content_type_name         OUT NOCOPY VARCHAR2 -- 2
    ,x_content_type_description     OUT NOCOPY VARCHAR2 -- 3
    ,x_content_type_status          OUT NOCOPY VARCHAR2 -- 4
    ,X_ATTRIBUTE_TYPE_CODE    OUT NOCOPY JTF_VARCHAR2_TABLE_100 -- 5
    ,x_ATTRIBUTE_TYPE_name    OUT NOCOPY JTF_VARCHAR2_TABLE_300  -- 6
    ,x_DESCRIPTION      OUT NOCOPY JTF_VARCHAR2_TABLE_2000 -- 7
    ,x_CONTENT_TYPE_CODE      OUT NOCOPY JTF_VARCHAR2_TABLE_100 -- 8
    ,x_DATA_TYPE_CODE       OUT NOCOPY JTF_VARCHAR2_TABLE_100 -- 9
    ,x_DATA_LENGTH      OUT NOCOPY JTF_NUMBER_TABLE -- 10
    ,x_MIN_INSTANCES       OUT NOCOPY JTF_NUMBER_TABLE -- 11
    ,x_MAX_INSTANCES       OUT NOCOPY JTF_NUMBER_TABLE -- 12
    ,x_Flex_value_set_id     OUT NOCOPY JTF_NUMBER_TABLE -- 13
    ,x_REFERENCE_CODE       OUT NOCOPY JTF_VARCHAR2_TABLE_100 -- 14
 ,x_DEFAULT_VALUE       OUT NOCOPY JTF_VARCHAR2_TABLE_300 -- 15
    ,x_UPDATEABLE_FLAG     OUT NOCOPY JTF_VARCHAR2_TABLE_100 -- 16 Varchar2(1)
    ,x_CREATED_BY        OUT NOCOPY JTF_NUMBER_TABLE -- 17
    ,x_CREATION_DATE       OUT NOCOPY JTF_DATE_TABLE -- 18
    ,x_LAST_UPDATED_BY     OUT NOCOPY JTF_NUMBER_TABLE --19
    ,x_LAST_UPDATE_DATE      OUT NOCOPY JTF_DATE_TABLE -- 20
    ,x_LAST_UPDATE_LOGIN      OUT NOCOPY JTF_NUMBER_TABLE --21
    ,x_OBJECT_VERSION_NUMBER    OUT NOCOPY JTF_NUMBER_TABLE --22
    ,x_return_status            OUT NOCOPY VARCHAR2 -- 23
    ,x_msg_count                OUT NOCOPY INTEGER --24
    ,x_msg_data                 OUT NOCOPY VARCHAR2 --25
	,p_language					IN   VARCHAR2	--26
)
IS

CURSOR Cur_Content_Type(l_language IN VARCHAR2) IS
SELECT content_type_name
    ,description
    ,content_type_status
FROM
  IBC_CONTENT_TYPES_TL T,
  IBC_CONTENT_TYPES_B B
WHERE
  B.CONTENT_TYPE_CODE = T.CONTENT_TYPE_CODE AND
    B.CONTENT_TYPE_CODE = p_content_type_Code AND
  T.LANGUAGE = l_language;


--

CURSOR Cur_Attributes(l_language IN VARCHAR2) IS
SELECT B.ATTRIBUTE_TYPE_CODE
    ,ATTRIBUTE_TYPE_name
    ,DESCRIPTION
    ,B.CONTENT_TYPE_CODE
    ,DATA_TYPE_CODE
    ,DATA_LENGTH
    ,MIN_INSTANCES
    ,MAX_INSTANCES
	,Flex_value_set_id
    ,REFERENCE_CODE
	,DEFAULT_VALUE
    ,UPDATEABLE_FLAG
    ,B.CREATED_BY
    ,B.CREATION_DATE
    ,B.LAST_UPDATED_BY
    ,B.LAST_UPDATE_DATE
    ,B.LAST_UPDATE_LOGIN
    ,B.OBJECT_VERSION_NUMBER
FROM IBC_ATTRIBUTE_TYPES_B B,IBC_ATTRIBUTE_TYPES_TL T
WHERE B.CONTENT_TYPE_CODE = p_Content_type_code
AND B.content_type_code = T.CONTENT_TYPE_CODE
AND B.ATTRIBUTE_TYPE_CODE = T.ATTRIBUTE_TYPE_CODE
AND LANGUAGE = l_language
ORDER BY DISPLAY_ORDER;

CURSOR CUR_LANG IS
SELECT '1' FROM FND_LANGUAGES
WHERE LANGUAGE_CODE = p_language;

l_api_name 				  VARCHAR2(50) := 'Get_Content_Type';
l_language				  VARCHAR2(4)  := p_language;
l_temp					  CHAR(1);

BEGIN

IF l_language IS NULL OR l_language = Fnd_Api.G_MISS_CHAR THEN
   l_language := USERENV('LANG');
ELSE
	OPEN CUR_LANG;
	FETCH CUR_LANG INTO l_temp;
	  IF CUR_LANG%NOTFOUND THEN
	      Fnd_Message.Set_name('IBC', 'IBC_INVALID_LANGUAGE_CODE');
          Fnd_Message.Set_Token('COLUMN', 'LANGUAGE', FALSE);
          Fnd_Msg_Pub.ADD;
          CLOSE CUR_LANG;
          RAISE Fnd_Api.G_EXC_ERROR;
      END IF;
END IF;



     -- Initialize API return status to SUCCESS
     x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

	  OPEN  Cur_Content_Type(l_language);
      FETCH Cur_Content_Type INTO 	x_content_type_name
	  		  			,x_content_type_description
						,x_content_type_status;
	  IF Cur_Content_Type%NOTFOUND THEN
	      Fnd_Message.Set_name('IBC', 'Invalid Content TYPE Code');
          Fnd_Message.Set_Token('COLUMN', 'Content_Type_Code', FALSE);
          Fnd_Msg_Pub.ADD;
          CLOSE Cur_Content_Type;
          RAISE Fnd_Api.G_EXC_ERROR;
      END IF;
      CLOSE Cur_Content_Type;


OPEN Cur_Attributes(l_language);

FETCH Cur_Attributes BULK COLLECT INTO X_ATTRIBUTE_TYPE_CODE
    ,x_ATTRIBUTE_TYPE_name
    ,x_DESCRIPTION
    ,x_CONTENT_TYPE_CODE
    ,x_DATA_TYPE_CODE
    ,x_DATA_LENGTH
    ,x_MIN_INSTANCES
    ,x_MAX_INSTANCES
	,x_Flex_value_set_id
    ,x_REFERENCE_CODE
	,x_DEFAULT_VALUE
    ,x_UPDATEABLE_FLAG
    ,x_CREATED_BY
    ,x_CREATION_DATE
    ,x_LAST_UPDATED_BY
    ,x_LAST_UPDATE_DATE
    ,x_LAST_UPDATE_LOGIN
    ,x_OBJECT_VERSION_NUMBER;

CLOSE Cur_Attributes;


-- IF x_return_status = 'S' THEN
-- 	dbms_output.put_line('================= OUT PUT ======================');
-- 	FOR i IN x_attribute_type_code.first..x_attribute_type_code.last LOOP
-- 	dbms_output.put_line('x_attribute_type_code('||i||') =>' ||x_attribute_type_code(i));
-- 	dbms_output.put_line('x_ATTRIBUTE_TYPE_name ('||i||') =>'||x_ATTRIBUTE_TYPE_name (i));
-- 	dbms_output.put_line('x_DESCRIPTION  		('||i||') =>' ||x_DESCRIPTION (i));
-- 	dbms_output.put_line('x_CONTENT_TYPE_CODE 	('||i||') =>' ||x_CONTENT_TYPE_CODE(i));
-- 	dbms_output.put_line('x_DATA_TYPE_CODE 		('||i||') =>' ||x_DATA_TYPE_CODE(i));
-- 	dbms_output.put_line('===================END =============================');
-- 	END LOOP;
-- END IF;

      -- Standard call to get message count and if count is 1, get message info.
      Fnd_Msg_Pub.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );


EXCEPTION
	  WHEN Fnd_Api.G_EXC_ERROR THEN
    	  ROLLBACK;
	      Ibc_Utilities_Pvt.HANDLE_EXCEPTIONS(
		   P_API_name => L_API_name
		  ,P_PKG_name => G_PKG_name
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
		   P_API_name => L_API_name
		  ,P_PKG_name => G_PKG_name
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
		   P_API_name => L_API_name
		  ,P_PKG_name => G_PKG_name
		  ,P_EXCEPTION_LEVEL => Ibc_Utilities_Pvt.G_EXC_OTHERS
		  ,P_PACKAGE_TYPE => Ibc_Utilities_Pvt.G_PVT
		  ,P_SQLCODE => SQLCODE
		  ,P_SQLERRM => SQLERRM
		  ,X_MSG_COUNT => X_MSG_COUNT
		  ,X_MSG_DATA => X_MSG_DATA
		  ,X_RETURN_STATUS => X_RETURN_STATUS);

END get_Content_Type;


FUNCTION  Query_Attribute_type_Row (
              p_attribute_type_code  IN   VARCHAR2,
              p_content_type_code   IN   VARCHAR2
) RETURN  Ibc_Ctype_Pvt.Attribute_Type_Rec_Type

IS
l_Attribute_Type_Rec  Ibc_Ctype_Pvt.Attribute_Type_Rec_Type;
BEGIN
   SELECT
   ATTRIBUTE_TYPE_CODE,
   ATTRIBUTE_TYPE_name,
   CONTENT_TYPE_CODE,
   CREATED_BY,
   CREATION_DATE,
   DATA_LENGTH,
   DATA_TYPE_CODE,
   DEFAULT_VALUE,
   DESCRIPTION,
   LAST_UPDATED_BY,
   LAST_UPDATE_DATE,
   LAST_UPDATE_LOGIN,
   MAX_INSTANCES,
   MIN_INSTANCES,
   OBJECT_VERSION_NUMBER,
   REFERENCE_CODE,
   UPDATEABLE_FLAG
   INTO
   l_Attribute_Type_Rec.ATTRIBUTE_TYPE_CODE,
   l_Attribute_Type_Rec.ATTRIBUTE_TYPE_name,
   l_Attribute_Type_Rec.CONTENT_TYPE_CODE,
   l_Attribute_Type_Rec.CREATED_BY,
   l_Attribute_Type_Rec.CREATION_DATE,
   l_Attribute_Type_Rec.DATA_LENGTH,
   l_Attribute_Type_Rec.DATA_TYPE_CODE,
   l_Attribute_Type_Rec.DEFAULT_VALUE,
   l_Attribute_Type_Rec.DESCRIPTION,
   l_Attribute_Type_Rec.LAST_UPDATED_BY,
   l_Attribute_Type_Rec.LAST_UPDATE_DATE,
   l_Attribute_Type_Rec.LAST_UPDATE_LOGIN,
   l_Attribute_Type_Rec.MAX_INSTANCES,
   l_Attribute_Type_Rec.MIN_INSTANCES,
   l_Attribute_Type_Rec.OBJECT_VERSION_NUMBER,
   l_Attribute_Type_Rec.REFERENCE_CODE,
   l_Attribute_Type_Rec.UPDATEABLE_FLAG
   FROM IBC_ATTRIBUTE_TYPES_VL
   WHERE   attribute_type_code = p_attribute_type_code
   AND     content_type_code = p_content_type_code;

RETURN l_attribute_type_rec;

END Query_Attribute_Type_Row;

FUNCTION  get_ctype_rec RETURN  Ibc_Ctype_Pvt.content_type_rec_type
IS
    TMP_REC  Ibc_Ctype_Pvt.content_type_rec_type;
BEGIN
    RETURN   TMP_REC;
END get_ctype_rec;






PROCEDURE Is_Valid_Flex_Value(
	P_Api_Version_Number		IN     NUMBER
	,P_Init_Msg_List		IN     VARCHAR2
	,p_flex_value_set_id		IN     NUMBER
	,p_flex_value_code		IN     VARCHAR2
	,x_exists			OUT  NOCOPY VARCHAR2
	,X_Return_Status		OUT  NOCOPY VARCHAR2
	,X_Msg_Count			OUT  NOCOPY  NUMBER
	,X_Msg_Data			OUT  NOCOPY  VARCHAR2
) IS

CURSOR C_FlexValueSet IS
SELECT flex_value_set_id,validation_type
FROM fnd_flex_value_sets
WHERE flex_value_set_id = p_flex_value_set_id;

l_value_set_id    NUMBER;
lx_select        VARCHAR2(32000);
lx_success        VARCHAR2(10);
lx_mapping_code   VARCHAR2(32000);
l_vset_type    VARCHAR2(1);
l_api_name     VARCHAR2(30) := 'IS_VALID_FLEX_VALUE';

l_code		   JTF_VARCHAR2_TABLE_300 := JTF_VARCHAR2_TABLE_300();
l_name		   JTF_VARCHAR2_TABLE_300 := JTF_VARCHAR2_TABLE_300();
l_description  JTF_VARCHAR2_TABLE_3000 := JTF_VARCHAR2_TABLE_3000();
l_temp		   CHAR(1);

l_meaning	   VARCHAR2(240);
l_id		   VARCHAR2(240);

CURSOR C_Flex_Value_Code IS
SELECT '1'
FROM TABLE(CAST(l_code AS JTF_VARCHAR2_TABLE_300)) A
WHERE A.COLUMN_VALUE = p_flex_value_code;

CURSOR C_flex_validation_tab IS
SELECT id_column_name,meaning_column_name
FROM fnd_flex_validation_tables
WHERE flex_value_set_id=p_flex_value_set_id;

BEGIN

x_exists := Fnd_Api.G_TRUE;
x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

OPEN C_FlexValueSet;
FETCH C_FlexValueSet INTO l_value_set_id,l_vset_type;
    IF C_FlexValueSet%NOTFOUND THEN
	Fnd_Message.Set_name('IBC', 'BAD_INPUT_VALUE');
        Fnd_Message.Set_Token('INPUT',p_flex_value_set_id, FALSE);
        Fnd_Msg_Pub.ADD;
        CLOSE C_FlexValueSet;
		x_exists := Fnd_Api.G_FALSE;
        RAISE Fnd_Api.G_EXC_ERROR;
   END IF;
CLOSE C_FlexValueSet;

-- dbms_output.put_line(l_value_set_id);
-- dbms_output.put_line(l_vset_type);

IF  l_vset_type = 'F' THEN
   Fnd_Flex_Val_Api.get_table_vset_select
    (p_value_set_id       => l_value_set_id,
      x_select         =>lx_select,
      x_mapping_code      =>lx_mapping_code,
      x_success     =>lx_success);


--   dbms_output.put_line(lx_success);
    OPEN C_flex_validation_tab;
    FETCH C_flex_validation_tab INTO l_meaning,l_id;
    CLOSE C_flex_validation_tab;

    IF l_meaning IS NOT NULL AND l_id IS NOT NULL  THEN
    lx_select := REPLACE(UPPER(lx_select),'FROM','BULK COLLECT INTO :tab1,:tab2,:tab3  FROM  ');
    EXECUTE IMMEDIATE 'BEGIN ' || lx_select || ';  END;'
       USING OUT l_code,OUT l_name,OUT l_description;
    ELSIF l_meaning IS NULL AND l_id IS NULL THEN
    lx_select := REPLACE(UPPER(lx_select),'FROM','BULK COLLECT INTO :tab1 FROM  ');
    EXECUTE IMMEDIATE 'BEGIN ' || lx_select || ';  END;'
       USING OUT l_code;
    ELSE
    lx_select := REPLACE(UPPER(lx_select),'FROM','BULK COLLECT INTO :tab1,:tab2  FROM  ');
    EXECUTE IMMEDIATE 'BEGIN ' || lx_select || ';  END;'
       USING OUT l_code,OUT l_description;
    END IF;

ELSIF l_vset_type = 'I' THEN
   Fnd_Flex_Val_Api.get_independent_vset_select
   (p_value_set_id     => l_value_set_id,
      x_select     =>lx_select,
      x_mapping_code  =>lx_mapping_code,
      x_success   =>lx_success);
    lx_select := REPLACE(UPPER(lx_select),'FROM','BULK COLLECT INTO :tab1,:tab2,:tab3  FROM  ');
    EXECUTE IMMEDIATE 'BEGIN ' || lx_select || ';  END;'
       USING OUT l_code,OUT l_name,OUT l_description;
ELSE
	x_exists := Fnd_Api.G_FALSE;
    RETURN;
END IF;

OPEN C_Flex_Value_Code;
FETCH C_Flex_Value_Code INTO l_temp;

    IF C_Flex_Value_Code%NOTFOUND THEN
      x_exists := Fnd_Api.G_FALSE;
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
     P_API_name => L_API_name
    ,P_PKG_name => G_PKG_name
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
     P_API_name => L_API_name
    ,P_PKG_name => G_PKG_name
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
     P_API_name => L_API_name
    ,P_PKG_name => G_PKG_name
    ,P_EXCEPTION_LEVEL => Ibc_Utilities_Pvt.G_EXC_OTHERS
    ,P_PACKAGE_TYPE => Ibc_Utilities_Pvt.G_PVT
    ,P_SQLCODE => SQLCODE
    ,P_SQLERRM => SQLERRM
    ,X_MSG_COUNT => X_MSG_COUNT
    ,X_MSG_DATA => X_MSG_DATA
    ,X_RETURN_STATUS => X_RETURN_STATUS);
END Is_Valid_Flex_Value;


PROCEDURE get_sql_from_flex(
   P_Api_Version_Number         IN    NUMBER
  ,P_Init_Msg_List              IN    VARCHAR2     --:= FND_API.G_FALSE
  ,p_flex_value_set_id     	IN    NUMBER --1
  ,x_select        		OUT  NOCOPY VARCHAR2 --4
  ,X_Return_Status              OUT NOCOPY  VARCHAR2 --6
  ,X_Msg_Count                  OUT NOCOPY  NUMBER -- 7
  ,X_Msg_Data                   OUT NOCOPY  VARCHAR2 -- 8
  ) IS

CURSOR C_flex IS
SELECT flex_value_set_id,validation_type
FROM  fnd_flex_value_sets F
WHERE F.flex_value_set_id = p_flex_value_set_id;

l_value_set_id		NUMBER;
lx_select		VARCHAR2(32000);
lx_success		VARCHAR2(10);
lx_mapping_code		VARCHAR2(32000);
l_vset_type		VARCHAR2(1);
l_api_name		VARCHAR2(30) := 'GET_SQL_FROM_FLEX';

BEGIN

x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

OPEN C_flex;
FETCH C_flex INTO l_value_set_id,l_vset_type;

IF C_flex%NOTFOUND THEN
	CLOSE C_flex;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
        FND_MESSAGE.Set_Token('INPUT', 'FLEX_VALUE_SET_ID', FALSE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
END IF;


CLOSE C_flex;

-- dbms_output.put_line(l_value_set_id);
-- dbms_output.put_line(l_vset_type);

IF  l_vset_type = 'F' THEN
   Fnd_Flex_Val_Api.get_table_vset_select
    (p_value_set_id     => l_value_set_id,
      x_select		=>lx_select,
      x_mapping_code    =>lx_mapping_code,
      x_success		=>lx_success);
--   dbms_output.put_line(lx_success);
ELSIF l_vset_type = 'I' THEN
   Fnd_Flex_Val_Api.get_independent_vset_select
   (p_value_set_id	=> l_value_set_id,
      x_select		=>lx_select,
      x_mapping_code	=>lx_mapping_code,
      x_success		=>lx_success);
--  dbms_output.put_line(lx_success);
ELSE
	x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name('IBC', 'IBC_INVALID_FLEX_VALUE_SET');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
END IF;


x_select := lx_select;


-- dbms_output.put_line(SUBSTR(x_select,1,240));
-- dbms_output.put_line(SUBSTR(x_select,241,480));


      -- Standard call to get message count and if count is 1, get message info.
      Fnd_Msg_Pub.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );


EXCEPTION
   WHEN Fnd_Api.G_EXC_ERROR THEN
       ROLLBACK;
       Ibc_Utilities_Pvt.HANDLE_EXCEPTIONS(
     P_API_name => L_API_name
    ,P_PKG_name => G_PKG_name
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
     P_API_name => L_API_name
    ,P_PKG_name => G_PKG_name
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
     P_API_name => L_API_name
    ,P_PKG_name => G_PKG_name
    ,P_EXCEPTION_LEVEL => Ibc_Utilities_Pvt.G_EXC_OTHERS
    ,P_PACKAGE_TYPE => Ibc_Utilities_Pvt.G_PVT
    ,P_SQLCODE => SQLCODE
    ,P_SQLERRM => SQLERRM
    ,X_MSG_COUNT => X_MSG_COUNT
    ,X_MSG_DATA => X_MSG_DATA
    ,X_RETURN_STATUS => X_RETURN_STATUS);

END get_sql_from_flex;



END Ibc_Ctype_Pvt;

/
