--------------------------------------------------------
--  DDL for Package Body CSM_PAGE_PERZ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_PAGE_PERZ_PKG" AS
/* $Header: csmlppb.pls 120.0 2005/11/29 23:49:42 utekumal noship $ */

PROCEDURE INSERT_ROW
                   (
                   X_FILE_NAME                VARCHAR2,
                   X_PAGE_NAME                VARCHAR2,
                   X_UIX_PAGE_SERVER_VERSION  VARCHAR2,
                   X_UIX_PAGE_CLIENT_VERSION  VARCHAR2,
                   X_MESSAGE_NAME             VARCHAR2,
                   X_OWNER                    VARCHAR2
                   )
IS

BEGIN
        --Insert
	INSERT INTO CSM_PAGE_PERZ
                (PAGE_PERZ_ID,
		 FILE_NAME,
                 PAGE_NAME,
                 UIX_PAGE_SERVER_VERSION,
                 UIX_PAGE_CLIENT_VERSION,
                 MESSAGE_NAME,
                 LAST_UPDATED_BY,
                 CREATION_DATE,
                 CREATED_BY,
                 LAST_UPDATE_DATE)
          VALUES(CSM_PAGE_PERZ_S.NEXTVAL,
                 X_FILE_NAME,
                 X_PAGE_NAME,
                 X_UIX_PAGE_SERVER_VERSION,
                 X_UIX_PAGE_CLIENT_VERSION,
                 X_MESSAGE_NAME,
                 DECODE(X_OWNER,'SEED',1,0),
                 SYSDATE,
                 DECODE(X_OWNER,'SEED',1,0),
                 SYSDATE);

END Insert_Row;

PROCEDURE UPDATE_ROW(
                   X_FILE_NAME                VARCHAR2,
                   X_PAGE_NAME                VARCHAR2,
                   X_UIX_PAGE_SERVER_VERSION  VARCHAR2,
                   X_UIX_PAGE_CLIENT_VERSION  VARCHAR2,
                   X_MESSAGE_NAME             VARCHAR2,
                   X_OWNER                    VARCHAR2
                    )

IS

BEGIN
        --Update
	UPDATE CSM_PAGE_PERZ
   	SET PAGE_NAME                = X_PAGE_NAME,
            UIX_PAGE_SERVER_VERSION  = X_UIX_PAGE_SERVER_VERSION,
            UIX_PAGE_CLIENT_VERSION  = X_UIX_PAGE_CLIENT_VERSION,
            MESSAGE_NAME             = X_MESSAGE_NAME,
            LAST_UPDATED_BY          = DECODE(X_OWNER,'SEED',1,0),
            LAST_UPDATE_DATE         = SYSDATE
	WHERE  FILE_NAME = X_FILE_NAME;

END Update_Row;

PROCEDURE LOAD_ROW(
                   X_PAGE_PERZ_ID             VARCHAR2,
                   X_FILE_NAME                VARCHAR2,
                   X_PAGE_NAME                VARCHAR2,
                   X_UIX_PAGE_SERVER_VERSION  VARCHAR2,
                   X_UIX_PAGE_CLIENT_VERSION  VARCHAR2,
                   X_MESSAGE_NAME             VARCHAR2,
                   X_OWNER                    VARCHAR2
                  )
IS


CURSOR c_page_exists(b_file_name VARCHAR2) IS
 SELECT 1
 FROM  CSM_PAGE_PERZ CPP
 WHERE CPP.FILE_NAME      = b_file_name;

 l_exists NUMBER;

BEGIN

  OPEN c_page_exists(X_FILE_NAME);
  FETCH c_page_exists INTO l_exists;
  CLOSE c_page_exists;

  IF l_exists IS NULL THEN

          Insert_Row(
                   X_FILE_NAME,
                   X_PAGE_NAME,
                   X_UIX_PAGE_SERVER_VERSION,
                   X_UIX_PAGE_CLIENT_VERSION,
                   X_MESSAGE_NAME,
                   X_OWNER);


  ELSE
          Update_Row(
                   X_FILE_NAME,
                   X_PAGE_NAME,
                   X_UIX_PAGE_SERVER_VERSION,
                   X_UIX_PAGE_CLIENT_VERSION,
                   X_MESSAGE_NAME,
                   X_OWNER);

	END IF;


END load_row;

END ;

/
