--------------------------------------------------------
--  DDL for Package Body GR_FIELD_NAME_MASKS_B_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GR_FIELD_NAME_MASKS_B_PKG" AS
/*$Header: GRHIFMBB.pls 115.4 2002/10/29 19:26:13 mgrosser noship $*/


/* =====================================================================
 PROOCEDURE:
   Insert_Row

 DESCRIPTION:
   This PL/SQL procedure is used to insert data into the table
   GR_FIELD_NAME_MASKS_B

 PARAMETERS:
   p_commit            IN   VARCHAR2,
   p_called_by_form    IN   VARCHAR2,
   p_item_code         IN   VARCHAR2,
   p_disclosure_code   IN   VARCHAR2,
   p_label_code        IN   VARCHAR2,
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
L_KEY_EXISTS    VARCHAR2(1);
L_MSG_DATA      VARCHAR2(2000);
L_MSG_TOKEN     VARCHAR2(100);
L_ROWID         VARCHAR2(18);

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

   Check_Foreign_Keys
			     (p_item_code,
				  p_disclosure_code,
				  p_label_code,
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
				  p_label_code,
				  'F',
				  l_rowid,
				  l_key_exists);

   IF FND_API.To_Boolean(l_key_exists) THEN
   	  RAISE Label_Exists_Error;
   END IF;

   INSERT INTO gr_item_field_name_masks_b
   		  	     (item_code,
				  disclosure_code,
				  label_code,
				  created_by,
				  creation_date,
				  last_updated_by,
				  last_update_date,
				  last_update_login)
          VALUES
		         (p_item_code,
				  p_disclosure_code,
				  p_label_code,
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
   GR_FIELD_NAME_MASKS_B

 PARAMETERS:
   p_commit            IN   VARCHAR2,
   p_called_by_form    IN   VARCHAR2,
   p_rowid             IN   VARCHAR2,
   p_item_code         IN   VARCHAR2,
   p_disclosure_code   IN   VARCHAR2,
   p_label_code        IN   VARCHAR2,
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

L_RETURN_STATUS   VARCHAR2(1) := 'S';
L_MSG_DATA        VARCHAR2(2000);

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
				  p_disclosure_code,
				  p_label_code,
				  l_return_status,
				  l_oracle_error,
				  l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Foreign_Key_Error;
   ELSE
      UPDATE gr_item_field_name_masks_b
      SET	 item_code	   = p_item_code,
		 disclosure_code   = p_disclosure_code,
		 label_code        = p_label_code,
		 created_by	   = p_created_by,
		 creation_date	   = p_creation_date,
		 last_updated_by   = p_last_updated_by,
		 last_update_date  = p_last_update_date,
		 last_update_login = p_last_update_login
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
   Lock_Row

 DESCRIPTION:
   This PL/SQL procedure is used to lock a row in the table
   GR_FIELD_NAME_MASKS_B

 PARAMETERS:
   p_commit            IN   VARCHAR2,
   p_called_by_form    IN   VARCHAR2,
   p_rowid             IN   VARCHAR2,
   p_item_code         IN   VARCHAR2,
   p_disclosure_code   IN   VARCHAR2,
   p_label_code        IN   VARCHAR2,
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
   FROM		gr_item_field_name_masks_b
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
   GR_FIELD_NAME_MASKS_B

 PARAMETERS:
   p_commit            IN   VARCHAR2,
   p_called_by_form    IN   VARCHAR2,
   p_rowid             IN   VARCHAR2,
   p_item_code         IN   VARCHAR2,
   p_disclosure_code   IN   VARCHAR2,
   p_label_code        IN   VARCHAR2,
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
PROCEDURE Delete_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_rowid IN VARCHAR2,
				  p_item_code IN VARCHAR2,
				  p_disclosure_code IN VARCHAR2,
				  p_label_code IN VARCHAR2,
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

CHECK_INTEGRITY_ERROR	  EXCEPTION;
ROW_MISSING_ERROR	  EXCEPTION;
PRAGMA EXCEPTION_INIT(Row_Missing_Error,100);

BEGIN

/*   Initialization Routine */

   SAVEPOINT Delete_Row;
   x_return_status := 'S';
   l_called_by_form := 'F';
   x_oracle_error := 0;
   x_msg_data := NULL;
   l_msg_token := p_item_code || ' ' || p_disclosure_code || ' ' || p_label_code ;

/* Now Call the Check Integrity procedure */

   Check_Integrity
                  (l_called_by_form,
                   p_item_code,
                   p_disclosure_code,
                   p_label_code,
                   l_return_status,
                   l_oracle_error,
                   l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Check_Integrity_Error;
   END IF;

   DELETE FROM gr_item_field_name_masks_b
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
   Check_Foreign_Keys

 DESCRIPTION:
   This PL/SQL procedure is used to check foreign key references from
   GR_FIELD_NAME_MASKS_B

 PARAMETERS:
   p_commit            IN   VARCHAR2,
   p_called_by_form    IN   VARCHAR2,
   p_rowid             IN   VARCHAR2,
   p_item_code         IN   VARCHAR2,
   p_disclosure_code   IN   VARCHAR2,
   p_label_code        IN   VARCHAR2,
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
PROCEDURE Check_Foreign_Keys
	   			 (p_item_code IN VARCHAR2,
				  p_disclosure_code IN VARCHAR2,
				  p_label_code IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2)
   IS

/*   Alpha Variables */

L_RETURN_STATUS	  VARCHAR2(1) := 'S';
L_MSG_DATA		  VARCHAR2(2000);
L_ROWID			  VARCHAR2(18);
L_KEY_EXISTS	  VARCHAR2(1);
L_HEADING		  VARCHAR2(30);

/*   Number Variables */

L_ORACLE_ERROR	  NUMBER;

/* Define the cursors */
/* Disclosure Codes */

CURSOR c_get_disclosure_codes
IS
  SELECT dc.disclosure_code
  FROM   gr_disclosures dc
  WHERE  dc.disclosure_code = p_disclosure_code;
Dsclcd   c_get_disclosure_codes%ROWTYPE;

/* Label Codes */

CURSOR c_get_label_codes
IS
  SELECT lc.label_code
  FROM   gr_labels_b lc
  WHERE  lc.label_code = p_label_code;
Labelcd   c_get_label_codes%ROWTYPE;

BEGIN

/*   Initialization Routine */

   SAVEPOINT Check_Foreign_Keys;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;

/*   Check the disclosure code for trade secrets */

   IF p_disclosure_code IS NOT NULL THEN
      OPEN c_get_disclosure_codes;
      FETCH c_get_disclosure_codes INTO Dsclcd;
      IF c_get_disclosure_codes%NOTFOUND THEN
         x_return_status := 'E';
	     FND_MESSAGE.SET_NAME('GR',
	                          'GR_RECORD_NOT_FOUND');
	     FND_MESSAGE.SET_TOKEN('CODE',
	                           p_disclosure_code,
			   				   FALSE);
	     l_msg_data := l_msg_data || FND_MESSAGE.Get || ' ';
	  END IF;
      CLOSE c_get_disclosure_codes;
   END IF;

/*   Check the label code for trade secrets */

   OPEN c_get_label_codes;
   FETCH c_get_label_codes INTO Labelcd;
   IF c_get_label_codes%NOTFOUND THEN
      x_return_status := 'E';
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_RECORD_NOT_FOUND');
	  FND_MESSAGE.SET_TOKEN('CODE',
	                        p_label_code,
							FALSE);
	  l_msg_data := l_msg_data || FND_MESSAGE.Get || ' ';
   END IF;
   CLOSE c_get_label_codes;

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
   GR_FIELD_NAME_MASKS_B

 PARAMETERS:
   p_item_code         IN   VARCHAR2   item code to check.
   p_disclosure_code   IN   VARCHAR2   disclosure code to check
   p_label_code        IN   VARCHAR2   label code to check
   p_called_by_form    IN   VARCHAR2   'T' if called by a form or 'F' if not
   x_row_id            OUT  VARCHAR2   row id of the record if found
   x_key_exists        OUT  VARCHAR2   'T' is the record is found, 'F' if not

 HISTORY
 ===================================================================== */
PROCEDURE Check_Primary_Key
		  		 	(p_item_code IN VARCHAR2,
					 p_disclosure_code IN VARCHAR2,
					 p_label_code IN VARCHAR2,
					 p_called_by_form IN VARCHAR2,
					 x_rowid OUT NOCOPY VARCHAR2,
					 x_key_exists OUT NOCOPY VARCHAR2)
  IS
/*	Alphanumeric variables	 */

L_MSG_DATA VARCHAR2(80);

/*		Declare any variables and the cursor */


CURSOR c_get_item_rowid
 IS
   SELECT dc.rowid
   FROM	  gr_item_field_name_masks_b dc
   WHERE  dc.item_code = p_item_code
   AND    dc.disclosure_code = p_disclosure_code
   AND    dc.label_code = p_label_code;

ItemRecord			   c_get_item_rowid%ROWTYPE;

BEGIN

   x_key_exists := 'F';
   l_msg_data := p_item_code;
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



/* =====================================================================
 PROOCEDURE:
   Check_Integrity

 DESCRIPTION:
   This PL/SQL procedure is used to check the data integrity in
   GR_FIELD_NAME_MASKS_B

 PARAMETERS:
   p_called_by_form    IN   VARCHAR2   'T' if called by a form or 'F' if not
   p_item_code         IN   VARCHAR2   item code to check.
   p_disclosure_code   IN   VARCHAR2   disclosure code to check
   p_label_code        IN   VARCHAR2   label code to check
   x_return_status     OUT  VARCHAR2,
   x_oracle_error      OUT  NUMBER,
   x_msg_data          OUT  VARCHAR2

 HISTORY
 ===================================================================== */
PROCEDURE Check_Integrity
				(p_called_by_form IN VARCHAR2,
		  		 p_item_code IN VARCHAR2,
				 p_disclosure_code IN VARCHAR2,
				 p_label_code IN VARCHAR2,
				 x_return_status OUT NOCOPY VARCHAR2,
				 x_oracle_error OUT NOCOPY NUMBER,
				 x_msg_data OUT NOCOPY VARCHAR2)
  IS
/*	Alphanumeric variables	 */

L_RETURN_STATUS VARCHAR2(1) := 'S';
L_MSG_DATA VARCHAR2(2000);
L_CODE_BLOCK VARCHAR2(100);

/*	Alphanumeric variables	 */

L_ORACLE_ERROR  NUMBER;
L_RECORD_COUNT  NUMBER;

/*		Declare any variables and the cursor */


BEGIN

/*     Initialization Routine */

   SAVEPOINT Check_Integrity;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;

   FND_MESSAGE.SET_NAME('GR',
                        'GR_INTEGRITY_HEADER');
   FND_MESSAGE.SET_TOKEN('CODE',
                         p_item_code || ' ' || p_disclosure_code || ' ' || p_label_code, FALSE);
   l_msg_data := FND_MESSAGE.Get;

/*	No integrity checking is needed */


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

END GR_FIELD_NAME_MASKS_B_PKG;

/
