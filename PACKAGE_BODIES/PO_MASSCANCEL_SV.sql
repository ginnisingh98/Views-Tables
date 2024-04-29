--------------------------------------------------------
--  DDL for Package Body PO_MASSCANCEL_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_MASSCANCEL_SV" as
/* $Header: POXTIMCB.pls 115.0 99/07/17 02:05:02 porting ship $ */

/***************************************************************************
 *
 *	Procedure:	lock_row
 *
 *	Description:	LOCK_ROW table handler for the PO_MASSCANCEL_INTERIM
 * 			table.
 *
 **************************************************************************/

 PROCEDURE lock_row (x_rowid 		  	VARCHAR2,
		     x_default_cancel_flag	VARCHAR2)

 IS
   CURSOR C IS
        SELECT *
        FROM   PO_MASSCANCEL_INTERIM
        WHERE  rowid = x_rowid
        FOR UPDATE of default_cancel_flag NOWAIT;
    Recinfo C%ROWTYPE;

 BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    if (Recinfo.default_cancel_flag = x_default_cancel_flag) then
      return;
    else
      /* Not using the regular fnd message, since that tells the
       * user that he/she should requery. Here we are forcing the
       * the requery. This is required due to the fact that we are
       * using multiselect and that highlights/de-highlights the rec
       * irrespective of lock failure, even though the cancel flag is
       * not updated if the lock fails.
       */
      --FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
	fnd_message.set_name('PO', 'PO_ALL_LOCK_FAILED_REQUERYING');
      APP_EXCEPTION.RAISE_EXCEPTION;
    end if;
 END lock_row;


/***************************************************************************
 *
 *	Procedure:	update_row
 *
 *	Description:	UPDATE table handler for the PO_MASSCANCEL_INTERIM
 * 			table.
 *
 **************************************************************************/

  PROCEDURE update_row(x_rowid                 VARCHAR2,
                       x_last_update_date      DATE,
                       x_last_updated_by       NUMBER,
		       x_last_update_login     NUMBER,
		       x_default_cancel_flag   VARCHAR2)

   IS
 BEGIN
   UPDATE PO_MASSCANCEL_INTERIM
   SET		default_cancel_flag	=	x_default_cancel_flag,
		last_update_date 	=      	x_last_update_date,
              	last_updated_by		=	x_last_updated_by,
		last_update_login	=	x_last_update_login
   WHERE rowid = x_rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

  END update_row;


END PO_MASSCANCEL_SV;

/
