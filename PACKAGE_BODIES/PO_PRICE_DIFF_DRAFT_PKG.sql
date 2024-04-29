--------------------------------------------------------
--  DDL for Package Body PO_PRICE_DIFF_DRAFT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_PRICE_DIFF_DRAFT_PKG" AS
/* $Header: PO_PRICE_DIFF_DRAFT_PKG.plb 120.5 2006/09/28 23:05:20 bao noship $ */

d_pkg_name CONSTANT varchar2(50) :=
  PO_LOG.get_package_base('PO_PRICE_DIFF_DRAFT_PKG');

-----------------------------------------------------------------------
--Start of Comments
--Name: delete_rows
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  Deletes drafts for price differentials based on the information given
--  If only draft_id is provided, then all price diffs for the draft will be
--  deleted
--  If price_differential_id is also provided, then the one record that has such
--  primary key will be deleted
--Parameters:
--IN:
--p_draft_id
--  draft unique identifier
--p_price_differential_id
--  price differential unique identifier
--IN OUT:
--OUT:
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE delete_rows
( p_draft_id IN NUMBER,
  p_price_differential_id IN NUMBER
) IS

d_api_name CONSTANT VARCHAR2(30) := 'delete_rows';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

BEGIN

  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  DELETE FROM po_price_diff_draft
  WHERE draft_id = p_draft_id
  AND price_differential_id = NVL(p_price_differential_id,
                                  price_differential_id);

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
--p_price_differential_id_tbl
--  table of po price differentials unique identifier
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
( p_price_differential_id_tbl IN PO_TBL_NUMBER,
  p_draft_id_tbl              IN PO_TBL_NUMBER,
  p_delete_flag_tbl           IN PO_TBL_VARCHAR1,
  x_record_already_exist_tbl  OUT NOCOPY PO_TBL_VARCHAR1
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
    PO_PRICE_DIFF_DRAFT_PVT.draft_changes_exist
    ( p_draft_id_tbl              => p_draft_id_tbl,
      p_price_differential_id_tbl => p_price_differential_id_tbl
    );

  -- bug5471513 START
  -- If there're duplicate entries in the id table,
  -- we do not want to insert multiple entries
  -- Created an associative array to store what id has appeared.
  l_duplicate_flag_tbl.EXTEND(p_price_differential_id_tbl.COUNT);

  FOR i IN 1..p_price_differential_id_tbl.COUNT LOOP
    IF (x_record_already_exist_tbl(i) = FND_API.G_FALSE) THEN

      IF (l_distinct_id_list.EXISTS(p_price_differential_id_tbl(i))) THEN

        l_duplicate_flag_tbl(i) := FND_API.G_TRUE;
      ELSE
        l_duplicate_flag_tbl(i) := FND_API.G_FALSE;

        l_distinct_id_list(p_price_differential_id_tbl(i)) := 1;
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

  FORALL i IN 1..p_price_differential_id_tbl.COUNT
    INSERT INTO po_price_diff_draft
    (
      draft_id,
      delete_flag,
      change_accepted_flag,
      price_differential_id,
      price_differential_num,
      entity_id,
      entity_type,
      price_type,
      enabled_flag,
      min_multiplier,
      max_multiplier,
      multiplier,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    )
    SELECT
      p_draft_id_tbl(i),
      p_delete_flag_tbl(i),
      NULL,
      price_differential_id,
      price_differential_num,
      entity_id,
      entity_type,
      price_type,
      enabled_flag,
      min_multiplier,
      max_multiplier,
      multiplier,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    FROM po_price_differentials
    WHERE price_differential_id = p_price_differential_id_tbl(i)
    AND x_record_already_exist_tbl(i) = FND_API.G_FALSE
    AND l_duplicate_flag_tbl(i) = FND_API.G_FALSE;

  d_position := 20;
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'transfer count = ' || SQL%ROWCOUNT);
  END IF;

  FORALL i IN 1..p_price_differential_id_tbl.COUNT
    UPDATE po_price_diff_draft
    SET    delete_flag = p_delete_flag_tbl(i)
    WHERE  price_differential_id = p_price_differential_id_tbl(i)
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
--p_price_differential_id
--  price differential unique identifier
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
( p_price_differential_id IN NUMBER,
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
    PO_LOG.proc_begin(d_module, 'p_price_differential_id',
                                p_price_differential_id);
  END IF;

  sync_draft_from_txn
  ( p_price_differential_id_tbl => PO_TBL_NUMBER(p_price_differential_id),
    p_draft_id_tbl              => PO_TBL_NUMBER(p_draft_id),
    p_delete_flag_tbl           => PO_TBL_VARCHAR1(p_delete_flag),
    x_record_already_exist_tbl  => l_record_already_exist_tbl
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

  DELETE FROM po_price_differentials PPD
  WHERE PPD.price_differential_id IN
         ( SELECT PPDD.price_differential_id
           FROM   po_price_diff_draft PPDD
           WHERE  PPDD.draft_id = p_draft_id
           AND    PPDD.delete_flag = 'Y'
           AND    NVL(PPDD.change_accepted_flag, 'Y') = 'Y');

  d_position := 10;

  -- Merge Price Differential changes
  -- For update case, the following columns will be skipped:
  --PPD.price_differential_id
  --PPD.entity_id
  --PPD.entity_type
  --PPD.creation_date
  --PPD.created_by
  MERGE INTO po_price_differentials PPD
  USING (
    SELECT
      PPDD.draft_id,
      PPDD.delete_flag,
      PPDD.change_accepted_flag,
      PPDD.price_differential_id,
      PPDD.price_differential_num,
      PPDD.entity_id,
      PPDD.entity_type,
      PPDD.price_type,
      PPDD.enabled_flag,
      PPDD.min_multiplier,
      PPDD.max_multiplier,
      PPDD.multiplier,
      PPDD.creation_date,
      PPDD.created_by,
      PPDD.last_update_date,
      PPDD.last_updated_by,
      PPDD.last_update_login
    FROM po_price_diff_draft PPDD
    WHERE PPDD.draft_id = p_draft_id
    AND NVL(PPDD.change_accepted_flag, 'Y') = 'Y'
    ) PPDDV
  ON (PPD.price_differential_id = PPDDV.price_differential_id)
  WHEN MATCHED THEN
    UPDATE
    SET
      PPD.price_differential_num = PPDDV.price_differential_num,
      PPD.price_type = PPDDV.price_type,
      PPD.enabled_flag = PPDDV.enabled_flag,
      PPD.min_multiplier = PPDDV.min_multiplier,
      PPD.max_multiplier = PPDDV.max_multiplier,
      PPD.multiplier = PPDDV.multiplier,
      PPD.last_update_date = PPDDV.last_update_date,
      PPD.last_updated_by = PPDDV.last_updated_by,
      PPD.last_update_login = PPDDV.last_update_login
  --  DELETE WHERE PPDDV.delete_flag = 'Y'
  WHEN NOT MATCHED THEN
    INSERT
    (
      PPD.price_differential_id,
      PPD.price_differential_num,
      PPD.entity_id,
      PPD.entity_type,
      PPD.price_type,
      PPD.enabled_flag,
      PPD.min_multiplier,
      PPD.max_multiplier,
      PPD.multiplier,
      PPD.creation_date,
      PPD.created_by,
      PPD.last_update_date,
      PPD.last_updated_by,
      PPD.last_update_login
    )
    VALUES
    (
      PPDDV.price_differential_id,
      PPDDV.price_differential_num,
      PPDDV.entity_id,
      PPDDV.entity_type,
      PPDDV.price_type,
      PPDDV.enabled_flag,
      PPDDV.min_multiplier,
      PPDDV.max_multiplier,
      PPDDV.multiplier,
      PPDDV.creation_date,
      PPDDV.created_by,
      PPDDV.last_update_date,
      PPDDV.last_updated_by,
      PPDDV.last_update_login
    ) WHERE NVL(PPDDV.delete_flag, 'N') <> 'Y';

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
--p_price_differential_id
--  id for po price differential record
--p_draft_id
--  draft unique identifier
--RETURN:
--End of Comments
------------------------------------------------------------------------
PROCEDURE lock_draft_record
( p_price_differential_id IN NUMBER,
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
  FROM po_price_diff_draft
  WHERE price_differential_id = p_price_differential_id
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
--p_price_differential_id
--  id for price differential record
--RETURN:
--End of Comments
------------------------------------------------------------------------
PROCEDURE lock_transaction_record
( p_price_differential_id IN NUMBER
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
  FROM po_price_differentials
  WHERE price_differential_id = p_price_differential_id
  FOR UPDATE NOWAIT;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
WHEN NO_DATA_FOUND THEN
  NULL;
END lock_transaction_record;

END PO_PRICE_DIFF_DRAFT_PKG;

/
