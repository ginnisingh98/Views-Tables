--------------------------------------------------------
--  DDL for Package Body HZ_POPULATE_BOT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_POPULATE_BOT_PKG" AS
/*$Header: ARHPBOTB.pls 120.19 2006/03/06 19:59:53 acng noship $ */

  PROCEDURE pop_parent_record(
    p_child_id       IN NUMBER,      -- child Id
    p_lud            IN DATE,        -- last update date
    p_centity_name   IN VARCHAR2,    -- child entity name
    p_cbo_code       IN VARCHAR2,    -- child business object code
    p_parent_id      IN NUMBER,      -- parent Id
    p_pentity_name   IN VARCHAR2,    -- parent entity name
    p_pbo_code       IN VARCHAR2     -- parent business object code
  );

  FUNCTION is_valid_ps(
    p_party_site_id  IN NUMBER
  ) RETURN BOOLEAN;

-----------------------------------------------------------------
-- Private Procedure name: pop_parent_record()
-- Purpose: populates parent record to bot tracking table
-- Scope: internal
-- Called From: procedure in this package
-- Input Parameters:
--   p_party_id  -- person party_id
--   p_lud       -- last update date
-----------------------------------------------------------------
-- operation is always U because parent record must exist before child
-- record can be created/updated
  PROCEDURE pop_parent_record(
    p_child_id       IN NUMBER,
    p_lud            IN DATE,
    p_centity_name   IN VARCHAR2,
    p_cbo_code       IN VARCHAR2,
    p_parent_id      IN NUMBER,
    p_pentity_name   IN VARCHAR2,
    p_pbo_code       IN VARCHAR2) IS
    -- local variables
    l_child_rec_exists_no     NUMBER;
    l_debug_prefix            VARCHAR2(40) := 'pop_parent_record';
  BEGIN
    hz_utility_v2pub.DEBUG(p_message=>'pop_parent_record+',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);

    BEGIN
      l_child_rec_exists_no := 0;
      SELECT child_id INTO  l_child_rec_exists_no
      FROM  HZ_BUS_OBJ_TRACKING
      WHERE event_id IS NULL
      AND CHILD_ENTITY_NAME = p_centity_name
      AND CHILD_BO_CODE = p_cbo_code
      AND CHILD_ID = p_child_id
      AND nvl(PARENT_ID,-99) = nvl(p_parent_id,-99)
      AND nvl(PARENT_BO_CODE,'X') = nvl(p_pbo_code,'X')
      AND rownum = 1;

      IF l_child_rec_exists_no <> 0 THEN
        -- data already exists, no need to write
        hz_utility_v2pub.DEBUG(p_message=> 'CHILD record already exists in BOT',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        INSERT INTO HZ_BUS_OBJ_TRACKING
        ( POPULATED_FLAG, CHILD_OPERATION_FLAG, CHILD_ID, CHILD_ENTITY_NAME, CHILD_BO_CODE,
          LAST_UPDATE_DATE, CREATION_DATE, PARENT_ENTITY_NAME, PARENT_ID, PARENT_BO_CODE
        ) VALUES (
          'Y', 'U', p_child_id, p_centity_name, p_cbo_code,
          p_lud, p_lud, p_pentity_name, p_parent_id, p_pbo_code);
    END;

    hz_utility_v2pub.DEBUG(p_message=>'pop_parent_record-',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
  END pop_parent_record;

-----------------------------------------------------------------
-- Procedure name: pop_hz_work_class()
-- Purpose: populates BOT for HZ_WORK_CLASS create or update
-- Scope: internal
-- Called From: V2 API
-- Called By: HZ_WORK_CLASS create or update APIs
-- Input Parameters:
--   p_operation -- contains I or U.  'I' if create API is calling this otherwise 'U'.
--   p_work_class_id IN NUMBER
--
-- Note:
--   Following are the allowed PARENT and CHILD BO combinations for HZ_WORK_CLASS
--   This procedure must ensure that the combination is valid before populating BOT
--   PARENT BO: EMP_HIST :: CHILD BO:
-----------------------------------------------------------------
  PROCEDURE pop_hz_work_class(p_operation IN VARCHAR2, p_work_class_id IN NUMBER) IS

    -- cursor statement to select the info from child table
    CURSOR c_child IS
      SELECT wc.LAST_UPDATE_DATE lud, wc.EMPLOYMENT_HISTORY_ID parent_id, eh.party_id party_id,
             wc.WORK_CLASS_ID child_id
      FROM HZ_WORK_CLASS wc, HZ_EMPLOYMENT_HISTORY eh, HZ_PARTIES p
      WHERE wc.WORK_CLASS_ID = P_WORK_CLASS_ID
      AND wc.employment_history_id = eh.employment_history_id
      AND eh.party_id = p.party_id
      AND p.party_type = 'PERSON';

    -- local variables
    l_debug_prefix            VARCHAR2(40) := 'pop_hz_work_class';
    l_parent_id               NUMBER;       -- used to store parent entity identifier
    l_bo_code                 VARCHAR2(30); -- used to store BO Code
    l_child_bo_code           VARCHAR2(30); -- used to store Child BO Code (if child entity is a root node)
    l_child_id                NUMBER;       -- used to store HZ_WORK_CLASS identifier
    l_lud                     DATE;         -- used to store the child last update date
    l_child_rec_exists_no     NUMBER;
    l_party_id                NUMBER;       -- person party_id of employment history record
    l_cen                     VARCHAR2(30) := 'HZ_WORK_CLASS';
  BEGIN
    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_work_class+',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);

    -- validate p_operation
    IF p_operation IN ('I','U') THEN
      NULL;
    ELSE
      hz_utility_v2pub.DEBUG(p_message=> 'incorrect operation flag sent to pop_hz_work_class',
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    FOR c_child_rec IN c_child LOOP
      -- collect the child info into variables
      l_lud := c_child_rec.lud;
      l_parent_id := c_child_rec.parent_id;
      l_child_id := c_child_rec.child_id;
      l_party_id := c_child_rec.party_id;

      -- if record not existing for work class, insert into hz_bus_obj_tracking
      BEGIN
        l_child_rec_exists_no := 0;
        SELECT child_id INTO l_child_rec_exists_no
        FROM  HZ_BUS_OBJ_TRACKING
        WHERE event_id IS NULL
        AND CHILD_ENTITY_NAME = l_cen
        AND CHILD_ID = l_child_id
        AND rownum = 1;

        IF l_child_rec_exists_no <> 0 THEN
          -- data already exists, no need to write
          hz_utility_v2pub.DEBUG(p_message=> 'CHILD record already exists in BOT',
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          INSERT INTO HZ_BUS_OBJ_TRACKING
          ( POPULATED_FLAG, CHILD_OPERATION_FLAG, CHILD_ID, CHILD_ENTITY_NAME, CHILD_BO_CODE,
            LAST_UPDATE_DATE, CREATION_DATE, PARENT_ENTITY_NAME, PARENT_ID, PARENT_BO_CODE
          ) VALUES (
            'N', p_operation, l_child_id, 'HZ_WORK_CLASS', NULL,
            l_lud, l_lud, 'HZ_EMPLOYMENT_HISTORY', l_parent_id, 'EMP_HIST');

          -- if record not existing for employment history, insert into hz_bus_obj_tracking
          pop_parent_record(p_child_id     => l_parent_id,
                            p_lud          => l_lud,
                            p_centity_name => 'HZ_EMPLOYMENT_HISTORY',
                            p_cbo_code     => 'EMP_HIST',
                            p_parent_id    => l_party_id,
                            p_pentity_name => 'HZ_PARTIES',
                            p_pbo_code     => 'PERSON');

          -- if record not existing for person of employment history, insert into hz_bus_obj_tracking
          pop_parent_record(p_child_id     => l_party_id,
                            p_lud          => l_lud,
                            p_centity_name => 'HZ_PARTIES',
                            p_cbo_code     => 'PERSON',
                            p_parent_id    => NULL,
                            p_pentity_name => NULL,
                            p_pbo_code     => NULL);
      END; -- anonymous block end
    END LOOP;

    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_work_class-',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);
  EXCEPTION
    WHEN OTHERS THEN
      hz_utility_v2pub.DEBUG(p_message=> SQLERRM,
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END pop_hz_work_class;

-----------------------------------------------------------------
-- Procedure name: pop_hz_role_responsibility()
-- Purpose: populates BOT for HZ_ROLE_RESPONSIBILITY create or update
-- Scope: internal
-- Called From: V2 API
-- Called By: HZ_ROLE_RESPONSIBILITY create or update APIs
-- Input Parameters:
--   p_operation -- contains I or U.  'I' if create API is calling this otherwise 'U'.
--   p_responsibility_id IN NUMBER
--
-- Note:
--   Following are the allowed PARENT and CHILD BO combinations for HZ_ROLE_RESPONSIBILITY
--   This procedure must ensure that the combination is valid before populating BOT
--
-- PARENT BO: CUST_ACCT_CONTACT :: CHILD BO:
-----------------------------------------------------------------
  PROCEDURE pop_hz_role_responsibility(p_operation IN VARCHAR2, p_responsibility_id IN NUMBER) IS

    -- cursor statement to select the info from child table
    CURSOR c_child IS
      SELECT rr.LAST_UPDATE_DATE lud, rr.CUST_ACCOUNT_ROLE_ID parent_id, rr.RESPONSIBILITY_ID child_id,
             nvl(car.cust_acct_site_id, car.cust_account_id) car_parent_id,
             decode(car.cust_acct_site_id, null, 'HZ_CUST_ACCOUNTS', 'HZ_CUST_ACCT_SITES_ALL') car_parent_entity,
             decode(car.cust_acct_site_id, null, 'CUST_ACCT', 'CUST_ACCT_SITE') car_parent_bo
      FROM HZ_ROLE_RESPONSIBILITY rr, HZ_CUST_ACCOUNT_ROLES car
      WHERE rr.RESPONSIBILITY_ID = P_RESPONSIBILITY_ID
      AND rr.cust_account_role_id = car.cust_account_role_id
      AND car.cust_account_id > 0;

    -- local variables
    l_debug_prefix            VARCHAR2(40) := 'pop_hz_role_responsibility';
    l_parent_id               NUMBER; -- used to store parent entity identifier
    l_child_id                NUMBER; -- used to store HZ_ROLE_RESPONSIBILITY identifier
    l_lud                     DATE; -- used to store the child last update date
    l_child_rec_exists_no     NUMBER;
    l_car_parent_id           NUMBER; -- parent Id of cust account roles
    l_car_parent_entity       VARCHAR2(30); -- entity name of cust account roles parent
    l_car_parent_bo           VARCHAR2(30); -- business object of cust account roles parent
    l_cen                     VARCHAR2(30) := 'HZ_ROLE_RESPONSIBILITY';
  BEGIN
    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_role_responsibility+',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);

    -- validate p_operation
    IF p_operation IN ('I','U') THEN
      NULL;
    ELSE
      hz_utility_v2pub.DEBUG(p_message=> 'incorrect operation flag sent to pop_hz_role_responsibility',
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    FOR c_child_rec IN C_child LOOP
      -- collect the child info into variables
      l_lud := c_child_rec.lud;
      l_parent_id := c_child_rec.parent_id;
      l_child_id := c_child_rec.child_id;
      l_car_parent_id := c_child_rec.car_parent_id;
      l_car_parent_entity := c_child_rec.car_parent_entity;
      l_car_parent_bo := c_child_rec.car_parent_bo;

      -- if record not existing, insert into hz_bus_obj_tracking
      BEGIN
        l_child_rec_exists_no := 0;
        SELECT child_id INTO  l_child_rec_exists_no
        FROM  HZ_BUS_OBJ_TRACKING
        WHERE event_id IS NULL
        AND CHILD_ENTITY_NAME = l_cen
        AND CHILD_ID = l_child_id
        AND rownum = 1;

        IF l_child_rec_exists_no <> 0 THEN
          -- data already exists, no need to write
          hz_utility_v2pub.DEBUG(p_message=> 'CHILD record already exists in BOT',
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          INSERT INTO HZ_BUS_OBJ_TRACKING
          ( POPULATED_FLAG, CHILD_OPERATION_FLAG, CHILD_ID, CHILD_ENTITY_NAME, CHILD_BO_CODE,
            LAST_UPDATE_DATE, CREATION_DATE, PARENT_ENTITY_NAME, PARENT_ID, PARENT_BO_CODE
          ) VALUES (
            'N', p_operation, l_child_id, 'HZ_ROLE_RESPONSIBILITY', NULL,
            l_lud, l_lud, 'HZ_CUST_ACCOUNT_ROLES', l_parent_id, 'CUST_ACCT_CONTACT');

          -- if record not existing for customer account contact, insert into hz_bus_obj_tracking
          pop_parent_record(p_child_id     => l_parent_id,
                            p_lud          => l_lud,
                            p_centity_name => 'HZ_CUST_ACCOUNT_ROLES',
                            p_cbo_code     => 'CUST_ACCT_CONTACT',
                            p_parent_id    => l_car_parent_id,
                            p_pentity_name => l_car_parent_entity,
                            p_pbo_code     => l_car_parent_bo);
      END ; -- anonymous block end
    END LOOP;

    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_role_responsibility-',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);
  EXCEPTION
    WHEN OTHERS THEN
      hz_utility_v2pub.DEBUG(p_message=> SQLERRM,
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END pop_hz_role_responsibility;

-----------------------------------------------------------------
-- Procedure name: pop_hz_relationships()
-- Purpose: populates BOT for HZ_RELATIONSHIPS create or update
-- Scope: internal
-- Called From: V2 API
-- Called By: HZ_RELATIONSHIPS create or update APIs
-- Input Parameters:
--   p_operation -- contains I or U.  'I' if create API is calling this otherwise 'U'.
--     p_RELATIONSHIP_ID IN NUMBER
--
-- Note:
--   Following are the allowed PARENT and CHILD BO combinations for HZ_RELATIONSHIPS
--   This procedure must ensure that the combination is valid before populating BOT
--
-- PARENT BO: ORG :: CHILD BO:
-- PARENT BO: PERSON :: CHILD BO:
-- PARENT BO: ORG_CONTACT :: CHILD BO:
-----------------------------------------------------------------
  PROCEDURE pop_hz_relationships(p_operation IN VARCHAR2, p_relationship_id IN NUMBER) IS

    CURSOR c_child IS
      SELECT pp.LAST_UPDATE_DATE lud, pp.subject_id sparent_id, pp.object_id oparent_id,
             pp.RELATIONSHIP_ID child_id,
             decode(pp.subject_type, 'ORGANIZATION', 'ORG', 'PERSON', 'PERSON', NULL) sbo_code,
             decode(pp.object_type, 'ORGANIZATION', 'ORG', 'PERSON', 'PERSON', NULL) obo_code
      FROM HZ_RELATIONSHIPS pp
      WHERE pp.RELATIONSHIP_ID = p_RELATIONSHIP_ID
      AND subject_type in ('ORGANIZATION','PERSON')
      AND object_type in ('ORGANIZATION','PERSON');

    CURSOR c_get_oc_id IS
      SELECT org_contact_id
      FROM HZ_ORG_CONTACTS
      WHERE party_relationship_id = p_relationship_id;

    -- local variables
    l_debug_prefix    VARCHAR2(40) := 'pop_hz_relationships';
    l_subj_id         NUMBER; -- used to store subject entity identifier
    l_obj_id          NUMBER; -- used to store object entity identifier
    l_sbo_code        VARCHAR2(30); -- used to store subject BO Code
    l_obo_code        VARCHAR2(30); -- used to store object BO Code
    l_child_id        NUMBER; -- used to store HZ_RELATIONSHIPS identifier
    l_lud             DATE; -- used to store the child last update date
    l_oc_id                   NUMBER;
    l_child_rec_exists_no     NUMBER;
    l_cen                     VARCHAR2(30) := 'HZ_RELATIONSHIPS';
 BEGIN
    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_relationships+',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);

    -- validate p_operation
    IF p_operation IN ('I','U') THEN
      NULL;
    ELSE
      hz_utility_v2pub.DEBUG(p_message=> 'incorrect operation flag sent to pop_hz_relationships',
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    FOR c_child_rec IN c_child LOOP
      l_lud := c_child_rec.lud;
      l_subj_id := c_child_rec.sparent_id;
      l_obj_id := c_child_rec.oparent_id;
      l_sbo_code := c_child_rec.sbo_code;
      l_obo_code := c_child_rec.obo_code;
      l_child_id := c_child_rec.child_id;

      -- if record not existing, insert into hz_bus_obj_tracking
      BEGIN
        l_child_rec_exists_no := 0;
        SELECT child_id INTO  l_child_rec_exists_no
        FROM  HZ_BUS_OBJ_TRACKING
        WHERE event_id IS NULL
        AND CHILD_ENTITY_NAME = l_cen
        AND CHILD_ID = l_child_id
        AND rownum = 1;

        IF l_child_rec_exists_no <> 0 THEN
          -- data already exists, no need to write
          hz_utility_v2pub.DEBUG(p_message=> 'CHILD record already exists in BOT',
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          -- for subject
          INSERT INTO HZ_BUS_OBJ_TRACKING
          ( POPULATED_FLAG, CHILD_OPERATION_FLAG, CHILD_ID, CHILD_ENTITY_NAME, CHILD_BO_CODE,
            LAST_UPDATE_DATE, CREATION_DATE, PARENT_ENTITY_NAME, PARENT_ID, PARENT_BO_CODE
          ) VALUES (
            'N', p_operation, l_child_id, 'HZ_RELATIONSHIPS', NULL,
            l_lud, l_lud, 'HZ_PARTIES', l_subj_id, l_sbo_code);

          -- for object
          INSERT INTO HZ_BUS_OBJ_TRACKING
          ( POPULATED_FLAG, CHILD_OPERATION_FLAG, CHILD_ID, CHILD_ENTITY_NAME, CHILD_BO_CODE,
            LAST_UPDATE_DATE, CREATION_DATE, PARENT_ENTITY_NAME, PARENT_ID, PARENT_BO_CODE
          ) VALUES (
            'N', p_operation, l_child_id, 'HZ_RELATIONSHIPS', NULL,
            l_lud, l_lud, 'HZ_PARTIES', l_obj_id, l_obo_code);

          -- if record not existing for customer account contact, insert into hz_bus_obj_tracking
          pop_parent_record(p_child_id     => l_subj_id,
                            p_lud          => l_lud,
                            p_centity_name => 'HZ_PARTIES',
                            p_cbo_code     => l_sbo_code,
                            p_parent_id    => NULL,
                            p_pentity_name => NULL,
                            p_pbo_code     => NULL);

          pop_parent_record(p_child_id     => l_obj_id,
                            p_lud          => l_lud,
                            p_centity_name => 'HZ_PARTIES',
                            p_cbo_code     => l_obo_code,
                            p_parent_id    => NULL,
                            p_pentity_name => NULL,
                            p_pbo_code     => NULL);

          IF(p_operation = 'U') THEN
            IF(l_sbo_code = 'PERSON' AND l_obo_code = 'ORGANIZATION') THEN
              OPEN c_get_oc_id;
              FETCH c_get_oc_id INTO l_oc_id;
              CLOSE c_get_oc_id;
              pop_hz_org_contacts(
                p_operation      => 'U',
                p_org_contact_id => l_oc_id);
            END IF;
          END IF;
      END ; -- anonymous block end
    END LOOP;

    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_relationships-',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);
  EXCEPTION
    WHEN OTHERS THEN
      hz_utility_v2pub.DEBUG(p_message=> SQLERRM,
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END pop_hz_relationships;

-----------------------------------------------------------------
-- Procedure name: pop_hz_person_profiles()
-- Purpose: populates BOT for HZ_PERSON_PROFILES create or update
-- Scope: internal
-- Called From: V2 API
-- Called By: HZ_PERSON_PROFILES create or update APIs
-- Input Parameters:
--   p_operation -- contains I or U.  'I' if create API is calling this otherwise 'U'.
--   p_person_profile_id IN NUMBER
--
-- Note:
--   Following are the allowed PARENT and CHILD BO combinations for HZ_PERSON_PROFILES
--   This procedure must ensure that the combination is valid before populating BOT
--
-- PARENT BO: PERSON :: CHILD BO:
-- PARENT BO: PERSON_CONTACT :: CHILD BO:
-----------------------------------------------------------------
  PROCEDURE pop_hz_person_profiles(p_operation IN VARCHAR2, p_person_profile_id IN NUMBER) IS

    -- cursor statement to select the info from child table
    CURSOR c_child IS
      SELECT LAST_UPDATE_DATE lud, PARTY_ID parent_id, PERSON_PROFILE_ID child_id
      FROM HZ_PERSON_PROFILES
      WHERE PERSON_PROFILE_ID = P_PERSON_PROFILE_ID;

    -- local variables
    l_debug_prefix    VARCHAR2(40) := 'pop_hz_person_profiles';
    l_parent_id       NUMBER; -- used to store parent entity identifier
    l_child_id        NUMBER; -- used to store HZ_PERSON_PROFILES identifier
    l_lud             DATE; -- used to store the child last update date
    l_child_rec_exists_no     NUMBER;
    l_org_contact_id          NUMBER;
    l_cen                     VARCHAR2(30) := 'HZ_PERSON_PROFILES';
  BEGIN
    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_person_profiles+',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);

    -- validate p_operation
    IF p_operation IN ('I','U') THEN
      NULL;
    ELSE
      hz_utility_v2pub.DEBUG(p_message=> 'incorrect operation flag sent to pop_hz_person_profiles',
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    FOR c_child_rec IN c_child LOOP
      -- collect the child info into variables
      l_lud := c_child_rec.lud;
      l_child_id := c_child_rec.child_id;
      l_parent_id := c_child_rec.parent_id;

      -- if record not existing, insert into hz_bus_obj_tracking
      BEGIN
        l_child_rec_exists_no := 0;
        SELECT child_id INTO  l_child_rec_exists_no
        FROM  HZ_BUS_OBJ_TRACKING
        WHERE event_id IS NULL
        AND CHILD_ENTITY_NAME = l_cen
        AND CHILD_ID = l_child_id
        AND rownum = 1;

        IF l_child_rec_exists_no <> 0 THEN
          -- data already exists, no need to write
          hz_utility_v2pub.DEBUG(p_message=> 'CHILD record already exists in BOT',
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          INSERT INTO HZ_BUS_OBJ_TRACKING
          ( POPULATED_FLAG, CHILD_OPERATION_FLAG, CHILD_ID, CHILD_ENTITY_NAME, CHILD_BO_CODE,
            LAST_UPDATE_DATE, CREATION_DATE, PARENT_ENTITY_NAME, PARENT_ID, PARENT_BO_CODE
          ) VALUES (
            'N', p_operation, l_child_id, 'HZ_PERSON_PROFILES', NULL,
            l_lud, l_lud, 'HZ_PARTIES', l_parent_id, 'PERSON');

          -- populate person party record
          pop_parent_record(p_child_id     => l_parent_id,
                            p_lud          => l_lud,
                            p_centity_name => 'HZ_PARTIES',
                            p_cbo_code     => 'PERSON',
                            p_parent_id    => NULL,
                            p_pentity_name => NULL,
                            p_pbo_code     => NULL);
      END ; -- anonymous block end
    END LOOP;

    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_person_profiles-',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);
  EXCEPTION
    WHEN OTHERS THEN
      hz_utility_v2pub.DEBUG(p_message=> SQLERRM,
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END pop_hz_person_profiles;

-----------------------------------------------------------------
-- Procedure name: pop_hz_person_language()
-- Purpose: populates BOT for HZ_PERSON_LANGUAGE create or update
-- Scope: internal
-- Called From: V2 API
-- Called By: HZ_PERSON_LANGUAGE create or update APIs
-- Input Parameters:
--   p_operation -- contains I or U.  'I' if create API is calling this otherwise 'U'.
--     p_LANGUAGE_USE_REFERENCE_ID IN NUMBER
--
-- Note:
--   Following are the allowed PARENT and CHILD BO combinations for HZ_PERSON_LANGUAGE
--   This procedure must ensure that the combination is valid before populating BOT
--
-- PARENT BO: PERSON :: CHILD BO:
-----------------------------------------------------------------
  PROCEDURE pop_hz_person_language(p_operation IN VARCHAR2, p_language_use_reference_id IN NUMBER) IS

    -- cursor statement to select the info from child table
    CURSOR c_child IS
      SELECT pl.LAST_UPDATE_DATE lud, pl.PARTY_ID parent_id, pl.LANGUAGE_USE_REFERENCE_ID child_id
      FROM HZ_PERSON_LANGUAGE pl, HZ_PARTIES p
      WHERE pl.LANGUAGE_USE_REFERENCE_ID = P_LANGUAGE_USE_REFERENCE_ID
      AND pl.party_id = p.party_id
      AND p.party_type = 'PERSON';

    -- local variables
    l_debug_prefix            VARCHAR2(40) := 'pop_hz_person_language';
    l_parent_id               NUMBER; -- used to store parent entity identifier
    l_child_id                NUMBER; -- used to store HZ_PERSON_LANGUAGE identifier
    l_lud                     DATE; -- used to store the child last update date
    l_child_rec_exists_no     NUMBER;
    l_cen                     VARCHAR2(30) := 'HZ_PERSON_LANGUAGE';
  BEGIN
    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_person_language+',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);

    -- validate p_operation
    IF p_operation IN ('I','U') THEN
      NULL;
    ELSE
      hz_utility_v2pub.DEBUG(p_message=> 'incorrect operation flag sent to pop_hz_person_language',
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    FOR c_child_rec IN c_child LOOP
      -- collect the child info into variables
      l_lud := c_child_rec.lud;
      l_parent_id := c_child_rec.parent_id;
      l_child_id := c_child_rec.child_id;

      -- if record not existing, insert into hz_bus_obj_tracking
      BEGIN
        l_child_rec_exists_no := 0;
        SELECT child_id INTO  l_child_rec_exists_no
        FROM  HZ_BUS_OBJ_TRACKING
        WHERE event_id IS NULL
        AND CHILD_ENTITY_NAME = l_cen
        AND CHILD_ID = l_child_id
        AND rownum = 1;

        IF l_child_rec_exists_no <> 0 THEN
          -- data already exists, no need to write
          hz_utility_v2pub.DEBUG(p_message=> 'CHILD record already exists in BOT',
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          INSERT INTO HZ_BUS_OBJ_TRACKING
          ( POPULATED_FLAG, CHILD_OPERATION_FLAG, CHILD_ID, CHILD_ENTITY_NAME, CHILD_BO_CODE,
            LAST_UPDATE_DATE, CREATION_DATE, PARENT_ENTITY_NAME, PARENT_ID, PARENT_BO_CODE
          ) VALUES (
            'N', p_operation, l_child_id, 'HZ_PERSON_LANGUAGE', NULL,
            l_lud, l_lud, 'HZ_PARTIES', l_parent_id, 'PERSON');

          -- populate party record
          pop_parent_record(p_child_id     => l_parent_id,
                            p_lud          => l_lud,
                            p_centity_name => 'HZ_PARTIES',
                            p_cbo_code     => 'PERSON',
                            p_parent_id    => NULL,
                            p_pentity_name => NULL,
                            p_pbo_code     => NULL);
      END ; -- anonymous block end
    END LOOP;

    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_person_language-',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);
  EXCEPTION
    WHEN OTHERS THEN
      hz_utility_v2pub.DEBUG(p_message=> SQLERRM,
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END pop_hz_person_language;

-----------------------------------------------------------------
-- Procedure name: pop_hz_person_interest()
-- Purpose: populates BOT for HZ_PERSON_INTEREST create or update
-- Scope: internal
-- Called From: V2 API
-- Called By: HZ_PERSON_INTEREST create or update APIs
-- Input Parameters:
--   p_operation -- contains I or U.  'I' if create API is calling this otherwise 'U'.
--   p_person_interest_id IN NUMBER
--
-- Note:
--   Following are the allowed PARENT and CHILD BO combinations for HZ_PERSON_INTEREST
--   This procedure must ensure that the combination is valid before populating BOT
--
-- PARENT BO: PERSON :: CHILD BO:
-----------------------------------------------------------------
  PROCEDURE pop_hz_person_interest(p_operation IN VARCHAR2, p_person_interest_id IN NUMBER) IS

    -- cursor statement to select the info from child table
    CURSOR C_child IS
      SELECT pi.LAST_UPDATE_DATE lud, pi.PARTY_ID parent_id, pi.PERSON_INTEREST_ID child_id
      FROM HZ_PERSON_INTEREST pi, HZ_PARTIES p
      WHERE pi.PERSON_INTEREST_ID = P_PERSON_INTEREST_ID
      AND pi.party_id = p.party_id
      AND p.party_type = 'PERSON';

    -- local variables
    l_debug_prefix            VARCHAR2(40) := 'pop_hz_person_interest';
    l_parent_id               NUMBER; -- used to store parent entity identifier
    l_child_id                NUMBER; -- used to store HZ_PERSON_INTEREST identifier
    l_lud                     DATE; -- used to store the child last update date
    l_child_rec_exists_no     NUMBER;
    l_cen                     VARCHAR2(30) := 'HZ_PERSON_INTEREST';
  BEGIN
    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_person_interest+',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);

    -- validate p_operation
    IF p_operation IN ('I','U') THEN
      NULL;
    ELSE
      hz_utility_v2pub.DEBUG(p_message=> 'incorrect operation flag sent to pop_hz_person_interest',
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    FOR c_child_rec IN c_child LOOP
      -- collect the child info into variables
      l_lud := c_child_rec.lud;
      l_parent_id := c_child_rec.parent_id;
      l_child_id := c_child_rec.child_id;

      -- if record not existing, insert into hz_bus_obj_tracking
      BEGIN
        l_child_rec_exists_no := 0;
        SELECT child_id INTO  l_child_rec_exists_no
        FROM  HZ_BUS_OBJ_TRACKING
        WHERE event_id IS NULL
        AND CHILD_ENTITY_NAME = l_cen
        AND CHILD_ID = l_child_id
        AND rownum = 1;

        IF l_child_rec_exists_no <> 0 THEN
          -- data already exists, no need to write
          hz_utility_v2pub.DEBUG(p_message=> 'CHILD record already exists in BOT',
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          INSERT INTO HZ_BUS_OBJ_TRACKING
          ( POPULATED_FLAG, CHILD_OPERATION_FLAG, CHILD_ID, CHILD_ENTITY_NAME, CHILD_BO_CODE,
            LAST_UPDATE_DATE, CREATION_DATE, PARENT_ENTITY_NAME, PARENT_ID, PARENT_BO_CODE
          ) VALUES (
            'N', p_operation, l_child_id, 'HZ_PERSON_INTEREST', NULL,
            l_lud, l_lud, 'HZ_PARTIES', l_parent_id, 'PERSON');

          -- populate party record
          pop_parent_record(p_child_id     => l_parent_id,
                            p_lud          => l_lud,
                            p_centity_name => 'HZ_PARTIES',
                            p_cbo_code     => 'PERSON',
                            p_parent_id    => NULL,
                            p_pentity_name => NULL,
                            p_pbo_code     => NULL);
      END ; -- anonymous block end
    END LOOP;

    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_person_interest-',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);
  EXCEPTION
    WHEN OTHERS THEN
      hz_utility_v2pub.DEBUG(p_message=> SQLERRM,
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END pop_hz_person_interest;

-----------------------------------------------------------------
-- Procedure name: pop_hz_party_site_uses()
-- Purpose: populates BOT for HZ_PARTY_SITE_USES create or update
-- Scope: internal
-- Called From: V2 API
-- Called By: HZ_PARTY_SITE_USES create or update APIs
-- Input Parameters:
--   p_operation -- contains I or U.  'I' if create API is calling this otherwise 'U'.
--   p_party_site_use_id IN NUMBER
--
-- Note:
--   Following are the allowed PARENT and CHILD BO combinations for HZ_PARTY_SITE_USES
--   This procedure must ensure that the combination is valid before populating BOT
--
-- PARENT BO: PARTY_SITE :: CHILD BO:
-----------------------------------------------------------------
  PROCEDURE pop_hz_party_site_uses(p_operation IN VARCHAR2, p_party_site_use_id IN NUMBER) IS

    -- cursor statement to select the info from child table
    CURSOR C_child IS
      SELECT psu.LAST_UPDATE_DATE lud, psu.PARTY_SITE_ID parent_id, psu.PARTY_SITE_USE_ID child_id,
             p.party_type, p.party_id
      FROM HZ_PARTY_SITE_USES psu, HZ_PARTY_SITES ps, HZ_PARTIES p
      WHERE psu.PARTY_SITE_USE_ID = P_PARTY_SITE_USE_ID
      AND psu.party_site_id = ps.party_site_id
      AND ps.party_id = p.party_id
      AND p.party_type in ('ORGANIZATION', 'PERSON', 'PARTY_RELATIONSHIP');

    CURSOR get_org_contact(l_party_id NUMBER) IS
      SELECT oc.org_contact_id
      FROM HZ_ORG_CONTACTS oc, HZ_RELATIONSHIPS pr
      WHERE oc.party_relationship_id = pr.relationship_id
      AND pr.party_id = l_party_id
      AND pr.subject_type = 'PERSON'
      AND pr.object_type = 'ORGANIZATION'
      AND rownum = 1;

    -- local variables
    l_debug_prefix            VARCHAR2(40) := 'pop_hz_party_site_uses';
    l_parent_id               NUMBER; -- used to store parent entity identifier
    l_child_id                NUMBER; -- used to store HZ_PARTY_SITE_USES identifier
    l_lud                     DATE; -- used to store the child last update date
    l_child_rec_exists_no     NUMBER;
    l_ptype                   VARCHAR2(30);
    l_pid                     NUMBER;
    l_dummy_id                NUMBER;
    l_cen                     VARCHAR2(30) := 'HZ_PARTY_SITE_USES';
  BEGIN
    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_party_site_uses+',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);

    -- validate p_operation
    IF p_operation IN ('I','U') THEN
      NULL;
    ELSE
      hz_utility_v2pub.DEBUG(p_message=> 'incorrect operation flag sent to pop_hz_party_site_uses',
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    FOR c_child_rec IN c_child LOOP
      -- collect the child info into variables
      l_lud := c_child_rec.lud;
      l_parent_id := c_child_rec.parent_id;
      l_child_id := c_child_rec.child_id;
      l_ptype := c_child_rec.party_type;
      l_pid := c_child_rec.party_id;

      IF(l_ptype = 'PARTY_RELATIONSHIP') THEN
        -- get org_contact_id
        OPEN get_org_contact(l_pid);
        FETCH get_org_contact INTO l_dummy_id;
        CLOSE get_org_contact;
        IF(l_dummy_id IS NULL) THEN
          RETURN;
        END IF;
      END IF;

      -- if record not existing, insert into hz_bus_obj_tracking
      BEGIN
        l_child_rec_exists_no := 0;
        SELECT child_id INTO  l_child_rec_exists_no
        FROM  HZ_BUS_OBJ_TRACKING
        WHERE event_id IS NULL
        AND CHILD_ENTITY_NAME = l_cen
        AND CHILD_ID = l_child_id
        AND rownum = 1;

        IF l_child_rec_exists_no <> 0 THEN
          -- data already exists, no need to write
          hz_utility_v2pub.DEBUG(p_message=> 'CHILD record already exists in BOT',
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          INSERT INTO HZ_BUS_OBJ_TRACKING
          ( POPULATED_FLAG, CHILD_OPERATION_FLAG, CHILD_ID, CHILD_ENTITY_NAME, CHILD_BO_CODE,
            LAST_UPDATE_DATE, CREATION_DATE, PARENT_ENTITY_NAME, PARENT_ID, PARENT_BO_CODE
          ) VALUES (
            'N', p_operation, l_child_id, 'HZ_PARTY_SITE_USES', NULL,
            l_lud, l_lud, 'HZ_PARTY_SITES', l_parent_id, 'PARTY_SITE');
      END ; -- anonymous block end
    END LOOP;

    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_party_site_uses-',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);
  EXCEPTION
    WHEN OTHERS THEN
      hz_utility_v2pub.DEBUG(p_message=> SQLERRM,
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END pop_hz_party_site_uses;

-----------------------------------------------------------------
-- Procedure name: pop_hz_party_sites()
-- Purpose: populates BOT for HZ_PARTY_SITES create or update
-- Scope: internal
-- Called From: V2 API
-- Called By: HZ_PARTY_SITES create or update APIs
-- Input Parameters:
--   p_operation -- contains I or U.  'I' if create API is calling this otherwise 'U'.
--   p_party_site_id IN NUMBER
--
-- Note:
--   Following are the allowed PARENT and CHILD BO combinations for HZ_PARTY_SITES
--   This procedure must ensure that the combination is valid before populating BOT
--
-- PARENT BO: ORG :: CHILD BO: PARTY_SITE
-- PARENT BO: PERSON :: CHILD BO: PARTY_SITE
-- PARENT BO: ORG_CONTACT :: CHILD BO: PARTY_SITE
-----------------------------------------------------------------
  PROCEDURE pop_hz_party_sites(p_operation IN VARCHAR2, p_party_site_id IN NUMBER) IS

    -- cursor statement to select the info from child table
    CURSOR c_child IS
      SELECT ps.LAST_UPDATE_DATE lud, ps.PARTY_ID parent_id,
             decode(p.party_type, 'PARTY_RELATIONSHIP', 'HZ_ORG_CONTACTS', 'HZ_PARTIES') parent_tbl_name,
             ps.PARTY_SITE_ID child_id,
             decode(p.party_type, 'ORGANIZATION', 'ORG', 'PERSON', 'PERSON', 'PARTY_RELATIONSHIP', 'ORG_CONTACT', null) bo_code,
             ps.location_id location_id
      FROM HZ_PARTY_SITES ps, HZ_PARTIES p
      WHERE ps.PARTY_SITE_ID = P_PARTY_SITE_ID
      AND ps.party_id = p.party_id
      AND p.party_type in ('ORGANIZATION','PERSON','PARTY_RELATIONSHIP');

    CURSOR get_org_contact(l_party_id NUMBER) IS
      SELECT oc.org_contact_id
      FROM HZ_ORG_CONTACTS oc, HZ_RELATIONSHIPS pr
      WHERE oc.party_relationship_id = pr.relationship_id
      AND pr.party_id = l_party_id
      AND pr.subject_type = 'PERSON'
      AND pr.object_type = 'ORGANIZATION'
      AND rownum = 1;

    -- local variables
    l_debug_prefix            VARCHAR2(40) := 'pop_hz_party_sites';
    l_parent_id               NUMBER; -- used to store parent entity identifier
    l_parent_tbl_name         VARCHAR2(30); -- used to store parent entity name
    l_bo_code                 VARCHAR2(30); -- used to store BO Code
    l_child_bo_code           VARCHAR2(30); -- used to store Child BO Code (if child entity is a root node)
    l_child_id                NUMBER; -- used to store HZ_PARTY_SITES identifier
    l_lud                     DATE; -- used to store the child last update date
    l_child_rec_exists_no     NUMBER;
    l_location_id             NUMBER;
    l_org_contact_id          NUMBER;
    l_org_id                  NUMBER;       -- party_id of organization for org contact relationship
    l_cen                     VARCHAR2(30) := 'HZ_PARTY_SITES';
  BEGIN
    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_party_sites+',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);

    -- validate p_operation
    IF p_operation IN ('I','U') THEN
      NULL;
    ELSE
      hz_utility_v2pub.DEBUG(p_message=> 'incorrect operation flag sent to pop_hz_party_sites',
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    FOR c_child_rec IN c_child LOOP
      -- collect the child info into variables
      l_lud := c_child_rec.lud;
      l_bo_code := c_child_rec.bo_code;
      l_child_id := c_child_rec.child_id;
      l_location_id := c_child_rec.location_id;
      l_parent_id := c_child_rec.parent_id;
      l_parent_tbl_name := c_child_rec.parent_tbl_name;

      IF(l_bo_code = 'ORG_CONTACT') THEN
        -- get org_contact_id
        OPEN get_org_contact(l_parent_id);
        FETCH get_org_contact INTO l_parent_id;
        CLOSE get_org_contact;
        IF(l_parent_id IS NULL) THEN
          RETURN;
        END IF;
      END IF;

      -- if record not existing, insert into hz_bus_obj_tracking
      BEGIN
        l_child_rec_exists_no := 0;
        SELECT child_id INTO  l_child_rec_exists_no
        FROM  HZ_BUS_OBJ_TRACKING
        WHERE event_id IS NULL
        AND CHILD_ENTITY_NAME = l_cen
        AND CHILD_ID = l_child_id
        AND rownum = 1;

        IF l_child_rec_exists_no <> 0 THEN
          -- data already exists, no need to write
          hz_utility_v2pub.DEBUG(p_message=> 'CHILD record already exists in BOT',
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          -- populate the child bo code also
          INSERT INTO HZ_BUS_OBJ_TRACKING
          ( POPULATED_FLAG, CHILD_OPERATION_FLAG, CHILD_ID, CHILD_ENTITY_NAME, CHILD_BO_CODE,
            LAST_UPDATE_DATE, CREATION_DATE, PARENT_ENTITY_NAME, PARENT_ID, PARENT_BO_CODE
          ) VALUES (
            'N', p_operation, l_child_id, 'HZ_PARTY_SITES', 'PARTY_SITE',
            l_lud, l_lud, l_parent_tbl_name, l_parent_id, l_bo_code);
      END ; -- anonymous block end
    END LOOP;

    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_party_sites-',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);
  EXCEPTION
    WHEN OTHERS THEN
      hz_utility_v2pub.DEBUG(p_message=> SQLERRM,
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END pop_hz_party_sites;

-----------------------------------------------------------------
-- Procedure name: pop_hz_party_preferences()
-- Purpose: populates BOT for HZ_PARTY_PREFERENCES create or update
-- Scope: internal
-- Called From: V2 API
-- Called By: HZ_PARTY_PREFERENCES create or update APIs
-- Input Parameters:
--   p_operation -- contains I or U.  'I' if create API is calling this otherwise 'U'.
--   p_party_preference_id IN NUMBER
--
-- Note:
--   Following are the allowed PARENT and CHILD BO combinations for HZ_PARTY_PREFERENCES
--   This procedure must ensure that the combination is valid before populating BOT
--
-- PARENT BO: ORG :: CHILD BO:
-- PARENT BO: PERSON :: CHILD BO:
-----------------------------------------------------------------
  PROCEDURE pop_hz_party_preferences(p_operation IN VARCHAR2, p_party_preference_id IN NUMBER) IS

    CURSOR C_child IS
      SELECT pp.LAST_UPDATE_DATE lud,  pp.PARTY_ID parent_id,
             'HZ_PARTIES' parent_tbl_name, pp.PARTY_PREFERENCE_ID child_id,
             decode(p.party_type, 'ORGANIZATION', 'ORG', 'PERSON', 'PERSON', NULL) bo_code
      FROM HZ_PARTY_PREFERENCES pp, HZ_PARTIES p
      WHERE pp.PARTY_PREFERENCE_ID = p_party_preference_id
      AND pp.party_id = p.party_id
      AND p.party_type in ('ORGANIZATION', 'PERSON');

    -- local variables
    l_debug_prefix            VARCHAR2(40) := 'pop_hz_party_preferences';
    l_parent_id               NUMBER; -- used to store parent entity identifier
    l_parent_tbl_name         VARCHAR2(30); -- used to store parent entity name
    l_bo_code                 VARCHAR2(30); -- used to store BO Code
    l_child_bo_code           VARCHAR2(30); -- used to store Child BO Code (if child entity is a root node)
    l_child_id                NUMBER; -- used to store HZ_PARTY_PREFERENCES identifier
    l_lud                     DATE; -- used to store the child last update date
    l_child_rec_exists_no     NUMBER;
    l_cen                     VARCHAR2(30) := 'HZ_PARTY_PREFERENCES';
  BEGIN
    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_party_preferences+',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);

    -- validate p_operation
    IF p_operation IN ('I','U') THEN
      NULL;
    ELSE
      hz_utility_v2pub.DEBUG(p_message=> 'incorrect operation flag sent to pop_hz_party_preferences',
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    FOR c_child_rec IN c_child LOOP
      -- collect the child info into variables
      l_lud := c_child_rec.lud;
      l_parent_id := c_child_rec.parent_id;
      l_parent_tbl_name := c_child_rec.parent_tbl_name;
      l_bo_code := c_child_rec.bo_code;
      l_child_id := c_child_rec.child_id;

      -- if record not existing, insert into hz_bus_obj_tracking
      BEGIN
        l_child_rec_exists_no := 0;
        SELECT child_id INTO  l_child_rec_exists_no
        FROM  HZ_BUS_OBJ_TRACKING
        WHERE event_id IS NULL
        AND CHILD_ENTITY_NAME = l_cen
        AND CHILD_ID = l_child_id
        AND rownum = 1;

        IF l_child_rec_exists_no <> 0 THEN
          -- data already exists, no need to write
          hz_utility_v2pub.DEBUG(p_message=> 'CHILD record already exists in BOT',
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          INSERT INTO HZ_BUS_OBJ_TRACKING
          ( POPULATED_FLAG, CHILD_OPERATION_FLAG, CHILD_ID, CHILD_ENTITY_NAME, CHILD_BO_CODE,
            LAST_UPDATE_DATE, CREATION_DATE, PARENT_ENTITY_NAME, PARENT_ID, PARENT_BO_CODE
          ) VALUES (
            'N', p_operation, l_child_id, 'HZ_PARTY_PREFERENCES', NULL,
            l_lud, l_lud, l_parent_tbl_name, l_parent_id, l_bo_code);

          -- populate party record
          pop_parent_record(p_child_id     => l_parent_id,
                            p_lud          => l_lud,
                            p_centity_name => 'HZ_PARTIES',
                            p_cbo_code     => l_bo_code,
                            p_parent_id    => NULL,
                            p_pentity_name => NULL,
                            p_pbo_code     => NULL);
      END ; -- anonymous block end
    END LOOP;

    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_party_preferences-',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);
    EXCEPTION
      WHEN OTHERS THEN
        hz_utility_v2pub.DEBUG(p_message=> SQLERRM,
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END pop_hz_party_preferences;

-----------------------------------------------------------------
-- Procedure name: pop_hz_org_contact_roles()
-- Purpose: populates BOT for HZ_ORG_CONTACT_ROLES create or update
-- Scope: internal
-- Called From: V2 API
-- Called By: HZ_ORG_CONTACT_ROLES create or update APIs
-- Input Parameters:
--   p_operation -- contains I or U.  'I' if create API is calling this otherwise 'U'.
--   p_org_contact_role_id IN NUMBER
--
-- Note:
--   Following are the allowed PARENT and CHILD BO combinations for HZ_ORG_CONTACT_ROLES
--   This procedure must ensure that the combination is valid before populating BOT
--
-- PARENT BO: ORG_CONTACT :: CHILD BO:
-----------------------------------------------------------------
  PROCEDURE pop_hz_org_contact_roles(p_operation IN VARCHAR2, p_org_contact_role_id IN NUMBER) IS

    -- cursor statement to select the info from child table
    CURSOR C_child IS
      SELECT ocr.LAST_UPDATE_DATE lud, ocr.ORG_CONTACT_ID parent_id,
             ocr.ORG_CONTACT_ROLE_ID child_id, pr.object_id object_id
      FROM HZ_ORG_CONTACT_ROLES ocr, HZ_ORG_CONTACTS oc, HZ_RELATIONSHIPS pr
      WHERE ORG_CONTACT_ROLE_ID = P_ORG_CONTACT_ROLE_ID
      AND ocr.org_contact_id = oc.org_contact_id
      AND oc.party_relationship_id = pr.relationship_id
      AND pr.object_type = 'ORGANIZATION'
      AND pr.subject_type = 'PERSON'
      AND rownum = 1;

    -- local variables
    l_debug_prefix            VARCHAR2(40) := 'pop_hz_org_contact_roles';
    l_parent_id               NUMBER; -- used to store parent entity identifier
    l_child_id                NUMBER; -- used to store HZ_ORG_CONTACT_ROLES identifier
    l_lud                     DATE; -- used to store the child last update date
    l_child_rec_exists_no     NUMBER;
    l_org_id                  NUMBER;
    l_cen                     VARCHAR2(30) := 'HZ_ORG_CONTACT_ROLES';
  BEGIN
    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_org_contact_roles+',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);

    -- validate p_operation
    IF p_operation IN ('I','U') THEN
      NULL;
    ELSE
      hz_utility_v2pub.DEBUG(p_message=> 'incorrect operation flag sent to pop_hz_org_contact_roles',
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    FOR c_child_rec IN c_child LOOP
      -- collect the child info into variables
      l_lud := c_child_rec.lud;
      l_parent_id := c_child_rec.parent_id;
      l_child_id := c_child_rec.child_id;
      l_org_id := c_child_rec.object_id;

      -- if record not existing, insert into hz_bus_obj_tracking
      BEGIN
        l_child_rec_exists_no := 0;
        SELECT child_id INTO  l_child_rec_exists_no
        FROM  HZ_BUS_OBJ_TRACKING
        WHERE event_id IS NULL
        AND CHILD_ENTITY_NAME = l_cen
        AND CHILD_ID = l_child_id
        AND rownum = 1;

        IF l_child_rec_exists_no <> 0 THEN
          -- data already exists, no need to write
          hz_utility_v2pub.DEBUG(p_message=> 'CHILD record already exists in BOT',
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          INSERT INTO HZ_BUS_OBJ_TRACKING
          ( POPULATED_FLAG, CHILD_OPERATION_FLAG, CHILD_ID, CHILD_ENTITY_NAME, CHILD_BO_CODE,
            LAST_UPDATE_DATE, CREATION_DATE, PARENT_ENTITY_NAME, PARENT_ID, PARENT_BO_CODE
          ) VALUES (
            'N', p_operation, l_child_id, 'HZ_ORG_CONTACT_ROLES', NULL,
            l_lud, l_lud, 'HZ_ORG_CONTACTS', l_parent_id, 'ORG_CONTACT');

          -- populate org party record
          pop_parent_record(p_child_id     => l_parent_id,
                            p_lud          => l_lud,
                            p_centity_name => 'HZ_ORG_CONTACTS',
                            p_cbo_code     => 'ORG_CONTACT',
                            p_parent_id    => l_org_id,
                            p_pentity_name => 'HZ_PARTIES',
                            p_pbo_code     => 'ORG');
      END ; -- anonymous block end
    END LOOP;

    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_org_contact_roles-',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);
  EXCEPTION
    WHEN OTHERS THEN
      hz_utility_v2pub.DEBUG(p_message=> SQLERRM,
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END pop_hz_org_contact_roles;

-----------------------------------------------------------------
-- Procedure name: pop_hz_org_contacts()
-- Purpose: populates BOT for HZ_ORG_CONTACTS create or update
-- Scope: internal
-- Called From: V2 API
-- Called By: HZ_ORG_CONTACTS create or update APIs
-- Input Parameters:
--   p_operation -- contains I or U.  'I' if create API is calling this otherwise 'U'.
--   p_org_contact_id IN NUMBER
--
-- Note:
--   Following are the allowed PARENT and CHILD BO combinations for HZ_ORG_CONTACTS
--   This procedure must ensure that the combination is valid before populating BOT
--
-- PARENT BO: ORG :: CHILD BO: ORG_CONTACT
-----------------------------------------------------------------
  PROCEDURE pop_hz_org_contacts(p_operation IN VARCHAR2, p_org_contact_id IN NUMBER) IS

    -- cursor statement to select the info from child table
    CURSOR C_child IS
      SELECT oc.LAST_UPDATE_DATE lud, oc.ORG_CONTACT_ID child_id,
             pr.object_id parent_id, pr.subject_id person_id, pr.relationship_id rel_id
      FROM HZ_ORG_CONTACTS oc, HZ_RELATIONSHIPS pr
      WHERE oc.ORG_CONTACT_ID = P_ORG_CONTACT_ID
      AND oc.party_relationship_id = pr.relationship_id
      AND pr.object_type = 'ORGANIZATION'
      AND pr.subject_type = 'PERSON'
      AND rownum = 1;

    -- local variables
    l_debug_prefix            VARCHAR2(40) := 'pop_hz_org_contacts';
    l_parent_id               NUMBER; -- used to store parent entity identifier
    l_child_id                NUMBER; -- used to store HZ_ORG_CONTACTS identifier
    l_lud                     DATE; -- used to store the child last update date
    l_child_rec_exists_no     NUMBER;
    l_rel_id                  NUMBER;
    l_person_id               NUMBER;
    l_pop_flag                VARCHAR2(1);
    l_cen                     VARCHAR2(30) := 'HZ_ORG_CONTACTS';
  BEGIN
    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_org_contacts+',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);

    -- validate p_operation
    IF p_operation IN ('I','U') THEN
      NULL;
    ELSE
      hz_utility_v2pub.DEBUG(p_message=> 'incorrect operation flag sent to pop_hz_org_contacts',
                             p_prefix=>l_debug_prefix,
       p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    FOR c_child_rec IN c_child LOOP
      -- collect the child info into variables
      l_lud := c_child_rec.lud;
      l_parent_id := c_child_rec.parent_id;
      l_child_id := c_child_rec.child_id;
      l_person_id := c_child_rec.person_id;
      l_rel_id := c_child_rec.rel_id;

      -- if record not existing, insert into hz_bus_obj_tracking
      BEGIN
        l_child_rec_exists_no := 0;
        SELECT child_id, populated_flag INTO  l_child_rec_exists_no, l_pop_flag
        FROM  HZ_BUS_OBJ_TRACKING
        WHERE event_id IS NULL
        AND CHILD_ENTITY_NAME = l_cen
        AND CHILD_ID = l_child_id
        AND rownum = 1;

        IF l_child_rec_exists_no <> 0 THEN
          IF(l_pop_flag = 'Y') THEN
            UPDATE HZ_BUS_OBJ_TRACKING
            SET populated_flag = 'N'
            WHERE event_id IS NULL
            AND CHILD_ENTITY_NAME = l_cen
            AND CHILD_ID = l_child_id;
          END IF;
          -- data already exists, no need to write
          hz_utility_v2pub.DEBUG(p_message=> 'CHILD record already exists in BOT',
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          -- populate the child bo code also
          INSERT INTO HZ_BUS_OBJ_TRACKING
          ( POPULATED_FLAG, CHILD_OPERATION_FLAG, CHILD_ID, CHILD_ENTITY_NAME, CHILD_BO_CODE,
            LAST_UPDATE_DATE, CREATION_DATE, PARENT_ENTITY_NAME, PARENT_ID, PARENT_BO_CODE
          ) VALUES (
            'N', p_operation, l_child_id, 'HZ_ORG_CONTACTS', 'ORG_CONTACT',
            l_lud, l_lud, 'HZ_PARTIES', l_parent_id, 'ORG');

          -- populate subject person as child
          pop_parent_record(p_child_id     => l_person_id,
                            p_lud          => l_lud,
                            p_centity_name => 'HZ_PARTIES',
                            p_cbo_code     => 'PERSON_CONTACT',
                            p_parent_id    => l_child_id,
                            p_pentity_name => 'HZ_ORG_CONTACTS',
                            p_pbo_code     => 'ORG_CONTACT');

          -- populate relationship as child
          pop_parent_record(p_child_id     => l_rel_id,
                            p_lud          => l_lud,
                            p_centity_name => 'HZ_RELATIONSHIPS',
                            p_cbo_code     => NULL,
                            p_parent_id    => l_child_id,
                            p_pentity_name => 'HZ_ORG_CONTACTS',
                            p_pbo_code     => 'ORG_CONTACT');
      END ; -- anonymous block end
    END LOOP;

    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_org_contacts-',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);
  EXCEPTION
    WHEN OTHERS THEN
      hz_utility_v2pub.DEBUG(p_message=> SQLERRM,
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END pop_hz_org_contacts;

-----------------------------------------------------------------
-- Procedure name: pop_hz_organization_profiles()
-- Purpose: populates BOT for HZ_ORGANIZATION_PROFILES create or update
-- Scope: internal
-- Called From: V2 API
-- Called By: HZ_ORGANIZATION_PROFILES create or update APIs
-- Input Parameters:
--   p_operation -- contains I or U.  'I' if create API is calling this otherwise 'U'.
--   p_organization_profile_id IN NUMBER
--
-- Note:
--   Following are the allowed PARENT and CHILD BO combinations for HZ_ORGANIZATION_PROFILES
--   This procedure must ensure that the combination is valid before populating BOT
--
-- PARENT BO: ORG :: CHILD BO:
-----------------------------------------------------------------
  PROCEDURE pop_hz_organization_profiles(p_operation IN VARCHAR2, p_organization_profile_id IN NUMBER) IS

    -- cursor statement to select the info from child table
    CURSOR C_child IS
      SELECT LAST_UPDATE_DATE lud, PARTY_ID parent_id, ORGANIZATION_PROFILE_ID child_id
      FROM HZ_ORGANIZATION_PROFILES
      WHERE ORGANIZATION_PROFILE_ID = P_ORGANIZATION_PROFILE_ID;

    -- local variables
    l_debug_prefix            VARCHAR2(40) := 'pop_hz_organization_profiles';
    l_parent_id               NUMBER; -- used to store parent entity identifier
    l_child_id                NUMBER; -- used to store HZ_ORGANIZATION_PROFILES identifier
    l_lud                     DATE; -- used to store the child last update date
    l_child_rec_exists_no     NUMBER;
    l_cen                     VARCHAR2(30) := 'HZ_ORGANIZATION_PROFILES';
  BEGIN
    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_organization_profiles+',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);

    -- validate p_operation
    IF p_operation IN ('I','U') THEN
      NULL;
    ELSE
      hz_utility_v2pub.DEBUG(p_message=> 'incorrect operation flag sent to pop_hz_organization_profiles',
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    FOR c_child_rec IN c_child LOOP
      -- collect the child info into variables
      l_lud := c_child_rec.lud;
      l_parent_id := c_child_rec.parent_id;
      l_child_id := c_child_rec.child_id;

      -- if record not existing, insert into hz_bus_obj_tracking
      BEGIN
        l_child_rec_exists_no := 0;
        SELECT child_id INTO  l_child_rec_exists_no
        FROM  HZ_BUS_OBJ_TRACKING
        WHERE event_id IS NULL
        AND CHILD_ENTITY_NAME = l_cen
        AND CHILD_ID = l_child_id
        AND rownum = 1;

        IF l_child_rec_exists_no <> 0 THEN
          -- data already exists, no need to write
          hz_utility_v2pub.DEBUG(p_message=> 'CHILD record already exists in BOT',
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          INSERT INTO HZ_BUS_OBJ_TRACKING
          ( POPULATED_FLAG, CHILD_OPERATION_FLAG, CHILD_ID, CHILD_ENTITY_NAME, CHILD_BO_CODE,
            LAST_UPDATE_DATE, CREATION_DATE, PARENT_ENTITY_NAME, PARENT_ID, PARENT_BO_CODE
          ) VALUES (
            'N', p_operation, l_child_id, 'HZ_ORGANIZATION_PROFILES', NULL,
            l_lud, l_lud, 'HZ_PARTIES', l_parent_id, 'ORG');

          -- populate org party record
          pop_parent_record(p_child_id     => l_parent_id,
                            p_lud          => l_lud,
                            p_centity_name => 'HZ_PARTIES',
                            p_cbo_code     => 'ORG',
                            p_parent_id    => NULL,
                            p_pentity_name => NULL,
                            p_pbo_code     => NULL);
      END ; -- anonymous block end
    END LOOP;

    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_organization_profiles-',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);
  EXCEPTION
    WHEN OTHERS THEN
      hz_utility_v2pub.DEBUG(p_message=> SQLERRM,
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END pop_hz_organization_profiles;

-----------------------------------------------------------------
-- Procedure name: pop_hz_locations()
-- Purpose: populates BOT for HZ_LOCATIONS create or update
-- Scope: internal
-- Called From: V2 API
-- Called By: HZ_LOCATIONS create or update APIs
-- Input Parameters:
--   p_operation -- contains I or U.  'I' if create API is calling this otherwise 'U'.
--   p_location_id IN NUMBER
--
-- Note:
--   Following are the allowed PARENT and CHILD BO combinations for HZ_LOCATIONS
--   This procedure must ensure that the combination is valid before populating BOT
--
-- PARENT BO: PARTY_SITE :: CHILD BO: LOCATION
-----------------------------------------------------------------
  PROCEDURE pop_hz_locations(p_operation IN VARCHAR2, p_location_id IN NUMBER) IS

    CURSOR c_child IS -- this is incorrect - please change
      SELECT LAST_UPDATE_DATE lud, LOCATION_ID child_id
      FROM HZ_LOCATIONS
      WHERE location_id = p_location_id;

    CURSOR c_ps(l_loc_id NUMBER) IS
      SELECT party_site_id
      FROM HZ_PARTY_SITES ps, HZ_PARTIES p
      WHERE ps.location_id = l_loc_id
      AND ps.party_id = p.party_id;

    -- local variables
    l_debug_prefix    VARCHAR2(40) := 'pop_hz_locations';
    l_parent_id       NUMBER; -- used to store parent entity identifier
    l_parent_tbl_name VARCHAR2(30); -- used to store parent entity name
    l_bo_code         VARCHAR2(30); -- used to store BO Code
    l_child_bo_code      VARCHAR2(30); -- used to store Child BO Code (if child entity is a root node)
    l_child_id        NUMBER; -- used to store HZ_LOCATIONS identifier
    l_lud             DATE; -- used to store the child last update date
    l_child_rec_exists_no     NUMBER;
    l_cen                     VARCHAR2(30) := 'HZ_LOCATIONS';
  BEGIN
    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_locations+',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);

    -- validate p_operation
    IF p_operation IN ('I','U') THEN
      NULL;
    ELSE
      hz_utility_v2pub.DEBUG(p_message=> 'incorrect operation flag sent to pop_hz_locations',
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    FOR c_child_rec IN c_child LOOP
      l_lud := c_child_rec.lud;
      l_child_id := c_child_rec.child_id;

      -- if record not existing, insert into hz_bus_obj_tracking
      BEGIN
        l_child_rec_exists_no := 0;
        SELECT child_id INTO  l_child_rec_exists_no
        FROM  HZ_BUS_OBJ_TRACKING
        WHERE event_id IS NULL
        AND CHILD_ENTITY_NAME = l_cen
        AND CHILD_ID = l_child_id
        AND rownum = 1;

        IF l_child_rec_exists_no <> 0 THEN
          -- data already exists, no need to write
          hz_utility_v2pub.DEBUG(p_message=> 'CHILD record already exists in BOT',
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          OPEN c_ps(l_child_id);
          LOOP
            FETCH c_ps INTO l_parent_id;
            EXIT WHEN c_ps%NOTFOUND;
            -- populate the child bo code also
            INSERT INTO HZ_BUS_OBJ_TRACKING
            ( POPULATED_FLAG, CHILD_OPERATION_FLAG, CHILD_ID, CHILD_ENTITY_NAME, CHILD_BO_CODE,
              LAST_UPDATE_DATE, CREATION_DATE, PARENT_ENTITY_NAME, PARENT_ID, PARENT_BO_CODE
            ) VALUES (
              'N', p_operation, l_child_id, 'HZ_LOCATIONS', 'LOCATION',
              l_lud, l_lud, 'HZ_PARTY_SITES', l_parent_id, 'PARTY_SITE');
          END LOOP;
          CLOSE c_ps;
      END ; -- anonymous block end
    END LOOP;

    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_locations-',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);
  EXCEPTION
    WHEN OTHERS THEN
      hz_utility_v2pub.DEBUG(p_message=> SQLERRM,
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END pop_hz_locations;

-----------------------------------------------------------------
-- Procedure name: pop_hz_financial_reports()
-- Purpose: populates BOT for HZ_FINANCIAL_REPORTS create or update
-- Scope: internal
-- Called From: V2 API
-- Called By: HZ_FINANCIAL_REPORTS create or update APIs
-- Input Parameters:
--   p_operation -- contains I or U.  'I' if create API is calling this otherwise 'U'.
--   p_financial_report_id IN NUMBER
--
-- Note:
--   Following are the allowed PARENT and CHILD BO combinations for HZ_FINANCIAL_REPORTS
--   This procedure must ensure that the combination is valid before populating BOT
--
-- PARENT BO: ORG :: CHILD BO: FIN_REPORT
-----------------------------------------------------------------
  PROCEDURE pop_hz_financial_reports(p_operation IN VARCHAR2, p_financial_report_id IN NUMBER) IS

    -- cursor statement to select the info from child table
    CURSOR C_child IS
      SELECT fr.LAST_UPDATE_DATE lud, fr.PARTY_ID parent_id, fr.FINANCIAL_REPORT_ID child_id,
             decode(p.party_type, 'ORGANIZATION', 'ORG', null) bo_code
      FROM HZ_FINANCIAL_REPORTS fr, HZ_PARTIES p
      WHERE fr.FINANCIAL_REPORT_ID = P_FINANCIAL_REPORT_ID
      AND fr.party_id = p.party_id
      AND p.party_type = 'ORGANIZATION';

    -- local variables
    l_debug_prefix    VARCHAR2(40) := 'pop_hz_financial_reports';
    l_parent_id       NUMBER; -- used to store parent entity identifier
    l_bo_code         VARCHAR2(30); -- used to store BO Code
    l_child_bo_code      VARCHAR2(30); -- used to store Child BO Code (if child entity is a root node)
    l_child_id        NUMBER; -- used to store HZ_FINANCIAL_REPORTS identifier
    l_lud             DATE; -- used to store the child last update date
    l_child_rec_exists_no     NUMBER;
    l_pop_flag                VARCHAR2(1);
    l_cen                     VARCHAR2(30) := 'HZ_FINANCIAL_REPORTS';
  BEGIN
    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_financial_reports+',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);

    -- validate p_operation
    IF p_operation IN ('I','U') THEN
      NULL;
    ELSE
      hz_utility_v2pub.DEBUG(p_message=> 'incorrect operation flag sent to pop_hz_financial_reports',
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    FOR c_child_rec IN c_child LOOP
      -- collect the child info into variables
      l_lud := c_child_rec.lud;
      l_parent_id := c_child_rec.parent_id;
      l_bo_code := c_child_rec.bo_code;
      l_child_id := c_child_rec.child_id;

      -- if record not existing, insert into hz_bus_obj_tracking
      BEGIN
        l_child_rec_exists_no := 0;
        SELECT child_id, populated_flag INTO  l_child_rec_exists_no, l_pop_flag
        FROM  HZ_BUS_OBJ_TRACKING
        WHERE event_id IS NULL
        AND CHILD_ENTITY_NAME = l_cen
        AND CHILD_ID = l_child_id
        AND rownum = 1;

        IF l_child_rec_exists_no <> 0 THEN
          IF(l_pop_flag = 'Y') THEN
            UPDATE HZ_BUS_OBJ_TRACKING
            SET populated_flag = 'N'
            WHERE event_id IS NULL
            AND CHILD_ENTITY_NAME = l_cen
            AND CHILD_ID = l_child_id;
          END IF;
          -- data already exists, no need to write
          hz_utility_v2pub.DEBUG(p_message=> 'CHILD record already exists in BOT',
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          -- populate the child bo code also
          INSERT INTO HZ_BUS_OBJ_TRACKING
          ( POPULATED_FLAG, CHILD_OPERATION_FLAG, CHILD_ID, CHILD_ENTITY_NAME, CHILD_BO_CODE,
            LAST_UPDATE_DATE, CREATION_DATE, PARENT_ENTITY_NAME, PARENT_ID, PARENT_BO_CODE
          ) VALUES (
            'N', p_operation, l_child_id, 'HZ_FINANCIAL_REPORTS', 'FIN_REPORT',
            l_lud, l_lud, 'HZ_PARTIES', l_parent_id, l_bo_code);

          -- populate org party record
          pop_parent_record(p_child_id     => l_parent_id,
                            p_lud          => l_lud,
                            p_centity_name => 'HZ_PARTIES',
                            p_cbo_code     => l_bo_code,
                            p_parent_id    => NULL,
                            p_pentity_name => NULL,
                            p_pbo_code     => NULL);
      END ; -- anonymous block end
    END LOOP;

    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_financial_reports-',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);
  EXCEPTION
    WHEN OTHERS THEN
      hz_utility_v2pub.DEBUG(p_message=> SQLERRM,
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END pop_hz_financial_reports;

-----------------------------------------------------------------
-- Procedure name: pop_hz_financial_profile()
-- Purpose: populates BOT for HZ_FINANCIAL_PROFILE create or update
-- Scope: internal
-- Called From: V2 API
-- Called By: HZ_FINANCIAL_PROFILE create or update APIs
-- Input Parameters:
--   p_operation -- contains I or U.  'I' if create API is calling this otherwise 'U'.
--   p_financial_profile_id IN NUMBER
--
-- Note:
--   Following are the allowed PARENT and CHILD BO combinations for HZ_FINANCIAL_PROFILE
--   This procedure must ensure that the combination is valid before populating BOT
--
-- PARENT BO: ORG :: CHILD BO:
-- PARENT BO: PERSON :: CHILD BO:
-----------------------------------------------------------------
  PROCEDURE pop_hz_financial_profile(p_operation IN VARCHAR2, p_financial_profile_id IN NUMBER) IS

    -- cursor statement to select the info from child table
    CURSOR c_child IS
      SELECT fp.LAST_UPDATE_DATE lud, fp.PARTY_ID parent_id,
             fp.FINANCIAL_PROFILE_ID child_id,
             decode(p.party_type, 'ORGANIZATION', 'ORG', 'PERSON', 'PERSON', NULL) bo_code
      FROM HZ_FINANCIAL_PROFILE fp, HZ_PARTIES p
      WHERE fp.FINANCIAL_PROFILE_ID = P_FINANCIAL_PROFILE_ID
      AND fp.party_id = p.party_id
      AND p.party_type in ('ORGANIZATION', 'PERSON');

    -- local variables
    l_debug_prefix    VARCHAR2(40) := 'pop_hz_financial_profile';
    l_parent_id       NUMBER; -- used to store parent entity identifier
    l_bo_code         VARCHAR2(30); -- used to store BO Code
    l_child_id        NUMBER; -- used to store HZ_FINANCIAL_PROFILE identifier
    l_lud             DATE; -- used to store the child last update date
    l_child_rec_exists_no     NUMBER;
    l_cen                     VARCHAR2(30) := 'HZ_FINANCIAL_PROFILE';
  BEGIN
    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_financial_profile+',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);

    -- validate p_operation
    IF p_operation IN ('I','U') THEN
      NULL;
    ELSE
      hz_utility_v2pub.DEBUG(p_message=> 'incorrect operation flag sent to pop_hz_financial_profile',
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    FOR c_child_rec IN c_child LOOP
      -- collect the child info into variables
      l_lud := c_child_rec.lud;
      l_parent_id := c_child_rec.parent_id;
      l_bo_code := c_child_rec.bo_code;
      l_child_id := c_child_rec.child_id;

      -- if record not existing, insert into hz_bus_obj_tracking
      BEGIN
        l_child_rec_exists_no := 0;
        SELECT child_id INTO  l_child_rec_exists_no
        FROM  HZ_BUS_OBJ_TRACKING
        WHERE event_id IS NULL
        AND CHILD_ENTITY_NAME = l_cen
        AND CHILD_ID = l_child_id
        AND rownum = 1;

        IF l_child_rec_exists_no <> 0 THEN
          -- data already exists, no need to write
          hz_utility_v2pub.DEBUG(p_message=> 'CHILD record already exists in BOT',
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          INSERT INTO HZ_BUS_OBJ_TRACKING
          ( POPULATED_FLAG, CHILD_OPERATION_FLAG, CHILD_ID, CHILD_ENTITY_NAME, CHILD_BO_CODE,
            LAST_UPDATE_DATE, CREATION_DATE, PARENT_ENTITY_NAME, PARENT_ID, PARENT_BO_CODE
          ) VALUES (
            'N', p_operation, l_child_id, 'HZ_FINANCIAL_PROFILE', NULL,
            l_lud, l_lud, 'HZ_PARTIES', l_parent_id, l_bo_code);

          -- populate org party record
          pop_parent_record(p_child_id     => l_parent_id,
                            p_lud          => l_lud,
                            p_centity_name => 'HZ_PARTIES',
                            p_cbo_code     => l_bo_code,
                            p_parent_id    => NULL,
                            p_pentity_name => NULL,
                            p_pbo_code     => NULL);
      END ; -- anonymous block end
    END LOOP;

    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_financial_profile-',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);
  EXCEPTION
    WHEN OTHERS THEN
      hz_utility_v2pub.DEBUG(p_message=> SQLERRM,
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END pop_hz_financial_profile;

-----------------------------------------------------------------
-- Procedure name: pop_hz_financial_numbers()
-- Purpose: populates BOT for HZ_FINANCIAL_NUMBERS create or update
-- Scope: internal
-- Called From: V2 API
-- Called By: HZ_FINANCIAL_NUMBERS create or update APIs
-- Input Parameters:
--   p_operation -- contains I or U.  'I' if create API is calling this otherwise 'U'.
--   p_financial_number_id IN NUMBER
--
-- Note:
--   Following are the allowed PARENT and CHILD BO combinations for HZ_FINANCIAL_NUMBERS
--   This procedure must ensure that the combination is valid before populating BOT
--
-- PARENT BO: FIN_REPORT :: CHILD BO:
-----------------------------------------------------------------
  PROCEDURE pop_hz_financial_numbers(p_operation IN VARCHAR2, p_financial_number_id IN NUMBER) IS

    -- cursor statement to select the info from child table
    CURSOR C_child IS
      SELECT fn.LAST_UPDATE_DATE lud, fn.FINANCIAL_REPORT_ID parent_id,
             fn.FINANCIAL_NUMBER_ID child_id, fr.party_id party_id
      FROM HZ_FINANCIAL_NUMBERS fn, HZ_FINANCIAL_REPORTS fr, HZ_PARTIES p
      WHERE fn.FINANCIAL_NUMBER_ID = P_FINANCIAL_NUMBER_ID
      AND fn.financial_report_id = fr.financial_report_id
      AND fr.party_id = p.party_id
      AND p.party_type = 'ORGANIZATION';

    -- local variables
    l_debug_prefix            VARCHAR2(40) := 'pop_hz_financial_numbers';
    l_parent_id               NUMBER; -- used to store parent entity identifier
    l_child_id                NUMBER; -- used to store HZ_FINANCIAL_NUMBERS identifier
    l_lud                     DATE; -- used to store the child last update date
    l_child_rec_exists_no     NUMBER;
    l_party_id                NUMBER;
    l_cen                     VARCHAR2(30) := 'HZ_FINANCIAL_NUMBERS';
  BEGIN
    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_financial_numbers+',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);

    -- validate p_operation
    IF p_operation IN ('I','U') THEN
      NULL;
    ELSE
      hz_utility_v2pub.DEBUG(p_message=> 'incorrect operation flag sent to pop_hz_financial_numbers',
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    FOR c_child_rec IN c_child LOOP
      -- collect the child info into variables
      l_lud := c_child_rec.lud;
      l_child_id := c_child_rec.child_id;
      l_parent_id := c_child_rec.parent_id;
      l_party_id := c_child_rec.party_id;

      -- if record not existing, insert into hz_bus_obj_tracking
      BEGIN
        l_child_rec_exists_no := 0;
        SELECT child_id INTO  l_child_rec_exists_no
        FROM  HZ_BUS_OBJ_TRACKING
        WHERE event_id IS NULL
        AND CHILD_ENTITY_NAME = l_cen
        AND CHILD_ID = l_child_id
        AND rownum = 1;

        IF l_child_rec_exists_no <> 0 THEN
          -- data already exists, no need to write
          hz_utility_v2pub.DEBUG(p_message=> 'CHILD record already exists in BOT',
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          INSERT INTO HZ_BUS_OBJ_TRACKING
          ( POPULATED_FLAG, CHILD_OPERATION_FLAG, CHILD_ID, CHILD_ENTITY_NAME, CHILD_BO_CODE,
            LAST_UPDATE_DATE, CREATION_DATE, PARENT_ENTITY_NAME, PARENT_ID, PARENT_BO_CODE
          ) VALUES (
            'N', p_operation, l_child_id, 'HZ_FINANCIAL_NUMBERS', NULL,
            l_lud, l_lud, 'HZ_FINANCIAL_REPORTS', l_parent_id, 'FIN_REPORT');

          -- populate org party record
          pop_parent_record(p_child_id     => l_parent_id,
                            p_lud          => l_lud,
                            p_centity_name => 'HZ_FINANCIAL_REPORTS',
                            p_cbo_code     => 'FIN_REPORT',
                            p_parent_id    => l_party_id,
                            p_pentity_name => 'HZ_PARTIES',
                            p_pbo_code     => 'ORG');

          -- populate org party record
          pop_parent_record(p_child_id     => l_party_id,
                            p_lud          => l_lud,
                            p_centity_name => 'HZ_PARTIES',
                            p_cbo_code     => 'ORG',
                            p_parent_id    => NULL,
                            p_pentity_name => NULL,
                            p_pbo_code     => NULL);
      END ; -- anonymous block end
    END LOOP;

    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_financial_numbers-',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);
  EXCEPTION
    WHEN OTHERS THEN
      hz_utility_v2pub.DEBUG(p_message=> SQLERRM,
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END pop_hz_financial_numbers;

-----------------------------------------------------------------
-- Procedure name: pop_hz_employment_history()
-- Purpose: populates BOT for HZ_EMPLOYMENT_HISTORY create or update
-- Scope: internal
-- Called From: V2 API
-- Called By: HZ_EMPLOYMENT_HISTORY create or update APIs
-- Input Parameters:
--   p_operation -- contains I or U.  'I' if create API is calling this otherwise 'U'.
--   p_employment_history_id IN NUMBER
--
-- Note:
--   Following are the allowed PARENT and CHILD BO combinations for HZ_EMPLOYMENT_HISTORY
--   This procedure must ensure that the combination is valid before populating BOT
--
-- PARENT BO: PERSON :: CHILD BO: EMP_HIST
-----------------------------------------------------------------
  PROCEDURE pop_hz_employment_history(p_operation IN VARCHAR2, p_EMPLOYMENT_HISTORY_ID IN NUMBER) IS

    -- cursor statement to select the info from child table
    CURSOR C_child IS
      SELECT eh.LAST_UPDATE_DATE lud, eh.PARTY_ID parent_id,
             eh.EMPLOYMENT_HISTORY_ID child_id
      FROM HZ_EMPLOYMENT_HISTORY eh, HZ_PARTIES p
      WHERE eh.EMPLOYMENT_HISTORY_ID = P_EMPLOYMENT_HISTORY_ID
      AND eh.party_id = p.party_id
      AND p.party_type = 'PERSON';

    -- local variables
    l_debug_prefix    VARCHAR2(40) := 'pop_hz_employment_history';
    l_parent_id       NUMBER; -- used to store parent entity identifier
    l_child_id        NUMBER; -- used to store HZ_EMPLOYMENT_HISTORY identifier
    l_lud             DATE; -- used to store the child last update date
    l_child_rec_exists_no     NUMBER;
    l_pop_flag                VARCHAR2(1);
    l_cen                     VARCHAR2(30) := 'HZ_EMPLOYMENT_HISTORY';
  BEGIN
    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_employment_history+',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);

    -- validate p_operation
    IF p_operation IN ('I','U') THEN
      NULL;
    ELSE
      hz_utility_v2pub.DEBUG(p_message=> 'incorrect operation flag sent to pop_hz_employment_history',
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    FOR c_child_rec IN c_child LOOP
      -- collect the child info into variables
      l_lud := c_child_rec.lud;
      l_child_id := c_child_rec.child_id;
      l_parent_id := c_child_rec.parent_id;

      -- if record not existing, insert into hz_bus_obj_tracking
      BEGIN
        l_child_rec_exists_no := 0;
        SELECT child_id, populated_flag INTO  l_child_rec_exists_no, l_pop_flag
        FROM  HZ_BUS_OBJ_TRACKING
        WHERE event_id IS NULL
        AND CHILD_ENTITY_NAME = 'HZ_EMPLOYMENT_HISTORY'
        AND CHILD_ID = l_child_id
        AND rownum = 1;

        IF l_child_rec_exists_no <> 0 THEN
          IF(l_pop_flag = 'Y') THEN
            UPDATE HZ_BUS_OBJ_TRACKING
            SET populated_flag = 'N'
            WHERE event_id IS NULL
            AND CHILD_ENTITY_NAME = l_cen
            AND CHILD_ID = l_child_id;
          END IF;
          -- data already exists, no need to write
          hz_utility_v2pub.DEBUG(p_message=> 'CHILD record already exists in BOT',
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          -- populate the child bo code also
          INSERT INTO HZ_BUS_OBJ_TRACKING
          ( POPULATED_FLAG, CHILD_OPERATION_FLAG, CHILD_ID, CHILD_ENTITY_NAME, CHILD_BO_CODE,
            LAST_UPDATE_DATE, CREATION_DATE, PARENT_ENTITY_NAME, PARENT_ID, PARENT_BO_CODE
          ) VALUES (
            'N', p_operation, l_child_id, 'HZ_EMPLOYMENT_HISTORY', 'EMP_HIST',
            l_lud, l_lud, 'HZ_PARTIES', l_parent_id, 'PERSON');

         -- populate org party record
         pop_parent_record(p_child_id     => l_parent_id,
                           p_lud          => l_lud,
                           p_centity_name => 'HZ_PARTIES',
                           p_cbo_code     => 'PERSON',
                           p_parent_id    => NULL,
                           p_pentity_name => NULL,
                           p_pbo_code     => NULL);
      END ; -- anonymous block end
    END LOOP;

    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_employment_history-',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);
  EXCEPTION
    WHEN OTHERS THEN
      hz_utility_v2pub.DEBUG(p_message=> SQLERRM,
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END pop_hz_employment_history;

-----------------------------------------------------------------
-- Procedure name: pop_hz_education()
-- Purpose: populates BOT for HZ_EDUCATION create or update
-- Scope: internal
-- Called From: V2 API
-- Called By: HZ_EDUCATION create or update APIs
-- Input Parameters:
--   p_operation -- contains I or U.  'I' if create API is calling this otherwise 'U'.
--   p_education_id IN NUMBER
--
-- Note:
--   Following are the allowed PARENT and CHILD BO combinations for HZ_EDUCATION
--   This procedure must ensure that the combination is valid before populating BOT
--
-- PARENT BO: PERSON :: CHILD BO:
-----------------------------------------------------------------
  PROCEDURE pop_hz_education(p_operation IN VARCHAR2, p_EDUCATION_ID IN NUMBER) IS

    -- cursor statement to select the info from child table
    CURSOR C_child IS
      SELECT edu.LAST_UPDATE_DATE lud, edu.PARTY_ID parent_id, edu.EDUCATION_ID child_id
      FROM HZ_EDUCATION edu, HZ_PARTIES p
      WHERE edu.EDUCATION_ID = P_EDUCATION_ID
      AND edu.party_id = p.party_id
      AND p.party_type = 'PERSON';

    -- local variables
    l_debug_prefix    VARCHAR2(40) := 'pop_hz_education';
    l_parent_id       NUMBER; -- used to store parent entity identifier
    l_child_id        NUMBER; -- used to store HZ_EDUCATION identifier
    l_lud             DATE; -- used to store the child last update date
    l_child_rec_exists_no     NUMBER;
    l_cen                     VARCHAR2(30) := 'HZ_EDUCATION';
  BEGIN
    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_education+',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);

    -- validate p_operation
    IF p_operation IN ('I','U') THEN
      NULL;
    ELSE
      hz_utility_v2pub.DEBUG(p_message=> 'incorrect operation flag sent to pop_hz_education',
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    FOR c_child_rec IN c_child LOOP
      -- collect the child info into variables
      l_lud := c_child_rec.lud;
      l_child_id := c_child_rec.child_id;
      l_parent_id := c_child_rec.parent_id;

      -- if record not existing, insert into hz_bus_obj_tracking
      BEGIN
        l_child_rec_exists_no := 0;
        SELECT child_id INTO  l_child_rec_exists_no
        FROM  HZ_BUS_OBJ_TRACKING
        WHERE event_id IS NULL
        AND CHILD_ENTITY_NAME = l_cen
        AND CHILD_ID = l_child_id
        AND rownum = 1;

        IF l_child_rec_exists_no <> 0 THEN
          -- data already exists, no need to write
          hz_utility_v2pub.DEBUG(p_message=> 'CHILD record already exists in BOT',
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          INSERT INTO HZ_BUS_OBJ_TRACKING
          ( POPULATED_FLAG, CHILD_OPERATION_FLAG, CHILD_ID, CHILD_ENTITY_NAME, CHILD_BO_CODE,
            LAST_UPDATE_DATE, CREATION_DATE, PARENT_ENTITY_NAME, PARENT_ID, PARENT_BO_CODE
          ) VALUES (
            'N', p_operation, l_child_id, 'HZ_EDUCATION', NULL,
            l_lud, l_lud, 'HZ_PARTIES', l_parent_id, 'PERSON');

          -- populate org party record
          pop_parent_record(p_child_id     => l_parent_id,
                            p_lud          => l_lud,
                            p_centity_name => 'HZ_PARTIES',
                            p_cbo_code     => 'PERSON',
                            p_parent_id    => NULL,
                            p_pentity_name => NULL,
                            p_pbo_code     => NULL);
      END ; -- anonymous block end
    END LOOP;

    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_education-',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);
  EXCEPTION
    WHEN OTHERS THEN
      hz_utility_v2pub.DEBUG(p_message=> SQLERRM,
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END pop_hz_education;

-----------------------------------------------------------------
-- Procedure name: pop_hz_cust_site_uses_all()
-- Purpose: populates BOT for HZ_CUST_SITE_USES_ALL create or update
-- Scope: internal
-- Called From: V2 API
-- Called By: HZ_CUST_SITE_USES_ALL create or update APIs
-- Input Parameters:
--   p_operation -- contains I or U.  'I' if create API is calling this otherwise 'U'.
--   p_site_use_id IN NUMBER
--
-- Note:
--   Following are the allowed PARENT and CHILD BO combinations for HZ_CUST_SITE_USES_ALL
--   This procedure must ensure that the combination is valid before populating BOT
--
-- PARENT BO: CUST_ACCT_SITE :: CHILD BO: CUST_ACCT_SITE_USE
-----------------------------------------------------------------
  PROCEDURE pop_hz_cust_site_uses_all(p_operation IN VARCHAR2, p_site_use_id IN NUMBER) IS

    -- cursor statement to select the info from child table
    CURSOR C_child IS
      SELECT casu.LAST_UPDATE_DATE lud, casu.CUST_ACCT_SITE_ID parent_id,
             casu.SITE_USE_ID child_id, cas.cust_account_id cust_acct_id
      FROM HZ_CUST_SITE_USES_ALL casu, HZ_CUST_ACCT_SITES_ALL cas
      WHERE casu.SITE_USE_ID = P_SITE_USE_ID
      AND casu.cust_acct_site_id = cas.cust_acct_site_id
      AND cas.cust_account_id > 0;

    -- local variables
    l_debug_prefix    VARCHAR2(40) := 'pop_hz_cust_site_uses_all';
    l_parent_id       NUMBER; -- used to store parent entity identifier
    l_child_id        NUMBER; -- used to store HZ_CUST_SITE_USES_ALL identifier
    l_lud             DATE; -- used to store the child last update date
    l_child_rec_exists_no     NUMBER;
    l_acct_id                 NUMBER;
    l_cen                     VARCHAR2(30) := 'HZ_CUST_SITE_USES_ALL';
  BEGIN
    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_cust_site_uses_all+',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);

    -- validate p_operation
    IF p_operation IN ('I','U') THEN
      NULL;
    ELSE
      hz_utility_v2pub.DEBUG(p_message=> 'incorrect operation flag sent to pop_hz_cust_site_uses_all',
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    FOR c_child_rec IN c_child LOOP
      -- collect the child info into variables
      l_lud := c_child_rec.lud;
      l_child_id := c_child_rec.child_id;
      l_parent_id := c_child_rec.parent_id;
      l_acct_id := c_child_rec.cust_acct_id;

      -- if record not existing, insert into hz_bus_obj_tracking
      BEGIN
        l_child_rec_exists_no := 0;
        SELECT child_id INTO  l_child_rec_exists_no
        FROM  HZ_BUS_OBJ_TRACKING
        WHERE event_id IS NULL
        AND CHILD_ENTITY_NAME = l_cen
        AND CHILD_ID = l_child_id
        AND rownum = 1;

        IF l_child_rec_exists_no <> 0 THEN
          -- data already exists, no need to write
          hz_utility_v2pub.DEBUG(p_message=> 'CHILD record already exists in BOT',
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          -- populate the child bo code also
          INSERT INTO HZ_BUS_OBJ_TRACKING
          ( POPULATED_FLAG, CHILD_OPERATION_FLAG, CHILD_ID, CHILD_ENTITY_NAME, CHILD_BO_CODE,
            LAST_UPDATE_DATE, CREATION_DATE, PARENT_ENTITY_NAME, PARENT_ID, PARENT_BO_CODE
          ) VALUES (
            'N', p_operation, l_child_id, 'HZ_CUST_SITE_USES_ALL', 'CUST_ACCT_SITE_USE',
            l_lud, l_lud, 'HZ_CUST_ACCT_SITES_ALL', l_parent_id, 'CUST_ACCT_SITE');
      END ; -- anonymous block end
    END LOOP;

    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_cust_site_uses_all-',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);
  EXCEPTION
    WHEN OTHERS THEN
      hz_utility_v2pub.DEBUG(p_message=> SQLERRM,
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END pop_hz_cust_site_uses_all;

-----------------------------------------------------------------
-- Procedure name: pop_hz_cust_profile_amts()
-- Purpose: populates BOT for HZ_CUST_PROFILE_AMTS create or update
-- Scope: internal
-- Called From: V2 API
-- Called By: HZ_CUST_PROFILE_AMTS create or update APIs
-- Input Parameters:
--   p_operation -- contains I or U.  'I' if create API is calling this otherwise 'U'.
--   p_cust_acct_profile_amt_id IN NUMBER
--
-- Note:
--   Following are the allowed PARENT and CHILD BO combinations for HZ_CUST_PROFILE_AMTS
--   This procedure must ensure that the combination is valid before populating BOT
--
-- PARENT BO: CUST_PROFILE :: CHILD BO:
-----------------------------------------------------------------
  PROCEDURE pop_hz_cust_profile_amts(p_operation IN VARCHAR2, p_cust_acct_profile_amt_id IN NUMBER) IS

    -- cursor statement to select the info from child table
    CURSOR C_child IS
      SELECT cpa.LAST_UPDATE_DATE lud, cpa.CUST_ACCOUNT_PROFILE_ID parent_id,
             cpa.CUST_ACCT_PROFILE_AMT_ID child_id,
             nvl(cp.site_use_id, cp.cust_account_id) cp_parent_id,
             decode(cp.site_use_id, null, 'HZ_CUST_ACCOUNTS', 'HZ_CUST_SITE_USES_ALL') cp_parent_entity,
             decode(cp.site_use_id, null, 'CUST_ACCT', 'CUST_ACCT_SITE_USE') cp_parent_bo
      FROM HZ_CUST_PROFILE_AMTS cpa, HZ_CUSTOMER_PROFILES cp
      WHERE cpa.CUST_ACCT_PROFILE_AMT_ID = P_CUST_ACCT_PROFILE_AMT_ID
      AND cpa.cust_account_profile_id = cp.cust_account_profile_id
      AND cp.cust_account_id > 0;

    -- local variables
    l_debug_prefix    VARCHAR2(40) := 'pop_hz_cust_profile_amts';
    l_parent_id       NUMBER; -- used to store parent entity identifier
    l_child_id        NUMBER; -- used to store HZ_CUST_PROFILE_AMTS identifier
    l_lud             DATE; -- used to store the child last update date
    l_child_rec_exists_no     NUMBER;
    l_cp_parent_id            NUMBER;
    l_cp_parent_entity        VARCHAR2(30);
    l_cp_parent_bo            VARCHAR2(30);
    l_cen                     VARCHAR2(30) := 'HZ_CUST_PROFILE_AMTS';
  BEGIN
    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_cust_profile_amts+',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);

    -- validate p_operation
    IF p_operation IN ('I','U') THEN
      NULL;
    ELSE
      hz_utility_v2pub.DEBUG(p_message=> 'incorrect operation flag sent to pop_hz_cust_profile_amts',
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    FOR c_child_rec IN c_child LOOP
      -- collect the child info into variables
      l_lud := c_child_rec.lud;
      l_child_id := c_child_rec.child_id;
      l_parent_id := c_child_rec.parent_id;
      l_cp_parent_id := c_child_rec.cp_parent_id;
      l_cp_parent_entity := c_child_rec.cp_parent_entity;
      l_cp_parent_bo := c_child_rec.cp_parent_bo;

      -- if record not existing, insert into hz_bus_obj_tracking
      BEGIN
        l_child_rec_exists_no := 0;
        SELECT child_id INTO  l_child_rec_exists_no
        FROM  HZ_BUS_OBJ_TRACKING
        WHERE event_id IS NULL
        AND CHILD_ENTITY_NAME = l_cen
        AND CHILD_ID = l_child_id
        AND rownum = 1;

        IF l_child_rec_exists_no <> 0 THEN
          -- data already exists, no need to write
          hz_utility_v2pub.DEBUG(p_message=> 'CHILD record already exists in BOT',
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          INSERT INTO HZ_BUS_OBJ_TRACKING
          ( POPULATED_FLAG, CHILD_OPERATION_FLAG, CHILD_ID, CHILD_ENTITY_NAME, CHILD_BO_CODE,
            LAST_UPDATE_DATE, CREATION_DATE, PARENT_ENTITY_NAME, PARENT_ID, PARENT_BO_CODE
          ) VALUES (
            'N', p_operation, l_child_id, 'HZ_CUST_PROFILE_AMTS', NULL,
            l_lud, l_lud, 'HZ_CUSTOMER_PROFILES', l_parent_id, 'CUST_PROFILE');

          -- populate org party record
          pop_parent_record(p_child_id     => l_parent_id,
                            p_lud          => l_lud,
                            p_centity_name => 'HZ_CUSTOMER_PROFILES',
                            p_cbo_code     => 'CUST_PROFILE',
                            p_parent_id    => l_cp_parent_id,
                            p_pentity_name => l_cp_parent_entity,
                            p_pbo_code     => l_cp_parent_bo);
      END ; -- anonymous block end
    END LOOP;

    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_cust_profile_amts-',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);
  EXCEPTION
    WHEN OTHERS THEN
      hz_utility_v2pub.DEBUG(p_message=> SQLERRM,
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END pop_hz_cust_profile_amts;

-----------------------------------------------------------------
-- Procedure name: pop_hz_cust_acct_sites_all()
-- Purpose: populates BOT for HZ_CUST_ACCT_SITES_ALL create or update
-- Scope: internal
-- Called From: V2 API
-- Called By: HZ_CUST_ACCT_SITES_ALL create or update APIs
-- Input Parameters:
--   p_operation -- contains I or U.  'I' if create API is calling this otherwise 'U'.
--   p_cust_acct_site_id IN NUMBER
--
-- Note:
--   Following are the allowed PARENT and CHILD BO combinations for HZ_CUST_ACCT_SITES_ALL
--   This procedure must ensure that the combination is valid before populating BOT
--
-- PARENT BO: CUST_ACCT :: CHILD BO: CUST_ACCT_SITE
-----------------------------------------------------------------
  PROCEDURE pop_hz_cust_acct_sites_all(p_operation IN VARCHAR2, p_cust_acct_site_id IN NUMBER) IS

    -- cursor statement to select the info from child table
    CURSOR C_child IS
      SELECT cas.LAST_UPDATE_DATE lud, cas.CUST_ACCOUNT_ID parent_id, cas.CUST_ACCT_SITE_ID child_id,
             ca.party_id ca_parent_id,
             decode(p.party_type, 'ORGANIZATION', 'ORG', 'PERSON', 'PERSON', NULL) ca_parent_bo
      FROM HZ_CUST_ACCT_SITES_ALL cas, HZ_CUST_ACCOUNTS ca, HZ_PARTIES p
      WHERE cas.CUST_ACCT_SITE_ID = P_CUST_ACCT_SITE_ID
      AND cas.cust_account_id = ca.cust_account_id
      AND ca.party_id = p.party_id
      AND p.party_type in ('ORGANIZATION', 'PERSON')
      AND cas.cust_account_id > 0;

    -- local variables
    l_debug_prefix    VARCHAR2(40) := 'pop_hz_cust_acct_sites_all';
    l_parent_id       NUMBER; -- used to store parent entity identifier
    l_child_id        NUMBER; -- used to store HZ_CUST_ACCT_SITES_ALL identifier
    l_lud             DATE; -- used to store the child last update date
    l_child_rec_exists_no     NUMBER;
    l_ca_parent_id    NUMBER;
    l_ca_parent_bo    VARCHAR2(30);
    l_pop_flag        VARCHAR2(1);
    l_cen                     VARCHAR2(30) := 'HZ_CUST_ACCT_SITES_ALL';
  BEGIN
    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_cust_acct_sites_all+',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);

    -- validate p_operation
    IF p_operation IN ('I','U') THEN
      NULL;
    ELSE
      hz_utility_v2pub.DEBUG(p_message=> 'incorrect operation flag sent to pop_hz_cust_acct_sites_all',
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    FOR c_child_rec IN c_child LOOP
      -- collect the child info into variables
      l_lud := c_child_rec.lud;
      l_child_id := c_child_rec.child_id;
      l_parent_id := c_child_rec.parent_id;
      l_ca_parent_id := c_child_rec.ca_parent_id;
      l_ca_parent_bo := c_child_rec.ca_parent_bo;

      -- if record not existing, insert into hz_bus_obj_tracking
      BEGIN
        l_child_rec_exists_no := 0;
        SELECT child_id, populated_flag INTO  l_child_rec_exists_no, l_pop_flag
        FROM  HZ_BUS_OBJ_TRACKING
        WHERE event_id IS NULL
        AND CHILD_ENTITY_NAME = l_cen
        AND CHILD_ID = l_child_id
        AND rownum = 1;

        IF l_child_rec_exists_no <> 0 THEN
          IF(l_pop_flag = 'Y') THEN
            UPDATE HZ_BUS_OBJ_TRACKING
            SET populated_flag = 'N'
            WHERE event_id IS NULL
            AND CHILD_ENTITY_NAME = l_cen
            AND CHILD_ID = l_child_id;
          END IF;
          -- data already exists, no need to write
          hz_utility_v2pub.DEBUG(p_message=> 'CHILD record already exists in BOT',
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          -- populate the child bo code also
          INSERT INTO HZ_BUS_OBJ_TRACKING
          ( POPULATED_FLAG, CHILD_OPERATION_FLAG, CHILD_ID, CHILD_ENTITY_NAME, CHILD_BO_CODE,
            LAST_UPDATE_DATE, CREATION_DATE, PARENT_ENTITY_NAME, PARENT_ID, PARENT_BO_CODE
          ) VALUES (
            'N', p_operation, l_child_id, 'HZ_CUST_ACCT_SITES_ALL', 'CUST_ACCT_SITE',
            l_lud, l_lud, 'HZ_CUST_ACCOUNTS', l_parent_id, 'CUST_ACCT');
      END ; -- anonymous block end
    END LOOP;

    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_cust_acct_sites_all-',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);
  EXCEPTION
    WHEN OTHERS THEN
      hz_utility_v2pub.DEBUG(p_message=> SQLERRM,
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END pop_hz_cust_acct_sites_all;

-----------------------------------------------------------------
-- Procedure name: pop_hz_cust_acct_relate_all()
-- Purpose: populates BOT for HZ_CUST_ACCT_RELATE_ALL create or update
-- Scope: internal
-- Called From: V2 API
-- Called By: HZ_CUST_ACCT_RELATE_ALL create or update APIs
-- Input Parameters:
--   p_operation -- contains I or U.  'I' if create API is calling this otherwise 'U'.
--   p_cust_account_id  IN NUMBER
--   p_related_cust_account_id IN NUMBER
--
-- Note:
--   Following are the allowed PARENT and CHILD BO combinations for HZ_CUST_ACCT_RELATE_ALL
--   This procedure must ensure that the combination is valid before populating BOT
--
-- PARENT BO: CUST_ACCT :: CHILD BO:
-----------------------------------------------------------------
  PROCEDURE pop_hz_cust_acct_relate_all(p_operation        IN VARCHAR2,
                                        p_cust_acct_relate_id IN NUMBER) IS

    -- cursor statement to select the info from child table
    CURSOR C_child IS
      SELECT car.LAST_UPDATE_DATE lud,
             car.cust_acct_relate_id child_id,
             car.cust_account_id cap_id,
             car.related_cust_account_id rcap_id,
             decode(p.party_type, 'ORGANIZATION', 'ORG_CUST', 'PERSON', 'PERSON_CUST', NULL) pbo,
             decode(rel_p.party_type, 'ORGANIZATION', 'ORG_CUST', 'PERSON', 'PERSON_CUST', NULL) rel_pbo,
             p.party_id pid, rel_p.party_id rel_pid
      FROM HZ_CUST_ACCT_RELATE_ALL car, HZ_CUST_ACCOUNTS ca, HZ_CUST_ACCOUNTS rel_ca,
           HZ_PARTIES p, HZ_PARTIES rel_p
      WHERE car.cust_acct_relate_id = p_cust_acct_relate_id
      AND car.cust_account_id = ca.cust_account_id
      AND car.related_cust_account_id = rel_ca.cust_account_id
      AND ca.party_id = p.party_id
      AND rel_ca.party_id = rel_p.party_id
      AND p.party_type in ('ORGANIZATION', 'PERSON')
      AND rel_p.party_type in ('ORGANIZATION', 'PERSON');

    -- local variables
    l_debug_prefix    VARCHAR2(40) := 'pop_hz_cust_acct_relate_all';
    l_child_id        NUMBER; -- used to store HZ_CUST_ACCT_RELATE_ALL identifier
    l_lud             DATE; -- used to store the child last update date
    l_child_rec_exists_no     NUMBER;
    l_cap_id                  NUMBER;
    l_rcap_id                 NUMBER;
    l_pbo                     VARCHAR2(30);
    l_pid                     NUMBER;
    l_rel_pbo                 VARCHAR2(30);
    l_rel_pid                 NUMBER;
    l_cen                     VARCHAR2(30) := 'HZ_CUST_ACCT_RELATE_ALL';
  BEGIN
    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_cust_acct_relate_all+',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);

    -- validate p_operation
    IF p_operation IN ('I','U') THEN
      NULL;
    ELSE
      hz_utility_v2pub.DEBUG(p_message=> 'incorrect operation flag sent to pop_hz_cust_acct_relate_all',
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    FOR c_child_rec IN c_child LOOP
      -- collect the child info into variables
      l_lud := c_child_rec.lud;
      l_pbo := c_child_rec.pbo;
      l_rel_pbo := c_child_rec.rel_pbo;
      l_pid := c_child_rec.pid;
      l_rel_pid := c_child_rec.rel_pid;
      l_child_id := c_child_rec.child_id;
      l_cap_id := c_child_rec.cap_id;
      l_rcap_id := c_child_rec.rcap_id;

      -- if record not existing, insert into hz_bus_obj_tracking
      BEGIN
        l_child_rec_exists_no := 0;
        SELECT child_id INTO  l_child_rec_exists_no
        FROM  HZ_BUS_OBJ_TRACKING
        WHERE event_id IS NULL
        AND CHILD_ENTITY_NAME = l_cen
        AND CHILD_ID = l_child_id
        AND rownum = 1;

        IF l_child_rec_exists_no <> 0 THEN
          -- data already exists, no need to write
          hz_utility_v2pub.DEBUG(p_message=> 'CHILD record already exists in BOT',
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          INSERT INTO HZ_BUS_OBJ_TRACKING
          ( POPULATED_FLAG, CHILD_OPERATION_FLAG, CHILD_ID, CHILD_ENTITY_NAME, CHILD_BO_CODE,
            LAST_UPDATE_DATE, CREATION_DATE, PARENT_ENTITY_NAME, PARENT_ID, PARENT_BO_CODE
          ) VALUES (
            'N', p_operation, l_child_id, 'HZ_CUST_ACCT_RELATE_ALL', NULL,
            l_lud, l_lud, 'HZ_CUST_ACCOUNTS', l_cap_id, 'CUST_ACCT');

          pop_parent_record(p_child_id     => l_cap_id,
                            p_lud          => l_lud,
                            p_centity_name => 'HZ_CUST_ACCOUNTS',
                            p_cbo_code     => 'CUST_ACCT',
                            p_parent_id    => l_pid,
                            p_pentity_name => 'HZ_PARTIES',
                            p_pbo_code     => l_pbo);

          pop_parent_record(p_child_id     => l_pid,
                            p_lud          => l_lud,
                            p_centity_name => 'HZ_PARTIES',
                            p_cbo_code     => l_pbo,
                            p_parent_id    => NULL,
                            p_pentity_name => NULL,
                            p_pbo_code     => NULL);

          INSERT INTO HZ_BUS_OBJ_TRACKING
          ( POPULATED_FLAG, CHILD_OPERATION_FLAG, CHILD_ID, CHILD_ENTITY_NAME, CHILD_BO_CODE,
            LAST_UPDATE_DATE, CREATION_DATE, PARENT_ENTITY_NAME, PARENT_ID, PARENT_BO_CODE
          ) VALUES (
            'N', p_operation, l_child_id, 'HZ_CUST_ACCT_RELATE_ALL', NULL,
            l_lud, l_lud, 'HZ_CUST_ACCOUNTS', l_rcap_id, 'CUST_ACCT');

          pop_parent_record(p_child_id     => l_rcap_id,
                            p_lud          => l_lud,
                            p_centity_name => 'HZ_CUST_ACCOUNTS',
                            p_cbo_code     => 'CUST_ACCT',
                            p_parent_id    => l_rel_pid,
                            p_pentity_name => 'HZ_PARTIES',
                            p_pbo_code     => l_rel_pbo);

          pop_parent_record(p_child_id     => l_rel_pid,
                            p_lud          => l_lud,
                            p_centity_name => 'HZ_PARTIES',
                            p_cbo_code     => l_rel_pbo,
                            p_parent_id    => NULL,
                            p_pentity_name => NULL,
                            p_pbo_code     => NULL);

      END ; -- anonymous block end
    END LOOP;

    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_cust_acct_relate_all-',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);
  EXCEPTION
    WHEN OTHERS THEN
      hz_utility_v2pub.DEBUG(p_message=> SQLERRM,
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END pop_hz_cust_acct_relate_all;

-----------------------------------------------------------------
-- Procedure name: pop_hz_cust_account_roles()
-- Purpose: populates BOT for HZ_CUST_ACCOUNT_ROLES create or update
-- Scope: internal
-- Called From: V2 API
-- Called By: HZ_CUST_ACCOUNT_ROLES create or update APIs
-- Input Parameters:
--   p_operation -- contains I or U.  'I' if create API is calling this otherwise 'U'.
--   p_cust_account_role_id IN NUMBER
--
-- Note:
--   Following are the allowed PARENT and CHILD BO combinations for HZ_CUST_ACCOUNT_ROLES
--   This procedure must ensure that the combination is valid before populating BOT
--
-- PARENT BO: CUST_ACCT :: CHILD BO: CUST_ACCT_CONTACT
-- PARENT BO: CUST_ACCT_SITE :: CHILD BO: CUST_ACCT_CONTACT
-----------------------------------------------------------------
  PROCEDURE pop_hz_cust_account_roles(p_operation IN VARCHAR2, p_cust_account_role_id IN NUMBER) IS

    -- cursor statement to select the info from child table
    CURSOR C_child IS
      SELECT car.LAST_UPDATE_DATE lud, car.CUST_ACCOUNT_ROLE_ID child_id,
             nvl(car.cust_acct_site_id, car.cust_account_id) parent_id,
             decode(car.cust_acct_site_id, null, 'CUST_ACCT', 'CUST_ACCT_SITE') parent_bo,
             decode(car.cust_acct_site_id, null, 'HZ_CUST_ACCOUNTS', 'HZ_CUST_ACCT_SITES_ALL') parent_entity,
             ca.cust_account_id ca_id
      FROM HZ_CUST_ACCOUNT_ROLES car, HZ_CUST_ACCOUNTS ca, HZ_PARTIES p
      WHERE car.CUST_ACCOUNT_ROLE_ID = P_CUST_ACCOUNT_ROLE_ID
      AND car.cust_account_id = ca.cust_account_id
      AND ca.party_id = p.party_id
      AND p.party_type in ('ORGANIZATION', 'PERSON')
      AND car.cust_account_id > 0;

    -- local variables
    l_debug_prefix    VARCHAR2(40) := 'pop_hz_cust_account_roles';
    l_parent_id       NUMBER; -- used to store parent entity identifier
    l_parent_bo       VARCHAR2(30);
    l_parent_entity   VARCHAR2(30);
    l_child_id        NUMBER; -- used to store HZ_CUST_ACCOUNT_ROLES identifier
    l_lud             DATE; -- used to store the child last update date
    l_child_rec_exists_no     NUMBER;
    l_ca_id                   NUMBER;
    l_pop_flag                VARCHAR2(1);
    l_cen                     VARCHAR2(30) := 'HZ_CUST_ACCOUNT_ROLES';
  BEGIN
    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_cust_account_roles+',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);

    -- validate p_operation
    IF p_operation IN ('I','U') THEN
      NULL;
    ELSE
      hz_utility_v2pub.DEBUG(p_message=> 'incorrect operation flag sent to pop_hz_cust_account_roles',
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    FOR c_child_rec IN c_child LOOP
      l_lud := c_child_rec.lud;
      l_child_id := c_child_rec.child_id;
      l_parent_id := c_child_rec.parent_id;
      l_parent_bo := c_child_rec.parent_bo;
      l_parent_entity := c_child_rec.parent_entity;

      -- if record not existing, insert into hz_bus_obj_tracking
      BEGIN
        l_child_rec_exists_no := 0;
        SELECT child_id, populated_flag INTO  l_child_rec_exists_no, l_pop_flag
        FROM  HZ_BUS_OBJ_TRACKING
        WHERE event_id IS NULL
        AND CHILD_ENTITY_NAME = l_cen
        AND CHILD_ID = l_child_id
        AND rownum = 1;

        IF l_child_rec_exists_no <> 0 THEN
          IF(l_pop_flag = 'Y') THEN
            UPDATE HZ_BUS_OBJ_TRACKING
            SET populated_flag = 'N'
            WHERE event_id IS NULL
            AND CHILD_ENTITY_NAME = l_cen
            AND CHILD_ID = l_child_id;
          END IF;
          -- data already exists, no need to write
          hz_utility_v2pub.DEBUG(p_message=> 'CHILD record already exists in BOT',
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          -- populate the child bo code also
          INSERT INTO HZ_BUS_OBJ_TRACKING
          ( POPULATED_FLAG, CHILD_OPERATION_FLAG, CHILD_ID, CHILD_ENTITY_NAME, CHILD_BO_CODE,
            LAST_UPDATE_DATE, CREATION_DATE, PARENT_ENTITY_NAME, PARENT_ID, PARENT_BO_CODE
          ) VALUES (
            'N', p_operation, l_child_id, 'HZ_CUST_ACCOUNT_ROLES', 'CUST_ACCT_CONTACT',
            l_lud, l_lud, l_parent_entity, l_parent_id, l_parent_bo);
      END ; -- anonymous block end
    END LOOP;

    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_cust_account_roles-',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);
  EXCEPTION
    WHEN OTHERS THEN
      hz_utility_v2pub.DEBUG(p_message=> SQLERRM,
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END pop_hz_cust_account_roles;

-----------------------------------------------------------------
-- Procedure name: pop_hz_cust_accounts()
-- Purpose: populates BOT for HZ_CUST_ACCOUNTS create or update
-- Scope: internal
-- Called From: V2 API
-- Called By: HZ_CUST_ACCOUNTS create or update APIs
-- Input Parameters:
--   p_operation -- contains I or U.  'I' if create API is calling this otherwise 'U'.
--   p_cust_account_id IN NUMBER
--
-- Note:
--   Following are the allowed PARENT and CHILD BO combinations for HZ_CUST_ACCOUNTS
--   This procedure must ensure that the combination is valid before populating BOT
--
-- PARENT BO: ORG_CUST :: CHILD BO: CUST_ACCT
-- PARENT BO: PERSON_CUST :: CHILD BO: CUST_ACCT
-----------------------------------------------------------------
  PROCEDURE pop_hz_cust_accounts(p_operation IN VARCHAR2, p_cust_account_id IN NUMBER) IS

    -- cursor statement to select the info from child table
    CURSOR C_child IS
      SELECT ca.LAST_UPDATE_DATE lud, ca.PARTY_ID parent_id, ca.CUST_ACCOUNT_ID child_id,
             decode(p.party_type, 'ORGANIZATION', 'ORG_CUST', 'PERSON', 'PERSON_CUST', NULL) bo_code
      FROM HZ_CUST_ACCOUNTS ca, HZ_PARTIES p
      WHERE ca.CUST_ACCOUNT_ID = P_CUST_ACCOUNT_ID
      AND ca.party_id = p.party_id
      AND p.party_type in ('ORGANIZATION', 'PERSON')
      AND ca.cust_account_id > 0;

    -- local variables
    l_debug_prefix    VARCHAR2(40) := 'pop_hz_cust_accounts';
    l_parent_id       NUMBER; -- used to store parent entity identifier
    l_bo_code         VARCHAR2(30); -- used to store BO Code
    l_child_id        NUMBER; -- used to store HZ_CUST_ACCOUNTS identifier
    l_lud             DATE; -- used to store the child last update date
    l_child_rec_exists_no     NUMBER;
    l_pop_flag                VARCHAR2(1);
    l_cen                     VARCHAR2(30) := 'HZ_CUST_ACCOUNTS';
  BEGIN
    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_cust_accounts+',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);

    -- validate p_operation
    IF p_operation IN ('I','U') THEN
      NULL;
    ELSE
      hz_utility_v2pub.DEBUG(p_message=> 'incorrect operation flag sent to pop_hz_cust_accounts',
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    FOR c_child_rec IN c_child LOOP
      -- collect the child info into variables
      l_lud := c_child_rec.lud;
      l_child_id := c_child_rec.child_id;
      l_parent_id := c_child_rec.parent_id;
      l_bo_code := c_child_rec.bo_code;

      -- if record not existing, insert into hz_bus_obj_tracking
      BEGIN
        l_child_rec_exists_no := 0;
        SELECT child_id, populated_flag INTO  l_child_rec_exists_no, l_pop_flag
        FROM  HZ_BUS_OBJ_TRACKING
        WHERE event_id IS NULL
        AND CHILD_ENTITY_NAME = l_cen
        AND CHILD_ID = l_child_id
        AND rownum = 1;

        IF l_child_rec_exists_no <> 0 THEN
          IF(l_pop_flag = 'Y') THEN
            UPDATE HZ_BUS_OBJ_TRACKING
            SET populated_flag = 'N'
            WHERE event_id IS NULL
            AND CHILD_ENTITY_NAME = l_cen
            AND CHILD_ID = l_child_id;
          END IF;
          -- data already exists, no need to write
          hz_utility_v2pub.DEBUG(p_message=> 'CHILD record already exists in BOT',
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          -- populate the child bo code also
          INSERT INTO HZ_BUS_OBJ_TRACKING
          ( POPULATED_FLAG, CHILD_OPERATION_FLAG, CHILD_ID, CHILD_ENTITY_NAME, CHILD_BO_CODE,
            LAST_UPDATE_DATE, CREATION_DATE, PARENT_ENTITY_NAME, PARENT_ID, PARENT_BO_CODE
          ) VALUES (
           'N', p_operation, l_child_id, 'HZ_CUST_ACCOUNTS', 'CUST_ACCT',
           l_lud, l_lud, 'HZ_PARTIES', l_parent_id, l_bo_code);
      END ; -- anonymous block end
    END LOOP;

    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_cust_accounts-',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);
  EXCEPTION
    WHEN OTHERS THEN
      hz_utility_v2pub.DEBUG(p_message=> SQLERRM,
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END pop_hz_cust_accounts;

-----------------------------------------------------------------
-- Procedure name: pop_hz_customer_profiles()
-- Purpose: populates BOT for HZ_CUSTOMER_PROFILES create or update
-- Scope: internal
-- Called From: V2 API
-- Called By: HZ_CUSTOMER_PROFILES create or update APIs
-- Input Parameters:
--   p_operation -- contains I or U.  'I' if create API is calling this otherwise 'U'.
--   p_cust_account_profile_id IN NUMBER
--
-- Note:
--   Following are the allowed PARENT and CHILD BO combinations for HZ_CUSTOMER_PROFILES
--   This procedure must ensure that the combination is valid before populating BOT
--
-- PARENT BO: CUST_ACCT :: CHILD BO: CUST_PROFILE
-- PARENT BO: CUST_ACCT_SITE_USE :: CHILD BO: CUST_PROFILE
-----------------------------------------------------------------
  PROCEDURE pop_hz_customer_profiles(p_operation IN VARCHAR2, p_cust_account_profile_id IN NUMBER) IS

    -- cursor statement to select the info from child table
    CURSOR C_child IS
      SELECT cp.LAST_UPDATE_DATE lud,
             nvl(cp.site_use_id, cp.cust_account_id) parent_id,
             decode(cp.site_use_id, NULL, 'HZ_CUST_ACCOUNTS', 'HZ_CUST_SITE_USES_ALL') parent_entity,
             decode(cp.site_use_id, NULL, 'CUST_ACCT', 'CUST_ACCT_SITE_USE') parent_bo,
             cp.CUST_ACCOUNT_PROFILE_ID child_id
      FROM HZ_CUSTOMER_PROFILES cp
      WHERE cp.CUST_ACCOUNT_PROFILE_ID = P_CUST_ACCOUNT_PROFILE_ID
      AND cp.cust_account_id > 0;

    -- local variables
    l_debug_prefix    VARCHAR2(40) := 'pop_hz_customer_profiles';
    l_parent_id       NUMBER; -- used to store parent entity identifier
    l_parent_bo       VARCHAR2(30);
    l_parent_entity   VARCHAR2(30);
    l_child_id        NUMBER; -- used to store HZ_CUSTOMER_PROFILES identifier
    l_lud             DATE; -- used to store the child last update date
    l_child_rec_exists_no     NUMBER;
    l_pop_flag                VARCHAR2(1);
    l_cen                     VARCHAR2(30) := 'HZ_CUSTOMER_PROFILES';
  BEGIN
    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_customer_profiles+',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);

    -- validate p_operation
    IF p_operation IN ('I','U') THEN
      NULL;
    ELSE
      hz_utility_v2pub.DEBUG(p_message=> 'incorrect operation flag sent to pop_hz_customer_profiles',
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    FOR c_child_rec IN c_child LOOP
      -- collect the child info into variables
      l_lud := c_child_rec.lud;
      l_child_id := c_child_rec.child_id;
      l_parent_id := c_child_rec.parent_id;
      l_parent_bo := c_child_rec.parent_bo;
      l_parent_entity := c_child_rec.parent_entity;

     -- credit mgmt team create customer profile with customer account id = -1
     -- we will not populate bot table for this record
     IF(l_parent_id > 0) THEN
      -- if record not existing, insert into hz_bus_obj_tracking
      BEGIN
        l_child_rec_exists_no := 0;
        SELECT child_id, populated_flag INTO  l_child_rec_exists_no, l_pop_flag
        FROM  HZ_BUS_OBJ_TRACKING
        WHERE event_id IS NULL
        AND CHILD_ENTITY_NAME = l_cen
        AND CHILD_ID = l_child_id
        AND rownum = 1;

        IF l_child_rec_exists_no <> 0 THEN
          IF(l_pop_flag = 'Y') THEN
            UPDATE HZ_BUS_OBJ_TRACKING
            SET populated_flag = 'N'
            WHERE event_id IS NULL
            AND CHILD_ENTITY_NAME = l_cen
            AND CHILD_ID = l_child_id;
          END IF;
          -- data already exists, no need to write
          hz_utility_v2pub.DEBUG(p_message=> 'CHILD record already exists in BOT',
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          -- populate the child bo code also
          INSERT INTO HZ_BUS_OBJ_TRACKING
          ( POPULATED_FLAG, CHILD_OPERATION_FLAG, CHILD_ID, CHILD_ENTITY_NAME, CHILD_BO_CODE,
            LAST_UPDATE_DATE, CREATION_DATE, PARENT_ENTITY_NAME, PARENT_ID, PARENT_BO_CODE
          ) VALUES (
            'N', p_operation, l_child_id, 'HZ_CUSTOMER_PROFILES', 'CUST_PROFILE',
            l_lud, l_lud, l_parent_entity, l_parent_id, l_parent_bo);
      END ; -- anonymous block end
     END IF; -- l_parent_id > 0
    END LOOP;

    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_customer_profiles-',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);
  EXCEPTION
    WHEN OTHERS THEN
      hz_utility_v2pub.DEBUG(p_message=> SQLERRM,
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END pop_hz_customer_profiles;

-----------------------------------------------------------------
-- Procedure name: pop_hz_credit_ratings()
-- Purpose: populates BOT for HZ_CREDIT_RATINGS create or update
-- Scope: internal
-- Called From: V2 API
-- Called By: HZ_CREDIT_RATINGS create or update APIs
-- Input Parameters:
--   p_operation -- contains I or U.  'I' if create API is calling this otherwise 'U'.
--   p_credit_rating_id IN NUMBER
--
-- Note:
--   Following are the allowed PARENT and CHILD BO combinations for HZ_CREDIT_RATINGS
--   This procedure must ensure that the combination is valid before populating BOT
--
-- PARENT BO: ORG :: CHILD BO:
-----------------------------------------------------------------
  PROCEDURE pop_hz_credit_ratings(p_operation IN VARCHAR2, p_credit_rating_id IN NUMBER) IS

    -- cursor statement to select the info from child table
    CURSOR C_child IS
      SELECT cr.LAST_UPDATE_DATE lud, cr.PARTY_ID parent_id, cr.CREDIT_RATING_ID child_id
      FROM HZ_CREDIT_RATINGS cr, HZ_PARTIES p
      WHERE cr.CREDIT_RATING_ID = P_CREDIT_RATING_ID
      AND cr.party_id = p.party_id
      AND p.party_type = 'ORGANIZATION';

    -- local variables
    l_debug_prefix    VARCHAR2(40) := 'pop_hz_credit_ratings';
    l_parent_id       NUMBER; -- used to store parent entity identifier
    l_child_id        NUMBER; -- used to store HZ_CREDIT_RATINGS identifier
    l_lud             DATE; -- used to store the child last update date
    l_child_rec_exists_no     NUMBER;
    l_cen                     VARCHAR2(30) := 'HZ_CREDIT_RATINGS';
  BEGIN
    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_credit_ratings+',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);

    -- validate p_operation
    IF p_operation IN ('I','U') THEN
      NULL;
    ELSE
      hz_utility_v2pub.DEBUG(p_message=> 'incorrect operation flag sent to pop_hz_credit_ratings',
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    FOR c_child_rec IN c_child LOOP
      -- collect the child info into variables
      l_lud := c_child_rec.lud;
      l_child_id := c_child_rec.child_id;
      l_parent_id := c_child_rec.parent_id;

      -- if record not existing, insert into hz_bus_obj_tracking
      BEGIN
        l_child_rec_exists_no := 0;
        SELECT child_id INTO  l_child_rec_exists_no
        FROM  HZ_BUS_OBJ_TRACKING
        WHERE event_id IS NULL
        AND CHILD_ENTITY_NAME = l_cen
        AND CHILD_ID = l_child_id
        AND rownum = 1;

        IF l_child_rec_exists_no <> 0 THEN
          -- data already exists, no need to write
          hz_utility_v2pub.DEBUG(p_message=> 'CHILD record already exists in BOT',
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          INSERT INTO HZ_BUS_OBJ_TRACKING
          ( POPULATED_FLAG, CHILD_OPERATION_FLAG, CHILD_ID, CHILD_ENTITY_NAME, CHILD_BO_CODE,
            LAST_UPDATE_DATE, CREATION_DATE, PARENT_ENTITY_NAME, PARENT_ID, PARENT_BO_CODE
          ) VALUES (
            'N', p_operation, l_child_id, 'HZ_CREDIT_RATINGS', NULL,
            l_lud, l_lud, 'HZ_PARTIES', l_parent_id, 'ORG');

          pop_parent_record(p_child_id     => l_parent_id,
                            p_lud          => l_lud,
                            p_centity_name => 'HZ_PARTIES',
                            p_cbo_code     => 'ORG',
                            p_parent_id    => NULL,
                            p_pentity_name => NULL,
                            p_pbo_code     => NULL);
      END ; -- anonymous block end
    END LOOP;

    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_credit_ratings-',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);
  EXCEPTION
    WHEN OTHERS THEN
      hz_utility_v2pub.DEBUG(p_message=> SQLERRM,
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END pop_hz_credit_ratings;

-----------------------------------------------------------------
-- Procedure name: pop_hz_contact_preferences()
-- Purpose: populates BOT for HZ_CONTACT_PREFERENCES create or update
-- Scope: internal
-- Called From: V2 API
-- Called By: HZ_CONTACT_PREFERENCES create or update APIs
-- Input Parameters:
--   p_operation -- contains I or U.  'I' if create API is calling this otherwise 'U'.
--   p_contact_preference_id IN NUMBER
--
-- Note:
--   Following are the allowed PARENT and CHILD BO combinations for HZ_CONTACT_PREFERENCES
--   This procedure must ensure that the combination is valid before populating BOT
--
-- PARENT BO: ORG :: CHILD BO:
-- PARENT BO: PERSON :: CHILD BO:
-- PARENT BO: ORG_CONTACT :: CHILD BO:
-- PARENT BO: PARTY_SITE :: CHILD BO:
-- PARENT BO: PHONE :: CHILD BO:
-- PARENT BO: TLX :: CHILD BO:
-- PARENT BO: EMAIL :: CHILD BO:
-- PARENT BO: WEB :: CHILD BO:
-- PARENT BO: EDI :: CHILD BO:
-- PARENT BO: EFT :: CHILD BO:
-- PARENT BO: SMS :: CHILD BO:
-----------------------------------------------------------------
  PROCEDURE pop_hz_contact_preferences(p_operation IN VARCHAR2, p_contact_preference_id IN NUMBER) IS

    CURSOR c_child IS
      SELECT cpp.LAST_UPDATE_DATE lud, cpp.CONTACT_LEVEL_TABLE_ID parent_id,
             cpp.CONTACT_LEVEL_TABLE parent_tbl_name, cpp.CONTACT_PREFERENCE_ID child_id
      FROM HZ_CONTACT_PREFERENCES cpp
      WHERE cpp.CONTACT_PREFERENCE_ID = P_CONTACT_PREFERENCE_ID;

    CURSOR c_cp(p_parent_id NUMBER) IS
      SELECT decode(contact_point_type, 'PHONE', 'PHONE', 'EMAIL', 'EMAIL', 'WEB', 'WEB', 'EFT', 'EFT', 'SMS', 'SMS', 'TLX', 'TLX', 'EDI', 'EDI', NULL), owner_table_name, owner_table_id
      FROM HZ_CONTACT_POINTS
      WHERE contact_point_id = p_parent_id
      AND contact_point_type in ('PHONE', 'EMAIL', 'TLX', 'WEB', 'EFT', 'EDI', 'SMS');

    CURSOR c_pty(p_parent_id NUMBER) IS
      SELECT decode(party_type, 'ORGANIZATION', 'ORG', 'PERSON', 'PERSON', 'PARTY_RELATIONSHIP', 'ORG_CONTACT', NULL),
             decode(party_type, 'ORGANIZATION', 'HZ_PARTIES', 'PERSON', 'HZ_PARTIES', 'PARTY_RELATIONSHIP', 'HZ_ORG_CONTACTS', NULL)
      FROM HZ_PARTIES
      WHERE party_id = p_parent_id
      AND party_type in ('ORGANIZATION', 'PERSON', 'PARTY_RELATIONSHIP');

    CURSOR c_oc(p_parent_id NUMBER) IS
      SELECT oc.org_contact_id
      FROM HZ_RELATIONSHIPS r, HZ_ORG_CONTACTS oc
      WHERE r.relationship_id = oc.party_relationship_id
      AND r.subject_type = 'PERSON'
      AND r.object_type = 'ORGANIZATION'
      AND r.party_id = p_parent_id
      AND rownum = 1;

    -- local variables
    l_debug_prefix            VARCHAR2(40) := 'pop_hz_contact_preferences';
    l_parent_id               NUMBER; -- used to store parent entity identifier
    l_parent_tbl_name         VARCHAR2(30); -- used to store parent entity name
    l_pty_bo_code             VARCHAR2(30);
    l_pty_tbl_name            VARCHAR2(30);
    l_bo_code                 VARCHAR2(30); -- used to store BO Code
    l_child_bo_code           VARCHAR2(30); -- used to store Child BO Code (if child entity is a root node)
    l_child_id                NUMBER; -- used to store HZ_CONTACT_PREFERENCES identifier
    l_lud                     DATE; -- used to store the child last update date
    l_child_rec_exists_no     NUMBER;
    l_cp_owner_table          VARCHAR2(30);
    l_cp_owner_id             NUMBER;
    l_oc_id                   NUMBER;
    l_cen                     VARCHAR2(30) := 'HZ_CONTACT_PREFERENCES';
  BEGIN
    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_contact_preferences+',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);

    -- validate p_operation
    IF p_operation IN ('I','U') THEN
      NULL;
    ELSE
      hz_utility_v2pub.DEBUG(p_message=> 'incorrect operation flag sent to pop_hz_contact_preferences',
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    FOR c_child_rec IN c_child LOOP
      -- collect the child info into variables
      l_lud := c_child_rec.lud;
      l_child_id := c_child_rec.child_id;
      l_parent_id := c_child_rec.parent_id;
      l_parent_tbl_name := c_child_rec.parent_tbl_name;

      IF(l_parent_tbl_name = 'HZ_PARTY_SITES') THEN
        l_bo_code := 'PARTY_SITE';
        IF NOT(is_valid_ps(l_parent_id)) THEN
          RETURN;
        END IF;
      ELSIF(l_parent_tbl_name = 'HZ_CONTACT_POINTS') THEN
        OPEN c_cp(l_parent_id);
        FETCH c_cp INTO l_bo_code, l_cp_owner_table, l_cp_owner_id;
        CLOSE c_cp;
        IF l_bo_code in ('PHONE', 'SMS', 'EDI') and l_cp_owner_table = 'HZ_PARTIES' THEN
          OPEN c_pty(l_cp_owner_id);
          FETCH c_pty INTO l_pty_bo_code, l_pty_tbl_name;
          CLOSE c_pty;
          IF(l_bo_code = 'PHONE' AND l_pty_bo_code IS NULL) THEN
            RETURN;
          ELSIF(l_bo_code = 'PHONE' AND l_pty_bo_code = 'ORG_CONTACT') THEN
            OPEN c_oc(l_cp_owner_id);
            FETCH c_oc INTO l_oc_id;
            CLOSE c_oc;
            IF(l_oc_id IS NULL) THEN
              RETURN;
            END IF;
          ELSIF(l_bo_code = 'SMS' AND l_pty_bo_code = 'ORG') THEN
            RETURN;
          ELSIF(l_bo_code = 'EDI' AND l_pty_bo_code = 'PERSON') THEN
            RETURN;
          END IF;
        END IF;
      ELSIF(l_parent_tbl_name = 'HZ_PARTIES') THEN
        OPEN c_pty(l_parent_id);
        FETCH c_pty INTO l_bo_code, l_parent_tbl_name;
        CLOSE c_pty;
        IF(l_bo_code = 'ORG_CONTACT') THEN
          OPEN c_oc(l_parent_id);
          FETCH c_oc INTO l_oc_id;
          CLOSE c_oc;
          IF(l_oc_id IS NULL) THEN
            RETURN;
          ELSE
            l_parent_id := l_oc_id;
          END IF;
        END IF;
      END IF;

      -- if record not existing, insert into hz_bus_obj_tracking
      BEGIN
        l_child_rec_exists_no := 0;
        SELECT child_id INTO  l_child_rec_exists_no
        FROM  HZ_BUS_OBJ_TRACKING
        WHERE event_id IS NULL
        AND CHILD_ENTITY_NAME = l_cen
        AND CHILD_ID = l_child_id
        AND rownum = 1;

        IF l_child_rec_exists_no <> 0 THEN
          -- data already exists, no need to write
          hz_utility_v2pub.DEBUG(p_message=> 'CHILD record already exists in BOT',
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          INSERT INTO HZ_BUS_OBJ_TRACKING
          ( POPULATED_FLAG, CHILD_OPERATION_FLAG, CHILD_ID, CHILD_ENTITY_NAME, CHILD_BO_CODE,
            LAST_UPDATE_DATE, CREATION_DATE, PARENT_ENTITY_NAME, PARENT_ID, PARENT_BO_CODE
          ) VALUES (
            'N', p_operation, l_child_id, 'HZ_CONTACT_PREFERENCES', NULL,
            l_lud, l_lud, l_parent_tbl_name, l_parent_id, l_bo_code);
      END ; -- anonymous block end
    END LOOP;

    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_contact_preferences-',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);
  EXCEPTION
    WHEN OTHERS THEN
      hz_utility_v2pub.DEBUG(p_message=> SQLERRM,
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END pop_hz_contact_preferences;

-----------------------------------------------------------------
-- Procedure name: pop_hz_contact_points()
-- Purpose: populates BOT for HZ_CONTACT_POINTS create or update
-- Scope: internal
-- Called From: V2 API
-- Called By: HZ_CONTACT_POINTS create or update APIs
-- Input Parameters:
--   p_operation -- contains I or U.  'I' if create API is calling this otherwise 'U'.
--   p_contact_point_id IN NUMBER
--
-- Note:
--   Following are the allowed PARENT and CHILD BO combinations for HZ_CONTACT_POINTS
--   This procedure must ensure that the combination is valid before populating BOT
--
-- PARENT BO: ORG :: CHILD BO: PHONE
-- PARENT BO: ORG :: CHILD BO: TLX
-- PARENT BO: ORG :: CHILD BO: EMAIL
-- PARENT BO: ORG :: CHILD BO: WEB
-- PARENT BO: ORG :: CHILD BO: EDI
-- PARENT BO: ORG :: CHILD BO: EFT
-- PARENT BO: PERSON :: CHILD BO: PHONE
-- PARENT BO: PERSON :: CHILD BO: EMAIL
-- PARENT BO: PERSON :: CHILD BO: WEB
-- PARENT BO: PERSON :: CHILD BO: SMS
-- PARENT BO: ORG_CONTACT :: CHILD BO: PHONE
-- PARENT BO: ORG_CONTACT :: CHILD BO: TLX
-- PARENT BO: ORG_CONTACT :: CHILD BO: EMAIL
-- PARENT BO: ORG_CONTACT :: CHILD BO: WEB
-- PARENT BO: ORG_CONTACT :: CHILD BO: SMS
-- PARENT BO: PARTY_SITE :: CHILD BO: PHONE
-- PARENT BO: PARTY_SITE :: CHILD BO: TLX
-- PARENT BO: PARTY_SITE :: CHILD BO: EMAIL
-- PARENT BO: PARTY_SITE :: CHILD BO: WEB
-----------------------------------------------------------------
  PROCEDURE pop_hz_contact_points(p_operation IN VARCHAR2, p_contact_point_id IN NUMBER) IS

    -- cursor statement to select the info from child table
    CURSOR c_child IS
      SELECT LAST_UPDATE_DATE lud, OWNER_TABLE_ID parent_id, CONTACT_POINT_ID child_id,
             OWNER_TABLE_NAME parent_entity, CONTACT_POINT_TYPE child_bo_code
      FROM HZ_CONTACT_POINTS
      WHERE CONTACT_POINT_ID = P_CONTACT_POINT_ID
      AND OWNER_TABLE_NAME in ('HZ_PARTY_SITES', 'HZ_PARTIES');

    -- cursor statement to select the info from party parent table
    CURSOR c_party_parent(p_parent_id IN NUMBER) IS
      SELECT decode(party_type, 'ORGANIZATION', 'ORG', 'PERSON', 'PERSON', 'PARTY_RELATIONSHIP', 'ORG_CONTACT', NULL),
             decode(party_type, 'ORGANIZATION', 'HZ_PARTIES', 'PERSON', 'HZ_PARTIES', 'PARTY_RELATIONSHIP', 'HZ_ORG_CONTACTS', NULL)
      FROM  HZ_PARTIES
      WHERE PARTY_ID = p_parent_id
      AND party_type in ('ORGANIZATION', 'PERSON', 'PARTY_RELATIONSHIP');

    CURSOR c_oc(p_parent_id NUMBER) IS
      SELECT oc.org_contact_id
      FROM HZ_RELATIONSHIPS r, HZ_ORG_CONTACTS oc
      WHERE r.relationship_id = oc.party_relationship_id
      AND r.subject_type = 'PERSON'
      AND r.object_type = 'ORGANIZATION'
      AND r.party_id = p_parent_id
      AND rownum = 1;

    -- local variables
    l_debug_prefix            VARCHAR2(40) := 'pop_hz_contact_points';
    l_parent_id               NUMBER; -- used to store parent entity identifier
    l_parent_tbl_name         VARCHAR2(30); -- used to store parent entity name
    l_bo_code                 VARCHAR2(30); -- used to store BO Code
    l_child_bo_code           VARCHAR2(30); -- used to store Child BO Code (if child entity is a root node)
    l_child_id                NUMBER; -- used to store HZ_CONTACT_POINTS identifier
    l_lud                     DATE; -- used to store the child last update date
    l_child_rec_exists_no     NUMBER;
    l_oc_id                   NUMBER;
    l_cen                     VARCHAR2(30) := 'HZ_CONTACT_POINTS';
  BEGIN
    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_contact_points+',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);

    -- validate p_operation
    IF p_operation IN ('I','U') THEN
      NULL;
    ELSE
      hz_utility_v2pub.DEBUG(p_message=> 'incorrect operation flag sent to pop_hz_contact_points',
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    FOR c_child_rec IN c_child LOOP
      -- collect the child info into variables
      l_lud := c_child_rec.lud;
      l_child_id := c_child_rec.child_id;
      l_child_bo_code := c_child_rec.child_bo_code;
      l_parent_id := c_child_rec.parent_id;
      l_parent_tbl_name := c_child_rec.parent_entity;

      IF(l_parent_tbl_name = 'HZ_PARTY_SITES') THEN
        l_bo_code := 'PARTY_SITE';
      ELSIF(l_parent_tbl_name = 'HZ_PARTIES') THEN
        OPEN c_party_parent(l_parent_id);
        FETCH c_party_parent INTO l_bo_code, l_parent_tbl_name;
        CLOSE c_party_parent;
        IF(l_bo_code = 'ORG_CONTACT') THEN
          OPEN c_oc(l_parent_id);
          FETCH c_oc INTO l_oc_id;
          CLOSE c_oc;
          IF(l_oc_id IS NULL) THEN
            RETURN;
          ELSE
            l_parent_id := l_oc_id;
          END IF;
        END IF;
      END IF;

      -- check invalid combination
      CASE
        WHEN l_child_bo_code = 'PHONE' THEN
          NULL;
        WHEN l_bo_code = 'PARTY_SITE' AND l_child_bo_code in ('TLX','EMAIL','WEB') THEN
          NULL;
        WHEN l_bo_code = 'ORG' AND l_child_bo_code in ('TLX','EMAIL','WEB','EDI','EFT') THEN
          NULL;
        WHEN l_bo_code = 'PERSON' AND l_child_bo_code in ('EMAIL','WEB','SMS') THEN
          NULL;
        WHEN l_bo_code = 'ORG_CONTACT' AND l_child_bo_code in ('TLX','EMAIL','WEB','SMS') THEN
          NULL;
        ELSE
          RETURN;
      END CASE;

      CASE
        WHEN l_bo_code = 'PARTY_SITE' THEN
          IF NOT(is_valid_ps(l_parent_id)) THEN
            RETURN;
          END IF;
        ELSE
          NULL;
      END CASE;

      -- if record not existing, insert into hz_bus_obj_tracking
      BEGIN
        l_child_rec_exists_no := 0;
        SELECT child_id INTO  l_child_rec_exists_no
        FROM  HZ_BUS_OBJ_TRACKING
        WHERE event_id IS NULL
        AND CHILD_ENTITY_NAME = l_cen
        AND CHILD_ID = l_child_id
        AND rownum = 1;

        IF l_child_rec_exists_no <> 0 THEN
          -- data already exists, no need to write
          hz_utility_v2pub.DEBUG(p_message=> 'CHILD record already exists in BOT',
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          -- populate the child bo code also
          INSERT INTO HZ_BUS_OBJ_TRACKING
          ( POPULATED_FLAG, CHILD_OPERATION_FLAG, CHILD_ID, CHILD_ENTITY_NAME, CHILD_BO_CODE,
            LAST_UPDATE_DATE, CREATION_DATE, PARENT_ENTITY_NAME, PARENT_ID, PARENT_BO_CODE
          ) VALUES (
            'N', p_operation, l_child_id, 'HZ_CONTACT_POINTS', l_child_bo_code,
            l_lud, l_lud, l_parent_tbl_name, l_parent_id, l_bo_code);
      END ; -- anonymous block end
    END LOOP;

    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_contact_points-',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);
  EXCEPTION
    WHEN OTHERS THEN
      hz_utility_v2pub.DEBUG(p_message=> SQLERRM,
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END pop_hz_contact_points;

-----------------------------------------------------------------
-- Procedure name: pop_hz_code_assignments()
-- Purpose: populates BOT for HZ_CODE_ASSIGNMENTS create or update
-- Scope: internal
-- Called From: V2 API
-- Called By: HZ_CODE_ASSIGNMENTS create or update APIs
--   p_code_assignment_id IN NUMBER
--
-- Note:
--   Following are the allowed PARENT and CHILD BO combinations for HZ_CODE_ASSIGNMENTS
--   This procedure must ensure that the combination is valid before populating BOT
--
-- PARENT BO: ORG :: CHILD BO:
-- PARENT BO: PERSON :: CHILD BO:
-----------------------------------------------------------------
  PROCEDURE pop_hz_code_assignments(p_operation IN VARCHAR2, p_code_assignment_id IN NUMBER) IS

    CURSOR C_child IS
      SELECT pp.LAST_UPDATE_DATE lud,  pp.OWNER_TABLE_ID parent_id, pp.CODE_ASSIGNMENT_ID child_id,
             decode(p.party_type, 'ORGANIZATION', 'ORG', 'PERSON', 'PERSON', NULL) bo_code
      FROM HZ_CODE_ASSIGNMENTS pp, HZ_PARTIES p
      WHERE pp.code_assignment_id = p_code_assignment_id
      AND pp.OWNER_TABLE_ID = p.party_id
      AND pp.OWNER_TABLE_NAME = 'HZ_PARTIES'
      AND p.party_type in ('ORGANIZATION', 'PERSON');

    -- local variables
    l_debug_prefix    VARCHAR2(40) := 'pop_hz_code_assignments';
    l_parent_id       NUMBER; -- used to store parent entity identifier
    l_child_id        NUMBER; -- used to store HZ_CODE_ASSIGNMENTS identifier
    l_lud             DATE; -- used to store the child last update date
    l_bo_code         VARCHAR2(30);
    l_child_rec_exists_no     NUMBER;
    l_cen                     VARCHAR2(30) := 'HZ_CODE_ASSIGNMENTS';
  BEGIN
    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_code_assignments+',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);

    -- validate p_operation
    IF p_operation IN ('I','U') THEN
      NULL;
    ELSE
      hz_utility_v2pub.DEBUG(p_message=> 'incorrect operation flag sent to pop_hz_code_assignments',
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    FOR c_child_rec IN c_child LOOP
      -- collect the child info into variables
      l_lud := c_child_rec.lud;
      l_child_id := c_child_rec.child_id;
      l_parent_id := c_child_rec.parent_id;
      l_bo_code := c_child_rec.bo_code;

      -- if record not existing, insert into hz_bus_obj_tracking
      BEGIN
        l_child_rec_exists_no := 0;
        SELECT child_id INTO  l_child_rec_exists_no
        FROM  HZ_BUS_OBJ_TRACKING
        WHERE event_id IS NULL
        AND CHILD_ENTITY_NAME = l_cen
        AND CHILD_ID = l_child_id
        AND rownum = 1;

        IF l_child_rec_exists_no <> 0 THEN
          -- data already exists, no need to write
          hz_utility_v2pub.DEBUG(p_message=> 'CHILD record already exists in BOT',
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          INSERT INTO HZ_BUS_OBJ_TRACKING
          ( POPULATED_FLAG, CHILD_OPERATION_FLAG, CHILD_ID, CHILD_ENTITY_NAME, CHILD_BO_CODE,
            LAST_UPDATE_DATE, CREATION_DATE, PARENT_ENTITY_NAME, PARENT_ID, PARENT_BO_CODE
          ) VALUES (
            'N', p_operation, l_child_id, 'HZ_CODE_ASSIGNMENTS', NULL,
            l_lud, l_lud, 'HZ_PARTIES', l_parent_id, l_bo_code);

          pop_parent_record(p_child_id     => l_parent_id,
                            p_lud          => l_lud,
                            p_centity_name => 'HZ_PARTIES',
                            p_cbo_code     => l_bo_code,
                            p_parent_id    => NULL,
                            p_pentity_name => NULL,
                            p_pbo_code     => NULL);
      END ; -- anonymous block end
    END LOOP;

    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_code_assignments-',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);
  EXCEPTION
    WHEN OTHERS THEN
      hz_utility_v2pub.DEBUG(p_message=> SQLERRM,
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END pop_hz_code_assignments;

-----------------------------------------------------------------
-- Procedure name: pop_hz_citizenship()
-- Purpose: populates BOT for HZ_CITIZENSHIP create or update
-- Scope: internal
-- Called From: V2 API
-- Called By: HZ_CITIZENSHIP create or update APIs
-- Input Parameters:
--   p_operation -- contains I or U.  'I' if create API is calling this otherwise 'U'.
--   p_citizenship_id IN NUMBER
--
-- Note:
--   Following are the allowed PARENT and CHILD BO combinations for HZ_CITIZENSHIP
--   This procedure must ensure that the combination is valid before populating BOT
--
-- PARENT BO: PERSON :: CHILD BO:
-----------------------------------------------------------------
  PROCEDURE pop_hz_citizenship(p_operation IN VARCHAR2, p_citizenship_id IN NUMBER) IS

    -- cursor statement to select the info from child table
    CURSOR C_child IS
      SELECT c.LAST_UPDATE_DATE lud, c.PARTY_ID parent_id, c.CITIZENSHIP_ID child_id
      FROM HZ_CITIZENSHIP c, HZ_PARTIES p
      WHERE c.CITIZENSHIP_ID = P_CITIZENSHIP_ID
      AND c.party_id = p.party_id
      AND p.party_type = 'PERSON';

    -- local variables
    l_debug_prefix    VARCHAR2(40) := 'pop_hz_citizenship';
    l_parent_id       NUMBER; -- used to store parent entity identifier
    l_child_id        NUMBER; -- used to store HZ_CITIZENSHIP identifier
    l_lud             DATE; -- used to store the child last update date
    l_child_rec_exists_no     NUMBER;
    l_cen                     VARCHAR2(30) := 'HZ_CITIZENSHIP';
  BEGIN
    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_citizenship+',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);

    -- validate p_operation
    IF p_operation IN ('I','U') THEN
      NULL;
    ELSE
      hz_utility_v2pub.DEBUG(p_message=> 'incorrect operation flag sent to pop_hz_citizenship',
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    FOR c_child_rec IN c_child LOOP
      -- collect the child info into variables
      l_lud := c_child_rec.lud;
      l_child_id := c_child_rec.child_id;
      l_parent_id := c_child_rec.parent_id;

      -- if record not existing, insert into hz_bus_obj_tracking
      BEGIN
        l_child_rec_exists_no := 0;
        SELECT child_id INTO  l_child_rec_exists_no
        FROM  HZ_BUS_OBJ_TRACKING
        WHERE event_id IS NULL
        AND CHILD_ENTITY_NAME = l_cen
        AND CHILD_ID = l_child_id
        AND rownum = 1;

        IF l_child_rec_exists_no <> 0 THEN
          -- data already exists, no need to write
          hz_utility_v2pub.DEBUG(p_message=> 'CHILD record already exists in BOT',
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          INSERT INTO HZ_BUS_OBJ_TRACKING
          ( POPULATED_FLAG, CHILD_OPERATION_FLAG, CHILD_ID, CHILD_ENTITY_NAME, CHILD_BO_CODE,
            LAST_UPDATE_DATE, CREATION_DATE, PARENT_ENTITY_NAME, PARENT_ID, PARENT_BO_CODE
          ) VALUES (
            'N', p_operation, l_child_id, 'HZ_CITIZENSHIP', NULL,
            l_lud, l_lud, 'HZ_PARTIES', l_parent_id, 'PERSON');

          pop_parent_record(p_child_id     => l_parent_id,
                            p_lud          => l_lud,
                            p_centity_name => 'HZ_PARTIES',
                            p_cbo_code     => 'PERSON',
                            p_parent_id    => NULL,
                            p_pentity_name => NULL,
                            p_pbo_code     => NULL);
      END ; -- anonymous block end
    END LOOP;

    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_citizenship-',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);
  EXCEPTION
    WHEN OTHERS THEN
      hz_utility_v2pub.DEBUG(p_message=> SQLERRM,
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END pop_hz_citizenship;

-----------------------------------------------------------------
-- Procedure name: pop_hz_certifications()
-- Purpose: populates BOT for HZ_CERTIFICATIONS create or update
-- Scope: internal
-- Called From: V2 API
-- Called By: HZ_CERTIFICATIONS create or update APIs
-- Input Parameters:
--   p_operation -- contains I or U.  'I' if create API is calling this otherwise 'U'.
--   p_certification_id IN NUMBER
--
-- Note:
--   Following are the allowed PARENT and CHILD BO combinations for HZ_CERTIFICATIONS
--   This procedure must ensure that the combination is valid before populating BOT
--
-- PARENT BO: ORG :: CHILD BO:
-- PARENT BO: PERSON :: CHILD BO:
-----------------------------------------------------------------
  PROCEDURE pop_hz_certifications(p_operation IN VARCHAR2, p_certification_id IN NUMBER) IS

    -- cursor statement to select the info from child table
    CURSOR C_child IS
      SELECT c.LAST_UPDATE_DATE lud, c.PARTY_ID parent_id, c.CERTIFICATION_ID child_id,
             decode(p.party_type, 'ORGANIZATION', 'ORG', 'PERSON', 'PERSON', NULL) bo_code
      FROM HZ_CERTIFICATIONS c, HZ_PARTIES p
      WHERE c.CERTIFICATION_ID = P_CERTIFICATION_ID
      AND c.party_id = p.party_id
      AND p.party_type in ('ORGANIZATION', 'PERSON');

    -- local variables
    l_debug_prefix    VARCHAR2(40) := 'pop_hz_certifications';
    l_parent_id       NUMBER; -- used to store parent entity identifier
    l_bo_code         VARCHAR2(30); -- used to store BO Code
    l_child_id        NUMBER; -- used to store HZ_CERTIFICATIONS identifier
    l_lud             DATE; -- used to store the child last update date
    l_child_rec_exists_no     NUMBER;
    l_cen                     VARCHAR2(30) := 'HZ_CERTIFICATIONS';
  BEGIN
    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_certifications+',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);

    -- validate p_operation
    IF p_operation IN ('I','U') THEN
      NULL;
    ELSE
      hz_utility_v2pub.DEBUG(p_message=> 'incorrect operation flag sent to pop_hz_certifications',
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    FOR c_child_rec IN c_child LOOP
      l_lud := c_child_rec.lud;
      l_child_id := c_child_rec.child_id;
      l_parent_id := c_child_rec.parent_id;
      l_bo_code := c_child_rec.bo_code;

      -- if record not existing, insert into hz_bus_obj_tracking
      BEGIN
        l_child_rec_exists_no := 0;
        SELECT child_id INTO  l_child_rec_exists_no
        FROM  HZ_BUS_OBJ_TRACKING
        WHERE event_id IS NULL
        AND CHILD_ENTITY_NAME = l_cen
        AND CHILD_ID = l_child_id
        AND rownum = 1;

        IF l_child_rec_exists_no <> 0 THEN
          -- data already exists, no need to write
          hz_utility_v2pub.DEBUG(p_message=> 'CHILD record already exists in BOT',
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          INSERT INTO HZ_BUS_OBJ_TRACKING
          ( POPULATED_FLAG, CHILD_OPERATION_FLAG, CHILD_ID, CHILD_ENTITY_NAME, CHILD_BO_CODE,
            LAST_UPDATE_DATE, CREATION_DATE, PARENT_ENTITY_NAME, PARENT_ID, PARENT_BO_CODE
          ) VALUES (
            'N', p_operation, l_child_id, 'HZ_CERTIFICATIONS', NULL,
            l_lud, l_lud, 'HZ_PARTIES', l_parent_id, l_bo_code);

          pop_parent_record(p_child_id     => l_parent_id,
                            p_lud          => l_lud,
                            p_centity_name => 'HZ_PARTIES',
                            p_cbo_code     => l_bo_code,
                            p_parent_id    => NULL,
                            p_pentity_name => NULL,
                            p_pbo_code     => NULL);
      END ; -- anonymous block end
    END LOOP;

    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_certifications-',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);
  EXCEPTION
    WHEN OTHERS THEN
      hz_utility_v2pub.DEBUG(p_message=> SQLERRM,
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END pop_hz_certifications;
-----------------------------------------------------------------
-- Procedure name: pop_HZ_PARTY_USG_ASSIGNMENTS()
-- Purpose: populates BOT for HZ_PARTY_USG_ASSIGNMENTS create or update
-- Scope: internal
-- Called From: V2 API
-- Called By: HZ_PARTY_USG_ASSIGNMENTS create or update APIs
-- Input Parameters:
--   p_operation -- contains I or U.  'I' if create API is calling this otherwise 'U'.
--   p_PARTY_USG_ASSIGNMENT_id IN NUMBER
--
-- Note:
--   Following are the allowed PARENT and CHILD BO combinations for HZ_CERTIFICATIONS
--   This procedure must ensure that the combination is valid before populating BOT
--
-- PARENT BO: ORG :: CHILD BO:
-- PARENT BO: PERSON :: CHILD BO:
-----------------------------------------------------------------
 PROCEDURE pop_HZ_PARTY_USG_ASSIGNMENTS (
           p_operation IN VARCHAR2,
           p_PARTY_USG_ASSIGNMENT_ID IN NUMBER) IS

    -- cursor statement to select the info from child table
    CURSOR C_child IS
      SELECT c.LAST_UPDATE_DATE lud, c.PARTY_ID parent_id, c.PARTY_USG_ASSIGNMENT_ID child_id,
             decode(p.party_type, 'ORGANIZATION', 'ORG', 'PERSON', 'PERSON', NULL) bo_code
      FROM HZ_PARTY_USG_ASSIGNMENTS c, HZ_PARTIES p
      WHERE c.PARTY_USG_ASSIGNMENT_ID = P_PARTY_USG_ASSIGNMENT_ID
      AND c.party_id = p.party_id
      AND p.party_type in ('ORGANIZATION', 'PERSON');

    -- local variables
    l_debug_prefix    VARCHAR2(40) := 'pop_HZ_PARTY_USG_ASSIGNMENTS';
    l_parent_id       NUMBER; -- used to store parent entity identifier
    l_bo_code         VARCHAR2(30); -- used to store BO Code
    l_child_id        NUMBER; -- used to store HZ_PARTY_USG_ASSIGNMENTS identifier
    l_lud             DATE; -- used to store the child last update date
    l_child_rec_exists_no     NUMBER;
    l_cen                     VARCHAR2(30) := 'HZ_PARTY_USG_ASSIGNMENTS';
  BEGIN
    hz_utility_v2pub.DEBUG(p_message=>'pop_HZ_PARTY_USG_ASSIGNMENTS+',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);

    -- validate p_operation
    IF p_operation IN ('I','U') THEN
      NULL;
    ELSE
      hz_utility_v2pub.DEBUG(p_message=> 'incorrect operation flag sent to pop_HZ_PARTY_USG_ASSIGNMENTS',
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    FOR c_child_rec IN c_child LOOP
      l_lud := c_child_rec.lud;
      l_child_id := c_child_rec.child_id;
      l_parent_id := c_child_rec.parent_id;
      l_bo_code := c_child_rec.bo_code;

      -- if record not existing, insert into hz_bus_obj_tracking
      BEGIN
        l_child_rec_exists_no := 0;
        SELECT child_id INTO  l_child_rec_exists_no
        FROM  HZ_BUS_OBJ_TRACKING
        WHERE event_id IS NULL
        AND CHILD_ENTITY_NAME = l_cen
        AND CHILD_ID = l_child_id
        AND rownum = 1;

        IF l_child_rec_exists_no <> 0 THEN
          -- data already exists, no need to write
          hz_utility_v2pub.DEBUG(p_message=> 'CHILD record already exists in BOT',
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          INSERT INTO HZ_BUS_OBJ_TRACKING
          ( POPULATED_FLAG, CHILD_OPERATION_FLAG, CHILD_ID, CHILD_ENTITY_NAME, CHILD_BO_CODE,
            LAST_UPDATE_DATE, CREATION_DATE, PARENT_ENTITY_NAME, PARENT_ID, PARENT_BO_CODE
          ) VALUES (
            'N', p_operation, l_child_id, 'HZ_PARTY_USG_ASSIGNMENTS', NULL,
            l_lud, l_lud, 'HZ_PARTIES', l_parent_id, l_bo_code);

          pop_parent_record(p_child_id     => l_parent_id,
                            p_lud          => l_lud,
                            p_centity_name => 'HZ_PARTIES',
                            p_cbo_code     => l_bo_code,
                            p_parent_id    => NULL,
                            p_pentity_name => NULL,
                            p_pbo_code     => NULL);
      END ; -- anonymous block end
    END LOOP;

    hz_utility_v2pub.DEBUG(p_message=>'pop_HZ_PARTY_USG_ASSIGNMENTS-',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);
  EXCEPTION
    WHEN OTHERS THEN
      hz_utility_v2pub.DEBUG(p_message=> SQLERRM,
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END pop_HZ_PARTY_USG_ASSIGNMENTS;

-----------------------------------------------------------------
-- Procedure name: pop_hz_extensibility()
-- Purpose: populates BOT for extensibility create or update
-- Scope: internal
-- Called From: V2 API
-- Called By: HZ_EXTENSIBILITY_PUB create or update APIs
-- Input Parameters:
--   p_operation -- contains I or U.  'I' if create API is calling this otherwise 'U'.
--   p_certification_id IN NUMBER
--
-- Note:
--   Following are the allowed PARENT and CHILD BO combinations for extensibility attributes
--   This procedure must ensure that the combination is valid before populating BOT
--
-- PARENT BO: ORG :: CHILD BO:
-- PARENT BO: PERSON :: CHILD BO:
-- PARENT BO: LOCATION :: CHILD BO:
-- PARENT BO: PARTY_SITE :: CHILD BO:
-----------------------------------------------------------------
  PROCEDURE pop_hz_extensibility(p_operation IN VARCHAR2, p_object_type IN VARCHAR2, p_extension_id IN NUMBER) IS

    -- cursor statement to select the info from child table
    CURSOR C_child_org IS
      SELECT c.LAST_UPDATE_DATE lud, p.PARTY_ID parent_id, c.extension_id child_id, 'ORG' bo_code, 'HZ_PARTIES' parent_entity
      FROM HZ_ORG_PROFILES_EXT_B c, HZ_ORGANIZATION_PROFILES p
      WHERE c.EXTENSION_ID = P_EXTENSION_ID
      AND c.ORGANIZATION_PROFILE_ID = p.ORGANIZATION_PROFILE_ID
      AND rownum = 1;

    CURSOR C_child_per IS
      SELECT c.LAST_UPDATE_DATE lud, p.PARTY_ID parent_id, c.extension_id child_id, 'PERSON' bo_code, 'HZ_PARTIES' parent_entity
      FROM HZ_PER_PROFILES_EXT_B c, HZ_PERSON_PROFILES p
      WHERE c.EXTENSION_ID = P_EXTENSION_ID
      AND c.PERSON_PROFILE_ID = p.PERSON_PROFILE_ID
      AND rownum = 1;

    CURSOR C_child_loc IS
      SELECT c.LAST_UPDATE_DATE lud, c.LOCATION_ID parent_id, c.extension_id child_id, 'LOCATION' bo_code, 'HZ_LOCATIONS' parent_entity
      FROM HZ_LOCATIONS_EXT_B c
      WHERE c.EXTENSION_ID = P_EXTENSION_ID
      AND rownum = 1;

    CURSOR C_child_ps IS
      SELECT c.LAST_UPDATE_DATE lud, c.PARTY_SITE_ID parent_id, c.extension_id child_id, 'PARTY_SITE' bo_code, 'HZ_PARTY_SITES' parent_entity
      FROM HZ_PARTY_SITES_EXT_B c
      WHERE c.EXTENSION_ID = P_EXTENSION_ID
      AND rownum = 1;

    -- local variables
    l_debug_prefix    VARCHAR2(40) := 'pop_hz_extensibility';
    l_parent_id       NUMBER; -- used to store parent entity identifier
    l_bo_code         VARCHAR2(30); -- used to store BO Code
    l_child_entity    VARCHAR2(30);
    l_parent_entity   VARCHAR2(30);
    l_child_id        NUMBER; -- used to store extensibility attributes identifier
    l_lud             DATE; -- used to store the child last update date
    l_child_rec_exists_no     NUMBER;
  BEGIN
    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_extensibility+',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);

    -- validate p_operation
    IF p_operation IN ('I','U') THEN
      NULL;
    ELSE
      hz_utility_v2pub.DEBUG(p_message=> 'incorrect operation flag sent to pop_hz_extensibility',
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF(p_object_type = 'ORG') THEN
      OPEN c_child_org;
      l_child_entity := 'HZ_ORG_PROFILES_EXT_VL';
    ELSIF(p_object_type = 'PERSON') THEN
      OPEN c_child_per;
      l_child_entity := 'HZ_PER_PROFILES_EXT_VL';
    ELSIF(p_object_type = 'LOCATION') THEN
      OPEN c_child_loc;
      l_child_entity := 'HZ_LOCATIONS_EXT_VL';
    ELSIF(p_object_type = 'PARTY_SITE') THEN
      OPEN c_child_ps;
      l_child_entity := 'HZ_PARTY_SITES_EXT_VL';
    END IF;

    IF(p_object_type = 'ORG') THEN
      FETCH c_child_org INTO l_lud, l_parent_id, l_child_id, l_bo_code, l_parent_entity;
    ELSIF(p_object_type = 'PERSON') THEN
      FETCH c_child_per INTO l_lud, l_parent_id, l_child_id, l_bo_code, l_parent_entity;
    ELSIF(p_object_type = 'LOCATION') THEN
      FETCH c_child_loc INTO l_lud, l_parent_id, l_child_id, l_bo_code, l_parent_entity;
    ELSIF(p_object_type = 'PARTY_SITE') THEN
      FETCH c_child_ps INTO l_lud, l_parent_id, l_child_id, l_bo_code, l_parent_entity;
    END IF;

    -- if record not existing, insert into hz_bus_obj_tracking
    BEGIN
      l_child_rec_exists_no := 0;
      SELECT child_id INTO  l_child_rec_exists_no
      FROM  HZ_BUS_OBJ_TRACKING
      WHERE event_id IS NULL
      AND CHILD_ENTITY_NAME = l_child_entity
      AND CHILD_ID = l_child_id
      AND rownum = 1;

      IF l_child_rec_exists_no <> 0 THEN
        -- data already exists, no need to write
        hz_utility_v2pub.DEBUG(p_message=> 'CHILD record already exists in BOT',
                               p_prefix=>l_debug_prefix,
                               p_msg_level=>fnd_log.level_procedure);
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        INSERT INTO HZ_BUS_OBJ_TRACKING
        ( POPULATED_FLAG, CHILD_OPERATION_FLAG, CHILD_ID, CHILD_ENTITY_NAME, CHILD_BO_CODE,
          LAST_UPDATE_DATE, CREATION_DATE, PARENT_ENTITY_NAME, PARENT_ID, PARENT_BO_CODE
        ) VALUES (
          'N', p_operation, l_child_id, l_child_entity, NULL,
          l_lud, l_lud, l_parent_entity, l_parent_id, l_bo_code);
    END ; -- anonymous block end

    IF(p_object_type = 'ORG') THEN
      CLOSE c_child_org;
    ELSIF(p_object_type = 'PERSON') THEN
      CLOSE c_child_per;
    ELSIF(p_object_type = 'LOCATION') THEN
      CLOSE c_child_loc;
    ELSIF(p_object_type = 'PARTY_SITE') THEN
      CLOSE c_child_ps;
    END IF;

    hz_utility_v2pub.DEBUG(p_message=>'pop_hz_extensibility-',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);
  EXCEPTION
    WHEN OTHERS THEN
      hz_utility_v2pub.DEBUG(p_message=> SQLERRM,
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END pop_hz_extensibility;

-----------------------------------------------------------------
-- Procedure name: pop_ra_cust_receipt_methods()
-- Purpose: populates BOT for RA_CUST_RECEIPT_METHODS create or update
-- Scope: internal
-- Called From: V2 API
-- Called By: HZ_PAYMENT_METHOD_PUB create or update APIs
-- Input Parameters:
--   p_operation -- contains I or U.  'I' if create API is calling this otherwise 'U'.
--   p_cust_receipt_method_id IN NUMBER
--
-- Note:
--   Following are the allowed PARENT and CHILD BO combinations for RA_CUST_RECEIPT_METHODS
--   This procedure must ensure that the combination is valid before populating BOT
--
-- PARENT BO: CUST_ACCT_SITE_USE :: CHILD BO:
-- PARENT BO: CUST_ACCT :: CHILD BO:
-----------------------------------------------------------------
  PROCEDURE pop_ra_cust_receipt_methods(p_operation IN VARCHAR2, p_cust_receipt_method_id IN NUMBER) IS

    -- cursor statement to select the info from child table
    CURSOR C_child IS
      SELECT rcrm.last_update_date lud, rcrm.cust_receipt_method_id child_id,
             nvl(rcrm.site_use_id, rcrm.customer_id) parent_id,
             decode(rcrm.site_use_id, NULL, 'HZ_CUST_ACCOUNTS', 'HZ_CUST_SITE_USES_ALL') parent_tbl_name,
             decode(rcrm.site_use_id, NULL, 'CUST_ACCT', 'CUST_ACCT_SITE_USE') parent_bo_code,
             decode(rcrm.site_use_id, NULL, p.party_id, rcrm.customer_id) grand_parent_id,
             decode(rcrm.site_use_id, NULL, 'HZ_PARTIES', 'HZ_CUST_ACCOUNTS') grand_parent_tbl_name,
             decode(rcrm.site_use_id, NULL, decode(p.party_type, 'ORGANIZATION', 'ORG_CUST', 'PERSON', 'PERSON_CUST', NULL), 'CUST_ACCT') grand_parent_bo_code
      FROM RA_CUST_RECEIPT_METHODS rcrm, HZ_CUST_ACCOUNTS ca, HZ_PARTIES p
      WHERE rcrm.cust_receipt_method_id = p_cust_receipt_method_id
      AND rcrm.customer_id = ca.cust_account_id
      AND ca.party_id = p.party_id
      AND p.party_type in ('ORGANIZATION', 'PERSON')
      AND rcrm.customer_id > 0;

    -- local variables
    l_debug_prefix            VARCHAR2(40) := 'pop_ra_cust_receipt_methods';
    l_parent_id               NUMBER; -- used to store parent entity identifier
    l_bo_code                 VARCHAR2(30); -- used to store BO Code
    l_child_id                NUMBER; -- used to store HZ_CERTIFICATIONS identifier
    l_lud                     DATE; -- used to store the child last update date
    l_child_rec_exists_no     NUMBER;
    l_parent_bo_code          VARCHAR2(30);
    l_parent_tbl_name         VARCHAR2(30);
    l_g_parent_id             NUMBER;
    l_g_parent_tbl_name       VARCHAR2(30);
    l_g_parent_bo_code        VARCHAR2(30);
    l_cen                     VARCHAR2(30) := 'RA_CUST_RECEIPT_METHODS';
  BEGIN
    hz_utility_v2pub.DEBUG(p_message=>'pop_ra_cust_receipt_methods+',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);

    -- validate p_operation
    IF p_operation IN ('I','U') THEN
      NULL;
    ELSE
      hz_utility_v2pub.DEBUG(p_message=> 'incorrect operation flag sent to pop_ra_cust_receipt_methods',
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    FOR c_child_rec IN c_child LOOP
      l_lud := c_child_rec.lud;
      l_child_id := c_child_rec.child_id;
      l_parent_id := c_child_rec.parent_id;
      l_parent_tbl_name := c_child_rec.parent_tbl_name;
      l_parent_bo_code := c_child_rec.parent_bo_code;
      l_g_parent_id := c_child_rec.grand_parent_id;
      l_g_parent_tbl_name := c_child_rec.grand_parent_tbl_name;
      l_g_parent_bo_code := c_child_rec.grand_parent_bo_code;

      -- if record not existing, insert into hz_bus_obj_tracking
      BEGIN
        l_child_rec_exists_no := 0;
        SELECT child_id INTO  l_child_rec_exists_no
        FROM  HZ_BUS_OBJ_TRACKING
        WHERE event_id IS NULL
        AND CHILD_ENTITY_NAME = l_cen
        AND CHILD_ID = l_child_id
        AND rownum = 1;

        IF l_child_rec_exists_no <> 0 THEN
          -- data already exists, no need to write
          hz_utility_v2pub.DEBUG(p_message=> 'CHILD record already exists in BOT',
                                 p_prefix=>l_debug_prefix,
                                 p_msg_level=>fnd_log.level_procedure);
        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          INSERT INTO HZ_BUS_OBJ_TRACKING
          ( POPULATED_FLAG, CHILD_OPERATION_FLAG, CHILD_ID, CHILD_ENTITY_NAME, CHILD_BO_CODE,
            LAST_UPDATE_DATE, CREATION_DATE, PARENT_ENTITY_NAME, PARENT_ID, PARENT_BO_CODE
          ) VALUES (
            'N', p_operation, l_child_id, 'RA_CUST_RECEIPT_METHODS', NULL,
            l_lud, l_lud, l_parent_tbl_name, l_parent_id, l_parent_bo_code);

          pop_parent_record(p_child_id     => l_parent_id,
                            p_lud          => l_lud,
                            p_centity_name => l_parent_tbl_name,
                            p_cbo_code     => l_parent_bo_code,
                            p_parent_id    => l_g_parent_id,
                            p_pentity_name => l_g_parent_tbl_name,
                            p_pbo_code     => l_g_parent_bo_code);
      END ; -- anonymous block end
    END LOOP;

    hz_utility_v2pub.DEBUG(p_message=>'pop_ra_cust_receipt_methods-',
                           p_prefix=>l_debug_prefix,
                           p_msg_level=>fnd_log.level_procedure);
  EXCEPTION
    WHEN OTHERS THEN
      hz_utility_v2pub.DEBUG(p_message=> SQLERRM,
                             p_prefix=>l_debug_prefix,
                             p_msg_level=>fnd_log.level_procedure);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END pop_ra_cust_receipt_methods;

  FUNCTION is_valid_ps(
    p_party_site_id  IN NUMBER
  ) RETURN BOOLEAN IS
    CURSOR get_ps IS
    SELECT p.party_type, p.party_id
    FROM HZ_PARTY_SITES ps, HZ_PARTIES p
    WHERE ps.party_site_id = p_party_site_id
    AND ps.party_id = p.party_id
    AND p.party_type in ('ORGANIZATION', 'PERSON', 'PARTY_RELATIONSHIP');

    CURSOR get_oc(l_party_id NUMBER) IS
    SELECT 1
    FROM HZ_PARTIES p, HZ_RELATIONSHIPS r
    WHERE p.party_id = l_party_id
    AND p.party_id = r.party_id
    AND r.subject_type = 'PERSON'
    AND r.object_type = 'ORGANIZATION'
    AND rownum = 1;

    l_party_type        VARCHAR2(30);
    l_party_id          NUMBER;
    l_dummy             NUMBER;
  BEGIN
    OPEN get_ps;
    FETCH get_ps INTO l_party_type, l_party_id;
    CLOSE get_ps;
    IF(l_party_type IS NULL) THEN
      RETURN FALSE;
    ELSIF(l_party_type = 'PARTY_RELATIONSHIP') THEN
      OPEN get_oc(l_party_id);
      FETCH get_oc INTO l_dummy;
      CLOSE get_oc;
      IF(l_dummy IS NULL) THEN
        RETURN FALSE;
      END IF;
    END IF;
    RETURN TRUE;
  END;

END HZ_POPULATE_BOT_PKG;

/
