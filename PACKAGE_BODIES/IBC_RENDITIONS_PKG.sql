--------------------------------------------------------
--  DDL for Package Body IBC_RENDITIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBC_RENDITIONS_PKG" AS
/* $Header: ibctrenb.pls 120.2 2005/07/29 15:06:15 appldev ship $ */


-- MODIFICATION HISTORY
-- Person            Date        Comments
-- ---------         ------      ------------------------------------------
-- vicho	     11/05/2002     Remove G_MISS defaulting on UPDATE_ROW
-- SHARMA 	     07/04/2005	     Modified LOAD_ROW, TRANSLATE_ROW and created
-- 			             LOAD_SEED_ROW for R12 LCT standards bug 4411674


PROCEDURE INSERT_ROW (
  Px_rowid 		IN OUT NOCOPY VARCHAR2,
  Px_RENDITION_ID	IN OUT NOCOPY NUMBER,
  P_OBJECT_VERSION_NUMBER IN NUMBER,
  P_LANGUAGE 			  IN VARCHAR2,
  P_FILE_ID 			  IN NUMBER,
  P_FILE_NAME 			  IN VARCHAR2,
  P_CITEM_VERSION_ID 	  IN NUMBER,
  P_mime_type			  IN VARCHAR2,
  p_CREATION_DATE 		  IN DATE,
  p_CREATED_BY 			  IN NUMBER,
  p_LAST_UPDATE_DATE 	  IN DATE,
  p_LAST_UPDATED_BY 	  IN NUMBER,
  p_LAST_UPDATE_LOGIN 	  IN NUMBER
) IS
  CURSOR C IS SELECT ROWID FROM IBC_RENDITIONS
    WHERE RENDITION_ID = Px_RENDITION_ID;
  CURSOR c2 IS SELECT ibc_renditions_s1.NEXTVAL FROM dual;
BEGIN

  -- Primary key validation check

  IF ((Px_RENDITION_ID IS NULL) OR
      (Px_RENDITION_ID = Fnd_Api.G_MISS_NUM))
  THEN
    OPEN c2;
    FETCH c2 INTO px_rendition_ID;
    CLOSE c2;
  END IF;

  INSERT INTO IBC_RENDITIONS (
    FILE_ID,
    FILE_NAME,
	mime_type,
    RENDITION_ID,
    CITEM_VERSION_ID,
	LANGUAGE,
	object_version_number,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) VALUES (
    P_FILE_ID,
    P_FILE_NAME,
	p_mime_type,
    Px_RENDITION_ID,
    P_CITEM_VERSION_ID,
	p_LANGUAGE,
	DECODE(p_object_version_number,NULL,1,p_object_version_number),
    DECODE(p_creation_date, NULL, SYSDATE,
           p_creation_date),
    DECODE(p_created_by, NULL, Fnd_Global.user_id, p_created_by),
    DECODE(p_last_update_date, NULL, SYSDATE,
           p_last_update_date),
    DECODE(p_last_updated_by,
           NULL, Fnd_Global.user_id, p_last_updated_by),
    DECODE(p_last_update_login,
           NULL, Fnd_Global.login_id, p_last_update_login)
		   );

  OPEN c;
  FETCH c INTO Px_rowid;
  IF (c%NOTFOUND) THEN
    CLOSE c;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c;

END INSERT_ROW;

PROCEDURE LOCK_ROW (
  P_RENDITION_ID IN NUMBER,
  P_OBJECT_VERSION_NUMBER IN NUMBER,
  P_FILE_ID IN NUMBER,
  P_FILE_NAME IN VARCHAR2,
  P_CITEM_VERSION_ID IN NUMBER,
  P_mime_type IN VARCHAR2
) IS
  CURSOR c IS SELECT
      OBJECT_VERSION_NUMBER,
      FILE_ID,
      FILE_NAME,
      CITEM_VERSION_ID
    FROM IBC_RENDITIONS
    WHERE RENDITION_ID = P_RENDITION_ID
    FOR UPDATE OF RENDITION_ID NOWAIT;
  recinfo c%ROWTYPE;

BEGIN
  OPEN c;
  FETCH c INTO recinfo;
  IF (c%NOTFOUND) THEN
    CLOSE c;
    Fnd_Message.set_name('FND', 'FORM_RECORD_DELETED');
    App_Exception.raise_exception;
  END IF;
  CLOSE c;
  IF (    (recinfo.OBJECT_VERSION_NUMBER = P_OBJECT_VERSION_NUMBER)
      AND (recinfo.FILE_ID = P_FILE_ID)
      AND ((recinfo.FILE_NAME = P_FILE_NAME)
           OR ((recinfo.FILE_NAME IS NULL) AND (P_FILE_NAME IS NULL)))
      AND (recinfo.CITEM_VERSION_ID = P_CITEM_VERSION_ID)
  ) THEN
    NULL;
  ELSE
    Fnd_Message.set_name('FND', 'FORM_RECORD_CHANGED');
    App_Exception.raise_exception;
  END IF;

END LOCK_ROW;

PROCEDURE UPDATE_ROW (
  P_RENDITION_ID		IN NUMBER,
  P_OBJECT_VERSION_NUMBER	IN NUMBER,
  P_LANGUAGE 			IN VARCHAR2,
  P_FILE_ID			IN NUMBER,
  P_FILE_NAME			IN VARCHAR2,
  P_CITEM_VERSION_ID		IN NUMBER,
  P_mime_type			IN VARCHAR2,
  P_LAST_UPDATE_DATE		IN DATE,
  P_LAST_UPDATED_BY		IN NUMBER,
  P_LAST_UPDATE_LOGIN		IN NUMBER
) IS
BEGIN
  UPDATE IBC_RENDITIONS SET
  FILE_ID 		  = DECODE(P_FILE_ID,NULL,FILE_ID,P_FILE_ID),
  FILE_NAME 		  = DECODE(P_FILE_NAME,NULL,FILE_NAME,P_FILE_NAME),
  MIME_TYPE 		  = DECODE(P_MIME_TYPE,NULL,MIME_TYPE,P_MIME_TYPE),
  CITEM_VERSION_ID 	  = DECODE(P_CITEM_VERSION_ID,NULL,CITEM_VERSION_ID,P_CITEM_VERSION_ID),
  LANGUAGE		  = DECODE(P_LANGUAGE,NULL,LANGUAGE,P_LANGUAGE),
  object_version_number = object_version_number + 1,
  last_update_date = DECODE(p_last_update_date,
                              NULL, SYSDATE, p_last_update_date),
  last_updated_by = DECODE(p_last_updated_by, NULL, Fnd_Global.user_id,
                             p_last_updated_by),
  last_update_login = DECODE(p_last_update_login, NULL, Fnd_Global.login_id,
                             p_last_update_login)
  WHERE RENDITION_ID 	  = P_RENDITION_ID
  AND object_version_number = DECODE(p_object_version_number,
                                       NULL,object_version_number,
                                       p_object_version_number);

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END UPDATE_ROW;

PROCEDURE DELETE_ROW (
  P_RENDITION_ID IN NUMBER
) IS
BEGIN

  DELETE FROM IBC_RENDITIONS
  WHERE RENDITION_ID = P_RENDITION_ID;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END DELETE_ROW;



PROCEDURE LOAD_ROW (
  P_UPLOAD_MODE		IN VARCHAR2,
  P_RENDITION_ID	IN NUMBER,
  P_LANGUAGE 		IN VARCHAR2,
  P_FILE_ID		IN NUMBER,
  P_FILE_NAME		IN VARCHAR2,
  P_CITEM_VERSION_ID	IN NUMBER,
  P_mime_type		IN VARCHAR2,
  p_OWNER 		IN VARCHAR2,
  p_LAST_UPDATE_DATE	IN VARCHAR2) IS

	l_user_id NUMBER := 0;
	lx_row_id VARCHAR2(240);
	lx_rendition_id NUMBER := p_rendition_id;
	l_FILE_NAME	VARCHAR2(100) := p_file_name;

	l_last_update_date DATE;

	db_user_id    NUMBER := 0;
	db_last_update_date DATE;

  BEGIN
	--get last updated by user id
	l_user_id := FND_LOAD_UTIL.OWNER_ID(p_OWNER);

	--translate data type VARCHAR2 to DATE for last_update_date
	l_last_update_date := nvl(TO_DATE(p_last_update_date, 'YYYY/MM/DD'),SYSDATE);

	-- get updatedby  and update_date values if existing in db
	SELECT LAST_UPDATED_BY, LAST_UPDATE_DATE INTO db_user_id, db_last_update_date
	FROM IBC_RENDITIONS
        WHERE RENDITION_ID = P_RENDITION_ID;


	IF l_file_name IS NULL THEN
	     SELECT attachment_file_name
	     INTO l_FILE_NAME
	     FROM ibc_citem_versions_tl
	     WHERE attachment_file_id=p_file_id
	     AND ROWNUM=1;
	END IF;

	IF (FND_LOAD_UTIL.UPLOAD_TEST(l_user_id, l_last_update_date,
		db_user_id, db_last_update_date, p_upload_mode )) THEN
	    UPDATE_ROW (
	      P_RENDITION_ID => p_RENDITION_ID
	      ,P_OBJECT_VERSION_NUMBER	=> NULL
	      ,P_LANGUAGE 	=> p_LANGUAGE
	      ,P_FILE_ID	=> p_FILE_ID
	      ,P_FILE_NAME	=> l_FILE_NAME
	      ,P_CITEM_VERSION_ID => p_CITEM_VERSION_ID
	      ,P_mime_type => p_mime_type
	      ,P_LAST_UPDATE_DATE => SYSDATE
	      ,P_LAST_UPDATED_BY => l_user_id
	      ,P_LAST_UPDATE_LOGIN	=> 0
	    );
	END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      INSERT_ROW (
         Px_rowid 				    => lx_row_id
        ,Px_RENDITION_ID		    => lx_rendition_id
        ,P_OBJECT_VERSION_NUMBER	=> 1
        ,P_LANGUAGE 				=> P_LANGUAGE
        ,P_FILE_ID 					=> p_FILE_ID
      	,P_FILE_NAME				=> l_FILE_NAME
        ,P_CITEM_VERSION_ID 		=> P_CITEM_VERSION_ID
      	,P_mime_type				=> p_mime_type
        ,p_CREATION_DATE 			=> SYSDATE
        ,p_CREATED_BY 				=> l_user_id
        ,p_LAST_UPDATE_DATE 		=> SYSDATE
        ,p_LAST_UPDATED_BY 			=> l_user_id
        ,p_LAST_UPDATE_LOGIN 		=> 0
      );

END LOAD_ROW;

PROCEDURE LOAD_SEED_ROW (
  P_UPLOAD_MODE		IN VARCHAR2,
  P_RENDITION_ID	IN NUMBER,
  P_LANGUAGE 		IN VARCHAR2,
  P_FILE_ID		IN NUMBER,
  P_FILE_NAME		IN VARCHAR2,
  P_CITEM_VERSION_ID	IN NUMBER,
  P_mime_type		IN VARCHAR2,
  p_OWNER 		IN VARCHAR2,
  p_LAST_UPDATE_DATE	IN VARCHAR2
) IS
BEGIN
	IF (p_UPLOAD_MODE = 'NLS') THEN
		NULL;
	ELSE
		Ibc_Renditions_Pkg.LOAD_ROW(
		  P_UPLOAD_MODE	=> P_UPLOAD_MODE,
		  P_RENDITION_ID => P_RENDITION_ID,
		  P_LANGUAGE => P_LANGUAGE,
		  P_FILE_ID => P_FILE_ID,
		  P_FILE_NAME => P_FILE_NAME,
		  P_CITEM_VERSION_ID => P_CITEM_VERSION_ID,
		  P_mime_type  => P_mime_type,
		  p_OWNER => p_OWNER,
		  p_LAST_UPDATE_DATE => p_LAST_UPDATE_DATE
		);

	END IF;

END LOAD_SEED_ROW;


END Ibc_Renditions_Pkg;

/
