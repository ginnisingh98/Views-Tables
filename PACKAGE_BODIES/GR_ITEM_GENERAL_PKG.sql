--------------------------------------------------------
--  DDL for Package Body GR_ITEM_GENERAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GR_ITEM_GENERAL_PKG" AS
/*$Header: GRHIIG1B.pls 115.7 2002/10/25 20:48:23 methomas ship $*/
PROCEDURE Insert_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_item_group_code IN VARCHAR2,
				  p_primary_cas_number IN VARCHAR2,
				  p_ingredient_flag IN VARCHAR2,
				  p_explode_ingredient_flag IN VARCHAR2,
				  p_formula_source_indicator IN VARCHAR2,
				  p_user_id IN NUMBER,
				  p_internal_reference_number IN VARCHAR2,
				  p_label_code IN VARCHAR2,
				  p_version_code IN VARCHAR2,
				  p_last_version_code IN VARCHAR2,
				  p_product_class IN VARCHAR2,
				  p_item_code IN VARCHAR2,
				  p_actual_hazard IN NUMBER,
				  p_print_ing_phrases_flag IN VARCHAR2,
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
			     (p_item_group_code,
				  p_primary_cas_number,
				  p_ingredient_flag,
				  p_explode_ingredient_flag,
				  p_formula_source_indicator,
				  p_user_id,
				  p_internal_reference_number,
				  p_label_code,
				  p_version_code,
				  p_last_version_code,
				  p_product_class,
				  p_item_code,
				  p_actual_hazard,
				  p_print_ing_phrases_flag,
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
				  'F',
				  l_rowid,
				  l_key_exists);

   IF FND_API.To_Boolean(l_key_exists) THEN
   	  RAISE Item_Exists_Error;
   END IF;

   INSERT INTO gr_item_general
   		  	     (item_code,
				  item_group_code,
				  primary_cas_number,
				  ingredient_flag,
				  explode_ingredient_flag,
				  formula_source_indicator,
				  user_id,
				  internal_reference_number,
				  product_label_code,
				  version_code,
				  last_version_code,
				  product_class,
				  actual_hazard,
				  print_ingredient_phrases_flag,
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
				  p_item_group_code,
				  p_primary_cas_number,
				  p_ingredient_flag,
				  p_explode_ingredient_flag,
				  p_formula_source_indicator,
				  p_user_id,
				  p_internal_reference_number,
				  p_label_code,
				  p_version_code,
				  p_last_version_code,
				  p_product_class,
				  p_actual_hazard,
				  p_print_ing_phrases_flag,
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
				  p_item_group_code IN VARCHAR2,
				  p_primary_cas_number IN VARCHAR2,
				  p_ingredient_flag IN VARCHAR2,
				  p_explode_ingredient_flag IN VARCHAR2,
				  p_formula_source_indicator IN VARCHAR2,
				  p_user_id IN NUMBER,
				  p_internal_reference_number IN VARCHAR2,
				  p_label_code IN VARCHAR2,
				  p_version_code IN VARCHAR2,
				  p_last_version_code IN VARCHAR2,
				  p_product_class IN VARCHAR2,
				  p_item_code IN VARCHAR2,
				  p_actual_hazard IN NUMBER,
				  p_print_ing_phrases_flag IN VARCHAR2,
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
			     (p_item_group_code,
				  p_primary_cas_number,
				  p_ingredient_flag,
				  p_explode_ingredient_flag,
				  p_formula_source_indicator,
				  p_user_id,
				  p_internal_reference_number,
				  p_label_code,
				  p_version_code,
				  p_last_version_code,
				  p_product_class,
				  p_item_code,
				  p_actual_hazard,
				  p_print_ing_phrases_flag,
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
      UPDATE gr_item_general
	  SET	 item_code 	 	 	 		 	 = p_item_code,
	  		 item_group_code				 = p_item_group_code,
			 primary_cas_number				 = p_primary_cas_number,
			 ingredient_flag				 = p_ingredient_flag,
			 explode_ingredient_flag		 = p_explode_ingredient_flag,
			 formula_source_indicator		 = p_formula_source_indicator,
			 user_id						 = p_user_id,
			 internal_reference_number		 = p_internal_reference_number,
			 product_label_code				 = p_label_code,
			 version_code					 = p_version_code,
			 last_version_code				 = p_last_version_code,
			 product_class					 = p_product_class,
			 actual_hazard					 = p_actual_hazard,
			 print_ingredient_phrases_flag	 = p_print_ing_phrases_flag,
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
				  p_item_group_code IN VARCHAR2,
				  p_primary_cas_number IN VARCHAR2,
				  p_ingredient_flag IN VARCHAR2,
				  p_explode_ingredient_flag IN VARCHAR2,
				  p_formula_source_indicator IN VARCHAR2,
				  p_user_id IN NUMBER,
				  p_internal_reference_number IN VARCHAR2,
				  p_label_code IN VARCHAR2,
				  p_version_code IN VARCHAR2,
				  p_last_version_code IN VARCHAR2,
				  p_product_class IN VARCHAR2,
				  p_item_code IN VARCHAR2,
				  p_actual_hazard IN NUMBER,
				  p_print_ing_phrases_flag IN VARCHAR2,
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
ROW_ALREADY_LOCKED_ERROR 	EXCEPTION;
PRAGMA EXCEPTION_INIT(ROW_ALREADY_LOCKED_ERROR,-54);

/*   Define the cursors */

CURSOR c_lock_item
 IS
   SELECT	*
   FROM		gr_item_general
   WHERE	rowid = p_rowid
   FOR UPDATE NOWAIT;
LockItemRcd	  c_lock_item%ROWTYPE;
BEGIN

/*      Initialization Routine */

   SAVEPOINT Lock_Row;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;

/*	   Now lock the record */

   OPEN c_lock_item;
   FETCH c_lock_item INTO LockItemRcd;
   IF c_lock_item%NOTFOUND THEN
	  CLOSE c_lock_item;
	  RAISE No_Data_Found_Error;
   END IF;
   CLOSE c_lock_item;

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
				  p_item_group_code IN VARCHAR2,
				  p_primary_cas_number IN VARCHAR2,
				  p_ingredient_flag IN VARCHAR2,
				  p_explode_ingredient_flag IN VARCHAR2,
				  p_formula_source_indicator IN VARCHAR2,
				  p_user_id IN NUMBER,
				  p_internal_reference_number IN VARCHAR2,
				  p_label_code IN VARCHAR2,
				  p_version_code IN VARCHAR2,
				  p_last_version_code IN VARCHAR2,
				  p_product_class IN VARCHAR2,
				  p_item_code IN VARCHAR2,
				  p_actual_hazard IN NUMBER,
				  p_print_ing_phrases_flag IN VARCHAR2,
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
			      p_item_group_code,
				  p_primary_cas_number,
				  p_ingredient_flag,
				  p_explode_ingredient_flag,
				  p_formula_source_indicator,
				  p_user_id,
				  p_internal_reference_number,
				  p_label_code,
				  p_version_code,
				  p_last_version_code,
				  p_product_class,
				  p_item_code,
				  p_actual_hazard,
				  p_print_ing_phrases_flag,
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

   DELETE FROM gr_item_general
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
	   			 (p_item_group_code IN VARCHAR2,
				  p_primary_cas_number IN VARCHAR2,
				  p_ingredient_flag IN VARCHAR2,
				  p_explode_ingredient_flag IN VARCHAR2,
				  p_formula_source_indicator IN VARCHAR2,
				  p_user_id IN NUMBER,
				  p_internal_reference_number IN VARCHAR2,
				  p_label_code IN VARCHAR2,
				  p_version_code IN VARCHAR2,
				  p_last_version_code IN VARCHAR2,
				  p_product_class IN VARCHAR2,
				  p_item_code IN VARCHAR2,
				  p_actual_hazard IN NUMBER,
				  p_print_ing_phrases_flag IN VARCHAR2,
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
/*	 Item Group Code */

CURSOR c_get_item_group
 IS
   SELECT	ig.item_group_code
   FROM		gr_item_groups_b ig
   WHERE	ig.item_group_code = p_item_group_code;
ItemGrpRecord		c_get_item_group%ROWTYPE;

/*  Product Class */

CURSOR c_get_prod_class
 IS
   SELECT   pc.product_class
   FROM		gr_product_classes pc
   WHERE	pc.product_class = p_product_class;
ProdClsRecord		c_get_prod_class%ROWTYPE;

/*  User ID */

CURSOR c_get_user_id
 IS
   SELECT	fnu.user_id
   FROM		fnd_user fnu
   WHERE	fnu.user_id = p_user_id;
UserRcd				c_get_user_id%ROWTYPE;

BEGIN

/*   Initialization Routine */

   SAVEPOINT Check_Foreign_Keys;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;

/*   Check the item group code if there is a value */

   IF p_item_group_code IS NOT NULL THEN
      OPEN c_get_item_group;
      FETCH c_get_item_group INTO ItemGrpRecord;
      IF c_get_item_group%NOTFOUND THEN
         CLOSE c_get_item_group;
         x_return_status := 'E';
		 FND_MESSAGE.SET_NAME('GR',
		                      'GR_RECORD_NOT_FOUND');
		 FND_MESSAGE.SET_TOKEN('CODE',
		                       p_item_group_code,
							   FALSE);
	     l_msg_data := l_msg_data || FND_MESSAGE.Get || ' ';
      END IF;
      CLOSE c_get_item_group;
   END IF;

/* 	   Check the product class code */

   IF p_product_class IS NOT NULL THEN
      OPEN c_get_prod_class;
      FETCH c_get_prod_class INTO ProdClsRecord;
      IF c_get_prod_class%NOTFOUND THEN
         CLOSE c_get_prod_class;
         x_return_status := 'E';
		 FND_MESSAGE.SET_NAME('GR',
		                      'GR_RECORD_NOT_FOUND');
		 FND_MESSAGE.SET_TOKEN('CODE',
		                       p_product_class,
							   FALSE);
	     l_msg_data := l_msg_data || FND_MESSAGE.Get || ' ';
      END IF;
      CLOSE c_get_prod_class;
   END IF;

/* 	   Check the user id */

   OPEN c_get_user_id;
   FETCH c_get_user_id INTO UserRcd;
   IF c_get_user_id%NOTFOUND THEN
      CLOSE c_get_user_id;
      x_return_status := 'E';
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_RECORD_NOT_FOUND');
	  FND_MESSAGE.SET_TOKEN('CODE',
	                        p_user_id,
	  					    FALSE);
	  l_msg_data := l_msg_data || FND_MESSAGE.Get || ' ';
   END IF;
   CLOSE c_get_user_id;

/* 	   Check the not null columns */

   IF p_print_ing_phrases_flag IS NULL THEN
      x_return_status := 'E';
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_NULL_VALUE');
	  FND_MESSAGE.SET_TOKEN('CODE',
	                        p_print_ing_phrases_flag,
	  					    FALSE);
	  l_msg_data := l_msg_data || FND_MESSAGE.Get || ' ';
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
	   			  p_item_group_code IN VARCHAR2,
				  p_primary_cas_number IN VARCHAR2,
				  p_ingredient_flag IN VARCHAR2,
				  p_explode_ingredient_flag IN VARCHAR2,
				  p_formula_source_indicator IN VARCHAR2,
				  p_user_id IN NUMBER,
				  p_internal_reference_number IN VARCHAR2,
				  p_label_code IN VARCHAR2,
				  p_version_code IN VARCHAR2,
				  p_last_version_code IN VARCHAR2,
				  p_product_class IN VARCHAR2,
				  p_item_code IN VARCHAR2,
				  p_actual_hazard IN NUMBER,
				  p_print_ing_phrases_flag IN VARCHAR2,
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
L_CODE_BLOCK	  VARCHAR2(2000);

/*   Number Variables */

L_ORACLE_ERROR	  NUMBER;
L_RECORD_COUNT	  NUMBER;

/*   Exceptions  */
INTEGRITY_ERROR 	EXCEPTION;

/*	 Define the Cursors */
/*   Calculations table */

CURSOR c_get_calculated
 IS
   SELECT COUNT(*)
   FROM	  gr_calculated ca
   WHERE  ca.item_code = p_item_code;

/*   Dispatch History */

CURSOR c_get_disp_history
 IS
   SELECT COUNT(*)
   FROM	  gr_dispatch_histories dh
   WHERE  dh.item_code = p_item_code;

/*   Document Print */

CURSOR c_get_doc_print
 IS
   SELECT COUNT(*)
   FROM	  gr_document_print dp
   WHERE  dp.item_code = p_item_code;

/*   European Information */

CURSOR c_get_emea
 IS
   SELECT COUNT(*)
   FROM	  gr_emea em
   WHERE  em.item_code = p_item_code;

/*   Generic Items */

CURSOR c_get_generics
 IS
   SELECT COUNT(*)
   FROM	  gr_generic_items_b gen
   WHERE  gen.item_code = p_item_code;

/*   Generic Names */

CURSOR c_get_generic_names
 IS
   SELECT COUNT(*)
   FROM	  gr_generic_ml_name_tl gmn
   WHERE  gmn.item_code = p_item_code;

/*   Item classifications */

CURSOR c_get_item_classn
 IS
   SELECT COUNT(*)
   FROM	  gr_item_classns ic
   WHERE  ic.item_code = p_item_code;

/*   Item Disclosures */

CURSOR c_get_item_disclosure
 IS
   SELECT COUNT(*)
   FROM	  gr_item_disclosures id
   WHERE  id.item_code = p_item_code;

/*   Item Document Details */

CURSOR c_get_item_doc_dtls
 IS
   SELECT COUNT(*)
   FROM	  gr_item_document_dtls idd
   WHERE  idd.item_code = p_item_code;

/*   Item Document Status */

CURSOR c_get_item_doc_status
 IS
   SELECT COUNT(*)
   FROM	  gr_item_doc_statuses ids
   WHERE  ids.item_code = p_item_code;

/*   Item Exposure */

CURSOR c_get_item_exposure
 IS
   SELECT COUNT(*)
   FROM	  gr_item_exposure ie
   WHERE  ie.item_code = p_item_code;

/*   Item Properties */

CURSOR c_get_item_properties
 IS
   SELECT COUNT(*)
   FROM	  gr_item_properties ip
   WHERE  ip.item_code = p_item_code;

/*   Item Right to Know */

CURSOR c_get_item_rtk
 IS
   SELECT COUNT(*)
   FROM	  gr_item_right_to_know irtk
   WHERE  irtk.item_code = p_item_code;

/*   Item Risk Phrases */

CURSOR c_get_item_risks
 IS
   SELECT COUNT(*)
   FROM	  gr_item_risk_phrases irp
   WHERE  irp.item_code = p_item_code;

/*   Item Safety Phrases */

CURSOR c_get_item_safety
 IS
   SELECT COUNT(*)
   FROM	  gr_item_safety_phrases isp
   WHERE  isp.item_code = p_item_code;

/*   Item Toxic */

CURSOR c_get_item_toxic
 IS
   SELECT COUNT(*)
   FROM	  gr_item_toxic it
   WHERE  it.item_code = p_item_code;

/*   Item Names */

CURSOR c_get_item_names
 IS
   SELECT COUNT(*)
   FROM	  gr_multilingual_name_tl mln
   WHERE  mln.item_code = p_item_code;

/*   Other names (synonyms) */

CURSOR c_get_other_names
 IS
   SELECT COUNT(*)
   FROM	  gr_other_names_tl onm
   WHERE  onm.item_code = p_item_code;

BEGIN

/*     Initialization Routine */

   SAVEPOINT Check_Integrity;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;

/* 	Now read the cursors to make sure the item code isn't used. */
/*  Calculations Table */

   l_record_count := 0;
   l_code_block := 'c_get_calculated';
   OPEN c_get_calculated;
   FETCH c_get_calculated INTO l_record_count;
   IF l_record_count <> 0 THEN
      l_return_status := 'E';
	  l_msg_data := l_msg_data || 'gr_calculated, ';
   END IF;
   CLOSE c_get_calculated;

/* 	 Dispatch History */

   l_record_count := 0;
   l_code_block := 'c_get_disp_history';
   OPEN c_get_disp_history;
   FETCH c_get_disp_history INTO l_record_count;
   IF l_record_count <> 0 THEN
      l_return_status := 'E';
	  l_msg_data := l_msg_data || 'gr_dispatch_histories, ';
   END IF;
   CLOSE c_get_disp_history;

/*    Document Printing */

   l_record_count := 0;
   l_code_block := 'c_get_doc_print';
   OPEN c_get_doc_print;
   FETCH c_get_doc_print INTO l_record_count;
   IF l_record_count <> 0 THEN
      l_return_status := 'E';
	  l_msg_data := l_msg_data || 'gr_document_print, ';
   END IF;
   CLOSE c_get_doc_print;

/*     European Information */

   l_record_count := 0;
   l_code_block := 'c_get_emea';
   OPEN c_get_emea;
   FETCH c_get_emea INTO l_record_count;
   IF l_record_count <> 0 THEN
      l_return_status := 'E';
	  l_msg_data := l_msg_data || 'gr_emea, ';
   END IF;
   CLOSE c_get_emea;

/*	    Generic Items */

   l_record_count := 0;
   l_code_block := 'g_get_generics';
   OPEN c_get_generics;
   FETCH c_get_generics INTO l_record_count;
   IF l_record_count <> 0 THEN
      l_return_status := 'E';
	  l_msg_data := l_msg_data || 'gr_generic_items_b, ';
   END IF;
   CLOSE c_get_generics;

/*    Generic Item Names */

   l_record_count := 0;
   l_code_block := 'c_get_generic_names ';
   OPEN c_get_generic_names;
   FETCH c_get_generic_names INTO l_record_count;
   IF l_record_count <> 0 THEN
      l_return_status := 'E';
	  l_msg_data := l_msg_data || 'gr_generic_ml_name_tl, ';
   END IF;
   CLOSE c_get_generic_names;

/*   Item Classifications */

   l_record_count := 0;
   l_code_block := 'c_get_item_classn';
   OPEN c_get_item_classn;
   FETCH c_get_item_classn INTO l_record_count;
   IF l_record_count <> 0 THEN
      l_return_status := 'E';
	  l_msg_data := l_msg_data || 'gr_item_classns, ';
   END IF;
   CLOSE c_get_item_classn;

/*   Item Disclosures */

   l_record_count := 0;
   l_code_block := 'c_get_item_disclosure';
   OPEN c_get_item_disclosure;
   FETCH c_get_item_disclosure INTO l_record_count;
   IF l_record_count <> 0 THEN
      l_return_status := 'E';
	  l_msg_data := l_msg_data || 'gr_item_disclosures, ';
   END IF;
   CLOSE c_get_item_disclosure;

/*   Item Document Details */

   l_record_count := 0;
   l_code_block := 'c_get_item_doc_dtls';
   OPEN c_get_item_doc_dtls;
   FETCH c_get_item_doc_dtls INTO l_record_count;
   IF l_record_count <> 0 THEN
      l_return_status := 'E';
	  l_msg_data := l_msg_data || 'gr_item_document_dtls, ';
   END IF;
   CLOSE c_get_item_doc_dtls;

/*    Item Document Statuses */

   l_record_count := 0;
   l_code_block := 'c_get_item_doc_status';
   OPEN c_get_item_doc_status;
   FETCH c_get_item_doc_status INTO l_record_count;
   IF l_record_count <> 0 THEN
      l_return_status := 'E';
	  l_msg_data := l_msg_data || 'gr_item_doc_statuses, ';
   END IF;
   CLOSE c_get_item_doc_status;

/*   Item Exposure */

   l_record_count := 0;
   l_code_block := 'c_get_item_exposure';
   OPEN c_get_item_exposure;
   FETCH c_get_item_exposure INTO l_record_count;
   IF l_record_count <> 0 THEN
      l_return_status := 'E';
	  l_msg_data := l_msg_data || 'gr_item_exposure, ';
   END IF;
   CLOSE c_get_item_exposure;

/*   Item Properties */

   l_record_count := 0;
   l_code_block := 'c_get_item_properties';
   OPEN c_get_item_properties;
   FETCH c_get_item_properties INTO l_record_count;
   IF l_record_count <> 0 THEN
      l_return_status := 'E';
	  l_msg_data := l_msg_data || 'gr_item_properties, ';
   END IF;
   CLOSE c_get_item_properties;

/*   Item Right to Know */

   l_record_count := 0;
   l_code_block := 'c_get_item_rtk';
   OPEN c_get_item_rtk;
   FETCH c_get_item_rtk INTO l_record_count;
   IF l_record_count <> 0 THEN
      l_return_status := 'E';
	  l_msg_data := l_msg_data || 'gr_item_right_to_know, ';
   END IF;
   CLOSE c_get_item_rtk;

/*   Item Risk Phrases */

   l_record_count := 0;
   l_code_block := 'c_get_item_risks';
   OPEN c_get_item_risks;
   FETCH c_get_item_risks INTO l_record_count;
   IF l_record_count <> 0 THEN
      l_return_status := 'E';
	  l_msg_data := l_msg_data || 'gr_item_risk_phrases, ';
   END IF;
   CLOSE c_get_item_risks;

/*   Item Safety Phrases */

   l_record_count := 0;
   l_code_block := 'c_get_item_safety';
   OPEN c_get_item_safety;
   FETCH c_get_item_safety INTO l_record_count;
   IF l_record_count <> 0 THEN
      l_return_status := 'E';
	  l_msg_data := l_msg_data || 'gr_item_safety_phrases, ';
   END IF;
   CLOSE c_get_item_safety;

/*	 Item Toxic */

   l_record_count := 0;
   l_code_block := 'c_get_item_toxic';
   OPEN c_get_item_toxic;
   FETCH c_get_item_toxic INTO l_record_count;
   IF l_record_count <> 0 THEN
      l_return_status := 'E';
	  l_msg_data := l_msg_data || 'gr_item_toxic, ';
   END IF;
   CLOSE c_get_item_toxic;

/*  Multi Lingual Names */

   l_record_count := 0;
   l_code_block := 'c_get_item_names';
   OPEN c_get_item_names;
   FETCH c_get_item_names INTO l_record_count;
   IF l_record_count <> 0 THEN
      l_return_status := 'E';
	  l_msg_data := l_msg_data || 'gr_multilingual_name_tl, ';
   END IF;
   CLOSE c_get_item_names;

/*		 Other Names (Synonyms) */

   l_record_count := 0;
   l_code_block := 'c_get_other_names';
   OPEN c_get_other_names;
   FETCH c_get_other_names INTO l_record_count;
   IF l_record_count <> 0 THEN
      l_return_status := 'E';
	  l_msg_data := l_msg_data || 'gr_other_names, ';
   END IF;
   CLOSE c_get_other_names;
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
	                    p_item_code,
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
/*		  p_item_code is the item code to check.
**		  p_called_by_form is 'T' if called by a form or 'F' if not.
**		  x_rowid is the row id of the record if found.
**		  x_key_exists is 'T' is the record is found, 'F' if not.
*/
		  		 	(p_item_code IN VARCHAR2,
					 p_called_by_form IN VARCHAR2,
					 x_rowid OUT NOCOPY VARCHAR2,
					 x_key_exists OUT NOCOPY VARCHAR2)
  IS
/*	Alphanumeric variables	 */

L_MSG_DATA VARCHAR2(80);

/*		Declare any variables and the cursor */


CURSOR c_get_item_rowid
 IS
   SELECT ig.rowid
   FROM	  gr_item_general ig
   WHERE  ig.item_code = p_item_code;
ItemRecord			   c_get_item_rowid%ROWTYPE;

BEGIN

   l_msg_data := p_item_code;
   x_key_exists := 'F';

   OPEN c_get_item_rowid;
   FETCH c_get_item_rowid INTO ItemRecord;
   IF c_get_item_rowid%FOUND THEN
      x_key_exists := 'T';
	  x_rowid := ItemRecord.rowid;
   ELSE
      x_key_exists := 'F';
   END IF;
   CLOSE c_get_item_rowid;

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

END GR_ITEM_GENERAL_PKG;

/
