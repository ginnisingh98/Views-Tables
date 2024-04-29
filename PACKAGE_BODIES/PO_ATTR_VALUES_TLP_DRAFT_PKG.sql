--------------------------------------------------------
--  DDL for Package Body PO_ATTR_VALUES_TLP_DRAFT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_ATTR_VALUES_TLP_DRAFT_PKG" AS
/* $Header: PO_ATTR_VALUES_TLP_DRAFT_PKG.plb 120.9 2006/09/28 22:58:56 bao noship $ */

d_pkg_name CONSTANT varchar2(50) :=
  PO_LOG.get_package_base('PO_ATTR_VALUES_TLP_DRAFT_PKG');

-----------------------------------------------------------------------
--Start of Comments
--Name: delete_rows
--Pre-reqs: None
--Modifies:
--Locks:
--  None
--Function:
--  Deletes drafts for attribute tlp values based on the information given
--  If only draft_id is provided, then all attribute tlp values for the draft
--  will be deleted
--  If attribute_values_tlp_id is also provided, then the record that has such
--  primary key will be deleted
--Parameters:
--IN:
--p_draft_id
--  draft unique identifier
--p_attribute_values_tlp_id
--  po attribute values unique identifier
--IN OUT:
--OUT:
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE delete_rows
( p_draft_id IN NUMBER,
  p_attribute_values_tlp_id IN NUMBER
) IS

d_api_name CONSTANT VARCHAR2(30) := 'delete_rows';
d_module CONSTANT VARCHAR2(2000) := d_pkg_name || d_api_name || '.';
d_position NUMBER;

BEGIN
  d_position := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
  END IF;

  DELETE FROM po_attribute_values_tlp_draft
  WHERE draft_id = p_draft_id
  AND attribute_values_tlp_id = NVL(p_attribute_values_tlp_id,
                                    attribute_values_tlp_id);

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
--p_attribute_values_tlp_id_tbl
--  table of po attribute values tlp unique identifier
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
( p_attribute_values_tlp_id_tbl IN PO_TBL_NUMBER,
  p_draft_id_tbl                IN PO_TBL_NUMBER,
  p_delete_flag_tbl             IN PO_TBL_VARCHAR1,
  x_record_already_exist_tbl    OUT NOCOPY PO_TBL_VARCHAR1
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
    PO_ATTR_VALUES_TLP_DRAFT_PVT.draft_changes_exist
    ( p_draft_id_tbl                => p_draft_id_tbl,
      p_attribute_values_tlp_id_tbl => p_attribute_values_tlp_id_tbl
    );

  -- bug5471513 START
  -- If there're duplicate entries in the id table,
  -- we do not want to insert multiple entries
  -- Created an associative array to store what id has appeared.
  l_duplicate_flag_tbl.EXTEND(p_attribute_values_tlp_id_tbl.COUNT);

  FOR i IN 1..p_attribute_values_tlp_id_tbl.COUNT LOOP
    IF (x_record_already_exist_tbl(i) = FND_API.G_FALSE) THEN

      IF (l_distinct_id_list.EXISTS(p_attribute_values_tlp_id_tbl(i))) THEN

        l_duplicate_flag_tbl(i) := FND_API.G_TRUE;
      ELSE
        l_duplicate_flag_tbl(i) := FND_API.G_FALSE;

        l_distinct_id_list(p_attribute_values_tlp_id_tbl(i)) := 1;
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

  FORALL i IN 1..p_attribute_values_tlp_id_tbl.COUNT
    INSERT INTO po_attribute_values_tlp_draft
    ( draft_id,
      delete_flag,
      change_accepted_flag,
      attribute_values_tlp_id,
      po_line_id,
      req_template_name,
      req_template_line_num,
      ip_category_id,
      inventory_item_id,
      org_id,
      language,
      description,
      manufacturer,
      comments,
      alias,
      long_description,
      tl_text_base_attribute1,
      tl_text_base_attribute2,
      tl_text_base_attribute3,
      tl_text_base_attribute4,
      tl_text_base_attribute5,
      tl_text_base_attribute6,
      tl_text_base_attribute7,
      tl_text_base_attribute8,
      tl_text_base_attribute9,
      tl_text_base_attribute10,
      tl_text_base_attribute11,
      tl_text_base_attribute12,
      tl_text_base_attribute13,
      tl_text_base_attribute14,
      tl_text_base_attribute15,
      tl_text_base_attribute16,
      tl_text_base_attribute17,
      tl_text_base_attribute18,
      tl_text_base_attribute19,
      tl_text_base_attribute20,
      tl_text_base_attribute21,
      tl_text_base_attribute22,
      tl_text_base_attribute23,
      tl_text_base_attribute24,
      tl_text_base_attribute25,
      tl_text_base_attribute26,
      tl_text_base_attribute27,
      tl_text_base_attribute28,
      tl_text_base_attribute29,
      tl_text_base_attribute30,
      tl_text_base_attribute31,
      tl_text_base_attribute32,
      tl_text_base_attribute33,
      tl_text_base_attribute34,
      tl_text_base_attribute35,
      tl_text_base_attribute36,
      tl_text_base_attribute37,
      tl_text_base_attribute38,
      tl_text_base_attribute39,
      tl_text_base_attribute40,
      tl_text_base_attribute41,
      tl_text_base_attribute42,
      tl_text_base_attribute43,
      tl_text_base_attribute44,
      tl_text_base_attribute45,
      tl_text_base_attribute46,
      tl_text_base_attribute47,
      tl_text_base_attribute48,
      tl_text_base_attribute49,
      tl_text_base_attribute50,
      tl_text_base_attribute51,
      tl_text_base_attribute52,
      tl_text_base_attribute53,
      tl_text_base_attribute54,
      tl_text_base_attribute55,
      tl_text_base_attribute56,
      tl_text_base_attribute57,
      tl_text_base_attribute58,
      tl_text_base_attribute59,
      tl_text_base_attribute60,
      tl_text_base_attribute61,
      tl_text_base_attribute62,
      tl_text_base_attribute63,
      tl_text_base_attribute64,
      tl_text_base_attribute65,
      tl_text_base_attribute66,
      tl_text_base_attribute67,
      tl_text_base_attribute68,
      tl_text_base_attribute69,
      tl_text_base_attribute70,
      tl_text_base_attribute71,
      tl_text_base_attribute72,
      tl_text_base_attribute73,
      tl_text_base_attribute74,
      tl_text_base_attribute75,
      tl_text_base_attribute76,
      tl_text_base_attribute77,
      tl_text_base_attribute78,
      tl_text_base_attribute79,
      tl_text_base_attribute80,
      tl_text_base_attribute81,
      tl_text_base_attribute82,
      tl_text_base_attribute83,
      tl_text_base_attribute84,
      tl_text_base_attribute85,
      tl_text_base_attribute86,
      tl_text_base_attribute87,
      tl_text_base_attribute88,
      tl_text_base_attribute89,
      tl_text_base_attribute90,
      tl_text_base_attribute91,
      tl_text_base_attribute92,
      tl_text_base_attribute93,
      tl_text_base_attribute94,
      tl_text_base_attribute95,
      tl_text_base_attribute96,
      tl_text_base_attribute97,
      tl_text_base_attribute98,
      tl_text_base_attribute99,
      tl_text_base_attribute100,
      tl_text_cat_attribute1,
      tl_text_cat_attribute2,
      tl_text_cat_attribute3,
      tl_text_cat_attribute4,
      tl_text_cat_attribute5,
      tl_text_cat_attribute6,
      tl_text_cat_attribute7,
      tl_text_cat_attribute8,
      tl_text_cat_attribute9,
      tl_text_cat_attribute10,
      tl_text_cat_attribute11,
      tl_text_cat_attribute12,
      tl_text_cat_attribute13,
      tl_text_cat_attribute14,
      tl_text_cat_attribute15,
      tl_text_cat_attribute16,
      tl_text_cat_attribute17,
      tl_text_cat_attribute18,
      tl_text_cat_attribute19,
      tl_text_cat_attribute20,
      tl_text_cat_attribute21,
      tl_text_cat_attribute22,
      tl_text_cat_attribute23,
      tl_text_cat_attribute24,
      tl_text_cat_attribute25,
      tl_text_cat_attribute26,
      tl_text_cat_attribute27,
      tl_text_cat_attribute28,
      tl_text_cat_attribute29,
      tl_text_cat_attribute30,
      tl_text_cat_attribute31,
      tl_text_cat_attribute32,
      tl_text_cat_attribute33,
      tl_text_cat_attribute34,
      tl_text_cat_attribute35,
      tl_text_cat_attribute36,
      tl_text_cat_attribute37,
      tl_text_cat_attribute38,
      tl_text_cat_attribute39,
      tl_text_cat_attribute40,
      tl_text_cat_attribute41,
      tl_text_cat_attribute42,
      tl_text_cat_attribute43,
      tl_text_cat_attribute44,
      tl_text_cat_attribute45,
      tl_text_cat_attribute46,
      tl_text_cat_attribute47,
      tl_text_cat_attribute48,
      tl_text_cat_attribute49,
      tl_text_cat_attribute50,
      last_update_login,
      last_updated_by,
      last_update_date,
      created_by,
      creation_date,
      request_id,
      program_application_id,
      program_id,
      program_update_date
    )
    SELECT
      p_draft_id_tbl(i),
      p_delete_flag_tbl(i),
      NULL,
      attribute_values_tlp_id,
      po_line_id,
      req_template_name,
      req_template_line_num,
      ip_category_id,
      inventory_item_id,
      org_id,
      language,
      description,
      manufacturer,
      comments,
      alias,
      long_description,
      tl_text_base_attribute1,
      tl_text_base_attribute2,
      tl_text_base_attribute3,
      tl_text_base_attribute4,
      tl_text_base_attribute5,
      tl_text_base_attribute6,
      tl_text_base_attribute7,
      tl_text_base_attribute8,
      tl_text_base_attribute9,
      tl_text_base_attribute10,
      tl_text_base_attribute11,
      tl_text_base_attribute12,
      tl_text_base_attribute13,
      tl_text_base_attribute14,
      tl_text_base_attribute15,
      tl_text_base_attribute16,
      tl_text_base_attribute17,
      tl_text_base_attribute18,
      tl_text_base_attribute19,
      tl_text_base_attribute20,
      tl_text_base_attribute21,
      tl_text_base_attribute22,
      tl_text_base_attribute23,
      tl_text_base_attribute24,
      tl_text_base_attribute25,
      tl_text_base_attribute26,
      tl_text_base_attribute27,
      tl_text_base_attribute28,
      tl_text_base_attribute29,
      tl_text_base_attribute30,
      tl_text_base_attribute31,
      tl_text_base_attribute32,
      tl_text_base_attribute33,
      tl_text_base_attribute34,
      tl_text_base_attribute35,
      tl_text_base_attribute36,
      tl_text_base_attribute37,
      tl_text_base_attribute38,
      tl_text_base_attribute39,
      tl_text_base_attribute40,
      tl_text_base_attribute41,
      tl_text_base_attribute42,
      tl_text_base_attribute43,
      tl_text_base_attribute44,
      tl_text_base_attribute45,
      tl_text_base_attribute46,
      tl_text_base_attribute47,
      tl_text_base_attribute48,
      tl_text_base_attribute49,
      tl_text_base_attribute50,
      tl_text_base_attribute51,
      tl_text_base_attribute52,
      tl_text_base_attribute53,
      tl_text_base_attribute54,
      tl_text_base_attribute55,
      tl_text_base_attribute56,
      tl_text_base_attribute57,
      tl_text_base_attribute58,
      tl_text_base_attribute59,
      tl_text_base_attribute60,
      tl_text_base_attribute61,
      tl_text_base_attribute62,
      tl_text_base_attribute63,
      tl_text_base_attribute64,
      tl_text_base_attribute65,
      tl_text_base_attribute66,
      tl_text_base_attribute67,
      tl_text_base_attribute68,
      tl_text_base_attribute69,
      tl_text_base_attribute70,
      tl_text_base_attribute71,
      tl_text_base_attribute72,
      tl_text_base_attribute73,
      tl_text_base_attribute74,
      tl_text_base_attribute75,
      tl_text_base_attribute76,
      tl_text_base_attribute77,
      tl_text_base_attribute78,
      tl_text_base_attribute79,
      tl_text_base_attribute80,
      tl_text_base_attribute81,
      tl_text_base_attribute82,
      tl_text_base_attribute83,
      tl_text_base_attribute84,
      tl_text_base_attribute85,
      tl_text_base_attribute86,
      tl_text_base_attribute87,
      tl_text_base_attribute88,
      tl_text_base_attribute89,
      tl_text_base_attribute90,
      tl_text_base_attribute91,
      tl_text_base_attribute92,
      tl_text_base_attribute93,
      tl_text_base_attribute94,
      tl_text_base_attribute95,
      tl_text_base_attribute96,
      tl_text_base_attribute97,
      tl_text_base_attribute98,
      tl_text_base_attribute99,
      tl_text_base_attribute100,
      tl_text_cat_attribute1,
      tl_text_cat_attribute2,
      tl_text_cat_attribute3,
      tl_text_cat_attribute4,
      tl_text_cat_attribute5,
      tl_text_cat_attribute6,
      tl_text_cat_attribute7,
      tl_text_cat_attribute8,
      tl_text_cat_attribute9,
      tl_text_cat_attribute10,
      tl_text_cat_attribute11,
      tl_text_cat_attribute12,
      tl_text_cat_attribute13,
      tl_text_cat_attribute14,
      tl_text_cat_attribute15,
      tl_text_cat_attribute16,
      tl_text_cat_attribute17,
      tl_text_cat_attribute18,
      tl_text_cat_attribute19,
      tl_text_cat_attribute20,
      tl_text_cat_attribute21,
      tl_text_cat_attribute22,
      tl_text_cat_attribute23,
      tl_text_cat_attribute24,
      tl_text_cat_attribute25,
      tl_text_cat_attribute26,
      tl_text_cat_attribute27,
      tl_text_cat_attribute28,
      tl_text_cat_attribute29,
      tl_text_cat_attribute30,
      tl_text_cat_attribute31,
      tl_text_cat_attribute32,
      tl_text_cat_attribute33,
      tl_text_cat_attribute34,
      tl_text_cat_attribute35,
      tl_text_cat_attribute36,
      tl_text_cat_attribute37,
      tl_text_cat_attribute38,
      tl_text_cat_attribute39,
      tl_text_cat_attribute40,
      tl_text_cat_attribute41,
      tl_text_cat_attribute42,
      tl_text_cat_attribute43,
      tl_text_cat_attribute44,
      tl_text_cat_attribute45,
      tl_text_cat_attribute46,
      tl_text_cat_attribute47,
      tl_text_cat_attribute48,
      tl_text_cat_attribute49,
      tl_text_cat_attribute50,
      last_update_login,
      last_updated_by,
      last_update_date,
      created_by,
      creation_date,
      request_id,
      program_application_id,
      program_id,
      program_update_date
    FROM po_attribute_values_tlp
    WHERE attribute_values_tlp_id = p_attribute_values_tlp_id_tbl(i)
    AND x_record_already_exist_tbl(i) = FND_API.G_FALSE
    AND l_duplicate_flag_tbl(i) = FND_API.G_FALSE;

  d_position := 20;
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_position, 'transfer count = ' || SQL%ROWCOUNT);
  END IF;

  FORALL i IN 1..p_attribute_values_tlp_id_tbl.COUNT
    UPDATE po_attribute_values_tlp_draft
    SET    delete_flag = p_delete_flag_tbl(i)
    WHERE  attribute_values_tlp_id = p_attribute_values_tlp_id_tbl(i)
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
--p_attribute_values_tlp_id
--  attribute values unique identifier
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
( p_attribute_values_tlp_id IN NUMBER,
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
    PO_LOG.proc_begin(d_module, 'p_attribute_values_tlp_id',
                                p_attribute_values_tlp_id);
  END IF;

  sync_draft_from_txn
  ( p_attribute_values_tlp_id_tbl => PO_TBL_NUMBER(p_attribute_values_tlp_id),
    p_draft_id_tbl                => PO_TBL_NUMBER(p_draft_id),
    p_delete_flag_tbl             => PO_TBL_VARCHAR1(p_delete_flag),
    x_record_already_exist_tbl    => l_record_already_exist_tbl
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
--START of Comments
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

  DELETE FROM po_attribute_values_tlp PAVT
  WHERE PAVT.attribute_values_tlp_id IN
         ( SELECT PAVTD.attribute_values_tlp_id
           FROM   po_attribute_values_tlp_draft PAVTD
           WHERE  PAVTD.draft_id = p_draft_id
           AND    PAVTD.delete_flag = 'Y'
           AND    NVL(PAVTD.change_accepted_flag, 'Y') = 'Y');

  -- During update case, the following attributes will be skipped:
  --  PAVT.attribute_values_tlp_id = PAVTDV.attribute_values_tlp_id,
  --  PAVT.created_by = PAVTDV.created_by,
  --  PAVT.creation_date = PAVTDV.creation_date,

  MERGE INTO po_attribute_values_tlp PAVT
  USING (
    SELECT
      PAVTD.draft_id,
      PAVTD.delete_flag,
      PAVTD.change_accepted_flag,
      PAVTD.attribute_values_tlp_id,
      PAVTD.po_line_id,
      PAVTD.req_template_name,
      PAVTD.req_template_line_num,
      PAVTD.ip_category_id,
      PAVTD.inventory_item_id,
      PAVTD.org_id,
      PAVTD.language,
      PAVTD.description,
      PAVTD.manufacturer,
      PAVTD.comments,
      PAVTD.alias,
      PAVTD.long_description,
      PAVTD.tl_text_base_attribute1,
      PAVTD.tl_text_base_attribute2,
      PAVTD.tl_text_base_attribute3,
      PAVTD.tl_text_base_attribute4,
      PAVTD.tl_text_base_attribute5,
      PAVTD.tl_text_base_attribute6,
      PAVTD.tl_text_base_attribute7,
      PAVTD.tl_text_base_attribute8,
      PAVTD.tl_text_base_attribute9,
      PAVTD.tl_text_base_attribute10,
      PAVTD.tl_text_base_attribute11,
      PAVTD.tl_text_base_attribute12,
      PAVTD.tl_text_base_attribute13,
      PAVTD.tl_text_base_attribute14,
      PAVTD.tl_text_base_attribute15,
      PAVTD.tl_text_base_attribute16,
      PAVTD.tl_text_base_attribute17,
      PAVTD.tl_text_base_attribute18,
      PAVTD.tl_text_base_attribute19,
      PAVTD.tl_text_base_attribute20,
      PAVTD.tl_text_base_attribute21,
      PAVTD.tl_text_base_attribute22,
      PAVTD.tl_text_base_attribute23,
      PAVTD.tl_text_base_attribute24,
      PAVTD.tl_text_base_attribute25,
      PAVTD.tl_text_base_attribute26,
      PAVTD.tl_text_base_attribute27,
      PAVTD.tl_text_base_attribute28,
      PAVTD.tl_text_base_attribute29,
      PAVTD.tl_text_base_attribute30,
      PAVTD.tl_text_base_attribute31,
      PAVTD.tl_text_base_attribute32,
      PAVTD.tl_text_base_attribute33,
      PAVTD.tl_text_base_attribute34,
      PAVTD.tl_text_base_attribute35,
      PAVTD.tl_text_base_attribute36,
      PAVTD.tl_text_base_attribute37,
      PAVTD.tl_text_base_attribute38,
      PAVTD.tl_text_base_attribute39,
      PAVTD.tl_text_base_attribute40,
      PAVTD.tl_text_base_attribute41,
      PAVTD.tl_text_base_attribute42,
      PAVTD.tl_text_base_attribute43,
      PAVTD.tl_text_base_attribute44,
      PAVTD.tl_text_base_attribute45,
      PAVTD.tl_text_base_attribute46,
      PAVTD.tl_text_base_attribute47,
      PAVTD.tl_text_base_attribute48,
      PAVTD.tl_text_base_attribute49,
      PAVTD.tl_text_base_attribute50,
      PAVTD.tl_text_base_attribute51,
      PAVTD.tl_text_base_attribute52,
      PAVTD.tl_text_base_attribute53,
      PAVTD.tl_text_base_attribute54,
      PAVTD.tl_text_base_attribute55,
      PAVTD.tl_text_base_attribute56,
      PAVTD.tl_text_base_attribute57,
      PAVTD.tl_text_base_attribute58,
      PAVTD.tl_text_base_attribute59,
      PAVTD.tl_text_base_attribute60,
      PAVTD.tl_text_base_attribute61,
      PAVTD.tl_text_base_attribute62,
      PAVTD.tl_text_base_attribute63,
      PAVTD.tl_text_base_attribute64,
      PAVTD.tl_text_base_attribute65,
      PAVTD.tl_text_base_attribute66,
      PAVTD.tl_text_base_attribute67,
      PAVTD.tl_text_base_attribute68,
      PAVTD.tl_text_base_attribute69,
      PAVTD.tl_text_base_attribute70,
      PAVTD.tl_text_base_attribute71,
      PAVTD.tl_text_base_attribute72,
      PAVTD.tl_text_base_attribute73,
      PAVTD.tl_text_base_attribute74,
      PAVTD.tl_text_base_attribute75,
      PAVTD.tl_text_base_attribute76,
      PAVTD.tl_text_base_attribute77,
      PAVTD.tl_text_base_attribute78,
      PAVTD.tl_text_base_attribute79,
      PAVTD.tl_text_base_attribute80,
      PAVTD.tl_text_base_attribute81,
      PAVTD.tl_text_base_attribute82,
      PAVTD.tl_text_base_attribute83,
      PAVTD.tl_text_base_attribute84,
      PAVTD.tl_text_base_attribute85,
      PAVTD.tl_text_base_attribute86,
      PAVTD.tl_text_base_attribute87,
      PAVTD.tl_text_base_attribute88,
      PAVTD.tl_text_base_attribute89,
      PAVTD.tl_text_base_attribute90,
      PAVTD.tl_text_base_attribute91,
      PAVTD.tl_text_base_attribute92,
      PAVTD.tl_text_base_attribute93,
      PAVTD.tl_text_base_attribute94,
      PAVTD.tl_text_base_attribute95,
      PAVTD.tl_text_base_attribute96,
      PAVTD.tl_text_base_attribute97,
      PAVTD.tl_text_base_attribute98,
      PAVTD.tl_text_base_attribute99,
      PAVTD.tl_text_base_attribute100,
      PAVTD.tl_text_cat_attribute1,
      PAVTD.tl_text_cat_attribute2,
      PAVTD.tl_text_cat_attribute3,
      PAVTD.tl_text_cat_attribute4,
      PAVTD.tl_text_cat_attribute5,
      PAVTD.tl_text_cat_attribute6,
      PAVTD.tl_text_cat_attribute7,
      PAVTD.tl_text_cat_attribute8,
      PAVTD.tl_text_cat_attribute9,
      PAVTD.tl_text_cat_attribute10,
      PAVTD.tl_text_cat_attribute11,
      PAVTD.tl_text_cat_attribute12,
      PAVTD.tl_text_cat_attribute13,
      PAVTD.tl_text_cat_attribute14,
      PAVTD.tl_text_cat_attribute15,
      PAVTD.tl_text_cat_attribute16,
      PAVTD.tl_text_cat_attribute17,
      PAVTD.tl_text_cat_attribute18,
      PAVTD.tl_text_cat_attribute19,
      PAVTD.tl_text_cat_attribute20,
      PAVTD.tl_text_cat_attribute21,
      PAVTD.tl_text_cat_attribute22,
      PAVTD.tl_text_cat_attribute23,
      PAVTD.tl_text_cat_attribute24,
      PAVTD.tl_text_cat_attribute25,
      PAVTD.tl_text_cat_attribute26,
      PAVTD.tl_text_cat_attribute27,
      PAVTD.tl_text_cat_attribute28,
      PAVTD.tl_text_cat_attribute29,
      PAVTD.tl_text_cat_attribute30,
      PAVTD.tl_text_cat_attribute31,
      PAVTD.tl_text_cat_attribute32,
      PAVTD.tl_text_cat_attribute33,
      PAVTD.tl_text_cat_attribute34,
      PAVTD.tl_text_cat_attribute35,
      PAVTD.tl_text_cat_attribute36,
      PAVTD.tl_text_cat_attribute37,
      PAVTD.tl_text_cat_attribute38,
      PAVTD.tl_text_cat_attribute39,
      PAVTD.tl_text_cat_attribute40,
      PAVTD.tl_text_cat_attribute41,
      PAVTD.tl_text_cat_attribute42,
      PAVTD.tl_text_cat_attribute43,
      PAVTD.tl_text_cat_attribute44,
      PAVTD.tl_text_cat_attribute45,
      PAVTD.tl_text_cat_attribute46,
      PAVTD.tl_text_cat_attribute47,
      PAVTD.tl_text_cat_attribute48,
      PAVTD.tl_text_cat_attribute49,
      PAVTD.tl_text_cat_attribute50,
      PAVTD.last_update_login,
      PAVTD.last_updated_by,
      PAVTD.last_update_date,
      PAVTD.created_by,
      PAVTD.creation_date,
      PAVTD.request_id,
      PAVTD.program_application_id,
      PAVTD.program_id,
      PAVTD.program_update_date
    FROM po_attribute_values_tlp_draft PAVTD
    WHERE PAVTD.draft_id = p_draft_id
    AND NVL(PAVTD.change_accepted_flag, 'Y') = 'Y') PAVTDV
  ON (PAVT.attribute_values_tlp_id = PAVTDV.attribute_values_tlp_id)
  WHEN MATCHED THEN
    UPDATE
    SET
      PAVT.po_line_id = PAVTDV.po_line_id,
      PAVT.req_template_name = PAVTDV.req_template_name,
      PAVT.req_template_line_num = PAVTDV.req_template_line_num,
      PAVT.ip_category_id = PAVTDV.ip_category_id,
      PAVT.inventory_item_id = PAVTDV.inventory_item_id,
      PAVT.org_id = PAVTDV.org_id,
      PAVT.language = PAVTDV.language,
      PAVT.description = PAVTDV.description,
      PAVT.manufacturer = PAVTDV.manufacturer,
      PAVT.comments = PAVTDV.comments,
      PAVT.alias = PAVTDV.alias,
      PAVT.long_description = PAVTDV.long_description,
      PAVT.tl_text_base_attribute1 = PAVTDV.tl_text_base_attribute1,
      PAVT.tl_text_base_attribute2 = PAVTDV.tl_text_base_attribute2,
      PAVT.tl_text_base_attribute3 = PAVTDV.tl_text_base_attribute3,
      PAVT.tl_text_base_attribute4 = PAVTDV.tl_text_base_attribute4,
      PAVT.tl_text_base_attribute5 = PAVTDV.tl_text_base_attribute5,
      PAVT.tl_text_base_attribute6 = PAVTDV.tl_text_base_attribute6,
      PAVT.tl_text_base_attribute7 = PAVTDV.tl_text_base_attribute7,
      PAVT.tl_text_base_attribute8 = PAVTDV.tl_text_base_attribute8,
      PAVT.tl_text_base_attribute9 = PAVTDV.tl_text_base_attribute9,
      PAVT.tl_text_base_attribute10 = PAVTDV.tl_text_base_attribute10,
      PAVT.tl_text_base_attribute11 = PAVTDV.tl_text_base_attribute11,
      PAVT.tl_text_base_attribute12 = PAVTDV.tl_text_base_attribute12,
      PAVT.tl_text_base_attribute13 = PAVTDV.tl_text_base_attribute13,
      PAVT.tl_text_base_attribute14 = PAVTDV.tl_text_base_attribute14,
      PAVT.tl_text_base_attribute15 = PAVTDV.tl_text_base_attribute15,
      PAVT.tl_text_base_attribute16 = PAVTDV.tl_text_base_attribute16,
      PAVT.tl_text_base_attribute17 = PAVTDV.tl_text_base_attribute17,
      PAVT.tl_text_base_attribute18 = PAVTDV.tl_text_base_attribute18,
      PAVT.tl_text_base_attribute19 = PAVTDV.tl_text_base_attribute19,
      PAVT.tl_text_base_attribute20 = PAVTDV.tl_text_base_attribute20,
      PAVT.tl_text_base_attribute21 = PAVTDV.tl_text_base_attribute21,
      PAVT.tl_text_base_attribute22 = PAVTDV.tl_text_base_attribute22,
      PAVT.tl_text_base_attribute23 = PAVTDV.tl_text_base_attribute23,
      PAVT.tl_text_base_attribute24 = PAVTDV.tl_text_base_attribute24,
      PAVT.tl_text_base_attribute25 = PAVTDV.tl_text_base_attribute25,
      PAVT.tl_text_base_attribute26 = PAVTDV.tl_text_base_attribute26,
      PAVT.tl_text_base_attribute27 = PAVTDV.tl_text_base_attribute27,
      PAVT.tl_text_base_attribute28 = PAVTDV.tl_text_base_attribute28,
      PAVT.tl_text_base_attribute29 = PAVTDV.tl_text_base_attribute29,
      PAVT.tl_text_base_attribute30 = PAVTDV.tl_text_base_attribute30,
      PAVT.tl_text_base_attribute31 = PAVTDV.tl_text_base_attribute31,
      PAVT.tl_text_base_attribute32 = PAVTDV.tl_text_base_attribute32,
      PAVT.tl_text_base_attribute33 = PAVTDV.tl_text_base_attribute33,
      PAVT.tl_text_base_attribute34 = PAVTDV.tl_text_base_attribute34,
      PAVT.tl_text_base_attribute35 = PAVTDV.tl_text_base_attribute35,
      PAVT.tl_text_base_attribute36 = PAVTDV.tl_text_base_attribute36,
      PAVT.tl_text_base_attribute37 = PAVTDV.tl_text_base_attribute37,
      PAVT.tl_text_base_attribute38 = PAVTDV.tl_text_base_attribute38,
      PAVT.tl_text_base_attribute39 = PAVTDV.tl_text_base_attribute39,
      PAVT.tl_text_base_attribute40 = PAVTDV.tl_text_base_attribute40,
      PAVT.tl_text_base_attribute41 = PAVTDV.tl_text_base_attribute41,
      PAVT.tl_text_base_attribute42 = PAVTDV.tl_text_base_attribute42,
      PAVT.tl_text_base_attribute43 = PAVTDV.tl_text_base_attribute43,
      PAVT.tl_text_base_attribute44 = PAVTDV.tl_text_base_attribute44,
      PAVT.tl_text_base_attribute45 = PAVTDV.tl_text_base_attribute45,
      PAVT.tl_text_base_attribute46 = PAVTDV.tl_text_base_attribute46,
      PAVT.tl_text_base_attribute47 = PAVTDV.tl_text_base_attribute47,
      PAVT.tl_text_base_attribute48 = PAVTDV.tl_text_base_attribute48,
      PAVT.tl_text_base_attribute49 = PAVTDV.tl_text_base_attribute49,
      PAVT.tl_text_base_attribute50 = PAVTDV.tl_text_base_attribute50,
      PAVT.tl_text_base_attribute51 = PAVTDV.tl_text_base_attribute51,
      PAVT.tl_text_base_attribute52 = PAVTDV.tl_text_base_attribute52,
      PAVT.tl_text_base_attribute53 = PAVTDV.tl_text_base_attribute53,
      PAVT.tl_text_base_attribute54 = PAVTDV.tl_text_base_attribute54,
      PAVT.tl_text_base_attribute55 = PAVTDV.tl_text_base_attribute55,
      PAVT.tl_text_base_attribute56 = PAVTDV.tl_text_base_attribute56,
      PAVT.tl_text_base_attribute57 = PAVTDV.tl_text_base_attribute57,
      PAVT.tl_text_base_attribute58 = PAVTDV.tl_text_base_attribute58,
      PAVT.tl_text_base_attribute59 = PAVTDV.tl_text_base_attribute59,
      PAVT.tl_text_base_attribute60 = PAVTDV.tl_text_base_attribute60,
      PAVT.tl_text_base_attribute61 = PAVTDV.tl_text_base_attribute61,
      PAVT.tl_text_base_attribute62 = PAVTDV.tl_text_base_attribute62,
      PAVT.tl_text_base_attribute63 = PAVTDV.tl_text_base_attribute63,
      PAVT.tl_text_base_attribute64 = PAVTDV.tl_text_base_attribute64,
      PAVT.tl_text_base_attribute65 = PAVTDV.tl_text_base_attribute65,
      PAVT.tl_text_base_attribute66 = PAVTDV.tl_text_base_attribute66,
      PAVT.tl_text_base_attribute67 = PAVTDV.tl_text_base_attribute67,
      PAVT.tl_text_base_attribute68 = PAVTDV.tl_text_base_attribute68,
      PAVT.tl_text_base_attribute69 = PAVTDV.tl_text_base_attribute69,
      PAVT.tl_text_base_attribute70 = PAVTDV.tl_text_base_attribute70,
      PAVT.tl_text_base_attribute71 = PAVTDV.tl_text_base_attribute71,
      PAVT.tl_text_base_attribute72 = PAVTDV.tl_text_base_attribute72,
      PAVT.tl_text_base_attribute73 = PAVTDV.tl_text_base_attribute73,
      PAVT.tl_text_base_attribute74 = PAVTDV.tl_text_base_attribute74,
      PAVT.tl_text_base_attribute75 = PAVTDV.tl_text_base_attribute75,
      PAVT.tl_text_base_attribute76 = PAVTDV.tl_text_base_attribute76,
      PAVT.tl_text_base_attribute77 = PAVTDV.tl_text_base_attribute77,
      PAVT.tl_text_base_attribute78 = PAVTDV.tl_text_base_attribute78,
      PAVT.tl_text_base_attribute79 = PAVTDV.tl_text_base_attribute79,
      PAVT.tl_text_base_attribute80 = PAVTDV.tl_text_base_attribute80,
      PAVT.tl_text_base_attribute81 = PAVTDV.tl_text_base_attribute81,
      PAVT.tl_text_base_attribute82 = PAVTDV.tl_text_base_attribute82,
      PAVT.tl_text_base_attribute83 = PAVTDV.tl_text_base_attribute83,
      PAVT.tl_text_base_attribute84 = PAVTDV.tl_text_base_attribute84,
      PAVT.tl_text_base_attribute85 = PAVTDV.tl_text_base_attribute85,
      PAVT.tl_text_base_attribute86 = PAVTDV.tl_text_base_attribute86,
      PAVT.tl_text_base_attribute87 = PAVTDV.tl_text_base_attribute87,
      PAVT.tl_text_base_attribute88 = PAVTDV.tl_text_base_attribute88,
      PAVT.tl_text_base_attribute89 = PAVTDV.tl_text_base_attribute89,
      PAVT.tl_text_base_attribute90 = PAVTDV.tl_text_base_attribute90,
      PAVT.tl_text_base_attribute91 = PAVTDV.tl_text_base_attribute91,
      PAVT.tl_text_base_attribute92 = PAVTDV.tl_text_base_attribute92,
      PAVT.tl_text_base_attribute93 = PAVTDV.tl_text_base_attribute93,
      PAVT.tl_text_base_attribute94 = PAVTDV.tl_text_base_attribute94,
      PAVT.tl_text_base_attribute95 = PAVTDV.tl_text_base_attribute95,
      PAVT.tl_text_base_attribute96 = PAVTDV.tl_text_base_attribute96,
      PAVT.tl_text_base_attribute97 = PAVTDV.tl_text_base_attribute97,
      PAVT.tl_text_base_attribute98 = PAVTDV.tl_text_base_attribute98,
      PAVT.tl_text_base_attribute99 = PAVTDV.tl_text_base_attribute99,
      PAVT.tl_text_base_attribute100 = PAVTDV.tl_text_base_attribute100,
      PAVT.tl_text_cat_attribute1 = PAVTDV.tl_text_cat_attribute1,
      PAVT.tl_text_cat_attribute2 = PAVTDV.tl_text_cat_attribute2,
      PAVT.tl_text_cat_attribute3 = PAVTDV.tl_text_cat_attribute3,
      PAVT.tl_text_cat_attribute4 = PAVTDV.tl_text_cat_attribute4,
      PAVT.tl_text_cat_attribute5 = PAVTDV.tl_text_cat_attribute5,
      PAVT.tl_text_cat_attribute6 = PAVTDV.tl_text_cat_attribute6,
      PAVT.tl_text_cat_attribute7 = PAVTDV.tl_text_cat_attribute7,
      PAVT.tl_text_cat_attribute8 = PAVTDV.tl_text_cat_attribute8,
      PAVT.tl_text_cat_attribute9 = PAVTDV.tl_text_cat_attribute9,
      PAVT.tl_text_cat_attribute10 = PAVTDV.tl_text_cat_attribute10,
      PAVT.tl_text_cat_attribute11 = PAVTDV.tl_text_cat_attribute11,
      PAVT.tl_text_cat_attribute12 = PAVTDV.tl_text_cat_attribute12,
      PAVT.tl_text_cat_attribute13 = PAVTDV.tl_text_cat_attribute13,
      PAVT.tl_text_cat_attribute14 = PAVTDV.tl_text_cat_attribute14,
      PAVT.tl_text_cat_attribute15 = PAVTDV.tl_text_cat_attribute15,
      PAVT.tl_text_cat_attribute16 = PAVTDV.tl_text_cat_attribute16,
      PAVT.tl_text_cat_attribute17 = PAVTDV.tl_text_cat_attribute17,
      PAVT.tl_text_cat_attribute18 = PAVTDV.tl_text_cat_attribute18,
      PAVT.tl_text_cat_attribute19 = PAVTDV.tl_text_cat_attribute19,
      PAVT.tl_text_cat_attribute20 = PAVTDV.tl_text_cat_attribute20,
      PAVT.tl_text_cat_attribute21 = PAVTDV.tl_text_cat_attribute21,
      PAVT.tl_text_cat_attribute22 = PAVTDV.tl_text_cat_attribute22,
      PAVT.tl_text_cat_attribute23 = PAVTDV.tl_text_cat_attribute23,
      PAVT.tl_text_cat_attribute24 = PAVTDV.tl_text_cat_attribute24,
      PAVT.tl_text_cat_attribute25 = PAVTDV.tl_text_cat_attribute25,
      PAVT.tl_text_cat_attribute26 = PAVTDV.tl_text_cat_attribute26,
      PAVT.tl_text_cat_attribute27 = PAVTDV.tl_text_cat_attribute27,
      PAVT.tl_text_cat_attribute28 = PAVTDV.tl_text_cat_attribute28,
      PAVT.tl_text_cat_attribute29 = PAVTDV.tl_text_cat_attribute29,
      PAVT.tl_text_cat_attribute30 = PAVTDV.tl_text_cat_attribute30,
      PAVT.tl_text_cat_attribute31 = PAVTDV.tl_text_cat_attribute31,
      PAVT.tl_text_cat_attribute32 = PAVTDV.tl_text_cat_attribute32,
      PAVT.tl_text_cat_attribute33 = PAVTDV.tl_text_cat_attribute33,
      PAVT.tl_text_cat_attribute34 = PAVTDV.tl_text_cat_attribute34,
      PAVT.tl_text_cat_attribute35 = PAVTDV.tl_text_cat_attribute35,
      PAVT.tl_text_cat_attribute36 = PAVTDV.tl_text_cat_attribute36,
      PAVT.tl_text_cat_attribute37 = PAVTDV.tl_text_cat_attribute37,
      PAVT.tl_text_cat_attribute38 = PAVTDV.tl_text_cat_attribute38,
      PAVT.tl_text_cat_attribute39 = PAVTDV.tl_text_cat_attribute39,
      PAVT.tl_text_cat_attribute40 = PAVTDV.tl_text_cat_attribute40,
      PAVT.tl_text_cat_attribute41 = PAVTDV.tl_text_cat_attribute41,
      PAVT.tl_text_cat_attribute42 = PAVTDV.tl_text_cat_attribute42,
      PAVT.tl_text_cat_attribute43 = PAVTDV.tl_text_cat_attribute43,
      PAVT.tl_text_cat_attribute44 = PAVTDV.tl_text_cat_attribute44,
      PAVT.tl_text_cat_attribute45 = PAVTDV.tl_text_cat_attribute45,
      PAVT.tl_text_cat_attribute46 = PAVTDV.tl_text_cat_attribute46,
      PAVT.tl_text_cat_attribute47 = PAVTDV.tl_text_cat_attribute47,
      PAVT.tl_text_cat_attribute48 = PAVTDV.tl_text_cat_attribute48,
      PAVT.tl_text_cat_attribute49 = PAVTDV.tl_text_cat_attribute49,
      PAVT.tl_text_cat_attribute50 = PAVTDV.tl_text_cat_attribute50,
      PAVT.last_update_login = PAVTDV.last_update_login,
      PAVT.last_updated_by = PAVTDV.last_updated_by,
      PAVT.last_update_date = PAVTDV.last_update_date,
      PAVT.request_id = PAVTDV.request_id,
      PAVT.program_application_id = PAVTDV.program_application_id,
      PAVT.program_id = PAVTDV.program_id,
      PAVT.program_update_date = PAVTDV.program_update_date,
      PAVT.rebuild_search_index_flag = 'Y'  -- rebuild_index
  --  DELETE WHERE PAVTDV.delete_flag = 'Y'
  WHEN NOT MATCHED THEN
    INSERT
    (
      PAVT.attribute_values_tlp_id,
      PAVT.po_line_id,
      PAVT.req_template_name,
      PAVT.req_template_line_num,
      PAVT.ip_category_id,
      PAVT.inventory_item_id,
      PAVT.org_id,
      PAVT.language,
      PAVT.description,
      PAVT.manufacturer,
      PAVT.comments,
      PAVT.alias,
      PAVT.long_description,
      PAVT.tl_text_base_attribute1,
      PAVT.tl_text_base_attribute2,
      PAVT.tl_text_base_attribute3,
      PAVT.tl_text_base_attribute4,
      PAVT.tl_text_base_attribute5,
      PAVT.tl_text_base_attribute6,
      PAVT.tl_text_base_attribute7,
      PAVT.tl_text_base_attribute8,
      PAVT.tl_text_base_attribute9,
      PAVT.tl_text_base_attribute10,
      PAVT.tl_text_base_attribute11,
      PAVT.tl_text_base_attribute12,
      PAVT.tl_text_base_attribute13,
      PAVT.tl_text_base_attribute14,
      PAVT.tl_text_base_attribute15,
      PAVT.tl_text_base_attribute16,
      PAVT.tl_text_base_attribute17,
      PAVT.tl_text_base_attribute18,
      PAVT.tl_text_base_attribute19,
      PAVT.tl_text_base_attribute20,
      PAVT.tl_text_base_attribute21,
      PAVT.tl_text_base_attribute22,
      PAVT.tl_text_base_attribute23,
      PAVT.tl_text_base_attribute24,
      PAVT.tl_text_base_attribute25,
      PAVT.tl_text_base_attribute26,
      PAVT.tl_text_base_attribute27,
      PAVT.tl_text_base_attribute28,
      PAVT.tl_text_base_attribute29,
      PAVT.tl_text_base_attribute30,
      PAVT.tl_text_base_attribute31,
      PAVT.tl_text_base_attribute32,
      PAVT.tl_text_base_attribute33,
      PAVT.tl_text_base_attribute34,
      PAVT.tl_text_base_attribute35,
      PAVT.tl_text_base_attribute36,
      PAVT.tl_text_base_attribute37,
      PAVT.tl_text_base_attribute38,
      PAVT.tl_text_base_attribute39,
      PAVT.tl_text_base_attribute40,
      PAVT.tl_text_base_attribute41,
      PAVT.tl_text_base_attribute42,
      PAVT.tl_text_base_attribute43,
      PAVT.tl_text_base_attribute44,
      PAVT.tl_text_base_attribute45,
      PAVT.tl_text_base_attribute46,
      PAVT.tl_text_base_attribute47,
      PAVT.tl_text_base_attribute48,
      PAVT.tl_text_base_attribute49,
      PAVT.tl_text_base_attribute50,
      PAVT.tl_text_base_attribute51,
      PAVT.tl_text_base_attribute52,
      PAVT.tl_text_base_attribute53,
      PAVT.tl_text_base_attribute54,
      PAVT.tl_text_base_attribute55,
      PAVT.tl_text_base_attribute56,
      PAVT.tl_text_base_attribute57,
      PAVT.tl_text_base_attribute58,
      PAVT.tl_text_base_attribute59,
      PAVT.tl_text_base_attribute60,
      PAVT.tl_text_base_attribute61,
      PAVT.tl_text_base_attribute62,
      PAVT.tl_text_base_attribute63,
      PAVT.tl_text_base_attribute64,
      PAVT.tl_text_base_attribute65,
      PAVT.tl_text_base_attribute66,
      PAVT.tl_text_base_attribute67,
      PAVT.tl_text_base_attribute68,
      PAVT.tl_text_base_attribute69,
      PAVT.tl_text_base_attribute70,
      PAVT.tl_text_base_attribute71,
      PAVT.tl_text_base_attribute72,
      PAVT.tl_text_base_attribute73,
      PAVT.tl_text_base_attribute74,
      PAVT.tl_text_base_attribute75,
      PAVT.tl_text_base_attribute76,
      PAVT.tl_text_base_attribute77,
      PAVT.tl_text_base_attribute78,
      PAVT.tl_text_base_attribute79,
      PAVT.tl_text_base_attribute80,
      PAVT.tl_text_base_attribute81,
      PAVT.tl_text_base_attribute82,
      PAVT.tl_text_base_attribute83,
      PAVT.tl_text_base_attribute84,
      PAVT.tl_text_base_attribute85,
      PAVT.tl_text_base_attribute86,
      PAVT.tl_text_base_attribute87,
      PAVT.tl_text_base_attribute88,
      PAVT.tl_text_base_attribute89,
      PAVT.tl_text_base_attribute90,
      PAVT.tl_text_base_attribute91,
      PAVT.tl_text_base_attribute92,
      PAVT.tl_text_base_attribute93,
      PAVT.tl_text_base_attribute94,
      PAVT.tl_text_base_attribute95,
      PAVT.tl_text_base_attribute96,
      PAVT.tl_text_base_attribute97,
      PAVT.tl_text_base_attribute98,
      PAVT.tl_text_base_attribute99,
      PAVT.tl_text_base_attribute100,
      PAVT.tl_text_cat_attribute1,
      PAVT.tl_text_cat_attribute2,
      PAVT.tl_text_cat_attribute3,
      PAVT.tl_text_cat_attribute4,
      PAVT.tl_text_cat_attribute5,
      PAVT.tl_text_cat_attribute6,
      PAVT.tl_text_cat_attribute7,
      PAVT.tl_text_cat_attribute8,
      PAVT.tl_text_cat_attribute9,
      PAVT.tl_text_cat_attribute10,
      PAVT.tl_text_cat_attribute11,
      PAVT.tl_text_cat_attribute12,
      PAVT.tl_text_cat_attribute13,
      PAVT.tl_text_cat_attribute14,
      PAVT.tl_text_cat_attribute15,
      PAVT.tl_text_cat_attribute16,
      PAVT.tl_text_cat_attribute17,
      PAVT.tl_text_cat_attribute18,
      PAVT.tl_text_cat_attribute19,
      PAVT.tl_text_cat_attribute20,
      PAVT.tl_text_cat_attribute21,
      PAVT.tl_text_cat_attribute22,
      PAVT.tl_text_cat_attribute23,
      PAVT.tl_text_cat_attribute24,
      PAVT.tl_text_cat_attribute25,
      PAVT.tl_text_cat_attribute26,
      PAVT.tl_text_cat_attribute27,
      PAVT.tl_text_cat_attribute28,
      PAVT.tl_text_cat_attribute29,
      PAVT.tl_text_cat_attribute30,
      PAVT.tl_text_cat_attribute31,
      PAVT.tl_text_cat_attribute32,
      PAVT.tl_text_cat_attribute33,
      PAVT.tl_text_cat_attribute34,
      PAVT.tl_text_cat_attribute35,
      PAVT.tl_text_cat_attribute36,
      PAVT.tl_text_cat_attribute37,
      PAVT.tl_text_cat_attribute38,
      PAVT.tl_text_cat_attribute39,
      PAVT.tl_text_cat_attribute40,
      PAVT.tl_text_cat_attribute41,
      PAVT.tl_text_cat_attribute42,
      PAVT.tl_text_cat_attribute43,
      PAVT.tl_text_cat_attribute44,
      PAVT.tl_text_cat_attribute45,
      PAVT.tl_text_cat_attribute46,
      PAVT.tl_text_cat_attribute47,
      PAVT.tl_text_cat_attribute48,
      PAVT.tl_text_cat_attribute49,
      PAVT.tl_text_cat_attribute50,
      PAVT.last_update_login,
      PAVT.last_updated_by,
      PAVT.last_update_date,
      PAVT.created_by,
      PAVT.creation_date,
      PAVT.request_id,
      PAVT.program_application_id,
      PAVT.program_id,
      PAVT.program_update_date,
      PAVT.rebuild_search_index_flag
    )
    VALUES
    (
      PAVTDV.attribute_values_tlp_id,
      PAVTDV.po_line_id,
      PAVTDV.req_template_name,
      PAVTDV.req_template_line_num,
      PAVTDV.ip_category_id,
      PAVTDV.inventory_item_id,
      PAVTDV.org_id,
      PAVTDV.language,
      PAVTDV.description,
      PAVTDV.manufacturer,
      PAVTDV.comments,
      PAVTDV.alias,
      PAVTDV.long_description,
      PAVTDV.tl_text_base_attribute1,
      PAVTDV.tl_text_base_attribute2,
      PAVTDV.tl_text_base_attribute3,
      PAVTDV.tl_text_base_attribute4,
      PAVTDV.tl_text_base_attribute5,
      PAVTDV.tl_text_base_attribute6,
      PAVTDV.tl_text_base_attribute7,
      PAVTDV.tl_text_base_attribute8,
      PAVTDV.tl_text_base_attribute9,
      PAVTDV.tl_text_base_attribute10,
      PAVTDV.tl_text_base_attribute11,
      PAVTDV.tl_text_base_attribute12,
      PAVTDV.tl_text_base_attribute13,
      PAVTDV.tl_text_base_attribute14,
      PAVTDV.tl_text_base_attribute15,
      PAVTDV.tl_text_base_attribute16,
      PAVTDV.tl_text_base_attribute17,
      PAVTDV.tl_text_base_attribute18,
      PAVTDV.tl_text_base_attribute19,
      PAVTDV.tl_text_base_attribute20,
      PAVTDV.tl_text_base_attribute21,
      PAVTDV.tl_text_base_attribute22,
      PAVTDV.tl_text_base_attribute23,
      PAVTDV.tl_text_base_attribute24,
      PAVTDV.tl_text_base_attribute25,
      PAVTDV.tl_text_base_attribute26,
      PAVTDV.tl_text_base_attribute27,
      PAVTDV.tl_text_base_attribute28,
      PAVTDV.tl_text_base_attribute29,
      PAVTDV.tl_text_base_attribute30,
      PAVTDV.tl_text_base_attribute31,
      PAVTDV.tl_text_base_attribute32,
      PAVTDV.tl_text_base_attribute33,
      PAVTDV.tl_text_base_attribute34,
      PAVTDV.tl_text_base_attribute35,
      PAVTDV.tl_text_base_attribute36,
      PAVTDV.tl_text_base_attribute37,
      PAVTDV.tl_text_base_attribute38,
      PAVTDV.tl_text_base_attribute39,
      PAVTDV.tl_text_base_attribute40,
      PAVTDV.tl_text_base_attribute41,
      PAVTDV.tl_text_base_attribute42,
      PAVTDV.tl_text_base_attribute43,
      PAVTDV.tl_text_base_attribute44,
      PAVTDV.tl_text_base_attribute45,
      PAVTDV.tl_text_base_attribute46,
      PAVTDV.tl_text_base_attribute47,
      PAVTDV.tl_text_base_attribute48,
      PAVTDV.tl_text_base_attribute49,
      PAVTDV.tl_text_base_attribute50,
      PAVTDV.tl_text_base_attribute51,
      PAVTDV.tl_text_base_attribute52,
      PAVTDV.tl_text_base_attribute53,
      PAVTDV.tl_text_base_attribute54,
      PAVTDV.tl_text_base_attribute55,
      PAVTDV.tl_text_base_attribute56,
      PAVTDV.tl_text_base_attribute57,
      PAVTDV.tl_text_base_attribute58,
      PAVTDV.tl_text_base_attribute59,
      PAVTDV.tl_text_base_attribute60,
      PAVTDV.tl_text_base_attribute61,
      PAVTDV.tl_text_base_attribute62,
      PAVTDV.tl_text_base_attribute63,
      PAVTDV.tl_text_base_attribute64,
      PAVTDV.tl_text_base_attribute65,
      PAVTDV.tl_text_base_attribute66,
      PAVTDV.tl_text_base_attribute67,
      PAVTDV.tl_text_base_attribute68,
      PAVTDV.tl_text_base_attribute69,
      PAVTDV.tl_text_base_attribute70,
      PAVTDV.tl_text_base_attribute71,
      PAVTDV.tl_text_base_attribute72,
      PAVTDV.tl_text_base_attribute73,
      PAVTDV.tl_text_base_attribute74,
      PAVTDV.tl_text_base_attribute75,
      PAVTDV.tl_text_base_attribute76,
      PAVTDV.tl_text_base_attribute77,
      PAVTDV.tl_text_base_attribute78,
      PAVTDV.tl_text_base_attribute79,
      PAVTDV.tl_text_base_attribute80,
      PAVTDV.tl_text_base_attribute81,
      PAVTDV.tl_text_base_attribute82,
      PAVTDV.tl_text_base_attribute83,
      PAVTDV.tl_text_base_attribute84,
      PAVTDV.tl_text_base_attribute85,
      PAVTDV.tl_text_base_attribute86,
      PAVTDV.tl_text_base_attribute87,
      PAVTDV.tl_text_base_attribute88,
      PAVTDV.tl_text_base_attribute89,
      PAVTDV.tl_text_base_attribute90,
      PAVTDV.tl_text_base_attribute91,
      PAVTDV.tl_text_base_attribute92,
      PAVTDV.tl_text_base_attribute93,
      PAVTDV.tl_text_base_attribute94,
      PAVTDV.tl_text_base_attribute95,
      PAVTDV.tl_text_base_attribute96,
      PAVTDV.tl_text_base_attribute97,
      PAVTDV.tl_text_base_attribute98,
      PAVTDV.tl_text_base_attribute99,
      PAVTDV.tl_text_base_attribute100,
      PAVTDV.tl_text_cat_attribute1,
      PAVTDV.tl_text_cat_attribute2,
      PAVTDV.tl_text_cat_attribute3,
      PAVTDV.tl_text_cat_attribute4,
      PAVTDV.tl_text_cat_attribute5,
      PAVTDV.tl_text_cat_attribute6,
      PAVTDV.tl_text_cat_attribute7,
      PAVTDV.tl_text_cat_attribute8,
      PAVTDV.tl_text_cat_attribute9,
      PAVTDV.tl_text_cat_attribute10,
      PAVTDV.tl_text_cat_attribute11,
      PAVTDV.tl_text_cat_attribute12,
      PAVTDV.tl_text_cat_attribute13,
      PAVTDV.tl_text_cat_attribute14,
      PAVTDV.tl_text_cat_attribute15,
      PAVTDV.tl_text_cat_attribute16,
      PAVTDV.tl_text_cat_attribute17,
      PAVTDV.tl_text_cat_attribute18,
      PAVTDV.tl_text_cat_attribute19,
      PAVTDV.tl_text_cat_attribute20,
      PAVTDV.tl_text_cat_attribute21,
      PAVTDV.tl_text_cat_attribute22,
      PAVTDV.tl_text_cat_attribute23,
      PAVTDV.tl_text_cat_attribute24,
      PAVTDV.tl_text_cat_attribute25,
      PAVTDV.tl_text_cat_attribute26,
      PAVTDV.tl_text_cat_attribute27,
      PAVTDV.tl_text_cat_attribute28,
      PAVTDV.tl_text_cat_attribute29,
      PAVTDV.tl_text_cat_attribute30,
      PAVTDV.tl_text_cat_attribute31,
      PAVTDV.tl_text_cat_attribute32,
      PAVTDV.tl_text_cat_attribute33,
      PAVTDV.tl_text_cat_attribute34,
      PAVTDV.tl_text_cat_attribute35,
      PAVTDV.tl_text_cat_attribute36,
      PAVTDV.tl_text_cat_attribute37,
      PAVTDV.tl_text_cat_attribute38,
      PAVTDV.tl_text_cat_attribute39,
      PAVTDV.tl_text_cat_attribute40,
      PAVTDV.tl_text_cat_attribute41,
      PAVTDV.tl_text_cat_attribute42,
      PAVTDV.tl_text_cat_attribute43,
      PAVTDV.tl_text_cat_attribute44,
      PAVTDV.tl_text_cat_attribute45,
      PAVTDV.tl_text_cat_attribute46,
      PAVTDV.tl_text_cat_attribute47,
      PAVTDV.tl_text_cat_attribute48,
      PAVTDV.tl_text_cat_attribute49,
      PAVTDV.tl_text_cat_attribute50,
      PAVTDV.last_update_login,
      PAVTDV.last_updated_by,
      PAVTDV.last_update_date,
      PAVTDV.created_by,
      PAVTDV.creation_date,
      PAVTDV.request_id,
      PAVTDV.program_application_id,
      PAVTDV.program_id,
      PAVTDV.program_update_date,
      'Y'   -- rebuild index
    ) WHERE NVL(PAVTDV.delete_flag, 'N') <> 'Y';

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
--p_attribute_values_tlp_id
--  id for attribute values tlp record
--p_draft_id
--  draft unique identifier
--RETURN:
--End of Comments
------------------------------------------------------------------------
PROCEDURE lock_draft_record
( p_attribute_values_tlp_id IN NUMBER,
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
  FROM po_attribute_values_tlp_draft
  WHERE attribute_values_tlp_id = p_attribute_values_tlp_id
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
--p_attribute_values_tlp_id
--  id for attribute values tlp record
--RETURN:
--End of Comments
------------------------------------------------------------------------
PROCEDURE lock_transaction_record
( p_attribute_values_tlp_id IN NUMBER
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
  FROM po_attribute_values_tlp
  WHERE attribute_values_tlp_id = p_attribute_values_tlp_id
  FOR UPDATE NOWAIT;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
WHEN NO_DATA_FOUND THEN
  NULL;
END lock_transaction_record;

END PO_ATTR_VALUES_TLP_DRAFT_PKG;

/
