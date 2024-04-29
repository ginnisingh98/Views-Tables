--------------------------------------------------------
--  DDL for Package Body CSM_NOTES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_NOTES_PKG" AS
/* $Header: csmunotb.pls 120.4.12010000.4 2010/04/30 05:19:07 trajasek ship $ */

-- MODIFICATION HISTORY
-- Person      Date    Comments
-- Anurag     06/12/02 Created
-- ---------   ------  ------------------------------------------
   -- Enter procedure, function bodies as shown below


/*** Globals ***/
g_object_name  CONSTANT VARCHAR2(30) := 'CSM_NOTES_PKG';  -- package name
g_pub_name     CONSTANT VARCHAR2(30) := 'CSF_M_NOTES';  -- publication item name
g_debug_level           NUMBER; -- debug level

CURSOR c_notes( b_user_name VARCHAR2, b_tranid NUMBER) is
  SELECT *
  FROM  csf_m_notes_inq
  WHERE tranid$$ = b_tranid
  AND   clid$$cs = b_user_name;


/***
  This procedure is called by APPLY_CLIENT_CHANGES when an inserted record is to be processed.
***/
PROCEDURE APPLY_INSERT
         (
           p_record        IN c_notes%ROWTYPE,
           p_error_msg     OUT NOCOPY    VARCHAR2,
           x_return_status IN OUT NOCOPY VARCHAR2
         ) IS

l_msg_count    number;
l_msg_data     varchar2(1024);

l_jtf_note_id  number;

BEGIN

CSM_UTIL_PKG.log( 'Entering ' || g_object_name || '.APPLY_INSERT:'
                    || ' for PK ' || p_record.jtf_note_id ,
                    'CSM_NOTES_PKG.APPLY_INSERT',FND_LOG.LEVEL_PROCEDURE);

--create the note
CSM_UTIL_PKG.log( 'Creating Note ' || g_object_name || '.APPLY_INSERT:'
                    || ' for PK ' || p_record.jtf_note_id ,
                    'CSM_NOTES_PKG.APPLY_INSERT',FND_LOG.LEVEL_EVENT);
jtf_notes_pub.Create_note
( p_api_version        => 1.0
, p_validation_level   => FND_API.G_VALID_LEVEL_FULL
, p_init_msg_list      => FND_API.G_TRUE
, p_commit             => FND_API.G_FALSE
, x_return_status      => x_return_status
, x_msg_count          => l_msg_count
, x_msg_data           => l_msg_data
, p_jtf_note_id        => p_record.jtf_note_id
, p_source_object_id   => p_record.source_object_id
, p_source_object_code => p_record.source_object_code
, p_notes              => p_record.notes
, p_note_status        => p_record.note_status
, p_note_type          => p_record.note_type
, p_entered_by         => p_record.entered_by
, p_entered_date       => p_record.entered_date
, p_created_by         => NVL(p_record.created_by,FND_GLOBAL.USER_ID)  --12.1
, p_creation_date      => SYSDATE
, p_last_updated_by    => NVL(p_record.last_updated_by,FND_GLOBAL.USER_ID)  --12.1
, p_last_update_date   => SYSDATE
, p_last_update_login  => FND_GLOBAL.LOGIN_ID
, x_jtf_note_id        => l_jtf_note_id
);

if x_return_status <> FND_API.G_RET_STS_SUCCESS
then
   /*** exception occurred in API -> return errmsg ***/
    p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
      (
        p_api_error      => TRUE
      );
    CSM_UTIL_PKG.log( 'Error in ' || g_object_name || '.APPLY_INSERT:'
               || ' ROOT ERROR: jtf_notes_pub.create_note'
               || ' for PK ' || p_record.JTF_NOTE_ID ,'CSM_NOTES_PKG.APPLY_INSERT',FND_LOG.LEVEL_ERROR );

   x_return_status := FND_API.G_RET_STS_ERROR;
else
   x_return_status := FND_API.G_RET_STS_SUCCESS;
end if;

exception
  when others then
     fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_INSERT', sqlerrm);
     p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
     (
       p_api_error      => TRUE
     );
     CSM_UTIL_PKG.log( 'Exception in ' || g_object_name || '.APPLY_INSERT:'
               || ' for PK ' || p_record.jtf_note_id , 'CSM_NOTES_PKG.APPLY_INSERT',FND_LOG.LEVEL_ERROR);
     x_return_status := FND_API.G_RET_STS_ERROR;

END APPLY_INSERT;


/***
  This procedure is called by APPLY_CLIENT_CHANGES when an inserted record is to be processed.
***/
PROCEDURE APPLY_UPDATE
         (
           p_record        IN c_notes%ROWTYPE,
           p_error_msg     OUT NOCOPY    VARCHAR2,
           x_return_status IN OUT NOCOPY VARCHAR2
         ) IS

l_msg_count    number;
l_msg_data     varchar2(1024);

l_server_last_update_date date;
CURSOR l_server_last_update_date_csr(p_jtf_note_id jtf_notes_b.jtf_note_id%TYPE)
IS
select last_update_date from jtf_notes_b
where jtf_note_id = p_jtf_note_id;

BEGIN
CSM_UTIL_PKG.log( 'Entering ' || g_object_name || '.APPLY_UPDATE:'
               || ' for PK ' || p_record.jtf_note_id,
               'CSM_NOTES_PKG.APPLY_UPDATE',
               FND_LOG.LEVEL_PROCEDURE );
--get the last update date of the note

--select last_update_date into l_server_last_update_date
--from jtf_notes_b
--where jtf_note_id = p_record.jtf_note_id;

  OPEN l_server_last_update_date_csr(p_record.jtf_note_id);
  FETCH l_server_last_update_date_csr INTO l_server_last_update_date;
  CLOSE l_server_last_update_date_csr;

--check for the stale data
  -- SERVER_WINS profile value
  if(fnd_profile.value(csm_profile_pkg.g_JTM_APPL_CONFLICT_RULE)
       = csm_profile_pkg.g_SERVER_WINS) then
    if(l_server_last_update_date <> p_record.server_last_update_date) then
       x_return_status := FND_API.G_RET_STS_ERROR;
       p_error_msg := 'UPWARD SYNC CONFLICT: CLIENT LOST: CSM_NOTES_PKG.APPLY_UPDATE: P_KEY = '
          || p_record.jtf_note_id;
       csm_util_pkg.log(p_error_msg,'CSM_NOTES_PKG.APPLY_UPDATE',FND_LOG.LEVEL_EVENT );
       return;
    end if;
  end if;

  --CLIENT_WINS (or client is allowd to update the record)

--update the note
jtf_notes_pub.Update_note
( p_api_version        => 1.0
, p_validation_level   => FND_API.G_VALID_LEVEL_FULL
, p_init_msg_list      => FND_API.G_TRUE
, p_commit             => FND_API.G_FALSE
, x_return_status      => x_return_status
, x_msg_count          => l_msg_count
, x_msg_data           => l_msg_data
, p_jtf_note_id        => p_record.jtf_note_id
, p_notes              => p_record.notes
, p_note_status        => p_record.note_status
, p_note_type          => p_record.note_type
, p_entered_by         => p_record.entered_by
, p_last_updated_by    =>  NVL(p_record.last_updated_by,FND_GLOBAL.USER_ID) --12.1
, p_last_update_date   => SYSDATE
, p_last_update_login  => FND_GLOBAL.LOGIN_ID
);

if x_return_status <> FND_API.G_RET_STS_SUCCESS
then
   /*** exception occurred in API -> return errmsg ***/
    p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
      (
        p_api_error      => TRUE
      );
    CSM_UTIL_PKG.log( 'Error in ' || g_object_name || '.APPLY_UPDATE:'
               || ' ROOT ERROR: jtf_notes_pub.update_note'
               || ' for PK ' || p_record.JTF_NOTE_ID ,'CSM_NOTES_PKG.APPLY_UPDATE',FND_LOG.LEVEL_ERROR );

   x_return_status := FND_API.G_RET_STS_ERROR;
else
   x_return_status := FND_API.G_RET_STS_SUCCESS;
end if;

CSM_UTIL_PKG.log( 'Exiting  ' || g_object_name || '.APPLY_UPDATE:'
               || ' for PK ' || p_record.jtf_note_id,
               'CSM_NOTES_PKG.APPLY_UPDATE',
               FND_LOG.LEVEL_PROCEDURE );
exception
  when others then
     fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_UPDATE', sqlerrm);
     p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
     (
       p_api_error      => TRUE
     );

     CSM_UTIL_PKG.log( 'Exception in ' || g_object_name || '.APPLY_UPDATE:'
               || ' for PK ' || p_record.jtf_note_id,
               'CSM_NOTES_PKG.APPLY_UPDATE',
               FND_LOG.LEVEL_ERROR );

     x_return_status := FND_API.G_RET_STS_ERROR;
END APPLY_UPDATE;

/***
  This procedure is called by APPLY_CLIENT_CHANGES for every record in in-queue that needs to be processed.
***/
PROCEDURE APPLY_RECORD
         (
           p_record        IN     c_notes%ROWTYPE,
           p_error_msg     OUT NOCOPY    VARCHAR2,
           x_return_status IN OUT NOCOPY VARCHAR2
         ) IS
BEGIN
  /*** initialize return status and message list ***/
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.INITIALIZE;

  IF p_record.dmltype$$='I' THEN
    -- Process insert
    APPLY_INSERT
      (
        p_record,
        p_error_msg,
        x_return_status
      );
  ELSE /*IF p_record.dmltype$$='U' THEN
    -- Process update
    APPLY_UPDATE
      (
        p_record,
        p_error_msg,
        x_return_status
      );
  ELSE*/
    -- Process delete; not supported for this entity
      CSM_UTIL_PKG.LOG
        ( 'Update and Delete is not supported for this entity'
          || ' for PK ' || p_record.jtf_note_id,
          'CSM_NOTES_PKG.APPLY_RECORD',
           FND_LOG.LEVEL_EVENT );

    p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
      (
        p_message        => 'CSM_DML_OPERATION'
      , p_token_name1    => 'DML'
      , p_token_value1   => p_record.dmltype$$
      );

    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

EXCEPTION WHEN OTHERS THEN
  /*** defer record when any process exception occurs ***/
    CSM_UTIL_PKG.LOG
    ( 'Exception occurred in CSM_notes_PKG.APPLY_RECORD:' || ' ' || sqlerrm
      || ' for PK ' || p_record.jtf_note_id,
      'CSM_NOTES_PKG.APPLY_RECORD',
               FND_LOG.LEVEL_ERROR );

  fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_RECORD', sqlerrm);
  p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
    (
      p_api_error      => TRUE
    );

  x_return_status := FND_API.G_RET_STS_ERROR;
END APPLY_RECORD;

/***
  This procedure is called by CSM_UTIL_PKG when publication item <replace>
  is dirty. This happens when a mobile field service device executed DML on an updatable table and did
  a fast sync. This procedure will insert the data that came from mobile into the backend tables using
  public APIs.
***/
PROCEDURE APPLY_CLIENT_CHANGES
         (
           p_user_name     IN VARCHAR2,
           p_tranid        IN NUMBER,
           p_debug_level   IN NUMBER,
           x_return_status IN OUT NOCOPY VARCHAR2
         ) IS

  l_process_status VARCHAR2(1);
  l_error_msg      VARCHAR2(4000);
BEGIN
  g_debug_level := p_debug_level;
  x_return_status := FND_API.G_RET_STS_SUCCESS;



  /*** loop through debrief labor records in inqueue ***/
  FOR r_notes IN c_notes( p_user_name, p_tranid) LOOP

    SAVEPOINT save_rec;

    /*** apply record ***/
    APPLY_RECORD
      (
        r_notes
      , l_error_msg
      , l_process_status
      );

    /*** was record processed successfully? ***/
    IF l_process_status = FND_API.G_RET_STS_SUCCESS THEN
      /*** Yes -> delete record from inqueue ***/

      CSM_UTIL_PKG.DELETE_RECORD
        (
          p_user_name,
          p_tranid,
          r_notes.seqno$$,
          r_notes.jtf_note_id,
          g_object_name,
          g_pub_name,
          l_error_msg,
          l_process_status
        );

      /*** was delete successful? ***/
      IF l_process_status <> FND_API.G_RET_STS_SUCCESS THEN
        /*** no -> rollback ***/
          CSM_UTIL_PKG.LOG
          ( 'Deleting from inqueue failed, rolling back to savepoint'
             || ' for PK ' || r_notes.jtf_note_id,
            'CSM_NOTES_PKG.APPLY_CLIENT_CHANGES',
            FND_LOG.LEVEL_EVENT ); -- put PK column here
        ROLLBACK TO save_rec;
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
    END IF;

    IF l_process_Status <> FND_API.G_RET_STS_SUCCESS THEN
      /*** Record was not processed successfully or delete failed -> defer and reject record ***/
       CSM_UTIL_PKG.LOG
        ( 'Record not processed successfully, deferring and rejecting record'
            || ' for PK ' || r_notes.jtf_note_id,
            'CSM_NOTES_PKG.APPLY_CLIENT_CHANGES',
             FND_LOG.LEVEL_EVENT); -- put PK column here

      CSM_UTIL_PKG.DEFER_RECORD
       (
         p_user_name
       , p_tranid
       , r_notes.seqno$$
       , r_notes.jtf_note_id
       , g_object_name
       , g_pub_name
       , l_error_msg
       , l_process_status
       , r_notes.dmltype$$
       );

      /*** Was defer successful? ***/
      IF l_process_status <> FND_API.G_RET_STS_SUCCESS THEN
        /*** no -> rollback ***/
          CSM_UTIL_PKG.LOG
          ( 'Defer record failed, rolling back to savepoint'
          || ' for PK ' || r_notes.jtf_note_id,
          'CSM_NOTES_PKG.APPLY_CLIENT_CHANGES',
          FND_LOG.LEVEL_EVENT ); -- put PK column here
        ROLLBACK TO save_rec;
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
    END IF;

  END LOOP;

EXCEPTION WHEN OTHERS THEN
  /*** catch and log exceptions ***/
    CSM_UTIL_PKG.LOG
    ( 'Exception occurred in APPLY_CLIENT_CHANGES:' || ' ' || sqlerrm ,
        'CSM_NOTES_PKG.APPLY_CLIENT_CHANGES',
        FND_LOG.LEVEL_ERROR
     );
  x_return_status := FND_API.G_RET_STS_ERROR;
END APPLY_CLIENT_CHANGES;

PROCEDURE APPLY_HA_INSERT
          (p_HA_PAYLOAD_ID  IN  NUMBER,
           p_COL_NAME_LIST  IN  CSM_VARCHAR_LIST,
           p_COL_VALUE_LIST IN  CSM_VARCHAR_LIST,
           x_RETURN_STATUS  OUT NOCOPY VARCHAR2,
           X_Error_Message  Out Nocopy Varchar2
         )
AS
 --Variable Declarations
   L_Api_Version    Number;
   L_Init_Msg_List  Varchar2(100);
   l_return_status  VARCHAR2(1);
   l_msg_count      NUMBER;
   L_MSG_DATA      VARCHAR2(2000);
   NOTES_REC       JTF_NOTES_B%ROWTYPE;
   L_JTF_NOTE_ID       NUMBER;
   L_CON_NAME_LIST  CSM_VARCHAR_LIST;
   L_CON_VALUE_LIST CSM_VARCHAR_LIST;
   L_AUX_NAME_LIST   CSM_VARCHAR_LIST;
   L_AUX_VALUE_LIST  CSM_VARCHAR_LIST;
   L_NOTES           VARCHAR2(2000);
   L_NOTES_DETAIL    CLOB;
   L_ERROR_MESSAGE  VARCHAR2(4000);
   L_JTF_NOTE_CONTEXTS_TAB JTF_NOTES_PUB.jtf_note_contexts_tbl_type;

Cursor C_Get_Aux_Objects(C_Payload_Id Number)
Is
SELECT HA_PAYLOAD_ID,
       OBJECT_NAME,
       DML_TYPE
From   Csm_Ha_Payload_Data
Where  Parent_Payload_Id = C_Payload_Id
AND    HA_PAYLOAD_ID <> Parent_Payload_Id
ORDER BY HA_PAYLOAD_ID ASC;

BEGIN
  X_Return_Status := Fnd_Api.G_Ret_Sts_Success;
  CSM_UTIL_PKG.LOG('Entering CSM_NOTES_PKG.APPLY_HA_INSERT for HA ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_NOTES_PKG.APPLY_HA_INSERT',FND_LOG.LEVEL_PROCEDURE);
  L_Api_Version := 1.0;
   -- get the notes info
--Process Aux Objects
  For R_Get_Aux_Objects In C_Get_Aux_Objects(P_Ha_Payload_Id)  Loop

    CSM_HA_PROCESS_PKG.Parse_Xml(P_Ha_Payload_Id =>R_Get_Aux_Objects.Ha_Payload_Id,
                        X_Col_Name_List  => l_Aux_Name_List,
                        x_COL_VALUE_LIST => l_Aux_Value_List,
                        X_Con_Name_List  => L_CON_NAME_LIST,
                        x_COn_VALUE_LIST => L_CON_VALUE_LIST,
                        X_Return_Status  => L_Return_Status,
                        X_Error_Message  => L_Error_Message);

    IF R_GET_AUX_OBJECTS.OBJECT_NAME = 'JTF_NOTES_TL' THEN
         If  L_Return_Status = Fnd_Api.G_Ret_Sts_Success And  L_Aux_Name_List.Count > 0 Then
          FOR I IN 1..L_AUX_NAME_LIST.COUNT-1 LOOP
            IF L_AUX_NAME_LIST(I) = 'NOTES' THEN
              L_NOTES := L_AUX_VALUE_LIST(I);
            ELSIF L_AUX_NAME_LIST(I) = 'NOTES_DETAIL' THEN
              L_NOTES_DETAIL := L_AUX_VALUE_LIST(I);
            END IF;
          END LOOP;
         END IF;
    END IF;
  END LOOP;

  FOR i in 1..p_COL_NAME_LIST.COUNT-1 LOOP

    IF  p_COL_VALUE_LIST(i) IS NOT NULL THEN

      IF P_COL_NAME_LIST(I) = 'JTF_NOTE_ID' THEN
        Notes_rec.JTF_NOTE_ID := p_COL_VALUE_LIST(i);
      ELSIF  p_COL_NAME_LIST(i) = 'PARENT_NOTE_ID' THEN
        Notes_rec.PARENT_NOTE_ID := p_COL_VALUE_LIST(i);
      ELSIF  p_COL_NAME_LIST(i) = 'SOURCE_OBJECT_ID' THEN
        Notes_rec.SOURCE_OBJECT_ID := p_COL_VALUE_LIST(i);
      ELSIF  p_COL_NAME_LIST(i) = 'SOURCE_OBJECT_CODE' THEN
        Notes_rec.SOURCE_OBJECT_CODE := p_COL_VALUE_LIST(i);
      ELSIF  p_COL_NAME_LIST(i) = 'LAST_UPDATE_DATE' THEN
        Notes_rec.LAST_UPDATE_DATE := p_COL_VALUE_LIST(i);
      ELSIF  p_COL_NAME_LIST(i) = 'LAST_UPDATED_BY' THEN
        Notes_rec.LAST_UPDATED_BY := p_Col_Value_List(I);
      ELSIF  p_COL_NAME_LIST(i) = 'CREATION_DATE' THEN
        Notes_rec.CREATION_DATE := p_COL_VALUE_LIST(i);
      ELSIF  p_COL_NAME_LIST(i) = 'CREATED_BY' THEN
        Notes_rec.CREATED_BY := p_Col_Value_List(I);
      ELSIF  p_COL_NAME_LIST(i) = 'LAST_UPDATE_LOGIN' THEN
        Notes_rec.LAST_UPDATE_LOGIN := p_COL_VALUE_LIST(i);
      ELSIF  p_COL_NAME_LIST(i) = 'NOTE_STATUS' THEN
        Notes_rec.NOTE_STATUS := p_Col_Value_List(I);
      ELSIF  p_COL_NAME_LIST(i) = 'ENTERED_BY' THEN
        Notes_rec.ENTERED_BY := p_Col_Value_List(I);
      ELSIF  p_COL_NAME_LIST(i) = 'ENTERED_DATE' THEN
        Notes_rec.ENTERED_DATE := P_COL_VALUE_LIST(I);
      ELSIF  p_COL_NAME_LIST(i) = 'NOTE_TYPE' THEN
        Notes_rec.NOTE_TYPE := P_COL_VALUE_LIST(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE1' Then
        Notes_rec.ATTRIBUTE1 := p_Col_Value_List(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE2' Then
        Notes_rec.ATTRIBUTE2 := p_Col_Value_List(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE3' Then
        Notes_rec.ATTRIBUTE3 := p_Col_Value_List(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE4' Then
        Notes_rec.ATTRIBUTE4 := p_Col_Value_List(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE5' Then
        Notes_rec.ATTRIBUTE5 := p_Col_Value_List(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE6' Then
        Notes_rec.ATTRIBUTE6 := p_Col_Value_List(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE7' Then
        Notes_rec.ATTRIBUTE7 := p_Col_Value_List(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE8' Then
        Notes_rec.ATTRIBUTE8 := p_Col_Value_List(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE9' Then
        Notes_rec.ATTRIBUTE9 := p_Col_Value_List(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE10' Then
        Notes_rec.ATTRIBUTE10 := p_Col_Value_List(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE11' Then
        Notes_rec.ATTRIBUTE11 := p_Col_Value_List(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE12' Then
        Notes_rec.ATTRIBUTE12 := p_Col_Value_List(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE13' Then
        Notes_rec.ATTRIBUTE13 := p_Col_Value_List(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE14' Then
        Notes_rec.ATTRIBUTE14 := p_Col_Value_List(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE15' Then
        Notes_rec.ATTRIBUTE15 := p_Col_Value_List(I);
      ELSIF  P_COL_NAME_LIST(I) = 'CONTEXT' THEN
        Notes_rec.CONTEXT := P_COL_VALUE_LIST(I);
      END IF;
    End If;
  END LOOP;

--calling the Notes Public API
JTF_NOTES_PUB.CREATE_NOTE
( P_PARENT_NOTE_ID     => NOTES_REC.PARENT_NOTE_ID
, P_JTF_NOTE_ID        => Notes_rec.JTF_NOTE_ID
, P_API_VERSION        => L_API_VERSION
, P_INIT_MSG_LIST      => L_INIT_MSG_LIST
, P_COMMIT             => FND_API.G_FALSE
, P_VALIDATION_LEVEL   => 0.5
, X_RETURN_STATUS	     => L_RETURN_STATUS
, X_MSG_COUNT		       => L_MSG_COUNT
, X_MSG_DATA		       => L_MSG_DATA
, P_ORG_ID             => NULL
, P_SOURCE_OBJECT_ID   => NOTES_REC.SOURCE_OBJECT_ID
, P_SOURCE_OBJECT_CODE => NOTES_REC.SOURCE_OBJECT_CODE
, P_NOTES              => L_NOTES
, P_NOTES_DETAIL       => L_NOTES_DETAIL
, P_NOTE_STATUS        => Notes_rec.NOTE_STATUS
, P_ENTERED_BY         => NOTES_REC.ENTERED_BY
, P_ENTERED_DATE       => NOTES_REC.ENTERED_DATE
, X_JTF_NOTE_ID        => l_jtf_note_id
, P_LAST_UPDATE_DATE   => NOTES_REC.LAST_UPDATE_DATE
, P_LAST_UPDATED_BY    => NOTES_REC.LAST_UPDATED_BY
, P_CREATION_DATE      => NOTES_REC.CREATION_DATE
, P_CREATED_BY         => Notes_rec.CREATED_BY
, P_LAST_UPDATE_LOGIN  => Notes_rec.LAST_UPDATE_LOGIN
, P_ATTRIBUTE1         => Notes_rec.ATTRIBUTE1
, P_ATTRIBUTE2         => Notes_rec.ATTRIBUTE2
, P_ATTRIBUTE3         => NOTES_REC.ATTRIBUTE3
, P_ATTRIBUTE4         => Notes_rec.ATTRIBUTE4
, P_ATTRIBUTE5         => Notes_rec.ATTRIBUTE5
, P_ATTRIBUTE6         => NOTES_REC.ATTRIBUTE6
, P_ATTRIBUTE7         => NOTES_REC.ATTRIBUTE7
, P_ATTRIBUTE8         => Notes_rec.ATTRIBUTE8
, P_ATTRIBUTE9         => NOTES_REC.ATTRIBUTE9
, P_ATTRIBUTE10        => NOTES_REC.ATTRIBUTE10
, P_ATTRIBUTE11        => Notes_rec.ATTRIBUTE11
, P_ATTRIBUTE12        => Notes_rec.ATTRIBUTE12
, P_ATTRIBUTE13        => Notes_rec.ATTRIBUTE13
, p_attribute14        => Notes_rec.ATTRIBUTE14
, P_ATTRIBUTE15        => Notes_rec.ATTRIBUTE15
, P_CONTEXT            => NOTES_REC.CONTEXT
, P_NOTE_TYPE          => NOTES_REC.NOTE_TYPE
, P_JTF_NOTE_CONTEXTS_TAB =>L_JTF_NOTE_CONTEXTS_TAB      --not used
);

  IF l_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
    X_Return_Status := Fnd_Api.G_Ret_Sts_Error;
    X_Error_Message := l_Msg_Data;
  ELSE
    X_Return_Status := Fnd_Api.G_Ret_Sts_Success;
  END IF;
  CSM_UTIL_PKG.LOG('Leaving CSM_NOTES_PKG.APPLY_HA_INSERT for HA ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_NOTES_PKG.APPLY_HA_INSERT',Fnd_Log.Level_Procedure);

EXCEPTION
  WHEN OTHERS THEN
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    X_Error_Message := TO_CHAR(SQLERRM,1,2000);
   CSM_UTIL_PKG.LOG('Leaving CSM_NOTES_PKG.APPLY_HA_INSERT for HA ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_NOTES_PKG.APPLY_HA_INSERT',FND_LOG.LEVEL_PROCEDURE);

END APPLY_HA_INSERT;
--Notes Update
PROCEDURE APPLY_HA_UPDATE
          (p_HA_PAYLOAD_ID  IN  NUMBER,
           p_COL_NAME_LIST  IN  CSM_VARCHAR_LIST,
           p_COL_VALUE_LIST IN  CSM_VARCHAR_LIST,
           x_RETURN_STATUS  OUT NOCOPY VARCHAR2,
           X_Error_Message  Out Nocopy Varchar2
         )
AS
 --Variable Declarations
   L_Api_Version    Number;
   L_Init_Msg_List  Varchar2(100);
   l_return_status  VARCHAR2(1);
   l_msg_count      NUMBER;
   L_MSG_DATA      VARCHAR2(2000);
   NOTES_REC       JTF_NOTES_B%ROWTYPE;
   L_JTF_NOTE_ID       NUMBER;
   L_CON_NAME_LIST  CSM_VARCHAR_LIST;
   L_CON_VALUE_LIST CSM_VARCHAR_LIST;
   L_AUX_NAME_LIST   CSM_VARCHAR_LIST;
   L_AUX_VALUE_LIST  CSM_VARCHAR_LIST;
   L_NOTES           VARCHAR2(2000);
   L_NOTES_DETAIL    CLOB;
   L_ERROR_MESSAGE  VARCHAR2(4000);
   L_JTF_NOTE_CONTEXTS_TAB JTF_NOTES_PUB.jtf_note_contexts_tbl_type;
Cursor C_Get_Aux_Objects(C_Payload_Id Number)
Is
SELECT HA_PAYLOAD_ID,
       OBJECT_NAME,
       DML_TYPE
From   Csm_Ha_Payload_Data
Where  Parent_Payload_Id = C_Payload_Id
AND    HA_PAYLOAD_ID <> Parent_Payload_Id
ORDER BY HA_PAYLOAD_ID ASC;


BEGIN
  X_Return_Status := Fnd_Api.G_Ret_Sts_Success;
  CSM_UTIL_PKG.LOG('Entering CSM_NOTES_PKG.APPLY_HA_UPDATE for HA ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_NOTES_PKG.APPLY_HA_UPDATE',FND_LOG.LEVEL_PROCEDURE);
  L_Api_Version := 1.0;
   -- get the notes info
--Process Aux Objects (notes TL information
  For R_Get_Aux_Objects In C_Get_Aux_Objects(P_Ha_Payload_Id)  Loop

    CSM_HA_PROCESS_PKG.Parse_Xml(P_Ha_Payload_Id =>R_Get_Aux_Objects.Ha_Payload_Id,
                        X_Col_Name_List  => l_Aux_Name_List,
                        x_COL_VALUE_LIST => l_Aux_Value_List,
                        X_Con_Name_List  => L_CON_NAME_LIST,
                        x_COn_VALUE_LIST => L_CON_VALUE_LIST,
                        X_Return_Status  => L_Return_Status,
                        X_Error_Message  => L_Error_Message);

    IF R_GET_AUX_OBJECTS.OBJECT_NAME = 'JTF_NOTES_TL' THEN
         If  L_Return_Status = Fnd_Api.G_Ret_Sts_Success And  L_Aux_Name_List.Count > 0 Then
          FOR I IN 1..L_AUX_NAME_LIST.COUNT-1 LOOP
            IF L_AUX_NAME_LIST(I) = 'NOTES' THEN
              L_NOTES := L_AUX_VALUE_LIST(I);
            ELSIF L_AUX_NAME_LIST(I) = 'NOTES_DETAIL' THEN
              L_NOTES_DETAIL := L_AUX_VALUE_LIST(I);
            END IF;
          END LOOP;
         END IF;
    END IF;
  END LOOP;


  FOR i in 1..p_COL_NAME_LIST.COUNT-1 LOOP

    IF  p_COL_VALUE_LIST(i) IS NOT NULL THEN

      IF P_COL_NAME_LIST(I) = 'JTF_NOTE_ID' THEN
        Notes_rec.JTF_NOTE_ID := p_COL_VALUE_LIST(i);
      ELSIF  p_COL_NAME_LIST(i) = 'PARENT_NOTE_ID' THEN
        Notes_rec.PARENT_NOTE_ID := p_COL_VALUE_LIST(i);
      ELSIF  p_COL_NAME_LIST(i) = 'SOURCE_OBJECT_ID' THEN
        Notes_rec.SOURCE_OBJECT_ID := p_COL_VALUE_LIST(i);
      ELSIF  p_COL_NAME_LIST(i) = 'SOURCE_OBJECT_CODE' THEN
        Notes_rec.SOURCE_OBJECT_CODE := p_COL_VALUE_LIST(i);
      ELSIF  p_COL_NAME_LIST(i) = 'LAST_UPDATE_DATE' THEN
        Notes_rec.LAST_UPDATE_DATE := p_COL_VALUE_LIST(i);
      ELSIF  p_COL_NAME_LIST(i) = 'LAST_UPDATED_BY' THEN
        Notes_rec.LAST_UPDATED_BY := p_Col_Value_List(I);
      ELSIF  p_COL_NAME_LIST(i) = 'CREATION_DATE' THEN
        Notes_rec.CREATION_DATE := p_COL_VALUE_LIST(i);
      ELSIF  p_COL_NAME_LIST(i) = 'CREATED_BY' THEN
        Notes_rec.CREATED_BY := p_Col_Value_List(I);
      ELSIF  p_COL_NAME_LIST(i) = 'LAST_UPDATE_LOGIN' THEN
        Notes_rec.LAST_UPDATE_LOGIN := p_COL_VALUE_LIST(i);
      ELSIF  p_COL_NAME_LIST(i) = 'NOTE_STATUS' THEN
        Notes_rec.NOTE_STATUS := p_Col_Value_List(I);
      ELSIF  p_COL_NAME_LIST(i) = 'ENTERED_BY' THEN
        Notes_rec.ENTERED_BY := p_Col_Value_List(I);
      ELSIF  p_COL_NAME_LIST(i) = 'ENTERED_DATE' THEN
        Notes_rec.ENTERED_DATE := P_COL_VALUE_LIST(I);
      ELSIF  p_COL_NAME_LIST(i) = 'NOTE_TYPE' THEN
        Notes_rec.NOTE_TYPE := P_COL_VALUE_LIST(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE1' Then
        Notes_rec.ATTRIBUTE1 := p_Col_Value_List(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE2' Then
        Notes_rec.ATTRIBUTE2 := p_Col_Value_List(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE3' Then
        Notes_rec.ATTRIBUTE3 := p_Col_Value_List(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE4' Then
        Notes_rec.ATTRIBUTE4 := p_Col_Value_List(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE5' Then
        Notes_rec.ATTRIBUTE5 := p_Col_Value_List(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE6' Then
        Notes_rec.ATTRIBUTE6 := p_Col_Value_List(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE7' Then
        Notes_rec.ATTRIBUTE7 := p_Col_Value_List(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE8' Then
        Notes_rec.ATTRIBUTE8 := p_Col_Value_List(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE9' Then
        Notes_rec.ATTRIBUTE9 := p_Col_Value_List(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE10' Then
        Notes_rec.ATTRIBUTE10 := p_Col_Value_List(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE11' Then
        Notes_rec.ATTRIBUTE11 := p_Col_Value_List(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE12' Then
        Notes_rec.ATTRIBUTE12 := p_Col_Value_List(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE13' Then
        Notes_rec.ATTRIBUTE13 := p_Col_Value_List(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE14' Then
        Notes_rec.ATTRIBUTE14 := p_Col_Value_List(I);
      Elsif  p_Col_Name_List(I) = 'ATTRIBUTE15' Then
        Notes_rec.ATTRIBUTE15 := p_Col_Value_List(I);
      ELSIF  P_COL_NAME_LIST(I) = 'CONTEXT' THEN
        Notes_rec.CONTEXT := P_COL_VALUE_LIST(I);
      END IF;
    End If;
  END LOOP;

--calling the Notes Public API
JTF_NOTES_PUB.Update_note
(
  P_API_VERSION        => L_API_VERSION
, P_INIT_MSG_LIST      => L_INIT_MSG_LIST
, P_COMMIT             => FND_API.G_FALSE
, P_VALIDATION_LEVEL   => 0.5 --FND_API.G_VALID_LEVEL_FULL
, X_RETURN_STATUS	     => L_RETURN_STATUS
, X_MSG_COUNT		       => L_MSG_COUNT
, X_MSG_DATA		       => L_MSG_DATA
, P_JTF_NOTE_ID        => NOTES_REC.JTF_NOTE_ID
, p_notes              => l_NOTES
, P_NOTES_DETAIL       => l_NOTES_DETAIL
, P_NOTE_STATUS        => Notes_rec.NOTE_STATUS
, P_ENTERED_BY         => NOTES_REC.ENTERED_BY
, P_LAST_UPDATE_DATE   => NOTES_REC.LAST_UPDATE_DATE
, P_LAST_UPDATED_BY    => NOTES_REC.LAST_UPDATED_BY
, P_LAST_UPDATE_LOGIN  => NOTES_REC.LAST_UPDATE_LOGIN
, p_append_flag            => NULL
, P_NOTE_TYPE          => NOTES_REC.NOTE_TYPE
, p_jtf_note_contexts_tab =>L_JTF_NOTE_CONTEXTS_TAB      --not used
);

  IF l_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
    X_Return_Status := Fnd_Api.G_Ret_Sts_Error;
    X_Error_Message := l_Msg_Data;
  ELSE
    X_Return_Status := Fnd_Api.G_Ret_Sts_Success;
  END IF;
  CSM_UTIL_PKG.LOG('Leaving CSM_NOTES_PKG.APPLY_HA_UPDATE for HA ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_NOTES_PKG.APPLY_HA_UPDATE',Fnd_Log.Level_Procedure);

EXCEPTION
  WHEN OTHERS THEN
    X_Return_Status := Fnd_Api.G_Ret_Sts_Error;
    X_Error_Message := L_Msg_Data;
   CSM_UTIL_PKG.LOG('Leaving CSM_NOTES_PKG.APPLY_HA_UPDATE for HA ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_NOTES_PKG.APPLY_HA_UPDATE',FND_LOG.LEVEL_PROCEDURE);

END APPLY_HA_UPDATE;

PROCEDURE APPLY_HA_CHANGES
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

  CSM_UTIL_PKG.LOG('Entering CSM_NOTES_PKG.APPLY_HA_CHANGES for Payload ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_NOTES_PKG.APPLY_HA_CHANGES',FND_LOG.LEVEL_PROCEDURE);

  IF p_dml_type ='I' THEN
    -- Process insert
            APPLY_HA_INSERT
                (p_HA_PAYLOAD_ID  =>p_HA_PAYLOAD_ID,
                p_COL_NAME_LIST  => P_COL_NAME_LIST,
                p_COL_VALUE_LIST => p_COL_VALUE_LIST,
                x_RETURN_STATUS  => l_RETURN_STATUS,
                x_ERROR_MESSAGE  => l_ERROR_MESSAGE
              );
  ELSIF p_dml_type ='U' THEN
    -- Process update
            APPLY_HA_UPDATE
                (p_HA_PAYLOAD_ID  =>p_HA_PAYLOAD_ID,
                p_COL_NAME_LIST  => P_COL_NAME_LIST,
                p_COL_VALUE_LIST => p_COL_VALUE_LIST,
                x_RETURN_STATUS  => l_RETURN_STATUS,
                X_ERROR_MESSAGE  => L_ERROR_MESSAGE
              );
  END IF;
  X_RETURN_STATUS := l_RETURN_STATUS;
  x_ERROR_MESSAGE := l_ERROR_MESSAGE;
  CSM_UTIL_PKG.LOG('Leaving CSM_NOTES_PKG.APPLY_HA_CHANGES for HA ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_NOTES_PKG.APPLY_HA_CHANGES',FND_LOG.LEVEL_PROCEDURE);

EXCEPTION WHEN OTHERS THEN
  CSM_UTIL_PKG.log( 'Exception in CSM_NOTES_PKG.APPLY_HA_CHANGES: ' || sqlerrm
               || ' for HA ID ' || p_HA_PAYLOAD_ID ,'CSM_NOTES_PKG.APPLY_HA_INSERT',FND_LOG.LEVEL_EXCEPTION);
  X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
  X_ERROR_MESSAGE := TO_CHAR(SQLERRM,2000);

END APPLY_HA_CHANGES;

END CSM_NOTES_PKG;

/
