--------------------------------------------------------
--  DDL for Package Body GR_PHRASES_TL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GR_PHRASES_TL_PKG" AS
/*$Header: GRHIPHTB.pls 115.12 2002/10/28 19:54:36 methomas ship $*/
PROCEDURE Insert_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_phrase_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_source_lang IN VARCHAR2,
				  p_key_word1 IN VARCHAR2,
				  p_key_word2 IN VARCHAR2,
				  p_key_word3 IN VARCHAR2,
				  p_key_word4 IN VARCHAR2,
				  p_key_word5 IN VARCHAR2,
				  p_key_word6 IN VARCHAR2,
				  p_phrase_text IN VARCHAR2,
				  p_print_font IN VARCHAR2,
				  p_print_size IN NUMBER,
				  p_image_pathname IN VARCHAR2,
				  p_image_print_location IN VARCHAR2,
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
			     (p_phrase_code,
				  p_language,
				  p_source_lang,
				  p_key_word1,
				  p_key_word2,
				  p_key_word3,
				  p_key_word4,
				  p_key_word5,
				  p_key_word6,
				  p_phrase_text,
				  p_print_font,
				  p_print_size,
				  p_image_pathname,
				  p_image_print_location,
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
   	   	   		 (p_phrase_code,
				  p_language,
				  'F',
				  l_rowid,
				  l_key_exists);

   IF FND_API.To_Boolean(l_key_exists) THEN
   	  RAISE Item_Exists_Error;
   END IF;

   INSERT INTO gr_phrases_tl
   		  	     (phrase_code,
				  language,
				  source_lang,
				  key_word1,
				  key_word2,
				  key_word3,
				  key_word4,
				  key_word5,
				  key_word6,
				  phrase_text,
				  print_font,
				  print_size,
				  image_pathname,
				  image_print_location,
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
		         (p_phrase_code,
				  p_language,
				  p_source_lang,
				  p_key_word1,
				  p_key_word2,
				  p_key_word3,
				  p_key_word4,
				  p_key_word5,
				  p_key_word6,
				  p_phrase_text,
				  p_print_font,
				  p_print_size,
				  p_image_pathname,
				  p_image_print_location,
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
   	   	   		 (p_phrase_code,
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
	  l_msg_token := p_phrase_code || ' ' || p_language;
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
	  l_msg_token := p_phrase_code || ' ' || p_language;
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
	  l_msg_token := p_phrase_code || ' ' || p_language;
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
				  p_phrase_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_source_lang IN VARCHAR2,
				  p_key_word1 IN VARCHAR2,
				  p_key_word2 IN VARCHAR2,
				  p_key_word3 IN VARCHAR2,
				  p_key_word4 IN VARCHAR2,
				  p_key_word5 IN VARCHAR2,
				  p_key_word6 IN VARCHAR2,
				  p_phrase_text IN VARCHAR2,
				  p_print_font IN VARCHAR2,
				  p_print_size IN NUMBER,
				  p_image_pathname IN VARCHAR2,
				  p_image_print_location IN VARCHAR2,
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
   l_msg_token := p_phrase_code || ' ' || p_language;

/*	  Now call the check foreign key procedure */

   Check_Foreign_Keys
			     (p_phrase_code,
				  p_language,
				  p_source_lang,
				  p_key_word1,
				  p_key_word2,
				  p_key_word3,
				  p_key_word4,
				  p_key_word5,
				  p_key_word6,
				  p_phrase_text,
				  p_print_font,
				  p_print_size,
				  p_image_pathname,
				  p_image_print_location,
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
      UPDATE gr_phrases_tl
	  SET	 phrase_code		 	 	 	 = p_phrase_code,
	  		 language						 = p_language,
			 source_lang					 = p_source_lang,
			 key_word1						 = p_key_word1,
			 key_word2						 = p_key_word2,
			 key_word3						 = p_key_word3,
			 key_word4						 = p_key_word4,
			 key_word5						 = p_key_word5,
			 key_word6						 = p_key_word6,
			 phrase_text					 = p_phrase_text,
			 print_font						 = p_print_font,
			 print_size						 = p_print_size,
			 image_pathname					 = p_image_pathname,
			 image_print_location			 = p_image_print_location,
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
				  p_phrase_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2)
 IS

/*   Alpha Variables */

L_RETURN_STATUS	  		VARCHAR2(1) := 'S';
L_MSG_DATA		  		VARCHAR2(2000);
L_MSG_TOKEN		  		VARCHAR2(100);
L_BASE_DESC				GR_PHRASES_TL.phrase_text%TYPE;
L_LANGUAGE		  		VARCHAR2(4);
L_CREATION_DATE	 		DATE;
L_LAST_UPDATE_DATE		DATE;
L_KEY_WORD1				GR_PHRASES_TL.key_word1%TYPE;
L_KEY_WORD2				GR_PHRASES_TL.key_word2%TYPE;
L_KEY_WORD3				GR_PHRASES_TL.key_word3%TYPE;
L_KEY_WORD4				GR_PHRASES_TL.key_word4%TYPE;
L_KEY_WORD5				GR_PHRASES_TL.key_word5%TYPE;
L_KEY_WORD6				GR_PHRASES_TL.key_word6%TYPE;
L_PRINT_FONT			GR_PHRASES_TL.print_font%TYPE;
L_IMAGE_PATHNAME		GR_PHRASES_TL.image_pathname%TYPE;
L_IMAGE_PRINT_LOCATION	GR_PHRASES_TL.image_print_location%TYPE;
L_ATTRIBUTE_CATEGORY	GR_PHRASES_TL.attribute_category%TYPE;
L_ATTRIBUTE1			GR_PHRASES_TL.attribute1%TYPE;
L_ATTRIBUTE2			GR_PHRASES_TL.attribute2%TYPE;
L_ATTRIBUTE3			GR_PHRASES_TL.attribute3%TYPE;
L_ATTRIBUTE4			GR_PHRASES_TL.attribute4%TYPE;
L_ATTRIBUTE5			GR_PHRASES_TL.attribute5%TYPE;
L_ATTRIBUTE6			GR_PHRASES_TL.attribute6%TYPE;
L_ATTRIBUTE7			GR_PHRASES_TL.attribute7%TYPE;
L_ATTRIBUTE8			GR_PHRASES_TL.attribute8%TYPE;
L_ATTRIBUTE9			GR_PHRASES_TL.attribute9%TYPE;
L_ATTRIBUTE10			GR_PHRASES_TL.attribute10%TYPE;
L_ATTRIBUTE11			GR_PHRASES_TL.attribute11%TYPE;
L_ATTRIBUTE12			GR_PHRASES_TL.attribute12%TYPE;
L_ATTRIBUTE13			GR_PHRASES_TL.attribute13%TYPE;
L_ATTRIBUTE14			GR_PHRASES_TL.attribute14%TYPE;
L_ATTRIBUTE15			GR_PHRASES_TL.attribute15%TYPE;
L_ATTRIBUTE16			GR_PHRASES_TL.attribute16%TYPE;
L_ATTRIBUTE17			GR_PHRASES_TL.attribute17%TYPE;
L_ATTRIBUTE18			GR_PHRASES_TL.attribute18%TYPE;
L_ATTRIBUTE19			GR_PHRASES_TL.attribute19%TYPE;
L_ATTRIBUTE20			GR_PHRASES_TL.attribute20%TYPE;
L_ATTRIBUTE21			GR_PHRASES_TL.attribute21%TYPE;
L_ATTRIBUTE22			GR_PHRASES_TL.attribute22%TYPE;
L_ATTRIBUTE23			GR_PHRASES_TL.attribute23%TYPE;
L_ATTRIBUTE24			GR_PHRASES_TL.attribute24%TYPE;
L_ATTRIBUTE25			GR_PHRASES_TL.attribute25%TYPE;
L_ATTRIBUTE26			GR_PHRASES_TL.attribute26%TYPE;
L_ATTRIBUTE27			GR_PHRASES_TL.attribute27%TYPE;
L_ATTRIBUTE28			GR_PHRASES_TL.attribute28%TYPE;
L_ATTRIBUTE29			GR_PHRASES_TL.attribute29%TYPE;
L_ATTRIBUTE30			GR_PHRASES_TL.attribute30%TYPE;

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
   SELECT		pht.phrase_text,
			pht.key_word1,
			pht.key_word2,
			pht.key_word3,
			pht.key_word4,
			pht.key_word5,
			pht.key_word6,
			pht.print_font,
			pht.print_size,
			pht.image_pathname,
			pht.image_print_location,
			pht.attribute_category,
			pht.attribute1,
			pht.attribute2,
			pht.attribute3,
			pht.attribute4,
			pht.attribute5,
			pht.attribute6,
			pht.attribute7,
			pht.attribute8,
			pht.attribute9,
			pht.attribute10,
			pht.attribute11,
			pht.attribute12,
			pht.attribute13,
			pht.attribute14,
			pht.attribute15,
			pht.attribute16,
			pht.attribute17,
			pht.attribute18,
			pht.attribute19,
			pht.attribute20,
			pht.attribute21,
			pht.attribute22,
			pht.attribute23,
			pht.attribute24,
			pht.attribute25,
			pht.attribute26,
			pht.attribute27,
			pht.attribute28,
			pht.attribute29,
			pht.attribute30,
         		pht.created_by,
			pht.creation_date,
			pht.last_updated_by,
			pht.last_update_date,
			pht.last_update_login
   FROM	    gr_phrases_tl pht
   WHERE	pht.phrase_code = p_phrase_code
   AND		pht.language = l_language;
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
   l_msg_token := p_phrase_code || ' ' || p_language;

/* Remove translations with no base row */

  delete from GR_PHRASES_TL T
  where not exists
    (select NULL
    from GR_PHRASES_B B
    where B.PHRASE_CODE = T.PHRASE_CODE
    );

/* Redefault translations from the source language  */

   update gr_phrases_tl t set (
    phrase_text ) =
    ( select
      B.PHRASE_TEXT
      from GR_PHRASES_TL B
      where B.PHRASE_CODE = T.PHRASE_CODE
      and B.LANGUAGE = T.SOURCE_LANG)
   where (
      T.PHRASE_CODE,
      T.LANGUAGE
   ) in (select
         SUBT.PHRASE_CODE,
         SUBT.LANGUAGE
         from GR_PHRASES_TL SUBB, GR_PHRASES_TL SUBT
         where SUBB.PHRASE_CODE = SUBT.PHRASE_CODE
         and SUBB.LANGUAGE = SUBT.SOURCE_LANG
         and (SUBB.PHRASE_TEXT <> SUBT.PHRASE_TEXT
          or (SUBB.PHRASE_TEXT is null and SUBT.PHRASE_TEXT is not null)
          or (SUBB.PHRASE_TEXT is not null and SUBT.PHRASE_TEXT is null)
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
      l_base_desc := PhraseDesc.phrase_text;
	  l_key_word1 := PhraseDesc.key_word1;
	  l_key_word2 := PhraseDesc.key_word2;
	  l_key_word3 := PhraseDesc.key_word3;
	  l_key_word4 := PhraseDesc.key_word4;
	  l_key_word5 := PhraseDesc.key_word5;
	  l_key_word6 := PhraseDesc.key_word6;
	  l_print_font := PhraseDesc.print_font;
	  l_print_size := PhraseDesc.print_size;
	  l_image_pathname := PhraseDesc.image_pathname;
	  l_image_print_location := PhraseDesc.image_print_location;
	  l_attribute_category := PhraseDesc.attribute_category;
	  l_attribute1 := PhraseDesc.attribute1;
	  l_attribute2 := PhraseDesc.attribute2;
	  l_attribute3 := PhraseDesc.attribute3;
	  l_attribute4 := PhraseDesc.attribute4;
	  l_attribute5 := PhraseDesc.attribute5;
	  l_attribute6 := PhraseDesc.attribute6;
	  l_attribute7 := PhraseDesc.attribute7;
	  l_attribute8 := PhraseDesc.attribute8;
	  l_attribute9 := PhraseDesc.attribute9;
	  l_attribute10 := PhraseDesc.attribute10;
	  l_attribute11 := PhraseDesc.attribute11;
	  l_attribute12 := PhraseDesc.attribute12;
	  l_attribute13 := PhraseDesc.attribute13;
	  l_attribute14 := PhraseDesc.attribute14;
	  l_attribute15 := PhraseDesc.attribute15;
	  l_attribute16 := PhraseDesc.attribute16;
	  l_attribute17 := PhraseDesc.attribute17;
	  l_attribute18 := PhraseDesc.attribute18;
	  l_attribute19 := PhraseDesc.attribute19;
	  l_attribute20 := PhraseDesc.attribute20;
	  l_attribute21 := PhraseDesc.attribute21;
	  l_attribute22 := PhraseDesc.attribute22;
	  l_attribute23 := PhraseDesc.attribute23;
	  l_attribute24 := PhraseDesc.attribute24;
	  l_attribute25 := PhraseDesc.attribute25;
	  l_attribute26 := PhraseDesc.attribute26;
	  l_attribute27 := PhraseDesc.attribute27;
	  l_attribute28 := PhraseDesc.attribute28;
	  l_attribute29 := PhraseDesc.attribute29;
	  l_attribute30 := PhraseDesc.attribute30;
	  l_created_by := PhraseDesc.created_by;
	  l_creation_date := PhraseDesc.creation_date;
	  l_last_updated_by := PhraseDesc.last_updated_by;
	  l_last_update_date := PhraseDesc.last_update_date;
	  l_last_update_login := PhraseDesc.last_update_login;
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
			FETCH c_get_descs INTO PhraseDesc;
			IF c_get_descs%NOTFOUND THEN
			   CLOSE c_get_descs;
			   INSERT INTO gr_phrases_tl
						(phrase_code,
						 language,
						 source_lang,
						 key_word1,
						 key_word2,
						 key_word3,
						 key_word4,
						 key_word5,
						 key_word6,
						 phrase_text,
						 print_font,
						 print_size,
						 image_pathname,
						 image_print_location,
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
				        (p_phrase_code,
						 l_language,
						 p_language,
						 l_key_word1,
						 l_key_word2,
						 l_key_word3,
						 l_key_word4,
						 l_key_word5,
						 l_key_word6,
						 l_base_desc,
						 l_print_font,
						 l_print_size,
						 l_image_pathname,
						 l_image_print_location,
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
				  p_phrase_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_source_lang IN VARCHAR2,
				  p_key_word1 IN VARCHAR2,
				  p_key_word2 IN VARCHAR2,
				  p_key_word3 IN VARCHAR2,
				  p_key_word4 IN VARCHAR2,
				  p_key_word5 IN VARCHAR2,
				  p_key_word6 IN VARCHAR2,
				  p_phrase_text IN VARCHAR2,
				  p_print_font IN VARCHAR2,
				  p_print_size IN NUMBER,
				  p_image_pathname IN VARCHAR2,
				  p_image_print_location IN VARCHAR2,
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

CURSOR c_lock_phrases_tl
 IS
   SELECT	last_update_date
   FROM		gr_phrases_tl
   WHERE	rowid = p_rowid
   FOR UPDATE NOWAIT;
LockPhraseRcd	  c_lock_phrases_tl%ROWTYPE;

BEGIN

/*      Initialization Routine */

   SAVEPOINT Lock_Row;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;
   l_msg_token := p_phrase_code || ' ' || p_language;

/*	   Now lock the record */

   OPEN c_lock_phrases_tl;
   FETCH c_lock_phrases_tl INTO LockPhraseRcd;
   IF c_lock_phrases_tl%NOTFOUND THEN
	  CLOSE c_lock_phrases_tl;
	  RAISE No_Data_Found_Error;
   END IF;
   CLOSE c_lock_phrases_tl;

   IF LockPhraseRcd.last_update_date <> p_last_update_date THEN
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
				  p_phrase_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_source_lang IN VARCHAR2,
				  p_key_word1 IN VARCHAR2,
				  p_key_word2 IN VARCHAR2,
				  p_key_word3 IN VARCHAR2,
				  p_key_word4 IN VARCHAR2,
				  p_key_word5 IN VARCHAR2,
				  p_key_word6 IN VARCHAR2,
				  p_phrase_text IN VARCHAR2,
				  p_print_font IN VARCHAR2,
				  p_print_size IN NUMBER,
				  p_image_pathname IN VARCHAR2,
				  p_image_print_location IN VARCHAR2,
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
   l_msg_token := p_phrase_code || ' ' || p_language;

/*  Now call the check integrity procedure */

   Check_Integrity
			     (l_called_by_form,
			      p_phrase_code,
				  p_language,
				  p_source_lang,
				  p_key_word1,
				  p_key_word2,
				  p_key_word3,
				  p_key_word4,
				  p_key_word5,
				  p_key_word6,
				  p_phrase_text,
				  p_print_font,
				  p_print_size,
				  p_image_pathname,
				  p_image_print_location,
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

   DELETE FROM gr_phrases_tl
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
	              p_phrase_code IN VARCHAR2,
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
   l_msg_token := p_phrase_code;

   DELETE FROM gr_phrases_tl
   WHERE 	   phrase_code = p_phrase_code;

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
	   			 (p_phrase_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_source_lang IN VARCHAR2,
				  p_key_word1 IN VARCHAR2,
				  p_key_word2 IN VARCHAR2,
				  p_key_word3 IN VARCHAR2,
				  p_key_word4 IN VARCHAR2,
				  p_key_word5 IN VARCHAR2,
				  p_key_word6 IN VARCHAR2,
				  p_phrase_text IN VARCHAR2,
				  p_print_font IN VARCHAR2,
				  p_print_size IN NUMBER,
				  p_image_pathname IN VARCHAR2,
				  p_image_print_location IN VARCHAR2,
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
   l_msg_token := p_phrase_code || ' ' || p_language;

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
	                        l_msg_token,
	                        FALSE);
	  x_msg_data := FND_MESSAGE.Get;

END Check_Foreign_Keys;

PROCEDURE Check_Integrity
	   			 (p_called_by_form IN VARCHAR2,
				  p_phrase_code IN VARCHAR2,
				  p_language IN VARCHAR2,
				  p_source_lang IN VARCHAR2,
				  p_key_word1 IN VARCHAR2,
				  p_key_word2 IN VARCHAR2,
				  p_key_word3 IN VARCHAR2,
				  p_key_word4 IN VARCHAR2,
				  p_key_word5 IN VARCHAR2,
				  p_key_word6 IN VARCHAR2,
				  p_phrase_text IN VARCHAR2,
				  p_print_font IN VARCHAR2,
				  p_print_size IN NUMBER,
				  p_image_pathname IN VARCHAR2,
				  p_image_print_location IN VARCHAR2,
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
/*		  p_phrase_code is the phrase code to check.
**	      p_language is the language code part of the key
**		  p_called_by_form is 'T' if called by a form or 'F' if not.
**		  x_rowid is the row id of the record if found.
**		  x_key_exists is 'T' is the record is found, 'F' if not.
*/
		  		 	(p_phrase_code IN VARCHAR2,
					 p_language IN VARCHAR2,
					 p_called_by_form IN VARCHAR2,
					 x_rowid OUT NOCOPY VARCHAR2,
					 x_key_exists OUT NOCOPY VARCHAR2)
  IS
/*	Alphanumeric variables	 */

L_MSG_DATA VARCHAR2(80);

/*		Declare any variables and the cursor */


CURSOR c_get_phrases_tl_rowid
 IS
   SELECT pht.rowid
   FROM	  gr_phrases_tl pht
   WHERE  pht.phrase_code = p_phrase_code
   AND	  pht.language = p_language;
PhraseTLRecord			   c_get_phrases_tl_rowid%ROWTYPE;

BEGIN

   l_msg_data := p_phrase_code || ' ' || p_language;

   x_key_exists := 'F';
   OPEN c_get_phrases_tl_rowid;
   FETCH c_get_phrases_tl_rowid INTO PhraseTLRecord;
   IF c_get_phrases_tl_rowid%FOUND THEN
      x_key_exists := 'T';
	  x_rowid := PhraseTLRecord.rowid;
   ELSE
      x_key_exists := 'F';
   END IF;
   CLOSE c_get_phrases_tl_rowid;

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
	X_IMAGE_PRINT_LOCATION IN VARCHAR2
	,X_PHRASE_CODE IN VARCHAR2
	,X_LANGUAGE IN VARCHAR2
	,X_SOURCE_LANG IN VARCHAR2
	,X_KEY_WORD1 IN VARCHAR2
	,X_KEY_WORD2 IN VARCHAR2
	,X_KEY_WORD3 IN VARCHAR2
	,X_KEY_WORD4 IN VARCHAR2
	,X_KEY_WORD5 IN VARCHAR2
	,X_KEY_WORD6 IN VARCHAR2
	,X_PHRASE_TEXT IN VARCHAR2
	,X_PRINT_FONT IN VARCHAR2
	,X_PRINT_SIZE IN NUMBER
	,X_IMAGE_PATHNAME IN VARCHAR2
) IS
BEGIN
	UPDATE GR_PHRASES_TL SET
		PHRASE_TEXT = X_PHRASE_TEXT,
		SOURCE_LANG = USERENV('LANG'),
		LAST_UPDATE_DATE = sysdate,
		LAST_UPDATED_BY = 0,
		LAST_UPDATE_LOGIN = 0
	WHERE (PHRASE_CODE = X_PHRASE_CODE)
	AND   (USERENV('LANG') IN (LANGUAGE, SOURCE_LANG));
END TRANSLATE_ROW;


PROCEDURE load_row (
	X_IMAGE_PRINT_LOCATION IN VARCHAR2
	,X_PHRASE_CODE IN VARCHAR2
	,X_LANGUAGE IN VARCHAR2
	,X_SOURCE_LANG IN VARCHAR2
	,X_KEY_WORD1 IN VARCHAR2
	,X_KEY_WORD2 IN VARCHAR2
	,X_KEY_WORD3 IN VARCHAR2
	,X_KEY_WORD4 IN VARCHAR2
	,X_KEY_WORD5 IN VARCHAR2
	,X_KEY_WORD6 IN VARCHAR2
	,X_PHRASE_TEXT IN VARCHAR2
	,X_PRINT_FONT IN VARCHAR2
	,X_PRINT_SIZE IN NUMBER
	,X_IMAGE_PATHNAME IN VARCHAR2
) IS
	CURSOR Cur_rowid IS
		SELECT rowid
		FROM GR_PHRASES_TL
			WHERE (PHRASE_CODE = X_PHRASE_CODE)
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
		GR_PHRASES_TL_PKG.UPDATE_ROW(
			P_COMMIT => 'T'
			,P_CALLED_BY_FORM => 'F'
			,P_ROWID => l_row_id
			,P_IMAGE_PRINT_LOCATION => X_IMAGE_PRINT_LOCATION
			,P_PHRASE_CODE => X_PHRASE_CODE
			,P_LANGUAGE => X_LANGUAGE
			,P_SOURCE_LANG => X_SOURCE_LANG
			,P_KEY_WORD1 => X_KEY_WORD1
			,P_KEY_WORD2 => X_KEY_WORD2
			,P_KEY_WORD3 => X_KEY_WORD3
			,P_KEY_WORD4 => X_KEY_WORD4
			,P_KEY_WORD5 => X_KEY_WORD5
			,P_KEY_WORD6 => X_KEY_WORD6
			,P_PHRASE_TEXT => X_PHRASE_TEXT
			,P_PRINT_FONT => X_PRINT_FONT
			,P_PRINT_SIZE => X_PRINT_SIZE
			,P_IMAGE_PATHNAME => X_IMAGE_PATHNAME
		        ,P_ATTRIBUTE_CATEGORY => NULL
		        ,P_ATTRIBUTE1 => NULL
		        ,P_ATTRIBUTE2 => NULL
		        ,P_ATTRIBUTE3 => NULL
		        ,P_ATTRIBUTE4 => NULL
		        ,P_ATTRIBUTE5 => NULL
		        ,P_ATTRIBUTE6 => NULL
		        ,P_ATTRIBUTE7 => NULL
		        ,P_ATTRIBUTE8 => NULL
		        ,P_ATTRIBUTE9 => NULL
		        ,P_ATTRIBUTE10 => NULL
		        ,P_ATTRIBUTE11 => NULL
		        ,P_ATTRIBUTE12 => NULL
		        ,P_ATTRIBUTE13 => NULL
		        ,P_ATTRIBUTE14 => NULL
		        ,P_ATTRIBUTE15 => NULL
		        ,P_ATTRIBUTE16 => NULL
		        ,P_ATTRIBUTE17 => NULL
		        ,P_ATTRIBUTE18 => NULL
		        ,P_ATTRIBUTE19 => NULL
		        ,P_ATTRIBUTE20 => NULL
		        ,P_ATTRIBUTE21 => NULL
		        ,P_ATTRIBUTE22 => NULL
		        ,P_ATTRIBUTE23 => NULL
		        ,P_ATTRIBUTE24 => NULL
		        ,P_ATTRIBUTE25 => NULL
		        ,P_ATTRIBUTE26 => NULL
		        ,P_ATTRIBUTE27 => NULL
		        ,P_ATTRIBUTE28 => NULL
		        ,P_ATTRIBUTE29 => NULL
		        ,P_ATTRIBUTE30 => NULL
			,P_CREATED_BY => l_user_id
			,P_CREATION_DATE => sysdate
			,P_LAST_UPDATED_BY => l_user_id
			,P_LAST_UPDATE_DATE => sysdate
			,P_LAST_UPDATE_LOGIN => 0
			,X_RETURN_STATUS => l_return_status
			,X_ORACLE_ERROR => l_oracle_error
			,X_MSG_DATA => l_msg_data);
	ELSE
		GR_PHRASES_TL_PKG.INSERT_ROW(
			P_COMMIT => 'T'
			,P_CALLED_BY_FORM => 'F'
			,P_IMAGE_PRINT_LOCATION => X_IMAGE_PRINT_LOCATION
			,P_PHRASE_CODE => X_PHRASE_CODE
			,P_LANGUAGE => X_LANGUAGE
			,P_SOURCE_LANG => X_SOURCE_LANG
			,P_KEY_WORD1 => X_KEY_WORD1
			,P_KEY_WORD2 => X_KEY_WORD2
			,P_KEY_WORD3 => X_KEY_WORD3
			,P_KEY_WORD4 => X_KEY_WORD4
			,P_KEY_WORD5 => X_KEY_WORD5
			,P_KEY_WORD6 => X_KEY_WORD6
			,P_PHRASE_TEXT => X_PHRASE_TEXT
			,P_PRINT_FONT => X_PRINT_FONT
			,P_PRINT_SIZE => X_PRINT_SIZE
			,P_IMAGE_PATHNAME => X_IMAGE_PATHNAME
		        ,P_ATTRIBUTE_CATEGORY => NULL
		        ,P_ATTRIBUTE1 => NULL
		        ,P_ATTRIBUTE2 => NULL
		        ,P_ATTRIBUTE3 => NULL
		        ,P_ATTRIBUTE4 => NULL
		        ,P_ATTRIBUTE5 => NULL
		        ,P_ATTRIBUTE6 => NULL
		        ,P_ATTRIBUTE7 => NULL
		        ,P_ATTRIBUTE8 => NULL
		        ,P_ATTRIBUTE9 => NULL
		        ,P_ATTRIBUTE10 => NULL
		        ,P_ATTRIBUTE11 => NULL
		        ,P_ATTRIBUTE12 => NULL
		        ,P_ATTRIBUTE13 => NULL
		        ,P_ATTRIBUTE14 => NULL
		        ,P_ATTRIBUTE15 => NULL
		        ,P_ATTRIBUTE16 => NULL
		        ,P_ATTRIBUTE17 => NULL
		        ,P_ATTRIBUTE18 => NULL
		        ,P_ATTRIBUTE19 => NULL
		        ,P_ATTRIBUTE20 => NULL
		        ,P_ATTRIBUTE21 => NULL
		        ,P_ATTRIBUTE22 => NULL
		        ,P_ATTRIBUTE23 => NULL
		        ,P_ATTRIBUTE24 => NULL
		        ,P_ATTRIBUTE25 => NULL
		        ,P_ATTRIBUTE26 => NULL
		        ,P_ATTRIBUTE27 => NULL
		        ,P_ATTRIBUTE28 => NULL
		        ,P_ATTRIBUTE29 => NULL
		        ,P_ATTRIBUTE30 => NULL
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
  delete from GR_PHRASES_TL T
  where not exists
    (select NULL
    from GR_PHRASES_B B
    where B.PHRASE_CODE = T.PHRASE_CODE
    );

  update GR_PHRASES_TL T set (
      PHRASE_TEXT
    ) = (select
      B.PHRASE_TEXT
    from GR_PHRASES_TL B
    where B.PHRASE_CODE = T.PHRASE_CODE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.PHRASE_CODE,
      T.LANGUAGE
  ) in (select
      SUBT.PHRASE_CODE,
      SUBT.LANGUAGE
    from GR_PHRASES_TL SUBB, GR_PHRASES_TL SUBT
    where SUBB.PHRASE_CODE = SUBT.PHRASE_CODE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.PHRASE_TEXT <> SUBT.PHRASE_TEXT
  ));

  insert into GR_PHRASES_TL (
    IMAGE_PRINT_LOCATION,
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
    PHRASE_CODE,
    KEY_WORD1,
    KEY_WORD2,
    KEY_WORD3,
    KEY_WORD4,
    KEY_WORD5,
    KEY_WORD6,
    PHRASE_TEXT,
    PRINT_FONT,
    PRINT_SIZE,
    IMAGE_PATHNAME,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.IMAGE_PRINT_LOCATION,
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
    B.PHRASE_CODE,
    B.KEY_WORD1,
    B.KEY_WORD2,
    B.KEY_WORD3,
    B.KEY_WORD4,
    B.KEY_WORD5,
    B.KEY_WORD6,
    B.PHRASE_TEXT,
    B.PRINT_FONT,
    B.PRINT_SIZE,
    B.IMAGE_PATHNAME,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from GR_PHRASES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from GR_PHRASES_TL T
    where T.PHRASE_CODE = B.PHRASE_CODE
    and T.LANGUAGE = L.LANGUAGE_CODE);

end NEW_LANGUAGE;

END GR_PHRASES_TL_PKG;

/
