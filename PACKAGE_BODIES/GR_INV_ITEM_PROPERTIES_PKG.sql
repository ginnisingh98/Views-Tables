--------------------------------------------------------
--  DDL for Package Body GR_INV_ITEM_PROPERTIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GR_INV_ITEM_PROPERTIES_PKG" AS
/*$Header: GRHIIIPB.pls 120.1 2005/08/05 08:57:13 schandru noship $*/
PROCEDURE Insert_Row
	   			 (p_commit             IN VARCHAR2,
				  p_called_by_form     IN VARCHAR2,
                                  p_organization_id    IN NUMBER,
                                  p_inventory_item_id  IN NUMBER,
				  p_sequence_number    IN NUMBER,
				  p_property_id        IN VARCHAR2,
				  p_label_code         IN VARCHAR2,
				  p_number_value       IN NUMBER,
				  p_alpha_value        IN VARCHAR2,
				  p_date_value         IN DATE,
				  p_created_by         IN NUMBER,
				  p_creation_date      IN DATE,
				  p_last_updated_by    IN NUMBER,
				  p_last_update_date   IN DATE,
				  p_last_update_login  IN NUMBER,
				  x_rowid             OUT NOCOPY VARCHAR2,
				  x_return_status     OUT NOCOPY VARCHAR2,
				  x_oracle_error      OUT NOCOPY NUMBER,
				  x_msg_data          OUT NOCOPY VARCHAR2)
	IS
/*   Alpha Variables */

L_RETURN_STATUS VARCHAR2(1) := 'S';
L_KEY_EXISTS 	VARCHAR2(1);
L_MSG_DATA 	VARCHAR2(2000);
L_ROWID 	VARCHAR2(18);
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
			         (p_organization_id,
			          p_inventory_item_id,
				  p_sequence_number,
				  p_property_id,
			          p_label_code,
				  p_number_value,
				  p_alpha_value,
				  p_date_value,
				  l_return_status,
				  l_oracle_error,
				  l_msg_data);
   IF l_return_status <> 'S' THEN
      RAISE Foreign_Key_Error;
   END IF;

/* 	   Now check the primary key doesn't already exist */

   Check_Primary_Key
   	   	   		 (p_organization_id,
   	   	   		  p_inventory_item_id,
   	   	   		  p_label_code,
				  p_property_id,
				  'F',
				  l_rowid,
				  l_key_exists);

   IF FND_API.To_Boolean(l_key_exists) THEN
   	  RAISE Item_Exists_Error;
   END IF;
   INSERT INTO gr_inv_item_properties
   		  	         (organization_id,
   		  	          inventory_item_id,
				  sequence_number,
				  property_id,
   		  	          label_code,
				  number_value,
				  alpha_value,
				  date_value,
				  created_by,
				  creation_date,
				  last_updated_by,
				  last_update_date,
				  last_update_login)
          VALUES
		                 (p_organization_id,
		                  p_inventory_item_id,
				  p_sequence_number,
				  p_property_id,
		                  p_label_code,
				  p_number_value,
				  p_alpha_value,
				  p_date_value,
				  p_created_by,
				  p_creation_date,
				  p_last_updated_by,
				  p_last_update_date,
				  p_last_update_login);

/*   Now get the row id of the inserted record */

   Check_Primary_Key
   	   	   		 (p_organization_id,
   	   	   		  p_inventory_item_id,
   	   	   		  p_label_code,
				  p_property_id,
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
	  l_msg_token := p_organization_id || ' ' || p_inventory_item_id || ' ' || p_label_code || ' ' || p_property_id;
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
	  l_msg_token := p_organization_id || ' ' || p_inventory_item_id || ' ' || p_label_code || ' ' || p_property_id;
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
	  l_msg_token := p_organization_id || ' ' || p_inventory_item_id || ' ' || p_label_code || ' ' || p_property_id;
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
	   			 (p_commit             IN VARCHAR2,
				  p_called_by_form     IN VARCHAR2,
				  p_rowid              IN VARCHAR2,
                                  p_organization_id    IN NUMBER,
                                  p_inventory_item_id  IN NUMBER,
				  p_sequence_number    IN NUMBER,
				  p_property_id        IN VARCHAR2,
				  p_label_code         IN VARCHAR2,
				  p_number_value       IN NUMBER,
				  p_alpha_value        IN VARCHAR2,
				  p_date_value         IN DATE,
				  p_created_by         IN NUMBER,
				  p_creation_date      IN DATE,
				  p_last_updated_by    IN NUMBER,
				  p_last_update_date   IN DATE,
				  p_last_update_login  IN NUMBER,
				  x_return_status     OUT NOCOPY VARCHAR2,
				  x_oracle_error      OUT NOCOPY NUMBER,
				  x_msg_data          OUT NOCOPY VARCHAR2)
   IS

/*   Alpha Variables */

L_RETURN_STATUS	  VARCHAR2(1) := 'S';
L_MSG_DATA		  VARCHAR2(2000);
L_MSG_TOKEN		  VARCHAR2(100);

/*   Number Variables */

L_ORACLE_ERROR	  NUMBER;
l_count 	number := 0;

/*   Exceptions */

FOREIGN_KEY_ERROR EXCEPTION;
ROW_MISSING_ERROR EXCEPTION;

BEGIN

/*       Initialization Routine */

   SAVEPOINT Update_Row;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;
   l_msg_token := p_organization_id || ' ' || p_inventory_item_id || ' ' || p_label_code || ' ' || p_property_id;


/*	  Now call the check foreign key procedure */

   Check_Foreign_Keys
			     (p_organization_id,
			      p_inventory_item_id,
			      p_sequence_number,
			      p_property_id,
			      p_label_code,
			      p_number_value,
			      p_alpha_value,
			      p_date_value,
			      l_return_status,
			      l_oracle_error,
			      l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Foreign_Key_Error;
   ELSE
	-- Bug 4510201 Start
	select count(*) into l_count from gr_inv_item_properties where rowid = p_rowid;
	-- Bug 4510201 End
      UPDATE gr_inv_item_properties
	  SET	 organization_id                 = p_organization_id,
	         inventory_item_id				 = p_inventory_item_id,
	         sequence_number				 = p_sequence_number,
			 property_id					 = p_property_id,
	  		 label_code		 	 	 	 	 = p_label_code,
	  		 number_value					 = p_number_value,
			 alpha_value				 	 = p_alpha_value,
			 date_value					 	 = p_date_value,
                  -- Bug 4510201 Start
			 --created_by						 = p_created_by,
			 --creation_date					 = p_creation_date,
                  -- Bug 4510201 End
			 last_updated_by				 = p_last_updated_by,
			 last_update_date				 = p_last_update_date,
			 last_update_login				 = p_last_update_login
	  WHERE  rowid = p_rowid;
-- Bug 4510201 Start
	  --IF SQL%NOTFOUND THEN
	   IF l_count = 0 THEN
-- Bug 4510201 End
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
	   			 (p_commit             IN VARCHAR2,
				  p_called_by_form     IN VARCHAR2,
				  p_rowid              IN VARCHAR2,
                                  p_organization_id    IN NUMBER,
                                  p_inventory_item_id  IN NUMBER,
				  p_sequence_number    IN NUMBER,
				  p_property_id        IN VARCHAR2,
				  p_label_code         IN VARCHAR2,
				  p_number_value       IN NUMBER,
				  p_alpha_value        IN VARCHAR2,
				  p_date_value         IN DATE,
				  p_created_by         IN NUMBER,
				  p_creation_date      IN DATE,
				  p_last_updated_by    IN NUMBER,
				  p_last_update_date   IN DATE,
				  p_last_update_login  IN NUMBER,
				  x_return_status     OUT NOCOPY VARCHAR2,
				  x_oracle_error      OUT NOCOPY NUMBER,
				  x_msg_data          OUT NOCOPY VARCHAR2)
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

CURSOR c_lock_item_properties
 IS
   SELECT	*
   FROM		gr_inv_item_properties
   WHERE	rowid = p_rowid
   FOR UPDATE NOWAIT;
LockItemPropRcd	  c_lock_item_properties%ROWTYPE;

BEGIN

/*      Initialization Routine */

   SAVEPOINT Lock_Row;
   x_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;
   l_msg_token := p_organization_id || ' ' || p_inventory_item_id || ' ' || p_label_code || ' ' || p_property_id;

/*	   Now lock the record */

   OPEN c_lock_item_properties;
   FETCH c_lock_item_properties INTO LockItemPropRcd;
   IF c_lock_item_properties%NOTFOUND THEN
	  CLOSE c_lock_item_properties;
	  RAISE No_Data_Found_Error;
   END IF;
   CLOSE c_lock_item_properties;

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
	   			 (p_commit            IN VARCHAR2,
				  p_called_by_form    IN VARCHAR2,
				  p_rowid             IN VARCHAR2,
				  p_organization_id   IN NUMBER,
				  p_inventory_item_id IN NUMBER,
				  p_sequence_number   IN NUMBER,
				  p_property_id       IN VARCHAR2,
				  p_label_code        IN VARCHAR2,
				  p_number_value      IN NUMBER,
				  p_alpha_value       IN VARCHAR2,
				  p_date_value        IN DATE,
				  p_created_by        IN NUMBER,
				  p_creation_date     IN DATE,
				  p_last_updated_by   IN NUMBER,
				  p_last_update_date  IN DATE,
				  p_last_update_login IN NUMBER,
				  x_return_status    OUT NOCOPY VARCHAR2,
				  x_oracle_error     OUT NOCOPY NUMBER,
				  x_msg_data         OUT NOCOPY VARCHAR2)
   IS

/*   Alpha Variables */

L_RETURN_STATUS	  VARCHAR2(1) := 'S';
L_MSG_DATA	  VARCHAR2(2000);
L_MSG_TOKEN	  VARCHAR2(100);
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
   l_msg_token := p_organization_id || ' ' || p_inventory_item_id || ' ' || p_label_code || ' ' || p_property_id;

/*  Now call the check integrity procedure */
   Check_Integrity
			     (l_called_by_form,
			      p_organization_id,
			      p_inventory_item_id,
			      p_sequence_number,
			      p_property_id,
			      p_label_code,
			      p_number_value,
			      p_alpha_value,
			      p_date_value,
			      l_return_status,
			      l_oracle_error,
			      l_msg_data);

   IF l_return_status <> 'S' THEN
      RAISE Check_Integrity_Error;
   END IF;

   DELETE FROM gr_inv_item_properties
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
    (p_commit            IN VARCHAR2,
     p_called_by_form    IN VARCHAR2,
     p_delete_option     IN VARCHAR2,
     p_organization_id   IN NUMBER,
     p_inventory_item_id IN NUMBER,
     p_label_code        IN VARCHAR2,
     x_return_status    OUT NOCOPY VARCHAR2,
     x_oracle_error     OUT NOCOPY NUMBER,
     x_msg_data         OUT NOCOPY VARCHAR2)
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
**		p delete option has one of three values
**		'I' - Delete all rows for the specified item.
**		'L' - Delete all rows for the specified label.
**		'B' - Delete all rows using the item and label
**			  combination.
*/
   IF p_delete_option = 'I' THEN
      IF p_organization_id IS NULL AND p_inventory_item_id IS NULL THEN
	     l_msg_token := 'Organization ID' || ' Item Inventory Id';
	     RAISE Null_Delete_Option_Error;
	  ELSE
	     l_msg_token := p_organization_id || p_inventory_item_id;

         DELETE FROM  gr_inv_item_properties
         WHERE organization_id   = p_organization_id
		 AND   inventory_item_id = p_inventory_item_id;
   	  END IF;
   ELSIF p_delete_option = 'L' THEN
      IF p_label_code IS NULL THEN
	     l_msg_token := 'Label Code';
		 RAISE Null_Delete_Option_Error;
	  ELSE
	     l_msg_token := p_label_code;

         DELETE FROM	gr_inv_item_properties
         WHERE			label_code = p_label_code;
      END IF;
   ELSIF p_delete_option = 'B' THEN
      IF (p_organization_id IS NULL AND p_inventory_item_id IS NULL)  OR
	     (p_label_code IS NULL) THEN
		 l_msg_token := 'Organization ID, Item or Label Code';
		 RAISE Null_Delete_Option_Error;
	  ELSE
	     l_msg_token := p_organization_id || ' ' || p_inventory_item_id ||' ' || p_label_code;

		 DELETE FROM	gr_inv_item_properties
		 WHERE	organization_id   = p_organization_id
		 AND    inventory_item_id = p_inventory_item_id
		 AND	label_code        = p_label_code;
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
	   			 (p_organization_id   IN NUMBER,
				  p_inventory_item_id IN NUMBER,
				  p_sequence_number   IN NUMBER,
				  p_property_id       IN VARCHAR2,
	   			  p_label_code        IN VARCHAR2,
				  p_number_value      IN NUMBER,
				  p_alpha_value       IN VARCHAR2,
				  p_date_value        IN DATE,
				  x_return_status    OUT NOCOPY VARCHAR2,
				  x_oracle_error     OUT NOCOPY NUMBER,
				  x_msg_data         OUT NOCOPY VARCHAR2)
   IS

/*   Alpha Variables */

L_RETURN_STATUS	  VARCHAR2(1) := 'S';
L_MSG_DATA		  VARCHAR2(2000);
L_MSG_TOKEN       VARCHAR2(100);
L_ROWID			  VARCHAR2(18);
L_KEY_EXISTS	  VARCHAR2(1);

/*   Number Variables */

L_ORACLE_ERROR	  NUMBER;

/*	Error Definitions */

ROW_MISSING_ERROR	EXCEPTION;

/*	Cursors */
CURSOR get_item_details IS
SELECT organization_id, inventory_item_id
FROM   mtl_system_items_b
WHERE  organization_id   = p_organization_id
AND    inventory_item_id = p_inventory_item_id;

l_organization_id   mtl_system_items_b.organization_id%type;
l_inventory_item_id mtl_system_items_b.inventory_item_id%type;
BEGIN

/*   Initialization Routine */

   l_return_status := 'S';
   x_oracle_error := 0;
   x_msg_data := NULL;
   l_msg_token := NULL;
   l_organization_id  := NULL;
   l_inventory_item_id := NULL;

/*   Check the item code */

   OPEN get_item_details;
   FETCH get_item_details INTO l_organization_id, l_inventory_item_id;
   CLOSE get_item_details;

   IF l_organization_id IS NULL AND l_inventory_item_id IS NULL THEN
      l_return_status := 'E';
      l_msg_token := l_msg_token || ' ' || p_organization_id || ' ' || p_inventory_item_id;
   END IF;

/*	 Check the label code */

   GR_LABELS_B_PKG.Check_Primary_Key
					(p_label_code,
					 'F',
					 l_rowid,
					 l_key_exists);

   IF NOT FND_API.To_Boolean(l_key_exists) THEN
      l_return_status := 'E';
      l_msg_token := l_msg_token || ' ' || p_label_code;
   END IF;

/*   Check the property id */

   GR_PROPERTIES_B_PKG.Check_Primary_Key
					(p_property_id,
					 'F',
					 l_rowid,
					 l_key_exists);

   IF NOT FND_API.To_Boolean(l_key_exists) THEN
      l_return_status := 'E';
      l_msg_token := l_msg_token || ' ' || p_property_id;
   END IF;

   IF l_return_status <> 'S' THEN
      RAISE Row_Missing_Error;
   ELSE
      x_return_status := 'S';
   END IF;

EXCEPTION

   WHEN Row_Missing_Error THEN
	  x_return_status := 'E';
	  x_oracle_error := APP_EXCEPTION.Get_Code;
      FND_MESSAGE.SET_NAME('GR',
                           'GR_RECORD_NOT_FOUND');
      FND_MESSAGE.SET_TOKEN('CODE',
         		            l_msg_token,
            			    FALSE);
	  x_msg_data := FND_MESSAGE.Get;

   WHEN OTHERS THEN
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
	   			 (p_called_by_form    IN VARCHAR2,
	   			  p_organization_id   IN NUMBER,
	   			  p_inventory_item_id IN NUMBER,
				  p_sequence_number   IN NUMBER,
				  p_property_id       IN VARCHAR2,
	   			  p_label_code        IN VARCHAR2,
				  p_number_value      IN NUMBER,
				  p_alpha_value       IN VARCHAR2,
				  p_date_value        IN DATE,
				  x_return_status    OUT NOCOPY VARCHAR2,
				  x_oracle_error     OUT NOCOPY NUMBER,
				  x_msg_data         OUT NOCOPY VARCHAR2)
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
/*		  p_item_code is the item code
**		  p_label_code is the label code
**		  p_property_id is the property id
**		  p_called_by_form is 'T' if called by a form or 'F' if not.
**		  x_rowid is the row id of the record if found.
**		  x_key_exists is 'T' is the record is found, 'F' if not.
*/
		  		 	(
                                         p_organization_id   IN NUMBER,
                                         p_inventory_item_id IN NUMBER,
		  		 	 p_label_code        IN VARCHAR2,
					 p_property_id       IN VARCHAR2,
					 p_called_by_form    IN VARCHAR2,
					 x_rowid            OUT NOCOPY VARCHAR2,
					 x_key_exists       OUT NOCOPY VARCHAR2)
  IS
/*	Alphanumeric variables	 */

L_MSG_DATA VARCHAR2(100);

/*		Declare any variables and the cursor */


CURSOR c_get_item_properties_rowid
 IS
   SELECT ip.rowid
   FROM	  gr_inv_item_properties ip
   WHERE  ip.organization_id   = p_organization_id
   AND    ip.inventory_item_id = p_inventory_item_id
   AND	  ip.label_code        = p_label_code
   AND	  ip.property_id       = p_property_id;
ItemPropertyRecord	   c_get_item_properties_rowid%ROWTYPE;

BEGIN

   l_msg_data := p_organization_id || ' ' || p_inventory_item_id || ' ' || p_label_code || ' ' || p_property_id;

   x_key_exists := 'F';
   OPEN c_get_item_properties_rowid;
   FETCH c_get_item_properties_rowid INTO ItemPropertyRecord;
   IF c_get_item_properties_rowid%FOUND THEN
      x_key_exists := 'T';
	  x_rowid := ItemPropertyRecord.rowid;
   ELSE
      x_key_exists := 'F';
   END IF;
   CLOSE c_get_item_properties_rowid;

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

END GR_INV_ITEM_PROPERTIES_PKG;

/
