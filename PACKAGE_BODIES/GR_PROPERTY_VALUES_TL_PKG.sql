--------------------------------------------------------
--  DDL for Package Body GR_PROPERTY_VALUES_TL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GR_PROPERTY_VALUES_TL_PKG" AS
/*$Header: GRHIPVTB.pls 120.1 2006/06/16 21:40:51 pbamb noship $*/
PROCEDURE Insert_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_property_id IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_value IN VARCHAR2,
				  p_display_order IN VARCHAR2,
				  p_source_lang IN VARCHAR2,
				  p_meaning IN VARCHAR2,
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
			     (p_property_id,
				  p_language,
				  p_value,
				  p_display_order,
				  p_source_lang,
				  p_meaning,
				  l_return_status,
				  l_oracle_error,
				  l_msg_data);
   IF l_return_status <> 'S' THEN
      RAISE Foreign_Key_Error;
   END IF;

/* 	   Now check the primary key doesn't already exist */

   Check_Primary_Key
   	   	   		 (p_property_id,
				  p_language,
				  p_value,
				  'F',
				  l_rowid,
				  l_key_exists);

   IF FND_API.To_Boolean(l_key_exists) THEN
   	  RAISE Item_Exists_Error;
   END IF;

   INSERT INTO gr_property_values_tl
   		  	     (property_id,
				  language,
				  value,
				  display_order,
				  source_lang,
				  meaning,
				  created_by,
				  creation_date,
				  last_updated_by,
				  last_update_date,
				  last_update_login)
          VALUES
		         (p_property_id,
				  p_language,
				  p_value,
				  p_display_order,
				  p_source_lang,
				  p_meaning,
				  p_created_by,
				  p_creation_date,
				  p_last_updated_by,
				  p_last_update_date,
				  p_last_update_login);

/*   Now get the row id of the inserted record */

   Check_Primary_Key
   	   	   		 (p_property_id,
				  p_language,
				  p_value,
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
	  l_msg_token := p_property_id || ' ' || p_language;
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
	  l_msg_token := p_property_id || ' ' || p_language;
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
	  l_msg_token := p_property_id || ' ' || p_language;
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
				  p_property_id IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_value IN VARCHAR2,
				  p_display_order IN VARCHAR2,
				  p_source_lang IN VARCHAR2,
				  p_meaning IN VARCHAR2,
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
   l_msg_token := p_property_id || ' ' || p_language || ' ' || p_value;

/*	  Now call the check foreign key procedure */

   Check_Foreign_Keys
			     (p_property_id,
				  p_language,
				  p_value,
				  p_display_order,
				  p_source_lang,
				  p_meaning,
				  l_return_status,
				  l_oracle_error,
				  l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Foreign_Key_Error;
   ELSE
      UPDATE gr_property_values_tl
	  SET	 property_id	 	 		 	 = p_property_id,
	  		 language						 = p_language,
			 value							 = p_value,
			 display_order					 = p_display_order,
			 source_lang					 = p_source_lang,
			 meaning					 	 = p_meaning,
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
				  p_property_id IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_value IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2)
 IS


/*   Alpha Variables */

L_RETURN_STATUS	  	VARCHAR2(1) := 'S';
L_MSG_DATA		  	VARCHAR2(2000);
L_MSG_TOKEN		  	VARCHAR2(100);
L_BASE_DESC			VARCHAR2(30);
L_PROPERTY_MEANING	VARCHAR2(80);
L_LANGUAGE		  	VARCHAR2(4);
L_VALUE			VARCHAR2(30);
L_CREATION_DATE	 	DATE;
L_LAST_UPDATE_DATE	DATE;

/*   Number Variables */

L_ORACLE_ERROR	  	NUMBER;
L_CREATED_BY		NUMBER;
L_LAST_UPDATED_BY	NUMBER;
L_LAST_UPDATE_LOGIN	NUMBER;
L_DISPLAY_ORDER	 	NUMBER;

/*	Exceptions */

LANGUAGE_MISSING_ERROR	EXCEPTION;


/*   Cursors */

CURSOR c_get_descs_value
 IS
   SELECT		pv.value
   FROM	    gr_property_values_tl pv
   WHERE	pv.property_id = p_property_id
   AND		pv.language = l_language
   AND          pv.value = l_value;

CURSOR c_get_descs
 IS
   SELECT		pv.value,
			pv.meaning,
			pv.display_order,
		        pv.created_by,
			pv.creation_date,
			pv.last_updated_by,
			pv.last_update_date,
			pv.last_update_login
   FROM	    gr_property_values_tl pv
   WHERE	pv.property_id = p_property_id
   AND		pv.language = l_language;

PropertyDesc				c_get_descs%ROWTYPE;
PropertyDesc_value			c_get_descs_value%ROWTYPE;

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
   l_msg_token := p_property_id || ' ' || p_language;

/* Remove translations with no base row */

  delete from GR_PROPERTY_VALUES_TL T
  where not exists
    (select NULL
    from GR_PROPERTIES_B B
    where B.PROPERTY_ID = T.PROPERTY_ID
    );

/* Redefault translations from the source language  */

   update gr_property_values_tl t set (
    meaning ) =
    ( select
      B.MEANING
      from GR_PROPERTY_VALUES_TL B
      where B.PROPERTY_ID = T.PROPERTY_ID
      and B.LANGUAGE = T.SOURCE_LANG
      and B.VALUE = T.VALUE)
   where (
      T.PROPERTY_ID,
      T.LANGUAGE,
      T.VALUE
   ) in (select
         SUBT.PROPERTY_ID,
         SUBT.LANGUAGE,
         SUBT.VALUE
         from GR_PROPERTY_VALUES_TL SUBB, GR_PROPERTY_VALUES_TL SUBT
         where SUBB.PROPERTY_ID = SUBT.PROPERTY_ID
         and SUBB.LANGUAGE = SUBT.SOURCE_LANG
         and SUBB.VALUE    = SUBT.VALUE
         and (SUBB.MEANING <> SUBT.MEANING
          or (SUBB.MEANING is null and SUBT.MEANING is not null)
          or (SUBB.MEANING is not null and SUBT.MEANING is null)
  ));



/*	Open the language cursor and get the description entered from the
**	user environment variable.
*/
    l_language	:= p_language;
    OPEN c_get_descs;
    LOOP
      FETCH c_get_descs INTO PropertyDesc;
      EXIT WHEN c_get_descs%NOTFOUND;
      l_value := PropertyDesc.value;
      l_display_order := PropertyDesc.display_order;
      l_property_meaning := PropertyDesc.meaning;
      l_created_by := PropertyDesc.created_by;
      l_creation_date := PropertyDesc.creation_date;
      l_last_updated_by := PropertyDesc.last_updated_by;
      l_last_update_date := PropertyDesc.last_update_date;
      l_last_update_login := PropertyDesc.last_update_login;

/*	Read fnd_languages for the installed and base languages.
**	For those that are found, read the values table.
**	If there isn't a record in the table for that language then
**	insert it and go on to the next.
*/


      OPEN c_get_installed_languages;
      FETCH c_get_installed_languages INTO InstLang;
      IF c_get_installed_languages%FOUND THEN
        WHILE c_get_installed_languages%FOUND LOOP
	  IF InstLang.language_code <> p_language THEN
		    l_language := InstLang.language_code;
   		    OPEN c_get_descs_value;
		    FETCH c_get_descs_value INTO PropertyDesc_Value;
		    IF c_get_descs_value%NOTFOUND THEN
			   INSERT INTO gr_property_values_tl
						(property_id,
						 language,
						 value,
						 display_order,
						 source_lang,
						 meaning,
						 created_by,
						 creation_date,
						 last_updated_by,
						 last_update_date,
						 last_update_login)
				   VALUES
				        (p_property_id,
						 l_language,
						 l_value,
						 l_display_order,
						 p_language,
						 l_property_meaning,
						 l_created_by,
						 l_creation_date,
						 l_last_updated_by,
						 l_last_update_date,
						 l_last_update_login);
                   END IF;
       		   CLOSE c_get_descs_value;
	  END IF;
	  FETCH c_get_installed_languages INTO InstLang;
        END LOOP;
      END IF;
      CLOSE c_get_installed_languages;
    END LOOP;
    CLOSE c_get_descs;
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
				  p_property_id IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_value IN VARCHAR2,
				  p_display_order IN VARCHAR2,
				  p_source_lang IN VARCHAR2,
				  p_meaning IN VARCHAR2,
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
L_MSG_TOKEN		  VARCHAR2(100);

/*  Number Variables */

L_ORACLE_ERROR	  NUMBER;

/*   Exceptions */

NO_DATA_FOUND_ERROR 		EXCEPTION;
ROW_ALREADY_LOCKED_ERROR 	EXCEPTION;
PRAGMA EXCEPTION_INIT(ROW_ALREADY_LOCKED_ERROR,-54);

/*   Define the cursors */

CURSOR c_lock_property_values
 IS
   SELECT	*
   FROM		gr_property_values_tl
   WHERE	rowid = p_rowid
   FOR UPDATE NOWAIT;
LockValueRcd	  c_lock_property_values%ROWTYPE;
BEGIN

/*      Initialization Routine */

   SAVEPOINT Lock_Row;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;
   l_msg_token := p_property_id || ' ' || p_language;

/*	   Now lock the record */

   OPEN c_lock_property_values;
   FETCH c_lock_property_values INTO LockValueRcd;
   IF c_lock_property_values%NOTFOUND THEN
	  CLOSE c_lock_property_values;
	  RAISE No_Data_Found_Error;
   END IF;
   CLOSE c_lock_property_values;

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
				  p_property_id IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_value IN VARCHAR2,
				  p_display_order IN VARCHAR2,
				  p_source_lang IN VARCHAR2,
				  p_meaning IN VARCHAR2,
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
   l_msg_token := p_property_id || ' ' || p_language || ' ' || p_value;

/*  Now call the check integrity procedure */

   Check_Integrity
			     (p_called_by_form,
			      p_property_id,
				  p_language,
				  p_value,
				  p_display_order,
				  p_source_lang,
				  p_meaning,
				  l_return_status,
				  l_oracle_error,
				  l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Check_Integrity_Error;
   END IF;

   DELETE FROM gr_property_values_tl
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
	              p_property_id IN VARCHAR2,
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
   l_msg_token := p_property_id;

   DELETE FROM gr_property_values_tl
   WHERE 	   property_id = p_property_id;

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
	   			 (p_property_id IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_value IN VARCHAR2,
				  p_display_order IN VARCHAR2,
				  p_source_lang IN VARCHAR2,
				  p_meaning IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2)
   IS

/*   Alpha Variables */

L_RETURN_STATUS	  VARCHAR2(1) := 'S';
L_MSG_DATA		  VARCHAR2(2000);
L_MSG_TOKEN       VARCHAR2(100);
L_LANGUAGE_CODE	  VARCHAR2(4);

/*   Number Variables */

L_ORACLE_ERROR	  NUMBER;

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
   l_msg_token := p_property_id || ' ' || p_language;

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
	                        l_msg_token,
	                        FALSE);
	  x_msg_data := FND_MESSAGE.Get;

END Check_Foreign_Keys;

PROCEDURE Check_Integrity
	   			 (p_called_by_form IN VARCHAR2,
				  p_property_id IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_value IN VARCHAR2,
				  p_display_order IN VARCHAR2,
				  p_source_lang IN VARCHAR2,
				  p_meaning IN VARCHAR2,
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
/*		  p_property_id is the property code to check.
**	      p_language is the language code part of the key
**		  p_called_by_form is 'T' if called by a form or 'F' if not.
**		  x_rowid is the row id of the record if found.
**		  x_key_exists is 'T' is the record is found, 'F' if not.
*/
		  		 	(p_property_id IN VARCHAR2,
					 p_language IN VARCHAR2,
					 p_value IN VARCHAR2,
					 p_called_by_form IN VARCHAR2,
					 x_rowid OUT NOCOPY VARCHAR2,
					 x_key_exists OUT NOCOPY VARCHAR2)
  IS
/*	Alphanumeric variables	 */

L_MSG_DATA VARCHAR2(80);

/*		Declare any variables and the cursor */


CURSOR c_get_property_values_rowid
 IS
   SELECT pv.rowid
   FROM	  gr_property_values_tl pv
   WHERE  pv.property_id = p_property_id
   AND	  pv.language = p_language
   AND	  pv.value = p_value;
PropertyTLRecord			   c_get_property_values_rowid%ROWTYPE;

BEGIN

   l_msg_data := p_property_id || ' ' || p_language;

   x_key_exists := 'F';
   OPEN c_get_property_values_rowid;
   FETCH c_get_property_values_rowid INTO PropertyTLRecord;
   IF c_get_property_values_rowid%FOUND THEN
      x_key_exists := 'T';
	  x_rowid := PropertyTLRecord.rowid;
   ELSE
      x_key_exists := 'F';
   END IF;
   CLOSE c_get_property_values_rowid;

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
	X_PROPERTY_ID IN VARCHAR2
	,X_LANGUAGE IN VARCHAR2
	,X_VALUE IN VARCHAR2
	,X_DISPLAY_ORDER IN NUMBER
	,X_SOURCE_LANG IN VARCHAR2
	,X_MEANING IN VARCHAR2
) IS
BEGIN
	UPDATE GR_PROPERTY_VALUES_TL SET
		MEANING = X_MEANING,
		SOURCE_LANG = USERENV('LANG'),
		LAST_UPDATE_DATE = sysdate,
		LAST_UPDATED_BY = 1,
		LAST_UPDATE_LOGIN = 0
	WHERE (PROPERTY_ID = X_PROPERTY_ID)
	AND   (VALUE = X_VALUE)
	AND   (USERENV('LANG') IN (LANGUAGE, SOURCE_LANG));
END TRANSLATE_ROW;


PROCEDURE load_row (
	X_PROPERTY_ID IN VARCHAR2
	,X_LANGUAGE IN VARCHAR2
	,X_VALUE IN VARCHAR2
	,X_DISPLAY_ORDER IN NUMBER
	,X_SOURCE_LANG IN VARCHAR2
	,X_MEANING IN VARCHAR2
) IS
	CURSOR Cur_rowid IS
		SELECT rowid
		FROM GR_PROPERTY_VALUES_TL
			WHERE (PROPERTY_ID = X_PROPERTY_ID)	AND   (VALUE = X_VALUE)
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
		GR_PROPERTY_VALUES_TL_PKG.UPDATE_ROW(
			P_COMMIT => 'T'
			,P_CALLED_BY_FORM => 'F'
			,P_ROWID => l_row_id
			,P_PROPERTY_ID => X_PROPERTY_ID
			,P_LANGUAGE => X_LANGUAGE
			,P_VALUE => X_VALUE
			,P_DISPLAY_ORDER => X_DISPLAY_ORDER
			,P_SOURCE_LANG => X_SOURCE_LANG
			,P_MEANING => X_MEANING
			,P_CREATED_BY => l_user_id
			,P_CREATION_DATE => sysdate
			,P_LAST_UPDATED_BY => l_user_id
			,P_LAST_UPDATE_DATE => sysdate
			,P_LAST_UPDATE_LOGIN => 0
			,X_RETURN_STATUS => l_return_status
			,X_ORACLE_ERROR => l_oracle_error
			,X_MSG_DATA => l_msg_data);
	ELSE
		GR_PROPERTY_VALUES_TL_PKG.INSERT_ROW(
			P_COMMIT => 'T'
			,P_CALLED_BY_FORM => 'F'
			,P_PROPERTY_ID => X_PROPERTY_ID
			,P_LANGUAGE => X_LANGUAGE
			,P_VALUE => X_VALUE
			,P_DISPLAY_ORDER => X_DISPLAY_ORDER
			,P_SOURCE_LANG => X_SOURCE_LANG
			,P_MEANING => X_MEANING
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


/*     21-Jan-2002     Melanie Grosser         BUG 2190024 - Added procedure NEW_LANGUAGE
                                               to be called from GRNLINS.sql. Generated
                                               from tltblgen.
*/
procedure NEW_LANGUAGE
is
begin
  update GR_PROPERTY_VALUES_TL T set (
      MEANING,
      DISPLAY_ORDER
    ) = (select
      B.MEANING,
      B.DISPLAY_ORDER
    from GR_PROPERTY_VALUES_TL B
    where B.PROPERTY_ID = T.PROPERTY_ID
    and B.VALUE = T.VALUE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.PROPERTY_ID,
      T.VALUE,
      T.LANGUAGE
  ) in (select
      SUBT.PROPERTY_ID,
      SUBT.VALUE,
      SUBT.LANGUAGE
    from GR_PROPERTY_VALUES_TL SUBB, GR_PROPERTY_VALUES_TL SUBT
    where SUBB.PROPERTY_ID = SUBT.PROPERTY_ID
    and SUBB.VALUE = SUBT.VALUE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.MEANING <> SUBT.MEANING
      or (SUBB.MEANING is null and SUBT.MEANING is not null)
      or (SUBB.MEANING is not null and SUBT.MEANING is null)
      or SUBB.DISPLAY_ORDER <> SUBT.DISPLAY_ORDER
  ));

  insert into GR_PROPERTY_VALUES_TL (
    PROPERTY_ID,
    VALUE,
    DISPLAY_ORDER,
    MEANING,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.PROPERTY_ID,
    B.VALUE,
    B.DISPLAY_ORDER,
    B.MEANING,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from GR_PROPERTY_VALUES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from GR_PROPERTY_VALUES_TL T
    where T.PROPERTY_ID = B.PROPERTY_ID
    and T.VALUE = B.VALUE
    and T.LANGUAGE = L.LANGUAGE_CODE);

end NEW_LANGUAGE;



END GR_PROPERTY_VALUES_TL_PKG;

/
