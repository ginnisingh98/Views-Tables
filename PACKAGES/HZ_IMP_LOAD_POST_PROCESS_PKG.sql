--------------------------------------------------------
--  DDL for Package HZ_IMP_LOAD_POST_PROCESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_IMP_LOAD_POST_PROCESS_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHLPPLS.pls 120.7 2005/09/29 01:07:36 achung noship $ */

TYPE PARTY_ID                        IS TABLE OF HZ_PARTIES.PARTY_ID%TYPE;
TYPE PARTY_TYPE                      IS TABLE OF HZ_PARTIES.PARTY_TYPE%TYPE;
TYPE INSERT_UPDATE_FLAG              IS TABLE OF VARCHAR2(1);

TYPE PARTY_SITE_ID                   IS TABLE OF HZ_PARTY_SITES.PARTY_SITE_ID%TYPE;

TYPE ORG_CONTACT_ID                  IS TABLE OF HZ_ORG_CONTACTS.ORG_CONTACT_ID%TYPE;

TYPE PERSON_TITLE                    IS TABLE OF HZ_PARTIES.PERSON_TITLE%TYPE;
TYPE PERSON_FIRST_NAME               IS TABLE OF HZ_PARTIES.PERSON_FIRST_NAME%TYPE;
TYPE PERSON_MIDDLE_NAME              IS TABLE OF HZ_PARTIES.PERSON_MIDDLE_NAME%TYPE;
TYPE PERSON_LAST_NAME                IS TABLE OF HZ_PARTIES.PERSON_LAST_NAME%TYPE;
TYPE PERSON_NAME_SUFFIX              IS TABLE OF HZ_PARTIES.PERSON_NAME_SUFFIX%TYPE;
TYPE KNOWN_AS                        IS TABLE OF HZ_PARTIES.KNOWN_AS%TYPE;
TYPE PERSON_FIRST_NAME_PHONETIC      IS TABLE OF HZ_PARTIES.PERSON_FIRST_NAME_PHONETIC%TYPE;
TYPE MIDDLE_NAME_PHONETIC            IS TABLE OF HZ_PERSON_PROFILES.MIDDLE_NAME_PHONETIC%TYPE;
TYPE PERSON_LAST_NAME_PHONETIC       IS TABLE OF HZ_PARTIES.PERSON_LAST_NAME_PHONETIC%TYPE;

TYPE PARTY_NAME                      IS TABLE OF HZ_PARTIES.PARTY_NAME%TYPE;

TYPE LOCATION_ID                     IS TABLE OF HZ_LOCATIONS.LOCATION_ID%TYPE;
TYPE ADDRESS1                        IS TABLE OF HZ_LOCATIONS.ADDRESS1%TYPE;
TYPE ADDRESS2                        IS TABLE OF HZ_LOCATIONS.ADDRESS2%TYPE;
TYPE ADDRESS3                        IS TABLE OF HZ_LOCATIONS.ADDRESS3%TYPE;
TYPE ADDRESS4                        IS TABLE OF HZ_LOCATIONS.ADDRESS4%TYPE;
TYPE POSTAL_CODE                     IS TABLE OF HZ_LOCATIONS.POSTAL_CODE%TYPE;
TYPE COUNTRY                         IS TABLE OF HZ_LOCATIONS.COUNTRY%TYPE;
TYPE CITY                            IS TABLE OF HZ_LOCATIONS.CITY%TYPE;
TYPE STATE                           IS TABLE OF HZ_LOCATIONS.STATE%TYPE;
TYPE CREATED_BY_MODULE               IS TABLE OF HZ_LOCATIONS.CREATED_BY_MODULE%TYPE;
TYPE PARTY_NUMBER                    IS TABLE OF HZ_PARTIES.PARTY_NUMBER%TYPE;

TYPE CONTACT_POINT_ID                IS TABLE OF HZ_CONTACT_POINTS.CONTACT_POINT_ID%TYPE;
TYPE RAW_PHONE_NUMBER                IS TABLE OF HZ_CONTACT_POINTS.RAW_PHONE_NUMBER%TYPE;
TYPE COUNTRY_CODE                    IS TABLE OF HZ_CONTACT_POINTS.PHONE_COUNTRY_CODE%TYPE;
TYPE PHONE_AREA_CODE                 IS TABLE OF HZ_CONTACT_POINTS.EMAIL_ADDRESS%TYPE;
TYPE PHONE_NUMBER                    IS TABLE OF HZ_CONTACT_POINTS.PHONE_NUMBER%TYPE;
TYPE OWNER_TABLE_NAME                IS TABLE OF HZ_CONTACT_POINTS.OWNER_TABLE_NAME%TYPE;
TYPE OWNER_TABLE_ID                  IS TABLE OF HZ_CONTACT_POINTS.OWNER_TABLE_ID%TYPE;
TYPE PRIMARY_FLAG                    IS TABLE OF HZ_CONTACT_POINTS.PRIMARY_FLAG%TYPE;
TYPE PRIMARY_BY_PURPOSE              IS TABLE OF HZ_CONTACT_POINTS.PRIMARY_BY_PURPOSE%TYPE;
TYPE PHONE_LINE_TYPE                 IS TABLE OF HZ_CONTACT_POINTS.PHONE_LINE_TYPE%TYPE;
TYPE PHONE_EXTENSION                 IS TABLE OF HZ_CONTACT_POINTS.PHONE_EXTENSION%TYPE;
TYPE ACTUAL_CONTENT_SOURCE           IS TABLE OF HZ_CONTACT_POINTS.ACTUAL_CONTENT_SOURCE%TYPE;
TYPE CONTACT_POINT_TYPE              IS TABLE OF HZ_CONTACT_POINTS.CONTACT_POINT_TYPE%TYPE;

TYPE TITLE                           IS TABLE OF HZ_ORG_CONTACTS.TITLE%TYPE;

TYPE RELATIONSHIP_ID                 IS TABLE OF HZ_RELATIONSHIPS.RELATIONSHIP_ID%TYPE;
TYPE RELATIONSHIP_CODE               IS TABLE OF HZ_RELATIONSHIPS.RELATIONSHIP_CODE%TYPE;
TYPE SUBJECT_ID                      IS TABLE OF HZ_RELATIONSHIPS.SUBJECT_ID%TYPE;
TYPE OBJECT_ID                       IS TABLE OF HZ_RELATIONSHIPS.OBJECT_ID%TYPE;
TYPE COMP_FLAG                       IS TABLE OF VARCHAR2(1);
TYPE REF_FLAG                        IS TABLE OF VARCHAR2(1);
TYPE PAR_FLAG                        IS TABLE OF VARCHAR2(1);
TYPE SITE_ORIG_SYSTEM_REFERENCE      IS TABLE OF HZ_IMP_ADDRESSES_INT.SITE_ORIG_SYSTEM_REFERENCE%TYPE;

-- Data Type for DQM Sync
TYPE EntityList                      IS TABLE OF VARCHAR2(30);

PROCEDURE WORKER_PROCESS (
  Errbuf                      OUT NOCOPY     VARCHAR2,
  Retcode                     OUT NOCOPY     VARCHAR2,
  P_BATCH_ID                  IN             NUMBER,
  P_ACTUAL_CONTENT_SRC        IN             VARCHAR2,
  P_BATCH_MODE_FLAG	      IN	     VARCHAR2,
  P_REQUEST_ID                IN             NUMBER,
  p_generate_fuzzy_key        IN             VARCHAR2 := 'Y'
);

END HZ_IMP_LOAD_POST_PROCESS_PKG;

 

/