--------------------------------------------------------
--  DDL for Package Body GMI_XFER_MST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_XFER_MST_PKG" AS
/*$Header: GMIXFERB.pls 115.2 2002/10/25 14:51:37 jdiiorio noship $*/
/*
**
**
**
*/
  /*###############################################################
  # NAME
  #	insert_row
  # SYNOPSIS
  #	 proc insert_row
  # DESCRIPTION
  #      This particular procedure is used to insert the values into
  #      the ic_xfer_mst table.
  #################################################################*/

  PROCEDURE insert_row	 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_transfer_id	IN NUMBER,
				  p_transfer_no IN VARCHAR2,
				  p_transfer_batch IN VARCHAR2,
				  p_orgn_code IN VARCHAR2,
				  p_transfer_status IN VARCHAR2,
				  p_item_id IN NUMBER,
				  p_lot_id IN NUMBER,
				  p_lot_status IN VARCHAR2,
				  p_release_reason_code IN VARCHAR2,
                                  p_receive_reason_code IN VARCHAR2,
				  p_cancel_reason_code IN VARCHAR2,
				  p_from_warehouse IN VARCHAR2,
				  p_from_location IN VARCHAR2,
				  p_to_warehouse IN VARCHAR2,
				  p_to_location IN VARCHAR2,
				  p_release_quantity1 IN NUMBER,
				  p_release_quantity2 IN NUMBER,
				  p_release_uom1 IN VARCHAR2,
				  p_release_uom2 IN VARCHAR2,
				  p_receive_quantity1 IN NUMBER,
				  p_receive_quantity2 IN NUMBER,
				  p_scheduled_release_date IN DATE,
				  p_actual_release_date IN DATE,
				  p_scheduled_receive_date IN DATE,
				  p_actual_receive_date IN DATE,
				  p_cancel_date	IN DATE,
				  p_delete_mark IN NUMBER,
				  p_received_by IN NUMBER,
				  p_released_by IN NUMBER,
				  p_canceled_by IN NUMBER,
				  p_text_code IN NUMBER,
				  p_comments IN VARCHAR2,
				  p_attribute_category IN VARCHAR2,
				  p_attribute1 IN VARCHAR2,
				  p_attribute2 IN VARCHAR2,
				  p_attribute3 IN VARCHAR2,
				  p_attribute4 IN VARCHAR2,
				  p_attribute5 IN VARCHAR2,
				  p_attribute6 IN VARCHAR2,
				  p_attribute7 IN VARCHAR2,
				  p_attribute8 IN VARCHAR2,
				  p_attribute9 IN VARCHAR2,
				  p_attribute10 IN VARCHAR2,
				  p_attribute11 IN VARCHAR2,
				  p_attribute12 IN VARCHAR2,
				  p_attribute13 IN VARCHAR2,
				  p_attribute14 IN VARCHAR2,
				  p_attribute15 IN VARCHAR2,
				  p_attribute16 IN VARCHAR2,
				  p_attribute17 IN VARCHAR2,
				  p_attribute18 IN VARCHAR2,
				  p_attribute19 IN VARCHAR2,
				  p_attribute20 IN VARCHAR2,
				  p_attribute21 IN VARCHAR2,
				  p_attribute22 IN VARCHAR2,
				  p_attribute23 IN VARCHAR2,
				  p_attribute24 IN VARCHAR2,
				  p_attribute25 IN VARCHAR2,
				  p_attribute26 IN VARCHAR2,
				  p_attribute27 IN VARCHAR2,
				  p_attribute28 IN VARCHAR2,
				  p_attribute29 IN VARCHAR2,
				  p_attribute30 IN VARCHAR2,
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

  /*   Local Variables */

  l_return_status	VARCHAR2(1) := 'S';
  l_key_exists		VARCHAR2(1);
  l_msg_data		VARCHAR2(2000);
  l_rowid		VARCHAR2(18);

  l_oracle_error	NUMBER;

  /*   Exceptions */

  FOREIGN_KEY_ERROR 	EXCEPTION;
  TRANSFER_EXISTS_ERROR EXCEPTION;
  ROW_MISSING_ERROR 	EXCEPTION;

  /* Declare cursors */

  BEGIN

    /*     Initialization Routine */

    SAVEPOINT Insert_Row;
    x_return_status := 'S';
    x_oracle_error := 0;
    x_msg_data := NULL;

    /*	  Now call the check foreign key procedure */

    check_foreign_keys		 (p_orgn_code,
				  p_item_id,
				  p_lot_id,
				  p_lot_status,
				  p_release_reason_code,
				  p_receive_reason_code,
				  p_cancel_reason_code,
				  p_from_warehouse,
				  p_from_location,
				  p_to_warehouse,
				  p_to_location,
				  p_received_by,
				  p_released_by,
				  p_canceled_by,
				  l_return_status,
				  l_oracle_error,
				  l_msg_data);

    IF l_return_status <> 'S' THEN
      RAISE Foreign_Key_Error;
    END IF;

    /*  Now check the primary key doesn't already exist */

    Check_Primary_Key (p_orgn_code,
		       p_transfer_no,
  		       'F',
		       l_rowid,
		       l_key_exists);

    IF FND_API.To_Boolean(l_key_exists) THEN
      RAISE Transfer_Exists_Error;
    END IF;

    INSERT INTO ic_xfer_mst
				(transfer_id,
				 transfer_no,
				 transfer_batch,
				 orgn_code,
				 transfer_status,
				 item_id,
				 lot_id,
				 lot_status,
				 release_reason_code,
				 receive_reason_code,
				 cancel_reason_code,
				 from_warehouse,
				 from_location,
				 to_warehouse,
				 to_location,
				 release_quantity1,
				 release_quantity2,
                                 release_uom1,
				 release_uom2,
				 receive_quantity1,
				 receive_quantity2,
				 scheduled_release_date,
				 actual_release_date,
				 scheduled_receive_date,
				 actual_receive_date,
				 cancel_date,
				 delete_mark,
				 received_by,
				 released_by,
				 canceled_by,
				 text_code,
				 comments,
				 attribute_category ,
				 attribute1 ,
				 attribute2 ,
				 attribute3 ,
				 attribute4 ,
				 attribute5 ,
				 attribute6 ,
				 attribute7 ,
				 attribute8 ,
				 attribute9 ,
				 attribute10 ,
				 attribute11 ,
				 attribute12 ,
				 attribute13 ,
				 attribute14 ,
				 attribute15 ,
				 attribute16 ,
				 attribute17 ,
				 attribute18 ,
				 attribute19 ,
				 attribute20 ,
				 attribute21 ,
				 attribute22 ,
				 attribute23 ,
				 attribute24 ,
				 attribute25 ,
				 attribute26 ,
				 attribute27 ,
				 attribute28 ,
				 attribute29 ,
				 attribute30 ,
				 created_by ,
				 creation_date ,
				 last_updated_by ,
				 last_update_date ,
				 last_update_login)
    VALUES
				(p_transfer_id	,
				 p_transfer_no ,
				 p_transfer_batch ,
				 p_orgn_code ,
				 p_transfer_status ,
				 p_item_id ,
				 p_lot_id ,
				 p_lot_status ,
				 p_release_reason_code ,
                                 p_receive_reason_code ,
				 p_cancel_reason_code ,
				 p_from_warehouse ,
				 p_from_location ,
				 p_to_warehouse ,
				 p_to_location ,
				 p_release_quantity1 ,
				 p_release_quantity2 ,
				 p_release_uom1,
				 p_release_uom2,
				 p_receive_quantity1,
				 p_receive_quantity2,
				 p_scheduled_release_date ,
				 p_actual_release_date ,
				 p_scheduled_receive_date ,
				 p_actual_receive_date ,
				 p_cancel_date	,
				 p_delete_mark ,
				 p_received_by ,
				 p_released_by ,
				 p_canceled_by ,
				 p_text_code ,
				 p_comments ,
				 p_attribute_category ,
				 p_attribute1 ,
				 p_attribute2 ,
				 p_attribute3 ,
				 p_attribute4 ,
				 p_attribute5 ,
				 p_attribute6 ,
				 p_attribute7 ,
				 p_attribute8 ,
				 p_attribute9 ,
				 p_attribute10 ,
				 p_attribute11 ,
				 p_attribute12 ,
				 p_attribute13 ,
				 p_attribute14 ,
				 p_attribute15 ,
				 p_attribute16 ,
				 p_attribute17 ,
				 p_attribute18 ,
				 p_attribute19 ,
				 p_attribute20 ,
				 p_attribute21 ,
				 p_attribute22 ,
				 p_attribute23 ,
				 p_attribute24 ,
				 p_attribute25 ,
				 p_attribute26 ,
				 p_attribute27 ,
				 p_attribute28 ,
				 p_attribute29 ,
				 p_attribute30 ,
				 p_created_by ,
				 p_creation_date ,
				 p_last_updated_by ,
				 p_last_update_date ,
				 p_last_update_login);

    /*   Now get the row id of the inserted record */

    Check_Primary_Key
   	   	   		 (p_orgn_code,
				  p_transfer_no,
				  'F',
				  l_rowid,
				  l_key_exists);

    IF FND_API.To_Boolean(l_key_exists) THEN
      x_rowid := l_rowid;
    ELSE
      RAISE Row_Missing_Error;
    END IF;

    /* Check the commit flag and if set, then commit the work. */

    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;
  EXCEPTION
    WHEN Foreign_Key_Error THEN
      ROLLBACK TO SAVEPOINT Insert_Row;
      x_return_status := l_return_status;
      x_oracle_error := l_oracle_error;
      FND_MESSAGE.SET_NAME('GMI', 'IC_FOREIGN_KEY_ERROR');
      FND_MESSAGE.SET_TOKEN('TEXT', l_msg_data);
      IF FND_API.To_Boolean(p_called_by_form) THEN
        APP_EXCEPTION.Raise_Exception;
      ELSE
        x_msg_data := FND_MESSAGE.Get;
      END IF;
    WHEN Transfer_Exists_Error THEN
      ROLLBACK TO SAVEPOINT Insert_Row;
      x_return_status := 'E';
      x_oracle_error := l_oracle_error;
      FND_MESSAGE.SET_NAME('GMA', 'SY_DUPKEYINSERT');
      IF FND_API.To_Boolean(p_called_by_form) THEN
        APP_EXCEPTION.Raise_Exception;
      ELSE
        x_msg_data := FND_MESSAGE.Get;
      END IF;
    WHEN Row_Missing_Error THEN
      ROLLBACK TO SAVEPOINT Insert_Row;
      x_return_status := 'E';
      x_oracle_error := l_oracle_error;
      FND_MESSAGE.SET_NAME('GMI', 'IC_NO_RECORD_INSERTED');
      FND_MESSAGE.SET_TOKEN('CODE', p_orgn_code||' '||p_transfer_no);
      IF FND_API.To_Boolean(p_called_by_form) THEN
         APP_EXCEPTION.Raise_Exception;
      ELSE
        x_msg_data := FND_MESSAGE.Get;
      END IF;
    WHEN OTHERS THEN
      ROLLBACK TO SAVEPOINT Insert_Row;
      x_return_status := 'U';
      x_oracle_error := l_oracle_error;
      l_msg_data := sqlerrm;
      FND_MESSAGE.SET_NAME('GMI', 'IC_UNEXPECTED_ERROR');
      FND_MESSAGE.SET_TOKEN('TEXT', l_msg_data);
      IF FND_API.To_Boolean(p_called_by_form) THEN
         APP_EXCEPTION.Raise_Exception;
      ELSE
        x_msg_data := FND_MESSAGE.Get;
      END IF;
  END Insert_Row;

  /*###############################################################
  # NAME
  #	update_row
  # SYNOPSIS
  #	 proc update_row
  # DESCRIPTION
  #      This particular procedure is used to update the values into
  #      the ic_xfer_mst table.
  #################################################################*/

  PROCEDURE update_row	 (p_commit IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  p_rowid IN VARCHAR2,
				  p_transfer_id	IN NUMBER,
				  p_transfer_no IN VARCHAR2,
				  p_transfer_batch IN VARCHAR2,
				  p_orgn_code IN VARCHAR2,
				  p_transfer_status IN VARCHAR2,
				  p_item_id IN NUMBER,
				  p_lot_id IN NUMBER,
				  p_lot_status IN VARCHAR2,
				  p_release_reason_code IN VARCHAR2,
                                  p_receive_reason_code IN VARCHAR2,
				  p_cancel_reason_code IN VARCHAR2,
				  p_from_warehouse IN VARCHAR2,
				  p_from_location IN VARCHAR2,
				  p_to_warehouse IN VARCHAR2,
				  p_to_location IN VARCHAR2,
				  p_release_quantity1 IN NUMBER,
				  p_release_quantity2 IN NUMBER,
				  p_release_uom1 IN VARCHAR2,
				  p_release_uom2 IN VARCHAR2,
				  p_receive_quantity1 IN NUMBER,
				  p_receive_quantity2 IN NUMBER,
				  p_scheduled_release_date IN DATE,
				  p_actual_release_date IN DATE,
				  p_scheduled_receive_date IN DATE,
				  p_actual_receive_date IN DATE,
				  p_cancel_date	IN DATE,
				  p_delete_mark IN NUMBER,
				  p_received_by IN NUMBER,
				  p_released_by IN NUMBER,
				  p_canceled_by IN NUMBER,
				  p_text_code IN NUMBER,
				  p_comments IN VARCHAR2,
				  p_attribute_category IN VARCHAR2,
				  p_attribute1 IN VARCHAR2,
				  p_attribute2 IN VARCHAR2,
				  p_attribute3 IN VARCHAR2,
				  p_attribute4 IN VARCHAR2,
				  p_attribute5 IN VARCHAR2,
				  p_attribute6 IN VARCHAR2,
				  p_attribute7 IN VARCHAR2,
				  p_attribute8 IN VARCHAR2,
				  p_attribute9 IN VARCHAR2,
				  p_attribute10 IN VARCHAR2,
				  p_attribute11 IN VARCHAR2,
				  p_attribute12 IN VARCHAR2,
				  p_attribute13 IN VARCHAR2,
				  p_attribute14 IN VARCHAR2,
				  p_attribute15 IN VARCHAR2,
				  p_attribute16 IN VARCHAR2,
				  p_attribute17 IN VARCHAR2,
				  p_attribute18 IN VARCHAR2,
				  p_attribute19 IN VARCHAR2,
				  p_attribute20 IN VARCHAR2,
				  p_attribute21 IN VARCHAR2,
				  p_attribute22 IN VARCHAR2,
				  p_attribute23 IN VARCHAR2,
				  p_attribute24 IN VARCHAR2,
				  p_attribute25 IN VARCHAR2,
				  p_attribute26 IN VARCHAR2,
				  p_attribute27 IN VARCHAR2,
				  p_attribute28 IN VARCHAR2,
				  p_attribute29 IN VARCHAR2,
				  p_attribute30 IN VARCHAR2,
				  p_created_by IN NUMBER,
				  p_creation_date IN DATE,
				  p_last_updated_by IN NUMBER,
				  p_last_update_date IN DATE,
				  p_last_update_login IN NUMBER,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2)
  IS
    /*   Local Variables */

    l_return_status	VARCHAR2(1) := 'S';
    l_msg_data		VARCHAR2(2000);
    l_oracle_error	NUMBER;

    /*   Exceptions */

    FOREIGN_KEY_ERROR 	EXCEPTION;
    ROW_MISSING_ERROR 	EXCEPTION;

  BEGIN

    /*       Initialization Routine */

    SAVEPOINT Update_Row;
    X_return_status := 'S';
    X_oracle_error := 0;
    X_msg_data := NULL;

    /*	  Now call the check foreign key procedure */

    check_foreign_keys		 (p_orgn_code,
				  p_item_id,
				  p_lot_id,
				  p_lot_status,
				  p_release_reason_code,
				  p_receive_reason_code,
				  p_cancel_reason_code,
				  p_from_warehouse,
				  p_from_location,
				  p_to_warehouse,
				  p_to_location,
				  p_received_by,
				  p_released_by,
				  p_canceled_by,
				  l_return_status,
				  l_oracle_error,
				  l_msg_data);

    IF l_return_status <> 'S' THEN
      RAISE Foreign_Key_Error;
    END IF;

    UPDATE ic_xfer_mst
    SET				   transfer_status  		= p_transfer_status,
       				   transfer_batch   		= p_transfer_batch,
				   item_id  			= p_item_id,
				   lot_id  			= p_lot_id,
				   lot_status  			= p_lot_status,
				   release_reason_code  	= p_release_reason_code,
                                   receive_reason_code  	= p_receive_reason_code,
				   cancel_reason_code  		= p_cancel_reason_code,
				   from_warehouse  		= p_from_warehouse,
				   from_location  		= p_from_location,
				   to_warehouse  		= p_to_warehouse,
				   to_location  		= p_to_location,
				   release_quantity1  		= p_release_quantity1,
				   release_quantity2  		= p_release_quantity2,
				   release_uom1  		= p_release_uom1,
				   release_uom2  		= p_release_uom2,
				   receive_quantity1  		= p_receive_quantity1,
				   receive_quantity2  		= p_receive_quantity2,
				   scheduled_release_date  	= p_scheduled_release_date,
				   actual_release_date  	= p_actual_release_date,
				   scheduled_receive_date 	= p_scheduled_receive_date,
				   actual_receive_date  	= p_actual_receive_date,
				   cancel_date	 		= p_cancel_date,
				   delete_mark  		= p_delete_mark,
				   received_by  		= p_received_by,
				   released_by  		= p_released_by,
				   canceled_by  		= p_canceled_by,
				   text_code  			= p_text_code,
				   comments  			= p_comments,
				   attribute_category  		= p_attribute_category,
				   attribute1  			= p_attribute1,
				   attribute2  			= p_attribute2,
				   attribute3  			= p_attribute3,
				   attribute4  			= p_attribute4,
				   attribute5  			= p_attribute5,
				   attribute6  			= p_attribute6,
				   attribute7  			= p_attribute7,
				   attribute8  			= p_attribute8,
				   attribute9  			= p_attribute9,
				   attribute10  		= p_attribute10,
				   attribute11  		= p_attribute11,
				   attribute12  		= p_attribute12,
				   attribute13  		= p_attribute13,
				   attribute14  		= p_attribute14,
				   attribute15  		= p_attribute15,
				   attribute16  		= p_attribute16,
				   attribute17  		= p_attribute17,
				   attribute18  		= p_attribute18,
				   attribute19  		= p_attribute19,
				   attribute20  		= p_attribute20,
				   attribute21  		= p_attribute21,
				   attribute22  		= p_attribute22,
				   attribute23  		= p_attribute23,
				   attribute24  		= p_attribute24,
				   attribute25  		= p_attribute25,
				   attribute26  		= p_attribute26,
				   attribute27  		= p_attribute27,
				   attribute28  		= p_attribute28,
				   attribute29  		= p_attribute29,
				   attribute30  		= p_attribute30,
				   created_by  			= p_created_by,
				   creation_date 		= p_creation_date,
				   last_updated_by  		= p_last_updated_by,
				   last_update_date  		= p_last_update_date,
				   last_update_login  		= p_last_update_login
    WHERE			rowid = p_rowid;
    IF SQL%NOTFOUND THEN
      RAISE Row_Missing_Error;
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
      FND_MESSAGE.SET_NAME('GMI', 'IC_FOREIGN_KEY_ERROR');
      FND_MESSAGE.SET_TOKEN('TEXT', l_msg_data);
      IF FND_API.To_Boolean(p_called_by_form) THEN
        APP_EXCEPTION.Raise_Exception;
      ELSE
        x_msg_data := FND_MESSAGE.Get;
      END IF;
    WHEN Row_Missing_Error THEN
      ROLLBACK TO SAVEPOINT Update_Row;
      x_return_status := 'E';
      x_oracle_error := l_oracle_error;
      FND_MESSAGE.SET_NAME('GMI',
                           'IC_RECORD_MISSING');
      FND_MESSAGE.SET_TOKEN('CODE', p_transfer_no);
      IF FND_API.To_Boolean(p_called_by_form) THEN
        APP_EXCEPTION.Raise_Exception;
      ELSE
	x_msg_data := FND_MESSAGE.Get;
      END IF;
    WHEN OTHERS THEN
      ROLLBACK TO SAVEPOINT Update_Row;
      x_return_status := 'U';
      x_oracle_error := l_oracle_error;
      l_msg_data := sqlerrm;
      FND_MESSAGE.SET_NAME('GMI', 'IC_UNEXPECTED_ERROR');
      FND_MESSAGE.SET_TOKEN('TEXT', l_msg_data);
      IF FND_API.To_Boolean(p_called_by_form) THEN
         APP_EXCEPTION.Raise_Exception;
      ELSE
        x_msg_data := FND_MESSAGE.Get;
      END IF;
  END Update_Row;

  /*###############################################################
  # NAME
  #	lock_row
  # SYNOPSIS
  #	 proc lock_row
  # DESCRIPTION
  #      This particular procedure is used to lock the corresponding
  #      row in the ic_xfer_mst table.
  #################################################################*/

  PROCEDURE Lock_Row	 (p_called_by_form IN VARCHAR2,
				  p_rowid IN VARCHAR2,
				  p_last_update_date IN DATE,
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

    CURSOR c_lock_transfer IS
      SELECT	last_update_date
      FROM	ic_xfer_mst
      WHERE	rowid = p_rowid
      FOR UPDATE OF last_update_date NOWAIT;

    LockTransferRcd	  c_lock_transfer%ROWTYPE;

  BEGIN

    /*      Initialization Routine */

    SAVEPOINT Lock_Row;
    X_return_status := 'S';
    X_oracle_error := 0;
    X_msg_data := NULL;

    /*	   Now lock the record */

    OPEN c_lock_transfer;
    FETCH c_lock_transfer INTO LockTransferRcd;
    IF c_lock_transfer%NOTFOUND THEN
      CLOSE c_lock_transfer;
      RAISE No_Data_Found_Error;
    END IF;
    CLOSE c_lock_transfer;

    IF LockTransferRcd.last_update_date <> p_last_update_date THEN
      RAISE RECORD_CHANGED_ERROR;
    END IF;
  EXCEPTION
    WHEN No_Data_Found_Error THEN
      ROLLBACK TO SAVEPOINT Lock_Row;
      X_return_status := 'E';
      FND_MESSAGE.SET_NAME('GMI', 'IC_RECORD_NOT_FOUND');
      FND_MESSAGE.SET_TOKEN('CODE',p_rowid,FALSE);
      IF FND_API.To_Boolean(p_called_by_form) THEN
        APP_EXCEPTION.Raise_Exception;
      ELSE
        X_msg_data := FND_MESSAGE.Get;
      END IF;
    WHEN RECORD_CHANGED_ERROR THEN
      ROLLBACK TO SAVEPOINT Lock_Row;
      X_return_status := 'E';
      FND_MESSAGE.SET_NAME('FND','FORM_RECORD_CHANGED');
      IF FND_API.To_Boolean(p_called_by_form) THEN
        APP_EXCEPTION.Raise_Exception;
      ELSE
        X_msg_data := FND_MESSAGE.Get;
      END IF;
    WHEN APP_EXCEPTION.RECORD_LOCK_EXCEPTION THEN
      ROLLBACK TO SAVEPOINT Lock_Row;
      X_return_status := 'L';
      X_oracle_error := APP_EXCEPTION.Get_Code;
      IF NOT (FND_API.To_Boolean(p_called_by_form)) THEN
        FND_MESSAGE.SET_NAME('GMI', 'IC_ROW_IS_LOCKED');
        X_msg_data := FND_MESSAGE.Get;
      END IF;
    WHEN OTHERS THEN
      ROLLBACK TO SAVEPOINT Lock_Row;
      X_return_status := 'U';
      X_oracle_error := APP_EXCEPTION.Get_Code;
      l_msg_data := APP_EXCEPTION.Get_Text;
      FND_MESSAGE.SET_NAME('GMI', 'IC_UNEXPECTED_ERROR');
      FND_MESSAGE.SET_TOKEN('TEXT', l_msg_data);
      IF FND_API.To_Boolean(p_called_by_form) THEN
        APP_EXCEPTION.Raise_Exception;
      ELSE
	X_msg_data := FND_MESSAGE.Get;
      END IF;
  END Lock_Row;

  /*###############################################################
  # NAME
  #	check_foreign_keys
  # SYNOPSIS
  #	 proc check_foreign_keys
  # DESCRIPTION
  #      This particular procedure is used to check the existense
  #      of the foreign keys in their parent table.
  #################################################################*/

  PROCEDURE check_foreign_keys
	   			 (p_orgn_code IN VARCHAR2,
				  p_item_id IN NUMBER,
				  p_lot_id IN NUMBER,
				  p_lot_status IN VARCHAR2,
				  p_release_reason_code IN VARCHAR2,
				  p_receive_reason_code IN VARCHAR2,
				  p_cancel_reason_code IN VARCHAR2,
				  p_from_warehouse IN VARCHAR2,
				  p_from_location IN VARCHAR2,
				  p_to_warehouse IN VARCHAR2,
				  p_to_location IN VARCHAR2,
				  p_received_by IN NUMBER,
				  p_released_by IN NUMBER,
				  p_canceled_by IN NUMBER,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_oracle_error OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2)
  IS

    /*   Local Variables */

    l_return_status	VARCHAR2(1) := 'S';
    l_msg_data		VARCHAR2(2000);
    l_rowid		VARCHAR2(18);
    l_key_exists	VARCHAR2(1);

    l_oracle_error	NUMBER;

    /*   Define the cursors */

    CURSOR Cur_get_orgn_code IS
      SELECT orgn_code
      FROM   sy_orgn_mst
      WHERE  orgn_code = p_orgn_code
             AND delete_mark = 0;
    OrgnRecord	Cur_get_orgn_code%ROWTYPE;

  BEGIN

    /*   Initialization Routine */

    SAVEPOINT check_foreign_keys;
    x_return_status := 'S';
    x_oracle_error := 0;
    x_msg_data := NULL;

    /*	Organization Code */

    IF p_orgn_code IS NOT NULL THEN
      OPEN Cur_get_orgn_code;
      FETCH Cur_get_orgn_code INTO OrgnRecord;
      IF Cur_get_orgn_code%NOTFOUND THEN
        x_return_status := 'E';
	FND_MESSAGE.SET_NAME('GMI', 'IC_RECORD_NOT_FOUND');
        FND_MESSAGE.SET_TOKEN('CODE', p_orgn_code);
        l_msg_data := l_msg_data || ' ' || FND_MESSAGE.Get;
      END IF;
      CLOSE Cur_get_orgn_code;
    END IF;


    IF x_return_status <> 'S' THEN
      x_msg_data := l_msg_data;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO SAVEPOINT check_foreign_keys;
      x_return_status := 'U';
      l_msg_data := sqlerrm;
      FND_MESSAGE.SET_NAME('GMI', 'IC_UNEXPECTED_ERROR');
      FND_MESSAGE.SET_TOKEN('TEXT', l_msg_data);
      x_msg_data := FND_MESSAGE.Get;
  END check_foreign_keys;

  /*###############################################################
  # NAME
  #	check_primary_key
  # SYNOPSIS
  #	proc check_primary_key
  # DESCRIPTION
  #     This particular procedure is used to check the existense
  #     of the primary key in the table.
  #################################################################*/

  PROCEDURE check_primary_key
  /*		  p_transfer_no is the transfer number to check.
  **		  p_called_by_form is 'T' if called by a form or 'F' if not.
  **		  x_rowid is the row id of the record if found.
  **		  x_key_exists is 'T' is the record is found, 'F' if not.
  */
		  		 	(p_orgn_code IN VARCHAR2,
					 p_transfer_no IN VARCHAR2,
					 p_called_by_form IN VARCHAR2,
					 x_rowid OUT NOCOPY VARCHAR2,
					 x_key_exists OUT NOCOPY VARCHAR2)
  IS
    /*	Local variables	 */

    l_msg_data	VARCHAR2(80);

    /*	Declare any variables and the cursor */

    CURSOR Cur_get_transfer_rowid IS
      SELECT rowid
      FROM   ic_xfer_mst
      WHERE  transfer_no = p_transfer_no
             AND orgn_code = p_orgn_code;

    TransferRecord	Cur_get_transfer_rowid%ROWTYPE;

  BEGIN
    x_key_exists := 'F';
    l_msg_data := p_orgn_code||' '||p_transfer_no;

    OPEN Cur_get_transfer_rowid;
    FETCH Cur_get_transfer_rowid INTO TransferRecord;
    IF Cur_get_transfer_rowid%FOUND THEN
      x_key_exists := 'T';
      x_rowid := TransferRecord.rowid;
    ELSE
      x_key_exists := 'F';
    END IF;
    CLOSE Cur_get_transfer_rowid;

  EXCEPTION
    WHEN Others THEN
      l_msg_data := sqlerrm;
      FND_MESSAGE.SET_NAME('GMI', 'IC_UNEXPECTED_ERROR');
      FND_MESSAGE.SET_TOKEN('TEXT',l_msg_data);
      IF FND_API.To_Boolean(p_called_by_form) THEN
        APP_EXCEPTION.Raise_Exception;
      END IF;
  END Check_Primary_Key;

END GMI_XFER_MST_PKG;

/
