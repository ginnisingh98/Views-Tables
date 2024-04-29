--------------------------------------------------------
--  DDL for Package Body CSM_NEW_MESSAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_NEW_MESSAGES_PKG" AS
/* $Header: csmlnmgb.pls 120.2 2006/05/09 05:52:12 utekumal noship $ */

PROCEDURE INSERT_ROW (
                  X_MESSAGE_ID       NUMBER,
                  X_MESSAGE_NAME     VARCHAR2,
                  X_MESSAGE_TYPE     VARCHAR2,
                  X_MESSAGE_LENGTH   NUMBER,
                  X_UPDATABLE        VARCHAR2,
                  X_MESSAGE_TEXT     VARCHAR2,
                  X_DESCRIPTION      VARCHAR2,
		  X_OWNER	     VARCHAR2
		  )
IS

BEGIN
        --Insert into base table
	INSERT INTO CSM_NEW_MESSAGES
                (MESSAGE_ID,
                 MESSAGE_NAME,
                 MESSAGE_TYPE,
                 MESSAGE_LENGTH,
                 UPDATABLE,
                 CREATION_DATE,
                 CREATED_BY,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY)
          VALUES(X_MESSAGE_ID,
                 X_MESSAGE_NAME,
                 X_MESSAGE_TYPE,
                 X_MESSAGE_LENGTH,
                 X_UPDATABLE,
                 SYSDATE,
                 DECODE(X_OWNER,'SEED',1,0),
		 SYSDATE,
                 DECODE(X_OWNER,'SEED',1,0)
		 );


        --Insert into TL table
	INSERT INTO CSM_NEW_MESSAGES_TL
                (MESSAGE_ID,
                 MESSAGE_NAME,
                 MESSAGE_TEXT,
                 DESCRIPTION,
                 LANGUAGE,
                 SOURCE_LANGUAGE,
                 CREATION_DATE,
                 CREATED_BY,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY)
          SELECT X_MESSAGE_ID,
                 X_MESSAGE_NAME,
                 X_MESSAGE_TEXT,
                 X_DESCRIPTION,
                 L.LANGUAGE_CODE,
                 userenv('LANG'),
                 SYSDATE,
                 DECODE(X_OWNER,'SEED',1,0),
		 SYSDATE,
                 DECODE(X_OWNER,'SEED',1,0)
	  FROM   FND_LANGUAGES L
          WHERE  L.INSTALLED_FLAG in ('I', 'B')
          AND NOT EXISTS
                 (SELECT NULL
                   FROM CSM_NEW_MESSAGES_TL T
                   WHERE T.MESSAGE_NAME = X_MESSAGE_NAME);


END INSERT_ROW;

PROCEDURE ADD_LANGUAGE
IS
BEGIN
--deleting obsolete TL records
    DELETE FROM CSM_NEW_MESSAGES_TL TL
    WHERE NOT EXISTS (SELECT 1 FROM CSM_NEW_MESSAGES B
                      WHERE B.MESSAGE_ID=TL.MESSAGE_ID);

--no need for TL table update since we are taking care of it in UPDATE_ROW api itself.


--insert TL records for new language
    	INSERT INTO CSM_NEW_MESSAGES_TL
                (MESSAGE_ID,
                 MESSAGE_NAME,
                 MESSAGE_TEXT,
                 DESCRIPTION,
                 LANGUAGE,
                 SOURCE_LANGUAGE,
                 CREATION_DATE,
                 CREATED_BY,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY)
          SELECT B.MESSAGE_ID,
                 B.MESSAGE_NAME,
                 B.MESSAGE_TEXT,
                 B.DESCRIPTION,
                 L.LANGUAGE_CODE,
                 B.SOURCE_LANGUAGE,
                 B.CREATION_DATE,
                 B.CREATED_BY,
                 B.LAST_UPDATE_DATE,
                 B.LAST_UPDATED_BY
	      FROM   CSM_NEW_MESSAGES_TL B,
		         FND_LANGUAGES L
          WHERE B.LANGUAGE = userenv('LANG')
   	      AND L.INSTALLED_FLAG in ('I', 'B')
          AND NOT EXISTS
                 (SELECT NULL
                   FROM CSM_NEW_MESSAGES_TL T
                   WHERE T.MESSAGE_NAME = B.MESSAGE_NAME
				   AND   T.LANGUAGE = L.LANGUAGE_CODE);

END ADD_LANGUAGE;

PROCEDURE UPDATE_ROW(
                  X_MESSAGE_NAME     VARCHAR2,
                  X_MESSAGE_TYPE     VARCHAR2,
                  X_MESSAGE_LENGTH   NUMBER,
                  X_UPDATABLE        VARCHAR2,
                  X_MESSAGE_TEXT     VARCHAR2,
                  X_DESCRIPTION      VARCHAR2,
                  X_OWNER	     VARCHAR2
                  )

IS

BEGIN
        --Update base Table
	UPDATE CSM_NEW_MESSAGES
   	SET MESSAGE_TYPE     = X_MESSAGE_TYPE,
            MESSAGE_LENGTH   = X_MESSAGE_LENGTH,
            UPDATABLE        = X_UPDATABLE,
            LAST_UPDATED_BY  = DECODE(X_OWNER,'SEED',1,0),
            LAST_UPDATE_DATE = SYSDATE
	WHERE  MESSAGE_NAME = X_MESSAGE_NAME;

        --Update TL Table
	UPDATE CSM_NEW_MESSAGES_TL
   	SET MESSAGE_TEXT     = X_MESSAGE_TEXT,
            DESCRIPTION      = X_DESCRIPTION,
            SOURCE_LANGUAGE  = userenv('LANG'),
            LAST_UPDATED_BY  = DECODE(X_OWNER,'SEED',1,0),
            LAST_UPDATE_DATE = SYSDATE
	WHERE  MESSAGE_NAME = X_MESSAGE_NAME
	AND    userenv('LANG') in (LANGUAGE, SOURCE_LANGUAGE);

END UPDATE_ROW;


PROCEDURE LOAD_ROW(
                  X_MESSAGE_NAME     VARCHAR2,
                  X_MESSAGE_TYPE     VARCHAR2,
                  X_MESSAGE_LENGTH   NUMBER,
                  X_UPDATABLE        VARCHAR2,
                  X_MESSAGE_TEXT     VARCHAR2,
                  X_DESCRIPTION      VARCHAR2,
                  X_OWNER	     VARCHAR2
                  )
IS

CURSOR c_message_exists(b_message_name VARCHAR2) IS
 SELECT 1
 FROM  CSM_NEW_MESSAGES CNM
 WHERE CNM.MESSAGE_NAME = b_message_name;

 l_exists NUMBER;

 X_MESSAGE_ID NUMBER;

BEGIN

  OPEN c_message_exists(X_MESSAGE_NAME);
  FETCH c_message_exists INTO l_exists;
  CLOSE c_message_exists;

  IF l_exists IS NULL THEN

  SELECT CSM_NEW_MESSAGES_S.NEXTVAL into X_MESSAGE_ID FROM dual;

          Insert_Row(
                  X_MESSAGE_ID,
                  X_MESSAGE_NAME,
                  X_MESSAGE_TYPE,
                  X_MESSAGE_LENGTH,
                  X_UPDATABLE,
                  X_MESSAGE_TEXT,
                  X_DESCRIPTION,
		  X_OWNER );


  ELSE
          Update_Row(
                  X_MESSAGE_NAME,
                  X_MESSAGE_TYPE,
                  X_MESSAGE_LENGTH,
                  X_UPDATABLE,
                  X_MESSAGE_TEXT,
                  X_DESCRIPTION,
                  X_OWNER );

	END IF;


END LOAD_ROW;


PROCEDURE TRANSLATE_ROW(
                  X_MESSAGE_NAME     VARCHAR2,
                  X_MESSAGE_TYPE     VARCHAR2,
                  X_MESSAGE_LENGTH   NUMBER,
                  X_UPDATABLE        VARCHAR2,
                  X_MESSAGE_TEXT     VARCHAR2,
                  X_DESCRIPTION      VARCHAR2,
                  X_OWNER	     VARCHAR2
                  )
IS

CURSOR c_message_exists(b_message_name VARCHAR2) IS
 SELECT 1
 FROM  CSM_NEW_MESSAGES CNM
 WHERE CNM.MESSAGE_NAME = b_message_name;

 l_exists NUMBER;

BEGIN

  OPEN c_message_exists(X_MESSAGE_NAME);
  FETCH c_message_exists INTO l_exists;
  CLOSE c_message_exists;

  IF l_exists IS NOT NULL THEN

     UPDATE CSM_NEW_MESSAGES_TL SET
       MESSAGE_TEXT         = nvl(X_MESSAGE_TEXT, MESSAGE_TEXT),
       DESCRIPTION          = nvl(X_DESCRIPTION, DESCRIPTION),
       LAST_UPDATE_DATE     = SYSDATE,
       LAST_UPDATED_BY      = DECODE(X_OWNER,'SEED',1,0),
       SOURCE_LANGUAGE      = userenv('LANG')
     WHERE MESSAGE_NAME     = X_MESSAGE_NAME
     AND userenv('LANG') IN (LANGUAGE, SOURCE_LANGUAGE);

  END IF;

END TRANSLATE_ROW;


PROCEDURE INSERT_ROW_PERZ (
                  X_MESSAGE_ID       NUMBER,
                  X_MESSAGE_NAME     VARCHAR2,
                  X_LEVEL_ID         NUMBER,
                  X_LEVEL_VALUE      NUMBER,
                  X_LANGUAGE         VARCHAR2,
                  X_MESSAGE_TEXT     VARCHAR2,
                  X_DESCRIPTION      VARCHAR2,
		  X_OWNER	     VARCHAR2
		  )

IS

errmsg varchar2(4000);

BEGIN
        --Insert into Perz table
	INSERT INTO CSM_NEW_MESSAGES_PERZ
                (MESSAGE_ID,
                 MESSAGE_NAME,
                 LEVEL_ID,
                 LEVEL_VALUE,
                 LANGUAGE,
                 MESSAGE_TEXT,
                 DESCRIPTION,
		 CREATION_DATE,
                 CREATED_BY,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY)
          VALUES(X_MESSAGE_ID,
                 X_MESSAGE_NAME,
                 X_LEVEL_ID,
                 X_LEVEL_VALUE,
                 X_LANGUAGE,
                 X_MESSAGE_TEXT,
                 X_DESCRIPTION,
                 SYSDATE,
                 DECODE(X_OWNER,'SEED',1,0),
		 SYSDATE,
                 DECODE(X_OWNER,'SEED',1,0)
		 );


END INSERT_ROW_PERZ;


PROCEDURE UPDATE_ROW_PERZ(
                  X_MESSAGE_NAME     VARCHAR2,
                  X_LEVEL_ID         NUMBER,
                  X_LEVEL_VALUE      NUMBER,
                  X_LANGUAGE         VARCHAR2,
                  X_MESSAGE_TEXT     VARCHAR2,
                  X_DESCRIPTION      VARCHAR2,
		  X_OWNER	     VARCHAR2
                  )

IS

BEGIN
        --Update base Table
	UPDATE CSM_NEW_MESSAGES_PERZ
   	SET MESSAGE_TEXT     = X_MESSAGE_TEXT,
            DESCRIPTION      = X_DESCRIPTION,
            LAST_UPDATED_BY  = DECODE(X_OWNER,'SEED',1,0),
            LAST_UPDATE_DATE = SYSDATE
	WHERE  MESSAGE_NAME = X_MESSAGE_NAME
	AND    LEVEL_ID     = X_LEVEL_ID
	AND    LEVEL_VALUE  = X_LEVEL_VALUE
	AND    LANGUAGE     = X_LANGUAGE;

END UPDATE_ROW_PERZ;


PROCEDURE LOAD_ROW_PERZ(
		  X_MESSAGE_NAME     VARCHAR2,
                  X_LEVEL_ID         NUMBER,
                  X_LEVEL_VALUE      NUMBER,
                  X_LANGUAGE         VARCHAR2,
                  X_MESSAGE_TEXT     VARCHAR2,
                  X_DESCRIPTION      VARCHAR2,
                  X_OWNER	     VARCHAR2
                  )
IS

CURSOR c_message_exists(b_message_name VARCHAR2, b_level_id NUMBER, b_level_value NUMBER, b_language VARCHAR2) IS
 SELECT 1
 FROM  CSM_NEW_MESSAGES_PERZ PERZ
 WHERE PERZ.MESSAGE_NAME = b_message_name
 AND PERZ.LEVEL_ID = b_level_id
 AND PERZ.LEVEL_VALUE = b_level_value
 AND PERZ.LANGUAGE = b_language;


CURSOR c_get_msg_id(b_message_name VARCHAR2) IS
 SELECT MESSAGE_ID
 FROM  CSM_NEW_MESSAGES CNM
 WHERE CNM.MESSAGE_NAME = b_message_name;

 l_exists NUMBER;

 X_MESSAGE_ID NUMBER;

BEGIN

  OPEN c_message_exists(X_MESSAGE_NAME, X_LEVEL_ID, X_LEVEL_VALUE, X_LANGUAGE);
  FETCH c_message_exists INTO l_exists;
  CLOSE c_message_exists;

  OPEN c_get_msg_id(X_MESSAGE_NAME);
  FETCH c_get_msg_id INTO X_MESSAGE_ID;
  CLOSE c_get_msg_id;

  IF X_MESSAGE_ID IS NULL THEN
    RETURN;
  END IF;

  IF l_exists IS NULL THEN

          INSERT_ROW_PERZ(
                  X_MESSAGE_ID,
                  X_MESSAGE_NAME,
                  X_LEVEL_ID,
                  X_LEVEL_VALUE,
                  X_LANGUAGE,
                  X_MESSAGE_TEXT,
                  X_DESCRIPTION,
		  X_OWNER );


  ELSE
          UPDATE_ROW_PERZ(
                  X_MESSAGE_NAME,
                  X_LEVEL_ID,
                  X_LEVEL_VALUE,
                  X_LANGUAGE,
                  X_MESSAGE_TEXT,
                  X_DESCRIPTION,
                  X_OWNER );
  END IF;

END LOAD_ROW_PERZ;


END CSM_NEW_MESSAGES_PKG;

/
