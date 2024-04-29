--------------------------------------------------------
--  DDL for Package Body GR_LABELS_B_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GR_LABELS_B_PKG" AS
/*$Header: GRHILABB.pls 120.0.12010000.2 2009/07/28 14:24:22 plowe ship $*/
PROCEDURE Insert_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_label_code IN VARCHAR2,
				  p_safety_category_code IN VARCHAR2,
				  p_label_class_code IN VARCHAR2,
				  p_data_position_indicator IN VARCHAR2,
				  p_label_properties_flag IN VARCHAR2,
				  p_label_value_required IN NUMBER,
				  p_item_properties_flag IN VARCHAR2,
				  p_ingredient_value_flag IN VARCHAR2,
				  p_inherit_from_label_code IN VARCHAR2,
				  p_print_ingredient_indicator IN VARCHAR2,
				  p_print_font IN VARCHAR2,
				  p_print_size IN NUMBER,
				  p_ingredient_label_code IN VARCHAR2,
				  p_value_procedure IN VARCHAR2,
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
				  p_tech_parm IN VARCHAR2,
				  p_rollup_disclosure_code IN VARCHAR2,
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

FOREIGN_KEY_ERROR 	EXCEPTION;
LABEL_EXISTS_ERROR 	EXCEPTION;
ROW_MISSING_ERROR 	EXCEPTION;

/* Declare cursors */

BEGIN

/*     Initialization Routine */

   SAVEPOINT Insert_Row;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;

/*	  Now call the check foreign key procedure */
/*B1319565 Added for Technical Parameters */
/*B1979042 Added parameter p_rollup_disclosure code*/
   Check_Foreign_Keys
			     (p_label_code,
				  p_safety_category_code,
				  p_label_class_code,
				  p_data_position_indicator,
				  p_label_properties_flag,
				  p_label_value_required,
				  p_item_properties_flag,  -- 7133754 change order of params to fit definition
				  p_ingredient_value_flag,
				  p_inherit_from_label_code,
				  p_print_ingredient_indicator,
				  p_print_font,
				  p_print_size,
				  p_ingredient_label_code,
				  p_value_procedure,
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
				  p_tech_parm,
				  p_rollup_disclosure_code,
				  l_return_status,
				  l_oracle_error,
				  l_msg_data);


   IF l_return_status <> 'S' THEN
      RAISE Foreign_Key_Error;
   END IF;

/* 	   Now check the primary key doesn't already exist */

   Check_Primary_Key
   	   	   		 (p_label_code,
				  'F',
				  l_rowid,
				  l_key_exists);

   IF FND_API.To_Boolean(l_key_exists) THEN
   	  RAISE Label_Exists_Error;
   END IF;
 /*B1319565 Added for Technical Parameters */
 /*B1979042 Added column rollup_disclosure code*/


   INSERT INTO gr_labels_b
   		  	     (label_code,
				  safety_category_code,
				  label_class_code,
				  data_position_indicator,
				  label_properties_flag,
				  label_value_required,
				  item_properties_flag,
				  ingredient_value_flag,
				  inherit_from_label_code,
				  print_ingredient_indicator,
				  print_font,
				  print_size,
				  ingredient_label_code,
				  value_procedure,
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
				  last_update_login,
				  tech_parm,
				  rollup_disclosure_code)
          VALUES
		         (p_label_code,
				  p_safety_category_code,
				  p_label_class_code,
				  p_data_position_indicator,
				  p_label_properties_flag,
				  p_label_value_required,  -- bug fixed  by peter lowe June 18 2008 - order was wrong causing invalid number oracle error on insert
				  p_item_properties_flag,
				  p_ingredient_value_flag,
				  p_inherit_from_label_code,
				  p_print_ingredient_indicator,
				  p_print_font,
				  p_print_size,
				  p_ingredient_label_code,
				  p_value_procedure,
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
				  p_last_update_login,
				  p_tech_parm,
				  p_rollup_disclosure_code);

/*   Now get the row id of the inserted record */

   Check_Primary_Key
   	   	   		 (p_label_code,
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
	  --x_return_status := l_return_status; -- PAL
	   x_return_status := 'F';
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

   WHEN Label_Exists_Error THEN
      ROLLBACK TO SAVEPOINT Insert_Row;
	  x_return_status := 'E';
	  x_oracle_error := APP_EXCEPTION.Get_Code;
      FND_MESSAGE.SET_NAME('GR',
                           'GR_RECORD_EXISTS');
      FND_MESSAGE.SET_TOKEN('CODE',
         		            p_label_code,
            			    FALSE);
      IF FND_API.To_Boolean(p_called_by_form) THEN
         APP_EXCEPTION.Raise_Exception;
	  ELSE
	     x_msg_data := FND_MESSAGE.Get;
      END IF;

   WHEN Row_Missing_Error THEN
      ROLLBACK TO SAVEPOINT Insert_Row;
	  x_return_status := 'P'; -- PAL
	  x_oracle_error := APP_EXCEPTION.Get_Code;
      FND_MESSAGE.SET_NAME('GR',
                           'GR_NO_RECORD_INSERTED');
      FND_MESSAGE.SET_TOKEN('CODE',
         		            p_label_code,
            			    FALSE);
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
				  p_label_code IN VARCHAR2,
				  p_safety_category_code IN VARCHAR2,
				  p_label_class_code IN VARCHAR2,
				  p_data_position_indicator IN VARCHAR2,
				  p_label_properties_flag IN VARCHAR2,
				  p_label_value_required IN NUMBER,
				  p_item_properties_flag IN VARCHAR2,
				  p_ingredient_value_flag IN VARCHAR2,
				  p_inherit_from_label_code IN VARCHAR2,
				  p_print_ingredient_indicator IN VARCHAR2,
				  p_print_font IN VARCHAR2,
				  p_print_size IN NUMBER,
				  p_ingredient_label_code IN VARCHAR2,
				  p_value_procedure IN VARCHAR2,
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
				  p_tech_parm IN VARCHAR2,
				  p_rollup_disclosure_code IN VARCHAR2,
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
/*B1979042 Added parameter p_rollup_disclosure code*/
   Check_Foreign_Keys
			     (p_label_code,
				  p_safety_category_code,
				  p_label_class_code,
				  p_data_position_indicator,
				  p_label_properties_flag,
				  p_label_value_required,
				  p_item_properties_flag,
				  p_ingredient_value_flag,
				  p_inherit_from_label_code,
				  p_print_ingredient_indicator,
				  p_print_font,
				  p_print_size,
				  p_ingredient_label_code,
				  p_value_procedure,
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
				  p_tech_parm,
				  p_rollup_disclosure_code,
				  l_return_status,
				  l_oracle_error,
				  l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Foreign_Key_Error;
   ELSE
   /*B1319565 Added for Technical Parameters */
   /*B1979042 Added column p_rollup_disclosure code*/
      UPDATE gr_labels_b
	  SET	 label_code 	 	 	 		 = p_label_code,
			 safety_category_code			 = p_safety_category_code,
			 label_class_code				 = p_label_class_code,
			 data_position_indicator		 = p_data_position_indicator,
			 label_properties_flag			 = p_label_properties_flag,
			 label_value_required 			 = p_label_value_required,
			 item_properties_flag			 = p_item_properties_flag,
			 ingredient_value_flag			 = p_ingredient_value_flag,
			 inherit_from_label_code		 = p_inherit_from_label_code,
			 print_ingredient_indicator		 = p_print_ingredient_indicator,
			 print_font				 = p_print_font,
			 print_size				 = p_print_size,
			 ingredient_label_code			 = p_ingredient_label_code,
			 value_procedure			 = p_value_procedure,
			 attribute_category			 = p_attribute_category,
			 attribute1				 = p_attribute1,
			 attribute2				 = p_attribute2,
			 attribute3				 = p_attribute3,
			 attribute4				 = p_attribute4,
			 attribute5				 = p_attribute5,
			 attribute6				 = p_attribute6,
			 attribute7				 = p_attribute7,
			 attribute8				 = p_attribute8,
			 attribute9				 = p_attribute9,
			 attribute10				 = p_attribute10,
			 attribute11				 = p_attribute11,
			 attribute12				 = p_attribute12,
			 attribute13				 = p_attribute13,
			 attribute14				 = p_attribute14,
			 attribute15				 = p_attribute15,
			 attribute16				 = p_attribute16,
			 attribute17				 = p_attribute17,
			 attribute18				 = p_attribute18,
			 attribute19				 = p_attribute19,
			 attribute20				 = p_attribute20,
			 attribute21				 = p_attribute21,
			 attribute22				 = p_attribute22,
			 attribute23				 = p_attribute23,
			 attribute24				 = p_attribute24,
			 attribute25				 = p_attribute25,
			 attribute26				 = p_attribute26,
			 attribute27				 = p_attribute27,
			 attribute28				 = p_attribute28,
			 attribute29				 = p_attribute29,
			 attribute30				 = p_attribute30,
			 created_by				 = p_created_by,
			 creation_date				 = p_creation_date,
			 last_updated_by			 = p_last_updated_by,
			 last_update_date			 = p_last_update_date,
			 last_update_login			 = p_last_update_login,
			 tech_parm 				 = p_tech_parm,
			 rollup_disclosure_code 		 = p_rollup_disclosure_code
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
         		            p_label_code,
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

PROCEDURE Lock_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_rowid IN VARCHAR2,
				  p_label_code IN VARCHAR2,
				  p_safety_category_code IN VARCHAR2,
				  p_label_class_code IN VARCHAR2,
				  p_data_position_indicator IN VARCHAR2,
				  p_label_properties_flag IN VARCHAR2,
				  p_label_value_required IN NUMBER,
				  p_item_properties_flag IN VARCHAR2,
				  p_ingredient_value_flag IN VARCHAR2,
				  p_inherit_from_label_code IN VARCHAR2,
				  p_print_ingredient_indicator IN VARCHAR2,
				  p_print_font IN VARCHAR2,
				  p_print_size IN NUMBER,
				  p_ingredient_label_code IN VARCHAR2,
				  p_value_procedure IN VARCHAR2,
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
				  p_tech_parm IN VARCHAR2,
				  p_rollup_disclosure_code IN VARCHAR2,
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

CURSOR c_lock_label
 IS
   SELECT	*
   FROM		gr_labels_b
   WHERE	rowid = p_rowid
   FOR UPDATE NOWAIT;
LockLabelRcd	  c_lock_label%ROWTYPE;

BEGIN

/*      Initialization Routine */

   SAVEPOINT Lock_Row;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;

/*	   Now lock the record */

   OPEN c_lock_label;
   FETCH c_lock_label INTO LockLabelRcd;
   IF c_lock_label%NOTFOUND THEN
	  CLOSE c_lock_label;
	  RAISE No_Data_Found_Error;
   END IF;
   CLOSE c_lock_label;

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
	                        p_label_code,
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
				  p_label_code IN VARCHAR2,
				  p_safety_category_code IN VARCHAR2,
				  p_label_class_code IN VARCHAR2,
				  p_data_position_indicator IN VARCHAR2,
				  p_label_properties_flag IN VARCHAR2,
				  p_label_value_required IN NUMBER,
				  p_item_properties_flag IN VARCHAR2,
				  p_ingredient_value_flag IN VARCHAR2,
				  p_inherit_from_label_code IN VARCHAR2,
				  p_print_ingredient_indicator IN VARCHAR2,
				  p_print_font IN VARCHAR2,
				  p_print_size IN NUMBER,
				  p_ingredient_label_code IN VARCHAR2,
				  p_value_procedure IN VARCHAR2,
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
				  p_tech_parm IN VARCHAR2,
				  p_rollup_disclosure_code IN VARCHAR2,
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
/*B1319565 Added for Technical Parameters */
/*B1979042 Added parameter p_rollup_disclosure code*/
   Check_Integrity
			     (l_called_by_form,
			      p_label_code,
				  p_safety_category_code,
				  p_label_class_code,
				  p_data_position_indicator,
				  p_label_properties_flag,
				  p_label_value_required,
				  p_item_properties_flag,
				  p_ingredient_value_flag,
				  p_inherit_from_label_code,
				  p_print_ingredient_indicator,
				  p_print_font,
				  p_print_size,
				  p_ingredient_label_code,
				  p_value_procedure,
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
				  p_tech_parm,
				  p_rollup_disclosure_code,
				  l_return_status,
				  l_oracle_error,
				  l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Check_Integrity_Error;
   END IF;

   DELETE FROM gr_labels_b
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
         		            p_label_code,
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

PROCEDURE Check_Foreign_Keys
	   			 (p_label_code IN VARCHAR2,
				  p_safety_category_code IN VARCHAR2,
				  p_label_class_code IN VARCHAR2,
				  p_data_position_indicator IN VARCHAR2,
				  p_label_properties_flag IN VARCHAR2,
				  p_label_value_required IN NUMBER,
				  p_item_properties_flag IN VARCHAR2,
				  p_ingredient_value_flag IN VARCHAR2,
				  p_inherit_from_label_code IN VARCHAR2,
				  p_print_ingredient_indicator IN VARCHAR2,
				  p_print_font IN VARCHAR2,
				  p_print_size IN NUMBER,
				  p_ingredient_label_code IN VARCHAR2,
				  p_value_procedure IN VARCHAR2,
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
				  p_tech_parm IN VARCHAR2,
				  p_rollup_disclosure_code IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2)
   IS

/*   Alpha Variables */

L_RETURN_STATUS	  VARCHAR2(1) := 'S';
L_MSG_DATA		  VARCHAR2(2000);
L_ROWID			  VARCHAR2(18);
L_KEY_EXISTS	  VARCHAR2(1);

/*   Number Variables */

L_ORACLE_ERROR	  NUMBER;

/*   Define the cursors */
/*	 Safety Categories  */

CURSOR c_get_safety_category
 IS
   SELECT	sc.safety_category_code
   FROM		gr_safety_categories_b sc
   WHERE	sc.safety_category_code = p_safety_category_code;
SafetyCatRcd		c_get_safety_category%ROWTYPE;

/*	 Label Class Codes */

CURSOR c_get_label_class
 IS
   SELECT	lcb.label_class_code
   FROM		gr_label_classes_b lcb
   WHERE	lcb.label_class_code = p_label_class_code;
LabelClsRcd			c_get_label_class%ROWTYPE;

BEGIN

/*   Initialization Routine */

   SAVEPOINT Check_Foreign_Keys;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;

/*   Check the safety category code */

   OPEN c_get_safety_category;
   FETCH c_get_safety_category INTO SafetyCatRcd;
   IF c_get_safety_category%NOTFOUND THEN
      x_return_status := 'E';
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_RECORD_NOT_FOUND');
	  FND_MESSAGE.SET_TOKEN('CODE',
	                        p_safety_category_code,
							FALSE);
	  l_msg_data := l_msg_data || FND_MESSAGE.Get || ' ';
   END IF;
   CLOSE c_get_safety_category;

/*   Check the label class code */

   OPEN c_get_label_class;
   FETCH c_get_label_class INTO LabelClsRcd;
   IF c_get_label_class%NOTFOUND THEN
      x_return_status := 'E';
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_RECORD_NOT_FOUND');
	  FND_MESSAGE.SET_TOKEN('CODE',
	                        p_label_class_code,
							FALSE);
	  l_msg_data := l_msg_data || FND_MESSAGE.Get || ' ';
   END IF;
   CLOSE c_get_label_class;

/*	Check the ingredient label code if entered */

   IF p_ingredient_label_code IS NOT NULL THEN
      Check_Primary_Key
					(p_ingredient_label_code,
					 'F',
					 l_rowid,
					 l_key_exists);
	  IF NOT FND_API.To_Boolean(l_key_exists) THEN
	     x_return_status := 'E';
	     FND_MESSAGE.SET_NAME('GR',
	                          'GR_RECORD_NOT_FOUND');
	     FND_MESSAGE.SET_TOKEN('CODE',
	                           p_ingredient_label_code,
			    			   FALSE);
	     l_msg_data := l_msg_data || FND_MESSAGE.Get || ' ';
	  END IF;
   END IF;

/*	Check the inherit from label code if entered */

   IF p_inherit_from_label_code IS NOT NULL THEN
      Check_Primary_Key
					(p_inherit_from_label_code,
					 'F',
					 l_rowid,
					 l_key_exists);
	  IF NOT FND_API.To_Boolean(l_key_exists) THEN
	     x_return_status := 'E';
	     FND_MESSAGE.SET_NAME('GR',
	                          'GR_RECORD_NOT_FOUND');
	     FND_MESSAGE.SET_TOKEN('CODE',
	                           p_inherit_from_label_code,
							   FALSE);
	     l_msg_data := l_msg_data || FND_MESSAGE.Get || ' ';
	  END IF;
   END IF;

/* 	   Check the not null columns */

   IF p_data_position_indicator IS NULL THEN
      x_return_status := 'E';
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_NULL_VALUE');
	  FND_MESSAGE.SET_TOKEN('CODE',
	                        'Data Position Indicator',
							FALSE);
	  l_msg_data := l_msg_data || FND_MESSAGE.Get;
   END IF;

   IF p_label_properties_flag IS NULL THEN
      x_return_status := 'E';
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_NULL_VALUE');
	  FND_MESSAGE.SET_TOKEN('CODE',
	                        'Label Properties Flag',
							FALSE);
	  l_msg_data := l_msg_data || FND_MESSAGE.Get;
   END IF;

   IF p_item_properties_flag IS NULL THEN
      x_return_status := 'E';
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_NULL_VALUE');
	  FND_MESSAGE.SET_TOKEN('CODE',
	                        'Item Properties Flag',
							FALSE);
	  l_msg_data := l_msg_data || FND_MESSAGE.Get;
   END IF;

   IF p_ingredient_value_flag IS NULL THEN
      x_return_status := 'E';
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_NULL_VALUE');
	  FND_MESSAGE.SET_TOKEN('CODE',
	                        'Ingredient Value Flag',
							FALSE);
	  l_msg_data := l_msg_data || FND_MESSAGE.Get;
   END IF;

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
	   			  p_label_code IN VARCHAR2,
				  p_safety_category_code IN VARCHAR2,
				  p_label_class_code IN VARCHAR2,
				  p_data_position_indicator IN VARCHAR2,
				  p_label_properties_flag IN VARCHAR2,
				  p_label_value_required IN NUMBER,
				  p_item_properties_flag IN VARCHAR2,
				  p_ingredient_value_flag IN VARCHAR2,
				  p_inherit_from_label_code IN VARCHAR2,
				  p_print_ingredient_indicator IN VARCHAR2,
				  p_print_font IN VARCHAR2,
				  p_print_size IN NUMBER,
				  p_ingredient_label_code IN VARCHAR2,
				  p_value_procedure IN VARCHAR2,
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
				  p_tech_parm IN VARCHAR2,
				  p_rollup_disclosure_code IN VARCHAR2,
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

/* Exceptions */
INTEGRITY_ERROR   EXCEPTION;

/*	 Define the Cursors */
/*   Audit table */

CURSOR c_get_audit
 IS
   SELECT COUNT(*)
   FROM	  gr_audit au
   WHERE  au.label_phrase_code = p_label_code;

/*   Country Profiles */

CURSOR c_get_cntry_profiles
 IS
   SELECT COUNT(*)
   FROM	  gr_country_profiles cp
   WHERE  cp.label_code_toxic = p_label_code
   OR     cp.label_code_exposure = p_label_code;

/* 	Document Structures */

CURSOR c_get_doc_structure
 IS
   SELECT COUNT(*)
   FROM	  gr_document_structures ds
   WHERE  ds.label_code = p_label_code;

/*   Generic Names */

CURSOR c_get_generic_names
 IS
   SELECT COUNT(*)
   FROM	  gr_generic_ml_name_tl gmn
   WHERE  gmn.label_code = p_label_code;

CURSOR c_get_item_exposure
 IS
   SELECT COUNT(*)
   FROM	  gr_item_exposure ie
   WHERE  ie.label_code = p_label_code;

/*   Item Properties */

CURSOR c_get_item_properties
 IS
   SELECT COUNT(*)
   FROM	  gr_item_properties ip
   WHERE  ip.label_code = p_label_code;

/*   Item Toxic */

CURSOR c_get_item_toxic
 IS
   SELECT COUNT(*)
   FROM	  gr_item_toxic it
   WHERE  it.label_code = p_label_code;

/*   Item Names */

CURSOR c_get_item_names
 IS
   SELECT COUNT(*)
   FROM	  gr_multilingual_name_tl mln
   WHERE  mln.label_code = p_label_code;

BEGIN

/*     Initialization Routine */

   SAVEPOINT Check_Integrity;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;

   FND_MESSAGE.SET_NAME('GR',
                        'GR_INTEGRITY_HEADER');
   FND_MESSAGE.SET_TOKEN('CODE',
                         p_label_code,
						 FALSE);
   l_msg_data := FND_MESSAGE.Get;

/* 	Now read the cursors to make sure the item code isn't used. */
/*  Audit Table */

   l_record_count := 0;
   l_code_block := 'c_get_audit';
   OPEN c_get_audit;
   FETCH c_get_audit INTO l_record_count;
   IF l_record_count <> 0 THEN
      l_return_status := 'E';
	  l_msg_data := l_msg_data || 'gr_audit, ';
   END IF;
   CLOSE c_get_audit;

/* 	 Country Profiles */

   l_record_count := 0;
   l_code_block := 'c_get_cntry_profiles';
   OPEN c_get_cntry_profiles;
   FETCH c_get_cntry_profiles INTO l_record_count;
   IF l_record_count <> 0 THEN
      l_return_status := 'E';
	  l_msg_data := l_msg_data || 'gr_country_profiles, ';
   END IF;
   CLOSE c_get_cntry_profiles;

/*    Document Structures */

   l_record_count := 0;
   l_code_block := 'c_get_doc_structure';
   OPEN c_get_doc_structure;
   FETCH c_get_doc_structure INTO l_record_count;
   IF l_record_count <> 0 THEN
      l_return_status := 'E';
	  l_msg_data := l_msg_data || 'gr_document_structures, ';
   END IF;
   CLOSE c_get_doc_structure;

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

/*	 Now sort out the error messaging */

   IF l_return_status <> 'S' THEN
      x_return_status := l_return_status;
      x_msg_data := l_msg_data;
      RAISE INTEGRITY_ERROR;
   END IF;

EXCEPTION
   WHEN INTEGRITY_ERROR THEN
      x_return_status := 'E';
      FND_MESSAGE.SET_NAME('GR',
                           'GR_INTEGRITY_HEADER');
      FND_MESSAGE.SET_TOKEN('CODE',
	                    p_label_code,
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
/*		  p_label_code is the label code to check.
**		  p_called_by_form is 'T' if called by a form or 'F' if not.
**		  x_rowid is the row id of the record if found.
**		  x_key_exists is 'T' is the record is found, 'F' if not.
*/
		  		 	(p_label_code IN VARCHAR2,
					 p_called_by_form IN VARCHAR2,
					 x_rowid OUT NOCOPY VARCHAR2,
					 x_key_exists OUT NOCOPY VARCHAR2)
  IS
/*	Alphanumeric variables	 */

L_MSG_DATA VARCHAR2(80);

/*		Declare any variables and the cursor */


CURSOR c_get_label_rowid
 IS
   SELECT lab.rowid
   FROM	  gr_labels_b lab
   WHERE  lab.label_code = p_label_code;
LabelRecord			   c_get_label_rowid%ROWTYPE;

BEGIN

   x_key_exists := 'F';
   l_msg_data := p_label_code;
   OPEN c_get_label_rowid;
   FETCH c_get_label_rowid INTO LabelRecord;
   IF c_get_label_rowid%FOUND THEN
      x_key_exists := 'T';
      x_rowid := LabelRecord.rowid;
   ELSE
      x_key_exists := 'F';
   END IF;
   CLOSE c_get_label_rowid;

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

END GR_LABELS_B_PKG;

/
