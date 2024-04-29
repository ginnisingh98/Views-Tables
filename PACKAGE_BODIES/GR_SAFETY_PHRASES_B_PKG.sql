--------------------------------------------------------
--  DDL for Package Body GR_SAFETY_PHRASES_B_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GR_SAFETY_PHRASES_B_PKG" AS
/*$Header: GRHISPB.pls 115.7 2002/10/28 20:01:27 gkelly ship $*/
PROCEDURE Insert_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_safety_phrase_code IN VARCHAR2,
				  p_additional_text_type IN VARCHAR2,
				  p_lookup_type IN VARCHAR2,
				  p_lookup_code IN VARCHAR2,
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

L_RETURN_STATUS 	VARCHAR2(1) := 'S';
L_KEY_EXISTS 		VARCHAR2(1);
L_MSG_DATA 			VARCHAR2(2000);
L_ROWID 			VARCHAR2(18);

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
				  p_additional_text_type,
				  p_lookup_type,
				  p_lookup_code,
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
   	   	   		 (p_safety_phrase_code,
				  'F',
				  l_rowid,
				  l_key_exists);

   IF FND_API.To_Boolean(l_key_exists) THEN
   	  RAISE Item_Exists_Error;
   END IF;

   INSERT INTO gr_safety_phrases_b
   		  	     (safety_phrase_code,
				  additional_text_type,
				  lookup_type,
				  lookup_code,
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
		         (p_safety_phrase_code,
				  p_additional_text_type,
				  p_lookup_type,
				  p_lookup_code,
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
   	   	   		 (p_safety_phrase_code,
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
         		            p_safety_phrase_code,
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
         		            p_safety_phrase_code,
            			    FALSE);
      IF FND_API.To_Boolean(p_called_by_form) THEN
	     APP_EXCEPTION.Raise_Exception;
	  ELSE
	     x_msg_data := FND_MESSAGE.Get;
	  END IF;

   WHEN OTHERS THEN
      ROLLBACK TO SAVEPOINT Insert_Row;
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

END Insert_Row;

PROCEDURE Update_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_rowid IN VARCHAR2,
				  p_safety_phrase_code IN VARCHAR2,
				  p_additional_text_type IN VARCHAR2,
				  p_lookup_type IN VARCHAR2,
				  p_lookup_code IN VARCHAR2,
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
			     (p_safety_phrase_code,
				  p_additional_text_type,
				  p_lookup_type,
				  p_lookup_code,
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
      UPDATE gr_safety_phrases_b
	  SET	 safety_phrase_code 	 	 	 = p_safety_phrase_code,
	  		 additional_text_type			 = p_additional_text_type,
			 lookup_type					 = p_lookup_type,
			 lookup_code					 = p_lookup_code,
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
         		            p_safety_phrase_code,
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
	                        l_msg_data,
	                        FALSE);
      IF FND_API.To_Boolean(p_called_by_form) THEN
	     APP_EXCEPTION.Raise_Exception;
	  ELSE
	     x_msg_data := FND_MESSAGE.Get;
	  END IF;

END Update_Row;

PROCEDURE Lock_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_rowid IN VARCHAR2,
				  p_safety_phrase_code IN VARCHAR2,
				  p_additional_text_type IN VARCHAR2,
				  p_lookup_type IN VARCHAR2,
				  p_lookup_code IN VARCHAR2,
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

/*  Number Variables */

L_ORACLE_ERROR	  NUMBER;

/*   Exceptions */

NO_DATA_FOUND_ERROR 		EXCEPTION;
RECORD_CHANGED_ERROR	 	EXCEPTION;

/*   Define the cursors */

CURSOR c_lock_safety
 IS
   SELECT	last_update_date
   FROM		gr_safety_phrases_b
   WHERE	rowid = p_rowid
   FOR UPDATE NOWAIT;
LockSafetyRcd	  c_lock_safety%ROWTYPE;
BEGIN

/*      Initialization Routine */

   SAVEPOINT Lock_Row;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;

/*	   Now lock the record */

   OPEN c_lock_safety;
   FETCH c_lock_safety INTO LockSafetyRcd;
   IF c_lock_safety%NOTFOUND THEN
	  CLOSE c_lock_safety;
	  RAISE No_Data_Found_Error;
   END IF;
   CLOSE c_lock_safety;

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
	                        p_safety_phrase_code,
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
				  p_safety_phrase_code IN VARCHAR2,
				  p_additional_text_type IN VARCHAR2,
				  p_lookup_type IN VARCHAR2,
				  p_lookup_code IN VARCHAR2,
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
L_CALLED_BY_FORM  VARCHAR2(1);

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
   l_called_by_form := 'F';
   x_oracle_error := 0;
   x_msg_data := NULL;

/*  Now call the check integrity procedure */

   Check_Integrity
			     (l_called_by_form,
			      p_safety_phrase_code,
				  p_additional_text_type,
				  p_lookup_type,
				  p_lookup_code,
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

   DELETE FROM gr_safety_phrases_b
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
         		            p_safety_phrase_code,
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
	                        l_msg_data,
	                        FALSE);
      IF FND_API.To_Boolean(p_called_by_form) THEN
	     APP_EXCEPTION.Raise_Exception;
	  ELSE
	     x_msg_data := FND_MESSAGE.Get;
	  END IF;

END Delete_Row;

PROCEDURE Check_Foreign_Keys
	   			 (p_safety_phrase_code IN VARCHAR2,
				  p_additional_text_type IN VARCHAR2,
				  p_lookup_type IN VARCHAR2,
				  p_lookup_code IN VARCHAR2,
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

/*   Number Variables */

L_ORACLE_ERROR	  NUMBER;

/*   Define the cursors */

BEGIN

/*   Initialization Routine */

   SAVEPOINT Check_Foreign_Keys;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;

/*   No foreign key references to check */


/* 	   Check the not null columns */

   IF p_additional_text_type IS NULL THEN
      x_return_status := 'E';
	  l_msg_data := l_msg_data || ' Additional Text Type cannot be null.';
   END IF;

   IF x_return_status <> 'S' THEN
      x_msg_data := l_msg_data;
   END IF;

EXCEPTION

   WHEN OTHERS THEN
      ROLLBACK TO SAVEPOINT Check_Foreign_Keys;
	  x_return_status := 'U';
	  x_oracle_error := APP_EXCEPTION.Get_Code;
	  l_msg_data := APP_EXCEPTION.Get_Text;
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_UNEXPECTED_ERROR');
	  FND_MESSAGE.SET_TOKEN('TEXT',
	                        l_msg_data,
	                        FALSE);
	  x_msg_data := FND_MESSAGE.Get;

END Check_Foreign_Keys;

PROCEDURE Check_Integrity
	   			 (p_called_by_form IN VARCHAR2,
	   			  p_safety_phrase_code IN VARCHAR2,
				  p_additional_text_type IN VARCHAR2,
				  p_lookup_type IN VARCHAR2,
				  p_lookup_code IN VARCHAR2,
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

/*  Exceptions */
INTEGRITY_ERROR	  EXCEPTION;

/*	 Define the Cursors */
/*   Item Safety Phrases table */

CURSOR c_get_item_safety_phrases
 IS
   SELECT COUNT(*)
   FROM	  gr_item_safety_phrases isp
   WHERE  isp.safety_phrase_code = p_safety_phrase_code;

BEGIN

/*     Initialization Routine */

   SAVEPOINT Check_Integrity;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;

/* 	Now read the cursors to make sure the safety phrase code isn't used. */

/* 	 Item Safety Phrases */

   l_record_count := 0;
   l_code_block := 'c_get_item_safety_phrases';
   OPEN c_get_item_safety_phrases;
   FETCH c_get_item_safety_phrases INTO l_record_count;
   IF l_record_count <> 0 THEN
      l_return_status := 'E';
	  l_msg_data := l_msg_data || 'gr_item_safety_phrases, ';
   END IF;
   CLOSE c_get_item_safety_phrases;


/*	 Now sort out the error messaging */

   IF l_return_status <> 'S' THEN
     RAISE INTEGRITY_ERROR;
   END IF;

EXCEPTION
   WHEN INTEGRITY_ERROR THEN
      x_return_status := 'E';
      FND_MESSAGE.SET_NAME('GR',
                           'GR_INTEGRITY_HEADER');
      FND_MESSAGE.SET_TOKEN('CODE',
	                    p_safety_phrase_code,
	                    FALSE);
      FND_MESSAGE.SET_TOKEN('TABLES',
	                    SUBSTR(l_msg_data,1,LENGTH(l_msg_data)-1),
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
/*		  p_safety_phrase_code is the safety phrase code to check.
**		  p_called_by_form is 'T' if called by a form or 'F' if not.
**		  x_rowid is the row id of the record if found.
**		  x_key_exists is 'T' is the record is found, 'F' if not.
*/
		  		 	(p_safety_phrase_code IN VARCHAR2,
					 p_called_by_form IN VARCHAR2,
					 x_rowid OUT NOCOPY VARCHAR2,
					 x_key_exists OUT NOCOPY VARCHAR2)
  IS
/*	Alphanumeric variables	 */

L_MSG_DATA VARCHAR2(80);

/*		Declare any variables and the cursor */


CURSOR c_get_safety_rowid
 IS
   SELECT sp.rowid
   FROM	  gr_safety_phrases_b sp
   WHERE  sp.safety_phrase_code = p_safety_phrase_code;
SafetyRecord			   c_get_safety_rowid%ROWTYPE;

BEGIN

   x_key_exists := 'F';
   OPEN c_get_safety_rowid;
   FETCH c_get_safety_rowid INTO SafetyRecord;
   IF c_get_safety_rowid%FOUND THEN
      x_key_exists := 'T';
	  x_rowid := SafetyRecord.rowid;
   ELSE
      x_key_exists := 'F';
   END IF;
   CLOSE c_get_safety_rowid;

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

END GR_SAFETY_PHRASES_B_PKG;

/
