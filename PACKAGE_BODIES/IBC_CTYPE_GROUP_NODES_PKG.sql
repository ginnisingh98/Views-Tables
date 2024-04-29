--------------------------------------------------------
--  DDL for Package Body IBC_CTYPE_GROUP_NODES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBC_CTYPE_GROUP_NODES_PKG" AS
/* $Header: ibctcgnb.pls 120.1 2005/07/12 01:43:05 appldev ship $*/

-- MODIFICATION HISTORY
-- Person            Date        Comments
-- ---------         ------      ------------------------------------------
-- vicho	     08/07/2003  created


PROCEDURE INSERT_ROW (
  x_ROWID  OUT NOCOPY VARCHAR2,
  px_CTYPE_GROUP_NODE_ID IN OUT NOCOPY NUMBER,
  p_CONTENT_TYPE_CODE IN VARCHAR2,
  p_DIRECTORY_NODE_ID IN NUMBER,
  p_OBJECT_VERSION_NUMBER IN NUMBER,
  p_CREATION_DATE IN DATE,
  p_CREATED_BY IN NUMBER,
  p_LAST_UPDATE_DATE IN DATE,
  p_LAST_UPDATED_BY IN NUMBER,
  p_LAST_UPDATE_LOGIN IN NUMBER
) IS
  CURSOR C IS SELECT ROWID FROM Ibc_Ctype_Group_Nodes
    WHERE CTYPE_GROUP_NODE_ID = px_CTYPE_GROUP_NODE_ID;

  CURSOR c2 IS SELECT Ibc_Ctype_Group_Nodes_s1.NEXTVAL FROM dual;

BEGIN

  -- Primary key validation check
  IF ((px_CTYPE_GROUP_NODE_ID IS NULL) OR
      (px_CTYPE_GROUP_NODE_ID = FND_API.G_MISS_NUM))
  THEN
    OPEN c2;
    FETCH c2 INTO px_CTYPE_GROUP_NODE_ID;
    CLOSE c2;
  END IF;

INSERT INTO IBC_CTYPE_GROUP_NODES (
 CTYPE_GROUP_NODE_ID
 ,CONTENT_TYPE_CODE
 ,DIRECTORY_NODE_ID
 ,OBJECT_VERSION_NUMBER
 ,CREATION_DATE
 ,CREATED_BY
 ,LAST_UPDATE_DATE
 ,LAST_UPDATED_BY
 ,LAST_UPDATE_LOGIN
) VALUES (
    px_CTYPE_GROUP_NODE_ID,
    p_CONTENT_TYPE_CODE,
    p_DIRECTORY_NODE_ID,
    p_OBJECT_VERSION_NUMBER,
    DECODE(p_creation_date, FND_API.G_MISS_DATE, SYSDATE, NULL, SYSDATE,
           p_creation_date),
    DECODE(p_created_by, FND_API.G_MISS_NUM, FND_GLOBAL.user_id,
           NULL, FND_GLOBAL.user_id, p_created_by),
    DECODE(p_last_update_date, FND_API.G_MISS_DATE, SYSDATE, NULL, SYSDATE,
           p_last_update_date),
    DECODE(p_last_updated_by, FND_API.G_MISS_NUM, FND_GLOBAL.user_id,
           NULL, FND_GLOBAL.user_id, p_last_updated_by),
    DECODE(p_last_update_login, FND_API.G_MISS_NUM, FND_GLOBAL.login_id,
           NULL, FND_GLOBAL.login_id, p_last_update_login)
 );

  OPEN c;
  FETCH c INTO x_ROWID;
  IF (c%NOTFOUND) THEN
    CLOSE c;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c;

END INSERT_ROW;




PROCEDURE UPDATE_ROW (
p_CTYPE_GROUP_NODE_ID	IN  NUMBER,
p_CONTENT_TYPE_CODE	IN  VARCHAR2  DEFAULT  NULL,
p_DIRECTORY_NODE_ID     IN  NUMBER DEFAULT  NULL,
p_LAST_UPDATED_BY	IN  NUMBER  DEFAULT  NULL,
p_LAST_UPDATE_DATE	IN  DATE DEFAULT  NULL,
p_LAST_UPDATE_LOGIN	IN  NUMBER DEFAULT  NULL
) IS
BEGIN
  UPDATE IBC_CTYPE_GROUP_NODES SET
	CONTENT_TYPE_CODE = p_CONTENT_TYPE_CODE,
	DIRECTORY_NODE_ID = p_DIRECTORY_NODE_ID,
	last_update_date = DECODE(p_last_update_date, FND_API.G_MISS_DATE, SYSDATE,
                              NULL, SYSDATE, p_last_update_date),
	last_updated_by = DECODE(p_last_updated_by, FND_API.G_MISS_NUM,
                             FND_GLOBAL.user_id, NULL, FND_GLOBAL.user_id,
                             p_last_updated_by),
	last_update_login = DECODE(p_last_update_login, FND_API.G_MISS_NUM,
                             FND_GLOBAL.login_id, NULL, FND_GLOBAL.login_id,
                             p_last_update_login)
  WHERE CTYPE_GROUP_NODE_ID = p_CTYPE_GROUP_NODE_ID;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END UPDATE_ROW;


PROCEDURE DELETE_ROW (
  p_CTYPE_GROUP_NODE_ID IN  NUMBER
) IS
BEGIN
  DELETE FROM IBC_CTYPE_GROUP_NODES
  WHERE CTYPE_GROUP_NODE_ID = p_CTYPE_GROUP_NODE_ID;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END DELETE_ROW;



PROCEDURE LOAD_ROW(
  p_UPLOAD_MODE	  IN VARCHAR2,
  p_CTYPE_GROUP_NODE_ID   IN  NUMBER,
  p_CONTENT_TYPE_CODE     IN  VARCHAR2,
  p_DIRECTORY_NODE_ID     IN  NUMBER,
  p_OWNER		  IN  VARCHAR2,
  p_LAST_UPDATE_DATE IN VARCHAR2) IS
BEGIN
  DECLARE
    l_user_id    NUMBER := 0;
    l_last_update_date DATE;
    l_row_id     VARCHAR2(64);
    lx_CTYPE_GROUP_NODE_ID NUMBER := p_CTYPE_GROUP_NODE_ID;

    db_user_id    NUMBER := 0;
    db_last_update_date DATE;

  BEGIN
	--get last updated by user id
	l_user_id := FND_LOAD_UTIL.OWNER_ID(p_OWNER);

	--translate data type VARCHAR2 to DATE for last_update_date
	l_last_update_date := nvl(TO_DATE(p_last_update_date, 'YYYY/MM/DD'),SYSDATE);

	-- get updatedby  and update_date values if existing in db
	SELECT LAST_UPDATED_BY, LAST_UPDATE_DATE INTO db_user_id, db_last_update_date
	FROM IBC_CTYPE_GROUP_NODES
	WHERE CTYPE_GROUP_NODE_ID = p_CTYPE_GROUP_NODE_ID;

	IF (FND_LOAD_UTIL.UPLOAD_TEST(l_user_id, l_last_update_date,
		db_user_id, db_last_update_date, p_upload_mode )) THEN

		Ibc_Ctype_Group_Nodes_Pkg.UPDATE_ROW (
		   p_CTYPE_GROUP_NODE_ID		=>	p_CTYPE_GROUP_NODE_ID,
		   p_CONTENT_TYPE_CODE			=>	p_CONTENT_TYPE_CODE,
		   p_DIRECTORY_NODE_ID			=>	p_DIRECTORY_NODE_ID,
		   p_LAST_UPDATED_BY			=>	l_user_id,
		   p_LAST_UPDATE_DATE			=>	SYSDATE,
		   p_LAST_UPDATE_LOGIN			=>	l_user_id
		);
	END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
        Ibc_Ctype_Group_Nodes_Pkg.INSERT_ROW (
		x_ROWID				=>  l_row_id,
		px_CTYPE_GROUP_NODE_ID		=>  lx_CTYPE_GROUP_NODE_ID,
		p_CONTENT_TYPE_CODE		=>  p_CONTENT_TYPE_CODE,
		p_DIRECTORY_NODE_ID		=>  p_DIRECTORY_NODE_ID,
		p_OBJECT_VERSION_NUMBER         =>  1,
		p_CREATED_BY			=>  l_user_id,
		p_CREATION_DATE			=>  SYSDATE,
		p_LAST_UPDATED_BY		=>  l_user_id,
		p_LAST_UPDATE_DATE		=>  SYSDATE,
		p_LAST_UPDATE_LOGIN		=>  l_user_id
	);
  END;
END LOAD_ROW;

PROCEDURE LOAD_SEED_ROW (
  p_UPLOAD_MODE	  IN VARCHAR2,
  p_CTYPE_GROUP_NODE_ID   IN  NUMBER,
  p_CONTENT_TYPE_CODE     IN  VARCHAR2,
  p_DIRECTORY_NODE_ID     IN  NUMBER,
  p_OWNER		  IN  VARCHAR2,
  p_LAST_UPDATE_DATE IN VARCHAR2) IS
BEGIN
	IF (p_UPLOAD_MODE = 'NLS') THEN
		NULL;
	ELSE
		Ibc_Ctype_Group_Nodes_Pkg.LOAD_ROW (
		p_UPLOAD_MODE	 => p_UPLOAD_MODE,
		p_CTYPE_GROUP_NODE_ID => p_CTYPE_GROUP_NODE_ID,
		p_CONTENT_TYPE_CODE => p_CONTENT_TYPE_CODE,
		p_DIRECTORY_NODE_ID => p_DIRECTORY_NODE_ID,
		p_OWNER		=> p_OWNER,
		p_last_update_date => p_LAST_UPDATE_DATE);
	END IF;
END LOAD_SEED_ROW;

END Ibc_Ctype_Group_Nodes_Pkg;

/
