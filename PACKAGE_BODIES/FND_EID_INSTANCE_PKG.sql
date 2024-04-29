--------------------------------------------------------
--  DDL for Package Body FND_EID_INSTANCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_EID_INSTANCE_PKG" AS
/* $Header: fndeidinstb.pls 120.0.12010000.3 2012/10/09 01:35:28 rnagaraj noship $ */

procedure DELETE_ROW(X_EID_INSTANCE_ID in NUMBER) is
begin
  delete from FND_EID_INSTANCES
  where EID_INSTANCE_ID = X_EID_INSTANCE_ID;

  if (sql%notfound) then
    null; --raise no_data_found;
  END IF;
end DELETE_ROW;


procedure LOAD_ROW (
          X_EID_INSTANCE_ID                  IN  VARCHAR2,
        X_APPLICATION_ID                   IN  VARCHAR2,
        X_EID_DATA_STORE_NAME              IN  VARCHAR2,
        X_EID_RELEASE_VERSION              IN  VARCHAR2,
        X_ENBL_WILDCARD_VAL_SRCH    IN  VARCHAR2,
        X_CONFIG_MERGE_POLICY       IN  VARCHAR2,
        X_CONFIG_SEARCH_CHARS       IN  VARCHAR2,
        X_MIN_OCCRNCS_INDXNG_SPL_STD   IN  VARCHAR2,
        X_MIN_INDXNG_SPL_CRCTN_STD   IN  VARCHAR2,
        X_MAX_INDXNG_SPL_CRCTN_STD   IN  VARCHAR2,
        X_MIN_OCCRNCS_INDXNG_SPL_MGD   IN  VARCHAR2,
        X_MIN_INDXNG_SPL_CRCTN_MGD   IN  VARCHAR2,
        X_MAX_INDXNG_SPL_CRCTN_MGD   IN  VARCHAR2,
        X_ENDECA_SERVER_PORT               IN  VARCHAR2,
        X_ENDECA_SERVER_HOST               IN  VARCHAR2,
        X_LAST_UPDATE_DATE                 IN  VARCHAR2,
        X_APPLICATION_SHORT_NAME           IN  VARCHAR2,
        X_OWNER                            IN  VARCHAR2
	) IS

   user_id NUMBER;
begin

   /*   if (fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                db_ludate, X_CUSTOM_MODE))
  */

    IF ( x_owner IS NOT NULL )  THEN
      user_id := fnd_load_util.owner_id(x_owner);
    ELSE
      user_id := -1;  /* should raise exception */
    END IF;

    IF ( user_id > 0 ) THEN
    MERGE INTO FND_EID_INSTANCES d
    USING (select
     X_EID_INSTANCE_ID            as    EID_INSTANCE_ID   ,
     X_APPLICATION_ID               as    APPLICATION_ID   ,
     X_EID_DATA_STORE_NAME          as     EID_DATA_STORE_NAME ,
     X_EID_RELEASE_VERSION          as     EID_RELEASE_VERSION ,
     X_ENBL_WILDCARD_VAL_SRCH  as   GLOBAL_ENBL_WILDCARD_VAL_SRCH ,
     X_CONFIG_MERGE_POLICY  as      GLOBAL_CONFIG_MERGE_POLICY ,
     X_CONFIG_SEARCH_CHARS  as      GLOBAL_CONFIG_SEARCH_CHARS ,
     X_MIN_OCCRNCS_INDXNG_SPL_STD  as     MIN_WRD_OCCRNCS_INDXNG_SPL_STD ,
     X_MIN_INDXNG_SPL_CRCTN_STD  as     MIN_CHARS_INDXNG_SPL_CRCTN_STD ,
     X_MAX_INDXNG_SPL_CRCTN_STD  as     MAX_CHARS_INDXNG_SPL_CRCTN_STD ,
     X_MIN_OCCRNCS_INDXNG_SPL_MGD  as     MIN_WRD_OCCRNCS_INDXNG_SPL_MGD ,
     X_MIN_INDXNG_SPL_CRCTN_MGD  as     MIN_CHARS_INDXNG_SPL_CRCTN_MGD ,
     X_MAX_INDXNG_SPL_CRCTN_MGD  as     MAX_CHARS_INDXNG_SPL_CRCTN_MGD ,
     X_ENDECA_SERVER_PORT  as     ENDECA_SERVER_PORT ,
     X_ENDECA_SERVER_HOST  as     ENDECA_SERVER_HOST ,
     X_OWNER    as     LAST_UPDATED_BY   ,
     X_LAST_UPDATE_DATE  as     LAST_UPDATE_DATE
    from dual) s
    ON (d.eid_instance_id = s.EID_INSTANCE_ID and d.application_id = s.application_id)
    WHEN MATCHED THEN
      UPDATE SET
     d.EID_DATA_STORE_NAME          =    s.EID_DATA_STORE_NAME ,
     d.EID_RELEASE_VERSION          =    s.EID_RELEASE_VERSION ,
     d.GLOBAL_ENBL_WILDCARD_VAL_SRCH  =   s.GLOBAL_ENBL_WILDCARD_VAL_SRCH ,
     d.GLOBAL_CONFIG_MERGE_POLICY  =      s.GLOBAL_CONFIG_MERGE_POLICY ,
     d.GLOBAL_CONFIG_SEARCH_CHARS  =      s.GLOBAL_CONFIG_SEARCH_CHARS ,
     d.MIN_WRD_OCCRNCS_INDXNG_SPL_STD  =     s.MIN_WRD_OCCRNCS_INDXNG_SPL_STD ,
     d.MIN_CHARS_INDXNG_SPL_CRCTN_STD  =     s.MIN_CHARS_INDXNG_SPL_CRCTN_STD ,
     d.MAX_CHARS_INDXNG_SPL_CRCTN_STD  =     s.MAX_CHARS_INDXNG_SPL_CRCTN_STD ,
     d.MIN_WRD_OCCRNCS_INDXNG_SPL_MGD  =     s.MIN_WRD_OCCRNCS_INDXNG_SPL_MGD ,
     d.MIN_CHARS_INDXNG_SPL_CRCTN_MGD  =     s.MIN_CHARS_INDXNG_SPL_CRCTN_MGD ,
     d.MAX_CHARS_INDXNG_SPL_CRCTN_MGD  =     s.MAX_CHARS_INDXNG_SPL_CRCTN_MGD ,
     d.ENDECA_SERVER_PORT  =     s.ENDECA_SERVER_PORT ,
     d.ENDECA_SERVER_HOST  =     s.ENDECA_SERVER_HOST ,
     d.LAST_UPDATED_BY    =     user_id   ,
     d.LAST_UPDATE_DATE  =      TO_DATE(s.LAST_UPDATE_DATE,'YYYY/MM/DD')
    WHEN NOT MATCHED THEN
      INSERT
       ( d.eid_instance_id,
     d.APPLICATION_ID  ,
     d.EID_DATA_STORE_NAME ,
     d.EID_RELEASE_VERSION ,
     d.GLOBAL_ENBL_WILDCARD_VAL_SRCH,
     d.GLOBAL_CONFIG_MERGE_POLICY  ,
     d.GLOBAL_CONFIG_SEARCH_CHARS  ,
     d.MIN_WRD_OCCRNCS_INDXNG_SPL_STD ,
     d.MIN_CHARS_INDXNG_SPL_CRCTN_STD ,
     d.MAX_CHARS_INDXNG_SPL_CRCTN_STD ,
     d.MIN_WRD_OCCRNCS_INDXNG_SPL_MGD ,
     d.MIN_CHARS_INDXNG_SPL_CRCTN_MGD ,
     d.MAX_CHARS_INDXNG_SPL_CRCTN_MGD ,
     d.ENDECA_SERVER_PORT  ,
     d.ENDECA_SERVER_HOST  ,
     d.CREATED_BY          ,
     d.CREATION_DATE       ,
     d.LAST_UPDATED_BY    ,
     d.LAST_UPDATE_DATE  )
      VALUES
      ( to_number(s.eid_instance_id),
     to_number(s.APPLICATION_ID)  ,
     s.EID_DATA_STORE_NAME ,
     s.EID_RELEASE_VERSION ,
     s.GLOBAL_ENBL_WILDCARD_VAL_SRCH,
     s.GLOBAL_CONFIG_MERGE_POLICY  ,
     s.GLOBAL_CONFIG_SEARCH_CHARS  ,
     to_number(s.MIN_WRD_OCCRNCS_INDXNG_SPL_STD) ,
     to_number(s.MIN_CHARS_INDXNG_SPL_CRCTN_STD) ,
     to_number(s.MAX_CHARS_INDXNG_SPL_CRCTN_STD) ,
     to_number(s.MIN_WRD_OCCRNCS_INDXNG_SPL_MGD) ,
     to_number(s.MIN_CHARS_INDXNG_SPL_CRCTN_MGD) ,
     to_number(s.MAX_CHARS_INDXNG_SPL_CRCTN_MGD) ,
     s.ENDECA_SERVER_PORT  ,
     s.ENDECA_SERVER_HOST  ,
     user_id          ,
     TO_DATE(s.LAST_UPDATE_DATE,'YYYY/MM/DD')       ,
     user_id    ,
     TO_DATE(s.LAST_UPDATE_DATE,'YYYY/MM/DD'));

  END IF;

end LOAD_ROW;

end FND_EID_INSTANCE_PKG;

/
