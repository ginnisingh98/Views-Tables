--------------------------------------------------------
--  DDL for Package Body GR_FIELD_NAME_MASKS_TL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GR_FIELD_NAME_MASKS_TL_PKG" AS
/*$Header: GRHIFMTB.pls 115.6 2003/08/05 18:05:50 gkelly noship $*/



/* =====================================================================
 PROOCEDURE:
   Insert_Row

 DESCRIPTION:
   This PL/SQL procedure is used to insert data into the table
   GR_FIELD_NAME_MASKS_TL

 PARAMETERS:
   p_commit            IN   VARCHAR2,
   p_called_by_form    IN   VARCHAR2,
   p_item_code         IN   VARCHAR2,
   p_disclosure_code   IN   VARCHAR2,
   p_label_code        IN   VARCHAR2,
   p_language          IN   VARCHAR2,
   p_field_name_mask   IN   VARCHAR2,
   p_source_lang       IN   VARCHAR2,
   p_created_by        IN   NUMBER,
   p_creation_date     IN   DATE,
   p_last_updated_by   IN   NUMBER,
   p_last_update_date  IN   DATE,
   p_last_update_login IN   NUMBER,
   x_rowid             OUT  VARCHAR2,
   x_return_status     OUT  VARCHAR2,
   x_oracle_error      OUT  NUMBER,
   x_msg_data          OUT  VARCHAR2

 HISTORY
 ===================================================================== */
PROCEDURE Insert_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_item_code IN VARCHAR2,
				  p_disclosure_code IN VARCHAR2,
				  p_label_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_field_name_mask IN VARCHAR2,
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
	   ( p_item_code,
	    p_disclosure_code,
	    p_label_code,
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
    	 ( p_item_code,
	  p_disclosure_code,
	  p_label_code,
    	  p_language,
	  'F',
	  l_rowid,
	  l_key_exists);

   IF FND_API.To_Boolean(l_key_exists) THEN
   	  RAISE Item_Exists_Error;
   END IF;

   INSERT INTO gr_item_field_name_masks_tl
  	     (item_code,
              disclosure_code,
	      label_code,
	      language,
	      field_name_mask,
  	      source_lang,
	      created_by,
	      creation_date,
	      last_updated_by,
	      last_update_date,
	      last_update_login)
          VALUES
	     (p_item_code,
	      p_disclosure_code,
	      p_label_code,
	      p_language,
	      p_field_name_mask,
	      p_source_lang,
              p_created_by,
              p_creation_date,
              p_last_updated_by,
              p_last_update_date,
              p_last_update_login);

/*   Now get the row id of the inserted record */

   Check_Primary_Key
   		 (p_item_code,
		  p_disclosure_code,
		  p_label_code,
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
         		     p_item_code,
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
         		     p_item_code,
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


/* =====================================================================
 PROOCEDURE:
   Update_Row

 DESCRIPTION:
   This PL/SQL procedure is used to update data in the table
   GR_FIELD_NAME_MASKS_TL

 PARAMETERS:
   p_commit            IN   VARCHAR2,
   p_called_by_form    IN   VARCHAR2,
   p_rowid             IN   VARCHAR2,
   pitem_code          IN   VARCHAR2,
   pdisclosure_code    IN   VARCHAR2,
   p_label_code        IN   VARCHAR2,
   p_language          IN   VARCHAR2,
   p_field_name_mask   IN   VARCHAR2,
   p_source_lang       IN   VARCHAR2,
   p_created_by        IN   NUMBER,
   p_creation_date     IN   DATE,
   p_last_updated_by   IN   NUMBER,
   p_last_update_date  IN   DATE,
   p_last_update_login IN   NUMBER,
   x_return_status     OUT  VARCHAR2,
   x_oracle_error      OUT  NUMBER,
   x_msg_data          OUT  VARCHAR2

 HISTORY
 ===================================================================== */
PROCEDURE Update_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_rowid IN VARCHAR2,
				  p_item_code IN VARCHAR2,
				  p_disclosure_code IN VARCHAR2,
				  p_label_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_field_name_mask IN VARCHAR2,
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
	   ( p_item_code,
	     p_disclosure_code,
   	     p_label_code,
	    p_language,
	    p_source_lang,
		l_return_status,
		l_oracle_error,
		l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Foreign_Key_Error;
   ELSE
       UPDATE	gr_item_field_name_masks_tl
	  SET	item_code = p_item_code,
	        disclosure_code  = p_disclosure_code,
	        label_code  = p_label_code,
	        language  = p_language,
	        field_name_mask = p_field_name_mask,
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
         		    		p_item_code,
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


/* =====================================================================
 PROOCEDURE:
   Add_Language

 DESCRIPTION:
   This PL/SQL procedure is used to add a record to the table
   GR_FIELD_NAME_MASKS_TL for every installed language

 PARAMETERS:
   p_commit            IN   VARCHAR2,
   p_called_by_form    IN   VARCHAR2,
   p_rowid             IN   VARCHAR2,
   p_item_code         IN   VARCHAR2,
   p_disclosure_code   IN   VARCHAR2,
   p_label_code        IN   VARCHAR2,
   p_language          IN   VARCHAR2,
   x_return_status     OUT  VARCHAR2,
   x_oracle_error      OUT  NUMBER,
   x_msg_data          OUT  VARCHAR2

 HISTORY
 ===================================================================== */
PROCEDURE Add_Language
             (p_commit IN VARCHAR2,
              p_called_by_form IN VARCHAR2,
              p_item_code IN VARCHAR2,
		      p_disclosure_code IN VARCHAR2,
		      p_label_code IN VARCHAR2,
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
   SELECT	eit.field_name_mask,
                eit.created_by,
		eit.creation_date,
		eit.last_updated_by,
		eit.last_update_date,
		eit.last_update_login
   FROM	        gr_item_field_name_masks_tl eit
   WHERE	eit.item_code = p_item_code
   AND  	eit.disclosure_code = p_disclosure_code
   AND  	eit.label_code = p_label_code
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
   l_msg_token := p_item_code || ' ' || p_disclosure_code || ' ' || p_label_code || ' ' || p_language;

/* Remove translations with no base row */

  delete from GR_ITEM_FIELD_NAME_MASKS_TL T
  where not exists
    (select NULL
    from GR_ITEM_FIELD_NAME_MASKS_B B
    where B.ITEM_CODE = T.ITEM_CODE
    and   B.DISCLOSURE_CODE = T.DISCLOSURE_CODE
    and   B.LABEL_CODE = T.LABEL_CODE
    );

/* Redefault translations from the source language  */

    Update gr_item_field_name_masks_tl t set (
    field_name_mask ) =
    ( select
      b.field_name_mask
      from gr_item_field_name_masks_tl b
      where b.item_code = t.item_code
      and   b.disclosure_code = t.disclosure_code
      and   b.label_code = t.label_code
      and   b.language = t.source_lang)
    where (
          t.item_code,
          t.disclosure_code,
          t.label_code,
          t.language
    ) in (select
          subt.item_code,
          subt.disclosure_code,
          subt.label_code,
          subt.language
          from gr_item_field_name_masks_tl subb, gr_item_field_name_masks_tl subt
          where  subb.item_code = subt.item_code
          and    subb.disclosure_code = subt.disclosure_code
          and    subb.label_code = subt.label_code
          and    subb.language = subt.source_lang
          and (subb.field_name_mask <> subt.field_name_mask
           or (subb.field_name_mask is null and subt.field_name_mask is not null)
           or (subb.field_name_mask is not null and subt.field_name_mask is null)));
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
          l_base_desc := TypeDesc.field_name_mask;
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
			   INSERT INTO gr_item_field_name_masks_tl
						(item_code,
						 disclosure_code,
						 label_code,
						 language,
						 field_name_mask,
						 source_lang,
						 created_by,
						 creation_date,
						 last_updated_by,
						 last_update_date,
						 last_update_login)
				   VALUES
				        (p_item_code,
						 p_disclosure_code,
						 p_label_code,
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


/* =====================================================================
 PROOCEDURE:
   Lock_Row

 DESCRIPTION:
   This PL/SQL procedure is used to lock a row in the table
   GR_FIELD_NAME_MASKS_TL

 PARAMETERS:
   p_commit            IN   VARCHAR2,
   p_called_by_form    IN   VARCHAR2,
   p_rowid             IN   VARCHAR2,
   p_item_code         IN   VARCHAR2,
   p_disclosure_code   IN   VARCHAR2,
   p_label_code        IN   VARCHAR2,
   p_language          IN   VARCHAR2,
   p_field_name_mask   IN   VARCHAR2,
   p_source_lang       IN   VARCHAR2,
   p_created_by        IN   NUMBER,
   p_creation_date     IN   DATE,
   p_last_updated_by   IN   NUMBER,
   p_last_update_date  IN   DATE,
   p_last_update_login IN   NUMBER,
   x_return_status     OUT  VARCHAR2,
   x_oracle_error      OUT  NUMBER,
   x_msg_data          OUT  VARCHAR2

 HISTORY
 ===================================================================== */
PROCEDURE Lock_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_rowid IN VARCHAR2,
				  p_item_code IN VARCHAR2,
				  p_disclosure_code IN VARCHAR2,
				  p_label_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_field_name_mask IN VARCHAR2,
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
   FROM		gr_item_field_name_masks_tl
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
	                        p_item_code,
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


/* =====================================================================
 PROOCEDURE:
   Delete_Row

 DESCRIPTION:
   This PL/SQL procedure is used to delete a row in the table
   GR_FIELD_NAME_MASKS_TL

 PARAMETERS:
   p_commit            IN   VARCHAR2,
   p_called_by_form    IN   VARCHAR2,
   p_rowid             IN   VARCHAR2,
   p_item_code         IN   VARCHAR2,
   p_disclosure_code   IN   VARCHAR2,
   p_label_code        IN   VARCHAR2,
   x_return_status     OUT  VARCHAR2,
   x_oracle_error      OUT  NUMBER,
   x_msg_data          OUT  VARCHAR2

 HISTORY
 ===================================================================== */
PROCEDURE Delete_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_rowid IN VARCHAR2,
				  p_item_code IN VARCHAR2,
				  p_disclosure_code IN VARCHAR2,
				  p_label_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2)
 IS
/*   Alpha Variables */

L_RETURN_STATUS	  VARCHAR2(1) := 'S';
L_MSG_DATA		  VARCHAR2(2000);
L_MSG_TOKEN		  VARCHAR2(100);
L_CALLED_BY_FORM          VARCHAR2(1);

/*   Number Variables */

L_ORACLE_ERROR	  NUMBER;

/*   Exceptions */

CHECK_INTEGRITY_ERROR     EXCEPTION;
ROW_MISSING_ERROR	  EXCEPTION;
PRAGMA EXCEPTION_INIT(Row_Missing_Error,100);

BEGIN

/*   Initialization Routine */

   SAVEPOINT Delete_Row;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;
   l_msg_token := p_item_code || ' ' || p_disclosure_code || ' ' || p_label_code || ' '|| p_language;

   DELETE FROM gr_item_field_name_masks_tl
   WHERE  	   rowid = p_rowid;

/*   Check the commit flag and if set, then commit the work. */

   IF FND_API.TO_Boolean(p_commit) THEN
      COMMIT WORK;
   END IF;

EXCEPTION

   WHEN Row_Missing_Error THEN
      ROLLBACK TO SAVEPOINT Delete_Row;
	  x_return_status := 'E';
	  x_oracle_error := APP_EXCEPTION.Get_Code;
      FND_MESSAGE.SET_NAME('GR',
                           'GR_RECORD_NOT_FOUND');
      FND_MESSAGE.SET_TOKEN('CODE',
         		            p_item_code,
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

/* =====================================================================
 PROOCEDURE:
   Delete_Rows

 DESCRIPTION:
   This PL/SQL procedure is used to delete all of the rows in the table
   GR_FIELD_NAME_MASKS_TL for the given item_code

 PARAMETERS:
   p_commit            IN   VARCHAR2,
   p_called_by_form    IN   VARCHAR2,
   p_item_code         IN   VARCHAR2,
   p_disclosure_code   IN   VARCHAR2,
   p_label_code        IN   VARCHAR2,
   x_return_status     OUT  VARCHAR2,
   x_oracle_error      OUT  NUMBER,
   x_msg_data          OUT  VARCHAR2

 HISTORY
 ===================================================================== */
PROCEDURE Delete_Rows
	             (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_item_code IN VARCHAR2,
				  p_disclosure_code IN VARCHAR2,
				  p_label_code IN VARCHAR2,
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
   l_msg_token := p_item_code;

   DELETE FROM gr_item_field_name_masks_tl
   WHERE       item_code = p_item_code;

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


/* =====================================================================
 PROOCEDURE:
   Check_Foreign_Keys

 DESCRIPTION:
   This PL/SQL procedure is used to check foreign key references from
   GR_FIELD_NAME_MASKS_TL

 PARAMETERS:
   p_item_code         IN   VARCHAR2,
   p_disclosure_code   IN   VARCHAR2,
   p_label_code        IN   VARCHAR2,
   p_language          IN   VARCHAR2,
   p_source_lang       IN   VARCHAR2,
   x_return_status     OUT  VARCHAR2,
   x_oracle_error      OUT  NUMBER,
   x_msg_data          OUT  VARCHAR2

 HISTORY
 ===================================================================== */
PROCEDURE Check_Foreign_Keys
	   			 (p_item_code IN VARCHAR2,
				  p_disclosure_code IN VARCHAR2,
				  p_label_code IN VARCHAR2,
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

   l_msg_token := p_item_code || ' ' || p_disclosure_code || ' ' || p_label_code || ' ' || p_language;

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


/* =====================================================================
 PROOCEDURE:
   Check_Primary_Key

 DESCRIPTION:
   This PL/SQL procedure is used to check if the record already exists in
   GR_FIELD_NAME_MASKS_TL

 PARAMETERS:
   p_item_code         IN   VARCHAR2   item code to check.
   p_disclosure_code   IN   VARCHAR2   disclosure code to check
   p_label_code        IN   VARCHAR2   label code to check
   p_language          IN   VARCHAR2   language to check
   p_called_by_form    IN   VARCHAR2   'T' if called by a form or 'F' if not
   x_row_id            OUT  VARCHAR2   row id of the record if found
   x_key_exists        OUT  VARCHAR2   'T' is the record is found, 'F' if not

 HISTORY
 ===================================================================== */
PROCEDURE Check_Primary_Key
			 (p_item_code IN VARCHAR2,
			  p_disclosure_code IN VARCHAR2,
			  p_label_code IN VARCHAR2,
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
   FROM	  gr_item_field_name_masks_tl ein
   WHERE  ein.item_code = p_item_code
   AND    ein.disclosure_code = p_disclosure_code
   AND    ein.label_code = p_label_code
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


/* =====================================================================
 PROOCEDURE:
   translate_row

 DESCRIPTION:
   This PL/SQL procedure is used to translate a row in
   GR_FIELD_NAME_MASKS_TL

 PARAMETERS:
   p_item_code         IN   VARCHAR2,
   p_disclosure_code   IN   VARCHAR2,
   p_label_code        IN   VARCHAR2,
   p_language          IN   VARCHAR2,
   p_field_name_mask   IN   VARCHAR2,
   p_source_lang       IN   VARCHAR2,

 HISTORY
 ===================================================================== */
PROCEDURE translate_row (
	X_ITEM_CODE IN VARCHAR2
	,X_DISCLOSURE_CODE IN VARCHAR2
	,X_LABEL_CODE IN VARCHAR2
	,X_LANGUAGE IN VARCHAR2
	,X_FIELD_NAME_MASK IN VARCHAR2
	,X_SOURCE_LANG IN VARCHAR2
) IS
BEGIN
	UPDATE GR_ITEM_FIELD_NAME_MASKS_TL SET
		FIELD_NAME_MASK = X_FIELD_NAME_MASK,
		SOURCE_LANG = USERENV('LANG'),
		LAST_UPDATE_DATE = sysdate,
		LAST_UPDATED_BY = 0,
		LAST_UPDATE_LOGIN = 0
	WHERE (ITEM_CODE = X_ITEM_CODE)
	AND   (DISCLOSURE_CODE = X_DISCLOSURE_CODE)
	AND   (LABEL_CODE = X_LABEL_CODE)
	AND   (USERENV('LANG') IN (LANGUAGE, SOURCE_LANG));
END TRANSLATE_ROW;


/* =====================================================================
 PROOCEDURE:
   load_row

 DESCRIPTION:
   This PL/SQL procedure is used to update or insert a row into
   GR_FIELD_NAME_MASKS_TL

 PARAMETERS:
   p_item_code         IN   VARCHAR2,
   p_disclosure_code   IN   VARCHAR2,
   p_label_code        IN   VARCHAR2,
   p_language          IN   VARCHAR2,
   p_field_name_mask   IN   VARCHAR2,
   p_source_lang       IN   VARCHAR2,

 HISTORY
 ===================================================================== */
PROCEDURE load_row (
	X_ITEM_CODE IN VARCHAR2
	,X_DISCLOSURE_CODE IN VARCHAR2
	,X_LABEL_CODE IN VARCHAR2
	,X_LANGUAGE IN VARCHAR2
	,X_FIELD_NAME_MASK IN VARCHAR2
	,X_SOURCE_LANG IN VARCHAR2
) IS
	CURSOR Cur_rowid IS
		SELECT rowid
		FROM GR_ITEM_FIELD_NAME_MASKS_TL
		WHERE (ITEM_CODE = X_ITEM_CODE)
		AND   (DISCLOSURE_CODE = X_DISCLOSURE_CODE)
		AND   (LABEL_CODE = X_LABEL_CODE)
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
		GR_FIELD_NAME_MASKS_TL_PKG.UPDATE_ROW(
			P_COMMIT => 'T'
			,P_CALLED_BY_FORM => 'F'
			,P_ROWID => l_row_id
			,P_ITEM_CODE => X_ITEM_CODE
			,P_DISCLOSURE_CODE => X_DISCLOSURE_CODE
			,P_LABEL_CODE => X_LABEL_CODE
			,P_LANGUAGE => X_LANGUAGE
			,P_FIELD_NAME_MASK => X_FIELD_NAME_MASK
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
		GR_FIELD_NAME_MASKS_TL_PKG.INSERT_ROW(
			P_COMMIT => 'T'
			,P_CALLED_BY_FORM => 'F'
			,P_ITEM_CODE => X_ITEM_CODE
			,P_DISCLOSURE_CODE => X_DISCLOSURE_CODE
			,P_LABEL_CODE => X_LABEL_CODE
			,P_LANGUAGE => X_LANGUAGE
			,P_FIELD_NAME_MASK => X_FIELD_NAME_MASK
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

/* =====================================================================
 PROOCEDURE:
   New_Language

 DESCRIPTION:
   This PL/SQL procedure is used to add a new language
   GR_FIELD_NAME_MASKS_TL


 HISTORY
 04-Aug-2003 GK Bug 2961127 - Added in procedure new language for populating the tables.
 ===================================================================== */
PROCEDURE NEW_LANGUAGE
is
begin
  DELETE FROM GR_ITEM_FIELD_NAME_MASKS_TL T
  WHERE not exists
    (SELECT NULL
    FROM GR_ITEM_FIELD_NAME_MASKS_B B
    WHERE B.ITEM_CODE = T.ITEM_CODE
    AND B.DISCLOSURE_CODE = T.DISCLOSURE_CODE
    AND B.LABEL_CODE = T.LABEL_CODE
    );

  UPDATE GR_ITEM_FIELD_NAME_MASKS_TL T SET (
      FIELD_NAME_MASK
    ) = (SELECT
      B.FIELD_NAME_MASK
    FROM GR_ITEM_FIELD_NAME_MASKS_TL B
    WHERE B.ITEM_CODE = T.ITEM_CODE
    AND B.LANGUAGE = T.SOURCE_LANG
    AND B.DISCLOSURE_CODE = T.DISCLOSURE_CODE
    AND B.LABEL_CODE = T.LABEL_CODE)
  WHERE (
      T.ITEM_CODE,
      T.LANGUAGE,
      T.DISCLOSURE_CODE,
      T.LABEL_CODE
  ) in (SELECT
      SUBT.ITEM_CODE,
      SUBT.LANGUAGE,
      SUBT.DISCLOSURE_CODE,
      SUBT.LABEL_CODE
    FROM GR_ITEM_FIELD_NAME_MASKS_TL SUBB, GR_ITEM_FIELD_NAME_MASKS_TL SUBT
    WHERE SUBB.ITEM_CODE = SUBT.ITEM_CODE
    AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
    AND SUBB.DISCLOSURE_CODE = SUBT.DISCLOSURE_CODE
    AND SUBB.LABEL_CODE = SUBT.LABEL_CODE
    AND (SUBB.FIELD_NAME_MASK <> SUBT.FIELD_NAME_MASK
  ));

  INSERT into GR_ITEM_FIELD_NAME_MASKS_TL (
    ITEM_CODE,
    DISCLOSURE_CODE,
    LABEL_CODE,
    FIELD_NAME_MASK,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) SELECT
    B.ITEM_CODE,
    B.DISCLOSURE_CODE,
    B.LABEL_CODE,
    B.FIELD_NAME_MASK,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  FROM GR_ITEM_FIELD_NAME_MASKS_TL B, FND_LANGUAGES L
  WHERE L.INSTALLED_FLAG in ('I', 'B')
  AND B.LANGUAGE = userenv('LANG')
  AND not exists
    (SELECT NULL
    FROM GR_ITEM_FIELD_NAME_MASKS_TL T
    WHERE T.ITEM_CODE = B.ITEM_CODE
    AND T.DISCLOSURE_CODE = B.DISCLOSURE_CODE
    AND T.LABEL_CODE = B.LABEL_CODE
    AND T.LANGUAGE = L.LANGUAGE_CODE);

END NEW_LANGUAGE;


END GR_FIELD_NAME_MASKS_TL_PKG;

/
