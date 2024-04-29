--------------------------------------------------------
--  DDL for Package Body GR_SAFETY_PHRASES_TL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GR_SAFETY_PHRASES_TL_PKG" AS
/*$Header: GRHISPTB.pls 120.1 2006/06/16 21:41:50 pbamb noship $*/
PROCEDURE Insert_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_safety_phrase_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_source_language IN VARCHAR2,
				  p_safety_phrase_description IN VARCHAR2,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_date IN DATE,
				  p_last_update_login IN NUMBER,
				  x_rowid OUT NOCOPY  VARCHAR2,
				  x_return_status OUT NOCOPY  VARCHAR2,
				  x_oracle_error OUT NOCOPY  NUMBER,
				  x_msg_data OUT NOCOPY  VARCHAR2)
	IS
/*   Alpha Variables */

L_RETURN_STATUS	VARCHAR2(1) := 'S';
L_KEY_EXISTS 	VARCHAR2(1);
L_MSG_DATA 		VARCHAR2(2000);
L_ROWID 		VARCHAR2(18);
L_MSG_TOKEN 	VARCHAR2(100);

/*   Number Variables */

L_ORACLE_ERROR	  NUMBER;
/*   Exceptions */

FOREIGN_KEY_ERROR EXCEPTION;
ITEM_EXISTS_ERROR EXCEPTION;
ROW_MISSING_ERROR EXCEPTION;

/* Declare cursors */


BEGIN

/*     Initialization Routine */

   SAVEPOINT Insert_Row;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;

/*	  Now call the check foreign key procedure */

   Check_Foreign_Keys
			     (p_safety_phrase_code,
				  p_language,
				  p_source_language,
				  p_safety_phrase_description,
				  l_return_status,
				  l_oracle_error,
				  l_msg_data);
   IF l_return_status <> 'S' THEN
      RAISE Foreign_Key_Error;
   END IF;

/* 	   Now check the primary key doesn't already exist */

   Check_Primary_Key
   	   	   		 (p_safety_phrase_code,
				  p_language,
				  'F',
				  l_rowid,
				  l_key_exists);

   IF FND_API.To_Boolean(l_key_exists) THEN
   	  RAISE Item_Exists_Error;
   END IF;

   INSERT INTO gr_safety_phrases_tl
   		  	     (safety_phrase_code,
				  language,
				  source_lang,
				  safety_phrase_description,
				  created_by,
				  creation_date,
				  last_updated_by,
				  last_update_date,
				  last_update_login)
          VALUES
		         (p_safety_phrase_code,
				  p_language,
				  p_source_language,
				  p_safety_phrase_description,
				  p_created_by,
				  p_creation_date,
				  p_last_updated_by,
				  p_last_update_date,
				  p_last_update_login);

/*   Now get the row id of the inserted record */

   Check_Primary_Key
   	   	   		 (p_safety_phrase_code,
				  p_language,
				  'F',
				  l_rowid,
				  l_key_exists);

   IF FND_API.To_Boolean(l_key_exists) THEN
   	  x_rowid := l_rowid;
   ELSE
   	  RAISE Row_Missing_Error;
   END IF;

/*   Check the commit flag and if set, then commit the work. */

   IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
   END IF;

EXCEPTION

   WHEN Foreign_Key_Error THEN
      ROLLBACK TO SAVEPOINT Insert_Row;
	  x_return_status := l_return_status;
	  x_oracle_error := l_oracle_error;
      FND_MESSAGE.SET_NAME('GR',
                           'GR_FOREIGN_KEY_ERROR');
      FND_MESSAGE.SET_TOKEN('TEXT',
         		            l_msg_data,
            			    FALSE);
      IF FND_API.To_Boolean(p_called_by_form) THEN
	     APP_EXCEPTION.Raise_Exception;
	  ELSE
	     x_msg_data := FND_MESSAGE.Get;
	  END IF;

   WHEN Item_Exists_Error THEN
      ROLLBACK TO SAVEPOINT Insert_Row;
	  l_msg_token := p_safety_phrase_code || ' ' || p_language;
	  x_return_status := 'E';
	  x_oracle_error := APP_EXCEPTION.Get_Code;
      FND_MESSAGE.SET_NAME('GR',
                           'GR_RECORD_EXISTS');
      FND_MESSAGE.SET_TOKEN('CODE',
         		            l_msg_token,
            			    FALSE);
      IF FND_API.To_Boolean(p_called_by_form) THEN
	     APP_EXCEPTION.Raise_Exception;
	  ELSE
	     x_msg_data := FND_MESSAGE.Get;
	  END IF;

   WHEN Row_Missing_Error THEN
      ROLLBACK TO SAVEPOINT Insert_Row;
	  l_msg_token := p_safety_phrase_code || ' ' || p_language;
	  x_return_status := 'E';
	  x_oracle_error := APP_EXCEPTION.Get_Code;
      FND_MESSAGE.SET_NAME('GR',
                           'GR_NO_RECORD_INSERTED');
      FND_MESSAGE.SET_TOKEN('CODE',
         		            l_msg_token,
            			    FALSE);
      IF FND_API.To_Boolean(p_called_by_form) THEN
	     APP_EXCEPTION.Raise_Exception;
	  ELSE
	     x_msg_data := FND_MESSAGE.Get;
	  END IF;

   WHEN OTHERS THEN
      ROLLBACK TO SAVEPOINT Insert_Row;
	  l_msg_token := p_safety_phrase_code || ' ' || p_language;
	  x_return_status := 'U';
	  x_oracle_error := SQLCODE;
	  l_msg_data := SUBSTR(SQLERRM, 1, 200);
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_UNEXPECTED_ERROR');
	  FND_MESSAGE.SET_TOKEN('TEXT',
	                        l_msg_token,
	                        FALSE);
      IF FND_API.To_Boolean(p_called_by_form) THEN
	     APP_EXCEPTION.Raise_Exception;
	  ELSE
	     x_msg_data := FND_MESSAGE.Get;
	  END IF;

END Insert_Row;

PROCEDURE Update_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_rowid IN VARCHAR2,
				  p_safety_phrase_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_source_language IN VARCHAR2,
				  p_safety_phrase_description IN VARCHAR2,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_date IN DATE,
				  p_last_update_login IN NUMBER,
				  x_return_status OUT NOCOPY  VARCHAR2,
				  x_oracle_error OUT NOCOPY  NUMBER,
				  x_msg_data OUT NOCOPY  VARCHAR2)
   IS

/*   Alpha Variables */

L_RETURN_STATUS	  VARCHAR2(1) := 'S';
L_MSG_DATA		  VARCHAR2(2000);
L_MSG_TOKEN		  VARCHAR2(100);

/*   Number Variables */

L_ORACLE_ERROR	  NUMBER;

/*   Exceptions */

FOREIGN_KEY_ERROR EXCEPTION;
ROW_MISSING_ERROR EXCEPTION;

BEGIN

/*       Initialization Routine */

   SAVEPOINT Update_Row;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;
   l_msg_token := p_safety_phrase_code || ' ' || p_language;

/*	  Now call the check foreign key procedure */

   Check_Foreign_Keys
			     (p_safety_phrase_code,
				  p_language,
				  p_source_language,
				  p_safety_phrase_description,
				  l_return_status,
				  l_oracle_error,
				  l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Foreign_Key_Error;
   ELSE
      UPDATE gr_safety_phrases_tl
	  SET	 safety_phrase_code 	 	 	 = p_safety_phrase_code,
	  		 language						 = p_language,
			 source_lang					 = p_source_language,
			 safety_phrase_description		 = p_safety_phrase_description,
			 created_by						 = p_created_by,
			 creation_date					 = p_creation_date,
			 last_updated_by				 = p_last_updated_by,
			 last_update_date				 = p_last_update_date,
			 last_update_login				 = p_last_update_login
	  WHERE  rowid = p_rowid;
	  IF SQL%NOTFOUND THEN
	     RAISE Row_Missing_Error;
	  END IF;
   END IF;

/*   Check the commit flag and if set, then commit the work. */

   IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
   END IF;

EXCEPTION

   WHEN Foreign_Key_Error THEN
      ROLLBACK TO SAVEPOINT Update_Row;
	  x_return_status := l_return_status;
	  x_oracle_error := l_oracle_error;
      FND_MESSAGE.SET_NAME('GR',
                           'GR_FOREIGN_KEY_ERROR');
      FND_MESSAGE.SET_TOKEN('TEXT',
         		            l_msg_data,
            			    FALSE);
      IF FND_API.To_Boolean(p_called_by_form) THEN
	     APP_EXCEPTION.Raise_Exception;
	  ELSE
	     x_msg_data := FND_MESSAGE.Get;
	  END IF;

   WHEN Row_Missing_Error THEN
      ROLLBACK TO SAVEPOINT Update_Row;
	  x_return_status := 'E';
	  x_oracle_error := APP_EXCEPTION.Get_Code;
      FND_MESSAGE.SET_NAME('GR',
                           'GR_NO_RECORD_INSERTED');
      FND_MESSAGE.SET_TOKEN('CODE',
         		            l_msg_token,
            			    FALSE);
      IF FND_API.To_Boolean(p_called_by_form) THEN
	     APP_EXCEPTION.Raise_Exception;
	  ELSE
	     x_msg_data := FND_MESSAGE.Get;
	  END IF;

   WHEN OTHERS THEN
      ROLLBACK TO SAVEPOINT Update_Row;
	  x_return_status := 'U';
	  x_oracle_error := SQLCODE;
	  l_msg_data := SUBSTR(SQLERRM, 1, 200);
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_UNEXPECTED_ERROR');
	  FND_MESSAGE.SET_TOKEN('TEXT',
	                        l_msg_token,
	                        FALSE);
      IF FND_API.To_Boolean(p_called_by_form) THEN
	     APP_EXCEPTION.Raise_Exception;
	  ELSE
	     x_msg_data := FND_MESSAGE.Get;
	  END IF;

END Update_Row;

PROCEDURE Add_Language
	             (p_commit IN VARCHAR2,
	              p_called_by_form IN VARCHAR2,
				  p_safety_phrase_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  x_return_status OUT NOCOPY  VARCHAR2,
				  x_oracle_error OUT NOCOPY  NUMBER,
				  x_msg_data OUT NOCOPY  VARCHAR2)
 IS

/*   Alpha Variables */

L_RETURN_STATUS	  	VARCHAR2(1) := 'S';
L_MSG_DATA		  	VARCHAR2(2000);
L_MSG_TOKEN		  	VARCHAR2(100);
L_BASE_DESC			VARCHAR2(240);
L_LANGUAGE		  	VARCHAR2(4);
L_CREATION_DATE	 	DATE;
L_LAST_UPDATE_DATE	DATE;

/*   Number Variables */

L_ORACLE_ERROR	  	NUMBER;
L_CREATED_BY		NUMBER;
L_LAST_UPDATED_BY	NUMBER;
L_LAST_UPDATE_LOGIN	NUMBER;

/*	Exceptions */

LANGUAGE_MISSING_ERROR	EXCEPTION;


/*   Cursors */

CURSOR c_get_descs
 IS
   SELECT	spt.safety_phrase_description,
            spt.created_by,
			spt.creation_date,
			spt.last_updated_by,
			spt.last_update_date,
			spt.last_update_login
   FROM	    gr_safety_phrases_tl spt
   WHERE	spt.safety_phrase_code = p_safety_phrase_code
   AND		spt.language = l_language;
PhraseDesc				c_get_descs%ROWTYPE;

CURSOR c_get_installed_languages
 IS
   SELECT	lng.language_code
   FROM	 	fnd_languages lng
   WHERE	lng.installed_flag IN ('I', 'B');
InstLang				c_get_installed_languages%ROWTYPE;


BEGIN

/*	Initialization Routine */

   SAVEPOINT Add_Language;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;
   l_msg_token := p_safety_phrase_code || ' ' || p_language;

 /* Remove translations with no base row */

  delete from GR_SAFETY_PHRASES_TL T
  where not exists
    (select NULL
    from GR_SAFETY_PHRASES_B B
    where B.SAFETY_PHRASE_CODE = T.SAFETY_PHRASE_CODE
    );

/* Redefault translations from the source language  */

   update gr_safety_phrases_tl t set (
    safety_phrase_description ) =
    ( select
      B.SAFETY_PHRASE_DESCRIPTION
      from GR_SAFETY_PHRASES_TL B
      where B.SAFETY_PHRASE_CODE = T.SAFETY_PHRASE_CODE
      and B.LANGUAGE = T.SOURCE_LANG)
   where (
      T.SAFETY_PHRASE_CODE,
      T.LANGUAGE
   ) in (select
         SUBT.SAFETY_PHRASE_CODE,
         SUBT.LANGUAGE
         from GR_SAFETY_PHRASES_TL SUBB, GR_SAFETY_PHRASES_TL SUBT
         where SUBB.SAFETY_PHRASE_CODE = SUBT.SAFETY_PHRASE_CODE
         and SUBB.LANGUAGE = SUBT.SOURCE_LANG
         and (SUBB.SAFETY_PHRASE_DESCRIPTION <> SUBT.SAFETY_PHRASE_DESCRIPTION
          or (SUBB.SAFETY_PHRASE_DESCRIPTION is null and SUBT.SAFETY_PHRASE_DESCRIPTION is not null)
          or (SUBB.SAFETY_PHRASE_DESCRIPTION is not null and SUBT.SAFETY_PHRASE_DESCRIPTION is null)
  ));



/*	Open the language cursor and get the description entered from the
**	user environment variable.
*/
   l_language := p_language;
   OPEN c_get_descs;
   FETCH c_get_descs INTO PhraseDesc;
   IF c_get_descs%NOTFOUND THEN
      CLOSE c_get_descs;
      RAISE Language_Missing_Error;
   ELSE
      l_base_desc := PhraseDesc.safety_phrase_description;
	  l_created_by := PhraseDesc.created_by;
	  l_creation_date := PhraseDesc.creation_date;
	  l_last_updated_by := PhraseDesc.last_updated_by;
	  l_last_update_date := PhraseDesc.last_update_date;
	  l_last_update_login := PhraseDesc.last_update_login;
      CLOSE c_get_descs;
   END IF;

/*	Read fnd_languages for the installed and base languages.
**	For those that are found, read the safety phrase tl table.
**	If there isn't a record in the table for that language then
**	insert it and go on to the next.
*/
   OPEN c_get_installed_languages;
   FETCH c_get_installed_languages INTO InstLang;
   IF c_get_installed_languages%FOUND THEN
      WHILE c_get_installed_languages%FOUND LOOP
	     IF InstLang.language_code <> p_language THEN
		    l_language := InstLang.language_code;
			OPEN c_get_descs;
			FETCH c_get_descs INTO PhraseDesc;
			IF c_get_descs%NOTFOUND THEN
			   CLOSE c_get_descs;
			   INSERT INTO gr_safety_phrases_tl
						(safety_phrase_code,
						 language,
						 source_lang,
						 safety_phrase_description,
						 created_by,
						 creation_date,
						 last_updated_by,
						 last_update_date,
						 last_update_login)
				   VALUES
				        (p_safety_phrase_code,
						 l_language,
						 p_language,
						 l_base_desc,
						 l_created_by,
						 l_creation_date,
						 l_last_updated_by,
						 l_last_update_date,
						 l_last_update_login);
			ELSE
			   CLOSE c_get_descs;
			END IF;
		 END IF;
		 FETCH c_get_installed_languages INTO InstLang;
	  END LOOP;
   END IF;
   CLOSE c_get_installed_languages;

   IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
   END IF;

EXCEPTION

   WHEN Language_Missing_Error THEN
      ROLLBACK TO SAVEPOINT Add_Language;
	  x_return_status := 'E';
	  x_oracle_error := APP_EXCEPTION.Get_Code;
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_RECORD_NOT_FOUND');
	  FND_MESSAGE.SET_TOKEN('CODE',
	                        l_msg_token,
	                        FALSE);
      IF FND_API.To_Boolean(p_called_by_form) THEN
	     APP_EXCEPTION.Raise_Exception;
	  ELSE
	     x_msg_data := FND_MESSAGE.Get;
	  END IF;

   WHEN OTHERS THEN
      ROLLBACK TO SAVEPOINT Add_Language;
	  x_return_status := 'U';
	  x_oracle_error := SQLCODE;
	  l_msg_data := SUBSTR(SQLERRM, 1, 200);
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_UNEXPECTED_ERROR');
	  FND_MESSAGE.SET_TOKEN('TEXT',
	                        l_msg_token,
	                        FALSE);
      IF FND_API.To_Boolean(p_called_by_form) THEN
	     APP_EXCEPTION.Raise_Exception;
	  ELSE
	     x_msg_data := FND_MESSAGE.Get;
	  END IF;

END Add_Language;

PROCEDURE Lock_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_rowid IN VARCHAR2,
				  p_safety_phrase_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_source_language IN VARCHAR2,
				  p_safety_phrase_description IN VARCHAR2,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_date IN DATE,
				  p_last_update_login IN NUMBER,
				  x_return_status OUT NOCOPY  VARCHAR2,
				  x_oracle_error OUT NOCOPY  NUMBER,
				  x_msg_data OUT NOCOPY  VARCHAR2)
   IS

/*  Alpha Variables */

L_RETURN_STATUS	  VARCHAR2(1) := 'S';
L_MSG_DATA		  VARCHAR2(2000);
L_MSG_TOKEN		  VARCHAR2(100);

/*  Number Variables */

L_ORACLE_ERROR	  NUMBER;

/*   Exceptions */

NO_DATA_FOUND_ERROR 		EXCEPTION;
RECORD_CHANGED_ERROR	 	EXCEPTION;

/*   Define the cursors */

CURSOR c_lock_safety_tl
 IS
   SELECT	last_update_date
   FROM		gr_safety_phrases_tl
   WHERE	rowid = p_rowid
   FOR UPDATE NOWAIT;
LockSafetyRcd	  c_lock_safety_tl%ROWTYPE;
BEGIN

/*      Initialization Routine */

   SAVEPOINT Lock_Row;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;
   l_msg_token := p_safety_phrase_code || ' ' || p_language;

/*	   Now lock the record */

   OPEN c_lock_safety_tl;
   FETCH c_lock_safety_tl INTO LockSafetyRcd;
   IF c_lock_safety_tl%NOTFOUND THEN
	  CLOSE c_lock_safety_tl;
	  RAISE No_Data_Found_Error;
   END IF;
   CLOSE c_lock_safety_tl;

   IF LockSafetyRcd.last_update_date <> p_last_update_date THEN
     RAISE RECORD_CHANGED_ERROR;
   END IF;

   IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
   END IF;

EXCEPTION

   WHEN No_Data_Found_Error THEN
      ROLLBACK TO SAVEPOINT Lock_Row;
	  x_return_status := 'E';
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_RECORD_NOT_FOUND');
	  FND_MESSAGE.SET_TOKEN('CODE',
	                        l_msg_token,
							FALSE);
      IF FND_API.To_Boolean(p_called_by_form) THEN
	     APP_EXCEPTION.Raise_Exception;
	  ELSE
	     x_msg_data := FND_MESSAGE.Get;
	  END IF;

   WHEN RECORD_CHANGED_ERROR THEN
     ROLLBACK TO SAVEPOINT Lock_Row;
     X_return_status := 'E';
     FND_MESSAGE.SET_NAME('FND',
	                  'FORM_RECORD_CHANGED');
     IF FND_API.To_Boolean(p_called_by_form) THEN
       APP_EXCEPTION.Raise_Exception;
     ELSE
       x_msg_data := FND_MESSAGE.Get;
     END IF;
   WHEN APP_EXCEPTION.RECORD_LOCK_EXCEPTION THEN
      ROLLBACK TO SAVEPOINT Lock_Row;
	  x_return_status := 'L';
	  x_oracle_error := APP_EXCEPTION.Get_Code;
          IF NOT (FND_API.To_Boolean(p_called_by_form)) THEN
            FND_MESSAGE.SET_NAME('GR',
	                       'GR_ROW_IS_LOCKED');
            x_msg_data := FND_MESSAGE.Get;
          END IF;


   WHEN OTHERS THEN
      ROLLBACK TO SAVEPOINT Lock_Row;
	  x_return_status := 'U';
	  x_oracle_error := SQLCODE;
	  l_msg_data := SUBSTR(SQLERRM, 1, 200);
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_UNEXPECTED_ERROR');
	  FND_MESSAGE.SET_TOKEN('TEXT',
	                        l_msg_token,
	                        FALSE);
      IF FND_API.To_Boolean(p_called_by_form) THEN
	     APP_EXCEPTION.Raise_Exception;
	  ELSE
	     x_msg_data := FND_MESSAGE.Get;
	  END IF;

END Lock_Row;

PROCEDURE Delete_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_rowid IN VARCHAR2,
				  p_safety_phrase_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_source_language IN VARCHAR2,
				  p_safety_phrase_description IN VARCHAR2,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_date IN DATE,
				  p_last_update_login IN NUMBER,
				  x_return_status OUT NOCOPY  VARCHAR2,
				  x_oracle_error OUT NOCOPY  NUMBER,
				  x_msg_data OUT NOCOPY  VARCHAR2)
   IS

/*   Alpha Variables */

L_RETURN_STATUS	  VARCHAR2(1) := 'S';
L_MSG_DATA		  VARCHAR2(2000);
L_MSG_TOKEN		  VARCHAR2(100);
L_CALLED_BY_FORM  VARCHAR2(1);

/*   Number Variables */

L_ORACLE_ERROR	  NUMBER;

/*   Exceptions */

CHECK_INTEGRITY_ERROR 		EXCEPTION;
ROW_MISSING_ERROR	  		EXCEPTION;
PRAGMA EXCEPTION_INIT(Row_Missing_Error,100);

/*	Define the cursors */

BEGIN

/*   Initialization Routine */

   SAVEPOINT Delete_Row;
   x_return_status := 'S';
   l_called_by_form := 'F';
   x_oracle_error := 0;
   x_msg_data := NULL;
   l_msg_token := p_safety_phrase_code || ' ' || p_language;

/*  Now call the check integrity procedure */

   Check_Integrity
			     (l_called_by_form,
			      p_safety_phrase_code,
				  p_language,
				  p_source_language,
				  p_safety_phrase_description,
				  l_return_status,
				  l_oracle_error,
				  l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Check_Integrity_Error;
   END IF;

   DELETE FROM gr_safety_phrases_tl
   WHERE  	   rowid = p_rowid;

/*   Check the commit flag and if set, then commit the work. */

   IF FND_API.TO_Boolean(p_commit) THEN
      COMMIT WORK;
   END IF;

EXCEPTION

   WHEN Check_Integrity_Error THEN
      ROLLBACK TO SAVEPOINT Delete_Row;
	  x_return_status := l_return_status;
	  x_oracle_error := l_oracle_error;
	  x_msg_data := l_msg_data;
      IF FND_API.To_Boolean(p_called_by_form) THEN
	     APP_EXCEPTION.Raise_Exception;
	  ELSE
	     x_msg_data := FND_MESSAGE.Get;
	  END IF;

   WHEN Row_Missing_Error THEN
      ROLLBACK TO SAVEPOINT Delete_Row;
	  x_return_status := 'E';
	  x_oracle_error := APP_EXCEPTION.Get_Code;
      FND_MESSAGE.SET_NAME('GR',
                           'GR_RECORD_NOT_FOUND');
      FND_MESSAGE.SET_TOKEN('CODE',
         		            l_msg_token,
            			    FALSE);
      IF FND_API.To_Boolean(p_called_by_form) THEN
	     APP_EXCEPTION.Raise_Exception;
	  ELSE
	     x_msg_data := FND_MESSAGE.Get;
	  END IF;

   WHEN OTHERS THEN
      ROLLBACK TO SAVEPOINT Delete_Row;
	  x_return_status := 'U';
	  x_oracle_error := SQLCODE;
	  l_msg_data := SUBSTR(SQLERRM, 1, 200);
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_UNEXPECTED_ERROR');
	  FND_MESSAGE.SET_TOKEN('TEXT',
	                        l_msg_token,
	                        FALSE);
      IF FND_API.To_Boolean(p_called_by_form) THEN
	     APP_EXCEPTION.Raise_Exception;
	  ELSE
	     x_msg_data := FND_MESSAGE.Get;
	  END IF;

END Delete_Row;

PROCEDURE Delete_Rows
	             (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
	              p_safety_phrase_code IN VARCHAR2,
				  x_return_status OUT NOCOPY  VARCHAR2,
				  x_oracle_error OUT NOCOPY  NUMBER,
				  x_msg_data OUT NOCOPY  VARCHAR2)
  IS

/*   Alpha Variables */

L_RETURN_STATUS	  VARCHAR2(1) := 'S';
L_MSG_DATA		  VARCHAR2(2000);
L_MSG_TOKEN       VARCHAR2(100);

/*   Number Variables */

L_ORACLE_ERROR	  NUMBER;

/*   Define the cursors */

BEGIN

/*   Initialization Routine */

   SAVEPOINT Delete_Rows;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;
   l_msg_token := p_safety_phrase_code;

   DELETE FROM gr_safety_phrases_tl
   WHERE 	   safety_phrase_code = p_safety_phrase_code;

   IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
   END IF;

EXCEPTION

   WHEN OTHERS THEN
      ROLLBACK TO SAVEPOINT Delete_Rows;
	  x_return_status := 'U';
	  x_oracle_error := SQLCODE;
	  l_msg_data := SUBSTR(SQLERRM, 1, 200);
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_UNEXPECTED_ERROR');
	  FND_MESSAGE.SET_TOKEN('TEXT',
	                        l_msg_token,
	                        FALSE);
      IF FND_API.To_Boolean(p_called_by_form) THEN
	     APP_EXCEPTION.Raise_Exception;
	  ELSE
	     x_msg_data := FND_MESSAGE.Get;
	  END IF;

END Delete_Rows;

PROCEDURE Check_Foreign_Keys
	   			 (p_safety_phrase_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_source_language IN VARCHAR2,
				  p_safety_phrase_description IN VARCHAR2,
				  x_return_status OUT NOCOPY  VARCHAR2,
				  x_oracle_error OUT NOCOPY  NUMBER,
				  x_msg_data OUT NOCOPY  VARCHAR2)
   IS

/*   Alpha Variables */

L_RETURN_STATUS	  VARCHAR2(1) := 'S';
L_MSG_DATA		  VARCHAR2(2000);
L_MSG_TOKEN       VARCHAR2(100);
L_LANGUAGE_CODE   VARCHAR2(4);

/*   Number Variables */

L_ORACLE_ERROR	  NUMBER;

/*	Error Definitions */

ROW_MISSING_ERROR	EXCEPTION;

/*   Define the cursors */

CURSOR c_get_language
 IS
   SELECT 	lng.language_code
   FROM		fnd_languages lng
   WHERE	lng.language_code = l_language_code;
LangRecord			c_get_language%ROWTYPE;

BEGIN

/*   Initialization Routine */

   SAVEPOINT Check_Foreign_Keys;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;
   l_msg_token := p_safety_phrase_code || ' ' || p_language;

/*   Check the language codes */

   l_language_code := p_language;
   OPEN c_get_language;
   FETCH c_get_language INTO LangRecord;
   IF c_get_language%NOTFOUND THEN
      CLOSE c_get_language;
	  l_msg_token := l_language_code;
	  RAISE Row_Missing_Error;
   END IF;
   CLOSE c_get_language;

   l_language_code := p_source_language;
   OPEN c_get_language;
   FETCH c_get_language INTO LangRecord;
   IF c_get_language%NOTFOUND THEN
      CLOSE c_get_language;
	  l_msg_token := l_language_code;
	  RAISE Row_Missing_Error;
   END IF;
   CLOSE c_get_language;

EXCEPTION

   WHEN Row_Missing_Error THEN
      ROLLBACK TO SAVEPOINT Check_Foreign_Keys;
	  x_return_status := 'E';
	  x_oracle_error := APP_EXCEPTION.Get_Code;
      FND_MESSAGE.SET_NAME('GR',
                           'GR_RECORD_NOT_FOUND');
      FND_MESSAGE.SET_TOKEN('CODE',
         		            l_msg_token,
            			    FALSE);
	  x_msg_data := FND_MESSAGE.Get;

   WHEN OTHERS THEN
      ROLLBACK TO SAVEPOINT Check_Foreign_Keys;
	  x_return_status := 'U';
	  x_oracle_error := SQLCODE;
	  l_msg_data := SUBSTR(SQLERRM, 1, 200);
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_UNEXPECTED_ERROR');
	  FND_MESSAGE.SET_TOKEN('TEXT',
	                        l_msg_token,
	                        FALSE);
	  x_msg_data := FND_MESSAGE.Get;

END Check_Foreign_Keys;

PROCEDURE Check_Integrity
	   			 (p_called_by_form IN VARCHAR2,
	   			  p_safety_phrase_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_source_language IN VARCHAR2,
				  p_safety_phrase_description IN VARCHAR2,
				  x_return_status OUT NOCOPY  VARCHAR2,
				  x_oracle_error OUT NOCOPY  NUMBER,
				  x_msg_data OUT NOCOPY  VARCHAR2)
   IS

/*   Alpha Variables */

L_RETURN_STATUS	  VARCHAR2(1) := 'S';
L_MSG_DATA		  VARCHAR2(2000);
L_CODE_BLOCK	  VARCHAR2(30);

/*   Number Variables */

L_ORACLE_ERROR	  NUMBER;
L_RECORD_COUNT	  NUMBER;

/*	 Exceptions */

INSTALLED_LANGUAGE_ERROR	EXCEPTION;

/*	 Define the Cursors */

CURSOR c_get_language_code
 IS
   SELECT	lng.installed_flag
   FROM		fnd_languages lng
   WHERE	lng.language_code = p_language
   AND		lng.installed_flag IN ('B', 'I');
LangRecord			c_get_language_code%ROWTYPE;

BEGIN

/*     Initialization Routine */

   SAVEPOINT Check_Integrity;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;

/*	Check the language isn't base or installed */

   OPEN c_get_language_code;
   FETCH c_get_language_code INTO LangRecord;
   IF c_get_language_code%FOUND THEN
      CLOSE c_get_language_code;
	  RAISE Installed_Language_Error;
   END IF;
   CLOSE c_get_language_code;

EXCEPTION

   WHEN Installed_Language_Error THEN
      ROLLBACK TO SAVEPOINT Check_Integrity;
	  x_return_status := 'E';
      FND_MESSAGE.SET_NAME('GR',
                           'GR_INSTALLED_LANG');
      FND_MESSAGE.SET_TOKEN('CODE',
         		            p_language,
            			    FALSE);
      IF FND_API.To_Boolean(p_called_by_form) THEN
	     APP_EXCEPTION.Raise_Exception;
	  ELSE
	     x_msg_data := FND_MESSAGE.Get;
	  END IF;

   WHEN OTHERS THEN
      ROLLBACK TO SAVEPOINT Check_Integrity;
	  x_return_status := 'U';
	  x_oracle_error := SQLCODE;
	  l_msg_data := SUBSTR(SQLERRM, 1, 200);
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_UNEXPECTED_ERROR');
	  FND_MESSAGE.SET_TOKEN('TEXT',
	                        l_msg_data,
	                        FALSE);
      IF FND_API.To_Boolean(p_called_by_form) THEN
	     APP_EXCEPTION.Raise_Exception;
	  ELSE
	     x_msg_data := FND_MESSAGE.Get;
	  END IF;

END Check_Integrity;

PROCEDURE Check_Primary_Key
/*		  p_safety_phrase_code is the safety phrase code to check.
**	      p_language is the language code part of the key
**		  p_called_by_form is 'T' if called by a form or 'F' if not.
**		  x_rowid is the row id of the record if found.
**		  x_key_exists is 'T' is the record is found, 'F' if not.
*/
		  		 	(p_safety_phrase_code IN VARCHAR2,
					 p_language IN VARCHAR2,
					 p_called_by_form IN VARCHAR2,
					 x_rowid OUT NOCOPY  VARCHAR2,
					 x_key_exists OUT NOCOPY  VARCHAR2)
  IS
/*	Alphanumeric variables	 */

L_MSG_DATA VARCHAR2(80);

/*		Declare any variables and the cursor */


CURSOR c_get_safety_tl_rowid
 IS
   SELECT spt.rowid
   FROM	  gr_safety_phrases_tl spt
   WHERE  spt.safety_phrase_code = p_safety_phrase_code
   AND	  spt.language = p_language;
SafetyTLRecord			   c_get_safety_tl_rowid%ROWTYPE;

BEGIN

   l_msg_data := p_safety_phrase_code || ' ' || p_language;

   x_key_exists := 'F';
   OPEN c_get_safety_tl_rowid;
   FETCH c_get_safety_tl_rowid INTO SafetyTLRecord;
   IF c_get_safety_tl_rowid%FOUND THEN
      x_key_exists := 'T';
	  x_rowid := SafetyTLRecord.rowid;
   ELSE
      x_key_exists := 'F';
   END IF;
   CLOSE c_get_safety_tl_rowid;

EXCEPTION

	WHEN Others THEN
	  l_msg_data := SQLCODE;
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_UNEXPECTED_ERROR');
	  FND_MESSAGE.SET_TOKEN('TEXT',
	                        l_msg_data,
	                        FALSE);
      IF FND_API.To_Boolean(p_called_by_form) THEN
	     APP_EXCEPTION.Raise_Exception;
	  END IF;

END Check_Primary_Key;

PROCEDURE translate_row (
	X_SAFETY_PHRASE_CODE IN VARCHAR2
	,X_LANGUAGE IN VARCHAR2
	,X_SOURCE_LANG IN VARCHAR2
	,X_SAFETY_PHRASE_DESCRIPTION IN VARCHAR2
) IS
BEGIN
	UPDATE GR_SAFETY_PHRASES_TL SET
		SAFETY_PHRASE_DESCRIPTION = X_SAFETY_PHRASE_DESCRIPTION,
		SOURCE_LANG = USERENV('LANG'),
		LAST_UPDATE_DATE = sysdate,
		LAST_UPDATED_BY = 0,
		LAST_UPDATE_LOGIN = 0
	WHERE (SAFETY_PHRASE_CODE = X_SAFETY_PHRASE_CODE)
	AND   (USERENV('LANG') IN (LANGUAGE, SOURCE_LANG));
END TRANSLATE_ROW;

/*Bug# 5237433 */
PROCEDURE translate_row (
	X_SAFETY_PHRASE_CODE IN VARCHAR2
	,X_SAFETY_PHRASE_DESCRIPTION IN VARCHAR2
        ,X_OWNER IN VARCHAR2
) IS
BEGIN
	UPDATE GR_SAFETY_PHRASES_TL SET
		SAFETY_PHRASE_DESCRIPTION = X_SAFETY_PHRASE_DESCRIPTION,
		SOURCE_LANG = USERENV('LANG'),
		LAST_UPDATE_DATE = sysdate,
		LAST_UPDATED_BY = Decode(X_OWNER, 'SEED', 1, 0),
		LAST_UPDATE_LOGIN = 0
	WHERE (SAFETY_PHRASE_CODE = X_SAFETY_PHRASE_CODE)
	AND   (USERENV('LANG') IN (LANGUAGE, SOURCE_LANG));
END TRANSLATE_ROW;

PROCEDURE load_row (
	X_SAFETY_PHRASE_CODE IN VARCHAR2
	,X_LANGUAGE IN VARCHAR2
	,X_SOURCE_LANG IN VARCHAR2
	,X_SAFETY_PHRASE_DESCRIPTION IN VARCHAR2
) IS
	CURSOR Cur_rowid IS
		SELECT rowid
		FROM GR_SAFETY_PHRASES_TL
			WHERE (SAFETY_PHRASE_CODE = X_SAFETY_PHRASE_CODE)
		AND   (LANGUAGE = X_LANGUAGE);
	l_user_id	NUMBER	DEFAULT 1;
	l_row_id	VARCHAR2(64);
	l_return_status	VARCHAR2(1);
	l_oracle_error	NUMBER;
	l_msg_data	VARCHAR2(2000);
BEGIN
	OPEN Cur_rowid;
	FETCH Cur_rowid INTO l_row_id;
	IF Cur_rowid%FOUND THEN
		GR_SAFETY_PHRASES_TL_PKG.UPDATE_ROW(
			P_COMMIT => 'T'
			,P_CALLED_BY_FORM => 'F'
			,P_ROWID => l_row_id
			,P_SAFETY_PHRASE_CODE => X_SAFETY_PHRASE_CODE
			,P_LANGUAGE => X_LANGUAGE
			,P_SOURCE_LANGUAGE => X_SOURCE_LANG
			,P_SAFETY_PHRASE_DESCRIPTION => X_SAFETY_PHRASE_DESCRIPTION
			,P_CREATED_BY => l_user_id
			,P_CREATION_DATE => sysdate
			,P_LAST_UPDATED_BY => l_user_id
			,P_LAST_UPDATE_DATE => sysdate
			,P_LAST_UPDATE_LOGIN => 0
			,X_RETURN_STATUS => l_return_status
			,X_ORACLE_ERROR => l_oracle_error
			,X_MSG_DATA => l_msg_data);
	ELSE
		GR_SAFETY_PHRASES_TL_PKG.INSERT_ROW(
			P_COMMIT => 'T'
			,P_CALLED_BY_FORM => 'F'
			,P_SAFETY_PHRASE_CODE => X_SAFETY_PHRASE_CODE
			,P_LANGUAGE => X_LANGUAGE
			,P_SOURCE_LANGUAGE => X_SOURCE_LANG
			,P_SAFETY_PHRASE_DESCRIPTION => X_SAFETY_PHRASE_DESCRIPTION
			,P_CREATED_BY => l_user_id
			,P_CREATION_DATE => sysdate
			,P_LAST_UPDATED_BY => l_user_id
			,P_LAST_UPDATE_DATE => sysdate
			,P_LAST_UPDATE_LOGIN => 0
			,X_ROWID => l_row_id
			,X_RETURN_STATUS => l_return_status
			,X_ORACLE_ERROR => l_oracle_error
			,X_MSG_DATA => l_msg_data);
	END IF;
	CLOSE Cur_rowid;
END LOAD_ROW;

/*Bug# 5237433 */
PROCEDURE load_row (
	X_SAFETY_PHRASE_CODE IN VARCHAR2
	,X_SAFETY_PHRASE_DESCRIPTION IN VARCHAR2
   	,X_OWNER       IN VARCHAR2
) IS
	CURSOR Cur_rowid IS
		SELECT rowid
		FROM GR_SAFETY_PHRASES_TL
			WHERE (SAFETY_PHRASE_CODE = X_SAFETY_PHRASE_CODE)
		AND USERENV('LANG') in (LANGUAGE,SOURCE_LANG);
	l_user_id	NUMBER	DEFAULT 0;
	l_row_id	VARCHAR2(64);
	l_return_status	VARCHAR2(1);
	l_oracle_error	NUMBER;
	l_msg_data	VARCHAR2(2000);
        l_sysdate                  DATE;

BEGIN
     IF (x_owner = 'SEED') THEN
         l_user_id := 1;
     END IF;
     select sysdate into l_sysdate from dual;

	OPEN Cur_rowid;
	FETCH Cur_rowid INTO l_row_id;
	IF Cur_rowid%FOUND THEN
	    UPDATE GR_SAFETY_PHRASES_TL SET
  		  SAFETY_PHRASE_DESCRIPTION    = X_SAFETY_PHRASE_DESCRIPTION,
	          LAST_UPDATE_DATE     = l_sysdate,
                  LAST_UPDATED_BY      = l_user_id,
                  LAST_UPDATE_LOGIN    = 0,
                  SOURCE_LANG          = userenv('LANG')
       	   WHERE (SAFETY_PHRASE_CODE = X_SAFETY_PHRASE_CODE)
       	   AND   userenv('LANG') in (LANGUAGE,SOURCE_LANG);
	ELSE
	   insert into GR_SAFETY_PHRASES_TL (
             	SAFETY_PHRASE_CODE,
                SAFETY_PHRASE_DESCRIPTION,
                CREATED_BY,
                CREATION_DATE,
                LAST_UPDATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATE_LOGIN,
                LANGUAGE,
                SOURCE_LANG
              ) select
                X_SAFETY_PHRASE_CODE,
                X_SAFETY_PHRASE_DESCRIPTION,
	        l_user_id,
	        l_sysdate,
	        l_user_id,
                l_sysdate,
	        0,
                L.LANGUAGE_CODE,
                userenv('LANG')
              from FND_LANGUAGES L
              where L.INSTALLED_FLAG in ('I', 'B')
              and not exists
                (select NULL
                from GR_SAFETY_PHRASES_TL T
                where T.SAFETY_PHRASE_CODE = X_SAFETY_PHRASE_CODE
                and T.LANGUAGE = L.LANGUAGE_CODE);
	END IF;
	CLOSE Cur_rowid;
END LOAD_ROW;

/*     21-Jan-2002     Melanie Grosser         BUG 2190024 - Added procedure NEW_LANGUAGE
                                               to be called from GRNLINS.sql. Generated
                                               from tltblgen.
*/
procedure NEW_LANGUAGE
is
begin
  delete from GR_SAFETY_PHRASES_TL T
  where not exists
    (select NULL
    from GR_SAFETY_PHRASES_B B
    where B.SAFETY_PHRASE_CODE = T.SAFETY_PHRASE_CODE
    );

  update GR_SAFETY_PHRASES_TL T set (
      SAFETY_PHRASE_DESCRIPTION
    ) = (select
      B.SAFETY_PHRASE_DESCRIPTION
    from GR_SAFETY_PHRASES_TL B
    where B.SAFETY_PHRASE_CODE = T.SAFETY_PHRASE_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.SAFETY_PHRASE_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.SAFETY_PHRASE_CODE,
      SUBT.LANGUAGE
    from GR_SAFETY_PHRASES_TL SUBB, GR_SAFETY_PHRASES_TL SUBT
    where SUBB.SAFETY_PHRASE_CODE = SUBT.SAFETY_PHRASE_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.SAFETY_PHRASE_DESCRIPTION <> SUBT.SAFETY_PHRASE_DESCRIPTION
  ));

  insert into GR_SAFETY_PHRASES_TL (
    SAFETY_PHRASE_CODE,
    SAFETY_PHRASE_DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.SAFETY_PHRASE_CODE,
    B.SAFETY_PHRASE_DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from GR_SAFETY_PHRASES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from GR_SAFETY_PHRASES_TL T
    where T.SAFETY_PHRASE_CODE = B.SAFETY_PHRASE_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);

end NEW_LANGUAGE;


END GR_SAFETY_PHRASES_TL_PKG;

/
