--------------------------------------------------------
--  DDL for Package Body FND_EID_PDR_ATTR_PROFILES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_EID_PDR_ATTR_PROFILES_PKG" AS
/* $Header: fndeidattprofb.pls 120.0.12010000.3 2012/10/09 01:33:27 rnagaraj noship $ */

procedure DELETE_ROW( X_EID_ATTR_PROFILE_ID in NUMBER) IS
begin
  delete from FND_EID_PDR_ATTR_PROFILES
  where eid_attr_profile_id = X_EID_attr_profile_id;

  if (sql%notfound) then
    null; --raise no_data_found;
  END IF;
end DELETE_ROW;


procedure LOAD_ROW (
         X_EID_ATTR_PROFILE_ID             IN VARCHAR2,
     X_EID_ATTR_PROFILE_CODE           IN VARCHAR2,
     X_RANKING_TYPE_CODE               IN VARCHAR2,
     X_SELECT_TYPE_CODE                IN VARCHAR2,
     X_SHOW_RECORD_COUNTS_FLAG         IN VARCHAR2,
     X_VALUE_SEARCHABLE_FLAG           IN VARCHAR2,
     X_TEXT_SEARCHABLE_FLAG            IN VARCHAR2,
     X_SNIPPET_SIZE                    IN VARCHAR2,
     X_UNIQUE_FLAG                     IN VARCHAR2,
     X_SINGLE_ASSIGN_FLAG              IN VARCHAR2,
     X_SEARCH_ALLOWS_WILDCARDS_FLAG    IN VARCHAR2,
     X_NAVIGATION_SORT_FLAG            IN VARCHAR2,
     X_LAST_UPDATE_DATE                IN VARCHAR2,
     X_APPLICATION_SHORT_NAME               IN VARCHAR2,
     X_OWNER                           IN VARCHAR2
	) IS
  user_id  NUMBER;
begin

   IF ( x_owner IS NOT NULL ) THEN
     user_id := fnd_load_util.owner_id(x_owner);
   ELSE
     user_id := -1; /* need to raise exception */
   END IF;

   IF ( user_id > 0 ) THEN

    MERGE INTO FND_EID_PDR_ATTR_PROFILES d
    USING (select
    X_EID_ATTR_PROFILE_ID              AS EID_ATTR_PROFILE_ID             ,
    X_EID_ATTR_PROFILE_CODE            AS EID_ATTR_PROFILE_CODE           ,
    X_RANKING_TYPE_CODE                AS RANKING_TYPE_CODE               ,
    X_SELECT_TYPE_CODE                 AS SELECT_TYPE_CODE                ,
    X_SHOW_RECORD_COUNTS_FLAG          AS SHOW_RECORD_COUNTS_FLAG         ,
    X_VALUE_SEARCHABLE_FLAG            AS VALUE_SEARCHABLE_FLAG           ,
    X_TEXT_SEARCHABLE_FLAG             AS TEXT_SEARCHABLE_FLAG            ,
    X_SNIPPET_SIZE                     AS SNIPPET_SIZE                    ,
    X_UNIQUE_FLAG                      AS UNIQUE_FLAG                     ,
    X_SINGLE_ASSIGN_FLAG               AS SINGLE_ASSIGN_FLAG              ,
    X_SEARCH_ALLOWS_WILDCARDS_FLAG     AS SEARCH_ALLOWS_WILDCARDS_FLAG    ,
    X_NAVIGATION_SORT_FLAG             AS NAVIGATION_SORT_FLAG          ,
    X_LAST_UPDATE_DATE                 AS LAST_UPDATE_DATE                ,
    X_OWNER                            AS LAST_UPDATED_BY
    from dual) s
    ON (d.eid_attr_profile_id = s.eid_attr_profile_id AND
        d.eid_attr_profile_code = s.eid_attr_profile_code)
    WHEN MATCHED THEN
      UPDATE SET
      d.RANKING_TYPE_CODE                = s.RANKING_TYPE_CODE               ,
      d.SELECT_TYPE_CODE                 = s.SELECT_TYPE_CODE                ,
      d.SHOW_RECORD_COUNTS_FLAG          = s.SHOW_RECORD_COUNTS_FLAG         ,
      d.VALUE_SEARCHABLE_FLAG            = s.VALUE_SEARCHABLE_FLAG           ,
      d.TEXT_SEARCHABLE_FLAG             = s.TEXT_SEARCHABLE_FLAG            ,
      d.SNIPPET_SIZE                     = s.SNIPPET_SIZE                    ,
      d.UNIQUE_FLAG                      = s.UNIQUE_FLAG                     ,
      d.SINGLE_ASSIGN_FLAG               = s.SINGLE_ASSIGN_FLAG              ,
      d.SEARCH_ALLOWS_WILDCARDS_FLAG     = s.SEARCH_ALLOWS_WILDCARDS_FLAG    ,
      d.NAVIGATION_SORT_FLAG           = s.NAVIGATION_SORT_FLAG          ,
      d.LAST_UPDATED_BY                  = user_id                 ,
      d.LAST_UPDATE_DATE                 = TO_DATE(s.LAST_UPDATE_DATE,'YYYY/MM/DD')
    WHEN NOT MATCHED THEN
      INSERT
       ( d.EID_ATTR_PROFILE_ID   ,
         d.EID_ATTR_PROFILE_CODE ,
         d.RANKING_TYPE_CODE     ,
         d.SELECT_TYPE_CODE      ,
         d.SHOW_RECORD_COUNTS_FLAG ,
         d.VALUE_SEARCHABLE_FLAG   ,
         d.TEXT_SEARCHABLE_FLAG    ,
         d.SNIPPET_SIZE            ,
         d.UNIQUE_FLAG             ,
         d.SINGLE_ASSIGN_FLAG      ,
         d.SEARCH_ALLOWS_WILDCARDS_FLAG,
         d.NAVIGATION_SORT_FLAG        ,
         d.CREATED_BY                  ,
         d.CREATION_DATE               ,
         d.LAST_UPDATED_BY             ,
         d.LAST_UPDATE_DATE            ,
         d.LAST_UPDATE_LOGIN
      )
      VALUES
      ( s.EID_ATTR_PROFILE_ID          ,
       s.EID_ATTR_PROFILE_CODE         ,
       s.RANKING_TYPE_CODE             ,
       s.SELECT_TYPE_CODE              ,
       s.SHOW_RECORD_COUNTS_FLAG       ,
       s.VALUE_SEARCHABLE_FLAG         ,
       s.TEXT_SEARCHABLE_FLAG          ,
       s.SNIPPET_SIZE                  ,
       s.UNIQUE_FLAG                   ,
       s.SINGLE_ASSIGN_FLAG            ,
       s.SEARCH_ALLOWS_WILDCARDS_FLAG  ,
       s.NAVIGATION_SORT_FLAG       ,
     user_id          ,
     TO_DATE(s.LAST_UPDATE_DATE,'YYYY/MM/DD')       ,
     user_id    ,
     TO_DATE(s.LAST_UPDATE_DATE,'YYYY/MM/DD')  ,
     0 );

  END IF;

end LOAD_ROW;

end FND_EID_PDR_ATTR_PROFILES_PKG ;

/
