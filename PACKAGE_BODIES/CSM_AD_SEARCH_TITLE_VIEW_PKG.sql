--------------------------------------------------------
--  DDL for Package Body CSM_AD_SEARCH_TITLE_VIEW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_AD_SEARCH_TITLE_VIEW_PKG" as
/* $Header: csmlastb.pls 120.1 2008/02/07 09:15:18 trajasek noship $ */
PROCEDURE INSERT_ROW (
                      X_SEARCH_TYPE    IN VARCHAR2,
                      X_LEVEL_ID       IN NUMBER,
                      X_LEVEL_VALUE    IN NUMBER,
                      X_SEARCH_TITLE   IN VARCHAR2,
                      X_VO_NAME        IN VARCHAR2,
                      X_SEARCH_TYPE_ID IN NUMBER,
                      X_OWNER          IN VARCHAR2
                      )
IS

BEGIN

  INSERT INTO CSM_AD_SEARCH_TITLE_VIEW
                           (ID,
                            SEARCH_TYPE,
                            LEVEL_ID,
                            LEVEL_VALUE,
                            SEARCH_TITLE,
                            VO_NAME,
                            CREATION_DATE,
                            CREATED_BY,
                            LAST_UPDATE_DATE,
                            LAST_UPDATED_BY,
                            SEARCH_TYPE_ID)
                          VALUES
                          ( CSM_AD_SEARCH_TITLE_VIEW_S.NEXTVAL,
                            X_SEARCH_TYPE,
                            X_LEVEL_ID,
                            X_LEVEL_VALUE,
                            X_SEARCH_TITLE,
                            X_VO_NAME,
                            SYSDATE,
                            DECODE(X_OWNER,'SEED',1,0),
                            SYSDATE,
                            DECODE(X_OWNER,'SEED',1,0),
                            X_SEARCH_TYPE_ID
                            );



END INSERT_ROW;

PROCEDURE UPDATE_ROW (
                     X_SEARCH_TYPE    IN VARCHAR2,
                     X_LEVEL_ID       IN NUMBER,
                     X_LEVEL_VALUE    IN NUMBER,
                     X_SEARCH_TITLE   IN VARCHAR2,
                     X_VO_NAME        IN VARCHAR2,
                     X_SEARCH_TYPE_ID IN NUMBER,
                     X_OWNER          IN VARCHAR2
                     )

IS

BEGIN


  UPDATE CSM_AD_SEARCH_TITLE_VIEW
   SET
      SEARCH_TITLE     =  X_SEARCH_TITLE,
      VO_NAME          =  X_VO_NAME,
      SEARCH_TYPE_ID   =  X_SEARCH_TYPE_ID,
      LAST_UPDATE_DATE =  SYSDATE,
      LAST_UPDATED_BY  =  DECODE(X_OWNER,'SEED',1,0)
   WHERE SEARCH_TYPE   =  X_SEARCH_TYPE;


END UPDATE_ROW;

PROCEDURE LOAD_ROW (
                    X_ID             IN NUMBER,
                    X_SEARCH_TYPE    IN VARCHAR2,
                    X_LEVEL_ID       IN NUMBER,
                    X_LEVEL_VALUE    IN NUMBER,
                    X_SEARCH_TITLE   IN VARCHAR2,
                    X_VO_NAME        IN VARCHAR2,
                    X_SEARCH_TYPE_ID IN NUMBER,
                    X_OWNER          IN VARCHAR2)

IS

CURSOR c_exists IS
   SELECT 1
   FROM  CSM_AD_SEARCH_TITLE_VIEW
   WHERE SEARCH_TYPE=X_SEARCH_TYPE;

l_exists NUMBER;

BEGIN



 OPEN c_exists;
 FETCH c_exists INTO l_exists;
 CLOSE c_exists;

 IF l_exists IS NULL THEN
   INSERT_ROW (
                 X_SEARCH_TYPE,
                 X_LEVEL_ID,
                 X_LEVEL_VALUE,
                 X_SEARCH_TITLE,
                 X_VO_NAME,
                 X_SEARCH_TYPE_ID,
                 X_OWNER
                 );


 ELSE

   UPDATE_ROW (
                X_SEARCH_TYPE,
                X_LEVEL_ID,
                X_LEVEL_VALUE,
                X_SEARCH_TITLE,
                X_VO_NAME,
                X_SEARCH_TYPE_ID,
                X_OWNER
                 );

 END IF;

END LOAD_ROW;

END CSM_AD_SEARCH_TITLE_VIEW_PKG ;

/
