--------------------------------------------------------
--  DDL for Package Body CSM_SR_ATTRIBUTES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_SR_ATTRIBUTES_PKG" AS
/* $Header: csmusrab.pls 120.0.12010000.3 2010/05/21 10:58:52 trajasek noship $ */
error EXCEPTION;

PROCEDURE APPLY_SR_LINK_INSERT
          (p_HA_PAYLOAD_ID  IN  NUMBER,
           p_COL_NAME_LIST  IN  CSM_VARCHAR_LIST,
           p_COL_VALUE_LIST IN  CSM_VARCHAR_LIST,
           x_RETURN_STATUS  OUT NOCOPY VARCHAR2,
           X_Error_Message  Out Nocopy Varchar2
         )
AS
 --Variable Declarations
   L_Api_Version    Number := 2.0;
   L_Init_Msg_List  Varchar2(100);
   L_User_Id        Number;
   L_Login_Id       Number;
   L_Link_Rec       Cs_Incidentlinks_Pub.Cs_Incident_Link_Rec_Type;
   L_Object_Version_Number  Number;
   L_Reciprocal_Link_Id     Number;
   L_LINK_ID			          NUMBER ;
   l_return_status       VARCHAR2(1);
   l_msg_count           NUMBER;
   l_msg_data            VARCHAR2(2000);


BEGIN
  X_Return_Status := Fnd_Api.G_Ret_Sts_Success;
  CSM_UTIL_PKG.LOG('Entering CSM_SR_ATTRIBUTES_PKG.APPLY_SR_LINK_INSERT for HA ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_SR_ATTRIBUTES_PKG.APPLY_SR_LINK_INSERT',FND_LOG.LEVEL_PROCEDURE);


   -- prepare the SR link for the given SR link

  FOR i in 1..p_COL_NAME_LIST.COUNT-1 LOOP

    IF  p_COL_VALUE_LIST(i) IS NOT NULL THEN

      If p_Col_Name_List(I) = 'LINK_ID' Then
        L_Link_Rec.LINK_ID := p_COL_VALUE_LIST(i);
      ELSIF  p_COL_NAME_LIST(i) = 'SUBJECT_ID' THEN
        L_Link_Rec.SUBJECT_ID := p_COL_VALUE_LIST(i);
      ELSIF  p_COL_NAME_LIST(i) = 'SUBJECT_TYPE' THEN
        L_Link_Rec.SUBJECT_TYPE := p_COL_VALUE_LIST(i);
      ELSIF  p_COL_NAME_LIST(i) = 'OBJECT_ID' THEN
        L_Link_Rec.OBJECT_ID := p_COL_VALUE_LIST(i);
      ELSIF  p_COL_NAME_LIST(i) = 'OBJECT_NUMBER' THEN
        L_Link_Rec.OBJECT_NUMBER := p_COL_VALUE_LIST(i);
      ELSIF  p_COL_NAME_LIST(i) = 'OBJECT_TYPE' THEN
        L_Link_Rec.OBJECT_TYPE := p_Col_Value_List(I);
      ELSIF  p_COL_NAME_LIST(i) = 'LINK_TYPE_ID' THEN
        L_Link_Rec.LINK_TYPE_ID := p_COL_VALUE_LIST(i);
      ELSIF  p_COL_NAME_LIST(i) = 'LINK_TYPE' THEN
        L_Link_Rec.LINK_TYPE := p_Col_Value_List(I);
      ELSIF  p_COL_NAME_LIST(i) = 'REQUEST_ID' THEN
        L_Link_Rec.REQUEST_ID := p_COL_VALUE_LIST(i);
      ELSIF  p_COL_NAME_LIST(i) = 'PROGRAM_APPLICATION_ID' THEN
        L_Link_Rec.PROGRAM_APPLICATION_ID := p_Col_Value_List(I);
      ELSIF  p_COL_NAME_LIST(i) = 'PROGRAM_ID' THEN
        L_Link_Rec.PROGRAM_ID := p_Col_Value_List(I);
      ELSIF  p_COL_NAME_LIST(i) = 'PROGRAM_UPDATE_DATE' THEN
        L_Link_Rec.PROGRAM_UPDATE_DATE := p_Col_Value_List(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE1' Then
        L_Link_Rec.LINK_SEGMENT1 := p_Col_Value_List(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE2' Then
        L_Link_Rec.LINK_SEGMENT2 := p_Col_Value_List(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE3' Then
        L_Link_Rec.LINK_SEGMENT3 := p_Col_Value_List(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE4' Then
        L_Link_Rec.Link_Segment4 := p_Col_Value_List(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE5' Then
        L_Link_Rec.LINK_SEGMENT5 := p_Col_Value_List(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE6' Then
        L_Link_Rec.LINK_SEGMENT6 := p_Col_Value_List(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE7' Then
        L_Link_Rec.LINK_SEGMENT7 := p_Col_Value_List(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE8' Then
        L_Link_Rec.LINK_SEGMENT8 := p_Col_Value_List(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE9' Then
        L_Link_Rec.Link_Segment9 := p_Col_Value_List(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE10' Then
        L_Link_Rec.LINK_SEGMENT10 := p_Col_Value_List(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE11' Then
        L_Link_Rec.Link_Segment11 := p_Col_Value_List(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE12' Then
        L_Link_Rec.LINK_SEGMENT12 := p_Col_Value_List(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE13' Then
        L_Link_Rec.Link_Segment13 := p_Col_Value_List(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE14' Then
        L_Link_Rec.Link_Segment14 := p_Col_Value_List(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE15' Then
        L_Link_Rec.LINK_SEGMENT15 := p_Col_Value_List(I);
      ELSIF  P_COL_NAME_LIST(I) = 'CONTEXT' THEN
        L_LINK_REC.LINK_CONTEXT := P_COL_VALUE_LIST(I);

      END IF;
    End If;
  END LOOP;

  --Call the SR link Api
      Cs_Incidentlinks_Pub.Create_Incidentlink (
        P_Api_Version		=> L_Api_Version,
        P_Init_Msg_List => L_Init_Msg_List,
        P_Commit     		=> NULL,
        P_Resp_Appl_Id	=> Null, -- not used
        P_Resp_Id			  => Null, -- not used
        P_USER_ID			  => FND_GLOBAL.USER_ID,
        P_Login_Id		  => NULL,
        P_Org_Id			  => Null, -- not used
        P_Link_Rec      => L_Link_Rec,
        X_Return_Status	=> l_return_status,
        X_Msg_Count		  => l_msg_count,
        X_Msg_Data		  => l_msg_data,
        X_Object_Version_Number => L_Object_Version_Number, -- new for 1159
        X_Reciprocal_Link_Id    => L_Reciprocal_Link_Id, -- new for 1159
        X_Link_Id			=>  L_LINK_ID);

  IF l_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
    X_Return_Status := Fnd_Api.G_Ret_Sts_Error;
    X_Error_Message := l_Msg_Data;
  ELSE
    X_Return_Status := Fnd_Api.G_Ret_Sts_Success;
  END IF;
  CSM_UTIL_PKG.LOG('Leaving CSM_SR_ATTRIBUTES_PKG.APPLY_SR_LINK_INSERT for HA ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_SR_ATTRIBUTES_PKG.APPLY_SR_LINK_INSERT',Fnd_Log.Level_Procedure);

EXCEPTION
  WHEN OTHERS THEN
    X_Return_Status := Fnd_Api.G_Ret_Sts_Error;
    X_Error_Message := L_Msg_Data;
   CSM_UTIL_PKG.LOG('Leaving CSM_SR_ATTRIBUTES_PKG.APPLY_SR_LINK_INSERT for HA ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_SR_ATTRIBUTES_PKG.APPLY_SR_LINK_INSERT',FND_LOG.LEVEL_PROCEDURE);

END APPLY_SR_LINK_INSERT;

---sr link update

PROCEDURE APPLY_SR_LINK_UPDATE
          (p_HA_PAYLOAD_ID  IN  NUMBER,
           p_COL_NAME_LIST  IN  CSM_VARCHAR_LIST,
           p_COL_VALUE_LIST IN  CSM_VARCHAR_LIST,
           x_RETURN_STATUS  OUT NOCOPY VARCHAR2,
           X_Error_Message  Out Nocopy Varchar2
         )
AS
 --Variable Declarations
   L_Api_Version    Number := 2.0;
   L_Init_Msg_List  Varchar2(100);
   L_User_Id        Number;
   L_Login_Id       Number;
   L_Link_Rec       Cs_Incidentlinks_Pub.Cs_Incident_Link_Rec_Type;
   L_Object_Version_Number  Number;
   L_Reciprocal_Link_Id     Number;
   L_LINK_ID			          NUMBER ;
   l_return_status       VARCHAR2(1);
   l_msg_count           NUMBER;
   l_msg_data            VARCHAR2(2000);

CURSOR C_GET_LINK_VERSION( B_LINK_ID NUMBER)
IS
   SELECT OBJECT_VERSION_NUMBER
   FROM   CS_INCIDENT_LINKS
   WHERE  LINK_ID = B_LINK_ID;


BEGIN
  X_Return_Status := Fnd_Api.G_Ret_Sts_Success;
  CSM_UTIL_PKG.LOG('Entering CSM_SR_ATTRIBUTES_PKG.APPLY_SR_LINK_UPDATE for HA ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_SR_ATTRIBUTES_PKG.APPLY_SR_LINK_UPDATE',FND_LOG.LEVEL_PROCEDURE);


   -- prepare the SR link for the given SR link

  FOR i in 1..p_COL_NAME_LIST.COUNT-1 LOOP

    IF  p_COL_VALUE_LIST(i) IS NOT NULL THEN

      If p_Col_Name_List(I) = 'LINK_ID' Then
        L_LINK_REC.LINK_ID := P_COL_VALUE_LIST(I);
        L_LINK_ID          := P_COL_VALUE_LIST(I);
      ELSIF  p_COL_NAME_LIST(i) = 'SUBJECT_ID' THEN
        L_Link_Rec.SUBJECT_ID := p_COL_VALUE_LIST(i);
      ELSIF  p_COL_NAME_LIST(i) = 'SUBJECT_TYPE' THEN
        L_Link_Rec.SUBJECT_TYPE := p_COL_VALUE_LIST(i);
      ELSIF  p_COL_NAME_LIST(i) = 'OBJECT_ID' THEN
        L_Link_Rec.OBJECT_ID := p_COL_VALUE_LIST(i);
      ELSIF  p_COL_NAME_LIST(i) = 'OBJECT_NUMBER' THEN
        L_Link_Rec.OBJECT_NUMBER := p_COL_VALUE_LIST(i);
      ELSIF  p_COL_NAME_LIST(i) = 'OBJECT_TYPE' THEN
        L_Link_Rec.OBJECT_TYPE := p_Col_Value_List(I);
      ELSIF  p_COL_NAME_LIST(i) = 'LINK_TYPE_ID' THEN
        L_Link_Rec.LINK_TYPE_ID := p_COL_VALUE_LIST(i);
      ELSIF  p_COL_NAME_LIST(i) = 'LINK_TYPE' THEN
        L_Link_Rec.LINK_TYPE := p_Col_Value_List(I);
      ELSIF  p_COL_NAME_LIST(i) = 'REQUEST_ID' THEN
        L_Link_Rec.REQUEST_ID := p_COL_VALUE_LIST(i);
      ELSIF  p_COL_NAME_LIST(i) = 'PROGRAM_APPLICATION_ID' THEN
        L_Link_Rec.PROGRAM_APPLICATION_ID := p_Col_Value_List(I);
      ELSIF  p_COL_NAME_LIST(i) = 'PROGRAM_ID' THEN
        L_Link_Rec.PROGRAM_ID := p_Col_Value_List(I);
      ELSIF  p_COL_NAME_LIST(i) = 'PROGRAM_UPDATE_DATE' THEN
        L_Link_Rec.PROGRAM_UPDATE_DATE := p_Col_Value_List(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE1' Then
        L_Link_Rec.LINK_SEGMENT1 := p_Col_Value_List(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE2' Then
        L_Link_Rec.LINK_SEGMENT2 := p_Col_Value_List(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE3' Then
        L_Link_Rec.LINK_SEGMENT3 := p_Col_Value_List(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE4' Then
        L_Link_Rec.Link_Segment4 := p_Col_Value_List(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE5' Then
        L_Link_Rec.LINK_SEGMENT5 := p_Col_Value_List(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE6' Then
        L_Link_Rec.LINK_SEGMENT6 := p_Col_Value_List(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE7' Then
        L_Link_Rec.LINK_SEGMENT7 := p_Col_Value_List(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE8' Then
        L_Link_Rec.LINK_SEGMENT8 := p_Col_Value_List(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE9' Then
        L_Link_Rec.Link_Segment9 := p_Col_Value_List(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE10' Then
        L_Link_Rec.LINK_SEGMENT10 := p_Col_Value_List(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE11' Then
        L_Link_Rec.Link_Segment11 := p_Col_Value_List(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE12' Then
        L_Link_Rec.LINK_SEGMENT12 := p_Col_Value_List(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE13' Then
        L_Link_Rec.Link_Segment13 := p_Col_Value_List(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE14' Then
        L_Link_Rec.Link_Segment14 := p_Col_Value_List(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE15' Then
        L_Link_Rec.LINK_SEGMENT15 := p_Col_Value_List(I);
      Elsif  p_Col_Name_List(I) = 'CONTEXT' Then
        L_Link_Rec.Link_Context := p_Col_Value_List(I);
      ELSIF  P_COL_NAME_LIST(I) = 'OBJECT_VERSION_NUMBER' THEN
        L_Object_Version_Number := p_Col_Value_List(I);
      END IF;
    End If;
  END LOOP;

    --Get the Latest Version number from the DB
  OPEN  C_GET_LINK_VERSION( L_LINK_ID );
  FETCH C_GET_LINK_VERSION INTO L_OBJECT_VERSION_NUMBER;
  CLOSE C_GET_LINK_VERSION;

  --Call the SR link Api
      Cs_Incidentlinks_Pub.UPDATE_INCIDENTLINK (
        P_Api_Version		=> L_Api_Version,
        P_Init_Msg_List => L_Init_Msg_List,
        P_Commit     		=> NULL,
        P_Resp_Appl_Id	=> Null, -- not used
        P_Resp_Id			  => Null, -- not used
        P_User_Id			  => Fnd_Global.User_Id,
        P_Login_Id		  => NULL,
        P_ORG_ID			  => NULL, -- not used
        P_LINK_ID      => L_LINK_ID,
        P_LINK_REC      => L_LINK_REC,
        P_OBJECT_VERSION_NUMBER => L_OBJECT_VERSION_NUMBER,
        X_Return_Status	=> l_return_status,
        X_Msg_Count		  => l_msg_count,
        X_Msg_Data		  => l_msg_data,
        X_Object_Version_Number => L_Object_Version_Number -- new for 1159
        );

  IF l_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
    X_Return_Status := Fnd_Api.G_Ret_Sts_Error;
    X_Error_Message := l_Msg_Data;
  ELSE
    X_Return_Status := Fnd_Api.G_Ret_Sts_Success;
  END IF;
  CSM_UTIL_PKG.LOG('Leaving CSM_SR_ATTRIBUTES_PKG.APPLY_SR_LINK_UPDATE for HA ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_SR_ATTRIBUTES_PKG.APPLY_SR_LINK_UPDATE',Fnd_Log.Level_Procedure);

EXCEPTION
  WHEN OTHERS THEN
    X_Return_Status := Fnd_Api.G_Ret_Sts_Error;
    X_Error_Message := L_Msg_Data;
   CSM_UTIL_PKG.LOG('Leaving CSM_SR_ATTRIBUTES_PKG.APPLY_SR_LINK_UPDATE for HA ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_SR_ATTRIBUTES_PKG.APPLY_SR_LINK_UPDATE',FND_LOG.LEVEL_PROCEDURE);

END APPLY_SR_LINK_UPDATE;
--sr link update ends
--sr link delete starts
PROCEDURE APPLY_SR_LINK_DELETE
          (p_HA_PAYLOAD_ID  IN  NUMBER,
           p_COL_NAME_LIST  IN  CSM_VARCHAR_LIST,
           p_COL_VALUE_LIST IN  CSM_VARCHAR_LIST,
           x_RETURN_STATUS  OUT NOCOPY VARCHAR2,
           X_Error_Message  Out Nocopy Varchar2
         )
AS
 --Variable Declarations
   L_Api_Version    Number := 2.0;
   L_Init_Msg_List  Varchar2(100);
   L_User_Id        Number;
   L_Login_Id       Number;
   L_LINK_ID			          NUMBER ;
   l_return_status       VARCHAR2(1);
   l_msg_count           NUMBER;
   l_msg_data            VARCHAR2(2000);


BEGIN
  X_Return_Status := Fnd_Api.G_Ret_Sts_Success;
  CSM_UTIL_PKG.LOG('Entering CSM_SR_ATTRIBUTES_PKG.APPLY_SR_LINK_DELETE for HA ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_SR_ATTRIBUTES_PKG.APPLY_SR_LINK_DELETE',FND_LOG.LEVEL_PROCEDURE);


   -- prepare the SR link for the given SR link
  L_API_VERSION := 2.0;
  FOR i in 1..p_COL_NAME_LIST.COUNT-1 LOOP

    IF  p_COL_VALUE_LIST(i) IS NOT NULL THEN

      If p_Col_Name_List(I) = 'LINK_ID' Then
       L_LINK_ID          := P_COL_VALUE_LIST(I);
       EXIT;
      END IF;
    End If;
  END LOOP;

  --Call the SR link Api
      Cs_Incidentlinks_Pub.DELETE_INCIDENTLINK (
        P_Api_Version		=> L_Api_Version,
        P_Init_Msg_List => FND_API.G_FALSE,
        P_Commit     		=> FND_API.G_FALSE,
        P_Resp_Appl_Id	=> Null, -- not used
        P_Resp_Id			  => Null, -- not used
        P_User_Id			  => Fnd_Global.User_Id,
        P_Login_Id		  => NULL,
        P_ORG_ID			  => NULL, -- not used
        P_LINK_ID      => L_LINK_ID,
        X_Return_Status	=> l_return_status,
        X_Msg_Count		  => l_msg_count,
        X_Msg_Data		  => l_msg_data
        );

  IF l_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
    X_Return_Status := Fnd_Api.G_Ret_Sts_Error;
    X_Error_Message := l_Msg_Data;
  ELSE
    X_Return_Status := Fnd_Api.G_Ret_Sts_Success;
  END IF;
  CSM_UTIL_PKG.LOG('Leaving CSM_SR_ATTRIBUTES_PKG.APPLY_SR_LINK_DELETE for HA ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_SR_ATTRIBUTES_PKG.APPLY_SR_LINK_DELETE',Fnd_Log.Level_Procedure);

EXCEPTION
  WHEN OTHERS THEN
    X_Return_Status := Fnd_Api.G_Ret_Sts_Error;
    X_Error_Message := L_Msg_Data;
   CSM_UTIL_PKG.LOG('Leaving CSM_SR_ATTRIBUTES_PKG.APPLY_SR_LINK_DELETE for HA ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_SR_ATTRIBUTES_PKG.APPLY_SR_LINK_DELETE',FND_LOG.LEVEL_PROCEDURE);

END APPLY_SR_LINK_DELETE;
--sr link delete ends
--SR Attributes insert
PROCEDURE APPLY_SR_ATTR_INSERT
          (p_HA_PAYLOAD_ID  IN  NUMBER,
           p_Col_Name_List  In  Csm_Varchar_List,
           p_COL_VALUE_LIST IN  CSM_VARCHAR_LIST,
           x_RETURN_STATUS  OUT NOCOPY VARCHAR2,
           X_Error_Message  Out Nocopy Varchar2
         )
AS
 --Variable Declarations
  L_Rowid  Varchar2(150);
  L_Incidnt_Attr_Val_Id  Number;
  L_Object_Version_Number  Number;
  L_Incident_Id  Number;
  L_Sr_Attribute_Code  Varchar2(30);
  L_Override_Addr_Valid_Flag  Varchar2(1);
  L_Attribute1  Varchar2(150);
  L_Attribute2  Varchar2(150);
  L_Attribute3  Varchar2(150);
  L_Attribute4  Varchar2(150);
  L_Attribute5  Varchar2(150);
  L_ATTRIBUTE6  VARCHAR2(150);
  L_Attribute7  Varchar2(150);
  L_Attribute8  Varchar2(150);
  L_Attribute9  Varchar2(150);
  L_ATTRIBUTE10  VARCHAR2(150);
  L_Attribute11  Varchar2(150);
  L_Attribute12  Varchar2(150);
  L_Attribute13  Varchar2(150);
  L_ATTRIBUTE14  VARCHAR2(150);
  L_Attribute15  Varchar2(150);
  L_Attribute_Category  Varchar2(30);
  L_SR_ATTRIBUTE_VALUE  VARCHAR2(150);
  L_CREATION_DATE  DATE;
  L_CREATED_BY  NUMBER;
  L_LAST_UPDATE_DATE  DATE;
  L_Last_Updated_By  Number;
  L_Last_Update_Login  Number;
  l_return_status       VARCHAR2(1);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);

BEGIN
  l_return_status := Fnd_Api.G_Ret_Sts_Success;
  CSM_UTIL_PKG.LOG('Entering CSM_SR_ATTRIBUTES_PKG.APPLY_SR_ATTR_INSERT for HA ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_SR_ATTRIBUTES_PKG.APPLY_SR_ATTR_INSERT',FND_LOG.LEVEL_PROCEDURE);


   -- prepare the SR link for the given SR link

  FOR i in 1..p_COL_NAME_LIST.COUNT-1 LOOP

    IF  p_COL_VALUE_LIST(i) IS NOT NULL THEN

      If p_Col_Name_List(I) = 'INCIDNT_ATTR_VAL_ID' Then
        L_Incidnt_Attr_Val_Id := P_COL_NAME_LIST(i);
      ELSIF  p_COL_NAME_LIST(i) = 'OBJECT_VERSION_NUMBER' THEN
        L_OBJECT_VERSION_NUMBER := P_COL_NAME_LIST(I);
      ELSIF  p_COL_NAME_LIST(i) = 'INCIDENT_ID' THEN
        L_Incident_Id := P_COL_NAME_LIST(i);
      ELSIF  p_COL_NAME_LIST(i) = 'SR_ATTRIBUTE_CODE' THEN
        L_Sr_Attribute_Code := P_COL_NAME_LIST(i);
      ELSIF  p_COL_NAME_LIST(i) = 'OVERRIDE_ADDR_VALID_FLAG' THEN
        L_Override_Addr_Valid_Flag := P_COL_NAME_LIST(i);
      ELSIF  P_COL_NAME_LIST(i) = 'CREATION_DATE' THEN
        L_CREATION_DATE := P_COL_NAME_LIST(I);
      ELSIF  P_COL_NAME_LIST(i) = 'CREATED_BY' THEN
        L_CREATED_BY := P_COL_NAME_LIST(i);
      ELSIF  P_COL_NAME_LIST(i) = 'LAST_UPDATE_DATE' THEN
        L_LAST_UPDATE_DATE := P_COL_NAME_LIST(I);
      Elsif  P_COL_NAME_LIST(I) = 'LAST_UPDATED_BY' Then
         L_Last_Updated_By:= P_COL_NAME_LIST(i);
      ELSIF  P_COL_NAME_LIST(i) = 'LAST_UPDATE_LOGIN' THEN
        L_Last_Update_Login := P_COL_NAME_LIST(I);
      Elsif  P_COL_NAME_LIST(I) = 'ATTRIBUTE1' Then
        L_Attribute1 := P_COL_NAME_LIST(I);
      Elsif  P_COL_NAME_LIST(I) = 'ATTRIBUTE2' Then
        L_Attribute2 := P_COL_NAME_LIST(I);
      Elsif  P_COL_NAME_LIST(I) = 'ATTRIBUTE3' Then
        L_Attribute3 := P_COL_NAME_LIST(I);
      Elsif  P_COL_NAME_LIST(I) = 'ATTRIBUTE4' Then
        L_Attribute4 := P_COL_NAME_LIST(I);
      Elsif  P_COL_NAME_LIST(I) = 'ATTRIBUTE5' Then
        L_Attribute5 := P_COL_NAME_LIST(I);
      Elsif  P_COL_NAME_LIST(I) = 'ATTRIBUTE6' Then
        L_Attribute6 := P_COL_NAME_LIST(I);
      Elsif  P_COL_NAME_LIST(I) = 'ATTRIBUTE7' Then
        L_Attribute7 := P_COL_NAME_LIST(I);
      Elsif  P_COL_NAME_LIST(I) = 'ATTRIBUTE8' Then
        L_Attribute8 := P_COL_NAME_LIST(I);
      Elsif  P_COL_NAME_LIST(I) = 'ATTRIBUTE9' Then
        L_Attribute9 := P_COL_NAME_LIST(I);
      Elsif  P_COL_NAME_LIST(I) = 'ATTRIBUTE10' Then
        L_Attribute10 := P_COL_NAME_LIST(I);
      Elsif  P_COL_NAME_LIST(I) = 'ATTRIBUTE11' Then
        L_Attribute11 := P_COL_NAME_LIST(I);
      Elsif  P_COL_NAME_LIST(I) = 'ATTRIBUTE12' Then
        L_Attribute12 := P_COL_NAME_LIST(I);
      Elsif  P_COL_NAME_LIST(I) = 'ATTRIBUTE13' Then
        L_Attribute13 := P_COL_NAME_LIST(I);
      Elsif  P_COL_NAME_LIST(I) = 'ATTRIBUTE14' Then
        L_Attribute14 := P_COL_NAME_LIST(I);
      Elsif  P_COL_NAME_LIST(I) = 'ATTRIBUTE15' Then
        L_Attribute15 := P_COL_NAME_LIST(I);
      Elsif  P_COL_NAME_LIST(I) = 'ATTRIBUTE_CATEGORY' Then
        L_Attribute_Category := P_COL_NAME_LIST(I);
      END IF;
    End If;
  END LOOP;

  --Call the SR attribute Api
      Cug_Incidnt_Attr_Vals_Pkg.Insert_Row (
        X_Rowid => L_Rowid,
        X_Incidnt_Attr_Val_Id => L_Incidnt_Attr_Val_Id,
        X_Object_Version_Number => L_Object_Version_Number,
        X_Incident_Id => L_Incident_Id,
        X_Sr_Attribute_Code => L_Sr_Attribute_Code,
        X_Override_Addr_Valid_Flag => L_Override_Addr_Valid_Flag,
        X_Attribute1 => L_Attribute1,
        X_Attribute2 => L_Attribute2,
        X_Attribute3 => L_Attribute3,
        X_Attribute4 => L_Attribute4,
        X_Attribute5 => L_Attribute5,
        X_Attribute6 => L_Attribute6,
        X_Attribute7 => L_Attribute7,
        X_Attribute8 => L_Attribute8,
        X_Attribute9 => L_Attribute9,
        X_Attribute10 => L_Attribute10,
        X_Attribute11 => L_Attribute11,
        X_Attribute12 => L_Attribute12,
        X_Attribute13 => L_Attribute13,
        X_Attribute14 => L_Attribute14,
        X_Attribute15 => L_Attribute15,
        X_Attribute_Category => L_Attribute_Category,
        X_Sr_Attribute_Value => L_SR_ATTRIBUTE_VALUE,
        X_Creation_Date     => L_Creation_Date,
        X_Created_By        => L_Last_Updated_By,
        X_Last_Update_Date  => L_Last_Update_Date,
        X_Last_Updated_By   => L_Last_Updated_By,
        X_Last_Update_Login => L_Last_Update_Login
      ) ;

  IF l_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
    X_Return_Status := Fnd_Api.G_Ret_Sts_Error;
    X_Error_Message := l_Msg_Data;
  ELSE
    X_Return_Status := Fnd_Api.G_Ret_Sts_Success;
  END IF;
  CSM_UTIL_PKG.LOG('Leaving CSM_SR_ATTRIBUTES_PKG.APPLY_SR_ATTR_INSERT for HA ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_SR_ATTRIBUTES_PKG.APPLY_SR_ATTR_INSERT',Fnd_Log.Level_Procedure);

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_Ret_Sts_Error;
    X_Error_Message := L_Msg_Data;
   CSM_UTIL_PKG.LOG('Leaving CSM_SR_ATTRIBUTES_PKG.APPLY_SR_ATTR_INSERT for HA ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_SR_ATTRIBUTES_PKG.APPLY_SR_ATTR_INSERT',FND_LOG.LEVEL_PROCEDURE);

End APPLY_SR_ATTR_INSERT;

--SR Attributes UPDATE
PROCEDURE APPLY_SR_ATTR_UPDATE
          (p_HA_PAYLOAD_ID  IN  NUMBER,
           p_Col_Name_List  In  Csm_Varchar_List,
           p_COL_VALUE_LIST IN  CSM_VARCHAR_LIST,
           x_RETURN_STATUS  OUT NOCOPY VARCHAR2,
           X_Error_Message  Out Nocopy Varchar2
         )
AS
 --Variable Declarations
  L_Rowid  Varchar2(150);
  L_Incidnt_Attr_Val_Id  Number;
  L_Object_Version_Number  Number;
  L_Incident_Id  Number;
  L_Sr_Attribute_Code  Varchar2(30);
  L_Override_Addr_Valid_Flag  Varchar2(1);
  L_Attribute1  Varchar2(150);
  L_Attribute2  Varchar2(150);
  L_Attribute3  Varchar2(150);
  L_Attribute4  Varchar2(150);
  L_Attribute5  Varchar2(150);
  L_ATTRIBUTE6  VARCHAR2(150);
  L_Attribute7  Varchar2(150);
  L_Attribute8  Varchar2(150);
  L_Attribute9  Varchar2(150);
  L_ATTRIBUTE10  VARCHAR2(150);
  L_Attribute11  Varchar2(150);
  L_Attribute12  Varchar2(150);
  L_Attribute13  Varchar2(150);
  L_ATTRIBUTE14  VARCHAR2(150);
  L_Attribute15  Varchar2(150);
  L_Attribute_Category  Varchar2(30);
  L_SR_ATTRIBUTE_VALUE  VARCHAR2(150);
  L_CREATION_DATE  DATE;
  L_CREATED_BY  NUMBER;
  L_LAST_UPDATE_DATE  DATE;
  L_Last_Updated_By  Number;
  L_Last_Update_Login  Number;
  l_return_status       VARCHAR2(1);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);

CURSOR C_GET_SRA_VERSION( B_INCIDNT_ATTR_VAL_ID NUMBER)
IS
   SELECT OBJECT_VERSION_NUMBER
   FROM   CUG_INCIDNT_ATTR_VALS_B
   WHERE  INCIDNT_ATTR_VAL_ID = B_INCIDNT_ATTR_VAL_ID;

BEGIN
  l_return_status := Fnd_Api.G_Ret_Sts_Success;
  CSM_UTIL_PKG.LOG('Entering CSM_SR_ATTRIBUTES_PKG.APPLY_SR_ATTR_UPDATE for HA ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_SR_ATTRIBUTES_PKG.APPLY_SR_ATTR_UPDATE',FND_LOG.LEVEL_PROCEDURE);


   -- prepare the SR link for the given SR link

  FOR i in 1..p_COL_NAME_LIST.COUNT-1 LOOP

    IF  p_COL_VALUE_LIST(i) IS NOT NULL THEN

      If p_Col_Name_List(I) = 'INCIDNT_ATTR_VAL_ID' Then
        L_Incidnt_Attr_Val_Id := P_COL_NAME_LIST(i);
      ELSIF  P_COL_NAME_LIST(I) = 'OBJECT_VERSION_NUMBER' THEN
        L_OBJECT_VERSION_NUMBER := P_COL_NAME_LIST(I)-1;
      ELSIF  p_COL_NAME_LIST(i) = 'INCIDENT_ID' THEN
        L_Incident_Id := P_COL_NAME_LIST(i);
      ELSIF  p_COL_NAME_LIST(i) = 'SR_ATTRIBUTE_CODE' THEN
        L_Sr_Attribute_Code := P_COL_NAME_LIST(i);
      ELSIF  p_COL_NAME_LIST(i) = 'OVERRIDE_ADDR_VALID_FLAG' THEN
        L_Override_Addr_Valid_Flag := P_COL_NAME_LIST(i);
      ELSIF  P_COL_NAME_LIST(i) = 'CREATION_DATE' THEN
        L_CREATION_DATE := P_COL_NAME_LIST(I);
      ELSIF  P_COL_NAME_LIST(i) = 'CREATED_BY' THEN
        L_CREATED_BY := P_COL_NAME_LIST(i);
      ELSIF  P_COL_NAME_LIST(i) = 'LAST_UPDATE_DATE' THEN
        L_LAST_UPDATE_DATE := P_COL_NAME_LIST(I);
      Elsif  P_COL_NAME_LIST(I) = 'LAST_UPDATED_BY' Then
         L_Last_Updated_By:= P_COL_NAME_LIST(i);
      ELSIF  P_COL_NAME_LIST(i) = 'LAST_UPDATE_LOGIN' THEN
        L_Last_Update_Login := P_COL_NAME_LIST(I);
      Elsif  P_COL_NAME_LIST(I) = 'ATTRIBUTE1' Then
        L_Attribute1 := P_COL_NAME_LIST(I);
      Elsif  P_COL_NAME_LIST(I) = 'ATTRIBUTE2' Then
        L_Attribute2 := P_COL_NAME_LIST(I);
      Elsif  P_COL_NAME_LIST(I) = 'ATTRIBUTE3' Then
        L_Attribute3 := P_COL_NAME_LIST(I);
      Elsif  P_COL_NAME_LIST(I) = 'ATTRIBUTE4' Then
        L_Attribute4 := P_COL_NAME_LIST(I);
      Elsif  P_COL_NAME_LIST(I) = 'ATTRIBUTE5' Then
        L_Attribute5 := P_COL_NAME_LIST(I);
      Elsif  P_COL_NAME_LIST(I) = 'ATTRIBUTE6' Then
        L_Attribute6 := P_COL_NAME_LIST(I);
      Elsif  P_COL_NAME_LIST(I) = 'ATTRIBUTE7' Then
        L_Attribute7 := P_COL_NAME_LIST(I);
      Elsif  P_COL_NAME_LIST(I) = 'ATTRIBUTE8' Then
        L_Attribute8 := P_COL_NAME_LIST(I);
      Elsif  P_COL_NAME_LIST(I) = 'ATTRIBUTE9' Then
        L_Attribute9 := P_COL_NAME_LIST(I);
      Elsif  P_COL_NAME_LIST(I) = 'ATTRIBUTE10' Then
        L_Attribute10 := P_COL_NAME_LIST(I);
      Elsif  P_COL_NAME_LIST(I) = 'ATTRIBUTE11' Then
        L_Attribute11 := P_COL_NAME_LIST(I);
      Elsif  P_COL_NAME_LIST(I) = 'ATTRIBUTE12' Then
        L_Attribute12 := P_COL_NAME_LIST(I);
      Elsif  P_COL_NAME_LIST(I) = 'ATTRIBUTE13' Then
        L_Attribute13 := P_COL_NAME_LIST(I);
      Elsif  P_COL_NAME_LIST(I) = 'ATTRIBUTE14' Then
        L_Attribute14 := P_COL_NAME_LIST(I);
      Elsif  P_COL_NAME_LIST(I) = 'ATTRIBUTE15' Then
        L_Attribute15 := P_COL_NAME_LIST(I);
      Elsif  P_COL_NAME_LIST(I) = 'ATTRIBUTE_CATEGORY' Then
        L_Attribute_Category := P_COL_NAME_LIST(I);
      END IF;
    End If;
  END LOOP;

  --Call the SR attribute Api
      CUG_INCIDNT_ATTR_VALS_PKG.UPDATE_ROW
      (
        X_Incidnt_Attr_Val_Id => L_Incidnt_Attr_Val_Id,
        X_Object_Version_Number => L_Object_Version_Number,
        X_Incident_Id => L_Incident_Id,
        X_Sr_Attribute_Code => L_Sr_Attribute_Code,
        X_Override_Addr_Valid_Flag => L_Override_Addr_Valid_Flag,
        X_Attribute1 => L_Attribute1,
        X_Attribute2 => L_Attribute2,
        X_Attribute3 => L_Attribute3,
        X_Attribute4 => L_Attribute4,
        X_Attribute5 => L_Attribute5,
        X_Attribute6 => L_Attribute6,
        X_Attribute7 => L_Attribute7,
        X_Attribute8 => L_Attribute8,
        X_Attribute9 => L_Attribute9,
        X_Attribute10 => L_Attribute10,
        X_Attribute11 => L_Attribute11,
        X_Attribute12 => L_Attribute12,
        X_Attribute13 => L_Attribute13,
        X_Attribute14 => L_Attribute14,
        X_Attribute15 => L_Attribute15,
        X_Attribute_Category => L_Attribute_Category,
        X_Sr_Attribute_Value => L_SR_ATTRIBUTE_VALUE,
        X_Last_Update_Date  => L_Last_Update_Date,
        X_Last_Updated_By   => L_Last_Updated_By,
        X_Last_Update_Login => L_Last_Update_Login
      ) ;

  IF l_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
    X_Return_Status := Fnd_Api.G_Ret_Sts_Error;
    X_Error_Message := l_Msg_Data;
  ELSE
    X_Return_Status := Fnd_Api.G_Ret_Sts_Success;
  END IF;
  CSM_UTIL_PKG.LOG('Leaving CSM_SR_ATTRIBUTES_PKG.APPLY_SR_ATTR_UPDATE for HA ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_SR_ATTRIBUTES_PKG.APPLY_SR_ATTR_UPDATE',Fnd_Log.Level_Procedure);

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_Ret_Sts_Error;
    X_Error_Message := L_Msg_Data;
   CSM_UTIL_PKG.LOG('Leaving CSM_SR_ATTRIBUTES_PKG.APPLY_SR_ATTR_UPDATE for HA ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_SR_ATTRIBUTES_PKG.APPLY_SR_ATTR_UPDATE',FND_LOG.LEVEL_PROCEDURE);

END APPLY_SR_ATTR_UPDATE;

--SR Attributes DELETE
PROCEDURE APPLY_SR_ATTR_DELETE
          (p_HA_PAYLOAD_ID  IN  NUMBER,
           p_Col_Name_List  In  Csm_Varchar_List,
           p_COL_VALUE_LIST IN  CSM_VARCHAR_LIST,
           x_RETURN_STATUS  OUT NOCOPY VARCHAR2,
           X_Error_Message  Out Nocopy Varchar2
         )
AS
 --Variable Declarations
  L_Incidnt_Attr_Val_Id  Number;
  l_return_status       VARCHAR2(1);
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);

BEGIN
  l_return_status := Fnd_Api.G_Ret_Sts_Success;
  CSM_UTIL_PKG.LOG('Entering CSM_SR_ATTRIBUTES_PKG.APPLY_SR_ATTR_DELETE for HA ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_SR_ATTRIBUTES_PKG.APPLY_SR_ATTR_DELETE',FND_LOG.LEVEL_PROCEDURE);


   -- prepare the SR link for the given SR link

  FOR i in 1..p_COL_NAME_LIST.COUNT-1 LOOP

    IF  p_COL_VALUE_LIST(i) IS NOT NULL THEN
      IF P_COL_NAME_LIST(I) = 'INCIDNT_ATTR_VAL_ID' THEN
        L_INCIDNT_ATTR_VAL_ID := P_COL_NAME_LIST(I);
        EXIT;
      END IF;
    END IF;

  END LOOP;

  --Call the SR attribute Api
      CUG_INCIDNT_ATTR_VALS_PKG.DELETE_ROW
      (
        X_Incidnt_Attr_Val_Id => L_Incidnt_Attr_Val_Id
      ) ;

  IF l_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
    X_Return_Status := Fnd_Api.G_Ret_Sts_Error;
    X_Error_Message := l_Msg_Data;
  ELSE
    X_Return_Status := Fnd_Api.G_Ret_Sts_Success;
  END IF;
  CSM_UTIL_PKG.LOG('Leaving CSM_SR_ATTRIBUTES_PKG.APPLY_SR_ATTR_DELETE for HA ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_SR_ATTRIBUTES_PKG.APPLY_SR_ATTR_DELETE',Fnd_Log.Level_Procedure);

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_Ret_Sts_Error;
    X_Error_Message := L_Msg_Data;
   CSM_UTIL_PKG.LOG('Leaving CSM_SR_ATTRIBUTES_PKG.APPLY_SR_ATTR_DELETE for HA ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_SR_ATTRIBUTES_PKG.APPLY_SR_ATTR_DELETE',FND_LOG.LEVEL_PROCEDURE);

END APPLY_SR_ATTR_DELETE;

PROCEDURE APPLY_HA_ATTR_CHANGES
          (p_HA_PAYLOAD_ID  IN  NUMBER,
           P_COL_NAME_LIST  IN  CSM_VARCHAR_LIST,
           p_COL_VALUE_LIST IN  CSM_VARCHAR_LIST,
           p_dml_type       IN  VARCHAR2,
           x_RETURN_STATUS  OUT NOCOPY VARCHAR2,
           x_ERROR_MESSAGE  OUT NOCOPY VARCHAR2
         )IS
L_RETURN_STATUS  VARCHAR2(100);
l_ERROR_MESSAGE  VARCHAR2(4000);
BEGIN
  /*** initialize return status and message list ***/
  L_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.INITIALIZE;

  CSM_UTIL_PKG.LOG('Entering CSM_SERVICE_REQUESTS_PKG.APPLY_HA_ATTR_CHANGES for Payload ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_SERVICE_REQUESTS_PKG.APPLY_HA_ATTR_CHANGES',FND_LOG.LEVEL_PROCEDURE);

  IF p_dml_type ='I' THEN
    -- Process insert
            APPLY_SR_ATTR_INSERT
                (p_HA_PAYLOAD_ID => p_HA_PAYLOAD_ID,
                p_COL_NAME_LIST  => P_COL_NAME_LIST,
                p_COL_VALUE_LIST => p_COL_VALUE_LIST,
                x_RETURN_STATUS  => l_RETURN_STATUS,
                x_ERROR_MESSAGE  => l_ERROR_MESSAGE
              );
  ELSIF p_dml_type ='U' THEN
    -- Process update
            APPLY_SR_ATTR_UPDATE
                (p_HA_PAYLOAD_ID => p_HA_PAYLOAD_ID,
                p_COL_NAME_LIST  => P_COL_NAME_LIST,
                p_COL_VALUE_LIST => p_COL_VALUE_LIST,
                x_RETURN_STATUS  => l_RETURN_STATUS,
                X_ERROR_MESSAGE  => L_ERROR_MESSAGE
              );
  ELSIF p_dml_type ='D' THEN
    -- Process update
            APPLY_SR_ATTR_DELETE
                (p_HA_PAYLOAD_ID => p_HA_PAYLOAD_ID,
                p_COL_NAME_LIST  => P_COL_NAME_LIST,
                p_COL_VALUE_LIST => p_COL_VALUE_LIST,
                x_RETURN_STATUS  => l_RETURN_STATUS,
                X_ERROR_MESSAGE  => L_ERROR_MESSAGE
              );
  END IF;
  X_RETURN_STATUS := l_RETURN_STATUS;
  x_ERROR_MESSAGE := l_ERROR_MESSAGE;
  CSM_UTIL_PKG.LOG('Leaving CSM_SERVICE_REQUESTS_PKG.APPLY_HA_ATTR_CHANGES for HA ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_SERVICE_REQUESTS_PKG.APPLY_HA_ATTR_CHANGES',FND_LOG.LEVEL_PROCEDURE);

EXCEPTION WHEN OTHERS THEN
  CSM_UTIL_PKG.log( 'Exception in CSM_SERVICE_REQUESTS_PKG.APPLY_HA_ATTR_CHANGES: ' || sqlerrm
               || ' for HA ID ' || p_HA_PAYLOAD_ID ,'CSM_SERVICE_REQUESTS_PKG.APPLY_HA_ATTR_CHANGES',FND_LOG.LEVEL_EXCEPTION);
  X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
  X_ERROR_MESSAGE := TO_CHAR(SQLERRM,2000);

END APPLY_HA_ATTR_CHANGES;

PROCEDURE APPLY_HA_LINK_CHANGES
          (p_HA_PAYLOAD_ID  IN  NUMBER,
           P_COL_NAME_LIST  IN  CSM_VARCHAR_LIST,
           p_COL_VALUE_LIST IN  CSM_VARCHAR_LIST,
           p_dml_type       IN  VARCHAR2,
           x_RETURN_STATUS  OUT NOCOPY VARCHAR2,
           x_ERROR_MESSAGE  OUT NOCOPY VARCHAR2
         )IS
L_RETURN_STATUS  VARCHAR2(100);
l_ERROR_MESSAGE  VARCHAR2(4000);
BEGIN
  /*** initialize return status and message list ***/
  L_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.INITIALIZE;

  CSM_UTIL_PKG.LOG('Entering CSM_SERVICE_REQUESTS_PKG.APPLY_HA_LINK_CHANGES for Payload ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_SERVICE_REQUESTS_PKG.APPLY_HA_LINK_CHANGES',FND_LOG.LEVEL_PROCEDURE);

  IF p_dml_type ='I' THEN
    -- Process insert
            APPLY_SR_LINK_INSERT
                (p_HA_PAYLOAD_ID  =>p_HA_PAYLOAD_ID,
                p_COL_NAME_LIST  => P_COL_NAME_LIST,
                p_COL_VALUE_LIST => p_COL_VALUE_LIST,
                x_RETURN_STATUS  => l_RETURN_STATUS,
                x_ERROR_MESSAGE  => l_ERROR_MESSAGE
              );
  ELSIF p_dml_type ='U' THEN
    -- Process update
            APPLY_SR_LINK_UPDATE
                (p_HA_PAYLOAD_ID  =>p_HA_PAYLOAD_ID,
                p_COL_NAME_LIST  => P_COL_NAME_LIST,
                p_COL_VALUE_LIST => p_COL_VALUE_LIST,
                x_RETURN_STATUS  => l_RETURN_STATUS,
                X_ERROR_MESSAGE  => L_ERROR_MESSAGE
              );
  ELSIF p_dml_type ='D' THEN
    -- Process update
            APPLY_SR_LINK_DELETE
                (p_HA_PAYLOAD_ID  =>p_HA_PAYLOAD_ID,
                p_COL_NAME_LIST  => P_COL_NAME_LIST,
                p_COL_VALUE_LIST => p_COL_VALUE_LIST,
                x_RETURN_STATUS  => l_RETURN_STATUS,
                X_ERROR_MESSAGE  => L_ERROR_MESSAGE
              );
  END IF;

  X_RETURN_STATUS := l_RETURN_STATUS;
  x_ERROR_MESSAGE := l_ERROR_MESSAGE;
  CSM_UTIL_PKG.LOG('Leaving CSM_SERVICE_REQUESTS_PKG.APPLY_HA_LINK_CHANGES for HA ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_SERVICE_REQUESTS_PKG.APPLY_HA_LINK_CHANGES',FND_LOG.LEVEL_PROCEDURE);

EXCEPTION WHEN OTHERS THEN
  CSM_UTIL_PKG.log( 'Exception in CSM_SERVICE_REQUESTS_PKG.APPLY_HA_LINK_CHANGES: ' || sqlerrm
               || ' for HA ID ' || p_HA_PAYLOAD_ID ,'CSM_SERVICE_REQUESTS_PKG.APPLY_HA_LINK_CHANGES',FND_LOG.LEVEL_EXCEPTION);
  X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
  X_ERROR_MESSAGE := TO_CHAR(SQLERRM,2000);

END APPLY_HA_LINK_CHANGES;

END CSM_SR_ATTRIBUTES_PKG;

/
