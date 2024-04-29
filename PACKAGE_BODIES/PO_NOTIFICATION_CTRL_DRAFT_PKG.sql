--------------------------------------------------------
--  DDL for Package Body PO_NOTIFICATION_CTRL_DRAFT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_NOTIFICATION_CTRL_DRAFT_PKG" AS
/* $Header: PO_NOTIFICATION_CTRL_DRAFT_PKG.plb 120.5 2006/09/28 23:04:57 bao noship $ */

d_pkg_name CONSTANT varchar2(50) :=
  PO_LOG.get_package_base('PO_NOTIFICATION_CTRL_DRAFT_PKG');

-----------------------------------------------------------------------
--Start of Comments
--Name: delete_rows
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  Deletes drafts for notification controls based on the information given
--  If only draft_id is provided, then all notification ctrls for the draft
--  will be deleted
--  If notification_id is also provided, then the one record that has such
--  primary key will be deleted
--Parameters:
--IN:
--p_draft_id
--  draft unique identifier
--p_notification_id
--  notification control unique identifier
--IN OUT:
--OUT:
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE delete_rows
( p_draft_id IN NUMBER,
  p_notification_id IN NUMBER
) IS
d_api_name CONSTANT VARCHAR2(30) := 'delete_rows';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

BEGIN

  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  DELETE FROM po_notification_ctrl_draft
  WHERE draft_id = p_draft_id
  AND notification_id = NVL(p_notification_id, notification_id);

  d_position := 10;
EXCEPTION
  WHEN OTHERS THEN
    PO_MESSAGE_S.add_exc_msg
    ( p_pkg_name => d_pkg_name,
      p_procedure_name => d_api_name || '.' || d_position
    );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END delete_rows;


-----------------------------------------------------------------------
--Start of Comments
--Name: sync_draft_from_txn
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  Copy data from transaction table to draft table, if the corresponding
--  record in draft table does not exist. It also sets the delete flag of
--  the draft record according to the parameter.
--Parameters:
--IN:
--p_notification_id_tbl
--  table of po notification controls unique identifier
--p_draft_id_tbl
--  table of draft ids this sync up will be done for
--p_delete_flag_tbl
--  table fo flags to indicate whether the draft record should be maked as
--  "to be deleted"
--IN OUT:
--OUT:
--x_record_already_exist_tbl
--  Returns whether the record was already in draft table or not
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE sync_draft_from_txn
( p_notification_id_tbl         IN PO_TBL_NUMBER,
  p_draft_id_tbl             IN PO_TBL_NUMBER,
  p_delete_flag_tbl          IN PO_TBL_VARCHAR1,
  x_record_already_exist_tbl OUT NOCOPY PO_TBL_VARCHAR1
) IS

d_api_name CONSTANT VARCHAR2(30) := 'sync_draft_from_txn';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_distinct_id_list DBMS_SQL.NUMBER_TABLE;
l_duplicate_flag_tbl PO_TBL_VARCHAR1 := PO_TBL_VARCHAR1();

BEGIN
  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  x_record_already_exist_tbl :=
    PO_NOTIFICATION_CTRL_DRAFT_PVT.draft_changes_exist
    ( p_draft_id_tbl        => p_draft_id_tbl,
      p_notification_id_tbl => p_notification_id_tbl
    );

  -- bug5471513 START
  -- If there're duplicate entries in the id table,
  -- we do not want to insert multiple entries
  -- Created an associative array to store what id has appeared.
  l_duplicate_flag_tbl.EXTEND(p_notification_id_tbl.COUNT);

  FOR i IN 1..p_notification_id_tbl.COUNT LOOP
    IF (x_record_already_exist_tbl(i) = FND_API.G_FALSE) THEN

      IF (l_distinct_id_list.EXISTS(p_notification_id_tbl(i))) THEN

        l_duplicate_flag_tbl(i) := FND_API.G_TRUE;
      ELSE
        l_duplicate_flag_tbl(i) := FND_API.G_FALSE;

        l_distinct_id_list(p_notification_id_tbl(i)) := 1;
      END IF;

    ELSE

      l_duplicate_flag_tbl(i) := NULL;

    END IF;
  END LOOP;
  -- bug5471513 END

  d_position := 10;
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'transfer records from txn to dft');
  END IF;

  FORALL i IN 1..p_notification_id_tbl.COUNT
    INSERT INTO po_notification_ctrl_draft
    (
      draft_id,
      delete_flag,
      change_accepted_flag,
      notification_id,
      po_header_id,
      start_date_active,
      end_date_active,
      notification_amount,
      notification_condition_code,
      notification_qty_percentage,
      last_update_date,
      last_update_login,
      last_updated_by,
      program_id,
      program_application_id,
      program_update_date,
      request_id,
      created_by,
      creation_date,
      attribute_category,
      attribute1,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9
    )
    SELECT
      p_draft_id_tbl(i),
      p_delete_flag_tbl(i),
      NULL,
      notification_id,
      po_header_id,
      start_date_active,
      end_date_active,
      notification_amount,
      notification_condition_code,
      notification_qty_percentage,
      last_update_date,
      last_update_login,
      last_updated_by,
      program_id,
      program_application_id,
      program_update_date,
      request_id,
      created_by,
      creation_date,
      attribute_category,
      attribute1,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9
    FROM po_notification_controls
    WHERE notification_id = p_notification_id_tbl(i)
    AND x_record_already_exist_tbl(i) = FND_API.G_FALSE
    AND l_duplicate_flag_tbl(i) = FND_API.G_FALSE;

  d_position := 20;
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'transfer count = ' || SQL%ROWCOUNT);
  END IF;

  FORALL i IN 1..p_notification_id_tbl.COUNT
    UPDATE po_notification_ctrl_draft
    SET    delete_flag = p_delete_flag_tbl(i)
    WHERE  notification_id = p_notification_id_tbl(i)
    AND    draft_id = p_draft_id_tbl(i)
    AND    NVL(delete_flag, 'N') <> 'Y'  -- bug5570989
    AND    x_record_already_exist_tbl(i) = FND_API.G_TRUE;

  d_position := 30;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'update draft records that are already' ||
                ' in draft table. Count = ' || SQL%ROWCOUNT);
  END IF;

  d_position := 40;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    PO_MESSAGE_S.add_exc_msg
    ( p_pkg_name => d_pkg_name,
      p_procedure_name => d_api_name || '.' || d_position
    );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END sync_draft_from_txn;

-----------------------------------------------------------------------
--Start of Comments
--Name: sync_draft_from_txn
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  Same functionality as the bulk version of this procedure
--Parameters:
--IN:
--p_notification_id
--  notification control unique identifier
--p_draft_id
--  the draft this sync up will be done for
--p_delete_flag
--  flag to indicate whether the draft record should be maked as "to be
--  deleted"
--IN OUT:
--OUT:
--x_record_already_exist
--  Returns whether the record was already in draft table or not
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE sync_draft_from_txn
( p_notification_id IN NUMBER,
  p_draft_id IN NUMBER,
  p_delete_flag IN VARCHAR2,
  x_record_already_exist OUT NOCOPY VARCHAR2
) IS

d_api_name CONSTANT VARCHAR2(30) := 'sync_draft_from_txn';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_record_already_exist_tbl PO_TBL_VARCHAR1;

BEGIN
  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_notification_id', p_notification_id);
  END IF;

  sync_draft_from_txn
  ( p_notification_id_tbl      => PO_TBL_NUMBER(p_notification_id),
    p_draft_id_tbl             => PO_TBL_NUMBER(p_draft_id),
    p_delete_flag_tbl          => PO_TBL_VARCHAR1(p_delete_flag),
    x_record_already_exist_tbl => l_record_already_exist_tbl
  );

  x_record_already_exist := l_record_already_exist_tbl(1);

  d_position := 10;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
    PO_LOG.proc_end(d_module, 'x_record_already_exist', x_record_already_exist);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    PO_MESSAGE_S.add_exc_msg
    ( p_pkg_name => d_pkg_name,
      p_procedure_name => d_api_name || '.' || d_position
    );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END sync_draft_from_txn;


-----------------------------------------------------------------------
--Start of Comments
--Name: merge_changes
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  Merge the records in draft table to transaction table
--  Either insert, update or delete will be performed on top of transaction
--  table, depending on the delete_flag on the draft record and whether the
--  record already exists in transaction table
--
--Parameters:
--IN:
--p_draft_id
--  draft unique identifier
--IN OUT:
--OUT:
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE merge_changes
( p_draft_id IN NUMBER
) IS

d_api_name CONSTANT VARCHAR2(30) := 'merge_changes';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

BEGIN

  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  -- Since putting DELETE within MERGE statement is causing database
  -- to thrown internal error, for now we just separate the DELETE statement.
  -- Once this is fixed we'll move the delete statement back to the merge
  -- statement

  -- bug5187544
  -- Delete only records that have not been rejected

  DELETE FROM po_notification_controls PNC
  WHERE PNC.notification_id IN
         ( SELECT PNCD.notification_id
           FROM   po_notification_ctrl_draft PNCD
           WHERE  PNCD.draft_id = p_draft_id
           AND    PNCD.delete_flag = 'Y'
           AND    NVL(PNCD.change_accepted_flag, 'Y') = 'Y' );

  d_position := 10;

  -- Merge PO notification control changes
  -- For update case, the following columns will be skipped:
  --PNC.notification_id
  --PNC.program_id
  --PNC.program_application_id
  --PNC.program_update_date
  --PNC.request_id
  --PNC.created_by
  --PNC.creation_date
  MERGE INTO po_notification_controls PNC
  USING (
    SELECT
      PNCD.draft_id,
      PNCD.delete_flag,
      PNCD.change_accepted_flag,
      PNCD.notification_id,
      PNCD.po_header_id,
      PNCD.start_date_active,
      PNCD.end_date_active,
      PNCD.notification_amount,
      PNCD.notification_condition_code,
      PNCD.notification_qty_percentage,
      PNCD.last_update_date,
      PNCD.last_update_login,
      PNCD.last_updated_by,
      PNCD.program_id,
      PNCD.program_application_id,
      PNCD.program_update_date,
      PNCD.request_id,
      PNCD.created_by,
      PNCD.creation_date,
      PNCD.attribute_category,
      PNCD.attribute1,
      PNCD.attribute10,
      PNCD.attribute11,
      PNCD.attribute12,
      PNCD.attribute13,
      PNCD.attribute14,
      PNCD.attribute15,
      PNCD.attribute2,
      PNCD.attribute3,
      PNCD.attribute4,
      PNCD.attribute5,
      PNCD.attribute6,
      PNCD.attribute7,
      PNCD.attribute8,
      PNCD.attribute9
    FROM po_notification_ctrl_draft PNCD
    WHERE PNCD.draft_id = p_draft_id
    AND NVL(PNCD.change_accepted_flag, 'Y') = 'Y'
    ) PNCDV
  ON (PNC.notification_id = PNCDV.notification_id)
  WHEN MATCHED THEN
    UPDATE
    SET
      PNC.po_header_id = PNCDV.po_header_id,
      PNC.start_date_active = PNCDV.start_date_active,
      PNC.end_date_active = PNCDV.end_date_active,
      PNC.notification_amount = PNCDV.notification_amount,
      PNC.notification_condition_code = PNCDV.notification_condition_code,
      PNC.notification_qty_percentage = PNCDV.notification_qty_percentage,
      PNC.last_update_date = PNCDV.last_update_date,
      PNC.last_update_login = PNCDV.last_update_login,
      PNC.last_updated_by = PNCDV.last_updated_by,
      PNC.attribute_category = PNCDV.attribute_category,
      PNC.attribute1 = PNCDV.attribute1,
      PNC.attribute10 = PNCDV.attribute10,
      PNC.attribute11 = PNCDV.attribute11,
      PNC.attribute12 = PNCDV.attribute12,
      PNC.attribute13 = PNCDV.attribute13,
      PNC.attribute14 = PNCDV.attribute14,
      PNC.attribute15 = PNCDV.attribute15,
      PNC.attribute2 = PNCDV.attribute2,
      PNC.attribute3 = PNCDV.attribute3,
      PNC.attribute4 = PNCDV.attribute4,
      PNC.attribute5 = PNCDV.attribute5,
      PNC.attribute6 = PNCDV.attribute6,
      PNC.attribute7 = PNCDV.attribute7,
      PNC.attribute8 = PNCDV.attribute8,
      PNC.attribute9 = PNCDV.attribute9
  --  DELETE WHERE PNCDV.delete_flag = 'Y'
  WHEN NOT MATCHED THEN
    INSERT
    (
      PNC.notification_id,
      PNC.po_header_id,
      PNC.start_date_active,
      PNC.end_date_active,
      PNC.notification_amount,
      PNC.notification_condition_code,
      PNC.notification_qty_percentage,
      PNC.last_update_date,
      PNC.last_update_login,
      PNC.last_updated_by,
      PNC.program_id,
      PNC.program_application_id,
      PNC.program_update_date,
      PNC.request_id,
      PNC.created_by,
      PNC.creation_date,
      PNC.attribute_category,
      PNC.attribute1,
      PNC.attribute10,
      PNC.attribute11,
      PNC.attribute12,
      PNC.attribute13,
      PNC.attribute14,
      PNC.attribute15,
      PNC.attribute2,
      PNC.attribute3,
      PNC.attribute4,
      PNC.attribute5,
      PNC.attribute6,
      PNC.attribute7,
      PNC.attribute8,
      PNC.attribute9
    )
    VALUES
    (
      PNCDV.notification_id,
      PNCDV.po_header_id,
      PNCDV.start_date_active,
      PNCDV.end_date_active,
      PNCDV.notification_amount,
      PNCDV.notification_condition_code,
      PNCDV.notification_qty_percentage,
      PNCDV.last_update_date,
      PNCDV.last_update_login,
      PNCDV.last_updated_by,
      PNCDV.program_id,
      PNCDV.program_application_id,
      PNCDV.program_update_date,
      PNCDV.request_id,
      PNCDV.created_by,
      PNCDV.creation_date,
      PNCDV.attribute_category,
      PNCDV.attribute1,
      PNCDV.attribute10,
      PNCDV.attribute11,
      PNCDV.attribute12,
      PNCDV.attribute13,
      PNCDV.attribute14,
      PNCDV.attribute15,
      PNCDV.attribute2,
      PNCDV.attribute3,
      PNCDV.attribute4,
      PNCDV.attribute5,
      PNCDV.attribute6,
      PNCDV.attribute7,
      PNCDV.attribute8,
      PNCDV.attribute9
    ) WHERE NVL(PNCDV.delete_flag, 'N') <> 'Y';

  d_position := 10;
EXCEPTION
  WHEN OTHERS THEN
    PO_MESSAGE_S.add_exc_msg
    ( p_pkg_name => d_pkg_name,
      p_procedure_name => d_api_name || '.' || d_position
    );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END merge_changes;

-----------------------------------------------------------------------
--Start of Comments
--Name: lock_draft_record
--Function:
--  Obtain database lock for the record in draft table
--Parameters:
--IN:
--p_notification_id
--  id for po notification control record
--p_draft_id
--  draft unique identifier
--RETURN:
--End of Comments
------------------------------------------------------------------------
PROCEDURE lock_draft_record
( p_notification_id IN NUMBER,
  p_draft_id        IN NUMBER
) IS

d_api_name CONSTANT VARCHAR2(30) := 'lock_draft_record';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_dummy NUMBER;

BEGIN
  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  SELECT 1
  INTO l_dummy
  FROM po_notification_ctrl_draft
  WHERE notification_id = p_notification_id
  AND draft_id = p_draft_id
  FOR UPDATE NOWAIT;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
WHEN NO_DATA_FOUND THEN
  NULL;
END lock_draft_record;

-----------------------------------------------------------------------
--Start of Comments
--Name: lock_transaction_record
--Function:
--  Obtain database lock for the record in transaction table
--Parameters:
--IN:
--p_notification_id
--  id for po notification control record
--RETURN:
--End of Comments
------------------------------------------------------------------------
PROCEDURE lock_transaction_record
( p_notification_id IN NUMBER
) IS

d_api_name CONSTANT VARCHAR2(30) := 'lock_transaction_record';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

l_dummy NUMBER;

BEGIN
  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  SELECT 1
  INTO l_dummy
  FROM po_notification_controls
  WHERE notification_id = p_notification_id
  FOR UPDATE NOWAIT;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
WHEN NO_DATA_FOUND THEN
  NULL;
END lock_transaction_record;

END PO_NOTIFICATION_CTRL_DRAFT_PKG;

/
