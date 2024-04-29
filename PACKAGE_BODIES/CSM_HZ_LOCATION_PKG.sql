--------------------------------------------------------
--  DDL for Package Body CSM_HZ_LOCATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_HZ_LOCATION_PKG" AS
/* $Header: csmuhzlb.pls 120.0.12010000.5 2010/05/21 10:58:09 trajasek noship $ */

error EXCEPTION;


/*** Globals ***/
g_object_name  CONSTANT VARCHAR2(30) := 'CSM_HZ_LOCATION_PKG';
g_pub_name     CONSTANT VARCHAR2(30) := 'CSM_HZ_LOCATIONS';
g_debug_level           NUMBER; -- debug level

/* Select all inq records */
CURSOR c_hz_location( b_user_name VARCHAR2, b_tranid NUMBER) is
  SELECT *
  FROM  CSM_HZ_LOCATIONS_INQ
  WHERE tranid$$ = b_tranid
  AND   clid$$cs = b_user_name;
/***
  This procedure is called by APPLY_CLIENT_CHANGES when an inserted record is to be processed.
***/
PROCEDURE APPLY_INSERT
         (
           p_record        IN c_hz_location%ROWTYPE,
           p_error_msg     out nocopy    VARCHAR2,
           x_return_status IN out nocopy VARCHAR2
         ) IS

--Variable Declarations
l_object_version_number  NUMBER := 1;
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(4000);
p_location_rec          hz_location_v2pub.location_rec_type;
l_location_id           NUMBER := NULL;

CURSOR c_get_location (c_postal_code VARCHAR2, c_country VARCHAR2)
IS
  SELECT LOCATION_ID FROM HZ_LOCATIONS
  WHERE ADDRESS1 = POSTAL_CODE
  AND   POSTAL_CODE = c_postal_code
  AND   COUNTRY     = c_country;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  CSM_UTIL_PKG.LOG('Entering CSM_HZ_LOCATION_PKG.APPLY_INSERT for Task Assignment Audit ID ' || p_record.LOCATION_ID ,
                         'CSM_HZ_LOCATION_PKG.APPLY_INSERT',FND_LOG.LEVEL_PROCEDURE);

 ---Check if the location with postal code already present for the user
 ---if so then get the location id and update the Task in the INQ with the location id
 OPEN   c_get_location (p_record.postal_code, p_record.country);
 FETCH  c_get_location  INTO l_location_id;
 CLOSE  c_get_location ;

  IF l_location_id IS  NULL THEN
    p_location_rec.location_id            := p_record.location_id;
    p_location_rec.country                := p_record.country;
    p_location_rec.address1               := p_record.address1;
    p_location_rec.address2               := p_record.address2;
    p_location_rec.address3               := p_record.address3;
    p_location_rec.address4               := p_record.address4;
    p_location_rec.city                   := p_record.city;
    p_location_rec.postal_code            := p_record.postal_code;
    p_location_rec.state                  := p_record.state;
    p_location_rec.province               := p_record.province;
    p_location_rec.county                 := p_record.county;
    p_location_rec.address_lines_phonetic := p_record.address_lines_phonetic;
    p_location_rec.created_by_module      := 'CSFDEAR';

    CSM_UTIL_PKG.LOG('Before calling hz_location_v2pub.create_location for Location ID ' || p_record.LOCATION_ID ,
                         'CSM_HZ_LOCATION_PKG.APPLY_INSERT',FND_LOG.LEVEL_EVENT);

  --Call the location API to create a new location record.
   hz_location_v2pub.create_location (
      p_init_msg_list              => FND_API.G_TRUE,
      p_location_rec               => p_location_rec,
      x_location_id                => l_location_id,
      x_return_status              => x_return_status,
      x_msg_count                  => l_msg_count,
      x_msg_data                   => l_msg_data
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        /*** exception occurred in API -> return errmsg ***/
        p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
        (
            p_api_error      => TRUE
        );
        CSM_UTIL_PKG.log( 'Error in ' || g_object_name || '.APPLY_INSERT:'
                   || ' ROOT ERROR: JTF_TASK_ASSIGNMENT_AUDIT_PKG.create_task_assignment_audit ' || sqlerrm
                   || ' for Task Assignment Audit ID ' || p_record.LOCATION_ID,'create_task_assignment_audit.APPLY_INSERT',FND_LOG.LEVEL_ERROR);
       x_return_status := FND_API.G_RET_STS_ERROR;
       RETURN;
    END IF;

  END IF;
  --Update the Task when the location is already present in hz_locations
  IF l_location_id <> p_record.location_id THEN
    UPDATE CSM_TASKS_INQ
    SET    LOCATION_ID = l_location_id
    WHERE  tranid$$    = p_record.tranid$$
    AND   clid$$cs     = p_record.CLID$$CS
    AND   location_id  = p_record.location_id;
  END IF;

  CSM_UTIL_PKG.LOG('Leaving CSM_HZ_LOCATION_PKG.APPLY_INSERT for Task Assignment Audit ID ' || p_record.LOCATION_ID ,
                         'CSM_HZ_LOCATION_PKG.APPLY_INSERT',FND_LOG.LEVEL_PROCEDURE);
  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION WHEN OTHERS THEN
  fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_INSERT', sqlerrm);
     p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
     (
       p_api_error      => TRUE
     );
     CSM_UTIL_PKG.log( 'Exception in ' || g_object_name || '.APPLY_INSERT: ' || sqlerrm
               || ' for Task Assignment Audit ID ' || p_record.LOCATION_ID ,'CSM_HZ_LOCATION_PKG.APPLY_INSERT',FND_LOG.LEVEL_EXCEPTION);

  x_return_status := FND_API.G_RET_STS_ERROR;
END APPLY_INSERT;


/***
  This procedure is called by APPLY_CLIENT_CHANGES for every record in in-queue that needs to be processed.
***/
PROCEDURE APPLY_RECORD
         (
           p_record        IN     c_hz_location%ROWTYPE,
           p_error_msg     out nocopy    VARCHAR2,
           x_return_status IN out nocopy VARCHAR2
         ) IS
  l_rc                    BOOLEAN;
  l_access_id             NUMBER;
BEGIN
  /*** initialize return status and message list ***/
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.INITIALIZE;

  CSM_UTIL_PKG.LOG('Entering CSM_HZ_LOCATION_PKG.APPLY_RECORD for Task Assignment Audit ID ' || p_record.LOCATION_ID ,
                         'CSM_HZ_LOCATION_PKG.APPLY_RECORD',FND_LOG.LEVEL_PROCEDURE);

  IF p_record.dmltype$$='I' THEN
    -- Process insert
    APPLY_INSERT
      (
        p_record,
        p_error_msg,
        x_return_status
      );
  ELSE --Delete and update is not supported for this PI
    -- invalid dml type
      CSM_UTIL_PKG.LOG
        ( 'Invalid DML type: ' || p_record.dmltype$$ || ' is not supported for this entity'
      || ' for Locaton ID ' || p_record.LOCATION_ID ,'CSM_HZ_LOCATION_PKG.APPLY_RECORD',FND_LOG.LEVEL_ERROR);

    p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
      (
        p_message        => 'CSM_DML_OPERATION'
      , p_token_name1    => 'DML'
      , p_token_value1   => p_record.dmltype$$
      );

    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  CSM_UTIL_PKG.LOG('Leaving CSM_HZ_LOCATION_PKG.APPLY_RECORD for Locaton ID ' || p_record.LOCATION_ID ,
                         'CSM_HZ_LOCATION_PKG.APPLY_RECORD',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION WHEN OTHERS THEN
     fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_RECORD', sqlerrm);
     p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
     (
       p_api_error      => TRUE
     );
     CSM_UTIL_PKG.log( 'Exception in ' || g_object_name || '.APPLY_RECORD: ' || sqlerrm
               || ' for Locaton ID ' || p_record.LOCATION_ID ,'CSM_HZ_LOCATION_PKG.APPLY_RECORD',FND_LOG.LEVEL_EXCEPTION);

  x_return_status := FND_API.G_RET_STS_ERROR;

END APPLY_RECORD;

/***
  This procedure is called by CSM_SERVICEP_WRAPPER_PKG when publication item CSM_HZ_LOCATION
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
CSM_UTIL_PKG.LOG('Entering CSM_HZ_LOCATION_PKG.APPLY_CLIENT_CHANGES ',
                         'CSM_HZ_LOCATION_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_PROCEDURE);
  g_debug_level := p_debug_level;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  /*** loop through all the  records in inqueue ***/
  FOR r_hz_location_rec IN c_hz_location( p_user_name, p_tranid) LOOP
    SAVEPOINT save_rec ;
    /*** apply record ***/
    APPLY_RECORD
      (
        r_hz_location_rec
      , l_error_msg
      , l_process_status
      );

    /*** was record processed successfully? ***/
    IF l_process_status = FND_API.G_RET_STS_SUCCESS THEN
      /*** Yes -> Reject record from inqueue ***/
      CSM_UTIL_PKG.DELETE_RECORD
        (
          p_user_name,
          p_tranid,
          r_hz_location_rec.seqno$$,
          r_hz_location_rec.LOCATION_ID,
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
      || ' for Location ID ' || r_hz_location_rec.LOCATION_ID ,'CSM_HZ_LOCATION_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_ERROR); -- put PK column here
        ROLLBACK TO save_rec;
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
    ELSIF l_process_Status <> FND_API.G_RET_STS_SUCCESS THEN
      /*** Record was not applied successfully -> defer and reject records ***/
      csm_util_pkg.log( 'Record not processed successfully, deferring and rejecting record'
      || ' for PK ' || r_hz_location_rec.LOCATION_ID ,'CSM_HZ_LOCATION_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_ERROR); -- put PK column here

      CSM_UTIL_PKG.DEFER_RECORD
       (
         p_user_name
       , p_tranid
       , r_hz_location_rec.seqno$$
       , r_hz_location_rec.LOCATION_ID
       , g_object_name
       , g_pub_name
       , l_error_msg
       , l_process_status
       , r_hz_location_rec.dmltype$$
       );

      /*** Was defer successful? ***/
      IF l_process_status <> FND_API.G_RET_STS_SUCCESS THEN
        /*** no -> rollback ***/
          CSM_UTIL_PKG.LOG
          ( 'Defer record failed, rolling back to savepoint'
          || ' for PK ' || r_hz_location_rec.LOCATION_ID ,'CSM_HZ_LOCATION_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_ERROR); -- put PK column here
        ROLLBACK TO save_rec;
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
    END IF;

  END LOOP;

  CSM_UTIL_PKG.LOG('Leaving CSM_HZ_LOCATION_PKG.APPLY_CLIENT_CHANGES',
                         'CSM_HZ_LOCATION_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_PROCEDURE);

EXCEPTION WHEN OTHERS THEN
  /*** catch and log exceptions ***/
     CSM_UTIL_PKG.log( 'Exception in ' || g_object_name || '.APPLY_CLIENT_CHANGES: ' || sqlerrm
               ,'CSM_HZ_LOCATION_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_EXCEPTION);

  x_return_status := FND_API.G_RET_STS_ERROR;

END APPLY_CLIENT_CHANGES;

Procedure Apply_Ha_Insert
          (P_Ha_Payload_Id   In  Number,
           P_HZL_NAME_LIST   IN  CSM_VARCHAR_LIST,
           p_Hzl_Value_List  In  Csm_Varchar_List,
           p_Hzps_Name_List  In  Csm_Varchar_List,
           p_hzps_VALUE_LIST IN  CSM_VARCHAR_LIST,
           x_RETURN_STATUS  OUT NOCOPY VARCHAR2,
           X_Error_Message  Out Nocopy Varchar2
         )
AS
 --Variable Declarations
   l_location_rec      HZ_LOCATION_V2PUB.LOCATION_REC_TYPE;
   l_location_id       NUMBER;
   l_loc_id            NUMBER;
   l_created_by_module VARCHAR2(150);
   l_application_id    NUMBER;
   l_init_msg_list     VARCHAR2(10);
   l_do_addr_val       VARCHAR2(10);
   l_addr_val_status   VARCHAR2(200);
   l_addr_warn_msg     VARCHAR2(2000);
   -- party site related variables
   l_party_site_rec      HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE;
   l_party_site_id       NUMBER;
   l_party_site_number   VARCHAR2(2000);
   -- common attributes for all return types
   l_return_status       VARCHAR2(1);
   l_msg_count           NUMBER;
   l_msg_data            VARCHAR2(2000);


BEGIN

  X_Return_Status := Fnd_Api.G_Ret_Sts_Success;
  CSM_UTIL_PKG.LOG('Entering CSM_HZ_LOCATION_PKG.APPLY_HA_INSERT for HA PAYLOAD ID ' || P_Ha_Payload_Id ,
                         'CSM_HZ_LOCATION_PKG.APPLY_HA_INSERT',FND_LOG.LEVEL_PROCEDURE);

   L_Created_By_Module                := 'SR_ONETIME';
   -- prepare the location_rec with the values that has been passed in the service_request_rec_type
  FOR I IN 1..P_HZL_NAME_LIST.COUNT-1 LOOP
    IF  P_HZL_NAME_LIST(I) IS NOT NULL THEN
      If p_Hzl_Name_List(I)    = 'LOCATION_ID' Then
         L_Location_Rec.LOCATION_ID         := p_Hzl_Value_List(I);
      Elsif p_Hzl_Name_List(I) = 'ADDRESS1' Then
         L_Location_Rec.Address1            := p_Hzl_Value_List(I);
      Elsif p_Hzl_Name_List(I) = 'ADDRESS2' Then
         L_Location_Rec.Address2            := p_Hzl_Value_List(I);
      Elsif p_Hzl_Name_List(I) = 'ADDRESS3' Then
         L_Location_Rec.Address3            := p_Hzl_Value_List(I);
      Elsif p_Hzl_Name_List(I) = 'ADDRESS4' Then
         L_Location_Rec.Address4            := p_Hzl_Value_List(I);
      Elsif p_Hzl_Name_List(I) = 'CITY' Then
         L_Location_Rec.City                := p_Hzl_Value_List(I);
      Elsif p_Hzl_Name_List(I) = 'STATE' Then
         L_Location_Rec.State               := p_Hzl_Value_List(I);
      Elsif p_Hzl_Name_List(I) = 'POSTAL_CODE' Then
        L_Location_Rec.Postal_Code         := p_Hzl_Value_List(I);
      Elsif p_Hzl_Name_List(I) = 'COUNTY' Then
        L_Location_Rec.County              := p_Hzl_Value_List(I);
      Elsif p_Hzl_Name_List(I) = 'PROVINCE' Then
        L_Location_Rec.Province            := p_Hzl_Value_List(I);
      Elsif p_Hzl_Name_List(I) = 'COUNTRY' Then
        L_Location_Rec.Country             := p_Hzl_Value_List(I);
      Elsif p_Hzl_Name_List(I) = 'CREATED_BY_MODULE' Then
        L_Location_Rec.Created_By_Module   := L_Created_By_Module;
        L_Party_Site_Rec.Created_By_Module := L_Created_By_Module;
      Elsif p_Hzl_Name_List(I) = 'INCIDENT_POSTAL_PLUS4_CODE' Then
        L_Location_Rec.Postal_Plus4_Code   := p_Hzl_Value_List(I);
      Elsif p_Hzl_Name_List(I) = 'INCIDENT_ADDR_LINES_PHONETIC' Then
        L_Location_Rec.Address_Lines_Phonetic := p_Hzl_Value_List(I);
      Elsif p_Hzl_Name_List(I) = 'ADDRESS_KEY' Then
        L_Location_Rec.address_key := p_Hzl_Value_List(I);
      Elsif p_Hzl_Name_List(I) = 'ADDRESS_STYLE' Then
        L_Location_Rec.address_style := p_Hzl_Value_List(I);
      Elsif p_Hzl_Name_List(I) = 'VALIDATED_FLAG' Then
        L_Location_Rec.validated_flag := p_Hzl_Value_List(I);
      End If;
    End If;
  End Loop;

  FOR J IN 1..P_HZPS_NAME_LIST.COUNT-1 LOOP

    IF  P_HZPS_NAME_LIST(J) IS NOT NULL THEN
	  --party_site initialization
      if p_Hzps_Name_List(j) = 'PARTY_ID' Then
          l_party_site_rec.party_id          := p_hzps_VALUE_LIST(j);
      Elsif p_Hzps_Name_List(j) = 'INCIDENT_ADDR_LINES_PHONETIC' Then
          L_Party_Site_Rec.Location_Id       := p_hzps_VALUE_LIST(j);
      Elsif p_Hzps_Name_List(j) = 'SITE_NUMBER' Then
          L_Party_Site_Rec.Party_Site_Number := p_hzps_VALUE_LIST(j);
      Elsif p_Hzps_Name_List(j) = 'SITE_NAME' Then
          L_Party_Site_Rec.Party_Site_Name   := p_hzps_VALUE_LIST(j);
      Elsif p_Hzps_Name_List(j) = 'ADDRESSEE' Then
          L_PARTY_SITE_REC.ADDRESSEE	     := P_HZPS_VALUE_LIST(J);
      Elsif p_Hzps_Name_List(j) = 'PARTY_SITE_ID' Then
          L_PARTY_SITE_REC.PARTY_SITE_ID	     := P_HZPS_VALUE_LIST(J);
      End If;
    End If;
  End Loop;


   IF (fnd_profile.value('CS_SR_VALIDATE_ONE_TIME_ADDRESS_AGAINST_TCA_GEOGRAPHY') = 'Y') THEN
	l_do_addr_val := 'Y';
   else
	l_do_addr_val := 'N';
   END IF;
  --starting transaction
   SAVEPOINT SAVE_HZ_LOCATION_REC ;

   HZ_LOCATION_V2PUB.create_location (
     p_init_msg_list     => FND_API.G_FALSE,
     p_location_rec      => l_location_rec,
     p_do_addr_val       => l_do_addr_val,
     x_location_id       => l_location_id,
     x_addr_val_status   => l_addr_val_status,
     x_addr_warn_msg     => l_addr_warn_msg,
     x_return_status     => l_return_status,
     x_msg_count         => l_msg_count,
     x_msg_data          => l_msg_data
     );
     --if location has been created successfully then create party_site
     --if party_site creation fails then roll back all the way to create_onetime_address;
     If l_return_status = FND_API.G_RET_STS_SUCCESS Then

          X_Error_Message      := l_msg_data;
	  --party_site initialization
          L_Party_Site_Rec.Location_Id       := L_Location_Id;
      	  l_party_site_rec.identifying_address_flag := 'N';
          l_party_site_rec.status := 'I';

          -- Create the party site
          HZ_PARTY_SITE_V2PUB.CREATE_PARTY_SITE(
            p_init_msg_list      => l_init_msg_list,
            p_party_site_rec     => l_party_site_rec,
            x_party_site_id      => l_party_site_id,
            x_party_site_number  => l_party_site_number,
            x_return_status      => l_return_status,
            x_msg_count          => l_msg_count,
            x_msg_data           => l_msg_data
	    );

      	 If L_Return_Status = Fnd_Api.G_Ret_Sts_Success Then
              --  x_location_id   := l_party_site_id;
                X_RETURN_STATUS := L_RETURN_STATUS;
                COMMIT;
         elsif l_return_status <> FND_API.G_RET_STS_SUCCESS Then
              X_Return_Status := L_Return_Status;
              X_ERROR_MESSAGE:= L_MSG_DATA;
             ROLLBACK TO SAVE_HZ_LOCATION_REC;
         End If;
    ELSE
        ROLLBACK TO SAVE_HZ_LOCATION_REC;
    END IF;
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_Ret_Sts_Error;
    X_ERROR_MESSAGE := L_MSG_DATA;
    ROLLBACK TO SAVE_HZ_LOCATION_REC;
   CSM_UTIL_PKG.LOG('Leaving CSM_HZ_LOCATION_PKG.APPLY_HA_INSERT for HA Payload ID ' || P_Ha_Payload_Id ,
                         'CSM_HZ_LOCATION_PKG.APPLY_HA_INSERT',FND_LOG.LEVEL_PROCEDURE);

END APPLY_HA_INSERT;

Procedure APPLY_HA_UPDATE
          (P_Ha_Payload_Id   In  Number,
           p_Hzl_Name_List   In  Csm_Varchar_List,
           p_Hzl_Value_List  In  Csm_Varchar_List,
           P_HZPS_NAME_LIST  IN   CSM_VARCHAR_LIST,
           P_HZPS_VALUE_LIST IN  CSM_VARCHAR_LIST,
           X_RETURN_STATUS  OUT NOCOPY VARCHAR2,
           X_Error_Message  Out Nocopy Varchar2
         )
AS
 --Variable Declarations
   l_location_rec      HZ_LOCATION_V2PUB.LOCATION_REC_TYPE;
   l_location_id       NUMBER;
   l_loc_id            NUMBER;
   l_created_by_module VARCHAR2(150);
   l_application_id    NUMBER;
   l_init_msg_list     VARCHAR2(10);
   l_do_addr_val       VARCHAR2(10);
   l_addr_val_status   VARCHAR2(200);
   l_addr_warn_msg     VARCHAR2(2000);
   -- party site related variables
   l_party_site_rec      HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE;
   l_party_site_id       NUMBER;
   l_party_site_number   VARCHAR2(2000);
   -- common attributes for all return types
   l_return_status       VARCHAR2(1);
   l_msg_count           NUMBER;
   l_msg_data            VARCHAR2(2000);

   L_LOC_OBJECT_VERSION_NUMBER NUMBER;
   L_PS_OBJECT_VERSION_NUMBER NUMBER;

CURSOR C_GET_LOC_VERSION( B_LOCATION_ID NUMBER)
IS
   SELECT OBJECT_VERSION_NUMBER
   FROM   HZ_LOCATIONS
   WHERE  LOCATION_ID = B_LOCATION_ID;

CURSOR C_GET_PS_VERSION( B_PARTY_SITE_ID NUMBER)
IS
   SELECT OBJECT_VERSION_NUMBER
   FROM   HZ_PARTY_SITES
   WHERE  PARTY_SITE_ID = B_PARTY_SITE_ID;


BEGIN

  X_Return_Status := Fnd_Api.G_Ret_Sts_Success;
  CSM_UTIL_PKG.LOG('Entering CSM_HZ_LOCATION_PKG.APPLY_HA_UPDATE for HA PAYLOAD ID ' || P_Ha_Payload_Id ,
                         'CSM_HZ_LOCATION_PKG.APPLY_HA_UPDATE',FND_LOG.LEVEL_PROCEDURE);

   L_Created_By_Module                := 'SR_ONETIME';
   -- prepare the location_rec with the values that has been passed in the service_request_rec_type
  For I In 1..p_Hzl_Name_List.Count-1 Loop
    If  p_Hzl_Name_List(I) Is Not Null Then
      If p_Hzl_Name_List(I)    = 'LOCATION_ID' Then
         L_Location_Rec.LOCATION_ID         := p_Hzl_Value_List(I);
      Elsif p_Hzl_Name_List(I) = 'ADDRESS1' Then
         L_Location_Rec.Address1            := p_Hzl_Value_List(I);
      Elsif p_Hzl_Name_List(I) = 'ADDRESS2' Then
         L_Location_Rec.Address2            := p_Hzl_Value_List(I);
      Elsif p_Hzl_Name_List(I) = 'ADDRESS3' Then
         L_Location_Rec.Address3            := p_Hzl_Value_List(I);
      Elsif p_Hzl_Name_List(I) = 'ADDRESS4' Then
         L_Location_Rec.Address4            := p_Hzl_Value_List(I);
      Elsif p_Hzl_Name_List(I) = 'CITY' Then
         L_Location_Rec.City                := p_Hzl_Value_List(I);
      Elsif p_Hzl_Name_List(I) = 'STATE' Then
         L_Location_Rec.State               := p_Hzl_Value_List(I);
      Elsif p_Hzl_Name_List(I) = 'POSTAL_CODE' Then
        L_Location_Rec.Postal_Code         := p_Hzl_Value_List(I);
      Elsif p_Hzl_Name_List(I) = 'COUNTY' Then
        L_Location_Rec.County              := p_Hzl_Value_List(I);
      Elsif p_Hzl_Name_List(I) = 'PROVINCE' Then
        L_Location_Rec.Province            := p_Hzl_Value_List(I);
      Elsif p_Hzl_Name_List(I) = 'COUNTRY' Then
        L_Location_Rec.Country             := p_Hzl_Value_List(I);
      Elsif p_Hzl_Name_List(I) = 'CREATED_BY_MODULE' Then
        L_Location_Rec.Created_By_Module   := L_Created_By_Module;
        L_Party_Site_Rec.Created_By_Module := L_Created_By_Module;
      Elsif p_Hzl_Name_List(I) = 'INCIDENT_POSTAL_PLUS4_CODE' Then
        L_Location_Rec.Postal_Plus4_Code   := p_Hzl_Value_List(I);
      Elsif p_Hzl_Name_List(I) = 'INCIDENT_ADDR_LINES_PHONETIC' Then
        L_Location_Rec.Address_Lines_Phonetic := p_Hzl_Value_List(I);
      Elsif p_Hzl_Name_List(I) = 'ADDRESS_KEY' Then
        L_Location_Rec.address_key := p_Hzl_Value_List(I);
      Elsif p_Hzl_Name_List(I) = 'ADDRESS_STYLE' Then
        L_Location_Rec.address_style := p_Hzl_Value_List(I);
      Elsif p_Hzl_Name_List(I) = 'VALIDATED_FLAG' Then
        L_LOCATION_REC.VALIDATED_FLAG := p_Hzl_Value_List(I);
      Elsif p_Hzl_Name_List(I) = 'OBJECT_VERSION_NUMBER' Then
        l_loc_object_version_number := p_Hzl_Value_List(I);
      END IF;

    End If;
  End Loop;

  For j In 1..p_Hzps_Name_List.Count-1 Loop
    If  p_Hzps_Name_List(j) Is Not Null Then
	  --party_site initialization
      if p_Hzps_Name_List(j) = 'PARTY_SITE_ID' Then
          L_PARTY_SITE_REC.PARTY_SITE_ID    := P_HZPS_VALUE_LIST(J);
      ELSif p_Hzps_Name_List(j) = 'PARTY_ID' Then
          l_party_site_rec.party_id          := p_hzps_VALUE_LIST(j);
      Elsif p_Hzps_Name_List(j) = 'INCIDENT_ADDR_LINES_PHONETIC' Then
          L_Party_Site_Rec.Location_Id       := p_hzps_VALUE_LIST(j);
      Elsif p_Hzps_Name_List(j) = 'SITE_NUMBER' Then
          L_Party_Site_Rec.Party_Site_Number := p_hzps_VALUE_LIST(j);
      Elsif p_Hzps_Name_List(j) = 'SITE_NAME' Then
          L_Party_Site_Rec.Party_Site_Name   := p_hzps_VALUE_LIST(j);
      Elsif p_Hzps_Name_List(j) = 'ADDRESSEE' Then
          L_PARTY_SITE_REC.ADDRESSEE	     := p_hzps_VALUE_LIST(J);
      Elsif p_Hzps_Name_List(j) = 'LOCATION_ID' Then
          l_party_site_rec.Location_Id	     := p_hzps_VALUE_LIST(j);
      Elsif p_Hzps_Name_List(j) = 'IDENTIFYING_ADDRESS_FLAG' Then
          L_PARTY_SITE_REC.IDENTIFYING_ADDRESS_FLAG	     := p_hzps_VALUE_LIST(J);
      Elsif p_Hzps_Name_List(j) = 'STATUS' Then
          L_PARTY_SITE_REC.STATUS	     := P_HZPS_VALUE_LIST(J);
      ELSIF p_Hzps_Name_List(J) = 'OBJECT_VERSION_NUMBER' THEN
        l_ps_object_version_number := P_HZPS_VALUE_LIST(j);
      END IF;
    End If;
  END LOOP;

  --Get the Latest Version number from the DB
  OPEN  C_GET_LOC_VERSION( L_LOCATION_REC.LOCATION_ID );
  FETCH C_GET_LOC_VERSION INTO L_LOC_OBJECT_VERSION_NUMBER;
  CLOSE C_GET_LOC_VERSION;

  OPEN  C_GET_PS_VERSION( L_PARTY_SITE_REC.PARTY_SITE_ID );
  FETCH C_GET_PS_VERSION INTO L_PS_OBJECT_VERSION_NUMBER;
  CLOSE C_GET_PS_VERSION;

  SAVEPOINT SAVE_HZ_LOCATION_REC ;
      -- UPDATE the party site
      HZ_PARTY_SITE_V2PUB.UPDATE_PARTY_SITE(
        p_init_msg_list      => l_init_msg_list,
        P_PARTY_SITE_REC     => L_PARTY_SITE_REC,
        p_object_version_number => l_ps_object_version_number,
        x_return_status      => l_return_status,
        x_msg_count          => l_msg_count,
        x_msg_data           => l_msg_data
    );

   IF (fnd_profile.value('CS_SR_VALIDATE_ONE_TIME_ADDRESS_AGAINST_TCA_GEOGRAPHY') = 'Y') THEN
	l_do_addr_val := 'Y';
   else
	l_do_addr_val := 'N';
   END IF;

     --if location has been created successfully then create party_site
     --if party_site creation fails then roll back all the way to create_onetime_address;
    If l_return_status = FND_API.G_RET_STS_SUCCESS Then

	  --party_site initialization
     HZ_LOCATION_V2PUB.update_location (
      p_init_msg_list     => FND_API.G_FALSE,
      p_location_rec      => l_location_rec,
      P_DO_ADDR_VAL       => L_DO_ADDR_VAL,
      p_object_version_number => l_loc_object_version_number,
      x_addr_val_status   => l_addr_val_status,
      x_addr_warn_msg     => l_addr_warn_msg,
      x_return_status     => l_return_status,
      x_msg_count         => l_msg_count,
      x_msg_data          => l_msg_data
      );

       IF L_RETURN_STATUS = FND_API.G_RET_STS_SUCCESS THEN
            --  x_location_id   := l_party_site_id;
              X_RETURN_STATUS := L_RETURN_STATUS;
              COMMIT;
       ELSIF L_RETURN_STATUS <> FND_API.G_RET_STS_SUCCESS THEN
            ROLLBACK TO SAVE_HZ_LOCATION_REC;
            X_Return_Status := L_Return_Status;
            X_Error_Message:= l_msg_data;
       END IF;
    ELSE
        ROLLBACK TO SAVE_HZ_LOCATION_REC;
    END IF;

EXCEPTION
  WHEN OTHERS THEN
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    X_ERROR_MESSAGE := L_MSG_DATA;
    ROLLBACK TO SAVE_HZ_LOCATION_REC ;
   CSM_UTIL_PKG.LOG('Leaving CSM_HZ_LOCATION_PKG.APPLY_HA_UPDATE for HA Payload ID ' || P_Ha_Payload_Id ,
                         'CSM_HZ_LOCATION_PKG.APPLY_HA_UPDATE',FND_LOG.LEVEL_PROCEDURE);

END APPLY_HA_UPDATE;

Procedure APPLY_HA_CHANGES
          (P_Ha_Payload_Id   In  Number,
           p_Hzl_Name_List   In  Csm_Varchar_List,
           p_Hzl_Value_List  In  Csm_Varchar_List,
           p_Hzps_Name_List  In  Csm_Varchar_List,
           p_HZPS_VALUE_LIST IN  CSM_VARCHAR_LIST,
           p_dml_type        IN  VARCHAR2,
           X_Return_Status   Out Nocopy Varchar2,
           X_Error_Message   Out Nocopy Varchar2
         )IS
L_RETURN_STATUS  VARCHAR2(100);
L_ERROR_MESSAGE  VARCHAR2(4000);

BEGIN
  /*** initialize return status and message list ***/
  L_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.INITIALIZE;

  CSM_UTIL_PKG.LOG('Entering CSM_SERVICE_REQUESTS_PKG.APPLY_HA_CHANGES for Payload ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_SERVICE_REQUESTS_PKG.APPLY_HA_CHANGES',FND_LOG.LEVEL_PROCEDURE);

  IF p_dml_type ='I' THEN
    -- Process insert
            APPLY_HA_INSERT
          (P_Ha_Payload_Id   =>p_HA_PAYLOAD_ID,
           p_Hzl_Name_List   => p_Hzl_Name_List,
           p_Hzl_Value_List  => p_Hzl_Value_List,
           P_HZPS_NAME_LIST  => p_Hzps_Name_List,
           P_HZPS_VALUE_LIST => p_HZPS_VALUE_LIST,
           X_RETURN_STATUS   => L_RETURN_STATUS,
           X_ERROR_MESSAGE   => L_ERROR_MESSAGE
         );
  ELSIF p_dml_type ='U' THEN
    -- Process update
      APPLY_HA_UPDATE
          (P_Ha_Payload_Id   =>p_HA_PAYLOAD_ID,
           p_Hzl_Name_List   => p_Hzl_Name_List,
           p_Hzl_Value_List  => p_Hzl_Value_List,
           P_HZPS_NAME_LIST  => p_Hzps_Name_List,
           P_HZPS_VALUE_LIST => p_HZPS_VALUE_LIST,
           X_RETURN_STATUS   => L_RETURN_STATUS,
           X_ERROR_MESSAGE   => L_ERROR_MESSAGE
         );
  END IF;
  X_RETURN_STATUS := l_RETURN_STATUS;
  x_ERROR_MESSAGE := l_ERROR_MESSAGE;
  CSM_UTIL_PKG.LOG('Leaving CSM_SERVICE_REQUESTS_PKG.APPLY_HA_CHANGES for HA ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_SERVICE_REQUESTS_PKG.APPLY_HA_CHANGES',FND_LOG.LEVEL_PROCEDURE);

EXCEPTION WHEN OTHERS THEN
  CSM_UTIL_PKG.log( 'Exception in CSM_SERVICE_REQUESTS_PKG.APPLY_HA_CHANGES: ' || sqlerrm
               || ' for HA ID ' || p_HA_PAYLOAD_ID ,'CSM_SERVICE_REQUESTS_PKG.APPLY_HA_INSERT',FND_LOG.LEVEL_EXCEPTION);
  X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
  X_ERROR_MESSAGE := TO_CHAR(SQLERRM,2000);

END APPLY_HA_CHANGES;

END CSM_HZ_LOCATION_PKG;

/
