--------------------------------------------------------
--  DDL for Package Body GR_ITEM_DOCUMENT_DTLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GR_ITEM_DOCUMENT_DTLS_PKG" AS
/*$Header: GRHIIDDB.pls 115.6 2002/10/25 20:31:01 methomas ship $*/
PROCEDURE Insert_Row
	   			 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_item_code IN VARCHAR2,
				  p_document_code IN VARCHAR2,
				  p_phrase_code IN VARCHAR2,
				  p_display_order IN NUMBER,
				  p_main_heading_code IN VARCHAR2,
				  p_sub_heading_code IN VARCHAR2,
				  p_print_size IN NUMBER,
				  p_print_font IN VARCHAR2,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_date IN DATE,
				  p_last_update_login IN NUMBER,
				  p_phrase_group_code IN VARCHAR2,
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
				  p_document_code,
				  p_phrase_code,
				  p_display_order,
				  p_main_heading_code,
				  p_sub_heading_code,
				  p_print_size,
				  p_print_font,
				  p_phrase_group_code,
				  l_return_status,
				  l_oracle_error,
				  l_msg_data);
   IF l_return_status <> 'S' THEN
      RAISE Foreign_Key_Error;
   END IF;

/* 	   Now check the primary key doesn't already exist */

   Check_Primary_Key
   	   	   		 (p_item_code,
   	   	   		  p_document_code,
				  p_phrase_code,
				  p_display_order,
				  'F',
				  l_rowid,
				  l_key_exists);

   IF FND_API.To_Boolean(l_key_exists) THEN
   	  RAISE Label_Exists_Error;
   END IF;

   INSERT INTO gr_item_document_dtls
   		  	     (item_code,
				  document_code,
				  phrase_code,
				  display_order,
				  main_heading_code,
				  sub_heading_code,
				  print_size,
				  print_font,
				  created_by,
				  creation_date,
				  last_updated_by,
				  last_update_date,
				  last_update_login,
				  phrase_group_code)
          VALUES
		         (p_item_code,
				  p_document_code,
				  p_phrase_code,
				  p_display_order,
				  p_main_heading_code,
				  p_sub_heading_code,
				  p_print_size,
				  p_print_font,
				  p_created_by,
				  p_creation_date,
				  p_last_updated_by,
				  p_last_update_date,
				  p_last_update_login,
				  p_phrase_group_code);

/*   Now get the row id of the inserted record */

   Check_Primary_Key
   	   	   		 (p_item_code,
				  p_document_code,
				  p_phrase_code,
				  p_display_order,
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
         		            p_item_code || ' ' || p_document_code,
            			    FALSE);
      IF FND_API.To_Boolean(p_called_by_form) THEN
         APP_EXCEPTION.Raise_Exception;
	  ELSE
	     x_msg_data := FND_MESSAGE.Get;
      END IF;

   WHEN Row_Missing_Error THEN
      ROLLBACK TO SAVEPOINT Insert_Row;
	  l_msg_data := p_item_code || ' ' || p_document_code;
	  x_return_status := 'E';
	  x_oracle_error := APP_EXCEPTION.Get_Code;
      FND_MESSAGE.SET_NAME('GR',
                           'GR_NO_RECORD_INSERTED');
      FND_MESSAGE.SET_TOKEN('CODE',
         		            l_msg_data,
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
				  p_document_code IN VARCHAR2,
				  p_phrase_code IN VARCHAR2,
				  p_display_order IN NUMBER,
				  p_main_heading_code IN VARCHAR2,
				  p_sub_heading_code IN VARCHAR2,
				  p_print_size IN NUMBER,
				  p_print_font IN VARCHAR2,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_date IN DATE,
				  p_last_update_login IN NUMBER,
				  p_phrase_group_code IN VARCHAR2,
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
				  p_document_code,
				  p_phrase_code,
				  p_display_order,
				  p_main_heading_code,
				  p_sub_heading_code,
				  p_print_size,
				  p_print_font,
				  p_phrase_group_code,
				  l_return_status,
				  l_oracle_error,
				  l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Foreign_Key_Error;
   ELSE
      UPDATE gr_item_document_dtls
      SET	 item_code		 				 = p_item_code,
			 document_code	  				 = p_document_code,
			 phrase_code	  				 = p_phrase_code,
			 display_order	  				 = p_display_order,
			 main_heading_code	  			 = p_main_heading_code,
			 sub_heading_code	  			 = p_sub_heading_code,
			 print_size	  					 = p_print_size,
			 print_font			  			 = p_print_font,
			 created_by						 = p_created_by,
			 creation_date					 = p_creation_date,
			 last_updated_by				 = p_last_updated_by,
			 last_update_date				 = p_last_update_date,
			 last_update_login				 = p_last_update_login,
			 phrase_group_code				 = p_phrase_group_code
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
	  l_msg_data := p_item_code || ' ' || p_document_code;
	  x_return_status := 'E';
	  x_oracle_error := APP_EXCEPTION.Get_Code;
      FND_MESSAGE.SET_NAME('GR',
                           'GR_NO_RECORD_INSERTED');
      FND_MESSAGE.SET_TOKEN('CODE',
         		            l_msg_data,
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
				  p_document_code IN VARCHAR2,
				  p_phrase_code IN VARCHAR2,
				  p_display_order IN NUMBER,
				  p_main_heading_code IN VARCHAR2,
				  p_sub_heading_code IN VARCHAR2,
				  p_print_size IN NUMBER,
				  p_print_font IN VARCHAR2,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_date IN DATE,
				  p_last_update_login IN NUMBER,
				  p_phrase_group_code IN VARCHAR2,
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

CURSOR c_lock_item_doc_dtls
 IS
   SELECT	*
   FROM		gr_item_document_dtls
   WHERE	rowid = p_rowid
   FOR UPDATE NOWAIT;
LockItemDocDtlRcd	  c_lock_item_doc_dtls%ROWTYPE;

BEGIN

/*      Initialization Routine */

   SAVEPOINT Lock_Row;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;

/*	   Now lock the record */

   OPEN c_lock_item_doc_dtls;
   FETCH c_lock_item_doc_dtls INTO LockItemDocDtlRcd;
   IF c_lock_item_doc_dtls%NOTFOUND THEN
	  CLOSE c_lock_item_doc_dtls;
	  RAISE No_Data_Found_Error;
   END IF;
   CLOSE c_lock_item_doc_dtls;

   IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
   END IF;

EXCEPTION

   WHEN No_Data_Found_Error THEN
      ROLLBACK TO SAVEPOINT Lock_Row;
	  l_msg_data := p_item_code || ' ' || p_document_code;
	  x_return_status := 'E';
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_RECORD_NOT_FOUND');
	  FND_MESSAGE.SET_TOKEN('CODE',
	                        l_msg_data,
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
				  p_document_code IN VARCHAR2,
				  p_phrase_code IN VARCHAR2,
				  p_display_order IN NUMBER,
				  p_main_heading_code IN VARCHAR2,
				  p_sub_heading_code IN VARCHAR2,
				  p_print_size IN NUMBER,
				  p_print_font IN VARCHAR2,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_date IN DATE,
				  p_last_update_login IN NUMBER,
				  p_phrase_group_code IN VARCHAR2,
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
				  p_document_code,
				  p_phrase_code,
				  p_display_order,
				  p_main_heading_code,
				  p_sub_heading_code,
				  p_print_size,
				  p_print_font,
				  p_phrase_group_code,
				  l_return_status,
				  l_oracle_error,
				  l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Check_Integrity_Error;
   END IF;

   DELETE FROM gr_item_document_dtls
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
	  l_msg_data := p_item_code || ' ' || p_document_code;
	  x_return_status := 'E';
	  x_oracle_error := APP_EXCEPTION.Get_Code;
      FND_MESSAGE.SET_NAME('GR',
                           'GR_RECORD_NOT_FOUND');
      FND_MESSAGE.SET_TOKEN('CODE',
         		            l_msg_data,
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
				  p_delete_option IN VARCHAR2,
				  p_item_code IN VARCHAR2,
	              p_document_code IN VARCHAR2,
				  p_phrase_code IN VARCHAR2,
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

/* 	 Define the exceptions */
NULL_DELETE_OPTION_ERROR	EXCEPTION;

/*   Define the cursors */

BEGIN

/*   Initialization Routine */

   SAVEPOINT Delete_Rows;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;

/*
**		p delete option has one of five values
**		'I' - Delete all rows for the specified item.
**		'D' - Delete all rows for the specified document.
**		'P' - Delete all rows for the specified phrase.
*/
   IF p_delete_option = 'I' THEN
      IF p_item_code IS NULL THEN
	     l_msg_token := 'Item Code';
	     RAISE Null_Delete_Option_Error;
	  ELSE
	     l_msg_token := p_item_code;

         DELETE FROM  gr_item_document_dtls
         WHERE		  item_code = p_item_code;
   	  END IF;
   ELSIF p_delete_option = 'D' THEN
      IF p_document_code IS NULL THEN
	     l_msg_token := 'Document Code';
		 RAISE Null_Delete_Option_Error;
	  ELSE
	     l_msg_token := p_document_code;

         DELETE FROM	gr_item_document_dtls
         WHERE			document_code = p_document_code;
      END IF;
   ELSIF p_delete_option = 'P' THEN
      IF p_phrase_code IS NULL THEN
	     l_msg_token := 'Phrase Code';
		 RAISE Null_Delete_Option_Error;
	  ELSE
	     l_msg_token := p_phrase_code;

		 DELETE FROM 	gr_item_document_dtls
		 WHERE			phrase_code = p_phrase_code;
	  END IF;
   END IF;

   IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
   END IF;

EXCEPTION

   WHEN Null_Delete_Option_Error THEN
	  x_return_status := 'E';
	  x_oracle_error := APP_EXCEPTION.Get_Code;
      FND_MESSAGE.SET_NAME('GR',
                           'GR_NULL_VALUE');
      FND_MESSAGE.SET_TOKEN('CODE',
         		            l_msg_token,
            			    FALSE);
      IF FND_API.To_Boolean(p_called_by_form) THEN
	     APP_EXCEPTION.Raise_Exception;
	  ELSE
         x_msg_data := FND_MESSAGE.Get;
	  END IF;

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
				  p_document_code IN VARCHAR2,
				  p_phrase_code IN VARCHAR2,
				  p_display_order IN NUMBER,
				  p_main_heading_code IN VARCHAR2,
				  p_sub_heading_code IN VARCHAR2,
				  p_print_size IN NUMBER,
				  p_print_font IN VARCHAR2,
				  p_phrase_group_code IN VARCHAR2,
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
/*	 Main Headings  */

CURSOR c_get_main_heading
 IS
   SELECT	mh.main_heading_code
   FROM		gr_main_headings_b mh
   WHERE	mh.main_heading_code = p_main_heading_code;
MainHdgRcd		c_get_main_heading%ROWTYPE;

/*	 Sub Headings  */

CURSOR c_get_sub_heading
 IS
   SELECT	sh.sub_heading_code
   FROM		gr_sub_headings_b sh
   WHERE	sh.sub_heading_code = p_sub_heading_code;
SubHdgRcd		c_get_sub_heading%ROWTYPE;

BEGIN

/*   Initialization Routine */

   SAVEPOINT Check_Foreign_Keys;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;

/*   Check the item code */

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

/*   Check the document code */

   l_key_exists := 'T';
   GR_DOCUMENT_CODES_PKG.Check_Primary_Key
   				(p_document_code,
				 'F',
				 l_rowid,
				 l_key_exists);

   IF NOT FND_API.To_Boolean(l_key_exists) THEN
      x_return_status := 'E';
	  FND_MESSAGE.SET_NAME('GR',
	                       'GR_RECORD_NOT_FOUND');
	  FND_MESSAGE.SET_TOKEN('CODE',
	                        p_document_code,
	  				        FALSE);
	  l_msg_data := l_msg_data || FND_MESSAGE.Get || ' ';
   END IF;

/*   Check the phrase code */

   IF p_phrase_code IS NOT NULL THEN
      l_key_exists := 'T';
      GR_PHRASES_B_PKG.Check_Primary_Key
				(p_phrase_code,
				 'F',
				 l_rowid,
				 l_key_exists);

      IF NOT FND_API.To_Boolean(l_key_exists) THEN
         x_return_status := 'E';
	     FND_MESSAGE.SET_NAME('GR',
	                          'GR_RECORD_NOT_FOUND');
	     FND_MESSAGE.SET_TOKEN('CODE',
	                           p_phrase_code,
	     				       FALSE);
	     l_msg_data := l_msg_data || FND_MESSAGE.Get || ' ';
	  END IF;
   END IF;

/*   Check the main heading code */

   OPEN c_get_main_heading;
   FETCH c_get_main_heading INTO MainHdgRcd;
   IF c_get_main_heading%NOTFOUND THEN
      x_return_status := 'E';
      FND_MESSAGE.SET_NAME('GR',
                           'GR_RECORD_NOT_FOUND');
      FND_MESSAGE.SET_TOKEN('CODE',
                            p_main_heading_code,
		      				FALSE);
      l_msg_data := l_msg_data || FND_MESSAGE.Get || ' ';
   END IF;
   CLOSE c_get_main_heading;

/*   Check the sub heading code */

   IF p_sub_heading_code IS NOT NULL THEN
      OPEN c_get_sub_heading;
      FETCH c_get_sub_heading INTO SubHdgRcd;
      IF c_get_sub_heading%NOTFOUND THEN
         x_return_status := 'E';
	     FND_MESSAGE.SET_NAME('GR',
	                          'GR_RECORD_NOT_FOUND');
	     FND_MESSAGE.SET_TOKEN('CODE',
	                           p_sub_heading_code,
			   				   FALSE);
	     l_msg_data := l_msg_data || FND_MESSAGE.Get || ' ';
	  END IF;
      CLOSE c_get_sub_heading;
   END IF;

/*	Check the phrase group code */

   IF p_phrase_group_code IS NOT NULL THEN
      l_key_exists := 'T';
      GR_PHRASE_GROUP_CODES_PKG.Check_Primary_Key
				(p_phrase_group_code,
				 'F',
				 l_rowid,
				 l_key_exists);

      IF NOT FND_API.To_Boolean(l_key_exists) THEN
         x_return_status := 'E';
	     FND_MESSAGE.SET_NAME('GR',
	                          'GR_RECORD_NOT_FOUND');
	     FND_MESSAGE.SET_TOKEN('CODE',
	                           p_phrase_group_code,
	     				       FALSE);
	     l_msg_data := l_msg_data || FND_MESSAGE.Get || ' ';
	  END IF;
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
				  p_item_code IN VARCHAR2,
				  p_document_code IN VARCHAR2,
				  p_phrase_code IN VARCHAR2,
				  p_display_order IN NUMBER,
				  p_main_heading_code IN VARCHAR2,
				  p_sub_heading_code IN VARCHAR2,
				  p_print_size IN NUMBER,
				  p_print_font IN VARCHAR2,
				  p_phrase_group_code IN VARCHAR2,
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

/* 	 No integrity checking required */


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
**		  p_document_code is the document code to check.
**		  p_phrase_code is the phrase code,
**		  p_display_order is the order ofthe display
**		  p_called_by_form is 'T' if called by a form or 'F' if not.
**		  x_rowid is the row id of the record if found.
**		  x_key_exists is 'T' is the record is found, 'F' if not.
*/
		  		 	(p_item_code IN VARCHAR2,
					 p_document_code IN VARCHAR2,
					 p_phrase_code IN VARCHAR2,
					 p_display_order IN NUMBER,
					 p_called_by_form IN VARCHAR2,
					 x_rowid OUT NOCOPY VARCHAR2,
					 x_key_exists OUT NOCOPY VARCHAR2)
  IS
/*	Alphanumeric variables	 */

L_MSG_DATA VARCHAR2(80);

/*		Declare any variables and the cursor */


CURSOR c_get_item_doc_dtls_rowid
 IS
   SELECT idd.rowid
   FROM	  gr_item_document_dtls idd
   WHERE  idd.item_code = p_item_code
   AND	  idd.document_code = p_document_code
   AND	  idd.phrase_code = p_phrase_code
   AND	  idd.display_order = p_display_order;
ItemDocDtlRecord			   c_get_item_doc_dtls_rowid%ROWTYPE;

BEGIN

   x_key_exists := 'F';
   l_msg_data := p_item_code || ' ' || p_document_code || ' ' || p_phrase_code;
   OPEN c_get_item_doc_dtls_rowid;
   FETCH c_get_item_doc_dtls_rowid INTO ItemDocDtlRecord;
   IF c_get_item_doc_dtls_rowid%FOUND THEN
      x_key_exists := 'T';
	  x_rowid := ItemDocDtlRecord.rowid;
   ELSE
      x_key_exists := 'F';
   END IF;
   CLOSE c_get_item_doc_dtls_rowid;

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

END GR_ITEM_DOCUMENT_DTLS_PKG;

/
