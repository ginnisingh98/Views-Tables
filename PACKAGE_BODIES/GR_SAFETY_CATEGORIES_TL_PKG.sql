--------------------------------------------------------
--  DDL for Package Body GR_SAFETY_CATEGORIES_TL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GR_SAFETY_CATEGORIES_TL_PKG" AS
/*$Header: GRHICATB.pls 115.9 2002/10/28 16:51:49 gkelly ship $*/
PROCEDURE Insert_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_safety_category_code IN VARCHAR2,
				  p_safety_category_description IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_source_lang IN VARCHAR2,
				  p_last_update_login IN NUMBER,
				  p_last_update_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_created_by IN NUMBER,
				  x_rowid OUT NOCOPY VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2)
	IS
/*   Alpha Variables */

L_RETURN_STATUS VARCHAR2(1) := 'S';
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
			     (p_safety_category_code,
				  p_safety_category_description,
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
   	   	   		 (p_safety_category_code,
				  p_language,
				  'F',
				  l_rowid,
				  l_key_exists);

   IF FND_API.To_Boolean(l_key_exists) THEN
   	  RAISE Item_Exists_Error;
   END IF;

   INSERT INTO gr_safety_categories_tl
   		  	     (safety_category_code,
				  safety_category_description,
				  language,
				  source_lang,
				  last_update_login,
				  last_update_date,
				  last_updated_by,
				  creation_date,
				  created_by)
          VALUES
		         (p_safety_category_code,
				  p_safety_category_description,
				  p_language,
				  p_source_lang,
				  p_last_update_login,
				  p_last_update_date,
				  p_last_updated_by,
				  p_creation_date,
				  p_created_by);

/*   Now get the row id of the inserted record */

   Check_Primary_Key
   	   	   		 (p_safety_category_code,
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
	  l_msg_token := p_safety_category_code;
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
	  l_msg_token := p_safety_category_code;
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
	  l_msg_token := p_safety_category_code ||' ' ||TO_CHAR(x_oracle_error);
	  x_return_status := 'U';
--B1052134 - changed APP_EXCEPTION.Get_Code to SQLCODE, added SQLERRM
	  x_oracle_error := SQLCODE;
	  l_msg_data := SUBSTR(SQLERRM, 1, 200);
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_UNEXPECTED_ERROR');
	  FND_MESSAGE.SET_TOKEN('TEXT',
	                        l_msg_token||sqlerrm,
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
				  p_safety_category_code IN VARCHAR2,
				  p_safety_category_description IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_source_lang IN VARCHAR2,
				  p_last_update_login IN NUMBER,
				  p_last_update_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_created_by IN NUMBER,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2)
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
   l_msg_token := p_safety_category_code;

/*	  Now call the check foreign key procedure */

   Check_Foreign_Keys
			     (p_safety_category_code,
				  p_safety_category_description,
				  p_language,
				  p_source_lang,
				  l_return_status,
				  l_oracle_error,
				  l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Foreign_Key_Error;
   ELSE
      UPDATE gr_safety_categories_tl
	  SET	 safety_category_code			  = p_safety_category_code,
			 safety_category_description	  = p_safety_category_description,
			 language	                      = p_language,
			 source_lang	                  = p_source_lang,
			 last_update_login	              = p_last_update_login,
			 last_update_date	              = p_last_update_date,
			 last_updated_by	              = p_last_updated_by,
			 creation_date	                  = p_creation_date,
			 created_by	                      = p_created_by
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
--B1052134 - changed APP_EXCEPTION to SQLCODE, added SQLERRM
	  x_oracle_error := SQLCODE;
	  l_msg_data := SUBSTR(SQLERRM, 1, 200);
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_UNEXPECTED_ERROR');
	  FND_MESSAGE.SET_TOKEN('TEXT',
	                        l_msg_token ||sqlerrm,
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
				  p_safety_category_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2)
 IS

/*   Alpha Variables */

L_RETURN_STATUS	  		VARCHAR2(1) := 'S';
L_MSG_DATA		  		VARCHAR2(2000);
L_MSG_TOKEN		  		VARCHAR2(100);
L_BASE_DESC             GR_SAFETY_CATEGORIES_TL.safety_category_description%TYPE;
L_LANGUAGE		  		VARCHAR2(4);
L_CREATION_DATE	 		DATE;
L_LAST_UPDATE_DATE		DATE;
/*
**   Number Variables
*/
L_ORACLE_ERROR	  	NUMBER;
L_CREATED_BY		NUMBER;
L_LAST_UPDATED_BY	NUMBER;
L_LAST_UPDATE_LOGIN	NUMBER;
/*
**	Exceptions
*/
LANGUAGE_MISSING_ERROR	EXCEPTION;
/*
**   Cursors
*/
CURSOR c_get_safety_category
 IS
   SELECT	cat.safety_category_description,
            cat.created_by,
			cat.creation_date,
			cat.last_updated_by,
			cat.last_update_date,
			cat.last_update_login
   FROM	    gr_safety_categories_tl cat
   WHERE	cat.safety_category_code = p_safety_category_code
   AND		cat.language = l_language;
CategoryRecord				c_get_safety_category%ROWTYPE;

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
   l_msg_token := p_safety_category_code || ' ' || p_language;

/* Remove translations with no base row */

  delete from GR_SAFETY_CATEGORIES_TL T
  where not exists
    (select NULL
    from GR_SAFETY_CATEGORIES_B B
    where B.SAFETY_CATEGORY_CODE = T.SAFETY_CATEGORY_CODE
    );

/* Redefault translations from the source language  */

   update gr_safety_categories_tl t set (
    safety_category_description ) =
    ( select
      B.SAFETY_CATEGORY_DESCRIPTION
      from GR_SAFETY_CATEGORIES_TL B
      where B.SAFETY_CATEGORY_CODE = T.SAFETY_CATEGORY_CODE
      and B.LANGUAGE = T.SOURCE_LANG)
   where (
      T.SAFETY_CATEGORY_CODE,
      T.LANGUAGE
   ) in (select
         SUBT.SAFETY_CATEGORY_CODE,
         SUBT.LANGUAGE
         from GR_SAFETY_CATEGORIES_TL SUBB, GR_SAFETY_CATEGORIES_TL SUBT
         where SUBB.SAFETY_CATEGORY_CODE = SUBT.SAFETY_CATEGORY_CODE
         and SUBB.LANGUAGE = SUBT.SOURCE_LANG
         and (SUBB.SAFETY_CATEGORY_DESCRIPTION <> SUBT.SAFETY_CATEGORY_DESCRIPTION
          or (SUBB.SAFETY_CATEGORY_DESCRIPTION is null and SUBT.SAFETY_CATEGORY_DESCRIPTION is not null)
          or (SUBB.SAFETY_CATEGORY_DESCRIPTION is not null and SUBT.SAFETY_CATEGORY_DESCRIPTION is null)
  ));

/*	Open the language cursor and get the description entered from the
**	user environment variable.
*/
   l_language := p_language;
   OPEN c_get_safety_category;
   FETCH c_get_safety_category INTO CategoryRecord;
   IF c_get_safety_category%NOTFOUND THEN
      CLOSE c_get_safety_category;
      RAISE Language_Missing_Error;
   ELSE
	  l_base_desc := CategoryRecord.safety_category_description;
	  l_created_by := CategoryRecord.created_by;
	  l_creation_date := CategoryRecord.creation_date;
	  l_last_updated_by := CategoryRecord.last_updated_by;
	  l_last_update_date := CategoryRecord.last_update_date;
	  l_last_update_login := CategoryRecord.last_update_login;
      CLOSE c_get_safety_category;
   END IF;

/*	Read fnd_languages for the installed and base languages.
**	For those that are found, read the phrases tl table.
**	If there isn't a record in the table for that language then
**	insert it and go on to the next.
*/
   OPEN c_get_installed_languages;
   FETCH c_get_installed_languages INTO InstLang;
   IF c_get_installed_languages%FOUND THEN
      WHILE c_get_installed_languages%FOUND LOOP
	     IF InstLang.language_code <> p_language THEN
		    l_language := InstLang.language_code;
			OPEN c_get_safety_category;
			FETCH c_get_safety_category INTO CategoryRecord;
			IF c_get_safety_category%NOTFOUND THEN
			   CLOSE c_get_safety_category;
			   INSERT INTO gr_safety_categories_tl
						(safety_category_code,
				         safety_category_description,
				         language,
				         source_lang,
				         last_update_login,
				         last_update_date,
				         last_updated_by,
				         creation_date,
				         created_by)
				   VALUES
				        (p_safety_category_code,
						 l_base_desc,
						 l_language,
						 p_language,
						 l_last_update_login,
						 l_last_update_date,
						 l_last_updated_by,
						 l_creation_date,
						 l_created_by);
			ELSE
			   CLOSE c_get_safety_category;
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
	                        l_msg_token||sqlerrm,
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
				  p_safety_category_code IN VARCHAR2,
				  p_safety_category_description IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_source_lang IN VARCHAR2,
				  p_last_update_login IN NUMBER,
				  p_last_update_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_created_by IN NUMBER,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2)
   IS

/*  Alpha Variables */

L_RETURN_STATUS	  VARCHAR2(1) := 'S';
L_MSG_DATA		  VARCHAR2(2000);
L_MSG_TOKEN		  VARCHAR2(100);

/*  Number Variables */

L_ORACLE_ERROR	  NUMBER;

/*   Exceptions */

NO_DATA_FOUND_ERROR 		EXCEPTION;
ROW_ALREADY_LOCKED_ERROR 	EXCEPTION;
PRAGMA EXCEPTION_INIT(ROW_ALREADY_LOCKED_ERROR,-54);

/*   Define the cursors */

CURSOR c_lock_categories_tl
 IS
   SELECT	*
   FROM		gr_safety_categories_tl
   WHERE	rowid = p_rowid
   FOR UPDATE NOWAIT;
LockCategoryRcd	  c_lock_categories_tl%ROWTYPE;

BEGIN

/*      Initialization Routine */

   SAVEPOINT Lock_Row;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;
   l_msg_token := p_safety_category_code || ' ' || p_language;

/*	   Now lock the record */

   OPEN c_lock_categories_tl;
   FETCH c_lock_categories_tl INTO LockCategoryRcd;
   IF c_lock_categories_tl%NOTFOUND THEN
	  CLOSE c_lock_categories_tl;
	  RAISE No_Data_Found_Error;
   END IF;
   CLOSE c_lock_categories_tl;

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

   WHEN Row_Already_Locked_Error THEN
      ROLLBACK TO SAVEPOINT Lock_Row;
	  x_return_status := 'E';
	  x_oracle_error := APP_EXCEPTION.Get_Code;
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_ROW_IS_LOCKED');
      IF FND_API.To_Boolean(p_called_by_form) THEN
         APP_EXCEPTION.Raise_Exception;
	  ELSE
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
	                        l_msg_token ||sqlerrm,
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
				  p_safety_category_code IN VARCHAR2,
				  p_safety_category_description IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_source_lang IN VARCHAR2,
				  p_last_update_login IN NUMBER,
				  p_last_update_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_created_by IN NUMBER,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2)
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

/*	Define the cursor */

BEGIN

/*   Initialization Routine */

   SAVEPOINT Delete_Row;
   x_return_status := 'S';
   l_called_by_form := 'F';
   x_oracle_error := 0;
   x_msg_data := NULL;
   l_msg_token := p_safety_category_code || ' ' || p_language;

/*  Now call the check integrity procedure */

   Check_Integrity
			     (l_called_by_form,
				  p_safety_category_code,
				  p_safety_category_description,
				  p_language,
				  p_source_lang,
				  l_return_status,
				  l_oracle_error,
				  l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Check_Integrity_Error;
   END IF;

   DELETE FROM gr_safety_categories_tl
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
	              p_safety_category_code IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2)
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
   l_msg_token := p_safety_category_code;

   DELETE FROM gr_safety_categories_tl
   WHERE 	   safety_category_code = p_safety_category_code;

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
	                        l_msg_token||sqlerrm,
	                        FALSE);
      IF FND_API.To_Boolean(p_called_by_form) THEN
         APP_EXCEPTION.Raise_Exception;
	  ELSE
	     x_msg_data := FND_MESSAGE.Get;
      END IF;

END Delete_Rows;

PROCEDURE Check_Foreign_Keys
	   			 (p_safety_category_code IN VARCHAR2,
				  p_safety_category_description IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_source_lang IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2)
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
   l_msg_token := p_safety_category_code || ' ' || p_language;

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

   l_language_code := p_source_lang;
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
      ROLLBACK TO SAVEPOINT Delete_Row;
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
	                        l_msg_token||sqlerrm,
	                        FALSE);
	  x_msg_data := FND_MESSAGE.Get;

END Check_Foreign_Keys;

PROCEDURE Check_Integrity
	   			 (p_called_by_form IN VARCHAR2,
				  p_safety_category_code IN VARCHAR2,
				  p_safety_category_description IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_source_lang IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2)
   IS

/*   Alpha Variables */

L_RETURN_STATUS	  VARCHAR2(1) := 'S';
L_MSG_DATA		  VARCHAR2(2000);
L_CODE_BLOCK	  VARCHAR2(100);

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
LangRecord		c_get_language_code%ROWTYPE;

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
/*		  p_safety_category_code is the code to check.
**	      p_language is the language code part of the key
**		  p_called_by_form is 'T' if called by a form or 'F' if not.
**		  x_rowid is the row id of the record if found.
**		  x_key_exists is 'T' is the record is found, 'F' if not.
*/
		  		 	(p_safety_category_code IN VARCHAR2,
					 p_language IN VARCHAR2,
					 p_called_by_form IN VARCHAR2,
					 x_rowid OUT NOCOPY VARCHAR2,
					 x_key_exists OUT NOCOPY VARCHAR2)
  IS
/*	Alphanumeric variables	 */

L_MSG_DATA VARCHAR2(80);

/*		Declare any variables and the cursor */


CURSOR c_get_categories_tl_rowid
 IS
   SELECT cat.rowid
   FROM	  gr_safety_categories_tl cat
   WHERE  cat.safety_category_code = p_safety_category_code
   AND	  cat.language = p_language;
CategoryTLRecord			   c_get_categories_tl_rowid%ROWTYPE;

BEGIN

   l_msg_data := p_safety_category_code || ' ' || p_language;

   x_key_exists := 'F';
   OPEN c_get_categories_tl_rowid;
   FETCH c_get_categories_tl_rowid INTO CategoryTLRecord;
   IF c_get_categories_tl_rowid%FOUND THEN
      x_key_exists := 'T';
	  x_rowid := CategoryTLRecord.rowid;
   ELSE
      x_key_exists := 'F';
   END IF;
   CLOSE c_get_categories_tl_rowid;

EXCEPTION

	WHEN Others THEN
	  l_msg_data := SUBSTR(SQLERRM, 1, 200);
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
	X_SAFETY_CATEGORY_CODE IN VARCHAR2
	,X_SAFETY_CATEGORY_DESCRIPTION IN VARCHAR2
	,X_LANGUAGE IN VARCHAR2
	,X_SOURCE_LANG IN VARCHAR2
) IS
BEGIN
	UPDATE GR_SAFETY_CATEGORIES_TL SET
		SAFETY_CATEGORY_DESCRIPTION = X_SAFETY_CATEGORY_DESCRIPTION,
		SOURCE_LANG = USERENV('LANG'),
		LAST_UPDATE_DATE = sysdate,
		LAST_UPDATED_BY = 0,
		LAST_UPDATE_LOGIN = 0
	WHERE (SAFETY_CATEGORY_CODE = X_SAFETY_CATEGORY_CODE)
	AND   (USERENV('LANG') IN (LANGUAGE, SOURCE_LANG));
END TRANSLATE_ROW;


PROCEDURE load_row (
	X_SAFETY_CATEGORY_CODE IN VARCHAR2
	,X_SAFETY_CATEGORY_DESCRIPTION IN VARCHAR2
	,X_LANGUAGE IN VARCHAR2
	,X_SOURCE_LANG IN VARCHAR2
) IS
	CURSOR Cur_rowid IS
		SELECT rowid
		FROM GR_SAFETY_CATEGORIES_TL
			WHERE (SAFETY_CATEGORY_CODE = X_SAFETY_CATEGORY_CODE)
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
		GR_SAFETY_CATEGORIES_TL_PKG.UPDATE_ROW(
			P_COMMIT => 'T'
			,P_CALLED_BY_FORM => 'F'
			,P_ROWID => l_row_id
			,P_SAFETY_CATEGORY_CODE => X_SAFETY_CATEGORY_CODE
			,P_SAFETY_CATEGORY_DESCRIPTION => X_SAFETY_CATEGORY_DESCRIPTION
			,P_LANGUAGE => X_LANGUAGE
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
		GR_SAFETY_CATEGORIES_TL_PKG.INSERT_ROW(
			P_COMMIT => 'T'
			,P_CALLED_BY_FORM => 'F'
			,P_SAFETY_CATEGORY_CODE => X_SAFETY_CATEGORY_CODE
			,P_SAFETY_CATEGORY_DESCRIPTION => X_SAFETY_CATEGORY_DESCRIPTION
			,P_LANGUAGE => X_LANGUAGE
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
  delete from GR_SAFETY_CATEGORIES_TL T
  where not exists
    (select NULL
    from GR_SAFETY_CATEGORIES_B B
    where B.SAFETY_CATEGORY_CODE = T.SAFETY_CATEGORY_CODE
    );

  update GR_SAFETY_CATEGORIES_TL T set (
      SAFETY_CATEGORY_DESCRIPTION
    ) = (select
      B.SAFETY_CATEGORY_DESCRIPTION
    from GR_SAFETY_CATEGORIES_TL B
    where B.SAFETY_CATEGORY_CODE = T.SAFETY_CATEGORY_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.SAFETY_CATEGORY_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.SAFETY_CATEGORY_CODE,
      SUBT.LANGUAGE
    from GR_SAFETY_CATEGORIES_TL SUBB, GR_SAFETY_CATEGORIES_TL SUBT
    where SUBB.SAFETY_CATEGORY_CODE = SUBT.SAFETY_CATEGORY_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.SAFETY_CATEGORY_DESCRIPTION <> SUBT.SAFETY_CATEGORY_DESCRIPTION
  ));

  insert into GR_SAFETY_CATEGORIES_TL (
    SAFETY_CATEGORY_CODE,
    SAFETY_CATEGORY_DESCRIPTION,
    LAST_UPDATE_LOGIN,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.SAFETY_CATEGORY_CODE,
    B.SAFETY_CATEGORY_DESCRIPTION,
    B.LAST_UPDATE_LOGIN,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from GR_SAFETY_CATEGORIES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from GR_SAFETY_CATEGORIES_TL T
    where T.SAFETY_CATEGORY_CODE = B.SAFETY_CATEGORY_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);

end NEW_LANGUAGE;

END GR_SAFETY_CATEGORIES_TL_PKG;

/
