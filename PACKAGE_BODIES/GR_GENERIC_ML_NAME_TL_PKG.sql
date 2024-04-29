--------------------------------------------------------
--  DDL for Package Body GR_GENERIC_ML_NAME_TL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GR_GENERIC_ML_NAME_TL_PKG" AS
/*$Header: GRHIGITB.pls 120.0 2005/05/26 14:24:42 appldev noship $*/
PROCEDURE Insert_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_item_code IN VARCHAR2,
				  p_item_no IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_label_code IN VARCHAR2,
				  p_source_lang IN VARCHAR2,
				  p_name_description IN VARCHAR2,
				  p_attribute_category IN VARCHAR2,
				  p_attribute1 IN VARCHAR2,
				  p_attribute2 IN VARCHAR2,
				  p_attribute3 IN VARCHAR2,
				  p_attribute4 IN VARCHAR2,
				  p_attribute5 IN VARCHAR2,
				  p_attribute6 IN VARCHAR2,
				  p_attribute7 IN VARCHAR2,
				  p_attribute8 IN VARCHAR2,
				  p_attribute9 IN VARCHAR2,
				  p_attribute10 IN VARCHAR2,
				  p_attribute11 IN VARCHAR2,
				  p_attribute12 IN VARCHAR2,
				  p_attribute13 IN VARCHAR2,
				  p_attribute14 IN VARCHAR2,
				  p_attribute15 IN VARCHAR2,
				  p_attribute16 IN VARCHAR2,
				  p_attribute17 IN VARCHAR2,
				  p_attribute18 IN VARCHAR2,
				  p_attribute19 IN VARCHAR2,
				  p_attribute20 IN VARCHAR2,
				  p_attribute21 IN VARCHAR2,
				  p_attribute22 IN VARCHAR2,
				  p_attribute23 IN VARCHAR2,
				  p_attribute24 IN VARCHAR2,
				  p_attribute25 IN VARCHAR2,
				  p_attribute26 IN VARCHAR2,
				  p_attribute27 IN VARCHAR2,
				  p_attribute28 IN VARCHAR2,
				  p_attribute29 IN VARCHAR2,
				  p_attribute30 IN VARCHAR2,
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
				  p_item_no,
				  p_language,
				  p_label_code,
				  p_source_lang,
				  p_name_description,
				  p_attribute_category,
				  p_attribute1,
				  p_attribute2,
				  p_attribute3,
				  p_attribute4,
				  p_attribute5,
				  p_attribute6,
				  p_attribute7,
				  p_attribute8,
				  p_attribute9,
				  p_attribute10,
				  p_attribute11,
				  p_attribute12,
				  p_attribute13,
				  p_attribute14,
				  p_attribute15,
				  p_attribute16,
				  p_attribute17,
				  p_attribute18,
				  p_attribute19,
				  p_attribute20,
				  p_attribute21,
				  p_attribute22,
				  p_attribute23,
				  p_attribute24,
				  p_attribute25,
				  p_attribute26,
				  p_attribute27,
				  p_attribute28,
				  p_attribute29,
				  p_attribute30,
				  l_return_status,
				  l_oracle_error,
				  l_msg_data);
   IF l_return_status <> 'S' THEN
      RAISE Foreign_Key_Error;
   END IF;

/* 	   Now check the primary key doesn't already exist */

   Check_Primary_Key
   	   	   		 (p_item_code,
				  p_item_no,
				  p_language,
				  'F',
				  l_rowid,
				  l_key_exists);

   IF FND_API.To_Boolean(l_key_exists) THEN
   	  RAISE Item_Exists_Error;
   END IF;

   INSERT INTO gr_generic_ml_name_tl
   		  	     (item_code,
				  item_no,
				  language,
				  label_code,
				  source_lang,
				  name_description,
				  attribute_category,
				  attribute1,
				  attribute2,
				  attribute3,
				  attribute4,
				  attribute5,
				  attribute6,
				  attribute7,
				  attribute8,
				  attribute9,
				  attribute10,
				  attribute11,
				  attribute12,
				  attribute13,
				  attribute14,
				  attribute15,
				  attribute16,
				  attribute17,
				  attribute18,
				  attribute19,
				  attribute20,
				  attribute21,
				  attribute22,
				  attribute23,
				  attribute24,
				  attribute25,
				  attribute26,
				  attribute27,
				  attribute28,
				  attribute29,
				  attribute30,
				  created_by,
				  creation_date,
				  last_updated_by,
				  last_update_date,
				  last_update_login)
          VALUES
		         (p_item_code,
				  p_item_no,
				  p_language,
				  p_label_code,
				  p_source_lang,
				  p_name_description,
				  p_attribute_category,
				  p_attribute1,
				  p_attribute2,
				  p_attribute3,
				  p_attribute4,
				  p_attribute5,
				  p_attribute6,
				  p_attribute7,
				  p_attribute8,
				  p_attribute9,
				  p_attribute10,
				  p_attribute11,
				  p_attribute12,
				  p_attribute13,
				  p_attribute14,
				  p_attribute15,
				  p_attribute16,
				  p_attribute17,
				  p_attribute18,
				  p_attribute19,
				  p_attribute20,
				  p_attribute21,
				  p_attribute22,
				  p_attribute23,
				  p_attribute24,
				  p_attribute25,
				  p_attribute26,
				  p_attribute27,
				  p_attribute28,
				  p_attribute29,
				  p_attribute30,
				  p_created_by,
				  p_creation_date,
				  p_last_updated_by,
				  p_last_update_date,
				  p_last_update_login);

/*   Now get the row id of the inserted record */

   Check_Primary_Key
   	   	   		 (p_item_code,
				  p_item_no,
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
	  l_msg_token := p_item_code || ' ' || p_item_no || ' ' || p_language;
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
	  l_msg_token := p_item_code || ' ' || p_item_no || ' ' || p_language;
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
	  l_msg_token := p_item_code || ' ' || p_item_no || ' ' || p_language;
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
				  p_item_no IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_label_code IN VARCHAR2,
				  p_source_lang IN VARCHAR2,
				  p_name_description IN VARCHAR2,
				  p_attribute_category IN VARCHAR2,
				  p_attribute1 IN VARCHAR2,
				  p_attribute2 IN VARCHAR2,
				  p_attribute3 IN VARCHAR2,
				  p_attribute4 IN VARCHAR2,
				  p_attribute5 IN VARCHAR2,
				  p_attribute6 IN VARCHAR2,
				  p_attribute7 IN VARCHAR2,
				  p_attribute8 IN VARCHAR2,
				  p_attribute9 IN VARCHAR2,
				  p_attribute10 IN VARCHAR2,
				  p_attribute11 IN VARCHAR2,
				  p_attribute12 IN VARCHAR2,
				  p_attribute13 IN VARCHAR2,
				  p_attribute14 IN VARCHAR2,
				  p_attribute15 IN VARCHAR2,
				  p_attribute16 IN VARCHAR2,
				  p_attribute17 IN VARCHAR2,
				  p_attribute18 IN VARCHAR2,
				  p_attribute19 IN VARCHAR2,
				  p_attribute20 IN VARCHAR2,
				  p_attribute21 IN VARCHAR2,
				  p_attribute22 IN VARCHAR2,
				  p_attribute23 IN VARCHAR2,
				  p_attribute24 IN VARCHAR2,
				  p_attribute25 IN VARCHAR2,
				  p_attribute26 IN VARCHAR2,
				  p_attribute27 IN VARCHAR2,
				  p_attribute28 IN VARCHAR2,
				  p_attribute29 IN VARCHAR2,
				  p_attribute30 IN VARCHAR2,
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
   l_msg_token := p_item_code || ' ' || p_item_no || ' ' || p_language;

/*	  Now call the check foreign key procedure */

   Check_Foreign_Keys
			     (p_item_code,
				  p_item_no,
				  p_language,
				  p_label_code,
				  p_source_lang,
				  p_name_description,
				  p_attribute_category,
				  p_attribute1,
				  p_attribute2,
				  p_attribute3,
				  p_attribute4,
				  p_attribute5,
				  p_attribute6,
				  p_attribute7,
				  p_attribute8,
				  p_attribute9,
				  p_attribute10,
				  p_attribute11,
				  p_attribute12,
				  p_attribute13,
				  p_attribute14,
				  p_attribute15,
				  p_attribute16,
				  p_attribute17,
				  p_attribute18,
				  p_attribute19,
				  p_attribute20,
				  p_attribute21,
				  p_attribute22,
				  p_attribute23,
				  p_attribute24,
				  p_attribute25,
				  p_attribute26,
				  p_attribute27,
				  p_attribute28,
				  p_attribute29,
				  p_attribute30,
				  l_return_status,
				  l_oracle_error,
				  l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Foreign_Key_Error;
   ELSE
      UPDATE gr_generic_ml_name_tl
	  SET	 item_code						 = p_item_code,
			 item_no	  					 = p_item_no,
			 language	  					 = p_language,
			 label_code	  					 = p_label_code,
			 source_lang	  				 = p_source_lang,
			 name_description	  			 = p_name_description,
			 attribute_category				 = p_attribute_category,
			 attribute1						 = p_attribute1,
			 attribute2						 = p_attribute2,
			 attribute3						 = p_attribute3,
			 attribute4						 = p_attribute4,
			 attribute5						 = p_attribute5,
			 attribute6						 = p_attribute6,
			 attribute7						 = p_attribute7,
			 attribute8						 = p_attribute8,
			 attribute9						 = p_attribute9,
			 attribute10					 = p_attribute10,
			 attribute11					 = p_attribute11,
			 attribute12					 = p_attribute12,
			 attribute13					 = p_attribute13,
			 attribute14					 = p_attribute14,
			 attribute15					 = p_attribute15,
			 attribute16					 = p_attribute16,
			 attribute17					 = p_attribute17,
			 attribute18					 = p_attribute18,
			 attribute19					 = p_attribute19,
			 attribute20					 = p_attribute20,
			 attribute21					 = p_attribute11,
			 attribute22					 = p_attribute22,
			 attribute23					 = p_attribute23,
			 attribute24					 = p_attribute24,
			 attribute25					 = p_attribute25,
			 attribute26					 = p_attribute26,
			 attribute27					 = p_attribute27,
			 attribute28					 = p_attribute28,
			 attribute29					 = p_attribute29,
			 attribute30					 = p_attribute30,
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
				  p_item_no IN VARCHAR2,
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
L_LABEL_CODE			VARCHAR2(5);
L_LANGUAGE		  		VARCHAR2(4);
L_CREATION_DATE	 		DATE;
L_LAST_UPDATE_DATE		DATE;
L_ATTRIBUTE_CATEGORY	VARCHAR2(30);
L_ATTRIBUTE1			VARCHAR2(240);
L_ATTRIBUTE2			VARCHAR2(240);
L_ATTRIBUTE3			VARCHAR2(240);
L_ATTRIBUTE4			VARCHAR2(240);
L_ATTRIBUTE5			VARCHAR2(240);
L_ATTRIBUTE6			VARCHAR2(240);
L_ATTRIBUTE7			VARCHAR2(240);
L_ATTRIBUTE8			VARCHAR2(240);
L_ATTRIBUTE9			VARCHAR2(240);
L_ATTRIBUTE10			VARCHAR2(240);
L_ATTRIBUTE11			VARCHAR2(240);
L_ATTRIBUTE12			VARCHAR2(240);
L_ATTRIBUTE13			VARCHAR2(240);
L_ATTRIBUTE14			VARCHAR2(240);
L_ATTRIBUTE15			VARCHAR2(240);
L_ATTRIBUTE16			VARCHAR2(240);
L_ATTRIBUTE17			VARCHAR2(240);
L_ATTRIBUTE18			VARCHAR2(240);
L_ATTRIBUTE19			VARCHAR2(240);
L_ATTRIBUTE20			VARCHAR2(240);
L_ATTRIBUTE21			VARCHAR2(240);
L_ATTRIBUTE22			VARCHAR2(240);
L_ATTRIBUTE23			VARCHAR2(240);
L_ATTRIBUTE24			VARCHAR2(240);
L_ATTRIBUTE25			VARCHAR2(240);
L_ATTRIBUTE26			VARCHAR2(240);
L_ATTRIBUTE27			VARCHAR2(240);
L_ATTRIBUTE28			VARCHAR2(240);
L_ATTRIBUTE29			VARCHAR2(240);
L_ATTRIBUTE30			VARCHAR2(240);

/*   Number Variables */

L_ORACLE_ERROR	  	NUMBER;
L_CREATED_BY		NUMBER;
L_LAST_UPDATED_BY	NUMBER;
L_LAST_UPDATE_LOGIN	NUMBER;
L_PRINT_SIZE		NUMBER;

/*	Exceptions */

LANGUAGE_MISSING_ERROR	EXCEPTION;


/*   Cursors */

CURSOR c_get_descs
 IS
   SELECT		gin.name_description,
			gin.label_code,
			gin.attribute_category,
			gin.attribute1,
			gin.attribute2,
			gin.attribute3,
			gin.attribute4,
			gin.attribute5,
			gin.attribute6,
			gin.attribute7,
			gin.attribute8,
			gin.attribute9,
			gin.attribute10,
			gin.attribute11,
			gin.attribute12,
			gin.attribute13,
			gin.attribute14,
			gin.attribute15,
			gin.attribute16,
			gin.attribute17,
			gin.attribute18,
			gin.attribute19,
			gin.attribute20,
			gin.attribute21,
			gin.attribute22,
			gin.attribute23,
			gin.attribute24,
			gin.attribute25,
			gin.attribute26,
			gin.attribute27,
			gin.attribute28,
			gin.attribute29,
			gin.attribute30,
          		gin.created_by,
			gin.creation_date,
			gin.last_updated_by,
			gin.last_update_date,
			gin.last_update_login
   FROM	    gr_generic_ml_name_tl gin
   WHERE	gin.item_code = p_item_code
   AND	 	gin.item_no = p_item_no
   AND		gin.language = l_language;
GenericDesc				c_get_descs%ROWTYPE;

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
   l_msg_token := p_item_code || ' ' || p_item_no || ' ' || p_language;

/* Remove translations with no base row */

  delete from GR_GENERIC_ML_NAME_TL T
  where not exists
    (select NULL
    from GR_GENERIC_ITEMS_B B
    where B.ITEM_CODE = T.ITEM_CODE
    and   B.ITEM_NO = T.ITEM_NO
    );

/* Redefault translations from the source language  */

   update gr_generic_ml_name_tl t set (
    name_description ) =
    ( select
      B.NAME_DESCRIPTION
      from GR_GENERIC_ML_NAME_TL B
      where B.ITEM_CODE = T.ITEM_CODE
      and B.ITEM_NO = T.ITEM_NO
      and B.LANGUAGE = T.SOURCE_LANG)
   where (
      T.ITEM_CODE,
      T.ITEM_NO,
      T.LANGUAGE
   ) in (select
         SUBT.ITEM_CODE,
         SUBT.ITEM_NO,
         SUBT.LANGUAGE
         from GR_GENERIC_ML_NAME_TL SUBB, GR_GENERIC_ML_NAME_TL SUBT
         where SUBB.ITEM_CODE = SUBT.ITEM_CODE
         and SUBB.ITEM_NO = SUBB.ITEM_NO
         and SUBB.LANGUAGE = SUBT.SOURCE_LANG
         and (SUBB.NAME_DESCRIPTION <> SUBT.NAME_DESCRIPTION
          or (SUBB.NAME_DESCRIPTION is null and SUBT.NAME_DESCRIPTION is not null)
          or (SUBB.NAME_DESCRIPTION is not null and SUBT.NAME_DESCRIPTION is null)
  ));

/*	Open the language cursor and get the description entered from the
**	user environment variable.
*/
   l_language := p_language;
   OPEN c_get_descs;
   FETCH c_get_descs INTO GenericDesc;
   IF c_get_descs%NOTFOUND THEN
      CLOSE c_get_descs;
      RAISE Language_Missing_Error;
   ELSE
      l_base_desc := GenericDesc.name_description;
	  l_label_code := GenericDesc.label_code;
	  l_attribute_category := GenericDesc.attribute_category;
	  l_attribute1 := GenericDesc.attribute1;
	  l_attribute2 := GenericDesc.attribute2;
	  l_attribute3 := GenericDesc.attribute3;
	  l_attribute4 := GenericDesc.attribute4;
	  l_attribute5 := GenericDesc.attribute5;
	  l_attribute6 := GenericDesc.attribute6;
	  l_attribute7 := GenericDesc.attribute7;
	  l_attribute8 := GenericDesc.attribute8;
	  l_attribute9 := GenericDesc.attribute9;
	  l_attribute10 := GenericDesc.attribute10;
	  l_attribute11 := GenericDesc.attribute11;
	  l_attribute12 := GenericDesc.attribute12;
	  l_attribute13 := GenericDesc.attribute13;
	  l_attribute14 := GenericDesc.attribute14;
	  l_attribute15 := GenericDesc.attribute15;
	  l_attribute16 := GenericDesc.attribute16;
	  l_attribute17 := GenericDesc.attribute17;
	  l_attribute18 := GenericDesc.attribute18;
	  l_attribute19 := GenericDesc.attribute19;
	  l_attribute20 := GenericDesc.attribute20;
	  l_attribute21 := GenericDesc.attribute21;
	  l_attribute22 := GenericDesc.attribute22;
	  l_attribute23 := GenericDesc.attribute23;
	  l_attribute24 := GenericDesc.attribute24;
	  l_attribute25 := GenericDesc.attribute25;
	  l_attribute26 := GenericDesc.attribute26;
	  l_attribute27 := GenericDesc.attribute27;
	  l_attribute28 := GenericDesc.attribute28;
	  l_attribute29 := GenericDesc.attribute29;
	  l_attribute30 := GenericDesc.attribute30;
	  l_created_by := GenericDesc.created_by;
	  l_creation_date := GenericDesc.creation_date;
	  l_last_updated_by := GenericDesc.last_updated_by;
	  l_last_update_date := GenericDesc.last_update_date;
	  l_last_update_login := GenericDesc.last_update_login;
      CLOSE c_get_descs;
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
			OPEN c_get_descs;
			FETCH c_get_descs INTO GenericDesc;
			IF c_get_descs%NOTFOUND THEN
			   CLOSE c_get_descs;
			   INSERT INTO gr_generic_ml_name_tl
						(item_code,
						 item_no,
						 language,
						 label_code,
						 source_lang,
						 name_description,
						 attribute_category,
						 attribute1,
						 attribute2,
						 attribute3,
						 attribute4,
						 attribute5,
						 attribute6,
						 attribute7,
						 attribute8,
						 attribute9,
						 attribute10,
						 attribute11,
						 attribute12,
						 attribute13,
						 attribute14,
						 attribute15,
						 attribute16,
						 attribute17,
						 attribute18,
						 attribute19,
						 attribute20,
						 attribute21,
						 attribute22,
						 attribute23,
						 attribute24,
						 attribute25,
						 attribute26,
						 attribute27,
						 attribute28,
						 attribute29,
						 attribute30,
						 created_by,
						 creation_date,
						 last_updated_by,
						 last_update_date,
						 last_update_login)
				   VALUES
				        (p_item_code,
						 p_item_no,
						 l_language,
						 l_label_code,
						 p_language,
						 l_base_desc,
						 l_attribute_category,
						 l_attribute1,
						 l_attribute2,
						 l_attribute3,
						 l_attribute4,
						 l_attribute5,
						 l_attribute6,
						 l_attribute7,
						 l_attribute8,
						 l_attribute9,
						 l_attribute10,
						 l_attribute11,
						 l_attribute12,
						 l_attribute13,
						 l_attribute14,
						 l_attribute15,
						 l_attribute16,
						 l_attribute17,
						 l_attribute18,
						 l_attribute19,
						 l_attribute20,
						 l_attribute21,
						 l_attribute22,
						 l_attribute23,
						 l_attribute24,
						 l_attribute25,
						 l_attribute26,
						 l_attribute27,
						 l_attribute28,
						 l_attribute29,
						 l_attribute30,
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
				  p_item_no IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_label_code IN VARCHAR2,
				  p_source_lang IN VARCHAR2,
				  p_name_description IN VARCHAR2,
				  p_attribute_category IN VARCHAR2,
				  p_attribute1 IN VARCHAR2,
				  p_attribute2 IN VARCHAR2,
				  p_attribute3 IN VARCHAR2,
				  p_attribute4 IN VARCHAR2,
				  p_attribute5 IN VARCHAR2,
				  p_attribute6 IN VARCHAR2,
				  p_attribute7 IN VARCHAR2,
				  p_attribute8 IN VARCHAR2,
				  p_attribute9 IN VARCHAR2,
				  p_attribute10 IN VARCHAR2,
				  p_attribute11 IN VARCHAR2,
				  p_attribute12 IN VARCHAR2,
				  p_attribute13 IN VARCHAR2,
				  p_attribute14 IN VARCHAR2,
				  p_attribute15 IN VARCHAR2,
				  p_attribute16 IN VARCHAR2,
				  p_attribute17 IN VARCHAR2,
				  p_attribute18 IN VARCHAR2,
				  p_attribute19 IN VARCHAR2,
				  p_attribute20 IN VARCHAR2,
				  p_attribute21 IN VARCHAR2,
				  p_attribute22 IN VARCHAR2,
				  p_attribute23 IN VARCHAR2,
				  p_attribute24 IN VARCHAR2,
				  p_attribute25 IN VARCHAR2,
				  p_attribute26 IN VARCHAR2,
				  p_attribute27 IN VARCHAR2,
				  p_attribute28 IN VARCHAR2,
				  p_attribute29 IN VARCHAR2,
				  p_attribute30 IN VARCHAR2,
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
RECORD_CHANGED_ERROR	 	EXCEPTION;

/*   Define the cursors */

CURSOR c_lock_generics_tl
 IS
   SELECT	last_update_date
   FROM		gr_generic_ml_name_tl
   WHERE	rowid = p_rowid
   FOR UPDATE NOWAIT;
LockGenericRcd	  c_lock_generics_tl%ROWTYPE;

BEGIN

/*      Initialization Routine */

   SAVEPOINT Lock_Row;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;
   l_msg_token := p_item_code || ' ' || p_item_no || ' ' || p_language;

/*	   Now lock the record */

   OPEN c_lock_generics_tl;
   FETCH c_lock_generics_tl INTO LockGenericRcd;
   IF c_lock_generics_tl%NOTFOUND THEN
	  CLOSE c_lock_generics_tl;
	  RAISE No_Data_Found_Error;
   END IF;
   CLOSE c_lock_generics_tl;

   IF LockGenericRcd.last_update_date <> p_last_update_date THEN
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
				  p_item_no IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_label_code IN VARCHAR2,
				  p_source_lang IN VARCHAR2,
				  p_name_description IN VARCHAR2,
				  p_attribute_category IN VARCHAR2,
				  p_attribute1 IN VARCHAR2,
				  p_attribute2 IN VARCHAR2,
				  p_attribute3 IN VARCHAR2,
				  p_attribute4 IN VARCHAR2,
				  p_attribute5 IN VARCHAR2,
				  p_attribute6 IN VARCHAR2,
				  p_attribute7 IN VARCHAR2,
				  p_attribute8 IN VARCHAR2,
				  p_attribute9 IN VARCHAR2,
				  p_attribute10 IN VARCHAR2,
				  p_attribute11 IN VARCHAR2,
				  p_attribute12 IN VARCHAR2,
				  p_attribute13 IN VARCHAR2,
				  p_attribute14 IN VARCHAR2,
				  p_attribute15 IN VARCHAR2,
				  p_attribute16 IN VARCHAR2,
				  p_attribute17 IN VARCHAR2,
				  p_attribute18 IN VARCHAR2,
				  p_attribute19 IN VARCHAR2,
				  p_attribute20 IN VARCHAR2,
				  p_attribute21 IN VARCHAR2,
				  p_attribute22 IN VARCHAR2,
				  p_attribute23 IN VARCHAR2,
				  p_attribute24 IN VARCHAR2,
				  p_attribute25 IN VARCHAR2,
				  p_attribute26 IN VARCHAR2,
				  p_attribute27 IN VARCHAR2,
				  p_attribute28 IN VARCHAR2,
				  p_attribute29 IN VARCHAR2,
				  p_attribute30 IN VARCHAR2,
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
   l_msg_token := p_item_code || ' ' || p_item_no || ' ' || p_language;

/*  Now call the check integrity procedure */

   Check_Integrity
			     (l_called_by_form,
				  p_item_code,
				  p_item_no,
				  p_language,
				  p_label_code,
				  p_source_lang,
				  p_name_description,
				  p_attribute_category,
				  p_attribute1,
				  p_attribute2,
				  p_attribute3,
				  p_attribute4,
				  p_attribute5,
				  p_attribute6,
				  p_attribute7,
				  p_attribute8,
				  p_attribute9,
				  p_attribute10,
				  p_attribute11,
				  p_attribute12,
				  p_attribute13,
				  p_attribute14,
				  p_attribute15,
				  p_attribute16,
				  p_attribute17,
				  p_attribute18,
				  p_attribute19,
				  p_attribute20,
				  p_attribute21,
				  p_attribute22,
				  p_attribute23,
				  p_attribute24,
				  p_attribute25,
				  p_attribute26,
				  p_attribute27,
				  p_attribute28,
				  p_attribute29,
				  p_attribute30,
				  l_return_status,
				  l_oracle_error,
				  l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Check_Integrity_Error;
   END IF;

   DELETE FROM gr_generic_ml_name_tl
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
				  p_item_no IN VARCHAR2,
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
   l_msg_token := p_item_code || ' ' || p_item_no;

/*
**		p_delete_option has one of three values.
**	    'G' - Delete all rows for the generic item in p_item_code.
**		'I' - Delete all rows for the specified item in p_item_no.
**		'B' - Delete all rows for the generic and specified item.
*/
   IF p_delete_option = 'G' THEN
      IF p_item_code IS NULL THEN
	     l_msg_token := 'Item Code';
	     RAISE Null_Delete_Option_Error;
	  ELSE
	     l_msg_token := p_item_code;

         DELETE FROM  gr_generic_ml_name_tl
         WHERE		  item_code = p_item_code;
   	  END IF;
   ELSIF p_delete_option = 'I' THEN
      IF p_item_no IS NULL THEN
	     l_msg_token := 'Item No.';
		 RAISE Null_Delete_Option_Error;
	  ELSE
	     l_msg_token := p_item_no;

         DELETE FROM	gr_generic_ml_name_tl
         WHERE			item_no = p_item_no;
	  END IF;
   ELSIF p_delete_option = 'B' THEN
      IF p_item_code IS NULL OR
	     p_item_no IS NULL THEN
		 l_msg_token := 'Item Code / Item No.';
		 RAISE Null_Delete_Option_Error;
	  ELSE
	     l_msg_token := p_item_code || ' ' || p_item_no;

		 DELETE FROM	gr_generic_ml_name_tl
		 WHERE			item_code = p_item_code
		 AND			item_no = p_item_no;
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
				  p_item_no IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_label_code IN VARCHAR2,
				  p_source_lang IN VARCHAR2,
				  p_name_description IN VARCHAR2,
				  p_attribute_category IN VARCHAR2,
				  p_attribute1 IN VARCHAR2,
				  p_attribute2 IN VARCHAR2,
				  p_attribute3 IN VARCHAR2,
				  p_attribute4 IN VARCHAR2,
				  p_attribute5 IN VARCHAR2,
				  p_attribute6 IN VARCHAR2,
				  p_attribute7 IN VARCHAR2,
				  p_attribute8 IN VARCHAR2,
				  p_attribute9 IN VARCHAR2,
				  p_attribute10 IN VARCHAR2,
				  p_attribute11 IN VARCHAR2,
				  p_attribute12 IN VARCHAR2,
				  p_attribute13 IN VARCHAR2,
				  p_attribute14 IN VARCHAR2,
				  p_attribute15 IN VARCHAR2,
				  p_attribute16 IN VARCHAR2,
				  p_attribute17 IN VARCHAR2,
				  p_attribute18 IN VARCHAR2,
				  p_attribute19 IN VARCHAR2,
				  p_attribute20 IN VARCHAR2,
				  p_attribute21 IN VARCHAR2,
				  p_attribute22 IN VARCHAR2,
				  p_attribute23 IN VARCHAR2,
				  p_attribute24 IN VARCHAR2,
				  p_attribute25 IN VARCHAR2,
				  p_attribute26 IN VARCHAR2,
				  p_attribute27 IN VARCHAR2,
				  p_attribute28 IN VARCHAR2,
				  p_attribute29 IN VARCHAR2,
				  p_attribute30 IN VARCHAR2,
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
/*	 Inventory Master   */

CURSOR c_get_ic_item
 IS
   SELECT	ic.item_id
   FROM		ic_item_mst ic
   WHERE	ic.item_no = p_item_no;
ICItemRecord		c_get_ic_item%ROWTYPE;

/*	 Language Codes */

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
   l_msg_token := p_item_code || ' ' || p_item_no || ' ' || p_language;

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

/*	Check the item no */

   OPEN c_get_ic_item;
   FETCH c_get_ic_item INTO ICItemRecord;
   IF c_get_ic_item%NOTFOUND THEN
	     x_return_status := 'E';
	     FND_MESSAGE.SET_NAME('GR',
	                          'GR_RECORD_NOT_FOUND');
	     FND_MESSAGE.SET_TOKEN('CODE',
	                           p_item_no,
							   FALSE);
	     l_msg_data := l_msg_data || FND_MESSAGE.Get || ' ';
   END IF;

/*	Check the label code */

   GR_LABELS_B_PKG.Check_Primary_Key
   					(p_label_code,
					 'F',
					 l_rowid,
					 l_key_exists);
   IF NOT FND_API.To_Boolean(l_key_exists) THEN
      x_return_status := 'E';
      FND_MESSAGE.SET_NAME('GR',
                           'GR_RECORD_NOT_FOUND');
      FND_MESSAGE.SET_TOKEN('CODE',
                            p_label_code,
   	    			   	    FALSE);
	  l_msg_data := l_msg_data || FND_MESSAGE.Get || ' ';
   END IF;

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
				  p_item_no IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_label_code IN VARCHAR2,
				  p_source_lang IN VARCHAR2,
				  p_name_description IN VARCHAR2,
				  p_attribute_category IN VARCHAR2,
				  p_attribute1 IN VARCHAR2,
				  p_attribute2 IN VARCHAR2,
				  p_attribute3 IN VARCHAR2,
				  p_attribute4 IN VARCHAR2,
				  p_attribute5 IN VARCHAR2,
				  p_attribute6 IN VARCHAR2,
				  p_attribute7 IN VARCHAR2,
				  p_attribute8 IN VARCHAR2,
				  p_attribute9 IN VARCHAR2,
				  p_attribute10 IN VARCHAR2,
				  p_attribute11 IN VARCHAR2,
				  p_attribute12 IN VARCHAR2,
				  p_attribute13 IN VARCHAR2,
				  p_attribute14 IN VARCHAR2,
				  p_attribute15 IN VARCHAR2,
				  p_attribute16 IN VARCHAR2,
				  p_attribute17 IN VARCHAR2,
				  p_attribute18 IN VARCHAR2,
				  p_attribute19 IN VARCHAR2,
				  p_attribute20 IN VARCHAR2,
				  p_attribute21 IN VARCHAR2,
				  p_attribute22 IN VARCHAR2,
				  p_attribute23 IN VARCHAR2,
				  p_attribute24 IN VARCHAR2,
				  p_attribute25 IN VARCHAR2,
				  p_attribute26 IN VARCHAR2,
				  p_attribute27 IN VARCHAR2,
				  p_attribute28 IN VARCHAR2,
				  p_attribute29 IN VARCHAR2,
				  p_attribute30 IN VARCHAR2,
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
/*		  p_item_code is the generic item code to check.
**		  p_item_no is the item number to check.
**	      p_language is the language code part of the key
**		  p_called_by_form is 'T' if called by a form or 'F' if not.
**		  x_rowid is the row id of the record if found.
**		  x_key_exists is 'T' is the record is found, 'F' if not.
*/
		  		 	(p_item_code IN VARCHAR2,
					 p_item_no IN VARCHAR2,
					 p_language IN VARCHAR2,
					 p_called_by_form IN VARCHAR2,
					 x_rowid OUT NOCOPY VARCHAR2,
					 x_key_exists OUT NOCOPY VARCHAR2)
  IS
/*	Alphanumeric variables	 */

L_MSG_DATA VARCHAR2(80);

/*		Declare any variables and the cursor */


CURSOR c_get_generic_tl_rowid
 IS
   SELECT gin.rowid
   FROM	  gr_generic_ml_name_tl gin
   WHERE  gin.item_code = p_item_code
   AND	  gin.item_no = p_item_no
   AND	  gin.language = p_language;
GenericTLRecord			   c_get_generic_tl_rowid%ROWTYPE;

BEGIN

   l_msg_data := p_item_code || ' ' || p_item_no || ' ' || p_language;

   x_key_exists := 'F';
   OPEN c_get_generic_tl_rowid;
   FETCH c_get_generic_tl_rowid INTO GenericTLRecord;
   IF c_get_generic_tl_rowid%FOUND THEN
      x_key_exists := 'T';
	  x_rowid := GenericTLRecord.rowid;
   ELSE
      x_key_exists := 'F';
   END IF;
   CLOSE c_get_generic_tl_rowid;

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

/*     28-Jan-2002     Melanie Grosser         BUG 2190024 - Procedure NEW_LANGUAGE had been
                                                 generated incorrectly.  I regenerated it.

*/
/*   Melanie Grosser 23-Dec-2003  BUG 3307401 - Regenerated procedure NEW_LANGUAGE using
                                  GR_GENERIC_ITEMS_B as the base table and fully defining the primary
                                  key.
*/
procedure NEW_LANGUAGE
is
begin
  delete from GR_GENERIC_ML_NAME_TL T
  where not exists
    (select NULL
    from GR_GENERIC_ITEMS_B B
    where B.ITEM_CODE = T.ITEM_CODE
    and B.ITEM_NO = T.ITEM_NO
    );

  update GR_GENERIC_ML_NAME_TL T set (
      NAME_DESCRIPTION
    ) = (select
      B.NAME_DESCRIPTION
    from GR_GENERIC_ML_NAME_TL B
    where B.ITEM_CODE = T.ITEM_CODE
    and B.ITEM_NO = T.ITEM_NO
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.ITEM_CODE,
      T.ITEM_NO,
      T.LANGUAGE
  ) in (select
      SUBT.ITEM_CODE,
      SUBT.ITEM_NO,
      SUBT.LANGUAGE
    from GR_GENERIC_ML_NAME_TL SUBB, GR_GENERIC_ML_NAME_TL SUBT
    where SUBB.ITEM_CODE = SUBT.ITEM_CODE
    and SUBB.ITEM_NO = SUBT.ITEM_NO
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME_DESCRIPTION <> SUBT.NAME_DESCRIPTION
  ));

  insert into GR_GENERIC_ML_NAME_TL (
    ATTRIBUTE10,
    ATTRIBUTE11,
    ATTRIBUTE12,
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE15,
    ATTRIBUTE16,
    ATTRIBUTE17,
    ATTRIBUTE18,
    ATTRIBUTE19,
    ATTRIBUTE20,
    ATTRIBUTE21,
    ATTRIBUTE22,
    ATTRIBUTE23,
    ATTRIBUTE24,
    ATTRIBUTE25,
    ATTRIBUTE26,
    ATTRIBUTE27,
    ATTRIBUTE28,
    ATTRIBUTE29,
    ATTRIBUTE30,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    ITEM_CODE,
    ITEM_NO,
    LABEL_CODE,
    NAME_DESCRIPTION,
    ATTRIBUTE_CATEGORY,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE9,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.ATTRIBUTE10,
    B.ATTRIBUTE11,
    B.ATTRIBUTE12,
    B.ATTRIBUTE13,
    B.ATTRIBUTE14,
    B.ATTRIBUTE15,
    B.ATTRIBUTE16,
    B.ATTRIBUTE17,
    B.ATTRIBUTE18,
    B.ATTRIBUTE19,
    B.ATTRIBUTE20,
    B.ATTRIBUTE21,
    B.ATTRIBUTE22,
    B.ATTRIBUTE23,
    B.ATTRIBUTE24,
    B.ATTRIBUTE25,
    B.ATTRIBUTE26,
    B.ATTRIBUTE27,
    B.ATTRIBUTE28,
    B.ATTRIBUTE29,
    B.ATTRIBUTE30,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    B.ITEM_CODE,
    B.ITEM_NO,
    B.LABEL_CODE,
    B.NAME_DESCRIPTION,
    B.ATTRIBUTE_CATEGORY,
    B.ATTRIBUTE1,
    B.ATTRIBUTE2,
    B.ATTRIBUTE3,
    B.ATTRIBUTE4,
    B.ATTRIBUTE5,
    B.ATTRIBUTE6,
    B.ATTRIBUTE7,
    B.ATTRIBUTE8,
    B.ATTRIBUTE9,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from GR_GENERIC_ML_NAME_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from GR_GENERIC_ML_NAME_TL T
    where T.ITEM_CODE = B.ITEM_CODE
    and T.ITEM_NO = B.ITEM_NO
    and T.LANGUAGE = L.LANGUAGE_CODE);

end NEW_LANGUAGE;

END GR_GENERIC_ML_NAME_TL_PKG;

/
