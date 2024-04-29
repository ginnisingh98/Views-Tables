--------------------------------------------------------
--  DDL for Package Body CAC_SYNC_CONTACTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CAC_SYNC_CONTACTS_PVT" as
/* $Header: cacvsctb.pls 120.3.12000000.2 2007/06/29 05:49:24 vsood ship $ */

/* Modified cursor for bug 6147530 */
CURSOR c_new_contacts
/*
 Getthe new contacts information from TCA HZ tables that have been newly added to the
party preference table HZ_PARTY_PREFERENCES since last sync */

(b_principal_id NUMBER,
 b_person_party_id NUMBER,
 b_bookmark_module VARCHAR2,
 b_bookmark_category VARCHAR2,
 b_bookmark_preference VARCHAR2)

IS
SELECT CAC_SYNC_CONTACT_TEMPS_S.NEXTVAL SYNC_CONTACT_TEMP_ID,
       HPP.VALUE_NUMBER             REL_CONTACT_PARTY_ID
     , ORG.PARTY_ID                 ORG_PARTY_ID
     , ORG.PARTY_NAME               ORG_NAME
     , PERSON.PARTY_ID              PERSON_PARTY_ID
     , PERSON.PARTY_NAME            PERSON_FULL_NAME
     , PERSON.PERSON_LAST_NAME||';'||
       PERSON.PERSON_FIRST_NAME||';'||
       PERSON.PERSON_MIDDLE_NAME||';'||
       ARLK.MEANING||';'||
       PERSON.PERSON_NAME_SUFFIX    PERSON_NAME_DELIMITED
     , HOC.JOB_TITLE                JOB_TITLE
     , HOC.DEPARTMENT               DEPARTMENT
     , LOC.PO_BOX_NUMBER||';'||
       LOC.ADDRESS1||';'||
       LOC.ADDRESS2||';'||
       LOC.CITY||';'||
       LOC.STATE||';'||
       LOC.POSTAL_CODE||';'||
       LOC.COUNTRY                   ADDRESS_DELIMITED
     , CPT_WP.PHONE_NUMBER          WORK_PHONE_NUMBER
     , CPT_HP.PHONE_NUMBER          HOME_PHONE_NUMBER
     , CPT_WF.PHONE_NUMBER          WORK_FAX_NUMBER
     , CPT_CELL.PHONE_NUMBER        CELL_NUMBER
     , CPT_PAGER.PHONE_NUMBER       PAGER_NUMBER
     , CPT_EMAIL.EMAIL_FORMAT       EMAIL_FORMAT
     , CPT_EMAIL.EMAIL_ADDRESS      EMAIL_ADDRESS
     , SITE.PARTY_SITE_ID           PARTY_SITE_ID
     , CPT_WP.CONTACT_POINT_ID      WORK_PHONE_CONTACT_POINT_ID
     , CPT_HP.CONTACT_POINT_ID      HOME_PHONE_CONTACT_POINT_ID
     , CPT_WF.CONTACT_POINT_ID      WORK_FAX_CONTACT_POINT_ID
     , CPT_CELL.CONTACT_POINT_ID    CELL_PHONE_CONTACT_POINT_ID
     , CPT_PAGER.CONTACT_POINT_ID   PAGER_CONTACT_POINT_ID
     , CPT_EMAIL.CONTACT_POINT_ID   EMAIL_CONTACT_POINT_ID
     , 'N'                          STATUS
  FROM HZ_PARTY_PREFERENCES HPP
     , HZ_PARTIES REL_CONTACT
     , HZ_PARTIES ORG
     , HZ_PARTIES PERSON
     , AR_LOOKUPS ARLK
     , HZ_ORG_CONTACTS HOC
     , HZ_RELATIONSHIPS REL
     , HZ_PARTY_SITES SITE
     , HZ_LOCATIONS LOC
     , (SELECT CP.OWNER_TABLE_ID
             , CP.CONTACT_POINT_ID
             , 'WORK;VOICE' CONTACT_TYPE
             , CAC_SYNC_CONTACTS_PVT.FORMAT_PHONE(CP.PHONE_COUNTRY_CODE,
                                                  CP.PHONE_AREA_CODE,
                                                  CP.PHONE_NUMBER,
                                                  CP.PHONE_EXTENSION) PHONE_NUMBER
          FROM HZ_CONTACT_POINTS CP
             , HZ_PARTY_PREFERENCES PREF
         WHERE PREF.PARTY_ID            = b_person_party_id
           AND PREF.CATEGORY            = b_bookmark_category
           AND PREF.PREFERENCE_CODE     = b_bookmark_preference
           AND PREF.MODULE              = b_bookmark_module
	   AND CP.OWNER_TABLE_ID  =  PREF.VALUE_NUMBER
           AND CP.CONTACT_POINT_ID      = (SELECT MIN(CONTACT_POINT_ID)
                                             FROM HZ_CONTACT_POINTS C
                                            WHERE C.OWNER_TABLE_ID        = PREF.VALUE_NUMBER
                                              AND C.OWNER_TABLE_NAME      = 'HZ_PARTIES'
                                              AND C.CONTACT_POINT_TYPE    = 'PHONE'
                                              AND C.PHONE_LINE_TYPE       = 'GEN'
                                              AND NVL(C.CONTACT_POINT_PURPOSE,'BUSINESS') = 'BUSINESS'
                                              AND C.STATUS                = 'A')
       ) CPT_WP
     , (SELECT CP.OWNER_TABLE_ID
             , CP.CONTACT_POINT_ID
             , 'HOME;VOICE' CONTACT_TYPE
             , CAC_SYNC_CONTACTS_PVT.FORMAT_PHONE(CP.PHONE_COUNTRY_CODE,
                                                  CP.PHONE_AREA_CODE,
                                                  CP.PHONE_NUMBER,
                                                  CP.PHONE_EXTENSION) PHONE_NUMBER

          FROM HZ_CONTACT_POINTS CP
             , HZ_PARTY_PREFERENCES PREF
         WHERE PREF.PARTY_ID            = b_person_party_id
           AND PREF.CATEGORY            = b_bookmark_category
           AND PREF.PREFERENCE_CODE     = b_bookmark_preference
           AND PREF.MODULE              = b_bookmark_module
	   AND CP.OWNER_TABLE_ID  =  PREF.VALUE_NUMBER
           AND CP.CONTACT_POINT_ID      = (SELECT MIN(CONTACT_POINT_ID)
                                             FROM HZ_CONTACT_POINTS C
                                            WHERE C.OWNER_TABLE_ID        = PREF.VALUE_NUMBER
                                              AND C.OWNER_TABLE_NAME      = 'HZ_PARTIES'
                                              AND C.CONTACT_POINT_TYPE    = 'PHONE'
                                              AND C.PHONE_LINE_TYPE       = 'GEN'
                                              AND C.CONTACT_POINT_PURPOSE = 'PERSONAL'
                                              AND C.STATUS                = 'A')
       ) CPT_HP
     , (SELECT CP.OWNER_TABLE_ID
             , CP.CONTACT_POINT_ID
             , 'WORK;FAX' CONTACT_TYPE
             , CAC_SYNC_CONTACTS_PVT.FORMAT_PHONE(CP.PHONE_COUNTRY_CODE,
                                                  CP.PHONE_AREA_CODE,
                                                  CP.PHONE_NUMBER,
                                                  CP.PHONE_EXTENSION) PHONE_NUMBER

          FROM HZ_CONTACT_POINTS CP
             , HZ_PARTY_PREFERENCES PREF
         WHERE PREF.PARTY_ID            = b_person_party_id
           AND PREF.CATEGORY            = b_bookmark_category
           AND PREF.PREFERENCE_CODE     = b_bookmark_preference
           AND PREF.MODULE              = b_bookmark_module
	   AND CP.OWNER_TABLE_ID  =  PREF.VALUE_NUMBER
           AND CP.CONTACT_POINT_ID      = (SELECT MIN(CONTACT_POINT_ID)
                                             FROM HZ_CONTACT_POINTS C
                                            WHERE C.OWNER_TABLE_ID        = PREF.VALUE_NUMBER
                                              AND C.OWNER_TABLE_NAME      = 'HZ_PARTIES'
                                              AND C.CONTACT_POINT_TYPE    = 'PHONE'
                                              AND C.PHONE_LINE_TYPE       = 'FAX'
                                              AND NVL(C.CONTACT_POINT_PURPOSE,'BUSINESS') = 'BUSINESS'
                                              AND C.STATUS                = 'A')
       ) CPT_WF
     , (SELECT CP.OWNER_TABLE_ID
             , CP.CONTACT_POINT_ID
             , 'CELL;VOICE' CONTACT_TYPE
             , CAC_SYNC_CONTACTS_PVT.FORMAT_PHONE(CP.PHONE_COUNTRY_CODE,
                                                  CP.PHONE_AREA_CODE,
                                                  CP.PHONE_NUMBER,
                                                  CP.PHONE_EXTENSION) PHONE_NUMBER

          FROM HZ_CONTACT_POINTS CP
             , HZ_PARTY_PREFERENCES PREF
         WHERE PREF.PARTY_ID            = b_person_party_id
           AND PREF.CATEGORY            = b_bookmark_category
           AND PREF.PREFERENCE_CODE     = b_bookmark_preference
           AND PREF.MODULE              = b_bookmark_module
	   AND CP.OWNER_TABLE_ID  =  PREF.VALUE_NUMBER
           AND CP.CONTACT_POINT_ID      = (SELECT MIN(CONTACT_POINT_ID)
                                             FROM HZ_CONTACT_POINTS C
                                            WHERE C.OWNER_TABLE_ID        = PREF.VALUE_NUMBER
                                              AND C.OWNER_TABLE_NAME      = 'HZ_PARTIES'
                                              AND C.CONTACT_POINT_TYPE    = 'PHONE'
                                              AND C.PHONE_LINE_TYPE       = 'MOBILE'
                                              AND NVL(C.CONTACT_POINT_PURPOSE,'BUSINESS') = 'BUSINESS'
                                              AND C.STATUS                = 'A')
       ) CPT_CELL
     , (SELECT CP.OWNER_TABLE_ID
             , CP.CONTACT_POINT_ID
             , 'PAGER' CONTACT_TYPE
             , CAC_SYNC_CONTACTS_PVT.FORMAT_PHONE(CP.PHONE_COUNTRY_CODE,
                                                  CP.PHONE_AREA_CODE,
                                                  CP.PHONE_NUMBER,
                                                  CP.PHONE_EXTENSION) PHONE_NUMBER

          FROM HZ_CONTACT_POINTS CP
             , HZ_PARTY_PREFERENCES PREF
         WHERE PREF.PARTY_ID            = b_person_party_id
           AND PREF.CATEGORY            = b_bookmark_category
           AND PREF.PREFERENCE_CODE     = b_bookmark_preference
           AND PREF.MODULE              = b_bookmark_module
	   AND CP.OWNER_TABLE_ID  =  PREF.VALUE_NUMBER
           AND CP.CONTACT_POINT_ID      = (SELECT MIN(CONTACT_POINT_ID)
                                             FROM HZ_CONTACT_POINTS C
                                            WHERE C.OWNER_TABLE_ID        = PREF.VALUE_NUMBER
                                              AND C.OWNER_TABLE_NAME      = 'HZ_PARTIES'
                                              AND C.CONTACT_POINT_TYPE    = 'PHONE'
                                              AND C.PHONE_LINE_TYPE       = 'PAGER'
                                              AND NVL(C.CONTACT_POINT_PURPOSE,'BUSINESS') = 'BUSINESS'
                                              AND C.STATUS                = 'A')
       ) CPT_PAGER
     , (SELECT CP.OWNER_TABLE_ID
             , CP.CONTACT_POINT_ID
             , 'EMAIL' CONTACT_TYPE
             , CP.EMAIL_FORMAT
             , CP.EMAIL_ADDRESS
          FROM HZ_CONTACT_POINTS CP
             , HZ_PARTY_PREFERENCES PREF
         WHERE PREF.PARTY_ID            = b_person_party_id
           AND PREF.CATEGORY            = b_bookmark_category
           AND PREF.PREFERENCE_CODE     = b_bookmark_preference
           AND PREF.MODULE              = b_bookmark_module
	   AND CP.OWNER_TABLE_ID  =  PREF.VALUE_NUMBER
           AND CP.CONTACT_POINT_ID      = (SELECT MIN(CONTACT_POINT_ID)
                                             FROM HZ_CONTACT_POINTS C
                                            WHERE C.OWNER_TABLE_ID        = PREF.VALUE_NUMBER
                                              AND C.OWNER_TABLE_NAME      = 'HZ_PARTIES'
                                              AND C.CONTACT_POINT_TYPE    = 'EMAIL'
                                              AND C.STATUS                = 'A')
       ) CPT_EMAIL
 WHERE NOT EXISTS (SELECT NULL
                     FROM CAC_SYNC_MAPPINGS
                    WHERE GUID = HPP.VALUE_NUMBER
                      AND PRINCIPAL_ID = b_principal_id
                      AND SERVER_URI = SERVER_URI_CONST)
   AND HPP.CATEGORY = b_bookmark_category
   AND HPP.PREFERENCE_CODE = b_bookmark_preference
   AND HPP.PARTY_ID = b_person_party_id
   AND HPP.MODULE = b_bookmark_module
   AND REL_CONTACT.PARTY_ID = HPP.VALUE_NUMBER
   AND REL.PARTY_ID = REL_CONTACT.PARTY_ID
   AND REL.DIRECTIONAL_FLAG = 'F'
   AND PERSON.PARTY_ID = REL.SUBJECT_ID
   AND ARLK.LOOKUP_TYPE(+) = 'CONTACT_TITLE'
   AND ARLK.LOOKUP_CODE(+) = PERSON.PERSON_PRE_NAME_ADJUNCT
   AND ORG.PARTY_ID = REL.OBJECT_ID
   AND HOC.PARTY_RELATIONSHIP_ID = REL.RELATIONSHIP_ID
   AND SITE.PARTY_ID (+)= REL_CONTACT.PARTY_ID
   AND SITE.STATUS (+)= 'A'
   AND SITE.IDENTIFYING_ADDRESS_FLAG (+)= 'Y'
   AND LOC.LOCATION_ID(+) = SITE.LOCATION_ID
   AND CPT_WP.OWNER_TABLE_ID(+) = REL_CONTACT.PARTY_ID
   AND CPT_HP.OWNER_TABLE_ID(+) = REL_CONTACT.PARTY_ID
   AND CPT_WF.OWNER_TABLE_ID(+) = REL_CONTACT.PARTY_ID
   AND CPT_CELL.OWNER_TABLE_ID(+) = REL_CONTACT.PARTY_ID
   AND CPT_PAGER.OWNER_TABLE_ID(+) = REL_CONTACT.PARTY_ID
   AND CPT_EMAIL.OWNER_TABLE_ID(+) = REL_CONTACT.PARTY_ID;

/* Modified cursor for bug 6147530 */
CURSOR c_updated_contacts
   /* Getthe updated contacts information from TCA HZ tables that have been updated
     since last sync */
  (b_principal_id NUMBER,
   b_person_party_id NUMBER,
   b_sync_anchor DATE,
   b_bookmark_module VARCHAR2,
   b_bookmark_category VARCHAR2,
   b_bookmark_preference VARCHAR2)
IS
SELECT     CAC_SYNC_CONTACT_TEMPS_S.NEXTVAL SYNC_CONTACT_TEMP_ID
         , REL_CONTACT_PARTY_ID
         , ORG_PARTY_ID
         , ORG_NAME
         , PERSON_PARTY_ID
         , PERSON_FULL_NAME
         , PERSON_NAME_DELIMITED
         , JOB_TITLE
         , DEPARTMENT
         , ADDRESS_DELIMITED
         , WORK_PHONE_NUMBER
         , HOME_PHONE_NUMBER
         , WORK_FAX_NUMBER
         , CELL_NUMBER
         , PAGER_NUMBER
         , EMAIL_FORMAT
         , EMAIL_ADDRESS
         , PARTY_SITE_ID
         , WORK_PHONE_CONTACT_POINT_ID
         , HOME_PHONE_CONTACT_POINT_ID
         , WORK_FAX_CONTACT_POINT_ID
         , CELL_PHONE_CONTACT_POINT_ID
         , PAGER_CONTACT_POINT_ID
         , EMAIL_CONTACT_POINT_ID
         , STATUS
  FROM (
    SELECT HPP.VALUE_NUMBER             REL_CONTACT_PARTY_ID
         , ORG.PARTY_ID                 ORG_PARTY_ID
         , ORG.PARTY_NAME               ORG_NAME
         , PERSON.PARTY_ID              PERSON_PARTY_ID
         , PERSON.PARTY_NAME            PERSON_FULL_NAME
         , PERSON.PERSON_LAST_NAME||';'||
           PERSON.PERSON_FIRST_NAME||';'||
           PERSON.PERSON_MIDDLE_NAME||';'||
           ARLK.MEANING||';'||
           PERSON.PERSON_NAME_SUFFIX    PERSON_NAME_DELIMITED
         , HOC.JOB_TITLE                JOB_TITLE
         , HOC.DEPARTMENT               DEPARTMENT
         , LOC.PO_BOX_NUMBER||';'||
           LOC.ADDRESS1||';'||
           LOC.ADDRESS2||';'||
           LOC.CITY||';'||
           LOC.STATE||';'||
           LOC.POSTAL_CODE||';'||
           LOC.COUNTRY                   ADDRESS_DELIMITED
         , CPT_WP.PHONE_NUMBER          WORK_PHONE_NUMBER
         , CPT_HP.PHONE_NUMBER          HOME_PHONE_NUMBER
         , CPT_WF.PHONE_NUMBER          WORK_FAX_NUMBER
         , CPT_CELL.PHONE_NUMBER        CELL_NUMBER
         , CPT_PAGER.PHONE_NUMBER       PAGER_NUMBER
         , CPT_EMAIL.EMAIL_FORMAT       EMAIL_FORMAT
         , CPT_EMAIL.EMAIL_ADDRESS      EMAIL_ADDRESS
         , SITE.PARTY_SITE_ID           PARTY_SITE_ID
         , CPT_WP.CONTACT_POINT_ID      WORK_PHONE_CONTACT_POINT_ID
         , CPT_HP.CONTACT_POINT_ID      HOME_PHONE_CONTACT_POINT_ID
         , CPT_WF.CONTACT_POINT_ID      WORK_FAX_CONTACT_POINT_ID
         , CPT_CELL.CONTACT_POINT_ID    CELL_PHONE_CONTACT_POINT_ID
         , CPT_PAGER.CONTACT_POINT_ID   PAGER_CONTACT_POINT_ID
         , CPT_EMAIL.CONTACT_POINT_ID   EMAIL_CONTACT_POINT_ID
         , 'U'                          STATUS
         , DECODE(SIGN(REL_CONTACT.LAST_UPDATE_DATE - b_sync_anchor),
                  1, 1,
                  0, 1,
                  0)
         + DECODE(SIGN(PERSON.LAST_UPDATE_DATE - b_sync_anchor),
                  1, 1,
                  0, 1,
                  0)
         + DECODE(SIGN(HOC.LAST_UPDATE_DATE - b_sync_anchor),
                  1, 1,
                  0, 1,
                  0)
         + DECODE(CSPM.PARTY_SITE_ID,
                  NULL, DECODE(SITE.PARTY_SITE_ID, NULL, 0, 1),
                  DECODE(SITE.PARTY_SITE_ID,
                         NULL, 1,
                         DECODE(CSPM.PARTY_SITE_ID,
                                SITE.PARTY_SITE_ID,
                                DECODE(SIGN(SITE.LAST_UPDATE_DATE - b_sync_anchor),
                                       1, 1,
                                       0, 1,
                                       0),
                                1)
                        )
                 )
         + DECODE(SIGN(LOC.LAST_UPDATE_DATE - b_sync_anchor),
                  1, 1,
                  0, 1,
                  0)
         + DECODE(CPT_WP.CONTACT_POINT_ID,
                  NULL, DECODE(CSPM.WORK_CONTACT_POINT_ID, NULL, 0, 1),
                  DECODE(CSPM.WORK_CONTACT_POINT_ID,
                         NULL, 1,
                         DECODE(CPT_WP.CONTACT_POINT_ID, CSPM.WORK_CONTACT_POINT_ID,
                                DECODE(SIGN(CPT_WP.LAST_UPDATE_DATE - b_sync_anchor),
                                       1, 1,
                                       0, 1,
                                       0),
                                1)))
         + DECODE(CPT_HP.CONTACT_POINT_ID,
                  NULL, DECODE(CSPM.HOME_CONTACT_POINT_ID, NULL, 0, 1),
                  DECODE(CSPM.HOME_CONTACT_POINT_ID,
                         NULL, 1,
                         DECODE(CPT_HP.CONTACT_POINT_ID, CSPM.HOME_CONTACT_POINT_ID,
                                DECODE(SIGN(CPT_HP.LAST_UPDATE_DATE - b_sync_anchor),
                                       1, 1,
                                       0, 1,
                                       0),
                                1)))
         + DECODE(CPT_WF.CONTACT_POINT_ID,
                  NULL, DECODE(CSPM.FAX_CONTACT_POINT_ID, NULL, 0, 1),
                  DECODE(CSPM.FAX_CONTACT_POINT_ID,
                         NULL, 1,
                         DECODE(CPT_WF.CONTACT_POINT_ID, CSPM.FAX_CONTACT_POINT_ID,
                                DECODE(SIGN(CPT_WF.LAST_UPDATE_DATE - b_sync_anchor),
                                       1, 1,
                                       0, 1,
                                       0),
                                1)))
         + DECODE(CPT_CELL.CONTACT_POINT_ID,
                  NULL, DECODE(CSPM.CELL_CONTACT_POINT_ID, NULL, 0, 1),
                  DECODE(CSPM.CELL_CONTACT_POINT_ID,
                         NULL, 1,
                         DECODE(CPT_CELL.CONTACT_POINT_ID, CSPM.CELL_CONTACT_POINT_ID,
                                DECODE(SIGN(CPT_CELL.LAST_UPDATE_DATE - b_sync_anchor),
                                       1, 1,
                                       0, 1,
                                       0),
                                1)))
         + DECODE(CPT_PAGER.CONTACT_POINT_ID,
                  NULL, DECODE(CSPM.PAGER_CONTACT_POINT_ID, NULL, 0, 1),
                  DECODE(CSPM.PAGER_CONTACT_POINT_ID,
                         NULL, 1,
                         DECODE(CPT_PAGER.CONTACT_POINT_ID, CSPM.PAGER_CONTACT_POINT_ID,
                                DECODE(SIGN(CPT_PAGER.LAST_UPDATE_DATE - b_sync_anchor),
                                       1, 1,
                                       0, 1,
                                       0),
                                1)))
         + DECODE(CPT_EMAIL.CONTACT_POINT_ID,
                  NULL, DECODE(CSPM.EMAIL_CONTACT_POINT_ID, NULL, 0, 1),
                  DECODE(CSPM.EMAIL_CONTACT_POINT_ID,
                         NULL, 1,
                         DECODE(CPT_EMAIL.CONTACT_POINT_ID, CSPM.EMAIL_CONTACT_POINT_ID,
                                DECODE(SIGN(CPT_EMAIL.LAST_UPDATE_DATE - b_sync_anchor),
                                       1, 1,
                                       0, 1,
                                       0),
                                1)))   UPDATED_FLAG
      FROM HZ_PARTIES REL_CONTACT
         , HZ_PARTIES ORG
         , HZ_PARTIES PERSON
         , AR_LOOKUPS ARLK
         , HZ_ORG_CONTACTS HOC
         , HZ_RELATIONSHIPS REL
         , HZ_PARTY_SITES SITE
         , HZ_LOCATIONS LOC
         , HZ_PARTY_PREFERENCES HPP
         , CAC_SYNC_CONTACT_MAPPINGS CSPM
         , (SELECT CP.OWNER_TABLE_ID
                 , CP.CONTACT_POINT_ID
                 , 'WORK;VOICE' CONTACT_TYPE
                 , CAC_SYNC_CONTACTS_PVT.FORMAT_PHONE(CP.PHONE_COUNTRY_CODE,
                                                      CP.PHONE_AREA_CODE,
                                                      CP.PHONE_NUMBER,
                                                      CP.PHONE_EXTENSION) PHONE_NUMBER
                 , CP.LAST_UPDATE_DATE
              FROM HZ_CONTACT_POINTS CP
                 , HZ_PARTY_PREFERENCES PREF
             WHERE PREF.PARTY_ID            = b_person_party_id
               AND PREF.CATEGORY            = b_bookmark_category
               AND PREF.PREFERENCE_CODE     = b_bookmark_preference
               AND PREF.MODULE              = b_bookmark_module
	       AND CP.OWNER_TABLE_ID  =  PREF.VALUE_NUMBER
               AND CP.CONTACT_POINT_ID      = (SELECT MIN(CONTACT_POINT_ID)
                                                 FROM HZ_CONTACT_POINTS C
                                                WHERE C.OWNER_TABLE_ID        = PREF.VALUE_NUMBER
                                                  AND C.OWNER_TABLE_NAME      = 'HZ_PARTIES'
                                                  AND C.CONTACT_POINT_TYPE    = 'PHONE'
                                                  AND C.PHONE_LINE_TYPE       = 'GEN'
                                                  AND NVL(C.CONTACT_POINT_PURPOSE,'BUSINESS') = 'BUSINESS'
                                                  AND C.STATUS                = 'A')
           ) CPT_WP
         , (SELECT CP.OWNER_TABLE_ID
                 , CP.CONTACT_POINT_ID
                 , 'HOME;VOICE' CONTACT_TYPE
                 , CAC_SYNC_CONTACTS_PVT.FORMAT_PHONE(CP.PHONE_COUNTRY_CODE,
                                                      CP.PHONE_AREA_CODE,
                                                      CP.PHONE_NUMBER,
                                                      CP.PHONE_EXTENSION) PHONE_NUMBER

                 , CP.LAST_UPDATE_DATE
              FROM HZ_CONTACT_POINTS CP
                 , HZ_PARTY_PREFERENCES PREF
             WHERE PREF.PARTY_ID            = b_person_party_id
               AND PREF.CATEGORY            = b_bookmark_category
               AND PREF.PREFERENCE_CODE     = b_bookmark_preference
               AND PREF.MODULE              = b_bookmark_module
	       AND CP.OWNER_TABLE_ID  =  PREF.VALUE_NUMBER
               AND CP.CONTACT_POINT_ID      = (SELECT MIN(CONTACT_POINT_ID)
                                                 FROM HZ_CONTACT_POINTS C
                                                WHERE C.OWNER_TABLE_ID        = PREF.VALUE_NUMBER
                                                  AND C.OWNER_TABLE_NAME      = 'HZ_PARTIES'
                                                  AND C.CONTACT_POINT_TYPE    = 'PHONE'
                                                  AND C.PHONE_LINE_TYPE       = 'GEN'
                                                  AND C.CONTACT_POINT_PURPOSE = 'PERSONAL'
                                                  AND C.STATUS                = 'A')
           ) CPT_HP
         , (SELECT CP.OWNER_TABLE_ID
                 , CP.CONTACT_POINT_ID
                 , 'WORK;FAX' CONTACT_TYPE
                 , CAC_SYNC_CONTACTS_PVT.FORMAT_PHONE(CP.PHONE_COUNTRY_CODE,
                                                  CP.PHONE_AREA_CODE,
                                                  CP.PHONE_NUMBER,
                                                  CP.PHONE_EXTENSION) PHONE_NUMBER

                 , CP.LAST_UPDATE_DATE
              FROM HZ_CONTACT_POINTS CP
                 , HZ_PARTY_PREFERENCES PREF
             WHERE PREF.PARTY_ID            = b_person_party_id
               AND PREF.CATEGORY            = b_bookmark_category
               AND PREF.PREFERENCE_CODE     = b_bookmark_preference
               AND PREF.MODULE              = b_bookmark_module
	       AND CP.OWNER_TABLE_ID  =  PREF.VALUE_NUMBER
               AND CP.CONTACT_POINT_ID      = (SELECT MIN(CONTACT_POINT_ID)
                                                 FROM HZ_CONTACT_POINTS C
                                                WHERE C.OWNER_TABLE_ID        = PREF.VALUE_NUMBER
                                                  AND C.OWNER_TABLE_NAME      = 'HZ_PARTIES'
                                                  AND C.CONTACT_POINT_TYPE    = 'PHONE'
                                                  AND C.PHONE_LINE_TYPE       = 'FAX'
                                                  AND NVL(C.CONTACT_POINT_PURPOSE,'BUSINESS') = 'BUSINESS'
                                                  AND C.STATUS                = 'A')
           ) CPT_WF
         , (SELECT CP.OWNER_TABLE_ID
                 , CP.CONTACT_POINT_ID
                 , 'CELL;VOICE' CONTACT_TYPE
                 , CAC_SYNC_CONTACTS_PVT.FORMAT_PHONE(CP.PHONE_COUNTRY_CODE,
                                                  CP.PHONE_AREA_CODE,
                                                  CP.PHONE_NUMBER,
                                                  CP.PHONE_EXTENSION) PHONE_NUMBER

                 , CP.LAST_UPDATE_DATE
              FROM HZ_CONTACT_POINTS CP
                 , HZ_PARTY_PREFERENCES PREF
             WHERE PREF.PARTY_ID            = b_person_party_id
               AND PREF.CATEGORY            = b_bookmark_category
               AND PREF.PREFERENCE_CODE     = b_bookmark_preference
               AND PREF.MODULE              = b_bookmark_module
	       AND CP.OWNER_TABLE_ID  =  PREF.VALUE_NUMBER
               AND CP.CONTACT_POINT_ID      = (SELECT MIN(CONTACT_POINT_ID)
                                                 FROM HZ_CONTACT_POINTS C
                                                WHERE C.OWNER_TABLE_ID        = PREF.VALUE_NUMBER
                                                  AND C.OWNER_TABLE_NAME      = 'HZ_PARTIES'
                                                  AND C.CONTACT_POINT_TYPE    = 'PHONE'
                                                  AND C.PHONE_LINE_TYPE       = 'MOBILE'
                                                  AND NVL(C.CONTACT_POINT_PURPOSE,'BUSINESS') = 'BUSINESS'
                                                  AND C.STATUS                = 'A')
           ) CPT_CELL
         , (SELECT CP.OWNER_TABLE_ID
                 , CP.CONTACT_POINT_ID
                 , 'PAGER' CONTACT_TYPE
                 , CAC_SYNC_CONTACTS_PVT.FORMAT_PHONE(CP.PHONE_COUNTRY_CODE,
                                                  CP.PHONE_AREA_CODE,
                                                  CP.PHONE_NUMBER,
                                                  CP.PHONE_EXTENSION) PHONE_NUMBER

                 , CP.LAST_UPDATE_DATE
              FROM HZ_CONTACT_POINTS CP
                 , HZ_PARTY_PREFERENCES PREF
             WHERE PREF.PARTY_ID            = b_person_party_id
               AND PREF.CATEGORY            = b_bookmark_category
               AND PREF.PREFERENCE_CODE     = b_bookmark_preference
               AND PREF.MODULE              = b_bookmark_module
	       AND CP.OWNER_TABLE_ID  =  PREF.VALUE_NUMBER
               AND CP.CONTACT_POINT_ID      = (SELECT MIN(CONTACT_POINT_ID)
                                                 FROM HZ_CONTACT_POINTS C
                                                WHERE C.OWNER_TABLE_ID        = PREF.VALUE_NUMBER
                                                  AND C.OWNER_TABLE_NAME      = 'HZ_PARTIES'
                                                  AND C.CONTACT_POINT_TYPE    = 'PHONE'
                                                  AND C.PHONE_LINE_TYPE       = 'PAGER'
                                                  AND NVL(C.CONTACT_POINT_PURPOSE,'BUSINESS') = 'BUSINESS'
                                                  AND C.STATUS                = 'A')
           ) CPT_PAGER
         , (SELECT CP.OWNER_TABLE_ID
                 , CP.CONTACT_POINT_ID
                 , 'EMAIL' CONTACT_TYPE
                 , CP.EMAIL_FORMAT
                 , CP.EMAIL_ADDRESS
                 , CP.LAST_UPDATE_DATE
              FROM HZ_CONTACT_POINTS CP
                 , HZ_PARTY_PREFERENCES PREF
             WHERE PREF.PARTY_ID            = b_person_party_id
               AND PREF.CATEGORY            = b_bookmark_category
               AND PREF.PREFERENCE_CODE     = b_bookmark_preference
               AND PREF.MODULE              = b_bookmark_module
	       AND CP.OWNER_TABLE_ID  =  PREF.VALUE_NUMBER
               AND CP.CONTACT_POINT_ID      = (SELECT MIN(CONTACT_POINT_ID)
                                                 FROM HZ_CONTACT_POINTS C
                                                WHERE C.OWNER_TABLE_ID        = PREF.VALUE_NUMBER
                                                  AND C.OWNER_TABLE_NAME      = 'HZ_PARTIES'
                                                  AND C.CONTACT_POINT_TYPE    = 'EMAIL'
                                                  AND C.STATUS                = 'A')
           ) CPT_EMAIL
     WHERE HPP.PARTY_ID = b_person_party_id
       AND HPP.CATEGORY = b_bookmark_category
       AND HPP.PREFERENCE_CODE = b_bookmark_preference
       AND HPP.MODULE = b_bookmark_module
       AND EXISTS (SELECT NULL
                     FROM CAC_SYNC_MAPPINGS
                    WHERE GUID = HPP.VALUE_NUMBER
                      AND PRINCIPAL_ID = b_principal_id
                      AND SERVER_URI = SERVER_URI_CONST)
       AND REL_CONTACT.PARTY_ID = HPP.VALUE_NUMBER
       AND ORG.PARTY_TYPE = 'ORGANIZATION'
       AND PERSON.PARTY_TYPE = 'PERSON'
       AND ARLK.LOOKUP_TYPE(+) = 'CONTACT_TITLE'
       AND ARLK.LOOKUP_CODE(+) = PERSON.PERSON_PRE_NAME_ADJUNCT
       AND REL.PARTY_ID = REL_CONTACT.PARTY_ID
       AND REL.DIRECTIONAL_FLAG = 'F'
       AND PERSON.PARTY_ID = REL.SUBJECT_ID
       AND ORG.PARTY_ID = REL.OBJECT_ID
       AND HOC.PARTY_RELATIONSHIP_ID = REL.RELATIONSHIP_ID
       AND SITE.PARTY_ID (+)= REL_CONTACT.PARTY_ID
       AND SITE.STATUS (+)= 'A'
       AND SITE.IDENTIFYING_ADDRESS_FLAG (+)= 'Y'
       AND LOC.LOCATION_ID(+) = SITE.LOCATION_ID
       AND CPT_WP.OWNER_TABLE_ID(+) = REL_CONTACT.PARTY_ID
       AND CPT_HP.OWNER_TABLE_ID(+) = REL_CONTACT.PARTY_ID
       AND CPT_WF.OWNER_TABLE_ID(+) = REL_CONTACT.PARTY_ID
       AND CPT_CELL.OWNER_TABLE_ID(+) = REL_CONTACT.PARTY_ID
       AND CPT_PAGER.OWNER_TABLE_ID(+) = REL_CONTACT.PARTY_ID
       AND CPT_EMAIL.OWNER_TABLE_ID(+) = REL_CONTACT.PARTY_ID
       AND CSPM.CONTACT_PARTY_ID(+) = REL_CONTACT.PARTY_ID
    )
WHERE UPDATED_FLAG > 0;

CURSOR c_deleted_contacts
/* Getthe deleted contacts information from TCA HZ tables that have been deleted
   since last sync */
   (b_principal_id NUMBER,
    b_person_party_id NUMBER,
    b_bookmark_module VARCHAR2,
    b_bookmark_category   VARCHAR2,
    b_bookmark_preference  VARCHAR2)

IS
    SELECT
    CAC_SYNC_CONTACT_TEMPS_S.NEXTVAL  SYNC_CONTACT_TEMP_ID,
    CSUM.GUID REL_CONTACT_PARTY_ID,
    -1        ORG_PARTY_ID,
    NULL      ORG_NAME,
    -1        PERSON_PARTY_ID,
    NULL      PERSON_FULL_NAME,
    NULL      PERSON_NAME_DELIMITED,
    NULL      JOB_TITLE,
    NULL      DEPARTMENT,
    NULL      ADDRESS_DELIMITED,
    NULL      WORK_PHONE_NUMBER,
    NULL      HOME_PHONE_NUMBER,
    NULL      WORK_FAX_NUMBER,
    NULL      CELL_NUMBER,
    NULL      PAGER_NUMBER,
    NULL      EMAIL_FORMAT,
    NULL      EMAIL_ADDRESS,
    NULL      PARTY_SITE_ID,
    NULL      WORK_PHONE_CONTACT_POINT_ID,
    NULL      HOME_PHONE_CONTACT_POINT_ID,
    NULL      WORK_FAX_CONTACT_POINT_ID,
    NULL      CELL_PHONE_CONTACT_POINT_ID,
    NULL      PAGER_CONTACT_POINT_ID,
    NULL      EMAIL_CONTACT_POINT_ID,
    'D'       STATUS
    FROM CAC_SYNC_MAPPINGS CSUM
    WHERE NOT EXISTS (SELECT NULL
                        FROM HZ_PARTY_PREFERENCES
                       WHERE VALUE_NUMBER = CSUM.GUID
                         AND CATEGORY = b_bookmark_category
                         AND PREFERENCE_CODE = b_bookmark_preference
                         AND MODULE = b_bookmark_module
                         AND PARTY_ID = b_person_party_id)
    AND CSUM.PRINCIPAL_ID = b_principal_id
    AND CSUM.SERVER_URI = SERVER_URI_CONST;

/* Modified cursor for bug 6147530 */
CURSOR c_all_contacts
/* Getthe ALL contacts information from TCA HZ tables */
   (b_person_party_id NUMBER,
    b_bookmark_module VARCHAR2,
    b_bookmark_category VARCHAR2,
    b_bookmark_preference VARCHAR2
    )

IS SELECT CAC_SYNC_CONTACT_TEMPS_S.NEXTVAL SYNC_CONTACT_TEMP_ID
     , HPP.VALUE_NUMBER             REL_CONTACT_PARTY_ID
     , ORG.PARTY_ID                 ORG_PARTY_ID
     , ORG.PARTY_NAME               ORG_NAME
     , PERSON.PARTY_ID              PERSON_PARTY_ID
     , PERSON.PARTY_NAME            PERSON_FULL_NAME
     , PERSON.PERSON_LAST_NAME||';'||
       PERSON.PERSON_FIRST_NAME||';'||
       PERSON.PERSON_MIDDLE_NAME||';'||
       ARLK.MEANING||';'||
       PERSON.PERSON_NAME_SUFFIX    PERSON_NAME_DELIMITED
     , HOC.JOB_TITLE                JOB_TITLE
     , HOC.DEPARTMENT               DEPARTMENT
     , LOC.PO_BOX_NUMBER||';'||
       LOC.ADDRESS1||';'||
       LOC.ADDRESS2||';'||
       LOC.CITY||';'||
       LOC.STATE||';'||
       LOC.POSTAL_CODE||';'||
       LOC.COUNTRY                   ADDRESS_DELIMITED
     , CPT_WP.PHONE_NUMBER          WORK_PHONE_NUMBER
     , CPT_HP.PHONE_NUMBER          HOME_PHONE_NUMBER
     , CPT_WF.PHONE_NUMBER          WORK_FAX_NUMBER
     , CPT_CELL.PHONE_NUMBER        CELL_NUMBER
     , CPT_PAGER.PHONE_NUMBER       PAGER_NUMBER
     , CPT_EMAIL.EMAIL_FORMAT       EMAIL_FORMAT
     , CPT_EMAIL.EMAIL_ADDRESS      EMAIL_ADDRESS
     , SITE.PARTY_SITE_ID           PARTY_SITE_ID
     , CPT_WP.CONTACT_POINT_ID      WORK_PHONE_CONTACT_POINT_ID
     , CPT_HP.CONTACT_POINT_ID      HOME_PHONE_CONTACT_POINT_ID
     , CPT_WF.CONTACT_POINT_ID      WORK_FAX_CONTACT_POINT_ID
     , CPT_CELL.CONTACT_POINT_ID    CELL_PHONE_CONTACT_POINT_ID
     , CPT_PAGER.CONTACT_POINT_ID   PAGER_CONTACT_POINT_ID
     , CPT_EMAIL.CONTACT_POINT_ID   EMAIL_CONTACT_POINT_ID
     , 'N'                        STATUS
  FROM HZ_PARTIES REL_CONTACT
     , HZ_PARTIES ORG
     , HZ_PARTIES PERSON
     , AR_LOOKUPS ARLK
     , HZ_ORG_CONTACTS HOC
     , HZ_RELATIONSHIPS REL
     , HZ_PARTY_SITES SITE
     , HZ_LOCATIONS LOC
     , HZ_PARTY_PREFERENCES HPP
     , CAC_SYNC_CONTACT_MAPPINGS CSPM
     , (SELECT CP.OWNER_TABLE_ID
             , CP.CONTACT_POINT_ID
             , 'WORK;VOICE' CONTACT_TYPE
             , CAC_SYNC_CONTACTS_PVT.FORMAT_PHONE(CP.PHONE_COUNTRY_CODE,
                                                  CP.PHONE_AREA_CODE,
                                                  CP.PHONE_NUMBER,
                                                  CP.PHONE_EXTENSION) PHONE_NUMBER

          FROM HZ_CONTACT_POINTS CP
             , HZ_PARTY_PREFERENCES PREF
         WHERE PREF.PARTY_ID            = b_person_party_id
           AND PREF.CATEGORY            = b_bookmark_category
           AND PREF.PREFERENCE_CODE     = b_bookmark_preference
           AND PREF.MODULE              = b_bookmark_module
	   AND CP.OWNER_TABLE_ID  =  PREF.VALUE_NUMBER
           AND CP.CONTACT_POINT_ID      = (SELECT MIN(CONTACT_POINT_ID)
                                             FROM HZ_CONTACT_POINTS C
                                            WHERE C.OWNER_TABLE_ID        = PREF.VALUE_NUMBER
                                              AND C.OWNER_TABLE_NAME      = 'HZ_PARTIES'
                                              AND C.CONTACT_POINT_TYPE    = 'PHONE'
                                              AND C.PHONE_LINE_TYPE       = 'GEN'
                                              AND NVL(C.CONTACT_POINT_PURPOSE,'BUSINESS') = 'BUSINESS'
                                              AND C.STATUS                = 'A')
       ) CPT_WP
     , (SELECT CP.OWNER_TABLE_ID
             , CP.CONTACT_POINT_ID
             , 'HOME;VOICE' CONTACT_TYPE
             , CAC_SYNC_CONTACTS_PVT.FORMAT_PHONE(CP.PHONE_COUNTRY_CODE,
                                                  CP.PHONE_AREA_CODE,
                                                  CP.PHONE_NUMBER,
                                                  CP.PHONE_EXTENSION) PHONE_NUMBER

          FROM HZ_CONTACT_POINTS CP
             , HZ_PARTY_PREFERENCES PREF
         WHERE PREF.PARTY_ID            = b_person_party_id
           AND PREF.CATEGORY            = b_bookmark_category
           AND PREF.PREFERENCE_CODE     = b_bookmark_preference
           AND PREF.MODULE              = b_bookmark_module
	   AND CP.OWNER_TABLE_ID  =  PREF.VALUE_NUMBER
           AND CP.CONTACT_POINT_ID      = (SELECT MIN(CONTACT_POINT_ID)
                                             FROM HZ_CONTACT_POINTS C
                                            WHERE C.OWNER_TABLE_ID        = PREF.VALUE_NUMBER
                                              AND C.OWNER_TABLE_NAME      = 'HZ_PARTIES'
                                              AND C.CONTACT_POINT_TYPE    = 'PHONE'
                                              AND C.PHONE_LINE_TYPE       = 'GEN'
                                              AND C.CONTACT_POINT_PURPOSE = 'PERSONAL'
                                              AND C.STATUS                = 'A')
       ) CPT_HP
     , (SELECT CP.OWNER_TABLE_ID
             , CP.CONTACT_POINT_ID
             , 'WORK;FAX' CONTACT_TYPE
             , CAC_SYNC_CONTACTS_PVT.FORMAT_PHONE(CP.PHONE_COUNTRY_CODE,
                                                  CP.PHONE_AREA_CODE,
                                                  CP.PHONE_NUMBER,
                                                  CP.PHONE_EXTENSION) PHONE_NUMBER

          FROM HZ_CONTACT_POINTS CP
             , HZ_PARTY_PREFERENCES PREF
         WHERE PREF.PARTY_ID            = b_person_party_id
           AND PREF.CATEGORY            = b_bookmark_category
           AND PREF.PREFERENCE_CODE     = b_bookmark_preference
           AND PREF.MODULE              = b_bookmark_module
	   AND CP.OWNER_TABLE_ID  =  PREF.VALUE_NUMBER
           AND CP.CONTACT_POINT_ID      = (SELECT MIN(CONTACT_POINT_ID)
                                             FROM HZ_CONTACT_POINTS C
                                            WHERE C.OWNER_TABLE_ID        = PREF.VALUE_NUMBER
                                              AND C.OWNER_TABLE_NAME      = 'HZ_PARTIES'
                                              AND C.CONTACT_POINT_TYPE    = 'PHONE'
                                              AND C.PHONE_LINE_TYPE       = 'FAX'
                                              AND NVL(C.CONTACT_POINT_PURPOSE,'BUSINESS') = 'BUSINESS'
                                              AND C.STATUS                = 'A')
       ) CPT_WF
     , (SELECT CP.OWNER_TABLE_ID
             , CP.CONTACT_POINT_ID
             , 'CELL;VOICE' CONTACT_TYPE
             , CAC_SYNC_CONTACTS_PVT.FORMAT_PHONE(CP.PHONE_COUNTRY_CODE,
                                                  CP.PHONE_AREA_CODE,
                                                  CP.PHONE_NUMBER,
                                                  CP.PHONE_EXTENSION) PHONE_NUMBER

          FROM HZ_CONTACT_POINTS CP
             , HZ_PARTY_PREFERENCES PREF
         WHERE PREF.PARTY_ID            = b_person_party_id
           AND PREF.CATEGORY            = b_bookmark_category
           AND PREF.PREFERENCE_CODE     = b_bookmark_preference
           AND PREF.MODULE              = b_bookmark_module
	   AND CP.OWNER_TABLE_ID  =  PREF.VALUE_NUMBER
           AND CP.CONTACT_POINT_ID      = (SELECT MIN(CONTACT_POINT_ID)
                                             FROM HZ_CONTACT_POINTS C
                                            WHERE C.OWNER_TABLE_ID        = PREF.VALUE_NUMBER
                                              AND C.OWNER_TABLE_NAME      = 'HZ_PARTIES'
                                              AND C.CONTACT_POINT_TYPE    = 'PHONE'
                                              AND C.PHONE_LINE_TYPE       = 'MOBILE'
                                              AND NVL(C.CONTACT_POINT_PURPOSE,'BUSINESS') = 'BUSINESS'
                                              AND C.STATUS                = 'A')
       ) CPT_CELL
     , (SELECT CP.OWNER_TABLE_ID
             , CP.CONTACT_POINT_ID
             , 'PAGER' CONTACT_TYPE
             , CAC_SYNC_CONTACTS_PVT.FORMAT_PHONE(CP.PHONE_COUNTRY_CODE,
                                                  CP.PHONE_AREA_CODE,
                                                  CP.PHONE_NUMBER,
                                                  CP.PHONE_EXTENSION) PHONE_NUMBER

          FROM HZ_CONTACT_POINTS CP
             , HZ_PARTY_PREFERENCES PREF
         WHERE PREF.PARTY_ID            = b_person_party_id
           AND PREF.CATEGORY            = b_bookmark_category
           AND PREF.PREFERENCE_CODE     = b_bookmark_preference
           AND PREF.MODULE              = b_bookmark_module
	   AND CP.OWNER_TABLE_ID  =  PREF.VALUE_NUMBER
           AND CP.CONTACT_POINT_ID      = (SELECT MIN(CONTACT_POINT_ID)
                                             FROM HZ_CONTACT_POINTS C
                                            WHERE C.OWNER_TABLE_ID        = PREF.VALUE_NUMBER
                                              AND C.OWNER_TABLE_NAME      = 'HZ_PARTIES'
                                              AND C.CONTACT_POINT_TYPE    = 'PHONE'
                                              AND C.PHONE_LINE_TYPE       = 'PAGER'
                                              AND NVL(C.CONTACT_POINT_PURPOSE,'BUSINESS') = 'BUSINESS'
                                              AND C.STATUS                = 'A')
       ) CPT_PAGER
     , (SELECT CP.OWNER_TABLE_ID
             , CP.CONTACT_POINT_ID
             , 'EMAIL' CONTACT_TYPE
             , CP.EMAIL_FORMAT
             , CP.EMAIL_ADDRESS
          FROM HZ_CONTACT_POINTS CP
             , HZ_PARTY_PREFERENCES PREF
         WHERE PREF.PARTY_ID            = b_person_party_id
           AND PREF.CATEGORY            = b_bookmark_category
           AND PREF.PREFERENCE_CODE     = b_bookmark_preference
           AND PREF.MODULE              = b_bookmark_module
	   AND CP.OWNER_TABLE_ID  =  PREF.VALUE_NUMBER
           AND CP.CONTACT_POINT_ID      = (SELECT MIN(CONTACT_POINT_ID)
                                             FROM HZ_CONTACT_POINTS C
                                            WHERE C.OWNER_TABLE_ID        = PREF.VALUE_NUMBER
                                              AND C.OWNER_TABLE_NAME      = 'HZ_PARTIES'
                                              AND C.CONTACT_POINT_TYPE    = 'EMAIL'
                                              AND C.STATUS                = 'A')
       ) CPT_EMAIL
 WHERE HPP.PARTY_ID = b_person_party_id
   AND HPP.CATEGORY = b_bookmark_category
   AND HPP.PREFERENCE_CODE = b_bookmark_preference
   AND HPP.MODULE = b_bookmark_module
   AND REL_CONTACT.PARTY_ID = HPP.VALUE_NUMBER
   AND ORG.PARTY_TYPE = 'ORGANIZATION'
   AND PERSON.PARTY_TYPE = 'PERSON'
   AND ARLK.LOOKUP_TYPE(+) = 'CONTACT_TITLE'
   AND ARLK.LOOKUP_CODE(+) = PERSON.PERSON_PRE_NAME_ADJUNCT
   AND REL.PARTY_ID = REL_CONTACT.PARTY_ID
   AND REL.DIRECTIONAL_FLAG = 'F'
   AND PERSON.PARTY_ID = REL.SUBJECT_ID
   AND ORG.PARTY_ID = REL.OBJECT_ID
   AND HOC.PARTY_RELATIONSHIP_ID = REL.RELATIONSHIP_ID
   AND SITE.PARTY_ID (+)= REL_CONTACT.PARTY_ID
   AND SITE.STATUS (+)= 'A'
   AND SITE.IDENTIFYING_ADDRESS_FLAG (+)= 'Y'
   AND LOC.LOCATION_ID(+) = SITE.LOCATION_ID
   AND CPT_WP.OWNER_TABLE_ID(+) = REL_CONTACT.PARTY_ID
   AND CPT_HP.OWNER_TABLE_ID(+) = REL_CONTACT.PARTY_ID
   AND CPT_WF.OWNER_TABLE_ID(+) = REL_CONTACT.PARTY_ID
   AND CPT_CELL.OWNER_TABLE_ID(+) = REL_CONTACT.PARTY_ID
   AND CPT_PAGER.OWNER_TABLE_ID(+) = REL_CONTACT.PARTY_ID
   AND CPT_EMAIL.OWNER_TABLE_ID(+) = REL_CONTACT.PARTY_ID
   AND CSPM.CONTACT_PARTY_ID(+) = REL_CONTACT.PARTY_ID;


PROCEDURE PREPARE_FASTSYNC
/*******************************************************************************
**
** PREPARE_FASTSYNC
**
**   Performs a fetch from HZ tables based on the timestamp
**   and populates the CAC_SYNC_CONTACT_TEMPS table
**
*******************************************************************************/
(
  p_api_version          IN     NUMBER          -- Standard version parameter
, p_init_msg_list        IN     VARCHAR2        -- Standard message initialization flag
, p_principal_id         IN     NUMBER          -- Principal ID
, p_person_party_id      IN     NUMBER          -- Person Party ID
, p_sync_anchor          IN     DATE            -- Timestamp for sync anchor
, x_return_status        OUT NOCOPY  VARCHAR2   -- Standard API return status parameter
, x_msg_count            OUT NOCOPY  NUMBER     -- Standard return parameter for the no of msgs in the stack
, x_msg_data             OUT NOCOPY  VARCHAR2   -- Standard return parameter for the msgs in the stack
)
IS
    rec_new_contacts     c_new_contacts%ROWTYPE;
    rec_updated_contacts c_updated_contacts%ROWTYPE;
    rec_deleted_contacts c_deleted_contacts%ROWTYPE;
    l_bkm_module VARCHAR2(50);
    l_bkm_category VARCHAR2(30);
    l_bkm_preference_code VARCHAR2(30);
    l_count NUMBER;
BEGIN
    l_bkm_module := fnd_profile.value('CAC_SYNC_CONT_BKM_MODULE');
    l_bkm_category := fnd_profile.value('CAC_SYNC_CONT_BKM_CATEGORY');
    l_bkm_preference_code := fnd_profile.value('CAC_SYNC_CONT_BKM_PREFERENCE_CODE');

    SAVEPOINT prepare_fastsync_sp;

    cac_sync_contact_util_pvt.log(p_message=>'Entering PREPARE_FASTSYNC...',
                                  p_msg_level=>fnd_log.level_procedure,
                                  p_module_prefix=>'PREPARE_FASTSYNC');

    IF p_init_msg_list IS NULL OR
       fnd_api.to_boolean (p_init_msg_list)
    THEN
        fnd_msg_pub.initialize;
    END IF;

    -- Emptying the CAC_SYNC_CONTACT_TEMPS table not reqd as using ON COMMIT DELETE ROWS clause
    cac_sync_contact_util_pvt.log(p_message=>'Querying the new contacts...',
                                  p_msg_level=>fnd_log.level_procedure,
                                  p_module_prefix=>'PREPARE_FASTSYNC');

    l_count := 0;
    FOR rec_new_contacts IN c_new_contacts (p_principal_id,
                                            p_person_party_id,
                                            l_bkm_module,
                                            l_bkm_category,
                                            l_bkm_preference_code)
    LOOP
        INSERT INTO CAC_SYNC_CONTACT_TEMPS
        (sync_contact_temp_id
        ,rel_contact_party_id
        ,org_party_id
        ,org_name
        ,person_party_id
        ,person_full_name
        ,person_name_delimited
        ,job_title
        ,department
        ,address_delimited
        ,work_phone_number
        ,home_phone_number
        ,work_fax_number
        ,cell_number
        ,pager_number
        ,email_format
        ,email_address
        ,party_site_id
        ,work_phone_contact_point_id
        ,home_phone_contact_point_id
        ,work_fax_contact_point_id
        ,cell_phone_contact_point_id
        ,pager_contact_point_id
        ,email_contact_point_id
        ,status
        )
        VALUES
        (rec_new_contacts.sync_contact_temp_id
        ,rec_new_contacts.rel_contact_party_id
        ,rec_new_contacts.org_party_id
        ,rec_new_contacts.org_name
        ,rec_new_contacts.person_party_id
        ,rec_new_contacts.person_full_name
        ,rec_new_contacts.person_name_delimited
        ,rec_new_contacts.job_title
        ,rec_new_contacts.department
        ,rec_new_contacts.address_delimited
        ,rec_new_contacts.work_phone_number
        ,rec_new_contacts.home_phone_number
        ,rec_new_contacts.work_fax_number
        ,rec_new_contacts.cell_number
        ,rec_new_contacts.pager_number
        ,rec_new_contacts.email_format
        ,rec_new_contacts.email_address
        ,rec_new_contacts.party_site_id
        ,rec_new_contacts.work_phone_contact_point_id
        ,rec_new_contacts.home_phone_contact_point_id
        ,rec_new_contacts.work_fax_contact_point_id
        ,rec_new_contacts.cell_phone_contact_point_id
        ,rec_new_contacts.pager_contact_point_id
        ,rec_new_contacts.email_contact_point_id
        ,rec_new_contacts.status
        );
        l_count := l_count + 1;
    END LOOP;

    cac_sync_contact_util_pvt.log(p_message=>'The number of new contacts queried: '||l_count,
                                  p_msg_level=>fnd_log.level_procedure,
                                  p_module_prefix=>'PREPARE_FASTSYNC');

    cac_sync_contact_util_pvt.log(p_message=>'Querying the updated contacts...',
                                  p_msg_level=>fnd_log.level_procedure,
                                  p_module_prefix=>'PREPARE_FASTSYNC');

    l_count := 0;
    FOR rec_updated_contacts IN c_updated_contacts (p_principal_id,
                                                    p_person_party_id,
                                                    p_sync_anchor,
                                                    l_bkm_module,
                                                    l_bkm_category,
                                                    l_bkm_preference_code)
    LOOP
        INSERT INTO CAC_SYNC_CONTACT_TEMPS
        (sync_contact_temp_id
        ,rel_contact_party_id
        ,org_party_id
        ,org_name
        ,person_party_id
        ,person_full_name
        ,person_name_delimited
        ,job_title
        ,department
        ,address_delimited
        ,work_phone_number
        ,home_phone_number
        ,work_fax_number
        ,cell_number
        ,pager_number
        ,email_format
        ,email_address
        ,party_site_id
        ,work_phone_contact_point_id
        ,home_phone_contact_point_id
        ,work_fax_contact_point_id
        ,cell_phone_contact_point_id
        ,pager_contact_point_id
        ,email_contact_point_id
        ,status
        )
        VALUES
        (rec_updated_contacts.sync_contact_temp_id
        ,rec_updated_contacts.rel_contact_party_id
        ,rec_updated_contacts.org_party_id
        ,rec_updated_contacts.org_name
        ,rec_updated_contacts.person_party_id
        ,rec_updated_contacts.person_full_name
        ,rec_updated_contacts.person_name_delimited
        ,rec_updated_contacts.job_title
        ,rec_updated_contacts.department
        ,rec_updated_contacts.address_delimited
        ,rec_updated_contacts.work_phone_number
        ,rec_updated_contacts.home_phone_number
        ,rec_updated_contacts.work_fax_number
        ,rec_updated_contacts.cell_number
        ,rec_updated_contacts.pager_number
        ,rec_updated_contacts.email_format
        ,rec_updated_contacts.email_address
        ,rec_updated_contacts.party_site_id
        ,rec_updated_contacts.work_phone_contact_point_id
        ,rec_updated_contacts.home_phone_contact_point_id
        ,rec_updated_contacts.work_fax_contact_point_id
        ,rec_updated_contacts.cell_phone_contact_point_id
        ,rec_updated_contacts.pager_contact_point_id
        ,rec_updated_contacts.email_contact_point_id
        ,rec_updated_contacts.status
        );
        l_count := l_count + 1;
    END LOOP;

    cac_sync_contact_util_pvt.log(p_message=>'The number of updated contacts queried: '||l_count,
                                  p_msg_level=>fnd_log.level_procedure,
                                  p_module_prefix=>'PREPARE_FASTSYNC');

    cac_sync_contact_util_pvt.log(p_message=>'Querying the deleted contacts...',
                                  p_msg_level=>fnd_log.level_procedure,
                                  p_module_prefix=>'PREPARE_FASTSYNC');

    l_count := 0;
    FOR rec_deleted_contacts IN c_deleted_contacts (p_principal_id,
                                                    p_person_party_id,
                                                    l_bkm_module,
                                                    l_bkm_category,
                                                    l_bkm_preference_code)
    LOOP
        INSERT INTO CAC_SYNC_CONTACT_TEMPS
        (sync_contact_temp_id
        ,rel_contact_party_id
        ,org_party_id
        ,org_name
        ,person_party_id
        ,person_full_name
        ,person_name_delimited
        ,job_title
        ,department
        ,address_delimited
        ,work_phone_number
        ,home_phone_number
        ,work_fax_number
        ,cell_number
        ,pager_number
        ,email_format
        ,email_address
        ,party_site_id
        ,work_phone_contact_point_id
        ,home_phone_contact_point_id
        ,work_fax_contact_point_id
        ,cell_phone_contact_point_id
        ,pager_contact_point_id
        ,email_contact_point_id
        ,status
        )
        VALUES
        (rec_deleted_contacts.sync_contact_temp_id
        ,rec_deleted_contacts.rel_contact_party_id
        ,rec_deleted_contacts.org_party_id
        ,rec_deleted_contacts.org_name
        ,rec_deleted_contacts.person_party_id
        ,rec_deleted_contacts.person_full_name
        ,rec_deleted_contacts.person_name_delimited
        ,rec_deleted_contacts.job_title
        ,rec_deleted_contacts.department
        ,rec_deleted_contacts.address_delimited
        ,rec_deleted_contacts.work_phone_number
        ,rec_deleted_contacts.home_phone_number
        ,rec_deleted_contacts.work_fax_number
        ,rec_deleted_contacts.cell_number
        ,rec_deleted_contacts.pager_number
        ,rec_deleted_contacts.email_format
        ,rec_deleted_contacts.email_address
        ,rec_deleted_contacts.party_site_id
        ,rec_deleted_contacts.work_phone_contact_point_id
        ,rec_deleted_contacts.home_phone_contact_point_id
        ,rec_deleted_contacts.work_fax_contact_point_id
        ,rec_deleted_contacts.cell_phone_contact_point_id
        ,rec_deleted_contacts.pager_contact_point_id
        ,rec_deleted_contacts.email_contact_point_id
        ,rec_deleted_contacts.status
        );
        l_count := l_count + 1;
    END LOOP;

    cac_sync_contact_util_pvt.log(p_message => 'The number of deleted contacts queried: '||l_count,
                                  p_msg_level => fnd_log.level_procedure,
                                  p_module_prefix=>'PREPARE_FASTSYNC');

    x_return_status := fnd_api.g_ret_sts_success;

    fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

    cac_sync_contact_util_pvt.log(p_message => 'Leaving PREPARE_FASTSYNC...: '||x_return_status,
                                  p_msg_level => fnd_log.level_procedure,
                                  p_module_prefix=>'PREPARE_FASTSYNC');
EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
        ROLLBACK TO prepare_fastsync_sp;
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
        cac_sync_contact_util_pvt.log(p_message => x_msg_data,
                                      p_msg_level => fnd_log.level_exception,
                                      p_module_prefix=>'PREPARE_FASTSYNC');
    WHEN OTHERS
    THEN
        ROLLBACK TO prepare_fastsync_sp;
        fnd_message.set_name ('CAC', 'CAC_CONTACT_UNKNOWN_ERROR');
        fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
        cac_sync_contact_util_pvt.log(p_message => x_msg_data,
                                      p_msg_level => fnd_log.level_exception,
                                      p_module_prefix=>'PREPARE_FASTSYNC');
END PREPARE_FASTSYNC;

PROCEDURE PREPARE_SLOWSYNC
/*******************************************************************************
**
** PREPARE_SLOWSYNC
**
**   Performs a fetch from HZ tables for ALL synchronizable contact records
**   and populates the CAC_SYNC_CONTACT_TEMPS table
**
*******************************************************************************/
(
  p_api_version          IN     NUMBER          -- Standard version parameter
, p_init_msg_list        IN     VARCHAR2        -- Standard message initialization flag
, p_person_party_id      IN     NUMBER          -- Person Party ID
, x_return_status        OUT NOCOPY  VARCHAR2   -- Standard API return status parameter
, x_msg_count            OUT NOCOPY  NUMBER     -- Standard return parameter for the no of msgs in the stack
, x_msg_data             OUT NOCOPY  VARCHAR2   -- Standard return parameter for the msgs in the stack
)
IS
    rec_all_contacts c_all_contacts%ROWTYPE;
    l_bkm_module VARCHAR2(50);
    l_bkm_category VARCHAR2(30);
    l_bkm_preference_code VARCHAR2(30);
    l_count NUMBER;
BEGIN
    l_bkm_module := fnd_profile.value('CAC_SYNC_CONT_BKM_MODULE');
    l_bkm_category := fnd_profile.value('CAC_SYNC_CONT_BKM_CATEGORY');
    l_bkm_preference_code := fnd_profile.value('CAC_SYNC_CONT_BKM_PREFERENCE_CODE');

    SAVEPOINT prepare_slowsync_sp;

    cac_sync_contact_util_pvt.log(p_message => 'Entering PREPARE_SLOWSYNC...: ',
                                  p_msg_level => fnd_log.level_procedure,
                                  p_module_prefix=>'PREPARE_SLOWSYNC');

    IF p_init_msg_list IS NULL OR
       fnd_api.to_boolean (p_init_msg_list)
    THEN
        fnd_msg_pub.initialize;
    END IF;

    -- Emptying the CAC_SYNC_CONTACT_TEMPS table not reqd as using ON COMMIT DELETE ROWS clause

    cac_sync_contact_util_pvt.log(p_message=>'Retrieving all the contacts...',
                                  p_msg_level=>fnd_log.level_procedure,
                                  p_module_prefix=>'PREPARE_SLOWSYNC');

    l_count := 0;
    FOR rec_all_contacts IN c_all_contacts (p_person_party_id,
                                            l_bkm_module,
                                            l_bkm_category,
                                            l_bkm_preference_code)
    LOOP
        INSERT INTO CAC_SYNC_CONTACT_TEMPS
        (sync_contact_temp_id
        ,rel_contact_party_id
        ,org_party_id
        ,org_name
        ,person_party_id
        ,person_full_name
        ,person_name_delimited
        ,job_title
        ,department
        ,address_delimited
        ,work_phone_number
        ,home_phone_number
        ,work_fax_number
        ,cell_number
        ,pager_number
        ,email_format
        ,email_address
        ,party_site_id
        ,work_phone_contact_point_id
        ,home_phone_contact_point_id
        ,work_fax_contact_point_id
        ,cell_phone_contact_point_id
        ,pager_contact_point_id
        ,email_contact_point_id
        ,status
        )
        VALUES
        (rec_all_contacts.sync_contact_temp_id
        ,rec_all_contacts.rel_contact_party_id
        ,rec_all_contacts.org_party_id
        ,rec_all_contacts.org_name
        ,rec_all_contacts.person_party_id
        ,rec_all_contacts.person_full_name
        ,rec_all_contacts.person_name_delimited
        ,rec_all_contacts.job_title
        ,rec_all_contacts.department
        ,rec_all_contacts.address_delimited
        ,rec_all_contacts.work_phone_number
        ,rec_all_contacts.home_phone_number
        ,rec_all_contacts.work_fax_number
        ,rec_all_contacts.cell_number
        ,rec_all_contacts.pager_number
        ,rec_all_contacts.email_format
        ,rec_all_contacts.email_address
        ,rec_all_contacts.party_site_id
        ,rec_all_contacts.work_phone_contact_point_id
        ,rec_all_contacts.home_phone_contact_point_id
        ,rec_all_contacts.work_fax_contact_point_id
        ,rec_all_contacts.cell_phone_contact_point_id
        ,rec_all_contacts.pager_contact_point_id
        ,rec_all_contacts.email_contact_point_id
        ,rec_all_contacts.status
        );
        l_count := l_count + 1;
    END LOOP;

    cac_sync_contact_util_pvt.log(p_message => 'The number of contacts queried: '||l_count,
                                  p_msg_level => fnd_log.level_procedure,
                                  p_module_prefix=>'PREPARE_SLOWSYNC');

    x_return_status := fnd_api.g_ret_sts_success;

    fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

    cac_sync_contact_util_pvt.log(p_message => 'Leaving PREPARE_SLOWSYNC...:'||x_return_status,
                                  p_msg_level => fnd_log.level_procedure,
                                  p_module_prefix=>'PREPARE_SLOWSYNC');
EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
        ROLLBACK TO prepare_slowsync_sp;
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
        cac_sync_contact_util_pvt.log(p_message => x_msg_data,
                                      p_msg_level => fnd_log.level_exception,
                                      p_module_prefix=>'PREPARE_SLOWSYNC');

    WHEN OTHERS
    THEN
        ROLLBACK TO prepare_slowsync_sp;
        fnd_message.set_name ('CAC', 'CAC_CONTACT_UNKNOWN_ERROR');
        fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
        cac_sync_contact_util_pvt.log(p_message => x_msg_data,
                                      p_msg_level => fnd_log.level_exception,
                                      p_module_prefix=>'PREPARE_SLOWSYNC');

END PREPARE_SLOWSYNC;

FUNCTION FORMAT_PHONE
/*******************************************************************************
**
** FORMAT_PHONE
**
**   Format phone fucntion calling CAC_SYNC_CONTACT_UTIL_PVT.format_phone()
**
*******************************************************************************/
( p_country_code         IN   VARCHAR2
, p_area_code            IN   VARCHAR2
, p_phone_number         IN   VARCHAR2
, p_phone_extension      IN   VARCHAR2
) RETURN VARCHAR2
IS
BEGIN
    cac_sync_contact_util_pvt.log(p_message => 'Entering FORMAT_PHONE...',
                                  p_msg_level => fnd_log.level_procedure,
                                  p_module_prefix=>'FORMAT_PHONE');

    cac_sync_contact_util_pvt.log(p_message => 'Calling CAC_SYNC_CONTACT_UTIL_PVT.FORMAT_PHONE...',
                                  p_msg_level => fnd_log.level_procedure,
                                  p_module_prefix=>'FORMAT_PHONE');

    RETURN CAC_SYNC_CONTACT_UTIL_PVT.FORMAT_PHONE(
             p_country_code => p_country_code,
             p_area_code => p_area_code,
             p_phone_number => p_phone_number,
             p_phone_extension => p_phone_extension,
             p_delimit_country => '+',
             p_delimit_area_code => '( )',
             p_delimit_phone_number => ' ',
             p_delimit_extension => ' x'
             );

END FORMAT_PHONE;


END CAC_SYNC_CONTACTS_PVT;

/
