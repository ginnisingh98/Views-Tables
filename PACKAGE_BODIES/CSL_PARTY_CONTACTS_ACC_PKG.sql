--------------------------------------------------------
--  DDL for Package Body CSL_PARTY_CONTACTS_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSL_PARTY_CONTACTS_ACC_PKG" AS
/* $Header: cslpcacb.pls 120.1 2005/08/31 02:56:26 utekumal noship $ */

g_debug_level           NUMBER;  -- debug level

/**
 *
 */
PROCEDURE INSERT_CONTACT_POINT( p_contact_point_id IN NUMBER
                              , p_resource_id IN NUMBER )
IS
 l_table_name            CONSTANT VARCHAR2(30) := 'HZ_CONTACT_POINTS';
 l_acc_table_name        CONSTANT VARCHAR2(30) := 'CSL_HZ_CONTACT_POINTS_ACC';
 l_pk1_name              CONSTANT VARCHAR2(30) := 'CONTACT_POINT_ID';
 l_publication_item_name CONSTANT JTM_HOOK_UTIL_PKG.t_publication_item_list :=
      JTM_HOOK_UTIL_PKG.t_publication_item_list('CSL_HZ_CONTACT_POINTS');

BEGIN
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_contact_point_id
    , l_table_name
    , 'Entering INSERT_CONTACT_POINT'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
     jtm_message_log_pkg.Log_Msg
      ( p_contact_point_id
      , l_table_name
      , 'Inserting ACC record for resource_id = '||p_resource_id
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  JTM_HOOK_UTIL_PKG.Insert_Acc
     ( P_PUBLICATION_ITEM_NAMES => l_publication_item_name
     , P_ACC_TABLE_NAME         => l_acc_table_name
     , P_PK1_NAME               => l_pk1_name
     , P_PK1_NUM_VALUE          => p_contact_point_id
     , P_RESOURCE_ID            => p_resource_id
     );

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_contact_point_id
    , l_table_name
    , 'Leaving INSERT_CONTACT_POINT'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
END INSERT_CONTACT_POINT;

/**
 *
 */
PROCEDURE DELETE_CONTACT_POINT( p_contact_point_id IN NUMBER
                              , p_resource_id IN NUMBER )
IS
 l_table_name            CONSTANT VARCHAR2(30) := 'HZ_CONTACT_POINTS';
 l_acc_table_name        CONSTANT VARCHAR2(30) := 'CSL_HZ_CONTACT_POINTS_ACC';
 l_pk1_name              CONSTANT VARCHAR2(30) := 'CONTACT_POINT_ID';
 l_publication_item_name CONSTANT JTM_HOOK_UTIL_PKG.t_publication_item_list :=
      JTM_HOOK_UTIL_PKG.t_publication_item_list('CSL_HZ_CONTACT_POINTS');
BEGIN
 IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_contact_point_id
    , l_table_name
    , 'Entering DELETE_CONTACT_POINT'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  JTM_HOOK_UTIL_PKG.Delete_Acc
     (  P_PUBLICATION_ITEM_NAMES => l_publication_item_name
      , P_ACC_TABLE_NAME         => l_acc_table_name
      , P_PK1_NAME               => l_pk1_name
      , P_PK1_NUM_VALUE          => p_contact_point_id
      , P_RESOURCE_ID            => p_resource_id
     );

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_contact_point_id
    , l_table_name
    , 'Leaving DELETE_CONTACT_POINT'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

END DELETE_CONTACT_POINT;

/**
 *
 */
PROCEDURE INSERT_HZ_RELATIONSHIP( p_party_id IN NUMBER
                                , p_resource_id IN NUMBER )
IS
 l_table_name            CONSTANT VARCHAR2(30) := 'HZ_RELATIONSHIPS';
 l_acc_table_name        CONSTANT VARCHAR2(30) := 'CSL_HZ_RELATIONSHIPS_ACC';
 l_pk1_name              CONSTANT VARCHAR2(30) := 'RELATIONSHIP_ID';
 l_pk2_name              CONSTANT VARCHAR2(30) := 'DIRECTIONAL_FLAG';
 l_publication_item_name CONSTANT JTM_HOOK_UTIL_PKG.t_publication_item_list :=
      JTM_HOOK_UTIL_PKG.t_publication_item_list('CSL_HZ_RELATIONSHIPS');


 CURSOR c_relationship( b_party_id NUMBER )
 IS
   SELECT *
   FROM HZ_RELATIONSHIPS
   WHERE PARTY_ID = b_party_id
   AND DIRECTIONAL_FLAG = 'F';

 r_relationship c_relationship%ROWTYPE;

BEGIN
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_party_id
    , l_table_name
    , 'Entering INSERT_HZ_RELATIONSHIP'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  OPEN c_relationship( p_party_id );
  FETCH c_relationship INTO r_relationship;
  IF c_relationship%FOUND THEN
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
       jtm_message_log_pkg.Log_Msg
        ( r_relationship.relationship_id
        , l_table_name
        , 'Inserting ACC record for resource_id = '||p_resource_id
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
     END IF;

    JTM_HOOK_UTIL_PKG.Insert_Acc
       ( P_PUBLICATION_ITEM_NAMES => l_publication_item_name
       , P_ACC_TABLE_NAME         => l_acc_table_name
       , P_PK1_NAME               => l_pk1_name
       , P_PK1_NUM_VALUE          => r_relationship.relationship_id
       , P_PK2_NAME               => l_pk2_name
       , p_PK2_CHAR_VALUE         => 'F'
       , P_RESOURCE_ID            => p_resource_id
       );

    /*Call the party of this relation*/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
       jtm_message_log_pkg.Log_Msg
       ( r_relationship.SUBJECT_ID
       , l_table_name
       , 'Calling the party for this relationship'
       , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;
    CSL_HZ_PARTIES_ACC_PKG.INSERT_PARTY( r_relationship.SUBJECT_ID, p_resource_id );
  ELSE
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
       jtm_message_log_pkg.Log_Msg
        ( p_party_id
        , l_table_name
        , 'Could not find Relationship record'
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;
  END IF;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_party_id
    , l_table_name
    , 'Leaving INSERT_HZ_RELATIONSHIP'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
END INSERT_HZ_RELATIONSHIP;

/**
 *
 */
PROCEDURE DELETE_HZ_RELATIONSHIP( p_party_id IN NUMBER
                                , p_resource_id IN NUMBER )
IS
 l_table_name            CONSTANT VARCHAR2(30) := 'HZ_RELATIONSHIPS';
 l_acc_table_name        CONSTANT VARCHAR2(30) := 'CSL_HZ_RELATIONSHIPS_ACC';
 l_pk1_name              CONSTANT VARCHAR2(30) := 'RELATIONSHIP_ID';
 l_pk2_name              CONSTANT VARCHAR2(30) := 'DIRECTIONAL_FLAG';
 l_publication_item_name CONSTANT JTM_HOOK_UTIL_PKG.t_publication_item_list :=
      JTM_HOOK_UTIL_PKG.t_publication_item_list('CSL_HZ_RELATIONSHIPS');

 CURSOR c_relationship( b_party_id NUMBER )
 IS
   SELECT *
   FROM HZ_RELATIONSHIPS
   WHERE PARTY_ID = b_party_id
   AND DIRECTIONAL_FLAG = 'F';

 r_relationship c_relationship%ROWTYPE;

BEGIN
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_party_id
    , l_table_name
    , 'Entering DELETE_HZ_RELATIONSHIP'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  OPEN c_relationship( p_party_id );
  FETCH c_relationship INTO r_relationship;
  IF c_relationship%FOUND THEN

    JTM_HOOK_UTIL_PKG.Delete_Acc
       (  P_PUBLICATION_ITEM_NAMES => l_publication_item_name
        , P_ACC_TABLE_NAME         => l_acc_table_name
        , P_PK1_NAME               => l_pk1_name
        , P_PK1_NUM_VALUE          => p_party_id
        , P_PK2_NAME               => l_pk2_name
        , P_PK2_CHAR_VALUE         => 'F'
        , P_RESOURCE_ID            => p_resource_id
       );

    /*Delete the matching party*/
    CSL_HZ_PARTIES_ACC_PKG.INSERT_PARTY( r_relationship.SUBJECT_ID, p_resource_id );
  END IF;
  CLOSE c_relationship;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_party_id
    , l_table_name
    , 'Leaving DELETE_HZ_RELATIONSHIP'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
END DELETE_HZ_RELATIONSHIP;

/**
 *
 */
PROCEDURE INSERT_CS_HZ_SR_CONTACTS( p_incident_id IN NUMBER
                                  , p_resource_id IN NUMBER
				  , p_flow_type   IN NUMBER )--DEFAULT CSL_CS_INCIDENTS_ALL_ACC_PKG.G_FLOW_NORMAL)
IS
 CURSOR c_contacts( b_incident_id NUMBER
                  , b_resource_id NUMBER)
 IS
  SELECT CHS.*
  FROM CS_HZ_SR_CONTACT_POINTS CHS
  WHERE CHS.INCIDENT_ID =  b_incident_id
  AND   CHS.SR_CONTACT_POINT_ID NOT IN (
    SELECT CCA.SR_CONTACT_POINT_ID
    FROM CSL_CS_HZ_SR_CONTACT_PTS_ACC CCA
    WHERE  CCA.RESOURCE_ID = b_resource_id
  );

 CURSOR c_obsolete_contacts( b_incident_id NUMBER
                           , b_resource_id NUMBER)
 IS
  SELECT CCA.*
  FROM CSL_CS_HZ_SR_CONTACT_PTS_ACC CCA
  WHERE CCA.RESOURCE_ID = b_resource_id
  AND CCA.SR_CONTACT_POINT_ID NOT IN (
    SELECT CHS.SR_CONTACT_POINT_ID
    FROM CS_HZ_SR_CONTACT_POINTS CHS
    --WHERE CHS.INCIDENT_ID =  b_incident_id
  );

 /*Each procedure has its own set of constants*/
 l_table_name            CONSTANT VARCHAR2(30) := 'CS_HZ_SR_CONTACT_POINTS';
 l_acc_table_name        CONSTANT VARCHAR2(30) := 'CSL_CS_HZ_SR_CONTACT_PTS_ACC';
 l_pk1_name              CONSTANT VARCHAR2(30) := 'SR_CONTACT_POINT_ID';
 l_publication_item_name CONSTANT JTM_HOOK_UTIL_PKG.t_publication_item_list :=
      JTM_HOOK_UTIL_PKG.t_publication_item_list('CSL_CS_HZ_SR_CONTACT_PTS');
BEGIN
  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_incident_id
    , l_table_name
    , 'Entering INSERT_CS_HZ_SR_CONTACTS'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*** Insert contact point ACC record ***/
  FOR r_contact IN c_contacts( b_incident_id => p_incident_id, b_resource_id => p_resource_id ) LOOP
   IF p_flow_type = CSL_CS_INCIDENTS_ALL_ACC_PKG.G_FLOW_NORMAL OR (
      p_flow_type = CSL_CS_INCIDENTS_ALL_ACC_PKG.G_FLOW_HISTORY AND
      r_contact.PRIMARY_FLAG = 'Y' ) THEN
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( r_contact.SR_CONTACT_POINT_ID
      , l_table_name
      , 'Inserting ACC record for resource_id = '||p_resource_id
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

   JTM_HOOK_UTIL_PKG.Insert_Acc
       ( P_PUBLICATION_ITEM_NAMES => l_publication_item_name
       , P_ACC_TABLE_NAME         => l_acc_table_name
       , P_PK1_NAME               => l_pk1_name
       , P_PK1_NUM_VALUE          => r_contact.SR_CONTACT_POINT_ID
       , P_RESOURCE_ID            => p_resource_id
       );


   /*Insert the contact point record*/
   IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( r_contact.SR_CONTACT_POINT_ID
      , l_table_name
      , 'Calling Insert_Contact_point for contact'||r_contact.CONTACT_POINT_ID
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
   END IF;
   IF r_contact.CONTACT_POINT_ID IS NOT NULL THEN
     /*Insert the contact point record*/
     INSERT_CONTACT_POINT( r_contact.CONTACT_POINT_ID, p_resource_id );
   END IF;

      /*Get the matching record ( party / party relation / employee or organization */
      IF r_contact.CONTACT_TYPE = 'PERSON' THEN
        -- Call procedure for hz_parties
        IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
           jtm_message_log_pkg.Log_Msg
           ( r_contact.SR_CONTACT_POINT_ID
           , l_table_name
           , 'Contact is of type ''PERSON'''||fnd_global.local_chr(10)||
	     'Calling the CSL_HZ_PARTIES_ACC_PKG.INSERT_PARTY'
           , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
        END IF;
        CSL_HZ_PARTIES_ACC_PKG.INSERT_PARTY( r_contact.PARTY_ID , p_resource_id );
      END IF; --PERSON

      IF r_contact.CONTACT_TYPE = 'PARTY_RELATIONSHIP' THEN
        -- Call procedure for hz_party_relation_ships
        IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
           jtm_message_log_pkg.Log_Msg
           ( r_contact.SR_CONTACT_POINT_ID
           , l_table_name
           , 'Contact is of type ''PARTY_RELATIONSHIP'''||fnd_global.local_chr(10)||
	     'Calling INSERT_HZ_RELATIONSHIP'
           , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
        END IF;
        INSERT_HZ_RELATIONSHIP( r_contact.PARTY_ID, p_resource_id );
      END IF; --PARTY_RELATIONSHIP

      IF r_contact.CONTACT_TYPE = 'EMPLOYEE' THEN
        -- Call procedure for per_all_people_f
        IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
           jtm_message_log_pkg.Log_Msg
           ( r_contact.SR_CONTACT_POINT_ID
           , l_table_name
           , 'Contact is of type ''EMPLOYEE'''||fnd_global.local_chr(10)||
	     'Calling INSERT_PER_ALL_PEOPLE_F'
           , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
        END IF;
        INSERT_PER_ALL_PEOPLE_F( r_contact.PARTY_ID, p_resource_id );
      END IF; --EMPLOYEE

      IF r_contact.CONTACT_TYPE = 'ORGANIZATION' THEN
        -- Call procedure for ...
        IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
           jtm_message_log_pkg.Log_Msg
           ( r_contact.SR_CONTACT_POINT_ID
           , l_table_name
           , 'Contact is of type ''ORGANIZATION'''||fnd_global.local_chr(10)||
	     'Call to be implemented'
           , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
        END IF;
        NULL;
      END IF; --ORGANIZATION
    END IF; --Flow check
  END LOOP;

  /*Delete all contacts in the acc table for this incident that are no longer valid*/
  FOR r_obsolete IN c_obsolete_contacts( b_incident_id => p_incident_id, b_resource_id => p_resource_id ) LOOP
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
       jtm_message_log_pkg.Log_Msg
       ( r_obsolete.SR_CONTACT_POINT_ID
       , l_table_name
       , 'Deleting contact record '||r_obsolete.SR_CONTACT_POINT_ID||fnd_global.local_chr(10)||
         'for resource '||p_resource_id
       , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

    JTM_HOOK_UTIL_PKG.Delete_Acc
     (  P_PUBLICATION_ITEM_NAMES => l_publication_item_name
      , P_ACC_TABLE_NAME         => l_acc_table_name
      , P_PK1_NAME               => l_pk1_name
      , P_PK1_NUM_VALUE          => r_obsolete.SR_CONTACT_POINT_ID
      , P_RESOURCE_ID            => p_resource_id
     );

 END LOOP;

  /*Done, all packages are called*/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_incident_id
    , l_table_name
    , 'Leaving INSERT_CS_HZ_SR_CONTACTS'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
END INSERT_CS_HZ_SR_CONTACTS;

/**
 *
 */
PROCEDURE DELETE_CS_HZ_SR_CONTACTS( p_incident_id IN NUMBER
                                  , p_resource_id IN NUMBER
				  , p_flow_type   IN NUMBER ) --DEFAULT CSL_CS_INCIDENTS_ALL_ACC_PKG.G_FLOW_NORMAL)
IS
 l_table_name            CONSTANT VARCHAR2(30) := 'CS_HZ_SR_CONTACT_POINTS';
 l_acc_table_name        CONSTANT VARCHAR2(30) := 'CSL_CS_HZ_SR_CONTACT_PTS_ACC';
 l_pk1_name              CONSTANT VARCHAR2(30) := 'SR_CONTACT_POINT_ID';
 l_publication_item_name CONSTANT JTM_HOOK_UTIL_PKG.t_publication_item_list :=
      JTM_HOOK_UTIL_PKG.t_publication_item_list('CSL_CS_HZ_SR_CONTACT_PTS');

 CURSOR c_contacts( b_incident_id NUMBER
                  , b_resource_id NUMBER)
 IS
  SELECT CHS.*
  FROM CS_HZ_SR_CONTACT_POINTS CHS
  WHERE CHS.INCIDENT_ID =  b_incident_id
  AND   CHS.SR_CONTACT_POINT_ID IN (
    SELECT CCA.SR_CONTACT_POINT_ID
    FROM CSL_CS_HZ_SR_CONTACT_PTS_ACC CCA
    WHERE  CCA.RESOURCE_ID = b_resource_id
  );

BEGIN
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_incident_id
    , l_table_name
    , 'Entering DELETE_CS_HZ_SR_CONTACTS'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  FOR r_contact IN c_contacts( b_incident_id => p_incident_id, b_resource_id => p_resource_id ) LOOP
   IF p_flow_type = CSL_CS_INCIDENTS_ALL_ACC_PKG.G_FLOW_NORMAL OR (
      p_flow_type = CSL_CS_INCIDENTS_ALL_ACC_PKG.G_FLOW_HISTORY AND
      r_contact.PRIMARY_FLAG = 'Y' ) THEN

     /*Delete the records from incident-contact mapping table*/
      JTM_HOOK_UTIL_PKG.Delete_Acc
       (  P_PUBLICATION_ITEM_NAMES => l_publication_item_name
        , P_ACC_TABLE_NAME         => l_acc_table_name
        , P_PK1_NAME               => l_pk1_name
        , P_PK1_NUM_VALUE          => r_contact.SR_CONTACT_POINT_ID
        , P_RESOURCE_ID            => p_resource_id
       );

      /*Delete the real contacts*/
      DELETE_CONTACT_POINT( r_contact.CONTACT_POINT_ID, p_resource_id );

      IF r_contact.CONTACT_TYPE = 'PERSON' THEN
        CSL_HZ_PARTIES_ACC_PKG.DELETE_PARTY( r_contact.PARTY_ID , p_resource_id );
      END IF; --PERSON

      IF r_contact.CONTACT_TYPE = 'PARTY_RELATIONSHIP' THEN
        DELETE_HZ_RELATIONSHIP( r_contact.PARTY_ID, p_resource_id );
      END IF; --PARTY_RELATIONSHIP

      IF r_contact.CONTACT_TYPE = 'EMPLOYEE' THEN
        DELETE_PER_ALL_PEOPLE_F( r_contact.PARTY_ID, p_resource_id );
      END IF; --EMPLOYEE

      IF r_contact.CONTACT_TYPE = 'ORGANIZATION' THEN
        NULL;
      END IF; --ORGANIZATION
    END IF; --p_flow_id
  END LOOP;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_incident_id
    , l_table_name
    , 'Leaving DELETE_CS_HZ_SR_CONTACTS'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

END DELETE_CS_HZ_SR_CONTACTS;

/**
 *
 */
PROCEDURE INSERT_PER_ALL_PEOPLE_F( p_person_id IN NUMBER
                                 , p_resource_id IN NUMBER )
IS

 CURSOR c_per_all_people(b_person_id NUMBER) IS
   SELECT EFFECTIVE_START_DATE , EFFECTIVE_END_DATE
   FROM PER_ALL_PEOPLE_F
   WHERE PERSON_ID = b_person_id;
 l_table_name            CONSTANT VARCHAR2(30) := 'PER_ALL_PEOPLE_F';
 l_acc_table_name        CONSTANT VARCHAR2(30) := 'JTM_PER_ALL_PEOPLE_F_ACC';
 l_pk1_name              CONSTANT VARCHAR2(30) := 'PERSON_ID';
 l_pk2_name              CONSTANT VARCHAR2(30) := 'EFFECTIVE_START_DATE';
 l_pk3_name              CONSTANT VARCHAR2(30) := 'EFFECTIVE_END_DATE';
 l_publication_item_name CONSTANT JTM_HOOK_UTIL_PKG.t_publication_item_list :=
      JTM_HOOK_UTIL_PKG.t_publication_item_list('PER_ALL_PEOPLE_F');

BEGIN
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_person_id
    , l_table_name
    , 'Entering INSERT_PER_ALL_PEOPLE_F'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  FOR r_per_all_people IN c_per_all_people(b_person_id => p_person_id) LOOP
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
       jtm_message_log_pkg.Log_Msg
        ( p_person_id
        , l_table_name
        , 'Inserting ACC record for resource_id = '||p_resource_id
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

    JTM_HOOK_UTIL_PKG.Insert_Acc
       ( P_PUBLICATION_ITEM_NAMES => l_publication_item_name
       , P_ACC_TABLE_NAME         => l_acc_table_name
       , P_PK1_NAME               => l_pk1_name
       , P_PK1_NUM_VALUE          => p_person_id
       , P_PK2_NAME               => l_pk2_name
       , P_PK2_DATE_VALUE         => r_per_all_people.EFFECTIVE_START_DATE
       , P_PK3_NAME               => l_pk3_name
       , P_PK3_DATE_VALUE         => r_per_all_people.EFFECTIVE_END_DATE
       , P_RESOURCE_ID            => p_resource_id
       );
  END LOOP;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_person_id
    , l_table_name
    , 'Leaving INSERT_PER_ALL_PEOPLE_F'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
END INSERT_PER_ALL_PEOPLE_F;

/**
 *
 */
PROCEDURE DELETE_PER_ALL_PEOPLE_F ( p_person_id IN NUMBER
                                  , p_resource_id IN NUMBER )
IS
 CURSOR c_per_all_people(b_person_id NUMBER) IS
   SELECT EFFECTIVE_START_DATE , EFFECTIVE_END_DATE
   FROM PER_ALL_PEOPLE_F
   WHERE PERSON_ID = b_person_id;
 l_table_name            CONSTANT VARCHAR2(30) := 'PER_ALL_PEOPLE_F';
 l_acc_table_name        CONSTANT VARCHAR2(30) := 'JTM_PER_ALL_PEOPLE_F_ACC';
 l_pk1_name              CONSTANT VARCHAR2(30) := 'PERSON_ID';
 l_pk2_name              CONSTANT VARCHAR2(30) := 'EFFECTIVE_START_DATE';
 l_pk3_name              CONSTANT VARCHAR2(30) := 'EFFECTIVE_END_DATE';
 l_publication_item_name CONSTANT JTM_HOOK_UTIL_PKG.t_publication_item_list :=
      JTM_HOOK_UTIL_PKG.t_publication_item_list('PER_ALL_PEOPLE_F');

BEGIN
IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_person_id
    , l_table_name
    , 'Entering DELETE_PER_ALL_PEOPLE_F'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  FOR r_per_all_people IN c_per_all_people(b_person_id => p_person_id) LOOP
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
       jtm_message_log_pkg.Log_Msg
        ( p_person_id
        , l_table_name
        , 'Deleting ACC record for resource_id = '||p_resource_id
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

    JTM_HOOK_UTIL_PKG.Delete_Acc
       (  P_PUBLICATION_ITEM_NAMES => l_publication_item_name
       , P_ACC_TABLE_NAME          => l_acc_table_name
       , P_PK1_NAME                => l_pk1_name
       , P_PK1_NUM_VALUE           => p_person_id
       , P_PK2_NAME                => l_pk2_name
       , P_PK2_DATE_VALUE          => r_per_all_people.EFFECTIVE_START_DATE
       , P_PK3_NAME                => l_pk3_name
       , P_PK3_DATE_VALUE          => r_per_all_people.EFFECTIVE_END_DATE
       , P_RESOURCE_ID             => p_resource_id
       );
  END LOOP;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_person_id
    , l_table_name
    , 'Leaving DELETE_PER_ALL_PEOPLE_F'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

END DELETE_PER_ALL_PEOPLE_F;

FUNCTION UPDATE_CONTACT_POINT_WFSUB( p_subscription_guid   in     raw
               , p_event               in out NOCOPY wf_event_t)
return varchar2
IS
 l_table_name            CONSTANT VARCHAR2(30) := 'HZ_CONTACT_POINTS';
 l_acc_table_name        CONSTANT VARCHAR2(30) := 'CSL_HZ_CONTACT_POINTS_ACC';
 l_pk1_name              CONSTANT VARCHAR2(30) := 'CONTACT_POINT_ID';
 l_publication_item_name CONSTANT JTM_HOOK_UTIL_PKG.t_publication_item_list :=
      JTM_HOOK_UTIL_PKG.t_publication_item_list('CSL_HZ_CONTACT_POINTS');
 l_key                    varchar2(240) := p_event.GetEventKey();
 l_org_id                 NUMBER;
 l_user_id 	            NUMBER;
 l_resp_id 	            NUMBER;
 l_resp_appl_id           NUMBER;
 l_security_group_id      NUMBER;
 l_count	            NUMBER;
 l_contact_point_id NUMBER;
 l_tab_resource_id    dbms_sql.Number_Table;
 l_tab_access_id      dbms_sql.Number_Table;
BEGIN
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;


  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( l_contact_point_id
    , l_table_name
    , 'Entering UPDATE_CONTACT_POINT_WFSUB'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  l_org_id := p_event.GetValueForParameter('ORG_ID');
  l_user_id := p_event.GetValueForParameter('USER_ID');
  l_resp_id := p_event.GetValueForParameter('RESP_ID');
  l_resp_appl_id := p_event.GetValueForParameter('RESP_APPL_ID');
  l_security_group_id := p_event.GetValueForParameter('SECURITY_GROUP_ID');

  fnd_global.apps_initialize (l_user_id, l_resp_id, l_resp_appl_id, l_security_group_id);

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
       jtm_message_log_pkg.Log_Msg
        ( l_contact_point_id
        , l_table_name
        , 'Get parameter for hz parameter P_CONTACT_POINT_REC.CONTACT_POINT_ID'
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
  --Bug 4496299
  /*
  l_contact_point_id := hz_param_pkg.ValueOfNumParameter  (p_key  => l_key,
                           p_parameter_name => 'P_CONTACT_POINT_REC.CONTACT_POINT_ID');
  */

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
     jtm_message_log_pkg.Log_Msg
      ( l_contact_point_id
      , l_table_name
      , 'Retrieved parameter for hz parameter P_CONTACT_POINT_REC.CONTACT_POINT_ID ' || l_contact_point_id
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*Is record valid ? assume so*/
  JTM_HOOK_UTIL_PKG.Get_Resource_Acc_List
     ( P_ACC_TABLE_NAME  => l_acc_table_name
     , P_PK1_NAME        => l_pk1_name
     , P_PK1_NUM_VALUE   => l_contact_point_id
     , L_TAB_RESOURCE_ID => l_tab_resource_id
     , L_TAB_ACCESS_ID   => l_tab_access_id
     );

    /*** re-send rec to all resources ***/
    IF l_tab_resource_id.COUNT > 0 THEN
      FOR i IN l_tab_resource_id.FIRST .. l_tab_resource_id.LAST LOOP
        JTM_HOOK_UTIL_PKG.Update_Acc
           ( P_PUBLICATION_ITEM_NAMES => l_publication_item_name
           , P_ACC_TABLE_NAME         => l_acc_table_name
           , P_RESOURCE_ID            => l_tab_resource_id(i)
           , P_ACCESS_ID              => l_tab_access_id(i)
           );
       END LOOP;
    END IF;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( l_contact_point_id
    , l_table_name
    , 'Leaving UPDATE_CONTACT_POINT_WFSUB'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  RETURN 'SUCCESS';

EXCEPTION
 WHEN OTHERS THEN
     WF_CORE.CONTEXT('CSL_PARTY_CONTACTS_ACC_PKG', 'UPDATE_CONTACT_POINT_WFSUB', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');
     RETURN 'ERROR';
END UPDATE_CONTACT_POINT_WFSUB;

END CSL_PARTY_CONTACTS_ACC_PKG;

/
