--------------------------------------------------------
--  DDL for Package Body IBC_STYLESHEETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBC_STYLESHEETS_PKG" AS
/* $Header: ibctstyb.pls 120.2 2005/08/08 13:58:14 appldev ship $*/

-- Purpose: Table Handler for Ibc_Stylesheets table.

-- MODIFICATION HISTORY
-- Person            Date        Comments
-- ---------         ------      ------------------------------------------
-- Sri Rangarajan    01/06/2002      Created Package
-- vicho	     11/05/2002     Remove G_MISS defaulting on UPDATE_ROW
-- Sharma	     07/04/2005  Modified LOAD_ROW, TRANSLATE_ROW and created
--				 LOAD_SEED_ROW for R12 LCT standards bug 4411674
-- Sri.rangarajan    08/08/2005  Added the logic to not override the default stylesheet
--				 set by the user.

PROCEDURE INSERT_ROW (
  x_ROWID OUT NOCOPY VARCHAR2,
  p_CONTENT_TYPE_CODE IN VARCHAR2,
  p_CONTENT_ITEM_ID IN NUMBER,
  p_OBJECT_VERSION_NUMBER IN NUMBER,
  p_default_stylesheet_flag IN VARCHAR2,
  p_CREATION_DATE IN DATE,
  p_CREATED_BY IN NUMBER,
  p_LAST_UPDATE_DATE IN DATE,
  p_LAST_UPDATED_BY IN NUMBER,
  p_LAST_UPDATE_LOGIN IN NUMBER
) IS
  CURSOR C IS SELECT ROWID FROM IBC_STYLESHEETS
    WHERE CONTENT_TYPE_CODE = p_CONTENT_TYPE_CODE
    AND CONTENT_ITEM_ID = p_CONTENT_ITEM_ID
    ;
BEGIN
  INSERT INTO IBC_STYLESHEETS (
    CONTENT_TYPE_CODE,
    CONTENT_ITEM_ID,
	default_stylesheet_flag,
    OBJECT_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) VALUES (
    p_CONTENT_TYPE_CODE,
    p_CONTENT_ITEM_ID,
	p_default_stylesheet_flag,
    p_OBJECT_VERSION_NUMBER,
    DECODE(p_creation_date, Fnd_Api.G_MISS_DATE, SYSDATE, NULL, SYSDATE,
           p_creation_date),
    DECODE(p_created_by, Fnd_Api.G_MISS_NUM, Fnd_Global.user_id,
           NULL, Fnd_Global.user_id, p_created_by),
    DECODE(p_last_update_date, Fnd_Api.G_MISS_DATE, SYSDATE, NULL, SYSDATE,
           p_last_update_date),
    DECODE(p_last_updated_by, Fnd_Api.G_MISS_NUM, Fnd_Global.user_id,
           NULL, Fnd_Global.user_id, p_last_updated_by),
    DECODE(p_last_update_login, Fnd_Api.G_MISS_NUM, Fnd_Global.login_id,
           NULL, Fnd_Global.login_id, p_last_update_login)
  );

  OPEN c;
  FETCH c INTO x_ROWID;
  IF (c%NOTFOUND) THEN
    CLOSE c;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c;

END INSERT_ROW;

PROCEDURE LOCK_ROW (
  p_CONTENT_TYPE_CODE IN VARCHAR2,
  p_CONTENT_ITEM_ID IN NUMBER,
  p_OBJECT_VERSION_NUMBER IN NUMBER
) IS
  CURSOR c IS SELECT
      OBJECT_VERSION_NUMBER
    FROM IBC_STYLESHEETS
    WHERE CONTENT_TYPE_CODE = p_CONTENT_TYPE_CODE
    AND CONTENT_ITEM_ID = p_CONTENT_ITEM_ID
    FOR UPDATE OF CONTENT_TYPE_CODE NOWAIT;
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
  IF (    (recinfo.OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER)
  ) THEN
    NULL;
  ELSE
    Fnd_Message.set_name('FND', 'FORM_RECORD_CHANGED');
    App_Exception.raise_exception;
  END IF;

END LOCK_ROW;

PROCEDURE UPDATE_ROW (
  p_CONTENT_ITEM_ID    IN  NUMBER,
  p_CONTENT_TYPE_CODE    IN  VARCHAR2,
  p_default_stylesheet_flag IN VARCHAR2,
  p_LAST_UPDATED_BY    IN  NUMBER,
  p_LAST_UPDATE_DATE    IN  DATE,
  p_LAST_UPDATE_LOGIN    IN  NUMBER,
  p_OBJECT_VERSION_NUMBER    IN  NUMBER
) IS
BEGIN
  UPDATE IBC_STYLESHEETS SET
   CONTENT_TYPE_CODE = DECODE(p_CONTENT_TYPE_CODE,Fnd_Api.G_MISS_CHAR,NULL,NULL,CONTENT_TYPE_CODE,p_CONTENT_TYPE_CODE),
   CONTENT_ITEM_ID = DECODE(p_CONTENT_ITEM_ID,Fnd_Api.G_MISS_NUM,NULL,NULL,CONTENT_ITEM_ID,p_CONTENT_ITEM_ID),
   default_stylesheet_flag = DECODE(p_default_stylesheet_flag,Fnd_Api.G_MISS_CHAR,'F',NULL,default_stylesheet_flag,p_default_stylesheet_flag),
   OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1,
   last_update_date = DECODE(p_last_update_date, Fnd_Api.G_MISS_DATE, SYSDATE,
                              NULL, SYSDATE, p_last_update_date),
   last_updated_by = DECODE(p_last_updated_by, Fnd_Api.G_MISS_NUM,
                             Fnd_Global.user_id, NULL, Fnd_Global.user_id,
                             p_last_updated_by),
   last_update_login = DECODE(p_last_update_login, Fnd_Api.G_MISS_NUM,
                             Fnd_Global.login_id, NULL, Fnd_Global.login_id,
                             p_last_update_login)
  WHERE CONTENT_TYPE_CODE = p_CONTENT_TYPE_CODE
  AND CONTENT_ITEM_ID = p_CONTENT_ITEM_ID
  AND object_version_number = DECODE(p_object_version_number,
                                       Fnd_Api.G_MISS_NUM,object_version_number,
                                       NULL,object_version_number,
                                       p_object_version_number);

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END UPDATE_ROW;

PROCEDURE DELETE_ROW (
  p_CONTENT_TYPE_CODE IN VARCHAR2,
  p_CONTENT_ITEM_ID IN NUMBER
) IS
BEGIN

  DELETE FROM IBC_STYLESHEETS
  WHERE CONTENT_TYPE_CODE = p_CONTENT_TYPE_CODE
  AND CONTENT_ITEM_ID = p_CONTENT_ITEM_ID;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END DELETE_ROW;

PROCEDURE LOAD_SEED_ROW (
  p_UPLOAD_MODE	  IN VARCHAR2,
  p_CONTENT_ITEM_ID	 NUMBER,
  p_CONTENT_TYPE_CODE	  	  VARCHAR2,
  p_default_stylesheet_flag	  VARCHAR2, --DEFAULT 'F',
  p_OWNER 	VARCHAR2,
  p_LAST_UPDATE_DATE IN VARCHAR2) IS
BEGIN
	IF (p_UPLOAD_MODE = 'NLS') THEN
		NULL;
	ELSE
		IBC_STYLESHEETS_PKG.LOAD_ROW (
			p_UPLOAD_MODE => p_UPLOAD_MODE,
			p_CONTENT_TYPE_CODE	=> p_CONTENT_TYPE_CODE,
			p_CONTENT_ITEM_ID	=> p_CONTENT_ITEM_ID,
			p_default_stylesheet_flag => p_default_stylesheet_flag,
			p_OWNER	=>p_OWNER,
			p_LAST_UPDATE_DATE => p_LAST_UPDATE_DATE );
	END IF;
END;


PROCEDURE LOAD_ROW (
  p_UPLOAD_MODE	  IN VARCHAR2,
  p_CONTENT_ITEM_ID	 NUMBER,
  p_CONTENT_TYPE_CODE	  	  VARCHAR2,
  p_default_stylesheet_flag	  VARCHAR2, --DEFAULT 'F',
  p_OWNER 	VARCHAR2,
  p_LAST_UPDATE_DATE IN VARCHAR2) IS

  l_default_stylesheet_flag	  CHAR(1);

  BEGIN

  l_default_stylesheet_flag := 	p_default_stylesheet_flag;


	  DECLARE
	    l_user_id    NUMBER := 0;
	    l_row_id     VARCHAR2(64);
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
		FROM IBC_STYLESHEETS
		WHERE CONTENT_TYPE_CODE = p_CONTENT_TYPE_CODE
		AND CONTENT_ITEM_ID = p_CONTENT_ITEM_ID
		AND object_version_number = DECODE(object_version_number,
						       Fnd_Api.G_MISS_NUM,object_version_number,
						       NULL,object_version_number,
						       object_version_number);
		DECLARE
		l_temp INTEGER;

		BEGIN

		     l_temp := 0;

		     IF (l_default_stylesheet_flag ='T') THEN

			-- if the user has set some other stylesheet
			-- as the default stylesheet. Don't override the
			-- user settings
			--
			SELECT count(*) INTO l_temp from IBC_STYLESHEETS
			WHERE content_type_code = p_CONTENT_TYPE_CODE
			and   CONTENT_ITEM_ID <> p_CONTENT_ITEM_ID
			and   default_stylesheet_flag = 'T';

			If l_temp <> 0 THEN
			   l_default_stylesheet_flag :='F';
			END IF;

		      END IF;
		EXCEPTION
		   when others THEN
			NULL;
		END;

		IF (FND_LOAD_UTIL.UPLOAD_TEST(l_user_id, l_last_update_date,
			db_user_id, db_last_update_date, p_upload_mode )) THEN

			UPDATE_ROW (
			  p_CONTENT_ITEM_ID	=>	p_CONTENT_ITEM_ID,
			  p_CONTENT_TYPE_CODE	=>	p_CONTENT_TYPE_CODE,
			  p_default_stylesheet_flag => nvl(l_default_stylesheet_flag,FND_API.G_MISS_CHAR),
			  p_LAST_UPDATED_BY    	 => l_user_id,
			  p_LAST_UPDATE_DATE     => SYSDATE,
			  p_LAST_UPDATE_LOGIN    => 0,
			  p_OBJECT_VERSION_NUMBER	=> NULL );
		END IF;

	  EXCEPTION
	    WHEN NO_DATA_FOUND THEN
	       INSERT_ROW (
		  X_ROWID => l_row_id,
		  p_CONTENT_ITEM_ID =>	p_CONTENT_ITEM_ID,
		  p_CONTENT_TYPE_CODE	=>	p_CONTENT_TYPE_CODE,
		  p_default_stylesheet_flag => 	p_default_stylesheet_flag,
		  p_OBJECT_VERSION_NUMBER	=>	1,
		  p_CREATION_DATE => SYSDATE,
		  p_CREATED_BY 	=> l_user_id,
		  p_LAST_UPDATE_DATE => SYSDATE,
		  p_LAST_UPDATED_BY => l_user_id,
		  p_LAST_UPDATE_LOGIN => 0);
	END;
END LOAD_ROW;

END Ibc_Stylesheets_Pkg;

/
