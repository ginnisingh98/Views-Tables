--------------------------------------------------------
--  DDL for Package Body BSC_SYS_IMAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_SYS_IMAGES_PKG" AS
/* $Header: BSCSYSIB.pls 120.0 2005/06/01 16:33:57 appldev noship $ */

PROCEDURE UPDATE_ROW
(
    X_FILE_NAME               IN VARCHAR2,
    X_DESCRIPTION             IN VARCHAR2,
    X_WIDTH                   IN NUMBER,
    X_HEIGHT                  IN NUMBER,
    X_LAST_UPDATE_DATE        IN VARCHAR2,
    X_LAST_UPDATED_BY         IN NUMBER,
    X_LAST_UPDATE_LOGIN       IN NUMBER
) IS
   -- L_BLOB     BLOB;
   -- L_BFILE    BFILE;
BEGIN
  UPDATE_ROW(
    X_FILE_NAME               => X_FILE_NAME,
    X_DESCRIPTION             => X_DESCRIPTION,
    X_WIDTH                   => X_WIDTH,
    X_HEIGHT                  => X_HEIGHT,
    X_MIME_TYPE               => '',
    X_LAST_UPDATE_DATE        => X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY         => X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN       => X_LAST_UPDATE_LOGIN
  );
END UPDATE_ROW;



--sawu: bug#4028672: overloaded UPDATE_ROW to take in MIME_TYPE
PROCEDURE UPDATE_ROW
(
    X_FILE_NAME               IN VARCHAR2,
    X_DESCRIPTION             IN VARCHAR2,
    X_WIDTH                   IN NUMBER,
    X_HEIGHT                  IN NUMBER,
    X_MIME_TYPE               IN VARCHAR2,
    X_LAST_UPDATE_DATE        IN VARCHAR2,
    X_LAST_UPDATED_BY         IN NUMBER,
    X_LAST_UPDATE_LOGIN       IN NUMBER
) IS
   -- L_BLOB     BLOB;
   -- L_BFILE    BFILE;
BEGIN
    UPDATE  BSC_SYS_IMAGES
    SET     DESCRIPTION            =   X_DESCRIPTION,
            WIDTH                  =   X_WIDTH,
            HEIGHT                 =   X_HEIGHT,
            MIME_TYPE              =   X_MIME_TYPE,
            LAST_UPDATE_DATE       =   NVL(TO_DATE(X_LAST_UPDATE_DATE, 'YYYY/MM/DD'), SYSDATE),
            LAST_UPDATED_BY        =   X_LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN      =   X_LAST_UPDATE_LOGIN,
            FILE_BODY              =   EMPTY_BLOB()
    WHERE   FILE_NAME              =   X_FILE_NAME
    AND     LAST_UPDATE_DATE      <=   TO_DATE(X_LAST_UPDATE_DATE, 'YYYY/MM/DD');
   -- RETURNING FILE_BODY INTO L_BLOB;
   -- IF (NOT SQL%NOTFOUND) THEN
   --     L_BFILE := BFILENAME( 'OA_MEDIA', X_FILE_NAME);
   --     DBMS_LOB.FILEOPEN( L_BFILE );
   --     DBMS_LOB.LOADFROMFILE(L_BLOB, L_BFILE, DBMS_LOB.GETLENGTH( L_BFILE));
   --     DBMS_LOB.FILECLOSE( L_BFILE );
   -- END IF;
END UPDATE_ROW;



PROCEDURE INSERT_ROW
(
    X_IMAGE_ID                  IN  NUMBER,
    X_FILE_NAME                 IN  VARCHAR2,
    X_DESCRIPTION               IN  VARCHAR2,
    X_WIDTH                     IN  NUMBER,
    X_HEIGHT                    IN  NUMBER,
    X_CREATED_BY                IN  NUMBER,
    X_LAST_UPDATED_BY           IN  NUMBER,
    X_LAST_UPDATE_LOGIN         IN  NUMBER
) IS
BEGIN
  INSERT_ROW(
    X_IMAGE_ID                  => X_IMAGE_ID,
    X_FILE_NAME                 => X_FILE_NAME,
    X_DESCRIPTION               => X_DESCRIPTION,
    X_WIDTH                     => X_WIDTH,
    X_HEIGHT                    => X_HEIGHT,
    X_MIME_TYPE                 => '',
    X_CREATED_BY                => X_CREATED_BY,
    X_LAST_UPDATED_BY           => X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN         => X_LAST_UPDATE_LOGIN
  );
END INSERT_ROW;



--sawu: bug#4028672: overloaded INSERT_ROW to take in MIME_TYPE
PROCEDURE INSERT_ROW
(
    X_IMAGE_ID                  IN  NUMBER,
    X_FILE_NAME                 IN  VARCHAR2,
    X_DESCRIPTION               IN  VARCHAR2,
    X_WIDTH                     IN  NUMBER,
    X_HEIGHT                    IN  NUMBER,
    X_MIME_TYPE                 IN  VARCHAR2,
    X_CREATED_BY                IN  NUMBER,
    X_LAST_UPDATED_BY           IN  NUMBER,
    X_LAST_UPDATE_LOGIN         IN  NUMBER
) IS
    CURSOR C IS SELECT ROWID FROM BSC_SYS_IMAGES WHERE IMAGE_ID = X_IMAGE_ID;
    L_ROWID    VARCHAR2(100);
   -- L_BLOB     BLOB;
   -- L_BFILE    BFILE;
    BEGIN
        INSERT INTO BSC_SYS_IMAGES
        (
            IMAGE_ID,
            FILE_NAME,
            DESCRIPTION,
            FILE_BODY,
            WIDTH,
            HEIGHT,
            MIME_TYPE,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN
        )
        VALUES
        (
            X_IMAGE_ID,
            X_FILE_NAME,
            X_DESCRIPTION,
            EMPTY_BLOB(),
            X_WIDTH,
            X_HEIGHT,
            X_MIME_TYPE,
            SYSDATE,
            X_CREATED_BY,
            SYSDATE,
            X_LAST_UPDATED_BY,
            0
        );
       -- RETURNING FILE_BODY INTO L_BLOB;

       -- L_BFILE := BFILENAME( 'OA_MEDIA', X_FILE_NAME);
       -- DBMS_LOB.FILEOPEN( L_BFILE );
       -- DBMS_LOB.LOADFROMFILE(L_BLOB, L_BFILE, DBMS_LOB.GETLENGTH( L_BFILE));
       -- DBMS_LOB.FILECLOSE( L_BFILE );

    OPEN C;
        FETCH C INTO L_ROWID;
        IF (C%NOTFOUND) THEN
            CLOSE C;
            RAISE NO_DATA_FOUND;
        END IF;
    CLOSE C;
END INSERT_ROW;

END BSC_SYS_IMAGES_PKG;

/
