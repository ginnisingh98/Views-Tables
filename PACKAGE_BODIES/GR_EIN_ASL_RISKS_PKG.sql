--------------------------------------------------------
--  DDL for Package Body GR_EIN_ASL_RISKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GR_EIN_ASL_RISKS_PKG" AS
/*$Header: GRHIEARB.pls 115.5 2002/10/29 16:37:34 mgrosser noship $*/
PROCEDURE Insert_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_sequence_number IN NUMBER,
				  p_risk_phrase_code IN VARCHAR2,
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
/* Declare Alpha Variables */

L_RETURN_STATUS VARCHAR2(1) := 'S';
L_KEY_EXISTS 	VARCHAR2(1);
L_MSG_DATA 		VARCHAR2(2000);
L_ROWID 		VARCHAR2(18);

/* Declare Number Variables */

L_ORACLE_ERROR	  NUMBER;

/* Declare Exceptions */

FOREIGN_KEY_ERROR 	EXCEPTION;
KEY_EXISTS_ERROR 	EXCEPTION;
ROW_MISSING_ERROR 	EXCEPTION;


BEGIN

/*     Initialization Routine */

   SAVEPOINT Insert_Row;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;

/*  Call the check foreign key procedure
  This will check that any codes being inserted into this table do indeed
  exist in the tables that they reference.  */

   Check_Foreign_Keys
			     (p_sequence_number,
			      p_risk_phrase_code,
                              l_return_status,
                              l_oracle_error,
                              l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Foreign_Key_Error;
   END IF;



/*   Check the primary key doesn't already exist */

   Check_Primary_Key
   	   	   		 (p_sequence_number,
   	   	   		  p_risk_phrase_code,
				  'F',
				  l_rowid,
				  l_key_exists);

   IF FND_API.To_Boolean(l_key_exists) THEN
   	  RAISE Key_Exists_Error;
   END IF;

   INSERT INTO gr_ein_asl_risks
   		  	     (    sequence_number,
   		  	          risk_phrase_code,
				  created_by,
				  creation_date,
				  last_updated_by,
				  last_update_date,
				  last_update_login)

          VALUES
		                 (p_sequence_number,
		                  p_risk_phrase_code,
				  p_created_by,
				  p_creation_date,
				  p_last_updated_by,
				  p_last_update_date,
				  p_last_update_login);

/*   Now get the row id of the inserted record */

   Check_Primary_Key
   	   	   		 (p_sequence_number,
   	   	   		  p_risk_phrase_code,
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

   WHEN Key_Exists_Error THEN
      ROLLBACK TO SAVEPOINT Insert_Row;
	  x_return_status := 'E';
	  x_oracle_error := APP_EXCEPTION.Get_Code;
      FND_MESSAGE.SET_NAME('GR',
                           'GR_RECORD_EXISTS');
      FND_MESSAGE.SET_TOKEN('CODE',
         		     p_sequence_number || ',' || p_risk_phrase_code,
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
         		     p_sequence_number || ',' || p_risk_phrase_code,
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


PROCEDURE Check_Foreign_Keys
	   			 (p_sequence_number IN NUMBER,
				  p_risk_phrase_code IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2)
   IS

/* Declare Alpha Variables */

L_RETURN_STATUS	  VARCHAR2(1) := 'S';
L_MSG_DATA	  VARCHAR2(2000);
L_ROWID		  VARCHAR2(18);
L_KEY_EXISTS	  VARCHAR2(1);

/* Declare  Number Variables */

L_ORACLE_ERROR	  NUMBER;

/* Define the cursors */
/* Risk Phrase cursor  */

CURSOR c_get_risk_phrase
 IS
   SELECT	rp.risk_phrase_code
   FROM		gr_risk_phrases_b rp
   WHERE	rp.risk_phrase_code = p_risk_phrase_code;
RiskPhraseRcd		c_get_risk_phrase%ROWTYPE;


BEGIN

/*   Initialization Routine */

   SAVEPOINT Check_Foreign_Keys;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;

/*   Check the risk phrase code */


   OPEN c_get_risk_phrase;
   FETCH c_get_risk_phrase INTO RiskPhraseRcd;
   IF c_get_risk_phrase%NOTFOUND THEN
      x_return_status := 'E';
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_RECORD_NOT_FOUND');
	  FND_MESSAGE.SET_TOKEN('CODE',
	                        p_risk_phrase_code,
				FALSE);
	  l_msg_data := l_msg_data || FND_MESSAGE.Get || ' ';
   END IF;
   CLOSE c_get_risk_phrase;


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




PROCEDURE Delete_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_rowid IN VARCHAR2,
				  p_sequence_number IN NUMBER,
				  p_risk_phrase_code IN VARCHAR2,
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
L_MSG_DATA	  VARCHAR2(2000);
L_CALLED_BY_FORM  VARCHAR2(1);

/*   Number Variables */

L_ORACLE_ERROR	  NUMBER;

/*   Exceptions */

CHECK_INTEGRITY_ERROR     EXCEPTION;
ROW_MISSING_ERROR	  EXCEPTION;
PRAGMA                    EXCEPTION_INIT(Row_Missing_Error,100);

BEGIN

/*   Initialization Routine */

   SAVEPOINT Delete_Row;
   x_return_status := 'S';
   l_called_by_form := 'F';
   x_oracle_error := 0;
   x_msg_data := NULL;



   DELETE FROM gr_ein_asl_risks
   WHERE       rowid = p_rowid;

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
         		            p_sequence_number || ', '
         		            || p_risk_phrase_code,
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



PROCEDURE Check_Primary_Key
		/*  p_sequence_number and p_risk_phrase_code is the key to check.
		  p_called_by_form is 'T' if called by a form or 'F' if not.
		  x_rowid is the row id of the record if found.
		  x_key_exists is 'T' is the record is found, 'F' if not. */

		  		 	(p_sequence_number IN NUMBER,
		  		 	 p_risk_phrase_code IN VARCHAR2,
					 p_called_by_form IN VARCHAR2,
					 x_rowid OUT NOCOPY VARCHAR2,
					 x_key_exists OUT NOCOPY VARCHAR2)
  IS
/*	Alphanumeric variables */

L_MSG_DATA VARCHAR2(80);

/*		Declare any variables and the cursor */


CURSOR c_get_einaslrisk_rowid
 IS
   SELECT ear.rowid
   FROM	  gr_ein_asl_risks ear
   WHERE  ear.sequence_number = p_sequence_number
     AND  ear.risk_phrase_code = p_risk_phrase_code;

EinAslRiskRecord			   c_get_einaslrisk_rowid%ROWTYPE;

BEGIN

   x_key_exists := 'F';
   l_msg_data := p_sequence_number || ', ' || p_risk_phrase_code;
   OPEN c_get_einaslrisk_rowid;
   FETCH c_get_einaslrisk_rowid INTO EinAslRiskRecord;
   IF c_get_einaslrisk_rowid%FOUND THEN
      x_key_exists := 'T';
	  x_rowid := EinAslRiskRecord.rowid;
   ELSE
      x_key_exists := 'F';
   END IF;
   CLOSE c_get_einaslrisk_rowid;

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


END GR_EIN_ASL_RISKS_PKG;

/
