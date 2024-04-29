--------------------------------------------------------
--  DDL for Package Body GR_EIN_ASL_CONCS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GR_EIN_ASL_CONCS_PKG" AS
/*$Header: GRHIEICB.pls 115.4 2002/10/29 16:32:06 mgrosser noship $*/
PROCEDURE Insert_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_sequence_number IN NUMBER,
				  p_european_index_number IN VARCHAR2,
				  p_concentration_low IN NUMBER,
				  p_concentration_high IN NUMBER,
				  p_hazard_classification_code IN VARCHAR2,
				  p_consolidated_risk_phrase IN VARCHAR2,
				  p_calculation_id IN VARCHAR2,
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
L_KEY_EXISTS VARCHAR2(1);
L_MSG_DATA VARCHAR2(2000);
L_ROWID VARCHAR2(18);

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
	   (p_european_index_number,
	    p_hazard_classification_code,
	    l_return_status,
	    l_oracle_error,
	    l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Foreign_Key_Error;
   END IF;

/* 	   Now check the primary key doesn't already exist */

   Check_Primary_Key
    	 (p_sequence_number,
	  p_european_index_number,
	  p_concentration_low,
	  p_concentration_high,
	  p_hazard_classification_code,
	  p_consolidated_risk_phrase,
	  p_calculation_id,
	  'F',
	  l_rowid,
	  l_key_exists);

   IF FND_API.To_Boolean(l_key_exists) THEN
   	  RAISE Item_Exists_Error;
   END IF;

   INSERT INTO gr_ein_asl_concs
  	     (sequence_number,
	      european_index_number,
	      concentration_low,
	      concentration_high,
	      hazard_classification_code,
	      consolidated_risk_phrase,
	      calculation_id,
	      created_by,
	      creation_date,
	      last_updated_by,
	      last_update_date,
	      last_update_login)
          VALUES
	     (p_sequence_number,
 	      p_european_index_number,
	      p_concentration_low,
	      p_concentration_high,
	      p_hazard_classification_code,
	      p_consolidated_risk_phrase,
	      p_calculation_id,
              p_created_by,
              p_creation_date,
              p_last_updated_by,
              p_last_update_date,
              p_last_update_login);

/*   Now get the row id of the inserted record */

   Check_Primary_Key
    	 (p_sequence_number,
	  p_european_index_number,
	  p_concentration_low,
	  p_concentration_high,
	  p_hazard_classification_code,
	  p_consolidated_risk_phrase,
	  p_calculation_id,
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
         		     p_european_index_number||' '||p_hazard_classification_code,
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
         		     p_european_index_number,
            		     FALSE);
      x_msg_data := FND_MESSAGE.Get;
      IF FND_API.To_Boolean(p_called_by_form) THEN
	 	 APP_EXCEPTION.Raise_Exception;
      ELSE
         x_msg_data := FND_MESSAGE.Get;
	  END IF;

   WHEN OTHERS THEN
      ROLLBACK TO SAVEPOINT Insert_Row;
      x_return_status := 'U';
      x_oracle_error := SQLCODE;
      l_msg_data := SUBSTR(sqlerrm, 1, 200);
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
				  p_sequence_number IN NUMBER,
				  p_european_index_number IN VARCHAR2,
				  p_concentration_low IN NUMBER,
				  p_concentration_high IN NUMBER,
				  p_hazard_classification_code IN VARCHAR2,
				  p_consolidated_risk_phrase IN VARCHAR2,
				  p_calculation_id IN VARCHAR2,
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
	   (p_european_index_number,
	    p_hazard_classification_code,
		l_return_status,
		l_oracle_error,
		l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Foreign_Key_Error;
   ELSE
       UPDATE	gr_ein_asl_concs
	  SET	sequence_number            = p_sequence_number,
	        european_index_number	   = p_european_index_number,
	        concentration_low          = p_concentration_low,
	        concentration_high         = p_concentration_high,
	        hazard_classification_code = p_hazard_classification_code,
	        consolidated_risk_phrase   = p_consolidated_risk_phrase,
	        calculation_id             = p_calculation_id,
		created_by                 = p_created_by,
		creation_date              = p_creation_date,
		last_updated_by	           = p_last_updated_by,
		last_update_date           = p_last_update_date,
		last_update_login          = p_last_update_login
	 WHERE	rowid = p_rowid;

      IF SQL%NOTFOUND THEN
	     RAISE Row_Missing_Error;
	  END IF;
   END IF;

/* 	Check if do the commit */

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
	    		p_european_index_number||' '||TO_CHAR(p_concentration_low)||'-'||TO_CHAR(p_concentration_high),
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
				  p_sequence_number IN NUMBER,
				  p_european_index_number IN VARCHAR2,
				  p_concentration_low IN NUMBER,
				  p_concentration_high IN NUMBER,
				  p_hazard_classification_code IN VARCHAR2,
				  p_consolidated_risk_phrase IN VARCHAR2,
				  p_calculation_id IN VARCHAR2,
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

CURSOR c_lock_ein_asl_concs
 IS
   SELECT	last_update_date
   FROM		gr_ein_asl_concs
   WHERE	rowid = p_rowid
   FOR UPDATE NOWAIT;
LockEinRcd	  c_lock_ein_asl_concs%ROWTYPE;
BEGIN

/*      Initialization Routine */

   SAVEPOINT Lock_Row;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;

/*	   Now lock the record */

   OPEN c_lock_ein_asl_concs;
   FETCH c_lock_ein_asl_concs INTO LockEinRcd;
   IF c_lock_ein_asl_concs%NOTFOUND THEN
	  CLOSE c_lock_ein_asl_concs;
	  RAISE No_Data_Found_Error;
   END IF;
   CLOSE c_lock_ein_asl_concs;

   IF LockEinRcd.last_update_date <> p_last_update_date THEN
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
	    		p_european_index_number||' '||TO_CHAR(p_concentration_low)||'-'||TO_CHAR(p_concentration_high),
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
	  l_msg_data := SUBSTR(sqlerrm, 1, 200);
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
				  p_sequence_number IN NUMBER,
				  p_european_index_number IN VARCHAR2,
				  p_concentration_low IN NUMBER,
				  p_concentration_high IN NUMBER,
				  p_hazard_classification_code IN VARCHAR2,
				  p_consolidated_risk_phrase IN VARCHAR2,
				  p_calculation_id IN VARCHAR2,
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

CHECK_INTEGRITY_ERROR EXCEPTION;
ROW_MISSING_ERROR	  EXCEPTION;
PRAGMA EXCEPTION_INIT(Row_Missing_Error,100);

BEGIN

/*   Initialization Routine */

   SAVEPOINT Delete_Row;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;

/*  Now call the check integrity procedure */

   Check_Integrity
	 (p_called_by_form,
    	  p_sequence_number,
	  p_european_index_number,
	  p_concentration_low,
	  p_concentration_high,
	  p_hazard_classification_code,
	  p_consolidated_risk_phrase,
	  p_calculation_id,
	  l_return_status,
	  l_oracle_error,
	  l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Check_Integrity_Error;
   END IF;

   DELETE FROM gr_ein_asl_concs
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
	    		p_european_index_number||' '||TO_CHAR(p_concentration_low)||'-'||TO_CHAR(p_concentration_high),
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
	  l_msg_data := SUBSTR(sqlerrm, 1, 200);
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
		      p_european_index_number IN VARCHAR2,
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
   l_msg_token := p_european_index_number;

   DELETE FROM gr_ein_asl_concs
   WHERE       european_index_number = p_european_index_number;

   IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
   END IF;

EXCEPTION

   WHEN OTHERS THEN
      ROLLBACK TO SAVEPOINT Delete_Rows;
	  x_return_status := 'U';
	  x_oracle_error := SQLCODE;
	  l_msg_data := SUBSTR(sqlerrm, 1, 200);
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
	   			 (p_european_index_number IN VARCHAR2,
	   			  p_hazard_classification_code IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2)
   IS

/*   Alpha Variables */

L_RETURN_STATUS	  VARCHAR2(1) := 'S';
L_MSG_DATA		  VARCHAR2(2000);
L_ROWID			  VARCHAR2(18);
L_KEY_EXISTS	  VARCHAR2(1);
L_MSG_TOKEN       VARCHAR2(30);

/*   Number Variables */

L_ORACLE_ERROR	  NUMBER;

/* Cursors   */
CURSOR c_get_hazards
 IS
   SELECT 	hazard_classification_code
   FROM		gr_eurohazards_b
   WHERE	hazard_classification_code = p_hazard_classification_code;
HazClassRecord			c_get_hazards%ROWTYPE;

BEGIN

/*   Initialization Routine */

   SAVEPOINT Check_Foreign_Keys;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;

/*   Check the hazard classification codes */
   IF p_hazard_classification_code IS NOT NULL THEN
     OPEN c_get_hazards;
     FETCH c_get_hazards INTO HazClassRecord;
     IF c_get_hazards%NOTFOUND THEN
	  l_msg_token := p_hazard_classification_code;
	  x_return_status := 'E';
	  x_oracle_error := APP_EXCEPTION.Get_Code;
        FND_MESSAGE.SET_NAME('GR',
                           'GR_RECORD_NOT_FOUND');
        FND_MESSAGE.SET_TOKEN('CODE',
         		            l_msg_token,
            			    FALSE);
       l_msg_data := FND_MESSAGE.Get;
     END IF;
     CLOSE c_get_hazards;
   END IF;
   IF x_return_status <> 'S' THEN
      x_msg_data := l_msg_data;
   END IF;

EXCEPTION

   WHEN OTHERS THEN
      ROLLBACK TO SAVEPOINT Check_Foreign_Keys;
	  x_return_status := 'U';
	  x_oracle_error := SQLCODE;
	  l_msg_data := SUBSTR(sqlerrm, 1, 200);
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_UNEXPECTED_ERROR');
	  FND_MESSAGE.SET_TOKEN('TEXT',
	                        l_msg_data,
	                        FALSE);
	  x_msg_data := FND_MESSAGE.Get;

END Check_Foreign_Keys;

PROCEDURE Check_Integrity
	   			 (p_called_by_form IN VARCHAR2,
				  p_sequence_number IN NUMBER,
				  p_european_index_number IN VARCHAR2,
				  p_concentration_low IN NUMBER,
				  p_concentration_high IN NUMBER,
				  p_hazard_classification_code IN VARCHAR2,
				  p_consolidated_risk_phrase IN VARCHAR2,
				  p_calculation_id IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2)
 IS

/*   Alpha Variables */

L_RETURN_STATUS	  VARCHAR2(1) := 'S';
L_MSG_DATA		  VARCHAR2(2000);

/*   Number Variables */

L_ORACLE_ERROR	  NUMBER;
L_RECORD_COUNT	  NUMBER;

/*   Exceptions */
INTEGRITY_ERROR		EXCEPTION;
/*   Define Cursors */


BEGIN
/*
**   Initialization Routine
*/
   SAVEPOINT Check_Integrity;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;
   l_record_count := 0;

 /* No need for checking any integrity */

EXCEPTION

   WHEN INTEGRITY_ERROR THEN
      x_return_status := 'E';
      FND_MESSAGE.SET_NAME('GR',
                           'GR_INTEGRITY_HEADER');
      FND_MESSAGE.SET_TOKEN('CODE',
	                    p_european_index_number||' '||p_hazard_classification_code,
	                    FALSE);
      FND_MESSAGE.SET_TOKEN('TABLES',
	                    l_msg_data,
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
      l_msg_data := SUBSTR(sqlerrm, 1, 200);
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
			 (p_sequence_number IN NUMBER,
			  p_european_index_number IN VARCHAR2,
			  p_concentration_low IN NUMBER,
			  p_concentration_high IN NUMBER,
			  p_hazard_classification_code IN VARCHAR2,
			  p_consolidated_risk_phrase IN VARCHAR2,
			  p_calculation_id IN VARCHAR2,
			  p_called_by_form IN VARCHAR2,
			  x_rowid OUT NOCOPY VARCHAR2,
			  x_key_exists OUT NOCOPY VARCHAR2)
 IS
/*		Declare any variables and the cursor */

L_MSG_DATA VARCHAR2(2000);

CURSOR c_get_eic_rowid
 IS
   SELECT eic.rowid
   FROM	  gr_ein_asl_concs eic
   WHERE  eic.european_index_number = p_european_index_number
   AND    eic.concentration_low = p_concentration_low
   AND    eic.concentration_high = p_concentration_high
   AND    (  (eic.hazard_classification_code IS NULL
              AND p_hazard_classification_code IS NULL)
          OR (eic.hazard_classification_code = p_hazard_classification_code));
EicRecord			   c_get_eic_rowid%ROWTYPE;

BEGIN

   x_key_exists := 'F';
   OPEN c_get_eic_rowid;
   FETCH c_get_eic_rowid INTO EicRecord;
   IF c_get_eic_rowid%FOUND THEN
      x_key_exists := 'T';
      x_rowid := EicRecord.rowid;
   ELSE
      x_key_exists := 'F';
   END IF;
   CLOSE c_get_eic_rowid;

EXCEPTION

   WHEN Others THEN
	  l_msg_data := sqlerrm;
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_UNEXPECTED_ERROR');
	  FND_MESSAGE.SET_TOKEN('TEXT',
	                        l_msg_data,
	                        FALSE);
      IF FND_API.To_Boolean(p_called_by_form) THEN
	     APP_EXCEPTION.Raise_Exception;
	  END IF;

END Check_Primary_Key;

END GR_EIN_ASL_CONCS_PKG;

/
