--------------------------------------------------------
--  DDL for Package Body CSM_AD_SEARCH_RESULT_VIEW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_AD_SEARCH_RESULT_VIEW_PKG" as
/* $Header: csmlaslb.pls 120.1 2008/02/20 11:38:38 trajasek noship $ */

PROCEDURE INSERT_ROW (
                      X_ID               IN NUMBER,
                      X_SEARCH_TYPE_ID   IN NUMBER,
                      X_LEVEL_ID         IN NUMBER,
                      X_LEVEL_VALUE      IN NUMBER,
                      X_HEADER           IN VARCHAR2,
                      X_COLUMN_NAME      IN VARCHAR2,
                      X_IS_MAIN          IN VARCHAR2,
                      X_IS_LINK          IN VARCHAR2,
                      X_DESTINATION      IN VARCHAR2,
                      X_PARAMETERS       IN VARCHAR2,
                      X_DISPLAY_SEQ      IN NUMBER,
                      X_ORIGINAL_SEQ     IN NUMBER,
                      X_IS_REMOVED       IN VARCHAR2,
                      X_OWNER            IN VARCHAR2
                      )

IS

BEGIN

 INSERT INTO CSM_AD_SEARCH_RESULT_VIEW
                     (ID,
                      SEARCH_TYPE_ID,
                      LEVEL_ID,
                      LEVEL_VALUE,
                      HEADER,
                      COLUMN_NAME,
                      IS_MAIN,
                      IS_LINK,
                      DESTINATION,
                      PARAMETERS,
                      DISPLAY_SEQ,
                      ORIGINAL_SEQ,
                      IS_REMOVED,
                      CREATION_DATE,
                      CREATED_BY,
                      LAST_UPDATE_DATE,
                      LAST_UPDATED_BY
                     )
                      VALUES
                      ( X_ID,     --CSM_AD_SEARCH_RESULT_VIEW_S.NEXTVAL,
                        X_SEARCH_TYPE_ID,
                        X_LEVEL_ID,
                        X_LEVEL_VALUE,
                        X_HEADER,
                        X_COLUMN_NAME,
                        X_IS_MAIN,
                        X_IS_LINK,
                        X_DESTINATION,
                        X_PARAMETERS,
                        X_DISPLAY_SEQ,
                        X_ORIGINAL_SEQ,
                        X_IS_REMOVED,
                        SYSDATE,
                        DECODE(X_OWNER,'SEED',1,0),
                        SYSDATE,
                        DECODE(X_OWNER,'SEED',1,0)
                        );
END INSERT_ROW;

PROCEDURE UPDATE_ROW (
                     X_ID               IN NUMBER,
                     X_SEARCH_TYPE_ID   IN NUMBER,
                     X_LEVEL_ID         IN NUMBER,
                     X_LEVEL_VALUE      IN NUMBER,
                     X_HEADER           IN VARCHAR2,
                     X_COLUMN_NAME      IN VARCHAR2,
                     X_IS_MAIN          IN VARCHAR2,
                     X_IS_LINK          IN VARCHAR2,
                     X_DESTINATION      IN VARCHAR2,
                     X_PARAMETERS       IN VARCHAR2,
                     X_DISPLAY_SEQ      IN NUMBER,
                     X_ORIGINAL_SEQ     IN NUMBER,
                     X_IS_REMOVED       IN VARCHAR2,
                     X_OWNER            IN VARCHAR2
                     )
IS

BEGIN


 UPDATE CSM_AD_SEARCH_RESULT_VIEW
   SET
      HEADER           =  X_HEADER,
      IS_MAIN          =  X_IS_MAIN,
      IS_LINK          =  X_IS_LINK,
      DESTINATION      =  X_DESTINATION,
      PARAMETERS       =  X_PARAMETERS,
      DISPLAY_SEQ      =  X_DISPLAY_SEQ,
      ORIGINAL_SEQ     =  X_ORIGINAL_SEQ,
      IS_REMOVED       =  X_IS_REMOVED,
      LAST_UPDATE_DATE =  SYSDATE,
      LAST_UPDATED_BY  =  DECODE(X_OWNER,'SEED',1,0),
      COLUMN_NAME      =  X_COLUMN_NAME ,
      SEARCH_TYPE_ID   =  X_SEARCH_TYPE_ID
   WHERE          ID   =  X_ID;


END UPDATE_ROW;

PROCEDURE LOAD_ROW (
                   X_ID               IN NUMBER,
                   X_SEARCH_TYPE_ID   IN NUMBER,
                   X_LEVEL_ID         IN NUMBER,
                   X_LEVEL_VALUE      IN NUMBER,
                   X_HEADER           IN VARCHAR2,
                   X_COLUMN_NAME      IN VARCHAR2,
                   X_IS_MAIN          IN VARCHAR2,
                   X_IS_LINK          IN VARCHAR2,
                   X_DESTINATION      IN VARCHAR2,
                   X_PARAMETERS       IN VARCHAR2,
                   X_DISPLAY_SEQ      IN NUMBER,
                   X_ORIGINAL_SEQ     IN NUMBER,
                   X_IS_REMOVED       IN VARCHAR2,
                   X_OWNER            IN VARCHAR2
                   )


IS

CURSOR c_exists IS
   SELECT 1
   FROM  CSM_AD_SEARCH_RESULT_VIEW
   WHERE ID = X_ID;


l_exists NUMBER;

BEGIN



 OPEN c_exists;
 FETCH c_exists INTO l_exists;
 CLOSE c_exists;



 IF l_exists IS NULL THEN
   INSERT_ROW (
                X_ID,
                X_SEARCH_TYPE_ID,
                X_LEVEL_ID,
                X_LEVEL_VALUE,
                X_HEADER,
                X_COLUMN_NAME,
                X_IS_MAIN,
                X_IS_LINK,
                X_DESTINATION,
                X_PARAMETERS,
                X_DISPLAY_SEQ,
                X_ORIGINAL_SEQ,
                X_IS_REMOVED,
                X_OWNER
                 );

 ELSE

   UPDATE_ROW (
                 X_ID,
                 X_SEARCH_TYPE_ID,
                 X_LEVEL_ID,
                 X_LEVEL_VALUE,
                 X_HEADER,
                 X_COLUMN_NAME,
                 X_IS_MAIN,
                 X_IS_LINK,
                 X_DESTINATION,
                 X_PARAMETERS,
                 X_DISPLAY_SEQ,
                 X_ORIGINAL_SEQ,
                 X_IS_REMOVED,
                 X_OWNER
                 );
 END IF;

END LOAD_ROW;

END CSM_AD_SEARCH_RESULT_VIEW_PKG ;

/
