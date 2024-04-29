--------------------------------------------------------
--  DDL for Package Body GR_OTHER_NAMES_TL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GR_OTHER_NAMES_TL_PKG" AS
/*$Header: GRHIONTB.pls 115.13 2002/10/28 17:03:11 methomas ship $*/
PROCEDURE Insert_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_item_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_orgn_code IN VARCHAR2,
				  p_synonym_sequence_number IN NUMBER,
				  p_source_lang IN VARCHAR2,
				  p_item_other_name IN VARCHAR2,
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
			     (p_item_code,
				  p_language,
				  p_orgn_code,
				  p_synonym_sequence_number,
				  p_source_lang,
				  p_item_other_name,
				  l_return_status,
				  l_oracle_error,
				  l_msg_data);
   IF l_return_status <> 'S' THEN
      RAISE Foreign_Key_Error;
   END IF;

/* 	   Now check the primary key doesn't already exist */

   Check_Primary_Key
   	   	   		 (p_item_code,
				  p_orgn_code,
				  p_language,
				  p_synonym_sequence_number,
				  'F',
				  l_rowid,
				  l_key_exists);

   IF FND_API.To_Boolean(l_key_exists) THEN
   	  RAISE Item_Exists_Error;
   END IF;

   INSERT INTO gr_other_names_tl
   		  	     (item_code,
				  language,
				  orgn_code,
				  synonym_sequence_number,
				  source_lang,
				  item_other_name,
				  created_by,
				  creation_date,
				  last_updated_by,
				  last_update_date,
				  last_update_login)
          VALUES
		         (p_item_code,
				  p_language,
				  p_orgn_code,
				  p_synonym_sequence_number,
				  p_source_lang,
				  p_item_other_name,
				  p_created_by,
				  p_creation_date,
				  p_last_updated_by,
				  p_last_update_date,
				  p_last_update_login);

/*   Now get the row id of the inserted record */

   Check_Primary_Key
   	   	   		 (p_item_code,
				  p_orgn_code,
				  p_language,
				  p_synonym_sequence_number,
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
	  l_msg_token := p_item_code || ' ' || p_orgn_code || ' ' || p_language;
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
	  l_msg_token := p_item_code || ' ' || p_orgn_code || ' ' || p_language;
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
	  l_msg_token := p_item_code || ' ' || p_orgn_code || ' ' || p_language;
	  x_return_status := 'U';
	  x_oracle_error := APP_EXCEPTION.Get_Code;
	  l_msg_data := APP_EXCEPTION.Get_Text;
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
				  p_item_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_orgn_code IN VARCHAR2,
				  p_synonym_sequence_number IN NUMBER,
				  p_source_lang IN VARCHAR2,
				  p_item_other_name IN VARCHAR2,
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
   l_msg_token := p_item_code || ' ' || p_orgn_code || ' ' || p_language;

/*	  Now call the check foreign key procedure */

   Check_Foreign_Keys
			     (p_item_code,
				  p_language,
				  p_orgn_code,
				  p_synonym_sequence_number,
				  p_source_lang,
				  p_item_other_name,
				  l_return_status,
				  l_oracle_error,
				  l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Foreign_Key_Error;
   ELSE
      UPDATE gr_other_names_tl
	  SET	 item_code						 = p_item_code,
			 language	  					 = p_language,
			 orgn_code	  					 = p_orgn_code,
			 synonym_sequence_number		 = p_synonym_sequence_number,
			 source_lang	  				 = p_source_lang,
			 item_other_name	  			 = p_item_other_name,
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
	  x_oracle_error := APP_EXCEPTION.Get_Code;
	  l_msg_data := APP_EXCEPTION.Get_Text;
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
				  p_item_code IN VARCHAR2,
				  p_orgn_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2)
 IS

/*   Alpha Variables */

L_RETURN_STATUS	  		VARCHAR2(1) := 'S';
L_MSG_DATA		  		VARCHAR2(2000);
L_MSG_TOKEN		  		VARCHAR2(100);
L_BASE_DESC				VARCHAR2(240);
L_ORGN_CODE				VARCHAR2(4);
L_LANGUAGE		  		VARCHAR2(4);
L_BASE_LANG		  		VARCHAR2(4);
L_CREATION_DATE	 		DATE;
L_LAST_UPDATE_DATE		DATE;

/*   Number Variables */

L_ORACLE_ERROR	  	NUMBER;
L_CREATED_BY		NUMBER;
L_LAST_UPDATED_BY	NUMBER;
L_LAST_UPDATE_LOGIN	NUMBER;
L_SYNONYM_SEQUENCE	NUMBER;
L_EXISTS		NUMBER;
/*	Exceptions */

LANGUAGE_MISSING_ERROR	EXCEPTION;


/*   Cursors */

CURSOR c_get_descs
 IS
   SELECT		ion.item_other_name,
			ion.orgn_code,
			ion.synonym_sequence_number,
        		ion.created_by,
			ion.creation_date,
			ion.last_updated_by,
			ion.last_update_date,
			ion.last_update_login,
			ion.language
   FROM	    gr_other_names_tl ion
   WHERE	ion.item_code = p_item_code
   AND	 	ion.orgn_code = p_orgn_code
   AND		(ion.language = l_language OR
                 synonym_sequence_number NOT IN (SELECT synonym_sequence_number
                 				 FROM   gr_other_names_tl
                 				 WHERE  item_code = p_item_code
                 				 AND    orgn_code = p_orgn_code
                 				 AND    language = l_language));
OtherNameDesc				c_get_descs%ROWTYPE;

CURSOR c_get_descs_sequence
 IS
   SELECT	1
   FROM	    	gr_other_names_tl ion
   WHERE	ion.item_code = p_item_code
   AND	 	ion.orgn_code = p_orgn_code
   AND		ion.language = l_language
   AND          ion.synonym_sequence_number = l_synonym_sequence;

CURSOR c_get_installed_languages
 IS
   SELECT	lng.language_code
   FROM	 	fnd_languages lng
   WHERE	lng.installed_flag IN ('I', 'B');
InstLang				c_get_installed_languages%ROWTYPE;


BEGIN

/*	Initialization Routine  */

   SAVEPOINT Add_Language;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;
   l_msg_token := p_item_code || ' ' || p_orgn_code || ' ' || p_language;

/* Remove translations with no base row */

  delete from GR_OTHER_NAMES_TL T
  where not exists
    (select NULL
    from GR_ITEM_GENERAL B,
         SY_ORGN_MST S
    where B.ITEM_CODE = T.ITEM_CODE
    and   S.ORGN_CODE = T.ORGN_CODE
    );

/* Redefault translations from the source language  */

   update gr_other_names_tl t set (
    item_other_name ) =
    ( select
      B.ITEM_OTHER_NAME
      from GR_OTHER_NAMES_TL B
      where B.ITEM_CODE = T.ITEM_CODE
      and B.ORGN_CODE = T.ORGN_CODE
      and B.LANGUAGE = T.SOURCE_LANG
      and B.SYNONYM_SEQUENCE_NUMBER = T.SYNONYM_SEQUENCE_NUMBER)
   where (
      T.ITEM_CODE,
      T.ORGN_CODE,
      T.LANGUAGE
   ) in (select
         SUBT.ITEM_CODE,
         SUBT.ORGN_CODE,
         SUBT.LANGUAGE
         from GR_OTHER_NAMES_TL SUBB, GR_OTHER_NAMES_TL SUBT
         where SUBB.ITEM_CODE = SUBT.ITEM_CODE
         and SUBB.ORGN_CODE = SUBT.ORGN_CODE
         and SUBB.LANGUAGE = SUBT.SOURCE_LANG
         and (SUBB.ITEM_OTHER_NAME <> SUBT.ITEM_OTHER_NAME
          or (SUBB.ITEM_OTHER_NAME is null and SUBT.ITEM_OTHER_NAME is not null)
          or (SUBB.ITEM_OTHER_NAME is not null and SUBT.ITEM_OTHER_NAME is null)
  ));


/*	Open the language cursor and get the description entered from the
**	user environment variable.
*/
   l_language := p_language;
   OPEN c_get_descs;
   FETCH c_get_descs INTO OtherNameDesc;
   IF c_get_descs%NOTFOUND THEN
      CLOSE c_get_descs;
      RAISE Language_Missing_Error;
   ELSE
     LOOP
          l_base_lang := OtherNameDesc.language;
          l_base_desc := OtherNameDesc.item_other_name;
	  l_orgn_code := OtherNameDesc.orgn_code;
	  l_synonym_sequence := OtherNameDesc.synonym_sequence_number;
	  l_created_by := OtherNameDesc.created_by;
	  l_creation_date := OtherNameDesc.creation_date;
	  l_last_updated_by := OtherNameDesc.last_updated_by;
	  l_last_update_date := OtherNameDesc.last_update_date;
	  l_last_update_login := OtherNameDesc.last_update_login;

/*	Read fnd_languages for the installed and base languages.
**	For those that are found, read the phrases tl table.
**	If there isn't a record in the table for that language then
**	insert it and go on to the next.
*/
	   OPEN c_get_installed_languages;
	   FETCH c_get_installed_languages INTO InstLang;
	   IF c_get_installed_languages%FOUND THEN
	      WHILE c_get_installed_languages%FOUND LOOP
		IF InstLang.language_code <> l_base_lang THEN
		    l_language := InstLang.language_code;
			OPEN c_get_descs_sequence;
			FETCH c_get_descs_sequence INTO l_exists;
			IF c_get_descs_sequence%NOTFOUND THEN
			   CLOSE c_get_descs_sequence;
			   INSERT INTO gr_other_names_tl
						(item_code,
						 language,
						 orgn_code,
						 synonym_sequence_number,
						 source_lang,
						 item_other_name,
						 created_by,
						 creation_date,
						 last_updated_by,
						 last_update_date,
						 last_update_login)
				   VALUES
				        (p_item_code,
						 l_language,
						 l_orgn_code,
						 l_synonym_sequence,
						 p_language,
						 l_base_desc,
 					     l_created_by,
						 l_creation_date,
						 l_last_updated_by,
						 l_last_update_date,
						 l_last_update_login);
			ELSE
			   CLOSE c_get_descs_sequence;
			END IF;
	           END IF;
  		   FETCH c_get_installed_languages INTO InstLang;
	       END LOOP;
	   END IF;
	   CLOSE c_get_installed_languages;
           FETCH c_get_descs INTO OtherNameDesc;
           EXIT WHEN c_get_descs%NOTFOUND;
       END LOOP;
       CLOSE c_get_descs;
     END IF;

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
	  x_oracle_error := APP_EXCEPTION.Get_Code;
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
				  p_item_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_orgn_code IN VARCHAR2,
				  p_synonym_sequence_number IN NUMBER,
				  p_source_lang IN VARCHAR2,
				  p_item_other_name IN VARCHAR2,
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

CURSOR c_lock_other_name_tl
 IS
   SELECT	*
   FROM		gr_other_names_tl
   WHERE	rowid = p_rowid
   FOR UPDATE NOWAIT;
LockOtherNameRcd	  c_lock_other_name_tl%ROWTYPE;

BEGIN

/*      Initialization Routine */

   SAVEPOINT Lock_Row;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;
   l_msg_token := p_item_code || ' ' || p_orgn_code || ' ' || p_language;

/*	   Now lock the record */

   OPEN c_lock_other_name_tl;
   FETCH c_lock_other_name_tl INTO LockOtherNameRcd;
   IF c_lock_other_name_tl%NOTFOUND THEN
	  CLOSE c_lock_other_name_tl;
	  RAISE No_Data_Found_Error;
   END IF;
   CLOSE c_lock_other_name_tl;

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
	  x_oracle_error := APP_EXCEPTION.Get_Code;
	  l_msg_data := APP_EXCEPTION.Get_Text;
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
				  p_item_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_orgn_code IN VARCHAR2,
				  p_synonym_sequence_number IN NUMBER,
				  p_source_lang IN VARCHAR2,
				  p_item_other_name IN VARCHAR2,
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

/*	Define the cursor */

BEGIN

/*   Initialization Routine */

   SAVEPOINT Delete_Row;
   x_return_status := 'S';
   l_called_by_form := 'F';
   x_oracle_error := 0;
   x_msg_data := NULL;
   l_msg_token := p_item_code || ' ' || p_orgn_code || ' ' || p_language;

/*  Now call the check integrity procedure */

   Check_Integrity
			     (l_called_by_form,
				  p_item_code,
				  p_language,
				  p_orgn_code,
				  p_synonym_sequence_number,
				  p_source_lang,
				  p_item_other_name,
				  l_return_status,
				  l_oracle_error,
				  l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Check_Integrity_Error;
   END IF;

   DELETE FROM gr_other_names_tl
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
	  x_oracle_error := APP_EXCEPTION.Get_Code;
	  l_msg_data := APP_EXCEPTION.Get_Text;
	  l_msg_data := APP_EXCEPTION.Get_Text;
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
				  p_delete_option IN VARCHAR2,
	              p_item_code IN VARCHAR2,
				  p_orgn_code IN VARCHAR2,
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

/*	 Excceptions */

NULL_DELETE_OPTION_ERROR	EXCEPTION;

/*   Define the cursors */

BEGIN

/*   Initialization Routine */

   SAVEPOINT Delete_Rows;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;
   l_msg_token := p_item_code || ' ' || p_orgn_code;

/*
**		p_delete_option has one of three values.
**	    'I' - Delete all rows for the item in p_item_code.
**		'O' - Delete all rows for the label in p_orgn_code.
**		'B' - Delete all rows for the item and label codes.
*/
   IF p_delete_option = 'I' THEN
      IF p_item_code IS NULL THEN
	     l_msg_token := 'Item Code';
	     RAISE Null_Delete_Option_Error;
	  ELSE
	     l_msg_token := p_item_code;

         DELETE FROM  gr_other_names_tl
         WHERE		  item_code = p_item_code;
   	  END IF;
   ELSIF p_delete_option = 'O' THEN
      IF p_orgn_code IS NULL THEN
	     l_msg_token := 'Organisation Code';
		 RAISE Null_Delete_Option_Error;
	  ELSE
	     l_msg_token := p_orgn_code;

         DELETE FROM	gr_other_names_tl
         WHERE			orgn_code = p_orgn_code;
	  END IF;
   ELSIF p_delete_option = 'B' THEN
      IF p_item_code IS NULL OR
	     p_orgn_code IS NULL THEN
		 l_msg_token := 'Item Code / Organisation Code';
		 RAISE Null_Delete_Option_Error;
	  ELSE
	     l_msg_token := p_item_code || ' ' || p_orgn_code;

		 DELETE FROM	gr_other_names_tl
		 WHERE			item_code = p_item_code
		 AND			orgn_code = p_orgn_code;
	  END IF;
   END IF;

   IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
   END IF;

EXCEPTION

   WHEN Null_Delete_Option_Error THEN
	  x_return_status := 'E';
	  x_oracle_error := APP_EXCEPTION.Get_Code;
      FND_MESSAGE.SET_NAME('GR',
                           'GR_NULL_VALUE');
      FND_MESSAGE.SET_TOKEN('CODE',
         		            l_msg_token,
            			    FALSE);
      IF FND_API.To_Boolean(p_called_by_form) THEN
	     APP_EXCEPTION.Raise_Exception;
	  ELSE
         x_msg_data := FND_MESSAGE.Get;
	  END IF;

   WHEN OTHERS THEN
      ROLLBACK TO SAVEPOINT Delete_Rows;
	  x_return_status := 'U';
	  x_oracle_error := APP_EXCEPTION.Get_Code;
	  l_msg_data := APP_EXCEPTION.Get_Text;
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
	   			 (p_item_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_orgn_code IN VARCHAR2,
				  p_synonym_sequence_number IN NUMBER,
				  p_source_lang IN VARCHAR2,
				  p_item_other_name IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2)
   IS

/*   Alpha Variables */

L_RETURN_STATUS	  VARCHAR2(1) := 'S';
L_MSG_DATA		  VARCHAR2(2000);
L_MSG_TOKEN       VARCHAR2(100);
L_LANGUAGE_CODE   VARCHAR2(4);
L_ROWID			  VARCHAR2(18);
L_KEY_EXISTS	  VARCHAR2(1);

/*   Number Variables */

L_ORACLE_ERROR	  NUMBER;

/*	Error Definitions */

ROW_MISSING_ERROR			EXCEPTION;

/*   Define the cursors */

/*	 Language Codes */

CURSOR c_get_language
 IS
   SELECT 	lng.language_code
   FROM		fnd_languages lng
   WHERE	lng.language_code = l_language_code;
LangRecord			c_get_language%ROWTYPE;

/*	 Organisation Codes */

CURSOR c_get_orgn
 IS
   SELECT	om.orgn_code
   FROM		sy_orgn_mst om
   WHERE	orgn_code = p_orgn_code;
OrgnRecord 			c_get_orgn%ROWTYPE;

BEGIN

/*   Initialization Routine */

   SAVEPOINT Check_Foreign_Keys;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;
   l_msg_token := p_item_code || ' ' || p_orgn_code || ' ' || p_language;

/*	Check the item code */

   GR_ITEM_GENERAL_PKG.Check_Primary_Key
   					(p_item_code,
					 'F',
					 l_rowid,
					 l_key_exists);
   IF NOT FND_API.To_Boolean(l_key_exists) THEN
      x_return_status := 'E';
      FND_MESSAGE.SET_NAME('GR',
                           'GR_RECORD_NOT_FOUND');
      FND_MESSAGE.SET_TOKEN('CODE',
                            p_item_code,
   	    			   	    FALSE);
	  l_msg_data := l_msg_data || FND_MESSAGE.Get || ' ';
   END IF;

/*	Check the organization code */

   OPEN c_get_orgn;
   FETCH c_get_orgn INTO OrgnRecord;
   IF c_get_orgn%NOTFOUND THEN
      CLOSE c_get_orgn;
	  l_msg_token := p_orgn_code;
	  RAISE Row_Missing_Error;
   END IF;
   CLOSE c_get_orgn;

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
	  x_oracle_error := APP_EXCEPTION.Get_Code;
	  l_msg_data := APP_EXCEPTION.Get_Text;
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_UNEXPECTED_ERROR');
	  FND_MESSAGE.SET_TOKEN('TEXT',
	                        l_msg_token,
	                        FALSE);
	  x_msg_data := FND_MESSAGE.Get;

END Check_Foreign_Keys;

PROCEDURE Check_Integrity
	   			 (p_called_by_form IN VARCHAR2,
	   			  p_item_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_orgn_code IN VARCHAR2,
				  p_synonym_sequence_number IN NUMBER,
				  p_source_lang IN VARCHAR2,
				  p_item_other_name IN VARCHAR2,
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
	  x_oracle_error := APP_EXCEPTION.Get_Code;
	  l_msg_data := APP_EXCEPTION.Get_Text;
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
/*		  p_item_code is the item code to check.
**		  p_orgn_code is the label code to check.
**	      p_language is the language code part of the key.
**		  p_synonym_sequence_number is the sequence number.
**		  p_called_by_form is 'T' if called by a form or 'F' if not.
**		  x_rowid is the row id of the record if found.
**		  x_key_exists is 'T' is the record is found, 'F' if not.
*/
		  		 	(p_item_code IN VARCHAR2,
					 p_orgn_code IN VARCHAR2,
					 p_language IN VARCHAR2,
					 p_synonym_sequence_number IN NUMBER,
					 p_called_by_form IN VARCHAR2,
					 x_rowid OUT NOCOPY VARCHAR2,
					 x_key_exists OUT NOCOPY VARCHAR2)
  IS
/*	Alphanumeric variables	 */

L_MSG_DATA VARCHAR2(80);

/*		Declare any variables and the cursor */


CURSOR c_get_other_name_tl_rowid
 IS
   SELECT ion.rowid
   FROM	  gr_other_names_tl ion
   WHERE  ion.item_code = p_item_code
   AND	  ion.orgn_code = p_orgn_code
   AND	  ion.language = p_language
   AND	  ion.synonym_sequence_number = p_synonym_sequence_number;
OtherNameTLRecord			   c_get_other_name_tl_rowid%ROWTYPE;

BEGIN

   l_msg_data := p_item_code || ' ' || p_orgn_code || ' ' || p_language;

   x_key_exists := 'F';
   OPEN c_get_other_name_tl_rowid;
   FETCH c_get_other_name_tl_rowid INTO OtherNameTLRecord;
   IF c_get_other_name_tl_rowid%FOUND THEN
      x_key_exists := 'T';
	  x_rowid := OtherNameTLRecord.rowid;
   ELSE
      x_key_exists := 'F';
   END IF;
   CLOSE c_get_other_name_tl_rowid;

EXCEPTION

	WHEN Others THEN
	  l_msg_data := APP_EXCEPTION.Get_Text;
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_UNEXPECTED_ERROR');
	  FND_MESSAGE.SET_TOKEN('TEXT',
	                        l_msg_data,
	                        FALSE);
      IF FND_API.To_Boolean(p_called_by_form) THEN
	     APP_EXCEPTION.Raise_Exception;
	  END IF;

END Check_Primary_Key;

/*     21-Jan-2002     Mercy Thomas   BUG 2190024 - Added procedure NEW_LANGUAGE
                       to be called from GRNLINS.sql. Generated from tltblgen. */

PROCEDURE NEW_LANGUAGE IS
begin
  delete from GR_OTHER_NAMES_TL T
  where not exists
    (select NULL
    from GR_ITEM_GENERAL B,
         SY_ORGN_MST S
    where B.ITEM_CODE = T.ITEM_CODE
    and   S.ORGN_CODE = T.ORGN_CODE
    );

/* Redefault translations from the source language  */

   update gr_other_names_tl t set (
    item_other_name ) =
    ( select
      B.ITEM_OTHER_NAME
      from GR_OTHER_NAMES_TL B
      where B.ITEM_CODE = T.ITEM_CODE
      and B.ORGN_CODE = T.ORGN_CODE
      and B.LANGUAGE = T.SOURCE_LANG
      and B.SYNONYM_SEQUENCE_NUMBER = T.SYNONYM_SEQUENCE_NUMBER)
   where (
      T.ITEM_CODE,
      T.ORGN_CODE,
      T.LANGUAGE
   ) in (select
         SUBT.ITEM_CODE,
         SUBT.ORGN_CODE,
         SUBT.LANGUAGE
         from GR_OTHER_NAMES_TL SUBB, GR_OTHER_NAMES_TL SUBT
         where SUBB.ITEM_CODE = SUBT.ITEM_CODE
         and SUBB.ORGN_CODE = SUBT.ORGN_CODE
         and SUBB.LANGUAGE = SUBT.SOURCE_LANG
         and (SUBB.ITEM_OTHER_NAME <> SUBT.ITEM_OTHER_NAME
          or (SUBB.ITEM_OTHER_NAME is null and SUBT.ITEM_OTHER_NAME is not null)
          or (SUBB.ITEM_OTHER_NAME is not null and SUBT.ITEM_OTHER_NAME is null)
  ));

  insert into GR_OTHER_NAMES_TL (
    ITEM_CODE,
    ORGN_CODE,
    SYNONYM_SEQUENCE_NUMBER,
    ITEM_OTHER_NAME,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.ITEM_CODE,
    B.ORGN_CODE,
    B.SYNONYM_SEQUENCE_NUMBER,
    B.ITEM_OTHER_NAME,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from GR_OTHER_NAMES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from GR_OTHER_NAMES_TL T
    where T.ITEM_CODE = B.ITEM_CODE
    and T.ORGN_CODE = B.ORGN_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);
end NEW_LANGUAGE;

END GR_OTHER_NAMES_TL_PKG;

/
