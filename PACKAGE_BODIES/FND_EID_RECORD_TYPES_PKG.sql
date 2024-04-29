--------------------------------------------------------
--  DDL for Package Body FND_EID_RECORD_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_EID_RECORD_TYPES_PKG" AS
/* $Header: fndeidrectypb.pls 120.0.12010000.3 2012/10/09 01:36:48 rnagaraj noship $ */

procedure DELETE_ROW(X_EID_INSTANCE_ID in NUMBER) is
begin
  delete from FND_EID_RECORD_TYPES
  where EID_INSTANCE_ID = X_EID_INSTANCE_ID;

  if (sql%notfound) then
    null; --raise no_data_found;
  END IF;
end DELETE_ROW;


procedure LOAD_ROW (
        X_EID_INSTANCE_ID               IN     VARCHAR2,
  X_RECORD_TYPE                   IN     VARCHAR2,
  X_VIEW_NAME                     IN     VARCHAR2,
  X_EID_FULL_LOAD_ETL_GRAPH       IN     VARCHAR2,
  X_EID_INCR_LOAD_ETL_GRAPH       IN     VARCHAR2,
  X_EID_DELETE_ETL_GRAPH          IN     VARCHAR2,
  X_EID_RELEASE_VERSION           IN     VARCHAR2,
  X_OBSOLETED_FLAG                IN     VARCHAR2,
  X_OBSOLETED_EID_RELEASE_VER     IN     VARCHAR2,
  X_LAST_UPDATE_DATE              IN     VARCHAR2,
  X_APPLICATION_SHORT_NAME        IN     VARCHAR2,
  X_OWNER                         IN     VARCHAR2
	) IS
  user_id NUMBER;
begin

   IF ( x_owner IS NOT NULL ) THEN
     user_id := fnd_load_util.owner_id(x_owner);
   ELSE
     user_id := -1;   /* need to raise exception */
   END IF;

   IF ( user_id > 0 ) THEN
    MERGE INTO FND_EID_RECORD_TYPES d
    USING (select
      X_EID_INSTANCE_ID                as EID_INSTANCE_ID               ,
      X_RECORD_TYPE                    as RECORD_TYPE                  ,
      X_VIEW_NAME                      as VIEW_NAME                   ,
      X_EID_FULL_LOAD_ETL_GRAPH        as EID_FULL_LOAD_ETL_GRAPH    ,
      X_EID_INCR_LOAD_ETL_GRAPH        as EID_INCR_LOAD_ETL_GRAPH   ,
      X_EID_DELETE_ETL_GRAPH           as EID_DELETE_ETL_GRAPH     ,
      X_EID_RELEASE_VERSION            as EID_RELEASE_VERSION     ,
      X_OBSOLETED_FLAG                 as OBSOLETED_FLAG         ,
      X_OBSOLETED_EID_RELEASE_VER  as OBSOLETED_EID_RELEASE_VERSION ,
      X_LAST_UPDATE_DATE               as LAST_UPDATE_DATE         ,
      X_OWNER                          as LAST_UPDATED_BY
    from dual) s
    ON (d.eid_instance_id = s.eid_instance_id and d.record_type = s.record_type)
    WHEN MATCHED THEN
      UPDATE SET
      d.VIEW_NAME                      = s.VIEW_NAME                   ,
      d.EID_FULL_LOAD_ETL_GRAPH        = s.EID_FULL_LOAD_ETL_GRAPH    ,
      d.EID_INCR_LOAD_ETL_GRAPH        = s.EID_INCR_LOAD_ETL_GRAPH   ,
      d.EID_DELETE_ETL_GRAPH           = s.EID_DELETE_ETL_GRAPH     ,
      d.EID_RELEASE_VERSION            = s.EID_RELEASE_VERSION     ,
      d.OBSOLETED_FLAG                 = s.OBSOLETED_FLAG         ,
      d.OBSOLETED_EID_RELEASE_VERSION  = s.OBSOLETED_EID_RELEASE_VERSION ,
      d.LAST_UPDATED_BY                = user_id           ,
      d.LAST_UPDATE_DATE               = TO_DATE(s.LAST_UPDATE_DATE,'YYYY/MM/DD')
    WHEN NOT MATCHED THEN
      INSERT
       (d.EID_INSTANCE_ID               ,
        d.RECORD_TYPE                  ,
        d.VIEW_NAME                   ,
        d.EID_FULL_LOAD_ETL_GRAPH    ,
        d.EID_INCR_LOAD_ETL_GRAPH   ,
        d.EID_DELETE_ETL_GRAPH     ,
        d.EID_RELEASE_VERSION     ,
        d.OBSOLETED_FLAG         ,
        d.OBSOLETED_EID_RELEASE_VERSION ,
        d.CREATED_BY                   ,
        d.CREATION_DATE               ,
        d.LAST_UPDATED_BY              ,
        d.LAST_UPDATE_DATE            )
      VALUES
      ( to_number(s.EID_INSTANCE_ID)  ,
	 s.RECORD_TYPE                  ,
      s.VIEW_NAME                   ,
      s.EID_FULL_LOAD_ETL_GRAPH    ,
      s.EID_INCR_LOAD_ETL_GRAPH   ,
      s.EID_DELETE_ETL_GRAPH     ,
      s.EID_RELEASE_VERSION     ,
      s.OBSOLETED_FLAG         ,
      s.OBSOLETED_EID_RELEASE_VERSION ,
      user_id,
      TO_DATE(s.LAST_UPDATE_DATE,'YYYY/MM/DD'),
      user_id,
      TO_DATE(s.LAST_UPDATE_DATE,'YYYY/MM/DD')  );

  END IF;

end LOAD_ROW;

end FND_EID_RECORD_TYPES_PKG;

/
