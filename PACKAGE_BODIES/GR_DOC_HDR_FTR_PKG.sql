--------------------------------------------------------
--  DDL for Package Body GR_DOC_HDR_FTR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GR_DOC_HDR_FTR_PKG" AS
/*$Header: GRHIDHFB.pls 115.1 2002/10/28 23:03:24 mgrosser noship $*/
PROCEDURE Insert_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_document_code IN VARCHAR2,
				  p_line_type IN NUMBER,
				  p_line_no IN NUMBER,
				  p_left_label_code IN VARCHAR2,
				  p_right_label_code IN VARCHAR2,
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
	   (p_document_code,
  	    p_left_label_code,
	    p_right_label_code,
	    l_return_status,
	    l_oracle_error,
	    l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Foreign_Key_Error;
   END IF;

/* 	   Now check the primary key doesn't already exist */

   Check_Primary_Key
    	 (p_document_code,
	  p_line_type,
	  p_line_no,
	  p_left_label_code,
	  p_right_label_code,
	  'F',
	  l_rowid,
	  l_key_exists);

   IF FND_API.To_Boolean(l_key_exists) THEN
     RAISE Item_Exists_Error;
   END IF;

   INSERT INTO gr_doc_hdr_ftr
  	     (document_code,
	      line_type,
	      line_no,
	      left_label_code,
	      right_label_code,
	      created_by,
	      creation_date,
	      last_updated_by,
	      last_update_date,
	      last_update_login)
          VALUES
	     (p_document_code,
 	      p_line_type,
	      p_line_no,
	      p_left_label_code,
	      p_right_label_code,
              p_created_by,
              p_creation_date,
              p_last_updated_by,
              p_last_update_date,
              p_last_update_login);

/*   Now get the row id of the inserted record */

   Check_Primary_Key
    	 (p_document_code,
	  p_line_type,
	  p_line_no,
	  p_left_label_code,
	  p_right_label_code,
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
         		     p_document_code||' '||p_left_label_code||' '||p_right_label_code,
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
         		     p_document_code||' '||p_left_label_code||' '||p_right_label_code,
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
      x_oracle_error := APP_EXCEPTION.Get_Code;
      l_msg_data := sqlerrm;
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
				  p_document_code IN VARCHAR2,
				  p_line_type IN NUMBER,
				  p_line_no IN NUMBER,
				  p_left_label_code IN VARCHAR2,
				  p_right_label_code IN VARCHAR2,
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
	   (p_document_code,
  	    p_left_label_code,
	    p_right_label_code,
	    l_return_status,
	    l_oracle_error,
	    l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Foreign_Key_Error;
   ELSE
       UPDATE	gr_doc_hdr_ftr
	  SET	left_label_code            = p_left_label_code,
	        right_label_code	   = p_right_label_code,
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
         		     p_document_code||' '||p_left_label_code||' '||p_right_label_code,
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
      l_msg_data := sqlerrm;
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
				  p_document_code IN VARCHAR2,
				  p_line_type IN NUMBER,
				  p_line_no IN NUMBER,
				  p_left_label_code IN VARCHAR2,
				  p_right_label_code IN VARCHAR2,
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

CURSOR c_lock_doc_hdr_ftr
 IS
   SELECT	last_update_date
   FROM		gr_doc_hdr_ftr
   WHERE	rowid = p_rowid
   FOR UPDATE NOWAIT;
LockDHFRcd	  c_lock_doc_hdr_ftr%ROWTYPE;
BEGIN

/*      Initialization Routine */

   SAVEPOINT Lock_Row;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;

/*	   Now lock the record */

   OPEN c_lock_doc_hdr_ftr;
   FETCH c_lock_doc_hdr_ftr INTO LockDHFRcd;
   IF c_lock_doc_hdr_ftr%NOTFOUND THEN
	  CLOSE c_lock_doc_hdr_ftr;
	  RAISE No_Data_Found_Error;
   END IF;
   CLOSE c_lock_doc_hdr_ftr;

   IF LockDHFRcd.last_update_date <> p_last_update_date THEN
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
         		     p_document_code||' '||p_left_label_code||' '||p_right_label_code,
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
	  l_msg_data := sqlerrm;
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
				  p_document_code IN VARCHAR2,
				  p_line_type IN NUMBER,
				  p_line_no IN NUMBER,
				  p_left_label_code IN VARCHAR2,
				  p_right_label_code IN VARCHAR2,
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
	  p_document_code,
	  p_line_type,
	  p_line_no,
	  p_left_label_code,
	  p_right_label_code,
	  l_return_status,
	  l_oracle_error,
	  l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Check_Integrity_Error;
   END IF;

   DELETE FROM gr_doc_hdr_ftr
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
         		     p_document_code||' '||p_left_label_code||' '||p_right_label_code,
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
	  l_msg_data := sqlerrm;
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
	   			 (p_document_code IN VARCHAR2,
				  p_left_label_code IN VARCHAR2,
				  p_right_label_code IN VARCHAR2,
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
CURSOR c_get_document
 IS
   SELECT document_code
   FROM   gr_document_codes
   WHERE  document_code = p_document_code;

CURSOR c_get_label (V_label_code VARCHAR2)
 IS
   SELECT label_code
   FROM   gr_labels_b
   WHERE  label_code = V_label_code;

DocCdRecord		c_get_document%ROWTYPE;
LabelRecord		c_get_label%ROWTYPE;

BEGIN

/*   Initialization Routine */

   SAVEPOINT Check_Foreign_Keys;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;

/*   Check the hazard classification codes */
   IF p_document_code IS NOT NULL THEN
     OPEN c_get_document;
     FETCH c_get_document INTO DocCdRecord;
     IF c_get_document%NOTFOUND THEN
	  l_msg_token := p_document_code;
	  x_return_status := 'E';
	  x_oracle_error := APP_EXCEPTION.Get_Code;
        FND_MESSAGE.SET_NAME('GR',
                           'GR_RECORD_NOT_FOUND');
        FND_MESSAGE.SET_TOKEN('CODE',
         		            l_msg_token,
            			    FALSE);
       l_msg_data := FND_MESSAGE.Get;
     END IF;
     CLOSE c_get_document;
   END IF;

   IF p_left_label_code IS NOT NULL THEN
     OPEN c_get_label (p_left_label_code);
     FETCH c_get_label INTO LabelRecord;
     IF c_get_label%NOTFOUND THEN
	  l_msg_token := p_left_label_code;
	  x_return_status := 'E';
	  x_oracle_error := APP_EXCEPTION.Get_Code;
        FND_MESSAGE.SET_NAME('GR',
                           'GR_RECORD_NOT_FOUND');
        FND_MESSAGE.SET_TOKEN('CODE',
         		            l_msg_token,
            			    FALSE);
       l_msg_data := FND_MESSAGE.Get;
     END IF;
     CLOSE c_get_label;
   END IF;

   IF p_right_label_code IS NOT NULL THEN
     OPEN c_get_label (p_right_label_code);
     FETCH c_get_label INTO LabelRecord;
     IF c_get_label%NOTFOUND THEN
	  l_msg_token := p_right_label_code;
	  x_return_status := 'E';
	  x_oracle_error := APP_EXCEPTION.Get_Code;
        FND_MESSAGE.SET_NAME('GR',
                           'GR_RECORD_NOT_FOUND');
        FND_MESSAGE.SET_TOKEN('CODE',
         		            l_msg_token,
            			    FALSE);
       l_msg_data := FND_MESSAGE.Get;
     END IF;
     CLOSE c_get_label;
   END IF;

   IF x_return_status <> 'S' THEN
      x_msg_data := l_msg_data;
   END IF;

EXCEPTION

   WHEN OTHERS THEN
      ROLLBACK TO SAVEPOINT Check_Foreign_Keys;
	  x_return_status := 'U';
	  x_oracle_error := APP_EXCEPTION.Get_Code;
	  l_msg_data := sqlerrm;
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_UNEXPECTED_ERROR');
	  FND_MESSAGE.SET_TOKEN('TEXT',
	                        l_msg_data,
	                        FALSE);
	  x_msg_data := FND_MESSAGE.Get;

END Check_Foreign_Keys;

PROCEDURE Check_Integrity
	   			 (p_called_by_form IN VARCHAR2,
				  p_document_code IN VARCHAR2,
				  p_line_type IN NUMBER,
				  p_line_no IN NUMBER,
				  p_left_label_code IN VARCHAR2,
				  p_right_label_code IN VARCHAR2,
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
         		     p_document_code||' '||p_left_label_code||' '||p_right_label_code,
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
      x_oracle_error := APP_EXCEPTION.Get_Code;
      l_msg_data := sqlerrm;
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
			 (p_document_code IN VARCHAR2,
			  p_line_type IN NUMBER,
			  p_line_no IN NUMBER,
			  p_left_label_code IN VARCHAR2,
			  p_right_label_code IN VARCHAR2,
			  p_called_by_form IN VARCHAR2,
			  x_rowid OUT NOCOPY VARCHAR2,
			  x_key_exists OUT NOCOPY VARCHAR2)
 IS
/*		Declare any variables and the cursor */

L_MSG_DATA VARCHAR2(2000);

CURSOR c_get_dhf_rowid
 IS
   SELECT dhf.rowid
   FROM	  gr_doc_hdr_ftr dhf
   WHERE  document_code = p_document_code
   AND    line_type     = p_line_type
   AND    line_no       = p_line_no;
DHFRecord			   c_get_dhf_rowid%ROWTYPE;

BEGIN

   x_key_exists := 'F';
   OPEN c_get_dhf_rowid;
   FETCH c_get_dhf_rowid INTO DHFRecord;
   IF c_get_dhf_rowid%FOUND THEN
      x_key_exists := 'T';
      x_rowid := DHFRecord.rowid;
   ELSE
      x_key_exists := 'F';
   END IF;
   CLOSE c_get_dhf_rowid;

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

END GR_DOC_HDR_FTR_PKG;

/
