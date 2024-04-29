--------------------------------------------------------
--  DDL for Package Body GR_DOCUMENT_CODES_TL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GR_DOCUMENT_CODES_TL_PKG" AS
/*$Header: GRHIDCTB.pls 115.11 2002/10/28 19:11:41 mgrosser noship $*/
PROCEDURE Insert_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_document_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_description IN VARCHAR2,
				  p_source_lang IN VARCHAR2,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_date IN DATE,
				  p_last_update_login IN NUMBER,
				  x_rowid OUT NOCOPY VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2)
	IS

/*   Alpha Variables */

L_RETURN_STATUS VARCHAR2(1) := 'S';
L_KEY_EXISTS VARCHAR2(1);
L_MSG_DATA VARCHAR2(2000);
L_ROWID VARCHAR2(18);

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
	   (p_document_code,
	    p_language,
	    p_source_lang,
	    l_return_status,
	    l_oracle_error,
	    l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Foreign_Key_Error;
   END IF;

/* 	   Now check the primary key doesn't already exist */

   Check_Primary_Key
    	 (p_document_code,
    	  p_language,
		  'F',
		  l_rowid,
		  l_key_exists);

   IF FND_API.To_Boolean(l_key_exists) THEN
   	  RAISE Item_Exists_Error;
   END IF;

   INSERT INTO gr_document_codes_tl
  	     (document_code,
  	      language,
  	      description,
  	      source_lang,
	      created_by,
	      creation_date,
	      last_updated_by,
	      last_update_date,
	      last_update_login)
          VALUES
	     (p_document_code,
	      p_language,
	      p_description,
	      p_source_lang,
              p_created_by,
              p_creation_date,
              p_last_updated_by,
              p_last_update_date,
              p_last_update_login);

/*   Now get the row id of the inserted record */

   Check_Primary_Key
   		 (p_document_code,
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
      x_return_status := 'E';
      x_oracle_error := APP_EXCEPTION.Get_Code;
      FND_MESSAGE.SET_NAME('GR',
                           'GR_RECORD_EXISTS');
      FND_MESSAGE.SET_TOKEN('CODE',
         		     p_document_code,
            		     FALSE);
      IF FND_API.To_Boolean(p_called_by_form) THEN
         APP_EXCEPTION.Raise_Exception;
      ELSE
         x_msg_data := FND_MESSAGE.Get;
      END IF;

   WHEN Row_Missing_Error THEN
      ROLLBACK TO SAVEPOINT Insert_Row;
      x_return_status := 'E';
      x_oracle_error := APP_EXCEPTION.Get_Code;
      FND_MESSAGE.SET_NAME('GR',
                           'GR_NO_RECORD_INSERTED');
      FND_MESSAGE.SET_TOKEN('CODE',
         		     p_document_code,
            		     FALSE);
      x_msg_data := FND_MESSAGE.Get;
      IF FND_API.To_Boolean(p_called_by_form) THEN
	 	 APP_EXCEPTION.Raise_Exception;
      ELSE
         x_msg_data := FND_MESSAGE.Get;
	  END IF;

   WHEN OTHERS THEN
      ROLLBACK TO SAVEPOINT Insert_Row;
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

END Insert_Row;

PROCEDURE Update_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_rowid IN VARCHAR2,
				  p_document_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_description IN VARCHAR2,
				  p_source_lang IN VARCHAR2,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_date IN DATE,
				  p_last_update_login IN NUMBER,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2)
 IS

/*   Alpha Variables */

L_RETURN_STATUS	  VARCHAR2(1) := 'S';
L_MSG_DATA		  VARCHAR2(2000);

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

/*	  Now call the check foreign key procedure */

   Check_Foreign_Keys
	   (p_document_code,
	    p_language,
	    p_source_lang,
		l_return_status,
		l_oracle_error,
		l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Foreign_Key_Error;
   ELSE
       UPDATE	gr_document_codes_tl
	  SET	document_code	= p_document_code,
	        language = p_language,
	        description = p_description,
	        source_lang = p_source_lang,
		created_by = p_created_by,
		creation_date = p_creation_date,
		last_updated_by	= p_last_updated_by,
		last_update_date = p_last_update_date,
		last_update_login = p_last_update_login
	 WHERE	rowid = p_rowid;

      IF SQL%NOTFOUND THEN
	     RAISE Row_Missing_Error;
	  END IF;
   END IF;

/* 	Check if do the commit */

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
         		    		p_document_code,
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
	                        l_msg_data,
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
		      p_document_code IN VARCHAR2,
		      p_language IN VARCHAR2,
		      x_return_status OUT NOCOPY VARCHAR2,
		      x_oracle_error OUT NOCOPY NUMBER,
		      x_msg_data OUT NOCOPY VARCHAR2)
 IS

/*   Alpha Variables */

L_RETURN_STATUS	  	VARCHAR2(1) := 'S';
L_MSG_DATA		  	VARCHAR2(2000);
L_MSG_TOKEN		  	VARCHAR2(30);
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
   SELECT	eit.description,
                eit.created_by,
		eit.creation_date,
		eit.last_updated_by,
		eit.last_update_date,
		eit.last_update_login
   FROM	        gr_document_codes_tl eit
   WHERE	eit.document_code = p_document_code
   AND		eit.language = l_language;
TypeDesc				c_get_descs%ROWTYPE;

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
   l_msg_token := p_document_code || ' ' || p_language;

/* Remove translations with no base row */

  delete from GR_DOCUMENT_CODES_TL T
  where not exists
    (select NULL
    from GR_DOCUMENT_CODES B
    where B.DOCUMENT_CODE = T.DOCUMENT_CODE
    );

/* Redefault translations from the source language  */

   /* 15-Aug-2001 Mercy Thomas 1926634
      Changed the inner query from GR_DOCUMENT_CODES to GR_DOCUMENT_CODES_TL.
      Added the condition B.LANGUAGE = T.SOURCE_LANG
      And changed the column from DOCUMENT_DESCRIPTION to DESCRIPTION */

   update gr_document_codes_tl t set (
    description ) =
    ( select
      B.DESCRIPTION
      from GR_DOCUMENT_CODES_TL B
      where B.DOCUMENT_CODE = T.DOCUMENT_CODE
      and   B.LANGUAGE = T.SOURCE_LANG)
   where (
      T.DOCUMENT_CODE,
      T.LANGUAGE
   ) in (select
         SUBT.DOCUMENT_CODE,
         SUBT.LANGUAGE
         from GR_DOCUMENT_CODES_TL SUBB, GR_DOCUMENT_CODES_TL SUBT
         where SUBB.DOCUMENT_CODE = SUBT.DOCUMENT_CODE
         and SUBB.LANGUAGE = SUBT.SOURCE_LANG
         and (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
          or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
          or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

/*	Open the language cursor and get the description entered from the
**	user environment variable.
*/
   l_language := p_language;
   OPEN c_get_descs;
   FETCH c_get_descs INTO TypeDesc;
   IF c_get_descs%NOTFOUND THEN
      CLOSE c_get_descs;
      RAISE Language_Missing_Error;
   ELSE
          l_base_desc := TypeDesc.description;
	  l_created_by := TypeDesc.created_by;
	  l_creation_date := TypeDesc.creation_date;
	  l_last_updated_by := TypeDesc.last_updated_by;
	  l_last_update_date := TypeDesc.last_update_date;
	  l_last_update_login := TypeDesc.last_update_login;
      CLOSE c_get_descs;
   END IF;

/*	Read fnd_languages for the installed and base languages.
**	For those that are found, read the types tl table.
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
			FETCH c_get_descs INTO TypeDesc;
			IF c_get_descs%NOTFOUND THEN
			   CLOSE c_get_descs;
			   INSERT INTO gr_document_codes_tl
						(document_code,
						 language,
						 description,
						 source_lang,
						 created_by,
						 creation_date,
						 last_updated_by,
						 last_update_date,
						 last_update_login)
				   VALUES
				        (p_document_code,
						 l_language,
						 l_base_desc,
						 p_language,
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

	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_UNEXPECTED_ERROR');
	  FND_MESSAGE.SET_TOKEN('TEXT',
	                        l_msg_token||SQLERRM,
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
				  p_document_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_description IN VARCHAR2,
				  p_source_lang IN VARCHAR2,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_date IN DATE,
				  p_last_update_login IN NUMBER,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2)
 IS

/*  Alpha Variables */

L_RETURN_STATUS	  VARCHAR2(1) := 'S';
L_MSG_DATA		  VARCHAR2(2000);

/*  Number Variables */

L_ORACLE_ERROR	  NUMBER;

/*   Exceptions */

NO_DATA_FOUND_ERROR 		EXCEPTION;
RECORD_CHANGED_ERROR	 	EXCEPTION;


/*   Define the cursors */

CURSOR c_lock_ein_number
 IS
   SELECT	last_update_date
   FROM		gr_document_codes_tl
   WHERE	rowid = p_rowid
   FOR UPDATE NOWAIT;
LockEinRcd	  c_lock_ein_number%ROWTYPE;
BEGIN

/*      Initialization Routine */

   SAVEPOINT Lock_Row;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;

/*	   Now lock the record */

   OPEN c_lock_ein_number;
   FETCH c_lock_ein_number INTO LockEinRcd;
   IF c_lock_ein_number%NOTFOUND THEN
	  CLOSE c_lock_ein_number;
	  RAISE No_Data_Found_Error;
   END IF;
   CLOSE c_lock_ein_number;

   IF LockEinRcd.last_update_date <> p_last_update_date THEN
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
	                        p_document_code,
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
	                        l_msg_data,
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
				  p_document_code IN VARCHAR2,
				  p_language	IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2)
 IS
/*   Alpha Variables */

L_RETURN_STATUS	  VARCHAR2(1) := 'S';
L_MSG_DATA		  VARCHAR2(2000);

/*   Number Variables */

L_ORACLE_ERROR	  NUMBER;

/*   Exceptions */

CHECK_INTEGRITY_ERROR EXCEPTION;
ROW_MISSING_ERROR	  EXCEPTION;
PRAGMA EXCEPTION_INIT(Row_Missing_Error,100);

BEGIN

/*   Initialization Routine */

   SAVEPOINT Delete_Row;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;

/*  Now call the check integrity procedure */

   Check_Integrity
			     (p_called_by_form,
			      p_document_code,
      			      p_language,
				  l_return_status,
				  l_oracle_error,
				  l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Check_Integrity_Error;
   END IF;

   DELETE FROM gr_document_codes_tl
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
         		            p_document_code,
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
	                        l_msg_data,
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
				  p_document_code IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2)
  IS

/*   Alpha Variables */

L_RETURN_STATUS	  VARCHAR2(1) := 'S';
L_MSG_DATA		  VARCHAR2(2000);
L_MSG_TOKEN       VARCHAR2(30);

/*   Number Variables */

L_ORACLE_ERROR	  NUMBER;

/*   Define the cursors */

BEGIN

/*   Initialization Routine */

   SAVEPOINT Delete_Rows;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;
   l_msg_token := p_document_code;

   DELETE FROM gr_document_codes_tl
   WHERE       document_code = p_document_code;

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
	                        l_msg_token||SQLERRM,
	                        FALSE);
	  IF FND_API.To_Boolean(p_called_by_form) THEN
	     APP_EXCEPTION.Raise_Exception;
	  ELSE
	     x_msg_data := FND_MESSAGE.Get;
	  END IF;

END Delete_Rows;


PROCEDURE Check_Foreign_Keys
	   			 (p_document_code IN VARCHAR2,
	   			  p_language IN VARCHAR2,
	   			  p_source_lang IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2)
   IS

/*   Alpha Variables */

L_RETURN_STATUS	  VARCHAR2(1) := 'S';
L_MSG_DATA		  VARCHAR2(2000);
L_ROWID			  VARCHAR2(18);
L_KEY_EXISTS	  VARCHAR2(1);
L_MSG_TOKEN       VARCHAR2(30);
L_LANGUAGE_CODE	  VARCHAR2(4);

/*   Number Variables */

L_ORACLE_ERROR	  NUMBER;

/* Cursors   */
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

   l_msg_token := p_document_code || ' ' || p_language;

/*   Check the language codes */

   l_language_code := p_language;
   OPEN c_get_language;
   FETCH c_get_language INTO LangRecord;
   IF c_get_language%NOTFOUND THEN
	  l_msg_token := l_language_code;
	  x_return_status := 'E';
	  x_oracle_error := APP_EXCEPTION.Get_Code;
      FND_MESSAGE.SET_NAME('GR',
                           'GR_RECORD_NOT_FOUND');
      FND_MESSAGE.SET_TOKEN('CODE',
         		            l_msg_token,
            			    FALSE);
	  l_msg_data := FND_MESSAGE.Get;
   END IF;
   CLOSE c_get_language;

   l_language_code := p_source_lang;
   OPEN c_get_language;
   FETCH c_get_language INTO LangRecord;
   IF c_get_language%NOTFOUND THEN
	  l_msg_token := l_language_code;
	  x_return_status := 'E';
	  x_oracle_error := APP_EXCEPTION.Get_Code;
      FND_MESSAGE.SET_NAME('GR',
                           'GR_RECORD_NOT_FOUND');
      FND_MESSAGE.SET_TOKEN('CODE',
         		            l_msg_token,
            			    FALSE);
	  l_msg_data := FND_MESSAGE.Get;
   END IF;
   CLOSE c_get_language;

   IF x_return_status <> 'S' THEN
      x_msg_data := l_msg_data;
   END IF;


EXCEPTION

   WHEN OTHERS THEN
      ROLLBACK TO SAVEPOINT Check_Foreign_Keys;
	  x_return_status := 'U';
	  x_oracle_error := SQLCODE;
	  l_msg_data := SUBSTR(SQLERRM, 1, 200);
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_UNEXPECTED_ERROR');
	  FND_MESSAGE.SET_TOKEN('TEXT',
	                        l_msg_data,
	                        FALSE);
	  x_msg_data := FND_MESSAGE.Get;

END Check_Foreign_Keys;

PROCEDURE Check_Integrity
	   			 (p_called_by_form IN VARCHAR2,
	   			  p_document_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2)
 IS

/*   Alpha Variables */

L_RETURN_STATUS	  VARCHAR2(1) := 'S';
L_MSG_DATA		  VARCHAR2(2000);

/*   Number Variables */

L_ORACLE_ERROR	  NUMBER;
L_RECORD_COUNT	  NUMBER;

/*   Exceptions */
INSTALLED_LANGUAGE_ERROR	EXCEPTION;
/*   Define Cursors */

CURSOR c_get_language_code
 IS
   SELECT	lng.installed_flag
   FROM		fnd_languages lng
   WHERE	lng.language_code = p_language
   AND		lng.installed_flag IN ('B', 'I');
LangRecord		c_get_language_code%ROWTYPE;

BEGIN
/*
**   Initialization Routine
*/
   SAVEPOINT Check_Integrity;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;
   l_record_count := 0;

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
			 (p_document_code IN VARCHAR2,
			  p_language IN VARCHAR2,
			  p_called_by_form IN VARCHAR2,
			  x_rowid OUT NOCOPY VARCHAR2,
			  x_key_exists OUT NOCOPY VARCHAR2)
 IS
/*		Declare any variables and the cursor */

L_MSG_DATA VARCHAR2(2000);

CURSOR c_get_ein_rowid
 IS
   SELECT ein.rowid
   FROM	  gr_document_codes_tl ein
   WHERE  ein.document_code = p_document_code
   AND	  ein.language = p_language;
EinRecord			   c_get_ein_rowid%ROWTYPE;

BEGIN

   x_key_exists := 'F';
   OPEN c_get_ein_rowid;
   FETCH c_get_ein_rowid INTO EinRecord;
   IF c_get_ein_rowid%FOUND THEN
      x_key_exists := 'T';
      x_rowid := EinRecord.rowid;
   ELSE
      x_key_exists := 'F';
   END IF;
   CLOSE c_get_ein_rowid;

EXCEPTION

   WHEN Others THEN
	  l_msg_data := sqlerrm;
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
	X_DOCUMENT_CODE IN VARCHAR2
	,X_LANGUAGE IN VARCHAR2
	,X_DESCRIPTION IN VARCHAR2
	,X_SOURCE_LANG IN VARCHAR2
) IS
BEGIN
	UPDATE GR_DOCUMENT_CODES_TL SET
		DESCRIPTION = X_DESCRIPTION,
		SOURCE_LANG = USERENV('LANG'),
		LAST_UPDATE_DATE = sysdate,
		LAST_UPDATED_BY = 0,
		LAST_UPDATE_LOGIN = 0
	WHERE (DOCUMENT_CODE = X_DOCUMENT_CODE)
	AND   (USERENV('LANG') IN (LANGUAGE, SOURCE_LANG));
END TRANSLATE_ROW;


PROCEDURE load_row (
	X_DOCUMENT_CODE IN VARCHAR2
	,X_LANGUAGE IN VARCHAR2
	,X_DESCRIPTION IN VARCHAR2
	,X_SOURCE_LANG IN VARCHAR2
) IS
	CURSOR Cur_rowid IS
		SELECT rowid
		FROM GR_DOCUMENT_CODES_TL
			WHERE (DOCUMENT_CODE = X_DOCUMENT_CODE)
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
		GR_DOCUMENT_CODES_TL_PKG.UPDATE_ROW(
			P_COMMIT => 'T'
			,P_CALLED_BY_FORM => 'F'
			,P_ROWID => l_row_id
			,P_DOCUMENT_CODE => X_DOCUMENT_CODE
			,P_LANGUAGE => X_LANGUAGE
			,P_DESCRIPTION => X_DESCRIPTION
			,P_SOURCE_LANG => X_SOURCE_LANG
			,P_CREATED_BY => l_user_id
			,P_CREATION_DATE => sysdate
			,P_LAST_UPDATED_BY => l_user_id
			,P_LAST_UPDATE_DATE => sysdate
			,P_LAST_UPDATE_LOGIN => 0
			,X_RETURN_STATUS => l_return_status
			,X_ORACLE_ERROR => l_oracle_error
			,X_MSG_DATA => l_msg_data);
	ELSE
		GR_DOCUMENT_CODES_TL_PKG.INSERT_ROW(
			P_COMMIT => 'T'
			,P_CALLED_BY_FORM => 'F'
			,P_DOCUMENT_CODE => X_DOCUMENT_CODE
			,P_LANGUAGE => X_LANGUAGE
			,P_DESCRIPTION => X_DESCRIPTION
			,P_SOURCE_LANG => X_SOURCE_LANG
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

/*     21-Jan-2002     Mercy Thomas   BUG 2190024 - Added procedure NEW_LANGUAGE
                       to be called from GRNLINS.sql. Generated from tltblgen. */

/*     28-Jan-2002     Melanie Grosser         BUG 2190024 - Procedure NEW_LANGUAGE had been
                                                 generated incorrectly.  I regenerated it.

*/

procedure NEW_LANGUAGE
is
begin
  delete from GR_DOCUMENT_CODES_TL T
  where not exists
    (select NULL
    from GR_DOCUMENT_CODES B
    where B.DOCUMENT_CODE = T.DOCUMENT_CODE
    );

  update GR_DOCUMENT_CODES_TL T set (
      DESCRIPTION
    ) = (select
      B.DESCRIPTION
    from GR_DOCUMENT_CODES_TL B
    where B.DOCUMENT_CODE = T.DOCUMENT_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.DOCUMENT_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.DOCUMENT_CODE,
      SUBT.LANGUAGE
    from GR_DOCUMENT_CODES_TL SUBB, GR_DOCUMENT_CODES_TL SUBT
    where SUBB.DOCUMENT_CODE = SUBT.DOCUMENT_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
  ));

  insert into GR_DOCUMENT_CODES_TL (
    DOCUMENT_CODE,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.DOCUMENT_CODE,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from GR_DOCUMENT_CODES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from GR_DOCUMENT_CODES_TL T
    where T.DOCUMENT_CODE = B.DOCUMENT_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);

end NEW_LANGUAGE;

END GR_DOCUMENT_CODES_TL_PKG;

/
