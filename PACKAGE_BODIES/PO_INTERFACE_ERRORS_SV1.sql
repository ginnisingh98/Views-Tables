--------------------------------------------------------
--  DDL for Package Body PO_INTERFACE_ERRORS_SV1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_INTERFACE_ERRORS_SV1" AS
/* $Header: POXPIIEB.pls 115.17 2004/03/05 23:30:53 mbhargav ship $ */

-- Read the profile option that enables/disables the debug log
g_po_pdoi_write_to_file VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_PDOI_WRITE_TO_FILE'),'N');

-- <PDOI-Grants Integration Project: START>
  -- Private function to this file
  -- This function is a bare wrapper to the insert statement. It would be called
  -- from the public procedures handle_interface_errors_msg() and
  -- insert_po_interface_errors(). It is part of the refactoring done in the
  -- PDOI-Grants Integration Project.
PROCEDURE insert_po_interface_errors_msg(
                           X_interface_type       IN VARCHAR2,
                           X_Interface_Header_ID  IN NUMBER,
                           X_Interface_Line_Id    IN NUMBER,
                           X_Interface_Dist_Id    IN NUMBER,
                           X_error_message_text   IN VARCHAR2,
                           X_error_message_name   IN VARCHAR2,
                           X_column_name          IN VARCHAR2,
                           X_table_name           IN VARCHAR2,
                           X_batch_id             IN NUMBER)
IS

-- Moved the AUTONOMOUS_TRANSACTION inside this new procedure. Prior to this
-- it was present in the public function insert_po_interface_errors(). That
-- function, in turn, now calls this procedure.

-- Bug 2705777. Making this an autonomous transaction to avoid rollback issues
-- with the main transaction's savepoints.
PRAGMA AUTONOMOUS_TRANSACTION;

  X_progress        varchar2(30) := null;
BEGIN
  X_progress := '010';

  insert into po_interface_errors(Interface_Type,
                                  Interface_Transaction_Id,
                                  column_name,
                                  table_name,
                                  error_message,
                                  Error_Message_Name,
                                  processing_date,
                                  Creation_Date,
                                  Created_By,
                                  Last_Update_Date,
                                  Last_Updated_by,
                                  Last_Update_Login,
                                  Interface_Header_ID,
                                  Interface_Line_Id,
                                  Interface_Distribution_Id,
                                  Request_Id,
                                  Program_Application_id,
                                  Program_Id,
                                  Program_Update_date,
                                  Batch_Id)
                          VALUES
                                 (X_interface_type,
                                  po_interface_errors_s.nextval,
                                  X_column_name,
                                  X_table_name,
                                  X_Error_Message_text,
                                  X_Error_Message_name,
                                  sysdate,
                                  sysdate,
                                  fnd_global.user_id,
                                  sysdate,
                                  fnd_global.user_id,
                                  fnd_global.login_id,
                                  X_interface_header_id,
                                  X_interface_line_id,
                                  X_Interface_Dist_Id,
                                  fnd_global.conc_request_id,
                                  fnd_global.prog_appl_id,
                                  fnd_global.conc_program_id,
                                  sysdate,
                                  X_batch_id);

  -- Have to commit at the end of a successful autonomous transaction
  commit;

EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('insert_po_interface_errors_msg', X_progress,
                           sqlcode);
    RAISE;
END insert_po_interface_errors_msg;
-- <PDOI-Grants Integration Project: END>

/*==================================================================*/
 PROCEDURE handle_interface_errors(X_interface_type           IN  VARCHAR2,
                                   X_Error_type               IN  VARCHAR2,
                                   X_Batch_id                 IN  NUMBER,
                                   X_Interface_Header_Id      IN  NUMBER,
                                   X_Interface_Line_id        IN  NUMBER,
                                   X_Error_message_name       IN  VARCHAR2,
                                   X_Table_name               IN  VARCHAR2,
                                   X_Column_name              IN  VARCHAR2,
                                   X_TokenName1               IN  VARCHAR2,
                                   X_TokenName2               IN  VARCHAR2,
                                   X_TokenName3               IN  VARCHAR2,
                                   X_TokenName4               IN  VARCHAR2,
                                   X_TokenName5               IN  VARCHAR2,
                                   X_TokenName6               IN  VARCHAR2,
                                   X_TokenValue1              IN  VARCHAR2,
                                   X_TokenValue2              IN  VARCHAR2,
                                   X_TokenValue3              IN  VARCHAR2,
                                   X_TokenValue4              IN  VARCHAR2,
                                   X_TokenValue5              IN  VARCHAR2,
                                   X_TokenValue6              IN  VARCHAR2,
                                   X_header_processable_flag  IN OUT NOCOPY VARCHAR2,
                                   X_Interface_Dist_Id        IN  NUMBER
)
IS

    X_progress		VARCHAR2(3);
    X_compl_code	VARCHAR2(1);


BEGIN
	IF (g_po_pdoi_write_to_file = 'Y') THEN
   	PO_DEBUG.put_line('-->Intfc error occurred ...' ||
   				X_error_message_name
   				);
	END IF;

	IF (X_header_processable_flag = 'Y') THEN
            X_header_processable_flag := 'N';
	END IF;

	X_progress   :=  '010';

    -- call function po_interface_error_insert to insert a new error record
    -- in an autonomous transaction.  Therefore, all error messages will be
    -- committed to the db without interfering with the main transaction's
    -- savepoints
    X_compl_code := po_interface_errors_sv1.insert_po_interface_errors(
                                     X_interface_type,
                                     X_Error_type, --<Bug 3375881>
                                     X_Batch_id,
                                     X_Interface_Header_ID,
                                     X_Interface_Line_Id ,
                                     X_Interface_Dist_Id,
                                     X_Error_Message_name,
				     X_column_name,
				     X_table_name,
                                     X_TokenName1,
                                     X_TokenName2,
                                     X_TokenName3,
                                     X_TokenName4,
                                     X_TokenName5,
                                     X_TokenName6,
                                     X_TokenValue1,
                                     X_TokenValue2,
                                     X_TokenValue3,
                                     X_TokenValue4,
                                     X_TokenValue5,
                                     X_TokenValue6);

EXCEPTION
  WHEN others THEN
       po_message_s.sql_error('handle_interface_errors', x_progress, sqlcode);
       raise;
END handle_interface_errors;

/* ========================================================================


	FUNCTION NAME:  insert_po_interface_errors()

=========================================================================*/

FUNCTION  insert_po_interface_errors(X_interface_type       IN VARCHAR2,
                                     X_Error_type           IN VARCHAR2,
                                     X_Batch_id             IN NUMBER,
                                     X_Interface_Header_ID  IN NUMBER,
                                     X_Interface_Line_Id    IN NUMBER,
                                     X_Interface_Dist_Id    IN NUMBER,
				     X_error_message_name   IN VARCHAR2,
				     X_column_name          IN VARCHAR2,
				     X_table_name           IN VARCHAR2,
                                     X_TokenName1           IN VARCHAR2,
                                     X_TokenName2           IN VARCHAR2,
                                     X_TokenName3           IN VARCHAR2,
                                     X_TokenName4           IN VARCHAR2,
                                     X_TokenName5           IN VARCHAR2,
                                     X_TokenName6           IN VARCHAR2,
                                     X_TokenValue1          IN VARCHAR2,
                                     X_TokenValue2          IN VARCHAR2,
                                     X_TokenValue3          IN VARCHAR2,
                                     X_TokenValue4          IN VARCHAR2,
                                     X_TokenValue5          IN VARCHAR2,
                                     X_TokenValue6          IN VARCHAR2)
Return VARCHAR2 IS

        X_progress        varchar2(30) := null;
        X_Error_Message   fnd_new_messages.message_text%type;

        --<Bug 3375881 mbhargav START>
        l_original_message   fnd_new_messages.message_text%type;
        l_error_type_message fnd_new_messages.message_text%type;
        --<Bug 3375881 mbhargav END>

BEGIN

       X_progress := '010';

       fnd_message.set_name('PO', X_Error_Message_Name);

       X_progress := '020';

       if (X_TokenName1 is not null and X_TokenValue1 is not null) then
           fnd_message.set_token(X_TokenName1, X_TokenValue1);
       end if;
       if (X_TokenName2 is not null and X_TokenValue2 is not null) then
           fnd_message.set_token(X_TokenName2, X_TokenValue2);
       end if;
       if (X_TokenName3 is not null and X_TokenValue3 is  not null) then
           fnd_message.set_token(X_TokenName3, X_TokenValue3);
       end if;
       if (X_TokenName4 is not null and X_TokenValue4 is not null) then
           fnd_message.set_token(X_TokenName4, X_TokenValue4);
       end if;
       if (X_TokenName5 is not null and X_TokenValue5 is not null) then
           fnd_message.set_token(X_TokenName5, X_TokenValue5);
       end if;
       if (X_TokenName6 is not null and X_TokenValue6 is not null) then
           fnd_message.set_token(X_TokenName6, X_TokenValue6);
       end if;

       X_progress := '030';

       --<Bug 3375881 mbhargav START>
       l_original_Message := Fnd_message.get;

       X_progress := '040';

       IF x_error_type = 'FATAL' THEN
          fnd_message.set_name('PO', 'PO_ERROR');
          l_error_type_message := fnd_message.get;
       ELSIF x_error_type = 'WARNING' THEN
          fnd_message.set_name('PO', 'PO_WARNING');
          l_error_type_message := fnd_message.get;
       ELSE
          l_error_type_message := null;
       END IF;

       --The message which is now returned has the_error_type appended to it.
       --The message stored in interface tables will be of following format:
       --Warning: <the error message itself>
       --Error: <the error message itself>
       x_error_message := substrb(l_error_type_message || ' ' || l_original_message, 1, 2000);
       --<Bug 3375881 mbhargav END>

X_progress := '050';

/* Bug 2860580. Added BATCH_ID in the INSERT statement */

  -- <PDOI-Grants Integration Project: START>
  -- Refactored this code to call this private function. This private function
  -- is also called from the new public procedure handle_interface_errors_msg()
  insert_po_interface_errors_msg(X_interface_type,
                                 X_interface_header_id,
                                 X_interface_line_id,
                                 X_Interface_Dist_Id,
                                 X_Error_Message,
                                 X_Error_Message_name,
                                 X_column_name,
                                 X_table_name,
                                 X_Batch_id);
  -- <PDOI-Grants Integration Project: END>

return('0');

EXCEPTION
  WHEN OTHERS THEN
      po_message_s.sql_error('insert_po_interface_errors', X_progress, sqlcode);
      ROLLBACK;
      raise;
END insert_po_interface_errors;

-- Bug 2705777. Removed procedures rollback_changes and rollback_line_changes

-- <PDOI-Grants Integration Project: START>
PROCEDURE handle_interface_errors_msg(
                    X_interface_type           IN  VARCHAR2,
                    X_Error_type               IN  VARCHAR2,
                    X_Batch_id                 IN  NUMBER,
                    X_Interface_Header_Id      IN  NUMBER,
                    X_Interface_Line_id        IN  NUMBER,
                    X_Error_message_text       IN  VARCHAR2,
                    X_Error_message_name       IN  VARCHAR2,
                    X_Table_name               IN  VARCHAR2,
                    X_Column_name              IN  VARCHAR2,
                    X_header_processable_flag  IN OUT NOCOPY VARCHAR2,
                    X_Interface_Dist_Id        IN  NUMBER DEFAULT NULL)
IS
  X_progress		VARCHAR2(3);
  X_compl_code	VARCHAR2(1);
BEGIN
  PO_DEBUG.put_line('-->Intfc error occurred...<'||X_error_message_text||'>');

  IF X_header_processable_flag = 'Y' THEN
     X_header_processable_flag := 'N';
  END IF;

  X_progress   :=  '010';
  -- call function insert_po_interface_errors_msg to insert a new error record
  insert_po_interface_errors_msg(X_interface_type,
                                 X_Interface_Header_ID,
                                 X_Interface_Line_Id ,
                                 X_Interface_Dist_Id,
                                 X_Error_Message_text,
                                 X_Error_Message_name,
                                 X_column_name,
                                 X_table_name,
                                 X_Batch_id);
EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('handle_interface_errors_msg', x_progress, sqlcode);
    RAISE;
END handle_interface_errors_msg;
-- <PDOI-Grants Integration Project: END>

END PO_INTERFACE_ERRORS_SV1;

/
