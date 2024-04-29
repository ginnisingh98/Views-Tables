--------------------------------------------------------
--  DDL for Package Body GR_ITEM_DISCLOSURES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GR_ITEM_DISCLOSURES_PKG" AS
/*$Header: GRHIIDB.pls 115.6 2002/10/25 20:17:06 methomas ship $*/
PROCEDURE Insert_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_item_code IN VARCHAR2,
				  p_disclosure_code IN VARCHAR2,
				  p_print_on_document_flag IN VARCHAR2,
				  p_minimum_reporting_level IN NUMBER,
				  p_text_reporting_level IN NUMBER,
				  p_label_reporting_level IN NUMBER,
				  p_exposure_reporting_level IN NUMBER,
				  p_toxicity_reporting_level IN NUMBER,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_update_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_login IN NUMBER,
				  x_rowid OUT NOCOPY VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2)
	IS
/*   Alpha Variables */

L_RETURN_STATUS	VARCHAR2(1) := 'S';
L_KEY_EXISTS 	VARCHAR2(1);
L_MSG_DATA 		VARCHAR2(2000);
L_ROWID 		VARCHAR2(18);
L_MSG_TOKEN 	VARCHAR2(80);

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
   l_msg_token := p_item_code || ' ' || p_disclosure_code;


/*	  Now call the check foreign key procedure */

   Check_Foreign_Keys
				 (p_item_code,
				  p_disclosure_code,
				  p_print_on_document_flag,
				  p_minimum_reporting_level,
				  p_text_reporting_level,
				  p_label_reporting_level,
				  p_exposure_reporting_level,
				  p_toxicity_reporting_level,
				  p_created_by,
				  p_creation_date,
				  p_last_update_date,
				  p_last_updated_by,
				  p_last_update_login,
				  l_return_status,
				  l_oracle_error,
				  l_msg_data);
   IF l_return_status <> 'S' THEN
      RAISE Foreign_Key_Error;
   END IF;

/* 	   Now check the primary key doesn't already exist */

   Check_Primary_Key
   	   	   		 (p_item_code,
				  p_disclosure_code,
				  'F',
				  l_rowid,
				  l_key_exists);

   IF FND_API.To_Boolean(l_key_exists) THEN
   	  RAISE Item_Exists_Error;
   END IF;

   INSERT INTO gr_item_disclosures
   		  	     (item_code,
				  disclosure_code,
				  print_on_document_flag,
				  minimum_reporting_level,
				  text_reporting_level,
				  label_reporting_level,
				  exposure_reporting_level,
				  toxicity_reporting_level,
				  created_by,
				  creation_date,
				  last_update_date,
				  last_updated_by,
				  last_update_login)
          VALUES
		         (p_item_code,
				  p_disclosure_code,
				  p_print_on_document_flag,
				  p_minimum_reporting_level,
				  p_text_reporting_level,
				  p_label_reporting_level,
				  p_exposure_reporting_level,
				  p_toxicity_reporting_level,
				  p_created_by,
				  p_creation_date,
				  p_last_update_date,
				  p_last_updated_by,
				  p_last_update_login);

/*   Now get the row id of the inserted record */

   Check_Primary_Key
   	   	   		 (p_item_code,
				  p_disclosure_code,
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
         		            l_msg_token,
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
         		            l_msg_token,
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
				  p_disclosure_code IN VARCHAR2,
				  p_print_on_document_flag IN VARCHAR2,
				  p_minimum_reporting_level IN NUMBER,
				  p_text_reporting_level IN NUMBER,
				  p_label_reporting_level IN NUMBER,
				  p_exposure_reporting_level IN NUMBER,
				  p_toxicity_reporting_level IN NUMBER,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_update_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_login IN NUMBER,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2)
   IS

/*   Alpha Variables */

L_RETURN_STATUS	  VARCHAR2(1) := 'S';
L_MSG_DATA		  VARCHAR2(2000);
L_MSG_TOKEN		  VARCHAR2(80);

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
   l_msg_token := p_item_code || ' ' || p_disclosure_code;

/*	  Now call the check foreign key procedure */

   Check_Foreign_Keys
				 (p_item_code,
				  p_disclosure_code,
				  p_print_on_document_flag,
				  p_minimum_reporting_level,
				  p_text_reporting_level,
				  p_label_reporting_level,
				  p_exposure_reporting_level,
				  p_toxicity_reporting_level,
				  p_created_by,
				  p_creation_date,
				  p_last_update_date,
				  p_last_updated_by,
				  p_last_update_login,
				  l_return_status,
				  l_oracle_error,
				  l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Foreign_Key_Error;
   ELSE
      UPDATE gr_item_disclosures
	  SET	 item_code		 	 	 		 = p_item_code,
			 disclosure_code		  		 = p_disclosure_code,
			 print_on_document_flag			 = p_print_on_document_flag,
			 minimum_reporting_level	  	 = p_minimum_reporting_level,
			 text_reporting_level		  	 = p_text_reporting_level,
			 label_reporting_level	  		 = p_label_reporting_level,
			 exposure_reporting_level	  	 = p_exposure_reporting_level,
			 toxicity_reporting_level	  	 = p_toxicity_reporting_level,
			 created_by	  					 = p_created_by,
			 creation_date	  				 = p_creation_date,
			 last_update_date	  			 = p_last_update_date,
			 last_updated_by	  			 = p_last_updated_by,
			 last_update_login	  			 = p_last_update_login
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

PROCEDURE Lock_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_rowid IN VARCHAR2,
				  p_item_code IN VARCHAR2,
				  p_disclosure_code IN VARCHAR2,
				  p_print_on_document_flag IN VARCHAR2,
				  p_minimum_reporting_level IN NUMBER,
				  p_text_reporting_level IN NUMBER,
				  p_label_reporting_level IN NUMBER,
				  p_exposure_reporting_level IN NUMBER,
				  p_toxicity_reporting_level IN NUMBER,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_update_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_login IN NUMBER,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2)
   IS

/*  Alpha Variables */

L_RETURN_STATUS	  VARCHAR2(1) := 'S';
L_MSG_DATA		  VARCHAR2(2000);
L_MSG_TOKEN		  VARCHAR2(80);

/*  Number Variables */

L_ORACLE_ERROR	  NUMBER;

/*   Exceptions */

NO_DATA_FOUND_ERROR 		EXCEPTION;
ROW_ALREADY_LOCKED_ERROR 	EXCEPTION;
PRAGMA EXCEPTION_INIT(ROW_ALREADY_LOCKED_ERROR,-54);

/*   Define the cursors */

CURSOR c_lock_discs
 IS
   SELECT	*
   FROM		gr_item_disclosures
   WHERE	rowid = p_rowid
   FOR UPDATE NOWAIT;
LockDiscRcd	  c_lock_discs%ROWTYPE;
BEGIN

/*      Initialization Routine */

   SAVEPOINT Lock_Row;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;
   l_msg_token := p_item_code || ' ' || p_disclosure_code;

/*	   Now lock the record */

   OPEN c_lock_discs;
   FETCH c_lock_discs INTO LockDiscRcd;
   IF c_lock_discs%NOTFOUND THEN
	  CLOSE c_lock_discs;
	  RAISE No_Data_Found_Error;
   END IF;
   CLOSE c_lock_discs;

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
				  p_disclosure_code IN VARCHAR2,
				  p_print_on_document_flag IN VARCHAR2,
				  p_minimum_reporting_level IN NUMBER,
				  p_text_reporting_level IN NUMBER,
				  p_label_reporting_level IN NUMBER,
				  p_exposure_reporting_level IN NUMBER,
				  p_toxicity_reporting_level IN NUMBER,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_update_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_login IN NUMBER,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2)
   IS

/*   Alpha Variables */

L_RETURN_STATUS	  VARCHAR2(1) := 'S';
L_MSG_DATA		  VARCHAR2(2000);
L_MSG_TOKEN		  VARCHAR2(80);
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
   l_msg_token := p_item_code || ' ' || p_disclosure_code;

/*  Now call the check integrity procedure */

   Check_Integrity
			     (p_called_by_form,
			      p_item_code,
				  p_disclosure_code,
				  p_print_on_document_flag,
				  p_minimum_reporting_level,
				  p_text_reporting_level,
				  p_label_reporting_level,
				  p_exposure_reporting_level,
				  p_toxicity_reporting_level,
				  p_created_by,
				  p_creation_date,
				  p_last_update_date,
				  p_last_updated_by,
				  p_last_update_login,
				  l_return_status,
				  l_oracle_error,
				  l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Check_Integrity_Error;
   END IF;

   DELETE FROM gr_item_disclosures
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
	  x_msg_data := l_msg_data;
      IF FND_API.To_Boolean(p_called_by_form) THEN
	     APP_EXCEPTION.Raise_Exception;
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
	              p_item_code IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2)
  IS

/*   Alpha Variables */

L_RETURN_STATUS	  VARCHAR2(1) := 'S';
L_MSG_DATA		  VARCHAR2(2000);
L_MSG_TOKEN       VARCHAR2(80);

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

   DELETE FROM gr_item_disclosures
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
				  p_disclosure_code IN VARCHAR2,
				  p_print_on_document_flag IN VARCHAR2,
				  p_minimum_reporting_level IN NUMBER,
				  p_text_reporting_level IN NUMBER,
				  p_label_reporting_level IN NUMBER,
				  p_exposure_reporting_level IN NUMBER,
				  p_toxicity_reporting_level IN NUMBER,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_update_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_login IN NUMBER,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2)
   IS

/*   Alpha Variables */

L_RETURN_STATUS	  VARCHAR2(1) := 'S';
L_MSG_DATA		  VARCHAR2(2000);
L_MSG_TOKEN       VARCHAR2(80);
L_ROWID			  VARCHAR2(18);
L_KEY_EXISTS	  VARCHAR2(1);

/*   Number Variables */

L_ORACLE_ERROR	  NUMBER;

/*   Define the cursors */

CURSOR c_get_disc_code
 IS
   SELECT	dc.disclosure_code
   FROM		gr_disclosures dc
   WHERE	dc.disclosure_code = p_disclosure_code;
DiscRecord			c_get_disc_code%ROWTYPE;

BEGIN

/*   Initialization Routine */

   SAVEPOINT Check_Foreign_Keys;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;
   l_msg_token := p_item_code || ' ' || p_disclosure_code;

/*   Item General */

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
	  l_msg_data := FND_MESSAGE.Get;
   END IF;

/*   Disclosure Code */

   OPEN c_get_disc_code;
   FETCH c_get_disc_code INTO DiscRecord;
   IF c_get_disc_code%NOTFOUND THEN
      x_return_status := 'E';
	  FND_MESSAGE.SET_NAME('GR',
	   					   'GR_RECORD_NOT_FOUND');
	  FND_MESSAGE.SET_TOKEN('CODE',
						    p_disclosure_code,
						    FALSE);
	  l_msg_data := l_msg_data || ' ' || FND_MESSAGE.Get;
   END IF;
   CLOSE c_get_disc_code;

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
	                        l_msg_token,
	                        FALSE);
	  x_msg_data := FND_MESSAGE.Get;

END Check_Foreign_Keys;

PROCEDURE Check_Integrity
	   			 (p_called_by_form IN VARCHAR2,
	   			  p_item_code IN VARCHAR2,
				  p_disclosure_code IN VARCHAR2,
				  p_print_on_document_flag IN VARCHAR2,
				  p_minimum_reporting_level IN NUMBER,
				  p_text_reporting_level IN NUMBER,
				  p_label_reporting_level IN NUMBER,
				  p_exposure_reporting_level IN NUMBER,
				  p_toxicity_reporting_level IN NUMBER,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_update_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_login IN NUMBER,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2)
   IS

/*   Alpha Variables */

L_RETURN_STATUS	  VARCHAR2(1) := 'S';
L_MSG_DATA		  VARCHAR2(2000);
L_CODE_BLOCK	  VARCHAR2(30);

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

/* No integrity checking is needed */


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
**	      p_disclosure_code is the second part of the key
**		  p_called_by_form is 'T' if called by a form or 'F' if not.
**		  x_rowid is the row id of the record if found.
**		  x_key_exists is 'T' is the record is found, 'F' if not.
*/
		  		 	(p_item_code IN VARCHAR2,
					 p_disclosure_code IN VARCHAR2,
					 p_called_by_form IN VARCHAR2,
					 x_rowid OUT NOCOPY VARCHAR2,
					 x_key_exists OUT NOCOPY VARCHAR2)
  IS
/*	Alphanumeric variables	 */

L_MSG_DATA VARCHAR2(80);

/*		Declare any variables and the cursor */


CURSOR c_get_disclosure_rowid
 IS
   SELECT dc.rowid
   FROM	  gr_item_disclosures dc
   WHERE  dc.item_code = p_item_code
   AND	  dc.disclosure_code = p_disclosure_code;
DisclosureRecord		c_get_disclosure_rowid%ROWTYPE;

BEGIN

   l_msg_data := p_item_code || ' ' || p_disclosure_code;

   x_key_exists := 'F';
   OPEN c_get_disclosure_rowid;
   FETCH c_get_disclosure_rowid INTO DisclosureRecord;
   IF c_get_disclosure_rowid%FOUND THEN
      x_key_exists := 'T';
	  x_rowid := DisclosureRecord.rowid;
   ELSE
      x_key_exists := 'F';
   END IF;
   CLOSE c_get_disclosure_rowid;

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

END GR_ITEM_DISCLOSURES_PKG;

/
