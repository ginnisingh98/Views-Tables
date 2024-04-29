--------------------------------------------------------
--  DDL for Package Body FND_EID_ATTR_GROUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_EID_ATTR_GROUPS_PKG" AS
/* $Header: fndeidattrgrpsb.pls 120.0.12010000.3 2012/10/09 01:32:12 rnagaraj noship $ */

procedure DELETE_ROW(
    X_EID_INSTANCE_ID in NUMBER,
    X_EID_INSTANCE_GROUP IN VARCHAR2,
    X_EID_INSTANCE_ATTRIBUTE IN VARCHAR2
    ) is
begin
  delete from FND_EID_ATTR_GROUPS
  where EID_INSTANCE_ID = X_EID_INSTANCE_ID
  AND EID_INSTANCE_GROUP = X_EID_INSTANCE_GROUP
  AND EID_INSTANCE_ATTRIBUTE  = X_EID_INSTANCE_ATTRIBUTE;

  if (sql%notfound) then
    null; --raise no_data_found;
  END IF;
end DELETE_ROW;


procedure LOAD_ROW (
        X_EID_INSTANCE_ID                    IN VARCHAR2,
        X_EID_INSTANCE_GROUP                 IN VARCHAR2,
        X_EID_INSTANCE_ATTRIBUTE             IN VARCHAR2,
        X_EID_INSTANCE_GROUP_ATTR_SEQ        IN VARCHAR2,
        X_EID_INST_GROUP_ATTR_USER_SEQ       IN VARCHAR2,
        X_GROUP_ATTRIBUTE_SOURCE             IN VARCHAR2,
        X_EID_RELEASE_VERSION                IN VARCHAR2,
        X_OBSOLETED_FLAG                     IN VARCHAR2,
        X_OBSOLETED_EID_REL_VER              IN VARCHAR2,
        X_LAST_UPDATE_DATE                   IN VARCHAR2,
        X_APPLICATION_SHORT_NAME             IN VARCHAR2,
        X_OWNER                              IN VARCHAR2
	) IS
   user_id  NUMBER;
begin

   IF ( x_owner IS NOT NULL ) THEN
     user_id := fnd_load_util.owner_id(x_owner);
   ELSE
     user_id := -1;
   END IF;

   IF ( user_id > 0 ) THEN

    MERGE INTO FND_EID_ATTR_GROUPS d
    USING (select
     X_EID_INSTANCE_ID                AS EID_INSTANCE_ID            ,
     X_EID_INSTANCE_GROUP             AS EID_INSTANCE_GROUP          ,
     X_EID_INSTANCE_ATTRIBUTE         AS EID_INSTANCE_ATTRIBUTE      ,
     X_EID_INSTANCE_GROUP_ATTR_SEQ    AS EID_INSTANCE_GROUP_ATTR_SEQ ,
     X_EID_INST_GROUP_ATTR_USER_SEQ   AS EID_INST_GROUP_ATTR_USER_SEQ,
     X_GROUP_ATTRIBUTE_SOURCE         AS GROUP_ATTRIBUTE_SOURCE      ,
     X_EID_RELEASE_VERSION            AS EID_RELEASE_VERSION         ,
     X_OBSOLETED_FLAG                 AS OBSOLETED_FLAG              ,
     X_OBSOLETED_EID_REL_VER          AS OBSOLETED_EID_RELEASE_VERSION,
     X_LAST_UPDATE_DATE               AS     LAST_UPDATE_DATE ,
     X_OWNER                          AS     LAST_UPDATED_BY
    from dual) s
    ON (d.eid_instance_id = s.eid_instance_id
        AND d.EID_INSTANCE_GROUP = s.EID_INSTANCE_GROUP
	   AND d.EID_INSTANCE_ATTRIBUTE = s.EID_INSTANCE_ATTRIBUTE)
    WHEN MATCHED THEN
      UPDATE SET
         d.EID_INSTANCE_GROUP_ATTR_SEQ     = s.EID_INSTANCE_GROUP_ATTR_SEQ,
         d.EID_INST_GROUP_ATTR_USER_SEQ    = s.EID_INST_GROUP_ATTR_USER_SEQ ,
         d.GROUP_ATTRIBUTE_SOURCE          = s.GROUP_ATTRIBUTE_SOURCE     ,
         d.EID_RELEASE_VERSION             = s.EID_RELEASE_VERSION        ,
         d.OBSOLETED_FLAG                  = s.OBSOLETED_FLAG             ,
         d.OBSOLETED_EID_RELEASE_VERSION   = s.OBSOLETED_EID_RELEASE_VERSION,
         d.LAST_UPDATED_BY    =     user_id   ,
         d.LAST_UPDATE_DATE  =     TO_DATE(s.LAST_UPDATE_DATE,'YYYY/MM/DD')
     WHERE d.eid_instance_id = s.eid_instance_id
	AND d.EID_INSTANCE_GROUP = s.EID_INSTANCE_GROUP
	AND d.EID_INSTANCE_ATTRIBUTE = s.EID_INSTANCE_ATTRIBUTE
    WHEN NOT MATCHED THEN
      INSERT
       ( d.EID_INSTANCE_ID                        ,
       d.EID_INSTANCE_GROUP                    ,
       d.EID_INSTANCE_ATTRIBUTE                ,
       d.EID_INSTANCE_GROUP_ATTR_SEQ           ,
       d.EID_INST_GROUP_ATTR_USER_SEQ          ,
       d.GROUP_ATTRIBUTE_SOURCE                ,
       d.EID_RELEASE_VERSION                   ,
       d.OBSOLETED_FLAG                        ,
       d.OBSOLETED_EID_RELEASE_VERSION         ,
       d.CREATED_BY          ,
       d.CREATION_DATE       ,
       d.LAST_UPDATED_BY    ,
       d.LAST_UPDATE_DATE  ,
       d.LAST_UPDATE_LOGIN )
      VALUES
      ( s.EID_INSTANCE_ID                        ,
        s.EID_INSTANCE_GROUP                    ,
        s.EID_INSTANCE_ATTRIBUTE                ,
        s.EID_INSTANCE_GROUP_ATTR_SEQ           ,
        s.EID_INST_GROUP_ATTR_USER_SEQ          ,
        s.GROUP_ATTRIBUTE_SOURCE                ,
        s.EID_RELEASE_VERSION                   ,
        s.OBSOLETED_FLAG                        ,
        s.OBSOLETED_EID_RELEASE_VERSION         ,
        user_id          ,
        TO_DATE(s.LAST_UPDATE_DATE,'YYYY/MM/DD')       ,
        user_id    ,
        TO_DATE(s.LAST_UPDATE_DATE,'YYYY/MM/DD')  ,
        0 );

  END IF;

end LOAD_ROW;

end FND_EID_ATTR_GROUPS_PKG;

/
