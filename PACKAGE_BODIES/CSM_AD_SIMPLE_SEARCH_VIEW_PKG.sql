--------------------------------------------------------
--  DDL for Package Body CSM_AD_SIMPLE_SEARCH_VIEW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_AD_SIMPLE_SEARCH_VIEW_PKG" as
/* $Header: csmlassb.pls 120.0 2008/01/25 19:16:41 trajasek noship $ */
PROCEDURE INSERT_ROW (
                      X_SEARCH_TYPE_ID   IN NUMBER,
                      X_LEVEL_ID      IN NUMBER,
                      X_LEVEL_VALUE   IN NUMBER,
                      X_NAME          IN VARCHAR2,
                      X_COLUMN_NAME   IN VARCHAR2,
                      X_DISPLAY_SEQ   IN NUMBER,
                      X_ORIGINAL_SEQ  IN NUMBER,
                      X_GROUP_TYPE    IN VARCHAR2,
                      X_IS_REMOVED    IN VARCHAR2,
                      X_DB_TYPE       IN VARCHAR2,
                      X_OPERATION     IN VARCHAR2,
                      X_OWNER         IN VARCHAR2
                      )
IS

BEGIN

  INSERT INTO CSM_AD_SIMPLE_SEARCH_VIEW
                           (ID,
                            SEARCH_TYPE_ID,
                            LEVEL_ID,
                            LEVEL_VALUE,
                            NAME,
                            COLUMN_NAME,
                            DISPLAY_SEQ,
                            ORIGINAL_SEQ,
                            GROUP_TYPE,
                            IS_REMOVED,
                            DB_TYPE,
                            OPERATION,
                            CREATION_DATE,
                            CREATED_BY,
                            LAST_UPDATE_DATE,
                            LAST_UPDATED_BY)
                          VALUES
                          ( CSM_AD_SIMPLE_SEARCH_VIEW_S.NEXTVAL,
                            X_SEARCH_TYPE_ID,
                            X_LEVEL_ID,
                            X_LEVEL_VALUE,
                            X_NAME,
                            X_COLUMN_NAME,
                            X_DISPLAY_SEQ,
                            X_ORIGINAL_SEQ,
                            X_GROUP_TYPE,
                            X_IS_REMOVED,
                            X_DB_TYPE,
                            X_OPERATION,
                            SYSDATE,
                            DECODE(X_OWNER,'SEED',1,0),
                            SYSDATE,
                            DECODE(X_OWNER,'SEED',1,0)
                            );



END INSERT_ROW;

PROCEDURE UPDATE_ROW (
                     X_SEARCH_TYPE_ID   IN NUMBER,
                     X_LEVEL_ID      IN NUMBER,
                     X_LEVEL_VALUE   IN NUMBER,
                     X_NAME          IN VARCHAR2,
                     X_COLUMN_NAME   IN VARCHAR2,
                     X_DISPLAY_SEQ   IN NUMBER,
                     X_ORIGINAL_SEQ  IN NUMBER,
                     X_GROUP_TYPE    IN VARCHAR2,
                     X_IS_REMOVED    IN VARCHAR2,
                     X_DB_TYPE       IN VARCHAR2,
                     X_OPERATION     IN VARCHAR2,
                     X_OWNER         IN VARCHAR2
                     )


IS

BEGIN


 UPDATE CSM_AD_SIMPLE_SEARCH_VIEW
   SET
      NAME             =  X_NAME,
      DISPLAY_SEQ      =  X_DISPLAY_SEQ,
      ORIGINAL_SEQ     =  X_ORIGINAL_SEQ,
      GROUP_TYPE       =  X_GROUP_TYPE,
      IS_REMOVED       =  X_IS_REMOVED,
      DB_TYPE          =  X_DB_TYPE,
      OPERATION        =  X_OPERATION,
      LAST_UPDATE_DATE =  SYSDATE,
      LAST_UPDATED_BY  =  DECODE(X_OWNER,'SEED',1,0)
   WHERE COLUMN_NAME   =  X_COLUMN_NAME
   AND SEARCH_TYPE_ID     = X_SEARCH_TYPE_ID ;


END UPDATE_ROW;

PROCEDURE LOAD_ROW (
                    X_ID               IN NUMBER,
                    X_SEARCH_TYPE_ID   IN NUMBER,
                    X_LEVEL_ID         IN NUMBER,
                    X_LEVEL_VALUE      IN NUMBER,
                    X_NAME             IN VARCHAR2,
                    X_COLUMN_NAME      IN VARCHAR2,
                    X_DISPLAY_SEQ      IN NUMBER,
                    X_ORIGINAL_SEQ     IN NUMBER,
                    X_GROUP_TYPE       IN VARCHAR2,
                    X_IS_REMOVED       IN VARCHAR2,
                    X_DB_TYPE          IN VARCHAR2,
                    X_OPERATION        IN VARCHAR2,
                    X_OWNER            IN VARCHAR2
                   )

IS

CURSOR c_exists IS
   SELECT 1
   FROM  CSM_AD_SIMPLE_SEARCH_VIEW
   WHERE COLUMN_NAME =X_COLUMN_NAME
   AND   SEARCH_TYPE_ID=X_SEARCH_TYPE_ID;


l_exists NUMBER;

BEGIN



 OPEN c_exists;
 FETCH c_exists INTO l_exists;
 CLOSE c_exists;



 IF l_exists IS NULL THEN
   INSERT_ROW (
                  X_SEARCH_TYPE_ID,
                 X_LEVEL_ID,
                 X_LEVEL_VALUE,
                 X_NAME,
                 X_COLUMN_NAME,
                 X_DISPLAY_SEQ,
                 X_ORIGINAL_SEQ,
                 X_GROUP_TYPE,
                 X_IS_REMOVED,
                 X_DB_TYPE,
                 X_OPERATION,
                 X_OWNER
                 );

 ELSE

   UPDATE_ROW (
                X_SEARCH_TYPE_ID,
                X_LEVEL_ID,
                X_LEVEL_VALUE,
                X_NAME,
                X_COLUMN_NAME,
                X_DISPLAY_SEQ,
                X_ORIGINAL_SEQ,
                X_GROUP_TYPE,
                X_IS_REMOVED,
                X_DB_TYPE,
                X_OPERATION,
                X_OWNER
               );

 END IF;

END LOAD_ROW;

END CSM_AD_SIMPLE_SEARCH_VIEW_PKG ;

/
