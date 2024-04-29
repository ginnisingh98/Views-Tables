--------------------------------------------------------
--  DDL for Package Body GR_REGIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GR_REGIONS_PKG" AS
/*$Header: GRHIRGNB.pls 115.5 2002/10/25 17:31:28 gkelly ship $*/
PROCEDURE Insert_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_region_code IN VARCHAR2,
				  p_region_description IN VARCHAR2,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_date IN DATE,
				  p_last_update_login IN NUMBER,
				  x_rowid OUT NOCOPY  VARCHAR2,
				  x_return_status OUT NOCOPY  VARCHAR2,
				  x_oracle_error OUT NOCOPY  NUMBER,
				  x_msg_data OUT NOCOPY  VARCHAR2)
	IS
/*   Alpha Variables */

L_RETURN_STATUS	VARCHAR2(1) := 'S';
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
			     (p_region_code,
			      p_region_description,
				  l_return_status,
				  l_oracle_error,
				  l_msg_data);
   IF l_return_status <> 'S' THEN
      RAISE Foreign_Key_Error;
   END IF;

/* 	   Now check the primary key doesn't already exist */

   Check_Primary_Key
   	   	   		 (p_region_code,
				  'F',
				  l_rowid,
				  l_key_exists);

   IF FND_API.To_Boolean(l_key_exists) THEN
   	  RAISE Item_Exists_Error;
   END IF;

   INSERT INTO gr_regions
   		  	     (region_code,
   		  	      region_description,
				  created_by,
				  creation_date,
				  last_updated_by,
				  last_update_date,
				  last_update_login)
          VALUES
		         (p_region_code,
				  p_region_description,
				  p_created_by,
				  p_creation_date,
				  p_last_updated_by,
				  p_last_update_date,
				  p_last_update_login);

/*   Now get the row id of the inserted record */

   Check_Primary_Key
   	   	   		 (p_region_code,
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
         		            p_region_code,
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
         		            p_region_code,
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
				  p_region_code IN VARCHAR2,
				  p_region_description IN VARCHAR2,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_date IN DATE,
				  p_last_update_login IN NUMBER,
				  x_return_status OUT NOCOPY  VARCHAR2,
				  x_oracle_error OUT NOCOPY  NUMBER,
				  x_msg_data OUT NOCOPY  VARCHAR2)
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
			     (p_region_code,
			      p_region_description,
				  l_return_status,
				  l_oracle_error,
				  l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Foreign_Key_Error;
   ELSE
      UPDATE gr_regions
	  SET	 region_code	 				 = p_region_code,
	         region_description 	 	 	 = p_region_description,
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
         		            p_region_code,
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
				  p_region_code IN VARCHAR2,
				  p_region_description IN VARCHAR2,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_date IN DATE,
				  p_last_update_login IN NUMBER,
				  x_return_status OUT NOCOPY  VARCHAR2,
				  x_oracle_error OUT NOCOPY  NUMBER,
				  x_msg_data OUT NOCOPY  VARCHAR2)
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

CURSOR c_lock_regions
 IS
   SELECT	*
   FROM		gr_regions
   WHERE	rowid = p_rowid
   FOR UPDATE NOWAIT;
LockRegionRcd	  c_lock_regions%ROWTYPE;
BEGIN

/*      Initialization Routine */

   SAVEPOINT Lock_Row;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;

/*	   Now lock the record */

   OPEN c_lock_regions;
   FETCH c_lock_regions INTO LockRegionRcd;
   IF c_lock_regions%NOTFOUND THEN
	  CLOSE c_lock_regions;
	  RAISE No_Data_Found_Error;
   END IF;
   CLOSE c_lock_regions;

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
	                        p_region_code,
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
				  p_region_code IN VARCHAR2,
				  p_region_description IN VARCHAR2,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_date IN DATE,
				  p_last_update_login IN NUMBER,
				  x_return_status OUT NOCOPY  VARCHAR2,
				  x_oracle_error OUT NOCOPY  NUMBER,
				  x_msg_data OUT NOCOPY  VARCHAR2)
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
			      p_region_code,
			      p_region_description,
				  l_return_status,
				  l_oracle_error,
				  l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Check_Integrity_Error;
   END IF;

   DELETE FROM gr_regions
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
         		            p_region_code,
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
	   			 (p_region_code IN VARCHAR2,
	   			  p_region_description IN VARCHAR2,
				  x_return_status OUT NOCOPY  VARCHAR2,
				  x_oracle_error OUT NOCOPY  NUMBER,
				  x_msg_data OUT NOCOPY  VARCHAR2)
   IS

/*   Alpha Variables */

L_RETURN_STATUS	  VARCHAR2(1) := 'S';
L_MSG_DATA		  VARCHAR2(2000);
L_KEY_EXISTS	  VARCHAR2(1);

/*   Number Variables */

L_ORACLE_ERROR	  NUMBER;
L_ROWID			  NUMBER;

/*   Define the cursors */

BEGIN

/*   Initialization Routine */

   SAVEPOINT Check_Foreign_Keys;
   x_return_status := 'S';
   x_oracle_error := 0;
   l_msg_data := NULL;
   x_msg_data := NULL;

/*   No foreign key checking needed. */

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
	   			  p_region_code IN VARCHAR2,
	   			  p_region_description IN VARCHAR2,
				  x_return_status OUT NOCOPY  VARCHAR2,
				  x_oracle_error OUT NOCOPY  NUMBER,
				  x_msg_data OUT NOCOPY  VARCHAR2)
   IS

/*   Alpha Variables */

L_RETURN_STATUS	  VARCHAR2(1) := 'S';
L_MSG_DATA		  VARCHAR2(2000);
L_CODE_BLOCK	  VARCHAR2(100);

/*   Number Variables */

L_ORACLE_ERROR	  NUMBER;
L_RECORD_COUNT	  NUMBER;

/*  Exceptions  */
INTEGRITY_ERROR		EXCEPTION;

/*	 Define the Cursors */
/*   Region Languages Table */

CURSOR c_get_rgn_langs
 IS
   SELECT	COUNT(*)
   FROM		gr_region_languages
   WHERE	region_code = p_region_code;

/*   Recipient Information */

CURSOR c_get_recipient
 IS
   SELECT	COUNT(*)
   FROM		gr_recipient_info
   WHERE	region_code = p_region_code;

BEGIN

/*     Initialization Routine */

   SAVEPOINT Check_Integrity;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;
   l_msg_data := NULL;

/*   Start with the region languages table */

   l_record_count := 0;
   l_code_block := 'c_get_rgn_langs';
   OPEN c_get_rgn_langs;
   FETCH c_get_rgn_langs INTO l_record_count;
   IF l_record_count <> 0 THEN
      l_return_status := 'E';
	  l_msg_data := l_msg_data || 'gr_region_languages, ';
   END IF;
   CLOSE c_get_rgn_langs;

/*   Now do the recipient information */

   l_record_count := 0;
   l_code_block := 'c_get_recipient';
   OPEN c_get_recipient;
   FETCH c_get_recipient INTO l_record_count;
   IF l_record_count <> 0 THEN
      l_return_status := 'E';
	  l_msg_data := l_msg_data || 'gr_recipient_info, ';
   END IF;
   CLOSE c_get_recipient;

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
	                    p_region_code,
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
/*		  p_region_code is the region code to check.
**		  p_called_by_form is 'T' if called by a form or 'F' if not.
**		  x_rowid is the row id of the record if found.
**		  x_key_exists is 'T' is the record is found, 'F' if not.
*/
		  		 	(p_region_code IN VARCHAR2,
					 p_called_by_form IN VARCHAR2,
					 x_rowid OUT NOCOPY  VARCHAR2,
					 x_key_exists OUT NOCOPY  VARCHAR2)
  IS
/*	Alphanumeric variables	 */

L_MSG_DATA VARCHAR2(80);

/*		Declare any variables and the cursor */


CURSOR c_get_region_rowid
 IS
   SELECT rc.rowid
   FROM	  gr_regions rc
   WHERE  rc.region_code = p_region_code;
RegionRecord			   c_get_region_rowid%ROWTYPE;

BEGIN

   x_key_exists := 'F';
   OPEN c_get_region_rowid;
   FETCH c_get_region_rowid INTO RegionRecord;
   IF c_get_region_rowid%FOUND THEN
      x_key_exists := 'T';
	  x_rowid := RegionRecord.rowid;
   ELSE
      x_key_exists := 'F';
   END IF;
   CLOSE c_get_region_rowid;

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

END GR_REGIONS_PKG;

/
