--------------------------------------------------------
--  DDL for Package Body PO_FORWARD_SV1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_FORWARD_SV1" AS
/* $Header: POXAPFOB.pls 120.1.12010000.2 2012/01/09 10:23:04 venuthot ship $*/
/*===========================================================================

  PROCEDURE NAME:       test_insert_action_history

===========================================================================*/

  PROCEDURE test_insert_action_history (x_object_id		IN  NUMBER,
        			   x_object_type_code		IN  VARCHAR2,
        			   x_object_sub_type_code	IN  VARCHAR2,
				   x_sequence_num		IN  NUMBER,
				   x_action_code		IN  VARCHAR2,
				   x_action_date		IN  DATE,
				   x_employee_id    		IN  NUMBER,
				   x_approval_path_id		IN  NUMBER,
				   x_note			IN  VARCHAR2,
				   x_object_revision_num	IN  NUMBER,
 				   x_offline_code		IN  VARCHAR2,
        			   x_request_id			IN  NUMBER,
        			   x_program_application_id	IN  NUMBER,
        			   x_program_id			IN  NUMBER,
        			   x_program_date		IN  DATE,
				   x_user_id			IN  NUMBER,
				   x_login_id			IN  NUMBER) IS
    BEGIN

    --dbms_output.put_line('before call');

    insert_action_history (x_object_id,
        			   x_object_type_code,
        			   x_object_sub_type_code,
				   x_sequence_num,
				   x_action_code,
				   x_action_date,
				   x_employee_id,
				   x_approval_path_id,
				   x_note,
				   x_object_revision_num,
 				   x_offline_code,
        			   x_request_id,
        			   x_program_application_id,
        			   x_program_id,
        			   x_program_date,
				   x_user_id,
				   x_login_id);

    --dbms_output.put_line('after call');

  END;

/*===========================================================================

  PROCEDURE NAME:	insert_action_history

===========================================================================*/

PROCEDURE insert_action_history (x_object_id			IN  NUMBER,
        			   x_object_type_code		IN  VARCHAR2,
        			   x_object_sub_type_code	IN  VARCHAR2,
				   x_sequence_num		IN  NUMBER,
				   x_action_code		IN  VARCHAR2,
				   x_action_date		IN  DATE,
				   x_employee_id    		IN  NUMBER,
				   x_approval_path_id		IN  NUMBER,
				   x_note			IN  VARCHAR2,
				   x_object_revision_num	IN  NUMBER,
 				   x_offline_code		IN  VARCHAR2,
        			   x_request_id			IN  NUMBER,
        			   x_program_application_id	IN  NUMBER,
        			   x_program_id			IN  NUMBER,
        			   x_program_date		IN  DATE,
				   x_user_id			IN  NUMBER,
				   x_login_id			IN  NUMBER,
                                   x_approval_group_id          IN  NUMBER)
IS
	x_progress	     VARCHAR2(3) := '';
        x_db_sequence_num    PO_ACTION_HISTORY.sequence_num%TYPE := NULL;

BEGIN

   x_db_sequence_num := x_sequence_num;

   IF x_db_sequence_num is NULL THEN

      --<ENCUMBRANCE FPJ START>

      x_progress := '010';

      SELECT MAX(sequence_num)
      INTO  x_db_sequence_num
      FROM  PO_ACTION_HISTORY
      WHERE object_id           = x_object_id
      AND   object_type_code    = x_object_type_code;

      x_progress := '020';

      IF (x_db_sequence_num IS NULL) THEN
         x_progress := '030';
         -- The action history sequence_num starts at 1.
         x_db_sequence_num := 1; -- Bug 13370924
      ELSE
         x_progress := '040';
         -- Use the next sequence num.
         x_db_sequence_num := x_db_sequence_num + 1;
      END IF;

      x_progress := '050';

      --<ENCUMBRANCE FPJ END>

    END IF;

    x_progress := '100';

    --dbms_output.put_line('Before insert');

    INSERT INTO PO_ACTION_HISTORY
        	(object_id,
        	object_type_code,
        	object_sub_type_code,
        	sequence_num,
        	last_update_date,
        	last_updated_by,
        	employee_id,
        	action_code,
		action_date,
        	note,
        	object_revision_num,
        	last_update_login,
        	creation_date,
        	created_by,
        	request_id,
        	program_application_id,
        	program_id,
        	program_date,
        	approval_path_id,
        	offline_code,
        	program_update_date,
                approval_group_id)
    VALUES (x_object_id,
        	x_object_type_code,
        	x_object_sub_type_code,
        	x_db_sequence_num,
        	sysdate,
        	x_user_id,
        	x_employee_id,
        	x_action_code,
		x_action_date,
        	x_note,
        	x_object_revision_num,
        	x_login_id,
        	sysdate,
        	x_user_id,
        	x_request_id,
        	x_program_application_id,
        	x_program_id,
        	x_program_date,
        	x_approval_path_id,
        	x_offline_code,
        	sysdate,
                x_approval_group_id);

     --dbms_output.put_line('After insert');

EXCEPTION
    WHEN OTHERS THEN
	--dbms_output.put_line('Exception in insert_action_history');
	PO_MESSAGE_S.SQL_ERROR('INSERT_ACTION_HISTORY', x_progress, sqlcode);
	RAISE;
END;


PROCEDURE insert_action_history( x_object_id            IN  NUMBER,
                                 x_object_type_code     IN  VARCHAR2,
                                 x_object_sub_type_code	IN  VARCHAR2,
                                 x_sequence_num         IN  NUMBER,
                                 x_action_code          IN  VARCHAR2,
                                 x_action_date          IN  DATE,
                                 x_employee_id          IN  NUMBER,
                                 x_approval_path_id     IN  NUMBER,
                                 x_note                 IN  VARCHAR2,
                                 x_object_revision_num  IN  NUMBER,
                                 x_offline_code         IN  VARCHAR2,
                                 x_request_id           IN  NUMBER,
                                 x_program_application_id       IN  NUMBER,
                                 x_program_id           IN  NUMBER,
                                 x_program_date         IN  DATE,
                                 x_user_id              IN  NUMBER,
                                 x_login_id             IN  NUMBER)
IS

BEGIN

        -- invoke the wrapper procedure insert_action_history with one more additional input parameter.
        -- We pass NULL value for the new column approval_group_id.
        insert_action_history( x_object_id,
                               x_object_type_code,
                               x_object_sub_type_code,
                               x_sequence_num,
                               x_action_code,
                               x_action_date,
                               x_employee_id,
                               x_approval_path_id,
                               x_note,
                               x_object_revision_num,
                               x_offline_code,
                               x_request_id,
                               x_program_application_id,
                               x_program_id,
                               x_program_date,
                               x_user_id,
                               x_login_id,
                               NULL);

END;

/*===========================================================================

  PROCEDURE NAME:       test_insert_all_action_history

===========================================================================*/

  PROCEDURE test_insert_all_action_history (x_old_employee_id  IN NUMBER,
				            x_new_employee_id  IN NUMBER,
			                    x_offline_code     IN VARCHAR2,
					    x_user_id	       IN NUMBER,
					    x_login_id	       IN NUMBER) IS
    BEGIN

    --dbms_output.put_line('before call');

    insert_all_action_history (x_old_employee_id,
				     x_new_employee_id,
			             x_offline_code,
				     x_user_id,
				     x_login_id);

    --dbms_output.put_line('after call');

  END;

/*===========================================================================

  PROCEDURE NAME:	insert_all_action_history

===========================================================================*/

PROCEDURE insert_all_action_history (x_old_employee_id  IN NUMBER,
				     x_new_employee_id  IN NUMBER,
			             x_offline_code     IN VARCHAR2,
				     x_user_id		IN NUMBER,
				     x_login_id		IN NUMBER)
IS
	x_progress	VARCHAR2(3) := '';
BEGIN

    x_progress := '010';

    IF (x_old_employee_id IS NOT NULL AND
	x_new_employee_id IS NOT NULL) THEN

	x_progress := '020';
        --dbms_output.put_line('Before Insert');

        INSERT INTO PO_ACTION_HISTORY
       		(object_id,
        	object_type_code,
        	object_sub_type_code,
        	sequence_num,
        	last_update_date,
        	last_updated_by,
        	action_date,
        	employee_id,
        	action_code,
        	note,
        	object_revision_num,
        	last_update_login,
        	creation_date,
        	created_by,
        	request_id,
        	program_application_id,
        	program_id,
        	program_date,
        	approval_path_id,
        	offline_code,
        	program_update_date)
    	SELECT  object_id,
        	object_type_code,
        	object_sub_type_code,
        	sequence_num + 1,
        	sysdate,
        	x_user_id,
        	NULL,
        	x_new_employee_id,
        	NULL,
        	NULL,
        	object_revision_num,
        	x_login_id,
        	sysdate,
        	x_user_id,
        	request_id,
        	program_application_id,
        	program_id,
        	sysdate,
        	approval_path_id,
        	x_offline_code,
        	sysdate
    	FROM    PO_ACTION_HISTORY
    	WHERE   employee_id = x_old_employee_id
    	AND     action_code IS NULL;

        --dbms_output.put_line('After Insert');

    ELSE
	x_progress := '030';
	PO_MESSAGE_S.SQL_ERROR('INSERT_ALL_ACTION_HISTORY', x_progress, sqlcode);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
	--dbms_output.put_line('In Exception');
	PO_MESSAGE_S.SQL_ERROR('INSERT_ALL_ACTION_HISTORY', x_progress, sqlcode);
	RAISE;
END;

/*===========================================================================

  PROCEDURE NAME:       test_update_action_history

===========================================================================*/

/*  PROCEDURE test_update_action_history (x_object_id		IN NUMBER,
			x_object_type_code	IN VARCHAR2,
			x_old_employee_id	IN NUMBER,
                        x_action_code           IN VARCHAR2,
			x_note			IN VARCHAR2,
			x_user_id		IN NUMBER,
			x_login_id		IN NUMBER) IS
    BEGIN

    --dbms_output.put_line('before call');

    update_action_history (x_object_id,
			x_object_type_code,
			x_old_employee_id,
                        x_action_code,
			x_note,
			x_user_id,
			x_login_id);

    --dbms_output.put_line('after call');

  END;
*/
/*===========================================================================

  PROCEDURE NAME:	update_action_history

===========================================================================*/

PROCEDURE update_action_history (x_object_id		IN NUMBER,
				 x_object_type_code	IN VARCHAR2,
				 x_old_employee_id	IN NUMBER,
                                 x_action_code          IN VARCHAR2,
				 x_note			IN VARCHAR2,
				 x_user_id		IN NUMBER,
				 x_login_id		IN NUMBER)
IS
	x_progress	VARCHAR2(3) := '';
        x_employee_id   NUMBER ;

BEGIN
    x_progress := '010';

    IF (x_object_id IS NOT NULL AND
	x_object_type_code IS NOT NULL) THEN

	x_progress := '020';
       -- dbms_output.put_line('Before Update');

/* Bug# 1326148: Amitabh
** Desc: The update_action_history() procedure has been modified to update t he
** employee_id also in the action history. Employee id should belong to the
** id of the corresponding user taking the action, not the employee id to
** which the req was forwarded to.
*/
        If (x_old_employee_id is NULL) then
                SELECT HR.EMPLOYEE_ID
                INTO   x_employee_id
                FROM   FND_USER FND, HR_EMPLOYEES_CURRENT_V HR
                WHERE  FND.USER_ID = NVL(x_user_id, fnd_global.user_id)
                AND    FND.EMPLOYEE_ID = HR.EMPLOYEE_ID;
        end if;

    	UPDATE PO_ACTION_HISTORY
    	SET     last_update_date = sysdate,
            	last_updated_by = x_user_id,
            	last_update_login = x_login_id,
                employee_id = NVL(x_employee_id, employee_id),
            	action_date = sysdate,
            	action_code = x_action_code,
            	note = x_note,
            	offline_code = decode(offline_code,
		  		'PRINTED', 'PRINTED', NULL)
    	WHERE   employee_id = NVL(x_old_employee_id, employee_id)
	AND	object_id = x_object_id
	AND	object_type_code = x_object_type_code
    	AND     action_code IS NULL;

    ELSE
	x_progress := '030';
	PO_MESSAGE_S.SQL_ERROR('UPDATE_ACTION_HISTORY', x_progress, sqlcode);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
	--dbms_output.put_line('Exception in update_action_history');
	PO_MESSAGE_S.SQL_ERROR('UPDATE_ACTION_HISTORY', x_progress, sqlcode);
	RAISE;
END;


/*===========================================================================

  PROCEDURE NAME:       test_update_all_action_history

===========================================================================*/

  PROCEDURE test_update_all_action_history (x_old_employee_id  IN NUMBER,
				     	    x_note		IN VARCHAR2,
					    x_user_id		IN NUMBER,
					    x_login_id		IN NUMBER) IS
    BEGIN

    --dbms_output.put_line('before call');

    update_all_action_history (x_old_employee_id,
				     x_note,
				     x_user_id,
				     x_login_id);

    --dbms_output.put_line('after call');

  END;

/*===========================================================================

  PROCEDURE NAME:	update_all_action_history

===========================================================================*/

PROCEDURE update_all_action_history (x_old_employee_id  IN NUMBER,
				     x_note		IN VARCHAR2,
				     x_user_id		IN NUMBER,
				     x_login_id		IN NUMBER)
IS
	x_progress	VARCHAR2(3) := '';
BEGIN
    x_progress := '010';

    IF (x_old_employee_id IS NOT NULL) THEN

	x_progress := '020';
        --dbms_output.put_line('Before Update');

    	UPDATE PO_ACTION_HISTORY
    	SET     last_update_date = sysdate,
            	last_updated_by = x_user_id,
            	last_update_login = x_login_id,
            	action_date = sysdate,
            	action_code = 'FORWARD',
            	note = x_note,
            	offline_code = decode(offline_code,
				'PRINTED', 'PRINTED', NULL)
    	WHERE   employee_id = x_old_employee_id
    	AND     action_code IS NULL;

    ELSE
	x_progress := '030';
	PO_MESSAGE_S.SQL_ERROR('UPDATE_ALL_ACTION_HISTORY', x_progress, sqlcode);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
	--dbms_output.put_line('In Exception');
	PO_MESSAGE_S.SQL_ERROR('UPDATE_ALL_ACTION_HISTORY', x_progress, sqlcode);
	RAISE;
END;

/*===========================================================================

  PROCEDURE NAME:	lock_row

===========================================================================*/

PROCEDURE lock_row (x_rowid		VARCHAR2,
		    x_last_update_date  DATE) IS
    CURSOR C IS
        SELECT 	*
        FROM   	po_action_history
        WHERE   rowid = x_rowid
        FOR UPDATE of sequence_num NOWAIT;
    Recinfo C%ROWTYPE;

BEGIN
    OPEN C;
    FETCH C INTO Recinfo;
    IF (C%NOTFOUND) then
        CLOSE C;
        FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.Raise_Exception;
    END IF;
    CLOSE C;

    IF (Recinfo.last_update_date = x_last_update_date) THEN
	return;
    ELSE
	FND_MESSAGE.set_name('FND', 'FORM_RECORD_CHANGED');
	 APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

END;

END PO_FORWARD_SV1;

/
