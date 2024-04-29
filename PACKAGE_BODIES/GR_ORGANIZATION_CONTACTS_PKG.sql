--------------------------------------------------------
--  DDL for Package Body GR_ORGANIZATION_CONTACTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GR_ORGANIZATION_CONTACTS_PKG" AS
/*$Header: GRHIORCB.pls 115.6 2002/10/28 17:00:20 methomas ship $*/
PROCEDURE Insert_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_orgn_code IN VARCHAR2,
				  p_daytime_contact_name IN VARCHAR2,
				  p_daytime_telephone IN VARCHAR2,
				  p_daytime_extension IN VARCHAR2,
				  p_daytime_area_code IN VARCHAR2,
				  p_evening_contact_name IN VARCHAR2,
				  p_evening_telephone IN VARCHAR2,
				  p_evening_extension IN VARCHAR2,
				  p_evening_area_code IN VARCHAR2,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_date IN DATE,
				  p_last_update_login IN NUMBER,
				  p_daytime_email IN VARCHAR2,
				  p_evening_email IN VARCHAR2,
				  p_daytime_fax_no IN VARCHAR2,
				  p_evening_fax_no IN VARCHAR2,
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
			     (p_orgn_code,
				  p_daytime_contact_name,
				  p_daytime_telephone,
				  p_daytime_extension,
				  p_daytime_area_code,
				  p_evening_contact_name,
				  p_evening_telephone,
				  p_evening_extension,
				  p_evening_area_code,
				  p_daytime_email,
				  p_evening_email,
				  p_daytime_fax_no,
				  p_evening_fax_no,
				  l_return_status,
				  l_oracle_error,
				  l_msg_data);
   IF l_return_status <> 'S' THEN
      RAISE Foreign_Key_Error;
   END IF;

/* 	   Now check the primary key doesn't already exist */

   Check_Primary_Key
   	   	   		 (p_orgn_code,
				  'F',
				  l_rowid,
				  l_key_exists);

   IF FND_API.To_Boolean(l_key_exists) THEN
   	  RAISE Item_Exists_Error;
   END IF;

   INSERT INTO gr_organization_contacts
   		  	     (orgn_code,
				  daytime_contact_name,
				  daytime_telephone,
				  daytime_extension,
				  daytime_area_code,
				  evening_contact_name,
				  evening_telephone,
				  evening_extension,
				  evening_area_code,
				  daytime_email,
				  evening_email,
				  daytime_fax_no,
				  evening_fax_no,
				  created_by,
				  creation_date,
				  last_updated_by,
				  last_update_date,
				  last_update_login)
          VALUES
		         (p_orgn_code,
				  p_daytime_contact_name,
				  p_daytime_telephone,
				  p_daytime_extension,
				  p_daytime_area_code,
				  p_evening_contact_name,
				  p_evening_telephone,
				  p_evening_extension,
				  p_evening_area_code,
				  p_daytime_email,
				  p_evening_email,
				  p_daytime_fax_no,
				  p_evening_fax_no,
				  p_created_by,
				  p_creation_date,
				  p_last_updated_by,
				  p_last_update_date,
				  p_last_update_login);

/*   Now get the row id of the inserted record */

   Check_Primary_Key
   	   	   		 (p_orgn_code,
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
	  l_msg_token := p_orgn_code;
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
	  l_msg_token := p_orgn_code;
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
	  l_msg_token := p_orgn_code;
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
				  p_orgn_code IN VARCHAR2,
				  p_daytime_contact_name IN VARCHAR2,
				  p_daytime_telephone IN VARCHAR2,
				  p_daytime_extension IN VARCHAR2,
				  p_daytime_area_code IN VARCHAR2,
				  p_evening_contact_name IN VARCHAR2,
				  p_evening_telephone IN VARCHAR2,
				  p_evening_extension IN VARCHAR2,
				  p_evening_area_code IN VARCHAR2,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_date IN DATE,
				  p_last_update_login IN NUMBER,
				  p_daytime_email IN VARCHAR2,
				  p_evening_email IN VARCHAR2,
				  p_daytime_fax_no IN VARCHAR2,
				  p_evening_fax_no IN VARCHAR2,
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
   l_msg_token := p_orgn_code;

/*	  Now call the check foreign key procedure */

   Check_Foreign_Keys
			     (p_orgn_code,
				  p_daytime_contact_name,
				  p_daytime_telephone,
				  p_daytime_extension,
				  p_daytime_area_code,
				  p_evening_contact_name,
				  p_evening_telephone,
				  p_evening_extension,
				  p_evening_area_code,
				  p_daytime_email,
				  p_evening_email,
				  p_daytime_fax_no,
				  p_evening_fax_no,
				  l_return_status,
				  l_oracle_error,
				  l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Foreign_Key_Error;
   ELSE
      UPDATE gr_organization_contacts
	  SET	 orgn_code                       = p_orgn_code,
	  		 daytime_contact_name		     = p_daytime_contact_name,
			 daytime_telephone	             = p_daytime_telephone,
			 daytime_extension	             = p_daytime_extension,
			 daytime_area_code               = p_daytime_area_code,
			 evening_contact_name	         = p_evening_contact_name,
			 evening_telephone	             = p_evening_telephone,
			 evening_extension	             = p_evening_extension,
			 evening_area_code	             = p_evening_area_code,
			 created_by						 = p_created_by,
			 creation_date					 = p_creation_date,
			 last_updated_by				 = p_last_updated_by,
			 last_update_date				 = p_last_update_date,
			 last_update_login				 = p_last_update_login,
			 daytime_email					= p_daytime_email,
			 evening_email					= p_evening_email,
			 daytime_fax_no					= p_daytime_fax_no,
			 evening_fax_no					= p_evening_fax_no
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
/*
**
**
**
*/
PROCEDURE Lock_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_rowid IN VARCHAR2,
				  p_orgn_code IN VARCHAR2,
				  p_daytime_contact_name IN VARCHAR2,
				  p_daytime_telephone IN VARCHAR2,
				  p_daytime_extension IN VARCHAR2,
				  p_daytime_area_code IN VARCHAR2,
				  p_evening_contact_name IN VARCHAR2,
				  p_evening_telephone IN VARCHAR2,
				  p_evening_extension IN VARCHAR2,
				  p_evening_area_code IN VARCHAR2,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_date IN DATE,
				  p_last_update_login IN NUMBER,
				  p_daytime_email IN VARCHAR2,
				  p_evening_email IN VARCHAR2,
				  p_daytime_fax_no IN VARCHAR2,
				  p_evening_fax_no IN VARCHAR2,
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

CURSOR c_lock_orgn_contacts
 IS
   SELECT	*
   FROM		gr_organization_contacts
   WHERE	rowid = p_rowid
   FOR UPDATE NOWAIT;
LockContactRcd	  c_lock_orgn_contacts%ROWTYPE;

BEGIN

/*      Initialization Routine */

   SAVEPOINT Lock_Row;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;
   l_msg_token := p_orgn_code;

/*	   Now lock the record */

   OPEN c_lock_orgn_contacts;
   FETCH c_lock_orgn_contacts INTO LockContactRcd;
   IF c_lock_orgn_contacts%NOTFOUND THEN
	  CLOSE c_lock_orgn_contacts;
	  RAISE No_Data_Found_Error;
   END IF;
   CLOSE c_lock_orgn_contacts;

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
				  p_orgn_code IN VARCHAR2,
				  p_daytime_contact_name IN VARCHAR2,
				  p_daytime_telephone IN VARCHAR2,
				  p_daytime_extension IN VARCHAR2,
				  p_daytime_area_code IN VARCHAR2,
				  p_evening_contact_name IN VARCHAR2,
				  p_evening_telephone IN VARCHAR2,
				  p_evening_extension IN VARCHAR2,
				  p_evening_area_code IN VARCHAR2,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_date IN DATE,
				  p_last_update_login IN NUMBER,
				  p_daytime_email IN VARCHAR2,
				  p_evening_email IN VARCHAR2,
				  p_daytime_fax_no IN VARCHAR2,
				  p_evening_fax_no IN VARCHAR2,
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
   l_msg_token := p_orgn_code;

/*  Now call the check integrity procedure */

   Check_Integrity
			     (l_called_by_form,
				  p_orgn_code,
				  p_daytime_contact_name,
				  p_daytime_telephone,
				  p_daytime_extension,
				  p_daytime_area_code,
				  p_evening_contact_name,
				  p_evening_telephone,
				  p_evening_extension,
				  p_evening_area_code,
				  p_daytime_email,
				  p_evening_email,
				  p_daytime_fax_no,
				  p_evening_fax_no,
				  l_return_status,
				  l_oracle_error,
				  l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Check_Integrity_Error;
   END IF;

   DELETE FROM gr_organization_contacts
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
	   			 (p_orgn_code IN VARCHAR2,
				  p_daytime_contact_name IN VARCHAR2,
				  p_daytime_telephone IN VARCHAR2,
				  p_daytime_extension IN VARCHAR2,
				  p_daytime_area_code IN VARCHAR2,
				  p_evening_contact_name IN VARCHAR2,
				  p_evening_telephone IN VARCHAR2,
				  p_evening_extension IN VARCHAR2,
				  p_evening_area_code IN VARCHAR2,
				  p_daytime_email IN VARCHAR2,
				  p_evening_email IN VARCHAR2,
				  p_daytime_fax_no IN VARCHAR2,
				  p_evening_fax_no IN VARCHAR2,
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

/*	Error Definitions */

ROW_MISSING_ERROR	EXCEPTION;

/*   Define the cursors */
CURSOR c_get_orgn_code
 IS
   SELECT	som.orgn_code
   FROM     sy_orgn_mst som
   WHERE    som.orgn_code = p_orgn_code;
LocalOrgnRecord			c_get_orgn_code%ROWTYPE;

BEGIN

/*   Initialization Routine */

   SAVEPOINT Check_Foreign_Keys;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;
   l_msg_token := p_orgn_code;
/*
**   Check the organization code
*/
   IF p_orgn_code IS NOT NULL THEN
      OPEN c_get_orgn_code;
	  FETCH c_get_orgn_code INTO LocalOrgnRecord;
	  IF c_get_orgn_code%NOTFOUND THEN
	     CLOSE c_get_orgn_code;
		 RAISE Row_Missing_Error;
	  END IF;

   	  CLOSE c_get_orgn_code;
   END IF;

EXCEPTION

   WHEN Row_Missing_Error THEN
      ROLLBACK TO SAVEPOINT Delete_Row;
	  x_return_status := 'E';
	  x_oracle_error := APP_EXCEPTION.Get_Code;
      FND_MESSAGE.SET_NAME('GR',
                           'GR_RECORD_NOT_FOUND');
      FND_MESSAGE.SET_TOKEN('CODE',
         		            p_orgn_code,
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
				  p_orgn_code IN VARCHAR2,
				  p_daytime_contact_name IN VARCHAR2,
				  p_daytime_telephone IN VARCHAR2,
				  p_daytime_extension IN VARCHAR2,
				  p_daytime_area_code IN VARCHAR2,
				  p_evening_contact_name IN VARCHAR2,
				  p_evening_telephone IN VARCHAR2,
				  p_evening_extension IN VARCHAR2,
				  p_evening_area_code IN VARCHAR2,
				  p_daytime_email IN VARCHAR2,
				  p_evening_email IN VARCHAR2,
				  p_daytime_fax_no IN VARCHAR2,
				  p_evening_fax_no IN VARCHAR2,
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

/*	 Define the Cursors */

BEGIN

/*     Initialization Routine */

   SAVEPOINT Check_Integrity;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;
   l_record_count := 0;

/*
**	No integrity checking required.
*/

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
/*		  p_orgn_code is the code to check.
**		  p_called_by_form is 'T' if called by a form or 'F' if not.
**		  x_rowid is the row id of the record if found.
**		  x_key_exists is 'T' is the record is found, 'F' if not.
*/
		  		 	(p_orgn_code IN VARCHAR2,
					 p_called_by_form IN VARCHAR2,
					 x_rowid OUT NOCOPY VARCHAR2,
					 x_key_exists OUT NOCOPY VARCHAR2)
  IS
/*	Alphanumeric variables	 */

L_MSG_DATA VARCHAR2(80);

/*		Declare any variables and the cursor */


CURSOR c_get_orgn_contacts_rowid
 IS
   SELECT orc.rowid
   FROM	  gr_organization_contacts orc
   WHERE  orc.orgn_code = p_orgn_code;
ContactRecord			   c_get_orgn_contacts_rowid%ROWTYPE;

BEGIN

   l_msg_data := p_orgn_code;

   x_key_exists := 'F';
   OPEN c_get_orgn_contacts_rowid;
   FETCH c_get_orgn_contacts_rowid INTO ContactRecord;
   IF c_get_orgn_contacts_rowid%FOUND THEN
      x_key_exists := 'T';
	  x_rowid := ContactRecord.rowid;
   ELSE
      x_key_exists := 'F';
   END IF;
   CLOSE c_get_orgn_contacts_rowid;

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

END GR_ORGANIZATION_CONTACTS_PKG;

/
