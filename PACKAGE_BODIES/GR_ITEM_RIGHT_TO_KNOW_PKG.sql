--------------------------------------------------------
--  DDL for Package Body GR_ITEM_RIGHT_TO_KNOW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GR_ITEM_RIGHT_TO_KNOW_PKG" AS
/*$Header: GRHIIRKB.pls 120.1 2006/01/10 11:46:12 methomas noship $*/
PROCEDURE Insert_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_item_code IN VARCHAR2,
				  p_location_segment_qualifier IN VARCHAR2,
				  p_location_segment_value IN VARCHAR2,
				  p_parent_segment_id IN NUMBER,
				  p_min_ingredients_to_print IN NUMBER,
				  p_rtk_reporting_level IN VARCHAR2,
				  p_use_msds_name_flag IN VARCHAR2,
				  p_rtk_name IN VARCHAR2,
				  p_print_cas_number_flag IN VARCHAR2,
				  p_trade_secret_flag IN VARCHAR2,
				  p_trade_secret_name IN VARCHAR2,
				  p_trade_secret_exp_date IN DATE,
				  p_trade_secret_permit IN VARCHAR2,
				  p_state_defined_item_type IN VARCHAR2,
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
L_CURRENT_SEQ	  NUMBER;

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

   Check_Foreign_Keys
			     (p_item_code,
				  p_location_segment_qualifier,
				  p_location_segment_value,
				  p_parent_segment_id,
				  p_min_ingredients_to_print,
				  p_rtk_reporting_level,
				  p_use_msds_name_flag,
				  p_rtk_name,
				  p_print_cas_number_flag,
				  p_trade_secret_flag,
				  p_trade_secret_name,
				  p_trade_secret_exp_date,
				  p_trade_secret_permit,
				  p_state_defined_item_type,
				  l_return_status,
				  l_oracle_error,
				  l_msg_data);
   IF l_return_status <> 'S' THEN
      RAISE Foreign_Key_Error;
   END IF;

/* 	   Now check the primary key doesn't already exist */

   Check_Primary_Key
   	   	   		 (p_item_code,
				  p_location_segment_qualifier,
				  p_location_segment_value,
				  p_parent_segment_id,
				  'F',
				  l_rowid,
				  l_key_exists);

   IF FND_API.To_Boolean(l_key_exists) THEN
   	  RAISE Label_Exists_Error;
   END IF;

   INSERT INTO gr_item_right_to_know
   		  	     (item_code,
				  location_segment_qualifier,
				  location_segment_value,
				  parent_segment_id,
				  min_ingredients_to_print,
				  rtk_reporting_level,
				  use_msds_name_flag,
				  rtk_name,
				  print_cas_number_flag,
				  trade_secret_flag,
				  trade_secret_name,
				  trade_secret_exp_date,
				  trade_secret_permit,
				  state_defined_item_type,
				  created_by,
				  creation_date,
				  last_updated_by,
				  last_update_date,
				  last_update_login)
          VALUES
		         (p_item_code,
				  p_location_segment_qualifier,
				  p_location_segment_value,
				  p_parent_segment_id,
				  p_min_ingredients_to_print,
				  p_rtk_reporting_level,
				  p_use_msds_name_flag,
				  p_rtk_name,
				  p_print_cas_number_flag,
				  p_trade_secret_flag,
				  p_trade_secret_name,
				  p_trade_secret_exp_date,
				  p_trade_secret_permit,
				  p_state_defined_item_type,
				  p_created_by,
				  p_creation_date,
				  p_last_updated_by,
				  p_last_update_date,
				  p_last_update_login);

/*   Now get the row id of the inserted record */

   Check_Primary_Key
   	   	   		 (p_item_code,
				  p_location_segment_qualifier,
				  p_location_segment_value,
				  p_parent_segment_id,
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

   WHEN Label_Exists_Error THEN
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
				  p_item_code IN VARCHAR2,
				  p_location_segment_qualifier IN VARCHAR2,
				  p_location_segment_value IN VARCHAR2,
				  p_parent_segment_id IN NUMBER,
				  p_min_ingredients_to_print IN NUMBER,
				  p_rtk_reporting_level IN VARCHAR2,
				  p_use_msds_name_flag IN VARCHAR2,
				  p_rtk_name IN VARCHAR2,
				  p_print_cas_number_flag IN VARCHAR2,
				  p_trade_secret_flag IN VARCHAR2,
				  p_trade_secret_name IN VARCHAR2,
				  p_trade_secret_exp_date IN DATE,
				  p_trade_secret_permit IN VARCHAR2,
				  p_state_defined_item_type IN VARCHAR2,
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
			     (p_item_code,
				  p_location_segment_qualifier,
				  p_location_segment_value,
				  p_parent_segment_id,
				  p_min_ingredients_to_print,
				  p_rtk_reporting_level,
				  p_use_msds_name_flag,
				  p_rtk_name,
				  p_print_cas_number_flag,
				  p_trade_secret_flag,
				  p_trade_secret_name,
				  p_trade_secret_exp_date,
				  p_trade_secret_permit,
				  p_state_defined_item_type,
				  l_return_status,
				  l_oracle_error,
				  l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Foreign_Key_Error;
   ELSE
      UPDATE gr_item_right_to_know
      SET	 item_code				  	 	 = p_item_code,
			 location_segment_qualifier	     = p_location_segment_qualifier,
			 location_segment_value	  		 = p_location_segment_value,
			 parent_segment_id	  			 = p_parent_segment_id,
			 min_ingredients_to_print	     = p_min_ingredients_to_print,
			 rtk_reporting_level	  		 = p_rtk_reporting_level,
			 use_msds_name_flag	  			 = p_use_msds_name_flag,
			 rtk_name	  					 = p_rtk_name,
			 print_cas_number_flag		  	 = p_print_cas_number_flag,
			 trade_secret_flag	  			 = p_trade_secret_flag,
			 trade_secret_name	  			 = p_trade_secret_name,
			 trade_secret_exp_date	  		 = p_trade_secret_exp_date,
			 trade_secret_permit	  		 = p_trade_secret_permit,
			 state_defined_item_type	  	 = p_state_defined_item_type,
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
				  p_item_code IN VARCHAR2,
				  p_location_segment_qualifier IN VARCHAR2,
				  p_location_segment_value IN VARCHAR2,
				  p_parent_segment_id IN NUMBER,
				  p_min_ingredients_to_print IN NUMBER,
				  p_rtk_reporting_level IN VARCHAR2,
				  p_use_msds_name_flag IN VARCHAR2,
				  p_rtk_name IN VARCHAR2,
				  p_print_cas_number_flag IN VARCHAR2,
				  p_trade_secret_flag IN VARCHAR2,
				  p_trade_secret_name IN VARCHAR2,
				  p_trade_secret_exp_date IN DATE,
				  p_trade_secret_permit IN VARCHAR2,
				  p_state_defined_item_type IN VARCHAR2,
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
   FROM		gr_item_right_to_know
   WHERE	rowid = p_rowid
   FOR UPDATE NOWAIT;
LockItemRTKRcd	  c_lock_item%ROWTYPE;

BEGIN

/*      Initialization Routine */

   SAVEPOINT Lock_Row;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;

/*	   Now lock the record */

   OPEN c_lock_item;
   FETCH c_lock_item INTO LockItemRTKRcd;
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
				  p_item_code IN VARCHAR2,
				  p_location_segment_qualifier IN VARCHAR2,
				  p_location_segment_value IN VARCHAR2,
				  p_parent_segment_id IN NUMBER,
				  p_min_ingredients_to_print IN NUMBER,
				  p_rtk_reporting_level IN VARCHAR2,
				  p_use_msds_name_flag IN VARCHAR2,
				  p_rtk_name IN VARCHAR2,
				  p_print_cas_number_flag IN VARCHAR2,
				  p_trade_secret_flag IN VARCHAR2,
				  p_trade_secret_name IN VARCHAR2,
				  p_trade_secret_exp_date IN DATE,
				  p_trade_secret_permit IN VARCHAR2,
				  p_state_defined_item_type IN VARCHAR2,
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
				  p_item_code,
				  p_location_segment_qualifier,
				  p_location_segment_value,
				  p_parent_segment_id,
				  p_min_ingredients_to_print,
				  p_rtk_reporting_level,
				  p_use_msds_name_flag,
				  p_rtk_name,
				  p_print_cas_number_flag,
				  p_trade_secret_flag,
				  p_trade_secret_name,
				  p_trade_secret_exp_date,
				  p_trade_secret_permit,
				  p_state_defined_item_type,
				  l_return_status,
				  l_oracle_error,
				  l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Check_Integrity_Error;
   END IF;

   DELETE FROM gr_item_right_to_know
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

PROCEDURE Delete_Rows
	             (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
	              p_item_code IN VARCHAR2,
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

   DELETE FROM gr_item_right_to_know
   WHERE 	   item_code = p_item_code;

   IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
   END IF;

EXCEPTION

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
				  p_location_segment_qualifier IN VARCHAR2,
				  p_location_segment_value IN VARCHAR2,
				  p_parent_segment_id IN NUMBER,
				  p_min_ingredients_to_print IN NUMBER,
				  p_rtk_reporting_level IN VARCHAR2,
				  p_use_msds_name_flag IN VARCHAR2,
				  p_rtk_name IN VARCHAR2,
				  p_print_cas_number_flag IN VARCHAR2,
				  p_trade_secret_flag IN VARCHAR2,
				  p_trade_secret_name IN VARCHAR2,
				  p_trade_secret_exp_date IN DATE,
				  p_trade_secret_permit IN VARCHAR2,
				  p_state_defined_item_type IN VARCHAR2,
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
/*	 AR Location Values  */
/* Bug 4177974 Commented the calls to AR_LOCATION related tables */
/*
CURSOR c_get_ar_values
 IS
   SELECT	av.location_segment_id
   FROM		ar_location_values av
   WHERE	location_segment_qualifier = p_location_segment_qualifier
   AND		location_segment_value = p_location_segment_value
   AND		parent_segment_id = p_parent_segment_id;
ARValuesRcd		c_get_ar_values%ROWTYPE;
*/
BEGIN

/*   Initialization Routine */

   SAVEPOINT Check_Foreign_Keys;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;

/* 	 Check the item code */

   l_key_exists := 'T';
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

/*   Check the ar location values */
/* Bug 4177974 Commented the calls to AR_LOCATION related tables */
/*
   OPEN c_get_ar_values;
   FETCH c_get_ar_values INTO ARValuesRcd;
   IF c_get_ar_values%NOTFOUND THEN
      x_return_status := 'E';
      FND_MESSAGE.SET_NAME('GR',
                           'GR_RECORD_NOT_FOUND');
      FND_MESSAGE.SET_TOKEN('CODE',
                            'ar location values',
		      				FALSE);
      l_msg_data := l_msg_data || FND_MESSAGE.Get || ' ';
   END IF;
   CLOSE c_get_ar_values;


   IF x_return_status <> 'S' THEN
      x_msg_data := l_msg_data;
   END IF;
*/
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
	   			  p_item_code IN VARCHAR2,
				  p_location_segment_qualifier IN VARCHAR2,
				  p_location_segment_value IN VARCHAR2,
				  p_parent_segment_id IN NUMBER,
				  p_min_ingredients_to_print IN NUMBER,
				  p_rtk_reporting_level IN VARCHAR2,
				  p_use_msds_name_flag IN VARCHAR2,
				  p_rtk_name IN VARCHAR2,
				  p_print_cas_number_flag IN VARCHAR2,
				  p_trade_secret_flag IN VARCHAR2,
				  p_trade_secret_name IN VARCHAR2,
				  p_trade_secret_exp_date IN DATE,
				  p_trade_secret_permit IN VARCHAR2,
				  p_state_defined_item_type IN VARCHAR2,
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

/*	 Define the Cursors */

BEGIN

/*     Initialization Routine */

   SAVEPOINT Check_Integrity;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;

/*	   No integrity checking required */



/*	 Now sort out the error messaging */

   IF l_return_status <> 'S' THEN
      x_return_status := l_return_status;
	  x_msg_data := l_msg_data;
   END IF;

EXCEPTION

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
					 p_location_segment_qualifier IN VARCHAR2,
					 p_location_segment_value IN VARCHAR2,
					 p_parent_segment_id IN NUMBER,
					 p_called_by_form IN VARCHAR2,
					 x_rowid OUT NOCOPY VARCHAR2,
					 x_key_exists OUT NOCOPY VARCHAR2)
  IS
/*	Alphanumeric variables	 */

L_MSG_DATA VARCHAR2(80);

/*		Declare any variables and the cursor */


CURSOR c_get_item_rtk_rowid
 IS
   SELECT irtk.rowid
   FROM	  gr_item_right_to_know irtk
   WHERE  irtk.item_code = p_item_code
   AND	  irtk.location_segment_qualifier = p_location_segment_qualifier
   AND	  irtk.location_segment_value = p_location_segment_value
   AND	  irtk.parent_segment_id = p_parent_segment_id;
ItemRTKRecord			   c_get_item_rtk_rowid%ROWTYPE;

BEGIN

   x_key_exists := 'F';
   l_msg_data := p_item_code;
   OPEN c_get_item_rtk_rowid;
   FETCH c_get_item_rtk_rowid INTO ItemRTKRecord;
   IF c_get_item_rtk_rowid%FOUND THEN
      x_key_exists := 'T';
	  x_rowid := ItemRTKRecord.rowid;
   ELSE
      x_key_exists := 'F';
   END IF;
   CLOSE c_get_item_rtk_rowid;

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

END GR_ITEM_RIGHT_TO_KNOW_PKG;

/
